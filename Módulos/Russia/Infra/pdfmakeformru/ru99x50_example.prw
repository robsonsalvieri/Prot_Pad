#INCLUDE 'totvs.ch'

Function U_ru99x50_example()
Local oData 
Local cJson
Local aData 
Local oOptions
//Gets PDF Template
oData := GetTemplate()

//Inserts data in template 
//Since functions are not suspported in JSON and needed for some customizations on pdfmake, notation being used is from package JSON-fn (http://www.eslinstructor.net/jsonfn/)

aData := { {'2021','26','06','2021'}}
oData := SetData('0',aData,@oData)

aData := { {'20701000001','8(495)999-99-99','3664069397','366401001'},;
	 	{'Агент наме попасд лгуи'},;
	 	{'xxx'},;
	  	{'20701000001','ззз20701000001'}}

oData := SetData('1',aData,@oData)

aData := { {'111112321'},;
	 	{'Королёв','Сергей','Павлович'},;
	  	{'1','15','06','1978','643'},;
	  	{'21','68 02 444666'}}
oData := SetData('2',aData,@oData)

aData := { {'13'},;
				{;
						{'01','жж','33333','4444','55555'},;
						{'02','жж','33333','4444','55555'},;
						{'03','жж','33333','4444','55555'},;
						{'04','жж','33333','4444','55555'},;
						{'05','жж','33333','4444','55555'},;
						{'06','жж','33333','4444','55555'},;
						{'07','жж','33333','4444','55555'},;
						{'08','жж','33333','4444','55555'},;
						{'09','жж','33333','4444','55555'},;
						{'10','жж','33333','4444','55555'},;
						{'11','жж','33333','4444','55555'},;
						{'12','жж','33333','4444','55555'},;
						{'13','жж','33333','4444','55555'},;
						{'14','жж','33333','4444','55555'},;
						{'15','жж','33333','4444','55555'},;
						{'16','жж','33333','4444','55555'},;
						{'17','жж','33333','4444','55555'};
				};
	}
oData := SetData('3',aData,@oData)

aData := {;
		{"126","1,400.00"},;
		{"320","10,000"},;
		{"311","532,896.33"};
		}
oData := SetData('4',aData,@oData)
aData := {;
		{"2,775,129.82","288,058"},;
		{"2,215,833.49","288,058"},;
		{"288,058","288,058"};
		}
oData := SetData('5',aData,@oData)

cJson := oData:ToJson()

//Gets Options for PDF template
oOptions := Ru99x50_01_GetOptionsTemplate()
oOptions['showSidebarButton']	:=	.F.

cOptions := oOptions:ToJson()
//Calls library with FWCALLAPP
ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions,'ru99x50_example')

Return

/*/{Protheus.doc} SetData
Sets data in JSON File.
Data is set by section, for each section there is an array for each line, and each of the lines has the fields to be filled in.

Example:
Section 2

	ИНН в Российской Федерации #aData[1,1]#
	Фамилия aData[2,1] Имя aData[2,2] Отчество * aData[2,3]
	Статус налогоплательщика #Data[3,1]#  Дата рождения #Data[3,2]#  .#Data[3,3]#  . #Data[3,4]#  Гражданство (код страны) #Data[3,5]# 
	Код документа, удостоверяющего личность: #Data[4,1]# Серия и номер документа #Data[4,2]#

	aData[1] =  {'111112321'}
	aData[2] =  {'Королёв','Сергей','Павлович'}
	aData[3] =  {'1','15','06','1978','643'}
	aData[4] =  {'21','68 02 444666'}

This is just one example of how this could be used.
Another option would be using PLACEHOLDERS and STRATRAN or i18N to substitute them on JSON string instead of JSON Object

cJson:="
{
	"text": "_KPP_",
	"border": [false, false, false, true],
	"style": "normal"
}
"
cJson := StrTran(cJson,"_KPP_","111112321")

Or 


cJson:="
{
	"text": "#1[]#",
	"border": [false, false, false, true],
	"style": "normal"
}
"
adata := {}
aadd(aData,"111112321") (where each POSITION N in a Data is linke to <N>#[desc]#  place holder)
cJson := i18n(cJson,aData)

@type function
@author Bruno Sobieski
@since 7/27/2021
@param cSection, character, Section Code
@param aData, array, Data to fill section
@param oData, object, Json object
@return object, Object received with data inserted
/*/
Static Function SetData(cSection,aData,oData)
Local nX
Local nCol
Local aEmptyLine
Do Case
//Header subtitle
Case cSection == "0"
	oData['content'][4]["columns"][1]["table"]["body"][1][2]["text"]	:=	aData[1][1]
