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
  ExtCtrls,
  Types,
  ChessGame,
  Direct2D;

type

  TGameChanged = procedure (State : TGameState) of object;
  TNewMove     = procedure (Move : TSimpleChessMove) of object;
  TChessBoard  = class(TCustomControl)
  private
    FOnPaint        : TNotifyEvent;
    FUseD2D         : Boolean;
    FD2DCanvas      : TDirect2DCanvas;
    FPieces         : array[1..32] of TChessPiece;
    FGame           : PChessGame;
    FMap            : TDictionary<TChessCoordinate, TPoint>;
    FDragging       : Boolean;
    FDragPiece      : TChessPiece;
    FWhiteTurn      : Boolean;
    FMoves          : Integer;
    FFirstMove      : Boolean;
    FState          : TGameState;
    FWhiteKing      : TChessPiece;
    FBlackKing      : TChessPiece;
    FGameChange     : TGameChanged;
    FAvailableMoves : TList<TChessCoordinate>;
    FFlipped        : Boolean;
    FHasPromoted    : Boolean;
    FBlockTable     : Boolean;
    FReplayTimer    : TTimer;
    FReplaying      : Boolean;
    FReplayIndex    : Integer;
    FFirstMap       : Boolean;
    FOnNewMove      : TNewMove;

    function CreateD2DCanvas : Boolean;
    procedure WmPaint(var Message : TWMPaint); message WM_PAINT;
    procedure WmSize (var Message : TWMSize);  message WM_SIZE;

    procedure SetAcceleratedD2D(const Value : Boolean);
    function  GetGDICanvas    : TCanvas;
    function  GetOSCanvas     : TCustomCanvas;
    function  CanCastle(Piece : TChessPiece; Long : Boolean) : Boolean;
    function  IsSquareAttacked (Square : TChessCoordinate; ByWhite : Boolean) : Boolean;

    procedure CreateChessPieces;
    procedure MapCoordinates;
    procedure MapBoard;
    function  MapFromPoint(const X, Y : Integer; var Coordinate : TChessCoordinate) : Boolean;
    function  GetPiece    (const Position : TChessCoordinate; var ChessPiece : TChessPiece) : Boolean;
    function  CheckMove   (const A, B : TChessCoordinate; ChessPiece : TChessPiece;
                           var ACapture : TChessPiece; bJustPeek : Boolean = False) : Boolean;
    function  CheckObstacles(const A, B : TChessCoordinate; bWhite : Boolean) : Boolean;
    procedure CheckKings;
    function  Castles    (const A : TChessCoordinate; Piece : TChessPiece) : Boolean;
    function  EnPassant  (const A : TChessCoordinate; Piece : TChessPiece) : Boolean;
    function  KingInCheck(bWhite : Boolean) : Boolean;
    function  GetAvailableMoves(Piece : TChessPiece) : Boolean;
    function  CheckForMate(bWhite : Boolean) : Boolean;
    function  Promote(Piece : TChessPiece) : Boolean;

    procedure OnReplayTimer(Sender : TObject);
  protected
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure PaintPieces;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp  (Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Reset;
    procedure Start;

    property Accelerated : Boolean         read FUseD2D write SetAcceleratedD2D;
    property Canvas      : TCustomCanvas   read GetOSCanvas;
    property GDICanvas   : TCanvas         read GetGDICanvas;
    property D2DCanvas   : TDirect2DCanvas read FD2DCanvas;

    property OnPaint       : TNotifyEvent read FOnPaint    write FOnPaint;
    property OnGameChanged : TGameChanged read FGameChange write FGameChange;
    property BlockBoard    : Boolean      read FBlockTable write FBlockTable;
    property OnNewMove     : TNewMove     read FOnNewMove  write FOnNewMove;

    procedure Flip;
    procedure StartReplay;

    procedure Perform(Move : TSimpleChessMove);
    procedure DispatchMove(Move : TSimpleChessMove);
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
    property DoubleBuffered default True;
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
const
  TGameTurn : set of TGameState = [gsWhiteToMove, gsBlackToMove];
implementation
uses
  Windows,
  PromotionForm,
  ChessClient,
  ChessMessages,
  Winapi.D2D1;

procedure Register;
begin
  RegisterComponents('ChessComponents', [TChessBoard]);
end;

constructor TChessBoard.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FD2DCanvas   := nil;
  FDragPiece   := nil;
  FMap         := TDictionary<TChessCoordinate, TPoint>.Create;
  FDragging    := False;
  FWhiteTurn   := True;
  FMoves       := 0;
  FFirstMove   := True;
  FState       := gsNone;
  FFlipped     := False;
  FReplayIndex := 0;

  New(FGame);
  FAvailableMoves := TList<TChessCoordinate>.Create;
  FHasPromoted    := False;
  FBlockTable     := False;
  FReplaying      := False;
  FFirstMap       := True;

  FReplayTimer          := TTimer.Create(Self);
  FReplayTimer.Interval := 1000;
  FReplayTimer.OnTimer  := OnReplayTimer;
  FReplayTimer.Enabled  := False;
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
  SquarePoint   : TPoint;
begin
  if FUseD2D then
  begin
    if FFlipped then
    begin
      clLastColor := clBlue;
      FD2DCanvas.Brush.Color := clBlue;
    end
    else
    begin
      clLastColor := clSkyBlue;
      FD2DCanvas.Brush.Color := clSkyBlue;
    end;

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

        SquarePoint.Y := nY;
        SquarePoint.X := nX;

        if ((FMap[FWhiteKing.Position] = SquarePoint) and (FState = gsWhiteInCheck)) or
           ((FMap[FBlackKing.Position] = SquarePoint) and (FState = gsBlackInCheck)) then
          Brush.Color := clRed;

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

      for I := 0 to FAvailableMoves.Count - 1 do
      begin
        SquarePoint := FMap[FAvailableMoves[I]];
        SquarePoint.X := SquarePoint.X + 50;
        SquarePoint.Y := SquarePoint.Y + 50;
        var Circle : TD2D1Ellipse;
        Circle.point   := SquarePoint;
        Circle.radiusX := 25;
        Circle.radiusY := 25;

        FD2DCanvas.Brush.Color := clLime;
        FD2DCanvas.Pen.Color := clLime;
        DrawEllipse(Circle);
        FillEllipse(Circle);
      end;
    end;
    PaintPieces;
    if Assigned(FOnPaint) then
      OnPaint(Self);
  end;
end;

procedure TChessBoard.PaintPieces;
var
  Point : TPoint;
  Piece : TChessPiece;
  R     : Integer;
  C     : Integer;
begin
  if FUseD2D then
  begin
    for R := 1 to 8 do
    for C := 1 to 8 do
    begin
      Point := FMap[TBoard[C][R]];
      if FReplaying
        then Piece := FGame.History[FReplayIndex][C][R]
        else Piece := FGame.Board[C][R];

      if Piece <> nil then
      begin
        if not Piece.Dragging
          then FD2DCanvas.Draw(Point.X, Point.Y, Piece)
          else FD2DCanvas.Draw(Piece.DragPos.X,Piece.DragPos.Y, Piece);
      end;
    end;
  end;
end;

procedure TChessBoard.CreateChessPieces;
var
  nIndex : Integer;
  bWhite : Boolean;
  nPos   : Integer;
begin
  for var I := Low(FPieces) to High(FPieces) do
  begin
    FPieces[I].Free;
  end;

  FPieces[1] := TKing.Create(True);
  FPieces[2] := TKing.Create(False);

  FWhiteKing := FPieces[1];
  FBlackKing := FPieces[2];

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
  nPos   := 9;
  for nIndex := 17 to 32 do
  begin
    FPieces[nIndex] := TPawn.Create(bWhite);
    FPieces[nIndex].InitialPos := TChessCoordinate(nPos);
    Inc(nPos);
    if nIndex = 24 then
      begin
        bWhite := not bWhite;
        nPos   := 49;
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

  if FFlipped then
  begin
    X := 0;
    Y := 0;
    for I := 1 to 64 do
    begin
      FMap.Add(TChessCoordinate(I), Point(X,Y));
      if (I mod 8 <> 0) then
      begin
        X := X + nSquareHeight;
      end
      else
      begin
        X := 0;
        Y := Y + nSquareHeight;
      end;
    end;
  end
  else begin
    X := 0;
    Y := Height - nSquareHeight;
    for I := 1 to 64 do
    begin
      FMap.Add(TChessCoordinate(I), Point(X,Y));
      if I mod 8 <> 0 then
      begin
        X := X + nSquareHeight;
      end
      else
      begin
        X := 0;
        Y := Y - nSquareHeight;
      end;
    end;
  end;

end;

procedure TChessBoard.MapBoard;
var
  I : Integer;
  P : TChessPiece;
begin
  for I := 1 to 64 do
  begin
    FGame.Board[GetColumn(TChessCoordinate(I))][GetRow(TChessCoordinate(I))] := nil;
    for P in FPieces do
    begin
      if (P.Position = TChessCoordinate(I)) and (not P.Captured) then
      begin
        FGame.Board[GetColumn(P.Position)][GetRow(P.Position)] := P;
      end
    end;
  end;
  if FFirstMap then
  begin
    AddSnap(FGame);
    SetLightBoard(FGame);
    FFirstMap := False;
  end;
end;

function TChessBoard.GetPiece(const Position : TChessCoordinate; var ChessPiece : TChessPiece) : Boolean;
begin
  ChessPiece := FGame.Board[GetColumn(Position)][GetRow(Position)];
  Result     := ChessPiece <> nil;
end;

function TChessBoard.CheckMove(const A, B : TChessCoordinate; ChessPiece : TChessPiece;
                               var ACapture : TChessPiece; bJustPeek : Boolean) : Boolean;
var
  Piece : TChessPiece;
begin
  Result   := True;
  ACapture := nil;

  if not (ChessPiece is TKnight) then
  begin
    Result := CheckObstacles(A,B, ChessPiece.White);
  end;

  if Result and GetPiece(B, Piece) then
  begin
    Result := Piece.White <> ChessPiece.White;
    if Result and not bJustPeek then Piece.Captured := True;
    ACapture := Piece;
  end;
end;

function TChessBoard.CheckObstacles(const A, B : TChessCoordinate; bWhite : Boolean) : Boolean;
var
  ARow,BRow        : Integer;
  AColumn, BColumn : Integer;
  bSameRow         : Boolean;
  bSameColumn      : Boolean;
  bDiagonal        : Boolean;
  bUpWards         : Boolean;
  bRightWards      : Boolean;
  I                : Integer;
  I2               : Integer;
  Piece            : TChessPiece;
  bBlocked         : Boolean;
begin
  ARow := GetRow(A);
  BRow := GetRow(B);

  AColumn := GetColumn(A);
  BColumn := GetColumn(B);

  bSameRow    := ARow = BRow;
  bSameColumn := AColumn = BColumn;
  bDiagonal   := (not bSameRow) and (not bSameColumn) and IsOnSameDiagonal(A, B);

  bUpWards    := ARow < BRow;
  bRightWards := AColumn < BColumn;
  Result      := True;

  I := ARow;
  I2:= AColumn;

  bBlocked := False;
  if (bDiagonal) then
  begin
    if bRightWards then
    begin
      if bUpWards then
      begin
        repeat
          Inc(I);
          Inc(I2);
          Piece := FGame.Board[I2][I];
          if (I = BRow) and (I2 = BColumn)
            then Result := Result and ((Piece = nil) or ((Piece <> nil) and (Piece.White <> bWhite)))
            else Result := Result and  (Piece = nil);

        until (I = BRow) and (I2 = BColumn) or not Result;
      end
      else
      begin
        repeat
          Inc(I2);
          Dec(I);
          Piece := FGame.Board[I2][I];
          if (I = BRow) and (I2 = BColumn)
            then Result := Result and (Piece = nil) or ((Piece <> nil) and (Piece.White <> bWhite))
            else Result := Result and (Piece = nil);
        until (I = BRow) and (I2 = BColumn) or not Result;
      end;
    end
    else
    begin
      if bUpWards then
      begin
        repeat
          Inc(I);
          Dec(I2);
          Piece := FGame.Board[I2][I];
          if (I = BRow) and (I2 = BColumn)
            then Result := Result and (Piece = nil) or ((Piece <> nil) and (Piece.White <> bWhite))
            else Result := Result and (Piece = nil);

        until (I = BRow) and (I2 = BColumn) or not Result;
      end
      else
      begin
        repeat
          Dec(I2);
          Dec(I);
          Piece := FGame.Board[I2][I];
          if (I = BRow) and (I2 = BColumn)
            then Result := Result and (Piece = nil) or ((Piece <> nil) and (Piece.White <> bWhite))
            else Result := Result and (Piece = nil);

        until (I = BRow) and (I2 = BColumn) or not Result;
      end;
    end;

  end
  else if (bSameRow) then
  begin
    if AColumn > BColumn then
    for I := BColumn to AColumn do
    begin
      if (I <> AColumn) then
      begin
        Piece := FGame.Board[I][ARow];
        if I = BColumn then
          begin
            if (Piece <> nil) and (Piece.White <> bWhite) then
            begin
              if bBlocked then
                Result := False;
              bBlocked := True;
            end;

          end
        else Result := Result and (Piece = nil) and (not bBlocked);
      end;
    end
    else begin
      for I := AColumn to BColumn do
      begin
        if (I <> AColumn) then
        begin
          Piece := FGame.Board[I][ARow];
          if I = BColumn then
          begin
            if (Piece <> nil) and (Piece.White <> bWhite) then
            begin
              if bBlocked then
                Result := False;
              bBlocked := True;
            end;
          end
          else Result := Result and (Piece = nil) and (not bBlocked);
        end;
      end
    end;
  end
  else
  begin
    if ARow > BRow then
    for I := BRow to ARow do
    begin
      if (I <> ARow) then
      begin
        Piece := FGame.Board[AColumn][I];
        if I = BRow
          then Result := Result and ((Piece = nil) or ((Piece <> nil) and (Piece.White <> bWhite)))
          else Result := Result and (Piece = nil);
      end;
    end
    else begin
      for I := ARow to BRow do
      begin
        if (I <> ARow) then
        begin
          Piece := FGame.Board[AColumn][I];
          if I = BRow
            then Result := Result and ((Piece = nil) or ((Piece <> nil) and (Piece.White <> bWhite)))
            else Result := Result and (Piece = nil);
        end;
      end
    end;
  end
end;

function TChessBoard.MapFromPoint(const X: Integer; const Y: Integer; var Coordinate : TChessCoordinate): Boolean;
var
  nSquareHeight : Integer;
  nSquareWidth  : Integer;
  Row           : Integer;
  Column        : Integer;
begin
  nSquareHeight := Height div 8;
  nSquareWidth  := Width  div 8;
  if FFlipped then
  begin
    if (X < 0) or (X > Width) or (Y > Height) or (Y < 0) then
    begin
      Result     := False;
      Coordinate := a1;
    end
    else
    begin
      Column := X div nSquareWidth;
      Row    := Y div nSquareHeight;

      Coordinate := MapFromRowColumn(Row, Column);
      Result     := True;
    end;
  end
  else begin
    if (X < 0) or (X > Width) or (Y > Height) or (Y < 0) then
    begin
      Result     := False;
      Coordinate := a1;
    end
    else
    begin
      Column := X div nSquareWidth;
      Row    := (Height - Y) div nSquareHeight;

      Coordinate := MapFromRowColumn(Row, Column);
      Result     := True;
    end;
  end;
end;

procedure TChessBoard.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FDragPiece) then
  begin
    FDragPiece.X := X - FDragPiece.Width div 2;
    FDragPiece.Y := Y - FDragPiece.Height div 2;
    Invalidate;
  end;
