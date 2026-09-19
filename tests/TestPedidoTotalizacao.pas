unit TestPedidoTotalizacao;

interface

uses
  DUnitX.TestFramework,
  Pedido,
  PedidoItem;

type
  [TestFixture]
  TTestPedidoTotalizacao = class
  private
    function NovoItem(AQuantidade, AVlrUnitario: Currency): TPedidoItem;
  public
    [Test]
    procedure Item_QuantidadeVezesUnitario;
    [Test]
    procedure Item_QuantidadeFracionada;
    [Test]
    procedure Item_QuantidadeZero_TotalZero;
    [Test]
    procedure Pedido_SemItens_TotalZero;
    [Test]
    procedure Pedido_SomaVariosItens;
    [Test]
    procedure Pedido_RecalculaAposRemoverItem;
    [Test]
    procedure Pedido_MaquinasConstrucao_Exemplo;
  end;

implementation

function TTestPedidoTotalizacao.NovoItem(AQuantidade, AVlrUnitario: Currency): TPedidoItem;
begin
  Result := TPedidoItem.Create;
  Result.Quantidade := AQuantidade;
  Result.VlrUnitario := AVlrUnitario;
  Result.CalcularTotal;
end;

procedure TTestPedidoTotalizacao.Item_QuantidadeVezesUnitario;
var
  Item: TPedidoItem;
begin
  Item := NovoItem(2, 10.50);
  try
    Assert.AreEqual<Currency>(21.00, Item.VlrTotal);
  finally
    Item.Free;
  end;
end;

procedure TTestPedidoTotalizacao.Item_QuantidadeFracionada;
var
  Item: TPedidoItem;
begin
  Item := NovoItem(1.5, 100);
  try
    Assert.AreEqual<Currency>(150.00, Item.VlrTotal);
  finally
    Item.Free;
  end;
end;

procedure TTestPedidoTotalizacao.Item_QuantidadeZero_TotalZero;
var
  Item: TPedidoItem;
begin
  Item := NovoItem(0, 2548.25);
  try
    Assert.AreEqual<Currency>(0, Item.VlrTotal);
  finally
    Item.Free;
  end;
end;

procedure TTestPedidoTotalizacao.Pedido_SemItens_TotalZero;
var
  Pedido: TPedido;
begin
  Pedido := TPedido.Create;
  try
    Pedido.CalcularTotal;
    Assert.AreEqual<Currency>(0, Pedido.ValorTotal);
  finally
    Pedido.Free;
  end;
end;

procedure TTestPedidoTotalizacao.Pedido_SomaVariosItens;
var
  Pedido: TPedido;
begin
  Pedido := TPedido.Create;
  try
    Pedido.Itens.Add(NovoItem(2, 10));
    Pedido.Itens.Add(NovoItem(3, 5.50));
    Pedido.CalcularTotal;
    Assert.AreEqual<Currency>(36.50, Pedido.ValorTotal);
  finally
    Pedido.Free;
  end;
end;

procedure TTestPedidoTotalizacao.Pedido_RecalculaAposRemoverItem;
var
  Pedido: TPedido;
begin
  Pedido := TPedido.Create;
  try
    Pedido.Itens.Add(NovoItem(1, 100));
    Pedido.Itens.Add(NovoItem(1, 40));
    Pedido.CalcularTotal;
    Assert.AreEqual<Currency>(140, Pedido.ValorTotal);
    Pedido.Itens.Delete(0);
    Pedido.CalcularTotal;
    Assert.AreEqual<Currency>(40, Pedido.ValorTotal);
  finally
    Pedido.Free;
  end;
end;

procedure TTestPedidoTotalizacao.Pedido_MaquinasConstrucao_Exemplo;
var
  Pedido: TPedido;
begin
  Pedido := TPedido.Create;
  try
    Pedido.Itens.Add(NovoItem(1, 2548.25));
    Pedido.Itens.Add(NovoItem(2, 3879.90));
    Pedido.Itens.Add(NovoItem(1, 1654.70));
    Pedido.CalcularTotal;
    Assert.AreEqual<Currency>(11962.75, Pedido.ValorTotal);
  finally
    Pedido.Free;
  end;
end;

end.
