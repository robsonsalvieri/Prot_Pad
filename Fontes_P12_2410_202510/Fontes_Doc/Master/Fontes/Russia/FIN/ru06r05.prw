#INCLUDE 'protheus.ch'
#INCLUDE 'fwmvcdef.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'RU06R05.ch'

#DEFINE DELETEFILE .F.
#DEFINE FIELDNAME 1
#DEFINE FIELDDESC 2
#DEFINE FIELDTYPE 3
#DEFINE FIELDVISIBLE 4
#DEFINE TYPEFORMAT 5
#DEFINE DECIMAFORMAT 6
#DEFINE STRCOLM 4 // columns for String, Numeric has more columns
#DEFINE DEFAULTPARVAL '*'

/*/{Protheus.doc} RU06R0501
    Bank statement report, daily version
    @type  Function
    @author Maxim Popenker
    @since 29/01/2024
    @version 1.0
    @example
    (examples)
    @see https://jiraproducao.totvs.com.br/browse/RULOC-1838
/*/
Function RU06R0501()
    While MainReport()

    Enddo
Return

/*/{Protheus.doc} MainReport
    Bank statement report, daily version
    @type  Function
    @author Maxim Popenker
    @since 29/01/2024
    @version 1.0
    @example
    (examples)
    @see 
/*/
Static Function MainReport
    Local cFile := Lower(CriaTrab(NIL, .F.)  )
    Local nHandle := FCREATE(cFile+".dxparam",0)      
    Local oJson := JsonObject():New()
    Local cContrlKey := 'F'+StrZero(Randomize( 1, 999999 ),9)
    Local lRecall := .F.
    local aParams := {} // selection parameters
    local cTable1 := ""

    If MyParamBox() // if Selection parameters were completed with OK

        oJson['controlKey']  := cContrlKey
        oJson['files']       := {'SECTION1'}
        oJson['mv_par01']    := dtos(mv_par01)      // Date 
        oJson['mv_par02']    := Alltrim(mv_par02)   // vendor code
        oJson['mv_par03']    := mv_par03            // checkbox: detailed storno: T = yes, F = No


        // pass parameters for data selection 
        AddMvParam(aParams, oJson['mv_par01'])        
        AddMvParam(aParams, oJson['mv_par02'])  
        aadd(aParams, mv_par03) 

        //Create report data, insert into the temporary DB table and then pass to angular via the file at the server
        cTable1 := 'SECTION1' + "_" + cContrlKey
        FwMsgRun(,{|oSay| MainDataCreate(aParams,cTable1)},'',STR0004) // STR0004 = wait for process

        FWRITE(nHandle, oJson:toJSon())
        FCLOSE(nHandle) 

        //invoke Angular grid engine
        lRecall := RU99X1203_DATAGRID3('RU06R0502','RU06R0503',cFile, DELETEFILE)
    
        //Delete temporary file
        STATICCALL(RU99X13_DXMODELS,CleanFiles,cFile)  
    Endif

Return lRecall


