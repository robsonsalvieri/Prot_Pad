#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07T12.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "INKEY.CH"

/*{Protheus.doc} RU07T12()
    Routine Tax Deductions. Based on the GPEA900 routine.

    @type  Function
    @author vselyakov
    @since 14.12.2020
    @version 191205P
*/
Function RU07T12()
    Local aArea        As Array
    Local aCoords      As Array
    Local cIdBrowse    As Character
    Local cIdGrid      As Character
    Local oPanelUp     As Object
    Local oForm        As Object
    Local oPanelDown   As Object
    Local oRelationF5C As Object
    Local oDialog      As Object
    Local oBrowseUp    As Object
    Local oBrowseDwn   As Object

    aArea := GetArea()
    aCoords := FWGetDialogSize(oMainWnd)

    Define MsDialog oDialog Title STR0001 From aCoords[1], aCoords[2] To aCoords[3], aCoords[4] Pixel  // Title 'Tax Deductions'.

    // Creates the container where the panels will be placed.
    oForm := FWFormContainer():New(oDialog)
    cIdBrowse := oForm:CreateHorizontalBox(60)
    cIdGrid := oForm:CreateHorizontalBox(35)
    
    oForm:Activate(oDialog, .F.)
    
    // Creates the panels where the browsers will be placed.
    oPanelUp := oForm:GetPanel(cIdBrowse)
    oPanelDown := oForm:GetPanel(cIdGrid)
    
    // FWmBrowse Superior: Employees
    oBrowseUp:= FWmBrowse():New()
    oBrowseUp:SetOwner(oPanelUp) // Here, browse is linked to the screen component.
    oBrowseUp:SetDescription(STR0007)
    oBrowseUp:SetAlias('SRA')
    oBrowseUp:SetMenuDef('') // Defines where the buttons for this browse will come from.
    oBrowseUp:DisableDetails()
    oBrowseUp:SetProfileID('1')
    oBrowseUp:SetCacheView(.F.) 
    oBrowseUp:ExecuteFilter(.T.)
    
    GpLegMVC(@oBrowseUp) // Creates a column with status of employee (legend).
    oBrowseUp:Activate()

    // FWmBrowse Inferior: Tax Deductions.
    oBrowseDwn:= FWMBrowse():New()
    oBrowseDwn:SetOwner(oPanelDown)
    oBrowseDwn:SetDescription(STR0001)
    oBrowseDwn:SetMenuDef('RU07T12')
    oBrowseDwn:DisableDetails()
    oBrowseDwn:SetAlias('F5C')
    oBrowseDwn:SetProfileID('2')
    oBrowseDwn:ForceQuitButton() // Whenever there are two menudefs on the screen, you must indicate in which browse the 'Exit' button will be.
    oBrowseDwn:SetCacheView(.F.)
    oBrowseDwn:ExecuteFilter(.F.)
    oBrowseDwn:SetDoubleClick({|| RU07T1202_DoubleClick()})

    // Set relation between up panel (SRA) and down panel (F5C).
    oRelationF5C:= FWBrwRelation():New()
    oRelationF5C:AddRelation(oBrowseUp, oBrowseDwn, {{'F5C_FILIAL', 'RA_FILIAL'}, {'F5C_MAT', 'RA_MAT'}, {'F5C_TYPE', '"3"'}})
    oRelationF5C:Activate()
    oBrowseDwn:Activate()
    oBrowseUp:Refresh()
    oBrowseDwn:Refresh()
    
    Activate MsDialog oDialog Center
    
    RestArea(aArea)
Return

/*{Protheus.doc} MenuDef()
    Menu for RU07T12 routine.

    @type  Function
    @author vselyakov
    @since 14.12.2020
    @version 191205P
*/
Static Function MenuDef()
    Local aMenuItems As Array

    aMenuItems := {}

    aAdd(aMenuItems, {STR0006, 'PesqBrw',                 0, 1, 0, NIL}) // "Search"
    aAdd(aMenuItems, {STR0003, 'VIEWDEF.RU07T12',         0, 3, 0, NIL}) // "Add"
    aAdd(aMenuItems, {STR0002, 'VIEWDEF.RU07T12',         0, 2, 0, NIL}) // "View"
    aAdd(aMenuItems, {STR0004, 'RU07T1202_DoubleClick()', 0, 4, 0, NIL}) // "Edit"
    aAdd(aMenuItems, {STR0005, 'RU07T1201_DeleteF5C()',   0, 5, 0, NIL}) // "Delete"
Return aMenuItems

