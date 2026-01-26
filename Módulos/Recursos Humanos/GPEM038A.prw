#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM038.CH"

Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM038A
@Author   Silvia Taguti
@Since    04/11/2022
@Version  1.0
/*/
Function GPEM038A()
Return()

/*/{Protheus.doc} fNew2500
Função responsável por gerar o evento S-2500 - Processos Trabalhistas
@Author.....: Silvia Taguti
@Since......: 04/11/2022
@Version....: 1.0
/*/
Function fNew2500(dDataIni, dDataFim, aArrayFil, lRetific, aLogsOk, aCheck, aLogsErr,cVersEnvio,cCPFDe,cCPFAte,cProcDe,cProcAte)

	Local aArea			:= GetArea()
	Local nI            := 0
	Local cDtIni		:= ""
	Local cDtFim		:= ""
	Local cAliasRE0		:= "RE0"
	Local cQuery 		:= ""
	Local nx            := 0
	Local lRetXml		:= .F.
	Local lRet          := .F.
	Local aErros		:= {}
	Local cEvtLog		:= OemToAnsi(STR0050) //"Registro S-2500 do Processo:"
	Local lRetRE0		:= .F.
	Local cStatus 		:= "-1"
	Local cMsgErro      := " "
	Local cTafKey		:= ""
	Local cPerPred		:= ""
	Local cStatPred		:= "-1"
	Local aInfoC		:= {}
	Local aDadosRJE		:= {}
	Local cChaveMid		:= ""
	Local cRjeKey		:= ""
	Local lNovoRJE		:= .T.
	Local cOperEvt		:= ""
	Local cOperNew		:= "I"
	Local cRetfEvt		:= ""
	Local cRecibEvt		:= ""
	Local cRecibAnt		:= ""
	Local nRecEvt		:= 0
	Local lRetif		:= .F.
	Local cIdVinculo	:= ""
	Local nZ			:= 0
	Local cFilInBkp		:= ""
	Local cProcExe		:= ""
	Local cChvProc		:= ""
	Local aStrRE0		:= {}
	Local nTamIdSqPr	:= 3
	Local cMsg			:= ""

	Private	cProJud 	:= ""
	Private	cObsProc	:= ""
	Private	cOrigem 	:= ""
	Private cNumProces	:= ""
	Private cReclam		:= ""
	Private aInfoE0A	:= {}
	Private aInfoE0B	:= {}
	Private aInfoE0C	:= {}
	Private aInfoE0D	:= {}
	Private aInfoE0G	:= {}
	Private aInfoRE1    := {}
	Private aInfoDep    := {}
	Private aInfoE0GDep	:= {}
	Private	cdtSent		:= ""
	Private	cdtCCP		:= ""
	Private	tpCCP		:= ""
	Private cnpjCCP		:= ""
	Private cCodUnic	:= ""
	Private cCPFTRAB	:= ""
	Private cNomeTrab	:= ""
	Private dDtNasc		:= ""
	Private cXml		:= ""
	Private	cTpResp 	:= ""
	Private cNInscResp	:= ""
	Private cDtAdmResp	:= ""
	Private cMatRespD	:= ""
	Private aUnicid		:= {}
	Private cFilIn 		:= ""
	Private cFilEnv     := ""
	Private cTpInsc		:= ""
	Private lAdmPubl	:= .F.
	Private cNrInsc		:= "0"
	Private cRetfNew	:= "1"
	Private cRecibXML	:= ""
	Private cIdXML		:= ""
	Private lTemCpo1_3	:= .T.
	Private lIdSqPr		:= .F.
	Private cIdSqPr		:= ""

	Default cCPFDe		:= ""
	Default cCPFAte 	:= "99999999999"
	Default cProcDe 	:= ""
	Default cProcAte	:= "ZZZZZZZZZZZZ"
	Default dDataIni	:= ctod("")
	Default dDataFim	:= CTOD("")
	Default aArrayFil	:= ""
	Default lRetific	:= .F.
	Default aLogsOk		:= {}
	Default aLogsErr	:= {}
	Default cVersEnvio	:= "9.2.00"

	DbSelectArea("RE0")	
	lTemCpo1_3	:= RE0->(ColumnPos( "RE0_RESPDT")) > 0
	lIdSqPr		:= RE0->(ColumnPos( "RE0_IDSQPR")) > 0 

	If lIdSqPr
		aStrRE0 	:= FWSX3Util():GetFieldStruct( "RE0_IDSQPR" ) 
		nTamIdSqPr	:= aStrRE0[3]
	EndIf

	cDtIni := DtoS(dDataIni)
	cDtFim := DtoS(dDataFim)
	cPerPred := AnoMes(dDataIni)

	IIf(Select(cAliasRE0) > 0,(cAliasRE0)->(DbCloseArea()), .T.)

	For nI := 1 To Len(aArrayFil)
		cProcExe := ""
		For nZ := 1 To Len(aArrayFil[nI][3])

			cFilIn	:= xFilial("RE0", aArrayFil[nI][3][nZ])
			cFilEnv	:= aArrayFil[nI][1]

			//Caso já tenha processado registros da filial
			If !Empty(cFilInBkp) .And. cFilInBkp == cFilIn
				Loop
			EndIf

			cFilInBkp := cFilIn

			If lMiddleware
				fPosFil( cEmpAnt, cFilEnv )
				cStatPred := "-1"
				If fVld1000( cPerPred, @cStatPred, cFilEnv )
					cTpInsc  := ""
					lAdmPubl := .F.
					cNrInsc  := "0"
					aInfoC   := fXMLInfos(cPerPred)
					If Len(aInfoC) >= 4
						cTpInsc  := aInfoC[1]
						lAdmPubl := aInfoC[4]
						cNrInsc  := aInfoC[2]
					EndIf
				Else
					cMsgErro := cFilEnv + " - " + OemToAnsi(STR0045)//"### - Registro do evento S-1000"
					cMsgErro += If(cStatPred == "-1", OemToAnsi(STR0046), "")	// não localizado na base de dados"
					cMsgErro += If( cStatPred == "1", OemToAnsi(STR0047), "")	//" não transmitido para o governo"
					cMsgErro += If( cStatPred == "2", OemToAnsi(STR0048), "")	//" aguardando retorno do governo"
					cMsgErro += If( cStatPred == "3", OemToAnsi(STR0049), "")	//" retornado com erro do governo"
					aAdd( aLogsErr, cMsgErro)
					Loop
				EndIf
			EndIf

			cQuery := "SELECT RE0.RE0_FILIAL, RE0.RE0_NUM, RE0.RE0_RECLAM, RE0.RE0_TPPROC, RE0.RE0_PROJUD,RE0.RE0_COBS, RE0.RE0_DTDECI, RE0.RE0_DTCCP, RE0.RE0_ORIGEM, "
			cQuery += "RE0.RE0_TPCCP,RE0.RE0_COMAR,RE0.RE0_VARA, RE0.RE0_CNPJCC,RE0.RE0_TPINSC, RE0.RE0_NINSC, RD0.RD0_CIC, RD0.RD0_NOME, RD0.RD0_DTNASC "
			If cVersEnvio >= "9.3" .And. lTemCpo1_3
				cQuery += ", RE0.RE0_RESPDT, RE0.RE0_RESPAD "
			EndIf
			If cVersEnvio >= "9.3" .And. lIdSqPr
				cQuery += ", RE0.RE0_IDSQPR "
			EndIf
			cQuery += "FROM " + RetSqlName('RE0') + " RE0 "
			cQuery += "INNER JOIN " + RetSqlName('RD0') + " RD0 "
			cQuery += "ON RE0.RE0_RECLAM = RD0.RD0_CODIGO "
			cQuery += "WHERE RE0.RE0_FILIAL IN ('" + cFilIn + "') "
			cQuery += " AND RE0.RE0_DTDECI BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' "
			cQuery += " AND RE0.RE0_PROJUD  <> ' ' "
			cQuery += " AND RE0.RE0_PROJUD BETWEEN '" + cProcDe + "' AND '" + cProcAte + "' AND "
			cQuery += " RD0.RD0_CIC BETWEEN '" + cCPFDe + "' AND '" + cCPFAte + "' AND"
			cQuery += " RE0.D_E_L_E_T_ = ' ' AND "
			cQuery += " RD0.D_E_L_E_T_ = ' ' "
			cQuery += " ORDER BY RE0.RE0_FILIAL, RE0.RE0_NUM, RE0.RE0_RECLAM "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),	cAliasRE0,.T.,.T.)

			While (cAliasRE0)->(!EOF())
				If !(cAliasRE0)->RE0_NUM $ cProcExe
					//ideResp
					cTpResp 	:= (cAliasRE0)->RE0_TPINSC
					cNInscResp	:= (cAliasRE0)->RE0_NINSC
					If cVersEnvio >= "9.3" .And. lTemCpo1_3
						cDtAdmResp	:= (cAliasRE0)->RE0_RESPDT
						cMatRespD	:= (cAliasRE0)->RE0_RESPAD
					EndIf
					//InfoProcesso
					cProJud  := (cAliasRE0)->RE0_PROJUD
					cObsProc := Alltrim(MSMM((cAliasRE0)->RE0_COBS,,,,3,,,"RE0",,"RE6"))
					cOrigem  := (cAliasRE0)->RE0_ORIGEM
					cProcExe += (cAliasRE0)->RE0_NUM + "|"

					cdtSent := (cAliasRE0)->RE0_DTDECI
					cdtCCP  := (cAliasRE0)->RE0_DTCCP
					tpCCP  	:= (cAliasRE0)->RE0_TPCCP
					cnpjCCP	:= (cAliasRE0)->RE0_CNPJCC
					lRetRE0	:= .T.		

					If !Empty((cAliasRE0)->RE0_COMAR ) .And. !Empty((cAliasRE0)->RE0_VARA )
						lRet := fGetRE1(@aInfoRE1, (cAliasRE0)->RE0_COMAR,(cAliasRE0)->RE0_VARA ) // >> Busca Informarações da Vara
						If !lRet
							aAdd(aLogsErr,OemToAnsi(STR0037) ) //"Comarca/Vara não cadastrada "
							(cAliasRE0)->(DBSkip())
							Loop
						Endif
					else
						lRet := .F.
						aAdd(aLogsErr,OemToAnsi(STR0037) ) //"Comarca/Vara não cadastrada "
						(cAliasRE0)->(DBSkip())
						Loop
					Endif

					If lRet
						//<ideTrab>
						ccpfTrab  := (cAliasRE0)->RD0_CIC
						cNomeTrab := EntGetInfo( "SRA", "RA_NOMECMP", (cAliasRE0)->RE0_RECLAM )
						cNomeTrab := fSubstRH( If( Empty(cNomeTrab), (cAliasRE0)->RD0_NOME, cNomeTrab ) )
						dDtNasc   := (cAliasRE0)->RD0_DTNASC

						If cVersEnvio >= "9.3" .And. lIdSqPr							
							If Empty((cAliasRE0)->RE0_IDSQPR)
								cIdSqPr	:= (cAliasRE0)->RE0_IDSQPR
							Else
								cIdSqPr	:= Padr(cValToChar(Val((cAliasRE0)->RE0_IDSQPR)),nTamIdSqPr,"")
							EndIf
						EndIf

						If !lMiddleware
							If cVersEnvio >= "9.3" .And. lIdSqPr 
								cChvProc	:= cProJud + ";" + ccpfTrab + ";" + "1" + ";" + cIdSqPr  + ";"
							Else
								cChvProc	:= cProJud + ";" + ccpfTrab  
							EndIf  
							// V9U_FILIAL+V9U_NRPROC+V9U_CPFTRA+V9U_IDESEQ+V9U_ATIVO       
							cStatus := TAFGetStat( "S-2500", cChvProc,cEmpAnt,cFilEnv, 6)
						Else
							aDadosRJE	:= {}
							lNovoRJE	:= .T.
							cStatus		:= "-1"
							cOperNew 	:= "I"
							cRetfNew	:= "1"
							nRecEvt		:= 0
							cRecibEvt	:= ""
							cRecibAnt	:= ""

							If cVersEnvio >= "9.3" .And. lIdSqPr 
								cRjeKey		:= Padr( cFilEnv + cProJud + ccpfTrab + AllTrim(cIdSqPr), fTamRJEKey(), " ")
							Else
								cRjeKey		:= Padr( cFilEnv + cProJud + ccpfTrab, fTamRJEKey(), " ")
							EndIf
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2500" + cRjeKey
							GetInfRJE( 2, cChaveMid, @cStatus, @cOperEvt, @cRetfEvt, @nRecEvt, @cRecibEvt, @cRecibAnt )

							If cStatus == "2"
								cMsg	:= If(cVersEnvio >= "9.3" .And. lIdSqPr .And. !Empty(cIdSqPr),  cProJud + OemToAnsi(STR0096) + " " + cIdSqPr ,  cProJud ) 
								aAdd(aLogsErr, cEvtLog + cMsg + " - " + OemToAnsi(STR0056)) //"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
								aAdd(aLogsErr, "" )
								(cAliasRE0)->(DBSkip())
								Loop
							ElseIf cStatus $ "1/3"
								cOperNew 	:= cOperEvt
								cRetfNew	:= cRetfEvt
								lNovoRJE	:= .F.
								If cRetfNew == "2"
									cRecibXML := cRecibAnt
								EndIf
							ElseIf cStatus == "4"
								cOperNew 	:= "A"
								cRetfNew	:= "2"
								cRecibXML	:= cRecibEvt
								cRecibAnt	:= cRecibEvt
								cRecibEvt	:= ""
							EndIf
							cIdXml := If( Empty(cIdXml), aInfoC[3], fXMLInfos(cPerPred)[3] ) //gerar id por evento, demais infos são por filial
							aAdd( aDadosRJE, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2500", cPerPred, cRjeKey, cIdXml, cRetfNew, "12", "1", Date(), Time(), cOperNew, cRecibEvt, cRecibAnt } )
						EndIf

						If (cStatus == "4" .Or. cRetfNew == "2") .And. !lRetific
							cMsg	:= If(cVersEnvio >= "9.3" .And. lIdSqPr .And. !Empty(cIdSqPr), cProJud + OemToAnsi(STR0096) + " " + cIdSqPr , cProJud ) 
							aAdd(aLogsErr, cEvtLog + cMsg + " - " + OemToAnsi(STR0044) ) //"Registro S-2500 do Processo:"##"Ja foi integrado anteriormente, selecione a opção de retificação "
							aAdd(aLogsErr, "" )
							(cAliasRE0)->(DBSkip())
							Loop
						Endif
						lRetif := If(cStatus == "4", lRetific, .F.)

						////E0B - Processo por Vinculo inFoContr
						If !Empty((cAliasRE0)->RE0_NUM ) .And. !Empty((cAliasRE0)->RE0_RECLAM ) .And. !Empty((cAliasRE0)->RE0_PROJUD)
							cNumProces := (cAliasRE0)->RE0_NUM
							cReclam	:= (cAliasRE0)->RE0_RECLAM
							lRet := fGetE0B(@aInfoE0B, cNumProces,cReclam )

							If !lRet .And. Len(aInfoE0B) == 0
								cMsg	:= If(cVersEnvio >= "9.3" .And. lIdSqPr .And. !Empty(cIdSqPr),  (cAliasRE0)->RE0_PROJUD + OemToAnsi(STR0096) + " " + cIdSqPr , (cAliasRE0)->RE0_PROJUD ) 
								aAdd(aLogsErr, OemToAnsi(STR0036) + cMsg) //"Nenhum vinculo relacionado ao processo: "
								aAdd(aLogsErr, "" )
								(cAliasRE0)->(DBSkip())
								Loop
							Endif

							If lRet .And. Len(aInfoE0B) > 0
								For nx:= 1 to Len(aInfoE0B)
									cIdVinculo := aInfoE0B[nx,3]
									cCodUnic   :=  aInfoE0B[nx,13]
									//Informações Reclamante Externo <infoCompl>
									If aInfoE0B[nx,4] == "1"
										lRet := fGetE0G(cNumProces, cReclam, cIdVinculo, cVersEnvio)
										If !lRet
											aAdd(aLogsErr, OemToAnsi(STR0038) ) //"Informações do participante externo não encontrada"
											Exit
										Endif
									Endif
									//<mudCategAtiv>
									aInfoE0A := fGetE0A( cNumProces, cReclam, cIdVinculo ) //	Filial, Processo, Reclamante, Id Vinculo

									//<unicContr>
									If aInfoE0B[nx,5] == "9"
										aUnicid :=	fGetUnic(cNumProces, cReclam, cIdVinculo)
									Endif

									//<ideEstab> <infoVlr>
									lRet := fGetE0C( cNumProces, cReclam, cIdVinculo, cVersEnvio )
									If !lRet
										aAdd(aLogsErr, OemToAnsi(STR0039) ) //"Informações dos períodos e valores decorrentes de processo trabalhista não cadastradas"
										Exit
									//<idePeriodo>
									ElseIf aInfoE0C[nX,6] == "1" .Or. aInfoE0C[nX,6] == "5"
										//E0D Valores Processo por Período
										If !fGetE0D( cNumProces, cReclam, cIdVinculo, aInfoE0C[nX,2], aInfoE0C[nX,3], aInfoE0C[nX,4], aInfoE0C[nX,5], cVersEnvio ) .And. aInfoE0C[nX,6] == "1"
											lRet := .F.
											aAdd(aLogsErr, OemToAnsi(STR0040) ) //Identificação do período ao qual se referem as bases de cálculo
											Exit
										Endif
									Endif
								Next nx //loop E0B
							Endif
						Endif
					Endif
					If lRet
						////Realiza a integração
						Begin Transaction
							lRetXml := fXml2500( @cXml,cVersEnvio, lRetif )

							If !lMiddleware
								cTafKey := "S2500" + cdtSent + cProJud
								//Integração TAF
								aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml,cTafKey, "3", "S2500", , , , , , "GPE", ,  )
							ElseIf lRetXml //Integração MID
								If fGravaRJE( aDadosRJE, cXML, lNovoRJE, nRecEvt )
									cMsg :=  cProJud + OemToAnsi(STR0043) + ccpfTrab 
									If cVersEnvio >= "9.3" .And. lIdSqPr .And. !Empty(cIdSqPr)
										cMsg	+= " " + OemToAnsi(STR0096) + " " + cIdSqPr 
									EndIf
									aAdd(aLogsOk, cEvtLog + " " + cMsg +  OemToAnsi(STR0055) ) //##"Registro S-2500 do Processo"## integrado com Mid
								EndIf
							EndIf
						End Transaction
						If Len( aErros ) > 0
							cMsgErro := ''
							FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
							FormText(@cMsgErro)
							aErros[1] := cMsgErro
							cMsg	:= If(cVersEnvio >= "9.3" .And. lIdSqPr .And. !Empty(cIdSqPr),  cProJud + OemToAnsi(STR0096) + " " + cIdSqPr , cProJud ) 
							aAdd(aLogsErr, cEvtLog + " " + cMsg + " - "+ OemToAnsi(STR0051) ) //##"Registro S-2500 "##" não foi integrado devido ao(s) erro(s) abaixo: "
							aAdd(aLogsErr, "" )
							aAdd(aLogsErr, aErros[1] )
						Endif

						If !lMiddleware .And. lRetXml .And. Len( aErros ) == 0							
							cMsg := cProJud + OemToAnsi(STR0043) + ccpfTrab 
							If cVersEnvio >= "9.3" .And. lIdSqPr .And. !Empty(cIdSqPr)
								cMsg +=  " " + OemToAnsi(STR0096) + " " + cIdSqPr 								
							EndIf							
							aAdd(aLogsOk, cEvtLog + " " + cMsg + OemToAnsi(STR0052)) //##"Registro S-2500 do Processo"## integrado com TAF
						Endif
					Endif
					aInfoE0A	:= {}
					aInfoE0B	:= {}
					aInfoE0C	:= {}
					aInfoRE1    := {}
					aInfoE0G	:= {}
					aInfoE0D	:= {}
					aInfoDep	:= {}
					cdtSent 	:= ""
					cdtCCP  	:= ""
					tpCCP  		:= ""
					cnpjCCP		:= ""
					cProJud 	:= ""
					cObsProc	:= ""
					cOrigem 	:= ""
					cNumProces	:= ""
					cReclam		:= ""
					cCodUnic	:= ""
					cNomeTrab 	:= ""
					dDtNasc	  	:= ""
					cTpResp 	:= ""
					cNInscResp	:= ""
					cDtAdmResp	:= ""
					cMatRespD	:= ""
					aUnicid		:= {}
				EndIf
				(cAliasRE0)->(dbSkip() )
			ENDDO
			(cAliasRE0)->( dbCloseArea() )
		Next nZ
	Next nI

	If !lRetRE0
		aAdd(aLogsErr,OemToAnsi(STR0041) ) //"Nenhum registro foi localizado, verifique os parametros selecionados"
	Endif

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetRE1
Busca  dados na tabela RE1
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetRE1(aInfoRE1, cComarca, cVara)
	Local lRet	:= .F.

	DEFAULT aInfoRE1	:= {}
	Default cComarca 	:= ""
	Default cVara       := ""

	DbSelectArea("RE1")
	RE1->(DbSetOrder(1)) //RE1_FILIAL+RE1_COMAR+RE1_VARA
	If RE1->( DbSeek(xFilial("RE1",cFilIn) + cComarca + cVara) )
		AADD(aInfoRE1, {RE1->RE1_UF, RE1->RE1_CODMUN, RE1->RE1_IDVARA })
		lRet := .T.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0B
Busca  dados na tabela E0B
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fGetE0B(aInfoE0B, cPronum, cReclam)

Local lRet      := .F.
Default cPronum := ""
Default cReclam := ""
Default aInfoE0B := {}

	DbSelectArea("E0B")
	E0B->(DbSetOrder(1)) //E0B_FILIAL +E0B_PRONUM + E0B_RECLAM
	If E0B->( DbSeek(xFilial("E0B",cFilIn) + cPronum + cReclam) )
		While E0B->( !Eof() .And. E0B->E0B_PRONUM == cPronum .And. E0B->E0B_RECLAM==cReclam )
			If Empty(E0B->E0B_VININC)
				AADD(aInfoE0B, {E0B->E0B_PRONUM,;		//1Numero Processo
								E0B->E0B_RECLAM,;		//2Reclamante
								E0B->E0B_IDVINC,;		//3Id. Vinculo
								E0B->E0B_EXT,;			//4Externo
								E0B->E0B_TPCONT,;		//5Tp. Contrato
								E0B->E0B_INDCON,;		//6Ind. Contrat
								E0B->E0B_DTADMO,;		//7Dt. Adm. Ori
								E0B->E0B_INDREI,;		//8Ind. Reinteg
								E0B->E0B_INDCAT,;		//9Recon Categ
								E0B->E0B_INDNAT,;		//10Reconhecimento Atividade
								E0B->E0B_INDMDE,;		//11Reconhecimento Desligamen
								E0B->E0B_INDUNI,;		//12Reconhecimento Contrato
								E0B->E0B_CODUNI,;		//13Matrícula eSocial
								E0B->E0B_CATEFD,;		//14Categoria eSocial
								E0B->E0B_DTITSV } )		//15Dt. Inicio TSV
				lRet := .T.
			EndIf
			E0B->(DBSkip())
		EndDo
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0A
Busca  dados na tabela E0A
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetE0A(cPronum, cReclam, cIdVinculo )


Default aInfoE0A 	:= {}
Default cPronum 	:= ""
Default cReclam 	:= ""
Default cIdVinculo  := ""

	DbSelectArea("E0A")
	E0A->(DbSetOrder(1)) //E0B_FILIAL +E0B_PRONUM + E0B_RECLAM
	If E0A->( DbSeek(xFilial("E0A",cFilIn) + cNumProces + cReclam + cIdVinculo) )

		AADD(aInfoE0A, {E0A->E0A_PRONUM,;		//1Numero Processo
						E0A->E0A_RECLAM,;       //2Reclamante
						E0A->E0A_IDVINC,;		//3Id. Vinculo
						E0A->E0A_IDMUD,;		//4
						E0A->E0A_CODUNI	,;		//5
						E0A->E0A_CATEFD,;		//6
						E0A->E0A_DTTSVE,;		//7
						E0A->E0A_DTALT,;		//8
						E0A->E0A_NCAT,;		    //9
						E0A->E0A_NATUR } )		//10
	Endif

Return aInfoE0A

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0C
Busca dados ideEstab/infoVlr na tabela E0C
@author  isabel.noguti
@since   11/09/2023
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Static Function fGetE0C( cNumProces, cReclam, cIdVinculo, cVersEnvio )
Local oAbono As object
Local lRet		:= .F.
Local cIndenSD	:= ""
Local cIndenAbo	:= ""
Local cMemoE0C	:= ""
Local aBonos	:= {}
Local nX		:= 0

Default cNumProces 	:= ""
Default cReclam 	:= ""
Default cIdVinculo  := ""
Default cVersEnvio	:= "9.2.00"

	DbSelectArea("E0C")
	E0C->(DbSetOrder(1)) //E0C_FILIAL+E0C_PRONUM+E0C_RECLAM+E0C_IDVINC+E0C_TPINSC+E0C_NINSC
	If E0C->( DbSeek(xFilial("E0C",cFilIn) + cNumProces + cReclam + cIdVinculo) )
		cIndenSD	:= E0C->E0C_INDENS
		cIndenAbo	:= E0C->E0C_ABONO
		If cIndenAbo == "S"
			cMemoE0C := MSMM(E0C->E0C_CMEM,,,,3,,,"E0C",,"RDY")
			If !Empty(cMemoE0C)
				oAbono := JsonObject():new()
				oAbono:FromJSON(cMemoE0C)
				For nX:= 1 to Min( 9, Len(oAbono['abono']) )
					If Valtype(oAbono['abono'][nX]['anoBase']) <> "U"
						aAdd( aBonos, oAbono['abono'][nX]['anoBase'] )
					EndIf
				Next nX
			EndIf
		EndIf

		AADD(aInfoE0C, {E0C->E0C_IDVINC,;	//1 Vinculo E0B
						E0C->E0C_TPINSC,;	//2 cTpInPr
						E0C->E0C_NINSC,;	//3 cnInscPr
						E0C->E0C_COMPIN,;	//4 cCompIn
						E0C->E0C_COMFIM,;	//5 cComFim
						E0C->E0C_REPPRO,;	//6 indReperc/repercProc
						E0C->E0C_VREMUN,;	//7 tags 1.1
						E0C->E0C_VRAPI,;	//8
						E0C->E0C_V13API,;	//9
						E0C->E0C_VINDEN,;	//10
						E0C->E0C_BCFGTS,;	//11
						E0C->E0C_PGRESC,;	//12
						cIndenSD,;			//13 tags 1.2
						cIndenAbo,;			//14
						aBonos;				//15
						} )
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0D
Busca  dados na tabela E0D
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetE0D(cNumProces, cReclam, cIdVinculo, cTpInPr, cnInscPr, cCompIn, cComFim, cVersEnvio )
Local lRet			:= .F.
Local nBcProc		:= 0
Local nBcSefip		:= 0
Local nBcAnt		:= 0
Local aInfInterm	:= {}
Local cMemoE0D		:= ""
Local oInfoInterm

Default cNumProces 	:= ""
Default cReclam 	:= ""
Default cIdVinculo  := ""
Default cTpInPr		:= ""
Default cnInscPr    := ""
Default cCompIn		:= ""
Default cComFim		:= ""
Default cVersEnvio	:= "9.2.00"

If !Empty(cTpInPr) .And. !Empty(cnInscPr)
	DbSelectArea("E0D")
	E0D->(DbSetOrder(1)) //E0D_FILIAL+E0D_PRONUM+E0D_RECLAM+E0D_IDVINC+E0D_TPINSC+E0D_NINSC+E0D_COMPET
	E0D->( DbSeek(xFilial("E0D",cFilIn) + cNumProces + cReclam + cIdVinculo +cTpInPr+cnInscPr ) )
	While E0D->( !EoF() ) .And. E0D->E0D_FILIAL == xFilial("E0D",cFilIn) .And. E0D->E0D_PRONUM == cNumProces .And. E0D->E0D_RECLAM == cReclam .And. E0D->E0D_IDVINC == cIdVinculo;
		.And. E0D->E0D_TPINSC == cTpInPr .And. E0D->E0D_NINSC == cnInscPr
			If E0D->E0D_COMPET >= cCompIn .And. E0D->E0D_COMPET <= cComFim
				aInfInterm := {}
				nBcProc := E0D->E0D_FGTSPR
				nBcSefip := E0D->E0D_FGTSSE
				nBcAnt := E0D->E0D_FGTSAN
				If cVersEnvio >= "9.3" .And. lTemCpo1_3
					cMemoE0D := MSMM(E0D->E0D_CMEM,,,,3,,,"E0D",,"RDY")
					If !Empty(cMemoE0D)
						oInfoInterm := JsonObject():new()
						If Empty(oInfoInterm:FromJSON(cMemoE0D))
							aInfInterm := oInfoInterm['infoInterm']
						EndIf
					EndIf
				EndIf

				Aadd(aInfoE0D,{;
					E0D->E0D_TPINSC,; 		//1
					E0D->E0D_NINSC,;   		//2
					E0D->E0D_COMPET,;  		//3
					E0D->E0D_GRAUEX,;  		//4
					E0D->E0D_BCINSS,;  		//5
					E0D->E0D_BCCP13,;  		//6
					E0D->E0D_BCFGTS,;  		//7
					E0D->E0D_FGTS13,;  		//8
					E0D->E0D_FGTSDE,;  		//9
					E0D->E0D_FG13AN,;  		//10
					E0D->E0D_FGTSPG,;  		//11
					E0D->E0D_CODCAT,;  		//12
					E0D->E0D_BCCPRE,; 		//13
					E0D->E0D_IDVINC,;		//14 Id E0B
					nBcProc,;				//15
					nBcSefip,;				//16
					nBcAnt,;				//17
					aInfInterm})			//18
				lRet := .T.
			EndIf
		E0D->( dbSkip() )
	EndDo
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0G
Busca  dados na tabela E0G
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetE0G(cNumProces, cReclam, cIdVinculo, cVersEnvio)

Local oInfoCompl As OBJECT
Local cJMemoE0G  	:= ""
Local cCodCBO 		:= ""
Local nnatAtiv		:= 0
Local dtRemun		:= ""
Local vrSalFx		:= ""
Local undSalFixo	:= ""
Local dscSalVar		:= ""
Local tpRegTrab 	:= 0
Local tpRegPrev 	:= 0
Local dtAdm 		:= ""
Local tmpParc 		:= 0
Local tpContr 		:= 0
Local dtTermDur		:= ""
Local clauAssec 	:= ""
Local objDet 		:= ""
Local observacao 	:= ""
Local tpInsc 		:= 0
Local nrInsc 		:= ""
Local matricAnt 	:= ""
Local dtTransf 		:= ""
Local dtDeslig 		:= ""
Local mtvDeslig 	:= ""
Local dtProjFimAPI	:= ""
Local dtTerm 		:= ""
Local mtvDesligTSV	:= ""
Local lRet			:= .F.
Local nPensAlim		:= 0
Local nPercAlim		:= 0
Local nVrAlim		:= 0

Default cNumProces 	:= ""
Default cReclam 	:= ""
Default cIdVinculo  := ""
Default cVersEnvio	:= "9.1.00"

	DbSelectArea("E0G")
	E0G->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC
	If E0G->( DbSeek(xFilial("E0G",cFilIn) + cNumProces + cReclam + cIdVinculo) )
		While !E0G->(Eof()) .And. (xFilial("E0G",cFilIn) == E0G->E0G_FILIAL .And. cNumProces == E0G->E0G_PRONUM .And. cIdVinculo == E0G->E0G_IDVINC ) .And. !lRet
			If E0G->E0G_TPINF == "2"      //infoCompl
					oInfoCompl := JsonObject():new()
					cJMemoE0G := MSMM(E0G->E0G_CMEM,,,,3,,,"E0G",,"RDY")
					oInfoCompl:FromJSON(cJMemoE0G)

					cCodCBO 	:= If (Valtype(oInfoCompl['codCBO']) == "U",cCodCBO,oInfoCompl['codCBO'])
					nnatAtiv	:= If (Valtype(oInfoCompl['natAtividade']) == "U",nnatAtiv,oInfoCompl['natAtividade'])

					//infoTerm
					If oInfoCompl['infoTerm']:hasProperty("dtTerm")
						dtTerm		:= If (Valtype(oInfoCompl['infoTerm']['dtTerm']) == "U",dtTerm,oInfoCompl['infoTerm']['dtTerm'])
						dtTerm		:= If(lMiddleware, dtTerm, Dtos(fJToD(dtTerm)) )
						mtvDesligTSV:= If (Valtype(oInfoCompl['infoTerm']['mtvDesligTSV']) == "U",mtvDesligTSV,oInfoCompl['infoTerm']['mtvDesligTSV'])
					EndIf

					//Remuneracao
					If Len(oInfoCompl['remuneracao']) > 0
						dtRemun		:= If (Valtype(oInfoCompl['remuneracao'][1]['dtRemun']) == "U",dtRemun,oInfoCompl['remuneracao'][1]['dtRemun'])
						dtRemun		:= If(lMiddleware, dtRemun, Dtos(fJToD(dtRemun)) )
						vrSalFx		:= If (Valtype(oInfoCompl['remuneracao'][1]['vrSalFx']) == "U",vrSalFx,oInfoCompl['remuneracao'][1]['vrSalFx'])
						undSalFixo	:= If (Valtype(oInfoCompl['remuneracao'][1]['undSalFixo']) == "U",undSalFixo,oInfoCompl['remuneracao'][1]['undSalFixo'])
						dscSalVar	:= If (Valtype(oInfoCompl['remuneracao'][1]['dscSalVar']) == "U",dscSalVar,oInfoCompl['remuneracao'][1]['dscSalVar'])
					EndIf

					//InfoVinc
					If oInfoCompl['infoVinc']:hasProperty("tpRegTrab")
						tpRegTrab 	:= If (Valtype(oInfoCompl['infoVinc']['tpRegTrab']) == "U",tpRegTrab,oInfoCompl['infoVinc']['tpRegTrab'])
						tpRegPrev 	:= If (Valtype(oInfoCompl['infoVinc']['tpRegPrev']) == "U",tpRegPrev,oInfoCompl['infoVinc']['tpRegPrev'])
						dtAdm		:= If (Valtype(oInfoCompl['infoVinc']['dtAdm']) == "U",dtAdm,oInfoCompl['infoVinc']['dtAdm'])
						dtAdm		:= If(lMiddleware, dtAdm, Dtos(fJToD(dtAdm)) )
						tmpParc 	:= If (Valtype(oInfoCompl['infoVinc']['tmpParc']) == "U",tmpParc,oInfoCompl['infoVinc']['tmpParc'])

						//duracao
						If oInfoCompl['infoVinc']['duracao']:hasProperty("tpContr")
							tpContr 	:= If (Valtype(oInfoCompl['infoVinc']['duracao']['tpContr']) == "U",tpContr,oInfoCompl['infoVinc']['duracao']['tpContr'])
							dtTermdur	:= If (Valtype(oInfoCompl['infoVinc']['duracao']['dtTerm']) == "U",dtTermdur,oInfoCompl['infoVinc']['duracao']['dtTerm'])
							dtTermdur	:= If(lMiddleware, dtTermdur, Dtos(fJToD(dtTermdur)) )
							clauAssec 	:= If (Valtype(oInfoCompl['infoVinc']['duracao']['clauAssec']) == "U",clauAssec,oInfoCompl['infoVinc']['duracao']['clauAssec'])
							objDet		:= If (Valtype(oInfoCompl['infoVinc']['duracao']['objDet']) == "U",objDet,oInfoCompl['infoVinc']['duracao']['objDet'])
						EndIf

						//observação
						If Len(oInfoCompl['infoVinc']['observacoes']) > 0
							observacao 	:= oInfoCompl['infoVinc']['observacoes'][1]['observacao']
						EndIf

						//sucessaoVinc
						If oInfoCompl['infoVinc']['sucessaoVinc']:hasProperty("tpInsc")
							tpInsc 		:= If (Valtype(oInfoCompl['infoVinc']['sucessaoVinc']['tpInsc']) == "U",tpInsc,oInfoCompl['infoVinc']['sucessaoVinc']['tpInsc'])
							nrInsc 		:= If (Valtype(oInfoCompl['infoVinc']['sucessaoVinc']['nrInsc']) == "U",nrInsc,oInfoCompl['infoVinc']['sucessaoVinc']['nrInsc'])
							matricAnt 	:= If (Valtype(oInfoCompl['infoVinc']['sucessaoVinc']['matricAnt']) == "U",matricAnt,oInfoCompl['infoVinc']['sucessaoVinc']['matricAnt'])
							dtTransf	:= If (Valtype(oInfoCompl['infoVinc']['sucessaoVinc']['dtTransf']) == "U",dtTransf,oInfoCompl['infoVinc']['sucessaoVinc']['dtTransf'])
							dtTransf	:= If(lMiddleware, dtTransf, Dtos(fJToD(dtTransf)) )
						EndIf

						//infoDeslig
						If oInfoCompl['infoVinc']['infoDeslig']:hasProperty("dtDeslig")
							dtDeslig	:= If (Valtype(oInfoCompl['infoVinc']['infoDeslig']['dtDeslig']) == "U",dtDeslig,oInfoCompl['infoVinc']['infoDeslig']['dtDeslig'])
							dtDeslig	:= If(lMiddleware, dtDeslig, Dtos(fJToD(dtDeslig)) )
							mtvDeslig 	:= oInfoCompl['infoVinc']['infoDeslig']['mtvDeslig']
							dtProjFimAPI	:= If (Valtype(oInfoCompl['infoVinc']['infoDeslig']['dtProjFimAPI']) == "U",dtProjFimAPI,oInfoCompl['infoVinc']['infoDeslig']['dtProjFimAPI'])
							dtProjFimAPI	:= If(lMiddleware, dtProjFimAPI, Dtos(fJToD(dtProjFimAPI)) )
							nPensAlim	:= If(Valtype(oInfoCompl['infoVinc']['infoDeslig']['pensAlim']) == "U", nPensAlim, oInfoCompl['infoVinc']['infoDeslig']['pensAlim'])
							nPercAlim	:= If(Valtype(oInfoCompl['infoVinc']['infoDeslig']['percAliment']) == "U", nPercAlim, oInfoCompl['infoVinc']['infoDeslig']['percAliment'])
							nVrAlim		:= If(Valtype(oInfoCompl['infoVinc']['infoDeslig']['vrAlim']) == "U", nVrAlim, oInfoCompl['infoVinc']['infoDeslig']['vrAlim'])
						EndIf
					EndIf

				Aadd(aInfoE0G,{;
						cCodCBO,; 						//1
						nnatAtiv,;   					//2
						dtRemun,;  						//3
						vrSalFx,;  						//4
						undSalFixo,;  					//5
						dscSalVar,;  					//6
						tpRegTrab,;  					//7
						tpRegPrev,;  					//8
						dtAdm,;  						//9
						tmpParc,;  						//10
						tpContr,;  						//11
						dtTermDur,;  					//12
						clauAssec,;						//13
						objDet ,;						//14
						observacao,;					//15
						tpInsc,;						//16
						nrInsc,;						//17
						matricAnt,;						//18
						dtTransf,;						//19
						dtDeslig,;						//20
						mtvDeslig,;						//21
						dtProjFimAPI,;					//22
						dtTerm,;						//23
						mtvDesligTSV,;	 				//24
						cIdVinculo,;					//25 IdE0B
						nPensAlim,;						//26 tags 1.2
						nPercAlim,;						//27
						nVrAlim })						//28
				lRet := .T.
			Endif
			E0G->(dbSkip())
		Enddo
	Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetE0G
Busca  dados na tabela E0G
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetE0GDep(cNumProces, cReclam, cIdVinculo)

Local cMemoDep  	:= ""
Local aDepMemo	:= {}
Local nI		:= 0

	If aScan(aInfoE0GDep, {|x| x[4] = cNumProces .And. x[5] = cReclam}) == 0     //Verifica se os dados do dependente externo, ja foram carregados no primeiro vinculos
		E0G->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC
		If E0G->( DbSeek(xFilial("E0G",cFilIn) + cNumProces + cReclam + cIdVinculo) )
			While !E0G->(Eof()) .And. (xFilial("E0G",cFilIn) == E0G->E0G_FILIAL .And. cNumProces == E0G->E0G_PRONUM .And. cIdVinculo == E0G->E0G_IDVINC )
				If E0G->E0G_TPINF == "1"      //infoCompl
					cMemoDep := MSMM(E0G->E0G_CMEM,,,,3,,,"E0G",,"RDY")
					If !Empty(cMemoDep)
						aDepMemo := StrTokArr( cMemoDep , '###' )
						For nI := 1 to Len(aDepMemo)
							aDep	:= StrTokArr( aDepMemo[nI] , '|' )
							aAdd(aInfoE0GDep, {aDep[2], aDep[1], IIf(Len(aDep) >= 3,aDep[3],""), cNumProces, cReclam })   //tpDep,cpfDep,descDep,cNumProces,cReclam
						Next nI
					EndIf
					Return aInfoE0GDep
				Endif
				E0G->(dbSkip())
			Enddo
		Endif
	Endif

Return aInfoE0GDep

//-------------------------------------------------------------------
/*/{Protheus.doc} function fJToD
Converte a data encontrada no json para o formato Date do Protheus
@author  martins.marcio
@since   25/10/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fJToD(cDateJson, cDtType)
	Local dRet := sToD("")
	DEFAULT cDateJson := ""
	DEFAULT cDtType	  := "D"

	dRet := IIf(cDtType =="D", sToD( StrTran( cDateJson, "-", "" ) ), StrTran( cDateJson, "-", "" ))

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetDep
Busca  dados na tabela E0D
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetDep(cCodUnic)

