unit PedidoRepository;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Pedido,
  PedidoItem,
  DatabaseConnection,
  AppExceptions;

type
  TPedidoRepository = class
  private
    FDb: TDatabaseConnection;
    procedure InserirItem(ANumeroPedido: Integer; AItem: TPedidoItem);
    procedure ExcluirItens(ANumero: Integer);
    procedure CarregarItens(APedido: TPedido);
  public
    constructor Create(ADb: TDatabaseConnection);
    function ProximoNumero: Integer;
    procedure Inserir(APedido: TPedido);
    procedure Atualizar(APedido: TPedido);
    function BuscarPorNumero(ANumero: Integer): TPedido;
    procedure Excluir(ANumero: Integer);
  end;

implementation

constructor TPedidoRepository.Create(ADb: TDatabaseConnection);
begin
  inherited Create;
  FDb := ADb;
end;

function TPedidoRepository.ProximoNumero: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDb.Connection;
    Query.SQL.Text := 'SELECT NEXT VALUE FOR GEN_PEDIDO_NUMERO AS NUMERO FROM RDB$DATABASE';
    Query.Open;
    Result := Query.FieldByName('NUMERO').AsInteger;
  finally
    Query.Free;
  end;
end;

procedure TPedidoRepository.InserirItem(ANumeroPedido: Integer; AItem: TPedidoItem);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDb.Connection;
    Query.SQL.Text :=
      'INSERT INTO PEDIDO_ITEM (NUMERO_PEDIDO, CODIGO_PRODUTO, QUANTIDADE, VLR_UNITARIO, VLR_TOTAL) ' +
      'VALUES (:NUMERO_PEDIDO, :CODIGO_PRODUTO, :QUANTIDADE, :VLR_UNITARIO, :VLR_TOTAL)';
    Query.ParamByName('NUMERO_PEDIDO').AsInteger := ANumeroPedido;
    Query.ParamByName('CODIGO_PRODUTO').AsInteger := AItem.CodigoProduto;
    Query.ParamByName('QUANTIDADE').AsCurrency := AItem.Quantidade;
    Query.ParamByName('VLR_UNITARIO').AsCurrency := AItem.VlrUnitario;
    Query.ParamByName('VLR_TOTAL').AsCurrency := AItem.VlrTotal;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TPedidoRepository.Inserir(APedido: TPedido);
var
  Query: TFDQuery;
  Item: TPedidoItem;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDb.Connection;
    Query.SQL.Text :=
      'INSERT INTO PEDIDO (NUMERO_PEDIDO, DATA_EMISSAO, CODIGO_CLIENTE, VALOR_TOTAL, OBSERVACAO) ' +
      'VALUES (:NUMERO_PEDIDO, :DATA_EMISSAO, :CODIGO_CLIENTE, :VALOR_TOTAL, :OBSERVACAO)';
    Query.ParamByName('NUMERO_PEDIDO').AsInteger := APedido.NumeroPedido;
    Query.ParamByName('DATA_EMISSAO').AsDate := APedido.DataEmissao;
    Query.ParamByName('CODIGO_CLIENTE').AsInteger := APedido.Cliente.Codigo;
    Query.ParamByName('VALOR_TOTAL').AsCurrency := APedido.ValorTotal;
    Query.ParamByName('OBSERVACAO').AsString := APedido.Observacao;
    Query.ExecSQL;
  finally
    Query.Free;
  end;

  for Item in APedido.Itens do
    InserirItem(APedido.NumeroPedido, Item);
end;

