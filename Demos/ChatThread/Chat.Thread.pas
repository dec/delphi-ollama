unit Chat.Thread;

interface

uses
  System.Classes,
  System.SysUtils,

  DecSoft.Ollama.Chat.Types,
  DecSoft.Ollama.Chat.Request;

type
  TChatFinishEvent = TNotifyEvent;
  TChatErrorEvent = procedure (Sender: TObject; const Error: string) of object;
  TChatContentEvent = procedure (Sender: TObject; const Content: string) of object;
  TChatExceptionEvent = procedure (Sender: TObject; const Exception: Exception) of object;

  TChatThread = class(TThread)
  private
    FError: string;
    FResponse: string;
    FException: Exception;
    FRequest: TChatRequest;
    FChatParams: TChatParams;
  private
    FOnError: TChatErrorEvent;
    FOnFinish: TChatFinishEvent;
    FOnContent: TChatContentEvent;
    FOnException: TChatExceptionEvent;
  private
    procedure NotifyError();
    procedure NotifyFinish();
    procedure NotifyContent();
    procedure NotifyException();
  public
    constructor Create(const ChatParams: TChatParams);
    destructor Destroy(); override;
  public
    procedure Execute(); override;
  public
    property Request: TChatRequest read FRequest;
  public
    property OnError: TChatErrorEvent read FOnError write FOnError;
    property OnFinish: TChatFinishEvent read FOnFinish write FOnFinish;
    property OnContent: TChatContentEvent read FOnContent write FOnContent;
    property OnException: TChatExceptionEvent read FOnException write FOnException;
  end;

implementation

{ TChatThread }

constructor TChatThread.Create(const ChatParams: TChatParams);
begin
  inherited Create(False);

  FError := EmptyStr;
  FResponse := EmptyStr;
  FChatParams := ChatParams;
  FRequest := TChatRequest.Create();
end;

destructor TChatThread.Destroy();
begin
  if FRequest.IsRunning then
    FRequest.Stop();

  FRequest.Free();
  inherited Destroy();
end;

procedure TChatThread.Execute();
begin
  try
    FRequest.Run(

      procedure (var Params: TChatParams)
      begin
        Params := FChatParams;
      end,

      procedure (const Result: TChatResponseResult; var Stop: Boolean)
      begin
        if not Self.Terminated then
        begin
          if Result.Streamed and not Result.Done then
          begin
            FResponse := Result.Message.Content;
            Synchronize(Self.NotifyContent);
          end;

          if not Result.Streamed and Result.Done then
          begin
            FResponse := Result.Message.Content;
            Synchronize(Self.NotifyContent);
          end;

          if Result.Done then
          begin
            Synchronize(Self.NotifyFinish);
            Self.Terminate();
          end;
        end
        else
        begin
         Synchronize(Self.NotifyFinish);
        end;
      end,

      procedure (const Error: string)
      begin
        FError := Error;
        Synchronize(Self.NotifyError);
      end);

  except
    on E: Exception do
    begin
      FException := E;
      Synchronize(Self.NotifyException);
    end;
  end;
end;

procedure TChatThread.NotifyError();
begin
  if Assigned(FOnError) then
    FOnError(Self, FError);
end;

procedure TChatThread.NotifyException();
begin
  if Assigned(FOnException) then
    FOnException(Self, FException);
end;

procedure TChatThread.NotifyFinish();
begin
  if Assigned(FOnFinish) then
    FOnFinish(Self);
end;

procedure TChatThread.NotifyContent();
begin
  if Assigned(FOnContent) then
    FOnContent(Self, FResponse);
end;

end.
