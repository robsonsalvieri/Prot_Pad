#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU44W700.CH"
#INCLUDE "FWMVCDEF.CH"
/*MAINTENANCE FOR PROJECTS Pre-Annotation Confirmation (simple model to be used in web forms for VISUALIZATION and Maintenance)*/

PUBLISH MODEL REST NAME RU44W700 RESOURCE OBJECT oRU44W700

/*/{Protheus.doc} oRU44W700
MAINTENANCE FOR PROJECTS Pre-Annotation Confirmation (simple model to be used in web forms for VISUALIZATION and Maintenance)
@type class
@author Fernando Nicolau
@since 03/07/2023
/*/
Class oRU44W700 From FwRestModel

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
    Method SaveData()
    Method DelData()
	Method Skip()
EndClass

/*/
{Protheus.doc} oRU44W700::Activate
Activate method
@type method
@version  R14
@author Fernando Nicolau
@since 03/07/2023
@return logical, true if activated
/*/
Method Activate() Class oRU44W700

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
		If !MPUserHasAccess('RU44W700')
			_Super:setfilter("1=2")
			lRet := .F.
			self:SetStatusResponse(403, STR0001)
		Else
			// Set standard filter for model
			RU44X10002_FilterOnActivate(@self,'RU44W700')
			lRet := .T.
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet

/*/
{Protheus.doc} oRU44W700::DeActivate
Deactivate method 
@type method
@version R14 
@author Fernando Nicolau
@since 03/07/2023
@return logical, Super class return
/*/
Method DeActivate() Class oRU44W700

	If !(self:nStatus == Nil)
		self:SetStatusResponse({self:nStatus, EncodeUTF8(self:cStatus)})
	EndIf

Return _Super:DeActivate()

/*/
{Protheus.doc} oRU44W700::Seek
Superclass override to improve seek function to use queries
@type method
@version  R14
@author Fernando Nicolau
@since 03/07/2023
@param cPK, character, Primary key
@return logical, true if found
/*/
Method Seek(cPK) Class oRU44W700

	Local lRet := RU44X10001_SeekMethod(@self, cPK)

Return lRet

/*/{Protheus.doc} Total
Returns total amount of records for filters defined
@type method
@version  R14
@author Fernando Nicolau
@since 03/07/2023
@return numeric, total records
/*/
Method Total() Class oRU44W700

	Local nTotal := 0

	nTotal := RU44X10003_Total(@self)

Return nTotal


/*/{Protheus.doc} Total
Returns model list data
@type method
@version  R14
@author Fernando Nicolau
@since 03/07/2023
@return character, records in JSON format
/*/
Method GetData() Class oRU44W700
	Local cRet := self:cResponse
Return cRet

Method Skip() Class oRU44W700
Return .F.

Method StartGetFormat(nTotal, nCount, nStartIndex) Class oRU44W700
	
Local cRet := ""
	
Return cRet

// //-------------------------------------------------------------------
// /*/{Protheus.doc} EndGetFormat
// Método retornar o conteúdo final do dado de retorno.
// @return cRet    Conteúdo final
// @author 
// @since 03/07/2023
// @version P11, P12
// /*/
// //-------------------------------------------------------------------
Method EndGetFormat() Class oRU44W700
	
Local cRet := ""
	
Return cRet


/*/{Protheus.doc} DelData
Method returns true if data was deleted successfully
@type method
@author Bruno Sobieski
@since 15/05/2024
@version R14
@return logical, true if deleted
/*/
Method DelData(cPk,cError) Class oRU44W700
    Local lRet      := .T.
    Default cData   := ""

    lRet := RU44X10005_DelData(self, cPk,@cError)
	If !lRet 
		setRestFault(400,EncodeUTF8(cError))
	Endif
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SaveData
Method returns true if data was saved successfully
@type method
@author Fernando nicolau
@since 15/05/2024
@version R14
@return logical, true if saved
/*/
Method SaveData(cPk,cData,cError) Class oRU44W700
    Local lRet      := .T.
    Default cData   := ""

    lRet := RU44X10004_SaveData(self, cPk,cData,@cError)
Return lRet


Function RU44W700()
Local cFiltraAJK := 'AJK_FILIAL == "'+xFilial("AJK")+'" .AND. AJK_CTRRVS == "1"'
Local oBrowse
If AMIIn(44)
	If PmsChkAJK(.T.)
		PRIVATE aRotina		:= MenuDef()
		// Instanciamento da Classe de Browse
		oBrowse := FWMBrowse():New()
		// Definição da tabela do Browse
		oBrowse:SetAlias('AJK')
	
		// Definição de filtro
		oBrowse:SetFilterDefault( cFiltraAJK )
	
		// Titulo da Browse
		oBrowse:SetDescription('Pre-annotations')
		// Opcionalmente pode ser desligado a exibição dos detalhes
		oBrowse:DisableDetails()
		// Ativação da Classe
		oBrowse:Activate()
	EndIf
EndIf
Return 

Static Function MenuDef() 
Local aRotina := {}
aAdd( aRotina, { STR0002   , 'VIEWDEF.RU44W700', 0, 2, 0, NIL } )
aAdd( aRotina, { STR0003   , 'VIEWDEF.RU44W700', 0, 3, 0, NIL } )
aAdd( aRotina, { STR0004   , 'VIEWDEF.RU44W700', 0, 4, 0, NIL } )
aAdd( aRotina, { STR0030   , 'VIEWDEF.RU44W700', 0, 5, 0, NIL } )
Return aRotina

/*/{Protheus.doc} ModelDef
Modeldef for pre-appointments
@type function
@version  R14
@author bsobieski
@since 14/08/2024
/*/
Static Function ModelDef() 
Local oStruAJK
Local oModel 
//Local oModelEv As Object
Local bCommit   := {|oModel| RU44W700Commit(oModel) }
Local bFieldPre	:= {|oModel, cModelId, cAction, cId, xValue| FieldPreVld(oModel, cModelId, cAction, cId, xValue)}
Local bPre		:= {|oModel| RU44W700ActivatePreValidation(oModel)}
Local bPost		:= {|oModel| RU44W700PosValidation(oModel)}
oStruAJK := FWFormStruct( 1, 'AJK'  )
oModel := MPFormModel():New('RU44W700',bFieldPre,bPost,bCommit)
oModel:SetVldActivate(bPre)

SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AF9_DESCRI'))

oStruAJK:AddField(STR0005, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|oModel| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT,'',Posicione('AF9',1,xFilial('AF9')+ AJK->AJK_PROJET + AJK->AJK_REVISA + AJK->AJK_TAREFA, 'AF9_DESCRI'))}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)
SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AE8_DESCRI'))
oStruAJK:AddField(STR0006, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|oModel| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT,'', Posicione('AE8',1,xFilial('AE8')+ AJK->AJK_RECURS, 'AE8_DESCRI'))}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)
SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AE8_EQUIP'))
oStruAJK:AddField(STR0008, ''/*<cTooltip >*/, AllTrim(SX3->X3_CAMPO) , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|oModel| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT,'', Posicione('AE8',1,xFilial('AE8')+ AJK->AJK_RECURS, 'AE8_EQUIP'))}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)
					
SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AED_DESCRI'))
oStruAJK:AddField(STR0009, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|oModel| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT,'', RU44X10006_GetTeamName('AJK'))}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)

SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AF8_DESCRI'))
oStruAJK:AddField(STR0007, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|oModel| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT,'',Posicione('AF8',1,xFilial('AF8')+ AJK->AJK_PROJET, 'AF8_DESCRI'))}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)

If !oStruAJK:HasField('AJK_CTRRVS')
	SX3->(DbSetOrder(2))
	SX3->(DBSEEK( 'AJK_CTRRVS'))
	oStruAJK:AddField(X3Titulo(), ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|| '1'}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.F. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)
Endif
If !oStruAJK:HasField('AJK_CODME1')

	SX3->(DbSetOrder(2))
	SX3->(DBSEEK( 'AJK_CODME1'))
	oStruAJK:AddField(X3Titulo(), ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					/**/, ;
 					.F. /*<lKey >*/,;
  					.F. /*[ lNoUpd ]*/,;
  					.F. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)
Endif
If !oStruAJK:HasField('AJK_CODMEM')
	SX3->(DbSetOrder(2))
	SX3->(DBSEEK( 'AJK_CODMEM'))
	oStruAJK:AddField(X3Titulo(), ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					/**/, ;
 					.F. /*<lKey >*/,;
  					.F. /*[ lNoUpd ]*/,;
  					.F. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)
Endif

aAuxTrg := FwStruTrigger(;
      "AJK_RECURS" ,; // Campo Dominio
      "AE8_DESCRI" ,; // Campo de Contradominio
      "Posicione('AE8',1,xFilial('AE8')+ M->AJK_RECURS, 'AE8_DESCRI')",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStruAJK:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])

aAuxTrg := FwStruTrigger(;
      "AJK_RECURS" ,; // Campo Dominio
      "AE8_EQUIP" ,; // Campo de Contradominio
      "Posicione('AE8',1,xFilial('AE8')+ M->AJK_RECURS, 'AE8_EQUIP')",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "02" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStruAJK:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AJK_RECURS" ,; // Campo Dominio
      "AED_DESCRI" ,; // Campo de Contradominio
      "Posicione('AED',1,xFilial('AED')+ AE8->AE8_EQUIP, 'AED_DESCRI')",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AE8" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AE8')+M->AJK_RECURS" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "03" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAJK:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AJK_RECURS" ,; // Campo Dominio
      "AJK_HQUANT" ,; // Campo de Contradominio
      "PmsHrsItvl(M->AJK_DATA,M->AJK_HORAI,M->AJK_DATA,M->AJK_HORAF,AE8->AE8_CALEND,M->AJK_PROJET,M->AJK_RECURS,,.T.)",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AF9" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AF9')+M->AJK_PROJET+M->AJK_REVISA+M->AJK_TAREFA" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AJK_TAREFA) .And.!Empty(M->AJK_DATA) .And. !Empty(M->AJK_HORAI).And. !Empty(M->AJK_HORAF).And. !Empty(M->AJK_PROJET).And.!Empty(M->AJK_RECURS)" ,; // Condicao para execucao do gatilho
      "04" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAJK:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])

aAuxTrg := FwStruTrigger(;
      "AJK_DATA" ,; // Campo Dominio
      "AJK_HQUANT" ,; // Campo de Contradominio
      "PmsHrsItvl(M->AJK_DATA,M->AJK_HORAI,M->AJK_DATA,M->AJK_HORAF,AE8->AE8_CALEND,M->AJK_PROJET,M->AJK_RECURS,,.T.)",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AF9" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AF9')+M->AJK_PROJET+M->AJK_REVISA+M->AJK_TAREFA" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AJK_TAREFA) .And.!Empty(M->AJK_DATA) .And. !Empty(M->AJK_HORAI).And. !Empty(M->AJK_HORAF).And. !Empty(M->AJK_PROJET).And.!Empty(M->AJK_RECURS)" ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAJK:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AJK_HORAI" ,; // Campo Dominio
      "AJK_HQUANT" ,; // Campo de Contradominio
      "PmsHrsItvl(M->AJK_DATA,M->AJK_HORAI,M->AJK_DATA,M->AJK_HORAF,AE8->AE8_CALEND,M->AJK_PROJET,M->AJK_RECURS,,.T.)",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AF9" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AF9')+M->AJK_PROJET+M->AJK_REVISA+M->AJK_TAREFA" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AJK_TAREFA) .And.!Empty(M->AJK_DATA) .And. !Empty(M->AJK_HORAI).And. !Empty(M->AJK_HORAF).And. !Empty(M->AJK_PROJET).And.!Empty(M->AJK_RECURS)" ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAJK:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])


aAuxTrg := FwStruTrigger(;
      "AJK_HORAF" ,; // Campo Dominio
      "AJK_HQUANT" ,; // Campo de Contradominio
      "PmsHrsItvl(M->AJK_DATA,M->AJK_HORAI,M->AJK_DATA,M->AJK_HORAF,AE8->AE8_CALEND,M->AJK_PROJET,M->AJK_RECURS,,.T.)",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AF9" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AF9')+M->AJK_PROJET+M->AJK_REVISA+M->AJK_TAREFA" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AJK_TAREFA) .And.!Empty(M->AJK_DATA) .And. !Empty(M->AJK_HORAI).And. !Empty(M->AJK_HORAF).And. !Empty(M->AJK_PROJET).And.!Empty(M->AJK_RECURS)" ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAJK:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AJK_PROJET" ,; // Campo Dominio
      "AJK_HQUANT" ,; // Campo de Contradominio
      "PmsHrsItvl(M->AJK_DATA,M->AJK_HORAI,M->AJK_DATA,M->AJK_HORAF,AE8->AE8_CALEND,M->AJK_PROJET,M->AJK_RECURS,,.T.)",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AF9" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AF9')+M->AJK_PROJET+M->AJK_REVISA+M->AJK_TAREFA" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AJK_TAREFA) .And.!Empty(M->AJK_DATA) .And. !Empty(M->AJK_HORAI).And. !Empty(M->AJK_HORAF).And. !Empty(M->AJK_PROJET).And.!Empty(M->AJK_RECURS)" ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAJK:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])

