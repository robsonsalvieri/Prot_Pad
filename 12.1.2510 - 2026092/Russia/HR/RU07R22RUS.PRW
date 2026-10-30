#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R22RUS.CH"

#DEFINE WINDOW_HEIGHT_SIZE 250
#DEFINE WINDOW_WIDTH_SIZE 300

#DEFINE TEXTBOX_WIDTH_SIZE 180
#DEFINE TEXTBOX_HEIGHT_SIZE 10
#DEFINE TEXTBOX_MAX_LENGTH 250
#DEFINE SRA_STR_MAX_LENGHT 250

#DEFINE LABEL_WIDTH_SIZE 60
#DEFINE LABEL_HEIGHT_SIZE 15

#DEFINE BUTTON_HEIGHT 012
#DEFINE BUTTON_WIDTH 050

#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"
#DEFINE COUNT_PARAMS_FILTER 10
#DEFINE INDEX_COMBOBOX 10
#DEFINE NAME_OF_PROGRAM "RU07R22RUS"
#DEFINE INDEX_SIGNER "8"
#DEFINE INDEX_SRA 7


/*/
{Protheus.doc} RU07R22RUS()

    The main function of the pdf-report is "Information about the insured person".
    
    @type Function
    @params 
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return 
    @example RU07R22RUS()
/*/
Function RU07R22RUS()

    Local oReportButton     As Object
    Local oExitButton       As Object
    Local oFilterButton     As Object
    Local aFilter           As Array
    Local aUserSettings     As Array
    Local nI                As Numeric
    Local cIdUser           As Character
    Local lSeeAll           As Logical
    Local bExitButton   := {|| oDlg:End()}
    Local bFilterButton := {|| aFilter := RU07R2203_GetFilterWindow(NAME_OF_PROGRAM)}
    Local bReportButton := {|| MsgRun(STR0127, STR0031, {|| RU07R2201_PrintReport(aFilter)})} // "Please wait!", "The process of reading data from filters and parameters."

    lSeeAll := VerSenha(114) .And. VerSenha(115)

    cIdUser := "U" + RetCodUsr()
    // Load default value for filter
    aFilter := RU07R2204_GetStrFilter(2)
    // Load value from database for filter
    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_FILTER, NAME_OF_PROGRAM)
    For nI := 1 To COUNT_PARAMS_FILTER
        If !(ValType(aUserSettings[nI]) $ "A|U")
            aFilter[nI] := Iif(nI == INDEX_COMBOBOX, Val(aUserSettings[nI]), SubStr(aUserSettings[nI], 1, Len(aFilter[nI])))
        EndIf
    Next nI
    If !lSeeAll
        aFilter[3] := xFilial("SRA")
    EndIf
    aFilter[INDEX_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aFilter[INDEX_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))

    // Assemble the Dimensions of Objects.
    oSize := FwDefSize():New(.F.)
    oSize:AddObject("CABECALHO", (oSize:aWindSize[3] * 1.1), (oSize:aWindSize[3] * 0.4), .F., .F.) // Not scalable.
    oSize:aMargins := {0, 0, 0, 0} // Space beside 0 objects, among them 3.
    oSize:lProp := .F. // Proportional.
    oSize:Process() // Trigger the calculations.

    DEFINE FONT oFont NAME "Arial" SIZE 0,-12 BOLD
    DEFINE MSDIALOG oDlg TITLE STR0009 From 0,0 TO (oSize:aWindSize[3] * 0.4), (oSize:aWindSize[3] * 1.1) OF oMainWnd PIXEL

        @oSize:GetDimension("CABECALHO", "LININI") + 3, oSize:GetDimension("CABECALHO","COLINI") + 3 GROUP oGroup To oSize:GetDimension("CABECALHO", "LINEND") * 0.49471, oSize:GetDimension("CABECALHO", "COLEND") * 0.5  LABEL STR0037 OF oDlg PIXEL // "Description".
        oGroup:oFont:=oFont
        @oSize:GetDimension("CABECALHO", "LININI") + 20, oSize:GetDimension("CABECALHO", "COLINI") + 13 SAY STR0009;
            SIZE oSize:GetDimension("CABECALHO", "COLEND") * 0.49471, oSize:GetDimension("CABECALHO", "LINEND") * 0.35 Of oDlg Pixel

        oFilterButton   := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412,  15, STR0041, NIL, bFilterButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Filter".
        oReportButton   := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412,  70, STR0038, NIL, bReportButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Report".
        oExitButton     := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412, 125, STR0122, NIL, bExitButton,   BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Exit".

    ACTIVATE MSDIALOG oDlg CENTERED