end;

function TChessBoard.Castles(const A : TChessCoordinate; Piece : TChessPiece) : Boolean;
var
  Move : TSimpleChessMove;
begin
  Result := False;
  if (Piece is TKing) and (not Piece.Moved) then
  begin
    if FWhiteTurn then
    begin
       if A = c1 then
       begin
         var Rook : TChessPiece;
         if GetPiece(a1, Rook) and not Rook.Moved and CanCastle(Piece, True) then
         begin
           (Rook as TRook).LongCastle;
           (Piece as TKing).LongCastle;
            Result := True;
            MapBoard;
            if KingInCheck(FWhiteTurn) then
            begin
              Piece.Undo;
              Rook.Undo;
              MapBoard;
            end
            else begin
              FWhiteTurn := not FWhiteTurn;
              Inc(FMoves);
              AddSnap(FGame);
              SetLightBoard(FGame);

              Move.Piece := WHITE_KING;
              Move.From  := e1;
              Move.Move  := c1;

              if Assigned(FOnNewMove) then
                FOnNewMove(Move);

              DispatchMove(Move);
            end;
         end;
       end
       else if A = g1 then
       begin
         var Rook : TChessPiece;
         if GetPiece(h1, Rook) and not Rook.Moved and CanCastle(Piece, False) then
         begin
           (Rook as TRook).ShortCastle;
           (Piece as TKing).ShortCastle;
            Result := True;
            MapBoard;
            if KingInCheck(FWhiteTurn) then
            begin
              Piece.Undo;
              Rook.Undo;
              MapBoard;
            end
            else begin
              FWhiteTurn := not FWhiteTurn;
              Inc(FMoves);
              AddSnap(FGame);
              SetLightBoard(FGame);

              Move.Piece := WHITE_KING;
              Move.From  := e1;
              Move.Move  := g1;

              if Assigned(FOnNewMove) then
                FOnNewMove(Move);

              DispatchMove(Move);
            end;
         end;
       end;
    end
    else
    begin
      if A = c8 then
      begin
        var Rook : TChessPiece;
        if GetPiece(a8, Rook) and not Rook.Moved and CanCastle(Piece, True) then
        begin
          (Rook as TRook).LongCastle;
          (Piece as TKing).LongCastle;
          Result := True;
          MapBoard;
          if KingInCheck(FWhiteTurn) then
          begin
            Piece.Undo;
            Rook.Undo;
            MapBoard;
          end
          else begin
            FWhiteTurn := not FWhiteTurn;
            Inc(FMoves);
            AddSnap(FGame);
            SetLightBoard(FGame);

            Move.Piece := BLACK_KING;
            Move.From  := e8;
            Move.Move  := c8;

            if Assigned(FOnNewMove) then
              FOnNewMove(Move);

            DispatchMove(Move);
          end;
        end;
      end
      else if A = g8 then
      begin
        var Rook : TChessPiece;
        if GetPiece(h8, Rook) and not Rook.Moved and CanCastle(Piece, False) then
        begin
          (Rook as TRook).ShortCastle;
          (Piece as TKing).ShortCastle;
           Result := True;
           MapBoard;
           if KingInCheck(FWhiteTurn) then
           begin
             Piece.Undo;
             Rook.Undo;
             MapBoard;
           end
           else begin
             FWhiteTurn := not FWhiteTurn;
             Inc(FMoves);
             AddSnap(FGame);
             SetLightBoard(FGame);

             Move.Piece := BLACK_KING;
             Move.From  := e8;
             Move.Move  := g8;

             if Assigned(FOnNewMove) then
               FOnNewMove(Move);

             DispatchMove(Move);
           end;
        end;
      end;
    end;
  end;
