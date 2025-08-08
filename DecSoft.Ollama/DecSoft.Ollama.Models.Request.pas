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

unit DecSoft.Ollama.Models.Request;

interface

uses
  System.JSON,
  System.Classes,

  DecSoft.Ollama.Request,
  DecSoft.Ollama.Models.Types;

type
  TModelsRequest = class (TOllamaRequest)
  public
    procedure Run(ModelsResponseProc: TModelsResponseProc);
  end;

implementation

uses
  System.SysUtils,

  DecSoft.Ollama.Strings;

{ TModelsRequest }

procedure TModelsRequest.Run(ModelsResponseProc: TModelsResponseProc);
var
  Model: TModel;
  ModelJSON: TJSONValue;
  ModelsArray: TJSONArray;
  ResponseJSON: TJSONValue;
  ResponseContent: TStringStream;
  ResponseResult: TModelsResponseResult;
begin
  ResponseContent := TStringStream.Create();
  try
    Self.Get(Format('%stags', [FApiUrl]), ResponseContent);

    ResponseJSON := TJSONObject.ParseJSONValue(ResponseContent.DataString);

    try

      if not Assigned(ResponseJSON) then
      begin
        raise Exception.CreateFmt(FormatUnexpectedResponse,
         [ResponseContent.DataString]);
      end;

      ModelsArray := ResponseJSON.GetValue<TJSONArray>('models');

      for ModelJSON in ModelsArray do
      begin
        Model.Name := ModelJSON.GetValue<string>('name');
        Model.Model := ModelJSON.GetValue<string>('model');

        ResponseResult.Models := ResponseResult.Models + [Model];
      end;

      if Assigned(ModelsResponseProc) then
        ModelsResponseProc(ResponseResult);

    finally
      ResponseJSON.Free();
    end;

  finally
    ResponseContent.Free();
  end;
end;

end.
