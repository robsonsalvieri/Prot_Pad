#INCLUDE 'protheus.ch'
#INCLUDE 'fwmvcdef.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'RU06R04.ch'

#DEFINE DELETEFILE .F.
#DEFINE FIELDNAME 1
#DEFINE FIELDDESC 2
#DEFINE FIELDTYPE 3
#DEFINE FIELDVISIBLE 4
#DEFINE TYPEFORMAT 5
#DEFINE DECIMAFORMAT 6
#DEFINE STRCOLM 4 // columns for String, Numeric has more columns
#DEFINE DEFAULTPARVAL '*'

/*/{Protheus.doc} RU06R0401
    Reconcillation sheet  with Supplier/Vendor using Angular output
    @type  Function
    @author Maxim Popenker
    @since 14/12/2023
    @version 1.0
    @example
    (examples)
    @see https://jiraproducao.totvs.com.br/browse/RULOC-1843
    /*/
Function RU06R0401()
    While MainReport()

    Enddo
Return

/*/{Protheus.doc} MainReport
    Reconcillation sheet  with Supplier/Vendor using Angular output
    @type  Function
    @author Maxim Popenker
    @since 14/12/2023
    @version 1.0
    @example
    (examples)
    @see 
/*/
Static Function MainReport

    Local cFile := Lower(CriaTrab(NIL, .F.)  )
    Local nHandle       
    Local oJson := JsonObject():New()
    Local cContrlKey := 'F'+StrZero(Randomize( 1, 999999 ),6)
    Local lRecall := .F.
    local aParams := {} // selection parameters
    local cTable1 := ""

    If MyParamBox() // if Selection parameters were completed with OK

        oJson['controlKey']  := cContrlKey
        oJson['files']       := {'SECTION1'}
        oJson['mv_par01']    := dtos(mv_par01)      // Date from
        oJson['mv_par02']    := dtos(mv_par02)      // Date to
        oJson['mv_par03']    := Alltrim(mv_par03)   // vendor code
        oJson['mv_par04']    := Alltrim(mv_par04)   // vendor dept
        oJson['mv_par05']    := Alltrim(mv_par05)   // contract from
        oJson['mv_par06']    := Alltrim(mv_par06)   // contract to
        oJson['mv_par07']    := mv_par07            // checkbox: group contracts: T = yes, F = No
        oJson['mv_par08']    := mv_par08            // checkbox: currencies: T = rub only, F = both currencies
        oJson['mv_par09']    := mv_par09            // checkbox: T = add VAT, F = exclude VAT
        oJson['vendorname']  := GetVendorName(mv_par03,mv_par04)


        // pass parameters for data selection 
        AddMvParam(aParams, oJson['mv_par01'])        
        AddMvParam(aParams, oJson['mv_par02']) 
        AddMvParam(aParams, oJson['mv_par03'])      
        AddMvParam(aParams, oJson['mv_par04'])  
        AddMvParam(aParams, oJson['mv_par05']) 
        AddMvParam(aParams, oJson['mv_par06'])      
        aadd(aParams, mv_par07) 
        aadd(aParams, mv_par08) 
        aadd(aParams, mv_par09) 

        //Create report data, insert into the temporary DB table and then pass to angular via the file at the server
        cTable1 := 'SECTION1' + "_" + cContrlKey
        FwMsgRun(,{|oSay| MainDataCreate(aParams,cTable1)},'',STR0015) // STR0015 = wait for process

        nHandle := FCREATE(cFile+".dxparam", 0)
        FWRITE(nHandle, oJson:toJSon())
        FCLOSE(nHandle) 

        //invoke Angular grid engine
        lRecall := RU99X1203_DATAGRID3('RU06R0402','RU06R0403',cFile, DELETEFILE)
    
        //Delete temporary file
        STATICCALL(RU99X13_DXMODELS,CleanFiles,cFile)  
    Endif

Return lRecall