Return


/*/
{Protheus.doc} RU07R2201_PrintReport(aFilter)

    Get data and print the SOZL report.

    @type Static Function
    @params aFilter, Array, Filter entered by the user.
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return .T.
    @example Local bReportButton := {|| MsAguarde({|| RU07R2201_PrintReport(aFilter)}, STR0031, STR0032)}
/*/
Static Function RU07R2201_PrintReport(aFilter)

    Local oSOZLObject  As Object
    Local nX           As Numeric
    Local nOrder       As Numeric
    Local nLenght      As Numeric
    Local cTemp        As Character
    Local cNome := ''  As Character
    Local aSRAArea     As Array
    Local lPageBreak   As Logical

    If (StaticCall(RU07R20RUS, RU07R2002_IsAcceptButton, aFilter))
        lPageBreak := .T.
        aSRAArea := SRA->(GetArea())
        oSOZLObject := RuRHSOZLForm():New(aFilter, StaticCall(RU07R20RUS, RU07R2006_GetFilterStr, aFilter), NAME_OF_PROGRAM)
        oSOZLObject:oGeneralJson := JsonObject():New()
        If Len(oSOZLObject:aPersonnelNumbers) > 0
            oSOZLObject:cFilialCode := oSOZLObject:aPersonnelNumbers[1, 2]
        ElseIf !Empty(AllTrim(aFilter[1]))
            oSOZLObject:cFilialCode := AllTrim(aFilter[1])
        EndIf
        oSOZLObject:oGeneralJson["content"] := {}
        oSOZLObject:cHeadTitlePage := STR0009 // "Information about the insured person"
        oSOZLObject:cSignerPost := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, aFilter[8])
        oSOZLObject:cSignerName := aFilter[9]
        oSOZLObject:cDate := CValToChar(Date())

        cTemp := CValToChar(Len(oSOZLObject:aPersonnelNumbers))
        nOrder := RetOrder("SRA", "RA_MAT+RA_FILIAL")
        nLenght := Len(cTemp)
        oSOZLObject:aPersonnelNumbers := oSOZLObject:SortByName(oSOZLObject:aPersonnelNumbers)

        If Len(aFilter[7]) == 0
            MsgAlert(STR0153, STR0152) // "Attention" + "No employee has been selected to generate the report."
        ElseIf aFilter[10] == 1
            For nX := 1 To Len(oSOZLObject:aPersonnelNumbers)
                lPageBreak := Iif( nX == 1, .F., .T. )
                If !Empty(Posicione("SRA", nOrder, oSOZLObject:aPersonnelNumbers[nX, 1], "RA_MAT"))
                    MsgRun(STR0126 + " " + PadL(CValToChar(nX), nLenght, "0") + "/" + cTemp, STR0009, {|| RU07R2206_GetDataForPDF(oSOZLObject, lPageBreak)}) // "Processed employees:"
                EndIf
            Next nX
            MsgRun(STR0125, STR0009, {||oSOZLObject:GetViewReport()}) // "Build a PDF"
            SRA->(RestArea(aSRAArea))
        ElseIf aFilter[10] == 2
            oSOZLObject:cNameReport := RU07R2205_GetXmlPath()
            If Len(AllTrim(oSOZLObject:cNameReport)) > 0 
                For nX := 1 To Len(oSOZLObject:aPersonnelNumbers)
                    If !Empty(Posicione("SRA", nOrder, oSOZLObject:aPersonnelNumbers[nX, 1], "RA_MAT"))
                        Iif(RU07R2202_ExcelFilePrint(oSOZLObject), cNome += '', cNome += AllTrim(SRA->RA_NOME)+CRLF)
                    EndIf
                Next nX
                MsgInfo(STR0150, STR0152) // "Attention" + "The SOZL has been completed."
                If Len(cNome) > 0
                    MsgStop(STR0149 + CRLF + cNome) // "The SOZL has not been generated for the following employees:" + employee's full name
                EndIf
            Else
                MsgAlert(STR0151, STR0152) // "Attention" + "The file will not be saved, because the path for saving the xml-file is not selected."
            EndIf
        Else
            MsgAlert(STR0147, STR0152) // "Select the file format."
        EndIf
        
        FreeObj(oSOZLObject)
    EndIf

