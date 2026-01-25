#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "GPEWORD.CH"
#INCLUDE "RU07R06RUS.CH"


#DEFINE LAYOUT_ALIGN_LEFT     1
#DEFINE LAYOUT_ALIGN_RIGHT    2
#DEFINE LAYOUT_ALIGN_HCENTER  4
#DEFINE LAYOUT_ALIGN_TOP      32
#DEFINE LAYOUT_ALIGN_BOTTOM   64
#DEFINE LAYOUT_ALIGN_VCENTER  128

#DEFINE WINDOW_HEIGHT_SIZE 200
#DEFINE WINDOW_WIDTH_SIZE 300

#DEFINE BUTTON_HEIGHT_SIZE 15
#DEFINE BUTTON_WIDTH_SIZE 30

#DEFINE TEXTBOX_WIDTH_SIZE 180
#DEFINE TEXTBOX_HEIGHT_SIZE 10
#DEFINE TEXTBOX_MAX_LENGTH 90
#DEFINE SRA_STR_MAX_LENGHT 250

#DEFINE LABEL_WIDTH_SIZE 60
#DEFINE LABEL_HEIGHT_SIZE 15

#DEFINE DISMISSED_EMPLOYEE_STATUS "D"

#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"

#DEFINE MAX_LENGHT_NAME_FILE 255


/*/
{Protheus.doc} RuEmployeePrintForm
    Class employee data for generating a print form by MS WORD.

    @type Class
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
/*/
Class RuEmployeePrintForm From LongNameClass
    Data cNumberEmployee As Character // RA_MAT.
    Data cNameEmployee As Character // RA_NOMECMP.

    Data aDataList As Array // Date in the format {"yourDocVariable", "yourLoadingData"}

    Method New() Constructor

EndClass

/*/
{Protheus.doc} New(cProgramName, lIsUseSRAFilterRow, lIsUseSettingUser)
    Default RuHRWordPrintForm constructor.

    @type Method
    @params cNumEmployee, Array,     Array of parameters from pergunte.
            cNameEmployee,     Character, Expression for filter (from parameters).
            aData, Array, Date in the format {"yourDocVariable", "yourLoadingData"}
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return Self, Object, RuEmployeePrintForm instance.
    @example oRuEmployeePrintForm := RuEmployeePrintForm():New(SRA->RA_MAT, AllTrim(SRA->RA_NOMECMP), GetDataArray(cCodeSignature))
/*/
Method New(cNumEmployee, cNameEmployee, aData) Class RuEmployeePrintForm

    Self:cNumberEmployee := cNumEmployee
    Self:cNameEmployee := AllTrim(cNameEmployee)
    Self:aDataList := aData

Return Self




/*/
{Protheus.doc} RuHRWordPrintForm   NEEED TO REANME SOURCE CODE INTO "RUHRWORDPRINTFORM"
    Class for generating a print form by MS WORD.

    @type Class
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
/*/
Class RuHRWordPrintForm From LongNameClass

    // Properties.
    Data lIsUseSRAFilterRow As Logical // ".T." - show line on dialog (default).
    Data lIsUseSettingUser  As Logical // ".T." - load and save user parameters from dialog (default).
    Data cProgramName       As Character // Code of routin what use this class. Need for saving parameters.
    Data cIdUser            As Character // Number of entered user (from SIGACFG).
    Data cFormTitle         As Character // Title of FWDialogModal.
    Data cMarkChar          As Character // Symbol of markig for FwMarkBrowse.
    Data cPatternPath       As Character
    Data cResultPath        As Character
    Data cCodeSigner        As Character
    Data cNameSigner        As Character
    Data cCodeEmp        As Character
    Data cNameEmp        As Character
    Data cSRAlList          As Character
    Data cExtension         As Character
    Data lGroupReport       As Logical
    Data lIsNeedCheck       As Logical
    Data lExecMacro         As Logical

    // Constructors.
    Method New() Constructor

    // Methods private.
    Method GetUserSettings()
    Method SetUserSettings()
    Method MakeArrayUserParameters()
    Method IsAcceptButton()
    Method GetSRAList()
    Method MakeDialogTemporaryTableSRA()
    Method MarkAll()
    Method CreateWordPrintForm()
    Method GetFullNameOfSignature(cCode, cNameSignature)
    Method GetFullNameOfEmloyee(cCode, cNameEmloyee)
    Method UpdateParam(cPatternPath, cResultPath, cCodeSignature, cNameSignature, cSRAlList, lGroupReport)

    // Methods public (for using).
    Method SetDlgTitle()
    Method GetParamDialog()
    Method GetInputParameters()
    Method PrintReport()

EndClass


/*/
{Protheus.doc} New(cProgramName, lIsUseSRAFilterRow, lIsUseSettingUser)
    Default RuHRWordPrintForm constructor, 

    @type Constructor
    @params cProgramName,       Character, The code of the program from where the class is called
            lIsUseSRAFilterRow, Logical,   ".T." - show line on dialog (default) for SRA filter.
            lIsUseSettingUser,  Logical,   Load and save user parameters from dialog.
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return RU6NDFL, Object, RU6NDFL instance.
    @example oPrintForm := RuHRWordPrintForm():New("RU07R06RUS")
/*/
Method New(cProgramName, lIsUseSRAFilterRow, lIsUseSettingUser) Class RuHRWordPrintForm

    Default cProgramName := ""
    Default lIsUseSRAFilterRow := .T.
    Default lIsUseSettingUser := .T.

    Self:cProgramName := cProgramName
    Self:lIsUseSRAFilterRow := lIsUseSRAFilterRow
    Self:lIsUseSettingUser := lIsUseSettingUser

    Self:cIdUser := "U" + RetCodUsr() // "U" because it is user params.

    Self:cMarkChar := "1"

    Self:lIsNeedCheck := .T.
    Self:lExecMacro := .F.

Return Self


/*/
{Protheus.doc} New(cProgramName, lIsUseSRAFilterRow, lIsUseSettingUser)
    Default RuHRWordPrintForm constructor, 

    @type Method
    @params cTitle, Character, Title of FWDialogModal.
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return RU6NDFL, Object, RU6NDFL instance.
    @example oDialog:SetDlgTitle(STR0001) // Set title a window.
/*/
Method SetDlgTitle(cTitle) Class RuHRWordPrintForm
    Self:cFormTitle := cTitle
