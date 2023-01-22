program ChessEngine;



{$R *.dres}

uses
  Vcl.Forms,
  Main in 'source\Main.pas' {MainForm},
  ChessBoard in 'comps\ChessBoard.pas',
  ChessPieces in 'source\ChessPieces.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;

end.