aAuxTrg := FwStruTrigger(;
      "AJK_TAREFA" ,; // Campo Dominio
      "AJK_SLDHR" ,; // Campo de Contradominio
      "A700HrSld(M->AJK_PROJET,M->AJK_REVISA,M->AJK_TAREFA,M->AJK_RECURS)",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AJK_PROJET).And.!Empty(M->AJK_TAREFA).And.!Empty(M->AJK_RECURS)" ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAJK:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])

oStruAJK:SetProperty('AJK_SITUAC',MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, '"1"'))
If oStruAJK:GetProperty('AJK_RECURS',MODEL_FIELD_INIT) == NIL
	oStruAJK:SetProperty('AJK_RECURS'  ,MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "RU44W70003GetResource()"))
EndIf
If oStruAJK:GetProperty('AJK_DATA',MODEL_FIELD_INIT) == NIL
 	oStruAJK:SetProperty('AJK_DATA'  ,MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "RU44W70002GetDate()"))
EndIf
If oStruAJK:GetProperty('AJK_SLDHR',MODEL_FIELD_INIT) == NIL
 	oStruAJK:SetProperty('AJK_SLDHR'  ,MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "A700HrSld(AJK->AJK_PROJET,AJK->AJK_REVISA,AJK->AJK_TAREFA,AJK->AJK_RECURS)"))
EndIf