Return .T.


/*/
{Protheus.doc} RU07R2206_GetDataForPDF(oSOZLObject, lPageBreak)

    Forms the content of the pdf-file for the printed form SOZL.

    @type Function
    @params oSOZLObject, Object, Object with information about the insured person.
            lPageBreak, Logical, Logical variable for determining the first page of a pdf-file.
    @author alysenko
    @since 20.03.2024
    @version 12.1.33
    @return oSOZLObject, Object, Object with information about the insured person.
    @example MsgRun(STR0126 + " " + PadL(CValToChar(nX), nLenght, "0") + "/" + cTemp, STR0009, {|| RU07R2206_GetDataForPDF(oSOZLObject, lPageBreak)})
/*/
Function RU07R2206_GetDataForPDF(oSOZLObject, lPageBreak)
                    oTitle   := oSOZLObject:GetTitle()
                    oTabsIn_1 := oSOZLObject:GetInTable()
                    oTabsFrom_1 := oSOZLObject:GetFromTable()
                    oPart1Form_1 := oSOZLObject:Get1Part()
                    oPart2Form_2 := oSOZLObject:Get2Part()
                    oPart3Form_3 := oSOZLObject:Get3Part()
                    oPart4Form_4 := oSOZLObject:Get4Part()
                    oPart5Form_5 := oSOZLObject:Get5Part()
                    oPart6Form_6 := oSOZLObject:Get6Part()
                    oPart71Form_71 := oSOZLObject:Get71Part()
                    oPart72Form_72 := oSOZLObject:Get72Part()
                    oPart73Form_73 := oSOZLObject:Get73Part()

                    oSOZLObject:AddContent(oSOZLObject:GetTitle(lPageBreak))
                    oSOZLObject:AddContent(oTabsIn_1)
                    oSOZLObject:AddContent(oTabsFrom_1)
                    oSOZLObject:AddContent(oPart1Form_1)
                    oSOZLObject:AddContent(oPart2Form_2)
                    oSOZLObject:AddContent(oPart3Form_3)
                    oSOZLObject:AddContent(oPart4Form_4)
                    oSOZLObject:AddContent(oPart5Form_5)
                    oSOZLObject:AddContent(oPart6Form_6)
                    oSOZLObject:AddContent(oPart71Form_71)
                    oSOZLObject:AddContent(oPart72Form_72)
                    oSOZLObject:AddContent(oPart73Form_73)
Return oSOZLObject


