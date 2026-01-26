#Include "PROTHEUS.CH"
#Include "TBICONN.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} PLMapGrvSche
Schedule padrao para gravação dos pedidos da Integração de acordo
com os STAMPS das entidades da tabela B7E (Integrações)
 
@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Main Function PLMapGrvSche()

    Local cCodOpe := MV_PAR01

    ImpLog(Replicate("*",50),.F.)
    ImpLog("Iniciando Job PLMapGrvSche")
    Conout("Iniciando Job PLMapGrvSche.")

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
    If MayIUseCode("PLMapGrvSche"+cCodOpe)
    
        ProcessIntegra(cCodOpe)

        FreeUsedCode() //Libera semaforo
    Else
        ImpLog("Job PLMapGrvSche"+cCodOpe+" - Já está em execução, aguarde o termino do processamento.")
        Conout("Job PLMapGrvSche"+cCodOpe+" - Já está em execução, aguarde o termino do processamento." ,, .F. ) 
        Return
    EndIf

    //Logs de finalizacao
    ImpLog("Finalizando Job PLMapGrvSche")
    Conout("Finalizando Job PLMapGrvSche.")
    ImpLog(Replicate("*",50),.F.)
    ImpLog("",.F.)    

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Pergunte do Schedule
 
@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
Return { "P","PLSATU",,{},""}


//-----------------------------------------------------------------
/*/{Protheus.doc} ProcessIntegra
Processa as Integrações
 
@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function ProcessIntegra(cOperadora)

    Local cAliasTemp := ""
    Local cQuery := ""
    Local oIntegration := Nil
    Local cCodIntegra := ""
    Local cAliasPrima := ""
    Local cClasseInteg := ""
    Local aResultado := {}

    Default cOperadora := ""

    cAliasTemp := GetNextAlias()
    cQuery := "SELECT B7E.B7E_CODIGO, B7E.B7E_ALIAS, B7E.B7E_CLASTP, B7E.B7E_DESCRI FROM "+RetSQLName("B7E")+" B7E "
	cQuery += " WHERE B7E.B7E_FILIAL = '"+xFilial("B7E")+"'"
	cQuery += "	  AND B7E.B7E_CODOPE = '"+cOperadora+"'"
    cQuery += "	  AND B7E.B7E_ATIVO = '1'"
	cQuery += "   AND B7E.D_E_L_E_T_= ' ' "

	dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)

    If !(cAliasTemp)->(Eof())        
        While !(cAliasTemp)->(Eof())

            cCodIntegra := (cAliasTemp)->B7E_CODIGO
            cDescricao := Alltrim((cAliasTemp)->B7E_DESCRI)
            cAliasPrima := (cAliasTemp)->B7E_ALIAS
            cClasseInteg := Alltrim((cAliasTemp)->B7E_CLASTP)

            ImpLog("Iniciando Processamento da Integração")
            ImpLog("Codigo: "+cCodIntegra, .F.)
            ImpLog("Descrição: "+cDescricao, .F.)

            If !Empty(cClasseInteg) .And. FindClass(cClasseInteg)
                oIntegration := &(cClasseInteg+"():New()")
                oIntegration:Setup(cOperadora, cCodIntegra)
                oIntegration:ProcessDados()
                
                aResultado := oIntegration:GetResult()

                ImpLog("*** Resultado do Processamento:", .F.)
                ImpLog("Quantidade de Pedido Gerado: "+cValToChar(aResultado[1]), .F.)
                ImpLog("Quantidade já Existente: "+cValToChar(aResultado[2]), .F.)
                ImpLog("Quantidade com Falha na Geração: "+cValToChar(aResultado[3]), .F.)
                ImpLog("Quantidade Total de Registros: "+cValToChar(aResultado[4]), .F.)

                FreeObj(oIntegration)
                oIntegration := Nil
            Else
                ImpLog("*** Classe Stamp não cadastrada para a Integração", .F.)
            EndIf

            ImpLog("",.F.)

            (cAliasTemp)->(DbSkip())
        EndDo				
    Else
        ImpLog("*** Nenhuma Integração cadastrada ou ativa.", .F.)
    EndIf
    
    (cAliasTemp)->(DbCloseArea())

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} ImpLog
Imprime Log do Schedule
 
@author Vinicius Queiros Teixeira
@since 20/07/2021
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function ImpLog(cMsg, lDateTime)

    Local cNameLog := "PLMapGrvSche.log"
    Local cDateTime := Substr(DTOS(Date()),7,2)+"/"+Substr(DTOS(Date()),5,2)+"/"+Substr(DTOS(Date()),1,4) + "-" + Time()

    Default cMsg := ""
    Default lDateTime := .T.

    If lDateTime
        PlsPtuLog("["+cDateTime+"] " + cMsg, cNameLog)
    Else
        PlsPtuLog(cMsg, cNameLog)
    EndIf    

Return