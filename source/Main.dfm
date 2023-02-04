object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Chess'
  ClientHeight = 839
  ClientWidth = 983
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  PixelsPerInch = 96
  TextHeight = 13
  object pnl_Status: TPanel
    Left = 0
    Top = 0
    Width = 983
    Height = 41
    Align = alTop
    TabOrder = 0
    object lblStatus: TLabel
      Left = 484
      Top = 7
      Width = 45
      Height = 21
      Align = alCustom
      Caption = 'None'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnNewGame: TButton
      Left = 1
      Top = 1
      Width = 75
      Height = 39
      Align = alLeft
      Caption = 'New Game'
      TabOrder = 0
      OnClick = btnNewGameClick
    end
    object btnFlip: TButton
      Left = 907
      Top = 1
      Width = 75
      Height = 39
      Align = alRight
      Caption = 'Flip Board'
      TabOrder = 1
      OnClick = btnFlipClick
    end
    object btnPromotionForm: TButton
      Left = 832
      Top = 1
      Width = 75
      Height = 39
      Align = alRight
      Caption = 'Promotion'
      TabOrder = 2
      OnClick = btnPromotionFormClick
    end
    object btnStart: TButton
      Left = 76
      Top = 1
      Width = 75
      Height = 39
      Align = alLeft
      Caption = 'Start'
      TabOrder = 3
    end
  end
  object pnl_Board: TPanel
    Left = 185
    Top = 41
    Width = 798
    Height = 798
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    Constraints.MaxHeight = 798
    Constraints.MaxWidth = 798
    Constraints.MinHeight = 798
    Constraints.MinWidth = 798
    TabOrder = 1
    object cbBoard: TChessBoard
      Left = 1
      Top = 1
      Width = 792
      Height = 792
      Align = alCustom
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Caption = 'cbBoard'
      Constraints.MaxHeight = 792
      Constraints.MaxWidth = 792
      Constraints.MinHeight = 792
      Constraints.MinWidth = 792
      UseDockManager = False
      DoubleBuffered = True
      ParentBackground = False
      ParentDoubleBuffered = False
      TabOrder = 0
    end
  end
  object pnl_Moves: TPanel
    Left = 0
    Top = 41
    Width = 185
    Height = 798
    Align = alLeft
    Caption = 'pnl_Moves'
    TabOrder = 2
  end
end
