#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU44W200.CH"


/*MAINTENANCE FOR PROJECTS (simple model to be used in web forms for VISUALIZATION)*/

PUBLISH MODEL REST NAME RU44W200 RESOURCE OBJECT oRU44W200

/*/{Protheus.doc} oRU44W200
description
@type class
@version  
@author
@since 03/07/2023
/*/
Class oRU44W200 From FwRestModel

	Data cSkip     as string //Registros a pular
	Data cPageSize as string // Tamanho da pagina
	Data cOrder    as string // Campo de ordenacao
	Data lReqTotalCount as logical // Se precisa retornar o total de registros
	Data cFilterVars as string // Campos a filtar
	Data cFilterExp as string // Expressao de filtro
	Data nTotal as numeric // Armazena o numero total de registros
	Data cResponse as string //Retorno
	Data cFirstlevel as string // Defines if it will get fist level only (default true)
	Data cFieldDetail as string  // Habilita mostrar mais informações nos campos do modelo (padrão: 10)
	Data cFieldVirtual as string //Habilita o retorno de campos virtuais (padrão: false)
	Data cFieldEmpty as string //Habilita o retorno de campos sem valores (padrão: false)
	Data cFields as string //Indica os campos a serem filtrados no retorno do modelo, incluindo os sub modelos, caso não informado todos os campos serão retornados
	Data cDebug as string //Valor booleano para habilitar o modo debug (padrão: false)
	Data cInternalId as string // Indica se deve retornar o ID(Recno) como informação complementar das linhas do GRID (padrão: false)
	Data cGroup as string // Indica se deve agrupar

	Method Activate()
	Method Seek()
	Method DeActivate()
	Method Total()
	Method GetData()
	Method StartGetFormat()
	Method EndGetFormat()
	//Method SetAlias()
	Method Skip()

EndClass

/*/{Protheus.doc} oRU44W200::Activate
description
@type method
@version  
@author 
@since 03/07/2023
@return variant, return_description
/*/
Method Activate() Class oRU44W200

	Local lRet as logical

	// Set query order if received
	self:cOrder := self:GetQSValue("order")

	self:cSkip 			:= self:GetQSValue("skip")
	self:cPageSize 		:= self:GetQSValue("take")
	self:cFirstlevel	:= self:GetQSValue("firstlevel")
	self:lReqTotalCount := self:GetQSValue("requireTotalCount")
	self:cFilterVars 	:= self:GetQSValue("filterVars")
	self:cFilterExp 	:= self:GetQSValue("filter")
	self:cFieldDetail	:= self:GetQSValue("fieldDetail")
	self:cFieldVirtual	:= self:GetQSValue("fieldVirtual")
	self:cFieldEmpty	:= self:GetQSValue("fieldEmpty")
	self:cFields		:= self:GetQSValue("fields")
	self:cDebug			:= self:GetQSValue("debug")
	self:cInternalId	:= self:GetQSValue("internalId")
	self:cGroup			:= self:GetQSValue("group")

	//So os permitidos
	If _Super:Activate()
		If !MPUserHasAccess('RU44W200')
			_Super:setfilter("1=2")
			lRet := .F.
			self:SetStatusResponse(403, STR0001)
		Else
			// Set standard filter for model
			RU44X10002_FilterOnActivate(@self,'RU44W200')
			lRet := .T.
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} oRU44W200::DeActivate
description
@type method
@version  
@author
@since 03/07/2023
@return variant, return_description
/*/
Method DeActivate() Class oRU44W200

	If !(self:nStatus == Nil)
		self:SetStatusResponse({self:nStatus, EncodeUTF8(self:cStatus)})
	EndIf

Return _Super:DeActivate()

/*/{Protheus.doc} oRU44W200::Seek
description
@type method
@version  
@author
@since 03/07/2023
@param cPK, character, param_description
@return variant, return_description
/*/
Method Seek(cPK) Class oRU44W200

	Local lRet := RU44X10001_SeekMethod(@self, cPK)

Return lRet

/*/{Protheus.doc} Total
Método responsável retornar a quantidade total de regitros do alias.
Contagem é feita atravez de query.
@return nTotal  Quantidade total de registros.
@author 
@since 03/07/2023
@version P11, P12
/*/
Method Total() Class oRU44W200

	Local nTotal := 0

	nTotal := RU44X10003_Total(@self)

Return nTotal


Method GetData() Class oRU44W200
	Local cRet := self:cResponse
Return cRet

Method Skip() Class oRU44W200
Return .F.

Method StartGetFormat(nTotal, nCount, nStartIndex) Class oRU44W200
	
	Local cRet := ""
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EndGetFormat
Método retornar o conteúdo final do dado de retorno.
@return cRet    Conteúdo final
@author 
@since 03/07/2023
@version P11, P12
/*/
//-------------------------------------------------------------------
Method EndGetFormat() Class oRU44W200
	
	Local cRet := ""
	
Return cRet




Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { STR0002   , 'VIEWDEF.RU44W200', 0, 2, 0, NIL } )
Return aRotina

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruAF8
	Local oModel // Modelo de dados que ser? constru?do
//Local oRestModel:= oRU44W200():New()
	oStruAF8 := FWFormStruct( 1, 'AF8' ,/* { |x| ALLTRIM(x) $ ' AF9_PROJETO, AF9_REVISA, AF9_EDTPAI, AF9_TAREFA, AF9_DESCRI, AF9_NIVEL, AF9_GRPCOM,AF9_REQ, AF9_START, AF9_FINISH, AF9_HDURAC,AF9_OBS,' } */ )
	oModel := MPFormModel():New('RU44W200',,,)

//oModel:SetVldActivate( { |oModel| ACTIVATE( oModel ) } )

// Adiciona ao modelo um componente de formul?rio
	oModel:AddFields( 'AF8MASTER', /*cOwner*/, oStruAF8)

// Adiciona a descri??o do Modelo de Dados
//oModel:SetDescription( 'Modelo de dados de Autor/Interprete' )
// Adiciona a descri??o do Componente do Modelo de Dados
//oModel:GetModel( 'AF9MASTER' ):SetDescription( 'Dados de Autor/Interprete' )
// Retorna o Modelo de dados
//oModel:SetVldActivate( { |oModel| U_NPPMS306_PREVALID( oModel ) } )
//oModel:InstallEvent("NPPMS30Event", /*cOwner*/, oEvent)
Return oModel


Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( 'RU44W200' )
// Cria a estrutura a ser usada na View
	Local oStruAF8 := FWFormStruct( 2, 'AF8' )
// Interface de visualiza??o constru?da
	Local oView

	oStruAF8:SetNoFolder()
// Cria o objeto de View
	oView := FWFormView():New()
// Define qual o Modelo de dados ser? utilizado na View
	oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formul?rio
// (antiga Enchoice)
	oView:AddField( 'VIEW_AF8', oStruAF8, 'AF8MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'HEADER' , 100 )
// Relaciona o identificador (ID) da View com o "box" para exibi??o
	oView:SetOwnerView( 'VIEW_AF8', 'HEADER' )


// Retorna o objeto de View criado
Return oView

                   
//Merge Russia R14 
                   
