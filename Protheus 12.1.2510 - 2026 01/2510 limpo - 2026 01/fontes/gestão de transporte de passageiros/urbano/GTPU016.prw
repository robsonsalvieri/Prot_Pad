#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU016.CH'

/*/{Protheus.doc} GTPU016
(long_description)
@type  Static Function
@author flavio.martins
@since 25/06/2024
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPU016()
Local oBrowse   := Nil
Local cMsgErro  := ''

If GU016VldDic(@cMsgErro)   

    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias('H7M')
    oBrowse:SetDescription(STR0001) // "Locais de Arrecadação"
    oBrowse:Activate()
Else
    FwAlertHelp(cMsgErro, STR0002) // "Banco de dados desatualizado, não será possível iniciar a rotina"
Endif

Return Nil

/*/{Protheus.doc} MenuDef
(long_description)
@type  Static Function
@author flavio.martins
@since 25/06/2024
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}
	
ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.GTPU016' OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina TITLE "Incluir" ACTION 'VIEWDEF.GTPU016' OPERATION 3 ACCESS 0	//'Incluir'
ADD OPTION aRotina TITLE "Alterar" ACTION 'VIEWDEF.GTPU016' OPERATION 4 ACCESS 0	//'Alterar'
ADD OPTION aRotina TITLE "Excluir" ACTION 'VIEWDEF.GTPU016' OPERATION 5 ACCESS 0	//'Excluir'
	    
Return aRotina

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 25/06/2024
@version 1.0@param , param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	 := Nil
Local oStruH7M	 := FwFormStruct(1,'H7M')
Local oStruH7N	 := FwFormStruct(1,'H7N')
Local bFieldTrig := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

oStruH7M:AddTrigger("H7M_LOJCLI", "H7M_LOJCLI", {||.T.}, bFieldTrig)
oStruH7M:AddTrigger("H7M_LOJFOR", "H7M_LOJFOR", {||.T.}, bFieldTrig)
oStruH7M:AddTrigger("H7M_CODGI1", "H7M_CODGI1", {||.T.}, bFieldTrig)
oStruH7N:AddTrigger("H7N_COD", "H7N_COD", {||.T.}, bFieldTrig)

oModel := MPFormModel():New('GTPU016', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| GU016VldAct(oModel)})

oModel:AddFields('H7MMASTER',/*cOwner*/,oStruH7M)
oModel:AddGrid('H7NDETAIL', 'H7MMASTER', oStruH7N, /*bPre*/, /*bLinePost*/, /*bPre*/) 

oModel:SetRelation('H7NDETAIL', {{'H7N_FILIAL', 'xFilial( "H7N")'},{'H7N_CODLOC', 'H7M_COD'}}, H7N->(IndexKey(1)))

oModel:GetModel('H7NDETAIL'):SetOptional(.T.)

oModel:SetDescription(STR0001) // "Locais de Arrecadação"
oModel:GetModel('H7MMASTER'):SetDescription(STR0001) // "Locais de Arrecadação"
		
Return oModel

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 25/06/2024
@version 1.0@param , param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oModel	:= ModelDef()
Local oView		:= FwFormView():New()
Local oStruH7M	:= FwFormStruct(2, 'H7M')
Local oStruH7N	:= FwFormStruct(2, 'H7N',{|x| AllTrim(x) $ 'H7N_COD|H7N_NOMUSR|H7N_CDPRES|H7N_CDAPEN|H7N_CDPREV|H7N_CDFECH|H7N_CDCONF|'}) 

oView:SetModel(oModel)

oView:SetDescription(STR0001) // "Locais de Arrecadação"

oView:AddField('VIEW_HEADER', oStruH7M,'H7MMASTER')
oView:AddGrid('VIEW_GRID', oStruH7N, 'H7NDETAIL')

oView:CreateHorizontalBox('VIEWHEADER', 70)
oView:CreateHorizontalBox('VIEWGRID', 30)

oView:SetOwnerView('VIEW_HEADER', 'VIEWHEADER')
oView:SetOwnerView('VIEW_GRID', 'VIEWGRID')

