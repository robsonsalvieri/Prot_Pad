#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RU07R04.CH"

#Define NDFL_RATE_13 "13"
#Define NDFL_RATE_15 "15"
#Define NDFL_RATE_30 "30"
#Define TYPE_COMPANY_CODE "1"
#Define BLOCK_5_LENGTH 8
#Define CONTINUE_TAX_DEDUCTION_CODE 1
#Define LEN_TAX_DEDUCTION_ARRAY_WITH_CONTINUES 4 // Array length with continued subtraction.


/*/
{Protheus.doc} RU07R04()
    Entry point to run the routine.
    Here the data is selected, filled and distributed according to the template.

    @type Function
    @params 
    @author iprokhorenko
    @since 2022/01/13
    @version 12.1.23
    @return 
    @example RU07R04())
/*/
Function RU07R04()

    Local lR13 As Logical
    Local lR15 As Logical
    Local lR30 As Logical
    Local cType As Char
    Local o2NDFL As Object

    Local cTN As Char
    Local cDate As Date

    Local Block_0 As Array
    Local Block_1 As Array
    Local Block_2 As Array
    Local Block_3 As Array
    Local Block_3_1 As Array
    Local Block_4 As Array
    Local Block_5 As Array

    Local dDateNow As Date

    Local nCount1 As Numeric
    Local aTMP As Array

    Local cNowDay As Char
    Local cNowMonth As Char
    Local cNowYear As Char

    Local aCompanyInfo As Array
    Local aTmpBlock4 As Array
    Local nI As Numeric
    Local nIndex As Numeric
    
    Pergunte('RU07R01DS',.T.)

    cTN := MV_PAR01
    cDate := MV_PAR02

    dDateNow := Date()

    cNowDay := IIf(Len(cValToChar(Day(dDateNow))) == 1, '0' + cValToChar(Day(dDateNow)), cValToChar(Day(dDateNow)))
    cNowMonth := IIf(Len(cValToChar(Month(dDateNow))) == 1, '0' + cValToChar(Month(dDateNow)), cValToChar(Month(dDateNow)))
    cNowYear := cValToChar(Year(dDateNow))

    Block_0 := {{cDate, cNowDay, cNowMonth, cNowYear}}

    o2NDFL := RU2NDFL():New(cTN, cDate)
    o2NDFL:GetData()

    lR13 := o2NDFL:lRate13
    lR15 := o2NDFL:lRate15
    lR30 := o2NDFL:lRate30

    // If the employee has no data, then a message is displayed that the report will not be generated.
    If lR13 .Or. lR15 .Or. lR30
        If lR30
            cType := NDFL_RATE_30
        ElseIf lR13
            cType := NDFL_RATE_13
        Else
            cType := NDFL_RATE_15
        EndIf

        aTMP := {}
        Block_1 := {}
        Block_2 := {}
        Block_4 := AClone(o2NDFL:a13TaxPayments)
        Block_5 := AClone(o2NDFL:aAllSumm13)
        Block_3 := AClone(o2NDFL:aIncome13)
        Block_3_1 := {}

        If lR30
            Block_4 := AClone(o2NDFL:a30TaxPayments)
            Block_5 := AClone(o2NDFL:aAllSumm30)
            Block_3 := AClone(o2NDFL:aIncome30)
        ElseIf lR13
            Block_4 := AClone(o2NDFL:a13TaxPayments)
            Block_5 := AClone(o2NDFL:aAllSumm13)
            Block_3 := AClone(o2NDFL:aIncome13)
        ElseIf lR15
            Block_4 := AClone(o2NDFL:a15TaxPayments)
            Block_5 := AClone(o2NDFL:aAllSumm15)
            Block_3 := AClone(o2NDFL:aIncome15)
        EndIf

        /* 
         * Set the arrays to default values (zero) so that if the arrays are empty, 
         * they will be processed successfully.
        */
        If ValType(Block_3) == "U"
            // Block_3 array values: "Period code", "Income code", "Income sum", "Deduction code", "Deduction sum".
            Block_3 := {{AllTrim(MV_PAR02) + "01", "0000", 0, "", 0}} // MV_PAR02 - Report year from parameters.
        EndIf

        If ValType(Block_4) == "U"
            // Block_4 array values: "Period code", "Deduction code", "Deduction sum".
            Block_4 := {{AllTrim(MV_PAR02) + "01", "000", 0}} // MV_PAR02 - Report year from parameters.
        EndIf

        If ValType(Block_5) == "U"
            /* Block_5 array values: 
             * 1 - "Total income"
             * 2 - "The tax base"
             * 3 - "The amount of tax calculated"
             * 4 - "Amount of fixed advance payments"
             * 5 - "Amount of tax withheld"
             * 6 - "The amount of tax transferred"
             * 7 - "Amount of tax withheld excessively by a withholding agent"
             * 8 - "The amount of tax not withheld by the withholding agent"
            */
            Block_5 := Array(BLOCK_5_LENGTH)
            aFill(Block_5, 0, 1, BLOCK_5_LENGTH)
        EndIf

        /* 
         * Getting information about company. 
         * This information added into Block_1.
         * Filling report header (Block_1) from aCompanyInfo:
         *  // 1 - INN.
         *  // 2 - KPP.
         *  // 3 - Full name.
         *  // 4 - IFNS code.
         *  // 5 - OKTMO.
         *  // 6 - Phone number.
         *  // 7 - Short name.
        */
        aCompanyInfo := o2NDFL:GetCompanyInfo(TYPE_COMPANY_CODE, FwXFilial("SRA"))
        Block_1 := {;
                        {Alltrim(aCompanyInfo[5]), Alltrim(aCompanyInfo[6]), Alltrim(aCompanyInfo[1]), Alltrim(aCompanyInfo[2])},;
                        {Alltrim(aCompanyInfo[7])},;
                        {''},;
                        {'', ''};
                }

        Block_2 := {;
                        {o2NDFL:cINN},;
                        {o2NDFL:cSurename, o2NDFL:cName, o2NDFL:cMiddleName},;
                        {o2NDFL:cTaxAgentStatusCode, ;
                        cValToChar(Day(STOD(o2NDFL:cBirthday))), ;
                        cValToChar(Month(STOD(o2NDFL:cBirthday))), ;
                        cValToChar(Year(STOD(o2NDFL:cBirthday))), ;
                        o2NDFL:cCitizenshipCode},;
                        {o2NDFL:cDocumentTypeCode, o2NDFL:cSeriesAndNumberDocument};
                    }
        
        aTMP := {{cType}}
        For nCount1 := 1 To Len(Block_3)
            Block_3[nCount1, 3] := RoundS(Block_3[nCount1, 3])
        Next
        aAdd(aTMP, Block_3)
        Block_3 := AClone(aTMP)

        If lR13 .And. lR15
            
            aTMP := {{NDFL_RATE_15}}
            Block_3_1 := AClone(o2NDFL:aIncome15)
            For nCount1 := 1 To Len(Block_3_1)
                Block_3_1[nCount1, 3] := RoundS(Block_3_1[nCount1, 3])
            Next
            aAdd(aTMP, Block_3_1)
            Block_3_1 := AClone(aTMP)
            
            For nCount1 := 1 To Len(o2NDFL:aAllSumm15)
                Block_5[nCount1] := Block_5[nCount1] + o2NDFL:aAllSumm15[nCount1]
            Next nCount1

            // Summarizing data on tax deductions.
            aTmpBlock4 := AClone(o2NDFL:a15TaxPayments)
            If ValType(aTmpBlock4) == "A" .And. ValType(Block_4) == "A"

                /*  You need to check for separable deductions in the month of exceeding the rate of 13%.
                 * 
                 *  You need to go through all the records of tax deductions.
                 *  Determine if there are divisions.
                 *  If there is, then sum them up, because the block for deductions the block is not divided into rates (declaration date 07/07/2023)
                */
                For nI := 1 To Len(aTmpBlock4)
                    /*
                     * Len(aTmpBlock4[nI]) == 4 - this is length of array line because this indicates 
                     * that the tax deduction is split in the month of exceeding the rate of 13%.
                     * 
                    */
                    If Len(aTmpBlock4[nI]) == LEN_TAX_DEDUCTION_ARRAY_WITH_CONTINUES
                        If aTmpBlock4[nI][4] == CONTINUE_TAX_DEDUCTION_CODE
                            nIndex := aScan(Block_4, {|x| x[1] == aTmpBlock4[nI][1] .And. x[2] == aTmpBlock4[nI][2] .And. x[4] == aTmpBlock4[nI][4]})

                            If nIndex > 0
                                Block_4[nIndex][3] += aTmpBlock4[nI][3]
                            EndIf
                        EndIf
                    EndIf
                Next nI

                // Clear temporary values.
                aTmpBlock4 := {}
            EndIf

        EndIf

        aTMP := {}
        For nCount1 := 1 To Len(Block_4)
            AAdd(aTMP, {Block_4[nCount1, 2], Block_4[nCount1, 3]})
        Next nCount1
        Block_4 := AClone(aTMP)

        /*
         * Block_5[5] - Amount of tax withheld. Added Round by RULOC-2205.
         * Block_5[6] - The amount of tax transferred. Added Round by RULOC-2205.
         *
         * Block_5 array values: 
         * Block[1] - "Total income"
         * Block[2] - "The tax base"
         * Block[3] - "The amount of tax calculated"
         * Block[4] - "Amount of fixed advance payments"
         * Block[5] - "Amount of tax withheld"
         * Block[6] - "The amount of tax transferred"
         * Block[7] - "Amount of tax withheld excessively by a withholding agent"
         * Block[8] - "The amount of tax not withheld by the withholding agent"
        */
        aTMP := {}
        aTMP := {;
                    {RoundS(Block_5[1]),   Round(Block_5[5], 0)},;
                    {RoundS(Block_5[2]),   Round(Block_5[6], 0)},;
                    {Round(Block_5[3], 0), Round(Block_5[7], 0)},;
                    {RoundS(Block_5[4]),   RoundS(Block_5[8])  };
                }
        Block_5 := AClone(aTMP)

        RU07R04_02(Block_0, Block_1, Block_2, Block_3, Block_3_1, Block_4, Block_5)
    Else
        MsgStop(STR0046, STR0045) // "No output data", "Error".
    EndIf

