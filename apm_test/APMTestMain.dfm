object fmAPMTestMain: TfmAPMTestMain
  Left = 300
  Top = 121
  Caption = 'APM Test Project'
  ClientHeight = 649
  ClientWidth = 1007
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 18
  object btnTestTx: TButton
    Left = 64
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Test TX'
    TabOrder = 0
    OnClick = btnTestTxClick
  end
  object memGenerated: TMemo
    Left = 40
    Top = 88
    Width = 825
    Height = 233
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
  object btnSpans: TButton
    Left = 208
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Test Spans'
    TabOrder = 2
    OnClick = btnSpansClick
  end
  object memPost: TMemo
    Left = 40
    Top = 360
    Width = 825
    Height = 233
    ScrollBars = ssBoth
    TabOrder = 3
    WordWrap = False
  end
  object btnPost: TButton
    Left = 888
    Top = 368
    Width = 75
    Height = 25
    Caption = 'Post'
    TabOrder = 4
    OnClick = btnPostClick
  end
  object odURLs: TOpenDialog
    DefaultExt = 'txt'
    Filter = 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*'
    Left = 368
    Top = 48
  end
end
