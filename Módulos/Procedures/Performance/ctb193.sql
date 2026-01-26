Create procedure CTB193_##
( 
   @IN_FILIAL       Char('CT2_FILIAL'),
   @IN_LCUSTO       Char(01),
   @IN_LITEM        Char(01),
   @IN_LCLVL        Char(01),
   @IN_TRANSACTION  Char(01),
   @IN_SOMA         Char(01) , 
   @OUT_RESULTADO   Char(01) OutPut
 )
as

/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  011 </a>
    Fonte Microsiga - <s>  CTBA193.PRW </s>
    Descricao       - <d>  Processamento de Saldo em Fila </d>
    Funcao do Siga  -      CTB193Proc()
    Entrada         - <ri> @IN_FILIAL     - Filial do processamento</ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  Alvaro Camillo Neto	</r>
    Data        :     09/04/2014
    
    CTB193 - Processamento de Saldo em Fila
      +--> CTB187B - Exclusao de Saldos
            +--> CTB189 - Efetiva a atualizacao dos saldos na CQ0/CQ1, CQ2/CQ3, CQ4/CQ5, CQ6/CQ7, CQ8/CQ9
                  +--> CTB180 - Atualizacao de Saldos do CQ0/CQ1
                  +--> CTB181 - Atualizacao de Saldos do CQ2/CQ3, CQ8/CQ9
                  +--> CTB182 - Atualizacao de Saldos do CQ4/CQ5, CQ8/CQ9
                  +--> CTB183 - Atualizacao de Saldos do CQ6/CQ7, CQ8/CQ9
            +--> CTB233 - Atualiza CTC - Subtraindo valor
            +--> CTB156 - ATUALIZACAO DE CUBOS - SE ATIVO
                  +--> CTB200 - Atualizacao do CUBO 01 - PLANO CONTAS
                  +--> CTB201 - Atualizacao do CUBO 02 - CENTRO DE CUSTO
                  +--> CTB202 - Atualizacao do CUBO 03 - ITEM 
                  +--> CTB203 - Atualizacao do CUBO 04 - CLASSE DE VALOR
                  +--> CTB204 - Atualizacao do CUBO 05 - ENTIDADE NIV05
                  +--> CTB205 - Atualizacao do CUBO 06 - ENTIDADE NIV06
                  +--> CTB206 - Atualizacao do CUBO 07 - ENTIDADE NIV07
                  +--> CTB207 - Atualizacao do CUBO 08 - ENTIDADE NIV08
                  +--> CTB208 - Atualizacao do CUBO 09 - ENTIDADE NIV09
      +--> CTB194 - Ct190SlBse  - Atualizar Saldos base - CQ0, CQ1, CQ2, CQ3
               +--> CTB195  - Atualizar Saldos base - - CQ4, CQ5, CQ6, CQ7
               +--> CTB233  - Atualiza CTC - Somando valor
      +--> CTB300 - - Atualiza os CUBOS
      |        +--> LASTDAY - Retorna o ultimo dia do mes
      |        +--> CTB310 - Chama Gravacao dos Cubos
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
      +--> CTB196 - Zera Fila
-------------------------------------------------------------------------------------- */
declare @cAux        char(03)
declare @cAux2       char(01)
declare @dDataIni    char(08)
declare @dDataFim    char(08)
declare @cAlias      char(03)
declare @RecMin      integer
declare @RecMax      integer

begin
   
   select @OUT_RESULTADO = '0'
   select @RecMin = 0
   select @RecMax = 0   

   select @cAux = 'CQA'   

   /* -------------------------------------------------------------------------
   CTB187B - Ct190SlBse - Atualizar Saldos base - CQ0/CQ1 - CQ2/CQ3 - CQ4/CQ5 - CQ6/CQ7
   -------------------------------------------------------------------------*/
   select @OUT_RESULTADO = '0'
   Exec CTB187B_## @IN_TRANSACTION, @IN_SOMA, @OUT_RESULTADO OutPut
   
   select @RecMin = Isnull( Min( R_E_C_N_O_ ), 0 ), @RecMax = Isnull( Max( R_E_C_N_O_ ), 0 )
     from CQA###
    where D_E_L_E_T_ = ' '
   if ( ( @RecMin = 0 ) and ( @RecMax = 0 ) ) begin
      /* ------------------------------------------------------------
         Nao tem dados a reprocessar
         ------------------------------------------------------------*/
      select @OUT_RESULTADO = '1'
   end
   else begin     
      /* -------------------------------------------------------------------------
         CTB194 - Ct190SlBse - Atualizar Saldos base - CQ0/CQ1 - CQ2/CQ3 - CQ4/CQ5 - CQ6/CQ7
         -------------------------------------------------------------------------*/
     select @OUT_RESULTADO = '0'
     EXEC CTB194_## @RecMin,  @RecMax , @IN_LCUSTO, @IN_LITEM, @IN_LCLVL, @IN_TRANSACTION, @IN_SOMA, @OUT_RESULTADO Output
 
      /* -------------------------------------------------------------------------
         ATUALIZA CUBOS
         -------------------------------------------------------------------------*/
      ##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
      ##FIELDP01( 'CT0.CT0_ID' )
      Exec CTB300_##  @RecMin,  @RecMax , @IN_TRANSACTION, @OUT_RESULTADO OutPut
      ##ENDFIELDP01
      ##ENDIF_001

      ##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo('CT0',,'05') .And. FWAliasInDic('QL6') .And. CT2->(FieldPos('CT2_EC05DB'))>0})
         Exec CTB300A_##  @RecMin,  @RecMax , @IN_TRANSACTION, @OUT_RESULTADO OutPut
      ##ENDIF_001
      
      select @OUT_RESULTADO = '0'
      EXEC CTB196_## @RecMin,  @RecMax, @IN_TRANSACTION, @OUT_RESULTADO Output
   end

   /*---------------------------------------------------------------
     Se a execucao foi OK retorna '1'
   --------------------------------------------------------------- */
   select @OUT_RESULTADO = '1'
end
