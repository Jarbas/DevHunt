unit Cliente;

interface

type
  TCliente = class
  private
    FCodigo: Integer;
    FNome: string;
    FCidade: string;
    FUF: string;
  public
    property Codigo: Integer read FCodigo write FCodigo;
    property Nome: string read FNome write FNome;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write FUF;
    function EstaCarregado: Boolean;
  end;

implementation

function TCliente.EstaCarregado: Boolean;
begin
  Result := (FCodigo > 0) and (FNome <> '');
end;

end.
