#Include 'Protheus.ch'
#Include 'GPEM038.ch'

Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )

/*/{Protheus.doc} GPEM038B
@Author   isabel.noguti
@Since    21/11/2022
@Version  1.0
/*/
Function GPEM038B()
Return()

/*/{Protheus.doc} fNew2501
Função responsável por gerar o evento S-2501 - Informações de Tributos Decorrentes de Processo Trabalhista
@Author.....: isabel.noguti
@Since......: 18/11/2022
@Version....: 1.0
/*/
Function fNew2501( dDataIni, aArrayFil, lRetific, aLogsOk, aLogsErr )
	Local aErrTaf		:= {}
	Local cAliasQry		:= GetNextAlias()
	Local cChaveE0F		:= ""
	Local cChaveE0I		:= ""
	Local cFilEnv		:= ""
	Local cIdLog		:= ""
	Local cOldProc		:= ""
	Local cOldIdSeq		:= ""
	Local cProJud		:= ""
	Local cIdSeq		:= ""
	Local cPerAp		:= ""
	Local cQuery		:= ""
	Local cStatus		:= "-1"
	Local cXml			:= ""
	Local lRet			:= .F.
	Local lRetXml		:= .F.
	Local nFil		 	:= 0
	Local nCont			:= 0
	Local lProcessa		:= .F.
	Local lRetif		:= .F.
	Local cMsgErr		:= ""
	Local aDadosE0E		:= {}
	Local aDadosE0H		:= {}
	Local aIdeTrab		:= {}
	Local aInfoIR		:= {}
	Local aSubCRIR		:= {}
	Local aInfoBs		:= {}
	Local aTribPer		:= {}
	Local cObs			:= ""
	Local cCodMemo		:= ""
	Local aInfoC		:= {}
	Local cStatPred		:= "-1"
	Local cRjeKey		:= ""
	Local cChaveMid		:= ""
	Local lNovoRJE		:= .T.
	Local cOperEvt		:= "I"
	Local cOperNew		:= "I"
	Local cRetfEvt		:= "1"
	Local cRecibEvt		:= ""
	Local cRecibAnt		:= ""
	Local nRecEvt		:= 0
	Local aDadosRJE		:= {}
	Local cTafKey		:= ""
	Local aIRCompl		:= {}
	Local nZ			:= 0
	Local cFilInBkp		:= ""
	Local cProcExe		:= ""
	Local cIdSeqProc	:= ""
	Local lTAFS13		:= V7C->(ColumnPos("V7C_IDESEQ")) > 0
	Local lGPES13		:= ChkFile("E0H")
	Local nTamIdSeq		:= 0
	Local cStat2555		:= "-1"
	Local oStat1		:= Nil //Query para buscar os processo

	Private cTpInsc		:= ""
	Private cNrInsc		:= ""
	Private lAdmPubl	:= .F.
	Private cIdXml		:= ""
	Private cRetfNew	:= "1"
	Private cRecibXML	:= ""

	Default dDataIni	:= CtoD("")
	Default aArrayFil	:= {}
	Default lRetific	:= .F.
	Default aLogsOk		:= {}
	Default aLogsErr	:= {}

	//Verifica se as atualizações de dicionário estão aplicadas no ambiente
	If cVersEnvio >= "9.3"
		If !lGPES13
			cMsgErr := OemToAnsi(STR0063)//"Ambiente GPE desatualizado para geração do evento no leiaute S-1.3, atualize o ambiente com a expedição contínua. "
		EndIf
		If !lMiddleware .And. !lTAFS13
			cMsgErr += OemToAnsi(STR0064)//"Verifique se o ambiente do TAF está atualizado."
		EndIf
	EndIf

	//Interrompe execução do evento S-2501 caso o ambiente não esteja atualizado
	If !Empty(cMsgErr)
		aAdd( aLogsErr, cMsgErr )
		Return
	EndIf

	//Tamanho do campo id sequencia
	If cVersEnvio >= "9.3"
		nTamIdSeq := FwTamSX3("E0H_IDSQPR")[1]
	EndIf

	cCpfDe	:= If( Empty(cCpfDe), '0', cCpfDe )
	cProcDe := If( Empty(cProcDe), '0', cProcDe )
	cPerAp	:= AnoMes(dDataIni)

	For nFil := 1 To Len(aArrayFil)
		cProcExe := ""
		For nZ := 1 To Len(aArrayFil[nFil][3])
			cFilIn	:= xFilial("RE0", aArrayFil[nFil][3][nZ])
			cFilEnv	:= aArrayFil[nFil][1]

			//Caso já tenha processado registros da filial
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
				If cVersEnvio >= "9.3"
					cQuery := "SELECT E0H.E0H_PRONUM PRONUM, E0H.E0H_RECLAM RECLAM, E0H.E0H_CMEM CMEM, E0H.E0H_COMPET COMPET, E0H.E0H_IDSQPR IDSQPR, E0H.E0H_BSINSS BSINSS, E0H.E0H_BS13 BS13, RE0.RE0_PROJUD, RD0.RD0_CIC "
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
					cQuery += "ORDER BY RE0.RE0_PROJUD, E0H.E0H_RECLAM, E0H.E0H_IDSQPR, E0H.E0H_COMPET"
				Else
					cQuery := "SELECT E0E.E0E_PRONUM PRONUM, E0E.E0E_RECLAM RECLAM, E0E.E0E_CMEM CMEM, E0E.E0E_COMPET COMPET, E0E.E0E_BSINSS BSINSS, E0E.E0E_BS13 BS13, E0E.E0E_RDIRRF, E0E.E0E_RDIR13, RE0.RE0_PROJUD, RD0.RD0_CIC "
					cQuery += "FROM " + RetSqlName('E0E') + " E0E "
					cQuery += "INNER JOIN " + RetSqlName('RE0') + " RE0 ON " + FwJoinFilial("E0E","RE0") + " AND E0E.E0E_PRONUM=RE0.RE0_NUM "
					cQuery += "LEFT JOIN " + RetSqlName('RD0') + " RD0 ON " + FwJoinFilial("E0E","RD0") + " AND E0E.E0E_RECLAM=RD0.RD0_CODIGO " //observ
					cQuery += "WHERE E0E.E0E_FILIAL IN ( ? ) "
					cQuery +=	"AND E0E.E0E_PERAP = ? "
					cQuery += 	"AND E0E.E0E_PRONUM IN (SELECT RE0.RE0_NUM "
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
					cQuery += 	"AND E0E.D_E_L_E_T_ = ' ' "
					cQuery +=   "AND RD0.D_E_L_E_T_ = ' ' "
					cQuery +=   "AND RE0.D_E_L_E_T_ = ' ' "
					cQuery += "ORDER BY RE0.RE0_PROJUD, E0E.E0E_RECLAM, E0E.E0E_COMPET "
				EndIf
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

				If cVersEnvio >= "9.3"
					cIdSeq := (cAliasQry)->IDSQPR
				EndIf

				If !(((cAliasQry)->RE0_PROJUD + cIdSeq) $ cProcExe)
					lRet 		:= .T.
					cObs		:= ""
					cCodMemo	:= ""
					lProcessa	:= .T.
					cOldProc	:= (cAliasQry)->RE0_PROJUD
					If cVersEnvio >= "9.3"
						cOldIdSeq	:= (cAliasQry)->IDSQPR
					EndIf
					cProcExe	+= cOldProc + cOldIdSeq + "|"
					cIdLog		:= " - " + STR0042 + cOldProc //" - Processo: ###"
					cStat2555	:= "-1"

					//Incrementa o Id no log de geração e deixa zerado caso o valor seja -1
					If cVersEnvio >= "9.3"
						If cOldIdSeq > "0"
							cIdLog += OemToAnsi(STR0062) + cOldIdSeq //" - Id. Sequência: "
						Else
							cOldIdSeq := space(nTamIdSeq)
						EndIF

						//Consulta o status do evento S-2555
						If lMiddleware
							cRjeKey		:= cFilEnv + cOldProc + cPerAp + "S2555"
							cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2555" + Padr(cRjeKey, 40, " ")
							//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
							GetInfRJE( 2, cChaveMid, @cStat2555 )
						Else
							//T8I_FILIAL+T8I_NRPROC+T8I_PERAPU+T8I_ATIVO 4
							cStat2555 	:= TAFGetStat( "S-2555", PadR(cOldProc,20) + ";" + cPerAp, cEmpAnt, cFilEnv, 4 )
						EndIf
						//Não gera evento S-2501 se localizou algum S-2555
						If cStat2555 <> "-1"
							aAdd(aLogsErr, cIdLog )
							aAdd(aLogsErr, OemToAnsi(STR0084)) //"Não é permitido gerar o evento S-2501 se houver evento S-2555 com mesmo Número de Processo e Período de Apuração consolidado."
							aAdd(aLogsErr, OemToAnsi(STR0085)) //"O evento S-2555 deverá ser excluído para que o evento S-2501 possa ser gerado."
							aAdd(aLogsErr, "" )
							lProcessa := .F.
							(cAliasQry)->(DbSkip())
							Loop
						EndIf
					EndIf

					If lMiddleware

						lNovoRJE	:= .T.
						cStatus		:= "-1"
						cOperNew 	:= "I"
						cRetfNew	:= "1"
						nRecEvt		:= 0
						cRecibEvt	:= ""
						cRecibAnt	:= ""

						cRjeKey		:= Padr( cFilEnv + cOldProc + cPerAp + cOldIdSeq, fTamRJEKey(), " ")
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2501" + cRjeKey + cPerAp
						GetInfRJE( 2, cChaveMid, @cStatus, @cOperEvt, @cRetfEvt, @nRecEvt, @cRecibEvt, @cRecibAnt )

						If cStatus $ "1/3"
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
					Else
						If cVersEnvio >= "9.3" .And. cOldIdSeq > "0"
							cStatus := TAFGetStat( "S-2501", PadR(cOldProc,20) + ";" + cPerAp + ";" + cOldIdSeq, cEmpAnt, cFilEnv, 7 )//V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_IDESEQ+V7C_ATIVO uso do indice 7 já que padrão da rotina manda indice 2
						Else
							cStatus := TAFGetStat( "S-2501", PadR(cOldProc,20) + ";" + cPerAp, cEmpAnt, cFilEnv, 5 )//V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_ATIVO já que padrão da rotina manda indice 2
						EndIf
					EndIf

					cMsgErr	:= If(!lRetific .And. (cStatus == "4" .Or. cRetfNew == "2"), OemToAnsi(STR0044), "")	//"Evento ja foi integrado anteriormente, selecione a opção de retificação "
					cMsgErr	:= If(cStatus == "2", OemToAnsi(STR0048), cMsgErr )				//"aguardando retorno do governo
					If !Empty(cMsgErr)
						lProcessa := .F.
						aAdd(aLogsErr, cIdLog + " - " + cMsgErr)
						(cAliasQry)->(DbSkip())
						Loop
					EndIf

					lRetif		:= If(cStatus == "4", lRetific, .F.)
					cProJud		:= AllTrim((cAliasQry)->RE0_PROJUD)
					If cVersEnvio >= "9.3"
						cIdSeqProc	:= AllTrim((cAliasQry)->IDSQPR)
					EndIf
				EndIf
				If lProcessa

					//Procura a observação do processo
					If cVersEnvio >= "9.3"
						cCodMemo	:= Posicione("E0H", 2, xFilial("E0H") + (cAliasQry)->PRONUM  + "OBSERV" + cPerAp + (cAliasQry)->IDSQPR, "E0H_CMEM")
						cObs 		:= AllTrim(MSMM(cCodMemo,,,,3,,,"E0H",,"RDY"))
					Else
						DbSelectArea("E0E")
						cCodMemo 	:= Posicione("E0E", 1, xFilial("E0E") + (cAliasQry)->PRONUM  + "OBSERV" + cPerAp, "E0E_CMEM")
						cObs 		:= AllTrim(MSMM(cCodMemo,,,,3,,,"E0E",,"RDY"))
					EndIf

					If !(cAliasQry)->RECLAM == "OBSERV"
						If aScan(aIdeTrab, {|x| x == (cAliasQry)->RD0_CIC }) == 0
							Aadd(aIdeTrab, (cAliasQry)->RD0_CIC	)

							If cVersEnvio >= "9.3"
								cChaveE0I := cFilIn + (cAliasQry)->PRONUM + (cAliasQry)->RECLAM + cPerAp  + "999999" + (cAliasQry)->IDSQPR + "1"	//infoCRIRRF
								DbSelectArea("E0I")
								E0I->(DbSetOrder(2)) //E0I_FILIAL+E0I_PRONUM+E0I_RECLAM+E0I_PERAP+E0I_COMPET+E0I_IDSQPR+E0I_TIPO+E0I_TPCR+E0I_IDTRIB
								If E0I->( dbSeek(cChaveE0I))
									While E0I->( E0I_FILIAL + E0I_PRONUM + E0I_RECLAM + E0I_PERAP + E0I_COMPET + E0I_IDSQPR + E0I_TIPO) == cChaveE0I
										aSubCRIR := {}
										If !Empty(E0I->E0I_CMEM)
											aSubCRIR := fGetCRIR( MSMM(E0I->E0I_CMEM,,,,3,,,"E0I",,"RDY"))
										EndIf

										aAdd(aInfoIR, {	(cAliasQry)->RD0_CIC		,;//1- cpfTrab
														E0I->E0I_TPCR				,;//2- tpCR
														AllTrim(Str(E0I->E0I_VRCR))	,;//3- vrCR
														aSubCRIR					})//4- subgrupos infoCRIRRF 1.3

										E0I->( dbSkip())
									End
								EndIf
							Else
								cChaveE0F := cFilIn + (cAliasQry)->PRONUM + (cAliasQry)->RECLAM + cPerAp + "999999" + "1"	//infoCRIRRF
								DbSelectArea("E0F")
								E0F->(DbSetOrder(2)) //E0F_FILIAL+E0F_PRONUM+E0F_RECLAM+E0F_PERAP+E0F_COMPET+E0F_TIPO+E0F_TPCR
								If E0F->( dbSeek(cChaveE0F))
									While E0F->( E0F_FILIAL + E0F_PRONUM + E0F_RECLAM + E0F_PERAP + E0F_COMPET + E0F_TIPO) == cChaveE0F
										aSubCRIR := {}
										If cVersEnvio >= "9.2" .And. !Empty(E0F->E0F_CMEM)
											aSubCRIR := fGetCRIR( MSMM(E0F->E0F_CMEM,,,,3,,,"E0F",,"RDY"))
										EndIf

										aAdd(aInfoIR, {	(cAliasQry)->RD0_CIC		,;//1- cpfTrab
														E0F->E0F_TPCR				,;//2- tpCR
														AllTrim(Str(E0F->E0F_VRCR))	,;//3- vrCR
														aSubCRIR					})//4- subgrupos infoCRIRRF 1.2
										E0F->( dbSkip())
									End
								EndIf
							EndIf
						EndIf

						If (cAliasQry)->COMPET == "999999"//infoIRComplem
							IF cVersEnvio >= "9.2" .And. !Empty((cAliasQry)->CMEM)
								aAdd(aIRCompl, {(cAliasQry)->RD0_CIC											,;//1- cpf
									fGetIRComp( MSMM((cAliasQry)->CMEM,,,,3,,, If(cVersEnvio >= "9.3", "E0H", "E0E"),,"RDY") )	})//2- infoIRComplem/infoDep
							EndIf
						ElseIf cVersEnvio >= "9.3"
							If aScan(aDadosE0H, {|x| x[1]+x[2]+x[7] == (cAliasQry)->RD0_CIC + (cAliasQry)->COMPET + (cAliasQry)->IDSQPR }) == 0	//calcTrib
								Aadd(aDadosE0H, {	(cAliasQry)->RD0_CIC				,;//1- cpfTrab
													(cAliasQry)->COMPET					,;//2- perRef
													AllTrim(Str((cAliasQry)->BSINSS))	,;//3- bsMensal
													AllTrim(Str((cAliasQry)->BS13))		,;//4- bs13
													0,;//5- rendIR
													0,;//6- rendIR13
													(cAliasQry)->IDSQPR})//7- ideSeqProc

								cChaveE0I := cFilIn + (cAliasQry)->PRONUM + (cAliasQry)->RECLAM + cPerAp + (cAliasQry)->COMPET + (cAliasQry)->IDSQPR + "2" //infoCRContrib
								DbSelectArea("E0I")
								If E0I->( dbSeek(cChaveE0I))
									While E0I->( E0I_FILIAL + E0I_PRONUM + E0I_RECLAM + E0I_PERAP + E0I_COMPET + E0I_IDSQPR + E0I_TIPO ) == cChaveE0I
										aAdd(aInfoBs, {	(cAliasQry)->RD0_CIC		,;//1- cpf
														(cAliasQry)->COMPET			,;//2- perRef
														E0I->E0I_TPCR				,;//3- tpCR
														AllTrim(Str(E0I->E0I_VRCR))	})//4- vrCR
										E0I->( dbSkip())
									End
								EndIf
							EndIf
						Else
							If aScan(aDadosE0E, {|x| x[1]+x[2] == (cAliasQry)->RD0_CIC + (cAliasQry)->COMPET }) == 0	//calcTrib
								Aadd(aDadosE0E, {	(cAliasQry)->RD0_CIC					,;//1- cpfTrab
													(cAliasQry)->COMPET						,;//2- perRef
													AllTrim(Str((cAliasQry)->BSINSS))		,;//3- bsMensal
													AllTrim(Str((cAliasQry)->BS13))			,;//4- bs13
													AllTrim(Str((cAliasQry)->E0E_RDIRRF))	,;//5- rendIR
													AllTrim(Str((cAliasQry)->E0E_RDIR13))	})//6- rendIR13

								cChaveE0F := cFilIn + (cAliasQry)->PRONUM + (cAliasQry)->RECLAM + cPerAp + (cAliasQry)->COMPET + "2" //infoCRContrib
								DbSelectArea("E0F")
								If E0F->( dbSeek(cChaveE0F))
									While E0F->( E0F_FILIAL + E0F_PRONUM + E0F_RECLAM + E0F_PERAP + E0F_COMPET + E0F_TIPO ) == cChaveE0F
										aAdd(aInfoBs, {	(cAliasQry)->RD0_CIC		,;//1- cpf
														(cAliasQry)->COMPET			,;//2- perRef
														E0F->E0F_TPCR				,;//3- tpCR
														AllTrim(Str(E0F->E0F_VRCR))	})//4- vrCR
										E0F->( dbSkip())
									End
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				(cAliasQry)->(DbSkip())

				//Array com os tributos por Período
				If cVersEnvio >= "9.3"
					aTribPer := aClone(aDadosE0H)
				Else
					aTribPer := aClone(aDadosE0E)
				EndIf

				If ((cVersEnvio <= "9.2" .And. cProJud == AllTrim((cAliasQry)->RE0_PROJUD)) .Or. ;
					 (cVersEnvio >= "9.3" .And. cProJud == AllTrim((cAliasQry)->RE0_PROJUD)) .And. cIdSeqProc == AllTrim((cAliasQry)->IDSQPR)) .Or. ;
					 Empty(cProJud)
					Loop
				ElseIf Len(aTribPer) > 0 .Or. ( cVersEnvio >= "9.2" .And. Len(aIdeTrab) > 0 )

					If lMiddleware
						aDadosRJE := {}
						cIdXml := If( Empty(cIdXml), aInfoC[3], fXMLInfos(cPerAp)[3] ) //gerar id por evento, demais infos são por filial
						aAdd( aDadosRJE, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S2501", cPerAp, cRjeKey, cIdXml, cRetfNew, "12", "1", Date(), Time(), cOperNew, cRecibEvt, cRecibAnt } )
					EndIf
					Begin Transaction
						lRetXml := fXML2501(@cXml, lRetif, cProJud, cPerAp, aIdeTrab, aTribPer, aInfoBs, aInfoIR, cObs, aIRCompl, cIdSeqProc )
						If lRetXml
							If lMiddleware
								If fGravaRJE( aDadosRJE, cXML, lNovoRJE, nRecEvt )
									aAdd(aLogsOk, cIdLog )
								EndIf
							Else
								cTafKey := "S2501" + cOldProc + cPerAp + cOldIdSeq
								aErrTaf := TafPrepInt( cEmpAnt, cFilEnv, cXml, cTafKey, "3", "S-2501", , , , , , "GPE" )

								If Len(aErrTaf) == 0
									aAdd( aLogsOk, cIdLog )
								else
									aAdd( aLogsErr, cIdLog )
									For nCont := 1 to Len(aErrTaf)
										aAdd( aLogsErr, aErrTaf[nCont])
									Next
								EndIf
							EndIf
						EndIf
					End Transaction
				EndIf
				cXml		:= ""
				aIdeTrab	:= {}
				aInfoIR		:= {}
				aDadosE0E	:= {}
				aDadosE0H	:= {}
				aTribPer	:= {}
				aInfoBs		:= {}
				cObs		:= ""
				cCodMemo	:= ""
				cProJud		:= ""
				cLogId		:= ""
				cIdSeqProc	:= ""
				aIRCompl	:= {}
			EndDo
			(cAliasQry)->(dbCloseArea())
		Next Nz
	Next nFil
	If !lRet
		aAdd( aLogsErr, OemToAnsi(STR0041) ) //"Nenhum registro foi localizado, verifique os parametros selecionados"
	Endif


Return lRet

/*/{Protheus.doc} fXML2501
Geração XML do evento S-2501
@Author.....: isabel.noguti
@Since......: 17/11/2022
@Version....: 1.0
/*/
Static Function fXML2501( cXml, lRetif, cProJud, cPerAp, aIdeTrab, aTribPer, aInfoBs, aInfoCRIR, cObs, aIRCompl, cIdSeqProc )
	Local lRet		:= .F.
	Local nTrab		:= 0
	Local nE		:= 0
	Local nF		:= 0
	Local cVersMw	:= ""
	Local cTpAmb
	Local lRRA		:= .F.
	Local nX		:= 0
	Local nInfV		:= 0
	Local nDedS		:= 0
	Local nBenP		:= 0

	Default lRetif		:= .F.
	Default cProJud		:= ""
	Default cPerAp		:= ""
	Default aIdeTrab	:= {}
	Default aTribPer	:= {}
	Default aInfoBs		:= {}
	Default aInfoCRIR	:= {}
	Default cObs		:= ""
	Default aIRCompl	:= {}
	Default cIdSeqProc	:= ""

	If lMiddleware
		fVersEsoc( "S2200", , , , , , @cVersMw, , @cTpAmb ) //lista do gpem017
		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtContProc/v" + cVersMw + "'>"
		cXML += 	"<evtContProc Id='" + cIdXml + "'>"
		fXMLIdEve( @cXML, { cRetfNew, Iif(cRetfNew == "2", cRecibXML, Nil), Nil, Nil, cTpAmb, 1, "12" } )
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )//<ideEmpregador>
	Else
		cXml := '<eSocial>'
		cXml += 	'<evtContProc>'
		If lRetif
			cXml += 		'<ideEvento>'
			cXml +=				'<indRetif>2</indRetif>'
			cXml +=			'</ideEvento>'
		EndIf
	EndIf

	cXml += 			'<ideProc>'
	cXml += 				'<nrProcTrab>' + cProJud + '</nrProcTrab>' //RE0_PROJUD
	cXml += 				'<perApurPgto>' + If( !lMiddleware, cPerAp, SubStr(cPerAp,1,4) + "-" + SubStr(cPerAp,5,2) ) + '</perApurPgto>' //AAAA-MM E0E_PERAP
	If cVersEnvio >= "9.3" .And. cIdSeqProc > "0"
		cXml +=				'<ideSeqProc>' + cIdSeqProc + '</ideSeqProc>' //E0H_IDSQPR
	EndIf
	If !Empty(cObs)
		cXml +=				'<obs>' + cObs + '</obs>' //E0E_CMEM
	EndIf
	cXml += 			'</ideProc>'
