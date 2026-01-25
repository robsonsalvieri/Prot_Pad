#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R19RUS.CH"

#DEFINE WINDOW_HEIGHT_SIZE 250
#DEFINE WINDOW_WIDTH_SIZE 300

#DEFINE TEXTBOX_WIDTH_SIZE 180
#DEFINE TEXTBOX_HEIGHT_SIZE 10
#DEFINE TEXTBOX_MAX_LENGTH 250

#DEFINE LABEL_WIDTH_SIZE 60
#DEFINE LABEL_HEIGHT_SIZE 15

#DEFINE SRA_STR_MAX_LENGHT 250
#DEFINE COUNT_PARAMS_PARAM 9
#DEFINE NAME_OF_PROGRAM "RU07R19RUS"
#DEFINE NAME_OF_PROGRAM_PAR "RU07R19PAR"
#DEFINE INDEX_PARAM_SIGNER "2"

#DEFINE RV_TIPO_DAY "V"
#DEFINE RV_TIPO_HOUR "H"
#DEFINE RV_TIPO_INCOME "1"
#DEFINE RV_OVERWORKING "S"

/*/
{Protheus.doc} RU07R19()

    Main function of report by P-4 form.

    @type Function
    @params 
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return 
    @example RU07R19()
/*/
Function RU07R19()

    Local aParameter As Array

    aParameter := RU07R1902_GetParametr(NAME_OF_PROGRAM_PAR)

    If Len(aParameter) > 0
        aParameter[5] := Iif(AllTrim(aParameter[5]) == "", Replicate("Z", TamSX3("RA_FILIAL")[1]), aParameter[5])
        aParameter[7] := Iif(AllTrim(aParameter[7]) == "", Replicate("Z", TamSX3("RA_CC")[1]), aParameter[7])
        aParameter[9] := Iif(AllTrim(aParameter[9]) == "", Replicate("Z", TamSX3("RA_DEPTO")[1]), aParameter[9])
        MsAguarde({|| RU07R1905_PrintReport(aParameter)}, STR0087, STR0021) // "Please, wait", "Data collection"
    EndIf

Return .T.

/*/
{Protheus.doc} RU07R1902_GetParametr(cNamePar)

    Shows a window for parametr.

    @type Function
    @params cNamePar, Character, Name of programm parametr
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return aResultDialog, Array, Array of current parametr.
    @example aParameter := RU07R1902_GetParametr(NAME_OF_PROGRAM_PAR)
/*/
Function RU07R1902_GetParametr(cNamePar)

    Local aResultDialog       As Array
    Local oDialog             As Object
    Local aParamtrField       As Array
    Local aUserSettings := {} As Array
    Local cNChar              As Character
    Local oGridLayout         As Object
    Local oPanelBottom        As Object
    Local oScrollBox          As Object
    Local nI                  As Numeric
    Local cIdUser             As Character
    Local oHelp               As Object
    Local cHelp               As Character
    Local lSeeAll             As Logical

    Default cNamePar := NAME_OF_PROGRAM_PAR

    cIdUser := "U" + RetCodUsr()
    lSeeAll := VerSenha(114) .And. VerSenha(115)

    aParamtrField := {{Array(COUNT_PARAMS_PARAM), , }, {Array(COUNT_PARAMS_PARAM), , Array(COUNT_PARAMS_PARAM)}} // fields and Title for it. 

    aParamtrField[1, 2] := RU07R1904_GetStrParam(1)
    aParamtrField[2, 2] := RU07R1904_GetStrParam(2)
    aResultDialog := RU07R1904_GetStrParam(2)
    aParamtrField[1, 3] := RU07R1904_GetStrParam(3)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, cNamePar)

    For nI := 1 To COUNT_PARAMS_PARAM
        If !(ValType(aUserSettings[nI]) $ "A|U")
            aParamtrField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aParamtrField[2, 2, nI]))
            aResultDialog[nI] := aParamtrField[2, 2, nI]
        EndIf
    Next nI
    If !lSeeAll
        aResultDialog[4] := aResultDialog[5] := aParamtrField[2, 2, 4] := aParamtrField[2, 2, 5] := xFilial("SRA")
    EndIf

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(STR0001) // "Report P-4"
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU07R1903_IsAcceptButton(aParamtrField[2, 2])})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    For nI := 1 To COUNT_PARAMS_PARAM

        cNChar := CValToChar(nI)
        If cNChar $ INDEX_PARAM_SIGNER
            cValidate := "{|| Iif(!RU07R1305_GetFullNameOfSignature(aParamtrField[2, 2, " + CNChar + "], @aParamtrField[2, 2, " + CValToChar(nI + 1) + "]), &('aParamtrField[2, 2, " + CValToChar(nI + 1) + "] := Space(1), .F.'), .T.)}"
        ElseIf cNChar $ "1"
            cValidate := "{|| Iif(Len(AllTrim(aParamtrField[2, 2, " + CNChar + "])) < 6 .Or. Val(SubStr(aParamtrField[2, 2, " + CNChar + "], 5, 2)) > 12 .Or. Val(SubStr(aParamtrField[2, 2, " + CNChar + "], 5, 2)) < 1, (MsgInfo('" + STR0019 + "'), .F.), .T.)}" // "Set Period"
        EndIf
        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), oScrollBox, ;
        TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",Iif(cNChar $ "1", &(cValidate), Nil), 0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,Iif(cNChar $ INDEX_PARAM_SIGNER, &(cValidate), Nil), Iif(cNChar $ "45", !lSeeAll, cNChar $ "3"),,, "aParamtrField[2, 2, " + cNChar + "]",,,, .T., .F.)

        aParamtrField[2, 1, nI]:bHelp := &("{|| ShowHelpCpo('CustomField', {aParamtrField[1, 3, " + CNChar + "]}, 1, {aParamtrField[1, 3, " + CNChar + "]}, 1)}")
        aParamtrField[2, 1, nI]:bGotFocus:= &("{|o|  cHelp := aParamtrField[1, 3, " + CNChar + "], oHelp:Refresh()}")

    Next nI

    If lSeeAll
        aParamtrField[2, 1, 4]:cF3 := "XM0"
        aParamtrField[2, 1, 5]:cF3 := "XM0"
    EndIf
    aParamtrField[2, 1, Val(INDEX_PARAM_SIGNER)]:cF3 := "SQ3"
    aParamtrField[2, 1, 6]:cF3 := "CTT"
    aParamtrField[2, 1, 7]:cF3 := "CTT"
    aParamtrField[2, 1, 8]:cF3 := "SQB"
    aParamtrField[2, 1, 9]:cF3 := "SQB"

    @ 05,05 GET oHelp VAR cHelp OF oPanelBottom MULTILINE SIZE WINDOW_WIDTH_SIZE - 10, 035 PIXEL READONLY WHEN .T. NO VSCROLL
    oHelp:lCanGotFocus := .F.

    oDialog:bInit := {|| aParamtrField[2, 1, 1]:Setfocus(), oHelp:Refresh() }
    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        For nI := 1 To COUNT_PARAMS_PARAM
            aUserSettings[nI] := aParamtrField[2, 2, nI]
            aResultDialog[nI] := aParamtrField[2, 2, nI]
        Next nI

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_PARAM, cNamePar, aUserSettings)
    Else
        aResultDialog := {}
    EndIf

Return aResultDialog

