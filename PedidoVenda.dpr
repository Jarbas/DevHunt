program PedidoVenda;

uses
  Vcl.Forms,
  AppConsts in 'src\Shared\Constants\AppConsts.pas',
  AppExceptions in 'src\Shared\Exceptions\AppExceptions.pas',
  Cliente in 'src\Domain\Cliente.pas',
  Produto in 'src\Domain\Produto.pas',
  PedidoItem in 'src\Domain\PedidoItem.pas',
  Pedido in 'src\Domain\Pedido.pas',
  DatabaseConfig in 'src\Database\DatabaseConfig.pas',
  DatabaseConnection in 'src\Database\DatabaseConnection.pas',
  ClienteRepository in 'src\Repositories\ClienteRepository.pas',
  ProdutoRepository in 'src\Repositories\ProdutoRepository.pas',
  PedidoRepository in 'src\Repositories\PedidoRepository.pas',
  PedidoService in 'src\Services\PedidoService.pas',
  uFrmPedidoVenda in 'src\Forms\uFrmPedidoVenda.pas' {FrmPedidoVenda};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := AppTitle;
  Application.CreateForm(TFrmPedidoVenda, FrmPedidoVenda);
  Application.Run;
end.