Return Nil


/*/
{Protheus.doc} RU07R04_02(aBlock0, aBlock1, aBlock2, aBlock3, aBlock3_1, aBlock4, aBlock5)
    Data sorting and distribution function.

    @type Function
    @params aBlock0 Array, array with data.
            aBlock1 Array, array with data.
            aBlock2 Array, array with data.
            aBlock3 Array, array with data.
            aBlock3_1 Array, array with data.
            aBlock4 Array, array with data.
            aBlock5 Array, array with data.
    @author iprokhorenko
    @since 2022/01/13
    @version 12.1.23
    @return 
    @example RU07R04_02(aBlock0, aBlock1, aBlock2, aBlock3, aBlock3_1, aBlock4, aBlock5)
/*/
Function RU07R04_02(aBlock0, aBlock1, aBlock2, aBlock3, aBlock3_1, aBlock4, aBlock5)
    Local oData As Object
    Local cJson As Char
    Local aData As Array
    Local oOptions As Object
    Local cShift As Char

    oData := GetTemplate(aBlock3, aBlock3_1)

    If Len(aBlock3_1) > 1 
        cShift := '2'
    Else
        cShift := '1'
    EndIf

    aData := AClone(aBlock0)
    oData := SetData('0', aData, @oData, cShift)

    aData := AClone(aBlock1)
    oData := SetData('1', aData, @oData, cShift)

    aData := AClone(aBlock2)
    oData := SetData('2', aData, @oData, cShift)

    aData := AClone(aBlock3)
    oData := SetData('3', aData, @oData, cShift)

    If Len(aBlock3_1) > 1
        aData := AClone(aBlock3_1)
        oData := SetData('3_1', aData, @oData, cShift)
    EndIf

    aData := AClone(aBlock4)
    oData := SetData('4', aData, @oData, cShift)

    aData := AClone(aBlock5)
    oData := SetData('5', aData, @oData, cShift)

    SetStrings(@oData, cShift)

    cJson := oData:ToJson()

    //Gets Options for PDF template
    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.

    cOptions := oOptions:ToJson()
    //Calls library with FWCALLAPP
    ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions,'RU07R04')

