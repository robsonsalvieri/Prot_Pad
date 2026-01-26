-- =============================================
-- Author:		Luiz Gustavo Romeiro de Jesus
-- Create date: 24/02/2025
-- Description:	Geração dos titulos a Pagar previsto
-- =============================================
CREATE PROCEDURE FIN007_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
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
	@IN_mdmTenantId char(32),
	@IN_DTINI char('F7I_EMIS1'),
	@IN_DTFIM char('F7I_EMIS1'),
    @IN_DEL char(1),
	@IN_TRANSACTION  Char(1),
	@DecCONVBS Integer,
	@OUT_RESULTADO Char(1) OutPut 
) AS
--Variaveis de apoio
declare @N_TAMTOTAL Integer	
declare @param_DTINI char('F7I_EMIS1')
declare @param_DTFIM char('F7I_EMIS1')
declare @filialCTT char('CTT_FILIAL')

declare @param_COMPANIA char('##COMPANIA')
declare @param_COD_UNID char('##COD_UNID')
declare @param_COD_FIL char('##COD_FIL')
declare @cValMoeda char(2)

--Variaveis do cursor
Declare @F7I_STAMP	Datetime
Declare @F7I_EXTCDH char('F7I_EXTCDH')
Declare @F7I_EXTCDD char('EV_MSUID')
Declare @F7I_EMISSA char('F7I_EMISSA')
Declare @F7I_EMIS1	char('F7I_EMIS1')
Declare @F7I_HIST	char('F7I_HIST')
Declare @F7I_TIPO	char('F7I_TIPO')
Declare @F7I_TIPDSC char('X5_DESCRI')
Declare @F7I_PREFIX char('F7I_PREFIX')
Declare @F7I_NUM	char('F7I_NUM')
Declare @F7I_PARCEL char('F7I_PARCEL')
Declare @F7I_MOEDA  Integer
Declare @F7I_DSCMDA char('F7I_DSCMDA')
Declare @F7I_VENCTO char('F7I_VENCTO')
Declare @F7I_VENCRE char('F7I_VENCRE')
Declare @F7I_FLBENF char('F7I_FLBENF')
Declare @F7I_CDBENF char('F7I_CDBENF')
Declare @F7I_LJBENF char('F7I_LJBENF')
Declare @F7I_NBENEF char('A2_NOME')
Declare @F7I_MOVIM  char('F7I_MOVIM')
Declare @F7I_DSCMOV char('F7I_DSCMOV')
Declare @F7I_SALDO  float
Declare @F7I_VLPROP float
Declare @F7I_VLCRUZ float
Declare @F7I_CONVBS float
Declare @F7I_FXRTBS char('F7I_FXRTBS')
Declare @F7I_CONVCT float
Declare @F7I_FXRTCT char('F7I_FXRTCT')
Declare @F7I_CNTCTB char('F7I_CNTCTB')
Declare @F7I_DSCCTB char('F7I_DSCCTB')
Declare @F7I_NATCTA char('F7I_NATCTA')
Declare @F7I_CCUSTO char('F7I_CCUSTO')
Declare @F7I_DSCCCT char('F7I_DSCCCT')
Declare @F7I_NATURE char('F7I_NATURE')
Declare @F7I_NATRAT char('F7I_NATRAT')
Declare @F7I_CCDRAT char('F7I_CCDRAT')
Declare @F7I_INTEGR char('F7I_INTEGR')
Declare @F7I_PAMOV  char('F7I_PAMOV')
Declare @F7I_CREDIT char('F7I_CREDIT')
Declare @F7I_DEBITO char('F7I_DEBITO')
Declare @F7I_CCD	char('F7I_CCD')
Declare @F7I_CCC	char('F7I_CCC')
Declare @F7I_ITEMCT char('F7I_ITEMCT')
Declare @F7I_ITEMD	char('F7I_ITEMD')
Declare @F7I_ITEMC	char('F7I_ITEMC')
Declare @F7I_CLVL	char('F7I_CLVL')
Declare @F7I_CLVLDB char('F7I_CLVLDB')
Declare @F7I_CLVLCR char('F7I_CLVLCR')
Declare @F7I_NUMBOR char('F7I_NUMBOR')
Declare @F7I_BANCO  char('F7I_BANCO')
Declare @F7I_AGENCI char('F7I_AGENCI')	
Declare @F7I_IDMOV	char('F7I_IDMOV')

--Variaveis de tratamento de campos
declare @E2_FILORIG	char('E2_FILORIG')
declare @E2_BAIXA	char('E2_BAIXA')
declare @E2_SALDO	float

declare @FK5_VALOR float
declare @FK5_TXMOED float
declare @FK5_MOEDA char('FK5_MOEDA')

declare @ABAT		float
declare @E2_MOEDA   float
declare @E2_ACRESC	float
declare @E2_DECRESC float
declare @E2_TIPO	char('E2_TIPO')
declare @sev_deleted char(1)
declare @sez_deleted char(1)
declare @trataRecDelEv char(1)
declare @trataRecDelEz char(1)
declare @EV_PERC	float
declare @EZ_PERC	float
declare @E2_VLCRUZ	float
declare @E2_VALOR	float
declare @CT1_CONTA	char('CT1_CONTA')
declare @E2_CCUSTO	char('E2_CCUSTO')
declare @ED_CCD		char('ED_CCD')
declare @se2_deleted char(1)
declare @FK7_IDDOC	char('FK7_IDDOC')
declare @maxStagingCounter Datetime
declare @CountEZ Integer
declare @delTransactTime char('F7I_STAMP')
declare @cF7I_STAMP char('F7I_STAMP')
declare @cF7J_STAMP char('F7J_STAMP')
declare @cStamp char('F7I_STAMP')
declare @Se2Recno	Integer  
declare @copyIntegr Char(2)
declare @E2_TXMOEDA float
declare flex char(1)


