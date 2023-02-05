unit ChessPieces;

interface

uses
  Graphics,
  Types,
  Vcl.Imaging.pngimage;

type
  TChessCoordinate = (a1 = 1, a2 = 9,  a3 = 17, a4 = 25, a5 = 33, a6 = 41, a7 = 49, a8 = 57,
                      b1 = 2, b2 = 10, b3 = 18, b4 = 26, b5 = 34, b6 = 42, b7 = 50, b8 = 58,
                      c1 = 3, c2 = 11, c3 = 19, c4 = 27, c5 = 35, c6 = 43, c7 = 51, c8 = 59,
                      d1 = 4, d2 = 12, d3 = 20, d4 = 28, d5 = 36, d6 = 44, d7 = 52, d8 = 60,
                      e1 = 5, e2 = 13, e3 = 21, e4 = 29, e5 = 37, e6 = 45, e7 = 53, e8 = 61,
                      f1 = 6, f2 = 14, f3 = 22, f4 = 30, f5 = 38, f6 = 46, f7 = 54, f8 = 62,
                      g1 = 7, g2 = 15, g3 = 23, g4 = 31, g5 = 39, g6 = 47, g7 = 55, g8 = 63,
                      h1 = 8, h2 = 16, h3 = 24, h4 = 32, h5 = 40, h6 = 48, h7 = 56, h8 = 64);
  TChessCoordinateHelper = record helper for TChessCoordinate
  function ToString : String;
  end;

  TSpecialSquares = set of TChessCoordinate;

  TChessPieceName = (CHESS_NONE = 0, WHITE_PAWN, BLACK_PAWN, WHITE_KING, BLACK_KING, WHITE_QUEEN,
                     BLACK_QUEEN, WHITE_KNIGHT, BLACK_KNIGHT, WHITE_BISHOP, BLACK_BISHOP,
                     WHITE_ROOK, BLACK_ROOK);
  TChessPieceNameHelper = record helper for TChessPieceName
  function ToString : String;
  end;

  TChessPiece = class(TPngImage)
  protected
    FPosition   : TChessCoordinate;
    FWhite      : Boolean;
    FInitialPos : TChessCoordinate;
    FCaptured   : Boolean;
    FMoved      : Boolean;
    FDragPos    : TPoint;
    FDragging   : Boolean;
    FMoves      : Integer;
    FLastPos    : TChessCoordinate;
    FEnPassant  : Boolean;
    FName       : TChessPieceName;

    procedure SetInitialPosition(APos : TChessCoordinate);
  public
    constructor Create(bWhite : Boolean); virtual;
    function    CanMove(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; virtual; abstract;
    function    Move(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; virtual;
    procedure   Reset;
    procedure   Undo;

    property Name       : TChessPieceName  read FName;
    property Position   : TChessCoordinate read FPosition   write FPosition;
    property White      : Boolean          read FWhite      write FWhite;
    property InitialPos : TChessCoordinate read FInitialPos write SetInitialPosition;
    property Captured   : Boolean          read FCaptured   write FCaptured;
    property Moved      : Boolean          read FMoved;
    property DragPos    : TPoint           read FDragPos    write FDragPos;
    property Dragging   : Boolean          read FDragging   write FDragging;
    property X          : Integer          read FDragPos.X  write FDragPos.X;
    property Y          : Integer          read FDragPos.Y  write FDragPos.Y;
    property LastPos    : TChessCoordinate read FLastPos;
    property EnPassant  : Boolean          read FEnPassant;
  end;

  TKnight = class(TChessPiece)
  public
    constructor Create(bWhite : Boolean); override;
    function CanMove(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; override;
  end;

  TBishop = class(TChessPiece)
  public
    constructor Create(bWhite : Boolean); override;
    function CanMove(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; override;
  end;

  TKing = class(TChessPiece)
  public
    constructor Create(bWhite : Boolean); override;
    function CanMove(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; override;
    procedure LongCastle;
    procedure ShortCastle;
  end;

  TRook = class(TChessPiece)
  public
    constructor Create(bWhite : Boolean); override;
    function CanMove(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; override;
    procedure LongCastle;
    procedure ShortCastle;
  end;

  TQueen = class(TChessPiece)
  public
    constructor Create(bWhite : Boolean); override;
    function CanMove(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; override;
  end;

  TPawn = class(TChessPiece)
  public
    constructor Create(bWhite : Boolean); override;
    function CanMove(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; override;
    function Move(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; override;
  end;

  function IsOnSameRow     (const A : TChessCoordinate; const B : TChessCoordinate) : Boolean; inline;
  function IsOnSameColumn  (const A : TChessCoordinate; const B : TChessCoordinate) : Boolean; inline;
  function IsOnSameDiagonal(const A : TChessCoordinate; const B : TChessCoordinate) : Boolean; inline;
  function GetRow          (const A : TChessCoordinate) : Integer; inline;
  function GetColumn       (const A : TChessCoordinate) : Integer; inline;
const
  TChessBoundaries : TSpecialSquares = [a1, b1, c1, d1, e1, f1, g1, h1, h2, h3, h4, h5, h6, h7, h8,
                                        g8, f8, e8, d8, c8, b8, a8, a7, a6, a5, a4, a3, a2];
  TChessCorners    : TSpecialSquares = [a1, h1, h8, a8];

  TChessAColumn    : TSpecialSquares = [a1, a2, a3, a4, a5, a6, a7, a8];
  TChessBColumn    : TSpecialSquares = [b1, b2, b3, b4, b5, b6, b7, b8];
  TChessCColumn    : TSpecialSquares = [c1, c2, c3, c4, c5, c6, c7, c8];
  TChessDColumn    : TSpecialSquares = [d1, d2, d3, d4, d5, d6, d7, d8];
  TChessEColumn    : TSpecialSquares = [e1, e2, e3, e4, e5, e6, e7, e8];
  TChessFColumn    : TSpecialSquares = [f1, f2, f3, f4, f5, f6, f7, f8];
  TChessGColumn    : TSpecialSquares = [g1, g2, g3, g4, g5, g6, g7, g8];
  TChessHColumn    : TSpecialSquares = [h1, h2, h3, h4, h5, h6, h7, h8];

implementation
uses
 System.SysUtils;
//ChessPiece//
function TChessPiece.Move(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
begin
  Result := CanMove(Coordinate, bCapture);
  if Result then
  begin
    FLastPos  := FPosition;
    FPosition := Coordinate;
    FMoved    := True;
    Inc(FMoves);
  end;
end;

constructor TChessPiece.Create(bWhite : Boolean);
begin
  FWhite    := bWhite;
  FCaptured := False;
  FMoved    := False;

  FDragPos.X := -1;
  FDragPos.Y := -1;
  FDragging := False;
  FMoves := 0;
  inherited Create;
end;

procedure TChessPiece.SetInitialPosition(APos : TChessCoordinate);
begin
   FInitialPos := APos;
   FPosition   := APos;
   FLastPos    := APos;
end;

procedure TChessPiece.Reset;
begin
  FPosition := FInitialPos;
  FCaptured := False;
  FMoved    := False;
  FMoves    := 0;
  FEnPassant:= False;
end;

procedure TChessPiece.Undo;
begin
  FPosition := FLastPos;
  Dec(FMoves);
  FMoved := FMoves <> 0;
end;
//ChessPiece//

//Bishop//
constructor TBishop.Create(bWhite : Boolean);
begin
  inherited;
  if FWhite then
  begin
    LoadFromResourceName(HInstance,'PngImage_7');
    FName := WHITE_BISHOP;
  end
  else begin
    LoadFromResourceName(HInstance,'PngImage_1');
    FName := BLACK_BISHOP;
  end;

end;

function TBishop.CanMove(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
begin
  Result := IsOnSameDiagonal(FPosition, Coordinate);
end;
//Bishop//

//King//
constructor TKing.Create(bWhite : Boolean);
begin
  inherited;
  if FWhite then
  begin
    LoadFromResourceName(HInstance,'PngImage_8');
    FName := WHITE_KING;
  end
  else begin
    LoadFromResourceName(HInstance,'PngImage_2');
    FName := BLACK_KING;
  end;
end;

function TKing.CanMove(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
var
  ARow, AColumn : Integer;
  BRow, BColumn : Integer;
begin
  ARow    := GetRow(Coordinate);
  AColumn := GetColumn(Coordinate);

  BRow    := GetRow(FPosition);
  BColumn := GetColumn(FPosition);

  Result := (Abs(ARow - BRow) <= 1) and (Abs(AColumn - BColumn) <= 1);
end;

procedure TKing.LongCastle;
begin
  if FWhite
  then FPosition := c1
  else FPosition := c8;
  Inc(FMoves);
  FMoved := True;
end;

procedure TKing.ShortCastle;
begin
  if FWhite
  then FPosition := g1
  else FPosition := g8;
  Inc(FMoves);
  FMoved := True;
end;
//King//

//Knight//
constructor TKnight.Create(bWhite : Boolean);
begin
  inherited;
  if FWhite then
  begin
    LoadFromResourceName(HInstance,'PngImage_9');
    FName := WHITE_KNIGHT;
  end
  else begin
    LoadFromResourceName(HInstance,'PngImage_3');
    FName := BLACK_KNIGHT;
  end;
end;

function TKnight.CanMove(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
var
  ARow, AColumn : Integer;
  BRow, BColumn : Integer;
begin
  ARow    := GetRow(Coordinate);
  AColumn := GetColumn(Coordinate);

  BRow    := GetRow(FPosition);
  BColumn := GetColumn(FPosition);

  Result := (Abs(ARow - BRow) = 2) and (Abs(AColumn - BColumn) = 1) or
            (Abs(ARow - BRow) = 1) and (Abs(AColumn - BColumn) = 2)
end;
//Knight//

//Queen//
constructor TQueen.Create(bWhite : Boolean);
begin
  inherited;
  if FWhite then
  begin
    LoadFromResourceName(HInstance,'PngImage_11');
    FName := WHITE_QUEEN;
  end
  else begin
    LoadFromResourceName(HInstance,'PngImage_5');
    FName := BLACK_QUEEN;
  end;
end;

function TQueen.CanMove(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
begin
  Result := IsOnSameColumn(FPosition, Coordinate) or IsOnSameRow(FPosition, Coordinate) or
            IsOnSameDiagonal(FPosition, Coordinate);
end;
//Queen//

//Rook//
constructor TRook.Create(bWhite : Boolean);
begin
  inherited;
  if FWhite
    then LoadFromResourceName(HInstance,'PngImage_12')
    else LoadFromResourceName(HInstance,'PngImage_6');
end;

function TRook.CanMove(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
begin
  Result := IsOnSameColumn(FPosition, Coordinate) or IsOnSameRow(FPosition, Coordinate);
end;

procedure TRook.LongCastle;
begin
  if FWhite
  then FPosition := d1
  else FPosition := d8;
  Inc(FMoves);
  FMoved := True;
end;

procedure TRook.ShortCastle;
begin
  if FWhite
  then FPosition := f1
  else FPosition := f8;
  Inc(FMoves);
  FMoved := True;
end;
//Rook//

//Pawn//
constructor TPawn.Create(bWhite : Boolean);
begin
  inherited;
  if FWhite then
  begin
    LoadFromResourceName(HInstance,'PngImage_10');
    FName := WHITE_PAWN;
  end
  else begin
    LoadFromResourceName(HInstance,'PngImage_4');
    FName := BLACK_PAWN;
  end;
end;

function TPawn.CanMove(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
begin
 if not bCapture then
 if(not FMoved) then
 begin
   if FWhite
     then Result := Integer(Coordinate) in [Integer(FPosition) + 8, Integer(FPosition) + 16]
     else Result := Integer(Coordinate) in [Integer(FPosition) - 8, Integer(FPosition) - 16];
 end
 else
 begin
   if FWhite
     then Result := Integer(Coordinate) = Integer(FPosition) + 8
     else Result := Integer(Coordinate) = Integer(FPosition) - 8;
 end
 else
 begin
   if FWhite
     then Result := (Integer(Coordinate) = Integer(FPosition) + 7) or
          (not (GetColumn(FPosition) = 8) and (Integer(Coordinate) = Integer(FPosition) + 9))
     else Result := (Integer(Coordinate) = Integer(FPosition) - 7) or
          (not (GetColumn(FPosition) = 1) and (Integer(Coordinate) = Integer(FPosition) - 9));
 end;
end;

function TPawn.Move(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean;
begin
  Result := inherited;
  if Result then
  begin
    if FWhite
      then if Integer(FPosition) = Integer(FLastPos) + 16 then FEnPassant := True else FEnPassant := False
      else if Integer(FPosition) = Integer(FLastPos) - 16 then FEnPassant := True else FEnPassant := False
  end;
end;

//Pawn//

//Functions//
function IsOnSameColumn(const A : TChessCoordinate; const B : TChessCoordinate) : Boolean; inline;
begin
  Result := GetColumn(B) = GetColumn(A);
end;

function IsOnSameRow(const A : TChessCoordinate; const B : TChessCoordinate) : Boolean; inline;
begin
  Result := GetRow(B) = GetRow(A);
end;

function IsOnSameDiagonal(const A : TChessCoordinate; const B : TChessCoordinate) : Boolean; inline;
var
  ColA, RowA : Integer;
  ColB, RowB : Integer;
begin
  ColA := GetColumn(A);
  RowA := GetRow(A);

  ColB := GetColumn(B);
  RowB := GetRow(B);

  Result := Abs(ColA - ColB) = Abs(RowA - RowB);
end;
function GetRow (const A : TChessCoordinate) : Integer; inline;
begin
  case A of
    a1,b1,c1,d1,
    e1,f1,g1,h1 : Result := 1;

    a2,b2,c2,d2,
    e2,f2,g2,h2 : Result := 2;

    a3,b3,c3,d3,
    e3,f3,g3,h3 : Result := 3;

    a4,b4,c4,d4,
    e4,f4,g4,h4 : Result := 4;

    a5,b5,c5,d5,
    e5,f5,g5,h5 : Result := 5;

    a6,b6,c6,d6,
    e6,f6,g6,h6 : Result := 6;

    a7,b7,c7,d7,
    e7,f7,g7,h7 : Result := 7;
  else
    Result := 8;
  end;
end;
function GetColumn (const A : TChessCoordinate) : Integer; inline;
begin
  case A of
    a1,a2,a3,a4,
    a5,a6,a7,a8 : Result := 1;

    b1,b2,b3,b4,
    b5,b6,b7,b8 : Result := 2;

    c1,c2,c3,c4,
    c5,c6,c7,c8 : Result := 3;

    d1,d2,d3,d4,
    d5,d6,d7,d8 : Result := 4;

    e1,e2,e3,e4,
    e5,e6,e7,e8 : Result := 5;

    f1,f2,f3,f4,
    f5,f6,f7,f8 : Result := 6;

    g1,g2,g3,g4,
    g5,g6,g7,g8 : Result := 7;
  else
    Result := 8;
  end;
end;

function TChessPieceNameHelper.ToString : String;
begin
  case Self of
    WHITE_PAWN   : Result := 'White Pawn';
    BLACK_PAWN   : Result := 'Black Pawn';
    WHITE_KING   : Result := 'White King';
    BLACK_KING   : Result := 'Black King';
    WHITE_QUEEN  : Result := 'White Queen';
    BLACK_QUEEN  : Result := 'Black Queen';
    WHITE_KNIGHT : Result := 'White Knight';
    BLACK_KNIGHT : Result := 'Black Knight';
    WHITE_BISHOP : Result := 'White Bishop';
    BLACK_BISHOP : Result := 'Black Bishop';
    WHITE_ROOK   : Result := 'White Rook';
    BLACK_ROOK   : Result := 'Black Rook';
    CHESS_NONE   : Result := 'None';
  end;
end;

function TChessCoordinateHelper.ToString: String;
var
  Row, Column : Integer;
begin
  Row    := GetRow(Self);
  Column := GetColumn(Self);
  Result := Char(Column + 96) + IntToStr(Row);
end;
//Functions//
end.
