#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07T14RUS.CH"
#INCLUDE "PCOTRYEXCEPTION.CH"

#DEFINE A_SEXO_VALUE {"MALE", "FEMALE"}
#DEFINE ZERO_UID "00000000-0000-0000-0000-000000000000"

// dublicate const: ruhrelnxmlanswerwriter
#DEFINE DELETE_NODE 1
#DEFINE NILABLE_NODE 2

/*/{Protheus.doc} RU07T14RUS()

    This main function for load xml-document request for missing information (by proactivity calculation)

    @type Function
    @return 
    @author dchihov
    @since 29.01.2024
    @version 12.1.23.10
    @example RU07T14RUS()
*/
Function RU07T14RUS()

    Local aArea     As Array
    Local aButtons  As Array
    Local oTempTab  As Object

    Static cRU07T1401MainAlias
    Static cRU07T1402RealName
    Static cRU07T1403RealName2
    Static lRU07T1401InitGrid
    Static lRU07T1402InitGrid
    Static aRU07T1401ComparesField

    aButtons := {{.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.T., STR0024}, ; // "Exit"
    {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}}

    aRU07T1401ComparesField := {{"LIST_NOME", "C", "C"} , {"LIST_YEAR1", "C", "N"}, {"LIST_SUMM1", "C", "N"}, ;
    {"LIST_YEAR2", "C", "N"}, {"LIST_SUMM2", "C", "N"}, {"LIST_EYEAR", "N", "N"}, {"LIST_EMOUN", "N", "N"}, ;
    {"LIST_KS206", "C", "N"}, {"LIST_PERB", "S", "D"}, {"LIST_PERE", "S", "D"}}

    aArea := GetArea()
    cRU07T1401MainAlias := RU07T1401_GetTempTable(@oTempTab)
    lRU07T1401InitGrid := .T.
    lRU07T1402InitGrid := .T.

    If !IsBlind()
        FWExecView("", "VIEWDEF.RU07T14RUS", MODEL_OPERATION_UPDATE, , , , , aButtons, /*{|| RU07T1422_CheckByExit()}*/)
    EndIf

    If oTempTab <> Nil
        oTempTab:Zap()
        oTempTab:Delete()
        FreeObj(oTempTab)
        oTempTab := Nil
    Endif

    RestArea(aArea)

Return

/*/{Protheus.doc} MenuDef()

    MenuDef

    @type Function
    @return 
    @author dchihov
    @since 29.01.2024
    @version 12.1.23.10
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
    @since 29.01.2024
    @version 12.1.23.10
    @example ModelDef()
*/
Static Function ModelDef()

    Local oModel  As Object
    Local oMaster As Object
    Local oStr1   As Object
    Local bLoad   As Block

    oMaster := FWFormModelStruct():New()
    oModel := MPFormModel():New('RU07T14RUS')
    oStr1 := FWFormModelStruct():New()
    oStr1:AddTable(cRU07T1401MainAlias, , cRU07T1401MainAlias)
    bLoad := {|oGridModel, lCopy| RU07T1402_LoadGrid(oGridModel, lCopy)}
        //          Titulo,      ToolTip,      Field ID,   Tipo, Tam,                     Dec,  Valid       ,When,          Combo,           Obrigat,          Init,       Chave,   Altera,      Virtual
    oStr1:AddField("LIST_OKK"   , "LIST_OKK"   , "LIST_OKK"   , "C", 1                      , 0   ,/*{|| }*/, /*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/,   /*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)
    oStr1:AddField("CheckBox"   , "CheckBox"   , "LIST_OK"    , "L", 1                      , 0   , {|oGrid, cId, xVal| RU07T1424_ValidMark(oGrid, xVal)}, {|oGrid, cId, xVal, nLin, xCurVal| xCurVal := Iif(xCurVal == Nil, xVal, xCurVal), RU07T1404_CheckCanSelect(oGrid, cId, xCurVal, nLin)}/*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/,     ,           , .T.         ,             )
    oStr1:AddField(STR0010      , "LIST_CODE"  , "LIST_CODE"  , "C", 12                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "No. ELN"
    oStr1:AddField(STR0011      , "LIST_CIC"   , "LIST_CIC"   , "C", TamSx3("RA_CIC")[1]    , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "SNILS"
    oStr1:AddField(STR0012      , "LIST_NOME"  , "LIST_NOME"  , "C", TamSx3("RA_NOMECMP")[1], 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Full name"
    oStr1:AddField(STR0013      , "LIST_YEAR1" , "LIST_YEAR1" , "C", 4                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Year-1"
    oStr1:AddField(STR0014      , "LIST_SUMM1" , "LIST_SUMM1" , "C", 23                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Income-1"
    oStr1:AddField(STR0015      , "LIST_YEAR2" , "LIST_YEAR2" , "C", 4                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Year-2"
    oStr1:AddField(STR0016      , "LIST_SUMM2" , "LIST_SUMM2" , "C", 23                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Income-2"
    oStr1:AddField(STR0017      , "LIST_EYEAR" , "LIST_EYEAR" , "N", 3                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Years of experience"
    oStr1:AddField(STR0018      , "LIST_EMOUN" , "LIST_EMOUN" , "N", 2                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Months of experience"
    oStr1:AddField(STR0019      , "LIST_EXPER" , "LIST_EXPER" , "C", 20                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Experience"
    oStr1:AddField(STR0020      , "LIST_KS206" , "LIST_KS206" , "C", 4                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "RK"
    oStr1:AddField(STR0021      , "LIST_KNFWT" , "LIST_KNFWT" , "C", 5                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Coeff. incomplete working time"
    oStr1:AddField(STR0022      , "LIST_PERB"  , "LIST_PERB"  , "C", 10                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Benefit with…"
    oStr1:AddField(STR0023      , "LIST_PERE"  , "LIST_PERE"  , "C", 10                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             ) // "Benefit for…"
    oStr1:AddField("LIST_SETTV" , "LIST_SETTV" , "LIST_SETTV" , "C", 28                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             )
    oStr1:AddField("LIST_SASTN" , "LIST_SASTN" , "LIST_SASTN" , "C", 20                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             )
    oStr1:AddField("LIST_SRANO" , "LIST_SRANO" , "LIST_SRANO" , "N", 13                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             )
    oStr1:AddField("LIST_SR8NO" , "LIST_SR8NO" , "LIST_SR8NO" , "N", 13                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             )
    oStr1:AddField("LIST_NUMLI" , "LIST_NUMLI" , "LIST_NUMLI" , "C", 1                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             )
    oStr1:AddField("LIST_CSTAT" , "LIST_CSTAT" , "LIST_CSTAT" , "C", 1                      , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             )
    oStr1:AddField("LIST_LINK"  , "LIST_LINK"  , "LIST_LINK"  , "N", 10                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             )
    oStr1:AddField("LIST_ORDFI" , "LIST_ORDFI" , "LIST_ORDFI" , "N", 10                     , 0   ,         ,              ,                ,                 ,              ,     ,           , .F.         ,             )

    oMaster:AddTable("MASTER", , STR0002) // "Loading"
    oModel:AddFields("MASTER", /*cOwner*/, oMaster, , ,{|o|{}} )
    oModel:AddGrid("RU07T14LIST", "MASTER", oStr1, , , , , bLoad)
    oModel:AddGrid("RU07T14ITEM", "MASTER", oStr1, , , , , bLoad)
    oModel:GetModel("RU07T14LIST"):SetNoInsertLine(.T.)
    oModel:GetModel("RU07T14ITEM"):SetNoInsertLine(.T.)
    oModel:GetModel("RU07T14ITEM"):SetDescription(STR0003) // "Simulation result"
    oModel:SetRelation("RU07T14LIST", {{"LIST_NUMLI", "1"}}, (cRU07T1401MainAlias)->(IndexKey()))
    oModel:SetRelation("RU07T14ITEM", {{"LIST_NUMLI", "2"}}, (cRU07T1401MainAlias)->(IndexKey()))

    oStr1:SetProperty("LIST_OK", MODEL_FIELD_INIT, {|| (cRU07T1401MainAlias)->LIST_OKK == "1"})
    oModel:SetPrimaryKey( {} )

Return oModel

