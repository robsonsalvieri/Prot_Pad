-- =============================================
-- Author:		Luiz Gustavo Romeiro de Jesus
-- Create date: 07/03/2025
-- Description:	Geração dos titulos a Pagar Realizado
-- =============================================
CREATE PROCEDURE FIN009_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
	@IN_TAMSA6  Integer,
	@IN_TAMSED  Integer,
	@IN_TAMCT1  Integer,
	@IN_TAMCTT  Integer,
	@IN_TAMSX5  Integer,
	@IN_TAMSA2  Integer,
	@IN_TAMFRV  Integer,
	@IN_TAMSEV  Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
	@IN_COMPANIA char('##COMPANIA'),
	@IN_COD_UNID char('##COD_UNID'),
	@IN_COD_FIL char('##COD_FIL'),
	@IN_mdmTenantId Char( 32 ),
	@IN_DTINI  char('F7I_EMIS1'),
	@IN_DTFIM  char('F7I_EMIS1'),
	@IN_DEL Char( 1 ),
	@IN_TRANSACTION Char( 1 ),
	@DecCONVBS Integer,
	@OUT_RESULTADO Char(1) OutPut 
)
AS
--Variaveis de apoio
declare @N_TAMTOTAL Integer

declare @param_DTINI char('F7I_EMIS1')
declare @param_DTFIM char('F7I_EMIS1')

declare @param_COMPANIA char('##COMPANIA')
declare @param_COD_UNID char('##COD_UNID')
declare @param_COD_FIL char('##COD_FIL')
declare @filialCT1 char('CT1_FILIAL')
declare @filialCTT char('CTT_FILIAL')

--Variaveis do cursor
DECLARE @F7I_ORIGIN Char('F7I_ORIGIN')
DECLARE @cF7I_STAMP	Char('F7I_STAMP')
DECLARE @F7I_EXTCDH	Char('F7I_EXTCDH')
DECLARE @F7I_EXTCDD	Char('EV_MSUID')
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
DECLARE @F7I_MOEDA	Float
DECLARE @F7I_DSCMDA	Char('F7I_DSCMDA')
DECLARE @F7I_MOEDB	Float
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
DECLARE @F7I_NBENEF Char('A2_NOME')
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

--Variaveis de tratamento de campos
DECLARE @EZ_MSUID	Char('EZ_MSUID')
DECLARE @EV_MSUID	Char('EV_MSUID')
DECLARE @E2_FILORIG	Char('E2_FILORIG')
DECLARE @E2_BAIXA	Char('E2_BAIXA')
DECLARE @E2_CCUSTO  Char('E2_CCUSTO')
DECLARE @E2_TIPO	Char('E2_TIPO')
DECLARE @E2_VLCRUZ	Float
DECLARE @E2_VALOR	Float
DECLARE @CT1_CONTA	Char('CT1_CONTA')
DECLARE @ED_CCD		Char('ED_CCD')
DECLARE @ED_DEBITO	Char('ED_DEBITO')
DECLARE @ED_CREDIT	Char('ED_CREDIT')
DECLARE @FK7_IDDOC	Char('FK7_IDDOC')
DECLARE @FK2_TPDOC	Char('FK2_TPDOC')
DECLARE @E2_LOTE	Char('E2_LOTE')
DECLARE @FK2_IDFK2	Char('FK2_IDFK2')
DECLARE @FK5_RECPAG	Char('FK5_RECPAG')
DECLARE @FK2_VALOR	Float
DECLARE @E2_MOEDA	Float
DECLARE @A6_MOEDA	Float
DECLARE @FK5_VALOR	Float
DECLARE @FK5_VLMOE2	Float
DECLARE @EZ_VALOR	Float
DECLARE @EV_VALOR	Float

DECLARE @maxStagingCounter 	Datetime 
DECLARE @se2_S_T_A_M_P_		Datetime 
DECLARE @fk7_S_T_A_M_P_ 	Datetime 
DECLARE @fk2_S_T_A_M_P_ 	Datetime 
DECLARE @fka_S_T_A_M_P_ 	Datetime 
DECLARE @fk5_S_T_A_M_P_ 	Datetime 
DECLARE @cFk5_STAMP char(26)
DECLARE @fk5_Recno Integer
declare @delTransactTime char(26)
declare @cStamp char(26)
declare @F7I_CREDIT char('F7I_CREDIT')
declare flex char(1)


