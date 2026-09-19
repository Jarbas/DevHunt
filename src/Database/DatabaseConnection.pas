unit DatabaseConnection;

interface

uses
  FireDAC.Comp.Client,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  DatabaseConfig;

type
  TDatabaseConnection = class
  private
    FConfig: TDatabaseConfig;
    FConnection: TFDConnection;
    FDriverLink: TFDPhysFBDriverLink;
    FWaitCursor: TFDGUIxWaitCursor;
    procedure Configurar;
  public
    constructor Create(const AConfig: TDatabaseConfig);
    destructor Destroy; override;
    procedure Conectar;
    procedure IniciarTransacao;
    procedure ConfirmarTransacao;
    procedure DesfazerTransacao;
    function EmTransacao: Boolean;
    property Connection: TFDConnection read FConnection;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils;

constructor TDatabaseConnection.Create(const AConfig: TDatabaseConfig);
begin
  inherited Create;
  FConfig := AConfig;
  FDriverLink := TFDPhysFBDriverLink.Create(nil);
  FWaitCursor := TFDGUIxWaitCursor.Create(nil);
  FWaitCursor.Provider := 'Forms';
  FWaitCursor.ScreenCursor := gcrNone;
  FConnection := TFDConnection.Create(nil);
  Configurar;
end;

destructor TDatabaseConnection.Destroy;
begin
  FConnection.Free;
  FWaitCursor.Free;
  FDriverLink.Free;
  inherited;
end;

procedure TDatabaseConnection.Configurar;
var
  ClientLib: string;
begin
  ClientLib := FConfig.ClientLibrary;
  if (ClientLib <> '') and (not TFile.Exists(ClientLib)) and (not TPath.IsPathRooted(ClientLib)) then
    ClientLib := TPath.Combine(ExtractFilePath(ParamStr(0)), ClientLib);

  if (ClientLib <> '') and TFile.Exists(ClientLib) then
    FDriverLink.VendorLib := ClientLib;

  FConnection.DriverName := 'FB';
  FConnection.Params.Clear;
  FConnection.Params.Add('DriverID=FB');
  FConnection.Params.Add('Server=' + FConfig.Server);
  FConnection.Params.Add('Port=' + FConfig.Port.ToString);
  FConnection.Params.Add('Database=' + FConfig.Database);
  FConnection.Params.Add('User_Name=' + FConfig.Username);
  FConnection.Params.Add('Password=' + FConfig.Password);
  FConnection.Params.Add('CharacterSet=UTF8');
  FConnection.LoginPrompt := False;
end;

procedure TDatabaseConnection.Conectar;
begin
  if not FConnection.Connected then
    FConnection.Connected := True;
end;

procedure TDatabaseConnection.IniciarTransacao;
begin
  if not FConnection.InTransaction then
    FConnection.StartTransaction;
end;

procedure TDatabaseConnection.ConfirmarTransacao;
begin
  if FConnection.InTransaction then
    FConnection.Commit;
end;

procedure TDatabaseConnection.DesfazerTransacao;
begin
  if FConnection.InTransaction then
    FConnection.Rollback;
end;

function TDatabaseConnection.EmTransacao: Boolean;
begin
  Result := FConnection.InTransaction;
end;

end.
