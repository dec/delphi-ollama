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

unit DecSoft.Ollama.Chat.Utils;

interface

uses
  DecSoft.Ollama.Chat.Types;

function MessageRoleToString(const Role: TChatMessageRole): string;
function StringToMessageRole(const Role: string): TChatMessageRole;

implementation

uses
  System.SysUtils,

  DecSoft.Ollama.Strings;

function MessageRoleToString(const Role: TChatMessageRole): string;
begin
  case Role of
    cmrTool: Result := 'tool';
    cmrUser: Result := 'user';
    cmrSystem: Result := 'system';
    cmrAssistant: Result := 'assistant';
  else
    raise Exception.Create(UnknowChatMessageRole);
  end;
end;

function StringToMessageRole(const Role: string): TChatMessageRole;
begin
  if (Role = 'tool') then
    Result := cmrTool
  else if (Role = 'user') then
    Result := cmrUser
  else if (Role = 'system') then
    Result := cmrSystem
  else if (Role = 'assistant') then
    Result := cmrAssistant
  else
    raise Exception.CreateFmt(FormatUnknowChatMessageRole, [Role])
end;

end.