Local aArea			:= GetArea()
Local aDep			:= {}
Local cFilTrab		:= ""
Local cMatTrab      := ""

Default cCodUnic		:= ""

	If !Empty(cCodUnic)
		dbSelectArea("SRA")
		SRA->(DbSetOrder(24))
		If SRA->(MsSeek(cCodUnic))
			If (SRA->RA_CODUNIC == cCodUnic)
				cFilTrab := SRA->RA_FILIAL
				cMatTrab := SRA->RA_MAT
				If !Empty(cFilTrab) .And. !Empty(cMatTrab)
					aDep := fGM23Dep(cFilTrab, cMatTrab)
				Endif
			ENDIF
		Endif
	Endif

RestArea(aArea)

Return aDep


//-------------------------------------------------------------------
/*/{Protheus.doc} function fGetUnic
Busca  dados na tabela E0D
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function fGetUnic(cNProc, cRecl, cIdVinPrinc)

Local aAreaE0B		:= E0B->(GetArea())

Default cNProc		:= ""
Default cRecl		:= ""
Default cIdVinPrinc	:= ""

	E0B->(DbSetOrder(1)) // E0G_FILIAL+E0G_PRONUM+E0G_RECLAM+E0G_IDVINC
	If E0B->( DbSeek(xFilial("E0B",cFilIn) + cNProc + cRecl ) )
		While !E0B->(Eof()) .And. E0B->E0B_FILIAL == xFilial("E0B",cFilIn) .And. E0B->E0B_PRONUM == cNProc
			If E0B->E0B_FILIAL == xFilial("E0B",cFilIn) .And. E0B->E0B_PRONUM == cNProc .And. E0B->E0B_VININC == cIdVinPrinc
				AADD(aUnicid, { AllTrim(E0B->E0B_CODUNI), E0B->E0B_CATEFD, E0B->E0B_DTITSV, cIdVinPrinc })
			ENDIF
			E0B->(dbSkip())
		Enddo
	Endif

RestArea(aAreaE0B)

Return aUnicid

//-------------------------------------------------------------------
/*/{Protheus.doc} function fXml2500
Geração XML s2500
@author  Silvia Taguti
@since   04/11/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function fXml2500(cXml, cVersEnvio,lRetific)

