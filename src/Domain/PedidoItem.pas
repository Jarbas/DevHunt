unit PedidoItem;

interface

type
  TPedidoItem = class
  private
    FId: Integer;
    FCodigoProduto: Integer;
    FDescricao: string;
    FQuantidade: Currency;
    FVlrUnitario: Currency;
    FVlrTotal: Currency;
  public
    procedure CalcularTotal;
    property Id: Integer read FId write FId;
    property CodigoProduto: Integer read FCodigoProduto write FCodigoProduto;
    property Descricao: string read FDescricao write FDescricao;
    property Quantidade: Currency read FQuantidade write FQuantidade;
    property VlrUnitario: Currency read FVlrUnitario write FVlrUnitario;
    property VlrTotal: Currency read FVlrTotal write FVlrTotal;
  end;

implementation

procedure TPedidoItem.CalcularTotal;
begin
  FVlrTotal := FQuantidade * FVlrUnitario;
end;

end.
