#Include "TOTVS.CH"
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobAtuCadCon
Classe responsavel por preparar os dados e configurações para a Classe
PMobAtuCadMod 

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Class PMobAtuCadCon

	// Propriedades obrigatorias nas API da Mobile
	Data oRequestModel
	Data cModelEndPoint
    Data oConfig
	Data aModel
	Data oBody
	// Dados de Entrada
	Data oPMobAtuCadMod	
	Data oParametersMap

	Method New() CONSTRUCTOR
	// Metodos obrigatorios nas API da Mobile
	Method GetModel()
	Method SetParameters()
	Method SetBody(oBody)
	Method SetRequestModel(oRequestModel)
	// Metodos das regras de negocio da Classe
	Method submit_formulario()	
	
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Method New() Class PMobAtuCadCon
	
	Self:oRequestModel := Nil
	Self:cModelEndPoint	:= ""
	Self:oConfig := Nil
	Self:aModel := {}
	Self:oBody := JsonObject():New()

	Self:oPMobAtuCadMod := JsonObject():New()
	Self:oParametersMap := JsonObject():New()
	
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel
Retorna os atributos obrigatórios dos métodos utilizados na Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Method GetModel() Class PMobAtuCadCon

	Local lRet := .T.

	Do Case 	
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/submit_formulario")
			aAdd(Self:aModel, "protocolo")
			aAdd(Self:aModel, "id_operadora")
			aAdd(Self:aModel, "mshash")
            aAdd(Self:aModel, "nome")
            aAdd(Self:aModel, "matricula")
            aAdd(Self:aModel, "matricula_titular")
            aAdd(Self:aModel, {"campos", {"id","label","name"}})
	EndCase

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SetParameters
Define os parametros recebidos no JSON para passar para Classe que irá
retornar os dados da resposta

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Method SetParameters() Class PMobAtuCadCon

	Do Case 
		Case Lower(Self:cModelEndPoint) == Lower("/mobileSaude/submit_formulario")
			Self:oParametersMap["protocolo"] := Self:oBody["protocolo"]
			Self:oParametersMap["id_operadora"] := Self:oBody["id_operadora"]
			Self:oParametersMap["mshash"] := Self:oBody["mshash"]
			Self:oParametersMap["nome"] := Self:oBody["nome"]
			Self:oParametersMap["matricula"] := Self:oBody["matricula"]
			Self:oParametersMap["matricula_titular"] := Self:oBody["matricula_titular"]
			Self:oParametersMap["campos"] := Self:oBody["campos"]		
	EndCase

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBody
Seta os dados do body recebido na API

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Method SetBody(oBody) Class PMobAtuCadCon

	Self:oBody := oBody

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} SetRequestModel
Seta Classe que realiza a validação do modelo de dados da API

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Method SetRequestModel(oRequestModel) Class PMobAtuCadCon

	Self:oRequestModel := oRequestModel	
	Self:SetBody(oRequestModel:oBody)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} submit_formulario
Realiza a chamada do método submit_formulario da Classe PMobAtuCadMod para
inserir uma nova solicitação de atualização cadastral para análise.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Method submit_formulario() Class PMobAtuCadCon

	Self:SetParameters()

	Self:oPMobAtuCadMod := PMobAtuCadMod():New(Self:oParametersMap) 
	Self:oPMobAtuCadMod:oConfig := Self:oConfig
	 
	If !Self:oPMobAtuCadMod:submit_formulario()

		Self:oRequestModel:SetStatusResponse(.F.)
		Self:oRequestModel:SetDataResponse(Self:oPMobAtuCadMod:getsubmit_formulario())
		Self:oRequestModel:DisableReason() // Desabilita o atributo de motivo de critica
		Self:oRequestModel:SetMessageResponse(Self:oPMobAtuCadMod:GetMessage())
		Return .F.	

	Endif

	Self:oRequestModel:SetDataResponse(Self:oPMobAtuCadMod:getsubmit_formulario())

Return .T.