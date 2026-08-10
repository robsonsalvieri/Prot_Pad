-- Procedure creation 
CREATE PROCEDURE PCOA300_3 (
    @IN_FILIAL Char( 'AKG_FILIAL' ) , 
    @IN_CONFIG Char( 'AKT_CONFIG' ) , 
    @IN_DATA Char( 'AK2_DATAI' ) , 
    @IN_CTAB Char( 'ABS_CEP' ) , 
    @IN_VALORD1 Float , 
    @IN_VALORD2 Float , 
    @IN_VALORD3 Float , 
    @IN_VALORD4 Float , 
    @IN_VALORD5 Float , 
    @IN_VALORC1 Float , 
    @IN_VALORC2 Float , 
    @IN_VALORC3 Float , 
    @IN_VALORC4 Float , 
    @IN_VALORC5 Float , 
    @IN_NIV01 Char( 'AKD_CO' ) , 
    @IN_NIV02 Char( 'AKD_CO' ) , 
    @IN_NIV03 Char( 'AKD_CO' ) , 
    @IN_NIV04 Char( 'AKD_CO' ) , 
    @IN_NIV05 Char( 'AKD_CO' ) ) AS
 
-- Declaration of variables
DECLARE @cAnalitica Char( 'AKD_CO' )
DECLARE @cSuperior Char( 'AKD_CO' )
DECLARE @cChaveR Char( 'AKT_CHAVE' )
DECLARE @iRegs Integer
DECLARE @iTranCount Integer
DECLARE @cExecSql  nvarchar(250)
BEGIN
   SELECT @cChaveR  = '' 
END 