/*/
{Protheus.doc} RU07R1903_IsAcceptButton(aParam)

    Check parameter.

    @type Function
    @params aParam, Array, Array of parameter wich entering the user.
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return lResult, Logical, Param valid or no valid.
    @example oDialog:SetValid({|| RU07R1903_IsAcceptButton(aParamtrField[2, 2])})
/*/
Function RU07R1903_IsAcceptButton(aParam)

    Local lResult As Logical
    Local cError  As Character
    Local cNotFil As Character

    lResult := .T.
    cError := ""
    cNotFil := ""
    cError := Iif(Len(AllTrim(aParam[1])) < 6 .Or. Val(SubStr(aParam[1], 5, 2)) > 12 .Or. Val(SubStr(aParam[1], 5, 2)) < 1, STR0019, "") // "Set Period"
    cNotFil := Iif(AllTrim(aParam[2]) == "" .Or. AllTrim(aParam[3]) == "", STR0003, "") // "Signatory"
    cError += Iif(AllTrim(cNotFil) <> "", STR0022 + CRLF + cNotFil, "") // "Parameters not filled:"
    If Len(cError) > 0
        lResult := .F.
        MsgStop(cError, STR0020) // "Error"
    EndIf

Return lResult

/*/
{Protheus.doc} RU07R1904_GetStrParam(nMode)

    Create Array by str constant for title, for empty val, for helps in filter-window.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for params; 2 - empty params; 3 - Array of help.
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU07R1904_GetStrParam(2)
/*/
Static Function RU07R1904_GetStrParam(nMode)

    Local aArray  As Array
    Local lSeeAll As Logical

    DEFAULT nMode := 1

    aArray := Array(COUNT_PARAMS_PARAM)

    If nMode == 1
        aArray[1] := STR0002 // "Reporting period"
        aArray[2] := STR0003 // "Signatory"
        aArray[3] := STR0004 // "Full name of the signatory"
        aArray[4] := STR0005 // "Branch from"
        aArray[5] := STR0006 // "Branch before"
        aArray[6] := STR0007 // "Cost center from"
        aArray[7] := STR0008 // "Cost center to"
        aArray[8] := STR0009 // "Division from"
        aArray[9] := STR0010 // "Division before"
    ElseIf nMode == 2
        lSeeAll := VerSenha(114) .And. VerSenha(115)
        aArray[1] := Space(6)
        aArray[2] := Space(TamSX3("RA_CARGO")[1])
        aArray[3] := Space(TEXTBOX_MAX_LENGTH)
        If lSeeAll
            aArray[4] := Space(TamSX3("RA_FILIAL")[1])
            aArray[5] := Replicate("Z", TamSX3("RA_FILIAL")[1])
        Else
            aArray[4] := aArray[5] := xFilial("SRA")
        EndIf
        aArray[6] := Space(TamSX3("RA_CC")[1])
        aArray[7] := Replicate("Z", TamSX3("RA_CC")[1])
        aArray[8] := Space(TamSX3("RA_DEPTO")[1])
        aArray[9] := Replicate("Z", TamSX3("RA_DEPTO")[1])
    ElseIf nMode == 3
        aArray[1] := STR0011 // "Enter the data generation period"
        aArray[2] := STR0012 // "Select the position of the signer from the directory"
        aArray[3] := ""
        aArray[4] := STR0013 // "Enter or select branch start code to filter data"
        aArray[5] := STR0014 // "Enter or select the final branch code to filter data"
        aArray[6] := STR0015 // "Enter or select cost center start code to filter data"
        aArray[7] := STR0016 // "Enter or select a final cost center code to filter data"
        aArray[8] := STR0017 // "Enter or select the starting department to filter data"
        aArray[9] := STR0018 // "Enter or select the final department to filter data"
    Else
        aArray := {}
    EndIf

Return aArray

/*/
{Protheus.doc} RU07R1905_PrintReport(aParameter)

    This function run getting data and print data into pdf.

    @type Static Function
    @params aParameter, Array, Array with parametr wich entering by user.
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return 
    @example MsAguarde({|| RU07R1905_PrintReport(aParameter)}, STR0087, STR0021) // "Please, wait", "Data collection"
/*/
Static Function RU07R1905_PrintReport(aParameter)

    Local oJson       As Object
    Local oJsonTemp   As Object
    Local oOptions    As Object
    Local cJson       As Character
    Local cOptions    As Character
    Local aDataForTit As Array
    Local aDataForTab As Array
    Local aFooter     As Array

    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.
    oJson := GetTemplatate()
    aDataForTit := RU07R1906_GetDataForTitle(aParameter, @aFooter)

    aDataForTab := RU07R1911_GetDataForTable(aParameter)
    MsProcTxt(STR0024) // "Building a PDF"
    oJsonTemp := RU07R1910_CreateCoverPage(aDataForTit)
    AEval(oJsonTemp["content"], {|X| Aadd(oJson["content"], X)})
    oJsonTemp := Nil
    oJsonTemp := CreateFirstPage(aDataForTab)
    AEval(oJsonTemp["content"], {|X| Aadd(oJson["content"], X)})
    oJsonTemp := CreateSecondPage(aDataForTab, aFooter)
    AEval(oJsonTemp["content"], {|X| Aadd(oJson["content"], X)})
    oJsonTemp := Nil
    MsProcTxt(STR0023) // "Sending to PDF Maker"

    cJson := oJson:ToJson()
    cOptions := oOptions:ToJson()

    ru99x50_pdfmakeForm(cJson, 'windows-1251', cOptions, 'RU07R19')
    FreeObj(oJson)
    FreeObj(oOptions)

Return .T.

