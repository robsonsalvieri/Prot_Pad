#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07T13RUS.CH"
#INCLUDE "PCOTRYEXCEPTION.CH"

#DEFINE STATE_OF_LOADED "'1','2','3'"
#DEFINE STATE_OF_CLOSED "030"
#DEFINE FIELD_NEED_CHECK_CAN "|R8_INIPCHI|R8_FIMPCHI|"

Static cRU07T1301MainAlias
Static cRU07T1302RealName
Static cRU07T1303RealName2
Static cRU07T1304Slave1Alias
Static cRU07T1305TempSr8
Static cRU07T1306TempSr8
Static lRU07T1301InitGrid
Static lRU07T1302ProcSave

Static cUltSeq

/*/{Protheus.doc} RU07T13RUS()

    This main function for load xml-dokument  by proactivity calculation

    @type Function
    @return 
    @author dchihov
    @since 09.11.2023
    @version 12.1.33
    @example RU07T13RUS()
*/
Function RU07T13RUS()

    Local aArea     As Array
    Local aButtons  As Array
    Local oTempTab  As Object
    Local oTemp2Tab As Object
    Local oTemp3Tab As Object
    Local cSaveFil  As Character

    Private cProcesso := ""
    Private aF07T13SSave := {"R8_FILIAL", "R8_TIPOAFA", "R8_DATAINI", "R8_OBSAFAS", "R8_DATAFIM", "R8_TPEFD", "R8_NMMED", ;
                        "R8_CRMMED", "R8_LAWSAL", "R8_INIPCHI", "R8_FIMPCHI", "R8_VIOLAT"}
    Private aF07T13LSave := {"R8_SEQ", "R8_CNPJSIN"}
    cSaveFil := cFilAnt

    aButtons := {{.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.T., STR0013}, ; // "Exit"
    {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}}

    aArea := GetArea()
    cRU07T1301MainAlias := RU07T1301_GetTempTable(@oTempTab)
    cRU07T1304Slave1Alias := RU07T1301_GetTempTable(@oTemp2Tab, 2)
    cRU07T1305TempSr8 := RU07T1301_GetTempTable(@oTemp3Tab, 3)
    lRU07T1301InitGrid := .T.
    lRU07T1302ProcSave := .F.

    If !IsBlind()
        FWExecView("", "VIEWDEF.RU07T13RUS", MODEL_OPERATION_UPDATE, , , , , aButtons, {|| RU07T1322_CheckByExit()})
    EndIf

    If oTempTab <> Nil
        oTempTab:Zap()
        oTempTab:Delete()
        FreeObj(oTempTab)
        oTempTab := Nil
    Endif
    If oTemp2Tab <> Nil
        oTemp2Tab:Zap()
        oTemp2Tab:Delete()
        FreeObj(oTemp2Tab)
        oTemp2Tab := Nil
    Endif
    If oTemp3Tab <> Nil
        oTemp3Tab:Zap()
        oTemp3Tab:Delete()
        FreeObj(oTemp3Tab)
        oTemp3Tab := Nil
    Endif
    cFilAnt := cSaveFil

    RestArea(aArea)

Return

/*/{Protheus.doc} MenuDef()

    MenuDef

    @type Function
    @return 
    @author dchihov
    @since 09.11.2023
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()

    Local aMenu := {} As Array

Return aMenu

/*/{Protheus.doc} ModelDef()

    ModelDef

    @type Function
    @return 
    @author dchihov
    @since 09.11.2023
    @version 12.1.33
    @example ModelDef()
*/
Static Function ModelDef()

    Local oModel  As Object
    Local oMaster As Object
    Local oStr1   As Object
    Local oStr2   As Object
    Local bLoad   As Block

    oMaster := FWFormModelStruct():New()
    oModel := MPFormModel():New('RU07T13RUS')
    oStr1 := FWFormModelStruct():New()
    oStr1:AddTable(cRU07T1301MainAlias, , cRU07T1301MainAlias)
    bLoad := {|oGridModel, lCopy| RU07T1302_LoadGrid(oGridModel, lCopy)}
        //          Titulo,      ToolTip,      Field ID,   Tipo, Tam,                     Dec,  Valid       ,When,          Combo,           Obrigat,          Init,       Chave,   Altera,      Virtual
    oStr1:AddField("LIST_OKK"   , "LIST_OKK"   , "LIST_OKK"   , "C", 1                      , 0   ,/*{|| }*/, /*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/,   /*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)
    oStr1:AddField("CheckBox"   , "CheckBox"   , "LIST_OK"    , "L", 1                      , 0   , {|oGrid, cId, xVal| oGrid:SetValue("LIST_OKK", Iif(xVal, "1", "0")), .T.}, {|oGrid, cId, xVal, nLin, xCurVal| xCurVal := Iif(xCurVal == Nil, xVal, xCurVal), CheckCanSelect(oGrid, cId, xCurVal, nLin)}/*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/,     ,           , .T.         ,             )
    oStr1:AddField(STR0006      , "LIST_SITFO" , "LIST_SITFO" , "C", 10                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Employee status"
    oStr1:AddField(STR0007      , "LIST_CIC"   , "LIST_CIC"   , "C", TamSx3("RA_CIC")[1]    , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "SNILS"
    oStr1:AddField(STR0008      , "LIST_NOME"  , "LIST_NOME"  , "C", TamSx3("RA_NOMECMP")[1], 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "FULL NAME"
    oStr1:AddField(STR0009      , "LIST_ELNNO" , "LIST_ELNNO" , "C", 12                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "No. ELN"
    oStr1:AddField(STR0010      , "LIST_DATIN" , "LIST_DATIN" , "D", TamSx3("R8_DATAINI")[1], 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Start date"
    oStr1:AddField(STR0011      , "LIST_CODEA" , "LIST_CODEA" , "C", 3                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Absence code"
    oStr1:AddField(STR0012      , "LIST_STATE" , "LIST_STATE" , "C", 3                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "ELN status"
    oStr1:AddField("LIST_CPROC" , "LIST_CPROC" , "LIST_CPROC" , "C", 5                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             )
    oStr1:AddField("LIST_CFIL"  , "LIST_CFIL"  , "LIST_CFIL"  , "C", TamSx3("RA_FILIAL")[1] , 0   ,/*{|| }*/, /*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/,   /*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)
    oStr1:AddField("LIST_CMAT"  , "LIST_CMAT"  , "LIST_CMAT"  , "C", TamSx3("RA_MAT")[1]    , 0   ,/*{|| }*/, /*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/,   /*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)
    oStr1:AddField("LIST_CANS"  , "LIST_CANS"  , "LIST_CANS"  , "C", 1                      , 0   ,/*{|| }*/, /*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/,   /*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)
    oStr1:AddField("LIST_CLOAD" , "LIST_CLOAD" , "LIST_CLOAD" , "C", 1                      , 0   ,/*{|| }*/, /*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/,   /*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)
    oStr1:AddField("LIST_NOTEE" , "LIST_NOTEE" , "LIST_NOTEE" , "C", 100                    , 0   ,/*{|| }*/, /*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/,   /*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)

    oStr2 := FWLoadModel("GPEA240"):GetModel("GPEA240_SR8"):GetStruct()
    oStr2:SetProperty("R8_SEQ", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'Gp240GetSeq()') )
    oMaster:AddTable("MASTER", , STR0002) // "Loading"
    oModel:AddFields("MASTER", /*cOwner*/, oMaster, , ,{|o|{}} )
    oModel:AddGrid("RU07T13LIST", "MASTER", oStr1, , , , , bLoad)
    oModel:AddGrid("GPEA240_SR8", "MASTER", oStr2)
    oModel:GetModel('GPEA240_SR8'):SetUseOldGrid(.T.)
    oMaster:Activate()
    oStr1:Activate()
    // oModel:GetModel("GPEA240_SR8"):SetOnlyView(.T.)
    // oModel:GetModel("GPEA240_SR8"):SetOnlyQuery(.T.)
    // oModel:GetModel("GPEA240_SR8"):SetNoInsertLine(.T.)
    oModel:GetModel("RU07T13LIST"):SetNoInsertLine(.T.)
    oModel:GetModel("GPEA240_SR8"):SetDescription(STR0003) // "Absences"
    oModel:SetRelation("GPEA240_SR8", {{"R8_FILIAL",'xFilial("SR8", ' + cRU07T1301MainAlias + '->LIST_CFIL)'}, {"R8_MAT", "LIST_CMAT"}}, SR8->(IndexKey()))

    oStr1:SetProperty("LIST_OK", MODEL_FIELD_INIT, {|| (cRU07T1301MainAlias)->LIST_OKK == "1"})
    oModel:SetPrimaryKey( {} )

Return oModel