Begin
	select @F7I_ORGSYT = 'PR'
	select @N_TAMTOTAL = @IN_TAMEMP + @IN_TAMUNIT +	@IN_TAMFIL

	select @param_DTINI = @IN_DTINI
	select @param_DTFIM = @IN_DTFIM

	select @param_COMPANIA = @IN_COMPANIA
    select @param_COD_UNID = @IN_COD_UNID
    select @param_COD_FIL = @IN_COD_FIL

	Select @cStamp = ( SELECT MIN(F7J_STAMP) FROM F7J### F7J WHERE F7J.F7J_ALIAS = 'CPR' )

	Select @delTransactTime = CONVERT(CHAR(26), DATEADD(HOUR, -1, GETUTCDATE()), 121)

	If @cStamp is not null 
		Begin
			If @cStamp > @delTransactTime
				Begin
					Select @maxStagingCounter  = convert(datetime, @delTransactTime ,121 ) 
				End
			Else
				Begin
					Select @maxStagingCounter  = convert(datetime, @cStamp,121 ) 
				End
		End


    If (@param_DTINI = ' ' and @param_DTFIM = ' ')
		Begin
			select @param_DTINI = Convert(CHAR(8),DateAdd(Year,-2,GetDate()),112)
			select @param_DTFIM = Convert(CHAR(8), GetDate(), 112)
		End

	select @F7I_TPEVNT = 'S'
	select @F7I_TPBENF = '3'
	select @F7I_ORBENF = 'CP'
	select @F7I_SALDO  = 0
	select @F7I_VLPROP = 0
	select @F7I_FXRTBS = 0
	select @F7I_VLRCNT = 0
	select @F7I_FXRTCT = 0

	declare curPagarR insensitive cursor for
	--NF
	
	select
		Origem																							as F7I_ORIGIN,
		se2_S_T_A_M_P_																					as se2_S_T_A_M_P_,
		fk7_S_T_A_M_P_																					as fk7_S_T_A_M_P_,
		fk2_S_T_A_M_P_																					as fk2_S_T_A_M_P_,
		fka_S_T_A_M_P_																					as fka_S_T_A_M_P_,
		fk5_S_T_A_M_P_																					as fk5_S_T_A_M_P_,
		fk5_Recno                                                                                       as fk5_Recno,
		EZ_MSUID																					    as EZ_MSUID,
		EV_MSUID																					    as EV_MSUID,
		E2_FILORIG																						as E2_FILORIG,	
		E2_EMISSAO																						as F7I_EMISSA,
		E2_EMIS1																						as F7I_EMIS1,	
		COALESCE(E2_HIST,' ')																			as F7I_HIST,
		E2_TIPO			          																		as F7I_TIPO,	
		X5_DESCRI																				        as F7I_TIPDSC,
		E2_PREFIXO																						as F7I_PREFIX,
		E2_NUM																							as F7I_NUM,
		E2_PARCELA																						as F7I_PARCEL,
		E2_MOEDA																						as F7I_MOEDA,
		trim(DESC_MOEDA_se2)																			as F7I_DSCMDA,
		A6_MOEDA																						as F7I_MOEDB,
		E2_VENCTO																						as F7I_VENCTO,
		E2_VENCREA																						as F7I_VENCRE,
		FK5_DATA																						as F7I_DTPGTO,
		FK5_BANCO  																						as F7I_BANCO,
		FK5_AGENCI 																						as F7I_AGENCI,
		FK5_CONTA  																						as F7I_CONTA,
		A2_FILIAL																						as F7I_FLBENF,
		A2_COD																							as F7I_CDBENF,
		A2_LOJA																							as F7I_LJBENF,
		A2_NOME																							as F7I_NBENEF,
		FK5_IDMOV 																						as F7I_IDMOV,
		E2_BAIXA																						as E2_BAIXA,
		E2_TIPO																							as E2_TIPO,	
		E2_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as F7I_VLCRUZ,
		E2_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E2_VLCRUZ,
		E2_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E2_VALOR,
		ED_CCD																							as ED_CCD,
		ED_DEBITO																						as ED_DEBITO,
		ED_CREDIT																						as ED_CREDIT,
		E2_CCUSTO																						as E2_CCUSTO,
		FK5_DTDISP																						as F7I_DTDISP,
		E2_NATUREZ																						as F7I_NATURE,      
		COALESCE(EV_NATUREZ,' ')																		as F7I_NATRAT,
		COALESCE(EZ_CCUSTO,' ')																			as F7I_CCDRAT,
		FK7_IDDOC																						as FK7_IDDOC,
		E2_DEBITO																						as F7I_DEBITO,
		E2_CCC																							as F7I_CCC,
		E2_CCD																							as F7I_CCD,
		E2_ITEMCTA																						as F7I_ITEMCT,
		E2_ITEMD																						as F7I_ITEMD,
		E2_ITEMC																						as F7I_ITEMC,
		E2_CLVL																							as F7I_CLVL,
		E2_CLVLDB																						as F7I_CLVLDB,
		E2_CLVLCR																						as F7I_CLVLCR,
		E2_NUMBOR																						as F7I_NUMBOR,
		FK5_HISTOR																						as F7I_HISTOR,
		FK2_TPDOC																						as FK2_TPDOC,
		E2_LOTE																							as E2_LOTE,
		FK2_IDFK2																						as FK2_IDFK2,
		FK5_RECPAG																						as FK5_RECPAG,
		FK2_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as FK2_VALOR,
		E2_MOEDA																						as E2_MOEDA,
		A6_MOEDA																						as A6_MOEDA,
		FK5_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as FK5_VALOR,
		FK5_VLMOE2 * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)											as FK5_VLMOE2,
		FK5_TXMOED 																						as F7I_CONVBS,
		FK5_TXMOED 																						as F7I_CONVCT,
		EV_VALOR																						as EV_VALOR,
		EZ_VALOR																						as EZ_VALOR,
		E2_CREDIT 																						as F7I_CREDIT
		,'#selectcursorflex' as cursorflex
		
	From (
		Select
			'NF' as Origem,
			'##ROW_NUMBER' as fka_rownum,
			fk7_rownum,
			stg_se2.E2_PREFIXO,
			stg_se2.E2_NUM,
			stg_se2.E2_PARCELA,
			stg_se2.E2_VALOR,
			stg_se2.E2_FILORIG,
			stg_se2.E2_TIPO,
			stg_se2.E2_LOJA,
			stg_se2.E2_NATUREZ,
			stg_se2.E2_CCUSTO,
			stg_se2.E2_MOEDA,
			stg_se2.E2_LOTE,
			stg_se2.E2_EMISSAO,
			stg_se2.E2_HIST,
			stg_se2.E2_VENCTO,
			stg_se2.E2_VENCREA,
			stg_se2.E2_VLCRUZ,
			stg_se2.E2_EMIS1,            
			stg_se2.E2_BAIXA,
			stg_se2.E2_DEBITO,
			stg_se2.E2_CCD,
			stg_se2.E2_CCC,
			stg_se2.E2_ITEMCTA,
			stg_se2.E2_ITEMD,
			stg_se2.E2_ITEMC,
			stg_se2.E2_CLVL,
			stg_se2.E2_CLVLDB,
			stg_se2.E2_CLVLCR,
			stg_se2.E2_NUMBOR,
			stg_se2.E2_CREDIT,
			stg_se2.S_T_A_M_P_ as se2_S_T_A_M_P_,

			fk7.FK7_PREFIX,
			fk7.FK7_NUM,
			fk7.FK7_PARCEL,
			fk7.FK7_TIPO,
			fk7.FK7_CLIFOR,
			fk7.FK7_LOJA,
			fk7.FK7_FILIAL,
			fk7.FK7_IDDOC,
			fk7.S_T_A_M_P_ as fk7_S_T_A_M_P_,

			fk2.FK2_TPDOC,
			fk2.FK2_IDFK2,
			fk2.FK2_VALOR,
			fk2.S_T_A_M_P_ as fk2_S_T_A_M_P_,

			fka_fk2.S_T_A_M_P_ as fka_S_T_A_M_P_,
			
			fk5.FK5_IDDOC,
			fk5.FK5_RECPAG,
			fk5.FK5_DATA,
			fk5.FK5_IDMOV,
			fk5.FK5_VALOR,
			fk5.FK5_BANCO,
			fk5.FK5_AGENCI,
			fk5.FK5_CONTA,
			fk5.FK5_VLMOE2,
			fk5.FK5_TXMOED,
			fk5.FK5_DTDISP,	
			fk5.FK5_HISTOR,        
			fk5.S_T_A_M_P_ as fk5_S_T_A_M_P_,
			fk5.R_E_C_N_O_ as fk5_Recno,
		
			sed.ED_DEBITO,
			sed.ED_CREDIT,			
			sed.ED_CCD,

			sx5_consolidate.X5_DESCRI,

			sa2.A2_COD,
			sa2.A2_LOJA,
			sa2.A2_FILIAL,
			sa2.A2_NOME,

			sa6.A6_MOEDA,

			currency_se2.DESC_MOEDA_se2,

			sev.EV_NATUREZ,
			sev.EV_MSUID,
			sev.EV_VALOR,
			sev.EV_PERC,
			sez.EZ_CCUSTO,
			sez.EZ_MSUID,
			sez.EZ_VALOR,
			sez.EZ_PERC
			,'#campoflex' as campoflex		
		From
			(
			select
				se2.E2_FILIAL,
				se2.E2_PREFIXO,
				se2.E2_NUM,
				se2.E2_PARCELA,
				se2.E2_VALOR,
				se2.E2_FILORIG,
				se2.E2_ACRESC,
				se2.E2_DECRESC,
				se2.E2_TIPO,
				se2.E2_SALDO,
				se2.E2_NATUREZ,
				se2.E2_CCUSTO,
				se2.E2_LOTE,
				se2.E2_EMISSAO,
				se2.E2_BAIXA,
				se2.E2_HIST,
				se2.E2_VENCTO,
				se2.E2_VENCREA,
				se2.E2_VLCRUZ,
				se2.E2_EMIS1,
				se2.E2_FORNECE,
				se2.E2_LOJA,
				se2.E2_MOEDA,
				se2.E2_FORMPAG,
				se2.E2_DEBITO,
				se2.E2_CREDIT,
				se2.E2_CCD,
				se2.E2_CCC,
				se2.E2_ITEMCTA,
				se2.E2_ITEMD,
				se2.E2_ITEMC,
				se2.E2_CLVL,
				se2.E2_CLVLDB,
				se2.E2_CLVLCR,
				se2.E2_NUMBOR,
				se2.D_E_L_E_T_,
				se2.S_T_A_M_P_,
				Count(se2.E2_NUM) as se2_rownum
				,'#campoflexprincipal' as campoflexprincipal
			From 
				SE2### se2 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			Where
				((@maxStagingCounter is null and (se2.E2_BAIXA  >= @param_DTINI or se2.E2_EMIS1  >= @param_DTINI  )) or se2.S_T_A_M_P_ > @maxStagingCounter )
				And RIGHT(se2.E2_TIPO, 1) <> '-' 
				AND se2.E2_TIPO NOT IN ('PR ', 'PA ')
			Group by
				se2.E2_FILIAL,
				se2.E2_PREFIXO,
				se2.E2_NUM,
				se2.E2_PARCELA,
				se2.E2_VALOR,
				se2.E2_FILORIG,
				se2.E2_ACRESC,
				se2.E2_DECRESC,
				se2.E2_TIPO,
				se2.E2_SALDO,
				se2.E2_NATUREZ,
				se2.E2_CCUSTO,
				se2.E2_LOTE,
				se2.E2_EMISSAO,
				se2.E2_BAIXA,
				se2.E2_HIST,
				se2.E2_VENCTO,
				se2.E2_VENCREA,
				se2.E2_VLCRUZ,
				se2.E2_EMIS1,
				se2.E2_FORNECE,
				se2.E2_LOJA,
				se2.E2_MOEDA,
				se2.E2_FORMPAG,
				se2.E2_DEBITO,
				se2.E2_CREDIT,
				se2.E2_CCD,
				se2.E2_CCC,
				se2.E2_ITEMCTA,
				se2.E2_ITEMD,
				se2.E2_ITEMC,
				se2.E2_CLVL,
				se2.E2_CLVLDB,
				se2.E2_CLVLCR,
				se2.E2_NUMBOR,
				se2.D_E_L_E_T_,
				se2.S_T_A_M_P_
				,'#campoflexprincipal' as campoflexprincipal
			) stg_se2
		
			Inner join (
				Select 
					fk7.FK7_FILTIT,
					fk7.FK7_PREFIX,
					fk7.FK7_NUM,
					fk7.FK7_PARCEL,
					fk7.FK7_TIPO,
					fk7.FK7_CLIFOR,
					fk7.FK7_LOJA,
					fk7.FK7_FILIAL,
					fk7.FK7_IDDOC,
					fk7.FK7_ALIAS,
					fk7.FK7_CHAVE,
					fk7.D_E_L_E_T_,
					fk7.S_T_A_M_P_,
					Count(fk7.FK7_NUM) as fk7_rownum
				From 
					FK7### fk7 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
				Where
					FK7_ALIAS = 'SE2'
				Group By
					fk7.FK7_FILTIT,
					fk7.FK7_PREFIX,
					fk7.FK7_NUM,
					fk7.FK7_PARCEL,
					fk7.FK7_TIPO,
					fk7.FK7_CLIFOR,
					fk7.FK7_LOJA,
					fk7.FK7_FILIAL,
					fk7.FK7_IDDOC,
					fk7.FK7_ALIAS,
					fk7.FK7_CHAVE,
					fk7.D_E_L_E_T_,
					fk7.S_T_A_M_P_
			) fk7
			On
				stg_se2.E2_FILIAL = fk7.FK7_FILTIT --FILTIT GRAVADO COM A FILIAL DA E1/E2 (NAO TRATAR)
				And stg_se2.E2_PREFIXO = fk7.FK7_PREFIX 
				And stg_se2.E2_NUM = fk7.FK7_NUM
				And stg_se2.E2_PARCELA = fk7.FK7_PARCEL
				And stg_se2.E2_TIPO = fk7.FK7_TIPO
				And stg_se2.E2_FORNECE = fk7.FK7_CLIFOR
				And stg_se2.E2_LOJA = fk7.FK7_LOJA
				And stg_se2.D_E_L_E_T_ = fk7.D_E_L_E_T_
				And stg_se2.se2_rownum = fk7.fk7_rownum

			Left join FK2### fk2 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on
				fk2.FK2_FILORI = stg_se2.E2_FILORIG -- amarrado com FILORI em ambas (nao tratar)	
				And fk2.FK2_IDDOC = fk7.FK7_IDDOC
				And fk2.FK2_MOTBX Not In ('LIQ','CEC','CMP')
				And fk2.D_E_L_E_T_ = ' '
			
			Left join FKA### fka_fk2 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on
				fka_fk2.FKA_FILIAL = fk2.FK2_FILIAL -- mesmo nivel de compartilhamento (nao tratar)
				And fka_fk2.FKA_IDORIG = fk2.FK2_IDFK2
				And fka_fk2.FKA_TABORI = 'FK2'

			Left join FKA### fka_fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on
				fka_fk5.FKA_FILIAL = fk2.FK2_FILIAL -- mesmo nivel de compartilhamento (nao tratar)
				And fka_fk2.FKA_IDPROC = fka_fk5.FKA_IDPROC
				And fka_fk5.FKA_TABORI = 'FK5'

			Inner join FK5### fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				fka_fk5.FKA_FILIAL = fk5.FK5_FILIAL -- mesmo nivel de compartilhamento (nao tratar)
				And fka_fk5.FKA_IDORIG = fk5.FK5_IDMOV
				And fk5.FK5_DATA >= @param_DTINI
				And fk5.FK5_ORDREC = ' '
				
			Inner join SED### sed
			on
				sed.ED_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSED) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSED)
				And sed.ED_CODIGO = stg_se2.E2_NATUREZ
				And sed.D_E_L_E_T_ = ' '

			inner join SX5### sx5_consolidate ON sx5_consolidate.X5_FILIAL  = SUBSTRING ( stg_se2.E2_FILORIG , 1 , @IN_TAMSX5 ) || REPLICATE ( ' ' , @N_TAMTOTAL  - @IN_TAMSX5 )
				And sx5_consolidate.X5_TABELA = '05' 
				And sx5_consolidate.X5_CHAVE  = stg_se2.E2_TIPO 
				And sx5_consolidate.D_E_L_E_T_  = ' '

			Left join SA2### sa2
			On
				sa2.A2_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSA2) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSA2)
				And sa2.A2_COD = stg_se2.E2_FORNECE
				And sa2.A2_LOJA = stg_se2.E2_LOJA
				And sa2.D_E_L_E_T_  = ' '

			Left Join SA6### sa6
			On		  
				sa6.A6_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSA6) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSA6)
				And sa6.A6_COD = fk5.FK5_BANCO
				And sa6.A6_AGENCIA = fk5.FK5_AGENCI                
				And sa6.A6_NUMCON = fk5.FK5_CONTA
				And sa6.D_E_L_E_T_  = ' '

			Left join (
				SELECT X6_VAR, X6_CONTEUD AS DESC_MOEDA_se2 FROM SX6### SX6 WHERE SX6.X6_VAR like 'MV_MOEDA%'
			) currency_se2
			ON
				TRIM(currency_se2.X6_VAR) = TRIM(CONCAT('MV_MOEDA', CAST(stg_se2.E2_MOEDA AS CHAR(2))))

			Left Join SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				sev.EV_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSEV) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSEV)
				And sev.EV_PREFIXO = stg_se2.E2_PREFIXO
				And sev.EV_NUM = stg_se2.E2_NUM
				And sev.EV_PARCELA = stg_se2.E2_PARCELA	
				And sev.EV_TIPO = stg_se2.E2_TIPO
				And sev.EV_CLIFOR = stg_se2.E2_FORNECE
				And sev.EV_LOJA = stg_se2.E2_LOJA
				And sev.EV_SEQ = fk5.FK5_SEQ
				And sev.EV_IDENT = '2' -- Baixa
				And fk5.FK5_RECPAG is not null
				And (
					(
						fk5.FK5_RECPAG = 'R'
						And sev.EV_SITUACA = 'E'
					) Or (
						fk5.FK5_RECPAG = 'P'
						And sev.EV_SITUACA IN ( 'X' , ' ')
					) 
				)
				
			Left Join SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				sev.EV_FILIAL = sez.EZ_FILIAL -- EV E EZ MESMO COMPARTILHAMENTO NAO TRATAR
				And sev.EV_PREFIXO = sez.EZ_PREFIXO
				And sev.EV_NUM = sez.EZ_NUM
				And sev.EV_PARCELA = sez.EZ_PARCELA	
				And sev.EV_TIPO = sez.EZ_TIPO
				And sev.EV_CLIFOR = sez.EZ_CLIFOR
				And sev.EV_LOJA = sez.EZ_LOJA 
				And sev.EV_NATUREZ = sez.EZ_NATUREZ 
				And sev.EV_SEQ = sez.EZ_SEQ
				And sev.EV_SITUACA = sez.EZ_SITUACA
				And sez.EZ_IDENT = '2' -- Baixa
				

			LEFT JOIN F7J### f7j
			ON 
				f7j.F7J_ALIAS = 'CPR' 
				AND Trim(f7j.F7J_STAMP) = CONVERT(CHAR(26), fk5.S_T_A_M_P_ , 121)
				AND f7j.F7J_RECNO = fk5.R_E_C_N_O_
				
			where
				(			
						(@maxStagingCounter is null)
						Or (fk5.S_T_A_M_P_ > @maxStagingCounter And @maxStagingCounter is not null)
						Or ( @param_DTINI <> ' ' and @param_DTFIM <> ' ' and  @IN_DEL  = 'S' )
					)
				AND f7j.F7J_RECNO is null
		) NF WHERE fka_rownum  = 1
	
	Union all 
	--fk5_semfka
	select 
		Origem																							as F7I_ORIGIN,
		se2_S_T_A_M_P_																					as se2_S_T_A_M_P_,
		fk7_S_T_A_M_P_																					as fk7_S_T_A_M_P_,
		fk2_S_T_A_M_P_																					as fk2_S_T_A_M_P_,
		fka_S_T_A_M_P_																					as fka_S_T_A_M_P_,
		fk5_S_T_A_M_P_																					as fk5_S_T_A_M_P_,
		fk5_Recno                                                                                       as fk5_Recno,
		EZ_MSUID																					    as EZ_MSUID,
		EV_MSUID																					    as EV_MSUID,		
		E2_FILORIG																						as E2_FILORIG,	
		E2_EMISSAO																						as F7I_EMISSA,
		E2_EMIS1																						as F7I_EMIS1,	
		COALESCE(E2_HIST,'SEM DESCRICAO')																as F7I_HIST,
		E2_TIPO			          																		as F7I_TIPO,	
		X5_DESCRI																				        as F7I_TIPDSC,
		E2_PREFIXO																						as F7I_PREFIX,
		E2_NUM																							as F7I_NUM,
		E2_PARCELA																						as F7I_PARCEL,
		E2_MOEDA																						as F7I_MOEDA,
		trim(DESC_MOEDA_se2)																			as F7I_DSCMDA,
		A6_MOEDA																						as F7I_MOEDB,
		E2_VENCTO																						as F7I_VENCTO,
		E2_VENCREA																						as F7I_VENCRE,
		FK5_DATA																						as F7I_DTPGTO,
		FK5_BANCO  																						as F7I_BANCO,
		FK5_AGENCI 																						as F7I_AGENCI,
		FK5_CONTA  																						as F7I_CONTA,
		A2_FILIAL																						as F7I_FLBENF,
		A2_COD																							as F7I_CDBENF,
		A2_LOJA																							as F7I_LJBENF,
		A2_NOME																							as F7I_NBENEF,
		FK5_IDMOV 																						as F7I_IDMOV,
		E2_BAIXA																						as E2_BAIXA,
		E2_TIPO																							as E2_TIPO,	
		E2_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as F7I_VLCRUZ,
		E2_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E2_VLCRUZ,
		E2_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E2_VALOR,
		ED_CCD																							as ED_CCD,
		ED_DEBITO																						as ED_DEBITO,
		ED_CREDIT																						as ED_CREDIT,
		E2_CCUSTO 																						as E2_CCUSTO,
		FK5_DTDISP																						as F7I_DTDISP,
		E2_NATUREZ																						as F7I_NATURE,      
		COALESCE(EV_NATUREZ,' ')																		as F7I_NATRAT,
		COALESCE(EZ_CCUSTO,' ')																			as F7I_CCDRAT,
		FK7_IDDOC																						as FK7_IDDOC,
		E2_DEBITO																						as F7I_DEBITO,
		E2_CCC																							as F7I_CCC,
		E2_CCD																							as F7I_CCD,
		E2_ITEMCTA																						as F7I_ITEMCT,
		E2_ITEMD																						as F7I_ITEMD,
		E2_ITEMC																						as F7I_ITEMC,
		E2_CLVL																							as F7I_CLVL,
		E2_CLVLDB																						as F7I_CLVLDB,
		E2_CLVLCR																						as F7I_CLVLCR,
		E2_NUMBOR																						as F7I_NUMBOR,
		FK5_HISTOR																						as F7I_HISTOR,
		FK2_TPDOC																						as FK2_TPDOC,
		E2_LOTE																							as E2_LOTE,
		FK2_IDFK2																						as FK2_IDFK2,
		FK5_RECPAG																						as FK5_RECPAG,
		FK2_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)													as FK2_VALOR,
		E2_MOEDA																						as E2_MOEDA,
		A6_MOEDA																						as A6_MOEDA,
		FK5_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)													as FK5_VALOR,
		FK5_VLMOE2 * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as FK5_VLMOE2,
		FK5_TXMOED 																						as F7I_CONVBS,
		FK5_TXMOED 																						as F7I_CONVCT,
		EV_VALOR																						as EV_VALOR,
		EZ_VALOR																						as EZ_VALOR,
		E2_CREDIT 																						as F7I_CREDIT
		,'#selectcursorflex' as cursorflex
	from (
		Select
			'fk5_semfka' as Origem,
			'##ROW_NUMBER' as fka_rownum,
			fk7_rownum,
			stg_se2.E2_PREFIXO,
			stg_se2.E2_NUM,
			stg_se2.E2_PARCELA,
			stg_se2.E2_VALOR,
			stg_se2.E2_FILORIG,
			stg_se2.E2_TIPO,
			stg_se2.E2_LOJA,
			stg_se2.E2_NATUREZ,
			stg_se2.E2_CCUSTO,
			stg_se2.E2_MOEDA,
			stg_se2.E2_LOTE,
			stg_se2.E2_EMISSAO,
			stg_se2.E2_HIST,
			stg_se2.E2_VENCTO,
			stg_se2.E2_VENCREA,
			stg_se2.E2_VLCRUZ,
			stg_se2.E2_EMIS1,            
			stg_se2.E2_BAIXA,
			stg_se2.E2_DEBITO,
			stg_se2.E2_CCD,
			stg_se2.E2_CCC,
			stg_se2.E2_ITEMCTA,
			stg_se2.E2_ITEMD,
			stg_se2.E2_ITEMC,
			stg_se2.E2_CLVL,
			stg_se2.E2_CLVLDB,
			stg_se2.E2_CLVLCR,
			stg_se2.E2_NUMBOR,
			stg_se2.E2_CREDIT,
			stg_se2.S_T_A_M_P_ as se2_S_T_A_M_P_,

			fk7.FK7_PREFIX,
			fk7.FK7_NUM,
			fk7.FK7_PARCEL,
			fk7.FK7_TIPO,
			fk7.FK7_CLIFOR,
			fk7.FK7_LOJA,
			fk7.FK7_FILIAL,
			fk7.FK7_IDDOC,
			fk7.S_T_A_M_P_ as fk7_S_T_A_M_P_,

			fk2.FK2_TPDOC,
			fk2.FK2_IDFK2,
			fk2.FK2_VALOR,
			fk2.S_T_A_M_P_ as fk2_S_T_A_M_P_,

			fka_fk2.S_T_A_M_P_ as fka_S_T_A_M_P_,		

			fk5.FK5_IDDOC,
			fk5.FK5_RECPAG,
			fk5.FK5_DATA,
			fk5.FK5_IDMOV,
			fk5.FK5_VALOR,
			fk5.FK5_BANCO,
			fk5.FK5_AGENCI,
			fk5.FK5_CONTA,
			fk5.FK5_VLMOE2,
			fk5.FK5_TXMOED,
			fk5.FK5_DTDISP,	
			fk5.FK5_HISTOR,       
			fk5.S_T_A_M_P_ as fk5_S_T_A_M_P_,
			fk5.R_E_C_N_O_ as fk5_Recno,
		
			sed.ED_DEBITO,
			sed.ED_CREDIT,
			sed.ED_CCD,

			sx5_consolidate.X5_DESCRI,

			sa2.A2_COD,
			sa2.A2_LOJA,
			sa2.A2_FILIAL,
			sa2.A2_NOME,

			sa6.A6_MOEDA,

			currency_se2.DESC_MOEDA_se2,

			sev.EV_NATUREZ,
			sev.EV_MSUID,
			sev.EV_VALOR,
			sev.EV_PERC,

			sez.EZ_CCUSTO,
			sez.EZ_MSUID,
			sez.EZ_VALOR,
			sez.EZ_PERC
			,'#campoflex' as campoflex	
		From
			(
				select
					se2.E2_FILIAL,
					se2.E2_PREFIXO,
					se2.E2_NUM,
					se2.E2_PARCELA,
					se2.E2_VALOR,
					se2.E2_FILORIG,
					se2.E2_ACRESC,
					se2.E2_DECRESC,
					se2.E2_TIPO,
					se2.E2_SALDO,
					se2.E2_NATUREZ,
					se2.E2_CCUSTO,
					se2.E2_LOTE,
					se2.E2_EMISSAO,
					se2.E2_BAIXA,
					se2.E2_HIST,
					se2.E2_VENCTO,
					se2.E2_VENCREA,
					se2.E2_VLCRUZ,
					se2.E2_EMIS1,
					se2.E2_FORNECE,
					se2.E2_LOJA,
					se2.E2_MOEDA,
					se2.E2_FORMPAG,
					se2.E2_DEBITO,
					se2.E2_CREDIT,
					se2.E2_CCD,
					se2.E2_CCC,
					se2.E2_ITEMCTA,
					se2.E2_ITEMD,
					se2.E2_ITEMC,
					se2.E2_CLVL,
					se2.E2_CLVLDB,
					se2.E2_CLVLCR,
					se2.E2_NUMBOR,
					se2.D_E_L_E_T_,
					se2.S_T_A_M_P_,
					Count(se2.E2_NUM) as se2_rownum
					,'#campoflexprincipal' as campoflexprincipal
				From 
					SE2### se2 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
				Where
					((@maxStagingCounter is null and (se2.E2_BAIXA  >= @param_DTINI or se2.E2_EMIS1  >= @param_DTINI  )) or se2.S_T_A_M_P_ > @maxStagingCounter )
					And RIGHT(se2.E2_TIPO, 1) <> '-'
					And se2.E2_TIPO <> 'PR '
				Group by
					se2.E2_FILIAL,
					se2.E2_PREFIXO,
					se2.E2_NUM,
					se2.E2_PARCELA,
					se2.E2_VALOR,
					se2.E2_FILORIG,
					se2.E2_ACRESC,
					se2.E2_DECRESC,
					se2.E2_TIPO,
					se2.E2_SALDO,
					se2.E2_NATUREZ,
					se2.E2_CCUSTO,
					se2.E2_LOTE,
					se2.E2_EMISSAO,
					se2.E2_BAIXA,
					se2.E2_HIST,
					se2.E2_VENCTO,
					se2.E2_VENCREA,
					se2.E2_VLCRUZ,
					se2.E2_EMIS1,
					se2.E2_FORNECE,
					se2.E2_LOJA,
					se2.E2_MOEDA,
					se2.E2_FORMPAG,
					se2.E2_DEBITO,
					se2.E2_CREDIT,
					se2.E2_CCD,
					se2.E2_CCC,
					se2.E2_ITEMCTA,
					se2.E2_ITEMD,
					se2.E2_ITEMC,
					se2.E2_CLVL,
					se2.E2_CLVLDB,
					se2.E2_CLVLCR,
					se2.E2_NUMBOR,
					se2.D_E_L_E_T_,
					se2.S_T_A_M_P_
					,'#campoflexprincipal' as campoflexprincipal
			) stg_se2
	
			Inner join (
				Select 
					fk7.FK7_FILTIT,
					fk7.FK7_PREFIX,
					fk7.FK7_NUM,
					fk7.FK7_PARCEL,
					fk7.FK7_TIPO,
					fk7.FK7_CLIFOR,
					fk7.FK7_LOJA,
					fk7.FK7_FILIAL,
					fk7.FK7_IDDOC,
					fk7.FK7_ALIAS,
					fk7.FK7_CHAVE,
					fk7.D_E_L_E_T_,
					fk7.S_T_A_M_P_,
					Count(fk7.FK7_NUM) as fk7_rownum
				From 
					FK7### fk7 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
				Where
					FK7_ALIAS = 'SE2'
				Group By
					fk7.FK7_FILTIT,
					fk7.FK7_PREFIX,
					fk7.FK7_NUM,
					fk7.FK7_PARCEL,
					fk7.FK7_TIPO,
					fk7.FK7_CLIFOR,
					fk7.FK7_LOJA,
					fk7.FK7_FILIAL,
					fk7.FK7_IDDOC,
					fk7.FK7_ALIAS,
					fk7.FK7_CHAVE,
					fk7.D_E_L_E_T_,
					fk7.S_T_A_M_P_
			) fk7
				On
					stg_se2.E2_FILIAL = fk7.FK7_FILTIT --FILTIT GRAVADO COM A FILIAL DA E1/E2 (NAO TRATAR)
					And stg_se2.E2_PREFIXO = fk7.FK7_PREFIX
					And stg_se2.E2_NUM = fk7.FK7_NUM
					And stg_se2.E2_PARCELA = fk7.FK7_PARCEL
					And stg_se2.E2_TIPO = fk7.FK7_TIPO
					And stg_se2.E2_FORNECE = fk7.FK7_CLIFOR
					And stg_se2.E2_LOJA = fk7.FK7_LOJA
					And stg_se2.D_E_L_E_T_ = fk7.D_E_L_E_T_
					And stg_se2.se2_rownum = fk7.fk7_rownum

			Left join FK2### fk2 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on
				fk2.FK2_FILORI = stg_se2.E2_FILORIG -- amarrado com FILORI em ambas (nao tratar)
				And fk2.FK2_IDDOC = fk7.FK7_IDDOC
				And fk2.FK2_MOTBX Not In ('LIQ','CEC','CMP')
				And fk2.D_E_L_E_T_ = ' '

			Left join FKA### fka_fk2 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on         				
				fka_fk2.FKA_FILIAL = fk2.FK2_FILIAL -- mesmo nivel de compartilhamento (nao tratar)
				And fka_fk2.FKA_IDORIG = fk2.FK2_IDFK2
				And fka_fk2.FKA_TABORI = 'FK2'

			Inner join FKA### fka_fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on         
				fka_fk5.FKA_FILIAL = fk2.FK2_FILIAL -- mesmo nivel de compartilhamento (nao tratar)
				And fka_fk2.FKA_IDPROC = fka_fk5.FKA_IDPROC
				And fka_fk5.FKA_TABORI = 'FK5'

			Inner join FK5### fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				fk5.FK5_FILORI = stg_se2.E2_FILORIG -- amarrado com FILORI em ambas (nao tratar)
				And fk5.FK5_DATA >= @param_DTINI
				And fk5.FK5_ORDREC = ' '
				And (
					(
						-- Bx em lote
						fk2.FK2_DATA = fk5.FK5_DATA
						And fk2.FK2_LOTE = fk5.FK5_LOTE
						And fka_fk5.FKA_IDORIG <> fk5.FK5_IDMOV
						And fk2.FK2_TPDOC = 'BA' 
						And fk5.FK5_TPDOC <> 'PA' --PA pode ter sido baixado em lote tbm.
						And fk5.FK5_RECPAG = 'P' 
						And fk5.FK5_LOTE <> ' '
					) Or (
						-- Estorno de Bx em lote
						fk2.FK2_DATA = fk5.FK5_DATA
						And fk2.FK2_LOTE = fk5.FK5_LOTE
						And fk2.FK2_VALOR = fk5.FK5_VALOR
						And fka_fk5.FKA_IDORIG <> fk5.FK5_IDMOV
						And fk2.FK2_TPDOC = 'ES'  
						And fk5.FK5_RECPAG = 'R'  
						And fk5.FK5_LOTE <> ' '
					)
				)
			Inner join SED### sed
			on
				sed.ED_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSED) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSED)
				And sed.ED_CODIGO = stg_se2.E2_NATUREZ
				And sed.D_E_L_E_T_ = ' '

			inner join SX5### sx5_consolidate ON sx5_consolidate.X5_FILIAL  = SUBSTRING ( stg_se2.E2_FILORIG , 1 , @IN_TAMSX5 ) || REPLICATE ( ' ' , @N_TAMTOTAL  - @IN_TAMSX5 )
				And sx5_consolidate.X5_TABELA = '05' 
				And sx5_consolidate.X5_CHAVE  = stg_se2.E2_TIPO 
				And sx5_consolidate.D_E_L_E_T_  = ' '

			Left join SA2### sa2
			On
				sa2.A2_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSA2) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSA2)
				And sa2.A2_COD = stg_se2.E2_FORNECE
				And sa2.A2_LOJA = stg_se2.E2_LOJA
				And sa2.D_E_L_E_T_  = ' '

			Left Join SA6### sa6
			On		  
			  sa6.A6_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSA6) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSA6)
			  And sa6.A6_COD = fk5.FK5_BANCO
			  And sa6.A6_AGENCIA = fk5.FK5_AGENCI                
			  And sa6.A6_NUMCON = fk5.FK5_CONTA
			  And sa6.D_E_L_E_T_  = ' '

			Left join (
				SELECT X6_VAR, X6_CONTEUD AS DESC_MOEDA_se2 FROM SX6### SX6 WHERE SX6.X6_VAR like 'MV_MOEDA%'
			) currency_se2
			ON
				TRIM(currency_se2.X6_VAR) = TRIM(CONCAT('MV_MOEDA', CAST(stg_se2.E2_MOEDA AS CHAR(2))))
			
			Left Join SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				sev.EV_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSEV) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSEV)
				And sev.EV_PREFIXO = stg_se2.E2_PREFIXO
				And sev.EV_NUM = stg_se2.E2_NUM
				And sev.EV_PARCELA = stg_se2.E2_PARCELA	
				And sev.EV_TIPO = stg_se2.E2_TIPO
				And sev.EV_CLIFOR = stg_se2.E2_FORNECE
				And sev.EV_LOJA = stg_se2.E2_LOJA
				And sev.EV_SEQ = fk5.FK5_SEQ
				And sev.EV_IDENT = '2' -- Baixa
				And fk5.FK5_RECPAG is not null
				And (
					(
						fk5.FK5_RECPAG = 'R'
						And sev.EV_SITUACA = 'E'
					) Or (
						fk5.FK5_RECPAG = 'P'
						And sev.EV_SITUACA IN ( 'X' , ' ')
					) 
				)
				

			Left Join SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				sev.EV_FILIAL = sez.EZ_FILIAL -- EV E EZ MESMO COMPARTILHAMENTO NAO TRATAR
				And sev.EV_PREFIXO = sez.EZ_PREFIXO
				And sev.EV_NUM = sez.EZ_NUM
				And sev.EV_PARCELA = sez.EZ_PARCELA	
				And sev.EV_TIPO = sez.EZ_TIPO
				And sev.EV_CLIFOR = sez.EZ_CLIFOR
				And sev.EV_LOJA = sez.EZ_LOJA 
				And sev.EV_NATUREZ = sez.EZ_NATUREZ 
				And sev.EV_SEQ = sez.EZ_SEQ
				And sev.EV_SITUACA = sez.EZ_SITUACA  
				And sez.EZ_IDENT = '2' -- Baixa
				

			LEFT JOIN F7J### f7j
			ON 
				f7j.F7J_ALIAS = 'CPR' 
				AND Trim(f7j.F7J_STAMP) = CONVERT(CHAR(26), fk5.S_T_A_M_P_ , 121)
				AND f7j.F7J_RECNO = fk5.R_E_C_N_O_
			
			where
				(			
					(@maxStagingCounter is null)
					Or (fk5.S_T_A_M_P_ > @maxStagingCounter And @maxStagingCounter is not null)
					Or ( @param_DTINI <> ' ' and @param_DTFIM <> ' ' and  @IN_DEL  = 'S' )
				)
				AND f7j.F7J_RECNO is null
		) Fk5_sem_Fka
			Where fka_rownum = 1

	Union All
	--PA
	select 
		Origem																							as F7I_ORIGIN,
		se2_S_T_A_M_P_																					as se2_S_T_A_M_P_,
		fk7_S_T_A_M_P_																					as fk7_S_T_A_M_P_,
		fk2_S_T_A_M_P_																					as fk2_S_T_A_M_P_,
		fka_S_T_A_M_P_																					as fka_S_T_A_M_P_,
		fk5_S_T_A_M_P_																					as fk5_S_T_A_M_P_,	
		fk5_Recno                                                                                       as fk5_Recno,	
		EZ_MSUID																					    as EZ_MSUID,
		EV_MSUID																					    as EV_MSUID,		
		E2_FILORIG																						as E2_FILORIG,	
		E2_EMISSAO																						as F7I_EMISSA,
		E2_EMIS1																						as F7I_EMIS1,	
		COALESCE(E2_HIST,' ')																			as F7I_HIST,
		E2_TIPO			          																		as F7I_TIPO,	
		X5_DESCRI																				        as F7I_TIPDSC,
		E2_PREFIXO																						as F7I_PREFIX,
		E2_NUM																							as F7I_NUM,
		E2_PARCELA																						as F7I_PARCEL,
		E2_MOEDA																						as F7I_MOEDA,
		trim(DESC_MOEDA_se2)																			as F7I_DSCMDA,
		A6_MOEDA																						as F7I_MOEDB,
		E2_VENCTO																						as F7I_VENCTO,
		E2_VENCREA																						as F7I_VENCRE,
		FK5_DATA																						as F7I_DTPGTO,
		FK5_BANCO  																						as F7I_BANCO,
		FK5_AGENCI 																						as F7I_AGENCI,
		FK5_CONTA  																						as F7I_CONTA,
		A2_FILIAL																						as F7I_FLBENF,
		A2_COD																							as F7I_CDBENF,
		A2_LOJA																							as F7I_LJBENF,
		A2_NOME																							as F7I_NBENEF,
		FK5_IDMOV 																						as F7I_IDMOV,
		E2_BAIXA																						as E2_BAIXA,
		E2_TIPO																							as E2_TIPO,	
		E2_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as F7I_VLCRUZ,
		E2_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E2_VLCRUZ,
		E2_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E2_VALOR,
		ED_CCD																							as ED_CCD,
		ED_DEBITO																						as ED_DEBITO,
		ED_CREDIT																						as ED_CREDIT,
		E2_CCUSTO																						as E2_CCUSTO,
		FK5_DTDISP																						as F7I_DTDISP,
		E2_NATUREZ																						as F7I_NATURE,      
		COALESCE(EV_NATUREZ,' ')																		as F7I_NATRAT,
		COALESCE(EZ_CCUSTO,' ')																			as F7I_CCDRAT,
		FK7_IDDOC																						as FK7_IDDOC,
		E2_DEBITO																						as F7I_DEBITO,
		E2_CCC																							as F7I_CCC,
		E2_CCD																							as F7I_CCD,
		E2_ITEMCTA																						as F7I_ITEMCT,
		E2_ITEMD																						as F7I_ITEMD,
		E2_ITEMC																						as F7I_ITEMC,
		E2_CLVL																							as F7I_CLVL,
		E2_CLVLDB																						as F7I_CLVLDB,
		E2_CLVLCR																						as F7I_CLVLCR,
		E2_NUMBOR																						as F7I_NUMBOR,
		FK5_HISTOR																						as F7I_HISTOR,
		FK2_TPDOC																						as FK2_TPDOC,
		E2_LOTE																							as E2_LOTE,
		FK2_IDFK2																						as FK2_IDFK2,
		FK5_RECPAG																						as FK5_RECPAG,
		FK2_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)													as FK2_VALOR,
		E2_MOEDA																						as E2_MOEDA,
		A6_MOEDA																						as A6_MOEDA,
		FK5_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)													as FK5_VALOR,
		FK5_VLMOE2 * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as FK5_VLMOE2,
		FK5_TXMOED 																						as F7I_CONVBS,
		FK5_TXMOED 																						as F7I_CONVCT,			
		EV_VALOR																						as EV_VALOR,
		EZ_VALOR																						as EZ_VALOR,
		E2_CREDIT 																						as F7I_CREDIT
		,'#selectcursorflex' as cursorflex			
	from (
		Select
			'PA' as Origem,
			'##ROW_NUMBER' as fka_rownum,
			fk7_rownum,
			stg_se2.E2_PREFIXO,
			stg_se2.E2_NUM,
			stg_se2.E2_PARCELA,
			stg_se2.E2_VALOR,
			stg_se2.E2_FILORIG,
			stg_se2.E2_TIPO,
			stg_se2.E2_LOJA,
			stg_se2.E2_NATUREZ,
			stg_se2.E2_CCUSTO,
			stg_se2.E2_MOEDA,
			stg_se2.E2_LOTE,
			stg_se2.E2_EMISSAO,
			stg_se2.E2_HIST,
			stg_se2.E2_VENCTO,
			stg_se2.E2_VENCREA,
			stg_se2.E2_VLCRUZ,
			stg_se2.E2_EMIS1,            
			stg_se2.E2_BAIXA,
			stg_se2.E2_DEBITO,
			stg_se2.E2_CCD,
			stg_se2.E2_CCC,
			stg_se2.E2_ITEMCTA,
			stg_se2.E2_ITEMD,
			stg_se2.E2_ITEMC,
			stg_se2.E2_CLVL,
			stg_se2.E2_CLVLDB,
			stg_se2.E2_CLVLCR,
			stg_se2.E2_NUMBOR,
			stg_se2.E2_CREDIT,
			stg_se2.S_T_A_M_P_ as se2_S_T_A_M_P_,

			fk7.FK7_PREFIX,
			fk7.FK7_NUM,
			fk7.FK7_PARCEL,
			fk7.FK7_TIPO,
			fk7.FK7_CLIFOR,
			fk7.FK7_LOJA,
			fk7.FK7_FILIAL,
			fk7.FK7_IDDOC,
			fk7.S_T_A_M_P_ as fk7_S_T_A_M_P_,

			fk2.FK2_TPDOC,
			fk2.FK2_IDFK2,
			fk2.FK2_VALOR,
			fk2.S_T_A_M_P_ as fk2_S_T_A_M_P_,

			fka.S_T_A_M_P_ as fka_S_T_A_M_P_,

			fk5.FK5_IDDOC,
			fk5.FK5_RECPAG,
			fk5.FK5_DATA,
			fk5.FK5_IDMOV,
			fk5.FK5_VALOR,
			fk5.FK5_BANCO,
			fk5.FK5_AGENCI,
			fk5.FK5_CONTA,
			fk5.FK5_VLMOE2,
			fk5.FK5_TXMOED,
			fk5.FK5_DTDISP,	
			fk5.FK5_HISTOR,        
			fk5.S_T_A_M_P_ as fk5_S_T_A_M_P_,
			fk5.R_E_C_N_O_ as fk5_Recno,
	
			sed.ED_DEBITO,
			sed.ED_CREDIT,
			sed.ED_CCD,

			sx5_consolidate.X5_DESCRI,

			sa2.A2_COD,
			sa2.A2_LOJA,
			sa2.A2_FILIAL,
			sa2.A2_NOME,

			sa6.A6_MOEDA,

			currency_se2.DESC_MOEDA_se2,

			sev.EV_NATUREZ,
			sev.EV_MSUID,
			sev.EV_VALOR,
			sev.EV_PERC,

			sez.EZ_CCUSTO,
			sez.EZ_MSUID,
			sez.EZ_VALOR,
			sez.EZ_PERC	
			,'#campoflex' as campoflex	
		From
			(
				select
					se2.E2_FILIAL,
					se2.E2_PREFIXO,
					se2.E2_NUM,
					se2.E2_PARCELA,
					se2.E2_VALOR,
					se2.E2_FILORIG,
					se2.E2_ACRESC,
					se2.E2_DECRESC,
					se2.E2_TIPO,
					se2.E2_SALDO,
					se2.E2_NATUREZ,
					se2.E2_CCUSTO,
					se2.E2_LOTE,
					se2.E2_EMISSAO,
					se2.E2_BAIXA,
					se2.E2_HIST,
					se2.E2_VENCTO,
					se2.E2_VENCREA,
					se2.E2_VLCRUZ,
					se2.E2_EMIS1,
					se2.E2_FORNECE,
					se2.E2_LOJA,
					se2.E2_MOEDA,
					se2.E2_FORMPAG,
					se2.E2_DEBITO,
					se2.E2_CREDIT,
					se2.E2_CCD,
					se2.E2_CCC,
					se2.E2_ITEMCTA,
					se2.E2_ITEMD,
					se2.E2_ITEMC,
					se2.E2_CLVL,
					se2.E2_CLVLDB,
					se2.E2_CLVLCR,
					se2.E2_NUMBOR,
					se2.D_E_L_E_T_,
					se2.S_T_A_M_P_,
					Count(se2.E2_NUM) as se2_rownum
					,'#campoflexprincipal' as campoflexprincipal
				From 
					SE2### se2 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
				Where
					((@maxStagingCounter is null and (se2.E2_BAIXA  >= @param_DTINI or se2.E2_EMIS1  >= @param_DTINI  )) or se2.S_T_A_M_P_ > @maxStagingCounter )
					And se2.E2_TIPO = 'PA '
				Group by
					se2.E2_FILIAL,
					se2.E2_PREFIXO,
					se2.E2_NUM,
					se2.E2_PARCELA,
					se2.E2_VALOR,
					se2.E2_FILORIG,
					se2.E2_ACRESC,
					se2.E2_DECRESC,
					se2.E2_TIPO,
					se2.E2_SALDO,
					se2.E2_NATUREZ,
					se2.E2_CCUSTO,
					se2.E2_LOTE,
					se2.E2_EMISSAO,
					se2.E2_BAIXA,
					se2.E2_HIST,
					se2.E2_VENCTO,
					se2.E2_VENCREA,
					se2.E2_VLCRUZ,
					se2.E2_EMIS1,
					se2.E2_FORNECE,
					se2.E2_LOJA,
					se2.E2_MOEDA,
					se2.E2_FORMPAG,
					se2.E2_DEBITO,
					se2.E2_CREDIT,
					se2.E2_CCD,
					se2.E2_CCC,
					se2.E2_ITEMCTA,
					se2.E2_ITEMD,
					se2.E2_ITEMC,
					se2.E2_CLVL,
					se2.E2_CLVLDB,
					se2.E2_CLVLCR,
					se2.E2_NUMBOR,
					se2.D_E_L_E_T_,
					se2.S_T_A_M_P_
					,'#campoflexprincipal' as campoflexprincipal
			) stg_se2
	
			Inner join (
				Select 
					fk7.FK7_FILTIT,
					fk7.FK7_PREFIX,
					fk7.FK7_NUM,
					fk7.FK7_PARCEL,
					fk7.FK7_TIPO,
					fk7.FK7_CLIFOR,
					fk7.FK7_LOJA,
					fk7.FK7_FILIAL,
					fk7.FK7_IDDOC,
					fk7.FK7_ALIAS,
					fk7.FK7_CHAVE,
					fk7.D_E_L_E_T_,
					fk7.S_T_A_M_P_,
					Count(fk7.FK7_NUM) as fk7_rownum
				From 
					FK7### fk7 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
				Where
					FK7_ALIAS = 'SE2'
				Group By
					fk7.FK7_FILTIT,
					fk7.FK7_PREFIX,
					fk7.FK7_NUM,
					fk7.FK7_PARCEL,
					fk7.FK7_TIPO,
					fk7.FK7_CLIFOR,
					fk7.FK7_LOJA,
					fk7.FK7_FILIAL,
					fk7.FK7_IDDOC,
					fk7.FK7_ALIAS,
					fk7.FK7_CHAVE,
					fk7.D_E_L_E_T_,
					fk7.S_T_A_M_P_
			) fk7
				On
					stg_se2.E2_FILIAL = fk7.FK7_FILTIT --FILTIT GRAVADO COM A FILIAL DA E1/E2 (NAO TRATAR)
					And stg_se2.E2_PREFIXO = fk7.FK7_PREFIX
					And stg_se2.E2_NUM = fk7.FK7_NUM
					And stg_se2.E2_PARCELA = fk7.FK7_PARCEL
					And stg_se2.E2_TIPO = fk7.FK7_TIPO
					And stg_se2.E2_FORNECE = fk7.FK7_CLIFOR
					And stg_se2.E2_LOJA = fk7.FK7_LOJA
					And stg_se2.D_E_L_E_T_ = fk7.D_E_L_E_T_
					And stg_se2.se2_rownum = fk7.fk7_rownum

			Left join FK2### fk2 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on
				fk2.FK2_FILORI = stg_se2.E2_FILORIG -- amarrado com FILORI em ambas (nao tratar)	
				And fk2.FK2_IDDOC = fk7.FK7_IDDOC
				And fk2.FK2_MOTBX Not In ('LIQ','CEC','CMP')
				And fk2.D_E_L_E_T_ = ' '

			INNER join FK5### fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				  fk5.FK5_FILORI = stg_se2.E2_FILORIG
				  And fk5.FK5_IDDOC = fk7.FK7_IDDOC 
				  And fk5.FK5_DATA >= @param_DTINI
				  And fk5.FK5_ORDREC = ' '
		
			Inner join FKA### fka LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on
				-- mesmo nivel de compartilhamento (nao tratar)
				( 
					(
						fka.FKA_FILIAL = fk2.FK2_FILIAL 
						And fka.FKA_IDORIG = fk2.FK2_IDFK2
					) or (
						fka.FKA_FILIAL = fk5.FK5_FILIAL
						And fka.FKA_IDORIG = fk5.FK5_IDMOV
					)
				)
				And FKA_TABORI in ('FK2','FK5' )
			
			Inner join SED### sed
			on
				sed.ED_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSED) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSED)
				And sed.ED_CODIGO = stg_se2.E2_NATUREZ
				And sed.D_E_L_E_T_ = ' '

			inner join SX5### sx5_consolidate ON sx5_consolidate.X5_FILIAL  = SUBSTRING ( stg_se2.E2_FILORIG , 1 , @IN_TAMSX5 ) || REPLICATE ( ' ' , @N_TAMTOTAL  - @IN_TAMSX5 )
				And sx5_consolidate.X5_TABELA = '05' 
				And sx5_consolidate.X5_CHAVE  = stg_se2.E2_TIPO 
				And sx5_consolidate.D_E_L_E_T_  = ' '

			Left join SA2### sa2
			On
				sa2.A2_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSA2) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSA2)
				And sa2.A2_COD = stg_se2.E2_FORNECE
				And sa2.A2_LOJA = stg_se2.E2_LOJA
				And sa2.D_E_L_E_T_  = ' '

			Left Join SA6### sa6
			On		  
			  sa6.A6_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSA6) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSA6)
			  And sa6.A6_COD = fk5.FK5_BANCO
			  And sa6.A6_AGENCIA = fk5.FK5_AGENCI                
			  And sa6.A6_NUMCON = fk5.FK5_CONTA
			  And sa6.D_E_L_E_T_  = ' '

			Left join (
				SELECT X6_VAR, X6_CONTEUD AS DESC_MOEDA_se2 FROM SX6### SX6 WHERE SX6.X6_VAR like 'MV_MOEDA%'
			) currency_se2
			ON
				TRIM(currency_se2.X6_VAR) = TRIM(CONCAT('MV_MOEDA', CAST(stg_se2.E2_MOEDA AS CHAR(2))))
				
			Left join (
				SELECT X6_VAR, X6_CONTEUD AS DESC_MOEDA_sa6 FROM SX6### SX6 WHERE SX6.X6_VAR like 'MV_MOEDA%'
			) currency_sa6
			ON
				TRIM(currency_sa6.X6_VAR) = TRIM(CONCAT('MV_MOEDA', CAST(stg_se2.E2_MOEDA AS CHAR(2))))

			Left Join SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				sev.EV_FILIAL = SUBSTRING(stg_se2.E2_FILORIG,1,@IN_TAMSEV) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSEV)
				And sev.EV_PREFIXO = stg_se2.E2_PREFIXO
				And sev.EV_NUM = stg_se2.E2_NUM
				And sev.EV_PARCELA = stg_se2.E2_PARCELA	
				And sev.EV_TIPO = stg_se2.E2_TIPO
				And sev.EV_CLIFOR = stg_se2.E2_FORNECE
				And sev.EV_LOJA = stg_se2.E2_LOJA
				And sev.EV_SEQ = fk5.FK5_SEQ
				And sev.EV_IDENT = '2' -- Baixa
				And fk5.FK5_RECPAG is not null
				And (
					(
						fk5.FK5_RECPAG  = 'R' 
						And sev.EV_SITUACA = 'E'
					) Or (
						fk5.FK5_RECPAG  = 'P' 
						And sev.EV_SITUACA IN ( 'X' , ' ')
					) 
				)
				

			Left Join SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				sev.EV_FILIAL = sez.EZ_FILIAL -- EV E EZ MESMO COMPARTILHAMENTO NAO TRATAR
				And sev.EV_PREFIXO = sez.EZ_PREFIXO
				And sev.EV_NUM = sez.EZ_NUM
				And sev.EV_PARCELA = sez.EZ_PARCELA	
				And sev.EV_TIPO = sez.EZ_TIPO
				And sev.EV_CLIFOR = sez.EZ_CLIFOR
				And sev.EV_LOJA = sez.EZ_LOJA 
				And sev.EV_NATUREZ = sez.EZ_NATUREZ 
				And sev.EV_SEQ = sez.EZ_SEQ
				And sev.EV_SITUACA = sez.EZ_SITUACA
				And sez.EZ_IDENT = '2' -- Baixa

			LEFT JOIN F7J### f7j
			ON 
				f7j.F7J_ALIAS = 'CPR' 
				AND Trim(f7j.F7J_STAMP) = CONVERT(CHAR(26), fk5.S_T_A_M_P_ , 121)
				AND f7j.F7J_RECNO = fk5.R_E_C_N_O_
			where
				(			
					(@maxStagingCounter is null)
					Or (fk5.S_T_A_M_P_ > @maxStagingCounter And @maxStagingCounter is not null)
					Or ( @param_DTINI <> ' ' and @param_DTFIM <> ' ' and  @IN_DEL  = 'S' )	
				) 
				AND f7j.F7J_RECNO is null
		) PA
			Where fka_rownum = 1
	
	for read only
	
	open curPagarR
		fetch next from curPagarR
			into @F7I_ORIGIN,
				@se2_S_T_A_M_P_,
				@fk7_S_T_A_M_P_,
				@fk2_S_T_A_M_P_,
				@fka_S_T_A_M_P_,
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
				@F7I_MOEDA,
				@F7I_DSCMDA,
				@F7I_MOEDB,
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
				@E2_BAIXA,
				@E2_TIPO,				 				 
				@F7I_VLCRUZ,				 
				@E2_VLCRUZ,
				@E2_VALOR,
				@ED_CCD,
				@ED_DEBITO,
				@ED_CREDIT,
				@E2_CCUSTO,
				@F7I_DTDISP,
				@F7I_NATURE,
				@F7I_NATRAT,
				@F7I_CCDRAT,				 
				@FK7_IDDOC,
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
				@FK2_TPDOC,
				@E2_LOTE,
				@FK2_IDFK2,
				@FK5_RECPAG,
				@FK2_VALOR,
				@E2_MOEDA,
				@A6_MOEDA,
				@FK5_VALOR,
				@FK5_VLMOE2,
				@F7I_CONVBS,
				@F7I_CONVCT,
				@EV_VALOR,
				@EZ_VALOR,
				@F7I_CREDIT
				--#cursorflex

	While ( (@@fetch_Status  = 0 ) )
	Begin			 
		select @F7I_VLPROP = 0
		select @F7I_CONVBS = ROUND(@F7I_CONVBS,@DecCONVBS)
		select @F7I_CONVCT = @F7I_CONVBS

		---------------------------------------------
		--Tratamento CT1
		---------------------------------------------
		
		If ( @FK5_RECPAG = 'R' AND @ED_CREDIT <> ' ' )
			Begin 
				exec XFILIAL_## 'CT1', @E2_FILORIG, @filialCT1 OutPut
				Select @F7I_CNTCTB = CT1_CONTA , @F7I_DSCCTB = SUBSTRING(CT1_DESC01,1,40) , @F7I_NATCTA = CT1_NATCTA FROM CT1### Where CT1_FILIAL = @filialCT1 AND CT1_CONTA = @ED_CREDIT AND D_E_L_E_T_ = ' '
			End
		Else
			Begin 			
				If ( @FK5_RECPAG = 'P' AND @ED_DEBITO <> ' ')
					Begin
						exec XFILIAL_## 'CT1', @E2_FILORIG, @filialCT1 OutPut
						Select @F7I_CNTCTB = CT1_CONTA , @F7I_DSCCTB = SUBSTRING(CT1_DESC01,1,40) , @F7I_NATCTA = CT1_NATCTA FROM CT1### Where CT1_FILIAL = @filialCT1 AND CT1_CONTA = @ED_DEBITO AND D_E_L_E_T_ = ' '
					End
			End

		If ( @F7I_CNTCTB = ' ' or @F7I_CNTCTB is null )
			Begin
				select @F7I_CNTCTB = '0'
			End

		---------------------------------------------
		--FIM Tratamento CT1
		---------------------------------------------


		---------------------------------------------
		--Tratamento Campo @F7I_EXTCDH
		---------------------------------------------
		If( Trim(@FK2_TPDOC) = 'BA' And @E2_LOTE <> ' ' )
			Begin 
				select @F7I_EXTCDH = @FK2_IDFK2
			End
		Else
			Begin
				select @F7I_EXTCDH = @F7I_IDMOV
			End

		---------------------------------------------
		--Tratamento Campo @F7I_EXTCDD
		---------------------------------------------
		If (  @EZ_MSUID is not null )
			Begin 
				select @F7I_EXTCDD = @EZ_MSUID			
			End
			Else
				Begin 			
					If ( @EV_MSUID is not null )
						Begin 
							select @F7I_EXTCDD = @EV_MSUID
						End
					Else
						Begin
							If( Trim(@FK2_TPDOC) = 'BA' And @E2_LOTE <> ' ' )
								Begin 
									select @F7I_EXTCDD = @FK2_IDFK2								
								End
							Else
								Begin
									select @F7I_EXTCDD = @F7I_IDMOV
								End
						End
				End

		---------------------------------------------
		--Tratamento Campo @F7I_HIST
		---------------------------------------------	
		If (@F7I_HIST = ' ')
			Begin
				select @F7I_HIST = 'SEM DESCRICAO'
			End
		---------------------------------------------
		--Tratamento Campo @F7I_TPEVNT
		---------------------------------------------
		If(  @FK5_RECPAG ='P' )
			Begin 
				select @F7I_TPEVNT = 'S'
			End
		Else
			Begin
				select @F7I_TPEVNT = 'E'
			End

		---------------------------------------------
		--Tratamento Campo @F7I_SALDO
		---------------------------------------------
		If( Trim(@FK2_TPDOC) = 'BA' And @E2_LOTE <> ' ' )
			Begin 
				select @F7I_SALDO = @FK2_VALOR
			End
		Else
			Begin
				If( @E2_MOEDA = @A6_MOEDA )
					Begin
						select @F7I_SALDO = @FK5_VALOR	
					End
				Else
					Begin
						select @F7I_SALDO = @FK5_VLMOE2	
					End			
			End

		---------------------------------------------
		SELECT @F7I_VLPROP = @F7I_SALDO
		---------------------------------------------
		---------------------------------------------
		--Tratamento Campo @F7I_FXRTBS,@F7I_FXRTCT
		---------------------------------------------

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

		---------------------------------------------
		--Tratamento Campo @F7I_VLRCNT 
		---------------------------------------------
		If ( @F7I_ORIGIN = 'PA' )
			Begin
				select @F7I_VLRCNT = @FK5_VALOR				
			End
		Else
			Begin
				select @F7I_VLRCNT = 0				
			End

		----------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Inicio Tratamento Descricao Custo
		----------------------------------------------------------------------------------------------------------------------------------------------------------
		
		SELECT @F7I_CCUSTO = @ED_CCD
		IF @ED_CCD <> ' '
			Begin
				exec XFILIAL_## 'CTT', @E2_FILORIG, @filialCTT OutPut
				SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @ED_CCD AND D_E_L_E_T_ = ' ')
			End
		------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Fim Tratamento Descricao Custo
		------------------------------------------------------------------------------------------------------------------------------------------------------------
		/**********************************************************************************************************************************************************/
		-- Inicio do tratamento stamp transacao
		/**********************************************************************************************************************************************************/
		If ( @fk5_S_T_A_M_P_ is null )
				Begin 
					Select @cFk5_STAMP = @delTransactTime
				End	
			Else 
				Begin
					Select @cFk5_STAMP = CONVERT(CHAR(26), @fk5_S_T_A_M_P_, 121)
				End 	
			
		/**********************************************************************************************************************************************************/
		-- Fim do tratamento stamp transacao
		/**********************************************************************************************************************************************************/
		---------------------------------------------
		--Tratamento Campo @cF7I_STAMP
		---------------------------------------------		
		select @cF7I_STAMP = @cFk5_STAMP
		/**********************************************************************************************************************************************************/
		-- Fim do tratamento dos campos para serem gravados na tabela F7I
		/**********************************************************************************************************************************************************/
		
		/**********************************************************************************************************************************************************/
		-- Inicio do tratamento DESCRICAO DA MEDA A6
		/**********************************************************************************************************************************************************/
		If ( @F7I_MOEDA = @F7I_MOEDB)
			Begin
				Select @F7I_DSCMDB = @F7I_DSCMDA
			End 
		Else
			Begin
				If (@F7I_MOEDB > 0)
					Begin
						Select @F7I_DSCMDB = ( SELECT SX6C.X6_CONTEUD FROM SX6### SX6C WHERE TRIM(SX6C.X6_VAR) = CONCAT('MV_MOEDA' , TRIM(CAST(@F7I_MOEDB AS CHAR(2)))) AND SX6C.D_E_L_E_T_ = ' ' )
					End
			End
		/**********************************************************************************************************************************************************/
		-- Fim do tratamento DESCRICAO DA MEDA A6
		/**********************************************************************************************************************************************************/
		
		/**********************************************************************************************************************************************************/
		--correcao para arredondamento de conversao ocorre apenas em mssql
		##IF_001({|| Trim(TcGetDb()) == "MSSQL" })
			IF  @cFk5_STAMP  NOT LIKE '%.%'
				BEGIN 
					SELECT @cFk5_STAMP = TRIM(@cFk5_STAMP) + '.000' 
				END
			IF  @cF7I_STAMP NOT LIKE '%.%'
				BEGIN 
					SELECT @cF7I_STAMP = TRIM(@cF7I_STAMP) + '.000' 
				END
		##ENDIF_001


		SELECT @param_COMPANIA = SUBSTRING(@E2_FILORIG,1, @IN_TAMEMP )
		SELECT @param_COD_UNID = SUBSTRING(@E2_FILORIG,@IN_TAMEMP+1, @IN_TAMUNIT)
		SELECT @param_COD_FIL  = SUBSTRING(@E2_FILORIG,@IN_TAMEMP+1 + @IN_TAMUNIT , @IN_TAMEMP + @IN_TAMUNIT + @IN_TAMFIL)
		/**********************************************************************************************************************************************************/
		-- Inclusão dos registros
		/**********************************************************************************************************************************************************/
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
			F7I_VLRCNT
			--#insertflex
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
			IsNull(SUBSTRING(@F7I_DSCMDA,1,10), ' '),
			IsNull(@F7I_MOEDB, 0), -- Alguns cadastros de banco não possuem moeda cadastrada
			IsNull(SUBSTRING(@F7I_DSCMDB,1,10), ' '),   
			@F7I_VENCTO, 
			@F7I_VENCRE, 
			@F7I_DTPGTO,   
			@F7I_BANCO,   
			@F7I_AGENCI,    
			@F7I_CONTA,   
			IsNull(@F7I_FLBENF, ' '),	 
			IsNull(@F7I_CDBENF, ' '), 
			IsNull(@F7I_LJBENF, ' '),			
			SUBSTRING(IsNull(@F7I_NBENEF, ' '),1,50),
			' ',--@F7I_MOVIM
			' ',--@F7I_DSCMOV,    
			@F7I_IDMOV,   	 
			@F7I_VLCRUZ,	 	 
			@F7I_CNTCTB, 
			IsNull(SUBSTRING(@F7I_DSCCTB,1,40),' '),
			IsNull(@F7I_NATCTA,' '),
			IsNull(SUBSTRING(@F7I_DSCCCT,1,40),' '),
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
			IsNull(@IN_GROUPEMPRESA,' '), 
			IsNull(@param_COMPANIA,' '), 
			IsNull(@param_COD_UNID,' '), 
			IsNull(@param_COD_FIL,' '),
			@cF7I_STAMP,
			@F7I_SALDO,
			@F7I_TPEVNT,
			@F7I_TPBENF,
			@F7I_ORBENF,
			@F7I_FXRTBS,
			@F7I_FXRTCT,
			@F7I_CCUSTO,
			@F7I_CREDIT,
			@F7I_VLRCNT
			--#variaveisflex
		)
		##CHECK_TRANSACTION_COMMIT

		/**********************************************************************************************************************************************************/
		-- Inclusao dos registros tabela de transacao
		/**********************************************************************************************************************************************************/
		INSERT INTO F7J###  (
				F7J_FILIAL,
				F7J_ALIAS,
				F7J_RECNO,
				F7J_STAMP
			) VALUES(
				' ',
				'CPR',
				@fk5_Recno , 
				@cFk5_STAMP 
			)
		/**********************************************************************************************************************************************************/
		-- Posiciona para o proximo registro do cursor
		/**********************************************************************************************************************************************************/
		fetch next from curPagarR
			into @F7I_ORIGIN,
				@se2_S_T_A_M_P_,
				@fk7_S_T_A_M_P_,
				@fk2_S_T_A_M_P_,
				@fka_S_T_A_M_P_,
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
				@F7I_MOEDA,
				@F7I_DSCMDA,
				@F7I_MOEDB,
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
				@E2_BAIXA,
				@E2_TIPO,				 				 
				@F7I_VLCRUZ,				 
				@E2_VLCRUZ,
				@E2_VALOR,
				@ED_CCD,
				@ED_DEBITO,
				@ED_CREDIT,
				@E2_CCUSTO,
				@F7I_DTDISP,
				@F7I_NATURE,
				@F7I_NATRAT,
				@F7I_CCDRAT,				 
				@FK7_IDDOC,
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
				@FK2_TPDOC,
				@E2_LOTE,
				@FK2_IDFK2,
				@FK5_RECPAG,
				@FK2_VALOR,
				@E2_MOEDA,
				@A6_MOEDA,
				@FK5_VALOR,
				@FK5_VLMOE2,
				@F7I_CONVBS,
				@F7I_CONVCT,
				@EV_VALOR,
				@EZ_VALOR,
				@F7I_CREDIT
				--#cursorflex
	End
	DELETE FROM 
		F7J###
    WHERE F7J_ALIAS = 'CPR'
      AND F7J_STAMP < @delTransactTime
	  AND F7J_STAMP < (
			SELECT MAX(F7J_STAMP ) FROM 
				F7J### 
			WHERE 
				F7J_ALIAS = 'CPR'
		)
	close curPagarR
	deallocate curPagarR
	select @OUT_RESULTADO = '1'
End	