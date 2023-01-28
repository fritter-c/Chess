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
  end;
  PChessPoint = ^TChessPoint;

  TSpecialSquares = set of TChessCoordinate;

  TChessBoard = class(TCustomControl)
  private
    FOnPaint    : TNotifyEvent;
    FUseD2D     : Boolean;
    FD2DCanvas  : TDirect2DCanvas;
    FPieces     : array[1..32] of TChessPiece;
    FBoard      : array[0..8] of array[0..8] of TChessPoint;
    FBoardMap   : TDictionary<TChessCoordinate, PChessPoint>;
    FMap        : TDictionary<TChessCoordinate, TPoint>;
    FDragging   : Boolean;
    FDragPiece  : TChessPiece;
    FWhiteTurn  : Boolean;
    FMoves      : Integer;
    FFirstMove  : Boolean;

    function CreateD2DCanvas : Boolean;

    procedure WmPaint(var Message : TWMPaint); message WM_PAINT;
    procedure WmSize(var Message : TWMSize); message WM_SIZE;

    procedure SetAcceleratedD2D(const Value : Boolean);
    function  GetGDICanvas : TCanvas;
    function  GetOSCanvas  : TCustomCanvas;
    function  CanCastle(Piece : TChessPiece; Long : Boolean) : Boolean;
    function  SquareAttacked (Square : TChessCoordinate; ByWhite : Boolean) : Boolean;

    procedure CreateChessPieces;
    procedure MapCoordinates;
    procedure MapBoard;
    function  MapFromPoint(const X, Y : Integer; var Coordinate : TChessCoordinate) : Boolean;
    function  GetPiece(const Position : TChessCoordinate; var ChessPiece : TChessPiece) : Boolean;
    function  CheckMove(const A, B : TChessCoordinate; ChessPiece : TChessPiece) : Boolean;
    function  CheckObstacles(const A, B : TChessCoordinate) : Boolean;
    procedure UpdateBoard(const A, B : TChessCoordinate; const Piece : TChessPiece);

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
  FMap       := TDictionary<TChessCoordinate, TPoint>.Create;
  FBoardMap  := TDictionary<TChessCoordinate, PChessPoint>.Create;
  FDragging  := False;
  FWhiteTurn := True;
  FMoves     := 0;
  FFirstMove := True;

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
  MapBoard;
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
      if not FPieces[I].Captured then
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

  FPieces[9]  := TBishop.Create(True);
  FPieces[10] := TBishop.Create(False);
  FPieces[11] := TBishop.Create(True);
  FPieces[12] := TBishop.Create(False);

  FPieces[9].InitialPos := c1;
  FPieces[10].InitialPos := c8;
  FPieces[11].InitialPos := f1;
  FPieces[12].InitialPos := f8;

  FPieces[13] := TKnight.Create(True);
  FPieces[14] := TKnight.Create(False);
  FPieces[15] := TKnight.Create(True);
  FPieces[16] := TKnight.Create(False);

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

procedure TChessBoard.MapBoard;
var
  I : Integer;
  X : TChessPoint;
  P : TChessPiece;
  Px: PChessPoint;
  K : TChessCoordinate;
begin
  for K in FBoardMap.Keys do
  Dispose(FBoardMap[K]);

  FBoardMap.Clear;
  for I := 1 to 64 do
  begin
    X.Piece := nil;

    for P in FPieces do
    if P.Position = TChessCoordinate(I) then
    begin
      X.Piece := P;
      Break;
    end;

    New(Px);

    Px^ := X;
    X.Point := FMap[TChessCoordinate(I)];
    FBoardMap.Add(TChessCoordinate(I), pX);
  end;
end;

function TChessBoard.GetPiece(const Position : TChessCoordinate; var ChessPiece : TChessPiece) : Boolean;
var
  X : PChessPoint;
begin
  Result := False;
  ChessPiece := nil;
  if (FBoardMap.TryGetValue(Position, X)) then
  begin
    ChessPiece := X.Piece;
    Result := X.Piece <> nil;
  end;
end;

function TChessBoard.CheckMove(const A, B : TChessCoordinate; ChessPiece : TChessPiece) : Boolean;
var
  Piece : TChessPiece;
begin
  Result := True;
  if not (ChessPiece is TKnight) then
  begin
    Result := CheckObstacles(A,B);
  end;

  if GetPiece(B, Piece) then
  begin
    Result := Piece.White <> ChessPiece.White;

    if Result then
      Piece.Captured := True;
  end;
end;

function TChessBoard.CheckObstacles(const A, B : TChessCoordinate) : Boolean;
begin
  Result := True;
end;
function TChessBoard.MapFromPoint(const X: Integer; const Y: Integer; var Coordinate : TChessCoordinate): Boolean;
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

procedure TChessBoard.UpdateBoard(const A, B : TChessCoordinate;const Piece : TChessPiece);
var
  X : PChessPoint;
begin
  if FBoardMap.TryGetValue(A, X) then
  begin
    X.Piece := nil;
  end;
  if FBoardMap.TryGetValue(B, X) then
  begin
    X.Piece := Piece;
  end;
end;

procedure TChessBoard.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Coordinate : TChessCoordinate;
  Origin     : TChessCoordinate;
  Piece      : TChessPiece;
  bCapture   : Boolean;
  bDone      : Boolean;
