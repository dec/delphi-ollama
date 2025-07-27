unit Chat.MainForm;

interface

uses
  Vcl.Forms,
  Vcl.StdCtrls,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,

  DecSoft.Ollama.Chat.Types,
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
    FFirstRun: Boolean;
    FRequest: TChatRequest;
    FHistory: TChatHistory;
  end;

var
  MainForm: TMainForm;

implementation

uses
  Vcl.Dialogs,
  System.SysUtils,

  DecSoft.Ollama.Chat.Utils;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FFirstRun := True;
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

  if FFirstRun then
    ResponseMemo.Clear();

  FFirstRun := False;

  ResponseMemo.Lines.Add('');
  ResponseMemo.Lines.Add(Format('User: %s', [PromptMemo.Text]));
  ResponseMemo.Lines.Add('');
  ResponseMemo.Lines.Add('Assistant: ');

  CancelButton.Enabled := True;
  ChatButton.Enabled := False;
  Screen.Cursor := crHourGlass;

  try
    try

      FRequest.Run(

        procedure (var Params: TChatParams)
        var
          Message: TChatMessage;
          FromHistory, ToHistory: TResponseMessage;
        begin
          Params.Model := ModelEdit.Text;
          Params.Stream := StreamedCheckBox.Checked;

          for FromHistory in FHistory do
          begin
            Message.Role := StringToMessageRole(FromHistory.Role);
            Message.Content := FromHistory.Content;
            Params.AppendMessage(Message);
          end;

          Message.Role := cmUser;
          Message.Content := PromptMemo.Text;
          Params.AppendMessage(Message);

          ToHistory.Role := MessageRoleToString(Message.Role);
          ToHistory.Content := Message.Content;
          FHistory := FHistory + [ToHistory];

          PromptMemo.Clear();
        end,

        procedure (const Result: TChatResponseResult; var Stop: Boolean)
        begin
          Application.ProcessMessages();

          if Result.Done then
            FHistory := FHistory + [Result.Message];

          ResponseMemo.Text := Trim(ResponseMemo.Text) +' '+ Result.Message.Content;
        end,

        procedure (const Error: string)
        begin
          ResponseMemo.Text := Format('Error: %s', [Error]);
        end);

    except

      on E: Exception do
      begin
        ResponseMemo.Text := Format('Exception: %s', [E.Message]);
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
