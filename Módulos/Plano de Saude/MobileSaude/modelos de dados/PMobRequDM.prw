#INCLUDE 'totvs.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} PMobRequDM
Classe para centralizar os modelos de dados de entrada dos EndPoints da API de integração com a platafroma 
Omnichannel da Mobile Saúde

@type  Class
@author geraldo felix junior
@since 20192207
/*/
//-------------------------------------------------------------------
CLASS PMobRequDM from PMobRespDM

	// Modelos de entrada 
	Data oSuperClass
	Data oClass
	Data cBody 
	Data cQueryString
	Data lCheckSecurityRulles

	// Modelo de retrorno
	Data lStatus

	// Variaveis de controle 
	Data oObj
	Data aModel 
	Data lSuccess
	Data oBody 
	Data oDataQueryString

	Method New() CONSTRUCTOR
	Method CheckPostModel(cModel, cBody, cQueryString)
	Method CheckGetModel(cModel, cQueryString)
	Method CheckSecurityRulles()
	Method ModelBase()

	Method SetBody(cBody)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method New() CLASS PMobRequDM
	// Inicializa a classe herdada, responsável pelo modelo de dados do retorno 
	_Super:New()

	// Modelo de entrada
	self:oClass  			:= nil	
	self:oSuperClass		:= nil
	self:cBody				:= ""
	self:cQueryString		:= ""

	// Propriedades de controle geral	
	self:aModel 				:= {}   	 
	self:lSuccess 				:= .T.   	   
	self:lCheckSecurityRulles	:= .T.	
	self:oBody					:= JsonObject():New()
	self:oDataQueryString		:= JsonObject():New()
	self:oObj					:= JsonObject():New()
Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckPostModel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method CheckPostModel(lAuto) CLASS PMobRequDM
	
	Local nCnt := 0
	Local nX := 0
	Local nY := 0
	Local lCritica := .F.
	Local lStatus := .T.	 
	Local cMessage := ""
	Local nCode	:= 0

	Default lAuto := .F.

	// Redefine os registros de retorno 
	self:SetStatusResponse(.T.)

	// verifica regra de segurança 
	If ((!self:lCheckSecurityRulles .Or. (self:lCheckSecurityRulles .And. self:CheckSecurityRulles(, lAuto))) .Or. lAuto)
		
		If self:Status		
			// Primeiro verifica se o conteúdo que chegou é valido
			If Empty(self:cBody)
				self:SetStatusResponse(.F.)	
				self:SetMessageResponse("O conteúdo do corpo da requisição não é valido. ")				
			Else
				// Registra as novas entradas
				self:oObj:FromJson(self:cBody)

				// Carrega o modelo de dados da requisição
				If self:oClass:GetModel()
					// Verifica se os dados de entrada são válidos
					For nCnt := 1 to len( self:oClass:aModel)
						// Quando o atributo for um array de objetos
						If ValType(self:oClass:aModel[nCnt]) == "A"

							If Empty(self:oObj[self:oClass:aModel[nCnt][1]])
								lCritica := .T.
							Else
								For nY := 1 To Len(self:oObj[self:oClass:aModel[nCnt][1]])
									For nX := 1 To Len(self:oClass:aModel[nCnt][2])

										If Empty(self:oObj[self:oClass:aModel[nCnt][1]][nY][self:oClass:aModel[nCnt][2][nX]])	
											lCritica := .T.
										Endif

									Next nX
								Next nY
							EndIf
						Else
							If Empty(self:oObj[self:oClass:aModel[nCnt]])	
								lCritica := .T.
							Endif
						EndIf	

						If lCritica
							self:SetStatusResponse(.F.)	
							self:SetMessageResponse("Um atributo obrigatório não foi informado.")
							Exit
						EndIf

					Next nCnt
				Else
					self:SetStatusResponse(.F.)	
					self:SetMessageResponse("Não existe definição para o modelo de dados para o EndPoint "+ self:oClass:cModelEndPoint)		

				Endif
			Endif
		Endif
	Endif

	// Criar o obj com os dados do corpo da requisicao 
	If self:Status	
		self:SetBody()
	Endif

Return self:Status	


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBody

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method SetBody() CLASS PMobRequDM
	self:oBody:FromJson(self:cBody)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckSecurityRulles

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method CheckSecurityRulles(lCheckUserContext, lAuto) CLASS PMobRequDM
Local lStatus	:= .F.
Local cToken	:= Iif(!lAuto, self:oSuperClass:GetHeader('Access'),"")
Local oSecurity := PMobSecCon():New()
Local aCheck 	:= oSecurity:CheckToken(cToken)
Default lCheckUserContext:= .F. // Este parametro determina se deve analisar o token de segurança no contexto do usuário

If lAuto
	aCheck[1] 	:= .T.
	aCheck[2]	:= 0
	aCheck[3]	:= ""
EndIf

lStatus := aCheck[1]
self:SetStatusResponse(aCheck[1])
self:SetStatusCode(aCheck[2])
self:SetMessageResponse(aCheck[3])

Return lStatus
