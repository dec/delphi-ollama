(*
 MIT license

 Copyright (c) 2025 DecSoft Utils

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

unit DecSoft.Ollama.Chat.Request;

interface

uses
  System.JSON,
  System.Classes,
  System.SysUtils,
  System.Net.URLClient,
  System.Net.HttpClient,

  DecSoft.Ollama.Request,
  DecSoft.Ollama.Chat.Types,
  DecSoft.Ollama.Response.Types;

type
  TChatRequest = class (TOllamaRequest)
  private
    FChatResponseProc: TChatResponseProc;
  private
    procedure ReceiveData(const Sender: TObject; AContentLength: Int64;
     AReadCount: Int64; var AAbort: Boolean);
  public
    procedure Run(ChatParamsProc: TChatParamsProc; ChatPartialResponseProc:
     TChatResponseProc; ErrorResponseProc: TErrorResponseProc);
  public
    property Streamed: Boolean read FStreamed;
  end;

implementation

uses
  DecSoft.Ollama.Params.Types,
  DecSoft.Ollama.Params.Constants;

{ TChatRequest }

procedure TChatRequest.Run(ChatParamsProc: TChatParamsProc;
 ChatPartialResponseProc: TChatResponseProc;
  ErrorResponseProc: TErrorResponseProc);
var
  ChatParams: TChatParams;
  RequestStream: TStringStream;
begin

  ChatParams := DefaultChatParams;
  ChatParams.Options := DefaultOptionsParam;

  if Assigned(ChatParamsProc) then
    ChatParamsProc(ChatParams);

  FErrorResponseProc := ErrorResponseProc;
  FChatResponseProc := ChatPartialResponseProc;

  RequestStream := TStringStream.Create(
   ChatParams.ToString(), TEncoding.UTF8);
  try

    Self.Post(Format('%schat', [FApiUrl]), RequestStream, Self.ReceiveData);

  finally
    RequestStream.Free();
  end;
end;

procedure TChatRequest.ReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var AAbort: Boolean);
var
  ResponseJSON: TJSONValue;
  ResponseResult: TChatResponseResult;
begin

  if FStopped then
  begin
    AAbort := True;
    FPartialResponse.Clear();
    Exit;
  end;

  if Trim(FPartialResponse.DataString) = '' then
    Exit;

  ResponseJSON := TJSONObject.ParseJSONValue(FPartialResponse.DataString);

  try
    if Assigned(ResponseJSON) then
    begin

      with ResponseResult do
      begin
        AsJSON := ResponseJSON;
        Streamed := FStreamed;
        Done := ResponseJSON.GetValue<Boolean>('done');
        Model := ResponseJSON.GetValue<string>('model');
        Message.Role := ResponseJSON.GetValue<string>('message.role');
        Message.Content := ResponseJSON.GetValue<string>('message.content');
        CreatedAt := ResponseJSON.GetValue<string>('created_at');
      end;

      if FStreamed then
      begin
        if Assigned(FChatResponseProc) then
          FChatResponseProc(ResponseResult, FStopped);

        FPartialResponse.Clear();
      end
      else
      begin
        if ResponseResult.Done and Assigned(FChatResponseProc) then
        begin

          FCompleteResponse.WriteString(ResponseResult.Message.Content);
          FCompleteResponse.Position := 0;

          with ResponseResult do
          begin
            Message.Content := FCompleteResponse.DataString;
            TotalDuration := ResponseJSON.GetValue<Int64>('total_duration');
            LoadDuration := ResponseJSON.GetValue<Int64>('load_duration');
            EvalCount := ResponseJSON.GetValue<Int64>('eval_count');
            EvalDuration := ResponseJSON.GetValue<Int64>('eval_duration');
            DoneReason := ResponseJSON.GetValue<string>('done_reason');

            PromptEvalCount :=
              ResponseJSON.GetValue<Int64>('prompt_eval_count');

            PromptEvalDuration :=
              ResponseJSON.GetValue<Int64>('prompt_eval_duration');
          end;

          FChatResponseProc(ResponseResult, FStopped);
        end;

      end;
    end;

  finally
    ResponseJSON.Free();
  end;
end;

end.
