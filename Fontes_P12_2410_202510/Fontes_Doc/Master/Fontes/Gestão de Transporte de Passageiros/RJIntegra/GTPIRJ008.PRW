#Include "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ008.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ008

Adapter REST da rotina de COLABORADORES

@type 		function
@sample 	GTPIRJ008(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ008(lJob,lAutomation)

	Local aArea  := GetArea()
	Local lRet   := .T.

	Default lJob := .F.
	DefaulT lAutomation := .F.

	If ( !lJob )
		FwMsgRun( , {|oSelf| lRet := GI008Receb(lJob, oSelf, lAutomation)}, , STR0001)		// "Processando registros de Colaboradores... Aguarde!"
	Else
		lRet := GI008Receb(lJob, , lAutomation)
	EndIf

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI008Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI008Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI008Receb(lJob, oMessage,lAutomation)

	Local oRJIntegra  := GtpRjIntegra():New()
	Local oModel	  := FwLoadModel("GTPA008")
	Local oStruGYG    := oModel:GetModel('GYGMASTER'):GetStruct()
	Local oMdlGYG	  := Nil
	Local aFldDePara  := {}
	Local aDeParaXXF  := {}
	Local aCampos	  := {"GYG_FILIAL", "GYG_CODIGO"}
	Local cIntID	  := ""
	Local cIntAux     := ""
	Local cExtID	  := ""
	Local cCode		  := ""
	Local cErro		  := ""
	Local cTagName    := ""
	Local cCampo      := ""
	Local cTipoCpo    := ""
	Local xValor      := ""
	Local nX          := 0
	Local nY          := 0
	Local nOpc		  := 0
	Local nTotReg     := 0
	Local lOk		  := .F.
	Local lRet        := .T.
	Local lContinua   := .T.
	Local lOnlyInsert := .F.
	Local lOverWrite  := .F.
	Local lMessage	  := ValType(oMessage) == 'O'
	Local cResultRest	:= ""
	Local aAutomation	:= {}
	Local cRotina	  	:= "GTPIRJ008"
	Local aError	  	:= {}

	oStruGYG:SetProperty('GYG_DTNASC', MODEL_FIELD_OBRIGAT, .F.)

	oRJIntegra:SetPath("/usuarios/todos")

	If ( lAutomation )

		aAutomation := aClone(SetAutomation())

		oRJIntegra:SetServico("Localidade",,,aAutomation[1])
		cResultRest := aAutomation[2]

	Else
		oRJIntegra:SetServico("Colaborador")
	EndIf

	aFldDePara	:= oRJIntegra:GetFieldDePara()
	aDeParaXXF  := oRJIntegra:GetFldXXF()

	If oRJIntegra:Get(cResultRest)

		oModel:SetCommit({ || CFGA070MNT("TotalBus", "GYG", "GYG_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGYG:GetValue('GYG_CODIGO'), 'GYG'))) },.T.)

		GYG->(DbSetOrder(1))	// GYG_FILIAL+GYG_CODIGO
		nTotReg := oRJIntegra:GetLenItens()
		For nX := 0 To nTotReg
			lContinua := .T.
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Colaboradores - #1/#2... Aguarde!"
				ProcessMessages()
			EndIf

			If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idUsuario' ,'C'))
				cCode := GTPxRetId("TotalBus", "GYG", "GYG_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)
				If Empty(cIntID)
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. GYG->(DbSeek(xFilial('GYG') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
						GtpGrvLgRj(		STR0008,; //"Colaboradores"
										oRJIntegra:cUrl,;
										oRJIntegra:cPath,;
										cRotina,;
										oRJIntegra:cParam,;
										cErro)
						aAdd(aError, cErro)
					Endif
				EndIf

				If lContinua
					oModel:SetOperation(nOpc)
					oModel:Activate()
					oMdlGYG	:= oModel:GetModel("GYGMASTER")

					For nY := 1 To Len(aFldDePara)
						// recuperando a TAG e o respectivo campo da tabela
						cTagName    := aFldDePara[nY][1]
						cCampo      := aFldDePara[nY][2]
						cTipoCpo    := aFldDePara[nY][3]
						lOnlyInsert := aFldDePara[nY][6]
						lOverWrite  := aFldDePara[nY][7]

						// recuperando através da TAG o valor a ser inserido no campo
						If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)))

							// verificando a necessidade de realizar o DePara XXF
							If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
								xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
							EndIf

							If cCampo == 'GYG_NOME'
								xValor := Substr(xValor, 1, TamSx3("GYG_NOME")[1])
							Endif

							If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGYG:GetValue(cCampo))
								lContinua := oRJIntegra:SetValue(oMdlGYG, cCampo, xValor)
							ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite)
								lContinua := oRJIntegra:SetValue(oMdlGYG, cCampo, xValor)
							EndIf

							If lContinua .And. cCampo == 'GYG_CPF' .And. !Empty(xValor)
								GetMatricula(oMdlGYG, xValor)
							Endif

							If !lContinua
								cErro := I18N(STR0003 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
								If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
									GtpGrvLgRj(		STR0008,; //"Colaboradores"
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
					Next nY

					If lContinua .And. oModel:lModify
						lContinua := oModel:VldData() .And. oModel:CommitData()
						If !lContinua
							cErro := I18N(STR0009, {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao validar os dados do Colaborador #2 (#1)."
							If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
								GtpGrvLgRj(		STR0008,; //"Colaboradores"
												oRJIntegra:cUrl,;
												oRJIntegra:cPath,;
												cRotina,;
												oRJIntegra:cParam,;
												cErro)
								aAdd(aError, cErro)
							Endif
						EndIf
					Endif
					oModel:DeActivate()

				EndIf
			EndIf

		Next nX
	Else
		cErro := I18N( STR0006, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
		GtpGrvLgRj(		STR0008,; //"Colaboradores"
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
	GTPDestroy(oMdlGYG)
	GTPDestroy(aFldDePara)
	GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI008Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI008Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI008Job(aParam)

//---Inicio Ambiente
	RPCSetType(3)
	RpcSetEnv(aParam[1], aParam[2])

	GTPIRJ008(.T.,.T.)

	RpcClearEnv()

Return


Static Function SetAutomation()

	Local cXMLAuto	:= ""
	Local cJsonAuto	:= ""

	cXMLAuto := '<?xml version="1.0" encoding="UTF-8"?>'
	cXMLAuto += '<RJIntegra>'
	cXMLAuto += '<Colaborador tagMainList="Usuario">'
	cXMLAuto += '	<ListOfFields>'
	cXMLAuto += '		<Field>'
	cXMLAuto += '			<tagName>idUsuario</tagName>'
	cXMLAuto += '			<fieldProtheus>GYG_CODIGO</fieldProtheus>'
	cXMLAuto += '			<onlyInsert>True</onlyInsert>'
	cXMLAuto += '			<overwrite>False</overwrite>'
	cXMLAuto += '		</Field>'
	cXMLAuto += '		<Field>'
	cXMLAuto += '			<tagName>nomeUsuario</tagName>'
	cXMLAuto += '			<fieldProtheus>GYG_NOME</fieldProtheus>'
	cXMLAuto += '			<onlyInsert>False</onlyInsert>'
	cXMLAuto += '			<overwrite>True</overwrite>'
	cXMLAuto += '		</Field>'
	cXMLAuto += '		<Field>'
	cXMLAuto += '			<tagName />'
	cXMLAuto += '			<fieldProtheus>GYG_RG</fieldProtheus>'
	cXMLAuto += '			<onlyInsert>False</onlyInsert>'
	cXMLAuto += '			<overwrite>True</overwrite>'
	cXMLAuto += '		</Field>'
	cXMLAuto += '		<Field>'
	cXMLAuto += '			<tagName>numCPF</tagName>'
	cXMLAuto += '			<fieldProtheus>GYG_CPF</fieldProtheus>'
	cXMLAuto += '			<onlyInsert>False</onlyInsert>'
	cXMLAuto += '			<overwrite>True</overwrite>'
	cXMLAuto += '		</Field>'
	cXMLAuto += '		<Field>'
	cXMLAuto += '			<tagName>dataNascimento</tagName>'
	cXMLAuto += '			<fieldProtheus>GYG_DTNASC</fieldProtheus>'
	cXMLAuto += '			<onlyInsert>False</onlyInsert>'
	cXMLAuto += '			<overwrite>True</overwrite>'
	cXMLAuto += '		</Field>'
	cXMLAuto += '		<Field>'
	cXMLAuto += '			<tagName>idAgencia</tagName>'
	cXMLAuto += '			<fieldProtheus>GYG_AGENCI</fieldProtheus>'
	cXMLAuto += '			<onlyInsert>False</onlyInsert>'
	cXMLAuto += '			<overwrite>True</overwrite>'
	cXMLAuto += '			<DeParaXXF>'
	cXMLAuto += '			<Alias>GI6</Alias>'
	cXMLAuto += '			<XXF_Field>GI6_CODIGO</XXF_Field>'
	cXMLAuto += '			<ColumnNumber>3</ColumnNumber>'
	cXMLAuto += '			<IndiceOrder>1</IndiceOrder>'
	cXMLAuto += '			<ListOfSeekField>'
	cXMLAuto += '				<SeekField>GI6_FILIAL</SeekField>'
	cXMLAuto += '				<SeekField>GI6_CODIGO</SeekField>'
	cXMLAuto += '			</ListOfSeekField>'
	cXMLAuto += '			</DeParaXXF>'
	cXMLAuto += '		</Field>'
	cXMLAuto += '		<Field>'
	cXMLAuto += '			<tagName>idLocalidade</tagName>'
	cXMLAuto += '			<fieldProtheus>GYG_LOCPAD</fieldProtheus>'
	cXMLAuto += '			<onlyInsert>False</onlyInsert>'
	cXMLAuto += '			<overwrite>True</overwrite>'
	cXMLAuto += '			<DeParaXXF>'
	cXMLAuto += '			<Alias>GI1</Alias>'
	cXMLAuto += '			<XXF_Field>GI1_CODIGO</XXF_Field>'
	cXMLAuto += '			<ColumnNumber>3</ColumnNumber>'
	cXMLAuto += '			<IndiceOrder>1</IndiceOrder>'
	cXMLAuto += '			<ListOfSeekField>'
	cXMLAuto += '				<SeekField>GI1_FILIAL</SeekField>'
	cXMLAuto += '				<SeekField>GI1_CODIGO</SeekField>'
	cXMLAuto += '			</ListOfSeekField>'
	cXMLAuto += '			</DeParaXXF>'
	cXMLAuto += '		</Field>'
	cXMLAuto += '	</ListOfFields>'
	cXMLAuto += '</Colaborador>'
	cXMLAuto += '</RJIntegra>'

	cJsonAuto := '{"Usuario":['
	cJsonAuto += '		{'
	cJsonAuto += '			"idUsuario": 216,'
	cJsonAuto += '			"nomeUsuario": "ALEXANDREIBIAPINA.",'
	cJsonAuto += '			"numCPF": "",'
	cJsonAuto += '			"dataNascimento": "",'
	cJsonAuto += '			"idLocalidade": "12077",'
	cJsonAuto += '			"descLocalidade": "PICOS - PI",'
	cJsonAuto += '			"idAgencia": "105",'
	cJsonAuto += '			"descAgencia": "RODOVIARIA DE PICOS",'
	cJsonAuto += '			"Login": "10G016"'
	cJsonAuto += '		}'
	cJsonAuto += '   ]'
	cJsonAuto += '}'

Return({cXmlAuto,cJsonAuto})

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetMatricula(oMdlGYG,cCpf)

@type Static Function
@author jacomo.fernandes
@since 16/01/2020
@version 1.0
@param oMdlGYG, object, (Descrição do parâmetro)
@param cCpf, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function GetMatricula(oMdlGYG,cCpf)
Local lRet      := .T.
Local cAliasTmp := GetNextAlias()

BeginSql Alias cAliasTmp
    Select 
		SRA.RA_FILIAL,
		SRA.RA_MAT
	From %Table:SRA% SRA
	Where
		SRA.RA_FILIAL LIKE %Exp:AllTrim(xFilial('GYG'))% || '%'
		AND SRA.RA_SITFOLH NOT IN ('D','T')
		AND SRA.RA_CIC = %Exp:cCPF%
		and SRA.%NotDel%
	Order By
		SRA.RA_FILIAL,
		SRA.RA_MAT

EndSql

If (cAliasTmp)->(!Eof())
    lRet := oMdlGYG:LoadValue('GYG_FUNCIO',(cAliasTmp)->RA_MAT)
    lRet := lRet .and. oMdlGYG:LoadValue('GYG_FILSRA',(cAliasTmp)->RA_FILIAL)
Endif

(cAliasTmp)->(DbCloseArea())

Return lRet
