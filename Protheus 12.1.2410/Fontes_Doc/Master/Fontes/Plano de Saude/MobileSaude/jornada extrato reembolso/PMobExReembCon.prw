#Include "TOTVS.CH"
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobExReembCon
Classe responsavel por preparar os dados e configurações para a Classe
PMobExReembMod 

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Class PMobExReembCon

	// Propriedades obrigatorias nas API da Mobile
	Data oRequestModel
	Data cModelEndPoint
    Data oConfig
	Data aModel
	Data oBody
	// Dados de Entrada
	Data oPMobReeMod	
	Data oParametersMap

	Method New() CONSTRUCTOR
	// Metodos obrigatorios nas API da Mobile
	Method GetModel()
	Method SetParameters()
	Method SetBody(oBody)
	Method SetRequestModel(oRequestModel)
	// Metodos das regras de negocio da Classe
	Method reeExtrato()
	Method reeDetalhe()	
	Method reeHistorico()	
	Method reeStatus()		
	
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method New() Class PMobExReembCon
	
	Self:oRequestModel := Nil
	Self:cModelEndPoint	:= ""
	Self:oConfig := Nil
	Self:aModel := {}
	Self:oBody := JsonObject():New()

	Self:oPMobReeMod := JsonObject():New()
	Self:oParametersMap := JsonObject():New()
	
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel
Retorna os atributos obrigatórios dos métodos utilizados na Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method GetModel() Class PMobExReembCon

	Local lRet := .F.

	Do Case 	
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/reeExtrato")
			aAdd(Self:aModel, "chaveBeneficiario")
			lRet := .T.
		
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/reeDetalhe")
			aAdd(Self:aModel, "chaveReembolso")
			lRet := .T.
		
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/reeHistorico")
			aAdd(Self:aModel, "chaveReembolso")
			lRet := .T.

		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/reeStatus")
			lRet := .T. // Método sem parametros de entrada
	EndCase

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SetParameters
Define os parametros recebidos no JSON para passar para Classe que irá
retornar os dados da resposta

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method SetParameters() Class PMobExReembCon

	Do Case 
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/reeExtrato")
			Self:oParametersMap["chaveBeneficiario"] := Self:oBody["chaveBeneficiario"]
			Self:oParametersMap["dataInicial"] := IIf(Empty(Self:oBody["dataInicial"]), "", Self:oBody["dataInicial"])
			Self:oParametersMap["dataFinal"] := IIf(Empty(Self:oBody["dataFinal"]), "", Self:oBody["dataFinal"])
		
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/reeDetalhe")
			Self:oParametersMap["chaveReembolso"] := Self:oBody["chaveReembolso"]
		
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/reeHistorico")
			Self:oParametersMap["chaveReembolso"] := Self:oBody["chaveReembolso"]

	EndCase

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBody
Seta os dados do body recebido na API

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method SetBody(oBody) Class PMobExReembCon

	Self:oBody := oBody

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} SetRequestModel
Seta Classe que realiza a validação do modelo de dados da API

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method SetRequestModel(oRequestModel) Class PMobExReembCon

	Self:oRequestModel := oRequestModel	
	Self:SetBody(oRequestModel:oBody)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} reeExtrato
Realiza a chamada do método reeExtrato da Classe PMobExReembMod para
retornar a lista de protocolos de reembolso do beneficiário.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method reeExtrato() Class PMobExReembCon

	Self:SetParameters()

	Self:oPMobReeMod := PMobExReembMod():New(Self:oParametersMap) 
	Self:oPMobReeMod:oConfig := Self:oConfig
	 
	If !Self:oPMobReeMod:reeExtrato()

		Self:oRequestModel:SetStatusResponse(.F.)
		Self:oRequestModel:SetMessageResponse(Self:oPMobReeMod:GetMessage())
		Return .F.	

	Endif

	Self:oRequestModel:SetDataResponse(Self:oPMobReeMod:getReeExtrato())

Return .T.	


//-------------------------------------------------------------------
/*/{Protheus.doc} reeDetalhe
Realiza a chamada do método reeDetalhe da Classe PMobExReembMod para
retornar os detalhes do protocolo de reembolso

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/02/2022
/*/
//------------------------------------------------------------------- 
Method reeDetalhe() Class PMobExReembCon

	Self:SetParameters()

	Self:oPMobReeMod := PMobExReembMod():New(Self:oParametersMap) 
	Self:oPMobReeMod:oConfig := Self:oConfig
	 
	If !Self:oPMobReeMod:reeDetalhe()

		Self:oRequestModel:SetStatusResponse(.F.)
		Self:oRequestModel:SetMessageResponse(Self:oPMobReeMod:GetMessage())
		Return .F.	

	Endif

	Self:oRequestModel:SetDataResponse(Self:oPMobReeMod:getReeDetalhe())
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} reeHistorico
Realiza a chamada do método reeHistorico da Classe PMobExReembMod para
retornar o historico de alteração de status do protocolo	

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/02/2022
/*/
//------------------------------------------------------------------- 
Method reeHistorico() Class PMobExReembCon

	Self:SetParameters()

	Self:oPMobReeMod := PMobExReembMod():New(Self:oParametersMap) 
	Self:oPMobReeMod:oConfig := Self:oConfig
	 
	If !Self:oPMobReeMod:reeHistorico()

		Self:oRequestModel:SetStatusResponse(.F.)
		Self:oRequestModel:SetMessageResponse(Self:oPMobReeMod:GetMessage())
		Return .F.

	Endif

	Self:oRequestModel:SetDataResponse(Self:oPMobReeMod:getReeHistorico())	 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} reeStatus
Realiza a chamada do método reeStatus da Classe PMobExReembMod para
retornar os status do protocolo de reembolso

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/02/2022
/*/
//------------------------------------------------------------------- 
Method reeStatus() Class PMobExReembCon

	Local lRetorno := .F.
	Self:SetParameters()

	Self:oPMobReeMod := PMobExReembMod():New(Self:oParametersMap) 
	Self:oPMobReeMod:oConfig := Self:oConfig
	 
	If Self:oPMobReeMod:reeStatus()

		Self:oRequestModel:SetDataResponse(Self:oPMobReeMod:getReeStatus())	
		lRetorno := .T.

	Endif
	
Return lRetorno