/*{Protheus.doc} RU07T1201_DeleteF5C()
    Before deleting a record from F5C, a check is made that no matching records exist in table F5D.
    If in F5D exist record then user get message "The deduction has already been taken into account and cannot be deleted".

    @type  Function
    @author vselyakov
    @since 15.01.2021
    @version 191205P
    @param 
    @return lCanDelete, Logical, Possibility to delete an F5C entry.
    @example RU07T1201_DeleteF5C()
*/
Function RU07T1201_DeleteF5C()
    Local lCanDelete As Logical
    Local cF5C_COD   As Char

    cF5C_COD   := F5C->F5C_COD // The value of the F5C_COD field on the selected row in the grid.
    lCanDelete := !RU07T1204_F5DExist(cF5C_COD) // Possibility to delete an F5C entry.

    If lCanDelete .AND. !IsBlind()
        FwExecView(NIL, "VIEWDEF.RU07T12", MODEL_OPERATION_DELETE, , {|| lCanDelete})
    Else
        Help(NIL, NIL, STR0009, NIL, STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL, NIL)
    EndIf

Return lCanDelete

/*{Protheus.doc} RU07T1202_DoubleClick(nOperation)
    The function launches the View for editing by double clicking on the line. 
    Before launching, it checks for records in F5D to determine if F5C fields need to be closed for editing.

    @type  Function
    @author vselyakov
    @since 15.01.2020
    @version 191205P
    @param nOperation, Numeric, Number of operation. 4-Edit
    @return lRet, Logical, Is it possible to run View.
    @example
    (examples)
*/
Function RU07T1202_DoubleClick(nOperation)
    Default nOperation := MODEL_OPERATION_UPDATE // Edit operation.

    // IsBlind() - This function determines if the connection made with Protheus has no user interface. 
    If !IsBlind()
        FWExecView(STR0004, "VIEWDEF.RU07T12", nOperation,, {|| .T.})
    EndIf
Return .T.

/*{Protheus.doc} ModelDef()
    Model for RU07T12 routine.

    @type  Function
    @author vselyakov
    @since 14.12.2020
    @version 191205P
*/
Static Function ModelDef()
    Local oModel   As Object
    Local oStrF5C  As Object // Structure of F5C table.
    Local oStrF5D  As Object // Structure of F5D table.
    Local oEvent   As Object // Events.
    
    oModel := MPFormModel():New('RU07T12')
    oEvent := RU07T12Event():NEW()
    
    // Defenition of structures.
    oStrF5C := FWFormStruct(1, "F5C")
    oStrF5D := FWFormStruct(1, "F5D")

    oModel:AddFields("RU07T12_F5C", /*cOwner*/, oStrF5C , /*bPreValidation*/, /*bPosValidation*/, /*bLoad*/)
    oModel:AddGrid("RU07T12_F5D", "RU07T12_F5C", oStrF5D)
    oModel:SetPrimaryKey( {"F5C_FILIAL", "F5C_MAT", "F5C_COD"} )
    
    oModel:SetRelation('RU07T12_F5D', {{'F5D_FILIAL', 'F5C_FILIAL'}, {'F5D_MAT', 'F5C_MAT'}, {'F5D_COD', 'F5C_COD'}})

    // Make grid only for View.
    oModel:GetModel("RU07T12_F5D"):SetOptional(.T.)
    oModel:GetModel("RU07T12_F5D"):SetOnlyQuery(.T.)

    oModel:SetDescription(STR0008)
    oModel:GetModel('RU07T12_F5C'):SetDescription("Tax deduction")
    oModel:GetModel('RU07T12_F5D'):SetDescription("Closing tax deductions")

    oModel:InstallEvent("RU07T12_Event",, oEvent) // Subscribe on events.

Return oModel

/*{Protheus.doc} ViewDef()
    View for RU07T12 routine.

    @type  Function
    @author vselyakov
    @since 14.12.2020
    @version 191205P
*/
Static Function ViewDef()
    Local oModel     As Object
    Local oStrF5C    As Object // Structure of F5C table.
    Local oStrF5D    As Object // Structure of F5D table.
    Local oView      As Object
    Local oModelF5D  As Object

    oModel    := FwLoadModel("RU07T12")
    oModelF5D := oModel:GetModel("RU07T12_F5D")
    oStrF5C   := FWFormStruct(2, "F5C")
    oStrF5D   := FWFormStruct(2, "F5D")

    // Hide fields from View.
    oStrF5C:RemoveField("F5C_COD")
    oStrF5C:RemoveField("F5C_TYPE")
    oStrF5D:RemoveField("F5D_MAT")
    oStrF5D:RemoveField("F5D_COD")
    oStrF5D:RemoveField("F5D_DTVCPM")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    
    oView:AddField("RU07T12_F5C", oStrF5C, "RU07T12_F5C")
    oView:AddGrid("RU07T12_F5D", oStrF5D, "RU07T12_F5D")
    oView:SetViewProperty("RU07T12_F5D", "OnlyView")

    oView:CreateHorizontalBox("HEADBOX", 30)
    oView:CreateHorizontalBox("GRIDBOX", 70)

    oView:SetOwnerView("RU07T12_F5C", "HEADBOX")
    oView:SetOwnerView("RU07T12_F5D", "GRIDBOX")

    // Method that sets a Code-block to be evaluated before activating View.
    oView:SetViewCanActivate({|oView| RU07T1206_SetFieldViewOnly(oView)})

