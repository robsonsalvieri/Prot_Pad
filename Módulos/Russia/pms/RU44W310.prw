#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU44W310.CH"
STATIC __lRejec 	:= .F.       	///	VARIAVEL PRECISA ESTAR DISPONÍVEL NA PMS311GRAVA() QUANDO HÁ INTEGRAÇÃO QNC (MV_QTMKPMS) 3 ou 4.
STATIC __cQNCRej	:= ""
STATIC __cQNCDEP	:= ""
STATIC __cNEWQUO	:= ""

/*MAINTENANCE FOR PROJECTS confirmations*/


PUBLISH MODEL REST NAME RU44W310 RESOURCE OBJECT oRU44W310

/*/{Protheus.doc} oRU44W310
description
@type class
@version  
@author
@since 03/07/2023
/*/
Class oRU44W310 From FwRestModel

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
	Method SaveData()

EndClass

/*/{Protheus.doc} oRU44W310::Activate
description
@type method
@version  
@author 
@since 03/07/2023
@return variant, return_description
/*/
Method Activate() Class oRU44W310

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
		If !MPUserHasAccess('RU44W310')
			_Super:setfilter("1=2")
			lRet := .F.
			self:SetStatusResponse(403, STR0001)
		Else
			// Set standard filter for model
			RU44X10002_FilterOnActivate(@self,'RU44W310')
			lRet := .T.
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} oRU44W310::DeActivate
description
@type method
@version  
@author
@since 03/07/2023
@return variant, return_description
/*/
Method DeActivate() Class oRU44W310

	If !(self:nStatus == Nil)
		self:SetStatusResponse({self:nStatus, EncodeUTF8(self:cStatus)})
	EndIf

Return _Super:DeActivate()

/*/{Protheus.doc} oRU44W310::Seek
description
@type method
@version  
@author
@since 03/07/2023
@param cPK, character, param_description
@return variant, return_description
/*/
Method Seek(cPK) Class oRU44W310

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
Method Total() Class oRU44W310

	Local nTotal := 0

	nTotal := RU44X10003_Total(@self)

Return nTotal


Method GetData() Class oRU44W310
	Local cRet := self:cResponse
Return cRet

Method Skip() Class oRU44W310
Return .F.

Method StartGetFormat(nTotal, nCount, nStartIndex) Class oRU44W310

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
Method EndGetFormat() Class oRU44W310

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
Method SaveData(cPk,cData,cError) Class oRU44W310
    Local lRet      := .T.
    Default cData   := ""

    lRet := RU44X10004_SaveData(self, cPk,cData,@cError)

Return lRet


/*/{Protheus.doc} RU44W710
Main browse for pre-annotations approval
@type function
@version  R14
@author bsobieski
@since 23/08/2024
/*/
Function RU44W310()
	Local oBrowse
	If AMIIn(44)
		PRIVATE aRotina		:= MenuDef()
		SET KEY VK_F4 TO
		SET KEY VK_F5 TO
		SX1->(DbSetOrder(1))
		If SX1->(MSSEEK('RU44W310'))
			SetKey( VK_F12, { || Pergunte("RU44W310",.T.) })
			Pergunte('RU44W310',.T.)
		Endif
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('AFF')

//	oBrowse:SetFilterDefault( cFiltraAFF )

		oBrowse:SetDescription(STR0040)
		oBrowse:DisableDetails()
		oBrowse:Activate()
		SET KEY VK_F12 TO

	EndIf
Return
Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { STR0002   , 'VIEWDEF.RU44W310', 0, 2, 0, NIL } )
	aAdd( aRotina, { STR0003   , 'VIEWDEF.RU44W310', 0, 3, 0, NIL } )
	aAdd( aRotina, { STR0004   , 'VIEWDEF.RU44W310', 0, 4, 0, NIL } )
	aAdd( aRotina, { STR0013   , 'VIEWDEF.RU44W310', 0, 5, 0, NIL } )
Return aRotina

Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruAFF
	Local oModel // Modelo de dados que ser? constru?do
	Local bCommit   := {|oModel| RU44W310Commit(oModel) }
	Local bPre		:= {|oModel| RU44W310ActivatePreValidation(oModel)}
	Local bPost		:= {|oModel| RU44W310PosValidation(oModel)}
	SX1->(DbSetOrder(1))
	If SX1->(MSSEEK('RU44W310'))
		Pergunte('RU44W310',.F.)
	Else
		mv_par01 := 1
		mv_par02 := 1
	Endif
//Local oRestModel:= oRU44W310():New()
	oStruAFF := FWFormStruct( 1, 'AFF' ,/* { |x| ALLTRIM(x) $ ' AF9_PROJETO, AF9_REVISA, AF9_EDTPAI, AF9_TAREFA, AF9_DESCRI, AF9_NIVEL, AF9_GRPCOM,AF9_REQ, AF9_START, AF9_FINISH, AF9_HDURAC,AF9_OBS,' } */ )
	oModel := MPFormModel():New('RU44W310', ,bPost,bCommit)
	oModel:SetVldActivate(bPre)

	SX3->(DbSetOrder(2))
	SX3->(DBSEEK( 'AF8_DESCRI'))
	oStruAFF:AddField(STR0007, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
		{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
		{|oModel| iif(oModel:GetOperation() == MODEL_OPERATION_INSERT,'',Posicione('AF8',1,xFilial('AF8')+ AFF->AFF_PROJET, 'AF8_DESCRI'))}, ;
		.F. /*<lKey >*/,;
		.T. /*[ lNoUpd ]*/,;
		.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)// Adiciona ao modelo um componente de formul?rio

	SX3->(DbSetOrder(2))
	SX3->(DBSEEK( 'AF9_DESCRI'))
	oStruAFF:AddField(STR0005, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 		/*[ bValid ]*/, ;
		{|| .F. }/*[ bWhen ]*/,;
		/* [ aValues ]*/, ;
		/*[ lObrigat ]*/,;
		{|oModel| RU44W31001InitTask()}, ;
		.F. /*<lKey >*/,;
		.T. /*[ lNoUpd ]*/,;
		.T. /* [ lVirtual ]*/,;
    	/*[ cValid ]*/)// Adiciona ao modelo um componente de formul?rio


	SX3->(DbSetOrder(2))
	SX3->(DBSEEK( 'AFF_CODMEM'))
	oStruAFF:AddField(X3Titulo(), ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					/**/, ;
					.F. /*<lKey >*/,;
					.F. /*[ lNoUpd ]*/,;
					.F. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)

	oStruAFF:AddField(STR0020, STR0021/*<cTooltip >*/, "_UPDVALUES", "L", 1, 0,;
 					/*[ bValid ]*/, ;
					{|| .T. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/.F.,;
 					/**/{|| mv_par01==1}, ;
					.F. /*<lKey >*/,;
					.F. /*[ lNoUpd ]*/,;
					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)
	oStruAFF:AddField(STR0024, STR0025/*<cTooltip >*/, "_CANDEL", "L", 1, 0,;
 					/*[ bValid ]*/, ;
					{|| M->_UPDVALUES }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/.F.,;
 					/**/{|| mv_par02==1 }, ;
					.F. /*<lKey >*/,;
					.F. /*[ lNoUpd ]*/,;
					.T. /* [ lVirtual ]*/,;
    				/*[ cValid ]*/)

	If !oStruAFF:HasField('AFF_CODMEM')
		SX3->(DbSetOrder(2))
		SX3->(DBSEEK( 'AFF_CODMEM'))
		oStruAFF:AddField(X3Titulo(), ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
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
		"AFF_PROJET" ,; // Campo Dominio
	"AF8_DESCRI" ,; // Campo de Contradominio
	"AF8->AF8_DESCRI",; // Regra de Preenchimento
	.T. ,; // Se posicionara ou nao antes da execucao do gatilhos
	"AF8" ,; // Alias da tabela a ser posicionada
	1 ,; // Ordem da tabela a ser posicionada
	"xFilial('AF8')+M->AFF_PROJET" ,; // Chave de busca da tabela a ser posicionada
	"" ,; // Condicao para execucao do gatilho
	"01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)
	oStruAFF:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])


	aAuxTrg := FwStruTrigger(;
		"AFF_PROJET" ,; // Campo Dominio
	"AFF_REVISA" ,; // Campo de Contradominio
	"AF8->AF8_REVISA",; // Regra de Preenchimento
	.T. ,; // Se posicionara ou nao antes da execucao do gatilhos
	"AF8" ,; // Alias da tabela a ser posicionada
	1 ,; // Ordem da tabela a ser posicionada
	"xFilial('AF8')+M->AFF_PROJET" ,; // Chave de busca da tabela a ser posicionada
	"" ,; // Condicao para execucao do gatilho
	"02" ) // Sequencia do gatilho (usado para identificacao no caso de erro)
	oStruAFF:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])

	aAuxTrg := FwStruTrigger(;
		"AFF_PROJET" ,; // Campo Dominio
	"AFF_TAREFA" ,; // Campo de Contradominio
	"''",; // Regra de Preenchimento
	.F. ,; // Se posicionara ou nao antes da execucao do gatilhos
	"" ,; // Alias da tabela a ser posicionada
	0 ,; // Ordem da tabela a ser posicionada
	"" ,; // Chave de busca da tabela a ser posicionada
	"" ,; // Condicao para execucao do gatilho
	"03" ) // Sequencia do gatilho (usado para identificacao no caso de erro)
	oStruAFF:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])

	aAuxTrg := FwStruTrigger(;
		"AFF_TAREFA" ,; // Campo Dominio
	"AFF_DESCRI" ,; // Campo de Contradominio
	"AF9->AF9_DESCRI",; // Regra de Preenchimento
	.T. ,; // Se posicionara ou nao antes da execucao do gatilhos
	"AF9" ,; // Alias da tabela a ser posicionada
	1 ,; // Ordem da tabela a ser posicionada
	"xFilial('AF9')+M->AFF_PROJET+M->AFF_REVISA+M->AFF_TAREFA" ,; // Chave de busca da tabela a ser posicionada
	"!Empty(M->AFF_PROJET)" ,; // Condicao para execucao do gatilho
	"01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)

	oStruAFF:AddTrigger(aAuxTrg[1], aAuxTrg[2],aAuxTrg[3], aAuxTrg[4])
	SX3->(DbSetOrder(2))
	SX3->(DBSEEK( 'AFF_TAREFA'))
	oStruAFF:SetProperty("AFF_TAREFA", MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, 'PmsSetF3("AF9",2,M->AFF_PROJET)'   ) )
	oStruAFF:SetProperty("AFF_DESCRI", MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, 'RU44W31001InitTask()'   ) )
	oStruAFF:SetProperty("AFF_TAREFA", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'RU44W31004VldTask().And.RU44W31002VldDate()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )

	SX3->(DbSetOrder(2))
	SX3->(DBSEEK( 'AFF_DATA '))
	oStruAFF:SetProperty("AFF_DATA", MODEL_FIELD_VALID,FWBuildFeature( STRUCT_FEATURE_VALID, 'RU44W31002VldDate()'  + iif(Empty(SX3->X3_VLDUSER),"",".And.("+Alltrim(SX3->X3_VLDUSER)+")") ) )

	oStruAFF:SetProperty("AFF_PERC", MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, 'RU44W31003InitPerc()') )

	FWMemoVirtual( oStruAFF,{ { 'AFF_CODMEM' , 'AFF_OBS' } } )

	oModel:AddFields( 'AFFMASTER', /*cOwner*/, oStruAFF)

	oModel:SetPrimaryKey({'AFF_PROJET','AFF_REVISA','AFF_TAREFA','AFF_DATA'})
