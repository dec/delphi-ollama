unit DecSoft.Ollama.UTF8.Utils;

interface

uses
  // Delphi
  System.SysUtils;

type
  TUTF8NotBoundEncoding = class(TUTF8Encoding)
  public
   function GetPreamble: TBytes; override;
  end;

implementation

function TUTF8NotBoundEncoding.GetPreamble(): TBytes;
begin
  SetLength(Result, 0);
end;

end.