Return oView

/*{Protheus.doc} RU07T12003(cDedCode)
    Returns a description of the tax deduction by code.

    @type  Function
    @author vselyakov
    @since 17.12.2020
    @version 191205P
*/
// Strange naming due to ATUSX requirements (F5C_DDED field)
Function RU07T12003(cDedCode)
    Local cResult As Character
    Local nPosLine As Numeric

    cResult := ""

    If !Empty(cDedCode)
        nPosLine := fPosTab("S210", cDedCode, "==", 6)

        If nPosLine > 0
            cResult := fTabela("S210", nPosLine, 7)
        EndIf
    EndIf   

Return cResult

/*{Protheus.doc} RU07T1204_F5DExist(nF5CCOD)
    Checks for the existence of matching records in F5D.

    @type  Function
    @author vselyakov
    @since 15.01.2020
    @version 191205P
    @param nF5CCOD, Char, Value F5C_COD of grid selected row.
    @return lF5DExist, Logical, There are corresponding entries in F5D.
    @example
    RU07T1204_F5DExist(cF5C_COD)
    RU07T1204_F5DExist(F5C->F5C_COD)
*/
Function RU07T1204_F5DExist(cF5CCOD)
    Local lF5DExist  As Logical
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character

    aArea := GetArea()
    lF5DExist := .F.

    oStatement := FWPreparedStatement():New(" SELECT COUNT(*) AS LINES FROM " + RetSQLName("F5D") + " WHERE F5D_FILIAL = ? AND F5D_MAT = ? AND F5D_COD = ? AND D_E_L_E_T_=' ' ")
    oStatement:SetString(1, xFilial("F5D"))
    oStatement:SetString(2, SRA->RA_MAT)
    oStatement:SetString(3, cF5CCOD)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery(), GetNextAlias())

    lF5DExist := ((cTab)->LINES > 0)

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)
Return lF5DExist

/*{Protheus.doc} RU07T1205_DeleteF5D(cFil, cMat, cProc, cPer, cRoteir)
    Remove record into F5D by delete calculation into GPEM160.

    @type  Function
    @author vselyakov
    @since 20.02.2020
    @version 191205P
    @param cFil,    Character, Filial of record.
           cMat,    Character, Employee number.
           cProc,   Character, Calculation process code.
           cPer,    Character, Settlement period code.
           cRoteir, Character, Calculation scenario code.
    @return lF5DDeleted, Logical, Flag that the record has been deleted.
    @example RU07T1205_DeleteF5D(cCanFil, cCanMat, cCanPro, cCanPer, cCanRot)
*/
Function RU07T1205_DeleteF5D(cFil, cMat, cProc, cPer, cRoteir)
    Local lF5DDeleted  As Logical
    Local oStatement   As Object
    Local aArea        As Array
    Local nStatus      As Numeric
    Local aRemovedF5D  As Array
    Local cQueryResult As Character

    aArea := GetArea()
    aRemovedF5D := {}
    lF5DDeleted := .F.

    // If this function called from GPEM040 routine then Looking for removed F5D records.
    If FwIsInCallstack("GPEM040")
        oStatement := FWPreparedStatement():New(" SELECT F5D_COD FROM " + RetSQLName("F5D") + " WHERE F5D_FILIAL = ? AND F5D_MAT IN (?) AND F5D_PROCES = ? AND F5D_ROTEIR = ? AND F5D_PER = ? AND D_E_L_E_T_=' ' ")
        oStatement:SetString(1, cFil)
        oStatement:SetIn(2, StrTokArr(cMat, "','"))
        oStatement:SetString(3, cProc)
        oStatement:SetString(4, cRoteir)
        oStatement:SetString(5, cPer)

        cQueryResult := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cQueryResult)
        DBGoTop()

        While !EoF()
            AAdd(aRemovedF5D, (cQueryResult)->F5D_COD)
            DBSkip()
        EndDo

        DbCloseArea()
    EndIf

    /* The string cMat can be represented as a set of table numbers like "000013','000014','000015','000016'".
     * This string get from GPEM160. 
     * For this reason, the StrTokArr function will be used, which will return an array. This array can then be used in the FWPreparedStatement class in the SetIn() method.
    */
    oStatement := FWPreparedStatement():New(" DELETE FROM " + RetSQLName("F5D") + " WHERE F5D_FILIAL = ? AND F5D_MAT IN (?) AND F5D_PROCES = ? AND F5D_ROTEIR = ? AND F5D_PER = ? AND D_E_L_E_T_=' ' ")
    oStatement:SetString(1, cFil)
    oStatement:SetIn(2, StrTokArr(cMat, "','"))
    oStatement:SetString(3, cProc)
    oStatement:SetString(4, cRoteir)
    oStatement:SetString(5, cPer)

    nStatus := TcSqlExec(oStatement:GetFixQuery())
    lF5DDeleted := (nStatus >= 0)

    // If this function called from GPEM040 routine then cancel closed tax deductions.
    If FwIsInCallstack("GPEM040") .And. lF5DDeleted
        oStatement := FWPreparedStatement():New(" UPDATE " + RetSQLName("F5C") + " SET F5C_LOCK = '1', F5C_STATUS = '1' WHERE F5C_FILIAL = ? AND F5C_MAT IN (?) AND F5C_COD IN (?) AND D_E_L_E_T_=' ' ")
        oStatement:SetString(1, cFil)
        oStatement:SetIn(2, StrTokArr(cMat, "','"))
        oStatement:SetIn(3, aRemovedF5D)

        nStatus := TcSqlExec(oStatement:GetFixQuery())
        lF5DDeleted := (nStatus >= 0)
    EndIf

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return lF5DDeleted