Return


/*/
{Protheus.doc}  GetUserSettings()
    Restore user settings.
    The data is stored in the SXK table

    @type Method
    @params 
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return aSettings, Array, Array with user settings for current program.
    @example aUserSettings := ::GetUserSettings()
/*/
Method GetUserSettings() Class RuHRWordPrintForm
    Local oStatement As Object
    Local cQuery     As Character
    Local aArea      As Array
    Local aSXKArea   As Array
    Local cAlias     As Character
    Local aSettings  As Array

    aSettings := {}
    aArea := GetArea()
    aSXKArea := SXK->(GetArea())

    cQuery := " SELECT XK_IDUSER, XK_GRUPO, XK_SEQ, XK_CONTEUD FROM " + RetSqlName("SXK")
    cQuery += " WHERE "
    cQuery += "    XK_IDUSER = ? "
    cQuery += "    AND XK_GRUPO = ? "
    cQuery += "    AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY XK_SEQ "

    oStatement := FWPreparedStatement():New()
    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, Self:cIdUser)
    oStatement:SetString(2, Self:cProgramName)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

    aSettings := Array(11)
    Afill(aSettings, {"", Space(TEXTBOX_MAX_LENGTH)})
    aSettings[5, 2] := aSettings[11, 2] := Space(SRA_STR_MAX_LENGHT)

    DbSelectArea(cAlias)
    DbGoTop()

    While !Eof()

        aSettings[Val((cAlias)->XK_SEQ)] := {(cAlias)->XK_SEQ, (cAlias)->XK_CONTEUD}

        DbSkip()
    EndDo
    
    DbCloseArea()

    // Destroy FWPreparedStatement object.
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aSXKArea)
    RestArea(aArea)

Return aSettings


/*/
{Protheus.doc} MakeArrayUserParameters(cPathTemplate, cPathResult, cCodeSign, cNameSign, cSraFilter, cGroupReport)
    Make numerated array with user settings from program.

    @type Method
    @params cPathTemplate, Character, Path to template print form.
            cPathResult, Character, Path to save result file.
            cCodeSign, Character, Code of signer (F3 = "SQ3").
            cNameSign, Character, Name of signer.
            cSraFilter, Character, List of selected SRA numbers.
            cGroupReport, Character, Is a group report or not.
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return aResult, Array, User settings from program.
    @example ::MakeArrayUserParameters(cPatternPath, cResultPath, cCodeSignature, cNameSignature, cSRAlList, cGroupReport)
/*/
Method MakeArrayUserParameters(cPathTemplate, cPathResult, cCodeSign, cNameSign, cSraFilter, cGroupReport) Class RuHRWordPrintForm
    Local aResult As Array

    aResult := {}

    If cGroupReport == ".T."
        aAdd(aResult, {"06", cGroupReport})
        aAdd(aResult, {"07", cPathTemplate})
        aAdd(aResult, {"08", cPathResult})
        aAdd(aResult, {"09", cCodeSign})
        aAdd(aResult, {"10", cNameSign})
        aAdd(aResult, {"11", cSraFilter})
    Else
        aAdd(aResult, {"01", cPathTemplate})
        aAdd(aResult, {"02", cPathResult})
        aAdd(aResult, {"03", cCodeSign})
        aAdd(aResult, {"04", cNameSign})
        aAdd(aResult, {"05", cSraFilter})
        aAdd(aResult, {"06", cGroupReport})
    EndIf

Return aResult


/*/
{Protheus.doc} SetUserSettings(cIdUser, aUserSettings)
    Save user settings into SXK table (like a perguntes).

    @type Method
    @params cIdUser, Character, Entered user number (from SIGACFG).
            aUserSettings, Array, Array of user settings from program.
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return lIsOk, Logical, Flag show that all process OK.
    @example Self:SetUserSettings(Self:cIdUser, Self:MakeArrayUserParameters(cPatternPath, cResultPath, cCodeSignature, cNameSignature, cSRAlList, Iif(lGroupReport, ".T.", ".F.")))
/*/
Method SetUserSettings(cIdUser, aUserSettings) Class RuHRWordPrintForm
    Local aArea     As Array
    Local aSXKArea  As Array
    Local nI As Numeric
    Local lIsOk As Logical

    aArea := GetArea()
    aSXKArea := SXK->(GetArea())
    lIsOk := .F.

    DbSelectArea("SXK")
    DbSetOrder(2) // XK_IDUSER + XK_GRUPO + XK_SEQ.
    DbGoTop()

    BeginTran() // Start a transaction.

    For nI := 1 To Len(aUserSettings)
        If DbSeek(Self:cIdUser + Self:cProgramName + aUserSettings[nI][1])
            If RecLock("SXK", .F.)
                SXK->XK_CONTEUD := aUserSettings[nI][2]
                SXK->(MsUnlock())

                lIsOk := .T.
            EndIf
        Else
            If RecLock("SXK", .T.)
                SXK->XK_IDUSER := Self:cIdUser
                SXK->XK_GRUPO := Self:cProgramName
                SXK->XK_SEQ := aUserSettings[nI][1]
                SXK->XK_CONTEUD := aUserSettings[nI][2]
                SXK->(MsUnlock())

                lIsOk := .T.
            EndIf
        EndIf
    Next nI

    // End transaction or rollback changes.
    If lIsOk
        EndTran()
    Else
        DisarmTransaction()
    EndIf

    MsUnlockAll() // Unlock all anyway.

    RestArea(aSXKArea)
    RestArea(aArea)

Return lIsOk


/*/
{Protheus.doc} IsAcceptButton(cTemplatePath, cDocSavePath)
    Checking that the fields are filled.

    @type Method
    @params cTemplatePath, Character, Path to document with template of print form.
            cDocSavePath, Character, Path to save document of result print form.
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return lResultValidation, Logical, Flag show that need parameters are filled.
    @example 
/*/
Method IsAcceptButton(cTemplatePath, cDocSavePath) Class RuHRWordPrintForm
    Local lResultValidation As Logical

    lResultValidation := .T. // Default value.

    If Empty(cTemplatePath) .Or. Empty(cDocSavePath)
        lResultValidation := .F.
        MsgStop(STR0009, STR0010)
    EndIf

    If !File(cTemplatePath)
        lResultValidation := .F.
        MsgStop(STR0002, STR0010)
    EndIf

