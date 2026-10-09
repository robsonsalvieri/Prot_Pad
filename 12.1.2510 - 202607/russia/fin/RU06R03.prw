#INCLUDE 'protheus.ch'
#INCLUDE 'fwmvcdef.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'ru06r03.ch'

#DEFINE DELETEFILE .F.
#DEFINE FIELDNAME 1
#DEFINE FIELDDESC 2
#DEFINE FIELDTYPE 3
#DEFINE FIELDVISIBLE 4
#DEFINE TYPEFORMAT 5
#DEFINE DECIMAFORMAT 6
#DEFINE DEFAULTPARVAL '*'

/*/{Protheus.doc} RU06R0301
    Customer overdue debt report
    @type  Function
    @author Maxim Popenker
    @since 05/12/2023
    @version 1.0
    @example
    (examples)
    @see https://jiraproducao.totvs.com.br/browse/RULOC-5763
    /*/
Function RU06R0301()
    While MainReport()

    Enddo
Return

/*/{Protheus.doc} MainReport
    Customer overdue debt report
    @type  Function
    @author Maxim Popenker
    @since 05/12/2023
    @version 1.0
    @example
    (examples)
    @see 
/*/
Static Function MainReport
    Local cFile := Lower(CriaTrab(NIL, .F.))
    Local nHandle       
    Local oJson := JsonObject():New()
    Local cContrlKey := 'F'+StrZero(Randomize( 1, 999999 ),6)
    Local lRecall := .F.
    local aParams := {} // selection parameters
    local cTable1 := ""

    If MyParamBox() // if Selection parameters were completed with OK

        oJson['controlKey']  := cContrlKey
        oJson['files']    := {'SECTION1'}
        oJson['mv_par01']    := dtos(mv_par01) //Report date
        oJson['mv_par02']    := Alltrim(mv_par02) //Customer code from
        oJson['mv_par03']    := Alltrim(mv_par03) //Customer unit from / dummy
        oJson['mv_par04']    := Alltrim(mv_par04) //Customer code to
        oJson['mv_par05']    := Alltrim(mv_par05) //Customer unit to / dummy
        oJson['mv_par06']    := mv_par06 // curr code
        oJson['mv_par07']    := Alltrim(mv_par07) //Filial from 
        oJson['mv_par08']    := Alltrim(mv_par08) //Filial to 



        // pass parameters for data selection 
        AddMvParam(aParams, dtos(mv_par01)) //date          

        AddMvParam(aParams, Alltrim(mv_par02)) //Customer code (e1_cliente)  from     
        AddMvParam(aParams, Alltrim(mv_par03)) //Customer unit (e1_cliente)  from     
        AddMvParam(aParams, Alltrim(mv_par04)) //Customer code (e1_cliente)  to      
        AddMvParam(aParams, Alltrim(mv_par05)) //Customer unit (e1_cliente)  to
        
        AddMvParam(aParams, mv_par06) // currency code  

        AddMvParam(aParams, Alltrim(mv_par07)) //Filial from       
        AddMvParam(aParams, Alltrim(mv_par08)) //Filial to

        //Create report data, insert into the temporary DB table and then pass to angular via the file at the server
        cTable1 := 'SECTION1' + "_" + cContrlKey
        FwMsgRun(,{|oSay| MainDataCreate(aParams,cTable1)},'',STR0038) 

        nHandle := FCREATE(cFile+".dxparam", 0)
        FWRITE(nHandle, oJson:toJSon())
        FCLOSE(nHandle) 

        //invoke Angular grid engine
        lRecall := RU99X1203_DATAGRID3('RU06R0302','RU06R0303',cFile, DELETEFILE)
    
        //Delete temporary file
        STATICCALL(RU99X13_DXMODELS,CleanFiles,cFile)  

    Endif

