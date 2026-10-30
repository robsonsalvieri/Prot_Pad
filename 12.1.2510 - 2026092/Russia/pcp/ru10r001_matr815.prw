#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ru10r001.CH"

#DEFINE DELETEFILE .T.

/*/{Protheus.doc} ru10r001
Report in DATAGRID format based on MATR815
@type function
@version  
@author bsobieski
@since 29/07/2023
/*/
Function ru10r001()

	SX1->(DbSetOrder(1))
	If !SX1->(DBSeek('RU10R001'))
		If !IsBlind()
			MsgInfo(STR0012,STR0011)
		Endif
	Else
		While ru10r001P()

		Enddo
	Endif	
Return


/*/{Protheus.doc} ru10r001P
Responsible for printing the report
@type function
@version  
@see pergunte description: https://jiraproducao.totvs.com.br/browse/RULOC-5378
@author bsobieski
@since 28/07/2023
@return logic, Returns if it should be executed once more when quited
/*/
Static Function ru10r001P()
	Local cFile          := Lower(CriaTrab(NIL, .F.)  )
	LOCAL nHandle
	Local oJson          := JsonObject():New()
	Local cControlKey    := cFile //StrZero(Randomize( 1, 999999 ),6)
	Local lRecall := .F.
	If Pergunte('RU10R001',.T.)

		oJson['controlKey']  := 'F'+cControlKey
		oJson['mv_par01']    := mv_par01
		oJson['mv_par02']    := mv_par02
		oJson['mv_par03']    := mv_par03
		oJson['mv_par04']    := mv_par04
		oJson['mv_par05']    := mv_par05
		oJson['mv_par06']    := mv_par06
		oJson['mv_par07']    := mv_par07
		oJson['mv_par08']    := mv_par08
		oJson['mv_par09']    := mv_par09
		oJson['mv_par10']    := mv_par10
		oJson['mv_par11']    := mv_par11
		oJson['mv_par12']    := mv_par12
		oJson['mv_par13']    := mv_par13
		oJson['mv_par14']    := mv_par14
		oJson['mv_par15']    := mv_par15

		oJson['files']    := {'SECTION1'}

		//CREATES DATA
		oProcess := MsNewProcess():New({|| CreateTMP(oProcess,'F'+cControlKey, 'SECTION1')}, STR0001 , STR0002, .T.) //"Generating data..." ## "Please wait..."
		oProcess:Activate()


		nHandle        := FCREATE(cFile+".dxparam", 0)
		FWRITE(nHandle, oJson:toJSon())
		FCLOSE(nHandle)

		lRecall := RU99X1203_DATAGRID3('ru10r001Def','ru10r001DD',cFile, DELETEFILE,'rusdatagrid03')
		//Delete parametrization file
		STATICCALL(RU99X13_DXMODELS,CleanFiles,cFile)

	Endif
Return lRecall

/*/{Protheus.doc} CreateTMP
Creates temporary table for DATAGRID3 report standard
@type function
@version  
@author bsobieski
@since 28/07/2023
@param oProcess, object, Execution control object for progress bar
@param cControlKey, character, Control key to generate file name and save parameters
@param cSection1, character, Section name 
@return nil
/*/
Static Function CreateTMP(oProcess,cControlKey,cSection1)
	Local aStru1  := {}
	Local nX
	Local nZ
	Local aFields:={}
	Local aData:={}
	Local aFldJson:={}
	Local oBulk
	Local oRet