/*/{Protheus.doc} MainDataCreate
    Create all structures, temporary tables and fill with data
    @author Maxim Popenker
    @since  14/12/2023
    @type
    @version 1.0
    @param aPar, array, list of pergunte parameters
    @param cTableName, Char, name of temporary table
    @return Nil

/*/
Static Function MainDataCreate(aPar,cTableName)
    Local aStru1   := {} //structure for main grid

    fill_db_field(@aStru1,"E2_EMISSAO") //date
    fill_db_field(@aStru1,"F5Q_CODE") //contract code
    fill_cdb_field(@aStru1,"CONTRACT",GetSx3Cache("F5Q_DESCR","X3_TAMANHO")) //contract
    fill_cdb_field(@aStru1,"PAYORD",60) //payment order/bank statement
    fill_cdb_field(@aStru1,"INVOICE",60) //invoice

    fill_ndb_field(@aStru1,"DEBIT_D",13,2) //debit in document currency
    fill_ndb_field(@aStru1,"CREDIT_D",13,2) //credit in document currency
    fill_db_field(@aStru1,"CTO_SIMB") //Currency - short name
    
    fill_ndb_field(@aStru1,"DEBIT_H",13,2) //debit in home (Rub) currency
    fill_ndb_field(@aStru1,"CREDIT_H",13,2) //credit in home (Rub) currency
    fill_cdb_field(@aStru1,"COMMENT",60) //comment


    //tech fields for DD
    fill_db_field(@aStru1,"E2_CONUNI") //conv.units/YE,1=Yes,2=No
    fill_db_field(@aStru1,"E2_PREFIXO") //AR prefix
    fill_db_field(@aStru1,"E2_NUM") //AR number
    fill_db_field(@aStru1,"E2_PARCELA") //AP installment
    fill_db_field(@aStru1,"E2_TIPO") //AR type
    fill_db_field(@aStru1,"E2_MOEDA") //Currency code
    fill_db_field(@aStru1,"F4C_CUUID") // link to the bank statement
    fill_db_field(@aStru1,"E2_F5QUID") // link to the Contract

    //conv unit text
    fill_cdb_field(@aStru1,"Z_UE",3) //U E

    fill_cdb_field(@aStru1,"RECTAB",3) //source document table
    fill_ndb_field(@aStru1,"RECNO",13,0) //recno pointer to source document

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
@since  14/12/2023
@type
@version 1.0
@param cTable, Char, table name
@param aParams, array, list of pergunte parameters
/*/
Static function LoadData(cTable,aParams)
    Local cSql     := ''
    Local cStartDate := aParams[1] 
    Local cEndDate := aParams[2] 
    Local cVendor := aParams[3] 
    Local cLoja := aParams[4] 
    Local cContrFr := aParams[5] 
    Local cContrTo := aParams[6] 
    Local lGroup   := aParams[7] //group contracts: T = yes, F = No
    Local lRubOnly := aParams[8] //currencies: T = rub only, F = both currencies
    Local cCr := "'NF','NDP'" // Credit doc typec
    Local cDb := "'PA'" // Debit foc types
    Local cAllowedMotBx := "'DAC'" // list of allowed FK2 operations for line items
    Local cInitMotBx := "" // list of (all) allowed FK2 operations for initial balance
    Local cInitDate := dtos(DaySub(stod(cStartDate),1)) // last date for calculating opening balances
	Local cQuery
	local aContrUid    := {}
    local cAlsTmp
    local nCntContr

    //pre-select contracts if needed
    if Empty(cContrFr)  .or. lGroup = .T.
        aAdd(aContrUid, {"",""})
    endif
    if lGroup = .F. // do not group contracts
        cQuery := " select F5Q_UID,F5Q_CODE "
        cQuery += " from "+RetSqlName("F5Q")+" F5Q  "
        cQuery += " where F5Q_A2COD = '"+cVendor+"'"
        cQuery += " and F5Q_A2LOJ = '"+cLoja+"'"
        cQuery += " and F5Q_FILIAL = '"+xFilial("F5Q")+"'"
        cQuery += " and F5Q_EDATE < '"+cEndDate+"'"
        cQuery += " and  D_E_L_E_T_ = ''"
        cQuery += " " + AddSqlParam( "F5Q_CODE", ">=", cContrFr )
        cQuery += " " + AddSqlParam( "F5Q_CODE", "<=", cContrTo )

        cQuery:=ChangeQuery(cQuery)
        cAlsTmp     := RU01GETALS(cQuery)
        While (cAlsTmp)->(! EOF())
            aAdd(aContrUid, {(cAlsTmp)->F5Q_UID,(cAlsTmp)->F5Q_CODE})
            (cAlsTmp)->(dbSkip())
        EndDo
        (cAlsTmp)->(dbCloseArea())

    endif

    //dummy record (to be deleted later) for populating zero initial balances
    cSql := "insert into " + cTable + " ( E2_EMISSAO ) select '00000000'"
    If TCSQLEXEC(cSql) < 0
        conout( "Error at MainQuery 0 >" + TCSQLError(), 'MA-3' )
        Return
    Endif

    for nCntContr := 1 to Len(aContrUid)
        //---------------------------------------------
        // Initial balances
        cSql := " insert into " + cTable + " ("
        cSql += "  E2_EMISSAO" //date
        cSql += ", F5Q_CODE" //contract code
        cSql += ", CONTRACT" //contract
        cSql += ", COMMENT" //comment
        if lRubOnly = .F.
            cSql += ", DEBIT_D" //debit in document currency
            cSql += ", CREDIT_D" //credit in document currency
            cSql += ", E2_CONUNI"//conv.units
            cSql += ", CTO_SIMB" //Currency - short name
        endif
        cSql += ", DEBIT_H" //debit in home (Rub) currency
        cSql += ", CREDIT_H" //credit in home (Rub) currency
        cSql += ", E2_F5QUID" // link to the Contract
        cSql += " ) "
        cSql += " select "
        cSql += "  E2_EMISSAO" //date
        cSql += ", F5Q_CODE" //contract code
        cSql += ", CONTRACT" //contract
        cSql += ", COMMENT" //comment
        if lRubOnly = .F.
            cSql += ", case when sum(DEBIT_D) > sum(CREDIT_D) then (sum(DEBIT_D) - sum(CREDIT_D)) else 0 end as DEBIT_D"
            cSql += ", case when sum(CREDIT_D) > sum(DEBIT_D) then (sum(CREDIT_D) - sum(DEBIT_D)) else 0 end as CREDIT_D"
            cSql += ", E2_CONUNI"
            cSql += ", CTO_SIMB"
        endif
        cSql += ", case when sum(DEBIT_H) > sum(CREDIT_H) then (sum(DEBIT_H) - sum(CREDIT_H)) else 0 end as DEBIT_H"
        cSql += ", case when sum(CREDIT_H) > sum(DEBIT_H) then (sum(CREDIT_H) - sum(DEBIT_H)) else 0 end as CREDIT_H"   
        cSql += ", E2_F5QUID" // link to the Contract
        
        cSql += "   	from ("
        
        cSql += "   select"
        cSql += " 	'"+cStartDate+"' as E2_EMISSAO,"
        cSql += " 	'"+aContrUid[nCntContr,2]+"' as F5Q_CODE,"
        cSql += "   CONTRACT,"
        cSql += "   '"+STR0026+"' as COMMENT,"//initial balance text
        cSql += "  	DEBIT_D,"
        cSql += "   CREDIT_D,"
        cSql += " 	CTO_SIMB,"
        cSql += "  	DEBIT_H,"
        cSql += "   CREDIT_H,"
        cSql += "   E2_CONUNI,"
        cSql += "   E2_F5QUID"
        
        cSql += "   	from ("
        
        cSql += SqlItems('19000101',cInitDate,cEndDate,cVendor,cLoja,cContrFr,cContrTo,aContrUid[nCntContr],lGroup,cCr,cDb,cInitMotBx)

        cSql += "	) tmp1"
        cSql += "	) tmp2 group by E2_EMISSAO, F5Q_CODE, CONTRACT, E2_F5QUID, "
        if lRubOnly = .F.
            cSql += "	E2_CONUNI, CTO_SIMB, "
        endif
        cSql += "	COMMENT"

        If TCSQLEXEC(cSql) < 0
            conout( "Error at MainQuery 1 >" + TCSQLError(), 'MA-3' )
            Return
        Endif

        //---------------------------------------------
        // insert zero balance in contract currency if there is none calculated (contract is younger than the start date)
        cSql := " insert into " + cTable + " ("
        cSql += "  E2_EMISSAO" //date
        cSql += ", F5Q_CODE" //contract code
        cSql += ", CONTRACT" //contract
        cSql += ", COMMENT" //comment
        cSql += ", DEBIT_D" //debit in document currency
        cSql += ", CREDIT_D" //credit in document currency
        cSql += ", CTO_SIMB" //Currency - short name
        cSql += ", DEBIT_H" //debit in home (Rub) currency
        cSql += ", CREDIT_H" //credit in home (Rub) currency
        cSql += ", E2_CONUNI"//conv.units
        cSql += ", E2_F5QUID" // link to the Contract
        cSql += " ) "
        cSql += " select "
        cSql += " 	'"+cStartDate+"',"
        cSql += " 	'"+aContrUid[nCntContr,2]+"',"
        cSql += "   coalesce(F5Q_DESCR,'') as CONTRACT,"
        cSql += "   '"+STR0026+"' as COMMENT,"//initial balance text
        cSql += "  	0 as DEBIT_D,"
        cSql += "   0 as CREDIT_D,"
        cSql += " 	coalesce(CTO.CTO_SIMB,'"+STR0030+"'),"
        cSql += "  	0 as DEBIT_H,"
        cSql += "   0 as CREDIT_H,"
        cSql += "   coalesce(F5Q_CONUNI,'2') as E2_CONUNI,"
        cSql += "   coalesce(F5Q_UID,'') as E2_F5QUID"
        cSql += "   	from "
        cSql += " " + cTable + " tmp1 "
        cSql += " left outer join "+RetSqlName("F5Q")+" F5Q on"
        cSql += " 	F5Q.F5Q_CODE = '"+aContrUid[nCntContr,2]+"' and F5Q.F5Q_FILIAL = '"+xFilial('F5Q')+"' and F5Q.D_E_L_E_T_ = ''"
	    cSql += " left outer join "+RetSqlName("CTO")+" CTO on"
        cSql += " 	CTO_MOEDA::INTEGER = F5Q_MOEDA and (CTO_FILIAL = F5Q_FILIAL or CTO_FILIAL = '')"
    	cSql += " where not exists ( select 1 from " + cTable + " tmp2 where comment = '"+STR0026+"' and F5Q_CODE = '"+aContrUid[nCntContr,2]+"')"
        cSql += " limit 1"

        If TCSQLEXEC(cSql) < 0
            conout( "Error at MainQuery 1 >" + TCSQLError(), 'MA-3' )
            Return
        Endif

        if nCntContr = 1
            //delete dummy record as it is not needed anymore
            cSql := "delete from " + cTable + " where E2_EMISSAO = '00000000'"
            If TCSQLEXEC(cSql) < 0
                conout( "Error at MainQuery End >" + TCSQLError(), 'MA-3' )
            Endif
        endif

        //---------------------------------------------
        // document items
        cSql := " insert into " + cTable + " ("
        cSql += "  E2_EMISSAO" //date
        cSql += ", F5Q_CODE" //contract code
        cSql += ", CONTRACT" //contract
        cSql += ", DEBIT_D" //debit in document currency
        cSql += ", CREDIT_D" //credit in document currency
        cSql += ", CTO_SIMB" //Currency - short name
        cSql += ", DEBIT_H" //debit in home (Rub) currency
        cSql += ", CREDIT_H" //credit in home (Rub) currency
        cSql += ", COMMENT" //comment
        cSql += ", E2_PREFIXO" //AR prefix
        cSql += ", E2_NUM" //AR number
        cSql += ", E2_PARCELA" //AP installment
        cSql += ", E2_TIPO" //AR type
        cSql += ", E2_CONUNI"//conv.units
        cSql += ", E2_F5QUID" // link to the Contract
        cSql += ", RECTAB" 
        cSql += ", RECNO" 
        cSql += " ) "
        cSql += " select "
        cSql += "  E2_EMISSAO"
        cSql += ", F5Q_CODE" 
        cSql += ", CONTRACT"
        cSql += ", DEBIT_D"
        cSql += ", CREDIT_D"
        cSql += ", CTO_SIMB"
        cSql += ", DEBIT_H "
        cSql += ", CREDIT_H"
        cSql += ", COMMENT" 
        cSql += ", E2_PREFIXO"
        cSql += ", E2_NUM"
        cSql += ", E2_PARCELA"
        cSql += ", E2_TIPO"
        cSql += ", E2_CONUNI"
        cSql += ", E2_F5QUID"
        cSql += ", RECTAB" 
        cSql += ", RECNO" 

        cSql += " from ("
        
        cSql += SqlItems(cStartDate,cEndDate,cEndDate,cVendor,cLoja,cContrFr,cContrTo,aContrUid[nCntContr],lGroup,cCr,cDb,cAllowedMotBx)

        cSql += " 	) tmp order by E2_EMISSAO, lorder"

        If TCSQLEXEC(cSql) < 0
            conout( "Error at MainQuery 2 >" + TCSQLError(), 'MA-3' )
            Return
        Endif


        //---------------------------------------------
        //closing balance
        cSql := " insert into " + cTable + " ("
        cSql += "  E2_EMISSAO" //date
        cSql += ", F5Q_CODE" //contract code
        cSql += ", CONTRACT" //contract
        cSql += ", COMMENT" //comment
        if lRubOnly = .F.
            cSql += ", DEBIT_D" //debit in document currency
            cSql += ", CREDIT_D" //credit in document currency
            cSql += ", E2_CONUNI"//conv.units
            cSql += ", CTO_SIMB" //Currency - short name
        endif
        cSql += ", DEBIT_H" //debit in home (Rub) currency
        cSql += ", CREDIT_H" //credit in home (Rub) currency
        cSql += ", E2_F5QUID" // link to the Contract
        cSql += " ) "
        cSql += " select "
        cSql += " 	'"+cEndDate+"',"
        cSql += " 	'"+aContrUid[nCntContr,2]+"',"
        cSql += "   CONTRACT,"
        cSql += "   '"+STR0031+"' as COMMENT,"//closing balance text
        if lRubOnly = .F.
            cSql += "  	case when sum(DEBIT_D) > sum(CREDIT_D) then (sum(DEBIT_D) - sum(CREDIT_D)) else 0 end as DEBIT_D,"
            cSql += "   case when sum(CREDIT_D) > sum(DEBIT_D) then (sum(CREDIT_D) - sum(DEBIT_D)) else 0 end as CREDIT_D,"
            cSql += "   E2_CONUNI,"
            cSql += " 	CTO_SIMB,"
        endif
        cSql += "  	case when sum(DEBIT_H) > sum(CREDIT_H) then (sum(DEBIT_H) - sum(CREDIT_H)) else 0 end as DEBIT_H,"
        cSql += "   case when sum(CREDIT_H) > sum(DEBIT_H) then (sum(CREDIT_H) - sum(DEBIT_H)) else 0 end as CREDIT_H,"   
        cSql += "   E2_F5QUID"
        cSql += "   	from " + cTable + " Tmp "
        if lGroup = .F.
            cSql += " 	where tmp.E2_F5QUID = '"+aContrUid[nCntContr,1]+"'"
        endif
        cSql += "   group by CONTRACT"
        if lRubOnly = .F.
            cSql += "   ,CTO_SIMB,E2_CONUNI"
        endif
        cSql += "   ,E2_F5QUID"

        If TCSQLEXEC(cSql) < 0
            conout( "Error at MainQuery 3 >" + TCSQLError(), 'MA-3' )
            Return
        Endif

    next

    //---------------------------------------------
    // set the U.E. flag for display
    if lRubOnly = .F.
        cSql := " update " + cTable + " set "
        cSql += " Z_UE = '"+STR0008+"'" // Yes
        cSql += " where E2_CONUNI = '1'"

        If TCSQLEXEC(cSql) < 0
            conout( "Error at MainQuery 4 >" + TCSQLError(), 'MA-3' )
            Return
        Endif
    endif


Return

/*/{Protheus.doc} SqlItems
generate SQL code to retrieve document items for the selected period and conditions
used to calculate both Initial Balance (summarized) and show report items (as selected)
@author Maxim Popenker
@since  14/12/2023
@type
@param cKey, Char, key
@version 1.0
/*/
Static function SqlItems(cStartDate,cEndDate,cFk2Date,cVendor,cLoja,cContrFr,cContrTo,aCurContr,lGroup,cCr,cDb,cAllowedMotBx)
	local cSql := ""

        // SE2 invoices
        cSql += " select"
        cSql += " E2_EMISSAO,"
        if lGroup = .T. //group contracts
            cSql += " '' as F5Q_CODE,"
            cSql += " '' as CONTRACT,"
            cSql += " '' as E2_F5QUID,"
        else
            cSql += " 	'"+aCurContr[2]+"' as F5Q_CODE,"
            cSql += " coalesce(F5Q_DESCR, '') as CONTRACT,"
            cSql += " E2_F5QUID,"
        endif
        cSql += " E2_MOEDA,"
        cSql += " CTO_SIMB,"
        cSql += " E2_PREFIXO,"
        cSql += " E2_NUM,"
        cSql += " E2_PARCELA,"
        cSql += " E2_TIPO,"
        cSql += " E2_CONUNI,"
        cSql += " coalesce(case when E2_TIPO in ("+CDB+") then E2_VALOR else 0 end, 0) as DEBIT_D, "
        cSql += " coalesce(case when E2_TIPO in ("+CCR+") then E2_VALOR else 0 end, 0) as CREDIT_D,"
        cSql += " coalesce(case when E2_TIPO in ("+CDB+") then E2_VLCRUZ else 0 end, 0) as DEBIT_H,"
        cSql += " coalesce(case when E2_TIPO in ("+CCR+") then E2_VLCRUZ else 0 end, 0) as CREDIT_H,"
        cSql += " '"+STR0028+" ' || e2_prefixo || ' No.' ||  e2_num || ' ' ||  e2_parcela as COMMENT," 
        cSql += " '1' as lorder "
        cSql += " , 'SE2' as RECTAB" 
        cSql += " , se2.r_e_c_n_o_ as RECNO" 
        cSql += " from "+RetSqlName("SE2")+" SE2"
        cSql += " join "+RetSqlName("SA2")+" SA2 on"
        cSql += " 	A2_COD = E2_FORNECE and A2_LOJA = E2_LOJA"
        cSql += " left outer join "+RetSqlName("F5Q")+" F5Q on"
        cSql += " 	E2_F5QUID = F5Q_UID and E2_FILIAL = F5Q_FILIAL and F5Q.D_E_L_E_T_ = ''"
        cSql += " left outer join "+RetSqlName("CTO")+" CTO on"
        cSql += " 	CTO_MOEDA::INTEGER = E2_MOEDA and (CTO_FILIAL = E2_FILIAL or CTO_FILIAL = '')"
        cSql += " where"
        cSql += " 	( E2_TIPO in ("+CDB+") or E2_TIPO in ("+CCR+") )"
        cSql += " 	and E2_EMISSAO >= '"+cStartDate+"' and E2_EMISSAO <= '"+cEndDate+"'"
        cSql += " 	and E2_FILIAL = '"+xFilial("SE2")+"'"
        cSql += " 	and SE2.D_E_L_E_T_ = ''"
        cSql += " 	and E2_FORNECE = '"+cVendor+"'"
        cSql += " " + AddSqlParam( "E2_LOJA", "=", cLoja )
        cSql += " " + AddSqlParam( "F5Q_CODE", ">=", cContrFr )
        cSql += " " + AddSqlParam( "F5Q_CODE", "<=", cContrTo )
        if lGroup = .F.
            cSql += " 	and E2_F5QUID = '"+aCurContr[1]+"'"
        endif

        cSql += " union all"

        // FK2 payments
        cSql += " select"
        cSql += " fk2_data as E2_EMISSAO,"
        if lGroup = .T. //group contracts
            cSql += " '' as F5Q_CODE,"
            cSql += " '' as CONTRACT,"
            cSql += " '' as E2_F5QUID,"
        else
            cSql += " '"+aCurContr[2]+"' as F5Q_CODE,"
            cSql += " coalesce(F5Q_DESCR, '') as CONTRACT,"
            cSql += " E2_F5QUID,"
        endif
        cSql += " E2_MOEDA,"
        cSql += " CTO_SIMB,"
        cSql += " E2_PREFIXO,
        cSql += " E2_NUM,"
        cSql += " E2_PARCELA,"
        cSql += " E2_TIPO,"
        cSql += " E2_CONUNI,"
        cSql += " coalesce(case when (E2_TIPO in ("+CCR+") and FK2_TPDOC != 'ES')  or (E2_TIPO in ("+CDB+") and FK2_TPDOC = 'ES') then FK2_VALOR  else 0 end, 0) as CREDIT_D, "
        cSql += " coalesce(case when (E2_TIPO in ("+CCR+") and FK2_TPDOC = 'ES')  or (E2_TIPO in ("+CDB+") and FK2_TPDOC != 'ES') then FK2_VALOR else 0 end, 0) as DEBIT_D,"
        cSql += " coalesce(case when (E2_TIPO in ("+CCR+") and FK2_TPDOC != 'ES')  or (E2_TIPO in ("+CDB+") and FK2_TPDOC = 'ES') then fk2_vlmoe2 else 0 end, 0) as CREDIT_H,"
        cSql += " coalesce(case when (E2_TIPO in ("+CCR+") and FK2_TPDOC = 'ES')  or (E2_TIPO in ("+CDB+") and FK2_TPDOC != 'ES') then fk2_vlmoe2 else 0 end, 0) as DEBIT_H,"
        cSql += " fk2_histor as comment, "
        cSql += " '2' as lorder "
        cSql += " , 'FK2' as RECTAB" 
        cSql += " , fk2.r_e_c_n_o_ as RECNO" 
        cSql += " from "+RetSqlName("SE2")+" SE2"
        cSql += " join "+RetSqlName("SA2")+" SA2 on"
        cSql += " 	A2_COD = E2_FORNECE and A2_LOJA = E2_LOJA"
        cSql += " left outer join "+RetSqlName("F5Q")+" F5Q on"
        cSql += " 	E2_F5QUID = F5Q_UID and E2_FILIAL = F5Q_FILIAL and F5Q.D_E_L_E_T_ = ''"
        cSql += " left outer join "+RetSqlName("FK7")+" FK7 on"
        cSql += " 	fk7.FK7_CHAVE = rpad(E2_FILIAL,6,' ') || '|' || rpad(E2_PREFIXO,3,' ') || '|' || rpad(E2_NUM,8,' ') || '|' || rpad(E2_PARCELA,2,' ')|| '|' || rpad(E2_TIPO,3,' ') || '|' || rpad(E2_FORNECE,6,' ')|| '|' || rpad(E2_LOJA,2,' ') and fk7.d_e_l_e_t_ = ''"
        cSql += " left outer join "+RetSqlName("CTO")+" CTO on"
        cSql += " 	CTO_MOEDA::INTEGER = E2_MOEDA and (CTO_FILIAL = E2_FILIAL or CTO_FILIAL = '')"
        cSql += " join "+RetSqlName("FK2")+" FK2"
        cSql += " 	on FK2_DATA >= '"+cStartDate+"' and FK2_DATA <= '"+cFk2Date+"' and FK2_IDDOC = fk7.FK7_IDDOC and FK2.d_e_l_e_t_ = ''"
        cSql += " where"
        cSql += " 	( E2_TIPO in ("+CDB+") or E2_TIPO in ("+CCR+") )"
        if !Empty(cAllowedMotBx)
            cSql += " 	and FK2_MOTBX in ("+cAllowedMotBx+")"
        endif
        cSql += " 	and E2_EMISSAO >= '"+cStartDate+"' and E2_EMISSAO <= '"+cEndDate+"'"
        cSql += " 	and E2_FILIAL = '"+xFilial("SE2")+"'"
        cSql += " 	and SE2.D_E_L_E_T_ = ''"
        cSql += " 	and E2_FORNECE = '"+cVendor+"'"
        cSql += " " + AddSqlParam( "E2_LOJA", "=", cLoja )
        cSql += " " + AddSqlParam( "F5Q_CODE", ">=", cContrFr )
        cSql += " " + AddSqlParam( "F5Q_CODE", "<=", cContrTo )
        if lGroup = .F.
            cSql += " 	and E2_F5QUID = '"+aCurContr[1]+"'"
        endif
    
        cSql += " union all"

        // F4C bank statements
        cSql += " select "
        cSql += " 	F4C_DTPAYM as E2_EMISSAO,"
        if lGroup = .T. //group contracts
            cSql += " '' as F5Q_CODE,"
            cSql += " '' as CONTRACT,"
            cSql += " '' as E2_F5QUID,"
        else
            cSql += " '"+aCurContr[2]+"' as F5Q_CODE,"
            cSql += " coalesce(F5Q_DESCR, '') as CONTRACT,"
            cSql += " F4C_UIDF5Q as E2_F5QUID,"
        endif
        cSql += " 	F4C_CURREN::integer as E2_MOEDA,"
        cSql += " 	CTO_SIMB,"
        cSql += " 	'' as E2_PREFIXO,"
        cSql += " 	'' as E2_NUM,"
        cSql += " 	'' as E2_PARCELA,"
        cSql += " 	'' as E2_TIPO,"
        cSql += " 	'2' as E2_CONUNI," // no conv units / Y.E.
        cSql += " 	case when F4C_PAYTYP = '1' then F4C_VALUE else 0 end as CREDIT_D,"
        cSql += " 	case when F4C_PAYTYP = '5' then F4C_VALUE else 0 end as DEBIT_D,"
        cSql += " 	case when F4C_PAYTYP = '1' then F4C_VALUE else 0 end as CREDIT_H,"
        cSql += " 	case when F4C_PAYTYP = '5' then F4C_VALUE else 0 end as DEBIT_H,"
        cSql += " 	'"+STR0019+" ' || F4C_BNKORD || ' "+STR0029+" ' || F4C_DTPAYM::date || ' ' /* || f4c_reason::text*/ as comment,"
        cSql += " 	'2' as lorder"
        cSql += " , 'F4C' as RECTAB" 
        cSql += " , f4c.r_e_c_n_o_ as RECNO" 
        cSql += " from F4C000 F4C"
        cSql += " left outer join F5Q000 F5Q on"
        cSql += " 	F5Q_UID = F4C_UIDF5Q "
        cSql += " 	and F4C_FILIAL = F5Q_FILIAL"
        cSql += " 	and F5Q.D_E_L_E_T_ = ''"        
        cSql += " left outer join "+RetSqlName("CTO")+" CTO on"
        cSql += " 	CTO_MOEDA = F4C_CURREN and (CTO_FILIAL = F4C_FILIAL or CTO_FILIAL = '')"
        cSql += " where"
        cSql += " 	f4c_supp = '"+cVendor+"'"
        cSql += " " + AddSqlParam( "F4C_UNIT", "=", cLoja )
        cSql += " 	and F4C_DTPAYM >= '"+cStartDate+"'"
        cSql += " 	and F4C_DTPAYM <= '"+cEndDate+"'"
        cSql += " 	and F4C.D_E_L_E_T_ = ''"
        cSql += " 	and F4C_FILIAL = '"+xFilial("F4C")+"'"
        cSql += " " + AddSqlParam( "F5Q_CODE", ">=", cContrFr )
        cSql += " " + AddSqlParam( "F5Q_CODE", "<=", cContrTo )
        if lGroup = .F.
            cSql += " 	and F4C_UIDF5Q = '"+aCurContr[1]+"'"
        endif

        cSql += " union all"

        // SFR exchange rate differences
        cSql += " select"
        cSql += " FR_DATADI as E2_EMISSAO,"
        if lGroup = .T. //group contracts
            cSql += " '' as F5Q_CODE,"
            cSql += " '' as CONTRACT,"
            cSql += " '' as E2_F5QUID,"
        else
            cSql += " '"+aCurContr[2]+"' as F5Q_CODE,"
            cSql += " coalesce(F5Q_DESCR, '') as CONTRACT,"
            cSql += " E2_F5QUID,"
        endif
        cSql += " FR_MOEDA as E2_MOEDA,"
        cSql += " CTO_SIMB,"
        cSql += " E2_PREFIXO,"
        cSql += " E2_NUM,"
        cSql += " E2_PARCELA,"
        cSql += " E2_TIPO,"
        cSql += " '2' as E2_CONUNI,"
        cSql += " coalesce(case when (E2_TIPO in ("+CCR+") and FR_VALOR > 0) or (E2_TIPO in ("+CDB+") and FR_VALOR < 0) then FR_VALOR  else 0 end, 0) as CREDIT_D, "
        cSql += " coalesce(case when (E2_TIPO in ("+CDB+") and FR_VALOR > 0) or (E2_TIPO in ("+CCR+") and FR_VALOR < 0)then FR_VALOR  else 0 end, 0) as DEBIT_D,"
        cSql += " coalesce(case when (E2_TIPO in ("+CCR+") and FR_VALOR > 0) or (E2_TIPO in ("+CDB+") and FR_VALOR < 0) then FR_VALOR  else 0 end, 0) as CREDIT_H, "
        cSql += " coalesce(case when (E2_TIPO in ("+CDB+") and FR_VALOR > 0) or (E2_TIPO in ("+CCR+") and FR_VALOR < 0)then FR_VALOR  else 0 end, 0) as DEBIT_H,"
        cSql += " '"+STR0012+"' as comment, 
        cSql += " '2' as lorder "
        cSql += " , 'SFR' as RECTAB" 
        cSql += " , sfr.r_e_c_n_o_ as RECNO" 
        cSql += " from "+RetSqlName("SE2")+" SE2"
        cSql += " join "+RetSqlName("SA2")+" SA2 on"
        cSql += " 	A2_COD = E2_FORNECE and A2_LOJA = E2_LOJA"
        cSql += " left outer join "+RetSqlName("F5Q")+" F5Q on"
        cSql += " 	E2_F5QUID = F5Q_UID and E2_FILIAL = F5Q_FILIAL and F5Q.D_E_L_E_T_ = ''"
        cSql += " left outer join "+RetSqlName("SED")+" SED on"
        cSql += " 	ED_CODIGO = E2_NATUREZ and SED.D_E_L_E_T_ = ''"
        cSql += " left outer join "+RetSqlName("FK7")+" FK7 on"
        cSql += " 	fk7.FK7_CHAVE = rpad(E2_FILIAL,6,' ') || '|' || rpad(E2_PREFIXO,3,' ') || '|' || rpad(E2_NUM,8,' ') || '|' || rpad(E2_PARCELA,2,' ')|| '|' || rpad(E2_TIPO,3,' ') || '|' || rpad(E2_FORNECE,6,' ')|| '|' || rpad(E2_LOJA,2,' ') and fk7.d_e_l_e_t_ = ''"
        cSql += " join "+RetSqlName("SFR")+" SFR "
        cSql += " 	on  FR_FILIAL = E2_FILIAL and FR_DATADI >= '"+cStartDate+"' and FR_DATADI <= '"+cEndDate+"' "
        cSql += " 	and FR_CHAVOR = rpad(SE2.E2_PREFIXO,3,' ') || rpad(SE2.E2_NUM,8,' ') || rpad(SE2.E2_PARCELA,2,' ') || rpad(SE2.E2_TIPO,3,' ') || rpad(SE2.E2_FORNECE,6,' ') || rpad(SE2.E2_LOJA,2,' ') "
        cSql += " 	and SFR.d_e_l_e_t_ = ''"
        cSql += " left outer join "+RetSqlName("CTO")+" CTO on"
        cSql += " 	CTO_MOEDA::INTEGER = FR_MOEDA and (CTO_FILIAL = FR_FILIAL or CTO_FILIAL = '')"
        cSql += " where"
        cSql += " 	( E2_TIPO in ("+CDB+") or E2_TIPO in ("+CCR+") )"
        cSql += " 	and E2_EMISSAO >= '"+cStartDate+"' and E2_EMISSAO <= '"+cEndDate+"'"
        cSql += " 	and E2_FILIAL = '"+xFilial("SE2")+"'"
        cSql += " 	and SE2.D_E_L_E_T_ = ''"
        cSql += " 	and E2_FORNECE = '"+cVendor+"'"
        cSql += " " + AddSqlParam( "E2_LOJA", "=", cLoja )
        cSql += " " + AddSqlParam( "F5Q_CODE", ">=", cContrFr )
        cSql += " " + AddSqlParam( "F5Q_CODE", "<=", cContrTo )
        if lGroup = .F.
            cSql += " 	and E2_F5QUID = '"+aCurContr[1]+"'"
        endif


