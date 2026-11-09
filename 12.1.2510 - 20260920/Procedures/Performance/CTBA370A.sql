-- =============================================
-- Author:		Thiago Alves Bussolin
-- Create date: 14/11/2025
-- Description:	Reprocessamento SigaCTB Procedure - Atualizacao de Moedas - Qdo o criterio de conversao ou a taxa foi alterada
-- =============================================

/* ------------------------------------------------------------------------------------
  
   Fonte Microsiga - <s>  CTBA370.PRW </s>
   Descricao       - <d>  Reprocessamento SigaCTB </d>
   Procedure       -      Atualizacao de Moedas - Qdo o criterio de conversao ou a taxa foi alterada
   Funcao do Siga  -      Ct370Proc()
   Entrada         - <ri> @IN_FILIAL     - Filial DE
                          @IN_FILATE     - Filial ATE
                          @IN_DATAINI    - Data Inicial
                          @IN_DATAFIM    - Data Final
                          @IN_LTPSALDO   - Se '1' processa um tipo de saldo, se '0' todos os tipos de Saldos
                          @IN_TPSALDO    - Tipo de saldo q tera a moeda atualizada
                          @IN_MOEDAS     - Moedas que serao atualizadas
                          @IN_CONVERTE   - '1' Plano de Contas CT1, '2' Lancamentos -CT2  </ri>
                          @IN_MVSOMA     - Conteudo do parametro soma
   Saida           - <o>  @OUT_RESULT    - Indica o termino OK da procedure </ro>
   Responsavel :     <r>  Siga	</r>
   Data        :     06/10/2008
   Obs: 
   1 - Verificar se Moeda esta Bloqeada
   2 - Verificar se Calendario nao esta bloqueado
   3 - Atualizacao por Conta - CT1_CVD  -   
                  Lancamento - CT2_CRITER = '12345' -  1- Diario
                                                       2- Media
                                                       3- Mensal
                                                       4- Informado
                                                       5- Nao gera lancamento na moeda a converter
  aProc[3]- CTBA370A-> Chamador                               
  aProc[2]-        --> CTBA370B -> Retorna o valor convertido
  aProc[1]-        --> xfilial
   -------------------------------------------------------------------------------------- */


CREATE PROCEDURE CTBA370A_## (
   @IN_FILIAL   Char( 'CT2_FILIAL' ),
   @IN_FILATE   Char( 'CT2_FILIAL' ),
   @IN_DATAINI  Char( 08 ),
   @IN_DATAFIM  Char( 08 ),
   @IN_LTPSALDO Char( 01 ),
   @IN_TPSALDO   Char( 'CT2_TPSALD' ),
   @IN_MOEDAS   Varchar( 200 ),
   @IN_CONVERTE Char( 01 ),
   @IN_MVSOMA   Char( 01 ),
   @OUT_RESULT  Char( 01 ) OutPut
)
as
Declare @cAux        Char( 03 )
Declare @cFil_CT1    Char( 'CT2_FILIAL' )
Declare @cFil_CT2    Char( 'CT2_FILIAL' )
Declare @cFil_CTO    Char( 'CT2_FILIAL' )
Declare @lConverte   Char( 01 )
Declare @cData       Char( 08 )
Declare @cBloq       Char( 01 )
Declare @cCT2_FILIAL Char( 8 )
Declare @cCT2_DATA   Char( 08 )
Declare @cCT2_LOTE    Char( 'CT2_LOTE' )
Declare @cCT2_SBLOTE  Char( 'CT2_SBLOTE' )
Declare @cCT2_DOC     Char( 'CT2_DOC' )
Declare @cCT2_LINHA   Char( 'CT2_LINHA' )
Declare @cCT2_FILORI Char( 'CT2_FILIAL' )
Declare @cCT2_EMPORI  Char( 'CT2_EMPORI' )
Declare @cCT2_DC      Char( 'CT2_DC' )
Declare @cCT2_DEBITO  Char( 'CT2_DEBITO' )
Declare @cCT2_CREDIT  Char( 'CT2_CREDIT' )
Declare @cCT2_CCD     Char( 'CT2_CCD' )
Declare @cCT2_CCC     Char( 'CT2_CCC' )
Declare @cCT2_ITEMD   Char( 'CT2_ITEMD' )
Declare @cCT2_ITEMC   Char( 'CT2_ITEMC' )
Declare @cCT2_CLVLDB  Char( 'CT2_CLVLDB' )
Declare @cCT2_CLVLCR  Char( 'CT2_CLVLCR' )
Declare @cCT2_LP      Char( 'CT2_LP' )
Declare @cCT2_MOEDLC  Char( 'CT2_MOEDLC' )
Declare @cCT2_TPSALD  Char( 'CT2_TPSALD' )
Declare @cCT2_DTLP   Char( 08 )
Declare @cCT2_CRCONV Char( 01 )
Declare @cCT2_DATATX Char( 08 )
Declare @cCT2_ROTINA  Char( 'CT2_ROTINA' )
Declare @cCT2_MANUAL  Char( 'CT2_MANUAL' )
Declare @nCT2_VALOR  Float
Declare @cMoeda      Char( 'CT2_MOEDLC' )
Declare @cCriterio   Char( 'CT2_CRCONV' )
Declare @cCT2_DCD  Char( 'CT2_DCD' )
Declare @cCT2_DCC  Char( 'CT2_DCC' )
Declare @cCT2_SEQUEN  Char( 'CT2_SEQUEN' )
Declare @cCT2_ORIGEM  Char( 'CT2_ORIGEM' )
Declare @cCT2_AGLUT  Char( 'CT2_AGLUT' )
Declare @cCT2_HP Char( 'CT2_HP' )
Declare @cCT2_HIST  Char( 'CT2_HIST' )
Declare @cCT2_SEQLAN  Char( 'CT2_SEQLAN' )
Declare @cCT2_SEQHIS  Char( 'CT2_SEQHIS' )
Declare @cCT2_SLBASE Char( 'CT2_SLBASE' )
Declare @cCT2_KEY  Char( 'CT2_KEY' )
Declare @cCT2_DTCV3  Char( 008 )
Declare @nValor      Float
Declare @nValorConv  Float
Declare @nValorDif   Float
Declare @iX          Integer
Declare @iRecno      Integer
Declare @iRecnoCT1   Integer
Declare @iRecnoCT2   Integer

