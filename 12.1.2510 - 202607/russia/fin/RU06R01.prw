#INCLUDE 'protheus.ch'
#INCLUDE 'fwmvcdef.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'ru06r01.ch'

#DEFINE DELETEFILE .F.
#DEFINE FIELDNAME 1
#DEFINE FIELDDESC 2
#DEFINE FIELDTYPE 3
#DEFINE FIELDVISIBLE 4
#DEFINE TYPEFORMAT 5
#DEFINE DECIMAFORMAT 6
#DEFINE STRCOLM 4 // columns for String, Numeric has more columns
#DEFINE DEFAULTPARVAL '*'

/*/{Protheus.doc} RU06R0101
    Turnover report by Vendors using Angular output
    @type  Function
    @author Maxim Popenker
    @since 16/06/2023
    @version 1.0
    @example
    (examples)
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5029
    /*/
Function RU06R0101()

    Local cFile := Lower(CriaTrab(NIL, .F.)  )
    Local nHandle       
    Local oJson := JsonObject():New()
    Local cControlKey := 'F'+StrZero(Randomize( 1, 999999 ),6)
    Local lRecall := .F.
    local aParams := {} // selection parameters
    local cTable1 := ""

    If MyParamBox() //Pergunte("RU06R01",.T.) // if Selection parameters were completed with OK

        oJson['controlKey']  := cControlKey
        oJson['files']    := {'SECTION1'}
        oJson['mv_par01']    := dtos(mv_par01) //Date from
        oJson['mv_par02']    := dtos(mv_par02) //Date to
        oJson['mv_par03']    := Alltrim(mv_par03) 
        oJson['mv_par04']    := Alltrim(mv_par04) 
        oJson['mv_par05']    := mv_par05 
        oJson['mv_par06']    := Alltrim(mv_par06) 
        oJson['mv_par07']    := Alltrim(mv_par07) 


    // pass parameters for data selection 
        AddMvParam(aParams, dtos(mv_par01)) //date (from)          
        AddMvParam(aParams, dtos(mv_par02)) //date (to) 

        AddMvParam(aParams, Alltrim(mv_par03)) //Customer code (e1_cliente)       
        AddMvParam(aParams, Alltrim(mv_par04)) //Customer dept (e1_loja)  

        AddMvParam(aParams, mv_par05) // currency code  

        AddMvParam(aParams, Alltrim(mv_par06)) //Filial from       
        AddMvParam(aParams, Alltrim(mv_par07)) //Filial to

        //Create report data, insert into the temporary DB table and then pass to angular via the file at the server
        cTable1 := 'SECTION1' + "_" + cControlKey
        FwMsgRun(,{|oSay| MainDataCreate(aParams,cTable1)},'',STR0048) // STR0048 = wait for process

        nHandle := FCREATE(cFile+".dxparam", 0)
        FWRITE(nHandle, oJson:toJSon())
        FCLOSE(nHandle) 

        //invoke Angular grid engine
        lRecall := RU99X1203_DATAGRID3('RU06R0102','RU06R0103',cFile, DELETEFILE)
    
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

    RU06XREP01(@aStru1,"FK7_IDDOC") //non-display field to link to FK1
    RU06XREP01(@aStru1,"A1_FILIAL") //Fillial
    RU06XREP01(@aStru1,"A1_COD") //Supplier’s code
    RU06XREP01(@aStru1,"A1_LOJA") //Supplier’s unit
    RU06XREP01(@aStru1,"A1_NOME ") //Supplier’s name
    RU06XREP01(@aStru1,"E1_F5QCODE")//Contract code
    RU06XREP01(@aStru1,"F5Q_DESCR") //Contract description
    RU06XREP01(@aStru1,"E1_NATUREZ") //Class
    RU06XREP01(@aStru1,"ED_DESCRIC") //Class description
    RU06XREP01(@aStru1,"E1_PREFIXO") //AR prefix
    RU06XREP01(@aStru1,"E1_NUM") //AR number
    RU06XREP01(@aStru1,"E1_PARCELA") //AP installment
    RU06XREP01(@aStru1,"E1_EMISSAO") //AR issue date
    RU06XREP01(@aStru1,"E1_TIPO") //AR type
    RU06XREP01(@aStru1,"E1_MOEDA") //Currency code
    RU06XREP01(@aStru1,"CTO_SIMB") //Currency - short name
    RU06XREP01(@aStru1,"E1_CONUNI") //Conventional units
    
    //sums in Document currency
    RU06XREP04(@aStru1,"SALDOI_DD",13,2) //Initial balance  - Debit
    RU06XREP04(@aStru1,"SALDOI_CD",13,2) //Initial balance  - Credit
    RU06XREP04(@aStru1,"SALDOI_SD",13,2) //Initial balance  - Summarized
    RU06XREP04(@aStru1,"TURNOV_DD",13,2) //Turnover  - Debit
    RU06XREP04(@aStru1,"TURNOV_CD",13,2) //Turnover  - Credit
    RU06XREP04(@aStru1,"SALDOF_DD",13,2) //Final balance  - Debit
    RU06XREP04(@aStru1,"SALDOF_CD",13,2) //Final balance  - Credit
    RU06XREP04(@aStru1,"SALDOF_SD",13,2) //Final balance  - Summarized

    //sums in Local (Home) currency
    RU06XREP04(@aStru1,"SALDOI_DH",13,2) //Initial balance  - Debit
    RU06XREP04(@aStru1,"SALDOI_CH",13,2) //Initial balance  - Credit
    RU06XREP04(@aStru1,"SALDOI_SH",13,2) //Initial balance  - Summarized
    RU06XREP04(@aStru1,"TURNOV_DH",13,2) //Turnover  - Debit
    RU06XREP04(@aStru1,"TURNOV_CH",13,2) //Turnover  - Credit
    RU06XREP04(@aStru1,"SALDOF_DH",13,2) //Final balance  - Debit
    RU06XREP04(@aStru1,"SALDOF_CH",13,2) //Final balance  - Credit
    RU06XREP04(@aStru1,"SALDOF_SH",13,2) //Final balance  - Summarized

    TCInternal(30, 'AUTORECNO')

    DbCreate(cTableName,aStru1,"TOPCONN")
    TCInternal(30, 'OFF')
    
    //Create and populate the main query with all data 
    FwMsgRun(,{|oSay|LoadData(cTableName,aPar)},'',STR0048) // STR0048 = wait for process

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} RU06R0102
create the Angular report JSON structure
@author Maxim Popenker
@since  13/02/2023
@type
@param cKey, Char, key
@version 1.0
/*/
 Function RU06R0102(cKey)
    Local oMainGrid := GetDxModel('main')
    Local oSummary := GetDxModel('summary')
    Local aFields := {}	
    Local oParamJson := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey) 
    Local cStartDate := oParamJson['mv_par01']
    Local cEndDate   := oParamJson['mv_par02']
    Local oDD := GetDxModel('drillDownLink')

    local aTemp
    Local aGrarr := {}  
    Local aTitle := {}
    Local aCode := {} 
    local cMainTitle
    Local oDD1 := GetDxModel('drillDownLink')
    local cDDType := "ADVPL"


    //Local oCol 
    //Local aDrillDowns := {}
    //Local nX
    //Local cDrillDefs
    //Local aFieldsDDG1

    // Grid configuration parameters
    oMainGrid['columnResizingMode'] 	:= 'widget'
    oMainGrid['columnFixing']['enabled'] 	:= .T.
    oMainGrid['scrolling'] := '{}'
    oMainGrid['stateStoring']['enabled'] := .T.
    oMainGrid['stateStoring']['storageKey'] := 'RU06R01' //+ RetCodUsr()

    //Column definition for the main grid
    Aadd(aFields,{"A1_FILIAL", STR0001,"string",.T.}) //Fillial
    Aadd(aFields,{"A1_COD", STR0002,"string",.T.}) //Supplier’s code
    Aadd(aFields,{"A1_LOJA", STR0003,"string",.T.}) //Supplier’s unit
    Aadd(aFields,{"A1_NOME", STR0004,"string",.T.}) //Supplier’s name
    Aadd(aFields,{"E1_F5QCODE", STR0005,"string",.T.})//Contract code
    Aadd(aFields,{"F5Q_DESCR", STR0006,"string",.T.}) //Contract description
    Aadd(aFields,{"E1_NATUREZ", STR0007,"string",.T.}) //Class
    Aadd(aFields,{"ED_DESCRIC", STR0008,"string",.T.}) //Class description
    Aadd(aFields,{"E1_PREFIXO", STR0009,"string",.T.}) //AR prefix
    Aadd(aFields,{"E1_NUM", STR0010,"string",.T.}) //AR number
    Aadd(aFields,{"E1_PARCELA", STR0011,"string",.T.}) //AP installment
    Aadd(aFields,{"E1_EMISSAO", STR0012,"date",.T.}) //AR issue date
    Aadd(aFields,{"E1_TIPO", STR0013,"string",.T.}) //AR type
    Aadd(aFields,{"E1_MOEDA", STR0014,"string",.T.}) //Currency
    Aadd(aFields,{"CTO_SIMB", STR0014,"string",.T.}) //Currency
    Aadd(aFields,{"E1_CONUNI", STR0015,"string",.T.}) //Conventional units
    //sums in Document currency
    Aadd(aFields,{"SALDOI_DD", STR0016,"number",.T.,'fixedPoint',2}) //Initial balance  - Debit
    Aadd(aFields,{"SALDOI_CD", STR0017,"number",.T.,'fixedPoint',2}) //Initial balance  - Credit
    Aadd(aFields,{"SALDOI_SD", STR0018,"number",.T.,'fixedPoint',2}) //Initial balance  - Summarized
    Aadd(aFields,{"TURNOV_DD", STR0019,"number",.T.,'fixedPoint',2}) //Turnover  - Debit
    Aadd(aFields,{"TURNOV_CD", STR0020,"number",.T.,'fixedPoint',2}) //Turnover  - Credit
    Aadd(aFields,{"SALDOF_DD", STR0021,"number",.T.,'fixedPoint',2}) //Final balance  - Debit
    Aadd(aFields,{"SALDOF_CD", STR0022,"number",.T.,'fixedPoint',2}) //Final balance  - Credit
    Aadd(aFields,{"SALDOF_SD", STR0023,"number",.T.,'fixedPoint',2}) //Final balance  - Summarized	
    //sums in Local (home) currency
    Aadd(aFields,{"SALDOI_DH", STR0026,"number",.T.,'fixedPoint',2}) //Initial balance  - Debit
    Aadd(aFields,{"SALDOI_CH", STR0027,"number",.T.,'fixedPoint',2}) //Initial balance  - Credit
    Aadd(aFields,{"SALDOI_SH", STR0028,"number",.T.,'fixedPoint',2}) //Initial balance  - Summarized
    Aadd(aFields,{"TURNOV_DH", STR0029,"number",.T.,'fixedPoint',2}) //Turnover  - Debit
    Aadd(aFields,{"TURNOV_CH", STR0030,"number",.T.,'fixedPoint',2}) //Turnover  - Credit
    Aadd(aFields,{"SALDOF_DH", STR0031,"number",.T.,'fixedPoint',2}) //Final balance  - Debit
    Aadd(aFields,{"SALDOF_CH", STR0032,"number",.T.,'fixedPoint',2}) //Final balance  - Credit
    Aadd(aFields,{"SALDOF_SH", STR0033,"number",.T.,'fixedPoint',2}) //Final balance  - Summarized	

    // create JSON structure from columns array
    RU06XREP02( aFields, @oMainGrid)

    // Grouping subtotals
    AddGroups(@oSummary,"SALDOI_DD", STR0016,'sum') //Initial balance  - Debit
    AddGroups(@oSummary,"SALDOI_CD", STR0017,'sum') //Initial balance  - Credit
    AddGroups(@oSummary,"SALDOI_SD", STR0018,'sum') //Initial balance  - Summarized
    AddGroups(@oSummary,"TURNOV_DD", STR0019,'sum') //Turnover  - Debit
    AddGroups(@oSummary,"TURNOV_CD", STR0020,'sum') //Turnover  - Credit
    AddGroups(@oSummary,"SALDOF_DD", STR0021,'sum') //Final balance  - Debit
    AddGroups(@oSummary,"SALDOF_CD", STR0022,'sum') //Final balance  - Credit
    AddGroups(@oSummary,"SALDOF_SD", STR0023,'sum') //Final balance  - Summarized	
    AddGroups(@oSummary,"SALDOI_DH", STR0026,'sum') //Initial balance  - Debit
    AddGroups(@oSummary,"SALDOI_CH", STR0027,'sum') //Initial balance  - Credit
    AddGroups(@oSummary,"SALDOI_SH", STR0028,'sum') //Initial balance  - Summarized
    AddGroups(@oSummary,"TURNOV_DH", STR0029,'sum') //Turnover  - Debit
    AddGroups(@oSummary,"TURNOV_CH", STR0030,'sum') //Turnover  - Credit
    AddGroups(@oSummary,"SALDOF_DH", STR0031,'sum') //Final balance  - Debit
    AddGroups(@oSummary,"SALDOF_CH", STR0032,'sum') //Final balance  - Credit
    AddGroups(@oSummary,"SALDOF_SH", STR0033,'sum') //Final balance  - Summarized	

    // Totals
    AddTotals(@oSummary,"SALDOI_DD", STR0016,'sum') //Initial balance  - Debit
    AddTotals(@oSummary,"SALDOI_CD", STR0017,'sum') //Initial balance  - Credit
    AddTotals(@oSummary,"SALDOI_SD", STR0018,'sum') //Initial balance  - Summarized
    AddTotals(@oSummary,"TURNOV_DD", STR0019,'sum') //Turnover  - Debit
    AddTotals(@oSummary,"TURNOV_CD", STR0020,'sum') //Turnover  - Credit
    AddTotals(@oSummary,"SALDOF_DD", STR0021,'sum') //Final balance  - Debit
    AddTotals(@oSummary,"SALDOF_CD", STR0022,'sum') //Final balance  - Credit
    AddTotals(@oSummary,"SALDOF_SD", STR0023,'sum') //Final balance  - Summarized	
    AddTotals(@oSummary,"SALDOI_DH", STR0026,'sum') //Initial balance  - Debit
    AddTotals(@oSummary,"SALDOI_CH", STR0027,'sum') //Initial balance  - Credit
    AddTotals(@oSummary,"SALDOI_SH", STR0028,'sum') //Initial balance  - Summarized
    AddTotals(@oSummary,"TURNOV_DH", STR0029,'sum') //Turnover  - Debit
    AddTotals(@oSummary,"TURNOV_CH", STR0030,'sum') //Turnover  - Credit
    AddTotals(@oSummary,"SALDOF_DH", STR0031,'sum') //Final balance  - Debit
    AddTotals(@oSummary,"SALDOF_CH", STR0032,'sum') //Final balance  - Credit
    AddTotals(@oSummary,"SALDOF_SH", STR0033,'sum') //Final balance  - Summarized	

    oMainGrid['summary'] := oSummary

    // Define drilldown relations
    oDD['callerGridId'] 		:= "maingrid"
    oDD['callerGridColumn']	:= "*"
    oDD['drillDownGridId'] 	:= "DD"//"DD"

    // fill complete JSON data

    AADD(aGrarr, oMainGrid)

      
    aTemp := STR0047+' '+FormatDate(cStartDate)+'-'+FormatDate(cEndDate)
    AADD(aTitle, aTemp)

     
    AADD(aCode, "maingrid")

    
    cMainTitle := STR0047+' '+FormatDate(cStartDate)+'-'+FormatDate(cEndDate)

    cRet := RU06XREP03(aGrarr, oDD1, oDD, aTitle, aCode, cMainTitle, cDDType)

//     cRet := ""

//     cRet :=  '{"data": { "sections": ['+;
//                                         '{"dxDataGridSetup": '+oMainGrid:toJSon()+", "+;
//                                         ' "title": "'+STR0047+' '+FormatDate(cStartDate)+'-'+FormatDate(cEndDate)+'",'+;
//                                         ' "code": "maingrid",'+;
//                                         ' "section": 0,'+;
//                                         ' "file": "SECTION1"}'+;
//                                         '],'
//    //  drilldown 
//     cRet += '"drillDowns": ['+;
//                                        '{'+;
//                                        ' "title": "DD title",'+;
//                                        ' "code": "DD",'+;
//                                        ' "drillDownType": "ADVPL"}'+;
//                                        '],'+;
//                                        ' "drillDownDefs": [' + oDD:toJSon() + '],'

//     cRet +=         ' "sectionsQuantity": 1,'+;
//                     ' "showFlatView": false,'+;
//                     ' "showRecall": false, '+;
//                     ' "mainTitle": "'+STR0047+' '+FormatDate(cStartDate)+'-'+FormatDate(cEndDate)+'" },'+; // 
//             ' "status": "ok",'+;
//             ' "ok": "ok",'+;
//             ' "statusText": "ok"}'    
  

    FreeObj(oMainGrid)
    FreeObj(oSummary)
    FreeObj(oDD)
    FreeObj(oDD1)

Return cRet


/*/{Protheus.doc} RU06R0103
   drill-down processor from main angular report
   @author Maxim Popenker
   @since  18/10/2023
   @type
   @version 1.0
