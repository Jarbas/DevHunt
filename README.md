## Instruções 

1. Para fazer o clone  abra o powerShel  execute 'git clone https://github.com/Jarbas/DevHunt.git'

Necessário  para execução

- Firebird instalado e em execução no Windows, usei a versão o 5. 
- A pasta `bin` com o `fbclient.dll` (fica junto do projeto)

## Primeira vez depois de clonar

2. Entre na pasta `database` e dê um duplo clique em **`criar_banco.bat`**.
   - Se o Firebird não estiver em execução, o script avisa e para.
   - Se estiver tudo certo, ele cria o banco em `src\Database\DEVHUNTER.FDB` e monta as tabelas com alguns clientes e produtos de exemplo.
3. Se ainda não existir, o script também deixa um `config.ini` na raiz. Esse arquivo já aponta para a pasta do projeto — não precisa colocar caminho absoluto de outra máquina.
4. Abra `PedidoVenda.dpr` no Delphi, compile e rode.

Depois de gravar, informe o número do pedido e use Carregar Pedido (cabeçalho + itens) ou Cancelar Pedido (apaga pedido e itens na mesma transação).

Os testes de totalização (DUnitX) ficam em `tests\PedidoVenda.Tests.dproj`.

## Organização do projeto

```text
PedidoVenda/
├── src/Domain           regras e entidades
├── src/Services         gravação do pedido
├── src/Repositories     acesso ao banco
├── src/Database         conexão + arquivo .FDB
├── src/Forms            tela
├── database/            script e criar_banco.bat
├── tests/               testes de totalização (DUnitX)
├── bin/                 fbclient.dll
├── config.ini           conexão com o banco
└── PedidoVenda.dpr      projeto principal
```

## Configuração

O `config.ini` fica na raiz. O caminho do banco é relativo:

Assim, em qualquer PC, depois do clone e do `criar_banco.bat`, a aplicação encontra o banco na própria pasta do projeto.

### Teste

