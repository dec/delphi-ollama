unit Chat.MainForm;

interface

uses
  Vcl.Forms,
  Vcl.StdCtrls,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  System.SysUtils,

  Chat.Thread;

type
  TMainForm = class(TForm)
    ModelEdit: TEdit;
    PromptMemo: TMemo;
    ModelLabel: TLabel;
    BottomPanel: TPanel;
    ResponseMemo: TMemo;
    PromptLabel: TLabel;
    ChatButton: TButton;
    CancelButton: TButton;
    StatusBar: TStatusBar;
    procedure ChatButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure ChatFinish(Sender: TObject);
    procedure ChatError(Sender: TObject; const Error: string);
    procedure ChatContent(Sender: TObject; const Content: string);
    procedure ChatException(Sender: TObject; const Exception: Exception);
  private
    FChatThread: TChatThread;
  end;

var
  MainForm: TMainForm;

implementation

uses
  Vcl.Dialogs;

{$R *.dfm}

procedure TMainForm.ChatButtonClick(Sender: TObject);
begin
  if Assigned(FChatThread) then
  begin
    FChatThread.Request.Stop();
    FChatThread.Terminate();
    FChatThread.WaitFor();
    FreeAndNil(FChatThread);
  end;

  ResponseMemo.Clear();
  ChatButton.Enabled := False;
  CancelButton.Enabled := True;

  FChatThread := TChatThread.Create(ModelEdit.Text, PromptMemo.Text);
  FChatThread.OnError := Self.ChatError;
  FChatThread.OnFinish := Self.ChatFinish;
  FChatThread.OnContent := Self.ChatContent;
  FChatThread.OnException := Self.ChatException;
end;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  if Assigned(FChatThread) then
  begin
    FChatThread.Request.Stop();
    FChatThread.Terminate();
    FChatThread.WaitFor();
    FreeAndNil(FChatThread);
  end;
  CancelButton.Enabled := False;
end;

procedure TMainForm.ChatError(Sender: TObject; const Error: string);
begin
  ChatButton.Enabled := True;
  CancelButton.Enabled := False;
  ResponseMemo.Text := Format('Error: %s', [Error]);  
end;

procedure TMainForm.ChatException(Sender: TObject; const Exception: Exception);
begin
  ChatButton.Enabled := True;
  CancelButton.Enabled := False;
  ResponseMemo.Text := Format('Exception: %s', [Exception.Message]);
end;

procedure TMainForm.ChatFinish(Sender: TObject);
begin
  ChatButton.Enabled := True;
  CancelButton.Enabled := False;
end;

procedure TMainForm.ChatContent(Sender: TObject; const Content: string);
begin
  ResponseMemo.Text := ResponseMemo.Text +
   StringReplace(Content, #10, #13#10, [rfReplaceAll]);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FChatThread) then
  begin
    FChatThread.Request.Stop();
    FChatThread.Terminate();
    FChatThread.WaitFor();
    FreeAndNil(FChatThread);
  end;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.