/*/
function RU06R0103(cColumn, cGridID,cDrillDownID,cKey,cBody)
    Local oData := JSONOBJECT():NEW()
    Local cRet 
    Local cBodyTmp as Character


    cBodyTmp := DecodeUtf8(cBody)
    If cBodyTmp == Nil
        cBodyTmp := cBody
    Endif
    oData:FROMJSON(cBodyTmp)

    If cColumn == 'E1_PREFIXO' .OR. cColumn == 'E1_NUM' ;
         .OR. cColumn == 'E1_EMISSAO' .OR. cColumn == 'E1_PARCELA' 
        //  imvoice    
        ShowSE2(oData['E1_PREFIXO'],oData['E1_NUM'],oData['E1_PARCELA'],oData['E1_TIPO'],oData['A1_FILIAL'])

    ElseIf cColumn == 'E1_F5QCODE' .or.  cColumn == 'F5Q_DESCR' 
        //  Agreement
        ShowF5Q(oData['E1_F5QCODE'],oData['A1_FILIAL'],STR0034)

    Endif 

    FreeObj(oData)
Return cRet

/*/{Protheus.doc} ShowSE2
   display invoice (SE2) from drill-down
   @author Maxim Popenker
   @since  18/10/2023
   @type
   @version 1.0
/*/
Static function ShowSE2(cPrefE2,cNumE2,cParc,cTip,cFil)

    Local cE2Num
    Local cPrefixo
    Local cRecno
    Local cAliasQry := GetNextAlias()
    Local aSaveArea  as Array
    Local aAreaSE2   as Array
    Local cSaveFil := cfilant
    Private cCadastro

    aSaveArea := GetArea() 
    aAreaSE2 := SE2->(GetArea())

    BeginSql Alias cAliasQry
        SELECT SE2.E2_PREFIXO, SE2.E2_NUM, SE2.R_E_C_N_O_ SE2RECNO
        FROM %table:SE2% SE2
        WHERE
        SE2.E2_FILIAL = %Exp:cFil% AND 
        E2_PREFIXO = %Exp:cPrefE2% AND E2_NUM = %Exp:cNumE2% AND
        SE2.%notDel%
    EndSql

    (cAliasQry)->(DbGoTop())
    If (cAliasQry)->(!Eof())
        IIF(EMPTY(cCadastro), cCadastro := "ZZSPR13", '') // AxVisual will get crit error with empty cCadastro
        cRecno := (cAliasQry)->(SE2RECNO)
        cPrefixo := (cAliasQry)->(E2_PREFIXO)
        cE2Num := (cAliasQry)->(E2_NUM)
        DbSelectArea('SE2')
        DbSetOrder(1)
        SE2->(DBGoTop())
        if SE2->(MsSeek(cFil + cPrefixo + cE2Num))
            cfilant:=cfil
            AxVisual('SE2', cRecno, 2)
            cfilant:=cSaveFil
        endif
        (cAliasQry)->(DbCloseArea())
    Else
        MsgAlert(STR0036, STR0037) // Error, Record not found
    Endif

    RestArea(aAreaSE2)  
    RestArea(aSaveArea) 
Return

/*/{Protheus.doc} ShowF5Q
   display contract (F5q) from drill-down
   @author Maxim Popenker
   @since  18/10/2023
   @type
   @version 1.0
