#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU44W710.CH"

/*MAINTENANCE FOR PROJECTS Pre-Annotation Confirmation (simple model to be used in web forms for VISUALIZATION)*/

PUBLISH MODEL REST NAME RU44W710 RESOURCE OBJECT oRU44W710

/*/{Protheus.doc} oRU44W710
description
@type class
@version  
@author
@since 03/07/2023
/*/
Class oRU44W710 From FwRestModel

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
	Data lOnlyValidate as logical // Indica se deve retornar o ID(Recno) como informação complementar das linhas do GRID (padrão: false)
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

/*/{Protheus.doc} oRU44W710::Activate
description
@type method
@version  
@author 
@since 03/07/2023
@return variant, return_description
/*/
Method Activate() Class oRU44W710

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
	self:lOnlyValidate  := self:GetQSValue("lOnlyValidate")  == "true" .Or. self:GetQSValue("lOnlyValidate") == "1"
	self:cGroup			:= self:GetQSValue("group")

	//So os permitidos
	If _Super:Activate()
		If !MPUserHasAccess('RU44W710')
			_Super:setfilter("1=2")
			lRet := .F.
			self:SetStatusResponse(403, STR0001)
		Else
			// Set standard filter for model
			RU44X10002_FilterOnActivate(@self,'RU44W710')
			lRet := .T.
		EndIf
	Else
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} oRU44W710::DeActivate
description
@type method
@version  
@author
@since 03/07/2023
@return variant, return_description
/*/
Method DeActivate() Class oRU44W710

	If !(self:nStatus == Nil)
		self:SetStatusResponse({self:nStatus, EncodeUTF8(self:cStatus)})
	EndIf

Return _Super:DeActivate()

/*/{Protheus.doc} oRU44W710::Seek
description
@type method
@version  
@author
@since 03/07/2023
@param cPK, character, param_description
@return variant, return_description
/*/
Method Seek(cPK) Class oRU44W710

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
Method Total() Class oRU44W710

	Local nTotal := 0

	nTotal := RU44X10003_Total(@self)

Return nTotal


Method GetData() Class oRU44W710
	Local cRet := self:cResponse
Return cRet

Method Skip() Class oRU44W710
Return .F.

Method StartGetFormat(nTotal, nCount, nStartIndex) Class oRU44W710
	
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
Method EndGetFormat() Class oRU44W710
	
	Local cRet := ""
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveData
Method returns true if data was saved successfully
@return lRet   
@author 
@since 15/05/2024
@version P14
/*/
//-------------------------------------------------------------------
Method SaveData(cPk,cData,cError) Class oRU44W710
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
Function RU44W710()
Local cFiltraAJK := 'AJK_FILIAL == "'+xFilial("AJK")+'" .AND. AJK_CTRRVS == "1"'
Local oBrowse
If AMIIn(44)
	If PmsChkAJK(.T.)
		PRIVATE aRotina		:= MenuDef()
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('AJK')
	
		oBrowse:SetFilterDefault( cFiltraAJK )
	
		oBrowse:SetDescription(STR0034)
		oBrowse:DisableDetails()
		oBrowse:Activate()
	EndIf
EndIf
Return 

/*/{Protheus.doc} MenuDef
Defines menu for browse
@type function
@version  R14
@author bsobieski
@since 23/08/2024
@return array, ARotina array for menu
/*/
Static Function MenuDef() 
Local aRotina := {}

aAdd( aRotina, { STR0002   	, 'VIEWDEF.RU44W710', 0, 2, 0, Nil } )
aAdd( aRotina, { STR0004	, 'VIEWDEF.RU44W710', 0, 4, 0, Nil } )
aAdd( aRotina, { STR0003 	, 'RU44W71001("2")'	, 0, 4, 0, Nil } )
aAdd( aRotina, { STR0018 	, 'RU44W71001("3")'	, 0, 4, 0, Nil } )
aAdd( aRotina, { STR0021 	, 'RU44W71001("1")'	, 0, 4, 0, Nil } )
aAdd( aRotina, { STR0035 	, 'RU44W71002("2")'	, 0, 4, 0, Nil } )
aAdd( aRotina, { STR0036  	, 'RU44W71002("3")'	, 0, 4, 0, Nil } )
aAdd( aRotina, { STR0037  	, 'RU44W71002("1")'	, 0, 4, 0, Nil } )

//aAdd( aRotina, { 'OPERATION 40' 	, 'VIEWDEF.RU44W710', 0, 40, 0, Nil, 15 } )
Return aRotina


/*/{Protheus.doc} ModelDef
Modeldef for preanotations management
@type function
@version  R14
@author bsobieski
@since 23/08/2024
@return Object, Model
/*/
Static Function ModelDef() 
Local oStruAJK
Local oModel 
Local bCommit   := {|oModel| RU44W710Commit(oModel) }
Local bPre		:= {|oModel| RU44W710ActivatePreValidation(oModel)}
Local bFieldPre	:= {|oModel, cModelId, cAction, cId, xValue| FieldPreVld(oModel, cModelId, cAction, cId, xValue)}
Local bPost		:= {|oModel| RU44W710PosValidation(oModel)}
Local nX
Local aFields 	:= {}

