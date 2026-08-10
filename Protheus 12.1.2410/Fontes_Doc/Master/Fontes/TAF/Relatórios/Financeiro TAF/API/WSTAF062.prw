#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF062
WS para retorno das informações de requisições do Relatório FIN x TAF

@author Rafael de Paula Leme
@since 23/05/2024
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSRESTFUL WSTAF062 DESCRIPTION "API Rel. FIN x TAF - Controle de requisições V3A"

	WSDATA companyId           AS STRING
	WSDATA idRequest           AS STRING OPTIONAL
	WSDATA page			       AS INTEGER OPTIONAL
	WSDATA pageSize		       AS INTEGER OPTIONAL

	WSMETHOD POST requestReport;
		DESCRIPTION "Grava a requisição e inicia o processamento do relatório";
		WSSYNTAX "/requestReport";
		PATH "requestReport";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET procesStatus;
		DESCRIPTION "Retorna o status do processamento do relatório";
		WSSYNTAX "/procesStatus";
		PATH "procesStatus";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET serviceStatus;
		DESCRIPTION "Retorna o status do Serviço Smart Schedule";
		WSSYNTAX "/serviceStatus";
		PATH "serviceStatus";
		PRODUCES APPLICATION_JSON

	WSMETHOD DELETE procesCancel;
		DESCRIPTION "Cancela o processamento do relatório";
		WSSYNTAX "/procesCancel";
		PATH "procesCancel";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET reportDetail;
		DESCRIPTION "Retorna os dados do processamento finalizado";
		WSSYNTAX "/reportDetail";
		PATH "reportDetail";
		PRODUCES APPLICATION_JSON		

	WSMETHOD GET totalizer;
		DESCRIPTION "Retorna os totais para os cards";
		WSSYNTAX "/totalizer";
		PATH "totalizer";
		PRODUCES APPLICATION_JSON	

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Método responsável por recepcionar os parâmetros e iniciar o processamento do relatório..
@author			Rafael de Paula Leme
@since			24/05/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD POST requestReport PATHPARAM companyId, idRequest WSREST WSTAF062

	Local oRequest		as object
	Local oResponse		as object
	Local oTask1        as object
	Local oTask2        as object
	Local aCompany      as array
	Local aRetorno      as array
	Local lRet          as logical
	Local lAutomato     as logical
	Local cFilRequest	as character
	Local cEmpRequest   as character
	Local cID           as character
	Local cAutoADVPR    as character

	oRequest	:=	JsonObject():New()
	oResponse	:=	JsonObject():New()
	oTask1      := Nil
	oTask2      := Nil
	aCompany    := {}
	aRetorno    := {}
	lRet        := .T.
	lAutomato   := .F.
	cFilRequest	:= ""
	cEmpRequest := ""
	cID         := ""
	cAutoADVPR  := self:Getheader( "Content-Advpr" )

	If valtype( cAutoADVPR ) == 'C' .And. !Empty(cAutoADVPR) .And. "WSTAF062" $ Upper(cAutoADVPR)
		lAutomato := .T.
	EndIf

	self:SetContentType("application/json")

	If Empty(self:GetContent())
		lRet := .F.
		SetRestFault(400, EncodeUTF8("Corpo da requisição não enviado."))
	ElseIf self:companyId == Nil
		lRet := .F.
		SetRestFault(400, EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId'."))
	Else
		oRequest:FromJson(self:GetContent())
		If Empty(oRequest["branchId"])
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Filial não informada no parâmetro 'branchId'."))
		ElseIf Empty(oRequest["initialDate"])
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Data inicial não informada no parâmetro 'initialDate'."))
		ElseIf Empty(oRequest["finalDate"])
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Data final não informada no parâmetro 'finalDate'."))
		ElseIf Empty(oRequest["group"]) .or. oRequest["group"] <> 2
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Evento não informado no parâmetro 'group'. "))
		ElseIf Empty(oRequest["emissionLow"]) .or. (oRequest["emissionLow"] <> 1 .and. oRequest["emissionLow"] <> 2 .and. oRequest["emissionLow"] <> 3) //Remover .or. após correção do setDefaultValues no front
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Emissão ou baixa não informado no parâmetro 'emissionLow'.")) 
		ElseIf Empty(oRequest["typeDatePayable"]) .or. (oRequest["typeDatePayable"] <> 1 .and. oRequest["typeDatePayable"] <> 2) //Remover .or. após correção do setDefaultValues no front
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Data Emissão ou Baixa não informado no parâmetro 'typeDatePayable'."))
		ElseIf Empty(oRequest["onlyTaf"]) .or. (oRequest["onlyTaf"] <> 1 .and. oRequest["onlyTaf"] <> 2 .and. oRequest["onlyTaf"] <> 3) //Remover .or. após correção do setDefaultValues no front
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Apenas enviado ao TAF não informado no parâmetro 'onlyTaf'."))
		ElseIf Empty(oRequest["onlyDivergent"]) .or. (oRequest["onlyDivergent"] <> 1 .and. oRequest["onlyDivergent"] <> 2) //Remover .or. após correção do setDefaultValues no front
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Somente divergentes não informado no parâmetro 'onlyDivergent'."))	
		Else
			aCompany := StrTokArr(self:companyId, "|")

			If Len(aCompany) < 2
				lRet := .F.
				SetRestFault(400, EncodeUTF8("Tamanho Empresa|Filial informado no parâmetro 'companyId' menor que o esperado"))
			Else
				cEmpRequest := aCompany[1]
				cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())

				If PrepEnv(cEmpRequest, cFilRequest)

					// Caso seja enviado o idRequest faço a exclusão dos registros antes de iniciar o processamento
					If self:idRequest <> Nil
						CancelProces(cFilRequest, self:idRequest)
					EndIf

					// Verifico se existe algum processamento para o usuário logado
					aRetorno := BuscaProces(cFilRequest,, __cUserID)
						
					If Len(aRetorno) > 0
						oResponse["id"]                        := aRetorno[1]    // V3A_ID
						oResponse["status"]                    := aRetorno[2]    // 0-Agendado 1-Em processamento 2-Concluído
						oResponse["params"]                    := JsonObject():New()
						oResponse["params"]["branchId"]        := aRetorno[3][1] // Filial 
						oResponse["params"]["initialDate"]     := aRetorno[3][2] // Data inicio
						oResponse["params"]["finalDate"]       := aRetorno[3][3] // Data fim
						oResponse["params"]["group"]           := aRetorno[3][4] // Grupo Bloco 20 e Bloco 40
						oResponse["params"]["emissionLow"]     := aRetorno[3][5] // Emissão ou Baixa
						oResponse["params"]["typeDatePayable"] := aRetorno[3][6] // Data títulos a pagar
						oResponse["params"]["onlyTaf"]         := aRetorno[3][7] // Somente Reinf
						oResponse["params"]["onlyDivergent"]   := aRetorno[3][8] // Somente Divergentes
					Else
						//Chamo a função para fazer o agendamento do processamento
						cID := InicProces(cFilRequest, oRequest, self:GetContent(), __cUserID, @oTask1, @oTask2, lAutomato)

						oResponse["id"] := cID 
						
						if Empty(cID)
							oResponse["status"] := '' 
						Else
							oResponse["status"] := '0'
						EndIf

					EndIf
		
					self:SetResponse(oResponse:ToJson())	
				Else
					lRet := .F.
					SetRestFault(400, EncodeUTF8("Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'."))
				Endif
			EndIf
		EndIf
	EndIf

	FreeObj(oRequest)
	FreeObj(oResponse)

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET
@type		 method
@description Método responsável retornar o status de um processamento
@author		 Rafael de Paula Leme
@since		 24/05/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET procesStatus PATHPARAM companyId, idRequest WSREST WSTAF062

	Local oRequest		as object
	Local oResponse		as object
	Local aCompany      as array
	Local aRetorno      as array
	Local lRet          as logical
	Local cFilRequest	as character
	Local cEmpRequest   as character
	Local cMsg          as character
	Local cWng1 		as character
	Local cWng2 		as character
	Local cWng3 		as character
	Local cStatus       as character

	oRequest	:=	JsonObject():New()
	oResponse	:=	JsonObject():New()
	aCompany    := {}
	aRetorno    := {}	
	lRet        := .T.
	cFilRequest	:= ''
	cEmpRequest := ''
	cMsg		:= ''
	cWng1   	:= ' Funcionalidade apenas para clientes que utilizam o TAF e Financeiro como módulo Protheus e possuam Movimentos no Contas a Pagar.'
	cWng2   	:= ' Campos ausentes na base para o correto funcionamento dessa rotina.'  //'Ausência de metadados no dicionário.'	
	cWng3   	:= ' O Repositório de funções está desatualizado.' //'Não existe a função de integração do Financeiro.' ou 'Não existe a função de criação de task.'
	cStatus 	:= ''

	self:SetContentType("application/json")

	If self:companyId == Nil
		lRet := .F.
		SetRestFault(400, EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId'."))		
	Else
		aCompany := StrTokArr(self:companyId, "|")

		If Len(aCompany) < 2
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Tamanho Empresa|Filial informado no parâmetro 'companyId' menor que o esperado"))
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())

			If PrepEnv(cEmpRequest, cFilRequest)
				oRequest:FromJSON(self:GetContent())
				
				if TemRegSE2()
					cWng1 := ''
				endif
				if TafPreCondSS()
					cWng2 := ''
				endif
				if FindSSTafInteg() .And. FindSSCreate()
					cWng3 := ''
				endif
				//Os warnings mudam o status e travam o uso da rotina: ausencia de registros no financeiro para comparar, metadados, funcoes nao compiladas...
				cMsg := cWng1 + cWng2 + cWng3
				if !Empty(cMsg)
					cStatus := 'noOk'
				endif

				if cStatus <> 'noOk'
					If self:idRequest == Nil .or. Empty(AllTrim(self:idRequest))
						aRetorno := BuscaProces(cFilRequest,, __cUserID)
					Else
						aRetorno := BuscaProces(cFilRequest, self:idRequest)
					EndIf

					If Len(aRetorno) > 0
						oResponse["id"]                        := aRetorno[1]    // V3A_ID
						oResponse["status"]                    := aRetorno[2]    // 0-Agendado 1-Em processamento 2-Concluído 3-Erro
						oResponse["messageService"] 		   := EncodeUTF8(cMsg)
						oResponse["params"]                    := JsonObject():New()
						oResponse["params"]["branchId"]        := aRetorno[3][1] // Filial 
						oResponse["params"]["initialDate"]     := aRetorno[3][2] // Data inicio
						oResponse["params"]["finalDate"]       := aRetorno[3][3] // Data fim
						oResponse["params"]["group"]           := aRetorno[3][4] // Grupo - Bloco 20 e Bloco 40
						oResponse["params"]["emissionLow"]     := aRetorno[3][5] // Emissão ou Baixa
						oResponse["params"]["typeDatePayable"] := aRetorno[3][6] // Data títulos a pagar
						oResponse["params"]["onlyTaf"]         := aRetorno[3][7] // Somente Reinf
						oResponse["params"]["onlyDivergent"]   := aRetorno[3][8] // Somente Divergentes
					else
						//Caso nao localize o cIdRequest ou o processo do usuário significa que ainda nao foi agendado,
						//ou seja configurou todas as precondicoes mas ainda nao realizou processamento
						oResponse["id"] := ''
						oResponse["status"] := 'noProcess'
						oResponse["messageService"] := EncodeUTF8(cMsg)
					EndIf
				else
					//Aqui o status quando existe falha nas precondicoes e trava o painel para uso
					oResponse["id"] := ''
					oResponse["status"] := 'noOk'
					oResponse["messageService"] := EncodeUTF8(cMsg)
				endif

				self:SetResponse(oResponse:ToJson())
			Else
				lRet := .F.
				SetRestFault(400, EncodeUTF8("Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'."))
			EndIf
		EndIf
	EndIf

	FreeObj(oRequest)
	FreeObj(oResponse)

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET serviceStatus
@type		 method
@description Método responsável retornar o status do servico Smart Schedule
@author		 Denis Souza
@since		 12/08/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET serviceStatus PATHPARAM companyId WSREST WSTAF062

	Local oRequest		as object
	Local oResponse		as object
	Local aCompany      as array
	Local lRet          as logical
	Local lStatus       as logical
	Local lAutomato     as logical
	Local cFilRequest	as character
	Local cEmpRequest   as character
	Local cAutoADVPR    as character
	Local cCode		    as character
    Local cUser		    as character
    Local cModule	    as character  
    Local cRoutine 	    as character 
	Local cEnv          as character

	oRequest	:=	JsonObject():New()
	oResponse	:=	JsonObject():New()
	aCompany    := {}
	lRet        := .T.
	lStatus 	:= .F.
	lAutomato   := .F.
	cFilRequest	:= ''
	cEmpRequest := ''
	cAutoADVPR  := self:Getheader( "Content-Advpr" )
	cCode		:= "LS006"  
    cUser		:= RetCodUsr()
    cModule	    := "84"     
    cRoutine 	:= "TAFRELFIN" 	
	cEnv        := TafSchdRun()

	If valtype( cAutoADVPR ) == 'C' .And. !Empty(cAutoADVPR) .And. "WSTAF062" $ Upper(cAutoADVPR)
		lAutomato := .T.
	EndIf

	self:SetContentType("application/json")

	If self:companyId == Nil 
		lRet := .F.
		SetRestFault(400, EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId'."))		
	Else
		aCompany := StrTokArr(self:companyId, "|")

		If Len(aCompany) < 2
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Tamanho Empresa|Filial informado no parâmetro 'companyId' menor que o esperado"))
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())
		Endif

		If PrepEnv(cEmpRequest, cFilRequest)
			oRequest:FromJSON(self:GetContent())						
			If (TafSSEnable() .And. TafSSRunning()) .or. !Empty(cEnv) .or. lAutomato
				lStatus := .T.
				//Registra o Uso da Rotina no License Server                    
				FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine)
			endif
			oResponse["status"] := lStatus
			self:SetResponse(oResponse:ToJson())				
		Else
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'."))
		EndIf
	EndIf

	FreeObj(oRequest)
	FreeObj(oResponse)

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PUT
@type		 method
@description Método responsável por cancelar um processamento em andamento e deletar os registros das tabelas.
@author		 Rafael de Paula Leme
@since		 24/05/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------

