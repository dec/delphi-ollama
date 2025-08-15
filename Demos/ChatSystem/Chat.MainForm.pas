unit Chat.MainForm;

interface

uses
  Vcl.Forms,
  Vcl.StdCtrls,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,

  DecSoft.Ollama.Chat.Request;

type
  TMainForm = class(TForm)
    ModelEdit: TEdit;
    PromptMemo: TMemo;
    ModelLabel: TLabel;
    BottomPanel: TPanel;
    ResponseMemo: TMemo;
    PromptLabel: TLabel;
    CancelButton: TButton;
    StatusBar: TStatusBar;
    ChatButton: TButton;
    StreamedCheckBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure ChatButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FRequest: TChatRequest;
  end;

var
  MainForm: TMainForm;

implementation

uses
  Vcl.Dialogs,
  System.SysUtils,

  DecSoft.Ollama.Chat.Types;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FRequest := TChatRequest.Create();
end;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  FRequest.Stop();
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FRequest.IsRunning then
    FRequest.Stop();
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FRequest.Free();
end;

procedure TMainForm.ChatButtonClick(Sender: TObject);
begin

  ResponseMemo.Lines.Add('');
  ResponseMemo.Lines.Add(Format('User: %s', [PromptMemo.Text]));
  ResponseMemo.Lines.Add('');
  ResponseMemo.Lines.Add('Ralph the magician:');
  ResponseMemo.Text := Trim(ResponseMemo.Text);

  CancelButton.Enabled := True;
  ChatButton.Enabled := False;
  Screen.Cursor := crHourGlass;

  try
    try

      FRequest.Run(

        procedure (var Params: TChatParams)
        var
          ChatMessage: TChatMessage;
        begin
          Params.Model := ModelEdit.Text;
          Params.Stream := StreamedCheckBox.Checked;

          ChatMessage.Role := cmrSystem;
          ChatMessage.Content := 'You are a fantastic magician who wants to amaze whoever listens to you.';
          Params.AppendMessage(ChatMessage);

          ChatMessage.Role := cmrUser;
          ChatMessage.Content := PromptMemo.Text;
          PromptMemo.Clear();

          Params.AppendMessage(ChatMessage);
        end,

        procedure (const Result: TChatResponseResult; var Stop: Boolean)
        begin
          Application.ProcessMessages();

          if Result.Streamed and not Result.Done then
            ResponseMemo.Text := ResponseMemo.Text +
             StringReplace(Result.Message.Content, #10, #13#10, [rfReplaceAll]);

          if not Result.Streamed and Result.Done then
            ResponseMemo.Text := ResponseMemo.Text +
             StringReplace(Result.Message.Content, #10, #13#10, [rfReplaceAll]);
        end,

        procedure (const Error: string)
        begin
          ShowMessage(Format('Error: %s', [Error]));
        end);

    except

      on E: Exception do
      begin
        ShowMessage(Format('Exception: %s', [E.Message]));
      end;
    end;

  finally

    Screen.Cursor := crDefault;
    ChatButton.Enabled := True;
    CancelButton.Enabled := False;
  end;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.
