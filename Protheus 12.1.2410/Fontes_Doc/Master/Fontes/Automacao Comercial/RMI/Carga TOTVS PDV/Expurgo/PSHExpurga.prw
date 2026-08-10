#include "PROTHEUS.CH"

Static cSemaforo    := ""
Static cThread      := "PSHExpurga - Thread: " + cValToChar(ThreadID())
Static dDataAte     := NIL

/*/{Protheus.doc} RMIExpurga
Efetua a limpeza das tabelas MHQ, MHR e MHL
Funçao chamada pelo Job RMIEnvia (RMIEnvTotvsPDV)
@type  Function
@author joao.marcos
@since 03/06/2024
@version v1.0
@param  cEmp, character, empresa
        cFil, character, filial
/*/
Function PSHExpurga()
Local cQryUID := ""

dDataAte := Iif(Empty(MV_PAR01), Date()-5, Date()-MV_PAR01) // Se parametro nao foi informado considera registros anteriores a 5 dias

LjGrvLog(cThread, " Inicio ", FWTimeStamp(2) )

If SetSemaforo()
    SelectRegExpurgo(@cQryUID)

    ExpurgaMHQ(cQryUID)

    ExpurgaMHL()

    ClearSemaforo()
EndIf

LjGrvLog(cThread, " Fim ", FWTimeStamp(2) )
    
Return

/*/{Protheus.doc} SetSemaforo
Cria semaforo
@type  Static Function
@author joao.marcos
@since 04/06/2024
@version 1.0
/*/
Static Function SetSemaforo()
Local lSemaforo := .T.

cSemaforo := "RMIExpurga" + "_" + cEmpAnt + "_" + cFilAnt

//Trava a execução para evitar que mais de uma sessão faça a execução.
If !LockByName(cSemaforo, .T., .T.)
    LjGrvLog(cSemaforo, "RMIExpurga | O serviço já esta sendo utilizado por outra instância." )
    lSemaforo := .F.
EndIf

Return lSemaforo

/*/{Protheus.doc} ClearSemaforo
Exclui Semaforo
@type  Static Function
@author joao.marcos
@since 04/06/2024
@version 1.0
/*/
Static Function ClearSemaforo()
UnLockByName(cSemaforo, .T., .T.)
Return

/*/{Protheus.doc} SelectRegExpurgo
Forma query para seleçao dos registros a serem deletados
@type  Static Function
@author joao.marcos
@since 03/06/2024
@version 1.0
@param cQryUID, character, Relaçao de UIDs para deleçao
/*/
Static Function SelectRegExpurgo(cQryUID, cAliasExpurgo )
Local cBanco    := AllTrim( Upper( TcGetDB() ) ) 
Local cInstruc1 := Iif("MSSQL" $ cBanco, "CONVERT(datetime, MHQ_DATGER + ' ' + MHQ_HORGER)", Iif("ORACLE" $ cBanco, "TO_DATE(MHQ_DATGER || ' ' || MHQ_HORGER, 'YYYYMMDD HH24MISS')", Iif("POSTGRES" $ cBanco, "TO_TIMESTAMP(MHQ_DATGER || ' ' || MHQ_HORGER, 'YYYYMMDD HH24MISS')", ) ) )

cQryUID   += " SELECT MHQ_UUID "                                                            + CRLF
cQryUID   += " FROM ( "                                                                     + CRLF
cQryUID   += " SELECT MHQ_UUID, "                                                           + CRLF
cQryUID   += "         ROW_NUMBER() OVER ( "                                                + CRLF
cQryUID   += "             PARTITION BY MHQ_FILIAL, MHQ_ORIGEM, MHQ_CPROCE, MHQ_CHVUNI "    + CRLF
cQryUID   += "             ORDER BY " + cInstruc1 + " DESC "                                + CRLF
cQryUID   += "         ) AS rn "                                                            + CRLF
cQryUID   += " FROM " + RetSqlName("MHQ") + " "                                             + CRLF
cQryUID   += " WHERE MHQ_FILIAL = '        ' "                                              + CRLF
cQryUID   += "     AND MHQ_STATUS = '2' "                                                   + CRLF
cQryUID   += "     AND MHQ_DATPRO < '" + DtoS(dDataAte) + "' "                              + CRLF
cQryUID   += "     AND D_E_L_E_T_ = ' ' "                                                   + CRLF
cQryUID   += " ) Elders "                                                                   + CRLF
cQryUID   += " WHERE rn > 1 "                                                               + CRLF
cQryUID   += "     AND NOT EXISTS ( "                                                       + CRLF
cQryUID   += "         SELECT 1 "                                                           + CRLF
cQryUID   += "         FROM " + RetSqlName("MIP") + " MIP "                                 + CRLF
cQryUID   += "         WHERE MIP.MIP_UIDORI = Elders.MHQ_UUID "                             + CRLF
cQryUID   += "     ) "

