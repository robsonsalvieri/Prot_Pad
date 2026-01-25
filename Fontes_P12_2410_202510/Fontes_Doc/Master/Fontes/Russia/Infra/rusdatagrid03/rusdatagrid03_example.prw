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

Function U_DX_EX03()
 While DX_EX03()

   Enddo
Return
Static Function DX_EX03()
Local cFile          := Lower(CriaTrab(NIL, .F.)  )
LOCAL nHandle       
Local oJson          := JsonObject():New()
Local cControlKey    :=  StrZero(Randomize( 1, 999999 ),6)
Local aParams        := {}
Local aRet           := {Space(len(SB1->B1_COD)),REPLICATE('Z',len(SB1->B1_COD))}
Local lRecall := .F.
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

   oJson['files']    := {'SECTION1','SECTION2','SECTION3'}
   
   //CREATES DATA
   CreateTMP({mv_par01,mv_par02},'F'+cControlKey, 'SECTION1', 'SECTION2' ,'SECTION3' )

   nHandle        := FCREATE(cFile+".dxparam", 0)
   FWRITE(nHandle, oJson:toJSon())
   FCLOSE(nHandle)

   //Call DATAGRID2 function with following parameters
   // Function that will return format for report
   // Function that will return Drill down data or will ADVPL screen for report on drilldown clicked
   // File where parametrization and key to open tables is stored
   lRecall := RU99X1203_DATAGRID3('U_EX03GetDef','U_EX03_DD',cFile, DELETEFILE,'rusdatagrid03')
   //Delete parametrization file
   STATICCALL(RU99X13_DXMODELS,CleanFiles,cFile)  

Endif
Return lRecall