end;

procedure TChessBoard.CheckKings;
begin
  if IsSquareAttacked(FWhiteKing.Position, False) then
    FState := gsWhiteInCheck
  else if IsSquareAttacked(FBlackKing.Position, True) then
    FState := gsBlackInCheck
end;

function TChessBoard.EnPassant(const A : TChessCoordinate; Piece : TChessPiece) : Boolean;
var
  TRow   : Integer; // Target Row
  TColumn: Integer; // Target Column;
  Target : TChessPiece;
  Move   : TSimpleChessMove;
begin
  Result := False;
  if Piece is TPawn then
  begin
    TRow   := GetRow(Piece.Position);
    TColumn:= GetColumn(A);
    // Is the pawn moving diagonally?
    if not Piece.CanMove(A, False) and Piece.CanMove(A, True)  then
    begin
      if GetPiece(TBoard[TColumn, TRow], Target) then
      begin
        if Target.White <> Piece.White then
        begin
          if Target.EnPassant then
          begin
            Piece.Move(A, True);
            Target.Captured := True;
            MapBoard;
            if KingInCheck(FWhiteTurn) then
            begin
              Piece.Undo;
              Target.Captured := False;
              MapBoard;
            end
            else begin
              FWhiteTurn := not FWhiteTurn;
              Inc(FMoves);
              AddSnap(FGame);
              SetLightBoard(FGame);

              Move.Piece := Piece.Name;
              Move.Move  := A;
              Move.From  := Piece.LastPos;

              if Assigned(FOnNewMove) then
                FOnNewMove(Move);

              DispatchMove(Move);
            end;
            Result := True;
          end;
        end;
      end;
    end;
  end;