procedure TPedidoRepository.ExcluirItens(ANumero: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDb.Connection;
    Query.SQL.Text := 'DELETE FROM PEDIDO_ITEM WHERE NUMERO_PEDIDO = :NUMERO';
    Query.ParamByName('NUMERO').AsInteger := ANumero;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TPedidoRepository.Atualizar(APedido: TPedido);
var
  Query: TFDQuery;
  Item: TPedidoItem;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDb.Connection;
    Query.SQL.Text := 'SELECT NUMERO_PEDIDO FROM PEDIDO WHERE NUMERO_PEDIDO = :NUMERO';
    Query.ParamByName('NUMERO').AsInteger := APedido.NumeroPedido;
    Query.Open;
    if Query.IsEmpty then
      raise ERegistroNaoEncontrado.CreateFmt('Pedido %d nao encontrado.', [APedido.NumeroPedido]);
    Query.Close;

    Query.SQL.Text :=
      'UPDATE PEDIDO SET CODIGO_CLIENTE = :CODIGO_CLIENTE, VALOR_TOTAL = :VALOR_TOTAL, ' +
      'OBSERVACAO = :OBSERVACAO WHERE NUMERO_PEDIDO = :NUMERO_PEDIDO';
    Query.ParamByName('CODIGO_CLIENTE').AsInteger := APedido.Cliente.Codigo;
    Query.ParamByName('VALOR_TOTAL').AsCurrency := APedido.ValorTotal;
    Query.ParamByName('OBSERVACAO').AsString := APedido.Observacao;
    Query.ParamByName('NUMERO_PEDIDO').AsInteger := APedido.NumeroPedido;
    Query.ExecSQL;
  finally
    Query.Free;
  end;

  ExcluirItens(APedido.NumeroPedido);
  for Item in APedido.Itens do
    InserirItem(APedido.NumeroPedido, Item);
end;

procedure TPedidoRepository.CarregarItens(APedido: TPedido);
var
  Query: TFDQuery;
  Item: TPedidoItem;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDb.Connection;
    Query.SQL.Text :=
      'SELECT I.ID, I.CODIGO_PRODUTO, I.QUANTIDADE, I.VLR_UNITARIO, I.VLR_TOTAL, ' +
      'P.DESCRICAO ' +
      'FROM PEDIDO_ITEM I ' +
      'JOIN PRODUTO P ON P.CODIGO = I.CODIGO_PRODUTO ' +
      'WHERE I.NUMERO_PEDIDO = :NUMERO ' +
      'ORDER BY I.ID';
    Query.ParamByName('NUMERO').AsInteger := APedido.NumeroPedido;
    Query.Open;
    while not Query.Eof do
    begin
      Item := TPedidoItem.Create;
      Item.Id := Query.FieldByName('ID').AsInteger;
      Item.CodigoProduto := Query.FieldByName('CODIGO_PRODUTO').AsInteger;
      Item.Descricao := Query.FieldByName('DESCRICAO').AsString;
      Item.Quantidade := Query.FieldByName('QUANTIDADE').AsCurrency;
      Item.VlrUnitario := Query.FieldByName('VLR_UNITARIO').AsCurrency;
      Item.VlrTotal := Query.FieldByName('VLR_TOTAL').AsCurrency;
      APedido.Itens.Add(Item);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TPedidoRepository.BuscarPorNumero(ANumero: Integer): TPedido;
var
  Query: TFDQuery;
  Pedido: TPedido;
begin
  Result := nil;
  Pedido := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDb.Connection;
    Query.SQL.Text :=
      'SELECT P.NUMERO_PEDIDO, P.DATA_EMISSAO, P.CODIGO_CLIENTE, P.VALOR_TOTAL, ' +
      'P.OBSERVACAO, C.NOME, C.CIDADE, C.UF ' +
      'FROM PEDIDO P ' +
      'JOIN CLIENTE C ON C.CODIGO = P.CODIGO_CLIENTE ' +
      'WHERE P.NUMERO_PEDIDO = :NUMERO';
    Query.ParamByName('NUMERO').AsInteger := ANumero;
    Query.Open;
    if Query.IsEmpty then
      raise ERegistroNaoEncontrado.CreateFmt('Pedido %d nao encontrado.', [ANumero]);

    Pedido := TPedido.Create;
    Pedido.NumeroPedido := Query.FieldByName('NUMERO_PEDIDO').AsInteger;
    Pedido.DataEmissao := Query.FieldByName('DATA_EMISSAO').AsDateTime;
    Pedido.Cliente.Codigo := Query.FieldByName('CODIGO_CLIENTE').AsInteger;
    Pedido.Cliente.Nome := Query.FieldByName('NOME').AsString;
    Pedido.Cliente.Cidade := Query.FieldByName('CIDADE').AsString;
    Pedido.Cliente.UF := Query.FieldByName('UF').AsString;
    Pedido.Observacao := Query.FieldByName('OBSERVACAO').AsString;
    CarregarItens(Pedido);
    Pedido.CalcularTotal;
    Result := Pedido;
    Pedido := nil;
  finally
    Pedido.Free;
    Query.Free;
  end;
end;

procedure TPedidoRepository.Excluir(ANumero: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDb.Connection;
    Query.SQL.Text := 'SELECT NUMERO_PEDIDO FROM PEDIDO WHERE NUMERO_PEDIDO = :NUMERO';
    Query.ParamByName('NUMERO').AsInteger := ANumero;
    Query.Open;
    if Query.IsEmpty then
      raise ERegistroNaoEncontrado.CreateFmt('Pedido %d nao encontrado.', [ANumero]);
    Query.Close;
    ExcluirItens(ANumero);

    Query.SQL.Text := 'DELETE FROM PEDIDO WHERE NUMERO_PEDIDO = :NUMERO';
    Query.ParamByName('NUMERO').AsInteger := ANumero;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

end.
