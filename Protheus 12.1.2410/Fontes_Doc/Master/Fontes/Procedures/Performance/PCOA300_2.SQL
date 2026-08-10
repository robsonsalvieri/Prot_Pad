-- Procedure creation 
CREATE PROCEDURE PCOA300_2 (
    @IN_FILIAL Char( 'AKG_FILIAL' ) , 
    @IN_CONFIG Char( 'AKT_CONFIG' ) , 
    @IN_DATAI Char( 'AK2_DATAI' ) , 
    @IN_DATAF Char( 'AK2_DATAI' ) , 
    @IN_TPSALD Char( 'AKD_TPSALD' ) , 
    @IN_FK Char( 'AK1_TPPERI' ) ) AS
 
-- Declaration of variables
DECLARE @cAux Char( 'AK0_VERSAO' )
DECLARE @cFil_AKT Char( 'AKG_FILIAL' )
DECLARE @iMinRecno Integer
DECLARE @iMaxRecno Integer
DECLARE @iNroRegs Integer
BEGIN
   SELECT @iMinRecno  = 0 
END 