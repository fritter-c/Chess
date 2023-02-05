program ChessEngine;



{$R *.dres}

uses
  Vcl.Forms,
  Main in 'source\Main.pas' {MainForm},
  ChessBoard in 'comps\ChessBoard.pas',
  SimpleClock in 'comps\SimpleClock.pas',
  ChessPieces in 'source\ChessPieces.pas',
  PromotionForm in 'source\PromotionForm.pas' {Promotion},
  ConfigureForm in 'source\ConfigureForm.pas' {FormConfigure},
  ChessGame in 'source\ChessGame.pas',
  ChessMessages in 'source\ChessMessages.pas',
  ChessClient  in 'source\ChessClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFormConfigure, FormConfigure);
  Application.Run;
end.
