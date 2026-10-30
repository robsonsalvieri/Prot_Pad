#Include "GTPIRJ119.ch"
#Include "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ119

Adapter REST da rotina de BILHETE no show

@type 		function
@sample 	GTPIRJ119()
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@param 	 	aParams, logical - informações pertinentes ao processo para filtro (.T.) ou não (.F.)
@param 	 	lMonit, logical - indica se a chamada foi realizada através de monitor (.T.) ou não (.F.)
@param 	 	lAuto, logical - indica se a chamada foi realizada através de automação (.T.) ou não (.F.)
@param 	 	cResultAuto, char - Vindo de script de automação
@param 	 	cXmlAuto, char - Vindo de script de automação
@return		lRet, Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	henrique.toyada
@since 		31/07/2019
@version 	1.0

/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ119(lJob,aParams,lMonit,lAuto,cResultAuto,cXmlAuto)

	Local aArea   := GetArea() 
	Local lRet    := .T.
	Local cEmpRJ  := nil
	Local dDtIni  := nil
	Local cHrIni  := nil
	Local dDtFim  := nil
	Local cHrFim  := nil
	Local cAgeIni := nil
	Local cAgeFim := nil

	Default lJob 	    := .F. 
	Default aParams	    := {}
	Default lAuto       := .F.
	Default cResultAuto := ''
	Default cXmlAuto    := ''

	If ( Len(aParams) == 0 )
	
		If ( Pergunte('GTPIRJ119',!lJob) )

			cEmpRJ  := MV_PAR01
			dDtIni  := MV_PAR02
			cHrIni  := MV_PAR03
			dDtFim  := MV_PAR04
			cHrFim  := MV_PAR05
			cAgeIni := AllTrim(MV_PAR06)
			cAgeFim := AllTrim(MV_PAR07)
		Else
			lRet := .F.
		EndIf

	ElseIf lJob

		cEmpRJ  := aParams[1]
		dDtIni  := aParams[2]
		cHrIni  := aParams[3]
		dDtFim  := aParams[4]
		cHrFim  := aParams[5]
		cAgeIni := aParams[6]
		cAgeFim := aParams[7]

	EndIf

	If ( lRet )
		FwMsgRun( , {|oSelf| lRet := GI119Receb(lJob, oSelf, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim,@lMonit, lAuto,cResultAuto,cXmlAuto)}, , "Processando registros de Bilhetes... Aguarde!") //"Processando registros de Bilhetes... Aguarde!"
	EndIF

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI119Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI119Receb(cRestResult, oMessage)
@param 		oRJIntegra, objeto - classe que trata da integração
			oMessage, objeto   - trata a mensagem apresentada em tela
@return 	lRet, logical      - resultado do processamento da rotina (.T. / .F.)
@author 	henrique.toyada
@since 		29/03/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI119Receb(lJob, oMessage, cEmpRJ, dDtIni, cHrIni, dDtFim, cHrFim, cAgeIni, cAgeFim, lMonit, lAuto, cResultAuto, cXmlAuto)

Local oRJIntegra  := GtpRjIntegra():New()
Local oModel	  := Nil
Local oMdlH7W	  := Nil
Local aFldDePara  := {}
Local aDeParaXXF  := {}
Local aCampos	  := {"H7W_FILIAL", "H7W_CODIGO"}
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

Local cRotina	  	:= "GTPIRJ119"

Default cEmpRJ      := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt)
Default dDtIni      := dDataBase-1
Default cHrIni      := '0000'
Default dDtFim      := dDataBase-1
Default cHrFim      := '2359'
Default cAgeIni     := ''
Default cAgeFim     := ''
Default cResultAuto := ''
Default cXmlAuto    := ''

oRJIntegra:SetPath("naoEmbarque/buscarEventoNaoEmbarque")
oRJIntegra:SetServico('BilheteNoShow')

oRJIntegra:SetParam('empresa'		 , ALLTRIM(cEmpRJ))
oRJIntegra:SetParam('dataHoraInicial', Left(FWTimeStamp(1, dDtIni),8) + STRTRAN(cHrIni,":",""))
oRJIntegra:SetParam('dataHoraFinal'	 , Left(FWTimeStamp(1, dDtFim),8) + STRTRAN(cHrFim,":",""))