Return lRecall


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

    fill_db_field(@aStru1,"FK7_IDDOC") //non-display field to link to FK1
    fill_db_field(@aStru1,"A1_FILIAL") //Fillial
    fill_db_field(@aStru1,"A1_NOME ") //Customer's name
    fill_db_field(@aStru1,"A1_COD") //Customer's code
    fill_db_field(@aStru1,"A1_LOJA") //Customer's unit
    fill_db_field(@aStru1,"E1_F5QCODE")//Contract code
    fill_db_field(@aStru1,"F5Q_DESCR") //Contract description
    fill_db_field(@aStru1,"E1_PREFIXO") //AR prefix
    fill_db_field(@aStru1,"E1_NUM") //AR number
    fill_db_field(@aStru1,"E1_PARCELA") //AP installment
    fill_db_field(@aStru1,"E1_EMISSAO") //AR issue date
    fill_db_field(@aStru1,"E1_TIPO") //AR type
    fill_db_field(@aStru1,"E1_MOEDA") //Currency code
    fill_db_field(@aStru1,"CTO_SIMB") //Currency - short name
    
    //total Debt
    fill_ndb_field(@aStru1,"TOTDEB_D",13,2) //Total debt - doc curr
    fill_ndb_field(@aStru1,"TOTDEB_R",13,2) //Total debt - rub
    //overdue debt
    fill_ndb_field(@aStru1,"OVDDEB_D",13,2) //Overdue debt - doc curr
    fill_ndb_field(@aStru1,"OVDDEB_R",13,2) //Overdue debt - rub
    fill_db_field(@aStru1,"E1_VENCTO") //Planed pay date
    fill_ndb_field(@aStru1,"OVDDAYS",6,0) //Days overdue
    //overdue debt per duration
    fill_ndb_field(@aStru1,"OVD45_D",13,2) //Overdue debt less than 45 days old - doc curr
    fill_ndb_field(@aStru1,"OVD45_R",13,2) //Overdue debt less than 45 days old - rub
    fill_ndb_field(@aStru1,"OVD90_D",13,2) //Overdue debt 45-90 days old - doc curr
    fill_ndb_field(@aStru1,"OVD90_R",13,2) //Overdue debt 45-90 days old - rub
    fill_ndb_field(@aStru1,"OVD9P_D",13,2) //Overdue debt 91+ days old - doc curr
    fill_ndb_field(@aStru1,"OVD9P_R",13,2) //Overdue debt 91+ days old - rub

    fill_ndb_field(@aStru1,"RESERVE_R",13,2) //Reserve amount - rub
    fill_ndb_field(@aStru1,"RATE",13,2) //Exchange rate 

    TCInternal(30, 'AUTORECNO')

    DbCreate(cTableName,aStru1,"TOPCONN")
    TCInternal(30, 'OFF')
    
    //Create and populate the main query with all data 
    FwMsgRun(,{|oSay|LoadData(cTableName,aPar)},'',STR0038) 

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
    Local cSql       := ''
    Local cStartDate := aParams[1] 
    Local cClientsFr := aParams[2] 
    Local cClientsTo := aParams[4] 
    Local cCurCode   := aParams[6] 
    Local cFilFrom   := aParams[7] 
    Local cFilTo     := aParams[8] 
    Local cDocTyp    := "'NF'" // Credit foc types
    

    // Step 1: get  data
    cSql := " insert into " + cTable + " ("
    cSql += " A1_FILIAL," //Fillial
    cSql += " A1_NOME," //Customer's name
    cSql += " A1_COD," //Customer's code
    cSql += " A1_LOJA," //Customer's unit
    cSql += " E1_F5QCODE,"//Contract code
    cSql += " F5Q_DESCR," //Contract description
    cSql += " E1_PREFIXO,"
    cSql += " E1_NUM," //AR number
    cSql += " E1_PARCELA," //AP installment
    cSql += " E1_EMISSAO," //AR issue date
    cSql += " E1_TIPO," //AR type
    cSql += " E1_MOEDA," //Currency code
    cSql += " CTO_SIMB," //Currency name/
    cSql += " E1_VENCTO,"  
    cSql += " TOTDEB_D,"
    cSql += " OVDDAYS," 
    cSql += " RATE" 
    cSql += " ) "
    cSql += " select "
        cSql += " E1_FILIAL," //Fillial
        cSql += " A1_NOME ," //Customer's name
        cSql += " A1_COD," //Customer's code
        cSql += " A1_LOJA," //Customer's unit
        cSql += " E1_F5QCODE,"//Contract code
        cSql += " Coalesce(F5Q_DESCR,'')," //Contract description
        cSql += " E1_PREFIXO,"
        cSql += " E1_NUM," //AR number
        cSql += " E1_PARCELA," //AP installment
        cSql += " E1_EMISSAO," //AR issue date
        cSql += " E1_TIPO," //AR type
        cSql += " E1_MOEDA," //Currency
        cSql += " CTO_SIMB," //Currency name/
        cSql += " E1_VENCTO,"  
        //total Debt
        cSql += " E1_VALOR - coalesce(MOVT,0) + coalesce(FR_VAL_I,0) as TOTDEB_D, "
        cSql += " '"+cStartDate+"'::date - E1_VENCTO::date as OVDDAYS, "
        cSql += " coalesce(case when E1_MOEDA = 1 then 1 when E1_MOEDA = 2 then m2_moeda2 when E1_MOEDA = 3 then m2_moeda3 when E1_MOEDA = 4 then m2_moeda4 when E1_MOEDA = 5 then m2_moeda5 end,0) as RATE"
        //
		csql += " from "+RetSqlName("SE1")+" SE1 "
        csql += " join "+RetSqlName("SA1")+" SA1 on A1_COD = E1_CLIENTE and A1_LOJA = E1_LOJA "
        cSql += " left outer join "+RetSqlName("F5Q")+" F5Q on E1_F5QUID = F5Q_UID and E1_FILIAL = F5Q_FILIAL and F5Q.D_E_L_E_T_ = '' " 
        cSql += " left outer join "+RetSqlName("FK7")+" FK7 on fk7.FK7_CHAVE = rpad(E1_FILIAL,6,' ') ||'|'|| rpad(E1_PREFIXO,3,' ') ||'|'|| rpad(E1_NUM,8,' ') ||'|'|| rpad(E1_PARCELA,2,' ')||'|'|| rpad(E1_TIPO,3,' ') ||'|'|| rpad(E1_CLIENTE,6,' ')||'|'||rpad(E1_LOJA, 2, ' ') and fk7.d_e_l_e_t_ = ''"                   
        cSql += " left outer join "+RetSqlName("CTO")+" CTO on CTO_MOEDA::INTEGER = E1_MOEDA and (CTO_FILIAL = E1_FILIAL or CTO_FILIAL = '')"
        cSql += " left outer join "+RetSqlName("SM2")+" SM2 on m2_data =  '"+cStartDate+"'"
        //
        cSql += " 	left outer join ("
        cSql += " 		select "
        cSql += " 		FK1_IDDOC, "
        // sums in document currency
        cSql += " 		sum(FK1_VALOR * (case when FK1_TPDOC = 'ES' then -1 else 1 end)  ) as MOVT, "
        // sums in home  currency
        cSql += " 		sum(FK1_VLMOE2 * (case when FK1_TPDOC = 'ES' then -1 else 1 end)  ) as MOVT_H "
        cSql += " 		from " + RetSqlName("FK1") + " F"
        cSql += " 		where FK1_DATA <= '"+cStartDate+"'"
        cSql += " 		and d_e_l_e_t_ = '' "
        cSql += " 		group by FK1_IDDOC"
        cSql += " 	) as P on p.FK1_IDDOC = fk7.FK7_IDDOC"
        // foreign / document currency rate differnces in home currency (if any)
        cSql += " 	left outer join ("
        cSql += " 	select "
        cSql += " 	    sum(FR_VALOR) as FR_VAL_I, " // for opening banance
        cSql += " 	    FR_CHAVOR, FR_FILIAL from "+RetSqlName("SFR")+" s where FR_DATADI < '"+cStartDate+"' and  s.d_e_l_e_t_ = '' group by FR_CHAVOR, FR_FILIAL) as SF "
        cSql += " 	on FR_CHAVOR = rpad(SE1.E1_PREFIXO,3,' ') || rpad(SE1.E1_NUM,8,' ') || rpad(SE1.E1_PARCELA,2,' ') ||"
        cSql += " 				   rpad(SE1.E1_TIPO,3,' ') || rpad(SE1.E1_CLIENTE,6,' ') || rpad(SE1.E1_LOJA,2,' ') "
        cSql += " 	and SE1.E1_FILIAL =  SF.FR_FILIAL "
        //
        cSql += " where E1_TIPO = "+cDocTyp+" "
        cSql += " and E1_EMISSAO <= '"+cStartDate+"'"
        cSql += " and SE1.D_E_L_E_T_ = ''"
        cSql += " " + AddSqlParam( "E1_CLIENTE", ">=", cClientsFr )
        cSql += " " + AddSqlParam( "E1_CLIENTE", "<=", cClientsTo )
        cSql += " " + AddSqlParam( "E1_FILIAL", ">=", cFilFrom )
        cSql += " " + AddSqlParam( "E1_FILIAL", "<=", cFilTo )
        cSql += " " + AddSqlParam( "E1_MOEDA", "=", cCurCode )

    If TCSQLEXEC(cSql) < 0
        conout( "Error at MainQuery 1 >" + TCSQLError(), 'MA-3' )
    Endif

    //calculate debt in RUB using current rate (=1 if doc currency is RUB)
    cSql := " update " + cTable + " set "
    cSql += " TOTDEB_R = TOTDEB_D * RATE," 
    cSql += " OVDDAYS = case when OVDDAYS > 0 then OVDDAYS else 0 end"

    If TCSQLEXEC(cSql) < 0
        conout( "Error at MainQuery 2 >" + TCSQLError(), 'MA-3' )
    Endif

    //distribute overdue debt depending on its age
    cSql := " update " + cTable + " set "
    cSql += " OVDDEB_D = case when OVDDAYS > 0 then TOTDEB_D else 0 end,"
    cSql += " OVDDEB_R = case when OVDDAYS > 0 then TOTDEB_R else 0 end,"
    cSql += " OVD45_D = case when OVDDAYS > 0 and OVDDAYS < 45 then TOTDEB_D else 0 end,"
    cSql += " OVD45_R = case when OVDDAYS > 0 and OVDDAYS < 45 then TOTDEB_R else 0 end,"
    cSql += " OVD90_D = case when OVDDAYS >= 45 and OVDDAYS <= 90 then TOTDEB_D else 0 end,"
    cSql += " OVD90_R = case when OVDDAYS >= 45 and OVDDAYS <= 90 then TOTDEB_R else 0 end,"
    cSql += " OVD9P_D = case when OVDDAYS > 90 then TOTDEB_D else 0 end,"
    cSql += " OVD9P_R = case when OVDDAYS > 90 then TOTDEB_R else 0 end"

    If TCSQLEXEC(cSql) < 0
        conout( "Error at MainQuery 3 >" + TCSQLError(), 'MA-3' )
    Endif


    cSql := " update " + cTable + " set RESERVE_R = OVD90_R * 0.5 + OVD9P_R"

    If TCSQLEXEC(cSql) < 0
        conout( "Error at MainQuery 4 >" + TCSQLError(), 'MA-3' )
    Endif
