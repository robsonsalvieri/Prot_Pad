##IF_001({|| cPaisLoc $ 'COL|PER' .And. CtbMovSaldo('CT0',,'05') .And. FWAliasInDic('QL6') .And. CT2->(FieldPos('CT2_EC05DB'))>0})
Create procedure CTB300A_##
( 
  @IN_RECMIN       Integer ,
  @IN_RECMAX       Integer ,
  @IN_TRANSACTION  Char(01),
  @OUT_RESULTADO   Char( 01 ) OutPut
 )
as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBA193.PRW </s>
    Descricao       - <d>  Reprocessamento SigaCTB </d>
    Procedure       -      Atualizacao de slds Bases - CT3, CT4, CT7, CTI
    Funcao do Siga  -      Ct190SlBse()
     Entrada         - <ri> @IN_RECMIN       - Recno Inicial da CQA
    					   @IN_RECMAX       - Recno Final da CQA 
    				  </ri>
    Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Responsavel :     <r>  TOTVS	</r>
    Data        :     07/11/2024
    Obs: a variável @iTranCount = 0 será trocada por 'commit tran' no CFGX051 pro SQLSERVER 
         e SYBASE
    CTB300a - Atualiza QL6 e QL7
     
   -------------------------------------------------------------------------------------- */

declare @RecMin      integer
declare @RecMax      integer
declare @iRecno      integer
declare @cFILCT2     char( 'CT2_FILIAL' )
declare @cFilial_QL6 char( 'CT2_FILIAL' )
declare @cFilial_QL7 char( 'CT2_FILIAL' )
declare @cFilial_CQ8 char( 'CT2_FILIAL' )
declare @cFilial_CQ9 char( 'CT2_FILIAL' )         
declare @cDATA       Char( 08 )
declare @cDataF      Char( 08 )
declare @cMOEDA      Char( 'CT7_MOEDA' )
declare @cCONTA      Char( 'CT7_CONTA' )
declare @cCUSTO      Char( 'CT3_CUSTO' )
declare @cITEM       Char( 'CT4_ITEM' )
declare @cCLVL       Char( 'CTI_CLVL' )
declare @cEC05       Char( 'CT2_EC05DB' )
declare @cTIPO       Char( 01 )
declare @cTPSALD     Char( 01 )
declare @nVALOR      Float
declare @nCTX_DEBITO Float
declare @nCTX_CREDIT Float
declare @cCTX_STATUS Char( 01 )
declare @cCTX_SLBASE Char( 01 )
declare @cCTX_DTLP   Char( 01 )
declare @cCT2_DTLP   Char( 08 )
declare @cCTX_LP     Char( 01 )


