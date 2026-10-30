#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ051.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ051

Adapter REST da rotina de Motivos de Cancelamento

@type 		function
@sample 	GTPIRJ051(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ051(lJob)

Local aArea  := GetArea() 

Default lJob := .F. 

FwMsgRun( , {|oSelf| GI051Receb(lJob, oSelf)}, , STR0001 ) // "Processando registros de Órgãos Concedentes... Aguarde!" 

RestArea(aArea)
GTPDestroy(aArea)

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI051Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI051Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI051Receb(lJob, oMessage)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA051")
Local oMdlGYC	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GYC_FILIAL", "GYC_CODIGO"}
Local aError	  := {}
Local cIntID	  := ""
Local cRotina	  := "GTPIRJ051"
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
Local lUpdt		  := .F.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'

oRJIntegra:SetPath("/tipoCancelamento/todos")
oRJIntegra:SetServico("TipoCancelamento")

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

If oRJIntegra:Get()

	oModel:SetCommit({ || CFGA070MNT("TotalBus", "GYC", "GYC_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGYC:GetValue('GYC_CODIGO'), 'GYC'))) },.T.)
	GYC->(DbSetOrder(1)) //GYC_FILIAL+GYC_CODIGO
	nTotReg := oRJIntegra:GetLenItens()	

	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )

		For nX := 0 To nTotReg
			lContinua := .T.
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Motivos de Cancelamento - #1/#2... Aguarde!" 
				ProcessMessages()
			EndIf
			
			If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'idTipo' ,'C'))
				cCode := GTPxRetId("TotalBus", "GYC", "GYC_CODIGO", cExtID, @cIntID, 3, @lUpdt, @cErro, aCampos, 1)
				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lUpdt .And. GYC->(DbSeek(xFilial('GYC') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
						GtpGrvLgRj(		STR0003,; //"Motivo de Cancelamento"
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
					oMdlGYC	:= oModel:GetModel("GYCMASTER")

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

							If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGYC:GetValue(cCampo)) 
								lContinua := oRJIntegra:SetValue(oMdlGYC, cCampo, xValor)
							ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
								lContinua := oRJIntegra:SetValue(oMdlGYC, cCampo, xValor)
							EndIf

							If !lContinua 
								cErro := I18N(STR0004, {cCampo, GTPXErro(oModel)}) //"Falha ao gravar o valor do campo #1 (#2)." 
								If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
									GtpGrvLgRj(		STR0003,; //"Motivo de Cancelamento
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
						
					If lContinua 						
				
						(lContinua := oModel:VldData() .and. oModel:CommitData())						

						If !lContinua
							cErro := I18N(STR0005, {GTPXErro(oModel)}) //"Falha ao gravar os dados (#1)." 
							If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
								GtpGrvLgRj(		STR0003,; //"Motivo de Cancelamento"
												oRJIntegra:cUrl,;
												oRJIntegra:cPath,;
												cRotina,;
												oRJIntegra:cParam,;
												cErro)
							Endif
						EndIf
					EndIf
					oModel:DeActivate()
				EndIf
			EndIf
		Next nX	

	Else
		FwAlertHelp(STR0006) //"Não há dados a serem processados com a parametrização utilizada."
	EndIf
	
Else
	cErro := I18N(STR0007, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
	GtpGrvLgRj(		STR0003,; //"Motivo de Cancelamento
					oRJIntegra:cUrl,;
					oRJIntegra:cPath,;
					cRotina,;
					oRJIntegra:cParam,;
					cErro)
EndIf

If !lJob
	If lMessage 
		oMessage:SetText(STR0008) // "Processo finalizado." 
		ProcessMessages()
	EndIf	
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGYC)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI051Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI051Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI051Job(aParam)

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[1], aParam[2])

GTPIRJ051(.T.)

RpcClearEnv()

Return