//For cpf
	For nTrab := 1 to Len(aideTrab)
		cXml += 		"<ideTrab cpfTrab='" + aideTrab[nTrab] + "'>"
		For nE := 1 to Len(aTribPer)
			If aTribPer[nE][1] == aideTrab[nTrab]
				cXml +=		"<calcTrib perRef='" +  If( !lMiddleware, aTribPer[nE][2], SubStr(aTribPer[nE][2],1,4) + "-" + SubStr(aTribPer[nE][2],5,2) ) + "' "
				cXml +=		"vrBcCpMensal='" + aTribPer[nE][3] + "' vrBcCp13='" + aTribPer[nE][4] + "'"
				cXml +=		">"

				For nF := 1 to Len(aInfoBs)
					If aInfoBs[nF][1] == aideTrab[nTrab] .And. aInfoBs[nF][2] == aTribPer[nE][2] //cpf/perRef
						cXml += "<infoCRContrib tpCR='" + aInfoBs[nF][3] + "' vrCR='" + aInfoBs[nF][4] + "'>"
						cXml += '</infoCRContrib>'
					EndIf
				Next nF
				cXml += 	'</calcTrib>'
			EndIf
		Next nE

		For nF := 1 to Len(aInfoCRIR)//tipo1
			If aInfoCRIR[nF][1] == aideTrab[nTrab]
				If cVersEnvio >= "9.3" .And. aInfoCRIR[nF][4][8] > "0"
					cXml += 	"<infoCRIRRF tpCR='" + aInfoCRIR[nF][2] + "' vrCR='" + aInfoCRIR[nF][3] + "' vrCR13='" + aInfoCRIR[nF][4][8] + "'>"
				Else
					cXml += 	"<infoCRIRRF tpCR='" + aInfoCRIR[nF][2] + "' vrCR='" + aInfoCRIR[nF][3] + "'>"
				EndIf

				If cVersEnvio >= "9.2" .And. Len(aInfoCRIR[nF,4]) >= 7
					lRRA := aInfoCRIR[nF,2] == "188951"

					If !Empty(aInfoCRIR[nF,4,1]) .Or. (aInfoCRIR[nF,2] == '056152' .And. !Empty(aInfoCRIR[nF,4,9]))
						If cVersEnvio >= "9.3"
							cXml +=		"<infoIR" + aInfoCRIR[nF,4,1] + ">"
							If !Empty(aInfoCRIR[nF,4,9])
								cXml += 	"<rendIsen0561" + aInfoCRIR[nF,4,9] + "/>"
							EndIf
							cXML += 	"</infoIR>"
						Else
							cXml +=		"<infoIR" + aInfoCRIR[nF,4,1] + "/>"
						EndIf
					EndIf
					If lRRA
						cXml +=		"<infoRRA" + If( Empty(aInfoCRIR[nF,4,2]), "", aInfoCRIR[nF,4,2] ) + ">"

						If !Empty(aInfoCRIR[nF,4,3])
							cXml +=		"<despProcJud" + aInfoCRIR[nF,4,3] + "/>"
						EndIf
						For nX := 1 to Len(aInfoCRIR[nF,4,4])
							cXml +=		"<ideAdv" + aInfoCRIR[nF,4,4,nX] + "/>"
						Next nX

						cXml +=		"</infoRRA>"
					Else
						For nX := 1 to Len(aInfoCRIR[nF,4,5])
							cXml +=	"<dedDepen" + aInfoCRIR[nF,4,5,nX] + "/>"
						Next nX
					EndIf

					For nX := 1 to Len(aInfoCRIR[nF,4,6])
						cXml +=		"<penAlim" + aInfoCRIR[nF,4,6,nX] + "/>"
					Next nX

					If !lRRA
						For nX := 1 to Len(aInfoCRIR[nF,4,7])
							cXml +=	"<infoProcRet" + aInfoCRIR[nF,4,7,nX,1] + ">"

							For nInfV := 1 to Len(aInfoCRIR[nF,4,7,nX,2])
								cXml +=	"<infoValores" + aInfoCRIR[nF,4,7,nX,2,nInfV,1] + ">"

								For nDedS := 1 to Len(aInfoCRIR[nF,4,7,nX,2,nInfV,2])
									cXml +=	"<dedSusp" + aInfoCRIR[nF,4,7,nX,2,nInfV,2,nDedS,1] + ">"

									For nBenP := 1 to Len(aInfoCRIR[nF,4,7,nX,2,nInfV,2,nDedS,2])
										cXml +=	"<benefPen" + aInfoCRIR[nF,4,7,nX,2,nInfV,2,nDedS,2,nBenP] + "/>"
									Next nBenP

									cXml +=	"</dedSusp>"
								Next nDedS

								cXml +=	"</infoValores>"
							Next nInfV

							cXml += "</infoProcRet>"
						Next nX
					EndIf
				EndIf
				cXml += 	'</infoCRIRRF>'
			EndIf
		Next nF

		If cVersEnvio >= "9.2"  .And. Len(aIRCompl) > 0//.And. qual chave no array
			If ( nE := aScan(aIRCompl, { |x| x[1] == aideTrab[nTrab] }) ) > 0
				If !Empty(aIRCompl[nE,2,1]) .Or. Len(aIRCompl[nE,2,2]) > 0
					cXml +=		"<infoIRComplem" + If( Empty(aIRCompl[nE,2,1]), "", " dtLaudo='" + aIRCompl[nE,2,1] + "'") + ">"
					For nX := 1 to Len(aIRCompl[nE,2,2])
						cXml += 	"<infoDep" + aIRCompl[nE,2,2,nX] + "/>"
					Next nX
					cXml +=		"</infoIRComplem>"
				EndIf
			EndIf
		EndIf

		cXml += 		'</ideTrab>'

	Next nTrab
	cXml += 	'</evtContProc>'
	cXml += '</eSocial>'

	If !Empty(cXml)
		GrvTxtArq(AllTrim(cXml), "S2501", cPerAp + cProJud + If(cIdSeqProc > "0", cIdSeqProc, "") )
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} fNew3500
Função responsável por gerar o evento S-2501 - Informações de Tributos Decorrentes de Processo Trabalhista
@Author.....: isabel.noguti
@Since......: 18/11/2022
@Version....: 1.0
/*/
Function fNew3500(dDataIni, dDataFim, aArrayFil,aLogsOk, aCheck, aLogsErr )
	Local cAliasQry		:= GetNextAlias()
	Local cFilEnv		:= ""
	Local cIdLog		:= ""
	Local cOldProc		:= ""
	Local cProJud		:= ""
	Local cPerAp		:= ""
	Local cQuery		:= ""
	Local cStatus		:= "-1"
	Local cStat2501		:= "-1"
	Local cStat2555		:= "-1"
	Local cMsgErr		:= ""
	Local cXml			:= ""
	Local cFilInBkp		:= ""
	Local cEvtLog		:="Registro S-3500 do Processo: "
	Local cIdSeq		:= ""
	Local cOldIdSeq		:= ""
	Local cRecib2501	:= ""
	Local lRet			:= .F.
	Local lRetXML		:= .T.
	Local lAdmPubl		:= .F.
	Local lProcessa		:= .T.
	Local lStat2501		:= .F.
	Local lTAFS13		:= V7J->(ColumnPos("V7J_IDESEQ")) > 0
	Local lGPES13		:= ChkFile("E0H")
	Local nFil 			:= 0
	Local nZ			:= 0
	Local nTamIdSeq		:= 0
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
	Default dDataFim	:= CtoD("")
	Default aArrayFil	:= {}
	Default lRetific	:= .F.
	Default aLogsOk		:= {}
	Default aLogsErr	:= {}

	//Verifica se as atualizações de dicionário estão aplicadas no ambiente
	If cVersEnvio >= "9.3"
		If !lGPES13
			cMsgErr := OemToAnsi(STR0063)//"Ambiente GPE desatualizado para geração do evento no leiaute S-1.3, atualize o ambiente com a expedição contínua. "
		EndIf
		If !lMiddleware .And. !lTAFS13
			cMsgErr += OemToAnsi(STR0064)//"Verifique se o ambiente do TAF está atualizado."
		EndIf
	EndIf

	//Interrompe execução do evento S-2501 caso o ambiente não esteja atualizado
	If !Empty(cMsgErr)
		aAdd( aLogsErr, cMsgErr )
		Return
	EndIf

	//Tamanho do campo id sequencia
	If cVersEnvio >= "9.3"
		nTamIdSeq := FwTamSX3("E0H_IDSQPR")[1]
	EndIf

	cCpfDe	:= If( Empty(cCpfDe), '0', cCpfDe )
	cProcDe := If( Empty(cProcDe), '0', cProcDe )
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
				fPosFil( cEmpAnt, cFilEnv )
				cStatus := "-1"
				If fVld1000( cPerAp, @cStatus, cFilEnv )
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
					cMsgErr += If(cStatus == "-1", OemToAnsi(STR0046), "")	//" não localizado na base de dados"
					cMsgErr += If( cStatus == "1", OemToAnsi(STR0047), "")	//" não transmitido para o governo"
					cMsgErr += If( cStatus == "2", OemToAnsi(STR0048), "")	//" aguardando retorno do governo"
					cMsgErr += If( cStatus == "3", OemToAnsi(STR0049), "")	//" retornado com erro do governo"
					aAdd( aLogsErr, cMsgErr)
					lProcessa	:= .F.
					Loop
				EndIf
			EndIf

			If oStat1 == Nil
				oStat1 := FWPreparedStatement():New()
				If cVersEnvio >= "9.3"
					cQuery := "SELECT E0H.E0H_PRONUM PRONUM, E0H.E0H_RECLAM RECLAM, E0H.E0H_CMEM CMEM, E0H.E0H_COMPET COMPET, E0H.E0H_IDSQPR IDSQPR, E0H.E0H_BSINSS BSINSS, E0H.E0H_BS13 BS13, RE0.RE0_PROJUD, RD0.RD0_CIC "
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
					cQuery += "ORDER BY RE0.RE0_PROJUD, E0H.E0H_RECLAM, E0H.E0H_IDSQPR, E0H.E0H_COMPET"
				Else
					cQuery := "SELECT E0E.E0E_PRONUM PRONUM, E0E.E0E_RECLAM RECLAM, E0E.E0E_CMEM CMEM, E0E.E0E_COMPET COMPET, E0E.E0E_BSINSS BSINSS, E0E.E0E_BS13 BS13, E0E.E0E_RDIRRF, E0E.E0E_RDIR13, RE0.RE0_PROJUD, RD0.RD0_CIC "
					cQuery += "FROM " + RetSqlName('E0E') + " E0E "
					cQuery += "INNER JOIN " + RetSqlName('RE0') + " RE0 ON " + FwJoinFilial("E0E","RE0") + " AND E0E.E0E_PRONUM=RE0.RE0_NUM "
					cQuery += "LEFT JOIN " + RetSqlName('RD0') + " RD0 ON " + FwJoinFilial("E0E","RD0") + " AND E0E.E0E_RECLAM=RD0.RD0_CODIGO " //observ
					cQuery += "WHERE E0E.E0E_FILIAL IN ( ? ) "
					cQuery +=	"AND E0E.E0E_PERAP = ? "
					cQuery += 	"AND E0E.E0E_PRONUM IN (SELECT RE0.RE0_NUM "
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
					cQuery += 	"AND E0E.D_E_L_E_T_ = ' ' "
					cQuery +=   "AND RD0.D_E_L_E_T_ = ' ' "
					cQuery +=   "AND RE0.D_E_L_E_T_ = ' ' "
					cQuery += "ORDER BY RE0.RE0_PROJUD, E0E.E0E_RECLAM, E0E.E0E_COMPET "
				EndIf
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

				If cVersEnvio >= "9.3"
					cIdSeq := (cAliasQry)->IDSQPR
				EndIf

				If !(((cAliasQry)->RE0_PROJUD + cIdSeq) $ cProcExe) .And. lProcessa
					lRet 		:= .T.
					lRetXML 	:= .T.
					lProcessa	:= .T.
					cOldProc	:= (cAliasQry)->RE0_PROJUD
					If cVersEnvio >= "9.3"
						cOldIdSeq	:= (cAliasQry)->IDSQPR
						cProcExe	+= cOldProc + cOldIdSeq + "|"
					Else
						cProcExe	+= cOldProc + "|"
					EndIf
					cIdLog		:= " - " + STR0042 + cOldProc //" - Processo: ###"
					cIdLog		+= STR0076 + cPerAp   //" - Per.Apur.: ###"

					//Incrementa o Id no log de geração e deixa zerado caso o valor seja -1
					If cVersEnvio >= "9.3"
						If cOldIdSeq > "0"
							cIdLog += OemToAnsi(STR0062) + AllTrim(cOldIdSeq) //" - Id. Sequência: "
						Else
							cOldIdSeq := Space(nTamIdSeq)
						EndIF
					EndIf

					// Status S-2555
					If cVersEnvio >= "9.3"
						If cOldIdSeq > "0"
							If lMiddleware
								cRjeKey		:= cFilEnv + cOldProc + cPerAp + "S2555"
								cKeyMid		:= cRjeKey
								cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2555" + Padr(cKeyMid, 40, " ")
								//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
								GetInfRJE( 2, cChaveMid, @cStat2555 )
							Else
								//T8I_FILIAL+T8I_NRPROC+T8I_PERAPU+T8I_ATIVO 4
								cStat2555 	:= TAFGetStat( "S-2555", PadR(cOldProc,20) + ";" + cPerAp, cEmpAnt, cFilEnv, 4 )
							EndIf
							If cStat2555 <> "-1"
								//"Não é permitido excluir ou retificar evento S-2501 se houver evento S-2555 com os mesmos Número de Processo e Período de Apuração consolidado."
								//"O evento S-2555 deverá ser excluído pelo TAF para que o evento S-2501 possa ser retificado/excluído."
								//"O evento S-2555 deverá ser excluído pelo Monitor do Middleware para que o evento S-2501 possa ser retificado/excluído."
								cMsgErr	:= OemToAnsi(STR0073)
								aAdd(aLogsErr, cIdLog )
								aAdd(aLogsErr, cMsgErr)
								aAdd(aLogsErr, If(lMiddleware,OemToAnsi(STR0075),OemToAnsi(STR0074)) )
								lProcessa := .F.
								Loop
							EndIf
						EndIf
					EndIf

					cProJud:= AllTrim((cAliasQry)->RE0_PROJUD)

					// Status S-2501
					If lMiddleware
						cRjeKey		:= If(cVersEnvio >= "9.3", Padr( cFilEnv + cOldProc + cPerAp + cOldIdSeq, fTamRJEKey(), " ") , Padr( cFilEnv + cOldProc + cPerAp , fTamRJEKey(), " "))
						cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2501" + cRjeKey + cPerAp
						cIdXml 		:= If( Empty(cIdXml), aInfoC[3], fXMLInfos(cPerAp)[3] )
						GetInfRJE( 2, cChaveMid, @cStat2501,,,,@cRecib2501)
					Else
						If cVersEnvio >= "9.3"
							cStat2501	:= TAFGetStat( "S-2501", PadR(cOldProc,20) + ";" + cPerAp + ";" + cOldIdSeq + ";" + "1" , cEmpAnt, cFilEnv, 7 ) // V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_IDESEQ+V7C_ATIVO uso do indice 7 já que padrão da rotina manda indice 2
						Else
							cStat2501 	:= TAFGetStat( "S-2501", PadR(cOldProc,20) + ";" + cPerAp, cEmpAnt, cFilEnv, 5 )//V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_ATIVO já que padrão da rotina manda indice 2
						EndIf
						cRecib2501 := fRecExTrib(cFilEnv, cOldProc, cPerAp, cOldIdSeq)
						cRecib2501 := If( Empty(cRecib2501), "S2501" + cOldProc + cPerAp + cOldIdSeq, cRecib2501 )
					EndIf

					If lProcessa
						If cStat2501 $ "2*3*4*6"
							BEGIN Transaction
								If  cStat2501 == "2"
									//"Evento S-2501 está aguardando retorno do governo, registro de Exclusão S-3500 desprezado."
									cMsgErr	:= OemToAnsi(STR0058)
									aAdd(aLogsErr, cIdLog )
									aAdd(aLogsErr, cMsgErr)
									lRetXML := .F.
								ElseIf cStat2501 = "3"
									// "Evento S-2501 rejeitado pelo Governo. Realizar os devidos ajustes para que ele esteja apto para Exclusão."
									cMsgErr	:= OemToAnsi(STR0077)
									aAdd(aLogsErr, cIdLog )
									aAdd(aLogsErr, cMsgErr)
									lRetXML := .F.
								ElseIf cStat2501 == "6" .Or. (lMiddleware .And. cStat2501 == "99")
									//"Evento S-2501 com evento de Exclusão pendente para transmissão, registro de Exclusão S-3500 desprezado."
									cMsgErr	:= OemToAnsi(STR0061)
									aAdd(aLogsErr, cIdLog )
									aAdd(aLogsErr, cMsgErr)
									lRetXML := .F.
								ElseIf cStat2501 == "4"
								cStatNew 	:= ""
								cOperNew 	:= ""
								cRetfNew 	:= ""
								cKeyMid	 	:= ""
								nRecEvt	 	:= 0
								lNovoRJE 	:= .T.
								aDadosRJE	:= {}
								aErros		:= {}

								InExc3500(@cXml,'S-2501',cRecib2501, cProJud, ,Substr(cPerAp,1,4)+ "-"+Substr(cPerAp,5,2),AllTrim(cOldIdSeq), cFilEnv, lAdmPubl, cTpInsc, cNrInsc, cIdXml, @cStatNew, @cOperNew, @cRetfNew, @nRecEvt, @lNovoRJE, @cRjeKey, @aErros)
								GrvTxtArq(alltrim(cXml), "S3500", cProJud )

								If lMiddleware
										If Empty(aErros)
											aDadosRJE := {}
											aAdd( aDadosRJE, { xFilial("RJE", cFilEnv), cFilEnv, cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S3500", cPerAp  , cRecib2501 , cIdXml, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew, NIL, NIL } )
											fGravaRJE( aDadosRJE, cXML, lNovoRJE, nRecEvt )
										EndIf
									Else
									aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S3500",,,,,,"GPE")
								EndIf

								If Len( aErros ) > 0
									cMsgErro := ''
									FeSoc2Err( aErros[1], @cMsgErro ,IIF(aErros[1]!='000026',1,2))
									FormText(@cMsgErro)
									aErros[1] := cMsgErro
									aAdd(aLogsErr, cEvtLog + cProJud + " - "+ OemToAnsi(STR0051) ) //##"Registro S-3500 "##" não foi integrado devido ao(s) erro(s) abaixo: "
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

							//"Evento S-2501 não transmitido, realizar a transmissão ou excluir pela rotina Exclusão de Evento (GPEM922)."
							//"Evento S-2501 não transmitido, realizar a transmissão ou excluir pela rotina Exclusão de Eventos (GPEM922)."
							lStat2501	:= If(lMiddleware, cStat2501 == "1", Empty(cStat2501))
							If lStat2501
								cMsgErr := If(lMiddleware,OemToAnsi(STR0080),OemToAnsi(STR0078))
							Else
								//"Evento S-2501 inexistente, executar a geração do evento S-2501."
								cMsgErr := OemToAnsi(STR0079)
							EndIf
							aAdd(aLogsErr, cIdLog )
							aAdd(aLogsErr, cMsgErr)
							lProcessa := .F.

						EndIf

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


Static Function fRecExTrib(cFilEx, cProcRecb, cPerAp, cIdSeqProc)

Local aArea			:= GetArea()
Local cRecib		:= ""
Local cChvV7C 		:= ""
Local nOrder		:= If(cVersEnvio >= "9.3",7,5)
Default cFilEx		:= ""
Default cProcRecb 	:= ""
Default cPerAp		:= ""
Default cIdSeqProc	:= ""


// Ordem 5 (S-1.2)  V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_IDESEQ+V7C_ATIVO
// Ordem 7 (S-1.3)  V7C_FILIAL+V7C_NRPROC+V7C_PERAPU+V7C_ATIVO
DbSelectArea("V7C")
V7C->( dbSetOrder(nOrder) )

cChvV7C	:= If(cVersEnvio >= "9.3",xFilial("V7C",cFilEx) + PADR(cProcRecb,20) + cPerAp + cIdSeqProc + "1",xFilial("V7C",cFilEx) + PADR(cProcRecb,20) + cPerAp + "1")

If V7C->( dbSeek( cChvV7C ) )
	cRecib := Alltrim(V7C->V7C_PROTUL)
EndIf

RestArea(aArea)

Return cRecib


/*/{Protheus.doc} fGetCRIR
Busca os dados dos subgrupos de infoCRIRRF a partir do campo memo da E0F
@author isabel.noguti
@since 20/09/2023
@version S-1.2
/*/
Static Function fGetCRIR( cMemoE0F )
	Local aSubCRIR	:= {}
	Local ltpRRA	:= .F.
	Local oInfoCRIR	:= JsonObject():new()
	Local cInfoIR	:= ""
	Local cInfo0561	:= ""
	Local cInfoRRA	:= ""
	Local cDespProc	:= ""
	Local cVrCr13	:= ""
	Local aIdeAdv	:= {}
	Local aDedDepen	:= {}
	Local aPenAlim	:= {}
	Local aProcRet	:= {}
	Local aInfoVal	:= {}
	Local aDedSusp	:= {}
	Local aBenefPen	:= {}
	Local cInfoProc	:= ""
	Local cInfoVal	:= ""
	Local cDesc		:= ""
	Local cInsc		:= ""
	Local cAtribs	:= ""
	Local cErroMsg	:= ""
	Local nX		:= 0
	Local n2		:= 0
	Local n25		:= 0
	Local n99		:= 0
	Local nTipo		:= 0
	Local nInd		:= 0
	Local nVlr		:= -1
	Local nVlr1		:= -1
	Local nVlr2		:= -1
	Local nVlr3		:= -1
	Local nVlr4		:= -1
	Local nVlr5		:= -1
	Local nVlr6		:= -1
	Local nVlr7		:= -1
	Local nVlr8		:= -1
	Local nVlr9		:= -1
	Local nVlr10	:= -1
	Local nLin		:= 1
	Local nVlrDia	:= -1
	Local nVlrAjuCus	:= -1
	Local nVrIndResCo	:= -1
	Local nVlrAboPecu	:= -1
	Local nVlrAuxMora	:= -1

	Default cMemoE0F	:= ""

	If !Empty(cMemoE0F)
		cErroMsg := oInfoCRIR:FromJSON(cMemoE0F)
		If Empty(cErroMsg) .And. Len(oInfoCRIR['infoCRIRRF']) > 0
			ltpRRA	:= oInfoCRIR['infoCRIRRF'][nLin]['tpCR'] == "188951"

			If oInfoCRIR['infoCRIRRF'][nLin]:hasProperty("vrCR13")
				cVrCr13 := AllTrim(Str(oInfoCRIR['infoCRIRRF'][nLin]['vrCR13']))
			EndIf

			If oInfoCRIR['infoCRIRRF'][nLin]:hasProperty("infoIR")
				nVlr  := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendTrib']) == "U",		 nVlr,	oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendTrib'] )
				nVlr1 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendTrib13']) == "U",	 nVlr1, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendTrib13'] )
				nVlr2 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendMoleGrave']) == "U", nVlr2, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendMoleGrave'] )
				nVlr3 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendIsen65']) == "U",	 nVlr3, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendIsen65'] )
				nVlr4 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrJurosMora']) == "U",	 nVlr4, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrJurosMora'] )
				nVlr5 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendIsenNTrib']) == "U", nVlr5, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendIsenNTrib'] )
				cDesc := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['descIsenNTrib']) <> "C",	 cDesc, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['descIsenNTrib'] )
				nVlr6 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrPrevOficial']) == "U",	 nVlr6, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrPrevOficial'] )

				If oInfoCRIR['infoCRIRRF'][nLin]['infoIR']:hasProperty("vrRendMoleGrave13")
					nVlr7 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendMoleGrave13']) == "U",	 nVlr7, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendMoleGrave13'] )
					nVlr8 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendIsen65Dec']) == "U",	 nVlr8, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrRendIsen65Dec'] )
					nVlr9 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrJurosMora13']) == "U",	 nVlr9, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrJurosMora13'] )
					nVlr10 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrPrevOficial13']) == "U",	 nVlr10, oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['vrPrevOficial13'] )
				EndIf

				cInfoIR := If( nVlr >= 0,					" vrRendTrib='"	+ AllTrim(Transform(nVlr, "@R 999999999999.99")) + "'",	"" )
				cInfoIR += If( nVlr1 >= 0 .And. !ltpRRA,	" vrRendTrib13='" + AllTrim(Transform(nVlr1, "@R 999999999999.99")) + "'", "" )
				cInfoIR += If( nVlr2 >= 0,					" vrRendMoleGrave='" + AllTrim(Transform(nVlr2, "@R 999999999999.99")) + "'", "" )
				cInfoIR += If( nVlr7 >= 0,					" vrRendMoleGrave13='" + AllTrim(Transform(nVlr7, "@R 999999999999.99")) + "'", "" )
				cInfoIR += If( nVlr3 >= 0,					" vrRendIsen65='" + AllTrim(Transform(nVlr3, "@R 999999999999.99")) + "'", "" )
				cInfoIR += If( nVlr8 >= 0,					" vrRendIsen65Dec='" + AllTrim(Transform(nVlr8, "@R 999999999999.99")) + "'", "" )
				cInfoIR += If( nVlr4 >= 0,					" vrJurosMora='" + AllTrim(Transform(nVlr4, "@R 999999999999.99")) + "'", "" )
				cInfoIR += If( nVlr9 >= 0,					" vrJurosMora13='" + AllTrim(Transform(nVlr9, "@R 999999999999.99")) + "'", "" )
				cInfoIR += If( nVlr5 >= 0,					" vrRendIsenNTrib='" + AllTrim(Transform(nVlr5, "@R 999999999999.99")) + "'", "" )
				cInfoIR += If( nVlr5 > 0 .And. !Empty(cDesc), " descIsenNTrib='" + AllTrim(cDesc) + "'", "" )
				cInfoIR += If( nVlr6 >= 0,					" vrPrevOficial='" + AllTrim(Transform(nVlr6, "@R 999999999999.99")) + "'", "" )
				cInfoIR += If( nVlr10 >= 0,					" vrPrevOficial13='" + AllTrim(Transform(nVlr10, "@R 999999999999.99")) + "'", "" )

				//Dados do grupo rendIsen0561
				If oInfoCRIR['infoCRIRRF'][nLin]["infoIR"]:hasProperty("rendIsen0561")
					nVlrDia		:= If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['rendIsen0561']['vlrDiarias']) == "U", 			nVlrDia,		oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['rendIsen0561']['vlrDiarias'] )
					nVlrAjuCus	:= If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['rendIsen0561']['vlrAjudaCusto']) == "U", 		nVlrAjuCus, 	oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['rendIsen0561']['vlrAjudaCusto'] )
					nVrIndResCo := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['rendIsen0561']['vlrIndResContrato']) == "U", 	nVrIndResCo, 	oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['rendIsen0561']['vlrIndResContrato'] )
					nVlrAboPecu	:= If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['rendIsen0561']['vlrAbonoPec']) == "U", 			nVlrAboPecu, 	oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['rendIsen0561']['vlrAbonoPec'] )
					nVlrAuxMora	:= If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['rendIsen0561']['vlrAuxMoradia']) == "U", 		nVlrAuxMora, 	oInfoCRIR['infoCRIRRF'][nLin]['infoIR']['rendIsen0561']['vlrAuxMoradia'] )

					cInfo0561 := If( nVlrDia >= 0, " vlrDiarias='"	+ AllTrim(Transform(nVlrDia, "@R 999999999999.99")) + "'",	"" )
					cInfo0561 += If( nVlrAjuCus >= 0, " vlrAjudaCusto='"	+ AllTrim(Transform(nVlrAjuCus, "@R 999999999999.99")) + "'",	"" )
					cInfo0561 += If( nVrIndResCo >= 0, " vlrIndResContrato='"	+ AllTrim(Transform(nVrIndResCo, "@R 999999999999.99")) + "'",	"" )
					cInfo0561 += If( nVlrAboPecu >= 0, " vlrAbonoPec='"	+ AllTrim(Transform(nVlrAboPecu, "@R 999999999999.99")) + "'",	"" )
					cInfo0561 += If( nVlrAuxMora >= 0, " vlrAuxMoradia='"	+ AllTrim(Transform(nVlrAuxMora, "@R 999999999999.99")) + "'",	"" )
				EndIf

			EndIf

			If ltpRRA .And. oInfoCRIR['infoCRIRRF'][nLin]:hasProperty("infoRRA")
				cDesc := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['descRRA']) <> "C", "", oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['descRRA'] )
				nVlr := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['qtdMesesRRA']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['qtdMesesRRA'] )

				cInfoRRA := " descRRA='" + cDesc + "' qtdMesesRRA='" + AllTrim(Transform(nVlr, "@R 999.9")) + "'"

				If oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']:hasProperty("despProcJud")
					nVlr := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['despProcJud']['vlrDespCustas']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['despProcJud']['vlrDespCustas'] )
					nVlr1 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['despProcJud']['vlrDespAdvogados']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['despProcJud']['vlrDespAdvogados'] )

					cDespProc := " vlrDespCustas='" + AllTrim(Transform(nVlr, "@R 999999999999.99") ) + "' vlrDespAdvogados='" + AllTrim(Transform(nVlr1, "@R 999999999999.99")) + "'"

				EndIf
				If oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']:hasProperty("ideAdv")
					For nX := 1 to Len(oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['ideAdv'])
						nTipo := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['ideAdv'][nX]['tpInsc']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['ideAdv'][nX]['tpInsc'] )
						cInsc := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['ideAdv'][nX]['nrInsc']) <> "C", "", oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['ideAdv'][nX]['nrInsc'] )
						nVlr := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['ideAdv'][nX]['vlrAdv']) == "U", -1, oInfoCRIR['infoCRIRRF'][nLin]['infoRRA']['ideAdv'][nX]['vlrAdv'] )

						cAtribs := " tpInsc='" + cValtoChar(nTipo) + "' nrInsc='" + AllTrim(cInsc) + "'"
						cAtribs += If( nVlr > 0, " vlrAdv='" + AllTrim(Transform(nVlr, "@R 999999999999.99")) + "'", "")

						aAdd(aIdeAdv, cAtribs)
					Next
				EndIf
			EndIf

			If !ltpRRA .And. oInfoCRIR['infoCRIRRF'][nLin]:hasProperty("dedDepen")
				For nX := 1 to Len(oInfoCRIR['infoCRIRRF'][nLin]['dedDepen'])
					nTipo := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['dedDepen'][nX]['tpRend']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['dedDepen'][nX]['tpRend'] )
					cInsc := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['dedDepen'][nX]['cpfDep']) <> "C", "", oInfoCRIR['infoCRIRRF'][nLin]['dedDepen'][nX]['cpfDep'] )
					nVlr := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['dedDepen'][nX]['vlrDeducao']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['dedDepen'][nX]['vlrDeducao'] )

					aAdd(aDedDepen, " tpRend='" + cValtoChar(nTipo) + "' cpfDep='" + cInsc + "' vlrDeducao='" + AllTrim(Transform(nVlr, "@R 999999999999.99")) + "'" )
				Next
			EndIf

			If oInfoCRIR['infoCRIRRF'][nLin]:hasProperty("penAlim")
				For nX := 1 to Len(oInfoCRIR['infoCRIRRF'][nLin]['penAlim'])
					nTipo := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['penAlim'][nX]['tpRend']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['penAlim'][nX]['tpRend'] )
					cInsc := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['penAlim'][nX]['cpfDep']) <> "C", "", oInfoCRIR['infoCRIRRF'][nLin]['penAlim'][nX]['cpfDep'] )
					nVlr := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['penAlim'][nX]['vlrPensao']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['penAlim'][nX]['vlrPensao'] )

					aAdd(aPenAlim, " tpRend='" + cValtoChar(nTipo) + "' cpfDep='" + cInsc + "' vlrPensao='" + AllTrim(Transform(nVlr, "@R 999999999999.99")) + "'")
				Next
			EndIf

			If !ltpRRA .And. oInfoCRIR['infoCRIRRF'][nLin]:hasProperty("infoProcRet")
				For nX := 1 to Len(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'])
					nTipo := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['tpProcRet']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['tpProcRet'] )
					cInsc := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['nrProcRet']) <> "C", "", oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['nrProcRet'] )
					nVlr := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['codSusp']) == "U", -1, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['codSusp'] )

					cInfoProc := " tpProcRet='" + cValtoChar(nTipo) + "' nrProcRet='" + AllTrim(cInsc) + "'"
					cInfoProc += If( nVlr >= 0, " codSusp='" + cValtoChar(nVlr) + "'", "" )

					aInfoVal := {}
					If oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]:hasProperty("infoValores")
						For n2 := 1 to Len(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'])
							nInd := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['indApuracao']) == "U", 1, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['indApuracao'] )
							nVlr  := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['vlrNRetido'])	== "U", -1, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['vlrNRetido'] )
							nVlr1 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['vlrDepJud']) == "U", -1, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['vlrDepJud'] )
							nVlr2 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['vlrCmpAnoCal']) == "U", -1, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['vlrCmpAnoCal'] )
							nVlr3 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['vlrCmpAnoAnt']) == "U", -1, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['vlrCmpAnoAnt'] )
							nVlr4 := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['vlrRendSusp']) == "U", -1, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['vlrRendSusp'] )

							cInfoVal := " indApuracao='" + cValtoChar(nInd) + "'"
							cInfoVal += If(	nVlr > 0, " vlrNRetido='" + AllTrim(Transform(nVlr, "@R 999999999999.99")) + "'", "")
							cInfoVal += If( nVlr1 > 0, " vlrDepJud='" + AllTrim(Transform(nVlr1, "@R 999999999999.99")) + "'", "")
							If nTipo == 2
								cInfoVal += If( nVlr2 > 0, " vlrCmpAnoCal='" + AllTrim(Transform(nVlr2, "@R 999999999999.99")) + "'", "")
								cInfoVal += If( nVlr3 > 0, " vlrCmpAnoAnt='" + AllTrim(Transform(nVlr3, "@R 999999999999.99")) + "'", "")
							EndIf
							cInfoVal += If( nVlr4 > 0, " vlrRendSusp='" + AllTrim(Transform(nVlr4, "@R 999999999999.99")) + "'", "")

							aDedSusp := {}
							If oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]:hasProperty("dedSusp")
								For n25 := 1 to Len(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'])
									nInd := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'][n25]['indTpDeducao']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'][n25]['indTpDeducao'] )
									nVlr := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'][n25]['indTpDeducao']) == "U", -1, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'][n25]['indTpDeducao'] )

									cAtribs := " indTpDeducao ='" + cValtoChar(nInd) + "'"
									cAtribs += If( nVlr > 0 .And. nVlr4 > 0, " vlrDedSusp='" + AllTrim(Transform(nVlr, "@R 999999999999.99")) + "'", "")

									aBenefPen := {}
									If oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'][n25]:hasProperty("benefPen")
										For n99 := 1 to Len(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'][n25]['benefPen'])
											cInsc := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'][n25]['benefPen'][n99]['cpfDep']) <> "C", "", oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'][n25]['benefPen'][n99]['cpfDep'] )
											nVlr := If( Valtype(oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'][n25]['benefPen'][n99]['vlrDepenSusp']) == "U", 0, oInfoCRIR['infoCRIRRF'][nLin]['infoProcRet'][nX]['infoValores'][n2]['dedSusp'][n25]['benefPen'][n99]['vlrDepenSusp'] )

											aAdd( aBenefPen, " cpfDep='" + cInsc + "' vlrDepenSusp='" + AllTrim(Transform(nVlr, "@R 999999999999.99")) + "'" )
										Next n99	//benefPen
									EndIf
									aAdd( aDedSusp, {cAtribs, aBenefPen} )
								Next n25	//dedSusp
							EndIf
							aAdd( aInfoVal, {cInfoVal, aDedSusp} )
						Next n2	//infoValores
					EndIf
					aAdd( aProcRet, {cInfoProc, aInfoVal} )
				Next nX	//infoProcRet
			EndIf

		EndIf
	EndIf

	aSubCRIR := { cInfoIR	,;	//1-grupo infoIR
				cInfoRRA	,;	//2-grupo infoRRA
				cDespProc	,;	//3-sub infoRRA/despProcJud
				aIdeAdv		,;	//4-subs infoRRA/ideAdv
				aDedDepen	,;	//5-grupos dedDepen
				aPenAlim	,;	//6-grupos penAlim
				aProcRet 	,;	//7-grupos infoProcRet
				cVrCr13		,;	//8- Conteúdo de VrCr13
				cInfo0561	}   //3-sub infoIR/rendIsen0561
Return aSubCRIR

/*/{Protheus.doc} fGetIRComp
Busca os dados do grupo infoIRComplem partir do campo memo da E0E
@author isabel.noguti
@since 21/09/2023
@version S-1.2
/*/
Static Function fGetIRComp( cMemoE0E )
	Local oInfCompl	:= JsonObject():new()
	Local aInfoDep	:= {}
	Local cDtLaudo	:= ""
	Local cAtribs	:= ""
	Local cCpf		:= ""
	Local cNasc		:= ""
	Local cNome		:= ""
	Local cdepIR	:= ""
	Local cTpDep	:= ""
	Local cDesc		:= ""
	Local nX		:= 0

	Default cMemoE0E	:= ""

	If !Empty(cMemoE0E)
		oInfCompl:FromJSON(cMemoE0E)

		If oInfCompl:hasProperty("dtLaudo")
			cDtLaudo := If( Valtype(oInfCompl['dtLaudo']) == "U", cDtLaudo, oInfCompl['dtLaudo'])
			cDtLaudo := If( lMiddleware, cDtLaudo, StrTran( cDtLaudo, "-", "" ) )
		EndIf

		For nX := 1 to Len(oInfCompl['infoDep'])
			cCpf	:= If( Valtype(oInfCompl['infoDep'][nX]['cpfDep']) <> "C", "", oInfCompl['infoDep'][nX]['cpfDep'])
			cNasc	:= If( Valtype(oInfCompl['infoDep'][nX]['dtNascto']) <> "C", "", oInfCompl['infoDep'][nX]['dtNascto'])
			cNasc := If( lMiddleware, cNasc, StrTran( cNasc, "-", "" ) )
			cNome	:= If( Valtype(oInfCompl['infoDep'][nX]['nome']) <> "C", "", oInfCompl['infoDep'][nX]['nome'])
			cdepIR	:= If( Valtype(oInfCompl['infoDep'][nX]['depIRRF']) <> "C", "", oInfCompl['infoDep'][nX]['depIRRF'])
			cTpDep	:= If( Valtype(oInfCompl['infoDep'][nX]['tpDep']) <> "C", "", oInfCompl['infoDep'][nX]['tpDep'])
			cDesc	:= If( Valtype(oInfCompl['infoDep'][nX]['descrDep']) <> "C", "", oInfCompl['infoDep'][nX]['descrDep'])

			cAtribs := " cpfDep='" + cCpf + "'"
			cAtribs += If( Empty(cNasc), "", " dtNascto='" + cNasc + "'" )
			cAtribs += If( Empty(cNome), "", " nome='" + cNome + "'" )
			cAtribs += If( cdepIR == "S", " depIRRF='" + cdepIR + "'", "" )
			cAtribs += If( cdepIR == "S", " tpDep='" + cTpDep + "'", "" )
			cAtribs += If( cTpDep == "99", " descrDep='" + cDesc + "'", "" )

			aAdd( aInfoDep, cAtribs )
		Next nX
	EndIf

Return { cDtLaudo, aInfoDep }
