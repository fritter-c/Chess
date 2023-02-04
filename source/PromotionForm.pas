unit PromotionForm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  ChessPieces,
  StdCtrls;

type
  TPromotion = class(TForm)
    imgQueen : TImage;
    imgRook  : TImage;
    imgBishop: TImage;
    imgKnight: TImage;
    btnCancel: TButton;
    pnl_Queen: TPanel;
    pnl_Rook: TPanel;
    pnl_Poney: TPanel;
    pnl_Bishop: TPanel;
    procedure btnCancelClick(Sender: TObject);
    procedure imgQueenClick(Sender: TObject);
    procedure imgRookClick(Sender: TObject);
    procedure imgBishopClick(Sender: TObject);
    procedure imgKnightClick(Sender: TObject);
    procedure imgQueenMouseEnter(Sender: TObject);
    procedure imgQueenMouseLeave(Sender: TObject);
    procedure imgRookMouseEnter(Sender: TObject);
    procedure imgRookMouseLeave(Sender: TObject);
    procedure imgKnightMouseEnter(Sender: TObject);
    procedure imgKnightMouseLeave(Sender: TObject);
    procedure imgBishopMouseEnter(Sender: TObject);
    procedure imgBishopMouseLeave(Sender: TObject);
  private
    FSelectedPiece : TChessPiece;
    FWhite         : Boolean;
  public
    property SelectedPiece : TChessPiece read FSelectedPiece;
    procedure ConfigureForm(bWhite : Boolean);
  end;

var
  Promotion: TPromotion;

implementation

uses
  Vcl.Imaging.pngimage;
{$R *.dfm}

procedure TPromotion.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TPromotion.ConfigureForm(bWhite : Boolean);
var
  RS : TResourceStream;
begin
  FWhite := bWhite;
  if bWhite then
  begin
    RS := TResourceStream.Create(HInstance, 'PngImage_11', RT_RCDATA);
    imgQueen.Picture.LoadFromStream(RS);
    RS.Free;
    RS := TResourceStream.Create(HInstance, 'PngImage_12', RT_RCDATA);
    imgRook.Picture.LoadFromStream(RS);
    RS.Free;
    RS := TResourceStream.Create(HInstance, 'PngImage_9', RT_RCDATA);
    imgKnight.Picture.LoadFromStream(RS);
    RS.Free;
    RS := TResourceStream.Create(HInstance, 'PngImage_7', RT_RCDATA);
    imgBishop.Picture.LoadFromStream(RS);
    RS.Free;
  end
  else begin
    RS := TResourceStream.Create(HInstance, 'PngImage_5', RT_RCDATA);
    imgQueen.Picture.LoadFromStream(RS);
    RS.Free;
    RS := TResourceStream.Create(HInstance, 'PngImage_6', RT_RCDATA);
    imgRook.Picture.LoadFromStream(RS);
    RS.Free;
    RS := TResourceStream.Create(HInstance, 'PngImage_3', RT_RCDATA);
    imgKnight.Picture.LoadFromStream(RS);
    RS.Free;
    RS := TResourceStream.Create(HInstance, 'PngImage_1', RT_RCDATA);
    imgBishop.Picture.LoadFromStream(RS);
    RS.Free;
  end;
end;

procedure TPromotion.imgBishopClick(Sender: TObject);
begin
  FSelectedPiece := TBishop.Create(FWhite);
  ModalResult    := mrOk;
end;

procedure TPromotion.imgBishopMouseEnter(Sender: TObject);
begin
  pnl_Bishop.Color := clHighlight;
end;

procedure TPromotion.imgBishopMouseLeave(Sender: TObject);
begin
  pnl_Bishop.Color := clBtnFace;
end;

procedure TPromotion.imgKnightClick(Sender: TObject);
begin
  FSelectedPiece := TKnight.Create(FWhite);
  ModalResult    := mrOk;
end;

procedure TPromotion.imgKnightMouseEnter(Sender: TObject);
begin
  pnl_Poney.Color := clHighlight;
end;

procedure TPromotion.imgKnightMouseLeave(Sender: TObject);
begin
  pnl_Poney.Color := clBtnFace;
end;

procedure TPromotion.imgQueenClick(Sender: TObject);
begin
  FSelectedPiece := TQueen.Create(FWhite);
  ModalResult    := mrOk;
end;

procedure TPromotion.imgQueenMouseEnter(Sender: TObject);
begin
  pnl_Queen.Color := clHighlight;
end;

procedure TPromotion.imgQueenMouseLeave(Sender: TObject);
begin
  pnl_Queen.Color := clBtnFace;
end;

procedure TPromotion.imgRookClick(Sender: TObject);
begin
  FSelectedPiece := TRook.Create(FWhite);
  ModalResult    := mrOk;
end;
procedure TPromotion.imgRookMouseEnter(Sender: TObject);
begin
  pnl_Rook.Color := clHighlight;
end;

procedure TPromotion.imgRookMouseLeave(Sender: TObject);
begin
  pnl_Rook.Color := clBtnFace;
end;
end.