Return oModel


Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( 'RU44W310' )
// Cria a estrutura a ser usada na View
	Local oStruAFF := FWFormStruct( 2, 'AFF' )
// Interface de visualiza??o constru?da
	Local oView
	oStruAFF:SetNoFolder()
// Cria o objeto de View
	oView := FWFormView():New()
// Define qual o Modelo de dados ser? utilizado na View
	oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formul?rio
// (antiga Enchoice)
	oView:AddField( 'VIEW_AFF', oStruAFF, 'AFFMASTER' )

// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'HEADER' , 100 )
// Relaciona o identificador (ID) da View com o "box" para exibi??o
	oView:SetOwnerView( 'VIEW_AFF', 'HEADER' )


// Retorna o objeto de View criado
Return oView

/*/{Protheus.doc} RU44W310Commit
Function responsible for COMMIT of the model
@type function
@version  R14
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if succeded
/*/
Static Function RU44W310Commit(oModel)
//	Local aErrorMessage := {}
//  Local nX
	Local lRet 		:= .T.
	Local aAreaAN8 := {}
	Local aAreaAF9 := {}
	Local nQtdAnt  := 0
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or.  oModel:GetOperation() == MODEL_OPERATION_INSERT
		Begin Transaction
			if oModel:GetOperation() == MODEL_OPERATION_UPDATE
				nQtdAnt := AFF->AFF_QUANT
				PmsAvalAFF("AFF",2)
			Endif
			FWFormCommit( oModel )
			PmsAvalAFF("AFF",1)


			If M->AFF_PERC == 100
				dbSelectArea("AF9")
				aAreaAF9  := AF9->(GetArea())
				dbSetOrder(1)
				If MsSeek(xFilial("AF9")+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA,.F.)
					dbSelectArea("AN8")
					aAreaAN8  := AN8->(GetArea())
					AN8->(dbSetOrder(1)) //AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA+DTOS(AN8_DATA)+AN8_HORA+AN8_TRFORI
					If AN8->( MsSeek( xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA) ) )
						Do While !AN8->(Eof()) .And. AN8->(AN8_FILIAL+AN8_PROJET+AN8_REVISA+AN8_TAREFA)==xFilial("AN8")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
							If AN8->AN8_STATUS=='1'
								RecLock("AN8",.F.)
								AN8->AN8_STATUS := '3'
								MsUnlock()
							EndIf
							AN8->(dbSkip())
						EndDo
					EndIf
					RestArea(aAreaAN8)
				EndIf
			EndIf
			If 	oModel:GETVALUE('AFFMASTER','_UPDVALUES')
				If  PMSExistAFF(AFF->AFF_PROJET, AFF->AFF_REVISA, AFF->AFF_TAREFA, DToS(AFF->AFF_DATA + 1))
					nQtd := AFF->AFF_QUANT - nQtdAnt
					PMS311Rec(AFF->AFF_PROJET, AFF->AFF_REVISA, AFF->AFF_TAREFA,;
						DToS(AFF_DATA), nQtd, oModel:GETVALUE('AFFMASTER','_CANDEL'))
				Endif
			Endif
		End Transaction
	ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
		PmsAvalAFF("AFF",2)
		PmsAvalAFF("AFF",3)
		If oModel:GETVALUE('AFFMASTER','_UPDVALUES')
			If  PMSExistAFF(AFF->AFF_PROJET, AFF->AFF_REVISA, AFF->AFF_TAREFA, DToS(AFF->AFF_DATA + 1))
				PMS311Rec(AFF->AFF_PROJET, AFF->AFF_REVISA, AFF->AFF_TAREFA,;
					DToS(AFF_DATA), AFF->AFF_QUANT * -1 , oModel:GETVALUE('AFFMASTER','_CANDEL'))
			Endif
		Endif
		FWFormCommit( oModel )
	Endif

	// If !lRet
	// 	If Len(aErrorMessage) > 0
	// 		Help(NIL, NIL, aErrorMessage[1], NIL,aErrorMessage[2]  , 1, 0, NIL, NIL, NIL, NIL, NIL,;
		// 				{aErrorMessage[3]})
	// 	Endif
	// Endif