WSMETHOD DELETE procesCancel PATHPARAM companyId, idRequest WSREST WSTAF062

	Local oRequest		as object
	Local oResponse		as object
	Local aCompany      as array
	Local aRetorno      as array
	Local lRet          as logical
	Local cFilRequest	as character
	Local cEmpRequest   as character

	oRequest	:=	JsonObject():New()
	oResponse	:=	JsonObject():New()	
	aCompany    := {}
	aRetorno    := {}	
	lRet        := .T.	
	cFilRequest	:= ""
	cEmpRequest := ""

	self:SetContentType("application/json")

	If self:companyId == Nil
		lRet := .F.
		SetRestFault(400, EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId'."))
	ElseIf self:idRequest == Nil
		lRet := .F.
		SetRestFault(400, EncodeUTF8("ID não informado no parâmetro 'idRequest'."))
	Else
		aCompany := StrTokArr(self:companyId, "|")

		If Len(aCompany) < 2
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Tamanho Empresa|Filial informado no parâmetro 'companyId' menor que o esperado"))
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())

			If PrepEnv(cEmpRequest, cFilRequest)
				oRequest:FromJSON(self:GetContent())

				// Deleto o processamento informado (ID) nas tabelas V3A e filhas
				lRet := CancelProces(cFilRequest, self:idRequest)

  				oResponse["canceled"] := lRet
				self:SetResponse(oResponse:ToJson())
			Else
				lRet := .F.
				SetRestFault(400, EncodeUTF8("Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'."))
			EndIf
		EndIf
	EndIf

	FreeObj(oRequest)
	FreeObj(oResponse)

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET
@type		 method
@description Método responsável por retornar os dados do processamento
@author		 Rafael de Paula Leme
@since		 27/05/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET reportDetail PATHPARAM companyId, idRequest, page, pageSize, WSREST WSTAF062

	Local oRequest		as object
	Local oResponse		as object
	Local aCompany      as array
	Local aAliasRep     as array
	Local lRet          as logical
	Local cFilRequest	as character
	Local cEmpRequest   as character

	oRequest	:=	JsonObject():New()
	oResponse	:=	JsonObject():New()
	aCompany    := {}
	aAliasRep   := {}	
	lRet        := .T.	
	cFilRequest	:= ""
	cEmpRequest := ""

	self:SetContentType("application/json")

	If self:companyId == Nil
		lRet := .F.
		SetRestFault(400, EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId'."))
	ElseIf self:idRequest == Nil
		lRet := .F.
		SetRestFault(400, EncodeUTF8("ID não informado no parâmetro 'idRequest'."))
	Else
		aCompany := StrTokArr(self:companyId, "|")

		If Len(aCompany) < 2
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Tamanho Empresa|Filial informado no parâmetro 'companyId' menor que o esperado"))
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())

			If PrepEnv(cEmpRequest, cFilRequest)
				oRequest:FromJSON(cFilRequest, self:GetContent())

				oResponse["reportDetail"] := {}

				// Executo query para busca dos registros conforme ID informado
				aAliasRep := GetReport(cFilRequest, self:idRequest, self:page, self:pageSize)

				GetJsonRep(aAliasRep, @oResponse)
			
				self:SetResponse(oResponse:ToJson())
			Else
				lRet := .F.
				SetRestFault(400, EncodeUTF8("Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'."))
			EndIf
		EndIf
	EndIf

	FreeObj(oRequest)
	FreeObj(oResponse)

