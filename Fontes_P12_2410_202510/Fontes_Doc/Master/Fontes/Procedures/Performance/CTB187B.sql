Create Procedure CTB187B_##(
   @IN_TRANSACTION Char(01),
   @IN_SOMA      Char( 01 ) ,
   @OUT_RESULT   Char( 01 ) OutPut
)

as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ctbxatu.prx </s>
    Descricao       - <d>  Atualizacao de Saldos na Exlusao do Lote  </d>
    Entrada         - <ri> @IN_FILIAL       - Filial onde a manutencao sera feita                     
                           @IN_INTEGRID     - '1' integridade ligada, '0'- Integridade desligada
                           @IN_MVSOMA       - '1' somo o valor no total digitado, se '2' somo duas vezes.
    Saida           - <o>  @OUT_RESULT      - Indica o termino OK da procedure </ro>
    Data        :     19/10/2009
--------------------------------------------------------------------------------------------------------------------- */
declare @cFilial_CT2 Char( 'CT2_FILIAL' )
declare @cMoeda      Char( 'CT2_MOEDLC' )
declare @cDebito     Char( 'CT2_DEBITO' )
declare @cCredit     Char( 'CT2_CREDIT' )
declare @cCustoD     Char( 'CT2_CCD' )
declare @cCustoC     Char( 'CT2_CCC' )
declare @cItemD      Char( 'CT2_ITEMD' )
declare @cItemC      Char( 'CT2_ITEMC' )
declare @cClvlD      Char( 'CT2_CLVLDB' )
declare @cClvlC      Char( 'CT2_CLVLCR' )
declare @cAux        VarChar( 03 )
declare @cTpSaldo    Char( 'CT2_TPSALD' )
declare @cDc         Char( 'CT2_DC' )
declare @cDoc Char('CT2_DOC' )
declare @cSbLote Char( 'CT2_SBLOTE' )
declare @cLote Char( 'CT2_LOTE' )
##IF_001({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F.)})
##FIELDP01( 'CT2.CT2_EC05DB' )
declare @cCT2_EC05DB Char( 'CT2_EC05DB' )
declare @cCT2_EC05CR Char( 'CT2_EC05CR' )
##ENDFIELDP01
##FIELDP02( 'CT2.CT2_EC06DB' )
declare @cCT2_EC06DB Char( 'CT2_EC06DB' )
declare @cCT2_EC06CR Char( 'CT2_EC06CR' )
##ENDFIELDP02
##FIELDP03( 'CT2.CT2_EC07DB' )
declare @cCT2_EC07DB Char( 'CT2_EC07DB' )
declare @cCT2_EC07CR Char( 'CT2_EC07CR' )
##ENDFIELDP03
##FIELDP04( 'CT2.CT2_EC08DB' )
declare @cCT2_EC08DB Char( 'CT2_EC08DB' )
declare @cCT2_EC08CR Char( 'CT2_EC08CR' )
##ENDFIELDP04
##FIELDP05( 'CT2.CT2_EC09DB' )
declare @cCT2_EC09DB Char( 'CT2_EC09DB' )
declare @cCT2_EC09CR Char( 'CT2_EC09CR' )
##ENDFIELDP05
##ENDIF_001
declare @nValor      Float
declare @cOper       Char( 01 )
declare @cData       Char( 08 )
declare @cDtlp       Char( 08 )
declare @cResult     Char( 01 )
declare @iRecnoTRW   integer

##IF_007({|| lColPer05 := (cPaisLoc $ 'COL|PER' .And. CtbMovSaldo("CT0",,"05") .And. FWAliasInDic('QL6') .And. CT2->(FieldPos('CT2_EC05DB'))>0)})   
   declare @cEC05DB_TRW Char( 'CT2_EC05DB' )
   declare @cEC05CR_TRW Char( 'CT2_EC05DB' )      
##ELSE_007   
   declare @cEC05DB_TRW Char( 01 )
   declare @cEC05CR_TRW Char( 01 )      
##ENDIF_007