oStruAJK := FWFormStruct( 1, 'AJK' ,/* { |x| ALLTRIM(x) $ ' AF9_PROJETO, AF9_REVISA, AF9_EDTPAI, AF9_TAREFA, AF9_DESCRI, AF9_NIVEL, AF9_GRPCOM,AF9_REQ, AF9_START, AF9_FINISH, AF9_HDURAC,AF9_OBS,' } */ )
oModel := MPFormModel():New('RU44W710',bFieldPre,bPost,bCommit)
oModel:SetVldActivate(bPre)

oStruAJK:SetProperty('AJK_SLDHR' ,MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, 'A700HrSld(AJK->AJK_PROJET,AJK->AJK_REVISA,AJK->AJK_TAREFA,AJK->AJK_RECURS)'))

SX3->(DbSetOrder(2))
SX3->(DBSEEK( 'AF9_DESCRI'))
oStruAJK:AddField(STR0005, ''/*<cTooltip >*/, SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
 					/*[ bValid ]*/, ;
					{|| .F. }/*[ bWhen ]*/,;
					/* [ aValues ]*/, ;
					/*[ lObrigat ]*/,;
 					{|| Posicione('AF9',1,xFilial('AF9')+ AJK->AJK_PROJET + AJK->AJK_REVISA + AJK->AJK_TAREFA, 'AF9_DESCRI')}, ;
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
 					{|| Posicione('AE8',1,xFilial('AE8')+ AJK->AJK_RECURS, 'AE8_DESCRI')}, ;
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
						{||, '1'}, ;
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
aFields := oStruAJK:GetFields()
 
For nX:=1 To Len(aFields)
	If aFields[nX,3] <> "AJK_SITUAC" .AND. aFields[nX,3] <> "AJK_MOTIVO"
		oStruAJK:SetProperty(aFields[nX,3] , MODEL_FIELD_NOUPD,  .T.)
	Else
		oStruAJK:SetProperty(aFields[nX,3] , MODEL_FIELD_NOUPD,  .F.)
	Endif
Next
FWMemoVirtual( oStruAJK,{ { 'AJK_CODME1' , 'AJK_MOTIVO'} } )

oModel:AddFields( 'AJKMASTER', /*cOwner*/, oStruAJK)

oModel:SetPrimaryKey({'AJK_CTRRVS','AJK_PROJET','AJK_REVISA','AJK_TAREFA','AJK_RECURS','AJK_DATA','AJK_HORAI' })
Return oModel


/*/{Protheus.doc} RU44W71001
Approval, rejection, revestion of current record
Not supposed to be used by REST services... For thar, just use the UPDATE option, sending status and reason

@type function
@version  R14
@author bsobieski
@since 23/08/2024
@param cOperation, character, Operation 2=Approve, 3= Reject, 1=Reversa approval/rejection
@param aConfig, array, Parambox parameters already filled in
@return Array, List of errors
/*/
Function RU44W71001(cOperation, aConfig)
Local lRet := .T. 
Local aError := ""
Local oModel:= ModelDef()
Local cOperDesc := ""
Local cReason := ""
Local lShowError := .T.
Local aRet := {}
Do Case
	Case cOperation == "1"
		cOperDesc := STR0021
	Case cOperation == "2"
		cOperDesc := STR0003
	Case cOperation == "3"
		cOperDesc := STR0018
EndCase

If aConfig <> Nil
	lShowError := .F.
Else
	aConfig := {"",.F.}
	aConfig[1] := I18n(STR0017,{cOperDesc})
	lRet:= ParamBox({	{11,aConfig[1],Space(400),,,},;
						{4,STR0024,aConfig[2],STR0020,40,,.F.}; //"Exibir detalhes :"###"Codigo"
				},cOperDesc+" "+ STR0031,aConfig,,,.F.,120,3)
Endif
If lRet
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	lRet := oModel:Activate()

	If lRet
		lRet := oModel:SETVALUE('AJKMASTER','AJK_SITUAC',cOperation)
	Endif
	If lRet
		If !aConfig[2]
			cReason := i18n(STR0032,{FWTIMESTAMP(5),cOperDesc})+CRLF+aConfig[1]
		Else
			cReason := i18n(STR0032,{FWTIMESTAMP(5),cOperDesc})+CRLF+aConfig[1]+CRLF+oModel:GETVALUE('AJKMASTER','AJK_MOTIVO')+CRLF+"------------"
		Endif
		lRet := oModel:SETVALUE('AJKMASTER','AJK_MOTIVO',cReason)
	Endif
	If lRet
		lRet := oModel:VldData() 
	Endif
	If lRet 
		lRet := (oModel:CommitData())
	Endif
	If !lRet
		aError := oModel:GetErrorMessage(.F.)
	Endif
	oModel:DeActivate()

	If !lRet
		If lShowError
			Help(NIL, NIL, IIf(Empty(aError[5]),STR0033,aError[5]), NIL,  IIf(Empty(aError[6]),STR0033,aError[6]), 1, 0, NIL, NIL, NIL, NIL, NIL,;
			{IIf(Empty(aError[7]),"",aError[7])})
		Else
			aRet := {IIf(Empty(aError[6]),STR0033,aError[6]),IIf(Empty(aError[7]),"",aError[7])}
		Endif
	Endif
Endif
Return aRet

/*/{Protheus.doc} ViewDef
ViewDef for preanotations management
@type function
@version  R14
@author bsobieski
@since 23/08/2024
@return Object, View
/*/
Static Function ViewDef()
Local oModel := FWLoadModel( 'RU44W710' )
Local oStruAJK := FWFormStruct( 2, 'AJK' )
Local oView
Local aFields := {}
Local nX
aFields := oStruAJK:GetFields()
For nX:=1 To Len(aFields)
	If aFields[nX,1] <> "AJK_SITUAC" .AND. aFields[nX,1] <> "AJK_MOTIVO"
		oStruAJK:SetProperty(aFields[nX,1] , MVC_VIEW_CANCHANGE,  .F.)
	Else
		oStruAJK:SetProperty(aFields[nX,1] , MVC_VIEW_CANCHANGE,  .T.)
	Endif
Next

oStruAJK:SetNoFolder()
oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_AJK', oStruAJK, 'AJKMASTER' )

oView:CreateHorizontalBox( 'HEADER' , 100 )
oView:SetOwnerView( 'VIEW_AJK', 'HEADER' )

Return oView

/*/{Protheus.doc} runApproval(aReturn, cOperation,aConfig)
    function responsible for Approve/Reject/Revert AJK records
    @type  Function 
    @author Dmitry Borisov 
    @since 29/05/2024 
    @version R14 
    @param aRecords , Array , List of records to be processed
	@param cOperation, character, Operation 2=Approve, 3= Reject, 1=Reversa approval/rejection
	@param aConfig, array, Parambox parameters already filled in
    @return Array , Errors list 
/*/
Static Function RunApprovalRejection(aRecords, cOperation,aConfig)
Local nX
Local aRet
Local aError := {}
Local nSuccess := 0
ProcRegua(Len(aRecords))
For nX:=1 To Len(aRecords)
	AJK->(DbGoto(aRecords[nX]))
	IncProc(i18n( STR0038,{Alltrim(AJK->AJK_PROJET), Alltrim(AJK->AJK_TAREFA),Len(aError), nSuccess}))
	aRet := RU44W71001(cOperation, aConfig)
	If len(aRet) > 0
		AAdd(aError,aRet)
	Else
		nSuccess++
	Endif
Next
Return aError


/*/{Protheus.doc} RU44W710Commit
Function responsible for COMMIT of the model
@type function
@version  R14
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if succeded
/*/
Static Function RU44W710Commit(oModel)
    Local aFieldsAFU	:= {}
    Local aFieldsAJK	:= {}
    Local aArea     := {}
    Local lApprove	:= .F.
	Local lReject 	:= .F.
	Local lRevert 	:= .F.
	Local cPrevSituac :=""
	Local nRecno
	Local aErrorMessage := {}
    Local nX
	Local lRet 		:= .T.
	Local oModel300 
    Private lMsErroAuto := .F.
    aArea := GetArea()
    DbSelectArea("AJK")
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE 
		Begin Transaction
			cPrevSituac := AJK->AJK_SITUAC
			lRevert 	:= (AJK->AJK_SITUAC $ "2|3") .And. oModel:GetValue("AJKMASTER", "AJK_SITUAC") == "1"
			lApprove 	:= (oModel:GetValue("AJKMASTER", "AJK_SITUAC")== "2")
			lReject 	:= (oModel:GetValue("AJKMASTER", "AJK_SITUAC")== "3")

			FWFormCommit( oModel )
			RecLock("AJK" ,.F.)
				AJK->AJK_USRAPR := __cUserID
			MsUnLock()
		
			If lApprove
				oModel300 := FWLoadModel( 'RU44W300' )
				oModel300:SetOperation( MODEL_OPERATION_INSERT )
				lRet := oModel300:Activate()
				aFieldsAJK := oModel:getModel('AJKMASTER'):GetStruct():aFields
				aFieldsAFU := oModel300:getModel('AFUMASTER'):GetStruct():aFields
				For nX:=1 To Len(aFieldsAFU)
					If Left(aFieldsAFU[nX][MODEL_FIELD_IDFIELD] , 3 ) == "AFU" .and.;
						aFieldsAFU[nX][MODEL_FIELD_IDFIELD] <> "AFU_CODMEM" .And.;
						aFieldsAFU[nX][MODEL_FIELD_IDFIELD] <> "AFU_CTRRVS" 
						If Ascan(aFieldsAJK, {|x| Substr(x[3],5) == Substr(aFieldsAFU[nX][MODEL_FIELD_IDFIELD],5)}) > 0
							lRet := oModel300:SETVALUE('AFUMASTER',aFieldsAFU[nX][MODEL_FIELD_IDFIELD],oModel:GetValue('AJKMASTER', 'AJK_'+Substr(aFieldsAFU[nX][MODEL_FIELD_IDFIELD],5)))
						Endif
					Endif
					If !lRet
						Exit
					Endif
				Next
				//oModel300:LoadVALUE('AFUMASTER',"AFU_PREREC","1")
				//oModel300:LoadVALUE('AFUMASTER',"AFU_CTRRVS","1")
				If lRet
					lRet := oModel300:VldData() 
				Endif
				If lRet 
					lRet := (oModel300:CommitData())
					If lRet 
						Reclock('AFU',.F.)
						AFU_PREREC := "1"
						MsUnLock()
					Endif
				Endif
				If !lRet
					aError := oModel300:GetErrorMessage(.F.)
				Endif
				oModel300:DeActivate()

				If !lRet
					aErrorMessage := {	If(Empty(aError[5]),STR0033,aError[5]),;
								IIf(Empty(aError[6]),STR0033,aError[6]),;
								IIf(Empty(aError[7]),"",aError[7])}
				Endif
				RestArea(aArea)
			EndIf
			If lRevert
				nRecno := GetAFURecno()	
				If nRecno == 0
					//TODO: To Think...
					// 		If it is being reverted from REJECT. then is ok
					//		If it is being reverted from approved, then there is an inconsisency, should be allow to revert? 
					//    		It is being allowed to do so, because if not, the only way to treat this record is directly in database
				Else
					AFU->(DbGoTo(nRecNo))     
					oModel300 := FWLoadModel( 'RU44W300' )
					oModel300:SetOperation( MODEL_OPERATION_DELETE )
					lRet := oModel300:Activate()
					if lRet
						lRet := oModel300:VldData() 
					Endif
					If lRet 
						lRet := (oModel300:CommitData())
					Endif	
					If !lRet
						aError := oModel300:GetErrorMessage(.F.)
					Endif
					oModel300:DeActivate()
					If !lRet
						aErrorMessage := {	If(Empty(aError[5]),STR0033,aError[5]),;
										IIf(Empty(aError[6]),STR0033,aError[6]),;
										IIf(Empty(aError[7]),"",aError[7])}
					Endif

				Endif
				RestArea(aArea)
			EndIf
			If !lRet
				DisarmTransaction()
			Endif
		End Transaction
	Endif
	If !lRet
		If Len(aErrorMessage) > 0
			Help(NIL, NIL, aErrorMessage[1], NIL,aErrorMessage[2]  , 1, 0, NIL, NIL, NIL, NIL, NIL,;
					{aErrorMessage[3]})
		Endif
	Endif
Return lRet

Static Function FieldPreVld(oSubModel, cModelId, cAction, cId, xValue)
    Local lRet := .T.
	Local cMessage:= ""
    If oSubModel:GetOperation() == MODEL_OPERATION_UPDATE  .And. cId == "AJK_SITUAC"
		If  cAction == "SETVALUE"
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
				Help(NIL, NIL, STR0010, NIL, cMessage, 1, 0, NIL, NIL, NIL, NIL, NIL,)
				//oSubModel:SetErrorMessage(cModelId, cId,cModelId,cId,'STR0028',cMessage,xValue, oSubModel:GetValue("AJK_SITUAC"))
			EndIf
		ElseIf cAction == "CANSETVALUE"
			lRet := .T.
		EndIf
	Endif
Return lRet

/*/{Protheus.doc} RU44W710ActivatePreValidation
Validates if the requested operation model can be executed for this model.
This validation is independent from data sent to the model, it is used to check usually permissions and status of record
@type function
@version  R14
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if prevalidation succeeed
/*/

Static Function RU44W710ActivatePreValidation(oModel, cModelId, cAction, cId, xValue)

Local lRet := .T.
Local lUpdate := oModel:GetOperation() == MODEL_OPERATION_UPDATE
Local lView   := !(lUpdate)
		 
If !(lView)  
	If !PmsVldFase("AF8",AJK->AJK_PROJET, "89")
		lRet := .F.
	EndIf

	If !lUpdate
		Help(NIL, NIL, STR0010, NIL, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL,)
		lRet :=.F.
	Endif
	// verificar data do ultimo fechamento do Projeto
	If lRet .And. !lView 
		AF8->(dbSetOrder(1))
		If AF8->(MsSeek(xFilial()+AJK->AJK_PROJET))
			If !Empty(AF8->AF8_ULMES) .and. (DTOS(AF8->AF8_ULMES) >= dtos(AJK->AJK_DATA))
				Help(NIL, NIL, STR0010, NIL, i18n(STR0011, {DTOC(AF8->AF8_ULMES)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet :=.F.
			EndIf
		EndIf
	EndIf
Endif

If lRet 
	Do Case
		Case lView
			If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 1, "APRPRE", AJK->AJK_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019, { AJK->AJK_PROJET, AJK->AJK_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf
		Case lUpdate
			If !PmsChkUser(AJK->AJK_PROJET, AJK->AJK_TAREFA, NIL, "", 2, "APRPRE", AJK->AJK_REVISA, /*cUser*/, .F.)
				Help(NIL, NIL, STR0012, NIL, i18n(STR0019, { AJK->AJK_PROJET, AJK->AJK_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
				lRet	:=.F.
			EndIf
	EndCase		
EndIf
Return lRet

/*/{Protheus.doc} RU44W710Posvalidation
Validates the data of the model as a whole, before trying to commit the model
@type function
@version  R14
@author bsobieski
@since 14/08/2024
@param oModel, object, Model
@return logical, true if validation succeeed
/*/

Static Function RU44W710Posvalidation(oModel)
Local lRet := .T.
Local lUpdate := oModel:GetOperation() == MODEL_OPERATION_UPDATE
If lUpdate
	If oModel:GetValue("AJKMASTER", "AJK_SITUAC") == "1" .And. (Empty(AJK->AJK_SITUAC).Or. AJK->AJK_SITUAC == "1")
		Help(NIL, NIL, STR0010, NIL, STR0027, 1, 0, NIL, NIL, NIL, NIL, NIL,)
		lRet := .F.
	EndIf
	If lRet .And. ( (	oModel:GetValue("AJKMASTER", "AJK_SITUAC") == "2" .And. AJK->AJK_SITUAC == "3") .Or. ;
	 				(	oModel:GetValue("AJKMASTER", "AJK_SITUAC") == "3" .And. AJK->AJK_SITUAC == "2") ) 
		Help(NIL, NIL, STR0010, NIL, I18N(STR0014, {IIf(AJK->AJK_SITUAC=="2", STR0015, STR0016),IIf(oModel:GetValue("AJKMASTER", "AJK_SITUAC") =="2", STR0015, STR0016)});
		, 1, 0, NIL, NIL, NIL, NIL, NIL,;
		{STR0022})
		lRet := .F.
	EndIf
	If lRet .And. (oModel:GetValue("AJKMASTER", "AJK_SITUAC") ==  AJK->AJK_SITUAC )
	 	Help(NIL, NIL, STR0010, NIL, i18n(STR0030,{IIf(AJK->AJK_SITUAC =="2", STR0015, STR0016)}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
	 	lRet := .F.
	EndIf
Endif
If lRet 
	If  oModel:GetValue("AJKMASTER", "AJK_SITUAC") == "2"
		//No need to Check AFU for appointment existence, because will be checked on RU44w300
	Endif 
Endif
Return lRet

/*/{Protheus.doc} GetAFURecno
Return RECNO from AFU linked to current posicioned pre-annotation
@type function
@version  R14
@author bsobieski
@since 23/08/2024
@return numeric, Record number from afu linked to current AJK
/*/
Static Function GetAFURecno()
Local cTemp 	:= GetNextAlias()
Local cQuery
Local nRecno := 0
cQuery	:= " Select R_E_C_N_O_ FROM "+ RetSqlName("AFU")
cQuery	+= " WHERE AFU_FILIAL = '"+ xFilial("AFU") +"' AND "
cQuery	+= " AFU_PROJET = '"+ AJK->AJK_PROJET +"' AND "
cQuery	+= " AFU_REVISA = '"+ AJK->AJK_REVISA +"' AND "
cQuery	+= " AFU_TAREFA = '"+ AJK->AJK_TAREFA +"' AND "
cQuery	+= " AFU_RECURS = '"+ AJK->AJK_RECURS +"' AND "		
cQuery	+= " AFU_DATA = '" + Dtos(AJK->AJK_DATA)+"' AND "
cQuery	+= " AFU_HORAI = '" + AJK->AJK_HORAI +"' AND "
cQuery	+= " AFU_HORAF = '" + AJK->AJK_HORAF +"' AND "
cQuery	+= " AFU_HQUANT = " + Str(AJK->AJK_HQUANT) +" AND "
cQuery	+= " AFU_CTRRVS = '1' AND "
cQuery	+= " AFU_PREREC= '1' AND "
cQuery	+= " D_E_L_E_T_ = '' "
cQuery 	:= ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTemp, .T., .T.)
If !EOF()
	nRecNo := (cTemp)->R_E_C_N_O_   
Endif
DbCloseArea()
Return nRecno

/*/{Protheus.doc} RU44W71002_PMS710Sel
Mass operation on AJK
@type function
@version  R14
@author bsobieski
@since 23/08/2024
@param cOperation, character, Operation 2=Approve, 3= Reject, 1=Reversa approval/rejection
/*/
Function RU44W71002_PMS710Sel(cOperation)
Local nX
Local aError := {}
Local aSoluc := {}
Local aConfig
Local aOptions := {}
Local aConfig2 := { Space(TamSX3('AF8_PROJET')[1]),;
					Replicate('z', TamSX3('AF8_PROJET')[1]),;
					Space( TamSX3('AE8_RECURS')[1]),;
					Replicate('z', TamSX3('AE8_RECURS')[1]),;
					Space(TamSX3('AED_EQUIP')[1]),;
					Replicate('z', TamSX3('AED_EQUIP')[1]),;
					Ctod(''),;
					dDataBase}

aAdd(aOptions,{1,  STR0039,aConfig2[1],"","","AF8",".T.",65,.F.}) 
aAdd(aOptions,{1,  STR0040,aConfig2[2],"","","AF8",".T.",65,.F.}) 
aAdd(aOptions,{1,  STR0041,aConfig2[3],"","","AE8",".T.",65,.F.}) 
aAdd(aOptions,{1,  STR0042,aConfig2[4],"","","AE8",".T.",65,.F.}) 
aAdd(aOptions,{1,  STR0043,aConfig2[5],"","","AED",".T.",65,.F.}) 
aAdd(aOptions,{1,  STR0044,aConfig2[6],"","","AED",".T.",65,.F.}) 
aAdd(aOptions,{1,  STR0045,aConfig2[7],"","",""   ,".T.",50,.F.}) 
aAdd(aOptions,{1,  STR0046,aConfig2[8],"","",""   ,".T.",50,.F.}) 

If ParamBox(aOptions,STR0047,@aConfig2,,,,,,,"RU44W71002",,.T.) 

	//aParam := {MV_PAR01 ,MV_PAR02 ,MV_PAR03 ,MV_PAR04 ,MV_PAR05 ,MV_PAR06}
	aReturn := AJKSelect(cOperation, aConfig2[1],aConfig2[2], aConfig2[3], aConfig2[4], aConfig2[5],aConfig2[6],aConfig2[7], aConfig2[8])
	
	If Len(aReturn) > 0
		aConfig := {"",.F.}
		Do Case
			Case cOperation == "1"
				cOperDesc := STR0021
			Case cOperation == "2"
				cOperDesc := STR0003
			Case cOperation == "3"
				cOperDesc := STR0018
		EndCase
		aConfig[1] := I18n(STR0017,{cOperDesc})
		lRet:= ParamBox({	{11,aConfig[1],Space(400),,,},;
							{4,STR0024,aConfig[2],STR0020,40,,.F.}; //"Exibir detalhes :"###"Codigo"
					},cOperDesc+" "+ STR0031,aConfig,,,.F.,120,3)

		If lRet
			Processa({|| aError := RunApprovalRejection(aReturn,cOperation,aConfig)})
			If Len(aError) >0
				aSoluc := {}
				For nX:=1 To Len(aError)
					AAdd(aSoluc,aError[nX,1])
				Next
				Help(NIL, NIL, STR0048, NIL,I18n(STR0049, {Len(aError)}), 1, 0, NIL, NIL, NIL, NIL, NIL,aSoluc)
			Endif
		Endif
	EndIf
EndIf

Return NIL

/*/{Protheus.doc} AJKSelect
Select records from AJK to be approved, rejected or to revert approval/rejection
@type function
@version R14 
@author bsobieski
@since 23/08/2024
@param cOperation, character, Operation 2=Approve, 3= Reject, 1=Reversa approval/rejection
@param cProjFrom, character, Starting project for filter
@param cProjTo, character,  Finishing project for filter
@param cResFrom, character,  Starting resource for filter
@param cResTo, character, Finishing resource for filter
@param cTeamFrom, character,  Starting team for filter
@param cTeamTo, character, Finishing team for filter
@param dDateFrom, date,  Starting date for filter
@param dDateTo, date, Finishing date for filter
@return array, Array with records selected
/*/
Static Function AJKSelect(cOperation, cProjFrom,cProjTo, cResFrom, cResTo, cTeamFrom, cTeamTo , dDateFrom, dDateTo)
Local bKeyF5     := SetKey(VK_F5)
Local aButtons := {}
Local lConfirm := .F.
Local oDlg2
Local aFields    := {"AJK_DATA","AJK_HORAI","AJK_HORAF","AJK_HQUANT","AJK_RECURS", "AE8_DESCRI","AJK_PROJET", "AF8_DESCRI","AJK_TAREFA", "AF9_DESCRI","AE8_EQUIP", "AED_DESCRI", "AJK_REVISA"}
Local aFieldsSel  := {}
Local aStruct
Local nX
Local cFieldsFrom  := ""
Local cFieldsTo   := ""
Local cNewAlias  := GetNextAlias()
Local cAliasTMP  := GetNextAlias()
Local cFilterExp:=""
Local aRet := {}
Local cTitulo := ""
Local aArea := GetArea()
Local lInvert 	:= .F.
Local lRet 		:= .T.
Local lFilterClients := (SuperGetMV("MV_PMSPCLI", .F., 1) == 1 )
Local cQueryCli := ""
Local oMark
Local aAccesses := {}
//TODO: Do not Select records filtered
Private cFilter := ""
Private cApplied := Space(100)

If (lFilterClients)
	cQueryCli := 'SELECT AI4_CODCLI,AI4_LOJCLI FROM '+RetSqlName('AI4')+" AI4,"+RetSqlName('AI3')+" AI3 "
	cQueryCli += 'WHERE  AI3_CODUSU=AI4_CODUSU '
	cQueryCli += " AND  AI3_USRSIS='"+__cUserID+"' "
	cQueryCli += " AND  AI3_FILIAL='"+xFilial('AI3')+"' "
	cQueryCli += " AND  AI4_FILIAL='"+xFilial('AI4')+"' "
	cQueryCli += " AND  AI4.D_E_L_E_T_='' "
	cQueryCli += " AND  AI3.D_E_L_E_T_='' "
EndIf

aStruct := {{"MARK","C",2,0}}
aFieldsSel := {{"MARK",'',''}}
SX3->(DbSetOrder(2))
For nX:=1 To Len(aFields)
	SX3->(DbSeek(aFields[nX]))
	Do Case 
		Case aFields[nX] == "AF8_DESCRI"
			cTitulo := STR0007
		Case aFields[nX] == "AE8_DESCRI"
			cTitulo := STR0006
		Case aFields[nX] == "AF9_DESCRI"
			cTitulo := STR0005
		Case aFields[nX] == "AED_DESCRI"
			cTitulo := STR0009
		OtherWise
			cTitulo := X3Titulo()
	EndCase
   	cFieldsFrom += ","+aFields[nX]
   	aadd(aStruct,{aFields[nX], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
    aadd(aFieldsSel,{aFields[nX],'',cTitulo,SX3->X3_PICTURE})
	// [n][01] Descrição do campo
	// [n][02] Nome do campo
	// [n][03] Tipo
	// [n][04] Tamanho
	// [n][05] Decimal
	// [n][06] Picture
    //aadd(aFieldsSel,{cTitulo,aFields[nX],SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE})
    cFieldsTo   += ","+aFields[nX]
   	IF(SX3->X3_TIPO=='C')
      cFilterExp += ".OR. %FILTER% $ UPPER("+sx3->x3_campo+") "
   Endif
Next nX
aadd(aStruct,{'AJKRECNO', "N", 10, 0})

cFieldsFrom += ", AJK.R_E_C_N_O_"
cFieldsTo += ", AJKRECNO"

oTempTable := FWTemporaryTable():New( cNewAlias )
oTemptable:SetFields( aStruct )
oTempTable:AddIndex("1", {"AE8_DESCRI"} )
oTempTable:AddIndex("2", {"AF8_DESCRI"} )
oTempTable:AddIndex("3", {"AF9_DESCRI"} )
oTempTable:Create()

cQuery := "INSERT INTO " + oTempTable:GetRealName() + " ( " + Substr(cFieldsTo,2) + "  ) " 
cQuery += "	SELECT " + Substr(cFieldsFrom,2) + "  "
cQuery += "	FROM " + RetSqlTab('AJK')+ " , " + RetSqlTab('AF9')+ " , " + RetSqlTab('AF8')+ " , " + RetSqlTab('AE8')+ "  left join " + RetSqlTab('AED')
cQuery += "	on  AED.D_E_L_E_T_ = ' ' "
cQuery += "	AND AED.AED_FILIAL = '"+xFilial('AED')+"' "
cQuery += "	AND AED.AED_EQUIP = AE8.AE8_EQUIP "
cQuery += "	WHERE AJK.D_E_L_E_T_ = ' ' "
cQuery += "	AND AF8.D_E_L_E_T_ = ' ' "
cQuery += "	AND AF9.D_E_L_E_T_ = ' ' "
cQuery += "	AND AE8.D_E_L_E_T_ = '' "
cQuery += "	AND AJK_FILIAL = '"+xFilial('AJK')+"' "
cQuery += "	AND AJK_PROJET BETWEEN  '"+cProjFrom+"' AND '"+cProjTo+"'"
cQuery += "	AND AJK_RECURS BETWEEN  '"+cResFrom+"' AND '"+cResTo+"'"
cQuery += "	AND AJK_DATA BETWEEN  '"+Dtos(dDateFrom)+"' AND '"+Dtos(dDateTo)+"'"
cQuery += "	AND AF8_FILIAL = '"+xFilial('AF8')+"' "
cQuery += "	AND AF8_PROJET = AJK_PROJET "
cQuery += "	AND AF8_REVISA = AJK_REVISA "

cQuery += "	AND AE8_FILIAL = '"+xFilial('AE8')+"' "
cQuery += "	AND AE8_RECURS = AJK_RECURS "
cQuery += "	AND AE8_EQUIP BETWEEN  '"+cTeamFrom+"' AND '"+cTeamTo+"'"
cQuery += "	AND AF9_FILIAL = '"+xFilial('AF9')+"' "
cQuery += "	AND AF9_PROJET = AJK_PROJET "
cQuery += "	AND AF9_REVISA = AF8_REVISA "
cQuery += "	AND AF9_TAREFA = AJK_TAREFA "
cQuery += " AND AJK_CTRRVS = '1' "
If cOperation == '1'
	cQuery += "	AND AJK_SITUAC in ('2','3') "
ElseIf cOperation == '2'
	cQuery += "	AND AJK_SITUAC in (' ','1') "
ElseIf cOperation == '3'
	cQuery += "	AND AJK_SITUAC in (' ','1') "
Endif
If lFilterClients
	cQuery += " AND (AF8_CLIENT,AF8_LOJA) IN ("+cQueryCli+") "
EndIf

cQuery += "ORDER BY AJK_DATA, AJK_HORAI , AJK_HORAF "

If TcSqlExec( cQuery ) <> 0
   Help(" ",1,"PMSA710",, STR0050 + tcsqlerror(),1,0) 
   lRet := .F.
EndIf

If lRet
	(cNewAlias)->( dbGoTop())

	aSize := MSADVSIZE()
	DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0051) From aSize[7],0 To aSize[6],aSize[5] PIXEL  

	oDlg2:lMaximized := .T.
   	aCOORD := {100,100,123,316}
   	cMarcaTR := 'xx'
	// oMarkBrowse := FWMarkBrowse():New()
	// oMarkBrowse:SetTemporary(.T.)
	// oMarkBrowse:SetUseFilter(.T.)
	// oMarkBrowse:SetValid({|X| RecordCanBeSelected(x)})
	// oMarkBrowse:SetIgnoreARotina(.T.)
	// oMarkBrowse:SetFieldMark( 'MARK' )

	// oMarkBrowse:SetOwner(oDlg2)
	// oMarkBrowse:SetFields(aFieldsSel)
	// oMarkBrowse:SetAlias( cNewAlias )
	// oMarkBrowse:SetMark('xx', cNewAlias, "MARK")
	// oMarkBrowse:Activate()
	oMark:=MsSelect():New(cNewAlias,"MARK", Nil,aFieldsSel,,cMarcaTR,aCoord,,,,,)
	oMark:oBrowse:lhasMark := .T.
	oMark:oBrowse:lCanAllmark := .t.
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:REFRESH()
	oMark:bAval := {|| RecordMark(@aAccesses)}
	oMark:oBrowse:bAllMArk := {|| RecordAllMark(oMark,@aAccesses)}
	//oMark:oBrowse:bheaderclick:= {|oMark,nPosition| u_clicked(oMark,nPosition,oTempTable,aFieldsSel)}

	Aadd(aButtons,{'RECALC' ,{|| QuickSearch(cFilterExp,cNewAlias,oMark)},,OemToAnsi(STR0052)+"",STR0052})
   	SetKey(VK_F5,{|| QuickSearch(cFilterExp,cNewAlias,oMark) })
	
   ACTIVATE MSDIALOG oDlg2 ON INIT ( EnchoiceBar( oDlg2,{|| lConfirm:=.T., oDlg2:End()} , {|| oDlg2:End() },,aButtons )) CENTERED //"Deseja cancelar?"
	//lInvert := oMark:oBrowse:lAllmark
   If lConfirm
      cQuery := "SELECT AJKRECNO "
      cQuery += " from "+ oTempTable:GetRealName() 
      cQuery += " WHERE MARK "+iif(lInvert,"<>","=")+" '"+cMarcaTR+"'"
      MPSysOpenQuery( cQuery, cAliasTMP)
      while !(cAliasTMP)->(EOF())

         aadd(aRet, (cAliasTMP)->(AJKRECNO ))
         
         (cAliasTMP)->(dbSkip())
      Enddo
      DbSelectArea(cAliasTMP)
      dbCloseArea()
   Endif
Endif
oTempTable:Delete()
RestArea(aArea)
SetKey(VK_F5,bKeyF5)

Return aRet


/*/{Protheus.doc} QuickSearch
Quick search in selection 
@type Function
@author MA3  - Bruno Sobieski
@since 12/02/2020
/*/
Static Function QuickSearch(cFilterExp,cAlias, oMark)
Local aParams :={{1, STR0053     ,  cApplied ,  ,          "",        "", ".T.", 80,  .F.}}
Local cMV_par01 := MV_PAR01
MV_PAR01 := cApplied

If ParamBox(aParams,  STR0053,,,,,,, , , .F.,.F.)
   If !Empty(MV_PAR01)
      cFilter := Substr(Strtran(cFilterExp,"%FILTER%","'"+upper(ALLTRIM(MV_PAR01))+"'"),5)
      SET FILTER TO &CFILTER.
   Else
      SET FILTER TO
   Endif
   (cAlias)->(DbGoTop())
   oMark:oBrowse:GoTop()
   oMark:oBrowse:REFRESH()
  // RestArea(aArea)
   cApplied := MV_PAR01
Endif

mv_par01 := cMV_par01

Return
/*/{Protheus.doc} RecordMark
Mark a record checking access
@type function
@version  
@author bsobieski
@since 26/08/2024
@param aAccesses, array, Cahced accesses
@param lShowHelp, logical, Show help or not
/*/
Static Function RecordMark(aAccesses, lShowHelp)
Local lCanBeMarked := .T.
Default lShowHelp := .T.
If Empty(MARK)
	If (nPos := Ascan(aAccesses, {|x| x[1] == AJK_PROJET+ AJK_TAREFA+AJK_REVISA}))>0
		lCanBeMarked := aAccesses[nPos][2]
	Else
		lCanBeMarked := PmsChkUser(AJK_PROJET, AJK_TAREFA, NIL, "", 2, "APRPRE", AJK_REVISA, /*cUser*/, .F.)
		aadd(aAccesses, {AJK_PROJET+ AJK_TAREFA+AJK_REVISA, lCanBeMarked})
	Endif
Endif
If lCanBeMarked
	Reclock(alias(),.F.)
	MARK := IIf(MARK == 'xx', '', 'xx')
	MsUnLock()
Else
	If lShowHelp
		Help(NIL, NIL, STR0012, NIL, i18n(STR0019, { AJK_PROJET, AJK_TAREFA}), 1, 0, NIL, NIL, NIL, NIL, NIL,)
	Endif
Endif
Return 
/*/{Protheus.doc} RecordAllMark
Mark all records (not using lInvert because access needs to be checked record by record)
@type function
@version  R14
@author bsobieski
@since 26/08/2024
@param oMark, object, MsSelect Object
@param aAccesses, array, Accesses cache
/*/
Static Function RecordAllMark(oMark,aAccesses)
Local lRet := .t.
Local nRecno := RECNO()
DbGotop()
While !Eof()
	RecordMark(aAccesses, .F.)
	DbSkip()
Enddo
DbGoTo(nRecno)
Return lRet
                   
//Merge Russia R14 
                   
