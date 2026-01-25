-- =============================================
-- Author:		Luiz Gustavo Romeiro de Jesus
-- Create date: 05/02/2025
-- Description:	Geracao dos titulos a receber previsto
-- =============================================

CREATE PROCEDURE FIN006_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
	@IN_TAMSED  Integer,
	@IN_TAMCT1  Integer,
	@IN_TAMCTT  Integer,
	@IN_TAMSX5  Integer,
	@IN_TAMSA1  Integer,
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
	@IN_CARTEIRAD char(1),
	@IN_TRANSACTION  Char(1),
	@DecCONVBS integer,
	@OUT_RESULTADO Char(1) OutPut
) AS

	-----------------------------------------------------------------
	-- 1- Criando as variaveis
	-----------------------------------------------------------------
	declare @N_TAMTOTAL Integer	
	declare @filial    char('E1_FILORIG')
	declare @filialCTT char('CTT_FILIAL')
	declare @param_DTINI char('F7I_EMIS1')
	declare @param_DTFIM char('F7I_EMIS1')

	declare @param_COMPANIA char('##COMPANIA')
    declare @param_COD_UNID char('##COD_UNID')
    declare @param_COD_FIL char('##COD_FIL')

	-- Variaveis gravacao
	declare @F7I_STAMP	Datetime
	declare @F7I_EXTCDH char('F7I_EXTCDH')
	declare @F7I_EXTCDD char('EV_MSUID')
	declare @F7I_EMISSA char('F7I_EMISSA')
	declare @F7I_EMIS1  char('F7I_EMIS1')
	declare @F7I_HIST	char('F7I_HIST')
	declare @F7I_TIPO	char('F7I_TIPO')
	declare @F7I_TIPDSC char('X5_DESCRI')
	declare @F7I_PREFIX char('F7I_PREFIX')
	declare @F7I_NUM 	char('F7I_NUM')
	declare @F7I_PARCEL char('F7I_PARCEL')
	declare @F7I_MOEDA  Integer
	declare @F7I_DSCMDA char('F7I_DSCMDA')
	declare @F7I_VENCTO char('F7I_VENCTO')
	declare @F7I_VENCRE char('F7I_VENCRE')
	declare @F7I_BANCO  char('F7I_BANCO')
	declare @F7I_AGENCI char('F7I_AGENCI')	
	declare @F7I_CONTA  char('F7I_CONTA')
	declare @F7I_FLBENF char('F7I_FLBENF')
	declare @F7I_CDBENF char('F7I_CDBENF')
	declare @F7I_LJBENF char('F7I_LJBENF')
	declare @F7I_NBENEF char('A1_NOME')
	declare @F7I_MOVIM  char('F7I_MOVIM')
	declare @F7I_DSCMOV char('FRV_DESCRI')
	declare @F7I_SALDO  float
	declare @F7I_VLPROP float
	declare @F7I_VLCRUZ float
	declare @F7I_CONVBS float
	declare @F7I_FXRTBS char('F7I_FXRTBS')
	declare @F7I_CONVCT float
	declare @F7I_FXRTCT char('F7I_FXRTCT')
	declare @F7I_CNTCTB char('F7I_CNTCTB')
	declare @F7I_DSCCTB char('F7I_DSCCTB')
	declare @F7I_NATCTA char('F7I_NATCTA')
	declare @F7I_CCUSTO char('F7I_CCUSTO')
	declare @F7I_DSCCCT char('F7I_DSCCCT')
	declare @F7I_NATURE char('F7I_NATURE')
	declare @F7I_NATRAT char('F7I_NATRAT')
	declare @F7I_CCDRAT char('F7I_CCDRAT')
	declare @F7I_INTEGR char('F7I_INTEGR')
	declare @F7I_CREDIT char('F7I_CREDIT')
	declare @F7I_DEBITO char('F7I_DEBITO')
	declare @F7I_CCD	char('F7I_CCD')
	declare @F7I_CCC	char('F7I_CCC')
	declare @F7I_ITEMCT char('F7I_ITEMCT')
	declare @F7I_ITEMD	char('F7I_ITEMD')
	declare @F7I_ITEMC	char('F7I_ITEMC')
	declare @F7I_CLVL	char('F7I_CLVL')
	declare @F7I_CLVLDB char('F7I_CLVLDB')
	declare @F7I_CLVLCR char('F7I_CLVLCR')
	declare @F7I_NUMBOR char('F7I_NUMBOR')


	-- Variaveis Cursor
	declare @iRecno		Integer  
	declare @iRecnoDel	Integer  
	declare @Se1Recno	Integer  

	declare @E1_EMIS1   char('E1_EMIS1')
	declare @E1_PORTADO char('E1_PORTADO')
	declare @E1_CONTA   char('E1_CONTA')
	declare @E1_AGEDEP  char('E1_AGEDEP')
	declare @E1_BAIXA   char('E1_BAIXA')
	declare @E1_ACRESC  float
	declare @E1_DECRESC float
	declare @E1_SALDO   float
	declare @E1_VALOR   float
	declare @FRV_DESCON char('FRV_DESCON')
	declare @EV_PERC    float
	declare	@EZ_PERC    float
	declare @CT1_CONTA  char('CT1_CONTA')
	declare @ED_CCC 	char('ED_CCC')
	declare @E1_CCUSTO 	char('E1_CCUSTO')
	declare @ABAT		float
	declare @se1_Deleted char(1)
	declare @sev_Deleted char(1)
	declare @sez_Deleted char(1)
	declare @trataRecDelEv char(1) 
	declare @trataRecDelEz char(1) 
	declare @copyIntegr char(1)
	Declare @CountEZ integer
	declare @E1_TXMOEDA float
	declare flex char(1)


	-- Times
	declare @maxStagingCounter Datetime 
	declare @cF7I_STAMP char('F7I_STAMP')
	declare @cF7J_STAMP char('F7J_STAMP')
	declare @cStamp char('F7J_STAMP')
	declare @delTransactTime char('F7J_STAMP')
	declare @dtInifilter char(8)

