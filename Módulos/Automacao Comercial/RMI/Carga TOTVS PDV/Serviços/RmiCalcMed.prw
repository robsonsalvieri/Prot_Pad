#INCLUDE "TOTVS.CH"

Static cSemaforo	:= ""

/*/{Protheus.doc} RmiCalcMed
Função principal do JOB para calcular a média de processamento de cada tabela
@author  Eduardo Sales
@since   17/06/2024
@version 1.0
/*/
Function RmiCalcMed()

	LjGrvLog("RmiCalcMed", " Inicio ", FWTimeStamp(2) )
	
	If SetSemaforo()
		GetTempoGeral()
		CalcMediaFiliais()
		
		//Aguardo 1 hora para executar novamente
		ClearSemaforo()
	EndIf

	LjGrvLog("RmiCalcMed", " Fim ", FWTimeStamp(2) )

Return

/*/{Protheus.doc} GetTempoGeral

@type    Static Function
@author  Eduardo Sales
@since   17/06/2024
@version 1.0
/*/
Static Function GetTempoGeral()
	
Local cQuery        := ""
Local cAliasQry     := ""
Local nTamFilial    := TamSX3("MIY_FILIAL")[1]
Local nTamPtoInt    := TamSX3("MIY_PTOINT")[1]
Local cTabela       := ""
Local cTabelaAtu	:= ""
Local cTpMedia		:= "GER"
Local cMediaTempo	:= ""
Local nDifMinutos	:= 0
Local nNumRegis		:= 0
Local nDifMinSoma	:= 0

cQuery += " SELECT DISTINCT "																				+ CRLF
cQuery += " MHN.MHN_TABELA AS TABELA, "																		+ CRLF
cQuery += " MHQ_DATGER, MHQ_HORGER, "																		+ CRLF
cQuery += " MIP_DATPRO, MIP_HORPRO "																		+ CRLF
cQuery += " FROM " + RetSqlName("MIP") + " MIP "															+ CRLF
cQuery += " INNER JOIN " + RetSqlName("MHQ") + " MHQ "														+ CRLF
cQuery += " ON MHQ.MHQ_UUID = MIP.MIP_UIDORI "																+ CRLF
cQuery += " AND MHQ.D_E_L_E_T_ = ' ' "																		+ CRLF
cQuery += " INNER JOIN " + RetSqlName("MHN") + " MHN "														+ CRLF
cQuery += " ON MHN.MHN_COD = MIP.MIP_CPROCE "																+ CRLF
cQuery += " AND MHN.D_E_L_E_T_ = ' ' "																		+ CRLF
cQuery += " INNER JOIN " + RetSqlName("MHP") + " MHP "														+ CRLF
cQuery += " ON MHP.MHP_CPROCE = MIP.MIP_CPROCE "															+ CRLF
cQuery += " WHERE 1 = 1 " 																					+ CRLF	
cQuery += " AND MHP.MHP_ATIVO = '1' "																		+ CRLF
cQuery += " AND MIP.MIP_STATUS = '2' "																		+ CRLF
cQuery += " AND MIP.D_E_L_E_T_ = ' ' "																		+ CRLF
cQuery += " AND MHQ.D_E_L_E_T_ = ' ' "																		+ CRLF
cQuery += " AND MHP.D_E_L_E_T_ = ' ' "																		+ CRLF
cQuery += " GROUP BY MHN.MHN_TABELA, MHQ_DATGER, MHQ_HORGER, MIP_DATPRO, MIP_HORPRO "						+ CRLF
cQuery += " ORDER BY MHN.MHN_TABELA "																		+ CRLF

cQuery		:= ChangeQuery(cQuery)
cAliasQry	:= MPSysOpenQuery(cQuery)

DbSelectArea("MIY")
MIY->(DbSetOrder(1)) //MIY_FILIAL + MIY_PTOINT + MIY_TPMED + MIY_TABELA

(cAliasQry)->(dbGoTop())
cTabela := (cAliasQry)->TABELA
cTabelaAtu := cTabela

Do While (cAliasQry)->(!Eof())
	
	If (cAliasQry)->TABELA == cTabelaAtu
		nNumRegis++
		nDifMinSoma += DataHora2Val( StoD((cAliasQry)->MHQ_DATGER) , (cAliasQry)->MHQ_HORGER , StoD((cAliasQry)->MIP_DATPRO) , (cAliasQry)->MIP_HORPRO  )
	Else
		// Camlcula a media de tempo em minutos
		nDifMinutos := nDifMinSoma / nNumRegis
		// Converte em horas
		cMediaTempo := AllTrim(Str(Min2Hrs(nDifMinutos)))

		// Grava a media de tempo na tabela MIY
		If DbSeek(Space(nTamFilial) + Space(nTamPtoInt) + cTpMedia + cTabela)
			RecLock("MIY", .F.)
				MIY->MIY_TEMPO := cMediaTempo
			MIY->(MsUnlock())
		Else
			RecLock("MIY", .T.)
				MIY->MIY_TPMED := cTpMedia
				MIY->MIY_TABELA := cTabela
				MIY->MIY_TEMPO := cMediaTempo
			MIY->(MsUnlock())
		EndIf

		cTabela := (cAliasQry)->TABELA
		cTabelaAtu := cTabela
		nNumRegis := 1
	EndIf	

	(cAliasQry)->(DbSkip())
EndDo

Return

/*/{Protheus.doc} SetSemaforo
Cria semaforo
@type    Static Function
@author  Eduardo Sales
@since   17/06/2024
@version 1.0
/*/
Static Function SetSemaforo()
Local lSemaforo := .T.

ClearSemaforo()	

cSemaforo := "RmiCalcMed" + "_" + cEmpAnt + "_" + cFilAnt

