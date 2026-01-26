#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA900.CH"
#INCLUDE "INKEY.CH"
#INCLUDE "RUHCM274.CH"

/*/{Protheus.doc} GPEA900RUS()
    Experience and 182H. Based on GPEA900 procedure.

    @type Function
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Function GPEA900RUS()

    Local aArea := GetArea()
    Local aCoords := FWGetDialogSize(oMainWnd)
    Local aRGEFields := {}
    Local cIdBrowse As Character
    Local cIdGrid As Character
    Local cX3Campo := ""
    Local oPanelUp As Object
    Local oFormContainer As Object
    Local oPanelDown As Object
    Local oRGERelation As Object
    Local oDlg As Object
    
    Local oBrowseUp As Object
    Local oBrowseDwn As Object

    Define MsDialog oDlg Title OemToAnsi(STR0001) From aCoords[1], aCoords[2] To aCoords[3], aCoords[4] Pixel

    oFormContainer := FWFormContainer():New(oDlg)
    cIdBrowse := oFormContainer:CreateHorizontalBox(60)
    cIdGrid := oFormContainer:CreateHorizontalBox(35)

    oFormContainer:Activate(oDlg, .F.)

    oPanelUp := oFormContainer:GeTPanel(cIdBrowse)
    oPanelDown := oFormContainer:GeTPanel(cIdGrid)

    oBrowseUp := FWmBrowse():New()
    oBrowseUp:SetOwner(oPanelUp)
    oBrowseUp:SetDescription(OemToAnsi(STR0018))
    oBrowseUp:SetAlias('SRA')
    oBrowseUp:SetMenuDef('')
    oBrowseUp:DisableDetails()
    oBrowseUp:SetProfileID('1')
    oBrowseUp:SetCacheView(.F.)
    oBrowseUp:ExecuteFilter(.T.)

    GpLegMVC(@oBrowseUp)

    oBrowseUp:Activate()

    oBrowseDwn:= FWMBrowse():New()
    oBrowseDwn:SetOwner(oPanelDown)
    oBrowseDwn:SetDescription(OemToAnsi(STR0001))
    oBrowseDwn:SetMenuDef('GPEA900RUS')
    oBrowseDwn:DisableDetails()
    oBrowseDwn:SetAlias('RGE')
    oBrowseDwn:SetProfileID('2')
    oBrowseDwn:ForceQuitButton()
    oBrowseDwn:SetCacheView(.F.)
    oBrowseDwn:ExecuteFilter(.F.)

    dbSelectArea("SX3")
    SX3->(DbSetOrder(1))
    dbSeek("RGE")

    While !Eof() .And. (X3_ARQUIVO == "RGE")
        cX3Campo := X3_CAMPO
        If !X3Usado(X3_CAMPO) .Or. AllTrim(X3_CAMPO) $ "RGE_FILIAL|RGE_MAT|RGE_NOMEPAS"
            SX3->(DbSkip())
            Loop
        EndIf
        AAdd(aRGEFields, cX3Campo)
        DbSkip()
    EndDo
    oBrowseDwn:SetOnlyFields(aRGEFields)

    oRGERelation := FWBrwRelation():New()
    oRGERelation:AddRelation(oBrowseUp, oBrowseDwn, {{'RGE_FILIAL', 'RA_FILIAL'}, {'RGE_MAT' , 'RA_MAT'}})
    oRGERelation:Activate()
    oBrowseDwn:Activate()
    oBrowseUp:Refresh()
    oBrowseDwn:Refresh()

    Activate MsDialog oDlg Center

    RestArea(aArea)

Return

/*/{Protheus.doc} MenuDef()
    Menu for GPEA900RUS routine.

    @type Function
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Static Function MenuDef()

    Local aMenuItems As Array

    aMenuItems := {}

    aAdd(aMenuItems, {STR0005, 'PesqBrw', 0, 1, 0, Nil}) // "Search"
    aAdd(aMenuItems, {STR0007, 'VIEWDEF.GPEA900RUS', 0, 3, 0, Nil}) // "Add"
    aAdd(aMenuItems, {STR0006, 'VIEWDEF.GPEA900RUS', 0, 2, 0, Nil}) // "View"
    aAdd(aMenuItems, {STR0012, 'VIEWDEF.GPEA900RUS', 0, 4, 0, Nil}) // "Edit" 
    aAdd(aMenuItems, {STR0009, 'GPEA900_01_Delete()', 0, 5, 0, Nil}) // "Delete"