begin
   Select @OUT_RESULT = '0'
   Select @cOper      = '-'
   Select @cResult    = '0'
   Select @cEC05DB_TRW = ' '
   Select @cEC05CR_TRW = ' '   
   select @cAux = 'CT2'
   /*---------------------------------------------------------------
     Trazer os dados do lancto para exclusão
     --------------------------------------------------------------- */
   Declare CTB_TRW insensitive cursor for
   select CT2_FILIAL, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_MOEDLC, CT2_DATA,  CT2_TPSALD, CT2_DC,     CT2_DEBITO, CT2_CREDIT, CT2_VALOR,  CT2_CCD,    CT2_CCC,
          CT2_ITEMD,  CT2_ITEMC, CT2_CLVLDB, CT2_CLVLCR, CT2_DTLP, R_E_C_N_O_
            ##IF_002({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
            ##FIELDP06( 'CT2.CT2_EC05DB' )
               , CT2_EC05DB
               , CT2_EC05CR
            ##ENDFIELDP06
            ##FIELDP07( 'CT2.CT2_EC06DB' )
               , CT2_EC06DB
               , CT2_EC06CR
            ##ENDFIELDP07
            ##FIELDP08( 'CT2.CT2_EC07DB' )
               , CT2_EC07DB
               , CT2_EC07CR
            ##ENDFIELDP08
            ##FIELDP09( 'CT2.CT2_EC08DB' )
               , CT2_EC08DB
               , CT2_EC08CR
            ##ENDFIELDP09
            ##FIELDP10( 'CT2.CT2_EC09DB' )
               , CT2_EC09DB
               , CT2_EC09CR
            ##ENDFIELDP10
            ##ENDIF_002
            ##IF_003({|| lColPer05 })
               , CT2_EC05DB
               , CT2_EC05CR
            ##ENDIF_003
        From TRW###
       Where CT2_FILIAL BETWEEN ' ' and 'zzzzzzzz'
         and CT2_DC      != '4'
         and CT2_TPSALD  != '9'
         and D_E_L_E_T_  = ' '
     For read only
     Open CTB_TRW
   
   Fetch CTB_TRW into @cFilial_CT2, @cLote,  @cSbLote, @cDoc, @cMoeda, @cData, @cTpSaldo, @cDc,   @cDebito, @cCredit, @nValor,  @cCustoD, @cCustoC,
                      @cItemD, @cItemC, @cClvlD, @cClvlC, @cDtlp,   @iRecnoTRW
                     ##IF_003({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                     ##FIELDP11( 'CT2.CT2_EC05DB' )
                        , @cCT2_EC05DB
                        , @cCT2_EC05CR
                     ##ENDFIELDP11
                     ##FIELDP12( 'CT2.CT2_EC06DB' )
                        , @cCT2_EC06DB
                        , @cCT2_EC06CR
                     ##ENDFIELDP12
                     ##FIELDP13( 'CT2.CT2_EC07DB' )
                        , @cCT2_EC07DB
                        , @cCT2_EC07CR
                     ##ENDFIELDP13
                     ##FIELDP14( 'CT2.CT2_EC08DB' )
                        , @cCT2_EC08DB
                        , @cCT2_EC08CR
                     ##ENDFIELDP14
                     ##FIELDP15( 'CT2.CT2_EC09DB' )
                        , @cCT2_EC09DB
                        , @cCT2_EC09CR
                     ##ENDFIELDP15
                     ##ENDIF_003
                      ##IF_004({|| lColPer05 })
                        , @cEC05DB_TRW
                        , @cEC05CR_TRW
                     ##ENDIF_004
    
   While ( @@Fetch_status = 0 ) begin
      
      If @cDc != '4' begin
         /*---------------------------------------------------------------
           Exclusão de contas a Debito e/ou Credito
           --------------------------------------------------------------- */
         exec CTB189_## @cFilial_CT2, @cOper,  @cDc,   @cDebito, @cCredit, @cCustoD,     @cCustoC, @cItemD, @cItemC, @cClvlD, @cClvlC, @cEC05DB_TRW, @cEC05CR_TRW, 
                        @cTpSaldo,  @cMoeda, @cData, @cDtlp,   @nValor,  '0', @IN_TRANSACTION, @cResult OutPut
         /*---------------------------------------------------------------
           Exclusão/subtração de Totais por lote
           --------------------------------------------------------------- */
         exec CTB233_## @cFilial_CT2, @cData, @cLote,  @cSbLote, @cDoc, @cMoeda,@cTpSaldo,  @cDc, @cOper, @IN_SOMA, @nValor, @IN_TRANSACTION, @cResult OutPut

         /*-------------------------------------------------------------------
           Atualiza os Cubos Diários e Mensais - CVX e CVY
           ------------------------------------------------------------------- */
         ##IF_004({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
         ##FIELDP26( 'CT0.CT0_ID' )
         select @nValor = @nValor * (-1)
         Exec CTB156_## @cFilial_CT2, @cDebito, @cCredit, @cCustoD, @cCustoC, @cItemD, @cItemC, @cClvlD, @cClvlC
                        ##FIELDP16( 'CT2.CT2_EC05DB' )
                           , @cCT2_EC05DB
                           , @cCT2_EC05CR
                        ##ENDFIELDP16
                        ##FIELDP17( 'CT2.CT2_EC06DB' )
                           , @cCT2_EC06DB
                           , @cCT2_EC06CR
                        ##ENDFIELDP17
                        ##FIELDP18( 'CT2.CT2_EC07DB' )
                           , @cCT2_EC07DB
                           , @cCT2_EC07CR
                        ##ENDFIELDP18
                        ##FIELDP19( 'CT2.CT2_EC08DB' )
                           , @cCT2_EC08DB
                           , @cCT2_EC08CR
                        ##ENDFIELDP19
                        ##FIELDP20( 'CT2.CT2_EC09DB' )
                           , @cCT2_EC09DB
                           , @cCT2_EC09CR
                        ##ENDFIELDP20
                        ,@cMoeda
                        ,@cDc
                        ,@cData
                        ,@cTpSaldo
                        ,@nValor
                        ,@IN_TRANSACTION
                        ,@cResult OutPut
         ##ENDFIELDP26
         ##ENDIF_004
      End
      /*-------------------------------------------------------------------
        Excluir a linha do TRW que ja foi atualizada
        ------------------------------------------------------------------- */
      ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
      delete from TRW###
       where R_E_C_N_O_ = @iRecnoTRW
      ##CHECK_TRANSACTION_COMMIT
      
      Fetch CTB_TRW into @cFilial_CT2, @cLote,  @cSbLote, @cDoc, @cMoeda, @cData,  @cTpSaldo, @cDc,  @cDebito, @cCredit, @nValor,  @cCustoD, @cCustoC,
                         @cItemD, @cItemC, @cClvlD, @cClvlC,  @cDtlp,  @iRecnoTRW
                        ##IF_005({|| IIF(FindFunction('CTBISCUBE'), CTBISCUBE(), .F. )})
                        ##FIELDP21( 'CT2.CT2_EC05DB' )
                           , @cCT2_EC05DB
                           , @cCT2_EC05CR
                        ##ENDFIELDP21
                        ##FIELDP22( 'CT2.CT2_EC06DB' )
                           , @cCT2_EC06DB
                           , @cCT2_EC06CR
                        ##ENDFIELDP22
                        ##FIELDP23( 'CT2.CT2_EC07DB' )
                           , @cCT2_EC07DB
                           , @cCT2_EC07CR
                        ##ENDFIELDP23
                        ##FIELDP24( 'CT2.CT2_EC08DB' )
                           , @cCT2_EC08DB
                           , @cCT2_EC08CR
                        ##ENDFIELDP24
                        ##FIELDP25( 'CT2.CT2_EC09DB' )
                           , @cCT2_EC09DB
                           , @cCT2_EC09CR
                        ##ENDFIELDP25
                        ##ENDIF_005
                        ##IF_006({|| lColPer05 })
                           , @cEC05DB_TRW
                           , @cEC05CR_TRW
                        ##ENDIF_006
   End
   Close CTB_TRW
   Deallocate CTB_TRW
   
   Select @OUT_RESULT = @cResult
End
