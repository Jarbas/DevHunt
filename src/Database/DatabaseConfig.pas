unit DatabaseConfig;

interface

type
  TDatabaseConfig = record
    Database: string;
    Username: string;
    Password: string;
    Server: string;
    Port: Integer;
    ClientLibrary: string;
    class function FromIni(const AFileName: string): TDatabaseConfig; static;
    function ConnectionString: string;
  end;

implementation

uses
  System.IniFiles,
  System.IOUtils,
  System.SysUtils,
  AppConsts,
  AppExceptions;

function FindProjectRoot: string;
var
  Dir: string;
  Parent: string;
  Guard: Integer;
begin
  Result := '';
  Dir := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  if Dir = '' then
    Dir := ExcludeTrailingPathDelimiter(TDirectory.GetCurrentDirectory);

  Guard := 0;
  while (Dir <> '') and (Guard < 8) do
  begin
    if TFile.Exists(TPath.Combine(Dir, 'PedidoVenda.dpr')) then
      Exit(Dir);
    Parent := ExcludeTrailingPathDelimiter(TDirectory.GetParent(Dir));
    if (Parent = '') or SameText(Parent, Dir) then
      Break;
    Dir := Parent;
    Inc(Guard);
  end;
end;

function ResolveConfigPath(const AFileName: string): string;
var
  Candidate: string;
  Root: string;
begin
  { Sempre a raiz do clone (pasta do PedidoVenda.dpr), nunca Win32\Base. }
  Root := FindProjectRoot;
  if Root <> '' then
  begin
    Candidate := TPath.Combine(Root, AFileName);
    if TFile.Exists(Candidate) then
      Exit(TPath.GetFullPath(Candidate));
  end;

  if TFile.Exists(AFileName) then
    Exit(TPath.GetFullPath(AFileName));

  Candidate := TPath.Combine(TDirectory.GetCurrentDirectory, AFileName);
  if TFile.Exists(Candidate) then
    Exit(TPath.GetFullPath(Candidate));

  raise EConfiguracao.CreateFmt(
    'Arquivo de configuracao nao encontrado: %s. Copie config.ini.example para config.ini.',
    [AFileName]);
end;

function ResolveRelativePath(const ABaseDir, APath: string): string;
begin
  if APath = '' then
    Exit('');

  if TPath.IsPathRooted(APath) then
    Result := TPath.GetFullPath(APath)
  else
    Result := TPath.GetFullPath(TPath.Combine(ABaseDir, APath));
end;

class function TDatabaseConfig.FromIni(const AFileName: string): TDatabaseConfig;
var
  Ini: TMemIniFile;
  Path: string;
  RootDir: string;
  RawDatabase: string;
  RawClientLib: string;
begin
  Path := ResolveConfigPath(AFileName);
  RootDir := ExtractFilePath(Path);

  { TIniFile (API do Windows) com caminho relativo le C:\Windows\config.ini. }
  Ini := TMemIniFile.Create(Path);
  try
    RawDatabase := Ini.ReadString(ConfigSection, 'Database', '');
    Result.Username := Ini.ReadString(ConfigSection, 'Username', 'SYSDBA');
    Result.Password := Ini.ReadString(ConfigSection, 'Password', '');
    Result.Server := Ini.ReadString(ConfigSection, 'Server', 'localhost');
    Result.Port := Ini.ReadInteger(ConfigSection, 'Port', 3050);
    RawClientLib := Ini.ReadString(ConfigSection, 'ClientLibrary', '.\bin\fbclient.dll');
  finally
    Ini.Free;
  end;

  if RawDatabase = '' then
    raise EConfiguracao.Create('Chave [DATABASE] Database nao informada no config.ini.');

  { Caminhos relativos partem da pasta do config.ini (raiz do projeto). }
  Result.Database := ResolveRelativePath(RootDir, RawDatabase);
  Result.ClientLibrary := ResolveRelativePath(RootDir, RawClientLib);
end;

function TDatabaseConfig.ConnectionString: string;
begin
  Result := Format('%s/%d:%s', [Server, Port, Database]);
end;

end.
