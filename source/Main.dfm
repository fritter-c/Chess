object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'ChessEngine'
  ClientHeight = 839
  ClientWidth = 983
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pnl_Status: TPanel
    Left = 0
    Top = 0
    Width = 983
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 985
    object btnNewGame: TButton
      Left = 32
      Top = 8
      Width = 75
      Height = 25
      Caption = 'New Game'
      TabOrder = 0
      OnClick = btnNewGameClick
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
      Width = 796
      Height = 796
      Align = alClient
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      Caption = 'cbBoard'
      UseDockManager = False
      ParentBackground = False
      TabOrder = 0
      ExplicitHeight = 798
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
    ExplicitHeight = 800
  end
end