Return lRet

/*/{Protheus.doc} BuscaProces
@type        function
@description Busca um processamento na V3A
@author      Rafael de Paula Leme
@since       24/05/2024
@return

/*/
//-------------------------------------------------------------------
Static Function BuscaProces(cFilRequest as character, cIdRequest as character, cUsuRequest as character)
	
	Local aRetorno  as array
	Local cChave    as character
	Local oReqBusca as Json

	Default cFilRequest := ""
	Default cIdRequest  := ""
	Default cUsuRequest := ""

	aRetorno  := {}
	cChave    := ""
	oReqBusca := Nil

	DBSelectArea("V3A")

	If !Empty(cIdRequest)
		V3A->(DBSetOrder(1))
		cChave := cFilRequest + cIdRequest
	Else
		V3A->(DBSetOrder(2))
		cChave := cFilRequest + cUsuRequest
	EndIf
	
	If V3A->(DbSeek(cChave))
		oReqBusca := JsonObject():New()
		oReqBusca:FromJson(V3A->V3A_PARAMS)
		aRetorno := {V3A->V3A_ID, V3A->V3A_STATUS, {oReqBusca["branchId"], oReqBusca["initialDate"],;
					oReqBusca["finalDate"], oReqBusca["group"], oReqBusca["emissionLow"],;
					oReqBusca["typeDatePayable"], oReqBusca["onlyTaf"], oReqBusca["onlyDivergent"]}}
	EndIf

	FreeObj(oReqBusca)

