-- Author: Fabio Bizerra Florencio - Create date: 07/11/2026
CREATE PROCEDURE FIN008E_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
	@IN_TAMSED  Integer,
	@IN_TAMSX5  Integer,
	@IN_TAMSA1  Integer,
	@IN_TAMSEV  Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
	@IN_mdmTenantId char(32),
	@IN_DTINI char('F7I_EMIS1'),
	@IN_DTFIM char('F7I_EMIS1'),
    @IN_FULL char(1),
	@IN_TRANSACTION  Char(1),
	@DecCONVBS integer,
	@IN_maxStagingCounter Datetime,
	@IN_delTransactTime char(26),
	@IN_IDORIGEM char(32),
	@IN_LOTEPROC Char(6),
	@OUT_RESULTADO Char(1) OutPut )
AS

DECLARE @N_TAMTOTAL Integer
DECLARE @F7I_ORIGIN Char('F7I_ORIGIN')
DECLARE @cF7I_STAMP	Char('F7I_STAMP')
DECLARE @F7I_STAMP  Char('F7I_STAMP')
DECLARE @F7I_EXTCDH Char('F7I_EXTCDH')
DECLARE @F7I_EXTCDD Char('F7I_EXTCDD')
DECLARE @F7I_GRPEMP Char('F7I_GRPEMP')
DECLARE @F7I_EMPR Char('F7I_EMPR')
DECLARE @F7I_UNID Char('F7I_UNID')
DECLARE @F7I_FILNEG Char('F7I_FILNEG')
DECLARE @F7I_ORGSYT Char('F7I_ORGSYT')
DECLARE @F7I_EMISSA Char('F7I_EMISSA')
DECLARE @F7I_EMIS1 Char('F7I_EMIS1')
DECLARE @F7I_HIST Char('F7I_HIST')
DECLARE @F7I_TIPO Char('F7I_TIPO')
DECLARE @F7I_TIPDSC Char('F7I_TIPDSC')
DECLARE @F7I_PREFIX Char('F7I_PREFIX')
DECLARE @F7I_NUM Char('F7I_NUM')
DECLARE @F7I_PARCEL Char('F7I_PARCEL')
DECLARE @F7I_DSCMDA Char('F7I_DSCMDA')
DECLARE @F7I_DSCMDB Char('F7I_DSCMDB')
DECLARE @F7I_MOEDA Integer
DECLARE @MOEDA Integer
DECLARE @F7I_MOEDB Integer
DECLARE @MOEDB Integer
DECLARE @F7I_VENCTO Char('F7I_VENCTO')
DECLARE @F7I_VENCRE Char('F7I_VENCRE')
DECLARE @F7I_DTPGTO Char('F7I_DTPGTO')
DECLARE @F7I_TPEVNT Char('F7I_TPEVNT')
DECLARE @F7I_BANCO Char('F7I_BANCO')
DECLARE @F7I_AGENCI Char('F7I_AGENCI')
DECLARE @F7I_CONTA Char('F7I_CONTA')
DECLARE @F7I_FLBENF Char('F7I_FLBENF')
DECLARE @F7I_CDBENF Char('F7I_CDBENF')
DECLARE @F7I_LJBENF Char('F7I_LJBENF')
DECLARE @F7I_NBENEF Char('E1_NOMCLI')
DECLARE @F7I_TPBENF Char('F7I_TPBENF')
DECLARE @F7I_ORBENF Char('F7I_ORBENF')
DECLARE @F7I_MOVIM Char('F7I_MOVIM')
DECLARE @F7I_DSCMOV Char('F7I_DSCMOV')
DECLARE @FRVCOD Char('F7I_MOVIM')
DECLARE @F7I_IDMOV Char('F7I_IDMOV')
DECLARE @F7I_SALDO Float
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
DECLARE @F7I_INTEGR Char('F7I_INTEGR')
DECLARE @F7I_DTDISP Char('F7I_DTDISP')
DECLARE @F7I_NATURE Char('F7I_NATURE')
DECLARE @F7I_NATRAT Char('F7I_NATRAT')
DECLARE @F7I_CCDRAT Char('F7I_CCDRAT')
DECLARE @F7I_DEBITO Char('F7I_DEBITO')
DECLARE @F7I_CCD Char('F7I_CCD')
DECLARE @F7I_CCC Char('F7I_CCC')
DECLARE @F7I_ITEMCT Char('F7I_ITEMCT')
DECLARE @F7I_ITEMD Char('F7I_ITEMD')
DECLARE @F7I_ITEMC Char('F7I_ITEMC')
DECLARE @F7I_CLVL Char('F7I_CLVL')
DECLARE @F7I_CLVLDB Char('F7I_CLVLDB')
DECLARE @F7I_CLVLCR Char('F7I_CLVLCR')
DECLARE @F7I_NUMBOR Char('F7I_NUMBOR')
DECLARE @F7I_HISTOR Char('F7I_HISTOR')
DECLARE @F7I_CREDIT Char('F7I_CREDIT')
DECLARE @filialCTT Char('CTT_FILIAL')
DECLARE @filialCT1 char('CT1_FILIAL')
DECLARE @DTINI char('F7I_EMIS1')
DECLARE @DTFIM char('F7I_EMIS1')
DECLARE @COMPANIA char('##COMPANIA')
DECLARE @COD_UNID char('##COD_UNID')
DECLARE @COD_FIL char('##COD_FIL')
DECLARE @EZ_MSUID Char('EZ_MSUID')
DECLARE @EV_MSUID Char('EV_MSUID')
DECLARE @EV_SITUACA CHAR('EV_SITUACA')
DECLARE @E1_FILORIG Char('E1_FILORIG')
DECLARE @E1_TIPO Char('E1_TIPO')
DECLARE @CT1_CONTA Char('CT1_CONTA')
DECLARE @FK5_RECPAG Char('FK5_RECPAG')
DECLARE @E1_MOEDA Integer
DECLARE @FK5_MOEDA Char('FK5_MOEDA')
DECLARE @MOEDFK5 Integer
DECLARE @FK5_VALOR Float
DECLARE @FK5_VLMOE2	Float
DECLARE @EZ_VALOR Float
DECLARE @EV_VALOR Float
DECLARE @E1_CCUSTO Char('E1_CCUSTO')
DECLARE @ED_DEBITO	Char('ED_DEBITO')
DECLARE @ED_CREDIT	Char('ED_CREDIT')
DECLARE @maxStagingCounter Datetime
DECLARE @fk5_S_T_A_M_P_ Datetime
DECLARE @cFk5_STAMP char(26)
DECLARE @fk5_Recno Integer
DECLARE @delTransactTime char(26)
DECLARE @cStamp char('F7J_STAMP')
DECLARE @IS_SPACE char(1)
DECLARE @IS_COMRAT char(1)
DECLARE @IS_SEMRAT char(1)
DECLARE @IS_FK7ALIAS char('FK7_ALIAS')
DECLARE @IS_TP_PR char('FK7_TIPO')
DECLARE @IS_TP_RA char('FK7_TIPO')
DECLARE @IS_TP_ABT char(2)
DECLARE @IS_X5TAB CHAR('X5_TABELA')
DECLARE @IS_EVIDENT CHAR('EV_IDENT')
DECLARE @IS_MOTLIQ char('FK1_MOTBX')
DECLARE @IS_MOTCEC char('FK1_MOTBX')
DECLARE @IS_MOTCMP char('FK1_MOTBX')
DECLARE @IS_FINA740 char("FK1_ORIGEM")
DECLARE @IS_FINA070 char("FK1_ORIGEM")
DECLARE @IS_RECPAGP CHAR(1)
DECLARE @IS_RECPAGR CHAR(1)
DECLARE @IS_SIT_X CHAR(1)
DECLARE @IS_SIT_E CHAR(1)
DECLARE @IS_MVMOEDA VARCHAR(10)
DECLARE @BSCFILIAL   char(50) 			
DECLARE @nTAMFWI Integer     
DECLARE @IS_FULL CHAR(1)
DECLARE @IS_F7J_ALIAS CHAR(3)    
DECLARE @IS_FIN008E char(7)
DECLARE @ID_PROCESSO char(32)
DECLARE @DATA_INICIO char(26)
DECLARE @CONTADOR Integer
DECLARE @REGVALIDO char(1)
declare flex char(1)

