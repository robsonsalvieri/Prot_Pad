#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU015B.CH'

/*/{Protheus.doc} GTPU015B
(long_description)
@type  Static Function
@author flavio.martins
@since 18/06/2024
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPU015B()
Local cCodLocal := H7P->H7P_CODH7M

    If GTPUVldAut(cCodLocal, "GTPU015")
    
        FwMsgRun(, {|| FwExecView(STR0001, "VIEWDEF.GTPU015B",MODEL_OPERATION_UPDATE,,{|| .T.})},"", STR0002) // "Conferência", "Carregando as informações..."

    Endif

Return Nil

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 18/06/2024
@version 1.0@param , param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oModel	 := FwLoadModel('GTPU015')
Local oView		 := FwFormView():New()
Local oStruH7PH	 := FwFormStruct(2, 'H7P',{|x| AllTrim(x) $ 'H7P_CODIGO|H7P_STATUS|H7P_DTFECH|H7P_CODH7M|H7P_DSCH7M|'})
Local oStruH7PT	 := FwFormStruct(2, 'H7P',{|x| !AllTrim(x) $ 'H7P_CODIGO|H7P_STATUS|H7P_DTFECH|H7P_CODH7M|H7P_DSCH7M|H7P_DINDSP|H7P_DINENV|H7P_DINACM|'})
Local cFieldsH7Q := 'H7Q_CONFER|H7Q_CODH7O|H7Q_DSCH7O|H7Q_VALOR|H7Q_DTINI|H7Q_DTFIM|H7Q_DOCIDT|H7Q_QTDPAR|H7Q_JUSTIF|H7Q_CODBCO|H7Q_AGEBCO|H7Q_CTABCO|'
Local oStruH7QR  := FWFormStruct(2, "H7Q",{|x| AllTrim(x) $ cFieldsH7Q})
Local oStruH7QD  := FWFormStruct(2, "H7Q",{|x| AllTrim(x) $ cFieldsH7Q}) 
Local bDblClick  := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}
Local nX         := 0

oView:SetModel(oModel)

oView:SetDescription(STR0004) // "Conferência do Caixa"

oStruH7QR:SetProperty("H7Q_CODH7O",MVC_VIEW_LOOKUP,"H7OREC")
oStruH7QD:SetProperty("H7Q_CODH7O",MVC_VIEW_LOOKUP,"H7ODES")

oStruH7QR:AddField("ANEXO","01",STR0003,STR0003,{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
oStruH7QD:AddField("ANEXO","01",STR0003,STR0003,{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"

For nX := 1 To Len(StrToKarr(cFieldsH7Q,"|"))
    oStruH7QR:SetProperty(StrToKarr(cFieldsH7Q,"|")[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
    oStruH7QD:SetProperty(StrToKarr(cFieldsH7Q,"|")[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next


oView:AddField('VIEW_HEADER', oStruH7PH, 'H7PMASTER')
oView:AddField('VIEW_TOTAL', oStruH7PT, 'H7PMASTER')
oView:AddGrid('VIEW_H7QRECEITA', oStruH7QR, 'H7QRECEITA')
oView:AddGrid('VIEW_H7QDESPESA', oStruH7QD, 'H7QDESPESA')

oView:CreateHorizontalBox('VIEWTOP', 25)
oView:CreateHorizontalBox('VIEWGRID', 55)
oView:CreateHorizontalBox('VIEWBOTTOM', 20)

oView:CreateVerticalBox('GRIDREC',49,'VIEWGRID')
oView:CreateVerticalBox('GRID_SEP',2,'VIEWGRID')
oView:CreateVerticalBox('GRIDDES',49,'VIEWGRID')

oView:SetOwnerView('VIEW_HEADER', 'VIEWTOP')
oView:SetOwnerView('VIEW_TOTAL', 'VIEWBOTTOM')
oView:SetOwnerView('VIEW_H7QRECEITA', 'GRIDREC')
oView:SetOwnerView('VIEW_H7QDESPESA', 'GRIDDES')

oView:EnableTitleView("VIEW_HEADER", STR0005) // "Dados do Caixa"
oView:EnableTitleView("VIEW_TOTAL", STR0006) // Totais do Caixa"
oView:EnableTitleView("VIEW_H7QRECEITA", STR0007) // "Receitas"
oView:EnableTitleView("VIEW_H7QDESPESA", STR0008) // "Despesas"

oView:SetViewProperty("VIEW_H7QRECEITA", "GRIDDOUBLECLICK", bDblClick)
oView:SetViewProperty("VIEW_H7QDESPESA", "GRIDDOUBLECLICK", bDblClick)

oStruH7PH:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStruH7PT:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStruH7QR:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStruH7QD:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

oStruH7QR:SetProperty('H7Q_CONFER', MVC_VIEW_CANCHANGE, .T.)
oStruH7QD:SetProperty('H7Q_CONFER', MVC_VIEW_CANCHANGE, .T.)

oView:SetNoDeleteLine('VIEW_H7QRECEITA')
oView:SetNoDeleteLine('VIEW_H7QDESPESA')
oView:SetNoInsertLine('VIEW_H7QRECEITA')
oView:SetNoInsertLine('VIEW_H7QDESPESA')

oView:AddUserButton(STR0009, "", {|oView| ConfereTudo(oView)},,,,.T.) // "Confere Tudo"

Return oView

/*/{Protheus.doc} SetDblClick(oGrid,cField,nLineGrid,nLineModel)
(long_description)
@type  Static Function
@author flavio.martins
@since 14/06/2024
@version 1.0@param , param_type, param_descr
@return nil
@example
(examples)
@see (links_or_references)
/*/
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Local oView := FwViewActive()

If cField == 'ANEXO'
    AttachDocs(oView, oGrid)
Endif

Return .T.

/*/{Protheus.doc} AttachDocs(oView, oGrid)
(long_description)
@type  Static Function
@author flavio.martins
@since 14/06/2024
@version 1.0@param , param_type, param_descr
@return nil
@example
(examples)
@see (links_or_references)
/*/
Static Function AttachDocs(oView, oGrid)
Local nRecno   :=  0 
Local aRecACB  := {}
Local nRecnoAC9 := 0

If oGrid:cViewId == 'VIEW_H7QRECEITA'
    nRecno := oView:GetModel():GetModel('H7QRECEITA'):GetDataId()
Else 
    nRecno := oView:GetModel():GetModel('H7QDESPESA'):GetDataId()
Endif

If nRecno == 0
    FwAlertHelp(STR0010, STR0011) // "Atenção", "Grave o registro antes de anexar o documento"
Else

    MsDocument('H7Q', H7Q->(nRecno), 1,,,@aRecACB)

    nRecnoAC9 := AC9->(RecNo())

    If oGrid:cViewId == 'VIEW_H7QRECEITA'
        oView:GetModel():GetModel('H7QRECEITA'):LoadValue("ANEXO", SetIniFld())
        oView:GetModel():GetModel('H7QRECEITA'):LoadValue("AC9RECNO", nRecnoAC9)
    Else
        oView:GetModel():GetModel('H7QDESPESA'):LoadValue("ANEXO", SetIniFld())
    //    oView:GetModel():GetModel('H7QRECEITA'):LoadValue("AC9RECNO", nRecnoAC9)
    Endif

    oView:Refresh()

Endif

Return 

/*/{Protheus.doc} SetIniFld()
(long_description)
@type  Static Function
@author flavio.martins
@since 14/06/2024
@version 1.0@param , param_type, param_descr
@return cValor
@example
(examples)
@see (links_or_references)
/*/
Static Function SetIniFld()
Local cValor := ''

AC9->(dbSetOrder(2))

If AC9->(dbSeek(xFilial('AC9')+'H7Q'+xFilial('H7Q')+xFilial('H7Q')+H7Q->H7Q_CODIGO))
    cValor := "F5_VERD"
Else
    cValor := 'F5_VERM'
Endif

Return cValor

/*/{Protheus.doc} ConfereTudo(oView)
(long_description)
@type  Static Function
@author flavio.martins
@since 18/06/2024
@version 1.0@param , param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ConfereTudo(oView)
Local oModel := oView:GetModel()
Local nX     := 0

For nX := 1 To oModel:GetModel('H7QRECEITA'):Length() 

    oModel:GetModel('H7QRECEITA'):GoLine(nX)
    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_CONFER', '2')
    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_DTCONF', dDataBase)
    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_USUCON', __cUserId)

Next

For nX := 1 To oModel:GetModel('H7QDESPESA'):Length() 

    oModel:GetModel('H7QDESPESA'):GoLine(nX)
    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_CONFER', '2')
    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_DTCONF', dDataBase)
    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_USUCON', __cUserId)

Next

oModel:GetModel('H7QRECEITA'):GoLine(1)
oModel:GetModel('H7QDESPESA'):GoLine(1)

Return
