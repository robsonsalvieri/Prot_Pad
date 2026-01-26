#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R20RUS.CH"

#DEFINE SEPARATOR_LINE_ARRAY {" ", "!", "?"}


/*/
{Protheus.doc} RuRHSTDRForm

    Class for STD-R Form.

    @type Class
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
/*/
Class RuRHSTDRForm From LongNameClass

    Data aParameters        As Array     // Array of parameters.
    Data aFilter            As Array     // Array of Filter.
    Data oGeneralJson       As Object    // Json for report.
    Data cFilter            As Character // String of filter.
    Data lFilterOn          As Logical   // Flag of active filter.
    Data cSignerPost        As Character // String of position of the signatory
    Data cSignerName        As Character // String of the signer's fullname
    Data cFilialCode        As Character // String of branch code
    Data cGroupCode         As Character // String of group code
    Data cDate              As Character // String of date
    Data cNameReport        As Character // String of the name of the printed form
    Data cHeadTitlePage     As Character // String of the name of the printed form
    Data aPersonnelNumbers  As Array     // Array of personel numbers.
    Data nTypeEmp           As Numeric   // Agent type from parameters.

    Method New(aParameters, aFilter, cFilterExpression, cNameReport) Constructor
    Method AddContent(oJson)
    Method GetData()
    Method Get1Part()
    Method Get2Part()
    Method Get2Data()
    Method Get1Tab()
    Method GetWork(aRow)
    Method GetHistMoving(aData)
    Method GetDataEmployer()
    Method GetTitle(lPageBreak)
    Method GetPersonnelNumbers()
    Method GetTemplatate()
    Method GetViewReport()
    Method GetWorkerInfo()
    Method GetEmployerInfo()
    Method SortByName(aDataSRA)
    Method GetInfoCompany(nTypeEmp)
    Method GetInfoBranch()

EndClass


/*/
{Protheus.doc} SortByName(aDataSRA)

    This method sorted array of TN by name of employees and by filters.

    @type Method
    @params aDataSRA, Array, Array of employee data.
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return aResult, Array, Sorted and filtered employee data array
    @example oSTDRObject:SortByName(oSTDRObject:aPersonnelNumbers)
/*/
Method SortByName(aDataSRA) Class RuRHSTDRForm

    Local cQuery     As Character
    Local cTab       As Character
    Local oStatement As Object
    Local aResult    As Array
    Local aEmployee  As Array
    Local aArea      As Array

    DEFAULT cRot := Nil
    DEFAULT cProc := Nil

    aArea := GetArea()

    aResult := {}
    aEmployee := {}
    aEval(aDataSRA, {|X| Aadd(aEmployee, X[3])})

    cQuery := " SELECT SRA.RA_MAT, SRA.RA_FILIAL FROM " + RetSqlName("SRA") + " SRA " 
    cQuery += " WHERE "
    cQuery += " CONCAT(SRA.RA_MAT, SRA.RA_FILIAL) IN (?) "
    cQuery += " AND SRA.D_E_L_E_T_ = '' "
    cQuery += " ORDER BY SRA.RA_NOMECMP "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, aEmployee)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !(cTab)->(EOF())
        Aadd(aResult, {(cTab)->RA_MAT, (cTab)->RA_FILIAL, (cTab)->RA_MAT + (cTab)->RA_FILIAL})
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DbCloseArea())
    RestArea(aArea)

Return aResult