//Id field is mandatory and must be a unique ID and the link with section 2 FATHERID field
	Aadd(aStru1,{"ID"	         ,"N",10,0})
	Aadd(aStru1,{"H8_RECURSO"	,"C",GetSx3Cache( "H8_RECURSO" , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"H1_DESCRI"	,"C",GetSx3Cache( "H1_DESCRI" , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"H1_CALEND"   ,"C",GetSx3Cache( "H1_CALEND" , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"H8_OP"	      ,"C",GetSx3Cache( "H8_OP"     , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"H8_QUANT"	   ,"N",GetSx3Cache( "H8_QUANT"  , "X3_TAMANHO" ),GetSx3Cache( "G2_SETUP" , "X3_DECIMAL" )})
	Aadd(aStru1,{"G2_SETUP"	   ,"N",GetSx3Cache( "G2_SETUP"  , "X3_TAMANHO" ),GetSx3Cache( "G2_SETUP" , "X3_DECIMAL" )})
	Aadd(aStru1,{"H8_DTINI"	   ,"D",GetSx3Cache( "H8_DTINI"  , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"H8_HRINI"	   ,"C",GetSx3Cache( "H8_HRINI"  , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"START"	      ,"C",20,0})
	Aadd(aStru1,{"H8_DTFIM"	   ,"D",GetSx3Cache( "H8_DTFIM"  , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"H8_HRFIM"	   ,"C",GetSx3Cache( "H8_HRFIM"  , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"FINISH"	   ,"C",20,0})
	Aadd(aStru1,{"H8_ROTEIRO"	,"C",GetSx3Cache( "H8_ROTEIRO", "X3_TAMANHO" ),0})
	Aadd(aStru1,{"H8_FERRAM"	,"C",GetSx3Cache( "H8_FERRAM" , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"H4_DESCRI"	,"C",GetSx3Cache( "H4_DESCRI" , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"H8_OPER"	   ,"C",GetSx3Cache( "H8_OPER"   , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"H8_DESDOBR"	,"C",GetSx3Cache( "H8_DESDOBR", "X3_TAMANHO" ),0})
	Aadd(aStru1,{"C2_NUM"	   ,"C",GetSx3Cache( "C2_NUM"    , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"C2_ITEM"	   ,"C",GetSx3Cache( "C2_ITEM"   , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"C2_SEQUEN"	,"C",GetSx3Cache( "C2_SEQUEN" , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"C2_ITEMGRD"	,"C",GetSx3Cache( "C2_ITEMGRD", "X3_TAMANHO" ),0})
	Aadd(aStru1,{"C2_PRODUTO"	,"C",GetSx3Cache( "C2_PRODUTO", "X3_TAMANHO" ),0})
	Aadd(aStru1,{"B1_DESC"	   ,"C",GetSx3Cache( "B1_DESC"   , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"C2_TPOP"	   ,"C",GetSx3Cache( "C2_TPOP"   , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"C2_ROTEIRO"	,"C",GetSx3Cache( "C2_ROTEIRO", "X3_TAMANHO" ),0})
	Aadd(aStru1,{"C2_STATUS"	,"C",GetSx3Cache( "C2_STATUS" , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"B1_OPERPAD"	,"C",GetSx3Cache( "B1_OPERPAD", "X3_TAMANHO" ),0})
	Aadd(aStru1,{"G2_DESCRI"	,"C",GetSx3Cache( "G2_DESCRI" , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"G2_TPOPER"	,"C",GetSx3Cache( "G2_TPOPER" , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"G2_TEMPAD"	,"C",GetSx3Cache( "G2_TEMPAD" , "X3_TAMANHO" ),0})
	Aadd(aStru1,{"G2_FORMSTP"	,"C",GetSx3Cache( "G2_FORMSTP" , "X3_TAMANHO"),0})

	TCInternal(30, 'AUTORECNO')
//Table names must have as SUFFIX "_"+cControlKey, this is required to avoid user being able to read any table from REST service for report
	DbCreate(cSection1+"_"+cControlKey,aStru1,"TOPCONN")
	TCInternal(30, 'OFF')

	oProcess:SetRegua1(3)
	oProcess:IncRegua1(STR0010) //'Querying data...'

	oRet := GETREPORTDATA(oProcess)

	oBulk := FWBulk():new(cSection1+"_"+cControlKey)
	aFields := {}
	For nX:=1 To Len(aStru1)
		aAdd(aFields, {aStru1[nX,1]})
		oBulk:SetFields(aFields)
	Next
	oProcess:SetRegua2(oRet['COUNT'])
	lSaved := .F.
	For nX:=1 To oRet['COUNT']
		oProcess:IncRegua2()
		lSaved := .F.
		aFldJson := oRet['DATA'][nX]:GetNames()
		aData := {nX}
		For nZ :=2 To Len(aFields)
			If Ascan(aFldJson,aFields[nZ][1]) == 0
				If (aStru1[nZ,2]=="N")
					AAdd(aData,0)
				ElseIf (aStru1[nZ,2]=="D")
					AAdd(aData,Ctod(''))
				Else
					AAdd(aData,'')
				Endif
			Else
				AAdd(aData,oRet['DATA'][nX][aFields[nZ][1]])
			Endif
		Next nZ
		oBulk:addData(aData)
		If Mod(nX,100) == 0
			oBulk:Flush()
			lSaved := .T.
		Endif
	Next
	If !lSaved
		oBulk:Flush()
	Endif
	oBulk:Close()
	oBulk:Destroy()
	oBulk := Nil
	oProcess:IncRegua1()

Return

/*/{Protheus.doc} ru10r001Def
Returns to DATAGRID3 the report definitions
@type function
@version  
@author bsobieski
@since 28/07/2023
@param cKey, character, Control key to read parameters file
@return Character, Returns JSON String with DATAGRID3 setup format
/*/
Function ru10r001Def(cKey)
	Local oJson1 := GetDxModel('main')
	Local oCol
	Local nX
	Local oSummary
	Local oLookup
	Local oIdLabel
	Local oDD
	Local oParamsValue
	Local oParams
	Local nAnswer
	Local aFields1    := {;
		"H8_RECURSO","H1_DESCRI","H1_CALEND","H8_OP","G2_SETUP","H8_QUANT","H8_DTINI","H8_HRINI",'START',"H8_DTFIM","H8_HRFIM",'FINISH',;
		"H8_ROTEIRO","H8_FERRAM","H4_DESCRI",;
		"H8_OPER","H8_DESDOBR","C2_NUM","C2_ITEM","C2_SEQUEN","C2_ITEMGRD","C2_PRODUTO","B1_DESC","C2_TPOP","C2_ROTEIRO","C2_STATUS",;
		"B1_OPERPAD",;
		"G2_DESCRI","G2_TPOPER","G2_TEMPAD",;
		"G2_FORMSTP"}

	oParamsValue := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey)
	aJsonParams := {} //JsonObject():New()
	If oParamsValue['error'] == Nil
		SX1->(DbSetOrder(1))
		SX1->(DbSeek('RU10R001'))
		nX:=1
		While !EOF() .And. Alltrim(SX1->X1_GRUPO) == 'RU10R001'
			oParams := GetDxModel('reportParams')
			oParams['label'] := X1Pergunt()
			&('mv_par'+StrZero(nX,2)) :=	oParamsValue['mv_par'+StrZero(nX,2)]
			If (SX1->x1_gsc=='C')
				nAnswer := oParamsValue['mv_par'+StrZero(nX,2)]
				If nAnswer >= 1 .and. nAnswer<=5
					oParams['value'] := &('X1DEF'+StrZero(nAnswer,2)+"()")
				Else
					oParams['value'] := oParamsValue['mv_par'+StrZero(nX,2)]
				Endif
			Else
				oParams['value'] := oParamsValue['mv_par'+StrZero(nX,2)]
			Endif
			aHelps := GetHlpSoluc(Iif(Empty(AllTrim(SX1->X1_HELP)), "." + AllTrim(SX1->X1_GRUPO) + SX1->X1_ORDEM + ".", SX1->X1_HELP))
			If Len(aHelps) >= 1
				oParams['help']  := Alltrim(aHelps[1])
			Endif
			aadd(aJsonParams,oParams)
			FreeObj(oParams)
			SX1->(DbSkip())
			nX++
		Enddo
	Endif
	FreeObj(oParamsValue)

//Create definition for main grid
	SX3->(DBSETORDER(2))
	For nX:=1 To Len(aFields1)
		oCol := GetDxModel('columns')
		oCol['dataField'] := aFields1[nX]
		If aFields1[nX] == 'START'
			oCol['caption']   := STR0003 //'Start'
			oCol['dataType']  := "datetime"
			oCol['allowGrouping']	:=	.T.
			oCol['groupIndex'] := 1
		ElseIf aFields1[nX] == 'FINISH'
			oCol['caption']   := STR0004 // 'Finish'
			oCol['dataType']  := "datetime"
			oCol['allowGrouping']	:=	.T.
			oCol['groupIndex'] := 2
		ElseIf SX3->(DbSeek(aFields1[nX]))
			oCol['caption']   :=  Alltrim(X3Descric())// Alltrim(X3TITULO())
			oCol['dataType']  := IIF(SX3->X3_TIPO == "N","number",IIF(SX3->X3_TIPO == "D","date","string"))
			cBox :=X3CBOX()
			If !Empty(cBox)
				oLookup := GetDxModel('lookup')
				oLookup['dataSource'] 	 := getOptionsX3CBox(cBox)
				If Alltrim(SX3->X3_CAMPO) == 'C2_STATUS'
					oIdLabel := GetDxModel('labelValueJson')
					oIdLabel['value'] := 'Z'
					oIdLabel['label'] := STR0005 //'Not working time'
					AAdd(oLookup['dataSource'],oIdLabel)
					FreeObj(oIdLabel)
					oIdLabel := Nil
				Endif
				oCol['lookup']     := oLookup
				FreeObj(oLookup)
				oLookup:= Nil
			Endif
			oCol['allowGrouping']	:=	SX3->X3_TIPO <>'N'
			If Alltrim(SX3->X3_CAMPO)=='H8_RECURSO'
				oCol['groupIndex'] := 0
			Endif
		Endif
		if !(aFields1[nX] $ "H8_OPER,H8_DESDOBR,H8_QUANT,START,G2_SETUP,FINISH,H8_ROTEIRO" + ;
				"C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,C2_TPOP,C2_STATUS,B1_DESC,H1_DESCRI,H1_CALEND"+;
				"H4_DESCRI,G2_DESCRI,G2_TPOPER")
			oCol['visible'] := .F.
		Endif

		AADd(oJson1['columns'], oCol)
		FreeObj(oCol)
	Next
	if mv_par15 == 2
		oJson1['width'] 	:= nil
	Else
		oJson1['columnResizingMode'] 	:= 'widget'
	Endif
	oJson1['height'] 	:= '80vh'
	oJson1['sorting']['mode'] 	:= 'multiple'
	oJson1['filterRow']['visible']  := .T.

	oSummary := GetDxModel('summary')

	aadd(oSummary['groupItems'],GetDxModel('groupItems'))
	oSummary['groupItems'][1]['column'] := 'H8_RECURSO'
	oSummary['groupItems'][1]['alignByColumn']   := .T.
	oSummary['groupItems'][1]['showInGroupFooter'] := .F.
	oSummary['groupItems'][1]['summaryType'] := 'count'

	aadd(oSummary['totalItems'],GetDxModel('totalItems'))
	oSummary['totalItems'][1]['column'] := 'H8_RECURSO'
	oSummary['totalItems'][1]['showInColumn'] := 0
	oSummary['totalItems'][1]['alignment']    := 'left'
	oSummary['totalItems'][1]['summaryType']  := 'count'

	oJson1['summary']:= oSummary

	FreeObj(oSummary)

// Define drilldown relations
	oDD := GetDxModel('drillDownLink')
	oDD['callerGridId'] 		:= "main"
	oDD['callerGridColumn']	:= "*"
	oDD['drillDownGridId'] 	:= "document"

	cRet :=  '{"data": { "sections": ['+;
		'{"dxDataGridSetup": '+oJson1:toJSon()+", "+;
		' "title": "'+STR0006+'",'+;//"Allocation"
		' "code": "main",'+;
		' "section": 0,'+;
		' "file": "SECTION1"}'+;
		'],'+;
		'"drillDowns": ['+;
		'{'+;
		' "title": "DrillDown2",'+;
		' "code": "document",'+;
		' "drillDownType": "ADVPL"}'+;
		'],'+;
		' "drillDownDefs": [' +;
		oDD:toJSon()+;
		'],'+;
		' "params": '+FwJSonSerialize(aJsonParams,.F.,.F.)+", "+;
		' "showRecall": true, '+;
		' "sectionsQuantity": 1,'+;
		' "mainTitle": "'+STR0007+'"},'+;
		' "status": "ok",'+;
		' "ok": "ok",'+;
		' "statusText": "ok"}'

	FreeObj(oJson1)
	FreeObj(oDD)

Return cRet

/*/{Protheus.doc} ru10r001Dd
Function called on drilldown routine from datagrid3
@type function
@version  
@author bsobieski
@since 28/07/2023
@param cColumn, character, Column clicked
@param cGridID, character, Grid ID from where was called the drilldown
@param cDrillDownID, character, Drilldwon ID for where the double click was directed
@param cKey, character, Control key to read parameters file
@param cBody, character, Conains line data in JSON Format
@return variant, return_description
/*/
Function ru10r001Dd(cColumn, cGridID,cDrillDownID,cKey,cBody)
	Local oJson
	Local oData
	Local cRet
	Private cCadastro := ''
	Do Case
	Case cGridID == "main"
		oJson := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey)
		If oJson['error'] == Nil
			oData:= JSONOBJECT():NEW()
			oData:FROMJSON(cBody)
			If !Empty(cColumn) .And. (oData[cColumn] <> Nil) .and. !Empty(oData['H8_OP'])
				SC2->(DbSetOrder(1))
				SC2->(DbSeek(xFilial()+oData['H8_OP']))
				SX2->(DbSetOrder(1))
				SX2->(DbSeek('SC2'))
				cCadastro := X2NOME()
				A650View('SC2',SC2->(Recno()),2)
			Endif
			FreeObj(oData)
		Endif
		FreeObj(oJson)
	EndCase

Return cRet

/*/{Protheus.doc} GETREPORTDATA
Function copied (and adapted) from MATR815 to generate data for report
@type function
@version  
@author bsobieski
@since 28/07/2023
@param oProcess, object, Execution control object for progress bar
@return JSON Object, Json Object with data
/*/
Static Function GETREPORTDATA(oProcess)
	Local  cOrderBy
	Local  cWhere01
	Local  oJsonRet := JsonObject():New()
	Local  oRet := JsonObject():New()
	Local cQryCarga := GetNextAlias()
	Local nx, nZ
	Local nCount := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas - RU10R001                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01            // Start Date from                       ³
//³ mv_par02            // Start Date to                         ³
//³ mv_par03            // Finish Date from                      ³
//³ mv_par04            // Finish date to                        ³
//³ mv_par05            // POs from                              ³
//³ mv_par06            // POs to                                ³
//³ mv_par07            // Resources from                        ³
//³ mv_par08            // Resources to                          ³
//³ mv_par09            // Tools from                            ³
//³ mv_par10            // Tools to                              ³
//³ mv_par11            // Product from                          ³
//³ mv_par12            // Product to                            ³
//³ mv_par13            // Impr. OP's Firmes, Previstas ou Ambas ³
//³ mv_par14            // Not working time as OP  (Add/Ignore)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Pergunte("RU10R001",.F.)

	oRet['DATA'] := {}
	oRet['COUNT']:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//MakeSqlExpr("RU10R001")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Condicao Where para filtrar OP's                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cWhere01 := "%"
	If	Upper(TcGetDb()) $ 'ORACLE,DB2,POSTGRES,INFORMIX'
		cWhere01  += "SC2.C2_ITEM = SUBSTR(SH8.H8_OP,7,2) AND "
		cWhere01  += "SC2.C2_SEQUEN = SUBSTR(SH8.H8_OP,9,3) AND "
		cWhere01  += "SC2.C2_ITEMGRD = SUBSTR(SH8.H8_OP,12,2)"
	Else
		cWhere01  += "SC2.C2_ITEM = SUBSTRING(SH8.H8_OP,7,2) AND "
		cWhere01  += "SC2.C2_SEQUEN = SUBSTRING(SH8.H8_OP,9,3) AND "
		cWhere01  += "SC2.C2_ITEMGRD = SUBSTRING(SH8.H8_OP,12,2) "
	EndIf

	If mv_par13  == 1
		cWhere01  += "AND SC2.C2_TPOP = 'P'  "
		lRet:=.F.
	ElseIf mv_par13  == 2
		cWhere01  += "AND SC2.C2_TPOP IN (' ','P')"
	EndIf

	cWhere01 += "%"

	cOrderBy := "%"
	cOrderBy += " SH8.H8_FILIAL, SH8.H8_RECURSO, SH8.H8_DTINI, SH8.H8_HRINI " // Por Recurso
	cOrderBy += "%"

	BeginSql Alias cQryCarga

SELECT SH8.H8_FILIAL, SH8.H8_OP, SH8.H8_OPER, SH8.H8_DESDOBR, SH8.H8_QUANT, SH8.H8_DTINI, SH8.H8_HRINI, SH8.H8_SETUP,
	SH8.H8_DTFIM,SH8.H8_HRFIM, SH8.H8_BITUSO, SH8.H8_RECURSO, SH8.H8_BITINI, SH8.H8_ROTEIRO, SH8.H8_FERRAM,
	SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SC2.C2_PRODUTO, SC2.C2_TPOP, SC2.C2_ROTEIRO, SC2.C2_STATUS,
	SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_DESC, SB1.B1_OPERPAD,
	SH1.H1_FILIAL, SH1.H1_CODIGO, SH1.H1_DESCRI, SH1.H1_CALEND,
	SH4.H4_FILIAL, SH4.H4_CODIGO, SH4.H4_DESCRI,
	SG2.G2_FILIAL, SG2.G2_PRODUTO, SG2.G2_CODIGO, SG2.G2_OPERAC, SG2.G2_DESCRI, SG2.G2_TPOPER, SG2.G2_TEMPAD,
	SG2.G2_FORMSTP, SG2.G2_SETUP
	

FROM %table:SH8% SH8

LEFT JOIN %table:SC2% SC2 ON
	SC2.C2_FILIAL = %xFilial:SC2% AND SC2.C2_NUM = SUBSTRING(SH8.H8_OP,1,6) AND %Exp:cWhere01% 
	AND SC2.C2_PRODUTO BETWEEN %Exp:mv_par11% AND %Exp:mv_par12%
	AND SC2.%NotDel%

LEFT JOIN %table:SB1% SB1 ON
	SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD = SC2.C2_PRODUTO AND SB1.%NotDel%
	
LEFT JOIN %table:SH1% SH1 ON
	SH1.H1_FILIAL = %xFilial:SH1% AND SH1.H1_CODIGO = SH8.H8_RECURSO AND SH1.%NotDel%

LEFT JOIN %table:SH4% SH4 ON
	SH4.H4_FILIAL = %xFilial:SH4% AND SH4.H4_CODIGO = SH8.H8_FERRAM AND SH4.%NotDel%

LEFT JOIN %table:SG2% SG2 ON
	SG2.G2_FILIAL = %xFilial:SG2% AND SG2.G2_PRODUTO = SC2.C2_PRODUTO AND 
	SG2.G2_CODIGO = SH8.H8_ROTEIRO AND SG2.G2_OPERAC = SH8.H8_OPER AND SG2.%NotDel%

WHERE SH8.H8_FILIAL = %xFilial:SH8% 
	AND SH8.H8_DTINI   BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
	AND SH8.H8_DTFIM   BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	AND SH8.H8_OP      BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
	AND SH8.H8_RECURSO BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
	AND SH8.H8_FERRAM  BETWEEN %Exp:mv_par09% AND %Exp:mv_par10%
	AND SH8.%NotDel%
	
ORDER BY %Exp:cOrderBy%

	EndSql
	oProcess:IncRegua1(STR0008)//'Loading report data...'
	oProcess:SetRegua2(500)

	cMindate := '999999999'
	cMaxDate := ''
	aResources:={}
	dbSelectArea(cQryCarga)

	While !(cQryCarga)->(Eof())
		nCount++
		If Mod(nCount,500)==0
			oProcess:SetRegua2(500)
		Endif
		oProcess:IncRegua2()

		oJsonRet := JsonObject():New()
		oJsonRet['H8_FILIAL']:=(cQryCarga)->H8_FILIAL
		oJsonRet['H8_OP']	:=(cQryCarga)->H8_OP
		oJsonRet['H8_OPER']:=(cQryCarga)->H8_OPER
		oJsonRet['H1_CALEND']:=(cQryCarga)->H1_CALEND
		oJsonRet['H8_DESDOBR']:=(cQryCarga)->H8_DESDOBR
		oJsonRet['H8_QUANT']:=(cQryCarga)->H8_QUANT
		oJsonRet['START']	:=	FWTimeStamp(6, Stod((cQryCarga)->H8_DTINI), (cQryCarga)->H8_HRINI+":00")
		oJsonRet['H8_DTINI']:=	(cQryCarga)->H8_DTINI
		oJsonRet['H8_HRINI']:=(cQryCarga)->H8_HRINI
		oJsonRet['FINISH']	:=	FWTimeStamp(6, Stod((cQryCarga)->H8_DTFIM), (cQryCarga)->H8_HRFIM+":00")
		oJsonRet['H8_DTFIM']:=(cQryCarga)->H8_DTFIM
		oJsonRet['H8_HRFIM']:=(cQryCarga)->H8_HRFIM
		oJsonRet['H8_BITUSO']:=ConvTime((cQryCarga)->H8_BITUSO)
		oJsonRet['H8_RECURSO']	:=	(cQryCarga)->H8_RECURSO
		oJsonRet['H8_ROTEIRO']:=(cQryCarga)->H8_ROTEIRO
		oJsonRet['H8_FERRAM']:=(cQryCarga)->H8_FERRAM
		oJsonRet['C2_NUM']:=(cQryCarga)->C2_NUM
		oJsonRet['C2_ITEM']:=(cQryCarga)->C2_ITEM
		oJsonRet['C2_SEQUEN']:=(cQryCarga)->C2_SEQUEN
		oJsonRet['C2_ITEMGRD']:=(cQryCarga)->C2_ITEMGRD
		oJsonRet['C2_PRODUTO']:=(cQryCarga)->C2_PRODUTO
		oJsonRet['C2_TPOP']:=(cQryCarga)->C2_TPOP
		oJsonRet['C2_STATUS']:=IIF(Empty((cQryCarga)->C2_STATUS),"N",(cQryCarga)->C2_STATUS)
		oJsonRet['C2_ROTEIRO']:=(cQryCarga)->C2_ROTEIRO
		oJsonRet['B1_FILIAL']:=(cQryCarga)->B1_FILIAL
		oJsonRet['B1_COD']:=(cQryCarga)->B1_COD
		oJsonRet['B1_DESC']:=(cQryCarga)->B1_DESC
		oJsonRet['B1_OPERPAD']:=(cQryCarga)->B1_OPERPAD
		oJsonRet['H1_CODIGO']:=(cQryCarga)->H1_CODIGO
		oJsonRet['H1_DESCRI']:=(cQryCarga)->H1_DESCRI
		oJsonRet['H4_CODIGO']:=(cQryCarga)->H4_CODIGO
		oJsonRet['H4_DESCRI']:=(cQryCarga)->H4_DESCRI
		oJsonRet['G2_PRODUTO']:=(cQryCarga)->G2_PRODUTO
		oJsonRet['G2_CODIGO']:=(cQryCarga)->G2_CODIGO
		oJsonRet['G2_OPERAC']:=(cQryCarga)->G2_OPERAC
		oJsonRet['G2_DESCRI']:=(cQryCarga)->G2_DESCRI
		oJsonRet['G2_TPOPER']:=(cQryCarga)->G2_TPOPER
		oJsonRet['G2_TEMPAD']:=(cQryCarga)->G2_TEMPAD
		oJsonRet['G2_FORMSTP']:=(cQryCarga)->G2_FORMSTP
		oJsonRet['G2_SETUP'] :=(cQryCarga)->G2_SETUP
		oJsonRet['H8_SETUP']	   := ConvTime((cQryCarga)->H8_SETUP)
		//TODO: Consider SHE and SH9 for blocks on calendar calculation . Only option 1 available
		If mv_par14 == 2
			If ((cQryCarga)->H8_DTINI < cMinDate)
				cMindate := (cQryCarga)->H8_DTINI
			Endif
			If ((cQryCarga)->H8_DTFIM > cMaxDate)
				cMaxDate := (cQryCarga)->H8_DTFIM
			Endif
			If Ascan(aResources,{|x| x[1] == (cQryCarga)->H8_RECURSO .and. x[2]==(cQryCarga)->H8_FILIAL}) == 0
				aadd(aResources,{(cQryCarga)->H8_RECURSO,(cQryCarga)->H8_FILIAL,(cQryCarga)->H1_CALEND,(cQryCarga)->H1_FILIAL,(cQryCarga)->H1_DESCRI})
			Endif
		Endif
		aadd(oRet['DATA'],oJsonRet)
		oRet['COUNT']++
		FreeObj(oJsonRet)
		oJsonRet:= Nil
		dbSelectArea(cQryCarga)
		dbSkip()
	EndDo
	aCalend := {}

//TODO: Consider SHE and SH9 for exceptions on calendar calculation
	For nX:=1 To Len(aResources)
		nCount++
		If Mod(nCount,500)==0
			oProcess:SetRegua2(500)
		Endif
		oProcess:IncRegua2()
		If (nPosCalend := Ascan(aCalend,{ |x| x[1] == aResources[nX,4] .and. x[2] == aResources[nX,3] })) == 0
			aTmpCalend := GetCalendAlloc(aResources[nX,4],aResources[nX,3],cMinDate,cMaxDate)
			aadd(aCalend,{aResources[nX,4],aResources[nX,3], aTmpCalend})
			nPosCalend:= Len(aCalend)
		Endif
		For nZ :=1 To Len(aCalend[nPosCalend,3])
			oJsonRet	:=	JsonObject():New()
			oJsonRet['H8_FILIAL']	:=	aResources[nX,2]
			oJsonRet['H8_RECURSO']	:=	aResources[nX,1]
			oJsonRet['H1_DESCRI']	:=	aResources[nX,5]
			oJsonRet['START']		   :=	FWTimeStamp(6, aCalend[nPosCalend,3,nZ,1], aCalend[nPosCalend,3,nZ,3]+":00")
//GetMiliseconds((cQryCarga)->H8_DTINI,(cQryCarga)->H8_HRINI)
			oJsonRet['H8_DTINI']	   :=	aCalend[nPosCalend,3,nZ,1]
			oJsonRet['H8_HRINI']	   :=	aCalend[nPosCalend,3,nZ,3]
			oJsonRet['FINISH']		:=	FWTimeStamp(6, aCalend[nPosCalend,3,nZ,4], aCalend[nPosCalend,3,nZ,6]+":00")
			oJsonRet['H8_DTFIM']	   :=	aCalend[nPosCalend,3,nZ,4]
			oJsonRet['H8_HRFIM']	   :=	aCalend[nPosCalend,3,nZ,6]
			oJsonRet['C2_STATUS']	:=	'Z'
			oJsonRet['H1_CALEND']	  :=	aResources[nX,3]

			aadd(oRet['DATA'],oJsonRet)
			oRet['COUNT']++
			FreeObj(oJsonRet)
			oJsonRet:= Nil
		Next
	Next
	(cQryCarga)->(DbCloseArea())
	dbSelectArea("SH8")
	Set Filter to
	dbCloseArea()
	oProcess:IncRegua1(STR0009)//'Saving report data...'

Return oRet

/*/{Protheus.doc} GetCalendAlloc
Gets calendar not working days/time x resource, Tools and cost center on 
dates requestes by parameter
@type function
@version  
@author bsobieski
@since 28/07/2023
@param cFilCalend, character, Calendat branch
@param cCalend, character, Calendar code
@param cMinDate, character, Minimum date
@param cMaxDate, character, Maximum date
@return variant, return_description
/*/
Static Function GetCalendAlloc(cFilCalend,cCalend,cMinDate,cMaxDate)
	Local nX
	Local nPrecisa  := SuperGetMV('MV_PRECISA')
	Local nMaxCalend
	Local aRecord
	Local nFirst
	Local nStartRecs
	Local nXIni
	Local cBit
	Local cBitAnt
	Local aRes
	Local nDay
	Local aDays
	Local cCalendar
	Local nStartDay
	Local nMinutesStart
	Local dDate
	Local cMinutesStart
	Local nMinutesEnd
	Local cMinutesEnd
	Local dDStart
	Local dDEnd
	Local aArea := GetArea()
	Local cFIlH7 := xFilial('SH7')
//						  1		    2		  3         4         5         6         7         8         9        10        11        12        13
//               123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789			
//	cCalendar 	:= 	"                                    XXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXX                                                            XXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXX                                                            XXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXX                                                            XXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXX                                                            XXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXXX                                                                                                                                                                                                                         "
	DbSelectArea('SH7')
	DbSetOrder(1)
	If DbSeek(IIf(Empty(cFilH7),cFilH7,cFilCalend)+cCalend)
		//cCalendar := Substr(cCalendar,1,Len(cCalendar)-1)
		cCalendar 	:=	SH7->H7_ALOC
		nMaxCalend	:=	Len(cCalendar)
		nFirst 		:= At('X',cCalendar)
		aRecord 	:= {}
		nStartRecs := 2
		If nFirst > 0
			cCalendar	:= cCalendar + Substr(cCalendar,1,nFirst)
			nStartTime 	:=	0
			nXIni 		:= 	-1
			cBitAnt := ''
			For nX:=1 To nMaxCalendar
				cBit := Substr(cCalendar,nX,1)
				if nX == nMaxCalendar
					If cBit == 'X'
						AAdd(aRecord,{nXIni-1,nX-1})
						nStartRecs := 1
					Else
						AAdd(aRecord,{nXIni-1,nX-1+ aRecord[1][2] })
					Endif
					Exit
				Else
					If cBit == 'X' .And. cBitAnt <> 'X'
						AAdd(aRecord,{nXIni-1,nX-1})
					ElseIf cBit == ' ' .And. cBitAnt <> ' '
						nXIni	:=	nX
					Endif
					cBitAnt := cBit
				Endif
			Next
		Else
			aadd(aRecord,{0,24*60/(60/nPrecisa)*7})
			nStartRecs := 1
		Endif
		aDays := {}
		For nX:=nStartRecs To Len(aRecord)
			nStartDay 	:= Int(aRecord[nX][1]/(24*nPrecisa))+1
			nPosDay 	:= Ascan(aDays,{|x| x[1]==nStartDay})
			If nPosDay == 0
				aadd(aDays,{nStartDay,{}})
				nPosDay := Len(aDays)
			Endif
			AAdd(aDays[nPosDay][2],{aRecord[nX][1],aRecord[nX][2]})
		Next

		dDate := Stod(cMindate)-1

		aRes := {}
		While dDate <= Stod(cMaxDate)+1
			nDay := Dow(dDate)-1
			If nDay == 0
				nDay := 7
			Endif
			If nDay <=Len(aDays)
				For nX:=1 to Len(aDays[nDay][2])
					dDStart 		:= dDate
					nMinutesStart 	:= (aDays[nDay][2][nX][1] * (60/nPrecisa)) - ( (nDay-1) * 24 * 60)
					nMinutesEnd 	:= (aDays[nDay][2][nX][2] * (60/nPrecisa)) - ( (nDay-1) * 24 * 60)
					If nMinutesEnd > 24 * 60
						dDEnd 		:=	dDStart + Int(nMinutesEnd/(24*60))
						nMinutesEnd :=	Mod(nMinutesEnd,(24*60))
					Else
						dDEnd 	:=	dDStart
					Endif
					cMinutesStart := StrZero(Int(nMinutesStart/60),2) + ":" + StrZero(Mod(nMinutesStart,60)/100*60,2)
					cMinutesEnd := StrZero(Int(nMinutesEnd/60),2) + ":" + StrZero(Mod(nMinutesEnd,60)/100*60,2)
					aadd(aRes,{dDStart,nMinutesStart,cMinutesStart,dDEnd,nMinutesEnd,cMinutesEnd})
				Next
			Endif
			dDate := dDate + 1
		Enddo
	Endif
	RestArea(aArea)
Return aRes
/*/{Protheus.doc} getOptionsX3CBox
    Retorna as opções do campo já formatadas

    @type  Function
    @author alison.kaique
    @since 22/06/2021
    @version 12.1.33

    @param cField, character, Id do campo

    @return aOptions, array, opções do campo
/*/
Static Function getOptionsX3CBox(cX3Cbox As Character) As Array
	Local aX3Cbox   As Array
	Local aOptions  As Array
	Local cContent  As Character
	Local cFunction As Character
	Local nIndex    As Numeric
	Local nPosition As Numeric
	Local jOption   As Json

	// verifica se possui chamada de função e se a função existe
	If (Left(cX3Cbox, 01) == '#')
		cFunction := SubStr(cX3Cbox, 02)

		If (FindFunction(cFunction))
			cX3Cbox := &(cFunction)
		Else
			cX3Cbox := ''
		EndIf
	EndIf

	aX3Cbox  := StrTokArr(cX3Cbox, ";")
	aOptions := {}

	For nIndex := 01 To Len(aX3Cbox)
		cContent := AllTrim(aX3Cbox[nIndex])
		nPosition := At('=', cContent)

		If (nPosition > 0)
			jOption := JsonObject():New()
			jOption['value'] := Left(cContent, nPosition - 01)
			jOption['label'] := SubStr(cContent, nPosition + 01)
			AAdd(aOptions, jOption)
		EndIf
	Next nIndex
	if ValType(jOption) <> "U"
		FreeObj(jOption)
	EndIf
Return aOptions
                   
//Merge Russia R14 