--NAO REMOVER
Declare @cTratar Char( 01 )
--TRATARDECLARE



/* Ordem de chamada das procedures - NAO EXCLUIR OS COMENTARIOS
	
	   1.  CTBA370A     - Pai - Chamador.................................... 
      1.1 CTBA370A    - Retorna o valor convertido........................ 
*/


BEGIN
   SELECT @OUT_RESULT = '0'
   SELECT @cAux = 'CT2'
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFil_CT2 output 
   SELECT @cCT2_ROTINA = 'CTBA370'
   SELECT @cCT2_MANUAL = '1'
   SELECT @cMoeda = ' '
   SELECT @cCriterio = ' '
   SELECT @cData = ' '

   --TRATARZERAMENTO

   Declare CUR_CTB370 insensitive cursor for
    SELECT CT2_FILIAL, CT2_DATA,   CT2_LOTE,   CT2_SBLOTE, CT2_DOC,  CT2_LINHA,  CT2_FILORI, CT2_EMPORI, CT2_DC,     CT2_DEBITO,
           CT2_CREDIT, CT2_CCD,    CT2_CCC,    CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_LP,     CT2_MOEDLC, CT2_TPSALD,
           CT2_DTLP,   CT2_CRCONV, CT2_DATATX, CT2_VALOR, 
           CT2_DCD, CT2_DCC, CT2_SEQUEN, CT2_ORIGEM, CT2_AGLUT, CT2_HP, CT2_HIST, CT2_SEQLAN, CT2_SEQHIS, CT2_SLBASE, CT2_KEY, CT2_DTCV3 
      From CT2###
     Where CT2_FILIAL between @cFil_CT2 and @IN_FILATE
       AND CT2_DATA Between @IN_DATAINI AND @IN_DATAFIM
       AND CT2_MOEDLC = '01'
       AND ( CT2_TPSALD = @IN_TPSALDO AND @IN_LTPSALDO  = '1' OR (@IN_TPSALDO    = '0'))
       AND CT2_DC     != '4'
       AND D_E_L_E_T_ = ' '
   for read only
   Open CUR_CTB370
   Fetch CUR_CTB370
    into @cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,   @cCT2_SBLOTE, @cCT2_DOC,   @cCT2_LINHA,  @cCT2_FILORI, @cCT2_EMPORI, @cCT2_DC,     @cCT2_DEBITO,
         @cCT2_CREDIT, @cCT2_CCD,    @cCT2_CCC,    @cCT2_ITEMD,  @cCT2_ITEMC, @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_LP,     @cCT2_MOEDLC, @cCT2_TPSALD,
         @cCT2_DTLP,   @cCT2_CRCONV, @cCT2_DATATX, @nCT2_VALOR, 
         @cCT2_DCD, @cCT2_DCC, @cCT2_SEQUEN, @cCT2_ORIGEM, @cCT2_AGLUT, @cCT2_HP, @cCT2_HIST, @cCT2_SEQLAN, @cCT2_SEQHIS, @cCT2_SLBASE, @cCT2_KEY, @cCT2_DTCV3 
   While ( @@fetch_status = 0 ) 
   BEGIN
      SELECT @cAux = 'CT1'
      EXEC XFILIAL_## @cAux, @cCT2_FILIAL, @cFil_CT1 OutPut
      SELECT @cAux = 'CTO'
      EXEC XFILIAL_## @cAux, @cCT2_FILIAL, @cFil_CTO OutPut
      SELECT @iX = 1
      While @iX < Len( @IN_MOEDAS ) 
      BEGIN
         SELECT @lConverte  = '1'
         SELECT @iRecno     = 0
         SELECT @iRecnoCT1  = 0
         SELECT @iRecnoCT2  = 0
         SELECT @nValorConv = 0
         SELECT @nValorDif  = 0
         SELECT @nValor     = 0
         SELECT @cData      = @cCT2_DATA
         SELECT @cMoeda     = Substring( @IN_MOEDAS, @iX, 2 )
         SELECT @cBloq = CTO_BLOQ
           From CTO###
          Where CTO_FILIAL = @cFil_CTO
            AND CTO_MOEDA  = @cMoeda
            AND D_E_L_E_T_ = ' '
         IF @cBloq = '1' 
         BEGIN
            SELECT @lConverte = '0'
         END
         IF @lConverte = '1' 
         BEGIN
            SELECT @iRecnoCT2 = IsNull(R_E_C_N_O_, 0), @cCT2_DATATX = CT2_DATATX, @cCriterio = CT2_CRCONV, @nValor = CT2_VALOR
              From CT2###
             Where CT2_FILIAL = @cCT2_FILIAL
               and CT2_DATA   = @cCT2_DATA
               and CT2_LOTE   = @cCT2_LOTE
               and CT2_SBLOTE = @cCT2_SBLOTE
               and CT2_DOC    = @cCT2_DOC
               and CT2_LINHA  = @cCT2_LINHA
               and CT2_TPSALD = @cCT2_TPSALD
               and CT2_EMPORI = @cCT2_EMPORI
               and CT2_FILORI = @cCT2_FILORI
               and CT2_MOEDLC = @cMoeda
               and D_E_L_E_T_ = ' '
            IF @IN_CONVERTE  = '2' 
            BEGIN 
               IF @iRecnoCT2  = 0 
               BEGIN 
                  SELECT @lConverte  = '0' 
               END 
            END 
            ELSE 
            BEGIN 
               IF @iRecnoCT2  = 0 
               BEGIN 
                  SELECT @nValorConv  = @nCT2_VALOR 
               END 
            END 
         END
         IF @lConverte = '1' 
         BEGIN
            IF @IN_CONVERTE  = '2' 
            BEGIN
               IF @cCriterio  = ' ' 
               BEGIN 
                  SELECT @cCriterio  = '1' 
               END
               IF @cCriterio = '4' 
               BEGIN
                  SELECT @nValorConv = @nValor
               END
               ELSE
               BEGIN
                  IF @cCriterio  = '9' 
                  BEGIN 
                     SELECT @cData  = @cCT2_DATATX 
                  END 
                  EXEC CTBA370B_## @cCT2_FILIAL, @cData, @nCT2_VALOR, @cMoeda, @cCriterio, @nValorConv OutPut
               END
            END
            ELSE 
            BEGIN
               IF @cCT2_DC IN ( '1',  '3') 
               BEGIN
                  SELECT @iRecnoCT1 = IsNull(R_E_C_N_O_, 0)
                  --TRATAMENTO DE MOEDAS SELECT 
                  
                  From CT1###
                   Where CT1_FILIAL = @cFil_CT1
                     and CT1_CONTA  = @cCT2_DEBITO
                     and D_E_L_E_T_ = ' '
                  
                  --TRATAMENTO DO CRITERIO DE ACORDO COM MOEDAS NAO REMOVER
                  SELECT @cMoeda = 'TR'
               END
               IF @cCT2_DC = '2' 
               BEGIN
                  SELECT @iRecnoCT1 = IsNull(R_E_C_N_O_, 0)
                  --TRATAMENTO DE MOEDAS SELECT 
                   From CT1###
                   Where CT1_FILIAL = @cFil_CT1
                     and CT1_CONTA  = @cCT2_CREDIT
                     and D_E_L_E_T_ = ' '
                  
                  --TRATAMENTO DO CRITERIO DE ACORDO COM MOEDAS NAO REMOVER
                  SELECT @cMoeda = 'TR'
               END
               IF @cCriterio = '4' 
               BEGIN
                  SELECT @nValorConv = @nValor
               END
               ELSE
               BEGIN
                  IF @cCriterio = '9' 
                  BEGIN
                     SELECT @cData = @cCT2_DATATX
                  END
                  Exec CTBA370B_## @cCT2_FILIAL, @cData, @nCT2_VALOR, @cMoeda, @cCriterio, @nValorConv OutPut
               END
            END
            IF ( @iRecnoCT2 = 0 and Round(@nValorConv, 2) != 0.00 )  
            BEGIN
                  SELECT @nValorConv = Round( @nValorConv, 2)
                  SELECT @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CT2###
                  SELECT @iRecno = @iRecno + 1
                  ##TRATARECNO @iRecno\
                     BEGIN tran
                        INSERT INTO CT2### ( CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_FILORI, CT2_EMPORI, CT2_DC, CT2_DEBITO, CT2_DCD, CT2_CREDIT, CT2_DCC,                      CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_LP, CT2_SEQUEN, CT2_ROTINA, CT2_ORIGEM, CT2_AGLUT, CT2_MOEDLC,                      CT2_TPSALD, CT2_HP, CT2_HIST, CT2_SEQLAN, CT2_SEQHIS, CT2_MANUAL, CT2_DTLP, CT2_SLBASE, CT2_KEY, CT2_DTCV3, CT2_VALOR, CT2_CRCONV,       	              R_E_C_N_O_ )                   values(	                      @cCT2_FILIAL, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_LINHA, @cCT2_FILORI, @cCT2_EMPORI, @cCT2_DC, @cCT2_DEBITO, @cCT2_DCD, @cCT2_CREDIT, @cCT2_DCC, 
                           @cCT2_CCD, @cCT2_CCC, @cCT2_ITEMD, @cCT2_ITEMC, @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_LP, @cCT2_SEQUEN, @cCT2_ROTINA, @cCT2_ORIGEM, @cCT2_AGLUT, @cMoeda,                       @cCT2_TPSALD, @cCT2_HP, @cCT2_HIST, @cCT2_SEQLAN, @cCT2_SEQHIS, @cCT2_MANUAL, @cCT2_DTLP, @cCT2_SLBASE, @cCT2_KEY, @cCT2_DTCV3, @nValorConv, @cCT2_CRCONV, 
                           @iRecno )
                     commit tran
                  ##FIMTRATARECNO
            END
            ELSE 
            BEGIN
               IF ( Round(@nValorConv, 2) != 0.00 ) and (Round(@nValorConv, 2) != Round(@nValor, 2) ) 
               BEGIN
                  SELECT @nValorConv = Round( @nValorConv, 2)
                  SELECT @nValorDif  = round( (@nValorConv - @nValor), 2)
                  BEGIN tran
                     Update CT2###
                     Set CT2_VALOR  = @nValorConv
                     Where R_E_C_N_O_ = @iRecnoCT2
                  commit tran
               END 
               ELSE 
               BEGIN
                  IF ( Round(@nValorConv, 2) = 0.00 ) And ( @cCriterio = '5'  ) 
                  BEGIN
                     BEGIN tran
                        Update CT2###
                        Set D_E_L_E_T_  = '*' , R_E_C_D_E_L_ = @iRecnoCT2 
                        Where R_E_C_N_O_ = @iRecnoCT2
                     commit tran
                  END
               END
            END
         END
         SELECT @iX = @iX + 2
      END
      Fetch CUR_CTB370
       into @cCT2_FILIAL, @cCT2_DATA,   @cCT2_LOTE,   @cCT2_SBLOTE, @cCT2_DOC,   @cCT2_LINHA,  @cCT2_FILORI, @cCT2_EMPORI, @cCT2_DC,     @cCT2_DEBITO,
            @cCT2_CREDIT, @cCT2_CCD,    @cCT2_CCC,    @cCT2_ITEMD,  @cCT2_ITEMC, @cCT2_CLVLDB, @cCT2_CLVLCR, @cCT2_LP,     @cCT2_MOEDLC, @cCT2_TPSALD,
            @cCT2_DTLP,   @cCT2_CRCONV, @cCT2_DATATX, @nCT2_VALOR, 
            @cCT2_DCD, @cCT2_DCC, @cCT2_SEQUEN, @cCT2_ORIGEM, @cCT2_AGLUT, @cCT2_HP, @cCT2_HIST, @cCT2_SEQLAN, @cCT2_SEQHIS, @cCT2_SLBASE, @cCT2_KEY, @cCT2_DTCV3 
   END
   close CUR_CTB370
   deallocate CUR_CTB370
   SELECT @OUT_RESULT = '1'
END