/*/{Protheus.doc} MainDataCreate
    Create all structures, temporary tables and fill with data
    @author Maxim Popenker
    @since  29/01/2024
    @type
    @version 1.0
    @param aPar, array, list of pergunte parameters
    @param cTableName, Char, name of temporary table
    @return Nil

/*/
Static Function MainDataCreate(aPar,cTableName)
    Local aStru1   := {} //structure for main grid

    fill_db_field(@aStru1,"F4C_BNKORD")	//Number of bank document
    fill_db_field(@aStru1,"F4C_DTPAYM")	//Date of bank document
    fill_db_field(@aStru1,"F4C_DTTRAN")	//Date of bank transaction

    fill_ndb_field(@aStru1,"BALANCE",13,2)  //Opening/Closing balance

    fill_db_field(@aStru1,"F4C_OPER") 	//Operation   : 1=Inflow;2=Outflow  

    fill_db_field(@aStru1,"F4C_PAYTYP")  //Payment type: 1=paymt. to supp.;2=return to cust.;3=budget paymt.;4=paymt to empl.;5=return from supp.;6=paymt from cust.;7=paymt from budget;
    fill_cdb_field(@aStru1,"Z_PAYTYP",50)  //Text for payment type
    fill_db_field(@aStru1,"F4C_SUPP")    //Supplier code
    fill_db_field(@aStru1,"F4C_UNIT")    //Supplier unit
    fill_db_field(@aStru1,"A2_NOME")     //supplier name
    fill_db_field(@aStru1,"F4C_BNKREC")  //Receiving bank
    fill_cdb_field(@aStru1,"F4C_ACRNAM",100)  //Receiver Account Name   
    fill_db_field(@aStru1,"F4C_RECBIK")  //BIK of the correspondent
    fill_db_field(@aStru1,"F4C_RECACC")  //Bank account number of the correspondent
    fill_ndb_field(@aStru1,"OUT_SUM",13,2)  //Outflow payment amount

    fill_db_field(@aStru1,"F4C_RECTYP") //Reciept type: 1=Receive from a customer;2=Return from a supplier                                                                              
    fill_cdb_field(@aStru1,"Z_RECTYP",50)  //Text for receipt type
    fill_db_field(@aStru1,"F4C_CUST")    //Customer code
    fill_db_field(@aStru1,"F4C_CUNI")	//Customer unit 
    fill_db_field(@aStru1,"A1_NOME")    //Customer name
    fill_db_field(@aStru1,"F4C_BNKPAY") 	//Payer bank
    fill_cdb_field(@aStru1,"F4C_ACPNAM",100)	//Payer Account Name    
    fill_db_field(@aStru1,"F4C_PAYBIK")	//BIK of the correspondent
    fill_db_field(@aStru1,"F4C_PAYACC")	//Bank account number of the correspondent
    fill_ndb_field(@aStru1,"IN_SUM",13,2)  //Inflow payment amount

    fill_db_field(@aStru1,"F4C_CLASS")   //Class
    fill_db_field(@aStru1,"FK5_NATURE")	//Class 
    fill_db_field(@aStru1,"F4C_REASON")	//Reason for payment
    fill_db_field(@aStru1,"F4C_INTNUM")  //Bank statement number
    //tech fields for strorno
    fill_db_field(@aStru1,"F4C_DTREVE")  //date of reversal
    fill_db_field(@aStru1,"F4C_CUUID")  //uniq uid to refer from reveral 
    fill_db_field(@aStru1,"F4C_UUIDRE")  //uid of the reversed line

    TCInternal(30, 'AUTORECNO')

    DbCreate(cTableName,aStru1,"TOPCONN")
    TCInternal(30, 'OFF')
    
    //Create and populate the main query with all data 
    FwMsgRun(,{|oSay|LoadData(cTableName,aPar)},'',STR0015) // STR0015 = wait for process

Return