Return



//--------------------------------------------------------------------
/*/{Protheus.doc} RU06R0302
create the Angular report JSON structure
@author Maxim Popenker
@since  13/02/2023
@type
@param cKey, Char, key
@version 1.0
/*/
 Function RU06R0302(cKey)
    Local oMainGrid := GetDxModel('main')
    Local oSummary := GetDxModel('summary')
    Local aFields := {}	
    Local aTmp1 := {}	
    Local aTmp2 := {}	
    Local aTmp3 := {}	
    Local aTotal := {}	
    Local aOverdue := {}
    Local aOverdueTm := {}	
    Local oParamJson := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey) 
    Local cStartDate := oParamJson['mv_par01']
    Local oDD := GetDxModel('drillDownLink')

    // Grid configuration parameters
    oMainGrid['columnResizingMode'] 	:= 'widget'
    oMainGrid['columnFixing']['enabled'] 	:= .T.
    oMainGrid['scrolling'] := '{}'
    oMainGrid['stateStoring']['enabled'] := .T.
    oMainGrid['stateStoring']['storageKey'] := 'RU06R03' //+ RetCodUsr()

    //Column definition for the main grid
    aadd(aTmp1,"")
    Aadd(aTmp1,{"A1_FILIAL", STR0030,"string",.T.}) //Fillial
    Aadd(aTmp1,{"A1_NOME", STR0010,"string",.T.}) //Customer's name
    Aadd(aTmp1,{"A1_COD", STR0011,"string",.T.}) //Customer's code
    Aadd(aTmp1,{"A1_LOJA", STR0032,"string",.T.}) //Customer's unit
    Aadd(aTmp1,{"E1_F5QCODE", STR0012,"string",.T.})//Contract code
    Aadd(aTmp1,{"F5Q_DESCR", STR0013,"string",.T.}) //Contract description
    Aadd(aTmp1,{"E1_NUM", STR0014,"string",.T.}) //AR number
    Aadd(aTmp1,{"E1_PARCELA", STR0015,"string",.T.}) //AP installment
    Aadd(aTmp1,{"E1_EMISSAO", STR0031,"date",.T.}) //AR issue date
    Aadd(aTmp1,{"E1_TIPO", STR0016,"string",.T.}) //AR type
    Aadd(aTmp1,{"E1_MOEDA", STR0033,"string",.T.}) //Currency
    Aadd(aTmp1,{"CTO_SIMB", STR0033,"string",.T.}) //Currency
    Aadd(aFields,aTmp1)
    
    //total Debt
    aadd(aTotal,STR0035)
    Aadd(aTotal,{"TOTDEB_D", STR0017,"number",.T.,'fixedPoint',2}) //Total debt - doc curr
    Aadd(aTotal,{"TOTDEB_R", STR0018,"number",.T.,'fixedPoint',2}) //Total debt - rub
    Aadd(aFields,aTotal)
    
    //overdue debt
    aadd(aOverdue,STR0036)
    Aadd(aOverdue,{"OVDDEB_D", STR0019,"number",.T.,'fixedPoint',2}) //Overdue debt - doc curr
    Aadd(aOverdue,{"OVDDEB_R", STR0020,"number",.T.,'fixedPoint',2}) //Overdue debt - rub
    Aadd(aFields,aOverdue)

    aadd(aTmp2,"")
    Aadd(aTmp2,{"E1_VENCTO",  STR0021,"date",.T.}) //Planed pay date
    Aadd(aTmp2,{"OVDDAYS", STR0022,"number",.T.,'fixedPoint',0}) //Days overdue
    Aadd(aFields,aTmp2)
    
    //overdue debt per duration
    aadd(aOverdueTm,STR0037)
    Aadd(aOverdueTm,{"OVD45_D", STR0023,"number",.T.,'fixedPoint',2}) //Overdue debt less than 45 days old - doc curr
    Aadd(aOverdueTm,{"OVD45_R", STR0024,"number",.T.,'fixedPoint',2}) //Overdue debt less than 45 days old - rub
    Aadd(aOverdueTm,{"OVD90_D", STR0025,"number",.T.,'fixedPoint',2}) //Overdue debt 45-90 days old - doc curr
    Aadd(aOverdueTm,{"OVD90_R", STR0026,"number",.T.,'fixedPoint',2}) //Overdue debt 45-90 days old - rub
    Aadd(aOverdueTm,{"OVD9P_D", STR0027,"number",.T.,'fixedPoint',2}) //Overdue debt 91+ days old - doc curr
    Aadd(aOverdueTm,{"OVD9P_R", STR0028,"number",.T.,'fixedPoint',2}) //Overdue debt 91+ days old - rub
    Aadd(aFields,aOverdueTm)

    aadd(aTmp3,"")
    Aadd(aTmp3,{"RESERVE_R", STR0029,"number",.T.,'fixedPoint',2}) //reserve - rub
    Aadd(aTmp3,{"RATE", STR0040,"number",.T.,'fixedPoint',2}) //exchange rate
    Aadd(aFields,aTmp3)

    // create JSON structure from columns array
    FillJsColF(@oMainGrid,aFields)

    // Grouping subtotals
    AddGroups(@oSummary,"TOTDEB_D", STR0017,'sum') //Total debt - doc curr
    AddGroups(@oSummary,"TOTDEB_R", STR0018,'sum') //Total debt - rub
    AddGroups(@oSummary,"OVDDEB_D", STR0019,'sum') //Overdue debt - doc curr
    AddGroups(@oSummary,"OVDDEB_R", STR0020,'sum') //Overdue debt - rub
    AddGroups(@oSummary,"OVD45_D",  STR0023,'sum') //Overdue debt less than 45 days old - doc curr
    AddGroups(@oSummary,"OVD45_R",  STR0024,'sum') //Overdue debt less than 45 days old - rub
    AddGroups(@oSummary,"OVD90_D",  STR0025,'sum') //Overdue debt 45-90 days old - doc curr
    AddGroups(@oSummary,"OVD90_R",  STR0026,'sum') //Overdue debt 45-90 days old - rub
    AddGroups(@oSummary,"OVD9P_D",  STR0027,'sum') //Overdue debt 91+ days old - doc curr
    AddGroups(@oSummary,"OVD9P_R",  STR0028,'sum') //Overdue debt 91+ days old - rub
    AddGroups(@oSummary,"RESERVE_R",STR0029,'sum') //reserve
    // Totals
    AddTotals(@oSummary,"TOTDEB_D", STR0017,'sum') //Total debt - doc curr
    AddTotals(@oSummary,"TOTDEB_R", STR0018,'sum') //Total debt - rub
    AddTotals(@oSummary,"OVDDEB_D", STR0019,'sum') //Overdue debt - doc curr
    AddTotals(@oSummary,"OVDDEB_R", STR0020,'sum') //Overdue debt - rub
    AddTotals(@oSummary,"OVD45_D",  STR0023,'sum') //Overdue debt less than 45 days old - doc curr
    AddTotals(@oSummary,"OVD45_R",  STR0024,'sum') //Overdue debt less than 45 days old - rub
    AddTotals(@oSummary,"OVD90_D",  STR0025,'sum') //Overdue debt 45-90 days old - doc curr
    AddTotals(@oSummary,"OVD90_R",  STR0026,'sum') //Overdue debt 45-90 days old - rub
    AddTotals(@oSummary,"OVD9P_D",  STR0027,'sum') //Overdue debt 91+ days old - doc curr
    AddTotals(@oSummary,"OVD9P_R",  STR0028,'sum') //Overdue debt 91+ days old - rub
    AddTotals(@oSummary,"RESERVE_R",STR0029,'sum') //reserve

    oMainGrid['summary'] := oSummary

    // Define drilldown relations
    oDD['callerGridId'] 		:= "maingrid"
    oDD['callerGridColumn']	:= "*"
    oDD['drillDownGridId'] 	:= "DD"

    // fill complete JSON data
    cRet :=  '{"data": { "sections": ['+;
                                        '{"dxDataGridSetup": '+oMainGrid:toJSon()+", "+;
                                        ' "title": "'+STR0034+'",'+;
                                        ' "code": "maingrid",'+;
                                        ' "section": 0,'+;
                                        ' "file": "SECTION1"}'+;
                                        '],'
   //  drilldown 
    cRet += '"drillDowns": ['+;
                                       '{'+;
                                       ' "title": "DD title",'+;
                                       ' "code": "DD",'+;
                                       ' "drillDownType": "ADVPL"}'+;
                                       '],'+;
                                       ' "drillDownDefs": [' + oDD:toJSon() + '],'

    cRet +=         ' "sectionsQuantity": 1,'+;
                    ' "showFlatView": false,'+;
                    ' "showRecall": true, '+;
                    ' "mainTitle": "'+STR0034+' '+FormatDate(cStartDate)+'" },'+; // 
            ' "status": "ok",'+;
            ' "ok": "ok",'+;
            ' "statusText": "ok"}'    
  

    FreeObj(oMainGrid)
    FreeObj(oSummary)
    FreeObj(oParamJson)
    FreeObj(oDD)