Return aMenuItems


/*/{Protheus.doc} ModelDef()
    Model for GPEA900RUS routine.

    @type Function
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Static Function ModelDef()

    Local oModel As Object
    Local oStruRGE As Object

    Local oStructF5G As Object
    Local oStructF5H As Object

    Local oEvent As Object // Events.

    oModel := MPFormModel():New('GPEA900RUS')
    oEvent := GPEA900Event():New()

    oStructF5G := FWFormStruct(1,"F5G")
    oStructF5H := FWFormStruct(1,"F5H")
    oStruRGE := FWFormStruct(1,"RGE")

    oModel:AddFields("GPEA900_RGE",, oStruRGE)
    oModel:AddGrid("GPEA900_F5G", "GPEA900_RGE", oStructF5G)
    oModel:AddGrid("GPEA900_F5H", "GPEA900_RGE", oStructF5H)
    oModel:SetPrimaryKey({"RGE_FILIAL", "RGE_MAT"})

    oModel:SetRelation('GPEA900_F5G', {{'F5G_FILIAL','RGE_FILIAL'}, {'F5G_MAT','RGE_MAT'}, {'F5G_DATAIN','RGE_DATAIN'}, {'F5G_TIPOCO','RGE_TIPOCO'}, {'F5G_NUMID','RGE_NUMID'}})
    oModel:SetRelation('GPEA900_F5H', {{'F5H_FILIAL','RGE_FILIAL'}, {'F5H_MAT','RGE_MAT'}, {'F5H_DATAIN','RGE_DATAIN'}, {'F5H_TIPOCO','RGE_TIPOCO'}, {'F5H_NUMID','RGE_NUMID'}})

    oModel:SetDescription(STGP90001) //Reference
    
    oModel:InstallEvent("GPEA900_Event",, oEvent) 

Return oModel


/*/{Protheus.doc} ViewDef()
    View for GPEA900RUS routine.

    @type Function
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Static Function ViewDef()

    Local oModel As Object
    Local oStructRGE As Object
    Local oView As Object
    Local oStrF5G As Object
    Local oStrF5H As Object

    oModel := FwLoadModel("GPEA900RUS")

    oModelF5G := oModel:GetModel("GPEA900_F5G")
    oModelF5H := oModel:GetModel("GPEA900_F5H")
    oStrF5G := FWFormStruct(2, "F5G")
    oStrF5H := FWFormStruct(2, "F5H")

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oStructRGE := FWFormStruct(2,"RGE")
    oView:AddField("GPEA900_RGE", oStructRGE)

    oStructRGE:RemoveField("RGE_FILIAL")
    oStructRGE:RemoveField("RGE_TIPOCO")

    oStructRGE:AddGroup('Grupo00', OemToAnsi(STR0019), '', 3)
    oStructRGE:SetProperty("RGE_MAT", MVC_VIEW_GROUP_NUMBER , 'Grupo00')
    oStructRGE:SetProperty("RGE_NOME", MVC_VIEW_GROUP_NUMBER , 'Grupo00')
    oStructRGE:SetProperty("RGE_CIC", MVC_VIEW_GROUP_NUMBER , 'Grupo00')
    
    oStructRGE:AddGroup('Grupo01', OemToAnsi(STR0020), '', 3)

    oStructRGE:SetProperty("RGE_CNPJ", MVC_VIEW_GROUP_NUMBER, 'Grupo01')
    oStructRGE:SetProperty("RGE_DATAIN", MVC_VIEW_GROUP_NUMBER, 'Grupo01')
    oStructRGE:SetProperty("RGE_DATAFI", MVC_VIEW_GROUP_NUMBER, 'Grupo01')
    oStructRGE:SetProperty("RGE_NOMEMP", MVC_VIEW_GROUP_NUMBER, 'Grupo01')
    oStructRGE:SetProperty("RGE_CODNIF", MVC_VIEW_GROUP_NUMBER, 'Grupo01')
    oStructRGE:SetProperty("RGE_IRBASE", MVC_VIEW_GROUP_NUMBER, 'Grupo01')
    
    oStrF5G:RemoveField("F5G_FILIAL")
    oStrF5G:RemoveField("F5G_MAT")
    oStrF5G:RemoveField("F5G_NUMID")
    oStrF5G:RemoveField("F5G_TIPOCO")
    oStrF5G:RemoveField("F5G_DATAIN")

    oStrF5H:RemoveField("F5H_FILIAL")
    oStrF5H:RemoveField("F5H_MAT")
    oStrF5H:RemoveField("F5H_NUMID")
    oStrF5H:RemoveField("F5H_TIPOCO")
    oStrF5H:RemoveField("F5H_DATAIN")

    oView:AddGrid("GPEA900_F5G", oStrF5G, "GPEA900_F5G")
    oView:AddGrid("GPEA900_F5H", oStrF5H, "GPEA900_F5H")
    
    oView:CreateHorizontalBox("HEADBOX", 70)
    oView:CreateHorizontalBox("GRIDBOX", 30)
    oView:CreateFolder('FOLDER1', 'GRIDBOX')

    oView:AddSheet('FOLDER1','SHEET1',STGP90002) //182H
    oView:CreateHorizontalBox( 'BOXFORM2', 100,,, 'FOLDER1', 'SHEET1')
    oView:AddSheet('FOLDER1','SHEET2',STGP90003) //Experience
    oView:CreateHorizontalBox('BOXFORM4', 100,,, 'FOLDER1', 'SHEET2')

    oView:SetOwnerView("GPEA900_RGE", "HEADBOX")
    oView:SetOwnerView('GPEA900_F5G', 'BOXFORM2')
    oView:SetOwnerView('GPEA900_F5H', 'BOXFORM4')

    oView:SetCloseOnOk({ || .T. }) 

