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

unit DecSoft.Ollama.Chat.History;

interface

uses
  DecSoft.Ollama.Chat.Types;

type
  TChatHistory = class(TObject)
  private
    FAutoTrim: Boolean;
    FMaxMessages: Integer;
    FMessages: TArray<TChatMessage>;
  public
    constructor Create(const AutoTrim: Boolean = True;
     const MaxMessages: Integer = 50); reintroduce;
  public
    function GetMessages(): TArray<TChatMessage>;
    function AddMessage(const ChatMessage: TChatMessage): Integer;
  public
    property AutoTrim: Boolean read FAutoTrim write FAutoTrim;
  end;

implementation

{ TChatHistory }

constructor TChatHistory.Create(const AutoTrim:
 Boolean = True; const MaxMessages: Integer = 50);
begin
  inherited Create();
  FMessages := [];
  FAutoTrim := AutoTrim;
  FMaxMessages := MaxMessages;
end;

function TChatHistory.AddMessage(const ChatMessage: TChatMessage): Integer;
begin
  FMessages := FMessages + [ChatMessage];

  if FAutoTrim and (Length(FMessages) > FMaxMessages) then
  begin
    Delete(FMessages, 0, FMaxMessages div 2);
  end;

  Result := Length(FMessages);
end;

function TChatHistory.GetMessages(): TArray<TChatMessage>;
var
  I: Integer;
  ChatMessage: TChatMessage;
begin
  Result := [];

  for I := 0 to Length(FMessages) - 1 do
  begin
    ChatMessage.Role := FMessages[I].Role;
    ChatMessage.Content := FMessages[I].Content;

    if (I = Length(FMessages) - 1) then
    begin
      if Length(FMessages[I].Images) > 0 then
        ChatMessage.Images := FMessages[I].Images;
    end;

    Result := Result + [ChatMessage];
  end;
end;

end.
