unit Version.MainForm;

interface

uses
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls,
  System.Classes;

type
  TMainForm = class(TForm)
    BottomPanel: TPanel;
    VersionMemo: TMemo;
    StatusBar: TStatusBar;
    GetVersionButton: TButton;
    procedure GetVersionButtonClick(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

uses
  Vcl.Dialogs,
  System.SysUtils,

  DecSoft.Ollama.Version.Types,
  DecSoft.Ollama.Version.Request;

{$R *.dfm}

procedure TMainForm.GetVersionButtonClick(Sender: TObject);
var
  VersionRequest: TVersionRequest;
begin
  VersionMemo.Clear();
  VersionRequest := TVersionRequest.Create();

  try

    try

      VersionRequest.Run(
       procedure (const Result: TVersionResponseResult)
       begin
         VersionMemo.Lines.Add(Result.Version);
       end);

    except
      on E: Exception do
      begin
        ShowMessageFmt('Exception: %s', [E.Message]);
      end;
    end;

  finally
    VersionRequest.Free();
  end;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.
