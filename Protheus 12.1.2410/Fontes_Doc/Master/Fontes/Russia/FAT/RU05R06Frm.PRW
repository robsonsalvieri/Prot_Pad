#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU02R02.CH"


#DEFINE MAX_SYMBOL_IN_LINE 38 //maximum number of characters in a line
/*/
{Protheus.doc} RU05R06Frm(aBlock_0, aBlock_1, aBlock_2)
    Data distribution function.

    @type Function
    @params aBlock0 Array, array with data.
            aBlock1 Array, array with data.
            aBlock2 Array, array with data.
    @author eprokhorenko
    @since 9/8/2023
    @version 
    @return 
    @example RU05R06Frm(aBlock_0, aBlock_1, aBlock_2)
/*/
Function RU05R06Frm(aBlock_0, aBlock_1, aBlock_2)

    Local oData     As Object
    Local cJson     As Char
    Local nLenBl_2  As Numeric
    Local oOptions  As Object
    Local cPdate    As Char

    oData := GetTemplate(aBlock_0, aBlock_1, aBlock_2)
    oData := SetData(@oData, aBlock_0, aBlock_1, aBlock_2)
    
    nLenBl_2 := Len(aBlock_2)
    cPdate   :=  aBlock_0[2]
    SetStrings(@oData, cPdate, nLenBl_2)

    cJson := oData:ToJson()

    //Gets Options for PDF template
    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.

    cOptions := oOptions:ToJson()
    //Calls library with FWCALLAPP
    ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions,'RU05R06')

Return

