Create Procedure ATF070_##
(   @IN_cFilial         CHAR(8), 
    @IN_dDataBase       CHAR(8),    
    @IN_dMesAnt         CHAR(8),     
    @IN_lAtfctap        INTEGER,
    @IN_cN1TipoNeg      VARCHAR(50),
    @IN_cN3TipoNeg      VARCHAR(50),
    @IN_cContaCap       CHAR(20),
    @IN_nCorrec         FLOAT,
    @IN_cCalcDep        CHAR(1),
    @IN_cTipDepr        CHAR(1),
    @IN_IN_TRANSACTION  CHAR(1),
    @OUT_RESULTADO      CHAR(1) OUTPUT)
as
Declare @cFilSN3  Char( 'N3_FILIAL' )
begin   
    exec XFILIAL_## 'SN3', @cFilSN3, @IN_cFilial OutPut        
    select @OUT_RESULTADO = '1'
end