begin
   
   select @OUT_RESULTADO = '0'
   
   select @RecMin = @IN_RECMIN 
   select @RecMax = @IN_RECMAX  
   
   
   Declare CUR_CUBO190 insensitive cursor for
   Select CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB,CT2_TPSALD,CT2_EC05DB,CT2_DTLP,SUM(CT2_VALOR),'1'
        From CT2### CT2 , CQA### CQA
       Where (CT2_DC = '1' or CT2_DC = '3')
         and CT2_DEBITO != ' '
         and CQA.D_E_L_E_T_ = ' '
		 and CT2.D_E_L_E_T_ = ' '
		 and CT2_FILIAL = CQA_FILCT2
		 and CT2_DATA   = CQA_DATA
		 and CT2_LOTE   = CQA_LOTE
		 and CT2_SBLOTE = CQA_SBLOTE
		 and CT2_DOC    = CQA_DOC
		 and CT2_LINHA  = CQA_LINHA
		 and CT2_TPSALD = CQA_TPSALD
		 and CT2_EMPORI = CQA_EMPORI
		 and CT2_FILORI = CQA_FILORI
		 and CT2_MOEDLC = CQA_MOEDLC
       and CT2_EC05DB <> ' '
		 and CQA.R_E_C_N_O_  between @RecMin and @RecMax
   Group By CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_DEBITO, CT2_CCD, CT2_ITEMD, CT2_CLVLDB,CT2_TPSALD,CT2_EC05DB,CT2_DTLP           
   Union
   Select CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR,CT2_TPSALD,CT2_EC05CR,CT2_DTLP,SUM(CT2_VALOR),'2'
        From CT2### CT2 , CQA### CQA
       Where (CT2_DC = '2' or CT2_DC = '3')
         and CT2_CREDIT != ' '
         and CQA.D_E_L_E_T_ = ' '
		 and CT2.D_E_L_E_T_ = ' '
		 and CT2_FILIAL = CQA_FILCT2
		 and CT2_DATA   = CQA_DATA
		 and CT2_LOTE   = CQA_LOTE
		 and CT2_SBLOTE = CQA_SBLOTE
		 and CT2_DOC    = CQA_DOC
		 and CT2_LINHA  = CQA_LINHA
		 and CT2_TPSALD = CQA_TPSALD
		 and CT2_EMPORI = CQA_EMPORI
		 and CT2_FILORI = CQA_FILORI
		 and CT2_MOEDLC = CQA_MOEDLC
       and CT2_EC05CR <> ' '
		 and CQA.R_E_C_N_O_  between @RecMin and @RecMax 
   Group By CT2_FILIAL, CT2_DATA, CT2_MOEDLC, CT2_CREDIT, CT2_CCC, CT2_ITEMC, CT2_CLVLCR,CT2_TPSALD,CT2_EC05CR,CT2_DTLP
   order by 1,2,3,4,5,6,7,8,9
            
   for read only
   Open CUR_CUBO190
   Fetch CUR_CUBO190 into  @cFILCT2, @cDATA, @cMOEDA, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cTPSALD, @cEC05, @cCT2_DTLP, @nVALOR, @cTIPO
   
   While (@@Fetch_status = 0 ) begin

         
         exec XFILIAL_## 'QL6', @cFILCT2, @cFilial_QL6 OutPut         
         exec XFILIAL_## 'QL7', @cFILCT2, @cFilial_QL7 OutPut         
         exec XFILIAL_## 'CQ8', @cFILCT2, @cFilial_CQ8 OutPut         
         exec XFILIAL_## 'CQ9', @cFILCT2, @cFilial_CQ9 OutPut
         
         select @nCTX_DEBITO = 0
         select @nCTX_CREDIT = 0
         select @cCTX_STATUS = '1'
         select @cCTX_SLBASE = 'S'
         select @cCTX_DTLP = ' '
         /*---------------------------------------------------------------
           Ajusta dados para GRAVACO DE SALDOS DO DIA 
           --------------------------------------------------------------- */
         if @cTIPO = '1' begin
            select @nCTX_DEBITO = Round(@nVALOR, 2)
            select @nCTX_CREDIT = 0
         end
         if @cTIPO = '2' begin
            select @nCTX_CREDIT = Round(@nVALOR, 2)
            select @nCTX_DEBITO = 0
         end
         
         if @cCT2_DTLP = ' ' begin
            select @cCTX_LP = 'N'
            select @cCTX_DTLP = ' '
         end else begin
            select @cCTX_LP = 'Z'
            select @cCTX_DTLP = @cCT2_DTLP
         end
         /*---------------------------------------------------------------
           Verifica se a linha ja existe no QL7
           --------------------------------------------------------------- */ 
         select @iRecno  = 0     
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From QL7###
          Where QL7_FILIAL = @cFilial_QL7
            and QL7_DATA   = @cDATA
            and QL7_CONTA  = @cCONTA
            and QL7_CCUSTO = @cCUSTO
            and QL7_ITEM   = @cITEM
            and QL7_CLVL   = @cCLVL
            and QL7_ENT05  = @cEC05
            and QL7_MOEDA  = @cMOEDA
            and QL7_TPSALD = @cTPSALD
            and QL7_LP     = @cCTX_LP
            and QL7_DTLP   = @cCTX_DTLP            
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM QL7###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no QL7 - Saldos da Conta
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into QL7### ( QL7_FILIAL, QL7_CONTA, QL7_CCUSTO, QL7_ITEM, QL7_CLVL, QL7_ENT05, QL7_MOEDA, QL7_DATA, QL7_TPSALD, QL7_SLBASE, QL7_DTLP, QL7_LP, QL7_STATUS, QL7_DEBITO, QL7_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_QL7, @cCONTA,    @cCUSTO,   @cITEM,   @cCLVL,    @cEC05,   @cMOEDA, @cDATA, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Update no QL7 - Saldos da Conta
           --------------------------------------------------------------- */
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update QL7###
               set QL7_DEBITO = QL7_DEBITO + @nCTX_DEBITO, QL7_CREDIT  = QL7_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
         ##CHECK_TRANSACTION_COMMIT
         
         /*-----------------------------------------------------------------
		       Verifica se a linha ja existe no QL7  MES
          ----------------------------------------------------------------- */  
         Exec LASTDAY_## @cDATA, @cDataF OutPut
      
         select @iRecno  = 0
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From QL6###
          Where QL6_FILIAL = @cFilial_QL7
            and QL6_DATA   = @cDataF
            and QL6_CONTA  = @cCONTA
            and QL6_CCUSTO = @cCUSTO
            and QL6_ITEM   = @cITEM
            and QL6_CLVL   = @cCLVL
            and QL6_ENT05  = @cEC05
            and QL6_MOEDA  = @cMOEDA
            and QL6_TPSALD = @cTPSALD
            and QL6_LP     = @cCTX_LP
            and QL6_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM QL6###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no QL6 - Classe de Valor
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
     	      Insert into QL6### ( QL6_FILIAL, QL6_CONTA, QL6_CCUSTO, QL6_ITEM, QL6_CLVL, QL6_ENT05, QL6_MOEDA, QL6_DATA, QL6_TPSALD, QL6_SLBASE, QL6_DTLP, QL6_LP, QL6_STATUS, QL6_DEBITO, QL6_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_QL7, @cCONTA,    @cCUSTO,   @cITEM,   @cCLVL,    @cEC05, @cMOEDA, @cDataF, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno ) 
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Insert no QL6 - Classe de Valor
           --------------------------------------------------------------- */
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update QL6###
               set QL6_DEBITO = QL6_DEBITO + @nCTX_DEBITO, QL6_CREDIT  = QL6_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
         ##CHECK_TRANSACTION_COMMIT

         /* -----------------------------------------------------------------
            Verifica se a linha ja existe no CQ9 (Saldo por entidade ) - DIA
            ----------------------------------------------------------------- */      
         select @iRecno  = 0
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ9###
          Where CQ9_FILIAL = @cFilial_CQ9
            and CQ9_DATA   = @cDATA
            and CQ9_IDENT  = 'CV0'
            and CQ9_CODIGO = @cEC05
            and CQ9_MOEDA  = @cMOEDA
            and CQ9_TPSALD = @cTPSALD
            and CQ9_LP     = @cCTX_LP
            and CQ9_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ9###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ9 - Saldos poe entidades Dia
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into CQ9### ( CQ9_FILIAL, CQ9_IDENT, CQ9_CODIGO, CQ9_MOEDA, CQ9_DATA, CQ9_TPSALD, CQ9_SLBASE, CQ9_DTLP, CQ9_LP, CQ9_STATUS, CQ9_DEBITO, CQ9_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_CQ9, 'CV0', @cEC05, @cMOEDA, @cDATA, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Update no CQ9 - Saldos por entidade DIA
           --------------------------------------------------------------- */
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ9###
               set CQ9_DEBITO = CQ9_DEBITO + @nCTX_DEBITO, CQ9_CREDIT  = CQ9_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
         ##CHECK_TRANSACTION_COMMIT

         /* -----------------------------------------------------------------
            Verifica se a linha ja existe no CQ8 (Saldo por entidade ) - MES
            ----------------------------------------------------------------- */   
         Exec LASTDAY_## @cDATA, @cDataF OutPut
         
         select @iRecno  = 0
         ##UNIQUEKEY_START
         select @iRecno = Isnull(Min(R_E_C_N_O_), 0)
           From CQ8###
          Where CQ8_FILIAL = @cFilial_CQ8
            and CQ8_DATA   = @cDataF
            and CQ8_IDENT  = 'CV0'
            and CQ8_CODIGO = @cEC05
            and CQ8_MOEDA  = @cMOEDA
            and CQ8_TPSALD = @cTPSALD
            and CQ8_LP     = @cCTX_LP
            and CQ8_DTLP   = @cCTX_DTLP
            and D_E_L_E_T_ = ' '
         ##UNIQUEKEY_END
         
         If @iRecno = 0 begin
            select @iRecno = IsNull(Max(R_E_C_N_O_), 0) FROM CQ8###
            select @iRecno = @iRecno + 1
            /*---------------------------------------------------------------
              Insert no CQ8 - Saldos dpoe entidade MES
              --------------------------------------------------------------- */
            ##TRATARECNO @iRecno\
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Insert into CQ8### ( CQ8_FILIAL, CQ8_IDENT, CQ8_CODIGO, CQ8_MOEDA, CQ8_DATA, CQ8_TPSALD, CQ8_SLBASE, CQ8_DTLP, CQ8_LP, CQ8_STATUS, CQ8_DEBITO, CQ8_CREDIT, R_E_C_N_O_ )
                         values( @cFilial_CQ8, 'CV0', @cEC05, @cMOEDA, @cDataF, @cTPSALD, @cCTX_SLBASE, @cCTX_DTLP, @cCTX_LP, @cCTX_STATUS, 0, 0, @iRecno )
            ##CHECK_TRANSACTION_COMMIT
            ##FIMTRATARECNO
         end
         /*---------------------------------------------------------------
           Update no CQ8 - Saldos da Conta
           --------------------------------------------------------------- */
         ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            Update CQ8###
               set CQ8_DEBITO = CQ8_DEBITO + @nCTX_DEBITO, CQ8_CREDIT  = CQ8_CREDIT + @nCTX_CREDIT
             Where R_E_C_N_O_ = @iRecno
         ##CHECK_TRANSACTION_COMMIT
            
      SELECT @fim_CUR = 0
      Fetch CUR_CUBO190 into @cFILCT2, @cDATA, @cMOEDA, @cCONTA, @cCUSTO, @cITEM, @cCLVL, @cTPSALD, @cEC05, @cCT2_DTLP, @nVALOR, @cTIPO
   End
   close CUR_CUBO190
   deallocate CUR_CUBO190

   select @OUT_RESULTADO = '1'
end
##ENDIF_001