Return lResultValidation


/*/
{Protheus.doc} MarkAll(oBrowsePut, cTempTbl, cMark)
    Mark all records into temporary table.

    @type Method
    @params oBrowsePut, Object, Object of class FWMarkBrowse.
            cTempTbl, Character, Alias of temporary table.
            cMark, Character, Symbol of marking.
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return .T.
    @example oMark:bAllMark := {|| MarkAll(oMark, cAlias, cMarkChar)}
/*/
Method MarkAll(oBrowsePut, cTempTbl, cMark) Class RuHRWordPrintForm
    Local nRecOri As Numeric
    Local cMarker As Character

    cMarker := "0"

    nRecOri	:= (cTempTbl)->(RecNo())

    DbSelectArea(cTempTbl)
    (cTempTbl)->(DbGoTop())

    Do While !(cTempTbl)->(Eof())
        If (cTempTbl)->RA_OK <> cMark
            cMarker := cMark
            Exit
        EndIf

        (cTempTbl)->(DbSkip())
    EndDo

    (cTempTbl)->(DbEval({|| (cTempTbl)->RA_OK := cMarker},{|| .T. }))

    oBrowsePut:GoTo(nRecOri, .T.)

Return .T.


/*/
{Protheus.doc} GetSRAList(cSraList)
    The function starts the process of creating a temporary table and 
    displaying information in the form of FWMarkBrowse for selecting employees
    into processing bar MsAguarde.

    @type Method
    @params cSraList, Character, Last list of selected employee numbers.
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return cNumbersList, Character, New list of selected employee numbers.
    @example cSRAlList := ::GetSRAList(cSRAlList)
/*/
Method GetSRAList(cSraList) Class RuHRWordPrintForm
    Local cNumbersList As Character
    Local aArea        As Array

    cNumbersList := ""
    aArea := GetArea()

    MsAguarde({|| cNumbersList := Self:MakeDialogTemporaryTableSRA(cSraList)}, STR0042, STR0043) // "Wait", "Formation of a data table".

    RestArea(aArea)

Return cNumbersList


