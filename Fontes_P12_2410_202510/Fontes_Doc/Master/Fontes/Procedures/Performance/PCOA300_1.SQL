-- Procedure creation 
CREATE PROCEDURE PCOA300_1 (
    @IN_FILIALCOR Char( 'AKG_FILIAL' ) , 
    @IN_CONFIG Char( 'AKT_CONFIG' ) , 
    @IN_DATA Char( 'AK2_DATAI' ) , 
    @IN_CHAVE Char( 'AKT_CHAVE' ) , 
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
    @IN_ANALIT Char( 'AK1_TPPERI' ) , 
    @IN_NIV01 Char( 'AKD_CO' ) , 
    @IN_NIV02 Char( 'AKD_CO' ) , 
    @IN_NIV03 Char( 'AKD_CO' ) , 
    @IN_NIV04 Char( 'AKD_CO' ) , 
    @IN_NIV05 Char( 'AKD_CO' ) ) AS
 
-- Declaration of variables
DECLARE @cFil_AKT Char( 'AKG_FILIAL' )
DECLARE @cAux Char( 'AK0_VERSAO' )
DECLARE @iRecnoAKT Integer
DECLARE @nValorD1 Float
DECLARE @nValorD2 Float
DECLARE @nValorD3 Float
DECLARE @nValorD4 Float
DECLARE @nValorD5 Float
DECLARE @nValorC1 Float
DECLARE @nValorC2 Float
DECLARE @nValorC3 Float
DECLARE @nValorC4 Float
DECLARE @nValorC5 Float
DECLARE @iLoop Integer
DECLARE @ins_error Integer
DECLARE @ins_ini Integer
DECLARE @ins_fim Integer
DECLARE @icoderror Integer
BEGIN
   SELECT @cAux  = 'AKT' 
END 