/*/
{Protheus.doc} RU07R2202_ExcelFilePrint(oSOZLObject)
    Printing of the SOZL in xml format.

    @type Function
    @params oSOZLObject, Object, Object with information about the insured person.
    @author 
    @since 12.02.2024
    @version 12.1.2210
    @return 
    @example RU07R2202_ExcelFilePrint(oSOZLObject)
/*/
Function RU07R2202_ExcelFilePrint(oSOZLObject)
    Local nHdl      := 0                      As Numeric
    Local cXML      := ""                     As Character
    Local cDirect   := ""                     As Character
    Local aDatTemp  := {}                     As Array
    Local cNameBank                           As Character
    Local cBIK                                As Character
    Local lXml      := .T.                    As Logical
    Local cFirstName     := AllTrim(SRA->RA_PRISOBR)  As Character

    cDirect := AllTrim(oSOZLObject:cNameReport) + UPPER(cFirstName) + FWTimeStamp(1) + '.xml'
    
    cSQL := "SELECT * FROM " + RetSQLName("SA6") + " WHERE A6_FILIAL = ? AND A6_COD = '" + Substr(AllTrim(SRA->RA_BCDEPSA), 1, 3) + "' AND A6_AGENCIA = '" + Substr(AllTrim(SRA->RA_BCDEPSA), 4, Len(AllTrim(SRA->RA_BCDEPSA))) + "' AND D_E_L_E_T_=' ' ORDER BY A6_TYPEACC ASC " 
    cTabl := "SA6"
    aParam := {xFilial("SA6")}
    aField := {'A6_NOME', 'A6_AGENCIA'}
    StaticCall(RU07R10RUS, RU07R1009_SelectData, cTabl, cSQL, aParam, aField, @aDatTemp)
    cNameBank := UPPER(AllTrim(aDatTemp[1, 2]))
    cBIK      := AllTrim(aDatTemp[2, 2])
    cBirthDate := Substr(AllTrim(CValToChar(SRA->RA_NASC)), 7, 4) + '-' + Substr(AllTrim(CValToChar(SRA->RA_NASC)), 4, 2) + '-' + Substr(AllTrim(CValToChar(SRA->RA_NASC)), 1, 2)
    cIssDate := Substr(AllTrim(CValToChar(SRA->RA_DEMIPAS)), 7, 4) + '-' + Substr(AllTrim(CValToChar(SRA->RA_DEMIPAS)), 4, 2) + '-' + Substr(AllTrim(CValToChar(SRA->RA_DEMIPAS)), 1, 2)
    cExpDate := Substr(AllTrim(CValToChar(SRA->RA_DVALPAS)), 7, 4) + '-' + Substr(AllTrim(CValToChar(SRA->RA_DVALPAS)), 4, 2) + '-' + Substr(AllTrim(CValToChar(SRA->RA_DVALPAS)), 1, 2)
    
    //Creates the xml-file
    nHdl := fCreate(cDirect)
    //If there was an error in the creation
    If nHdl == -1
        lXml := .F.
    Else
        //Here is the body of the XML
        cXML += '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
        // Part 1
        cXML += '<insuredPerson xmlns="urn:ru:fss:integration:types:rpu:InsuredPerson:v01" xmlns:p="http://www.fss.ru/integration/types/person/v02" xmlns:c="http://www.fss.ru/integration/types/common/v01" xmlns:r="http://www.fss.ru/integration/types/dic/CauseRadiationExposure/v01" xmlns:id="http://www.fss.ru/integration/types/dic/identtityDoc/v01" xmlns:dsz="urn:ru:fss:integration:types:dic:SpecialZone:v01" xmlns:e="http://www.fss.ru/integration/types/dic/errors/v01" xmlns:org="http://www.fss.ru/integration/types/organization/v01">' + CRLF
        cXml += Space(4)   +'<fullName>' + CRLF
        cXml += Space(8)   +'<p:firstName>' + EncodeUTF8(AllTrim(SRA->RA_PRINOME)) + '</p:firstName>' + CRLF
        cXml += Space(8)   +'<p:lastName>' + EncodeUTF8(AllTrim(SRA->RA_PRISOBR)) + '</p:lastName>' + CRLF
        cXml += Space(8)   +'<p:middleName>' + EncodeUTF8(AllTrim(SRA->RA_SECNOME)) + '</p:middleName>' + CRLF
        cXml += Space(4)   +'</fullName>' + CRLF
        cXml += Space(4)   +'<birthDate>' + cBirthDate + '</birthDate>' + CRLF
        cXml += Space(4)   +'<gender>' + Iif(SRA->RA_SEXO == 'F', 'FEMALE', 'MALE') + '</gender>' + CRLF
        cXml += Space(4)   +'<snils>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_CIC))) + '</snils>' + CRLF
        cXml += Space(4)   +'<inn>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_PIS))) + '</inn>' + CRLF
        // Part 2
        If SRA->RA_FICHA == "21" .OR. SRA->RA_FICHA == "14" .OR. SRA->RA_FICHA == "91"
            cXml += Space(4)   +'<identityDocument>' + CRLF
            Do case
                case SRA->RA_FICHA == "21"
                    cXml += Space(8)   +'<passport>' + CRLF
                    cXml += Space(12)  +'<series>' + EncodeUTF8(Substr(CValToChar(SRA->RA_NUMEPAS), 1, 4)) + '</series>' + CRLF
                    cXml += Space(12)  +'<number>' + EncodeUTF8(Substr(CValToChar(SRA->RA_NUMEPAS), 5, 6)) + '</number>' + CRLF
                    cXml += Space(12)  +'<issueDate>' + cIssDate + '</issueDate>' + CRLF
                    cXml += Space(12)  +'<whoIssued>' + EncodeUTF8(AllTrim(SRA->RA_EMISPAS)) + '</whoIssued>' + CRLF
                    cXml += Space(8)   +'</passport>' + CRLF
                case SRA->RA_FICHA == "14"
                    cXml += Space(8)   +'<tempIdentDocType>' + CRLF
                    cXml += Space(12)  +'<number>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_NUMEPAS))) + '</number>' + CRLF
                    cXml += Space(12)  +'<expirationDate>' + cExpDate + '</expirationDate>' + CRLF
                    cXml += Space(8)   +'</tempIdentDocType>' + CRLF
                case SRA->RA_FICHA == "91"
                    cXml += Space(8)   +'<otherIdentDocType>' + CRLF
                    cXml += Space(12)  +'<type>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_FICHA))) + '</type>' + CRLF
                    cXml += Space(12)  +'<number>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_NUMEPAS))) + '</number>' + CRLF
                    cXml += Space(12)  +'<expirationDate>' + cExpDate + '</expirationDate>' + CRLF
                    cXml += Space(8)   +'</otherIdentDocType>' + CRLF
            Endcase
            cXml += Space(4)   +'</identityDocument>' + CRLF
        EndIf
        // Part 3
        If SRA->RA_FICHA == "12" .OR. SRA->RA_FICHA == "15"
            cXml += Space(4)   +'<identityDocument>' + CRLF
            cXml += Space(8)   +'<otherIdentDocType>' + CRLF
            cXml += Space(12)  +'<type>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_FICHA))) + '</type>' + CRLF
            Do case
                case SRA->RA_FICHA == "12"
                    cXml += Space(12)  +'<series>' + EncodeUTF8(Substr(CValToChar(SRA->RA_NUMEPAS), 1, 2)) + '</series>' + CRLF
                    cXml += Space(12)  +'<number>' + EncodeUTF8(AllTrim(Substr(CValToChar(SRA->RA_NUMEPAS), 3, len(SRA->RA_NUMEPAS)-2))) + '</number>' + CRLF
                case SRA->RA_FICHA == "15"
                    cXml += Space(12)  +'<number>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_NUMEPAS))) + '</number>' + CRLF
            Endcase
            cXml += Space(12)  +'<expirationDate>' + cIssDate + '</expirationDate>' + CRLF
            cXml += Space(8)   +'</otherIdentDocType>' + CRLF
            cXml += Space(4)   +'</identityDocument>' + CRLF
            cXml += Space(4)   +'<residenceDocumentType>' + CRLF
            Do case
                case SRA->RA_FICHA == "12"
                    cXml += Space(8)   +'<residentCard>' + CRLF
                    cXml += Space(12)  +'<series>' + EncodeUTF8(Substr(CValToChar(SRA->RA_NUMEPAS), 1, 2)) + '</series>' + CRLF
                    cXml += Space(12)  +'<number>' + EncodeUTF8(AllTrim(Substr(CValToChar(SRA->RA_NUMEPAS), 3, len(SRA->RA_NUMEPAS)-2))) + '</number>' + CRLF
                    cXml += Space(12)  +'<passportIssueDate>' + cIssDate + '</passportIssueDate>' + CRLF
                    cXml += Space(8)   +'</residentCard>' + CRLF
                case SRA->RA_FICHA == "15"
                    cXml += Space(8)   +'<tempResidencePermit>' + CRLF
                    cXml += Space(12)  +'<number>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_NUMEPAS))) + '</number>' + CRLF
                    cXml += Space(12)  +'<issueDate>' + cIssDate + '</issueDate>' + CRLF
                    cXml += Space(8)   +'</tempResidencePermit>' + CRLF
            Endcase
            cXml += Space(4)   +'</residenceDocumentType>' + CRLF
        EndIf
        // Part 5
        cXml += Space(4)   +'<regAddress>' + CRLF
        cXml += Space(8)   +'<fiasAddress>' + CRLF
        cXml += Space(12)  +'<c:houseGuid>' + EncodeUTF8(AllTrim(SRA->RA_MUNICIP)) + '</c:houseGuid>' + CRLF
        cXml += Space(12)  +'<c:flat>' + EncodeUTF8(AllTrim(SRA->RA_NUMENDE)) + '</c:flat>' + CRLF
        cXml += Space(8)   +'</fiasAddress>' + CRLF
        cXml += Space(8)   +'<postalCode>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_CEP))) + '</postalCode>' + CRLF
        cXml += Space(4)   +'</regAddress>' + CRLF
        // Part 6
        // Part 7
        If SRA->RA_TPCTSAL == "1"
            cXml += Space(4)   +'<methodReceivePayment>' + CRLF
            cXml += Space(8)   +'<c:bankInfo>' + CRLF
            cXml += Space(12)  +'<c:bankName>' + EncodeUTF8(cNameBank) + '</c:bankName>' + CRLF
            cXml += Space(12)  +'<c:bik>' + EncodeUTF8(cBIK) + '</c:bik>' + CRLF
            cXml += Space(12)  +'<c:accountNum>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_CTDEPSA))) + '</c:accountNum>' + CRLF
            cXml += Space(8)   +'</c:bankInfo>' + CRLF
            cXml += Space(4)   +'</methodReceivePayment>' + CRLF
        Else
            cXml += Space(4)   +'<methodReceivePayment>' + CRLF
            cXml += Space(8)   +'<c:currentFiasAddress>' + CRLF
            cXml += Space(12)  +'<c:guid>' + EncodeUTF8(AllTrim(SRA->RA_MUNICIP)) + '</c:guid>' + CRLF
            cXml += Space(12)  +'<c:house>' + EncodeUTF8(AllTrim(SRA->RA_MUNICIP)) + '</c:house>' + CRLF
            cXml += Space(12)  +'<c:flat>' + EncodeUTF8(AllTrim(SRA->RA_NUMENDE)) + '</c:flat>' + CRLF
            cXml += Space(8)   +'</c:currentFiasAddress>' + CRLF
            cXml += Space(8)   +'<c:postalCode>' + EncodeUTF8(AllTrim(CValToChar(SRA->RA_CEP))) + '</c:postalCode>' + CRLF
            cXml += Space(4)   +'</methodReceivePayment>' + CRLF
        EndIf
        cXML += '</insuredPerson>'

        //Functions write to the xml-file and close him.
        fWrite(nHdl,cXML)
        fClose(nHdl)
    EndIf
    
