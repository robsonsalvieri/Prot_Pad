-- =============================================
-- Author:		Fabio Bizerra Florencio
-- Create date: 05/11/2025
-- Description:	Geração dos titulos a Pagar Realizado
-- =============================================
CREATE PROCEDURE FIN009C_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer,
	@IN_TAMFIL Integer,
	@IN_TAMSED  Integer,
	@IN_TAMSX5  Integer,
	@IN_TAMSA2  Integer,
	@IN_TAMSEV  Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
	@IN_COMPANIA char('##COMPANIA'),
	@IN_COD_UNID char('##COD_UNID'),
	@IN_COD_FIL char('##COD_FIL'),
	@IN_mdmTenantId Char( 32 ),
	@IN_DTINI  char('F7I_EMIS1'),
	@IN_DTFIM  char('F7I_EMIS1'),
	@IN_FULL Char( 1 ),
	@IN_TRANSACTION Char( 1 ),
	@DecCONVBS Integer,
	@IN_maxStagingCounter DateTime,
	@IN_delTransactTime char(26),
	@IN_IDORIGEM char(32),
	@IN_LOTEPROC Char(6),
	@OUT_RESULTADO Char(1) OutPut
)
AS

DECLARE @N_TAMTOTAL Integer
DECLARE @param_DTINI char('F7I_EMIS1')
DECLARE @param_DTFIM char('F7I_EMIS1')
DECLARE @param_COMPANIA char('##COMPANIA')
DECLARE @param_COD_UNID char('##COD_UNID')
DECLARE @param_COD_FIL char('##COD_FIL')
DECLARE @filialCT1 char('CT1_FILIAL')
DECLARE @filialCTT char('CTT_FILIAL')
DECLARE @F7I_ORIGIN Char('F7I_ORIGIN')
DECLARE @cF7I_STAMP	Char('F7I_STAMP')
DECLARE @F7I_EXTCDH	Char('F7I_EXTCDH')
DECLARE @F7I_EXTCDD	Char('F7I_EXTCDD')
DECLARE @F7I_GRPEMP	Char('F7I_GRPEMP')
DECLARE @F7I_EMPR	Char('F7I_EMPR')
DECLARE @F7I_UNID	Char('F7I_UNID')
DECLARE @F7I_FILNEG	Char('F7I_FILNEG')
DECLARE @F7I_ORGSYT	char('F7I_ORGSYT')
DECLARE @F7I_EMISSA	Char('F7I_EMISSA')
DECLARE @F7I_EMIS1	Char('F7I_EMIS1')
DECLARE @F7I_HIST	Char('F7I_HIST')
DECLARE @F7I_TIPO	Char('F7I_TIPO')
DECLARE @F7I_TIPDSC	Char('X5_DESCRI')
DECLARE @F7I_PREFIX	Char('F7I_PREFIX')
DECLARE @F7I_NUM	Char('F7I_NUM')
DECLARE @F7I_PARCEL	Char('F7I_PARCEL')
DECLARE @F7I_DSCMDA	Char('F7I_DSCMDA')
DECLARE @F7I_MOEDA	Integer
DECLARE @MOEDA 		Integer
DECLARE @F7I_MOEDB	Integer
DECLARE @MOEDB 		Integer
DECLARE @F7I_DSCMDB	Char('F7I_DSCMDB')
DECLARE @F7I_VENCTO	Char('F7I_VENCTO')
DECLARE @F7I_VENCRE	Char('F7I_VENCRE')
DECLARE @F7I_DTPGTO	Char('F7I_DTPGTO')
DECLARE @F7I_TPEVNT	Char('F7I_TPEVNT')
DECLARE @F7I_BANCO	Char('F7I_BANCO')
DECLARE @F7I_AGENCI	Char('F7I_AGENCI')
DECLARE @F7I_CONTA	Char('F7I_CONTA')
DECLARE @F7I_FLBENF Char('F7I_FLBENF')
DECLARE @F7I_CDBENF Char('F7I_CDBENF')
DECLARE @F7I_LJBENF Char('F7I_LJBENF')
DECLARE @F7I_NBENEF Char('E2_NOMFOR')
DECLARE @F7I_TPBENF Char('F7I_TPBENF')
DECLARE @F7I_ORBENF Char('F7I_ORBENF')
DECLARE @F7I_IDMOV	Char('F7I_IDMOV')
DECLARE @F7I_SALDO	Float
DECLARE @F7I_VLPROP Float
DECLARE @F7I_VLCRUZ Float
DECLARE @F7I_CONVBS Float
DECLARE @F7I_FXRTBS Char('F7I_FXRTBS')
DECLARE @F7I_VLRCNT Float
DECLARE @F7I_CONVCT Float
DECLARE @F7I_FXRTCT Char('F7I_FXRTCT')
DECLARE @F7I_CNTCTB Char('F7I_CNTCTB')
DECLARE @F7I_DSCCTB Char('F7I_DSCCTB')
DECLARE @F7I_NATCTA Char('F7I_NATCTA')
DECLARE @F7I_CCUSTO Char('F7I_CCUSTO')
DECLARE @F7I_DSCCCT Char('F7I_DSCCCT')
DECLARE @F7I_DTDISP Char('F7I_DTDISP')
DECLARE @F7I_NATURE Char('F7I_NATURE')
DECLARE @F7I_NATRAT Char('F7I_NATRAT')
DECLARE @F7I_CCDRAT Char('F7I_CCDRAT')
DECLARE @F7I_DEBITO Char('F7I_DEBITO')
DECLARE @F7I_CCD	Char('F7I_CCD')
DECLARE @F7I_CCC	Char('F7I_CCC')
DECLARE @F7I_ITEMCT	Char('F7I_ITEMCT')
DECLARE @F7I_ITEMD	Char('F7I_ITEMD')
DECLARE @F7I_ITEMC	Char('F7I_ITEMC')
DECLARE @F7I_CLVL	Char('F7I_CLVL')
DECLARE @F7I_CLVLDB	Char('F7I_CLVLDB')
DECLARE @F7I_CLVLCR	Char('F7I_CLVLCR')
DECLARE @F7I_NUMBOR	Char('F7I_NUMBOR')
DECLARE @F7I_HISTOR	Char('F7I_HISTOR')
DECLARE @EZ_MSUID	Char('EZ_MSUID')
DECLARE @EV_MSUID	Char('EV_MSUID')
DECLARE @EV_SITUACA	Char('EV_SITUACA')
DECLARE @E2_FILORIG	Char('E2_FILORIG')
DECLARE @E2_BAIXA	Char('E2_BAIXA')
DECLARE @E2_CCUSTO  Char('E2_CCUSTO')
DECLARE @E2_VLCRUZ	Float
DECLARE @E2_VALOR	Float
DECLARE @E2_MOEDA   Integer
DECLARE @FK5_MOEDA  Char('FK5_MOEDA')
DECLARE @MOEDFK5  	Integer
DECLARE @CT1_CONTA	Char('CT1_CONTA')
DECLARE @ED_DEBITO	Char('ED_DEBITO')
DECLARE @ED_CREDIT	Char('ED_CREDIT')
DECLARE @FK2_IDFK2	Char('FK2_IDFK2')
DECLARE @FK5_RECPAG	Char('FK5_RECPAG')
DECLARE @FK2_VALOR	Float
DECLARE @FK2_VLMOE2	Float
DECLARE @EZ_VALOR	Float
DECLARE @EV_VALOR	Float
DECLARE @maxStagingCounter 	Datetime
DECLARE @fk5_S_T_A_M_P_ 	Datetime
DECLARE @cFk5_STAMP char(26)
DECLARE @fk5_Recno Integer
DECLARE @delTransactTime char(26)
DECLARE @cStamp char(26)
DECLARE @F7I_CREDIT char('F7I_CREDIT')
DECLARE @IS_SPACE char(1)
DECLARE @IS_FK7ALIAS char('FK7_ALIAS')
DECLARE @IS_TP_PA char('FK7_TIPO')
DECLARE @IS_TP_PR char('FK7_TIPO')
DECLARE @IS_DOCBL char('FK5_TPDOC')
DECLARE @IS_DOCBA char('FK5_TPDOC')
DECLARE @IS_DOCVL char('FK5_TPDOC')
DECLARE @IS_DOCES char('FK5_TPDOC')
DECLARE @IS_TP_IMP CHAR(2)
DECLARE @IS_X5TAB CHAR('X5_TABELA')
DECLARE @IS_EVIDENT2 CHAR('EV_IDENT')
DECLARE @IS_RECPAGP CHAR(1)
DECLARE @IS_RECPAGR CHAR(1)
DECLARE @IS_SIT_X CHAR(1)
DECLARE @IS_SIT_E CHAR(1)
DECLARE @IS_FULL CHAR(1)
DECLARE @IS_MVMOEDA VARCHAR(10)
DECLARE @F7J_ALIAS CHAR(3)
DECLARE @IS_FIN009C char(7)
DECLARE @ID_PROCESSO char(32)
DECLARE @DATA_INICIO char(26)
DECLARE @CONTADOR Integer
DECLARE @REGVALIDO char(1)
declare flex char(1)

