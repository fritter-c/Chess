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
  Vcl.StdCtrls, Vcl.Buttons;
type
  TMainForm = class(TForm)
    pnl_Board : TPanel;
    pnl_Moves : TPanel;
    pnl_Status: TPanel;
    btnNewGame: TButton;
    cbBoard: TChessBoard;
    lblStatus: TLabel;
    btnFlip: TButton;
    procedure btnNewGameClick(Sender: TObject);
    procedure btnFlipClick(Sender: TObject);
  private
    procedure OnGameChanged(Status : TGameState);
  public
    constructor Create(AOwner: TComponent); override;

end;

var
  MainForm : TMainForm;

implementation


{$R *.dfm}
constructor TMainForm.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  cbBoard.OnGameChanged := OnGameChanged;
end;

procedure TMainForm.btnFlipClick(Sender: TObject);
begin
  cbBoard.Flip;
end;

procedure TMainForm.btnNewGameClick(Sender: TObject);
begin
  cbBoard.Reset;
end;

procedure TMainForm.OnGameChanged(Status : TGameState);
begin
  lblStatus.Caption := Status.ToString;
end;
end.