//oView:EnableTitleView("VIEW_HEADER","Dados do Local de Arrecadação") 
oView:EnableTitleView("VIEW_GRID", STR0003) // "Usuários"

oStruH7M:AddGroup('GRP001', '','', 2)
oStruH7M:AddGroup('GRP002', STR0004,'', 2) // "Endereço"
oStruH7M:AddGroup('GRP003', STR0005,'', 2) // "Dados Financeiros"

oStruH7M:SetProperty('H7M_COD', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruH7M:SetProperty('H7M_DESC', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruH7M:SetProperty('H7M_STATUS', MVC_VIEW_GROUP_NUMBER, 'GRP001')

oStruH7M:SetProperty('H7M_CODGI1', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruH7M:SetProperty('H7M_DSCGI1', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruH7M:SetProperty('H7M_END', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruH7M:SetProperty('H7M_COMP', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruH7M:SetProperty('H7M_CEP', MVC_VIEW_GROUP_NUMBER, 'GRP002')

oStruH7M:SetProperty('H7M_CODFOR', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStruH7M:SetProperty('H7M_LOJFOR', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStruH7M:SetProperty('H7M_NOMFOR', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStruH7M:SetProperty('H7M_CODCLI', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStruH7M:SetProperty('H7M_LOJCLI', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStruH7M:SetProperty('H7M_NOMCLI', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStruH7M:SetProperty('H7M_BANCO', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStruH7M:SetProperty('H7M_AGENCI', MVC_VIEW_GROUP_NUMBER, 'GRP003')
oStruH7M:SetProperty('H7M_CONTA', MVC_VIEW_GROUP_NUMBER, 'GRP003')

Return oView

/*/{Protheus.doc} FieldTrigger()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 25/06/2024
@version 1.0
@return uVal
@type function
/*/
Static Function FieldTrigger(oMdl, cField, uVal)

If cField == 'H7M_LOJCLI'
    oMdl:SetValue("H7M_NOMCLI", Posicione('SA1', 1, xFilial('SA1')+oMdl:GetValue('H7M_CODCLI')+uVal,'A1_NREDUZ'))
ElseIf cField == 'H7M_LOJFOR'    
    oMdl:SetValue("H7M_NOMFOR", Posicione('SA2', 1, xFilial('SA2')+oMdl:GetValue('H7M_CODFOR')+uVal,'A2_NREDUZ'))
ElseIf cField == 'H7M_CODGI1'
    oMdl:SetValue("H7M_DSCGI1", Posicione('GI1', 1, xFilial('GI1')+uVal,'GI1_DESCRI'))
ElseIf cField == 'H7N_COD'
    oMdl:SetValue("H7N_NOMUSR", UsrRetName(uVal))
Endif

Return uVal

/*/{Protheus.doc} GU016VldAct
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GU016VldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !GU016VldDic(@cMsgErro)
    lRet := .F.
    cMsgSol :=  STR0006 // "Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GU016VldAct", cMsgErro, cMsgSol) 
    Return .F.
Endif

Return lRet

/*/{Protheus.doc} GU016VldDic
(long_description)
@type  Static Function
@author flavio.martins
@since 25/06/2024
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GU016VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'H7M','H7N'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'H7M_COD','H7M_DESC','H7M_STATUS','H7M_END','H7M_COMP','H7M_CODFOR',;
            'H7M_LOJFOR','H7M_CODCLI','H7M_LOJCLI','H7M_BANCO','H7M_AGENCI',;
            'H7M_CONTA','H7N_CODLOC','H7N_COD','H7N_STATUS','H7N_CDPRES',;
            'H7N_CDAPEN','H7N_CDPREV','H7N_CDFECH','H7N_CDCONF'}

For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

If Empty(cMsgErro)
	For nX := 1 To Len(aFields)
	    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
	        lRet := .F.
	        cMsgErro := I18n("Campo #1 não se encontra no dicionário",{aFields[nX]})
	        Exit
	    Endif
	Next
EndIf

Return lRet