end;

function TChessBoard.KingInCheck(bWhite : Boolean) : Boolean;
begin
  if bWhite
    then Result := IsSquareAttacked(FWhiteKing.Position, False)
    else Result := IsSquareAttacked(FBlackKing.Position, True);
end;

function TChessBoard.GetAvailableMoves(Piece : TChessPiece) : Boolean;
var
  I        : Integer;
  Captured : TChessPiece;
  bCapture : Boolean;
begin
  FAvailableMoves.Clear;
  Result := False;
  if not (Piece is TKing) then
  begin
    for I := 1 to 64 do
    begin
      if TChessCoordinate(I) <> Piece.Position then
      begin
        var Coordinate : TChessCoordinate;
        Coordinate := TChessCoordinate(I);
        bCapture   := False;
        if GetPiece(Coordinate, Captured) then
          bCapture := True;

        if Piece.CanMove(Coordinate, bCapture) then
        begin
          if CheckMove(Piece.Position, Coordinate, Piece, Captured) and
             Piece.Move(Coordinate, bCapture)  then
          begin
            MapBoard;
            if not KingInCheck(Piece.White) then
            begin
              FAvailableMoves.Add(Coordinate);
              Result := True;
            end;
            Piece.Undo;
            if Captured <> nil then
              Captured.Captured := False;
            MapBoard;
          end;
        end;
      end;
    end;
  end
  else begin
    for I := 1 to 64 do
    begin
      if TChessCoordinate(I) <> Piece.Position then
      begin
        var Coordinate : TChessCoordinate;
        Coordinate := TChessCoordinate(I);
        bCapture   := False;
        if GetPiece(Coordinate,  Captured) then
          bCapture := True;

        if Piece.CanMove(Coordinate, bCapture) then
        begin
          if CheckMove(Piece.Position, Coordinate, Piece, Captured) and
             Piece.Move(Coordinate, bCapture)  then
          begin
            MapBoard;
            if not KingInCheck(Piece.White) then
            begin
              FAvailableMoves.Add(Coordinate);
              Result := True;
            end;
            Piece.Undo;
            if Captured <> nil then
              Captured.Captured := False;
            MapBoard;
          end;
        end;
      end;
    end;
  end;

