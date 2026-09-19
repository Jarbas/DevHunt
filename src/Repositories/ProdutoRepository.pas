unit ProdutoRepository;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Produto,
  DatabaseConnection,
  AppExceptions;

type
  TProdutoRepository = class
  private
    FDb: TDatabaseConnection;
  public
    constructor Create(ADb: TDatabaseConnection);
    function BuscarPorCodigo(ACodigo: Integer): TProduto;
  end;

implementation

constructor TProdutoRepository.Create(ADb: TDatabaseConnection);
begin
  inherited Create;
  FDb := ADb;
end;

function TProdutoRepository.BuscarPorCodigo(ACodigo: Integer): TProduto;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDb.Connection;
    Query.SQL.Text :=
      'SELECT CODIGO, DESCRICAO, PRECO_VENDA ' +
      'FROM PRODUTO ' +
      'WHERE CODIGO = :CODIGO';
    Query.ParamByName('CODIGO').AsInteger := ACodigo;
    Query.Open;
    if Query.IsEmpty then
      raise ERegistroNaoEncontrado.CreateFmt('Produto %d nao encontrado.', [ACodigo]);
    Result := TProduto.Create;
    Result.Codigo := Query.FieldByName('CODIGO').AsInteger;
    Result.Descricao := Query.FieldByName('DESCRICAO').AsString;
    Result.PrecoVenda := Query.FieldByName('PRECO_VENDA').AsCurrency;
  finally
    Query.Free;
  end;
end;

end.