return cSql

//--------------------------------------------------------------------
/*/{Protheus.doc} RU06R0402
create a JSON structure for an Angular output
@author Maxim Popenker
@since  14/12/2023
@type
@param cKey, Char, key
@version 1.0
/*/
 Function RU06R0402(cKey)
    Local oMainGrid := GetDxModel('main')
    Local oSummary := GetDxModel('summary')
    Local aFields := {}	
    Local oParamJson := STATICCALL(RU99X13_DXMODELS,ReadParams,cKey) 
    Local cStartDate := oParamJson['mv_par01']
    Local cEndDate   := oParamJson['mv_par02']
    Local oDD := GetDxModel('drillDownLink')
    Local lGroup   := oParamJson['mv_par07'] //group contracts: T = yes, F = No
    Local lRubOnly := oParamJson['mv_par08'] //currencies: T = rub only, F = both currencies
    local cVendName := oParamJson['vendorname']
    Local cTitle := STR0016+' '+cVendName+' '+FormatDate(cStartDate)+'-'+FormatDate(cEndDate)

    // Grid configuration parameters
    oMainGrid['columnResizingMode'] 	:= 'widget'
    oMainGrid['columnFixing']['enabled'] 	:= .T.
    oMainGrid['scrolling'] := '{}'
    oMainGrid['stateStoring']['enabled'] := .T.
    oMainGrid['stateStoring']['storageKey'] := 'RU06R04' //+ RetCodUsr()

    //Column definition for the main grid
	Aadd(aFields,{"E2_EMISSAO", STR0017,"date",.T.}) // 17 date
    if lGroup = .F. // not group contracts
        Aadd(aFields,{"F5Q_CODE",   STR0034,"string",.T.}) //34 contract code
        Aadd(aFields,{"CONTRACT",   STR0018,"string",.T.}) //18 contract
    endif
    if lRubOnly = .F. // not only Rubles
        Aadd(aFields,{"DEBIT_D",    STR0021,"number",.T.,'fixedPoint',2}) //21 debit in document currency
        Aadd(aFields,{"CREDIT_D",   STR0022,"number",.T.,'fixedPoint',2}) //22 credit in document currency
        Aadd(aFields,{"CTO_SIMB",   STR0023,"string",.T.}) //23 Currency - short name
        Aadd(aFields,{"Z_UE",       STR0035,"string",.T.}) //23 Currency - U.E.
    endif
    Aadd(aFields,{"DEBIT_H",    STR0024,"number",.T.,'fixedPoint',2}) //24 debit in home (Rub) currency
    Aadd(aFields,{"CREDIT_H",   STR0025,"number",.T.,'fixedPoint',2}) //25 credit in home (Rub) currency
    Aadd(aFields,{"COMMENT",    STR0011,"string",.T.}) //30 comment

    // create JSON structure from columns array
    Fill_json_colums( aFields, @oMainGrid)

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
                    ' "mainTitle": "'+cTitle+'" },'+; // 
            ' "status": "ok",'+;
            ' "ok": "ok",'+;
            ' "statusText": "ok"}'    
  

    FreeObj(oMainGrid)
    FreeObj(oSummary)

