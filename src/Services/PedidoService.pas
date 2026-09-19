unit PedidoService;

interface

uses
  Pedido,
  PedidoItem,
  Cliente,
  Produto,
  ClienteRepository,
  ProdutoRepository,
  PedidoRepository,
  DatabaseConnection,
  AppExceptions;

type
  TPedidoService = class
  private
    FDb: TDatabaseConnection;
    FClienteRepo: TClienteRepository;
    FProdutoRepo: TProdutoRepository;
    FPedidoRepo: TPedidoRepository;
    procedure ValidarCliente(APedido: TPedido);
    procedure ValidarItens(APedido: TPedido);
  public
    constructor Create(ADb: TDatabaseConnection);
    destructor Destroy; override;
    function CarregarCliente(ACodigo: Integer): TCliente;
    function CarregarProduto(ACodigo: Integer): TProduto;
    procedure DefinirCliente(APedido: TPedido; ACodigo: Integer);
    procedure AdicionarItem(APedido: TPedido; ACodigoProduto: Integer;
      AQuantidade, AVlrUnitario: Currency);
    procedure AtualizarItem(APedido: TPedido; AIndex: Integer;
      ACodigoProduto: Integer; AQuantidade, AVlrUnitario: Currency);
    procedure RemoverItem(APedido: TPedido; AIndex: Integer);
    procedure CalcularTotal(APedido: TPedido);
    function GravarPedido(APedido: TPedido): Integer;
    function CarregarPedido(ANumero: Integer): TPedido;
    procedure CancelarPedido(ANumero: Integer);
  end;

implementation

uses
  System.SysUtils;

constructor TPedidoService.Create(ADb: TDatabaseConnection);
begin
  inherited Create;
  FDb := ADb;
  FClienteRepo := TClienteRepository.Create(ADb);
  FProdutoRepo := TProdutoRepository.Create(ADb);
  FPedidoRepo := TPedidoRepository.Create(ADb);
end;

destructor TPedidoService.Destroy;
begin
  FPedidoRepo.Free;
  FProdutoRepo.Free;
  FClienteRepo.Free;
  inherited;
end;

function TPedidoService.CarregarCliente(ACodigo: Integer): TCliente;
begin
  if ACodigo <= 0 then
    raise EValidacao.Create('Informe o codigo do cliente.');
  Result := FClienteRepo.BuscarPorCodigo(ACodigo);
end;

function TPedidoService.CarregarProduto(ACodigo: Integer): TProduto;
begin
  if ACodigo <= 0 then
    raise EValidacao.Create('Informe o codigo do produto.');
  Result := FProdutoRepo.BuscarPorCodigo(ACodigo);
end;

procedure TPedidoService.DefinirCliente(APedido: TPedido; ACodigo: Integer);
var
  Cliente: TCliente;
begin
  Cliente := CarregarCliente(ACodigo);
  try
    APedido.Cliente.Codigo := Cliente.Codigo;
    APedido.Cliente.Nome := Cliente.Nome;
    APedido.Cliente.Cidade := Cliente.Cidade;
    APedido.Cliente.UF := Cliente.UF;
  finally
    Cliente.Free;
  end;
end;

procedure TPedidoService.AdicionarItem(APedido: TPedido; ACodigoProduto: Integer;
  AQuantidade, AVlrUnitario: Currency);
var
  Produto: TProduto;
  Item: TPedidoItem;
begin
  if AQuantidade <= 0 then
    raise EValidacao.Create('Quantidade deve ser maior que zero.');
  if AVlrUnitario < 0 then
    raise EValidacao.Create('Valor unitario nao pode ser negativo.');

  Produto := FProdutoRepo.BuscarPorCodigo(ACodigoProduto);
  try
    Item := TPedidoItem.Create;
    Item.CodigoProduto := Produto.Codigo;
    Item.Descricao := Produto.Descricao;
    Item.Quantidade := AQuantidade;
    Item.VlrUnitario := AVlrUnitario;
    Item.CalcularTotal;
    APedido.Itens.Add(Item);
  finally
    Produto.Free;
  end;
  APedido.CalcularTotal;
end;

procedure TPedidoService.AtualizarItem(APedido: TPedido; AIndex: Integer;
  ACodigoProduto: Integer; AQuantidade, AVlrUnitario: Currency);
var
  Item: TPedidoItem;
  Produto: TProduto;
begin
  Item := APedido.ItemPorIndice(AIndex);
  if Item = nil then
    raise EValidacao.Create('Item do pedido nao encontrado.');
  if AQuantidade <= 0 then
    raise EValidacao.Create('Quantidade deve ser maior que zero.');
  if AVlrUnitario < 0 then
    raise EValidacao.Create('Valor unitario nao pode ser negativo.');

  if ACodigoProduto <> Item.CodigoProduto then
  begin
    Produto := FProdutoRepo.BuscarPorCodigo(ACodigoProduto);
    try
      Item.CodigoProduto := Produto.Codigo;
      Item.Descricao := Produto.Descricao;
    finally
      Produto.Free;
    end;
  end;

  Item.Quantidade := AQuantidade;
  Item.VlrUnitario := AVlrUnitario;
  Item.CalcularTotal;
  APedido.CalcularTotal;
end;

procedure TPedidoService.RemoverItem(APedido: TPedido; AIndex: Integer);
begin
  if APedido.ItemPorIndice(AIndex) = nil then
    raise EValidacao.Create('Item do pedido nao encontrado.');
  APedido.Itens.Delete(AIndex);
  APedido.CalcularTotal;
end;

procedure TPedidoService.CalcularTotal(APedido: TPedido);
begin
  APedido.CalcularTotal;
end;

procedure TPedidoService.ValidarCliente(APedido: TPedido);
begin
  if APedido.Cliente.Codigo <= 0 then
    raise EValidacao.Create('Informe o codigo do cliente.');
  if not APedido.Cliente.EstaCarregado then
    raise EValidacao.CreateFmt('Cliente %d nao encontrado.', [APedido.Cliente.Codigo]);
end;

procedure TPedidoService.ValidarItens(APedido: TPedido);
begin
  if APedido.Itens.Count = 0 then
    raise EValidacao.Create('Inclua ao menos um item no pedido.');
end;

function TPedidoService.GravarPedido(APedido: TPedido): Integer;
begin
  ValidarCliente(APedido);
  ValidarItens(APedido);
  APedido.CalcularTotal;

  FDb.IniciarTransacao;
  try
    if APedido.NumeroPedido > 0 then
      FPedidoRepo.Atualizar(APedido)
    else
    begin
      APedido.NumeroPedido := FPedidoRepo.ProximoNumero;
      FPedidoRepo.Inserir(APedido);
    end;
    FDb.ConfirmarTransacao;
    Result := APedido.NumeroPedido;
  except
    FDb.DesfazerTransacao;
    raise;
  end;
end;

function TPedidoService.CarregarPedido(ANumero: Integer): TPedido;
begin
  if ANumero <= 0 then
    raise EValidacao.Create('Informe o numero do pedido.');
  Result := FPedidoRepo.BuscarPorNumero(ANumero);
end;

procedure TPedidoService.CancelarPedido(ANumero: Integer);
begin
  if ANumero <= 0 then
    raise EValidacao.Create('Informe o numero do pedido.');

  FDb.IniciarTransacao;
  try
    FPedidoRepo.Excluir(ANumero);
    FDb.ConfirmarTransacao;
  except
    FDb.DesfazerTransacao;
    raise;
  end;
end;

end.