Return aRetorno

/*/{Protheus.doc} InicProces
@type        function
@description Grava a requisição na V3A e inicia inicia o processamento
@author      Rafael de Paula Leme
@since       24/05/2024
@return

/*/
//-------------------------------------------------------------------
Static Function InicProces(cFilRequest as character, oRequest as Json, cBody as Character, cUsuRequest as character, oTask1 as object, oTask2 as object, lAutomato as logical)

	Local aPerguntas as array
	Local aMVParams  as array
	Local cId        as character
	Local lEnableSS  as logical
	Local lRunningSS as logical
	Local cEnv       as character

	Default cFilRequest := ""
	Default cUsuRequest := ""
	Default lAutomato   := .F.

	aPerguntas := {}
	aMVParams  := Array(1, "")
	cId  := ""

	cEnv := TafSchdRun() //Retorna os Environments que estão com o schedule em execução.
	lEnableSS  := TafSSEnable()  //Smart schedule esta habilitado?
	lRunningSS := TafSSRunning() //Smart schedule em execução?

	If lAutomato
		lEnableSS  := .T.
		lRunningSS := .T.
		If oRequest['idTestCase'] <> Nil
			If oRequest['idTestCase'] == "WSTAF06245"
        		lEnableSS  := .F.
				lRunningSS := .F.
			EndIf
    	EndIf
	EndIf
	
	If (lEnableSS .And. lRunningSS) .or. !Empty(cEnv)
		If RecLock("V3A", .T.)
			V3A->V3A_FILIAL	:= cFilRequest
			V3A->V3A_ID     := cID := TAFGeraID("TAF")
			V3A->V3A_DTREQ	:= Date()
			V3A->V3A_HRREQ	:= StrTran(Time(), ":", "")
			V3A->V3A_STATUS	:= '0' // 0-Não iniciado 1-Em processamento 2-Concluído 3-Erro no processamento
			V3A->V3A_PARAMS	:= cBody
			V3A->V3A_USER	:= cUsuRequest
			V3A->V3A_STSFIN := '0'
			V3A->V3A_STSTAF := '0'
			V3A->(MsUnlock())
		EndIf
		If Empty(cEnv)
			cEnv := GetEnvServer()
		Endif
	EndIf

	If !Empty(cId)
		Iif(!lAutomato,aMVParams[1] := AllTrim(cID),)
		oTask1 := totvs.framework.schedule.utils.createTask(cEnv, /*cEmpAnt*/, cFilRequest, 'TAFA625', 84, cUsuRequest, '', aMVParams, /*lReuse*/, .F.)
		If oRequest['onlyTaf'] <> 2
			oTask2 := totvs.framework.schedule.utils.createTask(cEnv, /*cEmpAnt*/, cFilRequest, 'TAFA626', 84, cUsuRequest, '', aMVParams, /*lReuse*/, .F.)
		EndIf
	EndIf

Return cID

/*/{Protheus.doc} CancelProces
@type        function
@description Cancela um processamento 
@author      Rafael de Paula Leme
@since       24/05/2024
@return

/*/
//-------------------------------------------------------------------
Static Function CancelProces(cFilRequest as character, cIdRequest as character)

	Local lRet       as logical
	Local cQuery   	 as character
	Local oPrepQuery as object
	
	Default cFilRequest := ""
	Default cIdRequest  := ""

	lRet   := .T.
	cQuery := ''
	oPrepQuery := FWPreparedStatement():New()

	cQuery += " DELETE FROM " + RetSqlName("V3A") + " WHERE "
	cQuery += " V3A_FILIAL = ?"
	cQuery += " AND V3A_ID = ?"

	oPrepQuery:SetQuery(cQuery)
	oPrepQuery:SetString(1,cFilRequest)
	oPrepQuery:SetString(2,cIdRequest)

	cQuery := oPrepQuery:getFixQuery()
	lRet := TCSQLExec(cQuery) >= 0

	oPrepQuery:Destroy()

	If lRet
		oPrepQuery := FWPreparedStatement():New()

		cQuery := ''
		cQuery += " DELETE FROM " + RetSqlName("V5I") + " WHERE "
		cQuery += " V5I_FILIAL = ?"
		cQuery += " AND V5I_IDREQ = ?"

		oPrepQuery:SetQuery(cQuery)
		oPrepQuery:SetString(1,cFilRequest)
		oPrepQuery:SetString(2,cIdRequest)

		cQuery := oPrepQuery:getFixQuery()
		lRet := TCSQLExec(cQuery) >= 0

		oPrepQuery:Destroy()

	EndIf

	If lRet
		oPrepQuery := FWPreparedStatement():New()
	
		cQuery := ''
		cQuery += " DELETE FROM " + RetSqlName("V58") + " WHERE "
		cQuery += " V58_FILIAL = ?"
		cQuery += " AND V58_IDREQ = ?"

		oPrepQuery:SetQuery(cQuery)
		oPrepQuery:SetString(1,cFilRequest)
		oPrepQuery:SetString(2,cIdRequest)

		cQuery := oPrepQuery:getFixQuery()
		lRet := TCSQLExec(cQuery) >= 0

		oPrepQuery:Destroy()

	EndIf

	If lRet
		oPrepQuery := FWPreparedStatement():New()

		cQuery := ''
		cQuery += " DELETE FROM " + RetSqlName("V5W") + " WHERE "
		cQuery += " V5W_FILIAL = ?"
		cQuery += " AND V5W_IDREQ = ?"

		oPrepQuery:SetQuery(cQuery)
		oPrepQuery:SetString(1,cFilRequest)
		oPrepQuery:SetString(2,cIdRequest)

		cQuery := oPrepQuery:getFixQuery()
		lRet := TCSQLExec(cQuery) >= 0

		oPrepQuery:Destroy()
	EndIf

	If lRet
		oPrepQuery := FWPreparedStatement():New()

		cQuery := ''
		cQuery += " DELETE FROM " + RetSqlName("V44") + " WHERE "
		cQuery += " V44_FILIAL = ?"
		cQuery += " AND V44_IDREQ = ?"

		oPrepQuery:SetQuery(cQuery)
		oPrepQuery:SetString(1,cFilRequest)
		oPrepQuery:SetString(2,cIdRequest)

		cQuery := oPrepQuery:getFixQuery()
		lRet := TCSQLExec(cQuery) >= 0

		oPrepQuery:Destroy()

	EndIf

