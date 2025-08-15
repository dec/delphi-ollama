(*
 MIT license

 Copyright (c) DecSoft Utils

 https://www.decsoftutils.com/
 https://github.com/dec/delphi-ollama

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*)

unit DecSoft.Ollama.Generation.Request;

interface

uses
  DecSoft.Ollama.Request,
  DecSoft.Ollama.Response.Types,
  DecSoft.Ollama.Generation.Types;

type
  TGenerationRequest = class (TOllamaRequest)
  private
    FGenerationlResponseProc: TGenerationResponseProc;
  private
    procedure ReceiveData(const Sender: TObject; AContentLength: Int64;
     AReadCount: Int64; var AAbort: Boolean);
  public
    procedure Run(GenerationParamsProc: TGenerationParamsProc;
     GenerationResponseProc: TGenerationResponseProc; ResponseErrorProc:
      TResponseErrorProc);
  public
    property Streamed: Boolean read FStreamed;
  end;

implementation

uses
  System.JSON,
  System.Classes,
  System.SysUtils,

  DecSoft.Ollama.Strings,
  DecSoft.Ollama.Params.Constants;

{ TGenerationRequest }

procedure TGenerationRequest.Run(GenerationParamsProc: TGenerationParamsProc;
 GenerationResponseProc: TGenerationResponseProc; ResponseErrorProc:
  TResponseErrorProc);
var
  RequestStream: TStringStream;
  GenerationParams: TGenerationParams;
begin

  GenerationParams := DefaultGenerationParams;
  GenerationParams.Options := DefaultOptionsParam;

  if Assigned(GenerationParamsProc) then
    GenerationParamsProc(GenerationParams);

  FResponseErrorProc := ResponseErrorProc;
  FGenerationlResponseProc := GenerationResponseProc;

  RequestStream := TStringStream.Create(
   GenerationParams.ToString(), TEncoding.UTF8);

  try
    Self.Post(Format('%sgenerate', [FApiUrl]), RequestStream, Self.ReceiveData);
  finally
    RequestStream.Free();
  end;
end;

procedure TGenerationRequest.ReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var AAbort: Boolean);
var
  Thinking: string;
  ResponseJSON: TJSONValue;
  ResponseResult: TGenerationResponseResult;
begin

  AAbort := FStopped;

  if Trim(FPartialResponse.DataString) = '' then
    Exit;

  ResponseJSON := TJSONObject.ParseJSONValue(FPartialResponse.DataString);

  try

    if not Assigned(ResponseJSON) then
      Exit;

    ResponseResult.AsJSON := ResponseJSON;
    ResponseResult.Streamed := FStreamed;
    ResponseResult.Done := ResponseJSON.GetValue<Boolean>('done');
    ResponseResult.Model := ResponseJSON.GetValue<string>('model');
    ResponseResult.Response := ResponseJSON.GetValue<string>('response');
    ResponseResult.Response := ResponseJSON.GetValue<string>('response');
    ResponseResult.CreatedAt := ResponseJSON.GetValue<string>('created_at');

    if ResponseJSON.TryGetValue<string>('thinking', Thinking) then
      ResponseResult.Thinking := Thinking;

    FCompleteResponse.WriteString(ResponseResult.Response);

    if FStreamed and not ResponseResult.Done and
     Assigned(FGenerationlResponseProc)then
    begin
      FGenerationlResponseProc(ResponseResult, FStopped);
      FPartialResponse.Clear();
    end;

    if ResponseResult.Done and Assigned(FGenerationlResponseProc) then
    begin

      FCompleteResponse.Position := 0;

      with ResponseResult do
      begin
        Response := ResponseResult.Response;
        TotalDuration := ResponseJSON.GetValue<Int64>('total_duration');
        LoadDuration := ResponseJSON.GetValue<Int64>('load_duration');
        EvalCount := ResponseJSON.GetValue<Int64>('eval_count');
        EvalDuration := ResponseJSON.GetValue<Int64>('eval_duration');
        DoneReason := ResponseJSON.GetValue<string>('done_reason');

        // Because if the "raw" parameter is True there is no context
        ResponseJSON.TryGetValue<TArray<Int64>>('context', Context);

        PromptEvalCount :=
          ResponseJSON.GetValue<Int64>('prompt_eval_count');

        PromptEvalDuration :=
          ResponseJSON.GetValue<Int64>('prompt_eval_duration');
      end;

      FGenerationlResponseProc(ResponseResult, FStopped);
    end;

  finally
    ResponseJSON.Free();
  end;
end;

end.
