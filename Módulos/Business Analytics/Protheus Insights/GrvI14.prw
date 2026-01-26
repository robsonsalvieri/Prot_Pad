#INCLUDE 'protheus.ch' 

/*/{Protheus.doc} GrvI14Fin
    Função que realiza a gravação dos registros na 
    Tabela I14 - Controle de Msg Smartlink
    @return 
    @author Danilo Santos
    @since 01/06/2023
/*/
Function GrvI14Fin(cAliasDB,nOrderDB,aGrvI14,lUpdate,cHashID)

Local nRecI14 := 0
Default cAliasDB  := ""
Default nOrderDB := 1
Default aGrvI14 := {}
Default lUpdate  := .T.
Default cHashID := ""

DbSelectArea(cAliasDB)
DbSetOrder(nOrderDB) 

If !(cAliasDB)->(MsSeek(SPACE(TAMSX3('I14_FILIAL')[1])+ aGrvI14[1] )) .And. lUpdate     
    //Se não existir, inclui a rotina com os dados padrões
    RecLock("I14",.T.)
        I14->I14_FILIAL	:= SPACE(TAMSX3('I14_FILIAL')[1])
        I14->I14_TRANID	:= aGrvI14[1]  // Transaction ID - 02           
        I14->I14_RACTEN	:= aGrvI14[2]  // RacTenantID - 03              
        I14->I14_MESSID	:= cHashID // Message ID - 04
        I14->I14_MODULO := aGrvI14[3]   // Modulo - 05     
        I14->I14_INSTYP := aGrvI14[4]  // Insight Type - 06 
        I14->I14_MSGRAW := ""  // Message Raw - 07
        I14->I14_DTRESP := Date()  // dateResponse - 08
        I14->I14_COMGRP := aGrvI14[5] // companyGroup - 09
        I14->I14_BRANCH := aGrvI14[6]  // branch - 10
        I14->I14_USERID := aGrvI14[7]  // cUserid - 11
        I14->I14_USERNM := aGrvI14[8]  // cUserName - 12
        I14->I14_READ   := aGrvI14[9]  //read - 13
        I14->I14_RDDATE := Ctod("")  //readDate - 14 
        I14->I14_USRIDR := ""  // userIdRead - 15
        I14->I14_REQTYP := aGrvI14[10]  //requestType - 16
        I14->I14_CSTAT  := aGrvI14[11]  //cStat - 17
    MsUnlock()
    (cAliasDB)->(DbCloseArea())
    
ElseIf (cAliasDB)->(MsSeek(SPACE(TAMSX3('I14_FILIAL')[1]) + aGrvI14[1] )) .And. !lUpdate .And. lower(aGrvI14[4]) == "financeiro"
    RecLock("I14",.F.)
        I14->I14_RACTEN	:= aGrvI14[2]  //RacTenantId        
        I14->I14_MSGRAW := aGrvI14[6]  // Message Raw - 07
        I14->I14_CSTAT  := aGrvI14[16] //Status
    MsUnlock() 
    (cAliasDB)->(DbCloseArea())
