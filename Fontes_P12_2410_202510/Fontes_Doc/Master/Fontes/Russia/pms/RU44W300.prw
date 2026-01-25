#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU44W300.CH"

/*MAINTENANCE FOR PROJECTS Appointments (simple model to be used in web forms for VISUALIZATION)*/

PUBLISH MODEL REST NAME RU44W300 RESOURCE OBJECT oRU44W300

/*/{Protheus.doc} oRU44W300
description
@type class
@version  
@author
@since 03/07/2023
/*/
Class oRU44W300 From FwRestModel

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
	//Method SetAlias()
	Method Skip()

EndClass

/*/{Protheus.doc} oRU44W300::Activate
description
@type method
@version  
@author 
@since 03/07/2023
@return variant, return_description
/*/
Method Activate() Class oRU44W300

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
		If !MPUserHasAccess('RU44W300')
			_Super:setfilter("1=2")
			lRet := .F.
			self:SetStatusResponse(403, STR0001)
		Else
			// Set standard filter for model
			RU44X10002_FilterOnActivate(@self,'RU44W300')
			lRet := .T.
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} oRU44W300::DeActivate
description
@type method
@version  
@author
@since 03/07/2023
@return variant, return_description
/*/
Method DeActivate() Class oRU44W300

	If !(self:nStatus == Nil)
		self:SetStatusResponse({self:nStatus, EncodeUTF8(self:cStatus)})
	EndIf

Return _Super:DeActivate()

/*/{Protheus.doc} oRU44W300::Seek
description
@type method
@version  
@author
@since 03/07/2023
@param cPK, character, param_description
@return variant, return_description
/*/
Method Seek(cPK) Class oRU44W300

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
Method Total() Class oRU44W300

	Local nTotal := 0

	nTotal := RU44X10003_Total(@self)

Return nTotal


Method GetData() Class oRU44W300
	Local cRet := self:cResponse
Return cRet

Method Skip() Class oRU44W300
Return .F.

Method StartGetFormat(nTotal, nCount, nStartIndex) Class oRU44W300
	
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
Method EndGetFormat() Class oRU44W300
	
	Local cRet := ""
	
Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveData
Method returns true if data was saved successfully
@return lRet   
@author 
@since 14/05/2024
@version P14
/*/
//-------------------------------------------------------------------
Method SaveData(cPk,cData,cError) Class oRU44W300
    Local lRet      := .T.
    Default cData   := ""

    lRet := RU44X10004_SaveData(self, cPk,cData,@cError)

Return lRet



Function RU44W300()
Local cFiltraAFU := 'AFU_FILIAL == "'+xFilial("AFU")+'" .AND. AFU_CTRRVS == "1"'
Local oBrowse
If AMIIn(44)
	PRIVATE aRotina		:= MenuDef()
	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	// Definição da tabela do Browse
	oBrowse:SetAlias('AFU')

	// Definição de filtro
	oBrowse:SetFilterDefault( cFiltraAFU )

	// Titulo da Browse
	//oBrowse:SetDescription(cCadastro)
	// Opcionalmente pode ser desligado a exibição dos detalhes
	oBrowse:DisableDetails()
	// Ativação da Classe
	oBrowse:Activate()
EndIf
Return 


Static Function MenuDef() 
Local aRotina := {}

aAdd( aRotina, { STR0002   , 'VIEWDEF.RU44W300', 0, 2, 0, NIL } )
aAdd( aRotina, { STR0003   , 'VIEWDEF.RU44W300', 0, 3, 0, NIL } )
aAdd( aRotina, { STR0004   , 'VIEWDEF.RU44W300', 0, 4, 0, NIL } )
aAdd( aRotina, { STR0013   , 'VIEWDEF.RU44W300', 0, 5, 0, NIL } )
Return aRotina

Static Function ModelDef() 
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruAFU
Local oModel // Modelo de dados que ser? constru?do
Local bCommit   := {|oModel| RU44W300Commit(oModel) }
//Local bFieldPre	:= {|oModel, cModelId, cAction, cId, xValue| FieldPreVld(oModel, cModelId, cAction, cId, xValue)}
Local bPre		:= {|oModel| RU44W300ActivatePreValidation(oModel)}
Local bPost		:= {|oModel| RU44W300PosValidation(oModel)}
oStruAFU := FWFormStruct( 1, 'AFU'  )
oModel := MPFormModel():New('RU44W300',/*bFieldPre*/,bPost,bCommit)
oModel:SetVldActivate(bPre)

SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AF9_DESCRI'))
oStruAFU:AddField(STR0005, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
					{|oModel| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT,'',Posicione('AF9',1,xFilial('AF9')+ AFU->AFU_PROJET + AFU->AFU_REVISA + AFU->AFU_TAREFA, 'AF9_DESCRI'))}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)
SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AE8_DESCRI'))
oStruAFU:AddField(STR0006, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|oModel| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT,'', Posicione('AE8',1,xFilial('AE8')+ AFU->AFU_RECURS, 'AE8_DESCRI'))}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)

SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AE8_EQUIP'))
oStruAFU:AddField(STR0008, ''/*<cTooltip >*/, Alltrim(SX3->X3_CAMPO), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|oModel| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT,'', Posicione('AE8',1,xFilial('AE8')+ AFU->AFU_RECURS, 'AE8_EQUIP'))}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)
SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AED_DESCRI'))
oStruAFU:AddField(STR0009, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|| RU44X10006_GetTeamName('AFU')}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)

SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AF8_DESCRI'))
oStruAFU:AddField(STR0007, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|oModel| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT,'',Posicione('AF8',1,xFilial('AF8')+ AFU->AFU_PROJET, 'AF8_DESCRI'))}, ;
 					.F. /*<lKey >*/,;
  					.T. /*[ lNoUpd ]*/,;
  					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)

If !oStruAFU:HasField('AFU_CTRRVS')
	SX3->(DbSetOrder(2))
	SX3->(DBSEEK( 'AFU_CTRRVS'))
	oStruAFU:AddField(X3Titulo(), ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
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

If !oStruAFU:HasField('AFU_CODMEM')
	SX3->(DbSetOrder(2))
	SX3->(DBSEEK( 'AFU_CODMEM'))
	oStruAFU:AddField(X3Titulo(), ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
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
      "AFU_RECURS" ,; // Campo Dominio
      "AE8_DESCRI" ,; // Campo de Contradominio
      "Posicione('AE8',1,xFilial('AE8')+ M->AFU_RECURS, 'AE8_DESCRI')",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])

aAuxTrg := FwStruTrigger(;
      "AFU_RECURS" ,; // Campo Dominio
      "AE8_EQUIP" ,; // Campo de Contradominio
      "Posicione('AE8',1,xFilial('AE8')+ M->AFU_RECURS, 'AE8_EQUIP')",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AFU_RECURS)"  ,; // Condicao para execucao do gatilho
      "02" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AFU_RECURS" ,; // Campo Dominio
      "AED_DESCRI" ,; // Campo de Contradominio
      "Posicione('AED',1,xFilial('AED')+ AE8->AE8_EQUIP, 'AED_DESCRI')",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AE8" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AE8')+M->AFU_RECURS" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AFU_RECURS)" ,; // Condicao para execucao do gatilho
      "03" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AFU_RECURS" ,; // Campo Dominio
      "AFU_HQUANT" ,; // Campo de Contradominio
      "PmsHrsItvl(M->AFU_DATA,M->AFU_HORAI,M->AFU_DATA,M->AFU_HORAF,AE8->AE8_CALEND,M->AFU_PROJET,M->AFU_RECURS,,.T.)",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AF9" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AF9')+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AFU_TAREFA) .And.!Empty(M->AFU_DATA) .And. !Empty(M->AFU_HORAI).And. !Empty(M->AFU_HORAF).And. !Empty(M->AFU_PROJET).And.!Empty(M->AFU_RECURS)" ,; // Condicao para execucao do gatilho
      "04" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])


aAuxTrg := FwStruTrigger(;
      "AFU_RECURS" ,; // Campo Dominio
      "AFU_COD" ,; // Campo de Contradominio
      "AE8->AE8_PRDREA",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AE8" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AE8')+ M->AFU_RECURS" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "05" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])


