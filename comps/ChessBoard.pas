unit ChessBoard;

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
  Direct2D;

type
  TChessPoint = record
    Point : TPoint;
    Piece : TChessPiece;
    Coord : TChessCoordinate;
  end;
  TChessBoard = class(TCustomControl)
  private
    FOnPaint    : TNotifyEvent;
    FUseD2D     : Boolean;
    FD2DCanvas  : TDirect2DCanvas;
    FPieces     : array[1..32] of TChessPiece;
    FMap        : TDictionary<TChessCoordinate, TPoint>;
    FDragging   : Boolean;
    FDragPiece  : TChessPiece;

    function CreateD2DCanvas : Boolean;

    procedure WmPaint(var Message : TWMPaint); message WM_PAINT;
    procedure WmSize(var Message : TWMSize); message WM_SIZE;

    procedure SetAcceleratedD2D(const Value : Boolean);
    function  GetGDICanvas : TCanvas;
    function  GetOSCanvas  : TCustomCanvas;

    procedure CreateChessPieces;
    procedure MapCoordinates;
    function  MapFromPoint(X, Y : Integer; var Coordinate : TChessCoordinate) : Boolean;

  protected
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure PaintPieces;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy(); override;
    procedure Reset;

    property Accelerated : Boolean         read FUseD2D write SetAcceleratedD2D;
    property Canvas      : TCustomCanvas   read GetOSCanvas;
    property GDICanvas   : TCanvas         read GetGDICanvas;
    property D2DCanvas   : TDirect2DCanvas read FD2DCanvas;

    property OnPaint : TNotifyEvent read FOnPaint write FOnPaint;
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
  function MapFromRowColumn(Row : Integer; Column : Integer) : TChessCoordinate; inline;
implementation

uses
  Windows,
  Winapi.D2D1;

procedure Register;
begin
  RegisterComponents('ChessComponents', [TChessBoard]);
end;
constructor TChessBoard.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FD2DCanvas := nil;
  FDragPiece := nil;
  FMap := TDictionary<TChessCoordinate, TPoint>.Create;
  FDragging := False;
  CreateChessPieces;
end;

destructor TChessBoard.Destroy;
begin
  inherited;
  if FD2DCanvas <> nil then
    FD2DCanvas.Free;
end;

procedure TChessBoard.CreateWnd;
begin
  inherited;

  if (Win32MajorVersion >= 6) and (Win32Platform = VER_PLATFORM_WIN32_NT)
    then FUseD2D := CreateD2DCanvas
    else FUseD2D := False;
end;

function TChessBoard.CreateD2DCanvas : Boolean;
begin
  try
    FD2DCanvas := TDirect2DCanvas.Create(Handle);
  except
    Exit(False);

  end;
  Result := True;
end;

function TChessBoard.GetGDICanvas: TCanvas;
begin
  if FUseD2D
    then Result := nil
    else Result := inherited Canvas;
end;

procedure TChessBoard.SetAcceleratedD2D(const Value: Boolean);
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

procedure TChessBoard.WmPaint(var Message: TWMPaint);
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
procedure TChessBoard.WmSize(var Message: TWMSize);
var
  Size : TD2D1SizeU;
begin
  Size := D2D1SizeU(Width, Height);
  if FD2DCanvas <> nil then
    ID2D1HwndRenderTarget(FD2DCanvas.RenderTarget).Resize(Size);
  inherited;
  MapCoordinates;
end;

function TChessBoard.GetOSCanvas: TCustomCanvas;
begin
  if FUseD2D
    then Result := FD2DCanvas
    else Result := inherited Canvas;
end;

procedure TChessBoard.Paint;
var
  nSquareHeight : Cardinal;
  nSquareWidth  : Cardinal;
  nX            : Cardinal;
  nY            : Cardinal;
  rectSquare    : TRect;
  I             : Integer;
  clLastColor   : TColor;
begin
  if FUseD2D then
  begin
    clLastColor := clBlue;
    FD2DCanvas.Brush.Color := clBlue;
    nSquareHeight := Height div 8;
    nSquareWidth  := Width div 8;
    nX := 0;
    nY := 0;
    with FD2DCanvas do
    begin

      for I := 1 to 64 do
      begin
        rectSquare.Top := nY;
        rectSquare.Left := nX;
        rectSquare.Width := nSquareWidth;
        rectSquare.Height := nSquareHeight;
        Rectangle(rectSquare);
        FillRect(rectSquare);

        if I mod 8 <> 0 then
        begin
          nX := nX + nSquareWidth;
          if clLastColor = clBlue
            then Brush.Color := clSkyBlue
            else Brush.Color := clBlue;
          clLastColor := Brush.Color;
        end
        else
        begin
          nX := 0;
          nY := nY + nSquareHeight;
        end;

      end;
    end;
    PaintPieces;
    if Assigned(FOnPaint) then
      OnPaint(Self);
  end;
end;

procedure TChessBoard.PaintPieces;
var
  I             : Integer;
  Point         : TPoint;
