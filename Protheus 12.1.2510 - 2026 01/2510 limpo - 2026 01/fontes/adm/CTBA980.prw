#Include "ctba980.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "fwschedule.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA980
Agendamento para correção pontual de saldos

@author  TOTVS
@since   09/06/2024
@version 12
/*/
//-------------------------------------------------------------------
Function CTBA980()
Local aArea		    := GetArea() as Array
Local dDataIni      := StoD("") as Date
Local dDataFin      := dDataBase-1 as Date
Local lMoedaEsp     := .F. as Logical
Local cThread		:= cValToChar(ThreadID()) as Character
Local cCodUUID      := "" as Character
Local cCurrency     := "" as Character
Local cQuery As Character
Local cAliasAux  := GetNextAlias()
Local nDtIniBanc := 0 as Numeric
Local nDtFimBanc := 0 as Numeric
If LockByName("CTBA980",.T.,.T.)
    CONOUT("--- CTBA980 ["+cThread+"] - "+STR0002+" - "+DtoS(DATE())+" "+Time()+" - "+STR0001+" - "+cFilAnt+" ---") //"Filial" //"Inicio"

    //Validar se a quantidade de dias ou meses é maior que 0
    If Type("MV_PAR02")=="N" .And. MV_PAR02 > 0  

        lMoedaEsp := IIf(MV_PAR03 == 1, .T., .F.) // Moeda especifica
        cCurrency := IIF(lMoedaEsp, MV_PAR04, "ALL")  // Moeda
        cCodUUID  := FwUUIDV4()
        cTpSald   := AllTrim(MV_PAR05) // Tipo de saldo

        // Caso a periodicidade for por meses
        If MV_PAR01 == 1 
            //A busca só deve retroagir até o mês inicial do ano
            //A Query busca os calendarios contabeis dos meses informados no MV_PAR02, que estiver vinculado a moeda, e com o status = 1
            //Caso o numero de meses informado no MV_PAR02 seja maior que o mês atual da dDataBase
           
            dDataIni := FirstDay(MonthSub(dDataBase -1,MV_PAR02))
            dDataFin := LastDay(dDataBase -1)
            //A busca de divergencias é divida por meses
            cQuery := " SELECT CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD, CTG_DTINI, CTG_DTFIM, CTG_STATUS"+CRLF
            cQuery += " FROM " +RetSQLName("CTG") + " CTG "+CRLF 
            cQuery += " LEFT JOIN "+RetSQLName("CTE")+" CTE ON "+CRLF 
            cQuery += " CTG_FILIAL = CTE_FILIAL AND"+CRLF
            cQuery += " CTG_CALEND = CTE_CALEND"+CRLF  
            cQuery += " WHERE"+CRLF 
            cQuery += " CTG_FILIAL = '" + xFilial("CTG") + "'"+CRLF
            cQuery += " AND CTG_DTINI >= '"+DtoS(dDataIni)+"' AND CTG_DTINI <= '"+DtoS(dDataFin)+"' AND CTG_DTFIM <= '"+DtoS(dDataFin)+"'"
            if(lMoedaEsp)
                cQuery += " AND CTE_MOEDA = '"+cCurrency+" '"+CRLF 
            Endif
            cQuery += " AND CTE.D_E_L_E_T_ = ' '"
            cQuery += " AND CTG.D_E_L_E_T_ = ' '"
            cQuery += " AND CTG_STATUS = '1'"
            cQuery += " GROUP BY CTG_FILIAL, CTG_CALEND, CTG_EXERC, CTG_PERIOD,CTG_DTINI, CTG_DTFIM, CTG_STATUS "
            cQuery += " ORDER BY CTG_DTFIM DESC "

            dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasAux, .T., .F.)
            WHile !(cAliasAux)->(Eof())
                nDtIniBanc := (cAliasAux)->CTG_DTINI
                nDtFimBanc := (cAliasAux)->CTG_DTFIM
                if((cAliasAux)->CTG_STATUS == '1')
                    if(nDtIniBanc <= DtoS(dDataBase -1))
                        CTBA965(nDtIniBanc, nDtFimBanc, cCurrency, cCodUUID, .F., cTpSald)
                    Endif
                EndIf    
                (cAliasAux)->(dbSkip()) 
            EndDo
            (cAliasAux)->(dbCloseArea())
        // Caso a periodicidade for por dias
        Else
            dDataIni := dDataBase - MV_PAR02
            dDataFin := dDataBase - 1
            CTBA965(DtoS(dDataIni), DtoS(dDataFin), cCurrency, cCodUUID, .F., cTpSald)
        EndIf

    EndIf

    QLJ->(dbSetOrder(1))
    If QLJ->(dbSeek(xFilial("QLJ")+cCodUUID))
        CTBA190(.T., dDataIni, dDataBase-1, cFilAnt, cFilAnt, cTpSald, lMoedaEsp, cCurrency, .F., " ", "ZZ", cCodUUID)                
    EndIf

    CONOUT("--- CTBA980 ["+cThread+"] - "+STR0003+" - "+DtoS(DATE())+" "+Time()+" - "+STR0001+" - "+cFilAnt+" ---") //"Filial" //"Fim"
EndIf

UnLockByName("CTBA980",.T.,.T.)

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna os parametros no schedule.

@return aReturn			Array com os parametros

@author  TOTVS
@since   09/06/2024
@version 12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
Local aParam  := {} as Array

aParam := { "P",;			//Tipo R para relatorio P para processo
            "CTB980",;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            STR0004,;	    // Título  //"Refaz saldos recorrente"
			,;				//Nome do Relatório
            .T.,;			//Indica se permite que o agendamento possa ser cadastrado como sempre ativo
			.T. }			//Indica que o agendamento pode ser realizado por filiais

Return aParam


