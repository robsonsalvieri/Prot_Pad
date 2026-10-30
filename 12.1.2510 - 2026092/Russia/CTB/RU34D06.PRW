#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU34D06.CH"

/*/{Protheus.doc} RU34D06()
    This function needed for maintaince analytic sync rules

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/10/27
    @version 12.1.33
    @example RU34D06()
*/
Function RU34D06()
    Local lRet as Logical
    Local oBrowse as Object
    Local aArea := {}

    Private aRotina as Array

    aRotina := MenuDef()

    lRet := .T.
    aArea := GetArea()

    DbSeelectArea('F5O')
    DbSeelectArea('F5S')
    oBrowse := BrowseDef()
    oBrowse:Activate()

    RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} BrowseDef()
    This function activate MVC

    @type Static Function
    @return oBrowse

    @author Dmitry Borisov
    @since 2023/10/27
    @version 12.1.33
    @example BrowseDef()
*/
Static Function BrowseDef()
    Local oBrowse as Object

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F5O")
    oBrowse:SetDescription(STR0001) // Analytics Rules
    oBrowse:DisableDetails()

Return oBrowse

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRet

    @author Dmitry Borisov
    @since 2023/10/27
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRet := {}

    aAdd( aRet, {STR0002, "VIEWDEF.RU34D06", 0, MODEL_OPERATION_INSERT, 0, Nil} ) // Add
    aAdd( aRet, {STR0004, "VIEWDEF.RU34D06", 0, MODEL_OPERATION_VIEW  , 0, Nil} ) // View
    aAdd( aRet, {STR0003, "VIEWDEF.RU34D06", 0, MODEL_OPERATION_UPDATE, 0, Nil} ) // Edit
    aAdd( aRet, {STR0005, "VIEWDEF.RU34D06", 0, MODEL_OPERATION_DELETE, 0, Nil} ) // Delete
    aAdd( aRet, {STR0014, "RU34XFUN06('" + STR0014 + "','RU34D06')", 0, 9, 0, Nil} ) // Copy

Return aRet

/*/{Protheus.doc} ModelDef()
    This function prepare Model object from MVC

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2023/10/27
    @version 12.1.33
    @example ModelDef()
*/
Static Function ModelDef()
    Local oModel as Object
    Local oStrF5O := FWFormStruct(1, 'F5O')
    Local oStrF5S := FWFormStruct(1, 'F5S')
    Local oModelEv As Object
    Local aRelat  := {}

    oStrF5O:SetProperty('F5O_GRCNS',MODEL_FIELD_VALID, {|| ExistCpo("F43")})
    oStrF5O:SetProperty('F5O_F5QCOD',MODEL_FIELD_WHEN, {|oMdl| ChkWhen(oMdl)})

    oModel := MPFormModel():New('RU34D06')
    oModel:AddFields('F5OMASTER', Nil, oStrF5O)
    oModel:SetPrimaryKey({'F5O_FILIAL','F5O_CTYPE','F5O_GRCNS','F5O_F5QCOD'})
    oModel:AddGrid("F5SDETAIL", "F5OMASTER", oStrF5S)
    oModel:SetPrimaryKey({'F5S_FILIAL','F5S_CTYPE','F5S_GRCNS','F5S_F5QCOD','F5S_DVALST'})

    aAdd(aRelat, {"F5S_FILIAL", "XFILIAL('F5S')"})
    aAdd(aRelat, {"F5S_CTYPE" , "F5O_CTYPE"})
    aAdd(aRelat, {"F5S_GRCNS" , "F5O_GRCNS"})
    aAdd(aRelat, {"F5S_F5QCOD", "F5O_F5QCOD"})

    oModel:SetRelation( 'F5SDETAIL', aRelat , F5S->(IndexKey(1)))
    oModelEv 	:= RU34D06EventRUS():New()
    oModel:InstallEvent("oModelEv", /*cOwner*/, oModelEv)

Return(oModel)

