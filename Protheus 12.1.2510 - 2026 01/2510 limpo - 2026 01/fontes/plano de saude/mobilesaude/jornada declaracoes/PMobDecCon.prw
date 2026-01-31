#Include "TOTVS.CH"
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobDecCon
Classe responsavel por preparar os dados e configurações para a Classe
PMobDecMod 

@author Rafael Soares da Silva
@version Protheus 12
@since 17/01/2022
/*/
//------------------------------------------------------------------- 
Class PMobDecCon

    // Propriedades obrigatorias nas API da Mobile
	Data oRequestModel
	Data oConfig
	Data cModelEndPoint
	Data aModel
	Data oBody
	// Dados de entrada			
	Data oPMobDecMod
	Data parametersMap
	   
    Method New() CONSTRUCTOR
	// Metodos obrigatorios nas API da Mobile
	Method GetModel()
	Method SetParameters()
	Method SetBody(oBody)
	Method SetRequestModel(oRequestModel)
	// Metodos das regras de negocio da Classe
	Method declaracoes()
	Method pdfDeclaracao()		

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Rafael Soares da Silva
@version Protheus 12
@since 17/01/2022
/*/
//------------------------------------------------------------------- 
Method New() Class PMobDecCon
	
	Self:oRequestModel := Nil
	Self:cModelEndPoint := ""
	Self:oConfig := Nil
	Self:aModel := {}
	Self:oBody := JsonObject():New()

	Self:oPMobDecMod := JsonObject():New()
	Self:parametersMap := JsonObject():New()

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel
Retorna os atributos obrigatórios dos métodos utilizados na Classe

@author Rafael Soares
@version Protheus 12
@since 18/01/2022
/*/
//------------------------------------------------------------------- 
Method GetModel() Class PMobDecCon

	Local lRet := .F.
	
	Do Case 
		Case lower(Self:cModelEndPoint) == lower("/mobileSaude/declaracoes")
			Aadd(Self:aModel, "matriculaContrato")
			lRet := .T.
		
		Case lower(Self:cModelEndPoint) == lower("/mobileSaude/pdfDeclaracao")
			Aadd(Self:aModel, "idDeclaracao")
			lRet := .T.
	EndCase

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SetParameters
Define os parametros recebidos no JSON para passar para Classe que irá
retornar os dados da resposta

@author Rafael Soares
@version Protheus 12
@since 18/01/2022
/*/
//------------------------------------------------------------------- 
Method SetParameters() Class PMobDecCon

	Do Case 
		Case lower(Self:cModelEndPoint) == lower("/mobileSaude/declaracoes")
			Self:parametersMap["multiContract"] := IIf(Empty(Self:oBody["multiContract"]), "", Self:oBody["multiContract"])
			Self:parametersMap["chaveBeneficiarioTipo"] := IIf(Empty(Self:oBody["chaveBeneficiarioTipo"]), "", Self:oBody["chaveBeneficiarioTipo"])
			Self:parametersMap["chaveBeneficiario"] := IIf(Empty(Self:oBody["chaveBeneficiario"]), "", Self:oBody["chaveBeneficiario"])
			Self:parametersMap["matriculaContrato"] := Self:oBody["matriculaContrato"]

		Case lower(Self:cModelEndPoint) == lower("/mobileSaude/pdfDeclaracao")
			Self:parametersMap["idDeclaracao"] := Self:oBody["idDeclaracao"]
	EndCase

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBody
Seta os dados do body recebido na API

@author Rafael Soares
@version Protheus 12
@since 18/01/2022
/*/
//------------------------------------------------------------------- 
Method SetBody(oBody) Class PMobDecCon

	Self:oBody := oBody

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} SetRequestModel
Seta Classe que realiza a validação do modelo de dados da API

@author Rafael Soares
@version Protheus 12
@since 18/01/2022
/*/
//------------------------------------------------------------------- 
Method SetRequestModel(oRequestModel) Class PMobDecCon

	Self:oRequestModel := oRequestModel	
	Self:SetBody(oRequestModel:oBody)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} declaracoes
Realiza a chamada do método guiaAutorizacoes da Classe PMobGuiMod para
retornar uma lista de declarações do beneficiário.

@author Rafael Soares
@version Protheus 12
@since 18/01/2022
/*/
//------------------------------------------------------------------- 
Method declaracoes() Class PMobDecCon

	Self:SetParameters()

	Self:oPMobDecMod := PMobDecMod():New(Self:parametersMap) 
	Self:oPMobDecMod:oConfig := Self:oConfig
	
	If !Self:oPMobDecMod:declaracoes()

		Self:oRequestModel:SetStatusResponse(.F.)
		Self:oRequestModel:SetMessageResponse(Self:oPMobDecMod:getMessage())
		Return .F.

	Endif
	
	Self:oRequestModel:SetDataResponse(Self:oPMobDecMod:getdeclaracoes())	 


Return .T.	


//-------------------------------------------------------------------
/*/{Protheus.doc} pdfDeclaracao
Realiza a chamada do método guiaPdf da Classe PMobGuiMod para retornar 
uma URL ou um campo BASE64 contendo o arquivo PDF da declaração

@author Rafael Soares
@version Protheus 12
@since 18/01/2022
/*/
//------------------------------------------------------------------- 
Method pdfDeclaracao() Class PMobDecCon
 
	Self:SetParameters()

	Self:oPMobDecMod := PMobDecMod():New(Self:parametersMap) 
	Self:oPMobDecMod:oConfig := Self:oConfig

	If !Self:oPMobDecMod:pdfDeclaracao()
		
		Self:oRequestModel:SetStatusResponse(.F.)
		Self:oRequestModel:SetMessageResponse(Self:oPMobDecMod:getMessage())
		Return .F.

	Endif

	Self:oRequestModel:SetDataResponse(Self:oPMobDecMod:getpdfDeclaracao())		 
	
Return .T.