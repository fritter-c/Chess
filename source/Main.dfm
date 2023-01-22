object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'ChessEngine'
  ClientHeight = 841
  ClientWidth = 985
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
    Width = 985
    Height = 41
    Align = alTop
    TabOrder = 0
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
    Width = 800
    Height = 800
    Align = alClient
    Constraints.MaxHeight = 800
    Constraints.MaxWidth = 800
    Constraints.MinHeight = 800
    Constraints.MinWidth = 800
    TabOrder = 1
    object cbBoard: TChessBoard
      Left = 1
      Top = 1
      Width = 798
      Height = 798
      Align = alClient
      Caption = 'cbBoard'
      UseDockManager = False
      DoubleBuffered = True
      ParentBackground = False
      ParentDoubleBuffered = False
      TabOrder = 0
      OnMouseDown = cbBoardMouseDown
    end
  end
  object pnl_Moves: TPanel
    Left = 0
    Top = 41
    Width = 185
    Height = 800
    Align = alLeft
    Caption = 'pnl_Moves'
    TabOrder = 2
  end
end