/*/
Static function ShowF5Q(cF5q_code,cFil,cTitle)

    Local aSaveArea  as Array
    Local aAreaF5Q   as Array
    Local cSaveFil := cfilant

    if cF5q_code == Nil .or. cF5q_code == ''
        Return
    endif

    aSaveArea := GetArea() 
    aAreaF5Q := F5Q->(GetArea())

    DbSelectArea('F5Q')
    DbSetOrder(2)
    F5Q->(DBGoTop())
    if F5Q->(MsSeek(cFil + cF5q_code))
        cfilant:=cfil
        FWExecView(cTitle, 'RU69T01RUS', MODEL_OPERATION_VIEW,, { || .T. },, 15 ) 
        cfilant:=cSaveFil
    endif

    RestArea(aAreaF5Q)  
    RestArea(aSaveArea) 
return

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
    //oFormat:FromJson('{ "type": "fixedPoint","precision": '+str(GetSx3Cache( cColumn, "X3_DECIMAL" ))+' }')
    oFormat:FromJson('{ "type": "fixedPoint","precision": "2" }')
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
    oFormat:FromJson('{ "type": "fixedPoint","precision": "2" }')
    oSummary['groupItems'][nCnt]['valueFormat'] := oFormat
    oSummary['groupItems'][nCnt]['displayFormat'] := cColText + ': {0}'    
    FreeObj(oFormat)
Return

/*/
{Protheus.doc} LoadData, 
 fills primary data table with the results of the report 
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param cTable, Char, table name
@param aParams, array, list of pergunte parameters
/*/
Static function LoadData(cTable,aParams)
    Local cSql     := ''
    Local cStartDate := aParams[1] 
    Local cEndDate := aParams[2] 
    Local cClients := aParams[3] 
    Local cLoja := aParams[4] 
    Local cCurCode := aParams[5] 
    Local cFilFrom := aParams[6] 
    Local cFilTo   := aParams[7] 
    Local cDb := "'PA'" // Debit doc typec
    Local cCr := "'NF'" // Credit foc types
    //Local cHomeCur := '1' // code for home/local currency
    

    // Step 1: get  data
    cSql := " insert into " + cTable + " ("
    cSql += " A1_FILIAL," //Fillial
    cSql += " A1_COD," //Supplier’s code
    cSql += " A1_LOJA," //Supplier’s unit
    cSql += " A1_NOME," //Supplier’s name
    cSql += " E1_F5QCODE,"//Contract code
    cSql += " F5Q_DESCR," //Contract description
    cSql += " E1_NATUREZ," //Class
    cSql += " ED_DESCRIC," //Class description
    cSql += " E1_PREFIXO," //AR prefix
    cSql += " E1_NUM," //AR number
    cSql += " E1_PARCELA," //AP installment
    cSql += " E1_EMISSAO," //AR issue date
    cSql += " E1_TIPO," //AR type
    cSql += " E1_MOEDA," //Currency code
    cSql += " CTO_SIMB," //Currency name
    cSql += " E1_CONUNI," //Conventional units
    cSql += " FK7_IDDOC," //Link to FK1
    cSql += " SALDOI_DD," // in Doc currency
    cSql += " SALDOI_CD," 
    cSql += " SALDOI_SD," 
    cSql += " TURNOV_DD," 
    cSql += " TURNOV_CD," 
    cSql += " SALDOF_DD," 
    cSql += " SALDOF_CD," 
    cSql += " SALDOF_SD," 
    cSql += " SALDOI_DH," // in Home currency
    cSql += " SALDOI_CH," 
    cSql += " SALDOI_SH," 
    cSql += " TURNOV_DH," 
    cSql += " TURNOV_CH," 
    cSql += " SALDOF_DH," 
    cSql += " SALDOF_CH," 
    cSql += " SALDOF_SH" 
    cSql += " ) "
    cSql += " select "
        cSql += " E2_FILIAL," //Fillial
        cSql += " A2_COD," //Supplier’s code
        cSql += " A2_LOJA," //Supplier’s unit
        cSql += " A2_NOME ," //Supplier’s name
        cSql += " E2_F5QCODE,"//Contract code
        cSql += " Coalesce(F5Q_DESCR,'')," //Contract description
        cSql += " E2_NATUREZ," //Class
        cSql += " Coalesce(ED_DESCRIC,'')," //Class description
        cSql += " E2_PREFIXO," //AR prefix
        cSql += " E2_NUM," //AR number
        cSql += " E2_PARCELA," //AP installment
        cSql += " E2_EMISSAO," //AR issue date
        cSql += " E2_TIPO," //AR type
        cSql += " E2_MOEDA," //Currency
        cSql += " CTO_SIMB," //Currency name
        cSql += " Case when E2_CONUNI = '1' then 'X' else '' end," //Conventional units as flag
        cSql += " Coalesce(FK7_IDDOC,'')," //Link to FK1
        // opening balance in Doc Curr
        cSql += " coalesce(case when E2_EMISSAO < '"+cStartDate+"' and E2_TIPO in ("+cDb+") then E2_VALOR - coalesce(INITIAL,0) else 0 end,0) as SALDOI_DD," 
        cSql += " coalesce(case when E2_EMISSAO < '"+cStartDate+"' and E2_TIPO in ("+cCr+") then E2_VALOR - coalesce(INITIAL,0) else 0 end,0) as SALDOI_CD," 
        cSql += " coalesce(case when E2_EMISSAO < '"+cStartDate+"' then (case when E2_TIPO in ("+cDb+") then E2_VALOR - coalesce(INITIAL,0)  "
        cSql += "                                                                                 else -1 * (E2_VALOR - coalesce(INITIAL,0)) end) end,0) as SALDOI_SD," 
        // turnover in Doc Curr
        cSql += " coalesce(case when E2_TIPO in ("+cDb+") then (case when E2_EMISSAO >= '"+cStartDate+"' and E2_EMISSAO <= '"+cEndDate+"' then E2_VALOR else 0 END) else TURNOVER end,0) as TURNOV_DD," 
        cSql += " coalesce(case when E2_TIPO in ("+cCr+") then (case when E2_EMISSAO >= '"+cStartDate+"' and E2_EMISSAO <= '"+cEndDate+"' then E2_VALOR else 0 END) else TURNOVER end,0) as TURNOV_CD," 
        // closing balance in Doc Curr
        cSql += " coalesce(case when E2_TIPO in ("+cDb+") then E2_VALOR - coalesce(FINAL,0) else 0 end,0) as SALDOF_DD," 
        cSql += " coalesce(case when E2_TIPO in ("+cCr+") then E2_VALOR - coalesce(FINAL,0) else 0 end,0) as SALDOF_CD," 
        cSql += " coalesce(case when E2_TIPO in ("+cDb+") then (E2_VALOR - coalesce(FINAL,0)) else -1 * (E2_VALOR - coalesce(FINAL,0)) end,0) as SALDOF_SD," 
        // postings in Home currencies calculated below have Currency rate differences added as FR_VAL_*
        // opening balance in Home Curr
        cSql += " coalesce(case when E2_EMISSAO < '"+cStartDate+"' and E2_TIPO in ("+cDb+") then E2_VLCRUZ - coalesce(INITIAL_H,0) else 0 end,0) 
        cSql += " + (case when coalesce(FR_VAL_I,0) < 0 then Abs(coalesce(FR_VAL_I,0)) else 0 end)"
        cSql += " as SALDOI_DH," 
        cSql += " coalesce(case when E2_EMISSAO < '"+cStartDate+"' and E2_TIPO in ("+cCr+") then E2_VLCRUZ - coalesce(INITIAL_H,0) else 0 end,0) "
        cSql += " + (case when coalesce(FR_VAL_I,0) > 0 then coalesce(FR_VAL_I,0) else 0 end)"
        cSql += " as SALDOI_CH," 
        cSql += " coalesce(case when E2_EMISSAO < '"+cStartDate+"' then (case when E2_TIPO in ("+cDb+") then (E2_VLCRUZ - coalesce(INITIAL_H,0) ) 
        cSql += "                                                                                  else -1 * (E2_VLCRUZ - coalesce(INITIAL_H,0))  end) end,0) - coalesce(FR_VAL_I,0)"
        cSql += " as SALDOI_SH," 
        // turnover in Home Curr
        cSql += " coalesce(case when E2_TIPO in ("+cDb+") then (case when E2_EMISSAO >= '"+cStartDate+"' and E2_EMISSAO <= '"+cEndDate+"' then E2_VLCRUZ else 0 END) else TURNOVER_H end,0)"
        cSql += " + (case when coalesce(FR_VAL_T,0) > 0 then  coalesce(FR_VAL_T,0) else 0 end)"
        cSql += " as TURNOV_DH," 
        cSql += " coalesce(case when E2_TIPO in ("+cCr+") then (case when E2_EMISSAO >= '"+cStartDate+"' and E2_EMISSAO <= '"+cEndDate+"' then E2_VLCRUZ else 0 END) else TURNOVER_H end,0)"
        cSql += " + (case when coalesce(FR_VAL_T,0) < 0 then Abs( coalesce(FR_VAL_T,0)) else 0 end)"
        cSql += " as TURNOV_CH," 
        // closing balance in Home Curr
        cSql += " coalesce(case when E2_TIPO in ("+cDb+") then E2_VLCRUZ - coalesce(FINAL_H,0) else 0 end,0)  
        cSql += " - (case when coalesce(FR_VAL_F,0) < 0 then Abs(coalesce(FR_VAL_F,0)) else 0 end)"
        cSql += " as SALDOF_DH,"
        cSql += " coalesce(case when E2_TIPO in ("+cCr+") then E2_VLCRUZ - coalesce(FINAL_H,0) else 0 end,0)"
        cSql += " - (case when coalesce(FR_VAL_F,0) > 0 then coalesce(FR_VAL_F,0) else 0 end)"
        cSql += " as SALDOF_CH," 
        cSql += " coalesce(case when E2_TIPO in ("+cDb+") then (E2_VLCRUZ - coalesce(FINAL_H,0))"
        cSql += "                                    else -1 * (E2_VLCRUZ - coalesce(FINAL_H,0)) end,0)"
        cSql += " - coalesce(FR_VAL_F,0)"
        cSql += " as SALDOF_SH" 
        //
		csql += " from "+RetSqlName("SE2")+" SE2 "
        csql += " join "+RetSqlName("SA2")+" SA2 on A2_COD = E2_FORNECE and A2_LOJA = E2_LOJA "
        cSql += " left outer join "+RetSqlName("F5Q")+" F5Q on E2_F5QUID = F5Q_UID and E2_FILIAL = F5Q_FILIAL and F5Q.D_E_L_E_T_ = '' " 
        cSql += " left outer join "+RetSqlName("SED")+" SED on ED_CODIGO = E2_NATUREZ and SED.D_E_L_E_T_ = '' " 
        cSql += " left outer join "+RetSqlName("FK7")+" FK7 on fk7.FK7_CHAVE = rpad(E2_FILIAL,6,' ') ||'|'|| rpad(E2_PREFIXO,3,' ') ||'|'|| rpad(E2_NUM,8,' ') ||'|'|| rpad(E2_PARCELA,2,' ')||'|'|| rpad(E2_TIPO,3,' ') ||'|'|| rpad(E2_FORNECE,6,' ')||'|'||rpad(E2_LOJA, 2, ' ') and fk7.d_e_l_e_t_ = ''"                   
        cSql += " left outer join "+RetSqlName("CTO")+" CTO on CTO_MOEDA::INTEGER = E2_MOEDA and (CTO_FILIAL = E2_FILIAL or CTO_FILIAL = '')"
        //
        cSql += " 	left outer join ("
        cSql += " 		select "
        cSql += " 		FK2_IDDOC, "
        // sums in document currency
        cSql += " 		sum(FK2_VALOR * (case when FK2_TPDOC = 'ES' then -1 else 1 end) * ( case when FK2_DATA < '"+cStartDate+"' then 1 else 0  end) ) as INITIAL, "
        cSql += " 		sum(FK2_VALOR * (case when FK2_TPDOC = 'ES' then -1 else 1 end) * ( case when FK2_DATA >= '"+cStartDate+"' and FK2_DATA <= '"+cEndDate+"'then 1 else 0  end) ) as TURNOVER, "
        cSql += " 		sum(FK2_VALOR * (case when FK2_TPDOC = 'ES' then -1 else 1 end) * ( case when FK2_DATA <= '"+cEndDate+"'then 1 else 0  end) ) as FINAL, "
        // sums in home  currency
        cSql += " 		sum(FK2_VLMOE2 * (case when FK2_TPDOC = 'ES' then -1 else 1 end) * ( case when FK2_DATA < '"+cStartDate+"' then 1 else 0  end) ) as INITIAL_H, "
        cSql += " 		sum(FK2_VLMOE2 * (case when FK2_TPDOC = 'ES' then -1 else 1 end) * ( case when FK2_DATA >= '"+cStartDate+"' and FK2_DATA <= '"+cEndDate+"'then 1 else 0  end) ) as TURNOVER_H, "
        cSql += " 		sum(FK2_VLMOE2 * (case when FK2_TPDOC = 'ES' then -1 else 1 end) * ( case when FK2_DATA <= '"+cEndDate+"'then 1 else 0  end) ) as FINAL_H "
        cSql += " 		from " + RetSqlName("FK2") + " F"
        cSql += " 		where FK2_DATA <= '"+cEndDate+"'"
        cSql += " 		and d_e_l_e_t_ = '' "
        cSql += " 		group by FK2_IDDOC"
        cSql += " 	) as P on p.FK2_IDDOC = fk7.FK7_IDDOC"
        // foreign / document currency rate differnces in home currency (if any)
        cSql += " 	left outer join ("
        cSql += " 	select "
        cSql += " 	    sum(case when FR_DATADI < '"+cStartDate+"' then FR_VALOR else 0 end) as FR_VAL_I, " // for opening banance
        cSql += " 	    sum(case when FR_DATADI >= '"+cStartDate+"' and FR_DATADI <= '"+cEndDate+"' then FR_VALOR else 0 end) as FR_VAL_T, " // for turnover
        cSql += " 	    sum(case when FR_DATADI < '"+cEndDate+"' then FR_VALOR else 0 end) as FR_VAL_F, " // for closing balance
        cSql += " 	    FR_CHAVOR, FR_FILIAL from "+RetSqlName("SFR")+" s where FR_DATADI < '"+cEndDate+"' and  s.d_e_l_e_t_ = '' group by FR_CHAVOR, FR_FILIAL) as SF "
        cSql += " 	on FR_CHAVOR = rpad(SE2.E2_PREFIXO,3,' ') || rpad(SE2.E2_NUM,8,' ') || rpad(SE2.E2_PARCELA,2,' ') ||"
        cSql += " 				   rpad(SE2.E2_TIPO,3,' ') || rpad(SE2.E2_FORNECE,6,' ') || rpad(SE2.E2_LOJA,2,' ') "
        cSql += " 	and SE2.E2_FILIAL =  SF.FR_FILIAL "
        //
        cSql += " where ( E2_TIPO in ("+cDb+") or E2_TIPO in ("+cCR+") )"
        cSql += " and E2_EMISSAO <= '"+cEndDate+"'"
        cSql += " and SE2.D_E_L_E_T_ = ''"
        cSql += " " + AddSqlParam( "E2_FORNECE", "=", cClients )
        cSql += " " + AddSqlParam( "E2_LOJA", "=", cLoja )
        cSql += " " + AddSqlParam( "E2_FILIAL", ">=", cFilFrom )
        cSql += " " + AddSqlParam( "E2_FILIAL", "<=", cFilTo )
        cSql += " " + AddSqlParam( "E2_MOEDA", "=", cCurCode )

    If TCSQLEXEC(cSql) < 0
        conout( "Error at MainQuery 1 >" + TCSQLError(), 'MA-3' )
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
 that fills an ar                                                                                                                       ray for creation of the temporary DB table, checking if the custom field is activated
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


/*/{Protheus.doc} FormatDate
   formats date from date to russian print standart dd.mm.yyyy
   @author Maxim Popenker
   @since  13/02/2023
   @type
   @version 1.0
