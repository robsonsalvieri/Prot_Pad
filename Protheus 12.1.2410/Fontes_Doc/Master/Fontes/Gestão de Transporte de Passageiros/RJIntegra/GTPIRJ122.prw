#Include "GTPIRJ122.ch"
#Include "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ122

Adapter REST da rotina de MAPA DE VIAGEM

@type 		function
@sample 	GTPIRJ122()
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@param 	 	aParams, logical - informações pertinentes ao processo para filtro (.T.) ou não (.F.)
@param 	 	lMonit, logical - indica se a chamada foi realizada através de monitor (.T.) ou não (.F.)
@param 	 	lAuto, logical - indica se a chamada foi realizada através de automação (.T.) ou não (.F.)
@param 	 	cResultAuto, char - Vindo de script de automação
@param 	 	cXmlAuto, char - Vindo de script de automação
@return		lRet, Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	João Pires
@since 		03/12/2024
@version 	1.0

/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ122(lJob,aParams,lMonit,lAuto,cResultAuto,cXmlAuto)

	Local aArea   := GetArea() 
	Local lRet    := .T.
	Local cEmpRJ  := nil
	Local dDtServ := nil
	Local cServ   := nil
	
	Default lJob 	    := .F. 
	Default aParams	    := {}
	Default lAuto       := .F.
	Default cResultAuto := ''
	Default cXmlAuto    := ''

	If ( Len(aParams) == 0 )
	
		If ( Pergunte('GTPIRJ122',!lJob) )

			cEmpRJ  := MV_PAR01
			dDtServ := MV_PAR02
			cServ   := MV_PAR03
			
		Else
			lRet := .F.
		EndIf

	ElseIf lJob

		cEmpRJ  := aParams[1]
		dDtServ := aParams[2]
		cServ   := aParams[3]
		
	EndIf

	If ( lRet )
		FwMsgRun( , {|oSelf| lRet := GI122Receb(lJob, oSelf, cEmpRJ, dDtServ, cServ ,@lMonit, lAuto,cResultAuto,cXmlAuto)}, , STR0001) //"Processando registros de mapa de viagem... Aguarde!"
	EndIF

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI122Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI122Receb(cRestResult, oMessage)
@param 		oRJIntegra, objeto - classe que trata da integração
			oMessage, objeto   - trata a mensagem apresentada em tela
@return 	lRet, logical      - resultado do processamento da rotina (.T. / .F.)
@author 	henrique.toyada
@since 		29/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI122Receb(lJob, oMessage, cEmpRJ, dDtServ, cServ, lMonit, lAuto, cResultAuto, cXmlAuto)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := Nil
Local oMdlH7X	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"H7X_FILIAL", "H7X_CODIGO"}
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
Local lOk		  := .F.
Local lRet        := .T.
Local lContinua   := .T.
Local lOnlyInsert := .F.
Local lOverWrite  := .F.
Local lMessage	  := ValType(oMessage) == 'O'
Local cDtServ     := ''

Local cRotina	  	:= "GTPIRJ122"

Default cEmpRJ      := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt)
Default dDtServ     := dDataBase-1
Default cServ       := '30009'
Default cResultAuto := ''
Default cXmlAuto    := ''

cDtServ := DTOS(dDtServ)

oRJIntegra:SetPath("/bilhete/viagem")
oRJIntegra:SetServico('MapaViagem')

oRJIntegra:SetParam('empresa'		 , ALLTRIM(cEmpRJ))
oRJIntegra:SetParam('dataServico'    , SUBSTR(cDtServ,3,Len(cDtServ)))
if !Empty(cServ)
	oRJIntegra:SetParam('servico'	     , ALLTRIM(cServ))
endif

aFldDePara	:= aClone(oRJIntegra:GetFieldDePara())
aDeParaXXF  := aClone(oRJIntegra:GetFldXXF())

