#Include 'TOTVS.ch'
#define OPE_MONIT '0500'
#define SEND_ERROR "3" // Erro de envio
#define PENDING_SEND "1" // Pendente de envio
#define SEND_COMPLETED "2" // Envio finalizado
#define log 'ChatAudit_LOG'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLPTUMONIT - Schedule de monitoramento do chat auditores

@author  sakai
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Function PLPTUMONIT()

    PLSLOGFIL(Replicate("-",100),log)
    PLSLOGFIL(timeLog() + "Iniciando PLPTUMONIT - Resposta Automatica Monitoramento - Empresa/Filial: "+cEmpAnt+"-"+cFilAnt,log)
    PLSLOGFIL('',log)
    
    //Retorna registros com erro
    PLSLOGFIL(timeLog() + "Atualizando registros com erro...",log)
	PLSCOMMIT(qryAjuste())
        
    //Faz o envio dos registros de monitoranto pendente
    PLSLOGFIL(timeLog() + "Buscando registros pendentes...",log)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,qryPendentes()),"TRBIU",.T.,.F.)    

    if !TRBIU->(EOF())
        PLSLOGFIL(timeLog() + "Iniciando envio de registros de monitoramento pendentes:",log)        
        while !TRBIU->(EOF())

            PLSLOGFIL('',log)
            PLSLOGFIL(timeLog() + "Registro BIU_IDSALA: "+TRBIU->BIU_IDSALA + "BIU_IDCHAT: "+TRBIU->BIU_IDCHAT,log)

            BIU->(DBGOTO(TRBIU->R_E_C_N_O_))
            
            BIV->(DbSetOrder(1)) //BIV_FILIAL+BIV_IDSALA
            BIV->(MsSeek(xFilial("BIV")+BIU->BIU_IDSALA))

            jStatus := totvs.protheus.health.plan.unimed.chatauditSendAudit(.F.)
            //Se concluido com sucesso, marca o registro de monitoramento da Operadora 0500 como lido
            if jStatus["status"] == SEND_COMPLETED
                PLSCOMMIT(updStatus(TRBIU->BIU_IDSALA,TRBIU->BIU_IDCHAT))
            endIf
            TRBIU->(DbSkip())
        endDo
    else
        PLSLOGFIL(timeLog() + "Nenhum registro de monitoramento pendente para envio",log)
    endIf
	TRBIU->(dbCloseArea())
    
    PLSLOGFIL('',log)
    PLSLOGFIL(timeLog() + "Finalizando PLPTUMONIT - Resposta Automatica Monitoramento",log)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} timeLog

@author  sakai
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Static Function timeLog()
Return Dtoc(date()) + " " +time() + " - " + cValToChar(ThreadID()) + " - "

//-------------------------------------------------------------------
/*/{Protheus.doc} qryAjuste - Retorna a query que atualiza os 
registros com erro de envio para pendente de envio

@author  sakai
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Static Function qryAjuste()

    Local cSql := ""

    cSql := " UPDATE " + RetsqlName("BIU")
	cSql += " SET BIU_STAPRO = 'P' " //P=Pendente
	cSql += " WHERE BIU_FILIAL = '"+ xFilial("BIU") + "'"
    cSql += " AND BIU_DESMSG = '"+OPE_MONIT+"' "
    cSql += " AND BIU_STAPRO = 'E' " //E=Falha
	cSql += " AND D_E_L_E_T_ = ' ' "

Return cSql

//-------------------------------------------------------------------
/*/{Protheus.doc} qryPendentes - Retorna a query que retorna os 
registros pendentes de envio para o chat auditores

@author  sakai
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Static Function qryPendentes()

    Local cSql := ""

    cSql := " SELECT BIU_IDSALA, BIU_IDCHAT, R_E_C_N_O_ "
    cSql += " FROM " + RetSqlName("BIU") + " BIU "
    cSql += " WHERE BIU_FILIAL = '"+ xFilial("BIU") + "'"
    cSql += " AND BIU_DESMSG = '"+OPE_MONIT+"' "
    cSql += " AND BIU_STAPRO = 'P' " //P=Pendente
    cSql += " AND BIU.D_E_L_E_T_ = ' ' "

Return cSql

//-------------------------------------------------------------------
/*/{Protheus.doc} updStatus - Atualiza o status do registro de 
pedido de monitoramento 

@author  sakai
@version P11
@since   13.06.00
/*/
//-------------------------------------------------------------------
Static Function updStatus(cIdSala,cIdChat)
    
    Local cSql := ""

    cSql := " UPDATE " + RetsqlName("BIU")
	cSql += " SET BIU_STAPRO = 'L' " //L=Recebido Lido
    cSql += " WHERE BIU_FILIAL = '"+ xFilial("BIU") + "'"
    cSql += " AND BIU_IDSALA = '"+cIdSala+"' "
    cSql += " AND BIU_IDCHAT < '"+cIdChat+"' "
    cSql += " AND BIU_ORGMSG = '"+OPE_MONIT+"' "
    cSql += " AND D_E_L_E_T_ = ' ' "

Return cSql

/*/{Protheus.doc} schedDef
Definicao dos perguntes para o botao parametros do schedule
@type function
@version 12.1.2510
@author renan.almeida
@since 17/01/2025
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo.
/*/
Static Function SchedDef()
Return { "P","",,{},""}
