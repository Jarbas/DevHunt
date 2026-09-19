object FrmPedidoVenda: TFrmPedidoVenda
  Left = 0
  Top = 0
  Caption = 'Pedido de Venda'
  ClientHeight = 592
  ClientWidth = 720
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object pnlCliente: TPanel
    Left = 8
    Top = 8
    Width = 704
    Height = 120
    BevelOuter = bvNone
    TabOrder = 0
    object lblCliente: TLabel
      Left = 0
      Top = 4
      Width = 37
      Height = 15
      Caption = 'Cliente'
    end
    object lblObservacao: TLabel
      Left = 0
      Top = 60
      Width = 62
      Height = 15
      Caption = 'Observa'#231#227'o'
    end
    object edtCodCliente: TEdit
      Left = 2
      Top = 24
      Width = 72
      Height = 23
      TabOrder = 0
      OnChange = edtCodClienteChange
    end
    object edtNomeCliente: TEdit
      Left = 80
      Top = 24
      Width = 320
      Height = 23
      TabStop = False
      ReadOnly = True
      TabOrder = 1
    end
    object edtCidade: TEdit
      Left = 408
      Top = 24
      Width = 200
      Height = 23
      TabStop = False
      ReadOnly = True
      TabOrder = 2
    end
    object edtUF: TEdit
      Left = 616
      Top = 24
      Width = 40
      Height = 23
      TabStop = False
      ReadOnly = True
      TabOrder = 3
    end
    object edtObservacao: TEdit
      Left = 80
      Top = 56
      Width = 576
      Height = 23
      MaxLength = 80
      TabOrder = 4
    end
  end
  object pnlItem: TPanel
    Left = 8
    Top = 136
    Width = 704
    Height = 96
    BevelOuter = bvNone
    TabOrder = 1
    object lblProduto: TLabel
      Left = 0
      Top = 0
      Width = 43
      Height = 15
      Caption = 'Produto'
    end
    object lblDescricao: TLabel
      Left = 80
      Top = 0
      Width = 51
      Height = 15
      Caption = 'Descri'#231#227'o'
    end
    object lblQuantidade: TLabel
      Left = 336
      Top = 0
      Width = 26
      Height = 15
      Caption = 'Qtde'
    end
    object lblVlrUnitario: TLabel
      Left = 424
      Top = 0
      Width = 42
      Height = 15
      Caption = 'Vlr Unit.'
    end
    object lblVlrItem: TLabel
      Left = 520
      Top = 0
      Width = 41
      Height = 15
      Caption = 'Vlr Item'
    end
    object edtCodProduto: TEdit
      Left = 0
      Top = 20
      Width = 72
      Height = 23
      TabOrder = 0
      OnChange = edtCodProdutoChange
    end
    object edtDescricao: TEdit
      Left = 80
      Top = 20
      Width = 248
      Height = 23
      TabStop = False
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 1
    end
    object edtQuantidade: TEdit
      Left = 336
      Top = 20
      Width = 80
      Height = 23
      TabOrder = 2
      Text = '1'
      OnChange = edtQuantidadeChange
    end
    object edtVlrUnitario: TEdit
      Left = 424
      Top = 20
      Width = 88
      Height = 23
      TabOrder = 3
      OnChange = edtVlrUnitarioChange
    end
    object edtVlrItem: TEdit
      Left = 520
      Top = 20
      Width = 88
      Height = 23
      TabStop = False
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 4
    end
    object btnAdicionar: TButton
      Left = 400
      Top = 52
      Width = 176
      Height = 28
      Caption = 'Inserir/Atualizar Item'
      TabOrder = 5
      OnClick = btnAdicionarClick
    end
    object btnExcluirItem: TButton
      Left = 584
      Top = 52
      Width = 112
      Height = 28
      Caption = 'Excluir Item'
      TabOrder = 6
      OnClick = btnExcluirItemClick
    end
  end
  object grdItens: TDBGrid
    Left = 8
    Top = 240
    Width = 704
    Height = 200
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnCellClick = grdItensCellClick
    OnKeyDown = grdItensKeyDown
  end
  object pnlRodape: TPanel
    Left = 8
    Top = 448
    Width = 704
    Height = 132
    BevelOuter = bvNone
    TabOrder = 3
    object lblNumeroPedido: TLabel
      Left = 0
      Top = 4
      Width = 54
      Height = 15
      Caption = 'N'#186' pedido'
    end
    object lblTotalCaption: TLabel
      Left = 447
      Top = 12
      Width = 65
      Height = 15
      Alignment = taRightJustify
      Caption = 'Total pedido'
    end
    object lblTotal: TLabel
      Left = 606
      Top = 8
      Width = 42
      Height = 30
      Alignment = taRightJustify
      Caption = '0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtNumeroPedido: TEdit
      Left = 0
      Top = 24
      Width = 80
      Height = 23
      TabOrder = 0
    end
    object btnCarregar: TButton
      Left = 88
      Top = 22
      Width = 130
      Height = 28
      Caption = 'Carregar Pedido'
      TabOrder = 1
      OnClick = btnCarregarClick
    end
    object btnCancelar: TButton
      Left = 224
      Top = 22
      Width = 130
      Height = 28
      Caption = 'Cancelar Pedido'
      TabOrder = 2
      OnClick = btnCancelarClick
    end
    object btnNovo: TButton
      Left = 0
      Top = 96
      Width = 90
      Height = 28
      Caption = 'Novo'
      TabOrder = 3
      OnClick = btnNovoClick
    end
    object btnGravar: TButton
      Left = 96
      Top = 96
      Width = 90
      Height = 28
      Caption = 'Gravar'
      TabOrder = 4
      OnClick = btnGravarClick
    end
  end
end
