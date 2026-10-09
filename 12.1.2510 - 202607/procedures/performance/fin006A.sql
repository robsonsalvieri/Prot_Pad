-- =============================================
-- Author:		Luiz Gustavo Romeiro de Jesus
-- Create date: 05/02/2025
-- Description:	Geracao dos titulos a receber previsto
-- =============================================

CREATE PROCEDURE FIN006A_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
	@IN_TAMSED  Integer,
	@IN_TAMCT1  Integer,
	@IN_TAMSX5  Integer,
	@IN_TAMSA1  Integer,
	@IN_TAMFRV  Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
    @IN_COMPANIA char('##COMPANIA'),
    @IN_COD_UNID char('##COD_UNID'),
    @IN_COD_FIL char('##COD_FIL'),
	@IN_mdmTenantId char(32),
	@IN_DTINI char('F7I_EMIS1'),
	@IN_DTFIM char('F7I_EMIS1'),
    @IN_FULL char(1),
	@IN_CARTEIRAD char(1),
	@IN_TRANSACTION  Char(1),
	@DecCONVBS integer,
	@IN_maxStagingCounter Datetime,
	@IN_delTransactTime char(25),
	@IN_IDORIGEM char(32),
	@IN_LOTEPROC Char(6),
	@IN_DTCORTE char('F7I_EMIS1'),
	@OUT_RESULTADO Char(1) OutPut
) AS

	--Declaracao de variaveis
	declare @N_TAMTOTAL Integer	
	declare @filial    char('E1_FILORIG')
	declare @filialCTT char('CTT_FILIAL')
	declare @param_DTINI char('F7I_EMIS1')
	declare @param_DTFIM char('F7I_EMIS1')
	declare @param_DTCORTE char('F7I_EMIS1')

	declare @param_COMPANIA char('##COMPANIA')
    declare @param_COD_UNID char('##COD_UNID')
    declare @param_COD_FIL char('##COD_FIL')

	-- Variaveis gravacao
	declare @F7I_STAMP	Datetime
	declare @F7I_EXTCDH char('F7I_EXTCDH')
	declare @F7I_EXTCDD char('F7I_EXTCDD')
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
	declare @E1_SDACRES float
	declare @E1_SDDECRE float
	declare @E1_SALDO   float
	declare @E1_VALOR   float
	declare @FRV_DESCON char('FRV_DESCON')
	declare @CT1_CONTA  char('CT1_CONTA')
	declare @ED_CCC 	char('ED_CCC')
	declare @E1_CCUSTO 	char('E1_CCUSTO')
	declare @ABAT		float
	declare @se1_Deleted char(1)
	declare @E1_TXMOEDA float
	declare @MOEDA Integer
	declare @IS_MVMOEDA VARCHAR(10)

	declare @maxStagingCounter Datetime 
	declare @cF7I_STAMP char('F7I_STAMP')
	declare @cF7J_STAMP char('F7J_STAMP')
	declare @delTransactTime char('F7J_STAMP')
	declare @IS_SPACE char(1)
	declare @IS_X5TAB char(2)
	declare @IS_SEMRAT char(1)
	declare @IS_TP_RA char("E1_TIPO")
	declare @IS_TP_ABAT char("E1_TIPO")
	declare @IS_TP_ABT char(2)
	declare @F7J_ALIAS char("F7J_ALIAS")
	declare @IS_FIN006A char(7)
	declare @ID_PROCESSO char(32)
	declare @DATA_INICIO char(26)
	declare @CONTADOR Integer 
	declare flex char(1)

