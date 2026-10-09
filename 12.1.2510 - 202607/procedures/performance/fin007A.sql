CREATE PROCEDURE FIN007A_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
	@IN_TAMSED  Integer,
	@IN_TAMCT1  Integer,
	@IN_TAMSX5  Integer,
	@IN_TAMSA2  Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
	@IN_COMPANIA char('##COMPANIA'),
	@IN_COD_UNID char('##COD_UNID'),
	@IN_COD_FIL char('##COD_FIL'),
	@IN_mdmTenantId char(32),
	@IN_DTINI char('F7I_EMIS1'),
	@IN_DTFIM char('F7I_EMIS1'),
    @IN_FULL char(1),
	@IN_TRANSACTION  Char(1),	
	@DecCONVBS Integer,
	@IN_maxStagingCounter Datetime,
	@IN_delTransactTime char('F7I_STAMP'),
	@IN_IDORIGEM char(32),
	@IN_LOTEPROC Char(6),
	@IN_DTCORTE char('F7I_EMIS1'),
	@OUT_RESULTADO Char(1) OutPut 
) AS

declare @N_TAMTOTAL Integer	
declare @param_DTINI char('F7I_EMIS1')
declare @param_DTFIM char('F7I_EMIS1')
declare @param_DTCORTE char('F7I_EMIS1')
declare @filialCTT char('CTT_FILIAL')
declare @param_COMPANIA char('##COMPANIA')
declare @param_COD_UNID char('##COD_UNID')
declare @param_COD_FIL char('##COD_FIL')
declare @cValMoeda char(2)
Declare @F7I_STAMP	Datetime
Declare @F7I_EXTCDH char('F7I_EXTCDH')
Declare @F7I_EXTCDD char('F7I_EXTCDD')
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
declare @E2_FILORIG	char('E2_FILORIG')
declare @E2_BAIXA	char('E2_BAIXA')
declare @E2_SALDO	float
declare @FK5_VALOR float
declare @FK5_TXMOED float
declare @FK5_MOEDA char('FK5_MOEDA')
declare @ABAT		float
declare @E2_MOEDA   float
declare @E2_SDACRES	float
declare @E2_SDDECRE float
declare @E2_TIPO	char('E2_TIPO')
declare @E2_VLCRUZ	float
declare @E2_VALOR	float
declare @CT1_CONTA	char('CT1_CONTA')
declare @E2_CCUSTO	char('E2_CCUSTO')
declare @ED_CCD		char('ED_CCD')
declare @se2_deleted char(1)
declare @FK7_FILIAL	char('FK7_FILIAL')
declare @FK7_IDDOC	char('FK7_IDDOC')
declare @maxStagingCounter Datetime
declare @delTransactTime char('F7I_STAMP')
declare @cF7I_STAMP char('F7I_STAMP')
declare @cF7J_STAMP char('F7J_STAMP')
declare @cStamp char('F7I_STAMP')
declare @Se2Recno	Integer  
declare @E2_TXMOEDA float
declare @MOEDA 		Float
declare @IS_ORGSYT char(2)
declare @IS_X5TAB05 char(2)
declare @IS_X5TAB58 char(2)
declare @IS_SPACE char(1)
declare @IS_ALIAS char(3)
declare @IS_TPDOCPA char('FK5_TPDOC')
declare @IS_TPDOCES char('FK5_TPDOC')
declare @IS_MVMOEDA char(8)
declare @IS_SEMRAT char(1)
declare @IS_ALIAS_CPP char(3)
declare @IS_TP_ABT char(2)
declare @IS_FIN007A char(7)
declare @ID_PROCESSO char(32)
declare @DATA_INICIO char(26)
declare @CONTADOR Integer 
declare flex char(1)

