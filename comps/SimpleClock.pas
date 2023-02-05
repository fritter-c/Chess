unit SimpleClock;

interface
uses
  Controls,
  Classes,
  Graphics,
  Forms,
  Messages,
  Generics.Collections,
  SysUtils,
  ChessPieces,
  Types,
  ExtCtrls,
  Direct2D;


type
  TClockTimeout = procedure(Sender : TObject) of object;
  TSimpleClock = class(TCustomControl)

  private
    FTime          : TTime;
    FStarterTime   : TTime;
    FTimer         : TTimer;
    FHasIncrement  : Boolean;
    FIncrement     : TTime;
    FUseD2D        : Boolean;
    FD2DCanvas     : TDirect2DCanvas;
    FTimeOut       : TClockTimeout;

    function  CreateD2DCanvas : Boolean;
    procedure WmPaint(var Message : TWMPaint); message WM_PAINT;
    procedure WmSize (var Message : TWMSize);  message WM_SIZE;
    procedure SetAcceleratedD2D(const Value : Boolean);
    function  GetGDICanvas    : TCanvas;
    function  GetOSCanvas     : TCustomCanvas;

    procedure OnTimer(Sender : TObject);
    procedure SetIncrement(AIncrement : TTime);
  protected
    procedure CreateWnd; override;
    procedure Paint; override;

  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;

    procedure Start;
    procedure Stop;
    procedure Reset;

    property Time        : TTime     read FTime         write FTime;
    property StarterTime : TTime     read FStarterTime  write FStarterTime;
    property HasIncrement: Boolean   read FHasIncrement write FHasIncrement;
    property Increment   : TTime     read FIncrement    write SetIncrement;
    property OnTimeout   : TClockTimeout read FTimeOut  write FTimeOut;

    property Accelerated : Boolean         read FUseD2D write SetAcceleratedD2D;
    property Canvas      : TCustomCanvas   read GetOSCanvas;
    property GDICanvas   : TCanvas         read GetGDICanvas;
    property D2DCanvas   : TDirect2DCanvas read FD2DCanvas;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderWidth;
    property Caption;
    property Color;
    property Constraints;
    property Ctl3D;
    property UseDockManager default True;
    property DockSite;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property Padding;
    property ParentBiDiMode;
    property ParentBackground;
    property ParentColor;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Touch;
    property Visible;
    property StyleElements;
    property StyleName;
    property OnAlignInsertBefore;
    property OnAlignPosition;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGesture;
    property OnGetSiteInfo;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;
  procedure Register;
implementation
uses
  Windows,
  Winapi.D2D1;

procedure Register;
begin
  RegisterComponents('ChessComponents', [TSimpleClock]);
end;
constructor TSimpleClock.Create(AOwner: TComponent);
begin
  inherited;
  FD2DCanvas      := nil;
  FStarterTime    := 0;
  FTime           := 0;
  FTimer          := TTimer.Create(Self);
  FTimer.OnTimer  := OnTimer;
  FTimer.Interval := 100;
  FHasIncrement   := False;
  FIncrement      := 0;
  FTimer.Enabled  := False;
end;

destructor TSimpleClock.Destroy;
begin
  inherited;
  if FD2DCanvas <> nil then
    FD2DCanvas.Free;
end;

procedure TSimpleClock.CreateWnd;
begin
  inherited;

  if (Win32MajorVersion >= 6) and (Win32Platform = VER_PLATFORM_WIN32_NT)
    then FUseD2D := CreateD2DCanvas
    else FUseD2D := False;
end;

function TSimpleClock.CreateD2DCanvas : Boolean;
begin
  try
    FD2DCanvas := TDirect2DCanvas.Create(Handle);
  except
    Exit(False);

  end;
  Result := True;
end;

function TSimpleClock.GetGDICanvas: TCanvas;
begin
  if FUseD2D
    then Result := nil
    else Result := inherited Canvas;
end;

procedure TSimpleClock.SetAcceleratedD2D(const Value: Boolean);
begin
  if Value <> FUseD2D then
    Exit;

  if not Value then
  begin
    FUseD2D := False;
    Repaint;
  end
  else
  begin
    FUseD2D := FD2DCanvas <> nil;
    if FUseD2D then
      Repaint;
  end;
end;

procedure TSimpleClock.WmPaint(var Message: TWMPaint);
var
  PaintStruct : TPaintStruct;
begin
  if FUseD2D then
  begin
    BeginPaint(Handle, PaintStruct);
    try
      FD2DCanvas.BeginDraw;
      try
        Paint;
      finally
        FD2DCanvas.EndDraw
      end;
    finally
      EndPaint(Handle, PaintStruct);
    end;
  end
  else
   inherited;
end;

procedure TSimpleClock.WmSize(var Message: TWMSize);
var
  Size : TD2D1SizeU;
begin
  Size := D2D1SizeU(Width, Height);
  if FD2DCanvas <> nil then
    ID2D1HwndRenderTarget(FD2DCanvas.RenderTarget).Resize(Size);
  inherited;
end;

function TSimpleClock.GetOSCanvas: TCustomCanvas;
begin
  if FUseD2D
    then Result := FD2DCanvas
    else Result := inherited Canvas;
end;

procedure TSimpleClock.Paint;
var
  strTime   : String;
  Point     : TPoint;
  Rect      : TRect;
  D2DRect   : D2D_Rect_F;
begin
  strTime := FormatDateTime('hh:mm:ss', FTime);
  Rect.Width := Width;
  D2DRect.left := 0;
  D2DRect.top  := 0;
  D2DRect.right:= Width;
  D2DRect.bottom:= Height;

  with FD2DCanvas do
  begin
    Brush.Color := Color;
    Pen.Color   := Color;
    FillRectangle(D2DRect);
    Font.Size := 22;
    Font.Color := clBlack;
    Point.Y := Height div 2 - (Font.Size + 10) div 2;
    Point.X := Width div 2 - TextExtent(strTime).Width div 2;
    Rect.Location := Point;
    Rect.Width  := Width;
    Rect.Height := Height;
    TextRect(Rect, strTime);
  end;
end;

procedure TSimpleClock.OnTimer(Sender : TObject);
begin
  FTime := FTime - EncodeTime(0,0,0,100);
  Invalidate;
end;

procedure TSimpleClock.SetIncrement(AIncrement : TTime);
begin
  FIncrement := AIncrement;
  if AIncrement > 0
    then FHasIncrement := True
    else FHasIncrement := False;
end;

procedure TSimpleClock.Start;
begin
  FTimer.Enabled := True;
end;

procedure TSimpleClock.Stop;
begin
  FTimer.Enabled := False;
  if FHasIncrement then FTime := FTime + FIncrement;
  Invalidate;
end;

procedure TSimpleClock.Reset;
begin
  FTimer.Enabled := False;
  FTime := FStarterTime;
  Invalidate;
end;

end.