Return cRet

/*/{Protheus.doc} FillJsColF
 generates Json columns for a table
@author Maxim Popenker
@since  13/02/2023
@param  aFields,  Array,      list of the fields for selected data structure and their properties.
@param  oDataGridOut, Object,      Json grid object
@version 1.0
/*/
static function FillJsColF(oJsonA,aFieldsA)
   local nX, nZ 
   Local oCol 
   Local oColumn
   Local oFormat
   Local oJsonCSS

   For nX:=1 To Len(aFieldsA)
      If valType(aFieldsA[nX]) == "A"
         oColumn := GetDxModel('columns')
         oColumn['columns']   := {}
         oColumn['allowFiltering']   := .F.
         oColumn['allowGrouping']   := .F.
         oColumn['allowHiding']   := .F.
         oColumn['allowSearch']   := .F.
         oColumn['showWhenGrouped']   := .T.
         oColumn['caption'] := aFieldsA[nX,1]
         For nZ := 2 To Len(aFieldsA[nX])
            oCol := GetDxModel('columns')
            oCol['dataField'] := aFieldsA[nX,nZ][FIELDNAME]
            oCol['caption']   := Alltrim(aFieldsA[nX,nZ][FIELDDESC])
            oCol['dataType']  := aFieldsA[nX,nZ][FIELDTYPE]
            oCol['visible']   := aFieldsA[nX,nZ][FIELDVISIBLE]
            If (aFieldsA[nX,nZ][FIELDTYPE]!="number")
                oCol['allowGrouping']   := .T.
            endif
            If (aFieldsA[nX,nZ][FIELDTYPE]=="number")
               If len(aFieldsA[nX,nZ])>4 .and. !empty(aFieldsA[nX,nZ][TYPEFORMAT])
                  oFormat := JsonObject():New() //Define customized algnment for 
                  //oFormat:FromJson('{ "type": "fixedPoint","precision": 2 }')
                  oFormat['type'] := aFieldsA[nX,nZ][TYPEFORMAT]
                  if !Empty(aFieldsA[nX,nZ][DECIMAFORMAT])
                     oFormat['precision'] := aFieldsA[nX,nZ][DECIMAFORMAT]
                  Endif
                  oCol['format'] := oFormat
                  //FreeObj(oFormat)      
               Endif

               oJsonCSS := JsonObject():New() //Define customized algnment for 
               oJsonCSS:FromJson('{"rowType":"header","settings": [{"cssKey":"text-align","value":"center"}]}')
               oCol['__customCss']:= {}
               aadd(oCol['__customCss'],oJsonCSS)
               FreeObj(oJsonCSS)
            ElseIf (aFieldsA[nX,nZ][FIELDTYPE]=="date")
                  oCol['format'] := "dd.MM.yyyy"
            Endif
            AAdd(oColumn['columns'],oCol)
            FreeObj(oCol)
         Next nZ
      Endif
      AAdd(oJsonA['columns'], oColumn)
      FreeObj(oColumn)
   Next
