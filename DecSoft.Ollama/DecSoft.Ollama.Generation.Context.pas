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

unit DecSoft.Ollama.Generation.Context;

interface

type
  TArray<Int64> = array of Int64;

type
  TGenerationContext = class(TObject)
  private
    FAutoTrim: Boolean;
    FMaxContext: Int64;
    FContext: TArray<Int64>;
  public
    constructor Create(const AutoTrim: Boolean = True;
     const MaxContext: Int64 = 2000); reintroduce;
  public
    function GetContext(): TArray<Int64>;
    function AddContext(const Context: TArray<Int64>): Int64;
  public
    property AutoTrim: Boolean read FAutoTrim write FAutoTrim;
    property MaxContext: Int64 read FMaxContext write FMaxContext;
  end;

implementation

{ TGenerationContext }

constructor TGenerationContext.Create(const AutoTrim:
 Boolean = True; const MaxContext: Int64 = 2000);
begin
  inherited Create();
  FContext := [];
  FAutoTrim := AutoTrim;
  FMaxContext := MaxContext;
end;

function TGenerationContext.AddContext(const Context: TArray<Int64>): Int64;
begin
  FContext := FContext + Context;

  if FAutoTrim and (Length(FContext) > FMaxContext) then
  begin
    Delete(FContext, 0, FMaxContext div 2);
  end;

  Result := Length(FContext);
end;

function TGenerationContext.GetContext(): TArray<Int64>;
begin
  Result := FContext;
end;

end.
