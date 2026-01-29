#INCLUDE 'PROTHEUS.CH'                
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'


/*/{Protheus.doc} AGRI830
Funcao de integracao com o adapter EAI envio de informações de Engenheiros AGRA830
utilizando o conceito de mensagem unica JSON
@type function
@version 12
@author carlos.augusto
@since 17/10/2025
/*/
Function AGRI830( oEAIObEt, nTypeTrans, cTypeMessage ) 

	Local aErroAuto := {}
	Local aContato	:= {}	
	Local cAlias    := "NP8"
	Local cCampo    := "NP8_CODIGO"
	Local cEvento   := "upsert"
	Local cMsgUnica := "AGRA830"
	Local lRet      := .T. 
	Local lDelete	:= .F.
	Local ofwEAIObj	:= FwEAIobj():New()
	Local oModel    := NIL
	Local nInfoFed  := 0

	
	Default	oEAIObEt := Nil
	
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	
	Do Case
		//--------------------------------------
		//envio mensagem
		//--------------------------------------
		Case nTypeTrans == TRANS_SEND
			oModel := FwModelActive()
			
			If lDelete := !ALTERA .AND. !INCLUI
				cEvento := 'delete'
			EndIf		

			//Montagem da mensagem
			ofwEAIObj:Activate()
			ofwEAIObj:setEvent(cEvento)	
		
			ofwEAIObj:setprop("CompanyId", cEmpAnt)
			ofwEAIObj:setprop("BranchId", cFilAnt)
			ofwEAIObj:setprop("CompanyInternalId", cEmpAnt + '|' + cFilAnt)
			ofwEAIObj:setprop("Code", ALLTRIM(NP8->NP8_CODIGO))
			ofwEAIObj:setprop("InternalId", getIDInt(NP8->NP8_CODIGO))

			IF SUPERGETMV("MV_SIGAAGD", .f., .f.) 
				ofwEAIObj:setprop("ExternalId", getIDExt(NP8->NP8_CODIGO))
			Endif

			If !Empty(NP8->NP8_NOME)
				ofwEAIObj:setprop("Name", ALLTRIM(NP8->NP8_NOME))
			EndIf
			
			If !Empty(NP8->NP8_CPF)
				nInfoFed++
				ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
       			ofwEAIObj:get("GovernmentalInformation")[nInfoFed]:setprop("Name" , "CPF",,.T.)
	        	ofwEAIObj:get("GovernmentalInformation")[nInfoFed]:setprop("Scope", "Federal",,.T.)
	        	ofwEAIObj:get("GovernmentalInformation")[nInfoFed]:setprop("Id"   , Alltrim(NP8->NP8_CPF),,.T.)	
			EndIf
			If !Empty(NP8->NP8_RENASE)
				nInfoFed++
				ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
       			ofwEAIObj:get("GovernmentalInformation")[nInfoFed]:setprop("Name" , "Número do RENASEM",,.T.)
	        	ofwEAIObj:get("GovernmentalInformation")[nInfoFed]:setprop("Scope", "Federal",,.T.)
	        	ofwEAIObj:get("GovernmentalInformation")[nInfoFed]:setprop("Id"   , Alltrim(NP8->NP8_RENASE),,.T.)
			EndIf
			If !Empty(NP8->NP8_CREA)
				nInfoFed++
				ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
       			ofwEAIObj:get("GovernmentalInformation")[nInfoFed]:setprop("Name" , "CREA",,.T.)
	        	ofwEAIObj:get("GovernmentalInformation")[nInfoFed]:setprop("Scope", "Federal",,.T.)
	        	ofwEAIObj:get("GovernmentalInformation")[nInfoFed]:setprop("Id"   , Alltrim(NP8->NP8_CREA),,.T.)
			Endif
			
			If !Empty(NP8->NP8_ENDER) .Or. !Empty(NP8->NP8_CODMUN) .Or. !Empty(NP8->NP8_EST) .Or. !Empty(NP8->NP8_CEP)
				oAddress := ofwEAIObj:setprop("Address")
				If !Empty(NP8->NP8_ENDER)
					oAddress:setprop("Address", ALLTRIM(NP8->NP8_ENDER) )
				EndIf

				If !Empty(NP8->NP8_CODMUN)
					oAddress:setprop("City")
					oAddress:getPropValue("City"):setprop("CityCode", ALLTRIM(NP8->NP8_CODMUN) )
					oAddress:getPropValue("City"):setprop("CityInternalId", ALLTRIM(cEmpAnt) + '|' + ALLTRIM(cFilAnt) + '|' +  ALLTRIM(NP8->NP8_CODMUN) )
					oAddress:getPropValue("City"):setprop("CityDescription", ALLTRIM( POSICIONE("CC2", 1, XFILIAL("CC2")+NP8->NP8_EST+NP8->NP8_CODMUN, "CC2_MUN")) )
				EndIf
				If !Empty(NP8->NP8_EST)
					oAddress:setprop("State")
					oAddress:getPropValue("State"):setprop("stateId", ALLTRIM(NP8->NP8_EST) )
					oAddress:getPropValue("State"):setprop("StateInternalId", ALLTRIM(cEmpAnt) + '|' + ALLTRIM(cFilAnt) + '|' +  ALLTRIM(NP8->NP8_EST) )
					oAddress:getPropValue("State"):setprop("StateDescription", Alltrim(POSICIONE("SX5",1,xFilial("SX5")+"12"+NP8->NP8_EST,"X5_DESCRI")) )
				EndIf
				If !Empty(NP8->NP8_CEP)
					oAddress:setprop("ZIPCode", ALLTRIM(NP8->NP8_CEP) )
				EndIf
			EndIf
			
			If !Empty(NP8->NP8_NUMTEL) .Or. !Empty(NP8->NP8_EMAIL)
				ofwEAIObj:setprop('ListOfCommunicationInformation',{},'CommunicationInformation',,.T.)
				ofwEAIObj:get("ListOfCommunicationInformation")[1]:setprop("PhoneNumber", Alltrim(NP8->NP8_NUMTEL),,.T.)
				ofwEAIObj:get("ListOfCommunicationInformation")[1]:setprop("Email", Alltrim(NP8->NP8_EMAIL),,.T.)
			EndIf
						
			//Exclui o De/Para 
			If lDelete
				CFGA070MNT(NIL, cAlias, cCampo, NIL, getIDInt(NP8->NP8_CODIGO), lDelete)
			Endif
		
		//--------------------------------------
		//Recebimento mensagem
		//--------------------------------------	
		Case nTypeTrans == TRANS_RECEIVE .And. Type("oEAIObEt") != Nil
			//Nao implementado
		
	EndCase

	aSize(aContato,0)
	aContato := {}

	aSize(aErroAuto, 0)
	aErroAuto := {}

Return { lRet, ofwEAIObj, cMsgUnica }

/*/{Protheus.doc} getIDInt
Retorna o Codigo Interno
@type function
@version 12
@author jean.schulze
@since 15/10/2025
@param codigo, character, codigo
@return variant, id
/*/
Static Function getIDInt(codigo)
	Local cEmpresa := cEmpAnt
	Local cFil     := xFilial('NP8')
return cEmpresa + '|' + cFil + '|' + codigo

/*/{Protheus.doc} getIDExt
Retorna o Codigo Externo Conforme DE-PARA padrao
@type function
@version 12
@author jean.schulze
@since 15/10/2025
@param codigo, character, codigo
@return variant, id
/*/
Static Function getIDExt(codigo)
	Local ofeatureDTO  := agdTCOSolicitacaoExternaReceituarioDTO():new()
	Local cCodeInteg   := ofeatureDTO:getIdentificaoIntegracao()
	Local cIdInter     := getIDInt(codigo)
return CFGA070Ext(cCodeInteg, "NP8", "NP8_CODIGO", cIdInter)