return

/*/{Protheus.doc} RU06R0303
   drill-down processor from main angular report
   @author Maxim Popenker
   @since  18/10/2023
   @type
   @version 1.0
/*/
function RU06R0303(cColumn, cGridID,cDDownID,cKey,cBody)
    Local oData := JSONOBJECT():NEW()
    Local cRet 
    Local cBodyTmp as Character


    cBodyTmp := DecodeUtf8(cBody)
    If cBodyTmp == Nil
        cBodyTmp := cBody
    Endif
    oData:FROMJSON(cBodyTmp)

    ShowSE1(oData['E1_PREFIXO'],oData['E1_NUM'],oData['E1_PARCELA'],oData['E1_TIPO'],oData['A1_FILIAL'])

    FreeObj(oData)
Return cRet

/*/{Protheus.doc} ShowSE1
   display invoice (SE1) from drill-down
   @author Maxim Popenker
   @since  18/10/2023
   @type
   @version 1.0
/*/
Static function ShowSE1(cPref,cNumE1,cParc,cTip,cFil)

    Local cAliasQry := GetNextAlias()
    Local aSaveArea  as Array
    Local aAreaSE1   as Array
    Local cSaveFil := cfilant
    Private cCadastro

    aSaveArea := GetArea() 
    aAreaSE1 := SE1->(GetArea())

    BeginSql Alias cAliasQry
        SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, SE1.R_E_C_N_O_ SE1RECNO
        FROM %table:SE1% SE1
        WHERE
        E1_FILIAL = %Exp:cFil% AND 
        E1_PREFIXO = %Exp:cPref% AND 
        E1_NUM = %Exp:cNumE1% AND
        E1_PARCELA = %Exp:cParc% AND
        E1_TIPO = %Exp:cTip% AND
        SE1.%notDel%
    EndSql

    (cAliasQry)->(DbGoTop())
    If (cAliasQry)->(!Eof())
        IIF(EMPTY(cCadastro), cCadastro := STR0039, '') // AxVisual will get crit error with empty cCadastro
        DbSelectArea('SE1')
        DbSetOrder(1)
        SE1->(DBGoTop())
        if SE1->(MsSeek(cFil + (cAliasQry)->(E1_PREFIXO) + (cAliasQry)->(E1_NUM) + (cAliasQry)->(E1_PARCELA) + (cAliasQry)->(E1_TIPO)))
            cfilant:=cfil
            AxVisual('SE1', (cAliasQry)->(SE1RECNO), 2)
            cfilant:=cSaveFil
        endif
        (cAliasQry)->(DbCloseArea())
    Else
        MsgAlert(STR0036, STR0037) // Error, Record not found
    Endif

    RestArea(aAreaSE1)  
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
 

