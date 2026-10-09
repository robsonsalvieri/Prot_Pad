
CREATE PROCEDURE CTB220ALT_## (

@IN_FILIAL Char( 'CT2_FILIAL' ),
@IN_DATA Char( 8 ) ,
@IN_LINHA Char( 'CT2_LINHA' ) ,
@IN_TPSALD Char( 'CT2_TPSALD' ) ,
@IN_EMPORI Char( 'CT2_EMPORI' ) ,
@IN_FILORI Char( 'CT2_FILORI' ) ,
@IN_MOEDLC Char( 'CT2_MOEDLC' ) ,
@IN_LOTE Char( 'CT2_LOTE' ) ,
@IN_SBLOTE Char( 'CT2_SBLOTE' ) ,
@IN_DOC Char( 'CT2_DOC' ) ,
@IN_HIST Char( 'CT2_HIST' ) ,
@IN_VALOR Float ,
@OUT_HIST Char( 'CT2_HIST' ) output ,
@OUT_VALOR Float output ) AS

-- Declaration of variables
DECLARE @cHist Char( 'CT2_HIST' )
DECLARE @nValor Float

--Tratameto de valores e histórico 
BEGIN
   SELECT @OUT_HIST = @IN_HIST
   SELECT @OUT_VALOR = @IN_VALOR
END