aAuxTrg := FwStruTrigger(;
      "AFU_DATA" ,; // Campo Dominio
      "AFU_HQUANT" ,; // Campo de Contradominio
      "PmsHrsItvl(M->AFU_DATA,M->AFU_HORAI,M->AFU_DATA,M->AFU_HORAF,AE8->AE8_CALEND,M->AFU_PROJET,M->AFU_RECURS,,.T.)",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AF9" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AF9')+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AFU_TAREFA) .And.!Empty(M->AFU_DATA) .And. !Empty(M->AFU_HORAI).And. !Empty(M->AFU_HORAF).And. !Empty(M->AFU_PROJET).And.!Empty(M->AFU_RECURS)" ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AFU_HORAI" ,; // Campo Dominio
      "AFU_HQUANT" ,; // Campo de Contradominio
      "PmsHrsItvl(M->AFU_DATA,M->AFU_HORAI,M->AFU_DATA,M->AFU_HORAF,AE8->AE8_CALEND,M->AFU_PROJET,M->AFU_RECURS,,.T.)",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AF9" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AF9')+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AFU_TAREFA) .And.!Empty(M->AFU_DATA) .And. !Empty(M->AFU_HORAI).And. !Empty(M->AFU_HORAF).And. !Empty(M->AFU_PROJET).And.!Empty(M->AFU_RECURS)" ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])


aAuxTrg := FwStruTrigger(;
      "AFU_HORAF" ,; // Campo Dominio
      "AFU_HQUANT" ,; // Campo de Contradominio
      "PmsHrsItvl(M->AFU_DATA,M->AFU_HORAI,M->AFU_DATA,M->AFU_HORAF,AE8->AE8_CALEND,M->AFU_PROJET,M->AFU_RECURS,,.T.)",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AF9" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AF9')+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AFU_TAREFA) .And.!Empty(M->AFU_DATA) .And. !Empty(M->AFU_HORAI).And. !Empty(M->AFU_HORAF).And. !Empty(M->AFU_PROJET).And.!Empty(M->AFU_RECURS)" ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AFU_PROJET" ,; // Campo Dominio
      "AFU_HQUANT" ,; // Campo de Contradominio
      "PmsHrsItvl(M->AFU_DATA,M->AFU_HORAI,M->AFU_DATA,M->AFU_HORAF,AE8->AE8_CALEND,M->AFU_PROJET,M->AFU_RECURS,,.T.)",; // Regra de Preenchimento
      .T. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "AF9" ,; // Alias da tabela a ser posicionada
      1 ,; // Ordem da tabela a ser posicionada
      "xFilial('AF9')+M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA" ,; // Chave de busca da tabela a ser posicionada
      "!Empty(M->AFU_TAREFA) .And.!Empty(M->AFU_DATA) .And. !Empty(M->AFU_HORAI).And. !Empty(M->AFU_HORAF).And. !Empty(M->AFU_PROJET).And.!Empty(M->AFU_RECURS)" ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   

oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])

aAuxTrg := FwStruTrigger(;
      "AFU_HQUANT" ,; // Campo Dominio
      "AFU_CUSTO1" ,; // Campo de Contradominio
      "RU44W30010_Pms320Cust(M->AFU_HQUANT)",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])

aAuxTrg := FwStruTrigger(;
      "AFU_HQUANT" ,; // Campo Dominio
      "AFU_CUSTO2" ,; // Campo de Contradominio
      "xMoeda(M->AFU_CUSTO1	,1,2,M->AFU_DATA)",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "02" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AFU_HQUANT" ,; // Campo Dominio
      "AFU_CUSTO3" ,; // Campo de Contradominio
      "xMoeda(M->AFU_CUSTO1	,1,3,M->AFU_DATA)",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "03" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AFU_HQUANT" ,; // Campo Dominio
      "AFU_CUSTO4" ,; // Campo de Contradominio
      "xMoeda(M->AFU_CUSTO1	,1,4,M->AFU_DATA)",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "04" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
aAuxTrg := FwStruTrigger(;
      "AFU_HQUANT" ,; // Campo Dominio
      "AFU_CUSTO5" ,; // Campo de Contradominio
      "xMoeda(M->AFU_CUSTO1	,1,5,M->AFU_DATA)",; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      NIL ,; // Condicao para execucao do gatilho
      "05" ) // Sequencia do gatilho (usado para identificacao no caso de erro)   
oStruAFU:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])