Return

/*/{Protheus.doc} ExpurgaMHQ
Deleta dos registros antigos da MHQ
@type  Static Function
@author joao.marcos
@since 04/06/2024
@version 1.0
@param cQryUID, character, Relaçao de UIDs para deleçao
/*/
Static Function ExpurgaMHQ(cQryUID)
Local cAliasUUID    := ""
Local nContaReg     := 0
Local cUUIDIn       := ""

LjGrvLog(cThread, " ExpurgaMHQ | Inicio ", FWTimeStamp(2) )

cQryUID     := ChangeQuery(cQryUID)
cAliasUUID  := MPSysOpenQuery(cQryUID)

While (cAliasUUID)->(!EOF())

    nContaReg++

    cUUIDIn += "'" + (cAliasUUID)->MHQ_UUID + "',"

    // Executa o DELETE a cada 100 registros
    If nContaReg == 100
        cUUIDIn := SubStr(cUUIDIn,1,Len(cUUIDIn)-1)
        ExecDelMHQ(cUUIDIn)

        nContaReg   := 0
        cUUIDIn     := ""
    EndIf

    (cAliasUUID)->(dbSkip())

EndDo

If !Empty(cUUIDIn)
    cUUIDIn := SubStr(cUUIDIn,1,Len(cUUIDIn)-1)
    ExecDelMHQ(cUUIDIn)
EndIf

LjGrvLog(cThread, " ExpurgaMHQ | Fim ", FWTimeStamp(2) )

Return

/*/{Protheus.doc} ExecDelMHQ
Deleta dos registros antigos da MHQ
@type  Static Function
@author joao.marcos
@since 10/04/2024
@version 1.0
@param cUUIDIn, character, Relaçao de UIDs para deleçao
/*/
Static Function ExecDelMHQ(cUUIDIn)
Local cInstrucao    := ""

cInstrucao += " DELETE " + RetSqlName("MHQ") + " "
cInstrucao += " WHERE MHQ_UUID IN( " + cUUIDIn + " )"

TCSQLExec( cInstrucao )
Return

/*/{Protheus.doc} ExpurgaMHL
Deleta os registros da MHL que na MIP estejam com status diferente de 3 (erro)
@type  Static Function
@author joao.marcos
@since 04/06/2024
@version 1.0
/*/
Static Function ExpurgaMHL()
Local cInstrucao := ""

LjGrvLog(cThread, " ExpurgaMHL | Inicio ", FWTimeStamp(2) )

cInstrucao += " DELETE " + RetSqlName("MHL") + " "              + CRLF
cInstrucao += " WHERE R_E_C_N_O_ IN( "                          + CRLF
cInstrucao += "     SELECT MHL.R_E_C_N_O_ "                     + CRLF
cInstrucao += "     FROM " + RetSqlName("MHL") + " MHL "        + CRLF
cInstrucao += "     INNER JOIN " + RetSqlName("MIP") + " MIP "  + CRLF
cInstrucao += "     ON MIP_FILIAL = MHL_FILIAL "                + CRLF
cInstrucao += "     AND MIP_UUID = MHL_UIDORI "                 + CRLF
cInstrucao += "     WHERE MIP_STATUS <> '3') "                  + CRLF

TCSQLExec( cInstrucao )

LjGrvLog(cThread, " ExpurgaMHL | Fim ", FWTimeStamp(2) )

Return

/*/{Protheus.doc} SchedDef
Funçao obrigatoria para rotinas que serao executadas via Schedule
@type  Static Function
@author joao.marcos
@since 29/07/2024
@version v1.0
/*/
Static Function SchedDef()

Local aParam  := {}

aParam := { "P"                 ,;  //Tipo R para relatorio P para processo
            "PSHEXPURGA"        ,;  //Pergunte do relatorio, caso nao use passar ParamDef
            /*Alias*/           ,;	
            /*Array de ordens*/ ,;
            /*Titulo*/          }

Return aParam