end;

function TChessBoard.CheckForMate(bWhite : Boolean) : Boolean;
var
  Piece : TChessPiece;
begin
  Result := False;
  for Piece in FPieces do
  if (Piece.White = bWhite) and (not Piece.Captured) then
    Result := Result or GetAvailableMoves(Piece);
end;

function TChessBoard.Promote(Piece : TChessPiece) : Boolean;
var
  PromotedPiece : TChessPiece;
begin
  Result := True;
  if (Piece is TPawn) and (((Piece.White) and (GetRow(Piece.Position) = 8)) or
    ((not Piece.White) and (GetRow(Piece.Position) = 1)))  then
  begin
    Result := False;
    with TPromotion.Create(Self) do
    begin
      ConfigureForm(Piece.White);
      Left := Mouse.CursorPos.X;
      Top  := Mouse.CursorPos.Y;
      ShowModal;
      if ModalResult = mrOk then
      begin
        FHasPromoted := True;
        PromotedPiece:= SelectedPiece;
        PromotedPiece.InitialPos := Piece.Position;
        for var I := Low(FPieces) to High(FPieces) do
        begin
          if FPieces[I] = Piece then
          begin
            FPieces[I] := PromotedPiece;
            Break;
          end;

        end;
        Piece.Free;
        Result := True;
      end;
      Free;
    end;
  end;
end;

procedure TChessBoard.Flip;
begin
  FFlipped := not FFlipped;
  MapCoordinates;
  Invalidate;
end;
procedure TChessBoard.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Coordinate : TChessCoordinate;
  Piece      : TChessPiece;
  Captured   : TChessPiece;
  bCapture   : Boolean;
  Move       : TSimpleChessMove;
begin
  if FDragging and Assigned(FDragPiece) and (Button = mbLeft) then
  begin
    bCapture := False;
    FDragPiece.Dragging := False;
    if MapFromPoint(X, Y, Coordinate) then
    begin
      // Check if there is a piece in the destination square
      if GetPiece(Coordinate, Piece) then
        bCapture := True;

      // Check for castles, the game turn and the piece standard moveset
      if (not Castles(Coordinate, FDragPiece)) and (not EnPassant(Coordinate, FDragPiece))
         and (FWhiteTurn xor (not FDragPiece.White)) and
          FDragPiece.CanMove(Coordinate, bCapture) then
      begin
        // Check for the move in the context of the actual board (Obstacles and Captures)
        if CheckMove(FDragPiece.Position, Coordinate, FDragPiece, Captured) and
           FDragPiece.Move(Coordinate, bCapture)  then
        begin
          MapBoard;
          if KingInCheck(FWhiteTurn) then
          begin
            // Illegal move (puts/maintains self in check), Undo and ReMaps
            FDragPiece.Undo;
            MapBoard;
            if (Captured <> nil) then
              Captured.Captured := False;
          end
          // Valid move, Continues
          else if Promote(FDragPiece) then
          begin
            if not FWhiteTurn
              then FState := gsWhiteToMove
              else FState := gsBlackToMove;
            // If not in checkmate/stalemate, check if a king is in check and updates the state
            if not CheckForMate(not FWhiteTurn) then
            begin
              if (not FWhiteTurn) and
                IsSquareAttacked(FWhiteKing.Position, not FWhiteTurn) then
                FState := gsWhiteWinsOnMate
              else if (not FWhiteTurn) then
                FState := gsDrawStaleMate
              else if (FWhiteTurn) and
                IsSquareAttacked(FBlackKing.Position, FWhiteTurn) then
                FState := gsBlackWinsOnMate
              else
                FState := gsDrawStaleMate;
            end
            else CheckKings;

            FWhiteTurn := not FWhiteTurn;
            Inc(FMoves);
            FFirstMove := False;
            AddSnap(FGame);
            SetLightBoard(FGame);

            Move.Piece := FDragPiece.Name;
            Move.Move  := Coordinate;
            Move.From  := FDragPiece.LastPos;

            if Assigned(FOnNewMove) then
              FOnNewMove(Move);
            DispatchMove(Move);
          end
          else begin
            // Cancel Promotion, Undo and ReMaps
            FDragPiece.Undo;
            MapBoard;
            if (Captured <> nil) then
              Captured.Captured := False;
          end;
        end;
      end;
    end;
    FDragging  := False;
    FDragPiece := nil;
    FAvailableMoves.Clear;
    if Assigned(FGameChange) then
      FGameChange(FState);
    Invalidate;
  end;
  inherited;
  // Game ended, block inputs
  if FState > gsBlackInCheck then FBlockTable := True;