SX3->(DbSetOrder(2))
SX3->(DbSeek('AJK_TAREFA'))
//Substitute standard validations
oStruAJK:SetProperty("AJK_TAREFA", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'RU44W70004VldTask()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )
SX3->(DbSeek('AJK_DATA'))
oStruAJK:SetProperty("AJK_DATA", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'RU44W70008VldData()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )
SX3->(DbSeek('AJK_RECURS'))
oStruAJK:SetProperty("AJK_RECURS", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'RU44W70007VldResource()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )
SX3->(DbSeek('AJK_HORAI'))
oStruAJK:SetProperty("AJK_HORAI", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'AtVldHora(M->AJK_HORAI).and.RU44W70005VldHoraI()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )
SX3->(DbSeek('AJK_HORAF'))
oStruAJK:SetProperty("AJK_HORAF", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'AtVldHora(M->AJK_HORAF).and.RU44W70006VldHoraF()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )
SX3->(DbSeek('AJK_HQUANT'))
oStruAJK:SetProperty("AJK_HQUANT", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'POSITIVO()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )


FWMemoVirtual( oStruAJK,{ { 'AJK_CODMEM' , 'AJK_OBS' } , { 'AJK_CODME1' , 'AJK_MOTIVO'} } )

oModel:AddFields( 'AJKMASTER', /*cOwner*/, oStruAJK)

oModel:SetPrimaryKey({'AJK_CTRRVS','AJK_PROJET','AJK_REVISA','AJK_TAREFA','AJK_RECURS','AJK_DATA','AJK_HORAI' })
//oModelEv := RU44W700EventRUS():New()
//oModel:InstallEvent("oModelEv", /*cOwner*/, oModelEv)
Return oModel

/*/{Protheus.doc} ViewDef
ViewDef for pre-appointments
@type function
@version  R14
@author bsobieski
@since 14/08/2024
/*/
Static Function ViewDef()
Local oModel := FWLoadModel( 'RU44W700' )
Local oStruAJK := FWFormStruct( 2, 'AJK' )
Local oView

oStruAJK:SetNoFolder()
oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_AJK', oStruAJK, 'AJKMASTER' )

oView:CreateHorizontalBox( 'HEADER' , 100 )
oView:SetOwnerView( 'VIEW_AJK', 'HEADER' )

Return oView

/*/{Protheus.doc} RU44W700Commit
Function responsible for COMMIT of the model
@type function
@version  1.0
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if succeded
/*/
Static Function RU44W700Commit(oModel)
	Local lRet 		:= .T. 	as logical
    DbSelectArea("AJK")
    If oModel:GetOperation() == MODEL_OPERATION_INSERT 
		Begin transaction
			//Fill MEMO fields
			// If !Empty(oModel:GetValue("AJKMASTER", "AJK_OBS"))
			// 	cCode := MSMM(,TamSx3("AJK_OBS")[1],,oModel:GetValue("AJKMASTER", "AJK_OBS"),1,,,"AJK","AJK_CODMEM")
			// 	oModel:LoadValue("AJKMASTER", "AJK_CODMEM", cCode)
			// Endif
			// If !Empty(oModel:GetValue("AJKMASTER", "AJK_MOTIVO"))
			// 	cCode := MSMM(,TamSx3("AJK_MOTIVO")[1],,oModel:GetValue("AJKMASTER", "AJK_MOTIVO"),1,,,"AJK","AJK_CODME1")
			// 	oModel:LoadValue("AJKMASTER", "AJK_CODME1", cCode)				
			// EndIf
			FWFormCommit( oModel )
		End Transaction
	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
		Begin Transaction
			//Fill MEMO fields
			// If !Empty(oModel:GetValue("AJKMASTER", "AJK_OBS"))
			// 	RU44XFUN03(oModel, "AJKMASTER", "AJK_OBS", "AJK_CODMEM", "AJK")
			// EndIf
			// If !Empty(oModel:GetValue("AJKMASTER", "AJK_MOTIVO"))
			// 	RU44XFUN03(oModel, "AJKMASTER", "AJK_MOTIVO", "AJK_CODME1", "AJK")
			// EndIf
			FWFormCommit( oModel )
		End Transaction
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE		
		Begin Transaction	
		FWFormCommit( oModel )
		End Transaction
	Endif
Return lRet

Static Function FieldPreVld(oSubModel, cModelId, cAction, cId, xValue)
    Local lRet := .T.
	Local cMessage:= ""

    If oSubModel:GetOperation() == MODEL_OPERATION_UPDATE .And. cAction == "SETVALUE" .And. cId == "AJK_SITUAC"
        If lRet .And. oSubModel:GetValue("AJK_SITUAC") == '3' .And. xValue == '2'
            cMessage := STR0013
            lRet := .F.
        EndIf
        If lRet .And. oSubModel:GetValue("AJK_SITUAC") == '2' .And. xValue == '3'
            cMessage := STR0026
            lRet := .F.
        EndIf
        If lRet .And. oSubModel:GetValue("AJK_SITUAC") == '1' .And. (xValue == Nil .Or. Empty(xValue))
            cMessage := STR0027
            lRet := .F.
        EndIf
        If !lRet
			Help(NIL, NIL, STR0010, NIL,cMessage, 1, 0, NIL, NIL, NIL, NIL, NIL,)
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} RU44W700ActivatePreValidation
Validates if the requested operation model can be executed for this model.
This validation is independent from data sent to the model, it is used to check usually permissions and status of record
@type function
@version  1.0
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if prevalidation succeeed
/*/
Static Function RU44W700ActivatePreValidation(oModel, cModelId, cAction, cId, xValue)
Local lRet := .T. as logical
Local lInsert := oModel:GetOperation() == MODEL_OPERATION_INSERT as logical
Local lUpdate := oModel:GetOperation() == MODEL_OPERATION_UPDATE as logical
Local lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE as logical
Local lView   := !(lInsert .Or. lDelete .Or. lUpdate) as logical
		 
If !(lView).And. !lInsert .And. !Empty(AJK->AJK_PROJET) 
	If !PmsVldFase("AF8",AJK->AJK_PROJET, "88")
		lRet := .F.
	EndIf
EndIf 
                   
// verificar data do ultimo fechamento do Projeto
If lRet .And. (lUpdate .Or. lDelete)
	AF8->(dbSetOrder(1))
	If AF8->(MsSeek(xFilial()+ AJK->AJK_PROJET))
		If !Empty(AF8->AF8_ULMES) .and. (AF8->AF8_ULMES >= AJK->AJK_DATA)
			Help(NIL, NIL, STR0010, NIL, i18n(STR0011, {DTOC(AF8->AF8_ULMES)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet :=.F.
		EndIf
	EndIf`
EndIf

If lRet .AND. !lInsert
	Do Case
		Case lView //.And. IsInCallStack('RU44W700')
			If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 2, "PREREC", AJK->AJK_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{AJK->AJK_PROJET,AJK->AJK_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf
		Case lUpdate
			//At Pre-Validation still do not know if this is an approval or an edit, so validate both
			If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 3, "PREREC", AJK->AJK_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{AJK->AJK_PROJET,AJK->AJK_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf
			If lRet 
				If AJK->AJK_SITUAC == '2' 
					cMessage := STR0026
					lRet	:=	.F.
				ElseIf AJK->AJK_SITUAC == '3' 
					cMessage := STR0013
					lRet	:=	.F.
				Endif
				If !lRet
					Help(NIL, NIL, STR0010, NIL, cMessage, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				Endif
			EndIf
		Case lDelete
			If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 4, "PREREC", AJK->AJK_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{AJK->AJK_PROJET,AJK->AJK_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf
            If lRet .And. (AJK->AJK_SITUAC $ "2;3")
                Help(NIL, NIL, STR0010, NIL, i18n(STR0014,{IIf(AJK->AJK_SITUAC =="2", STR0015, STR0016)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
                lRet := .F.
            EndIf
	EndCase
		
EndIf
Return lRet
/*/{Protheus.doc} RU44W700Posvalidation
Validates the data of the model as a whole, before trying to commit the model
@type function
@version  R14
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if validation succeeed
/*/
Static Function RU44W700Posvalidation(oModel)
Local lRet := .T. as logical
Local lInsert := oModel:GetOperation() == MODEL_OPERATION_INSERT as logical
Local lUpdate := oModel:GetOperation() == MODEL_OPERATION_UPDATE as logical
Local lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE as logical
If lUpdate
	If oModel:GetValue("AJKMASTER", "AJK_SITUAC") <> (Iif(Empty(AJK->AJK_SITUAC),"1", AJK->AJK_SITUAC))
		Help(NIL, NIL, STR0010, NIL, STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0018})
	 	lRet := .F.
	EndIf
	//Validate phase only if project code changed:
	If lRet .And. AJK->AJK_PROJET <> oModel:GetValue("AJKMASTER", "AJK_PROJET")
		//Maintenance pre-annotations (only if situation did not change)
		If oModel:GetValue("AJKMASTER", "AJK_SITUAC") == AJK->AJK_SITUAC  .And. ;
			!PmsVldFase("AF8", oModel:GetValue("AJKMASTER", "AJK_PROJET"), "88")
			lRet := .F.
		EndIf
		//If change was not on SITUATION check access to INSERT/CHANGE PRE-REQS

		If lRet .And.;
			!PmsChkUser(oModel:GetValue("AJKMASTER", "AJK_PROJET"), oModel:GetValue("AJKMASTER", "AJK_TAREFA"), NIL, "", 3, "PREREC", oModel:GetValue("AJKMASTER", "AJK_REVISA"), /*cUser*/, .F.)			
			Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{oModel:GetValue("AJKMASTER", "AJK_PROJET"),oModel:GetValue("AJKMASTER", "AJK_TAREFA")}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet := .F.
		Endif
		If lRet .And. (oModel:GetValue("AJKMASTER", "AJK_PROJET") <> AJK->AJK_PROJET .or. oModel:GetValue("AJKMASTER", "AJK_TAREFA") <> AJK->AJK_TAREFA) .And. ;
			!PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 3, "PREREC", AJK->AJK_REVISA, /*cUser*/, .F.) 
			Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{AJK->AJK_PROJET,AJK->AJK_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet := .F.
		Endif
		If lRet .And. SuperGetMV("MV_PMSVRAL", .F., 0) <> 0
			If !IsAllocatedRes(M->AJK_PROJET, M->AJK_REVISA, M->AJK_TAREFA, M->AJK_RECURS)
				Help(NIL, NIL, STR0012, NIL, STR0029, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet := .F.
			EndIf
		EndIf

	EndIf 
 ElseIf lInsert
	AF8->(dbSetOrder(1))
	If AF8->(MsSeek(xFilial()+oModel:GetValue("AJKMASTER", "AJK_PROJET")))
		If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(oModel:GetValue("AJKMASTER", "AJK_DATA")))
			Help(NIL, NIL, STR0010, NIL, i18n(STR0011, {DTOC(AF8->AF8_ULMES)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet :=.F.
		EndIf
	EndIf
	If lRet .And. !PmsVldFase("AF8", oModel:GetValue("AJKMASTER", "AJK_PROJET"), "88")
		lRet := .F.
	EndIf 
	If lRet .And. !PmsChkUser(oModel:GetValue("AJKMASTER", "AJK_PROJET"), oModel:GetValue("AJKMASTER", "AJK_TAREFA"), NIL, "", 3, "PREREC", oModel:GetValue("AJKMASTER", "AJK_REVISA"), /*cUser*/, .F.)
		Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{oModel:GetValue("AJKMASTER", "AJK_PROJET"),oModel:GetValue("AJKMASTER", "AJK_TAREFA")}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
		lRet := .F.
	Endif
	If lRet .And. SuperGetMV("MV_PMSVRAL", .F., 0) <> 0
		If !IsAllocatedRes(M->AJK_PROJET, M->AJK_REVISA, M->AJK_TAREFA, M->AJK_RECURS)
			Help(NIL, NIL, STR0012, NIL, STR0029, 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet := .F.
		EndIf
	EndIf

ElseIf lDelete
	If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 4, "PREREC", AJK->AJK_REVISA, /*cUser*/, .F.)
		Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{AJK->AJK_PROJET,AJK->AJK_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
		lRet	:=.F.
	EndIf
	If lRet .And. (AJK->AJK_SITUAC $ "2;3")
		//Aviso(STR0002,STR0009,{"Ok"},2) //"Operacao Invalida"### //"Pre Apontamento, já foi aprovado/rejeitado. Verifique"
		Help(NIL, NIL, STR0010, NIL, i18n(STR0014,{IIf(oModel:GetValue("AJKMASTER", "AJK_SITUAC") =="2", STR0015, STR0016)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
		lRet := .F.
	EndIf
EndIf

If lRet .And. ( lInsert .Or. lUpdate)
	//Validate start and end time on POST, because they depend on task and resource, and because situation may have changed since it was validated.
	lRet := RU44W70009VldInterval(oModel)
Endif
Return lRet
/*/{Protheus.doc} RU44W70001GetHour
Standard init for hour. It gets the START or FINISH hour for the current resource linked to the user in his standard calendar.
To override, create a different content on X3_RELACAO for the fields
@type function
@version  1.0
@author bsobieski
@since 14/08/2024
@param cType, character, INIT for start hour, FINISH for finish hour
@return character, hour in xx:xx format
/*/
Function RU44W70001GetHour(cType) as character
Local nX as numeric
Local nPosToday as numeric
Local nPosCheck as numeric
Local aCalend as Array
Local nLastDay := 0  as numeric
Local cRet := ""  as character
//Do not remove, is needed to select any area for a bug on PMSCALEND
DbSelectArea('AE8')
DbSetOrder(3)
If AE8->(MsSeek(xFilial()+__cUserId))
	If !Empty(AE8->AE8_CALEND)
		aCalend := PmsCalend(AE8->AE8_CALEND)
		nPosToday := Dow(dDataBase)
		If nPosToday > 0
			If aCalend[nPosToday][2] <> Nil 
				nPosCheck := nPosToday
			Else
				nPosCheck := nPosToday - 1				
				While nPosCheck <> nPosToday
					If nPosCheck == 0
						nPosCheck := Len(aPMSCalend)
					Endif
					If aCalend[nPosToday][nPosCheck] <> Nil 
						Exit
					Endif
					nPosCheck--
					nLastDay-- 
				Enddo
			Endif
		Endif
		If cType == 'INIT'
			cRet :=  Right(aCalend[nPosCheck][2],5)
		ElseIf cType == 'FINISH'
			//Position 2 is first start, so need to search for last position with valid hour, after position 2
			For nX := 3 To Len(aCalend[nPosCheck])
				If (aCalend[nPosCheck][nX] == Nil)
					Exit
				Else
					cRet :=  Right(aCalend[nPosCheck][nX],5)
				Endif
			Next
		Endif
	Endif
Endif

Return cRet
/*/{Protheus.doc} RU44W70002GetDate
Standard init for date. 
It gets the first working day before (or equal) to today for the current resource linked to the user in his standard calendar.
To override, create a different content on X3_RELACAO for the field
@type function
@version  1.0
@author bsobieski
@since 14/08/2024
@param cType, character, INIT for start hour, FINISH for finish hour
@return date, first working day according to resource calendar (linked by user name)
/*/
Function RU44W70002GetDate() as Date
Local nPosToday as numeric
Local nPosCheck as numeric
Local aCalend as Array
Local nLastDay := 0 as numeric
Local dRet := dDatabase as date
//Do not remove, is needed to select any area for a bug on PMSCALEND
DbSelectArea('AE8')
DbSetOrder(3)

If AE8->(MsSeek(xFilial()+__cUserId))
	If !Empty(AE8->AE8_CALEND)
		aCalend := PmsCalend(AE8->AE8_CALEND)
		nPosToday := Dow(dDataBase)
		If nPosToday > 0
			If aCalend[nPosToday][2] <> Nil 
				nPosCheck := nPosToday
			Else
				nPosCheck := nPosToday - 1				
				While nPosCheck <> nPosToday
					If nPosCheck == 0
						nPosCheck := Len(aPMSCalend)
					Endif
					If aCalend[nPosToday][nPosCheck] <> Nil 
						Exit
					Endif
					nPosCheck--
					nLastDay-- 
				Enddo
			Endif
		Endif
		dRet := dDatabase - nLastDay
	Endif
Endif

Return dRet

/*/{Protheus.doc} RU44W70003GetResource
Gets resource linked to current user
To override, create a different content on X3_RELACAO for the field
@type function
@version  1.0
@author bsobieski
@since 14/08/2024
@return date, first working day according to resource calendar (linked by user name)
/*/
Function RU44W70003GetResource() as character
Local cRet := "" as character
AE8->(DbSetOrder(3))
If AE8->(MsSeek(xFilial()+__cUserId))
	cRet := AE8->AE8_RECURS
Endif

Return cRet
/*/{Protheus.doc} RU44W70004VldTask
Validates task typed
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W70004VldTask() as logical
Local lRet := .T. as logical
If !Empty(M->AJK_TAREFA) .And. !Empty(M->AJK_PROJET)
	lRet := ExistCpo("AF9",M->AJK_PROJET+M->AJK_REVISA+M->AJK_TAREFA,1)
EndIf
Return lRet

/*/{Protheus.doc} RU44W70007VldResource
Validates resource typed
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W70007VldResource() as logical
Local lRet := .T. as logical
If !Empty(M->AJK_RECURS)
	lRet := ExistCpo("AE8",M->AJK_RECURS,1)
Endif
Return lRet

/*/{Protheus.doc} RU44W70008VldData
Validates date typed
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W70008VldData() as logical
Local lRet := .T. as logical
Local oModel 	   := FWModelActive() as object
AF8->(dbSetOrder(1))
If AF8->(MsSeek(xFilial()+oModel:GetValue("AJKMASTER", "AJK_PROJET")))
	If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(oModel:GetValue("AJKMASTER", "AJK_DATA")))
		Help(NIL, NIL, STR0010, NIL, i18n(STR0011, {DTOC(AF8->AF8_ULMES)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
		lRet :=.F.
	EndIf
EndIf

Return lRet


/*/{Protheus.doc} RU44W70009VldInterval
Validates interval typed. This functions should be called only on MODEL Validation and not on HOURS
fields to avoid having dead loops when typing start/finish hour
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W70009VldInterval(oModel as Object) as logical
Local lBlqApt		:= .F. as logical
Local nRecAlt 		:= 0 as numeric
Local lRet 			:= .T. as logical
Local nQtdHrAnt		:= 0 as numeric
If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	nQtdHrAnt   := AJK->AJK_HQUANT
	nRecAlt 	:= AJK->(RecNo())
EndIf

AF8->(DbsetOrder(1)) 
AF8->(MSSeek(xFilial()+M->AJK_PROJET))
lBlqApt := AF8->AF8_PAR001=="1"

dbSelectArea("AE8")
dbSetOrder(1)
MsSeek(xFilial('AE8')+M->AJK_RECURS)
If lRet.And. AE8->AE8_UMAX <= 100 
	lRet := CheckAppointments(M->AJK_HORAI,M->AJK_HORAF, nRecAlt)
EndIf        	
If lRet
	//lRet := oModel:SetValue('AJKMASTER','AJK_HQUANT',  PmsHrsItvl(M->AJK_DATA,M->AJK_HORAI,M->AJK_DATA,M->AJK_HORAF,AE8->AE8_CALEND,M->AJK_PROJET,M->AJK_RECURS,,.T.) )
	If lBlqApt
		lRet := PMSVldSld(nQtdHrAnt) 
	EndIf
Endif

Return lRet

/*/{Protheus.doc} IsAllocatedRes
Checks if resource is allocated to the task to make the appointment
@type function
@version  R14
@author bsobieski
@since 19/08/2024
@param cProject, character, Project code
@param cRevision, character, Version code
@param cTask, character, Task code
@param cResource, character, Resource code
@return Logical, True if resource is allocated on the task
/*/
Static Function IsAllocatedRes(cProject, cRevision, cTask, cResource) as logical
Local aArea := GetArea() as Array
Local aAreaAFA := AFA->(GetArea()) As Array

Local lReturn := .F. as Logical

dbSelectArea("AFA")
AFA->(dbSetOrder(5))

// AFA - índice 5:	
// AFA_FILIAL + AFA_PROJET + AFA_REVISA + AFA_TAREFA + AFA_RECURS

lReturn := AFA->(MsSeek(xFilial("AFA") + cProject + cRevision + cTask + cResource))

RestArea(aAreaAFA)	
RestArea(aArea)
Return lReturn
/*/{Protheus.doc} RU44W70005VldHoraI
Validates starting time
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W70005VldHoraI() as logical
Local aArea        := GetArea() as Array
Local aAreaAJK     := AJK->(GetArea()) as Array
Local lRet         := .T. as logical
Local cHora        := M->AJK_HORAI  as character
Local lBlqApt		:= .F. as logical
Local nRecAlt 		:= 0 as numeric
Local oModel 	    := FWModelActive() as object

If !Empty(M->AJK_RECURS).And.!Empty(M->AJK_PROJET)
	AF8->(DbsetOrder(1)) 
	AF8->(MSSeek(xFilial()+M->AJK_PROJET))
	lBlqApt := AF8->AF8_PAR001=="1"

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		nRecAlt   := AJK->(RecNo())
	EndIf

		
	M->AJK_HORAI := AdjusTimeToPrecision(cHora)
	oModel:LoadValue('AJKMASTER','AJK_HORAI', M->AJK_HORAI )
	If  !Empty(M->AJK_DATA)
		If lRet .And. !Empty(M->AJK_HORAF)
			If SubStr(cHora,1,2)+Substr(cHora,4,2) > Substr(M->AJK_HORAF,1,2)+Substr(M->AJK_HORAF,4,2)
				Help(NIL, NIL, STR0020, NIL, STR0021, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet := .F.
			EndIf
		EndIf

		dbSelectArea("AE8")
		dbSetOrder(1)
		MsSeek(xFilial('AE8')+M->AJK_RECURS)
		If lRet.And. AE8->AE8_UMAX <= 100 
			If !Empty(M->AJK_HORAF)    
				lRet := CheckAppointments(cHora,'', nRecAlt)
			Endif
		EndIf        	
	EndIf

	RestArea(aAreaAJK)
	RestArea(aArea)
Endif
Return lRet

/*/{Protheus.doc} RU44W70006VldHoraF
Validates finish time
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W70006VldHoraF() as logical
Local aArea        := GetArea() as Array
Local aAreaAJK     := AJK->(GetArea()) as Array
Local lRet         := .T. as logical
Local cHora      	:= M->AJK_HORAF as character
Local oModel 		:= FWModelActive() as object
Local nRecAlt		:= 0 as numeric
If !Empty(M->AJK_RECURS).And.!Empty(M->AJK_PROJET)

	AF8->(DbsetOrder(1)) 
	AF8->(MSSeek(xFilial()+M->AJK_PROJET))
		
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		nRecAlt   := AJK->(RecNo())
	EndIf

	M->AJK_HORAF := AdjusTimeToPrecision(cHora)
	oModel:LoadValue('AJKMASTER','AJK_HORAF', M->AJK_HORAF)
	If !Empty(M->AJK_DATA)   
		If lRet .And. !Empty(M->AJK_HORAI)
			If SubStr(cHora,1,2)+Substr(cHora,4,2) < Substr(M->AJK_HORAI,1,2)+Substr(M->AJK_HORAI,4,2)
				Help(NIL, NIL, STR0020, NIL, STR0022, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet := .F.
			EndIf    
		Endif
		dbSelectArea("AE8")
		dbSetOrder(1)
		MsSeek(xFilial('AE8')+M->AJK_RECURS)
		If AE8->AE8_UMAX <= 100 	
			If !Empty(M->AJK_HORAI)    
				lRet := CheckAppointments('zzzzz', cHora, nRecAlt)
			Endif
		EndIf
	EndIf

	RestArea(aAreaAJK)
	RestArea(aArea)
Endif
Return lRet

/*/{Protheus.doc} PMSVldSld
Checks available balance, to be called when tasks balance control is turned on PROJECT
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Static Function PMSVldSld(nQtdHrAnt as numeric) as logical
Local nApontTot    := 0 as numeric
Local nSaldoTot    := 0 as numeric
Local lRet         := .T. as logical

nSaldoTot := A700HrSld(M->AJK_PROJET ,M->AJK_REVISA ,M->AJK_TAREFA ,M->AJK_RECURS)
nApontTot := M->AJK_HQUANT - nQtdHrAnt	
If nApontTot > nSaldoTot
	Help(NIL, NIL, STR0020, NIL, STR0023 +" ["+Str(M->AJK_HQUANT,8,2)+">"+Str(nSaldoTot-nQtdHrAnt,8,2)+"]" , 1, 0, NIL, NIL, NIL, NIL, NIL,;
	{STR0024})
	lRet := .F.
EndIf	
Return lRet

/*/{Protheus.doc} CheckAppointments
Check if already exists an appointment/pre-appointment for the period informed
@type function
@version R14
@author bsobieski
@since 15/08/2024
@param cHoraI, character, Start time
@param cHoraF, character, Finish time
@param nRecAlt, numeric, Current record (to be disregarded when editing an appointment)
@return logical, True if there is no conflicting appointments/pre-appointmenr
/*/
Static Function CheckAppointments(cHoraI as character,cHoraF as character,nRecAlt as numeric) as logical
Local cQuery := "" as character
Local oStatement := FWPreparedStatement():New() as object
Local lRet := .T. as logical
Local cFinalQuery as character
Local cMessage as character
DEFAULT nRecAlt := 0
cQuery := "SELECT * FROM 
cQuery += " (SELECT AFU_HORAI HORAI, AFU_HORAF HORAF, 'AFU' AS ORIGIN FROM " + RetSqlName('AFU')
cQuery += "    WHERE 	AFU_FILIAL = ? " //AFU_FILIAL 1
cQuery += "    		AND AFU_CTRRVS = '1' "
cQuery += "    		AND AFU_RECURS = ? " //AFU_RECURS 2
cQuery += "    		AND AFU_DATA = ? " //AFU_DATA 3
cQuery += "    		AND D_E_L_E_T_ = '' "
cQuery += "  UNION ALL "
cQuery += "  SELECT AJK_HORAI HORAI, AJK_HORAF HORAF, 'AJK' AS ORIGIN FROM " + RetSqlName('AJK')
cQuery += "    WHERE 	AJK_FILIAL = ? " //ajk_filial 4
cQuery += "    		AND AJK_CTRRVS = '1' " //
cQuery += "    		AND AJK_SITUAC  <> '3' " //
cQuery += "    		AND AJK_RECURS = ? " //ajk_recurs 5
cQuery += "    		AND AJK_DATA = ? " //ajk_data 6
cQuery += "    		AND D_E_L_E_T_ = '' "
cQuery += "    		AND R_E_C_N_O_ <> ? " //NRECALT 7
cQuery += "    		) "
cQuery += "  AS JOINEDTABLE "
cQuery += "   WHERE    ( ? >= HORAI AND ? <  HORAF  ) "//CHORAI 8 CHORAI 9
cQuery += "    		OR ( ? >  HORAI AND ? <= HORAF ) "//CHORAF 10 CHORAF 11
cQuery += "    		OR "
cQuery += "   		(         ? < HORAI  "//CHORAI 12
cQuery += "    		 	  AND ? > HORAF "//CHORAF 13
cQuery += "    		) "

oStatement:SetQuery(cQuery)
oStatement:SetString(1,xFilial("AFU"))
oStatement:SetString(2,M->AJK_RECURS)
oStatement:SetString(3,Dtos(M->AJK_DATA))
oStatement:SetString(4,xFilial("AJK"))
oStatement:SetString(5,M->AJK_RECURS)
oStatement:SetString(6,Dtos(M->AJK_DATA))
oStatement:SetNumeric(7,nRecAlt)
oStatement:SetString(8,cHoraI)
oStatement:SetString(9,cHoraI)
oStatement:SetString(10,cHoraF)
oStatement:SetString(11,cHoraF)
oStatement:SetString(12,cHoraI)
oStatement:SetString(13,cHoraF)

cFinalQuery := oStatement:GetFixQuery()

cFinalQuery := ChangeQuery(cFinalQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cFinalQuery),GetNextAlias(),.F.,.T.)
If !Eof()
	lRet := .F.
	cMessage := "["+ORIGIN+": "+HORAI+"=>"+HORAF+"]"
	Help(NIL, NIL, STR0020, NIL, STR0025 + " " + cMessage, 1, 0, NIL, NIL, NIL, NIL, NIL,)
Endif
DbCloseArea()

Return lRet

/*/{Protheus.doc} AdjusTimeToPrecision
Adjusts time to precission defined by MV_PRECIS
@type function
@version  R14
@author bsobieski
@since 15/08/2024
@param cHora, character, Time to nbe adjusted
@return character, Time adjusted
/*/
Static Function AdjusTimeToPrecision(cHora as character) as character
Local nInterv      := 60 / SuperGetMV("MV_PRECISA") as numeric
Local x            := 0 as numeric

For x := 1 to GetMv("MV_PRECISA")
	Do  Case 
		Case x == 1
			 If Val(Substr(cHora,4,2)) < nInterv
				 If Val(Substr(cHora,4,2)) < nInterv/2 
				    cHora := Substr(cHora,1,3)+"00"
				    exit
				 Else
				    cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv))
				    exit
				 EndIf
		     EndIf

		Case x > 1 .AND. x < GetMv("MV_PRECISA")
			 If Val(Substr(cHora,4,2)) > (nInterv*(x-1)) .AND. Val(Substr(cHora,4,2)) < (nInterv*x)
			    If Val(Substr(cHora,4,2)) < ((nInterv*x)-(nInterv/2))
			       cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv*(x-1)))
			       exit
				Else
			       cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv*x))
			       exit
			 	EndIf
			 EndIf

		Case x == GetMv("MV_PRECISA")
			 If Val(Substr(cHora,4,2)) > (nInterv*(x-1)) .AND. Val(Substr(cHora,4,2)) < (nInterv*x)
			 	If Val(Substr(cHora,4,2)) < ((nInterv*x)-(nInterv/2)) .AND. Val(Substr(cHora,4,2)) > nInterv*(x-1)
			       cHora := Substr(cHora,1,3)+Alltrim(Str(nInterv*(x-1)))
			       exit
			    Else
			       cHora := Soma1(Substr(cHora,1,2))+":00"
			       exit
			    EndIf
			 EndIf
	End Case
Next X
Return cHora


/*/{Protheus.doc} RU44W70010
Checks the available hours balance for a defined task/resource
@type function
@version R14 
@author bsobieski
@since 15/08/2024
@param cProject, character, Project code
@param cRev, character, Version code
@param cTask, character, Task code
@param cResource, character, Resource code
@return numeric, Available balance
/*/
Function RU44W70010(cProject as character ,cRev as character ,cTask as character, cResource as character) as numeric

If cRev  == Nil
	AF8->(DbSetOrder(1))
	AF8->(MsSeek(xFilial()+cProject))
	cRev := AF8->AF8_REVISA
Endif
Return A700HrSld(cProject ,cRev ,cTask, cResource)
/*/{Protheus.doc} A700HrSld
Checks the available hours balance for a defined task/resource
@type function
@version R14 
@author bsobieski
@since 15/08/2024
@param cProject, character, Project code
@param cRev, character, Version code
@param cTask, character, Task code
@param cResource, character, Resource code
@return numeric, Available balance
/*/
Static Function A700HrSld(cProject as character ,cRev as character ,cTask as character, cResource as character) as numeric
Local aArea     := GetArea()
Local cQuery := "" as character
Local oStatement := FWPreparedStatement():New() as object
Local cFinalQuery as character

cQuery := "SELECT Sum(AFA_QUANT) as qty FROM "+ RetSqlName('AFA')
cQuery += "    WHERE 	AFA_FILIAL = ? " 
cQuery += "    		AND AFA_PROJET = ? " 
cQuery += "    		AND AFA_REVISA= ? " 
cQuery += "    		AND AFA_TAREFA = ? "
cQuery += "    		AND AFA_RECURS = ? " 
cQuery += "    		AND D_E_L_E_T_ = '' "
//Define a consulta e os parâmetros
oStatement:SetQuery(cQuery)
oStatement:SetString(1,xFilial("AFA"))
oStatement:SetString(2,cProject)
oStatement:SetString(3,cRev)
oStatement:SetString(4,cTask)
oStatement:SetString(5,cResource)

cFinalQuery := oStatement:GetFixQuery()
cFinalQuery := ChangeQuery(cFinalQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cFinalQuery),GetNextAlias(),.F.,.T.)
nTotal := qty
DbCloseArea()

oStatement:Destroy()
FREEOBJ(oStatement)
oStatement := FWPreparedStatement():New()
cQuery := "SELECT Sum(AFU_HQUANT) as qty FROM "+ RetSqlName('AFU')
cQuery += "    WHERE 	AFU_FILIAL = ? " 
cQuery += "    		AND AFU_PROJET = ? " 
cQuery += "    		AND AFU_REVISA= ? " 
cQuery += "    		AND AFU_TAREFA = ? "
cQuery += "    		AND AFU_RECURS = ? " 
cQuery += "    		AND D_E_L_E_T_ = '' "
//Define a consulta e os parâmetros
oStatement:SetQuery(cQuery)
oStatement:SetString(1,xFilial("AFU"))
oStatement:SetString(2,cProject)
oStatement:SetString(3,cRev)
oStatement:SetString(4,cTask)
oStatement:SetString(5,cResource)

cFinalQuery := oStatement:GetFixQuery()
cFinalQuery := ChangeQuery(cFinalQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cFinalQuery),GetNextAlias(),.F.,.T.)
nTotal -= qty
DbCloseArea()
	

oStatement:Destroy()
FREEOBJ(oStatement)
oStatement := FWPreparedStatement():New()
cQuery := "SELECT Sum(AJK_HQUANT) as qty FROM "+ RetSqlName('AJK')
cQuery += "    WHERE 	AJK_FILIAL = ? " 
cQuery += "    		AND AJK_PROJET = ? " 
cQuery += "    		AND AJK_REVISA= ? " 
cQuery += "    		AND AJK_TAREFA = ? "
cQuery += "    		AND AJK_RECURS = ? " 
cQuery += "    		AND AJK_SITUAC NOT IN ('2','3') " 
cQuery += "    		AND AJK_CTRRVS = '1' "
cQuery += "    		AND D_E_L_E_T_ = '' "
//Define a consulta e os parâmetros
oStatement:SetQuery(cQuery)
oStatement:SetString(1,xFilial("AJK"))
oStatement:SetString(2,cProject)
oStatement:SetString(3,cRev)
oStatement:SetString(4,cTask)
oStatement:SetString(5,cResource)

cFinalQuery := oStatement:GetFixQuery()
cFinalQuery := ChangeQuery(cFinalQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cFinalQuery),GetNextAlias(),.F.,.T.)
nTotal -= qty
DbCloseArea()
oStatement:Destroy()
FREEOBJ(oStatement)
	
RestArea(aArea)
	                                      
Return Iif( nTotal<0 , 0 , nTotal )
                   
//Merge Russia R14 
                   
