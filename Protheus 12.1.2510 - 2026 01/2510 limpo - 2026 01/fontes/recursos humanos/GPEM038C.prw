#Include 'Protheus.ch'
#Include 'GPEM038.ch'

Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM038C
@Author   isabel.noguti/raquel.andrade
@Since    15/10/2024
@Version  1.0
/*/
Function GPEM038C()
Return()

/*/{Protheus.doc} fNew2555
Função responsável por gerar o evento S-2555 - Solicitação de Consolidação das Informações de Tributos Decorrentes de Processo Trabalhista
@Author.....: isabel.noguti/raquel.andrade
@Since......: 15/10/2024
@Version....: 1.0
/*/
Function fNew2555( dDataIni, aArrayFil, aLogsOk, aLogsErr )
	Local aErrTaf		:= {}
	Local aDadosRJE		:= {}
	Local cAliasQry		:= GetNextAlias()
	Local cFilEnv		:= ""
	Local cIdLog		:= ""
	Local cOldProc		:= ""
	Local cProJud		:= ""
	Local cIdSeq		:= ""
	Local cPerAp		:= ""
	Local cQuery		:= ""
	Local cStat2501		:= "-1"
	Local cStat2555		:= "-1"
	Local cStatPred		:= "-1"
	Local cStatNew		:= "-1"
	Local cOperNew		:= "I"
	Local cXml			:= ""
	Local cMsgErr		:= ""
	Local cRjeKey		:= ""
	Local cChaveMid		:= ""
	Local cRetfNew		:= ""
	Local cFilInBkp		:= ""
	Local cProcExe		:= ""	
	Local lRet			:= .F.
	Local lRetXml		:= .F.
	Local lNovoRJE		:= .T.
	Local lTAFS13		:= ChkFile("T8I")
	Local lGPES13		:= ChkFile("E0H")
	Local nFil		 	:= 0
	Local nCont			:= 0	
	Local nRecEvt		:= 0	
	Local nZ			:= 0
	Local nTamIdSeq		:= 0
	Local oStat1		:= Nil //Query para buscar os processo
		
	Private cTpInsc		:= ""
	Private cNrInsc		:= ""
	Private cIdXml		:= ""
	Private lAdmPubl	:= .F.	

	Default dDataIni	:= CtoD("")
	Default aArrayFil	:= {}
	Default aLogsOk		:= {}
	Default aLogsErr	:= {}

	// Verifica se as atualizações de dicionário estão aplicadas no ambiente
	If cVersEnvio >= "9.3"
		If !lGPES13
			cMsgErr := OemToAnsi(STR0063)//"Ambiente GPE desatualizado para geração do evento no leiaute S-1.3, atualize o ambiente com a expedição contínua. "
		EndIf
		If !lMiddleware .And. !lTAFS13
			cMsgErr += OemToAnsi(STR0064)//"Verifique se o ambiente do TAF está atualizado."
		EndIf
	EndIf

	// Interrompe execução caso o ambiente não esteja atualizado
	If !Empty(cMsgErr)
		aAdd( aLogsErr, cMsgErr )
		Return
	EndIf

	// Tamanho do campo id sequencia
	If cVersEnvio >= "9.3"
		nTamIdSeq := FwTamSX3("E0H_IDSQPR")[1]
	EndIf

	cProcDe := If( Empty(cProcDe), '0', cProcDe )
	cPerAp	:= AnoMes(dDataIni)

	For nFil := 1 To Len(aArrayFil)
		cProcExe := ""
		For nZ := 1 To Len(aArrayFil[nFil][3])
			cFilIn	:= xFilial("RE0", aArrayFil[nFil][3][nZ])
			cFilEnv	:= aArrayFil[nFil][1]

			// Caso já tenha processado registros da filial
			If !Empty(cFilInBkp) .And. cFilInBkp == cFilIn
				Loop
			EndIf

			cFilInBkp := cFilIn

			If lMiddleware
				fPosFil( cEmpAnt, cFilEnv )
				cStatPred := "-1"
				If fVld1000( cPerAp, @cStatPred, cFilEnv )
					cTpInsc	 := ""
					cNrInsc	 := "0"
					lAdmPubl := .F.
					cIdXml	 := ""
					aInfoC	 := fXMLInfos(cPerAp)
					If Len(aInfoC) >= 4
						cTpInsc  := aInfoC[1]
						cNrInsc  := aInfoC[2]
						lAdmPubl := aInfoC[4]
					EndIf
				Else
					cMsgErr := cFilEnv + " - " + OemToAnsi(STR0045)//"### - Registro do evento S-1000"
					cMsgErr += If(cStatPred == "-1", OemToAnsi(STR0046), "")	//" não localizado na base de dados"
					cMsgErr += If( cStatPred == "1", OemToAnsi(STR0047), "")	//" não transmitido para o governo"
					cMsgErr += If( cStatPred == "2", OemToAnsi(STR0048), "")	//" aguardando retorno do governo"
					cMsgErr += If( cStatPred == "3", OemToAnsi(STR0049), "")	//" retornado com erro do governo"
					aAdd( aLogsErr, cMsgErr)
					Loop
				EndIf
			EndIf

			If oStat1 == Nil
				oStat1 := FWPreparedStatement():New()
				cQuery := "SELECT DISTINCT RE0.RE0_PROJUD, E0H.E0H_IDSQPR "
				cQuery += "FROM " + RetSqlName('RE0') + " RE0 "
				cQuery += "INNER JOIN " + RetSqlName('E0H') + " E0H ON " + FwJoinFilial("E0H","RE0") + " AND E0H.E0H_PRONUM=RE0.RE0_NUM "
				cQuery += "WHERE E0H.E0H_FILIAL IN ( ? ) "
				cQuery +=	"AND E0H.E0H_PERAP = ? "
				cQuery +=	"AND E0H.E0H_IDSQPR > ? "
				cQuery +=	"AND RE0.RE0_PROJUD BETWEEN ? AND ? "
				cQuery += 	"AND E0H.D_E_L_E_T_ = ? "
				cQuery +=   "AND RE0.D_E_L_E_T_ = ? "
				cQuery += "ORDER BY RE0.RE0_PROJUD, E0H.E0H_IDSQPR "
				cQuery := ChangeQuery(cQuery)
				oStat1:SetQuery(cQuery)
			EndIf

			oStat1:SetString(1, cFilIn)
			oStat1:SetString(2, cPerAp)
			oStat1:SetString(3, '0')//seq usuario informa
			oStat1:SetString(4, cProcDe)
			oStat1:SetString(5, cProcAte)
			oStat1:SetString(6, ' ')
			oStat1:SetString(7, ' ')
			cQuery := oStat1:getFixQuery()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

			While (cAliasQry)->(!EoF())

				If !((cAliasQry)->RE0_PROJUD $ cProcExe) 
					lRet 		:= .T.
					cOldProc	:= (cAliasQry)->RE0_PROJUD
					cIdSeq		:= (cAliasQry)->E0H_IDSQPR
					cIdLog		:= " - " + STR0042 + cOldProc 	//" - Processo: ###"
					cIdLog		+=  STR0076 + cPerAp   			//" - Per.Apur.: ###"	

					// Status S-2501
					If lMiddleware
						cStat2501	:= "-1"
						cRjeKey		:= Padr( cFilEnv + cOldProc + cPerAp + cIdSeq, fTamRJEKey(), " ")
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2501" + cRjeKey + cPerAp
						GetInfRJE( 2, cChaveMid, @cStat2501)
					Else
						cStat2501 := TAFGetStat( "S-2501", PadR(cOldProc,20) + ";" + cPerAp + ";" + cIdSeq, cEmpAnt, cFilEnv, 7 )//V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_IDESEQ+V7C_ATIVO
					EndIf

					// Cenário: Ter E0H com mais de uma sequencia, onde um evento está apenas no GPE e o outro já foi integrado
					If cStat2501 == "-1"
						(cAliasQry)->(DbSkip())		
						If (cAliasQry)->(EoF()) .Or. ;
							(cAliasQry)->RE0_PROJUD <> cOldProc	 .Or. ;
							((cAliasQry)->RE0_PROJUD == cOldProc .And. (cAliasQry)->E0H_IDSQPR <> cIdSeq) 
							//"Evento S-2501 com sequencia não integrado para o período de apuração informado"
							cMsgErr := OemToAnsi(STR0070)	
							aAdd(aLogsErr, cIdLog + " - " + cMsgErr)
						EndIf
						Loop
					EndIf

					cProcExe	+= cOldProc + "|"
					cProJud		:= AllTrim((cAliasQry)->RE0_PROJUD)

					// Status S-2555
					If lMiddleware
						nRecEvt		:= 0
						cRjeKey		:= cFilEnv + cOldProc + cPerAp + "S2555"
						cKeyMid		:= cRjeKey
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2555" + Padr(cKeyMid, 40, " ")
						//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						GetInfRJE( 2, cChaveMid, @cStat2555 , /*cOperRJE*/, /*cRetfRJE*/, @nRecEvt, cRjeKey, /*cRecAnt*/,/*lVldFil*/,/*cVldFil*/,/*lVldS3000*/,/*cDtIni*/,.T. )
					Else
						//T8I_FILIAL+T8I_NRPROC+T8I_PERAPU+T8I_ATIVO 4			
						cStat2555 	:= TAFGetStat( "S-2555", PadR(cOldProc,20) + ";" + cPerAp, cEmpAnt, cFilEnv, 4 )
					EndIf

					Begin Transaction
						lRetXml := fXML2555(@cXml, cProJud, cPerAp )
						If lRetXml
							If  cStat2555 == "2"
								//"Evento S-2555 está aguardando retorno do governo, registro de Consolidação S-2555 desprezado."
								cMsgErr	:= OemToAnsi(STR0081) 
								aAdd(aLogsErr, cIdLog )
								aAdd(aLogsErr, cMsgErr)
							ElseIf cStat2555 == "4"
								//"Evento S-2555 não permite Refitificação, evento deverá ser excluído e integrado novamente."
								cMsgErr	:= OemToAnsi(STR0082)
								aAdd(aLogsErr, cIdLog )
								aAdd(aLogsErr, cMsgErr)
							ElseIf cStat2555 == "6" .Or. (lMiddleware .And. cStat2555 == "99")
								//"Evento S-2555 com evento de Exclusão pendente para transmissão, registro de Consolidação S-2555 desprezado."
								cMsgErr	:= OemToAnsi(STR0083)
								aAdd(aLogsErr, cIdLog )
								aAdd(aLogsErr, cMsgErr)
							Else
								If lMiddleware
									If cStat2555 $ "1/3"
										cOperNew 	:= "I"
										cRetfNew	:= "1"
										cStatNew	:= "1"
										lNovoRJE	:= .F.
									// Será tratado como inclusão
									Else
										cOperNew 	:= "I"
										cRetfNew	:= "1"
										cStatNew	:= "1"
										lNovoRJE	:= .T.
									EndIf

									aDadosRJE := {}
									cIdXml := If( Empty(cIdXml), aInfoC[3], fXMLInfos(cPerAp)[3] ) //gerar id por evento, demais infos são por filial
									aAdd( aDadosRJE, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2555", cPerAp, cRjeKey, cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
									If fGravaRJE( aDadosRJE, cXML, lNovoRJE, nRecEvt )
										aAdd(aLogsOk, cIdLog )
									EndIf
								Else							
									aErrTaf := TafPrepInt( cEmpAnt, cFilEnv, cXml, /*cTafKey*/, "3", "S-2555", , , , , , "GPE" )

									If Len(aErrTaf) == 0
										aAdd( aLogsOk, cIdLog )
									Else
										aAdd( aLogsErr, cIdLog )
										For nCont := 1 to Len(aErrTaf)
											aAdd( aLogsErr, aErrTaf[nCont])
										Next
									EndIf
								EndIf
							EndIf
						EndIf
					End Transaction
				EndIf
				cXml		:= ""
				cProJud		:= ""
				cLogId		:= ""
				cIdSeq		:= ""
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		Next Nz
	Next nFil
	If !lRet
		//"Nenhum registro foi localizado, verifique os parametros selecionados"
		aAdd( aLogsErr, OemToAnsi(STR0041) ) 
	Endif

Return lRet

/*/{Protheus.doc} fXML2555
Geração XML do evento S-2555
@Author.....: isabel.noguti
@Since......: 15/10/2024
@Version....: 1.0
/*/
Static Function fXML2555( cXml, cProJud, cPerAp )
	Local lRet		:= .F.
	Local cVersMw   := ""
	Local cVersEnv	:= ""
	Local cTpAmb	:= ""

	Default cXml		:= ""
	Default cProJud		:= ""
	Default cPerAp		:= ""

	If lMiddleware
		fVersEsoc( "S2555", .T., /*aRetGPE*/, /*aRetTAF*/, @cVersEnv, Nil, @cVersMw , , @cTpAmb )
		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtConsolidContProc/v" + cVersMw + "'>"
		cXML += 	"<evtConsolidContProc Id='" + cIdXml + "'>"		
		fXMLIdEve( @cXML, { Nil, Nil, Nil, Nil, cTpAmb, 1, "12" } )
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Else
		cXml := '<eSocial>'
		cXml += 	'<evtConsolidContProc>'
	EndIf
	cXml +=			'<ideProc>'
	cXml +=				'<nrProcTrab>' + cProJud + '</nrProcTrab>'
	cXml +=				'<perApurPgto>' + If( !lMiddleware, cPerAp, SubStr(cPerAp,1,4) + "-" + SubStr(cPerAp,5,2) ) + '</perApurPgto>'//taf AAAAMM / Mid AAAA-MM
	cXml +=			'</ideProc>'

	cXml += 	'</evtConsolidContProc>'
	cXml += '</eSocial>'

	If !Empty(cXml)
		GrvTxtArq(AllTrim(cXml), "S2555",  cPerAp + cProJud)
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} fDel2555
Função responsável por gerar o evento S-3500 para o evento S-2555
@Author.....: martins.marcio
@Since......: 18/11/2024
@Version....: 1.0
/*/
Function fDel2555(dDataIni, aArrayFil, aLogsOk, aLogsErr )
	Local cAliasQry		:= GetNextAlias()
	Local cFilEnv		:= ""
	Local cIdLog		:= ""
	Local cOldProc		:= ""
	Local cPerAp		:= ""
	Local cQuery		:= ""
	Local cStatus		:= "-1"
	Local cStat2555		:= "-1"
	Local cMsgErr		:= ""
	Local cXml			:= ""
	Local cFilInBkp		:= ""
	Local cEvtLog		:="Registro S-3500 do Processo: "
	Local cOldIdSeq		:= ""
	Local cRecib2555	:= ""
	Local lRet			:= .F.
	Local lRetXML		:= .T.
	Local lAdmPubl		:= .F.
	Local lProcessa		:= .T.
	Local lTAFS13		:= V7J->(ColumnPos("V7J_IDESEQ")) > 0
	Local nFil 			:= 0
	Local nZ			:= 0
	Local oStat1		:= Nil 

	// Variáveis do Middleware
	Local cTpInsc		:= ""
	Local cNrInsc		:= ""
	Local cChaveMid	 	:= ""
	Local cStatNew		:= ""
	Local cOperNew		:= ""
	Local cRetfNew		:= ""
	Local cKeyMid		:= ""
	Local cRjeKey		:= ""
	Local cIdXml		:= ""
	Local lNovoRJE		:= .T.

	Default dDataIni	:= CtoD("")
	Default aArrayFil	:= {}
	Default aLogsOk		:= {}
	Default aLogsErr	:= {}

	//Verifica se as atualizações de dicionário estão aplicadas no ambiente
	If cVersEnvio >= "9.3" 
		If !lMiddleware .And. !lTAFS13
			cMsgErr += OemToAnsi(STR0064)//"Verifique se o ambiente do TAF está atualizado."
		EndIf
	EndIf

	//Interrompe execução do evento S-2555 caso o ambiente não esteja atualizado
	If !Empty(cMsgErr)
		aAdd( aLogsErr, cMsgErr )
		Return
	EndIf

	cPerAp	:= AnoMes(dDataIni)

	For nFil := 1 To Len(aArrayFil)
		cProcExe := ""
		For nZ := 1 To Len(aArrayFil[nFil][3])
			cFilIn := xFilial("RE0", aArrayFil[nFil][3][nZ])
			cFilEnv := aArrayFil[nFil][1]

			//Caso já tenha processado registros da filial
			If !Empty(cFilInBkp) .And. cFilInBkp == cFilIn
				Loop
			EndIf

			cFilInBkp := cFilIn

			If lMiddleware
				//Descomentar MID
				// fPosFil( cEmpAnt, cFilEnv )
				// cStatus := "-1"
				// If fVld1000( cPerAp, @cStatus, cFilEnv )
				// 	cTpInsc	 := ""
				// 	cNrInsc	 := "0"
				// 	lAdmPubl := .F.
				// 	cIdXml	 := ""
				// 	aInfoC	 := fXMLInfos(cPerAp)
				// 	If Len(aInfoC) >= 4
				// 		cTpInsc  := aInfoC[1]
				// 		cNrInsc  := aInfoC[2]
				// 		lAdmPubl := aInfoC[4]
				// 	EndIf
				// Else
				// 	cMsgErr := cFilEnv + " - " + OemToAnsi(STR0045)//"### - Registro do evento S-1000"
				// 	cMsgErr += If(cStatus == "-1", OemToAnsi(STR0046), "")	//" não localizado na base de dados"
				// 	cMsgErr += If( cStatus == "1", OemToAnsi(STR0047), "")	//" não transmitido para o governo"
				// 	cMsgErr += If( cStatus == "2", OemToAnsi(STR0048), "")	//" aguardando retorno do governo"
				// 	cMsgErr += If( cStatus == "3", OemToAnsi(STR0049), "")	//" retornado com erro do governo"
				// 	aAdd( aLogsErr, cMsgErr)
				// 	lProcessa	:= .F.
				// 	Loop
				// EndIf
			EndIf
			
			If oStat1 == Nil
				oStat1 := FWPreparedStatement():New()
				cQuery := "SELECT DISTINCT RE0.RE0_PROJUD, E0H.E0H_PERAP "
				cQuery += "FROM " + RetSqlName('E0H') + " E0H "
				cQuery += "INNER JOIN " + RetSqlName('RE0') + " RE0 ON " + FwJoinFilial("E0H","RE0") + " AND E0H.E0H_PRONUM=RE0.RE0_NUM "
				cQuery += "LEFT JOIN " + RetSqlName('RD0') + " RD0 ON " + FwJoinFilial("E0H","RD0") + " AND E0H.E0H_RECLAM=RD0.RD0_CODIGO " //observ
				cQuery += "WHERE E0H.E0H_FILIAL IN ( ? ) "
				cQuery +=	"AND E0H.E0H_PERAP = ? "
				cQuery += 	"AND E0H.E0H_PRONUM IN (SELECT RE0.RE0_NUM "
				cQuery +=							"FROM " + RetSqlName('RE0') + " RE0 "
				cQuery +=						 	"WHERE RE0.RE0_FILIAL IN ( ? ) "
				cQuery +=							"AND RE0.RE0_PROJUD BETWEEN ? AND ? "
				cQuery +=							"AND RE0.RE0_PROJUD IN (SELECT RE0_PROJUD "
				cQuery +=													"FROM " + RetSqlName('RE0') + " RE0 "
				cQuery += 													"INNER JOIN " + RetSqlName('RD0') + " RD0 ON " + FwJoinFilial("RE0","RD0") + " AND RE0.RE0_RECLAM = RD0.RD0_CODIGO "
				cQuery +=													"WHERE RD0.RD0_CIC BETWEEN ? AND ? "
				cQuery +=													"AND RD0.D_E_L_E_T_ = ' ') "
				cQuery +=							"AND RE0.D_E_L_E_T_ = ' ') "
				cQuery +=	"AND RE0.RE0_PROJUD BETWEEN ? AND ? "
				cQuery += 	"AND E0H.D_E_L_E_T_ = ' ' "
				cQuery +=   "AND RD0.D_E_L_E_T_ = ' ' "
				cQuery +=   "AND RE0.D_E_L_E_T_ = ' ' "
				cQuery += "ORDER BY RE0.RE0_PROJUD, E0H.E0H_PERAP "

				cQuery := ChangeQuery(cQuery)
				oStat1:SetQuery(cQuery)
			EndIf

			oStat1:SetString(1, cFilIn)
			oStat1:SetString(2, cPerAp)
			oStat1:SetString(3, cFilIn)
			oStat1:SetString(4, cProcDe)
			oStat1:SetString(5, cProcAte)
			oStat1:SetString(6, cCpfDe)
			oStat1:SetString(7, cCpfAte)
			oStat1:SetString(8, cProcDe)
			oStat1:SetString(9, cProcAte)

			cQuery := oStat1:getFixQuery()

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

			While (cAliasQry)->(!EoF())

				If !(((cAliasQry)->RE0_PROJUD + (cAliasQry)->E0H_PERAP ) $ cProcExe) .And. lProcessa
					lRet 		:= .T.
					lRetXML 	:= .T.
					lProcessa	:= .T.
					cOldProc	:= (cAliasQry)->RE0_PROJUD
					cPerAp		:= (cAliasQry)->E0H_PERAP

					cProcExe	+= cOldProc + cPerAp + "|"

					cIdLog		:= " - " + STR0042 + cOldProc //" - Processo: ###"
					cIdLog		+= STR0076 + cPerAp   //" - Per.Apur.: ###"

					// Status S-2555
					If lMiddleware								
						//Descomentar MID
						// cRjeKey		:= cFilEnv + cOldProc + cPerAp + "S2555"
						// cKeyMid		:= cRjeKey
						// cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2555" + Padr(cKeyMid, 40, " ")
						// //RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
						// GetInfRJE( 2, cChaveMid, @cStat2555,,,,@cRecib2555 )
					Else			
						//T8I_FILIAL+T8I_NRPROC+T8I_PERAPU+T8I_ATIVO 4			
						cStat2555 	:= TAFGetStat( "S-2555", PadR(cOldProc,20) + ";" + cPerAp, cEmpAnt, cFilEnv, 4 )
						cRecib2555 := getRec2555(cFilEnv, cOldProc, cPerAp)
						cRecib2555 := If( Empty(cRecib2555), "S2555" + cOldProc + cPerAp, cRecib2555 )
					EndIf

					If cStat2555 $ "2*3*4*6"
						BEGIN Transaction
							If  cStat2555 == "2"
								//"Evento S-2555 está aguardando retorno do governo, registro de Exclusão S-3500 desprezado."
								cMsgErr	:= OemToAnsi(STR0086) 
								aAdd(aLogsErr, cIdLog )
								aAdd(aLogsErr, cMsgErr)
								lRetXML := .F.
							ElseIf cStat2555 == "3"
								// "Evento S-2555 rejeitado pelo Governo. Realizar os devidos ajustes para que ele esteja apto para Exclusão."
								cMsgErr	:= OemToAnsi(STR0087) 
								aAdd(aLogsErr, cIdLog )
								aAdd(aLogsErr, cMsgErr)
								lRetXML := .F.
							ElseIf cStat2555 == "6" .Or. (lMiddleware .And. cStat2555 == "99")	
								//"Evento S-2555 com evento de Exclusão pendente para transmissão, registro de Exclusão S-3500 desprezado."
								cMsgErr	:= OemToAnsi(STR0088)
								aAdd(aLogsErr, cIdLog )
								aAdd(aLogsErr, cMsgErr)
								lRetXML := .F.
							ElseIf cStat2555 == "4"
								cStatNew 	:= ""
								cOperNew 	:= ""
								cRetfNew 	:= ""
								cKeyMid	 	:= ""
								nRecEvt	 	:= 0
								lNovoRJE 	:= .T.
								aDadosRJE	:= {}
								aErros		:= {}

								InExc3500(@cXml,'S-2555',cRecib2555, cOldProc, ,Substr(cPerAp,1,4)+ "-"+Substr(cPerAp,5,2),AllTrim(cOldIdSeq), cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cIdXml, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cRjeKey, @aErros)
								GrvTxtArq(alltrim(cXml), "S3500", cOldProc )

								If lMiddleware
									//Descomentar MID
									// If Empty(aErros)
									// 	aDadosRJE := {}
									// 	aAdd( aDadosRJE, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3500", cPerAp  , cRecib2555 , cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )									
									// 	fGravaRJE( aDadosRJE, cXML, lNovoRJE, nRecEvt )
									// EndIf
								Else
									aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3500",,,,,,"GPE")
								EndIf

								If Len( aErros ) > 0
									cMsgErro := ''
									FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
									FormText(@cMsgErro)
									aErros[1] := cMsgErro
									aAdd(aLogsErr, cEvtLog + cOldProc + " - "+ OemToAnsi(STR0051) ) //##"Registro S-3500 "##" não foi integrado devido ao(s) erro(s) abaixo: "
									aAdd(aLogsErr, "" )
									aAdd(aLogsErr, aErros[1] )
									lRetXML := IIF(Len(aErros) > 0,.F.,.T.)	
								EndIf
							EndIf

							If !lRetXML
								lProcessa := .F.
							Else
								aAdd( aLogsOk, cIdLog )	
							EndIf

						END Transaction
					Else	

						lStat2555	:= If(lMiddleware, cStat2555 == "1", Empty(cStat2555))
						If lStat2555
							//"Evento S-2555 não transmitido, realizar a transmissão ou excluir pela rotina Exclusão de Eventos (GPEM922)."
							//"Evento S-2555 não transmitido, verificar o evento na rotina do TAF."
							cMsgErr := If(lMiddleware,OemToAnsi(STR0089),OemToAnsi(STR0090))
						Else
							//"Evento S-2555 inexistente, executar a geração do evento S-2555."
							cMsgErr := OemToAnsi(STR0091)
						EndIf 						
						aAdd(aLogsErr, cIdLog )
						aAdd(aLogsErr, cMsgErr)
						lProcessa := .F.

					EndIf
					
				EndIf
				(cAliasQry)->(DbSkip())
			Enddo
			(cAliasQry)->(dbCloseArea())
		Next nZ
	Next nFil
	If !lRet
		aAdd( aLogsErr, OemToAnsi(STR0041) ) //"Nenhum registro foi localizado, verifique os parametros selecionados"
	Endif

Return lRet

/*/{Protheus.doc} getRec2555
Retorna o recibo do evento S-2555
@Author.....: martins.marcio
@Since......: 18/11/2024
@Version....: 1.0
/*/
Static Function getRec2555(cFilEx, cProcRecb, cPerAp)

	Local aArea			:= GetArea()
	Local cRecib		:= ""
	Local cChvT8I 		:= ""
	Default cFilEx		:= ""
	Default cProcRecb 	:= ""
	Default cPerAp		:= ""

	DbSelectArea("T8I")
	T8I->( dbSetOrder(4) ) //4 - T8I_FILIAL+T8I_NRPROC+T8I_PERAPU+T8I_ATIVO
	cChvT8I	:= xFilial("T8I",cFilEx) + PADR(cProcRecb,20) + cPerAp + "1"
	If T8I->( dbSeek( cChvT8I ) )
		cRecib := Alltrim(T8I->T8I_PROTUL)
	EndIf

	RestArea(aArea)

Return cRecib
