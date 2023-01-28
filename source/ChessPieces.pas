unit ChessPieces;

interface

uses
  Graphics,
  Vcl.Imaging.pngimage;

type
  TChessCoordinate = (a1 = 1,  a2 = 2,  a3 = 3,  a4 = 4,  a5 = 5,  a6 = 6,  a7 = 7,  a8 = 8,
                      b1 = 9,  b2 = 10, b3 = 11, b4 = 12, b5 = 13, b6 = 14, b7 = 15, b8 = 16,
                      c1 = 17, c2 = 18, c3 = 19, c4 = 20, c5 = 21, c6 = 22, c7 = 23, c8 = 24,
                      d1 = 25, d2 = 26, d3 = 27, d4 = 28, d5 = 29, d6 = 30, d7 = 31, d8 = 32,
                      e1 = 33, e2 = 34, e3 = 35, e4 = 36, e5 = 37, e6 = 38, e7 = 39, e8 = 40,
                      f1 = 41, f2 = 42, f3 = 43, f4 = 44, f5 = 45, f6 = 46, f7 = 47, f8 = 48,
                      g1 = 49, g2 = 50, g3 = 51, g4 = 52, g5 = 53, g6 = 54, g7 = 55, g8 = 56,
                      h1 = 57, h2 = 58, h3 = 59, h4 = 60, h5 = 61, h6 = 62, h7 = 63, h8 = 64);

  TChessPiece = class(TPngImage)
  protected
    FPosition   : TChessCoordinate;
    FWhite      : Boolean;
    FInitialPos : TChessCoordinate;
    FCaptured   : Boolean;
    FMoved      : Boolean;

    procedure SetInitialPosition(APos : TChessCoordinate);
  public
    constructor Create(bWhite : Boolean); virtual;
    function    CanMove(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; virtual; abstract;
    function    Move(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; virtual;
    procedure   Reset; virtual;

    property Position   : TChessCoordinate read FPosition   write FPosition;
    property White      : Boolean          read FWhite      write FWhite;
    property InitialPos : TChessCoordinate read FInitialPos write SetInitialPosition;
    property Captured   : Boolean          read FCaptured   write FCaptured;
    property Moved      : Boolean          read FMoved;
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
  private
    FFirstMove : Boolean;
  public
    constructor Create(bWhite : Boolean); override;
    function CanMove(Coordinate: TChessCoordinate; bCapture : Boolean = False): Boolean; override;
    function Move(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean; override;
    procedure Reset; override;

    property FirstMove : Boolean read FFirstMove write FFirstMove;
  end;

  function IsOnSameRow     (const A : TChessCoordinate; const B : TChessCoordinate) : Boolean; inline;
  function IsOnSameColumn  (const A : TChessCoordinate; const B : TChessCoordinate) : Boolean; inline;
  function IsOnSameDiagonal(const A : TChessCoordinate; const B : TChessCoordinate) : Boolean; inline;
implementation

//ChessPiece//
function TChessPiece.Move(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
begin
  Result := CanMove(Coordinate, bCapture);
  if Result then
  begin
    FPosition := Coordinate;
    FMoved    := True;
  end;
end;

constructor TChessPiece.Create(bWhite : Boolean);
begin
  FWhite    := bWhite;
  FCaptured := False;
  FMoved    := False;
  inherited Create;
end;

procedure TChessPiece.SetInitialPosition(APos : TChessCoordinate);
begin
   FInitialPos := APos;
   FPosition   := APos;
end;

procedure TChessPiece.Reset;
begin
  FPosition := FInitialPos;
  FCaptured := False;
  FMoved    := False;
end;
//ChessPiece//

//Bishop//
constructor TBishop.Create(bWhite : Boolean);
begin
  inherited;
  if FWhite 
    then LoadFromResourceName(HInstance,'PngImage_7')
    else LoadFromResourceName(HInstance,'PngImage_1');
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
  if FWhite
    then LoadFromResourceName(HInstance,'PngImage_8')
    else LoadFromResourceName(HInstance,'PngImage_2');
end;

function TKing.CanMove(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
begin
  Result := Integer(Coordinate) in [Integer(FPosition) + 1,
                                    Integer(FPosition) + 9,
                                    Integer(FPosition) + 8,
                                    Integer(FPosition) + 7,
                                    Integer(FPosition) - 9,
                                    Integer(FPosition) - 8,
                                    Integer(FPosition) - 7,
                                    Integer(FPosition) - 1];
end;

procedure TKing.LongCastle;
begin
  if FWhite
  then FPosition := c1
  else FPosition := c8;
  FMoved := True;
end;

procedure TKing.ShortCastle;
begin
  if FWhite
  then FPosition := g1
  else FPosition := g8;
  FMoved := True;
end;
//King//

//Knight//
constructor TKnight.Create(bWhite : Boolean);
begin
  inherited;
  if FWhite
    then LoadFromResourceName(HInstance,'PngImage_9')
    else LoadFromResourceName(HInstance,'PngImage_3');
end;

function TKnight.CanMove(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
var
  nDist : Integer;
begin
  nDist := Abs(Integer(FPosition) - Integer(Coordinate));
  Result := (not (IsOnSameColumn(FPosition, Coordinate))) and ((nDist = 6) or (nDist = 10) or (nDist = 15) or (nDist = 17));
end;
//Knight//

//Queen//
constructor TQueen.Create(bWhite : Boolean);
begin
  inherited;
  if FWhite
    then LoadFromResourceName(HInstance,'PngImage_11')
    else LoadFromResourceName(HInstance,'PngImage_5');
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
  FMoved := True;
end;

procedure TRook.ShortCastle;
begin
  if FWhite
  then FPosition := f1
  else FPosition := f8;
  FMoved := True;
end;
//Rook//

//Pawn//
constructor TPawn.Create(bWhite : Boolean);
begin
  inherited;
  if FWhite
    then LoadFromResourceName(HInstance,'PngImage_10')
    else LoadFromResourceName(HInstance,'PngImage_4');
  FFirstMove := True;
end;

function TPawn.CanMove(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
begin
 if not bCapture then
 if(FFirstMove) then
 begin
   if FWhite
     then Result := Integer(Coordinate) in [Integer(FPosition) + 1, Integer(FPosition) + 2]
     else Result := Integer(Coordinate) in [Integer(FPosition) - 1, Integer(FPosition) - 2];
 end
 else
 begin
   if FWhite
     then Result := Integer(Coordinate) = Integer(FPosition) + 1
     else Result := Integer(Coordinate) = Integer(FPosition) - 1;
 end
 else
 begin
   if FWhite
     then Result := (Integer(Coordinate) = Integer(FPosition) - 7) or (Integer(Coordinate) = Integer(FPosition) + 9)
     else Result := (Integer(Coordinate) = Integer(FPosition) + 7) or (Integer(Coordinate) = Integer(FPosition) - 9);
 end;
end;

function TPawn.Move(Coordinate: TChessCoordinate; bCapture : Boolean): Boolean;
begin
  Result := inherited;
  FFirstMove := False;
end;

procedure TPawn.Reset;
begin
  FFirstMove := True;
  inherited;
end;
//Pawn//

//Functions//
function IsOnSameColumn(const A : TChessCoordinate; const B : TChessCoordinate) : Boolean;
var
  nCoord : Integer;
begin
  nCoord := Integer(A);
  if (nCoord <= 8) then
    nCoord := 1
  else if (nCoord <= 16) then
    nCoord := 9
  else if (nCoord <= 24) then
    nCoord := 17
  else if (nCoord <= 32) then
    nCoord := 25
  else if (nCoord <= 40) then
    nCoord := 33
  else if (nCoord <= 48) then
    nCoord := 41
  else if (nCoord <= 56) then
    nCoord := 49
  else if (nCoord <= 64) then
    nCoord := 57;

  Result := (Integer(B) >= nCoord) and (Integer(B) <= nCoord + 7);
end;

function IsOnSameRow(const A : TChessCoordinate; const B : TChessCoordinate) : Boolean;
var
  nCoord : Integer;
begin
  nCoord := Abs(Integer(A) - Integer(B));
  Result := (nCoord mod 8 = 0);
end;

function IsOnSameDiagonal(const A : TChessCoordinate; const B : TChessCoordinate) : Boolean;
var
  nCoord : Integer;
begin
  nCoord := Abs(Integer(A) - Integer(B));
  Result := (nCoord mod 9 = 0) or (nCoord mod 7 = 0)
end;
//Functions//
end.
