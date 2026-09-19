unit Produto;

interface

type
  TProduto = class
  private
    FCodigo: Integer;
    FDescricao: string;
    FPrecoVenda: Currency;
  public
    property Codigo: Integer read FCodigo write FCodigo;
    property Descricao: string read FDescricao write FDescricao;
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;
    function EstaCarregado: Boolean;
  end;

implementation

function TProduto.EstaCarregado: Boolean;
begin
  Result := (FCodigo > 0) and (FDescricao <> '');
end;

end.