Return

/*/
{Protheus.doc} SetData(cSection, aData, oData, cShift)
    Sets data in JSON File.
    Data is set by section, for each section there is an array for each line, and each of the lines has the fields to be filled in.

    @type function
    @params cSection Char, the number of the section in which the data is entered.
            aData Array, array with data.
            oData Object, contains a template construct.
            cShift Char, Template Offset Parameter.
            
    @author Bruno Sobieski
    @since 7/27/2021
    @param cSection, character, Section Code
    @param aData, array, Data to fill section
    @param oData, object, Json object
    @return object, Object received with data inserted
/*/
Static Function SetData(cSection, aData, oData, cShift)
    Local nX As Numeric
    Local nCol As Numeric
    Local aEmptyLine As Array
    Local nLen2 As Numeric

    Do Case
    Case cSection == "0"
        // Fill in the report period
        oData['content'][4]["columns"][1]["table"]["body"][1][2]["text"] := aData[1][1]
        oData['content'][4]["columns"][1]["table"]["body"][1][4]["text"] := aData[1][2]
        oData['content'][4]["columns"][1]["table"]["body"][1][6]["text"] := aData[1][3]
        oData['content'][4]["columns"][1]["table"]["body"][1][8]["text"] := aData[1][4]
    Case cSection == "1"
        // Fill in information about the company
        oData['content'][6]["table"]["body"][1][2]["text"] := aData[1][1]
        oData['content'][6]["table"]["body"][1][4]["text"] := aData[1][2]
        oData['content'][6]["table"]["body"][1][6]["text"] := aData[1][3]
        oData['content'][6]["table"]["body"][1][8]["text"] := aData[1][4]
        oData['content'][7]["table"]["body"][1][2]["text"] := aData[2][1]
        oData['content'][8]["table"]["body"][1][2]["text"] := aData[3][1]
        oData['content'][9]["table"]["body"][1][2]["text"] := aData[4][1]
        oData['content'][9]["table"]["body"][1][4]["text"] := aData[4][2]
    Case cSection == "2"
        // Fill in information about the employee
        oData['content'][11]["table"]["body"][1][2]["text"] := aData[1][1]
        oData['content'][12]["table"]["body"][1][2]["text"] := aData[2][1]
        oData['content'][12]["table"]["body"][1][4]["text"] := aData[2][2]
        oData['content'][12]["table"]["body"][1][6]["text"] := aData[2][3]
        oData['content'][13]["table"]["body"][1][2]["text"] := aData[3][1]
        oData['content'][13]["table"]["body"][1][4]["text"] := aData[3][2]
        oData['content'][13]["table"]["body"][1][6]["text"] := aData[3][3]
        oData['content'][13]["table"]["body"][1][8]["text"] := aData[3][4]
        oData['content'][13]["table"]["body"][1][10]["text"] := aData[3][5]
        oData['content'][14]["table"]["body"][1][2]["text"] := aData[4][1]
        oData['content'][14]["table"]["body"][1][4]["text"] := aData[4][2]

    Case cSection == "3"
        // Fill in the income data
        If Len(aData[2]) <= 4
            nLen2 := 2
        Else
            If Len(aData[2]) / 2 > Int(Len(aData[2]) / 2)
                nLen2 := Int(Len(aData[2]) / 2) + 1
            Else
                nLen2 := Len(aData[2]) / 2
            EndIf
        EndIf

        oData['content'][15]["table"]["body"][1][2]["text"] := aData[1][1]
        For nX := 1 To Min(Len(aData[2]), nLen2)
            oData['content'][16]["columns"][1]["table"]["body"][1 + nX] := aData[2][nX]
        Next
        For nX := nLen2 + 1 To Len(aData[2])
            oData['content'][16]["columns"][3]["table"]["body"][1 + nX - nLen2] := aData[2][nX]
        Next

    Case cSection == "3_1"
        // Fill in income data for a different interest rate
        If Len(aData[2]) <= 4
            nLen2 := 2
        Else
            If Len(aData[2]) / 2 > Int(Len(aData[2]) / 2)
                nLen2 := Int(Len(aData[2]) / 2) + 1
            Else
                nLen2 := Len(aData[2]) / 2
            EndIf
        EndIf

        oData['content'][17]["table"]["body"][1][2]["text"] := aData[1][1]
        For nX := 1 To Min(Len(aData[2]), nLen2)
            oData['content'][18]["columns"][1]["table"]["body"][1 + nX] := aData[2][nX]
        Next
        For nX := nLen2 + 1 To Len(aData[2])
            oData['content'][18]["columns"][3]["table"]["body"][1 + nX - nLen2] := aData[2][nX]
        Next

    Case cSection == "4"
        // Data about deductions
        aEmptyLine := Array(8)
        aEmptyLine := aFill(aEmptyLine, "")
        nCOl := 1
        
        If cShift == '2'
            For nX := 1 To Len(aData)
                If nCol == 9
                    AAdd(oData['content'][20]["table"]["body"], aEmptyLine)
                    nCol := 1
                Endif
                oData['content'][20]["table"]["body"][Len(oData['content'][20]["table"]["body"])][nCol++] := aData[nX, 1]
                oData['content'][20]["table"]["body"][Len(oData['content'][20]["table"]["body"])][nCol++] := aData[nX, 2]
            Next
        Else
            For nX := 1 To Len(aData)
                If nCol == 9
                    AAdd(oData['content'][18]["table"]["body"], aEmptyLine)
                    nCol := 1
                Endif
                oData['content'][18]["table"]["body"][Len(oData['content'][18]["table"]["body"])][nCol++] := aData[nX, 1]
                oData['content'][18]["table"]["body"][Len(oData['content'][18]["table"]["body"])][nCol++] := aData[nX, 2]
            Next
        EndIf

    Case cSection == "5"
        // General totals
        If cShift == '2'
            For nX := 1 To Len(aData)
                oData['content'][22]["table"]["body"][nX][2]["text"] := aData[nX, 1]
                oData['content'][22]["table"]["body"][nX][4]["text"] := aData[nX, 2]
            Next
        Else
            For nX := 1 To Len(aData)
                oData['content'][20]["table"]["body"][nX][2]["text"] := aData[nX, 1]
                oData['content'][20]["table"]["body"][nX][4]["text"] := aData[nX, 2]
            Next
        EndIf
        
    EndCase

