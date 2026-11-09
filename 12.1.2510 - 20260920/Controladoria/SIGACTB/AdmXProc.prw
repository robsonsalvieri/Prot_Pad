#Include "PROTHEUS.Ch"
// Funcoes declaradas e usadas em procedures, que necessitam
// ser prefixadas no AS400 com o nome do banco ( schema )
// ( array usado na aplicacao de stored procedures )
Static a400Funcs := { "MSDATEDIFF" , "MSDATEADD" }

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CtbAjustaP³ Autor ³                       ³ Data ³ 28/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz validacoes nas procedures antes e depois da procedures ³±±
±±³          ³ passarem pela funca MsParse                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CtbAjustaP()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cQuery = procedure ajustada                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GENERICO                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lAntesParser =.t. antes da Msparse, .F. depois da funca    ³±±
±±³          ³ cQueryParser = query a ser ajustada                        ³±±
±±³          ³ nTratRec = posicao em q o recno deve ser tratado           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CtbAjustaP(lAntesParser, cQuery, nPTratRec)
	Local aSaveArea   := GetArea()
	Local nPosFim     := 0
	Local nPosFim2	  := 0
	Local nPos2       := 0
	Local nPos3       := 0
	Local nCnt01      := 0
	Local nCaracter   := 0
	Local cRecnotext  := ""
	Local cInsertText := ""
	Local cBufferAux  := ""
	Local xProc       := ""
	Local nPosAux     := 0
	Local cNumField   := ""
	Local nPosIni     := 0
	Local cCampo      := ''
	Local lMantem     :=.T.
	Local cTabela     := ''
	Local cChaveUnica := ''
	*/
	//nPTratRec	      := If( nPTratRec = NIL, 0, nTratRec )
	default nPTratRec = 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacoes que devem ser feitas/adicionadas ANTES da query ( procedure ) passar pela funcao MsParses ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAntesParser
		/* ---------------------------------------------------------------------
		TRATAMENTO PARA GRAVAR REGISTROS SIMULTANEAMENTE NA MESMA TABELA.
		##TRATARECNO nRecno
			codigo
			Insert Into Recno values ;
	   			 	codigo
		##FIMTRATARECNO
		---------------------------------------------------------------------- */
		While ("##TRATARECNO" $ Upper(cQuery))
			nPTratRec	:= AT("##TRATARECNO",Upper(cQuery))
			nPosFim		:= AT("\",Upper(cQuery))
			//Retorna a variavel recno a ser aplicada no insert
			cRecnotext	:= Substr(cQuery,nPTratRec+13,nPosFim-nPTratRec-13)
			nPosFim2	:= AT("##FIMTRATARECNO", Upper(cQuery))
			//Retorna o INSERT para ser utilizado no tratamento.
			cInsertText	:= Substr( cQuery, nPosFim+1,nPosFim2-nPosFim-1)
			//Seta as variaveis @ins_ini e @ins_fim, que serao utilizadas como marcador inicial e final no tratamento de INSERT.
			cBufferAux	:= "select @ins_ini = " + cRecnotext + CRLF
			cBufferAux	+= cInsertText + CRLF
			cBufferAux	+= "select @ins_fim = 1 " + CRLF
			cQuery 	:= Stuff( cQuery, nPTratRec,((nPosFim2+15)-nPTratRec),cBufferAux ) // Retira ##TRATARECNO e Inclui o Tratamento de Insert no cBuffer
		End While

		//Inclui declaracao de variaveis utilizadas para o tratamento de INSERT na procedure
		If nPTratRec <> 0
			nPos3 := at("BEGIN",upper(cQuery))
			If nPos3 > 0
				cInsertText := "Declare @iLoop integer " + CRLF
				cInsertText += "Declare @ins_error integer " + CRLF
				cInsertText += "Declare @ins_ini integer " + CRLF
				cInsertText += "Declare @ins_fim integer " + CRLF
				cInsertText += "Declare @icoderror integer " + CRLF
				cQuery	:= Stuff(cQuery,(nPos3-2),0,cInsertText)
			Endif
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se o campos utilizado existe na tabela para a criacao d procedure  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While ("##FIELDP" $ Upper(cQuery))
			nPosAux   := AT("##FIELDP",Upper(cQuery))
			cNumField := substr(cQuery,nPosAux + 8,2)
			nPosIni   := AT("##FIELDP" + cNumField +"( '", Upper(cQuery))
			nPosFim   := AT("##ENDFIELDP" + cNumField, Upper(cQuery))
			cCampo    := ''
			lMantem   :=.T.
			// Verifica se os campos existem no banco
			For nPos2 := nPosIni+13 to Len( cQuery )
				If substr( cQuery, nPos2, 1) != "'" .and. substr( cQuery, nPos2, 1) != ";".and. substr( cQuery, nPos2, 1) != "."
					cCampo += substr( cQuery, nPos2, 1)
				Elseif substr( cQuery, nPos2, 1) = "."
					cTabela := cCampo
					If !EMPTY(FWX2CHAVE(cTabela))
						lMantem := .f.
						exit
					EndIf
					cCampo := ''
				Else
					If !EMPTY(FWX2CHAVE(cTabela))
						ChkFile(cTabela, .F.)
						If cCampo <> "R_E_C_D_E_L_"
							lMantem := lMantem .and. ((cTabela)->(FieldPos( cCampo )) > 0)
							cCampo := ''
						else
							cChaveUnica := tcInternal(13, Alltrim(FWX2UNICO(cTabela)))
							If Empty(cChaveUnica)
								lMantem := .f.
								cCampo := ''
							else
								lMantem := .t.
								cCampo := ''
							EndIf
						EndIf
					EndIf
				EndIf
				If substr( cQuery, nPos2, 1) = "'"
					EXIT
				EndIf
			Next
			If !lMantem
				// os marcadores e todo o código contido entre eles serão removidos
				cQuery:= Substr( cQuery, 1, nPosIni-1 )+ Substr( cQuery, nPosFim+13 )
			Else
				// Retira apenas as instrucoes #FIELDP  e ##ENDFIELDP
				cQuery:= Substr( cQuery, 1, nPosIni-1 ) + Substr( cQuery, nPos2 + 3, nPosfim - nPos2 - 3 ) + Substr( cQuery, nPosfim+13 )
			EndIf
		End While

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacoes que devem ser feitas APOS a query ( procedure ) passar pela funcao MsParse ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  ( isincallstack("AUTJOBRUNCT") .or. isincallstack("CTBS001") ) .and. ('MSSQL' $ Trim(TcGetDb()) .or. Trim(TcGetDb()) = 'SYBASE')
			cQuery := StrTran(cQuery, 'SET @iTranCount = 0', " Commit Transaction ")
			cQuery := StrTran(cQuery, 'SET @iTranCount  = 0', " Commit Transaction ")
		End

		If Trim(TcGetDb()) = 'INFORMIX'
			cQuery := StrTran(cQuery, 'LET viTranCount  = 0', "COMMIT WORK")
			cQuery := StrTran(cQuery, 'LTRIM ( RTRIM (', "TRIM((")
		EndIf

		//Efetua tratamento para o DB2 ou AS400
		If Trim(TcGetDb()) = 'DB2'
			cQuery	:= StrTran( cQuery, 'set vfim_CUR  = 0 ;', 'set fim_CUR = 0;' )
			cQuery	:= StrTran( cQuery, "IF fim_CUR <> 1 THEN", "IF fim_CUR = 1 THEN")
		elseIf  Trim(TcGetDb()) = 'ORACLE'
			cQuery	:= StrTran( cQuery, "CUR_PCO300%NOTFOUND1", "CUR_PCO300%NOTFOUND")
		EndIf

		//Inclusao do tratamento de INSERT na procedure
		If nPTratRec <> 0
			cQuery	:= InsertPutSql( TcGetDb(), cQuery )
			If Trim(TcGetDb()) = 'DB2'
				nPos3 := at("DECLARE FIM_CUR INTEGER DEFAULT 0;",upper(cQuery))
				If nPos3 > 0
					cInsertText := "Declare fim_CUR integer default 0;" + CRLF
					cInsertText += "Declare v_dup_key CONDITION for sqlstate '23505';" + CRLF
					cQuery	:= Stuff(cQuery,nPos3,34,cInsertText)
				Endif
				nPos3 := at("SET FIM_CUR = 1;",upper(cQuery))
				If nPos3 > 0
					cInsertText := "SET fim_CUR = 1;" + CRLF
					cInsertText += "DECLARE CONTINUE HANDLER FOR v_dup_key SET vicoderror = 1;" + CRLF
					cQuery	:= Stuff(cQuery,nPos3,16,cInsertText)
				Endif
			EndIf
		EndIf

		xProc := ''
		For nCnt01 := 1 to Len(cQuery)
			nCaracter := asc(Substr(cQuery,nCnt01,1))
			if nCaracter == 13
				xProc += ''
			elseif nCaracter == 10
				xProc +=chr(10)
			else
				xProc += Subs(cQuery,nCnt01,1)
			endif
		Next
		cQuery:=xProc
		// na validaproc
		If Upper(TcSrvType())= "ISERIES" .and. !Empty(cQuery)
			cQuery := pVldDb2400( cQuery )   //pcoxfun
		EndIf
	Endif

	RestArea(aSaveArea)
Return( cQuery)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³pVldDb2400  ³ Autor ³ siga                  ³ Data ³02.07.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Realiza ajustes na procedure para aplicar no DB2 do AS400    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³pVldDb2400( cBuffer )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpC1 = cBuffer- procedure a ser ajustada para o db2/400    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function pVldDb2400( cBuffer )
	Local lTop4AS400   := ('ISERIES'$Upper(TcSrvType()))
	Local lTop4ASASCII := .F.
	Local cTOP400Alias := ""
	Local nPos3        := 0

	// Sendo tool ou nao, ajusta sintaxe para AS400 com TOP4
	If lTop4AS400

		// Identifica se o TOP4 AS400 é o build novo, com tratamento ASCII
		If val(TCInternal(80)) >= 20081008
			lTop4ASASCII := .T.
		Endif

		// Identifica nome do Schema ( Alias )
		cTOP400Alias := GetSrvProfString('DBALIAS','')
		If empty(cTOP400Alias)
			cTOP400Alias := GetSrvProfString('TOPALIAS','')
		Endif
		If empty(cTOP400Alias)
			cTOP400Alias := GetPvProfString('TOTVSDBACCESS','ALIAS','',GetAdv97())
		Endif
		If empty(cTOP400Alias)
			cTOP400Alias := GetPvProfString('TOPCONNECT','ALIAS','',GetAdv97())
		Endif

		// Troca operadores de concatenacao e diferenca
		cBuffer	:= StrTran( cBuffer, '||', ' CONCAT ' )
		cBuffer	:= StrTran( cBuffer, '!=', '<>' )

		// Se for criação de FUNCTION, deve ser especificado
		// LANGUAGE SQL NOT FENCED antes do BEGIN

		If !"LANGUAGE SQL"$upper(cBuffer)
			nPos3 := at("BEGIN",upper(cBuffer))
			if nPos3 > 0
				cBuffer	:= Stuff(cBuffer,nPos3,0,"LANGUAGE SQL NOT FENCED"+CRLF)
			Endif
		Endif

		// Localiza o begin novamente, e acrescenta o sort sequence
		// diferenciado para  o TOP4 AS400
		// Mas apenas coloca isso se for build antigo, antes do ASCII

		If !lTop4ASASCII
			nPos3 := at("BEGIN",upper(cBuffer))
			If nPos3 > 0
				cBuffer	:= Stuff(cBuffer,nPos3,0,"SET OPTION SRTSEQ = TOP40/TOPASCII"+CRLF)
			Endif
		Endif

		// Prefixa as chamadas de stored procedures com o nome do banco/alias atual
		cBuffer := UPstrtran(cBuffer,"CALL ","CALL "+cTOP400Alias+".")

		// Prefixa as chamadas de functions com o alias do banco (schema) atual
		aeval(a400Funcs , {|x| cBuffer := UPstrtran(cBuffer,x,cTOP400Alias+"."+x) } )

		// Utilizado para passar qualquer erro nao tratado para o nivel superior
		// Declara handler de erro para fazer RESIGNAL de qualquer SQL Exception
		// se j'a tem um handler declarado, faz ap'os ele.
		// Se nao tem, faz apos ultimo declare encontrado.
		nPos3 := at("DECLARE CONTINUE HANDLER",upper(cBuffer))
		If nPos3 > 0
			cBuffer	:= Stuff(cBuffer,nPos3,0,"DECLARE EXIT HANDLER FOR SQLEXCEPTION "+CRLF+"   RESIGNAL ;"+CRLF)
		Else
			nPos3 := rat("DECLARE ",upper(cBuffer))
			If nPos3 > 0
				while substr(cBuffer,nPos3,1) != chr(10)
					nPos3++
				Enddo
				nPos3++
				cBuffer	:= Stuff(cBuffer,nPos3,0,"DECLARE EXIT HANDLER FOR SQLEXCEPTION "+CRLF+"   RESIGNAL ;"+CRLF)
			Endif
		Endif

		// Coloca commitment level *CHG !! Sem ele, a procedure ocasiona erro caso tente fazer um rollback em caso de erro interno...
		nPos3 := at("BEGIN",upper(cBuffer))
		If nPos3 > 0
			cBuffer	:= Stuff(cBuffer,nPos3,0,"SET OPTION COMMIT = *CHG"+CRLF)
		Endif

		// DEBUG - Mostra corpo da procedure gerado no console
		/*
	conout(replicate('=',79 ))
	conout(cBuffer)
	conout(replicate('=',79 ))
		*/

	Endif
Return(cBuffer)
