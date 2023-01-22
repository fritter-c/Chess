unit Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  ChessBoard,
  Vcl.StdCtrls;
type
  TMainForm = class(TForm)
    pnl_Board : TPanel;
    pnl_Moves : TPanel;
    pnl_Status: TPanel;
    btnNewGame: TButton;
    cbBoard: TChessBoard;
    procedure btnNewGameClick(Sender: TObject);
  private

  public
    constructor Create(AOwner: TComponent); override;

end;

var
  MainForm : TMainForm;

implementation


{$R *.dfm}
procedure TMainForm.btnNewGameClick(Sender: TObject);
begin
  cbBoard.Reset;
end;

constructor TMainForm.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
end;

end.
