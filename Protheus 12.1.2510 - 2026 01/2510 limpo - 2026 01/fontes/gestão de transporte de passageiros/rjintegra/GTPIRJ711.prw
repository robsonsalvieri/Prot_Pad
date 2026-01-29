#Include "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ711.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ711

Adapter REST da rotina de Tipo de Agência

@type 		function
@sample 	GTPIRJ711()
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	GTP
@since 		25/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ711(lJob)

Local aArea  := GetArea() 
Default lJob := .F. 

FwMsgRun( , {|oSelf| GI711Receb(lJob, oSelf)}, , STR0001)		// "Processando registros de Tipo de Agência... Aguarde!" 

RestArea(aArea)
GTPDestroy(aArea)

Return .T. 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI711Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI711Receb(cRestResult, oMessage)
@param 		oRJIntegra, objeto - classe que trata da integração
			oMessage, objeto   - trata a mensagem apresentada em tela
@return 	lRet, logical      - resultado do processamento da rotina (.T. / .F.)
@author 	GTP
@since 		20/05/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI711Receb(lJob, oMessage)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA711")
Local oMdlGI5	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GI5_FILIAL", "GI5_CODIGO"}
Local cIntID	  := ""
Local cIntAux	  := ""
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
Local nPos        := 0
Local nTotReg     := 0
Local lUpdt		  := .F.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'
Local cRotina	  := "GTPIRJ711"
Local aError	  := {}

oRJIntegra:SetPath("/tipoAgencia/todas")
oRJIntegra:SetServico('TipoAgencia')

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

If oRJIntegra:Get()

	oModel:SetCommit({ || CFGA070MNT("TotalBus", "GI5", "GI5_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGI5:GetValue('GI5_CODIGO'), 'GI5'))) },.T.)

	GI5->(DbSetOrder(1)) // GI5_FILIAL+GI5_CODIGO
	nTotReg := oRJIntegra:GetLenItens()
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )
		
		For nX := 0 To nTotReg
			lContinua := .T.
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Tipo de Agência - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf

			If !Empty((cExtID := oRJIntegra:GetJsonValue(nX, 'idTipo', 'C'))) 
				cCode := GTPxRetId("TotalBus", "GI5", "GI5_CODIGO", cExtID, @cIntID, 3, @lUpdt, @cErro, aCampos, 1)
				If Empty(cIntID)  
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lUpdt .And. GI5->(DbSeek(xFilial('GI5') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
						GtpGrvLgRj(		STR0008,; //"Tipo de Agência"
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
					oMdlGI5 := oModel:GetModel("GI5MASTER")

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
								xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lUpdt, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
							EndIf

							If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGI5:GetValue(cCampo)) 
								lContinua := oRJIntegra:SetValue(oMdlGI5, cCampo, xValor)
							ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
								lContinua := oRJIntegra:SetValue(oMdlGI5, cCampo, xValor)
							EndIf

							If !lContinua 
								cErro := I18N(STR0003, {cCampo, GTPXErro(oModel)})	// "Falha ao gravar o valor do campo #1 (#2)." 
								If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
									GtpGrvLgRj(		STR0008,; //"Tipo de Agência"
													oRJIntegra:cUrl,;
													oRJIntegra:cPath,;
													cRotina,;
													oRJIntegra:cParam,;
													cErro)
									aAdd(aError, cErro)
								Endif
								Exit	
							EndIf
						EndIf
					Next nY
					If lContinua .And. oModel:lModify
						lContinua := oModel:VldData() .And. oModel:CommitData()
						If !lContinua
							cErro := I18N(STR0009, {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao validar os dados do tipo agência #2 (#1)."
							If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
								GtpGrvLgRj(		STR0008,; //"Tipo de Agência"
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
		FwAlertHelp(STR0011)//"Não há dados a serem processados com a parametrização utilizada."
	EndIf
				
Else
	cErro := I18N( STR0010, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
	GtpGrvLgRj(		STR0008,; //"Tipo de Agência"
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
GTPDestroy(oMdlGI5)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI711Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI711Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	GTP
@since 		20/05/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI711Job(aParams)

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParams[1], aParams[2])

GTPIRJ711(.T.)

RpcClearEnv()

Return