Begin

	select @N_TAMTOTAL = @IN_TAMEMP + @IN_TAMUNIT +	@IN_TAMFIL

	Select @cStamp = (
						SELECT MIN(F7J_STAMP) 
							FROM F7J### F7J
							WHERE 
								F7J.F7J_ALIAS = 'CPP' 
					)

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

	If (@IN_DTINI = ' ' and @IN_DTFIM = ' ')
        Begin
            select @param_DTINI = Convert(CHAR(8),DateAdd(Year,-2,GetDate()),112)
            select @param_DTFIM = Convert(CHAR(8), GetDate(), 112)
        End

	select @F7I_EXTCDD = ' '

	select @F7I_SALDO  = 0
	select @F7I_VLPROP = 0
	select @F7I_CONVBS = 0
	select @F7I_FXRTBS = '0'
	select @F7I_CONVCT = 0
	select @F7I_FXRTCT = '0'
	select @F7I_CNTCTB = '0'
	select @F7I_CCUSTO = ' '
	select @F7I_INTEGR = ' '
	select @F7I_PAMOV  = ' '
	select @F7I_IDMOV = ' '
	select @CountEZ = 0

	If ( @param_DTINI <> ' ' and @param_DTFIM <> ' ' and @IN_DEL = 'S') --Adicionar tratamento com parametro de limpeza
        BEGIN
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\			
            delete F7I###
			where 
				F7I_FILIAL = ' '  				
				AND F7I_EMIS1 BETWEEN @param_DTINI and @param_DTFIM
				AND F7I_GRPEMP = @IN_GROUPEMPRESA
				AND F7I_EMPR = @IN_COMPANIA						
				AND F7I_UNID = @IN_COD_UNID
				AND F7I_FILNEG = @IN_COD_FIL				
				AND F7I_ORGSYT = 'CP'
            ##CHECK_TRANSACTION_COMMIT 
        END

	If @param_DTINI = ' ' and @param_DTFIM = ' '
		Begin
			select @param_DTINI = null
			select @param_DTFIM = null
		End

	select @param_COMPANIA = @IN_COMPANIA
    select @param_COD_UNID = @IN_COD_UNID
    select @param_COD_FIL = @IN_COD_FIL

	declare curPagarPrev insensitive cursor for
	select		
		stamp_se2																				        as F7I_STAMP,
		LOWER(CONVERT(char(32), HashBytes('MD5',CONCAT(@IN_mdmTenantId,protheus_pk,E2_FILORIG)), 2))	as F7I_EXTCDH,
		COALESCE(CAST(EZ_MSUID AS VARCHAR(36)) ,CAST(EV_MSUID AS VARCHAR(36)) ) 						as F7I_EXTCDD,
		E2_FILORIG																						as E2_FILORIG,	
		E2_EMISSAO																						as F7I_EMISSA,
		COALESCE(E2_EMIS1,' ')																			as F7I_EMIS1,	
		COALESCE(E2_HIST,' ')																			as F7I_HIST,
		E2_TIPO			          																		as F7I_TIPO,	
		sx5_05_desc																						as F7I_TIPDSC,
		E2_PREFIXO																						as F7I_PREFIX,
		E2_NUM																							as F7I_NUM,
		E2_PARCELA																						as F7I_PARCEL,
		E2_MOEDA																						as F7I_MOEDA,
		trim(DESC_MOEDA)																				as F7I_DSCMDA,
		E2_VENCTO																						as F7I_VENCTO,
		E2_VENCREA																						as F7I_VENCRE,
		A2_FILIAL																						as F7I_FLBENF,
		A2_COD																							as F7I_CDBENF,
		A2_LOJA																							as F7I_LJBENF,
		A2_NOME																							as F7I_NBENEF,
		TRIM(E2_FORMPAG)																				as F7I_MOVIM,
		COALESCE(sx5_58_desc,' ')																		as F7I_DSCMOV,
		COALESCE(E2_BAIXA,' ')																			as E2_BAIXA,
		E2_SALDO																						as E2_SALDO,
		ABAT																							as ABAT,
		E2_ACRESC																						as E2_ACRESC,
		E2_DECRESC																						as E2_DECRESC,
		E2_TIPO																							as E2_TIPO,	
		sev_deleted																						as sev_deleted,
		sez_deleted																						as sez_deleted,
		EV_PERC																							as EV_PERC,
		EZ_PERC																							as EZ_PERC,	
		E2_VLCRUZ																						as F7I_VLCRUZ,
		E2_VLCRUZ																						as E2_VLCRUZ,
		E2_VALOR																						as E2_VALOR,	
		CT1_CONTA																						as CT1_CONTA,	
		COALESCE(SUBSTRING(CT1_DESC01,1,40),' ')														as F7I_DSCCTB,
		COALESCE(CT1_NATCTA,' ')																		as F7I_NATCTA,
		E2_CCUSTO																						as E2_CCUSTO,
		ED_CCD																							as ED_CCD,
		--Rateio
		E2_NATUREZ																						as F7I_NATURE,      
		COALESCE(EV_NATUREZ,' ')																		as F7I_NATRAT,
		COALESCE(EZ_CCUSTO,' ')																			as F7I_CCDRAT,      
		se2_deleted																						as se2_deleted,
		FK7_IDDOC																						as FK7_IDDOC,
		E2_CREDIT																						as F7I_CREDIT,
		E2_DEBITO																						as F7I_DEBITO,
		E2_CCD																							as F7I_CCD,
		E2_CCC																							as F7I_CCC,
		E2_ITEMCTA																						as F7I_ITEMCT,
		E2_ITEMD																						as F7I_ITEMD,
		E2_ITEMC																						as F7I_ITEMC,
		E2_CLVL																							as F7I_CLVL,
		E2_CLVLDB																						as F7I_CLVLDB,
		E2_CLVLCR																						as F7I_CLVLCR,
		E2_NUMBOR																						as F7I_NUMBOR,
        fk5_idmov																						as F7I_IDMOV,
		FK5_VALOR																						as FK5_VALOR,
		FK5_TXMOED																						as FK5_TXMOED,
		FK5_MOEDA																						as FK5_MOEDA,
		E2_MOEDA																						as E2_MOEDA,
		se2_recno 																						as Se2Recno,
		IsNull(CountEZ, 0)																				as CountEZ,
		evdeleted,
		ezdeleted,
		copyIntegr,
		E2_TXMOEDA 																						as E2_TXMOEDA
		,'#selectcursorflex' as cursorflex	
	From 
	(

	Select	
		RTrim(@IN_GROUPEMPRESA) || '|' || RTrim(se2_principal.E2_FILIAL) || '|' || RTrim(se2_principal.E2_PREFIXO) || '|' || RTrim(se2_principal.E2_NUM) || '|' || RTrim(se2_principal.E2_PARCELA) || '|' || RTrim(se2_principal.E2_TIPO) || '|' ||	RTrim(se2_principal.E2_FORNECE) || '|' || RTrim(se2_principal.E2_LOJA) as protheus_pk,
		se2_principal.E2_FILIAL,
		se2_principal.E2_PREFIXO,
		se2_principal.E2_NUM,
		se2_principal.E2_PARCELA,
		se2_principal.E2_FORNECE,
		se2_principal.E2_LOJA,
		se2_principal.E2_FILORIG,
		se2_principal.E2_TIPO,
		se2_principal.E2_NATUREZ,
		se2_principal.E2_CCUSTO,
		se2_principal.E2_FORMPAG,
		se2_principal.E2_MOEDA,
		se2_principal.E2_EMISSAO,
		se2_principal.E2_EMIS1,
		se2_principal.E2_HIST,
		se2_principal.E2_VENCTO,
		se2_principal.E2_VENCREA,
		se2_principal.E2_BAIXA,
		se2_principal.E2_SALDO,
		se2_principal.E2_ACRESC,
		se2_principal.E2_DECRESC,
		se2_principal.E2_VLCRUZ,
		se2_principal.E2_VALOR,
		se2_principal.se2_deleted,
		se2_principal.se2_recno, 
		se2_principal.E2_CREDIT,
		se2_principal.E2_DEBITO, 
		se2_principal.E2_CCD, 
		se2_principal.E2_CCC,
		se2_principal.E2_ITEMCTA,
		se2_principal.E2_ITEMD,
		se2_principal.E2_ITEMC,
		se2_principal.E2_CLVL,
		se2_principal.E2_CLVLDB,
		se2_principal.E2_CLVLCR,
		se2_principal.E2_NUMBOR,
		se2_principal.E2_TXMOEDA,
		se2_principal.E2_MULTNAT,
		se2_principal.stamp_se2,
		se2_abatimentos.ABAT,
		sx5_05_consolidate.X5_FILIAL as sx5_05_filial,
		sx5_05_consolidate.X5_DESCRI as sx5_05_desc,
		sx5_58_consolidate.X5_FILIAL as sx5_58_filial,
		sx5_58_consolidate.X5_DESCRI as sx5_58_desc,
		fk7_consolidate.FK7_FILTIT,
		fk7_consolidate.FK7_PREFIX,
		fk7_consolidate.FK7_NUM,
		fk7_consolidate.FK7_PARCEL,
		fk7_consolidate.FK7_TIPO,
		fk7_consolidate.FK7_CLIFOR,
		fk7_consolidate.FK7_LOJA,
		fk7_consolidate.FK7_FILIAL,
		fk7_consolidate.FK7_IDDOC,
		fk7_consolidate.FK7_ALIAS,
		fk5_consolidate.FK5_FILIAL,
		fk5_consolidate.FK5_FILORI,
		fk5_consolidate.FK5_IDDOC,
		fk5_consolidate.FK5_IDMOV fk5_idmov,
		fk5_consolidate.FK5_DATA,
		fk5_consolidate.FK5_LOTE,
		fk5_consolidate.FK5_TPDOC,
		fk5_consolidate.FK5_VALOR,
		fk5_consolidate.FK5_RECPAG,
		fk5_consolidate.FK5_SEQ,
		fk5_consolidate.FK5_CONTA,
		fk5_consolidate.FK5_AGENCI,
		fk5_consolidate.FK5_BANCO,
		fk5_consolidate.FK5_VLMOE2,
		fk5_consolidate.FK5_TXMOED,
		fk5_consolidate.FK5_MOEDA,
		sed.ED_CODIGO,
		sed.ED_FILIAL,
		sed.ED_CREDIT,
		sed.ED_DEBITO,
		sed.ED_CCD,
		ct1.CT1_CONTA,
		ct1.CT1_FILIAL,
		ct1.CT1_DESC01,
		ct1.CT1_NATCTA,
		sev.EV_FILIAL,
		sev.EV_PREFIXO,
		sev.EV_NUM,
		sev.EV_PARCELA,
		sev.EV_TIPO,
		sev.EV_CLIFOR,
		sev.EV_LOJA,
		sev.EV_NATUREZ,
		sev.EV_IDENT,
		sev.EV_SEQ,
		sev.EV_SITUACA,    
		sev.EV_VALOR,
		sev.EV_PERC,
		sev.EV_MSUID,
		sev.D_E_L_E_T_ as sev_deleted,
		sez.EZ_FILIAL,
		sez.EZ_PREFIXO,
		sez.EZ_NUM,
		sez.EZ_PARCELA,
		sez.EZ_TIPO,
		sez.EZ_CLIFOR,
		sez.EZ_CCUSTO,
		sez.EZ_LOJA,
		sez.EZ_NATUREZ,
		sez.EZ_IDENT,
		sez.EZ_SEQ,
		sez.EZ_SITUACA,
		sez.EZ_MSUID,
		sez.EZ_VALOR,
		sez.EZ_PERC,
		sez.D_E_L_E_T_ as sez_deleted,
		currency.DESC_MOEDA,
		sa2.A2_FILIAL,
		sa2.A2_COD,
		sa2.A2_LOJA,
		sa2.A2_NOME,		
		RateioEZ.CountEZ,	
		tratarateio.evdeleted,
		tratarateio.ezdeleted,
		copyIntegr
		,'#campoflex' as campoflex
	From 
		(
			SELECT DISTINCT
				' ' copyIntegr,
				E2_FILIAL,
				E2_PREFIXO,
				E2_NUM,
				E2_PARCELA,
				E2_FORNECE,
				E2_LOJA,
				E2_FILORIG,
				E2_TIPO,
				E2_NATUREZ,
				E2_CCUSTO,
				E2_FORMPAG,
				E2_MOEDA,
				E2_EMISSAO,
				E2_EMIS1,
				E2_HIST,
				E2_VENCTO,
				E2_VENCREA,
				E2_BAIXA,
				E2_SALDO,
				E2_ACRESC,
				E2_DECRESC,
				E2_VLCRUZ,
				E2_VALOR,
				se2.D_E_L_E_T_ se2_deleted,
				se2.R_E_C_N_O_ se2_recno,  
				E2_CREDIT,
				E2_DEBITO, 
				E2_CCD, 
				E2_CCC,
				E2_ITEMCTA,
				E2_ITEMD,
				E2_ITEMC,
				E2_CLVL,
				E2_CLVLDB,
				E2_CLVLCR,
				E2_NUMBOR,
				E2_TXMOEDA,
				E2_MULTNAT,
				se2.S_T_A_M_P_ stamp_se2,
				' ' EV_NATUREZ_EZDEL
				,'#campoflexprincipal' as campoflexprincipal
			FROM
				SE2### se2 LEFT JOIN CT2### ON CT2_FILIAL = ' '
			WHERE
				( @maxStagingCounter is null OR se2.S_T_A_M_P_ > @maxStagingCounter )
				AND ((se2.D_E_L_E_T_ = ' ' AND se2.E2_SALDO > 0) OR (se2.D_E_L_E_T_ = '*'))
				AND RIGHT(se2.E2_TIPO, 1) <> '-' 

			UNION ALL

			SELECT DISTINCT
				'E' copyIntegr,
				E2_FILIAL,
				E2_PREFIXO,
				E2_NUM,
				E2_PARCELA,
				E2_FORNECE,
				E2_LOJA,
				E2_FILORIG,
				E2_TIPO,
				E2_NATUREZ,
				E2_CCUSTO,
				E2_FORMPAG,
				E2_MOEDA,
				E2_EMISSAO,
				E2_EMIS1,
				E2_HIST,
				E2_VENCTO,
				E2_VENCREA,
				E2_BAIXA,
				E2_SALDO,
				E2_ACRESC,
				E2_DECRESC,
				E2_VLCRUZ,
				E2_VALOR,
				se2.D_E_L_E_T_ se2_deleted,
				se2.R_E_C_N_O_ se2_recno, 
				E2_CREDIT,
				E2_DEBITO, 
				E2_CCD, 
				E2_CCC,
				E2_ITEMCTA,
				E2_ITEMD,
				E2_ITEMC,
				E2_CLVL,
				E2_CLVLDB,
				E2_CLVLCR,
				E2_NUMBOR,
				E2_TXMOEDA,
				E2_MULTNAT,
				S_T_A_M_P_ stamp_se2,
				' ' EV_NATUREZ_EZDEL
				,'#campoflexprincipal' as campoflexprincipal
			FROM
				SE2### se2 LEFT JOIN CT2### ON CT2_FILIAL = ' '
				Left join
				(SELECT
					EV_FILIAL,
					'EV' copyIntegr,
					EV_PREFIXO,
					EV_NUM,
					EV_PARCELA,
					EV_TIPO,
					EV_CLIFOR,
					EV_LOJA,
					EV_NATUREZ,
					EV_IDENT,
					EV_MSUID,
					D_E_L_E_T_
				FROM
					SEV### LEFT JOIN CT2### ON CT2_FILIAL = ' '
				WHERE
					EV_RECPAG = 'P'
					And D_E_L_E_T_ = ' '
				) sev
				On
					sev.EV_FILIAL = SUBSTRING(se2.E2_FILORIG,1,@IN_TAMSEV) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSEV)
					And sev.EV_PREFIXO = se2.E2_PREFIXO
					And sev.EV_NUM = se2.E2_NUM
					And sev.EV_PARCELA = se2.E2_PARCELA
					And sev.EV_TIPO = se2.E2_TIPO
					And sev.EV_CLIFOR = se2.E2_FORNECE
					And sev.EV_LOJA = se2.E2_LOJA
					And sev.EV_IDENT = '1'
					And sev.EV_MSUID is not null
					And sev.D_E_L_E_T_ = ' '
				Left join
				(SELECT
					EZ_FILIAL,
					'EZ' copyIntegr,
					EZ_PREFIXO,
					EZ_NUM,
					EZ_PARCELA,
					EZ_TIPO,
					EZ_CLIFOR,
					EZ_LOJA,
					EZ_NATUREZ,
					EZ_CCUSTO,
					EZ_IDENT,
					EZ_MSUID,
					D_E_L_E_T_
				FROM
					SEZ### LEFT JOIN CT2### ON CT2_FILIAL = ' '
				WHERE
					EZ_RECPAG = 'P'
					And D_E_L_E_T_ = ' '
				) sez
				On
					sev.EV_FILIAL = sez.EZ_FILIAL
					And sev.EV_PREFIXO = sez.EZ_PREFIXO
					And sev.EV_NUM = sez.EZ_NUM
					And sev.EV_PARCELA = sez.EZ_PARCELA
					And sev.EV_TIPO = sez.EZ_TIPO
					And sev.EV_CLIFOR = sez.EZ_CLIFOR
					And sev.EV_LOJA = sez.EZ_LOJA
					And sev.EV_NATUREZ = sez.EZ_NATUREZ
					And sez.EZ_IDENT = '1'
					And sez.EZ_MSUID is not null
					And sez.D_E_L_E_T_ = ' '
			WHERE
				RIGHT(se2.E2_TIPO,1) <> '-'
				And se2.E2_MULTNAT = '1'
				And ( @maxStagingCounter is null OR se2.S_T_A_M_P_ > @maxStagingCounter )
				And se2.S_T_A_M_P_ <> se2.I_N_S_D_T_ -- onde ha (ev ou ez) e tem alteracao de stamp
				And (sev.EV_NATUREZ is not null
					or sez.EZ_CCUSTO is not null
				)
				And se2.D_E_L_E_T_ = ' '
		) se2_principal
		Left join (	
			select
				se2_abatimentos.E2_FILIAL,
				se2_abatimentos.E2_FILORIG,
				se2_abatimentos.E2_PREFIXO,
				se2_abatimentos.E2_NUM,
				se2_abatimentos.E2_PARCELA,
				se2_abatimentos.E2_FORNECE,
				se2_abatimentos.E2_LOJA,
				Sum(se2_abatimentos.E2_VALOR) as ABAT
			From
				SE2### se2_abatimentos LEFT JOIN CT2### ON CT2_FILIAL = ' '
			Where 
				RIGHT(se2_abatimentos.E2_TIPO,1) = '-'
				And ( @maxStagingCounter is null OR se2_abatimentos.S_T_A_M_P_ > @maxStagingCounter )
				And se2_abatimentos.D_E_L_E_T_ = ' '
			Group By
				E2_FILIAL,
				E2_FILORIG,
				E2_PREFIXO,
				E2_NUM,
				E2_PARCELA,
				E2_FORNECE,
				E2_LOJA
		) se2_abatimentos
		on 
			se2_abatimentos.E2_FILIAL = se2_principal.E2_FILIAL
			And se2_abatimentos.E2_PREFIXO = se2_principal.E2_PREFIXO
			And se2_abatimentos.E2_NUM = se2_principal.E2_NUM
			And se2_abatimentos.E2_PARCELA = se2_principal.E2_PARCELA
			And se2_abatimentos.E2_FORNECE = se2_principal.E2_FORNECE
			And se2_abatimentos.E2_LOJA	 = se2_principal.E2_LOJA
			And se2_abatimentos.E2_FILORIG = se2_principal.E2_FILORIG

		inner Join (
			SELECT X5_FILIAL, X5_CHAVE, X5_DESCRI FROM SX5### WHERE X5_TABELA = '05' AND D_E_L_E_T_ = ' '
		) sx5_05_consolidate
		on 	
			sx5_05_consolidate.X5_FILIAL  = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSX5) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSX5)
			and Trim(sx5_05_consolidate.X5_CHAVE) = trim(se2_principal.E2_TIPO)
		
		Left join (
			SELECT X5_FILIAL, X5_CHAVE, X5_DESCRI FROM SX5### WHERE X5_TABELA = '58' AND D_E_L_E_T_ = ' '
		) sx5_58_consolidate
		on      
			sx5_58_consolidate.X5_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSX5) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSX5)
			and trim(sx5_58_consolidate.X5_CHAVE) = trim(se2_principal.E2_FORMPAG)
		
		Left join (
			select 
				fk7_consolidate.FK7_FILTIT,
				fk7_consolidate.FK7_PREFIX,
				fk7_consolidate.FK7_NUM,
				fk7_consolidate.FK7_PARCEL,
				fk7_consolidate.FK7_TIPO,
				fk7_consolidate.FK7_CLIFOR,
				fk7_consolidate.FK7_LOJA,
				fk7_consolidate.FK7_FILIAL,
				fk7_consolidate.FK7_IDDOC,
				fk7_consolidate.FK7_ALIAS,
				fk7_consolidate.D_E_L_E_T_
			from
				FK7### fk7_consolidate LEFT JOIN CT2### ON CT2_FILIAL = ' '
			Where
				TRIM(fk7_consolidate.FK7_ALIAS) = 'SE2'			
				And fk7_consolidate.FK7_TIPO = 'PA'
		) fk7_consolidate
		on 
			se2_principal.E2_FILIAL = fk7_consolidate.FK7_FILTIT 
			And se2_principal.E2_PREFIXO = fk7_consolidate.FK7_PREFIX
			And se2_principal.E2_NUM = fk7_consolidate.FK7_NUM
			And se2_principal.E2_PARCELA = fk7_consolidate.FK7_PARCEL
			And se2_principal.E2_TIPO = fk7_consolidate.FK7_TIPO
			And se2_principal.E2_FORNECE = fk7_consolidate.FK7_CLIFOR
			And se2_principal.E2_LOJA = fk7_consolidate.FK7_LOJA
			And se2_principal.se2_deleted = fk7_consolidate.D_E_L_E_T_-- Cenario de exclusao e inclusao de mesma chave iria se perder sem isso

		Left join (
			select 
				fk5_consolidate.FK5_FILIAL,
				fk5_consolidate.FK5_FILORI,
				fk5_consolidate.FK5_IDDOC,
				fk5_consolidate.FK5_IDMOV,
				fk5_consolidate.FK5_DATA,
				fk5_consolidate.FK5_LOTE,
				fk5_consolidate.FK5_TPDOC,
				fk5_consolidate.FK5_VALOR,
				fk5_consolidate.FK5_RECPAG,
				fk5_consolidate.FK5_SEQ,
				fk5_consolidate.FK5_CONTA,
				fk5_consolidate.FK5_AGENCI,
				fk5_consolidate.FK5_BANCO,
				fk5_consolidate.FK5_VLMOE2,
				fk5_consolidate.FK5_TXMOED,
				fk5_consolidate.FK5_MOEDA
			From 
				FK5### fk5_consolidate LEFT JOIN CT2### ON CT2_FILIAL = ' '						
			Where
				( TRIM(fk5_consolidate.FK5_TPDOC) IN ('PA','ES') )
				and fk5_consolidate.D_E_L_E_T_= ' '			
		) fk5_consolidate
		on 			
			fk5_consolidate.FK5_FILORI = se2_principal.E2_FILORIG
			And fk5_consolidate.FK5_IDDOC = fk7_consolidate.FK7_IDDOC			
		
		inner join SED### sed
		on      
			sed.ED_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSED) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSED)
			and sed.ED_CODIGO = se2_principal.E2_NATUREZ
			and sed.D_E_L_E_T_ = ' '

		Left join CT1### ct1
		on      
			ct1.CT1_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMCT1) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMCT1)
			and ct1.CT1_CONTA = sed.ED_DEBITO
			and ct1.D_E_L_E_T_ = ' '
			
		Left join SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' '
		On      
			sev.EV_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSEV) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSEV)
			And sev.EV_PREFIXO = se2_principal.E2_PREFIXO 
			And sev.EV_NUM = se2_principal.E2_NUM 
			And sev.EV_PARCELA = se2_principal.E2_PARCELA	
			And sev.EV_TIPO = se2_principal.E2_TIPO 
			And sev.EV_CLIFOR = se2_principal.E2_FORNECE
			And sev.EV_LOJA = se2_principal.E2_LOJA
			And sev.EV_IDENT='1'  --Emissao
			And sev.EV_MSUID is not null
			And sev.EV_RECPAG = 'P'
			And se2_principal.E2_MULTNAT = '1'
			And se2_principal.copyIntegr IN (' ')

		Left join SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' '
		On      
		  sev.EV_FILIAL = sez.EZ_FILIAL 
		  And sev.EV_PREFIXO = sez.EZ_PREFIXO 
		  And sev.EV_NUM = sez.EZ_NUM 
		  And sev.EV_PARCELA = sez.EZ_PARCELA	
		  And sev.EV_TIPO = sez.EZ_TIPO 
		  And sev.EV_CLIFOR = sez.EZ_CLIFOR 
		  And sev.EV_LOJA = sez.EZ_LOJA 
		  And sev.EV_NATUREZ = sez.EZ_NATUREZ 
		  And sez.EZ_IDENT='1'
		  And sez.EZ_RECPAG = 'P'
		  And sez.EZ_MSUID is not null
		  And se2_principal.E2_MULTNAT = '1'
		  And se2_principal.copyIntegr IN (' ')

		Left join (
			SELECT X6_VAR, X6_CONTEUD AS DESC_MOEDA FROM SX6### SX6 WHERE SX6.X6_VAR like 'MV_MOEDA%'
		) currency
		ON
			TRIM(currency.X6_VAR) = TRIM(CONCAT('MV_MOEDA', CAST(se2_principal.E2_MOEDA AS CHAR(2))))
		
		Left join SA2### sa2
		On      
			sa2.A2_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSA2) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSA2)
			And sa2.A2_COD = se2_principal.E2_FORNECE
			And sa2.A2_LOJA = se2_principal.E2_LOJA

		Left join (
            SELECT
                fk5.FK5_FILORI,
                fk5.FK5_IDDOC,
                fk5.FK5_TPDOC,
                fk5.FK5_IDMOV,
                se2_est.E2_FILIAL,
                se2_est.E2_PREFIXO,
                se2_est.E2_NUM,
                se2_est.E2_PARCELA,
                se2_est.E2_TIPO,
                se2_est.E2_FORNECE,
                se2_est.E2_LOJA,
                se2_est.E2_FILORIG
            FROM
                SE2### se2_est LEFT JOIN CT2### ON CT2_FILIAL = ' ' Inner Join FK7### fk7 LEFT JOIN CT2### ON CT2_FILIAL = ' '
                On
					se2_est.E2_FILIAL = fk7.FK7_FILTIT
                    And se2_est.E2_PREFIXO = fk7.FK7_PREFIX
                    And se2_est.E2_NUM = fk7.FK7_NUM    
                    And se2_est.E2_PARCELA = fk7.FK7_PARCEL
                    And se2_est.E2_TIPO = fk7.FK7_TIPO
                    And se2_est.E2_FORNECE = fk7.FK7_CLIFOR
                    And se2_est.E2_LOJA = fk7.FK7_LOJA   
                    And se2_est.D_E_L_E_T_ = fk7.D_E_L_E_T_ -- Cenario de exclusao e inclusao de mesma chave iria se perder sem isso
                    and fk7.FK7_ALIAS = 'SE2'
                    And se2_est.E2_TIPO = 'PA'
                Inner Join FK5### fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' '
                On
                    fk5.FK5_FILIAL = fk7.FK7_FILIAL
                    And fk5.FK5_FILORI = se2_est.E2_FILORIG
                    And fk5.FK5_IDDOC = fk7.FK7_IDDOC
                    And fk5.FK5_TPDOC = 'ES'
			WHERE
				( @maxStagingCounter is null OR se2_est.S_T_A_M_P_ > @maxStagingCounter )
            GROUP BY
                fk5.FK5_FILORI,
                fk5.FK5_IDDOC,
                fk5.FK5_TPDOC,
                fk5.FK5_IDMOV, 
                se2_est.E2_FILIAL,
                se2_est.E2_PREFIXO,
                se2_est.E2_NUM,
                se2_est.E2_PARCELA,
                se2_est.E2_TIPO,
                se2_est.E2_FORNECE,
                se2_est.E2_LOJA,
                se2_est.E2_FILORIG
        ) pa_est
        ON
			pa_est.E2_FILIAL = se2_principal.E2_FILIAL
            and pa_est.E2_PREFIXO = se2_principal.E2_PREFIXO
            and pa_est.E2_NUM = se2_principal.E2_NUM
            and pa_est.E2_PARCELA = se2_principal.E2_PARCELA
            and pa_est.E2_TIPO = se2_principal.E2_TIPO
            and pa_est.E2_FORNECE = se2_principal.E2_FORNECE
            and pa_est.E2_LOJA = se2_principal.E2_LOJA
            and pa_est.E2_FILORIG = se2_principal.E2_FILORIG
            and pa_est.FK5_IDMOV = fk5_consolidate.FK5_IDMOV
		
        Left join (
            SELECT
                fk5.FK5_FILORI,
                fk5.FK5_IDDOC,
                fk5.FK5_IDMOV,
                fk5.FK5_TPDOC 
            FROM
                FK5### fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' '
            WHERE
                FK5_TPDOC  = 'ES'
            GROUP BY
                fk5.FK5_FILORI,
                fk5.FK5_IDDOC,
                fk5.FK5_IDMOV,
                fk5.FK5_TPDOC 
        ) pa_mov
        ON
            pa_est.E2_FILORIG = pa_mov.FK5_FILORI
            and pa_est.FK5_IDDOC = pa_mov.FK5_IDDOC
            and pa_est.FK5_TPDOC = pa_mov.FK5_TPDOC
            and pa_est.FK5_IDMOV = pa_mov.FK5_IDMOV
		
		Left Join (
			Select 
				SEZ.EZ_FILIAL,
				SEZ.EZ_CLIFOR,
				SEZ.EZ_LOJA,
				SEZ.EZ_PREFIXO,
				SEZ.EZ_NUM,
				SEZ.EZ_PARCELA,
				SEZ.EZ_TIPO,
				SEZ.EZ_NATUREZ,
				SEZ.D_E_L_E_T_,
				COUNT(*) CountEZ			
			From 
				SEZ### SEZ LEFT JOIN CT2### ON CT2_FILIAL = ' '		
			Where	
				SEZ.EZ_RECPAG = 'P'
			Group by 			
				SEZ.EZ_FILIAL,
				SEZ.EZ_CLIFOR,
				SEZ.EZ_LOJA,
				SEZ.EZ_PREFIXO,
				SEZ.EZ_NUM,
				SEZ.EZ_PARCELA,
				SEZ.EZ_TIPO,
				SEZ.EZ_NATUREZ,
				SEZ.D_E_L_E_T_
		) RateioEZ
		on		
			sev.EV_FILIAL = RateioEZ.EZ_FILIAL
			And sev.EV_PREFIXO = RateioEZ.EZ_PREFIXO
			And sev.EV_NUM = RateioEZ.EZ_NUM
			And sev.EV_PARCELA = RateioEZ.EZ_PARCELA
			And sev.EV_TIPO = RateioEZ.EZ_TIPO
			And sev.EV_CLIFOR = RateioEZ.EZ_CLIFOR
			And sev.EV_LOJA = RateioEZ.EZ_LOJA
			And sev.EV_NATUREZ = RateioEZ.EZ_NATUREZ
			And IsNull(sez.D_E_L_E_T_, ' ') = RateioEZ.D_E_L_E_T_

		Left join (
			select 
				sev.EV_FILIAL,
				sev.EV_PREFIXO,
				sev.EV_NUM,
				sev.EV_PARCELA,
				sev.EV_TIPO,
				sev.EV_CLIFOR,
				sev.EV_LOJA,
				sev.EV_NATUREZ,
				sez.EZ_CCUSTO,
				sev.EV_IDENT,
				sev.EV_MSUID,			
				sev.D_E_L_E_T_ as evdeleted,
				sez.D_E_L_E_T_ as ezdeleted			
			from 
				SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' Left join SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' '
				On 
				  sev.EV_FILIAL = sez.EZ_FILIAL 
				  And sev.EV_PREFIXO = sez.EZ_PREFIXO 
				  And sev.EV_NUM = sez.EZ_NUM 
				  And sev.EV_PARCELA = sez.EZ_PARCELA	
				  And sev.EV_TIPO = sez.EZ_TIPO 
				  And sev.EV_CLIFOR = sez.EZ_CLIFOR 
				  And sev.EV_LOJA = sez.EZ_LOJA 
				  And sev.EV_NATUREZ = sez.EZ_NATUREZ 
				  And sez.EZ_RECPAG = 'P'
				  And sez.EZ_IDENT = '1'
				  And sez.EZ_MSUID is not null
			where
				sev.EV_RECPAG = 'P'
		) tratarateio
		on 		    
			sev.EV_FILIAL = tratarateio.EV_FILIAL
			And sev.EV_PREFIXO = tratarateio.EV_PREFIXO
			And sev.EV_NUM = tratarateio.EV_NUM
			And sev.EV_PARCELA = tratarateio.EV_PARCELA
			And sev.EV_TIPO = tratarateio.EV_TIPO
			And sev.EV_CLIFOR = tratarateio.EV_CLIFOR
			And sev.EV_LOJA = tratarateio.EV_LOJA
			And sev.EV_NATUREZ = tratarateio.EV_NATUREZ
			And COALESCE(sez.EZ_CCUSTO, ' ') = COALESCE(tratarateio.EZ_CCUSTO, ' ')
			And sev.D_E_L_E_T_ = tratarateio.evdeleted
			And COALESCE(sez.D_E_L_E_T_, ' ') = COALESCE(tratarateio.ezdeleted, ' ')
			And tratarateio.EV_IDENT = '1'  --Emissao
			And tratarateio.EV_MSUID is not null
			And	(
				(COALESCE(tratarateio.ezdeleted, ' ') = '*' and tratarateio.evdeleted = ' ')
				or (tratarateio.evdeleted = '*' and COALESCE(tratarateio.ezdeleted, ' ') = ' ')
			)
			And copyIntegr NOT IN ('E')

		LEFT JOIN F7J### f7j
		ON
			f7j.F7J_ALIAS = 'CPP' 
			AND Trim(f7j.F7J_STAMP) = CONVERT(CHAR(26), se2_principal.stamp_se2, 121)
			AND f7j.F7J_RECNO = se2_principal.se2_recno
		
	Where
		pa_mov.FK5_IDDOC is null	
		-- Exclusao da copia de SE2 copyIntegr = 'EZ' quando nao há rateio CC
		And (
			(
				copyIntegr = ' '
				or Trim(copyIntegr) = 'E'
			)
		)
		-- Exclusao da duplicata de rateio Somente Natureza quando temos rateio CC
		And (
			copyIntegr = ' '
			or (copyIntegr <> ' '
				and evdeleted is null
				and ezdeleted is null
			)
		)
		And (			
			( se2_principal.stamp_se2 > @maxStagingCounter or @maxStagingCounter is null) or 
			( se2_principal.stamp_se2 is null and Convert(date, se2_principal.E2_EMIS1) > @maxStagingCounter) or 
			( @param_DTINI <> ' ' and @param_DTFIM <> ' ' and  @IN_DEL  = 'S')						
		) AND (
			(se2_principal.E2_EMIS1 >= @param_DTINI
			) OR (se2_principal.E2_BAIXA >= @param_DTINI
				) OR (
					se2_principal.E2_SALDO > 0
				)
		)
		AND f7j.F7J_RECNO is null
	) PagarPrevisto

	for read only

	-----------------------------------------------------------------
	-- 4- Abrindo o cursor
	-----------------------------------------------------------------
	open curPagarPrev
		fetch next from curPagarPrev			
			into @F7I_STAMP,
				 @F7I_EXTCDH,
				 @F7I_EXTCDD,
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
				 @F7I_VENCTO,
				 @F7I_VENCRE,
				 @F7I_FLBENF,
				 @F7I_CDBENF,
				 @F7I_LJBENF,
				 @F7I_NBENEF,
				 @F7I_MOVIM,
				 @F7I_DSCMOV,
				 @E2_BAIXA,
				 @E2_SALDO,
				 @ABAT,
				 @E2_ACRESC,
				 @E2_DECRESC,
				 @E2_TIPO,
				 @sev_deleted,
				 @sez_deleted,
				 @EV_PERC,
				 @EZ_PERC,
				 @F7I_VLCRUZ,				 
				 @E2_VLCRUZ,
				 @E2_VALOR,
				 @CT1_CONTA,
				 @F7I_DSCCTB,
				 @F7I_NATCTA,
				 @E2_CCUSTO,
				 @ED_CCD,
				 @F7I_NATURE,
				 @F7I_NATRAT,
				 @F7I_CCDRAT,
				 @se2_deleted,
				 @FK7_IDDOC,
				 @F7I_CREDIT,
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
				 @F7I_IDMOV,
				 @FK5_VALOR,	
				 @FK5_TXMOED,	
				 @FK5_MOEDA,	
				 @E2_MOEDA,
				 @Se2Recno,
				 @CountEZ,
				 @trataRecDelEv,
				 @trataRecDelEz,
				 @copyIntegr,
				 @E2_TXMOEDA
				 --#cursorflex

		While ( (@@fetch_Status  = 0 ) )			
		Begin
			/**********************************************************************************************************************************************************/
			-- Tratamento dos campos para serem gravados na tabela F7I
			/**********************************************************************************************************************************************************/
			--------------------------------------------
			--Tratamento Campo F7I_IDMOV
			---------------------------------------------
			If (@F7I_IDMOV is null)
				Begin
					select @F7I_IDMOV = ' '
				End	
			---------------------------------------------
			--Fim tratamento Campo F7I_IDMOV
			---------------------------------------------
			--------------------------------------------
			--Tratamento Campo F7I_STAMP
			---------------------------------------------
			If ( @F7I_STAMP is null )
				Begin 
					If ( @F7I_EMIS1 = ' ' )
						Begin
							If ( @E2_BAIXA = ' ' )
								Begin
									Select @cF7I_STAMP = ' '
								End
							Else
								Begin
									Select @cF7I_STAMP = FORMAT(Convert(date, @E2_BAIXA), 'yyyy-MM-ddTHH:mm:ss.fff')
								End
						End		
					Else	
						Begin					
							Select @cF7I_STAMP = FORMAT(Convert(date, @F7I_EMIS1 ), 'yyyy-MM-ddTHH:mm:ss.fff')
							Select @cF7J_STAMP = @delTransactTime
						End
				End				
			Else 
				Begin
					Select @cF7I_STAMP = CONVERT(CHAR(26), @F7I_STAMP, 121)
					Select @cF7J_STAMP = @cF7I_STAMP
				End 
			---------------------------------------------
			--Fim tratamento Campo F7I_STAMP
			---------------------------------------------
			/**********************************************************************************************************************************************************/		
			---------------------------------------------
			--Tratamento Campo F7I_EXTCDD
			---------------------------------------------
			If ( @F7I_EXTCDD is null )
				Begin 
					select @F7I_EXTCDD = @F7I_EXTCDH
				End
			---------------------------------------------
			--Fim tratamento Campo F7I_EXTCDD
			---------------------------------------------
			/**********************************************************************************************************************************************************/
			---------------------------------------------
			--Tratamento Campo @F7I_HIST
			---------------------------------------------	
			If (@F7I_HIST = ' ')
				Begin
					select @F7I_HIST = 'SEM DESCRICAO'
				End
			---------------------------------------------
			--Fim tratamento Campo F7I_HIST
			---------------------------------------------				
			/**********************************************************************************************************************************************************/
			---------------------------------------------
			--Tratamento Campo @F7I_SALDO
			---------------------------------------------
			If @E2_BAIXA=' '
				Begin 
					If (@E2_SALDO - IsNull(@ABAT,0) + @E2_ACRESC - @E2_DECRESC < 0 )
						Begin
							select @F7I_SALDO = 0
						End
					Else
						Begin
							select @F7I_SALDO = @E2_SALDO - IsNull(@ABAT,0) + @E2_ACRESC - @E2_DECRESC
						End
				End
			Else
				Begin 
					If ( @E2_SALDO - IsNull(@ABAT,0)< 0 )
						Begin
							select @F7I_SALDO = 0
						End
					Else
						Begin 
							select @F7I_SALDO = @E2_SALDO - IsNull(@ABAT,0)
						End
				End

			
			---------------------------------------------
			--Fim tratamento Campo @F7I_SALDO
			---------------------------------------------
			/**********************************************************************************************************************************************************/		
			---------------------------------------------
			--Tratamento Campo @F7I_VLPROP
			---------------------------------------------
			If (@sev_deleted IS NULL OR @sev_deleted = '*')
				Begin
					-- Verifica se 'E2_BAIXA' está vazio
					If @E2_BAIXA = ' '
						Begin
							-- Calcula o valor de 'F7I_VLPROP' com base no saldo e abatimentos	
							If ( @E2_SALDO - ISNULL(@ABAT, 0) + @E2_ACRESC - @E2_DECRESC < 0 )
								Begin
									select @F7I_VLPROP = 0
								End
							Else
								Begin 
									select @F7I_VLPROP = @E2_SALDO - ISNULL(@ABAT, 0) + @E2_ACRESC - @E2_DECRESC
								End
						End
					Else
						Begin
							-- Se 'E2_SALDO' for negativo, o valor é 0
							If ( @E2_SALDO < 0 )
								Begin 									
									select @F7I_VLPROP = 0
								End
							Else
								Begin
									select @F7I_VLPROP = @E2_SALDO
								End						
						End
				End
				-- Se 'EZ_PERC' não for nulo e 'sez_deleted' for vazio
				Else If (@EZ_PERC IS NOT NULL AND @sez_deleted = ' ')
					Begin
						-- Calcula o valor de 'F7I_VLPROP' com base no percentual					
						If ( @E2_SALDO * @EV_PERC * @EZ_PERC < 0 )
							Begin 
								select @F7I_VLPROP = 0
							End
						Else
							Begin 
								select @F7I_VLPROP =  ROUND(@E2_SALDO * @EV_PERC * @EZ_PERC, 2)
							End
					End
				Else
					Begin
						-- Calcula o valor de 'F7I_VLPROP' com base apenas no percentual
						--set @F7I_VLPROP = IIF(@E2_SALDO * @EV_PERC < 0, 0, @E2_SALDO * @EV_PERC)
						If ( @E2_SALDO * @EV_PERC < 0 )
							Begin 
								select @F7I_VLPROP = 0
							End
						Else
							Begin
								select @F7I_VLPROP = ROUND(@E2_SALDO * @EV_PERC, 2)
							End
					End

			If (trim(@E2_TIPO) = 'NDF')
				Begin 
					select @F7I_SALDO = @F7I_SALDO * -1
					select @F7I_VLPROP = @F7I_VLPROP * -1
					select @F7I_VLCRUZ = @F7I_VLCRUZ * -1
				End
		
			---------------------------------------------
			--Fim tratamento Campo @F7I_VLCRUZ
			---------------------------------------------
			/**********************************************************************************************************************************************************/
			---------------------------------------------
			--Tratamento Campo @F7I_CONVBS,@F7I_FXRTBS,@F7I_CONVCT,@F7I_FXRTCT
			---------------------------------------------
			If ( @E2_VALOR = 0 )
				Begin 
					select @F7I_CONVBS = 0
                    select @F7I_FXRTBS = '0'
                    select @F7I_CONVCT = 0
                    select @F7I_FXRTCT = '0'
				End
			Else
				Begin 
					If @E2_TXMOEDA > 0
						Begin
							select @F7I_CONVBS = ROUND((@E2_TXMOEDA), @DecCONVBS)
							select @F7I_CONVCT = @F7I_CONVBS
						End
					If @E2_TXMOEDA = 0 and @E2_MOEDA > '1'
						Begin
							exec MAT020_## @F7I_EMISSA, @F7I_MOEDA, @F7I_CONVBS OutPut
							select @F7I_CONVCT = @F7I_CONVBS
						End
                    If ( @E2_VLCRUZ / @E2_VALOR <> 0  )
						Begin
							select @F7I_FXRTBS = '1'
                            select @F7I_FXRTCT = '1'
						End
					Else
						Begin 
							select @F7I_FXRTBS = '0'
                            select @F7I_FXRTCT = '0'
						End	                                 
				End
			---------------------------------------------
			--Fim tratamento Campo @F7I_CONVBS,@F7I_FXRTBS,@F7I_CONVCT,@F7I_FXRTCT
			---------------------------------------------
			/**********************************************************************************************************************************************************/						
			exec XFILIAL_## 'CTT', @E2_FILORIG, @filialCTT OutPut

			If ((@E2_CCUSTO IS NULL) OR @E2_CCUSTO = ' ')
				Begin
					SELECT @F7I_CCUSTO = @ED_CCD
					SELECT @F7I_DSCCCT = ' '
					IF @ED_CCD <> ' '
						Begin
							SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @ED_CCD AND D_E_L_E_T_ = ' ')
						End
				End
			Else
				Begin 
					SELECT @F7I_CCUSTO = @E2_CCUSTO
					SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @E2_CCUSTO AND D_E_L_E_T_ = ' ')
				End
			
			---------------------------------------------
			--Tratamento Campo @F7I_CNTCTB
			---------------------------------------------
			If ( (@CT1_CONTA is null) or (@CT1_CONTA = ' ') )
                Begin
				    select @F7I_CNTCTB = '0'
                End
			Else
				Begin 
					select @F7I_CNTCTB = @CT1_CONTA
				End
			---------------------------------------------
			--Fim tratamento Campo @F7I_CNTCTB
			---------------------------------------------
			/**********************************************************************************************************************************************************/
		
			/**********************************************************************************************************************************************************/
			---------------------------------------------
			--Tratamento Campo @F7I_INTEGR
			---------------------------------------------
			If ( Trim(@se2_deleted) = '*' Or Trim(@sev_deleted) = '*' Or Trim(@sez_deleted) = '*' Or @E2_SALDO = 0 )
                Begin
				    select @F7I_INTEGR = 'E'					
                End
			Else
				Begin 
					select @F7I_INTEGR = ' '
				End
			---------------------------------------------
			--Fim tratamento Campo @F7I_INTEGR
			---------------------------------------------
			/**********************************************************************************************************************************************************/
			---------------------------------------------
			--Tratamento Campo @F7I_PAMOV
			---------------------------------------------
			If @F7I_TIPO = 'PA'
				Begin
					select @F7I_PAMOV = 'S'
					If @F7I_IDMOV <> ' '
						Begin							
							Select @F7I_SALDO = 0
							Select @F7I_VLPROP = 0
							Select @F7I_INTEGR = 'E'
						End
					Else
						Begin 
							select @F7I_PAMOV = 'N'
						End
				End
			Else
				Begin
					select @F7I_PAMOV = ' '
				End	
			---------------------------------------------
			--Fim tratamento Campo @F7I_PAMOV
			---------------------------------------------		
			---------------------------------------------
			--Ultimo tratamento Campo @F7I_INTEGR sobre Rateio
			---------------------------------------------
			if @trataRecDelEv = '*' or @trataRecDelEz = '*'
				Begin
					If @CountEZ > 0 OR @F7I_INTEGR = 'E'
						Begin
							select @F7I_SALDO = 0
							select @F7I_VLPROP = 0
							select @F7I_INTEGR = 'E'
						End
					Else
						Begin
							If @sev_deleted = '*'
								Begin
									select @F7I_SALDO = 0
									select @F7I_VLPROP = 0
									select @F7I_INTEGR = 'E'
								End
						End
				End

			if Trim(@copyIntegr)  = 'E'
				Begin
					select @F7I_SALDO = 0
					select @F7I_VLPROP = 0
					select @F7I_INTEGR = 'E'
				End
			---------------------------------------------
			--Fim Novo tratamento Campo @F7I_INTEGR
			---------------------------------------------

			--correcao para arredondamento de conversao ocorre apenas em mssql
			##IF_001({|| Trim(TcGetDb()) == "MSSQL" })
				IF  @cF7J_STAMP NOT LIKE '%.%'
					BEGIN 
						SELECT @cF7J_STAMP = TRIM(@cF7J_STAMP) + '.000' 
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
			-- Fim do tratamento dos campos para serem gravados na tabela F7I
			/**********************************************************************************************************************************************************/

			/**********************************************************************************************************************************************************/
			-- Inclusão dos registros
			/**********************************************************************************************************************************************************/
			##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
			insert into F7I### (
						F7I_STAMP,
						F7I_EXTCDH,
						F7I_EXTCDD,
						F7I_GRPEMP,
						F7I_EMPR,
						F7I_UNID,
						F7I_FILNEG,
						F7I_ORGSYT,
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
						F7I_VENCTO,
						F7I_VENCRE,
						F7I_TPEVNT,				 
						F7I_FLBENF,
						F7I_CDBENF,
						F7I_LJBENF,
						F7I_NBENEF,
						F7I_TPBENF,
						F7I_ORBENF,
						F7I_MOVIM,
						F7I_DSCMOV,
						F7I_SALDO,
						F7I_VLPROP,
						F7I_VLCRUZ,
						F7I_CONVBS,
						F7I_FXRTBS,
						F7I_VLRCNT,
						F7I_CONVCT,
						F7I_FXRTCT,
						F7I_CNTCTB,
						F7I_DSCCTB,
						F7I_NATCTA,
						F7I_CCUSTO,
						F7I_DSCCCT,
						F7I_NATURE,
						F7I_NATRAT,
						F7I_CCDRAT,
						F7I_INTEGR,
						F7I_PAMOV,
						F7I_CREDIT,
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
						F7I_CONTA,
						F7I_IDMOV	
						--#insertflex						
					) Values (
						@cF7I_STAMP,
						@F7I_EXTCDH,
						@F7I_EXTCDD,
						IsNull(@IN_GROUPEMPRESA,' '),
						IsNull(@param_COMPANIA,' '),
						IsNull(@param_COD_UNID,' '),
						IsNull(@param_COD_FIL,' '),
						'CP',--@F7I_ORGSYT,
						@F7I_EMISSA,
						@F7I_EMIS1,
						@F7I_HIST,
						@F7I_TIPO,
						@F7I_TIPDSC,
						@F7I_PREFIX,
						@F7I_NUM,
						@F7I_PARCEL,
						@F7I_MOEDA,
						SUBSTRING(IsNull(@F7I_DSCMDA, ' '),1,10),
						@F7I_VENCTO,
						@F7I_VENCRE,
						'S',--@F7I_TPEVNT,				 
						IsNull(@F7I_FLBENF, ' '),
						IsNull(@F7I_CDBENF, ' '),
						IsNull(@F7I_LJBENF, ' '),
						IsNull(SUBSTRING(@F7I_NBENEF,1,50), ' '),
						'3',--@F7I_TPBENF,
						'CP',--@F7I_ORBENF,
						IsNull(@F7I_MOVIM,' '),
						@F7I_DSCMOV,
						@F7I_SALDO,
						@F7I_VLPROP,
						@F7I_VLCRUZ,
						@F7I_CONVBS,
						@F7I_FXRTBS,
						0 , --@F7I_VLRCNT,
						@F7I_CONVCT,
						@F7I_FXRTCT,
						@F7I_CNTCTB,
						IsNull(@F7I_DSCCTB,' '),
						@F7I_NATCTA,
						@F7I_CCUSTO,
						IsNull(SUBSTRING(@F7I_DSCCCT,1,40),' '),
						@F7I_NATURE,
						@F7I_NATRAT,
						@F7I_CCDRAT,
						@F7I_INTEGR,
						@F7I_PAMOV,
						@F7I_CREDIT,
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
						'PREV' ,--@F7I_CONTA,
						@F7I_IDMOV
						--#variaveisflex
					)
			##CHECK_TRANSACTION_COMMIT
			---------------------------------------------
			--Gravação tabela de transacao
			---------------------------------------------		
			INSERT INTO F7J###  (
				F7J_FILIAL,
				F7J_ALIAS,
				F7J_RECNO,
				F7J_STAMP
			) VALUES(
				' ',
				'CPP',
				@Se2Recno , 
				@cF7J_STAMP
			)


			/**********************************************************************************************************************************************************/
			-- Fim Gravação tabela de transacao
			/**********************************************************************************************************************************************************/



			/**********************************************************************************************************************************************************/
			-- Posiciona para o proximo registro do cursor
			/**********************************************************************************************************************************************************/
			fetch next from curPagarPrev			
				into @F7I_STAMP,
					 @F7I_EXTCDH,
					 @F7I_EXTCDD,
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
					 @F7I_VENCTO,
					 @F7I_VENCRE,
					 @F7I_FLBENF,
					 @F7I_CDBENF,
					 @F7I_LJBENF,
					 @F7I_NBENEF,
					 @F7I_MOVIM,
					 @F7I_DSCMOV,
					 @E2_BAIXA,
					 @E2_SALDO,
					 @ABAT,
					 @E2_ACRESC,
					 @E2_DECRESC,
					 @E2_TIPO,
					 @sev_deleted,
					 @sez_deleted,
					 @EV_PERC,
					 @EZ_PERC,
					 @F7I_VLCRUZ,	
					 @E2_VLCRUZ,				 
					 @E2_VALOR,
					 @CT1_CONTA,
					 @F7I_DSCCTB,
					 @F7I_NATCTA,
					 @E2_CCUSTO,
					 @ED_CCD,
					 @F7I_NATURE,
					 @F7I_NATRAT,
					 @F7I_CCDRAT,
					 @se2_deleted,
					 @FK7_IDDOC,
					 @F7I_CREDIT,
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
					 @F7I_IDMOV,
					 @FK5_VALOR,	
					 @FK5_TXMOED,	
					 @FK5_MOEDA,	
					 @E2_MOEDA,
					 @Se2Recno,
					 @CountEZ,
				 	 @trataRecDelEv,
				 	 @trataRecDelEz,
					 @copyIntegr,
					 @E2_TXMOEDA
					 --#cursorflex

	End	

	DELETE FROM 
		F7J###
    WHERE F7J_STAMP < @delTransactTime 
      AND F7J_ALIAS = 'CPP'
	  AND F7J_STAMP < (
			SELECT MAX(F7J_STAMP ) FROM 
				F7J### 
			WHERE 
				F7J_ALIAS = 'CPP'
		)
		

	close curPagarPrev
	deallocate curPagarPrev
	select @OUT_RESULTADO = '1'
	
End