Return cRet


/*/{Protheus.doc} RU06R0403
   drill-down processor from main angular report   
   @author Maxim Popenker
   @since  18/12/2023
   @type
   @version 1.0
/*/
function RU06R0403(cColumn, cGridID,cDrillDownID,cKey,cBody)
    Local oData := JSONOBJECT():NEW()
    Local cRet 
    Local cBodyTmp as Character


    cBodyTmp := DecodeUtf8(cBody)
    If cBodyTmp == Nil
        cBodyTmp := cBody
    Endif
    oData:FROMJSON(cBodyTmp)
        
    If cColumn == 'CONTRACT' 
        //  Agreement/Contract
        ShowF5Q(oData['E2_F5QUID'])
    else
        //  other documents    
        ShowTab(oData['RECTAB'],oData['RECNO'])
    Endif 

    FreeObj(oData)
Return cRet

/*/{Protheus.doc} GetVendorName
   get vendor name for report header
   @author Maxim Popenker
   @since  18/12/2023
   @type
   @version 1.0
/*/
static function GetVendorName(cVendor, cDept)
    local cVendorName :=""
    cVendorName := Alltrim(posicione("SA2",1,xFilial("SA2") + cVendor + cDept,"A2_NOME"))
    cVendorName := Strtran(cVendorName,'"',' ')