/*/
{Protheus.doc} SetData(oData, aBlock_0, aBlock_1, aBlock_2)
    Sets data in JSON File.
    @type function
    @params aBlock_0, aBlock_1, aBlock_2 Array, array with data.
            oData Object, contains a template construct.   
    @author eprokhorenko
    @since 9/8/2023
    @param Block_0, aBlock_1, aBlock_2, array, Data to fill section
    @param oData, object, Json object
    @return object, Object received with data inserted
/*/
Static Function SetData(oData, aBlock_0, aBlock_1, aBlock_2)
    Local nX As Numeric
    Local nCont As Numeric

        //the invoice number and date
        oData['content'][1]["table"]["body"][1][2]["text"] := aBlock_0[1]
        oData['content'][1]["table"]["body"][1][4]["text"] := aBlock_0[2]
        oData['content'][1]["table"]["body"][2][2]["text"] := aBlock_0[3]
        oData['content'][1]["table"]["body"][2][4]["text"] := aBlock_0[4]

        nCont := 0
        If CToD(aBlock_0[2]) < SToD("20210701")
         // Fill in information about vendor and buyer
            oData['content'][2]["columns"][1]["table"]["body"][1][2]["text"]  := aBlock_0[5]
            oData['content'][3]["columns"][1]["table"]["body"][1][2]["text"]  := aBlock_0[6]
            oData['content'][4]["columns"][1]["table"]["body"][1][2]["text"]  := aBlock_0[7]
            oData['content'][5]["columns"][1]["table"]["body"][1][2]["text"]  := aBlock_0[8]
            oData['content'][5]["columns"][1]["table"]["body"][2][2]["text"]  := aBlock_0[9] 
            oData['content'][6]["columns"][1]["table"]["body"][1][2]["text"]  := aBlock_0[10]
            oData['content'][7]["columns"][1]["table"]["body"][1][2]["text"]  := aBlock_0[12]
            oData['content'][8]["columns"][1]["table"]["body"][1][2]["text"]  := aBlock_0[13]
            oData['content'][9]["columns"][1]["table"]["body"][1][2]["text"]  := aBlock_0[14]
            oData['content'][10]["columns"][1]["table"]["body"][1][2]["text"] := aBlock_0[15]
            oData['content'][11]["columns"][1]["table"]["body"][1][2]["text"] := aBlock_0[16]
            nCont := 8
        Else
            // Fill in information about the vendor
            oData['content'][2]["table"]["body"][1][2]["text"] := aBlock_0[5]
            oData['content'][2]["table"]["body"][2][2]["text"] := aBlock_0[6]
            oData['content'][2]["table"]["body"][3][2]["text"] := aBlock_0[7]
            oData['content'][2]["table"]["body"][4][2]["text"] := aBlock_0[8]
            oData['content'][3]["table"]["body"][1][2]["text"] := aBlock_0[9]
            oData['content'][3]["table"]["body"][2][2]["text"] := aBlock_0[10]
            oData['content'][3]["table"]["body"][3][2]["text"] := aBlock_0[17]

            // Fill in information about the buyer
            oData['content'][2]["table"]["body"][1][5]["text"] := aBlock_0[12]
            oData['content'][2]["table"]["body"][2][5]["text"] := aBlock_0[13]
            oData['content'][2]["table"]["body"][3][5]["text"] := aBlock_0[14]
            oData['content'][2]["table"]["body"][4][5]["text"] := aBlock_0[15]
            oData['content'][3]["table"]["body"][2][5]["text"] := aBlock_0[16]
        EndIf

        // Fill in information about goods
        For nX := 1 To Len(aBlock_2)
            oData['content'][4 + nCont]["table"]["body"][3+nX][1]["text"]  := aBlock_2[nX][1]
            oData['content'][4 + nCont]["table"]["body"][3+nX][2]["text"]  := aBlock_2[nX][2]
            oData['content'][4 + nCont]["table"]["body"][3+nX][3]["text"]  := aBlock_2[nX][4]
            oData['content'][4 + nCont]["table"]["body"][3+nX][4]["text"]  := aBlock_2[nX][5]
            oData['content'][4 + nCont]["table"]["body"][3+nX][5]["text"]  := aBlock_2[nX][6]
            oData['content'][4 + nCont]["table"]["body"][3+nX][6]["text"]  := aBlock_2[nX][7]
            oData['content'][4 + nCont]["table"]["body"][3+nX][7]["text"]  := aBlock_2[nX][8]
            oData['content'][4 + nCont]["table"]["body"][3+nX][8]["text"]  := aBlock_2[nX][9]
            oData['content'][4 + nCont]["table"]["body"][3+nX][9]["text"]  := aBlock_2[nX][3]
            oData['content'][4 + nCont]["table"]["body"][3+nX][10]["text"] := aBlock_2[nX][12]
            oData['content'][4 + nCont]["table"]["body"][3+nX][11]["text"] := aBlock_2[nX][10]
            oData['content'][4 + nCont]["table"]["body"][3+nX][12]["text"] := aBlock_2[nX][11]
            oData['content'][4 + nCont]["table"]["body"][3+nX][13]["text"] := aBlock_2[nX][13]
            oData['content'][4 + nCont]["table"]["body"][3+nX][14]["text"] := aBlock_2[nX][14]
            oData['content'][4 + nCont]["table"]["body"][3+nX][15]["text"] := aBlock_2[nX][15]
        Next
        
        // General totals
        oData['content'][4 + nCont]["table"]["body"][3+nX][8]["text"]  := aBlock_1[1]
        oData['content'][4 + nCont]["table"]["body"][3+nX][11]["text"] := aBlock_1[2]
        oData['content'][4 + nCont]["table"]["body"][3+nX][12]["text"] := aBlock_1[3]

        // Fill in information about signatories
        oData['content'][4 + nCont+1]["table"]["body"][1][4]["text"] := aBlock_1[4]
        oData['content'][4 + nCont+1]["table"]["body"][1][9]["text"] := aBlock_1[5]

Return oData