If !Empty(cAgeIni)
	oRJIntegra:SetParam('agenciaInicio', AllTrim(cAgeIni))
Endif
If !Empty(cAgeFim)
	oRJIntegra:SetParam('agenciaFim', AllTrim(cAgeFim))
Endif

aFldDePara	:= aClone(oRJIntegra:GetFieldDePara())
aDeParaXXF  := aClone(oRJIntegra:GetFldXXF())

If oRJIntegra:Get(cResultAuto)

	// Ordena tabela GIC para localizar a chave BPE 
	GIC->(DbSetorder(12))	// GIC_FILIAL + GIC_CHVBPE

	oModel:= FwLoadModel("GTPA115G")

	oModel:SetCommit({ || CFGA070MNT("TotalBus", "H7W", "H7W_CODIGO", cExtID, IIF(!Empty(cIntId), cIntId, GTPxMakeId(oMdlH7W:GetValue('H7W_CODIGO'), 'H7W'))) },.T.)

	H7W->(DbSetOrder(1))	// HTW_FILIAL+H7W_CODIGO
	nTotReg := oRJIntegra:GetLenItens()
	
	nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

	If ( nTotReg >= 0 )
		
		For nX := 0 To nTotReg 

			lContinua := .T.
			
			If lMessage .And. !lJob
				oMessage:SetText(I18N(STR0001, {cValtoChar(nX + 1), nTotReg + 1}))  //"Processando registros de Bilhetes - #1/#2... Aguarde!"
				ProcessMessages()
			EndIf
			
			If !Empty(cExtID := oRJIntegra:GetJsonValue(nX, 'chaveAcesso', 'C'))  

				//Localiza a chave bpe na tabela GIC para inclusão/alteração na tabela H7W
				If ! GIC->( DbSeek(xFilial("GIC") + cExtID ) )
					lContinua := .F.
					cErro := I18N(STR0002, {cExtID})	//"Não localizado Chave BPE no cadastro de bilhetes tabela GIC (#1)."
					GtpGrvLgRj(	STR0003,; //"Eventos não embarque"
								oRJIntegra:cUrl,;
								oRJIntegra:cPath,;
								cRotina,;
								oRJIntegra:cParam,;
								cErro)
					Loop

				EndIf
				 
				cCode := GTPxRetId("TotalBus", "H7W", "H7W_CODIGO", cExtID, @cIntID, 3, @lOk, @cErro, aCampos, 1)

				If Empty(cIntID) 
					nOpc := MODEL_OPERATION_INSERT
				ElseIf lOk .And. H7W->(DbSeek(xFilial('H7W') + cCode))
					nOpc := MODEL_OPERATION_UPDATE
				Else
					lContinua := .F.
					GtpGrvLgRj(	STR0003,; //"Eventos não embarque"
								oRJIntegra:cUrl,;
								oRJIntegra:cPath,;
								cRotina,;
								oRJIntegra:cParam,;
								cErro)
				EndIf
				
				If lContinua
											
						oModel:SetOperation(nOpc)
						oModel:Activate()
						oMdlH7W := oModel:GetModel("H7WMASTER")
						
						For nY := 1 To Len(aFldDePara)
							// recuperando a TAG e o respectivo campo da tabela 
							cTagName    := aFldDePara[nY][1]
							cCampo      := aFldDePara[nY][2]
							cTipoCpo    := aFldDePara[nY][3]
							lOnlyInsert := aFldDePara[nY][6]
							lOverWrite  := aFldDePara[nY][7]
							
							// recuperando através da TAG o valor a ser inserido no campo 
							If !Empty(cTagName) .And. !Empty((xValor := oRJIntegra:GetJsonValue(nX, cTagName, cTipoCpo)))

								If cTagName == "dhEvento"  .and. cCampo == "H7W_HREVEN"
									xValor := substr(xValor,12,8)
								EndIf 

								// verificando a necessidade de realizar o DePara XXF
								If (nPos := aScan(aDeParaXXF, {|x| x[1] == cCampo})) > 0
									xValor := GTPxRetId("TotalBus", aDeParaXXF[nPos, 2], aDeParaXXF[nPos, 3], xValor, @cIntAux, aDeParaXXF[nPos, 4], @lOk, @cErro, aDeParaXXF[nPos, 6], aDeParaXXF[nPos, 5])
								EndIf
								If nOpc == MODEL_OPERATION_INSERT .And. lOnlyInsert .And. Empty(oMdlH7W:GetValue(cCampo)) 
									lContinua := oRJIntegra:SetValue(oMdlH7W, cCampo, xValor)
								ElseIf (nOpc == MODEL_OPERATION_INSERT .And. !lOnlyInsert) .Or. (nOpc == MODEL_OPERATION_UPDATE .And. lOverWrite) 
									lContinua := oRJIntegra:SetValue(oMdlH7W, cCampo, xValor)
								EndIf

								If !lContinua
									cErro := I18N(STR0004 , {GTPXErro(oModel),cExtID,cIntId})	// "Falha ao gravar o valor do campo #1 (#2)."
									GtpGrvLgRj(	STR0003,; //"Eventos não embarque"
												oRJIntegra:cUrl,;
												oRJIntegra:cPath,;
												cRotina,;
												oRJIntegra:cParam,;
												cErro)
								EndIf

							EndIf
						Next nY

						oRJIntegra:SetValue(oMdlH7W, 'H7W_EMPRJI', ALLTRIM(cEmpRJ))						

						If lContinua .And. oModel:lModify
							lContinua := oModel:VldData() .And. oModel:CommitData()
							If !lContinua
								cErro := I18N(STR0005, {GTPXErro(oModel),cExtID,cIntId})	//"Falha ao carregar modelos de dados (#1)."
									GtpGrvLgRj(	STR0003,; //"Eventos não embarque"
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
		lMonit := .F.	//Precisará efetuar o disarmTransaction
		If !lJob
			FwAlertHelp(STR0006)	//"Não há dados a serem processados com a parametrização utilizada."
		EndIf 			
	EndIf

Else
	cErro := I18N( STR0007, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
	GtpGrvLgRj(	STR0003,; //"Eventos não embarque"
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
GTPDestroy(oMdlH7W)
GTPDestroy(aFldDePara)
GTPDestroy(aDeParaXXF)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI119Job

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI119Job(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jose.darocha
@since 		04/09/2025
@version 	1.0
/*/          
//           1    2          3       4          5       6     7
//GI119Job({'3','20250904','00:00','20250904','23:59','001','002'})
//          |    |          |        |      	|		|	  |-> Agência TotalBus Final
//          |    |          |        |          |       |-> Agência TotalBus Inicial
//          |    |          |        |          |-> Hora Final   
//          |    |          |        |-> Data Final
//          |    |          |-> Hora Inicio
//          |    |-> Data Inicio
//          |-> Código da empresa TotalBus
//------------------------------------------------------------------------------------------
Function GI119Job(aParam, lAuto)
Local nPosEmp := 0	 		//Posicao da empresa
Local nPosFil := 0	 		//Posicao da filial
Local lExecJOB:= .T. 		//Executado via JOB

Default lAuto := .F.

nPosEmp := IF(Len(aParam) == 11, 8, IF(Len(aParam) == 9, 6, 1))
nPosFil := IF(Len(aParam) == 11, 9, IF(Len(aParam) == 9, 7, 2))

If ValType(aParam[2]) == 'C'
	aParam[2] := STOD(aParam[2])
Endif

If ValType(aParam[4]) == 'C'
	aParam[4] := STOD(aParam[4])
Endif

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[nPosEmp],aParam[nPosFil])

If Len(aParam) == 11
	GI119Receb(lExecJOB, Nil, aParam[1], aParam[2], aParam[3], aParam[4], aParam[5], aParam[6], aParam[7],,lAuto)
ElseIf Len(aParam) == 9
	GI119Receb(lExecJOB, Nil, aParam[1], aParam[2], aParam[3], aParam[4], aParam[5], NIL      ,  NIL     ,,lAuto)
EndIf

RpcClearEnv()

Return