/*/
static function FormatDate(cData)
   local cFData as character

   cFData := Substr(alltrim(cData), 7, 2) + "." +  Substr(alltrim(cData), 5, 2) + "." + Substr(alltrim(cData), 1, 4)

Return cFData

/*/{Protheus.doc} MyParamBox
   reads parameters instead of the pergunte
   @author Maxim Popenker
   @since  13/02/2023
   @type
   @version 1.0
/*/
static function MyParamBox()
   local aParamBox := {}
   local aRet := {} 
   local lRes

    //aAdd(aParamBox,{1,"Date from" ,FirstDate(Date()),"","","","",60,.T.})
    //aAdd(aParamBox,{1,"Date to" ,LastDate(Date()),"","","","",60,.T.})
    aAdd(aParamBox,{1,STR0050,StoD("        "),"","","","",60,.T.})
    aAdd(aParamBox,{1,STR0051,StoD("        "),"","","","",60,.T.})
    aAdd(aParamBox,{1,STR0052,Space(6),"","","SA2","",6,.F.}) 
    aAdd(aParamBox,{1,STR0053,Space(2),"","","SA2","",2,.F.}) 
    aAdd(aParamBox,{1,STR0054,"  ","","","CTO","",2,.F.}) //
    aAdd(aParamBox,{1,STR0055,Space(6),"","","XM0","",6,.F.}) //
    aAdd(aParamBox,{1,STR0056,Space(6),"","","XM0","",6,.F.}) //

    lRes := ParamBox(aParamBox,"Test Parameters...",@aRet)

Return lRes


                   
//Merge Russia R14 
                   