//Trava a execução para evitar que mais de uma sessão faça a execução.
If !LockByName(cSemaforo, .T., .T.)
	LjGrvLog(cSemaforo, "RmiCalcMed | O serviço já esta sendo utilizado por outra instância." )
	lSemaforo := .F.
EndIf

Return lSemaforo

/*/{Protheus.doc} ClearSemaforo
Exclui Semaforo
@type    Static Function
@author  Eduardo Sales
@since   17/06/2024
@version 1.0
/*/
Static Function ClearSemaforo()
	UnLockByName(cSemaforo, .T., .T.)
Return

/*/{Protheus.doc} CalcMediaFiliais
Calcula a media de tempo de integraçao de cada tabela por filial
@type Static Function
@author joao.marcos
@since 17/06/2024
@version v1.0
/*/
Static Function CalcMediaFiliais()
Local AliasQryFil   := ""   as Character
Local cChave        := ""   as Character
Local cFilialProc   := ""   as Character
Local nContProc     := 0    as Numeric
Local nDifMinutos   := 0    as Numeric              // Diferença em minutos entre a data de geraçao e a data de processamento do dado
Local aAreaMIY      := MIY->(GetArea())   as Array

MIY->(dbSetOrder(1)) // 

AliasQryFil := QueryMediaFiliais()

(AliasQryFil)->(dbGoTop())

cChave := AllTrim( (AliasQryFil)->MIP_FILIAL + (AliasQryFil)->MIP_CPROCE )

While (AliasQryFil)->(!EOF())

    If cChave == AllTrim((AliasQryFil)->MIP_FILIAL + (AliasQryFil)->MIP_CPROCE)

        cFilialProc := (AliasQryFil)->MIP_FILIAL
        cTabelaProc := SubStr((AliasQryFil)->MIP_CPROCE,4,3)
        nContProc++
        // Retorna diferença em minutos entre as Datas e Horas de geraçao do dado e do momento em que a Central/PDV pegou o dado
        nDifMinutos += DataHora2Val( StoD((AliasQryFil)->MHQ_DATGER) , (AliasQryFil)->MHQ_HORGER , StoD((AliasQryFil)->MIP_DATPRO) , (AliasQryFil)->MIP_HORPRO  )
    Else
        If MIY->(dbSeek( PadR(cFilialProc, TamSX3("MIP_FILIAL")[1]) + PadR("",TamSX3("MIY_PTOINT")[1]) +;
                         PadR("FIL", TamSX3("MIY_TPMED")[1] ) + PadR(cTabelaProc, TamSX3("MIY_TABELA")[1] ) ) )
            lInclui := .F.
        Else
            lInclui := .T.
        EndIf  

        MIY->(RecLock("MIY",lInclui))
        MIY->MIY_FILIAL := cFilialProc
        MIY->MIY_TPMED  := "FIL"
        MIY->MIY_TABELA := cTabelaProc
        MIY->MIY_TEMPO  := SubStr( StrTran(AllTrim(Str(Min2Hrs(nDifMinutos / nContProc ))),".",":") ,1,5) // Tempo em horas
        MIY->(MsUnLock())

        cChave      := AllTrim( (AliasQryFil)->MIP_FILIAL + (AliasQryFil)->MIP_CPROCE )
        nContProc   := 1
        cFilialProc := (AliasQryFil)->MIP_FILIAL
        cTabelaProc := SubStr((AliasQryFil)->MIP_CPROCE,4,3)
        nDifMinutos := DataHora2Val( StoD((AliasQryFil)->MHQ_DATGER) , (AliasQryFil)->MHQ_HORGER , StoD((AliasQryFil)->MIP_DATPRO) , (AliasQryFil)->MIP_HORPRO  )

    EndIf

    (AliasQryFil)->(dbSkip())

EndDo

RestArea(aAreaMIY)

Return

/*/{Protheus.doc} QueryMediaFiliais
Efetua a query para listar os processos por filial 
@type  Static Function
@author joao.marcos
@since 17/06/2024
@version v1.0
/*/
Static Function QueryMediaFiliais()
Local AliasQryFil   := ""   as Character
Local cQuery        := ""   as Character

cQuery := " SELECT DISTINCT MIP_FILIAL, MIP_CPROCE, MHQ_DATGER, MHQ_HORGER, MIP_DATPRO, MIP_HORPRO "    + CRLF
cQuery += " FROM " + RetSqlName("MIP") + " MIP "                                                        + CRLF
cQuery += " INNER JOIN " + RetSqlName("MHQ") + " MHQ "                                                  + CRLF
cQuery += " ON MHQ_UUID = MIP_UIDORI "                                                                  + CRLF
cQuery += " WHERE MIP_STATUS = '2' "                                                                    + CRLF
cQuery += " AND MIP.D_E_L_E_T_ = ' ' "                                                                  + CRLF
cQuery += " AND MHQ.D_E_L_E_T_ = ' ' "                                                                  + CRLF
cQuery += " ORDER BY MIP_FILIAL, MIP_CPROCE "                                                           + CRLF

cQuery := ChangeQuery(cQuery)
AliasQryFil := MPSysOpenQuery(cQuery)

Return AliasQryFil


/*/{Protheus.doc} SchedDef
Funçao obrigatoria para rotinas que serao executadas via Schedule
@type  Static Function
@author joao.marcos
@since 30/07/2024
@version v1.0
/*/
Static Function SchedDef()

Local aParam  := {}

aParam := { "P"                 ,;  //Tipo R para relatorio P para processo
            "ParamDef"          ,;  //Pergunte do relatorio, caso nao use passar ParamDef
            /*Alias*/           ,;	
            /*Array de ordens*/ ,;
            /*Titulo*/          }

Return aParam
