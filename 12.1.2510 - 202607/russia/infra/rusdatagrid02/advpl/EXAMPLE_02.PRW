#INCLUDE "TOTVS.CH"
#DEFINE DELETEFILE .F.
// Is mandatory to have these static functions:

// GetDef(cKey)
//    Returns all object data definitions, receives cKey where parameters should be stored
//    IE: cKey=SC0005030 
// GetDD(cKey,cData, cColumn, cCode)
//    Returns data for datagrid cCode, related to cData data clicked, from cColumn. Parameters are defined by cKey
//    IE: 
//       cKey=SC0005030 
//       cData=01225001 //Data defined to be the link for drilldowns
//       cColum=B1_COD 
//       cCode='ProductDetails' //DataGrid code definition

Function U_DX_EX02(lRecall)
   While DX_EX02()

   Enddo
Return
Static Function DX_EX02()
Local cFile          := Lower(CriaTrab(NIL, .F.)  )
LOCAL nHandle       
Local oJson          := JsonObject():New()
Local cControlKey    := StrZero(Randomize( 1, 999999 ),6)
Local aParams        := {}
Local aRet           := {Space(len(SB1->B1_COD)),REPLICATE('Z',len(SB1->B1_COD))}
Local lRecall        := .F.
// Create Contol key
// Call parametrization
// Create data in temporary tables
//    All data tables must be suffixed as "_"+controlKey
// Save data from parameters and control key in file with extension dxparam
//    oJson['controlKey']  := 'F'+
//    oJson['mv_par01']    := mv_par01
//    oJson['mv_par02']    := mv_par02
//    oJson['mv_par03']    := mv_par03
//    oJson['mv_par04']    := mv_par04
//    oJson['mv_par05']    := mv_par05
//    oJson['mv_par06']    := mv_par06
// Call REPORT


aadd(aParams,{1,"Product from "  ,aRet[1],"@!",,'SB1',,,.F.})
aadd(aParams,{1,"Product to "    ,aRet[2],"@!",,'SB1',,,.F.})
CONOUT("SET reportParams = "+CFILE+ " to debug from angular APP")
If ParamBox(aParams,"Parameters for report ",)

   oJson['controlKey']  := 'F'+cControlKey
   oJson['mv_par01']    := mv_par01
   oJson['mv_par02']    := mv_par02

   oJson['files']    := {'SECTION1','SECTION2'}
   
   //CREATES DATA
   CreateTMP({mv_par01,mv_par02},'F'+cControlKey, 'SECTION1', 'SECTION2'  )

   nHandle        := FCREATE(cFile+".dxparam", 0)
   FWRITE(nHandle, oJson:toJSon())
   FCLOSE(nHandle)

   //Call DATAGRID2 function with following parameters
   // Function that will return format for report
   // Function that will return Drill down data or will ADVPL screen for report on drilldown clicked
   // File where parametrization and key to open tables is stored
   lRecall := RU99X12_DATAGRID2('U_EX02GetDef','U_EX02_DD',cFile, DELETEFILE)
   //Delete parametrization file
   STATICCALL(RU99X13_DXMODELS,CleanFiles,cFile)  
Endif

Return lRecall

Static Function CreateTMP(aRet,cControlKey,cSection1,cSection2)
Local cSql  := ""
Local aStru1  := {}
Local aStru2  := {}

