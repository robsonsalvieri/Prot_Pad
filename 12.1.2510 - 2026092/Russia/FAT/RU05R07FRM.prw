#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RU05R07.CH"

#DEFINE MAX_SYMBOL_IN_LINE 42 //maximum number of characters in a line

    /*/{Protheus.doc} RU05R07Frm(nDataLen)
    @type Function
    @params nDataLen Numeric, number with array length.
    @param aData, array, Data to fill section
    @author Dsidorenko
    @since 08/02/2024 
    @version 12.1.2310
    @return oData, JSON Object with PDF template according to pdfMake Documentation and with JSON-fn package syntax.
    @see (http://pdfmake.org/playground.html#) 
    /*/
Function RU05R07Frm(nDataLen, aData)
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
        "pageMargins": [10, 5, 25, 10],
        "styles": {
            "header1": { 
                "font": "Arial",
                "fontSize": 7,
                "bold": false,
			    "alignment": "right"
            },
            "header2": {
                "fontSize": 9,
                "bold": true,
                "font": "Arial"
            },
            "table1": {
                "alignment": "center",
                "fontSize": 7,
                "bold": false,
                "font": "Arial"
            },
            "table2": {
                "fontSize": 5,
                "bold": false,
                "font": "Arial",
			    "alignment": "center"
            }
	    },
        "pageBreakBefore": "function (currentNode, followingNodesOnPage, nodesOnNextPage, previousNodesOnPage) {return currentNode.headlineLevel === 1;}",
        "content": [
            {"margin": [0, 0, 20, 0],"text": "", "style": "header1"},
            {"margin": [0, 0, 20, 0],"text": "", "style": "header1"},
            {"text": "", "style": ""},
            {
		    "margin": [0, 0, 0, 0],
			"table": {
			    "widths": [600, 90, 70],
				"body":[
                        [
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
                                "border": [false, false, false, true],
                                "style": "table1",
			                    "alignment": "left"
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
                                "style": "table1",
			                    "alignment": "center"
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false], 
                                "style": "table2"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [true, false, true, false],
                                "style": "table1",
			                    "alignment": "center"
                            }
                        ]
                    ] 
			    }
		    },
            {
		    "margin": [0, 0, 0, 0],
			"table": {
			    "widths": [60, 531, 90, 70],
				"body":[
                        [
                            {
                                "text": "",
                                "border": [false, false, false, true],
                                "style": "table1", 
                                "alignment": "left",
                                "colSpan": 2
                            },
                            {},
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1"
                            },
                            {
                                "text": "",
                                "border": [true, true, true, false],
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
                                "border": [false, false, false, false], 
                                "style": "table2"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [true, false, true, true]
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "colSpan": 2,
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1", 
                                "alignment": "right"
                            },
                            {},
                            {
                                "text": "",
                                "border": [true, true, true, true],
                                "style": "table1"
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1",
			                    "alignment": "right"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, true],
                                "style": "table1", 
                                "alignment": "left"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1", 
                                "alignment": "right"
                            },
                            {
                                "text": "",
                                "border": [true, false, true, false],
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
                                "border": [false, false, false, false], 
                                "style": "table2"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [true, false, true, false]
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1",
			                    "alignment": "right"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, true],
                                "style": "table1", 
                                "alignment": "left"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1", 
                                "alignment": "right"
                            },
                            {
                                "text": "",
                                "border": [true, true, true, false],
                                "style": "table1",
			                    "alignment": "center"
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false], 
                                "style": "table2"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [true, false, true, false],
                                "style": "table1",
			                    "alignment": "center"
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1",
			                    "alignment": "right"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, true],
                                "style": "table1", 
                                "alignment": "left"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, true],
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
                                "border": [false, false, false, false], 
                                "style": "table2"
                            },
                            {
                                "text": "",
                                "border": [true, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [true, false, true, false]
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false],
                                "style": "table1",
			                    "alignment": "right"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, true]
                            },
                            {
                                "text": "",
                                "border": [true, false, false, true],
                                "style": "table1"
                            },
                            {
                                "text": "",
                                "border": [true, false, true, true],
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
                                "border": [false, false, false, false], 
                                "style": "table2"
                            },
                            {
                                "text": "",
                                "border": [true, false, false, true],
                                "style": "table1"
                            },
                            {
                                "text": "",
                                "border": [true, false, true, false]
                            }
                        ],
                        [
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
                                "border": [true, false, false, true],
                                "style": "table1"
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
		    "margin": [120, 0, 0, 0],
			"table": {
			    "widths": [150, 100, 100, 103, 90, 70],
				"body":[
                        [
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [true, true, true, true],
			                    "alignment": "center",
			                    "style": "table1"
                            },
                            {
                                "text": "",
                                "border": [true, true, true, true],
			                    "alignment": "center",
			                    "style": "table1"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false],
			                    "alignment": "right",
			                    "style": "table1"
                            },
                            {
                                "text": "",
                                "border": [true, false, true, true],
			                    "alignment": "center",
			                    "style": "table1"
                            },
                            {
                                "text": "",
                                "border": [true, false, true, true]
                            }
                        ],
                        [
                            {"text": "",
                                "border": [false, false, false, false],
			                    "alignment": "right",
			                    "style": "header2"
                            },
                            {
                                "text": "",
                                "border": [true, true, true, true],
			                    "alignment": "right",
			                    "style": "table1"
                            },
                            {
                                "text": "",
                                "border": [true, true, true, true],
			                    "alignment": "center",
			                    "style": "table1"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false],
			                    "alignment": "right",
			                    "style": "header1"
                            },
                            {
                                "text": "",
                                "border": [true, true, true, true]
                            }
                        ]
                    ] 
			    }
		    },
            {"margin": [0, 0, 20, 0], "text": "", "style": "table1", "alignment": "right"},
            {
		    "margin": [10, 0, 0, 0],
                "table": {
                    "widths": [20, 150, 30, 30, 30, 35, 30, 30, 25, 40, 40, 50, 32, 50, 50],
                    "body": [
                        [
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"colSpan": 2, "text": "", "style": "table1"},
                            {},
                            {"colSpan": 2, "text": "", "style": "table1"},
                            {},
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"colSpan": 2, "text": "", "style": "table1"},
                            {},
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"colSpan": 2, "text": "", "style": "table1"},
                            {},
                            {"rowSpan": 2, "text": "", "style": "table1"}
                        ],
                        [
                            {},
                            {"text": "", "style": "table1"},
                            {"text": "", "style": "table1"},
                            {"text": "", "style": "table1"},
                            {"text": "", "style": "table1"},
                            {},
                            {"text": "", "style": "table1"},
                            {"text": "", "style": "table1"},
                            {},
                            {},
                            {},
                            {},
                            {"text": "", "style": "table1"},
                            {"text": "", "style": "table1"},
                            {}
                        ],
                        [
                            {"text": "1",  "style": "table1", "alignment": "center"},
                            {"text": "2",  "style": "table1", "alignment": "center"},
                            {"text": "3",  "style": "table1", "alignment": "center"},
                            {"text": "4",  "style": "table1", "alignment": "center"},
                            {"text": "5",  "style": "table1", "alignment": "center"},
                            {"text": "6",  "style": "table1", "alignment": "center"},
                            {"text": "7",  "style": "table1", "alignment": "center"},
                            {"text": "8",  "style": "table1", "alignment": "center"},
                            {"text": "9",  "style": "table1", "alignment": "center"},
                            {"text": "10",  "style": "table1", "alignment": "center"},
                            {"text": "11",  "style": "table1", "alignment": "center"},
                            {"text": "12",  "style": "table1", "alignment": "center"},
                            {"text": "13",  "style": "table1", "alignment": "center"},
                            {"text": "14",  "style": "table1", "alignment": "center"},
                            {"text": "15",  "style": "table1", "alignment": "center"}
                        ],
                    EndContent
                    BeginContent var cJson2
                        [
                            {"text": "",  "style": "table1", "alignment": "left"},
                            {"text": "",  "style": "table1", "alignment": "left"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {},
                            {},
                            {},
                            {},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "right"}
                        ]
                    EndContent
                    BeginContent var cJson4
                    ]
                }
		    },
            {"margin": [0, 0, 20, 0],"text": "", "style": "table1", "alignment": "right", "headlineLevel": 1},
            {
		    "margin": [10, 0, 0, 0],
                "table": {
                    "widths": [20, 150, 30, 30, 30, 35, 30, 30, 25, 40, 40, 50, 32, 50, 50],
                    "body": [
                        [
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"colSpan": 2, "text": "", "style": "table1"},
                            {},
                            {"colSpan": 2, "text": "", "style": "table1"},
                            {},
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"colSpan": 2, "text": "", "style": "table1"},
                            {},
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"rowSpan": 2, "text": "", "style": "table1"},
                            {"colSpan": 2, "text": "", "style": "table1"},
                            {},
                            {"rowSpan": 2, "text": "", "style": "table1"}
                        ],
                        [
                            {},
                            {"text": "", "style": "table1"},
                            {"text": "", "style": "table1"},
                            {"text": "", "style": "table1"},
                            {"text": "", "style": "table1"},
                            {},
                            {"text": "", "style": "table1"},
                            {"text": "", "style": "table1"},
                            {},
                            {},
                            {},
                            {},
                            {"text": "", "style": "table1"},
                            {"text": "", "style": "table1"},
                            {}
                        ],
                        [
                            {"text": "1",  "style": "table1", "alignment": "center"},
                            {"text": "2",  "style": "table1", "alignment": "center"},
                            {"text": "3",  "style": "table1", "alignment": "center"},
                            {"text": "4",  "style": "table1", "alignment": "center"},
                            {"text": "5",  "style": "table1", "alignment": "center"},
                            {"text": "6",  "style": "table1", "alignment": "center"},
                            {"text": "7",  "style": "table1", "alignment": "center"},
                            {"text": "8",  "style": "table1", "alignment": "center"},
                            {"text": "9",  "style": "table1", "alignment": "center"},
                            {"text": "10",  "style": "table1", "alignment": "center"},
                            {"text": "11",  "style": "table1", "alignment": "center"},
                            {"text": "12",  "style": "table1", "alignment": "center"},
                            {"text": "13",  "style": "table1", "alignment": "center"},
                            {"text": "14",  "style": "table1", "alignment": "center"},
                            {"text": "15",  "style": "table1", "alignment": "center"}
                        ],
                        [
                            {"text": "",  "style": "table1", "alignment": "left"},
                            {"text": "",  "style": "table1", "alignment": "left"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {},
                            {},
                            {},
                            {},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "right"}
                        ]
                    EndContent
                    BeginContent var cJson3
                        [
                            {"colSpan": 7,"text": "", "alignment": "right", "border": [false, false, false, false ],  "style": "table1"},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "right"}
                        ],
                        [
                            {"colSpan": 7,"text": "", "alignment": "right", "border": [false, false, false, false ],  "style": "table1"},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "center"},
                            {"text": "",  "style": "table1", "alignment": "right"},
                            {"text": "",  "style": "table1", "alignment": "right"}
                        ]
                ]
            }
		},
        {   
		    "margin": [10, 0, 0, 0],
			"table": {
			    "widths": [180, 300],
				"body":[
                        [
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, true]
                            }
                        ]
                    ] 
			}
		},
        {   
		    "margin": [10, 0, 0, 0],
			"table": {
			    "widths": [60, 420, 200],
				"body":[
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false], 
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            }
                        ]
                    ] 
			}
		},
		{   
		    "margin": [10, 0, 0, 0],
			"table": {
			    "widths": [230, 100, 200, 50, 150],
				"body":[
                        [
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [true, true, true, false]
                            }
                        ],
                        [
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false], 
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [true, false, true, true]
                            }
                        ]
                    ] 
			}
		},
        {   
		    "margin": [10, 0, 0, 0],
			"table": {
			    "widths": [40, 130, 42, 100, 200, 50, 150],
				"body":[
                        [
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [true, false, true, false]
                            }
                        ],
                        [
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false], 
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false], 
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [true, false, true, true]
                            }
                        ]
                    ] 
			}
		},
        {   
		    "margin": [10, 0, 0, 0],
			"table": {
			    "widths": [160, 145, 50, 20, 70, 120, 20, 120],
				"body":[
                        [
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "right"
                            },
                            {"text": "",
                                "border": [false, false, true, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "right"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            }
                        ],
                        [
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {
                                "text": "",
                                "border": [false, false, false, false]
                            },
                            {
                                "text": "",
                                "border": [false, false, true, false]
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
                                "border": [false, false, false, false]
                            }
                        ]
                    ]
			}
		},
        {   
		    "margin": [10, 0, 0, 0],
			"table": {
			    "widths": [90, 10,  245, 30, 40, 10, 290],
				"body":[
                        [
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, true, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "right"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            }
                        ],
                        [
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, true, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            }
                        ]

                    ]
                    
			}
		},
        {   
		    "margin": [10, 0, 0, 0],
			"table": {
			    "widths": [80, 70, 10, 70, 10, 98, 10, 40, 10, 290],
				"body":[
                        [
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, true, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            }
                        ],
                        [
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, true, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            }
                        ]
                    ]
			}
		},
		{   
		    "margin": [10, 0, 0, 0],
			"table": {
			    "widths": [110, 60, 10, 69, 10, 79, 10, 50, 80, 10, 80, 10, 80],
				"body":[
                        [
                            {"text": "",
                                "colSpan": 3,
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, true, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            }
                        ],
                        [
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, true, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            }
                        ],
                        [
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, true, false]
                            },
                            {"text": "",
                                "colSpan": 3,
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            }
                        ],
                        [
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, true, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table2",
			                    "alignment": "center"
                            }
                        ]

                    ]
                    
			}
		},
		{   
		    "margin": [10, 0, 0, 0],
			"table": {
			    "widths": [70, 20, 70, 30, 50, 49, 59, 40, 20, 70, 30, 50, 49],
				"body":[
                        [
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, true, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, false]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            },
                            {"text": "",
                                "border": [false, false, false, true]
                            },
                            {"text": "",
                                "border": [false, false, false, false],  
                                "style": "table1",
			                    "alignment": "left"
                            }
                        ]

                    ]
                    
			}
		}


		]
    }
    EndContent

    nMiddlePage:= 28
    nCountPage := 0
    nCountLine := 0
    nCntLnPage := 0
    nSumStr    := 0
    nFirstPage  := 1
    nMoreStrFrst:= 15

    If nDataLen > 1 
        For nX :=1 To nDataLen
            nCountLine := RU05R0704_CountLine(aData[nX][5])
            nCntLnPage += nCountLine
            If (nCntLnPage >= nFirstPage .AND. (nCntLnPage <= nMoreStrFrst) .AND. nCountPage==0 .AND. nX != nDataLen)
                nFirstPage := nCntLnPage
            EndIf
            if (nCntLnPage > nFirstPage .AND. nCountPage==0);
                    .OR. (nCntLnPage > nMiddlePage) ;
                    .OR. (nCntLnPage > 15 .AND. nX == nDataLen)
                cJson1 += cJson4
                nCntLnPage := nCountLine
                nCountPage ++
            Else
                if nX = 1
                    cJson1 += cJson2
                else
                    cJson1 := cJson1 + ", " + cJson2
                endif
            EndIf
        Next
    Else
        cJson1 += cJson2
    EndIf

    cJson := cJson1 + ", " + cJson3 

   
    oData:FromJson(cJson)

    oData['content'][7]["text"] := nCountPage + 1
    
Return oData

/*/
{Protheus.doc} RU05R0704_CountLine(cWord)
    function counts the number of lines
    @type function
    @params cWord Character, the product's name from invoice
    @author Dsidorenko
    @since 24/03/2023
    @version 12.1.2310
    @return nCountLine Numeric, Count line
/*/

Static Function RU05R0704_CountLine(cWord)

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
                   
                   
