#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU01D08.CH"

/*/{Protheus.doc} RU01D08()
    This function needed for maintaince transport types records

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/07/11
    @version 12.1.33
    @example RU01D08()
*/
Function RU01D08()
    Local lRet As Logical
    Local oBrowse As Object
    Private aRotina := MenuDef()

    lRet := .T.

    oBrowse := BrowseDef()
    oBrowse:Activate()
Return(lRet)

/*/{Protheus.doc} BrowseDef()
    This function activate MVC

    @type Static Function
    @return oBrowse

    @author Dmitry Borisov
    @since 2023/07/11
    @version 12.1.33
    @example BrowseDef()
*/
Static Function BrowseDef()
    Local oBrowse As Object

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SN1")
    oBrowse:SetDescription(STR0001)
Return oBrowse

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRotina

    @author Dmitry Borisov
    @since 2023/07/11
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRotina := {}

    aAdd( aRotina, {STR0002, "VIEWDEF.RU01D08", 0, MODEL_OPERATION_VIEW  , 0, Nil} ) // View
    aAdd( aRotina, {STR0004, "VIEWDEF.RU01D08", 0, MODEL_OPERATION_UPDATE, 0, Nil} ) // Edit	

Return aRotina

/*/{Protheus.doc} ModelDef()
    This function prepare Model object from MVC

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2023/07/11
    @version 12.1.33
    @example ModelDef()
*/
Static Function ModelDef()
    Local oModel As Object
    Local oStrSN1 := FWFormStruct(1, "SN1")
    Local oStrF59 := FWFormStruct(1, "F59")
    Local aRelat  := {}
    Local oModelEv As Object

    oModel := MPFormModel():New("RU01D08",,,)
    oModel:AddFields("SN1_MASTER", Nil, oStrSN1)
    oModel:AddGrid("F59DETAIL", "SN1_MASTER", oStrF59)
    oModel:SetPrimaryKey({'F59_FILIAL', 'F59_CBASE', 'F59_ITEM', 'F59_BEGDAT', 'F59_ENDDAT','F59_PRTYPE','F59_PROKT1',;
    'F59_PROKT2','F59_PROKT3','F59_PROKT4','F59_PRNTAX'})

    aAdd(aRelat, {"F59_FILIAL", "XFILIAL('F59')"})
    aAdd(aRelat, {"F59_CBASE", "N1_CBASE"})
    aAdd(aRelat, {"F59_ITEM", "N1_ITEM"})

    oModel:SetRelation( 'F59DETAIL', aRelat , F59->(IndexKey(1)))
    oModelEv 	:= RU01D08EventRUS():New()
    oModel:InstallEvent("oModelEv", /*cOwner*/, oModelEv)

Return(oModel)

/*/{Protheus.doc} ViewDef()
    This function prepare View object from MVC

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2023/07/11
    @version 12.1.33
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView As Object
    Local oStrSN1 As Object
    Local oModel  := FwLoadModel("RU01D08")
    Local oStrF59 := FWFormStruct(2, "F59")
    Local cFieldsSN1 := "N1_FILIAL;N1_CBASE;N1_ITEM;N1_DESCRIC;"

    oStrSN1 := FWFormStruct(2, "SN1", {|x| (AllTrim(x) + ";" $ cFieldsSN1)}, .F.)

    oStrSN1:SetProperty('N1_FILIAL' ,MVC_VIEW_CANCHANGE,.F.)
    oStrSN1:SetProperty('N1_CBASE'  ,MVC_VIEW_CANCHANGE,.F.)
    oStrSN1:SetProperty('N1_ITEM'   ,MVC_VIEW_CANCHANGE,.F.)
    oStrSN1:SetProperty('N1_DESCRIC',MVC_VIEW_CANCHANGE,.F.)

    oStrF59:RemoveField('F59_CBASE')
    oStrF59:RemoveField('F59_ITEM')
    oStrF59:RemoveField('F59_FILIAL')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_SN1", oStrSN1, "SN1_MASTER")
    oView:AddGrid( "VIEW_F59", oStrF59, "F59DETAIL")
    oView:CreateHorizontalBox( 'BOXSN1', 020)
    oView:CreateHorizontalBox( 'BOXF59' , 080)
    oView:SetOwnerView('VIEW_SN1','BOXSN1')
    oView:SetOwnerView('VIEW_F59','BOXF59')
    oView:SetViewProperty('VIEW_F59', "GRIDFILTER", {.F.})
    oView:SetViewProperty('VIEW_F59', "GRIDNOORDER")
    oView:SetViewProperty('VIEW_F59', "CHANGELINE", {{ |oView, cViewID| RU01D08Copy(oView, cViewID) }})
    oView:SetDescription(STR0001)
Return(oView)

/*/{Protheus.doc} RU01D0801F()
    This function calls from SXB table, and needed for filter F55 table records
	used in next standard queries: F55_1, F55_2, F55_3, F55_4

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/09/25
    @version 12.1.33
    @example RU01D0801F()
