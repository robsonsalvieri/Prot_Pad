/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.10 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  SPEDCTBA.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Procedure       -      Grava CSA
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL - filial a gravar
                           @IN_CODREV - Codigo da Revisao
                           @IN_NUMLOT - Numero do Lote
                           @IN_DTLANC - Data do Lancto
                           @IN_VLLCTO - Valro do Lancto
                           @IN_DATA   - Data do Lancto <ri/>
    Saida           - <o>  </ro>
    Responsavel :     <r>  	</r>
    Data        :     01/03/2010
   -------------------------------------------------------------------------------------- */
-- Cria procedure de gravacao de movimentos na tabela CSL
--PROCEDURE CT11POPCSL_
CREATE PROCEDURE CTBS011F_## (
    @IN_FILIAL Char( 'CSL_FILIAL' ) , 
    @IN_CODREV Char( 'CSL_CODREV' ) , 
    @IN_CHAVE Char( 'CSL_NUMLOT' ) , 
    @IN_LINHA Char( 'CSL_LINHA' ) , 
    @IN_DEBITO Char( 'CSL_CODCTA' ) , 
    @IN_CCD Char( 'CSL_CCUSTO' ) , 
    @IN_DC Char( 01 ) , 
    @IN_VALOR Float , 
    @IN_FUVALOR Float,
    @IN_ADVALOR Float,
    @IN_TAXA Float,
    @IN_DATA Char( 08 ) , 
    @IN_LCUSTO Char( 01 ) , 
    @IN_ENTREF Char( 02 ) , 
    @IN_NUMARQ Char( 'CSL_NUMARQ' ) , 
    @IN_LMOEDFUN Char( 01 ),
    @IN_CCODPLA Char( 'CVD_CODPLA' ) ,
    @IN_CVERPLA Char( 'CVD_VERSAO' ) ,
    @OUT_RECNO Integer  output ) AS
 
-- Declaration of variables
DECLARE @iRecno Integer
DECLARE @nVlLcto Float
Declare @nFUVlLcto Float
Declare @nADVlLcto Float
Declare @cFCODPLA Char( 'CVD_CODPLA' ) 
Declare @cFCVERPLA Char( 'CVD_VERSAO' ) 
DECLARE @cCusto Char( 'CSB_CCUSTO' )
DECLARE @cFilial_CVD Char( 'CVD_FILIAL' )
DECLARE @cFilial_CSL Char( 'CSL_FILIAL' )
DECLARE @cCVD_CONTA VarChar( 'CVD_CONTA' )
DECLARE @cCVD_CTAREF VarChar( 'CVD_CTAREF' )
DECLARE @cCVD_ENTREF Char( 'CVD_ENTREF' )
DECLARE @cCVD_CUSTO Char( 'CVD_CUSTO' )
DECLARE @cAux Char( 03 )
DECLARE @NCONT Integer

BEGIN
   SELECT @cAux  = 'CVD' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CVD output 
   SELECT @cAux  = 'CSL' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CSL output 
   SELECT @OUT_RECNO  = 0 
   SELECT @cCusto  = @IN_CCD 
   SELECT @cCVD_CONTA  = ' ' 
   SELECT @cCVD_ENTREF  = ' ' 
   SELECT @cCVD_CTAREF  = ' ' 
   SELECT @cCVD_CUSTO  = ' ' 
   IF RTRIM(LTRIM(@IN_CCODPLA)) IS NULL OR RTRIM(LTRIM(@IN_CCODPLA )) = ''
   BEGIN 
      SELECT @cFCODPLA = NULL
      SELECT @cFCVERPLA = NULL
   END
   ELSE
   BEGIN
      SELECT @cFCODPLA = @IN_CCODPLA
      SELECT @cFCVERPLA = @IN_CVERPLA
   End

   IF @IN_LCUSTO  = '0' 
   BEGIN 
      SELECT @cCusto  = ' ' 
   END 
   SELECT @nVlLcto  = ROUND ( @IN_VALOR , 2 )

   IF @IN_LMOEDFUN = '1'
   BEGIN
      SELECT @nFUVlLcto = Round( @IN_FUVALOR, 2 )
	   SELECT @nADVlLcto = Round( @IN_ADVALOR, 2 )
   END
   -- Cursor declaration cursor_CVD
      DECLARE cursor_CVD insensitive  CURSOR FOR 
      SELECT CVD_CONTA , CVD_ENTREF , CVD_CTAREF , CVD_CUSTO 
      FROM CVD### 
      WHERE CVD_FILIAL  = @cFilial_CVD  and CVD_ENTREF  = @IN_ENTREF 
         and ( CVD_CODPLA = @cFCODPLA OR @cFCODPLA IS NULL )
         and ( CVD_VERSAO = @cFCVERPLA OR @cFCVERPLA IS NULL )
         and CVD_CONTA  = @IN_DEBITO  and CVD_CUSTO  = @cCusto  and D_E_L_E_T_  = ' ' 
         FOR READ ONLY 
   OPEN cursor_CVD
   FETCH cursor_CVD 
    INTO @cCVD_CONTA , @cCVD_ENTREF , @cCVD_CTAREF , @cCVD_CUSTO 
   WHILE ( (@@Fetch_Status  = 0 ) )
   BEGIN
      SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
        FROM CSL###
      SELECT @iRecno  = @iRecno  + 1 
      IF ROUND ( @nVlLcto , 2 ) != 0.00 
      BEGIN 
         IF @IN_LMOEDFUN = '1'
         BEGIN
            ##TRATARECNO @iRecno\
               INSERT INTO CSL### (CSL_FILIAL, CSL_CODREV, CSL_NUMLOT, CSL_LINHA,  CSL_CODCTA, CSL_CCUSTO, CSL_INDDC, 
                  CSL_VLPART , CSL_FUPART,CSL_ADPART,CSL_TAXA, CSL_DTLANC, CSL_CTAREF, CSL_NUMARQ, R_E_C_N_O_ ) 
               VALUES (@cFilial_CSL, @IN_CODREV, @IN_CHAVE,  @IN_LINHA,  @IN_DEBITO, @cCusto, @IN_DC,
                  @nVlLcto,@nFUVlLcto,@nADVlLcto,@IN_TAXA, @IN_DATA, @cCVD_CTAREF, @IN_NUMARQ, @iRecno )
            ##FIMTRATARECNO
         END
         ELSE
         BEGIN
            ##TRATARECNO @iRecno\
               INSERT INTO CSL### (CSL_FILIAL , CSL_CODREV , CSL_NUMLOT , CSL_LINHA , CSL_CODCTA , CSL_CCUSTO , CSL_INDDC , 
                  CSL_VLPART , CSL_DTLANC , CSL_CTAREF , CSL_NUMARQ , R_E_C_N_O_ ) 
               VALUES (@cFilial_CSL , @IN_CODREV , @IN_CHAVE , @IN_LINHA , @IN_DEBITO , @cCusto , @IN_DC ,
                  @nVlLcto , @IN_DATA , @cCVD_CTAREF , @IN_NUMARQ , @iRecno )
            ##FIMTRATARECNO
         END
      END 
      FETCH cursor_CVD 
       INTO @cCVD_CONTA , @cCVD_ENTREF , @cCVD_CTAREF , @cCVD_CUSTO 
   END 
   CLOSE cursor_CVD
   DEALLOCATE cursor_CVD
   SELECT @OUT_RECNO  = @iRecno 
END 