/*/
{Protheus.doc} GetTemplate(aBlock_0,aBlock_1, aBlock_2)
    Create Json file
    @type function
    @params aBlock_0,aBlock_1, aBlock_2 Array, array with data.
    @author eprokhorenko
    @since 9/8/2023
    @return oData, JSON Object with PDF template according to pdfMake Documentation and with JSON-fn package syntax.
/*/
Static Function GetTemplate(aBlock_0,aBlock_1, aBlock_2)
    Local cJson1        As Character
    Local cJson2        As Character
    Local cJson3        As Character
    Local cJson4        As Character
    Local cJson5        As Character
    Local cJson6        As Character
    Local cJson7        As Character
    Local cJson         As Character
    Local oData         := JsonObject():New()
    Local nX            As Numeric
    Local nFirstPage    As Numeric
    Local nMoreStrFrst  As Numeric
    Local nMiddlePage   As Numeric
    Local nCountPage    As Numeric
    Local nCountLine    As Numeric
    Local nCntLnPage    As Numeric
    Local nSumStr       As Numeric

    BeginContent var cJson1
    {
        "pageSize": "A4",
        "pageOrientation": "landscape",
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
        "pageBreakBefore": "function (currentNode, followingNodesOnPage, nodesOnNextPage, previousNodesOnPage) {return currentNode.headlineLevel === 1;}",
        "content": [
            EndContent
            BeginContent var cJson2
            {
                "margin": [40, 0, 0, 0],
                "table": {
                    "widths": [130, 100, 20, 85, 20, 5, 350],
                    "dontBreakRows": false,
                    "body": [
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"                       }, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal", "alignment": "center"}, 
                            {"text": ""   , "border": [false, false, false, false], "style": "normal", "alignment": "center"},
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal", "alignment": "center"}, 
                            {"text": "(1)", "border": [false, false, false, false], "style": "normal"                       },
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"                       }, 
                            {"text": ""   , "border": [false, false, false, false], "style": "header", "alignment": "right" }
                        ],
                        [
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"                       }, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal", "alignment": "center"},
                            {"text": ""    , "border": [false, false, false, false], "style": "normal", "alignment": "center"},
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal", "alignment": "center"},
                            {"text": "(1a)", "border": [false, false, false, false], "style": "normal"                       },
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"                       },
                            {"text": ""    , "border": [false, false, false, false], "style": "header", "alignment": "right" }
                        ]
                    ]
                }
            },
            {
                "margin": [20, 20, 0, 0],
                "columns": [{
                "width": "60%",
                "table": {
                    "widths": ["auto", "*", 20],
                    "body": [
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(2)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            }]
            },
            {
                "margin": [20, 0, 0, 0],
                "columns": [{
                "width": "60%",
                "table": {
                    "widths": ["auto", "*", 20],
                    "body": [
                        [
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal"},
                            {"text": "(2a)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            }]
            },
            {
                "margin": [20, 0, 0, 0],
                "columns": [{
                "width": "60%",
                "table": {
                    "widths": ["auto", "*", 20],
                    "body": [
                        [
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(2á)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            }]
            },
            {
                "margin": [20, 0, 0, 0],
                "columns": [{
                "width": "60%",
                "table": {
                    "widths": [110, "*", 20],
                    "body": [
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(3)", "border": [false, false, false, false], "style": "normal"}
                        ],
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(4)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            }]
            },
            {
                "margin": [20, 0, 0, 0],
                "columns": [{
                "width": "60%",
                "table": {
                    "widths": ["auto", "*", 20],
                    "body": [
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(5)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            }]
            },
            {
                "margin": [20, 0, 0, 0],
                "columns": [{
                "width": "60%",
                "table": {
                    "widths": ["auto", "*", 20],
                    "body": [
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(6)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            }]
            },
            {
                "margin": [20, 0, 0, 0],
                "columns": [{
                "width": "60%",
                "table": {
                    "widths": ["auto", "*", 20],
                    "body": [
                        [
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal"},
                            {"text": "(6a)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            }]
            },
            {
                "margin": [20, 0, 0, 0],
                "columns": [{
                "width": "60%",
                "table": {
                    "widths": ["auto", "*", 20],
                    "body": [
                        [
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(6á)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            }]
            },
            {
                "margin": [20, 0, 0, 0],
                "columns": [{
                "width": "60%",
                "table": {
                    "widths": ["auto", "*", 20],
                    "body": [
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"},
                            {"text": "(7)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            }]
            },
            {
                "margin": [20, 0, 0, 0],
                "columns": [{
                "width": "60%",
                "table": {
                    "widths": ["auto", "*", 20],
                    "body": [
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"},
                            {"text": "(8)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            }]
            },
            EndContent
            BeginContent var cJson3
            {
                "margin": [15, 0, 0, 0],
                "table": {
                    "widths": [130, 100, 20, 95, 20, 5, 360],
                    "dontBreakRows": false,
                    "body": [
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"                       }, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal", "alignment": "center"}, 
                            {"text": ""   , "border": [false, false, false, false], "style": "normal", "alignment": "center"},
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal", "alignment": "center"}, 
                            {"text": "(1)", "border": [false, false, false, false], "style": "normal"                       },
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"                       }, 
                            {"text": ""   , "border": [false, false, false, false], "style": "header"                       }
                        ],
                        [
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"                       }, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal", "alignment": "center"},
                            {"text": ""    , "border": [false, false, false, false], "style": "normal", "alignment": "center"},
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal", "alignment": "center"},
                            {"text": "(1a)", "border": [false, false, false, false], "style": "normal"                       },
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"                       },
                            {"text": ""    , "border": [false, false, false, false], "style": "header"                       }
                        ]
                    ]
                }
            },
            {
                "margin": [15, 20, 0, 0],
                "table": {
                    "widths": [125, 250, 20, 105, 250, 20],
                    "body": [
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal", "bold": true}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"              }, 
                            {"text": "(2)", "border": [false, false, false, false], "style": "normal"              },
                            {"text": ""   , "border": [false, false, false, false], "style": "normal", "bold": true}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"              }, 
                            {"text": "(6)", "border": [false, false, false, false], "style": "normal"              }
                        ],
                        [
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal"},
                            {"text": "(2a)", "border": [false, false, false, false], "style": "normal"},
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal"},
                            {"text": "(6a)", "border": [false, false, false, false], "style": "normal"}
                        ],
                        [
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(2á)", "border": [false, false, false, false], "style": "normal"},
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(6á)", "border": [false, false, false, false], "style": "normal"}
                        ],
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(3)", "border": [false, false, false, false], "style": "normal"},
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"},
                            {"text": "(7)", "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            },
            {
                "margin": [15, 0, 0, 0],
                "table": {
                    "widths": [125, 250, 20, 175, 180, 20],
                    "body": [
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(4)", "border": [false, false, false, false], "style": "normal"},
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"},
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}
                        ],
                        [
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(5)", "border": [false, false, false, false], "style": "normal"},
                            {"text": ""   , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""   , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(8)", "border": [false, false, false, false], "style": "normal"}
                        ],
                        [
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""    , "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "(5a)", "border": [false, false, false, false], "style": "normal"},
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"},
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}, 
                            {"text": ""    , "border": [false, false, false, false], "style": "normal"}
                        ]
                    ]
                }
            },
            EndContent
            BeginContent var cJson4
            {
                "margin": [15, 10, 0, 0],
                "table": {
                    "headerRows": 3,
                    "widths": [9, 135, 25, 14, 38, 35, 47, 60, 25, 31, 60, 60, 29, 44, 67],
                    "body": [
                        [
                            {"rowSpan": 2, "text": "", "style": "tableSmallCenter"},
                            {"rowSpan": 2, "text": "", "style": "tableNormCenter" },
                            {"rowSpan": 2, "text": "", "style": "tableNormCenter" },
                            {"colSpan": 2, "text": "", "style": "tableSmallCenter"},
                            {},
                            {"rowSpan": 2, "text": "", "style": "tableNormCenter" },
                            {"rowSpan": 2, "text": "", "style": "tableNormCenter" },
                            {"rowSpan": 2, "text": "", "style": "tableNormCenter" },
                            {"rowSpan": 2, "text": "", "style": "tableSmallCenter"},
                            {"rowSpan": 2, "text": "", "style": "tableSmallCenter"},
                            {"rowSpan": 2, "text": "", "style": "tableNormCenter" },
                            {"rowSpan": 2, "text": "", "style": "tableNormCenter" },
                            {"colSpan": 2, "text": "", "style": "tableSmallCenter"},
                            {},
                            {"rowSpan": 2, "text": "", "style": "tableSmallCenter"}
                        ],
                        [
                            {},
                            {},
                            {},
                            {"text": "",  "style": "tableSmallCenter"},
                            {"text": "",  "style": "tableSmallCenter"},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {"text": "",  "style": "tableSmallCenter"},
                            {"text": "",  "style": "tableSmallCenter"},
                            {}
                        ],
                        [
                            {"text": "1" ,  "style": "tableNormCenter"},
                            {"text": "1a",  "style": "tableNormCenter"},
                            {"text": "1á",  "style": "tableNormCenter"},
                            {"text": "2" ,  "style": "tableNormCenter"},
                            {"text": "2a",  "style": "tableNormCenter"},
                            {"text": "3" ,  "style": "tableNormCenter"},
                            {"text": "4" ,  "style": "tableNormCenter"},
                            {"text": "5" ,  "style": "tableNormCenter"},
                            {"text": "6" ,  "style": "tableNormCenter"},
                            {"text": "7" ,  "style": "tableNormCenter"},
                            {"text": "8" ,  "style": "tableNormCenter"},
                            {"text": "9" ,  "style": "tableNormCenter"},
                            {"text": "10",  "style": "tableNormCenter"},
                            {"text": "10a", "style": "tableNormCenter"},
                            {"text": "11",  "style": "tableNormCenter"}
                        ],    
                    EndContent
                    BeginContent var cJson5
                        [
                            {"text": "",  "style": "tableNormCenter", "alignment": "right"},
                            {"text": "",  "style": "tableNormCenter", "alignment": "left" },
                            {"text": "",  "style": "tableNormCenter"                      },
                            {"text": "",  "style": "tableNormCenter"                      },
                            {"text": "",  "style": "tableNormCenter"                      },
                            {"text": "",  "style": "tableNormCenter", "alignment": "right"},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right"},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right"},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right"},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right"},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right"},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right"},
                            {"text": "",  "style": "tableNormCenter"                      },
                            {"text": "",  "style": "tableNormCenter"                      },
                            {"text": "",  "style": "tableNormCenter"                      }
                        ], 
                    EndContent
                    BeginContent var cJson7
                        [
                            {"text": "",  "style": "tableNormCenter", "alignment": "right", "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter", "alignment": "left" , "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter"                      , "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter"                      , "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter"                      , "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right", "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right", "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right", "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right", "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right", "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right", "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter", "alignment": "right", "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter"                      , "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter"                      , "headlineLevel": 1},
                            {"text": "",  "style": "tableNormCenter"                      , "headlineLevel": 1}
                        ],                  
                    EndContent
                    BeginContent var cJson6
                        [
                            {"colSpan": 7,"text": "" , "style": "tableNormCenter", "alignment": "left", "bold": true},
                            {"text": "" , "style": "tableNormCenter"                           },
                            {"text": "" , "style": "tableNormCenter"                           },
                            {"text": "" , "style": "tableNormCenter"                           },
                            {"text": "" , "style": "tableNormCenter"                           },
                            {"text": "" , "style": "tableNormCenter"                           },
                            {"text": "" , "style": "tableNormCenter"                           },
                            {"text": "" , "style": "tableNormCenter", "alignment": "right"     },
                            {"colSpan": 2,"text": "X", "style": "tableNormCenter", "bold": true},
                            {"text": "" , "style": "tableNormCenter"                           },
                            {"text": "" , "style": "tableNormCenter", "alignment": "right"     },
                            {"text": "" , "style": "tableNormCenter", "alignment": "right"     },
                            {"colSpan": 3,"text": "" , "style": "tableNormCenter"              },
                            {"text": "" , "style": "tableNormCenter"                           },
                            {"text": "" , "style": "tableNormCenter"                           }
                        ]
                    ]

                }
            },
            {
                "margin": [15, 15, 0, 0],
                "table": {
                    "widths": [130, 60, 15, 90, 40, 130, 60, 15, 90],
                    "body": [
                        [
                            {"text": "", "border": [false, false, false, false], "style": "normal"}, 
                            {"text": "", "border": [false, false, false, true ], "style": "normal"},
                            {"text": "", "border": [false, false, false, false], "style": "normal"},
                            {"text": "", "border": [false, false, false, true ], "style": "normal"},
                            {"text": "", "border": [false, false, false, false], "style": "normal"},
                            {"text": "", "border": [false, false, false, false], "style": "normal"}, 
                            {"text": "", "border": [false, false, false, true ], "style": "normal"},
                            {"text": "", "border": [false, false, false, false], "style": "normal"},
                            {"text": "", "border": [false, false, false, true ], "style": "normal"}
                        ],
                        [
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"}, 
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"},
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"},
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"},
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"},
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"}, 
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"},
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"},
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"}
                        ]

                    ]
                }
            },
            {
                "margin": [15, 5, 0, 0],
                "table": {
                    "widths": [130, 60, 15, 90, 40, 130, 60, 15, 90],
                    "body": [
                        [
                            {"text": "", "border": [false, false, false, false], "style": "normal"}, 
                            {"text": "", "border": [false, false, false, true ], "style": "normal"},
                            {"text": "", "border": [false, false, false, false], "style": "normal"}, 
                            {"text": "", "border": [false, false, false, true ], "style": "normal"},
                            {"text": "", "border": [false, false, false, false], "style": "normal"},
                            {"text": "", "border": [false, false, false, true ], "style": "normal"},
                            {"text": "", "border": [false, false, false, true ], "style": "normal"},
                            {"text": "", "border": [false, false, false, true ], "style": "normal"}, 
                            {"text": "", "border": [false, false, false, true ], "style": "normal"}
                        ],
                        [
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"}, 
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"},
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"}, 
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"},
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"}, 
                            {"colSpan": 4,"text": "", "border": [false, false, false, false], "style": "smallStyle"}, 
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"},
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"}, 
                            {"text": "", "border": [false, false, false, false], "style": "smallStyle"}
                        ]

                    ]
                }
            }

        ]
	}
    EndContent

    If CToD(aBlock_0[2]) < SToD("20210701")
        cJson1      += (cJson2 + cJson4)
        nFirstPage  := 12 // Number of lines for the first page
        nMoreStrFrst:= 18 // Number of lines for the first page if Len(aBlock_2) > (nMoreStrFrst/2)
    Else
        cJson1      += (cJson3 + cJson4)
        nFirstPage  := 18 // Number of lines for the first page
        nMoreStrFrst:= 36 // Number of lines for the first page if Len(aBlock_2) > (nMoreStrFrst/2)
    EndIf

    nMiddlePage:= 58
    nCountPage := 0
    nCountLine := 0
    nCntLnPage := 0
    nSumStr    := 0

    //Dynamically control page breaks
    If Len(aBlock_2) > 1 
        For nX :=1 To Len(aBlock_2)
            nCountLine := CountLine(aBlock_2[nX][2])
            nCntLnPage += nCountLine
            If (nCntLnPage >= nFirstPage .AND. (nCntLnPage <= nMoreStrFrst) .AND. nCountPage==0 .AND. nX != Len(aBlock_2))
                nFirstPage := nCntLnPage
            EndIf
            if (nCntLnPage > nFirstPage .AND. nCountPage==0);
                    .OR. (nCntLnPage > nMiddlePage) ;
                    .OR. (nCntLnPage > nFirstPage .AND. nCountPage==0) ;
                    .OR. (nCntLnPage > nMiddlePage);
                    .OR. (nCntLnPage > 46 .AND. nX == Len(aBlock_2))
                cJson1 += cJson7
                nCntLnPage := nCountLine
                nCountPage ++
            Else
                cJson1 += cJson5
            EndIf
        Next
    Else
        cJson1 += cJson5
    EndIf

    cJson := cJson1 + cJson6

    oData:FromJson(cJson)
Return oData

/*/
{Protheus.doc} CountLine(cWord)
    function counts the number of lines
    @type function
    @params cWord Character, the product's name from invoice
    @author eprokhorenko
    @since 15/09/2023
    @version 
    @return nCountLine Numeric, Count line
/*/

Static Function CountLine(cWord)

Local nY         As Numeric
Local nCountLine As Numeric
nCountLine := 0

    While (AT(Chr(13)+Chr(10), cWord)) != 0 .AND. (AT(Chr(13)+Chr(10), cWord)) != NIL //Find char Enter
        cWord := StrTran( cWord, Chr(13)+Chr(10), " @#*$$ ", , 1)
    End
    aWord :=  StrTokArr(cWord, " ") 
    If (!Empty(aWord))
        nSumStr := 0
        For nY :=1 To Len(aWord)
            If(aWord[nY] == "@#*$$")
                nCountLine ++
                nSumStr := 0
            Else
                nSumStr += Len(aWord[nY]) + IIF(nY != Len(aWord), 1, 0) //Add one char, because split string by a space (aWord :=  StrTokArr(cWord, " "))
                If(nSumStr >= MAX_SYMBOL_IN_LINE) .OR. (nSumStr < MAX_SYMBOL_IN_LINE .AND. nY == Len(aWord))
                    nCountLine ++
                    nSumStr := IiF(nSumStr == MAX_SYMBOL_IN_LINE, 0, (Len(aWord[nY]) + IIF(nY != Len(aWord), 1, 0))) 
                EndIf
                If(Len(cWord) <= MAX_SYMBOL_IN_LINE) //If number of characters < MAX_SYMBOL_IN_LINE, PDFMake will create two line
                    nCountLine := 2  
                EndIf
            EndIf
        Next
    Else
        nCountLine := 2
    EndIf
    
Return nCountLine

/*/
{Protheus.doc} SetData(oData,cPdate, nLenBl_2)
    Sets data in JSON File.
    Fills the template with standard strings from the CH file.
    @type function
    @params oData Object, contains a template construct.
            cPdate Char, nLenBl_2 Num, Template Offset Parameter.
    @author eprokhorenko
    @since 9/8/2023
    @version 
    @return 
/*/
Static Function SetStrings(oData,cPdate, nLenBl_2)
Local nCont As Numeric

nCont := 0

    If CToD(cPdate) < SToD("20210701")
       oData["content"][1]["table"]["body"][1][1]["text"] := STR0020
       oData["content"][1]["table"]["body"][1][3]["text"] := STR0014
       oData["content"][1]["table"]["body"][1][7]["text"] := STR0022
	   oData["content"][1]["table"]["body"][2][1]["text"] := STR0021
	   oData["content"][1]["table"]["body"][2][3]["text"] := STR0014
	   oData["content"][1]["table"]["body"][2][7]["text"] := STR0024
	   
	   oData["content"][2]["columns"][1]["table"]["body"][1][1]["text"] := STR0025
	   oData["content"][3]["columns"][1]["table"]["body"][1][1]["text"] := STR0027
	   oData["content"][4]["columns"][1]["table"]["body"][1][1]["text"] := STR0028
	   oData["content"][5]["columns"][1]["table"]["body"][1][1]["text"] := STR0030
	   oData["content"][5]["columns"][1]["table"]["body"][2][1]["text"] := STR0031
	   oData["content"][6]["columns"][1]["table"]["body"][1][1]["text"] := STR0033
	   oData["content"][7]["columns"][1]["table"]["body"][1][1]["text"] := STR0026
	   oData["content"][8]["columns"][1]["table"]["body"][1][1]["text"] := STR0027
	   oData["content"][9]["columns"][1]["table"]["body"][1][1]["text"] := STR0029
	   oData["content"][10]["columns"][1]["table"]["body"][1][1]["text"] := STR0032
	   oData["content"][11]["columns"][1]["table"]["body"][1][1]["text"] := STR0034 + " " + STR0035
       nCont := 8
    Else
       oData["content"][1]["table"]["body"][1][1]["text"] := STR0020
	   oData["content"][1]["table"]["body"][1][3]["text"] := STR0014
	   oData["content"][1]["table"]["body"][1][7]["text"] := STR0022
	   oData["content"][1]["table"]["body"][2][1]["text"] := STR0021
	   oData["content"][1]["table"]["body"][2][3]["text"] := STR0014
	   oData["content"][1]["table"]["body"][2][7]["text"] := STR0023

	   oData["content"][2]["table"]["body"][1][1]["text"] := STR0025
	   oData["content"][2]["table"]["body"][1][4]["text"] := STR0026
	   oData["content"][2]["table"]["body"][2][1]["text"] := STR0027
	   oData["content"][2]["table"]["body"][2][4]["text"] := STR0027
	   oData["content"][2]["table"]["body"][3][1]["text"] := STR0028
	   oData["content"][2]["table"]["body"][3][4]["text"] := STR0029
	   oData["content"][2]["table"]["body"][4][1]["text"] := STR0030
	   oData["content"][2]["table"]["body"][4][4]["text"] := STR0032
	   oData["content"][3]["table"]["body"][1][1]["text"] := STR0031
	   oData["content"][3]["table"]["body"][1][4]["text"] := STR0034
	   oData["content"][3]["table"]["body"][2][1]["text"] := STR0033
	   oData["content"][3]["table"]["body"][2][4]["text"] := STR0035
	   oData["content"][3]["table"]["body"][3][1]["text"] := STR0036
    EndIf

    oData['content'][4 + nCont]["table"]["body"][1][1]["text"]  := STR0037
    oData['content'][4 + nCont]["table"]["body"][1][2]["text"]  := STR0038
    oData['content'][4 + nCont]["table"]["body"][1][3]["text"]  := STR0039
    oData['content'][4 + nCont]["table"]["body"][1][4]["text"]  := STR0040
    oData['content'][4 + nCont]["table"]["body"][2][4]["text"]  := STR0041
    oData['content'][4 + nCont]["table"]["body"][2][5]["text"]  := STR0042
    oData['content'][4 + nCont]["table"]["body"][1][6]["text"]  := STR0043
    oData['content'][4 + nCont]["table"]["body"][1][7]["text"]  := STR0044
    oData['content'][4 + nCont]["table"]["body"][1][8]["text"]  := STR0045
    oData['content'][4 + nCont]["table"]["body"][1][9]["text"]  := STR0046
    oData['content'][4 + nCont]["table"]["body"][1][10]["text"] := STR0047
    oData['content'][4 + nCont]["table"]["body"][1][11]["text"] := STR0048
    oData['content'][4 + nCont]["table"]["body"][1][12]["text"] := STR0049
    oData['content'][4 + nCont]["table"]["body"][1][13]["text"] := STR0050
    oData['content'][4 + nCont]["table"]["body"][2][13]["text"] := STR0051
    oData['content'][4 + nCont]["table"]["body"][2][14]["text"] := STR0052
    oData['content'][4 + nCont]["table"]["body"][1][15]["text"] := STR0053
    oData['content'][4 + nCont]["table"]["body"][3+nLenBl_2+1][1]["text"]  := STR0054 

    oData['content'][4 + nCont+1]["table"]["body"][1][1]["text"]  := STR0055
    oData['content'][4 + nCont+1]["table"]["body"][1][6]["text"]  := STR0056
    oData['content'][4 + nCont+1]["table"]["body"][2][2]["text"]  := STR0057
    oData['content'][4 + nCont+1]["table"]["body"][2][4]["text"]  := STR0058
    oData['content'][4 + nCont+1]["table"]["body"][2][7]["text"]  := STR0057
    oData['content'][4 + nCont+1]["table"]["body"][2][9]["text"]  := STR0058

    oData['content'][4 + nCont+2]["table"]["body"][1][1]["text"]  := STR0059
    oData['content'][4 + nCont+2]["table"]["body"][2][2]["text"]  := STR0057
    oData['content'][4 + nCont+2]["table"]["body"][2][4]["text"]  := STR0058
    oData['content'][4 + nCont+2]["table"]["body"][2][6]["text"]  := STR0060

Return
                   
//Merge Russia R14 
                   
                   