/*/{Protheus.doc} ViewDef()
    This function prepare View object from MVC

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2023/10/27
    @version 12.1.33
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView As Object
    Local oModel  := FwLoadModel("RU34D06")
    Local oStrF5O := FWFormStruct(2, "F5O")
    Local oStrF5S := FWFormStruct(2, "F5S")

    oStrF5O:RemoveField('F5O_FILIAL')

    oStrF5S:RemoveField('F5S_FILIAL')
    oStrF5S:RemoveField('F5S_GRCNS')
    oStrF5S:RemoveField('F5S_CTYPE')
    oStrF5S:RemoveField('F5S_F5QCOD')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_F5O", oStrF5O, "F5OMASTER")
    oView:AddGrid( "VIEW_F5S", oStrF5S, "F5SDETAIL")
    oView:CreateHorizontalBox( 'BOXF5O', 020)
    oView:CreateHorizontalBox( 'BOXF5S', 080)
    oView:SetOwnerView('VIEW_F5O','BOXF5O')
    oView:SetOwnerView('VIEW_F5S','BOXF5S')
    oView:SetViewProperty('VIEW_F5S', "GRIDFILTER", {.F.})
    oView:SetViewProperty('VIEW_F5S', "GRIDNOORDER")
    oView:SetViewProperty('VIEW_F5S', "CHANGELINE", {{ |oView, cViewID| RU34D06003(oView, cViewID, oView:GetModel("F5SDETAIL")) }})
    oView:SetDescription(STR0001)
    oView:SetProgressBar(.T.)
Return(oView)

/*/{Protheus.doc} RU34D06003_CopyGrid(oView, cViewID, oModelF5S)
    This function copy values from previous record to new record

    @type Static Function
    @param oView = object with view
    @param cViewID = String with view id, example: "VIEW_F5S"
    @param oModelF5S = object with grid model
    @return lRet

    @author Dmitry Borisov
    @since 2023/10/30
    @version 12.1.33
    @example RU34D06003(oView, cViewID, oModelF5S)
*/
Static Function RU34D06003_CopyGrid(oView, cViewID, oModelF5S)
    Local lRet      := .T.
    Local nLine     := 0

    If oModelF5S:Length() > 1
        nLine := oModelF5S:GetLine()
        If nLine > 1
            If oModelF5S:IsInserted(nLine)  .AND. oModelF5S:GetValue("F5S_DVALEN", nLine-1) == CTOD("31.12.9999")
                oModelF5S:GoLine(nLine)
                oModelF5S:LoadValue("F5S_PAYAC" ,oModelF5S:GetValue("F5S_PAYAC" , nLine-1))
                oModelF5S:LoadValue("F5S_PAYAR" ,oModelF5S:GetValue("F5S_PAYAR" , nLine-1))
                oModelF5S:LoadValue("F5S_ADVAC" ,oModelF5S:GetValue("F5S_ADVAC" , nLine-1))
                oModelF5S:LoadValue("F5S_ADVAR" ,oModelF5S:GetValue("F5S_ADVAR" , nLine-1))
                oModelF5S:LoadValue("F5S_CFAR"  ,oModelF5S:GetValue("F5S_CFAR"  , nLine-1))
                If oModelF5S:GetStruct():HasField('F5S_EC09DB')
                    oModelF5S:LoadValue("F5S_EC09DB",oModelF5S:GetValue("F5S_EC09DB", nLine-1))
                EndIf
                oModelF5S:LoadValue("F5S_PRFAC" ,oModelF5S:GetValue("F5S_PRFAC" , nLine-1))
                oModelF5S:LoadValue("F5S_CSTAC" ,oModelF5S:GetValue("F5S_CSTAC" , nLine-1))
                oModelF5S:LoadValue("F5S_PRFAR" ,oModelF5S:GetValue("F5S_PRFAR" , nLine-1))
                oModelF5S:LoadValue("F5S_CSTAR" ,oModelF5S:GetValue("F5S_CSTAR" , nLine-1))
                oModelF5S:LoadValue("F5S_LEGAC" ,oModelF5S:GetValue("F5S_LEGAC" , nLine-1))
                oModelF5S:LoadValue("F5S_VATAC" ,oModelF5S:GetValue("F5S_VATAC" , nLine-1))
                oModelF5S:LoadValue("F5S_LEGAR" ,oModelF5S:GetValue("F5S_LEGAR" , nLine-1))
                oModelF5S:LoadValue("F5S_VATAR" ,oModelF5S:GetValue("F5S_VATAR" , nLine-1))
                oModelF5S:SetValue("F5S_DVALST" ,oModelF5S:GetValue("F5S_DVALST", nLine-1)+1)
                oView:Refresh(cViewID)
            EndIf
        EndIf
    EndIf
Return (lRet)

