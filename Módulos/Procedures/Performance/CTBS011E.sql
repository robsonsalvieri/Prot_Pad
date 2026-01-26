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
                           @IN_INDTIP - indice do lancto
                           @IN_DATA   - Data do Lancto <ri/>
    Saida           - <o>  </ro>
    Responsavel :     <r>  	</r>
    Data        :     01/03/2010
   -------------------------------------------------------------------------------------- */
   
-- Cria procedure de gravacao de movimentos na tabela CSB
--PROCEDURE CT11POPCSB
CREATE PROCEDURE CTBS011E_## (
    @IN_FILIAL Char( 'CSB_FILIAL' ) , 
    @IN_CODREV Char( 'CSB_CODREV' ) , 
    @IN_CHAVE Char( 'CSB_NUMLOT' ) , 
    @IN_LINHA Char( 'CSB_LINHA' ) , 
    @IN_DEBITO Char( 'CSB_CODCTA' ) , 
    @IN_CCD Char( 'CSB_CCUSTO' ) , 
    @IN_DC Char( 01 ) , 
    @IN_CODHIST Char( 'CSB_CODHIS' ) , 
    @IN_HIST VarChar( 'CSB_HISTOR' ) , 
    @IN_VALOR Float , 
    @IN_DTEXT Char( 008 ) , 
    @IN_FUVALOR   Float,
    @IN_ADVALOR   Float,
    @IN_TXFECHA   Float,
    @IN_TXMEDIA   Float,
    @IN_CODPAR Char( 'CSB_CODPAR' ) , 
    @IN_NUMARQ Char( 'CSB_NUMARQ' ) , 
    @IN_DATA Char( 08 ) , 
    @IN_LCUSTO Char( 01 ) , 
    @IN_ENTREF Char( 02 ) , 
    @IN_LMOEDFUN  Char( 01 ),
    @IN_CTPMOED  Char( 'CTP_MOEDA' ),
    @IN_LCSQ Char( 01 ),
    @IN_LENTREF Char( 01 ),
    @IN_CCODPLA Char( 'CVD_CODPLA' ) ,
    @IN_CVERPLA Char( 'CVD_VERSAO' ) ,
    @OUT_RECNO Integer  output ) AS
 
-- Declaration of variables
DECLARE @cFilial_CSA Char( 'CSA_FILIAL' )
DECLARE @cFilial_CSB Char( 'CSB_FILIAL' )
DECLARE @cFilial_CTP Char( 'CTP_FILIAL' )
DECLARE @iRecno Integer
DECLARE @nVlLcto Float
DECLARE @cCusto Char( 'CSB_CCUSTO' )
DECLARE @iRecnoZ Integer
DECLARE @cAux Char( 03 )
DECLARE @NCONT Integer
Declare @nFuVlLcto Float
Declare @nAdVlLcto Float
Declare @cNtSped Char( 'CT1_NTSPED' )
Declare @nTaxa Float
Declare @nCtpTaxa Float
Declare @nCtpTxMd Float
Declare @nDebCsa Float
Declare @nCreCsa Float
Declare @nDFuCsa Float
Declare @nCFuCsa Float
Declare @nDAdCsa Float
Declare @nCAdCsa Float