/*/
{Protheus.doc} LoadData, 
 fills primary data table with the results of the report 
@author Maxim Popenker
@since  29/01/2024
@type
@version 1.0
@param cTable, Char, table name
@param aParams, array, list of pergunte parameters
/*/
Static function LoadData(cTable,aParams)
    Local cSql     := ''
    Local cDate := aParams[1] 
    Local cBank := aParams[2] 
    Local lStorno := aParams[3] 
    Local lError := .F.


    //Opening balance
    cSql := " insert into " + cTable + " ("
    cSql += "F4C_DTPAYM,"	//Date of bank document
    cSql += "BALANCE," 	
    cSql += "Z_PAYTYP"  //Text 
    cSql += " ) "
    cSql += " select"
    cSql += " E8_DTSALAT as F4C_DTPAYM, "
    cSql += " E8_SALATUA as BALANCE, "
    cSql += " '"+STR0043+"' as Z_PAYTYP  " // opening balance
    cSql += " from "+RetSqlName("SE8")+" se8 "
    cSql += " where E8_BANCO = '"+cBank+"'"
    cSql += " and E8_FILIAL = '"+xFilial('SE8')+"'"
    cSql += " and E8_DTSALAT = "
    cSql += "   (select max(E8_DTSALAT) from "+RetSqlName("SE8")+" se8a 
    cSql += "    where SE8A.E8_BANCO = '"+cBank+"'and SE8A.E8_FILIAL = '"+xFilial('SE8')+"' and SE8A.E8_DTSALAT < '"+cDate+"')"

    If TCSQLEXEC(cSql) < 0
        conout( "Error at MainQuery 1 >" + TCSQLError(), 'MA-3' )
        lError := .T.
    Endif

    //line items
    if lError == .F.
        cSql := " insert into " + cTable + " ("
        cSql += "F4C_BNKORD,"	//Number of bank document
        cSql += "F4C_DTPAYM,"	//Date of bank document
        cSql += "F4C_DTTRAN,"
        cSql += "F4C_OPER," 	//Operation   : 1=Inflow;2=Outflow  
        cSql += "F4C_PAYTYP,"  //Payment type: 1=paymt. to supp.;2=return to cust.;3=budget paymt.;4=paymt to empl.;5=return from supp.;6=paymt from cust.;7=paymt from budget;
        cSql += "Z_PAYTYP,"  //Text for payment type
        cSql += "F4C_SUPP,"    //Supplier code
        cSql += "F4C_UNIT,"    //Supplier unit
        cSql += "A2_NOME,"    //supplier name
        cSql += "F4C_BNKREC,"  //Receiving bank
        cSql += "F4C_ACRNAM,"  //Receiver Account Name   
        cSql += "F4C_RECBIK,"  //BIK of the correspondent
        cSql += "F4C_RECACC,"  //Bank account number of the correspondent
        cSql += "OUT_SUM,"  //Outflow payment amount
        cSql += "F4C_RECTYP," //Reciept type: 1=Receive from a customer;2=Return from a supplier                                                                              
        cSql += "Z_RECTYP,"  //Text for receipt type
        cSql += "F4C_CUST,"   //Customer code
        cSql += "F4C_CUNI,"	//Customer unit 
        cSql += "A1_NOME,"    //Customer name
        cSql += "F4C_BNKPAY," 	//Payer bank
        cSql += "F4C_ACPNAM,"	//Payer Account Name    
        cSql += "F4C_PAYBIK,"	//BIK of the correspondent
        cSql += "F4C_PAYACC,"	//Bank account number of the correspondent
        cSql += "IN_SUM,"  //Inflow payment amount
        cSql += "F4C_CLASS,"   //Class
        cSql += "FK5_NATURE,"	//Class 
        cSql += "F4C_REASON,"	//Reason for payment
        cSql += "F4C_INTNUM,"  //Bank statement number
        cSql += "F4C_DTREVE,"  //date of reversal
        cSql += "F4C_CUUID,"  //uniq uid to refer from reveral 
        cSql += "F4C_UUIDRE"  //uid of the reversed line
        cSql += " ) "
        cSql += " select"
        cSql += " F4C_BNKORD,"	
        cSql += " F4C_DTPAYM,"	
        cSql += " F4C_DTTRAN,"
        cSql += " F4C_OPER,"                                                                                                             
        cSql += " F4C_PAYTYP," 
        cSql += " case" 
        cSql += " 	when F4C_PAYTYP = '1' then '"+STR0005+"'" 
        cSql += " 	when F4C_PAYTYP = '2' then '"+STR0006+"'" 
        cSql += " 	when F4C_PAYTYP = '3' then '"+STR0007+"'" 
        cSql += " 	when F4C_PAYTYP = '4' then '"+STR0008+"'" 
        cSql += " 	when F4C_PAYTYP = '5' then '"+STR0009+"'" 
        cSql += " 	when F4C_PAYTYP = '6' then '"+STR0010+"'"
        cSql += " 	when F4C_PAYTYP = '7' then '"+STR0011+"'" 
        cSql += " 	else ''" 
        cSql += " end as Z_PAYTYP,"
        cSql += " F4C_SUPP,"   
        cSql += " F4C_UNIT,"   
        cSql += " coalesce(A2_NOME,'') as A2_NOME," 
        cSql += " F4C_BNKREC," 
        cSql += " coalesce(sa61.A6_ACNAME,'') as F4C_ACRNAM," 
        cSql += " F4C_RECBIK," 
        cSql += " F4C_RECACC," 
        cSql += " case when F4C_OPER = '2' then F4C_VALUE * (case when FK5_RECPAG = 'R' then -1 else 1 end) else 0 end as OUT_SUM,"
        //---
        cSql += " F4C_RECTYP," 
        cSql += " case "
        cSql += " 	when F4C_RECTYP = '1' then '"+STR0012+"' "
        cSql += " 	when F4C_RECTYP = '2' then '"+STR0013+"'" 
        cSql += " else ''" 
        cSql += " end as Z_RECTYP,"                                                                              
        cSql += " F4C_CUST,"   
        cSql += " F4C_CUNI,"	   
        cSql += " coalesce(A1_NOME,'') as A1_NOME," 
        cSql += " F4C_BNKPAY," 
        cSql += " coalesce(sa62.A6_ACNAME,'') as F4C_ACPNAM,"	
        cSql += " F4C_PAYBIK,"	
        cSql += " F4C_PAYACC,"	
        cSql += " case when F4C_OPER = '1' then F4C_VALUE * (case when FK5_RECPAG = 'P' then -1 else 1 end) else 0 end as IN_SUM,"
        //---
        cSql += " F4C_CLASS,"  
        cSql += " FK5_NATURE,"	
        cSql += " coalesce(F4C_REASON,'') as F4C_REASON,"	
        cSql += " F4C_INTNUM,"  
        cSql += " F4C_DTREVE,"  
        cSql += " F4C_CUUID,"   
        cSql += " F4C_UUIDRE"  
        cSql += " from "+RetSqlName("F5M")+" f5m" 
        cSql += " join "+RetSqlName("F4C")+" f4c on f4c_cuuid = f5m_iddoc and f4c.d_e_l_e_t_ = '' and f4c_filial = f5m_filial"
        cSql += " join "+RetSqlName("FK5")+" fk5 on FK5.fk5_idbs  = f4c.f4c_cuuid "
        cSql += " left outer join "+RetSqlName("SA2")+" sa2 on a2_cod = F4C_SUPP and a2_loja = F4C_UNIT and A2_FILIAL = '"+xFilial('SA2')+"'"
        cSql += " left outer join "+RetSqlName("SA1")+" sa1 on a1_cod = F4C_CUST and a1_loja = F4C_CUNI and A1_FILIAL = '"+xFilial('SA1')+"'"
        cSql += " left outer join "+RetSqlName("SA6")+" sa61 on sa61.A6_AGENCIA = F4C_RECBIK and sa61.A6_NUMCON = F4C_RECACC and sa61.A6_MOEDA = F4C_CURREN::integer and sa61.A6_COD = F4C_BNKREC and sa61.A6_FILIAL = '"+xFilial('SA6')+"'"
        cSql += " left outer join "+RetSqlName("SA6")+" sa62 on sa62.A6_AGENCIA = F4C_PAYBIK and sa62.A6_NUMCON = F4C_PAYACC and sa62.A6_MOEDA = F4C_CURREN::integer and sa62.A6_COD = F4C_BNKPAY and sa62.A6_FILIAL = '"+xFilial('SA6')+"'"
        cSql += " where f5m_alias = 'F4C'" 
        cSql += " and f5m.d_e_l_e_t_ = ''  and F5M_FILIAL = '"+xFilial('F5M')+"'" 
        cSql += " and FK5_BANCO = '"+cBank+"'"
        cSql += " and f4c_dtpaym = '"+cDate+"'"    

        If TCSQLEXEC(cSql) < 0 
            conout( "Error at MainQuery 2 >" + TCSQLError(), 'MA-3' )
            lError := .T.
        Endif
    endif

    // add rterplacement items for cancelled (storned) lines

    if lStorno == .F. .and. lError == .F.
        //storno not detailed
        cSql := " delete from " + cTable + " where F4C_DTREVE != ''"
        If TCSQLEXEC(cSql) < 0
            conout( "Error at MainQuery 2a >" + TCSQLError(), 'MA-3' )
            lError := .T.
        Endif
    endif

   //closing balance
    if lError == .F.     
        cSql := " insert into " + cTable + " ("
        cSql += "F4C_DTPAYM,"	//Date of bank document
        cSql += "F4C_OPER,"	//Date of bank document
        cSql += "BALANCE," 	
        cSql += "Z_PAYTYP"  //Text 
        cSql += " ) "
        cSql += " select"
        cSql += " E8_DTSALAT as F4C_DTPAYM, "
        cSql += " 'C' as F4C_OPER, "
        cSql += " E8_SALATUA as BALANCE, "
        cSql += " '"+STR0044+"' as Z_PAYTYP  " // closing  balance
        cSql += " from "+RetSqlName("SE8")+" se8 "
        cSql += " where E8_BANCO = '"+cBank+"'"
        cSql += " and E8_FILIAL = '"+xFilial('SE8')+"'"
        cSql += " and E8_DTSALAT = "
        cSql += "   (select min(E8_DTSALAT) from "+RetSqlName("SE8")+" se8a 
        cSql += "    where SE8A.E8_BANCO = '"+cBank+"'and SE8A.E8_FILIAL = '"+xFilial('SE8')+"' and SE8A.E8_DTSALAT >= '"+cDate+"')"

        If TCSQLEXEC(cSql) < 0
            conout( "Error at MainQuery 3 >" + TCSQLError(), 'MA-3' )
            lError := .T.
        Endif
    endif
 
   //check balances
    if lError == .F.     
        cSql := " insert into " + cTable + " ("
        cSql += " F4C_DTPAYM,"	//Date of bank document
        cSql += " BALANCE," 	
        cSql += " Z_PAYTYP"  //Text 
        cSql += " ) "
        cSql += " select"
        cSql += " '"+cDate+"' as F4C_DTPAYM, "
        cSql += " case when FIN_CHK_CALC = FIN_CHK_TAB then 0 else Abs(FIN_CHK_CALC) - Abs(FIN_CHK_TAB) end  as BALANCE, "
        cSql += " '"+STR0046+"' as Z_PAYTYP  " // balance difference check
        cSql += " from "
        cSql += " (select sum(BALANCE)+sum(IN_SUM)-sum(OUT_SUM) as FIN_CHK_CALC from " + cTable + " tmp where F4C_OPER !='C' and F4C_DTREVE = '') as calc "
        cSql += " join "
        cSql += " (select E8_SALATUA as fin_chk_tab from "+RetSqlName("SE8")+" se8 "
        cSql += "   where E8_BANCO = '"+cBank+"' and E8_DTSALAT = "
        cSql += "     (select min(E8_DTSALAT) from "+RetSqlName("SE8")+" se8a where SE8A.E8_BANCO = '"+cBank+"' and SE8A.E8_FILIAL = '"+xFilial('SE8')+"' and SE8A.E8_DTSALAT >= '"+cDate+"')) as tab "
        cSql += " on 1=1"
        
        If TCSQLEXEC(cSql) < 0
            conout( "Error at MainQuery 4 >" + TCSQLError(), 'MA-3' )
            lError := .T.
        Endif
    endif
