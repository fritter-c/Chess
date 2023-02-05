object FormConfigure: TFormConfigure
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Configure'
  ClientHeight = 421
  ClientWidth = 316
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBlackPlayer: TPanel
    Left = 0
    Top = 0
    Width = 316
    Height = 190
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlBlackPlayer'
    ShowCaption = False
    TabOrder = 0
    ExplicitWidth = 306
    object lblTimeBlack: TLabel
      Left = 12
      Top = 65
      Width = 60
      Height = 29
      Align = alCustom
      Caption = 'Time:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblBlack: TLabel
      Left = 0
      Top = 0
      Width = 316
      Height = 35
      Align = alTop
      Caption = 'Black Player'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Font.Quality = fqClearType
      ParentFont = False
      ExplicitWidth = 179
    end
    object lblHoursBlack: TLabel
      Left = 135
      Top = 74
      Width = 7
      Height = 13
      Caption = 'H'
    end
    object lblMinutesBlack: TLabel
      Left = 195
      Top = 74
      Width = 8
      Height = 13
      Caption = 'M'
    end
    object lblSecondsBlack: TLabel
      Left = 256
      Top = 73
      Width = 6
      Height = 13
      Caption = 'S'
    end
    object lblIncrementBlack: TLabel
      Left = 12
      Top = 121
      Width = 117
      Height = 29
      Align = alCustom
      Caption = 'Increment:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblMinutesBlack2: TLabel
      Left = 192
      Top = 131
      Width = 8
      Height = 13
      Caption = 'M'
    end
    object seMinutes: TSpinEdit
      Left = 148
      Top = 70
      Width = 41
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
      OnChange = seMinutesChange
    end
    object seHours: TSpinEdit
      Left = 88
      Top = 70
      Width = 41
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
      OnChange = seHoursChange
    end
    object seSeconds: TSpinEdit
      Left = 209
      Top = 70
      Width = 41
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
      OnChange = seSecondsChange
    end
    object seIncrement: TSpinEdit
      Left = 141
      Top = 126
      Width = 45
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = seIncrementChange
    end
  end
  object pnlCommands: TPanel
    Left = 0
    Top = 380
    Width = 316
    Height = 40
    Align = alTop
    Caption = 'pnlCommands'
    ShowCaption = False
    TabOrder = 1
    object btnOk: TButton
      Left = 240
      Top = 1
      Width = 75
      Height = 38
      Align = alRight
      Caption = 'Ok'
      TabOrder = 0
      OnClick = btnOkClick
      ExplicitLeft = 230
    end
    object btnCancel: TButton
      Left = 165
      Top = 1
      Width = 75
      Height = 38
      Align = alRight
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
      ExplicitLeft = 155
    end
  end
  object pnlWhitePlayer: TPanel
    Left = 0
    Top = 190
    Width = 316
    Height = 190
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlBlack'
    ShowCaption = False
    TabOrder = 2
    ExplicitWidth = 306
    object lblTimeWhite: TLabel
      Left = 12
      Top = 65
      Width = 60
      Height = 29
      Align = alCustom
      Caption = 'Time:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblWhite: TLabel
      Left = 0
      Top = 0
      Width = 316
      Height = 35
      Align = alTop
      Caption = 'White Player'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -29
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Font.Quality = fqClearType
      ParentFont = False
      ExplicitWidth = 188
    end
    object lblHoursWhite: TLabel
      Left = 135
      Top = 74
      Width = 7
      Height = 13
      Caption = 'H'
    end
    object lblMinutesWhite: TLabel
      Left = 195
      Top = 74
      Width = 8
      Height = 13
      Caption = 'M'
    end
    object lblSecondsWhite: TLabel
      Left = 256
      Top = 73
      Width = 6
      Height = 13
      Caption = 'S'
    end
    object lblIncrementWhite: TLabel
      Left = 12
      Top = 121
      Width = 117
      Height = 29
      Align = alCustom
      Caption = 'Increment:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblMinutesWhite2: TLabel
      Left = 192
      Top = 131
      Width = 8
      Height = 13
      Caption = 'M'
    end
    object seMinutes1: TSpinEdit
      Left = 148
      Top = 70
      Width = 41
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
      OnChange = seMinutes1Change
    end
    object seHours1: TSpinEdit
      Left = 88
      Top = 70
      Width = 41
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
      OnChange = seHours1Change
    end
    object seSeconds1: TSpinEdit
      Left = 209
      Top = 70
      Width = 41
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
      OnChange = seSeconds1Change
    end
    object seIncrement1: TSpinEdit
      Left = 141
      Top = 126
      Width = 45
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = seIncrement1Change
    end
  end
end