/*/
{Protheus.doc} GetWorkerInfo()

    This method builds a part with information about the employee.
    
    @type Method
    @params
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the employee.
    @example oSTDRObject:AddContent(oSTDRObject:GetWorkerInfo())
/*/
Method GetWorkerInfo() Class RuRHSTDRForm

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "title",
                "fontSize": 10
            },
            {
                "margin": [15, 9, 0, 0],
                "style": "normal9",
                "fontSize": 9
            },
            {
                "margin": [15, 2, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [130, 470],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["text"] := STR0001 // "Information about the work activity provided to the employee by the employer"
    oJson["content"][2]["text"] := STR0045 // "Employee Information:"
    oJson["content"][3]["table"]["body"][1, 1]["text"] := STR0046 //"Surname"
    oJson["content"][3]["table"]["body"][1, 2]["text"] := SRA->RA_PRISOBR
    oJson["content"][3]["table"]["body"][2, 1]["text"] := STR0047 //"Name"
    oJson["content"][3]["table"]["body"][2, 2]["text"] := SRA->RA_PRINOME
    oJson["content"][3]["table"]["body"][3, 1]["text"] := STR0048 //"Patronymic (if available)"
    oJson["content"][3]["table"]["body"][3, 2]["text"] := SRA->RA_SECNOME
    oJson["content"][3]["table"]["body"][4, 1]["text"] := STR0049 //"Date of birth"
    oJson["content"][3]["table"]["body"][4, 2]["text"] := "« " + CValToChar(Day(SRA->RA_NASC)) + " » " + StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(SRA->RA_NASC)) + " " + CValToChar(Year(SRA->RA_NASC))
    oJson["content"][3]["table"]["body"][5, 1]["text"] := STR0050 //"SNILS"
    oJson["content"][3]["table"]["body"][5, 2]["text"] := Transform(AllTrim(SRA->RA_CIC), GetSX3Cache("RA_CIC", "X3_PICTURE"))

Return oJson


/*/
{Protheus.doc} GetEmployerInfo()

    This method builds a part with information about the employer.
    
    @type Method
    @params
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the employer.
    @example oSTDRObject:AddContent(oSTDRObject:GetEmployerInfo())
/*/
Method GetEmployerInfo() Class RuRHSTDRForm

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()
    aData := ::GetDataEmployer()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [15, 9, 0, 0],
                "style": "normal9",
                "fontSize": 9
            },
            {
                "margin": [15, 2, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [150, 450],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["text"] := STR0051 // "Information about the employer:"
    oJson["content"][2]["table"]["body"][1, 1]["text"] := STR0052 // "Registration number in the PFR"
    oJson["content"][2]["table"]["body"][1, 2]["text"] := AllTrim(aData[1, 2]) // PFRREG
    oJson["content"][2]["table"]["body"][2, 1]["text"] := STR0053 // "Employer (name)"
    oJson["content"][2]["table"]["body"][2, 2]["text"] := AllTrim(aData[2, 2]) // FULLNAM
    oJson["content"][2]["table"]["body"][3, 1]["text"] := STR0054 // "INN"
    oJson["content"][2]["table"]["body"][3, 2]["text"] := AllTrim(aData[3, 2]) // INN
    oJson["content"][2]["table"]["body"][4, 1]["text"] := STR0055 // "KPP"
    oJson["content"][2]["table"]["body"][4, 2]["text"] := AllTrim(aData[4, 2]) // KPP

Return oJson


/*/
{Protheus.doc} GetDataEmployer()

    This method gets information about the employer.
    
    @type Method
    @params
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return aInfo, Array, Array with information about the employer.
    @example aData := ::GetDataEmployer()
/*/
Method GetDataEmployer() Class RuRHSTDRForm

    Local aInfo := Array(7,2)       As Array
    Local aEmpl := Array(8)         As Array
    Local nI                        As Numeric

    If AllTrim(::aFilter[1]) $ STR0044
        aEmpl := ::GetInfoBranch()
    Else
        Do case
            case AllTrim(::aFilter[1]) $ STR0041
                aEmpl := ::GetInfoCompany(4)
            case AllTrim(::aFilter[1]) $ STR0042
                aEmpl := ::GetInfoCompany(3)
            case AllTrim(::aFilter[1]) $ STR0043
                aEmpl := ::GetInfoCompany(2)
        Endcase
    EndIf
    If Len(aEmpl) <> 0
        For nI := 1 To Len(aEmpl)
            aInfo[nI, 2] := aEmpl[nI]
        Next nI
    EndIf

Return aInfo


/*/
{Protheus.doc} GetInfoBranch()

    This method gets information about the employer for branch from the configurator.
    
    @type Method
    @params
    @author alysenko
    @since 10.10.2023
    @version 12.1.33
    @return aBranchInfo, Array, Array with information about the employer (branch).
    @example aComp := ::GetInfoBranch()
/*/
Method GetInfoBranch() Class RuRHSTDRForm
    Local cBrQuery := ""            As Character
    Local oBrStatement := Nil       As Object
    Local aArea := GetArea()        As Array
    Local aBranchInfo := Array(7)   As Array
    Local aBrFilter     := {}       As Array
    Local cBrINN := ""              As Character
    Local nBr := 2                  As Numeric

    AFill(aBranchInfo, "")

    // Getting data about the structural unit selected in filters.
    DbSelectArea("XX8")
    XX8->(dbSetOrder(1))
    XX8->(dbGoTop())
    While !XX8->(Eof()) .AND. Len(aBrFilter) == 0
        If XX8_TIPO == '3' .AND. Alltrim(XX8_DESCRI) == Alltrim(::aFilter[2])
            aAdd( aBrFilter, {XX8->XX8_EMPR, XX8->XX8_UNID, XX8->XX8_CODIGO, XX8->XX8_GRPEMP} )
        EndIf
        XX8->(DbSkip())
    Enddo

    If Len(aBrFilter) > 0
        // Make SQL query.
        cBrQuery := " SELECT BR_COMPGRP, BR_COMPEMP, BR_COMPUNI, BR_BRANCH, BR_PFRREG, BR_FULLNAM, BR_KPP, BR_PHONENU, BR_EMAIL, BR_SUBORD "
        cBrQuery += " FROM SYS_BRANCH_L_RUS " 
        cBrQuery += " WHERE "
        cBrQuery += "     BR_COMPGRP = ? "
        cBrQuery += "     AND BR_COMPEMP = ? " 
        cBrQuery += "     AND BR_COMPUNI = ? " 
        cBrQuery += "     AND BR_BRANCH = ? " 
        cBrQuery += "     AND D_E_L_E_T_ = ' '"

        oBrStatement := FWPreparedStatement():New(cBrQuery)
        oBrStatement:SetString(1, ::cGroupCode)
        oBrStatement:SetString(2, Alltrim(aBrFilter[1, 1]))
        oBrStatement:SetString(3, Alltrim(aBrFilter[1, 2]))
        oBrStatement:SetString(4, Alltrim(aBrFilter[1, 3]))

        cTab := MPSysOpenQuery(oBrStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        If !(cTab)->(Eof())
            aBranchInfo[1] := Alltrim((cTab)->BR_PFRREG)    // PFR.
            aBranchInfo[2] := Alltrim((cTab)->BR_FULLNAM)   // Full name.
            aBranchInfo[4] := Alltrim((cTab)->BR_KPP)       // KPP.
            aBranchInfo[5] :=  Alltrim((cTab)->BR_PHONENU)  // Phone.
            aBranchInfo[6] :=  Alltrim((cTab)->BR_EMAIL)    // Email.
            aBranchInfo[7] :=  Alltrim((cTab)->BR_SUBORD)   // SUBORD.
        EndIf
        (cTab)->(DBCloseArea())

        // Since the branch does not have an INN, it is taken from the level of the structure higher in the hierarchy
        While cBrINN == "" .AND. nBr <= 4
            cBrINN := ::GetInfoCompany(nBr, aBrFilter)[3]
            nBr++
        EndDo
        aBranchInfo[3] := cBrINN     // INN. 

        If Type("oBrStatement") <> "U"
            oBrStatement:Destroy()
            FwFreeObj(oBrStatement)
        EndIf
    EndIf

    RestArea(aArea)

Return aBranchInfo


/*/
{Protheus.doc} GetInfoCompany(nTypeEmp)

    This method gets information for structural units from the configurator - for companies, groups of companies and business units.
    
    @type Method
    @params nTypeEmp, Numeric, agent type from parameters.
        nTypeEmp = 4 - Group company
        nTypeEmp = 3 - Company
        nTypeEmp = 2 - Buisness unit
    @params aBrCFil,  Array,   Array of data on the branch, the company over which you need to obtain.
    @author alysenko
    @since 09.10.2023
    @version 12.1.33
    @return aCompanyInfo, Array, Array with information about the employer.
    @example aComp := ::GetInfoCompany(4)
/*/
Method GetInfoCompany(nTypeEmp, aBrCFil) Class RuRHSTDRForm
    Local cQuery := ""  As Character
    Local oStatement := Nil As Object
    Local aArea := GetArea() As Array
    Local cCO_TIPO := "" As Character
    Local aCompanyInfo := {} As Array
    Local aEmplFilter     := {}     As Array
    Local cCondOfSub := ".F." As Character

    Default aBrCFil := {}

    // Defenition type of object like "sys_company_l_rus" style.
    If nTypeEmp == 4        // Group company.
        cCO_TIPO := "0"
        cCondOfSub := "XX8->XX8_CODIGO == aBrCFil[1, 4]"
    ElseIf nTypeEmp == 3    // Company.
        cCO_TIPO := "1"
        cCondOfSub := "XX8->XX8_GRPEMP == aBrCFil[1, 4] .AND. XX8->XX8_CODIGO == aBrCFil[1, 1]"
    ElseIf nTypeEmp == 2    // Buisness unit.
        cCO_TIPO := "2"
        cCondOfSub := "XX8->XX8_GRPEMP == aBrCFil[1, 4] .AND. XX8->XX8_EMPR == aBrCFil[1, 1] .AND. XX8->XX8_CODIGO == aBrCFil[1, 2]"
    EndIf

    aCompanyInfo := {"", "", "", ""}

    // Getting data about the structural unit selected in filters.
    DbSelectArea("XX8")
    XX8->(dbSetOrder(1))
    XX8->(dbGoTop())
    While !XX8->(Eof())
        If XX8->XX8_TIPO == cCO_TIPO .AND. Alltrim(XX8->XX8_DESCRI) == Alltrim(::aFilter[2])
            aAdd( aEmplFilter, {XX8->XX8_EMPR, XX8->XX8_UNID, XX8->XX8_CODIGO} )
        ElseIf AllTrim(::aFilter[1]) $ STR0044
            If XX8->XX8_TIPO == cCO_TIPO .AND. &(cCondOfSub)
                aAdd( aEmplFilter, {XX8->XX8_EMPR, XX8->XX8_UNID, XX8->XX8_CODIGO} )
            EndIf
        EndIf
        XX8->(DbSkip())
    Enddo

    If Len(aEmplFilter) > 0
        aCompanyInfo := {}
        // Make SQL query.
        cQuery := " SELECT CO_TIPO, CO_COMPGRP, CO_COMPEMP, CO_COMPUNI, CO_PFRREG, CO_FULLNAM, CO_INN, CO_KPP, CO_PHONENU, CO_EMAIL, CO_SUBORD "
        cQuery += " FROM SYS_COMPANY_L_RUS " 
        cQuery += " WHERE "
        cQuery += "     CO_TIPO = ? "
        cQuery += "     AND CO_COMPGRP = ? " 
        cQuery += "     AND CO_COMPEMP = ? " 
        cQuery += "     AND CO_COMPUNI = ? " 
        cQuery += "     AND D_E_L_E_T_ = ' '"

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, cCO_TIPO)
        oStatement:SetString(2, ::cGroupCode)
        oStatement:SetString(3, IIF( cCO_TIPO == "1", Alltrim(aEmplFilter[1, 3]), Alltrim(aEmplFilter[1, 1]) ) )
        oStatement:SetString(4, IIF( cCO_TIPO == "2", Alltrim(aEmplFilter[1, 3]), Alltrim(aEmplFilter[1, 2]) ) )

        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())

        While !(cTab)->(Eof())
            aAdd(aCompanyInfo, Alltrim((cTab)->CO_PFRREG))  // PFR.
            aAdd(aCompanyInfo, Alltrim((cTab)->CO_FULLNAM)) // Full name.
            aAdd(aCompanyInfo, Alltrim((cTab)->CO_INN))     // INN.
            aAdd(aCompanyInfo, Alltrim((cTab)->CO_KPP))     // KPP.
            aAdd(aCompanyInfo, Alltrim((cTab)->CO_PHONENU)) // Phone.
            aAdd(aCompanyInfo, Alltrim((cTab)->CO_EMAIL))   // Email.
            aAdd(aCompanyInfo, Alltrim((cTab)->CO_SUBORD))  // SUBORD.
            (cTab)->(DbSkip())
        EndDo

        (cTab)->(DBCloseArea())

        If Type("oStatement") <> "U"
            oStatement:Destroy()
            FwFreeObj(oStatement)
        EndIf
    EndIf

    RestArea(aArea)

Return aCompanyInfo


/*/
{Protheus.doc} Get1Part()

    This method builds the part before the table with information about the submission of applications and their filing date.

    @type Method
    @params
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSubs1_1 := oSTDRObject:Get1Part()
/*/
Method Get1Part() Class RuRHSTDRForm

    Local oJson As Object
    Local cJson As Character
    Local cDateSubm := '' As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [15, 3, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [400, 90, 100],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "fontSize": 2}, {"border": [false, false, false, false], "text": "", "fontSize": 2},
                            {"border": [false, false, false, false], "text": "", "fontSize": 7, "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "fontSize": 2}, {"border": [false, false, false, false], "text": "", "fontSize": 2},
                            {"border": [false, false, false, false], "text": "", "fontSize": 7, "alignment": "center"}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent
    
    cDateSubm := CValToChar(Day(::aParameters[1])) + ' ' + StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(::aParameters[1])) + ' ' + CValToChar(Year(::aParameters[1]))

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"] := STR0056 // "An application has been submitted for the continuation of the employment record"
    oJson["content"][1]["table"]["body"][2, 3]["text"] := "(" + STR0058 + ")" // "date of submission"
    oJson["content"][1]["table"]["body"][3, 1]["text"] := STR0057 // "An application has been submitted for the provision of information on employment"
    oJson["content"][1]["table"]["body"][4, 3]["text"] := "(" + STR0058 + ")" // "date of submission"
    oJson["content"][1]["table"]["body"][3, 3]["text"] := IIF(cDateSubm == "0  0", "", cDateSubm)

Return oJson


/*/
{Protheus.doc} Get2Part()

    This method creates a part after the table for the signature of the signatory.

    @type Method
    @params
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return oJson, Object, Json with information for the signature of the signatory.
    @example oSubs2_1 := oSTDRObject:Get2Part()
/*/
Method Get2Part() Class RuRHSTDRForm

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [15, 9, 0, 0],
                "style": "normal",
                "fontSize": 7,
                "table": {
                    "width": "100%",
                    "widths": [170, 10, 100, 150, 200],
                    "body": [ 
                        [
                            {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "left"}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"] := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, ::aParameters[2]) // "Position of the authorized person"
    oJson["content"][1]["table"]["body"][1, 5]["text"] := ::cSignerName // "Decryption of the signature" StaticCall(RU07R06RUS, RU07R0602_GetFullNameOfSignature, ::aParameters[2])
    oJson["content"][1]["table"]["body"][2, 1]["text"] := "(" + STR0072 + ")" // "Position of the authorized person"
    oJson["content"][1]["table"]["body"][2, 3]["text"] := "(" + STR0073 + ")" // "Signature"
    oJson["content"][1]["table"]["body"][2, 5]["text"] := "(" + STR0074 + ")" // "Decryption of the signature"
    oJson["content"][1]["table"]["body"][3, 4]["text"] := STR0075 // "M.P. (if available)"
    oJson["content"][1]["table"]["body"][3, 5]["text"] := STR0076 // "For electronic transmission, the document is signed with a qualified electronic signature of an authorized person"

Return oJson


/*/
{Protheus.doc} Get2Data()

    This method creates a part after the table for the date of creation/signing of the STD-R.

    @type Method
    @params
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return oJson, Object, Json with information for the date of creation/signing of the STD-R.
    @example oSubs2_2 := oSTDRObject:Get2Data()
/*/
Method Get2Data() Class RuRHSTDRForm

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [15, 0, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [7, 15, 7, 70, 7, 40, 7],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": "", "fontSize": 7, "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"] := "«"
    oJson["content"][1]["table"]["body"][1, 2]["text"] := CValToChar(Day(Date()))
    oJson["content"][1]["table"]["body"][1, 3]["text"] := "»"
    oJson["content"][1]["table"]["body"][1, 4]["text"] := StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(Date()))
    oJson["content"][1]["table"]["body"][1, 6]["text"] := CValToChar(Year(Date()))
    oJson["content"][1]["table"]["body"][1, 7]["text"] := STR0077 // "y."
    oJson["content"][1]["table"]["body"][2, 4]["text"] := STR0078 // "(date)"

Return oJson


/*/
{Protheus.doc} GetTitle(lPageBreak)

    This method builds rows on top of a sheet with information about the application.

    @type Method
    @params lPageBreak, Logical, Page break befor or not.
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the application.
    @example oSTDRObject:AddContent(oSTDRObject:GetTitle(lPageBreak))
/*/
Method GetTitle(lPageBreak) Class RuRHSTDRForm

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [15, 9, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [60, 470, 230],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, true], "text": ""},
                            {"border": [false, false, false, false], "text": "", "alignment": "left"},
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    If lPageBreak
        oJson["content"][1]["pageBreak"] := "before"
    EndIf
    oJson["content"][1]["table"]["body"][1, 3]["text"] := STR0012 + CRLF + STR0013 + CRLF + STR0014 // "Attachment ? 1" 
                        // + "to the Order of the Ministry of Labor and Social Protection of the Russian Federation"
                        // + "? 713n dated November 10, 2022"
    oJson["content"][1]["table"]["body"][2, 1]["text"] := STR0011 // "STD-R Form"

Return oJson


/*/
{Protheus.doc} GetData()

    This method get employee data for table.

    @type Method
    @params
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return oJson, Object, Json with employee data for table.
    @example aData := ::GetData()
/*/
Method GetData() Class RuRHSTDRForm

    Local aData    As Array
    Local aRow     As Character
    Local cTemp    As Character

    aData := {}
    
    If SRA->RA_ADMISSA <= ::aParameters[1] .AND. DToC(SRA->RA_ADMISSA) != "  .  .    "
        aRow := Array(10)
        AFill(aRow, "")
        aRow[1] := aRow[7] := DToC(SRA->RA_ADMISSA)
        aRow[2] := STR0087
        aRow := ::GetWork(aRow)
        Aadd(aData, aRow)
    ElseIf DToC(::aParameters[1]) == "  .  .    "
        aRow := Array(10)
        AFill(aRow, "")
        aRow[1] := aRow[7] := DToC(SRA->RA_ADMISSA)
        aRow[2] := STR0087
        aRow := ::GetWork(aRow)
        Aadd(aData, aRow)
    EndIf
    
    aData := ::GetHistMoving(aData)

    If SRA->RA_DEMISSA <= ::aParameters[1] .AND. DToC(SRA->RA_DEMISSA) != "  .  .    "
        aRow := Array(10)
        AFill(aRow, "")
        aRow[1] := aRow[7] := DToC(SRA->RA_DEMISSA)
        aRow[2] := STR0089
        aRow := ::GetWork(aRow)
        cTemp := FDesc("SRG", SRA->RA_MAT + DToS(SRA->RA_DEMISSA), "RG_TIPORES",, xFilial("SRG"), RetOrdem("SRG", "RG_FILIAL+RG_MAT+DTOS(RG_DATADEM)"))
        cTemp := Iif(Empty(cTemp), "", FDescRCC("S043", cTemp, 1, 2, 70, 20) + FDescRCC("S043", cTemp, 1, 2, 3, 30))
        aRow[5] := cTemp
        Aadd(aData, aRow)
    ElseIf DToC(::aParameters[1]) == "  .  .    "
        aRow := Array(10)
        AFill(aRow, "")
        aRow[1] := aRow[7] := DToC(SRA->RA_DEMISSA)
        aRow[2] := STR0089
        aRow := ::GetWork(aRow)
        cTemp := FDesc("SRG", SRA->RA_MAT + DToS(SRA->RA_DEMISSA), "RG_TIPORES",, xFilial("SRG"), RetOrdem("SRG", "RG_FILIAL+RG_MAT+DTOS(RG_DATADEM)"))
        cTemp := Iif(Empty(cTemp), "", FDescRCC("S043", cTemp, 1, 2, 70, 20) + FDescRCC("S043", cTemp, 1, 2, 3, 30))
        aRow[5] := cTemp
        Aadd(aData, aRow)
    EndIf

Return aData


/*/
{Protheus.doc} GetWork(aRow)

    This method get data for 4, 5 and 7 column.

    @type Method
    @params aRow, Array, Current data-row
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return aRow, Array, Array with data about employee's work for 4, 5 and 7 column.
    @example aRow := ::GetWork(aRow)
/*/
Method GetWork(aRow) Class RuRHSTDRForm

    Local lMHEmpl  As Character
    Local aSQ3Area As Array
    Local cTemp    As Character
    Local nLenStr  As Numeric
    Local lSeek    As Logical
    Local cBrFil   As Character
    Local cCodeFunc As Character

    aSQ3Area := SQ3->(GetArea())
    nLenStr := 24
    lMHEmpl := SRA->RA_CATFUNC $ "MH"
    lSeek := .F.
    cBrFil := xFilial("SQ3")
    cCodeFunc := ""

    aRow[4] := Iif(Empty(AllTrim(aRow[4])), SRA->RA_CARGO, aRow[4])
    aRow[8] := Iif(Empty(AllTrim(aRow[8])), SRA->RA_FILIAL, aRow[8])
    aRow[9] := Iif(Empty(AllTrim(aRow[9])), SRA->RA_CC, aRow[9])
    aRow[10] := Iif(Empty(AllTrim(aRow[10])), SRA->RA_DEPTO, aRow[10])

    If !Empty(AllTrim(aRow[4])) .And. !Empty(AllTrim(aRow[9]))
        DBSelectArea("SQ3")
        SQ3->(DBSetOrder(RetOrdem("SQ3", "Q3_FILIAL+Q3_CARGO+Q3_CC")))
        lSeek := SQ3->(DBSeek(cBrFil + aRow[4] + aRow[9]))
        If lSeek .Or. SQ3->(DBSeek(cBrFil + aRow[4]))
            cTemp := Iif(lMHEmpl, STR0079 + " " + AllTrim(SQ3->Q3_DESCSUM), "") // "Position:"
            aRow[3] := cTemp
            If lMHEmpl .And. !Empty(AllTrim(SQ3->Q3_RGWGRP + SQ3->Q3_CTGCD))
                cTemp := STR0080 + " " + AllTrim(SQ3->Q3_RGWGRP) + "," + AllTrim(SQ3->Q3_CTGCD) // "Category:
                aRow[3] += cTemp
            EndIf
            cCodeFunc := SQ3->Q3_OKZ
        EndIf
        If lMHEmpl
            cTemp := CRLF + STR0081 + " " + AllTrim(FDesc("SRJ", SRA->RA_CODFUNC, "RJ_DESC", TamSX3("RJ_DESC"), aRow[8])) // "Labor function:"
            aRow[3] += cTemp
            cTemp := CRLF + STR0082 + " " + AllTrim(FDesc("SQB", aRow[10], "QB_DESCRIC")) // "Structural subdivision:"
            aRow[3] += cTemp
        EndIf
        SQ3->(DBCloseArea())
        aRow[6] := STR0015
    EndIf

    SQ3->(RestArea(aSQ3Area))

    aRow[8] := aRow[9] := aRow[10] := " "
    aRow[4] := cCodeFunc

Return aRow


/*/
{Protheus.doc} GetHistMoving(aData)

    This method get data from gpea180 (SRE) for report.

    @type Method
    @params aData, Array, Current data-array.
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return aData, Array, Array of data.
    @example aData := ::GetHistMoving(aData)
/*/
Method GetHistMoving(aData) Class RuRHSTDRForm

    Local aArea      As Array
    Local aRCLArea      As Array
    Local aSRJArea      As Array
    Local aHist      As Array
    Local lIsFirst   As Logical
    Local nCount    As Numeric

    Local cQuery     As Character
    Local cTab       As Character
    Local oStatement As Object

    lIsFirst := .T.
    aRCLArea := RCL->(GetArea())
    aSRJArea := SRJ->(GetArea())

    aArea := GetArea()
    cQuery := " SELECT SRE.RE_DATA, SRE.RE_POSTOP, SRE.RE_POSTOD, SRE.RE_CCD, SRE.RE_CCP, SRE.RE_DEPTOD, SRE.RE_DEPTOP, SRE.RE_FILIALD, SRE.RE_FILIALP FROM " + RetSqlName("SRE") + " SRE " 
    cQuery += " WHERE "
    cQuery += " SRE.RE_MATP = ? "
    cQuery += " AND SRE.RE_DATA < ? "
    cQuery += " AND SRE.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY SRE.RE_DATA "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, SRA->RA_MAT)
    oStatement:SetString(2, DToS(::aParameters[1]))

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DbSelectArea("RCL")
    DbSelectArea("SRJ")
    RCL->(DbGoTop())
    SRJ->(DbGoTop())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    nCount := 0
    While !(cTab)->(EOF())
        If lIsFirst
            lIsFirst := .F.
            Posicione("RCL", RetOrdem("RCL", "RCL_FILIAL+RCL_POSTO"), Padr((cTab)->RE_FILIALD, len(xFilial("RCL")), " ") + (cTab)->RE_POSTOD, "RCL_CARGO")
            aHist := ::GetWork({DToC(SToD((cTab)->RE_DATA)), STR0088, "", RCL->RCL_CARGO, "", "", DToC(SToD((cTab)->RE_DATA)), Padr((cTab)->RE_FILIALD, len(xFilial("RCL")), " "), (cTab)->RE_CCD, (cTab)->RE_DEPTOD})
            aData[1, 3] := aHist[3]
            nCount += 1
            aData[nCount, 4] := FDesc("SRJ", RCL->RCL_FUNCAO, "RJ_CBO",, RCL->RCL_FILIAL, RetOrdem("SRJ", "RJ_FILIAL+RJ_FUNCAO"))
        EndIf
        Posicione("RCL", RetOrdem("RCL", "RCL_FILIAL+RCL_POSTO"), Padr((cTab)->RE_FILIALP, len(xFilial("RCL")), " ") + (cTab)->RE_POSTOP, "RCL_CARGO")
        Aadd(aData, ::GetWork({DToC(SToD((cTab)->RE_DATA)), STR0088, "", RCL->RCL_CARGO, "", "", DToC(SToD((cTab)->RE_DATA)), Padr((cTab)->RE_FILIALP, len(xFilial("RCL")), " "), (cTab)->RE_CCP, (cTab)->RE_DEPTOP}))
        nCount += 1
        aData[nCount, 4] := FDesc("SRJ", RCL->RCL_FUNCAO, "RJ_CBO",, RCL->RCL_FILIAL, RetOrdem("SRJ", "RJ_FILIAL+RJ_FUNCAO"))
        (cTab)->(DBSkip())
    EndDo

    (cTab)->(DbCloseArea())
    FwFreeObj(oStatement)
    SRJ->(RestArea(aSRJArea))
    RCL->(RestArea(aRCLArea))
    RestArea(aArea)

Return aData


/*/
{Protheus.doc} AddContent(oJson)

    This method add elemnts from content Json object to general json in SELF.

    @type Method
    @params oJson, Object, Json object with content-item.
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return lRet, Logical, .T. If success added item, .F. - Content is empty or not exist
    @example oSTDRObject:AddContent(oSubs1_1)
/*/
Method AddContent(oJson) Class RuRHSTDRForm

    Local nX   As Numeric
    Local lRet As Logical

    lRet := .F.
    If !::oGeneralJson:HasProperty("content")
        ::oGeneralJson["content"] := {}
    EndIf
    If oJson:HasProperty("content")
        If ValType(oJson["content"]) == "A"
            For nX := 1 To Len(oJson["content"])
                lRet := .T.
                Aadd(::oGeneralJson["content"], oJson["content"][nX])
            Next nX
        EndIf
    EndIf

Return lRet


/*/
{Protheus.doc} New(aParameters, cFilterExpression, cNameReport)

    Default constructor.

    @type Method
    @params aParameters, Array,     Array of parameters from pergunte.
    @params aFilter,     Array,     Array of filter.
    @params cFilter,     Character, Expression for filter (from parameters).
    @params cNameReport, Character, Name of report.
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return RuRHSTDRForm, Object, RuRHSTDRForm instance.
    @example oSTDRObject := RuRHSTDRForm():New(aParam, aFilter, RU07R2006_GetFilterStr(aFilter), NAME_OF_PROGRAM)
/*/
Method New(aParameters, aFilter, cFilterExpression, cNameReport) Class RuRHSTDRForm

    DEFAULT cNameReport := "RU07R20RUS"

    Self:aParameters := AClone(aParameters)
    Self:aFilter := AClone(aFilter)
    Self:cFilter := cFilterExpression
    Self:cNameReport := cNameReport
    Self:cFilialCode := cFilAnt
    Self:cGroupCode := cEmpAnt
    Self:cHeadTitlePage := ""

    If !Empty(::cFilter)
        ::lFilterOn := .T.
        ::aPersonnelNumbers := ::GetPersonnelNumbers()
    Else
        ::lFilterOn := .F.
        ::aPersonnelNumbers := {}
    EndIf

Return Self


/*/
{Protheus.doc} GetPersonnelNumbers()

    Forms an array with personnel numbers of employees who meet the conditions in the filter.

    @type Method
    @params 
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return aNumbers, Array, Array of periods in format 'YYYYMM' ordered.
    @example ::aPersonnelNumbers := ::GetPersonnelNumbers()
/*/
Method GetPersonnelNumbers() Class RuRHSTDRForm

    Local aNumbers     As Array
    Local aArea        As Array
    Local oStatement   As Object
    Local cQuery       As Character
    Local cTab         As Character

    aNumbers := {}
    aArea := GetArea()

    cQuery := " SELECT RA_MAT AS EMPLOYNUM, RA_FILIAL AS FILIAL FROM " +  RetSQLName("SRA") + " WHERE "
    If ::lFilterOn
        cQuery += ::cFilter
        cQuery += " AND "
    EndIf
    cQuery += " D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        aAdd(aNumbers, {(cTab)->EMPLOYNUM, (cTab)->FILIAL, (cTab)->EMPLOYNUM + (cTab)->FILIAL})
        (cTab)->(DbSkip())
    EndDo

    aSort(aNumbers, , , {|X, Y| X[1] < Y[1] .Or. (X[1] == Y[1] .And. X[2] < Y[2])})

    (cTab)->(DbCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return aNumbers


/*/
{Protheus.doc} GetViewReport()

    This method get Json for All report and send it to prf-maker. 

    @type Method
    @params 
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return lResult, Logical, The data has been successfully submitted for display.
    @example oSTDRObject:GetViewReport()
/*/
Method GetViewReport() Class RuRHSTDRForm

    Local lResult := .T.  As Logical
    Local cJson           As Character
    Local cOptions        As Character
    Local oData           As Object
    Local oOptions        As Object


    oData := ::GetTemplatate()

    MsProcTxt(STR0083) // "Building a complete JSON."

    oData["content"] := Iif(ValType(::oGeneralJson) != 'U', ::oGeneralJson["content"], {})

    If lResult

        oOptions := Ru99x50_01_GetOptionsTemplate()
        oOptions['showSidebarButton'] := .F.

        cJson := oData:ToJson()
        cOptions := oOptions:ToJson()

        //Calls library with FWCALLAPP
        ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions, ::cNameReport)

    Else
    // "Error generating JSON" "Could not generate Json for output. Stage:" "Send to PDF-Maker"
        Help(,,STR0085,, STR0086 + CRLF + '"' + STR0084 + '"', 1, 0)
    EndIf

    FwFreeObj(oData)

Return lResult


/*/
{Protheus.doc} Get1Tab()

    This method biuld table with employee's work activity data.

    @type Method
    @params 
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return oJson, Object, Json with employee's work activity data.
    @example oTabs1_1 := oSTDRObject:Get1Tab()
/*/
Method Get1Tab() Class RuRHSTDRForm

    Local oJson As Object
    Local aRow  As Array
    Local cJson As Character
    Local nX    As Numeric
    Local nY    As Numeric
    Local aData As Array
    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [15, 9, 0, 0],
                "style": "normal",
                "fontSize": 7,
                "alignment": "center",
                "table": {
                    "margin": [0, 0, 0, 0],
                    "width": "100%",
                    "widths": [30, 50, 70, 160, 75, 150, 50, 40, 40, 50],
                    "body": [ 
                        [
                            {"rowSpan": 3, "text": ""}, {"colSpan": 8, "text": ""}, {}, {}, {}, {}, {}, {}, {}, {"rowSpan": 3, "text": ""}
                        ],
                        [
                            {}, {"rowSpan": 2, "text": ""}, {"rowSpan": 2, "text": ""}, {"colSpan": 3, "text": ""},{}, {},
                            {"colSpan": 3, "text": ""}, {}, {}, {}
                        ],
                        [
                            {},{},{}, {"text": ""}, {"text": ""}, {"text": ""},
                            {"text": ""}, {"text": ""}, {"text": ""}, {}
                        ],
                        [
                            {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1,  1]["text"] := STR0059 // "?? p/p"
    oJson["content"][1]["table"]["body"][1,  2]["text"] := STR0060 // "Information about employment"
    oJson["content"][1]["table"]["body"][2,  2]["text"] := STR0062 // "Date (number, month, year) of admission, transfer, dismissal"
    oJson["content"][1]["table"]["body"][2,  3]["text"] := STR0063 // "Information about admission, transfer, dismissal"
    oJson["content"][1]["table"]["body"][2,  4]["text"] := STR0061 // "Name"
    oJson["content"][1]["table"]["body"][3,  4]["text"] := STR0064 // "Work function (position, profession, specialty, qualification, specific type of assigned work), structural unit "
    oJson["content"][1]["table"]["body"][3,  5]["text"] := STR0065 // "Code of the function being performed (if available)" 
    oJson["content"][1]["table"]["body"][3,  6]["text"] := STR0066 // "Reasons for dismissal, paragraph, part of the article, article of the Labor Code of the Russian Federation, federal law"
    oJson["content"][1]["table"]["body"][2,  7]["text"] := STR0067 // "Basis"
    oJson["content"][1]["table"]["body"][3,  7]["text"] := STR0068 // "Name of the document"
    oJson["content"][1]["table"]["body"][3,  8]["text"] := STR0069 // "Date"
    oJson["content"][1]["table"]["body"][3,  9]["text"] := STR0070 // "Number of the document"
    oJson["content"][1]["table"]["body"][1, 10]["text"] := STR0071 // "The sign of cancellation of the record of information about admission, transfer, dismissal"

    For nX := 1 To 10
        oJson["content"][1]["table"]["body"][4,  nX]["text"] := CValToChar(nX)
    Next nX

    aData := ::GetData()

    For nX := 1 To Len(aData)
        aRow := Array(10)
        For nY := 1 To Len(aRow)
            aRow[nY] := JsonObject():New()
        Next nY

        aRow[1]["text"] := CValToChar(nX)
        For nY := 1 To Len(aData[nX]) - 1
            aRow[1 + nY]["text"] := aData[nX, nY]
        Next nY

        Aadd(oJson["content"][1]["table"]["body"], aRow)
    Next nX

Return oJson


/*/
{Protheus.doc} GetTemplatate()

    This method biuld empty templatate for report and Json without content.

    @type Method
    @params 
    @author alysenko
    @since 01.09.2023
    @version 12.1.33
    @return oJson, Object, Json for report.
    @example oData := ::GetTemplatate()
/*/
Method GetTemplatate() Class RuRHSTDRForm

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "pageSize": "A4",
        "pageOrientation": "landscape",
        "pageMargins": [0, 0, 0, 0],
        "styles": {
            "title": {
                "fontSize": 10,
                "bold": true,
                "font": "Arial",
                "alignment": "center"
            },
            "normal": {
            "font": "Arial",
                "fontSize": 9,
                "bold": false
            },
            "normal9": {
            "font": "Arial",
                "fontSize": 9,
                "bold": true
            }
        },
        "content": [
            {
                "margin": [15, 9, 0, 0],
                "style": "title"
            }
        ]
    }
    EndContent
    oJson:FromJson(cJson)

Return oJson