end;

procedure TChessBoard.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Coordinate : TChessCoordinate;
  Piece      : TChessPiece;
begin
  if MapFromPoint(X,Y,Coordinate) and (Button = mbLeft) and (not FBlockTable) then
  begin
    IsSquareAttacked(Coordinate, True);
    if GetPiece(Coordinate, Piece) then
    begin
      FDragging := True;
      FDragPiece := Piece;
      FDragPiece.Dragging := True;
      FDragPiece.X := X - FDragPiece.Width div 2;
      FDragPiece.Y := Y - FDragPiece.Height div 2;
      if GetAvailableMoves(FDragPiece) then Invalidate;
    end
    else
    begin
      FDragging  := False;
      FDragPiece := nil;
    end;
  end
  else
  begin
    if Assigned(FDragPiece)then
      FDragPiece.Dragging := False;

    FDragging  := False;
    FDragPiece := nil;
  end;
  inherited;
end;

procedure TChessBoard.Reset;
var
  Piece : TChessPiece;
begin
  if not FHasPromoted then
  begin
    for Piece in FPieces do
      Piece.Reset;
  end
  else CreateChessPieces;

  Dispose(FGame);
  New(FGame);

  FFirstMap := True;
  MapBoard;

  FWhiteTurn := True;
  FFirstMove := True;
  FMoves     := 0;
  FState     := gsNone;
  FAvailableMoves.Clear;

  if Assigned(FGameChange) then
    FGameChange(FState);

  FBlockTable := False;
  Invalidate;
end;

procedure TChessBoard.Start;
begin
  FWhiteTurn := True;
  FState := gsWhiteToMove;
  FBlockTable := False;
  if Assigned(FGameChange) then
    FGameChange(FState);
end;

function TChessBoard.CanCastle(Piece : TChessPiece; Long : Boolean) : Boolean;
var
  Point  : TChessPiece;
  WhiteL : TSpecialSquares;
  WhiteS : TSpecialSquares;
  BlackL : TSpecialSquares;
  BlackS : TSpecialSquares;
  I      : TChessCoordinate;
begin
  Result := True;

  WhiteL := [b1, c1, d1];
  WhiteS := [f1, g1];
  BlackL := [b8, c8, d8];
  BlackS := [f8, g8];

  if (Piece is TKing) then
  begin
    if Piece.White then
    begin
      if Long then
      begin
        for I in WhiteL do
        begin
          Point  := FGame.Board[GetColumn(I)][GetRow(I)];
          Result := Result and (Point = nil);

          Result := Result and not IsSquareAttacked(I, False);
        end;
      end
      else begin
        for I in WhiteS do
        begin
          Point  := FGame.Board[GetColumn(I)][GetRow(I)];
          Result := Result and (Point = nil);

          Result := Result and not IsSquareAttacked(I, False);
        end;
      end;
    end
    else begin
      if Long then
      begin
        for I in BlackL do
        begin
          Point  := FGame.Board[GetColumn(I)][GetRow(I)];
          Result := Result and (Point = nil);

          Result := Result and not IsSquareAttacked(I, True);
        end;
      end
      else begin
        for I in BlackS do
        begin
          Point  := FGame.Board[GetColumn(I)][GetRow(I)];
          Result := Result and (Point = nil);

          Result := Result and not IsSquareAttacked(I, True);
        end;
      end;
    end;
  end;
end;

function TChessBoard.IsSquareAttacked (Square : TChessCoordinate; ByWhite : Boolean) : Boolean;
var
  ARow, AColumn : Integer;
  I             : Integer;
  Piece         : TChessPiece;
  R, C          : Integer;
