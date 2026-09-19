# Banco do Pedido de Venda

## Jeito mais fácil

1. Deixe o **Firebird ligado** no Windows (serviço em execução).
2. Dê um duplo clique em **`criar_banco.bat`**.

O script:

- avisa se o Firebird não estiver rodando;
- cria a pasta `src\Database` se precisar;
- gera o arquivo `DEVHUNTER.FDB` dentro dessa pasta;
- monta as tabelas e coloca clientes e produtos de teste;
- cria o `config.ini` na raiz, se ainda não existir.

## Se preferir fazer na mão

Só use isso se o `.bat` não for uma opção. Com o Firebird rodando:

```text
isql
```

```sql
CREATE DATABASE 'C:/caminho/completo/para/PedidoVenda/src/Database/DEVHUNTER.FDB'
  USER 'SYSDBA' PASSWORD 'firebird'
  PAGE_SIZE 16384
  DEFAULT CHARACTER SET UTF8;
```

Depois, as tabelas:

```text
isql -user SYSDBA -password firebird -i database\db.sql caminho\completo\DEVHUNTER.FDB
```

## O que entra no banco

Clientes, produtos, pedidos e itens do pedido. O número do pedido vem de uma sequence; o item ganha ID automático.

Relação rápida:

```text
CLIENTE  →  PEDIDO  →  PEDIDO_ITEM  →  PRODUTO
```

## Dados de teste

| Tabela  | Códigos            |
|---------|--------------------|
| CLIENTE | 1, 2, 3            |
| PRODUTO | 1, 2, 3            |
