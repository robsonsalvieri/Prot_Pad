/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.11 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBS011.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Procedure       -      Grava CS4
    Funcao do Siga  -      
    Entrada         - <ri> @IN_FILIAL - filial a gravar
                           @IN_CODREV - Codigo da Revisao
                           @IN_LPROCCTO - Se processa o custo - ainda estamos mandando tudo
    Saida           - <o>  </ro>
    Responsavel :     <r>  Renato F Campos </r>
    Data        :     14/06/2011
   -------------------------------------------------------------------------------------- */

-- Cria procedure de gravacao das contas referenciais 
-- PROCEDURE PROCCTAREF
CREATE PROCEDURE CTBS011B_## (
    @IN_FILIAL Char( 'CS4_FILIAL' ) , 
    @IN_CODREV Char( 'CS4_CODREV' ) , 
    @IN_LPROCCTO Char( 01 ) , 
    @IN_CODPLA Char( 'CVD_CODPLA' ) , 
    @IN_LEMPTYPLA Char( 01 ) , 
    @IN_VERPLA Char( 'CVD_VERSAO' ) , 
    @IN_MOEDAESC Char( 03 ) , 
    @OUT_RESULT Char( 01 )  output ) AS
 
-- Declaration of variables
DECLARE @cFilial_CVD Char( 'CVD_FILIAL' )
DECLARE @cFilial_CS4 Char( 'CS4_FILIAL' )
DECLARE @cCVD_CONTA VarChar( 'CVD_CONTA' )
DECLARE @cCVD_CTAREF VarChar( 'CVD_CTAREF' )
DECLARE @cCVD_ENTREF Char( 'CVD_ENTREF' )
DECLARE @cCVD_CUSTO Char( 'CVD_CUSTO' )
DECLARE @cCVD_TPUTIL Char( 'CVD_TPUTIL' )
DECLARE @cCVD_CLASSE Char( 'CVD_CLASSE' )
DECLARE @cFCVD_CLASSE Char( 'CVD_CLASSE' )
DECLARE @cCVD_NATCTA Char( 'CVD_NATCTA' )
DECLARE @cCVD_CTASUP Char( 'CVD_CTASUP' )
DECLARE @cAux Char( 03 )
DECLARE @iRecno Integer
DECLARE @iNroRegs Integer
BEGIN
   SELECT @cCVD_CONTA  = '' 
   SELECT @cCVD_CTAREF  = '' 
   SELECT @cCVD_ENTREF  = '' 
   SELECT @cCVD_CUSTO  = '' 
   SELECT @cCVD_TPUTIL  = '' 
   SELECT @cCVD_CLASSE  = '' 
   SELECT @cCVD_NATCTA  = '' 
   SELECT @cCVD_CTASUP  = '' 
   SELECT @iRecno  = 0 
   SELECT @iNroRegs  = 0 
   SELECT @OUT_RESULT  = '0' 
   SELECT @cAux  = 'CVD' 
   
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CVD output 
   SELECT @cAux  = 'CS4' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CS4 output 
    
   -- Cursor declaration cursor_referencial
   
   IF @IN_MOEDAESC = 'FCO'
   BEGIN
      SELECT @cFCVD_CLASSE  = '2'
   END
   ELSE
   BEGIN
      SELECT @cFCVD_CLASSE  = NULL
   END
   DECLARE cursor_referencial insensitive  CURSOR FOR 
   SELECT CVD_CONTA , CVD_ENTREF , CVD_CTAREF , CVD_CUSTO , CVD_TPUTIL , CVD_CLASSE , CVD_NATCTA , CVD_CTASUP 
      FROM CVD### 
      WHERE CVD_FILIAL  = @cFilial_CVD 
      and ( CVD_CLASSE  = @cFCVD_CLASSE OR @cFCVD_CLASSE IS NULL )  
      and  ( 
            (@IN_LEMPTYPLA  = '0'  
            and CVD_CODPLA  = @IN_CODPLA 
            and CVD_VERSAO  = @IN_VERPLA 
            )  
         or  
            (@IN_CODPLA  = ' '  
            and CVD_VERSAO  = @IN_VERPLA 
            ) 
         )  
      and D_E_L_E_T_  = ' ' 
   FOR READ ONLY 
   OPEN cursor_referencial
   FETCH cursor_referencial 
    INTO @cCVD_CONTA , @cCVD_ENTREF , @cCVD_CTAREF , @cCVD_CUSTO , @cCVD_TPUTIL , @cCVD_CLASSE , @cCVD_NATCTA , @cCVD_CTASUP 
   WHILE ( (@@Fetch_Status  = 0 ) )
   BEGIN
      SELECT @iNroRegs  = @iNroRegs  + 1 
      IF @iNroRegs  = 1 
      BEGIN 
         begin tran 
         SELECT @iNroRegs  = @iNroRegs 
      END 
      SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) FROM CS4### 
      SELECT @iRecno  = @iRecno  + 1 
      ##TRATARECNO @iRecno\
      INSERT INTO CS4### (CS4_FILIAL , CS4_CODREV , CS4_CONTA , CS4_CTAREF , CS4_ENTREF , CS4_TPUTIL , CS4_CLASSE , CS4_NATCTA , 
            CS4_CTASUP , R_E_C_N_O_ ) 
      VALUES (@cFilial_CS4 , @IN_CODREV , @cCVD_CONTA , @cCVD_CTAREF , @cCVD_ENTREF , @cCVD_TPUTIL , @cCVD_CLASSE , @cCVD_NATCTA , 
            @cCVD_CTASUP , @iRecno )
      ##FIMTRATARECNO 
      FETCH cursor_referencial INTO @cCVD_CONTA , @cCVD_ENTREF , @cCVD_CTAREF , @cCVD_CUSTO , @cCVD_TPUTIL , @cCVD_CLASSE , @cCVD_NATCTA , @cCVD_CTASUP 
      IF @iNroRegs  >= 10000 
      BEGIN 
         commit tran 
         SELECT @iNroRegs  = 0 
      END 
   END 
   CLOSE cursor_referencial
   DEALLOCATE cursor_referencial
   IF @iNroRegs  > 0 
   BEGIN 
       SELECT @OUT_RESULT  = '9' 
   END 
   SELECT @OUT_RESULT  = '1' 
END 