Return cVendorName

/*/{Protheus.doc} ShowTab
   display document (Invoice/paymemt/bank statement) from drill-down
   @author Maxim Popenker
   @since  18/12/2023
   @type
   @version 1.0
/*/
Static function ShowTab(cTabName,nRecno)

    Local aSaveArea  as Array
    Local aAreaTab   as Array
    Private cCadastro := ""
    Private INCLUI := .F.
    Private ALTERA := .F.

    if nRecno > 0
        aSaveArea := GetArea() 
        aAreaTab := (cTabName)->(GetArea())

        DbSelectArea(cTabName)
        (cTabName)->(DbGoTop())
        (cTabName)->(DbGoTo(nRecno))

        if cTabName = 'F4C'
            FWExecView(STR0033, 'RU06D07', MODEL_OPERATION_VIEW,, { || .T. } )
        else
            AxVisual(cTabName, nRecno, 2)
        endif

        RestArea(aAreaTab)  
        RestArea(aSaveArea) 
    endif
Return

/*/{Protheus.doc} ShowF5Q
   display contract (F5Q) from drill-down
   @author Maxim Popenker
   @since  18/12/2023
   @type
   @version 1.0
/*/
Static function ShowF5Q(cF5q_uid)
    Local aSaveArea  as Array
    Local aAreaF5Q   as Array
    Local cSaveFil := cfilant
    local cFil := xFilial('F5Q')

    if cF5q_uid == Nil .or. cF5q_uid == ''
        Return
    endif

    aSaveArea := GetArea() 
    aAreaF5Q := F5Q->(GetArea())

    DbSelectArea('F5Q')
    DbSetOrder(1)
    F5Q->(DBGoTop())
    if F5Q->(MsSeek(cFil + cF5q_uid))
        cfilant:=cfil
        FWExecView(STR0032, 'RU69T01RUS', MODEL_OPERATION_VIEW,, { || .T. },, 15 ) 
        cfilant:=cSaveFil
    endif

    RestArea(aAreaF5Q)  
    RestArea(aSaveArea) 