Begin

	select @F7I_ORGSYT = 'PR'
	select @N_TAMTOTAL = @IN_TAMEMP + @IN_TAMUNIT +	@IN_TAMFIL
	select @maxStagingCounter = @IN_maxStagingCounter
	select @delTransactTime  = @IN_delTransactTime 
	select @param_DTINI = @IN_DTINI
	select @param_DTFIM = @IN_DTFIM
	select @param_COMPANIA = @IN_COMPANIA
    select @param_COD_UNID = @IN_COD_UNID
    select @param_COD_FIL = @IN_COD_FIL
	select @F7I_MOEDA = 0
	select @F7I_MOEDB = 0
	select @MOEDA = 0
	select @MOEDB = 0
	select @MOEDFK5 = 0
	select @IS_SPACE = ' '
	select @IS_FK7ALIAS = 'SE2'
	select @IS_TP_PA  = 'PA '
	select @IS_TP_PR  = 'PR '
	select @IS_X5TAB  = '05'  
	select @IS_EVIDENT2 = '2'  
	select @IS_RECPAGP = 'P'  
	select @IS_RECPAGR = 'R'  
	select @IS_SIT_X = 'X'  
	select @IS_SIT_E = 'E'  
	select @IS_MVMOEDA = 'MV_MOEDA'
	select @IS_DOCBL = 'BL'
	select @IS_DOCBA = 'BA'
	select @IS_DOCVL = 'VL'
	select @IS_DOCES = 'ES'
	select @IS_TP_IMP  = '%-'
	select @F7I_TPEVNT = 'S'
	select @F7I_TPBENF = '3'
	select @F7I_ORBENF = 'CP'
	select @IS_FULL = @IN_FULL
	select @F7I_SALDO = 0
	select @F7I_VLPROP = 0
	select @F7I_FXRTBS = 0
	select @F7I_VLRCNT = 0
	select @F7I_FXRTCT = 0
	select @F7J_ALIAS = 'CPR'
	select @IS_FIN009C = 'FIN009C'
	select @DATA_INICIO = CONVERT(Char(26), SYSDATETIME(), 121)
	select @ID_PROCESSO = @IN_IDORIGEM
	select @CONTADOR = 0 
	select @REGVALIDO = 'S'

	Begin	
		If @IS_FULL = 'S'
			Begin
				--Baixa em Lote Com Rateio
				DECLARE curPagar_BxLote_full_## insensitive cursor for
					SELECT  '##CTE_FK2' 			AS F7I_ORIGIN,
						FK5.S_T_A_M_P_ 				AS fk5_S_T_A_M_P_,
						FK5.R_E_C_N_O_				AS fk5_Recno,
						sez.EZ_MSUID				AS EZ_MSUID,
						sev.EV_MSUID				AS EV_MSUID,
						stg_se2.E2_FILORIG 			AS E2_FILORIG,
						stg_se2.E2_EMISSAO 			AS F7I_EMISSA,
						stg_se2.E2_EMIS1 			AS F7I_EMIS1,
						stg_se2.E2_HIST 			AS F7I_HIST,
						stg_se2.E2_TIPO 			AS F7I_TIPO,
						sx5_consolidate.X5_DESCRI	AS F7I_TIPDSC,
						stg_se2.E2_PREFIXO			AS F7I_PREFIX,
						stg_se2.E2_NUM				AS F7I_NUM,
						stg_se2.E2_PARCELA			AS F7I_PARCEL,
						stg_se2.E2_MOEDA			AS E2_MOEDA,
						FK5.FK5_MOEDA				AS FK5_MOEDA,
						stg_se2.E2_VENCTO			AS F7I_VENCTO,
						stg_se2.E2_VENCREA			AS F7I_VENCRE,
						FK5.FK5_DATA				AS F7I_DTPGTO,
						FK5.FK5_BANCO				AS F7I_BANCO,
						FK5.FK5_AGENCI				AS F7I_AGENCI,
						FK5.FK5_CONTA				AS F7I_CONTA,
						sa2.A2_FILIAL				AS F7I_FLBENF,
						stg_se2.E2_FORNECE 			AS F7I_CDBENF,
						stg_se2.E2_LOJA 			AS F7I_LJBENF,
						stg_se2.E2_NOMFOR 			AS F7I_NBENEF,
						FK5.FK5_IDMOV				AS F7I_IDMOV,
						sed.ED_CCD					AS F7I_CCUSTO,
						sed.ED_DEBITO				AS ED_DEBITO,
						sed.ED_CREDIT				AS ED_CREDIT,
						FK5.FK5_DTDISP				AS F7I_DTDISP,
						stg_se2.E2_NATUREZ			AS F7I_NATURE,
						sev.EV_NATUREZ				AS F7I_NATRAT,
						sez.EZ_CCUSTO				AS F7I_CCDRAT,
						stg_se2.E2_DEBITO			AS F7I_DEBITO,
						stg_se2.E2_CCC				AS F7I_CCC,
						stg_se2.E2_CCD				AS F7I_CCD,
						stg_se2.E2_ITEMCTA			AS F7I_ITEMCT,
						stg_se2.E2_ITEMD			AS F7I_ITEMD,
						stg_se2.E2_ITEMC			AS F7I_ITEMC,
						stg_se2.E2_CLVL				AS F7I_CLVL,
						stg_se2.E2_CLVLDB			AS F7I_CLVLDB,
						stg_se2.E2_CLVLCR			AS F7I_CLVLCR,
						stg_se2.E2_NUMBOR			AS F7I_NUMBOR,
						FK5.FK5_HISTOR				AS F7I_HISTOR,
						fk2.FK2_IDFK2				AS FK2_IDFK2,
						FK5.FK5_RECPAG				AS FK5_RECPAG,
						fk2.FK2_VALOR 				AS FK2_VALOR,
						fk2.FK2_VLMOE2 				AS FK2_VLMOE2,
						FK5.FK5_TXMOED				AS F7I_CONVBS,
						stg_se2.E2_CREDIT			AS F7I_CREDIT,
						sev.EV_SITUACA				AS EV_SITUACA,
						sev.EV_VALOR				AS EV_VALOR,
						sez.EZ_VALOR				AS EZ_VALOR
						,'#campoflex' as campoflex
						,'#camposflexrateio' as camposflexrateio
					FROM FK5### FK5 LEFT JOIN CT2### ON CT2_FILIAL = ' '  -- ct2 removido sempre pelo parser
						INNER JOIN fk2_one fk2 
							on fk2.FK2_FILIAL = FK5.FK5_FILIAL
								and fk2.FK2_LOTE = FK5.FK5_LOTE
								and 'X' = 'CASE_FK2_FK5_TPDOC'
								and fk2rn = 1
						INNER JOIN FK7### fk7  LEFT JOIN CT2### ON CT2_FILIAL = ' '  -- ct2 removido sempre pelo parser
							ON fk7.FK7_FILIAL = fk2.FK2_FILIAL
								AND fk7.FK7_IDDOC = fk2.FK2_IDDOC
								AND fk7.FK7_ALIAS = @IS_FK7ALIAS
								AND fk7.D_E_L_E_T_ = @IS_SPACE
						INNER JOIN SE2### stg_se2  LEFT JOIN CT2### ON CT2_FILIAL = ' '  -- ct2 removido sempre pelo parser
							ON	stg_se2.E2_FILIAL = fk7.FK7_FILTIT
								AND stg_se2.E2_PREFIXO = fk7.FK7_PREFIX
								AND stg_se2.E2_NUM = fk7.FK7_NUM
								AND stg_se2.E2_PARCELA = fk7.FK7_PARCEL
								AND stg_se2.E2_TIPO = fk7.FK7_TIPO
								AND stg_se2.E2_FORNECE = fk7.FK7_CLIFOR
								AND stg_se2.E2_LOJA = fk7.FK7_LOJA
								AND stg_se2.D_E_L_E_T_ = @IS_SPACE
								AND stg_se2.E2_TIPO NOT LIKE @IS_TP_IMP 
								AND stg_se2.E2_TIPO <>  @IS_TP_PR
						INNER JOIN SED### sed
							ON sed.ED_FILIAL = SUBSTRING(FK5.FK5_FILORI,1,@IN_TAMSED) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSED)
								AND sed.ED_CODIGO = stg_se2.E2_NATUREZ
								AND sed.D_E_L_E_T_ = @IS_SPACE
						LEFT JOIN SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
							ON sev.EV_FILIAL = stg_se2.E2_FILIAL
								AND sev.EV_PREFIXO = stg_se2.E2_PREFIXO
								AND sev.EV_NUM = stg_se2.E2_NUM
								AND sev.EV_PARCELA = stg_se2.E2_PARCELA
								AND sev.EV_TIPO = stg_se2.E2_TIPO
								AND sev.EV_CLIFOR = stg_se2.E2_FORNECE
								AND sev.EV_LOJA = stg_se2.E2_LOJA
								AND sev.EV_IDENT = @IS_EVIDENT2
								AND sev.EV_SEQ = FK5.FK5_SEQ
								AND sev.D_E_L_E_T_ = @IS_SPACE
						LEFT JOIN SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
							on  sez.EZ_FILIAL = sev.EV_FILIAL
								And sez.EZ_PREFIXO = sev.EV_PREFIXO
								And sez.EZ_NUM = sev.EV_NUM
								and sez.EZ_PARCELA = sev.EV_PARCELA
								and sez.EZ_TIPO = sev.EV_TIPO
								and sez.EZ_CLIFOR = sev.EV_CLIFOR
								and sez.EZ_LOJA = sev.EV_LOJA
								and sez.EZ_NATUREZ = sev.EV_NATUREZ
								and sez.EZ_IDENT = sev.EV_IDENT
								and sez.EZ_SEQ = sev.EV_SEQ
								and sez.D_E_L_E_T_ = @IS_SPACE
						LEFT JOIN SX5### sx5_consolidate
							ON sx5_consolidate.X5_FILIAL =  SUBSTRING(FK5.FK5_FILORI,1,@IN_TAMSX5) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSX5)
								AND sx5_consolidate.X5_TABELA = @IS_X5TAB
								AND sx5_consolidate.X5_CHAVE = stg_se2.E2_TIPO
								AND sx5_consolidate.D_E_L_E_T_ = @IS_SPACE
						INNER JOIN SA2### sa2 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
							on sa2.A2_FILIAL = SUBSTRING(stg_se2.E2_FILORIG, 1, @IN_TAMSA2) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSA2)
								and sa2.A2_COD = stg_se2.E2_FORNECE
								and sa2.A2_LOJA = stg_se2.E2_LOJA
								and sa2.D_E_L_E_T_ = @IS_SPACE
					WHERE ( FK5.FK5_DATA >= @param_DTINI AND FK5.FK5_DATA <= @param_DTFIM )
						AND FK5.FK5_TPDOC IN ( @IS_DOCBL, @IS_DOCVL, @IS_DOCES ) AND FK5.FK5_LOTE <> @IS_SPACE
						
				FOR READ ONLY

				open curPagar_BxLote_full_##
				fetch next from curPagar_BxLote_full_##
					into @F7I_ORIGIN,
							@fk5_S_T_A_M_P_,
							@fk5_Recno,
							@EZ_MSUID,
							@EV_MSUID,
							@E2_FILORIG,
							@F7I_EMISSA,
							@F7I_EMIS1,
							@F7I_HIST,
							@F7I_TIPO,
							@F7I_TIPDSC,
							@F7I_PREFIX,
							@F7I_NUM,
							@F7I_PARCEL,
							@E2_MOEDA,
							@FK5_MOEDA,
							@F7I_VENCTO,
							@F7I_VENCRE,
							@F7I_DTPGTO,
							@F7I_BANCO,
							@F7I_AGENCI,
							@F7I_CONTA,
							@F7I_FLBENF,
							@F7I_CDBENF,
							@F7I_LJBENF,
							@F7I_NBENEF,
							@F7I_IDMOV,
							@F7I_CCUSTO,
							@ED_DEBITO,
							@ED_CREDIT,
							@F7I_DTDISP,
							@F7I_NATURE,
							@F7I_NATRAT,
							@F7I_CCDRAT,
							@F7I_DEBITO,
							@F7I_CCC,
							@F7I_CCD,
							@F7I_ITEMCT,
							@F7I_ITEMD,
							@F7I_ITEMC,
							@F7I_CLVL,
							@F7I_CLVLDB,
							@F7I_CLVLCR,
							@F7I_NUMBOR,
							@F7I_HISTOR,
							@FK2_IDFK2,
							@FK5_RECPAG,
							@FK2_VALOR,
							@FK2_VLMOE2,
							@F7I_CONVBS,
							@F7I_CREDIT,
							@EV_SITUACA,
							@EV_VALOR,
							@EZ_VALOR
							--#cursorflex
							--#cursorrateio
				While ( (@@fetch_Status  = 0 ) )
					Begin
						select @REGVALIDO = 'S'

						If (@EV_SITUACA <> @IS_SPACE)
							Begin
								If @FK5_RECPAG = @IS_RECPAGP and @EV_SITUACA = @IS_SIT_E
									Begin
										select @REGVALIDO = 'S'
									End
								Else
									Begin 
										If @FK5_RECPAG = @IS_RECPAGR and @EV_SITUACA = @IS_SIT_X
											Begin
												select @REGVALIDO = 'S'
											End
										Else
											Begin
												select @REGVALIDO = 'N'
											End
									End
							End

						If ( @REGVALIDO = 'S' )
							Begin
								select @F7I_EXTCDH = @FK2_IDFK2
								select @F7I_VLPROP = 0
								select @F7I_VLRCNT = 0

								If @F7I_HIST Is Null Or @F7I_HIST = @IS_SPACE
									Begin
										select @F7I_HIST = @IS_SPACE
									End
								
								If @F7I_TIPDSC Is Null Or @F7I_TIPDSC = @IS_SPACE
									Begin
										select @F7I_TIPDSC = @IS_SPACE
									End
								
								If @F7I_NATRAT Is Null Or @F7I_NATRAT = @IS_SPACE
									Begin
										select @F7I_NATRAT = @IS_SPACE
									End
								
								If @F7I_CCDRAT Is Null Or @F7I_CCDRAT = @IS_SPACE
									Begin
										select @F7I_CCDRAT = @IS_SPACE
									End

								If ( @FK5_RECPAG = 'R' AND @ED_CREDIT <> @IS_SPACE )
									Begin 
										exec XFILIAL_## 'CT1', @E2_FILORIG, @filialCT1 OutPut
										Select @F7I_CNTCTB = CT1_CONTA , @F7I_DSCCTB = SUBSTRING(CT1_DESC01,1,40) , @F7I_NATCTA = CT1_NATCTA FROM CT1### Where CT1_FILIAL = @filialCT1 AND CT1_CONTA = @ED_CREDIT AND D_E_L_E_T_ = @IS_SPACE
									End
								Else
									Begin 			
										If ( @FK5_RECPAG = 'P' AND @ED_DEBITO <> @IS_SPACE)
											Begin
												exec XFILIAL_## 'CT1', @E2_FILORIG, @filialCT1 OutPut
												Select @F7I_CNTCTB = CT1_CONTA , @F7I_DSCCTB = SUBSTRING(CT1_DESC01,1,40) , @F7I_NATCTA = CT1_NATCTA FROM CT1### Where CT1_FILIAL = @filialCT1 AND CT1_CONTA = @ED_DEBITO AND D_E_L_E_T_ = @IS_SPACE
											End
									End

								If ( @F7I_CNTCTB = @IS_SPACE or @F7I_CNTCTB is null )
									Begin
										select @F7I_CNTCTB = '0'
									End

								If (@F7I_HIST = @IS_SPACE)
									Begin
										select @F7I_HIST = 'SEM DESCRICAO'
									End
								
								If(  @FK5_RECPAG ='P' )
									Begin 
										select @F7I_TPEVNT = 'S'
									End
								Else
									Begin
										select @F7I_TPEVNT = 'E'
									End
								
								
								If ( @FK2_VLMOE2 = 0 )
									Begin 
										select @F7I_SALDO = @FK2_VALOR
									End
								Else
									Begin
										select @F7I_SALDO = @FK2_VLMOE2
									End

								If (  @EZ_MSUID is not null )
									Begin 
										select @F7I_EXTCDD = @EZ_MSUID
										select @F7I_VLPROP = @EZ_VALOR
									End
								Else
									Begin
										If ( @EV_MSUID is not null )
											Begin 
												select @F7I_EXTCDD = @EV_MSUID
												select @F7I_VLPROP = @EV_VALOR
											End
										Else
											Begin
												select @F7I_EXTCDD = @FK2_IDFK2
												select @F7I_VLPROP = @F7I_SALDO
											End
									End
								
								select @F7I_VLRCNT = @FK2_VALOR
								select @F7I_VLCRUZ = @FK2_VALOR
								select @F7I_CONVBS = ROUND(@F7I_CONVBS, @DecCONVBS)
								select @F7I_CONVCT = @F7I_CONVBS

								If ( @F7I_CONVBS = 0 )
									Begin
										select @F7I_FXRTBS = '0'
										select @F7I_FXRTCT = '0'
									End
								Else			
									Begin
										select @F7I_FXRTBS = '1'
										select @F7I_FXRTCT = '1'
									End	
						
								If (@F7I_MOEDA <> @MOEDA)
									Begin
										select @MOEDA = @F7I_MOEDA
										select @F7I_DSCMDA = (SELECT DSCMDA.X6_CONTEUD
																FROM SX6### DSCMDA 
																WHERE RTRIM(DSCMDA.X6_VAR) = @IS_MVMOEDA || RTRIM(CAST(@F7I_MOEDA AS CHAR(2)))
																					AND DSCMDA.D_E_L_E_T_ = @IS_SPACE )
									End

								select @MOEDFK5 = ISNULL(CAST(@FK5_MOEDA AS INTEGER), 0)
								
								If ( @F7I_MOEDB <> @MOEDFK5 )
									Begin
										select @MOEDB = @MOEDFK5
										select @F7I_MOEDB = @MOEDFK5
										select @F7I_DSCMDB = (SELECT DSCMDB.X6_CONTEUD
																FROM SX6### DSCMDB 
																WHERE RTRIM(DSCMDB.X6_VAR) = @IS_MVMOEDA || RTRIM(CAST(@F7I_MOEDB AS CHAR(2)))
																					AND DSCMDB.D_E_L_E_T_ = @IS_SPACE )
									End 
								
								If ( @fk5_S_T_A_M_P_ is null )
									Begin 
										select @cFk5_STAMP = @delTransactTime
									End	
								Else 
									Begin
										select @cFk5_STAMP = CONVERT(CHAR(26), @fk5_S_T_A_M_P_, 121)
									End 	
								
								select @cF7I_STAMP = @cFk5_STAMP
								
								--correcao para arredondamento de conversao ocorre apenas em mssql
								##IF_001({|| Trim(TcGetDb()) == "MSSQL" })
									IF  @cFk5_STAMP  NOT LIKE '%.%'
										BEGIN 
											SELECT @cFk5_STAMP = TRIM(@cFk5_STAMP)  + '.000' 
										END
									IF  @cF7I_STAMP NOT LIKE '%.%'
										BEGIN 
											SELECT @cF7I_STAMP = TRIM(@cF7I_STAMP) + '.000' 
										END
								##ENDIF_001
									
								select @F7I_DSCCCT = @IS_SPACE
								IF @F7I_CCUSTO <> @IS_SPACE
									Begin
										exec XFILIAL_## 'CTT', @E2_FILORIG, @filialCTT OutPut
										SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @F7I_CCUSTO AND D_E_L_E_T_ = @IS_SPACE)
									End

								select @param_COMPANIA = SUBSTRING(@E2_FILORIG,1, @IN_TAMEMP )
								select @param_COD_UNID = SUBSTRING(@E2_FILORIG,@IN_TAMEMP+1, @IN_TAMUNIT)
								select @param_COD_FIL = SUBSTRING(@E2_FILORIG, @IN_TAMEMP + 1 + @IN_TAMUNIT, @IN_TAMFIL)

								##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
								insert into F7I### (
									F7I_ORIGIN,
									F7I_EXTCDH,
									F7I_EXTCDD,
									F7I_EMISSA,
									F7I_EMIS1,
									F7I_HIST,
									F7I_TIPO,
									F7I_TIPDSC,
									F7I_PREFIX,
									F7I_NUM,
									F7I_PARCEL,
									F7I_MOEDA,
									F7I_DSCMDA,
									F7I_MOEDB,
									F7I_DSCMDB,
									F7I_VENCTO,
									F7I_VENCRE,
									F7I_DTPGTO,
									F7I_BANCO,
									F7I_AGENCI,
									F7I_CONTA,
									F7I_FLBENF,
									F7I_CDBENF,
									F7I_LJBENF,
									F7I_NBENEF,
									F7I_MOVIM,
									F7I_DSCMOV,
									F7I_IDMOV,
									F7I_VLCRUZ,
									F7I_CNTCTB,
									F7I_DSCCTB,
									F7I_NATCTA,
									F7I_DSCCCT,
									F7I_DTDISP,
									F7I_NATURE,
									F7I_NATRAT,
									F7I_CCDRAT,
									F7I_DEBITO,
									F7I_CCC,
									F7I_CCD,
									F7I_ITEMCT,
									F7I_ITEMD,
									F7I_ITEMC,
									F7I_CLVL,
									F7I_CLVLDB,
									F7I_CLVLCR,
									F7I_NUMBOR,
									F7I_HISTOR,
									F7I_CONVBS,
									F7I_CONVCT,
									F7I_VLPROP,
									F7I_ORGSYT,
									F7I_GRPEMP,
									F7I_EMPR,
									F7I_UNID,
									F7I_FILNEG,
									F7I_STAMP,
									F7I_SALDO,
									F7I_TPEVNT,
									F7I_TPBENF,
									F7I_ORBENF,
									F7I_FXRTBS,
									F7I_FXRTCT,
									F7I_CCUSTO,
									F7I_CREDIT,
									F7I_VLRCNT,
									F7I_IDPROC
									--#insertflex
									--#insertrateio
								) Values (
									@F7I_ORIGIN,
									@F7I_EXTCDH,
									@F7I_EXTCDD,
									@F7I_EMISSA,
									@F7I_EMIS1,
									@F7I_HIST,
									@F7I_TIPO,
									@F7I_TIPDSC,
									@F7I_PREFIX,
									@F7I_NUM,
									@F7I_PARCEL,
									@F7I_MOEDA,
									IsNull(SUBSTRING(@F7I_DSCMDA,1,10), @IS_SPACE),
									@F7I_MOEDB,
									IsNull(SUBSTRING(@F7I_DSCMDB,1,10), @IS_SPACE),
									@F7I_VENCTO,
									@F7I_VENCRE,
									@F7I_DTPGTO,
									@F7I_BANCO,
									@F7I_AGENCI,
									@F7I_CONTA,
									@F7I_FLBENF,
									@F7I_CDBENF,
									@F7I_LJBENF,
									@F7I_NBENEF,
									@IS_SPACE,--@F7I_MOVIM
									@IS_SPACE,--@F7I_DSCMOV,
									@F7I_IDMOV,
									@F7I_VLCRUZ,
									@F7I_CNTCTB,
									IsNull(SUBSTRING(@F7I_DSCCTB,1,40),@IS_SPACE),
									IsNull(@F7I_NATCTA,@IS_SPACE),
									IsNull(SUBSTRING(@F7I_DSCCCT,1,40),@IS_SPACE),
									@F7I_DTDISP,
									@F7I_NATURE,
									@F7I_NATRAT,
									@F7I_CCDRAT,
									@F7I_DEBITO,
									@F7I_CCC,
									@F7I_CCD,
									@F7I_ITEMCT,
									@F7I_ITEMD,
									@F7I_ITEMC,
									@F7I_CLVL,
									@F7I_CLVLDB,
									@F7I_CLVLCR,
									@F7I_NUMBOR,
									@F7I_HISTOR,
									@F7I_CONVBS,
									@F7I_CONVCT,
									@F7I_VLPROP,
									@F7I_ORGSYT,
									IsNull(@IN_GROUPEMPRESA,@IS_SPACE),
									IsNull(@param_COMPANIA,@IS_SPACE),
									IsNull(@param_COD_UNID,@IS_SPACE),
									IsNull(@param_COD_FIL,@IS_SPACE),
									@cF7I_STAMP,
									@F7I_SALDO,
									@F7I_TPEVNT,
									@F7I_TPBENF,
									@F7I_ORBENF,
									@F7I_FXRTBS,
									@F7I_FXRTCT,
									@F7I_CCUSTO,
									@F7I_CREDIT,
									@F7I_VLRCNT,
									@ID_PROCESSO
									--#variaveisflex
									--#variaveisrateio
								)
								##CHECK_TRANSACTION_COMMIT

								INSERT INTO F7J###  (F7J_FILIAL, F7J_ALIAS, F7J_RECNO, F7J_STAMP) 
								VALUES (@IS_SPACE, @F7J_ALIAS, @fk5_Recno, @cFk5_STAMP)
								
								SELECT @CONTADOR = @CONTADOR + 1
							End
						fetch next from curPagar_BxLote_full_##
							into @F7I_ORIGIN,
								@fk5_S_T_A_M_P_,
								@fk5_Recno,
								@EZ_MSUID,
								@EV_MSUID,
								@E2_FILORIG,
								@F7I_EMISSA,
								@F7I_EMIS1,
								@F7I_HIST,
								@F7I_TIPO,
								@F7I_TIPDSC,
								@F7I_PREFIX,
								@F7I_NUM,
								@F7I_PARCEL,
								@E2_MOEDA,
								@FK5_MOEDA,
								@F7I_VENCTO,
								@F7I_VENCRE,
								@F7I_DTPGTO,
								@F7I_BANCO,
								@F7I_AGENCI,
								@F7I_CONTA,
								@F7I_FLBENF,
								@F7I_CDBENF,
								@F7I_LJBENF,
								@F7I_NBENEF,
								@F7I_IDMOV,
								@F7I_CCUSTO,
								@ED_DEBITO,
								@ED_CREDIT,
								@F7I_DTDISP,
								@F7I_NATURE,
								@F7I_NATRAT,
								@F7I_CCDRAT,
								@F7I_DEBITO,
								@F7I_CCC,
								@F7I_CCD,
								@F7I_ITEMCT,
								@F7I_ITEMD,
								@F7I_ITEMC,
								@F7I_CLVL,
								@F7I_CLVLDB,
								@F7I_CLVLCR,
								@F7I_NUMBOR,
								@F7I_HISTOR,
								@FK2_IDFK2,
								@FK5_RECPAG,
								@FK2_VALOR,
								@FK2_VLMOE2,
								@F7I_CONVBS,
								@F7I_CREDIT,
								@EV_SITUACA,
								@EV_VALOR,
								@EZ_VALOR
								--#cursorflex
								--#cursorrateio
					End
				close curPagar_BxLote_full_##
				deallocate curPagar_BxLote_full_##
			End
		Else
			Begin
				DECLARE curPagar_BxLote_delta_## insensitive cursor for
					SELECT  '##CTE_FK2' 			AS F7I_ORIGIN,
						FK5.S_T_A_M_P_ 				AS fk5_S_T_A_M_P_,
						FK5.R_E_C_N_O_				AS fk5_Recno,
						sez.EZ_MSUID				AS EZ_MSUID,
						sev.EV_MSUID				AS EV_MSUID,
						stg_se2.E2_FILORIG 			AS E2_FILORIG,
						stg_se2.E2_EMISSAO 			AS F7I_EMISSA,
						stg_se2.E2_EMIS1 			AS F7I_EMIS1,
						stg_se2.E2_HIST 			AS F7I_HIST,
						stg_se2.E2_TIPO 			AS F7I_TIPO,
						sx5_consolidate.X5_DESCRI	AS F7I_TIPDSC,
						stg_se2.E2_PREFIXO			AS F7I_PREFIX,
						stg_se2.E2_NUM				AS F7I_NUM,
						stg_se2.E2_PARCELA			AS F7I_PARCEL,
						stg_se2.E2_MOEDA			AS E2_MOEDA,
						FK5.FK5_MOEDA				AS FK5_MOEDA,
						stg_se2.E2_VENCTO			AS F7I_VENCTO,
						stg_se2.E2_VENCREA			AS F7I_VENCRE,
						FK5.FK5_DATA				AS F7I_DTPGTO,
						FK5.FK5_BANCO				AS F7I_BANCO,
						FK5.FK5_AGENCI				AS F7I_AGENCI,
						FK5.FK5_CONTA				AS F7I_CONTA,
						sa2.A2_FILIAL				AS F7I_FLBENF,
						stg_se2.E2_FORNECE 			AS F7I_CDBENF,
						stg_se2.E2_LOJA 			AS F7I_LJBENF,
						stg_se2.E2_NOMFOR 			AS F7I_NBENEF,
						FK5.FK5_IDMOV				AS F7I_IDMOV,
						sed.ED_CCD					AS F7I_CCUSTO,
						sed.ED_DEBITO				AS ED_DEBITO,
						sed.ED_CREDIT				AS ED_CREDIT,
						FK5.FK5_DTDISP				AS F7I_DTDISP,
						stg_se2.E2_NATUREZ			AS F7I_NATURE,
						sev.EV_NATUREZ				AS F7I_NATRAT,
						sez.EZ_CCUSTO				AS F7I_CCDRAT,
						stg_se2.E2_DEBITO			AS F7I_DEBITO,
						stg_se2.E2_CCC				AS F7I_CCC,
						stg_se2.E2_CCD				AS F7I_CCD,
						stg_se2.E2_ITEMCTA			AS F7I_ITEMCT,
						stg_se2.E2_ITEMD			AS F7I_ITEMD,
						stg_se2.E2_ITEMC			AS F7I_ITEMC,
						stg_se2.E2_CLVL				AS F7I_CLVL,
						stg_se2.E2_CLVLDB			AS F7I_CLVLDB,
						stg_se2.E2_CLVLCR			AS F7I_CLVLCR,
						stg_se2.E2_NUMBOR			AS F7I_NUMBOR,
						FK5.FK5_HISTOR				AS F7I_HISTOR,
						fk2.FK2_IDFK2				AS FK2_IDFK2,
						FK5.FK5_RECPAG				AS FK5_RECPAG,
						fk2.FK2_VALOR 				AS FK2_VALOR,
						fk2.FK2_VLMOE2				AS FK2_VLMOE2,
						FK5.FK5_TXMOED				AS F7I_CONVBS,
						stg_se2.E2_CREDIT			AS F7I_CREDIT,
						sev.EV_SITUACA				AS EV_SITUACA,
						sev.EV_VALOR				AS EV_VALOR,
						sez.EZ_VALOR				AS EZ_VALOR
						,'#campoflex' as campoflex
						,'#camposflexrateio' as camposflexrateio
					FROM FK5### FK5 LEFT JOIN CT2### ON CT2_FILIAL = ' '  -- ct2 removido sempre pelo parser
						INNER JOIN fk2_one fk2 
							on fk2.FK2_FILIAL = FK5.FK5_FILIAL
								and fk2.FK2_LOTE = FK5.FK5_LOTE
								and 'X' = 'CASE_FK2_FK5_TPDOC'
								and fk2rn = 1
						INNER JOIN FK7### fk7  LEFT JOIN CT2### ON CT2_FILIAL = ' '  -- ct2 removido sempre pelo parser
							ON fk7.FK7_FILIAL = fk2.FK2_FILIAL
								AND fk7.FK7_IDDOC = fk2.FK2_IDDOC
								AND fk7.FK7_ALIAS = @IS_FK7ALIAS
						INNER JOIN SE2### stg_se2  LEFT JOIN CT2### ON CT2_FILIAL = ' '  -- ct2 removido sempre pelo parser
							ON	stg_se2.E2_FILIAL = fk7.FK7_FILTIT
								AND stg_se2.E2_PREFIXO = fk7.FK7_PREFIX
								AND stg_se2.E2_NUM = fk7.FK7_NUM
								AND stg_se2.E2_PARCELA = fk7.FK7_PARCEL
								AND stg_se2.E2_TIPO = fk7.FK7_TIPO
								AND stg_se2.E2_FORNECE = fk7.FK7_CLIFOR
								AND stg_se2.E2_LOJA = fk7.FK7_LOJA
								AND stg_se2.D_E_L_E_T_ = fk7.D_E_L_E_T_
								AND stg_se2.E2_TIPO NOT LIKE @IS_TP_IMP 
								AND stg_se2.E2_TIPO <>  @IS_TP_PR
						INNER JOIN SED### sed
							ON sed.ED_FILIAL = SUBSTRING(FK5.FK5_FILORI,1,@IN_TAMSED) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSED)
								AND sed.ED_CODIGO = stg_se2.E2_NATUREZ
								AND sed.D_E_L_E_T_ = @IS_SPACE
						INNER JOIN SA2### sa2 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
							on sa2.A2_FILIAL = SUBSTRING(stg_se2.E2_FILORIG, 1, @IN_TAMSA2) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSA2)
								and sa2.A2_COD = stg_se2.E2_FORNECE
								and sa2.A2_LOJA = stg_se2.E2_LOJA
								and sa2.D_E_L_E_T_ = @IS_SPACE
						LEFT JOIN SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
							ON sev.EV_FILIAL = stg_se2.E2_FILIAL
								AND sev.EV_PREFIXO = stg_se2.E2_PREFIXO
								AND sev.EV_NUM = stg_se2.E2_NUM
								AND sev.EV_PARCELA = stg_se2.E2_PARCELA
								AND sev.EV_TIPO = stg_se2.E2_TIPO
								AND sev.EV_CLIFOR = stg_se2.E2_FORNECE
								AND sev.EV_LOJA = stg_se2.E2_LOJA
								AND sev.EV_IDENT = @IS_EVIDENT2
								AND sev.EV_SEQ = FK5.FK5_SEQ
								AND sev.D_E_L_E_T_ = stg_se2.D_E_L_E_T_
						LEFT JOIN SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
							on  sez.EZ_FILIAL = sev.EV_FILIAL
								And sez.EZ_PREFIXO = sev.EV_PREFIXO
								And sez.EZ_NUM = sev.EV_NUM
								and sez.EZ_PARCELA = sev.EV_PARCELA
								and sez.EZ_TIPO = sev.EV_TIPO
								and sez.EZ_CLIFOR = sev.EV_CLIFOR
								and sez.EZ_LOJA = sev.EV_LOJA
								and sez.EZ_NATUREZ = sev.EV_NATUREZ
								and sez.EZ_IDENT = sev.EV_IDENT
								and sez.EZ_SEQ = sev.EV_SEQ
								and sez.D_E_L_E_T_ = sev.D_E_L_E_T_
						LEFT JOIN SX5### sx5_consolidate
							ON sx5_consolidate.X5_FILIAL =  SUBSTRING(FK5.FK5_FILORI,1,@IN_TAMSX5) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSX5)
								AND sx5_consolidate.X5_TABELA = @IS_X5TAB
								AND sx5_consolidate.X5_CHAVE = stg_se2.E2_TIPO
								AND sx5_consolidate.D_E_L_E_T_ = @IS_SPACE
						LEFT JOIN F7J### f7j
							ON f7j.F7J_ALIAS =  @F7J_ALIAS
								AND f7j.F7J_STAMP = CONVERT(CHAR(26), FK5.S_T_A_M_P_ , 121)
								AND f7j.F7J_RECNO = FK5.R_E_C_N_O_
					WHERE FK5.S_T_A_M_P_ > @maxStagingCounter AND f7j.F7J_RECNO is null
						AND FK5.FK5_LOTE <> @IS_SPACE AND FK5.FK5_TPDOC IN ( @IS_DOCBL, @IS_DOCVL, @IS_DOCES )
						
				FOR READ ONLY

				open curPagar_BxLote_delta_##
				fetch next from curPagar_BxLote_delta_##
					into @F7I_ORIGIN,
							@fk5_S_T_A_M_P_,
							@fk5_Recno,
							@EZ_MSUID,
							@EV_MSUID,
							@E2_FILORIG,
							@F7I_EMISSA,
							@F7I_EMIS1,
							@F7I_HIST,
							@F7I_TIPO,
							@F7I_TIPDSC,
							@F7I_PREFIX,
							@F7I_NUM,
							@F7I_PARCEL,
							@E2_MOEDA,
							@FK5_MOEDA,
							@F7I_VENCTO,
							@F7I_VENCRE,
							@F7I_DTPGTO,
							@F7I_BANCO,
							@F7I_AGENCI,
							@F7I_CONTA,
							@F7I_FLBENF,
							@F7I_CDBENF,
							@F7I_LJBENF,
							@F7I_NBENEF,
							@F7I_IDMOV,
							@F7I_CCUSTO,
							@ED_DEBITO,
							@ED_CREDIT,
							@F7I_DTDISP,
							@F7I_NATURE,
							@F7I_NATRAT,
							@F7I_CCDRAT,
							@F7I_DEBITO,
							@F7I_CCC,
							@F7I_CCD,
							@F7I_ITEMCT,
							@F7I_ITEMD,
							@F7I_ITEMC,
							@F7I_CLVL,
							@F7I_CLVLDB,
							@F7I_CLVLCR,
							@F7I_NUMBOR,
							@F7I_HISTOR,
							@FK2_IDFK2,
							@FK5_RECPAG,
							@FK2_VALOR,
							@FK2_VLMOE2,
							@F7I_CONVBS,
							@F7I_CREDIT,
							@EV_SITUACA,
							@EV_VALOR,
							@EZ_VALOR
							--#cursorflex
							--#cursorrateio
				While ( (@@fetch_Status  = 0 ) )
					Begin
						select @REGVALIDO = 'S'

						If (@EV_SITUACA <> @IS_SPACE)
							Begin
								If @FK5_RECPAG = @IS_RECPAGP and @EV_SITUACA = @IS_SIT_E
									Begin
										select @REGVALIDO = 'S'
									End
								Else
									Begin 
										If @FK5_RECPAG = @IS_RECPAGR and @EV_SITUACA = @IS_SIT_X
											Begin
												select @REGVALIDO = 'S'
											End
										Else
											Begin
												select @REGVALIDO = 'N'
											End
									End
							End

						If ( @REGVALIDO = 'S' )
							Begin
								select @F7I_EXTCDH = @FK2_IDFK2
								select @F7I_VLPROP = 0
								select @F7I_VLRCNT = 0

								If @F7I_HIST Is Null Or @F7I_HIST = @IS_SPACE
									Begin
										select @F7I_HIST = @IS_SPACE
									End
								
								If @F7I_TIPDSC Is Null Or @F7I_TIPDSC = @IS_SPACE
									Begin
										select @F7I_TIPDSC = @IS_SPACE
									End
								
								If @F7I_NATRAT Is Null Or @F7I_NATRAT = @IS_SPACE
									Begin
										select @F7I_NATRAT = @IS_SPACE
									End
								
								If @F7I_CCDRAT Is Null Or @F7I_CCDRAT = @IS_SPACE
									Begin
										select @F7I_CCDRAT = @IS_SPACE
									End

								If ( @FK5_RECPAG = 'R' AND @ED_CREDIT <> @IS_SPACE )
									Begin 
										exec XFILIAL_## 'CT1', @E2_FILORIG, @filialCT1 OutPut
										Select @F7I_CNTCTB = CT1_CONTA , @F7I_DSCCTB = SUBSTRING(CT1_DESC01,1,40) , @F7I_NATCTA = CT1_NATCTA FROM CT1### Where CT1_FILIAL = @filialCT1 AND CT1_CONTA = @ED_CREDIT AND D_E_L_E_T_ = @IS_SPACE
									End
								Else
									Begin 			
										If ( @FK5_RECPAG = 'P' AND @ED_DEBITO <> @IS_SPACE)
											Begin
												exec XFILIAL_## 'CT1', @E2_FILORIG, @filialCT1 OutPut
												Select @F7I_CNTCTB = CT1_CONTA , @F7I_DSCCTB = SUBSTRING(CT1_DESC01,1,40) , @F7I_NATCTA = CT1_NATCTA FROM CT1### Where CT1_FILIAL = @filialCT1 AND CT1_CONTA = @ED_DEBITO AND D_E_L_E_T_ = @IS_SPACE
											End
									End

								If ( @F7I_CNTCTB = @IS_SPACE or @F7I_CNTCTB is null )
									Begin
										select @F7I_CNTCTB = '0'
									End

								If (@F7I_HIST = @IS_SPACE)
									Begin
										select @F7I_HIST = 'SEM DESCRICAO'
									End
								
								If(  @FK5_RECPAG ='P' )
									Begin 
										select @F7I_TPEVNT = 'S'
									End
								Else
									Begin
										select @F7I_TPEVNT = 'E'
									End
								
								
								If ( @FK2_VLMOE2 = 0 )
									Begin 
										select @F7I_SALDO = @FK2_VALOR
									End
								Else
									Begin
										select @F7I_SALDO = @FK2_VLMOE2
									End

								If (  @EZ_MSUID is not null )
									Begin 
										select @F7I_EXTCDD = @EZ_MSUID
										select @F7I_VLPROP = @EZ_VALOR
									End
								Else
									Begin
										If ( @EV_MSUID is not null )
											Begin 
												select @F7I_EXTCDD = @EV_MSUID
												select @F7I_VLPROP = @EV_VALOR
											End
										Else
											Begin
												select @F7I_EXTCDD = @FK2_IDFK2
												select @F7I_VLPROP = @F7I_SALDO
											End
									End
								
								select @F7I_VLRCNT = @FK2_VALOR
								select @F7I_VLCRUZ = @FK2_VALOR
								select @F7I_CONVBS = ROUND(@F7I_CONVBS, @DecCONVBS)
								select @F7I_CONVCT = @F7I_CONVBS

								If ( @F7I_CONVBS = 0 )
									Begin
										select @F7I_FXRTBS = '0'
										select @F7I_FXRTCT = '0'
									End
								Else			
									Begin
										select @F7I_FXRTBS = '1'
										select @F7I_FXRTCT = '1'
									End	

								If (@F7I_MOEDA <> @MOEDA)
									Begin
										select @MOEDA = @F7I_MOEDA
										select @F7I_DSCMDA = (SELECT DSCMDA.X6_CONTEUD
																FROM SX6### DSCMDA 
																WHERE RTRIM(DSCMDA.X6_VAR) = @IS_MVMOEDA || RTRIM(CAST(@F7I_MOEDA AS CHAR(2)))
																					AND DSCMDA.D_E_L_E_T_ = @IS_SPACE )
									End

								select @MOEDFK5 = ISNULL(CAST(@FK5_MOEDA AS INTEGER), 0)
								
								If ( @F7I_MOEDB <> @MOEDFK5 )
									Begin
										select @MOEDB = @MOEDFK5
										select @F7I_MOEDB = @MOEDFK5
										select @F7I_DSCMDB = (SELECT DSCMDB.X6_CONTEUD
																FROM SX6### DSCMDB 
																WHERE RTRIM(DSCMDB.X6_VAR) = @IS_MVMOEDA || RTRIM(CAST(@F7I_MOEDB AS CHAR(2)))
																					AND DSCMDB.D_E_L_E_T_ = @IS_SPACE )
									End 
								
								If ( @fk5_S_T_A_M_P_ is null )
									Begin 
										select @cFk5_STAMP = @delTransactTime
									End	
								Else 
									Begin
										select @cFk5_STAMP = CONVERT(CHAR(26), @fk5_S_T_A_M_P_, 121)
									End 	
								
								select @cF7I_STAMP = @cFk5_STAMP
								
								--correcao para arredondamento de conversao ocorre apenas em mssql
								##IF_001({|| Trim(TcGetDb()) == "MSSQL" })
									IF  @cFk5_STAMP  NOT LIKE '%.%'
										BEGIN 
											SELECT @cFk5_STAMP = TRIM(@cFk5_STAMP)  + '.000' 
										END
									IF  @cF7I_STAMP NOT LIKE '%.%'
										BEGIN 
											SELECT @cF7I_STAMP = TRIM(@cF7I_STAMP) + '.000' 
										END
								##ENDIF_001
									
								select @F7I_DSCCCT = @IS_SPACE
								IF @F7I_CCUSTO <> @IS_SPACE
									Begin
										exec XFILIAL_## 'CTT', @E2_FILORIG, @filialCTT OutPut
										SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @F7I_CCUSTO AND D_E_L_E_T_ = @IS_SPACE)
									End

								select @param_COMPANIA = SUBSTRING(@E2_FILORIG,1, @IN_TAMEMP )
								select @param_COD_UNID = SUBSTRING(@E2_FILORIG,@IN_TAMEMP+1, @IN_TAMUNIT)
								select @param_COD_FIL = SUBSTRING(@E2_FILORIG, @IN_TAMEMP + 1 + @IN_TAMUNIT, @IN_TAMFIL)

								##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
								insert into F7I### (
									F7I_ORIGIN,
									F7I_EXTCDH,
									F7I_EXTCDD,
									F7I_EMISSA,
									F7I_EMIS1,
									F7I_HIST,
									F7I_TIPO,
									F7I_TIPDSC,
									F7I_PREFIX,
									F7I_NUM,
									F7I_PARCEL,
									F7I_MOEDA,
									F7I_DSCMDA,
									F7I_MOEDB,
									F7I_DSCMDB,
									F7I_VENCTO,
									F7I_VENCRE,
									F7I_DTPGTO,
									F7I_BANCO,
									F7I_AGENCI,
									F7I_CONTA,
									F7I_FLBENF,
									F7I_CDBENF,
									F7I_LJBENF,
									F7I_NBENEF,
									F7I_MOVIM,
									F7I_DSCMOV,
									F7I_IDMOV,
									F7I_VLCRUZ,
									F7I_CNTCTB,
									F7I_DSCCTB,
									F7I_NATCTA,
									F7I_DSCCCT,
									F7I_DTDISP,
									F7I_NATURE,
									F7I_NATRAT,
									F7I_CCDRAT,
									F7I_DEBITO,
									F7I_CCC,
									F7I_CCD,
									F7I_ITEMCT,
									F7I_ITEMD,
									F7I_ITEMC,
									F7I_CLVL,
									F7I_CLVLDB,
									F7I_CLVLCR,
									F7I_NUMBOR,
									F7I_HISTOR,
									F7I_CONVBS,
									F7I_CONVCT,
									F7I_VLPROP,
									F7I_ORGSYT,
									F7I_GRPEMP,
									F7I_EMPR,
									F7I_UNID,
									F7I_FILNEG,
									F7I_STAMP,
									F7I_SALDO,
									F7I_TPEVNT,
									F7I_TPBENF,
									F7I_ORBENF,
									F7I_FXRTBS,
									F7I_FXRTCT,
									F7I_CCUSTO,
									F7I_CREDIT,
									F7I_VLRCNT,
									F7I_IDPROC
									--#insertflex
									--#insertrateio
								) Values (
									@F7I_ORIGIN,
									@F7I_EXTCDH,
									@F7I_EXTCDD,
									@F7I_EMISSA,
									@F7I_EMIS1,
									@F7I_HIST,
									@F7I_TIPO,
									@F7I_TIPDSC,
									@F7I_PREFIX,
									@F7I_NUM,
									@F7I_PARCEL,
									@F7I_MOEDA,
									IsNull(SUBSTRING(@F7I_DSCMDA,1,10), @IS_SPACE),
									@F7I_MOEDB,
									IsNull(SUBSTRING(@F7I_DSCMDB,1,10), @IS_SPACE),
									@F7I_VENCTO,
									@F7I_VENCRE,
									@F7I_DTPGTO,
									@F7I_BANCO,
									@F7I_AGENCI,
									@F7I_CONTA,
									@F7I_FLBENF,
									@F7I_CDBENF,
									@F7I_LJBENF,
									@F7I_NBENEF,
									@IS_SPACE,--@F7I_MOVIM
									@IS_SPACE,--@F7I_DSCMOV,
									@F7I_IDMOV,
									@F7I_VLCRUZ,
									@F7I_CNTCTB,
									IsNull(SUBSTRING(@F7I_DSCCTB,1,40),@IS_SPACE),
									IsNull(@F7I_NATCTA,@IS_SPACE),
									IsNull(SUBSTRING(@F7I_DSCCCT,1,40),@IS_SPACE),
									@F7I_DTDISP,
									@F7I_NATURE,
									@F7I_NATRAT,
									@F7I_CCDRAT,
									@F7I_DEBITO,
									@F7I_CCC,
									@F7I_CCD,
									@F7I_ITEMCT,
									@F7I_ITEMD,
									@F7I_ITEMC,
									@F7I_CLVL,
									@F7I_CLVLDB,
									@F7I_CLVLCR,
									@F7I_NUMBOR,
									@F7I_HISTOR,
									@F7I_CONVBS,
									@F7I_CONVCT,
									@F7I_VLPROP,
									@F7I_ORGSYT,
									IsNull(@IN_GROUPEMPRESA,@IS_SPACE),
									IsNull(@param_COMPANIA,@IS_SPACE),
									IsNull(@param_COD_UNID,@IS_SPACE),
									IsNull(@param_COD_FIL,@IS_SPACE),
									@cF7I_STAMP,
									@F7I_SALDO,
									@F7I_TPEVNT,
									@F7I_TPBENF,
									@F7I_ORBENF,
									@F7I_FXRTBS,
									@F7I_FXRTCT,
									@F7I_CCUSTO,
									@F7I_CREDIT,
									@F7I_VLRCNT,
									@ID_PROCESSO
									--#variaveisflex
									--#variaveisrateio
								)
								##CHECK_TRANSACTION_COMMIT

								INSERT INTO F7J###  (F7J_FILIAL, F7J_ALIAS, F7J_RECNO, F7J_STAMP) 
								VALUES (@IS_SPACE, @F7J_ALIAS, @fk5_Recno, @cFk5_STAMP)
								
								SELECT @CONTADOR = @CONTADOR + 1
							End
						fetch next from curPagar_BxLote_delta_##
							into @F7I_ORIGIN,
								@fk5_S_T_A_M_P_,
								@fk5_Recno,
								@EZ_MSUID,
								@EV_MSUID,
								@E2_FILORIG,
								@F7I_EMISSA,
								@F7I_EMIS1,
								@F7I_HIST,
								@F7I_TIPO,
								@F7I_TIPDSC,
								@F7I_PREFIX,
								@F7I_NUM,
								@F7I_PARCEL,
								@E2_MOEDA,
								@FK5_MOEDA,
								@F7I_VENCTO,
								@F7I_VENCRE,
								@F7I_DTPGTO,
								@F7I_BANCO,
								@F7I_AGENCI,
								@F7I_CONTA,
								@F7I_FLBENF,
								@F7I_CDBENF,
								@F7I_LJBENF,
								@F7I_NBENEF,
								@F7I_IDMOV,
								@F7I_CCUSTO,
								@ED_DEBITO,
								@ED_CREDIT,
								@F7I_DTDISP,
								@F7I_NATURE,
								@F7I_NATRAT,
								@F7I_CCDRAT,
								@F7I_DEBITO,
								@F7I_CCC,
								@F7I_CCD,
								@F7I_ITEMCT,
								@F7I_ITEMD,
								@F7I_ITEMC,
								@F7I_CLVL,
								@F7I_CLVLDB,
								@F7I_CLVLCR,
								@F7I_NUMBOR,
								@F7I_HISTOR,
								@FK2_IDFK2,
								@FK5_RECPAG,
								@FK2_VALOR,
								@FK2_VLMOE2,
								@F7I_CONVBS,
								@F7I_CREDIT,
								@EV_SITUACA,
								@EV_VALOR,
								@EZ_VALOR
								--#cursorflex
								--#cursorrateio
					End
				close curPagar_BxLote_delta_##
				deallocate curPagar_BxLote_delta_##
				
			End
	End

	Begin
		INSERT INTO F7P### (F7P_IDPROC, F7P_INICIO, F7P_FIM, F7P_QTDE, F7P_PROCES, F7P_LOTE) 
		VALUES (@ID_PROCESSO, @DATA_INICIO, CONVERT(Char(26), SYSDATETIME(), 121), @CONTADOR, @IS_FIN009C, @IN_LOTEPROC)
	End

	select @OUT_RESULTADO = '1'	
End