unit Pedido;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  Cliente,
  PedidoItem;

type
  TPedido = class
  private
    FNumeroPedido: Integer;
    FDataEmissao: TDate;
    FCliente: TCliente;
    FItens: TObjectList<TPedidoItem>;
    FValorTotal: Currency;
    FObservacao: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CalcularTotal;
    function ItemPorIndice(AIndex: Integer): TPedidoItem;
    property NumeroPedido: Integer read FNumeroPedido write FNumeroPedido;
    property DataEmissao: TDate read FDataEmissao write FDataEmissao;
    property Cliente: TCliente read FCliente;
    property Itens: TObjectList<TPedidoItem> read FItens;
    property ValorTotal: Currency read FValorTotal;
    property Observacao: string read FObservacao write FObservacao;
  end;

implementation

constructor TPedido.Create;
begin
  inherited Create;
  FCliente := TCliente.Create;
  FItens := TObjectList<TPedidoItem>.Create(True);
  FDataEmissao := Date;
  FValorTotal := 0;
end;

destructor TPedido.Destroy;
begin
  FItens.Free;
  FCliente.Free;
  inherited;
end;

procedure TPedido.CalcularTotal;
var
  Item: TPedidoItem;
begin
  FValorTotal := 0;
  for Item in FItens do
  begin
    Item.CalcularTotal;
    FValorTotal := FValorTotal + Item.VlrTotal;
  end;
end;

function TPedido.ItemPorIndice(AIndex: Integer): TPedidoItem;
begin
  if (AIndex < 0) or (AIndex >= FItens.Count) then
    Result := nil
  else
    Result := FItens[AIndex];
end;

end.
