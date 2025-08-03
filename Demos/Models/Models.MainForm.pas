unit Models.MainForm;

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
    ModelsMemo: TMemo;
    StatusBar: TStatusBar;
    GetModelsButton: TButton;
    procedure GetModelsButtonClick(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

uses
  Vcl.Dialogs,
  System.SysUtils,

  DecSoft.Ollama.Models.Request,
  DecSoft.Ollama.Generation.Types;

{$R *.dfm}

procedure TMainForm.GetModelsButtonClick(Sender: TObject);
var
  ModelsRequest: TModelsRequest;
begin
  ModelsMemo.Clear();
  ModelsRequest := TModelsRequest.Create();

  try

    try

      ModelsRequest.Run(
       procedure (const Result: TModelsResponseResult)
       var
         Model: TModel;
       begin
         if Length(Result.Models) = 0 then
         begin
           ModelsMemo.Text := 'No models found!';
         end
         else
         begin
           for Model in Result.Models do
             ModelsMemo.Lines.Add(Model.Name);
         end;
       end);

    except
      on E: Exception do
      begin
        ShowMessageFmt('Exception: %s', [E.Message]);
      end;
    end;

  finally
    ModelsRequest.Free();
  end;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;

end.