*/
Function RU01D0801F()
    Local cRet   := ''
    Local cRuPrf := ''
    Local cFieldInd   := ''

    If AllTrim(ReadVar()) != ''
        cRuPrf:=StrTokArr(ReadVar(), "->")[2]
    EndIf

    cFieldInd := Right(cRuPrf,1)

    Do Case
        Case cFieldInd == "1"
            cRet := "ALLTRIM(F55->F55_OKTMO2) == '000'"
        Case cFieldInd == "2"
            cRet := "F55->F55_OKTMO1 == FWFLDGET('"+Left(cRuPrf,Len(cRuPrf)-1)+"1') .AND. (EMPTY(ALLTRIM(F55->F55_OKTMO3)) .OR. ALLTRIM(F55->F55_OKTMO3) == '000') .AND. !EMPTY(ALLTRIM(F55->F55_OKTMO2)) .AND. ALLTRIM(F55->F55_OKTMO2) != '000'"
        Case cFieldInd == "3"
            cRet := "F55->F55_OKTMO1 == FWFLDGET('"+Left(cRuPrf,Len(cRuPrf)-1)+"1') .AND. F55->F55_OKTMO2 == FWFLDGET('"+Left(cRuPrf,Len(cRuPrf)-1)+"2') .AND. (EMPTY(ALLTRIM(F55->F55_OKTMO4)) .OR. ALLTRIM(F55->F55_OKTMO4) == '000') .AND. !EMPTY(ALLTRIM(F55->F55_OKTMO3)) .AND. ALLTRIM(F55->F55_OKTMO3) != '000'"
        Case cFieldInd == "4"
            cRet := "F55->F55_OKTMO1 == FWFLDGET('"+Left(cRuPrf,Len(cRuPrf)-1)+"1') .AND. F55->F55_OKTMO2 == FWFLDGET('"+Left(cRuPrf,Len(cRuPrf)-1)+"2') .AND. F55->F55_OKTMO3 == FWFLDGET('"+Left(cRuPrf,Len(cRuPrf)-1)+"3') .AND. !EMPTY(ALLTRIM(F55->F55_OKTMO4)) .AND. ALLTRIM(F55->F55_OKTMO4) != '000'"
    End Do
Return cRet

/*/{Protheus.doc} RU01D08Copy(oView, cViewID)
    This function copy values from previous record to new record

    @type Static Function
    @param oView = object with view
    @param cViewID = String with view id, example: "VIEW_F59"
    @return lRet

    @author Dmitry Borisov
    @since 2023/07/25
    @version 12.1.33
    @example RU01D08Copy(oView, cViewID)
*/
Static Function RU01D08Copy(oView, cViewID)
    Local lRet      := .T.
    Local oModel    := FWModelActive()
    Local oModelF59 := oModel:GetModel("F59DETAIL")

    If oModelF59:Length() > 1
        nLine := oModelF59:GetLine()
        If nLine > 1
            If oModelF59:IsInserted(nLine) .AND. oModelF59:GetValue("F59_ENDDAT", nLine-1) == CTOD("31.12.9999")
                oModelF59:GoLine(nLine)
                oModelF59:LoadValue("F59_TTOKT1",oModelF59:GetValue("F59_TTOKT1", nLine-1))
                oModelF59:LoadValue("F59_TTOKT2",oModelF59:GetValue("F59_TTOKT2", nLine-1))
                oModelF59:LoadValue("F59_TTOKT3",oModelF59:GetValue("F59_TTOKT3", nLine-1))
                oModelF59:LoadValue("F59_TTOKT4",oModelF59:GetValue("F59_TTOKT4", nLine-1))
                oModelF59:LoadValue("F59_TTUOP", oModelF59:GetValue("F59_TTUOP" , nLine-1))
                oModelF59:LoadValue("F59_TTVOP", oModelF59:GetValue("F59_TTVOP" , nLine-1))
                oModelF59:LoadValue("F59_TTLPNU",oModelF59:GetValue("F59_TTLPNU", nLine-1))
                oModelF59:LoadValue("F59_TTTYPE",oModelF59:GetValue("F59_TTTYPE", nLine-1))
                oModelF59:LoadValue("F59_TRANTY",oModelF59:GetValue("F59_TRANTY", nLine-1))
                oModelF59:LoadValue("F59_TTSTLD",oModelF59:GetValue("F59_TTSTLD", nLine-1))
                oModelF59:LoadValue("F59_TTRTTD",oModelF59:GetValue("F59_TTRTTD", nLine-1))
                oModelF59:LoadValue("F59_TTREGD",oModelF59:GetValue("F59_TTREGD", nLine-1))
                oModelF59:LoadValue("F59_TTDERD",oModelF59:GetValue("F59_TTDERD", nLine-1))
                oModelF59:LoadValue("F59_TTPLAT",oModelF59:GetValue("F59_TTPLAT", nLine-1))
                oModelF59:LoadValue("F59_TTECON",oModelF59:GetValue("F59_TTECON", nLine-1))
                oModelF59:LoadValue("F59_PROPTY",oModelF59:GetValue("F59_PROPTY", nLine-1))
                oModelF59:LoadValue("F59_PTOKT1",oModelF59:GetValue("F59_PTOKT1", nLine-1))
                oModelF59:LoadValue("F59_PTOKT2",oModelF59:GetValue("F59_PTOKT2", nLine-1))
                oModelF59:LoadValue("F59_PTOKT3",oModelF59:GetValue("F59_PTOKT3", nLine-1))
                oModelF59:LoadValue("F59_PTOKT4",oModelF59:GetValue("F59_PTOKT4", nLine-1))
                oModelF59:LoadValue("F59_PTNOTA",oModelF59:GetValue("F59_PTNOTA", nLine-1))
                oModelF59:SetValue("F59_BEGDAT",oModelF59:GetValue("F59_BEGDAT", nLine-1)+1)
                oView:Refresh(cViewID)
            EndIf
        EndIf
    EndIf
Return (lRet)
