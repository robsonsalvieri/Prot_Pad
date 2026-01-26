##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) .And. AliasInDic('QLJ')})
##FIELDP01( 'CT0.CT0_ID' )
Create procedure CTB220D_##
( 
   @IN_FILIAL       Char('CT2_FILIAL'),
   @IN_CONTA        Char('QLJ_CONTA'),
   @IN_CUSTO        Char('QLJ_CUSTO'),
   @IN_ITEM         Char('QLJ_ITEM'),
   @IN_CLVL         Char('QLJ_CLVL'),
   @IN_ENT05        Char('QLJ_ENT05'),
   @IN_ENT06        Char('QLJ_ENT06'),
   @IN_ENT07        Char('QLJ_ENT07'),
   @IN_ENT08        Char('QLJ_ENT08'),
   @IN_ENT09        Char('QLJ_ENT09'),
   @IN_DATA         Char('QLJ_DATA'),
   @IN_MOEDA        Char('QLJ_MOEDA'),
   @IN_TPSALDO      Char('QLJ_TPSALD'),
   @IN_TIPO         Char(01),
   @IN_TRANSACTION  Char(01),
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Gerencia o reprocessamento de saldos Diários do cubo (CVX e CVY)
    Fonte Microsiga - <s> CTBA190.PRW </s>
    Entrada         - <ri> @IN_FILIAL      - Filial de reprocessamento
                           @IN_CONTA       - Conta contábil
                           @IN_CUSTO       - Centro de Custo
                           @IN_ITEM        - Item contábil
                           @IN_CLVL        - Classe de Valor
                           @IN_ENT05       - Entidade 05
                           @IN_ENT06       - Entidade 06
                           @IN_ENT07       - Entidade 07
                           @IN_ENT08       - Entidade 08
                           @IN_ENT09       - Entidade 09
                           @IN_DATA        - Data para reprocessamento
                           @IN_MOEDA       - Moeda 
                           @IN_TPSALDO     - Tipo de Saldo
                           @IN_TIPO        - Tipo - '0' Exclusão - '1' inclusão
                           @IN_TRANSACTION - '1' Se foi chamado dentro de transação </ri>
    Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        :     08/11/2023
-------------------------------------------------------------------------------------- */
declare @cFilial_CT2 char('CT2_FILIAL')
declare @cFilial_CT0 char('CT0_FILIAL')
declare @cFilial_CVX char('CVX_FILIAL')
declare @cFILCT2     char('CT2_FILIAL')
declare @cDATA       Char(08)
declare @cDataMes    Char(08)
declare @cMOEDA      Char('QLJ_MOEDA')
declare @cCONTA      Char('QLJ_CONTA')
declare @cCUSTO      Char('QLJ_CUSTO')
declare @cITEM       Char('QLJ_ITEM')
declare @cCLVL       Char('QLJ_CLVL')
declare @cEC05       Char('QLJ_ENT05')
declare @cEC06       Char('QLJ_ENT06')
declare @cEC07       Char('QLJ_ENT07')
declare @cEC08       Char('QLJ_ENT08')
declare @cEC09       Char('QLJ_ENT09')
declare @cCustoAux   Char('QLJ_CUSTO')
declare @cItemAux    Char('QLJ_ITEM')
declare @cClvlAux    Char('QLJ_CLVL')
declare @cEC05Aux    Char('QLJ_ENT05')
declare @cEC06Aux    Char('QLJ_ENT06')
declare @cEC07Aux    Char('QLJ_ENT07')
declare @cEC08Aux    Char('QLJ_ENT08')
declare @cEC09Aux    Char('QLJ_ENT09')
declare @cTipo       Char(01)
declare @nVALOR      Float
declare @nValDeb     Float
declare @nValCrd     Float
Declare @lCubo01     Char(01)
Declare @lCubo02     Char(01)
Declare @lCubo03     Char(01)
Declare @lCubo04     Char(01)
Declare @lCubo05     Char(01)
Declare @lCubo06     Char(01)
Declare @lCubo07     Char(01)
Declare @lCubo08     Char(01)
Declare @lCubo09     Char(01)
Declare @cConfig     Char('CT0_ID')
Declare @fim_CUR     integer

begin
   
   select @OUT_RESULTADO = '0'

   Exec LASTDAY_## @IN_DATA, @cDataMes OutPut

   exec XFILIAL_## 'CT2', @IN_FILIAL, @cFilial_CT2 OutPut
   exec XFILIAL_## 'CT0', @IN_FILIAL, @cFilial_CT0 OutPut
   exec XFILIAL_## 'CVX', @IN_FILIAL, @cFilial_CVX OutPut

   /*Primeiro apago os valores da CVX com a CTB209D */
   if @IN_TIPO = '0' begin
      select @cConfig = '01'
      select @lCubo01 = CT0_CONTR
         From CT0###
         where CT0_FILIAL = @cFilial_CT0
         and CT0_ID     = @cConfig
         and D_E_L_E_T_ = ' '
      
      If @lCubo01 = '1' begin 
         select @cCustoAux = ' '
         select @cItemAux = ' '
         select @cClvlAux = ' '
         select @cEC05Aux = ' '
         select @cEC06Aux = ' '
         select @cEC07Aux = ' '
         select @cEC08Aux = ' '
         select @cEC09Aux = ' '
         Exec CTB209D_## @cFilial_CVX, @IN_DATA, @IN_MOEDA, @IN_TPSALDO, @IN_CONTA, @cCustoAux, @cItemAux, @cClvlAux,
                           @cEC05Aux, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output          
      End
      
      /* ---------------------------------------------------------------
         Atualiza Cubo 2 - ccusto
         --------------------------------------------------------------- */
      
      select @cConfig = '02'
      select @lCubo02 = CT0_CONTR
         From CT0###
         where CT0_FILIAL = @cFilial_CT0
         and CT0_ID     = @cConfig
         and D_E_L_E_T_ = ' '
      
      If @lCubo02 = '1' begin            
         select @cItemAux = ' '
         select @cClvlAux = ' '
         select @cEC05Aux = ' '
         select @cEC06Aux = ' '
         select @cEC07Aux = ' '
         select @cEC08Aux = ' '
         select @cEC09Aux = ' '  
         Exec CTB209D_## @cFilial_CVX, @IN_DATA, @IN_MOEDA, @IN_TPSALDO, @IN_CONTA, @IN_CUSTO, @cItemAux, @cClvlAux,
                           @cEC05Aux, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output                              
      End
      
      /* ---------------------------------------------------------------
         Atualiza Cubo 3 - ITEM CONTABIL
         --------------------------------------------------------------- */
      select @cConfig = '03'
      select @lCubo03 = CT0_CONTR
         From CT0###
         where CT0_FILIAL = @cFilial_CT0
         and CT0_ID     = @cConfig
         and D_E_L_E_T_ = ' '
      
      If @lCubo03 = '1' begin
         select @cClvlAux = ' '
         select @cEC05Aux = ' '
         select @cEC06Aux = ' '
         select @cEC07Aux = ' '
         select @cEC08Aux = ' '
         select @cEC09Aux = ' '
            Exec CTB209D_##  @cFilial_CVX, @IN_DATA, @IN_MOEDA, @IN_TPSALDO, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @cClvlAux,
                           @cEC05Aux, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output         
      End

      /* ---------------------------------------------------------------
         Atualiza Cubo 4 - CLASSE DE VALOR
         --------------------------------------------------------------- */
      select @cConfig = '04'
      select @lCubo04 = CT0_CONTR
         From CT0###
         where CT0_FILIAL = @cFilial_CT0
         and CT0_ID     = @cConfig
         and D_E_L_E_T_ = ' '
      
      If @lCubo04 = '1' begin      
         select @cEC05Aux = ' '
         select @cEC06Aux = ' '
         select @cEC07Aux = ' '
         select @cEC08Aux = ' '
         select @cEC09Aux = ' '
         Exec CTB209D_## @cFilial_CVX, @IN_DATA, @IN_MOEDA, @IN_TPSALDO, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
                           @cEC05Aux, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig,@IN_TRANSACTION, @OUT_RESULTADO Output         
      End
      
      /* ---------------------------------------------------------------
         Atualiza Cubo 5 - ENTIDADE NIVEL 05
         --------------------------------------------------------------- */
      ##FIELDP67( 'CT2.CT2_EC05DB' )      
         select @cConfig = '05'
         select @lCubo05 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo05 = '1' begin   
            select @cEC06Aux = ' '
            select @cEC07Aux = ' '
            select @cEC08Aux = ' '
            select @cEC09Aux = ' ' 
            Exec CTB209D_## @cFilial_CVX, @IN_DATA, @IN_MOEDA, @IN_TPSALDO, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
                              @IN_ENT05, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output                  
         End     
      ##ENDFIELDP67
      /* ---------------------------------------------------------------
         Atualiza Cubo 6 - ENTIDADE NIVEL 06
         --------------------------------------------------------------- */
      ##FIELDP73( 'CT2.CT2_EC06DB' )      
         select @cConfig = '06'
         select @lCubo06 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo06 = '1' begin   
            select @cEC07Aux = ' '
            select @cEC08Aux = ' '
            select @cEC09Aux = ' '  
            Exec CTB209D_## @cFilial_CVX, @IN_DATA, @IN_MOEDA, @IN_TPSALDO, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
                              @IN_ENT05, @IN_ENT06, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output                      
         End      
      ##ENDFIELDP73
      /* ---------------------------------------------------------------
         Atualiza Cubo 7 - ENTIDADE NIVEL 07
         --------------------------------------------------------------- */
      ##FIELDP79( 'CT2.CT2_EC07DB' )
         select @cConfig = '07'
         select @lCubo07 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '

         If @lCubo07 = '1' begin
            select @cEC08Aux = ' '
            select @cEC09Aux = ' ' 
            Exec CTB209D_## @cFilial_CVX, @IN_DATA, @IN_MOEDA, @IN_TPSALDO, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
                              @IN_ENT05, @IN_ENT06, @IN_ENT07, @cEC08Aux, @cEC09Aux, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output                 
         End
      ##ENDFIELDP79
      /* ---------------------------------------------------------------
         Atualiza Cubo 8 - ENTIDADE NIVEL 08
         --------------------------------------------------------------- */
      ##FIELDP85( 'CT2.CT2_EC08DB' )      
         select @cConfig = '08'
         select @lCubo08 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo08 = '1' begin   
            Select @cEC09Aux = ' '          
            Exec CTB209D_## @cFilial_CVX, @IN_DATA, @IN_MOEDA, @IN_TPSALDO, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
                              @IN_ENT05, @IN_ENT06, @IN_ENT07, @IN_ENT08, @cEC09Aux, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output                             
         End      
      ##ENDFIELDP85

      /* ---------------------------------------------------------------
         Atualiza Cubo 9 - ENTIDADE NIVEL 09
         --------------------------------------------------------------- */
      ##FIELDP91( 'CT2.CT2_EC09DB' )
         select @cConfig = '09'
         select @lCubo09 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo09 = '1' begin
            Exec CTB209D_## @cFilial_CVX, @IN_DATA, @IN_MOEDA, @IN_TPSALDO, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
                              @IN_ENT05, @IN_ENT06, @IN_ENT07, @IN_ENT08, @IN_ENT09, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output             
         End
      ##ENDFIELDP91
   end else begin
      /* Insere novamente os valores na CVX */
      Declare CUR_CUBO190 insensitive cursor for
      Select CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CONTA, CCUSTO, ITEM, CLASSE,             
            EC05, EC06, EC07, EC08, EC09, SUM(CT2_VALOR), TIPO
      From ( Select CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_DEBITO CONTA, CT2_CCD CCUSTO, CT2_ITEMD ITEM, CT2_CLVLDB CLASSE,   
                     CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, 
                        
                        ##IF_002({|| CT2->(FieldPos('CT2_EC05DB'))>0})
                           CT2_EC05DB EC05,
                        ##ELSE_002
                           ' ' EC05,
                        ##ENDIF_002
                        
                        ##IF_003({|| CT2->(FieldPos('CT2_EC06DB'))>0})
                           CT2_EC06DB EC06,
                        ##ELSE_003
                           ' ' EC06,
                        ##ENDIF_003

                        ##IF_004({|| CT2->(FieldPos('CT2_EC07DB'))>0})
                           CT2_EC07DB EC07,
                        ##ELSE_004
                           ' ' EC07,
                        ##ENDIF_004

                        ##IF_005({|| CT2->(FieldPos('CT2_EC08DB'))>0})
                           CT2_EC08DB EC08,
                        ##ELSE_005
                           ' ' EC08,
                        ##ENDIF_005

                        ##IF_006({|| CT2->(FieldPos('CT2_EC09DB'))>0})
                           CT2_EC09DB EC09,
                        ##ELSE_006
                           ' ' EC09,
                        ##ENDIF_006

                        CT2_VALOR, '1' TIPO
               From CT2###
               Where CT2_FILIAL = @cFilial_CT2
                  and CT2_DEBITO = @IN_CONTA
                  and CT2_DATA = @IN_DATA                    
                  and CT2_CCD = @IN_CUSTO
                  and CT2_ITEMD = @IN_ITEM
                  and CT2_CLVLDB = @IN_CLVL

                  ##FIELDP22( 'CT2.CT2_EC05DB' )
                     and CT2_EC05DB = @IN_ENT05
                  ##ENDFIELDP22

                  ##FIELDP23( 'CT2.CT2_EC06DB' )
                     and CT2_EC06DB = @IN_ENT06
                  ##ENDFIELDP23

                  ##FIELDP24( 'CT2.CT2_EC07DB' )
                     and CT2_EC07DB = @IN_ENT07
                  ##ENDFIELDP24

                  ##FIELDP25( 'CT2.CT2_EC08DB' )
                     and CT2_EC08DB = @IN_ENT08
                  ##ENDFIELDP25

                  ##FIELDP26( 'CT2.CT2_EC09DB' )
                     and CT2_EC09DB = @IN_ENT09
                  ##ENDFIELDP26

                  and (CT2_DC = '1' or CT2_DC = '3')
                  and CT2_TPSALD = @IN_TPSALDO
                  and CT2_MOEDLC = @IN_MOEDA
                  and CT2_DEBITO != ' '
                  and D_E_L_E_T_= ' ' 
            Union
               Select CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_CREDIT CONTA, CT2_CCC CCUSTO, CT2_ITEMC ITEM, CT2_CLVLCR CLASSE,
                        CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_TPSALD, CT2_EMPORI, CT2_FILORI, 
                        
                        ##IF_002({|| CT2->(FieldPos('CT2_EC05CR'))>0})
                           CT2_EC05CR EC05,
                        ##ELSE_002
                           ' ' EC05,
                        ##ENDIF_002
                        
                        ##IF_003({|| CT2->(FieldPos('CT2_EC06CR'))>0})
                           CT2_EC06CR EC06,
                        ##ELSE_003
                           ' ' EC06,
                        ##ENDIF_003

                        ##IF_004({|| CT2->(FieldPos('CT2_EC07CR'))>0})
                           CT2_EC07CR EC07,
                        ##ELSE_004
                           ' ' EC07,
                        ##ENDIF_004

                        ##IF_005({|| CT2->(FieldPos('CT2_EC08CR'))>0})
                           CT2_EC08CR EC08,
                        ##ELSE_005
                           ' ' EC08,
                        ##ENDIF_005

                        ##IF_006({|| CT2->(FieldPos('CT2_EC09CR'))>0})
                           CT2_EC09CR EC09,
                        ##ELSE_006
                           ' ' EC09,
                        ##ENDIF_006

                        CT2_VALOR, '2' TIPO
               From CT2###
               Where CT2_FILIAL = @cFilial_CT2
                  and CT2_CREDIT = @IN_CONTA
                  and CT2_DATA = @IN_DATA                    
                  and CT2_CCC = @IN_CUSTO
                  and CT2_ITEMC = @IN_ITEM
                  and CT2_CLVLCR = @IN_CLVL

                  ##FIELDP22( 'CT2.CT2_EC05CR' )
                     and CT2_EC05CR = @IN_ENT05
                  ##ENDFIELDP22

                  ##FIELDP23( 'CT2.CT2_EC06CR' )
                     and CT2_EC06CR = @IN_ENT06
                  ##ENDFIELDP23

                  ##FIELDP24( 'CT2.CT2_EC07CR' )
                     and CT2_EC07CR = @IN_ENT07
                  ##ENDFIELDP24

                  ##FIELDP25( 'CT2.CT2_EC08CR' )
                     and CT2_EC08CR = @IN_ENT08
                  ##ENDFIELDP25

                  ##FIELDP26( 'CT2.CT2_EC09CR' )
                     and CT2_EC09CR = @IN_ENT09
                  ##ENDFIELDP26

                  and (CT2_DC = '2' or CT2_DC = '3')
                  and CT2_TPSALD = @IN_TPSALDO
                  and CT2_MOEDLC = @IN_MOEDA
                  and CT2_CREDIT != ' '
                  and D_E_L_E_T_ = ' ' ) CT2TRB
      Where NOT EXISTS (Select 1 
                           From CQA### CQA
                           Where CQA_FILCT2 = CT2_FILIAL
                           and CQA_DATA     = CT2_DATA 
                           and CQA_LOTE     = CT2_LOTE 
                           and CQA_SBLOTE   = CT2_SBLOTE
                           and CQA_DOC      = CT2_DOC 
                           and CQA_LINHA    = CT2_LINHA
                           and CQA_TPSALD   = CT2_TPSALD
                           and CQA_EMPORI   = CT2_EMPORI
                           and CQA_FILORI   = CT2_FILORI
                           and CQA_MOEDLC   = CT2_MOEDLC
                           and CQA.D_E_L_E_T_ = ' ')
         Group by CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CONTA, CCUSTO, ITEM, CLASSE,
                  EC05, EC06, EC07, EC08, EC09, TIPO
         order by CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CONTA, CCUSTO, ITEM, CLASSE,
                  EC05, EC06, EC07, EC08, EC09, TIPO

      for read only
      Open CUR_CUBO190
      Fetch CUR_CUBO190 into  @cFILCT2, @cDATA, @cMOEDA, @cCONTA, @cCUSTO, @cITEM, @cCLVL,
                              @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nVALOR, @cTipo
      
      While (@@Fetch_status = 0 ) begin
         
         if @cTipo = '1' begin 
            select @nValDeb = Round(@nVALOR,2)
            select @nValCrd = 0
         end
         if @cTipo = '2' begin 
            select @nValDeb = 0
            select @nValCrd = Round(@nVALOR,2)
         end      
      
         select @cConfig = '01'
         select @lCubo01 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo01 = '1' begin 
            select @cCustoAux = ' '
            select @cItemAux = ' '
            select @cClvlAux = ' '
            select @cEC05Aux = ' '
            select @cEC06Aux = ' '
            select @cEC07Aux = ' '
            select @cEC08Aux = ' '
            select @cEC09Aux = ' '
         
            Exec CTB208D_## @cFILCT2, @cDATA, @cMOEDA, @IN_TPSALDO, @cCONTA, @cCustoAux, @cItemAux, @cClvlAux,
                              @cEC05Aux, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @nValDeb, @nValCrd, @IN_TRANSACTION, @OUT_RESULTADO Output 
         End
         
         /* ---------------------------------------------------------------
            Atualiza Cubo 2 - ccusto
            --------------------------------------------------------------- */
         
         select @cConfig = '02'
         select @lCubo02 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo02 = '1' begin            
            select @cItemAux = ' '
            select @cClvlAux = ' '
            select @cEC05Aux = ' '
            select @cEC06Aux = ' '
            select @cEC07Aux = ' '
            select @cEC08Aux = ' '
            select @cEC09Aux = ' '  
         
            Exec CTB208D_## @cFILCT2, @cDATA, @cMOEDA, @IN_TPSALDO, @cCONTA, @cCUSTO, @cItemAux, @cClvlAux,
                              @cEC05Aux, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @nValDeb, @nValCrd, @IN_TRANSACTION, @OUT_RESULTADO Output                      
         End
      
         /* ---------------------------------------------------------------
            Atualiza Cubo 3 - ITEM CONTABIL
            --------------------------------------------------------------- */
         select @cConfig = '03'
         select @lCubo03 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo03 = '1' begin
            select @cClvlAux = ' '
            select @cEC05Aux = ' '
            select @cEC06Aux = ' '
            select @cEC07Aux = ' '
            select @cEC08Aux = ' '
            select @cEC09Aux = ' '
         
            Exec CTB208D_## @cFILCT2, @cDATA, @cMOEDA, @IN_TPSALDO, @cCONTA, @cCUSTO, @cITEM, @cClvlAux,
                              @cEC05Aux, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @nValDeb, @nValCrd, @IN_TRANSACTION, @OUT_RESULTADO Output 
         End
      
         /* ---------------------------------------------------------------
            Atualiza Cubo 4 - CLASSE DE VALOR
            --------------------------------------------------------------- */
         select @cConfig = '04'
         select @lCubo04 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
            and CT0_ID     = @cConfig
            and D_E_L_E_T_ = ' '
         
         If @lCubo04 = '1' begin      
            select @cEC05Aux = ' '
            select @cEC06Aux = ' '
            select @cEC07Aux = ' '
            select @cEC08Aux = ' '
            select @cEC09Aux = ' '
         
            Exec CTB208D_## @cFILCT2, @cDATA, @cMOEDA, @IN_TPSALDO, @cCONTA, @cCUSTO, @cITEM, @cCLVL,
                              @cEC05Aux, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @nValDeb, @nValCrd, @IN_TRANSACTION, @OUT_RESULTADO Output       
         End
         
         /* ---------------------------------------------------------------
            Atualiza Cubo 5 - ENTIDADE NIVEL 05
            --------------------------------------------------------------- */
         ##FIELDP67( 'CT2.CT2_EC05DB' )      
            select @cConfig = '05'
            select @lCubo05 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo05 = '1' begin   
               select @cEC06Aux = ' '
               select @cEC07Aux = ' '
               select @cEC08Aux = ' '
               select @cEC09Aux = ' ' 
               
               Exec CTB208D_## @cFILCT2, @cDATA, @cMOEDA, @IN_TPSALDO, @cCONTA, @cCUSTO, @cITEM, @cCLVL,
                                 @cEC05, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @nValDeb, @nValCrd, @IN_TRANSACTION, @OUT_RESULTADO Output 
            End     
         ##ENDFIELDP67
         /* ---------------------------------------------------------------
            Atualiza Cubo 6 - ENTIDADE NIVEL 06
            --------------------------------------------------------------- */
         ##FIELDP73( 'CT2.CT2_EC06DB' )      
            select @cConfig = '06'
            select @lCubo06 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo06 = '1' begin   
               select @cEC07Aux = ' '
               select @cEC08Aux = ' '
               select @cEC09Aux = ' '  
               
               Exec CTB208D_## @cFILCT2, @cDATA, @cMOEDA, @IN_TPSALDO, @cCONTA, @cCUSTO, @cITEM, @cCLVL,
                                 @cEC05, @cEC06, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @nValDeb, @nValCrd, @IN_TRANSACTION, @OUT_RESULTADO Output             
            End      
         ##ENDFIELDP73
         /* ---------------------------------------------------------------
            Atualiza Cubo 7 - ENTIDADE NIVEL 07
            --------------------------------------------------------------- */
         ##FIELDP79( 'CT2.CT2_EC07DB' )
            select @cConfig = '07'
            select @lCubo07 = CT0_CONTR
               From CT0###
               where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '

            If @lCubo07 = '1' begin
               select @cEC08Aux = ' '
               select @cEC09Aux = ' ' 
            
               Exec CTB208D_## @cFILCT2, @cDATA, @cMOEDA, @IN_TPSALDO, @cCONTA, @cCUSTO, @cITEM, @cCLVL,
                                 @cEC05, @cEC06, @cEC07, @cEC08Aux, @cEC09Aux, @cConfig, @nValDeb, @nValCrd, @IN_TRANSACTION, @OUT_RESULTADO Output         
            End
         ##ENDFIELDP79
         /* ---------------------------------------------------------------
            Atualiza Cubo 8 - ENTIDADE NIVEL 08
            --------------------------------------------------------------- */
         ##FIELDP85( 'CT2.CT2_EC08DB' )      
            select @cConfig = '08'
            select @lCubo08 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo08 = '1' begin   
               Select @cEC09Aux = ' '          
            
               Exec CTB208D_## @cFILCT2, @cDATA, @cMOEDA, @IN_TPSALDO, @cCONTA, @cCUSTO, @cITEM, @cCLVL,
                                 @cEC05, @cEC06, @cEC07, @cEC08, @cEC09Aux, @cConfig, @nValDeb, @nValCrd, @IN_TRANSACTION, @OUT_RESULTADO Output                       
            End      
         ##ENDFIELDP85

         /* ---------------------------------------------------------------
            Atualiza Cubo 9 - ENTIDADE NIVEL 09
            --------------------------------------------------------------- */
         ##FIELDP91( 'CT2.CT2_EC09DB' )
            select @cConfig = '09'
            select @lCubo09 = CT0_CONTR
            From CT0###
            where CT0_FILIAL = @cFilial_CT0
               and CT0_ID     = @cConfig
               and D_E_L_E_T_ = ' '
            
            If @lCubo09 = '1' begin
            
               Exec CTB208D_## @cFILCT2, @cDATA, @cMOEDA, @IN_TPSALDO, @cCONTA, @cCUSTO, @cITEM, @cCLVL,
                                 @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @cConfig, @nValDeb, @nValCrd, @IN_TRANSACTION, @OUT_RESULTADO Output 
            End
         ##ENDFIELDP91
         
         SELECT @fim_CUR = 0
         Fetch CUR_CUBO190 into @cFILCT2, @cDATA, @cMOEDA, @cCONTA, @cCUSTO, @cITEM, @cCLVL,
                                 @cEC05, @cEC06, @cEC07, @cEC08, @cEC09, @nVALOR, @cTipo
      End  
         
      close CUR_CUBO190
      deallocate CUR_CUBO190
      
      select @OUT_RESULTADO = '1'
   end
end
##ENDFIELDP01
##ENDIF_001
