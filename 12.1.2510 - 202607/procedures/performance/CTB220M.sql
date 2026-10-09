##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. ) .And. AliasInDic('QLJ')})
##FIELDP01( 'CT0.CT0_ID' )
Create procedure CTB220M_##
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
   @IN_DATA         Char(06),
   @IN_MOEDA        Char('QLJ_MOEDA'),
   @IN_TPSALD       Char('QLJ_TPSALD'),
   @IN_TIPO         Char(01),
   @IN_TRANSACTION  Char(01),
   @OUT_RESULTADO   Char(01) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v> Protheus P12 </v>    
    Procedure       -     Reprocessamento SigaCTB
    Descricao       - <d> Gerencia o reprocessamento de saldos Mensais do cubo (CVX e CVY)
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
declare @cFilial_CT0 char('CT0_FILIAL')
declare @cFILCT2     char('CT2_FILIAL')
declare @cMOEDA      Char('CT2_MOEDLC')
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

   exec XFILIAL_## 'CT0', @IN_FILIAL, @cFilial_CT0 OutPut
   /* deleta saldos mensais */
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
         Exec CTB209M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @cCustoAux, @cItemAux, @cClvlAux,
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
         Exec CTB209M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @cItemAux, @cClvlAux,
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
         Exec CTB209M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @cClvlAux,
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
         Exec CTB209M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
                           @cEC05Aux, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output     
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
            Exec CTB209M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
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
            Exec CTB209M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
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
            Exec CTB209M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
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
            Exec CTB209M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
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
            Exec CTB209M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
                           @IN_ENT05, @IN_ENT06, @IN_ENT07, @IN_ENT08, @IN_ENT09, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output            
         End
      ##ENDFIELDP91
      
   end else begin

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
        
         Exec CTB208M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @cCustoAux, @cItemAux, @cClvlAux,
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
         
         Exec CTB208M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @cItemAux, @cClvlAux,
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
        
         Exec CTB208M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @cClvlAux,
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
        
         Exec CTB208M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
                           @cEC05Aux, @cEC06Aux, @cEC07Aux, @cEC08Aux, @cEC09Aux, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output      
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
           
            Exec CTB208M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
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
            
            Exec CTB208M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
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
            
            Exec CTB208M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
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
           
            Exec CTB208M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
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
           
            Exec CTB208M_## @IN_FILIAL, @IN_DATA, @IN_MOEDA, @IN_TPSALD, @IN_CONTA, @IN_CUSTO, @IN_ITEM, @IN_CLVL,
                           @IN_ENT05, @IN_ENT06, @IN_ENT07, @IN_ENT08, @IN_ENT09, @cConfig, @IN_TRANSACTION, @OUT_RESULTADO Output 
         End
      ##ENDFIELDP91

   end   
   select @OUT_RESULTADO = '1'
end
##ENDFIELDP01
##ENDIF_001
