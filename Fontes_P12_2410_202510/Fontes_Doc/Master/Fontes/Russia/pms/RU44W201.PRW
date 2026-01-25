#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU44W201.CH"

#define PMS_MIN_DATE Ctod('01/01/1980')
#define PMS_MIN_HOUR '08:00'

/*MAINTENANCE FOR tasks (simple model to be used in web forms for VISUALIZATION)*/

/*Function RU44W201()
Local oBrowse
Private aRotina   := MenuDef()
//Think where to put it for calling directly from WEB
// Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()
// Defini??o da tabela do Browse
oBrowse:SetAlias('AF9')
//oBrowse:SetDescription('Cadastro de Autor/Interprete')
oBrowse:Activate()
Return NIL
*/

PUBLISH MODEL REST NAME RU44W201 RESOURCE OBJECT oRU44W201

/*/{Protheus.doc} oRU44W201
description
@type class
@version  
@author
@since 03/07/2023
/*/
Class oRU44W201 From FwRestModel

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
	Data cGroup as string // Indica se deve retornar o ID(Recno) como informação complementar das linhas do GRID (padrão: false)

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

/*/{Protheus.doc} oRU44W201::Activate
description
@type method
@version  
@author 
@since 03/07/2023
@return variant, return_description
/*/
Method Activate() Class oRU44W201

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
		If !MPUserHasAccess('RU44W201')
			_Super:setfilter("1=2")
			lRet := .F.
			self:SetStatusResponse(403, STR0001)
		Else
			// Set standard filter for model
			RU44X10002_FilterOnActivate(@self,'RU44W201')
			lRet := .T.
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} oRU44W201::DeActivate
description
@type method
@version  
@author
@since 03/07/2023
@return variant, return_description
/*/
Method DeActivate() Class oRU44W201

	If !(self:nStatus == Nil)
		self:SetStatusResponse({self:nStatus, EncodeUTF8(self:cStatus)})
	EndIf

Return _Super:DeActivate()

/*/{Protheus.doc} oRU44W201::Seek
description
@type method
@version  
@author
@since 03/07/2023
@param cPK, character, param_description
@return variant, return_description
/*/
Method Seek(cPK) Class oRU44W201

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
Method Total() Class oRU44W201

	Local nTotal := 0

	nTotal := RU44X10003_Total(@self)

Return nTotal


Method GetData() Class oRU44W201
	Local cRet := self:cResponse
Return cRet

Method Skip() Class oRU44W201
Return .F.

Method StartGetFormat(nTotal, nCount, nStartIndex) Class oRU44W201
	
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
Method EndGetFormat() Class oRU44W201
	
	Local cRet := ""
	
Return cRet


Static Function MenuDef() 
Local aRotina := {}
aAdd( aRotina, { STR0002   , 'VIEWDEF.RU44W201', 0, 2, 0, NIL } )
//aAdd( aRotina, { 'Insert' , 'VIEWDEF.RU44W201', 0, 3, 0, NIL } )
//aAdd( aRotina, { 'Modify' , 'VIEWDEF.RU44W201', 0, 4, 0, NIL } )
//aAdd( aRotina, { 'Delete' , 'VIEWDEF.RU44W201', 0, 5, 0, NIL } )
Return aRotina

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruAF9 := FWFormStruct( 1, 'AF9' , { |x| ALLTRIM(x) $ 'AF9_PROJET, AF9_REVISA, AF9_EDTPAI, AF9_TAREFA, AF9_DESCRI, AF9_NIVEL, AF9_GRPCOM,AF9_REQ, AF9_START, AF9_HORAI,AF9_HORAF,AF9_FINISH,AF9_CALEND,AF9_HDURAC,AF9_OBS,' }  )
Local oStruAFA := FWFormStruct( 1, 'AFA' , { |x| ALLTRIM(x) $ 'AFA_ITEM,AFA_RECURS,AFA_QUANT' }  )
Local oStruAFD := FWFormStruct( 1, 'AFD' ,/* { |x| ALLTRIM(x) $ 'AFA_ITEM,AFA_RECURS,AFA_QUANT' }*/  )
Local oModel // Modelo de dados que ser? constru?do
// Local oEvent := NPPMS30Event():New()
// Cria o objeto do Modelo de Dados