Local nI		:= 0
Local nB		:= 0
Local nD		:= 0
Local nU		:= 0
Local nM		:= 0
Local lRet		:= .F.
Local cVersMw	:= ""
Local cTpAmb
Local nTpRegTrab := 0
Local cIdVinc	:= ""
Local nPosVinc	:= 0
Local cPensAlim	:= ""

Default lRetific := .F.

	//-------------------
	//| Inicio do XML
	//-------------------
	If lMiddleware
		fVersEsoc( "S2200", .T., /*aRetGPE*/, /*aRetTAF*/, , , @cVersMw, , @cTpAmb ) //lista do gpem017, adiciona ou
		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtProcTrab/v" + cVersMw + "'>"
		cXML += 	"<evtProcTrab Id='" + cIdXml + "'>"
		fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cTpAmb, 1, "12" } )
	Else
		cXml := "<eSocial>"
		cXml += '	<evtProcTrab>'
		If lRetific
			cXml += '		<ideEvento>'
			cXml += '			<indRetif>2</indRetif>
			cXml += '		</ideEvento>'
		Endif
	EndIf

	cXml += '		<ideEmpregador>'
	If lMiddleware
		cXml += '		<tpInsc>'+ cTpInsc +'</tpInsc>'
		cXml += '		<nrInsc>'+ Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) +'</nrInsc>'
	EndIf
	If !Empty(cTpResp) .And. !Empty(cNInscResp)
		cXml += '		<ideResp>'
		cXml += '			<tpInsc>'+cTpResp+'</tpInsc>'
		cXml += '			<nrInsc>'+cNInscResp+'</nrInsc>'
		If !Empty(cDtAdmResp)
			cXml += '			<dtAdmRespDir>'+ IIf(!lMiddleware, cDtAdmResp, SubStr(cDtAdmResp,1,4)+"-"+SubStr(cDtAdmResp,5,2)+"-"+SubStr(cDtAdmResp,7,2)) + '</dtAdmRespDir>'
		EndIf
		If !Empty(cMatRespD)
			cXml += '			<matRespDir>'+ AllTrim(cMatRespD) +'</matRespDir>'
		EndIf
		cXml += '		</ideResp>'
	Endif
	cXml += '		</ideEmpregador>'

	cXml +=	'		<infoProcesso>'
	cXml +=	'			<origem>'+cOrigem+'</origem>'
	cXml +=	'			<nrProcTrab>'+Alltrim(cProJud)+'</nrProcTrab>'
	If !lMiddleware .Or. !Empty(cObsProc)
		cXml +=	'			<obsProcTrab>'+fSubstRH(cObsProc)+'</obsProcTrab>'
	EndIf

	cXml +=	'			<dadosCompl>'
	If cOrigem == "1"
		cXml +=	'				<infoProcJud>'
		cXml +=	'					<dtSent>'+ If(!lMiddleware, cdtSent, SubStr(cDtSent,1,4)+"-"+SubStr(cDtSent,5,2)+"-"+SubStr(cDtSent,7,2)) +'</dtSent>'

		If Len(aInfoRE1) > 0
			cXml +=	'				<ufVara>'+ aInfoRE1[1,1] +'</ufVara>'
			cXml +=	'				<codMunic>' + Iif(lMiddleware, fEstIBGE(aInfoRE1[1,1]), "") + aInfoRE1[1,2] + '</codMunic>'
			cXml +=	'				<idVara>'+ AllTrim(aInfoRE1[1,3]) +'</idVara>'
		Endif
		cXml +=	'				</infoProcJud>'
	Else
		cXml +=	'				<infoCCP>'
		cXml +=	'					<dtCCP>'+ cdtCCP+ '</dtCCP>'
		cXml +=	'					<tpCCP>'+ tpCCP+'</tpCCP>'
		cXml +=	'					<cnpjCCP>'+cnpjCCP+'</cnpjCCP>'
		cXml +=	'				</infoCCP>'
	EndIf
	cXml +=	'			</dadosCompl>'

	cXml +=	'		</infoProcesso>'
	cXml +=	'		<ideTrab>'
	cXml +=	'			<cpfTrab>' +ccpfTrab+ '</cpfTrab>'
	cXml +=	'			<nmTrab>' + AllTrim(cNomeTrab) + '</nmTrab>'
	cXml +=	'			<dtNascto>' + If(!lMiddleware, dDtNasc, SubStr(dDtNasc,1,4)+"-"+SubStr(dDtNasc,5,2)+"-"+SubStr(dDtNasc,7,2)) + '</dtNascto>'
	If cVersEnvio >= "9.3" .And. lIdSqPr .And. !Empty(cIdSqPr)
		cXml +=	'			<ideSeqTrab>' + AllTrim(cIdSqPr) + '</ideSeqTrab>'
	EndIf
	If Len(aInfoDep) > 0
		For nI:= 1 To Len(aInfoDep)
			cXml +=	'			<dependente>'
			cXml +=	'				<cpfDep>'+ aInfoDep[nI,4]	+'</cpfDep>'
			cXml +=					fTpDep(aInfoDep[nI],cVersEnvio)
			If aInfoDep[nI,1] == '13'
				cXml +=	'				<descDep>'+ aInfoDep[nI,2]+ '</descDep>'
			Endif
			cXml +=	'			</dependente>'
		Next nI
	Endif

	If Len(aInfoE0G) > 0 .And. Len(aInfoE0GDep) > 0
		For nI:= 1 To Len(aInfoE0GDep)
			cXml +=	'			<dependente>'
			cXml +=	'				<cpfDep>'+ aInfoE0GDep[nI,2]+'</cpfDep>'
			cXml +=					fTpDep(aInfoE0GDep[nI],cVersEnvio)
			If aInfoE0GDep[nI,1]=='13'
				cXml +=	'				<descDep>'+ aInfoE0GDep[nI,3]+ '</descDep>'
			Endif
			cXml +=	'			</dependente>'
		Next nI
	Endif

	If Len(aInfoE0B) > 0
		For nB:= 1 To Len(aInfoE0B)
			cIdVinc := aInfoE0B[nB,3]
			cXml +=	'			<infoContr>'
			cXml +=	'				<tpContr>'+ aInfoE0B[nB,5]+ '</tpContr>'
			cXml +=	'				<indContr>'+ aInfoE0B[nB,6]+ '</indContr>'
			// Preencher quando tpContr = 2/4 e  indContr = N
			If aInfoE0B[nB,5] $ "2|4" .And. aInfoE0B[nB,6] $ "N|2"
				cXml +=	'				<dtAdmOrig>'+ If(!lMiddleware, aInfoE0B[nB,7], SubStr(aInfoE0B[nB,7],1,4)+"-"+SubStr(aInfoE0B[nB,7],5,2)+"-"+SubStr(aInfoE0B[nB,7],7,2)) + '</dtAdmOrig>'
			Endif
			// Preencher quando tpContr <> 6 e  indContr = S
			If aInfoE0B[nB,5] <> "6" .And. aInfoE0B[nB,6] $ "S|1"
				cXml +=	'				<indReint>'+ aInfoE0B[nB,8]+ '</indReint>
			Endif
			cXml +=	'				<indCateg>'+ aInfoE0B[nB,9]+ '</indCateg>'
			cXml +=	'				<indNatAtiv>'+ aInfoE0B[nB,10]+ '</indNatAtiv>'
			cXml +=	'				<indMotDeslig>'+ aInfoE0B[nB,11]+ '</indMotDeslig>'
			cXml +=	'				<matricula>'+ AllTrim(aInfoE0B[nB,13]) + '</matricula>'
			//tpcontr = N ou matricula nao preenchida
			If aInfoE0B[nB,6] $ "N|2" .Or. Empty(aInfoE0B[nB,13])
				cXml +=	'				<codCateg>'+ aInfoE0B[nB,14]+ '</codCateg>
			Endif
			//Preencher quando tpcontr == 6 e indcontr == N
			If (aInfoE0B[nB,5] == "6" .And.  aInfoE0B[nB,6] $ "N|2") .Or. Empty(aInfoE0B[nB,13])
				cXml +=	'				<dtInicio>'+ If(!lMiddleware, Dtos(aInfoE0B[nB,15]), SubStr(Dtos(aInfoE0B[nB,15]),1,4)+"-"+SubStr(Dtos(aInfoE0B[nB,15]),5,2)+"-"+SubStr(Dtos(aInfoE0B[nB,15]),7,2)) + '</dtInicio>'
			Endif

			If Len(aInfoE0G) > 0 .And. aInfoE0B[nB,6] $ "N|2" .And. ( nPosVinc := aScan(aInfoE0G, {|x| x[25] == cIdVinc }) ) > 0
				cXml +=	'				<infoCompl>'
				cXml +=	'					<codCBO>' + aInfoE0G[nPosVinc,1]+ '</codCBO>'
				If aInfoE0G[nPosVinc,2] > 0
					cXml +=	'					<natAtividade>'+ cValToChar(aInfoE0G[nPosVinc,2])+ '</natAtividade>'
				EndIf
				nTpRegTrab	:= aInfoE0G[nPosVinc,7]
				If !(aInfoE0B[nB,5] <> "6" .And. nTpRegTrab == 2) //Não gerar conforme tpContr+tpRegTrab
					cXml +=	'					<remuneracao>'
					cXml +=	'						<dtRemun>' + aInfoE0G[nPosVinc,3]+ '</dtRemun>'
					cXml +=	'						<vrSalFx>' + cValToChar(aInfoE0G[nPosVinc,4])+ '</vrSalFx>'
					cXml +=	'						<undSalFixo>' + cValToChar(aInfoE0G[nPosVinc,5])+ '</undSalFixo>'
					cXml +=	'						<dscSalVar>' + fSubstRH(aInfoE0G[nPosVinc,6])+ '</dscSalVar>'
					cXml +=	'					</remuneracao>'
				EndIf
				If aInfoE0B[nB,5] <> "6" .And. nTpRegTrab > 0 .And. aInfoE0G[nPosVinc,8] > 0 .And. !Empty(aInfoE0G[nPosVinc,9])
					cXml +=	'					<infoVinc>'
					cXml +=	'						<tpRegTrab>' + cValToChar(nTpRegTrab) + '</tpRegTrab>'
					cXml +=	'						<tpRegPrev>' + cValToChar(aInfoE0G[nPosVinc,8])+ '</tpRegPrev>'
					cXml +=	'						<dtAdm>'+ aInfoE0G[nPosVinc,9]+ '</dtAdm>'
					If nTpRegTrab == 1
						If aInfoE0G[nPosVinc,10] >= 0
							cXml +=	'						<tmpParc>' + cValToChar(aInfoE0G[nPosVinc,10])+ '</tmpParc>'
						EndIf
						If aInfoE0G[nPosVinc,11] > 0
							cXml +=	'						<duracao>'
							cXml +=	'							<tpContr>' + cValToChar(aInfoE0G[nPosVinc,11])+ '</tpContr>'
							If 	aInfoE0G[nPosVinc,11] == 2
								cXml +=	'							<dtTerm>' + aInfoE0G[nPosVinc,12]+ '</dtTerm>'
							Endif
							If 	cValToChar(aInfoE0G[nPosVinc,11]) $ "2|3"
								cXml +=	'							<clauAssec>' + aInfoE0G[nPosVinc,13]+ '</clauAssec>'
							EndIf
							If 	aInfoE0G[nPosVinc,11] == 3
							cXml +=	'							<objDet>' +aInfoE0G[nPosVinc,14]+ '</objDet>'
							EndIf
							cXml +=	'						</duracao>'
						EndIf
					EndIf
					If !lMiddleware .Or. !Empty(aInfoE0G[nPosVinc,15])
						cXml +=	'						<observacoes>'
						cXml +=	'							<observacao>'+ fSubstRH(aInfoE0G[nPosVinc,15])+ '</observacao>'
						cXml +=	'						</observacoes>'
					EndIf
					If !lMiddleware .Or. aInfoE0G[nPosVinc,16] > 0
						cXml +=	'						<sucessaoVinc>'
						cXml +=	'							<tpInsc>'+ cValToChar(aInfoE0G[nPosVinc,16])+ '</tpInsc>'
						cXml +=	'							<nrInsc>'+ aInfoE0G[nPosVinc,17]+ '</nrInsc>'
						cXml +=	'							<matricAnt>'+ aInfoE0G[nPosVinc,18]+ '</matricAnt>'
						cXml +=	'							<dtTransf>'+ aInfoE0G[nPosVinc,19]+ '</dtTransf>'
						cXml +=	'						</sucessaoVinc>'
					EndIf
					cXml +=	'						<infoDeslig>'
					cXml +=	'							<dtDeslig>'+ aInfoE0G[nPosVinc,20]+ '</dtDeslig>'
					cXml +=	'							<mtvDeslig>'+ aInfoE0G[nPosVinc,21]+ '</mtvDeslig>'
					If !lMiddleware .Or. !Empty(aInfoE0G[nPosVinc,22])
						cXml +=	'						<dtProjFimAPI>'+ aInfoE0G[nPosVinc,22]+ '</dtProjFimAPI>'
					EndIf
					If nTpRegTrab == 1
						If aInfoE0G[nPosVinc,26] >= 0
							cPensAlim := cValToChar(aInfoE0G[nPosVinc,26])
							cXml +=	'						<pensAlim>' + cPensAlim + '</pensAlim>' //0~3
						EndIf
						If cPensAlim $ "1|3" .And. aInfoE0G[nPosVinc,27] > 0
							cXml +=	'					<percAliment>' + AllTrim(Transform(aInfoE0G[nPosVinc,27], "@R 999.99")) + '</percAliment>'
						EndIf
						If cPensAlim $ "2|3" .And. aInfoE0G[nPosVinc,28] > 0
							cXml +=	'					<vrAlim>' + AllTrim(Transform(aInfoE0G[nPosVinc,28], "@R 999999999999.99") ) + '</vrAlim>'
						EndIf
					EndIf
					cXml +=	'						</infoDeslig>'
					cXml +=	'					</infoVinc>'
				EndIf
				If aInfoE0B[nB,5] == "6" .And. !Empty(aInfoE0G[nPosVinc,23])
					cXml +=	'					<infoTerm>'
					cXml +=	'						<dtTerm>'+ aInfoE0G[nPosVinc,23]+ '</dtTerm>'
					cXml +=	'						<mtvDesligTSV>'+ aInfoE0G[nPosVinc,24]+ '</mtvDesligTSV>'
					cXml +=	'					</infoTerm>'
				EndIf
				cXml +=	'				</infoCompl>'
			Endif
			If Len(aInfoE0A) > 0 .And. (aInfoE0B[nB,9] == 'S' .Or. aInfoE0B[nB,10] == 'S')  .And. ( nPosVinc := aScan(aInfoE0A, {|x| x[3] == cIdVinc }) ) > 0 //Reconhecimento da atividade
				cXml +=	'				<mudCategAtiv>'
				cXml +=	'					<codCateg>'+ aInfoE0A[nPosVinc,9]+ '</codCateg>'
				If !("-" $ aInfoE0A[nPosVinc,10])
					cXml +=	'					<natAtividade>'+ aInfoE0A[nPosVinc,10]+ '</natAtividade>'
				EndIf
				cXml +=	'					<dtMudCategAtiv>'+ If(!lMiddleware, Dtos(aInfoE0A[nPosVinc,8]), SubStr(Dtos(aInfoE0A[nPosVinc,8]),1,4)+"-"+SubStr(Dtos(aInfoE0A[nPosVinc,8]),5,2)+"-"+SubStr(Dtos(aInfoE0A[nPosVinc,8]),7,2)) + '</dtMudCategAtiv>'
				cXml +=	'				</mudCategAtiv>'
			Endif
			If Len(aUnicid) > 0 .And. (aInfoE0B[nB,5] == '9') .And. ( nU := aScan(aUnicid, {|x| x[4] == cIdVinc }) ) > 0	//Unicidade de contrato 1.1: E0B_INDUNI=S / 1.2: E0B_TPCONT=9
				While nU <= Len(aUnicid) .And. aUnicid[nU,4] == cIdVinc
					cXml +=	'				<unicContr>'
					If !lmiddleware .Or. !Empty(aUnicid[nU,1])
						cXml +=	'					<matUnic>'+aUnicid[nU,1]+'</matUnic>
					EndIf
					If Empty(aUnicid[nU,1])
						cXml +=	'						<codCateg>'+aUnicid[nU,2]+'</codCateg>'
						cXml +=	'						<dtInicio>'+ If(!lMiddleware, Dtos(aUnicid[nU,3]), SubStr(Dtos(aUnicid[nU,3]),1,4)+"-"+SubStr(Dtos(aUnicid[nU,3]),5,2)+"-"+SubStr(Dtos(aUnicid[nU,3]),7,2)) +'</dtInicio>'
					Endif
					cXml +=	'				</unicContr>'
					nU++
				EndDo
			Endif
			If Len(aInfoE0C) >= nB .And. aInfoE0C[nB,1] == cIdVinc//E0C
				cXml +=	'				<ideEstab>'
				cXml +=	'					<tpInsc>'+ aInfoE0C[nB,2] + '</tpInsc>'
				cXml +=	'					<nrInsc>'+ aInfoE0C[nB,3] + '</nrInsc>'
				cXml +=	'					<infoVlr>'
				cXml +=	'						<compIni>' + If( !lMiddleware, aInfoE0C[nB,4], SubStr(aInfoE0C[nB,4],1,4) + "-" + SubStr(aInfoE0C[nB,4],5,2) ) + '</compIni>'
				cXml +=	'						<compFim>' + If( !lMiddleware, aInfoE0C[nB,5], SubStr(aInfoE0C[nB,5],1,4) + "-" + SubStr(aInfoE0C[nB,5],5,2) ) + '</compFim>'

				cXml += '					<indReperc>' + aInfoE0C[nB,6] + '</indReperc>'
				If aInfoE0C[nB,13] == "S"
					cXml += '				<indenSD>' + aInfoE0C[nB,13] + '</indenSD>'
				EndIf
				If aInfoE0C[nB,14] == "S"
					cXml += '				<indenAbono>' + aInfoE0C[nB,14] + '</indenAbono>'
					For nI := 1 to Len(aInfoE0C[nB,15])
						cXml += '			<abono>'
						cXml += '				<anoBase>' + aInfoE0C[nB,15,nI] + '</anoBase>'
						cXml += '			</abono>'
					Next nI
				EndIf

				If Len(aInfoE0D) > 0 .And. ( nD := aScan(aInfoE0D, {|x| x[14]+x[1]+x[2] == cIdVinc + aInfoE0C[nB,2] + aInfoE0C[nB,3] }) ) > 0
					While nD <= Len(aInfoE0D) .And. aInfoE0D[nD,14] == cIdVinc
						cXml +=	'				<idePeriodo>'
						cXml +=	'					<perRef>' + If( !lMiddleware, aInfoE0D[nD,3], SubStr(aInfoE0D[nD,3],1,4) + "-" + SubStr(aInfoE0D[nD,3],5,2) ) + '</perRef>'
						cXml +=	'					<baseCalculo>'
						cXml +=	'						<vrBcCpMensal>'+AllTrim(Transform(aInfoE0D[nD,5], "@R 999999999.99") )+ '</vrBcCpMensal>'
						If aInfoE0D[nD,6] > 0
							cXml +=	'						<vrBcCp13>'+AllTrim(Transform(aInfoE0D[nD,6], "@R 999999999.99") )+ '</vrBcCp13>'
						EndIf

						If !("-" $ aInfoE0D[nD,4]) .And. Val(aInfoE0D[nD,4]) > 0
							cXml +=	'						<infoAgNocivo>'
							cXml +=	'							<grauExp>'+aInfoE0D[nD,4]+'</grauExp>'
							cXml +=	'						</infoAgNocivo>'
						EndIF
						cXml +=	'					</baseCalculo>'
						If aInfoE0D[nD,15] > 0 .Or. aInfoE0D[nD,9] > 0
							cXml +=	'					<infoFGTS>'
							cXml +=	'					<vrBcFGTSProcTrab>' + AllTrim(Transform(aInfoE0D[nD,15], "@R 999999999.99") ) + '</vrBcFGTSProcTrab>'	//E0D_FGTSPR
							If aInfoE0D[nD,16] > 0
								cXml +=	'				<vrBcFGTSSefip>' + AllTrim(Transform(aInfoE0D[nD,16], "@R 999999999.99") ) + '</vrBcFGTSSefip>'
							EndIf
							If aInfoE0D[nD,17] > 0
								cXml +=	'				<vrBcFGTSDecAnt>' + AllTrim(Transform(aInfoE0D[nD,17], "@R 999999999.99") ) + '</vrBcFGTSDecAnt>'
							EndIf
							cXml +=	'					</infoFGTS>'
						EndIf
						If aInfoE0B[nB,9] == "S"
							cXml +=	'				<baseMudCateg>'
							cXml +=	'					<codCateg>'+aInfoE0D[nD,12]+'</codCateg>'
							cXml +=	'					<vrBcCPrev>'+AllTrim(Transform(aInfoE0D[nD,13], "@R 999999999.99") )+'</vrBcCPrev>'
							cXml +=	'				</baseMudCateg>'
						EndIf
						If !Empty(aInfoE0D[nD,18]) // Em versão < 9.3 estará sempre vazio
							cXml +=	'				<infoInterm>'
							For nM := 1 To Len(aInfoE0D[nD,18])
								cXml +=	'					<dia>'+cValToChar(aInfoE0D[nD,18,nM]['dia'])+'</dia>'
								If !Empty(aInfoE0D[nD,18,nM]['hrsTrab'])
									cXml +=	'					<hrsTrab>'+aInfoE0D[nD,18,nM]['hrsTrab']+'</hrsTrab>'
								EndIf
							Next nM
							cXml +=	'				</infoInterm>'
						EndIf
						cXml +=	'				</idePeriodo>'
						nD++
					EndDo
				Endif
				cXml +=	'					</infoVlr>'
				cXml +=	'				</ideEstab>'
			Endif
			cXml +=	'			</infoContr>'
		Next nB
	Endif

	cXml +=	'		</ideTrab>'
	cXml +=	'	</evtProcTrab>'
	cXml += '</eSocial>'

	//-------------------
	//| Final do XML
	//-------------------
	If !Empty(cXml)
		GrvTxtArq(alltrim(cXml), "S2500",ccpfTrab)
		lRet := .T.
	Endif
Return lRet
