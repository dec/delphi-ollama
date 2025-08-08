unit Generation.MainForm;

interface

uses
  Vcl.Forms,
  Vcl.StdCtrls,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,

  DecSoft.Ollama.Generation.Request;

type
  TMainForm = class(TForm)
    ModelEdit: TEdit;
    PromptMemo: TMemo;
    ModelLabel: TLabel;
    BottomPanel: TPanel;
    PromptLabel: TLabel;
    CancelButton: TButton;
    StatusBar: TStatusBar;
    GenerateButton: TButton;
    ThinkCheckBox: TCheckBox;
    StreamedCheckBox: TCheckBox;
    ThinkMemo: TMemo;
    ResponseMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure GenerateButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FRequest: TGenerationRequest;
  end;

var
  MainForm: TMainForm;

implementation

uses
  Vcl.Dialogs,
  System.SysUtils,

  DecSoft.Ollama.Generation.Types;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FRequest := TGenerationRequest.Create();
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

procedure TMainForm.GenerateButtonClick(Sender: TObject);
begin
  ThinkMemo.Clear();
  ResponseMemo.Clear();

  CancelButton.Enabled := True;
  GenerateButton.Enabled := False;
  Screen.Cursor := crHourGlass;

  try
    try

      FRequest.Run(

        procedure (var Params: TGenerationParams)
        begin
          Params.Model := ModelEdit.Text;
          Params.Prompt := PromptMemo.Text;
          Params.Think := ThinkCheckBox.Checked;
          Params.Stream := StreamedCheckBox.Checked;
        end,

        procedure (const Result: TGenerationResponseResult; var Stop: Boolean)
        begin
          Application.ProcessMessages();

          if Result.Streamed and not Result.Done then
          begin
            ThinkMemo.Text := ThinkMemo.Text + Result.Thinking;
            ResponseMemo.Text := ResponseMemo.Text + Result.Response;
          end;

          if not Result.Streamed and Result.Done then
          begin
            ThinkMemo.Text := ThinkMemo.Text + Result.Thinking;
            ResponseMemo.Text := ResponseMemo.Text + Result.Response;
          end;
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
    GenerateButton.Enabled := True;
    CancelButton.Enabled := False;
  end;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.
