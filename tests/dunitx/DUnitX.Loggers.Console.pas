unit DUnitX.Loggers.Console;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework;

type
  TDUnitXConsoleLogger = class(TInterfacedObject, ITestLogger)
  public
    constructor Create(AVerbose: Boolean);
    procedure OnTestOk(const AName: string);
    procedure OnTestFail(const AName, AError: string);
  end;

implementation

constructor TDUnitXConsoleLogger.Create(AVerbose: Boolean);
begin
  inherited Create;
end;

procedure TDUnitXConsoleLogger.OnTestOk(const AName: string);
begin
  Writeln('[OK]    ', AName);
end;

procedure TDUnitXConsoleLogger.OnTestFail(const AName, AError: string);
begin
  Writeln('[FALHA] ', AName, ' -> ', AError);
end;

end.