Return


//--------------------------------------------------------------------
/*/{Protheus.doc} RU06R0502
create a JSON structure for an Angular output
@author Maxim Popenker
@since  29/01/2024
@type
@param cKey, Char, key
@version 1.0
/*/
 Function RU06R0502(cKey)
    Local oMainGrid := GetDxModel('main')
    Local oSummary := GetDxModel('summary')
    Local aFields := {}	
    Local oParamJson := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey) 
    Local cDate := oParamJson['mv_par01']
    Local cBank   := oParamJson['mv_par02']
    Local oDD := GetDxModel('drillDownLink')
    Local cTitle := STR0041+' '+FormatDate(cDate)+' '+STR0042+' '+GetBankName(cBank)

    // Grid configuration parameters
    oMainGrid['columnResizingMode'] 	:= 'widget'
    oMainGrid['columnFixing']['enabled'] 	:= .T.
    oMainGrid['scrolling'] := '{}'
    oMainGrid['stateStoring']['enabled'] := .T.
    oMainGrid['stateStoring']['storageKey'] := 'RU06R05' //+ RetCodUsr()

    //Column definition for the main grid
    Aadd(aFields,{"F4C_BNKORD",   STR0014,"string",.T.})	//Number of bank document
    Aadd(aFields,{"F4C_DTPAYM",   STR0015,"date",.T.})	//Date of bank document
    Aadd(aFields,{"BALANCE",      STR0045,"string",.T.}) //Column for opening/closing balances

    Aadd(aFields,{"F4C_OPER",     STR0016,"string",.T.}) //Operation   : 1=Inflow;2=Outflow  

    Aadd(aFields,{"F4C_PAYTYP",   STR0017,"string",.T.}) //Payment type: 1=paymt. to supp.;2=return to cust.;3=budget paymt.;4=paymt to empl.;5=return from supp.;6=paymt from cust.;7=paymt from budget;
    Aadd(aFields,{"Z_PAYTYP",     STR0018,"string",.T.}) //Text for payment type
    Aadd(aFields,{"F4C_SUPP",     STR0019,"string",.T.}) //Supplier code
    Aadd(aFields,{"F4C_UNIT",     STR0020,"string",.T.}) //Supplier unit
    Aadd(aFields,{"A2_NOME",      STR0021,"string",.T.}) //supplier name
    Aadd(aFields,{"F4C_BNKREC",   STR0022,"string",.T.}) //Receiving bank
    Aadd(aFields,{"F4C_ACRNAM",   STR0023,"string",.T.}) //Receiver Account Name   
    Aadd(aFields,{"F4C_RECBIK",   STR0024,"string",.T.}) //BIK of the correspondent
    Aadd(aFields,{"F4C_RECACC",   STR0025,"string",.T.}) //Bank account number of the correspondent
    Aadd(aFields,{"OUT_SUM",      STR0026,"number",.T.,'fixedPoint',2}) //Outflow payment amount

    Aadd(aFields,{"F4C_RECTYP",   STR0027,"string",.T.}) //Reciept type: 1=Receive from a customer;2=Return from a supplier                                                                              
    Aadd(aFields,{"Z_RECTYP",     STR0028,"string",.T.}) //Text for receipt type
    Aadd(aFields,{"F4C_CUST",     STR0029,"string",.T.}) //Customer code
    Aadd(aFields,{"F4C_CUNI",     STR0030,"string",.T.})	//Customer unit 
    Aadd(aFields,{"A1_NOME",      STR0031,"string",.T.}) //Customer name
    Aadd(aFields,{"F4C_BNKPAY",   STR0032,"string",.T.}) //Payer bank
    Aadd(aFields,{"F4C_ACPNAM",   STR0033,"string",.T.})	//Payer Account Name    
    Aadd(aFields,{"F4C_PAYBIK",   STR0034,"string",.T.})	//BIK of the correspondent
    Aadd(aFields,{"F4C_PAYACC",   STR0035,"string",.T.})	//Bank account number of the correspondent
    Aadd(aFields,{"IN_SUM",       STR0036,"number",.T.,'fixedPoint',2}) //Inflow payment amount

    Aadd(aFields,{"F4C_CLASS",    STR0037,"string",.T.}) //Class
    Aadd(aFields,{"FK5_NATURE",   STR0038,"string",.T.})	//Class 
    Aadd(aFields,{"F4C_REASON",   STR0039,"string",.T.})	//Reason for payment
    Aadd(aFields,{"F4C_INTNUM",   STR0040,"string",.T.}) //Bank statement number
    Aadd(aFields,{"F4C_DTREVE",   STR0048,"date",.T.}) //date reversed

    // create JSON structure from columns array
    Fill_json_colums( aFields, @oMainGrid)
    
    // Totals
    AddTotals(@oSummary,'OUT_SUM',STR0026,'sum')
    AddTotals(@oSummary,'IN_SUM',STR0036,'sum')

    oMainGrid['summary'] := oSummary

    // Define drilldown relations
    oDD['callerGridId'] 		:= "maingrid"
    oDD['callerGridColumn']	:= "*"
    oDD['drillDownGridId'] 	:= "DD"

    // fill complete JSON data
    cRet :=  '{"data": { "sections": ['+;
                                        '{"dxDataGridSetup": '+oMainGrid:toJSon()+", "+;
                                        ' "title": "'+cTitle+'",'+;
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
                    ' "mainTitle": "'+cTitle+' " },'+; // 
            ' "status": "ok",'+;
            ' "ok": "ok",'+;
            ' "statusText": "ok"}'    
  

    FreeObj(oMainGrid)
    FreeObj(oSummary)