Return lRet

/*/{Protheus.doc} RU44W310ActivatePreValidation
Validates if the requested operation model can be executed for this model.
This validation is independent from data sent to the model, it is used to check usually permissions and status of record
@type function
@version  R14
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if prevalidation succeeed
/*/

Static Function RU44W310ActivatePreValidation(oModel, cModelId, cAction, cId, xValue)

	Local lRet := .T.
	Local lUpdate := oModel:GetOperation() == MODEL_OPERATION_UPDATE
	Local lInsert := oModel:GetOperation() == MODEL_OPERATION_INSERT
	Local lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
	Local lView   := !(lUpdate .or. lInsert .or. lDelete)

	If lUpdate
		If !PmsVldFase("AF8",AFF->AFF_PROJET, "93")
			lRet := .F.
		EndIf
	ElseIf lDelete
		If !PmsVldFase("AF8",AFF->AFF_PROJET, "95")
			lRet := .F.
		EndIf
	Endif
	If lRet.And. (lUpdate .Or. lDelete)
		AF8->(dbSetOrder(1))
		If AF8->(MsSeek(xFilial()+AFF->AFF_PROJET))
			If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(AFF->AFF_DATA))
				Help(NIL, NIL, STR0010, NIL, i18n(STR0011, {DTOC(AF8->AF8_ULMES)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet :=.F.
			EndIf
		EndIf

	EndIf

	If lRet .And. (lUpdate .or. lDelete)
		If !(lRet := MaCanAltAFF("AFF",.F.))
			Help(NIL, NIL, STR0010, NIL, STR0014 , 1, 0, NIL, NIL, NIL, NIL, NIL,)
		Endif
	Endif

	If lRet
		Do Case
		Case lView
			If !PmsChkUser(AFF->AFF_PROJET, AFF->AFF_TAREFA, NIL, "", 2, "CONFIR", AFF->AFF_REVISA, /*cUser*/, .F.)
				lRet	:=.F.
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019, { AFF->AFF_PROJET, AFF->AFF_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
			EndIf
		Case lUpdate
			If !PmsChkUser(AFF->AFF_PROJET, AFF->AFF_TAREFA, NIL, "", 3, "CONFIR", AFF->AFF_REVISA, /*cUser*/, .F.)
				lRet	:=.F.
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019, { AFF->AFF_PROJET, AFF->AFF_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
			EndIf
		EndCase
	EndIf
Return lRet

/*/{Protheus.doc} RU44W310Posvalidation
Validates the data of the model as a whole, before trying to commit the model
@type function
@version  R14
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if validation succeeed
/*/

Static Function RU44W310Posvalidation(oModel)
	Local lUpdate := oModel:GetOperation() == MODEL_OPERATION_UPDATE
	Local lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE
	Local lInsert := oModel:GetOperation() == MODEL_OPERATION_INSERT
	Local lRet 	  := .T. 
	Local aAreaAFD := {}
	Local aAreaSE1 := {}
	Local aAreaAFT := {}
	Local aAreaAFP := {}
	Local nPerc
	Local cAcao 	:= ""
	Local cRevaca 	:= ""
	Local aArea2AF9	:= {}
	Local cAFA_RECUR
	Local cAF8_DESCR
	Local aColsRej := {}
	Local nX
	//Private variables used inside validations
	PRIVATE INCLUI := lInsert
	PRIVATE ALTERA := lUpdate
	lRet 	  := ValidEdt("M->AFF_PERC",lDelete) .And. ValidEdt("M->AFF_QUANT",lDelete)
	If lRet
		AF9->(DbSetOrder(1))
		AF9->(MSSeek(xFilial()+M->AFF_PROJET+M->AFF_REVISA+M->AFF_TAREFA))
		If !Empty(AF9->AF9_ACAO) .AND. !Empty(AF9->AF9_REVACA) .AND. !Empty(AF9->AF9_TPACAO)
			lRet := .F.
			Help(NIL, NIL, STR0010, NIL, STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0018})
		Endif
	Endif
	If !ExistChav("AFF",M->AFF_PROJET+M->AFF_REVISA+M->AFF_TAREFA+DTOS(M->AFF_DATA))
		lRet := .F.
		Help(NIL, NIL, STR0026, NIL, STR0015, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0016})
	Endif
	If lRet
		If lInsert
			If !PmsVldFase("AF8",M->AFF_PROJET, "93")
				lRet := .F.
			EndIf
			If lRet .And. !PmsChkUser(M->AFF_PROJET, M->AFF_TAREFA, NIL, "", 4, "CONFIR", M->AFF_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019, { M->AFF_PROJET, M->AFF_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf
		ElseIf lUpdate
			If !PmsChkUser(M->AFF_PROJET, M->AFF_TAREFA, NIL, "", 3, "CONFIR", M->AFF_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019, { M->AFF_PROJET, M->AFF_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf
		ElseIf lDelete
			If !PmsChkUser(M->AFF_PROJET, M->AFF_TAREFA, NIL, "", 4, "CONFIR", M->AFF_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019, { M->AFF_PROJET, M->AFF_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf
		Endif
	Endif

// pesquisa se existe uma tarefa com relacionamento
// fim-no-inicio a tarefa atual. se existir, não permitir incluir
// a confirmação se a tarefa predecessora não estiver confirmada em 100%.
	If GetNewPar("MV_PMSPRE",  2) == 1
		dbSelectArea("AFD")
		aAreaAFD := AFD->(GetArea())
		dbSetOrder(1) //AFD_FILIAL + AFD_PROJET + AFD_REVISA + AFD_TAREFA + AFD_ITEM

		If MsSeek(xFilial("AFD") + M->AFF_PROJET + M->AFF_REVISA + M->AFF_TAREFA)
			While !AFD->(Eof()) .And.;
					AFD->AFD_FILIAL + AFD->AFD_PROJET + AFD->AFD_REVISA + AFD->AFD_TAREFA =;
					xFilial("AFD")  + M->AFF_PROJET   + M->AFF_REVISA   + M->AFF_TAREFA

				If AFD->AFD_TIPO == "1"
					If !IsConcluded(AFD->AFD_PROJET, AFD->AFD_REVISA, AFD->AFD_PREDEC)
						Help(NIL, NIL, STR0026, NIL, i18n(STR0035, { ALLTRIM(AFD->AFD_PROJET), Alltrim(AFD->AFD_PREDEC)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
						lRet := .F.
						Exit
					EndIf
				EndIf
				AFD->(dbSkip())
			End
		EndIf
		RestArea(aAreaAFD)
	EndIf

	If lRet .And. (lInsert .Or. lUpdate)
		lRet := PmsVlRelac(M->AFF_PROJET, M->AFF_REVISA, M->AFF_TAREFA, M->AFF_PERC)
	EndIf


	If lRet	.And. (lDelete .Or. lUpdate)
		If lDelete
			nPerc	:=	0
		Else
			nPerc	:=	M->AFF_PERC
		Endif

		dbSelectArea("AF9")
		DbSetOrder(1)
		MsSeek(xFilial()+M->AFF_PROJET+M->AFF_REVISA+M->AFF_TAREFA)
		dbSelectArea("AFT")
		aAreaAFT := AFT->(GetArea())
		dbSetOrder(2)
		dbSelectArea("SE1")
		aAreaSE1 := SE1->(GetArea())
		dbSetOrder(2)
		dbSelectArea("AFP")
		aAreaAFP := AFP->(GetArea())
		dbSetOrder(1)
		MsSeek(xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA)
		While lRet	.And.  !Eof() .And. xFilial()+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_TAREFA==AFP_FILIAL+AFP_PROJETO+AFP_REVISA+AFP_TAREFA
			If AFP->AFP_DTATU==AFF->AFF_DATA
				If nPerc <= AFP_PERC

					// verifica se existem titulos Normais gerados para o
					// evento, que tiveram movimentos
					dbSelectArea("SE1")
					MsSeek(PmsFilial("SE1", "AFP")+AFP->AFP_CLIENT+AFP->AFP_LOJA+AFP->AFP_PREFIX+AFP->AFP_NUM)
					While lRet	.And. !Eof() .And. PmsFilial("SE1", "AFP")+AFP->AFP_CLIENT+AFP->AFP_LOJA+AFP->AFP_PREFIX+AFP->AFP_NUM==;
							E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM

						If !(SE1->E1_TIPO$MVNOTAFIS) .Or. !Empty(SE1->E1_BAIXA) .Or. SE1->E1_VALOR <> SE1->E1_SALDO .Or. !(SE1->E1_SITUACA $ " 0")
							dbSelectArea("AFT")
							If MsSeek(xFilial()+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA) .And. AFT->AFT_EVENTO==AFP->AFP_ITEM

								Help(NIL, NIL, STR0026, NIL, ;
									i18n(STR0037,;
									{ ALLTRIM(SE1->E1_TIPO),;
									Alltrim(SE1->E1_PREFIXO),;
									Alltrim(SE1->E1_NUM),;
									Alltrim(SE1->E1_PARCELA),;
									If(lDelete, STR0038,;
										i18n(STR0039, {Alltrim(Str(AFP->AFP_PERC))+"%."}));
										}),;
										1, 0, NIL, NIL, NIL, NIL, NIL,)
									//The bill Type #1[type]#, prefix #2[Prefix]#, number #3[number]#, Installment #4[Installment]# generated by events of this task was moved and therefore this confirmation cannot be #5[]#
									lRet	:=	.F.
								EndIf
							Endif
							dbSelectArea("SE1")
							DbSkip()
						Enddo
					EndIf
				EndIf
				dbSelectArea("AFP")
				dbSkip()
			EndDo
			RestArea(aAreaAFT)
			RestArea(aAreaSE1)
			RestArea(aAreaAFP)

		Endif

//TODO: Implement INTEGRATION WITH QNC Module in MODEL
		If .F. // lRet .AND. (M->AFF_PERC == 100)
			__lRejec 	:= .F.       	///	VARIAVEL PRECISA ESTAR DISPONÍVEL NA PMS311GRAVA() QUANDO HÁ INTEGRAÇÃO QNC (MV_QTMKPMS) 3 ou 4.

			dbSelectArea("AF9")
			dbSetOrder(1)
			If MsSeek(xFilial("AF9")+M->AFF_PROJET + M->AFF_REVISA + M->AFF_TAREFA)
				//
				// Se PMS esta integrado com QNC
				//
				If !Empty(AF9->AF9_ACAO) .AND. !Empty(AF9->AF9_REVACA) .AND. !Empty(AF9->AF9_TPACAO)
					///Define as etapas que não tem obrigatoriedade
					__cQNCRej	:= ""
					__cQNCDEP	:= ""
					__cNEWQUO	:= ""

					lRet := QAltObrigEtp(AF9->AF9_ACAO ,AF9->AF9_REVACA ,AF9->AF9_TPACAO,.T.,@__lRejec,@__cQNCRej,@__cQNCDEP,@__cNEWQUO)

					// Se houver rejeicao do plano de acao, visualiza a tela
					// para informar os tipos de erros e os motivos da rejeicao
					If __lRejec
						dbSelectArea("AE8")
						aAreaAE8 := AE8->(GetArea())
						dbSetOrder(1)
						dbSelectArea("AFA")
						aAreaAFA := AFA->(GetArea())
						dbSetOrder(1)
						// Busca outas tarefas que foram abertas em paralelo
						// se houver tarefas parcialmente executadas, deve apresetnar mensagem ao usuario
						// para que os recursos com a tarefa em paralelo encerrem.
						cAcao 		:= AF9->AF9_ACAO
						cRevaca 	:= AF9->AF9_REVACA
						aArea2AF9	:= AF9->(GetArea())
						AF9->(dbSetOrder(6))
						AF9->(dbSeek(xFilial("AF9")+cAcao+cRevaca,.F.))
						While AF9->(!EOF()) .AND. AF9->(AF9_FILIAL+AF9_ACAO+AF9_REVACA) == xFilial("AF9")+cAcao+cRevaca
							// Busca pelas OUTRAS tarefas com o mesmo plano e revisão
							If  xFilial("AF9")+M->AFF_PROJET + M->AFF_REVISA + M->AFF_TAREFA<>AF9->(AF9_FILIAL+AF9_PROJET+AF9_REVISA+AF9_TAREFA)
								// se a tarefa em paralelo está em execucao
								If !Empty(AF9->AF9_DTATUI) .And. Empty(AF9->AF9_DTATUF)
									dbSelectArea("AFA")
									dbSeek(xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA))
									Do While !AFA->(Eof()) .And. AFA->(AFA_FILIAL+AFA_PROJET+AFA_REVISA+AFA_TAREFA)==xFilial("AFA")+AF9->(AF9_PROJET+AF9_REVISA+AF9_TAREFA)
										If AE8->(dbSeek(xFilial("AE8")+AFA->AFA_RECURS))
											cAFA_RECUR := AFA->AFA_RECURS
											cAF8_DESCR := AE8->AE8_DESCRI
										EndIf
										If AFA->AFA_RESP == "S"
											EXIT
										EndIf
										AFA->(dbSkip())
									EndDo
									aAdd( aColsRej, {Alltrim(cAFA_RECUR),Alltrim(cAF8_DESCR),Alltrim(AF9->AF9_TAREFA),Alltrim(AF9->AF9_DESCRI),AF9->AF9_DTATUI,PmsPOCAF9(AF9->AF9_PROJET,AF9->AF9_REVISA,AF9->AF9_TAREFA,dDataBase),.F.})
								EndIf
							EndIf
							dbSelectArea("AF9")
							DbSkip()
						EndDo
						RestArea(aArea2AF9)
						RestArea(aAreaAFA)
						RestArea(aAreaAE8)

						// REJEICAO SOMENTE PODE OCORRER QUANDO AS TAREFAS EM PARALELO FOREM ENCERRADAS
						// Titulo da janela : rejeicao Tarefas em paralelo
						// Mensagem:
						// grade: Codigo/Nome recurso, Codigo/Descricao Tarefa,  Data real inicio e % executado
						If !Empty(aColsRej)

							lRet := .F.

							aHeadRej := {}
							For nX:=1 To Len(aColsRej)
								cMessage := i18n(STR0022,{;
									aColsRej[nX,1],;
									aColsRej[nX,2],;
									aColsRej[nX,3],;
									aColsRej[nX,4],;
									Dtoc(aColsRej[nX,5]),;
									Str(aColsRej[nX,6]),;
									}) + CRLF
							Next nX
							Help(NIL, NIL, STR0030, NIL, ;
								cMessage,;
								1, 0, NIL, NIL, NIL, NIL, NIL,{STR0031})
						EndIf

						If lRet
							//TODO: CHECK CONDITIONS TO IMPLEMENT INTEGRATION WITH QNC
							//***************
							// Monta aCols	*
							//***************
							// 	aHeaderANA			:= GetaHeader( "ANC", { "ANC_TIPERR", "ANC_MOTIVO" /*exibir*/ }, { "ANA_SEVCOD" /*nao exibir*/} )
							// 	aAdd( aColsANA, { Space( TamSX3( "ANC_TIPERR" )[1] ), Space( TamSX3( "ANC_MOTIVO" )[1] ), NIL } )
							// 	aColsANA[Len(aColsANA),Len(aHeaderANA) + 1] := .F.

							// 	DEFINE MSDIALOG oDlg TITLE STR0047 + " " + AF9->AF9_TAREFA FROM 0, 0 TO 250,450 PIXEL //"Tarefa"

							// 	@  10,   5 SAY oSay2 PROMPT STR0048 SIZE 25, 7 OF oDlg PIXEL //"Motivo:"

							// 	oGDItens:= MsNewGetDados():New( 020,005,105,225, cGetOpc,,,,,,,,,, oDlg, aHeaderANA, aColsANA )

							// 	@ 110, 147 BUTTON oBtn1 PROMPT STR0049 SIZE 37, 12 ACTION IIf( !VldRjtTrf( oGDItens, aScan( aHeaderANA, { |x| x[2] == "ANC_MOTIVO" } ) ), MsgInfo( STR0050 ), (lRet := .T., oDlg:End()) ) OF oDlg PIXEL //"Ok"##"Motivo nao informado"
							// 	@ 110, 187 BUTTON oBtn2 PROMPT STR0051 SIZE 37, 12 ACTION (lRet := .F., oDlg:End()) OF oDlg PIXEL //"Cancela"
							// 	ACTIVATE MSDIALOG oDlg CENTERED

							// 	// Atualiza o array a motivos com as informacoes digitadas
							// 	aMotivos := {}
							// 	If lRet
							// 		nPosTpErro	:= aScan( aHeaderANA, { |x| x[2] == "ANC_TIPERR" } )
							// 		nPosDesc	:= aScan( aHeaderANA, { |x| x[2] == "ANC_MOTIVO" } )

							// 		For nInc := 1 To Len( oGDItens:aCols )
							// 			aAdd( aMotivos, { oGDItens:aCols[nInc][nPosTpErro], oGDItens:aCols[nInc][nPosDesc], 0 } )
							// 		Next
							// 	EndIf
							// EndIf

						EndIf
					EndIf
				EndIf
				RestArea(aAreaAF9)

				If lRet .And. !__lRejec
					lRet := SIMCHLok()[1]
				EndIf

			EndIf
		Endif
		// If lRet .And. !lDelete .And. !IsBlind() .And. PMSExistAFF(M->AFF_PROJET, M->AFF_REVISA, M->AFF_TAREFA, DTOS(M->AFF_DATA + 1))
		// 	nAnswer := Aviso(STR0027,; //"Atualizar confirmacoes"
		// 		STR0028,; //"Deseja atualizar as confirmacoes posteriores para considerar a alteracao efetuada?"
		// 		{STR0032, STR0034, STR0033}, 3) //"Update and delete"# "Only update"##"Nao"

		// 	If nAnswer == 1
		// 		oModel:LoadValue('AFFMASTER', '_UPDVALUES',.T.)
		// 		oModel:LoadValue('AFFMASTER', '_CANDEL',.T.)
		// 	ElseIf nAnswer == 2
		// 		oModel:LoadValue('AFFMASTER', '_UPDVALUES',.T.)
		// 		oModel:LoadValue('AFFMASTER', '_CANDEL',.F.)
		// 	Else
		// 		oModel:LoadValue('AFFMASTER', '_UPDVALUES',.F.)
		// 		oModel:LoadValue('AFFMASTER', '_CANDEL',.F.)
		// 	Endif
		// Endif

		// If oModel:GetValue('AFFMASTER', '_UPDVALUES')
		// 	If Aviso(STR0027,; //"Atualizar confirmacoes"
		// 		STR0034,; //"Deseja excluir as confirmacoes cujos percentuais forem menores que 0% ou maiores que 100%?"
		// 		{STR0032, STR0033}, 3) == 1 //"Sim"###"Nao"
		// 		oModel:LoadValue('AFFMASTER', '_CANDEL',.T.)
		// 	Endif
		// Endif
		Return lRet

/*/{Protheus.doc} RU44W31001InitTask
Initiates value for virtual field AFF_TAREFA
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return character, Task description
/*/
Function RU44W31001InitTask() as character
	Local cRet := "" as character
	Local oModel 	   := FWModelActive() as object
	If oModel:GetOperation() <> MODEL_OPERATION_INSERT
		AF9->(MsSeek(xFilial()+AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA))
		cRet := AF9->AF9_DESCRI
	EndIf

Return cRet


/*/{Protheus.doc} RU44W31002VldDate
Validates date on task and date typing
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W31002VldDate() as logical
	Local lRet := .T. as logical
	Local oModel 	   := FWModelActive() as object
	If !Empty(M->AFF_TAREFA) .And. !Empty(M->AFF_PROJET)
		lRet := oModel:GetOperation() == MODEL_OPERATION_UPDATE .And.;
			M->AFF_PROJET+M->AFF_REVISA+M->AFF_TAREFA+Dtos(M->AFF_DATA) == AFF->AFF_PROJET+AFF->AFF_REVISA+AFF->AFF_TAREFA+Dtos(AFF->AFF_DATA)
		If !lRet
			lRet := ExistChav("AFF",M->AFF_PROJET+M->AFF_REVISA+M->AFF_TAREFA+Dtos(M->AFF_DATA))
		Endif
	EndIf
Return lRet

/*/{Protheus.doc} RU44W31003InitPerc
Fills percentage
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W31003InitPerc() as numeric
	Local nRet := 0 as numeric
	Local oModel 	   := FWModelActive() as object
	If oModel:GetOperation() <> MODEL_OPERATION_INSERT
		nRet := PMS310QT(.F.)
	EndIf
Return nRet

/*/{Protheus.doc} RU44W31004VldTask
Validates task typed
@type function
@version R14
@author bsobieski
@since 15/08/2024
@return logical, true if valid
/*/
Function RU44W31004VldTask() as logical
	Local lRet := .T. as logical
	If !Empty(M->AFF_TAREFA) .And. !Empty(M->AFF_PROJET)
		lRet := ExistCpo("AF9",M->AFF_PROJET+M->AFF_REVISA+M->AFF_TAREFA,1)
	EndIf
Return lRet

                   
//Merge Russia R14 
                   