begin
  if FDragging and Assigned(FDragPiece) then
  begin
    bCapture := False;
    bDone  := False;
    Origin := FDragPiece.Position;
    if MapFromPoint(X, Y, Coordinate) then
    begin
      if GetPiece(Coordinate, Piece) then
        bCapture := True;

      if (FDragPiece is TKing) and (not FDragPiece.Moved) then
      begin
        if FWhiteTurn then
        begin
          if Coordinate = c1 then
          begin
            var Rook : TChessPiece;
            if GetPiece(a1, Rook) and not Rook.Moved and CanCastle(FDragPiece, True) then
            begin
              (Rook as TRook).LongCastle;
              (FDragPiece as TKing).LongCastle;
               bDone := True;
               FWhiteTurn := not FWhiteTurn;

               UpdateBoard(FDragPiece.InitialPos, FDragPiece.Position, FDragPiece);
               UpdateBoard(a1, Rook.Position, Rook);
            end;
          end
          else if Coordinate = g1 then
          begin
            var Rook : TChessPiece;
            if GetPiece(h1, Rook) and not Rook.Moved and CanCastle(FDragPiece, False) then
            begin
              (Rook as TRook).ShortCastle;
              (FDragPiece as TKing).ShortCastle;
               bDone := True;
               FWhiteTurn := not FWhiteTurn;

               UpdateBoard(FDragPiece.InitialPos, FDragPiece.Position, FDragPiece);
               UpdateBoard(h1, Rook.Position, Rook);
            end;
          end;
        end
        else
        begin
          if Coordinate = c8 then
          begin
            var Rook : TChessPiece;
            if GetPiece(a8, Rook) and not Rook.Moved and CanCastle(FDragPiece, True) then
            begin
              (Rook as TRook).LongCastle;
              (FDragPiece as TKing).LongCastle;
               bDone := True;
               FWhiteTurn := not FWhiteTurn;

               UpdateBoard(FDragPiece.InitialPos, FDragPiece.Position, FDragPiece);
               UpdateBoard(a8, Rook.Position, Rook);
            end;
          end
          else if Coordinate = g8 then
          begin
            var Rook : TChessPiece;
            if GetPiece(h8, Rook) and not Rook.Moved and CanCastle(FDragPiece, False) then
            begin
              (Rook as TRook).ShortCastle;
              (FDragPiece as TKing).ShortCastle;
               bDone := True;
               FWhiteTurn := not FWhiteTurn;

               UpdateBoard(FDragPiece.InitialPos, FDragPiece.Position, FDragPiece);
               UpdateBoard(a8, Rook.Position, Rook);
            end;
          end;
        end;

      end;

      if (not bDone) and (FWhiteTurn xor (not FDragPiece.White)) and
          FDragPiece.CanMove(Coordinate, bCapture) then
      begin
        if CheckMove(FDragPiece.Position, Coordinate, FDragPiece) and
           FDragPiece.Move(Coordinate, bCapture)  then
        begin
          UpdateBoard(Origin, FDragPiece.Position, FDragPiece);
          FWhiteTurn := not FWhiteTurn;
          Inc(FMoves);
          FFirstMove := False;

        end;
      end;
    end;
  end;
  FDragging  := False;
  FDragPiece := nil;
  Invalidate;
  inherited;
end;

procedure TChessBoard.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Coordinate : TChessCoordinate;
  Piece      : TChessPiece;
begin
  if MapFromPoint(X,Y,Coordinate) then
  begin
    if GetPiece(Coordinate, Piece) then
    begin
      FDragging := True;
      FDragPiece := Piece;
    end
    else
    begin
      FDragging  := False;
      FDragPiece := nil;
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
  MapBoard;
  FWhiteTurn := True;
  FFirstMove := True;
  FMoves := 0;
  Invalidate;
end;

function TChessBoard.CanCastle(Piece : TChessPiece; Long : Boolean) : Boolean;
var
  Point      : PChessPoint;
  Coordinate : TChessCoordinate;
  WhiteL     : TSpecialSquares;
  WhiteS     : TSpecialSquares;
  BlackL     : TSpecialSquares;
  BlackS     : TSpecialSquares;
begin
  Result := True;

  WhiteL  := [b1, c1, d1];
  WhiteS  := [f1, g1];
  BlackL  := [b8, c8, d8];
  BlackS  := [f8, g8];

  if (Piece is TKing) then
  begin
    if Piece.White then
    begin
      if Long then
      begin
        for var I in WhiteL do
        begin
          if FBoardMap.TryGetValue(I,Point) then
            Result := Result and (Point.Piece = nil);

          Result := SquareAttacked(I, False);
        end;
      end
      else begin
        for var I in WhiteS do
        begin
          if FBoardMap.TryGetValue(I,Point) then
            Result := Result and (Point.Piece = nil);

          Result := SquareAttacked(I, False);
        end;
      end;
    end
    else begin
      if Long then
      begin
        for var I in BlackL do
        begin
          if FBoardMap.TryGetValue(I,Point) then
            Result := Result and (Point.Piece = nil);

          Result := SquareAttacked(I, True);
        end;
      end
      else begin
        for var I in BlackS do
        begin
          if FBoardMap.TryGetValue(I,Point) then
            Result := Result and (Point.Piece = nil);

          Result := SquareAttacked(I, True);
        end;
      end;
    end;
  end;
end;

function TChessBoard.SquareAttacked (Square : TChessCoordinate; ByWhite : Boolean) : Boolean;
var
  Coordinate : TChessCoordinate;
begin
  Result := True;
end;
function MapFromRowColumn(Row : Integer; Column : Integer) : TChessCoordinate;
begin
  Result := TChessCoordinate(Row + 1 + Column * 8);
end;
end.