/*/
{Protheus.doc} RU07R1906_GetDataForTitle(aParameter, aFooter)

    This function get data for title list.

    @type Static Function
    @params aParameter, Array, Array with parametr wich entering by user.
    @params aFooter,    Array, array for data for footer
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return aData, Array, Data for Title list
    @example aDataForTit := RU07R1906_GetDataForTitle(aParameter, aFooter)
/*/
Static Function RU07R1906_GetDataForTitle(aParameter, aFooter)

    Local aData As Array
    Local aGCBR As Array
    Local aGBBR As Array
    Local aRDBR As Array
    Local aArea As Array
    Local aSM0a As Array
    Local cFil1 As Character
    Local cFil2 As Character
    Local cStrF As Character
    Local cDept As Chaarcter
    Local nI    As Numeric
    // Local cTemp As Character
    Local nLenShare    As Numeric
    Local nLenCUnit    As Numeric
    Local nLenCCompany As Numeric

    aArea := GetArea()
    aSM0a := SM0->(GetArea())
    cFil1 := Space(TamSX3("RA_FILIAL")[1])
    cFil2 := Replicate("Z", TamSX3("RA_FILIAL")[1])
    nLenShare := 0
    nLenCUnit := 0
    nLenCCompany := 0
    aFooter := {StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, aParameter[2])}
    //RU70R0104_GetFullNameOfSignature(aParameter[2], @cTemp)
    //aAdd(aFooter, cTemp)
    aAdd(aFooter, aParameter[3])

    cDept := ""
    aGBBR := {{"BR_FULLNAM", ""}, {"BR_SHORTNM", ""}, {"BR_OKPO", ""}}
    DbSelectArea("SM0")
    SM0->(DbGoTop())
    While !(SM0->(EOF()))
        If cFil1 < SM0->M0_CODFIL
            cFil1 := SM0->M0_CODFIL
        EndIf
        If cFil2 > SM0->M0_CODFIL
            cFil2 := SM0->M0_CODFIL
        EndIf
        SM0->(DbSkip())
    EndDo
    SM0->(DbGoTop())
    While !(SM0->(EOF()))
        If cFil1 > SM0->M0_CODFIL .And. SM0->M0_CODFIL >= aParameter[4]
            cFil1 := SM0->M0_CODFIL
        EndIf
        If cFil2 < SM0->M0_CODFIL .And. SM0->M0_CODFIL <= aParameter[5]
            cFil2 := SM0->M0_CODFIL
        EndIf
        SM0->(DbSkip())
    EndDo
    cFil1 := PadR(cFil1, TamSX3("RA_FILIAL")[1], " ")
    cFil2 := PadR(cFil2, TamSX3("RA_FILIAL")[1], " ")
    If cFil1 <> cFil2
        cStrF := RU07R1907_GetStructCodeF(cEmpAnt) 
        For nI := 1 To Len(cStrF)
            Do Case 
                Case SubStr(cStrF, nI, 1) == "E"
                    nLenCCompany += 1
                Case SubStr(cStrF, nI, 1) == "U"
                    nLenCUnit += 1
            EndCase
        Next nI
        nLenShare := 0
        For nI := 1 To Len(cFil1)
            If SubStr(cFil1, nI, 1) == SubStr(cFil2, nI, 1)
                nLenShare += 1
            Else
                Exit
            EndIf
        Next nI
        cCodeCompany := SubStr(cFil1, 1, Min(nLenCCompany, nLenShare))
        cCodeUnit := SubStr(cFil1, 1 + nLenCCompany, Min(nLenCUnit, nLenShare - Min(nLenCCompany, nLenShare)))
        aGCBR := RU07R1908_GetHCompanyInfo({{"CO_FULLNAM", "CO_FULLNAM"}, {"CO_SHORTNM", "CO_SHORTNM"}, {"CO_OKPO", "CO_OKPO"}, ;
        {"CO_PHONENU", "CO_PHONENU"}, {"CO_EMAIL", "CO_EMAIL"}}, cEmpAnt, cCodeCompany, cCodeUnit)
    Else
        aGCBR := FwComAltInf({"CO_FULLNAM", "CO_SHORTNM", "CO_OKPO", "CO_PHONENU", "CO_EMAIL", "CO_COMPGRP", "CO_COMPEMP", "CO_COMPUNI", "CO_TIPO"}, cEmpAnt, cFil1)
        aGBBR := FwBranAltInf({"BR_FULLNAM", "BR_SHORTNM", "BR_OKPO", "BR_PHONENU", "BR_EMAIL", "BR_COMPGRP", "BR_COMPEMP", "BR_COMPUNI", "BR_BRANCH"}, cEmpAnt, cFil1)
    EndIf

    If Len(AllTrim(aGBBR[1, 2])) > 0
        aRDBR := aGBBR
    Else
        aRDBR := aGCBR
    EndIf
    aData := {aRDBR[1, 2], aRDBR[2, 2], aRDBR[3, 2]}
    aAdd(aFooter, AllTrim(aRDBR[4, 2]))
    aAdd(aFooter, AllTrim(aRDBR[5, 2]))
    aAdd(aData, RU07R1909_GetAddress(aRDBR[6, 2], aRDBR[7, 2], aRDBR[8, 2], aRDBR[9, 2], .T., "2")[1])
    If Alltrim(aData[4]) == ""
        aData[4] := RU07R1909_GetAddress(aRDBR[6, 2], aRDBR[7, 2], aRDBR[8, 2], aRDBR[9, 2], .T., "0")[1]
        aFooter[3] := AllTrim(aRDBR[4, 2])
        aFooter[4] := AllTrim(aRDBR[5, 2])
    EndIf
    aAdd(aData, SubStr(aParameter[1], 5, 2))
    aAdd(aData, SubStr(aParameter[1], 1, 4))
    
    SM0->(RestArea(aSM0a))
    RestArea(aArea)

Return aData

/*/
{Protheus.doc} RU07R1907_GetStructCodeF(cEmpAnalyze)

    This function get struct code for group of company.

    @type Function
    @params cEmpAnalyze, Character, Group of company.
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return cStructCodeF, Character, Struct code filial for Group of company
    @example cStrF := RU07R1907_GetStructCodeF(cEmpAnt) 
/*/
Function RU07R1907_GetStructCodeF(cEmpAnalyze)

    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local cStructCodeF As Character

    aArea := GetArea()
    cStructCodeF := ""

    cQuery := "SELECT M0_LEIAUTE AS STRUCTURE FROM SYS_COMPANY WHERE"
    cQuery += " M0_CODIGO = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cEmpAnalyze)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    cStructCodeF := Alltrim((cTab)->STRUCTURE)

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return cStructCodeF

/*/
{Protheus.doc} RU07R1908_GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)
    The function receives data about selected company. If no data about selected company - get data abaout hight structure/
    Get data from SYS_COMPANY and SYS_COMPANY_L_RUS (SIGACFG).

    @type Function
    @params aCampo,       Array,     Array fields in CO which mast received ({{Field_From_DB, Alias_Field}...})
    @params cGroupCode,   Character, Code group of company.
    @params cCodeCompany, Character, Code company.
    @params cCodeUnit,    Character, Cod bussines unit.
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return aResult, Array, Received Information.
    @example aGCBR := RU07R1908_GetHCompanyInfo({{"CO_FULLNAM", "CO_FULLNAM"}, {"CO_SHORTNM", "CO_SHORTNM"}, {"CO_OKPO", "CO_OKPO"}}, ;
/*/
Function RU07R1908_GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)

    Local oStatement     As Object
    Local cQuery         As Character 
    Local aArea          As Array
    Local cTab           As Character
    Local aResult := { } As Logical
    Local nI             As Numeric

    DEFAULT cGroupCode := cEmpAnt

    If !Empty(aCampo)

        aArea := GetArea()

        cQuery := " SELECT "
        For nI := 1 To Len(aCampo)
            cQuery += aCampo[nI, 1] + ", "
        Next nI
        cQuery += " CO_COMPGRP, CO_COMPEMP, CO_COMPUNI, CO_TIPO"
        cQuery += " FROM SYS_COMPANY_L_RUS WHERE "
        cQuery += " CO_COMPGRP = ? "
        cQuery += " AND CO_COMPEMP = ? "
        cQuery += " AND CO_COMPUNI = ? "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, cGroupCode)
        oStatement:SetString(2, cCodeCompany)
        oStatement:SetString(3, cCodeUnit)

        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        If !((cTab)->(EOF()))
            For nI := 1 To Len(aCampo)
                AAdd(aResult, {aCampo[nI, 2], Alltrim((cTab)->(&(aCampo[nI, 2])))})
            Next nI
            AAdd(aResult, {"CO_COMPGRP", (cTab)->CO_COMPGRP})
            AAdd(aResult, {"CO_COMPEMP", (cTab)->CO_COMPEMP})
            AAdd(aResult, {"CO_COMPUNI", (cTab)->CO_COMPUNI})
            AAdd(aResult, {"CO_TIPO", (cTab)->CO_TIPO})
        EndIf

        (cTab)->(DBCloseArea())
        oStatement:Destroy()
        FwFreeObj(oStatement)

        RestArea(aArea)

        If Empty(aResult) .And. !(Empty(cCodeCompany) .And. Empty(cCodeUnit))
            If !Empty(cCodeUnit)
                aResult := GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, "")
            Else
                aResult := GetHCompanyInfo(aCampo, cGroupCode, "", "")
            EndIf
        EndIf
    EndIf

Return aResult

