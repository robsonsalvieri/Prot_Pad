#Include "TOTVS.CH"
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobGuiCon
Classe responsavel por preparar os dados e configurações para a Classe
PMobGuiMod 

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 04/02/2022
/*/
//------------------------------------------------------------------- 
Class PMobGuiCon

	// Propriedades obrigatorias nas API da Mobile
	Data oRequestModel
	Data cModelEndPoint
    Data oConfig
	Data aModel
	Data oBody
	// Dados de Entrada
	Data oPMobGuiMod	
	Data oParametersMap

	Method New() CONSTRUCTOR
	// Metodos obrigatorios nas API da Mobile
	Method GetModel()
	Method SetParameters()
	Method SetBody(oBody)
	Method SetRequestModel(oRequestModel)
	// Metodos das regras de negocio da Classe
	Method guiaAutorizacoes()
	Method guiaDetalhe()	
	Method guiaPdf()	
	Method guiaStatus()		
	
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022
/*/
//------------------------------------------------------------------- 
Method New() Class PMobGuiCon
	
	Self:oRequestModel := Nil
	Self:cModelEndPoint	:= ""
	Self:oConfig := Nil
	Self:aModel := {}
	Self:oBody := JsonObject():New()

	Self:oPMobGuiMod := JsonObject():New()
	Self:oParametersMap := JsonObject():New()
	
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel
Retorna os atributos obrigatórios dos métodos utilizados na Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022
/*/
//------------------------------------------------------------------- 
Method GetModel() Class PMobGuiCon

	Local lRet := .F.

	Do Case 	
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/guiaAutorizacoes")
			aAdd(Self:aModel, "matriculaContrato")
			lRet := .T.

		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/guiaDetalhe")
			aAdd(Self:aModel, "chaveAutorizacao")
			lRet := .T.
		
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/guiaPdf")
			aAdd(Self:aModel, "chaveAutorizacao")
			lRet := .T.
		
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/guiaStatus")
			lRet := .T. // Método sem parametros de entrada
	EndCase

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SetParameters
Define os parametros recebidos no JSON para passar para Classe que irá
retornar os dados da resposta

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022.
/*/
//------------------------------------------------------------------- 
Method SetParameters() Class PMobGuiCon

	Do Case 
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/guiaAutorizacoes")
			Self:oParametersMap["chaveBeneficiarioTipo"] := IIf(Empty(Self:oBody["chaveBeneficiarioTipo"]), "", Self:oBody["chaveBeneficiarioTipo"])
			Self:oParametersMap["multiContract"] := IIf(Empty(Self:oBody["multiContract"]), "", Self:oBody["multiContract"])
			Self:oParametersMap["chaveBeneficiario"] := IIf(Empty(Self:oBody["chaveBeneficiario"]), "", Self:oBody["chaveBeneficiario"])
			Self:oParametersMap["dataInicial"] := IIf(Empty(Self:oBody["dataInicial"]), "", Self:oBody["dataInicial"])
			Self:oParametersMap["dataFinal"] := IIf(Empty(Self:oBody["dataFinal"]), "", Self:oBody["dataFinal"])
			Self:oParametersMap["matriculaContrato"] := Self:oBody["matriculaContrato"]
		
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/guiaDetalhe")
			Self:oParametersMap["chaveAutorizacao"] := Self:oBody["chaveAutorizacao"]
		
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/guiaPdf")
			Self:oParametersMap["chaveAutorizacao"] := Self:oBody["chaveAutorizacao"]
		
	EndCase

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBody
Seta os dados do body recebido na API

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022
/*/
//------------------------------------------------------------------- 
Method SetBody(oBody) Class PMobGuiCon

	Self:oBody := oBody

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} SetRequestModel
Seta Classe que realiza a validação do modelo de dados da API

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022
/*/
//------------------------------------------------------------------- 
Method SetRequestModel(oRequestModel) Class PMobGuiCon

	Self:oRequestModel := oRequestModel	
	Self:SetBody(oRequestModel:oBody)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} guiaAutorizacoes
Realiza a chamada do método guiaAutorizacoes da Classe PMobGuiMod para
retornar a lista de guias de autorizações do beneficiário.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022
/*/
//------------------------------------------------------------------- 
Method guiaAutorizacoes() Class PMobGuiCon

	Local lRetorno := .F.
	Self:SetParameters()

	Self:oPMobGuiMod := PMobGuiMod():New(Self:oParametersMap) 
	Self:oPMobGuiMod:oConfig := Self:oConfig
	 
	If Self:oPMobGuiMod:guiaAutorizacoes()

		Self:oRequestModel:SetDataResponse(Self:oPMobGuiMod:getGuiaAutorizacoes())
		lRetorno := .T.	

	Endif

Return lRetorno	


//-------------------------------------------------------------------
/*/{Protheus.doc} guiaDetalhe
Realiza a chamada do método guiaDetalhe da Classe PMobGuiMod para
retornar os detalhes da guia

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022
/*/
//------------------------------------------------------------------- 
Method guiaDetalhe() Class PMobGuiCon

	Self:SetParameters()

	Self:oPMobGuiMod := PMobGuiMod():New(Self:oParametersMap) 
	Self:oPMobGuiMod:oConfig := Self:oConfig
	 
	If !Self:oPMobGuiMod:guiaDetalhe()

		Self:oRequestModel:SetStatusResponse(.F.)
		Self:oRequestModel:SetMessageResponse(Self:oPMobGuiMod:GetMessage())
		Return .F.	

	Endif

	Self:oRequestModel:SetDataResponse(Self:oPMobGuiMod:getGuiaDetalhe())
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} guiaPdf
Realiza a chamada do método guiaPdf da Classe PMobGuiMod para
retornar a URL ou Base 64 do PDF da Guia	.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022
/*/
//------------------------------------------------------------------- 
Method guiaPdf() Class PMobGuiCon

	Self:SetParameters()

	Self:oPMobGuiMod := PMobGuiMod():New(Self:oParametersMap) 
	Self:oPMobGuiMod:oConfig := Self:oConfig
	 
	If !Self:oPMobGuiMod:guiaPdf()

		Self:oRequestModel:SetStatusResponse(.F.)
		Self:oRequestModel:SetMessageResponse(Self:oPMobGuiMod:GetMessage())
		Return .F.

	Endif

	Self:oRequestModel:SetDataResponse(Self:oPMobGuiMod:getGuiaPdf())	 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} guiaStatus
Realiza a chamada do método guiaStatus da Classe PMobGuiMod para
retornar os status da guia	

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 21/01/2022
/*/
//------------------------------------------------------------------- 
Method guiaStatus() Class PMobGuiCon

	Local lRetorno := .F.

	Self:SetParameters()

	Self:oPMobGuiMod := PMobGuiMod():New(Self:oParametersMap) 
	Self:oPMobGuiMod:oConfig := Self:oConfig
	 
	If Self:oPMobGuiMod:guiaStatus()

		Self:oRequestModel:SetDataResponse(Self:oPMobGuiMod:getGuiaStatus())
		lRetorno := .T.

	Endif
	
Return lRetorno