/*/{Protheus.doc} RU34D06004_GetContracts(lCheck, aChanged, oModel)
    This function uses in validation and for update contract data
    Returns array of contracts

    @type Function
    @param lCheck = logical, param defines mode of function: .T. = validation, .F. = edit records
    @param aChanged  = array with inserted/edited/deleted row number from grid
    @return aF5Qlist

    @author Dmitry Borisov
    @since 2023/11/01
    @version 12.1.33
    @example RU34D06004(lCheck, aChanged)
*/
Function RU34D06004_GetContracts(lCheck, aChanged)
    Local cQuery     := ''
    Local cSubQuery  := ''
    Local cTab       := GetNextAlias()
    Local oModel     := FWModelActive()
    Local cType      := oModel:GetValue("F5OMASTER", "F5O_CTYPE")
    Local cGrcns     := oModel:GetValue("F5OMASTER", "F5O_GRCNS")
    Local cF5qcode   := oModel:GetValue("F5OMASTER", "F5O_F5QCOD")
    Local aSqlOper   := IIf(lCheck, {"OR", ""}, {"AND","NOT"})
    Local aF5Qlist   := {}
    Local aArea      := {}
    Local nX         := 0

    cQuery := "SELECT F5Q_CODE, R_E_C_N_O_ As RecNo"
    cQuery += " FROM "+RetSqlName('F5Q')
    cQuery += " WHERE D_E_L_E_T_ = '' "
    cQuery += " AND F5Q_FILIAL = '"+xFilial("F5O")+"'"
    cQuery += " AND F5Q_CTYPE = '"+cType+"'"
    cQuery += " AND F5Q_GRCNS = '"+cGrcns+"'"
    If !Empty(AllTrim(cF5qcode))
        cQuery += " AND F5Q_CODE = '"+AllTrim(cF5qcode)+"'"
    Else
        cQuery += " AND F5Q_CODE NOT IN (SELECT F5O_F5QCOD FROM "+RetSqlName('F5O')+" WHERE F5O_F5QCOD != '' AND D_E_L_E_T_ = '' )"
    EndIf

    If oModel:GetOperation() <> MODEL_OPERATION_DELETE

        If Empty(AllTrim(cF5qcode))
            If Empty(aChanged)
                aChanged := RU34D06006(oModel)
            EndIf
            If Len(aChanged) > 0
                For nX := 1 To Len(aChanged)
                    If !oModel:GetModel("F5SDETAIL"):IsDeleted(aChanged[nX])
                        If nX == Len(aChanged)
                            cSubQuery += "(F5Q_EDATE BETWEEN '" + DTOS(oModel:GetModel("F5SDETAIL"):GetValue("F5S_DVALST", aChanged[nX])) + "' AND '" + DTOS(oModel:GetModel("F5SDETAIL"):GetValue("F5S_DVALEN", aChanged[nX])) + "')) "
                        Else
                            cSubQuery += "(F5Q_EDATE BETWEEN '" + DTOS(oModel:GetModel("F5SDETAIL"):GetValue("F5S_DVALST", aChanged[nX])) + "' AND '" + DTOS(oModel:GetModel("F5SDETAIL"):GetValue("F5S_DVALEN", aChanged[nX])) + "') OR "
                        EndIf
                    EndIf
                Next nX
                cQuery += IIf(Empty(cSubQuery),''," AND ( " + cSubQuery)
            EndIf
        EndIf

        cQuery += " AND (F5Q_CODE " + aSqlOper[2] + " IN ("
        cQuery += " SELECT C7_F5QCODE FROM " + RetSqlName('SC7')
        cQuery += " WHERE C7_FILIAL = '"+xFilial("F5O")+"' AND C7_F5QCODE = F5Q_CODE AND D_E_L_E_T_ = '')" 

        cQuery += " " + aSqlOper[1] + " F5Q_CODE " + aSqlOper[2] + " IN ("
        cQuery += " SELECT C5_F5QCODE FROM " + RetSqlName('SC5')
        cQuery += " WHERE C5_FILIAL = '"+xFilial("F5O")+"' AND C5_F5QCODE = F5Q_CODE AND D_E_L_E_T_ = '')" 

        cQuery += " " + aSqlOper[1] + " F5Q_CODE " + aSqlOper[2] + " IN ("
        cQuery += " SELECT F1_CNTID FROM " + RetSqlName('SF1')
        cQuery += " WHERE F1_FILIAL = '"+xFilial("F5O")+"' AND F1_CNTID = F5Q_CODE AND D_E_L_E_T_ = '')" 

        cQuery += " " + aSqlOper[1] + " F5Q_CODE " + aSqlOper[2] + " IN ("
        cQuery += " SELECT F2_CNTID FROM " + RetSqlName('SF2')
        cQuery += " WHERE F2_FILIAL = '"+xFilial("F5O")+"' AND F2_CNTID = F5Q_CODE AND D_E_L_E_T_ = ''))" 
    EndIf

    cQuery := ChangeQuery(cQuery)
    aArea  := GetArea()
    DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTab)

    While (cTab)->(!EOF())
        aAdd(aF5Qlist, (cTab)->RecNo)
        (cTab)->(DbSkip())
    End

    (cTab)->(dbCloseArea())
    RestArea(aArea)

