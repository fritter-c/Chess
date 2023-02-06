unit ChessClient;

interface
uses
  Windows,
  Messages,
  Net.Socket,
  OverbyteICSWSocket,
  Classes;

type
  PByteArray = array of PByte;

  TChessClient = class(TThread)

  private
    FSocket : TWSocket;

    procedure ProcessMessage(var MsgRec : TMsg);
    procedure HandleNewMove(var MsgRec : TMsg);
    procedure HandleConnection(var MsgRec : TMsg);
    procedure ConfigureSocket;
    procedure DataAvaiable(Sender : TObject; Error : Word);
    procedure ConnectionChanged(Sender : TObject; OldState, NewState : TSocketState);
    procedure ExecuteDestroy;
    procedure ProcessNewMove(Data : array of Byte; Size : Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;

    property Socket : TWSocket read FSocket;
  end;
var
  g_ChessClient : TChessClient;

procedure CreateClient;

implementation
uses
  ChessMessages,
  ChessGame,
  ChessPieces,
  Main,
  ActiveX;
const
  c_ClientNewMove = 1;
constructor TChessClient.Create;
begin
  inherited Create(False);
  FSocket := nil;
end;

destructor TChessClient.Destroy;
begin
  inherited;
end;

procedure TChessClient.ProcessMessage(var MsgRec : TMsg);
begin
  case MsgRec.message of
    WM_NEW_MOVE : HandleNewMove(MsgRec);
    WM_CONNECT  : HandleConnection(MsgRec);
  end;
end;

procedure TChessClient.HandleNewMove(var MsgRec: TMSG);
var
  Move : TSimpleChessMove;
  Data : array of Byte;
begin
  Move := PSimpleChessMove(MsgRec.WParam)^;
  Dispose(PSimpleChessMove(MsgRec.WParam));

  SetLength(Data, Sizeof(TSimpleChessMove) + 1);

  Data[0] := Byte(c_ClientNewMove);
  Data[1] := Byte(Move.Piece);
  Data[2] := Byte(Move.From);
  Data[3] := Byte(Move.Move);
  if (FSocket <> nil) and (FSocket.State = wsConnected) then
    FSocket.Send(@Data[0], Length(Data));
end;

procedure TChessClient.ConfigureSocket;
begin
  FSocket.Proto := 'tcp';
  FSocket.MultiThreaded := True;
  FSocket.Port := '8080';
  FSocket.Addr := '127.0.0.1';
  FSocket.SslContext := TSslContext.Create(nil);
  FSocket.LineMode  := False;
  FSocket.OnDataAvailable := DataAvaiable;
  FSocket.ComponentOptions := [wsoTcpNoDelay];
  FSocket.OnChangeState := ConnectionChanged;
end;

procedure TChessClient.HandleConnection(var MsgRec : TMsg);
begin
  try
    if FSocket = nil then FSocket := TWSocket.Create(nil)
    else begin
      FSocket.Destroy;
      FSocket := TWSocket.Create(nil);
    end;

    ConfigureSocket;
    FSocket.Connect;
  finally


  end;
end;

procedure TChessClient.DataAvaiable(Sender : TObject; Error : Word);
var
  Data : array of Byte;
begin
  SetLength(Data, 255);
  FSocket.Receive(@Data[0], 255);
  case Data[0] of
    c_ClientNewMove : ProcessNewMove(Data, 4);
  end;
end;

procedure TChessClient.ConnectionChanged(Sender : TObject; OldState, NewState : TSocketState);
begin
  PostMessage(MainForm.MainHandle, WM_CONNECTIONCHANGED, 0,0);
end;
procedure TChessClient.Execute;
var
  MsgRec : TMsg;
begin
  NameThreadForDebugging('CHESS_CLIENT');
  PeekMessage(MsgRec, 0, WM_USER, WM_USER, PM_NOREMOVE);
  CoInitialize(nil);
  try
    while not Terminated and GetMessage(MsgRec, 0,0,0) do
    begin
      TranslateMessage(MsgRec);
      ProcessMessage(MsgRec);
      DispatchMessage(MsgRec);
    end;
  finally

  end;
  ExecuteDestroy;
end;

procedure TChessClient.ExecuteDestroy;
begin
  FSocket.SslContext.Free;
  FSocket.Abort;
  FSocket.Free;
end;

procedure TChessClient.ProcessNewMove(Data : array of Byte; Size : Integer);
var
  Move : PSimpleChessMove;
begin
  new(Move);
  with Move^ do
  begin
    Piece := TChessPieceName(Data[1]);
    From := TChessCoordinate(Data[2]);
    Move := TChessCoordinate(Data[3]);
  end;
  PostMessage(MainForm.MainHandle, WM_PROCESS_NEW_MOVE, WPARAM(Move),0);
end;

procedure CreateClient;
begin
  g_ChessClient := TChessClient.Create;
end;

initialization
  g_ChessClient := nil;
end.