Return lXml


/*/
{Protheus.doc} RU07R2203_GetFilterWindow(cNameFil)

    Shows a window for filter.

    @type Static Function
    @params cNameFil, Character, Name of programm filter
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return aResultDialog, Array, Array of current parametr.
    @example Local bFilterButton := {|| aFilter := RU07R2203_GetFilterWindow(NAME_OF_PROGRAM)}
/*/
Function RU07R2203_GetFilterWindow(cNameFil)

    Local aResultDialog       As Array
    Local aItems := {}        As Array
    Local oDialog             As Object
    Local aFilterField        As Array
    Local aUserSettings := {} As Array
    Local oGridLayout         As Object
    Local oPanelBottom        As Object
    Local oScrollBox          As Object
    Local nI                  As Numeric
    Local cIdUser             As Character
    Local oHelp               As Object
    Local cHelp               As Character
    Local cValidate           As Character
    Local cNChar              As Character
    Local cChange             As Character
    Local lSeeAll             As Logical

    Default cNameFil := NAME_OF_PROGRAM

    cIdUser := "U" + RetCodUsr()
    lSeeAll := VerSenha(114) .And. VerSenha(115)

    aFilterField := {{Array(COUNT_PARAMS_FILTER), , }, {Array(COUNT_PARAMS_FILTER), , Array(COUNT_PARAMS_FILTER)}} // fields and Title for it. 

    aFilterField[1, 2] := RU07R2204_GetStrFilter(1)
    aFilterField[2, 2] := RU07R2204_GetStrFilter(2)
    aResultDialog := RU07R2204_GetStrFilter(2)
    aFilterField[1, 3] := RU07R2204_GetStrFilter(3)
    aItems := RU07R2204_GetStrFilter(4)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_FILTER, cNameFil)

    For nI := 1 To COUNT_PARAMS_FILTER
        If nI == INDEX_COMBOBOX
            nIndex := Val(aResultDialog[nI])
            If nIndex <= Len(aItems) .And. nIndex > 0
                aFilterField[2, 2, nI] := aItems[nIndex]
                aFilterField[2, 3, nI] := nIndex
            EndIf
        EndIf
        If !(ValType(aUserSettings[nI]) $ "A|U")
            If nI == INDEX_COMBOBOX
                nIndex := Val(aUserSettings[nI])
                If nIndex <= Len(aItems) .And. nIndex > 0
                    aFilterField[2, 2, nI] := aItems[nIndex]
                    aFilterField[2, 3, nI] := nIndex
                EndIf
            Else
                aFilterField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aFilterField[2, 2, nI]))
            EndIf
            aResultDialog[nI] := Iif(nI == INDEX_COMBOBOX, aFilterField[2, 3, nI], aFilterField[2, 2, nI])
        EndIf
    Next nI
    aResultDialog[INDEX_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aFilterField[2, 2, INDEX_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))
    If !lSeeAll
        aResultDialog[1] := aFilterField[2, 2, 3] := xFilial("SRA")
        aResultDialog[2] := aFilterField[2, 2, 4] := xFilial("SRA")
    EndIf

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(STR0041) // "Filter"
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({||StaticCall(RU07R20RUS, RU07R2002_IsAcceptButton, aFilterField[2, 2])})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    For nI := 1 To COUNT_PARAMS_FILTER

        cNChar := CValToChar(nI)
        
        // Make lines for parametr
        aFilterField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aFilterField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        aFilterField[1, 1, nI]:lWordWrap := .F.

        If nI < 8
            aFilterField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aFilterField[2, 2, " + CNChar + "], aFilterField[2, 2, " + CNChar + "] := u)}"), oScrollBox, ;
            TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,, Iif(nI < 3, !lSeeAll, .F.),,, "aFilterField[2, 2, " + cNChar + "]",,,, .T., .F.)
        ElseIf nI == INDEX_COMBOBOX
            cValidate := "{|o| aFilterField[2, 3, " + cNChar + "] := o:nAt}"
            aFilterField[2, 1, nI] := TComboBox():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aFilterField[2, 2, " + CNChar + "], aFilterField[2, 2, " + CNChar + "] := u)}"), aItems, ;
            TEXTBOX_WIDTH_SIZE - 50, TEXTBOX_HEIGHT_SIZE, oScrollBox,, &(cValidate),,,, .T.,,,,,,,,, "aFilterField[2, 2, " + cNChar + "]")
        Else
            cValidate := "{|| Iif(!RU07R1305_GetFullNameOfSignature(aFilterField[2, 2, " + CNChar + "], @aFilterField[2, 2, " + CValToChar(nI + 1) + "]), &('aFilterField[2, 2, " + CValToChar(nI + 1) + "] := Space(1), .F.'), .T.)}"
            cChange := "{|u| If( PCount() == 0, aFilterField[2, 2, " + CNChar + "], aFilterField[2, 2, " + CNChar + "] := u)}"
            aFilterField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &(cChange), oScrollBox, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, ;
            0,16777215,,.F.,,.T.,,.F.,,.F.,.F., Iif(cNChar $ INDEX_SIGNER, &(cValidate), Nil), CValToChar(nI - 1) $ INDEX_SIGNER,,, "aFilterField[2, 2, " + cNChar + "]",,,, .T., .F.)
        EndIf

        aFilterField[2, 1, nI]:bHelp := &("{|| ShowHelpCpo('CustomField', {aFilterField[1, 3, " + CNChar + "]}, 1, {aFilterField[1, 3, " + CNChar + "]}, 1)}")
        aFilterField[2, 1, nI]:bGotFocus:= &("{|o|  cHelp := aFilterField[1, 3, " + CNChar + "], oHelp:Refresh()}")

    Next nI

    oButtonSRAList := TButton():New(130, 250, "...", oScrollBox, {|| aFilterField[2, 2, 7] := Padr(RU16R0104_GetSraList(aFilterField[2, 2, 7]), SRA_STR_MAX_LENGHT, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    oButtonXX8Type := TButton():New(10,  250, "...", oScrollBox, {|| aFilterField[2, 2, 1] := StaticCall(RU07R20RUS, F3XX8StrCompany, 1), MsgAlert(STR0028, STR0041), aFilterField[2, 2, 2] := StaticCall(RU07R20RUS, F3XX8StrCompany, 2)}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    oButtonXX8Empl := TButton():New(30,  250, "...", oScrollBox, {|| aFilterField[2, 2, 2] := StaticCall(RU07R20RUS, F3XX8StrCompany, 2)}, 10, 10, , , .F., .T., .F., , .F., , , .F.)

    aFilterField[2, 1, 3]:cF3 := "XM0"
    aFilterField[2, 1, 4]:cF3 := "XM0"
    aFilterField[2, 1, 5]:cF3 := "CTT"
    aFilterField[2, 1, 6]:cF3 := "CTT"
    aFilterField[2, 1, Val(INDEX_SIGNER)]:cF3 := "SQ3"

    @ 05,05 GET oHelp VAR cHelp OF oPanelBottom MULTILINE SIZE WINDOW_WIDTH_SIZE - 10, 035 PIXEL READONLY WHEN .T. NO VSCROLL
    oHelp:lCanGotFocus := .F.

    oDialog:bInit := {|| aFilterField[2, 1, 1]:Setfocus(), oHelp:Refresh() }
    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        For nI := 1 To COUNT_PARAMS_FILTER
            If nI == INDEX_COMBOBOX
                aUserSettings[nI] := CValToChar(aFilterField[2, 3, nI])
                aResultDialog[nI] := aFilterField[2, 3, nI]
            Else
                aResultDialog[nI] := aFilterField[2, 2, nI]
                aUserSettings[nI] := aFilterField[2, 2, nI]
            End
        Next nI

        aResultDialog[INDEX_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aFilterField[2, 2, INDEX_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_FILTER, cNameFil, aUserSettings)

    EndIf

Return aResultDialog


/*/
{Protheus.doc} RU07R2205_GetXmlPath()

    Creating an xml file.

    @type Function
    @params
    @author alysenko
    @since 12.02.2024
    @version 12.1.33
    @return cXmlPath, Character, The path to save the xml file.
    @example Local cDirect   := RU07R2205_GetXmlPath() As Character
/*/
Function RU07R2205_GetXmlPath()
    Local cXmlPath := '' As Character
    
    MsgAlert(STR0148, STR0009) // "Select the path to save the xml-file SOZL." "Information about the insured person"
    cXmlPath := Padr(cGetFile("*.*", STR0148, 1, "C:\", .T., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.), TEXTBOX_MAX_LENGTH, Space(1))

Return cXmlPath


/*/
{Protheus.doc} RU07R2204_GetStrFilter(nMode)

    Create Array by str constant for title, for empty val, for helps in filter-window.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for Filters; 2 - empty Filters; 3 - Array of help.
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return aAraay, Array, Array of empty Filters or title for Filters.
    @example aFilterField[1, 2] := RU07R2204_GetStrFilter(1)
/*/
Static Function RU07R2204_GetStrFilter(nMode)

    Local aArray  As Array
    Local lSeeAll As Logical

    DEFAULT nMode := 1

    aArray := Array(COUNT_PARAMS_FILTER)

    If nMode == 1
        aArray[ 1] := STR0128 // "Structure layer"
        aArray[ 2] := STR0123 // "Policyholder"
        aArray[ 3] := STR0129 // "Branch from"
        aArray[ 4] := STR0130 // "Branch before"
        aArray[ 5] := STR0131 // "Department from"
        aArray[ 6] := STR0132 // "Department before"
        aArray[ 7] := STR0133 // "TN"
        aArray[ 8] := STR0134 // "Signatory"
        aArray[ 9] := STR0135 // "Full name of the signatory"
        aArray[10] := STR0144 // "Format"
    ElseIf nMode == 2
        lSeeAll := VerSenha(114) .And. VerSenha(115)
        If lSeeAll
            aArray[ 3] := aArray[ 4] := Replicate("Z", TamSX3("RA_FILIAL")[1])
        Else
            aArray[ 3] := xFilial("SRA")
            aArray[ 4] := Replicate("Z", TamSX3("RA_FILIAL")[1])
        EndIf
        aArray[ 1] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 2] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 5] := Space(TamSX3("RA_CC")[1])
        aArray[ 6] := Replicate("Z", TamSX3("RA_CC")[1])
        aArray[ 7] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 8] := Space(TamSX3("RCH_PER")[1])
        aArray[ 9] := Space(TEXTBOX_MAX_LENGTH)
        aArray[10] := Space(4)
    ElseIf nMode == 3
        aArray[ 1] := STR0136 // "Select the structure layer."
        aArray[ 2] := STR0124 // "Select an Policyholder."
        aArray[ 3] := STR0137 // "Select the start branch."
        aArray[ 4] := STR0138 // "Select the final branch."
        aArray[ 5] := STR0139 // "Select the start department."
        aArray[ 6] := STR0140 // "Select the final department."
        aArray[ 7] := STR0141 // "Select the employee's registration number."
        aArray[ 8] := STR0142 // "Enter the signer."
        aArray[ 9] := STR0143 // "Surname First Name Patronymic of the signatory."
        aArray[10] := STR0147 // "Select the file format."
    ElseIf nMode == 4
        aArray := Array(2)
        aArray[ 1] := STR0145 // "PDF"
        aArray[ 2] := STR0146 // "XML"
    Else
        aArray := {}
    EndIf

Return aArray