Return lRet

/*/{Protheus.doc} GetReport
@type        function
@description Retorna os dados processados para exibição
@author      Rafael de Paula Leme
@since       24/05/2024
@return

/*/
//-------------------------------------------------------------------
Static Function GetReport(cFilRequest as character, cIdRequest as character, nPage as numeric, nPageSize as numeric)

	Local oPrepV5W  as object
	Local lHasNext  as logical
	Local nTotReg   as numeric
	Local nIndBind  as numeric
	Local cAlias    as character
	Local cQuery    as character
	Local cBd       as character

	Default cFilRequest := ""
	Default cIdRequest  := ""
	Default nPage 	    := 1
    Default nPageSize 	:= 100

	oPrepV5W  := Nil
	lHasNext  := .F.
	nTotReg   := 0
	nIndBind  := 1
	cAlias    := ""
	cQuery    := ""
	cBd	      := Upper(AllTrim(TcGetDb()))

	cQuery += " SELECT "
	cQuery += " V5W.V5W_ID ID, V5W.V5W_EMISBX EMISBX, "
	cQuery += " V5W.V5W_DIVERG DIVERG, V5W.V5W_ERP ERP, V5W.V5W_TAF TAF, V5W.V5W_FILTIT FILTIT, "
	cQuery += " V5W.V5W_PREFIX PREFIX, V5W.V5W_NUMERO NUMTIT, V5W.V5W_NATTIT NATTIT, "
	cQuery += " V5W.V5W_DTEMIS DTEMIS, V5W.V5W_CODPAR CODPAR, V5W.V5W_CPFCGC CFPCGC, "
	cQuery += " V5W.V5W_NOME NOMPAR, "
	cQuery += " SUM(V5W.V5W_VLBRER) VLBRER, "
	cQuery += " SUM(V5W.V5W_VLBRTA) VLBRTA, "
	cQuery += " V5W.V5W_SEQUEN SEQUEN, V5W.V5W_ENVTAF ENVTAF, "
	cQuery += " V44.V44_NATREN NATREN, V44.V44_DECTER DECTER,  "
	cQuery += " COALESCE(SUM(V44.V44_VALOR),0)  VALNAT, "
	cQuery += " COALESCE(SUM(V44.V44_VALIR),0)  VALIR,  "
	cQuery += " COALESCE(SUM(V44.V44_VALPIS),0) VALPIS, "
	cQuery += " COALESCE(SUM(V44.V44_VALCOF),0) VALCOF, " 
	cQuery += " COALESCE(SUM(V44.V44_VALCSL),0) VALCSL, "
	cQuery += " COALESCE(SUM(V44.V44_VLAGRG),0) VLAGRG  "

	cQuery += " FROM "
	cQuery += RetSqlName("V5W") + " V5W "

	cQuery += " LEFT JOIN " + RetSqlName("V44") + " V44 ON V44.V44_FILIAL = V5W.V5W_FILIAL "
    cQuery += " AND V44.V44_IDV5W = V5W.V5W_ID "
    cQuery += " AND V44.D_E_L_E_T_ = ? "

	cQuery += " WHERE "
	cQuery += " V5W.V5W_FILIAL = ? " 
	cQuery += " AND V5W.V5W_IDREQ = ? "
	cQuery += " AND V5W.D_E_L_E_T_ = ? "

	cQuery += " GROUP BY        "
	cQuery += " V5W.V5W_ID,     "
	cQuery += " V5W.V5W_EMISBX, "
	cQuery += " V5W.V5W_DIVERG, "
	cQuery += " V5W.V5W_ERP,    "
	cQuery += " V5W.V5W_TAF,    "
	cQuery += " V5W.V5W_FILTIT, "
	cQuery += " V5W.V5W_PREFIX, "
	cQuery += " V5W.V5W_NUMERO, "
	cQuery += " V5W.V5W_NATTIT, "
	cQuery += " V5W.V5W_NOME,   "
	cQuery += " V5W.V5W_DTEMIS, "
	cQuery += " V5W.V5W_CODPAR, "
	cQuery += " V5W.V5W_CPFCGC, "
	cQuery += " V5W.V5W_SEQUEN, "
	cQuery += " V44.V44_NATREN, "
	cQuery += " V44.V44_DECTER, "
	cQuery += " V5W.V5W_ENVTAF  "

	ReportTot(cQuery, cFilRequest, cIdRequest, nPage, nPageSize, @lHasNext, @nTotReg)
	
	cQuery += " ORDER BY V5W.V5W_FILTIT, V5W.V5W_EMISBX, V5W.V5W_NUMERO "
	cQuery += " OFFSET (( ? - 1 ) * ? ) ROWS "
	cQuery += " FETCH NEXT ? ROWS ONLY "

	If !("DB2" $ cBd)
		cQuery := ChangeQuery(cQuery)
	EndIf

	oPrepV5W := FWPreparedStatement():New()	
    oPrepV5W:SetQuery(cQuery)

	oPrepV5W:SetString(nIndBind++, space(1))
	oPrepV5W:SetString(nIndBind++, cFilRequest)
	oPrepV5W:SetString(nIndBind++, cIdRequest)
	oPrepV5W:SetString(nIndBind++, space(1))
	oPrepV5W:SetNumeric(nIndBind++, nPage)
	oPrepV5W:SetNumeric(nIndBind++, nPageSize)
	oPrepV5W:SetNumeric(nIndBind++, nPageSize)

	cQuery := oPrepV5W:GetFixQuery()
    cAlias := MPSysOpenQuery(cQuery)
	oPrepV5W:Destroy()