/*/{Protheus.doc} fill_db_field
fills an array for creation of the temporary DB table based on SX3 data
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

/*/{Protheus.doc} fill_ndb_field
fills an array for creation of the temporary DB table for numeric field
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param  aStruc,  Array,      list of the fields for selected data table  and their properties.
@param  cFieldname, Char,    field name 
@param  nLen, Numeric,    field length 
@param  nDec, Numeric,    number of decimal places
/*/
static function fill_ndb_field(aStruc, cFieldname,nLen,nDec)

    aadd(aStruc,{cFieldname ,'N', nLen, nDec})

Return

/*/{Protheus.doc} fill_ndb_field
fills an array for creation of the temporary DB table for Char field
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param  aStruc,  Array,      list of the fields for selected data table  and their properties.
@param  cFieldname, Char,    field name 
@param  nLen, Numeric,    field length 
/*/
static function fill_zdb_field(aStruc, cFieldname,nLen)

    aadd(aStruc,{cFieldname ,'C', nLen, nDec})

Return

/*/{Protheus.doc} ChckCustFld
     check if a custom field is active in the database
    @author Maxim Popenker
    @since  13/02/2023
    @type
    @version 1.0
    @param cFldname, Char, name of the field
    @return logic, True if the field is active, Flase otherwise

