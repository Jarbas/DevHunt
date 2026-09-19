unit uFrmPedidoVenda;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.DBGrids,
  Pedido,
  PedidoItem,
  Produto,
  PedidoService,
  DatabaseConnection,
  AppExceptions, Vcl.Grids;

type
  TFrmPedidoVenda = class(TForm)
    pnlCliente: TPanel;
    lblCliente: TLabel;
    edtCodCliente: TEdit;
    edtNomeCliente: TEdit;
    edtCidade: TEdit;
    edtUF: TEdit;
    lblObservacao: TLabel;
    edtObservacao: TEdit;
    pnlItem: TPanel;
    lblProduto: TLabel;
    lblDescricao: TLabel;
    lblQuantidade: TLabel;
    lblVlrUnitario: TLabel;
    lblVlrItem: TLabel;
    edtCodProduto: TEdit;
    edtDescricao: TEdit;
    edtQuantidade: TEdit;
    edtVlrUnitario: TEdit;
    edtVlrItem: TEdit;
    btnAdicionar: TButton;
    btnExcluirItem: TButton;
    grdItens: TDBGrid;
    pnlRodape: TPanel;
    lblTotalCaption: TLabel;
    lblTotal: TLabel;
    lblNumeroPedido: TLabel;
    edtNumeroPedido: TEdit;
    btnCarregar: TButton;
    btnCancelar: TButton;
    btnGravar: TButton;
    btnNovo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtCodClienteChange(Sender: TObject);
    procedure edtCodProdutoChange(Sender: TObject);
    procedure edtQuantidadeChange(Sender: TObject);
    procedure edtVlrUnitarioChange(Sender: TObject);
    procedure btnAdicionarClick(Sender: TObject);
    procedure btnExcluirItemClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnCarregarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure grdItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure grdItensCellClick(Column: TColumn);
  private
    FDb: TDatabaseConnection;
    FPedidoService: TPedidoService;
    FPedido: TPedido;
    FItensTable: TFDMemTable;
    FItensSource: TDataSource;
    FIndiceItem: Integer;
    FAtualizandoTela: Boolean;
    procedure NovoPedido;
    procedure ExibirPedido;
    procedure AtualizarCabecalho;
    procedure AtualizarGrid;
    procedure AtualizarTotal;
    procedure AtualizarTotalItem;
    procedure ConfigurarGrid;
    function TextoParaMoeda(const ATexto: string): Currency;
    function QuantidadeInformada: Currency;
    function ValorUnitarioInformado: Currency;
    function NumeroInformado: Integer;
    function IndiceItemPorProduto(ACodigo: Integer): Integer;
    procedure LimparCamposItem;
    procedure CarregarItemNaTela(AIndex: Integer);
    procedure MostrarErro(const E: Exception);
    procedure Focar(AControl: TWinControl);
    procedure LimparClienteExibido;
    procedure LimparProdutoExibido;
    procedure RemoverItemSelecionado;
  public
  end;

var
  FrmPedidoVenda: TFrmPedidoVenda;

implementation

{$R *.dfm}

uses
  DatabaseConfig,
  AppConsts;

procedure TFrmPedidoVenda.FormCreate(Sender: TObject);
var
  Config: TDatabaseConfig;
begin
  Config := TDatabaseConfig.FromIni(ConfigFileName);
  FDb := TDatabaseConnection.Create(Config);
  FDb.Conectar;
  FPedidoService := TPedidoService.Create(FDb);
  FPedido := TPedido.Create;
  ConfigurarGrid;
  NovoPedido;
end;

procedure TFrmPedidoVenda.FormDestroy(Sender: TObject);
begin
  FPedido.Free;
  FPedidoService.Free;
  FDb.Free;
end;

