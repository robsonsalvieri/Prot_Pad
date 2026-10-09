#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA900D.CH"

/*/{Protheus.doc} GTPA900D
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param nil, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA900D()
Local cMsgErro := ""

If G900DVldDic(@cMsgErro)  
    FwExecView(STR0001, "VIEWDEF.GTPA900D", MODEL_OPERATION_UPDATE,,{|| .T.},,50,,,,,) // "Cancelamento do Contrato"
Else
    FwAlertHelp(cMsgErro, STR0012) // "Banco de dados desatualizado, não será possível iniciar a rotina"
Endif

Return

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param nil, param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel    := Nil
Local oStruGY0  := FwFormStruct(1, "GY0") // Contrato
Local oStruGYN  := FwFormStruct(1, "GYN") // Viagens
Local bCommit	:= {|oModel| G900DCommit(oModel)}
Local bVldActiv := { |oModel| G900DVldAct(oModel)}
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }

oStruGY0:AddTrigger("GY0_DTCANC", "GY0_DTCANC", { || .T.}, bFldTrig)
If GY0->(FIELDPOS( "GY0_DTCANC" )) > 0 
    oStruGY0:SetProperty("GY0_DTCANC", MODEL_FIELD_VALID, bFldVld)
EndIf
oStruGYN:AddField("", "", "GYN_MARK" , "L", 1  , 0, NIL, NIL ,NIL, .F., { || .T.}, .F., .F., .T.)

oModel := MPFormModel():New("GTPA900D", /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
oModel:SetDescription(STR0001) // "Cancelamento do Contrato"

oModel:AddFields("GY0MASTER",,oStruGY0)
oModel:AddGrid("GYNDETAIL", "GY0MASTER", oStruGYN)

oModel:GetModel("GYNDETAIL"):SetMaxLine(999999)

oModel:SetPrimaryKey({"GY0_FILIAL","GY0_NUMERO","GY0_REVISA"})
If FWSIXUtil():ExistIndex( "GYN" , "A" )
    oModel:SetRelation("GYNDETAIL", {{"GYN_FILIAL",'xFilial("GYN")'}, {"GYN_CODGY0", "GY0_NUMERO"}}, GYN->(IndexKey(10)) )
Else 
    oModel:SetRelation("GYNDETAIL", {{"GYN_FILIAL",'xFilial("GYN")'}, {"GYN_CODGY0", "GY0_NUMERO"}})
EndIf 

oModel:GetModel("GYNDETAIL"):SetLoadFilter(,"GYN_FINAL = '2' AND GYN_CANCEL = '1'")

oModel:GetModel("GYNDETAIL"):SetOptional(.T.)
oModel:GetModel("GYNDETAIL"):SetOnlyQuery(.T.)

oModel:GetModel("GY0MASTER"):SetDescription(STR0002) // "Dados do Contrato"
oModel:GetModel("GYNDETAIL"):SetDescription(STR0003) // "Viagens não finalizadas do contrato"		

oModel:GetModel("GYNDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("GYNDETAIL"):SetNoDeleteLine(.T.)

oStruGYN:SetProperty("*",  MODEL_FIELD_NOUPD, .T.)
oStruGYN:SetProperty("GYN_MARK",  MODEL_FIELD_NOUPD, .F.)

oModel:SetVldActivate(bVldActiv)
oModel:SetCommit(bCommit)

Return oModel

/*/{Protheus.doc} G900DVldAct
(long_description)
@type  Static Function
@author flavio.martins
@since 31/10/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900DVldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !G900DVldDic(@cMsgErro)
    lRet := .F.
    cMsgSol := "Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G900DVldAct", cMsgErro, cMsgSol) 
Endif

Return lRet