Static Function CreateTMP(aRet,cControlKey,cSection1,cSection2,cSection3)
Local cSql  := ""
Local aStru1  := {}
Local aStru2  := {}
Local aStru3  := {}
//Id field is mandatory and must be a unique ID and the link with section 2 FATHERID field
Aadd(aStru1,{"ID"	      ,"N",10,0})
Aadd(aStru1,{"B1_COD"	,"C",GetSx3Cache( "B1_COD"    , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B1_DESC"	,"C",GetSx3Cache( "B1_DESC"   , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B1_UM"	   ,"C",GetSx3Cache( "B1_UM"     , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B1_TIPO"	,"C",GetSx3Cache( "B1_TIPO"   , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B1_GRUPO"	,"C",GetSx3Cache( "B1_GRUPO"  , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B2_LOCAL"	,"C",GetSx3Cache( "B2_LOCAL"   , "X3_TAMANHO" ),0})
Aadd(aStru1,{"B2_QATU"	,"N",GetSx3Cache( "B2_QATU"   , "X3_TAMANHO" ),GetSx3Cache( "B2_QATU" , "X3_DECIMAL" )})

Aadd(aStru2,{"ID"	      ,"N",10,0})
Aadd(aStru2,{"B1_COD"	,"C",GetSx3Cache( "B1_COD"    , "X3_TAMANHO" ),0})
Aadd(aStru2,{"B1_DESC"	,"C",GetSx3Cache( "B1_DESC"   , "X3_TAMANHO" ),0})
Aadd(aStru2,{"B1_UM"	   ,"C",GetSx3Cache( "B1_UM"     , "X3_TAMANHO" ),0})
Aadd(aStru2,{"B1_TIPO"	,"C",GetSx3Cache( "B1_TIPO"   , "X3_TAMANHO" ),0})
Aadd(aStru2,{"B1_GRUPO"	,"C",GetSx3Cache( "B1_GRUPO"  , "X3_TAMANHO" ),0})
Aadd(aStru2,{"B8_LOCAL"	,"C",GetSx3Cache( "B8_LOCAL"   , "X3_TAMANHO" ),0})
Aadd(aStru2,{"B8_LOTECTL","C",GetSx3Cache( "B8_LOTECTL"   , "X3_TAMANHO" ),0})
Aadd(aStru2,{"B8_SALDO"	,"N",GetSx3Cache( "B8_SALDO"   , "X3_TAMANHO" ),GetSx3Cache( "B8_SALDO" , "X3_DECIMAL" )})

Aadd(aStru3,{"ID"	      ,"N",10,0})
Aadd(aStru3,{"B1_COD"	,"C",GetSx3Cache( "B1_COD"    , "X3_TAMANHO" ),0})
Aadd(aStru3,{"B1_DESC"	,"C",GetSx3Cache( "B1_DESC"   , "X3_TAMANHO" ),0})
Aadd(aStru3,{"B1_UM"	   ,"C",GetSx3Cache( "B1_UM"     , "X3_TAMANHO" ),0})
Aadd(aStru3,{"B1_TIPO"	,"C",GetSx3Cache( "B1_TIPO"   , "X3_TAMANHO" ),0})
Aadd(aStru3,{"B1_GRUPO"	,"C",GetSx3Cache( "B1_GRUPO"  , "X3_TAMANHO" ),0})
Aadd(aStru3,{"BF_LOCAL"	,"C",GetSx3Cache( "BF_LOCAL"   , "X3_TAMANHO" ),0})
Aadd(aStru3,{"BF_LOCALIZ","C",GetSx3Cache( "BF_LOCALIZ"   , "X3_TAMANHO" ),0})
Aadd(aStru3,{"BF_QUANT"	,"N",GetSx3Cache( "BF_QUANT"   , "X3_TAMANHO" ),GetSx3Cache( "BF_QUANT" , "X3_DECIMAL" )})




TCInternal(30, 'AUTORECNO')
//Table names must have as SUFFIX "_"+cControlKey, this is required to avoid user being able to read any table from REST service for report
DbCreate(cSection1+"_"+cControlKey,aStru1,"TOPCONN")
DbCreate(cSection2+"_"+cControlKey,aStru2,"TOPCONN")
DbCreate(cSection3+"_"+cControlKey,aStru3,"TOPCONN")
TCInternal(30, 'OFF')

   cSql  := " insert into "+cSection1+"_"+cControlKey+" (ID, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, B2_LOCAL, B2_QATU ) "
   cSql  += " SELECT SB2.R_E_C_N_O_, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO,B2_LOCAL, ROUND(B2_QATU,2) "
   cSql  += "   FROM "+RetSqlName('SB1') +" SB1,"+RetSqlName('SB2') +" SB2 "
   cSql  += " WHERE B1_FILIAL = '"+xFilial('SB1')+"' "
   cSql  += " AND B2_FILIAL = '"+xFilial('SB2')+"' "
   cSql  += " AND B1_COD BETWEEN '"+aRet[1]+"' AND '"+aRet[2]+"' "
   cSql  += " AND B1_COD = B2_COD "
   cSql  += " AND SB1.D_E_L_E_T_= ' ' "
   cSql  += " AND SB2.D_E_L_E_T_= ' ' "
   cSql  += " ORDER BY B1_COD, B2_LOCAL "
   TCSQLEXEC(cSql)
   
   
   cSql  := " insert into "+cSection2+"_"+cControlKey+" (ID, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, B8_LOCAL, B8_LOTECTL, B8_SALDO) "
   cSql  += " SELECT SB8.R_E_C_N_O_, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, B8_LOCAL, B8_LOTECTL, ROUND(B8_SALDO,2)
   cSql  += "   FROM "+RetSqlName('SB1') +" SB1,"+RetSqlName('SB8') +" SB8 "
   cSql  += " WHERE B1_FILIAL = '"+xFilial('SB1')+"' "
   cSql  += " AND B8_FILIAL = '"+xFilial('SB8')+"' "
   cSql  += " AND B1_COD BETWEEN '"+aRet[1]+"' AND '"+aRet[2]+"' "
   cSql  += " AND B1_COD = B8_PRODUTO "
   cSql  += " AND SB1.D_E_L_E_T_= ' ' "
   cSql  += " AND SB8.D_E_L_E_T_= ' ' "
   cSql  += " ORDER BY B1_COD,B8_LOCAL,B8_LOTECTL "
   TCSQLEXEC(cSql)
   
   
   cSql  := " insert into "+cSection3+"_"+cControlKey+" (ID, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, BF_LOCAL, BF_LOCALIZ, BF_QUANT) "
   cSql  += " SELECT MAX(SBF.R_E_C_N_O_), B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, BF_LOCAL, BF_LOCALIZ, ROUND(SUM(BF_QUANT),2)
   cSql  += "   FROM "+RetSqlName('SB1') +" SB1,"+RetSqlName('SBF') +" SBF "
   cSql  += " WHERE B1_FILIAL = '"+xFilial('SB1')+"' "
   cSql  += " AND BF_FILIAL = '"+xFilial('SBF')+"' "
   cSql  += " AND B1_COD BETWEEN '"+aRet[1]+"' AND '"+aRet[2]+"' "
   cSql  += " AND B1_COD = BF_PRODUTO "
   cSql  += " AND SB1.D_E_L_E_T_= ' ' "
   cSql  += " AND SBF.D_E_L_E_T_= ' ' "
   cSql  += " GROUP BY  B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_GRUPO, BF_LOCAL , BF_LOCALIZ"
   cSql  += " ORDER BY B1_COD,BF_LOCAL,BF_LOCALIZ "
   TCSQLEXEC(cSql)
   

Return
Function U_EX03GetDef(cKey)
Local oJson0 := GetDxModel('main')
Local oJson1 := GetDxModel('main')
Local oJson2:= GetDxModel('main')
Local oJson3:= GetDxModel('main')
Local oDataGridDD1:= GetDxModel('main')
Local oSummary := GetDxModel('summary')
Local oDD1
Local oDD2 
Local oDD3 
Local oDD4
Local oCol 
Local oColumn
Local nX,nZ
Local aFields1    := {"B1_COD", "B1_DESC","B1_UM", "B1_TIPO", "B1_GRUPO", "B2_LOCAL","B2_QATU"}
Local aFields2    := {"B1_COD", "B1_DESC","B1_UM", "B1_TIPO", "B1_GRUPO", "B8_LOCAL","B8_LOTECTL","B8_SALDO"}
Local aFields3    := {"B1_COD", "B1_DESC","B1_UM", "B1_TIPO", "B1_GRUPO", "BF_LOCAL","BF_LOCALIZ","BF_QUANT"}
Local aFieldsKDX  := {"ORIGIN","D3_COD","D3_LOCAL","D3_LOTECTL", "D3_LOCALIZ","D3_EMISSAO","D3_DOC","D3_QUANT","D3_CUSTO1"}
Local aFields0    := {;
                     {"Product data","B1_COD", "B1_DESC","B1_UM", "B1_TIPO", "B1_GRUPO"},;
                     {"Location data", "B8_LOCAL","B8_LOTECTL"},;
                     "B8_SALDO"}

//Create definition for main grid
SX3->(DBSETORDER(2))
For nX:=1 To Len(aFields1)
   oCol := GetDxModel('columns')
   oCol['dataField'] := aFields1[nX]
   If SX3->(DbSeek(aFields1[nX]))
      oCol['caption']   :=  Alltrim(X3Descric())// Alltrim(X3TITULO())
      oCol['dataType']  := IIF(SX3->X3_TIPO == "N","number",IIF(SX3->X3_TIPO == "D","date","string"))
      //oCol['width']     := Max(SX3->X3_TAMANHO * 5,40)
   Endif
   if (aFields1[nx]=="B1_UM")
      oCol['allowGrouping']	:=	.F.
   Else
	   oCol['allowGrouping']	:=	.T.
   Endif
   if (aFields1[nx]=="B1_TIPO")
      oCol['allowFiltering']	:=	.F.
   endif
   AADd(oJson1['columns'], oCol)
   FreeObj(oCol)
Next

SX3->(DBSETORDER(2))
For nX:=1 To Len(aFields2)
   oCol := GetDxModel('columns')
   oCol['dataField'] := aFields2[nX]
   If SX3->(DbSeek(aFields2[nX]))
      oCol['caption']   :=  Alltrim(X3Descric())// Alltrim(X3TITULO())
      oCol['dataType']  := IIF(SX3->X3_TIPO == "N","number",IIF(SX3->X3_TIPO == "D","date","string"))
      //oCol['width']     := Max(SX3->X3_TAMANHO * 5,40)
   Endif
   if (aFields2[nx]=="B1_UM")
      oCol['allowGrouping']	:=	.F.
   Else
	   oCol['allowGrouping']	:=	.T.
   Endif
   if (aFields2[nx]=="B1_TIPO")
      oCol['allowFiltering']	:=	.F.
   endif
   AADd(oJson2['columns'], oCol)
   FreeObj(oCol)
Next


SX3->(DBSETORDER(2))
For nX:=1 To Len(aFields3)
   oCol := GetDxModel('columns')
   oCol['dataField'] := aFields3[nX]
   If SX3->(DbSeek(aFields3[nX]))
      oCol['caption']   :=  Alltrim(X3Descric())// Alltrim(X3TITULO())
      oCol['dataType']  := IIF(SX3->X3_TIPO == "N","number",IIF(SX3->X3_TIPO == "D","date","string"))
      //oCol['width']     := Max(SX3->X3_TAMANHO * 5,40)
   Endif
   if (aFields3[nx]=="B1_UM")
      oCol['allowGrouping']	:=	.F.
   Else
	   oCol['allowGrouping']	:=	.T.
   Endif
   if (aFields3[nx]=="B1_TIPO")
      oCol['allowFiltering']	:=	.F.
   endif
   AADd(oJson3['columns'], oCol)
   FreeObj(oCol)
Next

SX3->(DBSETORDER(2))

For nX:=1 To Len(aFields0)
   If valType(aFields0[nX]) == "A"
      oColumn := GetDxModel('columns')
      oColumn['columns']   := {}
      oColumn['allowFiltering']   := .F.
      oColumn['allowGrouping']   := .F.
      oColumn['caption'] := aFields0[nX,1]
      For nZ := 2 To Len(aFields0[nX])
         oCol := GetDxModel('columns')
         oCol  := GetColSX3(aFields0[nX,nZ])
         oCol['dataField'] := aFields0[nX,nZ]
         AAdd(oColumn['columns'],oCol)
         FreeObj(oCol)
      Next nZ
   Else
      oColumn  := GetColSX3(aFields0[nX])
      oColumn['dataField'] := aFields0[nX]
   Endif
   AADd(oJson0['columns'], oColumn)
   FreeObj(oColumn)
Next

//Setup filters and standards for SB1

//Setup filters and standards for SB2
oJson2['filterRow']['visible']  := .T.

aadd(oSummary['groupItems'],GetDxModel('groupItems'))
oSummary['groupItems'][1]['column'] := 'B2_QATU'
oSummary['groupItems'][1]['alignByColumn']   := .T.
oSummary['groupItems'][1]['showInGroupFooter'] := .F.
oSummary['groupItems'][1]['summaryType'] := 'sum'

aadd(oSummary['totalItems'],GetDxModel('totalItems'))
oSummary['totalItems'][1]['column'] := 'B1_COD'
oSummary['totalItems'][1]['showInColumn'] := 0
oSummary['totalItems'][1]['alignment']    := 'left'
oSummary['totalItems'][1]['summaryType']  := 'count'

oJson1['summary']:= oSummary

FreeObj(oSummary)
oSummary := GetDxModel('summary')

aadd(oSummary['groupItems'],GetDxModel('groupItems'))
oSummary['groupItems'][1]['column'] := 'B8_SALDO'
oSummary['groupItems'][1]['alignByColumn']   := .T.
oSummary['groupItems'][1]['showInGroupFooter'] := .F.
oSummary['groupItems'][1]['summaryType'] := 'sum'

aadd(oSummary['totalItems'],GetDxModel('totalItems'))
oSummary['totalItems'][1]['column'] := 'B1_COD'
oSummary['totalItems'][1]['showInColumn'] := 0
oSummary['totalItems'][1]['alignment']    := 'left'
oSummary['totalItems'][1]['summaryType']  := 'count'

oJson2['summary']:= oSummary
oJson0['summary']:= oSummary


FreeObj(oSummary)
oSummary := GetDxModel('summary')

aadd(oSummary['groupItems'],GetDxModel('groupItems'))
oSummary['groupItems'][1]['column'] := 'BF_QUANT'
oSummary['groupItems'][1]['alignByColumn']   := .T.
oSummary['groupItems'][1]['showInGroupFooter'] := .F.
oSummary['groupItems'][1]['summaryType'] := 'sum'

aadd(oSummary['totalItems'],GetDxModel('totalItems'))
oSummary['totalItems'][1]['column'] := 'B1_COD'
oSummary['totalItems'][1]['showInColumn'] := 0
oSummary['totalItems'][1]['alignment']    := 'left'
oSummary['totalItems'][1]['summaryType']  := 'count'

oJson3['summary']:= oSummary


// Define drilldown relations
oDD1 := GetDxModel('drillDownLink')
oDD1['callerGridId'] 		:= "balanceSB2"
oDD1['callerGridColumn']	:= "*"
oDD1['drillDownGridId'] 	:= "kardex"

// Define drilldown relations
oDD2 := GetDxModel('drillDownLink')
oDD2['callerGridId'] 		:= "balanceSB8"
oDD2['callerGridColumn']	:= "*"
oDD2['drillDownGridId'] 	:= "kardex"

oDD21 := GetDxModel('drillDownLink')
oDD21['callerGridId'] 		:= "balanceSB8Banded"
oDD21['callerGridColumn']	:= "*"
oDD21['drillDownGridId'] 	:= "kardex"

// Define drilldown relations
oDD3 := GetDxModel('drillDownLink')
oDD3['callerGridId'] 		:= "balanceSBF"
oDD3['callerGridColumn']	:= "*"
oDD3['drillDownGridId'] 	:= "kardex"

// Define drilldown relations
oDD4 := GetDxModel('drillDownLink')
oDD4['callerGridId'] 		:= "kardex"
oDD4['callerGridColumn']	:= "*"
oDD4['drillDownGridId'] 	:= "document"
/*
// Define drilldown relations
oDD4 := GetDxModel('drillDownLink')
oDD4['callerGridId'] 		:= "flatView"
oDD4['callerGridColumn']	:= "*"
oDD4['drillDownGridId'] 	:= "kardex"
*/
For nX:=1 To Len(aFieldsKDX)
   oCol := GetDxModel('columns')
   oCol['dataField'] := aFieldsKDX[nX]
   IF aFieldsKDX[nX]== "ORIGIN"
      oCol['caption']   := "Origin"
      oCol['dataType']  := "string"
   ELseIf SX3->(DbSeek(aFieldsKDX[nX]))
      oCol['caption']   :=  Alltrim(X3Descric())
      oCol['dataType']  := IIF(SX3->X3_TIPO == "N","number",IIF(SX3->X3_TIPO == "D","date","string"))
   Endif
   If oCol['dataType'] <> "number"
      oCol['allowGrouping']	:=	.T.
   Endif    

   AADd(oDataGridDD1['columns'], oCol)
   FreeObj(oCol)
Next

FreeObj(oSummary)
oSummary := GetDxModel('summary')

aadd(oSummary['groupItems'],GetDxModel('groupItems'))
oSummary['groupItems'][1]['column'] := 'D3_QUANT'
oSummary['groupItems'][1]['alignByColumn']   := .T.
oSummary['groupItems'][1]['showInGroupFooter'] := .F.
oSummary['groupItems'][1]['summaryType'] := 'sum'
aadd(oSummary['groupItems'],GetDxModel('groupItems'))
oSummary['groupItems'][2]['column'] := 'D3_CUSTO1'
oSummary['groupItems'][2]['alignByColumn']   := .T.
oSummary['groupItems'][2]['showInGroupFooter'] := .F.
oSummary['groupItems'][2]['summaryType'] := 'sum'

aadd(oSummary['totalItems'],GetDxModel('totalItems'))
oSummary['totalItems'][1]['column'] := 'D3_QUANT'
oSummary['totalItems'][1]['showInColumn'] := 0
oSummary['totalItems'][1]['alignment']    := 'left'
oSummary['totalItems'][1]['summaryType']  := 'sum'

aadd(oSummary['totalItems'],GetDxModel('totalItems'))
oSummary['totalItems'][2]['column'] := 'D3_CUSTO1'
oSummary['totalItems'][2]['showInColumn'] := 0
oSummary['totalItems'][2]['alignment']    := 'left'
oSummary['totalItems'][2]['summaryType']  := 'sum'

oDataGridDD1['summary']:= oSummary

oJson1['stateStoring']['enabled']   := .F.
oJson2['stateStoring']['enabled']   := .F.
oJson3['stateStoring']['enabled']   := .F.
oJson0['stateStoring']['enabled']   := .F.
oDataGridDD1['stateStoring']['enabled']   := .F.
oDataGridDD1['width']   := '100%'
oDataGridDD1['height']  := '80vh'

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
                                    '{"dxDataGridSetup": '+oJson1:toJSon()+", "+;
                                    ' "title": "Balances",'+;
                                    ' "code": "balanceSB2",'+;
                                    ' "section": 0,'+;
                                    ' "file": "SECTION1"},'+;
                                    '{"dxDataGridSetup": '+oJson2:toJSon()+", "+;
                                    ' "title": "Balances per lot",'+;
                                    ' "code": "balanceSB8",'+;
                                    ' "section": 1,'+;
                                    ' "file": "SECTION2"},'+;
                                    '{"dxDataGridSetup": '+oJson3:toJSon()+", "+;
                                    ' "title": "Balances per location",'+;
                                    ' "code": "balanceSBF",'+;
                                    ' "section": 2,'+;
                                    ' "file": "SECTION3"},'+;
                                    '{"dxDataGridSetup": '+oJson0:toJSon()+", "+;
                                    ' "title": "Balances per lot (Banded columns)",'+;
                                    ' "code": "balanceSB8Banded",'+;
                                    ' "section": 3,'+;
                                    ' "file": "SECTION2"}'+;                                    
                                    '],'+;
                     '"drillDowns": ['+;
                                    '{"dxDataGridSetup": '+oDataGridDD1:toJSon()+", "+;
                                    ' "title": "DrillDown1",'+;
                                    ' "code": "kardex",'+;
                                    ' "section": 4,'+;
                                    ' "drillDownType": "angular"},'+;
                                    '{'+;
                                    ' "title": "DrillDown2",'+;
                                    ' "code": "document",'+;
                                    ' "drillDownType": "ADVPL"}'+;
                                    '],'+;
                   ' "drillDownDefs": [' +;
                                       oDD1:toJSon()+','+;
                                       oDD2:toJSon()+','+;
                                       oDD21:toJSon()+','+;
                                       oDD3:toJSon()+','+;
                                       oDD4:toJSon()+;
                                      '],'+;
                   ' "params": '+FwJSonSerialize(aJsonParams,.F.,.F.)+", "+;
                   ' "showRecall": true, '+;
                   ' "sectionsQuantity": 4,'+;
                   ' "mainTitle": "TestReport" },'+;
         ' "status": "ok",'+;
         ' "ok": "ok",'+;
         ' "statusText": "ok"}'

FreeObj(oJson1)
FreeObj(oJson2)
FreeObj(oJson3)
FreeObj(oSummary)
FreeObj(oDD1)
FreeObj(oDD2)
FreeObj(oDD3)
FreeObj(oDD4)
FreeObj(oDataGridDD1)

Return cRet


Function U_EX03_DD(cColumn, cGridID,cDrillDownID,cKey,cBody)
Local aStru := {}
Local cFile := CriaTrab(Nil,.F.)
Local oJson
Local oData
Local cRet 
Local nHandle
Local cTitle   := ""
Local aFilters := {{},{},{}}
Local nX
Do Case
Case cGridID == "balanceSB2".Or. cGridID == "balanceSB8"
   oJson := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey)  
   If oJson['error'] == Nil
      oData:= JSONOBJECT():NEW()
      oData:FROMJSON(cBody)
      If (oData['B1_COD'] <> Nil)
         If cGridID == "balanceSB2"
            aadd(aFilters[1], " AND D1_LOCAL = '"+DECODEUTF8(oData['B2_LOCAL'])+"' ")
            aadd(aFilters[2], " AND D2_LOCAL = '"+DECODEUTF8(oData['B2_LOCAL'])+"' ")
            aadd(aFilters[3], " AND D3_LOCAL = '"+DECODEUTF8(oData['B2_LOCAL'])+"' ")
         Else
            aadd(aFilters[1], " AND D1_LOCAL = '"+DECODEUTF8(oData['B8_LOCAL'])+"' ")
            aadd(aFilters[2], " AND D2_LOCAL = '"+DECODEUTF8(oData['B8_LOCAL'])+"' ")
            aadd(aFilters[3], " AND D3_LOCAL = '"+DECODEUTF8(oData['B8_LOCAL'])+"' ")
         Endif
         If oData['B8_LOTECTL'] <> Nil
            aadd(aFilters[1], " AND D1_LOTECTL = '"+DECODEUTF8(oData['B8_LOTECTL'])+"' ")
            aadd(aFilters[2], " AND D2_LOTECTL = '"+DECODEUTF8(oData['B8_LOTECTL'])+"' ")
            aadd(aFilters[3], " AND D3_LOTECTL = '"+DECODEUTF8(oData['B8_LOTECTL'])+"' ")
         Endif
         Aadd(aStru,{"ID"	         ,"C",GetSx3Cache( "D3_NUMSEQ"       , "X3_TAMANHO" )       ,0})
         Aadd(aStru,{"ORIGIN"	      ,"C",3,0})
         Aadd(aStru,{"D3_COD"	      ,"C",GetSx3Cache( "D3_COD"       , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_EMISSAO"	,"D",GetSx3Cache( "D3_EMISSAO"   , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_DOC"	      ,"C",GetSx3Cache( "D3_DOC"       , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_LOCAL"	   ,"C",GetSx3Cache( "D3_LOCAL"     , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_LOTECTL"	,"C",GetSx3Cache( "D3_LOTECTL"     , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_LOCALIZ"	,"C",GetSx3Cache( "D3_LOCALIZ"     , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_QUANT"	   ,"N",GetSx3Cache( "D3_QUANT"     , "X3_TAMANHO" ),GetSx3Cache( "D3_QUANT" , "X3_DECIMAL" )})
         Aadd(aStru,{"D3_CUSTO1"	   ,"N",GetSx3Cache( "D3_CUSTO1"    , "X3_TAMANHO" ),GetSx3Cache( "D3_CUSTO1" , "X3_DECIMAL" )})

         TCInternal(30, 'AUTORECNO')
         //Table names must have as SUFFIX "_"+cControlKey, this is required to avoid user being able to read any table from REST service for report
         DbCreate(cFile+"_"+oJson['controlKey'],aStru,"TOPCONN")
         TCInternal(30, 'OFF')
         cSql  := " insert into "+cFile+"_"+oJson['controlKey']+" (ID, ORIGIN, D3_COD, D3_EMISSAO, D3_DOC, D3_LOCAL, D3_LOTECTL, D3_LOCALIZ, D3_QUANT, D3_CUSTO1 ) "
         cSql  += " SELECT D1_NUMSEQ, 'SD1',D1_COD, D1_EMISSAO, D1_DOC, D1_LOCAL, D1_LOTECTL, D1_LOCALIZ, ROUND(D1_QUANT,2), ROUND(D1_CUSTO,2)
         cSql  += "   FROM "+RetSqlName('SD1') +" SD1 "
         cSql  += " WHERE D1_FILIAL = '"+xFilial('SD1')+"' "
         cSql  += " AND D1_COD  =  '"+DECODEUTF8(oData['B1_COD'])+"' "
         For nX:=1 To Len(aFilters[1])
            cSql  +=aFilters[1][nX]
         Next
         cSql  += " AND D_E_L_E_T_= ' ' "

         cSql  += " union all "
         cSql  += " SELECT D2_NUMSEQ, 'SD2', D2_COD, D2_EMISSAO, D2_DOC, D2_LOCAL, D2_LOTECTL, D2_LOCALIZ, ROUND(D2_QUANT,2) * -1 , ROUND(D2_CUSTO1,2) * -1
         cSql  += "   FROM "+RetSqlName('SD2') +" SD2 "
         cSql  += " WHERE D2_FILIAL = '"+xFilial('SD2')+"' "
         cSql  += " AND D2_COD  =  '"+DECODEUTF8(oData['B1_COD'])+"' "
         For nX:=1 To Len(aFilters[2])
            cSql  +=aFilters[2][nX]
         Next
         cSql  += " AND D_E_L_E_T_= ' ' "
         
         cSql  += " union all "
         cSql  += " SELECT D3_NUMSEQ, 'SD3', D3_COD, D3_EMISSAO, D3_DOC, D3_LOCAL, D3_LOTECTL, D3_LOCALIZ, ROUND(D3_QUANT,2) * CASE WHEN D3_TM < '500' THEN 1 ELSE -1 END , ROUND(D3_CUSTO1,2)  * CASE WHEN D3_TM < '500' THEN 1 ELSE -1 END
         cSql  += "   FROM "+RetSqlName('SD3') +" SD3 "
         cSql  += " WHERE D3_FILIAL = '"+xFilial('SD3')+"' "
         cSql  += " AND D3_COD  =  '"+DECODEUTF8(oData['B1_COD'])+"' "
         For nX:=1 To Len(aFilters[3])
            cSql  +=aFilters[3][nX]
         Next
         cSql  += " AND D_E_L_E_T_= ' ' "
         
         TCSQLEXEC(cSql)
         If !EMpty(tcsqlerror())
            cRet := StrTran(tcsqlerror(),'"','\"')
            cRet := StrTran(cRet,chr(9),'\t')
            cRet := StrTran(cRet,chr(13),'\n')
            cRet := StrTran(cRet,chr(10),'\n')
            cRet := '{"title": "'+cRet+'"}'
         Else
            cRet := '{"file":"'+cFile+'","title": "'+cTitle+'"}'
         Endif
         aadd(oJson['files'],cFile)
         nHandle        := Fopen(cKey+".dxparam", 2)
         FWRITE(nHandle, oJson:toJSon())
         FCLOSE(nHandle)
         FreeObj(oJson)
         FreeObj(oData)
      Endif
   Endif
Case cGridID == "balanceSBF"
   oJson := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey)  
   If oJson['error'] == Nil
      oData:= JSONOBJECT():NEW()
      oData:FROMJSON(cBody)
      If (oData['B1_COD'] <> Nil)

         Aadd(aStru,{"ID"	         ,"N",10       ,0})
         Aadd(aStru,{"ORIGIN"	      ,"C",3,0})
         Aadd(aStru,{"D3_COD"	      ,"C",GetSx3Cache( "D3_COD"       , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_EMISSAO"	,"D",GetSx3Cache( "D3_EMISSAO"   , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_DOC"	      ,"C",GetSx3Cache( "D3_DOC"       , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_LOCAL"	   ,"C",GetSx3Cache( "D3_LOCAL"     , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_LOTECTL"	   ,"C",GetSx3Cache( "D3_LOTECTL"     , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_LOCALIZ"	   ,"C",GetSx3Cache( "D3_LOCALIZ"     , "X3_TAMANHO" ),0})
         Aadd(aStru,{"D3_QUANT"	   ,"N",GetSx3Cache( "D3_QUANT"     , "X3_TAMANHO" ),GetSx3Cache( "D3_QUANT" , "X3_DECIMAL" )})
         Aadd(aStru,{"D3_CUSTO1"	   ,"N",GetSx3Cache( "D3_CUSTO1"    , "X3_TAMANHO" ),GetSx3Cache( "D3_CUSTO1" , "X3_DECIMAL" )})

         TCInternal(30, 'AUTORECNO')
         //Table names must have as SUFFIX "_"+cControlKey, this is required to avoid user being able to read any table from REST service for report
         DbCreate(cFile+"_"+oJson['controlKey'],aStru,"TOPCONN")
         TCInternal(30, 'OFF')
         cSql  := " insert into "+cFile+"_"+oJson['controlKey']+" (ID, ORIGIN, D3_COD, D3_EMISSAO, D3_DOC, D3_LOCAL, D3_LOTECTL, D3_LOCALIZ, D3_QUANT, D3_CUSTO1 ) "
         cSql  += " SELECT R_E_C_N_O_, DB_ORIGEM,DB_PRODUTO, DB_DATA, DB_DOC, DB_LOCAL, DB_LOTECTL, DB_LOCALIZ, ROUND(DB_QUANT,2) * CASE WHEN DB_TM < '500' THEN 1 ELSE -1 END, 0 
         cSql  += "   FROM "+RetSqlName('SDB') +" SDB "
         cSql  += " WHERE DB_FILIAL = '"+xFilial('SDB')+"' "
         cSql  += " AND DB_PRODUTO  =  '"+DECODEUTF8(oData['B1_COD'])+"' "
         cSql  += " AND DB_LOCAL    =  '"+DECODEUTF8(oData['BF_LOCAL'])+"' "
         cSql  += " AND DB_LOCALIZ  =  '"+DECODEUTF8(oData['BF_LOCALIZ'])+"' "
         cSql  += " AND D_E_L_E_T_= ' ' "
         
         TCSQLEXEC(cSql)
         If !EMpty(tcsqlerror())
            cRet := StrTran(tcsqlerror(),'"','\"')
            cRet := StrTran(cRet,chr(9),'\t')
            cRet := StrTran(cRet,chr(13),'\n')
            cRet := StrTran(cRet,chr(10),'\n')
            cRet := '{"title": "'+cRet+'"}'
         Else
            cRet := '{"file":"'+cFile+'","title": "'+cTitle+'"}'
         Endif
         aadd(oJson['files'],cFile)
         nHandle        := Fopen(cKey+".dxparam", 2)
         FWRITE(nHandle, oJson:toJSon())
         FCLOSE(nHandle)
         FreeObj(oJson)
         FreeObj(oData)
      Endif
   Endif

Case (cGridID == "kardex")
   // Nao ha drill down do Kardex
EndCase

Return cRet


Static Function GetColSX3(cCol)
SX3->(DbSetOrder(2))
SX3->(DbSeek(cCol))
oCol := GetDxModel('columns')
oCol['caption']   :=  Alltrim(X3Descric())// Alltrim(X3TITULO())
oCol['dataType']  := IIF(SX3->X3_TIPO == "N","number",IIF(SX3->X3_TIPO == "D","date","string"))
Return oCol