SX3->(DbSetOrder(2))
SX3->(DbSeek('AFU_TAREFA'))
//Substitute standard validations
oStruAFU:SetProperty("AFU_TAREFA", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'RU44W30004VldTask()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )
oStruAFU:SetProperty("AFU_TAREFA", MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, 'PmsSetF3("AF9",2,M->AFU_PROJET)'   ) )

SX3->(DbSeek('AFU_DATA'))
oStruAFU:SetProperty("AFU_DATA", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'RU44W30008VldData()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )

//SX3->(DbSeek('AFU_RECURS'))
//oStruAFU:SetProperty("AFU_RECURS", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'RU44W30007VldResource()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )
SX3->(DbSeek('AFU_HORAI'))
oStruAFU:SetProperty("AFU_HORAI", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'AtVldHora(M->AFU_HORAI).and.RU44W30005VldHoraI()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )
SX3->(DbSeek('AFU_HORAF'))
oStruAFU:SetProperty("AFU_HORAF", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'AtVldHora(M->AFU_HORAF).and.RU44W30006VldHoraF()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )
SX3->(DbSeek('AFU_HQUANT'))
oStruAFU:SetProperty("AFU_HQUANT", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'POSITIVO()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )


FWMemoVirtual( oStruAFU,{ { 'AFU_CODMEM' , 'AFU_OBS' } } )

oModel:AddFields( 'AFUMASTER', /*cOwner*/, oStruAFU)

oModel:SetPrimaryKey({'AFU_CTRRVS','AFU_PROJET','AFU_REVISA','AFU_TAREFA','AFU_RECURS','AFU_DATA','AFU_HORAI'})
Return oModel


/*/{Protheus.doc} ViewDef
View definition for MVC Model
@type function
@version  R14
@author bsobieski
@since 19/08/2024
@return Object, View
/*/
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel := FWLoadModel( 'RU44W300' )
// Cria a estrutura a ser usada na View
Local oStruAFU := FWFormStruct( 2, 'AFU' )
// Interface de visualiza??o constru?da
Local oView

oStruAFU:SetNoFolder()
// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados ser? utilizado na View
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formul?rio
// (antiga Enchoice)
oView:AddField( 'VIEW_AFU', oStruAFU, 'AFUMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'HEADER' , 100 )
// Relaciona o identificador (ID) da View com o "box" para exibi??o
oView:SetOwnerView( 'VIEW_AFU', 'HEADER' )


// Retorna o objeto de View criado
Return oView



/*/{Protheus.doc} RU44W300ActivatePreValidation
Validates if the requested operation model can be executed for this model.
This validation is independent from data sent to the model, it is used to check usually permissions and status of record
@type function
@version  1.0
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if prevalidation succeeed
/*/
Static Function RU44W300ActivatePreValidation(oModel, cModelId, cAction, cId, xValue)
Local lRet := .T. as logical
Local lInsert := oModel:GetOperation() == MODEL_OPERATION_INSERT as logical
Local lUpdate := oModel:GetOperation() == MODEL_OPERATION_UPDATE as logical
Local lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE as logical
Local lView   := !(lInsert .Or. lDelete .Or. lUpdate) as logical
		 
If !(lView).And. !lInsert .And. !Empty(AFU->AFU_PROJET) 
	If !PmsVldFase("AF8",AFU->AFU_PROJET, "86")
		lRet := .F.
	EndIf
EndIf 
                   
// verificar data do ultimo fechamento do Projeto
If lRet .And. (lUpdate .Or. lDelete)
	AF8->(dbSetOrder(1))
	If AF8->(MsSeek(xFilial()+ AFU->AFU_PROJET))
		If !Empty(AF8->AF8_ULMES) .and. (AF8->AF8_ULMES >= AFU->AFU_DATA)
			Help(NIL, NIL, STR0010, NIL, i18n(STR0011, {DTOC(AF8->AF8_ULMES)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet :=.F.
		EndIf
	EndIf
EndIf

If lRet .AND. !lInsert
	Do Case
		Case lView //.And. IsInCallStack('RU44W300')
			If !PmsChkUser(AFU->AFU_PROJET, AFU->AFU_TAREFA, NIL, "", 2, "RECURS", AFU->AFU_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{AFU->AFU_PROJET,AFU->AFU_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf
		Case lUpdate
			//At Pre-Validation still do not know if this is an approval or an edit, so validate both
			If !Empty(AFU->AFU_PREREC)
				Help(NIL, NIL, STR0012, NIL, STR0014, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf			
			If !PmsChkUser(AFU->AFU_PROJET, AFU->AFU_TAREFA, NIL, "", 3, "RECURS", AFU->AFU_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{AFU->AFU_PROJET,AFU->AFU_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf			
		Case lDelete
			If !Empty(AFU->AFU_PREREC) .And. !IsInCallStack('RU44W710COMMIT')
				Help(NIL, NIL, STR0012, NIL, STR0015, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf			
			If !PmsChkUser(AFU->AFU_PROJET, AFU->AFU_TAREFA, NIL, "", 4, "RECURS", AFU->AFU_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{AFU->AFU_PROJET,AFU->AFU_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf
	EndCase
EndIf
Return lRet
/*/{Protheus.doc} RU44W300Posvalidation
Validates the data of the model as a whole, before trying to commit the model
@type function
@version  1.0
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if validation succeeed
/*/
Static Function RU44W300Posvalidation(oModel)
Local lRet := .T. as logical
Local lInsert := oModel:GetOperation() == MODEL_OPERATION_INSERT as logical
Local lUpdate := oModel:GetOperation() == MODEL_OPERATION_UPDATE as logical
Local lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE as logical
If lUpdate
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas verifica esta condição caso o tipo de recurso (AE8_TPREAL) esteja configurado como (1=Custo Medio/FIFO)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. MVUlmes() >= M->AFU_DATA .AND. Posicione("AE8",1,xFilial("AE8")+M->AFU_RECURS,"AE8_TPREAL")   == "1" // tipo apontamento 1=Custo Medio/FIFO
		Help ( " ", 1, "FECHTO" )
		lRet := .F.
	EndIf	
	cEDTpai := PMSReadValue("AF9", 1, ;
							xFilial("AF9") + M->AFU_PROJET + M->AFU_REVISA + M->AFU_TAREFA, ;
							"AF9_EDTPAI", "")
	//Validate phase only if project code changed:
	If lRet .And. AFU->AFU_PROJET <> oModel:GetValue("AFUMASTER", "AFU_PROJET")

		If lRet .And.;
			!PmsChkUser(oModel:GetValue("AFUMASTER", "AFU_PROJET"), oModel:GetValue("AFUMASTER", "AFU_TAREFA"), NIL, "", 3, "RECURS", oModel:GetValue("AFUMASTER", "AFU_REVISA"), /*cUser*/, .F.)			
			Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{oModel:GetValue("AFUMASTER", "AFU_PROJET"),oModel:GetValue("AFUMASTER", "AFU_TAREFA")}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet := .F.
		Endif
		If lRet .And. (oModel:GetValue("AFUMASTER", "AFU_PROJET") <> AFU->AFU_PROJET .or. oModel:GetValue("AFUMASTER", "AFU_TAREFA") <> AFU->AFU_TAREFA) .And. ;
			(!PmsChkUser(AFU->AFU_PROJET, AFU->AFU_TAREFA, NIL, "", 3, "RECURS", AFU->AFU_REVISA, /*cUser*/, .F.) .And. ;
			!PmsChkUser(oModel:GetValue("AFUMASTER", "AFU_PROJET"),oModel:GetValue("AFUMASTER", "AFU_TAREFA"),,cEDTPai,3,"RECURS",oModel:GetValue("AFUMASTER", "AFU_REVISA"),))
			Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{AJK->AJK_PROJET,AJK->AJK_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet := .F.
		Endif
	EndIf 
	If lRet .And. SuperGetMV("MV_PMSVRAL", .F., 0) <> 0
		If !IsAllocatedRes(M->AFU_PROJET, M->AFU_REVISA, M->AFU_TAREFA, M->AFU_RECURS)
			Help(NIL, NIL, STR0012, NIL, STR0016, 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet := .F.
		EndIf
	EndIf
 ElseIf lInsert
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas verifica esta condição caso o tipo de recurso (AE8_TPREAL) esteja configurado como (1=Custo Medio/FIFO)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. MVUlmes() >= M->AFU_DATA .AND. Posicione("AE8",1,xFilial("AE8")+M->AFU_RECURS,"AE8_TPREAL")   == "1" // tipo apontamento 1=Custo Medio/FIFO
		Help ( " ", 1, "FECHTO" )
		lRet := .F.
	EndIf	

	If lRet .And. !PmsVldFase("AF8", oModel:GetValue("AFUMASTER", "AFU_PROJET"), "86")
		lRet := .F.
	EndIf 
	AF8->(dbSetOrder(1))
	If AF8->(MsSeek(xFilial()+oModel:GetValue("AFUMASTER", "AFU_PROJET")))
		If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(oModel:GetValue("AFUMASTER", "AFU_DATA")))
			Help(NIL, NIL, STR0010, NIL, i18n(STR0011, {DTOC(AF8->AF8_ULMES)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet :=.F.
		EndIf
	EndIf
	If lRet .And. ;
		(!PmsChkUser(oModel:GetValue("AFUMASTER", "AFU_PROJET"), oModel:GetValue("AFUMASTER", "AFU_TAREFA"), NIL, "", 3, "RECURS", oModel:GetValue("AFUMASTER", "AFU_REVISA"), /*cUser*/, .F.) .And.;
		!PmsChkUser(oModel:GetValue("AFUMASTER", "AFU_PROJET"),oModel:GetValue("AFUMASTER", "AFU_TAREFA"),,cEDTPai,3,"RECURS",oModel:GetValue("AFUMASTER", "AFU_REVISA"),))
		Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{oModel:GetValue("AFUMASTER", "AFU_PROJET"),oModel:GetValue("AFUMASTER", "AFU_TAREFA")}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
		lRet := .F.
	Endif
	If lRet .And. SuperGetMV("MV_PMSVRAL", .F., 0) <> 0
		If !IsAllocatedRes(M->AFU_PROJET, M->AFU_REVISA, M->AFU_TAREFA, M->AFU_RECURS)
			Help(NIL, NIL, STR0012, NIL, STR0016, 1, 0, NIL, NIL, NIL, NIL, NIL,)
			lRet := .F.
		EndIf
	EndIf

ElseIf lDelete
	If !Empty(AFU->AFU_PREREC).And. !IsInCallStack('RU44W710COMMIT')
		Help(NIL, NIL, STR0012, NIL, STR0015, 1, 0, NIL, NIL, NIL, NIL, NIL,)
		lRet	:=.F.
	EndIf			
	If !PmsChkUser(AFU->AFU_PROJET, AFU->AFU_TAREFA, NIL, "", 4, "RECURS", AFU->AFU_REVISA, /*cUser*/, .F.)
		Help(NIL, NIL, STR0012, NIL, i18n(STR0019,{AFU->AFU_PROJET,AFU->AFU_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
		lRet	:=.F.
	EndIf
EndIf

If lRet .And. ( lInsert .Or. lUpdate)
	//Validate start and end time on POST, because they depend on task and resource, and because situation may have changed since it was validated.
	lRet := RU44W30009VldInterval(oModel)
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
/*/
Function responsible for COMMIT of the model
@type function
@version  1.0
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if succeded
/*/
Static Function RU44W300Commit(oModel)
	Local lRet 		:= .T. 	as logical
    DbSelectArea("AFU")
    If oModel:GetOperation() == MODEL_OPERATION_INSERT 
		Begin transaction
			Pms320Grava(Nil,.F.)
		End Transaction
	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
		Begin Transaction
			Pms320Grava(AFU->(Recno()),.F.)
		End Transaction
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE		
		Begin Transaction	
			Pms320Grava(AFU->(Recno()),.T.)
		End Transaction
	Endif
Return lRet
/*/{Protheus.doc} RU44W30004VldTask
Validates task typed
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W30004VldTask() as logical
Local lRet := .T. as logical
If !Empty(M->AFU_TAREFA) .And. !Empty(M->AFU_PROJET)
	lRet := ExistCpo("AF9",M->AFU_PROJET+M->AFU_REVISA+M->AFU_TAREFA,1)
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
Function RU44W30009VldInterval(oModel as Object) as logical
Local lBlqApt		:= .F. as logical
Local nRecAlt 		:= 0 as numeric
Local lRet 			:= .T. as logical
Local nQtdHrAnt		:= 0 as numeric
If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	nQtdHrAnt   := AFU->AFU_HQUANT
	nRecAlt 	:= AFU->(RecNo())
EndIf

AF8->(DbsetOrder(1)) 
AF8->(MSSeek(xFilial()+M->AFU_PROJET))
lBlqApt := AF8->AF8_PAR001=="1"

dbSelectArea("AE8")
dbSetOrder(1)
MsSeek(xFilial('AE8')+M->AFU_RECURS)
If lRet.And. AE8->AE8_UMAX <= 100 
	lRet := CheckAppointments(M->AFU_HORAI,M->AFU_HORAF, nRecAlt)
EndIf        	
If lRet
	If lBlqApt
		lRet := PMSVldSld(nQtdHrAnt) 
	EndIf
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

nSaldoTot := A300HrSld(M->AFU_PROJET, M->AFU_REVISA, M->AFU_TAREFA, M->AFU_RECURS )
nApontTot := M->AFU_HQUANT - nQtdHrAnt	
If nApontTot > nSaldoTot
	Help(NIL, NIL, STR0020, NIL, STR0023 +" ["+Str(M->AFU_HQUANT,8,2)+">"+Str(nSaldoTot-nQtdHrAnt,8,2)+"]" , 1, 0, NIL, NIL, NIL, NIL, NIL,;
	{STR0024})
	lRet := .F.
EndIf	
Return lRet
/*/{Protheus.doc} RU44W30008VldData
Validates date typed
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W30008VldData() as logical
Local lRet := .T. as logical
Local oModel 	   := FWModelActive() as object
AF8->(dbSetOrder(1))
If AF8->(MsSeek(xFilial()+oModel:GetValue("AFUMASTER", "AFU_PROJET")))
	If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(oModel:GetValue("AFUMASTER", "AFU_DATA")))
		Help(NIL, NIL, STR0010, NIL, i18n(STR0011, {DTOC(AF8->AF8_ULMES)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
		lRet :=.F.
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} RU44W30005VldHoraI
Validates starting time
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W30005VldHoraI() as logical
Local aArea        := GetArea() as Array
Local aAreaAFU     := AFU->(GetArea()) as Array
Local lRet         := .T. as logical
Local cHora        := M->AFU_HORAI  as character
Local lBlqApt		:= .F. as logical
Local nRecAlt 		:= 0 as numeric
Local oModel 	    := FWModelActive() as object

If !Empty(M->AFU_RECURS).And.!Empty(M->AFU_PROJET)
	AF8->(DbsetOrder(1)) 
	AF8->(MSSeek(xFilial()+M->AFU_PROJET))
	lBlqApt := AF8->AF8_PAR001=="1"

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		nRecAlt   := AFU->(RecNo())
	EndIf

	M->AFU_HORAI := AdjusTimeToPrecision(cHora)
	oModel:LoadValue('AFUMASTER','AFU_HORAI', M->AFU_HORAI )
	If  !Empty(M->AFU_DATA)
		If lRet .And. !Empty(M->AFU_HORAF)
			If SubStr(cHora,1,2)+Substr(cHora,4,2) > Substr(M->AFU_HORAF,1,2)+Substr(M->AFU_HORAF,4,2)
				Help(NIL, NIL, STR0020, NIL, STR0021, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet := .F.
			EndIf
		EndIf

		dbSelectArea("AE8")
		dbSetOrder(1)
		MsSeek(xFilial('AE8')+M->AFU_RECURS)
		If lRet.And. AE8->AE8_UMAX <= 100 
			If !Empty(M->AFU_HORAF)    
				lRet := CheckAppointments(cHora,'', nRecAlt)
			Endif
		EndIf        	
	EndIf

	RestArea(aAreaAFU)
	RestArea(aArea)
Endif
Return lRet

/*/{Protheus.doc} RU44W30006VldHoraF
Validates finish time
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W30006VldHoraF() as logical
Local aArea        := GetArea() as Array
Local aAreaAFU     := AFU->(GetArea()) as Array
Local lRet         := .T. as logical
Local cHora      	:= M->AFU_HORAF as character
Local oModel 		:= FWModelActive() as object
Local nRecAlt		:= 0 as numeric
If !Empty(M->AFU_RECURS).And.!Empty(M->AFU_PROJET)

	AF8->(DbsetOrder(1)) 
	AF8->(MSSeek(xFilial()+M->AFU_PROJET))
		
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		nRecAlt   := AFU->(RecNo())
	EndIf

	M->AFU_HORAF := AdjusTimeToPrecision(cHora)
	oModel:LoadValue('AFUMASTER','AFU_HORAF', M->AFU_HORAF)
	If !Empty(M->AFU_DATA)   
		If lRet .And. !Empty(M->AFU_HORAI)
			If SubStr(cHora,1,2)+Substr(cHora,4,2) < Substr(M->AFU_HORAI,1,2)+Substr(M->AFU_HORAI,4,2)
				Help(NIL, NIL, STR0020, NIL, STR0022, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet := .F.
			EndIf    
		Endif
		dbSelectArea("AE8")
		dbSetOrder(1)
		MsSeek(xFilial('AE8')+M->AFU_RECURS)
		If AE8->AE8_UMAX <= 100 	
			If !Empty(M->AFU_HORAI)    
				lRet := CheckAppointments('zzzzz', cHora, nRecAlt)
			Endif
		EndIf
	EndIf

	RestArea(aAreaAFU)
	RestArea(aArea)
Endif
Return lRet


/*/{Protheus.doc} CheckAppointments
Check if already exists an appointment for the period informed
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
cQuery += " SELECT AFU_HORAI , AFU_HORAF  FROM " + RetSqlName('AFU')
cQuery += "    WHERE 	AFU_FILIAL = ? " //AFU_FILIAL 1
cQuery += "    		AND AFU_CTRRVS = '1' "
cQuery += "    		AND AFU_RECURS = ? " //AFU_RECURS 2
cQuery += "    		AND AFU_DATA = ? " //AFU_DATA 3
cQuery += "         AND (     (  ? >= AFU_HORAI AND ? < AFU_HORAF )  "//CHORAI 4 CHORAI 5
cQuery += "    		      OR  (  ? >  AFU_HORAI AND ? <= AFU_HORAF )  "//CHORAF 6 CHORAF 7
cQuery += "    		      OR "
cQuery += "   		      (         ? < AFU_HORAI  "//CHORAI 8
cQuery += "    		 	      AND ? > AFU_HORAF "//CHORAF 9
cQuery += "    		      )  "
cQuery += "    		     ) "
cQuery += "    		AND R_E_C_N_O_ <> ? " //NRECALT 10
cQuery += "    		AND D_E_L_E_T_ = '' "

oStatement:SetQuery(cQuery)
oStatement:SetString(1,xFilial("AFU"))
oStatement:SetString(2,M->AFU_RECURS)
oStatement:SetString(3,Dtos(M->AFU_DATA))
oStatement:SetString(4,cHoraI)
oStatement:SetString(5,cHoraI)
oStatement:SetString(6,cHoraF)
oStatement:SetString(7,cHoraF)
oStatement:SetString(8,cHoraI)
oStatement:SetString(9,cHoraF)
oStatement:SetNumeric(10,nRecAlt)

cFinalQuery := oStatement:GetFixQuery()

cFinalQuery := ChangeQuery(cFinalQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cFinalQuery),GetNextAlias(),.F.,.T.)
If !Eof()
	lRet := .F.
	cMessage := "["+AFU_HORAI+"=>"+AFU_HORAF+"]"
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
/*/{Protheus.doc} RU44W30010_Pms320Cust
Get cost for the task in case it is setup as fixed cost for the resource
@type function
@version  R14
@author bsobieski
@since 19/08/2024
@param nQuant, numeric, Hours quantity
@return numeric, Total ost for the task
/*/
Function RU44W30010_Pms320Cust(nQuant)
Local aArea		:= GetArea()
Local aAreaAE8	:= AE8->(GetArea())
Local nCost := 0
//Local oModel 		:= FWModelActive() as object

dbSelectArea("AE8")
dbSetOrder(1)
MsSeek(xFilial()+M->AFU_RECURS)	
If AE8->AE8_TPREAL $"1235"
	nCost := AE8->AE8_CUSFIX*nQuant
EndIf
	
RestArea(aAreaAE8)
RestArea(aArea)

Return nCost

/*/{Protheus.doc} A300HrSld
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
Static Function A300HrSld(cProject as character ,cRev as character ,cTask as character, cResource as character) as numeric
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
                   
