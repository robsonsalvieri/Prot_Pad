#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R23RUS.CH"


#DEFINE MAX_SYMBOL_IN_LINE 38 //maximum number of characters in a line
/*/
{Protheus.doc} RU07R23Frm(aBlock_0, aBlock_1, aBlock_2)
    Data distribution function.

    @type Function
    @params aData Array, array with data.
            
    @author iprokhorenko
    @since 06/12/2023
    @version 
    @return 
    @example RU07R23Frm(aBlock_0, aBlock_1, aBlock_2)
/*/
Function RU07R23Frm(aData)

    Local oData     As Object
    Local cJson     As Char
    Local nLenBl_2  As Numeric
    Local oOptions  As Object
    Local cPdate    As Char

    oData := GetTemplate(aData)
    oData := SetData(@oData, aData)
    
    cJson := oData:ToJson()

    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.

    cOptions := oOptions:ToJson()
    ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions,'RU07R23')

Return

/*/
{Protheus.doc} SetData(oData, aData)
    Sets data in JSON File.
    @type function
    @params aData Array, array with data.
            oData Object, contains a template construct.   
    @author iprokhorenko
    @since 06/12/2023
    @param aData, array, Data to fill section
    @param oData, object, Json object
    @return object, Object received with data inserted
/*/
Static Function SetData(oData, aData)
    Local nX As Numeric
    Local nCont As Numeric
    Local nI            As Numeric
    Local nJ            As Numeric
    Local nLen as Numeric

    For nX := 1 to Len(aData)
        nCont := nX //* 2 - 1//3 - 2
        nLen:=iif(len(aData[nX][3]) > len(aData[nX][4]) + 2, len(aData[nX][3]), len(aData[nX][4])+2)
        oData['content'][nCont]["table"]["body"][1][1]["text"] := aData[nX][1][1]
        oData['content'][nCont]["table"]["body"][2][1]["text"] := aData[nX][1][2]
        oData['content'][nCont]["table"]["body"][3][1]["text"] := aData[nX][1][3]
        oData['content'][nCont]["table"]["body"][3][6]["text"] := aData[nX][1][6]
        oData['content'][nCont]["table"]["body"][4][1]["text"] := aData[nX][1][4]
        oData['content'][nCont]["table"]["body"][4][6]["text"] := aData[nX][1][7]
        oData['content'][nCont]["table"]["body"][5][1]["text"] := aData[nX][1][5]
        oData['content'][nCont]["table"]["body"][5][6]["text"] := aData[nX][1][8]
        oData['content'][nCont]["table"]["body"][6][1]["text"] := aData[nX][1][9]
        
        oData['content'][nCont]["table"]["body"][7][1]["text"] := STR0013               // Total taxable income since the beginning of the year
        oData['content'][nCont]["table"]["body"][7][2]["text"] := aData[nX][1][19]
        oData['content'][nCont]["table"]["body"][7][6]["text"] := STR0014               // To be paid per month
        oData['content'][nCont]["table"]["body"][7][7]["text"] := aData[nX][1][10]

        oData['content'][nCont]["table"]["body"][8][1]["text"] := STR0015               // Personal income tax deductions applied
        oData['content'][nCont]["table"]["body"][8][2]["text"] := STR0016               // to myself
        oData['content'][nCont]["table"]["body"][8][3]["text"] := Transform(aData[nX][2][1], GetSx3Cache( "RC_VALOR", "X3_PICTURE" )) 
        oData['content'][nCont]["table"]["body"][8][4]["text"] := STR0017               // for children
        oData['content'][nCont]["table"]["body"][8][5]["text"] := Transform(aData[nX][2][2], GetSx3Cache( "RC_VALOR", "X3_PICTURE" )) 
        oData['content'][nCont]["table"]["body"][8][6]["text"] := STR0030               // property
        oData['content'][nCont]["table"]["body"][8][7]["text"] := Transform(aData[nX][2][3], GetSx3Cache( "RC_VALOR", "X3_PICTURE" )) 
        oData['content'][nCont]["table"]["body"][8][8]["text"] := STR0031               // social
        oData['content'][nCont]["table"]["body"][8][9]["text"] := Transform(aData[nX][2][4], GetSx3Cache( "RC_VALOR", "X3_PICTURE" )) 

        oData['content'][nCont]["table"]["body"][9][1]["text"] := STR0032               // Type of charges
        oData['content'][nCont]["table"]["body"][9][2]["text"] := STR0033               // Code
        oData['content'][nCont]["table"]["body"][9][3]["text"] := STR0034               // Slave. days/hours
        oData['content'][nCont]["table"]["body"][9][4]["text"] := STR0035               // Amount rub.
        oData['content'][nCont]["table"]["body"][9][6]["text"] := STR0036               // Type of charges
        oData['content'][nCont]["table"]["body"][9][7]["text"] := STR0033               // Code
        oData['content'][nCont]["table"]["body"][9][8]["text"] := STR0035               // Amount rub.

        oData['content'][nCont]["table"]["body"][10][1]["text"] := STR0037              // 1. Accrued per month
        oData['content'][nCont]["table"]["body"][10][6]["text"] := STR0038              // 2. Paid/withheld for the month

        oData['content'][nCont]["table"]["body"][14 + nLen - 3][1]["text"] = STR0041                   // Total accrued income for the month
        oData['content'][nCont]["table"]["body"][14 + nLen - 3][4]["text"] = aData[nX][1][11]
        oData['content'][nCont]["table"]["body"][14 + nLen - 3][6]["text"] = STR0042                   // Total paid and withheld for the month
        oData['content'][nCont]["table"]["body"][14 + nLen - 3][8]["text"] = aData[nX][1][12]
        oData['content'][nCont]["table"]["body"][14 + nLen - 2][1]["text"] = STR0043                   // Debt due to employer at the beginning of the month*
        oData['content'][nCont]["table"]["body"][14 + nLen - 2][5]["text"] = aData[nX][1][18]
        oData['content'][nCont]["table"]["body"][14 + nLen - 2][6]["text"] = STR0044                   // Debt due to employer at the end of the month *
        oData['content'][nCont]["table"]["body"][14 + nLen - 2][9]["text"] = aData[nX][1][10]//aData[nX][1][17]
        oData['content'][nCont]["table"]["body"][14 + nLen - 1][1]["text"] = STR0045                   // *Note: as a general rule, the employer’s debt to the employee is the salary for the second half of the month worked, which the employee receives at the beginning of the next month
        oData['content'][nCont]["table"]["body"][14 + nLen][1]["text"] = STR0046                       // Debt due to employee at the beginning of the month
        oData['content'][nCont]["table"]["body"][14 + nLen][5]["text"] = aData[nX][1][15]
        oData['content'][nCont]["table"]["body"][14 + nLen][6]["text"] = STR0047                       // Employee's debt at the end of the month
        oData['content'][nCont]["table"]["body"][14 + nLen][9]["text"] = aData[nX][1][16]
 
        for nI := 1 to len(aData[nX][3])
            oData['content'][nCont]["table"]["body"][10+nI][1]["text"] := aData[nX][3][nI][1]
            oData['content'][nCont]["table"]["body"][10+nI][2]["text"] := aData[nX][3][nI][2]
            oData['content'][nCont]["table"]["body"][10+nI][3]["text"] := aData[nX][3][nI][3]
            oData['content'][nCont]["table"]["body"][10+nI][4]["text"] := aData[nX][3][nI][4]
        Next

        for nI := 1 to len(aData[nX][4])
            oData['content'][nCont]["table"]["body"][10+nI][6]["text"] := aData[nX][4][nI][1]
            oData['content'][nCont]["table"]["body"][10+nI][7]["text"] := aData[nX][4][nI][2]
            oData['content'][nCont]["table"]["body"][10+nI][8]["text"] := aData[nX][4][nI][3]
        Next

        oData['content'][nCont]["table"]["body"][10+nLen - 1][6]["text"] := STR0039                    // Paid for the first half of the month
        oData['content'][nCont]["table"]["body"][10+nLen - 1][7]["text"] := "872"
        oData['content'][nCont]["table"]["body"][10+nLen - 1][8]["text"] := aData[nX][1][14]
        oData['content'][nCont]["table"]["body"][10+nLen][6]["text"] := STR0040                        // Personal income tax withheld
        oData['content'][nCont]["table"]["body"][10+nLen][8]["text"] := aData[nX][1][13]
    Next
        