Return cRet


/*/{Protheus.doc} RU06R0503
   drill-down processor from main angular report   
   @author Maxim Popenker
   @since  18/12/2023
   @type
   @version 1.0
/*/
function RU06R0503(cColumn, cGridID,cDrillDownID,cKey,cBody)
    Local oData := JSONOBJECT():NEW()
    Local cBodyTmp as Character

    cBodyTmp := DecodeUtf8(cBody)
    If cBodyTmp == Nil
        cBodyTmp := cBody
    Endif
    oData:FROMJSON(cBodyTmp)
        
    If !Empty(oData['F4C_INTNUM'])
        ShowTab(oData['F4C_INTNUM'],oData['F4C_DTTRAN'])
    Endif 

    FreeObj(oData)
Return 

/*/{Protheus.doc} GetBankName
   get vendor name for report header
   @author Maxim Popenker
   @since  18/12/2023
   @type
   @version 1.0
/*/
static function GetBankName(cBank)
    local cName :=""
    cName := Alltrim(posicione("SA6",1,xFilial("SA6") + cBank,"A6_ACNAME"))
    cName := Strtran(cName,'"',' ')
Return cName

/*/{Protheus.doc} ShowTab
   display document (Invoice/paymemt/bank statement) from drill-down
   @author Maxim Popenker
   @since  18/12/2023
   @type
   @version 1.0
/*/
Static function ShowTab(cIntNum,cDtTran)

    Local aSaveArea  as Array
    Local aAreaTab   as Array
    Private cCadastro := ""
    Private INCLUI := .F.
    Private ALTERA := .F.

    aSaveArea := GetArea() 
    aAreaTab := F4C->(GetArea())

    DbSelectArea("F4C")
    DbSetOrder(1)
    F4C->(DbGoTop())    

    if F4C->(MsSeek(xFilial('F4C') + Padr(cIntNum, 10, '') + cDtTran))
        FWExecView(STR0047, 'RU06D07', MODEL_OPERATION_VIEW,, { || .T. } )
    ENDIF

    RestArea(aAreaTab)  
    RestArea(aSaveArea) 