/*/
{Protheus.doc} RU07R1909_GetAddress(aCampo, cGroupCode, cCodeCompany, cCodeUnit)
    This function get information from aga by address.

    @type Function
    @params cGrpAdr,  Character, Code of group company.
    @params cEmpAdr,  Character, Code of company.
    @params cUniAdr,  Character, Code company.
    @params cBranAdr, Character, Code of branch (tipo if not branch).
    @params lBr,      Logical,   Is it Branch or not.
    @params cType,    Character, type of address (0 - legal, 1 - factical, 2 - postal).
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return aResult, Array, Array with data from aga.
    @example aAdd(aData, RU07R1909_GetAddress(aGBBR[4, 2], aGBBR[5, 2], aGBBR[6, 2], aGBBR[7, 2], .T., "2")[1])
/*/
Function RU07R1909_GetAddress(cGrpAdr, cEmpAdr, cUniAdr, cBranAdr, lBr, cType)

    Local cQuery     As Character
    Local oStatement As Object
    Local cTab       As Character
    Local aResult    As Character
    Local nRecNo     As Numeric

    nRecNo := -1
    cKeyForAddres := ""
    If lBr .Or. cBranAdr $ "12"
        cKeyForAddres := cEmpAdr
        If cBranAdr == "2" .Or. lBr
            cKeyForAddres += cUniAdr
        EndIf
    EndIf
    cKeyForAddres := xFilial("SM0") + cGrpAdr + cKeyForAddres + cBranAdr

    cQuery := " SELECT "
    cQuery += " R_E_C_N_O_"
    cQuery += " FROM " + RetSqlName("AGA") + " AGA WHERE "
    cQuery += " AGA_ENTIDA = 'SM0' "
    cQuery += " AND AGA_CODENT = ? "
    cQuery += " AND AGA_TIPO = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY AGA_FROM DESC "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cKeyForAddres)
    oStatement:SetString(2, cType)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    If !((cTab)->(EOF()))
        nRecNo := (cTab)->R_E_C_N_O_
    EndIf

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    If nRecNo > 0
        aResult := RU07R1981_GetColumnFromTableByNrec("AGA", {"AGA_FULL"}, nRecNo)
    Else
        aResult := {" "}
    EndIf

Return aResult