/*/
{Protheus.doc} MakeDialogTemporaryTableSRA(cSRAlList)
    The function starts the process of creating a temporary table and 
    displaying information in the form of FWMarkBrowse for selecting employees
    into processing bar MsAguarde.

    @type Method
    @params cSraList, Character, Last list of selected employee numbers.
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return cNumbersList, Character, New list of selected employee numbers.
    @example MsAguarde({|| cNumbersList := MakeDialogTemporaryTableSRA(cSraList)}, STR0042, STR0043)
/*/
Method MakeDialogTemporaryTableSRA(cSRAlList) Class RuHRWordPrintForm
    Local cAlias As Character
    Local aFields As Array
    Local aColumns As Array
    Local oMark As Object
    Local oDlg As Object
    Local cNumbersList As Character
    Local oTempTable As Object
    Local cQuery As Character
    Local aSRAArea As Array
    Local aSraTempData As Array
    Local nSraCount As Numeric
    Local nI As Numeric
    Local aSelectedSra As Array
    Local nSqlStatus As Numeric
    Local oColumn As Object
    Local aSeekFields As Array
    Local aFilterFields As Array
    
    aCurArea := GetArea()
    aSRAArea := SRA->(GetArea())
    aSraTempData := {}
    aSelectedSra := {}
    cNumbersList := ""
    aSeekFields := {}
    aFilterFields := {}

    // Defenition fields of temporary table.
    aFields := {}
    aAdd(aFields, {"RA_OK"     , "C", 1                      , 00})
    aAdd(aFields, {"RA_MAT"    , "C", TamSX3("RA_MAT")[1]    , 00})
    aAdd(aFields, {"RA_NOMECMP", "C", TamSX3("RA_NOMECMP")[1], 00})
    aAdd(aFields, {"RA_ADMISSA", "D", TamSX3("RA_ADMISSA")[1], 00})
    aAdd(aFields, {"RA_CIC"    , "C", TamSX3("RA_CIC")[1]    , 00})

    // Defenition fields for search.
    /*  Fields array     Title                                 X3_TIPO                          X3_TAMANHO                  X3_DECIMAL          X3_CAMPO         X3_PICTURE             Index #   IsUse */
    aAdd(aSeekFields, {FWX3Titulo("RA_MAT")    , {{"", GetSx3Cache("RA_MAT"    , "X3_TIPO"), TamSX3("RA_MAT")[1]    , TamSX3("RA_MAT")[2]    , "RA_MAT"    , X3Picture("RA_MAT")     }},   1,     .T.   })
    aAdd(aSeekFields, {FWX3Titulo("RA_NOMECMP"), {{"", GetSx3Cache("RA_NOMECMP", "X3_TIPO"), TamSX3("RA_NOMECMP")[1], TamSX3("RA_NOMECMP")[2], "RA_NOMECMP", X3Picture("RA_NOMECMP") }},   2,     .T.   })
    aAdd(aSeekFields, {FWX3Titulo("RA_ADMISSA"), {{"", GetSx3Cache("RA_ADMISSA", "X3_TIPO"), TamSX3("RA_ADMISSA")[1], TamSX3("RA_ADMISSA")[2], "RA_ADMISSA", X3Picture("RA_ADMISSA") }},   3,     .T.   })
    aAdd(aSeekFields, {FWX3Titulo("RA_CIC")    , {{"", GetSx3Cache("RA_CIC"    , "X3_TIPO"), TamSX3("RA_CIC")[1]    , TamSX3("RA_CIC")[2]    , "RA_CIC"    , X3Picture("RA_CIC")     }},   4,     .T.   })

    // Defenition fields for filter.
    /*    Fields array     Field          Title                          Type                              X3_TAMANHO                 X3_DECIMAL             X3_PICTURE          */
    aAdd(aFilterFields, {"RA_MAT"    , FWX3Titulo("RA_MAT")    , GetSx3Cache("RA_MAT"    , "X3_TIPO"), TamSX3("RA_MAT")[1]    , TamSX3("RA_MAT")[2]    , X3Picture("RA_MAT")     })
    aAdd(aFilterFields, {"RA_NOMECMP", FWX3Titulo("RA_NOMECMP"), GetSx3Cache("RA_NOMECMP", "X3_TIPO"), TamSX3("RA_NOMECMP")[1], TamSX3("RA_NOMECMP")[2], X3Picture("RA_NOMECMP") })
    aAdd(aFilterFields, {"RA_ADMISSA", FWX3Titulo("RA_ADMISSA"), GetSx3Cache("RA_ADMISSA", "X3_TIPO"), TamSX3("RA_ADMISSA")[1], TamSX3("RA_ADMISSA")[2], X3Picture("RA_ADMISSA") })
    aAdd(aFilterFields, {"RA_CIC"    , FWX3Titulo("RA_CIC")    , GetSx3Cache("RA_CIC"    , "X3_TIPO"), TamSX3("RA_CIC")[1]    , TamSX3("RA_CIC")[2]    , X3Picture("RA_CIC")     })

    cAlias := CriaTrab(Nil, .F.) // Get new alias of your temporary table.
    oTempTable := FWTemporaryTable():New(cAlias) // Create temporary table.
    oTemptable:SetFields(aFields) // Set columns.

    // Create indexes.
    oTempTable:AddIndex(cAlias + "01", {"RA_MAT"    }) // Set index 01.
    oTempTable:AddIndex(cAlias + "02", {"RA_NOMECMP"}) // Set index 02.
    oTempTable:AddIndex(cAlias + "03", {"RA_ADMISSA"}) // Set index 03.
    oTempTable:AddIndex(cAlias + "04", {"RA_CIC"    }) // Set index 04.
    
    oTempTable:Create() // Create table.

    // Get employee number from SRA table and write it into array aSraTempData.
    DbSelectArea("SRA")
    SRA->(DbSetOrder(1)) // RA_FILIAL+RA_MAT+RA_NOME
    SRA->(DbGoTop())

    While !(SRA->(Eof()))
        aAdd(aSraTempData, {"0", SRA->RA_MAT, SRA->RA_NOMECMP, SRA->RA_ADMISSA, SRA->RA_CIC})

        SRA->(DBSkip())
    EndDo

    nSraCount := Len(aSraTempData)

    // Insert employee array into temporary table.
    For nI := 1 To nSraCount
        cQuery := "INSERT INTO " + oTempTable:GetRealName()
        cQuery += " ( "
        cQuery += "     RA_OK, "
        cQuery += "     RA_MAT, "
        cQuery += "     RA_NOMECMP, "
        cQuery += "     RA_ADMISSA, "
        cQuery += "     RA_CIC "
        cQuery += " ) "
        cQuery += " VALUES "
        cQuery += " ( " 
        cQuery += "   '" + aSraTempData[nI][1] + "' , " // RA_OK
        cQuery += "   '" + aSraTempData[nI][2] + "' , " // RA_MAT
        cQuery += "   '" + aSraTempData[nI][3] + "' , " // RA_NOMECMP
        cQuery += "   '" + DToS(aSraTempData[nI][4]) + "', " // RA_ADMISSA
        cQuery += "   '" + AllTrim(aSraTempData[nI][5]) + "' " // RA_CIC
        cQuery += " ) "

        nSqlStatus := TCSqlExec(cQuery)
        If nSqlStatus < 0
            MsgStop(STR0041, STR0010)
            Exit
        EndIf

    Next nI

    DbSelectArea(cAlias)
    (cAlias)->(DbGotop())
    
    // Create array with columns for browse.
    aColumns := {}
    
    For nI := 1 To Len(aFields)
        If (aFields[nI][1] == "RA_OK")
            Loop
        EndIf

        oColumn := FWBrwColumn():New() // Create a column object.
        oColumn:SetTitle(RetTitle(aFields[nI][1])) // Set title column.
        oColumn:SetData(&("{ || " + aFields[nI][1] + " }")) // Set data column.
        oColumn:SetID(aFields[nI]) // Set id of column.

        // Set size of columns.
        Do Case
            Case aFields[nI][1] == "RA_MAT"
                oColumn:SetSize(TamSX3("RA_MAT")[1])
                oColumn:SetAlign(CONTROL_ALIGN_CENTER)
            Case aFields[nI][1] == "RA_NOMECMP"
                oColumn:SetSize(TamSX3("RA_NOMECMP")[1])
            Case aFields[nI][1] == "RA_ADMISSA"
                oColumn:SetSize(TamSX3("RA_ADMISSA")[1])
            Case aFields[nI][1] == "RA_CIC"
                oColumn:SetSize(TamSX3("RA_CIC")[1])
            Otherwise
                oColumn:SetSize(20)
        EndCase

        // Set picture for RA_CIC column.
        If aFields[nI][1] == "RA_CIC"
            oColumn:SetPicture(X3Picture("RA_CIC"))
        EndIf

        aAdd(aColumns, oColumn) // Add column to array.
    Next nI

    

    If !Empty(cSRAlList)
        aSelectedSra := StrTokArr(cSRAlList, SEPARATOR_ARRAY_VALUES_SYMBOL)

        DbSelectArea(cAlias)
        (cAlias)->(DbGotop())
        While !((cAlias)->(Eof()))

            If aScan(aSelectedSra, (cAlias)->RA_MAT) > 0
                (cAlias)->RA_OK := Self:cMarkChar
            EndIf

            (cAlias)->(DbSkip())
        EndDo
    EndIf

    // Define dialog for browse.
    DEFINE MSDIALOG oDlg TITLE STR0040 FROM 00,00 TO 500, 800 OF oMainWnd PIXEL
    
    oMark := FWMarkBrowse():New()
    oMark:SetMark(Self:cMarkChar, cAlias, "RA_OK")
    oMark:SetFieldMark('RA_OK')
    oMark:SetDescription(STR0040)
    oMark:SetColumns(aColumns)
    oMark:SetAlias(cAlias)
    oMark:DisableReport()
    // oMark:DisableFilter()
    oMark:SetMenuDef('')
    oMark:SetIgnoreARotina(.T.)
    oMark:SetSeek(.T., aSeekFields)
	oMark:SetTemporary(.T.)
	oMark:SetLocate()
	oMark:SetUseFilter(.T.)
	// oMark:SetDbfFilter(.T.)
	oMark:SetFilterDefault("")
	oMark:SetFieldFilter(aFilterFields)
    oMark:DisableDetails()
    oMark:SetOwner(oDlg)
    oMark:bAllMark := {|| ::MarkAll(oMark, cAlias, Self:cMarkChar)}
    oMark:Refresh()
    oMark:Activate()

    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| (nOpcA:=1), (oDlg:End())}, {|| oDlg:End()}, , /*aButEnc*/)

    // Defenition selected employee.
    DbSelectArea(cAlias)
    (cAlias)->(DbGotop())
    While !((cAlias)->(Eof()))

        If ((cAlias)->RA_OK == Self:cMarkChar)
            cNumbersList += (cAlias)->RA_MAT + SEPARATOR_ARRAY_VALUES_SYMBOL
        EndIf

        If Len(cNumbersList) + Len((cAlias)->RA_MAT) > SRA_STR_MAX_LENGHT
            Exit
        EndIf

        (cAlias)->(DbSkip())
    EndDo

    // Delete temporary table.
    If oTempTable <> Nil
        oTempTable:Delete()
        oTempTable := Nil
    Endif

    RestArea(aSRAArea)
    RestArea(aCurArea)

