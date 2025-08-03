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

unit DecSoft.Ollama.Generation.Types;

interface

uses
  System.JSON,
  System.SysUtils,

  DecSoft.Ollama.Params.Types,
  DecSoft.Ollama.Response.Types;

type

  TGenerationResponseResult = record
  public
    Model: string;
    Done: Boolean;
    Response: string;
    CreatedAt: string;
    TotalDuration: Int64;
    LoadDuration: Int64;
    Context: TArray<Int64>;
    PromptEvalCount: Int64;
    PromptEvalDuration: Int64;
    EvalCount: Int64;
    EvalDuration: Int64;
    DoneReason: string;
    Streamed: Boolean;
    AsJSON: TJSONValue;
  end;

  TGenerationResponseProc = reference to
   procedure (const Result: TGenerationResponseResult; var Stop: Boolean);

  TGenerationParams = record
  public
    Model: string;
    Prompt: string;
    Suffix: string;
    Stream: Boolean;
    KeepAlive: string;
    Options: TOptionsParam;
    Images: TArray<TFileName>;
    Format: TResponseFormat;
    Context: TArray<Int64>;
  private
    function ToJSON(): TJSONObject;
  public
    procedure ClearImages();
    function ToString(): string;
    function ResponseFormatToString() : string;
    procedure AddImage(const FileName: TFileName);
  end;

  TGenerationParamsProc = reference to
   procedure (var Params: TGenerationParams);

implementation

uses
  DecSoft.Ollama.Strings,
  DecSoft.Ollama.Base64.Utils;

{ TGenerationParams }

procedure TGenerationParams.AddImage(const FileName: TFileName);
begin
  if FileExists(FileName) then
    Self.Images := Self.Images + [FileName]
  else
    raise Exception.CreateFmt(FormatMissingFileName, [FileName]);
end;

procedure TGenerationParams.ClearImages();
begin
  Self.Images := [];
end;

function TGenerationParams.ResponseFormatToString(): string;
begin
  case Self.Format of
    crfText: Result := '';
    crfJSON: Result := 'json';
  else
    Result := '';
  end;

end;

function TGenerationParams.ToJSON(): TJSONObject;
var
  StopSequence: string;
  FileName: TFileName;
  Options: TJSONObject;
  ContextNum: Int64;
  ContextArray: TJSONArray;
  ImagesJSON, StopSequences: TJSONArray;
begin

  Result := TJSONObject.Create();
  Result.AddPair(TJSONPair.Create('model', Self.Model));
  Result.AddPair(TJSONPair.Create('prompt', Self.Prompt));
  Result.AddPair(TJSONPair.Create('suffix', Self.Suffix));
  Result.AddPair(TJSONPair.Create('format', Self.ResponseFormatToString()));
  Result.AddPair(TJSONPair.Create('stream', TJSONBool.Create(Self.Stream)));

  ContextArray := TJSONArray.Create();
  for ContextNum in Self.Context do
    ContextArray.Add(ContextNum);

  Result.AddPair(TJSONPair.Create('context', ContextArray));

  if Self.KeepAlive <> '' then
    Result.AddPair(TJSONPair.Create('keep_alive', Self.KeepAlive));

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

  Result.AddPair('options', Options);

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
        raise Exception.CreateFmt(FormatMissingFileName, [FileName]);
      end;
    end;
    if ImagesJSON.Count > 0 then
    begin
      Result.AddPair('images', ImagesJSON);
    end;
  end;
end;

function TGenerationParams.ToString(): string;
var
  CompletionMessageJSON: TJSONObject;
begin
  CompletionMessageJSON := Self.ToJSON();
  try
    Result := CompletionMessageJSON.ToString();
  finally
    CompletionMessageJSON.Free();
  end;
end;

end.

