@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM  Pedido de Venda - cria o banco Firebird na pasta do projeto
REM  Uso: dê um duplo clique ou rode no Prompt de Comando.
REM ============================================================

cd /d "%~dp0"
set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"

set "DB_DIR=%ROOT%\src\Database"
set "DB_FILE=%DB_DIR%\DEVHUNTER.FDB"
set "SCHEMA=%~dp0db.sql"
set "CONFIG_EXAMPLE=%ROOT%\config.ini.example"
set "CONFIG=%ROOT%\config.ini"
set "ISQL="
set "FB_USER=SYSDBA"
set "FB_PASS=firebird"

echo.
echo  Pedido de Venda - preparacao do banco
echo  -------------------------------------
echo  Pasta do projeto: %ROOT%
echo  Banco sera criado em: %DB_FILE%
echo.

REM --- Localiza o isql do Firebird ---
if exist "%ProgramFiles%\Firebird\Firebird_5_0\isql.exe" set "ISQL=%ProgramFiles%\Firebird\Firebird_5_0\isql.exe"
if not defined ISQL if exist "%ProgramFiles%\Firebird\Firebird_4_0\isql.exe" set "ISQL=%ProgramFiles%\Firebird\Firebird_4_0\isql.exe"
if not defined ISQL if exist "%ProgramFiles%\Firebird\Firebird_3_0\isql.exe" set "ISQL=%ProgramFiles%\Firebird\Firebird_3_0\isql.exe"
if not defined ISQL if exist "%ProgramFiles(x86)%\Firebird\Firebird_3_0\isql.exe" set "ISQL=%ProgramFiles(x86)%\Firebird\Firebird_3_0\isql.exe"
if not defined ISQL (
  where isql.exe >nul 2>&1
  if not errorlevel 1 for /f "delims=" %%I in ('where isql.exe') do (
    set "ISQL=%%I"
    goto :isql_ok
  )
)

:isql_ok
if not defined ISQL (
  echo [ERRO] Nao encontrei o Firebird instalado nesta maquina.
  echo        Instale o Firebird e rode este script de novo.
  echo.
  pause
  exit /b 1
)

echo  Firebird encontrado: %ISQL%
echo.

REM --- Verifica se o servico do Firebird esta em execucao ---
set "FB_OK="
for %%S in (
  "FirebirdServerDefaultInstance"
  "FirebirdGuardianDefaultInstance"
  "FirebirdServerClassicDefaultInstance"
  "FirebirdServerSuperClassicDefaultInstance"
) do (
  sc query %%~S >nul 2>&1
  if not errorlevel 1 (
    sc query %%~S | findstr /I "RUNNING" >nul 2>&1
    if not errorlevel 1 set "FB_OK=1"
  )
)

if not defined FB_OK (
  REM Nome do servico pode variar; confere se a porta padrao esta escutando.
  netstat -an | findstr /R /C:":3050 .*LISTENING" >nul 2>&1
  if not errorlevel 1 set "FB_OK=1"
)

if not defined FB_OK (
  echo [AVISO] O Firebird nao parece estar em execucao.
  echo         Abra os Servicos do Windows, inicie o Firebird
  echo         ^(ou o Guardian^) e rode este arquivo de novo.
  echo.
  pause
  exit /b 1
)

echo  Servico do Firebird: em execucao
echo.

if not exist "%SCHEMA%" (
  echo [ERRO] Nao encontrei o arquivo de tabelas: %SCHEMA%
  pause
  exit /b 1
)

if not exist "%DB_DIR%" (
  echo  Criando pasta: %DB_DIR%
  mkdir "%DB_DIR%"
  if errorlevel 1 (
    echo [ERRO] Nao foi possivel criar a pasta do banco.
    pause
    exit /b 1
  )
)

REM Caminho com barra normal — o Firebird prefere assim no CREATE DATABASE
set "DB_CREATE=%DB_FILE:\=/%"

if exist "%DB_FILE%" (
  echo  O banco ja existe. Vou so atualizar as tabelas e os dados de teste.
  echo.
) else (
  echo  Criando o arquivo do banco...
  set "TMP_SQL=%TEMP%\pedido_venda_create_%RANDOM%.sql"
  (
    echo CREATE DATABASE '%DB_CREATE%'
    echo   USER '%FB_USER%' PASSWORD '%FB_PASS%'
    echo   PAGE_SIZE 16384
    echo   DEFAULT CHARACTER SET UTF8;
  ) > "!TMP_SQL!"

  type "!TMP_SQL!" | "%ISQL%" -quiet
  set "CREATE_ERR=!errorlevel!"
  del "!TMP_SQL!" >nul 2>&1

  if not "!CREATE_ERR!"=="0" (
    echo.
    echo [ERRO] Nao consegui criar o banco.
    echo        Confirme se o Firebird esta rodando e se voce tem
    echo        permissao para gravar em:
    echo        %DB_DIR%
    echo.
    pause
    exit /b 1
  )

  if not exist "%DB_FILE%" (
    echo [ERRO] O comando rodou, mas o arquivo do banco nao apareceu.
    pause
    exit /b 1
  )

  echo  Banco criado com sucesso.
  echo.
)

echo  Montando tabelas e dados de teste...
set "DB_CONNECT=localhost/3050:%DB_CREATE%"
"%ISQL%" -user %FB_USER% -password %FB_PASS% -i "%SCHEMA%" "%DB_CONNECT%"
if errorlevel 1 (
  echo.
  echo [ERRO] Falha ao criar as tabelas. Veja a mensagem acima.
  pause
  exit /b 1
)

set "TMP_CHK=%TEMP%\pedido_venda_check_%RANDOM%.sql"
> "!TMP_CHK!" (
  echo SELECT COUNT^(*^) FROM PRODUTO;
  echo EXIT;
)
"%ISQL%" -user %FB_USER% -password %FB_PASS% -i "!TMP_CHK!" "%DB_CONNECT%" | findstr /I "Table unknown" >nul
set "CHK_ERR=!errorlevel!"
del "!TMP_CHK!" >nul 2>&1
if "!CHK_ERR!"=="0" (
  echo.
  echo [ERRO] O arquivo do banco existe, mas as tabelas nao foram criadas.
  echo        Feche o Pedido de Venda e rode este script de novo.
  echo.
  pause
  exit /b 1
)

if exist "%~dp0alter_observacao.sql" (
  "%ISQL%" -user %FB_USER% -password %FB_PASS% -i "%~dp0alter_observacao.sql" "%DB_CONNECT%"
)

> "%CONFIG%" (
  echo [DATABASE]
  echo Database=.\src\Database\DEVHUNTER.FDB
  echo Username=%FB_USER%
  echo Password=%FB_PASS%
  echo Server=localhost
  echo Port=3050
  echo ClientLibrary=.\bin\fbclient.dll
)
echo  Arquivo config.ini gravado na raiz do projeto.

echo.
echo  Pronto!
echo  O banco esta em: %DB_FILE%
echo  O programa ja aponta para esse caminho no config.ini.
echo  Agora abra o projeto no Delphi e rode a aplicacao.
echo.
pause
endlocal
exit /b 0
