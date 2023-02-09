unit ChessGame;

interface
uses
  Generics.Collections,
  ChessPieces;

type
  TGameState = (gsNone,
                gsWhiteToMove,
                gsBlackToMove,
                gsWhiteInCheck,
                gsBlackInCheck,
                gsWhiteWinsOnResign,
                gsWhiteWinsOnMate,
                gsWhiteWinsOnTime,
                gsBlackWinsOnResign,
                gsBlackWinsOnMate,
                gsBlackWinsOnTime,
                gsDrawInsufficientMaterial,
                gsDrawAgreement,
                gsDrawStaleMate,
                gsDrawRepetition);
  TGameStateHelper = record helper for TGameState
  function ToString : string;
  end;

  TPieceBoard = array [1..8] of array [1..8] of TChessPiece;

  TLightBoard = array [1..8] of array [1..8] of TChessPieceName;

  TSimpleChessMove = packed record
    Piece : TChessPieceName;
    Move  : TChessCoordinate;
    From  : TChessCoordinate;
  end;
  PSimpleChessMove = ^TSimpleChessMove;

  TSimpleChessMoveHelper = record helper for TSimpleChessMove
  function ToString : String; inline;
  end;
  TAlgebraicChessMove = packed record
    Piece : TChessPieceName;
    Move  : TChessCoordinate;
    Kill  : Boolean;
    BFile : Boolean;
    BRank : Boolean;
    FileD : Integer;
    RankD : Integer;
    Castle: Boolean;
  end;
  TChessTimeConfig = packed record
    White : Boolean;
    Time  : TTime;
    Inc   : TTime;
  end;
  PChessTimeConfig = ^TChessTimeConfig;

  TChessTimeLeft = packed record
    White : Boolean;
    Time  : TTime;
  end;
  PChessTimeLeft = ^TChessTimeLeft;

  TChessPlayer = record
    Moves    : Integer;
    TimeLeft : TTime;
    White    : Boolean;
  end;
  PChessPlayer = ^TChessPlayer;

  TChessGame = record
    Board       : TPieceBoard;
    History     : array of TPieceBoard;
    LightBoard  : TLightBoard;
    PriorBoard  : TLightBoard;
    WhitePlayer : PChessPlayer;
    BlackPlayer : PChessPlayer;
    Moves       : Integer;
    WhiteToMove : Boolean;
    State       : TGameState;
  end;
  PChessGame = ^TChessGame;

  TChessPromote = packed record
    Move      : TSimpleChessMove;
    PromoteTo : TChessPieceName;
  end;
  PChessPromote = ^TChessPromote;

  procedure AddSnap(Game : PChessGame); inline;
  procedure SetLightBoard(Game : PChessGame); inline;
  procedure SetState(Game : PChessGame; State : TGameState); inline;
const
  TBoard : array [1..8] of array [1..8] of TChessCoordinate =
  ((a1, a2, a3, a4, a5, a6, a7, a8),
   (b1, b2, b3, b4, b5, b6, b7, b8),
   (c1, c2, c3, c4, c5, c6, c7, c8),
   (d1, d2, d3, d4, d5, d6, d7, d8),
   (e1, e2, e3, e4, e5, e6, e7, e8),
   (f1, f2, f3, f4, f5, f6, f7, f8),
   (g1, g2, g3, g4, g5, g6, g7, g8),
   (h1, h2, h3, h4, h5, h6, h7, h8));
implementation
function TGameStateHelper.ToString : String;
begin
  case Self of
    gsNone                     : Result := 'None';
    gsWhiteToMove              : Result := 'White to Move';
    gsBlackToMove              : Result := 'Black to Move';
    gsWhiteInCheck             : Result := 'White in Check';
    gsBlackInCheck             : Result := 'Black in Check';
    gsWhiteWinsOnResign        : Result := 'White Wins (On Resign)';
    gsWhiteWinsOnMate          : Result := 'White Wins (On Mate)';
    gsWhiteWinsOnTime          : Result := 'White Wins (On Time)';
    gsBlackWinsOnResign        : Result := 'Black Wins (On Resign)';
    gsBlackWinsOnMate          : Result := 'Black Wins (On Mate)' ;
    gsBlackWinsOnTime          : Result := 'Black Wins (On Time)';
    gsDrawInsufficientMaterial : Result := 'Draw (Insufficient Material)';
    gsDrawAgreement            : Result := 'Draw (Agreement)';
    gsDrawStaleMate            : Result := 'Draw (Stalamate)';
    gsDrawRepetition           : Result := 'Draw (DrawRepetition)';
  end;
end;
procedure AddSnap(Game : PChessGame); inline;
begin
  SetLength(Game.History, Length(Game.History) + 1);
  Game.History[Length(Game.History) - 1] := Game.Board;
end;

procedure SetLightBoard(Game : PChessGame); inline;
var
  C,R : Integer;
begin
  for C := 1 to 8 do
  for R := 1 to 8 do
    Game.PriorBoard[C][R] := Game.LightBoard[C][R];
  for C := 1 to 8 do
  for R := 1 to 8 do
  begin
    if Assigned(Game.Board[C][R])
      then Game.LightBoard[C][R] := Game.Board[C][R].Name
      else Game.LightBoard[C][R] := CHESS_NONE;
  end;
end;

function TSimpleChessMoveHelper.ToString : String;
begin
  Result := Self.Piece.ToString + ' to ' + Self.Move.ToString;
end;

procedure SetState(Game : PChessGame; State : TGameState); inline;
begin
  if Game.State <> State then Game.State := State; 
end;
end.
