object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'DecSoft Ollama For Delphi Version Demo'
  ClientHeight = 468
  ClientWidth = 467
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object BottomPanel: TPanel
    Left = 0
    Top = 370
    Width = 467
    Height = 98
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      467
      98)
    object GetVersionButton: TButton
      Left = 277
      Top = 24
      Width = 179
      Height = 34
      Anchors = [akTop, akRight]
      Caption = 'Get Ollama version'
      TabOrder = 0
      OnClick = GetVersionButtonClick
    end
    object StatusBar: TStatusBar
      Left = 1
      Top = 78
      Width = 465
      Height = 19
      Panels = <>
    end
  end
  object VersionMemo: TMemo
    Left = 0
    Top = 0
    Width = 467
    Height = 370
    Align = alClient
    DoubleBuffered = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentDoubleBuffered = False
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
