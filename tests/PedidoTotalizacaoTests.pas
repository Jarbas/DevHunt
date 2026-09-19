unit PedidoTotalizacaoTests;

interface

uses
  DUnitX.TestFramework,
  Pedido,
  PedidoItem;

type
  [TestFixture]
  TPedidoTotalizacaoTests = class
  private
    function NovoItem(AQuantidade, AVlrUnitario: Currency): TPedidoItem;
  public
    [Test]
    procedure Item_Total_EhQuantidadeVezesUnitario;
    [Test]
    procedure Item_QuantidadeFracionada_MantemDuasCasasNoProdutoDePreco;
    [Test]
    procedure Pedido_SemItens_TotalZero;
    [Test]
    procedure Pedido_Total_SomaItens;
    [Test]
    procedure Pedido_AposRemoverItem_RecalculaTotal;
    [Test]
    procedure Pedido_AoAlterarItem_RecalculaTotal;
  end;

implementation

function TPedidoTotalizacaoTests.NovoItem(AQuantidade, AVlrUnitario: Currency): TPedidoItem;
begin
  Result := TPedidoItem.Create;
  Result.Quantidade := AQuantidade;
  Result.VlrUnitario := AVlrUnitario;
  Result.CalcularTotal;
end;

procedure TPedidoTotalizacaoTests.Item_Total_EhQuantidadeVezesUnitario;
var
  Item: TPedidoItem;
begin
  Item := NovoItem(2, 2548.25);
  try
    Assert.AreEqual<Currency>(5096.50, Item.VlrTotal);
  finally
    Item.Free;
  end;
end;

procedure TPedidoTotalizacaoTests.Item_QuantidadeFracionada_MantemDuasCasasNoProdutoDePreco;
var
  Item: TPedidoItem;
begin
  Item := NovoItem(1.5, 3879.90);
  try
    Assert.AreEqual<Currency>(5819.85, Item.VlrTotal);
  finally
    Item.Free;
  end;
end;

procedure TPedidoTotalizacaoTests.Pedido_SemItens_TotalZero;
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

procedure TPedidoTotalizacaoTests.Pedido_Total_SomaItens;
var
  Pedido: TPedido;
begin
  Pedido := TPedido.Create;
  try
    Pedido.Itens.Add(NovoItem(1, 2548.25));
    Pedido.Itens.Add(NovoItem(2, 1654.70));
    Pedido.CalcularTotal;
    Assert.AreEqual<Currency>(5857.65, Pedido.ValorTotal);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoTotalizacaoTests.Pedido_AposRemoverItem_RecalculaTotal;
var
  Pedido: TPedido;
begin
  Pedido := TPedido.Create;
  try
    Pedido.Itens.Add(NovoItem(1, 2548.25));
    Pedido.Itens.Add(NovoItem(1, 3879.90));
    Pedido.CalcularTotal;
    Pedido.Itens.Delete(0);
    Pedido.CalcularTotal;
    Assert.AreEqual<Currency>(3879.90, Pedido.ValorTotal);
  finally
    Pedido.Free;
  end;
end;

procedure TPedidoTotalizacaoTests.Pedido_AoAlterarItem_RecalculaTotal;
var
  Pedido: TPedido;
  Item: TPedidoItem;
begin
  Pedido := TPedido.Create;
  try
    Item := NovoItem(1, 1654.70);
    Pedido.Itens.Add(Item);
    Pedido.CalcularTotal;
    Item.Quantidade := 3;
    Pedido.CalcularTotal;
    Assert.AreEqual<Currency>(4964.10, Pedido.ValorTotal);
  finally
    Pedido.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPedidoTotalizacaoTests);

end.
