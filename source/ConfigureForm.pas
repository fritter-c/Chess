unit ConfigureForm;

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
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Samples.Spin;

type
  TFormConfigure = class(TForm)
    lblBlack          : TLabel;
    lblTimeBlack      : TLabel;
    pnlBlackPlayer    : TPanel;
    seMinutes         : TSpinEdit;
    seHours           : TSpinEdit;
    seSeconds         : TSpinEdit;
    lblHoursBlack     : TLabel;
    lblMinutesBlack   : TLabel;
    lblSecondsBlack   : TLabel;
    lblIncrementBlack : TLabel;
    seIncrement       : TSpinEdit;
    lblMinutesBlack2  : TLabel;
    pnlCommands       : TPanel;
    btnOk             : TButton;
    btnCancel         : TButton;
    pnlWhitePlayer    : TPanel;
    lblTimeWhite      : TLabel;
    lblWhite          : TLabel;
    lblHoursWhite     : TLabel;
    lblMinutesWhite   : TLabel;
    lblSecondsWhite   : TLabel;
    lblIncrementWhite : TLabel;
    lblMinutesWhite2  : TLabel;
    seMinutes1        : TSpinEdit;
    seHours1          : TSpinEdit;
    seSeconds1        : TSpinEdit;
    seIncrement1      : TSpinEdit;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure seHours1Change(Sender: TObject);
    procedure seMinutes1Change(Sender: TObject);
    procedure seSeconds1Change(Sender: TObject);
    procedure seIncrement1Change(Sender: TObject);
    procedure seHoursChange(Sender: TObject);
    procedure seMinutesChange(Sender: TObject);
    procedure seSecondsChange(Sender: TObject);
    procedure seIncrementChange(Sender: TObject);
  public
    function GetWhiteTime : TDateTime;
    function GetBlackTime : TDateTime;
    function GetBlackInc  : TDateTime;
    function GetWhiteInc  : TDateTime;
  end;
var
  FormConfigure: TFormConfigure;
implementation

{$R *.dfm}

procedure TFormConfigure.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFormConfigure.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TFormConfigure.seHours1Change(Sender: TObject);
begin
  if TSpinEdit(Sender).Value < 0 then seHours1.Value := 0;
end;

procedure TFormConfigure.seHoursChange(Sender: TObject);
begin
  if TSpinEdit(Sender).Value < 0 then seHours1.Value := 0;
end;

procedure TFormConfigure.seIncrement1Change(Sender: TObject);
begin
  if TSpinEdit(Sender).Value < 0 then seHours1.Value := 0;
end;

procedure TFormConfigure.seIncrementChange(Sender: TObject);
begin
  if TSpinEdit(Sender).Value < 0 then seHours1.Value := 0;
end;

procedure TFormConfigure.seMinutes1Change(Sender: TObject);
begin
  if TSpinEdit(Sender).Value < 0 then seHours1.Value := 0;
end;

procedure TFormConfigure.seMinutesChange(Sender: TObject);
begin
  if TSpinEdit(Sender).Value < 0 then seHours1.Value := 0;
end;

procedure TFormConfigure.seSeconds1Change(Sender: TObject);
begin
  if TSpinEdit(Sender).Value < 0 then seHours1.Value := 0;
end;

procedure TFormConfigure.seSecondsChange(Sender: TObject);
begin
  if TSpinEdit(Sender).Value < 0 then seHours1.Value := 0;
end;

function TFormConfigure.GetWhiteTime : TDateTime;
begin
  Result := EncodeTime(seHours1.Value, seMinutes.Value, seSeconds.Value, 0);
end;

function TFormConfigure.GetBlackTime : TDateTime;
begin
  Result := EncodeTime(seHours.Value, seMinutes.Value, seSeconds.Value, 0);
end;

function TFormConfigure.GetBlackInc  : TDateTime;
begin
  Result := EncodeTime(0, 0, seIncrement.Value, 0);
end;

function TFormConfigure.GetWhiteInc  : TDateTime;
begin
  Result := EncodeTime(0, 0, seIncrement1.Value, 0);
end;
end.
