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
  Vcl.StdCtrls,
  PromotionForm,
  Vcl.Buttons,
  SimpleClock,
  ChessGame,
  Vcl.ComCtrls;
type
  TMainForm = class(TForm)
    pnl_Board       : TPanel;
    pnl_SidePanel   : TPanel;
    pnl_Status      : TPanel;
    btnNewGame      : TButton;
    cbBoard         : TChessBoard;
    lblStatus       : TLabel;
    btnFlip         : TButton;
    btnPromotionForm: TButton;
    btnStart        : TButton;
    Clock_2         : TSimpleClock;
    Clock_1         : TSimpleClock;
    redtMoves       : TRichEdit;
    btnConfigure    : TBitBtn;
    btnReplay       : TButton;
    procedure btnNewGameClick(Sender: TObject);
    procedure btnFlipClick(Sender: TObject);
    procedure btnPromotionFormClick(Sender: TObject);
    procedure btnConfigureClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnReplayClick(Sender: TObject);
  private
    FGameState         : TGameState;
    FWhiteClockRunning : Boolean;
    procedure OnGameChanged(Status : TGameState);
    procedure OnNewMove(Move : TSimpleChessMove);
  public
    constructor Create(AOwner: TComponent); override;

end;

var
  MainForm : TMainForm;

implementation

uses
  ConfigureForm;

{$R *.dfm}
constructor TMainForm.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  cbBoard.OnGameChanged := OnGameChanged;
  cbBoard.OnNewMove     := OnNewMove;
{$IFDEF DEBUG}
  btnPromotionForm.Visible := True;
{$ELSE}
  btnPromotionForm.Visible := False;
{$ENDIF}
  cbBoard.BlockBoard := True;
  Clock_1.StarterTime := EncodeTime(0,5,0,0);
  Clock_2.StarterTime := EncodeTime(0,5,0,0);
  Clock_1.Increment   := EncodeTime(0,0,0,0);
  Clock_2.Increment   := EncodeTime(0,0,0,0);
  Clock_1.Reset;
  Clock_2.Reset;
end;

procedure TMainForm.btnConfigureClick(Sender: TObject);
begin
  with TFormConfigure.Create(Self) do
  begin
    ShowModal;
    Clock_1.StarterTime := GetBlackTime;
    Clock_1.Increment   := GetBlackInc;
    Clock_2.StarterTime := GetWhiteTime;
    Clock_2.Increment   := GetWhiteInc;
    Clock_1.Reset;
    Clock_2.Reset;
    Free;
  end;
end;

procedure TMainForm.btnFlipClick(Sender: TObject);
begin
  cbBoard.Flip;
end;

procedure TMainForm.btnNewGameClick(Sender: TObject);
begin
  cbBoard.Reset;
  Clock_2.Stop;
  Clock_1.Stop;
  Clock_1.Reset;
  Clock_2.Reset;
  cbBoard.BlockBoard := True;
end;

procedure TMainForm.btnPromotionFormClick(Sender: TObject);
begin
  with TPromotion.Create(Self) do
  begin
    ConfigureForm(False);
    Left := Mouse.CursorPos.X;
    Top  := Mouse.CursorPos.Y;
    ShowModal;
    Free;
  end;
end;

procedure TMainForm.btnReplayClick(Sender: TObject);
begin
  Clock_2.Stop;
  Clock_1.Stop;
  Clock_1.Reset;
  Clock_2.Reset;
  cbBoard.StartReplay;
  redtMoves.Clear;
end;

procedure TMainForm.btnStartClick(Sender: TObject);
begin
  FWhiteClockRunning := True;
  FGameState := gsWhiteToMove;
  redtMoves.Clear;
  cbBoard.Start;
  Clock_2.Start;
end;

procedure TMainForm.OnGameChanged(Status : TGameState);
begin
  lblStatus.Caption := Status.ToString;
  if (Status <> FGameState) then
  begin
    FGameState := Status;
    if FGameState <= gsBlackInCheck then
    begin
      if FWhiteClockRunning then
      begin
        Clock_1.Start;
        Clock_2.Stop;
      end
      else begin
        Clock_1.Stop;
        Clock_2.Start;
      end;
      FWhiteClockRunning := not FWhiteClockRunning;
    end
    else begin
      Clock_1.Stop;
      Clock_2.Stop;
      Clock_1.Reset;
      Clock_2.Reset;
    end;

  end;
end;
procedure TMainForm.OnNewMove(Move : TSimpleChessMove);
begin
  redtMoves.Lines.Add(Move.ToString);
end;
end.