/*/{Protheus.doc} ViewDef()

    ViewDef

    @type Function
    @return 
    @author dchihov
    @since 29.01.2024
    @version 12.1.23.10
    @example ViewDef()
*/
Static Function ViewDef()

    Local oView  As Object
    Local oModel As Object
    Local oStr1  As Object
    
    oModel := FwLoadModel("RU07T14RUS")

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oStr1 := FWFormViewStruct():New()
    //              ID           Order Titulo   Descrip   Help Type  Pict     bPictVar LookUp CanCh  Ider cGroup Combo MaxLenCombo IniBrw, lVirt PicVar
    oStr1:AddField("LIST_OK"   , "01", ""     , "LIST_OK", Nil, "L", ""      , Nil   , ""     , .T., ""  , ""   , {}  , 0         , ""    , .T.)
    oStr1:AddField("LIST_CODE" , "02", STR0010, STR0010  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "No. ELN"
    oStr1:AddField("LIST_CIC"  , "03", STR0011, STR0011  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "SNILS"
    oStr1:AddField("LIST_NOME" , "04", STR0012, STR0012  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Full name"
    oStr1:AddField("LIST_YEAR1", "05", STR0013, STR0013  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Year-1"
    oStr1:AddField("LIST_SUMM1", "06", STR0014, STR0014  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Income-1"
    oStr1:AddField("LIST_YEAR2", "07", STR0015, STR0015  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Year-2"
    oStr1:AddField("LIST_SUMM2", "08", STR0016, STR0016  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Income-2"
    oStr1:AddField("LIST_EXPER", "09", STR0019, STR0019  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Experience"
    oStr1:AddField("LIST_KS206", "10", STR0020, STR0020  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "RK"
    // now not localize in ma3
    // oStr1:AddField("LIST_KNFWT", "11", STR0021, STR0021  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Coeff. incomplete working time"
    oStr1:AddField("LIST_PERB" , "12", STR0022, STR0022  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Benefit with…"
    oStr1:AddField("LIST_PERE" , "13", STR0023, STR0023  , Nil, "C", ""      , Nil   , ""     , .F., ""  , ""   , {}  , 0         , ""    , .F.) // "Benefit for…"

    oView:AddGrid("RU07T14LIST", oStr1)
    oView:AddGrid("RU07T14ITEM", oStr1)

    oView:createHorizontalBox("LIST", 50)
    oView:createHorizontalBox("GRID", 50)

    oView:SetOwnerView("RU07T14LIST","LIST")
    oView:SetOwnerView("RU07T14ITEM","GRID")
    oView:SetDescription(STR0001) // "ELN"
    oView:SetAfterViewActivate({|oView| RU07T1403_AfterActive(oView)})

    oView:SetCloseOnOk({ || .T. })
    oView:AddUserButton(STR0004, "BUTTON1", {|oView| RU07T1406_LoadXML(oView)}) // "Load from file"
    oView:AddUserButton(STR0005, "BUTTON2", {|oView| RU07T1413_SimulationCalculation(oModel, oView)}) // "Show calculation"
    oView:AddUserButton(STR0006, "BUTTON3", {|oView| RU07T1419_CompareData(oView)}) // "Data Comparison"
    oView:AddUserButton(STR0007, "BUTTON4", {|oView| RU07T1421_MarkAll(oView, .F., , "RU07T14LIST", "RU07T14ITEM")}) // "Mark all"
    oView:AddUserButton(STR0008, "BUTTON5", {|oView| RU07T1423_InvertMark(oView)}) // "Invert mark"
    oView:AddUserButton(STR0009, "BUTTON6", {|oView| RU07T1425_CreateAgree()}) // "Generate a response"
    oView:SetViewAction("ASKONCANCELSHOW", { |oView| .F. } )

Return oView

/*/{Protheus.doc} RU07T1401_GetTempTable(oTempTable)

    This function create temporary table for data from XML.

    @type Function
    @param oTempTable, Object, Object for temp table/
    @return cRetAlias, Character, Alias of temporary table/
    @author dchihov
    @since 29.01.2024
    @version 12.1.23.10
    @example cRU07T1401MainAlias := RU07T1401_GetTempTable(@oTempTab)
*/
Function RU07T1401_GetTempTable(oTempTable, nTt)

    Local cRetAlias As Character
    Local aFields   As Array

    Default nTt := 1

    cRetAlias := CriaTrab(Nil, .F.) // Get new alias of your temporary table.
    oTempTable := FWTemporaryTable():New(cRetAlias) // Create temporary table.
    aFields := {}
    aAdd(aFields, {"LIST_OKK"   , "C", 1                      , 00})
    aAdd(aFields, {"LIST_CODE"  , "C", 12                     , 00}) // Benefit code
    aAdd(aFields, {"LIST_CIC"   , "C", TamSx3("RA_CIC")[1]    , 00}) // RA_CIC (SNILS)
    aAdd(aFields, {"LIST_NOME"  , "C", TamSx3("RA_NOMECMP")[1], 00}) // RA_NOMECMP
    aAdd(aFields, {"LIST_NBDAY" , "N", 3                      , 00}) // Calculation base day (count)
    aAdd(aFields, {"LIST_YEAR1" , "C", 4                      , 00}) // Year #1
    aAdd(aFields, {"LIST_SUMM1" , "C", 23                     , 02}) // Summ 1
    aAdd(aFields, {"LIST_YEAR2" , "C", 4                      , 00}) // Year #2
    aAdd(aFields, {"LIST_SUMM2" , "C", 23                     , 02}) // Summ 2
    aAdd(aFields, {"LIST_EYEAR" , "N", 3                      , 00}) // Count of expirience year
    aAdd(aFields, {"LIST_EMOUN" , "N", 2                      , 00}) // Count of expirience mounth
    aAdd(aFields, {"LIST_EXPER" , "C", 20                     , 00}) // String of experience
    aAdd(aFields, {"LIST_KS206" , "C", 4                      , 00}) // Regional koefficient
    aAdd(aFields, {"LIST_KNFWT" , "C", 5                      , 03}) // Koefficient not full working time
    aAdd(aFields, {"LIST_PERB"  , "C", 10                     , 00}) // Period begin
    aAdd(aFields, {"LIST_PERE"  , "C", 10                     , 00}) // Period end
    aAdd(aFields, {"LIST_SETTV" , "C", 28                     , 00}) // String of required and editable for parameter (degree 2, editable - 0 mandatory - 1)
    aAdd(aFields, {"LIST_SASTN" , "C", 20                     , 00}) // Social assist number
    aAdd(aFields, {"LIST_SRANO" , "N", 13                     , 00}) // SRA->(RecNo())
    aAdd(aFields, {"LIST_SR8NO" , "N", 13                     , 00}) // SR8->(RecNo())
    aAdd(aFields, {"LIST_NUMLI" , "C", 1                      , 00}) // Which is list
    aAdd(aFields, {"LIST_CSTAT" , "C", 1                      , 00}) // State of List
    aAdd(aFields, {"LIST_LINK"  , "N", 10                     , 00}) // RecNo element second list
    aAdd(aFields, {"LIST_ORDFI" , "N", 10                     , 00}) // Field for order of records
    oTemptable:SetFields(aFields) // Set columns.
    oTempTable:AddIndex("1", {"LIST_NUMLI", "LIST_ORDFI", "LIST_NOME"})
    oTempTable:AddIndex("2", {"LIST_NUMLI", "LIST_ORDFI", "LIST_CODE"})
    oTempTable:AddIndex("3", {"LIST_NUMLI", "LIST_ORDFI", "LIST_CIC"})
    oTempTable:AddIndex("4", {"LIST_NUMLI", "LIST_LINK"})
    oTempTable:Create()
    cRU07T1402RealName := oTempTable:GetRealName()

    DbSelectArea(cRetAlias)

Return cRetAlias

/*/{Protheus.doc} RU07T1402_LoadGrid(oGridModel, lCopy)

    This function Array with data for main grid.

    @type Function
    @param oGridModel, Object,  Grid model.
    @param lCopy,      Logical, Object for temp table.
    @return aLoad,     Array, Array for a grid.
    @author dchihov
    @since 30.01.2024
    @version 12.1.23.10
    @example bLoad := {|oGridModel, lCopy| RU07T1402_LoadGrid(oGridModel, lCopy)}
*/
Function RU07T1402_LoadGrid(oGridModel, lCopy)
    
    Local aLoad := {} As Array

    aLoad := FWLoadByAlias(oGridModel, cRU07T1401MainAlias, cRU07T1401MainAlias)

Return aLoad

/*/{Protheus.doc} RU07T1403_AfterActive(oView)

    This function Make some things? which need do after activate view.

    @type Function
    @param oView, Object, Main view.
    @return .T.
    @author dchihov
    @since 30.01.2024
    @version 12.1.23.10
    @example oView:SetAfterViewActivate({|oView| RU07T1403_AfterActive(oView)})
*/
Function RU07T1403_AfterActive(oView)

    Local oBrowse1 As Object
    Local oBrowse2 As Object

    oBrowse1 := oView:GetViewObj("RU07T14LIST")[3]
    oBrowse2 := oView:GetViewObj("RU07T14ITEM")[3]

    oBrowse1:oBrowse:aColumns[1]:SetHeaderImage("")
    oBrowse1:oBrowse:aColumns[1]:SetHeaderClick( {|| RU07T1421_MarkAll(, , , "RU07T14LIST", "RU07T14ITEM")} )
    AEval(oBrowse1:oBrowse:aColumns, {|X| X:SetHeaderClick( {|| RU07T1417_HeaderClick(oView, oBrowse1, oBrowse2, "RU07T14LIST", 2) /*oBrowse1:TGRIDORDERCOLUMN(), RU07T1416_FillCustomSortField(oBrowse1:oControl:GetModel("RU07T14LIST"), oView, oBrowse1, oBrowse2), RU07T1411_UpdateGrid(oView, 2)*/} )}, 2)
    oBrowse1:oBrowse:bOnMove := {|oBrowse, nMoveType, nCursorPos, nQtdLinha, nVisbleRow| RU07T1418_Moved(oView, oBrowse1, oBrowse2, oBrowse, nMoveType, nCursorPos, nQtdLinha, nVisbleRow)}
    oBrowse2:oBrowse:aColumns[1]:SetHeaderImage("")
    oBrowse2:oBrowse:aColumns[1]:SetHeaderClick( {|| RU07T1421_MarkAll(, , , "RU07T14ITEM", "RU07T14LIST")} )
    AEval(oBrowse2:oBrowse:aColumns, {|X| X:SetHeaderClick( {|| RU07T1417_HeaderClick(oView, oBrowse2, oBrowse1, "RU07T14ITEM", 1)} )}, 2)
    oBrowse2:oBrowse:bOnMove := {|oBrowse, nMoveType, nCursorPos, nQtdLinha, nVisbleRow| RU07T1418_Moved(oView, oBrowse2, oBrowse1, oBrowse, nMoveType, nCursorPos, nQtdLinha, nVisbleRow)}
    oBrowse1:oBrowse:SetBlkBackColor(&("{|| RU07T1412_CheckEmpl(Self:oData:aShow[Self:nAt][3], .T., Self:oData:oSubmodel:aDataModel[Self:oData:aShow[Self:nAt, Self:oData:nPosModelLine], " + CValToChar(MODEL_GRID_ID) + "])}"))
    oBrowse2:oBrowse:SetBlkBackColor(&("{|| RU07T1412_CheckEmpl(Self:oData:aShow[Self:nAt][3], .T., Self:oData:oSubmodel:aDataModel[Self:oData:aShow[Self:nAt, Self:oData:nPosModelLine], " + CValToChar(MODEL_GRID_ID) + "])}"))
    // // oBrowse:oBrowse:SetBlkBackColor({|| RU07T1411_CheckEmpl(oBrowse:oBrowse:ODATA:ASHOW[oBrowse:oBrowse:nAt][3], .T.)})
    oBrowse1:oBrowse:SetBlkColor({|| CLR_BLACK})
    oBrowse2:oBrowse:SetBlkColor({|| CLR_BLACK})

Return .T.

/*/{Protheus.doc} RU07T1404_CheckCanSelect(oGrid, cIdField, xVal, nLin, lVis, nIdRec)

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
    @since 30.01.2024
    @version 12.1.23.10
    @example {|oGrid, cId, xVal, nLin, xCurVal| xCurVal := Iif(xCurVal == Nil, xVal, xCurVal), RU07T1404_CheckCanSelect(oGrid, cId, xCurVal, nLin)}
*/
Static Function RU07T1404_CheckCanSelect(oGrid, cIdField, xVal, nLin, lVis, nIdRec)

    Local lRes   As Logical
    Local nType  As Numeric
    Local aMArea As Array

    Default oGrid := Nil
    Default cIdField := ""
    Default xVal := .F.
    Default nLin := 0
    Default lVis := .T.
    Default nIdRec := -1

    lRes := .F.
    nType := 0
    aMArea := (cRU07T1401MainAlias)->(GetArea())

    // If get param by grid for posicione in table
    If nLin > 0
        nIdRec := oGrid:GetDataId()
        If nIdRec > 0
            (cRU07T1401MainAlias)->(DbGoTo(oGrid:GetDataId()))
        EndIf
    // If get id
    ElseIf nIdRec > -1
        (cRU07T1401MainAlias)->(DbGoTo(nIdRec))
    EndIf

    // Current value = .T. and current make is uncheck
    If xVal
        lRes := .T.
    ElseIf nIdRec > 0
        If (cRU07T1401MainAlias)->LIST_LINK < 1
            lRes := .F.
            If lVis
                Help( Nil, Nil, STR0050, Nil, STR0051, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0052 + " '" +  STR0005 + "' " + STR0053 } ) // "Check the correctness of the data and ZNS.", "This entry has not been calculated and cannot be marked.", "Select", "Show calculation", "in other actions"
            EndIf
        ElseIf(cRU07T1401MainAlias)->LIST_SRANO < 1
            lRes := .F.
            If lVis
                Help( Nil, Nil, STR0050, Nil, STR0054, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0055 } ) // "Check the correctness of the data and ZNS.", "No employee found for this salary", "Check the correctness of the data and ZNS."
            EndIf
        ElseIf(cRU07T1401MainAlias)->LIST_SR8NO < 1
            lRes := .F.
            If lVis
                Help( Nil, Nil, STR0050, Nil, STR0056, 1, 0, Nil, Nil, Nil, Nil, Nil, { STR0057 } ) // "Check the correctness of the data and ZNS.", "Missing not found for this ZNS", "Download ENL in absence"
            EndIf
        Else
            // Record can be selected
            lRes := .T.
        EndIf
    EndIf

    (cRU07T1401MainAlias)->(RestArea(aMArea))

Return lRes

/*/{Protheus.doc} RU07T1405_Error(e, lErro, cError)

    This function for error.

    @type Function
    @param e,      Object,    Object of error.
    @param lErro,  Logical,   Is error.
    @param cError, Character, Message of error.
    @return 
    @author dchihov
    @since 30.01.2024
    @version 12.1.23.10
    @example bErro := ErrorBlock( { |e| RU07T1405_Error(e, , @cExcept) } )
*/
Function RU07T1405_Error(e, lErro, cError)

    lErro := e:gencode > 0
    cError += "Error:" + CRLF + CRLF +  e:description + CRLF + CRLF + "Stack:" + CRLF + e:errorstack + CRLF + CRLF
    Break

Return

/*/{Protheus.doc} RU07T1406_LoadXML(oMainView)

    This function get xml from user and run loading data from XML-file.

    @type Function
    @param oMainView, Object, View of form.
    @return .T.
    @author dchihov
    @since 30.01.2024
    @version 12.1.23.10
    @example oView:AddUserButton(STR0004, "BUTTON1", {|oView| RU07T1406_LoadXML(oView)}) // "Load from file"
*/
Function RU07T1406_LoadXML(oMainView)

    Local cPathXML As Character
    Local aFiles   As Array
    cPathXML := cGetFile("*.xml|*.XML", STR0025, 1, "C:\", .T., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_MULTISELECT, .T., .T.) // "Selecting a file to download ELN"
    If Len(AllTrim(cPathXML)) > 0
        aFiles := StrTokArr(cPathXML, "|")
        MsAguarde({|| RU07T1407_ReadXML(oMainView, aFiles)}, STR0026, STR0027) // "Please wait", "Files uploaded"
        MostraErro()
        RU07T1411_UpdateGrid(oMainView, 1)
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1407_ReadXML(oMainView, aFiles)

    This function load data from XML-file.

    @type Function
    @param oMainView, Object, View of form.
    @return .T.
    @author dchihov
    @since 30.01.2024
    @version 12.1.23.10
    @example MsAguarde({|| RU07T1407_ReadXML(oMainView, aFiles)}, STR0026, STR0027) // "Please wait", "Files uploaded"
*/
Function RU07T1407_ReadXML(oMainView, aFiles)

    Local cPathXML As Character
    Local cPath    As Character
    Local cTemp    As Character
    Local cName    As Character
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
    bErro := ErrorBlock( { |e| RU07T1405_Error(e, , @cExcept) } )
    AutoGrLog(STR0030) // "Files:"
    Begin Sequence
        For nX := 1 To nCount
            aFiles[nX] := AllTrim(aFiles[nX])
            cPathXML := aFiles[nX]
            If File(cPathXML, 2, .F.)
                If lFirst
                    lFirst := .F.
                    // reusing old function (in name of folder "xmlt13")
                    cPath := RU07T1306_MakeTmpDir()
                EndIf
                cTemp := cPath + CValToChar(Randomize(1, 50000)) + ".xml"
                While File(cTemp)
                    cTemp := cPath + CValToChar(Randomize(1, 50000)) + ".xml"
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
                aAdd(aError, aFiles[nX] + Iif(Len(AllTrim(cError)) > 0,  CRLF + cError + CRLF + CRLF, ""))
            EndIf
            SplitPath(cPathXML, @cDrive)
            If Len(AllTrim(cName) + AllTrim(cExtens)) > 0 .And. Empty(cDrive)
                FErase(cPathXML)
            EndIf
            cName := cExtens := ""
            MsProcTxt(STR0027 + " " + CValToChar(nX) + "/" + CValToChar(nCount)) // "Files uploaded"
        Next nX
    End Sequence
    ErrorBlock(bErro)
    AutoGrLog(STR0031) // "uploaded successfully"
    If Len(cPath) > 0
        SplitPath(cPathXML, @cDrive)
        If Len(AllTrim(cName) + AllTrim(cExtens)) > 0 .And. Empty(cDrive) .And. File(cPathXML)
            FErase(cPathXML)
        EndIf
        DirRemove(cPath)
    EndIf
    If Len(aError) > 0
        AutoGrLog(CRLF)
        AutoGrLog(STR0028) // "The following files could not be parsed:"
        AutoGrLog(CRLF)
        For nX := 1 To Len(aError)
            AutoGrLog(aError[nX])
        Next nX
        AutoGrLog(STR0029) // "maybe they are damaged"
    EndIf
    If Len(cExcept) > 0
        AutoGrLog(CRLF)
        AutoGrLog(cExcept)
    EndIf

Return .T.

/*/{Protheus.doc} LoadXMLELN(oMainView, cPath, cErr)

    This function read data from XML-file and write into grid.

    @type Function
    @param oMainView, Object, View of form.
    @param cPath,  Character, Path to XML.
    @param cErr,   Character, Message of error.
    @return lSuccess, Logical, Success reading XML-file.
    @author dchihov
    @since 30.01.2024
    @version 12.1.23.10
    @example If LoadXMLELN(oMainView, cPathXML, @cError)
*/
Static Function LoadXMLELN(oMainView, cPath, cErr)

    Local oXMLReader As Object
    Local lSuccess   As Logical

    oXMLReader := RUHRElnXMLReaderPart02():New(cPath, "1")
    lSuccess := oXMLReader:ReadXML()
    cErr := ""
    If !lSuccess
        cErr := Iif(Empty(oXMLReader:cError), "", oXMLReader:cError)
    EndIf
    If lSuccess
        RU07T1408_FillTempTable(oXMLReader:aTableData, oXMLReader:nCSE)
    EndIf

    oXMLReader:Destroy()
    FreeObj(oXMLReader)
    oXMLReader := Nil

Return lSuccess

/*/{Protheus.doc} RU07T1408_FillTempTable(aTablePers, nZS)

    This function Filling temptable data.

    @type Function
    @param aTablePers, Array, Array of data
    @param nZS,      Numeric, Count system elem in table pers
    @return nCount, Numeric, Count of record, which writing into temp table.
    @author dchihov
    @since 30.01.2024
    @version 12.1.23.10
    @example RU07T1408_FillTempTable(oXMLReader:aTablePerson, oXMLReader:nSLE)
*/
Function RU07T1408_FillTempTable(aTablePers, nZS)

    Local nI      As Numeric
    Local nIndex  As Numeric
    Local aPersL  As Array
    Local aPers   As Array
    Local aArea   As Array
    Local aSRArea As Array
    Local nCount  As Numeric
    Local cTemp   As Character
    Local cTemp2  As Character

    nCount := 0
    aPersL := {}
    aArea := GetArea()
    aSRArea := SRA->(GetArea())
    For nI := 2 To Len(aTablePers)
        nIndex := AScan(aPersL, {|X| X[1] == aTablePers[nI]["snils"]["value"]})
        If nIndex > 0
            aPers := aPersL[nIndex]
        Else
            aPers := RU07T1409_GetDataFromBd(aTablePers[nI]["snils"]["value"], "1")
            aPers[2] := aTablePers[nI]["snils"]["value"]
            aPers[3] := aTablePers[nI]["lastName"]["value"] + " " + aTablePers[nI]["firstName"]["value"] + " " + aTablePers[nI]["middleName"]["value"]
            aAdd(aPersL, aPers)
        EndIf
        If aPers[4] > 0 
            SRA->(DbGoTo(aPers[4]))
        EndIf
        cTemp := RU07T1410_FormatYYMM(aTablePers[nI]["insurYY"]["value"], "1")
        cTemp += Iif(Empty(cTemp), "", CRLF) + RU07T1410_FormatYYMM(aTablePers[nI]["insurMM"]["value"], "2")
        cTemp2 := ""
        cTemp2 += CValToChar(Iif(aTablePers[nI]["code"]["editable"], 1, 0) + Iif(aTablePers[nI]["code"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["snils"]["editable"], 1, 0) + Iif(aTablePers[nI]["snils"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["lastName"]["editable"], 1, 0) + Iif(aTablePers[nI]["lastName"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["LastInfo"][1]["calc"]["editable"], 1, 0) + Iif(aTablePers[nI]["LastInfo"][1]["calc"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["LastInfo"][1]["baseSum"]["editable"], 1, 0) + Iif(aTablePers[nI]["LastInfo"][1]["baseSum"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["LastInfo"][2]["calc"]["editable"], 1, 0) + Iif(aTablePers[nI]["LastInfo"][2]["calc"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["LastInfo"][2]["baseSum"]["editable"], 1, 0) + Iif(aTablePers[nI]["LastInfo"][2]["baseSum"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["insurYY"]["editable"], 1, 0) + Iif(aTablePers[nI]["insurYY"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["insurMM"]["editable"], 1, 0) + Iif(aTablePers[nI]["insurMM"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["insurYY"]["editable"], 1, 0) + Iif(aTablePers[nI]["insurYY"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["kfReg"]["editable"], 1, 0) + Iif(aTablePers[nI]["kfReg"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["kfShortDays"]["editable"], 1, 0) + Iif(aTablePers[nI]["kfShortDays"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["begin"]["editable"], 1, 0) + Iif(aTablePers[nI]["begin"]["required"], 2, 0)) + " "
        cTemp2 += CValToChar(Iif(aTablePers[nI]["end"]["editable"], 1, 0) + Iif(aTablePers[nI]["end"]["required"], 2, 0)) + " "
        If RecLock(cRU07T1401MainAlias, .T.)
            (cRU07T1401MainAlias)->LIST_OKK   := "0"
            (cRU07T1401MainAlias)->LIST_CODE  := aTablePers[nI]["code"]["value"]
            (cRU07T1401MainAlias)->LIST_CIC   := aPers[2]
            (cRU07T1401MainAlias)->LIST_NOME  := aPers[3]
            (cRU07T1401MainAlias)->LIST_NBDAY := aTablePers[nI]["baseCalcDays"]["value"]
            (cRU07T1401MainAlias)->LIST_YEAR1 := aTablePers[nI]["LastInfo"][1]["calc"]["value"]
            (cRU07T1401MainAlias)->LIST_SUMM1 := aTablePers[nI]["LastInfo"][1]["baseSum"]["value"]
            (cRU07T1401MainAlias)->LIST_YEAR2 := aTablePers[nI]["LastInfo"][2]["calc"]["value"]
            (cRU07T1401MainAlias)->LIST_SUMM2 := aTablePers[nI]["LastInfo"][2]["baseSum"]["value"]
            (cRU07T1401MainAlias)->LIST_EYEAR := aTablePers[nI]["insurYY"]["value"]
            (cRU07T1401MainAlias)->LIST_EMOUN := aTablePers[nI]["insurMM"]["value"]
            (cRU07T1401MainAlias)->LIST_EXPER := cTemp
            (cRU07T1401MainAlias)->LIST_KS206 := Iif(Empty(aTablePers[nI]["kfReg"]["value"]), "1", CValToChar(Round(Val(aTablePers[nI]["kfReg"]["value"]) / 100, 2)))
            (cRU07T1401MainAlias)->LIST_KNFWT := aTablePers[nI]["kfShortDays"]["value"]
            cTemp := DToS(aTablePers[nI]["begin"]["value"])
            (cRU07T1401MainAlias)->LIST_PERB  := SubStr(cTemp, 1, 4) + "-" + SubStr(cTemp, 5, 2) + "-" + SubStr(cTemp, 7)
            cTemp := DToS(aTablePers[nI]["end"]["value"])
            (cRU07T1401MainAlias)->LIST_PERE  := SubStr(cTemp, 1, 4) + "-" + SubStr(cTemp, 5, 2) + "-" + SubStr(cTemp, 7)
            (cRU07T1401MainAlias)->LIST_SETTV := cTemp2
            (cRU07T1401MainAlias)->LIST_SASTN := aTablePers[nI]["socialAssistNum"]["value"]
            (cRU07T1401MainAlias)->LIST_SRANO := aPers[4]
            (cRU07T1401MainAlias)->LIST_SR8NO := Iif(aPers[4] > 0, RU07T1409_GetDataFromBd(aTablePers[nI]["code"]["value"], "2")[1], 0)
            (cRU07T1401MainAlias)->LIST_NUMLI := "1"
            (cRU07T1401MainAlias)->LIST_CSTAT := "1"
            (cRU07T1401MainAlias)->LIST_LINK  := 0
            (cRU07T1401MainAlias)->LIST_ORDFI := (cRU07T1401MainAlias)->(RecNo())
            (cRU07T1401MainAlias)->(MsUnLock())
        EndIf
    Next nI

    RestArea(aArea)
    SRA->(RestArea(aSRArea))
    
Return nCount

/*/{Protheus.doc} RU07T1409_GetDataFromBd(cVar, cType)

        This function get exist data.

        @type Function
        @param cVar,  Character, Value for seek data
        @param cType, Character, Type of data which need get
        @return aResult, Array, Result array
        @author dchihov
        @since 02.02.2024
        @version 12.1.23.10
        @example aPers := RU07T1409_GetDataFromBd(aTablePers[nI]["snils"]["value"], "1")
*/
Function RU07T1409_GetDataFromBd(cVar, cType)

    Local aResult As Array
    Local aArea   As Array
    Local aXArea  As Array
    Local nOrder  As Numeric
    Local nTemp   As Numeric
    Local lSeeAll As Logical
    aArea := GetArea()
    lSeeAll := VerSenha(114) .And. VerSenha(115)
    If cType == "1"
        aXArea := SRA->(GetArea())
        DbSelectArea("SRA")
        nOrder := RetOrdem("SRA", "RA_CIC")
        SRA->(DbSetOrder(nOrder))
        aResult := { .T., "", "", 0}
        If SRA->(DbSeek(cVar, .T.))
            aResult[1] := .F.
            aResult[2] := SRA->RA_CIC
            aResult[3] := SRA->RA_NOMECMP
            aResult[4] := SRA->(RecNo())
        EndIf
        SRA->(RestArea(aXArea))
    ElseIf cType == "2"
        nTemp := (cRU07T1401MainAlias)->LIST_SRANO
        aResult := {0}
        If nTemp > 0
            cQuery := "SELECT R_E_C_N_O_ RECN FROM " + RetSQLName("SR8") + CRLF
            cQuery += "WHERE R8_OBSAFAS = " + "'" + cVar + "' AND R8_MAT = '" + SRA->RA_MAT + "' AND D_E_L_E_T_ = '' AND R_E_C_D_E_L_ = 0"

            cAlias := GetNextAlias()

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)
            DbSelectArea(cAlias)
            (cAlias)->(DbGoTop())
            If (cAlias)->(EOF())
                aResult := {0}
            Else
                aResult := {(cAlias)->RECN}
            EndIf
            (cAlias)->(DbCloseArea())
        EndIf
    EndIf

    RestArea(aArea)

Return aResult

/*/{Protheus.doc} RU07T1410_FormatYYMM(nVal, cType)

    This function formation for year or mounth by experience.

    @type Function
    @param nVal,  Numeric,   Value for formation
    @param cType, Character, Type of data for format
    @return cResStr, Character, formatted string
    @author dchihov
    @since 02.02.2024
    @version 12.1.23.10
    @example cTemp := RU07T1410_FormatYYMM(aTablePers[nI]["insurYY"]["value"], "1")
*/
Function RU07T1410_FormatYYMM(nVal, cType)

    Local cResStr  As Character
    Local nTemp As Numeric
    
    If nVal < 1
        cResStr := Iif(cType == "1", "", "0 " + STR0039) // months
    Else
        nTemp := nVal % 10
        cResStr := CValToChar(nVal) + " "
        If cType == "1"
            If (nVal / 10) % 10 == 1
                cResStr += STR0036 // years
            ElseIf nTemp == 1
                cResStr += STR0034 // year
            ElseIf nTemp > 1 .And. nTemp < 5
                cResStr += STR0035 // of the year
            Else
                cResStr += STR0036 // years
            EndIf
        ElseIf cType == "2"
            If (nVal / 10) % 10 == 1
                cResStr += STR0039 // months
            ElseIf nTemp == 1
                cResStr += STR0037 // month
            ElseIf nTemp > 1 .And. nTemp < 5
                cResStr += STR0038 // months
            Else
                cResStr += STR0039 // months
            EndIf
        EndIf
    EndIf

Return cResStr

/*/{Protheus.doc} RU07T1411_UpdateGrid(oMainView, nGrid)

    This function update view.

    @type Function
    @param oMainView, Object, View of form.
    @param nGrid,    Numeric, Which grid is update.
    @return 
    @author dchihov
    @since 02.02.2024
    @version 12.1.23.10
    @example RU07T1411_UpdateGrid(oMainView)
*/
Function RU07T1411_UpdateGrid(oMainView, nGrid)

    Local oList    As Object
    Local aData    As Array
    Local aNewData As Array
    Local nNumInd  As Numeric
    Local nTemp    As Numeric
    Local nI       As Numeric

    Default nGrid := 3

    nTemp := nGrid % 2

    If nTemp > 0
        oList := oMainView:GetModel("RU07T14LIST")
        aData := RU07T1402_LoadGrid(oList, .F.)
        aNewData := {}
        nNumInd := AScan(oList:OFORMMODELSTRUCT:AFIELDS, {|X| X[MODEL_FIELD_IDFIELD] == "LIST_NUMLI"})
        For nI := 1 To Len(aData)
            If /*AScan(oList:aDataModel, {|X| X[MODEL_GRID_ID] == aData[nI, 1]}) < 1 .And.*/ aData[nI, 2, nNumInd] == "1"
                aAdd(aNewData, aData[nI])
            EndIf
        Next nI
        If Len(aNewData) > 0
            //If lRU07T1401InitGrid
                AEval(oList:aDataModel, {|X|, X[MODEL_GRID_ID] := 0})
                oList:ClearData(.F., .F.)
                lRU07T1401InitGrid := .F.
            //EndIf
            oList:Load(aNewData)
            oMainView:Refresh("RU07T14LIST")
        EndIf
    EndIf

    If nGrid - nTemp > 0
        oList := oMainView:GetModel("RU07T14ITEM")
        aData := RU07T1402_LoadGrid(oList, .F.)
        aNewData := {}
        nNumInd := AScan(oList:OFORMMODELSTRUCT:AFIELDS, {|X| X[MODEL_FIELD_IDFIELD] == "LIST_NUMLI"})
        For nI := 1 To Len(aData)
            If /*AScan(oList:aDataModel, {|X| X[MODEL_GRID_ID] == aData[nI, 1]}) < 1 .And. */aData[nI, 2, nNumInd] == "2"
                aAdd(aNewData, aData[nI])
            EndIf
        Next nI
        If Len(aNewData) > 0
            // If lRU07T1402InitGrid
                AEval(oList:aDataModel, {|X|, X[MODEL_GRID_ID] := 0})
                oList:ClearData(.F., .F.)
                lRU07T1402InitGrid := .F.
            // EndIf
            oList:Load(aNewData)
            oMainView:Refresh("RU07T14ITEM")
        EndIf
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1412_CheckEmpl(cSNILS, lNum, nIdRec)

    This function check exist TN for snils.

    @type Function
    @param cSNILS, Character, Snils for view.
    @param lNum,   Numeric, Mode for call function.
    @param nIdRec, Numeric, Id record.
    @return xRes, Result (if mode non numeric it's logical, numeric mode for get color).
    @author dchihov
    @since 05.02.2024
    @version 12.1.23.10
    @example oBrowse:oBrowse:SetBlkBackColor(&("{|| RU07T1412_CheckEmpl(Self:oData:aShow[Self:nAt][3], .T., Self:oData:oSubmodel:aDataModel[Self:oData:aShow[Self:nAt, Self:oData:nPosModelLine], " + CValToChar(MODEL_GRID_ID) + "])}"))
*/
Function RU07T1412_CheckEmpl(cSNILS, lNum, nIdRec)

    Local aArea  As Array
    Local aTArea As Array
    Local lCans  As Logical
    Local xRes

    Default lNum := .F.

    xRes := .F.

    aArea := GetArea()
    aTArea := (cRU07T1401MainAlias)->(GetArea())
    (cRU07T1401MainAlias)->(DbSetOrder(3))
    If nIdRec > 0
        (cRU07T1401MainAlias)->(DbGoTo(nIdRec))
        lCans := !Empty(AllTrim((cRU07T1401MainAlias)->LIST_CIC))
    Else
        lCans := (cRU07T1401MainAlias)->(MsSeek(cSNILS))
    EndIf

    // If lNum - return color
    If lNum
        If Empty(cSNILS) .And. nIdRec < 1 .Or. (cRU07T1401MainAlias)->LIST_LINK < 1
            xRes := CLR_WHITE
        ElseIf lCans .And. (cRU07T1401MainAlias)->LIST_SR8NO > 0
            If (cRU07T1401MainAlias)->LIST_CSTAT == "1"
                xRes := CLR_WHITE
            ElseIf (cRU07T1401MainAlias)->LIST_CSTAT == "2"
                xRes := CLR_YELLOW
            EndIf
        Else
            // state for not finding employee
            xRes := CLR_HRED
        EndIf
    Else
        If (cRU07T1401MainAlias)->(MsSeek(cSNILS)) .And. (cRU07T1401MainAlias)->LIST_CANS == "1" .And. RU07T1404_CheckCanSelect(,,,, .F.)
            xRes := .T.
        EndIf
    EndIf

    (cRU07T1401MainAlias)->(RestArea(aTArea))
    RestArea(aArea)

Return xRes

/*/{Protheus.doc} RU07T1413_SimulationCalculation(oModel, oView)

    This function run simulation of calculation.

    @type Function
    @param oModel, Object, Model of routine.
    @param oView,  Object, View of routine.
    @return 
    @author dchihov
    @since 05.02.2024
    @version 12.1.23.10
    @example oView:AddUserButton(STR0005, "BUTTON2", {|oView| RU07T1413_SimulationCalculation(oModel, oView)}) // "Show calculation"
*/
Function RU07T1413_SimulationCalculation(oModel, oView)

    MsAguarde({|| RU07T1414_Simulation(oModel, oView)}, STR0026, STR0043) // "Please wait", "Simulation of calculation for absences:"

Return .T.

/*/{Protheus.doc} RU07T1414_Simulation(oModel, oView)

    This function simulation of calculation.

    @type Function
    @param oModel, Object, Model of routine.
    @param oView,  Object, View of routine.
    @return 
    @author dchihov
    @since 05.02.2024
    @version 12.1.23.10
    @example MsAguarde({|| RU07T1414_Simulation(oModel, oView)}, STR0026, STR0043) // "Please wait", "Simulation of calculation for absences:"
*/
Function RU07T1414_Simulation(oModel, oView)

    Local aArea       As Array
    Local aSRAArea    As Array
    Local aSR8Area    As Array
    Local aDataForAb  As Array
    Local aGetTreeFrm As Array
    Local oRpoForm    As Object
    Local oGrid       As Object
    Local oGrid2      As Object
    Local oBrw        As Object
    Local cSaveFil    As Character
    Local cExcept     As Character
    Local cTemp       As Character
    Local cRot        As Character
    Local nLenght     As Numeric
    Local nLine1      As Numeric
    Local nI          As Numeric

    Private oRU07XFU01 := RUHRElnDataForElnItem():New("01")

    oGrid := oModel:GetModel("RU07T14LIST")
    oGrid2 := oModel:GetModel("RU07T14ITEM")
    oBrw := oView:GetViewObj("RU07T14LIST")[3]
    aArea := GetArea()
    aSRAArea := SRA->(GetArea())
    aSR8Area := SR8->(GetArea())
    DbSelectArea("SRA")
    DbSelectArea("SR8")
    nLenght := oGrid:Length()
    nLine1 := oBrw:oBrowse:oData:aShow[oBrw:oBrowse:aVisibleReg[1], oBrw:oBrowse:oData:nPosModelLine]
    cTemp   := CValToChar(nLenght)
    cExcept := ""
    cSaveFil := cFilAnt

    bErro := ErrorBlock( { |e| RU07T1405_Error(e, , @cExcept) } )
    Begin Sequence
        For nI := 1 To oGrid:Length()
            If oGrid:GetDataId() > 0
                MsProcTxt(STR0043 + " " + CValToChar(nI) + "/" + cTemp) // "Simulation of calculation for absences:"
                If oGrid:GetValue("LIST_SR8NO", nI) > 0 .And. oGrid:GetValue("LIST_SRANO", nI) > 0
                    SRA->(DbGoTo(oGrid:GetValue("LIST_SRANO", nI)))
                    SR8->(DbGoTo(oGrid:GetValue("LIST_SR8NO", nI)))
                    cFilAnt := SRA->RA_FILIAL
                    aDataForAb := {SubStr(DToS(SR8->R8_DATAINI), 1, 6), {1, {SR8->(RecNo())}}}
                    SetMnemonicos(NIL,NIL,.T.)
                    cRot := "FOL"
                    SetRotExec(cRot)
                    SetPeriodCalc(SubStr(DToS(SR8->R8_DATAINI), 1, 6))
                    SetNumPgCalc(SR8->R8_NUMPAGO)
                    cMatNum := SRA->RA_MAT
                    cMatFil := SRA->RA_FILIAL

                    GetTreeFrm(@aGetTreeFrm, cFilAnt, NIL, NIL, .T., @oRpoForm, .T.)

                    IsEndCalc()

                    S_CARGARCH()
                    S_LTABELAS()
                    S_HRSCALC()
                    S_RESIDEXT()
                    S_NCOMPHRS()
                    S_SALMES()
                    S_SALHORA()
                    S_SALDIA()
                    S_SALARIO()

                    fAbsences(SRA->RA_MAT, aDataForAb[1], aDataForAb[2])
                    // Closing additional RPO
                    LeaveExecRot()
                    RpoFormInit(NIL, .T.)
                    If oRU07XFU01:Validate(.F.)
                        RU07T1415_AddCalcIntoTempTable(oRU07XFU01, "01", oGrid:GetDataId(nI))
                    Else
                        RU07T1415_AddCalcIntoTempTable(oRU07XFU01, "02", oGrid:GetDataId(nI), .T., .T.)
                    EndIf
                ElseIf oGrid:GetValue("LIST_SRANO", nI) > 0
                    SRA->(DbGoTo(oGrid:GetValue("LIST_SRANO", nI)))
                    oRU07XFU01:SetDefEmptyVal()
                    oRU07XFU01:cSNILS := SRA->RA_CIC
                    oRU07XFU01:cNOME := SRA->RA_NOMECMP
                    RU07T1415_AddCalcIntoTempTable(oRU07XFU01, "02", oGrid:GetDataId(nI), .T., .F.)
                Else
                    RU07T1415_AddCalcIntoTempTable(, "02", oGrid:GetDataId(nI))
                EndIf
            EndIf
        Next nI
    End Sequence
    cFilAnt := cSaveFil
    ErrorBlock(bErro)
    If Empty(cExcept)
        MsgInfo(STR0045, STR0044) // "Absence calculation simulation completed successfully", "Done"
    Else
        AutoGrLog(cExcept)
        MostraErro()
    EndIf
    RU07T1411_UpdateGrid(oView)
    FwFreeObj(oRU07XFU01)
    RestArea(aArea)
    SRA->(RestArea(aSRAArea))
    SR8->(RestArea(aSR8Area))

Return .T.

/*/{Protheus.doc} RU07T1415_AddCalcIntoTempTable(oItem, cType, nIdRec, lWriteLink, lWriteLin2)

    This function added item into temp table after calculation.

    @type Function
    @param oItem,       Object, Item for added
    @param cType,    Character, Type of added
    @param nIdRec,     Numeric, Linked record ID
    @param lWriteLink, Logical, Write link on current SRA
    @param lWriteLin2, Logical, Write link on current SR8
    @return 
    @author dchihov
    @since 07.02.2024
    @version 12.1.23.10
    @example RU07T1415_AddCalcIntoTempTable(, "02", oGrid:GetDataId(nI))
*/
Function RU07T1415_AddCalcIntoTempTable(oItem, cType, nIdRec, lWriteLink, lWriteLin2)

    Local cTemp  As Character
    Local cSAN   As Character
    Local nNewId As Numeric
    Local lNew   As Logical
    Local aMArea As Array
    Local oNewE  As Object

    Default oItem := Nil
    Default lWriteLink := .F.
    Default lWriteLin2 := .F.

    aMArea := (cRU07T1401MainAlias)->(GetArea())
    nNewId := 0
    lNew := .T.
    (cRU07T1401MainAlias)->(DbGoTo(nIdRec))
    cSAN := (cRU07T1401MainAlias)->LIST_SASTN
    If (cRU07T1401MainAlias)->LIST_LINK > 0
        lNew := .F.
        nNewId := (cRU07T1401MainAlias)->LIST_LINK
        (cRU07T1401MainAlias)->(DbGoTo(nNewId))
    EndIf
    If ValType(oItem) == "O"
        ASort(oItem:aLastYear, , , {|X, Y| X[1] < Y[1]})
    EndIf

    If RecLock(cRU07T1401MainAlias, lNew)
        If cType == "01"
            (cRU07T1401MainAlias)->LIST_OKK   := "0"
            (cRU07T1401MainAlias)->LIST_CODE  := oItem:cNumberOfELN
            (cRU07T1401MainAlias)->LIST_CIC   := oItem:cSNILS
            (cRU07T1401MainAlias)->LIST_NOME  := oItem:cNome
            (cRU07T1401MainAlias)->LIST_NBDAY := oItem:nCDays
            (cRU07T1401MainAlias)->LIST_YEAR1 := oItem:aLastYear[1, 1]
            (cRU07T1401MainAlias)->LIST_SUMM1 := AllTrim(Str(oItem:aLastYear[1, 2], , 2))
            (cRU07T1401MainAlias)->LIST_YEAR2 := oItem:aLastYear[2, 1]
            (cRU07T1401MainAlias)->LIST_SUMM2 := AllTrim(Str(oItem:aLastYear[2, 2], , 2))
            (cRU07T1401MainAlias)->LIST_EYEAR := oItem:nYExperience
            (cRU07T1401MainAlias)->LIST_EMOUN := oItem:nMExperience
            cTemp := RU07T1410_FormatYYMM(oItem:nYExperience, "1")
            cTemp += Iif(Empty(cTemp), "", CRLF) + RU07T1410_FormatYYMM(oItem:nMExperience, "2")
            (cRU07T1401MainAlias)->LIST_EXPER := cTemp
            (cRU07T1401MainAlias)->LIST_KS206 := CValToChar(oItem:nRegKoeff)
            (cRU07T1401MainAlias)->LIST_KNFWT := CValToChar(oItem:nKoeffNNWT)
            cTemp := DToS(oItem:dDateStart)
            (cRU07T1401MainAlias)->LIST_PERB  := SubStr(cTemp, 1, 4) + "-" + SubStr(cTemp, 5, 2) + "-" + SubStr(cTemp, 7)
            cTemp := DToS(oItem:dDateFin)
            (cRU07T1401MainAlias)->LIST_PERE  := SubStr(cTemp, 1, 4) + "-" + SubStr(cTemp, 5, 2) + "-" + SubStr(cTemp, 7)

            (cRU07T1401MainAlias)->LIST_SETTV := ""
            (cRU07T1401MainAlias)->LIST_SASTN := cSAN
            (cRU07T1401MainAlias)->LIST_SRANO := SRA->(RecNo())
            (cRU07T1401MainAlias)->LIST_SR8NO := SR8->(RecNo())
            (cRU07T1401MainAlias)->LIST_NUMLI := "2"
            If lNew
                (cRU07T1401MainAlias)->LIST_CSTAT := "1"
                (cRU07T1401MainAlias)->LIST_LINK  := nIdRec
                (cRU07T1401MainAlias)->LIST_ORDFI := nIdRec
            EndIf
            (cRU07T1401MainAlias)->(MsUnLock())
            nNewId := (cRU07T1401MainAlias)->(RecNo())
        ElseIf cType == "02"
            If ValType(oItem) == "U"
                oNewE := RUHRElnDataForElnItem():New("01")
            Else
                oNewE := oItem
            EndIf
            (cRU07T1401MainAlias)->LIST_OKK   := "0"
            (cRU07T1401MainAlias)->LIST_CODE  := Iif(ValType(oNewE:cNumberOfELN) == "C", oNewE:cNumberOfELN, STR0042) // "no data"
            (cRU07T1401MainAlias)->LIST_CIC   := Iif(ValType(oNewE:cSNILS) == "C", oNewE:cSNILS, STR0042) // "no data"
            (cRU07T1401MainAlias)->LIST_NOME  := Iif(ValType(oNewE:cNome) == "C", oNewE:cNome, STR0042) // "no data"
            (cRU07T1401MainAlias)->LIST_NBDAY := Iif(ValType(oNewE:nCDays) == "N", oNewE:nCDays, -1) // "no data"
            (cRU07T1401MainAlias)->LIST_YEAR1 := Iif(ValType(oNewE:aLastYear[1, 1]) == "C", oNewE:aLastYear[1, 1], STR0042) // "no data"
            (cRU07T1401MainAlias)->LIST_SUMM1 := Iif(ValType(oNewE:aLastYear[1, 2]) == "N", AllTrim(Str(oNewE:aLastYear[1, 2], , 2)), STR0042) // "no data"
            (cRU07T1401MainAlias)->LIST_YEAR2 := Iif(ValType(oNewE:aLastYear[2, 1]) == "C", oNewE:aLastYear[2, 1], STR0042) // "no data"
            (cRU07T1401MainAlias)->LIST_SUMM2 := Iif(ValType(oNewE:aLastYear[2, 2]) == "N", AllTrim(Str(oNewE:aLastYear[2, 2], , 2)), STR0042) // "no data"
            (cRU07T1401MainAlias)->LIST_EYEAR := Iif(ValType(oNewE:nYExperience) == "N", oNewE:nYExperience, -1)
            (cRU07T1401MainAlias)->LIST_EMOUN := Iif(ValType(oNewE:nMExperience) == "N", oNewE:nMExperience, -1)
            (cRU07T1401MainAlias)->LIST_EXPER := Iif(ValType(cTemp) == "C", cTemp, STR0042) // "no data"
            (cRU07T1401MainAlias)->LIST_KS206 := Iif(ValType(oNewE:nRegKoeff) == "N", CValToChar(oNewE:nRegKoeff), STR0042) // "no data"
            (cRU07T1401MainAlias)->LIST_KNFWT := Iif(ValType(oNewE:nKoeffNNWT) == "N", CValToChar(oNewE:nKoeffNNWT), STR0042) // "no data"
            cTemp := Iif(ValType(oNewE:dDateStart) == "D", DToS(oNewE:dDateStart), "")
            (cRU07T1401MainAlias)->LIST_PERB  := Iif(Empty(cTemp), STR0042, SubStr(cTemp, 1, 4) + "-" + SubStr(cTemp, 5, 2) + "-" + SubStr(cTemp, 7)) // "no data"
            cTemp := Iif(ValType(oNewE:dDateFin) == "D", DToS(oNewE:dDateFin), "")
            (cRU07T1401MainAlias)->LIST_PERE  := Iif(Empty(cTemp), STR0042, SubStr(cTemp, 1, 4) + "-" + SubStr(cTemp, 5, 2) + "-" + SubStr(cTemp, 7)) // "no data"

            (cRU07T1401MainAlias)->LIST_SETTV := ""
            (cRU07T1401MainAlias)->LIST_SASTN := cSAN
            (cRU07T1401MainAlias)->LIST_SRANO := Iif(lWriteLink, SRA->(RecNo()), 0)
            (cRU07T1401MainAlias)->LIST_SR8NO := Iif(lWriteLin2, SR8->(RecNo()), 0)
            (cRU07T1401MainAlias)->LIST_NUMLI := "2"
            If lNew
                (cRU07T1401MainAlias)->LIST_CSTAT := "1"
                (cRU07T1401MainAlias)->LIST_LINK := nIdRec
                (cRU07T1401MainAlias)->LIST_ORDFI := nIdRec
            EndIf
            (cRU07T1401MainAlias)->(MsUnLock())
            nNewId := (cRU07T1401MainAlias)->(RecNo())
        EndIf
    EndIf

    (cRU07T1401MainAlias)->(DbGoTo(nIdRec))
    If RecLock(cRU07T1401MainAlias, .F.)
        (cRU07T1401MainAlias)->LIST_LINK := nNewId
    EndIf

    (cRU07T1401MainAlias)->(RestArea(aMArea))

Return nNewId

/*/{Protheus.doc} RU07T1416_FillCustomSortField(oGrid)

    This function fill custom field for sorting data.

    @type Function
    @param oGrid, Object, Grid with sort
    @return 
    @author dchihov
    @since 08.02.2024
    @version 12.1.23.10
    @example RU07T1416_FillCustomSortField(oGrid)
*/
Function RU07T1416_FillCustomSortField(oGrid, oView, oBrw, oBrw2)

    Local nItem  As Numeric
    Local nLine  As Numeric
    Local nI     As Numeric
    Local aArea  As Array
    Local aMArea As Array

    aArea := GetArea()
    aMArea := (cRU07T1401MainAlias)->(GetArea())
    nLine := oGrid:nLine

    For nI := 1 To Len(oBrw:oBrowse:oData:aShow) // oGrid:Length()
        oGrid:GoLine(oBrw:oBrowse:oData:aShow[nI, oBrw:oBrowse:oData:nPosModelLine])
        nItem := oGrid:GetDataId() // oGrid:GetDataId(nI)
        (cRU07T1401MainAlias)->(DbGoTo(nItem))
        If RecLock(cRU07T1401MainAlias, .F.)
            (cRU07T1401MainAlias)->LIST_ORDFI := nI
            oGrid:SetValue("LIST_ORDFI", nI)
            // oBrw:SetValue("LIST_ORDFI", nI, )
            (cRU07T1401MainAlias)->(MsUnLock())
            nItem := (cRU07T1401MainAlias)->LIST_LINK
            If nItem > 0
                (cRU07T1401MainAlias)->(DbGoTo(nItem))
                If RecLock(cRU07T1401MainAlias, .F.)
                    (cRU07T1401MainAlias)->LIST_ORDFI := nI
                    (cRU07T1401MainAlias)->(MsUnLock())
                EndIf
            EndIf
        EndIf
    Next nI

    oGrid:GoLine(nLine)
    oBrw2:ResetProperties()

    RestArea(aArea)
    (cRU07T1401MainAlias)->(RestArea(aMArea))

Return .T.

/*/{Protheus.doc} RU07T1417_HeaderClick(oView, oBrowse1, oBrowse2, cIdModel, nGrForUpd)

    This function for click on header.

    @type Function
    @param oView   ,  Object,    View
    @param oBrowse1,  Object,    FormGrid for grid 1
    @param oBrowse2,  Object,    Formgrid for grid 2
    @param cIdModel,  Character, Id Model which call event
    @param nGrForUpd, Numeric,   Number grid for update
    @return 
    @author dchihov
    @since 08.02.2024
    @version 12.1.23.10
    @example AEval(oBrowse1:oBrowse:aColumns, {|X| X:SetHeaderClick( {|| RU07T1417_HeaderClick(oView, oBrowse1, oBrowse2, "RU07T14LIST", 2) } )}, 2)
*/
Function RU07T1417_HeaderClick(oView, oBrowse1, oBrowse2, cIdModel, nGrForUpd)

    Local nLine As Numeric
    Local oGrid As Object

    oBrowse1:TGRIDORDERCOLUMN()
    oGrid := oBrowse1:oControl:GetModel(cIdModel)
    RU07T1416_FillCustomSortField(oGrid, oView, oBrowse1, oBrowse2)
    RU07T1411_UpdateGrid(oView, nGrForUpd)
    nLine := oGrid:GetDataId(oBrowse1:oBrowse:oData:aShow[oBrowse1:oBrowse:aVisibleReg[1], oBrowse1:oBrowse:oData:nPosModelLine])
    oGrid := oBrowse2:oControl:GetModel(oBrowse2:cSelfModelid)
    oGrid:SeekLine({{"LIST_LINK", nLine}})
    oView:Refresh(oBrowse2:cSelfModelid)

Return .T.

/*/{Protheus.doc} RU07T1418_Moved(oView, oBrowse1, oBrowse2, oBrowse, nMoveType, nCursorPos, nQtdLinha, nVisbleRow)

    This function for move on grid.

    @type Function
    @param oView     , Object , View
    @param oBrowse1  , Object , FormGrid for grid 1
    @param oBrowse2  , Object , Formgrid for grid 2
    @param oBrowse   , Object , Browse:Browse in formgrid
    @param nMoveType , Numeric, Type of Move
    @param nCursorPos, Numeric, Current position
    @param nQtdLinha , Numeric, Count of moving line
    @param nVisbleRow, Numeric, Count od visible line
    @return 
    @author dchihov
    @since 08.02.2024
    @version 12.1.23.10
    @example oBrowse1:oBrowse:bOnMove := {|oBrowse, nMoveType, nCursorPos, nQtdLinha, nVisbleRow| RU07T1418_Moved(oView, oBrowse1, oBrowse2, oBrowse, nMoveType, nCursorPos, nQtdLinha, nVisbleRow)}
*/
Function RU07T1418_Moved(oView, oBrowse1, oBrowse2, oBrowse, nMoveType, nCursorPos, nQtdLinha, nVisbleRow)

    Local nLine As Numeric
    Local nLin2 As Numeric
    local aView As Array
    Local oGrid As Object

    aView := {oBrowse1:oBrowse:oData:aShow[oBrowse1:oBrowse:aVisibleReg[1], oBrowse1:oBrowse:oData:nPosModelLine]}

    oBrowse1:TGridOnMove(oBrowse, nMoveType, nCursorPos, nQtdLinha, nVisbleRow)

    If aView[1] != oBrowse1:oBrowse:oData:aShow[oBrowse1:oBrowse:aVisibleReg[1], oBrowse1:oBrowse:oData:nPosModelLine]
        oGrid := oBrowse1:oControl:GetModel(oBrowse1:cSelfModelid)
        nLine := oGrid:GetDataId(oBrowse1:oBrowse:oData:aShow[oBrowse1:oBrowse:aVisibleReg[1], oBrowse1:oBrowse:oData:nPosModelLine])
        oGrid := oBrowse2:oControl:GetModel(oBrowse2:cSelfModelid)
        oGrid:SeekLine({{"LIST_LINK", nLine}})
        oView:Refresh(oBrowse2:cSelfModelid)
    Else
        oGrid := oBrowse1:oControl:GetModel(oBrowse1:cSelfModelid)
        nLine := oGrid:GetDataId()
        oGrid := oBrowse2:oControl:GetModel(oBrowse2:cSelfModelid)
        nLin2 := oGrid:GetLine()
        If !oGrid:SeekLine({{"LIST_LINK", nLine}})
            oGrid:GoLine(nLin2)
        EndIf
    EndIf
    aView := {oBrowse:GetCursorPos(), oBrowse1:oBrowse:nAt}
    If aView[1, 1] > Len(oBrowse2:oBrowse:aVisibleReg)
        aView[1, 1] := Len(oBrowse2:oBrowse:aVisibleReg)
        aView[2] := oBrowse2:oBrowse:aVisibleReg[aView[1, 1]]
    EndIf
    oBrowse2:oBrowse:nCursorPos := aView[1, 1] 
    oBrowse2:oBrowse:SelectRow(aView[1, 1])
    oBrowse2:oBrowse:Goto(aView[2], .F., .T.)

Return .T.

/*/{Protheus.doc} RU07T1419_CompareData(oMainView)

    This function Compare data from XML and from calculated.

    @type Function
    @return 
    @author dchihov
    @since 09.02.2024
    @version 12.1.23.10
    @example oView:AddUserButton(STR0006, "BUTTON3", {|oView| RU07T1419_CompareData(oView)}) // "Data Comparison"
*/
Function RU07T1419_CompareData(oMainView)

    Local aArea  As Array
    local aMArea As Array

    aArea := GetArea()
    aMArea := (cRU07T1401MainAlias)->(GetArea())

    (cRU07T1401MainAlias)->(DbSetOrder(1))
    (cRU07T1401MainAlias)->(DbGoTop())

    While !(cRU07T1401MainAlias)->(EOF()) .And. (cRU07T1401MainAlias)->LIST_NUMLI == "1"
        If (cRU07T1401MainAlias)->LIST_LINK > 0 .And. (cRU07T1401MainAlias)->LIST_SR8NO > 0 .And. (cRU07T1401MainAlias)->LIST_SRANO > 0
            RU07T1420_CompareRecord((cRU07T1401MainAlias)->LIST_LINK)
        EndIf
        (cRU07T1401MainAlias)->(DbSkip())
    EndDo

    MsgInfo(STR0049) // "The comparison of records and simulation results is complete. Differing entries are highlighted in color."
    RU07T1411_UpdateGrid(oMainView)

    RestArea(aArea)
    (cRU07T1401MainAlias)->(RestArea(aMArea))

Return .T.

/*/{Protheus.doc} RU07T1420_CompareRecord(nRecId)

    This function Compare current record and given one. (this function also mark stat after compare)

    @type Function
    @param nRecId, Numeric, Id record for comparing
    @return lRes,  Logical, Result of compare
    @author dchihov
    @since 09.02.2024
    @version 12.1.23.10
    @example RU07T1420_CompareRecord((cRU07T1401MainAlias)->LIST_LINK)
*/
Function RU07T1420_CompareRecord(nRecId)

    Local aArea As Array
    Local aVal  As Array
    Local nI    As Numeric
    Local lRes  As Logical
    Local xVal

    aArea := (cRU07T1401MainAlias)->(GetArea())
    aVal := {}
    lRes := .F.

    For nI := 1 To Len(aRU07T1401ComparesField)
        xVal := ""
        If aRU07T1401ComparesField[nI, 2] == "C"
            If aRU07T1401ComparesField[nI, 3] == "C"
                xVal := AllTrim((cRU07T1401MainAlias)->&(aRU07T1401ComparesField[nI, 1]))
            ElseIf aRU07T1401ComparesField[nI, 3] == "N"
                xVal := Val((cRU07T1401MainAlias)->&(aRU07T1401ComparesField[nI, 1]))
            EndIf
        ElseIf aRU07T1401ComparesField[nI, 2] == "N"
            xVal := (cRU07T1401MainAlias)->&(aRU07T1401ComparesField[nI, 1])
        ElseIf aRU07T1401ComparesField[nI, 2] == "S"
            xVal := SToD(StrTran((cRU07T1401MainAlias)->&(aRU07T1401ComparesField[nI, 1]), "-", ""))
        EndIf
        aAdd(aVal, {aRU07T1401ComparesField[nI], xVal})
    Next nI
    (cRU07T1401MainAlias)->(DbGoTo(nRecId))
    For nI := 1 To Len(aVal)
        xVal := ""
        If aVal[nI, 1, 2] == "C"
            If aVal[nI, 1, 3] == "C"
                xVal := AllTrim((cRU07T1401MainAlias)->&(aVal[nI, 1, 1]))
            ElseIf aVal[nI, 1, 3] == "N"
                xVal := Val((cRU07T1401MainAlias)->&(aVal[nI, 1, 1]))
            EndIf
        ElseIf aVal[nI, 1, 2] == "N"
            xVal := (cRU07T1401MainAlias)->&(aVal[nI, 1, 1])
        ElseIf aVal[nI, 1, 2] == "S"
            xVal := SToD(StrTran((cRU07T1401MainAlias)->&(aVal[nI, 1, 1]), "-", ""))
        EndIf
        lRes := lRes .Or. aVal[nI, 2] != xVal
    Next nI
    If RecLock(cRU07T1401MainAlias, .F.)
        (cRU07T1401MainAlias)->LIST_CSTAT := Iif(lRes, "2", "1")
        (cRU07T1401MainAlias)->(MsUnLock())
    EndIf

    (cRU07T1401MainAlias)->(RestArea(aArea))

    If RecLock(cRU07T1401MainAlias, .F.)
        (cRU07T1401MainAlias)->LIST_CSTAT := Iif(lRes, "2", "1")
        (cRU07T1401MainAlias)->(MsUnLock())
    EndIf
    lRes := !lRes

Return lRes

/*/{Protheus.doc} RU07T1421_MarkAll(oView, lFromGrid, lUnmark, cModel)

    This function mark/unmark all.

    @type Function
    @param oView,     Object,  Main view.
    @param lFromGrid, Logical, Called from Grid.
    @param lUnmark,   Logical, Unmark mode.
    @param cModel,  Character, Id model by grid from called.
    @param cModel2, Character, Id second model.
    @return 
    @author dchihov
    @since 10.04.2024
    @version 12.1.23.10
    @example oBrowse1:oBrowse:aColumns[1]:SetHeaderClick( {|| RU07T1421_MarkAll(, , , "RU07T14LIST")} )
*/
Function RU07T1421_MarkAll(oView, lFromGrid, lUnmark, cModel, cModel2)

    Local cQuery As Character
    Local cAlias As Character
    local cList  As Character
    Local oGrid  As Object
    Local oGrid2 As Object
    Local oModel As Object
    Local oBrw   As Object
    Local oBrw2  As Object
    Local nCount As Numeric
    Local nI     As Numeric
    local nLine1 As Numeric
    local nLine2 As Numeric
    local nLine3 As Numeric
    local nLineB As Numeric
    local nLineT As Numeric
    Local lVal   As Logical
    Local aArea  As Array
    Local aCursorPos As Array
    
    Default oView := FWViewActive()
    Default lFromGrid := .T.
    Default lUnmark := .F.

    oModel := FWModelActivate()
    oGrid := oModel:GetModel(cModel)
    oGrid2 := oModel:GetModel(cModel2)
    // If grid not empty
    If oGrid:GetDataId() > 0
        aArea := GetArea()

        // saved line pos in grid
        oBrw := oView:GetViewObj(cModel)[3]
        oBrw2 := oView:GetViewObj(cModel2)[3]
        nLine1 := oGrid:GetLine()
        nLineT := oGrid2:GetLine()
        nLineB := oBrw:oBrowse:nAt
        aCursorPos := oBrw:oBrowse:oBrowse:GetCursorPos()
        // from which list is called
        cList := oGrid:GetValue("LIST_NUMLI")
        // save grids in database
        SaveGrids(oModel)

        If lUnmark
            // Hard mode unmark
            lVal := .F.
        Else
            // If exist record which can be select, but not select - mode allmark else unmark
            cQuery := "SELECT R_E_C_N_O_ AS RECN FROM " + cRU07T1402RealName + CRLF
            cQuery += "WHERE LIST_OKK = '0' AND LIST_NUMLI = '" + cList + "'"

            cAlias := GetNextAlias()

            DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)

            nCount := 0
            (cAlias)->(DbGoTop())
            While !(cAlias)->(EOF())
                If RU07T1404_CheckCanSelect(,,,, .F., (cAlias)->RECN)
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
            If RU07T1404_CheckCanSelect(oGrid, , oGrid:GetValue("LIST_OK"), nI, .F.)
                // set mark/unmark
                oGrid:SetValue("LIST_OK", lVal)
            EndIf
        Next nI
        // Pos selected row
        nLine2 := oBrw:oBrowse:oData:aShow[oBrw:oBrowse:aVisibleReg[1], oBrw:oBrowse:oData:nPosModelLine]
        nLine3 := oBrw2:oBrowse:oData:aShow[oBrw2:oBrowse:aVisibleReg[1], oBrw2:oBrowse:oData:nPosModelLine]
        // Save grids in database
        SaveGrids(oModel)

        // Rest line pos and scroll
        oGrid:GoLine(nLine2)
        oGrid2:GoLine(nLine3)

        oView:Refresh("RU07T14LIST")
        oView:Refresh("RU07T14ITEM")
        If(lFromGrid)
            oGrid:GoLine(nLine1)
            oGrid2:GoLine(nLineT)
        EndIf

        // Rest selected pos
        oBrw:oBrowse:nCursorPos := aCursorPos[1] 
        oBrw:oBrowse:SelectRow(aCursorPos[1])
        oBrw:oBrowse:Goto(nLineB, .F., .T.)
        oBrw2:oBrowse:nCursorPos := aCursorPos[1] 
        oBrw2:oBrowse:SelectRow(aCursorPos[1])
        oBrw2:oBrowse:Goto(nLineB, .F., .T.)
        RestArea(aArea)
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1422_SaveLIST(oGrid)

    This function save list model (grid for list).

    @type Function
    @return 
    @author dchihov
    @since 10.04.2024
    @version 12.1.23.10
    @example RU07T1422_SaveLIST(oGrid)
*/
Static Function RU07T1422_SaveLIST(oGrid)

    Local nI          As Numeric
    Local cQuery      As Character

    cQuery := ""
    For nI := 1 To oGrid:Length()
        // Build query for update record in database from grid
        cQuery += "UPDATE " + cRU07T1402RealName + " SET LIST_OKK = " + Iif(oGrid:GetValue("LIST_OK", nI), "'1'", "'0'")
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

/*/{Protheus.doc} SaveGrids(oModel)

    This function called save grids.

    @type Function
    @return 
    @author dchihov
    @since 11.04.2024
    @version 12.1.23.10
    @example SaveGrids(oModel)
*/
Static Function SaveGrids(oModel)

    Default oModel := FWViewActive()

    oModel := FWModelActivate()
    RU07T1422_SaveLIST(oModel:GetModel("RU07T14LIST"))
    RU07T1422_SaveLIST(oModel:GetModel("RU07T14ITEM"))

Return .T.

/*/{Protheus.doc} RU07T1423_InvertMark(oView)

    This function invert mark.

    @type Function
    @param oView, Object, Main view.
    @return 
    @author dchihov
    @since 11.04.2024
    @version 12.1.23.10
    @example oView:AddUserButton(STR0008, "BUTTON5", {|oView| RU07T1423_InvertMark(oView)}) // "Invert mark"
*/
Function RU07T1423_InvertMark(oView)

    Local oGrid  As Object
    Local oModel As Object
    Local oBrw   As Object
    Local oBrw2  As Object
    Local nI     As Numeric
    local nLine1 As Numeric
    local nLine2 As Numeric
    local nLine3 As Numeric
    Local aCursorPos As Array
    
    Default oView := FWViewActive()

    oModel := FWModelActivate()
    oGrid := oModel:GetModel("RU07T14LIST")
    oBrw := oView:GetViewObj("RU07T14LIST")[3]
    oBrw2 := oView:GetViewObj("RU07T14ITEM")[3]
    // If grid not empty
    If oGrid:GetDataId() > 0

        // Save line pos and select row in grid
        nLine1 := oGrid:GetLine()
        aCursorPos := oView:GetViewObj("RU07T14LIST")[3]:oBrowse:oBrowse:GetCursorPos()
        SaveGrids(oModel)

        For nI := 1 To oGrid:Length()
            oGrid:GoLine(nI)
            If oGrid:GetValue("LIST_OK") == .T.
                oGrid:SetValue("LIST_OK", .F.)
            ElseIf RU07T1404_CheckCanSelect(oGrid, , oGrid:GetValue("LIST_OK"), nI, .F.)
                oGrid:SetValue("LIST_OK", .T.)
            EndIf
        Next nI
        nLine2 := oBrw:oBrowse:oData:aShow[oBrw:oBrowse:aVisibleReg[1], oBrw:oBrowse:oData:nPosModelLine]
        nLine3 := oBrw2:oBrowse:oData:aShow[oBrw2:oBrowse:aVisibleReg[1], oBrw2:oBrowse:oData:nPosModelLine]
        SaveGrids(oModel)
        // Rest line pos on first str in view grid
        oGrid:GoLine(nLine2)
        oModel:GetModel("RU07T14ITEM"):GoLine(nLine3)
        oView:Refresh("RU07T14LIST")
        oView:Refresh("RU07T14ITEM")
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1424_ValidMark(oGrid, lVal)

    This function set value by set mark on record.

    @type Function
    @param oGrid, Object, Grid for set value.
    @param lVal, Logical, Value for set.
    @return .T.
    @author dchihov
    @since 10.04.2024
    @version 12.1.23.10
    @example {|oGrid, cId, xVal| RU07T1424_ValidMark(oGrid, xVal)}
*/
Function RU07T1424_ValidMark(oGrid, lVal)

    Local oGridL  As Object
    Local nLinkId As Numeric
    Local nLine   As Numeric
    Local lLine   As Logical
    Local lLink   As Logical

    If !FwIsInCallStack("RU07T1424_ValidMark", 2)
        lLine := .F.
        lLink := .T.
        oGrid:SetValue("LIST_OKK", Iif(lVal, "1", "0"))
        oGridL := Iif(oGrid:cId == "RU07T14LIST", oGrid:oFormModel:GetModel("RU07T14ITEM"), oGrid:oFormModel:GetModel("RU07T14LIST"))
        nLinkId := oGrid:GetDataId()
        If oGridL:GetValue("LIST_LINK") <> nLinkId
            nLine := oGridL:GetLine()
            lLink := oGridL:SeekLine({{"LIST_LINK", nLinkId}})
            lLine := .T.
        EndIf
        If lLink
            oGridL:SetValue("LIST_OK", lVal)
        EndIf
        If lLine
            oGridL:GoLine(nLine)
        EndIf
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1425_CreateAgree()

    This function create agree by ZNS.

    @type Function
    @param oGrid, Object, Grid for set value.
    @param lVal, Logical, Value for set.
    @return .T.
    @author dchihov
    @since 11.04.2024
    @version 12.1.23.10
    @example oView:AddUserButton(STR0009, "BUTTON6", {|oView| RU07T1425_CreateAgree()})
*/
Function RU07T1425_CreateAgree()

    Local nCountOfAgree As Numeric

    MsAguarde({|| nCountOfAgree := RU07T1426_Agree()}, STR0026, STR0058 + " 0") // "Please wait", "Files generated:"

    If nCountOfAgree == 0
        MsgInfo(STR0061) // "There is no data to generate an answer, download and calculate ELN"
    ElseIf nCountOfAgree > 0
        MostraErro()
    EndIf

Return .T.

/*/{Protheus.doc} RU07T1426_Agree()

    This function create agree by ZNS.

    @type Function
    @return nCountOfAg, Numeric, Count of created files
    @author dchihov
    @since 11.04.2024
    @version 12.1.23.10
    @example nCountOfAgree := RU07T1426_Agree()
*/
Function RU07T1426_Agree()

    Local oModel     As Object
    Local oView      As Object
    Local oGrid      As Object
    Local oGrid2     As Object
    Local oBrw       As Object
    Local oBrw2      As Object
    Local oXMLWriter As Object
    Local oJSONSampl As Object
    Local bErro      As TGridKeyBlock
    Local cSplSymb   As Character
    Local cExcept    As Character
    Local cLocPath   As Character
    Local cLocTemp   As Character
    Local cTemp      As Character
    Local cTemp2     As Character
    Local cTempN     As Character
    Local cTempF     As Character
    Local nCountOfAg As Numeric
    Local nX         As Numeric
    Local nLineB     As Numeric
    Local nLine1     As Numeric
    Local nLine2     As Numeric
    Local aDirInfo   As Array
    Local aListFile  As Array
    Local aMArea     As Array
    Local aCursorPos As Array

    cLocPath := AllTrim(cGetFile("*", STR0059, 1, "C:\", .F., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_RETDIRECTORY, .T., .T.)) // "Select a path to save files"
    aListFile := {}
    If Len(cLocPath) == 0
        nCountOfAg := -1
    ElseIf ExistDir(cLocPath)
        oModel := FWModelActivate()
        oView := FWViewActive()
        oGrid := oModel:GetModel("RU07T14LIST")
        oGrid2 := oModel:GetModel("RU07T14ITEM")
        oBrw := oView:GetViewObj("RU07T14LIST")[3]
        oBrw2 := oView:GetViewObj("RU07T14ITEM")[3]
        nLineB := oBrw:oBrowse:nAt
        aCursorPos := oBrw:oBrowse:oBrowse:GetCursorPos()

        SaveGrids(oModel)
        aMArea := (cRU07T1401MainAlias)->(GetArea())
        nCountOfAg := 0
        cLocTemp := GetTempPath()
        cExcept := ""

        bErro := ErrorBlock( { |e| RU07T1405_Error(e, , @cExcept) } )
        cSplSymb := Iif("LINUX" $ Upper(GetSrvInfo()[2]), "/", "\")
        cPath := AllTrim(RU07T1306_MakeTmpDir())
        Begin Sequence
            (cRU07T1401MainAlias)->(DbSetOrder(1))
            (cRU07T1401MainAlias)->(DbGoTop())
            If (cRU07T1401MainAlias)->(DbSeek("2"))
                While !(cRU07T1401MainAlias)->(EOF()) .And. (cRU07T1401MainAlias)->LIST_NUMLI == "2" 
                    cTempF := ""
                    If (cRU07T1401MainAlias)->LIST_OKK == "1"
                        oXMLWriter := RUHRElnXMLAnswerWriter():New(@oJSONSampl, 1)
                        cTempN := CValToChar(Randomize(1, 50000)) + ".xml"
                        cTemp := cPath + cTempN
                        While File(cTemp)
                            cTempN := CValToChar(Randomize(1, 50000)) + ".xml"
                            cTemp := cPath + cTempN
                        EndDo
                        oXMLWriter:FillXml(RU07T1427_FillJsonData(oJSONSampl["struct"]))
                        If oXMLWriter:WriteFile(cTemp)
                            nCountOfAg += 1
                            CpyS2T(cTemp, cLocTemp)
                            cTemp2 := cLocPath + AllTrim((cRU07T1401MainAlias)->LIST_SASTN)
                            If File(cTemp2 + cTempF + ".xml")
                                cTempF := "000001"
                                While File(cTemp2 + "_" + cTempF + ".xml")
                                    cTempF := Soma1(cTempF)
                                EndDo
                                cTempF := "_" + cTempF
                            EndIf
                            Aadd(aListFile, cTemp2 + cTempF + ".xml")
                            FRename(cLocTemp + cTempN, aListFile[nCountOfAg], , .F.)
                            MsProcTxt(STR0058 + " " + CValToChar(nCountOfAg)) // "Files generated:"
                            FErase(cTemp)
                        EndIf
                        FreeObj(oJSONSampl)
                        oJSONSampl := Nil
                        oXMLWriter:Destroy()
                        FreeObj(oXMLWriter)
                        oXMLWriter := Nil
                    EndIf
                    (cRU07T1401MainAlias)->(DbSkip())
                EndDo
            EndIf
        End Sequence

        ErrorBlock(bErro)

        If Empty(cExcept) .And. nCountOfAg > 0
            AutoGrLog(STR0062 + " " + CValToChar(nCountOfAg)) // "files successfully created:"
            AutoGrLog(CRLF)
            AEval(aListFile, {|X| AutoGrLog(X)})
        Else
            AutoGrLog(cExcept)
            nCountOfAg := 1
        EndIf

        aDirInfo := Directory(cPath + "*", , , .F.)
        For nX := 1 To Len(aDirInfo)
            FErase(cPath + cSplSymb + aDirInfo[nX, 1])
            If SubStr(cPath, Len(cPath), 1) == cSplSymb
                cPath := SubStr(cPath, 1, Len(cPath) - 1)
            EndIf
            DirRemove(cPath)
        Next nX

        (cRU07T1401MainAlias)->(RestArea(aMArea))
        nLine1 := oBrw:oBrowse:oData:aShow[oBrw:oBrowse:aVisibleReg[1], oBrw:oBrowse:oData:nPosModelLine]
        nLine2 := oBrw2:oBrowse:oData:aShow[oBrw2:oBrowse:aVisibleReg[1], oBrw2:oBrowse:oData:nPosModelLine]
                // Rest line pos and scroll
        oGrid:GoLine(nLine1)
        oGrid2:GoLine(nLine2)

        oView:Refresh("RU07T14LIST")
        oView:Refresh("RU07T14ITEM")

        // Rest selected pos
        oBrw:oBrowse:nCursorPos := aCursorPos[1] 
        oBrw:oBrowse:SelectRow(aCursorPos[1])
        oBrw:oBrowse:Goto(nLineB, .F., .T.)
        oBrw2:oBrowse:nCursorPos := aCursorPos[1] 
        oBrw2:oBrowse:SelectRow(aCursorPos[1])
        oBrw2:oBrowse:Goto(nLineB, .F., .T.)
    Else
        nCountOfAg := -1
        MsgInfo(STR0060) // "The entered path does not exist"
    EndIf

Return nCountOfAg

/*/{Protheus.doc} RU07T1427_FillJsonData(oJson)

    This function Fill JSON-Object needable data.

    @type Function
    @param oJson, JSON, JSON-object which is filling
    @return oJson, JSON, JSON-object with data.
    @author dchihov
    @since 14.05.2024
    @version 12.1.23.10
    @example RU07T1427_FillJsonData(oXMLWriter:GetJsonSample())
*/
Function RU07T1427_FillJsonData(oJson)

    Local aTemp    As Array
    Local aArea    As Array
    Local aSRAArea As Array
    Local aSA6Area As Array
    Local cTemp    As Character
    Local oBFApp   As Object

    aArea := GetArea()
    aSRAArea := SRA->(GetArea())
    aSA6Area := SA6->(GetArea())
    DbSelectArea("SRA")
    SRA->(DbGoTo((cRU07T1401MainAlias)->LIST_SRANO))

    aTemp := FwBranAltInf({"BR_FSS", "BR_SUBORD"}, , SRA->RA_FILIAL)
    If Empty(AllTrim(aTemp[1, 2])) .Or. Empty(AllTrim(aTemp[2, 2]))
        aTemp := FwComAltInf({"CO_FSS", "CO_SUBORD"}, , SRA->RA_FILIAL)
    EndIf
    oBFApp := oJson["approveSocialAssist"]["node"]["benefit1Approve"]["node"]
    oJson["approveSocialAssist"]["node"]["socialAssistNum"]["value"] := EncodeUTF8(AllTrim((cRU07T1401MainAlias)->(LIST_SASTN)))
    oBFApp["elnInfo"]["node"]["code"]["value"] := EncodeUTF8(AllTrim((cRU07T1401MainAlias)->(LIST_CODE)))
    oBFApp["insurerInfo"]["node"]["regNum"]["value"] := EncodeUTF8(PadL(AllTrim(aTemp[1, 2]), 10, "0"))
    oBFApp["insurerInfo"]["node"]["parentNo"]["value"] := EncodeUTF8(AllTrim(aTemp[2, 2]))
    oBFApp["insuredInfo"]["node"]["snils"]["value"] := EncodeUTF8(AllTrim(SRA->RA_CIC))
    oBFApp["insuredInfo"]["node"]["inn"]["value"] := EncodeUTF8(AllTrim(SRA->RA_PIS))
    oBFApp["insuredInfo"]["node"]["fullName"]["node"]["firstName"]["value"] := EncodeUTF8(AllTrim(SRA->RA_PRINOME))
    oBFApp["insuredInfo"]["node"]["fullName"]["node"]["lastName"]["value"] := EncodeUTF8(AllTrim(SRA->RA_PRISOBR))
    oBFApp["insuredInfo"]["node"]["fullName"]["node"]["middleName"]["value"] := EncodeUTF8(AllTrim(SRA->RA_SECNOME))
    cTemp := DToS(SRA->RA_NASC)
    oBFApp["insuredInfo"]["node"]["birthDate"]["value"] := EncodeUTF8(SubStr(cTemp, 1, 4) + "-" + SubStr(cTemp, 5, 2) + "-" + SubStr(cTemp, 7))
    oBFApp["insuredInfo"]["node"]["gender"]["value"] := EncodeUTF8(A_SEXO_VALUE[Iif(SRA->RA_SEXO == "F", 2, 1)])
    oBFApp["insuredInfo"]["node"]["taxpayer"]["node"]["taxpayerStatus"]["value"] := EncodeUTF8("1")
    oBFApp["insuredInfo"]["node"]["taxpayer"]["node"]["countryCode"]["value"] := EncodeUTF8(AllTrim(SRA->RA_NACIONC))
    oBFApp["insuredInfo"]["node"]["taxpayer"]["node"]["address"]["node"]["houseGuid"]["value"] := ZERO_UID
    oBFApp["insuredInfo"]["node"]["taxpayer"]["node"]["address"]["node"]["guid"]["typeException"] := DELETE_NODE
    oBFApp["insuredInfo"]["node"]["taxpayer"]["node"]["address"]["node"]["house"]["typeException"] := DELETE_NODE
    oBFApp["insuredInfo"]["node"]["taxpayer"]["node"]["address"]["node"]["building"]["typeException"] := DELETE_NODE
    oBFApp["insuredInfo"]["node"]["taxpayer"]["node"]["address"]["node"]["flat"]["value"] := EncodeUTF8(Iif(Empty(AllTrim(SRA->RA_NUMENDE)), " ", AllTrim(SRA->RA_NUMENDE)))
    oBFApp["insuredInfo"]["node"]["taxpayer"]["node"]["postalCode"]["value"] := EncodeUTF8(Iif(Empty(AllTrim(SRA->RA_CEP)), " ", AllTrim(SRA->RA_CEP)))
    oBFApp["insuredInfo"]["node"]["id"]["node"]["type"]["value"] := EncodeUTF8(SRA->RA_FICHA)
    If AllTrim(SRA->RA_FICHA) == "21"
        oBFApp["insuredInfo"]["node"]["id"]["node"]["series"]["value"] := EncodeUTF8(SubStr(SRA->RA_NUMEPAS, 1, 4))
        oBFApp["insuredInfo"]["node"]["id"]["node"]["num"]["value"] := EncodeUTF8(SubStr(SRA->RA_NUMEPAS, 5, 6))
    Else
        oBFApp["insuredInfo"]["node"]["id"]["node"]["num"]["value"] := EncodeUTF8(AllTrim(SRA->RA_NUMEPAS))
    EndIf
    cTemp := DToS(SRA->RA_DEMIPAS)
    oBFApp["insuredInfo"]["node"]["id"]["node"]["issueDate"]["value"] := EncodeUTF8(Iif(!Empty(SRA->RA_DEMIPAS), SubStr(cTemp, 1, 4) + "-" + SubStr(cTemp, 5, 2) + "-" + SubStr(cTemp, 7), ""))
    oBFApp["insuredInfo"]["node"]["id"]["node"]["dept"]["value"] := EncodeUTF8(AllTrim(SRA->RA_EMISPAS))
    cTemp := DToS(SRA->RA_DVALPAS)
    oBFApp["insuredInfo"]["node"]["id"]["node"]["endDate"]["value"] := EncodeUTF8(Iif(!Empty(SRA->RA_DVALPAS), SubStr(cTemp, 1, 4) + "-" + SubStr(cTemp, 5, 2) + "-" + SubStr(cTemp, 7), ""))
    oBFApp["insuredInfo"]["node"]["workContract"]["typeException"] := NILABLE_NODE
    cTemp := AllTrim(SRA->RA_DDDFONE) + AllTrim(SRA->RA_TELEFON)
    If Empty(cTemp)
        cTemp := AllTrim(SRA->RA_DDDCELU) + AllTrim(SRA->RA_NUMCELU)
    EndIf
    oBFApp["insuredInfo"]["node"]["personPhone"]["value"] := EncodeUTF8(cTemp)
    If SRA->RA_TPCTSAL == "1"
        If !Empty(SRA->RA_BCDEPSA)
            oBFApp["receivePayment"]["node"]["bankInfo"]["node"]["bankName"]["value"] := EncodeUTF8(Posicione("SA6", RetOrdem("SA6", "A6_FILIAL+A6_COD+A6_AGENCIA"), xFilial("SA6") + SRA->RA_BCDEPSA, "A6_NOME"))
            oBFApp["receivePayment"]["node"]["bankInfo"]["node"]["bik"]["value"] := EncodeUTF8(SA6->A6_AGENCIA)
        EndIf
        oBFApp["receivePayment"]["node"]["bankInfo"]["node"]["accountNum"]["value"] := EncodeUTF8(SRA->RA_CTDEPSA)
        oBFApp["receivePayment"]["node"]["cardMir"]["typeException"] := DELETE_NODE
        oBFApp["receivePayment"]["node"]["otherOrg"]["typeException"] := DELETE_NODE
        oBFApp["receivePayment"]["node"]["currentFiasAddress"]["typeException"] := DELETE_NODE
        oBFApp["receivePayment"]["node"]["postalCode"]["typeException"] := DELETE_NODE
    Else
        oBFApp["receivePayment"]["node"]["currentFiasAddress"]["node"]["houseGuid"]["value"] := ZERO_UID
        oBFApp["receivePayment"]["node"]["currentFiasAddress"]["node"]["guid"]["typeException"] := DELETE_NODE
        oBFApp["receivePayment"]["node"]["currentFiasAddress"]["node"]["house"]["typeException"] := DELETE_NODE
        oBFApp["receivePayment"]["node"]["currentFiasAddress"]["node"]["building"]["typeException"] := DELETE_NODE
        oBFApp["receivePayment"]["node"]["currentFiasAddress"]["node"]["flat"]["typeException"] := NILABLE_NODE
        oBFApp["receivePayment"]["node"]["postalCode"]["value"] := EncodeUTF8(Iif(Empty(AllTrim(SRA->RA_CEP)), " ", AllTrim(SRA->RA_CEP)))
        oBFApp["receivePayment"]["node"]["bankInfo"]["typeException"] := DELETE_NODE
        oBFApp["receivePayment"]["node"]["cardMir"]["typeException"] := DELETE_NODE
        oBFApp["receivePayment"]["node"]["otherOrg"]["typeException"] := DELETE_NODE
    EndIf
    oBFApp["calculationData"]["node"]["baseCalcDays"]["value"] := EncodeUTF8(CValToChar((cRU07T1401MainAlias)->LIST_NBDAY))
    oBFApp["calculationData"]["node"]["years"]["node"]["year1"]["node"]["calc"]["value"] := EncodeUTF8((cRU07T1401MainAlias)->LIST_YEAR1)
    oBFApp["calculationData"]["node"]["years"]["node"]["year1"]["node"]["baseSum"]["value"] := EncodeUTF8(AllTrim((cRU07T1401MainAlias)->LIST_SUMM1))
    oBFApp["calculationData"]["node"]["years"]["node"]["year2"]["node"]["calc"]["value"] := EncodeUTF8((cRU07T1401MainAlias)->LIST_YEAR2)
    oBFApp["calculationData"]["node"]["years"]["node"]["year2"]["node"]["baseSum"]["value"] := EncodeUTF8(AllTrim((cRU07T1401MainAlias)->LIST_SUMM2))
    oBFApp["calculationData"]["node"]["kfReg"]["value"] := EncodeUTF8(CValToChar(Round(Val((cRU07T1401MainAlias)->LIST_KS206) * 100, 0)))
    oBFApp["calculationData"]["node"]["kfShortDays"]["value"] := EncodeUTF8(CValToChar(Round(Val((cRU07T1401MainAlias)->LIST_KNFWT) * 100, 0)))
    oBFApp["calculationData"]["node"]["experience"]["node"]["insurYY"]["value"] := EncodeUTF8(CValToChar((cRU07T1401MainAlias)->LIST_EYEAR))
    oBFApp["calculationData"]["node"]["experience"]["node"]["insurMM"]["value"] := EncodeUTF8(CValToChar((cRU07T1401MainAlias)->LIST_EMOUN))
    oBFApp["calculationData"]["node"]["experience"]["node"]["notInsurYY"]["typeException"] := NILABLE_NODE
    oBFApp["calculationData"]["node"]["experience"]["node"]["notInsurMM"]["typeException"] := NILABLE_NODE
    oBFApp["calculationData"]["node"]["calcConditionList"]["typeException"] := NILABLE_NODE
    oBFApp["calculationData"]["node"]["payPeriodFSS"]["node"]["begin"]["value"] := EncodeUTF8((cRU07T1401MainAlias)->LIST_PERB)
    oBFApp["calculationData"]["node"]["payPeriodFSS"]["node"]["end"]["value"] := EncodeUTF8((cRU07T1401MainAlias)->LIST_PERE)
    oBFApp["calculationData"]["node"]["excludePeriodList"]["typeException"] := NILABLE_NODE
    oBFApp["calculationData"]["node"]["downPeriodList"]["typeException"] := NILABLE_NODE
    oBFApp["insuranceCase"]["typeException"] := DELETE_NODE
    
    SRA->(RestArea(aSRAArea))
    SA6->(RestArea(aSA6Area))
    RestArea(aArea)

Return oJson