/*{Protheus.doc} RU07T1206_SetFieldViewOnly(oView)
    When View activate go check to a exist a record for this deduction in F5D.
    Some fields of F5C table will be for view only in this case.

    @type  Function
    @author vselyakov
    @since 15.04.2021
    @version 191205P
    @param oView, Object, Object of current View.
    @return lActivate, Logical, .T. - View can be activate, .F. - another case.
    @example oView:SetViewCanActivate({|oView| RU07T1206_SetFieldViewOnly(oView)})
*/
Static Function RU07T1206_SetFieldViewOnly(oView)
    Local oStrF5C As Object

    oStrF5C := oView:GetViewStruct("RU07T12_F5C")

    If oView:GetOperation() == MODEL_OPERATION_UPDATE .And. RU07T1204_F5DExist(F5C->F5C_COD)
        oStrF5C:SetProperty("F5C_LOCLTA", MVC_VIEW_CANCHANGE, .F.)
        oStrF5C:SetProperty("F5C_DTENTR", MVC_VIEW_CANCHANGE, .F.)
        oStrF5C:SetProperty("F5C_DEDCOD", MVC_VIEW_CANCHANGE, .F.)
        oStrF5C:SetProperty("F5C_INCOME", MVC_VIEW_CANCHANGE, .F.)
    EndIf

Return .T.

/*{Protheus.doc} RU07T1207_CloseTaxDeductionsByTermination(cFil, cPersonnelNumber)
    Upon dismissal of an employee, if he has tax deductions, we close them.

    @type  Function
    @author vselyakov
    @since 29.09.2021
    @version 191205P
    @param cFil, Character, Filial of employee.
           cPersonnelNumber, Character, Employee personnel number.
    @return lF5DDeleted, Logical, Flag that the record has been deleted.
    @example RU07T1207_CloseTaxDeductionsByTermination(SRA->RA_FILIAL, SRA->RA_MAT)
*/
Function RU07T1207_CloseTaxDeductionsByTermination(cFil, cPersonnelNumber)
    Local lF5DDeleted  As Logical
    Local oStatement   As Object
    Local aArea        As Array
    Local nStatus      As Numeric

    aArea := GetArea()
    lF5DDeleted := .F.

    oStatement := FWPreparedStatement():New(" UPDATE " + RetSQLName("F5C") + " SET F5C_LOCK = '2', F5C_STATUS = '2' WHERE F5C_FILIAL = ? AND F5C_MAT = ? AND D_E_L_E_T_=' ' ")
    oStatement:SetString(1, cFil)
    oStatement:SetString(2, cPersonnelNumber)

    nStatus := TcSqlExec(oStatement:GetFixQuery())
    lF5DDeleted := (nStatus >= 0)

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return lF5DDeleted
