object fmAPMTestMain: TfmAPMTestMain
  Left = 709
  Top = 366
  Caption = 'APM Test Project'
  ClientHeight = 649
  ClientWidth = 1024
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Calibri'
  Font.Style = []
  OldCreateOrder = False
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
  object memMain: TMemo
    Left = 96
    Top = 112
    Width = 433
    Height = 193
    Lines.Strings = (
      'memMain')
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
end
