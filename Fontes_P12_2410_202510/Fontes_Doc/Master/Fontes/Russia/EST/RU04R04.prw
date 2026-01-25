#INCLUDE 'protheus.ch'
#INCLUDE 'fwmvcdef.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'RU04R04.CH'

#DEFINE DELETEFILE .F.
#DEFINE FIELDNAME 1
#DEFINE FIELDDESC 2
#DEFINE FIELDTYPE 3
#DEFINE FIELDVISIBLE 4
#DEFINE TYPEFORMAT 5
#DEFINE DECIMAFORMAT 6
#DEFINE STRCOLM 4 // columns for String, Numeric has more columns
#DEFINE DEFAULTPARVAL "*" // filler for default / empty parameter value

/*/{Protheus.doc} RU04R0401
    Materials Movements report using Angular output
    @type  Function
    @author Maxim Popenker
    @since 13/02/2023
    @version 1.0
    @example
    (examples)
    @see (links_or_references)
    /*/
Function RU04R0401()

    Local cFile := Lower(CriaTrab(NIL, .F.)  )
    Local nHandle       
    Local oJson := JsonObject():New()
    Local cControlKey := 'F'+StrZero(Randomize( 1, 999999 ),6)
    Local lRecall := .F.
    local aParams := {} // selection parameters
    local cTable1 := ""


   If Pergunte("RU04R04",.T.) // if Selection parameters were completed with OK

        oJson['controlKey']  := cControlKey
        oJson['files']    := {'SECTION1'}

        // pass parameters for data selection 
        AddMvParam(aParams, dtos(mv_par01)) //Document date (from)          
        AddMvParam(aParams, dtos(mv_par02)) //Document date (to)            
        AddMvParam(aParams, dtos(mv_par03)) //Posting date (from)           
        AddMvParam(aParams, dtos(mv_par04)) //Posting date (to)             
        AddMvParam(aParams, mv_par05) //material code (from)          
        AddMvParam(aParams, mv_par06) //material code (to)            
        AddMvParam(aParams, mv_par07) //Warehouse (from)              
        AddMvParam(aParams, mv_par08) //Warehouse (to)                
        AddMvParam(aParams, mv_par09) //Batch (from)                  
        AddMvParam(aParams, mv_par10) //Batch (to)                    
        AddMvParam(aParams, mv_par11) //TIO (from)                    
        AddMvParam(aParams, mv_par12) //TIO (to)                      
        AddMvParam(aParams, mv_par13) //Storage adr (from)            
        AddMvParam(aParams, mv_par14) //Storage adr (to)              
        AddMvParam(aParams, mv_par15) //Customer (from)               
        AddMvParam(aParams, mv_par16) //Customer (to)                 
        AddMvParam(aParams, Alltrim(Str(mv_par17))) //Add deleted items (1-No, 2-yes)                
        AddMvParam(aParams, mv_par18) //Project       

        //Create report data, insert into the temporary DB table and then pass to angular via the file at the server
        cTable1 := 'SECTION1' + "_" + cControlKey
        FwMsgRun(,{|oSay| MainDataCreate(aParams,cTable1)},'',STR0048) // STR0048 = wait for process

        nHandle := FCREATE(cFile+".dxparam", 0)
        FWRITE(nHandle, oJson:toJSon())
        FCLOSE(nHandle) 

        //invoke Angular grid engine
        lRecall := RU99X1203_DATAGRID3('RU04R0402','',cFile, DELETEFILE)
    
        //Delete temporary file
        STATICCALL(RU99X13_DXMODELS,CleanFiles,cFile)  

   Endif

Return 