Return {cAlias, nTotReg, lHasNext}

/*/{Protheus.doc} ReportTot
@type        function
@description Retorna lHasNext
@author      Rafael de Paula Leme
@since       20/06/2024
@return

/*/
//-------------------------------------------------------------------
Static Function ReportTot(cQuery as character, cFilRequest as character, cIdRequest as character, nPage as numeric, nPageSize as numeric, lHasNext as logical, nTotReg as numeric)

	Local oPrepTot  as object
	Local cAliasTot as character
	Local cQryTot   as character

	oPrepTot  := Nil
	cAliasTot := ""

	cQryTot := " SELECT COUNT (*) QTDREG FROM ( " + cQuery + " ) TBTOT "

	oPrepTot := FWPreparedStatement():New()	
	oPrepTot:SetQuery(cQryTot)

	oPrepTot:SetString(1, space(1))
	oPrepTot:SetString(2, cFilRequest)
	oPrepTot:SetString(3, cIdRequest)
	oPrepTot:SetString(4, space(1))

	cQryTot := oPrepTot:GetFixQuery()
	cAliasTot := MPSysOpenQuery(cQryTot)

	nTotReg := (cAliasTot)->QTDREG

	if (nPage * nPageSize) >= nTotReg
		lHasNext := .F.
	Else
		lHasNext := .T.
	EndIf

	(cAliasTot)->(DBCloseArea())
	oPrepTot:Destroy()

Return

/*/{Protheus.doc} GetJson
@type        function
@description Gera json para response
@author      Rafael de Paula Leme
@since       27/05/2024
@return

/*/
//-------------------------------------------------------------------
Static Function GetJsonRep(aAliasRep, oResponse)

	Local nTot    	:= 0  as numeric
	Local nVlBrer 	:= 0  as numeric
	Local nVlBrta 	:= 0  as numeric
	Local nVlIR   	:= 0  as numeric
	Local nVlPis  	:= 0  as numeric
	Local nVlCof  	:= 0  as numeric
	Local nVlCSL  	:= 0  as numeric
	Local nVlAgr  	:= 0  as numeric
	Local cAliasRep := '' as character
	Local cDiverg 	:= '' as character
	Local cErp 		:= '' as character
	Local cTaf		:= '' as character

	cAliasRep := aAliasRep[1]

	If !(cAliasRep)->(EOF())
		
		(cAliasRep)->(DbGoTop())

		While !(cAliasRep)->(EOF())
		
			aadd(oResponse["reportDetail"],JsonObject():New())
			nTot := Len(oResponse["reportDetail"])

			nVlBrer := (cAliasRep)->VLBRER
			nVlBrta := (cAliasRep)->VLBRTA
			nVlIR 	:= (cAliasRep)->VALIR
			nVlPis 	:= (cAliasRep)->VALPIS
			nVlCof 	:= (cAliasRep)->VALCOF
			nVlCSL 	:= (cAliasRep)->VALCSL
			nVlAgr 	:= (cAliasRep)->VLAGRG

			if (cAliasRep)->DIVERG == '1'
				cDiverg := 'Sim'
			else
				cDiverg := 'Não'
			endIf

			if (cAliasRep)->ERP == '1'
				cErp := 'Sim'
			else
				cErp := 'Não'
			EndIf			

			if (cAliasRep)->TAF == '1'
				cTaf := 'Sim'
			else
				cTaf := 'Não'
			endif
			
			oResponse["reportDetail"][nTot]["id"]              := (cAliasRep)->ID
			oResponse["reportDetail"][nTot]["divergence"]      := EncodeUTF8(cDiverg)
			oResponse["reportDetail"][nTot]["erp"]             := EncodeUTF8(cErp)
			oResponse["reportDetail"][nTot]["taf"]             := EncodeUTF8(cTaf) 
			oResponse["reportDetail"][nTot]["branch"]          := EncodeUTF8(Alltrim((cAliasRep)->FILTIT))
			oResponse["reportDetail"][nTot]["document"]        := EncodeUTF8(Alltrim((cAliasRep)->NUMTIT))
			oResponse["reportDetail"][nTot]["prefix"]          := EncodeUTF8(Alltrim((cAliasRep)->PREFIX))
			oResponse["reportDetail"][nTot]["cpfCnpj"]         := EncodeUTF8(Alltrim((cAliasRep)->CFPCGC))
			oResponse["reportDetail"][nTot]["participantName"] := EncodeUTF8(Alltrim((cAliasRep)->NOMPAR))
			oResponse["reportDetail"][nTot]["issueDate"]       := DtoC(Stod((cAliasRep)->DTEMIS))
			oResponse["reportDetail"][nTot]["valueErp"]        := EncodeUTF8(Alltrim(Transform(nVlBrer,"@E 9,999,999,999,999.99")))
			oResponse["reportDetail"][nTot]["valueTaf"]        := EncodeUTF8(Alltrim(Transform(nVlBrta,"@E 9,999,999,999,999.99")))
			oResponse["reportDetail"][nTot]["natureIncome"]    := Alltrim((cAliasRep)->NATREN)
			oResponse["reportDetail"][nTot]["irValue"]         := EncodeUTF8(Alltrim(Transform(nVlIR ,"@E 9,999,999,999,999.99")))
			oResponse["reportDetail"][nTot]["pisValue"]        := EncodeUTF8(Alltrim(Transform(nVlPis,"@E 9,999,999,999,999.99")))
			oResponse["reportDetail"][nTot]["cofinsValue"]     := EncodeUTF8(Alltrim(Transform(nVlCof,"@E 9,999,999,999,999.99")))
			oResponse["reportDetail"][nTot]["csllValue"]       := EncodeUTF8(Alltrim(Transform(nVlCSL,"@E 9,999,999,999,999.99")))
			oResponse["reportDetail"][nTot]["agragValue"]      := EncodeUTF8(Alltrim(Transform(nVlAgr,"@E 9,999,999,999,999.99")))
			oResponse["reportDetail"][nTot]["procId"]          := EncodeUTF8(ErroMsg((cAliasRep)->ID))
			oResponse["reportDetail"][nTot]["sendTaf"]         := EncodeUTF8(Iif(Alltrim((cAliasRep)->ENVTAF) == "1", "Sim","Não")) //#todo Se existir na V5I o novo campo, considerar o conteudo de la.

			(cAliasRep)->(dbSkip())
		EndDo
	Else
		aadd(oResponse["reportDetail"],JsonObject():New())
		oResponse["reportDetail"] := {}
	EndIf

	oResponse['totalRecords'] := aAliasRep[2]
	oResponse['hasNext']      := aAliasRep[3]

	(cAliasRep)->(DBCloseArea())