procedure TFrmPedidoVenda.ConfigurarGrid;
begin
  FItensTable := TFDMemTable.Create(Self);
  FItensTable.FieldDefs.Add('CODIGO', ftInteger);
  FItensTable.FieldDefs.Add('DESCRICAO', ftString, 80);
  FItensTable.FieldDefs.Add('QTDE', ftCurrency);
  FItensTable.FieldDefs.Add('VLR_UNIT', ftCurrency);
  FItensTable.FieldDefs.Add('VLR_TOTAL', ftCurrency);
  FItensTable.CreateDataSet;
  FItensTable.LogChanges := False;

  FItensTable.FieldByName('CODIGO').DisplayLabel := 'Produto';
  FItensTable.FieldByName('DESCRICAO').DisplayLabel := 'Descrição';
  FItensTable.FieldByName('QTDE').DisplayLabel := 'Qtde';
  FItensTable.FieldByName('VLR_UNIT').DisplayLabel := 'Vlr Unit.';
  FItensTable.FieldByName('VLR_TOTAL').DisplayLabel := 'Vlr Total';
  TNumericField(FItensTable.FieldByName('QTDE')).DisplayFormat := '#,##0.000';
  TNumericField(FItensTable.FieldByName('VLR_UNIT')).DisplayFormat := '#,##0.00';
  TNumericField(FItensTable.FieldByName('VLR_TOTAL')).DisplayFormat := '#,##0.00';
  FItensTable.FieldByName('CODIGO').DisplayWidth := 8;
  FItensTable.FieldByName('DESCRICAO').DisplayWidth := 32;
  FItensTable.FieldByName('QTDE').DisplayWidth := 10;
  FItensTable.FieldByName('VLR_UNIT').DisplayWidth := 12;
  FItensTable.FieldByName('VLR_TOTAL').DisplayWidth := 12;

  FItensSource := TDataSource.Create(Self);
  FItensSource.DataSet := FItensTable;
  grdItens.DataSource := FItensSource;
  grdItens.ReadOnly := True;
  grdItens.Options := grdItens.Options + [dgRowSelect] - [dgEditing];
end;

procedure TFrmPedidoVenda.NovoPedido;
begin
  FPedido.Free;
  FPedido := TPedido.Create;
  FIndiceItem := -1;
  edtNumeroPedido.Clear;
  edtCodCliente.Clear;
  LimparCamposItem;
  ExibirPedido;
  Focar(edtCodCliente);
end;

procedure TFrmPedidoVenda.ExibirPedido;
begin
  FAtualizandoTela := True;
  try
    if FPedido.NumeroPedido > 0 then
      edtNumeroPedido.Text := IntToStr(FPedido.NumeroPedido)
    else
      edtNumeroPedido.Clear;
    if FPedido.Cliente.Codigo > 0 then
      edtCodCliente.Text := IntToStr(FPedido.Cliente.Codigo)
    else
      edtCodCliente.Clear;
    AtualizarCabecalho;
  finally
    FAtualizandoTela := False;
  end;
  AtualizarGrid;
  AtualizarTotal;
end;

procedure TFrmPedidoVenda.FormShow(Sender: TObject);
begin
  Focar(edtCodCliente);
end;

procedure TFrmPedidoVenda.Focar(AControl: TWinControl);
begin
  if (AControl = nil) or (not Showing) or (not HandleAllocated) then
    Exit;
  if (not AControl.Visible) or (not AControl.Enabled) then
    Exit;
  try
    ActiveControl := AControl;
  except
  end;
end;

procedure TFrmPedidoVenda.AtualizarCabecalho;
begin
  edtNomeCliente.Text := FPedido.Cliente.Nome;
  edtCidade.Text := FPedido.Cliente.Cidade;
  edtUF.Text := FPedido.Cliente.UF;
  edtObservacao.Text := FPedido.Observacao;
end;

procedure TFrmPedidoVenda.AtualizarGrid;
var
  Item: TPedidoItem;
begin
  FItensTable.DisableControls;
  try
    FItensTable.EmptyDataSet;
    for Item in FPedido.Itens do
    begin
      FItensTable.Append;
      FItensTable.FieldByName('CODIGO').AsInteger := Item.CodigoProduto;
      FItensTable.FieldByName('DESCRICAO').AsString := Item.Descricao;
      FItensTable.FieldByName('QTDE').AsCurrency := Item.Quantidade;
      FItensTable.FieldByName('VLR_UNIT').AsCurrency := Item.VlrUnitario;
      FItensTable.FieldByName('VLR_TOTAL').AsCurrency := Item.VlrTotal;
      FItensTable.Post;
    end;
    if not FItensTable.IsEmpty then
      FItensTable.First;
  finally
    FItensTable.EnableControls;
  end;
end;

procedure TFrmPedidoVenda.AtualizarTotal;
begin
  FPedido.CalcularTotal;
  lblTotal.Caption := FormatFloat('#,##0.00', FPedido.ValorTotal);
  lblTotal.Update;
end;

procedure TFrmPedidoVenda.AtualizarTotalItem;
begin
  edtVlrItem.Text := FormatFloat('#,##0.00', QuantidadeInformada * ValorUnitarioInformado);
end;

function TFrmPedidoVenda.TextoParaMoeda(const ATexto: string): Currency;
var
  S: string;