Return



/*/
{Protheus.doc} AddTotals, 
add Totals data for the grid summary 
@author Maxim Popenker
@since  29/01/2024
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
@since  29/01/2024
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
@since  29/01/2024
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
returns part of the SQL "where" condition if parameter value is not default ( != DEFAULTPARVAL)
@author Maxim Popenker
@since  29/01/2024
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
@since  29/01/2024
@param  aFields,  Array,      list of the fields for selected data structure and their properties.
@param  oDtGridOut, Object,      Json grid object
@version 1.0
/*/
static function Fill_json_colums( aFieldsIn, oDtGridOut)
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

      aadd(oDtGridOut['columns'], oCol)
      FreeObj(oCol)
    Next
    FreeObj(oFormat)
Return

/*/{Protheus.doc} fill_db_field
fills an array for creation of the temporary DB table based on SX3 data
@author Maxim Popenker
@since  29/01/2024
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
@since  29/01/2024
@type
@version 1.0
@param  aStruc,  Array,      list of the fields for selected data table  and their properties.
@param  cFieldname, Char,    field name 
@param  nLen, Numeric,    field length 
@param  nDec, Numeric,    number of decimal places
/*/
static function fill_ndb_field(aStruc, cFieldname, nLen, nDec)

    aadd(aStruc,{cFieldname ,'N', nLen, nDec})