/*/
{Protheus.doc} RU07R1910_CreateCoverPage(aData)
    This function create Json with Cover Page.

    @type Static Function
    @params aData, Array, Array with data for Json
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return oJson, Object, Json for pdf-maker.
    @example oJson := RU07R1910_CreateCoverPage(aDataForTit)
/*/
Static Function RU07R1910_CreateCoverPage(aData)

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content":[
            {
                "margin": [0, 0, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [10, 10, "*", 10, 10, 10],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": "", "colSpan": 2}, {}, {"bold": true}, {"border": [false, false, false, false], "text": "", "colSpan": 3}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "text": " ", "colSpan": 6, "fontSize": 3}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "colSpan": 2}, {}, {}, {"border": [false, false, false, false], "text": "", "colSpan": 3}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "text": " ", "colSpan": 6, "fontSize": 3}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"colSpan": 4}, {}, {}, {}, {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [60, 2, 80, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [210, 15, 70, 15, 15, "*"],
                    "body": [ 
                        [
                            {"border": [true, true, true, false], "colSpan": 6}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, false, false, false], "text": ""}, {"border": [false, false, false, false]}, {"border": [false, false, false, true], "text": ""},
                            {"border": [false, false, false, false]}, {"border": [false, false, false, true], "text": ""}, {"border": [false, false, true, false], "text": "", "alignment": "left"}
                        ],
                        [
                            {"border": [true, false, false, true], "colSpan": 2, "text": ""}, {}, {"border": [false, false, false, true]}, {"border": [false, false, true, true], "text": "", "colSpan": 3}, {}, {}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 3, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": ["*", 160, 15, 180],
                    "body": [ 
                        [
                            {}, {}, {"border": [false, false, false, false], "rowSpan": 6, "text": ""}, {"bold": true}
                        ],
                        [
                            {"border": [true, true, true, false], "alignment": "left", "rowSpan": 3, "fotnSize": 9}, 
                            {"border": [true, true, true, false], "rowSpan": 3, "fotnSize": 9}, {}, {"border": [false, true, false, false], "text": ""}
                        ],
                        [
                            {}, {}, {}, {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, false, true, false], "alignment": "left", "fotnSize": 9}, {"border": [true, false, true, false], "fotnSize": 9}, {},
                            {"border": [false, true, false, false], "rowSpan": 2, "text": ""}
                        ],
                        [
                            {"border": [true, false, true, true], "alignment": "left", "fotnSize": 9}, {"border": [true, false, true, true], "text": ""}, {}, {}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 5, 0, 0],
                "style": "normal",
                "table": {
                    "widths": [240, "*", 30],
                    "body": [ 
                        [
                            {"border": [false, true, false, false], "bold": true}, {"border": [false, true, false, true]}, {"border": [false, true, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 1, 0, 0],
                "style": "normal",
                "table": {
                    "widths": [100, "*", 30],
                    "body": [ 
                        [
                            {"border": [false, true, false, false], "bold": true}, {"border": [false, true, false, true]}, {"border": [false, true, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 2, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [130, "*", 170, 170],
                    "body": [ 
                        [
                            {"rowSpan": 2}, {"colSpan": 3}, {}, {}
                        ],
                        [
                            {}, {}, {}, {}
                        ],
                        [
                            {"text": "1"}, {"text": "2"}, {"text": "3"}, {"text": "4"}
                        ],
                        [
                            {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)

    oJson["content"][1]["table"]["body"][1, 3]["text"] := STR0025
    oJson["content"][1]["table"]["body"][3, 3]["text"] := STR0026
    oJson["content"][1]["table"]["body"][5, 2]["text"] := STR0027

    oJson["content"][2]["table"]["body"][1, 1]["text"] := STR0028
    oJson["content"][2]["table"]["body"][2, 2]["text"] := STR0029
    oJson["content"][2]["table"]["body"][2, 3]["text"] := Lower(RU07R1980_GetMonthName(Val(aData[5])))
    oJson["content"][2]["table"]["body"][2, 4]["text"] := STR0030
    oJson["content"][2]["table"]["body"][2, 5]["text"] := SubStr(aData[6], 3, 2)
    oJson["content"][2]["table"]["body"][2, 6]["text"] := STR0031
    oJson["content"][2]["table"]["body"][3, 3]["text"] := STR0032

    oJson["content"][3]["table"]["body"][1, 1]["text"] := STR0033
    oJson["content"][3]["table"]["body"][1, 2]["text"] := STR0034
    oJson["content"][3]["table"]["body"][1, 4]["text"] := STR0035
    oJson["content"][3]["table"]["body"][2, 1]["text"] := STR0036 + CRLF + STR0037 + CRLF + STR0038
    oJson["content"][3]["table"]["body"][2, 2]["text"] := STR0039
    oJson["content"][3]["table"]["body"][3, 4]["text"] := CRLF + STR0040 + CRLF + STR0041 + CRLF + STR0042 + CRLF + STR0043 + CRLF + STR0044 + CRLF + STR0045 + CRLF + STR0046 + CRLF + CRLF + CRLF
    oJson["content"][3]["table"]["body"][4, 4]["text"] := STR0047
    oJson["content"][3]["table"]["body"][5, 1]["text"] := STR0048
    oJson["content"][3]["table"]["body"][5, 2]["text"] := STR0049 + CRLF + STR0050
    oJson["content"][3]["table"]["body"][6, 1]["text"] := STR0051

    oJson["content"][4]["table"]["body"][1, 1]["text"] := STR0052
    oJson["content"][4]["table"]["body"][1, 2]["text"] := AllTrim(aData[1]) + " (" + AllTrim(aData[2]) + ")"
    oJson["content"][5]["table"]["body"][1, 1]["text"] := STR0053
    oJson["content"][5]["table"]["body"][1, 2]["text"] := aData[4]
    
    oJson["content"][6]["table"]["body"][1, 1]["text"] := STR0054 + CRLF + STR0055 + CRLF + STR0056
    oJson["content"][6]["table"]["body"][1, 2]["text"] := STR0057
    oJson["content"][6]["table"]["body"][2, 2]["text"] := STR0058
    oJson["content"][6]["table"]["body"][4, 1]["text"] := STR0059
    oJson["content"][6]["table"]["body"][4, 2]["text"] := aData[3]

Return oJson

/*/
{Protheus.doc} RU07R1911_GetDataForTable(aParameter)
    This function get data for table part.

    @type Static Function
    @params aParameter, Array, Parametr, which user entering.
    @author dchizhov
    @since 30.08.2023
    @version 12.1.2210
    @return aData, Array, Data for table part.
    @example aDataForTab := RU07R1911_GetDataForTable(aParameter)
/*/
Static Function RU07R1911_GetDataForTable(aParameter)

    Local aData As Array
    Local aTemp As Array
    Local aIter As Array
    Local nI    As Numeric

    aData := {}
    aTemp := RU07R1912_GetListFilterForDataForTable(aParameter)

    For nI := 1 To Len(aTemp)
        aIter := {aTemp[nI]}
        aAdd(aIter, 0)
        aAdd(aIter, Round(RU07R1913_GetAverCountByFilial(aTemp[nI], aParameter[1], "MH"), 2))
        aAdd(aIter, 0)
        aAdd(aIter, Round(RU07R1913_GetAverCountByFilial(aTemp[nI], aParameter[1], "A"), 2))
        aIter[2] := aIter[3] + aIter[4] + aIter[5]
        aAdd(aIter, aTemp[nI, aTemp[nI, 4] + 1])
        aAdd(aIter, 0)
        aAdd(aIter, 0)
        aAdd(aIter, Round(aTemp[nI, aTemp[nI, 4] + 2] / 1000, 1))
        aAdd(aIter, 0)
        aAdd(aIter, Round(aTemp[nI, aTemp[nI, 4] + 3] / 1000, 1))
        aAdd(aIter, 0)
        aIter[8] := aIter[9] + aIter[10] + aIter[11]
        aAdd(aData, aIter)
    Next nI

Return aData

/*/
{Protheus.doc} RU07R1912_GetListFilterForDataForTable(aParameter)
    This function get list of filtering data for table.

    @type Static Function
    @params aParameter, Array, Parametr, which user entering.
    @author dchizhov
    @since 30.08.2023
    @version 12.1.2210
    @return aListFilter, Array, List of filter for table part.
    @example aTemp := RU07R1912_GetListFilterForDataForTable(aParameter)
/*/
Static Function RU07R1912_GetListFilterForDataForTable(aParameter)

    Local aListFilter As Array
    Local aFilter     As Array
    Local aSM0Area    As Array
    Local aSRAArea    As Array
    Local nIndex      As Numeric
    Local cOkved      As Character
    Local nI          As Numeric
    Local nLenFil     As Numeric

    aListFilter := {}
    nLenFil := TamSX3("RA_FILIAL")[1]
    aSM0Area := SM0->(GetArea())
    aSRAArea := SRA->(GetArea())
    DbSelectArea("SM0")
    SM0->(DbGoTop())
    While !(SM0->(EOF()))
        If SM0->M0_CODFIL <= aParameter[5] .And. SM0->M0_CODFIL >= aParameter[4]
            cOkved := FwBranAltInf({"BR_OKVED"}, cEmpAnt, SM0->M0_CODFIL)[1, 2]
            nIndex := AScan(aListFilter, {|X| AllTrim(X[1]) == AllTrim(cOkved)})
            If nIndex < 1
                aFilter := {cOkved, {PadR(SM0->M0_CODFIL, nLenFil, " ")}, "|" + PadR(SM0->M0_CODFIL, nLenFil, " ")  + "|", 0}
                For nI := 6 To Len(aParameter)
                    aAdd(aFilter, aParameter[nI])
                Next nI
                aAdd(aListFilter, aFilter)
            Else
                aAdd(aListFilter[nIndex, 2], PadR(SM0->M0_CODFIL, nLenFil, " "))
                aListFilter[nIndex, 3] += PadR(SM0->M0_CODFIL, nLenFil, " ") + "|"
            EndIf
        EndIf
        SM0->(DbSkip())
    EndDo
    DbSelectArea("SRA")
    SRA->(DbSetOrder(RetOrdem("SRA", "RA_FILIAL+RA_MAT")))
    SRA->(DbGoTop())
    While !(SRA->(EOF()))
        nIndex := AScan(aListFilter, {|X| "|" + SRA->RA_FILIAL + "|" $ X[3]})
        If nIndex < 1
            SRA->(DbSkip())
            Loop
        Else
            If SRA->RA_CC >= aParameter[6] .And. SRA->RA_CC <= aParameter[7] .And. SRA->RA_DEPTO >= aParameter[8] .And. SRA->RA_DEPTO <= aParameter[9]
                If aListFilter[nIndex, 4] < 1
                    aAdd(aListFilter[nIndex], {})
                    aListFilter[nIndex, 4] := Len(aListFilter[nIndex])
                    aAdd(aListFilter[nIndex], 0)
                    aAdd(aListFilter[nIndex], 0)
                    aAdd(aListFilter[nIndex], 0)
                EndIf
                aAdd(aListFilter[nIndex, aListFilter[nIndex, 4]], {SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_ADMISSA, SRA->RA_DEMISSA, AllTrim(SRA->RA_CATFUNC)})
                If SRA->RA_CATFUNC $ "MH"
                    aListFilter[nIndex, aListFilter[nIndex, 4] + 1] += RU07R1914_GetHoursEmployee(aParameter[1])
                    aListFilter[nIndex, aListFilter[nIndex, 4] + 2] += RU07R1915_GetIncomeEmployee(aParameter[1])
                ElseIf SRA->RA_CATFUNC $ "A"
                    aListFilter[nIndex, aListFilter[nIndex, 4] + 3] += RU07R1915_GetIncomeEmployee(aParameter[1])
                EndIf
            EndIf
        EndIf
        SRA->(DbSkip())
    EndDo

    SM0->(RestArea(aSM0Area))
    SRA->(RestArea(aSRAArea))

Return aListFilter

/*/
{Protheus.doc} RU07R1913_GetAverCountByFilial(aFiltr, cMounth, cCatFunc)
    This function get average count for mounth by filter.

    @type Static Function
    @params aFiltr,   Array, Filter for data.
    @params cMounth,  Character, Period (mounth).
    @params cCatFunc, Character, Func of category for calculation.
    @author dchizhov
    @since 31.08.2023
    @version 12.1.2210
    @return nAverCount, Numeric, Average count.
    @example aAdd(aIter, Round(RU07R1913_GetAverCountByFilial(aTemp[nI], aParameter[1], "MH"), 2))
/*/
Static Function RU07R1913_GetAverCountByFilial(aFiltr, cMounth, cCatFunc)

    Local nAverCount             As Numeric
    Local nMonthDayCount         As Numeric
    Local dLastDateMonth         As Date
    Local nI                     As Numeric
    Local dFirstDateMonth        As Date
    Local aSraAverage            As Array
    Local nSumEmployee           As Numeric
    Local cFilterFilial          As Character
    Local dStartWorkMonthPer     As Date
    Local dFinishWorkMonthPer    As Date
    Local nIndSraArray           As Numeric

    nAverCount := 0
    aSraAverage := {}
    cFilterFilial := ""
    nIndSraArray := aFiltr[4]

    dFirstDateMonth := SToD(cMounth + "01")
    nMonthDayCount := RU07XFUN05_GetMonthSize(Val(SubStr(cMounth,5, 2)), Val(SubStr(cMounth,1, 4)))
    dLastDateMonth := SToD(cMounth + Str(nMonthDayCount, 2))
    nSumEmployee := 0
    nAverCount := 0

    For nI := 1 To Len(aFiltr[nIndSraArray])
        If Len(AllTrim(aFiltr[nIndSraArray, nI, 5])) > 0 .And. AllTrim(aFiltr[nIndSraArray, nI, 5]) $ cCatFunc
            dStartWorkMonthPer := Max(aFiltr[nIndSraArray, nI, 3], dFirstDateMonth)
            dFinishWorkMonthPer := Iif(Empty(aFiltr[nIndSraArray, nI, 4]), dLastDateMonth, Min(aFiltr[nIndSraArray, nI, 4], dLastDateMonth))
            If dStartWorkMonthPer <= dLastDateMonth .And. dFinishWorkMonthPer >= dFirstDateMonth
                nSumEmployee += dFinishWorkMonthPer - dStartWorkMonthPer + 1
            EndIf
        EndIf
    Next nI

    nAverCount := nSumEmployee / nMonthDayCount

Return nAverCount

/*/
{Protheus.doc} RU07R1914_GetHoursEmployee(cMounth)
    This function get count employee-hours for employee (MUST BE POSICIONE ON EMPLOYEE).

    @type Static Function
    @params cMounth, Character, Period for calculation.
    @author dchizhov
    @since 31.08.2023
    @version 12.1.2210
    @return nSumHours, Numeric, Count of employee hours.
    @example aListFilter[aListFilter[nIndex] + 1] += RU07R1914_GetHoursEmployee(aParameter[1])
/*/
Static Function RU07R1914_GetHoursEmployee(cMounth)

    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local nSumHours    As Numeric
    Local aArrPd       As Array

    aArea := GetArea()
    nSumHours := 0
    aArrPd := {"0031", "0032", "1756"}

    cQuery := "SELECT SRD.RD_HORAS, SRV.RV_COD, SRV.RV_CODFOL, SRV.RV_TIPO FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD "
    cQuery += " WHERE "
    cQuery += " RD_PERIODO = ? "
    cQuery += " AND RD_MAT = ? "
    cQuery += " AND (RV_CODFOL IN ('" + aArrPd[1] + "', '" + aArrPd[2] + "', '" + aArrPd[3] + "') "
    cQuery += " OR (RV_TIPOCOD = '" + RV_TIPO_INCOME + "' "
    cQuery += " AND RV_HE = '" + RV_OVERWORKING + "')) "
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cMounth)
    oStatement:SetString(2, SRA->RA_MAT)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !((cTab)->(EOF()))
        If AllTrim((cTab)->RV_CODFOL) <> aArrPd[2] .And. AllTrim((cTab)->RV_TIPO) == RV_TIPO_DAY .Or. AllTrim((cTab)->RV_CODFOL) $ aArrPd[1] + "|" + aArrPd[3]
            nSumHours += (cTab)->RD_HORAS * SRA->RA_HRSDIA
        ElseIf AllTrim((cTab)->RV_CODFOL) == aArrPd[2] .Or. (AllTrim((cTab)->RV_TIPO) == RV_TIPO_HOUR .And. AllTrim((cTab)->RV_CODFOL) <> aArrPd[1]  .And. AllTrim((cTab)->RV_CODFOL) <> aArrPd[3])
            nSumHours += (cTab)->RD_HORAS
        EndIf
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DbCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return nSumHours

/*/
{Protheus.doc} RU07R1915_GetIncomeEmployee(cMounth)
    This function get income for employee (MUST BE POSICIONE ON EMPLOYEE).

    @type Static Function
    @params cMounth, Character, Period for calculation.
    @author dchizhov
    @since 31.08.2023
    @version 12.1.2210
    @return nSumValor, Numeric, Sum of valor for income.
    @example aListFilter[aListFilter[nIndex] + 2] += RU07R1915_GetIncomeEmployee(aParameter[1])
/*/
Static Function RU07R1915_GetIncomeEmployee(cMounth)

    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local nSumValor    As Numeric

    aArea := GetArea()
    nSumValor := 0

    cQuery := "SELECT Sum(SRD.RD_VALOR) AS VALOR FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD "
    cQuery += " WHERE "
    cQuery += " SRD.RD_PERIODO = ? "
    cQuery += " AND SRD.RD_MAT = ? "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' "
    cQuery += " AND SRV.RV_TIPOCOD = '" + RV_TIPO_INCOME + "' "
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cMounth)
    oStatement:SetString(2, SRA->RA_MAT)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !((cTab)->(EOF()))
        nSumValor += (cTab)->VALOR
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DbCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return nSumValor





/*/
{Protheus.doc} CreateFirstPage(aData)
    This function create Json with first Page.

    @type Static Function
    @params aData, Array, Array with data for Json
    @author dchizhov
    @since 30.08.2023
    @version 12.1.2210
    @return oJson, Object, Json for pdf-maker.
    @example oJson := RU07R1910_CreateCoverPage(aDataForTit)
/*/
Static Function CreateFirstPage(aData)

    Local oJson As Object
    Local cJson As Character
    Local nX    As Numeric
    Local nI    As Numeric
    Local aSumm As Numeric

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content":[
            {
                "pageBreak": "before",
                "style": "normal",
                "alignment": "center",
                "bold": true,
                "text": ""
            },
            {
                "style": "normal",
                "alignment": "center",
                "text": ""
            },
            {
                "margin": [0, 10, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": ["*", 50, 80, 100, 100, 100, 100],
                    "body": [ 
                        [
                            {"rowSpan": 3}, {"rowSpan": 3}, {"rowSpan": 3}, {"colSpan": 4}, {}, {}, {}
                        ],
                        [
                            {}, {}, {}, {"rowSpan": 2}, {"colSpan": 3}, {}, {}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left", "text": " "}, {"text": "01"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border":[true, true, true, false], "text": ""}, {"border":[true, true, true, false], "text": ""}, 
                            {"border":[true, true, true, false], "text": ""}, {"border":[true, true, true, false], "text": ""}, 
                            {"border":[true, true, true, false], "text": ""}, {"border":[true, true, true, false], "text": ""}, 
                            {"border":[true, true, true, false], "text": ""}
                        ],
                        [
                            {"border":[true, false, true, true], "text": ""}, {"border":[true, false, true, true], "text": "02"}, 
                            {"border":[true, false, true, true], "text": ""}, {"border":[true, false, true, true], "text": ""}, 
                            {"border":[true, false, true, true], "text": ""}, {"border":[true, false, true, true], "text": ""}, 
                            {"border":[true, false, true, true], "text": ""}
                        ],
                        [
                            {}, {"text": "03"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {"text": "04"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {"text": "05"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {"text": "06"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {"text": "07"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {"text": "08"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {"text": "09"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {"text": "10"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {"text": "11"}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 20, 0, 0],
                "style": "normal",
                "alignment": "left",
                "text": ["", "", "", ""]
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)

    oJson["content"][1]["text"] := STR0060
    oJson["content"][2]["text"] := STR0061

    oJson["content"][3]["table"]["body"][1, 1]["text"] := STR0062
    oJson["content"][3]["table"]["body"][1, 2]["text"] := STR0063
    oJson["content"][3]["table"]["body"][1, 3]["text"] := STR0064 + " (" + STR0065 + ")"
    oJson["content"][3]["table"]["body"][1, 4]["text"] := STR0066
    oJson["content"][3]["table"]["body"][2, 4]["text"] := STR0067 + CRLF + STR0068
    oJson["content"][3]["table"]["body"][2, 5]["text"] := STR0069
    oJson["content"][3]["table"]["body"][3, 5]["text"] := STR0070 + " (" + STR0071 + ")"
    oJson["content"][3]["table"]["body"][3, 6]["text"] := STR0072 + " (" + STR0073 + ")"
    oJson["content"][3]["table"]["body"][3, 7]["text"] := STR0074 + " (" + STR0075 + ")"
    oJson["content"][3]["table"]["body"][4, 1]["text"] := STR0076
    oJson["content"][3]["table"]["body"][4, 2]["text"] := STR0077
    oJson["content"][3]["table"]["body"][4, 3]["text"] := STR0078
    aSumm := {0, 0, 0, 0}
    For nX := 1 To Len(aData)
        oJson["content"][3]["table"]["body"][nX + 6, 3]["text"] := aData[nX, 1, 1]
        oJson["content"][3]["table"]["body"][nX + 6, 4]["text"] := aData[nX, 2]
        oJson["content"][3]["table"]["body"][nX + 6, 5]["text"] := aData[nX, 3]
        oJson["content"][3]["table"]["body"][nX + 6, 6]["text"] := aData[nX, 4]
        oJson["content"][3]["table"]["body"][nX + 6, 7]["text"] := aData[nX, 5]
        For nI := 1 To Len(aSumm)
            aSumm[nI] += aData[nX, nI + 1]
        Next nI
    Next nX
    For nX := 4 To 7
        oJson["content"][3]["table"]["body"][4, nX]["text"] := CValToChar(nX - 3)
        oJson["content"][3]["table"]["body"][5, nX]["text"] := aSumm[nX - 3]
    Next nX
    oJson["content"][3]["table"]["body"][5, 1]["text"] := STR0079
    oJson["content"][3]["table"]["body"][5, 3]["text"] := STR0080
    oJson["content"][3]["table"]["body"][6, 1]["text"] := STR0081 + CRLF + STR0082

    oJson["content"][4]["text"][1] := "(" + STR0065 + ") - " + STR0083 + CRLF
    oJson["content"][4]["text"][2] := "(" + STR0071 + ") - " + STR0084 + CRLF
    oJson["content"][4]["text"][3] := "(" + STR0073 + ") - " + STR0085 + CRLF
    oJson["content"][4]["text"][4] := "(" + STR0075 + ") - " + STR0086 + CRLF

Return oJson

/*/
{Protheus.doc} CreateSecondPage(aData, aFoot)
    This function create Json with second Page.

    @type Static Function
    @params aData, Array, Array with data for Json
    @params aFoot, Array, Array with data for footer
    @author dchizhov
    @since 31.08.2023
    @version 12.1.2210
    @return oJson, Object, Json for pdf-maker.
    @example oJson := RU07R1910_CreateCoverPage(aDataForTit, aFooter)
/*/
Static Function CreateSecondPage(aData, aFoot)

    Local oJson As Object
    Local cJson As Character
    Local nX    As Numeric
    Local nI    As Numeric
    Local aSumm As Numeric
    Local dNow  As Date

    oJson := JsonObject():New()
    dNow := Date()

    BeginContent var cJson
    {
        "content":[
            {
                "pageBreak": "before",
                "style": "normal",
                "alignment": "center",
                "margin": [30, 0, 0, 0],
                "table": {
                    "widths": [100, 100, 100, 100, 100, 100, 100],
                    "body": [ 
                        [
                            {"colSpan": 2}, {}, {"colSpan": 4}, {}, {}, {}, {"rowSpan": 3}
                        ],
                        [
                            {"rowSpan": 2}, {"rowSpan": 2}, {"rowSpan": 2}, {"colSpan": 3}, {}, {}, {}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"text": " "}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            },
            {
                "style": "normal",
                "alignment": "center",
                "margin": [0, 15, 0, 0],
                "table": {
                    "widths": [300, 120, 5, 50, 70, 5, 15, 5, 60, 15, 15, 15],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "alignment": "left", "rowSpan": 2}, {"border": [false, false, false, false], "text": "", "colSpan": 11}, 
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {"border": [false, false, false, true]}, {"border": [false, false, false, false], "text": "", "rowSpan": 4}, 
                            {"border": [false, false, false, true], "colSpan": 2}, {}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "colSpan": 6, "text": ""}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "rowSpan": 3, "text": ""}, {"border": [false, true, false, false]}, {}, 
                            {"border": [false, true, false, false], "colSpan": 2}, {}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, true, false, false], "colSpan": 6}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {"border": [false, false, false, true]}, {}, {"border": [false, false, false, false]}, 
                            {"border": [false, false, false, true]}, {"border": [false, false, false, false]},
                            {"border": [false, false, false, true]}, {"border": [false, false, false, false]}, 
                            {"border": [false, false, false, true]}, {"border": [false, false, false, false]}, 
                            {"border": [false, false, false, true]}, {"border": [false, false, false, false]}
                        ],
                        [
                            {}, {"border": [false, true, false, false]}, {}, {"border": [false, false, false, false], "colSpan": 2, "text": ""}, {}, 
                            {"border": [false, false, false, false], "colSpan": 7}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            },
            {
                "style": "normal",
                "margin": [0, 20, 0, 0],
                "table": {
                    "widths": [70],
                    "body": [ 
                        [
                            {"border": [false, false, false, true], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 0, 0, 0],
                "style": "normal",
                "alignment": "left",
                "text": ["", ""]
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)

    oJson["content"][1]["table"]["body"][1, 1]["text"] := STR0100
    oJson["content"][1]["table"]["body"][1, 3]["text"] := STR0101 + CRLF + STR0102
    oJson["content"][1]["table"]["body"][1, 7]["text"] := STR0103
    oJson["content"][1]["table"]["body"][2, 1]["text"] := STR0104
    oJson["content"][1]["table"]["body"][2, 2]["text"] := STR0105
    oJson["content"][1]["table"]["body"][2, 3]["text"] := STR0106
    oJson["content"][1]["table"]["body"][2, 4]["text"] := STR0107
    oJson["content"][1]["table"]["body"][3, 4]["text"] := STR0108
    oJson["content"][1]["table"]["body"][3, 5]["text"] := STR0109
    oJson["content"][1]["table"]["body"][3, 6]["text"] := STR0110

    aSumm := {0, 0, 0, 0, 0, 0, 0}
    For nX := 1 To Len(aData)
        // oJson["content"][1]["table"]["body"][5 + nX, 1]["text"] := aData[nX, 6]
        // oJson["content"][1]["table"]["body"][5 + nX, 3]["text"] := aData[nX, 8]
        // oJson["content"][1]["table"]["body"][5 + nX, 4]["text"] := aData[nX, 9]
        // oJson["content"][1]["table"]["body"][5 + nX, 6]["text"] := aData[nX, 11]
        For nI := 1 To Len(aSumm)
            aSumm[nI] += aData[nX, 5 + nI]
            oJson["content"][1]["table"]["body"][5 + nX, nI]["text"] := aData[nX, 5 + nI]
        Next nI
    Next nX
    For nX := 1 To 7
        oJson["content"][1]["table"]["body"][4, nX]["text"] := CValToChar(nX + 4)
        oJson["content"][1]["table"]["body"][5, nX]["text"] := aSumm[nX]
    Next nX

    oJson["content"][2]["table"]["body"][1, 1]["text"] := STR0111 + CRLF + STR0112 + CRLF + STR0113 + CRLF + STR0114
    oJson["content"][2]["table"]["body"][2, 2]["text"] := CRLF + CRLF + CRLF + aFoot[1]
    oJson["content"][2]["table"]["body"][2, 4]["text"] := CRLF + CRLF + CRLF + aFoot[2]
    oJson["content"][2]["table"]["body"][3, 2]["text"] := STR0115
    oJson["content"][2]["table"]["body"][3, 4]["text"] := STR0116
    oJson["content"][2]["table"]["body"][3, 7]["text"] := STR0117
    oJson["content"][2]["table"]["body"][4, 2]["text"] := aFoot[3]
    oJson["content"][2]["table"]["body"][4, 4]["text"] := STR0118 + " (" + STR0119 + ")"
    oJson["content"][2]["table"]["body"][4, 5]["text"] := aFoot[4]
    oJson["content"][2]["table"]["body"][4, 6]["text"] := '"'
    oJson["content"][2]["table"]["body"][4, 7]["text"] := Day(dNow)
    oJson["content"][2]["table"]["body"][4, 8]["text"] := '"'
    oJson["content"][2]["table"]["body"][4, 9]["text"] := Lower(RU07R1980_GetMonthName(Month(dNow), 2))
    oJson["content"][2]["table"]["body"][4,10]["text"] := STR0120
    oJson["content"][2]["table"]["body"][4,11]["text"] := SubStr(DToS(dNow), 3, 2)
    oJson["content"][2]["table"]["body"][4,12]["text"] := STR0121
    oJson["content"][2]["table"]["body"][5, 2]["text"] := STR0122 + CRLF + STR0123 + " (" + STR0124 + ")"
    oJson["content"][2]["table"]["body"][5, 6]["text"] := STR0125 + CRLF + STR0126
    oJson["content"][4]["text"][1] := "(" + STR0119 + ") - " + STR0127 + CRLF
    oJson["content"][4]["text"][2] := "(" + STR0124 + ") - " + STR0128

Return oJson

/*/
{Protheus.doc} GetTemplatate()

    This function biuld empty templatate for report and Json without content.

    @type Static Function
    @params 
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return oJson, Object, Json for report.
    @example oJson := GetTemplatate()
/*/
Static Function GetTemplatate()

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "pageSize": "A4",
        "pageMargins": [0, 0, 0, 0],
        "pageOrientation": "landscape",
        "styles": {
            "title": {
                "fontSize": 11,
                "bold": true,
                "font": "Arial",
                "alignment": "center"
            },
            "normal": {
            "font": "Arial",
                "fontSize": 10,
                "bold": false
            },
            "normal7": {
            "font": "Arial",
                "fontSize": 7,
                "bold": false
            },
            "small": {
            "font": "Arial",
                "fontSize": 6,
                "bold": false
            }
        },
        "content": [
        ]
    }
    EndContent
    oJson:FromJson(cJson)

Return oJson

/*/
{Protheus.doc} RU07R1980_GetMonthName()

    This function return name of month.

    @type Function
    @params nNumMonth, Numeric, Number of mounth
    @params nNumPadej, Numeric, Number of padej (1- imenit, 2- rodit, 3 - dat, 4 - vinit, 5 - tvorit, 6 - predloj).
    @author dchizhov
    @since 30.08.2023
    @version 12.1.2210
    @return cName, Character, Name of mounth.
    @example oJson["content"][2]["table"]["body"][2, 3]["text"] := RU07R1980_GetMonthName(Val(aData[5]))
/*/
Function RU07R1980_GetMonthName(nNumMonth, nNumPadej)

    Local cName As Character

    DEFAULT nNumPadej := 1

    If nNumPadej == 1
        Do Case 
            Case nNumMonth == 1
                cName := STR0088 // "January"
            Case nNumMonth == 2
                cName := STR0089 // "February"
            Case nNumMonth == 3
                cName := STR0090 // "March"
            Case nNumMonth == 4
                cName := STR0091 // "April"
            Case nNumMonth == 5
                cName := STR0092 // "May"
            Case nNumMonth == 6
                cName := STR0093 // "June"
            Case nNumMonth == 7
                cName := STR0094 // "July"
            Case nNumMonth == 8
                cName := STR0095 // "August"
            Case nNumMonth == 9
                cName := STR0096 // "September"
            Case nNumMonth == 10
                cName := STR0097 // "October"
            Case nNumMonth == 11
                cName := STR0098 // "November"
            Case nNumMonth == 12
                cName := STR0099 // "December"
        EndCase
    ElseIf nNumPadej == 2
        Do Case 
            Case nNumMonth == 1
                cName := STR0129 // "January"
            Case nNumMonth == 2
                cName := STR0130 // "February"
            Case nNumMonth == 3
                cName := STR0131 // "Martha"
            Case nNumMonth == 4
                cName := STR0132 // "April"
            Case nNumMonth == 5
                cName := STR0133 // "May"
            Case nNumMonth == 6
                cName := STR0134 // "June"
            Case nNumMonth == 7
                cName := STR0135 // "July"
            Case nNumMonth == 8
                cName := STR0136 // "august"
            Case nNumMonth == 9
                cName := STR0137 // "September"
            Case nNumMonth == 10
                cName := STR0138 // "October"
            Case nNumMonth == 11
                cName := STR0139 // "November"
            Case nNumMonth == 12
                cName := STR0140 // "December"
        EndCase
    Else
        MsgInfo("Not Realized!", "Not Realized")
        cName := "Not Realized"
    EndIf

Return cName

/*/
{Protheus.doc} RU07R1981_GetColumnFromTableByNrec(cNameAlias, aColumnName, nRec)
    Get data from table by R_E_C_N_O_.

    @type Function
    @params cNameAlias,  Character, Alias of Table.
    @params aColumnName, Array,     Columns to get.
    @params nRec,        Numeric,   R_E_C_N_O_.
    @author dchizhov
    @since 30.08.2023
    @version 12.1.2210
    @return aResult, Array, Value into report format.
    @example aValue := RU07R1981_GetColumnFromTableByNrec(cNameAlias, aColumnName, nRecNo)
/*/
Function RU07R1981_GetColumnFromTableByNrec(cNameAlias, aColumnName, nRec)

    Local aReturn As Array
    Local aArea   As Array
    Local aTabArea As Array

    aReturn := { }

    If Len(aColumnName) > 0

        aArea := GetArea()
        aTabArea := (cNameAlias)->(GetArea())

        (cNameAlias)->(DbGoTo(nRec))

        If !((cNameAlias)->(EOF()))
            AEval(aColumnName, {|X| AAdd(aReturn, (cNameAlias)->(&(X)))} )
        EndIf

        (cNameAlias)->(RestArea(aTabArea))
        RestArea(aArea)
    EndIf

Return aReturn