begin
  ARow    := GetRow(Square);
  AColumn := GetColumn(Square);
  Result  := False;

  // Check Row
  for I := 1 to 8 do
  begin
    if (I <> AColumn) then
    begin
      Piece := FGame.Board[I][ARow];

      if (Piece = nil) then
        Continue;

      if I < AColumn then
      begin
        Result := Result or Piece.White = ByWhite;
        // Is Protected
        if ((not (Piece is TRook)) and (not (Piece is TQueen))
            or (Piece.White <> ByWhite)) then
          Result := False;
      end;

      if I > AColumn then
      begin
        // Is Protected
        if (not Result) and ((not (Piece is TRook)) and (not (Piece is TQueen))
            or (Piece.White <> ByWhite)) then
        begin
          Result := False;
          Break;
        end;
        Result := Result or (Piece.White = ByWhite);
      end;

    end;
  end;

  // Check Columns
  if not Result then
  begin
    for I := 1 to 8 do
    begin
      if (I <> ARow) then
      begin
        Piece := FGame.Board[AColumn][I];
        if (Piece = nil) then
          Continue;

        if I < ARow then
        begin
          Result := Result or Piece.White = ByWhite;
          // Is Protected
          if ((not (Piece is TRook)) and (not (Piece is TQueen))
               or (Piece.White <> ByWhite)) then
            Result := False;
        end;

        if I > ARow then
        begin
          // Is Protected
          if (not Result) and ((not (Piece is TRook)) and (not (Piece is TQueen))
            or (Piece.White <> ByWhite)) then
          begin
            Result := False;
            Break;
          end;

          Result := Result or (Piece.White = ByWhite);
        end;
      end;
    end;
  end;

  // Check Left Up Diagonal
  if not Result then
  begin
    R := ARow;
    C := AColumn;
    repeat
      // Traverses until board ends
      if R < 8 then Inc(R);
      if C > 1 then Dec(C);

      Piece := FGame.Board[C][R];
      if (Piece <> nil) then
      begin
        // Is Protected
        if (not Result) and ((not (Piece is TBishop)) and (not (Piece is TQueen))
            or (Piece.White <> ByWhite)) then
        begin
          Result := False;
          Break;
        end;

        if ((Piece is TBishop) or (Piece is TQueen)) then
          Result := Result or (Piece.White = ByWhite);
      end;
    until (R = 8) or (C = 1);
  end;

  // Check Left Down Diagonal
  if not Result then
  begin
    R := ARow;
    C := AColumn;
    repeat
      // Traverses until board ends
      if R > 1 then Dec(R);
      if C > 1 then Dec(C);

      Piece := FGame.Board[C][R];

      if (Piece <> nil) then
      begin
        // Is Protected
        if (not Result) and ((not (Piece is TBishop)) and (not (Piece is TQueen))
            or (Piece.White <> ByWhite)) then
        begin
          Result := False;
          Break;
        end;
        if ((Piece is TBishop) or (Piece is TQueen)) then
          Result := Result or (Piece.White = ByWhite);
      end;
    until (R = 1) or (C = 1);
  end;

  // Check Right Up Diagonal
  if not Result then
  begin
    R := ARow;
    C := AColumn;
    repeat
      // Traverses until board ends
      if R < 8 then Inc(R);
      if C < 8 then Inc(C);

      Piece := FGame.Board[C][R];

      if (Piece <> nil) then
      begin
        // Is Protected
        if (not Result) and ((not (Piece is TBishop)) and (not (Piece is TQueen))
            or (Piece.White <> ByWhite)) then
        begin
          Result := False;
          Break;
        end;
        if ((Piece is TBishop) or (Piece is TQueen)) then
          Result := Result or (Piece.White = ByWhite);
      end;
    until (R = 8) or (C = 8);
  end;
  // Check Right Down Diagonal
  if not Result then
  begin
    R := ARow;
    C := AColumn;
    repeat
      // Traverses until board ends
      if R > 1 then Dec(R);
      if C < 8 then Inc(C);

      Piece := FGame.Board[C][R];

      if (Piece <> nil) then
      begin
        // Is Protected
        if (not Result) and ((not (Piece is TBishop)) and (not (Piece is TQueen))
            or (Piece.White <> ByWhite)) then
        begin
          Result := False;
          Break;
        end;
        if ((Piece is TBishop) or (Piece is TQueen)) then
          Result := Result or (Piece.White = ByWhite);
      end;
    until (R = 1) or (C = 8);
  end;

  // Check Poneys
  if not Result then
  begin
    R := ARow;
    C := AColumn;

    if R + 2 <= 8 then
    begin
      if C + 1 <= 8 then
      begin
        Piece := FGame.Board[C + 1][R + 2];
        if (Piece <> nil) and (Piece is TKnight) and (Piece.White = ByWhite) then
        begin
          Result := True;
          exit;
        end;
      end;

      if C - 1 >= 1 then
      begin
        Piece := FGame.Board[C - 1][R + 2];
        if (Piece <> nil) and (Piece is TKnight) and (Piece.White = ByWhite) then
        begin
          Result := True;
          exit;
        end;
      end;
    end;

    if R - 2 >= 1 then
    begin
      if C + 1 <= 8 then
      begin
        Piece := FGame.Board[C + 1][R - 2];
        if (Piece <> nil) and (Piece is TKnight) and (Piece.White = ByWhite) then
        begin
          Result := True;
          exit
        end;
      end;

      if C - 1 >= 1 then
      begin
        Piece := FGame.Board[C - 1][R - 2];
        if (Piece <> nil) and (Piece is TKnight) and (Piece.White = ByWhite) then
        begin
          Result := True;
          exit
        end;
      end;
    end;

    if C + 2 <= 8 then
    begin
      if R + 1 <= 8 then
      begin
        Piece := FGame.Board[C + 2][R + 1];
        if (Piece <> nil) and (Piece is TKnight) and (Piece.White = ByWhite) then
        begin
          Result := True;
          exit
        end;
      end;

      if R - 1 >= 1 then
      begin
        Piece := FGame.Board[C + 2][R - 1];
        if (Piece <> nil) and (Piece is TKnight) and (Piece.White = ByWhite) then
        begin
          Result := True;
          exit
        end;
      end;
    end;

    if C - 2 >= 1 then
    begin
      if R + 1 <= 8 then
      begin
        Piece := FGame.Board[C - 2][R + 1];
        if (Piece <> nil) and (Piece is TKnight) and (Piece.White = ByWhite) then
        begin
          Result := True;
          exit
        end;
      end;

      if R - 1 >= 1 then
      begin
        Piece := FGame.Board[C - 2][R - 1];
        if (Piece <> nil) and (Piece is TKnight) and (Piece.White = ByWhite) then
        begin
          Result := True;
          exit
        end;
      end;
    end

  end;
  // Check Pawns
  if not Result then
  begin
    R := ARow;
    C := AColumn;
    if ByWhite then
    begin
      if (C - 1 >= 1) and (R - 1 >= 1) then
      begin
        Piece := FGame.Board[C - 1][R - 1];
        if (Piece <> nil) and (Piece is TPawn) and (Piece.White) then
        begin
          Result := True;
          exit
        end;
      end;
      if (C + 1 <= 8) and (R - 1 >= 1) then
      begin
        Piece := FGame.Board[C + 1][R - 1];
        if (Piece <> nil) and (Piece is TPawn) and (Piece.White) then
        begin
          Result := True;
          exit
        end;
      end;
    end
    else
    begin
      if (C + 1 <= 8) and (R - 1 >= 1) then
      begin
        Piece := FGame.Board[C + 1][R - 1];
        if (Piece <> nil) and (Piece is TPawn) and (not Piece.White) then
        begin
          Result := True;
          exit
        end;
      end;
      if (C + 1 <= 8) and (R + 1 >= 1) then
      begin
        Piece := FGame.Board[C + 1][R + 1];
        if (Piece <> nil) and (Piece is TPawn) and (not Piece.White) then
        begin
          Result := True;
          exit
        end;
      end;
    end;
  end;
  // Check Kings
  if not Result then
  begin
    if ByWhite then
    begin
      R := GetRow(FWhiteKing.Position);
      C := GetColumn(FWhiteKing.Position);
    end
    else
    begin
      R := GetRow(FBlackKing.Position);
      C := GetColumn(FBlackKing.Position);
    end;
    Result := (Abs(R - ARow) <= 1) and (Abs(C - AColumn) <= 1);
  end;