Begin
	select @F7I_ORGSYT = 'RR' 	
	select @F7I_TPEVNT = 'S'
	select @F7I_TPBENF = '1'
	select @F7I_ORBENF = 'CR'
	select @F7I_SALDO  = 0
	select @F7I_VLPROP = 0
	select @F7I_FXRTBS = 0
	select @F7I_VLRCNT = 0
	select @F7I_FXRTCT = 0
	select @F7I_MOEDA = 0
	select @F7I_MOEDB = 0
	select @MOEDA = 0
	select @MOEDB = 0
	select @MOEDFK5 = 0
	select @IS_SPACE  = ' '
	select @FRVCOD = @IS_SPACE
	select @IS_COMRAT = '1'
	select @IS_SEMRAT = '2'
	select @IS_FK7ALIAS = 'SE1'
	select @IS_TP_PR  = 'PR '
	select @IS_TP_RA  = 'RA '
	select @IS_TP_ABT = '%-'
	select @IS_X5TAB  = '05'
	select @IS_EVIDENT = '2'
	select @IS_RECPAGP = 'P'
	select @IS_RECPAGR = 'R'
	select @IS_SIT_X = 'X'
	select @IS_SIT_E = 'E'
	select @IS_MVMOEDA = 'MV_MOEDA'
	select @IS_MOTLIQ  = 'LIQ'
	select @IS_MOTCEC  = 'CEC'
	select @IS_MOTCMP = 'CMP'
	select @IS_FINA740 = 'FINA740 '
	select @IS_FINA070 = 'FINA070 '
	select @IS_FULL = @IN_FULL
	select @DTINI  = @IN_DTINI
	select @DTFIM  = @IN_DTFIM
	select @IS_F7J_ALIAS = 'CRR'
	select @IS_FIN008E = 'FIN008E'
	select @DATA_INICIO = CONVERT(Char(26), SYSDATETIME(), 121)
	select @ID_PROCESSO = @IN_IDORIGEM
	select @CONTADOR = 0
	select @REGVALIDO = 'S'
	select @maxStagingCounter = @IN_maxStagingCounter
	select @delTransactTime = @IN_delTransactTime
    select @N_TAMTOTAL = @IN_TAMEMP + @IN_TAMUNIT +	@IN_TAMFIL
	select @BSCFILIAL = REPLICATE('X', @N_TAMTOTAL)				
	exec XFILIAL_## 'FWI',@BSCFILIAL, @BSCFILIAL OutPut 		
    select @nTAMFWI = Len(Trim(@BSCFILIAL))  
	
	If @IS_FULL = 'S'
		Begin

			DECLARE LJ_full_## INSENSITIVE CURSOR FOR
				SELECT
					'LJ'						AS F7I_ORIGIN,
					fk5.S_T_A_M_P_				AS fk5_S_T_A_M_P_,
					fk5.R_E_C_N_O_				AS fk5_Recno,
					sez.EZ_MSUID				AS EZ_MSUID,
					sev.EV_MSUID				AS EV_MSUID,
					stg_se1.E1_FILORIG			AS E1_FILORIG,
					stg_se1.E1_EMISSAO			AS F7I_EMISSA,
					stg_se1.E1_EMIS1			AS F7I_EMIS1,
					stg_se1.E1_HIST				AS F7I_HIST,
					stg_se1.E1_TIPO				AS F7I_TIPO,
					sx5_consolidate.X5_DESCRI	AS F7I_TIPDSC,
					stg_se1.E1_PREFIXO			AS F7I_PREFIX,
					stg_se1.E1_NUM				AS F7I_NUM,
					stg_se1.E1_PARCELA			AS F7I_PARCEL,
					stg_se1.E1_MOEDA			AS F7I_MOEDA,
					stg_se1.E1_VENCTO			AS F7I_VENCTO,
					stg_se1.E1_VENCREA			AS F7I_VENCRE,
					fk5.FK5_DATA				AS F7I_DTPGTO,
					fk5.FK5_BANCO				AS F7I_BANCO,
					fk5.FK5_AGENCI				AS F7I_AGENCI,
					fk5.FK5_CONTA				AS F7I_CONTA,
					sa1.A1_FILIAL				AS F7I_FLBENF,
					stg_se1.E1_CLIENTE			AS F7I_CDBENF,
					stg_se1.E1_LOJA				AS F7I_LJBENF,
					stg_se1.E1_NOMCLI			AS F7I_NBENEF,
					fk5.FK5_IDMOV				AS F7I_IDMOV,
					stg_se1.E1_TIPO				AS E1_TIPO,
					stg_se1.E1_VLCRUZ			AS F7I_VLCRUZ,
					fk5.FK5_DTDISP				AS F7I_DTDISP,
					stg_se1.E1_NATUREZ			AS F7I_NATURE,
					sev.EV_NATUREZ				AS F7I_NATRAT,
					sez.EZ_CCUSTO				AS F7I_CCDRAT,
					stg_se1.E1_DEBITO			AS F7I_DEBITO,
					stg_se1.E1_CCD				AS F7I_CCD,
					stg_se1.E1_CCC				AS F7I_CCC,
					stg_se1.E1_ITEMCTA			AS F7I_ITEMCT,
					stg_se1.E1_ITEMD			AS F7I_ITEMD,
					stg_se1.E1_ITEMC			AS F7I_ITEMC,
					stg_se1.E1_CLVL				AS F7I_CLVL,
					stg_se1.E1_CLVLDB			AS F7I_CLVLDB,
					stg_se1.E1_CLVLCR			AS F7I_CLVLCR,
					stg_se1.E1_NUMBOR			AS F7I_NUMBOR,
					fk5.FK5_HISTOR				AS F7I_HISTOR,
					fk5.FK5_RECPAG				AS FK5_RECPAG,
					stg_se1.E1_MOEDA			AS E1_MOEDA,
					fk5.FK5_MOEDA				AS FK5_MOEDA,
					fk5.FK5_VALOR				AS FK5_VALOR,
					fk5.FK5_VLMOE2				AS FK5_VLMOE2,
					fk5.FK5_TXMOED				AS F7I_CONVBS,
					sev.EV_VALOR				AS EV_VALOR,
					sez.EZ_VALOR				AS EZ_VALOR,
					sed.ED_CCC					AS F7I_CCUSTO,
					sed.ED_DEBITO				AS ED_DEBITO,
					sed.ED_CREDIT				AS ED_CREDIT,
					stg_se1.E1_CCUSTO			AS E1_CCUSTO,
					stg_se1.E1_SITUACA			AS F7I_MOVIM,
					stg_se1.E1_CREDIT			AS F7I_CREDIT,
					sev.EV_SITUACA				AS EV_SITUACA
					,'#campoflex' as campoflex	
					,'#camposflexrateio' as camposflexrateio
				FROM FK5### fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
					INNER JOIN FK7### fk7 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
						on fk7.FK7_FILIAL = fk5.FK5_FILIAL
							and fk7.FK7_IDDOC = fk5.FK5_IDDOC
							and fk7.D_E_L_E_T_ = @IS_SPACE
					INNER JOIN FK1### fk1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
						on fk1.FK1_FILIAL = fk7.FK7_FILIAL
							and fk1.FK1_IDDOC = fk7.FK7_IDDOC
							and fk1.FK1_MOTBX Not In (@IS_MOTLIQ, @IS_MOTCEC, @IS_MOTCMP)
							and fk1.D_E_L_E_T_ = @IS_SPACE
					INNER JOIN SE1### stg_se1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
						on stg_se1.E1_FILIAL = fk7.FK7_FILTIT
							and stg_se1.E1_CLIENTE = fk7.FK7_CLIFOR
							and stg_se1.E1_LOJA    = fk7.FK7_LOJA
							and stg_se1.E1_PREFIXO = fk7.FK7_PREFIX
							and stg_se1.E1_NUM     = fk7.FK7_NUM
							and stg_se1.E1_PARCELA = fk7.FK7_PARCEL
							and stg_se1.E1_TIPO    = fk7.FK7_TIPO
							and stg_se1.D_E_L_E_T_ = @IS_SPACE
							and stg_se1.E1_TIPO not like @IS_TP_ABT
							and stg_se1.E1_TIPO <> @IS_TP_PR
					INNER JOIN SED### sed
						on sed.ED_FILIAL =  SUBSTRING(fk5.FK5_FILORI,1,@IN_TAMSED) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSED)
							and sed.ED_CODIGO = stg_se1.E1_NATUREZ
							and sed.D_E_L_E_T_ = @IS_SPACE
					LEFT JOIN SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
						on sev.EV_FILIAL = stg_se1.E1_FILIAL
							and sev.EV_PREFIXO = stg_se1.E1_PREFIXO
							and sev.EV_NUM = stg_se1.E1_NUM
							and sev.EV_PARCELA = stg_se1.E1_PARCELA
							and sev.EV_TIPO = stg_se1.E1_TIPO
							and sev.EV_CLIFOR = stg_se1.E1_CLIENTE
							and sev.EV_LOJA = stg_se1.E1_LOJA
							and sev.EV_IDENT = @IS_EVIDENT
							and sev.EV_SEQ = fk5.FK5_SEQ
							and sev.EV_RECPAG = @IS_RECPAGR
							and sev.D_E_L_E_T_ = @IS_SPACE
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
							and sez.EZ_SITUACA = sev.EV_SITUACA
							and sez.D_E_L_E_T_ = @IS_SPACE
					LEFT JOIN FWI### fwi LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
						On	fwi.FWI_FILIAL  = SUBSTRING(fk5.FK5_FILORI,1, @nTAMFWI) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @nTAMFWI)
							And fwi.FWI_IDMOV = fk5.FK5_IDMOV
							AND fwi.D_E_L_E_T_ = @IS_SPACE
					LEFT JOIN SX5### sx5_consolidate
						on sx5_consolidate.X5_FILIAL = SUBSTRING(fk5.FK5_FILORI,1,@IN_TAMSX5) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSX5)
							and sx5_consolidate.X5_TABELA = @IS_X5TAB
							and sx5_consolidate.X5_CHAVE = stg_se1.E1_TIPO
							and sx5_consolidate.D_E_L_E_T_ = @IS_SPACE							
					INNER JOIN SA1### sa1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
							on sa1.A1_FILIAL = SUBSTRING(stg_se1.E1_FILORIG, 1, @IN_TAMSA1) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSA1)
								and sa1.A1_COD = stg_se1.E1_CLIENTE
								and sa1.A1_LOJA = stg_se1.E1_LOJA
								and sa1.D_E_L_E_T_ = @IS_SPACE
				WHERE ( fk5.FK5_DATA >= @DTINI AND fk5.FK5_DATA <= @DTFIM ) 
					AND fk5.FK5_ORIGEM Not in (@IS_FINA740, @IS_FINA070)
					AND fk5.FK5_TPDOC <> @IS_TP_RA
					AND fwi.FWI_IDMOV Is Null
			FOR READ ONLY
			OPEN LJ_full_##
			FETCH NEXT FROM LJ_full_##
				INTO @F7I_ORIGIN,
					@fk5_S_T_A_M_P_,
					@fk5_Recno,
					@EZ_MSUID,
					@EV_MSUID,
					@E1_FILORIG,
					@F7I_EMISSA,
					@F7I_EMIS1,
					@F7I_HIST,
					@F7I_TIPO,
					@F7I_TIPDSC,
					@F7I_PREFIX,
					@F7I_NUM,
					@F7I_PARCEL,
					@F7I_MOEDA,
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
					@E1_TIPO,
					@F7I_VLCRUZ,
					@F7I_DTDISP,
					@F7I_NATURE,
					@F7I_NATRAT,
					@F7I_CCDRAT,
					@F7I_DEBITO,
					@F7I_CCD,
					@F7I_CCC,
					@F7I_ITEMCT,
					@F7I_ITEMD,
					@F7I_ITEMC,
					@F7I_CLVL,
					@F7I_CLVLDB,
					@F7I_CLVLCR,
					@F7I_NUMBOR,
					@F7I_HISTOR,
					@FK5_RECPAG,
					@E1_MOEDA,
					@FK5_MOEDA,
					@FK5_VALOR,
					@FK5_VLMOE2,
					@F7I_CONVBS,
					@EV_VALOR,
					@EZ_VALOR,
					@F7I_CCUSTO,
					@ED_DEBITO,
					@ED_CREDIT,
					@E1_CCUSTO,
					@F7I_MOVIM,
					@F7I_CREDIT,
					@EV_SITUACA
					--#cursorflex
					--#cursorrateio
			WHILE ( (@@fetch_Status  = 0 ) )
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

					If @REGVALIDO = 'S'
						Begin
							select @F7I_MOVIM  = TRIM(@F7I_MOVIM)
							select @F7I_VLPROP = 0
							select @F7I_EXTCDH = @F7I_IDMOV

							If @F7I_HIST Is Null
								Begin
									select @F7I_HIST = @IS_SPACE
								End
							
							If @F7I_HISTOR Is Null
								Begin
									select @F7I_HISTOR = @IS_SPACE
								End
							
							If @F7I_TIPDSC Is Null
								Begin
									select @F7I_TIPDSC = @IS_SPACE
								End
							
							If @F7I_NATRAT Is Null
								Begin
									select @F7I_NATRAT = @IS_SPACE
								End
							
							If @F7I_CCDRAT Is Null
								Begin
									select @F7I_CCDRAT = @IS_SPACE
								End

							If ( @FK5_RECPAG = 'P' AND TRIM(@ED_CREDIT) <> @IS_SPACE )
								Begin 
									exec XFILIAL_## 'CT1', @E1_FILORIG, @filialCT1 OutPut
									Select @F7I_CNTCTB = CT1_CONTA , @F7I_DSCCTB = SUBSTRING(CT1_DESC01,1,40) , @F7I_NATCTA = CT1_NATCTA FROM CT1### Where CT1_FILIAL = @filialCT1 AND CT1_CONTA = @ED_CREDIT AND D_E_L_E_T_ = @IS_SPACE
								End
							Else
								Begin 			
									If ( @FK5_RECPAG = 'R' AND TRIM(@ED_DEBITO) <> @IS_SPACE)
										Begin
											exec XFILIAL_## 'CT1', @E1_FILORIG, @filialCT1 OutPut
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

							If(  Trim(@FK5_RECPAG) = 'R' )
								Begin 
									select @F7I_TPEVNT = 'E'
								End
							Else
								Begin
									select @F7I_TPEVNT = 'S'
								End

								If ( @FK5_VLMOE2 = 0 )
									Begin 
										select @F7I_SALDO = @FK5_VALOR
									End
								Else
									Begin
									select @F7I_SALDO = @FK5_VLMOE2
									End
							
							select @F7I_VLCRUZ = @FK5_VALOR
							select @F7I_VLRCNT = @FK5_VALOR
							select @F7I_CONVBS = ROUND(@F7I_CONVBS, @DecCONVBS)
							select @F7I_CONVCT = @F7I_CONVBS

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
											select @F7I_EXTCDD = @F7I_IDMOV
											select @F7I_VLPROP = @F7I_SALDO
										End
								End

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

							If ( @F7I_MOEDA <> @MOEDA )
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

							If ( @F7I_MOVIM <> @FRVCOD )
								Begin
									select @FRVCOD = @F7I_MOVIM
									select @F7I_DSCMOV = (SELECT FRV_DESCRI
															FROM FRV### FRV 
															WHERE FRV_CODIGO = @FRVCOD
																				AND FRV.D_E_L_E_T_ = @IS_SPACE ) 
								End 
							
							If ( @fk5_S_T_A_M_P_ is null )
								Begin 
									select @cFk5_STAMP = @delTransactTime
								End	
							Else 
								Begin
									select @cFk5_STAMP = CONVERT(CHAR(26), @fk5_S_T_A_M_P_, 121)
								End 	
								
							select @F7I_DSCCCT = @IS_SPACE
							if @F7I_CCUSTO <> @IS_SPACE
								Begin
									exec XFILIAL_## 'CTT', @E1_FILORIG, @filialCTT OutPut
									SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @F7I_CCUSTO AND D_E_L_E_T_ = @IS_SPACE)
								End
					
							select @F7I_STAMP = @cFk5_STAMP
							select @cF7I_STAMP = FORMAT(CONVERT( datetime ,@cFk5_STAMP ,121 ), 'yyyy-MM-ddTHH:mm:ss.fff')
							
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

							select @COMPANIA = SUBSTRING(@E1_FILORIG,1, @IN_TAMEMP )
							select @COD_UNID = SUBSTRING(@E1_FILORIG,@IN_TAMEMP+1, @IN_TAMUNIT)
							select @COD_FIL  = SUBSTRING(@E1_FILORIG,@IN_TAMEMP+1 + @IN_TAMUNIT , @IN_TAMEMP + @IN_TAMUNIT + @IN_TAMFIL)

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
									F7I_CCD,
									F7I_CCC,
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
									F7I_FXRTCT,
									F7I_FXRTBS,
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
									SUBSTRING(@F7I_DSCMDA,1,10),
									@F7I_MOEDB,
									SUBSTRING(@F7I_DSCMDB,1,10), 
									@F7I_VENCTO, 
									@F7I_VENCRE, 
									@F7I_DTPGTO,   
									@F7I_BANCO,   
									@F7I_AGENCI,    
									@F7I_CONTA,   
									@F7I_FLBENF,
									@F7I_CDBENF,
									@F7I_LJBENF,
									SUBSTRING(IsNull(@F7I_NBENEF, @IS_SPACE),1,50),
									@F7I_MOVIM,
									IsNull(@F7I_DSCMOV, @IS_SPACE),    
									@F7I_IDMOV,   	 
									@F7I_VLCRUZ,
									@F7I_CNTCTB, 
									IsNull(SUBSTRING(@F7I_DSCCTB,1,40),@IS_SPACE),
									IsNull(@F7I_NATCTA, @IS_SPACE),
									IsNull(SUBSTRING(@F7I_DSCCCT,1,40),@IS_SPACE),
									@F7I_DTDISP,   
									@F7I_NATURE, 
									IsNull(@F7I_NATRAT, @IS_SPACE),
									IsNull(@F7I_CCDRAT, @IS_SPACE),
									@F7I_DEBITO, 
									@F7I_CCD,
									@F7I_CCC,	
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
									@IN_GROUPEMPRESA, 
									@COMPANIA, 
									@COD_UNID, 
									@COD_FIL,
									@cF7I_STAMP,
									@F7I_SALDO,
									@F7I_TPEVNT,
									@F7I_TPBENF,
									@F7I_ORBENF,
									@F7I_FXRTCT,
									@F7I_FXRTBS,
									@F7I_CCUSTO,
									@F7I_CREDIT,
									@F7I_VLRCNT,
									@ID_PROCESSO
									--#variaveisflex
									--#variaveisrateio
								)
							##CHECK_TRANSACTION_COMMIT

							INSERT INTO F7J###  (F7J_FILIAL, F7J_ALIAS, F7J_RECNO, F7J_STAMP ) 
							VALUES(@IS_SPACE, @IS_F7J_ALIAS, @fk5_Recno , @cFk5_STAMP )

							SELECT @CONTADOR = @CONTADOR + 1
						End
					FETCH NEXT FROM LJ_full_##
						INTO @F7I_ORIGIN,
							@fk5_S_T_A_M_P_,
							@fk5_Recno,
							@EZ_MSUID,
							@EV_MSUID,
							@E1_FILORIG,
							@F7I_EMISSA,
							@F7I_EMIS1,
							@F7I_HIST,
							@F7I_TIPO,
							@F7I_TIPDSC,
							@F7I_PREFIX,
							@F7I_NUM,
							@F7I_PARCEL,
							@F7I_MOEDA,
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
							@E1_TIPO,
							@F7I_VLCRUZ,
							@F7I_DTDISP,
							@F7I_NATURE,
							@F7I_NATRAT,
							@F7I_CCDRAT,
							@F7I_DEBITO,
							@F7I_CCD,
							@F7I_CCC,
							@F7I_ITEMCT,
							@F7I_ITEMD,
							@F7I_ITEMC,
							@F7I_CLVL,
							@F7I_CLVLDB,
							@F7I_CLVLCR,
							@F7I_NUMBOR,
							@F7I_HISTOR,
							@FK5_RECPAG,
							@E1_MOEDA,
							@FK5_MOEDA,
							@FK5_VALOR,
							@FK5_VLMOE2,
							@F7I_CONVBS,
							@EV_VALOR,
							@EZ_VALOR,
							@F7I_CCUSTO,
							@ED_DEBITO,
							@ED_CREDIT,
							@E1_CCUSTO,
							@F7I_MOVIM,
							@F7I_CREDIT,
							@EV_SITUACA
							--#cursorflex
							--#cursorrateio
				End
			CLOSE LJ_full_##
			DEALLOCATE LJ_full_##
		End
	Else
		Begin
			DECLARE LJ_delta_## INSENSITIVE CURSOR FOR
				SELECT
					'LJ'						AS F7I_ORIGIN,
					fk5.S_T_A_M_P_				AS fk5_S_T_A_M_P_,
					fk5.R_E_C_N_O_				AS fk5_Recno,
					sez.EZ_MSUID				AS EZ_MSUID,
					sev.EV_MSUID				AS EV_MSUID,
					stg_se1.E1_FILORIG			AS E1_FILORIG,
					stg_se1.E1_EMISSAO			AS F7I_EMISSA,
					stg_se1.E1_EMIS1			AS F7I_EMIS1,
					stg_se1.E1_HIST				AS F7I_HIST,
					stg_se1.E1_TIPO				AS F7I_TIPO,
					sx5_consolidate.X5_DESCRI	AS F7I_TIPDSC,
					stg_se1.E1_PREFIXO			AS F7I_PREFIX,
					stg_se1.E1_NUM				AS F7I_NUM,
					stg_se1.E1_PARCELA			AS F7I_PARCEL,
					stg_se1.E1_MOEDA			AS F7I_MOEDA,
					stg_se1.E1_VENCTO			AS F7I_VENCTO,
					stg_se1.E1_VENCREA			AS F7I_VENCRE,
					fk5.FK5_DATA				AS F7I_DTPGTO,
					fk5.FK5_BANCO				AS F7I_BANCO,
					fk5.FK5_AGENCI				AS F7I_AGENCI,
					fk5.FK5_CONTA				AS F7I_CONTA,
					sa1.A1_FILIAL				AS F7I_FLBENF,
					stg_se1.E1_CLIENTE			AS F7I_CDBENF,
					stg_se1.E1_LOJA				AS F7I_LJBENF,
					stg_se1.E1_NOMCLI			AS F7I_NBENEF,
					fk5.FK5_IDMOV				AS F7I_IDMOV,
					stg_se1.E1_TIPO				AS E1_TIPO,
					stg_se1.E1_VLCRUZ			AS F7I_VLCRUZ,
					fk5.FK5_DTDISP				AS F7I_DTDISP,
					stg_se1.E1_NATUREZ			AS F7I_NATURE,
					sev.EV_NATUREZ				AS F7I_NATRAT,
					sez.EZ_CCUSTO				AS F7I_CCDRAT,
					stg_se1.E1_DEBITO			AS F7I_DEBITO,
					stg_se1.E1_CCD				AS F7I_CCD,
					stg_se1.E1_CCC				AS F7I_CCC,
					stg_se1.E1_ITEMCTA			AS F7I_ITEMCT,
					stg_se1.E1_ITEMD			AS F7I_ITEMD,
					stg_se1.E1_ITEMC			AS F7I_ITEMC,
					stg_se1.E1_CLVL				AS F7I_CLVL,
					stg_se1.E1_CLVLDB			AS F7I_CLVLDB,
					stg_se1.E1_CLVLCR			AS F7I_CLVLCR,
					stg_se1.E1_NUMBOR			AS F7I_NUMBOR,
					fk5.FK5_HISTOR				AS F7I_HISTOR,
					fk5.FK5_RECPAG				AS FK5_RECPAG,
					stg_se1.E1_MOEDA			AS E1_MOEDA,
					fk5.FK5_MOEDA				AS FK5_MOEDA,
					fk5.FK5_VALOR				AS FK5_VALOR,
					fk5.FK5_VLMOE2				AS FK5_VLMOE2,
					fk5.FK5_TXMOED				AS F7I_CONVBS,
					sev.EV_VALOR				AS EV_VALOR,
					sez.EZ_VALOR				AS EZ_VALOR,
					sed.ED_CCC					AS F7I_CCUSTO,
					sed.ED_DEBITO				AS ED_DEBITO,
					sed.ED_CREDIT				AS ED_CREDIT,
					stg_se1.E1_CCUSTO			AS E1_CCUSTO,
					stg_se1.E1_SITUACA			AS F7I_MOVIM,
					stg_se1.E1_CREDIT			AS F7I_CREDIT,
					sev.EV_SITUACA				AS EV_SITUACA
					,'#campoflex' as campoflex	
					,'#camposflexrateio' as camposflexrateio
				FROM FK5### fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
					INNER JOIN FK7### fk7 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
						on fk7.FK7_FILIAL = fk5.FK5_FILIAL
							and fk7.FK7_IDDOC = fk5.FK5_IDDOC
					INNER JOIN FK1### fk1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
						on fk1.FK1_FILIAL = fk7.FK7_FILIAL
							and fk1.FK1_IDDOC = fk7.FK7_IDDOC
							and fk1.FK1_MOTBX Not In (@IS_MOTLIQ, @IS_MOTCEC, @IS_MOTCMP)
					INNER JOIN SE1### stg_se1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
						on stg_se1.E1_FILIAL = fk7.FK7_FILTIT
							and stg_se1.E1_CLIENTE = fk7.FK7_CLIFOR
							and stg_se1.E1_LOJA    = fk7.FK7_LOJA
							and stg_se1.E1_PREFIXO = fk7.FK7_PREFIX
							and stg_se1.E1_NUM     = fk7.FK7_NUM
							and stg_se1.E1_PARCELA = fk7.FK7_PARCEL
							and stg_se1.E1_TIPO    = fk7.FK7_TIPO
							and stg_se1.D_E_L_E_T_ = fk7.D_E_L_E_T_
							and stg_se1.E1_TIPO not like @IS_TP_ABT
							and stg_se1.E1_TIPO <> @IS_TP_PR
					LEFT JOIN SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
						on sev.EV_FILIAL = stg_se1.E1_FILIAL
							and sev.EV_PREFIXO = stg_se1.E1_PREFIXO
							and sev.EV_NUM = stg_se1.E1_NUM
							and sev.EV_PARCELA = stg_se1.E1_PARCELA
							and sev.EV_TIPO = stg_se1.E1_TIPO
							and sev.EV_CLIFOR = stg_se1.E1_CLIENTE
							and sev.EV_LOJA = stg_se1.E1_LOJA
							and sev.EV_IDENT = @IS_EVIDENT
							and sev.EV_SEQ = fk5.FK5_SEQ
							and sev.EV_RECPAG = @IS_RECPAGR
							and sev.D_E_L_E_T_ = stg_se1.D_E_L_E_T_
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
							and sez.EZ_SITUACA = sev.EV_SITUACA
							and sev.D_E_L_E_T_ = sev.D_E_L_E_T_
					LEFT JOIN FWI### fwi LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
						On	fwi.FWI_FILIAL  = SUBSTRING(fk5.FK5_FILORI,1, @nTAMFWI) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @nTAMFWI)
							And fwi.FWI_IDMOV = fk5.FK5_IDMOV
							AND fwi.D_E_L_E_T_ = @IS_SPACE
					INNER JOIN SED### sed
						on sed.ED_FILIAL =  SUBSTRING(fk5.FK5_FILORI,1,@IN_TAMSED) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSED)
							and sed.ED_CODIGO = stg_se1.E1_NATUREZ
							and sed.D_E_L_E_T_ = @IS_SPACE
					LEFT JOIN SX5### sx5_consolidate
						on sx5_consolidate.X5_FILIAL = SUBSTRING(fk5.FK5_FILORI,1,@IN_TAMSX5) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSX5)
							and sx5_consolidate.X5_TABELA = @IS_X5TAB
							and sx5_consolidate.X5_CHAVE = stg_se1.E1_TIPO
							and sx5_consolidate.D_E_L_E_T_ = @IS_SPACE
					LEFT JOIN F7J### f7j
						ON f7j.F7J_ALIAS = @IS_F7J_ALIAS
							AND f7j.F7J_STAMP = CONVERT(CHAR(26), fk5.S_T_A_M_P_ , 121)
							AND f7j.F7J_RECNO = fk5.R_E_C_N_O_
					INNER JOIN SA1### sa1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
							on sa1.A1_FILIAL = SUBSTRING(stg_se1.E1_FILORIG, 1, @IN_TAMSA1) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSA1)
								and sa1.A1_COD = stg_se1.E1_CLIENTE
								and sa1.A1_LOJA = stg_se1.E1_LOJA
								and sa1.D_E_L_E_T_ = @IS_SPACE
				WHERE fk5.S_T_A_M_P_ > @maxStagingCounter 
					AND fk5.FK5_ORIGEM Not in (@IS_FINA740, @IS_FINA070)
					AND fk5.FK5_TPDOC <> @IS_TP_RA
					AND fwi.FWI_IDMOV Is Null
			FOR READ ONLY
			OPEN LJ_delta_##
			FETCH NEXT FROM LJ_delta_##
				INTO @F7I_ORIGIN,
					@fk5_S_T_A_M_P_,
					@fk5_Recno,
					@EZ_MSUID,
					@EV_MSUID,				 
					@E1_FILORIG,				 
					@F7I_EMISSA,
					@F7I_EMIS1,
					@F7I_HIST,
					@F7I_TIPO,
					@F7I_TIPDSC,				 
					@F7I_PREFIX,
					@F7I_NUM,
					@F7I_PARCEL,
					@F7I_MOEDA,
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
					@E1_TIPO,
					@F7I_VLCRUZ,
					@F7I_DTDISP,
					@F7I_NATURE,
					@F7I_NATRAT,
					@F7I_CCDRAT,
					@F7I_DEBITO,
					@F7I_CCD,
					@F7I_CCC,
					@F7I_ITEMCT,
					@F7I_ITEMD,
					@F7I_ITEMC,
					@F7I_CLVL,
					@F7I_CLVLDB,
					@F7I_CLVLCR,
					@F7I_NUMBOR,
					@F7I_HISTOR,				 
					@FK5_RECPAG,
					@E1_MOEDA,
					@FK5_MOEDA,
					@FK5_VALOR,
					@FK5_VLMOE2,
					@F7I_CONVBS,
					@EV_VALOR,
					@EZ_VALOR,
					@F7I_CCUSTO,
					@ED_DEBITO,
					@ED_CREDIT,
					@E1_CCUSTO,
					@F7I_MOVIM,
					@F7I_CREDIT,
					@EV_SITUACA
					--#cursorflex
					--#cursorrateio
			WHILE ( (@@fetch_Status  = 0 ) )
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

					If @REGVALIDO = 'S'
						Begin
							select @F7I_MOVIM  = TRIM(@F7I_MOVIM)
							select @F7I_VLPROP = 0
							select @F7I_EXTCDH = @F7I_IDMOV

							If @F7I_HIST Is Null
								Begin
									select @F7I_HIST = @IS_SPACE
								End
							
							If @F7I_HISTOR Is Null
								Begin
									select @F7I_HISTOR = @IS_SPACE
								End
							
							If @F7I_TIPDSC Is Null
								Begin
									select @F7I_TIPDSC = @IS_SPACE
								End
							
							If @F7I_NATRAT Is Null
								Begin
									select @F7I_NATRAT = @IS_SPACE
								End
							
							If @F7I_CCDRAT Is Null
								Begin
									select @F7I_CCDRAT = @IS_SPACE
								End

							If ( @FK5_RECPAG = 'P' AND TRIM(@ED_CREDIT) <> @IS_SPACE )
								Begin 
									exec XFILIAL_## 'CT1', @E1_FILORIG, @filialCT1 OutPut
									Select @F7I_CNTCTB = CT1_CONTA , @F7I_DSCCTB = SUBSTRING(CT1_DESC01,1,40) , @F7I_NATCTA = CT1_NATCTA FROM CT1### Where CT1_FILIAL = @filialCT1 AND CT1_CONTA = @ED_CREDIT AND D_E_L_E_T_ = @IS_SPACE
								End
							Else
								Begin 			
									If ( @FK5_RECPAG = 'R' AND TRIM(@ED_DEBITO) <> @IS_SPACE)
										Begin
											exec XFILIAL_## 'CT1', @E1_FILORIG, @filialCT1 OutPut
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

							If(  Trim(@FK5_RECPAG) = 'R' )
								Begin 
									select @F7I_TPEVNT = 'E'
								End
							Else
								Begin
									select @F7I_TPEVNT = 'S'
								End

								If ( @FK5_VLMOE2 = 0 )
									Begin 
										select @F7I_SALDO = @FK5_VALOR
									End
								Else
									Begin
										select @F7I_SALDO = @FK5_VLMOE2
									End
							
							select @F7I_VLCRUZ = @FK5_VALOR
							select @F7I_VLRCNT = @FK5_VALOR
							select @F7I_CONVBS = ROUND(@F7I_CONVBS, @DecCONVBS)
							select @F7I_CONVCT = @F7I_CONVBS

							If (  @EZ_MSUID is not null )
								Begin 
									select @F7I_EXTCDD = @EZ_MSUID
									select @F7I_VLPROP = ROUND(@EZ_VALOR, 2)
								End
							Else
								Begin 			
									If ( @EV_MSUID is not null )
										Begin 
											select @F7I_EXTCDD = @EV_MSUID
											select @F7I_VLPROP = ROUND(@EV_VALOR, 2)
										End
									Else
										Begin
											select @F7I_EXTCDD = @F7I_IDMOV
											select @F7I_VLPROP = @F7I_SALDO
										End
								End

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

							If ( @F7I_MOEDA <> @MOEDA )
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

							If ( @F7I_MOVIM <> @FRVCOD )
								Begin
									select @FRVCOD = @F7I_MOVIM
									select @F7I_DSCMOV = (SELECT FRV_DESCRI
															FROM FRV### FRV 
															WHERE FRV_CODIGO = @FRVCOD
																				AND FRV.D_E_L_E_T_ = @IS_SPACE ) 
								End 
							
							If ( @fk5_S_T_A_M_P_ is null )
								Begin 
									select @cFk5_STAMP = @delTransactTime
								End	
							Else 
								Begin
									select @cFk5_STAMP = CONVERT(CHAR(26), @fk5_S_T_A_M_P_, 121)
								End 	
								
							select @F7I_DSCCCT = @IS_SPACE
							if @F7I_CCUSTO <> @IS_SPACE
								Begin
									exec XFILIAL_## 'CTT', @E1_FILORIG, @filialCTT OutPut
									SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @F7I_CCUSTO AND D_E_L_E_T_ = @IS_SPACE)
								End
					
							select @F7I_STAMP = @cFk5_STAMP
							select @cF7I_STAMP = FORMAT(CONVERT( datetime ,@cFk5_STAMP ,121 ), 'yyyy-MM-ddTHH:mm:ss.fff')
							
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

							select @COMPANIA = SUBSTRING(@E1_FILORIG,1, @IN_TAMEMP )
							select @COD_UNID = SUBSTRING(@E1_FILORIG,@IN_TAMEMP+1, @IN_TAMUNIT)
							select @COD_FIL  = SUBSTRING(@E1_FILORIG,@IN_TAMEMP+1 + @IN_TAMUNIT , @IN_TAMEMP + @IN_TAMUNIT + @IN_TAMFIL)

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
									F7I_CCD,
									F7I_CCC,
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
									F7I_FXRTCT,
									F7I_FXRTBS,
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
									SUBSTRING(@F7I_DSCMDA,1,10),
									@F7I_MOEDB,
									SUBSTRING(@F7I_DSCMDB,1,10), 
									@F7I_VENCTO, 
									@F7I_VENCRE, 
									@F7I_DTPGTO,   
									@F7I_BANCO,   
									@F7I_AGENCI,    
									@F7I_CONTA,   
									@F7I_FLBENF,
									@F7I_CDBENF,
									@F7I_LJBENF,
									SUBSTRING(IsNull(@F7I_NBENEF, @IS_SPACE),1,50),
									@F7I_MOVIM,
									IsNull(@F7I_DSCMOV, @IS_SPACE),    
									@F7I_IDMOV,   	 
									@F7I_VLCRUZ,
									@F7I_CNTCTB, 
									IsNull(SUBSTRING(@F7I_DSCCTB,1,40),@IS_SPACE),
									IsNull(@F7I_NATCTA, @IS_SPACE),
									IsNull(SUBSTRING(@F7I_DSCCCT,1,40),@IS_SPACE),
									@F7I_DTDISP,   
									@F7I_NATURE, 
									IsNull(@F7I_NATRAT, @IS_SPACE),
									IsNull(@F7I_CCDRAT, @IS_SPACE),
									@F7I_DEBITO, 
									@F7I_CCD,
									@F7I_CCC,	
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
									@IN_GROUPEMPRESA, 
									@COMPANIA, 
									@COD_UNID, 
									@COD_FIL,
									@cF7I_STAMP,
									@F7I_SALDO,
									@F7I_TPEVNT,
									@F7I_TPBENF,
									@F7I_ORBENF,
									@F7I_FXRTCT,
									@F7I_FXRTBS,
									@F7I_CCUSTO,
									@F7I_CREDIT,
									@F7I_VLRCNT,
									@ID_PROCESSO
									--#variaveisflex
									--#variaveisrateio
								)
							##CHECK_TRANSACTION_COMMIT

							INSERT INTO F7J###  (F7J_FILIAL, F7J_ALIAS, F7J_RECNO, F7J_STAMP ) 
							VALUES(@IS_SPACE, @IS_F7J_ALIAS, @fk5_Recno , @cFk5_STAMP )

							SELECT @CONTADOR = @CONTADOR + 1
						End
					FETCH NEXT FROM LJ_delta_##
						INTO @F7I_ORIGIN,
							@fk5_S_T_A_M_P_,
							@fk5_Recno,
							@EZ_MSUID,
							@EV_MSUID,
							@E1_FILORIG,
							@F7I_EMISSA,
							@F7I_EMIS1,
							@F7I_HIST,
							@F7I_TIPO,
							@F7I_TIPDSC,
							@F7I_PREFIX,
							@F7I_NUM,
							@F7I_PARCEL,
							@F7I_MOEDA,
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
							@E1_TIPO,
							@F7I_VLCRUZ,
							@F7I_DTDISP,
							@F7I_NATURE,
							@F7I_NATRAT,
							@F7I_CCDRAT,
							@F7I_DEBITO,
							@F7I_CCD,
							@F7I_CCC,
							@F7I_ITEMCT,
							@F7I_ITEMD,
							@F7I_ITEMC,
							@F7I_CLVL,
							@F7I_CLVLDB,
							@F7I_CLVLCR,
							@F7I_NUMBOR,
							@F7I_HISTOR,
							@FK5_RECPAG,
							@E1_MOEDA,
							@FK5_MOEDA,
							@FK5_VALOR,
							@FK5_VLMOE2,
							@F7I_CONVBS,
							@EV_VALOR,
							@EZ_VALOR,
							@F7I_CCUSTO,
							@ED_DEBITO,
							@ED_CREDIT,
							@E1_CCUSTO,
							@F7I_MOVIM,
							@F7I_CREDIT,
							@EV_SITUACA
							--#cursorflex
							--#cursorrateio
				End
			CLOSE LJ_delta_##
			DEALLOCATE LJ_delta_##
		End

	Begin
		INSERT INTO F7P### (F7P_IDPROC, F7P_INICIO, F7P_FIM, F7P_QTDE, F7P_PROCES, F7P_LOTE) 
		VALUES (@ID_PROCESSO, @DATA_INICIO, CONVERT(Char(26), SYSDATETIME(), 121), @CONTADOR, @IS_FIN008E, @IN_LOTEPROC)
	End

	select @OUT_RESULTADO = '1'
End