Return



/*/{Protheus.doc} fill_cdb_field
fills an array for creation of the temporary DB table for Char  field                                                                                                                   ray for creation of the temporary DB table, checking if the custom field is activated
@author Maxim Popenker
@since  29/01/2024
@type
@version 1.0
@param  aStruc,  Array,      list of the fields for selected data table  and their properties.
@param  cFieldname, Char,    field name 
@param  nLen, Numeric,    field length 
/*/
static function fill_cdb_field(aStruc, cFieldname, nLen)

    aadd(aStruc,{cFieldname ,'C', nLen})

Return


/*/{Protheus.doc} FormatDate
   formats date from internal format YYYYMMDD to russian print standart DD.MM.YYYY
   @author Maxim Popenker
   @since  29/01/2024
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
   @since  29/01/2024
   @type
   @version 1.0
/*/
static function MyParamBox()
   local aParamBox := {}
   local aRet := {} 
   local lRes := .F.
   Local cLoad := 'RU06R05'+ RetCodUsr()

    aAdd(aParamBox,{1,STR0001,StoD("        "),"","","","",60,.T.}) //date 
    BoxParamAdd(@aParamBox,"E8_BANCO",STR0002,"SA6",.T.)// bank code
    aAdd(aParamBox,{4,STR0003,.F.,"",50,"",.F.}) //checkbox: storno detailed

    lRes := ParamBox(aParamBox,STR0004,@aRet,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/,/*oMainDlg*/,cLoad,.T.,.T.)

Return lRes

/*/{Protheus.doc} BoxParamAdd
   add parameter using DB settings
   @author Maxim Popenker
   @since  29/01/2024
   @type
   @version 1.0
/*/
static function BoxParamAdd(aParamBox,cFldName,cText,cF3,lMandatory)
    local cValid := ''
    if cFldName =  "A2_COD"
        cValid := 'Vazio() .Or. ExistCpo("SA2")' + iif(!Empty(GetSx3Cache(cFldName,"X3_VLDUSER")),' .or. '+GetSx3Cache(cFldName,"X3_VLDUSER"),'')
    elseif cFldName =  "CTO_MOEDA" 
        cValid := 'Vazio() .Or. ExistCpo("CTO")' + iif(!Empty(GetSx3Cache(cFldName,"X3_VLDUSER")),' .or. '+GetSx3Cache(cFldName,"X3_VLDUSER"),'')
    endif
    aAdd(aParamBox,{1,cText,Space(TamSx3(cFldName)[1]),"",cValid,cF3,"",TamSx3(cFldName)[1],lMandatory})
Return
                   
//Merge Russia R14 
                   
