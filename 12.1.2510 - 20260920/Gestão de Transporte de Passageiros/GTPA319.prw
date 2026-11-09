#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA319.CH'

/*/{Protheus.doc} GTPA319
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA319()
Local cMsgErro := ''

If GA319VlDic(@cMsgErro)
    FwExecView(STR0001,"VIEWDEF.GTPA319",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/, 5,/*aButtons*/, {||.T.}/*bCancel*/,,,) // "Contratos de Viagens Especiais - Aprovação Operacional"
Else
    FwAlertHelp(cMsgErro, "Atualize o dicionário para utilizar esta rotina",) //"Atualize o dicionário para utilizar esta rotina"
Endif

Return

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormModelStruct():New() 
Local oStruG6R  := FwFormStruct(1, "G6R")
Local bLoad		:= {|oModel| GA319BLoad(oModel)}
Local bLnPost	:= {|oModel| GA319LnPos(oModel)}
Local bVldActiv := {|oModel| G319VldAct(oModel)}

oModel := MPFormModel():New("GTPA319",/*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

SetMdlStru(oStruCab, oStruG6R)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid("GRID", "HEADER", oStruG6R,,bLnPost,,,)
oModel:SetRelation('GRID' ,{{'G6R_FILIAL' , 'xFilial("G6R")'}},  G6R->(IndexKey(1)))
oModel:GetModel("GRID"):SetLoadFilter(, "G6R_APRVOP = '2'")

oModel:SetDescription(STR0001) // "Contratos de Viagens Especiais - Aprovação Operacional"
oModel:GetModel("HEADER"):SetDescription("Header")
oModel:GetModel("GRID"):SetDescription(STR0002) //"Contratos"
oModel:SetPrimaryKey({})

oModel:GetModel("GRID"):SetMaxLine(99999)	

oModel:GetModel('GRID'):SetNoDeleteLine(.T.)
oModel:GetModel('GRID'):SetNoInsertLine(.T.)

oModel:SetVldActivate(bVldActiv)

Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA319")
Local cFields 	:= "|G6R_CODIGO|G6R_NROPOR|G6R_SA3COD|G6R_SA3DES|G6R_LOCORI|G6R_DESORI|G6R_POLTR|G6R_EIXOS|G6R_DTIDA|G6R_HRIDA|G6R_DTVLTA|G6R_HRVLTA|G6R_KMCONT|G6R_QUANT|G6R_JUSRPV"
Local aFields   := StrToKarr(cFields, "|")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruG6R	:= FwFormStruct(2, "G6R", {|cCampo|  AllTrim(cCampo) $ cFields}) 
Local nX 		:= 0

// Cria o objeto de View
oView := FwFormView():New()

SetViewStru(oStruCab, oStruG6R)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0003) // "Contratos de Turismo"

//oView:AddField('VIEW_HEADER' ,oStruCab,'HEADER')
oView:AddGrid('VIEW_GRID', oStruG6R, 'GRID')

//oView:CreateHorizontalBox('HEADER', 35)
oView:CreateHorizontalBox('GRID', 100)

//oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_GRID','GRID')

//oView:EnableTitleView("VIEW_HEADER", "")
oView:EnableTitleView("VIEW_GRID", STR0002) // "Contratos"

oView:AddIncrementalField('VIEW_GRID','SEQ')

oView:AddUserButton(STR0004, "", {|oView| FwMsgRun(,{|| GA319Pesq(oView)},,STR0008)},/*cToolTip*/ ,VK_F5/*nShortCut*/) // "Recursos Disponíveis <F5>", "Pesquisando Recursos..."

oView:GetViewObj("VIEW_GRID")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_GRID")[3]:SetFilter(.T.)

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowUpdateMsg(.F.)

For nX := 1 To Len(aFields)
    oStruG6R:SetProperty(aFields[nX], MVC_VIEW_ORDEM , StrZero(nX,2))

    If !(aFields[nX] $ 'APROV|G6R_JUSRPV')
        oStruG6R:SetProperty(aFields[nX], MVC_VIEW_CANCHANGE, .F.)	
    Endif

Next

Return(oView)

/*/{Protheus.doc} SetMdlStru
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMdlStru(oStruCab, oStruGrd)
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

oStruGrd:AddField(STR0005,STR0005,  "APROV", "C", 1, 0, {|| .T.},{|| .T.},{STR0006, STR0007},.F.,NIL,.F.,.F.,.T.) // "Ação"

oStruGrd:AddTrigger("APROV","APROV",{ || .T. }, bFldTrig)
	
Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param oStruct , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruCab, oStruGrd)

oStruGrd:AddField("APROV", "00", STR0005, STR0005,{""},"COMBO","",NIL,"",.T.,NIL,NIL,{STR0006, STR0007},NIL,NIL,.F.) // "Ação", "1=Aprovar","2=Reprovar"

Return

/*/{Protheus.doc} FieldTrigger
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldTrigger(oMdl, cField, uVal)

If cField == 'APROV'

    If uVal == '1'
        oMdl:LoadValue('G6R_APRVOP', '3')
        oMdl:ClearField('G6R_JUSRPV')
    Else
        oMdl:LoadValue('G6R_APRVOP', '4')
    Endif

    oMdl:LoadValue('G6R_USUAPR', AllTrim(RetCodUsr()))
    oMdl:LoadValue('G6R_DTAPRV', FwTimeStamp(2))

Endif

Return uVal

/*/{Protheus.doc} GA319BLoad
(long_description)
@type  Static Function
@author flavio.martins
@since 04/10/2022
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA319BLoad(oModel)
Local oMdlCab := oModel:GetModel('HEADER')

Return 

/*/{Protheus.doc} GA319LnPos(oModel)
(long_description)
@type  Static Function
@author flavio.martins
@since 05/10/2022
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA319LnPos(oModel)
Local lRet := .T.

If oModel:GetValue('APROV') == '2' .And. Empty(oModel:GetValue('G6R_JUSRPV'))
    lRet := .F.
    oModel:GetModel():SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GA319LnPos", STR0009) // "Informe a justificativa para a reprovação do contrato"

Endif

Return lRet

/*/{Protheus.doc} GA319Pesq
//TODO Descrição auto-gerada.
@author flavio.martins
@since 04/10/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA319Pesq(oView)
Local lRet 			:= .T.

GTPA319A(oView:GetModel())

Return lRet

/*/{Protheus.doc} G319VldAct(oModel)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 05/10/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function G319VldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !GA319VlDic(@cMsgErro)
    lRet := .F.
    cMsgSol :=  "Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G319VldAct", cMsgErro, cMsgSol) 
Endif

Return lRet

/*/{Protheus.doc} GA319VlDic
(long_description)
@type  Static Function
@author flavio.martins
@since 06/10/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GA319VlDic(cMsgErro)
Local lRet          := .T.
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'G6R_APRVOP','G6R_USUAPR','G6R_DTAPRV','G6R_JUSRPV'}

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
