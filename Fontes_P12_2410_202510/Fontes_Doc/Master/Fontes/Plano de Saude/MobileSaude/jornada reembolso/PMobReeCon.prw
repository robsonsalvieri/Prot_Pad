#INCLUDE 'totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobReeCon

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Class PMobReeCon From PMobConfig

	// Propriedades de uso geral
	Data oRequestModel
	Data message

	Data oReembModel
	Data cModelEndPoint

	Data aModel
	Data oBody

	Data clientId 		
	Data clientSecret	
	

	Data protocolo 	  			
	Data id_operadora 			
	Data mshash 				
	Data matricula_titular 		
	Data matricula_beneficiario 
	Data cpf_titular 			
	Data telefone 				
	Data nome_titular 			
	Data operadora_ans 			
	Data despesas 				


	Method New() CONSTRUCTOR

	// Metodos obrigatorios do padrao definido
	Method GetModel()
	Method SetReembParameters()
	Method SetRequestModel(oRequestModel)
	Method PMobReembDao()
	Method SetBody(oBody)
	Method RetornoResp()
	
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method New() Class PMobReeCon

	_Super:New() //Inicializa a classe herdada, responsável pelas configurações

	self:oReembModel 		:= jSonObject():New()
	self:cModelEndPoint		:= nil
	self:oRequestModel 		:= nil
	self:aModel 			:= {}
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method GetModel() CLASS PMobReeCon

	Local lRet := .T.

	If self:cModelEndPoint == "/mobileSaude/geraProtocolo"
		Aadd(self:aModel, "cpf_titular")
	Else
		lRet := .F.	
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetBody

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//-------------------------------------------------------------------
Method SetBody(oBody) class PMobReeCon
	self:oBody := oBody
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetRequestModel
	Criado para carregar oBody do objeto
	
	@type  Function
	@author Robson Nayland
	@since 16/09/2021
	@version 12
/*/
//------------------------------------------------------------------- 
Method SetRequestModel(oRequestModel) class PMobReeCon
	self:oRequestModel := oRequestModel
	self:SetBody(oRequestModel:oBody)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraProtocolo
	Criado para chamar a classe DAO e efetus as validações de Banco
	
	@type  Function
	@author Robson Nayland
	@since 16/09/2021
	@version 12
/*/
//------------------------------------------------------------------- 
Method PMobReembDao() class PMobReeCon

	Local aItens :={}
	Local aDadRda:={}
	Local aDadUsr:={}
	Local cProtocolo:= ''
	

	// DEFINE os parametros 
	self:SetReembParameters()

	DbselectArea("BA1")
	DbselectArea("BA3")
	DbselectArea("BOW")
	DbselectArea("B1N")
	DbselectArea("BI3")
	
	
	//Validando informações do Json.
	PMobReemb	:= PMobReemb():New()
	If !PMobReemb:ValidReembo(self,@aDadUsr,@aDadRda,@aItens)
		self:RetornoResp(0)
		return(.F.)
	Endif
	

	cProtocolo := GetSXENum("BOW","BOW_PROTOC")
	ConfirmSX8()

	// Enviando a resposta 
	self:RetornoResp(1,cProtocolo) 


	// Gravando o reembolso apos as validações
	If !PMobReemb:Gerareembo(aDadUsr,aDadRda,aItens,cProtocolo)
		ReTurn(.F.)
	Endif


Return(.T.)	



//-------------------------------------------------------------------
/*/{Protheus.doc} SetReembParameters
	Carrega com os dados vindo do Json do Mobile Saude 
	
	@type  Function
	@author Robson Nayland
	@since 16/09/2021
	@version 12
/*/
//------------------------------------------------------------------- 

Method SetReembParameters() class PMobReeCon

	self:protocolo 	  			:= self:oBody["protocolo"]
	self:id_operadora 			:= self:oBody["id_operadora"]
	self:mshash 				:= self:oBody["mshash"]
	self:matricula_titular 		:= self:oBody["matricula_titular"]
	self:matricula_beneficiario := self:oBody["matricula_beneficiario"]
	self:cpf_titular 			:= self:oBody["cpf_titular"]
	self:telefone 				:= self:oBody["telefone"]
	self:nome_titular 			:= self:oBody["nome_titular"]
	self:operadora_ans 			:= self:oBody["operadora_ans"]
	self:despesas 				:= self:oBody["despesas"]

	
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} SetReembParameters
	Carrega com os dados vindo do Json do Mobile Saude 
	nTipo = 0 - Negado por alguma valiação
	nTipo = 1 - Aprovado 
	
	@type  Function
	@author Robson Nayland
	@since 16/09/2021
	@version 12
/*/
//------------------------------------------------------------------- 

Method RetornoResp(nTipo,cProtocolo) class PMobReeCon

	// Prepara o retorno

	oResposta := jSonObject():New()

	oResposta['protocolo']	:= If(nTipo=1,cProtocolo,'')
	oResposta['mshash']		:= If(nTipo=1,"NjA1ZDhkNjkzN2RjMz213bNTg2ZjUyMzgyZTk5ZTkyMGU4MDA2ZGFiNg==",'')
	oResposta['status']		:= If(nTipo=1,'2','0')

	self:oRequestModel:SetDataResponse(oResposta) 

	
Return