/*/{Protheus.doc} FieldTrigger
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param uVal, param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldTrigger(oMdl,cField,uVal)

If cField == 'GY0_DTCANC' .And. !Empty(uVal)
    G900DFilt(oMdl)
Endif

Return uVal

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""
Local cDtApura  := ""

If cField == 'GY0_DTCANC'

    cDtApura := GetDtApura(oMdl:GetValue('GY0_NUMERO'))

    If uNewValue < oMdl:GetValue('GY0_DTINIC')
        lRet     := .F.
        cMsgErro := STR0010 // "Data do cancelamento não pode ser inferior a a data de início do contrato"
        cMsgSol  := STR0011 // "Selecione uma data maior ou igual a data de início do contrato"
    Endif

    If lRet .And. DtoS(uNewValue) < cDtApura 
        lRet     := .F.
        cMsgErro := STR0008 // "Data do cancelamento do contrato não pode ser inferior a data da última apuração"
        cMsgSol  := STR0009 // "Selecione uma data maior ou igual a data da última apuração"
    Endif

Endif 

If !lRet
    oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param oView, param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel('GTPA900D')
Local oStruGY0	:= FwFormStruct(2,'GY0', {|cCampo| AllTrim(cCampo)+ "|" $ "GY0_NUMERO|GY0_REVISA|GY0_DTINIC|GY0_CLIENT|GY0_LOJACL|GY0_DTCANC|GY0_OBSCAN|"})
Local oStruGYN 	:= FwFormStruct(2,'GYN', {|cCampo| AllTrim(cCampo)+ "|" $ "GYN_CODIGO|GYN_LINCOD|GYN_DTINI|GYN_HRINI|GYN_DTFIM|GYN_HRFIM|"})

oStruGY0:AddGroup("DADOS", "", "" , 2)
oStruGY0:SetProperty("*" ,MVC_VIEW_GROUP_NUMBER, "DADOS")

oStruGY0:AddGroup("CANCELA", "Dados do Cancelamento", "" , 2)
oStruGY0:SetProperty("GY0_DTCANC" ,MVC_VIEW_GROUP_NUMBER, "CANCELA")
oStruGY0:SetProperty("GY0_OBSCAN" ,MVC_VIEW_GROUP_NUMBER, "CANCELA")

oStruGYN:AddField("GYN_MARK", "00", "", "", NIL, "L", "", NIL, Nil, .T., NIL, NIL, Nil, NIL, NIL, .T., NIL)

oView := FwFormView():New()
oView:SetModel(oModel)
oView:SetDescription(STR0001) // "Cancelamento do Contrato"
oView:AddField('VIEW_HEADER', oStruGY0, 'GY0MASTER')
oView:AddGrid('VIEW_DETAIL' , oStruGYN, 'GYNDETAIL')

oView:CreateVerticalBox('HEADER', 50)
oView:CreateVerticalBox('DETAIL', 50)

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_DETAIL','DETAIL')

oView:EnableTitleView("VIEW_HEADER", STR0002)   // "Dados do Contrato"	
oView:EnableTitleView("VIEW_DETAIL", STR0003)   // "Viagens não finalizadas do contrato"

//oView:SetViewProperty("GY0MASTER", "SETLAYOUT", {FF_LAYOUT_HORZ_DESCR_TOP , 4 } )

Return oView

/*/{Protheus.doc} GetDtApura
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@return cDtApura, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GetDtApura(cCodContr)
Local cDtApura  := ''
Local cAliasTmp := GetNextAlias()

BeginSql Alias cAliasTmp

    SELECT COALESCE(MAX(GQR.GQR_DTFINA), '') AS GQR_DTFINA
    FROM %Table:G9W% G9W
    INNER JOIN %Table:GQR% GQR ON GQR.GQR_FILIAL = %xFilial:GQR%
    AND GQR.GQR_CODIGO = G9W.G9W_CODGQR
    AND GQR.%NotDel%
    WHERE G9W.G9W_FILIAL = %xFilial:G9W%
      AND G9W.G9W_NUMGY0 = %Exp:cCodContr%
      AND G9W.%NotDel%

EndSql

cDtApura := (cAliasTmp)->GQR_DTFINA

(cAliasTmp)->(dbCloseArea())

Return cDtApura