/*/{Protheus.doc} ViewDef()

    ViewDef

    @type Function
    @return 
    @author dchihov
    @since 09.11.2023
    @version 12.1.33
    @example ViewDef()
*/
Static Function ViewDef()

    Local oView As Object
    Local oStr1 As Object
    Local oStr2 As Object
    
    oModel := FwLoadModel("RU07T13RUS")

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oStr1 := FWFormViewStruct():New()
    //              ID           Order Titulo   Descrip   Help Type  Pict     bPictVar LookUp CanCh  Ider cGroup Combo MaxLenCombo IniBrw, lVirt PicVar
    oStr1:AddField("LIST_OK"   , "01", ""     , "LIST_OK", Nil, "L", ""      , Nil   , ""     , .T., ""  , ""   , {}  , 0         , ""    , .T.)
    oStr1:AddField("LIST_SITFO", "02", STR0006, STR0006  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Employee status"
    oStr1:AddField("LIST_CIC"  , "03", STR0007, STR0007  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "SNILS"
    oStr1:AddField("LIST_NOME" , "04", STR0008, STR0008  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "FULL NAME"
    oStr1:AddField("LIST_ELNNO", "05", STR0009, STR0009  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "No. ELN"
    oStr1:AddField("LIST_DATIN", "06", STR0010, STR0010  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Start date"
    oStr1:AddField("LIST_CODEA", "07", STR0011, STR0011  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Absence code"
    oStr1:AddField("LIST_STATE", "08", STR0012, STR0012  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "ELN status"
    oStr2 := FWLoadView("GPEA240RUS"):GetViewStruct("GPEA240_SR8")

    oView:AddGrid("RU07T13LIST", oStr1)
    oView:AddGrid("GPEA240_SR8", oStr2)

    oView:createHorizontalBox("LIST", 50)
    oView:createHorizontalBox("GRID", 50)

    oView:SetViewProperty("GPEA240_SR8", "OnlyView")
    oView:SetNoInsertLine("GPEA240_SR8")
    oView:SetNoDeleteLine("GPEA240_SR8")

    oView:SetOwnerView("RU07T13LIST","LIST")
    oView:SetOwnerView("GPEA240_SR8","GRID")

    oView:SetViewProperty("RU07T13LIST", "CHANGELINE", {{ |oView, cViewID| RU07T1303_ChangeLine(oView:GetModel("RU07T13LIST"), oView:GetModel("GPEA240_SR8")), ;
    oView:Refresh("GPEA240_SR8")  }} )
    oView:SetDescription(STR0001) // "ELN"
    // oView:EnableTitleView("RU07T13LIST")
    oView:EnableTitleView("GPEA240_SR8")
    oView:SetAfterViewActivate({|oView| RU07T1310_AfterActive(oView)})

    oView:AddIncrementField("GPEA240_SR8","R8_SEQ")

    oView:SetCloseOnOk({ || .T. })
    oView:AddUserButton(STR0004, "BUTTON1", {|oView| RU07T1304_LoadXML(oView)}) // "Load from file"
    oView:AddUserButton(STR0035, "BUTTON2", {|oView| RU07T1314_MarkAll(oView, .F.)}) // "Mark all"
    oView:AddUserButton(STR0036, "BUTTON3", {|oView| RU07T1316_InvertMark(oView)}) // "Invert mark"
    oView:AddUserButton(STR0037, "BUTTON4", {|oView| RU07T1317_AddMarked(oView)}) // "Add marked"
    oView:AddUserButton(STR0038, "BUTTON5", {|oView| RU07T1323_Save(oView)}) // "Save"
    oView:AddUserButton(STR0039, "BUTTON6", {|oView| RU07T1325_CancelAddRows()}) // "Cancel
    // oView:AddUserButton(STR0005, "BUTTON2", {|oView| MSGINFO("Wait new version!", "Availible on new version")}) // "Fill from ELN"
    oView:SetViewAction("ASKONCANCELSHOW", { |oView| .F. } )

Return oView

/*/{Protheus.doc} RU07T1301_GetTempTable(oTempTable)

    This function create temporary table for data from XML.

    @type Function
    @param oTempTable, Object, Object for temp table/
    @return cRetAlias, Character, Alias of temporary table/
    @author dchihov
    @since 10.11.2023
    @version 12.1.33
    @example cRU07T1301MainAlias := RU07T1301_GetTempTable(@oTempTab)
*/
Function RU07T1301_GetTempTable(oTempTable, nTt)

    Local cRetAlias As Character
    Local aFields   As Array
    Local aSR8Field As Array
    Local nI        As Numeric

    Default nTt := 1

    cRetAlias := CriaTrab(Nil, .F.) // Get new alias of your temporary table.
    oTempTable := FWTemporaryTable():New(cRetAlias) // Create temporary table.
    aFields := {}
    // ELN table
    If nTt == 1
        aAdd(aFields, {"LIST_OKK"   , "C", 1                      , 00})
        aAdd(aFields, {"LIST_SITFO" , "C", 10                     , 00}) // RA_SITFOLH
        aAdd(aFields, {"LIST_CIC"   , "C", TamSx3("RA_CIC")[1]    , 00}) // RA_CIC
        aAdd(aFields, {"LIST_NOME"  , "C", TamSx3("RA_NOMECMP")[1], 00}) // RA_NOMECMP
        aAdd(aFields, {"LIST_ELNNO" , "C", 12                     , 00}) // ELN No
        aAdd(aFields, {"LIST_DATIN" , "D", TamSx3("R8_DATAINI")[1], 00}) // Date start
        aAdd(aFields, {"LIST_CODEA" , "C", 3                      , 00}) // Code of absence
        aAdd(aFields, {"LIST_STATE" , "C", 40                     , 00}) // ELN State
        aAdd(aFields, {"LIST_CSTAT" , "C", 3                      , 00}) // ELN State
        aAdd(aFields, {"LIST_CPROC" , "C", TamSx3("RA_PROCES")[1] , 00}) // RA_PROCESS
        aAdd(aFields, {"LIST_CFIL"  , "C", TamSx3("RA_FILIAL")[1] , 00}) // RA_FILIAL
        aAdd(aFields, {"LIST_CMAT"  , "C", TamSx3("RA_MAT")[1]    , 00}) // RA_MAT
        aAdd(aFields, {"LIST_CANS"  , "C", 1                      , 00}) // Can selected
        aAdd(aFields, {"LIST_CLOAD" , "C", 1                      , 00}) // State of load (0 - not load, 1 - load in grid, 2- loaded in grid, 3 - save in sr8, 9 - error)
        aAdd(aFields, {"LIST_NOTEE" , "C", 100                    , 00}) // Notification by error
        aAdd(aFields, {"LIST_TPAFA" , "C", TamSx3("R8_TIPOAFA")[1], 00}) // R8_TIPOAFA
        aAdd(aFields, {"LIST_TPFD"  , "C", TamSx3("R8_TPEFD")[1]  , 00}) // R8_TPEFD
        aAdd(aFields, {"LIST_NMED"  , "C", TamSx3("R8_NMMED")[1]  , 00}) // R8_NMMED
        aAdd(aFields, {"LIST_CRMED" , "C", TamSx3("R8_CRMMED")[1] , 00}) // R8_CRMMED
        aAdd(aFields, {"LIST_OGRN1" , "C", TamSx3("R8_CNPJSIN")[1], 00}) // R8_CNPJSIN
        aAdd(aFields, {"LIST_INIP"  , "D", TamSx3("R8_INIPCHI")[1], 00}) // R8_INIPCHI
        aAdd(aFields, {"LIST_FIMP"  , "D", TamSx3("R8_FIMPCHI")[1], 00}) // R8_FIMPCHI
        aAdd(aFields, {"LIST_VIOLD" , "D", TamSx3("R8_VIOLAT")[1] , 00}) // R8_VIOLAT
        aAdd(aFields, {"LIST_SRANO" , "C", 10                     , 00}) // SRA->(RecNo())
    ElseIf nTt == 2
        // Table for periods in ELN
        aAdd(aFields, {"PERD_RCD" , "N", 9                      , 00}) // Rec No LIST
        aAdd(aFields, {"PERD_DTS" , "D", TamSx3("R8_DATAINI")[1], 00}) // Date Start
        aAdd(aFields, {"PERD_DTF" , "D", TamSx3("R8_DATAINI")[1], 00}) // Date Fin
    ElseIf nTt == 3
        // Temp copy SR8 for added record? which yet not saved
        aSR8Field := FWLoadModel("GPEA240"):GetModel("GPEA240_SR8"):GetStruct():GetFields()
        For nI := 1 To Len(aSR8Field)
            aAdd(aFields, {aSR8Field[nI, 3], aSR8Field[nI, 4], aSR8Field[nI, 5], aSR8Field[nI, 6]})
        Next nI
        aAdd(aFields, {"RECNO", "N", 9, 00})
    EndIf
    oTemptable:SetFields(aFields) // Set columns.
    If nTt == 1
        oTempTable:AddIndex("1", {"LIST_NOME"})
        oTempTable:AddIndex("2", {"LIST_CMAT"})
        oTempTable:AddIndex("3", {"LIST_CIC"})
    ElseIf nTt == 2
        oTempTable:AddIndex("1", {"PERD_RCD"})
        oTempTable:AddIndex("2", {"PERD_RCD", "PERD_DTS", "PERD_DTF"})
    ElseIf nTt == 3
        oTempTable:AddIndex("1", {"R8_FILIAL", "R8_MAT","R8_SEQ"})
    EndIf
    oTempTable:Create()
    If nTt == 1
        cRU07T1302RealName := oTempTable:GetRealName()
    ElseIf nTt == 2
        cRU07T1303RealName2 := oTempTable:GetRealName()
    ElseIf nTt == 3
        cRU07T1306TempSr8 := oTempTable:GetRealName()
    EndIf

    DbSelectArea(cRetAlias)

Return cRetAlias

/*/{Protheus.doc} RU07T1302_LoadGrid(oGridModel, lCopy)

    This function Array with data for main grid.

    @type Function
    @param oGridModel, Object,  Grid model.
    @param lCopy,      Logical, Object for temp table.
    @return aLoad,     Array, Array for a grid.
    @author dchihov
    @since 10.11.2023
    @version 12.1.33
    @example bLoad := {|oGridModel, lCopy| RU07T1302_LoadGrid(oGridModel, lCopy)}
*/
Function RU07T1302_LoadGrid(oGridModel, lCopy)
    
    Local aLoad := {} As Array

    aLoad := FWLoadByAlias(oGridModel, cRU07T1301MainAlias, cRU07T1301MainAlias)

Return aLoad

/*/{Protheus.doc} RU07T1303_ChangeLine(oGrid, oChild)

    This function for change line in master grid. Refresh detail grid and make some things.

    @type Function
    @param oGrid,  Object, GridModel (master).
    @param oChild, Object, GridModel (detail).
    @return .T.
    @author dchihov
    @since 13.11.2023
    @version 12.1.33
    @example RU07T1303_ChangeLine(oView:GetModel("RU07T13LIST"), oView:GetModel("GPEA240_SR8"))
*/
Function RU07T1303_ChangeLine(oGrid, oChild)
    
    Local aTempData As Array
    Local aLoadData As Array
    Local nMat      As Numeric
    Local nFilial   As Numeric
    Local cMatCur   As Numeric
    Local cFilialC  As Numeric
    Local nI        As Numeric
    Local oView     As Object

    oView := FWViewActive()

    cProcesso := oGrid:GetValue("LIST_CPROC")
    (cRU07T1301MainAlias)->(DbGoTo(oGrid:GetDataID()))
    // Posicione SRA
    SRA->(DbGoTo(Val((cRU07T1301MainAlias)->LIST_SRANO)))
    AEval(oChild:aDataModel, {|X|, X[MODEL_GRID_ID] := 0})
    oChild:ClearData(.F., .F.)
    cFilAnt := SRA->RA_FILIAL
    aLoadData := FormLoadGrid(oChild)
    nMat := AScan(oChild:OFORMMODELSTRUCT:AFIELDS, {|X| X[MODEL_FIELD_IDFIELD] == "R8_MAT"})
    nFilial := AScan(oChild:OFORMMODELSTRUCT:AFIELDS, {|X| X[MODEL_FIELD_IDFIELD] == "R8_FILIAL"})
    If nMat > 0 .And. nFilial > 0
        // Add record from temp copy SR8
        cMatCur := oGrid:GetValue("LIST_CMAT")
        cFilialC := oGrid:GetValue("LIST_CFIL")
        (cRU07T1305TempSr8)->(DbGoTop())
        aTempData := FWLoadByAlias(oChild, cRU07T1305TempSr8, cRU07T1305TempSr8)
        For nI := 1 To Len(aTempData)
            If aTempData[nI, 2, nMat] == cMatCur .And. aTempData[nI, 2, nFilial] == cFilialC
                aTempData[nI, 1] := 0
                aAdd(aLoadData, AClone(aTempData[nI]))
            EndIf
        Next nI
    EndIf
    oChild:Load(aLoadData)
    // Need refresh for update all fields in model (especially R8_SEQ)
    oView:Refresh("GPEA240_SR8")

Return .T.

/*/{Protheus.doc} RU07T1304_LoadXML(oMainView)

    This function get xml from user and run loading data from XML-file.

    @type Function
    @param oMainView, Object, View of form.
    @return .T.
    @author dchihov
    @since 14.11.2023
    @version 12.1.33
    @example oView:AddUserButton(STR0004, "BUTTON1", {|oView| RU07T1304_LoadXML(oView)}) // "Load from file"
*/
Function RU07T1304_LoadXML(oMainView)
    
    Local cPathXML As Character
    Local aFiles   As Array

    cPathXML := cGetFile("*.xml|*.XML", STR0019, 1, "C:\", .T., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_MULTISELECT, .T., .T.) // "Selecting a file to download ELN"

    If Len(AllTrim(cPathXML)) > 0
        aFiles := StrTokArr(cPathXML, "|")
        MsAguarde({|| RU07T1305_ReadXML(oMainView, aFiles)}, STR0024, STR0025) // "Please wait", "Files uploaded"
        MostraErro()
        RU07T1309_UpdateGrid(oMainView)
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1305_ReadXML(oMainView, aFiles)

    This function load data from XML-file.

    @type Function
    @param oMainView, Object, View of form.
    @return .T.
    @author dchihov
    @since 14.11.2023
    @version 12.1.33
    @example MsAguarde({|| RU07T1305_ReadXML(oMainView, aFiles)}, STR0024, STR0025) // "Please wait", "Files uploaded"
*/
Function RU07T1305_ReadXML(oMainView, aFiles)
    
    Local cPathXML As Character
    Local cPath    As Character
    Local cTemp    As Character
    Local cName    As Character
    Local cSplSymb As Character
    Local cDrive   As Character
    Local cExtens  As Character
    Local aError   As Array
    Local cExcept  As Character
    Local cError   As Character
    Local bErro    As Block
    Local nCount   As Numeric
    Local nX       As Numeric
    Local nTemp    As Numeric
    Local lFirst   As Logical

    lFirst := .T.
    cExcept := cPath := ""
    aError := {}
    nCount := Len(aFiles)
    bErro := ErrorBlock( { |e| RU07T1307_Error(e, , @cExcept) } )
    cSplSymb := Iif("LINUX" $ Upper(GetSrvInfo()[2]), "/", "\")
    AutoGrLog(STR0022) // "Files:"
    Begin Sequence
        For nX := 1 To nCount
            cPathXML := AllTrim(aFiles[nX])
            If File(cPathXML, 2, .F.)
                If lFirst
                    lFirst := .F.
                    cPath := RU07T1306_MakeTmpDir()
                EndIf
                cTemp := cPath + cValToChar(Randomize(1, 50000)) + ".xml"
                While File(cTemp)
                    cTemp := cPath + cValToChar(Randomize(1, 50000)) + ".xml"
                EndDo
                SplitPath(cPathXML, , , @cName, @cExtens)
                CpyT2S(cPathXML, cPath)
                FRename(cPath + cName + cExtens, cTemp, , .F.)
                cPathXML := cTemp
            Else
                If nX > 1
                    nTemp := At("\", cPathXML)
                    cTemp := SubStr(cPathXML, 1, nTemp)
                    If cTemp <> SubStr(AllTrim(aFiles[1]), 1, nTemp)
                        cPathXML := SubStr(cPathXML, nTemp + 1)
                    EndIf
                EndIf
            EndIf
    
            If LoadXMLELN(oMainView, cPathXML, @cError)
                AutoGrLog(aFiles[nX])
            Else
                Aadd(aError, aFiles[nX] + Iif(Len(AllTrim(cError)) > 0,  CRLF + cError + CRLF + CRLF, ""))
            EndIf
            SplitPath(cPathXML, @cDrive)
            If Len(AllTrim(cName) + AllTrim(cExtens)) > 0 .And. Empty(cDrive)
                FErase(cPathXML)
            EndIf
            cName := cExtens := ""
            MsProcTxt(STR0025 + " " + CValToChar(nX) + "/" + CValToChar(nCount)) // "Files uploaded"
        Next nX
    End Sequence
    ErrorBlock(bErro)
    AutoGrLog(STR0023) // "uploaded successfully"
    If Len(cPath) > 0
        SplitPath(cPathXML, @cDrive)
        If Len(AllTrim(cName) + AllTrim(cExtens)) > 0 .And. Empty(cDrive) .And. File(cPathXML)
            FErase(cPathXML)
        EndIf
        DirRemove(cPath)
    EndIf
    If Len(aError) > 0
        AutoGrLog(CRLF)
        AutoGrLog(STR0020) // "The following files could not be parsed:"
        AutoGrLog(CRLF)
        For nX := 1 To Len(aError)
            AutoGrLog(aError[nX])
        Next nX
        AutoGrLog(STR0021) // "maybe they are damaged"
    EndIf
    If Len(cExcept) > 0
        AutoGrLog(CRLF)
        AutoGrLog(cExcept)
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1306_MakeTmpDir()

    This function make temporary directory and return path.

    @type Function
    @return cPath, Character, Path to temp directory
    @author dchihov
    @since 15.11.2023
    @version 12.1.33
    @example cPath := RU07T1306_MakeTmpDir()
*/
Function RU07T1306_MakeTmpDir()

    Local cSplSymb As Character
    Local cPath    As Character
    Local cTemp    As Character
    Local cUPath   As Character
    Local cDPath   As Character
    Local aDirInf  As Array
    Local aFileInf As Array
    Local dDateOld As Date
    Local cDateOld As Character
    Local nX       As Numeric

    cSplSymb := Iif("LINUX" $ Upper(GetSrvInfo()[2]), "/", "\")
    cPath := "spool" + cSplSymb
    If !ExistDir(cPath)
        MakeDir(cPath)
    EndIf
    cPath += "temp"  + cSplSymb
    If !ExistDir(cPath)
        MakeDir(cPath, , .F.)
    EndIf
    cUPath := "xmlt13" + AllTrim(__cUserId)
    dDateOld := Date() - 1
    cDateOld := DToS(dDateOld)
    cDPath := cUPath + DToS(dDateOld)
    aDirInf := Directory(cPath + "*", "D", , .F.)
    For nX := 1 To Len(aDirInf)
        If "xmlt13" == SubStr(aDirInf[nX, 1], 1, 6) .And. SubStr(aDirInf[nX, 1], 13, 8) <= cDateOld .And. aDirInf[nX, 3] <= dDateOld /// May be job better?
            aFileInf := Directory(cPath + aDirInf[nX, 1] + cSplSymb + "*.xml", , , .F.)
            AEval(aFileInf, {|X| FErase(cPath + aDirInf[nX, 1] + cSplSymb + X[1])})
            DirRemove(cPath + aDirInf[nX, 1])
        EndIf
    Next nX
    cDPath := cUPath + DToS(dDateOld + 1)
    cPath += cDPath
    cTemp := cPath + cValToChar(Randomize(1, 500)) + cSplSymb
    While ExistDir(cTemp)
        cTemp := cPath + cValToChar(Randomize(1, 500)) + cSplSymb
    EndDo
    cPath := cTemp
    MakeDir(cPath, , .F.)
    
Return cPath

/*/{Protheus.doc} RU07T1307_Error(e, lErro, cError)

    This function for error.

    @type Function
    @param e,      Object,    Object of error.
    @param lErro,  Logical,   Is error.
    @param cError, Character, Message of error.
    @return 
    @author dchihov
    @since 16.11.2023
    @version 12.1.33
    @example bErro := ErrorBlock( { |e| RU07T1307_Error(e, , @cExcept) } )
*/
Function RU07T1307_Error(e, lErro, cError)

    lErro := e:gencode > 0
    cError += "Error:" + CRLF + CRLF +  e:description + CRLF + CRLF + "Stack:" + CRLF + e:errorstack + CRLF + CRLF
    Break

Return

/*/{Protheus.doc} LoadXMLELN(oMainView)

    This function read data from XML-file and write into grid.

    @type Function
    @param oMainView, Object, View of form.
    @param cPath,  Character, Path to XML.
    @param cErr,   Character, Message of error.
    @return lSuccess, Logical, Success reading XML-file.
    @author dchihov
    @since 14.11.2023
    @version 12.1.33
    @example LoadXMLELN(oMainView, cPathXML)
*/
Static Function LoadXMLELN(oMainView, cPath, cErr)

    Local oXMLReader As Object
    Local lSuccess   As Logical

    oXMLReader := RUHRElnXMLReader():New(cPath)
    lSuccess := oXMLReader:ReadXML()
    cErr := ""
    If !lSuccess
        cErr := Iif(Empty(oXMLReader:cError), "", oXMLReader:cError)
    EndIf
    If lSuccess
        lSuccess := oXMLReader:LoadPerFromDictionary()
        If !lSuccess
            cErr := Iif(Empty(oXMLReader:cError), "", oXMLReader:cError)
        EndIf
    EndIf
    If lSuccess
        RU07T1308_FillTempTable(oXMLReader:aTablePerson, oXMLReader:nCSE)
    EndIf

    oXMLReader:Destroy()
    FreeObj(oXMLReader)
    oXMLReader := Nil

Return lSuccess

/*/{Protheus.doc} RU07T1308_FillTempTable(aTablePers, nZS)

    This function Filling temptable persons data.

    @type Function
    @param aTablePers, Array, Array of persons
    @param nZS,      Numeric, Count system elem in table pers
    @return nCount, Numeric, Count of record, which writing into temp table.
    @author dchihov
    @since 27.11.2023
    @version 12.1.33
    @example RU07T1308_FillTempTable(oXMLReader:aTablePerson, oXMLReader:nSLE)
*/
Function RU07T1308_FillTempTable(aTablePers, nZS)

    Local nI     As Numeric
    Local nK     As Numeric
    Local nCount As Numeric

    nCount := 0

    For nI := 1 To Len(aTablePers)

        If RecLock(cRU07T1301MainAlias, .T.)
            (cRU07T1301MainAlias)->LIST_OKK   := "0"
            (cRU07T1301MainAlias)->LIST_SITFO := Iif(Empty(aTablePers[nI, 1, 5]), "", aTablePers[nI, 1, 5])
            (cRU07T1301MainAlias)->LIST_CIC   := Iif(Empty(aTablePers[nI, 1, 3]), aTablePers[nI, nZS + 1, 2], aTablePers[nI, 1, 3])
            (cRU07T1301MainAlias)->LIST_NOME  := Iif(Empty(aTablePers[nI, 1, 4]), aTablePers[nI, nZS + 2, 2] + " " + aTablePers[nI, nZS + 3, 2] + " " + ;
                                        aTablePers[nI, nZS + 4, 2], aTablePers[nI, 1, 4])
            (cRU07T1301MainAlias)->LIST_ELNNO := aTablePers[nI, nZS + 5, 2]
            (cRU07T1301MainAlias)->LIST_DATIN := aTablePers[nI, nZS + 6, 2]
            (cRU07T1301MainAlias)->LIST_CODEA := aTablePers[nI, nZS + 7, 2]
            (cRU07T1301MainAlias)->LIST_STATE := RU07T1313_GetTitleStateByCod(aTablePers[nI, nZS + 8, 2])
            (cRU07T1301MainAlias)->LIST_CSTAT := aTablePers[nI, nZS + 8, 2]
            (cRU07T1301MainAlias)->LIST_CPROC := Iif(Empty(aTablePers[nI, 1, 6]), "", aTablePers[nI, 1, 6])
            (cRU07T1301MainAlias)->LIST_CFIL  := Iif(Empty(aTablePers[nI, 1, 2]), "", aTablePers[nI, 1, 2])
            (cRU07T1301MainAlias)->LIST_CMAT  := Iif(Empty(aTablePers[nI, 1, 1]), "", aTablePers[nI, 1, 1])
            (cRU07T1301MainAlias)->LIST_CANS  := Iif(RU07T1312_EmplCanSelect(), "1", "0")
            (cRU07T1301MainAlias)->LIST_CLOAD := "0"
            (cRU07T1301MainAlias)->LIST_NOTEE := ""
            (cRU07T1301MainAlias)->LIST_TPAFA := RU07T1390_GetCodByCod(1, aTablePers[nI, nZS + 7, 2])
            (cRU07T1301MainAlias)->LIST_TPFD  := RU07T1390_GetCodByCod(2, aTablePers[nI, nZS + 7, 2])
            (cRU07T1301MainAlias)->LIST_NMED  := aTablePers[nI, nZS + 9, 2]
            (cRU07T1301MainAlias)->LIST_CRMED := aTablePers[nI, nZS + 10, 2]
            (cRU07T1301MainAlias)->LIST_OGRN1 := aTablePers[nI, nZS + 11, 2]
            (cRU07T1301MainAlias)->LIST_INIP  := aTablePers[nI, nZS + 12, 2]
            (cRU07T1301MainAlias)->LIST_FIMP  := aTablePers[nI, nZS + 13, 2]
            (cRU07T1301MainAlias)->LIST_VIOLD := aTablePers[nI, nZS + 14, 2]
            (cRU07T1301MainAlias)->LIST_SRANO := Iif(Empty(aTablePers[nI, 1, 7]), "0", aTablePers[nI, 1, 7])
            (cRU07T1301MainAlias)->(MsUnLock())
            For nK := 1 To Len(aTablePers[nI, 2])
                // Save periods from ELN
                If RecLock(cRU07T1304Slave1Alias, .T.)
                    (cRU07T1304Slave1Alias)->PERD_RCD := (cRU07T1301MainAlias)->(RecNo())
                    (cRU07T1304Slave1Alias)->PERD_DTS := aTablePers[nI, 2, nK, 1]
                    (cRU07T1304Slave1Alias)->PERD_DTF := aTablePers[nI, 2, nK, 2]
                    (cRU07T1304Slave1Alias)->(MsUnLock())
                EndIf
            Next nK
            nCount += 1
        EndIf

    Next nI

Return nCount

/*/{Protheus.doc} RU07T1309_UpdateGrid(oMainView)

    This function update view.

    @type Function
    @param oMainView, Object, View of form.
    @return 
    @author dchihov
    @since 27.11.2023
    @version 12.1.33
    @example RU07T1309_UpdateGrid(oMainView)
*/
Function RU07T1309_UpdateGrid(oMainView)

    Local oList    As Object
    Local aData    As Array
    Local aNewData As Array
    Local nI       As Numeric

    oList := oMainView:GetModel("RU07T13LIST")
    aData := RU07T1302_LoadGrid(oList, .F.)

    aNewData := {}
    For nI := 1 To Len(aData)
        If AScan(oList:aDataModel, {|X| X[MODEL_GRID_ID] == aData[nI, 1]}) < 1
            Aadd(aNewData, aData[nI])
        EndIf
    Next nI

    If Len(aNewData) > 0
        If lRU07T1301InitGrid
            AEval(oList:aDataModel, {|X|, X[MODEL_GRID_ID] := 0})
            oList:ClearData(.F., .F.)
            lRU07T1301InitGrid := .F.
        EndIf
        oList:Load(aNewData)
        oMainView:Refresh("RU07T13LIST")
        RU07T1303_ChangeLine(oList, oMainView:GetModel("GPEA240_SR8"))
    EndIf

Return 

/*/{Protheus.doc} RU07T1310_AfterActive(oView)

    This function Make some things? which need do after activate view.

    @type Function
    @param oView, Object, Main view.
    @return .T.
    @author dchihov
    @since 12.12.2023
    @version 12.1.23.10
    @example oView:SetAfterViewActivate({|oView| RU07T1310_AfterActive(oView)})
*/
Function RU07T1310_AfterActive(oView)

    Local oBrowse As Object

    oBrowse := oView:GetViewObj("RU07T13LIST")[3]

    oBrowse:oBrowse:aColumns[1]:SetHeaderImage("")
    oBrowse:oBrowse:aColumns[1]:SetHeaderClick( {|| RU07T1314_MarkAll()} )
    oBrowse:oBrowse:SetBlkBackColor(&("{|| RU07T1311_CheckEmpl(Self:oData:aShow[Self:nAt][3], .T., Self:oData:oSubmodel:aDataModel[Self:oData:aShow[Self:nAt, Self:oData:nPosModelLine], " + CValToChar(MODEL_GRID_ID) + "])}"))
    // oBrowse:oBrowse:SetBlkBackColor({|| RU07T1311_CheckEmpl(oBrowse:oBrowse:ODATA:ASHOW[oBrowse:oBrowse:nAt][3], .T.)})
    oBrowse:oBrowse:SetBlkColor({|| CLR_BLACK})


Return .T.

/*/{Protheus.doc} RU07T1311_CheckEmpl(cSNILS, lNum, nIdRec)

    This function check exist TN for snils.

    @type Function
    @param cSNILS, Character, Snils for view.
    @param lNum,   Numeric, Mode for call function.
    @param nIdRec, Numeric, Id record.
    @return xRes, Result (if mode non numeric it's logical, numeric mode for get color).
    @author dchihov
    @since 29.11.2023
    @version 12.1.33
    @example oBrowse:oBrowse:SetBlkBackColor({|| RU07T1311_CheckEmpl(oBrowse:oBrowse:ODATA:ASHOW[oBrowse:oBrowse:nAt][3], .T.)})
*/
Function RU07T1311_CheckEmpl(cSNILS, lNum, nIdRec)

    Local aArea  As Array
    Local aTArea As Array
    Local lCans  As Logical
    Local xRes

    Default lNum := .F.

    xRes := .F.

    aArea := GetArea()
    aTArea := (cRU07T1301MainAlias)->(GetArea())
    (cRU07T1301MainAlias)->(DbSetOrder(3))
    If nIdRec > 0
        (cRU07T1301MainAlias)->(DbGoTo(nIdRec))
        lCans := !Empty(AllTrim((cRU07T1301MainAlias)->LIST_CIC))
    Else
        lCans := (cRU07T1301MainAlias)->(MsSeek(cSNILS))
    EndIf

    // If lNum - return color
    If lNum
        If lCans .And. (cRU07T1301MainAlias)->LIST_CANS == "1"
            If (cRU07T1301MainAlias)->LIST_CLOAD == "9"
                // state for error when adding or save record
                xRes := CLR_LIGHTGRAY
            Else
                If CheckCanSelect(,,,, .F.) .Or. (cRU07T1301MainAlias)->LIST_CLOAD == "2"
                    // normal state
                    xRes := CLR_WHITE
                Else
                    // Can't select row
                    xRes := CLR_LIGHTGRAY
                EndIf
            EndIf
        Else
            // state for not finding employee
            xRes := CLR_HRED
        EndIf
    Else
        If (cRU07T1301MainAlias)->(MsSeek(cSNILS)) .And. (cRU07T1301MainAlias)->LIST_CANS == "1" .And. CheckCanSelect(,,,, .F.)
            xRes := .T.
        EndIf
    EndIf

    (cRU07T1301MainAlias)->(RestArea(aTArea))
    RestArea(aArea)

Return xRes

/*/{Protheus.doc} RU07T1312_EmplCanSelect()

    This function defines the conditions for selecting the current employee.

    @type Function
    @return lRes, Logical, Exist.
    @author dchihov
    @since 07.11.2023
    @version 12.1.33
    @example lRes := RU07T1312_EmplCanSelect()
*/
Function RU07T1312_EmplCanSelect()

    Local lRes   As Logical

    lRes := .F.

    If !Empty(AllTrim((cRU07T1301MainAlias)->LIST_CMAT))
        lRes := .T.
    EndIf

Return lRes

/*/{Protheus.doc} CheckCanSelect()

    This function check can select the record.

    @type Function
    @param oGrid,    Object,    Main Grid.
    @param cIdField, Character, Id field in grid.
    @param xVal,              , Current value for field.
    @param nLin,     Numeric,   Number of current line in grid.
    @param lVis,     Logical,   Show msg for user.
    @param nIdRec,   Numeric,   Id record.
    @return lRes, Logical, Can select.
    @author dchihov
    @since 26.12.2023
    @version 12.1.23.10
    @example {|oGrid, cId, xVal, nLin| CheckCanSelect(oGrid, cId, xVal, nLin)}
*/
Static Function CheckCanSelect(oGrid, cIdField, xVal, nLin, lVis, nIdRec)

    Local lRes  As Logical
    Local nType As Numeric

    Default oGrid := Nil
    Default cIdField := ""
    Default xVal := .F.
    Default nLin := 0
    Default lVis := .T.
    Default nIdRec := -1

    lRes := .F.
    nType := 0

    // If get param by grid for posicione in table
    If nLin > 0
        (cRU07T1301MainAlias)->(DbGoTo(oGrid:aDataModel[nLin][MODEL_GRID_ID]))
    // If get id
    ElseIf nIdRec > -1
        (cRU07T1301MainAlias)->(DbGoTo(nIdRec))
    EndIf

    // Can Select employee
    If (cRU07T1301MainAlias)->LIST_CANS == "1"
        // Current value = .T. and current make is uncheck
        If xVal
            lRes := .T.
        // Record already added
        ElseIf (cRU07T1301MainAlias)->LIST_CLOAD $ STATE_OF_LOADED
            // Number of msg for visible
            nType := 1
        // ELN not closed
        ElseIf (cRU07T1301MainAlias)->LIST_CSTAT <> STATE_OF_CLOSED
            // Number of msg for visible
            nType := 2
        Else 
            // Record can be selected
            lRes := .T.
        EndIf
    EndIf

    If lVis .And. nType > 0
        If nType == 1
            MsgInfo(STR0058) // "This entry has already been added"
        ElseIf nType == 2
            MsgInfo(STR0059) // "Only closed ELNs are available for selection"
        EndIf
    EndIf

Return lRes

/*/{Protheus.doc} RU07T1313_GetTitleStateByCod(cCode)

    This function get title for code of state.

    @type Function
    @param cCode, Character, Code of state.
    @return cTitle, Character, Title for Code.
    @author dchihov
    @since 04.12.2023
    @version 12.1.33
    @example (cRU07T1301MainAlias)->LIST_STATE := RU07T1313_GetTitleStateByCod(aTablePers[nI, 9, 2])
*/
Function RU07T1313_GetTitleStateByCod(cCode)

    Local cTitle As Character

    Do Case
        Case cCode == "010"
            cTitle := STR0026 // "open"
        Case cCode == "020"
            cTitle := STR0027 // "extended"
        Case cCode == "030"
            cTitle := STR0028 // "closed"
        Case cCode == "040"
            cTitle := STR0029 // "referral to ITU"
        Case cCode == "050"
            cTitle := STR0030 // "supplemented with ITU data"
        Case cCode == "060"
            cTitle := STR0031 // "filled in by the Policyholder"
        Case cCode == "070"
            cTitle := STR0032 // "filled in by the Policyholder (PVSO register)"
        Case cCode == "080"
            cTitle := STR0033 // "Benefit paid"
        Case cCode == "090"
            cTitle := STR0034 // "Actions terminated"
        OtherWise
            cTitle := cCode
    EndCase

Return cTitle

/*/{Protheus.doc} RU07T1314_MarkAll(oView)

    This functionmark/unmark all.

    @type Function
    @param oView,     Object,  Main view.
    @param lFromGrid, Logical, Called from Grid.
    @param lUnmark,   Logical, Unmark mode.
    @return 
    @author dchihov
    @since 04.12.2023
    @version 12.1.23.10
    @example oView:AddUserButton(STR0035, "BUTTON2", {|oView| RU07T1314_MarkAll(oView)}) // "Mark all"
*/
Function RU07T1314_MarkAll(oView, lFromGrid, lUnmark)

    Local cQuery As Character
    Local cAlias As Character
    Local nCount As Numeric
    Local oGrid  As Object
    Local oModel As Object
    Local nI     As Numeric
    Local lVal   As Logical
    local nLine1 As Numeric
    local nLine2 As Numeric
    local nLineB As Numeric
    Local aArea  As Array
    Local oBrw   As Object
    Local aCursorPos As Array
    
    Default oView := FWViewActive()
    Default lFromGrid := .T.
    Default lUnmark := .F.

    oModel := FWModelActivate()
    oGrid := oModel:GetModel("RU07T13LIST")
    // If grid not empty
    If oGrid:GetDataId() > 0
        aArea := GetArea()

        // saved line pos in grid
        oBrw := oView:GetViewObj("RU07T13LIST")[3]
        nLine1 := oGrid:NLINE
        nLineB := oBrw:oBrowse:nAt
        aCursorPos := oBrw:oBrowse:oBrowse:GetCursorPos()
        // save grid in database
        RU07T1315_SaveLIST(oGrid)

        If lUnmark
            // Hard mode unmark
            lVal := .F.
        Else
            // If exist record which can be select, but not select - mode allmark else unmark
            cQuery := "SELECT R_E_C_N_O_ AS RECN FROM " + cRU07T1302RealName + CRLF
            cQuery += "WHERE LIST_CANS = '1' AND  LIST_OKK = '0'"

            cAlias := GetNextAlias()

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

            nCount := 0
            (cAlias)->(DbGoTop())
            While !(cAlias)->(EOF())
                If CheckCanSelect(,,,, .F., (cAlias)->RECN)
                    nCount += 1
                    Exit
                EndIf
                (cAlias)->(DbSkip())
            EndDo

            (cAlias)->(DbCloseArea())

            If nCount > 0
                lVal := .T.
            Else
                lVal := .F.
            EndIf
        EndIf

        For nI := 1 To oGrid:Length()
            oGrid:GoLine(nI)
            If oGrid:GetValue("LIST_CANS") == "1" .And. CheckCanSelect(oGrid,, oGrid:GetValue("LIST_OK"), nI, .F.)
                // set mark/unmark
                oGrid:SetValue("LIST_OK", lVal)
            EndIf
        Next nI
        // Pos selected row
        nLine2 := oBrw:oBrowse:oData:aShow[oBrw:oBrowse:aVisibleReg[1], oBrw:oBrowse:oData:nPosModelLine]
        // Save grid in database
        RU07T1315_SaveLIST(oGrid)

        // Rest line pos and scroll
        oGrid:GoLine(nLine2)

        oView:Refresh("RU07T13LIST")
        If(lFromGrid)
            oGrid:GoLine(nLine1)
        EndIf

        // Rest selected pos
        oBrw:oBrowse:nCursorPos := aCursorPos[1] 
        oBrw:oBrowse:SelectRow(aCursorPos[1])
        oBrw:oBrowse:Goto(nLineB, .F., .T.)
        RestArea(aArea)
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1315_SaveLIST(oGrid)

    This function save list model (grid for list).

    @type Function
    @return 
    @author dchihov
    @since 08.12.2023
    @version 12.1.23.10
    @example RU07T1315_SaveLIST(oGrid)
*/
Static Function RU07T1315_SaveLIST(oGrid)

    Local nI          As Numeric
    Local cQuery      As Character

    cQuery := ""
    For nI := 1 To oGrid:Length()
        // Build query for update record in database from grid
        cQuery += "UPDATE " + cRU07T1302RealName + " SET LIST_OKK = " + Iif(oGrid:GetValue("LIST_OK", nI), "'1',", "'0',")
        cQuery += " LIST_CLOAD = '" + oGrid:GetValue("LIST_CLOAD", nI) + "',"
        cQuery += " LIST_NOTEE = '" + oGrid:GetValue("LIST_NOTEE", nI) + "'"
        cQuery += " WHERE R_E_C_N_O_ = " + CValToChar(oGrid:GetDataID(nI)) + ";" + CRLF
        If nI % 10 == 0
            // If in query more 10 record - execute query and clean str query
            TCSQLeXEC(cQuery)
            cQuery := ""
        EndIf
    Next nI

    If !Empty(cQuery)
        // If query not empty - last query not execute
        TCSQLeXEC(cQuery)
        cQuery := ""
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1316_InvertMark(oView)

    This function invert mark.

    @type Function
    @param oView, Object, Main view.
    @return 
    @author dchihov
    @since 08.12.2023
    @version 12.1.23.10
    @example oView:AddUserButton(STR0036, "BUTTON3", {|oView| RU07T1316_InvertMark(oView)}) // "Invert mark"
*/
Function RU07T1316_InvertMark(oView)

    Local oGrid  As Object
    Local oModel As Object
    Local oBrw   As Object
    Local nI     As Numeric
    local nLine1 As Numeric
    local nLine2 As Numeric
    Local aCursorPos As Array
    
    Default oView := FWViewActive()

    oModel := FWModelActivate()
    oGrid := oModel:GetModel("RU07T13LIST")
    oBrw := oView:GetViewObj("RU07T13LIST")[3]
    // If grid not empty
    If oGrid:GetDataId() > 0

        // Save line pos and select row in grid
        nLine1 := oGrid:NLINE
        aCursorPos := oView:GetViewObj("RU07T13LIST")[3]:oBrowse:oBrowse:GetCursorPos()
        RU07T1315_SaveLIST(oGrid)

        For nI := 1 To oGrid:Length()
            oGrid:GoLine(nI)
            If oGrid:GetValue("LIST_OK") == .T.
                oGrid:SetValue("LIST_OK", .F.)
            ElseIf oGrid:GetValue("LIST_CANS") == "1" .And. CheckCanSelect(oGrid,,, nI, .F.)
                oGrid:SetValue("LIST_OK", .T.)
            EndIf
        Next nI
        nLine2 := oBrw:oBrowse:oData:aShow[oBrw:oBrowse:aVisibleReg[1], oBrw:oBrowse:oData:nPosModelLine]
        RU07T1315_SaveLIST(oGrid)
        // Rest line pos on first str in view grid
        oGrid:GoLine(nLine2)
        oView:Refresh("RU07T13LIST")
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1317_AddMarked(oView)

    This function add record to sr8.

    @type Function
    @param oView, Object, Main view.
    @return 
    @author dchihov
    @since 08.12.2023
    @version 12.1.23.10
    @example oView:AddUserButton(STR0037, "BUTTON4", {|oView| RU07T1317_AddMarked(oView)}) // "Add marked"
*/
Static Function RU07T1317_AddMarked(oView)

    Local oModel      As Object
    Local oGrid       As Object
    Local oBrw        As Object
    Local nLineB      As Numeric
    Local nLine1      As Numeric
    Local nLine       As Numeric
    Local nI          As Numeric
    Local lSuccess    As Logical
    Local cSaveFil    As Character

    Default oView := FWViewActive()

    oModel := FWModelActivate()
    oGrid := oModel:GetModel("RU07T13LIST")
    oBrw := oView:GetViewObj("RU07T13LIST")[3]
    cSaveFil := cFilAnt

    // Grid not empty
    If oGrid:GetDataId() > 0
        // Save line pos and selected row
        nLine1 := oGrid:NLINE
        nLineB := oBrw:oBrowse:nAt
        aCursorPos := oBrw:oBrowse:oBrowse:GetCursorPos()

        // Save grid in database
        RU07T1315_SaveLIST(oGrid)
        For nI := 1 To oGrid:Length()
            oGrid:GoLine(nI)
            If oGrid:GetValue("LIST_OK") .And. !(oGrid:GetValue("LIST_CLOAD") $ STATE_OF_LOADED)
                // Set mark for load record
                oGrid:SetValue("LIST_CLOAD", "1")
            EndIf
        Next nI
        // Save grid in database
        RU07T1315_SaveLIST(oGrid)

        // Save added row in temp SR8 table and valid added rows
        MsAguarde({|| lSuccess := RU07T1318_SaveAdded(oView, oGrid)}, STR0024, STR0040) // "Please wait", "Loading Absences"
        If lSuccess
            MsgInfo(STR0041) // "Absences loaded successfully"
        Else
            MostraErro()
        EndIf
        cFilAnt := cSaveFil
        // Search first visible row
        nLine := oBrw:oBrowse:oData:aShow[oBrw:oBrowse:aVisibleReg[1], oBrw:oBrowse:oData:nPosModelLine]
        RU07T1315_SaveLIST(oGrid)
        // Rest line pos
        oGrid:GoLine(nLine)
        oView:Refresh("RU07T13LIST")
        // Update grid for absence
        RU07T1303_ChangeLine(oGrid, oModel:GetModel("GPEA240_SR8"))
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1318_SaveAdded(oView, oGrid, lSave)

    This function Saves data in SR8 (simulation mode available).

    @type Function
    @param oView, Object,  Main view.
    @param lSave, Logical, Save in database.
    @return lSuccess, Logical, Is success.
    @author dchihov
    @since 08.12.2023
    @version 12.1.23.10
    @example MsAguarde({|| lSuccess := RU07T1318_SaveAdded(oView, oGrid)}, STR0024, STR0040) // "Please wait", "Loading Absences"
*/
Static Function RU07T1318_SaveAdded(oView, oGrid, lSave)

    Local cQuery      As Character
    Local cAlias      As Character
    Local oModel      As Object
    Local oHGrid      As Object
    Local oBrw        As Object
    Local lSuccess    As Logical
    Local aArea       As Array
    Local aLISTArea   As Array
    Local bErro       As Block

    oModel := FWModelActivate()
    Default oView := FWViewActive()
    Default oGrid := oModel:GetModel("RU07T13LIST")
    Default lSave := .F.

    aArea := GetArea()
    aLISTArea := (cRU07T1301MainAlias)->(GetArea())
    oBrw := oView:GetViewObj("RU07T13LIST")[3]
    oHGrid := oModel:GetModel("GPEA240_SR8")

    cExcept := ""
    lSuccess := .F.
    // Custom error handling
    bErro := ErrorBlock( { |e| RU07T1307_Error(e, , @cExcept) } )

    // Save line pos in grid
    nLine := oGrid:NLINE
    aCursorPos := oView:GetViewObj("RU07T13LIST")[3]:oBrowse:oBrowse:GetCursorPos()

    Begin Sequence

        // Get list of employee for load absence
        cQuery := "SELECT DISTINCT LIST_CMAT, LIST_CFIL FROM " + cRU07T1302RealName + CRLF
        cQuery += "WHERE LIST_CLOAD = " + Iif(lSave, "'2'", "'1'")

        cAlias := GetNextAlias()

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())

        While !(cAlias)->(EOF())
            // Search first line in ELN grid for epmloyee
            If oGrid:SeekLine({{"LIST_CMAT", (cAlias)->LIST_CMAT}, {"LIST_CFIL", (cAlias)->LIST_CFIL}})
                // Posicione in alias on find record
                (cRU07T1301MainAlias)->(DbGoTo(oGrid:GetDataID()))
                // Update grid with absence
                RU07T1303_ChangeLine(oGrid, oHGrid)
                If lSave
                    // If saving recod - save current grid of absence
                    lSuccess := RU07T1324_SaveAddedRows(oView, oModel)
                    If !lSuccess
                        cExcept += CRLF + STR0049 + " " + (cAlias)->LIST_CMAT + "(" + (cAlias)->LIST_CFIL + ")" // "Error when saving absence for an employee"
                        Exit
                    EndIf
                Else
                    // If adding rows - load line n grid of absense? validate line and save in temp SR8
                    RU07T1319_LoadAddedRows(oHGrid, oGrid, oModel)
                EndIf
            EndIf
            (cAlias)->(DbSkip())
        EndDo

        (cAlias)->(DbCloseArea())

    End Sequence
    // Return standart error handling
    ErrorBlock(bErro)
    // Rest line pos in grid of ELN
    nLine := oBrw:oBrowse:oData:aShow[oBrw:oBrowse:aVisibleReg[1], oBrw:oBrowse:oData:nPosModelLine]
    oGrid:GoLine(nLine)

    RestArea(aArea)
    (cRU07T1301MainAlias)->(RestArea(aLISTArea))
    If Empty(cExcept) .And. (!lSave .Or. lSuccess)
        lSuccess := .T.
    Else
        // writing about error in log
        AutoGrLog(STR0042 + CRLF + CRLF) // "Errors occurred while loading absences:"
        AutoGrLog(cExcept) // "Errors occurred while loading absences:"
        lSuccess := .F.
    EndIf
    
Return lSuccess

/*/{Protheus.doc} RU07T1319_LoadAddedRows(oGrid, oHGrid, oModel)

    This function Saves data in temp SR8-copy.

    @type Function
    @param oGrid, Object, Grid for SR8.
    @param oHGrid, Object, MainGrid.
    @param oModel, Object, MainModel.
    @return lSuccess, Logical, Is success.
    @author dchihov
    @since 11.12.2023
    @version 12.1.23.10
    @example RU07T1319_LoadAddedRows(oModel:GetModel("GPEA240_SR8"), oGrid)
*/
Static Function RU07T1319_LoadAddedRows(oGrid, oHGrid, oModel)

    Local nI          As Numeric
    Local nK          As Numeric
    Local nItem       As Numeric
    Local aArea       As Array
    Local aSRAArea    As Array
    Local aRCMArea    As Array
    Local nLine       As Numeric
    Local nCurLine    As Numeric
    Local nLineNew    As Numeric
    Local aAddedRow   As Array
    Local lLineNSave  As Logical
    Local cSaveFil    As Character
    Local lSuccess    As Logical
    Local cError      As Character
    Local aFielFill   As Array

    // Default oView := FWViewActive()
    Default oModel := FWModelActive()

    aArea := GetArea()
    aSRAArea := SRA->(GetArea())
    aRCMArea := RCM->(GetArea())
    aFielFill := {{{"R8_DATAFIM", 4}, {"R8_TPEFD", 6}, {"R8_NMMED", 7}, {"R8_CRMMED", 8}, {"R8_CNPJSIN", 9}}, {{"R8_INIPCHI", 10}, {"R8_FIMPCHI", 11}}}
    cSaveFil := cFilAnt
    cError := ""
    // Get rows for add in grid
    aAddedRow := RU07T1320_GetAddedRows()
    nLine := oGrid:Length()
    nCurLine := oGrid:NLINE
    DbSelectArea("SRA")
    SRA->(DbSetOrder(RetOrdem("SRA", "SRA->RA_FILIAL+SRA->RA_MAT")))
    // Posicione in SRA
    If SRA->(DbSeek((cRU07T1301MainAlias)->LIST_CFIL + (cRU07T1301MainAlias)->LIST_CMAT))
        // Enable insert line
        oGrid:SetNoInsertLine(.F.)
        cFilAnt := SRA->RA_FILIAL
        For nI := 1 To Len(aAddedRow)
            // Default empty line
            If nLine == 1 .And. oGrid:IsInserted(nLine)
                // Delete defeault empty line
                oGrid:SetNoDeleteLine(.F.)
                oGrid:DeleteLine()
                oGrid:SetNoDeleteLine(.T.)
            EndIf
            nLineNew := oGrid:AddLine()
            MsProcTxt(STR0040 + " (" + SRA->RA_MAT + " - " + DToC(aAddedRow[nI, 2, 3]) + ")") // "Loading Absences"

            If nLine == nLineNew
                // Sometimes adding line fail but after go to other line its ok
                oGrid:GoLine(Iif(nLineNew == 1, oGrid:Length(), 1))
                nLineNew := oGrid:AddLine()
                If nLine == nLineNew
                    // Fail by added line
                    UserException(STR0043 + " " + CValToChar(nLine + 1) + " '" + (cRU07T1301MainAlias)->LIST_CMAT + "'") // "Error adding line
                EndIf
            EndIf
            nLine := nLineNew
            // Line not for save (mean in REAL SR8)
            lLineNSave := .T.
            oGrid:LoadValue("R8_FILIAL", xFilial("SR8", (cRU07T1301MainAlias)->LIST_CFIL))
            // Positione in RCM by tipoafa
            Posicione("RCM", 1, xFilial("RCM", (cRU07T1301MainAlias)->LIST_CFIL) + aAddedRow[nI, 2, 2], "RCM_DESCRI")
            lSuccess := oGrid:SetValue("R8_TIPOAFA", aAddedRow[nI, 2, 2])
            lSuccess := oGrid:SetValue("R8_DATAINI", aAddedRow[nI, 2, 3])
            If !lSuccess
                // If can't set dataini - unmark record and stand state "9"
                nItem := AScan(oHGrid:ADATAMODEL, {|X| X[MODEL_GRID_ID] == aAddedRow[nI, 1, 1]})
                oHGrid:GoLine(nItem)
                oHGrid:SetValue("LIST_OK", .F.)
                oHGrid:SetValue("LIST_CLOAD", "9")
                UserException(STR0043 + " " + CValToChar(nLine) + " '" + (cRU07T1301MainAlias)->LIST_CMAT + "' can't fill DATAINI - " + DToC(aAddedRow[nI, 2, 3])) // "Error adding line
            EndIf
            lSuccess := lSuccess .And. RU07T1392_FillVal(oModel, oGrid, "R8_OBSAFAS", aAddedRow[nI, 2, 5], @cError)
            // lSuccess := oGrid:SetValue("R8_OBSAFAS", aAddedRow[nI, 2, 5])
            RU07T1391_WriteError(oModel, !lSuccess, cError)
            If aAddedRow[nI, 2, 1] == "030"
                // Line for save (mean in REAL SR8)
                lLineNSave := .F.
                For nK := 1 To Len(aFielFill[1])
                    lSuccess := lSuccess .And. RU07T1392_FillVal(oModel, oGrid, aFielFill[1, nK, 1], aAddedRow[nI, 2, aFielFill[1, nK, 2]], @cError)
                Next nK
                If !Empty(aAddedRow[nI, 2, 10]) .Or. !Empty(aAddedRow[nI, 2, 11])
                    lSuccess := oGrid:SetValue("R8_LAWSAL", "1")
                    RU07T1391_WriteError(oModel, !lSuccess, cError)
                    For nK := 1 To Len(aFielFill[2])
                        lSuccess := lSuccess .And. RU07T1392_FillVal(oModel, oGrid, aFielFill[2, nK, 1], aAddedRow[nI, 2, aFielFill[2, nK, 2]], @cError)
                    Next nK
                EndIf
                lSuccess := lSuccess .And. RU07T1392_FillVal(oModel, oGrid, "R8_VIOLAT", aAddedRow[nI, 2, 12], @cError)
            EndIf
            nItem := AScan(oHGrid:ADATAMODEL, {|X| X[MODEL_GRID_ID] == aAddedRow[nI, 1, 1]})
            // If something wrong
            If !lSuccess
                oHGrid:GoLine(nItem)
                oHGrid:SetValue("LIST_OK", .F.)
                oHGrid:SetValue("LIST_CLOAD", "9")
                UserException(STR0061 + " " + aAddedRow[nI, 2, 5] + " " + STR0062 + CRLF + cError) // "When filling out the data for a new absence (", "), the following errors occurred:"
            EndIf
            // If line for save - valid line
            If lLineNSave .Or. StaticCall(GPEA240RUS, gp240LinOk, oGrid)
                // Save line in temp SR8
                If RU07T1321_SaveInSR8Temp(oGrid, nLineNew)
                    // If succes save - unmark record and stand state
                    oHGrid:GoLine(nItem)
                    oHGrid:SetValue("LIST_OK", .F.)
                    oHGrid:SetValue("LIST_CLOAD", "2")
                EndIf
            Else
                // If error validation by line - unmark record and stand state "9"
                oHGrid:GoLine(nItem)
                oHGrid:SetValue("LIST_OK", .F.)
                oHGrid:SetValue("LIST_CLOAD", "9")
                UserException(STR0043 + " " + CValToChar(nLine) + " " + STR0050 + " '" + (cRU07T1301MainAlias)->LIST_CMAT + "' " + STR0051 + " - " + DToC(aAddedRow[nI, 2, 3])) // "Error adding line", "for employee", "failed to add line"
            EndIf
        Next nI
        // Disable insert line
        oGrid:SetNoInsertLine(.T.)
    ElseIf (cRU07T1301MainAlias)->LIST_CANS == "1"
        UserException(STR0043 + CValToChar(nLine + 1) + " '" + (cRU07T1301MainAlias)->LIST_CMAT + "'") // "Error adding line
    EndIf
    // Rest line pos
    oGrid:GoLine(nCurLine)

    RestArea(aArea)
    cFilAnt := cSaveFil
    SRA->(RestArea(aSRAArea))
    RCM->(RestArea(aRCMArea))
    
Return .T.

/*/{Protheus.doc} RU07T1320_GetAddedRows()

    This function get array of added row.

    @type Function
    @param oGrid, Object, Grid for SR8.
    @param lSave, Logical, Save in database.
    @return aAddedRow, Array, Added rows.
    @author dchihov
    @since 1.12.2023
    @version 12.1.23.10
    @example aAddedRow := RU07T1320_GetAddedRows()
*/
Static Function RU07T1320_GetAddedRows()

    Local cQuery      As Character
    Local cAlias      As Character
    Local cState      As Character
    Local aArea       As Array
    Local aAddedRow   As Array
    Local dStart      As Date
    Local dFinish     As Date

    aArea := GetArea()
    aAddedRow := {}
    cState := "'1'"

    // Get data for added rows
    cQuery := "SELECT LIST_TPAFA, R_E_C_N_O_, LIST_ELNNO, LIST_TPFD, LIST_CSTAT, " 
    cQuery += "LIST_NMED, LIST_CRMED, LIST_OGRN1, LIST_INIP, LIST_FIMP, LIST_VIOLD FROM " + cRU07T1302RealName + CRLF
    cQuery += "WHERE LIST_CLOAD IN (" + cState + ") AND LIST_CMAT = '" + (cRU07T1301MainAlias)->LIST_CMAT + "'"
    cQuery += " AND LIST_CFIL = '" + (cRU07T1301MainAlias)->LIST_CFIL + "'"

    cAlias := GetNextAlias()

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
    DbSelectArea(cRU07T1304Slave1Alias)
    (cRU07T1304Slave1Alias)->(DbSetOrder(2))

    While !(cAlias)->(EOF())
        If (cRU07T1304Slave1Alias)->(DbSeek(CValToChar((cAlias)->R_E_C_N_O_)))
            // get periods for absence (in ELN may be some periods bu t in absence period is one)
            dStart := (cRU07T1304Slave1Alias)->PERD_DTS
            dFinish := (cRU07T1304Slave1Alias)->PERD_DTF
            While !((cRU07T1304Slave1Alias)->(EOF())) .And. (cRU07T1304Slave1Alias)->PERD_RCD == (cAlias)->R_E_C_N_O_
                If dFinish < (cRU07T1304Slave1Alias)->PERD_DTF
                    dFinish := (cRU07T1304Slave1Alias)->PERD_DTF
                EndIf
                (cRU07T1304Slave1Alias)->(DbSkip())
            EndDo
            Aadd(aAddedRow, {{(cAlias)->R_E_C_N_O_}, {(cAlias)->LIST_CSTAT, (cAlias)->LIST_TPAFA, dStart, dFinish, (cAlias)->LIST_ELNNO, (cAlias)->LIST_TPFD, (cAlias)->LIST_NMED, ;
            (cAlias)->LIST_CRMED, (cAlias)->LIST_OGRN1, SToD((cAlias)->LIST_INIP), SToD((cAlias)->LIST_FIMP), SToD((cAlias)->LIST_VIOLD)}})
            (cAlias)->(DbSkip())
        Else
            UserException(STR0044 + " '" + (cAlias)->LIST_ELNNO + "'") // "Unable to load period of incapacity for absence"
        EndIf
        // Sorting rows by data start of absence
        ASort(aAddedRow, , , {|X, Y| X[2, 3] < Y[2, 3]})
    EndDo

    (cAlias)->(DbCloseArea())

    RestArea(aArea)
    
Return aAddedRow

/*/{Protheus.doc} RU07T1321_SaveInSR8Temp(oGrid)

    This function save record in temp sr8.

    @type Function
    @param nDiction, Numeric,   Code of dictionary.
    @param cCode,    Character, Code from XML.
    @return cResult, Character, Result code.
    @author dchihov
    @since 11.12.2023
    @version 12.1.23.10
    @example If RU07T1321_SaveInSR8Temp(oGrid, nLineNew)
*/
Static Function RU07T1321_SaveInSR8Temp(oGrid, nLine)

    Local aStrSr8 As Array
    Local nI      As Numeric

    aStrSr8 := oGrid:GetStruct():GetFields()

    Default nLine = oGrid:nLine

    If RecLock(cRU07T1305TempSr8, .T.)
        For nI := 1 To Len(aStrSr8)
            (cRU07T1305TempSr8)->&(aStrSr8[nI, 3]) := oGrid:GetValue(aStrSr8[nI, 3], nLine)
        Next nI
        // This field need for function loadlinegrid (ProtheusFunctionMVC)
        (cRU07T1305TempSr8)->RECNO := (cRU07T1305TempSr8)->(RecNo())
        (cRU07T1305TempSr8)->(MsUnLock())
    Else
        UserException(STR0043 + CValToChar(nLine + 1) + " '" + (cRU07T1301MainAlias)->LIST_CMAT + "'" + "- '" + (cRU07T1301MainAlias)->LIST_ELNNO + "'") // "Error adding line
    EndIf
    
Return .T.

/*/{Protheus.doc} RU07T1322_CheckByExit()

    This function check exist added and not saved record before exit.

    @type Function
    @param 
    @return lRet, Logical, Exit.
    @author dchihov
    @since 15.12.2023
    @version 12.1.23.10
    @example FWExecView("", "VIEWDEF.RU07T13RUS", MODEL_OPERATION_UPDATE, , , , , aButtons, {|| RU07T1322_CheckByExit()})
*/
Static Function RU07T1322_CheckByExit()

    Local aArea  As Array
    Local aTArea As Array
    Local lRet   As Logical

    aArea := GetArea()
    aTArea := (cRU07T1305TempSr8)->(GetArea())
    lRet := .T.

    DbSelectArea(cRU07T1305TempSr8)
    (cRU07T1305TempSr8)->(DbGoTop())

    While !(cRU07T1305TempSr8)->(EOF())
        // If not empty DataFim this record may be saved
        If !Empty((cRU07T1305TempSr8)->R8_DATAFIM)
            lRet := .F.
            Exit
        EndIf
        (cRU07T1305TempSr8)->(DbSkip())
    EndDo

    If !lRet
        lRet := MsgYesNo(STR0045) // "There are ELNs that were added but not saved in absence, still quit?"
    EndIf

    RestArea(aArea)
    (cRU07T1305TempSr8)->(RestArea(aTArea))

Return lRet

/*/{Protheus.doc} RU07T1323_Save(oView)

    This function interface for saving added rows.

    @type Function
    @param oView, Object, View
    @return .T.
    @author dchihov
    @since 15.12.2023
    @version 12.1.23.10
    @example oView:AddUserButton(STR0038, "BUTTON5", {|oView| RU07T1323_Save(oView)}) // "Save"
*/
Static Function RU07T1323_Save(oView)

    Local lSuccess As Logical
    Local oModel   As Object
    Local cSaveFil As Character

    oModel := FWModelActivate()
    cSaveFil := cFilAnt

    // MsgInfo(STR0048) // "Only closed absences will be saved)"

    MsAguarde({|| lSuccess := RU07T1318_SaveAdded(oView, oModel:GetModel("RU07T13LIST"), .T.)}, STR0024, STR0040) // "Please wait", "Loading Absences"

    If lSuccess
        MsgInfo(STR0046) // "Added entries are saved in absences."
    Else
        MostraErro()
    EndIf
    cFilAnt := cSaveFil

    // Update grid with absence
    RU07T1303_ChangeLine(oModel:GetModel("RU07T13LIST"), oModel:GetModel("GPEA240_SR8"))

Return .T.

/*/{Protheus.doc} RU07T1324_SaveAddedRows(oView, oModel)

    This function save grid from Model into SR8 (it's used model from gpea240).

    @type Function
    @param oView, Object, View of routine.
    @param oModel, Object, Model of routine
    @return lRet, Logical, Succes save.
    @author dchihov
    @since 15.12.2023
    @version 12.1.23.10
    @example lSuccess := RU07T1324_SaveAddedRows(oView, oModel)
*/
Static Function RU07T1324_SaveAddedRows(oView, oModel)

    Local oGrid      As Object
    Local oModelAuto As Object
    Local oGridAuto  As Object
    Local aEmpl      As Array
    Local aStruc     As Array
    Local nLine      As Numeric
    Local lRet       As Logical
    Local nI         As Numeric
    Local nK         As Numeric
    Local cSaveFil   As Character
    Local xVal

    oGrid := oModel:GetModel("GPEA240_SR8")

    aEmpl := {{"RA_FILIAL", (cRU07T1301MainAlias)->LIST_CFIL}, {"RA_MAT", (cRU07T1301MainAlias)->LIST_CMAT}}
    cSaveFil := cFilAnt

    aStruc := oGrid:GetStruct():GetFields()
    // Model from gpea240 for saving data.
    oModelAuto := FWLoadModel("GPEA240")
    lRet := .T.
    // Initialize for model GPEA240
    If StaticCall(GPEA240RUS, GP240Ini, oModelAuto, MODEL_OPERATION_INSERT)
        If oModelAuto:Activate()
            oGridAuto := oModelAuto:GetModel("GPEA240_SR8")
            For nI := 1 To oGrid:Length()
                // Line with id = 0 it's line from temp SR8 and if DATAFIM is empty - this line not for save
                If oGrid:GetDataID(nI) > 0 .Or. Empty(oGrid:GetValue("R8_DATAFIM", nI))
                    Loop
                EndIf
                nLine := oGridAuto:Length()
                oGridAuto:GoLine(nLine)
                If nLine == 1 .And. oGridAuto:IsInserted(nLine)
                    oGridAuto:DeleteLine()
                EndIf
                If nLine == oGridAuto:AddLine()
                    // Sometimes adding line fail but after go to other line its ok
                    oGridAuto:GoLine(1)
                    If nLine == oGridAuto:AddLine()
                        lRet := .F.
                        RU07T1393_FreeModel(oModelAuto)
                        UserException(STR0052) // "Error adding row to model"
                        Exit
                    EndIf
                EndIf
                cFilAnt := (cRU07T1301MainAlias)->LIST_CFIL
                // Posicione in RCM
                Posicione("RCM", 1, xFilial("RCM", (cRU07T1301MainAlias)->LIST_CFIL) + oGrid:GetValue("R8_TIPOAFA", nI), "RCM_DESCRI")
                For nK := 1 To Len(aF07T13SSave)
                    xVal := oGrid:GetValue(aF07T13SSave[nK], nI)
                    // Fill seteble value
                    If !Empty(xVal) .And. (!("|" + aF07T13SSave[nK] + "|" $ FIELD_NEED_CHECK_CAN) .Or. oGridAuto:CanSetValue(aF07T13SSave[nK]))
                        lRet := oGridAuto:SetValue(aF07T13SSave[nK], xVal)
                    EndIf
                    If !lRet
                        RU07T1393_FreeModel(oModelAuto)
                        UserException(STR0060 + " - " + aF07T13SSave[nK] + "(" + oModelAuto:GetErrorMessage()[6] + ")") // "Unable to insert value into field"
                    EndIf
                Next nK
                For nK := 1 To Len(aF07T13LSave)
                    // Fill loadeble value
                    oGridAuto:LoadValue(aF07T13LSave[nK], oGrid:GetValue(aF07T13LSave[nK], nI))
                Next nK
            Next nI
        Else
            RU07T1393_FreeModel(oModelAuto)
            UserException(STR0054) // "Error activating automatic model"
            lRet := .F.
        EndIf
    Else
        RU07T1393_FreeModel(oModelAuto)
        UserException(STR0055) // "Error initializing automatic model"
        lRet := .F.
    EndIf
    // Check if chengeble line
    If Empty(oGridAuto:aLinesChanged)
        lRet := .T.
    Else
        // Valid model
        If lRet .And. oModelAuto:VldData()
            // Save model
            If oModelAuto:CommitData()
                lRet := .T.
                // Delete saving rows from temp table
                TCSQLeXEC("DELETE FROM " + cRU07T1306TempSr8 + " WHERE R8_MAT = '" + SRA->RA_MAT + "' AND R8_FILIAL = '" + SRA->RA_FILIAL + "'")
                (cRU07T1305TempSr8)->(DbSkip())
                (cRU07T1305TempSr8)->(DbGoTop())
            Else
                RU07T1393_FreeModel(oModelAuto)
                UserException(STR0056) // "Error when saving automatic model"
                lRet := .F.
            Endif
        Else
            RU07T1393_FreeModel(oModelAuto)
            UserException(STR0057 + "(" + oModelAuto:GetErrorMessage()[6] + ")") // "Unknown error in automatic model"
            lRet := .F.
        Endif
    EndIf
    RU07T1393_FreeModel(oModelAuto)
    cFilAnt := cSaveFil

Return lRet

/*/{Protheus.doc} RU07T1325_CancelAddRows()

    This function cansell added rows

    @type Function
    @param 
    @return .T.
    @author dchihov
    @since 15.12.2023
    @version 12.1.23.10
    @example oView:AddUserButton(STR0039, "BUTTON6", {|oView| RU07T1325_CancelAddRows()}) // "Cancel
*/
Static Function RU07T1325_CancelAddRows()

    Local oView  As Object 
    Local oModel As Object 
    Local oGrid  As Object 
    Local oBrw   As Object 
    Local aArea  As Array
    Local nLine  As Numeric
    Local nI     As Numeric
    
    oView := FWViewActive()
    oModel := FWModelActivate()
    oGrid := oModel:GetModel("RU07T13LIST")

    If oGrid:GetDataId() > 0
        aArea := GetArea()

        oBrw := oView:GetViewObj("RU07T13LIST")[3]
        // Save data in database
        RU07T1315_SaveLIST(oGrid)

        For nI := 1 To oGrid:Length()
            oGrid:GoLine(nI)
            // Remove mark about loading lines
            oGrid:SetValue("LIST_CLOAD", "0")
        Next nI
        nLine := oBrw:oBrowse:oData:aShow[oBrw:oBrowse:aVisibleReg[1], oBrw:oBrowse:oData:nPosModelLine]
        // Save data in database
        RU07T1315_SaveLIST(oGrid)
        // Rest line pos
        oGrid:GoLine(nLine)

        oView:Refresh("RU07T13LIST")
        // Cleaning temp table
        TCSQLeXEC("DELETE FROM " + cRU07T1306TempSr8)

        // Refresh grid for SR8
        RU07T1303_ChangeLine(oGrid, oModel:GetModel("GPEA240_SR8"))
        RestArea(aArea)

        MsgInfo(STR0047) // "The addition of entries was cancelled"
    EndIf

Return .T.


/*/{Protheus.doc} RU07T1390_GetCodByCod(nDiction, cCode)

    This function get cod of element by dictionary by cod from xml.

    @type Function
    @param nDiction, Numeric,   Code of dictionary.
    @param cCode,    Character, Code from XML.
    @return cResult, Character, Result code.
    @author dchihov
    @since 11.12.2023
    @version 12.1.23.10
    @example (cRU07T1301MainAlias)->LIST_TPFD  := RU07T1390_GetCodByCod(2, aTablePers[nI, nZS + 7, 2])
*/
Static Function RU07T1390_GetCodByCod(nDiction, cCode)

    Local cResult As Character

    If nDiction == 1
        Do Case
            Case cCode == "01"
                cResult := "004"
            Case cCode == "02"
                cResult := "020"
            Case cCode == "03"
                cResult := "021"
            Case cCode == "04"
                cResult := "003"
            Case cCode == "05"
                cResult := "007"
            Case cCode == "06"
                cResult := "019"
            Case cCode == "07"
                cResult := "022"
            Case cCode == "08"
                cResult := "023"
            Case cCode == "09"
                cResult := "024"
            Case cCode == "10"
                cResult := "009"
            Case cCode == "11"
                cResult := "025"
            Case cCode == "12"
                cResult := "026"
            Case cCode == "13"
                cResult := "027"
            Case cCode == "14"
                cResult := "028"
            Case cCode == "15"
                cResult := "029"
            OtherWise
                cResult := ""
        EndCase
    ElseIf nDiction == 2
        Do Case
            Case cCode == "01"
                cResult := "04"
            Case cCode == "02"
                cResult := "20"
            Case cCode == "03"
                cResult := "21"
            Case cCode == "04"
                cResult := "03"
            Case cCode == "05"
                cResult := "07"
            Case cCode == "06"
                cResult := "19"
            Case cCode == "07"
                cResult := "22"
            Case cCode == "08"
                cResult := "23"
            Case cCode == "09"
                cResult := "24"
            Case cCode == "10"
                cResult := "09"
            Case cCode == "11"
                cResult := "25"
            Case cCode == "12"
                cResult := "26"
            Case cCode == "13"
                cResult := "27"
            Case cCode == "14"
                cResult := "28"
            Case cCode == "15"
                cResult := "29"
            OtherWise
                cResult := ""
        EndCase
    EndIf
    
Return cResult

/*/{Protheus.doc} RU07T1391_WriteError(oModel, lError, cError)

    This function get text of error by model.

    @type Function
    @param oModel, Object,    Model.
    @param lError, Logical,   Has error.
    @param cError, Character, All Error.
    @return cResult, Character, Text of error.
    @author dchihov
    @since 23.01.2024
    @version 12.1.23.10
    @example RU07T1391_WriteError(oModel, !lSuccess, @cError)
*/
Static Function RU07T1391_WriteError(oModel, lError, cError)

    Local cResult := "" As Character
    Local aError        As Array

    Default oModel := FWModelActive()

    If lError
        aError := oModel:GetErrorMessage()
        cResult := aError[4] + " - " + aError[6]
        If ValType(cError) == "C"
            If Len(cError) > 0
                cError += CRLF
            EndIf
            cError += cResult
        EndIf
        oModel:GetErrorMsgText(.T.)
    EndIf

Return cResult

/*/{Protheus.doc} RU07T1392_FillVal(oModel, oGrid, cField, xVal, cError)

    This function get text of error by model.

    @type Function
    @param oModel, Object,    Model.
    @param oGrid,  Object,    Grid.
    @param cField, Character, ID of the field to be filled.
    @param xVal,   ,          Value.
    @param cError, Character, All Error.
    @return cResult, Character, Text of error.
    @author dchihov
    @since 23.01.2024
    @version 12.1.23.10
    @example lSuccess := lSuccess .And. RU07T1392_FillVal(oModel, oGrid, "R8_VIOLAT", aAddedRow[nI, 2, 12], @cError)
*/
Static Function RU07T1392_FillVal(oModel, oGrid, cField, xVal, cError)

    Local lSuccess As Logical

    lSuccess := .T.

    If !Empty(xVal)
        lSuccess := oGrid:SetValue(cField, xVal)
        RU07T1391_WriteError(oModel, !lSuccess, @cError)
    EndIf

Return lSuccess

/*/{Protheus.doc} RU07T1393_FreeModel(oModel)

    This function free Model.

    @type Function
    @param oModel, Object, Model.
    @return cResult, 
    @author dchihov
    @since 24.01.2024
    @version 12.1.23.10
    @example RU07T1393_FreeModel(oModelAuto)
*/
Static Function RU07T1393_FreeModel(oModel)

    oModel:DeActivate()
    oModel:Destroy()
    oModel := NIL

Return Nil
