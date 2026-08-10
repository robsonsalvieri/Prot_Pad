-- =============================================
-- Author:		Luiz Gustavo Romeiro de Jesus
-- Create date: 27/01/2025
-- Description:	Geracao dos movimentos bancarios para a tabela F7N Gesplan
-- =============================================
CREATE PROCEDURE FIN010_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
	@IN_TAMSA6  Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
	@IN_DTINI char('FK5_DATA'),
	@IN_DTFIM char('FK5_DATA'),
	@IN_COMPANIA char('##COMPANIA'),
	@IN_COD_UNID char('##COD_UNID'),
	@IN_COD_FIL char('##COD_FIL'),
    @IN_DEL char(1),
	@IN_BXLOTE char(1),
	@IN_TRANSACTION char(1),
	@OUT_RESULTADO char( 01 ) OutPut
) AS 
	
	-- 1- Criando as variaveis
	declare @filial    char('FK5_FILORI')
	declare @N_TAMTOTAL Integer

	declare @param_COMPANIA char('##COMPANIA')
    declare @param_COD_UNID char('##COD_UNID')
    declare @param_COD_FIL char('##COD_FIL')
    -----------------------------------------------------------------
    declare @F7N_FILIAL char('F7N_FILIAL')
    declare @F7N_EXTCDH char('F7N_EXTCDH')
    declare @F7N_EXTCDD char('F7N_EXTCDD')
    declare @F7N_DATA   char('F7N_DATA')
    declare @F7N_VALOR float
    declare @F7N_NATURE char('F7N_NATURE')
    declare @F7N_TPEVNT char('F7N_TPEVNT')
    declare @F7N_TPDOC char('F7N_TPDOC')
    declare @F7N_DOC char('F7N_DOC')
    declare @F7N_HISTOR char('F7N_HISTOR')
    declare @F7N_CCUSTO char('F7N_CCUSTO')
    declare @F7N_TXMOED float
    declare @F7N_ORIGEM char('F7N_ORIGEM')
    declare @F7N_DTDISP char('F7N_DTDISP')
    declare @F7N_DEBITO char('F7N_DEBITO')
    declare @F7N_CREDIT char('F7N_CREDIT')
    declare @F7N_CCD char('F7N_CCD')
    declare @F7N_CCC char('F7N_CCC')
    declare @F7N_ITEMD char('F7N_ITEMD')
    declare @F7N_ITEMC char('F7N_ITEMC')
    declare @F7N_CLVLDB char('F7N_CLVLDB')
    declare @F7N_CLVLCR char('F7N_CLVLCR')
    declare @F7N_MOEDA char('F7N_MOEDA')
    declare @F7N_DSCMDA char('F7N_DSCMDA')
    declare @F7N_BANCO char('F7N_BANCO')
    declare @F7N_AGENCIA char('F7N_AGENCIA')
    declare @F7N_CONTA char('F7N_CONTA')
    declare @F7N_FLXF01 char('F7N_FLXF01')
    declare @F7N_FLXF02 char('F7N_FLXF02')
    declare @F7N_FLXF03 char('F7N_FLXF03')
    declare @F7N_FLXF04 char('F7N_FLXF04')
    declare @F7N_FLXF05 char('F7N_FLXF05')
    declare @F7N_MSUID char('F7N_MSUID')
    declare @F7N_STAMP char('F7I_STAMP')
	declare @BXLOTE char(1)
	declare @cF7N_STAMP char(26)
	declare @cF7J_STAMP char(26)
	declare @maxStagingCounter datetime
	declare @dtInifilter datetime

	--## Variaveis Trabalho Em condicionais ##--
	declare @data_inicio char(8)
	declare @data_fim char(8)

	--## Variaveis Trabalho Pos Consulta ##--
    declare @FK5_RECPAG char('FK5_RECPAG')
    declare @FK5_ORDREC char('FK5_ORDREC')
    declare @FK5_DOC char('FK5_DOC')
    declare @FK5_NUMCH char('FK5_NUMCH')
    declare @FK5_HISTOR char('FK5_HISTOR')
    declare @S_T_A_M_P_FK5 datetime
    declare @FK5_DATA char('FK5_DATA')
	declare @FK5_RECNO Integer
	declare @cStamp char(26)
	declare @delTransactTime char(26)
	declare flex char(1)

	BEGIN
		select @OUT_RESULTADO = '0'
		select @N_TAMTOTAL = @IN_TAMEMP + @IN_TAMUNIT +	@IN_TAMFIL 
		-----------------------------------------------------------------
		-- 2- Definindos as variaveis
		-----------------------------------------------------------------
		

    	If (@IN_DTINI <> ' ' and @IN_DTFIM <> ' ' and @IN_DEL = 'S') --Adicionar tratamento com parametro de limpeza
    	    BEGIN
				##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
    	        delete F7N###
				where 
					F7N_DATA BETWEEN @IN_DTINI and @IN_DTFIM
					AND F7N_GRPEMP = @IN_GROUPEMPRESA
					AND F7N_EMPR = @IN_COMPANIA
					AND F7N_UNID = @IN_COD_UNID
					AND F7N_FILNEG = @IN_COD_FIL
    	        ##CHECK_TRANSACTION_COMMIT			
    	    END

			--## Data Incio ##--
			IF @IN_DTINI = ' '
				BEGIN
					-- Calcula a data de dois anos atras
					SELECT @data_inicio = CONVERT(CHAR(8), DATEADD(YEAR, -2, GetDate()), 112)
				END
			ELSE
				BEGIN
					-- Atribui @IN_DTINI a variavel
					SELECT @data_inicio = @IN_DTINI
				END

				--## Data Incio ##--
			IF @IN_DTFIM = ' '
				BEGIN
					-- Calcula a data de dois anos atras
					SELECT @data_fim = Convert(CHAR(8), GetDate(), 112) 
				END
			ELSE
				BEGIN
					-- Atribui @IN_DTINI a variavel
					SELECT @data_fim = @IN_DTFIM
				END

	Select @cStamp = (
					SELECT MIN(F7J_STAMP) 
						FROM F7J### F7J
						WHERE 
							F7J.F7J_ALIAS = 'MVB' 
				)
	
	If @IN_BXLOTE = ' '
		Begin
			select @BXLOTE = '2'
		End
	Else
		Begin
			select @BXLOTE = @IN_BXLOTE
		End

	Select @delTransactTime = CONVERT(CHAR(26), DATEADD(HOUR, -1, GETUTCDATE()), 121)
	Select @dtInifilter = CONVERT(datetime, '', 121)
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
	Else
		Begin
			select @maxStagingCounter = @dtInifilter
		End
			-----------------------------------------------------------------
		-- 3- Gerando o Cursor da query principal
		-----------------------------------------------------------------
			declare curMovBancario insensitive cursor for
    		--Main Query
    		Select
    		    FK5_DATA																	                as F7N_DATA,        
				TRIM(Cast(A6_MOEDA as char(2)))																as F7N_MOEDA,
				(SELECT TRIM(X6_CONTEUD) FROM SX6### WHERE X6_FIL = ' ' AND Trim(X6_VAR) = 'MV_MOEDA' || TRIM(Cast(A6_MOEDA as char(2))) AND D_E_L_E_T_ = ' ') F7N_DSCMDA,
    		    FK5_VALOR														                            as F7N_VALOR,
    		    FK5_NATURE																					as F7N_NATURE,   
				FK5_BANCO																					as F7N_BANCO,
    		    FK5_AGENCI																					as F7N_AGENCIA,
    		    FK5_CONTA																					as F7N_CONTA,
				FK5_RECPAG																					as FK5_RECPAG,
    		    FK5_TPDOC													                                as F7N_TPDOC,
				FK5_ORDREC																					as FK5_ORDREC,
				FK5_DOC																						as FK5_DOC,
				FK5_NUMCH																					as FK5_NUMCH,
				FK5_HISTOR																					as FK5_HISTOR,
				S_T_A_M_P_FK5																				as S_T_A_M_P_FK5,
    		    FK5_CCUSTO																		            as F7N_CCUSTO,
    		    CAST(FK5_TXMOED	AS FLOAT)		                                                            as F7N_TXMOED,
    		    FK5_IDMOV												                                    as F7N_EXTCDH,
    		    FK5_IDMOV													                                as F7N_EXTCDD,
    		    FK5_ORIGEM														                            as F7N_ORIGEM,
    		    Isnull(FK8_DEBITO,' ')		                                                                as F7N_DEBITO,
    		    Isnull(FK8_CREDIT,' ')		                                                                as F7N_CREDIT,
    		    Isnull(FK8_CCD,' ')			                                                                as F7N_CCD,
    		    Isnull(FK8_CCC,' ')			                                                                as F7N_CCC,
    		    Isnull(FK8_ITEMD,' ')		                                                                as F7N_ITEMD,
    		    Isnull(FK8_ITEMC,' ')		                                                                as F7N_ITEMC,
    		    Isnull(FK8_CLVLDB,' ')		                                                                as F7N_CLVLDB,
    		    Isnull(FK8_CLVLCR,' ')		                                                                as F7N_CLVLCR,        
    		    FK5_DTDISP																	                as F7N_DTDISP,
				RECNO            	                                                                        as FK5_RECNO ,
				FK5FILORI -- @filial 
				,'#selectcursorflex' as cursorflex     																							
    		From
    		    --Query Principal somente com os campos utilizados no DM
				(SELECT
					stg.FK5_FILIAL,
					stg.FK5_BANCO,
					stg.FK5_AGENCI,
					stg.FK5_CONTA,
					stg.FK5_IDMOV,
					stg.FK5_DATA,
					stg.FK5_VALOR,
					stg.FK5_NATURE,
					stg.FK5_RECPAG,
					stg.FK5_TPDOC,
					stg.FK5_ORDREC,
					stg.FK5_DOC,
					stg.FK5_NUMCH,
					stg.FK5_HISTOR,
					stg.FK5_CCUSTO,
					stg.FK5_TXMOED,
					stg.FK5_VLMOE2,
					stg.FK5_ORIGEM,
					stg.FK5_DTDISP,
					stg.FK5_FILORI as FK5FILORI,
					stg.S_T_A_M_P_ as S_T_A_M_P_FK5,
					stg.D_E_L_E_T_,
					stg.R_E_C_N_O_ RECNO,
					sa6.A6_MOEDA,
					fk8.FK8_FILIAL,
					fk8.FK8_IDMOV,
					fk8.FK8_DEBITO,
					fk8.FK8_CREDIT,
					fk8.FK8_CCD,
					fk8.FK8_CCC,
					fk8.FK8_ITEMD,
					fk8.FK8_ITEMC,
					fk8.FK8_CLVLDB,
					fk8.FK8_CLVLCR
					,'#campoflex' as campoflex
				FROM
					FK5### stg LEFT JOIN CT2### ON CT2_FILIAL = ' '
					INNER JOIN SA6### sa6
    		        On      
    		            sa6.A6_FILIAL= SUBSTRING(stg.FK5_FILORI,1,@IN_TAMSA6) || REPLICATE(' ', @N_TAMTOTAL - @IN_TAMSA6)  --@FilialSA6
    		            AND sa6.A6_COD=stg.FK5_BANCO
    		            AND sa6.A6_AGENCIA=stg.FK5_AGENCI                
    		            AND sa6.A6_NUMCON=stg.FK5_CONTA

					LEFT JOIN FK8### fk8 LEFT JOIN CT2### ON CT2_FILIAL = ' ' On      
    		            fk8.FK8_FILIAL = stg.FK5_FILIAL --MESMO NIVEL DE COMPARTILHAMENTO (nao precisa tratamento)
    		            AND fk8.FK8_IDMOV = stg.FK5_IDMOV

					LEFT JOIN F7J### f7j ON 
						f7j.F7J_ALIAS = 'MVB' 
						AND Trim(f7j.F7J_STAMP) = CONVERT(CHAR(26), stg.S_T_A_M_P_, 121)
						AND f7j.F7J_RECNO = stg.R_E_C_N_O_

				WHERE 
					(
					    (
					        Rtrim(stg.FK5_ORIGEM) IN (
					        'FINA100',
					        'FINI100G',
					        'FINA550',
					        'FINA171',
					        'FINA181',
					        'FINA887' /*MI*/,
					        'FINA085A' /*MI*/
							) 
					    OR
					    (
					        (
					        stg.FK5_LOTE <> ' '
					        AND stg.FK5_RECPAG = 'P'
					        AND TRIM(stg.FK5_TPDOC) = 'DB'
					        AND stg.FK5_IDDOC = ' '
					        AND TRIM(stg.FK5_ORIGEM) = 'FINA200' /* Retorno CNAB Receber */
					        )
					    )
					
						OR 
							(
								@BXLOTE = '2'
								AND stg.FK5_LOTE <> ' '
								AND Trim(stg.FK5_TPDOC) IN ('VL', 'BL', 'ES')
								AND stg.FK5_ORIGEM IN ('FINA200', 'FINA070', 'FINA110')
							)
					    OR
							(
					        stg.FK5_NUMCH is not null
							AND stg.FK5_NUMCH <> ' '
					        AND RTrim(stg.FK5_TPDOC) IN ('CH','ES') --Baixas com cheque 
							)
					    )
					)
					And (
					    IsNull(stg.S_T_A_M_P_, @dtInifilter) > @maxStagingCounter
					    or (stg.S_T_A_M_P_ is null  
							and Convert(datetime, stg.FK5_DATA, 121) > @maxStagingCounter
						)
					)
					-----------------------------------------------------------------
					-- 3- Tratamento dos parametros de data para processamento
					-----------------------------------------------------------------
					AND (
						stg.FK5_DATA >= @data_inicio
					)
					AND f7j.F7J_RECNO is null
    		) Mov
		for read only

		open curMovBancario 
    		    fetch next from curMovBancario
    		        into
							@F7N_DATA,
							@F7N_MOEDA,
							@F7N_DSCMDA,
							@F7N_VALOR,
							@F7N_NATURE,
							@F7N_BANCO,
							@F7N_AGENCIA,
							@F7N_CONTA,
							@FK5_RECPAG,
							@F7N_TPDOC,
							@FK5_ORDREC,
							@FK5_DOC,
							@FK5_NUMCH,
							@FK5_HISTOR,
							@S_T_A_M_P_FK5,
							@F7N_CCUSTO,
							@F7N_TXMOED,
							@F7N_EXTCDH,
							@F7N_EXTCDD,
							@F7N_ORIGEM,
							@F7N_DEBITO,
							@F7N_CREDIT,
							@F7N_CCD,
							@F7N_CCC,
							@F7N_ITEMD,
							@F7N_ITEMC,
							@F7N_CLVLDB,
							@F7N_CLVLCR,
							@F7N_DTDISP,
							@FK5_RECNO,
							@filial
							--#cursorflex


    		WHILE ((@@fetch_Status  = 0))
				BEGIN
					--## Variaveis F7N_TPEVNT ##--
					IF @FK5_RECPAG = 'P'
						Begin
							SELECT @F7N_TPEVNT = 'S'
						End
					ELSE
						Begin
							SELECT @F7N_TPEVNT = 'E'
						End

					--## Variaveis F7N_DOC ##--
					IF @FK5_ORDREC <> ' '
						Begin
							SELECT @F7N_DOC = Trim(@FK5_ORDREC) -- MI -- Ordem de Pago
						End
					Else
						Begin
							IF (@FK5_DOC is Null or @FK5_DOC = ' ')
								Begin
									SELECT @F7N_DOC = '0'
								End
							Else
								Begin
									SELECT @F7N_DOC = Trim(@FK5_DOC) -- ERP Padrao		
								End
						End
					--## Variaveis F7N_HISTOR ##--
					IF ( @FK5_NUMCH <> ' '
							AND @FK5_ORDREC = ' ' -- MI nao pode receber historico de Cheque quando nao houver ORDREC preenchido, no padrao estara sempre vazio
							AND Trim(@F7N_TPDOC) IN ('CH', 'ES')
					)
						Begin 
							SELECT @F7N_HISTOR = SUBSTRING(Trim(@FK5_HISTOR) || ' - ' || 'Cheque No: ' || @FK5_NUMCH,1,40 )
						End
					Else
						Begin
							SELECT @F7N_HISTOR = @FK5_HISTOR
						End

					--## Variaveis F7N_STAMP ##--
					IF (@S_T_A_M_P_FK5 is Null)
						Begin
							SELECT @cF7N_STAMP = FORMAT(Convert(date, @F7N_DATA ), 'yyyy-MM-ddTHH:mm:ss.fff')
							Select @cF7J_STAMP = @delTransactTime
						End
					Else
						Begin 
							SELECT @cF7N_STAMP = CONVERT(CHAR(26),@S_T_A_M_P_FK5 , 121) 
							Select @cF7J_STAMP = @cF7N_STAMP
						End	
					 
					##IF_001({|| Trim(TcGetDb()) == "MSSQL" })
						IF  @cF7J_STAMP NOT LIKE '%.%'
							BEGIN 
								SELECT @cF7J_STAMP = TRIM(@cF7J_STAMP) + '.000' 
							END
						IF  @cF7N_STAMP NOT LIKE '%.%'
							BEGIN 
								SELECT @cF7N_STAMP = TRIM(@cF7N_STAMP) + '.000' 
							END
					##ENDIF_001

					SELECT @param_COMPANIA  = SUBSTRING(@filial,1, @IN_TAMEMP )
    				SELECT @param_COD_UNID = SUBSTRING(@filial,@IN_TAMEMP+1, @IN_TAMUNIT)
    				SELECT @param_COD_FIL  = SUBSTRING(@filial,@IN_TAMEMP+1 + @IN_TAMUNIT , @IN_TAMEMP + @IN_TAMUNIT + @IN_TAMFIL)

					-----------------------------------------------------------------
					-- 5- Efetuando a gravacao dos registros
					-----------------------------------------------------------------
					##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
					INSERT INTO F7N### (
						F7N_GRPEMP,
						F7N_EMPR,
						F7N_UNID,
						F7N_FILNEG,
						F7N_DATA,        
						F7N_MOEDA,		
						F7N_DSCMDA,
						F7N_VALOR,
						F7N_NATURE,   
						F7N_BANCO,
						F7N_AGENCI,
						F7N_CONTA,        
						F7N_TPEVNT,
						F7N_BENEF,
						F7N_TPDOC,
						F7N_DOC,
						F7N_HISTOR,
						F7N_CCUSTO,
						F7N_CNTCTB,
						F7N_ORGSYT,
						F7N_TXMOED,
						F7N_EXTCDH,
						F7N_EXTCDD,
						F7N_ORIGEM,
						F7N_DEBITO,
						F7N_CREDIT,
						F7N_CCD,
						F7N_CCC,
						F7N_ITEMD,
						F7N_ITEMC,
						F7N_CLVLDB,
						F7N_CLVLCR,
						F7N_DTDISP,
						F7N_STAMP
						--#insertflex	
					) Values (
						IsNull(@IN_GROUPEMPRESA,' '), 
						IsNull(@param_COMPANIA,' '), 
						IsNull(@param_COD_UNID,' '), 
						IsNull(@param_COD_FIL,' '),
						@F7N_DATA,        
						IsNull(@F7N_MOEDA, ' '),		
						IsNull(SUBSTRING(@F7N_DSCMDA,1,10), ' '),		
						@F7N_VALOR,
						@F7N_NATURE,   
						@F7N_BANCO,
						@F7N_AGENCIA,
						@F7N_CONTA, 
						@F7N_TPEVNT,
						'MB', --@F7N_BENEF
						@F7N_TPDOC,
						@F7N_DOC,
						@F7N_HISTOR,
						@F7N_CCUSTO,
						'0',--@F7N_CNTCTB,
						'MB',--@F7N_ORGSYT,
						@F7N_TXMOED,
						@F7N_EXTCDH,
						@F7N_EXTCDD,
						@F7N_ORIGEM,
						@F7N_DEBITO,
						@F7N_CREDIT,
						@F7N_CCD,
						@F7N_CCC,
						@F7N_ITEMD,
						@F7N_ITEMC,
						@F7N_CLVLDB,
						@F7N_CLVLCR,
						@F7N_DTDISP,
						IsNull(@cF7N_STAMP, ' ')
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
						'MVB',
						@FK5_RECNO , 
						@cF7J_STAMP
					)

					-----------------------------------------------------------------
					-- 6- Posiciona para o proximo registro
					-----------------------------------------------------------------
					fetch next from curMovBancario
						into    
								@F7N_DATA,
								@F7N_MOEDA,
								@F7N_DSCMDA,
								@F7N_VALOR,
								@F7N_NATURE,
								@F7N_BANCO,
								@F7N_AGENCIA,
								@F7N_CONTA,
								@FK5_RECPAG,
								@F7N_TPDOC,
								@FK5_ORDREC,
								@FK5_DOC,
								@FK5_NUMCH,
								@FK5_HISTOR,
								@S_T_A_M_P_FK5,
								@F7N_CCUSTO,
								@F7N_TXMOED,
								@F7N_EXTCDH,
								@F7N_EXTCDD,
								@F7N_ORIGEM,
								@F7N_DEBITO,
								@F7N_CREDIT,
								@F7N_CCD,
								@F7N_CCC,
								@F7N_ITEMD,
								@F7N_ITEMC,
								@F7N_CLVLDB,
								@F7N_CLVLCR,
								@F7N_DTDISP,
								@FK5_RECNO,
								@filial
								--#cursorflex
				END
		-----------------------------------------------------------------
		-- 5- Encerrando o cursor
		-----------------------------------------------------------------	
		DELETE FROM F7J###
		WHERE 
			F7J_ALIAS = 'MVB' 
			AND F7J_STAMP < @delTransactTime 
			AND F7J_STAMP < (
								SELECT MAX(F7J_STAMP )
								FROM F7J### 
								WHERE F7J_ALIAS = 'MVB' 
							)	
		close curMovBancario
		deallocate curMovBancario

		select @OUT_RESULTADO = '1'
	END 