/*/{Protheus.doc} MainDataCreate
    Create all structures, temporary tables and fill with data
    @author Maxim Popenker
    @since  13/02/2023
    @type
    @version 1.0
    @param aPar, array, list of pergunte parameters
    @param cTableName, Char, name of temporary table
    @return Nil

/*/
Static Function MainDataCreate(aPar,cTableName)
    Local aStru1   := {} //structure for main grid

    fill_db_field(@aStru1,"D1_FILIAL") 
    fill_db_field(@aStru1,"D1_ITEM") 
    fill_db_field(@aStru1,"D1_COD") 
    fill_zdb_field(@aStru1,"D1_DESCRI",254) 
    fill_db_field(@aStru1,"D1_GRUPO")
    fill_db_field(@aStru1,"D1_UM") 
    fill_db_field(@aStru1,"D1_QUANT") 
    fill_db_field(@aStru1,"D1_VUNIT") 
    fill_db_field(@aStru1,"D1_TOTAL") 
    fill_db_field(@aStru1,"D1_TES") 
    fill_db_field(@aStru1,"D1_SERIE") 
    fill_db_field(@aStru1,"D1_DOC") 
    fill_db_field(@aStru1,"D1_EMISSAO") 
    fill_db_field(@aStru1,"D1_DTDIGIT") 
    fill_db_field(@aStru1,"D1_LOCAL") 
    fill_db_field(@aStru1,"D1_LOCALIZ") 
    fill_db_field(@aStru1,"D1_LOTECTL") 
    fill_db_field(@aStru1,"D1_NUMDESP") 
    fill_db_field(@aStru1,"D1_ORIGEM") 
    fill_db_field(@aStru1,"D1_ITEMCTA")
    fill_db_field(@aStru1,"D1_FORNECE") 
    fill_db_field(@aStru1,"D1_LOJA") 
    fill_cdb_field(@aStru1,"D1_EC06DB") // custom field,  may be inactive
    fill_cdb_field(@aStru1,"D1_EC06CR") // custom field,  may be inactive 
    fill_cdb_field(@aStru1,"D1_EC07DB") // custom field,  may be inactive
    fill_cdb_field(@aStru1,"D1_EC07CR") // custom field,  may be inactive
    fill_cdb_field(@aStru1,"D1_EC08DB") // custom field,  may be inactive 
    fill_cdb_field(@aStru1,"D1_EC08CR") // custom field,  may be inactive 
    fill_cdb_field(@aStru1,"D1_EC09DB") // custom field,  may be inactive 
    fill_cdb_field(@aStru1,"D1_EC09CR") // custom field,  may be inactive 
    fill_db_field(@aStru1,"D1_CLVL") 
    fill_db_field(@aStru1,"D1_CONTA") 
    fill_db_field(@aStru1,"D1_SERIORI")	
    fill_db_field(@aStru1,"D1_NFORI") 
    fill_db_field(@aStru1,"D1_CUSTO") 
    fill_db_field(@aStru1,"D1_CUSFF1") 
    fill_db_field(@aStru1,"B1_CUSTD") 

    TCInternal(30, 'AUTORECNO')

    DbCreate(cTableName,aStru1,"TOPCONN")
    TCInternal(30, 'OFF')
    
    //Create and populate the main query with all data 
    FwMsgRun(,{|oSay|FSFILTEM(cTableName,aPar)},'',STR0048) // STR0048 = wait for process

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} RU04R0402
create the Angular report JSON structure
@author Maxim Popenker
@since  13/02/2023
@type
@param cKey, Char, key
@version 1.0
/*/
 Function RU04R0402(cKey)
    Local oMainGrid := GetDxModel('main')
    Local oSummary := GetDxModel('summary')
    Local aFields := {}	

    // Grid configuration parameters
    oMainGrid['columnResizingMode'] 	:= 'widget'
    oMainGrid['columnFixing']['enabled'] 	:= .T.
    oMainGrid['scrolling'] := '{}'
    oMainGrid['stateStoring']['enabled'] := .T.
    oMainGrid['stateStoring']['storageKey'] := 'RU04R04' + RetCodUsr()

    //Column definition for the main grid
    Aadd(aFields,{"D1_FILIAL", STR0001,"string",.T.})	
    Aadd(aFields,{"D1_ITEM", STR0002,"string",.T.})	
    Aadd(aFields,{"D1_COD", STR0003,"string",.T.})	
    Aadd(aFields,{"D1_DESCRI", STR0004,"string",.T.})	
    Aadd(aFields,{"D1_GRUPO", STR0005,"string",.T.})	
    Aadd(aFields,{"D1_UM", STR0006,"string",.T.})	
    Aadd(aFields,{"D1_QUANT", STR0007,"number",.T.,'fixedPoint',4})	
    Aadd(aFields,{"D1_VUNIT", STR0008,"number",.T.,'fixedPoint',2})	
    Aadd(aFields,{"D1_TOTAL", STR0009,"number",.T.,'fixedPoint',2})	
    Aadd(aFields,{"D1_TES", STR0010,"string",.T.})	
    Aadd(aFields,{"D1_SERIE", STR0011,"string",.T.})	
    Aadd(aFields,{"D1_DOC", STR0012,"string",.T.})	
    Aadd(aFields,{"D1_EMISSAO", STR0013,"date",.T.})	
    Aadd(aFields,{"D1_DTDIGIT", STR0014,"date",.T.})	
    Aadd(aFields,{"D1_LOCAL", STR0015,"string",.T.})	
    Aadd(aFields,{"D1_LOCALIZ", STR0016,"string",.T.})	
    Aadd(aFields,{"D1_LOTECTL", STR0017,"string",.T.})	
    Aadd(aFields,{"D1_NUMDESP", STR0018,"string",.T.})	
    Aadd(aFields,{"D1_ORIGEM", STR0019,"string",.T.})	
    Aadd(aFields,{"D1_ITEMCTA", STR0020,"string",.T.})	
    Aadd(aFields,{"D1_FORNECE", STR0021,"string",.T.})	
    Aadd(aFields,{"D1_LOJA", STR0022,"string",.T.})	
    if ChckCustFld("D1_EC06DB") // Debet and Credit fields are activated only in pairs
        Aadd(aFields,{"D1_EC06DB", STR0023,"string",.T.})	
        Aadd(aFields,{"D1_EC06CR", STR0024,"string",.T.})	
    endif
    if ChckCustFld("D1_EC07DB") // Debet and Credit fields are activated only in pairs
        Aadd(aFields,{"D1_EC07DB", STR0025,"string",.T.})	
        Aadd(aFields,{"D1_EC07CR", STR0026,"string",.T.})
    endif
    if ChckCustFld("D1_EC08DB") // Debet and Credit fields are activated only in pairs	
        Aadd(aFields,{"D1_EC08DB", STR0027,"string",.T.})	
        Aadd(aFields,{"D1_EC08CR", STR0028,"string",.T.})	
    endif
    if ChckCustFld("D1_EC09DB") // Debet and Credit fields are activated only in pairs
        Aadd(aFields,{"D1_EC09DB", STR0029,"string",.T.})	
        Aadd(aFields,{"D1_EC09CR", STR0030,"string",.T.})	
    endif
    Aadd(aFields,{"D1_CLVL", STR0038,"string",.T.})	
    Aadd(aFields,{"D1_CONTA", STR0040,"string",.T.})	
    Aadd(aFields,{"D1_SERIORI", STR0045,"string",.T.})	
    Aadd(aFields,{"D1_NFORI", STR0046,"string",.T.})	
    
    Aadd(aFields,{"D1_CUSTO", STR0056,"number",.T.,'fixedPoint',2})	
    Aadd(aFields,{"D1_CUSFF1", STR0057,"number",.T.,'fixedPoint',2})	
    Aadd(aFields,{"B1_CUSTD", STR0058,"number",.T.,'fixedPoint',2})	

    // create JSON structure from columns array
    Fill_json_colums( aFields, @oMainGrid)

    // Grouping subtotals
    AddGroups(@oSummary,'D1_QUANT',STR0007,'sum')
    AddGroups(@oSummary,'D1_TOTAL',STR0009,'sum')

    // Totals
    AddTotals(@oSummary,'D1_QUANT',STR0007,'sum')
    AddTotals(@oSummary,'D1_TOTAL',STR0009,'sum')

    oMainGrid['summary'] := oSummary


    // fill complete JSON data
    cRet :=  '{"data": { "sections": ['+;
                                        '{"dxDataGridSetup": '+oMainGrid:toJSon()+", "+;
                                        ' "title": "'+STR0047+'",'+;
                                        ' "code": "maingrid",'+;
                                        ' "section": 0,'+;
                                        ' "file": "SECTION1"}'+;
                                        '],'

    cRet +=         ' "sectionsQuantity": 1,'+;
                    ' "showFlatView": false,'+;
                    ' "showRecall": true, '+;
                    ' "mainTitle": "' + STR0047 + '" },'+; // STR0047 =material Movement report
            ' "status": "ok",'+;
            ' "ok": "ok",'+;
            ' "statusText": "ok"}'    
  

    FreeObj(oMainGrid)
    FreeObj(oSummary)

Return cRet


/*/
{Protheus.doc} AddTotals, 
add Totals data for the grid summary 
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param oSummary, Object, Grid Summary
@param cColumn, Char, column name in grid
@param cColText, Char, column title
@param cType, Char, totals type: sum, min,avg,max....
/*/
Static function AddTotals(oSummary,cColumn,cColText,cType)
    Local oFormat := JsonObject():New()
    Local nCnt
    aadd(oSummary['totalItems'],GetDxModel('totalItems'))
    nCnt := Len(oSummary['totalItems'])
    oSummary['totalItems'][nCnt]['column'] := cColumn
    oSummary['totalItems'][nCnt]['summaryType'] := cType
    oFormat:FromJson('{ "type": "fixedPoint","precision": '+str(GetSx3Cache( cColumn, "X3_DECIMAL" ))+' }')
    oSummary['totalItems'][nCnt]['valueFormat'] := oFormat
    oSummary['totalItems'][nCnt]['displayFormat'] := cColText + ': {0}'
    FreeObj(oFormat)
Return

/*/
{Protheus.doc} AddGroups, 
add Grouping data for the grid summary 
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param oSummary, Object, Grid Summary
@param cColumn, Char, column name in grid
@param cColText, Char, column title
@param cType, Char, totals type: sum, min,avg,max....
/*/
Static function AddGroups(oSummary,cColumn,cColText,cType)
    Local oFormat := JsonObject():New()
    Local nCnt
    aadd(oSummary['groupItems'],GetDxModel('groupItems'))
    nCnt := Len(oSummary['groupItems'])
    oSummary['groupItems'][nCnt]['column'] := cColumn
    oSummary['groupItems'][nCnt]['alignByColumn']   := .T.
    oSummary['groupItems'][nCnt]['showInGroupFooter'] := .F.
    oSummary['groupItems'][nCnt]['summaryType'] := cType
    oFormat:FromJson('{ "type": "fixedPoint","precision": '+str(GetSx3Cache( cColumn, "X3_DECIMAL" ))+' }')
    oSummary['groupItems'][nCnt]['valueFormat'] := oFormat
    oSummary['groupItems'][nCnt]['displayFormat'] := cColText + ': {0}'    
    FreeObj(oFormat)
Return

/*/
{Protheus.doc} FSFILTEM, 
fills primary data table with the results of the report 
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param cTable, Char, table name
@param aParams, array, list of pergunte parameters
/*/
Static function FSFILTEM(cTable,aParams)
    Local cSql     := ''
    Local cDelFlag := aParams[17]

    // Step 1: get SD1 data
    cSql  := " insert into " + cTable + " ("
    cSql  += " D1_FILIAL, D1_ITEM, D1_COD, D1_DESCRI, D1_GRUPO, D1_UM,"
    cSql  += " D1_QUANT, D1_VUNIT, D1_TOTAL, D1_TES, D1_SERIE, D1_DOC,"
    cSql  += " D1_EMISSAO, D1_DTDIGIT, D1_LOCAL, D1_LOCALIZ, D1_LOTECTL, D1_NUMDESP,"
    cSql  += " D1_ORIGEM, D1_ITEMCTA, D1_FORNECE, D1_LOJA,"
    cSql  += iif(ChckCustFld("D1_EC06DB")," D1_EC06DB, D1_EC06CR,", "")
    cSql  += iif(ChckCustFld("D1_EC07DB")," D1_EC07DB, D1_EC07CR,", "")
    cSql  += iif(ChckCustFld("D1_EC08DB")," D1_EC08DB, D1_EC08CR,", "")
    cSql  += iif(ChckCustFld("D1_EC09DB")," D1_EC09DB, D1_EC09CR,", "")
    cSql  += " D1_CLVL, D1_CONTA, D1_SERIORI, D1_NFORI,D1_CUSTO,D1_CUSFF1,B1_CUSTD "
    cSql  += ") select "
    cSql  += " D1_FILIAL, D1_ITEM, D1_COD, D1_DESCRI, D1_GRUPO, D1_UM,"
    cSql  += " case when D1_TES < '500' then  D1_QUANT else -1 * D1_QUANT end as D1_QUANT,  D1_VUNIT,"
    cSql  += " case when D1_TES < '500'then D1_TOTAL else -1 * D1_TOTAL end as D1_TOTAL, D1_TES, D1_SERIE, D1_DOC," 
    cSql  += " D1_EMISSAO, D1_DTDIGIT, D1_LOCAL, D1_LOCALIZ, D1_LOTECTL, D1_NUMDESP,"
    cSql  += " D1_ORIGEM, D1_ITEMCTA, D1_FORNECE, D1_LOJA,"
    cSql  += iif(ChckCustFld("D1_EC06DB")," D1_EC06DB, D1_EC06CR,", "")
    cSql  += iif(ChckCustFld("D1_EC07DB")," D1_EC07DB, D1_EC07CR,", "")
    cSql  += iif(ChckCustFld("D1_EC08DB")," D1_EC08DB, D1_EC08CR,", "")
    cSql  += iif(ChckCustFld("D1_EC09DB")," D1_EC09DB, D1_EC09CR,", "")
    cSql  += " D1_CLVL, D1_CONTA, D1_SERIORI, D1_NFORI,D1_CUSTO,D1_CUSFF1,B1_CUSTD"
    cSql  += " from " + RetSqlName("SD1") + " d "
    cSql  += " join " + RetSqlName("SB1") + " b on d.D1_COD = b.B1_COD  and b.B1_FILIAL  = '" + xFilial('SB1') + "'"
    cSql  += " where D1_FILIAL  = '" + xFilial('SD1') + "'"
    if cDelFlag == "1" // do not add deleted items
        cSql  += " and d.D_E_L_E_T_ = ''"
    endif
    cSql  += AddSqlParam( "D1_EMISSAO",  ">=", aParams[1] )
    cSql  += AddSqlParam( "D1_EMISSAO",  "<=", aParams[2] )
    cSql  += AddSqlParam( "D1_DTDIGIT",  ">=", aParams[3] )
    cSql  += AddSqlParam( "D1_DTDIGIT",  "<=", aParams[4] )
    cSql  += AddSqlParam( "D1_COD",      ">=", aParams[5] )
    cSql  += AddSqlParam( "D1_COD",      "<=", aParams[6] )
    cSql  += AddSqlParam( "D1_LOCAL",    ">=", aParams[7] )
    cSql  += AddSqlParam( "D1_LOCAL",    "<=", aParams[8] )
    cSql  += AddSqlParam( "D1_LOTECTL",  ">=", aParams[9] )
    cSql  += AddSqlParam( "D1_LOTECTL",  "<=", aParams[10] )
    cSql  += AddSqlParam( "D1_TES",      ">=", aParams[11] )
    cSql  += AddSqlParam( "D1_TES",      "<=", aParams[12] )
    cSql  += AddSqlParam( "D1_LOCALIZ",  ">=", aParams[13] )
    cSql  += AddSqlParam( "D1_LOCALIZ",  "<=", aParams[14] )
    cSql  += AddSqlParam( "D1_FORNECE",  ">=", aParams[15] )
    cSql  += AddSqlParam( "D1_FORNECE",  "<=", aParams[16] )
    cSql  += AddSqlParam( "D1_ITEMCTA",   "=", aParams[18] )

    If TCSQLEXEC(cSql) < 0
        conout( "Error at MainQuery 1 >" + TCSQLError(), 'MA-3' )
        Return
    Endif

    // Step 2: get SD2 data
    cSql  := " insert into " + cTable + " ("
    cSql  += " D1_FILIAL, D1_ITEM, D1_COD, D1_DESCRI, D1_GRUPO, D1_UM,"
    cSql  += " D1_QUANT, D1_VUNIT, D1_TOTAL, D1_TES, D1_SERIE, D1_DOC,"
    cSql  += " D1_EMISSAO, D1_DTDIGIT, D1_LOCAL, D1_LOCALIZ, D1_LOTECTL,"
    cSql  += " D1_ITEMCTA, D1_FORNECE, D1_LOJA,"
    cSql  += iif(ChckCustFld("D1_EC06DB")," D1_EC06DB, D1_EC06CR,", "")
    cSql  += iif(ChckCustFld("D1_EC07DB")," D1_EC07DB, D1_EC07CR,", "")
    cSql  += iif(ChckCustFld("D1_EC08DB")," D1_EC08DB, D1_EC08CR,", "")
    cSql  += iif(ChckCustFld("D1_EC09DB")," D1_EC09DB, D1_EC09CR,", "")
    cSql  += " D1_CLVL, D1_CONTA,D1_CUSTO,D1_CUSFF1,B1_CUSTD"
    cSql  +=  ") select DISTINCT "
    cSql  += " d.D2_FILIAL, d.D2_ITEM, d.D2_COD, d.D2_DESCRI, d.D2_GRUPO, d.D2_UM,"
    cSql  += " case when D2_TES < '500' then  D2_QUANT else -1 * D2_QUANT end as D2_QUANT, d.D2_PRCVEN, "
    cSql  += " case when D2_TES < '500'then D2_TOTAL else -1 * D2_TOTAL end as D2_TOTAL, d.D2_TES, d.D2_SERIE, d.D2_DOC,"
    cSql  += " d.D2_EMISSAO, d.D2_DTDIGIT, d.D2_LOCAL, d.D2_LOCALIZ, d.D2_LOTECTL,"
    cSql  += " d.D2_ITEMCC, d.D2_CLIENTE, d.D2_LOJA,"
    cSql  += iif(ChckCustFld("D1_EC06DB")," D2_EC06DB, D2_EC06CR,", "")
    cSql  += iif(ChckCustFld("D1_EC07DB")," D2_EC07DB, D2_EC07CR,", "")
    cSql  += iif(ChckCustFld("D1_EC08DB")," D2_EC08DB, D2_EC08CR,", "")
    cSql  += iif(ChckCustFld("D1_EC09DB")," D2_EC09DB, D2_EC09CR,", "")    
    cSql  += " d.D2_CLVL, d.D2_CONTA,d.D2_CUSTO1,d.D2_CUSFF1,B1_CUSTD"
    cSql  += " from " + RetSqlName("SD2") + " d"	
    cSql  += " join " + RetSqlName("SB1") + " b on d.D2_COD = b.B1_COD  and b.B1_FILIAL  = '" + xFilial('SB1') + "'"
    cSql  += " where D2_FILIAL  = '" + xFilial('SD2') + "'"
    if cDelFlag == "1" // do not add deleted items
        cSql  += " and d.D_E_L_E_T_ = ''"
    endif
    cSql  += AddSqlParam( "D2_EMISSAO",  ">=", aParams[1] )
    cSql  += AddSqlParam( "D2_EMISSAO",  "<=", aParams[2] )
    cSql  += AddSqlParam( "D2_DTDIGIT",  ">=", aParams[3] )
    cSql  += AddSqlParam( "D2_DTDIGIT",  "<=", aParams[4] )
    cSql  += AddSqlParam( "D2_COD",      ">=", aParams[5] )
    cSql  += AddSqlParam( "D2_COD",      "<=", aParams[6] )
    cSql  += AddSqlParam( "D2_LOCAL",    ">=", aParams[7] )
    cSql  += AddSqlParam( "D2_LOCAL",    "<=", aParams[8] )
    cSql  += AddSqlParam( "D2_LOTECTL",  ">=", aParams[9] )
    cSql  += AddSqlParam( "D2_LOTECTL",  "<=", aParams[10] )
    cSql  += AddSqlParam( "D2_TES",      ">=", aParams[11] )
    cSql  += AddSqlParam( "D2_TES",      "<=", aParams[12] )
    cSql  += AddSqlParam( "D2_LOCALIZ",  ">=", aParams[13] )
    cSql  += AddSqlParam( "D2_LOCALIZ",  "<=", aParams[14] )
    cSql  += AddSqlParam( "D2_ITEMCC",    "=", aParams[18] ) 


    If TCSQLEXEC(cSql) < 0
        conout( "Error at MainQuery 2 >" + TCSQLError(), 'MA-3' )
        Return
    Endif


    // Step 3: get SD3 data
    cSql  := " insert into " + cTable + " ("
    cSql  += " D1_FILIAL, D1_COD,"
    cSql  += " D1_DESCRI, D1_GRUPO, D1_UM,"
    cSql  += " D1_QUANT, D1_TES, D1_DOC,"
    cSql  += " D1_EMISSAO, D1_DTDIGIT, D1_LOCAL, D1_LOCALIZ, D1_LOTECTL,"
    cSql  += iif(ChckCustFld("D1_EC06DB")," D1_EC06DB, D1_EC06CR,", "")
    cSql  += iif(ChckCustFld("D1_EC07DB")," D1_EC07DB, D1_EC07CR,", "")
    cSql  += iif(ChckCustFld("D1_EC08DB")," D1_EC08DB, D1_EC08CR,", "")
    cSql  += iif(ChckCustFld("D1_EC09DB")," D1_EC09DB, D1_EC09CR,", "")
    cSql  += " D1_CLVL,D1_CONTA,D1_CUSTO,D1_CUSFF1,B1_CUSTD"
    cSql  +=  ") select "
    cSql  += " d.D3_FILIAL, d.D3_COD," 
    cSql  += " b.B1_DESC, "
    cSql  += " d.D3_GRUPO, d.D3_UM,"
    cSql  += " case when D3_TM < '500' then  D3_QUANT else -1 * D3_QUANT end as D3_QUANT, d.D3_TM, D3_DOC,"
    cSql  += " d.D3_EMISSAO, d.D3_EMISSAO AS D1_DTDIGIT, d.D3_LOCAL, d.D3_LOCALIZ, d.D3_LOTECTL,"
    cSql  += iif(ChckCustFld("D1_EC06DB")," D3_EC06DB, D3_EC06CR,", "")
    cSql  += iif(ChckCustFld("D1_EC07DB")," D3_EC07DB, D3_EC07CR,", "")
    cSql  += iif(ChckCustFld("D1_EC08DB")," D3_EC08DB, D3_EC08CR,", "")
    cSql  += iif(ChckCustFld("D1_EC09DB")," D3_EC09DB, D3_EC09CR,", "")
    cSql  += " d.D3_CLVL, d.D3_CONTA,d.D3_CUSTO1,d.D3_CUSFF1,B1_CUSTD"
    cSql  += " from " + RetSqlName("SD3") + " d"
    cSql  += " join " + RetSqlName("SB1") + " b on d.D3_COD = b.B1_COD"
    cSql  += " where d.D3_FILIAL  = '" + xFilial('SD3') + "' and b.B1_FILIAL  = '" + xFilial('SB1') + "'"
    if cDelFlag == "1" // do not add deleted items
        cSql  += " and d.D_E_L_E_T_ = ''"
    endif
    cSql  += AddSqlParam( "D3_EMISSAO",  ">=", aParams[1] )
    cSql  += AddSqlParam( "D3_EMISSAO",  "<=", aParams[2] )
    cSql  += AddSqlParam( "D3_EMISSAO",  ">=", aParams[3] )
    cSql  += AddSqlParam( "D3_EMISSAO",  "<=", aParams[4] )
    cSql  += AddSqlParam( "D3_COD",      ">=", aParams[5] )
    cSql  += AddSqlParam( "D3_COD",      "<=", aParams[6] )
    cSql  += AddSqlParam( "D3_LOCAL",    ">=", aParams[7] )
    cSql  += AddSqlParam( "D3_LOCAL",    "<=", aParams[8] )
    cSql  += AddSqlParam( "D3_LOTECTL",  ">=", aParams[9] )
    cSql  += AddSqlParam( "D3_LOTECTL",  "<=", aParams[10] )
    cSql  += AddSqlParam( "D3_TM",       ">=", aParams[11] ) // D1_TES
    cSql  += AddSqlParam( "D3_TM",       "<=", aParams[12] )
    cSql  += AddSqlParam( "D3_LOCALIZ",  ">=", aParams[13] )
    cSql  += AddSqlParam( "D3_LOCALIZ",  "<=", aParams[14] )


    If TCSQLEXEC(cSql) < 0
        conout( "Error at MainQuery 3 >" + TCSQLError(), 'MA-3' )
        Return
    Endif

Return

/*/
{Protheus.doc} AddMvParam, 
moves parameter value to the array, 
or fills array item with the defalult placeholder  DEFAULTPARVAL
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param aParams, array, list of pergunte parameters
@param cMv_par, Char, parameter value (string format only)
/*/
static function AddMvParam( aParams, cMv_par )

    aadd(aParams, Iif(!EMPTY(AllTrim(cMv_par)),AllTrim(cMv_par),DEFAULTPARVAL))

return

/*/
{Protheus.doc} AddSqlParam, 
returns SQL "where" condition if parameter value is not default ( != DEFAULTPARVAL)
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param cParNam, Char, DB table coumn name
@param cParSign, Char, comparision operation (=, >,< etc)
@param cParVal, Char, value
@return cParStr, Char, part of the SQL selection
/*/
static function AddSqlParam( cParNam,  cParSign, cParVal )
    local cParStr := " "
    If cParVal <> DEFAULTPARVAL
        cParStr := " and "  + cParNam  + " " + cParSign + " '" + alltrim(cParVal) + "' "
    endif
return cParStr
 
/*/{Protheus.doc} Fill_json_colums
generates Json columns for a table
@author Maxim Popenker
@since  13/02/2023
@param  aFields,  Array,      list of the fields for selected data structure and their properties.
@param  oDataGridOut, Object,      Json grid object
@version 1.0
/*/
static function Fill_json_colums( aFieldsIn, oDataGridOut)
    local nX
    local oCol
    local oFormat
    local oJsonCSS

   For nX:=1 To Len(aFieldsIn)
      oCol := GetDxModel('columns')
      oCol['dataField'] := aFieldsIn[nX,FIELDNAME]
      oCol['caption']   := Alltrim(aFieldsIn[nX,FIELDDESC])
      oCol['dataType']  := aFieldsIn[nX,FIELDTYPE]
      oCol['visible']   := aFieldsIn[nX,FIELDVISIBLE]

      If (aFieldsIn[nX,FIELDTYPE]=="number")
         If len(aFieldsIn[nX])>STRCOLM .and. !empty(aFieldsIn[nX,TYPEFORMAT])
            oFormat := JsonObject():New() //Define customized algnment for 
            oFormat['type'] := aFieldsIn[nX,TYPEFORMAT]
            if !Empty(aFieldsIn[nX,DECIMAFORMAT])
               oFormat['precision'] := aFieldsIn[nX,DECIMAFORMAT]
            Endif
            oCol['format'] := oFormat
         Endif

         oJsonCSS := JsonObject():New() //Define customized algnment for 
         oJsonCSS:FromJson('{"rowType":"header","settings": [{"cssKey":"text-align","value":"center"}]}')
         oCol['__customCss']:= {}
         aadd(oCol['__customCss'],oJsonCSS)
         FreeObj(oJsonCSS)
      Else
        oCol['allowGrouping']   := .T.
        If (aFieldsIn[nX,FIELDTYPE]=="date")
            oCol['format'] := "dd.MM.yyyy"
        endif
      Endif

      aadd(oDataGridOut['columns'], oCol)
      FreeObj(oCol)
    Next
    FreeObj(oFormat)
Return

/*/{Protheus.doc} fill_db_field
fills an array for creation of the temporary DB table
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param  aStruc,  Array,      list of the fields for selected data table  and their properties.
@param  cFieldname, Char,    field name from the SX3 table
/*/
static function fill_db_field(aStruc, cFieldname)

    aadd(aStruc,{cFieldname ,GetSx3Cache(cFieldname,"X3_TIPO"), GetSx3Cache(cFieldname,"X3_TAMANHO"), GetSx3Cache( cFieldname, "X3_DECIMAL" )})

Return

/*/{Protheus.doc} fill_zdb_field
fills an array for creation of the temporary DB table
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param  aStruc,  Array,      list of the fields for selected data table  and their properties.
@param  cFieldname, Char,    field name from the SX3 table
@param  nLen, Numeric,    field length
/*/
static function fill_zdb_field(aStruc, cFieldname, nLen)

    aadd(aStruc,{cFieldname ,GetSx3Cache(cFieldname,"X3_TIPO"), nLen, 0})

Return

/*/{Protheus.doc} ChckCustFld
    check if a custom field is active in the database
    @author Maxim Popenker
    @since  13/02/2023
    @type
    @version 1.0
    @param cFldname, Char, name of the field
    @return locic, True if the field is active, Flase otherwise

/*/
static function ChckCustFld(cFldname)
    local lActive := .F. 

    IF SD1->(Fieldpos(cFldname)) > 0 //field is active 
        lActive := .T.
    endif

Return lActive

/*/{Protheus.doc} fill_cdb_field
fills an ar                                                                                                                       ray for creation of the temporary DB table, checking if the custom field is activated
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param  aStruc,  Array,      list of the fields for selected data table  and their properties.
@param  cFieldname, Char,    field name from the SX3 table
/*/
static function fill_cdb_field(aStruc, cFieldname)

    if ChckCustFld(cFieldname)
        aadd(aStruc,{cFieldname ,GetSx3Cache(cFieldname,"X3_TIPO"), GetSx3Cache(cFieldname,"X3_TAMANHO"), GetSx3Cache( cFieldname, "X3_DECIMAL" )})        
    endif

Return



                   
//Merge Russia R14 
                   
                   
