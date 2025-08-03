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

unit DecSoft.Ollama.Chat.Types;

interface

uses
  System.JSON,
  System.Classes,
  System.SysUtils,

  DecSoft.Ollama.Chat.Tools,
  DecSoft.Ollama.Params.Types;

type

  TResponseMessage = record
  public
    Role: string;
    Content: string;
  end;

  TResponseToolCallArgument = record
  public
    Name: string;
    Value: string;
  end;

  TResponseToolCall = record
  public
    Name: string;
    Arguments: TArray<TResponseToolCallArgument>;
  end;

  TChatResponseResult = record
  public
    Model: string;
    Done: Boolean;
    CreatedAt: string;
    TotalDuration: Int64;
    LoadDuration: Int64;
    PromptEvalCount: Int64;
    PromptEvalDuration: Int64;
    EvalCount: Int64;
    EvalDuration: Int64;
    DoneReason: string;
    Streamed: Boolean;
    Message: TResponseMessage;
    ToolCalls: TArray<TResponseToolCall>;
    AsJSON: TJSONValue;
  end;

  TChatMessageRole = (cmSystem, cmUser, cmAssistant, cmTool);

  TChatMessage = record
  public
    Role: TChatMessageRole;
    Content: string;
    Images: TArray<TFileName>;
  public
    procedure ClearImages();
    function ToString(): string;
    function ToJSON(): TJSONObject;
    function RoleToString(): string;
    procedure AddImage(const FileName: TFileName);
  end;

  TChatResponseProc = reference to
   procedure (const Result: TChatResponseResult; var Stop: Boolean);

  TChatParams = record
  public
    Model: string;
    Stream: Boolean;
    KeepAlive: string;
    Options: TOptionsParam;
    Tools: TArray<TChatTool>;
    Messages: TArray<TChatMessage>;
  public
    procedure Clear();
    function ToString(): string;
    procedure AppendMessage(const ChatMessage: TChatMessage);
    procedure SetMessages(const ChatMessages: TArray<TChatMessage>);
  end;

  TChatParamsProc = reference to
   procedure (var ChatParams: TChatParams);

implementation

uses
  DecSoft.Ollama.Chat.Utils,
  DecSoft.Ollama.Base64.Utils;

{ TChatMessage }

procedure TChatMessage.AddImage(const FileName: TFileName);
begin
  if FileExists(FileName) then
    Self.Images := Self.Images + [FileName]
  else
    raise Exception.CreateFmt('Missing file name: %s', [FileName]);
end;

procedure TChatMessage.ClearImages();
begin
  Self.Images := [];
end;

function TChatMessage.RoleToString(): string;
begin
  Result := MessageRoleToString(Self.Role);
end;

function TChatMessage.ToJSON(): TJSONObject;
var
  FileName: TFileName;
  ImagesJSON: TJSONArray;
begin
  Result := TJSONObject.Create();
  Result.AddPair(TJSONPair.Create('role', Self.RoleToString()));
  Result.AddPair(TJSONPair.Create('content', Self.Content));

  if Length(Self.Images) > 0 then
  begin
    ImagesJSON := TJSONArray.Create();
    for FileName in Self.Images do
    begin
      if FileExists(FileName) then
      begin
        ImagesJSON.Add(FileToBase64(FileName).ToString());
      end
      else
      begin
        raise Exception.Create(
         'The chat message images is set but some file do not exist.');
      end;
    end;
    if ImagesJSON.Count > 0 then
    begin
      Result.AddPair('images', ImagesJSON);
    end;
  end;
end;

function TChatMessage.ToString(): string;
var
  ChatMessageJSON: TJSONObject;
begin
  ChatMessageJSON := Self.ToJSON();
  try
    Result := ChatMessageJSON.ToString();
  finally
    ChatMessageJSON.Free();
  end;
end;

{ TChatParams }

procedure TChatParams.AppendMessage(const ChatMessage: TChatMessage);
begin
  Self.Messages := Self.Messages + [ChatMessage];
end;

procedure TChatParams.SetMessages(const ChatMessages: TArray<TChatMessage>);
begin
  Self.Messages := ChatMessages;
end;

procedure TChatParams.Clear();
begin
  Self.Messages := [];
end;

function TChatParams.ToString(): string;
var
  ChatTool: TChatTool;
  StopSequence: string;
  ChatMessage: TChatMessage;
  Options, Params: TJSONObject;
  Messages, Tools, StopSequences: TJSONArray;
begin
  Messages := TJSONArray.Create();
  Params := TJSONObject.Create();
  try

    with Params do
    begin
      AddPair(TJSONPair.Create('model', Self.Model));
      AddPair(TJSONPair.Create('stream', TJSONBool.Create(Self.Stream)));
    end;

    if Self.KeepAlive <> '' then
      Params.AddPair(TJSONPair.Create('keep_alive', Self.KeepAlive));

    Options := TJSONObject.Create();

    with Options do
    begin
      AddPair('mirostat', TJSONNumber.Create(Self.Options.Mirostat));
      AddPair('mirostat_eta', TJSONNumber.Create(Self.Options.MirostatEta));
      AddPair('mirostat_tau', TJSONNumber.Create(Self.Options.MirostatTau));
      AddPair('num_ctx', TJSONNumber.Create(Self.Options.NumCtx));
      AddPair('repeat_last_n', TJSONNumber.Create(Self.Options.RepeatLastN));
      AddPair('repeat_penalty', TJSONNumber.Create(Self.Options.RepeatPenalty));
      AddPair('temperature', TJSONNumber.Create(Self.Options.Temperature));
      AddPair('seed', TJSONNumber.Create(Self.Options.Seed));
    end;

    if Length(Self.Options.Stop) > 0 then
    begin
      StopSequences := TJSONArray.Create();
      for StopSequence in Self.Options.Stop do
      begin
        StopSequences.Add(StopSequence);
      end;
      Options.AddPair('stop', StopSequences);
    end;

    Options.AddPair('tfs_z', TJSONNumber.Create(Self.Options.TfsZ));
    Options.AddPair('num_predict', TJSONNumber.Create(Self.Options.NumCtx));
    Options.AddPair('top_k', TJSONNumber.Create(Self.Options.TopK));
    Options.AddPair('top_p', TJSONNumber.Create(Self.Options.TopP));
    Options.AddPair('min_p', TJSONNumber.Create(Self.Options.MinP));

    Params.AddPair('options', Options);

    for ChatMessage in Self.Messages do
    begin
      Messages.AddElement(ChatMessage.ToJSON());
    end;

    Params.AddPair('messages', Messages);

    if Length(Self.Tools) > 0 then
    begin
      Tools := TJSONArray.Create();

      for ChatTool in Self.Tools do
      begin
        Tools.AddElement(ChatTool.ToJSON());
      end;

      Params.AddPair('tools', Tools);
    end;

    Result := Params.ToString();

  finally
    Params.Free();
  end;
end;

end.