Return 

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET
@type		 method
@description Método responsável por retornar os dados do processamento
@author		 Rafael de Paula Leme
@since		 27/05/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET totalizer PATHPARAM companyId, idRequest WSREST WSTAF062

	Local oRequest			as object
	Local oResponse			as object
	Local aCompany      	as array
	Local lRet          	as logical
	Local cFilRequest		as character
	Local cEmpRequest   	as character
	Local nValueFinancy   	as numeric
	Local nValueTAF       	as numeric
	Local nValueApuration 	as numeric

	oRequest	    := JsonObject():New()
	oResponse	    := JsonObject():New()
	aCompany        := {}
	lRet            := .T.	
	cFilRequest	    := ""
	cEmpRequest     := ""
	nValueFinancy  	:= 0
	nValueTAF       := 0
	nValueApuration	:= 0

	self:SetContentType("application/json")

	If self:companyId == Nil
		lRet := .F.
		SetRestFault(400, EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId'."))
	ElseIf self:idRequest == Nil
		lRet := .F.
		SetRestFault(400, EncodeUTF8("ID não informado no parâmetro 'idRequest'."))
	Else
		aCompany := StrTokArr(self:companyId, "|")

		If Len(aCompany) < 2
			lRet := .F.
			SetRestFault(400, EncodeUTF8("Tamanho Empresa|Filial informado no parâmetro 'companyId' menor que o esperado"))
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())

			If PrepEnv(cEmpRequest, cFilRequest)

				oRequest:FromJSON(cFilRequest, self:GetContent())

				oResponse["taf"] := {}
				aadd(oResponse["taf"],JsonObject():New())
				nTotTaf := Len(oResponse["taf"])

				oResponse["totalfinancy"] := {}
				aadd(oResponse["totalfinancy"],JsonObject():New())
				nTotTotalFinancy := Len(oResponse["totalfinancy"])

				oResponse["totalapuration"] := {}
				aadd(oResponse["totalapuration"],JsonObject():New())
				nTotApuration := Len(oResponse["totalapuration"])

				GetTotalizer(cFilRequest, self:idRequest, @nValueTAF, @nValueFinancy, @nValueApuration)

				oResponse["taf"][nTotTaf]["title"] := EncodeUTF8('Totalização TAF')
				oResponse["taf"][nTotTaf]["value"] := EncodeUTF8( 'R$ ' + Transform(nValueTAF,"@E 9,999,999,999,999.99") )

				oResponse["totalfinancy"][nTotTotalFinancy]["title"] := EncodeUTF8('Totalização Financeiro')
				oResponse["totalfinancy"][nTotTotalFinancy]["value"] := EncodeUTF8( 'R$ ' + Transform(nValueFinancy,"@E 9,999,999,999,999.99") )

				oResponse["totalapuration"][nTotApuration]["title"] := EncodeUTF8('Totalização Previsão Apuração')
				oResponse["totalapuration"][nTotApuration]["value"] := EncodeUTF8( 'R$ ' + Transform(nValueApuration,"@E 9,999,999,999,999.99") )

				self:SetResponse(oResponse:ToJson())
			Else
				lRet := .F.
				SetRestFault(400, EncodeUTF8("Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'."))
			EndIf
		EndIf
	EndIf

	FreeObj(oRequest)
	FreeObj(oResponse)

Return lRet