BEGIN	
	select @N_TAMTOTAL = @IN_TAMEMP + @IN_TAMUNIT +	@IN_TAMFIL
	select @maxStagingCounter = @IN_maxStagingCounter
	select @delTransactTime  = @IN_delTransactTime 
	select @param_DTINI = @IN_DTINI
	select @param_DTFIM = @IN_DTFIM
	select @param_DTCORTE = @IN_DTCORTE
	select @param_COMPANIA = @IN_COMPANIA
    select @param_COD_UNID = @IN_COD_UNID
    select @param_COD_FIL = @IN_COD_FIL
	select @IS_SPACE   = ' '
	select @F7I_EMIS1  = @IS_SPACE
	select @IS_X5TAB   = '05'
	select @IS_SEMRAT  = '2'  -- Sem rateio
	select @IS_TP_RA   = 'RA '
	select @IS_TP_ABAT = 'AB-'
	select @IS_TP_ABT  = '%-'
	select @F7J_ALIAS  = 'CRP'
	select @IS_MVMOEDA = 'MV_MOEDA'
	select @MOEDA  = 0
	select @IS_FIN006A = 'FIN006A'
	select @DATA_INICIO = CONVERT(Char(26), SYSDATETIME(), 121)
	select @ID_PROCESSO = @IN_IDORIGEM
	select @CONTADOR = 0 

	If @IN_FULL = 'S'
		BEGIN 
			--FULL
			declare curReceber_sem_Rateio_full_## insensitive cursor for

			SELECT '##CTE_SE1_ABATIMENTOS##',
				se1.S_T_A_M_P_ 												AS F7I_STAMP,
				'##HASH_MD5_PK##' 											AS F7I_EXTCDH,
				se1.E1_EMISSAO                    							AS F7I_EMISSA,
				se1.E1_EMIS1                      							AS F7I_EMIS1,
				COALESCE(se1.E1_HIST, @IS_SPACE)  							AS F7I_HIST,
				se1.E1_TIPO                       							AS F7I_TIPO,
				ISNULL(sx5_consolidate.X5_DESCRI, @IS_SPACE)  				AS F7I_TIPDSC,
				se1.E1_PREFIXO                    							AS F7I_PREFIX,
				se1.E1_NUM                        							AS F7I_NUM,
				se1.E1_PARCELA                    							AS F7I_PARCEL,
				se1.E1_MOEDA                      							AS F7I_MOEDA,
				se1.E1_VENCTO                     							AS F7I_VENCTO,
				se1.E1_VENCREA                    							AS F7I_VENCRE,
				TRIM(se1.E1_PORTADO)              							AS E1_PORTADO,
				TRIM(se1.E1_CONTA)                							AS E1_CONTA,
				TRIM(se1.E1_AGEDEP)               							AS E1_AGEDEP,
				COALESCE(sa1.A1_FILIAL, @IS_SPACE)  						AS F7I_FLBENF,
				COALESCE(sa1.A1_COD,    @IS_SPACE)  						AS F7I_CDBENF,
				COALESCE(sa1.A1_LOJA,   @IS_SPACE)  						AS F7I_LJBENF,
				COALESCE(sa1.A1_NOME,   @IS_SPACE)  						AS F7I_NBENEF,
				se1.E1_SITUACA                    							AS F7I_MOVIM,
				COALESCE(frv.FRV_DESCRI, @IS_SPACE) 						AS F7I_DSCMOV,
				COALESCE(frv.FRV_DESCON, @IS_SPACE) 						AS FRV_DESCON,
				se1.E1_BAIXA                      							AS E1_BAIXA,
				se1.E1_SALDO                      							AS E1_SALDO,
				COALESCE(se1_abatimentos.ABAT, 0)   						AS ABAT,
				se1.E1_SDACRES                     							AS E1_SDACRES,
				se1.E1_SDDECRE                    							AS E1_SDDECRE,
				se1.D_E_L_E_T_                    							AS se1_Deleted,
				ROUND(se1.E1_VLCRUZ, 2)             						AS F7I_VLCRUZ,
				se1.E1_VALOR                      							AS E1_VALOR,
				COALESCE(ct1.CT1_CONTA,  @IS_SPACE) 						AS CT1_CONTA,
				COALESCE(ct1.CT1_DESC01, @IS_SPACE) 						AS F7I_DSCCTB,
				COALESCE(ct1.CT1_NATCTA, @IS_SPACE) 						AS F7I_NATCTA,
				COALESCE(sed.ED_CCC,     @IS_SPACE) 						AS ED_CCC,
				COALESCE(se1.E1_CCUSTO, @IS_SPACE)  						AS E1_CCUSTO,
				se1.E1_NATUREZ                    							AS F7I_NATURE,
				se1.E1_CREDIT                     							AS F7I_CREDIT,
				se1.E1_DEBITO                     							AS F7I_DEBITO,
				se1.E1_CCD                        							AS F7I_CCD,
				se1.E1_CCC                        							AS F7I_CCC,
				se1.E1_ITEMCTA                    							AS F7I_ITEMCT,
				se1.E1_ITEMD                      							AS F7I_ITEMD,
				se1.E1_ITEMC                      							AS F7I_ITEMC,
				se1.E1_CLVL                       							AS F7I_CLVL,
				se1.E1_CLVLDB                     							AS F7I_CLVLDB,
				se1.E1_CLVLCR                     							AS F7I_CLVLCR,
				se1.E1_NUMBOR                     							AS F7I_NUMBOR,
				se1.R_E_C_N_O_                    							AS Se1Recno,
				se1.E1_FILORIG                    							AS filial,
				se1.E1_TXMOEDA                    							AS E1_TXMOEDA
				,'#campoflex' as campoflex
			FROM SE1### se1 LEFT JOIN CT2### ON CT2_FILIAL = ' '
			LEFT JOIN se1_abatimentos
				ON se1.E1_FILIAL  = se1_abatimentos.E1_FILIAL
					AND se1.E1_PREFIXO = se1_abatimentos.E1_PREFIXO
					AND se1.E1_NUM     = se1_abatimentos.E1_NUM
					AND se1.E1_PARCELA = se1_abatimentos.E1_PARCELA
					AND se1.E1_CLIENTE = se1_abatimentos.E1_CLIENTE
					AND se1.E1_LOJA    = se1_abatimentos.E1_LOJA
			INNER JOIN SED### sed
				ON sed.ED_FILIAL = SUBSTRING(se1.E1_FILORIG, 1, @IN_TAMSED) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSED)
					AND sed.ED_CODIGO = se1.E1_NATUREZ
					AND sed.D_E_L_E_T_ = @IS_SPACE
			INNER JOIN SA1### sa1
				ON sa1.A1_FILIAL = SUBSTRING(se1.E1_FILORIG, 1, @IN_TAMSA1) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSA1)
				AND sa1.A1_COD  = se1.E1_CLIENTE
				AND sa1.A1_LOJA = se1.E1_LOJA
				AND sa1.D_E_L_E_T_ = @IS_SPACE
			LEFT JOIN SX5### sx5_consolidate
				ON sx5_consolidate.X5_FILIAL = SUBSTRING (se1.E1_FILORIG, 1, @IN_TAMSX5) || REPLICATE (@IS_SPACE, @N_TAMTOTAL - @IN_TAMSX5)
					AND sx5_consolidate.X5_TABELA = @IS_X5TAB
					AND sx5_consolidate.X5_CHAVE = se1.E1_TIPO
					AND sx5_consolidate.D_E_L_E_T_ = @IS_SPACE
			LEFT JOIN CT1### ct1
				ON ct1.CT1_FILIAL = SUBSTRING(se1.E1_FILORIG, 1, @IN_TAMCT1) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMCT1)
				AND ct1.CT1_CONTA  = sed.ED_CREDIT
				AND ct1.D_E_L_E_T_ = @IS_SPACE
			LEFT JOIN FRV### frv LEFT JOIN CT2### ON CT2_FILIAL = ' '
				ON frv.FRV_FILIAL = SUBSTRING(se1.E1_FILORIG, 1, @IN_TAMFRV) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMFRV)
				AND frv.FRV_CODIGO = se1.E1_SITUACA
				AND frv.D_E_L_E_T_ = @IS_SPACE
			WHERE (se1.E1_EMISSAO >= @param_DTINI AND se1.E1_EMISSAO <= @param_DTFIM)
				AND (
						(se1.E1_EMISSAO < @param_DTCORTE AND se1.E1_SALDO > 0)
						OR se1.E1_EMISSAO >= @param_DTCORTE
				)
				AND se1.E1_MULTNAT IN (@IS_SEMRAT, @IS_SPACE)
				AND se1.E1_TIPO <> @IS_TP_RA
				AND se1.E1_TIPO not like @IS_TP_ABT
				AND se1.D_E_L_E_T_ = @IS_SPACE

			for read only

			open curReceber_sem_Rateio_full_##
			fetch next from curReceber_sem_Rateio_full_##
				into
					@F7I_STAMP,
					@F7I_EXTCDH,
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
					@E1_SDACRES,
					@E1_SDDECRE,
					@se1_Deleted, 
					@F7I_VLCRUZ,
					@E1_VALOR,
					@CT1_CONTA,
					@F7I_DSCCTB,
					@F7I_NATCTA,
					@ED_CCC,
					@E1_CCUSTO,
					@F7I_NATURE,
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
					@filial,
					@E1_TXMOEDA
					--#cursorflex

			while ( (@@fetch_Status  = 0 ) )
				Begin
					select @F7I_CONVBS = 0
					select @F7I_CONVCT = 0
					Select @F7I_CCUSTO = @IS_SPACE
					Select @F7I_EXTCDD = @F7I_EXTCDH

					If (@F7I_HIST = @IS_SPACE)
						begin
							select @F7I_HIST = 'SEM DESCRICAO'
						End

					If trim(@F7I_MOVIM) <> '0' and @F7I_MOVIM <> @IS_SPACE AND @E1_PORTADO <> @IS_SPACE
						begin
							select @F7I_BANCO  = TRIM(@E1_PORTADO)
							select @F7I_AGENCI = @E1_AGEDEP
							select @F7I_CONTA  = @E1_CONTA
						end
					else
						begin
							select @F7I_BANCO  = @IS_SPACE
							select @F7I_AGENCI = @IS_SPACE
							select @F7I_CONTA  = 'PREV'
						End

					If @FRV_DESCON = '2' AND @IN_CARTEIRAD = 'S'
						begin
							Select @F7I_SALDO = 0
							Select @F7I_VLPROP = 0
						End
					Else
						Begin
							Select @F7I_SALDO  = ROUND((@E1_SALDO + @E1_SDACRES - @ABAT - @E1_SDDECRE), 2)
							Select @F7I_VLPROP = @F7I_SALDO
							If @F7I_SALDO < 0 
								Begin
									Select @F7I_SALDO = 0
									Select @F7I_VLPROP = 0
								End
						End
					
					If @E1_VALOR <> 0
						Begin 
							If @E1_TXMOEDA > 0
								Begin
									Select @F7I_CONVBS = ROUND((@E1_TXMOEDA), @DecCONVBS)
									Select @F7I_CONVCT = @F7I_CONVBS
								End
							If @E1_TXMOEDA = 0 and @F7I_MOEDA > 1
								Begin
									exec MAT020_## @F7I_EMISSA, @F7I_MOEDA, @F7I_CONVBS OutPut
									Select @F7I_CONVCT = @F7I_CONVBS
								End

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
							Select @F7I_CONVCT = 0
						End
					
					--nao alterar a ordem abaixo
					If TRIM(@F7I_TIPO) = 'NCC'
						Begin
							Select @F7I_VLPROP = @F7I_VLPROP * -1
							Select @F7I_VLCRUZ = @F7I_VLCRUZ * -1
							Select @F7I_SALDO  = @F7I_SALDO  * -1
						End
					
					If @F7I_MOEDA <> 0 AND ( @F7I_MOEDA <> @MOEDA )
						Begin
							select @MOEDA = @F7I_MOEDA
							select @F7I_DSCMDA = (SELECT DSCMDA.X6_CONTEUD 
													FROM SX6### DSCMDA 
													WHERE RTRIM(DSCMDA.X6_VAR) = @IS_MVMOEDA || RTRIM(CAST(@MOEDA AS CHAR(2)))
														AND DSCMDA.D_E_L_E_T_ = @IS_SPACE )
						End 

					If @CT1_CONTA = @IS_SPACE
						Begin
							Select @F7I_CNTCTB = '0'
						End
					Else 
						Begin
							Select @F7I_CNTCTB = @CT1_CONTA 
						End
					
					exec XFILIAL_## 'CTT', @filial, @filialCTT OutPut

					If (@E1_CCUSTO IS NULL OR @E1_CCUSTO = @IS_SPACE)
						Begin
							SELECT @F7I_CCUSTO = @ED_CCC
							SELECT @F7I_DSCCCT = @IS_SPACE
							IF @ED_CCC <> @IS_SPACE
								Begin
									SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01, 1, 40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @ED_CCC AND D_E_L_E_T_ = @IS_SPACE)
								End
						End
					Else
						Begin 
							SELECT @F7I_CCUSTO = @E1_CCUSTO
							SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT  AND CTT_CUSTO = @E1_CCUSTO AND D_E_L_E_T_ = @IS_SPACE)
						End

					If (@se1_Deleted = '*' OR @E1_SALDO = 0 OR (@FRV_DESCON = '2' AND @IN_CARTEIRAD = 'S'))
						Begin
							Select @F7I_INTEGR = 'E' 
						End
					Else 
						Begin
							Select @F7I_INTEGR = @IS_SPACE
						End
					
					If ( @F7I_STAMP is null )
						Begin 
							Select @cF7J_STAMP = @delTransactTime
							If ( @F7I_EMIS1 = @IS_SPACE )
								Begin
									If ( @E1_BAIXA = @IS_SPACE )
										Begin
											Select @cF7I_STAMP = @IS_SPACE
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
						End	
					Else 
						Begin
							Select @cF7I_STAMP = CONVERT(CHAR(26), @F7I_STAMP, 121)
							Select @cF7J_STAMP = @cF7I_STAMP
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

					SELECT @param_COMPANIA = SUBSTRING(@filial, 1, @IN_TAMEMP)
					SELECT @param_COD_UNID = SUBSTRING(@filial, @IN_TAMEMP + 1, @IN_TAMUNIT)
					SELECT @param_COD_FIL = SUBSTRING(@filial, @IN_TAMEMP + 1 + @IN_TAMUNIT, @IN_TAMFIL)

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
						F7I_INTEGR,
						F7I_IDPROC
						--#insertflex
					) Values (
						@cF7I_STAMP,
						@F7I_EXTCDH,
						@F7I_EXTCDD,
						IsNull(@IN_GROUPEMPRESA, @IS_SPACE),
						IsNull(@param_COMPANIA, @IS_SPACE),
						IsNull(@param_COD_UNID, @IS_SPACE),
						IsNull(@param_COD_FIL, @IS_SPACE),
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
						IsNull(SUBSTRING(@F7I_DSCMDA,1,10), @IS_SPACE),
						0 , --@F7I_MOEDB,
						@IS_SPACE, --@F7I_DSCMDB,
						@F7I_VENCTO,
						@F7I_VENCRE,
						@IS_SPACE,--@F7I_DTPGTO,
						'E',--@F7I_TPEVNT,
						@F7I_BANCO,
						@F7I_AGENCI,
						@F7I_CONTA,
						IsNull(@F7I_FLBENF, @IS_SPACE),
						IsNull(@F7I_CDBENF, @IS_SPACE),
						IsNull(@F7I_LJBENF, @IS_SPACE),
						IsNull(SUBSTRING(@F7I_NBENEF,1,50), @IS_SPACE),
						'1',--@F7I_TPBENF,
						'CR', --@F7I_ORBENF,
						@F7I_MOVIM,
						@F7I_DSCMOV,
						@IS_SPACE,-- F7I_IDMOV
						@F7I_SALDO,
						@F7I_VLPROP,
						@F7I_VLCRUZ,
						@F7I_CONVBS,
						@F7I_FXRTBS,
						0 ,--@F7I_VLRCNT,
						@F7I_CONVCT,
						@F7I_FXRTCT,
						@F7I_CNTCTB,
						IsNull(SUBSTRING(@F7I_DSCCTB,1,40), @IS_SPACE),
						@F7I_NATCTA,
						@F7I_CCUSTO,
						IsNull(SUBSTRING(@F7I_DSCCCT,1,40), @IS_SPACE),
						@F7I_NATURE,
						IsNull(@F7I_NATRAT, @IS_SPACE),
						IsNull(@F7I_CCDRAT, @IS_SPACE),
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
						@F7I_INTEGR,
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
						'CRP',
						@Se1Recno , 
						@cF7J_STAMP
					)

					SELECT @CONTADOR = @CONTADOR + 1

					fetch next from curReceber_sem_Rateio_full_##
					into
						@F7I_STAMP,
						@F7I_EXTCDH,
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
						@E1_SDACRES,
						@E1_SDDECRE,
						@se1_Deleted, 
						@F7I_VLCRUZ,
						@E1_VALOR,
						@CT1_CONTA,
						@F7I_DSCCTB,
						@F7I_NATCTA,
						@ED_CCC,
						@E1_CCUSTO,
						@F7I_NATURE,
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
						@filial,
						@E1_TXMOEDA
						--#cursorflex
				End

			close curReceber_sem_Rateio_full_##
			deallocate curReceber_sem_Rateio_full_##
		END
	Else
		BEGIN
			--DELTA
			declare curReceber_sem_Rateio_delta_## insensitive cursor for

			SELECT '##CTE_SE1_ABATIMENTOS##',
				se1.S_T_A_M_P_ 													AS F7I_STAMP,
				'##HASH_MD5_PK##' 												AS F7I_EXTCDH,
				se1.E1_EMISSAO                    								AS F7I_EMISSA,
				se1.E1_EMIS1                      								AS F7I_EMIS1,
				COALESCE(se1.E1_HIST, @IS_SPACE)  								AS F7I_HIST,
				se1.E1_TIPO                       								AS F7I_TIPO,
				ISNULL(sx5_consolidate.X5_DESCRI, @IS_SPACE)  					AS F7I_TIPDSC,
				se1.E1_PREFIXO                    								AS F7I_PREFIX,
				se1.E1_NUM                        								AS F7I_NUM,
				se1.E1_PARCELA                    								AS F7I_PARCEL,
				se1.E1_MOEDA                      								AS F7I_MOEDA,
				se1.E1_VENCTO                     								AS F7I_VENCTO,
				se1.E1_VENCREA                    								AS F7I_VENCRE,
				TRIM(se1.E1_PORTADO)              								AS E1_PORTADO,
				TRIM(se1.E1_CONTA)                								AS E1_CONTA,
				TRIM(se1.E1_AGEDEP)               								AS E1_AGEDEP,
				COALESCE(sa1.A1_FILIAL, @IS_SPACE)  							AS F7I_FLBENF,
				COALESCE(sa1.A1_COD,    @IS_SPACE)  							AS F7I_CDBENF,
				COALESCE(sa1.A1_LOJA,   @IS_SPACE)  							AS F7I_LJBENF,
				COALESCE(sa1.A1_NOME,   @IS_SPACE)  							AS F7I_NBENEF,
				se1.E1_SITUACA                    								AS F7I_MOVIM,
				COALESCE(frv.FRV_DESCRI, @IS_SPACE) 							AS F7I_DSCMOV,
				COALESCE(frv.FRV_DESCON, @IS_SPACE) 							AS FRV_DESCON,
				se1.E1_BAIXA                      								AS E1_BAIXA,
				se1.E1_SALDO                      								AS E1_SALDO,
				COALESCE(se1_abatimentos.ABAT, 0)   							AS ABAT,
				se1.E1_SDACRES                     								AS E1_SDACRES,
				se1.E1_SDDECRE                    								AS E1_SDDECRE,
				se1.D_E_L_E_T_                    								AS se1_Deleted,
				ROUND(se1.E1_VLCRUZ, 2)	             							AS F7I_VLCRUZ,
				se1.E1_VALOR                      								AS E1_VALOR,
				COALESCE(ct1.CT1_CONTA,  @IS_SPACE) 							AS CT1_CONTA,
				COALESCE(ct1.CT1_DESC01, @IS_SPACE) 							AS F7I_DSCCTB,
				COALESCE(ct1.CT1_NATCTA, @IS_SPACE) 							AS F7I_NATCTA,
				COALESCE(sed.ED_CCC,     @IS_SPACE) 							AS ED_CCC,
				COALESCE(se1.E1_CCUSTO, @IS_SPACE)  							AS E1_CCUSTO,
				se1.E1_NATUREZ                    								AS F7I_NATURE,
				se1.E1_CREDIT                     								AS F7I_CREDIT,
				se1.E1_DEBITO                     								AS F7I_DEBITO,
				se1.E1_CCD                        								AS F7I_CCD,
				se1.E1_CCC                        								AS F7I_CCC,
				se1.E1_ITEMCTA                    								AS F7I_ITEMCT,
				se1.E1_ITEMD                      								AS F7I_ITEMD,
				se1.E1_ITEMC                      								AS F7I_ITEMC,
				se1.E1_CLVL                       								AS F7I_CLVL,
				se1.E1_CLVLDB                     								AS F7I_CLVLDB,
				se1.E1_CLVLCR                     								AS F7I_CLVLCR,
				se1.E1_NUMBOR                     								AS F7I_NUMBOR,
				se1.R_E_C_N_O_                    								AS Se1Recno,
				se1.E1_FILORIG                    								AS filial,
				se1.E1_TXMOEDA                    								AS E1_TXMOEDA
				,'#campoflex' as campoflex
			FROM SE1### se1 LEFT JOIN CT2### ON CT2_FILIAL = ' '
			LEFT JOIN se1_abatimentos
				ON se1.E1_FILIAL  = se1_abatimentos.E1_FILIAL
					AND se1.E1_PREFIXO = se1_abatimentos.E1_PREFIXO
					AND se1.E1_NUM     = se1_abatimentos.E1_NUM
					AND se1.E1_PARCELA = se1_abatimentos.E1_PARCELA
					AND se1.E1_CLIENTE = se1_abatimentos.E1_CLIENTE
					AND se1.E1_LOJA    = se1_abatimentos.E1_LOJA
			INNER JOIN SED### sed
				ON sed.ED_FILIAL = SUBSTRING(se1.E1_FILORIG, 1, @IN_TAMSED) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSED)
					AND sed.ED_CODIGO = se1.E1_NATUREZ
					AND sed.D_E_L_E_T_ = @IS_SPACE
			INNER JOIN SA1### sa1
				ON sa1.A1_FILIAL = SUBSTRING(se1.E1_FILORIG, 1, @IN_TAMSA1) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMSA1)
				AND sa1.A1_COD  = se1.E1_CLIENTE
				AND sa1.A1_LOJA = se1.E1_LOJA
				AND sa1.D_E_L_E_T_ = @IS_SPACE
			LEFT JOIN SX5### sx5_consolidate
				ON sx5_consolidate.X5_FILIAL = SUBSTRING (se1.E1_FILORIG, 1, @IN_TAMSX5) || REPLICATE (@IS_SPACE, @N_TAMTOTAL - @IN_TAMSX5)
					AND sx5_consolidate.X5_TABELA = @IS_X5TAB
					AND sx5_consolidate.X5_CHAVE = se1.E1_TIPO
					AND sx5_consolidate.D_E_L_E_T_ = @IS_SPACE
			LEFT JOIN CT1### ct1
				ON ct1.CT1_FILIAL = SUBSTRING(se1.E1_FILORIG, 1, @IN_TAMCT1) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMCT1)
				AND ct1.CT1_CONTA  = sed.ED_CREDIT
				AND ct1.D_E_L_E_T_ = @IS_SPACE
			LEFT JOIN FRV### frv LEFT JOIN CT2### ON CT2_FILIAL = ' '
				ON frv.FRV_FILIAL = SUBSTRING(se1.E1_FILORIG, 1, @IN_TAMFRV) || REPLICATE(@IS_SPACE, @N_TAMTOTAL - @IN_TAMFRV)
				AND frv.FRV_CODIGO = se1.E1_SITUACA
				AND frv.D_E_L_E_T_ = @IS_SPACE
			LEFT JOIN F7J### f7j
				ON f7j.F7J_ALIAS = @F7J_ALIAS 
					AND f7j.F7J_STAMP = CONVERT(CHAR(26), se1.S_T_A_M_P_, 121)
					AND f7j.F7J_RECNO = se1.R_E_C_N_O_
			WHERE se1.S_T_A_M_P_ > @maxStagingCounter
				AND se1.E1_MULTNAT IN (@IS_SEMRAT, @IS_SPACE)
				AND se1.E1_TIPO <> @IS_TP_RA
				AND se1.E1_TIPO not like @IS_TP_ABT
				AND f7j.F7J_RECNO is null

			for read only

			open curReceber_sem_Rateio_delta_##
			fetch next from curReceber_sem_Rateio_delta_##
				into
					@F7I_STAMP,
					@F7I_EXTCDH,
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
					@E1_SDACRES,
					@E1_SDDECRE,
					@se1_Deleted, 
					@F7I_VLCRUZ,
					@E1_VALOR,
					@CT1_CONTA,
					@F7I_DSCCTB,
					@F7I_NATCTA,
					@ED_CCC,
					@E1_CCUSTO,
					@F7I_NATURE,
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
					@filial,
					@E1_TXMOEDA
					--#cursorflex

			while ( (@@fetch_Status  = 0 ) )
				Begin
					Select @F7I_CONVBS = 0
					Select @F7I_CONVCT = 0	
					Select @F7I_CCUSTO = @IS_SPACE
					Select @F7I_EXTCDD = @F7I_EXTCDH

					If (@F7I_HIST = @IS_SPACE)
						begin
							select @F7I_HIST = 'SEM DESCRICAO'
						End

					If trim(@F7I_MOVIM) <> '0' and @F7I_MOVIM <> @IS_SPACE AND @E1_PORTADO <> @IS_SPACE
						begin
							select @F7I_BANCO  = TRIM(@E1_PORTADO)
							select @F7I_AGENCI = @E1_AGEDEP
							select @F7I_CONTA  = @E1_CONTA
						end
					else
						begin
							select @F7I_BANCO  = @IS_SPACE
							select @F7I_AGENCI = @IS_SPACE
							select @F7I_CONTA  = 'PREV'
						End

					If @FRV_DESCON = '2' AND @IN_CARTEIRAD = 'S'
						begin
							Select @F7I_SALDO = 0
							Select @F7I_VLPROP = 0
						End
					Else
						Begin
							Select @F7I_SALDO  = ROUND((@E1_SALDO + @E1_SDACRES - @ABAT - @E1_SDDECRE), 2)
							Select @F7I_VLPROP = @F7I_SALDO
							If @F7I_SALDO < 0 
								Begin
									Select @F7I_SALDO = 0
									Select @F7I_VLPROP = 0
								End
						End
					
					If @E1_VALOR <> 0
						Begin 
							If @E1_TXMOEDA > 0
								Begin
									Select @F7I_CONVBS = ROUND((@E1_TXMOEDA), @DecCONVBS)
									Select @F7I_CONVCT = @F7I_CONVBS
								End
							If @E1_TXMOEDA = 0 and @F7I_MOEDA > 1
								Begin
									exec MAT020_## @F7I_EMISSA, @F7I_MOEDA, @F7I_CONVBS OutPut
									Select @F7I_CONVCT = @F7I_CONVBS
								End

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
							Select @F7I_CONVCT = 0
						End
					
					--nao alterar a ordem abaixo
					If TRIM(@F7I_TIPO) = 'NCC'
						Begin
							Select @F7I_VLPROP = @F7I_VLPROP * -1
							Select @F7I_VLCRUZ = @F7I_VLCRUZ * -1
							Select @F7I_SALDO  = @F7I_SALDO  * -1
						End
					
					If @F7I_MOEDA <> 0 AND ( @F7I_MOEDA <> @MOEDA )
								Begin
									select @MOEDA = @F7I_MOEDA
									select @F7I_DSCMDA = (SELECT DSCMDA.X6_CONTEUD 
															FROM SX6### DSCMDA 
															WHERE RTRIM(DSCMDA.X6_VAR) = @IS_MVMOEDA || RTRIM(CAST(@MOEDA AS CHAR(2)))
																				AND DSCMDA.D_E_L_E_T_ = @IS_SPACE )
								End 

					If @CT1_CONTA = @IS_SPACE
						Begin
							Select @F7I_CNTCTB = '0'
						End
					Else 
						Begin
							Select @F7I_CNTCTB = @CT1_CONTA 
						End
					
					exec XFILIAL_## 'CTT', @filial, @filialCTT OutPut

					If (@E1_CCUSTO IS NULL OR @E1_CCUSTO = @IS_SPACE)
						Begin
							SELECT @F7I_CCUSTO = @ED_CCC
							SELECT @F7I_DSCCCT = @IS_SPACE
							IF @ED_CCC <> @IS_SPACE
								Begin
									SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @ED_CCC AND D_E_L_E_T_ = @IS_SPACE)
								End
						End
					Else
						Begin 
							SELECT @F7I_CCUSTO = @E1_CCUSTO
							SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT  AND CTT_CUSTO = @E1_CCUSTO AND D_E_L_E_T_ = @IS_SPACE)
						End

					If (@se1_Deleted = '*' OR @E1_SALDO = 0 OR (@FRV_DESCON = '2' AND @IN_CARTEIRAD = 'S') )
						Begin
							Select @F7I_INTEGR = 'E' 
						End
					Else 
						Begin
							Select @F7I_INTEGR = @IS_SPACE
						End
					
					If ( @F7I_STAMP is null )
						Begin 
							Select @cF7J_STAMP = @delTransactTime
							If ( @F7I_EMIS1 = @IS_SPACE )
								Begin
									If ( @E1_BAIXA = @IS_SPACE )
										Begin
											Select @cF7I_STAMP = @IS_SPACE
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
						End	
					Else 
						Begin
							Select @cF7I_STAMP = CONVERT(CHAR(26), @F7I_STAMP, 121)
							Select @cF7J_STAMP = @cF7I_STAMP
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

					SELECT @param_COMPANIA = SUBSTRING(@filial, 1, @IN_TAMEMP)
					SELECT @param_COD_UNID = SUBSTRING(@filial, @IN_TAMEMP + 1, @IN_TAMUNIT)
					SELECT @param_COD_FIL = SUBSTRING(@filial, @IN_TAMEMP + 1 + @IN_TAMUNIT, @IN_TAMFIL)

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
						F7I_INTEGR,
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
						IsNull(SUBSTRING(@F7I_DSCMDA,1,10), @IS_SPACE),
						0 , --@F7I_MOEDB,
						@IS_SPACE, --@F7I_DSCMDB,
						@F7I_VENCTO,
						@F7I_VENCRE,
						@IS_SPACE,--@F7I_DTPGTO,
						'E',--@F7I_TPEVNT,
						@F7I_BANCO,
						@F7I_AGENCI,
						@F7I_CONTA,
						IsNull(@F7I_FLBENF, @IS_SPACE),
						IsNull(@F7I_CDBENF, @IS_SPACE),
						IsNull(@F7I_LJBENF, @IS_SPACE),
						IsNull(SUBSTRING(@F7I_NBENEF,1,50), @IS_SPACE),
						'1',--@F7I_TPBENF,
						'CR', --@F7I_ORBENF,
						@F7I_MOVIM,
						@F7I_DSCMOV,
						@IS_SPACE,-- F7I_IDMOV
						@F7I_SALDO,
						@F7I_VLPROP,
						@F7I_VLCRUZ,
						@F7I_CONVBS,
						@F7I_FXRTBS,
						0 ,--@F7I_VLRCNT,
						@F7I_CONVCT,
						@F7I_FXRTCT,
						@F7I_CNTCTB,
						IsNull(SUBSTRING(@F7I_DSCCTB,1,40),@IS_SPACE),
						@F7I_NATCTA,
						@F7I_CCUSTO,
						IsNull(SUBSTRING(@F7I_DSCCCT,1,40),@IS_SPACE),
						@F7I_NATURE,
						IsNull(@F7I_NATRAT, @IS_SPACE),
						IsNull(@F7I_CCDRAT, @IS_SPACE),
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
						@F7I_INTEGR,
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
						'CRP',
						@Se1Recno , 
						@cF7J_STAMP
					)

					SELECT @CONTADOR = @CONTADOR + 1

					fetch next from curReceber_sem_Rateio_delta_##
					into
						@F7I_STAMP,
						@F7I_EXTCDH,
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
						@E1_SDACRES,
						@E1_SDDECRE,
						@se1_Deleted, 
						@F7I_VLCRUZ,
						@E1_VALOR,
						@CT1_CONTA,
						@F7I_DSCCTB,
						@F7I_NATCTA,
						@ED_CCC,
						@E1_CCUSTO,
						@F7I_NATURE,
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
						@filial,
						@E1_TXMOEDA
						--#cursorflex
				End

			close curReceber_sem_Rateio_delta_##
			deallocate curReceber_sem_Rateio_delta_##
			select @OUT_RESULTADO = '1'
		END

		Begin
			INSERT INTO F7P### (F7P_IDPROC, F7P_INICIO, F7P_FIM, F7P_QTDE, F7P_PROCES, F7P_LOTE) 
			VALUES (@ID_PROCESSO, @DATA_INICIO, CONVERT(Char(26), SYSDATETIME(), 121), @CONTADOR, @IS_FIN006A, @IN_LOTEPROC)
		End
END