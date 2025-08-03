unit Chat.MainForm;

interface

uses
  Vcl.Forms,
  Vcl.StdCtrls,
  System.Classes,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,

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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChatButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FRequest: TChatRequest;
  private
    function GetChatTools(): TArray<TChatTool>;
    function GetCurrentWeatherChatTool(): TChatTool;
    function GetCurrentWeather(const Location, TempFormat: string): string;
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

  ParamProp2.Name := 'TempFormat';
  ParamProp2.IsRequired := True;
  ParamProp2.Description := 'The format to return the weather in, e.g. "celsius" or "fahrenheit"';

  ToolParam.Properties := [ParamProp1, ParamProp2];

  Result.Parameters := [ToolParam];
end;

function TMainForm.GetChatTools: TArray<TChatTool>;
begin
  Result := [Self.GetCurrentWeatherChatTool()];
end;

procedure TMainForm.ChatButtonClick(Sender: TObject);
begin

  ResponseMemo.Lines.Add('');
  ResponseMemo.Lines.Add(Format('User: %s', [PromptMemo.Text]));
  ResponseMemo.Lines.Add('');
  ResponseMemo.Lines.Add('Assistant:');
  ResponseMemo.Text := Trim(ResponseMemo.Text);

  ChatButton.Enabled := False;
  Screen.Cursor := crHourGlass;

  try
    try

      FRequest.Run(

        procedure (var Params: TChatParams)
        var
          ChatMessage: TChatMessage;
        begin
          Params.Stream := False;
          Params.Model := ModelEdit.Text;

          Params.Tools := Self.GetChatTools();

          ChatMessage.Role := cmUser;
          ChatMessage.Content := PromptMemo.Text;
          PromptMemo.Clear();

          Params.AppendMessage(ChatMessage);
        end,

        procedure (const Result: TChatResponseResult; var Stop: Boolean)
        var
          ResponseToolCall: TResponseToolCall;
        begin
          Application.ProcessMessages();

          if Result.Done then
          begin
            if Length(Result.ToolCalls) > 0 then
            begin
              for ResponseToolCall in Result.ToolCalls do
              begin
                if ResponseToolCall.Name = 'GetCurrentWeather' then
                begin

                  ResponseMemo.Text := ResponseMemo.Text + Self.GetCurrentWeather(
                   ResponseToolCall.Arguments[0].Value,
                   ResponseToolCall.Arguments[1].Value);
                end;
              end;
            end
            else
            begin
              ResponseMemo.Text := ResponseMemo.Text + Result.Message.Content;
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
  end;
end;

function TMainForm.GetCurrentWeather(const Location, TempFormat: string): string;
begin
  Result := Format(
   'The user ask for the weather in location: "%s" and temp format: "%s"',
    [Location, TempFormat]);
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.