return

/*/
{Protheus.doc} AddTotals, 
add Totals data for the grid summary 
@author Maxim Popenker
@since  14/12/2023
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
@since  14/12/2023
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
@since  14/12/2023
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
@since  14/12/2023
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
@since  14/12/2023
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
@since  14/12/2023
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
@since  14/12/2023
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
@since  14/12/2023
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
   @since  14/12/2023
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
   @since  14/12/2023
   @type
   @version 1.0
/*/
static function MyParamBox()
   local aParamBox := {}
   local aRet := {} 
   local lRes
   Local cLoad := 'RU06R04'+ RetCodUsr()

    aAdd(aParamBox,{1,STR0001,StoD("        "),"","","","",60,.T.}) //date from
    aAdd(aParamBox,{1,STR0002,StoD("        "),"","","","",60,.T.}) //date to
    BoxParamAdd(@aParamBox,"A2_COD",STR0003,"SA2",.T.)// vendor code
    BoxParamAdd(@aParamBox,"A2_LOJA",STR0004,"SA2",.T.)  // vendor dept
    BoxParamAdd(@aParamBox,"F5Q_CODE",STR0005,"F5QSE2",.F.) // contract from
    BoxParamAdd(@aParamBox,"F5Q_CODE",STR0006,"F5QSE2",.F.) // contract to
    aAdd(aParamBox,{4,STR0007,.F.,"",50,"",.F.}) //select: group contracts or not
    aAdd(aParamBox,{4,STR0010,.F.,"",50,"",.F.}) //select: currencies
    aAdd(aParamBox,{4,STR0013,.F.,"",50,"",.F.}) //checkbox: add VAT

    lRes := ParamBox(aParamBox,STR0014,@aRet,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/,/*oMainDlg*/,cLoad,.T.,.T.)

Return lRes

/*/{Protheus.doc} BoxParamAdd
   add parameter using DB settings
   @author Maxim Popenker
   @since  14/12/2023
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
                   
