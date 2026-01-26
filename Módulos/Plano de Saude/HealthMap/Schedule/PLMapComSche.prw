#Include "PROTHEUS.CH"
#Include "TBICONN.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} PLMapComSche
Schedule padrao para comunicar os pedidos pendentes da Integração
 
@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Main Function PLMapComSche()

    Local cCodOpe := MV_PAR01

    ImpLog(Replicate("*",50),.F.)
    ImpLog("Iniciando Job PLMapComSche")
    Conout("Iniciando Job PLMapComSche.")

    BA0->(DbSetOrder(1))
    If Empty(cCodOpe)
        ImpLog("Nao foi informada a Operadora nos parametros da rotina.")
        Conout( "Nao foi informada a Operadora nos parametros da rotina" ,, .F. )     
        Return

    ElseIf !BA0->(MsSeek(xFilial("BA0")+cCodOpe))
        ImpLog("A Operadora informada nao foi encontrada no sistema.")
        Conout( "A Operadora informada nao foi encontrada no sistema." ,, .F. )     
        Return nil
    Endif

    // Trava para não executar o JOB se ja estiver em execucao
    If MayIUseCode("PLMapComSche"+cCodOpe)
    
        ProcessPedidos(cCodOpe)

        FreeUsedCode() //Libera semaforo
    Else
        ImpLog("Job PLMapComSche"+cCodOpe+" - Já está em execução, aguarde o termino do processamento.")
        Conout("Job PLMapComSche"+cCodOpe+" - Já está em execução, aguarde o termino do processamento." ,, .F. ) 
        Return
    EndIf

    //Logs de finalizacao
    ImpLog("Finalizando Job PLMapComSche")
    Conout("Finalizando Job PLMapComSche.")
    ImpLog(Replicate("*",50),.F.)
    ImpLog("",.F.) 

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Pergunte do Schedule
 
@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
Return { "P","PLSATU",,{},""}


//-----------------------------------------------------------------
/*/{Protheus.doc} ProcessPedidos
Processa os pedidos para envio
 
@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function ProcessPedidos(cOperadora, aAutomacao)

    Local cAliasTemp := ""
    Local cQuery := ""
    Local cResultado := ""

    Default cOperadora := ""
    Default aAutomacao := {}

    cAliasTemp := GetNextAlias()
    cQuery := "SELECT B7F.R_E_C_N_O_ RECNO FROM "+RetSQLName("B7F")+" B7F "

    cQuery += " INNER JOIN "+RetSQLName("B7E")+" B7E " 	
	cQuery += "	    ON B7E.B7E_FILIAL = '"+xFilial("B7E")+"'" 
	cQuery += "	    AND B7E.B7E_CODOPE = B7F.B7F_CODOPE "
	cQuery += "	    AND B7E.B7E_CODIGO = B7F.B7F_CODIGO "
	cQuery += "	    AND B7E.B7E_ALIAS = B7F.B7F_ALIAS " 
    cQuery += "	    AND B7E.B7E_ATIVO = '1' "
	cQuery += "	    AND B7E.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE B7F.B7F_FILIAL = '"+xFilial("B7F")+"'"
	cQuery += "	  AND B7F.B7F_CODOPE = '"+cOperadora+"'"
    cQuery += "	  AND (B7F.B7F_STATUS = '0' OR B7F.B7F_STATUS = '2')" // Pendente de Envio e Erro de Envio
	cQuery += "   AND B7F.D_E_L_E_T_ = ' ' "

	dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)
    
    If !(cAliasTemp)->(Eof())
        While !(cAliasTemp)->(Eof())

            B7F->(MsGoTo((cAliasTemp)->RECNO))

            ImpLog("Iniciando Comunicação do Pedido")
            ImpLog("Cod.Integração: "+B7F->B7F_CODIGO, .F.)
            ImpLog("Pedido: "+B7F->B7F_CODPED, .F.)

            cResultado := PLMapConnect(.F., .F., aAutomacao)[2]

            ImpLog("*** Resultado da Comunicação:", .F.)
            ImpLog(cResultado, .F.)
 
            ImpLog("",.F.)

            (cAliasTemp)->(DbSkip())
        EndDo				
    Else
        ImpLog("*** Nenhum pedido encontrado para envio.", .F.)
    EndIf

    (cAliasTemp)->(DbCloseArea())

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} ImpLog
Imprime Log do Schedule
 
@author Vinicius Queiros Teixeira
@since 23/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function ImpLog(cMsg, lDateTime)

    Local cNameLog := "PLMapComSche.log"
    Local cDateTime := Substr(DTOS(Date()),7,2)+"/"+Substr(DTOS(Date()),5,2)+"/"+Substr(DTOS(Date()),1,4) + "-" + Time()

    Default cMsg := ""
    Default lDateTime := .T.

    If lDateTime
        PlsPtuLog("["+cDateTime+"] " + cMsg, cNameLog)
    Else
        PlsPtuLog(cMsg, cNameLog)
    EndIf    

Return