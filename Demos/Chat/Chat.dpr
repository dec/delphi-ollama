program Chat;

uses
  Vcl.Forms,
  Chat.MainForm in 'Chat.MainForm.pas' {MainForm},
  DecSoft.Ollama.Chat.Request in '..\..\DecSoft.Ollama\DecSoft.Ollama.Chat.Request.pas',
  DecSoft.Ollama.Chat.Types in '..\..\DecSoft.Ollama\DecSoft.Ollama.Chat.Types.pas',
  DecSoft.Ollama.Constants in '..\..\DecSoft.Ollama\DecSoft.Ollama.Constants.pas',
  DecSoft.Ollama.Generation.Request in '..\..\DecSoft.Ollama\DecSoft.Ollama.Generation.Request.pas',
  DecSoft.Ollama.Generation.Types in '..\..\DecSoft.Ollama\DecSoft.Ollama.Generation.Types.pas',
  DecSoft.Ollama.Params.Constants in '..\..\DecSoft.Ollama\DecSoft.Ollama.Params.Constants.pas',
  DecSoft.Ollama.Params.Types in '..\..\DecSoft.Ollama\DecSoft.Ollama.Params.Types.pas',
  DecSoft.Ollama.Request in '..\..\DecSoft.Ollama\DecSoft.Ollama.Request.pas',
  DecSoft.Ollama.Response.Types in '..\..\DecSoft.Ollama\DecSoft.Ollama.Response.Types.pas',
  DecSoft.Ollama.Base64.Utils in '..\..\DecSoft.Ollama\DecSoft.Ollama.Base64.Utils.pas',
  DecSoft.Ollama.Chat.Utils in '..\..\DecSoft.Ollama\DecSoft.Ollama.Chat.Utils.pas',
  DecSoft.Ollama.UTF8.Utils in '..\..\DecSoft.Ollama\DecSoft.Ollama.UTF8.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
