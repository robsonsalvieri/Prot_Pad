#INCLUDE 'totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobFinCon

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Class PMobFinCon From PMobConfig
	// Propriedades de uso geral
	Data oRequestModel
	Data message

	Data oPMobFinMod
	Data cModelEndPoint

	// Dados de entrada	
	Data aModel
	Data oBody	
	Data oBeneficiario

	Data parametersMap
	Data tituloCodigo
	Data tituloId

	Data lMultiContract 	
	data lLoginByCPF		
	Data chaveBeneficiario
	Data oConfig

	Method New() CONSTRUCTOR

	// Metodos obrigatorios do padrao definido
	Method GetModel()
	Method SetParameters()
	Method SetBody(oBody)
	Method SetRequestModel(oRequestModel)

	// Metodos de regras de negocio do serviço
	Method listaDebitos()						// Em construção 
	Method detalheDebito()	
	Method boletoPdf()	
	Method extratoFaturaPdf()		
	
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method New() Class PMobFinCon
	
	// Obrigatorios para o padrão definido
	self:oPMobFinMod 		:= jSonObject():New()
	self:cModelEndPoint		:= nil
	self:oConfig			:= nil
	self:oRequestModel 		:= nil
	self:message 			:= ""

	// Dados de entrada 
	self:parametersMap		:= JsonObject():New()
	
	self:lMultiContract 	:= nil
	self:lLoginByCPF		:= nil
	self:chaveBeneficiario	:= nil

	self:tituloCodigo		:= nil
	self:tituloId			:= nil

	// Modelos genericos da arquitetura de API	
	self:aModel 			:= {}
	self:oBody			  	:= JsonObject():New()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} listaDebitos

Metodo que lista os débitos do cliente
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method listaDebitos() class PMobFinCon

	// DEFINE os parametros 
	self:SetParameters()

	// Cria mapa referente ao cliente vinculado ao beneficiário 
	self:oPMobFinMod := PMobFinMod():New(self:parametersMap) 
	self:oPMobFinMod:oConfig := self:oConfig
	 
	If !self:oPMobFinMod:listaDebitos()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:oPMobFinMod:getMessage())
		Return(.F.)	
	Endif

	self:oRequestModel:SetDataResponse(self:oPMobFinMod:getListaDebitos())	// Contratos	 

Return .T.	


//-------------------------------------------------------------------
/*/{Protheus.doc} detalheDebito

Metodo que retorna o detalhe do débito selecionado
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method detalheDebito() class PMobFinCon

	// DEFINE os parametros 
	self:SetParameters()

	// Cria mapa referente ao cliente vinculado ao beneficiário 
	self:oPMobFinMod := PMobFinMod():New(self:parametersMap) 
	self:oPMobFinMod:oConfig := self:oConfig
	 
	If !self:oPMobFinMod:detalheDebito()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:oPMobFinMod:getMessage())
		Return(.F.)	
	Endif

	self:oRequestModel:SetDataResponse(self:oPMobFinMod:getDetalheDebito())	// Contratos	 
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} boletoPdf

Metodo que retorna o boleto em PDF
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method boletoPdf() class PMobFinCon

	// DEFINE os parametros 
	self:SetParameters()

	// Cria mapa referente ao cliente vinculado ao beneficiário 
	self:oPMobFinMod := PMobFinMod():New(self:parametersMap) 
	self:oPMobFinMod:oConfig := self:oConfig
	 
	If !self:oPMobFinMod:boletoPdf()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:oPMobFinMod:getMessage())
		Return(.F.)	
	Endif

	self:oRequestModel:SetDataResponse(self:oPMobFinMod:getBoletoPdf())	// Contratos	 
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} extratoFaturaPdf

Metodo que retorna o extrato em PDF
@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method extratoFaturaPdf() class PMobFinCon

	// DEFINE os parametros 
	self:SetParameters()

	// Cria mapa referente ao cliente vinculado ao beneficiário 
	self:oPMobFinMod := PMobFinMod():New(self:parametersMap) 
	self:oPMobFinMod:oConfig := self:oConfig
	 
	If !self:oPMobFinMod:extratoFaturaPdf()
		self:oRequestModel:SetStatusResponse(.F.)
		self:oRequestModel:SetMessageResponse(self:oPMobFinMod:getMessage())
		Return(.F.)	
	Endif

	self:oRequestModel:SetDataResponse(self:oPMobFinMod:getExtratoFaturaPdf())	// Contratos	 
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} SetBody

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method SetBody(oBody) class PMobFinCon
	self:oBody := oBody
Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} SetParameters

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method SetParameters() CLASS PMobFinCon

	Do Case 

		Case lower(self:cModelEndPoint) == lower("/mobileSaude/listaDebitos")
			self:parametersMap['multiContract']			:= self:oBody['multiContract']
			self:parametersMap['chaveBeneficiarioTipo']	:= self:oBody['chaveBeneficiarioTipo']
			self:parametersMap['chaveBeneficiario']		:= self:oBody['chaveBeneficiario']

		Case lower(self:cModelEndPoint) == lower("/mobileSaude/detalheDebito")
			self:parametersMap['tituloCodigo'] 	:= self:oBody['tituloCodigo']
			self:parametersMap['tituloId']	 	:= self:oBody['tituloId']
			
		Case lower(self:cModelEndPoint) == lower("/mobileSaude/boletoPdf")
			self:parametersMap['tituloCodigo'] 	:= self:oBody['tituloCodigo']
			self:parametersMap['tituloId']	 	:= self:oBody['tituloId']
			
		Case lower(self:cModelEndPoint) == lower("/mobileSaude/extratoFaturaPdf")
			self:parametersMap['tituloCodigo'] 	:= self:oBody['tituloCodigo']
			self:parametersMap['tituloId']	 	:= self:oBody['tituloId']
		
	EndCase

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetRequestModel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method SetRequestModel(oRequestModel) class PMobFinCon
	self:oRequestModel := oRequestModel	
	self:SetBody(oRequestModel:oBody)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   20/08/2018
/*/
//------------------------------------------------------------------- 
Method GetModel() CLASS PMobFinCon

	Local lRet := .T.

	Do Case 
	
		Case lower(self:cModelEndPoint) == lower("/mobileSaude/listaDebitos")
			Aadd(self:aModel, "chaveBeneficiario")

		Case lower(self:cModelEndPoint) == lower("/mobileSaude/detalheDebito")
			Aadd(self:aModel, "tituloCodigo")
			Aadd(self:aModel, "tituloId")
			
		Case lower(self:cModelEndPoint) == lower("/mobileSaude/boletoPdf")
			Aadd(self:aModel, "tituloCodigo")
			Aadd(self:aModel, "tituloId")
			
		Case lower(self:cModelEndPoint) == lower("/mobileSaude/extratoFaturaPdf")
			Aadd(self:aModel, "tituloCodigo")
			Aadd(self:aModel, "tituloId")

		Otherwise
			lRet := .F.

	EndCase

Return lRet