oStruAF9:SetProperty("AF9_EDTPAI", MODEL_FIELD_WHEN,   {|| !EMPTY(M->AF9_PROJET) })
oStruAF9:SetProperty("AF9_EDTPAI", MODEL_FIELD_VALID,  {|x,y,cValue| EXISTCPO('AFC',M->AF9_PROJET+M->AF9_REVISA+cValue)})
oStruAF9:SetProperty("AF9_TAREFA", MODEL_FIELD_WHEN,   {|| .F.} )

oStruAF9:SetProperty("AF9_START" , MODEL_FIELD_VALID,  {|| .t.}) //{|| U_NPPMS301_VALIDINI()})
oStruAF9:SetProperty("AF9_FINISH", MODEL_FIELD_VALID,  {|| .t.}) //{|| U_NPPMS301_VALIDINI()})
oStruAF9:SetProperty("AF9_HORAI" , MODEL_FIELD_VALID,  {|| .t.}) //{|| U_NPPMS301_VALIDINI()})
oStruAF9:SetProperty("AF9_HORAF" , MODEL_FIELD_VALID,  {|| .t.}) //{|| U_NPPMS301_VALIDINI()})
oStruAF9:SetProperty("AF9_HDURAC", MODEL_FIELD_VALID,  {|| .t.})  //{|| U_NPPMS302_VALIDDURAC()})
oStruAF9:SetProperty("AF9_CALEND", MODEL_FIELD_VALID,  {|| .t.})  //{|| U_NPPMS303_CALENDAR()})

oStruAFA:SetProperty("AFA_RECURS"   , MODEL_FIELD_VALID, {|| EXISTCPO('AE8')})  //{|| U_NPPMS303_CALENDAR()})
oStruAFA:SetProperty("AFA_QUANT"    , MODEL_FIELD_VALID, {|| POSITIVO()})  //{|| U_NPPMS303_CALENDAR()})
oStruAFA:SetProperty("AFA_QUANT"    , MODEL_FIELD_WHEN, {|| .T.})  //{|| U_NPPMS303_CALENDAR()})

oStruAF9:AddTrigger("AF9_PROJET", "AF9_TAREFA", /*[ bPre ]*/, {|x,y,cValue| PmsSetF3("AFC",10,cValue),""})
oStruAF9:AddTrigger("AF9_PROJET", "AF9_CALEND", /*[ bPre ]*/, {|x,y,cValue| POSICIONE('AF8',1,xFilial('AF8')+cValue,"AF8->AF8_CALEND")})
oStruAF9:AddTrigger("AF9_EDTPAI", "AF9_TAREFA", /*[ bPre ]*/, {|x,y,cValue| PmsNumAF9(M->AF9_PROJET,M->AF9_REVISA,NIL /*cNivelTrf*/,cValue,/*cTrfAtual*/,/*lLiberaCod*/)})
oStruAF9:AddTrigger("AF9_EDTPAI", "AF9_NIVEL",  /*[ bPre ]*/, {|x,y,cValue| SOMA1(POSICIONE('AFC',1,xFilial('AFC')+M->AF9_PROJET+M->AF9_REVISA+cValue,"AFC->AFC_NIVEL"))})
oStruAF9:AddTrigger("AF9_START" , "AF9_FINISH",  /*[ bPre ]*/,{|x,y,cValue| cValue})

oStruAFA:AddTrigger("AFA_RECURS", "AFA_PRODUT", /*[ bPre ]*/, {|x,y,cValue| POSICIONE('AE8',1,xFilial('AE8')+cValue,"AE8->AE8_PRODUT")})
oStruAFA:AddTrigger("AFA_RECURS", "AFA_DATPRF", /*[ bPre ]*/, {|x,y,cValue| M->AF9_START})

oStruAFD:SetProperty("AFD_HRETAR"   , MODEL_FIELD_VALID, {|x,y,z| U_NPPMS305_PREDECS(X,Y,Z)})  
oStruAFD:SetProperty("AFD_PREDEC"   , MODEL_FIELD_VALID, {|x,y,cValue| EXISTCPO('AF9',M->AF9_PROJET+M->AF9_REVISA+cValue).and.U_NPPMS305_PREDECS(X,Y,cValue)})  //{|| U_NPPMS303_CALENDAR()})
oStruAFD:SetProperty("AFD_TIPO"     , MODEL_FIELD_VALID, {|x,y,z| U_NPPMS305_PREDECS(X,Y,Z)})  

