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

unit DecSoft.Ollama.Chat.Tools;

interface

uses
  System.JSON;

type

  TChatToolParameterProperty = record
  public
    Name: string;
    Description: string;
    IsRequired: Boolean;
  end;

  TChatToolParameter = record
  public
    Properties: TArray<TChatToolParameterProperty>;
  end;

  TChatTool = record
  public
    Name: string;
    Description: string;
    Parameters: TArray<TChatToolParameter>;
  public
    function ToJSON(): TJSONObject;
  end;

implementation

{ TChatTool }

function TChatTool.ToJSON(): TJSONObject;
var
  Required: TJSONArray;
  ToolParam: TChatToolParameter;
  ParamProp: TChatToolParameterProperty;
  Func, Params, Prop, Props: TJSONObject;
begin
  Result := TJSONObject.Create();
  Func := TJSONObject.Create();
  Params := TJSONObject.Create();
  Props := TJSONObject.Create();
  Required := TJSONArray.Create();

  Func.AddPair('name', Self.Name);
  Func.AddPair('description', Self.Description);

  Params.AddPair('type', 'object');

  for ToolParam in Self.Parameters do
  begin
    for ParamProp in ToolParam.Properties do
    begin

      Prop := TJSONObject.Create();

      Prop.AddPair('type', 'string');
      Prop.AddPair('description', ParamProp.Description);

      Props.AddPair(ParamProp.Name, Prop);

      if ParamProp.IsRequired then
        Required.AddElement(TJSONString.Create(ParamProp.Name));
    end;
  end;

  Params.AddPair('properties', Props);
  Params.AddPair('required', Required);

  Func.AddPair('parameters', Params);

  Result.AddPair('type', 'function');
  Result.AddPair('function', Func);
end;

end.
