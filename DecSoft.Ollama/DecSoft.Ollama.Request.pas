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
    FPartialResponseTimeout: Integer;
  protected
    FApiUrl: string;
    FStopped: Boolean;
    FStreamed: Boolean;
    FIsRunning: Boolean;
    FHttpClient: THTTPClient;
    FPartialResponse: TStringStream;
    FCompleteResponse: TStringStream;
    FErrorResponseProc: TErrorResponseProc;
  protected
    procedure Post(const ApiMethodUrl: string; const JSONRequest:
     TStringStream; ReceiveDataEvent: TReceiveDataEvent);
  public
    constructor Create(const ApiUrl: string = OllamaDefaultApiUrl);
    destructor Destroy(); override;
  public
    property IsRunning: Boolean read FIsRunning;
    property SendTimeout: Integer read FSendTimeout write FSendTimeout;
    property ConnectionTimeout: Integer
     read FConnectionTimeout write FConnectionTimeout;
    property ResponseTimeout: Integer
     read FPartialResponseTimeout write FPartialResponseTimeout;
  public
    procedure Stop();
  public
    property Stopped: Boolean read FStopped;
    property ApiUrl: string read FApiUrl write FApiUrl;
  end;

implementation

uses
  DIALOGS,

  DecSoft.Ollama.UTF8.Utils,
  DecSoft.Ollama.Chat.Request,
  DecSoft.Ollama.Generation.Request;

{ TOllamaRequest }

constructor TOllamaRequest.Create(const ApiUrl: string = OllamaDefaultApiUrl);
begin
  inherited Create();
  FApiUrl := ApiUrl;
  FStopped := False;
  FStreamed := True;
  FIsRunning := False;
  FSendTimeout := 5;
  FPartialResponseTimeout := 300;
  FConnectionTimeout := 5;

  FHttpClient := THTTPClient.Create();
  FPartialResponse := TStringStream.Create('', TUTF8NotBoundEncoding.Create());
  FCompleteResponse := TStringStream.Create('', TUTF8NotBoundEncoding.Create());
end;

destructor TOllamaRequest.Destroy();
begin
  FHttpClient.Free();
  FPartialResponse.Free();
  FCompleteResponse.Free();
  inherited Destroy();
end;

procedure TOllamaRequest.Stop();
begin
  FStopped := True;
end;

procedure TOllamaRequest.Post(const ApiMethodUrl: string; const
 JSONRequest: TStringStream; ReceiveDataEvent: TReceiveDataEvent);
var
  ErrorMsg: string;
  Headers: TNetHeaders;
  ErrorJSON: TJSONValue;
  HttpClient: THttpClient;
  JSONRequestValue: TJSONValue;
begin

  FStopped := False;
  FIsRunning := True;
  FPartialResponse.Clear();
  HttpClient := THTTPClient.Create();
  Headers := [TNetHeader.Create('Content-Type', 'application/json')];

  HttpClient.SendTimeout := FSendTimeout * 1000;
  HttpClient.ResponseTimeout := FPartialResponseTimeout * 1000;
  HttpClient.ConnectionTimeout := FConnectionTimeout * 1000;

  JSONRequestValue := TJSONObject.ParseJSONValue(JSONRequest.DataString);
  FStreamed := JSONRequestValue.GetValue<Boolean>('stream');

  HttpClient.OnReceiveData := ReceiveDataEvent;

  try

    HttpClient.Post(ApiMethodUrl, JSONRequest, FPartialResponse, Headers);

    try

      if (FPartialResponse.DataString <> '') and not FStopped then
      begin
        ErrorJSON := TJSONObject.ParseJSONValue(FPartialResponse.DataString);
        try
          if ErrorJSON.TryGetValue('error', ErrorMsg) then
          begin
            if Assigned(FErrorResponseProc) then
              FErrorResponseProc(ErrorJSON.GetValue<string>('error'));
          end;
        finally
          ErrorJSON.Free();
        end;
      end;

    except
      on E: Exception do
      begin
        if Assigned(FErrorResponseProc) then
          FErrorResponseProc(E.Message)
        else
          raise;
      end;
    end;

  finally
    FIsRunning := False;
    JSONRequestValue.Free();
    HttpClient.Free();
  end;
end;

end.
