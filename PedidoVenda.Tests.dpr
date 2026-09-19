program PedidoVendaTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.TestFramework in 'tests\dunitx\DUnitX.TestFramework.pas',
  DUnitX.Loggers.Console in 'tests\dunitx\DUnitX.Loggers.Console.pas',
  Cliente in 'src\Domain\Cliente.pas',
  PedidoItem in 'src\Domain\PedidoItem.pas',
  Pedido in 'src\Domain\Pedido.pas',
  PedidoTotalizacaoTests in 'tests\PedidoTotalizacaoTests.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
begin
  try
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;
    Runner.AddLogger(TDUnitXConsoleLogger.Create(True));
    Results := Runner.Execute;
    if not Results.AllPassed then
      ExitCode := 1;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
  Write('Concluido. Pressione Enter...');
  Readln;
end.