Return oData

/*/
{Protheus.doc} GetTemplate(aData)
    Create Json file
    @type function
    @params aData Array, array with data.
    @author iprokhorenko
    @since 06/12/2023
    @return oData, JSON Object with PDF template according to pdfMake Documentation and with JSON-fn package syntax.
/*/
Static Function GetTemplate(aData)
    Local cJson1        As Character
    Local cJson2        As Character
    Local cJson3        As Character
    Local cJson4        As Character
    Local cJson5        As Character
    Local cJson6        As Character

    Local cJson         As Character
    Local oData         := JsonObject():New()
    Local nX            As Numeric
    Local nI            As Numeric
    Local nLen          As Numeric

    BeginContent var cJson1
    {
        "pageSize": "A4",
        "pageMargins": [0, 30, 0, 10],
        "styles": 
        {
            "subTitle": {
                "fontSize": 9.5,
                "font": "Arial",
                "bold": true
            },
            "tableSmallCenter": {
                "font": "Arial",
                "fontSize": 6.5,
                "alignment": "center"
            },
            "tableSmallCenterBold": {
                "font": "Arial",
                "fontSize": 6.5,
                "alignment": "center",
                "bold": true
            },
            "tableSmallLeft": {
                "font": "Arial",
                "fontSize": 6.5,
                "alignment": "left"
            },
            "header": {
                "font": "Arial",
                "fontSize": 6,
                "bold": false,
                "alignment": "right"
            },
            "normal": {
            "font": "Arial",
                "fontSize": 7.5,
                "bold": false
            },
            "tableNormCenter": {
            "font": "Arial",
                "fontSize": 7,
                "alignment": "center"
            },
            "smallStyle": {
            "font": "Arial",
                "fontSize": 5.5,
                "alignment": "center"
            }
        },
        "content": [
            EndContent

            BeginContent var cJson2
            {
                "margin": [5, 10, 0, 0],
                "pageBreak": "after",
                "table": {
                    "headerRows": 3,
                    "widths": [80, 60, 60, 25, 60, 80, 40, 30, 60],
                    "body": [
                        [
                            {"colSpan": 9, "text": "", "style": "tableSmallCenterBold"},
                            {},{},{},{},{},{},{},{}
                        ],
                        
                        [
                            {"colSpan": 9, "text": "", "style": "tableSmallCenterBold"},
                            {},{},{},{},{},{},{},{}
                        ],
                        [
                            {"colSpan": 5, "text": "", "style": "tableSmallLeft"},
                            {},{},{},{},
                            {"colSpan": 4, "text": "", "style": "tableSmallLeft"},
                            {},{},{}
                        ],
                        [
                            {"colSpan": 5, "text": "", "style": "tableSmallLeft"},
                            {},{},{},{},
                            {"colSpan": 4, "text": "", "style": "tableSmallLeft"},
                            {},{},{}
                        ],
                        [
                            {"colSpan": 5, "text": "", "style": "tableSmallLeft"},
                            {},{},{},{},
                            {"colSpan": 4, "text": "", "style": "tableSmallLeft"},
                            {},{},{}
                        ],
                        [
                            {"colSpan": 9, "text": "", "style": "tableSmallLeft"},
                            {},{},{},{},{},{},{},{}
                        ],
                        
                        [
                            {"text": "", "style": "tableNormCenter"},
                            {"colSpan": 4, "text": "", "style": "tableSmallLeft"},
                            {},{},{},
                            {"text": "" ,  "style": "tableNormCenter"},
                            {"colSpan": 3, "text": "", "style": "tableSmallLeft"},
                            {},{}
                        ],
                        [
                                                    
                            {"text": "", "style": "tableNormCenter"},
                            {"text": "", "style": "tableNormCenter"},
                            {"text": "", "style": "tableNormCenter"},
                            {"text": "", "style": "tableNormCenter"},
                            {"text": "", "style": "tableNormCenter"},
                            {"text": "", "style": "tableNormCenter"},
                            {"text": "", "style": "tableNormCenter"},
                            {"text": "", "style": "tableNormCenter"},
                            {"text": "", "style": "tableNormCenter"}
                        
                        ],
                        
                        [
                            {"text": "" ,  "style": "tableSmallCenterBold"},
                            {"text": "" ,  "style": "tableSmallCenterBold"},
                            {"text": "" ,  "style": "tableSmallCenterBold"},
                            {"colSpan": 2, "text": "", "style": "tableSmallCenterBold"},
                            {},
                            {"text": "" ,  "style": "tableSmallCenterBold"},
                            {"text": "" ,  "style": "tableSmallCenterBold"},
                            {"colSpan": 2, "text": "", "style": "tableSmallCenterBold"},
                            {}
                        ],
                        
                        [
                            {"colSpan": 5, "text": "", "style": "tableSmallLeft"},
                            {},{},{},{},
                            {"colSpan": 4, "text": "", "style": "tableSmallLeft"},
                            {},{},{}
                        ],

                        EndContent

                        BeginContent var cJson3
                        [
                            {"text": "" ,  "style": "tableSmallLeft"},
                            {"text": "" ,  "style": "tableSmallLeft"},
                            {"text": "" ,  "style": "tableSmallLeft"},
                            {"colSpan": 2, "text": "", "style": "tableSmallLeft"},
                            {},
                            {"text": "" ,  "style": "tableSmallLeft"},
                            {"text": "" ,  "style": "tableSmallLeft"},
                            {"colSpan": 2, "text": "", "style": "tableSmallLeft"},
                            {}
                        ],

                        EndContent

                        BeginContent var cJson4
                        [
                            {"colSpan": 3, "text": "", "style": "tableSmallLeft"},
                            {},{},
                            {"colSpan": 2, "text": "", "style": "tableSmallLeft"},
                            {},
                            {"text": "", "style": "tableSmallLeft"},
                            {"text": "", "style": "tableSmallLeft"},
                            {"colSpan": 2, "text": "", "style": "tableSmallLeft"},
                            {}
                        ],
                        [
                            {"colSpan": 4, "text": "", "style": "tableSmallLeft"},
                            {},{},{},
                            {"text": "", "style": "tableSmallLeft"},
                            {"colSpan": 3, "text": "", "style": "tableSmallLeft"},
                            {},{},
                            {"text": "", "style": "tableSmallLeft"}
                        ],
                        [
                            {"colSpan": 9, "text": "", "style": "tableSmallLeft"},
                            {},{},{},{},{},{},{},{}
                        ],
                        [
                            {"colSpan": 4, "text": "", "style": "tableSmallLeft"},
                            {},{},{},
                            {"text": "", "style": "tableSmallLeft"},
                            {"colSpan": 3, "text": "", "style": "tableSmallLeft"},
                            {},{},
                            {"text": "", "style": "tableSmallLeft"}
                        ]
                    ]

                }
            }

            EndContent
            

            BeginContent var cJson5
        ]
	}
    EndContent
    
    cJson := cJson1
    
    for nX := 1 to len(aData)
        cJson += cJson2
        
        nlen:=iif(len(aData[nX][3]) > len(aData[nX][4]) + 2, len(aData[nX][3]), len(aData[nX][4])+2)
        For nI := 1 to nlen//len(aData[nX][3])+2
            cJson += cJson3
        Next
        
        cJson += cJson4 + Iif(nX != len(aData), ', ', '')

    Next

    cJson += cJson5 

    oData:FromJson(cJson)

Return oData
