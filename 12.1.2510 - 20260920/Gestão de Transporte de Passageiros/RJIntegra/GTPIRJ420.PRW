#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ420.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ420

Adapter REST da rotina de TIPOS DE DOCUMENTO 

@type 		function
@sample 	GTPIRJ420(lJOb)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		04/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ420(lJob)

Local aArea  := GetArea() 

Default lJob := .F. 

FwMsgRun( , {|oSelf| GI420Receb(lJob, oSelf)}, , STR0001)		// "Processando registros de Tipos de Documento... Aguarde!" 

RestArea(aArea)
GTPDestroy(aArea)

Return .T. 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI420Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI420Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI420Receb(lJob, oMessage)

GI420Processa(lJob, oMessage, "/TipoReceitaDespesa/todas", "TipoDocumento", "idTipo" )  
GI420Processa(lJob, oMessage, "/tipoEventoExtra", "TipoEventoExtra", "id" )

Return .T.


Static Function GI420Processa(lJob, oMessage, cMetodo, cServico, cTagId )
Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := FwLoadModel("GTPA420")
Local oMdlGZC	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"GZC_FILIAL", "GZC_CODIGO"}
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
Local lUpdt		  := .F.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'
Local cRotina	  := "GTPIRJ420"
Local aError	  := {}
Local oJsonResult := JsonObject():new()
Local aDados      := {}
Local cComplemen  := Iif(Empty(FwxFilial("GZC")),'','#'+FwxFilial('GZC'))

