#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ004.CH"

#DEFINE SRV_NORMAL '1'
#DEFINE SRV_EXTRAORDINARIO '2'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ004

Adapter REST da rotina de Horarios/Serviços 

@type 		function
@sample 	GTPIRJ004(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		06/05/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ004(lJob, lAuto, aParams, lMonit)

	Local aArea   := GetArea()
	Local lRet    := .T.
	Local cEmpRJ  := nil
	Local dDtIni  := nil
	Local cHrIni  := nil
	Local dDtFim  := nil
	Local cHrFim  := nil

	Default lJob    := .F.
	Default lAuto   := .F.
	Default aParams	:= {}

	If !lJob

		If FwAlertYesNo(STR0008)	//'Para integrar horários/serviços é preciso integrar linhas. Deseja realizar a integração?'
			GTPIRJ002(lJob)
		EndIf 

		If ( Len(aParams) == 0 )

			If Pergunte('GTPIRJ004',!lJob)

				cEmpRJ  := MV_PAR01
				dDtIni  := MV_PAR02
				cHrIni  := MV_PAR03
				dDtFim  := MV_PAR04
				cHrFim  := MV_PAR05

				lRet := .T.
			Else
				lRet := .F.
			EndIf

		Else

			cEmpRJ  := aParams[1]
			dDtIni  := aParams[2]
			cHrIni  := aParams[3]
			dDtFim  := aParams[4]
			cHrFim  := aParams[5]

		EndIf

		If ( lRet )
			FwMsgRun( , {|oSelf| lRet := GI004Receb(lJob, oSelf,cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim,lAuto,@lMonit)}, , STR0001) //"Processando registros de Horários/Serviço... Aguarde!"
		EndIf

	Else
		Pergunte('GTPIRJ004',.F.)
		lRet := GI004Receb(lJob, oSelf,cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim,lAuto)
	EndIf

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI004Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI004Receb(cXml, lRet)
@param 		cXml, characters, Xml passado pela função do IntegDef
			lRet, logical, Variavel passada por referncia utilizada para validar o processamento da rotina
@Return 	cXMLRet, characters, String contendo o xml de envio
@author 	jacomo.fernandes
@since 		15/02/2017
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI004Receb(lJob, oMessage,cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, lAuto, lMonit)

	Local oRJIntegra  := GtpRjIntegra():New()
	Local oModel	  := FwLoadModel("GTPA004")
	Local oMdlGID	  := Nil
	Local oMdlGIE     := Nil
	Local aFldsGID    := {}
	Local aDPXXFGID   := {}
	Local aFldsGIE    := {}
	Local aDPXXFGIE   := {}
	Local aGIEValues  := {}
	Local cIntID	  := ""
	Local cIntAux	  := ""
	Local cExtID	  := ""
	Local cCode		  := ""
	Local cErro		  := ""
	Local cTagName    := ""
	Local cCampo      := ""
	Local cTipoCpo    := ""
	Local xValor      := ""
	Local cSequencia  := ""
	Local cFilAux     := ""
	Local cFrequenc   := ""
	Local cStatus     := ""
	Local cXmlAuto    := ""
	Local cResultAuto := ""
	Local cFilBkp     := cFilAnt
	Local nW          := 0
	Local nX          := 0
	Local nTrecho     := 0
	Local nField      := 0
	Local nOpc		  := 0
	Local nTotReg     := 0
	Local nTotGIE     := 0
	Local nPos        := 0
	Local lOk		  := .F.
	Local lRet        := .T.
	Local lContinua   := .T.
	Local lOnlyInsert := .F.
	Local lOverWrite  := .F.
	Local lAddLine	  := .F.
	Local aAux        := {}
	Local lMessage	  := ValType(oMessage) == 'O'
	Local oJsonResult := JsonObject():new()
	Local aDados      := {}
	Local aTrechos    := {}
	Local cRotina	  := "GTPIRJ004"
	Local aError	  := {}
	Local cExtEmp     := ""
	Local nKmProvavel := 0
	Local nGYN_LOTACA := 0
	Local aCposGYN    := {}
	Local cCodLin     := ''
	Local cCodHorario := ''
	Local aMsgRet  	  := {}  
	Local cTexto      := ''    
	Local lStruViagem := GID->(FieldPos('GID_IDSRV1')) > 0 .And. GID->(FieldPos('GID_IDSRV2')) > 0
	Local lGeraViagem := .T.
	Local cIdServico  := ''
	Local cStCorrida  := ""
	Local lGYN_EXTRA  := .F.
	Local lUsaPiso	  := .F.
	Local cDtVInicial := ""
	Local nDiasViagem := 0

	cXmlAuto := '<?xml version="1.0" encoding="utf-8"?>'
	cXmlAuto += "<RJIntegra>"
	cXmlAuto += '	<Servico tagMainList="servico">'
	cXmlAuto += "		<ListOfFields>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>idServico</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_COD</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>True</onlyInsert>"
	cXmlAuto += "				<overwrite>False</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>idLinha</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_LINHA</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>True</onlyInsert>"
	cXmlAuto += "				<overwrite>False</overwrite>"
	cXmlAuto += "                <DeParaXXF>"
	cXmlAuto += "					<Alias>GI2</Alias>"
	cXmlAuto += "					<XXF_Field>GI2_COD</XXF_Field>"
	cXmlAuto += "					<ColumnNumber>3</ColumnNumber>"
	cXmlAuto += "					<IndiceOrder>1</IndiceOrder>"
	cXmlAuto += "					<ListOfSeekField>"
	cXmlAuto += "						<SeekField>GI2_FILIAL</SeekField>"
	cXmlAuto += "						<SeekField>GI2_COD</SeekField>"
	cXmlAuto += "					</ListOfSeekField>"
	cXmlAuto += "				</DeParaXXF>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>horaInicio</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_HORCAB</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "            <Field>"
	cXmlAuto += "				<tagName>dataSaida</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_INIVIG</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "            <Field>"
	cXmlAuto += "				<tagName>dataChegada</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_FINVIG</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>frequencia</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_SEG</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>numeroServico</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_NUMSRV</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>statusT</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_STATUS</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>feriados</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_FER</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>sentidoIda</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_SENTID</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>dataHoraModificacaoT</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_DTALT</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "			<Field>"
	cXmlAuto += "				<tagName>statusCorrida</tagName>"
	cXmlAuto += "				<fieldProtheus>GID_MSBLQL</fieldProtheus>"
	cXmlAuto += "				<onlyInsert>False</onlyInsert>"
	cXmlAuto += "				<overwrite>True</overwrite>"
	cXmlAuto += "			</Field>"
	cXmlAuto += "		</ListOfFields>"
	cXmlAuto += '		<Trechos tagMainList="trechos">'
	cXmlAuto += "			<ListOfFields>"
	cXmlAuto += "				<Field>"
	cXmlAuto += "					<tagName>idTrecho</tagName>"
	cXmlAuto += "					<fieldProtheus>GIE_COD</fieldProtheus>"
	cXmlAuto += "					<onlyInsert>True</onlyInsert>"
	cXmlAuto += "					<overwrite>False</overwrite>"
	cXmlAuto += "				</Field>"
	cXmlAuto += "				<Field>"
	cXmlAuto += "					<tagName>sequencia</tagName>"
	cXmlAuto += "					<fieldProtheus>GIE_SEQ</fieldProtheus>"
	cXmlAuto += "					<onlyInsert>False</onlyInsert>"
	cXmlAuto += "					<overwrite>True</overwrite>"
	cXmlAuto += "				</Field>"
	cXmlAuto += "				<Field>"
	cXmlAuto += "					<tagName>origemID</tagName>"
	cXmlAuto += "					<fieldProtheus>GIE_IDLOCP</fieldProtheus>"
	cXmlAuto += "					<onlyInsert>False</onlyInsert>"
	cXmlAuto += "					<overwrite>True</overwrite>"
	cXmlAuto += "					<DeParaXXF>"
	cXmlAuto += "						<Alias>GI1</Alias>"
	cXmlAuto += "						<XXF_Field>GI1_COD</XXF_Field>"
	cXmlAuto += "						<ColumnNumber>3</ColumnNumber>"
	cXmlAuto += "						<IndiceOrder>1</IndiceOrder>"
	cXmlAuto += "						<ListOfSeekField>"
	cXmlAuto += "							<SeekField>GI1_FILIAL</SeekField>"
	cXmlAuto += "							<SeekField>GI1_COD</SeekField>"
	cXmlAuto += "						</ListOfSeekField>"
	cXmlAuto += "					</DeParaXXF>"
	cXmlAuto += "				</Field>"
	cXmlAuto += "                <Field>"
	cXmlAuto += "					<tagName>destinoID</tagName>"
	cXmlAuto += "					<fieldProtheus>GIE_IDLOCD</fieldProtheus>"
	cXmlAuto += "					<onlyInsert>False</onlyInsert>"
	cXmlAuto += "					<overwrite>True</overwrite>"
	cXmlAuto += "					<DeParaXXF>"
	cXmlAuto += "						<Alias>GI1</Alias>"
	cXmlAuto += "						<XXF_Field>GI1_COD</XXF_Field>"
	cXmlAuto += "						<ColumnNumber>3</ColumnNumber>"
	cXmlAuto += "						<IndiceOrder>1</IndiceOrder>"
	cXmlAuto += "						<ListOfSeekField>"
	cXmlAuto += "							<SeekField>GI1_FILIAL</SeekField>"
	cXmlAuto += "							<SeekField>GI1_COD</SeekField>"
	cXmlAuto += "						</ListOfSeekField>"
	cXmlAuto += "					</DeParaXXF>"
	cXmlAuto += "				</Field>"
	cXmlAuto += "				<Field>"
	cXmlAuto += "					<tagName>horaIncio</tagName>"
	cXmlAuto += "					<fieldProtheus>GIE_HORLOC</fieldProtheus>"
	cXmlAuto += "					<onlyInsert>True</onlyInsert>"
	cXmlAuto += "					<overwrite>False</overwrite>"
	cXmlAuto += "				</Field>"
	cXmlAuto += "				<Field>"
	cXmlAuto += "					<tagName>horaFinal</tagName>"
	cXmlAuto += "					<fieldProtheus>GIE_HORDES</fieldProtheus>"
	cXmlAuto += "					<onlyInsert>False</onlyInsert>"
	cXmlAuto += "					<overwrite>True</overwrite>"
	cXmlAuto += "				</Field>"
	cXmlAuto += "				<Field>"
	cXmlAuto += "					<tagName>via</tagName>"
	cXmlAuto += "					<fieldProtheus>GIE_VIA</fieldProtheus>"
	cXmlAuto += "					<onlyInsert>False</onlyInsert>"
	cXmlAuto += "					<overwrite>True</overwrite>"
	cXmlAuto += "				</Field>  "
	cXmlAuto += "				<Field>"
	cXmlAuto += "					<tagName>tempoTrecho</tagName>"
	cXmlAuto += "					<fieldProtheus>GIE_TPTR</fieldProtheus>"
	cXmlAuto += "					<onlyInsert>False</onlyInsert>"
	cXmlAuto += "					<overwrite>True</overwrite>"
	cXmlAuto += "				</Field>"
	cXmlAuto += "                <Field>"
	cXmlAuto += "					<tagName>tempoExcecao</tagName>"
	cXmlAuto += "					<fieldProtheus>GIE_TEMPO</fieldProtheus>"
	cXmlAuto += "					<onlyInsert>False</onlyInsert>"
	cXmlAuto += "					<overwrite>True</overwrite>"
	cXmlAuto += "				</Field>    "
	cXmlAuto += "			</ListOfFields>	"
	cXmlAuto += "		</Trechos>"
	cXmlAuto += "	</Servico>"
	cXmlAuto += "</RJIntegra>"

	oRJIntegra:SetPath("/servico")

	oRJIntegra:SetParam('empresa'    , ALLTRIM(cEmpRJ))
	oRJIntegra:SetParam('dataInicial', SubStr(DtoS(dDtIni), 3,8) + STRTRAN(cHrIni,":",""))
	oRJIntegra:SetParam('dataFinal'	 , SubStr(DtoS(dDtFim), 3,8) + STRTRAN(cHrFim,":",""))

// recuperando as informaçôes do XML de controle da LINHA
	If !lAuto
		oRJIntegra:SetServico("Servico")
	Else
		oRJIntegra:SetServico("Servico",,,cXmlAuto)
	EndIf

	aFldsGID  := aClone(oRJIntegra:GetFieldDePara())
	aDPXXFGID := aClone(oRJIntegra:GetFldXXF())

// recuperando as informaçôes do XML de controle dos TRECHOS
	If !lAuto
		oRJIntegra:SetServico("Servico/Trechos",.T.)
	Else
		oRJIntegra:SetServico("Servico/Trechos",.T.,,cXmlAuto)
	EndIf

	aFldsGIE  := aClone(oRJIntegra:GetFieldDePara())
	aDPXXFGIE := aClone(oRJIntegra:GetFldXXF())

	If !lAuto
		oRJIntegra:SetServico("Servico")
	Else
		oRJIntegra:SetServico("Servico",,,cXmlAuto)
	EndIf

	If lAuto
		cResultAuto := '{"linha":[{"idLinha":213,"descLinha":"UBERABA X SANTOS 20089","idClasse":1,"dataModificacao":"2018-03-19","idOrgaoConcedente":3,"prefixo":"06033801","tributaTarifa":1,"tributaTEmbarque":0,"tributaPedagio":0,"codigoLinha":"20089","idEmpresa":10,"trechos":{"trecho":[{"idTrecho":35965,"sequencia":1,"indVenda":null,"origemID":"7451","destinoID":"19249","descOrigem":"URA","origemIBGE":null,"descDestino":"IGA","destinoIBGE":null,"kmReal":"16","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null},{"idTrecho":35983,"sequencia":2,"indVenda":null,"origemID":"19249","destinoID":"19248","descOrigem":"IGA","origemIBGE":null,"descDestino":"AMI","destinoIBGE":null,"kmReal":"9","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null},{"idTrecho":36000,"sequencia":3,"indVenda":null,"origemID":"19248","destinoID":"19247","descOrigem":"AMI","origemIBGE":null,"descDestino":"ITV","destinoIBGE":null,"kmReal":"27","horaIncio":null,"horaFinal":null,"tempoTrecho":null,"tempoExcecao":null,"via":"225","dataFinal":null,"dataInicio":null}]}}]}'
	EndIf


	If oRJIntegra:Get(cResultAuto)

		oModel:SetCommit({ || CFGA070MNT("TotalBus", "GID", "GID_COD", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGID:GetValue('GID_COD'), 'GID'))) },.T.)

		GID->(DbSetOrder(1))	// GI2_FILIAL+GI2_COD+GI2_VIA
		GIE->(DbSetOrder(6))	// GIE_FILIAL+GIE_CODGID+GIE_SEQ+GIE_HIST

		oJsonResult:fromJson(oRJIntegra:cResult)
		aDados  := oJsonResult['servico']
		nTotReg := Len(aDados)

		//Necessário para a automação não efetuar todos os registros de uma vez
		If lAuto
			nTotReg := 1
		EndIf

		nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

		If ( nTotReg >= 1 )

			For nW := 1 To nTotReg
				lContinua  := .T.
				aGIEValues := {}
				cTexto     := ""
				lRet       := .T.

				If lMessage .And. !lJob
					oMessage:SetText(I18N(STR0002, {cValtoChar(nW), nTotReg}))//"Processando registros de Horários/Serviço - #1/#2... Aguarde!"
					ProcessMessages()
				EndIf

				// para essa integração é preciso localizar a filial. Caso não encontrada, pular para próximo item do JSON
				cFilAux := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt, cValToChar(aDados[nW]['idEmpresa']), , "2")
				If Empty(cFilAux)
					Loop
				Else
					cFilAnt := cFilAux
				EndIf

				oRJIntegra:aFldDePara := aFldsGID
				oRJIntegra:aFldXXF    := aDPXXFGID
				lGYN_EXTRA  := Upper(Alltrim(aDados[nW]['servicoExtraT'])) == 'SIM'
				cExtID      := cValToChar(aDados[nW][ 'idServico' ])
				cExtEmp     := cValToChar(aDados[nW][ 'idEmpresa' ])
				cExtId      := Alltrim(cExtEmp) + "|" + Alltrim(cExtId)
				nGYN_LOTACA := aDados[nW][ 'quantidadesAssentos' ]
				aCposGYN    := {}
				aMsgRet     := {}
				lGeraViagem := .T.
				cStCorrida  := Alltrim(aDados[nW][ 'statusCorrida' ])
				cIdServico  := cValToChar(aDados[nW][ 'idServico' ])
				If lStruViagem
					lUsaPiso :=  aDados[nW]['pisoExtra1'] == cIdServico .Or. aDados[nW]['pisoExtra1'] == cIdServico
					If lUsaPiso
					GetQtdeExtra(nW, aDados, @nGYN_LOTACA)
					EndIf
				EndIF 					
				If !lGYN_EXTRA
					lGYN_EXTRA := Upper(Alltrim(aDados[nW]['descTipoServico'])) == "EXTRA"	
				EndIf		
				Aadd( aCposGYN,{'GYN_LOTACA',nGYN_LOTACA})
				Aadd( aCposGYN,{'GYN_EXTRA' ,lGYN_EXTRA})
				Aadd( aCposGYN,{'GYN_NUMSRV' ,cIdServico})
				If !Empty(cExtID)
					cCode := GTPxRetId("TotalBus", "GID", "GID_COD", cExtID, @cIntID, 3, @lOk, @cErro, {"GID_FILIAL", "GID_COD"}, 1)
					If Empty(cIntID)
						nOpc := MODEL_OPERATION_INSERT
					ElseIf lOk .And. GID->(DbSeek(xFilial('GID') + cCode))
						nOpc := MODEL_OPERATION_UPDATE
					Else
						lContinua := .F.
						If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
							GtpGrvLgRj(		STR0004,; //"Horários"
							oRJIntegra:cUrl,;
								oRJIntegra:cPath,;
								cRotina,;
								oRJIntegra:cParam,;
								cErro)
							aAdd(aError, cErro)
							Exit
						EndIf
					EndIf
					// Cancelamento de Viagem
					If lContinua .And. nOpc == MODEL_OPERATION_UPDATE 
						If cStCorrida == 'Cancelado' 
							GTPA3EXEC( 5 )	
							oModel:DeActivate() 
							Loop 
						Else
							GTPA3EXEC( 6 )	// Verifica se existe viagem criada, em casos de ativação do cancelamento
						EndIf 
					EndIf 
					If lContinua
						oModel:SetOperation(nOpc)

						oModel:Activate()
						oMdlGID := oModel:GetModel('GIDMASTER')
						oMdlGIE := oModel:GetModel('GIEDETAIL')

						// recuperando a TAG e o respectivo campo da tabela GID
						For nX := 1 To Len(aFldsGID)
							cTagName    := aFldsGID[nX][1]
							cCampo      := aFldsGID[nX][2]
							cTipoCpo    := aFldsGID[nX][3]
							lOnlyInsert := aFldsGID[nX][6]
							lOverWrite  := aFldsGID[nX][7]

							If cTagName $ "frequencia"
								cFrequenc := aDados[nW][cTagName]
								// Se for viagem extra e a frequência estiver vazia, considerar como todos os dias
								If lGYN_EXTRA .And. Empty(StrTran(cFrequenc,"|",""))
									cFrequenc := "|X|X|X|X|X|X|X|"
								EndIf

								aAux := separa(Substr(cFrequenc,2,len(cFrequenc)-2),"|")
								If !Empty(aAux)
									lContinua := oMdlGID:setValue("GID_SEG", aAux[1] == "X")

									If  lContinua .And. Len(aAux) >= 2
										lContinua := oMdlGID:setValue("GID_TER", aAux[2] == "X")
									EndIf
									If lContinua .And. Len(aAux) >= 3
										lContinua := oMdlGID:setValue("GID_QUA", aAux[3] == "X")
									EndIf
									If lContinua .And. Len(aAux) >= 4
										lContinua := oMdlGID:setValue("GID_QUI", aAux[4] == "X")
									EndIf
									If lContinua .And. Len(aAux) >= 5
										lContinua := oMdlGID:setValue("GID_SEX", aAux[5] == "X")
									EndIf
									If lContinua .And. Len(aAux) >= 6
										lContinua := oMdlGID:setValue("GID_SAB", aAux[6] == "X")
									EndIf
									If lContinua .And. Len(aAux) >= 7
										lContinua := oMdlGID:setValue("GID_DOM", aAux[7] == "X")
									EndIf
								EndIf
							EndIf

							If cTagName $ "statusT|statusCorrida|feriados"
								cStatus := cValToChar(aDados[nW][cTagName])
							EndIf

							// recuperando através da TAG o valor a ser inserido no campo
							If !Empty(cTagName) .And. !Empty((xValor := GTPCastType(aDados[nW][cTagName],cTipoCpo)))
								// verificando a necessidade de realizar o DePara XXF
								If (nPos := aScan(aDPXXFGID, {|x| x[1] == cCampo})) > 0
									xValor := GTPxRetId("TotalBus", aDPXXFGID[nPos, 2], aDPXXFGID[nPos, 3], xValor, @cIntAux, aDPXXFGID[nPos, 4], @lOk, @cErro, aDPXXFGID[nPos, 6], aDPXXFGID[nPos, 5])
									
									If cTagName $ "idLinha" .And. Empty(xValor)
										xValor := GTPCastType(aDados[nW]['idEmpresa'],"C") + "|" +  GTPCastType(aDados[nW]['idLinha'],"C")	
									xValor := GTPxRetId("TotalBus", aDPXXFGID[nPos, 2], aDPXXFGID[nPos, 3], xValor, @cIntAux, aDPXXFGID[nPos, 4], @lOk, @cErro, aDPXXFGID[nPos, 6], aDPXXFGID[nPos, 5])
								EndIf
								EndIf
								
								If cTagName $ "horaInicio"
									xValor := STRTRAN( xValor, ":", "")
								EndIf
								If cTagName $ "sentidoIda"
									xValor := IIF(xValor == "1", "1", "2")
								EndIf
								If cCampo $ "GID_STATUS"
									xValor := "1"
								EndIf
                                If cCampo $ "GID_MSBLQL"
                                    xValor := "2"
								EndIf
								If cCampo $ "GID_FER"
									xValor := (cStatus == "1")
								EndIf

								If !(cTagName $ "frequencia")
									If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGID:GetValue(cCampo))
										lContinua := oMdlGID:SetValue(cCampo, xValor)
									ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc <> MODEL_OPERATION_INSERT .And. lOverWrite)
										lContinua := oMdlGID:SetValue(cCampo, xValor)
									EndIf
								EndIf
								If !lContinua
									cErro := I18N( STR0003 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
									If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
										GtpGrvLgRj(		STR0004,; //"Horários"
										oRJIntegra:cUrl,;
											oRJIntegra:cPath,;
											cRotina,;
											oRJIntegra:cParam,;
											cErro)
										aAdd(aError, cErro)
										EXIT
									Endif
								EndIf
							EndIf
						Next nX

						If lStruViagem .And. lUsaPiso
							lContinua := oMdlGID:SetValue('GID_GERVIA', Iif(lGeraViagem,'1','2'))
							If !lContinua
								cErro := I18N( STR0003 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
								If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
									GtpGrvLgRj(		STR0004,; //"Horários"
									oRJIntegra:cUrl,;
										oRJIntegra:cPath,;
										cRotina,;
										oRJIntegra:cParam,;
										cErro)
									aAdd(aError, cErro)
									EXIT
								Endif
							EndIf						
						EndIf 

						// recuperando a TAG e o respectivo campo da tabela G5I (Trechos)
						aTrechos := aDados[nW]['trechos']['trecho']
						aSort(aTrechos, , , {|x, y| x['sequencia'] < y['sequencia']})
						nTotGIE     := Len(aTrechos)
						nKmProvavel := 0

						If lContinua .And. nTotGIE > 0
							// populando o array com os valores a serem gravados na tabela G5I
							oRJIntegra:aFldDePara := aFldsGIE
							oRJIntegra:aFldXXF    := aDPXXFGIE
							nDiasViagem := 0
							If nOpc == MODEL_OPERATION_UPDATE
								GTPxClearData(oMdlGIE,.F.)
								ExcluiHorTrechos(oMdlGID:GetValue("GID_COD"))
							EndIf 								
							For nTrecho := 1 To nTotGIE
								lAddLine := .F.
								cSequencia := Replicate('0', TamSx3('GIE_SEQ')[1] - Len(cValtoChar(aTrechos[nTrecho]['sequencia']))) + RTrim(LTrim(cValtoChar(aTrechos[nTrecho]['sequencia'])))
								nKmProvavel += Val(aTrechos[nTrecho]['kmReal'])
								If lContinua .And. !oMdlGIE:SeekLine({{'GIE_SEQ', cSequencia }})
									lAddLine := .T.
									oMdlGIE:addLine(.T.)
								EndIf
								For nField := 1 To Len(aFldsGIE)
									xValor      := ""
									cTagName    := aFldsGIE[nField][1]
									cCampo      := aFldsGIE[nField][2]
									cTipoCpo    := aFldsGIE[nField][3]
									lOnlyInsert := aFldsGIE[nField][6]
									lOverWrite  := aFldsGIE[nField][7]

									// recuperando através da TAG o valor a ser inserido no campo
									If !Empty(cTagName) .And. !Empty(xValor := GTPCastType(aTrechos[nTrecho][cTagName],cTipoCpo))
										// verificando a necessidade de realizar o DePara XXF
										If (nPos := aScan(aDPXXFGIE, {|x| x[1] == cCampo})) > 0
											xValor := GTPxRetId("TotalBus", aDPXXFGIE[nPos, 2], aDPXXFGIE[nPos, 3], xValor, @cIntAux, aDPXXFGIE[nPos, 4], @lOk, @cErro, aDPXXFGIE[nPos, 6], aDPXXFGIE[nPos, 5])
										EndIf

										If cCampo == "GIE_SEQ"
											xValor := cSequencia
										EndIf
										If cCampo $ "GIE_HORLOC|GIE_HORDES"
											xValor := STRTRAN( xValor, ":", "")
										EndIf
										If cCampo $ "GIE_TPTR|GIE_TEMPO"//"1970-01-01 01:00:00.0"
											xValor := STRTRAN(SUBSTR(xValor,12,5), ":", "")
										EndIf
										If lAddLine .And. lOnlyInsert .And. Empty(oMdlGIE:GetValue(cCampo))
											lContinua := oMdlGIE:SetValue(cCampo, xValor)
										ElseIf (lAddLine .And. !lOnlyInsert) .Or. (!lAddLine .And. lOverWrite)
											lContinua := oMdlGIE:SetValue(cCampo, xValor)
										EndIf

										If !lContinua
											cErro := I18N( STR0003 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
											If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
												GtpGrvLgRj(		STR0004,; //"Horários"
												oRJIntegra:cUrl,;
													oRJIntegra:cPath,;
													cRotina,;
													oRJIntegra:cParam,;
													cErro)
												aAdd(aError, cErro)
												EXIT
											Endif
										EndIf
									EndIf
								Next nField

								If aTrechos[nTrecho]['horaFinal'] < aTrechos[nTrecho]['horaIncio']
									nDiasViagem++
								EndIf
								oMdlGIE:LoadValue('GIE_DIA', nDiasViagem)
								
							Next nTrecho

						EndIf

						If lContinua .And. oModel:lModify
							lContinua := oModel:VldData() .And. oModel:CommitData()
							If !lContinua
								cErro := I18N( STR0005, {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao validar os dados da Horários #2 (#1)."
								If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
									GtpGrvLgRj(		STR0004,; //"Horários"
									oRJIntegra:cUrl,;
										oRJIntegra:cPath,;
										cRotina,;
										oRJIntegra:cParam,;
										cErro)
									aAdd(aError, cErro)
								Endif
							Else 
								cCodLin     := oMdlGID:GetValue( 'GID_LINHA' )
								cCodHorario := oMdlGID:GetValue( 'GID_COD' )
								cDtVInicial := StrTran(SubStr(aDados[nW]['dataSaida'],1,10),"-","")

								If !Empty(cCodLin)
									//INCLUI VIAGEM CASO NÃO EXISTA
									GYN->(DbSetOrder(2))	//GYN_FILIAL, GYN_LINCOD, GYN_CODGID, GYN_LINSEN, GYN_DTINI, GYN_HRINI, GYN_DTFIM, GYN_HRFIM, GYN_TIPO, R_E_C_N_O_, D_E_L_E_T_
									If lGeraViagem .And. (oMdlGID:GetValue('GID_MSBLQL') == '2') .And. !ExistViagem(nW, oModel, aDados, lGYN_EXTRA)
										lRet   := GTPXGerViag( cCodLin, oMdlGID:GetValue('GID_SENTID'), cCodHorario, cDtVInicial, /*dDtFim*/, /*aRecurso*/, /*cCodExcl*/, SRV_NORMAL, /*cCodContr*/, cValToChar(nKmProvavel), NIL, @aMsgRet, aCposGYN)
										If Len(aMsgRet) > 0
											cTexto := I18N( STR0009, {cCodLin,cCodHorario,Alltrim(aMsgRet[5]),aMsgRet[6]})	//'Falha na geração da Viagem: Código linha: #1 Código horário: #2 Msg: #3 #4'
										EndIf 
									EndIf 
								Else 
									lRet := .F.
									cTexto:= I18N(STR0010,{cCodHorario})	//'Falha na geração da Viagem: Linha não informado referente ao código horário: #1'
								Endif 
								If !lRet 
									cErro := I18N( STR0005, { cTexto,cExtID,cIntId})	// "Falha ao validar os dados da Horários #2 (#1)."
									If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
										GtpGrvLgRj(		STR0004,; //"Horários"
										oRJIntegra:cUrl,;
											oRJIntegra:cPath,;
											cRotina,;
											oRJIntegra:cParam,;
											cErro)
										aAdd(aError, cErro)
									Endif
								EndIf 								
							EndIf
						Endif
						oModel:DeActivate()
					EndIf
				EndIf
			Next nW

		Else
			lMonit := .F.	//Precisará efetuar o disarmTransaction
			FwAlertHelp("Não há dados a serem processados com a parametrização utilizada.")
		EndIf

	Else

		cErro := I18N( STR0006, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço (#1)."
		GtpGrvLgRj(		STR0004,; //"Horários"
		oRJIntegra:cUrl,;
			oRJIntegra:cPath,;
			cRotina,;
			oRJIntegra:cParam,;
			cErro)

	EndIf

	If !lJob
		If lMessage
			oMessage:SetText(STR0007) // "Processo finalizado."
			ProcessMessages()
		EndIf
	EndIf

	oRJIntegra:Destroy()
	GTPDestroy(oModel)
	GTPDestroy(oMdlGID)
	GTPDestroy(aFldsGID)
	GTPDestroy(aDPXXFGID)
	GTPDestroy(aFldsGIE)
	GTPDestroy(aDPXXFGIE)
	GTPDestroy(aGIEValues)
	cFilAnt := cFilBkp

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI004Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI002Job(aParams)
@param		aParam, array - lista de parÃ¢metros 	 	
@return 	
@author 	henrique.toyada
@since 		
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI004Job(aParam, lAuto)

	Local nPosEmp := 0
	Local nPosFil := 0

	Default lAuto := .F.

	nPosEmp := IF(Len(aParam) == 9, 6, 1)
	nPosFil := IF(Len(aParam) == 9, 7, 2)
//---Inicio Ambiente
	RPCSetType(3)
	RpcSetEnv(aParam[nPosEmp],aParam[nPosFil])

	If Len(aParam) == 9
		GI004Receb(.F., Nil, aParam[1], STOD(aParam[2]), aParam[3], STOD(aParam[4]), aParam[5],lAuto)
	Else
		GTPIRJ004(.F.,lAuto)
	EndIf

	RpcClearEnv()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetQtdeExtra

Função totalizador quantidade de lotação de piso extra

@type 		function
@sample 	GetQtdeExtra()
@param		
@return 	
@author 	jose.darocha
@since 		
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GetQtdeExtra(nX, aDados, nGYN_LOTACA)
	Local cPisoExt1:= aDados[nX]['pisoExtra1'] 
	Local cPisoExt2:= aDados[nX]['pisoExtra2'] 
	Local nPos       := 0
	Local nQtde		 := 0

	If !Empty(cPisoExt1)
		If (nPos:= AsCan(aDados,{|z| z['idServico'] == Val(cPisoExt1)})) > 0
			nQtde += aDados[nPos]['quantidadesAssentos']
		EndIf 
	EndIF 
	If !Empty(cPisoExt2)
		If (nPos:= AsCan(aDados,{|z| z['idServico'] == Val(cPisoExt2)})) > 0
			nQtde += aDados[nPos]['quantidadesAssentos']
		EndIf 
	EndIF 

	If nQtde > 0
		nGYN_LOTACA += nQtde
	EndIf 
Return Nil


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI004AUT

Função utilizada para consumir o serviço através de um JOB via Schedule

@type 		function
@sample 	GI004AUT()
@author 	João Pires
@since 		02/06/2026
@version 	1.0
/*/
//
//------------------------------------------------------------------------------------------
Function GI004AUT(aParam)
	GI004Receb(.T., Nil, aParam[1], aParam[2], aParam[3], aParam[4], aParam[5],.F.)
Return


/*/{Protheus.doc} ExistViagem
Verifica se existe viagem nos parametros informados, para nao tentar gerar uma viagem duplicada
@type function
@version 12.1.2410
@author vitor.rosa
@since 05/03/2026
@param nW, numeric, ponteiro do laço principal de processamento dos serviços
@param oModel, object, modelo de dados do MVC
@param aDados, array, array com os dados dos serviços retornados do JSON, utilizado para verificar os parametros da viagem a ser gerada
@param lExtra, logical, indica se o serviço é extra ou não, para verificar o tipo da viagem a ser gerada
@return logical, true se existir viagem, false se não existir
/*/
Static Function ExistViagem(nW as numeric, oModel as object, aDados as array, lExtra as logical)
	Local aServicos      as array
	Local aTrechos       as array
	Local cAlias         as character
	Local cCodHorario    as character
	Local cCodLin        as character
	Local cDataFinal     as character
	Local cDataInicio    as character
	Local cHoraFinal     as character
	Local cHoraInicio    as character
	Local cIdServico     as character
	Local cNumServico    as character
	Local cQuery         as character
	Local cSentidoViagem as character
	Local cViagemExtra   as character
	Local lRet           as logical
	Local oModelGID      as object
	Local oQuery         as object

	oModelGID      := oModel:GetModel( 'GIDMASTER' )
	cIdServico     := aDados[nW][ 'idServico' ]
	cNumServico    := aDados[nW][ 'numServico' ]
	cCodLin        := oModelGID:GetValue( 'GID_LINHA' )
	cCodHorario    := oModelGID:GetValue( 'GID_COD' )
	cSentidoViagem := oModelGID:GetValue( 'GID_SENTID' )
	aServicos      := {}
	aTrechos       := {}
	cViagemExtra   := Iif(lExtra, "T", "F")
	lRet           := .F.

	aTrechos := aDados[nW]['trechos']['trecho']
	aSort(aTrechos, , , {|x, y| x[ 'sequencia' ] < y[ 'sequencia' ]})

	cDataInicio := StrTran(SubStr(aTrechos[1][ 'dataInicioString' ],1,10),"-","")
	cHoraInicio := StrTran(aTrechos[1][ 'horaIncio' ],":","")
	cDataFinal  := StrTran(SubStr(aTrechos[Len(aTrechos)][ 'dataFinalString' ],1,10),"-","")
	cHoraFinal  := StrTran(aTrechos[Len(aTrechos)][ 'horaFinal' ],":","")
	
	cQuery := "SELECT" + CRLF
	cQuery += "1" + CRLF
	cQuery += "FROM" + CRLF
	cQuery += RetSQLName("GYN") + CRLF
	cQuery += "WHERE" + CRLF
	cQuery += "GYN_FILIAL = ?" + CRLF
	cQuery += "AND GYN_LINCOD = ?" + CRLF
	cQuery += "AND GYN_CODGID = ?" + CRLF
	cQuery += "AND GYN_LINSEN = ?" + CRLF
	cQuery += "AND GYN_DTINI = ?" + CRLF
	cQuery += "AND GYN_HRINI = ?" + CRLF
	cQuery += "AND GYN_DTFIM = ?" + CRLF
	cQuery += "AND GYN_HRFIM = ?" + CRLF
	cQuery += "AND GYN_TIPO = ?" + CRLF
	cQuery += "AND GYN_EXTRA = ?" + CRLF
	cQuery += "AND D_E_L_E_T_ = ' '"

	oQuery := FWExecStatement():New(cQuery)		
	oQuery:SetString(1, xFilial("GYN"))
	oQuery:SetString(2, cCodLin)
	oQuery:SetString(3, cCodHorario)
	oQuery:SetString(4, cSentidoViagem)
	oQuery:SetString(5, cDataInicio)
	oQuery:SetString(6, cHoraInicio)
	oQuery:SetString(7, cDataFinal)
	oQuery:SetString(8, cHoraFinal)
	oQuery:SetString(9, SRV_NORMAL)
	oQuery:SetString(10, cViagemExtra)

	cAlias := oQuery:OpenAlias()

	If (cAlias)->(!Eof())
		lRet := .T.
	EndIf

	(cAlias)->(DBCloseArea())

Return lRet

/*/{Protheus.doc} ExcluiHorTrechos
Exclui registros de horarios e trechos em caso de UPDATE
@type function
@version 12.1.2410
@author jose.darocha
@since 01/04/2026
@param cGID_COD, caracter, código do horário
@return Nulo
/*/
Static Function ExcluiHorTrechos( cGID_COD )
	Local aAreaAtu := GetArea()
	GIE->(DbSetOrder(1))
	If GIE->( DbSeek(xFilial("GIE") + cGID_COD ))
		While GIE->(!Eof()) .And. GIE->GIE_FILIAL == xFilial("GIE") .And. GIE->GIE_CODGID == cGID_COD
			RecLock("GIE",.F.)
			GIE->(DBDelete())
			GIE->(MsUnLock())
			GIE->(DbSkip())
		EndDo
	Endif		
	RestArea( aAreaAtu )
Return  
