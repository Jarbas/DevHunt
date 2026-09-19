unit DUnitX.TestFramework;

interface

uses
  System.SysUtils,
  System.TypInfo,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Rtti;

type
  TestFixtureAttribute = class(TCustomAttribute);
  TestAttribute = class(TCustomAttribute);

  ETestFailure = class(Exception);

  Assert = class
  public
    class procedure AreEqual<T>(const Expected, Actual: T);
  end;

  IRunResults = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function GetAllPassed: Boolean;
    property AllPassed: Boolean read GetAllPassed;
  end;

  ITestLogger = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    procedure OnTestOk(const AName: string);
    procedure OnTestFail(const AName, AError: string);
  end;

  ITestRunner = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    procedure SetUseRTTI(const AValue: Boolean);
    function GetUseRTTI: Boolean;
    property UseRTTI: Boolean read GetUseRTTI write SetUseRTTI;
    procedure AddLogger(const ALogger: ITestLogger);
    function Execute: IRunResults;
  end;

  TDUnitX = class
  private
    class var FFixtures: TList<TClass>;
  public
    class constructor Create;
    class destructor Destroy;
    class procedure RegisterTestFixture(AClass: TClass);
    class function CreateRunner: ITestRunner;
  end;

implementation

type
  TRunResults = class(TInterfacedObject, IRunResults)
  private
    FFailed: Integer;
  public
    constructor Create(AFailed: Integer);
    function GetAllPassed: Boolean;
  end;

  TTestRunner = class(TInterfacedObject, ITestRunner)
  private
    FUseRTTI: Boolean;
    FLoggers: TList<ITestLogger>;
    procedure NotifyOk(const AName: string);
    procedure NotifyFail(const AName, AError: string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetUseRTTI(const AValue: Boolean);
    function GetUseRTTI: Boolean;
    procedure AddLogger(const ALogger: ITestLogger);
    function Execute: IRunResults;
  end;

class procedure Assert.AreEqual<T>(const Expected, Actual: T);
begin
  if TComparer<T>.Default.Compare(Expected, Actual) <> 0 then
    raise ETestFailure.CreateFmt('Esperado <%s>, obtido <%s>.',
      [TValue.From<T>(Expected).ToString, TValue.From<T>(Actual).ToString]);
end;

constructor TRunResults.Create(AFailed: Integer);
begin
  inherited Create;
  FFailed := AFailed;
end;

function TRunResults.GetAllPassed: Boolean;
begin
  Result := FFailed = 0;
end;

class constructor TDUnitX.Create;
begin
  FFixtures := TList<TClass>.Create;
end;

class destructor TDUnitX.Destroy;
begin
  FFixtures.Free;
end;

class procedure TDUnitX.RegisterTestFixture(AClass: TClass);
begin
  if not FFixtures.Contains(AClass) then
    FFixtures.Add(AClass);
end;

class function TDUnitX.CreateRunner: ITestRunner;
begin
  Result := TTestRunner.Create;
end;

constructor TTestRunner.Create;
begin
  inherited Create;
  FUseRTTI := True;
  FLoggers := TList<ITestLogger>.Create;
end;

destructor TTestRunner.Destroy;
begin
  FLoggers.Free;
  inherited;
end;

procedure TTestRunner.SetUseRTTI(const AValue: Boolean);
begin
  FUseRTTI := AValue;
end;

function TTestRunner.GetUseRTTI: Boolean;
begin
  Result := FUseRTTI;
end;

procedure TTestRunner.AddLogger(const ALogger: ITestLogger);
begin
  if ALogger <> nil then
    FLoggers.Add(ALogger);
end;

procedure TTestRunner.NotifyOk(const AName: string);
var
  Logger: ITestLogger;
begin
  for Logger in FLoggers do
    Logger.OnTestOk(AName);
end;

procedure TTestRunner.NotifyFail(const AName, AError: string);
var
  Logger: ITestLogger;
begin
  for Logger in FLoggers do
    Logger.OnTestFail(AName, AError);
end;

function TTestRunner.Execute: IRunResults;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Metodo: TRttiMethod;
  Atributo: TCustomAttribute;
  FixtureClass: TClass;
  Instancia: TObject;
  Falhas: Integer;
  EhTeste: Boolean;
begin
  Falhas := 0;
  Contexto := TRttiContext.Create;
  try
    for FixtureClass in TDUnitX.FFixtures do
    begin
      Instancia := FixtureClass.Create;
      try
        Tipo := Contexto.GetType(FixtureClass);
        for Metodo in Tipo.GetMethods do
        begin
          if Metodo.Visibility <> mvPublic then
            Continue;
          if Metodo.Parent <> Tipo then
            Continue;
          EhTeste := False;
          for Atributo in Metodo.GetAttributes do
            if Atributo is TestAttribute then
              EhTeste := True;
          if not EhTeste then
            Continue;
          try
            Metodo.Invoke(Instancia, []);
            NotifyOk(Metodo.Name);
          except
            on E: Exception do
            begin
              Inc(Falhas);
              NotifyFail(Metodo.Name, E.Message);
            end;
          end;
        end;
      finally
        Instancia.Free;
      end;
    end;
  finally
    Contexto.Free;
  end;
  Result := TRunResults.Create(Falhas);
end;

end.
