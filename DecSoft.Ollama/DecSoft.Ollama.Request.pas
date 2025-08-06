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

unit DecSoft.Ollama.Request;

interface

uses
  System.JSON,
  System.Classes,
  System.SysUtils,
  System.Net.URLClient,
  System.Net.HttpClient,

  DecSoft.Ollama.Constants,
  DecSoft.Ollama.Response.Types;

type
  TOllamaRequest = class abstract (TObject)
  private
    FSendTimeout: Integer;
    FConnectionTimeout: Integer;
    FResponseTimeout: Integer;
  protected
    FApiUrl: string;
    FStopped: Boolean;
    FStreamed: Boolean;
    FIsRunning: Boolean;
    FCustomHeaders: TNetHeaders;
    FPartialResponse: TStringStream;
    FCompleteResponse: TStringStream;
    FResponseErrorProc: TResponseErrorProc;
  protected
    procedure Get(const ApiMethodUrl: string; Response: TStringStream);
    procedure Post(const ApiMethodUrl: string; const JSONRequest:
     TStringStream; ReceiveDataEvent: TReceiveDataEvent);
  public
    constructor Create(const ApiUrl: string = OllamaDefaultApiUrl;
     const CustomHeaders: TNetHeaders = nil);
    destructor Destroy(); override;
  public
    property IsRunning: Boolean read FIsRunning;
    property SendTimeout: Integer read FSendTimeout write FSendTimeout;
    property ConnectionTimeout: Integer
     read FConnectionTimeout write FConnectionTimeout;
    property ResponseTimeout: Integer
     read FResponseTimeout write FResponseTimeout;
  public
    procedure Stop();
  public
    property Stopped: Boolean read FStopped;
    property ApiUrl: string read FApiUrl write FApiUrl;
  end;

implementation

uses
  DecSoft.Ollama.UTF8.Utils,
  DecSoft.Ollama.Chat.Request,
  DecSoft.Ollama.Generation.Request;

{ TOllamaRequest }

constructor TOllamaRequest.Create(const ApiUrl: string = OllamaDefaultApiUrl;
 const CustomHeaders: TNetHeaders = nil);
begin
  inherited Create();
  FApiUrl := ApiUrl;
  FStopped := False;
  FStreamed := True;
  FIsRunning := False;
  FSendTimeout := 5;
  FResponseTimeout := 300;
  FConnectionTimeout := 5;
  FCustomHeaders := CustomHeaders;

  FPartialResponse := TStringStream.Create('', TUTF8NotBoundEncoding.Create());
  FCompleteResponse := TStringStream.Create('', TUTF8NotBoundEncoding.Create());
end;

destructor TOllamaRequest.Destroy();
begin
  FPartialResponse.Free();
  FCompleteResponse.Free();
  inherited Destroy();
end;

procedure TOllamaRequest.Get(const ApiMethodUrl: string;
  Response: TStringStream);
var
  HttpClient: THttpClient;
begin
  HttpClient := THTTPClient.Create();
  try
    HttpClient.Get(ApiMethodUrl, Response, FCustomHeaders);
  finally
    HttpClient.Free();
  end;
end;

procedure TOllamaRequest.Stop();
begin
  FStopped := True;
end;

procedure TOllamaRequest.Post(const ApiMethodUrl: string; const
 JSONRequest: TStringStream; ReceiveDataEvent: TReceiveDataEvent);
var
  ErrorMsg: string;
  ErrorJSON: TJSONValue;
  HttpClient: THttpClient;
  JSONRequestValue: TJSONValue;
begin

  FStopped := False;
  FIsRunning := True;
  FPartialResponse.Clear();
  HttpClient := THTTPClient.Create();

  HttpClient.SendTimeout := FSendTimeout * 1000;
  HttpClient.ResponseTimeout := FResponseTimeout * 1000;
  HttpClient.ConnectionTimeout := FConnectionTimeout * 1000;

  JSONRequestValue := TJSONObject.ParseJSONValue(JSONRequest.DataString);
  FStreamed := JSONRequestValue.GetValue<Boolean>('stream');

  HttpClient.OnReceiveData := ReceiveDataEvent;

  try

    HttpClient.Post(ApiMethodUrl, JSONRequest,
     FPartialResponse, FCustomHeaders);

    if (FPartialResponse.DataString <> '') and not FStopped then
    begin
      ErrorJSON := TJSONObject.ParseJSONValue(FPartialResponse.DataString);
      try
        if ErrorJSON.TryGetValue('error', ErrorMsg) then
        begin
          if Assigned(FResponseErrorProc) then
            FResponseErrorProc(ErrorJSON.GetValue<string>('error'));
        end;
      finally
        ErrorJSON.Free();
      end;
    end;

  finally
    FIsRunning := False;
    JSONRequestValue.Free();
    HttpClient.Free();
  end;
end;

end.