end;

procedure TChessBoard.OnReplayTimer(Sender : TObject);
begin
  if Length(FGame.History) > 0 then
  begin
    if FReplayIndex < Length(FGame.History) - 1  then
    begin
      Inc(FReplayIndex);
    end
    else begin
      FReplayTimer.Enabled := False;
      FReplaying := False;
    end;
  end
  else begin
    FReplayTimer.Enabled := False;
    FReplaying := False;
  end;
  Invalidate;
end;

procedure TChessBoard.StartReplay;
begin
  FBlockTable := True;
  if Length(FGame.History) > 0 then
  begin
    FReplayIndex := 0;
    FReplayTimer.Enabled :=True;
    FReplaying := True;
    SetLightBoard(FGame);
  end;
  Invalidate;
end;

procedure TChessBoard.Perform(Move : TSimpleChessMove);
var
  Coordinate : TChessCoordinate;
  Piece      : TChessPiece;
  MovePiece  : TChessPiece;
  Captured   : TChessPiece;
  bCapture   : Boolean;
  I          : Integer;
begin
  bCapture := False;
  MovePiece:= nil;
  for I := Low(FPieces) to High(FPieces) do
  begin
    if (FPieces[I].Name = Move.Piece) and  (Move.From = FPieces[I].Position)then
    begin
      MovePiece := FPieces[I];
      Break;
    end;
  end;

  Coordinate := Move.Move;

  // Check if there is a piece in the destination square
  if GetPiece(Coordinate, Piece) then
    bCapture := True;

  // Check for castles, the game turn and the piece standard moveset
  if (MovePiece <> nil) and (not Castles(Coordinate, MovePiece)) and (not EnPassant(Coordinate, MovePiece))
     and (FWhiteTurn xor (not MovePiece.White)) and
      MovePiece.CanMove(Coordinate, bCapture) then
  begin
    // Check for the move in the context of the actual board (Obstacles and Captures)
    if CheckMove(MovePiece.Position, Coordinate, MovePiece, Captured) and
       MovePiece.Move(Coordinate, bCapture)  then
    begin
      MapBoard;
      if KingInCheck(FWhiteTurn) then
      begin
        // Illegal move (puts/maintains self in check), Undo and ReMaps
        MovePiece.Undo;
        MapBoard;
        if (Captured <> nil) then
          Captured.Captured := False;
      end
      // Valid move, Continues
      else if Promote(MovePiece) then
      begin
        if not FWhiteTurn
          then FState := gsWhiteToMove
          else FState := gsBlackToMove;
        // If not in checkmate/stalemate, check if a king is in check and updates the state
        if not CheckForMate(not FWhiteTurn) then
        begin
          if (not FWhiteTurn) and
            IsSquareAttacked(FWhiteKing.Position, not FWhiteTurn) then
            FState := gsWhiteWinsOnMate
          else if (not FWhiteTurn) then
            FState := gsDrawStaleMate
          else if (FWhiteTurn) and
            IsSquareAttacked(FBlackKing.Position, FWhiteTurn) then
            FState := gsBlackWinsOnMate
          else
            FState := gsDrawStaleMate;
        end
        else CheckKings;

        FWhiteTurn := not FWhiteTurn;
        Inc(FMoves);
        FFirstMove := False;
        AddSnap(FGame);
        SetLightBoard(FGame);
        if Assigned(FOnNewMove) then
          FOnNewMove(Move);
      end
      else begin
        // Cancel Promotion, Undo and ReMaps
        MovePiece.Undo;
        MapBoard;
        if (Captured <> nil) then
          Captured.Captured := False;
      end;
    end;
  end;
  FAvailableMoves.Clear;
  if Assigned(FGameChange) then
    FGameChange(FState);
  Invalidate;

  // Game ended, block inputs
  if FState > gsBlackInCheck then FBlockTable := True;
end;

procedure TChessBoard.DispatchMove(Move : TSimpleChessMove);
var
  PMove : PSimpleChessMove;
begin
  New(PMove);
  PMove^ := Move;
  if g_ChessClient <> nil then
    PostThreadMessage(g_ChessClient.ThreadID, WM_NEW_MOVE, WPARAM(PMove), 0);
end;

function MapFromRowColumn(Row : Integer; Column : Integer) : TChessCoordinate;
begin
  Result := TChessCoordinate(Column + 1 + Row * 8);
end;
end.