begin
  S := Trim(ATexto);
  if S = '' then
    Exit(0);
  if Pos(',', S) > 0 then
  begin
    S := StringReplace(S, '.', '', [rfReplaceAll]);
    S := StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  end
  else if Pos('.', S) > 0 then
    S := StringReplace(S, '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := StrToCurrDef(S, 0);
end;

function TFrmPedidoVenda.QuantidadeInformada: Currency;
begin
  Result := TextoParaMoeda(edtQuantidade.Text);
end;

function TFrmPedidoVenda.ValorUnitarioInformado: Currency;
begin
  Result := TextoParaMoeda(edtVlrUnitario.Text);
end;

function TFrmPedidoVenda.IndiceItemPorProduto(ACodigo: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to FPedido.Itens.Count - 1 do
    if FPedido.Itens[I].CodigoProduto = ACodigo then
      Exit(I);
  Result := -1;
end;

procedure TFrmPedidoVenda.LimparCamposItem;
begin
  FAtualizandoTela := True;
  try
    FIndiceItem := -1;
    edtCodProduto.Clear;
    edtDescricao.Clear;
    edtQuantidade.Text := '1';
    edtVlrUnitario.Clear;
    edtVlrItem.Clear;
  finally
    FAtualizandoTela := False;
  end;
end;

procedure TFrmPedidoVenda.CarregarItemNaTela(AIndex: Integer);
var
  Item: TPedidoItem;
begin
  Item := FPedido.ItemPorIndice(AIndex);
  if Item = nil then
    Exit;
  FIndiceItem := AIndex;
  FAtualizandoTela := True;
  try
    edtCodProduto.Text := IntToStr(Item.CodigoProduto);
    edtDescricao.Text := Item.Descricao;
    edtQuantidade.Text := FormatFloat('#,##0.000', Item.Quantidade);
    edtVlrUnitario.Text := FormatFloat('#,##0.00', Item.VlrUnitario);
    edtVlrItem.Text := FormatFloat('#,##0.00', Item.VlrTotal);
  finally
    FAtualizandoTela := False;
  end;
end;

function TFrmPedidoVenda.NumeroInformado: Integer;
begin
  Result := StrToIntDef(Trim(edtNumeroPedido.Text), 0);
  if Result <= 0 then
    Result := FPedido.NumeroPedido;
end;

procedure TFrmPedidoVenda.MostrarErro(const E: Exception);
begin
  MessageDlg(E.Message, mtError, [mbOK], 0);
end;

procedure TFrmPedidoVenda.LimparClienteExibido;
begin
  if FPedido = nil then
    Exit;
  FPedido.Cliente.Codigo := 0;
  FPedido.Cliente.Nome := '';
  FPedido.Cliente.Cidade := '';
  FPedido.Cliente.UF := '';
  AtualizarCabecalho;
end;

procedure TFrmPedidoVenda.edtCodClienteChange(Sender: TObject);
var
  Codigo: Integer;
  Texto: string;
begin
  if FAtualizandoTela or (FPedido = nil) or (FPedidoService = nil) then
    Exit;

  Texto := Trim(edtCodCliente.Text);
  if Texto = '' then
  begin
    LimparClienteExibido;
    Exit;
  end;

  Codigo := StrToIntDef(Texto, 0);
  if Codigo <= 0 then
  begin
    LimparClienteExibido;
    Exit;
  end;

  try
    FPedidoService.DefinirCliente(FPedido, Codigo);
    AtualizarCabecalho;
  except
    on E: EAppException do
    begin
      LimparClienteExibido;
      MostrarErro(E);
    end;
  end;
end;

procedure TFrmPedidoVenda.LimparProdutoExibido;
begin
  edtDescricao.Clear;
  edtVlrUnitario.Clear;
  edtVlrItem.Clear;
end;

procedure TFrmPedidoVenda.edtCodProdutoChange(Sender: TObject);
var
  Produto: TProduto;
  Codigo: Integer;
  Texto: string;
begin
  if FAtualizandoTela or (FPedidoService = nil) then
    Exit;

  Texto := Trim(edtCodProduto.Text);
  if Texto = '' then
  begin
    LimparProdutoExibido;
    Exit;
  end;

  Codigo := StrToIntDef(Texto, 0);
  if Codigo <= 0 then
  begin
    LimparProdutoExibido;
    Exit;
  end;

  try
    Produto := FPedidoService.CarregarProduto(Codigo);
    try
      edtDescricao.Text := Produto.Descricao;
      edtVlrUnitario.Text := FormatFloat('#,##0.00', Produto.PrecoVenda);
      AtualizarTotalItem;
    finally
      Produto.Free;
    end;
  except
    on E: EAppException do
      LimparProdutoExibido;
  end;
end;

procedure TFrmPedidoVenda.edtQuantidadeChange(Sender: TObject);
begin
  if FAtualizandoTela then
    Exit;
  AtualizarTotalItem;
end;

procedure TFrmPedidoVenda.edtVlrUnitarioChange(Sender: TObject);
begin
  if FAtualizandoTela then
    Exit;
  AtualizarTotalItem;
end;

procedure TFrmPedidoVenda.RemoverItemSelecionado;
var
  Indice: Integer;
begin
  if (FItensTable = nil) or FItensTable.IsEmpty then
  begin
    MessageDlg('Selecione um item para excluir.', mtError, [mbOK], 0);
    Exit;
  end;
  Indice := FItensTable.RecNo - 1;
  if FIndiceItem >= 0 then
    Indice := FIndiceItem;
  try
    FPedidoService.RemoverItem(FPedido, Indice);
    FIndiceItem := -1;
    AtualizarGrid;
    AtualizarTotal;
    LimparCamposItem;
    Focar(edtCodProduto);
  except
    on E: EAppException do
      MostrarErro(E);
  end;
end;

procedure TFrmPedidoVenda.btnExcluirItemClick(Sender: TObject);
begin
  RemoverItemSelecionado;
end;

procedure TFrmPedidoVenda.btnAdicionarClick(Sender: TObject);
var
  Codigo: Integer;
  Indice: Integer;
begin
  Codigo := StrToIntDef(Trim(edtCodProduto.Text), 0);
  if Codigo <= 0 then
  begin
    MessageDlg('Informe o codigo do produto.', mtError, [mbOK], 0);
    Focar(edtCodProduto);
    Exit;
  end;
  if QuantidadeInformada <= 0 then
  begin
    MessageDlg('Informe a quantidade.', mtError, [mbOK], 0);
    Focar(edtQuantidade);
    Exit;
  end;

  Indice := FIndiceItem;
  if Indice < 0 then
    Indice := IndiceItemPorProduto(Codigo);

  try
    if Indice >= 0 then
      FPedidoService.AtualizarItem(
        FPedido, Indice, Codigo, QuantidadeInformada, ValorUnitarioInformado)
    else
      FPedidoService.AdicionarItem(
        FPedido, Codigo, QuantidadeInformada, ValorUnitarioInformado);
    AtualizarGrid;
    AtualizarTotal;
    LimparCamposItem;
    Focar(edtCodProduto);
  except
    on E: EAppException do
      MostrarErro(E);
  end;
end;

procedure TFrmPedidoVenda.btnGravarClick(Sender: TObject);
var
  Numero: Integer;
  Atualizando: Boolean;
begin
  FPedido.NumeroPedido := NumeroInformado;
  FPedido.Observacao := Trim(edtObservacao.Text);
  Atualizando := FPedido.NumeroPedido > 0;
  try
    Numero := FPedidoService.GravarPedido(FPedido);
    if Atualizando then
      MessageDlg(Format('Pedido %d atualizado com sucesso.', [Numero]), mtInformation, [mbOK], 0)
    else
      MessageDlg(Format('Pedido %d gravado com sucesso.', [Numero]), mtInformation, [mbOK], 0);
    NovoPedido;
  except
    on E: Exception do
      MostrarErro(E);
  end;
end;

procedure TFrmPedidoVenda.btnNovoClick(Sender: TObject);
begin
  NovoPedido;
  Focar(edtCodCliente);
end;

procedure TFrmPedidoVenda.btnCarregarClick(Sender: TObject);
var
  Carregado: TPedido;
begin
  try
    Carregado := FPedidoService.CarregarPedido(NumeroInformado);
    FPedido.Free;
    FPedido := Carregado;
    ExibirPedido;
  except
    on E: EAppException do
      MostrarErro(E);
  end;
end;

procedure TFrmPedidoVenda.btnCancelarClick(Sender: TObject);
var
  Numero: Integer;
begin
  Numero := NumeroInformado;
  if Numero <= 0 then
  begin
    MessageDlg('Informe o numero do pedido.', mtError, [mbOK], 0);
    Focar(edtNumeroPedido);
    Exit;
  end;
  if MessageDlg(Format('Cancelar o pedido %d e seus itens?', [Numero]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  try
    FPedidoService.CancelarPedido(Numero);
    MessageDlg(Format('Pedido %d cancelado.', [Numero]), mtInformation, [mbOK], 0);
    NovoPedido;
  except
    on E: EAppException do
      MostrarErro(E);
  end;
end;

procedure TFrmPedidoVenda.grdItensCellClick(Column: TColumn);
begin
  if (FItensTable = nil) or FItensTable.IsEmpty then
    Exit;
  CarregarItemNaTela(FItensTable.RecNo - 1);
end;

procedure TFrmPedidoVenda.grdItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_DELETE then
    Exit;
  Key := 0;
  RemoverItemSelecionado;
end;

end.