Return oView


/*/{Protheus.doc} GPEA900_01_Delete()
    Function for delete data.

    @type Function
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Function GPEA900_01_Delete()

    Local nOperation As Numeric
    
    nOperation := 5 // Delete operation.
    
    If !IsBlind()
        FwExecView(Nil, "VIEWDEF.GPEA900RUS", nOperation, , {|| .T.})
    EndIf
    
Return .T.


/*/{Protheus.doc} GPE900_02_Edit()
    Data editing function.

    @type Function
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Function GPE900_02_Edit(nOperation)
    
    Default nOperation := 4 // Edit operation.

    If !IsBlind()
        FWExecView(Nil, "VIEWDEF.GPEA900RUS", nOperation,, {|| .T.})
    EndIf
Return .T.


/*/{Protheus.doc} GPEA9RUS_GetDescByS211()
    Returns a description of the experience by code.

    @type Function
    @param  cDedCode,  Character, Code of experience.
    @author iprokhorenko
    @since 2021/04/21
    @version 191205P
*/
Function GPEA9RUS_GetDescByS211(cDedCode As Character)
    Local cResult As Character
    Local nPosLine As Numeric

    cResult := ""

    If !Empty(cDedCode)
        nPosLine := fPosTab("S211", cDedCode, "==", 4)

        If nPosLine > 0
            cResult := fTabela("S211", nPosLine, 5)
        EndIf
    EndIf

Return cResult
