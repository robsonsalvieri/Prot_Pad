Create procedure CTB020_##
( 
   @IN_LCUSTO       Char(01),
   @IN_LITEM        Char(01),
   @IN_LCLVL        Char(01),
   @IN_FILIALDE     Char('CT2_FILIAL'),
   @IN_FILIALATE    Char('CT2_FILIAL'),
   @IN_DATADE       Char(08),
   @IN_DATAATE      Char(08),
   @IN_LMOEDAESP    Char(01),
   @IN_MOEDA        Char('CT7_MOEDA'),
   @IN_TPSALDO      Char('CT2_TPSALD'),
   @IN_MVSOMA       Char(01),
   @IN_REPROC       Char(01),
   @IN_INTEGRIDADE  Char(01),
   @IN_MVCTB190D    Char(01),
   @IN_EMPANT       Char(02),
   @IN_FILANT       Char('CT2_FILIAL'), 
   @IN_TRANSACTION  Char(01), 
   @IN_LCONTA       Char(01),
   @IN_UUID         Char(36),
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------

    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  013 </a>
    Fonte Microsiga - <s>  CTBA190.PRW </s>
    Descricao       - <d>  Reprocessamento Contábil </d>
    Funcao do Siga  -      CTB190Proc()
    Entrada         - <ri> @IN_LCUSTO       - Centro de Custo em uso
                           @IN_LITEM        - Item em uso
                           @IN_LCLVL        - Classe de Valor em uso
                           @IN_FILIALDE     - Filial inicio do processamento
                           @IN_FILIALATE    - Filial final do processamento
                           @IN_DATADE       - Data Inicial
                           @IN_DATAATE      - Data Final
                           @IN_LMOEDAESP    - Moeda Especifica - '1', todas, exceto orca/o - '0'
                           @IN_MOEDA        - Moeda escolhida  - se '0', todas exceto orcamento
                           @IN_TPSALDO      - Tipos de Saldo a Repropcessar - ('1','2',..)
                           @IN_MVSOMA       - Soma 2 vezes
                           @IN_REPROC       - Se Reproc -> '1'
                           @IN_INTEGRIDADE  - '1' se a integridade estiver ligada, '0' se nao estiver ligada.
                           @IN_MVCTB190D    - '1' exclui fisicamente, '0' marca como deletado
                           @IN_LCONTA       - '1' Reprocessamento de saldos por contaChar(01),
                           @IN_UUID         - Código UUID para ser pesquisado na tabela QLJ
                           @IN_TRANSACTION  - '1' chamada dentro de transação - '0' fora de transação</ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alice	</r>
    Data        :     03/11/2003
    
    CTB020 - Reprecessamento Contábil
      IF @IN_LCONTA = '1' +--> Reprocessamento de saldos por conta
         +--> CTB220D - Atualiza os saldos DIÁRIOS do cubo - MV_CTBCUBE = '1'
               +--> CTB209D - Exclui os saldos DIÁRIOS do cubo (CVX e CVY)                
               +--> CTB208D - Refaz os saldos DIÁRIOS do cubo (CVX e CVY)                
         +--> CTB220M - Atualiza os saldos MENSAIS do cubo - MV_CTBCUBE = '1'
               +--> CTB209D - Exclui os saldos MENSAIS do cubo (CVX e CVY)                
               +--> CTB208D - Refaz os saldos MENSAIS do cubo (CVX e CVY)   
         +--> CTB002B - Zera Saldos CQ's e CTC
         +--> CTB021B - Refaz Saldos CQ's         
      Else +--> Reprocessamento de saldos legado
         +--> CTB002 - Zera Saldos
         +--> CTB021 - Ct190SlBse  - Atualizar Saldos base - CQ0, CQ1, CQ2, CQ3
                  +--> CTB230  - Atualizar Saldos base - - CQ4, CQ5, CQ6, CQ7
                  +--> CTB232  - Atualizar Saldos base - CQ8, CQ9
         |        +--> CTB025  - Ct190FlgLP - Atualiza slds referentes a Apur de LP
         +--> CTB023 - Ct190Doc()  - Totais por Doc
            EXCLUIDO     +--> CTB024 - CtbFlgPon() - Atualiza os Flags de Conta Ponte. Não atualiza valores, somete grava Flags
            EXCLUIDO      |        |                  das AP LP com conta Ponte (CTZ - Lançamentos apurados com conta ponte  )
         |        +--> CTB025  - Ct190FlgLP() - Atualiza os flags dos saldos ref. lucros/perdas
         +-------------------------------------------------------------------------------
         | Localización COL/PER
         +--> CTB002A - Zera Saldos - QL6, QL7
         +--> CTB021A - Ct190SlBse  - Atualizar Saldos base - QL6, QL7
         |     +--> CTB025A  - Ct190FlgLP - Atualiza slds referentes a Apur de LP - QL7
         |     +--> CTB232A  - Atualizar Saldos base - CQ8, CQ9
         +-------------------------------------------------------------------------------
         +--> CTB220 - - Atualiza os CUBBOS
         |        +--> CTB209 - Apaga os dados do CVXe CVY no periodo solicitado
         |        +--> LASTDAY - Retorna o ultimo dia do mes
         |        +--> CTB211 - Chama Gravacao dos Cubos
         |                 +--> CTB210 - Chamada das Atualizacao de Cubos
         |                          +--> CTB200 - Atualizar Cubo01 - CONTA
         |                          +--> CTB201 - Atualizar Cubo02 - CCUSTO
         |                          +--> CTB202 - Atualizar Cubo03 - ITEM
         |                          +--> CTB203 - Atualizar Cubo04 - CLVL
         |                          +--> CTB204 - Atualizar Cubo05 - NIV05
         |                          +--> CTB205 - Atualizar Cubo06 - NIV06
         |                          +--> CTB206 - Atualizar Cubo07 - NIV07
         |                          +--> CTB207 - Atualizar Cubo08 - NIV08
         |                          +--> CTB208 - Atualizar Cubo09 - NIV09
         -------------------------------------------------------------------------------------- */
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cAux2       char(01)
declare @cAux        char(03)
declare @dDataIni    char(08)
declare @dDataFim    char(08)
declare @cAlias      char(03)
declare @lExistQLJ   char(01)

##IF_001({|| AliasInDic('QLJ')})
   declare @cFilial_QLJ char('QLJ_FILIAL')
   declare @cConta      Char('QLJ_CONTA')
   declare @cCusto      Char('QLJ_CUSTO')
   declare @cItem       Char('QLJ_ITEM')
   declare @cClasse     Char('QLJ_CLVL')
   declare @cEnt05      Char('QLJ_ENT05')
   declare @cEnt06      Char('QLJ_ENT06')
   declare @cEnt07      Char('QLJ_ENT07')
   declare @cEnt08      Char('QLJ_ENT08')
   declare @cEnt09      Char('QLJ_ENT09')
   declare @cTabOri     char("QLJ_TABORI")
##ENDIF_001

declare @dDataProc   char(08)
declare @dDataMes    char(06)
declare @FilProc     char('CT2_FILIAL')
declare @nRecQLJ     Integer
declare @cMoeda      char(02)
declare @cTpSald     char(01)

begin
   select @lExistQLJ = 1
   /*-----------------------------
      Spike - Só faz por conta se for BRA
   -------------------------------*/
   ##IF_001({|| !AliasInDic('QLJ') .Or. cPaisLoc <> 'BRA'})
      select @lExistQLJ = 0
   ##ENDIF_001

   select @OUT_RESULTADO = '0'
   select @cAux2 = '0'

   select @cAux = 'CT2'   
   exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_CT2 OutPut

   /*----------------------------------------------      
      Spike - Reprocessamento por conta
      Para efeito de estudo foi feito somente na
      CQ0, CQ1 e CTC
   -----------------------------------------------*/
   if (@IN_LCONTA = '1' and @lExistQLJ = '1') begin

      ##IF_003({|| AliasInDic('QLJ')})
         select @cAux = 'QLJ'   
         exec XFILIAL_## @cAux, @IN_FILIALDE, @cFilial_QLJ OutPut
         
         ##IF_002({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) }) 
            /* #### Deleta saldos diários do CUBO #### */
            Declare CUR_TMP1 insensitive cursor for
            Select QLJ_FILORI, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, 
                  QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, 
                  QLJ_DATA, QLJ_MOEDA, QLJ_TPSALD
               from QLJ### 
               where QLJ_FILIAL = @cFilial_QLJ AND QLJ_UUID = @IN_UUID AND D_E_L_E_T_ = ' '    
            Order by 1, 2, 3, 4, 5, 6
            for read only
            Open CUR_TMP1
            Fetch CUR_TMP1 into @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataProc, @cMoeda, @cTpSald

            While (@@Fetch_status = 0 ) begin                           
               select @OUT_RESULTADO = '0'
               EXEC CTB220D_## @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataProc, @cMoeda, @cTpSald, '0', @IN_TRANSACTION, @OUT_RESULTADO OutPut            
               
               SELECT @fim_CUR = 0
               Fetch CUR_TMP1 into @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataProc, @cMoeda, @cTpSald
            end
            close CUR_TMP1
            deallocate CUR_TMP1
         ##ENDIF_002

         ##IF_002({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) }) 
            /* #### Deleta saldos mensais #### */
            Declare CUR_TMP2 insensitive cursor for
            select QLJ_FILORI, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, 
               QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, SUBSTRING(QLJ_DATA,1,6), 
               QLJ_MOEDA, QLJ_TPSALD         
            from QLJ### 
            where QLJ_FILIAL = @cFilial_QLJ AND QLJ_UUID = @IN_UUID AND D_E_L_E_T_ = ' ' 
            GROUP BY QLJ_FILORI, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, 
                  QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, SUBSTRING(QLJ_DATA,1,6),
                  QLJ_MOEDA, QLJ_TPSALD
            Order by 1, 2, 3, 4, 5, 6
            for read only
            Open CUR_TMP2
            Fetch CUR_TMP2 into @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataMes, @cMoeda, @cTpSald

            While (@@Fetch_status = 0 ) begin                           
               select @OUT_RESULTADO = '0'
               EXEC CTB220M_## @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataMes, @cMoeda, @cTpSald, '0', @IN_TRANSACTION, @OUT_RESULTADO OutPut                        
               
               SELECT @fim_CUR = 0
               Fetch CUR_TMP2 into @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataMes, @cMoeda, @cTpSald
            end
            close CUR_TMP2
            deallocate CUR_TMP2
         ##ENDIF_002

         /* #### Atualiza saldos Diáros #### */
         Declare CUR_TMP3 insensitive cursor for
         Select QLJ_FILORI, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, 
               QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, 
               QLJ_DATA, QLJ_MOEDA, QLJ_TPSALD, QLJ_TABORI, R_E_C_N_O_
            from QLJ### 
            where QLJ_FILIAL = @cFilial_QLJ AND QLJ_UUID = @IN_UUID AND D_E_L_E_T_ = ' '    
         Order by 1, 2, 3, 4, 5, 6
         for read only
         Open CUR_TMP3
         Fetch CUR_TMP3 into @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataProc, @cMoeda, @cTpSald, @cTabOri, @nRecQLJ

         While (@@Fetch_status = 0 ) begin
            select @dDataIni = @dDataProc
            select @dDataFim = @dDataProc
                           
            if ( @cTabOri = 'CQ1' ) begin            
               select @cAlias    = 'CQ1'
               select @OUT_RESULTADO = '0'
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
                           
               select @cAlias    = 'CQ0'
               select @OUT_RESULTADO = '0'
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output             
               
               select @OUT_RESULTADO = '0'
               EXEC CTB021B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @IN_EMPANT, @IN_FILANT, @IN_TRANSACTION, @OUT_RESULTADO Output            
            end

            if ( @cTabOri = 'CQ3' ) begin            
               /* Zera CQ8 e CQ9 */
               select @cAlias    = 'CTT'
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output             

               select @cAlias    = 'CQ3'
               select @OUT_RESULTADO = '0'
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
               
               select @cAlias    = 'CQ2'
               select @OUT_RESULTADO = '0'
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
               
               select @OUT_RESULTADO = '0'
               EXEC CTB021B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @IN_EMPANT, @IN_FILANT, @IN_TRANSACTION, @OUT_RESULTADO Output            
            end
            
            if ( @cTabOri = 'CQ5' ) begin
               /* Zera CQ8 e CQ9 */
               select @cAlias    = 'CTD'
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output             
               
               select @cAlias    = 'CQ5'
               select @OUT_RESULTADO = '0'
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
               
               select @cAlias    = 'CQ4'
               select @OUT_RESULTADO = '0'
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
               
               select @OUT_RESULTADO = '0'
               EXEC CTB021B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @IN_EMPANT, @IN_FILANT, @IN_TRANSACTION, @OUT_RESULTADO Output            
            end

            if ( @cTabOri = 'CQ7' ) begin
               /* Zera CQ8 e CQ9 */
               select @cAlias    = 'CTH'
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output             
               
               select @cAlias    = 'CQ7'
               select @OUT_RESULTADO = '0'
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output             
               
               select @cAlias    = 'CQ6'  
               select @OUT_RESULTADO = '0'          
               EXEC CTB002B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output             
               
               select @OUT_RESULTADO = '0'
               EXEC CTB021B_## @cAlias, @FilProc, @cConta, @cCusto, @cItem, @cClasse, @dDataProc, @IN_LMOEDAESP, @IN_MOEDA, @cTpSald, @IN_EMPANT, @IN_FILANT, @IN_TRANSACTION, @OUT_RESULTADO Output                        
            end            

            ##IF_002({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) })

               select @cAlias    = 'CVX'
               select @OUT_RESULTADO = '0'
               EXEC CTB220D_## @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataProc, @cMoeda, @cTpSald, '1', @IN_TRANSACTION, @OUT_RESULTADO OutPut
            
            ##ENDIF_002
            
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
               UPDATE QLJ### SET QLJ_STATUS = '1' WHERE R_E_C_N_O_ = @nRecQLJ
            ##CHECK_TRANSACTION_COMMIT

            SELECT @fim_CUR = 0
            Fetch CUR_TMP3 into @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataProc, @cMoeda, @cTpSald, @cTabOri, @nRecQLJ
         end
         close CUR_TMP3
         deallocate CUR_TMP3

         ##IF_002({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) })
            /* #### Atualiza saldos Mensais #### */
            Declare CUR_TMP4 insensitive cursor for
            select QLJ_FILORI, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, 
               QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, SUBSTRING(QLJ_DATA,1,6), 
               QLJ_MOEDA, QLJ_TPSALD         
            from QLJ### 
            where QLJ_FILIAL = @cFilial_QLJ AND QLJ_UUID = @IN_UUID AND D_E_L_E_T_ = ' ' 
            GROUP BY QLJ_FILORI, QLJ_CONTA, QLJ_CUSTO, QLJ_ITEM, QLJ_CLVL, 
                  QLJ_ENT05, QLJ_ENT06, QLJ_ENT07, QLJ_ENT08, QLJ_ENT09, SUBSTRING(QLJ_DATA,1,6),
                  QLJ_MOEDA, QLJ_TPSALD
            Order by 1, 2, 3, 4, 5, 6
            for read only
            Open CUR_TMP4
            Fetch CUR_TMP4 into @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataMes, @cMoeda, @cTpSald

            While (@@Fetch_status = 0 ) begin
            
               select @OUT_RESULTADO = '0'
               EXEC CTB220M_## @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataMes, @cMoeda, @cTpSald, '1', @IN_TRANSACTION, @OUT_RESULTADO OutPut         

               SELECT @fim_CUR = 0
               Fetch CUR_TMP4 into @FilProc, @cConta, @cCusto, @cItem, @cClasse, @cEnt05, @cEnt06, @cEnt07, @cEnt08, @cEnt09, @dDataMes, @cMoeda, @cTpSald
            end
            close CUR_TMP4
            deallocate CUR_TMP4
         ##ENDIF_002
          
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            DELETE FROM QLJ### WHERE QLJ_FILIAL = @cFilial_QLJ AND QLJ_UUID = @IN_UUID AND QLJ_STATUS = '1' AND D_E_L_E_T_ = ' '
         ##CHECK_TRANSACTION_COMMIT

         select @OUT_RESULTADO = '1' 

      ##ELSE_003

         select @OUT_RESULTADO = '0'   

      ##ENDIF_003
   end 
   else begin
      Select @dDataIni = Isnull( Min( CT2_DATA ), '0' ), @dDataFim = Isnull( Max( CT2_DATA ), '1' )
      from CT2###
      where CT2_FILIAL between @cFilial_CT2 and @IN_FILIALATE
         and D_E_L_E_T_ = ' '
      if ( ( @dDataIni = '0' ) and ( @dDataFim = '1' ) ) begin
         /* ------------------------------------------------------------
            Nao tem dados a reprocessar
            ------------------------------------------------------------*/
         select @OUT_RESULTADO = '1'
      end
      else begin
         select @dDataIni = @IN_DATADE
         select @dDataFim = @IN_DATAATE
         /* -------------------------------------------------------------------------
            Zera/Exclui Saldos de Contas - CQ0 Mês / CQ1 Dia
            -------------------------------------------------------------------------*/    
         select @cAlias    = 'CQ0'
         select @cAux2     = '0'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
         select @cAlias    = 'CQ1'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
         
               
         /* -------------------------------------------------------------------------
            Zera/Exclui Saldos de CCustos - CQ2 Mês / CQ3 Dia
            -------------------------------------------------------------------------*/    
         if @IN_LCUSTO = '1' begin
            select @OUT_RESULTADO = '0'
            select @cAlias    = 'CQ2'
            select @cAux2     = '0'
            EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
            select @cAlias    = 'CQ3'
            EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
         end
         /* -------------------------------------------------------------------------
            Zera/Exclui Saldos de Item - CQ4 Mês / CQ5 Dia
            -------------------------------------------------------------------------*/    
         if @IN_LITEM  = '1' begin
            select @OUT_RESULTADO = '0'
            select @cAlias    = 'CQ4'
            select @cAux2     = '0'
            EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
            select @cAlias    = 'CQ5'
            EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
         end
         /* -------------------------------------------------------------------------
            Zera/Exclui Saldos de Classe de Valor - CQ6 Mês / CQ7 Dia
            -------------------------------------------------------------------------*/    
         if @IN_LCLVL  = '1' begin
            select @OUT_RESULTADO = '0'
            select @cAlias    = 'CQ6'
            select @cAux2     = '0'
            EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
            select @cAlias    = 'CQ7'
            EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output       
         end
         /* -------------------------------------------------------------------------
            Zera/Exclui Saldos por entidade - CQ8 Mês / CQ9 Dia
            -------------------------------------------------------------------------*/    
         if @IN_LCUSTO  = '1' or  @IN_LITEM  = '1' or @IN_LCLVL  = '1' begin
            select @OUT_RESULTADO = '0'
            select @cAlias    = 'CQ8'
            select @cAux2     = '0'
            EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
            select @cAlias    = 'CQ9'
            EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output       
         end
         /* -------------------------------------------------------------------------
            Zera/Exclui Saldos de Contas - CTC - Documento
            -------------------------------------------------------------------------*/
         select @OUT_RESULTADO = '0'
         select @cAlias    = 'CTC'
         select @cAux2     = '0'
         EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output 
         /* -----------------------------------------------------------------------------------
            CTB021 - Ct190SlBse - Atualizar Saldos base - CQ0/CQ1 - CQ2/CQ3 - CQ4/CQ5 - CQ6/CQ7
            ----------------------------------------------------------------------------------- */
         select @OUT_RESULTADO = '0'
         EXEC CTB021_## @IN_FILIALDE,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_FILIALATE,  @dDataIni, @dDataFim,  @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @IN_TRANSACTION, @OUT_RESULTADO Output
         /* -------------------------------------------------------------------------
            Ct190Doc() - Totais por Doc
            -------------------------------------------------------------------------*/
         select @OUT_RESULTADO = '0'
         EXEC CTB023_## @IN_FILIALDE,  @IN_FILIALATE, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_MVSOMA, @IN_TRANSACTION, @OUT_RESULTADO OutPut

         /* -------------------------------------------------------------------------
            Países Colombia y Perú
            -------------------------------------------------------------------------*/
         ##IF_002({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo('CT0',,'05') })
         ##FIELDP02( 'QL6.QL6_FILIAL' )
            /* -------------------------------------------------------------------------
               Zera/Exclui Saldos de Entidad 05 - QL6 Mês / QL7 Dia
               -------------------------------------------------------------------------*/
            select @OUT_RESULTADO = '0'
            select @cAlias    = 'QL6'
            select @cAux2     = '0'
            EXEC CTB002A_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output
            select @cAlias    = 'QL7'
            EXEC CTB002A_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output
            /* -------------------------------------------------------------------------
               Zera/Exclui Saldos por entidade - CQ8 Mês / CQ9 Dia. Si maneja otras entidades, ya borró saldos, no repetir operación
               -------------------------------------------------------------------------*/
            if @IN_LCUSTO  = '0' and  @IN_LITEM  = '0' and @IN_LCLVL  = '0' begin
               select @OUT_RESULTADO = '0'
               select @cAlias    = 'CQ8'
               select @cAux2     = '0'
               EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output
               select @cAlias    = 'CQ9'
               EXEC CTB002_## @cAlias, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_FILIALDE, @IN_FILIALATE, @dDataIni, @dDataFim, @cAux2, @IN_INTEGRIDADE, @IN_MVCTB190D, @IN_TRANSACTION, @OUT_RESULTADO Output
            end
            /* -----------------------------------------------------------------------------------
               CTB021A - Ct190SlBse - Atualizar Saldos base - QL6/QL7
               ----------------------------------------------------------------------------------- */
            select @OUT_RESULTADO = '0'
            EXEC CTB021A_## @IN_FILIALDE,  @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_FILIALATE, @dDataIni, @dDataFim, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_EMPANT, @IN_FILANT, @IN_TRANSACTION, @OUT_RESULTADO Output
         ##ENDFIELDP02
         ##ENDIF_002
         /* -------------------------------------------------------------------------
            ATUALIZA CUBOS
            -------------------------------------------------------------------------*/
         ##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
         ##FIELDP01( 'CT0.CT0_ID' )         
         Exec CTB220_## @IN_FILIALDE, @IN_FILIALATE, @IN_DATADE, @IN_DATAATE, @IN_LMOEDAESP, @IN_MOEDA, @IN_TPSALDO, @IN_TRANSACTION, @OUT_RESULTADO OutPut         
         ##ENDFIELDP01
         ##ENDIF_001
      end
      /*---------------------------------------------------------------
      Se a execucao foi OK retorna '1'
      --------------------------------------------------------------- */
      select @OUT_RESULTADO = '1'
   end
end
