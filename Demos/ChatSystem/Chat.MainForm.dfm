object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'DecSoft Ollama For Delphi Chat System Demo'
  ClientHeight = 634
  ClientWidth = 1004
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object BottomPanel: TPanel
    Left = 0
    Top = 478
    Width = 1004
    Height = 156
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      1004
      156)
    object PromptLabel: TLabel
      Left = 16
      Top = 16
      Width = 34
      Height = 13
      Caption = 'Prompt'
    end
    object ModelLabel: TLabel
      Left = 670
      Top = 16
      Width = 28
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Model'
      ExplicitLeft = 632
    end
    object PromptMemo: TMemo
      Left = 16
      Top = 35
      Width = 631
      Height = 81
      Anchors = [akLeft, akTop, akRight]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      Lines.Strings = (
        'What color is the sky?')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 0
    end
    object ModelEdit: TEdit
      Left = 670
      Top = 35
      Width = 177
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 1
      Text = 'gemma3'
    end
    object ChatButton: TButton
      Left = 670
      Top = 72
      Width = 75
      Height = 34
      Anchors = [akTop, akRight]
      Caption = 'Chat'
      TabOrder = 2
      OnClick = ChatButtonClick
    end
    object CancelButton: TButton
      Left = 772
      Top = 72
      Width = 75
      Height = 34
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      Enabled = False
      TabOrder = 3
      OnClick = CancelButtonClick
    end
    object StreamedCheckBox: TCheckBox
      Left = 870
      Top = 32
      Width = 115
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Streamed response'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object StatusBar: TStatusBar
      Left = 1
      Top = 136
      Width = 1002
      Height = 19
      Panels = <>
    end
  end
  object ResponseMemo: TMemo
    Left = 0
    Top = 0
    Width = 1004
    Height = 478
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