begin
  if FUseD2D then
  begin
    for I := 1 to 32 do
    begin
      Point := FMap[FPieces[I].Position];
      FD2DCanvas.Draw(Point.X, Point.Y, FPieces[I]);
    end;

  end;
end;

procedure TChessBoard.CreateChessPieces;
var
  nIndex : Integer;
  bWhite : Boolean;
  nPos   : Integer;
begin
  FPieces[1] := TKing.Create(True);
  FPieces[2] := TKing.Create(False);

  FPieces[1].InitialPos := e1;
  FPieces[2].InitialPos := e8;

  FPieces[3] := TQueen.Create(True);
  FPieces[4] := TQueen.Create(False);

  FPieces[3].InitialPos := d1;
  FPieces[4].InitialPos := d8;

  FPieces[5] := TRook.Create(True);
  FPieces[6] := TRook.Create(False);
  FPieces[7] := TRook.Create(True);
  FPieces[8] := TRook.Create(False);

  FPieces[5].InitialPos := a1;
  FPieces[6].InitialPos := a8;
  FPieces[7].InitialPos := h1;
  FPieces[8].InitialPos := h8;

  FPieces[9] := TBishop.Create(True);
  FPieces[10] := TBishop.Create(False);
  FPieces[11] := TBishop.Create(True);
  FPieces[12] := TBishop.Create(False);

  FPieces[9].InitialPos := c1;
  FPieces[10].InitialPos := c8;
  FPieces[11].InitialPos := f1;
  FPieces[12].InitialPos := f8;

  FPieces[13] := TKnight.Create(True);
  FPieces[14]:= TKnight.Create(False);
  FPieces[15] := TKnight.Create(True);
  FPieces[16]:= TKnight.Create(False);

  FPieces[13].InitialPos := b1;
  FPieces[14].InitialPos := b8;
  FPieces[15].InitialPos := g1;
  FPieces[16].InitialPos := g8;

  bWhite := True;
  nPos   := 2;
  for nIndex := 17 to 32 do
  begin
    FPieces[nIndex] := TPawn.Create(bWhite);
    FPieces[nIndex].InitialPos := TChessCoordinate(nPos);
    Inc(nPos,8);
    if nIndex = 24 then
      begin
        bWhite := not bWhite;
        nPos   := 7;
      end;
  end;
end;

procedure TChessBoard.MapCoordinates;
var
  I             : Integer;
  nSquareHeight : Integer;
  X             : Integer;
  Y             : Integer;
begin
  FMap.Clear;
  nSquareHeight := Height div 8;
  X := 0;
  Y := Height - nSquareHeight;

  for I := 1 to 64 do
  begin
    FMap.Add(TChessCoordinate(I), Point(X,Y));
    if I mod 8 <> 0 then
    begin
      Y := Y - nSquareHeight;
    end
    else
    begin
      Y := Height - nSquareHeight;;
      X := X + nSquareHeight;
    end;
  end;
end;

function TChessBoard.MapFromPoint(X: Integer; Y: Integer; var Coordinate : TChessCoordinate): Boolean;
var
  nSquareHeight : Integer;
  nSquareWidth  : Integer;
  Row           : Integer;
  Column        : Integer;
begin
  nSquareHeight := Height div 8;
  nSquareWidth  := Width div 8;
  if (X < 0) or (X > Width) or (Y > Height) or (Y < 0) then
  begin
    Result := False;
    Coordinate := a1;
  end
  else
  begin
    Column:= X div nSquareWidth;
    Row := (Height - Y) div nSquareHeight;
    Coordinate := MapFromRowColumn(Row, Column);
    Result := True;
  end;
end;

procedure TChessBoard.MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TChessBoard.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Coordinate : TChessCoordinate;
begin
  if FDragging and Assigned(FDragPiece) then
  begin
    if MapFromPoint(X, Y, Coordinate) then
    begin
      if FDragPiece.Move(Coordinate) then
        Invalidate;
    end;
  end;
  FDragging  := False;
  FDragPiece := nil;
  inherited;
end;

procedure TChessBoard.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Coordinate : TChessCoordinate;
  Piece      : TChessPiece;
begin
  if MapFromPoint(X,Y,Coordinate) then
  begin
    for Piece in FPieces do
    begin
      if Piece.Position = Coordinate then
      begin
        FDragging := True;
        FDragPiece := Piece;
        break
      end
      else
      begin
        FDragging  := False;
        FDragPiece := nil;
      end;
    end;
  end
  else
  begin
    FDragging  := False;
    FDragPiece := nil;
  end;

  inherited;
end;

procedure TChessBoard.Reset;
var
  Piece : TChessPiece;
begin
  for Piece in FPieces do
    Piece.Reset;
  Invalidate;
end;

function MapFromRowColumn(Row : Integer; Column : Integer) : TChessCoordinate;
begin
  Result := TChessCoordinate(Row + 1 + Column * 8);
end;
end.