/*/{Protheus.doc} G900DFilt
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param nil, param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900DFilt(oMdl)
Local oModel    := oMdl:GetModel()
Local cDtCanc   := DtoS(oModel:GetModel("GY0MASTER"):GetValue("GY0_DTCANC"))
Local oView     := FwViewActive()

oModel:DeActivate()
oModel:GetModel("GYNDETAIL"):SetLoadFilter(, "GYN_FINAL = '2' AND GYN_CANCEL = '1' AND GYN_DTINI >= '" + cDtCanc + "'")
oModel:Activate()

oModel:GetModel("GY0MASTER"):LoadValue('GY0_DTCANC',  StoD(cDtCanc))

oView:Refresh()

Return

/*/{Protheus.doc} G900DCommit
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param nil, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900DCommit(oModel)
Local lRet    := .T.
Local cCodCN9 := oModel:GetValue('GY0MASTER', 'GY0_CODCN9') 
Local cRevCN9 := oModel:GetValue('GY0MASTER', 'GY0_REVISA') 

FwMsgRun(,{|| lRet := CancelaGCT(cCodCN9, cRevCN9)}, STR0004, STR0006) // "Solicitando cancelamento do contrato no GCT...") //"Aguarde", "Solicitando cancelamento do contrato no GCT..."

If lRet
    oModel:SetValue('GY0MASTER', 'GY0_STATUS', '3')
    oModel:SetValue('GY0MASTER', 'GY0_USUCAN', __cUserId)

    FwMsgRun(,{|| lRet := G900ExcVia(oModel)}, STR0004, STR0005) //"Aguarde", "Excluindo viagens não finalizadas do contrato..."
Else
    FwAlertWarning(STR0007) // "Não foi possível cancelar o contrato no GCT", "Atenção"

Endif
        
If lRet .And. oModel:VldData()
    FwFormCommit(oModel)
Endif

Return lRet

/*/{Protheus.doc} CancelaGCT
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param nil, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function CancelaGCT(cCodCN9,cRevCN9)
Local lRet := .F.

CN9->(dbSetOrder(1))

If CN9->(dbSeek(xFilial("CN9") + cCodCN9 + cRevCN9))
	lRet := CN100SitCh(CN9->CN9_NUMERO,CN9->CN9_REVISA,"01",,.F.)
Endif

Return lRet

/*/{Protheus.doc} G900ExcVia
(long_description)
@type  Static Function
@author flavio.martins
@since 26/10/2022
@version 1.0
@param nil, param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900ExcVia(oModel)
Local lRet    := .T.
Local oMdl300 := FwLoadModel('GTPA300')
Local nX      := 0

dbSelectArea("GYN")
GYN->(dbSetOrder(1))

For nX := 1 To oModel:GetModel('GYNDETAIL'):Length()

     oModel:GetModel("GYNDETAIL"):GoLine(nX)

    If oModel:GetValue("GYNDETAIL", "GYN_MARK")

        If GYN->(dbSeek(xFilial('GYN')+oModel:GetValue("GYNDETAIL", "GYN_CODIGO")))

            oMdl300:DeActivate()
            oMdl300:SetOperation(MODEL_OPERATION_DELETE)
            oMdl300:Activate()

            If oMdl300:VldData()
                oMdl300:CommitData()
            Endif        

        Endif

    Endif

Next

If oMdl300:IsActive()
    oMdl300:DeActivate()
Endif

Return lRet

/*/{Protheus.doc} G900DVldDic
(long_description)
@type  Static Function
@author flavio.martins
@since 31/10/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G900DVldDic(cMsgErro)
Local lRet          := .T.
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'GY0_DTCANC','GY0_USUCAN','GY0_OBSCAN'}

If Empty(cMsgErro)
	For nX := 1 To Len(aFields)
	    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
	        lRet := .F.
	        cMsgErro := I18n(STR0013, {aFields[nX]}) // "Campo #1 não se encontra no dicionário"
	        Exit
	    Endif
	Next
EndIf

Return lRet