Begin

	select @N_TAMTOTAL = @IN_TAMEMP + @IN_TAMUNIT +	@IN_TAMFIL
	select @IS_ORGSYT = 'CP'
	select @IS_X5TAB05 = '05'
	select @IS_X5TAB58 = '58'
	select @IS_ALIAS = 'SE2'
	select @IS_SPACE = ' '
	select @IS_TPDOCPA = 'PA'
	select @IS_TPDOCES = 'ES'
	select @IS_MVMOEDA = 'MV_MOEDA'
	select @IS_SEMRAT = '2'
	select @MOEDA  = 0
	select @maxStagingCounter = @IN_maxStagingCounter
	select @delTransactTime = @IN_delTransactTime
	select @param_DTINI = @IN_DTINI
	select @param_DTFIM = @IN_DTFIM
	select @param_DTCORTE = @IN_DTCORTE
	select @F7I_EXTCDD = @IS_SPACE
	select @F7I_SALDO  = 0
	select @F7I_VLPROP = 0
	select @F7I_FXRTBS = '0'
	select @F7I_FXRTCT = '0'
	select @F7I_CNTCTB = '0'
	select @F7I_CCUSTO = @IS_SPACE
	select @F7I_INTEGR = @IS_SPACE
	select @IS_ALIAS_CPP = 'CPP'
	select @IS_TP_ABT = '%-'
	select @param_COMPANIA = @IN_COMPANIA
    select @param_COD_UNID = @IN_COD_UNID
    select @param_COD_FIL = @IN_COD_FIL
	select @IS_FIN007A = 'FIN007A'
	select @DATA_INICIO = CONVERT(Char(26), SYSDATETIME(), 121)
	select @ID_PROCESSO = @IN_IDORIGEM
	select @CONTADOR = 0

	If @IN_FULL = 'S'
		Begin

			declare curPagarPrev_## insensitive cursor for
			select		
				stamp_se2 as F7I_STAMP,
				LOWER(CONVERT(char(32), HashBytes('MD5',CONCAT(@IN_mdmTenantId,protheus_pk,E2_FILORIG)), 2))	as F7I_EXTCDH,
				E2_FILORIG								 														as E2_FILORIG,	
				E2_EMISSAO								 														as F7I_EMISSA,
				ISNULL(E2_EMIS1,@IS_SPACE)					 													as F7I_EMIS1,	
				ISNULL(E2_HIST,@IS_SPACE)					 													as F7I_HIST,
				E2_TIPO			          				 														as F7I_TIPO,	
				ISNULL(sx5_05_desc, @IS_SPACE)								 									as F7I_TIPDSC,
				E2_PREFIXO								 														as F7I_PREFIX,
				E2_NUM									 														as F7I_NUM,
				E2_PARCELA								 														as F7I_PARCEL,
				E2_MOEDA								 														as F7I_MOEDA,
				E2_VENCTO								 														as F7I_VENCTO,
				E2_VENCREA								 														as F7I_VENCRE,
				A2_FILIAL								 														as F7I_FLBENF,
				A2_COD									 														as F7I_CDBENF,
				A2_LOJA									 														as F7I_LJBENF,
				A2_NOME									 														as F7I_NBENEF,
				TRIM(E2_FORMPAG)						 														as F7I_MOVIM,
				ISNULL(sx5_58_desc,@IS_SPACE)			 														as F7I_DSCMOV,
				ISNULL(E2_BAIXA,@IS_SPACE)			 															as E2_BAIXA,
				E2_SALDO								 														as E2_SALDO,
				ABAT									 														as ABAT,
				E2_SDACRES								 														as E2_SDACRES,
				E2_SDDECRE								 														as E2_SDDECRE,
				E2_TIPO									 														as E2_TIPO,	
				ROUND(E2_VLCRUZ, 2)						 														as F7I_VLCRUZ,
				E2_VLCRUZ								 														as E2_VLCRUZ,
				E2_VALOR								 														as E2_VALOR,	
				CT1_CONTA								 														as CT1_CONTA,	
				ISNULL(SUBSTRING(CT1_DESC01,1,40),@IS_SPACE) 													as F7I_DSCCTB,
				ISNULL(CT1_NATCTA,@IS_SPACE)				 													as F7I_NATCTA,
				E2_CCUSTO								 														as E2_CCUSTO,
				ED_CCD									 														as ED_CCD,
				E2_NATUREZ								 														as F7I_NATURE,      
				se2_deleted								 														as se2_deleted,
				E2_CREDIT								 														as F7I_CREDIT,
				E2_DEBITO								 														as F7I_DEBITO,
				E2_CCD									 														as F7I_CCD,
				E2_CCC									 														as F7I_CCC,
				E2_ITEMCTA								 														as F7I_ITEMCT,
				E2_ITEMD								 														as F7I_ITEMD,
				E2_ITEMC								 														as F7I_ITEMC,
				E2_CLVL									 														as F7I_CLVL,
				E2_CLVLDB								 														as F7I_CLVLDB,
				E2_CLVLCR								 														as F7I_CLVLCR,
				E2_NUMBOR								 														as F7I_NUMBOR,
				E2_MOEDA								 														as E2_MOEDA,
				se2_recno 								 														as Se2Recno,
				E2_TXMOEDA 								 														as E2_TXMOEDA,
				FK7_FILIAL								 														as FK7_FILIAL,
				FK7_IDDOC								 														as FK7_IDDOC
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
				se2_principal.E2_SDACRES,
				se2_principal.E2_SDDECRE,
				se2_principal.E2_VLCRUZ,
				se2_principal.E2_VALOR,
				se2_principal.D_E_L_E_T_ as se2_deleted,
				se2_principal.R_E_C_N_O_ as se2_recno,
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
				se2_principal.S_T_A_M_P_ as stamp_se2,
				FK7.FK7_FILIAL,
				FK7.FK7_IDDOC,
				(SELECT MAX(sub_fk5.FK5_IDMOV)
					FROM FK5### sub_fk5
				WHERE sub_fk5.FK5_IDDOC = FK7.FK7_IDDOC
					AND sub_fk5.FK5_TPDOC = @IS_TPDOCPA
					AND sub_fk5.D_E_L_E_T_ = @IS_SPACE) AS fk5_idmov,
				(SELECT SUM(se2_abat.E2_VALOR)
					FROM SE2### se2_abat
					WHERE se2_abat.E2_FILIAL = se2_principal.E2_FILIAL
					AND se2_abat.E2_PREFIXO = se2_principal.E2_PREFIXO
					AND se2_abat.E2_NUM = se2_principal.E2_NUM
					AND se2_abat.E2_PARCELA = se2_principal.E2_PARCELA
					AND se2_abat.E2_FORNECE = se2_principal.E2_FORNECE
					AND se2_abat.E2_LOJA = se2_principal.E2_LOJA
					AND se2_abat.E2_TIPO LIKE @IS_TP_ABT
					AND se2_abat.D_E_L_E_T_ = @IS_SPACE) AS ABAT,
				sx5_05_consolidate.X5_FILIAL as sx5_05_filial,
				sx5_05_consolidate.X5_DESCRI as sx5_05_desc,
				sx5_58_consolidate.X5_FILIAL as sx5_58_filial,
				sx5_58_consolidate.X5_DESCRI as sx5_58_desc,
				sed.ED_CODIGO,
				sed.ED_FILIAL,
				sed.ED_CREDIT,
				sed.ED_DEBITO,
				sed.ED_CCD,
				ct1.CT1_CONTA,
				ct1.CT1_FILIAL,
				ct1.CT1_DESC01,
				ct1.CT1_NATCTA,
				sa2.A2_FILIAL,
				sa2.A2_COD,
				sa2.A2_LOJA,
				sa2.A2_NOME		
				,'#campoflex' as campoflex
			From SE2### se2_principal LEFT JOIN CT2### ON CT2_FILIAL = ' ' -- ct2 removido sempre pelo parser
				INNER JOIN FK7### FK7 LEFT JOIN CT2### ON CT2_FILIAL = ' ' 
					ON FK7.FK7_ALIAS = @IS_ALIAS
						AND FK7.FK7_FILTIT  = se2_principal.E2_FILIAL  
						AND FK7.FK7_PREFIX  = se2_principal.E2_PREFIXO 
						AND FK7.FK7_NUM     = se2_principal.E2_NUM 	 	
						AND FK7.FK7_PARCEL  = se2_principal.E2_PARCELA 
						AND FK7.FK7_TIPO    = se2_principal.E2_TIPO 	 	
						AND FK7.FK7_CLIFOR  = se2_principal.E2_FORNECE 
						AND FK7.FK7_LOJA    = se2_principal.E2_LOJA 	 							
						AND FK7.D_E_L_E_T_ 	= @IS_SPACE
				LEFT JOIN SX5### sx5_05_consolidate
					ON sx5_05_consolidate.X5_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSX5) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSX5)
						AND sx5_05_consolidate.X5_TABELA = @IS_X5TAB05
						AND sx5_05_consolidate.X5_CHAVE = se2_principal.E2_TIPO
						AND sx5_05_consolidate.D_E_L_E_T_ = @IS_SPACE
				LEFT JOIN SX5### sx5_58_consolidate
					ON sx5_58_consolidate.X5_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSX5) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSX5)
						AND sx5_58_consolidate.X5_TABELA = @IS_X5TAB58
						AND trim(sx5_58_consolidate.X5_CHAVE) = trim(se2_principal.E2_FORMPAG)
						AND sx5_58_consolidate.D_E_L_E_T_ = @IS_SPACE		
				INNER JOIN SED### sed
					ON	sed.ED_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSED) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSED)
						and sed.ED_CODIGO = se2_principal.E2_NATUREZ
						and sed.D_E_L_E_T_ = @IS_SPACE
				LEFT JOIN CT1### ct1
					ON	ct1.CT1_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMCT1) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMCT1)
						and ct1.CT1_CONTA = sed.ED_DEBITO
						and ct1.D_E_L_E_T_ = @IS_SPACE
				INNER JOIN SA2### sa2
					On sa2.A2_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSA2) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSA2)
						And sa2.A2_COD = se2_principal.E2_FORNECE
						And sa2.A2_LOJA = se2_principal.E2_LOJA
						And sa2.D_E_L_E_T_ = @IS_SPACE
				WHERE se2_principal.E2_MULTNAT in (@IS_SEMRAT,@IS_SPACE)
					AND (
							(se2_principal.E2_EMIS1 >= @param_DTINI AND se2_principal.E2_EMIS1 <= @param_DTFIM)
							OR (se2_principal.E2_BAIXA >= @param_DTINI AND se2_principal.E2_BAIXA <= @param_DTFIM)
						)
					AND (
							(se2_principal.E2_EMIS1 < @param_DTCORTE AND se2_principal.E2_SALDO > 0)
							OR se2_principal.E2_EMIS1 >= @param_DTCORTE
					)
					AND se2_principal.E2_TIPO not like @IS_TP_ABT
					AND se2_principal.D_E_L_E_T_ = @IS_SPACE ) PagarPrevisto
					WHERE PagarPrevisto.fk5_idmov is null --considera somente os registros que não possuem movimentação financeira gerada

			for read only

			open curPagarPrev_##
				fetch next from curPagarPrev_##			
					into @F7I_STAMP,
						@F7I_EXTCDH,
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
						@E2_SDACRES,
						@E2_SDDECRE,
						@E2_TIPO,
						@F7I_VLCRUZ,				 
						@E2_VLCRUZ,
						@E2_VALOR,
						@CT1_CONTA,
						@F7I_DSCCTB,
						@F7I_NATCTA,
						@E2_CCUSTO,
						@ED_CCD,
						@F7I_NATURE,
						@se2_deleted,
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
						@E2_MOEDA,
						@Se2Recno,
						@E2_TXMOEDA,
						@FK7_FILIAL,
						@FK7_IDDOC
						--#cursorflex

				While ( (@@fetch_Status  = 0 ) )			
				Begin
					select @F7I_NATRAT = @IS_SPACE
					select @F7I_CCDRAT = @IS_SPACE
					select @F7I_IDMOV  = @IS_SPACE
					select @F7I_PAMOV  = @IS_SPACE
					select @F7I_CONVBS = 0
					select @F7I_CONVCT = 0

					If @F7I_MOEDA <> 0 AND ( @F7I_MOEDA <> @MOEDA )
						Begin
							select @MOEDA = @F7I_MOEDA
							select @F7I_DSCMDA = (SELECT DSCMDA.X6_CONTEUD
														FROM SX6### DSCMDA
														WHERE RTRIM(DSCMDA.X6_VAR) = @IS_MVMOEDA || RTRIM(CAST(@MOEDA AS CHAR(2)))
														AND DSCMDA.D_E_L_E_T_ = @IS_SPACE )
						End
		
					If ( @F7I_STAMP is null )
						Begin 
							If ( @F7I_EMIS1 = @IS_SPACE )
								Begin
									If ( @E2_BAIXA = @IS_SPACE )
										Begin
											Select @cF7I_STAMP = @IS_SPACE
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
					
					select @F7I_EXTCDD  = @F7I_EXTCDH			
					
					If (@F7I_HIST = @IS_SPACE)
						Begin
							select @F7I_HIST = 'SEM DESCRICAO'
						End
					
					Select @F7I_SALDO = ROUND((@E2_SALDO + @E2_SDACRES - @E2_SDDECRE - IsNull(@ABAT,0)), 2)
					Select @F7I_VLPROP = @F7I_SALDO
					If @F7I_SALDO < 0 
						Begin
							Select @F7I_SALDO = 0
							Select @F7I_VLPROP = 0
						End
					
					If (trim(@E2_TIPO) = 'NDF')
						Begin 
							select @F7I_SALDO = @F7I_SALDO * -1
							select @F7I_VLPROP = @F7I_VLPROP * -1
							select @F7I_VLCRUZ = @F7I_VLCRUZ * -1
						End
				
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
					
					exec XFILIAL_## 'CTT', @E2_FILORIG, @filialCTT OutPut

					If ((@E2_CCUSTO IS NULL) OR @E2_CCUSTO = @IS_SPACE)
						Begin
							SELECT @F7I_CCUSTO = @ED_CCD
							SELECT @F7I_DSCCCT = @IS_SPACE
							IF @ED_CCD <> @IS_SPACE
								Begin
									SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @ED_CCD AND D_E_L_E_T_ = @IS_SPACE)
								End
						End
					Else
						Begin 
							SELECT @F7I_CCUSTO = @E2_CCUSTO
							SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @E2_CCUSTO AND D_E_L_E_T_ = @IS_SPACE)
						End
					
					If ( (@CT1_CONTA is null) or (@CT1_CONTA = @IS_SPACE) )
						Begin
							select @F7I_CNTCTB = '0'
						End
					Else
						Begin 
							select @F7I_CNTCTB = @CT1_CONTA
						End
					
					If ( Trim(@se2_deleted) = '*' Or @E2_SALDO = 0 )
						Begin
							select @F7I_INTEGR = 'E'					
						End
					Else
						Begin 
							select @F7I_INTEGR = @IS_SPACE
						End
					
					If @F7I_TIPO = 'PA'
						Begin
							select @F7I_PAMOV = 'S'
							select @F7I_IDMOV = (SELECT FK5_IDMOV FROM FK5### FK5 WHERE FK5.FK5_IDDOC = @FK7_IDDOC 
														AND 'X' = '##PAMOV##' AND FK5.D_E_L_E_T_ = @IS_SPACE)
							If  @F7I_IDMOV <> @IS_SPACE
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
					SELECT @param_COD_FIL = SUBSTRING(@E2_FILORIG, @IN_TAMEMP + 1 + @IN_TAMUNIT, @IN_TAMFIL)
					
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
								F7I_IDMOV,
								F7I_IDPROC
								--#insertflex						
							) Values (
								@cF7I_STAMP,
								@F7I_EXTCDH,
								@F7I_EXTCDD,
								IsNull(@IN_GROUPEMPRESA,@IS_SPACE),
								IsNull(@param_COMPANIA,@IS_SPACE),
								IsNull(@param_COD_UNID,@IS_SPACE),
								IsNull(@param_COD_FIL,@IS_SPACE),
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
								SUBSTRING(IsNull(@F7I_DSCMDA, @IS_SPACE),1,10),
								@F7I_VENCTO,
								@F7I_VENCRE,
								'S',--@F7I_TPEVNT,				 
								IsNull(@F7I_FLBENF, @IS_SPACE),
								IsNull(@F7I_CDBENF, @IS_SPACE),
								IsNull(@F7I_LJBENF, @IS_SPACE),
								IsNull(SUBSTRING(@F7I_NBENEF,1,50), @IS_SPACE),
								'3',--@F7I_TPBENF,
								'CP',--@F7I_ORBENF,
								IsNull(@F7I_MOVIM,@IS_SPACE),
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
								IsNull(@F7I_DSCCTB,@IS_SPACE),
								@F7I_NATCTA,
								@F7I_CCUSTO,
								IsNull(SUBSTRING(@F7I_DSCCCT,1,40),@IS_SPACE),
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
								@F7I_IDMOV,
								@ID_PROCESSO
								--#variaveisflex
							)
					##CHECK_TRANSACTION_COMMIT			
						
					INSERT INTO F7J###  (
						F7J_FILIAL,
						F7J_ALIAS,
						F7J_RECNO,
						F7J_STAMP
					) VALUES(
						@IS_SPACE,
						@IS_ALIAS_CPP,
						@Se2Recno , 
						@cF7J_STAMP
					)

					SELECT @CONTADOR = @CONTADOR + 1

					fetch next from curPagarPrev_##			
						into @F7I_STAMP,
							@F7I_EXTCDH,
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
							@E2_SDACRES,
							@E2_SDDECRE,
							@E2_TIPO,
							@F7I_VLCRUZ,				 
							@E2_VLCRUZ,
							@E2_VALOR,
							@CT1_CONTA,
							@F7I_DSCCTB,
							@F7I_NATCTA,
							@E2_CCUSTO,
							@ED_CCD,
							@F7I_NATURE,
							@se2_deleted,
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
							@E2_MOEDA,
							@Se2Recno,
							@E2_TXMOEDA,
							@FK7_FILIAL,
							@FK7_IDDOC
							--#cursorflex
		
				End	 				
				close curPagarPrev_##
				deallocate curPagarPrev_##
	End
	Else
		Begin 
			declare curPagarPrev_delta_## insensitive cursor for
			select		
				stamp_se2																				        		as F7I_STAMP,
				LOWER(CONVERT(char(32), HashBytes('MD5',CONCAT(@IN_mdmTenantId,protheus_pk,E2_FILORIG)), 2))			as F7I_EXTCDH,
				E2_FILORIG																								as E2_FILORIG,	
				E2_EMISSAO																								as F7I_EMISSA,
				ISNULL(E2_EMIS1,@IS_SPACE)																				as F7I_EMIS1,	
				ISNULL(E2_HIST,@IS_SPACE)																				as F7I_HIST,
				E2_TIPO			          																				as F7I_TIPO,	
				ISNULL(sx5_05_desc, @IS_SPACE)																			as F7I_TIPDSC,
				E2_PREFIXO																								as F7I_PREFIX,
				E2_NUM																									as F7I_NUM,
				E2_PARCELA																								as F7I_PARCEL,
				E2_MOEDA																								as F7I_MOEDA,
				E2_VENCTO																								as F7I_VENCTO,
				E2_VENCREA																								as F7I_VENCRE,
				A2_FILIAL																								as F7I_FLBENF,
				A2_COD																									as F7I_CDBENF,
				A2_LOJA																									as F7I_LJBENF,
				A2_NOME																									as F7I_NBENEF,
				TRIM(E2_FORMPAG)																						as F7I_MOVIM,
				ISNULL(sx5_58_desc,@IS_SPACE)																			as F7I_DSCMOV,
				ISNULL(E2_BAIXA,@IS_SPACE)																				as E2_BAIXA,
				E2_SALDO																								as E2_SALDO,
				ABAT																									as ABAT,
				E2_SDACRES																								as E2_SDACRES,
				E2_SDDECRE																								as E2_SDDECRE,
				E2_TIPO																									as E2_TIPO,	
				ROUND(E2_VLCRUZ, 2)																						as F7I_VLCRUZ,
				E2_VLCRUZ																								as E2_VLCRUZ,
				E2_VALOR																								as E2_VALOR,	
				CT1_CONTA																								as CT1_CONTA,	
				ISNULL(SUBSTRING(CT1_DESC01,1,40),@IS_SPACE)															as F7I_DSCCTB,
				ISNULL(CT1_NATCTA,@IS_SPACE)																			as F7I_NATCTA,
				E2_CCUSTO																								as E2_CCUSTO,
				ED_CCD																									as ED_CCD,
				E2_NATUREZ																								as F7I_NATURE,      
				se2_deleted																								as se2_deleted,
				E2_CREDIT																								as F7I_CREDIT,
				E2_DEBITO																								as F7I_DEBITO,
				E2_CCD																									as F7I_CCD,
				E2_CCC																									as F7I_CCC,
				E2_ITEMCTA																								as F7I_ITEMCT,
				E2_ITEMD																								as F7I_ITEMD,
				E2_ITEMC																								as F7I_ITEMC,
				E2_CLVL																									as F7I_CLVL,
				E2_CLVLDB																								as F7I_CLVLDB,
				E2_CLVLCR																								as F7I_CLVLCR,
				E2_NUMBOR																								as F7I_NUMBOR,
				FK5_VALOR																								as FK5_VALOR,
				FK5_TXMOED																								as FK5_TXMOED,
				FK5_MOEDA																								as FK5_MOEDA,
				E2_MOEDA																								as E2_MOEDA,
				se2_recno 																								as Se2Recno,
				E2_TXMOEDA 																								as E2_TXMOEDA,
				FK7_IDDOC																								as FK7_IDDOC
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
				se2_principal.E2_SDACRES,
				se2_principal.E2_SDDECRE,
				se2_principal.E2_VLCRUZ,
				se2_principal.E2_VALOR,
				se2_principal.D_E_L_E_T_ as se2_deleted,
				se2_principal.R_E_C_N_O_ as se2_recno,
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
				se2_principal.S_T_A_M_P_ as stamp_se2,
				(SELECT SUM(se2_abat.E2_VALOR)
					FROM SE2### se2_abat
					WHERE se2_abat.E2_FILIAL = se2_principal.E2_FILIAL
					AND se2_abat.E2_PREFIXO = se2_principal.E2_PREFIXO
					AND se2_abat.E2_NUM = se2_principal.E2_NUM
					AND se2_abat.E2_PARCELA = se2_principal.E2_PARCELA
					AND se2_abat.E2_FORNECE = se2_principal.E2_FORNECE
					AND se2_abat.E2_LOJA = se2_principal.E2_LOJA
					AND se2_abat.E2_TIPO LIKE @IS_TP_ABT
					AND se2_abat.D_E_L_E_T_ = @IS_SPACE) AS ABAT,
				sx5_05_consolidate.X5_FILIAL as sx5_05_filial,
				sx5_05_consolidate.X5_DESCRI as sx5_05_desc,
				sx5_58_consolidate.X5_FILIAL as sx5_58_filial,
				sx5_58_consolidate.X5_DESCRI as sx5_58_desc,
				FK7.FK7_FILTIT,
				FK7.FK7_PREFIX,
				FK7.FK7_NUM,
				FK7.FK7_PARCEL,
				FK7.FK7_TIPO,
				FK7.FK7_CLIFOR,
				FK7.FK7_LOJA,
				FK7.FK7_FILIAL,
				FK7.FK7_ALIAS,
				FK7.FK7_IDDOC,
				FK5.FK5_FILIAL,
				FK5.FK5_FILORI,
				FK5.FK5_IDDOC,
				FK5.FK5_DATA,
				FK5.FK5_LOTE,
				FK5.FK5_TPDOC,
				FK5.FK5_VALOR,
				FK5.FK5_RECPAG,
				FK5.FK5_SEQ,
				FK5.FK5_CONTA,
				FK5.FK5_AGENCI,
				FK5.FK5_BANCO,
				FK5.FK5_VLMOE2,
				FK5.FK5_TXMOED,
				FK5.FK5_MOEDA,
				sed.ED_CODIGO,
				sed.ED_FILIAL,
				sed.ED_CREDIT,
				sed.ED_DEBITO,
				sed.ED_CCD,
				ct1.CT1_CONTA,
				ct1.CT1_FILIAL,
				ct1.CT1_DESC01,
				ct1.CT1_NATCTA,		
				sa2.A2_FILIAL,
				sa2.A2_COD,
				sa2.A2_LOJA,
				sa2.A2_NOME
				,'#campoflex' as campoflex
			From SE2### se2_principal LEFT JOIN CT2### ON CT2_FILIAL = ' '
				INNER JOIN FK7### FK7 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
					ON FK7.FK7_ALIAS = @IS_ALIAS
						AND FK7.FK7_FILTIT  = se2_principal.E2_FILIAL
						AND FK7.FK7_PREFIX  = se2_principal.E2_PREFIXO
						AND FK7.FK7_NUM  	= se2_principal.E2_NUM
						AND FK7.FK7_PARCEL  = se2_principal.E2_PARCELA
						AND FK7.FK7_TIPO  	= se2_principal.E2_TIPO
						AND FK7.FK7_CLIFOR  = se2_principal.E2_FORNECE
						AND FK7.FK7_LOJA  	= se2_principal.E2_LOJA
						AND FK7.D_E_L_E_T_ 	= se2_principal.D_E_L_E_T_
				LEFT JOIN SX5### sx5_05_consolidate
					ON sx5_05_consolidate.X5_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSX5) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSX5)
						AND sx5_05_consolidate.X5_TABELA = @IS_X5TAB05
						AND sx5_05_consolidate.X5_CHAVE = se2_principal.E2_TIPO
						AND sx5_05_consolidate.D_E_L_E_T_ = @IS_SPACE
				LEFT JOIN SX5### sx5_58_consolidate
					ON sx5_58_consolidate.X5_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSX5) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSX5)
						AND sx5_58_consolidate.X5_TABELA = @IS_X5TAB58
						AND trim(sx5_58_consolidate.X5_CHAVE) = trim(se2_principal.E2_FORMPAG)
						AND sx5_58_consolidate.D_E_L_E_T_ = @IS_SPACE
				LEFT JOIN FK5### FK5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
					ON	FK5.FK5_IDDOC = FK7.FK7_IDDOC
						AND FK5.FK5_TPDOC = @IS_TPDOCPA
				INNER JOIN SED### sed
					ON	sed.ED_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSED) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSED)
						AND sed.ED_CODIGO = se2_principal.E2_NATUREZ
						AND sed.D_E_L_E_T_ = @IS_SPACE
				LEFT JOIN CT1### ct1
					ON	ct1.CT1_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMCT1) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMCT1)
						AND ct1.CT1_CONTA = sed.ED_DEBITO
						AND ct1.D_E_L_E_T_ = @IS_SPACE
				INNER JOIN SA2### sa2
					On sa2.A2_FILIAL = SUBSTRING(se2_principal.E2_FILORIG,1,@IN_TAMSA2) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSA2)
						AND sa2.A2_COD = se2_principal.E2_FORNECE
						AND sa2.A2_LOJA = se2_principal.E2_LOJA
						AND sa2.D_E_L_E_T_ = @IS_SPACE
				LEFT JOIN F7J### f7j
				ON f7j.F7J_ALIAS = @IS_ALIAS_CPP
						AND f7j.F7J_STAMP = CONVERT(CHAR(26), se2_principal.S_T_A_M_P_, 121)
					AND f7j.F7J_RECNO = se2_principal.R_E_C_N_O_
			Where se2_principal.S_T_A_M_P_ > @maxStagingCounter
				AND se2_principal.E2_MULTNAT in (@IS_SEMRAT,@IS_SPACE)
				AND se2_principal.E2_TIPO not like @IS_TP_ABT
				AND f7j.F7J_RECNO is null
			) PagarPrevisto

			for read only

			open curPagarPrev_delta_##
				fetch next from curPagarPrev_delta_##			
					into @F7I_STAMP,
						@F7I_EXTCDH,
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
						@E2_SDACRES,
						@E2_SDDECRE,
						@E2_TIPO,
						@F7I_VLCRUZ,				 
						@E2_VLCRUZ,
						@E2_VALOR,
						@CT1_CONTA,
						@F7I_DSCCTB,
						@F7I_NATCTA,
						@E2_CCUSTO,
						@ED_CCD,
						@F7I_NATURE,
						@se2_deleted,
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
						@FK5_VALOR,	
						@FK5_TXMOED,	
						@FK5_MOEDA,	
						@E2_MOEDA,
						@Se2Recno,
						@E2_TXMOEDA,
						@FK7_IDDOC
						--#cursorflex

				While ( (@@fetch_Status  = 0 ) )			
				Begin
					select @F7I_NATRAT = @IS_SPACE
					select @F7I_CCDRAT = @IS_SPACE
					select @F7I_PAMOV  = @IS_SPACE
					select @F7I_IDMOV  = @IS_SPACE
					select @F7I_CONVBS = 0
					select @F7I_CONVCT = 0

					If @F7I_MOEDA <> 0 AND ( @F7I_MOEDA <> @MOEDA )
						Begin
							select @MOEDA = @F7I_MOEDA
							select @F7I_DSCMDA = (SELECT DSCMDA.X6_CONTEUD
														FROM SX6### DSCMDA
														WHERE RTRIM(DSCMDA.X6_VAR) = @IS_MVMOEDA || RTRIM(CAST(@MOEDA AS CHAR(2)))
														AND DSCMDA.D_E_L_E_T_ = @IS_SPACE )
						End
		
					If ( @F7I_STAMP is null )
						Begin 
							If ( @F7I_EMIS1 = @IS_SPACE )
								Begin
									If ( @E2_BAIXA = @IS_SPACE )
										Begin
											Select @cF7I_STAMP = @IS_SPACE
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
					
					select @F7I_EXTCDD  = @F7I_EXTCDH			
					
					If (@F7I_HIST = @IS_SPACE)
						Begin
							select @F7I_HIST = 'SEM DESCRICAO'
						End

					Select @F7I_SALDO = ROUND((@E2_SALDO + @E2_SDACRES - @E2_SDDECRE - IsNull(@ABAT,0)), 2)
					Select @F7I_VLPROP = @F7I_SALDO
					If @F7I_SALDO < 0 
						Begin
							Select @F7I_SALDO = 0
							Select @F7I_VLPROP = 0
						End

					If (trim(@E2_TIPO) = 'NDF')
						Begin 
							select @F7I_SALDO = @F7I_SALDO * -1
							select @F7I_VLPROP = @F7I_VLPROP * -1
							select @F7I_VLCRUZ = @F7I_VLCRUZ * -1
						End
				
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
					
					exec XFILIAL_## 'CTT', @E2_FILORIG, @filialCTT OutPut

					If ((@E2_CCUSTO IS NULL) OR @E2_CCUSTO = @IS_SPACE)
						Begin
							SELECT @F7I_CCUSTO = @ED_CCD
							SELECT @F7I_DSCCCT = @IS_SPACE
							IF @ED_CCD <> @IS_SPACE
								Begin
									SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @ED_CCD AND D_E_L_E_T_ = @IS_SPACE)
								End
						End
					Else
						Begin 
							SELECT @F7I_CCUSTO = @E2_CCUSTO
							SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @E2_CCUSTO AND D_E_L_E_T_ = @IS_SPACE)
						End
				
					If ( (@CT1_CONTA is null) or (@CT1_CONTA = @IS_SPACE) )
						Begin
							select @F7I_CNTCTB = '0'
						End
					Else
						Begin 
							select @F7I_CNTCTB = @CT1_CONTA
						End
					
					If ( Trim(@se2_deleted) = '*' Or @E2_SALDO = 0 )
						Begin
							select @F7I_INTEGR = 'E'					
						End
					Else
						Begin 
							select @F7I_INTEGR = @IS_SPACE
						End
					
					If @F7I_TIPO = 'PA'
						Begin
							select @F7I_PAMOV = 'S'
							select @F7I_IDMOV = (SELECT FK5_IDMOV FROM FK5### FK5 WHERE FK5.FK5_IDDOC = @FK7_IDDOC 
																AND 'X' = '##PAMOV##' AND FK5.D_E_L_E_T_ = @IS_SPACE)
							If @F7I_IDMOV <> @IS_SPACE
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
					SELECT @param_COD_FIL = SUBSTRING(@E2_FILORIG, @IN_TAMEMP + 1 + @IN_TAMUNIT, @IN_TAMFIL)
					
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
								F7I_IDMOV,
								F7I_IDPROC	
								--#insertflex						
							) Values (
								@cF7I_STAMP,
								@F7I_EXTCDH,
								@F7I_EXTCDD,
								IsNull(@IN_GROUPEMPRESA,@IS_SPACE),
								IsNull(@param_COMPANIA,@IS_SPACE),
								IsNull(@param_COD_UNID,@IS_SPACE),
								IsNull(@param_COD_FIL,@IS_SPACE),
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
								SUBSTRING(IsNull(@F7I_DSCMDA, @IS_SPACE),1,10),
								@F7I_VENCTO,
								@F7I_VENCRE,
								'S',--@F7I_TPEVNT,				 
								IsNull(@F7I_FLBENF, @IS_SPACE),
								IsNull(@F7I_CDBENF, @IS_SPACE),
								IsNull(@F7I_LJBENF, @IS_SPACE),
								IsNull(SUBSTRING(@F7I_NBENEF,1,50), @IS_SPACE),
								'3',--@F7I_TPBENF,
								'CP',--@F7I_ORBENF,
								IsNull(@F7I_MOVIM,@IS_SPACE),
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
								IsNull(@F7I_DSCCTB,@IS_SPACE),
								@F7I_NATCTA,
								@F7I_CCUSTO,
								IsNull(SUBSTRING(@F7I_DSCCCT,1,40),@IS_SPACE),
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
								IsNull(@F7I_IDMOV, @IS_SPACE),
								@ID_PROCESSO
								--#variaveisflex
							)
					##CHECK_TRANSACTION_COMMIT			
						
					INSERT INTO F7J###  (
						F7J_FILIAL,
						F7J_ALIAS,
						F7J_RECNO,
						F7J_STAMP
					) VALUES(
						@IS_SPACE,
						@IS_ALIAS_CPP,
						@Se2Recno , 
						@cF7J_STAMP
					)

					SELECT @CONTADOR = @CONTADOR + 1

					fetch next from curPagarPrev_delta_##			
						into @F7I_STAMP,
							@F7I_EXTCDH,
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
							@E2_SDACRES,
							@E2_SDDECRE,
							@E2_TIPO,
							@F7I_VLCRUZ,				 
							@E2_VLCRUZ,
							@E2_VALOR,
							@CT1_CONTA,
							@F7I_DSCCTB,
							@F7I_NATCTA,
							@E2_CCUSTO,
							@ED_CCD,
							@F7I_NATURE,
							@se2_deleted,
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
							@FK5_VALOR,	
							@FK5_TXMOED,	
							@FK5_MOEDA,	
							@E2_MOEDA,
							@Se2Recno,
							@E2_TXMOEDA,
							@FK7_IDDOC
							--#cursorflex
		
				End	 				
				close curPagarPrev_delta_##
				deallocate curPagarPrev_delta_##
				
		End
		
		Begin
			INSERT INTO F7P### (F7P_IDPROC, F7P_INICIO, F7P_FIM, F7P_QTDE, F7P_PROCES, F7P_LOTE) 
			VALUES (@ID_PROCESSO, @DATA_INICIO, CONVERT(Char(26), SYSDATETIME(), 121), @CONTADOR, @IS_FIN007A, @IN_LOTEPROC)
		End
	
	select @OUT_RESULTADO = '1'
	
End