//Id field is mandatory and must be a unique ID and the link with section 2 FATHERID field
Aadd(aStru1,{"ID"	,"C",GetSx3Cache( "B1_COD"    , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B1_COD"	,"C",GetSx3Cache( "B1_COD"    , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B1_DESC"	,"C",GetSx3Cache( "B1_DESC"   , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B1_UM"	   ,"C",GetSx3Cache( "B1_UM"     , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B1_TIPO"	,"C",GetSx3Cache( "B1_TIPO"   , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B1_GRUPO"	,"C",GetSx3Cache( "B1_GRUPO"  , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B2_QATU"	,"N",GetSx3Cache( "B2_QATU"   , "X3_TAMANHO" ),GetSx3Cache( "B2_QATU" , "X3_DECIMAL" )})
Aadd(aStru1,{"B2_VATU1"	,"N",GetSx3Cache( "B2_VATU1"   , "X3_TAMANHO" ),GetSx3Cache( "B2_VATU1" , "X3_DECIMAL" )})

//FATEHRId field is mandatory and must be a unique ID and the link with section 1 ID field
Aadd(aStru2,{"FATHERID"	,"C",GetSx3Cache( "B2_COD"    , "X3_TAMANHO" ),0})
Aadd(aStru2,{"B2_LOCAL"	,"C",GetSx3Cache( "B2_LOCAL"  , "X3_TAMANHO" ),0})
Aadd(aStru2,{"B2_CM1"	,"N",GetSx3Cache( "B2_CM1"    , "X3_TAMANHO" ),GetSx3Cache( "B2_CM1" , "X3_DECIMAL" )})
Aadd(aStru2,{"B2_VATU1"	,"N",GetSx3Cache( "B2_VATU1"  , "X3_TAMANHO" ),GetSx3Cache( "B2_VATU1" , "X3_DECIMAL" )})
Aadd(aStru2,{"B2_QATU"	,"N",GetSx3Cache( "B2_QATU"   , "X3_TAMANHO" ),GetSx3Cache( "B2_QATU" , "X3_DECIMAL" )})

TCInternal(30, 'AUTORECNO')
//Table names must have as SUFFIX "_"+cControlKey, this is required to avoid user being able to read any table from REST service for report
DbCreate(cSection1+"_"+cControlKey,aStru1,"TOPCONN")
DbCreate(cSection2+"_"+cControlKey,aStru2,"TOPCONN")
TCInternal(30, 'OFF')

   cSql  := " insert into "+cSection1+"_"+cControlKey+" (ID, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO,  B2_QATU,B2_VATU1 ) "
   cSql  += " SELECT B1_COD, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, SUM(B2_QATU) AS B2_QATU , SUM(B2_VATU1) AS B2_VATU1
   cSql  += "   FROM "+RetSqlName('SB1') +" SB1,"+RetSqlName('SB2') +" SB2 "
   cSql  += " WHERE B1_FILIAL = '"+xFilial('SB1')+"' "
   cSql  += " AND B2_FILIAL = '"+xFilial('SB2')+"' "
   cSql  += " AND B1_COD BETWEEN '"+aRet[1]+"' AND '"+aRet[2]+"' "
   cSql  += " AND B1_COD = B2_COD "
   cSql  += " AND SB1.D_E_L_E_T_= ' ' "
   cSql  += " AND SB2.D_E_L_E_T_= ' ' "
   cSql  += " GROUP BY B1_COD,B1_DESC,B1_GRUPO,B1_TIPO,B1_UM "
   TCSQLEXEC(cSql)
   
   cSql  := ""
   cSql  += " INSERT INTO "+cSection2+"_"+cControlKey+"  ( FATHERID, B2_LOCAL, B2_QATU,B2_CM1,B2_VATU1 ) " 
   cSql  += " SELECT  B2_COD ,B2_LOCAL, B2_QATU,B2_CM1,B2_VATU1  FROM "+RetSqlName('SB2') +" SB2 "
   cSql  += " WHERE B2_FILIAL = '"+xFilial('SB2')+"' "
   cSql  += " AND B2_COD BETWEEN '"+aRet[1]+"' AND '"+aRet[2]+"' "
   cSql  += " AND SB2.D_E_L_E_T_= ' ' "
   TCSQLEXEC(cSql)

Return
Function U_EX02GetDef(cKey)
Local oJson := GetDxModel('main')
Local oJson2:= GetDxModel('main')
Local oJson3:= GetDxModel('main')
Local oParam
Local oDataGridDD1:= GetDxModel('main')
Local oSummary := GetDxModel('summary')
Local oMD 
Local oDD1
Local oDD2 
Local oDD3 
Local oDD4
Local oCol 
Local nX
Local aFields     := {"B1_COD", "B1_DESC","B1_UM", "B1_TIPO", "B1_GRUPO","B2_QATU","B2_VATU1"}
Local aFieldsFlat := {"B1_COD", "B1_DESC","B1_UM", "B1_TIPO", "B1_GRUPO", "B2_LOCAL","B2_QATU","B2_VATU1","B2_CM1"}
Local aFieldsKDX  := {"D3_EMISSAO","D3_DOC","D3_QUANT","D3_LOCAL","D3_CUSTO1"}
//Create definition for main grid
SX3->(DBSETORDER(2))
For nX:=1 To Len(aFields)
   oCol := GetDxModel('columns')
   oCol['dataField'] := aFields[nX]
   If SX3->(DbSeek(aFields[nX]))
      oCol['caption']   :=  Alltrim(X3Descric())// Alltrim(X3TITULO())
      oCol['dataType']  := IIF(SX3->X3_TIPO == "N","number",IIF(SX3->X3_TIPO == "D","date","string"))
      If SX3->X3_TIPO == "N"
         oFormat := JsonObject():New() //Define customized algnment for 
         oFormat['type'] := "fixedPoint"
         oFormat['precision'] := 2
         oCol['format'] := oFormat
         FreeObj(oFormat)
      Endif
      //oCol['width']     := Max(SX3->X3_TAMANHO * 5,40)
   Endif
   if (aFields[nx]=="B1_UM")
      oCol['allowGrouping']	:=	.F.
   Else
	   oCol['allowGrouping']	:=	.T.
   Endif
   if (aFields[nx]=="B1_TIPO")
      oCol['allowFiltering']	:=	.F.
   endif
   AADd(oJson['columns'], oCol)
   FreeObj(oCol)
Next

//Create definition for section inside grid item (not mandatory)
aFields := {"B2_LOCAL", "B2_QATU","B2_CM1","B2_VATU1"}
For nX:=1 To Len(aFields)
   oCol := GetDxModel('columns')
   oCol['dataField'] := aFields[nX]
   If SX3->(DbSeek(aFields[nX]))
      oCol['caption']   :=  Alltrim(X3Descric())
      oCol['dataType']  := IIF(SX3->X3_TIPO == "N","number",IIF(SX3->X3_TIPO == "D","date","string"))
      //oCol['width']     := Max(SX3->X3_TAMANHO * 5,40)
   Endif
	oCol['allowGrouping']	:=	.T.
   AADd(oJson2['columns'], oCol)
   FreeObj(oCol)
Next

//Setup filters and standards for SB1

//Setup filters and standards for SB2
oJson2['filterRow']['visible']  := .F.
oJson2['height']  := '100%'
oJson2['width']  := '97vw'
oJson2['scrolling']['mode']  := 'infinite'
oJson2['paging']['enabled'] 	 := .F.
oJson2['pager']['visible'] 	 := .F.

oMD := GetDxModel('masterDetail')
oMD['enabled']    := .T.
oMD['template']   := 'balances'
oJson['masterDetail'] := oMD
FreeObj(oMD)

oSummary['texts']['sum']  :=   "Totals: {0}"

aadd(oSummary['groupItems'],GetDxModel('groupItems'))
oSummary['groupItems'][1]['column'] := 'B2_QATU'
oSummary['groupItems'][1]['alignByColumn']   := .T.
oSummary['groupItems'][1]['showInGroupFooter'] := .F.
oSummary['groupItems'][1]['summaryType'] := 'sum'

oFormat := JsonObject():New() //Define customized algnment for 
oFormat['type'] := "fixedPoint"
oFormat['precision'] := 2
oSummary['groupItems'][1]['valueFormat'] := oFormat

FreeObj(oFormat)

aadd(oSummary['groupItems'],GetDxModel('groupItems'))
oSummary['groupItems'][2]['column'] := 'B2_VATU1'
oSummary['groupItems'][2]['alignByColumn']   := .T.
oSummary['groupItems'][2]['showInGroupFooter'] := .F.
oSummary['groupItems'][2]['summaryType'] := 'sum'

oFormat := JsonObject():New() //Define customized algnment for 
oFormat['type'] := "fixedPoint"
oFormat['precision'] := 2
oSummary['groupItems'][2]['valueFormat'] := oFormat

FreeObj(oFormat)

aadd(oSummary['totalItems'],GetDxModel('totalItems'))
oSummary['totalItems'][1]['column'] := 'B1_COD'
oSummary['totalItems'][1]['showInColumn'] := 0
oSummary['totalItems'][1]['alignment']    := 'left'
oSummary['totalItems'][1]['summaryType']  := 'count'
/*
	oRet['alignByColumn'] 			:= .F.
	oRet['column'] 					:= Nil
	oRet['displayFormat'] 			:= Nil
	oRet['showInColumn'] 			:= Nil
	oRet['showInGroupFooter'] 		:= .F.
	oRet['skipEmptyValues'] 			:= Nil
	oRet['summaryType'] 			:= Nil
	oRet['valueFormat'] 			:= Nil
*/

oJson3['summary']:= oSummary

// Flat view sections setup
// 1-Automatic
//   Just define showFlatView as true, and it will be created joining both sections sent
// 2-Define special SETUP, but exactly same columns as in 2 defined sections
//   Define showFlatView as true
//   Define flatViewSection with setup
//   No need to define columns
// 3-Define special SETUP, with special columns (in this example, is needed to setup columns to define GROUPINDEX for Product code)
//   Define showFlatView as true
//   Define flatViewSection with setup
//   Define columns
//
//   In all cases data will be taken and combined from previous sections

For nX:=1 To Len(aFieldsFlat)
   oCol := GetDxModel('columns')
   oCol['dataField'] := aFieldsFlat[nX]
   If SX3->(DbSeek(aFieldsFlat[nX]))
      oCol['caption']   :=  Alltrim(X3Descric())
      oCol['dataType']  :=  IIF(SX3->X3_TIPO == "N","number",IIF(SX3->X3_TIPO == "D","date","string"))
      if (aFieldsFlat[nX]=='B1_COD')
         oCol['groupIndex']     := 0
      Endif
   Endif
	oCol['allowGrouping']	:=	.T.
   AADd(oJson3['columns'], oCol)
   FreeObj(oCol)
Next

// Define drilldown relations
oDD1 := GetDxModel('drillDownLink')
oDD1['callerGridId'] 		:= "products"
oDD1['callerGridColumn']	:= "*"
oDD1['drillDownGridId'] 	:= "kardex"

// Define drilldown relations
oDD2 := GetDxModel('drillDownLink')
oDD2['callerGridId'] 		:= "balances"
oDD2['callerGridColumn']	:= "*"
oDD2['drillDownGridId'] 	:= "kardex"

// Define drilldown relations
oDD3 := GetDxModel('drillDownLink')
oDD3['callerGridId'] 		:= "kardex"
oDD3['callerGridColumn']	:= "*"
oDD3['drillDownGridId'] 	:= "document"

// Define drilldown relations
oDD4 := GetDxModel('drillDownLink')
oDD4['callerGridId'] 		:= "flatView"
oDD4['callerGridColumn']	:= "*"
oDD4['drillDownGridId'] 	:= "kardex"

For nX:=1 To Len(aFieldsKDX)
   oCol := GetDxModel('columns')
   oCol['dataField'] := aFieldsKDX[nX]
   If SX3->(DbSeek(aFieldsKDX[nX]))
      oCol['caption']   :=  Alltrim(X3Descric())
      oCol['dataType']  := IIF(SX3->X3_TIPO == "N","number",IIF(SX3->X3_TIPO == "D","date","string"))
   Endif
   If aFieldsKDX[nX] == "D3_EMISSAO"
	   oCol['allowGrouping']	:=	.T.
   Endif      
   AADd(oDataGridDD1['columns'], oCol)
   FreeObj(oCol)
Next
oParamsValue := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey)  
aJsonParams := {} //JsonObject():New()
If oParamsValue['error'] == Nil
   oParams := GetDxModel('reportParams')
   oParams['label'] := "From product"
   oParams['value'] := oParamsValue['mv_par01']
   oParams['help']  := "Initial product to filter"
   aadd(aJsonParams,oParams)
   FreeObj(oParams)
   oParams:= GetDxModel('reportParams')
   oParams['label'] := "To product"
   oParams['value'] := oParamsValue['mv_par02']
   oParams['help']  := "Final product to filter"
   aadd(aJsonParams,oParams)
   FreeObj(oParams)

Endif
FreeObj(oParamsValue)

cRet :=  '{"data": { "sections": ['+;
                                    '{"dxDataGridSetup": '+oJson:toJSon()+", "+;
                                    ' "title": "Section 1",'+;
                                    ' "code": "products",'+;
                                    ' "section": 0,'+;
                                    ' "file": "SECTION1"},'+;
                                    '{"dxDataGridSetup": '+oJson2:toJSon()+", "+;
                                    ' "title": "Section2",'+;
                                    ' "code": "balances",'+;
                                    ' "section": 1,'+;
                                    ' "file": "SECTION2"}'+;
                                    '],'+;
                     '"drillDowns": ['+;
                                    '{"dxDataGridSetup": '+oDataGridDD1:toJSon()+", "+;
                                    ' "title": "DrillDown 1",'+;
                                    ' "code": "kardex",'+;
                                    ' "section": 3,'+;
                                    ' "drillDownType": "angular"},'+;
                                    '{'+;
                                    ' "title": "DrillDown 2",'+;
                                    ' "code": "document",'+;
                                    ' "drillDownType": "ADVPL"}'+;
                                    '],'+;
                   ' "drillDownDefs": [' +;
                                       oDD1:toJSon()+','+;
                                       oDD2:toJSon()+','+;
                                       oDD3:toJSon()+','+;
                                       oDD4:toJSon()+;
                                      '],'+;
                   ' "sectionsQuantity": 2,'+;
                   ' "flatViewSection": '+oJson3:toJSon()+", "+;
                   ' "showFlatView": true,'+;
                   ' "params": '+FwJSonSerialize(aJsonParams,.F.,.F.)+", "+;
                   ' "showRecall": true, '+;
                   ' "mainTitle": "TestReport" },'+;
         ' "status": "ok",'+;
         ' "ok": "ok",'+;
         ' "statusText": "ok"}'

FreeObj(oJson)
FreeObj(oJson2)
FreeObj(oJson3)
FreeObj(oSummary)
FreeObj(oDD1)
FreeObj(oDD2)
FreeObj(oDD3)
FreeObj(oDD4)
FreeObj(oDataGridDD1)

Return cRet


Function U_EX02_DD(cColumn, cGridID,cDrillDownID,cKey,cBody)
Local aStru := {}
Local cFile := CriaTrab(Nil,.F.)
Local oJson
Local oData
Local cRet 
Local nHandle
Local cTitle := ""
Do Case
Case cGridID == "products"
   oJson := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey)  
   If oJson['error'] == Nil
      oData:= JSONOBJECT():NEW()
      oData:FROMJSON(DecodeUtf8(cBody))
      If (oData['B1_COD'] <> Nil)
         Aadd(aStru,{"ID"	         ,"N",10       ,0})
         Aadd(aStru,{"D3_COD"	      ,"C",GetSx3Cache( "D3_COD"       , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_EMISSAO"	,"D",GetSx3Cache( "D3_EMISSAO"   , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_DOC"	      ,"C",GetSx3Cache( "D3_DOC"       , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_LOCAL"	   ,"C",GetSx3Cache( "D3_LOCAL"     , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_QUANT"	   ,"N",GetSx3Cache( "D3_QUANT"     , "X3_TAMANHO" ),GetSx3Cache( "D3_QUANT" , "X3_DECIMAL" )})
         Aadd(aStru,{"D3_CUSTO1"	   ,"N",GetSx3Cache( "D3_CUSTO1"    , "X3_TAMANHO" ),GetSx3Cache( "D3_CUSTO1" , "X3_DECIMAL" )})

         TCInternal(30, 'AUTORECNO')
         //Table names must have as SUFFIX "_"+cControlKey, this is required to avoid user being able to read any table from REST service for report
         DbCreate(cFile+"_"+oJson['controlKey'],aStru,"TOPCONN")
         TCInternal(30, 'OFF')
         cSql  := " insert into "+cFile+"_"+oJson['controlKey']+" (ID, D3_COD, D3_EMISSAO, D3_DOC, D3_LOCAL, D3_QUANT, D3_CUSTO1 ) "
         cSql  += " SELECT R_E_C_N_O_, D3_COD, D3_EMISSAO, D3_DOC, D3_LOCAL, D3_QUANT, D3_CUSTO1 
         cSql  += "   FROM "+RetSqlName('SD3') +" SD3 "
         cSql  += " WHERE D3_FILIAL = '"+xFilial('SD3')+"' "
         cSql  += " AND D3_COD  =  '"+oData['B1_COD']+"' "
         cSql  += " AND D_E_L_E_T_= ' ' "
         TCSQLEXEC(cSql)
         If !EMpty(tcsqlerror())
            cRet := '{"title": "'+tcsqlerror()+'"}'
         Else
            cRet := '{"file":"'+cFile+'","title": "'+cTitle+'"}'
         Endif
         aadd(oJson['files'],cFile)
         nHandle        := Fopen(cKey+".dxparam", 2)
         FWRITE(nHandle, oJson:toJSon())
         FCLOSE(nHandle)
         FreeObj(oJson)
         FreeObj(oData)
      Else
         cRet := '{"message": "Not found"}'
      Endif
   Endif
Case (cGridID == "kardex")
   // Nao ha drill down do Kardex
   cRet := '{"message": "Not found"}'
Case (cGridID == "balances" .or. cGridID == "flatView")
   oJson := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey)  
   If oJson['error'] == Nil
      oData:= JSONOBJECT():NEW()
      oData:FROMJSON(DecodeUtf8(cBody))
      If (oData['B1_COD'] <> Nil .or. oData['FATHERID'] <> nil) .And.oData['B2_LOCAL'] <> nil
         Aadd(aStru,{"ID"	         ,"N",10       ,0})
         Aadd(aStru,{"D3_COD"	      ,"C",GetSx3Cache( "D3_COD"       , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_EMISSAO"	,"D",GetSx3Cache( "D3_EMISSAO"   , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_DOC"	      ,"C",GetSx3Cache( "D3_DOC"       , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_LOCAL"	   ,"C",GetSx3Cache( "D3_LOCAL"     , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_QUANT"	   ,"N",GetSx3Cache( "D3_QUANT"     , "X3_TAMANHO" ),GetSx3Cache( "D3_QUANT" , "X3_DECIMAL" )})
         Aadd(aStru,{"D3_CUSTO1"	   ,"N",GetSx3Cache( "D3_CUSTO1"    , "X3_TAMANHO" ),GetSx3Cache( "D3_CUSTO1" , "X3_DECIMAL" )})

         TCInternal(30, 'AUTORECNO')
         //Table names must have as SUFFIX "_"+cControlKey, this is required to avoid user being able to read any table from REST service for report
         DbCreate(cFile+"_"+oJson['controlKey'],aStru,"TOPCONN")
         TCInternal(30, 'OFF')
         cSql  := " insert into "+cFile+"_"+oJson['controlKey']+" (ID, D3_COD, D3_EMISSAO, D3_DOC, D3_LOCAL, D3_QUANT, D3_CUSTO1 ) "
         cSql  += " SELECT R_E_C_N_O_, D3_COD, D3_EMISSAO, D3_DOC, D3_LOCAL, D3_QUANT, D3_CUSTO1 
         cSql  += "   FROM "+RetSqlName('SD3') +" SD3 "
         cSql  += " WHERE D3_FILIAL = '"+xFilial('SD3')+"' "
         If cGridID == "flatView"
            cSql  += " AND D3_COD  =  '"+oData['B1_COD']+"' "
         Else
            cSql  += " AND D3_COD  =  '"+oData['FATHERID']+"' "
         Endif
         cSql  += " AND D3_LOCAL  =  '"+oData['B2_LOCAL']+"' "
         cSql  += " AND D_E_L_E_T_= ' ' "
         TCSQLEXEC(cSql)

         If !EMpty(tcsqlerror())
            cRet := '{"title": "'+tcsqlerror()+'"}'
         Else
            cRet := '{"file":"'+cFile+'","title": "'+cTitle+'"}'
         Endif
     
         aadd(oJson['files'],cFile)
         nHandle        := Fopen(cKey+".dxparam", 2)
         FWRITE(nHandle, oJson:toJSon())
         FCLOSE(nHandle)
         FreeObj(oJson)
         FreeObj(oData)
      Else
         cRet := '{"message": "Not found"}'
      Endif
   Endif
EndCase

Return cRet