Return oData


/*/
{Protheus.doc} GetTemplate(aBlock3, aBlock3_1)
    Gets an example tempalte based on NFDL HR Report. This is intended to be just an example
    Do not forget to check in your template variable sections (tables with variable amount of lines) and how spae will be filled in according to these variations
    On this Angualr object is currently supported only Arial FONT, if any other font needed, please implement on PDFMAKEFORMRU package in angular applications.

    You may validate format defined here in  pdfmake site playground
    @type function
    @params aBlock3 Array, array with data.
            aBlock3_1 Array, array with data.
    @author Bruno Sobieski
    @since 8/2/2021
    @return oData, JSON Object with PDF template according to pdfMake Documentation and with JSON-fn package syntax.
/*/
Static Function GetTemplate(aBlock3, aBlock3_1)
    Local cJson1 As Char
    Local cJson2 As Char
    Local cJson3 As Char
    Local cJsonTmp As Char
    Local cJson As Char
    Local oData := JsonObject():New()
    Local nLenArr as Numeric
    Local nX as Numeric

    BeginContent var cJson1
    {
        "pageSize": "A4",
        "pageMargins": [0, 0, 0, 0],
        "styles": {
            "subTitle": {
                "fontSize": 9.5,
                "font": "Arial",
                "bold": true
            },
            "title": {
                "fontSize": 10.5,
                "bold": true,
                "font": "Arial",
                "alignment": "center"
            },
            "header": {
            "font": "Arial",
                "fontSize": 7,
                "bold": false
            },
            "normal": {
            "font": "Arial",
                "fontSize": 8.5,
                "bold": false
            },
            "normalCentered": {
            "font": "Arial",
                "fontSize": 8.5,
                "alignment": "center"
            },
            "normalLeft": {
            "font": "Arial",
                "fontSize": 8.5,
                "alignment": "left"
            }
        },
        "content": [{
                "margin": [5, 18, 0, 0],
                "columns": [{
                        "text": "",
                        "width": "82%"
                    }, {
                        "width": "18%",
                        "stack": [
                            "Приложение № 4",
                            "к приказу ФНС России",
                            "от 15.10.2020 № ЕД-7-11/753@"

                        ],
                        "style": "header"
                    }

                ]
            }, {
                "margin": [5, 0, 0, 0],
                "text": "",
                "style": "subTitle"
            },
            {
                "text": "",
                "style": "title",
                "margin": [10, 10, 0, 0]
            }, {
                "margin": [200, 0],
                "columns": [{
                        "table": {
                            "body": [
                                [{
                                        "text": "",
                                        "border": [false, false, false, false],
                                        "style": "subTitle"
                                    }, {
                                        "text": "2021 S0[1]",
                                        "border": [false, false, false, true],
                                        "style": "subTitle"
                                    }, {
                                        "text": "",
                                        "border": [false, false, false, false],
                                        "style": "subTitle"
                                    }, {
                                        "text": "15 S0[2]",
                                        "border": [false, false, false, true],
                                        "style": "subTitle"
                                    }, {
                                        "text": ".",
                                        "border": [false, false, false, false],
                                        "style": "subTitle"
                                    }, {
                                        "text": "6 S0[3]",
                                        "border": [false, false, false, true],
                                        "style": "subTitle"
                                    }, {
                                        "text": ".",
                                        "border": [false, false, false, false],
                                        "style": "subTitle"
                                    }, {
                                        "text": "2021 S0[4]",
                                        "border": [false, false, false, true],
                                        "style": "subTitle"
                                    }
                                ]
                            ]
                        }
                    }
                ]
            }, {
                "text": "1. Данные о налоговом агенте",
                "style": "subTitle",
                "margin": [5, 40, 0, 0]
            }, {
                "margin": [0, 7, 10, 0],
                "layout": {
                    "hLinestyle": "function (i, node) {return { dash: {length: 1, space: 1 } } }","vLineColor": "function (i, node) {return 'black'}"
                    },
                "table": {
                    "width": "100%",
                    "widths": [60, "*", 50, "*", 30, "*", 30, "*"],
                    "body": [
                        [   {
                                "text": "Код по ОКТМО",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "left"
                            }, {
                                "text": "S1[1]",
                                "border": [false, false, false, true],
                                "style": "normal"
                            }, {
                                "text": "Телефон ",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "right"
                            }, {
                                "text": "S1[2]",
                                "border": [false, false, false, true],
                                "style": "normal"
                            }, {
                                "text": "ИНН",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "right"
                            }, {
                                "text": "S1[3]",
                                "border": [false, false, false, true],
                                "style": "normal"
                            }, {
                                "text": "КПП",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "right"
                            }, {
                                "text": "S1[4]",
                                "border": [false, false, false, true],
                                "style": "normal"
                            }
                        ]
                    ]
                }

            }, {
                "margin": [0, 0, 10, 0],
                "table": {
                    "width": "100%",
                    "widths": [80, "*"],
                    "body": [
                        [{
                                "text": "Налоговый агент",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "left"
                            }, 
                            {
                                "text": "ООО \"Арбатская контора по заготовке рогов и копыт\" ",
                                "border": [false, false, false, false],
                                "style": "normal"
                            }
                        ]
                    ]
                }
            }, {
                "margin": [0, 0, 10, 0],
                "layout": {
                    "hLinestyle":  {
                            "dash": {
                                "length": 1,
                                "space": 1
                            }
                        }
                    },
                    "table": {
                    "width": "100%",
                    "widths": [180, 20],
                    "body": [
                        [{
                                "text": "Форма реорганизации (ликвидация) (код)",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "left"
                            }, {
                                "text": "",
                                "border": [false, false, false, true],
                                "style": "normal"
                            }
                        ]
                    ]
                }
            }, 
            
            {
                "margin": [0, 0, 10, 0],
                "layout": {
                    "hLinestyle":  {
                            "dash": {
                                "length": 1,
                                "space": 1
                            }
                        }
                },
                    "table": {
                    "width": "100%",
                    "widths": [180, 60, 5, 60],
                    "body": [
                        [{
                                "text": "ИНН/КПП реорганизованной организации",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "left"
                            }, {
                                "text": "20701000001",
                                "border": [false, false, false, true],
                                "style": "normal"
                            }, {
                                "text": "/",
                                "border": [false, false, false, false],
                                "style": "normal"
                            }, {
                                "text": "",
                                "border": [false, false, false, true],
                                "style": "normal"
                            }
                        ]
                    ]
                }
            }, {
                "text": "2. Данные о физическом лице - получателе дохода",
                "style": "subTitle",
                "margin": [5, 10, 0, 0]
            }, {
                "margin": [0, 7, 10, 0],
                "layout": {
                            "hLinestyle":  {
                                    "dash": {
                                        "length": 1,
                                        "space": 1
                                    }
                                }
                        },
                    "table": {
                    "width": "100%",
                    "widths": [130, 70],
                    "body": [
                        [{
                                "text": "ИНН в Российской Федерации",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "left"
                            }, {
                                "text": "",
                                "border": [false, false, false, true],
                                "style": "normal"
                            }
                        ]
                    ]
                }
            },
            {
                "margin": [0, 0, 0, 0],
                "layout": {
                    "hLinestyle": 
                        { "dash": {
                                    "length": 1,
                                    "space": 1
                        }
                    }
                },
                "table": {
                    "width": "100%",
                    "widths": [40, 145, 35, 145, 65, 100],
                    "body": [
                        [{
                                "text": "Фамилия",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "left"
                            }, {
                                "text": "Королёв",
                                "border": [false, false, false, true],
                                "style": "normal",
                                "alignment": "center"
                            }, {
                                "text": "Имя",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "right"
                            }, {
                                "text": "Сергей",
                                "border": [false, false, false, true],
                                "style": "normal",
                                "alignment": "center"
                            }, {
                                "text": "Отчество * ",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "right"
                            }, {
                                "text": "Павлович",
                                "border": [false, false, false, true],
                                "style": "normal",
                                "alignment": "center"
                            }
                        ]
                    ]
                }
            }, {
                "margin": [0, 0, 0, 0],
                "layout": {
                            "hLinestyle":  {
                                    "dash": {
                                        "length": 1,
                                        "space": 1
                                    }
                                }
                        },
            
                "table": {
                    "width": "100%",
                    "widths": [120, 6, 80, 20, 5, 20, 5, 30, 125, 30],
                    "body": [
                        [{
                                "text": "Статус налогоплательщика",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "left"
                            }, {
                                "text": "1",
                                "border": [false, false, false, true],
                                "style": "normal",
                                "alignment": "center"
                            }, {
                                "text": "Дата рождения ",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "right"
                            }, {
                                "text": "15",
                                "border": [false, false, false, true],
                                "style": "normal",
                                "alignment": "center"
                            }, {
                                "text": ".",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "right"
                            }, {
                                "text": "06",
                                "border": [false, false, false, true],
                                "style": "normal",
                                "alignment": "center"
                            }, {
                                "text": ".",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "right"
                            }, {
                                "text": "1978",
                                "border": [false, false, false, true],
                                "style": "normal",
                                "alignment": "center"
                            }, {
                                "text": "Гражданство (код страны)",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "right"
                            }, {
                                "text": "643",
                                "border": [false, false, false, true],
                                "style": "normal",
                                "alignment": "center"
                            }
                        ]
                    ]
                }
            }, {
                "margin": [0, 0, 0, 0],
                "layout": {
                            "hLinestyle":  {
                                    "dash": {
                                        "length": 1,
                                        "space": 1
                                    }
                                }
                        },
                        "table": {
                    "width": "100%",
                    "widths": [180, 35, 125, 205],
                    "body": [
                        [{
                                "text": "Код документа, удостоверяющего личность:",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "left"
                            }, {
                                "text": "21",
                                "border": [false, false, false, true],
                                "style": "normal",
                                "alignment": "center"
                            }, {
                                "text": "Серия и номер документа",
                                "border": [false, false, false, false],
                                "style": "normal",
                                "alignment": "right"
                            }, {
                                "text": "68 02 444666",
                                "border": [false, false, false, true],
                                "style": "normal",
                                "alignment": "center"
                            }
                        ]
                    ]
                }
            }, 
            
            EndContent

            If Len(aBlock3[2]) <= 4
                nLenArr := 2
            Else
                If Len(aBlock3[2]) / 2 > Int(Len(aBlock3[2]) / 2)
                    nLenArr := Int(Len(aBlock3[2]) / 2) + 1
                Else
                    nLenArr := Len(aBlock3[2]) / 2
                EndIf
            EndIf

            If Len(aBlock3_1) > 1 
                BeginContent var cJson2
            
                {
                    "margin": [0, 7, 0, 0],
                        "layout": {
                                "hLinestyle":  {
                                        "dash": {
                                            "length": 1,
                                            "space": 1
                                        }
                                    }
                            },
                            "table": {
                        "width": "100%",
                        "widths": [170, 15, 15],
                        "body": [
                            [{
                                    "text": "3. Доходы, облагаемые по ставке :",
                                    "border": [false, false, false, false],
                                    "style": "subTitle",
                                    "alignment": "left"
                                }, {
                                    "text": "13",
                                    "border": [false, false, false, true],
                                    "style": "normal",
                                    "alignment": "center"
                                }, {
                                    "text": "%",
                                    "border": [false, false, false, false],
                                    "style": "normal",
                                    "alignment": "center"
                                }
                            ]
                        ]
                    }
                }, 
                
                {
                    "margin": [5, 7, 5, 0],
                    "columns": [{
                            "width": 285,
                            "style": "normalCentered",
                            "table": {
                                "width": "100%",
                                "widths": ["14.5%", "14.5%", "27.3%", "14.5%", "29.1%"],
                                "body": [
                                    ["Месяц", "Код дохода", "Сумма дохода", "Код вычета", "Сумма вычета"],

                                    EndContent

                                    For nX := 1 To nLenArr
                                        If nX == nLenArr
                                            cJson2 += '["  ", "", "", "", ""]'
                                        Else
                                            cJson2 += '["  ", "", "", "", ""],'
                                        EndIf
                                    Next

                                    BeginContent var cJsonTmp
                                ]
                            }
                        }, {
                            "text": "",
                            "width": 15
                        }, {
                            "width": 285,
                            "style": "normalCentered",
                            "table": {
                                "width": "100%",
                                "widths": ["14.5%", "14.5%", "27.3%", "14.5%", "29.1%"],
                                "body": [
                                    ["Месяц", "Код дохода", "Сумма дохода", "Код вычета", "Сумма вычета"],

                                    EndContent
                                    cJson2 += cJsonTmp

                                    cJsonTmp := ''

                                    For nX := 1 To nLenArr
                                        If nX == nLenArr
                                            cJson2 += '["  ", "", "", "", ""]'
                                        Else
                                            cJson2 += '["  ", "", "", "", ""],'
                                        EndIf
                                    Next
                                    
                                    BeginContent var cJsonTmp
                                ]
                            }
                        }
                    ]
                }, {
                    "margin": [0, 7, 0, 0],
                "layout": {
                                "hLinestyle":  {
                                        "dash": {
                                            "length": 1,
                                            "space": 1
                                        }
                                    }
                            },
                            "table": {
                        "width": "100%",
                        "widths": [170, 15, 15],
                        "body": [
                            [{
                                    "text": "3. Доходы, облагаемые по ставке :",
                                    "border": [false, false, false, false],
                                    "style": "subTitle",
                                    "alignment": "left"
                                }, {
                                    "text": "15",
                                    "border": [false, false, false, true],
                                    "style": "normal",
                                    "alignment": "center"
                                }, {
                                    "text": "%",
                                    "border": [false, false, false, false],
                                    "style": "normal",
                                    "alignment": "center"
                                }
                            ]
                        ]
                    }
                }, 
                
                {
                    "margin": [5, 7, 5, 0],
                    "columns": [{
                            "width": 285,
                            "style": "normalCentered",
                            "table": {
                                "width": "100%",
                                "widths": ["14.5%", "14.5%", "27.3%", "14.5%", "29.1%"],
                                "body": [
                                    ["Месяц", "Код дохода", "Сумма дохода", "Код вычета", "Сумма вычета"],
                                    EndContent

                                    cJson2 += cJsonTmp

                                    cJsonTmp := ''

                                    if Len(aBlock3_1[2]) <= 4
                                        nLenArr := 2
                                    Else
                                        If Len(aBlock3_1[2]) / 2 > Int(Len(aBlock3_1[2]) / 2)
                                            nLenArr := Int(Len(aBlock3_1[2]) / 2) + 1
                                        Else
                                            nLenArr := Len(aBlock3_1[2]) / 2
                                        EndIf
                                    EndIf

                                    For nX := 1 To nLenArr
                                        If nX == nLenArr
                                            cJson2 += '["  ", "", "", "", ""]'
                                        Else
                                            cJson2 += '["  ", "", "", "", ""],'
                                        EndIf
                                    Next

                                    BeginContent var cJsonTmp
                                ]
                            }
                        }, {
                            "text": "",
                            "width": 15
                        }, {
                            "width": 285,
                            "style": "normalCentered",
                            "table": {
                                "width": "100%",
                                "widths": ["14.5%", "14.5%", "27.3%", "14.5%", "29.1%"],
                                "body": [
                                    ["Месяц", "Код дохода", "Сумма дохода", "Код вычета", "Сумма вычета"],
                                    EndContent
                                    
                                    cJson2 += cJsonTmp

                                    cJsonTmp := ''

                                    For nX := 1 To nLenArr
                                        If nX == nLenArr
                                            cJson2 += '["  ", "", "", "", ""]'
                                        Else
                                            cJson2 += '["  ", "", "", "", ""],'
                                        EndIf
                                    Next

                                    BeginContent var cJsonTmp
                                ]
                            }
                        }
                    ]
                }, 
                EndContent

                cJson2 += cJsonTmp

            Else
                BeginContent var cJson2
            
                {
                    "margin": [0, 7, 0, 0],
                        "layout": {
                                "hLinestyle":  {
                                        "dash": {
                                            "length": 1,
                                            "space": 1
                                        }
                                    }
                            },
                            "table": {
                        "width": "100%",
                        "widths": [170, 15, 15],
                        "body": [
                            [{
                                    "text": "3. Доходы, облагаемые по ставке :",
                                    "border": [false, false, false, false],
                                    "style": "subTitle",
                                    "alignment": "left"
                                }, {
                                    "text": "13",
                                    "border": [false, false, false, true],
                                    "style": "normal",
                                    "alignment": "center"
                                }, {
                                    "text": "%",
                                    "border": [false, false, false, false],
                                    "style": "normal",
                                    "alignment": "center"
                                }
                            ]
                        ]
                    }
                }, 
                
                {
                    "margin": [5, 7, 5, 0],
                    "columns": [{
                            "width": 285,
                            "style": "normalCentered",
                            "table": {
                                "width": "100%",
                                "widths": ["14.5%", "14.5%", "27.3%", "14.5%", "29.1%"],
                                "body": [
                                    ["Месяц", "Код дохода", "Сумма дохода", "Код вычета", "Сумма вычета"],


                                    EndContent

                                    For nX := 1 To nLenArr
                                        If nX == nLenArr
                                            cJson2 += '["  ", "", "", "", ""]'
                                        Else
                                            cJson2 += '["  ", "", "", "", ""],'
                                        EndIf
                                    Next

                                    BeginContent var cJsonTmp
                                ]
                            }
                        }, {
                            "text": "",
                            "width": 15
                        }, {
                            "width": 285,
                            "style": "normalCentered",
                            "table": {
                                "width": "100%",
                                "widths": ["14.5%", "14.5%", "27.3%", "14.5%", "29.1%"],
                                "body": [
                                    ["Месяц", "Код дохода", "Сумма дохода", "Код вычета", "Сумма вычета"],

                                    EndContent
                                    cJson2 += cJsonTmp

                                    cJsonTmp := ''

                                    For nX := 1 To nLenArr
                                        If nX == nLenArr
                                            cJson2 += '["  ", "", "", "", ""]'
                                        Else
                                            cJson2 += '["  ", "", "", "", ""],'
                                        EndIf
                                    Next
                                    
                                    BeginContent var cJsonTmp
                                ]
                            }
                        }
                    ]
                }, 
                EndContent

                cJson2 += cJsonTmp

                cJsonTmp := ''
            EndIf

            BeginContent var cJson3
            {
                "text": "4. Стандартные, социальные и имущественные налоговые вычеты",
                "style": "subTitle",
                "margin": [5, 7, 0, 0]
            }, {
                "margin": [5, 7, 5, 0],
                "width": "100%",
                "style": "normalCentered",
                "table": {
                    "width": "100%",
                    "widths": ["8%", "17%", "8%", "17%", "8%", "17%", "8%", "17%"],
                    "body": [
                        ["Код вычета", "Сумма вычета", "Код вычета", "Сумма вычета", "Код вычета", "Сумма вычета", "Код вычета", "Сумма вычета"],
                        ["  ", "  ", "  ", "  ", "  ", "  ", "  ", "  "]
                    ]
                }
            }, {
                "text": "5. Общие суммы дохода и налога ",
                "style": "subTitle",
                "margin": [5, 17, 0, 0]
            }, {
                "margin": [5, 7, 5, 0],
                "width": "100%",
                "style": "normalLeft",
                "table": {
                    "width": "100%",
                    "widths": ["27%", "19%", "35%", "19%"],
                    "body": [
                        ["Общая сумма дохода", {"text":"", "style":"normalCentered"} , "Сумма налога удержанная",{"text":"", "style":"normalCentered"}],
                        ["Налоговая база", {"text":"", "style":"normalCentered"}, "Сумма налога перечисленная", {"text":"", "style":"normalCentered"}],
                        ["Сумма налога исчисленная", {"text":"", "style":"normalCentered"}, "Сумма налога, излишне удержанная налоговым агентом", {"text":"", "style":"normalCentered"}],
                        ["Сумма фиксированных авансовых платежей",  {"text":"", "style":"normalCentered"}, "Сумма налога, не удержанная налоговым агентом",  {"text":"", "style":"normalCentered"}]
                    ]
                }
            }, {
                "margin": [5, 25, 0, 0],
                "style": "normalCentered",
                "table": {
                    "width": "100%",
                    "widths": ["53%", "5%", "18%"],
                    "body": [
                        [{
                                "text": "налоговый агент (Ф.И.О.)",
                                "border": [false, true, false, false]
                            }, {
                                "text": " ",
                                "border": [false, false, false, false]
                            }, {
                                "text": "(подпись)",
                                "border": [false, true, false, false]
                            }
                        ]
                    ]
                }
            }, {
                "margin": [0, 14, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": ["32%"],
                    "body": [
                        [{
                                "text": "* Отчество указывается при наличии.",
                                "border": [false, true, false, false]
                            }
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    cJson := cJson1 + cJson2 + cJson3
    oData:FromJson(cJson)


Return oData


/*/
{Protheus.doc} RoundS(nValue)
    Custom rounding and line-to-line functions.

    @type function
    @params nValue Numeric, Parameter for rounding.
            
    @author iprokhorenko
    @since 2022/01/13
    @version 12.1.23
    @return 
/*/
Static Function RoundS(nValue)
    Local cResult As Char
    Local nPosPoint As Numeric

    cResult := cValToChar(NoRound(nValue, 2))
    If At(',', cResult, 1) == 0 .And. At('.', cResult, 1) == 0
        If cResult <> '0'
            cResult := cResult + '.00'
        EndIf
    Else
        If At(',', cResult, 1) == 0
            nPosPoint := At('.', cResult, 1)
        Else
            nPosPoint := At(',', cResult, 1)
        EndIf
        
        If Len(Substr(cResult, nPosPoint + 1, Len(cResult) - nPosPoint)) < 2 
            cResult := cResult + '0'
        EndIf
    EndIf

Return Alltrim(cResult)

/*/
{Protheus.doc} SetData(cSection, aData, oData, cShift)
    Sets data in JSON File.
    Fills the template with standard strings from the CH file.

    @type function
    @params oData Object, contains a template construct.
            cShift Char, Template Offset Parameter.
    @author iprokhorenko
    @since 2022/01/13
    @version 12.1.23
    @return 
/*/
Static Function SetStrings(oData,cShift)

    oData["content"][1]["columns"][2]["stack"][1] := STR0002
    oData["content"][1]["columns"][2]["stack"][2] := STR0003
    oData["content"][1]["columns"][2]["stack"][3] := STR0004
    oData['content'][2]["text"] := STR0001
    oData['content'][3]["text"] := STR0005
    oData['content'][4]["columns"][1]["table"]["body"][1][1]["text"] := STR0006
    oData['content'][4]["columns"][1]["table"]["body"][1][3]["text"] := STR0007
    oData['content'][5]["text"] := STR0008

    oData['content'][6]["table"]["body"][1][1]["text"] := STR0009
    oData['content'][6]["table"]["body"][1][3]["text"] := STR0010
    oData['content'][6]["table"]["body"][1][5]["text"] := STR0011
    oData['content'][6]["table"]["body"][1][7]["text"] := STR0012

    oData['content'][7]["table"]["body"][1][1]["text"] := STR0013
    oData['content'][8]["table"]["body"][1][1]["text"] := STR0014

    oData['content'][9]["table"]["body"][1][1]["text"] := STR0015
    oData['content'][10]["text"] := STR0016
    oData['content'][11]["table"]["body"][1][1]["text"] := STR0017

    oData['content'][12]["table"]["body"][1][1]["text"] := STR0018
    oData['content'][12]["table"]["body"][1][3]["text"] := STR0019
    oData['content'][12]["table"]["body"][1][5]["text"] := STR0020

    oData['content'][13]["table"]["body"][1][1]["text"] := STR0021
    oData['content'][13]["table"]["body"][1][3]["text"] := STR0022
    oData['content'][13]["table"]["body"][1][9]["text"] := STR0023

    oData['content'][14]["table"]["body"][1][1]["text"] := STR0024
    oData['content'][14]["table"]["body"][1][3]["text"] := STR0025

    oData['content'][15]["table"]["body"][1][1]["text"] := STR0026
    oData['content'][16]["columns"][1]["table"]["body"][1][1] := STR0027
    oData['content'][16]["columns"][1]["table"]["body"][1][2] := STR0028
    oData['content'][16]["columns"][1]["table"]["body"][1][3] := STR0029
    oData['content'][16]["columns"][1]["table"]["body"][1][4] := STR0030
    oData['content'][16]["columns"][1]["table"]["body"][1][5] := STR0031
    
    oData['content'][16]["columns"][3]["table"]["body"][1][1] := STR0027
    oData['content'][16]["columns"][3]["table"]["body"][1][2] := STR0028
    oData['content'][16]["columns"][3]["table"]["body"][1][3] := STR0029
    oData['content'][16]["columns"][3]["table"]["body"][1][4] := STR0030
    oData['content'][16]["columns"][3]["table"]["body"][1][5] := STR0031

    If cShift == '2'

        oData['content'][17]["table"]["body"][1][1]["text"] := STR0026
        oData['content'][18]["columns"][1]["table"]["body"][1][1] := STR0027
        oData['content'][18]["columns"][1]["table"]["body"][1][2] := STR0028
        oData['content'][18]["columns"][1]["table"]["body"][1][3] := STR0029
        oData['content'][18]["columns"][1]["table"]["body"][1][4] := STR0030
        oData['content'][18]["columns"][1]["table"]["body"][1][5] := STR0031
        
        oData['content'][18]["columns"][3]["table"]["body"][1][1] := STR0027
        oData['content'][18]["columns"][3]["table"]["body"][1][2] := STR0028
        oData['content'][18]["columns"][3]["table"]["body"][1][3] := STR0029
        oData['content'][18]["columns"][3]["table"]["body"][1][4] := STR0030
        oData['content'][18]["columns"][3]["table"]["body"][1][5] := STR0031

        oData['content'][19]["text"] := STR0032
        oData['content'][20]["table"]["body"][1][1] := STR0030
        oData['content'][20]["table"]["body"][1][2] := STR0031
        oData['content'][20]["table"]["body"][1][3] := STR0030
        oData['content'][20]["table"]["body"][1][4] := STR0031
        oData['content'][20]["table"]["body"][1][5] := STR0030
        oData['content'][20]["table"]["body"][1][6] := STR0031
        oData['content'][20]["table"]["body"][1][7] := STR0030
        oData['content'][20]["table"]["body"][1][8] := STR0031

        oData['content'][21]["text"] := STR0033
        oData['content'][22]["table"]["body"][1][1] := STR0034
        oData['content'][22]["table"]["body"][2][1] := STR0035
        oData['content'][22]["table"]["body"][3][1] := STR0036
        oData['content'][22]["table"]["body"][4][1] := STR0037
        oData['content'][22]["table"]["body"][1][3] := STR0038
        oData['content'][22]["table"]["body"][2][3] := STR0039
        oData['content'][22]["table"]["body"][3][3] := STR0040
        oData['content'][22]["table"]["body"][4][3] := STR0041

        oData["content"][23]["table"]["body"][1][1]["text"] := STR0042
        oData["content"][23]["table"]["body"][1][3]["text"] := STR0043
        oData["content"][24]["table"]["body"][1][1]["text"] := STR0044

    Else
        oData['content'][17]["text"] := STR0032
        oData['content'][18]["table"]["body"][1][1] := STR0030
        oData['content'][18]["table"]["body"][1][2] := STR0031
        oData['content'][18]["table"]["body"][1][3] := STR0030
        oData['content'][18]["table"]["body"][1][4] := STR0031
        oData['content'][18]["table"]["body"][1][5] := STR0030
        oData['content'][18]["table"]["body"][1][6] := STR0031
        oData['content'][18]["table"]["body"][1][7] := STR0030
        oData['content'][18]["table"]["body"][1][8] := STR0031

        oData['content'][19]["text"] := STR0033
        oData['content'][20]["table"]["body"][1][1] := STR0034
        oData['content'][20]["table"]["body"][2][1] := STR0035
        oData['content'][20]["table"]["body"][3][1] := STR0036
        oData['content'][20]["table"]["body"][4][1] := STR0037
        oData['content'][20]["table"]["body"][1][3] := STR0038
        oData['content'][20]["table"]["body"][2][3] := STR0039
        oData['content'][20]["table"]["body"][3][3] := STR0040
        oData['content'][20]["table"]["body"][4][3] := STR0041

        oData["content"][21]["table"]["body"][1][1]["text"] := STR0042
        oData["content"][21]["table"]["body"][1][3]["text"] := STR0043
        oData["content"][22]["table"]["body"][1][1]["text"] := STR0044
    EndIf

Return