//Day
	oData['content'][4]["columns"][1]["table"]["body"][1][4]["text"]	:=	aData[1][2]
//Month
	oData['content'][4]["columns"][1]["table"]["body"][1][6]["text"]	:=	aData[1][3]
//Year2
	oData['content'][4]["columns"][1]["table"]["body"][1][8]["text"]	:=	aData[1][4]
Case cSection == "1"
	oData['content'][6]["table"]["body"][1][2]["text"]	:=	aData[1][1]
	oData['content'][6]["table"]["body"][1][4]["text"]	:=	aData[1][2]
	oData['content'][6]["table"]["body"][1][6]["text"]	:=	aData[1][3]
	oData['content'][6]["table"]["body"][1][8]["text"]	:=	aData[1][4]

	oData['content'][7]["table"]["body"][1][2]["text"]	:=	aData[2][1]

	oData['content'][8]["table"]["body"][1][2]["text"]	:=	aData[3][1]

	oData['content'][9]["table"]["body"][1][2]["text"]	:=	aData[4][1]
	oData['content'][9]["table"]["body"][1][4]["text"]	:=	aData[4][2]
Case cSection == "2"

	oData['content'][11]["table"]["body"][1][2]["text"]	:=	aData[1][1]

	oData['content'][12]["table"]["body"][1][2]["text"]	:=	aData[2][1]
	oData['content'][12]["table"]["body"][1][4]["text"]	:=	aData[2][2]
	oData['content'][12]["table"]["body"][1][6]["text"]	:=	aData[2][3]

	oData['content'][13]["table"]["body"][1][2]["text"]	:=	aData[3][1]
	oData['content'][13]["table"]["body"][1][4]["text"]	:=	aData[3][2]
	oData['content'][13]["table"]["body"][1][6]["text"]	:=	aData[3][3]
	oData['content'][13]["table"]["body"][1][8]["text"]	:=	aData[3][4]
	oData['content'][13]["table"]["body"][1][10]["text"]	:=	aData[3][5]

	oData['content'][14]["table"]["body"][1][2]["text"]	:=	aData[4][1]
	oData['content'][14]["table"]["body"][1][4]["text"]	:=	aData[4][2]

Case cSection == "3"
	oData['content'][15]["table"]["body"][1][2]["text"]	:=	aData[1][1]
	//Left Table
	For nX:=1 To Min(Len(aData[2]),15)
		oData['content'][16]["columns"][1]["table"]["body"][1+nX]	:=	aData[2][nX]
	Next
	//Right Table
	For nX:=16 To Len(aData[2])
		oData['content'][16]["columns"][3]["table"]["body"][1+nX-15]	:=	aData[2][nX]
	Next

Case cSection == "4"
	aEmptyLine := Array(8)
	aEmptyLine	:=	aFill(aEmptyLine,"")
	nCOl := 1
	For nX:=1 To Len(aData)
		If nCol == 9
			AAdd(oData['content'][18]["table"]["body"],aEmptyLine)		
			nCol := 1
		Endif
		oData['content'][18]["table"]["body"] [Len(oData['content'][18]["table"]["body"]) ][nCol++] := aData[nX,1]
		oData['content'][18]["table"]["body"] [Len(oData['content'][18]["table"]["body"]) ][nCol++] := aData[nX,2]
	Next
Case cSection == "5"
	For nX:=1 To Len(aData)
		oData['content'][20]["table"]["body"] [nX][2]["text"] := aData[nX,1]
		oData['content'][20]["table"]["body"] [nX][4]["text"] := aData[nX,2]
	Next
EndCase

Return oData


/*/{Protheus.doc} GetTemplate
Gets an example tempalte based on NFDL HR Report. This is intended to be just an example
Do not forget to check in your template variable sections (tables with variable amount of lines) and how spae will be filled in according to these variations
On this Angualr object is currently supported only Arial FONT, if any other font needed, please implement on PDFMAKEFORMRU package in angular applications.

You may validate format defined here in  pdfmake site playground
@type function
@author Bruno Sobieski
@since 8/2/2021
@return oData, JSON Object with PDF template according to pdfMake Documentation and with JSON-fn package syntax.
/*/
Static Function GetTemplate()
Local cJson
Local oData := JsonObject():New()