/*/
static function ChckCustFld(cFldname)
    local lActive := .F. 

    IF SD1->(Fieldpos(cFldname)) > 0 //field is active 
        lActive := .T.
    endif

Return lActive

/*/{Protheus.doc} fill_cdb_field
fills an array for creation of the temporary DB table for custom  field                                                                                                                   ray for creation of the temporary DB table, checking if the custom field is activated
@author Maxim Popenker
@since  13/02/2023
@type
@version 1.0
@param  aStruc,  Array,      list of the fields for selected data table  and their properties.
@param  cFieldname, Char,    field name 
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
   get parameters from user instead of the pergunte
   @author Maxim Popenker
   @since  13/02/2023
   @type
   @version 1.0
/*/
static function MyParamBox()
   local aParamBox := {}
   local aRet := {} 
   local lRes := .F.
   Local cLoad := 'RU06R03'+ RetCodUsr()

    aAdd(aParamBox,{1,STR0001,Date(),"","","","",60,.T.}) //1 report date
    BoxParamAdd(@aParamBox,"A1_COD",STR0002,"SA1",.F.) //2 Customer code from
    BoxParamAdd(@aParamBox,"A1_LOJA",STR0003,"SA1",.F.) //3 Customer unit from
    BoxParamAdd(@aParamBox,"A1_COD",STR0004,"SA1",.F.) //4 Customer code to
    BoxParamAdd(@aParamBox,"A1_LOJA",STR0005,"SA1",.F.) //5 Customer unit to
    BoxParamAdd(@aParamBox,"CTO_MOEDA",STR0006,"CTO",.F.) //6 Currency code
    BoxParamAdd(@aParamBox,"A1_FILIAL",STR0007,"XM0",.F.) //7 Filial from
    BoxParamAdd(@aParamBox,"A1_FILIAL",STR0008,"XM0",.F.) //8 Filial to

    lRes := ParamBox(aParamBox,STR0009,@aRet,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/,/*oMainDlg*/,cLoad,.T.,.T.)

Return lRes

/*/{Protheus.doc} BoxParamAdd
   fill parambox item
   @author Maxim Popenker
   @since  13/02/2023
   @type
   @version 1.0
/*/
static function BoxParamAdd(aParamBox,cFldName,cText,cF3,lMandatory)
    local cValid := ''
    if cFldName =  "A1_COD"
        cValid := 'Vazio() .Or. ExistCpo("SA1")' + iif(!Empty(GetSx3Cache(cFldName,"X3_VLDUSER")),' .or. '+GetSx3Cache(cFldName,"X3_VLDUSER"),'')
    elseif cFldName =  "CTO_MOEDA" 
        cValid := 'Vazio() .Or. ExistCpo("CTO")' + iif(!Empty(GetSx3Cache(cFldName,"X3_VLDUSER")),' .or. '+GetSx3Cache(cFldName,"X3_VLDUSER"),'')
    endif
    aAdd(aParamBox,{1,cText,Space(TamSx3(cFldName)[1]),"",cValid,cF3,"",TamSx3(cFldName)[1],lMandatory})
Return
                   
//Merge Russia R14 
                   
