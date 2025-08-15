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
  DecSoft.Ollama.Chat.Tools,
  DecSoft.Ollama.Chat.Request;

type
  TMainForm = class(TForm)
    ModelEdit: TEdit;
    PromptMemo: TMemo;
    ModelLabel: TLabel;
    BottomPanel: TPanel;
    ResponseMemo: TMemo;
    PromptLabel: TLabel;
    StatusBar: TStatusBar;
    ChatButton: TButton;
    StreamedCheckBox: TCheckBox;
    CancelButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChatButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CancelButtonClick(Sender: TObject);
  private
    FRequest: TChatRequest;
  private
    function GetChatTools(): TArray<TChatTool>;
    function GetCurrentWeatherChatTool(): TChatTool;
    function GetCurrentWeather(const Location, TempDegree: string): string;
  private
    procedure MakeRequest(const ChatMessage: TChatMessage);
  end;

var
  MainForm: TMainForm;

implementation

uses
  Vcl.Dialogs,
  System.SysUtils;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FRequest := TChatRequest.Create();
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

function TMainForm.GetCurrentWeatherChatTool(): TChatTool;
var
  ToolParam: TChatToolParameter;
  ParamProp1, ParamProp2: TChatToolParameterProperty;
begin
  Result.Name := 'GetCurrentWeather';
  Result.Description := 'Get the current weather for a location';

  ParamProp1.Name := 'Location';
  ParamProp1.IsRequired := True;
  ParamProp1.Description := 'The location to get the weather for, e.g. Madrid, Spain';

  ParamProp2.Name := 'TempDegree';
  ParamProp2.IsRequired := True;
  ParamProp2.Description := 'The format to return the weather in, e.g. "celsius" or "fahrenheit"';
  ParamProp2.Enum := ['celsius', 'fahrenheit'];

  ToolParam.Properties := [ParamProp1, ParamProp2];

  Result.Parameters := [ToolParam];
end;

procedure TMainForm.MakeRequest(const ChatMessage: TChatMessage);
begin

  CancelButton.Enabled := True;
  ChatButton.Enabled := False;
  Screen.Cursor := crHourGlass;

  try
    try

      FRequest.Run(

        procedure (var Params: TChatParams)
        begin
          Params.Model := ModelEdit.Text;
          Params.Tools := Self.GetChatTools();
          Params.Stream := StreamedCheckBox.Checked;

          PromptMemo.Clear();

          Params.AppendMessage(ChatMessage);
        end,

        procedure (const Result: TChatResponseResult; var Stop: Boolean)
        var
          ResponseToolCall: TResponseToolCall;
        begin
          Application.ProcessMessages();

          if Result.Streamed and not Result.Done then
            ResponseMemo.Text := ResponseMemo.Text +
             StringReplace(Result.Message.Content, #10, #13#10, [rfReplaceAll]);

          if not Result.Streamed and Result.Done then
            ResponseMemo.Text := ResponseMemo.Text +
             StringReplace(Result.Message.Content, #10, #13#10, [rfReplaceAll]);

          if Length(Result.ToolCalls) > 0 then
          begin
            for ResponseToolCall in Result.ToolCalls do
            begin
              if ResponseToolCall.Name = 'GetCurrentWeather' then
              begin
                Self.GetCurrentWeather(
                 ResponseToolCall.Arguments[0].Value,
                 ResponseToolCall.Arguments[1].Value);
              end;
            end;
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
    ChatButton.Enabled := True;
    CancelButton.Enabled := False;
  end;
end;

function TMainForm.GetChatTools: TArray<TChatTool>;
begin
  Result := [Self.GetCurrentWeatherChatTool()];
end;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  FRequest.Stop();
end;

procedure TMainForm.ChatButtonClick(Sender: TObject);
var
  ChatMessage: TChatMessage;
begin
  ResponseMemo.Lines.Add('');
  ResponseMemo.Lines.Add(Format('User: %s', [PromptMemo.Text]));
  ResponseMemo.Lines.Add('');
  ResponseMemo.Lines.Add('Assistant:');
  ResponseMemo.Text := Trim(ResponseMemo.Text);

  ChatMessage.Role := cmrUser;
  ChatMessage.Content := PromptMemo.Text;
  Self.MakeRequest(ChatMessage);
end;

function TMainForm.GetCurrentWeather(const Location, TempDegree: string): string;
var
  ChatMessage: TChatMessage;
begin
  ChatMessage.Role := cmrTool;
  ChatMessage.ToolName := 'GetCurrentWeather';
  ChatMessage.Content := Format('Location: %s - Temperature: 30º %s - Precipitation: 10%', [Location, TempDegree]);
  Self.MakeRequest(ChatMessage);
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.
