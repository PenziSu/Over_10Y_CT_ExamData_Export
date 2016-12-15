object Form1: TForm1
  Left = 257
  Top = 141
  Width = 896
  Height = 506
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnSearch_XR2: TButton
    Left = 16
    Top = 16
    Width = 129
    Height = 49
    Caption = 'GO!'
    TabOrder = 0
    OnClick = btnSearch_XR2Click
  end
  object rzdbgrd1: TRzDBGrid
    Left = 16
    Top = 96
    Width = 417
    Height = 353
    DataSource = dds1
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object CT16: TRzRadioButton
    Left = 288
    Top = 16
    Width = 115
    Height = 17
    Caption = '16切CT'
    TabOrder = 2
  end
  object CT64: TRzRadioButton
    Left = 408
    Top = 16
    Width = 115
    Height = 17
    Caption = '64切CT'
    TabOrder = 3
  end
  object CT8: TRzRadioButton
    Left = 160
    Top = 16
    Width = 115
    Height = 17
    Caption = '8切CT'
    TabOrder = 4
  end
  object Date_month: TRzSpinEdit
    Left = 288
    Top = 40
    Width = 65
    Height = 45
    Max = 12
    Min = 1
    Value = 1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
  object Date_year: TRzSpinEdit
    Left = 160
    Top = 40
    Width = 89
    Height = 45
    Max = 105
    Min = 100
    Value = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -32
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
  object dds1: TDataSource
    DataSet = cds1
    Left = 112
    Top = 40
  end
  object cds1: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = '#'
        DataType = ftString
        Size = 3
      end
      item
        Name = '月份'
        DataType = ftString
        Size = 6
      end
      item
        Name = '身份'
        DataType = ftString
        Size = 4
      end
      item
        Name = '門診/住院'
        DataType = ftString
        Size = 2
      end
      item
        Name = '報到日期'
        DataType = ftString
        Size = 8
      end
      item
        Name = '病歷號'
        DataType = ftString
        Size = 10
      end
      item
        Name = '病患姓名'
        DataType = ftString
        Size = 10
      end
      item
        Name = '醫令碼'
        DataType = ftString
        Size = 8
      end
      item
        Name = '檢查敘述'
        DataType = ftString
        Size = 30
      end
      item
        Name = '儀器代碼'
        DataType = ftString
        Size = 4
      end
      item
        Name = '檢查單號'
        DataType = ftString
        Size = 12
      end
      item
        Name = '儀器類別'
        DataType = ftString
        Size = 4
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 24
    Top = 32
  end
end
