unit ClienteRepository;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  Cliente,
  DatabaseConnection,
  AppExceptions;

type
  TClienteRepository = class
  private
    FDb: TDatabaseConnection;
  public
    constructor Create(ADb: TDatabaseConnection);
    function BuscarPorCodigo(ACodigo: Integer): TCliente;
  end;

implementation

constructor TClienteRepository.Create(ADb: TDatabaseConnection);
begin
  inherited Create;
  FDb := ADb;
end;

function TClienteRepository.BuscarPorCodigo(ACodigo: Integer): TCliente;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDb.Connection;
    Query.SQL.Text :=
      'SELECT CODIGO, NOME, CIDADE, UF ' +
      'FROM CLIENTE ' +
      'WHERE CODIGO = :CODIGO';
    Query.ParamByName('CODIGO').AsInteger := ACodigo;
    Query.Open;
    if Query.IsEmpty then
      raise ERegistroNaoEncontrado.CreateFmt('Cliente %d não encontrado.', [ACodigo]);
    Result := TCliente.Create;
    Result.Codigo := Query.FieldByName('CODIGO').AsInteger;
    Result.Nome := Query.FieldByName('NOME').AsString;
    Result.Cidade := Query.FieldByName('CIDADE').AsString;
    Result.UF := Query.FieldByName('UF').AsString;
  finally
    Query.Free;
  end;
end;

end.