Return cNumbersList


/*/
{Protheus.doc} GetFullNameOfSignature(cCode, cNameSignature)
    Forms the full name of the signatory person.
    Since the function is used in pergunt (SX1) in validation.

    @type Method
    @params cCod, Character, Employee personnel number.
            cNameSignature, Character, Result Full name of signer.
    @author vselyakov
    @since 06.12.2022
    @version 12.1.33
    @return lResult, Logical, Indicates that an employee is attached to the position.
    @example RU07R0602_GetFullNameOfSignature(cCodeSignature, @cNameSignature)
/*/
Method GetFullNameOfSignature(cCode, cNameSignature) Class RuHRWordPrintForm
    Local cFullName  As Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local lResult    As Logical

    cFullName := ""
    aArea := GetArea()

    If !Empty(cCode)
        oStatement := FWPreparedStatement():New(" SELECT RA_MAT, RA_NOME FROM " + RetSQLName("SRA") + " WHERE RA_FILIAL = ? AND RA_CARGO = ? AND D_E_L_E_T_=' ' ")
        oStatement:SetString(1, xFilial("SRA"))
        oStatement:SetString(2, cCode)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        cFullName := (cTab)->RA_NOME

        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    // Write result to pergunte.
    If !Empty(cFullName)
        lResult := .T.
        cNameSignature := cFullName
    ElseIf Self:lIsNeedCheck
        lResult := .F.
        // "Error", "No employee has been assigned to this position", "Indicate the position to which the employee is assigned".
        Help(,, STR0010,, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0024})
        cNameSignature := ""
    EndIf

    RestArea(aArea)

Return lResult

/*/
{Protheus.doc} GetFullNameOfEmloyee(cCode, cNameEmloyeeEmloyee)
    Forms the full name of the signatory person.
    Since the function is used in pergunt (SX1) in validation.

    @type Method
    @params cCod, Character, Employee personnel number.
            cNameEmloyee, Character, Result Full name of signer.
    @author iprokhorenko
    @since 06.12.2022
    @version 12.1.33
    @return lResult, Logical, Indicates that an employee is attached to the position.
    @example RU07R0602_GetFullNameOfEmloyee(cCodeEmloyee, @cNameEmloyee)
/*/
Method GetFullNameOfEmloyee(cCode, cNameEmloyee) Class RuHRWordPrintForm
    Local cFullName  As Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local lResult    As Logical

    cFullName := ""
    aArea := GetArea()

    If !Empty(cCode)
        oStatement := FWPreparedStatement():New(" SELECT RA_MAT, RA_NOME FROM " + RetSQLName("SRA") + " WHERE RA_FILIAL = ? AND RA_MAT = ? AND D_E_L_E_T_=' ' ")
        oStatement:SetString(1, xFilial("SRA"))
        oStatement:SetString(2, cCode)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        cFullName := (cTab)->RA_NOME

        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    // Write result to pergunte.
    If !Empty(cFullName)
        lResult := .T.
        cNameSignature := cFullName
    ElseIf Self:lIsNeedCheck
        lResult := .F.
        // "Error", "No employee has been assigned to this position", "Indicate the position to which the employee is assigned".
        Help(,, STR0010,, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0024})
        cNameSignature := ""
    EndIf

    RestArea(aArea)

Return lResult