//oStruAF9:AddTrigger("AF9_EDTPAI", "AF9_TAREFA", /*[ bPre ]*/, {|X,Y,Z| u_DUM001(X,Y,Z)})

oModel := MPFormModel():New('RU44W201',,,)

//oModel:SetVldActivate( { |oModel| ACTIVATE( oModel ) } )
//oStruAF9:AddField(SX3->X3_CAMPO, '', SX3->X3_CAMPO, SX3->X3_TIPO, X3TITULO(),X3DESCRI() , {|| .F.}/*[ bWhen ]*/, , .F.,/* [ bInit ]*/,/* <lKey >*/, .T./*[ lNoUpd ]*/, /*[ lVirtual ]*/,/* [ cValid ]*/)
//FWFORMVIEWSTRUCT():AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AF8_DESCRI'))
oStruAF9:AddField(STR0006, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|| Posicione('AF8',1,xFilial('AF8')+ AF9->AF9_PROJET, 'AF8_DESCRI')}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)
SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AE8_DESCRI'))
oStruAFA:AddField(STR0007, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|| Posicione('AE8',1,xFilial('AE8')+ AFA->AFA_RECURS, 'AE8_DESCRI')}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)

// Adiciona ao modelo um componente de formul?rio
oModel:AddFields( 'AF9MASTER', /*cOwner*/, oStruAF9)
oModel:AddGrid( 'AFADETAIL', 'AF9MASTER', oStruAFA )
oModel:GetModel('AFADETAIL'):SetOptional( .T. )
oModel:SetRelation( 'AFADETAIL', { { 'AFA_FILIAL', 'xFilial( "AFA" )' }, {'AFA_PROJET', 'AF9_PROJET' }, {'AFA_REVISA', 'AF9_REVISA' }, {'AFA_TAREFA', 'AF9_TAREFA' } }, AFA->( IndexKey( 1 ) ) )

oModel:AddGrid( 'AFDDETAIL', 'AF9MASTER', oStruAFD )
oModel:GetModel('AFDDETAIL'):SetOptional( .T. )
oModel:SetRelation( 'AFDDETAIL', { { 'AFD_FILIAL', 'xFilial( "AFD" )' }, {'AFD_PROJET', 'AF9_PROJET' }, {'AFD_REVISA', 'AF9_REVISA' }, {'AFD_TAREFA', 'AF9_TAREFA' } }, AFD->( IndexKey( 1 ) ) )

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
Local oModel := FWLoadModel( 'RU44W201' )
// Cria a estrutura a ser usada na View
Local oStruAF9 := FWFormStruct( 2, 'AF9' , { |x| ALLTRIM(x) $ 'AF9_PROJET, AF9_REVISA, AF9_EDTPAI, AF9_TAREFA, AF9_DESCRI, AF9_NIVEL, AF9_GRPCOM,AF9_REQ, AF9_START, AF9_HORAI,AF9_HORAF,AF9_FINISH,AF9_CALEND,AF9_HDURAC,AF9_OBS,' } )
Local oStruAFA := FWFormStruct( 2, 'AFA' , { |x| ALLTRIM(x) $ 'AFA_RECURS,AFA_QUANT,AFA_PRODUT' } )
Local oStruAFD := FWFormStruct( 2, 'AFD' )
// Interface de visualiza??o constru?da
Local oView

oStruAF9:SetNoFolder()
// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados ser? utilizado na View
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formul?rio
// (antiga Enchoice)
oView:AddField( 'VIEW_AF9', oStruAF9, 'AF9MASTER' )
oView:AddGrid( 'VIEW_AFA', oStruAFA, 'AFADETAIL' )
oView:AddGrid( 'VIEW_AFD', oStruAFD, 'AFDDETAIL' )
oView:AddIncrementField( 'VIEW_AFD', 'AFD_ITEM' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'HEADER' , 50 )
oView:CreateHorizontalBox( 'AFA' , 25)
oView:CreateHorizontalBox( 'AFD' , 25)
// Relaciona o identificador (ID) da View com o "box" para exibi??o
oView:SetOwnerView( 'VIEW_AF9', 'HEADER' )
oView:SetOwnerView( 'VIEW_AFA', 'AFA' )
oView:SetOwnerView( 'VIEW_AFD', 'AFD' )


// Retorna o objeto de View criado
Return oView
                   
//Merge Russia R14 
                   