Return aF5Qlist

/*/{Protheus.doc} RU34D06005_UpdateContracts(aF5Qlist, oModel)
    This function updates contract's analytics

    @type Function
    @param aF5Qlist = Array with recno from F5Q table
    @param oModel = object with model
    @return 

    @author Dmitry Borisov
    @since 2023/11/01
    @version 12.1.33
    @example RU34D06005(aF5Qlist, oModel)
*/
Function RU34D06005_UpdateContracts(aF5Qlist, oModel)
    Local nX        := 0
    Local nI        := 0
    Local aArea     := F5Q->(GetArea())
    Local aChanged  := {}

    aChanged := RU34D06006(oModel)

    DbSelectArea("F5Q")
    For nX := 1 To Len(aF5Qlist)
        F5Q->(DbGoTo(aF5Qlist[nX]))
        For nI := 1 To Len(aChanged)
            If !oModel:GetModel("F5SDETAIL"):IsDeleted(aChanged[nI]) .And. F5Q->F5Q_EDATE >= oModel:GetModel("F5SDETAIL"):GetValue("F5S_DVALST", aChanged[nI]) .And.;
             F5Q->F5Q_EDATE <= oModel:GetModel("F5SDETAIL"):GetValue("F5S_DVALEN", aChanged[nI])
                RecLock('F5Q', .F.)
                F5Q->F5Q_PAYAC  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_PAYAC" , aChanged[nI])
                F5Q->F5Q_PAYAR  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_PAYAR" , aChanged[nI])
                F5Q->F5Q_ADVAC  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_ADVAC" , aChanged[nI])
                F5Q->F5Q_ADVAR  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_ADVAR" , aChanged[nI])
                F5Q->F5Q_CFAR   := oModel:GetModel("F5SDETAIL"):GetValue("F5S_CFAR"  , aChanged[nI])
                If oModel:GetModel("F5SDETAIL"):GetStruct():HasField('F5S_EC09DB')
                    F5Q->F5Q_EC09DB := oModel:GetModel("F5SDETAIL"):GetValue("F5S_EC09DB", aChanged[nI])
                EndIf
                F5Q->F5Q_PRFAC  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_PRFAC" , aChanged[nI])
                F5Q->F5Q_CSTAC  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_CSTAC" , aChanged[nI])
                F5Q->F5Q_PRFAR  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_PRFAR" , aChanged[nI])
                F5Q->F5Q_CSTAR  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_CSTAR" , aChanged[nI])
                F5Q->F5Q_LEGAC  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_LEGAC" , aChanged[nI])
                F5Q->F5Q_VATAC  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_VATAC" , aChanged[nI])
                F5Q->F5Q_LEGAR  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_LEGAR" , aChanged[nI])
                F5Q->F5Q_VATAR  := oModel:GetModel("F5SDETAIL"):GetValue("F5S_VATAR" , aChanged[nI])
                F5Q->(MSUnlock())
            EndIf
        Next nI
    Next nX
    RestArea(aArea)
Return 

/*/{Protheus.doc} RU34D06006_GetChangedLines(oModel)
    This function return inserted/updated lines from grid

    @type Function
    @param oModel = object with model
    @return aChanged

    @author Dmitry Borisov
    @since 2023/12/29
    @version 12.1.33
    @example RU34D06006(oModel)
*/
Function RU34D06006_GetChangedLines(oModel)
    Local aChanged  := {}
    Local nX        := 0
    Local lSubModel := oModel:GetId() == "F5SDETAIL"

    aChanged := Iif(!lSubModel, oModel:GetModel("F5SDETAIL"):GetLinesChanged(), oModel:GetLinesChanged())
    For nX := 1 To Len(aChanged)
        If !lSubModel
            If oModel:GetModel("F5SDETAIL"):IsDeleted(aChanged[nX])
                aDel(aChanged, nX)
            EndIf
        Else
            If oModel:IsDeleted(aChanged[nX])
                aDel(aChanged, nX)
            EndIf
        EndIf
    Next nX

    nX := aScan(aChanged, Nil)
    If nX > 0
        aSize(aChanged, nX-1)
    EndIf

Return (aChanged)

/*/{Protheus.doc} ChkWhen()
    This function uses for WHEN condition for fields

    @type Static Function
    @return lRet

    @author Dmitry Borisov
    @since 2024/01/12
    @example ChkWhen(oModel)
*/
Static Function ChkWhen(oModel)
    Local lRet    := .T.
    
    If oModel:GetOperation() == MODEL_OPERATION_UPDATE
        lRet := .F.
    EndIf

Return (lRet)
                   
//Merge Russia R14 
                   
