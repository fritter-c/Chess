object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Chess'
  ClientHeight = 835
  ClientWidth = 979
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
    Width = 979
    Height = 41
    Align = alTop
    TabOrder = 0
    object lblStatus: TLabel
      Left = 307
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
      Left = 903
      Top = 1
      Width = 75
      Height = 39
      Align = alRight
      Caption = 'Flip Board'
      TabOrder = 1
      OnClick = btnFlipClick
    end
    object btnStart: TButton
      Left = 76
      Top = 1
      Width = 75
      Height = 39
      Align = alLeft
      Caption = 'Start'
      TabOrder = 2
      OnClick = btnStartClick
    end
    object btnConfigure: TBitBtn
      Left = 151
      Top = 1
      Width = 75
      Height = 39
      Align = alLeft
      Caption = 'Configure'
      ModalResult = 5
      NumGlyphs = 2
      TabOrder = 3
      OnClick = btnConfigureClick
    end
    object btnReplay: TButton
      Left = 226
      Top = 1
      Width = 75
      Height = 39
      Align = alLeft
      Caption = 'Replay'
      TabOrder = 4
      OnClick = btnReplayClick
    end
    object btnConnect: TButton
      Left = 828
      Top = 1
      Width = 75
      Height = 39
      Align = alRight
      Caption = 'Connect'
      TabOrder = 5
      OnClick = btnConnectClick
    end
    object pnlStatus: TPanel
      Left = 643
      Top = 1
      Width = 185
      Height = 39
      Align = alRight
      Caption = 'pnlStatus'
      ShowCaption = False
      TabOrder = 6
      object lblConnectionStatus: TLabel
        Left = 1
        Top = 1
        Width = 183
        Height = 37
        Align = alClient
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        ExplicitWidth = 5
        ExplicitHeight = 21
      end
    end
  end
  object pnl_Board: TPanel
    Left = 185
    Top = 41
    Width = 794
    Height = 794
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    Constraints.MaxHeight = 798
    Constraints.MaxWidth = 798
    Constraints.MinHeight = 794
    Constraints.MinWidth = 794
    TabOrder = 1
    object cbBoard: TChessBoard
      Left = 1
      Top = 1
      Width = 792
      Height = 792
      Align = alClient
      Caption = 'cbBoard'
      UseDockManager = False
      DoubleBuffered = True
      ParentBackground = False
      ParentDoubleBuffered = False
      TabOrder = 0
      ExplicitLeft = 320
      ExplicitTop = 320
      ExplicitWidth = 100
      ExplicitHeight = 41
    end
  end
  object pnl_SidePanel: TPanel
    Left = 0
    Top = 41
    Width = 185
    Height = 794
    Align = alLeft
    Caption = 'pnl_SidePanel'
    TabOrder = 2
    object redtMoves: TRichEdit
      Left = 1
      Top = 42
      Width = 183
      Height = 710
      Align = alClient
      Color = clMenuBar
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      Zoom = 100
      ExplicitTop = 1
      ExplicitHeight = 792
    end
    object Clock_2: TSimpleClock
      Left = 1
      Top = 752
      Width = 183
      Height = 41
      Align = alBottom
      Caption = 'Clock_2'
      UseDockManager = False
      ParentBackground = False
      TabOrder = 1
      ExplicitLeft = 32
      ExplicitTop = 720
      ExplicitWidth = 100
    end
    object Clock_1: TSimpleClock
      Left = 1
      Top = 1
      Width = 183
      Height = 41
      Align = alTop
      Caption = 'Clock_1'
      UseDockManager = False
      ParentBackground = False
      TabOrder = 2
      ExplicitLeft = 80
      ExplicitTop = 344
      ExplicitWidth = 100
    end
  end
end
