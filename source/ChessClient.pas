unit ChessClient;

interface
uses
  Windows,
  Messages,
  Net.Socket,
  Classes;

type
  TChessClient = class(TThread)

  private
    FSocket : TSocket;

    procedure ProcessMessage(var MsgRec : TMsg);
    procedure HandleNewMove(var MsgRec : TMsg);
  public
    constructor Create;
    procedure Execute; override;
  end;
var
  g_ChessClient : TChessClient;

procedure CreateClient;

implementation
uses
  ChessMessages,
  ChessGame,
  ActiveX;
constructor TChessClient.Create;
begin
  inherited Create(False);
end;

procedure TChessClient.ProcessMessage(var MsgRec : TMsg);
begin
  case MsgRec.message of
    WM_NEW_MOVE : HandleNewMove(MsgRec);
  end;
end;

procedure TChessClient.HandleNewMove(var MsgRec: TMSG);
var
  Move : TSimpleChessMove;
begin
  Move := PSimpleChessMove(MsgRec.WParam)^;
  Dispose(PSimpleChessMove(MsgRec.WParam));
end;

procedure TChessClient.Execute;
var
  MsgRec : TMsg;
begin
  NameThreadForDebugging('CHESS_CLIENT');
  PeekMessage(MsgRec, 0, WM_USER, WM_USER, PM_NOREMOVE);
  CoInitialize(nil);

  while not Terminated and GetMessage(MsgRec, 0,0,0) do
  begin
    TranslateMessage(MsgRec);
    ProcessMessage(MsgRec);
    DispatchMessage(MsgRec);
  end;
end;

procedure CreateClient;
begin
  g_ChessClient := TChessClient.Create;
end;

initialization
  g_ChessClient := nil;
end.
