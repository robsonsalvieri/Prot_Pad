#INCLUDE "LOCA250.CH" 
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"                                                                                                   
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSMGADD.CH"                                                                                                                  

/*/{PROTHEUS.DOC} LOCA250.PRW
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - LIBERACAO DE EQUIPAMENTOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 21/06/2024
/*/

FUNCTION LOCA250(a,b,c,d,lAuto) 
Local cUser		:= RETCODUSR(SUBSTR(CUSUARIO,7,15))  		// RETORNA O CÓDIGO DO USUÁRIO
Local aArea	   	:= GETAREA() 
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local cQuery 	:= ""
Local cTemps50  := ""
Local cTemps60  := ""
Local lRet      := .T.
Local lUser     := .T.
Local lProcessa := .T.
Local CQRYLEG
Local CSTSANTI  := ST9->T9_STATUS 
Local CSTSNOVO  := ""

Default lAuto   := .F.

    If SELECT("TMPLEG") > 0 
		TMPLEG->( DBCLOSEAREA() ) 
	ENDIF 

	If !lMvLocBac
		CQRYLEG := " SELECT TQY_STATUS FROM "+ RETSQLNAME("TQY") +" TQY WHERE TQY.TQY_STTCTR = '00' AND TQY.D_E_L_E_T_ = ' ' AND TQY.TQY_FILIAL = '"+xFilial("FQY")+"' "	
		TCQUERY CQRYLEG NEW ALIAS "TMPLEG"
		If TMPLEG->(!EOF()) 
			CSTSNOVO := TMPLEG->TQY_STATUS 
		EndIF
	else
		CQRYLEG := " SELECT FQD_STATQY FROM "+ RETSQLNAME("FQD") +" FQD WHERE FQD.FQD_STAREN = '00' AND FQD.D_E_L_E_T_ = ' ' AND FQD.FQD_FILIAL = '"+xFilial("FQD")+"' "	
		TCQUERY CQRYLEG NEW ALIAS "TMPLEG"
		If TMPLEG->(!EOF())
			CSTSNOVO := TMPLEG->FQD_STATQY 
		EndIf
	EndIf
    TMPLEG->( DBCLOSEAREA() ) 

	If empty(ST9->T9_STATUS)
        Help( ,, "LOCA250",, STR0021, 1, 0,,,,,,{STR0022}) //"Inconsistência nos dados."###"Status atual em minuta, não precisa ser liberado."
		lRet := .F.
    EndIF
    
    If ST9->T9_STATUS == LOCA224K() .and. lRet // status 00 disponível
        Help( ,, "LOCA250",, STR0021, 1, 0,,,,,,{STR0005+ST9->T9_STATUS+STR0006}) //"Inconsistência nos dados."###"Este equipamento já está com o status ["###"] - Disponível."
		lRet := .F.
	EndIf

    If lRet
        If !FQ1->(DBSEEK(XFILIAL("FQ1") + cUser + "LOCA250" , .T.)) 	// PROCURA O CÓDIGO DE USUÁRIO NA TABELA DE USUÁRIOS ANALIZADORES 
		    lUser := .F.
        EndIf
    EndIF

	If !lMvLocBac
		TQY->(dbSetOrder(1))
		TQY->(dbGotop())
		While !TQY->(Eof())
			If TQY->TQY_STTCTR == "60"
				cTemps60 := TQY->TQY_STATUS
			EndIF
			If TQY->TQY_STTCTR == "50"
				cTemps50 := TQY->TQY_STATUS
			EndIF
			TQY->(dbSkip())
		EndDo
	Else
		FQD->(dbSetOrder(1))
		FQD->(dbGotop())
		While !FQD->(Eof())
			If FQD->FQD_STAREN == "60"
				cTemps60 := FQD->FQD_STATQY
			EndIF
			If FQD->FQD_STAREN == "50"
				cTemps50 := FQD->FQD_STATQY
			EndIF
			FQD->(dbSkip())
		EndDo
	EndIF

	If lRet
        If (ST9->T9_STATUS <> cTemps60 .and. ST9->T9_STATUS <> cTemps50) .and. !lUser
            Help( ,, "LOCA250",, STR0021, 1, 0,,,,,,{STR0008}) //"Inconsistência nos dados."###"Este equipamento não está com o status NF Retorno gerado."
            lRet := .F.
        EndIf 
    EndIf

	If lRet
		If SELECT("TRBFQ4") > 0
			TRBFQ4->( DBCLOSEAREA() )
		EndIf
        cQuery := " SELECT FQ4_PROJET"      
        cQuery += " FROM " + RetSqlName("FQ4") + " FQ4 " 
        cQuery += " WHERE FQ4.D_E_L_E_T_ = '' "       
		cQuery += " AND FQ4.FQ4_FILIAL = '"+xFilial("FQ4")+"' "
        cQuery += " AND FQ4.FQ4_CODBEM = ? "       
        cQuery += " AND FQ4.FQ4_STATUS = ? "       
        cQuery += " ORDER BY FQ4_DTFIM DESC "
        cQuery := changequery(cQuery) 
        aBindParam := {ST9->T9_CODBEM, ST9->T9_STATUS}
        MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)

        TRBFQ4->(dbGotop())

        If !lAuto
            If MsgYesNo( STR0009 + ALLTRIM(ST9->T9_CODBEM) + STR0010 + ALLTRIM(TRBFQ4->FQ4_PROJET) + STR0011 + ST9->T9_STATUS + "] ?", STR0007 )  //"CONFIRMA A DISPONIBILIZAÇÃO DO EQUIPAMENTO ["###"], VINCULADO AO PROJETO ["###"], STATUS ATUAL ["
                lProcessa := .T.
            Else
                lProcessa := .F.
            EndIF
        Else
            lProcessa := .T.
        EndIf

        If lProcessa
            ST9->(RECLOCK("ST9",.F.)) 
            ST9->T9_STATUS := CSTSNOVO // DISPONIVEL 
            ST9->(MSUNLOCK()) 
            LOCXITU21(CSTSANTI, CSTSNOVO, FQ4->FQ4_PROJET , "", "")
        EndIf

        TRBFQ4->(dbCloseArea())
    EndIF
	
    RestArea(aArea)
Return lRet

