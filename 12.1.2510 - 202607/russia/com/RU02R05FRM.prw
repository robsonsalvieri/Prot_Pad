#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE MAX_SYMBOL_IN_LINE 21 //maximum number of characters in a line

    /*/{Protheus.doc} RU02R05Frm(nDataLen)
    @type Function
    @params nDataLen Numeric, number with array length.
    @author Dsidorenko
    @since 08/02/2024 
    @version 13.1.2310
    @return oData, JSON Object with PDF template according to pdfMake Documentation and with JSON-fn package syntax.
    @see (http://pdfmake.org/playground.html#) 
    /*/
Function RU02R05Frm(nDataLen, aData)
    Local cJson      As Char
    Local cJson1     As Char
    Local cJson2     As Char
    Local cJson3     As Char
    Local cJson4     As Char
    Local oData := JsonObject():New()
    Local nX As Numeric

    BeginContent var cJson1
    {
        "pageSize": "A4",
        "pageOrientation": "landscape",
        "pageMargins": [10, 30, 25, 10],
        "styles": {
            "header1": { 
                "font": "Arial",
                "fontSize": 7,
                "bold": true,
			    "alignment": "right"
            },
            "header2": {
                "margin": [170, 10, 0, 5],
                "fontSize": 16,
                "bold": true,
                "font": "Arial"
            },
            "table1": {
                "alignment": "center",
                "fontSize": 10,
                "bold": true,
                "font": "Arial"
            },
            "table2": {
                "fontSize": 10,
                "bold": false,
                "font": "Arial",
			    "alignment": "center"
            },
            "table4": {
                "fontSize": 10,
                "bold": false,
                "font": "Arial",
			    "alignment": "left"
            },
            "table5": {
                "fontSize": 10,
                "bold": false,
                "font": "Arial",
			    "alignment": "right"
            },
            "table3": {
                "fontSize": 10,
                "bold": false,
                "font": "Arial"
            }
	    },
        "pageBreakBefore": "function (currentNode, followingNodesOnPage, nodesOnNextPage, previousNodesOnPage) {return currentNode.headlineLevel === 1;}",
        "content": [
            {"text": "", "style": "header1"},
            {"text": "", "style": "header1"},
            {"text": "", "style": ""},
            {
			"style": "header2",
			"table": {
			    "widths": [200, 10, 100, 90, 90, 70],
				"body":[
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1"
                            },
                            {
                                "text": "",
                                "border": [true, true, true, true],
                                "style": "table1"
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, true]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1",
			                    "alignment": "right"
                            },
                            {
                                "text": "",
                                "border": [true, true, true, true],
                                "style": "table1"
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1",
			                    "alignment": "right"
                            },
                            {
                                "text": "",
                                "border": [true, true, true, true],
                                "style": "table1"
                            }
                        ]
                    ] 
			}
		},
        {   
			"style": "",
			"table": {
			    "widths": [150, 350],
				"body":[
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table3",
			                    "alignment": "right"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, true],
                                "style": "table3"
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table3",
			                    "alignment": "right"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, true],
                                "style": "table3"
                            }
                        ]
                    ] 
			}
		},
        {
             "margin": [0, 10, 0, 0],
                "table": {
                    "headerRows": 3,
                    "widths": [60, 70, 110, 150, 40, 60, 50, 60, 60, 60],
                    "body": [
                        [
                            {"rowSpan": 2, "text": "", "style": "table2"},
                            {"rowSpan": 2, "text": "", "style": "table2" },
                            {"rowSpan": 2, "text": "", "style": "table2" },
                            {"colSpan": 2, "text": "", "style": "table2"},
                            {},
                            {"rowSpan": 2, "text": "", "style": "table2" },
                            {"colSpan": 2, "text": "", "style": "table2" },
                            {},
                            {"colSpan": 2, "text": "", "style": "table2" },
                            {}
                        ],
                        [
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"}
                        ],
                        [
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"}
                        ]
                ]
                }
		},
		{
            "margin": [0, 20, 0, 0],
                "table": {
                    "headerRows": 3,
                    "widths": [120, 60, 20, 35, 50, 45, 65, 70, 70, 70, 45, 60],
                    "body": [
                        [
                            {"colSpan": 2, "text": "", "style": "table2"},
                            {},
                            {"colSpan": 2, "text": "", "style": "table2"},
                            {},
                            {"colSpan": 2, "text": "", "style": "table2"},
                            {},
                            {"rowSpan": 2, "text": "", "style": "table2"},
                            {"rowSpan": 2, "text": "", "style": "table2"},
                            {"rowSpan": 2, "text": "", "style": "table2"},
                            {"rowSpan": 2, "text": "", "style": "table2"},
                            {"rowSpan": 2, "text": "", "style": "table2"},
                            {"rowSpan": 2, "text": "", "style": "table2"}
                        ],
                        [
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"}
                        ],
                        [
                            {"text": "1",  "style": "table2"},
                            {"text": "2",  "style": "table2"},
                            {"text": "3",  "style": "table2"},
                            {"text": "4",  "style": "table2"},
                            {"text": "5",  "style": "table2"},
                            {"text": "6",  "style": "table2"},
                            {"text": "7",  "style": "table2"},
                            {"text": "8",  "style": "table2"},
                            {"text": "9",  "style": "table2"},
                            {"text": "10",  "style": "table2"},
                            {"text": "11",  "style": "table2"},
                            {"text": "12",  "style": "table2"}
                        ],
                    EndContent
                    BeginContent var cJson2
                        [
                            {"text": "",  "style": "table4"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table5"},
                            {"text": "",  "style": "table5"},
                            {"text": "",  "style": "table5"},
                            {"text": "",  "style": "table5"},
                            {"text": "",  "style": "table5"},
                            {"text": "",  "style": "table5"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table2"}
                        ],
                    EndContent
                    BeginContent var cJson4
                        [
                            {"text": "",  "style": "table4", "headlineLevel": 1},
                            {"text": "",  "style": "table2", "headlineLevel": 1},
                            {"text": "",  "style": "table2", "headlineLevel": 1},
                            {"text": "",  "style": "table2", "headlineLevel": 1},
                            {"text": "",  "style": "table5", "headlineLevel": 1},
                            {"text": "",  "style": "table5", "headlineLevel": 1},
                            {"text": "",  "style": "table5", "headlineLevel": 1},
                            {"text": "",  "style": "table5", "headlineLevel": 1},
                            {"text": "",  "style": "table5", "headlineLevel": 1},
                            {"text": "",  "style": "table5", "headlineLevel": 1},
                            {"text": "",  "style": "table2", "headlineLevel": 1},
                            {"text": "",  "style": "table2", "headlineLevel": 1}
                        ],
                    EndContent
                    BeginContent var cJson3
                        [
                            {"colSpan": 4,"text": "", "border": [false, false, false, false ],  "style": "table2"},
                            {},
                            {},
                            {},
                            {"text": "", "border": [false, false, false, false ],  "style": "table5"},
                            {"text": "",  "style": "table2"},
                            {"text": "",  "style": "table5"},
                            {"text": "",  "style": "table5"},
                            {"text": "",  "style": "table5"},
                            {"text": "",  "style": "table5"},
                            {"text": "", "border": [false, false, false, false ],  "style": "table2"},
                            {"text": "", "border": [false, false, false, false ],  "style": "table2"}
                        ]
                ]
                }
		},
        {
            "margin": [40, 20, 0, 0],
            "style": "table2",
			"table": {
			    "widths": [60, 10, 80, 10, 80, 10, 80],
				"body":[
                        [
                            {"text": "", "border": [false, false, false, false], "alignment": "center"},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, true]},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, true]},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, true]}
                        ],
                        [
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, false], "alignment": "center"},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, false], "alignment": "center"},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, false], "alignment": "center"}
                        ],
                        [
                            {"text": "", "border": [false, false, false, false], "alignment": "center"},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, true]},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, true]},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, true]}
                        ],
                        [
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, false], "alignment": "center"},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, false], "alignment": "center"},
                            {"text": "", "border": [false, false, false, false]},
                            {"text": "", "border": [false, false, false, false], "alignment": "center"}
                        ]
                    ] 
			}
		}

		]
    }
    EndContent

    nMiddlePage:= 29
    nCountPage := 0
    nCountLine := 0
    nCntLnPage := 0
    nSumStr    := 0
    nFirstPage  := 7
    nMoreStrFrst:= 12

    If nDataLen > 1 
        For nX :=1 To nDataLen
            nCountLine := RU02R0504_CountLine(aData[nX][8])
            nCntLnPage += nCountLine
            If (nCntLnPage >= nFirstPage .AND. (nCntLnPage <= nMoreStrFrst) .AND. nCountPage==0 .AND. nX != nDataLen)
                nFirstPage := nCntLnPage
            EndIf
            if (nCntLnPage > nFirstPage .AND. nCountPage==0);
                    .OR. (nCntLnPage > nMiddlePage) ;
                    .OR. (nCntLnPage > 25 .AND. nX == nDataLen)
                cJson1 += cJson4
                nCntLnPage := nCountLine
                nCountPage ++
            Else
                cJson1 += cJson2
            EndIf
        Next
    Else
        cJson1 += cJson2
    EndIf

    cJson := cJson1 + cJson3 
   
    oData:FromJson(cJson)
    
Return oData

/*/
{Protheus.doc} RU02R0504_CountLine(cWord)
    function counts the number of lines
    @type function
    @params cWord Character, the product's name from invoice
    @author Dsidorenko
    @since 24/03/2023
    @version 13.1.2310
    @return nCountLine Numeric, Count line
/*/

Static Function RU02R0504_CountLine(cWord)

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
                If(nSumStr >= MAX_SYMBOL_IN_LINE)
                    nCountLine ++
                    nSumStr := IiF(nSumStr == MAX_SYMBOL_IN_LINE, 0, (Len(aWord[nY]) + IIF(nY != Len(aWord), 1, 0))) 
                
                EndIf
                if (nSumStr < MAX_SYMBOL_IN_LINE .AND. nY == Len(aWord))
                    nCountLine ++
                EndIf
            EndIf
        Next
    Else
        nCountLine := 2
    EndIf

Return nCountLine
//Merge Russia R14                   