BEGIN
   IF @IN_LMOEDFUN = '1'
   BEGIN
      SELECT @cAux  = 'CTP' 
      EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CTP output 
      SELECT @nFuVlLcto = 0
      SELECT @nAdVlLcto = 0
      SELECT @cNtSped = ''		
      SELECT @nTaxa = 0     
      SELECT @nCtpTaxa = 0
      SELECT @nCtpTxMd = 0
      SELECT @nDebCsa = 0
      SELECT @nCreCsa = 0
      SELECT @nDFuCsa = 0
      SELECT @nCFuCsa = 0
      SELECT @nDAdCsa = 0
      SELECT @nCAdCsa = 0        
      SELECT @nCtpTxMd = @IN_TXMEDIA 
      SELECT @cNtSped = CT1_NTSPED FROM CT1###
         WHERE CT1_CONTA = @IN_DEBITO
         SELECT @nCtpTaxa = CTP_TAXA FROM CTP### WHERE CTP_FILIAL = @cFilial_CTP AND CTP_MOEDA = @IN_CTPMOED AND CTP_DATA = @IN_DATA
      IF @cNtSped  between '01' and '02' 
      BEGIN 
         SELECT @nTaxa = @IN_TXFECHA 
      END
      ELSE
      BEGIN
         IF @cNtSped  = '03' 
         BEGIN
            SELECT @nTaxa = @nCtpTaxa
         END
         ELSE
         BEGIN
            IF @cNtSped  = '04' 
            BEGIN 
               SELECT @nTaxa = @nCtpTxMd 
            END
         END
      END
      SELECT @nFuVlLcto = Round( @IN_FUVALOR, 2 )
      SELECT @nAdVlLcto = Round( @IN_ADVALOR, 2 )
   END

   SELECT @nVlLcto  = ROUND ( @IN_VALOR , 2 )
   SELECT @cAux  = 'CSB' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CSB output 
   SELECT @OUT_RECNO  = 0 
   SELECT @cCusto  = @IN_CCD 
   IF @IN_LCUSTO  = '0' 
   BEGIN 
      SELECT @cCusto  = ' ' 
   END 
   SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
     FROM CSB###
   SELECT @iRecno  = @iRecno  + 1 
   IF ROUND ( @nVlLcto , 2 ) != 0.00 
   BEGIN 
      IF @IN_LMOEDFUN = '1'
      BEGIN
         IF @IN_LCSQ = '01'
         BEGIN
            ##TRATARECNO @iRecno\
               INSERT INTO CSB### (CSB_FILIAL,  CSB_CODREV, CSB_NUMLOT, CSB_LINHA,  CSB_CODCTA, CSB_CCUSTO, CSB_INDDC, 
                  CSB_CODHIS,  CSB_HISTOR, CSB_VLPART,CSB_FUPART, CSB_TAXA, CSB_ADPART, CSB_CODPAR, CSB_NUMARQ, CSB_DTLANC , CSB_DTEXT , R_E_C_N_O_ ) 
               VALUES (@cFilial_CSB,  @IN_CODREV, @IN_CHAVE,  @IN_LINHA,  @IN_DEBITO, @cCusto, @IN_DC,  @IN_CODHIST , 
                     SUBSTRING ( @IN_HIST , 1 , 254254 ), @nVlLcto,@nFuVlLcto,@nTaxa,@nAdVlLcto, @IN_CODPAR, @IN_NUMARQ, @IN_DATA, @IN_DTEXT , @iRecno )
            ##FIMTRATARECNO
         END
         ELSE
         BEGIN
            ##TRATARECNO @iRecno\
               INSERT INTO CSB### (CSB_FILIAL,  CSB_CODREV, CSB_NUMLOT, CSB_LINHA,  CSB_CODCTA, CSB_CCUSTO, CSB_INDDC, 
                  CSB_CODHIS,  CSB_HISTOR, CSB_VLPART,CSB_FUPART, CSB_TAXA, CSB_ADPART, CSB_CODPAR, CSB_NUMARQ, CSB_DTLANC , R_E_C_N_O_ ) 
               VALUES (@cFilial_CSB,  @IN_CODREV, @IN_CHAVE,  @IN_LINHA,  @IN_DEBITO, @cCusto, @IN_DC,  @IN_CODHIST , 
                     SUBSTRING ( @IN_HIST , 1 , 254254 ), @nVlLcto,@nFuVlLcto,@nTaxa,@nAdVlLcto, @IN_CODPAR, @IN_NUMARQ, @IN_DATA, @iRecno )
            ##FIMTRATARECNO
         END
      END
      ELSE
      BEGIN
         IF @IN_LCSQ = '01'
         BEGIN
            ##TRATARECNO @iRecno\
               INSERT INTO CSB### (CSB_FILIAL , CSB_CODREV , CSB_NUMLOT , CSB_LINHA , CSB_CODCTA , CSB_CCUSTO , CSB_INDDC , CSB_CODHIS , 
                     CSB_HISTOR , CSB_VLPART , CSB_CODPAR , CSB_NUMARQ , CSB_DTLANC , CSB_DTEXT , R_E_C_N_O_ ) 
               VALUES (@cFilial_CSB , @IN_CODREV , RTRIM(@IN_CHAVE)||@IN_DTEXT  , @IN_LINHA , @IN_DEBITO , @cCusto , @IN_DC , @IN_CODHIST , 
                     SUBSTRING ( @IN_HIST , 1 , 254254 ), @nVlLcto , @IN_CODPAR , @IN_NUMARQ , @IN_DATA , @IN_DTEXT , @iRecno )
            ##FIMTRATARECNO
         END
         ELSE
         BEGIN
            ##TRATARECNO @iRecno\
               INSERT INTO CSB### (CSB_FILIAL , CSB_CODREV , CSB_NUMLOT , CSB_LINHA , CSB_CODCTA , CSB_CCUSTO , CSB_INDDC , CSB_CODHIS , 
                     CSB_HISTOR , CSB_VLPART , CSB_CODPAR , CSB_NUMARQ , CSB_DTLANC , R_E_C_N_O_ ) 
               VALUES (@cFilial_CSB , @IN_CODREV , @IN_CHAVE  , @IN_LINHA , @IN_DEBITO , @cCusto , @IN_DC , @IN_CODHIST , 
                     SUBSTRING ( @IN_HIST , 1 , 254254 ), @nVlLcto , @IN_CODPAR , @IN_NUMARQ , @IN_DATA , @iRecno )
            ##FIMTRATARECNO
         END
      END
      IF @IN_LENTREF = '1'
      BEGIN
         IF @IN_LMOEDFUN = '1'
         BEGIN
            --PROCEDURE CT11POPCSL_
            EXEC CTBS011F_## @IN_FILIAL, @IN_CODREV,   @IN_CHAVE,      @IN_LINHA, @IN_DEBITO, @cCusto, @IN_DC, 
		         @nVlLcto,@nFuVlLcto,@nAdVlLcto,@nTaxa, @IN_DATA, @IN_LCUSTO, @IN_ENTREF, @IN_NUMARQ, @IN_LMOEDFUN , @IN_CCODPLA, @IN_CVERPLA , @iRecnoZ OutPut
         END
         ELSE
         BEGIN
            --PROCEDURE CT11POPCSL_
            EXEC CTBS011F_## @IN_FILIAL, @IN_CODREV,   @IN_CHAVE,      @IN_LINHA, @IN_DEBITO, @cCusto, @IN_DC,
		         @nVlLcto, 0,0,0,@IN_DATA, @IN_LCUSTO, @IN_ENTREF, @IN_NUMARQ, @IN_LMOEDFUN , @IN_CCODPLA, @IN_CVERPLA , @iRecnoZ OutPut 
         END
      END
      IF @IN_LMOEDFUN = '1'
      BEGIN
         SELECT @cAux  = 'CSB' 
         EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilial_CSA output 
         SELECT @nDebCsa = isnull(sum(CSB_VLPART),0) FROM CSB### WHERE CSB_FILIAL = @cFilial_CSB AND D_E_L_E_T_=' '  AND CSB_INDDC='D' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT
         SELECT @nCreCsa = isnull(sum(CSB_VLPART),0) FROM CSB### WHERE CSB_FILIAL = @cFilial_CSB AND D_E_L_E_T_=' '  AND CSB_INDDC='C' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT
         SELECT @nDFuCsa = isnull(sum(CSB_FUPART),0) FROM CSB### WHERE CSB_FILIAL = @cFilial_CSB AND D_E_L_E_T_=' '  AND CSB_INDDC='D' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT
         SELECT @nCFuCsa = isnull(sum(CSB_FUPART),0) FROM CSB### WHERE CSB_FILIAL = @cFilial_CSB AND D_E_L_E_T_=' '  AND CSB_INDDC='C' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT
         SELECT @nDAdCsa = isnull(sum(CSB_ADPART),0) FROM CSB### WHERE CSB_FILIAL = @cFilial_CSB AND D_E_L_E_T_=' '  AND CSB_INDDC='D' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT
         SELECT @nCAdCsa = isnull(sum(CSB_ADPART),0) FROM CSB### WHERE CSB_FILIAL = @cFilial_CSB AND D_E_L_E_T_=' '  AND CSB_INDDC='C' AND CSB_DTLANC = @IN_DATA AND CSB_CODREV = @IN_CODREV  GROUP BY CSB_FILIAL, CSB_CODREV, CSB_DTLANC, CSB_NUMLOT
         IF @nDebCsa != 0 
         BEGIN
            UPDATE CSA### Set CSA_VLLCTO = Round( @nDebCsa, 2 ), CSA_VLLFUN= Round( @nDFuCsa, 2 ), CSA_ADDVLL= Round( @nDAdCsa, 2 )
               Where CSA_FILIAL = @cFilial_CSA AND CSA_CODREV= @IN_CODREV AND  CSA_DTLANC = @IN_DATA AND CSA_NUMLOT = @IN_CHAVE
         END 
         ELSE 
         BEGIN
            UPDATE CSA### Set CSA_VLLCTO = Round( @nCreCsa, 2 ), CSA_VLLFUN= Round( @nCFuCsa, 2 ), CSA_ADDVLL= Round( @nCAdCsa, 2 )
               Where CSA_FILIAL = @cFilial_CSA AND CSA_CODREV= @IN_CODREV AND  CSA_DTLANC = @IN_DATA AND CSA_NUMLOT = @IN_CHAVE
         END
      END
   END 
   SELECT @OUT_RECNO  = @iRecno 
END 