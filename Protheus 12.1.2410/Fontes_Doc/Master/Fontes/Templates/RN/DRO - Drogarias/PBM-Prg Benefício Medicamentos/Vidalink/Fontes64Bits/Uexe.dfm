object Form1: TForm1
  Left = 192
  Top = 114
  Caption = 'Teste de chamada da DLL - versao 64bits'
  ClientHeight = 98
  ClientWidth = 388
  Color = 16744576
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 25
    Height = 13
    Caption = 'EAN:'
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 61
    Height = 13
    Caption = 'Informa'#231#245'es:'
  end
  object Label3: TLabel
    Left = 8
    Top = 83
    Width = 36
    Height = 13
    Caption = 'Tempo:'
  end
  object lblTempo: TLabel
    Left = 48
    Top = 83
    Width = 42
    Height = 13
    Caption = '00:00:00'
  end
  object Button1: TButton
    Left = 184
    Top = 8
    Width = 97
    Height = 25
    Caption = 'Configura'#231#245'es'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 288
    Top = 8
    Width = 97
    Height = 25
    Caption = 'Testar'
    TabOrder = 1
    OnClick = Button2Click
  end
  object txtEan: TEdit
    Left = 40
    Top = 8
    Width = 137
    Height = 21
    TabOrder = 2
    Text = '1234567890123'
  end
  object txtInfo: TEdit
    Left = 8
    Top = 56
    Width = 377
    Height = 21
    TabOrder = 3
  end
  object Button3: TButton
    Left = 304
    Top = 80
    Width = 73
    Height = 17
    Caption = 'Desconectar'
    TabOrder = 4
    OnClick = Button3Click
  end
end
