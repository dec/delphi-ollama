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

{ Special thanks to @HemulGM (https://github.com/HemulGM) for this unit! }

(*
 MIT License

 Copyright (c) 2023 HemulGM

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

unit DecSoft.Ollama.Base64.Utils;

interface

uses
  System.Classes,
  System.Net.Mime,
  System.SysUtils,
  System.NetEncoding;

type
  TBase64Data = record
  public
    ContentType: string;
    Data: string;
  public
    function ToString(): string;
  end;

function FileToBase64(const FileName: TFileName): TBase64Data;

function StreamToBase64(Stream: TStream;
 const ContentType: string): TBase64Data;

function GetFileContentType(const FileName: TFileName): string;

implementation

function GetFileContentType(const FileName: TFileName): string;
var
  LKind: TMimeTypes.TKind;
begin
  TMimeTypes.Default.GetFileInfo(FileName, Result, LKind);
end;

function FileToBase64(const FileName: TFileName): TBase64Data;
var
  FS: TFileStream;
  Base64: TStringStream;
begin
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    Base64 := TStringStream.Create('', TEncoding.UTF8);
    try
      {$IF RTLVersion >= 35.0}
      TNetEncoding.Base64String.Encode(FS, Base64);
      {$ELSE}
      TNetEncoding.Base64.Encode(FS, Base64);
      {$ENDIF}
      Result.Data := Base64.DataString;
      Result.ContentType := GetFileContentType(FileName);
    finally
      Base64.Free;
    end;
  finally
    FS.Free;
  end;
end;

function StreamToBase64(Stream: TStream;
 const ContentType: string): TBase64Data;
var
  Base64: TStringStream;
begin
  Base64 := TStringStream.Create('', TEncoding.UTF8);
  try
    {$IF RTLVersion >= 35.0}
    TNetEncoding.Base64String.Encode(Stream, Base64);
    {$ELSE}
    TNetEncoding.Base64.Encode(Stream, Base64);
    {$ENDIF}
    Result.Data := Base64.DataString;
    Result.ContentType := ContentType;
  finally
    Base64.Free;
  end;
end;

{ TBase64Data }

function TBase64Data.ToString: string;
begin
  Result := Data;

  //Format('data:%s;base64,%s', [ContentType, Data]).Replace(#13#10, '');
end;

end.

