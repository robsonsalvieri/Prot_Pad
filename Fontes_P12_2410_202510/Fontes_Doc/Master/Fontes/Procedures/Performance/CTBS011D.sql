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
    Saida           - <o>  </ro>
    Responsavel :     <r>  	</r>
    Data        :     01/03/2010
   -------------------------------------------------------------------------------------- */
-- Cria procedure de gravacao de movimentos no CSA
-- PROCEDURE CT11POPCSA 
CREATE PROCEDURE CTBS011D_## (
    @IN_FILIAL Char( 'CSA_FILIAL' ) , 
    @IN_CODREV Char( 'CSA_CODREV' ) , 
    @IN_NUMLOT Char( 'CSA_NUMLOT' ) , 
    @IN_DTLANC Char( 'CSA_DTLANC' ) , 
    @IN_VLLCTO Float , 
    @IN_INDTIP Char( 'CSA_INDTIP' ) , 
    @IN_DTEXT Char( 008 ),
    @IN_LMOEDFUN  Char( 01 ),
    @IN_VLLFUN  Float ,
    @IN_ADDVLL  Float ,
    @IN_LCSQ   Char( 01 )) AS
 
-- Declaration of variables
DECLARE @iRecno Integer
DECLARE @nVlLcto Float
Declare @nVLLFUN     Float
Declare @nADDVLL     Float
BEGIN
   SELECT @nVlLcto  = ROUND ( @IN_VLLCTO , 2 )
   IF @IN_LMOEDFUN = '1'
   BEGIN
      SELECT @nVLLFUN = Round( @IN_VLLFUN, 2 )
      SELECT @nADDVLL = Round( @IN_ADDVLL, 2 )
   END
   SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 )
     FROM CSA### 
   SELECT @iRecno  = @iRecno  + 1 
   IF @IN_LCSQ = '1'
   BEGIN  
      IF @IN_LMOEDFUN ='0'
      BEGIN
         ##TRATARECNO @iRecno\
            INSERT INTO CSA### (CSA_FILIAL , CSA_CODREV , CSA_NUMLOT , CSA_DTLANC , CSA_VLLCTO , CSA_INDTIP , CSA_DTEXT , R_E_C_N_O_ ) 
            VALUES (@IN_FILIAL , @IN_CODREV , RTRIM ( @IN_NUMLOT ) || @IN_DTEXT , @IN_DTLANC , @nVlLcto ,
            @IN_INDTIP , @IN_DTEXT ,@iRecno )
         ##FIMTRATARECNO
      END
      ELSE
      BEGIN
         ##TRATARECNO @iRecno\
            INSERT INTO CSA### (CSA_FILIAL , CSA_CODREV , CSA_NUMLOT , CSA_DTLANC , CSA_VLLCTO , CSA_INDTIP , CSA_DTEXT , CSA_VLLFUN, CSA_ADDVLL , R_E_C_N_O_ ) 
            VALUES (@IN_FILIAL , @IN_CODREV , RTRIM ( @IN_NUMLOT ) || @IN_DTEXT , @IN_DTLANC , @nVlLcto ,
            @IN_INDTIP , @IN_DTEXT , @nVLLFUN, @nADDVLL , @iRecno )
         ##FIMTRATARECNO
      END
   END
   ELSE
   BEGIN
      IF @IN_LMOEDFUN ='0'
      BEGIN
         ##TRATARECNO @iRecno\
            INSERT INTO CSA### (CSA_FILIAL , CSA_CODREV , CSA_NUMLOT , CSA_DTLANC , CSA_VLLCTO , CSA_INDTIP , R_E_C_N_O_ ) 
            VALUES (@IN_FILIAL , @IN_CODREV , RTRIM ( @IN_NUMLOT ) || @IN_DTEXT , @IN_DTLANC , @nVlLcto ,
            @IN_INDTIP ,@iRecno )
         ##FIMTRATARECNO
      END
      ELSE
      BEGIN
         ##TRATARECNO @iRecno\
            INSERT INTO CSA### (CSA_FILIAL , CSA_CODREV , CSA_NUMLOT , CSA_DTLANC , CSA_VLLCTO , CSA_INDTIP , CSA_VLLFUN, CSA_ADDVLL,R_E_C_N_O_ ) 
            VALUES (@IN_FILIAL , @IN_CODREV , RTRIM ( @IN_NUMLOT ) || @IN_DTEXT , @IN_DTLANC , @nVlLcto ,
            @IN_INDTIP , @nVLLFUN, @nADDVLL ,@iRecno )
         ##FIMTRATARECNO
      END
   END
END 