oModel:SetCommit({ || CFGA070MNT("TotalBus", "GZC", "GZC_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlGZC:GetValue('GZC_CODIGO'), 'GZC'))) },.T.)

oRJIntegra:SetPath(cMetodo)
oRJIntegra:SetServico(cServico)

aFldDePara	:= oRJIntegra:GetFieldDePara()
aDeParaXXF  := oRJIntegra:GetFldXXF()

oModel:GetModel('GZCMASTER'):GetStruct():SetProperty( "GZC_DESCRI" , MODEL_FIELD_WHEN  , {|| ALLWAYSTRUE()} ) 

If oRJIntegra:Get()
	GZC->(DbSetOrder(1))	// GZC_FILIAL+GZC_CODIGO
	oJsonResult:fromJson(oRJIntegra:cResult)
	
	If cTagId == 'idTipo' 
		aDados  := oJsonResult['tipoReceitaDespesa']
	Else 
		aDados  := oJsonResult['evento']
	EndIf
	nTotReg := Len(aDados)

	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 1 )

		For nX := 1 To nTotReg
			lContinua := .T.
			cErro     := ""
			If lMessage .And. !lJob
				If cServico == "TipoDocumento"
					oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1})) // "Processando registros de Tipos de Documento - #1/#2... Aguarde!" 
				Else
					oMessage:SetText(I18N(STR0010, {cValtoChar(nX + 1), nTotReg + 1})) // "Processando registros de eventos extras - #1/#2... Aguarde!"
				EndIf
				ProcessMessages()
			EndIf

			cExtID := cValToChar(aDados[nX][cTagId]) + cComplemen
			
			If !Empty(cExtID)
				cCode := GTPxRetId("TotalBus", "GZC", "GZC_CODIGO", cExtID, @cIntID, 3, @lUpdt, @cErro, aCampos, 1)
				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lUpdt .And. GZC->(DbSeek(xFilial('GZC') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
						GtpGrvLgRj(		STR0011,; //"Tipos de Documento"
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
					oMdlGZC	:= oModel:GetModel("GZCMASTER")

					For nY := 1 To Len(aFldDePara)
						// recuperando a TAG e o respectivo campo da tabela 
						cTagName    := aFldDePara[nY][1] 
						cCampo      := aFldDePara[nY][2]
						cTipoCpo    := aFldDePara[nY][3]
						lOnlyInsert := aFldDePara[nY][6]
						lOverWrite  := aFldDePara[nY][7]

						// recuperando através da TAG o valor a ser inserido no campo 
						If !Empty(cTagName) .And. !Empty((xValor := GTPCastType(aDados[nX][cTagName],cTipoCpo)))

							// verificando a necessidade de realizar o DePara XXF
							If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
								xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lUpdt, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
							EndIf

							If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlGZC:GetValue(cCampo))
								
								If lContinua
									If cCampo == "GZC_CODIGO"
										xValor:= GI420PrxNum()	 	
									EndIf
									
									lContinua := oMdlGZC:SetValue(cCampo, xValor)
								Endif
								
							ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
								
								If lContinua
									lContinua := oMdlGZC:SetValue(cCampo, xValor)
								Endif							

							EndIf

							If !lContinua 	
								cErro := I18N(STR0003, {cCampo, GTPXErro(oModel)}) //"Falha ao gravar o valor do campo #1 (#2)." 
								If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
									GtpGrvLgRj(		STR0011,; //"Tipos de Documento"
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
						If (nOpc == MODEL_OPERATION_INSERT)
							lContinua := oMdlGZC:SetValue('GZC_INCMAN'	,"2") .And. oMdlGZC:SetValue('GZC_PROPRI'	,"S")
						EndIf
						If lContinua .And. oModel:lModify
							lContinua := oModel:VldData() .And. oModel:CommitData()
						Endif
						If !lContinua
							cErro := I18N(STR0004, {GTPXErro(oModel)}) //"Falha ao gravar os dados (#1)." 
							If aScan(aError, {|x| AllTrim(x) == cErro}) == 0
								GtpGrvLgRj(		STR0011,; //"Tipos de Documento"
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
		FwAlertHelp(STR0012) //"Não há dados a serem processados com a parametrização utilizada."
	EndIf	
	
Else
	cErro := I18N(STR0013, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
	GtpGrvLgRj(		STR0011,; //"Tipos de Documento"
					oRJIntegra:cUrl,;
					oRJIntegra:cPath,;
					cRotina,;
					oRJIntegra:cParam,;
					cErro)
EndIf

If !lJob 
	If lMessage 
		oMessage:SetText(STR0007) //"Processo finalizado." 
		ProcessMessages()
	Else
		Alert(STR0007) //"Processo finalizado."
	endif
EndIf
oJsonResult:fromJson("{}")
oJsonResult := NIL
aSize(aDados, 0)
oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlGZC)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI420Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI420Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jacomo.fernandes
@since 		28/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GI420Job(aParam)

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[1], aParam[2])

GTPIRJ420(.T.)

RpcClearEnv()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI420PrxNum

Função utilizada para retornar o próximo número do Código automático

@type 		function
@sample 	GI420Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	gustavo.silva2
@since 		24/07/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------

Static Function GI420PrxNum()
Local cCodigo 	:= "100"
Local cAliasGZC	:= GetNextAlias()
Local cCodRet	:= ""

If ( AllTrim( Upper( TcGetDb() ) ) <> 'ORACLE' )
	BeginSql Alias cAliasGZC
	 		
		SELECT ISNULL(MAX(GZC_CODIGO),'000') CODIGO
	 	FROM %Table:GZC% GZC
		WHERE
		GZC.GZC_FILIAL = %xFilial:GZC%
		AND ISNUMERIC(GZC_CODIGO)=1
		AND GZC.%NotDel%
			      
	EndSql
	
	cCodRet:= (cAliasGZC)->CODIGO

Else
	BeginSql Alias cAliasGZC
		SELECT GZC.GZC_CODIGO CODIGO	
		FROM %Table:GZC% GZC
		WHERE GZC.GZC_FILIAL = %xFilial:GZC%
		AND GZC.%NotDel%
		ORDER BY GZC.GZC_CODIGO DESC
	EndSql

	While (cAliasGZC)->(!Eof())
		If IsNumeric((cAliasGZC)->CODIGO)
			cCodRet:= (cAliasGZC)->CODIGO
			Exit
		EndIf
	 (cAliasGZC)->(DBSKIP())
	EndDo

EndIf

	If Val(cCodRet) <= 100
		cCodigo := Soma1(cCodigo)
	Else
		cCodigo	:= GetSxEnum('GZC', 'GZC_CODIGO') //Soma1(cCodRet)
		CONFIRMSX8()
	EndIf

	(cAliasGZC)->(dbCloseArea())	

Return cCodigo