BEGIN	
	-----------------------------------------------------------------
	-- 2- Definindos as variaveis
	-----------------------------------------------------------------

	select @N_TAMTOTAL = @IN_TAMEMP + @IN_TAMUNIT +	@IN_TAMFIL
	select @param_DTINI = @IN_DTINI
	select @param_DTFIM = @IN_DTFIM

	select @param_COMPANIA = @IN_COMPANIA
    select @param_COD_UNID = @IN_COD_UNID
    select @param_COD_FIL = @IN_COD_FIL

	-----------------------------------------------------------------
	-- 3- Validando se existe necessidade de limpeza
	-----------------------------------------------------------------
	If ( @param_DTINI <> ' ' and @param_DTFIM <> ' ' and @IN_DEL = 'S') --Adicionar tratamento com parametro de limpeza
        BEGIN
            ##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
            delete F7I###
			where 
				F7I_FILIAL  = ' '
				And F7I_DTPGTO BETWEEN @param_DTINI and @param_DTFIM
				And TRIM(F7I_GRPEMP) = Trim(@IN_GROUPEMPRESA)
				And TRIM(F7I_EMPR) = Trim(@IN_COMPANIA)
				And TRIM(F7I_UNID) = Trim(@IN_COD_UNID)
				And TRIM(F7I_FILNEG) = Trim(@IN_COD_FIL) 
				AND F7I_ORGSYT = 'CR'
            ##CHECK_TRANSACTION_COMMIT 
        END
	
	Select @F7I_EMIS1  = ' '
	Select @CountEZ = 0
	select @F7I_CONVBS = 0
	select @F7I_CONVCT = 0


	Select @cStamp = (SELECT MIN(F7J_STAMP) FROM F7J### F7J WHERE F7J.F7J_ALIAS = 'CRP' )
	--sera convertido para 127 no ponto de entrada
	Select @delTransactTime = CONVERT(CHAR(26), DATEADD(HOUR, -1, GETUTCDATE()), 121)

	If @cStamp is not null 
		Begin
			If @cStamp > @delTransactTime
				Begin
					--sera convertido para 127 no ponto de entrada
					Select @maxStagingCounter  = convert(datetime, @delTransactTime ,121 ) 
				End
			Else
				Begin
					--sera convertido para 127 no ponto de entrada
					Select @maxStagingCounter  = convert(datetime, @cStamp,121 ) 
				End
		End

	If (@param_DTINI = ' ' and @param_DTFIM = ' ')
        Begin
			select @param_DTINI = Convert(CHAR(8),DateAdd(Year,-2,GetDate()),112)
			select @param_DTFIM = Convert(CHAR(8), GetDate(), 112)
            
        End
	If ( @param_DTINI is null )
		Begin
			Select @dtInifilter = Convert(CHAR(8),DateAdd(Year,-2,GetDate()),112)
		End
	Else
		Begin
			Select @dtInifilter = @param_DTINI 
		End

	-----------------------------------------------------------------
	-- 4- Gerando o Cursor da query principal
	-----------------------------------------------------------------
	declare curRecPrevisto insensitive cursor for
	--Main Query
	Select 	
		stamp_se1                                                                                       as F7I_STAMP,
		LOWER(CONVERT(VARCHAR(32), HashBytes('MD5',CONCAT(Trim(@IN_mdmTenantId),protheus_pk,E1_FILORIG)), 2)) as F7I_EXTCDH,	
		COALESCE(CAST(EZ_MSUID AS VARCHAR(36)) ,CAST(EV_MSUID AS VARCHAR(36)) ) 						as F7I_EXTCDD,
		E1_EMISSAO																						as F7I_EMISSA,
		E1_EMIS1																						as F7I_EMIS1,
		COALESCE(E1_HIST,' ')																			aS F7I_HIST,
		E1_TIPO					                                                                        as F7I_TIPO,
		X5_DESCRI																				        as F7I_TIPDSC,
		E1_PREFIXO 				                                                                        as F7I_PREFIX,
		E1_NUM 					                                                                        as F7I_NUM,
		E1_PARCELA 				                                                                        as F7I_PARCEL,	
		E1_MOEDA 				                                                                        as F7I_MOEDA,
		Isnull(DESC_MOEDA ,' ')	                                                                        as F7I_DSCMDA,
		E1_VENCTO																				        as F7I_VENCTO,
		E1_VENCREA																				        as F7I_VENCRE,
		TRIM(E1_PORTADO) 																				AS E1_PORTADO,
		TRIM(E1_CONTA) 																					AS E1_CONTA,
		TRIM(E1_AGEDEP) 																				AS E1_AGEDEP,
		Isnull(A1_FILIAL,' ')                                                                           as F7I_FLBENF,
        Isnull(A1_COD,' ')                                                                              as F7I_CDBENF,
        Isnull(A1_LOJA,' ')	                                                                            as F7I_LJBENF,
		Isnull(A1_NOME,' ')	                                                                            as F7I_NBENEF,
		E1_SITUACA                  																    as F7I_MOVIM,
		Isnull(FRV_DESCRI,' ' )               													        as F7I_DSCMOV,
		Isnull(FRV_DESCON,' ' ),
		E1_BAIXA,
		E1_SALDO ,
		ABAT,
		E1_ACRESC,
		E1_DECRESC,
		se1_Deleted,
		sev_Deleted,
		sez_Deleted,
		EV_PERC,
		EZ_PERC,
		E1_VLCRUZ 																						AS F7I_VLCRUZ, -- Gesplan faz o calculo do campo conforme a taxa do conversionBusiness
		E1_VALOR,
		Isnull(CT1_CONTA,' ' )                                                                          As CT1_CONTA,
		Isnull(CT1_DESC01,' ' ) 																		AS F7I_DSCCTB,    
		Isnull(CT1_NATCTA,' ' ) 																		AS F7I_NATCTA,
		Isnull(ED_CCC,' ' )                                                                             as ED_CCC,
		Isnull(E1_CCUSTO,' ' )																			as E1_CCUSTO,
		E1_NATUREZ																				        as F7I_NATURE,      
		Isnull(EV_NATUREZ,' ' )																        	as F7I_NATRAT,
		Isnull(EZ_CCUSTO,' ' )																	        as F7I_CCDRAT,
		E1_CREDIT																						as F7I_CREDIT,
		E1_DEBITO																						as F7I_DEBITO,
		E1_CCD																							as F7I_CCD,
		E1_CCC																							as F7I_CCC,
		E1_ITEMCTA																						as F7I_ITEMCT,
		E1_ITEMD																						as F7I_ITEMD,
		E1_ITEMC																						as F7I_ITEMC,
		E1_CLVL																							as F7I_CLVL,
		E1_CLVLDB																						as F7I_CLVLDB,
		E1_CLVLCR																						as F7I_CLVLCR,
		E1_NUMBOR																						as F7I_NUMBOR,
		recno_se1,
		IsNull(CountEZ, 0)																				as CountEZ,
		evdeleted,
		ezdeleted,
		copyIntegr,
		E1_FILORIG, --@filial
		E1_TXMOEDA                                                                                      as E1_TXMOEDA
		,'#selectcursorflex' as cursorflex
	from (
			SELECT			
				RTrim(@IN_GROUPEMPRESA)  || '|' || RTrim(se1_principal.E1_FILIAL)  || '|' || RTrim(se1_principal.E1_PREFIXO)  || '|' || RTrim(se1_principal.E1_NUM)  || '|' || RTrim(se1_principal.E1_PARCELA)  || '|' ||RTrim(se1_principal.E1_TIPO) as protheus_pk,
				se1_principal.E1_FILIAL,
				se1_principal.SE1_S_T_A_M_P_,
				se1_principal.E1_PREFIXO,
				se1_principal.E1_NUM,
				se1_principal.E1_PARCELA,
				se1_principal.E1_NATUREZ,    
				se1_principal.E1_SITUACA,
				se1_principal.E1_FILORIG,
				se1_principal.E1_EMISSAO,
				se1_principal.E1_EMIS1,
				se1_principal.E1_HIST,
				se1_principal.E1_MOEDA,
				se1_principal.E1_VENCTO,
				se1_principal.E1_VENCREA,
				se1_principal.E1_PORTADO,
				se1_principal.E1_AGEDEP,
				se1_principal.E1_CONTA,
				se1_principal.E1_BAIXA,
				se1_principal.E1_SALDO,
				se1_principal.E1_ACRESC,
				se1_principal.E1_DECRESC,
				se1_principal.E1_VLCRUZ,
				se1_principal.E1_VALOR,
				se1_principal.E1_CREDIT,
				se1_principal.E1_DEBITO,
				se1_principal.E1_CCD,
				se1_principal.E1_CCC,
				se1_principal.E1_ITEMCTA,
				se1_principal.E1_ITEMD,
				se1_principal.E1_ITEMC,
				se1_principal.E1_CLVL,
				se1_principal.E1_CLVLDB,
				se1_principal.E1_CLVLCR,
				se1_principal.E1_NUMBOR,
				se1_principal.E1_TXMOEDA,
				se1_principal.E1_MULTNAT,
				se1_principal.se1_Deleted, 
				se1_principal.stamp_se1,
				se1_principal.recno_se1,
				se1_principal.E1_TIPO as E1_TIPO,
				TRIM(se1_principal.E1_CCUSTO) as E1_CCUSTO,
				se1_principal.E1_CLIENTE as E1_CLIENTE,
				se1_principal.E1_LOJA as E1_LOJA,    
				se1_abatimentos.ABAT,
				sed.ED_FILIAL,
				sed.ED_CODIGO,
				sed.ED_CREDIT,
				sed.ED_DEBITO,
				sed.ED_CCC,
				ct1.CT1_CONTA,
				ct1.CT1_FILIAL,
				ct1.CT1_DESC01,
				ct1.CT1_NATCTA,
				sx5_consolidate.X5_CHAVE,
				sx5_consolidate.X5_FILIAL,
				sx5_consolidate.X5_DESCRI,
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
				sev.EV_MSUID,
				sev.EV_VALOR,
				sev.EV_PERC,
				sev.D_E_L_E_T_ as sev_Deleted,
				sez.EZ_FILIAL,
				sez.EZ_PREFIXO,
				sez.EZ_NUM,
				sez.EZ_PARCELA,
				sez.EZ_TIPO,
				trim(sez.EZ_CLIFOR) as EZ_CLIFOR,
				sez.EZ_CCUSTO,
				trim(sez.EZ_LOJA) as EZ_LOJA,
				sez.EZ_NATUREZ,
				sez.EZ_IDENT,
				sez.EZ_SEQ,
				sez.EZ_SITUACA,
				sez.EZ_MSUID,
				sez.EZ_VALOR,
				sez.EZ_PERC,
				sez.D_E_L_E_T_ as sez_Deleted,
				currency.DESC_MOEDA,
				sa1.A1_FILIAL,
				sa1.A1_COD,
				sa1.A1_LOJA,
				sa1.A1_NOME,
				FRV_FILIAL,
				FRV_CODIGO,
				FRV_DESCRI,
				frv.FRV_DESCON,
				RateioEZ.CountEZ,
				tratarateio.evdeleted,
				tratarateio.ezdeleted,
				copyIntegr
				,'#campoflex' as campoflex
			FROM
				(
					SELECT DISTINCT
						' ' copyIntegr,
						E1_FILIAL,
						E1_FILORIG,
						S_T_A_M_P_ as SE1_S_T_A_M_P_,
						E1_PREFIXO,
						E1_NUM,
						E1_PARCELA,
						E1_NATUREZ,    
						E1_SITUACA,
						E1_EMISSAO,
						E1_EMIS1,
						E1_HIST,
						E1_MOEDA,
						E1_VENCTO,
						E1_VENCREA,
						E1_PORTADO,
						E1_AGEDEP,
						E1_CONTA,
						E1_BAIXA,
						E1_SALDO,
						E1_ACRESC,
						E1_DECRESC,
						E1_VLCRUZ,
						E1_VALOR,
						E1_CREDIT,
						E1_DEBITO,
						E1_CCD,
						E1_CCC,
						E1_ITEMCTA,
						E1_ITEMD,
						E1_ITEMC,
						E1_CLVL,
						E1_CLVLDB,
						E1_CLVLCR,
						E1_NUMBOR,
						E1_TXMOEDA,
						E1_MULTNAT,
						D_E_L_E_T_ se1_Deleted, 
						S_T_A_M_P_ stamp_se1,
						R_E_C_N_O_ recno_se1,
						E1_TIPO as E1_TIPO,
						TRIM(E1_CCUSTO) as E1_CCUSTO,
						E1_CLIENTE as E1_CLIENTE,
						E1_LOJA as E1_LOJA,
						' ' EV_NATUREZ_EZDEL
						,'#campoflexprincipal' as campoflexprincipal
					FROM
						SE1### se1 LEFT JOIN CT2### ON CT2_FILIAL = ' '
					WHERE
						Trim(se1.E1_TIPO) <> 'RA'
						And se1.E1_TIPO not like '%-'
				) se1_principal 
				Left Join (	
					SELECT
						se1_abatimentos.E1_FILIAL,
						se1_abatimentos.E1_FILORIG,
						se1_abatimentos.E1_PREFIXO,
						se1_abatimentos.E1_NUM,
						se1_abatimentos.E1_PARCELA,
						se1_abatimentos.E1_CLIENTE,
						se1_abatimentos.E1_LOJA,
						Sum(se1_abatimentos.E1_VALOR) as ABAT
					From
						SE1### se1_abatimentos LEFT JOIN CT2### ON CT2_FILIAL = ' '
					Where 
						se1_abatimentos.E1_TIPO like '%-'
						and se1_abatimentos.D_E_L_E_T_ = ' '
					Group By
						E1_FILIAL,
						E1_FILORIG,
						E1_PREFIXO,
						E1_NUM,
						E1_PARCELA,
						E1_CLIENTE,
						E1_LOJA
				) se1_abatimentos
				on 
					se1_principal.E1_FILIAL = se1_abatimentos.E1_FILIAL
					And se1_abatimentos.E1_PREFIXO = se1_principal.E1_PREFIXO
					And se1_abatimentos.E1_NUM = se1_principal.E1_NUM
					And se1_abatimentos.E1_PARCELA = se1_principal.E1_PARCELA
					And se1_abatimentos.E1_CLIENTE = se1_principal.E1_CLIENTE
					And se1_abatimentos.E1_LOJA  = se1_principal.E1_LOJA
					And se1_principal.E1_FILORIG = se1_abatimentos.E1_FILORIG

				inner join SED### sed on      
					sed.ED_FILIAL = SUBSTRING(se1_principal.E1_FILORIG,1,@IN_TAMSED) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSED)      
					and sed.ED_CODIGO = se1_principal.E1_NATUREZ
					and sed.D_E_L_E_T_ = ' '

				left join CT1### ct1 on      
					ct1.CT1_FILIAL = SUBSTRING(se1_principal.E1_FILORIG,1,@IN_TAMCT1) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMCT1)          
					and ct1.CT1_CONTA = sed.ED_CREDIT
					and ct1.D_E_L_E_T_ = ' '

				inner Join (
					SELECT X5_FILIAL, X5_CHAVE, X5_DESCRI FROM SX5### WHERE X5_TABELA = '05' AND D_E_L_E_T_ = ' '
				) sx5_consolidate
				on
					sx5_consolidate.X5_FILIAL = SUBSTRING(se1_principal.E1_FILORIG,1,@IN_TAMSX5) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSX5) 
					and Trim(sx5_consolidate.X5_CHAVE) = trim(se1_principal.E1_TIPO)
	  	
				left join SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' '
				On      
					sev.EV_FILIAL = SUBSTRING(se1_principal.E1_FILORIG,1,@IN_TAMSEV) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSEV)
					And sev.EV_PREFIXO = se1_principal.E1_PREFIXO 
					And sev.EV_NUM = se1_principal.E1_NUM 
					And sev.EV_PARCELA = se1_principal.E1_PARCELA	
					And sev.EV_TIPO = se1_principal.E1_TIPO 
					And sev.EV_CLIFOR = se1_principal.E1_CLIENTE
					And sev.EV_LOJA = se1_principal.E1_LOJA
					And sev.EV_IDENT = '1'  --Emissao
					And sev.EV_RECPAG = 'R'
					And sev.EV_MSUID is not null
					And se1_principal.E1_MULTNAT = '1'

				left join SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' '
				On      
					sev.EV_FILIAL = sez.EZ_FILIAL 
					And sev.EV_PREFIXO = sez.EZ_PREFIXO 
					And sev.EV_NUM = sez.EZ_NUM 
					And sev.EV_PARCELA = sez.EZ_PARCELA	
					And sev.EV_TIPO = sez.EZ_TIPO 
					And sev.EV_CLIFOR = sez.EZ_CLIFOR 
					And sev.EV_LOJA = sez.EZ_LOJA 
					And sev.EV_NATUREZ = sez.EZ_NATUREZ 
					And sez.EZ_RECPAG = 'R'
					And sez.EZ_IDENT = '1'
					And sez.EZ_MSUID is not null
					And se1_principal.E1_MULTNAT = '1'

				Left join (
					SELECT X6_VAR, X6_CONTEUD AS DESC_MOEDA FROM SX6### SX6 WHERE SX6.X6_VAR like '%MV_MOEDA%'
				) currency
				ON
					TRIM(currency.X6_VAR) = TRIM(CONCAT('MV_MOEDA', CAST(se1_principal.E1_MOEDA AS CHAR(2))))

				left join SA1### sa1 On      
				  	sa1.A1_FILIAL = SUBSTRING(se1_principal.E1_FILORIG,1,@IN_TAMSA1) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSA1)      
					And sa1.A1_COD = se1_principal.E1_CLIENTE
					And sa1.A1_LOJA = se1_principal.E1_LOJA
					And sa1.D_E_L_E_T_ = ' '

				left join FRV### frv LEFT JOIN CT2### ON CT2_FILIAL = ' ' On      
					frv.FRV_FILIAL = SUBSTRING(se1_principal.E1_FILORIG,1,@IN_TAMFRV) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMFRV)
					And frv.FRV_CODIGO = se1_principal.E1_SITUACA
					And frv.D_E_L_E_T_ = ' '

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
						SEZ.EZ_RECPAG = 'R'
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
					And COALESCE(sez.D_E_L_E_T_, ' ') = RateioEZ.D_E_L_E_T_

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
						SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' Left Join SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' '
						On
						  sev.EV_FILIAL = sez.EZ_FILIAL 
						  And sev.EV_PREFIXO = sez.EZ_PREFIXO 
						  And sev.EV_NUM = sez.EZ_NUM 
						  And sev.EV_PARCELA = sez.EZ_PARCELA	
						  And sev.EV_TIPO = sez.EZ_TIPO 
						  And sev.EV_CLIFOR = sez.EZ_CLIFOR 
						  And sev.EV_LOJA = sez.EZ_LOJA 
						  And sev.EV_NATUREZ = sez.EZ_NATUREZ 
						  And sez.EZ_RECPAG = 'R'
						  And sez.EZ_IDENT = '1'
						  And sez.EZ_MSUID is not null		
					where
						sev.EV_RECPAG = 'R'
						And sev.EV_IDENT = '1'  --Emissao
						And sev.EV_MSUID is not null
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
					And	(
						(COALESCE(tratarateio.ezdeleted, ' ') = '*' and tratarateio.evdeleted = ' ')
						or (tratarateio.evdeleted = '*' and COALESCE(tratarateio.ezdeleted, ' ') = ' ')
					)

				LEFT JOIN F7J### f7j
				ON 
					f7j.F7J_ALIAS = 'CRP' 
					AND TRIM(f7j.F7J_STAMP) = CONVERT(CHAR(26), se1_principal.stamp_se1, 121)
					AND f7j.F7J_RECNO = se1_principal.recno_se1
			  
				WHERE
					(
						(se1_principal.stamp_se1 > @maxStagingCounter
							or @maxStagingCounter is null
						) or (se1_principal.stamp_se1 is null
							and Convert(date, se1_principal.E1_EMIS1) > @maxStagingCounter
							and @maxStagingCounter is null
						) or ( @param_DTINI <> ' '
							AND @param_DTFIM <> ' '
							AND @IN_DEL = 'S'
						)
					) And (
						(
							se1_principal.E1_EMIS1 >= @dtInifilter
							-- AND se1_principal.E1_EMIS1 <= COALESCE(@param_DTFIM, Convert(CHAR(8), GetDate(), 112))
						) OR (
							( 
								se1_principal.E1_BAIXA >= @dtInifilter
								-- And se1_principal.E1_BAIXA <= COALESCE(@param_DTFIM, Convert(CHAR(8), GetDate(), 112))
							)
						) Or (
							se1_principal.E1_SALDO > 0
						)
					)
					AND f7j.F7J_RECNO is null
	)  ReceberPrevisto
	 for read only
	 -----------------------------------------------------------------
	 -- 5- Abrindo o cursor
	 -----------------------------------------------------------------
	 open curRecPrevisto
	 fetch next from curRecPrevisto
        into
			@F7I_STAMP,
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
			@F7I_DSCMDA,
			@F7I_VENCTO,
			@F7I_VENCRE,
			@E1_PORTADO,
			@E1_CONTA,
			@E1_AGEDEP, 
			@F7I_FLBENF,
			@F7I_CDBENF,
			@F7I_LJBENF,
			@F7I_NBENEF,
			@F7I_MOVIM,
			@F7I_DSCMOV,
			@FRV_DESCON,
			@E1_BAIXA,
			@E1_SALDO,
			@ABAT,
			@E1_ACRESC,
			@E1_DECRESC,
			@se1_Deleted, 
			@sev_Deleted,
			@sez_Deleted,
			@EV_PERC,
			@EZ_PERC,
			@F7I_VLCRUZ,
			@E1_VALOR,
			@CT1_CONTA,
			@F7I_DSCCTB,
			@F7I_NATCTA,
			@ED_CCC,
			@E1_CCUSTO,
			@F7I_NATURE,
			@F7I_NATRAT,
			@F7I_CCDRAT,
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
			@Se1Recno,
			@CountEZ,
			@trataRecDelEv,
			@trataRecDelEz,
			@copyIntegr,
			@filial,
			@E1_TXMOEDA
			--#cursorflex
		while ( (@@fetch_Status  = 0 ) )
		Begin
			-----------------------------------------------------------------
			-- 6- Abrindo o cursor
			-----------------------------------------------------------------

			-----------------------------------------------------------------
			-- 6.1- Conversao de valores
			-----------------------------------------------------------------
			Select @F7I_SALDO = 0
			Select @F7I_CCUSTO = ' '
			If ( @F7I_EXTCDD is null )
				Begin 
					select @F7I_EXTCDD = @F7I_EXTCDH
				End

			If (@F7I_HIST = ' ')
				begin
					select @F7I_HIST = 'SEM DESCRICAO'
				End

			If trim(@F7I_MOVIM) <> '0' and @F7I_MOVIM <> ' ' AND @E1_PORTADO <> ' '
				begin
					select @F7I_BANCO = TRIM(@E1_PORTADO)
					select @F7I_AGENCI = @E1_AGEDEP
					select @F7I_CONTA = @E1_CONTA
				end
			else
				begin
					select @F7I_BANCO = ' '
					select @F7I_AGENCI = ' '
					select @F7I_CONTA = 'PREV'
				End

			If @FRV_DESCON = '1' AND @IN_CARTEIRAD = 'S'
				begin
					select @F7I_SALDO = 0
				End
			else
				begin 
					If @E1_BAIXA = ' '
					begin
						If	(@E1_SALDO - ISNULL(@ABAT, 0) + @E1_ACRESC - @E1_DECRESC) < 0
							begin
								select @F7I_SALDO = 0
							End
						else
							begin
								select @F7I_SALDO = (@E1_SALDO - ISNULL(@ABAT, 0) + @E1_ACRESC - @E1_DECRESC)
							End
					end
					else
						begin
							If	(@E1_SALDO - ISNULL(@ABAT, 0)) < 0
								begin
									select @F7I_SALDO = 0
								End
							else
								begin
									select @F7I_SALDO = (@E1_SALDO - ISNULL(@ABAT, 0))
								End
						End
				End
			select @F7I_SALDO = COALESCE( @F7I_SALDO ,0)

			--F7I_VLPROP
			IF @FRV_DESCON = '1' AND @IN_CARTEIRAD = 'S' 
				Begin
					Select @F7I_VLPROP = 0
				End
			Else
				Begin
					If @EV_PERC IS NULL OR @sev_Deleted = '*' -- Rateio nao existe ou deletado
					Begin
						If COALESCE(@E1_BAIXA, ' ') = ' ' 
						Begin
							If (@E1_SALDO - ISNULL(@ABAT, 0) + @E1_ACRESC - @E1_DECRESC) < 0
								Begin
									Select @F7I_VLPROP = 0
								End
							Else
								Begin 
									Select @F7I_VLPROP = (@E1_SALDO - ISNULL(@ABAT, 0) + @E1_ACRESC - @E1_DECRESC)
								End
						End
						Else
							Begin 
								If @E1_SALDO < 0
									Begin
										Select @F7I_VLPROP = 0
									End
								Else
									Begin 
										Select @F7I_VLPROP =  @E1_SALDO 
									End
							End
					End
					Else
						Begin
							If ( @EZ_PERC IS NOT NULL AND @sez_Deleted = ' ')
								Begin
									If (@E1_SALDO * @EV_PERC * @EZ_PERC) < 0 
										Begin
											Select @F7I_VLPROP = 0
										End
									Else
										Begin
											Select @F7I_VLPROP = ROUND((@E1_SALDO * @EV_PERC * @EZ_PERC), 2)
										End
								End
							Else
								Begin
									If (@E1_SALDO * @EV_PERC) < 0
										Begin
											Select @F7I_VLPROP = 0
										End
									Else 
										Begin
											Select @F7I_VLPROP = ROUND((@E1_SALDO * @EV_PERC), 2)
										End
								End
						End
				End
			--validacoes com base no @E1_VALOR <> 0
			--nao alterar a ordem abaixo por conta da atualizacao do F7I_VLCRUZ por TRIM(@F7I_TIPO) = 'NCC'
			If @E1_VALOR <> 0
				Begin 
					
					If @E1_TXMOEDA > 0
						Begin
							select @F7I_CONVBS = ROUND((@E1_TXMOEDA), @DecCONVBS)
							--atualizacao do campo @F7I_CONVCT igual regra acima 
							Select @F7I_CONVCT = @F7I_CONVBS
						End
					If @E1_TXMOEDA = 0 and @F7I_MOEDA > 1
						Begin
							exec MAT020_## @F7I_EMISSA, @F7I_MOEDA, @F7I_CONVBS OutPut
							--atualizacao do campo @F7I_CONVCT igual regra acima 
							Select @F7I_CONVCT = @F7I_CONVBS
						End

					--atualizacao do campo @F7I_FXRTBS com base: @F7I_VLCRUZ / @E1_VALOR <> 0 mesma regra para  @F7I_FXRTCT
					If @F7I_CONVBS <> 0
						Begin
							Select @F7I_FXRTBS = '1'
							Select @F7I_FXRTCT = '1'
						End
					Else 
						Begin
							Select @F7I_FXRTBS = '0'
							Select @F7I_FXRTCT = '0'
						End
				End
			Else
				Begin
					Select @F7I_CONVBS = 0
					--atualizacao do campo @F7I_CONVCT igual regra acima 
					Select @F7I_CONVCT = 0
				End

			--nao alterar a ordem abaixo
			If TRIM(@F7I_TIPO) = 'NCC'
				Begin
					Select @F7I_VLPROP = @F7I_VLPROP * -1
					Select @F7I_VLCRUZ = @F7I_VLCRUZ * -1
					Select @F7I_SALDO  = @F7I_SALDO  * -1
				End

			If @CT1_CONTA = ' '
				Begin
					Select @F7I_CNTCTB = '0'
				End
			Else 
				Begin
					Select @F7I_CNTCTB = @CT1_CONTA 
				End
			
			exec XFILIAL_## 'CTT', @filial, @filialCTT OutPut

			If (@E1_CCUSTO IS NULL OR @E1_CCUSTO = ' ')
				Begin
					SELECT @F7I_CCUSTO = @ED_CCC
					SELECT @F7I_DSCCCT = ' '
					IF @ED_CCC <> ' '
						Begin
							SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @ED_CCC AND D_E_L_E_T_ = ' ')
						End
				End
			Else
				Begin 
					SELECT @F7I_CCUSTO = @E1_CCUSTO
					SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT  AND CTT_CUSTO = @E1_CCUSTO AND D_E_L_E_T_ = ' ')
				End
			

			If (@se1_Deleted = '*' OR @sev_Deleted = '*' OR @sez_Deleted = '*' OR (@FRV_DESCON = '1' AND @IN_CARTEIRAD = 'S') OR @E1_SALDO = 0 )
				Begin
					Select @F7I_INTEGR = 'E' 
				End
			Else 
				Begin
					Select @F7I_INTEGR = ' '
				End

			If ( @F7I_STAMP is null )
				Begin 
					If ( @F7I_EMIS1 = ' ' )
						Begin
							If ( @E1_BAIXA = ' ' )
								Begin
									Select @cF7I_STAMP = ' '
								End
							Else
								Begin
									Select @cF7I_STAMP = FORMAT(Convert(date, @E1_BAIXA), 'yyyy-MM-ddTHH:mm:ss.fff')
								End
						End
					Else
						Begin
							Select @cF7I_STAMP = FORMAT(Convert(date, @F7I_EMIS1), 'yyyy-MM-ddTHH:mm:ss.fff')
						End
					Select @cF7J_STAMP = @delTransactTime
				End	
			Else 
				Begin
					Select @cF7I_STAMP = CONVERT(CHAR(26), @F7I_STAMP, 121)
					Select @cF7J_STAMP = @cF7I_STAMP
				End 

			-----------------------------------------------------------------
			-- 6.1-  FIM
			-----------------------------------------------------------------
			select 
				@iRecnoDel = Isnull(Min(R_E_C_N_O_), 0)
			From 
				F7I###
			Where 
				F7I_EXTCDH =@F7I_EXTCDH
				AND F7I_EXTCDD = @F7I_EXTCDD

			If @iRecnoDel > 0 and trim(@param_DTINI) <> ' ' and trim(@param_DTFIM) <> ' ' and @IN_DEL = 'S'
				Begin
					##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
					delete F7I###
					where 
						F7I_EXTCDH = @F7I_EXTCDH
						AND F7I_EXTCDD = @F7I_EXTCDD 
						And R_E_C_N_O_ = @iRecnoDel
					##CHECK_TRANSACTION_COMMIT
				End

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
							If @sev_Deleted = '*'
								Begin
									select @F7I_SALDO = 0
									select @F7I_VLPROP = 0
									select @F7I_INTEGR = 'E'
								End
						End
				End

			if Trim(@copyIntegr) = 'E'
				Begin
					select @F7I_SALDO = 0
					select @F7I_VLPROP = 0
					select @F7I_INTEGR = 'E'
				End
				
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
			---------------------------------------------
			--Fim Novo tratamento Campo @F7I_INTEGR
			---------------------------------------------
			SELECT @param_COMPANIA = SUBSTRING(@filial,1, @IN_TAMEMP )
			SELECT @param_COD_UNID = SUBSTRING(@filial,@IN_TAMEMP+1, @IN_TAMUNIT)
			SELECT @param_COD_FIL = SUBSTRING(@filial,@IN_TAMEMP+1 + @IN_TAMUNIT , @IN_TAMEMP + @IN_TAMUNIT + @IN_TAMFIL)

			-----------------------------------------------------------------
			-- 7- Efetuando a inclusao dos registros
			-----------------------------------------------------------------
			##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
			INSERT INTO F7I### (
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
				F7I_MOEDB,
				F7I_DSCMDB,
				F7I_VENCTO,
				F7I_VENCRE,
				F7I_DTPGTO,
				F7I_TPEVNT,
				F7I_BANCO,
				F7I_AGENCI,
				F7I_CONTA,
				F7I_FLBENF,
				F7I_CDBENF,
				F7I_LJBENF,
				F7I_NBENEF,
				F7I_TPBENF,
				F7I_ORBENF,
				F7I_MOVIM,
				F7I_DSCMOV,
				F7I_IDMOV,
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
				F7I_INTEGR
				--#insertflex
			) Values (
				@cF7I_STAMP,
				@F7I_EXTCDH,
				@F7I_EXTCDD,
				IsNull(@IN_GROUPEMPRESA,' '),
				IsNull(@param_COMPANIA,' '),
				IsNull(@param_COD_UNID,' '),
				IsNull(@param_COD_FIL,' '),
				'CR', --@F7I_ORGSYT,
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
				0 , --@F7I_MOEDB,
				' ', --@F7I_DSCMDB,
				@F7I_VENCTO,
				@F7I_VENCRE,
				' ',--@F7I_DTPGTO,
				'E',--@F7I_TPEVNT,
				@F7I_BANCO,
				@F7I_AGENCI,
				@F7I_CONTA,
				IsNull(@F7I_FLBENF, ' '),
				IsNull(@F7I_CDBENF, ' '),
				IsNull(@F7I_LJBENF, ' '),
				IsNull(SUBSTRING(@F7I_NBENEF,1,50), ' '),
				'1',--@F7I_TPBENF,
				'CR', --@F7I_ORBENF,
				@F7I_MOVIM,
				@F7I_DSCMOV,
				' ',-- F7I_IDMOV
				@F7I_SALDO,
				@F7I_VLPROP,
				@F7I_VLCRUZ,
				@F7I_CONVBS,
				@F7I_FXRTBS,
				0 ,--@F7I_VLRCNT,
				@F7I_CONVCT,
				@F7I_FXRTCT,
				@F7I_CNTCTB,
				IsNull(SUBSTRING(@F7I_DSCCTB,1,40),' '),
				@F7I_NATCTA,
				@F7I_CCUSTO,
				IsNull(SUBSTRING(@F7I_DSCCCT,1,40),' '),
				@F7I_NATURE,
				@F7I_NATRAT,
				@F7I_CCDRAT,
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
				@F7I_INTEGR
				--#variaveisflex
			)
			##CHECK_TRANSACTION_COMMIT

			INSERT INTO F7J###  (
				F7J_FILIAL,
				F7J_ALIAS,
				F7J_RECNO,
				F7J_STAMP
			) VALUES(
				' ',
				'CRP',
				@Se1Recno , 
				@cF7J_STAMP
			)
					
			-----------------------------------------------------------------
			-- 10- Posiciona para o proximo registro
			-----------------------------------------------------------------
			fetch next from curRecPrevisto
            into
				@F7I_STAMP,
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
				@F7I_DSCMDA,
				@F7I_VENCTO,
				@F7I_VENCRE,
				@E1_PORTADO,
				@E1_CONTA,
				@E1_AGEDEP, 
				@F7I_FLBENF,
				@F7I_CDBENF,
				@F7I_LJBENF,
				@F7I_NBENEF,
				@F7I_MOVIM,
				@F7I_DSCMOV,
				@FRV_DESCON,
				@E1_BAIXA,
				@E1_SALDO,
				@ABAT,
				@E1_ACRESC,
				@E1_DECRESC,
				@se1_Deleted, 
				@sev_Deleted,
				@sez_Deleted,
				@EV_PERC,
				@EZ_PERC,
				@F7I_VLCRUZ,
				@E1_VALOR,
				@CT1_CONTA ,
				@F7I_DSCCTB,
				@F7I_NATCTA,
				@ED_CCC,
				@E1_CCUSTO,
				@F7I_NATURE,
				@F7I_NATRAT,
				@F7I_CCDRAT,
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
				@Se1Recno,
				@CountEZ,
				@trataRecDelEv,
				@trataRecDelEz,
				@copyIntegr,
				@filial,
				@E1_TXMOEDA
				--#cursorflex
		End
		
	DELETE FROM 
		F7J###
    WHERE F7J_ALIAS = 'CRP' 
      AND F7J_STAMP < @delTransactTime 
	  AND F7J_STAMP < (
			SELECT MAX(F7J_STAMP) FROM 
				F7J### 
			WHERE 
				F7J_ALIAS = 'CRP'
		)
	 -----------------------------------------------------------------
	 -- 11- Encerra o cursor
	 -----------------------------------------------------------------
	 close curRecPrevisto
	 deallocate curRecPrevisto	
	 select @OUT_RESULTADO = '1'
END