/*/{Protheus.doc} GetTotalizer
@type        function
@description Função para retorno dos totalizadores utilizados nos 3 Cards.
@author      Rafael de Paula Leme
@since       06/08/2024
@return

/*/
//-------------------------------------------------------------------
Static Function GetTotalizer(cFilRequest as character, cIdRequest as character, nValueTAF as numeric, nValueFinancy as numeric, nValueApuration as numeric)

	Local oPrepTot  as object
	Local cAliasTot as character
	Local cQuery    as character
	Local cBd       as character
	Local cIsNull   as character

	Default cFilRequest := ""
	Default cIdRequest  := ""

	oPrepTot  := Nil
	cAliasTot := ''
	cQuery    := ""
	cBd	      := Upper(AllTrim(TcGetDb()))
	cIsNull   := Iif(!("INFORMIX" $ cBd ),"COALESCE","NVL") 

	nValueTAF       := 0
	nValueFinancy   := 0
	nValueApuration := 0

	oPrepTot := FWPreparedStatement():New()
	
	cQuery += "SELECT SUM(TOT.VLBERP) VLBERP, SUM(TOT.VLBTAF) VLBTAF,SUM(TOT.VLPREV) VLPREV FROM( "
	cQuery += "SELECT "
	cQuery += "SUM(CASE WHEN V5W.V5W_ERP = ? THEN V5W.V5W_VLBRER ELSE 0 END) VLBERP, "
	cQuery += "SUM(CASE WHEN V5W.V5W_TAF = ? THEN V5W.V5W_VLBRTA ELSE 0 END) VLBTAF, "
	cQuery += "0 VLPREV "
	cQuery += "FROM " + RetSqlName("V5W") + " V5W "
	cQuery += "WHERE V5W.V5W_FILIAL = ? "
    cQuery += "AND V5W.V5W_IDREQ = ? "
	cQuery += "AND V5W.D_E_L_E_T_ = ? "

	cQuery += "UNION ALL "

	cQuery += "SELECT "
	cQuery += "0 VLBERP, "
	cQuery += "0 VLBTAF, "
	cQuery += "SUM(CASE WHEN ? (V44.V44_NATREN, ? ) <> ? THEN V44.V44_VALOR ELSE 0 END) VLPREV "
    cQuery += "FROM " + RetSqlName("V44") + " V44 "
	cQuery += "LEFT JOIN " + RetSqlName("V5W") + " V5W  ON  "
	cQuery += "V44.V44_FILIAL = V5W.V5W_FILIAL "
	cQuery += "AND V44.V44_IDV5W = V5W.V5W_ID "
	cQuery += "AND V44.D_E_L_E_T_ = ? "
	cQuery += "WHERE V5W.V5W_FILIAL = ? "
	cQuery += "AND V5W.V5W_IDREQ = ? "
	cQuery += ") TOT "

	If !("DB2" $ cBd )
		cQuery := ChangeQuery( cQuery )
	EndIf
	
    oPrepTot:SetQuery(cQuery)

	oPrepTot:SetString(1, '1')
	oPrepTot:SetString(2, '1')
	oPrepTot:SetString(3, cFilRequest)
	oPrepTot:SetString(4, cIdRequest)
	oPrepTot:SetString(5, space(1))
	oPrepTot:SetUnsafe(6, cIsNull)
	oPrepTot:SetString(7, space(1))
	oPrepTot:SetString(8, space(1))
	oPrepTot:SetString(9, space(1))
	oPrepTot:SetString(10,cFilRequest)
	oPrepTot:SetString(11,cIdRequest)

	cQuery := oPrepTot:GetFixQuery()
    cAliasTot := MPSysOpenQuery(cQuery)

	If !(cAliasTot)->(EOF())
		nValueTAF       := (cAliasTot)->VLBTAF
		nValueFinancy   := (cAliasTot)->VLBERP
		nValueApuration := (cAliasTot)->VLPREV
	EndIf

	(cAliasTot)->(DbCloseArea())
	oPrepTot:Destroy()

Return

/*/{Protheus.doc} GET
@type		 Function
@description Função responsável para tratar a mensagem de erro
@author		 Carlos Pister
@since		 06/08/2024
@return		
/*/
Static Function erroMsg( cId as character )

    Local cAlias    := GetNextAlias()
    Local cMessage  := ''
	Local aDados    := {}
	Local nI 		:= 0

    Default cId		    := ''

    BeginSql Alias cAlias
    SELECT
        V5W_MSGDIV INFO 
    FROM 
        %table:V5W%
    WHERE 
        V5W_ID = %Exp:cId% 
    EndSql
        
		If (cAlias)->( !Eof() )

			aDados := StrTokArr((cAlias)->INFO, ';')

			For nI := 1 To Len(aDados)
				If !Empty(Alltrim(aDados[nI]))
					cMessage += aDados[nI]
					cMessage += Chr(13) + Chr(10)
					cMessage += Replicate("-",40)
					cMessage += Chr(13) + Chr(10)
					cMessage += Chr(13) + Chr(10)
				EndIf
			Next nI 

        EndIf

    (cAlias)->(DBCloseArea())

Return ( cMessage )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FindSSTafInteg()
@type		 function
@description Verifica se existe a função de integração do financeiro
@author		 Denis Souza
@since		 12/08/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------
Function FindSSTafInteg()
	Local lTafInteg  as logical
	lTafInteg := (FindClass("totvs.protheus.backoffice.fin.taf.integration.TafIntegration") .Or. FindFunction('totvs.protheus.backoffice.fin.taf.integration.TafIntegration'))
Return lTafInteg

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FindSSCreate
@type		 function
@description Verifica se existe a função da criação de task
@author		 Denis Souza
@since		 12/08/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------
Function FindSSCreate()
	Local lUtilCreat as logical
	lUtilCreat := (FindClass("totvs.framework.schedule.utils.createTask") .Or. FindFunction('totvs.framework.schedule.utils.createTask'))
Return lUtilCreat

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TafSSEnable
@type		 function
@description Verifica se o Smart schedule esta habilitado
@author		 Denis Souza
@since		 12/08/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------
Function TafSSEnable()
	Local lEnableSS  as logical
	lEnableSS := (FindClass("totvs.framework.smartschedule.startSchedule.smartSchedIsEnabled") .Or. FindFunction('totvs.framework.smartschedule.startSchedule.smartSchedIsEnabled')) .And. totvs.framework.smartschedule.startSchedule.smartSchedIsEnabled()
Return lEnableSS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} function
@type		 TafSSRunning
@description Verifica se o Smart schedule esta em execução
@author		 Denis Souza
@since		 12/08/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------
Function TafSSRunning()
	Local lRunningSS as logical
	lRunningSS := (FindClass("totvs.framework.smartschedule.startSchedule.smartSchedIsRunning") .Or. FindFunction('totvs.framework.smartschedule.startSchedule.smartSchedIsRunning')) .And. totvs.framework.smartschedule.startSchedule.smartSchedIsRunning()
Return lRunningSS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TafPreCondSS()
@type		 function
@description Verifica aplicacao do ultimo pacote disponibilizado
@author		 Denis Souza
@since		 12/08/2024
@return			

/*/
//---------------------------------------------------------------------------------------------------------------
Function TafPreCondSS()

	Local lRet as logical

	lRet := .F.

	//Novas tabelas e Ultimo Campo Criado
	If AliasInDic("V3A") .And. AliasInDic("V5I") .And. AliasInDic("V5W") .And. TafColumnPos("V5W_MSGDIV")
		lRet :=	.T.
	EndIf

Return lRet