elseif !lUpdate
    If (aGrvI14[15] <> "PER") .and. !(lower(aGrvI14[5]) == 'financialforecast') 
        //Consummer retorna mas se nao existir na tabela , grava um registro na tabela I14 
        RecLock("I14",.T.)
            I14->I14_FILIAL	:= SPACE(TAMSX3('I14_FILIAL')[1]) //Filial - 01
            I14->I14_TRANID	:= aGrvI14[1]  // Transaction ID - 02           
            I14->I14_RACTEN	:= aGrvI14[2]  // RacTenantID - 03              
            I14->I14_MESSID	:= aGrvI14[3]  // Message ID - 04
            I14->I14_MODULO := aGrvI14[4]  // Modulo - 05     
            I14->I14_INSTYP := aGrvI14[5]  // Insight Type - 06 
            I14->I14_MSGRAW := aGrvI14[6]  // Message Raw - 07
            I14->I14_DTRESP := aGrvI14[7] // dateResponse - 08
            I14->I14_COMGRP := aGrvI14[8] // companyGroup - 09
            I14->I14_BRANCH := aGrvI14[9]  // branch - 10
            I14->I14_USERID := aGrvI14[10]  // cUserid - 11
            I14->I14_USERNM := aGrvI14[11]  // cUserName - 12
            I14->I14_READ   := aGrvI14[12]  //read - 13
            I14->I14_RDDATE := aGrvI14[13] //readDate - 14 
            I14->I14_USRIDR := aGrvI14[14]  // userIdRead - 15
            I14->I14_REQTYP := aGrvI14[15]  //requestType - 16
            I14->I14_CSTAT  := aGrvI14[16]  //cStat - 17
        MsUnlock()   
        (cAliasDB)->(DbCloseArea())
    ElseIf aGrvI14[15] == "PER"
        DbSelectArea(cAliasDB)
        dBSetOrder(2)
        nRecI14 := VldTenant(aGrvI14[2]) //nRecI14
        
        If nRecI14 == 0 
            //Consummer retorna mas se nao existir na tabela , grava um registro na tabela I14 
            RecLock("I14",.T.)
                I14->I14_FILIAL	:= SPACE(TAMSX3('I14_FILIAL')[1]) //Filial - 01
                I14->I14_TRANID	:= aGrvI14[1]  // Transaction ID - 02           
                I14->I14_RACTEN	:= aGrvI14[2]  // RacTenantID - 03              
                I14->I14_MESSID	:= aGrvI14[3]  // Message ID - 04
                I14->I14_MODULO := aGrvI14[4]  // Modulo - 05     
                I14->I14_INSTYP := aGrvI14[5]  // Insight Type - 06 
                I14->I14_MSGRAW := aGrvI14[6]  // Message Raw - 07
                I14->I14_DTRESP := aGrvI14[7] // dateResponse - 08
                I14->I14_COMGRP := aGrvI14[8] // companyGroup - 09
                I14->I14_BRANCH := aGrvI14[9]  // branch - 10
                I14->I14_USERID := aGrvI14[10]  // cUserid - 11
                I14->I14_USERNM := aGrvI14[11]  // cUserName - 12
                I14->I14_READ   := aGrvI14[12]  //read - 13
                I14->I14_RDDATE := aGrvI14[13] //readDate - 14 
                I14->I14_USRIDR := aGrvI14[14]  // userIdRead - 15
                I14->I14_REQTYP := aGrvI14[15]  //requestType - 16
                I14->I14_CSTAT  := aGrvI14[16]  //cStat - 17
            MsUnlock()
            I14->(dbCloseArea())
            (cAliasDB)->(DbCloseArea())
        else
            DbSelectArea(cAliasDB)
            dBSetOrder(2)
            dbGoto(nRecI14)
            RecLock("I14",.F.)
                I14->I14_TRANID	:= aGrvI14[1]  //TransctionId        
                I14->I14_MSGRAW := aGrvI14[6]  // Message Raw - 07  
                I14->I14_DTRESP := Date()
                I14->I14_RDDATE := aGrvI14[13]  
                I14->I14_CSTAT  := aGrvI14[16] 
            MsUnlock()
            I14->(dbCloseArea())
            (cAliasDB)->(DbCloseArea())
        Endif    
    Endif              
EndIf

Return

/*/{Protheus.doc} VldTenant
    Função que retorna se o Tenant esta habilitado para receber os insights
    @return lRet 
    @author Danilo Santos
    @since 01/06/2023
/*/
Function VldTenant(cTenant) 
    
	Local cQuery 		      As Character
 	Local cNextAlias 	      As Character 
    Local nRecI14 := 0 

	Default cTenant := ""
	cNextAlias := GetNextAlias()

	cQuery := "SELECT * "
	cQuery += " FROM " + RetSqlName("I14") + " I14 "
	cQuery += " WHERE "
	cQuery += " I14.I14_FILIAL = '" + SPACE(TAMSX3("I14_FILIAL" )[1]) + "' AND"
	cQuery += " I14.I14_RACTEN = '" + cTenant + "' AND"	//RacTenant
    cQuery += " I14.I14_REQTYP = 'PER' AND"
	cQuery += " I14.I14_CSTAT = '200' AND"
	cQuery += " I14.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cNextAlias, .F.,.T. )

	nRecI14 := (cNextAlias)->R_E_C_N_O_

	(cNextAlias)->(dbCloseArea())

Return nRecI14


/*/{Protheus.doc} ReadAlertsId
    Registra a leitura do alerta na tabela I14
    @return 
    @author Danilo Santos
    @since 12/06/2023
/*/
Function ReadAlertsId(aParamAlert)

Local cQuery 		As Character
Local cNextAlias 	As Character 
Local cAlertFin	    As Character
Local cUpdateFin    As Character
Local oUpdFin := JsonObject():new()
	
	cNextAlias := GetNextAlias()

	cQuery := "SELECT * "
	cQuery += " FROM " + RetSqlName("I14") + " I14 "
	cQuery += " WHERE "
//	cQuery += " I14.I14_FILIAL = '" + xFilial("FK5") + "' AND"
	cQuery += " I14.I14_TRANID = '" + aParamAlert[1] + "' AND"	// requestId	
	cQuery += " I14_INSTYP = 'FinancialAlert' AND"
	cQuery += " I14_REQTYP = 'WAR' AND"
	cQuery += " I14.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cNextAlias, .F.,.T. )

	If (cNextAlias)->(!Eof())
		nRecI14 := (cNextAlias)->R_E_C_N_O_

		DbSelectArea('I14')
		DbSetOrder(1)
		dbgoto(nRecI14)
        cAlertFin := I14->I14_MSGRAW
        oUpdFin:FromJson(cAlertFin)

        oUpdFin['readStatus']  := "True"
        cUpdateFin := oUpdFin:toJSON( )
        

        RecLock("I14",.F.)
            I14->I14_READ   := .T.
            I14->I14_RDDATE := DATE()
            I14->I14_USRIDR := __cUseriD
            I14->I14_USERNM := cUserName
            I14->I14_MSGRAW := cUpdateFin
        MsUnlock()
        I14->(dbCloseArea())

	EndIf

	(cNextAlias)->(dbCloseArea())

Return 