BeginContent var cJson
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
			"margin": [0, 18, 0, 0],
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
			"text": "Форма по КНД 1175018",
			"style": "subTitle"
		},
		{
			"text": "СПРАВКА О ДОХОДАХ И СУММАХ НАЛОГА ФИЗИЧЕСКОГО ЛИЦА",
			"style": "title",
			"margin": [10, 10, 0, 0]
		}, {
			"margin": [200, 0],
			"columns": [{
					"table": {
						"body": [
							[{
									"text": "за",
									"border": [false, false, false, false],
									"style": "subTitle"
								}, {
									"text": "2021 S0[1]",
									"border": [false, false, false, true],
									"style": "subTitle"
								}, {
									"text": "год от",
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
			"margin": [0, 40, 0, 0]
		}, {
			"margin": [0, 7, 10, 0],
			"layout": {
				"hLinestyle": 	"function (i, node) {return { dash: {length: 1, space: 1 } } }"	
				},
			"table": {
				"width": "100%",
				"widths": [100, "*", "*", "*", "*", "*", "*", "*"],
				"body": [
					[{
							"text": "Код по ОКТМО",
							"border": [false, false, false, false],
							"style": "normal",
							"alignment": "left"
						}, {
							"text": "20701000001 S1[1]",
							"border": [false, false, false, true],
							"style": "normal"
						}, {
							"text": "Телефон ",
							"border": [false, false, false, false],
							"style": "normal",
							"alignment": "right"
						}, {
							"text": "8(495)999-99-99 S1[2]",
							"border": [false, false, false, true],
							"style": "normal"
						}, {
							"text": "ИНН",
							"border": [false, false, false, false],
							"style": "normal",
							"alignment": "right"
						}, {
							"text": "3664069397 S1[3]",
							"border": [false, false, false, true],
							"style": "normal"
						}, {
							"text": "КПП",
							"border": [false, false, false, false],
							"style": "normal",
							"alignment": "right"
						}, {
							"text": "366401001 S1[4]",
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
				"widths": [100, "*"],
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
				"widths": [200, 20],
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
				"widths": [200, 60, 5, 60],
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
			"margin": [0, 10, 0, 0]
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
				"widths": [130, 50],
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
				"widths": [45, 155, 35, 165, 65, 100],
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
				"widths": [195, 35, 130, 205],
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
				"widths": [195, 25, 15],
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
							"alignment": "right"
						}
					]
				]
			}
		}, {
			"margin": [0, 7, 0, 0],
			"columns": [{
					"width": 290,
					"style": "normalCentered",
					"table": {
						"width": "100%",
						"widths": ["14.5%", "14.5%", "27.3%", "14.5%", "29.1%"],
						"body": [
							["Месяц", "Код дохода", "Сумма дохода", "Код вычета", "Сумма вычета"],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""]
						]
					}
				}, {
					"text": "",
					"width": 15
				}, {
					"width": 290,
					"style": "normalCentered",
					"table": {
						"width": "100%",
						"widths": ["14.5%", "14.5%", "27.3%", "14.5%", "29.1%"],
						"body": [
							["Месяц", "Код дохода", "Сумма дохода", "Код вычета", "Сумма вычета"],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""],
							["..", "", "", "", ""]
						]
					}
				}
			]
		}, {
			"text": "4. Стандартные, социальные и имущественные налоговые вычеты",
			"style": "subTitle",
			"margin": [0, 7, 0, 0]
		}, {
			"margin": [0, 7, 0, 0],
			"width": "100%",
			"style": "normalCentered",
			"table": {
				"width": "100%",
				"widths": ["8%", "16%", "8%", "17%", "8%", "18%", "8%", "18%"],
				"body": [
					["Код вычета", "Сумма вычета", "Код вычета", "Сумма вычета", "Код вычета", "Сумма вычета", "Код вычета", "Сумма вычета"],
					["", "", "", "", "", "", "", ""]
				]
			}
		}, {
			"text": "5. Общие суммы дохода и налога ",
			"style": "subTitle",
			"margin": [0, 17, 0, 0]
		}, {
			"margin": [0, 7, 0, 0],
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
			"margin": [0, 25, 0, 0],
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

oData:FromJson(cJson)


Return oData


