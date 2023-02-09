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
  ChessPieces,
  Vcl.ComCtrls;
type
  TMainForm = class(TForm)
    pnl_Board          : TPanel;
    pnl_SidePanel      : TPanel;
    pnl_Status         : TPanel;
    btnNewGame         : TButton;
    lblStatus          : TLabel;
    btnFlip            : TButton;
    btnStart           : TButton;
    redtMoves          : TRichEdit;
    btnConfigure       : TBitBtn;
    btnReplay          : TButton;
    btnConnect         : TButton;
    lblConnectionStatus: TLabel;
    pnlStatus          : TPanel;
    cbBoard            : TChessBoard;
    Clock_2            : TSimpleClock;
    Clock_1            : TSimpleClock;
    procedure btnNewGameClick      (Sender: TObject);
    procedure btnFlipClick         (Sender: TObject);
    procedure btnPromotionFormClick(Sender: TObject);
    procedure btnConfigureClick    (Sender: TObject);
    procedure btnStartClick  (Sender: TObject);
    procedure btnReplayClick (Sender: TObject);
    procedure btnConnectClick(Sender: TObject);

  private
    FGameState         : TGameState;
    FWhiteClockRunning : Boolean;
    FHandle            : HWND;

    procedure OnGameChanged (Status : TGameState);
    procedure OnNewMove     (Move : TSimpleChessMove);
    procedure ProcessMessage(var Msg : TMessage);
    procedure ProcessNewMove(var Msg : TMessage);
    procedure ConnectionChanged;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    property MainHandle : HWND read FHandle;
end;

var
  MainForm : TMainForm;

implementation

uses
  ChessClient,
  ChessMessages,
  OverbyteICSWSocket,
  ConfigureForm;

{$R *.dfm}
constructor TMainForm.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);

  cbBoard.OnGameChanged := OnGameChanged;
  cbBoard.OnNewMove     := OnNewMove;
  cbBoard.BlockBoard    := True;

  Clock_1.StarterTime   := EncodeTime(0,5,0,0);
  Clock_2.StarterTime   := EncodeTime(0,5,0,0);
  Clock_1.Increment     := EncodeTime(0,0,0,0);
  Clock_2.Increment     := EncodeTime(0,0,0,0);
  Clock_1.Reset;
  Clock_2.Reset;

  FHandle := AllocateHwnd(ProcessMessage);

  CreateClient;
end;

destructor TMainForm.Destroy;
begin
  g_ChessClient.Terminate;
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

procedure TMainForm.btnConnectClick(Sender: TObject);
begin
  PostThreadMessage(g_ChessClient.ThreadID, WM_CONNECT, 0, 0);
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
  redtMoves.Clear;
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

procedure TMainForm.ProcessMessage(var Msg : TMessage);
begin
  case Msg.Msg of
    WM_CONNECTIONCHANGED : ConnectionChanged;
    WM_PROCESS_NEW_MOVE  : ProcessNewMove(Msg);
  end;
end;

procedure TMainForm.ProcessNewMove(var Msg : TMessage);
var
  Move : TSimpleChessMove;
begin
  Move := PSimpleChessMOve(Msg.WParam)^;
  Dispose(PSimpleChessMOve(Msg.WParam));
  cbBoard.Perform(Move);
end;

procedure TMainForm.ConnectionChanged;
begin
  case g_ChessClient.Socket.State of
     wsOpened     : lblConnectionStatus.Caption := 'Opened';
     wsConnecting : lblConnectionStatus.Caption := 'Connecting';
     wsListening  : lblConnectionStatus.Caption := 'Listening';
     wsClosed     : lblConnectionStatus.Caption := 'Closed';
     wsConnected  : lblConnectionStatus.Caption := 'Connected';
  end;
end;
end.

