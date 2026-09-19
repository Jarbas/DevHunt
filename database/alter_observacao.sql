/* Evolucao 4.1 — campo curto no cabecalho do pedido.
   Seguro em banco ja existente: ignora se a coluna ja existe. */
SET TERM ^ ;
EXECUTE BLOCK AS
BEGIN
  BEGIN
    EXECUTE STATEMENT 'ALTER TABLE PEDIDO ADD OBSERVACAO VARCHAR(80)';
  WHEN ANY DO BEGIN END
  END
END^
SET TERM ; ^
COMMIT;
