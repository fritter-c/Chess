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
  OverbyteIcsWndControl,
  OverbyteIcsWSocket,
  OverbyteIcsWSocketS,
  Vcl.StdCtrls,
  Generics.Collections,
  Vcl.ComCtrls;

type
  PByteArray = array of Byte;

  TMainForm = class(TForm)
    redtOutPut  : TRichEdit;
    btnActivate : TButton;
    btnClose    : TButton;
    lblClients  : TLabel;
    ssSocket    : TWSocketServer;

    procedure ssSocketSessionAvailable(Sender: TObject; ErrCode: Word);
    procedure ssSocketClientConnect   (Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure ssSocketDataAvailable   (Sender: TObject; ErrCode: Word);
    procedure btnActivateClick        (Sender: TObject);
    procedure ssSocketDataSent        (Sender: TObject; ErrCode: Word);
    procedure btnCloseClick           (Sender: TObject);
    procedure ssSocketClientDisconnect(Sender: TObject; Client: TWSocketClient; Error: Word);
    procedure ssSocketClientCreate    (Sender: TObject; Client: TWSocketClient);
    procedure ssSocketSessionClosed   (Sender: TObject; ErrCode: Word);
    procedure ssSocketSessionConnected(Sender: TObject; ErrCode: Word);
    procedure ssSocketSendData        (Sender: TObject; BytesSent: Integer);
  private
    FClients : TList<TWSocketClient>;
    procedure ConnectionDataAvailable(Sender: TObject; ErrCode: Word);
    procedure HandleClientMove       (Data : PByteArray; Size : Integer; Sender : TWSocketClient);
  public
    constructor Create(Owner : TComponent); override;
    destructor  Destroy; override;
  end;

var
  MainForm: TMainForm;
const
  c_ClientNewMove = 1;

implementation

{$R *.dfm}

constructor TMainForm.Create(Owner : TComponent);
begin
  inherited;
  FClients := TList<TWSocketClient>.Create;
end;

destructor TMainForm.Destroy;
var
  I : Integer;
begin
  FClients.Free;
  inherited;
end;

procedure TMainForm.btnActivateClick(Sender: TObject);
begin
  try
    ssSocket.ClientClass := TWSocketClient;
    ssSocket.Listen;
  finally

  end;
end;

procedure TMainForm.ConnectionDataAvailable(Sender: TObject; ErrCode: Word);
var
  RcvBuf : Integer;
  Data   : PByteArray;
begin
  SetLength(Data, 255);
  RcvBuf := TWSocketClient(Sender).Receive(Data, 255);
  case Data[0]  of
    c_ClientNewMove : HandleClientMove(Data,4, TWSocketClient(Sender));
  end;
end;

procedure TMainForm.HandleClientMove(Data : PByteArray; Size : Integer; Sender : TWSocketClient);
var
  I      : Integer;
  Buffer : array of Byte;
begin
  SetLength(Buffer, Size);
  for I := 0 to Size - 1 do
  begin
    Buffer[I] := Data[I];
  end;

  for I := 0 to FClients.Count - 1 do
  begin
    if FClients[i] <> Sender then FClients[i].Send(@Buffer[0], Size);
  end;
end;

procedure TMainForm.btnCloseClick(Sender: TObject);
begin
  ssSocket.Close;
end;

procedure TMainForm.ssSocketClientConnect(Sender: TObject; Client: TWSocketClient; Error: Word);
var
  I : Integer;
begin
  lblClients.Caption := 'Clients: ' + IntToStr(FClients.Count);
end;

procedure TMainForm.ssSocketClientCreate(Sender: TObject; Client: TWSocketClient);
begin
 redtOutPut.Lines.Add('Client Created');
 if FClients.IndexOf(Client) < 0 then
    FClients.Add(Client);
 Client.OnDataAvailable := ConnectionDataAvailable;
end;

procedure TMainForm.ssSocketClientDisconnect(Sender: TObject; Client: TWSocketClient; Error: Word);
var
  I : Integer;
begin
  lblClients.Caption := 'Clients: ' + IntToStr(FClients.Count);
  redtOutPut.Lines.Add('Client Disconnect');
  if FClients.IndexOf(Client) < 0 then
    FClients.Remove(Client);
end;

procedure TMainForm.ssSocketDataAvailable(Sender: TObject; ErrCode: Word);
var
  Data : array of PByte;
begin
  SetLength(Data, 4096);
  redtOutPut.Lines.Add('Socket DataAvailable');
  ssSocket.Receive(Data, 4096)
end;

procedure TMainForm.ssSocketDataSent(Sender: TObject; ErrCode: Word);
begin
  redtOutPut.Lines.Add('Socket DataSent');
end;

procedure TMainForm.ssSocketSendData(Sender: TObject; BytesSent: Integer);
begin
  redtOutPut.Lines.Add('Socket SendData');
end;

procedure TMainForm.ssSocketSessionAvailable(Sender: TObject; ErrCode: Word);
begin
  lblClients.Caption := 'Clients: ' + IntToStr(FClients.Count);
  redtOutPut.Lines.Add('SocketSessionAvailable');
end;

procedure TMainForm.ssSocketSessionClosed(Sender: TObject; ErrCode: Word);
begin
  lblClients.Caption := 'Clients: ' + IntToStr(FClients.Count);
end;

procedure TMainForm.ssSocketSessionConnected(Sender: TObject; ErrCode: Word);
begin
   lblClients.Caption := 'Clients: ' + IntToStr(FClients.Count);
end;
end.