If oRJIntegra:Get(cResultAuto)

	// Ordena tabela GIC para localizar a chave BPE 
	GIC->(DbSetorder(12))	// GIC_FILIAL + GIC_CHVBPE

	oModel:= FwLoadModel("GTPA115H")

	oModel:SetCommit({ || CFGA070MNT("TotalBus", "H7X", "H7X_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlH7X:GetValue('H7X_CODIGO'), 'H7X'))) },.T.)

	H7X->(DbSetOrder(1))	// HTX_FILIAL+H7X_CODIGO
	nTotReg := oRJIntegra:GetLenItens()
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )
		
		For nX := 0 To nTotReg 

			lContinua := .T.
			
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))  //"Processando registros de Viagens - #1/#2... Aguarde!"
				ProcessMessages()
			EndIf
			
			If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'chbpe', 'C','bilhete'))  

				//Localiza a chave bpe na tabela GIC para inclusão/alteração na tabela H7W
				If ! GIC->( DbSeek(xFilial("GIC") + cExtID ) )
					lContinua := .F.
					cErro := I18N(STR0003, {cExtID})	//"Não localizado Chave BPE no cadastro de bilhetes tabela GIC (#1)."
					GtpGrvLgRj(	STR0004,; //"Mapa de viagens"
								oRJIntegra:cUrl,;
								oRJIntegra:cPath,;
								cRotina,;
								oRJIntegra:cParam,;
								cErro)
					Loop

				EndIf
				 
				cCode := GTPxRetId("TotalBus", "H7X", "H7X_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)

				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. H7X->(DbSeek(xFilial('H7X') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					GtpGrvLgRj(	STR0004,; //"Mapa de viagem"
								oRJIntegra:cUrl,;
								oRJIntegra:cPath,;
								cRotina,;
								oRJIntegra:cParam,;
								cErro)
				EndIf
				
				If lContinua
											
						oModel:SetOperation(nOpc)
						oModel:Activate()
						oMdlH7X := oModel:GetModel("H7XMASTER")
						
						For nY := 1 To Len(aFldDePara)
							// recuperando a TAG e o respectivo campo da tabela 
							cTagName    := aFldDePara[nY][1]
							cCampo      := aFldDePara[nY][2]
							cTipoCpo    := aFldDePara[nY][3]
							lOnlyInsert := aFldDePara[nY][6]
							lOverWrite  := aFldDePara[nY][7]
							
							// recuperando através da TAG o valor a ser inserido no campo 
							If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo,'bilhete')))

								// verificando a necessidade de realizar o DePara XXF
								If cCampo == "H7X_AGENCI"
									xValor := AllTrim(cEmpRJ) + '|' + xValor //Campo na xxf é gravado composto empresa + "|" + id
								Endif

								If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
									xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
								EndIf
								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlH7X:GetValue(cCampo)) 
									lContinua := oRJIntegra:SetValue(oMdlH7X, cCampo, xValor)
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
									lContinua := oRJIntegra:SetValue(oMdlH7X, cCampo, xValor)
								EndIf

								If !lContinua
									cErro := I18N(STR0005 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
									GtpGrvLgRj(	STR0004,; //"Mapa de viagem"
												oRJIntegra:cUrl,;
												oRJIntegra:cPath,;
												cRotina,;
												oRJIntegra:cParam,;
												cErro)
								EndIf

							EndIf
						Next nY

						oRJIntegra:SetValue(oMdlH7X, 'H7X_EMPRJI', ALLTRIM(cEmpRJ))						

						If lContinua .And. oModel:lModify
							lContinua := oModel:VldData() .And. oModel:CommitData()
							If !lContinua
								cErro := I18N(STR0006, {GTPXErro(oModel),cExtID,cIntId})	//"Falha ao carregar modelos de dados (#1)."
									GtpGrvLgRj(	STR0004,; //"Mapa de viagem"
												oRJIntegra:cUrl,;
												oRJIntegra:cPath,;
												cRotina,;
												oRJIntegra:cParam,;
												cErro)
							EndIf
						Endif

						oModel:DeActivate()

				EndIf

			EndIf


		Next nX

	Else
		If !lJob
			lMonit := .F.	//Precisará efetuar o disarmTransaction
			FwAlertHelp(STR0007)	//"Não há dados a serem processados com a parametrização utilizada."
		EndIf 			
	EndIf

Else
	cErro := I18N( STR0008, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
	GtpGrvLgRj(	STR0004,; //"Mapa de viagem"
				oRJIntegra:cUrl,;
				oRJIntegra:cPath,;
				cRotina,;
				oRJIntegra:cParam,;
				cErro)
EndIf

If !lJob
	If lMessage
		oMessage:SetText(STR0009) // "Processo finalizado."
		ProcessMessages()
	EndIf
EndIf

oRJIntegra:Destroy()
GTPDestroy(oModel)
GTPDestroy(oMdlH7X)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI122Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI122Job(aParams,lAuto)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jose.darocha
@since 		04/09/2025
@version 	1.0
/*/          
//           1    2          3    
//GI122Job({'2','20250904','8690'})
//           |	 |	        |-> Código do serviço
//           |   |-> Data Serviço
//           |-> Código da empresa TotalBus
//------------------------------------------------------------------------------------------
Function GI122Job(aParam, lAuto)
Local nPosEmp  := 0 	//Posicao da empresa
Local nPosFil  := 0 	//Posicao da filial
Local lExecJOB := .T. 	//Executado via JOB

Default lAuto := .F.

nPosEmp := 4
nPosFil := 5

If ValType(aParam[2]) == 'C' .And. !Empty(aParam[2]) 
	aParam[2] := STOD(aParam[2])
Endif

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[nPosEmp],aParam[nPosFil])

GI122Receb(lExecJOB, Nil, aParam[1], aParam[2], aParam[3], Nil , lAuto)

RpcClearEnv()

Return