Method GetParamDialog(cTyepesOfReport, lNeedGrPrinting, lNeedSignature) Class RuHRWordPrintForm
    Local lResultDialog As Logical
    Local oDialog As Object
    Local lOk As Logical
    Local oButtonTemplatePath As Object
    Local oButtonResultPath As Object
    Local cPatternPath As Character
    Local cResultPath As Character
    Local oTxtPathTemplate As Object
    Local oTxtPathResult As Object
    Local oTxtSignature As Object // Lable of select signature.
    Local oTxtEmloyee As Object 
    Local oGetTemplate As Object
    Local oGetPath As Object
    Local oGetSignature As Object // Textbox with selected signature.
    Local oGetFullNameSignature As Object 
    Local cCodeSignature As Character
    Local cNameSignature As Character
    Local cCodeEmloyee As Character
    Local cNameEmloyee As Character
    Local oTxtEmployeeSelection As Character
    Local oGetSRAList As Object
    Local cSRAlList As Character
    Local oButtonSRAList As Object
    Local aUserSettings := {} As Array
    Local oGridLayout
    Local oTxtSignName As Character
    Local lTextReadOnly := .T. As Logical
    Local nShiftY := 0 As Character
    Local oGroupReport As Object
    Local lGroupReport As Logical

    Default cTyepesOfReport := STR0050
    Default lNeedGrPrinting := .F.
    Default lNeedSignature := .T.

    lOk := .F.
    cPatternPath := Space(TEXTBOX_MAX_LENGTH)
    cResultPath := Space(TEXTBOX_MAX_LENGTH)
    cCodeSignature := Space(5)
    cNameSignature := Space(TEXTBOX_MAX_LENGTH)
    cCodeEmloyee := Space(6)
    cNameEmloyee := Space(TEXTBOX_MAX_LENGTH)
    // Loading user parameters.
    If Self:lIsUseSettingUser
        aUserSettings := Self:GetUserSettings(Self:cIdUser)

        lGroupReport := .F.
        If AllTrim(aUserSettings[6][2]) == ".T."
            lGroupReport := .T.
            nShiftY := 6
        EndIf
        
        cPatternPath := aUserSettings[1 + nShiftY][2]
        cResultPath := aUserSettings[2 + nShiftY][2]
        If IsInCallStack('RU07R10RUS')
            cCodeSignature := aUserSettings[3 + nShiftY][2]
            cNameSignature := aUserSettings[4 + nShiftY][2]
            // cCodeEmloyee := aUserSettings[3 + nShiftY][2]
            // cNameEmloyee := aUserSettings[4 + nShiftY][2]
        Else
            cCodeSignature := aUserSettings[3 + nShiftY][2]
            cNameSignature := aUserSettings[4 + nShiftY][2]
            cSRAlList := aUserSettings[5 + nShiftY][2]
        EndIf
        nShiftY := 0
    EndIf

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(Self:cFormTitle)
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| Self:IsAcceptButton(cPatternPath, cResultPath)})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    If lNeedGrPrinting

        Self:lExecMacro := .T.
        // Make line to type of report. (Base or group (a-type))
        oGroupReport := TCheckBox():New(10, 70, cTyepesOfReport, {|u| If(PCount() == 0, lGroupReport, lGroupReport := u)}, oGridLayout, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE,, {|| ::UpdateParam(oGetTemplate, oGetPath, oGetSignature, oGetFullNameSignature, oGetSRAList, lGroupReport)},, /*{|| MsgInfo("2", "2")}*/,,,,.T.,,, /*{|| MsgInfo("3", "3")}*/)

        nShiftY := 20

    EndIf

    // Make line to template file path.
    oTxtPathTemplate := TSay():New(10 + nShiftY, 5, {|| STR0002}, oGridLayout,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
    oTxtPathTemplate:lWordWrap := .F.

    oGetTemplate := TGet():New(10 + nShiftY, 70, {|u| If(PCount() == 0, cPatternPath, cPatternPath := u)}, oGridLayout, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,, "cPatternPath",,,,.F.)
    oButtonTemplatePath := TButton():New(10 + nShiftY, 260, "...", oGridLayout, {|| cPatternPath := Padr(cGetFile(STR0005 + "|*.dot|" + STR0006 +"|*.*", STR0002, 1, 'C:\', .T., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.), TEXTBOX_MAX_LENGTH, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)


    // Make line to result file path.
    oTxtPathResult := TSay():New(30 + nShiftY, 5, {|| STR0003}, oGridLayout,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
    oTxtPathResult:lWordWrap := .F.

    oGetPath := TGet():New(30 + nShiftY, 70, {|u| If( PCount() == 0, cResultPath, cResultPath := u)}, oGridLayout, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,, "cResultPath",,,,.F.)
    oButtonResultPath := TButton():New(30 + nShiftY, 260, "...", oGridLayout, {|| cResultPath := Padr(cGetFile(STR0004 + "|*.doc|" + STR0006 +"|*.*", STR0003, 1, 'C:\', .T., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.), TEXTBOX_MAX_LENGTH, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)

    // If IsInCallStack('RU07R10RUS')

    //     lNeedSignature := .F.
    //     oTxtSignature := TSay():New(50 + nShiftY, 5, {|| STR0055}, oGridLayout,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
    //     oTxtSignature:lWordWrap := .F.

    //     oGetSignature := TGet():New(50 + nShiftY, 70, {|u| If( PCount() == 0, cCodeEmloyee, cCodeEmloyee := u)}, oGridLayout, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F., {|| Iif(!Self:GetFullNameOfEmloyee(cCodeEmloyee, @cNameEmloyee), cNameEmloyee := "", Nil)},.F.,,, "cCodeEmloyee",,,, .T., .F.)
    //     oGetSignature:cF3 := "SRA"


    //     // Make line with full name Emloyee.
    //     // oTxtSignName := TSay():New(70 + nShiftY, 5, {|| STR0056}, oGridLayout,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
    //     // oTxtSignName:lWordWrap := .F.

    //     // oGetFullNameSignature := TGet():New(70 + nShiftY, 70, {|u| If( PCount() == 0, cNameEmloyee, cNameEmloyee := u)}, oGridLayout, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,, lTextReadOnly,,, "cNameEmloyee",,,, .T., .F.)
    // EndIf

    If lNeedSignature 
        // Make line with select signature.
        oTxtSignature := TSay():New(50 + nShiftY, 5, {|| STR0020}, oGridLayout,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        oTxtSignature:lWordWrap := .F.

        oGetSignature := TGet():New(50 + nShiftY, 70, {|u| If( PCount() == 0, cCodeSignature, cCodeSignature := u)}, oGridLayout, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F., {|| Iif(!Self:GetFullNameOfSignature(cCodeSignature, @cNameSignature), cNameSignature := "", Nil)},.F.,,, "cCodeSignature",,,, .T., .F.)
        oGetSignature:cF3 := "SQ3"


        // Make line with full name signature.
        oTxtSignName := TSay():New(70 + nShiftY, 5, {|| STR0022}, oGridLayout,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        oTxtSignName:lWordWrap := .F.

        oGetFullNameSignature := TGet():New(70 + nShiftY, 70, {|u| If( PCount() == 0, cNameSignature, cNameSignature := u)}, oGridLayout, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,, lTextReadOnly,,, "cNameSignature",,,, .T., .F.)
    Else//If //!IsInCallStack('RU07R10RUS')
        nShiftY -= 40
    EndIf


    // Selection employee list for print form.
    If Self:lIsUseSRAFilterRow .And. !IsInCallStack('RU07R10RUS')
        oTxtEmployeeSelection := TSay():New(90 + nShiftY, 5, {|| STR0039}, oGridLayout,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        oTxtEmployeeSelection:lWordWrap := .F.

        oGetSRAList := TGet():New(90 + nShiftY, 70, {|u| If( PCount() == 0, cSRAlList, cSRAlList := u)}, oGridLayout, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,, "cSRAlList",,,,.F.)
        oButtonSRAList := TButton():New(90 + nShiftY, 260, "...", oGridLayout, {|| cSRAlList := Padr(Self:GetSRAList(cSRAlList), SRA_STR_MAX_LENGHT, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    EndIf

    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        If Self:lIsUseSettingUser
            Self:SetUserSettings(Self:cIdUser, Self:MakeArrayUserParameters(cPatternPath, cResultPath, cCodeSignature, cNameSignature, cSRAlList, Iif(lGroupReport, ".T.", ".F."))) // Saving user settings.
        EndIf

        // RU07R0601_PrintReport(cPatternPath, cResultPath, cCodeSignature, cNameSignature, cSRAlList) // Print report.

        Self:cPatternPath := cPatternPath
        Self:cResultPath := cResultPath
        Self:cCodeSigner := cCodeSignature
        Self:cNameSigner := cNameSignature
        Self:cCodeEmp := cCodeEmloyee
        Self:cNameEmp := cCodeEmloyee
        Self:cSRAlList := cSRAlList
        Self:lGroupReport := lGroupReport

    EndIf

Return lResultDialog


/*/
{Protheus.doc} GetInputParameters()
    Return sorted array of parameters.

    @type Method
    @params 
    @author vselyakov
    @since 06.12.2022
    @version 12.1.33
    @return aInputParameters, Array, sorted array of parameters.
    @example aInputParams := oDialog:GetInputParameters()
/*/
Method GetInputParameters() Class RuHRWordPrintForm
    Local aInputParameters := {} As Array

    aAdd(aInputParameters, Self:cPatternPath)
    aAdd(aInputParameters, Self:cResultPath)
    If IsInCallStack('RU07R10RUS')
        aAdd(aInputParameters, Self:cCodeSigner)
        aAdd(aInputParameters, Self:cNameSigner)
    Else
        aAdd(aInputParameters, Self:cCodeSigner)
        aAdd(aInputParameters, Self:cNameSigner)
        aAdd(aInputParameters, StrTokArr(AllTrim(Self:cSRAlList), SEPARATOR_ARRAY_VALUES_SYMBOL))
        aAdd(aInputParameters, Self:lGroupReport)
     EndIf
    

Return aInputParameters


/*/
{Protheus.doc} CreateWordPrintForm(cTemplatePath, cDocSavePath)
    This method generate report in MS Word document based on .dot template.

    @type Method
    @params cTemplatePath, Character, Path to document template into .dot format.
            cDocSavePath,  Character, Path to save result document into .doc format.
            lNeedMacro,    Logical,   Need execute macro when printing
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return lResult, Logical, Indicates that the formation has occurred.
    @example lResult := Self:CreateWordPrintForm(cTemplatePath, cResultPath, aRuEmployeePrintForm[nI]:aDataList)
/*/
Method CreateWordPrintForm(cTemplatePath, cDocSavePath, aData, lNeedMacro) Class RuHRWordPrintForm
    Local oWord    As Object
    Local nI       As Numeric
    Local lResult  As Logical
    Local lYes     As Logical
    Local cPath    As Character
    Local cTempD   As Character
    Local cNewPath As Character
    Local cDrive   As Character
    Local cPaths   As Characetr
    Local cName    As Character
    Local cExt     As Character
    Local nIter    As Numeric
    Local lTempSrv As Logical

    Default aData := {}

    lResult := .T.
    lYes := .T.
    cPath:= cDocSavePath
    lTempSrv := .F.

    If Len(aData) > 0
        oWord := OLE_CreateLink() // Create object word.
        If !(":" $ cTemplatePath) .And. Len(Directory(cTemplatePath)) > 0 // file on server
            lTempSrv := .T.
            SplitPath(cDocSavePath, @cDrive, @cPaths)
            SplitPath(cTemplatePath, , , @cName, @cExt)
            If File(cDrive + cPaths + cName + AllTrim(cExt)) // There is already a file with the same name, so copy to temp and move by new name
                cTempD := GetTempPath(.T.)
                CpyS2T(cTemplatePath, cTempD)
                cNewPath := cDrive + cPaths + cName + AllTrim(cExt)
                nIter := 0
                While File(cNewPath) .And. nIter < 6000
                    cNewPath := cDrive + cPaths + cName + DTOS(Date()) + StrTran(Time(), ":", "") + CValToChar(Random(1, 9)) + AllTrim(cExt) // Get unico name
                    nIter += 1 // If more than a 6000 iterations have passed, then the user is too unlucky, but falling into a never-ending loop is worse
                    If nIter % 40
                        Sleep(500) // Every 20 iteration sleep 0.5 sec
                    EndIf
                EndDo
                FRename(cTempD + cName + AllTrim(cExt), cNewPath)
                cTempD := cNewPath
            Else
                cTempD := cDrive + cPaths
                CpyS2T(cTemplatePath, cTempD)
                cTempD := cDrive + cPaths + cName + AllTrim(cExt)
            EndIf
        Else
            cTempD := cTemplatePath
        EndIf
        OLE_NewFile(oWord, cTempD) // Open template document.

        // Insert data into template.
        For nI := 1 To Len(aData)
            OLE_SetDocumentVar(oWord, aData[nI][1], aData[nI][2])
        Next nI

        // Exec macros if grouping print
        If Self:lGroupReport .And. Self:lExecMacro .Or. lNeedMacro
            OLE_ExecuteMacro(oWord, "CreateTable")
        EndIf

        OLE_UpDateFields(oWord) // Update fileds.
        If File(cPath)
            lYes := MsgYesNo(STR0046 + " '" + cPath + "' " + STR0047)
            If !(lYes .Or. Empty(Self:cExtension))
                nI := 1
                lYes := .T.
                While File(cPath)
                    cPath := Substr(cDocSavePath, 1, Rat(Upper(Self:cExtension), Upper(cDocSavePath)) - 1) + "_" + StrZero(nI, 5) + Self:cExtension
                    nI += 1
                    If nI > 99999
                        lYes := .F.
                        Exit
                    EndIf
                EndDo
                If lYes
                    lYes := MsgYesNo(STR0048 + " '" + cPath + "' " + "?")
                EndIf
            EndIf
        EndIf
        If lYes
            OLE_SaveAsFile(oWord, cPath) // Save result document.
        EndIf
        OLE_CloseLink(oWord) // Close object.
        If lTempSrv .And. File(cTempD)
            FErase(cTempD)
        EndIf
    Else
        lResult := .F.
    EndIf

Return lResult


/*/
{Protheus.doc} PrintReport(aRuEmployeePrintForm, cPrefixNameForFile)
    The method generates printed forms based on an array of RuEmployeePrintForm objects.

    @type Method
    @params aRuEmployeePrintForm, Array, array of RuEmployeePrintForm objects.
    @params cPrefixNameForFile, Character, Prefix for a name of file.
    @params lNeedMacro, Logical, Execute macros when printing
    @params lPrefix,    Logical, Only prefix and name
    @author vselyakov
    @since 06.12.2022
    @version 12.1.23
    @return lResult, Logical, Indicates that the formation has occurred.
    @example MsAguarde({|| ;
                          aDataList := RU07R0601_GetAllData(aInputParams[1], aInputParams[2], aInputParams[3], aInputParams[4], aInputParams[5]), ;
                          lCreateReport := oDialog:PrintReport(aDataList)  ;
                       }, STR0014, STR0015) // "Please wait", "Formation of an admission order".
/*/
Method PrintReport(aRuEmployeePrintForm, cPrefixNameForFile, lNeedMacro, lPrefix) Class RuHRWordPrintForm
    Local lResult As Logical
    Local nI As Numeric
    Local cTemplatePath As Character
    Local cResultPath As Character
    Local cDir As Character
    Local cName As Character
    Local cFullName As Character

    DEFAULT cPrefixNameForFile := STR0045
    DEFAULT lPrefix := .F.

    lResult := .F.
    cTemplatePath := Self:cPatternPath

    For nI := 1 To Len(aRuEmployeePrintForm)

        // Modify result document path.
        SplitPath(AllTrim(Self:cResultPath), @cResultPath, @cDir, @cName, @Self:cExtension)
        cFullName := cName + Self:cExtension
        Self:cExtension := Iif(Empty(Self:cExtension), ".doc", Self:cExtension)
        cResultPath := Substr(AllTrim(Self:cResultPath), 1, Iif(Empty(cFullName), Len(Self:cResultPath), Rat(Upper(cFullName), Upper(AllTrim(Self:cResultPath)))) - 1)
        If Len(cResultPath) > MAX_LENGHT_NAME_FILE - Len(Self:cExtension)
            MsgStop(STR0054)
        Else
            If Self:lGroupReport
                cResultPath += cPrefixNameForFile + cValToChar(aRuEmployeePrintForm[nI]:aDataList[1, 2]) + " " + STR0053 + Iif(Empty(cName), "", "_") + cName
            ElseIf lPrefix
                cResultPath += cPrefixNameForFile + Iif(Empty(cName), "", "_") + cName
            Else
                cResultPath += cPrefixNameForFile + cName + "-" + aRuEmployeePrintForm[nI]:cNumberEmployee + "-" + aRuEmployeePrintForm[nI]:cNameEmployee
            EndIf

            If Len(cResultPath) > MAX_LENGHT_NAME_FILE - Len(Self:cExtension)
                cResultPath := SubStr(cResultPath, 1, MAX_LENGHT_NAME_FILE - Len(Self:cExtension))
            EndIf

            cResultPath += Self:cExtension

            // Create Word document.
            lResult := Self:CreateWordPrintForm(cTemplatePath, cResultPath, aRuEmployeePrintForm[nI]:aDataList, lNeedMacro)
        EndIf

        If !lResult
            Exit
        EndIf

    Next nI

Return lResult


/*/
{Protheus.doc} UpdateParam(@cPatternPath, @cResultPath, @cCodeSignature, @cNameSignature, @cSRAlList, lGroupReport)
    The method update params from base.

    @type Method
    @params cPatternPath,   Character, Path to template print form.
    @params cResultPath,    Character, Path to save result file.
    @params cCodeSignature, Character, Code of signer (F3 = "SQ3").
    @params cNameSignature, Character, Name of signer.
    @params cSRAlList,      Character, List of selected SRA numbers.
    @params lGroupReport,   Character, Is a group report or not.
    @author dchizhov
    @since 11.01.2023
    @version 12.1.23
    @return lResult, Logical, Indicates that the formation has occurred.
    @example ::UpdateParam(@cPatternPath, @cResultPath, @cCodeSignature, @cNameSignature, @cSRAlList, lGroupReport)
/*/
Method UpdateParam(oGetTemplate, oGetPath, oGetSignature, oGetFullNameSignature, oGetSRAList, lGroupReport) Class RuHRWordPrintForm

    Local aParam         As Array
    Local aSaveParam     As Array
    Local lResult := .T. As Logical
    Local nShift         As Numeric
    
    aParam := Self:GetUserSettings(Self:cIdUser)
    nShift := Iif(lGroupReport, 6, 0)

    Self:lIsNeedCheck := .F.

    aSaveParam := Self:MakeArrayUserParameters(oGetTemplate:cText, oGetPath:cText, oGetSignature:cText, ;
        oGetFullNameSignature:cText, oGetSRAList:cText, Iif(lGroupReport, ".F.", ".T."))

    ADel(aSaveParam, AScan(aSaveParam, {|X| X[1] == "06"}))
    ASize(aSaveParam, Len(aSaveParam) - 1)

    Self:SetUserSettings(Self:cIdUser, aSaveParam)

    oGetTemplate:cText := aParam[1 + nShift][2]
    oGetTemplate:CtrlRefresh()
    oGetPath:cText := aParam[2 + nShift][2]
    oGetPath:CtrlRefresh()
    oGetSignature:cText := aParam[3 + nShift][2]
    oGetSignature:CtrlRefresh()
    oGetFullNameSignature:cText := aParam[4 + nShift][2]
    oGetFullNameSignature:CtrlRefresh()
    oGetSRAList:cText := aParam[5 + nShift][2]
    oGetSRAList:CtrlRefresh()

    Self:lIsNeedCheck := .T.

Return lResult
