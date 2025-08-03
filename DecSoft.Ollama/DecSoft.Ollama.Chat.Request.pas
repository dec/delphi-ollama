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

unit DecSoft.Ollama.Chat.Request;

interface

uses
  DecSoft.Ollama.Request,
  DecSoft.Ollama.Chat.Types,
  DecSoft.Ollama.Chat.Tools,
  DecSoft.Ollama.Response.Types;

type
  TChatRequest = class (TOllamaRequest)
  private
    FChatParams: TChatParams;
    FChatResponseProc: TChatResponseProc;
  private
    function GetChatToolByName(const Name: string): TChatTool;
  private
    procedure ReceiveData(const Sender: TObject; AContentLength: Int64;
     AReadCount: Int64; var AAbort: Boolean);
  public
    procedure Run(ChatParamsProc: TChatParamsProc; ChatPartialResponseProc:
     TChatResponseProc; ResponseErrorProc: TResponseErrorProc);
  public
    property Streamed: Boolean read FStreamed;
  end;

implementation

uses
  System.JSON,
  System.Classes,
  System.SysUtils,

  DecSoft.Ollama.Strings,
  DecSoft.Ollama.Params.Types,
  DecSoft.Ollama.Params.Constants;

{ TChatRequest }

procedure TChatRequest.Run(ChatParamsProc: TChatParamsProc;
 ChatPartialResponseProc: TChatResponseProc;
  ResponseErrorProc: TResponseErrorProc);
var
  RequestStream: TStringStream;
begin

  FChatParams := DefaultChatParams;
  FChatParams.Options := DefaultOptionsParam;

  if Assigned(ChatParamsProc) then
    ChatParamsProc(FChatParams);
  
  FResponseErrorProc := ResponseErrorProc;
  FChatResponseProc := ChatPartialResponseProc;

  RequestStream := TStringStream.Create(
   FChatParams.ToString(), TEncoding.UTF8);
  try

    Self.Post(Format('%schat', [FApiUrl]), RequestStream, Self.ReceiveData);

  finally
    RequestStream.Free();
  end;
end;

procedure TChatRequest.ReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var AAbort: Boolean);
var
  PropValue: string;
  ChatTool: TChatTool;
  ToolCallDef: TJSONValue;
  ResponseJSON: TJSONValue;
  ToolCallsArray: TJSONArray;
  ToolCall: TResponseToolCall;
  ChatToolParam: TChatToolParameter;
  ResponseResult: TChatResponseResult;
  ToolCallArgument: TResponseToolCallArgument;
  ChatToolParamProp: TChatToolParameterProperty;
begin

  AAbort := FStopped;

  if Trim(FPartialResponse.DataString) = '' then
    Exit;
    
  ResponseJSON := TJSONObject.ParseJSONValue(FPartialResponse.DataString);

  try

    if not Assigned(ResponseJSON) then
      Exit;

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

    FCompleteResponse.WriteString(ResponseResult.Message.Content);

    if FStreamed and not ResponseResult.Done and
     Assigned(FChatResponseProc)then
    begin
      FChatResponseProc(ResponseResult, FStopped);
      FPartialResponse.Clear();
    end;

    if ResponseResult.Done and Assigned(FChatResponseProc) then
    begin

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

      if ResponseJSON.TryGetValue<TJSONArray>
       ('message.tool_calls', ToolCallsArray) then
      begin

        for ToolCallDef in ToolCallsArray do
        begin

          ChatTool := Self.GetChatToolByName(
           ToolCallDef.GetValue<string>('function.name'));

          if ChatTool.Name <> '' then
          begin

            ToolCall.Name := ToolCallDef.GetValue<string>('function.name');

            for ChatToolParam in ChatTool.Parameters do
            begin

              for ChatToolParamProp in ChatToolParam.Properties do
              begin

                if ToolCallDef.TryGetValue<string>(Format(
                 'function.arguments.%s', [ChatToolParamProp.Name]),
                  PropValue) then
                begin
                  ToolCallArgument.Name := ChatToolParamProp.Name;
                  ToolCallArgument.Value := ToolCallDef.GetValue<string>(
                   Format('function.arguments.%s', [ChatToolParamProp.Name]));
                end
                else
                begin
                  // This can help in the implementation: if there is no
                  // parameter, we always set it, but with an empty value.
                  ToolCallArgument.Name := ChatToolParamProp.Name;
                  ToolCallArgument.Value := '';
                end;

                ToolCall.Arguments := ToolCall.Arguments + [ToolCallArgument];
              end;
            end;

            ResponseResult.ToolCalls := ResponseResult.ToolCalls + [ToolCall];
          end;
        end;
      end;

      FChatResponseProc(ResponseResult, FStopped);
    end;

  finally
    ResponseJSON.Free();
  end;
end;

function TChatRequest.GetChatToolByName(const Name: string): TChatTool;
var
  ChatTool: TChatTool;
begin
  ChatTool.Name := '';

  Result := ChatTool;

  for ChatTool in FChatParams.Tools do
  begin
    if ChatTool.Name = Name then
    begin
      Result := ChatTool;
      Break;
    end;
  end;
end;

end.
