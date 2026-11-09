/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P.10 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  SPEDCTBA.PRW </s>
    Descricao       - <d>  SPED SigaCTB </d>
    Procedure       -      Verifica se é data de Apuracao
    Funcao do Siga  -      ProcMov()
    Entrada         - <ri> @IN_EMP     - Empresa onde procurar a data de apuracao
                           @IN_FIL     - Filial onde procurar a data de Apuracao
                           @IN_DATA    - Data a Verificar
                           @IN_MOEDA   - Moeda escolhida
                           @IN_TPSALD  - Tipos de Saldo escolhido
						   @IN_LOTE    - Lote do lançamento de apuração
                           @IN_SBLOTE  - SubLote do lançamento de apuração
                           @IN_DOC     - Documento do lançamento de apuração
                           @IN_EMPORI  - Empresa de Origem do lançamento de apuração
                           @IN_FILORI  - Filial de Origem do Lançamento de Apuração
    Saida           - <o>  @OUT_RESULT - '0' NAO e data de Apuracao, '1' e data de Apuracao </ro>
    Responsavel :     <r>  	</r>
    Data        :     26/02/2010
   -------------------------------------------------------------------------------------- */
--Cria procedure para verifcar se a data e de apuracao de Lucros e Perdas 
-- CREATE PROCEDURE CT11DTLP##
CREATE PROCEDURE CTBS011C_## (
    @IN_EMP Char( 'CT2_EMPORI' ) , 
    @IN_FIL Char( 'CT2_FILIAL' ) , 
    @IN_DATA Char( 08 ) , 
    @IN_MOEDA Char( 'CT2_MOEDLC' ) , 
    @IN_TPSALD Char( 'CT2_TPSALD' ) , 
    @IN_LOTE Char( 'CT2_LOTE' ) , 
    @IN_SBLOTE Char( 'CT2_SBLOTE' ) , 
    @IN_DOC Char( 'CT2_DOC' ) , 
    @IN_EMPORI Char( 'CT2_EMPORI' ) , 
    @IN_FILORI Char( 'CT2_FILORI' ) , 
    @IN_LCW0  Char( 01 ),
    @IN_TAMFILCT2  Integer,
    @IN_TAMTOTCT2  Integer,
    @OUT_RESULT Char( 01 )  output ) AS
 
-- Declaration of variables
DECLARE @iRecno Integer
BEGIN
   SELECT @iRecno  = Null 
   SELECT @OUT_RESULT  = '0' 
   IF @IN_LCW0 = '1'
   BEGIN
      IF @IN_TAMFILCT2 > 0
      BEGIN
         SELECT @iRecno  = R_E_C_N_O_ 
            FROM CW0### 
            WHERE CW0_TABELA  = 'LP'  and SUBSTRING ( CW0_CHAVE , 1 , 2 ) = @IN_EMP 
               and SUBSTRING(CW0_CHAVE,3,@IN_TAMFILCT2) = SUBSTRING(@IN_FIL,1,@IN_TAMFILCT2)
               and SUBSTRING ( CW0_DESC01 , 1 , @IN_TAMTOTCT2 ) = @IN_DATA  || @IN_MOEDA  || @IN_TPSALD  || 'Z'  
               and SUBSTRING ( CW0_DESC01 , 1 , 08 )
               NOT in ( 
                  SELECT CTZ_DATA 
                     FROM CTZ### CTZ
                     WHERE CTZ.CTZ_FILIAL  = @IN_FIL  and CTZ.CTZ_DATA  = @IN_DATA  and CTZ.CTZ_LOTE  = @IN_LOTE  and CTZ.CTZ_SBLOTE  = @IN_SBLOTE 
                        and CTZ.CTZ_DOC  = @IN_DOC  and CTZ.CTZ_TPSALD  = @IN_TPSALD  and CTZ.CTZ_EMPORI  = @IN_EMPORI  and CTZ.CTZ_FILORI  = @IN_FILORI 
                        and CTZ.CTZ_MOEDLC  = @IN_MOEDA  and CTZ.D_E_L_E_T_  = ' '  )  
            and D_E_L_E_T_  = ' '
      END
      ELSE
      BEGIN
         SELECT @iRecno  = R_E_C_N_O_ 
            FROM CW0### 
            WHERE CW0_TABELA  = 'LP'  and SUBSTRING ( CW0_CHAVE , 1 , 2 ) = @IN_EMP 
               and SUBSTRING ( CW0_DESC01 , 1 , @IN_TAMTOTCT2 ) = @IN_DATA  || @IN_MOEDA  || @IN_TPSALD  || 'Z'  
               and SUBSTRING ( CW0_DESC01 , 1 , 08 )
               NOT in ( 
                  SELECT CTZ_DATA 
                     FROM CTZ### CTZ
                     WHERE CTZ.CTZ_FILIAL  = @IN_FIL  and CTZ.CTZ_DATA  = @IN_DATA  and CTZ.CTZ_LOTE  = @IN_LOTE  and CTZ.CTZ_SBLOTE  = @IN_SBLOTE 
                        and CTZ.CTZ_DOC  = @IN_DOC  and CTZ.CTZ_TPSALD  = @IN_TPSALD  and CTZ.CTZ_EMPORI  = @IN_EMPORI  and CTZ.CTZ_FILORI  = @IN_FILORI 
                        and CTZ.CTZ_MOEDLC  = @IN_MOEDA  and CTZ.D_E_L_E_T_  = ' '  )  
            and D_E_L_E_T_  = ' '
      END
      IF @iRecno is null 
      BEGIN 
         SELECT @OUT_RESULT  = '0' 
      END 
      ELSE 
      BEGIN 
         SELECT @OUT_RESULT  = '1' 
      END 
   END
   ELSE
   BEGIN
      SELECT @iRecno = R_E_C_N_O_
	      From SX5### SX5
         Where X5_TABELA = 'LP'
            and X5_CHAVE  = @IN_EMP||@IN_FIL 
            and Substring(X5_DESCRI,1,@IN_TAMTOTCT2) = @IN_DATA||@IN_MOEDA||@IN_TPSALD||'Z'
            and D_E_L_E_T_ = ' '
      IF @iRecno is null 
      BEGIN
         select @OUT_RESULT = '0'
      END
      ELSE 
      BEGIN
         select @OUT_RESULT = '1'
      END
   END
END 