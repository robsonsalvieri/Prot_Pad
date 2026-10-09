#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE ANALITICO_FILIAL              1
#DEFINE ANALITICO_ID                  2
#DEFINE ANALITICO_VERSAO              3
#DEFINE ANALITICO_PERAPU              4
#DEFINE ANALITICO_CPF                 5
#DEFINE ANALITICO_NOME                6
#DEFINE ANALITICO_EVENTO              7
#DEFINE ANALITICO_CODRECEITA          8
#DEFINE ANALITICO_SEQUENCIA           9
#DEFINE ANALITICO_VLRRENDTRIB        10
#DEFINE ANALITICO_VLRRENDTRIB13      11
#DEFINE ANALITICO_VLRPREVOFICIAL     12
#DEFINE ANALITICO_VLRPREVOFICIAL13   13
#DEFINE ANALITICO_VLRCRMEN           14
#DEFINE ANALITICO_VLRCRMEN13         15
#DEFINE ANALITICO_VLRPARC65          16
#DEFINE ANALITICO_VLRPARC65DEC       17
#DEFINE ANALITICO_VLRDIARIAS         18
#DEFINE ANALITICO_VLRAJDCUSTO        19
#DEFINE ANALITICO_VLRINDRESCTR       20
#DEFINE ANALITICO_VLRABONOPEC        21
#DEFINE ANALITICO_VLRRENMOLGRV       22
#DEFINE ANALITICO_VLRRENMOLGRV13     23
#DEFINE ANALITICO_VLRAUXMOR          24
#DEFINE ANALITICO_VLRBOLMEDIC        25
#DEFINE ANALITICO_VLRBOLMEDIC13      26
#DEFINE ANALITICO_VLRJUROSMORA       27
#DEFINE ANALITICO_VLRINSEOUTROS      28
#DEFINE ANALITICO_TPREND             29
#DEFINE ANALITICO_CPFDEP             30
#DEFINE ANALITICO_VLRDED             31
#DEFINE ANALITICO_TPRENDALIM         32
#DEFINE ANALITICO_CPFDEPALIM         33
#DEFINE ANALITICO_VLRDEDALIM         34
#DEFINE ANALITICO_TPPREV             35
#DEFINE ANALITICO_CNPJPREV           36
#DEFINE ANALITICO_VLRDEDPCPREV       37
#DEFINE ANALITICO_VLRDEDPCPREV13     38
#DEFINE ANALITICO_VLRDEDFUNP         39
#DEFINE ANALITICO_VLRDEDFUNP13       40
#DEFINE ANALITICO_TPPROC             41
#DEFINE ANALITICO_NRPROC             42
#DEFINE ANALITICO_CODSUP             43
#DEFINE ANALITICO_PRCINDAPU          44
#DEFINE ANALITICO_PRCVLRRET          45
#DEFINE ANALITICO_PRCVLRJUD          46
#DEFINE ANALITICO_PRCVLACAL          47
#DEFINE ANALITICO_PRCVLAANT          48
#DEFINE ANALITICO_PRCVLSUSP          49
#DEFINE ANALITICO_PRCDEDTPDEDU       50
#DEFINE ANALITICO_PRCDEDVLSUSP       51
#DEFINE ANALITICO_PRCDEDINSCPL       52
#DEFINE ANALITICO_PRCDEDVLFUNP       53
#DEFINE ANALITICO_PRCBENCPFDEP       54
#DEFINE ANALITICO_PRCBENVLSUSP       55
#DEFINE ANALITICO_PLSAUDECNPJ        56
#DEFINE ANALITICO_PLSAUDEREGANS      57
#DEFINE ANALITICO_PLSAUDEVLRTIT      58
#DEFINE ANALITICO_DEPSAUDECPF        59
#DEFINE ANALITICO_DEPSAUDEVLRDEP     60
#DEFINE ANALITICO_REMMEDINDREM       61
#DEFINE ANALITICO_REMMEDCNPJOP       62
#DEFINE ANALITICO_REMMEDREGANS       63
#DEFINE ANALITICO_REMTIDTPINSC       64
#DEFINE ANALITICO_REMTIDNRINSC       65
#DEFINE ANALITICO_REMTIDVLREMB       66
#DEFINE ANALITICO_REMTIDVLRANT       67
#DEFINE ANALITICO_REMDEPCPF          68
#DEFINE ANALITICO_DETDEPTPINSC       69
#DEFINE ANALITICO_DETDEPNRINSC       70
#DEFINE ANALITICO_DETDEPVLREMB       71
#DEFINE ANALITICO_DETDEPVLRANT       72
#DEFINE ANALITICO_FORABA             73
#DEFINE ANALITICO_ABA                74
#DEFINE ANALITICO_PERREF             75
#DEFINE ANALITICO_ORIGEM             76
#DEFINE ANALITICO_RELACAO            77

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFColDirf
@type           Function
@description    Coleta dados para DIRF. Processa T3P (S-1210) e T2G (S-5002).

@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version		1.0

@param          cGroup,    Character, Grupo de empresas (RPCSetEnv).
@param          cFil,      Character, Filial de processamento.
@param          aFil,      Array,     Lista de filiais a processar.
@param          cPeriodo,  Character, Período de apuração base.
@param          cFunc,     Character, CPF específico para filtro (Opcional).
@param          lForca,    Logical,   Flag para forçar reprocessamento.
@param          lLockFree, Logical,   Indica se o sistema realizou o lock e está processando.
@return         Logical,   .T. = sucesso, .F. = erro.
/*/
//---------------------------------------------------------------------
Function TAFColDirf( cGroup as character, cFil as character, aFil as array, cPeriodo as character, cFunc as character, lForca as logical, lLockFree as logical ) as logical
	
    //-----------------------------------------------------------------------
    // Declaração de Variáveis Locais
    //-----------------------------------------------------------------------
    Local a1210       As Array
    Local aAnalitico  As Array
    Local aAreaSMO    As Array
    Local aFilsProc   As Array
    Local aIncons     As Array
    Local aTable      As Array
    
    Local cAlias      As Character
    Local cFilBkp     As Character
    Local cFilProc    As Character
    Local cIdFilCache As Character
    Local cLinkUrl    As Character
    Local cMsgDic     As Character
    Local cPerProc    As Character
    
    Local lLibAcsRel  As Logical
    Local lOk         As Logical
    Local lReproc     As Logical
    
    Local nF          As Numeric
    Local nPag        As Numeric
    Local nPagTot     As Numeric
    Local nTamT8R     As Numeric
    Local nTimeFim    As Numeric
    Local nTimeIni    As Numeric
    Local nTotReg     As Numeric
    Local nX          As Numeric

    //-----------------------------------------------------------------------
    // Inicialização de Parâmetros (Defaults)
    //-----------------------------------------------------------------------
    Default aFil      := {}
    Default cFil      := ""
    Default cFunc     := ""
    Default cGroup    := ""
    Default cPeriodo  := ""
    Default lForca    := .F.
    Default lLockFree := .T.

    //-----------------------------------------------------------------------
    // Inicialização de Variáveis
    //-----------------------------------------------------------------------
    a1210       := {}
    aAnalitico  := {}
    aAreaSMO    := {}
    aFilsProc   := {}
    aIncons     := {}
    aTable      := { "T3P", "T2G" }
    
    cAlias      := ""
    cFilBkp     := ""
    cFilProc    := ""
    cIdFilCache := ""
    cLinkUrl    := "https://tdn.totvs.com/display/TAF/DSERTAF1-39952+DT+-+Duplicidade+planos+de+saude+-+Relatorio+do+s-5002+taf+do+futuro"
    cMsgDic     := ""
    cPerProc    := ""
    
    lLibAcsRel  := .T.
    lOk         := .F.
    lReproc     := FwIsInCallStack( "TafRepDIRF" ) .And. Empty( cFunc )
    
    nF          := 0
    nPag        := 0
    nPagTot     := 0
    nTamT8R     := 0
    nTimeFim    := 0
    nTimeIni    := 0
    nTotReg     := 0
    nX          := 0

    //==============================
    // AMBIENTE
    //==============================
    // Só abre novo ambiente se não houver interface ativa (chamada via Job/Schedule)
    If !Empty( cGroup ) .And. Empty( aFil )
        RPCSetType( 3 )
        RPCSetEnv( cGroup, cFil,,, "TAF", "TAFColDirf" )
        TafConOut( "[TAFColDirf] Ambiente aberto via RPC (Job)." )
    Else
        TafConOut( "[TAFColDirf] Ambiente ja ativo via Interface. RPC ignorado." )
    EndIf

    //=========================================================================
    // VALIDAÇÃO DE TAMANHO DO DICIONÁRIO (T8R_RELACO)
    //=========================================================================
    nTamT8R := GetSX3Cache("T8R_RELACO", "X3_TAMANHO")

    If nTamT8R < 254
        
        cMsgDic := "O campo T8R_RELACO possui tamanho atual de " + cValToChar(nTamT8R) + " caracteres, " + ;
                   "mas o exigido pela DIRF é de 254." + CRLF + CRLF + ;
                   "Acao Necessaria:" + CRLF + ;
                   " - Atualize o dicionario de dados (SX3)." + CRLF + ;
                   " - Isso evita falhas de gravacao e inconsistencias graves."

        If !Empty( cGroup ) .And. Empty( aFil )

            TafConOut( "[TAFColDirf] ERRO FATAL: Dicionario T8R_RELACO desatualizado. Tamanho atual: " + cValToChar(nTamT8R) )

        Else

            cMsgDic += CRLF + CRLF + "Deseja abrir a documentacao oficial no seu navegador agora?"

            If FWAlertNoYes(cMsgDic, "TAF - Validacao de Dicionario")
                ShellExecute("open", cLinkUrl, "", "", 1)
            EndIf

            FWAlertInfo("ATENCAO: O processamento da DIRF foi ABORTADO por seguranca." + CRLF + ;
                        "Nenhum dado da DIRF foi gerado ou alterado no background.", ;
                        "Processo Cancelado")

        EndIf

        If !Empty( cGroup ) .And. Empty( aFil )
            RpcClearEnv()
            TafConOut( "[TAFColDirf] Rodando via Job: Ambiente encerrado via RpcClearEnv." )
        EndIf

        Return .F.
    EndIf

    // Inicia o contador do tempo de processamento
	nTimeIni := Seconds()
    cIdFilCache := UUIDRandomSeq()

    cFilBkp   := cFilAnt 
    aAreaSMO  := SM0->(GetArea())

    If Len(aFil) == 0 .And. FindFunction("FilMatriz") //quando vem via StartJob, pega as filiais com a mesma raiz
        aFil := FilMatriz()
    EndIF 

    If Len(aFil) == 0 .And. !FindFunction("FilMatriz") //se a funcao FilMatriz nao existir, pego somete a filial posicionada
        TafConOut("Função FilMatriz não encontrada, o processamento somente ocorrera na filial " + cFil)
        aAdd(aFil,cFil)
    EndIf 

	TafConOut( "=========================================" )
	TafConOut( "TAFColDirf - INÍCIO" )
	TafConOut( "=========================================" )
	
    //==============================
	// BLOQUEIA RELATÓRIO
	//==============================
	PutMV( "MV_COLDIRF", .F. )

    //Trava o ambiente
    If LockByName("Lock_DIRF",.F.,.T.)

        //==============================
        // PROCESSA CADA TABELA
        //==============================
        For nX := 1 To Len( aTable )

            cAlias := aTable[nX]

            //------------------------------
            // COUNT DE REGISTROS
            //------------------------------
            aFilsProc := getFilsProc(cAlias,cPeriodo,cFunc,lForca,cIdFilCache,aFil)

            // Valida se há registros
            If Len(aFilsProc) == 0
                TafConOut( "[" + cAlias + "] Sem registros a processar" )
                Loop
            EndIf

            nPagTot := Len(aFilsProc)
            TafConOut( "[" + cAlias + "] Total de páginas: " + cValToChar( nPagTot ) )

            For nPag := 1 To nPagTot

                cFilProc := aFilsProc[nPag][1]
                cPerProc := aFilsProc[nPag][2]
                nTotReg  := aFilsProc[nPag][3]
                TafConOut( "[" + cAlias + "] Total de registros: " + cValToChar( nTotReg ) +" - Filial " + cFilProc + " - Periodo " + cPerProc  )
               
                // Limpa arrays da página anterior
                a1210      := {}
                aAnalitico := {}
                aIncons    := {}
                lOk        := .F.

                TafConOut("Posicionando na filial " + cFilProc)
                If SM0->(MsSeek(cEmpAnt+cFilProc))

                    TafConOut("Filial " + cFilProc + " encontrada.")
                    //------------------------------
                    // EXECUTA QUERY E RETORNA ARRAY
                    //------------------------------
                    a1210 := TAFColQry( cAlias, cFilProc, cPerProc, cFunc, lForca )
                    TafConOut( "[" + cAlias + "] Array montado: " + cValToChar( Len( a1210 ) ) + " lote(s)" )

                    //------------------------------
                    // PROCESSA GRIDS
                    //------------------------------
                    For nF := 1 To Len(a1210)
                        TafConOut( "Processando folhas em lote, filial: " + cFilProc + " - lote: " + cValToChar(nF) )
                        TAFinfosGrid( a1210[nF], @aAnalitico, cAlias, cFilProc, cPerProc )

                        TafConOut( "[" + cAlias + "] Analítico gerado: " + cValToChar( Len( aAnalitico ) ) + " registros" )

                        If Len( aAnalitico ) > 0
                            lOk := .F.

                            TafGrvDIRF( aAnalitico, a1210[nF], cAlias, @lOk, @aIncons, .T. , lReproc, aFil, cPeriodo)
                            lReproc :=  .F.
                            aFil := {}
                        Else
                            TafConOut( "[" + cAlias + "] Sem dados analíticos para gravar" )
                        EndIf

                    Next nF
                EndIf

                // Libera a memória
                ASize( a1210, 0 )
                ASize( aAnalitico, 0 )
                ASize( aIncons, 0 )
                a1210       := Nil
                aAnalitico  := Nil
                aIncons     := Nil

            Next nPag 

            // ============================
            // Limpa o cache estático
            // ============================
            TAFCacheFast("CLEAR")

            // Se houve erro, para processamento de outras tabelas
            If !lLibAcsRel
                TafConOut( "[TAFColDirf] Processamento interrompido devido a erros" )
                Exit
            EndIf

            TafConOut( "[" + cAlias + "] Processamento concluído" )

        Next nX

        //==============================
        // LIBERA RELATÓRIO
        //==============================
        If lLibAcsRel
            PutMV( "MV_COLDIRF", .T. )
            TafConOut( "[TAFColDirf] Relatório liberado (MV_COLDIRF = .T.)" )
        Else
            TafConOut( "[TAFColDirf] Relatório mantido bloqueado (erros detectados)" )
        EndIf

        //==============================
        // RELATÓRIO FINAL
        //==============================
        nTimeFim := Seconds()

        TafConOut( "" )
        TafConOut( "=========================================" )
        TafConOut( "TAFColDirf - CONCLUÍDO" )
        TafConOut( "=========================================" )
        TafConOut( "Tempo total: " + Transform( nTimeFim - nTimeIni, "@E 999,999.99" ) + " seg" )
        TafConOut( "=========================================" )
        TafConOut( "" )

        UnLockByName("Lock_DIRF",.F.,.T.)
    Else 
        lLockFree := .F. 
    EndIf 

    //=====================================================================
    // FINALIZACAO DO AMBIENTE
    //=====================================================================
    
    cFilAnt := cFilBkp
    RestArea(aAreaSMO)   

    // Só encerra o ambiente se a rotina NÃO estiver rodando via interface
    // Se estiver no Job (StartJob/Schedule), o ambiente foi aberto via RPC e deve ser fechado.
    // Se estiver na interface (Menu/Wizard), o ambiente já existia e NÃO deve ser fechado.
    If !IsBlind() .And.!Empty( cGroup )
        // Se houver RPCSetEnv no inicio, mas detectamos que ha interface, 
        // apenas limpamos os arquivos, nao a sessao.
        TafConOut( "[TAFColDirf] Rodando via interface: RpcClearEnv ignorado para manter sessao viva." )
    ElseIf !Empty( cGroup )
        RpcClearEnv()
        TafConOut( "[TAFColDirf] Rodando via Job: Ambiente encerrado via RpcClearEnv." )
    EndIf

Return lLibAcsRel

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFColQry
@type           Function
@description    Monta query para índices existentes.

@author         Alexandre de Lima Santos/Denis R. de Oliveira
@since          17/12/2025
@version        1.0

@param          cAlias,   Character, Tabela (T3P ou T2G).
@param          cFil,     Character, Filial de execução.
@param          cPeriodo, Character, Período de apuração.
@param          cFunc,    Character, Filtro de CPF (opcional).
@param          lForca,   Logical,   Indicador de força de reprocessamento.
@return         Array,    Array a1210 montado.
/*/
//---------------------------------------------------------------------
Function TAFColQry( cAlias as character, cFil as character, cPeriodo as character, cFunc as character, lForca as logical ) as array

	Local a1210     as array
    Local aAux      as array 

    Local cAliasQry as character
    Local cBenefi   as character
    Local cCpf      as character
    Local cEvento   as character
    Local cFilReg   as character
    Local cId       as character
    Local cOrder    as character
    Local cPerApu   as character
    Local cQuery    as character
    Local cVersao   as character
    Local cWhere    as character

    Local nProgress as numeric
    Local nQuebra   as numeric
    Local nTamFil   as numeric

    Local oStmt     as object 
	
    Default cAlias   := ""
    Default cFil     := ""
    Default cPeriodo := ""
    Default cFunc    := ""
    Default lForca   := .F.

	// Inicialização
	a1210     := {}
    aAux      := {}

    cAliasQry := ""
    cBenefi   := ""
    cCpf      := ""
    cEvento   := ""
    cFilReg   := ""
    cId       := ""
    cOrder    := ""
    cPerApu   := ""
    cQuery    := ""
    cVersao   := ""
    cWhere    := ""

    nProgress := 0
    nQuebra   := 500
    nTamFil   := 0

    oStmt     := Nil


	TafConOut( "[TAFColQry] Iniciando query para " + cAlias )
	
	//=========================================================================
	// WHERE BASE
	//=========================================================================
	If !Empty(cPeriodo)

        cWhere := " WHERE " + cAlias + "_FILIAL = ? "
        cWhere += " AND " + cAlias + "_PERAPU = ? "

        If !Empty(cFunc)
            cWhere += " AND " + Iif(cAlias=="T3P", "T3P_CPF", "T2G_CPFBEN") + " = ? "
        EndIf

    Else

        cWhere := "WHERE " + cAlias + "_PERAPU >= '202501' "

    EndIf

	cWhere += "  AND " + cAlias + "_ATIVO = '1' "

    If !lForca
	    cWhere += "  AND " + cAlias + "_CHKDIR IN (' ', 'F') "
    EndIf

	cWhere += "  AND " + cAlias + ".D_E_L_E_T_ = ' ' "
	
	If cAlias == "T3P"
		cWhere += "  AND T3P_ORIEVE <> 'S2190' "
	EndIf

	//=========================================================================
	// ORDER BY 
	//=========================================================================
	cOrder      := ( "ORDER BY " + cAlias + "_PERAPU, " + cAlias + "_ID, " + cAlias + "_VERSAO " )
	
    If cAlias == "T3P"
        cQuery := "SELECT "
        cQuery += "T3P_FILIAL, T3P_ID, T3P_VERSAO, T3P_CPF, "
        cQuery += "T3P_PERAPU, T3P_BENEFI, T3P_EVENTO "
    Else
        cQuery := "SELECT "
        cQuery += "T2G_FILIAL, T2G_ID, T2G_VERSAO, T2G_CPFBEN, "
        cQuery += "T2G_PERAPU "
    EndIf

    cQuery += "FROM " + RetSQLName(cAlias) + " " + cAlias + " "
    cQuery += cWhere + " "
    cQuery += cOrder

	//=========================================================================
	// EXECUTA QUERY
	//=========================================================================
	oStmt := FWExecStatement():New( ChangeQuery(cQuery) )

    If !Empty(cPeriodo)

        oStmt:SetString( 1, cFil )
        oStmt:SetString( 2, cPeriodo )
        If !Empty(cFunc)
            oStmt:SetString( 3, cFunc )
        EndIf

    EndIf

    cAliasQry := oStmt:OpenAlias()
	
    //=========================================================================
    // PROCESSA REGISTROS
    //=========================================================================  
    // Consulta o tamanho da filial 1 única vez antes do laço e guarda na memória
    If !Empty( cAliasQry )

        nTamFil := FWSizeFilial() 
        
        (cAliasQry)->(DbGoTop())

        While !(cAliasQry)->(EoF())
            nProgress++

            If (nProgress % nQuebra) == 0   
                aAdd(a1210,aAux)
                aAux := {}
            EndIf     

            //=====================================================================
            // MONTA ESTRUTURA DO ARRAY
            //=====================================================================
            If cAlias == "T3P"

                cFilReg := PadR( AllTrim( ( cAliasQry )->T3P_FILIAL ), nTamFil )
                cId     := AllTrim( ( cAliasQry )->T3P_ID )
                cVersao := AllTrim( ( cAliasQry )->T3P_VERSAO )
                cCpf    := AllTrim( ( cAliasQry )->T3P_CPF )
                cPerApu := AllTrim( ( cAliasQry )->T3P_PERAPU )
                cBenefi := AllTrim( ( cAliasQry )->T3P_BENEFI )
                cEvento := AllTrim( ( cAliasQry )->T3P_EVENTO )

                aAdd( aAux, {;
                    cFilReg,;
                    cId,;
                    cVersao,;
                    cCpf,;
                    cPerApu,;
                    cBenefi,;
                    cEvento;
                } )

            Else

                cFilReg := PadR( AllTrim( ( cAliasQry )->T2G_FILIAL ), nTamFil )
                cId     := AllTrim( ( cAliasQry )->T2G_ID )
                cVersao := AllTrim( ( cAliasQry )->T2G_VERSAO )
                cCpf    := AllTrim( ( cAliasQry )->T2G_CPFBEN )
                cPerApu := AllTrim( ( cAliasQry )->T2G_PERAPU )

                aAdd( aAux, {;
                    cFilReg,;
                    cId,;
                    cVersao,;
                    cCpf,;
                    cPerApu;
                } )

            EndIf
            
            (cAliasQry)->(DbSkip())

        EndDo

        If Len(aAux) > 0 
            aAdd(a1210,aAux)
            aAux := {}
        EndIf 
        
        ( cAliasQry )->( DbCloseArea() )

    EndIf

    // Liberar memória
    If oStmt != Nil
        oStmt:Destroy()
        FreeObj( oStmt )
        oStmt := Nil
    EndIf
	
	TafConOut( "[TAFColQry] Processados " + cValToChar(nProgress) + " registros")

Return a1210

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFinfosGrid
@type           Function
@description    Processa os grids da DIRF com BULK LOADING In-Memory.
                Identifica a tabela origem, aciona o construtor do HashMap
                e despacha os arrays indexados para o processamento logico.
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0
@param          a1210,         Array,     Array base com registros principais do lote.
@param          aAnalitico,    Array,     Array que recebera os dados processados (Referencia).
@param          cTable,        Character, Tabela origem: "T3P" (S-1210) ou "T2G" (S-5002).
@param          cFil,          Character, Filial de processamento.
@param          cPeriodo,      Character, Periodo base de apuracao.
@return         lRet,          Logical,   .T. se executado com sucesso.
/*/
//-------------------------------------------------------------------
Function TAFinfosGrid( a1210 As Array, aAnalitico As Array, cTable As Character, cFil As Character, cPeriodo As Character ) As Logical

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aAliases      As Array
    Local aAliasCtx     As Array
    Local aTabsT2G      As Array
    Local aTabsT3P      As Array

    Local lNeedCtxPai   As Logical
    Local lNeedProcDed  As Logical
    Local lRet          As Logical

    Local nX            As Numeric
    Local nY            As Numeric

    Local oCtxPaiMap    As Object
    Local oHashCtx      As Object
    Local oHashMap      As Object
    Local oPayrollCache As Object
    Local oProcDedMap   As Object
    Local oRelPlanMap   As Object
    Local oRelReembMap  As Object

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default a1210      := {}
    Default aAnalitico := {}
    Default cTable     := ""
    Default cFil       := ""
    Default cPeriodo   := ""

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aAliases      := {}
    aAliasCtx     := {}
    aTabsT2G      := { "T8G", "V61", "V62", "V63", "V64", "V65", "V66", "V67", "V68", "V69", "V6A", "V54", "V50", "V51" }
    aTabsT3P      := { "V6M", "V7U", "V7V", "V7W", "V7X", "V7Y", "V7Z", "V8A", "V8B", "V8C", "V8D", "V8E", "V8F", "V8G" }

    lNeedCtxPai   := .F.
    lNeedProcDed  := .F.
    lRet          := .T.

    nX            := 0
    nY            := 0

    oCtxPaiMap    := Nil
    oHashCtx      := Nil
    oHashMap      := Nil
    oPayrollCache := Nil
    oProcDedMap   := Nil
    oRelPlanMap   := Nil
    oRelReembMap  := Nil

    // Garante que o array de retorno inicie vazio SEM QUEBRAR o ponteiro de referencia (@)
    aSize( aAnalitico, 0 )

    //-----------------------------------------------------------------------
    // PASSO 1: Bulk Loading com HashMap
    //-----------------------------------------------------------------------
    If cTable == "T3P"

        oHashMap      := TAFBulkMap( a1210, aTabsT3P, @aAliases, cFil, cTable )
        lNeedCtxPai   := TAFNeedCtxPai( a1210, oHashMap, cTable, cFil )
        lNeedProcDed  := TAFNeedProc( a1210, oHashMap, cTable, cFil )

        If lNeedProcDed
            oProcDedMap := THashMap():New()
        EndIf

        oPayrollCache := TAFBulkPayroll( a1210, cFil, cPeriodo, oHashMap )

    Else

        oHashMap      := TAFBulkMap( a1210, aTabsT2G, @aAliases, cFil, cTable )
        lNeedCtxPai   := TAFNeedCtxPai( a1210, oHashMap, cTable, cFil )
        lNeedProcDed  := TAFNeedProc( a1210, oHashMap, cTable, cFil )

        If lNeedProcDed
            oProcDedMap := THashMap():New()
        EndIf

    EndIf

    If lNeedCtxPai

        oHashCtx     := TAFBulkMap( a1210, { IIf( cTable == "T3P", "T8E", "T8H" ) }, @aAliasCtx, cFil, cTable )
        oCtxPaiMap   := TAFCtxPMap( a1210, oHashCtx, cTable, cPeriodo )
        oRelPlanMap  := THashMap():New()
        oRelReembMap := THashMap():New()

        TAFClsAlias( @aAliasCtx )

        aSize( aAliasCtx, 0 )

    EndIf

    //-----------------------------------------------------------------------
    // PASSO 2: Processamento em blocos In-Memory
    //-----------------------------------------------------------------------
    TafConOut( "[TAFinfosGrid] PASSO 2: Processamento em blocos..." )

    For nX := 1 To Len( a1210 )

        // Limpeza obrigatoria por evento para evitar vazamento de chave pai/filho
        If oProcDedMap != Nil
            HMClean( oProcDedMap )
        EndIf

        If oRelPlanMap != Nil
            HMClean( oRelPlanMap )
        EndIf

        If oRelReembMap != Nil
            HMClean( oRelReembMap )
        EndIf

        If cTable == "T3P"
            For nY := 1 To Len( aTabsT3P )
                TAFGRID( aTabsT3P[nY], a1210[nX], oHashMap, @aAnalitico, cTable, oPayrollCache, oCtxPaiMap, oProcDedMap, oRelPlanMap, oRelReembMap )
            Next nY
        Else
            For nY := 1 To Len( aTabsT2G )
                TAFGRID( aTabsT2G[nY], a1210[nX], oHashMap, @aAnalitico, cTable, Nil, oCtxPaiMap, oProcDedMap, oRelPlanMap, oRelReembMap )
            Next nY
        EndIf

    Next nX

    //-----------------------------------------------------------------------
    // PASSO 3: Liberando recursos e prevenindo Memory Leaks
    //-----------------------------------------------------------------------
    TafConOut( "[TAFinfosGrid] PASSO 3: Liberando recursos..." )

    TAFClsAlias( @aAliases )

    If oHashMap != Nil
        HMClean( oHashMap )
        FreeObj( oHashMap )
        oHashMap := Nil
    EndIf

    If oHashCtx != Nil
        HMClean( oHashCtx )
        FreeObj( oHashCtx )
        oHashCtx := Nil
    EndIf

    If oCtxPaiMap != Nil
        HMClean( oCtxPaiMap )
        FreeObj( oCtxPaiMap )
        oCtxPaiMap := Nil
    EndIf

    If oPayrollCache != Nil
        HMClean( oPayrollCache )
        FreeObj( oPayrollCache )
        oPayrollCache := Nil
    EndIf

    If oProcDedMap != Nil
        HMClean( oProcDedMap )
        FreeObj( oProcDedMap )
        oProcDedMap := Nil
    EndIf

    If oRelPlanMap != Nil
        HMClean( oRelPlanMap )
        FreeObj( oRelPlanMap )
        oRelPlanMap := Nil
    EndIf

    If oRelReembMap != Nil
        HMClean( oRelReembMap )
        FreeObj( oRelReembMap )
        oRelReembMap := Nil
    EndIf

    TafConOut( "[TAFinfosGrid] =========================================" )
    TafConOut( "[TAFinfosGrid] Processamento concluido" )
    TafConOut( "[TAFinfosGrid] =========================================" )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFBulkMap
@type           Function
@description    Gera um HashMap (In-Memory) com todas as linhas das
                tabelas filhas (Grids) baseadas no lote processado
                utilizando otimizacao de Bulk Select (Clausula IN).

@author         Denis R. de Oliveira
@since          17/12/2025
@version        1.0

@param          a1210,    Array,     Array base com registros principais.
@param          aTables,  Array,     Array com nomes das tabelas.
@param          aAliases, Array,     Array de aliases abertos (Passado por referência).
@param          cFil,     Character, Codigo da Filial para processamento.
@param          cTabPai,  Character, Codigo da tabela PAI.
@return         Object,   THashMap com referencias indexadas de objetos JSON.
/*/
//-------------------------------------------------------------------
Function TAFBulkMap( a1210 As Array, aTables As Array, aAliases As Array, cFil As Character, cTabPai As Character ) As Object
    
    //-----------------------------------------------------------------------
    // Declaracao de Variaveis
    //-----------------------------------------------------------------------
    Local aLines    As Array
    Local aIds      As Array
    Local aStruct   As Array
    Local aFieldPos As Array

    Local cAliasQry As Character
    Local cFilReg   As Character
    Local cIdReg    As Character
    Local cKey      As Character
    Local cQuery    As Character
    Local cTable    As Character
    Local cIdVers   As Character
    Local cVerReg   As Character

    Local jData     As Json

    Local lDummy    As Logical

    Local nPosFil   As Numeric
    Local nPosId    As Numeric
    Local nPosVers  As Numeric
    Local nRecCount As Numeric
    Local nX        As Numeric
    Local nY        As Numeric

    Local oHashMap  As Object
    Local oIdsMap   As Object
    Local oReqVers  As Object
    Local oStmt     As Object
    
    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default a1210       := {}
    Default aTables     := {}
    Default aAliases    := {}
    Default cFil        := ""
    Default cTabPai     := ""
    
    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis Locais
    //-----------------------------------------------------------------------
    aLines      := {}
    aIds        := { "_DUMMY_" }
    aStruct     := {}
    aFieldPos   := {}

    cAliasQry   := ""
    cFilReg     := ""
    cIdReg      := ""
    cKey        := ""
    cQuery      := ""
    cTable      := ""
    cIdVers     := ""
    cVerReg     := ""

    jData       := Nil

    lDummy      := .F.

    nPosFil     := 0
    nPosId      := 0
    nPosVers    := 0
    nRecCount   := 0
    nX          := 0
    nY          := 0
    
    oHashMap    := THashMap():New()  
    oIdsMap     := THashMap():New()
    oReqVers    := THashMap():New() 
    oStmt       := Nil

    //-----------------------------------------------------------------------
    // Criacao do Array de IDs para Filtro Bulk (IN Clause)
    //-----------------------------------------------------------------------
    For nX := 1 To Len( a1210 )

        If Len( a1210[nX] ) >= 3

            cIdReg  := AllTrim( a1210[nX][2] )
            cVerReg := AllTrim( a1210[nX][3] )
            cIdVers := cIdReg + "|" + cVerReg

            oReqVers:Set( cIdVers, .T. )

            If !oIdsMap:Get( cIdReg, @lDummy )
                aAdd( aIds, cIdReg )
                oIdsMap:Set( cIdReg, .T. )
            EndIf

        EndIf

    Next nX
    
    //-----------------------------------------------------------------------
    // Extracao Massiva de Dados (Carga do Cache In-Memory)
    //-----------------------------------------------------------------------
    For nY := 1 To Len( aTables )
        
        cTable := aTables[nY]
        
        TafConOut( "[TAFBulkMap] [" + cValToChar( nY ) + "/" + cValToChar( Len( aTables ) ) + "] Carregando " + cTable )

        cQuery := " SELECT * "
        cQuery += " FROM " + RetSQLName( cTable )
        cQuery += " WHERE "
        cQuery += cTable + "_FILIAL = ? "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += " AND " + cTable + "_ID IN (?) "

        // Execucao Orientada a Objeto com SetIn dinamico
        oStmt := FWExecStatement():New( ChangeQuery( cQuery ) )
        oStmt:SetString( 1, cFil )
        oStmt:SetIn( 2, aIds ) // O DBAccess se encarrega de montar IN ('ID1','ID2'...)

        cAliasQry := oStmt:OpenAlias()

        aAdd( aAliases, cAliasQry )
        
        If !Empty( cAliasQry )
            
            ( cAliasQry )->( DbGoTop() )

            // Identifica posicoes fora do Loop = Ganho de velocidade (O(1))
            nPosFil  := ( cAliasQry )->( FieldPos( cTable + "_FILIAL" ) )
            nPosId   := ( cAliasQry )->( FieldPos( cTable + "_ID" ) )
            nPosVers := ( cAliasQry )->( FieldPos( cTable + "_VERSAO" ) )
            
            // Captura a estrutura do alias da query 1 unica vez
            aStruct := ( cAliasQry )->( DbStruct() )

            aFieldPos := {}
            For nX := 1 To Len( aStruct )
                aAdd( aFieldPos, ( cAliasQry )->( FieldPos( aStruct[nX][1] ) ) )
            Next nX

            While !( cAliasQry )->( EoF() )

                // Verifica se essa versão de ID pertence ao lote atual
                cFilReg := AllTrim( ( cAliasQry )->( FieldGet( nPosFil ) ) )
                cIdReg  := AllTrim( ( cAliasQry )->( FieldGet( nPosId ) ) )
                cVerReg := AllTrim( ( cAliasQry )->( FieldGet( nPosVers ) ) )

                cIdVers := cIdReg + "|" + cVerReg
                If !oReqVers:Get( cIdVers, @lDummy )
                    ( cAliasQry )->( DbSkip() )
                    Loop
                EndIf
                
                cKey := cTable + "|" + cFilReg + "|" + cIdReg + "|" + cVerReg
                
                jData := TAFExtract( cAliasQry, cTable, aStruct, aFieldPos )
                
                If jData != Nil
                    
                    If oHashMap:Get( cKey, @aLines )
                        // O registro ja existe no HashMap, basta adicionar por referência
                        aAdd( aLines, jData )
                    Else
                        // Primeiro registro dessa chave, insere direto no HashMap
                        oHashMap:Set( cKey, { jData } )
                    EndIf
                    
                    jData := Nil
                    nRecCount++

                EndIf
                
                ( cAliasQry )->( DbSkip() )

            EndDo

        EndIf   
        
        If oStmt != Nil
            oStmt:Destroy()
            FreeObj( oStmt )
            oStmt := Nil
        EndIf

    Next nY

    HMClean( oIdsMap )
    HMClean( oReqVers )
    FreeObj( oIdsMap )
    FreeObj( oReqVers )
    oIdsMap  := Nil
    oReqVers := Nil

    TafConOut( "[TAFBulkMap] BULK LOAD CONCLUIDO: " + cValToChar( nRecCount ) + " linhas na Memoria" )

Return oHashMap

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFExtract
@type           Function
@description    Extrai campos essenciais da tabela de forma dinâmica
                e os converte em um Objeto JSON In-Memory.
            
@author         Denis R. de Oliveira
@since          17/12/2025
@version        1.0

@param          cAliasQry, Character, Alias da query executada.
@param          cTable,    Character, Nome da tabela origem.
@param          aStruct,   Array,     Estrutura de campos da tabela (DbStruct).
@param          aFieldPos, Array,     Cache das posições dos campos (FieldPos) para performance O(1).
@return         Json,      Objeto contendo os campos e valores extraídos.
/*/
//---------------------------------------------------------------------
Function TAFExtract( cAliasQry As Character, cTable As Character, aStruct As Array, aFieldPos As Array )

    //-------------------------------------------------------------------------
    // Declaração de Variáveis
    //-------------------------------------------------------------------------
    Local cField    As Character
    Local cValType  As Character
    Local jData     As Json
    Local nFieldPos As Numeric
    Local nX        As Numeric
    Local xValue    As Variant

    //-------------------------------------------------------------------------
    // Inicialização de Parâmetros (Defaults)
    //-------------------------------------------------------------------------
    Default cAliasQry := ""
    Default cTable    := ""
    Default aStruct   := {}
    Default aFieldPos := {}

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis Locais
    //-------------------------------------------------------------------------
    cField    := ""
    cValType  := ""
    jData     := JsonObject():New()
    nFieldPos := 0
    nX        := 0
    xValue    := Nil

    //-------------------------------------------------------------------------
    // Extrai campos NA ORDEM da estrutura da tabela para o JSON
    //-------------------------------------------------------------------------
    For nX := 1 To Len( aStruct )

        cField    := aStruct[nX][1]  // Nome do campo
        nFieldPos := aFieldPos[nX]   // Posição do campo

        // Pega valor real do banco (Garantido pelo DbStruct prévio)
        xValue   := ( cAliasQry )->( FieldGet( nFieldPos ) )
        cValType := ValType( xValue )

        If cValType == "C"
            jData[ cField ] := AllTrim( xValue )
        ElseIf cValType == "D"
            jData[ cField ] := DToS( xValue )
        ElseIf cValType == "L"
            jData[ cField ] := IIf( xValue, .T., .F. )
        ElseIf cValType == "N"
            jData[ cField ] := xValue
        Else
            jData[ cField ] := cValToChar( xValue )
        EndIf

    Next nX

Return jData

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGRID
@type           Function
@description    Processa as tabelas detalhe (Grids) de forma otimizada.
                Despacha os dados lidos do HashMap (In-Memory) para as 
                respectivas funcoes de extracao, eliminando o uso de 
                tabelas fisicas temporarias e ganhando performance.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          17/12/2025
@version        1.0

@param          cTable,        Character, Nome da tabela/aba sendo processada.
@param          aInfos,        Array,     Array base com registros principais (T3P/T2G).
@param          oHashMap,      Object,    HashMap contendo os registros do lote.
@param          aAnalitico,    Array,     Array de retorno com os dados calculados (Referencia).
@param          cAlias,        Character, Alias de Origem (S-1210 = T3P / S-5002 = T2G).
@param          oPayrollCache, Object,    Cache O(1) de Rubricas (C91, CMD, T92).
@param          oCtxPaiMap,    Object,    HashMap contendo o contexto do pai lógico.
@param          oRelPlanMap,   Object,    HashMap para relacionamento de Plano de Saúde.
@param          oRelReembMap,  Object,    HashMap para relacionamento de Reembolso.
@return         Logical,       .T. se finalizado com sucesso.
/*/
//-------------------------------------------------------------------
Function TAFGRID( cTable As Character, aInfos As Array, oHashMap As Object, aAnalitico As Array, cAlias As Character, oPayrollCache As Object, oCtxPaiMap As Object, oProcDedMap As Object, oRelPlanMap As Object, oRelReembMap As Object ) As Logical
    
    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aAllLines As Array
    Local cKey      As Character
    Local lRet      As Logical

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default cTable        := ""
    Default aInfos        := {}
    Default oHashMap      := Nil
    Default aAnalitico    := {}
    Default cAlias        := ""
    Default oPayrollCache := Nil
    Default oCtxPaiMap    := Nil
    Default oProcDedMap   := Nil
    Default oRelPlanMap   := Nil
    Default oRelReembMap  := Nil
    
    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aAllLines := {}
    cKey      := ""
    lRet      := .T.
    
    //-----------------------------------------------------------------------
    // BUSCA NO HASHMAP (O(1) - Leitura direta na Memoria)
    //-----------------------------------------------------------------------
    // Chave Mestra = Tabela | Filial | ID | Versao
    cKey := cTable + "|" + AllTrim( aInfos[1] ) + "|" + AllTrim( aInfos[2] ) + "|" + AllTrim( aInfos[3] )
    
    // Busca array com TODAS as linhas JSON deste funcionario nesta aba
    If !oHashMap:Get( cKey, @aAllLines )
        // Retorna silenciosamente. E natural que um funcionario nao tenha dados em todas as abas.
        Return lRet
    EndIf
    
    //-----------------------------------------------------------------------
    // Roteamento de Processamento e Passagem de Parametros por Referencia
    //-----------------------------------------------------------------------
    If cAlias == "T3P"
        Do Case
            Case cTable == "V6M"; TAFFil1200( aAllLines, aInfos, @aAnalitico, aInfos[5], oPayrollCache )
            Case cTable == "V7U"; TAFInV7U( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4] )
            Case cTable == "V7V"; TAFInV7V( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4] )
            Case cTable == "V7W"; TAFInV7W( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4] )
            Case cTable == "V7X"; TAFInV7X( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4] )
            Case cTable == "V7Y"; TAFInV7Y( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4] )
            Case cTable == "V7Z"; TAFInV7Z( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], oProcDedMap )
            Case cTable == "V8A"; TAFInV8A( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], oProcDedMap )
            Case cTable == "V8B"; TAFInV8B( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], oCtxPaiMap, oRelPlanMap )
            Case cTable == "V8C"; TAFInV8C( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], oCtxPaiMap, oRelPlanMap )
            Case cTable == "V8D"; TAFInV8D( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], oCtxPaiMap, oRelReembMap )
            Case cTable == "V8E"; TAFInV8E( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], oCtxPaiMap, oRelReembMap )
            Case cTable == "V8F"; TAFInV8F( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], oCtxPaiMap, oRelReembMap )
            Case cTable == "V8G"; TAFInV8G( aAllLines, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], oCtxPaiMap, oRelReembMap )
        EndCase
    Else
        Do Case
            Case cTable == "T8G"; TAFCon5002( aAllLines, aInfos, @aAnalitico )
            Case cTable == "V61"; TAFInV61( aAllLines, aInfos[5], @aAnalitico, aInfos[4] )
            Case cTable == "V62"; TAFInV62( aAllLines, aInfos[5], @aAnalitico, aInfos[4] )
            Case cTable == "V63"; TAFInV63( aAllLines, aInfos[5], @aAnalitico, aInfos[4] )
            Case cTable == "V64"; TAFInV64( aAllLines, aInfos[5], @aAnalitico, aInfos[4] )
            Case cTable == "V65"; TAFInV65( aAllLines, aInfos[5], @aAnalitico, aInfos[4] )
            Case cTable == "V66"; TAFInV66( aAllLines, aInfos[5], @aAnalitico, aInfos[4], oProcDedMap )
            Case cTable == "V67"; TAFInV67( aAllLines, aInfos[5], @aAnalitico, aInfos[4], oProcDedMap )
            Case cTable == "V68"; TAFInV68( aAllLines, aInfos[5], @aAnalitico, aInfos[4], oCtxPaiMap, oRelPlanMap )
            Case cTable == "V69"; TAFInV69( aAllLines, aInfos[5], @aAnalitico, aInfos[4], oCtxPaiMap, oRelPlanMap )
            Case cTable == "V6A"; TAFInV6A( aAllLines, aInfos[5], @aAnalitico, aInfos[4], oCtxPaiMap, oRelReembMap )
            Case cTable == "V54"; TAFInV54( aAllLines, aInfos[5], @aAnalitico, aInfos[4], oCtxPaiMap, oRelReembMap )
            Case cTable == "V50"; TAFInV50( aAllLines, aInfos[5], @aAnalitico, aInfos[4], oCtxPaiMap, oRelReembMap )
            Case cTable == "V51"; TAFInV51( aAllLines, aInfos[5], @aAnalitico, aInfos[4], oCtxPaiMap, oRelReembMap )
        EndCase
    EndIf

    aAllLines := Nil
    

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFNeedCtxPai
@type           Function
@description    Verifica se o lote atual possui dados de saude/reembolso
                que exijam a resolucao do contexto pai.
@author         Denis R. de Oliveira
@since          25/03/2026
@version        1.0
@param          a1210,    Array,     Array base com registros principais do lote.
@param          oHashMap, Object,    HashMap do bulk ja carregado.
@param          cTable,   Character, Tabela origem: "T3P" ou "T2G".
@param          cFil,     Character, Filial de processamento.
@return         Logical,  .T. se houver dados que dependem de CTXPAI.
/*/
//---------------------------------------------------------------------
Function TAFNeedCtxPai( a1210 As Array, oHashMap As Object, cTable As Character, cFil As Character ) As Logical

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aDummy    As Array

    Local cFilLimpa As Character
    Local cId       As Character
    Local cKeyA     As Character
    Local cKeyB     As Character
    Local cVersao   As Character

    Local lNeedCtx  As Logical

    Local nX        As Numeric

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default a1210       := {}
    Default oHashMap    := Nil
    Default cTable      := ""
    Default cFil        := ""

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aDummy   := {}

    cFilLimpa := AllTrim( cFil )
    cId       := ""
    cKeyA     := ""
    cKeyB     := ""
    cVersao   := ""

    lNeedCtx  := .F.

    nX       := 0

    If ValType( oHashMap ) != "O"
        Return .F.
    EndIf

    For nX := 1 To Len( a1210 )

        If Len( a1210[nX] ) < 3
            Loop
        EndIf

        cId     := AllTrim( a1210[nX][2] )
        cVersao := AllTrim( a1210[nX][3] )

        If cTable == "T3P"
            cKeyA := "V8B|" + cFilLimpa + "|" + cId + "|" + cVersao
            cKeyB := "V8D|" + cFilLimpa + "|" + cId + "|" + cVersao
        Else
            cKeyA := "V68|" + cFilLimpa + "|" + cId + "|" + cVersao
            cKeyB := "V6A|" + cFilLimpa + "|" + cId + "|" + cVersao
        EndIf

        If oHashMap:Get( cKeyA, @aDummy ) .Or. oHashMap:Get( cKeyB, @aDummy )
            lNeedCtx := .T.
            Exit
        EndIf

    Next nX

Return lNeedCtx

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFNeedProc
@type           Function
@description    Verifica se o lote atual possui dados de processo
                que exijam o mapa temporario de relacionamento.
@author         Denis R. de Oliveira
@since          27/03/2026
@version        1.0
@param          a1210,    Array,     Array base com registros principais do lote.
@param          oHashMap, Object,    HashMap do bulk ja carregado.
@param          cTable,   Character, Tabela origem: "T3P" ou "T2G".
@param          cFil,     Character, Filial de processamento.
@return         Logical,  .T. se houver dados que dependem do mapa de processo.
 /*/
//---------------------------------------------------------------------
Function TAFNeedProc( a1210 As Array, oHashMap As Object, cTable As Character, cFil As Character ) As Logical

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aDummy     As Array

    Local cFilLimpa  As Character
    Local cId        As Character
    Local cKeyA      As Character
    Local cKeyB      As Character
    Local cVersao    As Character

    Local lNeedProc  As Logical

    Local nX         As Numeric

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default a1210    := {}
    Default oHashMap := Nil
    Default cTable   := ""
    Default cFil     := ""

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aDummy    := {}

    cFilLimpa := AllTrim( cFil )
    cId       := ""
    cKeyA     := ""
    cKeyB     := ""
    cVersao   := ""

    lNeedProc := .F.

    nX        := 0

    If ValType( oHashMap ) != "O"
        Return .F.
    EndIf

    For nX := 1 To Len( a1210 )

        If Len( a1210[nX] ) < 3
            Loop
        EndIf

        cId     := AllTrim( a1210[nX][2] )
        cVersao := AllTrim( a1210[nX][3] )

        If cTable == "T3P"
            cKeyA := "V7Z|" + cFilLimpa + "|" + cId + "|" + cVersao
            cKeyB := "V8A|" + cFilLimpa + "|" + cId + "|" + cVersao
        Else
            cKeyA := "V66|" + cFilLimpa + "|" + cId + "|" + cVersao
            cKeyB := "V67|" + cFilLimpa + "|" + cId + "|" + cVersao
        EndIf

        If oHashMap:Get( cKeyA, @aDummy ) .Or. oHashMap:Get( cKeyB, @aDummy )
            lNeedProc := .T.
            Exit
        EndIf

    Next nX

Return lNeedProc

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCtxPMap
@type           Function
@description    Monta o mapa do contexto pai (In-Memory) a partir do Bulk 
                ja carregado, otimizando o processamento em lote e
                eliminando acessos redundantes ao banco de dados.

@author         Denis R. de Oliveira
@since          23/03/2026
@version        1.0

@param          a1210,    Array,     Array base com registros principais do lote.
@param          oHashMap, Object,    HashMap do bulk ja carregado em memoria.
@param          cTabPai,  Character, Tabela raiz do lote (T3P ou T2G).
@param          cPeriodo, Character, Periodo base do lote atual.
@return         oCtxMap,  Object,    HashMap populado com chaves do contexto.
/*/
//-------------------------------------------------------------------
Function TAFCtxPMap( a1210 As Array, oHashMap As Object, cTabPai As Character, cPeriodo As Character ) As Object

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aLines    As Array
    
    Local cCtxKeyPrf As Character
    Local cCtxTable  As Character
    Local cFieldPer  As Character
    Local cFieldSeq  As Character
    Local cFilReg    As Character
    Local cId        As Character
    Local cKey       As Character
    Local cPerBase   As Character
    Local cPerRef    As Character
    Local cRef       As Character
    Local cSeqIrc    As Character
    Local cTipo      As Character
    Local cVersao    As Character
    
    Local jLine     As Json
    
    Local nX        As Numeric
    Local nY        As Numeric
    
    Local oCtxMap   As Object

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default a1210    := {}
    Default oHashMap := Nil
    Default cTabPai  := ""
    Default cPeriodo := ""

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aLines    := {}
    
    cCtxKeyPrf := ""
    cCtxTable  := IIf( cTabPai == "T3P", "T8E", "T8H" )
    cFieldPer  := ""
    cFieldSeq  := ""
    cFilReg    := ""
    cId        := ""
    cKey       := ""
    cPerBase   := ""
    cPerRef    := ""
    cRef       := ""
    cSeqIrc    := ""
    cTipo      := ""
    cVersao    := ""
    
    jLine     := Nil
    
    nX        := 0
    nY        := 0
    
    oCtxMap    := THashMap():New()
    cCtxKeyPrf := cCtxTable + "|"
    cFieldPer  := cCtxTable + "_PERREF"
    cFieldSeq  := cCtxTable + "_SEQIRC"
    cPerBase   := IIf( "-" $ cPeriodo, StrTran( cPeriodo, "-", "" ), cPeriodo )

    If Len( cPerBase ) > 6
        cPerBase := Left( cPerBase, 6 )
    EndIf

    //-----------------------------------------------------------------------
    // Processamento Logico (Leitura In-Memory)
    //-----------------------------------------------------------------------
    If ValType( oHashMap ) != "O"
        Return oCtxMap
    EndIf

    For nX := 1 To Len( a1210 )
        
        If Len( a1210[nX] ) < 3
            Loop
        EndIf

        cFilReg := AllTrim( a1210[nX][1] )
        cId     := AllTrim( a1210[nX][2] )
        cVersao := AllTrim( a1210[nX][3] )

        // Busca a tabela pai diretamente
        cKey := cCtxKeyPrf + cFilReg + "|" + cId + "|" + cVersao

        If oHashMap:Get( cKey, @aLines )
            
            For nY := 1 To Len( aLines )
                
                jLine   := aLines[nY]
                cSeqIrc := PadL( AllTrim( cValToChar( jLine[ cFieldSeq ] ) ), 3, "0" )
                cPerRef := AllTrim( cValToChar( jLine[ cFieldPer ] ) )

                // Inline logico da TAFBuildCtxPai
                cRef := IIf( "-" $ cPerRef, StrTran( cPerRef, "-", "" ), cPerRef )
                
                If Empty( cRef )
                    cTipo := "ATU"
                    cRef  := cPerBase
                Else
                    cTipo := "ANT"
                EndIf
                
                If Len( cRef ) > 6
                    cRef := Left( cRef, 6 )
                EndIf

                // Popula o HashMap
                oCtxMap:Set( cFilReg + "|" + cId + "|" + cVersao + "|" + cSeqIrc, ;
                             cTipo + "_" + cRef + "_S" + cSeqIrc )
                             
            Next nY
            
        EndIf
        
    Next nX

Return oCtxMap

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFBuildCtxPai
@type           Function
@description    Monta o contexto canonico do pai logico.
@author         Denis R. de Oliveira
@since          25/03/2026
@version        1.0
@param          cPeriodo, Character, Periodo base do evento atual.
@param          cPerRef,  Character, Periodo de ajuste/perAnt do pai.
@param          cSeqIrc,  Character, Sequencia do infoIRComplem.
@return         Character, Contexto canonico do pai.
 /*/
//---------------------------------------------------------------------
Function TAFBuildCtxPai( cPeriodo As Character, cPerRef As Character, cSeqIrc As Character ) As Character

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local cRef  As Character
    Local cTipo As Character

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default cPeriodo := ""
    Default cPerRef  := ""
    Default cSeqIrc  := ""

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    cRef  := ""
    cTipo := ""

    cPerRef  := AllTrim( cPerRef )
    cPeriodo := AllTrim( cPeriodo )

    cRef := IIf( "-" $ cPerRef, StrTran( cPerRef, "-", "" ), cPerRef )
    If Empty( cRef )
        cTipo := "ATU"
        cRef  := IIf( "-" $ cPeriodo, StrTran( cPeriodo, "-", "" ), cPeriodo )
    Else
        cTipo := "ANT"
    EndIf

    If Len( cRef ) > 6
        cRef := Left( cRef, 6 )
    EndIf

Return cTipo + "_" + cRef + "_S" + PadL( AllTrim( cSeqIrc ), 3, "0" )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFCtxPaiKey
@type           Static Function
@description    Monta a chave de lookup do contexto pai.
@author         Denis R. de Oliveira
@since          25/03/2026
@version        1.0
@param          cFil,    Character, Filial do registro.
@param          cId,     Character, ID do evento.
@param          cVersao, Character, Versao do evento.
@param          cSeqIrc, Character, Sequencia do pai.
@return         Character, Chave canonica do contexto pai.
 /*/
//---------------------------------------------------------------------
Static Function TAFCtxPaiKey( cFil As Character, cId As Character, cVersao As Character, cSeqIrc As Character ) As Character

    Default cFil    := ""
    Default cId     := ""
    Default cVersao := ""
    Default cSeqIrc := ""

Return AllTrim( cFil ) + "|" + AllTrim( cId ) + "|" + AllTrim( cVersao ) + "|" + PadL( AllTrim( cSeqIrc ), 3, "0" )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFV68PKey
@type           Function
@description    Recupera a chave exata do titular de plano de saude na V68
                para fallback controlado da V69.
                So reconstrói o pai quando a cardinalidade do conjunto
                candidato for exatamente 1.
@author         Denis R. de Oliveira
@since          25/03/2026
@version        1.0

@param          cFil,       Character, Filial da V69/V68.
@param          cId,        Character, ID da V69/V68.
@param          cVersao,    Character, Versao da V69/V68.
@param          cCnpjOp,    Character, CNPJ da operadora.
@param          oCtxPaiMap, Object,    Mapa de contextos.
@param          cPeriodo,   Character, Periodo da apuracao.
@return         cSemKey,    Character, Chave exata do titular ou vazio.
 /*/
//---------------------------------------------------------------------
Static Function TAFV68PKey( cFil As Character, cId As Character, cVersao As Character, cCnpjOp As Character, oCtxPaiMap As Object, cPeriodo As Character ) As Character

    Local cAliasQry   As Character
    Local cAns        As Character
    Local cCnpjAux    As Character
    Local cCtxPai     As Character
    Local cFilAux     As Character
    Local cIdAux      As Character
    Local cQuery      As Character
    Local cSemKey     As Character
    Local cSeqIrc     As Character
    Local cVerAux     As Character
    Local nPos        As Numeric
    Local nTamCnpj    As Numeric
    Local nTamFil     As Numeric
    Local nTamId      As Numeric
    Local nTamVer     As Numeric
    Local oStmt       As Object

    Default cFil       := ""
    Default cId        := ""
    Default cVersao    := ""
    Default cCnpjOp    := ""
    Default oCtxPaiMap := Nil
    Default cPeriodo   := ""

    cAliasQry := ""
    cAns      := ""
    cCnpjAux  := ""
    cCtxPai   := ""
    cFilAux   := ""
    cIdAux    := ""
    cQuery    := ""
    cSemKey   := ""
    cSeqIrc   := ""
    cVerAux   := ""
    nPos      := 0
    nTamCnpj  := GetSX3Cache( "V68_CNPJOP", "X3_TAMANHO" )
    nTamFil   := GetSX3Cache( "V68_FILIAL", "X3_TAMANHO" )
    nTamId    := GetSX3Cache( "V68_ID",     "X3_TAMANHO" )
    nTamVer   := GetSX3Cache( "V68_VERSAO", "X3_TAMANHO" )
    oStmt     := Nil

    cFilAux  := PadR( AllTrim( cFil ),            nTamFil,  " " )
    cIdAux   := PadR( AllTrim( cId ),             nTamId,   " " )
    cVerAux  := PadR( AllTrim( cVersao ),         nTamVer,  " " )
    cCnpjAux := PadR( TAFCleanID( cCnpjOp ),      nTamCnpj, " " )

    cQuery := " SELECT V68_REGANS REGANS, V68_SEQIRC SEQIRC "
    cQuery += " FROM " + RetSqlName( "V68" )
    cQuery += " WHERE V68_FILIAL = ? "
    cQuery += "   AND V68_ID     = ? "
    cQuery += "   AND V68_VERSAO = ? "
    cQuery += "   AND V68_CNPJOP = ? "
    cQuery += "   AND D_E_L_E_T_ = ? "

    oStmt := FWExecStatement():New( ChangeQuery( cQuery ) )

    nPos := 0
    nPos++; oStmt:SetString( nPos, cFilAux  )
    nPos++; oStmt:SetString( nPos, cIdAux   )
    nPos++; oStmt:SetString( nPos, cVerAux  )
    nPos++; oStmt:SetString( nPos, cCnpjAux )
    nPos++; oStmt:SetString( nPos, " "      )

    cAliasQry := oStmt:OpenAlias()

    If !Empty( cAliasQry )

        If !( cAliasQry )->( EoF() )

            cAns    := TAFCleanID( ( cAliasQry )->REGANS )
            cSeqIrc := PadL( AllTrim( ( cAliasQry )->SEQIRC ), 3, "0" )

            ( cAliasQry )->( dbSkip() )

            If ( cAliasQry )->( EoF() )
                cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, cFil, cId, cVersao, cSeqIrc, cPeriodo )

                If !Empty( cAns ) .And. !Empty( cCtxPai )
                    cSemKey := "P|" + AllTrim( cCtxPai ) + "|TIT|" + TAFCleanID( cCnpjOp ) + "|" + cAns
                EndIf
            EndIf

        EndIf

        ( cAliasQry )->( dbCloseArea() )
    EndIf

    If ValType( oStmt ) == "O"
        oStmt:Destroy()
        FreeObj( oStmt )
        oStmt := Nil
    EndIf

Return cSemKey

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFCtxPaiSeqIrc
@type           Static Function
@description    Resolve o contexto do pai por FILIAL+ID+VERSAO+SEQIRC.
@author         Denis R. de Oliveira
@since          25/03/2026
@version        1.0
@param          oCtxPaiMap, Object,    HashMap de contexto.
@param          cFil,    Character, Filial do registro.
@param          cId,        Character, ID do evento.
@param          cVersao,    Character, Versao do evento.
@param          cSeqIrc,    Character, Sequencia do pai.
@param          cPeriodo,   Character, Periodo base do evento.
@return         Character, Contexto canonico do pai.
 /*/
//---------------------------------------------------------------------
Static Function TAFCtxPaiSeqIrc( oCtxPaiMap As Object, cFil As Character, cId As Character, cVersao As Character, cSeqIrc As Character, cPeriodo As Character ) As Character

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local cCtxKey As Character
    Local cCtxPai As Character

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default oCtxPaiMap := Nil
    Default cFil       := ""
    Default cId        := ""
    Default cVersao    := ""
    Default cSeqIrc    := ""
    Default cPeriodo   := ""

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    cCtxKey := TAFCtxPaiKey( cFil, cId, cVersao, cSeqIrc )
    cCtxPai := TAFBuildCtxPai( cPeriodo, "", cSeqIrc )

    If ValType( oCtxPaiMap ) == "O"
        oCtxPaiMap:Get( cCtxKey, @cCtxPai )
    EndIf

Return cCtxPai

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFHlthOrph
@type           Function
@description    Monta chave de fallback blindada para plano de saude orfao.
@author         Denis R. de Oliveira
@since          26/03/2026
@version        1.0
@param          cCtxPai, Character, Contexto canonico do pai.
@param          cCnpjOp, Character, CNPJ da operadora do proprio filho.
@param          cRegAns, Character, Registro ANS do proprio filho.
@param          cSeqVinc, Character, Vinculo sequencial do proprio filho.
@return         Character, Prefixo estavel para evitar colapso entre orfaos.
 /*/
//---------------------------------------------------------------------
Function TAFHlthOrph( cCtxPai As Character, cCnpjOp As Character, cRegAns As Character, cSeqVinc As Character ) As Character

    Local cAnsAux     as character
    Local cCnpjAux    as character
    Local cSeqVincAux as character

    Default cCtxPai  := ""
    Default cCnpjOp  := ""
    Default cRegAns  := ""
    Default cSeqVinc := ""

    cAnsAux     := TAFCleanID( cRegAns )
    cCnpjAux    := TAFCleanID( cCnpjOp )
    cSeqVincAux := AllTrim( cSeqVinc )

    cAnsAux     := IIf( Empty( cAnsAux ), "CTXERR", cAnsAux )
    cCnpjAux    := IIf( Empty( cCnpjAux ), "CTXERR", cCnpjAux )
    cSeqVincAux := IIf( Empty( cSeqVincAux ), "CTXERR", cSeqVincAux )

Return "P|" + AllTrim( cCtxPai ) + "|TIT|" + cCnpjAux + "|" + cAnsAux + "|ORPH|" + cSeqVincAux

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFRelReembOrph
@type           Function
@description    Monta chave de fallback blindada para reembolso orfao.
@author         Denis R. de Oliveira
@since          26/03/2026
@version        1.0
@param          cCtxPai, Character, Contexto canonico do pai.
@param          cSequen, Character, Sequencia do proprio filho/cabecalho.
@return         Character, Prefixo estavel para evitar colapso entre orfaos.
 /*/
//---------------------------------------------------------------------
Function TAFRelReembOrph( cCtxPai As Character, cSequen As Character ) As Character

    Local cSequenAux as character

    Default cCtxPai := ""
    Default cSequen := ""

    cSequenAux := AllTrim( cSequen )

    cSequenAux := IIf( Empty( cSequenAux ), "CTXERR", cSequenAux )

Return "P|" + AllTrim( cCtxPai ) + "|CAB|X|CTXERR|CTXERR|ORPH|" + cSequenAux

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFClsAlias
@description	Fecha todos os aliases abertos.
@param			aAliases	- Array com aliases abertos
@return			Nil
@author			Denis R. de Oliveira
@since			28/10/2025
@version		1.0			
/*/
//---------------------------------------------------------------------
Function TAFClsAlias( aAliases as array )

	Local cAlias  as character
	Local nX      as numeric
	Local nClosed as numeric

    Default aAliases := {}
	
	cAlias  := ""
	nX      := 0
	nClosed := 0
	
	If Len( aAliases ) == 0
		TafConOut( "[TAFClsAlias] Nenhum alias para fechar" )
		Return
	EndIf
	
	TafConOut( "[TAFClsAlias] Fechando " + cValToChar( Len( aAliases ) ) + " aliases..." )
	
	For nX := 1 To Len( aAliases )
		
		cAlias := aAliases[nX]
		
		If Select( cAlias ) > 0
			
			( cAlias )->( DbCloseArea() )
			nClosed++
			
		EndIf
		
	Next nX
	
	aAliases := {}
	
	TafConOut( "[TAFClsAlias] Total fechados: " + cValToChar( nClosed ) )
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7U
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7U( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character )

    Local cNome       as character
    Local cReceita    as character
    Local cCpfAux     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines     := {}
    Default cPeriodo   := ""
    Default cTable     := ""
    Default aAnalitico := {}
    Default cIdFunc    := ""
    Default cTipoEve   := ""
    Default cCpf       := ""

    cNome       := ""
    cReceita    := ""
    cCpfAux     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++
        
        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cTable + "_FILIAL" ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cTable + "_FILIAL" ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cTable + "_FILIAL" ], cCpfAux )
        EndIf
        
        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        cReceita := TAFCacheFast( "RECEITA", jLine[ cTable + "_FILIAL" ], jLine[ cTable + "_TPCR" ] )

        aAnalitico[nPosValores][ANALITICO_FILIAL]     := jLine[ cTable + "_FILIAL" ]
        aAnalitico[nPosValores][ANALITICO_ID]         := jLine[ cTable + "_ID" ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]     := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]        := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]       := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]     := 'S-1210'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]  := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_CODRECEITA] := cReceita
        aAnalitico[nPosValores][ANALITICO_TPREND]     := TAFTpRend( jLine[ cTable + "_TPREND" ] )
        aAnalitico[nPosValores][ANALITICO_CPFDEP]	  := jLine[ cTable + "_CPFDEP" ]
        aAnalitico[nPosValores][ANALITICO_VLRDED]	  := jLine[ cTable + "_VLRDED" ]
        aAnalitico[nPosValores][ANALITICO_FORABA]	  := "DEDDEP"
        aAnalitico[nPosValores][ANALITICO_ABA]	      := "02"
        aAnalitico[nPosValores][ANALITICO_PERREF]     := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	  := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]     := jLine[ cTable + "_VERSAO" ]
        
    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV61
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV61( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character )

    Local cNome       as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines     := {}
    Default cPeriodo   := ""
    Default aAnalitico := {}
    Default cCpf       := ""

    cNome       := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++
        
        cNome := TAFCacheFast( "NOME", jLine["V61_FILIAL"], cCpf )

        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )
        
        aAnalitico[nPosValores][ANALITICO_FILIAL]    := jLine["V61_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]        := jLine["V61_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]    := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]       := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]      := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]    := 'S-5002'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA] := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]:= jLine["V61_TPCR"]
        aAnalitico[nPosValores][ANALITICO_TPREND]    := TAFTpRend( jLine["V61_TPREND"] )
        aAnalitico[nPosValores][ANALITICO_CPFDEP]	 := jLine["V61_CPFDEP"]
        aAnalitico[nPosValores][ANALITICO_VLRDED]	 := jLine["V61_VLRDED"]
        aAnalitico[nPosValores][ANALITICO_FORABA]	 := "DEDDEP"
        aAnalitico[nPosValores][ANALITICO_ABA]	     := "02"
        aAnalitico[nPosValores][ANALITICO_PERREF]    := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	 := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]    := jLine["V61_VERSAO"]
        
    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV62
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV62( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character )

    Local cNome       as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines     := {}
    Default cPeriodo   := ""
    Default aAnalitico := {}
    Default cCpf       := ""

    cNome       := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++
        
        cNome := TAFCacheFast( "NOME", jLine["V62_FILIAL"], cCpf )

        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )
        
        aAnalitico[nPosValores][ANALITICO_FILIAL]     := jLine["V62_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]         := jLine["V62_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]     := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]        := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]       := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]     := 'S-5002'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]  := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_CODRECEITA] := jLine["V62_TPCR"]
        aAnalitico[nPosValores][ANALITICO_TPRENDALIM] := TAFTpRend( jLine["V62_TPREND"] )
        aAnalitico[nPosValores][ANALITICO_CPFDEPALIM] := jLine["V62_CPFDEP"]
        aAnalitico[nPosValores][ANALITICO_VLRDEDALIM] := jLine["V62_VLPEN"]
        aAnalitico[nPosValores][ANALITICO_FORABA]     := "PENALI"
        aAnalitico[nPosValores][ANALITICO_ABA]        := "03"
        aAnalitico[nPosValores][ANALITICO_PERREF]     := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]     := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]     := jLine["V62_VERSAO"]
        
    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV63
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV63( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character )

    Local cNome       as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines     := {}
    Default cPeriodo   := ""
    Default aAnalitico := {}
    Default cCpf       := ""

    cNome       := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++
        
        cNome := TAFCacheFast( "NOME", jLine["V63_FILIAL"], cCpf )

        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        aAnalitico[nPosValores][ANALITICO_FILIAL]           := jLine["V63_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]               := jLine["V63_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]           := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]              := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]             := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]           := 'S-5002'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]        := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]       := jLine["V63_TPCR"]
        aAnalitico[nPosValores][ANALITICO_TPPREV]           := TAFTpPrev( jLine["V63_TPREV"] )
        aAnalitico[nPosValores][ANALITICO_CNPJPREV]	        := jLine["V63_INSCPL"]
        aAnalitico[nPosValores][ANALITICO_VLRDEDPCPREV]	    := jLine["V63_VLCOMP"]
        aAnalitico[nPosValores][ANALITICO_VLRDEDPCPREV13]	:= jLine["V63_VLCO13"]
        aAnalitico[nPosValores][ANALITICO_VLRDEDFUNP]	    := jLine["V63_VLPATR"]
        aAnalitico[nPosValores][ANALITICO_VLRDEDFUNP13]	    := jLine["V63_VLPA13"]
        aAnalitico[nPosValores][ANALITICO_FORABA]	        := "PREVCL"
        aAnalitico[nPosValores][ANALITICO_ABA]	            := "04"
        aAnalitico[nPosValores][ANALITICO_PERREF]           := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	        := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]           := jLine["V63_VERSAO"]
        
    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV64
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV64( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character )

    Local cNome       as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines     := {}
    Default cPeriodo   := ""
    Default aAnalitico := {}
    Default cCpf       := ""

    cNome       := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++
        
        cNome := TAFCacheFast( "NOME", jLine["V64_FILIAL"], cCpf )

        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        aAnalitico[nPosValores][ANALITICO_FILIAL]           := jLine["V64_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]               := jLine["V64_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]           := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]              := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]             := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]           := 'S-5002'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]        := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_TPPROC]           := TAFTpProc( jLine["V64_TPPROC"] )
        aAnalitico[nPosValores][ANALITICO_NRPROC]	        := jLine["V64_NRPROC"]
        aAnalitico[nPosValores][ANALITICO_CODSUP]	        := jLine["V64_CODSUP"]
        aAnalitico[nPosValores][ANALITICO_FORABA]	        := "PROCRE"
        aAnalitico[nPosValores][ANALITICO_ABA]	            := "05"
        aAnalitico[nPosValores][ANALITICO_PERREF]           := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	        := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]           := jLine["V64_VERSAO"]
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]       := jLine["V64_TPCR"]
        aAnalitico[nPosValores][ANALITICO_RELACAO]          := AllTrim( TAFTpProc( jLine["V64_TPPROC"] ) + "|" + jLine["V64_NRPROC"] + "|" + jLine["V64_CODSUP"] )

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV65
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV65( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character )

    Local cNome       as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines     := {}
    Default cPeriodo   := ""
    Default aAnalitico := {}
    Default cCpf       := ""

    cNome       := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++
        
        cNome := TAFCacheFast( "NOME", jLine["V65_FILIAL"], cCpf )

        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        aAnalitico[nPosValores][ANALITICO_FILIAL]           := jLine["V65_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]               := jLine["V65_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]           := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]              := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]             := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]           := 'S-5002'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]        := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]       := jLine["V65_TPCR"]
        aAnalitico[nPosValores][ANALITICO_PRCINDAPU]        := TAFTpIndapu( jLine["V65_INDAPU"] )
        aAnalitico[nPosValores][ANALITICO_PRCVLRRET]	    := jLine["V65_VLRRET"]
        aAnalitico[nPosValores][ANALITICO_PRCVLRJUD]	    := jLine["V65_VLRJUD"]
        aAnalitico[nPosValores][ANALITICO_PRCVLACAL]	    := jLine["V65_VLACAL"]
        aAnalitico[nPosValores][ANALITICO_PRCVLAANT]	    := jLine["V65_VLAANT"]
        aAnalitico[nPosValores][ANALITICO_PRCVLSUSP]	    := jLine["V65_VLSUSP"]
        aAnalitico[nPosValores][ANALITICO_FORABA]	        := "PRCVAL"
        aAnalitico[nPosValores][ANALITICO_ABA]	            := "5A"
        aAnalitico[nPosValores][ANALITICO_PERREF]           := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	        := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]           := jLine["V65_VERSAO"]
        aAnalitico[nPosValores][ANALITICO_TPPROC]           := TAFTpProc( jLine["V65_TPPROC"] )
        aAnalitico[nPosValores][ANALITICO_NRPROC]           := jLine["V65_NRPROC"]
        aAnalitico[nPosValores][ANALITICO_CODSUP]           := jLine["V65_CODSUP"]
        aAnalitico[nPosValores][ANALITICO_RELACAO]          := AllTrim( TAFTpProc( jLine["V65_TPPROC"] ) + "|" + jLine["V65_NRPROC"] + "|" + jLine["V65_CODSUP"] + "|" + TAFTpIndapu( jLine["V65_INDAPU"] ) )

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV66
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV66( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character, oProcDedMap as Object )

    Local cDedKey     as character
    Local cNome       as character
    Local cOldDedKey  as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines      := {}
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default oProcDedMap := Nil

    cDedKey      := ""
    cNome        := ""
    cOldDedKey   := ""
    jLine        := Nil
    nI           := 0
    nPosValores  := 0
    nSequen      := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        cNome := TAFCacheFast( "NOME", jLine["V66_FILIAL"], cCpf )
        cDedKey := AllTrim( TAFTpProc( jLine["V66_TPPROC"] ) + "|" + ;
                            jLine["V66_NRPROC"] + "|" + ;
                            jLine["V66_CODSUP"] + "|" + ;
                            TAFTpIndapu( jLine["V66_INDAPU"] ) + "|" + ;
                            TAFTpDed( jLine["V66_TPDEDU"] ) + "|" + ;
                            TAFCleanID( jLine["V66_INSCPL"] ) )

        cOldDedKey := AllTrim( jLine["V66_TPCR"] + "|" + ;
                               jLine["V66_TPPROC"] + "|" + ;
                               jLine["V66_NRPROC"] + "|" + ;
                               jLine["V66_CODSUP"] + "|" + ;
                               jLine["V66_INDAPU"] + "|" + ;
                               jLine["V66_SEQUEN"] + "|" + ;
                               jLine["V66_SEQIRC"] )

        If oProcDedMap != Nil
            oProcDedMap:Set( cOldDedKey, cDedKey )
        EndIf

        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        aAnalitico[nPosValores][ANALITICO_FILIAL]             := jLine["V66_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]                 := jLine["V66_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]             := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]                := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]               := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]             := 'S-5002'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]          := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_TPPROC]             := TAFTpProc( jLine["V66_TPPROC"] )
        aAnalitico[nPosValores][ANALITICO_NRPROC]             := jLine["V66_NRPROC"]
        aAnalitico[nPosValores][ANALITICO_CODSUP]             := jLine["V66_CODSUP"]
        aAnalitico[nPosValores][ANALITICO_PRCINDAPU]          := TAFTpIndapu( jLine["V66_INDAPU"] )
        aAnalitico[nPosValores][ANALITICO_PRCDEDTPDEDU]       := TAFTpDed( jLine["V66_TPDEDU"] )
        aAnalitico[nPosValores][ANALITICO_PRCDEDVLSUSP]	      := jLine["V66_VLSUSP"]
        aAnalitico[nPosValores][ANALITICO_PRCDEDINSCPL]	      := TAFCleanID( jLine["V66_INSCPL"] )
        aAnalitico[nPosValores][ANALITICO_PRCDEDVLFUNP]	      := jLine["V66_VLFUNP"]
        aAnalitico[nPosValores][ANALITICO_FORABA]	          := "PRCDED"
        aAnalitico[nPosValores][ANALITICO_ABA]	              := "5B"
        aAnalitico[nPosValores][ANALITICO_PERREF]             := "" 
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	          := "3"
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]         := jLine["V66_TPCR"]
        aAnalitico[nPosValores][ANALITICO_VERSAO]             := jLine["V66_VERSAO"]
        aAnalitico[nPosValores][ANALITICO_RELACAO]            := cDedKey

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV67
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV67( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character, oProcDedMap as Object )

    Local cDedKey      as character
    Local cNome        as character
    Local cOldDedKey   as character
    Local cOrphKey     as character
    Local jLine        as Json
    Local nI           as numeric
    Local nPosValores  as numeric
    Local nSequen      as numeric

    Default aLines      := {}
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default oProcDedMap := Nil

    cDedKey      := ""
    cNome        := ""
    cOldDedKey   := ""
    cOrphKey     := ""
    jLine        := Nil
    nI           := 0
    nPosValores  := 0
    nSequen      := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        cNome := TAFCacheFast( "NOME", jLine["V67_FILIAL"], cCpf )

        cOldDedKey := AllTrim( jLine["V67_TPCR"] + "|" + ;
                               jLine["V67_TPPROC"] + "|" + ;
                               jLine["V67_NRPROC"] + "|" + ;
                               jLine["V67_CODSUP"] + "|" + ;
                               jLine["V67_INDAPU"] + "|" + ;
                               jLine["V67_SEQV66"] + "|" + ;
                               jLine["V67_SEQIRC"] )

        cDedKey := ""
        If oProcDedMap != Nil
            oProcDedMap:Get( cOldDedKey, @cDedKey )
        EndIf

        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        aAnalitico[nPosValores][ANALITICO_FILIAL]             := jLine["V67_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]                 := jLine["V67_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]             := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]                := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]               := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]             := 'S-5002'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]          := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_PRCBENCPFDEP]       := TAFCleanID( jLine["V67_CPFDEP"] )
        aAnalitico[nPosValores][ANALITICO_PRCBENVLSUSP]	      := jLine["V67_VLSUSP"]
        aAnalitico[nPosValores][ANALITICO_FORABA]	          := "PRCBEN"
        aAnalitico[nPosValores][ANALITICO_ABA]	              := "5C"
        aAnalitico[nPosValores][ANALITICO_PERREF]             := "" 
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	          := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]             := jLine["V67_VERSAO"]
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]         := jLine["V67_TPCR"]
        aAnalitico[nPosValores][ANALITICO_TPPROC]             := TAFTpProc( jLine["V67_TPPROC"] )
        aAnalitico[nPosValores][ANALITICO_NRPROC]             := jLine["V67_NRPROC"]
        aAnalitico[nPosValores][ANALITICO_CODSUP]             := jLine["V67_CODSUP"]
        aAnalitico[nPosValores][ANALITICO_PRCINDAPU]          := TAFTpIndapu( jLine["V67_INDAPU"] )

        If !Empty( cDedKey )
            aAnalitico[nPosValores][ANALITICO_PRCDEDTPDEDU]   := GetTok( cDedKey, 5, "|" )
            aAnalitico[nPosValores][ANALITICO_PRCDEDINSCPL]   := GetTok( cDedKey, 6, "|" )
            aAnalitico[nPosValores][ANALITICO_RELACAO]        := cDedKey + "|" + TAFCleanID( jLine["V67_CPFDEP"] )
        Else
            cOrphKey := "O3_" + PadL( AllTrim( jLine["V67_SEQV66"] ), 3, "0" ) + "_" + PadL( AllTrim( jLine["V67_SEQIRC"] ), 3, "0" )
            aAnalitico[nPosValores][ANALITICO_PRCDEDTPDEDU]   := "ORPHSEQ"
            aAnalitico[nPosValores][ANALITICO_PRCDEDINSCPL]   := cOrphKey
            aAnalitico[nPosValores][ANALITICO_RELACAO]        := AllTrim( TAFTpProc( jLine["V67_TPPROC"] ) + "|" + ;
                                                                            jLine["V67_NRPROC"] + "|" + ;
                                                                            jLine["V67_CODSUP"] + "|" + ;
                                                                            TAFTpIndapu( jLine["V67_INDAPU"] ) + "|" + ;
                                                                            "ORPHSEQ" + "|" + ;
                                                                            cOrphKey + "|" + ;
                                                                            TAFCleanID( jLine["V67_CPFDEP"] ) )
        EndIf

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV68
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelPlanMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV68( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character, oCtxPaiMap as Object, oRelPlanMap as Object )

    Local cAns        as character
    Local cCnpjOp     as character
    Local cCtxPai     as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemKey     as character
    Local cSeqIrc     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines      := {}
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default oCtxPaiMap  := Nil
    Default oRelPlanMap := Nil

    cAns        := ""
    cCnpjOp     := ""
    cCtxPai     := ""
    cMapKey     := ""
    cNome       := ""
    cSemKey     := ""
    cSeqIrc     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        cNome := TAFCacheFast( "NOME", jLine["V68_FILIAL"], cCpf )

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc := PadL( AllTrim( cValToChar( jLine["V68_SEQIRC"] ) ), 3, "0" )

        cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine["V68_FILIAL"], jLine["V68_ID"], jLine["V68_VERSAO"], cSeqIrc, cPeriodo )
        cAns    := TAFCleanID( jLine["V68_REGANS"] )
        cCnpjOp := TAFCleanID( jLine["V68_CNPJOP"] )
        
        cSemKey := "P|" + cCtxPai + "|TIT|" + cCnpjOp + "|" + cAns
        
        cMapKey := "V68|" + cSeqIrc + "|" + cCnpjOp

        aAnalitico[nPosValores][ANALITICO_FILIAL]       := jLine["V68_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]           := jLine["V68_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]       := "S-5002"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_PLSAUDECNPJ]  := jLine["V68_CNPJOP"]
        aAnalitico[nPosValores][ANALITICO_PLSAUDEREGANS]:= jLine["V68_REGANS"]
        aAnalitico[nPosValores][ANALITICO_PLSAUDEVLRTIT]:= jLine["V68_VLRTIT"]
        aAnalitico[nPosValores][ANALITICO_FORABA]       := "PLASAU"
        aAnalitico[nPosValores][ANALITICO_ABA]          := "06"
        aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]       := jLine["V68_VERSAO"]
        aAnalitico[nPosValores][ANALITICO_RELACAO]      := cSemKey

        If ValType( oRelPlanMap ) == "O"
            oRelPlanMap:Set( cMapKey, cSemKey )
        EndIf

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV69
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelPlanMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV69( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character, oCtxPaiMap as Object, oRelPlanMap as Object )

    Local cCtxPai     as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemPai     as character
    Local cSeqIrc     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines      := {}
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default oCtxPaiMap  := Nil
    Default oRelPlanMap := Nil

    cCtxPai     := ""
    cMapKey     := ""
    cNome       := ""
    cSemPai     := ""
    cSeqIrc     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        cNome := TAFCacheFast( "NOME", jLine["V69_FILIAL"], cCpf )

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc := PadL( AllTrim( cValToChar( jLine["V69_SEQIRC"] ) ), 3, "0" )
        cMapKey := "V68|" + cSeqIrc + "|" + TAFCleanID( jLine["V69_CNPJOP"] )
        cSemPai := ""
        cCtxPai := ""

        If ValType( oRelPlanMap ) == "O"
            oRelPlanMap:Get( cMapKey, @cSemPai )
        EndIf

        If Empty( cSemPai )
            cSemPai := TAFV68PKey( jLine["V69_FILIAL"], jLine["V69_ID"], jLine["V69_VERSAO"], jLine["V69_CNPJOP"], oCtxPaiMap, cPeriodo )
        EndIf

        If Empty( cSemPai )
            cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine["V69_FILIAL"], jLine["V69_ID"], jLine["V69_VERSAO"], cSeqIrc, cPeriodo )
            cSemPai := TAFHlthOrph( cCtxPai, jLine["V69_CNPJOP"], "", cSeqIrc )
        EndIf

        aAnalitico[nPosValores][ANALITICO_FILIAL]         := jLine["V69_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]             := jLine["V69_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]         := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]            := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]           := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]         := "S-5002"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]      := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_DEPSAUDECPF]    := jLine["V69_CPFDEP"]
        aAnalitico[nPosValores][ANALITICO_DEPSAUDEVLRDEP] := jLine["V69_VLRDEP"]
        aAnalitico[nPosValores][ANALITICO_FORABA]         := "DEPSAU"
        aAnalitico[nPosValores][ANALITICO_ABA]            := "6A"
        aAnalitico[nPosValores][ANALITICO_PERREF]         := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]         := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]         := jLine["V69_VERSAO"]
        aAnalitico[nPosValores][ANALITICO_RELACAO]        := cSemPai + "|DEP|" + TAFCleanID( jLine["V69_CPFDEP"] )

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV6A
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelReembMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV6A( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character, oCtxPaiMap as Object, oRelReembMap as Object )

    Local cAns        as character
    Local cCnpjOp     as character
    Local cCtxPai     as character
    Local cIndRem     as character
    Local cIndRemFull as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemKey     as character
    Local cSeqIrc     as character
    Local cSequen     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines       := {}
    Default cPeriodo     := ""
    Default aAnalitico   := {}
    Default cCpf         := ""
    Default oCtxPaiMap   := Nil
    Default oRelReembMap := Nil

    cAns        := ""
    cCnpjOp     := ""
    cCtxPai     := ""
    cIndRem     := ""
    cIndRemFull := ""
    cMapKey     := ""
    cNome       := ""
    cSemKey     := ""
    cSeqIrc     := ""
    cSequen     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        cNome := TAFCacheFast( "NOME", jLine["V6A_FILIAL"], cCpf )

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc     := PadL( AllTrim( jLine["V6A_SEQIRC"] ), 3, "0" )
        cCtxPai     := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine["V6A_FILIAL"], jLine["V6A_ID"], jLine["V6A_VERSAO"], cSeqIrc, cPeriodo )
        cIndRemFull := TAFIndRee( jLine["V6A_INDREM"] )
        cIndRem     := Left( AllTrim( cIndRemFull ), 1 )
        cAns        := TAFCleanID( jLine["V6A_REGANS"] )
        cCnpjOp     := TAFCleanID( jLine["V6A_CNPJOP"] )
        cSequen     := AllTrim( cValToChar( jLine["V6A_SEQUEN"] ) )
        cSemKey     := "P|" + cCtxPai + "|CAB|" + cIndRem + "|" + cCnpjOp + "|" + cAns + "|" + cSequen
        cMapKey     := "V6A|" + cSeqIrc + "|" + cSequen

        aAnalitico[nPosValores][ANALITICO_FILIAL]       := jLine["V6A_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]           := jLine["V6A_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]       := "S-5002"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_REMMEDINDREM] := cIndRemFull
        aAnalitico[nPosValores][ANALITICO_REMMEDCNPJOP] := jLine["V6A_CNPJOP"]
        aAnalitico[nPosValores][ANALITICO_REMMEDREGANS] := jLine["V6A_REGANS"]
        aAnalitico[nPosValores][ANALITICO_FORABA]       := "REMMED"
        aAnalitico[nPosValores][ANALITICO_ABA]          := "07"
        aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]       := jLine["V6A_VERSAO"]
        aAnalitico[nPosValores][ANALITICO_RELACAO]      := cSemKey

        If ValType( oRelReembMap ) == "O"
            oRelReembMap:Set( cMapKey, cSemKey )
        EndIf

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV54
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelReembMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV54( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character, oCtxPaiMap as Object, oRelReembMap as Object )

    Local cCtxPai     as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemPai     as character
    Local cSeqIrc     as character
    Local cSequen     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines       := {}
    Default cPeriodo     := ""
    Default aAnalitico   := {}
    Default cCpf         := ""
    Default oCtxPaiMap   := Nil
    Default oRelReembMap := Nil

    cCtxPai     := ""
    cMapKey     := ""
    cNome       := ""
    cSemPai     := ""
    cSeqIrc     := ""
    cSequen     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        cNome := TAFCacheFast( "NOME", jLine["V54_FILIAL"], cCpf )

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc := PadL( AllTrim( jLine["V54_SEQIRC"] ), 3, "0" )
        cSequen := AllTrim( cValToChar( jLine["V54_SEQUEN"] ) )
        cMapKey := "V6A|" + cSeqIrc + "|" + cSequen
        cSemPai := ""

        If ValType( oRelReembMap ) == "O"
            oRelReembMap:Get( cMapKey, @cSemPai )
        EndIf

        If Empty( cSemPai )
            cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine["V54_FILIAL"], jLine["V54_ID"], jLine["V54_VERSAO"], cSeqIrc, cPeriodo )
            cSemPai := TAFRelReembOrph( cCtxPai, cSequen )
        EndIf

        aAnalitico[nPosValores][ANALITICO_FILIAL]       := jLine["V54_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]           := jLine["V54_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]       := "S-5002"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_REMTIDTPINSC] := TAFTpInscr( jLine["V54_TPINSC"] )
        aAnalitico[nPosValores][ANALITICO_REMTIDNRINSC] := jLine["V54_NRINSC"]
        aAnalitico[nPosValores][ANALITICO_REMTIDVLREMB] := jLine["V54_VLREMB"]
        aAnalitico[nPosValores][ANALITICO_REMTIDVLRANT] := jLine["V54_VLRANT"]
        aAnalitico[nPosValores][ANALITICO_FORABA]       := "REMTID"
        aAnalitico[nPosValores][ANALITICO_ABA]          := "7A"
        aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]       := jLine["V54_VERSAO"]
        aAnalitico[nPosValores][ANALITICO_RELACAO]      := cSemPai + "|TIT|" + Left( AllTrim( TAFTpInscr( jLine["V54_TPINSC"] ) ), 1 ) + "|" + TAFCleanID( jLine["V54_NRINSC"] )

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV50
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelReembMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV50( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character, oCtxPaiMap as Object, oRelReembMap as Object )

    Local cCpfDep     as character
    Local cCtxPai     as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemKey     as character
    Local cSemPai     as character
    Local cSeqIrc     as character
    Local cSequen     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines       := {}
    Default cPeriodo     := ""
    Default aAnalitico   := {}
    Default cCpf         := ""
    Default oCtxPaiMap   := Nil
    Default oRelReembMap := Nil

    cCpfDep     := ""
    cCtxPai     := ""
    cMapKey     := ""
    cNome       := ""
    cSemKey     := ""
    cSemPai     := ""
    cSeqIrc     := ""
    cSequen     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        cNome := TAFCacheFast( "NOME", jLine["V50_FILIAL"], cCpf )

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc := PadL( AllTrim( jLine["V50_SEQIRC"] ), 3, "0" )
        cCpfDep := TAFCleanID( jLine["V50_CPFDEP"] )
        cSequen := AllTrim( cValToChar( jLine["V50_SEQUEN"] ) )
        cMapKey := "V6A|" + cSeqIrc + "|" + cSequen
        cSemPai := ""

        If ValType( oRelReembMap ) == "O"
            oRelReembMap:Get( cMapKey, @cSemPai )
        EndIf

        If Empty( cSemPai )
            cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine["V50_FILIAL"], jLine["V50_ID"], jLine["V50_VERSAO"], cSeqIrc, cPeriodo )
            cSemPai := TAFRelReembOrph( cCtxPai, cSequen )
        EndIf

        cSemKey := cSemPai + "|D|" + cCpfDep

        aAnalitico[nPosValores][ANALITICO_FILIAL]    := jLine["V50_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]        := jLine["V50_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]    := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]       := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]      := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]    := "S-5002"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA] := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_REMDEPCPF] := jLine["V50_CPFDEP"]
        aAnalitico[nPosValores][ANALITICO_FORABA]    := "REMDEP"
        aAnalitico[nPosValores][ANALITICO_ABA]       := "7B"
        aAnalitico[nPosValores][ANALITICO_PERREF]    := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]    := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]    := jLine["V50_VERSAO"]
        aAnalitico[nPosValores][ANALITICO_RELACAO]   := cSemKey

        If ValType( oRelReembMap ) == "O"
            oRelReembMap:Set( "V50|" + cSeqIrc + "|" + cCpfDep + "|" + cSequen, cSemKey )
        EndIf

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV51
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          aAnalitico, Array,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelReembMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV51( aLines as Array, cPeriodo as character, aAnalitico as Array, cCpf as character, oCtxPaiMap as Object, oRelReembMap as Object )

    Local cCpfDep     as character
    Local cCtxPai     as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemPai     as character
    Local cSeqIrc     as character
    Local cSequen     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines       := {}
    Default cPeriodo     := ""
    Default aAnalitico   := {}
    Default cCpf         := ""
    Default oCtxPaiMap   := Nil
    Default oRelReembMap := Nil

    cCpfDep     := ""
    cCtxPai     := ""
    cMapKey     := ""
    cNome       := ""
    cSemPai     := ""
    cSeqIrc     := ""
    cSequen     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        cNome := TAFCacheFast( "NOME", jLine["V51_FILIAL"], cCpf )

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc := PadL( AllTrim( jLine["V51_SEQIRC"] ), 3, "0" )
        cCpfDep := TAFCleanID( jLine["V51_CPFDEP"] )
        cSequen := AllTrim( cValToChar( jLine["V51_SEQUEN"] ) )
        cMapKey := "V50|" + cSeqIrc + "|" + cCpfDep + "|" + cSequen
        cSemPai := ""

        If ValType( oRelReembMap ) == "O"
            oRelReembMap:Get( cMapKey, @cSemPai )
        EndIf

        If Empty( cSemPai )
            cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine["V51_FILIAL"], jLine["V51_ID"], jLine["V51_VERSAO"], cSeqIrc, cPeriodo )
            cSemPai := TAFRelReembOrph( cCtxPai, cSequen ) + "|D|" + cCpfDep
        EndIf

        aAnalitico[nPosValores][ANALITICO_FILIAL]       := jLine["V51_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]           := jLine["V51_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
        aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]       := "S-5002"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_DETDEPTPINSC] := TAFTpInscr( jLine["V51_TPINSC"] )
        aAnalitico[nPosValores][ANALITICO_DETDEPNRINSC] := jLine["V51_NRINSC"]
        aAnalitico[nPosValores][ANALITICO_DETDEPVLREMB] := jLine["V51_VLREMB"]
        aAnalitico[nPosValores][ANALITICO_DETDEPVLRANT] := jLine["V51_VLRANT"]
        aAnalitico[nPosValores][ANALITICO_FORABA]       := "DETDEP"
        aAnalitico[nPosValores][ANALITICO_ABA]          := "7C"
        aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]       := jLine["V51_VERSAO"]
        aAnalitico[nPosValores][ANALITICO_RELACAO]      := cSemPai + "|T|" + Left( AllTrim( TAFTpInscr( jLine["V51_TPINSC"] ) ), 1 ) + "|" + TAFCleanID( jLine["V51_NRINSC"] )

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7V
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7V( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character )

    Local cNome       as character
    Local cReceita    as character
    Local cCpfAux     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines     := {}
    Default cPeriodo   := ""
    Default cTable     := ""
    Default aAnalitico := {}
    Default cIdFunc    := ""
    Default cTipoEve   := ""
    Default cCpf       := ""

    cNome       := ""
    cReceita    := ""
    cCpfAux     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++
        
        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cTable + "_FILIAL" ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cTable + "_FILIAL" ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cTable + "_FILIAL" ], cCpfAux )
        EndIf
        
        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        cReceita := TAFCacheFast( "RECEITA", jLine[ cTable + "_FILIAL" ], jLine[ cTable + "_TPCR" ] )

        aAnalitico[nPosValores][ANALITICO_FILIAL]       := jLine[ cTable + "_FILIAL" ]
        aAnalitico[nPosValores][ANALITICO_ID]           := jLine[ cTable + "_ID" ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]          := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-1210'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]   := cReceita
        aAnalitico[nPosValores][ANALITICO_TPRENDALIM]   := TAFTpRend( jLine[ cTable + "_TPREND" ] )
        aAnalitico[nPosValores][ANALITICO_CPFDEPALIM]	:= jLine[ cTable + "_CPFDEP" ]
        aAnalitico[nPosValores][ANALITICO_VLRDEDALIM]	:= jLine[ cTable + "_VLPEN" ]
        aAnalitico[nPosValores][ANALITICO_FORABA]	    := "PENALI"
        aAnalitico[nPosValores][ANALITICO_ABA]	        := "03"
        aAnalitico[nPosValores][ANALITICO_PERREF]       := "" 
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	    := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]       := jLine[ cTable + "_VERSAO" ]
            
    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7W
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7W( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character )

    Local cNome       as character
    Local cReceita    as character
    Local cCpfAux     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines     := {}
    Default cPeriodo   := ""
    Default cTable     := ""
    Default aAnalitico := {}
    Default cIdFunc    := ""
    Default cTipoEve   := ""
    Default cCpf       := ""
    
    cNome       := ""
    cReceita    := ""
    cCpfAux     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++
        
        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cTable + "_FILIAL" ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cTable + "_FILIAL" ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cTable + "_FILIAL" ], cCpfAux )
        EndIf
        
        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        cReceita := TAFCacheFast( "RECEITA", jLine[ cTable + "_FILIAL" ], jLine[ cTable + "_TPCR" ] )

        aAnalitico[nPosValores][ANALITICO_FILIAL]           := jLine[ cTable + "_FILIAL" ]
        aAnalitico[nPosValores][ANALITICO_ID]               := jLine[ cTable + "_ID" ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]           := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]              := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]             := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]           := 'S-1210'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]        := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]       := cReceita
        aAnalitico[nPosValores][ANALITICO_TPPREV]           := TAFTpPrev(jLine[ cTable + "_TPREV" ])
        aAnalitico[nPosValores][ANALITICO_CNPJPREV]	        := jLine[ cTable + "_INSCPL" ]
        aAnalitico[nPosValores][ANALITICO_VLRDEDPCPREV]	    := jLine[ cTable + "_VLCOMP" ]
        aAnalitico[nPosValores][ANALITICO_VLRDEDPCPREV13]	:= jLine[ cTable + "_VLDEP1" ]
        aAnalitico[nPosValores][ANALITICO_VLRDEDFUNP]	    := jLine[ cTable + "_VLPATR" ]
        aAnalitico[nPosValores][ANALITICO_VLRDEDFUNP13]	    := jLine[ cTable + "_VLPA13" ]
        aAnalitico[nPosValores][ANALITICO_FORABA]	        := "PREVCL"
        aAnalitico[nPosValores][ANALITICO_ABA]	            := "04"
        aAnalitico[nPosValores][ANALITICO_PERREF]           := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	        := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]           := jLine[ cTable + "_VERSAO" ]
        
    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7X
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7X( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character )

    Local cNome       as character
    Local cReceita    as character
    Local cCpfAux     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines     := {}
    Default cPeriodo   := ""
    Default cTable     := ""
    Default aAnalitico := {}
    Default cIdFunc    := ""
    Default cTipoEve   := ""
    Default cCpf       := ""

    cNome       := ""
    cReceita    := ""
    cCpfAux     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++
        
        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cTable + "_FILIAL" ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cTable + "_FILIAL" ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cTable + "_FILIAL" ], cCpfAux )
        EndIf
        
        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        cReceita := TAFCacheFast( "RECEITA", jLine[ cTable + "_FILIAL" ], jLine[ cTable + "_TPCR" ] )

        aAnalitico[nPosValores][ANALITICO_FILIAL]           := jLine[ cTable + "_FILIAL" ]
        aAnalitico[nPosValores][ANALITICO_ID]               := jLine[ cTable + "_ID" ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]           := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]              := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]             := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]           := 'S-1210'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]        := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]       := cReceita
        aAnalitico[nPosValores][ANALITICO_TPPROC]           := TAFTpProc( jLine[ cTable + "_TPPROC" ] )
        aAnalitico[nPosValores][ANALITICO_NRPROC]	        := jLine[ cTable + "_NRPROC" ]
        aAnalitico[nPosValores][ANALITICO_CODSUP]	        := jLine[ cTable + "_CODSUP" ]
        aAnalitico[nPosValores][ANALITICO_FORABA]	        := "PROCRE"
        aAnalitico[nPosValores][ANALITICO_ABA]	            := "05"
        aAnalitico[nPosValores][ANALITICO_PERREF]           := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	        := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]           := jLine[ cTable + "_VERSAO" ]
        aAnalitico[nPosValores][ANALITICO_RELACAO]          := AllTrim( TAFTpProc( jLine[ cTable + "_TPPROC" ] ) + "|" + jLine[ cTable + "_NRPROC" ] + "|" + jLine[ cTable + "_CODSUP" ] )
                  
    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7Y
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7Y( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character )

    Local cNome       as character
    Local cReceita    as character
    Local cCpfAux     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines     := {}
    Default cPeriodo   := ""
    Default cTable     := ""
    Default aAnalitico := {}
    Default cIdFunc    := ""
    Default cTipoEve   := ""
    Default cCpf       := ""

    cNome       := ""
    cReceita    := ""
    cCpfAux     := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++
        
        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cTable + "_FILIAL" ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cTable + "_FILIAL" ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cTable + "_FILIAL" ], cCpfAux )
        EndIf
        
        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        cReceita := TAFCacheFast( "RECEITA", jLine[ cTable + "_FILIAL" ], jLine[ cTable + "_TPCR" ] )

        aAnalitico[nPosValores][ANALITICO_FILIAL]           := jLine[ cTable + "_FILIAL" ]
        aAnalitico[nPosValores][ANALITICO_ID]               := jLine[ cTable + "_ID" ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]           := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]              := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]             := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]           := 'S-1210'
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]        := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]       := cReceita
        aAnalitico[nPosValores][ANALITICO_PRCINDAPU]        := TAFTpIndapu(jLine[ cTable + "_INDAPU" ])
        aAnalitico[nPosValores][ANALITICO_PRCVLRRET]	    := jLine[ cTable + "_VLRRET" ]
        aAnalitico[nPosValores][ANALITICO_PRCVLRJUD]	    := jLine[ cTable + "_VLRJUD" ]
        aAnalitico[nPosValores][ANALITICO_PRCVLACAL]	    := jLine[ cTable + "_VLACAL" ]
        aAnalitico[nPosValores][ANALITICO_PRCVLAANT]	    := jLine[ cTable + "_VLAANT" ]
        aAnalitico[nPosValores][ANALITICO_PRCVLSUSP]	    := jLine[ cTable + "_VLSUSP" ]
        aAnalitico[nPosValores][ANALITICO_FORABA]	        := "PRCVAL"
        aAnalitico[nPosValores][ANALITICO_ABA]	            := "5A"
        aAnalitico[nPosValores][ANALITICO_PERREF]           := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	        := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]           := jLine[ cTable + "_VERSAO" ]
        aAnalitico[nPosValores][ANALITICO_TPPROC]           := TAFTpProc( jLine[ cTable + "_TPPROC" ] )
        aAnalitico[nPosValores][ANALITICO_NRPROC]           := jLine[ cTable + "_NRPROC" ]
        aAnalitico[nPosValores][ANALITICO_CODSUP]           := jLine[ cTable + "_CODSUP" ]
        aAnalitico[nPosValores][ANALITICO_RELACAO]          := AllTrim( TAFTpProc( jLine[ cTable + "_TPPROC" ] ) + "|" + jLine[ cTable + "_NRPROC" ] + "|" + jLine[ cTable + "_CODSUP" ] + "|" + TAFTpIndapu( jLine[ cTable + "_INDAPU" ] ) )                                                                        

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7Z
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7Z( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character, oProcDedMap as Object )

    Local cDedKey     as character
    Local cNome       as character
    Local cOldDedKey  as character
    Local cReceita    as character
    Local cCpfAux     as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines      := {}
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default oProcDedMap := Nil

    cDedKey      := ""
    cNome        := ""
    cOldDedKey   := ""
    cReceita     := ""
    cCpfAux      := ""
    jLine        := Nil
    nI           := 0
    nPosValores  := 0
    nSequen      := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cTable + "_FILIAL" ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cTable + "_FILIAL" ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cTable + "_FILIAL" ], cCpfAux )
        EndIf

        cDedKey := AllTrim( TAFTpProc( jLine[ cTable + "_TPPROC" ] ) + "|" + ;
                            jLine[ cTable + "_NRPROC" ] + "|" + ;
                            jLine[ cTable + "_CODSUP" ] + "|" + ;
                            TAFTpIndapu( jLine[ cTable + "_INDAPU" ] ) + "|" + ;
                            TAFTpDed( jLine[ cTable + "_TPDEDU" ] ) + "|" + ;
                            TAFCleanID( jLine[ cTable + "_INSCPL" ] ) )

        cOldDedKey := AllTrim( jLine[ cTable + "_TPCR" ] + "|" + ;
                            jLine[ cTable + "_TPPROC" ] + "|" + ;
                            jLine[ cTable + "_NRPROC" ] + "|" + ;
                            jLine[ cTable + "_CODSUP" ] + "|" + ;
                            jLine[ cTable + "_INDAPU" ] + "|" + ;
                            jLine[ cTable + "_SEQUEN" ] + "|" + ;
                            jLine[ cTable + "_SEQIRC" ] )

        If oProcDedMap != Nil
            oProcDedMap:Set( cOldDedKey, cDedKey )
        EndIf

        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        cReceita := TAFCacheFast( "RECEITA", jLine[ cTable + "_FILIAL" ], jLine[ cTable + "_TPCR" ] )

        aAnalitico[nPosValores][ANALITICO_FILIAL]             :=  jLine[ cTable + "_FILIAL" ]
        aAnalitico[nPosValores][ANALITICO_ID]                 :=  jLine[ cTable + "_ID" ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]             :=  cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]                :=  cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]               :=  cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]             :=  'S-1210'
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]         :=  cReceita
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]          :=  CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_TPPROC]             :=  TAFTpProc( jLine[ cTable + "_TPPROC" ] )
        aAnalitico[nPosValores][ANALITICO_NRPROC]             :=  jLine[ cTable + "_NRPROC" ]
        aAnalitico[nPosValores][ANALITICO_CODSUP]             :=  jLine[ cTable + "_CODSUP" ]
        aAnalitico[nPosValores][ANALITICO_PRCINDAPU]          :=  TAFTpIndapu( jLine[ cTable + "_INDAPU" ] )
        aAnalitico[nPosValores][ANALITICO_PRCDEDTPDEDU]       :=  TAFTpDed( jLine[ cTable + "_TPDEDU" ] )
        aAnalitico[nPosValores][ANALITICO_PRCDEDVLSUSP]	      :=  jLine[ cTable + "_VLSUSP" ]
        aAnalitico[nPosValores][ANALITICO_PRCDEDINSCPL]	      :=  TAFCleanID( jLine[ cTable + "_INSCPL" ] )
        aAnalitico[nPosValores][ANALITICO_PRCDEDVLFUNP]	      :=  jLine[ cTable + "_VLFUNP" ]
        aAnalitico[nPosValores][ANALITICO_FORABA]	          := "PRCDED"
        aAnalitico[nPosValores][ANALITICO_ABA]	              := "5B"
        aAnalitico[nPosValores][ANALITICO_PERREF]             := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	          := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]             := jLine[ cTable + "_VERSAO" ] 
        aAnalitico[nPosValores][ANALITICO_RELACAO]            := cDedKey                     

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8A
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8A( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character, oProcDedMap as Object )

    Local cDedKey      as character
    Local cNome        as character
    Local cOldDedKey   as character
    Local cOrphKey     as character
    Local cReceita     as character
    Local cCpfAux      as character
    Local jLine        as Json
    Local nI           as numeric
    Local nPosValores  as numeric
    Local nSequen      as numeric

    Default aLines      := {}
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default oProcDedMap := Nil

    cDedKey      := ""
    cNome        := ""
    cOldDedKey   := ""
    cOrphKey     := ""
    cReceita     := ""
    cCpfAux      := ""
    jLine        := Nil
    nI           := 0
    nPosValores  := 0
    nSequen      := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cTable + "_FILIAL" ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cTable + "_FILIAL" ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cTable + "_FILIAL" ], cCpfAux )
        EndIf

        cOldDedKey := AllTrim( jLine[ cTable + "_TPCR" ] + "|" + ;
                            jLine[ cTable + "_TPPROC" ] + "|" + ;
                            jLine[ cTable + "_NRPROC" ] + "|" + ;
                            jLine[ cTable + "_CODSUP" ] + "|" + ;
                            jLine[ cTable + "_INDAPU" ] + "|" + ;
                            jLine[ cTable + "_SEQUEN" ] + "|" + ;
                            jLine[ cTable + "_SEQIRC" ] )

        cDedKey := ""
        If oProcDedMap != Nil
            oProcDedMap:Get( cOldDedKey, @cDedKey )
        EndIf

        aAdd(aAnalitico, Array(77))
        nPosValores := Len(aAnalitico)
        TAFInitArray( aAnalitico, nPosValores )

        cReceita := TAFCacheFast( "RECEITA", jLine[ cTable + "_FILIAL" ], jLine[ cTable + "_TPCR" ] )

        aAnalitico[nPosValores][ANALITICO_FILIAL]             :=  jLine[ cTable + "_FILIAL" ]
        aAnalitico[nPosValores][ANALITICO_ID]                 :=  jLine[ cTable + "_ID" ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]             :=  cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]                :=  cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]               :=  cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]             :=  'S-1210'
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]         :=  cReceita
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]          :=  CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_PRCBENCPFDEP]       :=  TAFCleanID( jLine[ cTable + "_CPFDEP" ] )
        aAnalitico[nPosValores][ANALITICO_PRCBENVLSUSP]	      :=  jLine[ cTable + "_VLSUSP" ]
        aAnalitico[nPosValores][ANALITICO_FORABA]	          := "PRCBEN"
        aAnalitico[nPosValores][ANALITICO_ABA]	              := "5C"
        aAnalitico[nPosValores][ANALITICO_PERREF]             := "" 
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	          := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]             := jLine[ cTable + "_VERSAO" ]
        aAnalitico[nPosValores][ANALITICO_TPPROC]             := TAFTpProc( jLine[ cTable + "_TPPROC" ] )
        aAnalitico[nPosValores][ANALITICO_NRPROC]             := jLine[ cTable + "_NRPROC" ]
        aAnalitico[nPosValores][ANALITICO_CODSUP]             := jLine[ cTable + "_CODSUP" ]
        aAnalitico[nPosValores][ANALITICO_PRCINDAPU]          := TAFTpIndapu( jLine[ cTable + "_INDAPU" ] )

        If !Empty( cDedKey )
            aAnalitico[nPosValores][ANALITICO_PRCDEDTPDEDU]   := GetTok( cDedKey, 5, "|" )
            aAnalitico[nPosValores][ANALITICO_PRCDEDINSCPL]   := GetTok( cDedKey, 6, "|" )
            aAnalitico[nPosValores][ANALITICO_RELACAO]        := cDedKey + "|" + TAFCleanID( jLine[ cTable + "_CPFDEP" ] )
        Else
            cOrphKey := "O1_" + PadL( AllTrim( jLine[ cTable + "_SEQUEN" ] ), 3, "0" ) + "_" + PadL( AllTrim( jLine[ cTable + "_SEQIRC" ] ), 3, "0" )
            aAnalitico[nPosValores][ANALITICO_PRCDEDTPDEDU]   := "ORPHSEQ"
            aAnalitico[nPosValores][ANALITICO_PRCDEDINSCPL]   := cOrphKey
            aAnalitico[nPosValores][ANALITICO_RELACAO]        := AllTrim( TAFTpProc( jLine[ cTable + "_TPPROC" ] ) + "|" + ;
                                                                            jLine[ cTable + "_NRPROC" ] + "|" + ;
                                                                            jLine[ cTable + "_CODSUP" ] + "|" + ;
                                                                            TAFTpIndapu( jLine[ cTable + "_INDAPU" ] ) + "|" + ;
                                                                            "ORPHSEQ" + "|" + ;
                                                                            cOrphKey + "|" + ;
                                                                            TAFCleanID( jLine[ cTable + "_CPFDEP" ] ) )
        EndIf

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8B
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelPlanMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8B( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character, oCtxPaiMap as Object, oRelPlanMap as Object )

    Local cAns        as character
    Local cCpfAux     as character
    Local cCtxPai     as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemKey     as character
    Local cSeqIrc     as character
    Local cSequen     as character
    Local cColCnpjOp  as character
    Local cColFilial  as character
    Local cColID      as character
    Local cColRegAns  as character
    Local cColSeqIrc  as character
    Local cColSequen  as character
    Local cColVersao  as character
    Local cColVlrTit  as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines      := {}
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default oCtxPaiMap  := Nil
    Default oRelPlanMap := Nil

    cAns        := ""
    cCpfAux     := ""
    cCtxPai     := ""
    cMapKey     := ""
    cNome       := ""
    cSemKey     := ""
    cSeqIrc     := ""
    cSequen     := ""
    cColCnpjOp  := cTable + "_CNPJOP"
    cColFilial  := cTable + "_FILIAL"
    cColID      := cTable + "_ID"
    cColRegAns  := cTable + "_REGANS"
    cColSeqIrc  := cTable + "_SEQIRC"
    cColSequen  := cTable + "_SEQUEN"
    cColVersao  := cTable + "_VERSAO"
    cColVlrTit  := cTable + "_VLRTIT"
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cColFilial ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cColFilial ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cColFilial ], cCpfAux )
        EndIf

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc := PadL( AllTrim( jLine[ cColSeqIrc ] ), 3, "0" )
        cSequen := AllTrim( cValToChar( jLine[ cColSequen ] ) )
        cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine[ cColFilial ], jLine[ cColID ], jLine[ cColVersao ], cSeqIrc, cPeriodo )
        cAns    := TAFCleanID( jLine[ cColRegAns ] )
        cSemKey := "P|" + cCtxPai + "|TIT|" + TAFCleanID( jLine[ cColCnpjOp ] ) + "|" + cAns
        cMapKey := "V8B|" + cSeqIrc + "|" + cSequen + "|" + TAFCleanID( jLine[ cColCnpjOp ] )

        aAnalitico[nPosValores][ANALITICO_FILIAL]       := jLine[ cColFilial ]
        aAnalitico[nPosValores][ANALITICO_ID]           := jLine[ cColID ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]          := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]       := "S-1210"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_DEPSAUDECPF]  := ""
        aAnalitico[nPosValores][ANALITICO_PLSAUDECNPJ]  := jLine[ cColCnpjOp ]
        aAnalitico[nPosValores][ANALITICO_PLSAUDEREGANS]:= jLine[ cColRegAns ]
        aAnalitico[nPosValores][ANALITICO_PLSAUDEVLRTIT]:= jLine[ cColVlrTit ]
        aAnalitico[nPosValores][ANALITICO_FORABA]       := "PLASAU"
        aAnalitico[nPosValores][ANALITICO_ABA]          := "06"
        aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]       := jLine[ cColVersao ]
        aAnalitico[nPosValores][ANALITICO_RELACAO]      := cSemKey

        If ValType( oRelPlanMap ) == "O"
            oRelPlanMap:Set( cMapKey, cSemKey )
        EndIf

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8C
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelPlanMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8C( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character, oCtxPaiMap as Object, oRelPlanMap as Object )

    Local cAns        as character
    Local cCpfAux     as character
    Local cCtxPai     as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemPai     as character
    Local cSeqIrc     as character
    Local cSequen     as character
    Local cColCnpjOp  as character
    Local cColCpfDep  as character
    Local cColFilial  as character
    Local cColID      as character
    Local cColRegAns  as character
    Local cColSeqIrc  as character
    Local cColSequen  as character
    Local cColVersao  as character
    Local cColVlrDep  as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines      := {}
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default oCtxPaiMap  := Nil
    Default oRelPlanMap := Nil

    cAns        := ""
    cCpfAux     := ""
    cCtxPai     := ""
    cMapKey     := ""
    cNome       := ""
    cSemPai     := ""
    cSeqIrc     := ""
    cSequen     := ""
    cColCnpjOp  := cTable + "_CNPJOP"
    cColCpfDep  := cTable + "_CPFDEP"
    cColFilial  := cTable + "_FILIAL"
    cColID      := cTable + "_ID"
    cColRegAns  := cTable + "_REGANS"
    cColSeqIrc  := cTable + "_SEQIRC"
    cColSequen  := cTable + "_SEQUEN"
    cColVersao  := cTable + "_VERSAO"
    cColVlrDep  := cTable + "_VLRDEP"
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cColFilial ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cColFilial ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cColFilial ], cCpfAux )
        EndIf

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc := PadL( AllTrim( jLine[ cColSeqIrc ] ), 3, "0" )
        cSequen := AllTrim( cValToChar( jLine[ cColSequen ] ) )
        cAns    := TAFCleanID( jLine[ cColRegAns ] )
        cMapKey := "V8B|" + cSeqIrc + "|" + cSequen + "|" + TAFCleanID( jLine[ cColCnpjOp ] )
        cSemPai := ""

        If ValType( oRelPlanMap ) == "O"
            oRelPlanMap:Get( cMapKey, @cSemPai )
        EndIf

        If Empty( cSemPai )
            cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine[ cColFilial ], jLine[ cColID ], jLine[ cColVersao ], cSeqIrc, cPeriodo )
            cSemPai := TAFHlthOrph( cCtxPai, jLine[ cColCnpjOp ], jLine[ cColRegAns ], cSequen )
        EndIf

        aAnalitico[nPosValores][ANALITICO_FILIAL]        := jLine[ cColFilial ]
        aAnalitico[nPosValores][ANALITICO_ID]            := jLine[ cColID ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]        := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]           := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]          := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]        := "S-1210"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]     := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_DEPSAUDECPF]   := jLine[ cColCpfDep ]
        aAnalitico[nPosValores][ANALITICO_DEPSAUDEVLRDEP]:= jLine[ cColVlrDep ]
        aAnalitico[nPosValores][ANALITICO_FORABA]        := "DEPSAU"
        aAnalitico[nPosValores][ANALITICO_ABA]           := "6A"
        aAnalitico[nPosValores][ANALITICO_PERREF]        := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]        := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]        := jLine[ cColVersao ]
        aAnalitico[nPosValores][ANALITICO_RELACAO]       := cSemPai + "|DEP|" + TAFCleanID( jLine[ cColCpfDep ] )

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8D
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelReembMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8D( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character, oCtxPaiMap as Object, oRelReembMap as Object )

    Local cAns        as character
    Local cCnpjOp     as character
    Local cCpfAux     as character
    Local cCtxPai     as character
    Local cIndRem     as character
    Local cIndRemFull as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemKey     as character
    Local cSeqIrc     as character
    Local cSequen     as character
    Local cColCnpjOp  as character
    Local cColFilial  as character
    Local cColID      as character
    Local cColIndRem  as character
    Local cColRegAns  as character
    Local cColSeqIrc  as character
    Local cColVersao  as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines       := {}
    Default cPeriodo     := ""
    Default cTable       := ""
    Default aAnalitico   := {}
    Default cIdFunc      := ""
    Default cTipoEve     := ""
    Default cCpf         := ""
    Default oCtxPaiMap   := Nil
    Default oRelReembMap := Nil

    cAns        := ""
    cCnpjOp     := ""
    cCpfAux     := ""
    cCtxPai     := ""
    cIndRem     := ""
    cIndRemFull := ""
    cMapKey     := ""
    cNome       := ""
    cSemKey     := ""
    cSeqIrc     := ""
    cSequen     := ""
    cColCnpjOp  := cTable + "_CNPJOP"
    cColFilial  := cTable + "_FILIAL"
    cColID      := cTable + "_ID"
    cColIndRem  := cTable + "_INDREM"
    cColRegAns  := cTable + "_REGANS"
    cColSeqIrc  := cTable + "_SEQIRC"
    cColVersao  := cTable + "_VERSAO"
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cColFilial ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cColFilial ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cColFilial ], cCpfAux )
        EndIf

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc     := PadL( AllTrim( jLine[ cColSeqIrc ] ), 3, "0" )
        cCtxPai     := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine[ cColFilial ], jLine[ cColID ], jLine[ cColVersao ], cSeqIrc, cPeriodo )
        cIndRemFull := TAFIndRee( jLine[ cColIndRem ] )
        cIndRem     := Left( AllTrim( cIndRemFull ), 1 )
        cAns        := TAFCleanID( jLine[ cColRegAns ] )
        cCnpjOp     := TAFCleanID( jLine[ cColCnpjOp ] )
        cSequen     := AllTrim( cValToChar( jLine[ cTable + "_SEQUEN" ] ) )
        cSemKey     := "P|" + cCtxPai + "|CAB|" + cIndRem + "|" + cCnpjOp + "|" + cAns + "|" + cSequen
        cMapKey     := "V8D|" + cSeqIrc + "|" + cSequen

        aAnalitico[nPosValores][ANALITICO_FILIAL]       := jLine[ cColFilial ]
        aAnalitico[nPosValores][ANALITICO_ID]           := jLine[ cColID ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]          := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]       := "S-1210"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_REMMEDINDREM] := cIndRemFull
        aAnalitico[nPosValores][ANALITICO_REMMEDCNPJOP] := jLine[ cColCnpjOp ]
        aAnalitico[nPosValores][ANALITICO_REMMEDREGANS] := jLine[ cColRegAns ]
        aAnalitico[nPosValores][ANALITICO_FORABA]       := "REMMED"
        aAnalitico[nPosValores][ANALITICO_ABA]          := "07"
        aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]       := jLine[ cColVersao ]
        aAnalitico[nPosValores][ANALITICO_RELACAO]      := cSemKey

        If ValType( oRelReembMap ) == "O"
            oRelReembMap:Set( cMapKey, cSemKey )
        EndIf

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8E
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelReembMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8E( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character, oCtxPaiMap as Object, oRelReembMap as Object )

    Local cCpfAux     as character
    Local cCtxPai     as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemPai     as character
    Local cSeqIrc     as character
    Local cSequen     as character
    Local cColFilial  as character
    Local cColID      as character
    Local cColNrInsc  as character
    Local cColSeqIrc  as character
    Local cColTpInsc  as character
    Local cColVersao  as character
    Local cColVlrAnt  as character
    Local cColVlrEmb  as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines       := {}
    Default cPeriodo     := ""
    Default cTable       := ""
    Default aAnalitico   := {}
    Default cIdFunc      := ""
    Default cTipoEve     := ""
    Default cCpf         := ""
    Default oCtxPaiMap   := Nil
    Default oRelReembMap := Nil

    cCpfAux     := ""
    cCtxPai     := ""
    cMapKey     := ""
    cNome       := ""
    cSemPai     := ""
    cSeqIrc     := ""
    cSequen     := ""
    cColFilial  := cTable + "_FILIAL"
    cColID      := cTable + "_ID"
    cColNrInsc  := cTable + "_NRINSC"
    cColSeqIrc  := cTable + "_SEQIRC"
    cColTpInsc  := cTable + "_TPINSC"
    cColVersao  := cTable + "_VERSAO"
    cColVlrAnt  := cTable + "_VLRANT"
    cColVlrEmb  := cTable + "_VLREMB"
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cColFilial ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cColFilial ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cColFilial ], cCpfAux )
        EndIf

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc := PadL( AllTrim( jLine[ cColSeqIrc ] ), 3, "0" )
        cSequen := AllTrim( cValToChar( jLine[ cTable + "_SEQUEN" ] ) )
        cMapKey := "V8D|" + cSeqIrc + "|" + cSequen
        cSemPai := ""

        If ValType( oRelReembMap ) == "O"
            oRelReembMap:Get( cMapKey, @cSemPai )
        EndIf

        If Empty( cSemPai )
            cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine[ cColFilial ], jLine[ cColID ], jLine[ cColVersao ], cSeqIrc, cPeriodo )
            cSemPai := TAFRelReembOrph( cCtxPai, cSequen )
        EndIf

        aAnalitico[nPosValores][ANALITICO_FILIAL]       := jLine[ cColFilial ]
        aAnalitico[nPosValores][ANALITICO_ID]           := jLine[ cColID ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]          := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]       := "S-1210"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_REMTIDTPINSC] := TAFTpInscr( jLine[ cColTpInsc ] )
        aAnalitico[nPosValores][ANALITICO_REMTIDNRINSC] := jLine[ cColNrInsc ]
        aAnalitico[nPosValores][ANALITICO_REMTIDVLREMB] := jLine[ cColVlrEmb ]
        aAnalitico[nPosValores][ANALITICO_REMTIDVLRANT] := jLine[ cColVlrAnt ]
        aAnalitico[nPosValores][ANALITICO_FORABA]       := "REMTID"
        aAnalitico[nPosValores][ANALITICO_ABA]          := "7A"
        aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]       := jLine[ cColVersao ]
        aAnalitico[nPosValores][ANALITICO_RELACAO]      := cSemPai + "|TIT|" + Left( AllTrim( TAFTpInscr( jLine[ cColTpInsc ] ) ), 1 ) + "|" + TAFCleanID( jLine[ cColNrInsc ] )

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8F
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelReembMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8F( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character, oCtxPaiMap as Object, oRelReembMap as Object )

    Local cCpfAux     as character
    Local cCpfDep     as character
    Local cCtxPai     as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemKey     as character
    Local cSemPai     as character
    Local cSeqIrc     as character
    Local cSequen     as character
    Local cColCpfDep  as character
    Local cColFilial  as character
    Local cColID      as character
    Local cColSeqIrc  as character
    Local cColVersao  as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines       := {}
    Default cPeriodo     := ""
    Default cTable       := ""
    Default aAnalitico   := {}
    Default cIdFunc      := ""
    Default cTipoEve     := ""
    Default cCpf         := ""
    Default oCtxPaiMap   := Nil
    Default oRelReembMap := Nil

    cCpfAux     := ""
    cCpfDep     := ""
    cCtxPai     := ""
    cMapKey     := ""
    cNome       := ""
    cSemKey     := ""
    cSemPai     := ""
    cSeqIrc     := ""
    cSequen     := ""
    cColCpfDep  := cTable + "_CPFDEP"
    cColFilial  := cTable + "_FILIAL"
    cColID      := cTable + "_ID"
    cColSeqIrc  := cTable + "_SEQIRC"
    cColVersao  := cTable + "_VERSAO"
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cColFilial ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cColFilial ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cColFilial ], cCpfAux )
        EndIf

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc := PadL( AllTrim( jLine[ cColSeqIrc ] ), 3, "0" )
        cCpfDep := TAFCleanID( jLine[ cColCpfDep ] )
        cSequen := AllTrim( cValToChar( jLine[ cTable + "_SEQUEN" ] ) )
        cMapKey := "V8D|" + cSeqIrc + "|" + cSequen
        cSemPai := ""

        If ValType( oRelReembMap ) == "O"
            oRelReembMap:Get( cMapKey, @cSemPai )
        EndIf

        If Empty( cSemPai )
            cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine[ cColFilial ], jLine[ cColID ], jLine[ cColVersao ], cSeqIrc, cPeriodo )
            cSemPai := TAFRelReembOrph( cCtxPai, cSequen )
        EndIf

        cSemKey := cSemPai + "|D|" + cCpfDep

        aAnalitico[nPosValores][ANALITICO_FILIAL]    := jLine[ cColFilial ]
        aAnalitico[nPosValores][ANALITICO_ID]        := jLine[ cColID ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]    := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]       := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]      := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]    := "S-1210"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA] := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_REMDEPCPF] := jLine[ cColCpfDep ]
        aAnalitico[nPosValores][ANALITICO_FORABA]    := "REMDEP"
        aAnalitico[nPosValores][ANALITICO_ABA]       := "7B"
        aAnalitico[nPosValores][ANALITICO_PERREF]    := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]    := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]    := jLine[ cColVersao ]
        aAnalitico[nPosValores][ANALITICO_RELACAO]   := cSemKey

        If ValType( oRelReembMap ) == "O"
            oRelReembMap:Set( "V8F|" + cSeqIrc + "|" + cCpfDep + "|" + cSequen, cSemKey )
        EndIf

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8G
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          aLines, Array,
@param          cPeriodo, Character,
@param          cTable, Character,
@param          aAnalitico, Array,
@param          cIdFunc, Character,
@param          cTipoEve, Character,
@param          cCpf, Character,
@param          oCtxPaiMap, Object,
@param          oRelReembMap, Object,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8G( aLines as Array, cPeriodo as character, cTable as character, aAnalitico as Array, cIdFunc as character, cTipoEve as character, cCpf as character, oCtxPaiMap as Object, oRelReembMap as Object )

    Local cCpfAux     as character
    Local cCpfDep     as character
    Local cCtxPai     as character
    Local cMapKey     as character
    Local cNome       as character
    Local cSemPai     as character
    Local cSeqIrc     as character
    Local cSequen     as character
    Local cColCpfDep  as character
    Local cColFilial  as character
    Local cColID      as character
    Local cColNrInsc  as character
    Local cColSeqIrc  as character
    Local cColTpInsc  as character
    Local cColVersao  as character
    Local cColVlrAnt  as character
    Local cColVlrEmb  as character
    Local jLine       as Json
    Local nI          as numeric
    Local nPosValores as numeric
    Local nSequen     as numeric

    Default aLines       := {}
    Default cPeriodo     := ""
    Default cTable       := ""
    Default aAnalitico   := {}
    Default cIdFunc      := ""
    Default cTipoEve     := ""
    Default cCpf         := ""
    Default oCtxPaiMap   := Nil
    Default oRelReembMap := Nil

    cCpfAux     := ""
    cCpfDep     := ""
    cCtxPai     := ""
    cMapKey     := ""
    cNome       := ""
    cSemPai     := ""
    cSeqIrc     := ""
    cSequen     := ""
    cColCpfDep  := cTable + "_CPFDEP"
    cColFilial  := cTable + "_FILIAL"
    cColID      := cTable + "_ID"
    cColNrInsc  := cTable + "_NRINSC"
    cColSeqIrc  := cTable + "_SEQIRC"
    cColTpInsc  := cTable + "_TPINSC"
    cColVersao  := cTable + "_VERSAO"
    cColVlrAnt  := cTable + "_VLRANT"
    cColVlrEmb  := cTable + "_VLREMB"
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0

    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        If Empty( cCpf )
            cCpfAux := AllTrim( TAFCacheFast( "CPF_BENEFI", jLine[ cColFilial ], cIdFunc ) )
            cNome   := TAFCacheFast( "NOME_ID", jLine[ cColFilial ], cIdFunc )
        Else
            cCpfAux := cCpf
            cNome   := TAFCacheFast( "NOME", jLine[ cColFilial ], cCpfAux )
        EndIf

        aAdd( aAnalitico, Array( 77 ) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )

        cSeqIrc := PadL( AllTrim( jLine[ cColSeqIrc ] ), 3, "0" )
        cCpfDep := TAFCleanID( jLine[ cColCpfDep ] )
        cSequen := AllTrim( cValToChar( jLine[ cTable + "_SEQUEN" ] ) )
        cMapKey := "V8F|" + cSeqIrc + "|" + cCpfDep + "|" + cSequen
        cSemPai := ""

        If ValType( oRelReembMap ) == "O"
            oRelReembMap:Get( cMapKey, @cSemPai )
        EndIf

        If Empty( cSemPai )
            cCtxPai := TAFCtxPaiSeqIrc( oCtxPaiMap, jLine[ cColFilial ], jLine[ cColID ], jLine[ cColVersao ], cSeqIrc, cPeriodo )
            cSemPai := TAFRelReembOrph( cCtxPai, cSequen ) + "|D|" + cCpfDep
        EndIf

        aAnalitico[nPosValores][ANALITICO_FILIAL]       := jLine[ cColFilial ]
        aAnalitico[nPosValores][ANALITICO_ID]           := jLine[ cColID ]
        aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
        aAnalitico[nPosValores][ANALITICO_CPF]          := cCpfAux
        aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]       := "S-1210"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CValToChar( StrZero( nSequen, 3 ) )
        aAnalitico[nPosValores][ANALITICO_DETDEPTPINSC] := TAFTpInscr( jLine[ cColTpInsc ] )
        aAnalitico[nPosValores][ANALITICO_DETDEPNRINSC] := jLine[ cColNrInsc ]
        aAnalitico[nPosValores][ANALITICO_DETDEPVLREMB] := jLine[ cColVlrEmb ]
        aAnalitico[nPosValores][ANALITICO_DETDEPVLRANT] := jLine[ cColVlrAnt ]
        aAnalitico[nPosValores][ANALITICO_FORABA]       := "DETDEP"
        aAnalitico[nPosValores][ANALITICO_ABA]          := "7C"
        aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "1"
        aAnalitico[nPosValores][ANALITICO_VERSAO]       := jLine[ cColVersao ]
        aAnalitico[nPosValores][ANALITICO_RELACAO]      := cSemPai + "|T|" + Left( AllTrim( TAFTpInscr( jLine[ cColTpInsc ] ) ), 1 ) + "|" + TAFCleanID( jLine[ cColNrInsc ] )

    Next nI

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInitArray
@type           Function
@description    Inicializa o array analitico com posicoes tipadas 
                (Zeros e Strings vazias). Otimizado com Static e AClone 
                para evitar dezenas de atribuicoes via Interpreter em loop.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@param          aAnalitico,  Array,   Array analitico a ser inicializado (Referencia).
@param          nPosValores, Numeric, Posicao do array que recebera a inicializacao.
@return         Nil
/*/
//-------------------------------------------------------------------
Function TAFInitArray( aAnalitico As Array, nPosValores As Numeric )

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Estaticas (Singleton de Memoria na Thread)
    //-----------------------------------------------------------------------
    Static aEmpty
    
    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default aAnalitico  := {}
    Default nPosValores := 0

    //-----------------------------------------------------------------------
    // Construcao do Esqueleto Basico (Executado apenas 1x por Thread)
    //-----------------------------------------------------------------------
    If ValType( aEmpty ) != "A"
        
        aEmpty := Array( 77 )
        
        // Preenche tudo com zero nativamente via kernel (C++)
        AFill( aEmpty, 0 ) 
        
        // Ajusta as posicoes que obrigatoriamente sao Caracteres (String)
        aEmpty[1]  := ""; aEmpty[2]  := ""; aEmpty[3]  := ""; aEmpty[4]  := ""; aEmpty[5]  := ""
        aEmpty[6]  := ""; aEmpty[7]  := ""; aEmpty[8]  := ""; aEmpty[9]  := ""
        
        aEmpty[29] := ""; aEmpty[30] := ""; aEmpty[32] := ""; aEmpty[33] := ""; aEmpty[35] := ""; aEmpty[36] := ""
        
        aEmpty[41] := ""; aEmpty[42] := ""; aEmpty[43] := ""; aEmpty[44] := ""; aEmpty[50] := ""
        aEmpty[52] := ""; aEmpty[54] := ""; aEmpty[56] := ""; aEmpty[57] := ""; aEmpty[59] := ""
        
        aEmpty[61] := ""; aEmpty[62] := ""; aEmpty[63] := ""; aEmpty[64] := ""; aEmpty[65] := ""
        aEmpty[68] := ""; aEmpty[69] := ""; aEmpty[70] := ""
        
        aEmpty[73] := ""; aEmpty[74] := ""; aEmpty[75] := ""; aEmpty[76] := ""; aEmpty[77] := ""
        
    EndIf

    //-----------------------------------------------------------------------
    // Atribuicao por Clonagem de Memoria (O(1) no Interpreter)
    //-----------------------------------------------------------------------
    If nPosValores > 0 .And. nPosValores <= Len( aAnalitico )
        aAnalitico[nPosValores] := AClone( aEmpty )
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpRend
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          cTpRend, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFTpRend( cTpRend as character )

    Default cTpRend := ""

    If cTpRend == "11"
        cTpRend := "11 - Remuneração mensal"
    ElseIf cTpRend == "12"
        cTpRend := "13º salário"
    ElseIf cTpRend == "13"
        cTpRend := "13 - Férias"
    ElseIf cTpRend == "14"
        cTpRend := "14 - PLR"
    ElseIf cTpRend == "18"
        cTpRend := "18 - RRA"
    Else
        cTpRend := "79 - Rendimento isento ou não tributável"
    EndIf

Return cTpRend

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpPrev
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          cTpPrev, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFTpPrev( cTpPrev as character )

    Default cTpPrev := ""

    If cTpPrev == "1"
        cTpPrev := "1 - Privada"
    ElseIf cTpPrev == "2"
        cTpPrev := "2 - FAPI"
    Else
        cTpPrev := "3 - Funpresp"
    EndIf

Return cTpPrev

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpProc
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          cTpProc, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFTpProc( cTpProc as character )

    Default cTpProc := ""

    If cTpProc == "1"
        cTpProc := "1 - Administrativo"
    Else
        cTpProc := "2 - Judicial"
    EndIf

Return cTpProc

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpIndapu
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          cTpIndapu, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFTpIndapu(cTpIndapu as character)

    Default cTpIndapu := ""

    If cTpIndapu == "1"
        cTpIndapu := "1 - Mensal"
    Else
        cTpIndapu := "2 - Anual (13° salário)"
    EndIf

Return cTpIndapu

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpDed
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          cTpEdu, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFTpDed( cTpEdu as character )

    Default cTpEdu := ""

    If cTpEdu == "1"
        cTpEdu := "1 - Previdência oficial"
    ElseIf cTpEdu == "2"
        cTpEdu := "2 - Previdência privada"
    ElseIf cTpEdu == "3"
        cTpEdu := "3 - Fundo de Aposentadoria Programada Individual - FAPI"
    ElseIf cTpEdu == "4"
        cTpEdu := "4 - Fundação de Previdência Complementar do Servidor Público - Funpresp"
    ElseIf cTpEdu == "5"
        cTpEdu := "5 - Pensão alimentícia"
    ElseIf cTpEdu == "7"
        cTpEdu := "7 - Dependentes"
    Else
        cTpEdu := "" // Se vier vazio ou um código que não existe, mantém vazio!
    EndIf

Return cTpEdu

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFIndRee
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          cIndRem, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFIndRee( cIndRem as character )

    Default cIndRem := ""

    If cIndRem == "1"
        cIndRem := "1 - Reembolso efetuado pelo empregador no âmbito do plano de saúde (a operadora reembolsa o empregador)"
    Else
        cIndRem := "2 - Reembolso efetuado pelo empregador como benefício do próprio empregador"
    EndIf

Return cIndRem

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpInscr
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          cTpInscr, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFTpInscr( cTpInscr as character )

    Default cTpInscr := ""

    If cTpInscr == "1"
        cTpInscr := "1 - CNPJ"
    Else
        cTpInscr := "2 - CPF"
    EndIf

Return cTpInscr

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFFil1200
@type           Function
@description    Processa a tabela V6M (Pagamentos) In-Memory e despacha
                o cache de rubricas para as sub-rotinas de calculo (Motor de Folha).

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0
@param          aLines,        Array,     Linhas da tabela V6M em formato JSON.
@param          aInfos,        Array,     Array com os dados de cabecalho do trabalhador.
@param          aAnalitico,    Array,     Array de retorno com os dados analiticos (Referencia).
@param          cPeriodo,      Character, Periodo base de apuracao.
@param          oPayrollCache, Object,    Cache O(1) de Rubricas (C91, CMD, T92).
@return         Nil
/*/
//-------------------------------------------------------------------
Function TAFFil1200( aLines As Array, aInfos As Array, aAnalitico As Array, cPeriodo As Character, oPayrollCache As Object )

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aProcess    As Array
    Local cChaveDedup As Character
    Local cDmDev      As Character
    Local cPerRef     As Character
    Local cPerRefKey  As Character
    Local cTable      As Character
    Local jLine       As Json
    Local nI          As Numeric
    Local nSequen     As Numeric

    // Variaveis Privadas requeridas pelas funcoes filhas (Motor de Regras Tributarias)
    Private cOrigEve  As Character
    Private cResidExt As Character

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default aLines        := {}
    Default aInfos        := {}
    Default aAnalitico    := {}
    Default cPeriodo      := ""
    Default oPayrollCache := Nil

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aProcess    := {}
    cChaveDedup := ""
    cDmDev      := ""
    cPerRef     := ""
    cPerRefKey  := ""
    cTable      := ""
    jLine       := Nil
    nI          := 0
    nSequen     := 0
    
    cOrigEve  := ""
    cResidExt := ""

    //-----------------------------------------------------------------------
    // Processamento Logico
    //-----------------------------------------------------------------------
    // Coleta o periodo de apuracao do array de cabecalho
    If Len( aInfos ) >= 5
        cPeriodo := AllTrim( cValToChar( aInfos[5] ) )
    EndIf

    For nI := 1 To Len( aLines )
        
        jLine := aLines[nI]

        // Extracao segura do JSON
        cOrigEve  := TAFTpEven( AllTrim( cValToChar( jLine["V6M_TPPGTO"] ) ) )
        cPerRef   := AllTrim( cValToChar( jLine["V6M_PERREF"] ) )
        cResidExt := AllTrim( cValToChar( jLine["V6M_PAIEXT"] ) )
        cDmDev    := AllTrim( cValToChar( jLine["V6M_INDDEV"] ) )
        
        cPerRefKey  := Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 )
        cChaveDedup := cOrigEve + "|" + cPerRefKey + "|" + cDmDev + "|" + cResidExt
        
        If aScan( aProcess, cChaveDedup ) > 0
            Loop 
        EndIf
        
        aAdd( aProcess, cChaveDedup )

        // Define a tabela de origem (C91, CMD, T92) com base no evento
        cTable    := TAFDefTable( cOrigEve )

        // Despacha para o roteador principal (Repassando as referencias e o Cache de Folha)
        TAFMainFil( cTable, cPerRef, aInfos, @aAnalitico, cPeriodo, @nSequen, cDmDev, oPayrollCache )
    
    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpEven
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          cTpEven, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFTpEven( cTpEven as character )

    Default cTpEven := ""

    If cTpEven == "1"
        cTpEven := "S-1200"
    ElseIf cTpEven == "2"
        cTpEven := "S-2299"
    ElseIf cTpEven == "3"
        cTpEven := "S-2399"
    EndIf

Return cTpEven

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDefTable
@type			Function
@description    Processa os dados da tabela corrente e popula o array Analitico.
@author			Alexandre de Lima Santos.
@since			28/10/2025
@version        1.0

@param          cEvento, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFDefTable( cEvento as character )

    Local cTable as character

    Default cEvento := ""

    cTable := ""
        
    If cEvento $ "S-1200|S-1202"
        cTable := "C91"
    ElseIf cEvento == "S-2299"
        cTable := "CMD"
    ElseIf cEvento == "S-2399"
        cTable := "T92"
    EndIf

Return cTable

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMainFil
@type           Function
@description    Funcao roteadora responsavel por direcionar o processamento
                para as rotinas especificas de cada evento de origem, 
                repassando o cache de rubricas para ganho de performance.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0
@param          cTable,        Character, Nome da tabela de origem (C91, CMD, T92).
@param          cPerRef,       Character, Periodo de referencia do pagamento.
@param          aInfos,        Array,     Dados de cabecalho do trabalhador.
@param          aAnalitico,    Array,     Array de retorno (Referencia).
@param          cPeriodo,      Character, Periodo base de apuracao.
@param          nSequen,       Numeric,   Contador sequencial de registros (Referencia).
@param          cDmDev,        Character, Identificador do demonstrativo de pagamento.
@param          oPayrollCache, Object,    Cache O(1) contendo as rubricas da folha.
@return         Nil
/*/
//-------------------------------------------------------------------
Function TAFMainFil( cTable As Character, cPerRef As Character, aInfos As Array, aAnalitico As Array, cPeriodo As Character, nSequen As Numeric, cDmDev As Character, oPayrollCache As Object )

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default cTable        := ""
    Default cPerRef       := ""
    Default aInfos        := {}
    Default aAnalitico    := {}
    Default cPeriodo      := ""
    Default nSequen       := 0
    Default cDmDev        := ""
    Default oPayrollCache := Nil

    //-----------------------------------------------------------------------
    // Roteamento por Tabela de Origem
    //-----------------------------------------------------------------------
    
    // Processamento de Folha Mensal (S-1200 / S-1202)
    If cTable == "C91"
        // Processa Periodo Atual e Retroativos vinculados
        TAFPer1200( cTable, cPerRef, aInfos, @aAnalitico, cPeriodo, @nSequen, cDmDev, oPayrollCache )
        TAFAnt1200( cTable, cPerRef, aInfos, @aAnalitico, cPeriodo, @nSequen, cDmDev, oPayrollCache )
    EndIf

    // Processamento de Desligamentos (S-2299)
    If cTable == "CMD"
        // Processa Verbas Rescisorias e Acordos vinculados
        TAFPer2299( cTable, cPerRef, aInfos, @aAnalitico, cPeriodo, @nSequen, cDmDev, oPayrollCache )
        TAFAnt2299( cTable, cPerRef, aInfos, @aAnalitico, cPeriodo, @nSequen, cDmDev, oPayrollCache )
    EndIf

    // Processamento de Trabalhador Sem Vinculo (S-2399)
    If cTable == "T92"
        TAFPer2399( cTable, cPerRef, aInfos, @aAnalitico, cPeriodo, @nSequen, cDmDev, oPayrollCache )
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TafMainLoad
@type			Function
@description	Carrega as regras e calcula os valores tributários
@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			28/10/2025
@version        1.0

@param          cCodRubr, Character,
@param          nValor, Numeric,
@param          aAnalitico, Array,
@param          cPeriodo, Character,
@param          cPer1210, Character,
@param          cIdFunc, Character,
@param          cBenef, Character,
@param          cTipoEve, Character,
@param          cPerRef, Character,
@param          nSequen, Numeric,
@param          cVersao, Character,
@param          cCpf, Character,
@param          cMv, Character,
@param          cFil, Character,
@return         Nil
/*/
//---------------------------------------------------------------------
Function TafMainLoad( cCodRubr As Character, nValor As Numeric , aAnalitico As Array, cPeriodo As Character, cPer1210 As Character, cIdFunc As Character, cBenef As Character, cTipoEve As Character, cPerRef As Character, nSequen As Numeric, cVersao As Character, cCpf As Character, cMv As Character, cFil As Character ) 

    //-------------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-------------------------------------------------------------------------
    Local aRegRendT   As Array
    Local aRegRendT13 As Array
    Local aRegPrev    As Array
    Local aRegPrev13  As Array
    Local aRegCRMen   As Array
    Local aRegCRMen13 As Array
    Local aRegIsen65  As Array
    Local aRegVlDia   As Array
    Local aRegVlAjCus As Array
    Local aRegIndResC As Array
    Local aRegAbonoP  As Array
    Local aRegMoleG   As Array
    Local aRegAuxMor  As Array
    Local aRegBolM    As Array
    Local aRegBolM13  As Array
    Local aRegJurosM  As Array
    Local aRegIsenOu  As Array
    
    Local nPosValores As Numeric
    Local cClasTri    As Character
    Local cC8RIr      As Character
    Local cC8RKey     As Character
    Local cTpRubric   As Character
    Local cCRMen      As Character
    Local cTpIRRF     As Character

    // Variaveis de escopo Private consumidas pelas funcoes de Macro (fVldRegIR)
    Private cTpInfoIR  As Character
    Private cClassTrib As Character

    //-------------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-------------------------------------------------------------------------
    Default cCodRubr    := ""
    Default nValor      := 0
    Default aAnalitico  := {}
    Default cPeriodo    := ""
    Default cPer1210    := ""
    Default cIdFunc     := ""
    Default cBenef      := ""
    Default cTipoEve    := ""
    Default cPerRef     := ""
    Default nSequen     := 0
    Default cVersao     := ""
    Default cCpf        := ""
    Default cMv         := ""
    Default cFil        := ""
  
    //-------------------------------------------------------------------------
    // Inicializacao de Variaveis 
    //-------------------------------------------------------------------------
    aRegRendT   := {}
    aRegRendT13 := {}
    aRegPrev    := {}
    aRegPrev13  := {}
    aRegCRMen   := {}
    aRegCRMen13 := {}
    aRegIsen65  := {}
    aRegVlDia   := {}
    aRegVlAjCus := {}
    aRegIndResC := {}
    aRegAbonoP  := {}
    aRegMoleG   := {}
    aRegAuxMor  := {}
    aRegBolM    := {}
    aRegBolM13  := {}
    aRegJurosM  := {}
    aRegIsenOu  := {}

    nPosValores := 0
    cClasTri    := ""
    cC8RIr      := ""
    cC8RKey     := ""
    cTpRubric   := ""
    cCRMen      := ""
    cTpIRRF     := ""
    cTpInfoIR   := ""
    cClassTrib  := ""

    //-------------------------------------------------------------------------
    // Prepara o Analitico (Aba de Tributos 01)
    //-------------------------------------------------------------------------
    nSequen++
    aAdd( aAnalitico, Array(77) )
    nPosValores := Len( aAnalitico )
    TAFInitArray( aAnalitico, nPosValores )

    //-------------------------------------------------------------------------
    // CACHE APLICADO NAS BUSCAS DE RUBRICA E CLASSIFICACAO (O(1))
    //-------------------------------------------------------------------------
    cClasTri   := AllTrim( TAFCacheFast( "CLAFIS", cFil, xFilial("T3P", cFil) + "1" ) )
    cClassTrib := AllTrim( TAFCacheFast( "CLASS_TRIB", cFil, cClasTri ) )

    // Se for MV, cCodRubr contem a rubrica. Buscamos o ID no Cache.
    cC8RKey := cCodRubr

    If cMv == "MV"
        cC8RKey := AllTrim( TAFCacheFast( "C8R_ID", cFil, cCodRubr ) )
    EndIf

    // Busca as classificacoes usando a chave padronizada (ID se MV, Rubrica senao)
    cC8RIr    := AllTrim( TAFCacheFast( "C8R_CINTIR", cFil, cC8RKey ) )
    cTpRubric := AllTrim( TAFCacheFast( "C8R_INDTRB", cFil, cC8RKey ) )

    // Busca a Natureza do eSocial (31, 32, etc.) baseada no CINTIR
    cTpInfoIR := AllTrim( TAFCacheFast( "C8U_CODIGO", cFil, cC8RIr ) )

    aAnalitico[nPosValores][ANALITICO_FILIAL] := xFilial("T3P",cFil)
    aAnalitico[nPosValores][ANALITICO_ID]     := cIdFunc
    aAnalitico[nPosValores][ANALITICO_PERAPU] := cPeriodo

    // Busca rapida de CPF e Nome respeitando o contexto de ID vs CPF
    If Empty( cCpf )
        cCpf := AllTrim( TAFCacheFast( "CPF_BENEFI", cFil, cBenef ) )
        aAnalitico[nPosValores][ANALITICO_NOME] := TAFCacheFast( "NOME_ID", cFil, cBenef )
    Else
        aAnalitico[nPosValores][ANALITICO_NOME] := TAFCacheFast( "NOME", cFil, cCpf )
    EndIf
  
    aAnalitico[nPosValores][ANALITICO_CPF]  := cCpf

    //-------------------------------------------------------------------------
    // Carrega regras estaticas para classificacao da verba
    //-------------------------------------------------------------------------
    aRegRendT   := fRgRendT()
    aRegRendT13 := fRgRendT13()
    aRegPrev    := fRgPrev()
    aRegPrev13  := fRgPrev13()
    aRegCRMen   := fRgCRMen()
    aRegCRMen13 := fRgCRMen13()
    aRegIsen65  := fRgIsen65()
    aRegVlDia   := fRgVlDia()
    aRegVlAjCus := fRgVlAjCus()
    aRegIndResC := fRgIndResC()
    aRegAbonoP  := fRgAbonoP()
    aRegMoleG   := fRgMoleG()
    aRegAuxMor  := fRgAuxMor()
    aRegBolM    := fRgBolM()
    aRegBolM13  := fRgBolM13()
    aRegJurosM  := fRgJurosM()
    aRegIsenOu  := fRgIsenOu()

    //-------------------------------------------------------------------------
    // Aplica as regras fiscais baseadas na Natureza do eSocial
    //-------------------------------------------------------------------------
    If cTpInfoIR $ "11*13*12*14" //Rendimento tributavel
        If cTpInfoIR == "13"
            cTpInfoIR := "11"
        EndIf 
        If fVldRegIR(aRegRendT, @cCRMen)
            cTpIRRF := "VLRRENDTRIB"     
        ElseIf fVldRegIR(aRegRendT13, @cCRMen)
            cTpIRRF := "VLRRENDTRIB13"
        EndIf

    ElseIf cTpInfoIR $ "41*43*42" //Valor de Previdencia
        If cTpInfoIR == "43"
             cTpInfoIR := "41"
        EndIf 
        If fVldRegIR(aRegPrev, @cCRMen)
            cTpIRRF := "VLRPREVOFICIAL"
        ElseIf fVldRegIR(aRegPrev13, @cCRMen)
            cTpIRRF := "VLRPREVOFICIAL13"
        EndIf

    ElseIf cTpInfoIR $ "31*33*32*34" //Desconto de IR (IRRF Mensal / 13o)
        If cTpInfoIR == '33'
             cTpInfoIR := '31'
        EndIf
        If fVldRegIR(aRegCRMen, @cCRMen)
            cTpIRRF := "VLRCRMEN"
        ElseIf fVldRegIR(aRegCRMen13, @cCRMen)
            cTpIRRF := "VLRCRMEN13"
        EndIf

    ElseIf cTpInfoIR $ "70*71" //Isencao 65 anos
        If fVldRegIR(aRegIsen65, @cCRMen)
             cTpIRRF := "VLRPARCISENTA65"
        EndIf
        
    ElseIf cTpInfoIR == "72" //Valor relativo a diarias
        If fVldRegIR(aRegVlDia, @cCRMen)
            cTpIRRF := "VLRDIARIAS"
        EndIf

    ElseIf cTpInfoIR == "73" //Valor relativo a Ajuda de Custos
        If fVldRegIR(aRegVlAjCus, @cCRMen)
             cTpIRRF := "VLRAJUDACUSTO"
        EndIf

    ElseIf cTpInfoIR == "74" //Valor relativo a Indenizacao
        If fVldRegIR(aRegIndResC, @cCRMen)
            cTpIRRF := "VLRINDRESCONTRATO"
        EndIf

    ElseIf cTpInfoIR == "75" //Valor relativo ao Abono Pecuniario
        If fVldRegIR(aRegAbonoP, @cCRMen)
            cTpIRRF := "VLRABONOPEC"
        EndIf  

    ElseIf cTpInfoIR $ "76*77" //Valor relativo a molestia grave
        If fVldRegIR(aRegMoleG, @cCRMen)
            cTpIRRF := "VLRRENDMOLEGRAVE"
        EndIf

    ElseIf cTpInfoIR == "700" //Valor relativo ao auxilio moradia
        If fVldRegIR(aRegAuxMor, @cCRMen)
            cTpIRRF := "VLRAUXMORADIA"
        EndIf 

    ElseIf cTpInfoIR == "702" //Valor relativo a bolsa medico
        If fVldRegIR(aRegBolM, @cCRMen)
            cTpIRRF := "VLRBOLSAMEDICO"
        EndIf 

    ElseIf cTpInfoIR == "703" //Valor relativo a bolsa medico - 13o
        If fVldRegIR(aRegBolM13, @cCRMen)
            cTpIRRF := "VLRBOLSAMEDICO13"
        EndIf

    ElseIf cTpInfoIR == "704" //Valor relativo a juros de mora
        If fVldRegIR(aRegJurosM, @cCRMen)
            cTpIRRF := "VLRJUROSMORA"
        EndIf

    ElseIf cTpInfoIR == "79" //Valor relativo aos rendimentos isentos
        If fVldRegIR(aRegIsenOu, @cCRMen)
            cTpIRRF := "VLRISENOUTROS"
        EndIf 
    EndIf

    // Controle de Inversao de Sinal (Descontos)
    If cTpInfoIR $ "31*32*34*41*42*"
        If cTpRubric $ "1|3" .AND. !Empty( cTpIRRF )
            nValor := -1 * nValor
        EndIf
    Else
        If cTpRubric $ "2|4" .AND. !Empty( cTpIRRF )
            nValor := -1 * nValor
        EndIf
    EndIf

    aAnalitico[nPosValores][ANALITICO_EVENTO]    := cOrigEve
    aAnalitico[nPosValores][ANALITICO_SEQUENCIA] := CVALTOCHAR(STRZERO(nSequen, 3))

    // Atribuicao Final do Valor na Coluna Correta
    If cTpIRRF == "VLRRENDTRIB"
        aAnalitico[nPosValores][ANALITICO_VLRRENDTRIB]      := nValor
    ElseIf cTpIRRF == "VLRRENDTRIB13"
        aAnalitico[nPosValores][ANALITICO_VLRRENDTRIB13]    := nValor
    ElseIf cTpIRRF == "VLRPREVOFICIAL"
        aAnalitico[nPosValores][ANALITICO_VLRPREVOFICIAL]   := nValor
    ElseIf cTpIRRF == "VLRPREVOFICIAL13"
        aAnalitico[nPosValores][ANALITICO_VLRPREVOFICIAL13] := nValor
    ElseIf cTpIRRF == "VLRCRMEN"
        aAnalitico[nPosValores][ANALITICO_VLRCRMEN]         := nValor
    ElseIf cTpIRRF == "VLRCRMEN13"
        aAnalitico[nPosValores][ANALITICO_VLRCRMEN13]       := nValor
    ElseIf cTpIRRF == "VLRPARCISENTA65"
        aAnalitico[nPosValores][ANALITICO_VLRPARC65]        := nValor
    ElseIf cTpIRRF == "VLRDIARIAS"
        aAnalitico[nPosValores][ANALITICO_VLRDIARIAS]       := nValor
    ElseIf cTpIRRF == "VLRAJUDACUSTO"
        aAnalitico[nPosValores][ANALITICO_VLRAJDCUSTO]      := nValor
    ElseIf cTpIRRF == "VLRINDRESCONTRATO"
        aAnalitico[nPosValores][ANALITICO_VLRINDRESCTR]     := nValor
    ElseIf cTpIRRF == "VLRABONOPEC"
        aAnalitico[nPosValores][ANALITICO_VLRABONOPEC]      := nValor
    ElseIf cTpIRRF == "VLRRENDMOLEGRAVE"
        aAnalitico[nPosValores][ANALITICO_VLRRENMOLGRV]     := nValor
    ElseIf cTpIRRF == "VLRAUXMORADIA"
        aAnalitico[nPosValores][ANALITICO_VLRAUXMOR]        := nValor
    ElseIf cTpIRRF == "VLRBOLSAMEDICO"
        aAnalitico[nPosValores][ANALITICO_VLRBOLMEDIC]      := nValor
    ElseIf cTpIRRF == "VLRBOLSAMEDICO13"
        aAnalitico[nPosValores][ANALITICO_VLRBOLMEDIC13]    := nValor
    ElseIf cTpIRRF == "VLRJUROSMORA"
        aAnalitico[nPosValores][ANALITICO_VLRJUROSMORA]     := nValor
    ElseIf cTpIRRF == "VLRISENOUTROS"
        aAnalitico[nPosValores][ANALITICO_VLRINSEOUTROS]    := nValor
    EndIf

    aAnalitico[nPosValores][ANALITICO_CODRECEITA] := cCRMen      
    aAnalitico[nPosValores][ANALITICO_FORABA]     := "TRIBUT"
    aAnalitico[nPosValores][ANALITICO_ABA]        := "01" 
    aAnalitico[nPosValores][ANALITICO_PERREF]     := cPerRef
    aAnalitico[nPosValores][ANALITICO_ORIGEM]     := "1"
    aAnalitico[nPosValores][ANALITICO_VERSAO]     := cVersao

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFPer1200
@type           Function
@description    Processa as rubricas da Folha Mensal (S-1200) extraindo os
                dados diretamente do cache em memoria. Substitui a busca
                fisica em banco de dados para ganho de performance O(1).

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@param          cTable,        Character, Nome da tabela de origem.
@param          cPerRef,       Character, Periodo de referencia da folha.
@param          aInfos,        Array,     Dados de cabecalho do trabalhador.
@param          aAnalitico,    Array,     Array de retorno analitico (Referencia).
@param          cPeriodo,      Character, Periodo base de apuracao.
@param          nSequen,       Numeric,   Contador sequencial (Referencia).
@param          cDmDev,        Character, ID do demonstrativo de pagamento.
@param          oPayrollCache, Object,    Objeto HashMap contendo as rubricas do lote.
@return         Nil
/*/
//-------------------------------------------------------------------
Function TAFPer1200( cTable As Character, cPerRef As Character, aInfos As Array, aAnalitico As Array, cPeriodo As Character, nSequen As Numeric, cDmDev As Character, oPayrollCache As Object )

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aRubricas     As Array
    Local cFil          As Character
    Local cKeySearch    As Character
    Local cPerRefKey    As Character
    Local nR            As Numeric

    Private cCatEFD     As Character 
    Private cIndRRA     As Character
    Private cIndApurIR  As Character
    
    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default cTable        := ""
    Default cPerRef       := ""
    Default aInfos        := {}
    Default aAnalitico    := {}
    Default cPeriodo      := ""
    Default nSequen       := 0
    Default cDmDev        := ""
    Default oPayrollCache := Nil
    
    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aRubricas   := {}
    cFil        := IIf( Len( aInfos ) >= 1, aInfos[1], "" )
    cKeySearch  := ""
    cPerRefKey  := ""
    nR          := 0
    
    cCatEFD     := ""
    cIndRRA     := ""
    cIndApurIR  := ""

    //-----------------------------------------------------------------------
    // Processamento In-Memory
    //-----------------------------------------------------------------------
    // Monta a chave de busca: Prefixo | ID (Matricula ou CPF) | Periodo | Demonstrativo
    cPerRefKey := Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 )

    cKeySearch := "PER1200|" + AllTrim( IIf( !Empty( aInfos[6] ), aInfos[6], aInfos[4] ) ) + "|" + cPerRefKey + "|" + AllTrim( cDmDev )

    If oPayrollCache != Nil

        oPayrollCache:Get( cKeySearch, @aRubricas )

        If Len( aRubricas ) == 0 .And. !Empty( aInfos[4] ) .And. !Empty( aInfos[6] )
            cKeySearch := "PER1200|" + AllTrim( aInfos[4] ) + "|" + cPerRefKey + "|" + AllTrim( cDmDev )
            oPayrollCache:Get( cKeySearch, @aRubricas )
        EndIf

    EndIf

    If Len( aRubricas ) > 0
        
        For nR := 1 To Len( aRubricas )
            
            // Atribui variaveis de escopo Private para a TafMainLoad
            cCatEFD    := AllTrim( cValToChar( aRubricas[nR][1] ) )
            cIndRRA    := AllTrim( cValToChar( aRubricas[nR][2] ) )
            cIndApurIR := AllTrim( cValToChar( aRubricas[nR][3] ) )
            
            // Aciona o motor de calculo tributario
            // Parametros Rubrica: [5]=CodRubr, [4]=Valor, [6]=MvLoad
            TafMainLoad( aRubricas[nR][5],;
                         aRubricas[nR][4],;
                         aAnalitico,;
                         cPeriodo,;
                         aInfos[5],;
                         aInfos[2],;
                         aInfos[6],;
                         aInfos[7],;
                         cPerRef,;
                         @nSequen,;
                         aInfos[3],;
                         aInfos[4],;
                         aRubricas[nR][6],;
                         cFil )
        Next nR

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFPer2299
@type           Function
@description    Processa as rubricas de Desligamento (S-2299) extraindo os
                dados diretamente do cache em memoria. Substitui a busca
                fisica em banco de dados para ganho de performance O(1).

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@param          cTable,        Character, Nome da tabela de origem.
@param          cPerRef,       Character, Periodo de referencia da rescisao.
@param          aInfos,        Array,     Dados de cabecalho do trabalhador.
@param          aAnalitico,    Array,     Array de retorno analitico (Referencia).
@param          cPeriodo,      Character, Periodo base de apuracao.
@param          nSequen,       Numeric,   Contador sequencial (Referencia).
@param          cDmDev,        Character, ID do demonstrativo de pagamento.
@param          oPayrollCache, Object,    Objeto HashMap contendo as rubricas do lote.
@return         Nil
/*/
//-------------------------------------------------------------------
Function TAFPer2299( cTable As Character, cPerRef As Character, aInfos As Array, aAnalitico As Array, cPeriodo As Character, nSequen As Numeric, cDmDev As Character, oPayrollCache As Object )

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aRubricas  As Array
    Local cFil       As Character
    Local cKeySearch As Character
    Local cTrabIdx   As Character
    Local nR         As Numeric

    Private cCatEFD    As Character 
    Private cIndRRA    As Character
    Private cIndApurIR As Character
    
    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default cTable        := ""
    Default cPerRef       := ""
    Default aInfos        := {}
    Default aAnalitico    := {}
    Default cPeriodo      := ""
    Default nSequen       := 0
    Default cDmDev        := ""
    Default oPayrollCache := Nil
    
    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aRubricas  := {}
    cFil       := IIf( Len( aInfos ) >= 1, aInfos[1], "" )
    cKeySearch := ""
    cTrabIdx   := ""
    nR         := 0
    
    cCatEFD    := ""
    cIndRRA    := ""
    cIndApurIR := ""

    //-----------------------------------------------------------------------
    // Processamento In-Memory
    //-----------------------------------------------------------------------
    // 1. Busca principal: (matricula; se vazia, CPF)
    cKeySearch := "PER2299|" + AllTrim( IIf( !Empty( aInfos[6] ), aInfos[6], aInfos[4] ) ) + "|" + Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 ) + "|" + AllTrim( cDmDev )

    If oPayrollCache != Nil
        oPayrollCache:Get( cKeySearch, @aRubricas )

        // 2. Fallback seguro via indice auxiliar CPF -> Matricula
        If Len( aRubricas ) == 0 .And. !Empty( aInfos[4] )
            cKeySearch := "IDX2299|" + AllTrim( aInfos[4] ) + "|" + Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 ) + "|" + AllTrim( cDmDev )
            cTrabIdx   := ""

            If oPayrollCache:Get( cKeySearch, @cTrabIdx )
                If !Empty( cTrabIdx ) .And. cTrabIdx != "#AMBIG"
                    cKeySearch := "PER2299|" + cTrabIdx + "|" + Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 ) + "|" + AllTrim( cDmDev )
                    oPayrollCache:Get( cKeySearch, @aRubricas )
                EndIf
            EndIf
        EndIf
    EndIf

    If Len( aRubricas ) > 0
        
        For nR := 1 To Len( aRubricas )
            
            // Atribui variaveis de escopo Private para a TafMainLoad
            cCatEFD    := AllTrim( cValToChar( aRubricas[nR][1] ) )
            cIndRRA    := AllTrim( cValToChar( aRubricas[nR][2] ) )
            cIndApurIR := AllTrim( cValToChar( aRubricas[nR][3] ) )
            
            // Aciona o motor de calculo tributario
            // Mapeamento Rubrica no Cache: [5]=CodRubr, [4]=Valor, [6]=MvLoad
            TafMainLoad( aRubricas[nR][5],;
                         aRubricas[nR][4],;
                         aAnalitico,;
                         cPeriodo,;
                         aInfos[5],;
                         aInfos[2],;
                         aInfos[6],;
                         aInfos[7],;
                         cPerRef,;
                         @nSequen,;
                         aInfos[3],;
                         aInfos[4],;
                         aRubricas[nR][6],;
                         cFil )
        Next nR

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAnt2299
@type           Function
@description    Processa as rubricas de Acordos e Retroativos de Desligamento 
                (S-2299) extraindo os dados diretamente do cache em memoria. 
                Substitui a busca fisica em banco de dados para ganho de 
                performance O(1).

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          04/03/2026
@version        1.0
@param          cTable,        Character, Nome da tabela de origem.
@param          cPerRef,       Character, Periodo de referencia da rescisao.
@param          aInfos,        Array,     Dados de cabecalho do trabalhador.
@param          aAnalitico,    Array,     Array de retorno analitico (Referencia).
@param          cPeriodo,      Character, Periodo base de apuracao.
@param          nSequen,       Numeric,   Contador sequencial (Referencia).
@param          cDmDev,        Character, ID do demonstrativo de pagamento.
@param          oPayrollCache, Object,    Objeto HashMap contendo as rubricas do lote.
@return         Nil
/*/
//-------------------------------------------------------------------
Function TAFAnt2299( cTable As Character, cPerRef As Character, aInfos As Array, aAnalitico As Array, cPeriodo As Character, nSequen As Numeric, cDmDev As Character, oPayrollCache As Object )

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aRubricas  As Array
    Local cFil       As Character
    Local cKeySearch As Character
    Local cTrabIdx   As Character
    Local nR         As Numeric

    Private cCatEFD    As Character 
    Private cIndApurIR As Character
    Private cIndRRA    As Character
    
    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default cTable        := ""
    Default cPerRef       := ""
    Default aInfos        := {}
    Default aAnalitico    := {}
    Default cPeriodo      := ""
    Default nSequen       := 0
    Default cDmDev        := ""
    Default oPayrollCache := Nil
    
    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aRubricas  := {}
    cFil       := IIf( Len( aInfos ) >= 1, aInfos[1], "" )
    cKeySearch := ""
    cTrabIdx   := ""
    nR         := 0
    
    cCatEFD    := ""
    cIndApurIR := ""
    cIndRRA    := ""

    //-----------------------------------------------------------------------
    // Processamento In-Memory (Zero Banco de Dados)
    //-----------------------------------------------------------------------
    // 1. Busca principal: (matricula; se vazia, CPF)
    cKeySearch := "ANT2299|" + AllTrim( IIf( !Empty( aInfos[6] ), aInfos[6], aInfos[4] ) ) + "|" + Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 ) + "|" + AllTrim( cDmDev )

    If oPayrollCache != Nil
        oPayrollCache:Get( cKeySearch, @aRubricas )

        // 2. Fallback seguro via indice auxiliar CPF -> Matricula
        If Len( aRubricas ) == 0 .And. !Empty( aInfos[4] )
            cKeySearch := "IDXANT2299|" + AllTrim( aInfos[4] ) + "|" + Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 ) + "|" + AllTrim( cDmDev )
            cTrabIdx   := ""

            If oPayrollCache:Get( cKeySearch, @cTrabIdx )
                If !Empty( cTrabIdx ) .And. cTrabIdx != "#AMBIG"
                    cKeySearch := "ANT2299|" + cTrabIdx + "|" + Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 ) + "|" + AllTrim( cDmDev )
                    oPayrollCache:Get( cKeySearch, @aRubricas )
                EndIf
            EndIf
        EndIf
    EndIf

    If Len( aRubricas ) > 0
        
        For nR := 1 To Len( aRubricas )
            
            // Atribui variaveis de escopo Private consumidas pela TafMainLoad
            cCatEFD    := AllTrim( cValToChar( aRubricas[nR][1] ) )
            cIndRRA    := AllTrim( cValToChar( aRubricas[nR][2] ) )
            cIndApurIR := AllTrim( cValToChar( aRubricas[nR][3] ) )
            
            // Aciona o motor de calculo tributario
            // Mapeamento Rubrica no Cache: [5]=CodRubr, [4]=Valor, [6]=MvLoad
            TafMainLoad( aRubricas[nR][5],;
                         aRubricas[nR][4],;
                         aAnalitico,;
                         cPeriodo,;
                         aInfos[5],;
                         aInfos[2],;
                         aInfos[6],;
                         aInfos[7],;
                         cPerRef,;
                         @nSequen,;
                         aInfos[3],;
                         aInfos[4],;
                         aRubricas[nR][6],;
                         cFil )
        Next nR

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFPer2399
@type           Function
@description    Processa as rubricas de Trabalhador Sem Vinculo (S-2399) 
                extraindo os dados diretamente do cache em memoria. 
                Substitui a busca fisica em banco de dados para ganho de 
                performance O(1).

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@param          cTable,        Character, Nome da tabela de origem (T92).
@param          cPerRef,       Character, Periodo de referencia do pagamento.
@param          aInfos,        Array,     Dados de cabecalho do trabalhador.
@param          aAnalitico,    Array,     Array de retorno analitico (Referencia).
@param          cPeriodo,      Character, Periodo base de apuracao.
@param          nSequen,       Numeric,   Contador sequencial (Referencia).
@param          cDmDev,        Character, ID do demonstrativo de pagamento.
@param          oPayrollCache, Object,    Objeto HashMap contendo as rubricas do lote.
@return         Nil
/*/
//-------------------------------------------------------------------
Function TAFPer2399( cTable As Character, cPerRef As Character, aInfos As Array, aAnalitico As Array, cPeriodo As Character, nSequen As Numeric, cDmDev As Character, oPayrollCache As Object )

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aRubricas  As Array
    Local cFil       As Character
    Local cKeySearch As Character
    Local cTrabIdx   As Character
    Local nR         As Numeric

    Private cCatEFD    As Character 
    Private cIndRRA    As Character
    Private cIndApurIR As Character
    
    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default cTable        := ""
    Default cPerRef       := ""
    Default aInfos        := {}
    Default aAnalitico    := {}
    Default cPeriodo      := ""
    Default nSequen       := 0
    Default cDmDev        := ""
    Default oPayrollCache := Nil
    
    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aRubricas  := {}
    cFil       := IIf( Len( aInfos ) >= 1, aInfos[1], "" )
    cKeySearch := ""
    cTrabIdx   := ""
    nR         := 0
    
    cCatEFD    := ""
    cIndRRA    := ""
    cIndApurIR := ""

    //-----------------------------------------------------------------------
    // Processamento In-Memory
    //-----------------------------------------------------------------------
    // 1. Busca principal: igual a PROD (matricula; se vazia, CPF)
    cKeySearch := "PER2399|" + AllTrim( IIf( !Empty( aInfos[6] ), aInfos[6], aInfos[4] ) ) + "|" + Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 ) + "|" + AllTrim( cDmDev )
    
    If oPayrollCache != Nil
        oPayrollCache:Get( cKeySearch, @aRubricas )

        // 2. Fallback seguro via indice auxiliar CPF -> Matricula
        If Len( aRubricas ) == 0 .And. !Empty( aInfos[4] )
            cKeySearch := "IDX2399|" + AllTrim( aInfos[4] ) + "|" + Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 ) + "|" + AllTrim( cDmDev )
            cTrabIdx   := ""
            
            If oPayrollCache:Get( cKeySearch, @cTrabIdx )
                If !Empty( cTrabIdx ) .And. cTrabIdx != "#AMBIG"
                    cKeySearch := "PER2399|" + cTrabIdx + "|" + Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 ) + "|" + AllTrim( cDmDev )
                    oPayrollCache:Get( cKeySearch, @aRubricas )
                EndIf
            EndIf
        EndIf
    EndIf

    If Len( aRubricas ) > 0
        
        For nR := 1 To Len( aRubricas )
            
            // Atribui variaveis de escopo Private consumidas pela TafMainLoad
            cCatEFD    := AllTrim( cValToChar( aRubricas[nR][1] ) )
            cIndRRA    := AllTrim( cValToChar( aRubricas[nR][2] ) )
            cIndApurIR := AllTrim( cValToChar( aRubricas[nR][3] ) )
            
            // Aciona o motor de calculo tributario
            // Mapeamento Rubrica no Cache: [5]=CodRubr, [4]=Valor, [6]=MvLoad
            TafMainLoad( aRubricas[nR][5],;
                         aRubricas[nR][4],;
                         aAnalitico,;
                         cPeriodo,;
                         aInfos[5],;
                         aInfos[2],;
                         aInfos[6],;
                         aInfos[7],;
                         cPerRef,;
                         @nSequen,;
                         aInfos[3],;
                         aInfos[4],;
                         aRubricas[nR][6],;
                         cFil )
        Next nR

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAnt1200
@type           Function
@description    Processa as rubricas de Pagamentos Retroativos (S-1200) extraindo
                os dados diretamente do cache em memoria. Substitui a busca
                fisica em banco de dados para ganho de performance O(1).

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@param          cTable,        Character, Nome da tabela de origem.
@param          cPerRef,       Character, Periodo de referencia da folha.
@param          aInfos,        Array,     Dados de cabecalho do trabalhador.
@param          aAnalitico,    Array,     Array de retorno analitico (Referencia).
@param          cPeriodo,      Character, Periodo base de apuracao.
@param          nSequen,       Numeric,   Contador sequencial (Referencia).
@param          cDmDev,        Character, ID do demonstrativo de pagamento.
@param          oPayrollCache, Object,    Objeto HashMap contendo as rubricas do lote.
@return         Nil
/*/
//-------------------------------------------------------------------
Function TAFAnt1200( cTable As Character, cPerRef As Character, aInfos As Array, aAnalitico As Array, cPeriodo As Character, nSequen As Numeric, cDmDev As Character, oPayrollCache As Object )

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aRubricas     As Array
    Local cFil          As Character
    Local cKeySearch    As Character
    Local cPerRefKey    As Character
    Local nR            As Numeric

    Private cCatEFD     As Character 
    Private cIndApurIR  As Character
    Private cIndRRA     As Character
    
    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default cTable        := ""
    Default cPerRef       := ""
    Default aInfos        := {}
    Default aAnalitico    := {}
    Default cPeriodo      := ""
    Default nSequen       := 0
    Default cDmDev        := ""
    Default oPayrollCache := Nil
    
    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    aRubricas   := {}
    cFil        := IIf( Len( aInfos ) >= 1, aInfos[1], "" )
    cKeySearch  := ""
    cPerRefKey  := ""
    nR          := 0
    
    cCatEFD     := ""
    cIndApurIR  := ""
    cIndRRA     := ""

    //-----------------------------------------------------------------------
    // Processamento In-Memory
    //-----------------------------------------------------------------------
    // Monta a chave de busca: Prefixo Retroativo | ID (Matricula ou CPF) | Periodo | Demonstrativo
    cPerRefKey := Left( StrTran( AllTrim( cPerRef ), "-", "" ), 6 )

    cKeySearch := "ANT1200|" + AllTrim( IIf( !Empty( aInfos[6] ), aInfos[6], aInfos[4] ) ) + "|" + cPerRefKey + "|" + AllTrim( cDmDev )

    If oPayrollCache != Nil

        oPayrollCache:Get( cKeySearch, @aRubricas )

        If Len( aRubricas ) == 0 .And. !Empty( aInfos[4] ) .And. !Empty( aInfos[6] )
            cKeySearch := "ANT1200|" + AllTrim( aInfos[4] ) + "|" + cPerRefKey + "|" + AllTrim( cDmDev )
            oPayrollCache:Get( cKeySearch, @aRubricas )
        EndIf

    EndIf

    // Busca as rubricas ja carregadas pelo TAFBulkPayroll no HashMap em tempo O(1)
    If Len( aRubricas ) > 0
        
        For nR := 1 To Len( aRubricas )
            
            // Atribui variaveis de escopo Private consumidas pela TafMainLoad
            cCatEFD    := AllTrim( cValToChar( aRubricas[nR][1] ) )
            cIndRRA    := AllTrim( cValToChar( aRubricas[nR][2] ) )
            cIndApurIR := AllTrim( cValToChar( aRubricas[nR][3] ) )
            
            // Aciona o motor de calculo tributario
            // Mapeamento Rubrica no Cache: [5]=CodRubr, [4]=Valor, [6]=MvLoad
            TafMainLoad( aRubricas[nR][5],;
                         aRubricas[nR][4],;
                         aAnalitico,;
                         cPeriodo,;
                         aInfos[5],;
                         aInfos[2],;
                         aInfos[6],;
                         aInfos[7],;
                         cPerRef,;
                         @nSequen,;
                         aInfos[3],;
                         aInfos[4],;
                         aRubricas[nR][6],;
                         cFil )
        Next nR

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFCon5002
@type			Function
@description	Função In-Memory para consolidar a Tabela T8G. 

@author			Alexandre de Lima Santos / Denis R. de Oliveira
@since			17/12/2025
@version        1.0

@param          aLines, Array,   - Dados em Json da memória
@param          aInfos, Array,   - Dados de cabeçalho
@param          aAnalitico, Array,   - Referência de retorno
@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFCon5002( aLines As Array, aInfos As Array, aAnalitico As Array ) 

    //-------------------------------------------------------------------------
    // Declaração de Variáveis
    //-------------------------------------------------------------------------
    Local cNome       As Character
    Local jLine       As Json
    Local nI          As Numeric
    Local nPosValores As Numeric
    Local nSequen     As Numeric

    //-------------------------------------------------------------------------
    // Inicialização de Parâmetros (Defaults)
    //-------------------------------------------------------------------------
    Default aLines     := {}
    Default aInfos     := {}
    Default aAnalitico := {}
    
    //-------------------------------------------------------------------------
    // Inicialização de Variáveis Locais
    //-------------------------------------------------------------------------
    cNome       := ""
    jLine       := Nil
    nI          := 0
    nPosValores := 0
    nSequen     := 0
    
    //-------------------------------------------------------------------------
    // Processamento do Array (In-Memory)
    //-------------------------------------------------------------------------
    For nI := 1 To Len( aLines )

        jLine := aLines[nI]
        nSequen++

        // Busca o nome respeitando ESTRITAMENTE a filial da linha atual
        cNome := TAFCacheFast( "NOME", jLine["T8G_FILIAL"], aInfos[4] )

        aAdd( aAnalitico, Array(77) )
        nPosValores := Len( aAnalitico )
        TAFInitArray( aAnalitico, nPosValores )
    
        aAnalitico[nPosValores][ANALITICO_FILIAL]           := jLine["T8G_FILIAL"]
        aAnalitico[nPosValores][ANALITICO_ID]               := jLine["T8G_ID"]
        aAnalitico[nPosValores][ANALITICO_PERAPU]           := aInfos[5]
        aAnalitico[nPosValores][ANALITICO_CPF]              := aInfos[4] 

        aAnalitico[nPosValores][ANALITICO_NOME]             := cNome
        aAnalitico[nPosValores][ANALITICO_EVENTO]           := "S-5002"
        aAnalitico[nPosValores][ANALITICO_SEQUENCIA]        := CVALTOCHAR(STRZERO(nSequen, 3))
        aAnalitico[nPosValores][ANALITICO_VLRRENDTRIB]      := jLine["T8G_RENDTR"]
        aAnalitico[nPosValores][ANALITICO_VLRRENDTRIB13]    := jLine["T8G_RENT13"]
        aAnalitico[nPosValores][ANALITICO_VLRPREVOFICIAL]   := jLine["T8G_PREVOF"]
        aAnalitico[nPosValores][ANALITICO_VLRPREVOFICIAL13] := jLine["T8G_PROF13"]
        aAnalitico[nPosValores][ANALITICO_VLRCRMEN]         := jLine["T8G_VCRMEN"]
        aAnalitico[nPosValores][ANALITICO_VLRCRMEN13]       := jLine["T8G_CR13ME"]
        aAnalitico[nPosValores][ANALITICO_VLRPARC65]        := jLine["T8G_PAIS65"]
        aAnalitico[nPosValores][ANALITICO_VLRPARC65DEC]     := jLine["T8G_PIS65D"]
        aAnalitico[nPosValores][ANALITICO_VLRDIARIAS]       := jLine["T8G_VLDIAR"]
        aAnalitico[nPosValores][ANALITICO_VLRAJDCUSTO]      := jLine["T8G_VLAJUC"]
        aAnalitico[nPosValores][ANALITICO_VLRINDRESCTR]     := jLine["T8G_VINRES"]
        aAnalitico[nPosValores][ANALITICO_VLRABONOPEC]      := jLine["T8G_ABONPE"]
        aAnalitico[nPosValores][ANALITICO_VLRRENMOLGRV]     := jLine["T8G_VLRIMG"]
        aAnalitico[nPosValores][ANALITICO_VLRRENMOLGRV13]   := jLine["T8G_IMG13"]
        aAnalitico[nPosValores][ANALITICO_VLRAUXMOR]        := jLine["T8G_VLMORD"]
        aAnalitico[nPosValores][ANALITICO_VLRBOLMEDIC]      := jLine["T8G_BOLMED"]
        aAnalitico[nPosValores][ANALITICO_VLRBOLMEDIC13]    := jLine["T8G_BOLM13"]
        aAnalitico[nPosValores][ANALITICO_VLRJUROSMORA]     := jLine["T8G_JURMOR"]
        aAnalitico[nPosValores][ANALITICO_VLRINSEOUTROS]    := jLine["T8G_ISEOUT"]
        aAnalitico[nPosValores][ANALITICO_CODRECEITA]       := jLine["T8G_CRMEN"]      
        aAnalitico[nPosValores][ANALITICO_FORABA]	        := "TRIBUT"
        aAnalitico[nPosValores][ANALITICO_ABA]	            := "01" // Aba de tributos 
        aAnalitico[nPosValores][ANALITICO_PERREF]           := ""
        aAnalitico[nPosValores][ANALITICO_ORIGEM]	        := "3"
        aAnalitico[nPosValores][ANALITICO_VERSAO]           := jLine["T8G_VERSAO"]

    Next nI

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fVldRegIR
@type           Static Function
@description    Retorna se as regras do IR foram atendidas, avaliando os blocos de código.
@author         lidio.oliveira
@since          05/11/2025
@version        1.0

@param          aRegras, Array,     Array contendo as regras de validação (Blocos de código).
@param          cCodCR,  Character, Código de Receita localizado (Atualizado por Referência).
@return         Logical, Indica se a rubrica atendeu a todas as regras fiscais avaliadas.
/*/
//---------------------------------------------------------------------
Static Function fVldRegIR( aRegras as Array, cCodCR as character )

    Local lRegOk    as Logical
    Local nAux      as Numeric
    Local nAux2     as Numeric

    Default aRegras := {}
    Default cCodCR  := ""

    lRegOk  := .T.
    nAux    := 0
    nAux2   := 0

    For nAux := 1 To Len(aRegras)

        lRegOk := .T.
        // Avalia a regra fiscal
        For nAux2 := 2 To Len(aRegras[nAux])
        
            If !Eval(aRegras[nAux][nAux2])
                lRegOk := .F.
                Exit // Falhou na condição atual, quebra o loop interno e vai para a próxima regra
            EndIf
        
        Next nAux2 

        // Todas as condições desta regra passaram
        If lRegOk
            cCodCR := aRegras[nAux][1]
            Exit
        EndIf

    Next nAux

Return lRegOk

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgRendT
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita do tipo do rendimento tributável vlrRendTrib
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para o rendimento tributável
/*/
//---------------------------------------------------------------------
Static Function fRgRendT()
    
    Static aRegRendT := Nil 
    
    If ValType( aRegRendT ) == "A"
        Return aRegRendT
    EndIf

    aRegRendT := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegRendT, {;
        "056107",;
        {| | cTpInfoIR == '11' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegRendT, {;
        "056111",;
        {| | cTpInfoIR == '11' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegRendT, {;
        "058806",;
        {| | cTpInfoIR == '11' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

    //CRMen = 061001  
    //IRRF sobre rendimentos relativos a prestação de serviços de transporte rodoviário internacional de carga, 
    //pagos a transportador autônomo PF residente no Paraguai
    AAdd(aRegRendT, {;
        "061001",;
        {| | cTpInfoIR == '11' },;
        {| | cCatEFD == '712' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

    //CRMen = 356201
    //IRRF sobre participação dos trabalhadores em lucros ou resultados - PLR
    AAdd(aRegRendT, {;
        "356201",;
        {| | cTpInfoIR == '14' },;
        {| | Substr(cCatEFD, 1, 1) == '1' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegRendT, {;
        "188901",;
        {| | cTpInfoIR $ '11*12*14' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '1' },;
        {| | cResidExt == '' } ;
    })

Return aRegRendT

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgRendT13
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita do tipo do rendimento tributável vlrRendTrib13
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para o rendimento tributável 
sobre 13 Salario
/*/
//---------------------------------------------------------------------
Static Function fRgRendT13()
    
    Static aRegRendT13 := Nil 
    
    If ValType( aRegRendT13) == "A"
        Return aRegRendT13
    EndIf

    aRegRendT13 := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegRendT13, {;
        "056107",;
        {| | cTpInfoIR == '12' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056112  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário
    AAdd(aRegRendT13, {;
        "056112",;
        {| | !(cOrigEve $ 'S-2299*S-2399') },;
        {| | cTpInfoIR == '12' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 056113  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário rescisório
    AAdd(aRegRendT13, {;
        "056113",;
        {| | (cOrigEve $ 'S-2299*S-2399') },;
        {| | cTpInfoIR == '12' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegRendT13, {;
        "058806",;
        {| | cTpInfoIR == '12' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

Return aRegRendT13

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgPrev
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita do tipo previdência oficial vlrPrevOficial
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para a previdência oficial
/*/
//---------------------------------------------------------------------
Static Function fRgPrev()
    
    Static aRegPrev := Nil 
    
    If ValType( aRegPrev ) == "A"
        Return aRegPrev
    EndIf

    aRegPrev := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegPrev, {;
        "056107",;
        {| | cTpInfoIR == '41' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegPrev, {;
        "056111",;
        {| | cTpInfoIR == '41' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegPrev, {;
        "058806",;
        {| | cTpInfoIR == '41' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

    //CRMen = 061001  
    //IRRF sobre rendimentos relativos a prestação de serviços de transporte rodoviário internacional de carga, 
    //pagos a transportador autônomo PF residente no Paraguai
    AAdd(aRegPrev, {;
        "061001",;
        {| | cTpInfoIR == '41' },;
        {| | cCatEFD == '712' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegPrev, {;
        "188901",;
        {| | cTpInfoIR $ '41*42' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '1' },;
        {| | cResidExt == '' } ;
    })

Return aRegPrev

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgPrev13
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita do tipo previdência oficial vlrPrevOficial13
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para a previdencia oficial 
sobre 13 Salario
/*/
//---------------------------------------------------------------------
Static Function fRgPrev13()
    
    Static aRegPrev13 := Nil 
    
    If ValType( aRegPrev13 ) == "A"
        Return aRegPrev13
    EndIf

    aRegPrev13 := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegPrev13, {;
        "056107",;
        {| | cTpInfoIR == '42' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056112  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário
    AAdd(aRegPrev13, {;
        "056112",;
        {| | !(cOrigEve $ 'S-2299*S-2399') },;
        {| | cTpInfoIR == '42' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 056113  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário rescisório
    AAdd(aRegPrev13, {;
        "056113",;
        {| | (cOrigEve $ 'S-2299*S-2399') },;
        {| | cTpInfoIR == '42' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegPrev13, {;
        "058806",;
        {| | cTpInfoIR == '42' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

Return aRegPrev13

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgCRMen
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo ao imposto retido - vlrCRMen
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para o imposto retido
/*/
//---------------------------------------------------------------------
Static Function fRgCRMen()
    
    Static aRegCRMen := Nil 
    
    If ValType( aRegCRMen ) == "A"
        Return aRegCRMen
    EndIf

    aRegCRMen := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegCRMen, {;
        "056107",;
        {| | cTpInfoIR == '31' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegCRMen, {;
        "056111",;
        {| | cTpInfoIR == '31' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegCRMen, {;
        "058806",;
        {| | cTpInfoIR == '31' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

    //CRMen = 356201
    //IRRF sobre participação dos trabalhadores em lucros ou resultados - PLR
    AAdd(aRegCRMen, {;
        "356201",;
        {| | cTpInfoIR == '34' },;
        {| | Substr(cCatEFD, 1, 1) == '1' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

    //CRMen = 061001  
    //IRRF sobre rendimentos relativos a prestação de serviços de transporte rodoviário internacional de carga, 
    //pagos a transportador autônomo PF residente no Paraguai
    AAdd(aRegCRMen, {;
        "061001",;
        {| | cTpInfoIR == '31' },;
        {| | cCatEFD == '712' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegCRMen, {;
        "188901",;
        {| | cTpInfoIR $ '31*32*34' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '1' },;
        {| | cResidExt == '' } ;
    })

Return aRegCRMen

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgCRMen13
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo ao imposto retido 13 - vlrCR13Men
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para o imposto retido 
sobre 13 salário
/*/
//---------------------------------------------------------------------
Static Function fRgCRMen13()
    
    Static aRegCRMen13 := Nil 
    
    If ValType( aRegCRMen13 ) == "A"
        Return aRegCRMen13
    EndIf

    aRegCRMen13 := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegCRMen13, {;
        "056107",;
        {| | cTpInfoIR == '32' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056112  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário
    AAdd(aRegCRMen13, {;
        "056112",;
        {| | !(cOrigEve $ 'S-2299*S-2399') },;
        {| | cTpInfoIR == '32' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 056113  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário rescisório
    AAdd(aRegCRMen13, {;
        "056113",;
        {| | (cOrigEve $ 'S-2299*S-2399') },;
        {| | cTpInfoIR == '32' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegCRMen13, {;
        "058806",;
        {| | cTpInfoIR == '32' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

Return aRegCRMen13

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgIsen65
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo ao imposto retido - vlrParcIsenta65
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para a parcela isenta de 
proventos de aposentadoria, reserva remunerada, reforma e pensão de 
beneficiário com 65 anos ou mais.
/*/
//---------------------------------------------------------------------
Static Function fRgIsen65()
    
    Static aRegIsen65 := Nil 
    
    If ValType( aRegIsen65 ) == "A"
        Return aRegIsen65
    EndIf

    aRegIsen65 := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegIsen65, {;
        "188901",;
        {| | cTpInfoIR $ '70*71' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '1' },;
        {| | cResidExt == '' } ;
    })

Return aRegIsen65

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgVlDia
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo a diárias - vlrDiarias
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a diárias.
/*/
//---------------------------------------------------------------------
Static Function fRgVlDia()
    
    Static aRegVlDia := Nil 
    
    If ValType( aRegVlDia ) == "A"
        Return aRegVlDia
    EndIf

    aRegVlDia := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegVlDia, {;
        "056107",;
        {| | cTpInfoIR == '72' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegVlDia, {;
        "056111",;
        {| | cTpInfoIR == '72' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegVlDia, {;
        "058806",;
        {| | cTpInfoIR == '72' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

Return aRegVlDia

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgVlAjCus
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo a ajuda de custo - vlrAjudaCusto
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
ajuda de custo
/*/
//---------------------------------------------------------------------
Static Function fRgVlAjCus()
    
    Static aRegVlAjCus := Nil 
    
    If ValType( aRegVlAjCus ) == "A"
        Return aRegVlAjCus
    EndIf

    aRegVlAjCus := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegVlAjCus, {;
        "056107",;
        {| | cTpInfoIR == '73' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegVlAjCus, {;
        "056111",;
        {| | cTpInfoIR == '73' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegVlAjCus, {;
        "058806",;
        {| | cTpInfoIR == '73' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

Return aRegVlAjCus

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgIndResC
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo a indenização e rescisão de contrato, 
inclusive a título de PDV e acidentes de trabalho.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
Indenização e rescisão de contrato
/*/
//---------------------------------------------------------------------
Static Function fRgIndResC()
    
    Static aRegIndResC := Nil 
    
    If ValType( aRegIndResC ) == "A"
        Return aRegIndResC
    EndIf

    aRegIndResC := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegIndResC, {;
        "056107",;
        {| | cTpInfoIR == '74' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegIndResC, {;
        "056111",;
        {| | cTpInfoIR == '74' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegIndResC, {;
        "058806",;
        {| | cTpInfoIR == '74' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

Return aRegIndResC

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgAbonoP
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo ao abono pecuniário.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
ao abono pecuniário
/*/
//---------------------------------------------------------------------
Static Function fRgAbonoP()
    
    Static aRegAbonoP := Nil 
    
    If ValType( aRegAbonoP ) == "A"
        Return aRegAbonoP
    EndIf

    aRegAbonoP := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegAbonoP, {;
        "056107",;
        {| | cTpInfoIR == '75' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegAbonoP, {;
        "056111",;
        {| | cTpInfoIR == '75' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegAbonoP, {;
        "058806",;
        {| | cTpInfoIR == '75' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

Return aRegAbonoP

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgMoleG
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo moléstia grave ou acidente em serviço
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
moléstia grave ou acidente em serviço
/*/
//---------------------------------------------------------------------
Static Function fRgMoleG()
    
    Static aRegMoleG := Nil 
    
    If ValType( aRegMoleG ) == "A"
        Return aRegMoleG
    EndIf

    aRegMoleG := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegMoleG, {;
        "188901",;
        {| | cTpInfoIR $ '76*77' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '1' },;
        {| | cResidExt == '' } ;
    })

Return aRegMoleG

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgAuxMor
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo ao auxílio moradia.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
auxílio moradia
/*/
//---------------------------------------------------------------------
Static Function fRgAuxMor()
    
    Static aRegAuxMor := Nil 
    
    If ValType( aRegAuxMor ) == "A"
        Return aRegAuxMor
    EndIf

    aRegAuxMor := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegAuxMor, {;
        "056107",;
        {| | cTpInfoIR == '700' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegAuxMor, {;
        "056111",;
        {| | cTpInfoIR == '700' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegAuxMor, {;
        "058806",;
        {| | cTpInfoIR == '700' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

Return aRegAuxMor

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgBolM
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo a bolsa médico residente.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
bolsa médico residente
/*/
//---------------------------------------------------------------------
Static Function fRgBolM()
    
    Static aRegBolM := Nil 
    
    If ValType( aRegBolM ) == "A"
        Return aRegBolM
    EndIf

    aRegBolM := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegBolM, {;
        "056107",;
        {| | cTpInfoIR == '702' },;
        {| | cCatEFD == '902' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

Return aRegBolM

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgBolM13
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo a bolsa médico residente - 13º salário.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
bolsa médico residente - 13º salário
/*/
//---------------------------------------------------------------------
Static Function fRgBolM13()
    
    Static aRegBolM13 := Nil 
    
    If ValType( aRegBolM13 ) == "A"
        Return aRegBolM13
    EndIf

    aRegBolM13 := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegBolM13, {;
        "056107",;
        {| | cTpInfoIR == '703' },;
        {| | cCatEFD == '902' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

Return aRegBolM13

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgJurosM
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo a juros de mora
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
a juros de mora
/*/
//---------------------------------------------------------------------
Static Function fRgJurosM()
    
    Static aRegJurosM := Nil 
    
    If ValType( aRegJurosM ) == "A"
        Return aRegJurosM
    EndIf

    aRegJurosM := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegJurosM, {;
        "188901",;
        {| | cTpInfoIR == '704' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '1' },;
        {| | cResidExt == '' } ;
    })

Return aRegJurosM

//---------------------------------------------------------------------
/*/{Protheus.doc} fRgIsenOu
@type			function
@description	Cria array com as regras para classificação da rubrica 
por código de receita relativo aos rendimentos isentos - outros.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
aos rendimentos isentos - outros
/*/
//---------------------------------------------------------------------
Static Function fRgIsenOu()
    
    Static aRegIsenOu := Nil 
    
    If ValType( aRegIsenOu ) == "A"
        Return aRegIsenOu
    EndIf

    aRegIsenOu := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegIsenOu, {;
        "056107",;
        {| | cTpInfoIR == '79' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib <> '22' } ;
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegIsenOu, {;
        "056111",;
        {| | cTpInfoIR == '79' },;
        {| | cCatEFD $ '101*102*103*105*106*107*108*111' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' },;
        {| | cClassTrib == '22' } ;
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegIsenOu, {;
        "058806",;
        {| | cTpInfoIR == '79' },;
        {| | cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781' },;
        {| | cIndApurIR == '0' },;
        {| | cIndRRA == '' },;
        {| | cResidExt == '' } ;
    })

Return aRegIsenOu

//---------------------------------------------------------------------
/*/{Protheus.doc} getFilsProc
@type			Static Function
@description	Realiza a quebra dos itens a serem processados 
por filial + periodo
@author			evandro.oliveira
@since			17/02/2025
@return			aFilsFound -Filiais para o processamento
/*/
//---------------------------------------------------------------------
Static Function getFilsProc(cTab as character, cPeriodo as character , cCFP as character, lForce as logical, cIdFilCache as character, aFilsParam as array)

    //-------------------------------------------------------------------------
    // Declaração de Variáveis Locais
    //-------------------------------------------------------------------------
    Local aFilsFound As Array
    Local cAliasEmps As Character
    Local cFils      As Character
    Local cPerAte    As Character
    Local cPerDe     As Character
    Local cPerFiltro As Character
    Local cSql       As Character 
    Local nPos       As Numeric
    Local oStmt      As Object

    //-------------------------------------------------------------------------
    // Inicialização de Parâmetros (Defaults)
    //-------------------------------------------------------------------------
    Default cTab        := "T3P"
    Default cPeriodo    := AnoMes( Date() )
    Default cCFP        := ""
    Default lForce      := .F.
    Default cIdFilCache := ""
    Default aFilsParam  := {}

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    aFilsFound := {}
    cAliasEmps := ""
    cFils      := ""
    cPerAte    := ""
    cPerDe     := ""
    cPerFiltro := AllTrim( cPeriodo )
    cSql       := "" 
    nPos       := 0
    oStmt      := Nil

    //-------------------------------------------------------------------------
    // Carga de Filiais a partir do Cache
    //-------------------------------------------------------------------------
    cFils := TAFCacheFil( cTab, aFilsParam, .T., , cIdFilCache )

    If Len(cPerFiltro) == 4 //Ver se ele pega o Anual assim
        cPerDe  := cPerFiltro + "01"
        cPerAte := cPerFiltro + "12"
    Else 
        cPerDe  := cPerFiltro
        cPerAte := cPerFiltro  
    EndIf 

    cSql := " SELECT " + cTab + "_FILIAL FILIAL "
    cSql += " ," + cTab + "_PERAPU PERAPU "
    cSql += " , Count(*) QTD "
    cSql += " FROM " + RetSqlName(cTab)
    cSql += " WHERE "
    cSql += cTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFils + " FILIAIS ) "

    If !Empty(cPerFiltro)
        cSql += " AND " + cTab + "_PERAPU BETWEEN ? AND ? "
    Else
        cSql += " AND " + cTab + "_PERAPU >= ? "
    EndIf

    If !Empty(cCFP)
        If cTab == "T2G"
            cSql += " AND " + cTab + "_CPFBEN = ? "
        Else
            cSql += " AND " + cTab + "_CPF = ? "
        EndIf 
    EndIf 

    cSql += " AND " + cTab + "_ATIVO = ?  "

    If cTab == "T3P"
        cSql += " AND T3P_ORIEVE <> ? "
    EndIf 

    If !lForce
        cSql += " AND " + cTab + "_CHKDIR IN (?)  "
    EndIf 

    cSql += " AND D_E_L_E_T_ = ?  "
    cSql += " GROUP BY " + cTab + "_FILIAL, " + cTab + "_PERAPU "

    oStmt := FWExecStatement():New(ChangeQuery(cSql))

    nPos := 0

    If !Empty(cPerFiltro)
        nPos++; oStmt:SetString(nPos,cPerDe) 
        nPos++; oStmt:SetString(nPos,cPerAte) 
    Else
        nPos++; oStmt:SetString(nPos,'202501') //Periodo Inicial
    EndIf

    If !Empty(cCFP)
        nPos++; oStmt:SetString(nPos,cCFP) 
    EndIf 

    nPos++; oStmt:SetString(nPos,'1')

    If cTab == "T3P" 
        nPos++; oStmt:SetString(nPos,'S2190')
    EndIF 

    If !lForce
        nPos++; oStmt:SetIn(nPos, {' ', 'F'} )
    EndIf 

    nPos++; oStmt:SetString(nPos,' ')

    cAliasEmps := oStmt:OpenAlias()

    If !Empty( cAliasEmps )

        While !(cAliasEmps)->(EoF())

            aAdd(aFilsFound,{(cAliasEmps)->FILIAL,(cAliasEmps)->PERAPU,(cAliasEmps)->QTD} )
            (cAliasEmps)->(dbSkip())

        EndDo
        
        (cAliasEmps)->(dbCloseArea())

    EndIf

    // Liberar memória
    If oStmt != Nil
        oStmt:Destroy()
        FreeObj( oStmt )
        oStmt := Nil
    EndIf

Return aFilsFound

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCacheFast
@type           Function
@description    Motor de cache In-Memory para evitar queries repetidas
                (Posicione) de Nomes e Códigos de Receita no BD.

@author         Denis R. de Oliveira
@since          02/03/2026
@version        1.0
@param          cType, Character, Tipo de busca ("NOME", "RECEITA")
@param          cFil,  Character, Filial de busca
@param          cKey,  Character, Chave de busca (CPF ou ID da Receita)
@return         cRet,  Character, Valor retornado do banco ou cache
/*/
//-------------------------------------------------------------------
Function TAFCacheFast( cType As Character, cFil As Character, cKey As Character ) As Character

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Estaticas (Preservam estado na Thread/Job)
    //-----------------------------------------------------------------------
    Static oCacheFast
    Static nTamFil 
    Static nTC9VCPF
    Static nTC9VID 
    Static nTC6RID 
    Static nTC8DID 
    Static nTC8UID 
    Static nTCUPID 
    Static nTC87ID
    Static nTC8RCOD 
    Static nTC8RID
    
    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local cRet     As Character
    Local cSeekKey As Character

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default cType := ""
    Default cFil  := ""
    Default cKey  := ""

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    cRet     := ""
    cSeekKey := ""

    //-----------------------------------------------------------------------
    // Tratamento de Comando Especial: Limpeza de Memoria
    //-----------------------------------------------------------------------
    If cType == "CLEAR"
        If ValType( oCacheFast ) == "O"
            HMClean( oCacheFast )
            FreeObj( oCacheFast )
            oCacheFast := Nil
        EndIf
        Return ""
    EndIf

    // Evita acesso fisico/caching inutil com chave vazia
    If Empty( cKey )
        Return ""
    EndIf

    //-----------------------------------------------------------------------
    // Carga de Tamanhos do Dicionario (Executado apenas 1x na Thread)
    //-----------------------------------------------------------------------
    If nTC9VCPF == Nil
        
        nTamFil  := GetSX3Cache("C9V_FILIAL","X3_TAMANHO")
        nTC9VCPF := GetSX3Cache("C9V_CPF",   "X3_TAMANHO")
        nTC9VID  := GetSX3Cache("C9V_ID",    "X3_TAMANHO")
        nTC6RID  := GetSX3Cache("C6R_ID",    "X3_TAMANHO")
        nTC8DID  := GetSX3Cache("C8D_ID",    "X3_TAMANHO")
        nTC8UID  := GetSX3Cache("C8U_ID",    "X3_TAMANHO")
        nTCUPID  := GetSX3Cache("CUP_ID",    "X3_TAMANHO")
        nTC87ID  := GetSX3Cache("C87_ID",    "X3_TAMANHO")
        nTC8RCOD := GetSX3Cache("C8R_CODRUB","X3_TAMANHO")
        nTC8RID  := GetSX3Cache("C8R_ID",    "X3_TAMANHO")
        
    EndIf

    //-----------------------------------------------------------------------
    // Inicializacao Singleton do THashMap (Performance In-Memory)
    //-----------------------------------------------------------------------
    If ValType( oCacheFast ) != "O"
        oCacheFast := THashMap():New()
    EndIf

    // Chave Mestra Dinamica (Garante a unicidade e evita colisao de Hash)
    cSeekKey := AllTrim( cType ) + "_" + AllTrim( cFil ) + "_" + AllTrim( cKey )

    //-----------------------------------------------------------------------
    // Busca Imediata no Cache (Cache Hit O(1))
    //-----------------------------------------------------------------------
    If oCacheFast:Get( cSeekKey, @cRet )
        Return cRet
    EndIf

    //-----------------------------------------------------------------------
    // Processamento Fisico no SGBD (Cache Miss) - Dispara apenas na 1a vez
    //-----------------------------------------------------------------------
    cFil := PadR( AllTrim( cFil ), nTamFil )

    Do Case
        
        Case cType == "NOME"
            cRet := cValToChar( Posicione( "C9V", 3, xFilial( "C9V", cFil ) + PadR( cKey, nTC9VCPF ) + "1", "C9V_NOME" ) )
            If Empty( cRet ) 
                cRet := cValToChar( Posicione( "C9V", 3, xFilial( "C9V", cFil ) + PadR( cKey, nTC9VCPF ) + "2", "C9V_NOME" ) )
            EndIf

        Case cType == "NOME_ID"
            cRet := cValToChar( Posicione( "C9V", 2, xFilial( "C9V", cFil ) + PadR( cKey, nTC9VID ) + "1", "C9V_NOME" ) )
            If Empty( cRet )
                cRet := cValToChar( Posicione( "C9V", 2, xFilial( "C9V", cFil ) + PadR( cKey, nTC9VID ) + "2", "C9V_NOME" ) )
            EndIf
            
        Case cType == "CPF_BENEFI"
            cRet := cValToChar( Posicione( "C9V", 2, xFilial( "C9V", cFil ) + PadR( cKey, nTC9VID ) + "1", "C9V_CPF" ) )
            If Empty( cRet )
                cRet := cValToChar( Posicione( "C9V", 2, xFilial( "C9V", cFil ) + PadR( cKey, nTC9VID ) + "2", "C9V_CPF" ) )
            EndIf
            
        Case cType == "RECEITA"
            cRet := cValToChar( Posicione( "C6R", 3, xFilial( "C6R", cFil ) + PadR( cKey, nTC6RID ), "C6R_CODIGO" ) )
            
        Case cType == "CLAFIS"
            cRet := cValToChar( Posicione( "C1E", 3, xFilial( "C1E", cFil ) + cKey, "C1E_CLAFIS" ) )
            
        Case cType == "CLASS_TRIB"
            cRet := cValToChar( Posicione( "C8D", 1, xFilial( "C8D", cFil ) + PadR( cKey, nTC8DID ), "C8D_CODIGO" ) )
            
        Case cType == "C8R_ID"
            cRet := cValToChar( Posicione( "C8R", 3, xFilial( "C8R", cFil ) + PadR( cKey, nTC8RCOD ) + "1", "C8R_ID" ) )
            
        Case cType == "C8R_CINTIR"
            cRet := cValToChar( Posicione( "C8R", 5, xFilial( "C8R", cFil ) + PadR( cKey, nTC8RID ) + "1", "C8R_CINTIR" ) )
            
        Case cType == "C8R_INDTRB"
            cRet := cValToChar( Posicione( "C8R", 5, xFilial( "C8R", cFil ) + PadR( cKey, nTC8RID ) + "1", "C8R_INDTRB" ) )
            
        Case cType == "C8U_CODIGO"
            cRet := cValToChar( Posicione( "C8U", 1, xFilial( "C8U", cFil ) + PadR( cKey, nTC8UID ), "C8U_CODIGO" ) )
        
        Case cType == "CUP_CAT"
            cRet := cValToChar( Posicione( "CUP", 1, xFilial( "CUP", cFil ) + PadR( cKey, nTCUPID ), "CUP_CODCAT" ) )
            
        Case cType == "C87_COD"
            cRet := cValToChar( Posicione( "C87", 1, xFilial( "C87", cFil ) + PadR( cKey, nTC87ID ), "C87_CODIGO" ) )
            
        Case cType == "C9V_CAT"
            cRet := cValToChar( Posicione( "C9V", 16, xFilial( "C9V", cFil ) + PadR( cKey, nTC9VID ) + "S2300" + "1", "C9V_CATCI" ) )
            If Empty( cRet )
                cRet := cValToChar( Posicione( "C9V", 16, xFilial( "C9V", cFil ) + PadR( cKey, nTC9VID ) + "S2300" + "2", "C9V_CATCI" ) )
            EndIf
            
    EndCase

    //-----------------------------------------------------------------------
    // Gravacao no Cache para as proximas leituras
    //-----------------------------------------------------------------------
    cRet := AllTrim( cRet )
    oCacheFast:Set( cSeekKey, cRet )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFBulkPayroll
@type           Function
@description    Motor O(1) de Busca de Rubricas Tributarias em Memoria.
                Realiza as 5 Queries Massivas da Folha de Pagamento (S-1200, S-2299 e S-2399) 
                utilizando o array de Lote (IN Clause) e centraliza o processamento num THashMap.

@author         Denis R. de Oliveira
@since          04/03/2026
@version        1.0
@param          a1210,    Array,     Lote do S-1210 a ser processado.
@param          cFil,     Character, Filial de processamento.
@param          cPeriodo, Character, Periodo de apuracao base.
@param          oHashMap, Object,    Traz o periodo de referencia 
@return         oMap,     Object,    THashMap contendo as rubricas indexadas.
/*/
//-------------------------------------------------------------------
Function TAFBulkPayroll( a1210 As Array, cFil As Character, cPeriodo As Character, oHashMap As Object ) As Object

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aAreaAnt      As Array
    Local aCpf          As Array
    Local aRows         As Array
    Local aTrabal       As Array
    
    Local cAliasQry     As Character
    Local cAnoBase      As Character
    Local cAnoAnt       As Character
    Local cBnkIndApu    As Character
    Local cBnkPerApu    As Character
    Local cBnkTrabal    As Character
    Local cCatC9V       As Character
    Local cCatCUP       As Character
    Local cCatEFD       As Character
    Local cCodCat       As Character
    Local cCodRubr      As Character
    Local cCpfLot       As Character
    Local cCpfStr       As Character
    Local cFilC9M       As Character
    Local cFilC9Q       As Character
    Local cFilC9R       As Character
    Local cFirstId      As Character
    Local cHeaderId     As Character
    Local cHeaderKey    As Character
    Local cIdEdmd       As Character
    Local cIndApurIR    As Character
    Local cIndRRA       As Character
    Local cIdxKey       As Character
    Local cExistTrab    As Character
    Local cKey          As Character
    Local cMainKeyID    As Character
    Local cMvLoad       As Character
    Local cPerApu       As Character
    Local cPerFim       As Character
    Local cPerFimSQL    As Character 
    Local cPerIni       As Character
    Local cPerIniSQL    As Character 
    Local cPerMin       As Character
    Local cQuery        As Character
    Local cTrabal       As Character
    Local cTrabLot      As Character
    Local cWhereCpf     As Character

    Local lDummy        As Logical
    Local lHasCpf       As Logical
    Local lHasTrab      As Logical
    
    Local nI            As Numeric
    Local nPar          As Numeric
    Local nValor        As Numeric
    
    Local oCpfSet       As Object
    Local oFirstHead    As Object
    Local oMap          As Object
    Local oStmt         As Object
    Local oTrabalSet    As Object

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default a1210       := {}
    Default cFil        := ""
    Default cPeriodo    := ""
    Default oHashMap    := Nil

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis (Tipagem Pura)
    //-----------------------------------------------------------------------
    aAreaAnt    := GetArea()
    aCpf        := { "_DUMMY_" }
    aRows       := {}
    aTrabal     := { "_DUMMY_" }
    
    cAliasQry   := ""
    cAnoBase    := ""
    cAnoAnt     := ""
    cBnkIndApu  := PadR( "", GetSX3Cache( "T14_INDAPU", "X3_TAMANHO" ) )
    cBnkPerApu  := PadR( "", GetSX3Cache( "T14_PERAPU", "X3_TAMANHO" ) )
    cBnkTrabal  := PadR( "", GetSX3Cache( "T14_TRABAL", "X3_TAMANHO" ) )
    cCatC9V     := ""
    cCatCUP     := ""
    cCatEFD     := ""
    cCodCat     := ""
    cCodRubr    := ""
    cCpfLot     := ""
    cCpfStr     := ""
    cFilC9M     := ""
    cFilC9Q     := ""
    cFilC9R     := ""
    cFirstId    := ""
    cHeaderId   := ""
    cHeaderKey  := ""
    cIdEdmd     := ""
    cIndApurIR  := ""
    cIndRRA     := ""
    cIdxKey     := ""
    cExistTrab  := ""
    cKey        := ""
    cMainKeyID  := ""
    cMvLoad     := ""
    cPerApu     := ""
    cPerFim     := ""
    cPerFimSQL  := "" 
    cPerIni     := ""
    cPerIniSQL  := "" 
    cPerMin     := ""
    cQuery      := ""
    cTrabal     := ""
    cTrabLot    := ""
    cWhereCpf   := ""

    lDummy      := .F.
    lHasCpf     := .F.
    lHasTrab    := .F.
    
    nI          := 0
    nPar        := 0
    nValor      := 0
    
    oCpfSet     := THashMap():New()
    oFirstHead  := Nil
    oMap        := THashMap():New()
    oStmt       := Nil
    oTrabalSet  := THashMap():New()

    //-----------------------------------------------------------------------
    // Configuracao de Variaveis de Contexto (Logica Inicial)
    //-----------------------------------------------------------------------
    cFilC9M     := xFilial( "C9M", cFil )
    cFilC9Q     := xFilial( "C9Q", cFil )
    cFilC9R     := xFilial( "C9R", cFil )

    // Extrai o Ano Base
    cAnoBase    := SubStr( AllTrim( cPeriodo ), 1, 4 )

    // Busca o menor PERREF real do lote ja carregado em memoria (V6M)
    cPerMin     := TAFPerRefLot( a1210, oHashMap )

    // Tratamento para 13º salário
    If Right( AllTrim( cPeriodo ), 2 ) == "12" .Or. Len( AllTrim( cPeriodo ) ) == 4
        cPerIni := cAnoBase
    ElseIf !Empty( cPerMin ) .And. cPerMin <= ( cAnoBase + "12" )
        cPerIni := cPerMin
    Else
        cAnoAnt := cValToChar( Val( cAnoBase ) - 1 )
        cPerIni := cAnoAnt + "01"
    EndIf

    // Desligamento/TSV (Q3/Q4/Q5)
    If Len( cPerIni ) == 4
        cPerIniSQL := cPerIni + "0101"
    Else
        cPerIniSQL := cPerIni + "01"
    EndIf

    // Mantem cobertura ate o periodo do ano base (13o salario 'zz')
    cPerFim     := cAnoBase + "zz"
    cPerFimSQL  := cAnoBase + "1231"

    // Log de Inicio
    TafConOut( "[TAFBulkPayroll] Inicializando Cache O(1) de Rubricas para Lote de " + cValToChar( Len( a1210 ) ) + " trabalhadores." )

    //-----------------------------------------------------------------------
    // Extracao de Trabalhador e CPF do lote para a clausula IN
    //-----------------------------------------------------------------------
    For nI := 1 To Len( a1210 )

        cTrabLot := ""
        cCpfLot  := ""

        // Extrai Matrícula (Se existir)
        If Len( a1210[nI] ) >= 6
            cTrabLot := AllTrim( cValToChar( a1210[nI][6] ) )
        EndIf

        // Extrai CPF (Se existir)
        If Len( a1210[nI] ) >= 4
            cCpfLot := AllTrim( cValToChar( a1210[nI][4] ) )
        EndIf

        // Alimenta o Set de Trabalhadores
        If !Empty( cTrabLot )
            If !oTrabalSet:Get( cTrabLot, @lDummy )
                oTrabalSet:Set( cTrabLot, .T. )
                aAdd( aTrabal, cTrabLot )
            EndIf
        EndIf

        // Alimenta o Set de CPFs de forma independente
        If !Empty( cCpfLot )
            If !oCpfSet:Get( cCpfLot, @lDummy )
                oCpfSet:Set( cCpfLot, .T. )
                aAdd( aCpf, cCpfLot )
            EndIf
        EndIf

    Next nI

    // Limpeza das HashMaps
    HMClean( oTrabalSet )
    FreeObj( oTrabalSet )
    oTrabalSet := Nil

    HMClean( oCpfSet )
    FreeObj( oCpfSet )
    oCpfSet := Nil

    //=========================================================================
    // PRE-RESOLUCAO DE CPFs: Traduz CPFs em IDs (TRABAL) 
    //=========================================================================
    If Len( aCpf ) > 1

        cQuery := " SELECT C9V_CPF, C9V_ID FROM " + RetSqlName("C9V") + ;
                  " WHERE C9V_FILIAL = ? AND C9V_CPF IN (?) AND D_E_L_E_T_ = ' ' "

        oStmt := FWExecStatement():New( ChangeQuery( cQuery ) )
        oStmt:SetString( 1, xFilial("C9V", cFil) )
        oStmt:SetIn( 2, aCpf )

        cAliasQry := oStmt:OpenAlias()

        If !Empty( cAliasQry )

            While !( cAliasQry )->( EoF() )

                cCpfStr := AllTrim( ( cAliasQry )->C9V_CPF )
                cKey    := AllTrim( ( cAliasQry )->C9V_ID )

                If !Empty( cKey ) .And. aScan( aTrabal, cKey ) == 0
                    aAdd( aTrabal, cKey )
                EndIf

                ( cAliasQry )->( DbSkip() )

            EndDo

            ( cAliasQry )->( DbCloseArea() )

        EndIf

        If oStmt != Nil
            oStmt:Destroy()
            FreeObj( oStmt )
            oStmt := Nil
        EndIf

    EndIf

    lHasTrab := Len( aTrabal ) > 1
    lHasCpf  := Len( aCpf ) > 1

    If lHasTrab .And. lHasCpf
        cWhereCpf := " AND ( C91.C91_TRABAL IN (?) OR C91.C91_CPF IN (?) ) "
    ElseIf lHasTrab
        cWhereCpf := " AND C91.C91_TRABAL IN (?) "
    ElseIf lHasCpf
        cWhereCpf := " AND C91.C91_CPF IN (?) "
    Else
        RestArea( aAreaAnt )
        Return oMap
    EndIf

    //=========================================================================
    // QUERY 1: TAFPer1200 (Folha Mensal Principal - Base C91 e C9M)
    //=========================================================================
    cQuery := " SELECT "
    cQuery += "     C91.C91_ID AS HEADER_ID, C91.C91_TRABAL AS TRABAL, C91.C91_CPF AS CPF, C91.C91_PERAPU AS PERAPU, C91.C91_MV AS MV, "
    cQuery += "     T14.T14_IDEDMD AS IDEDMD, T14.T14_INDRRA AS INDRRA, T14.T14_CODCAT AS CODCAT, "
    cQuery += "     C9L.C9L_ESTABE AS ESTABE, C9L.C9L_LOTACA AS LOTACA, "
    cQuery += "     C9M.C9M_CODRUB AS CODRUB, C9M.C9M_APURIR AS APURIR, C9M.C9M_VLRRUB AS VLRRUB, C9M.C9M_RUBRIC AS RUBRIC "
    cQuery += " FROM " + RetSQLName( "C91" ) + " C91 "
    cQuery += " INNER JOIN " + RetSQLName( "T14" ) + " T14 ON T14.T14_FILIAL = C91.C91_FILIAL AND T14.T14_ID = C91.C91_ID AND T14.T14_VERSAO = C91.C91_VERSAO AND T14.T14_INDAPU = '" + cBnkIndApu + "' AND T14.T14_PERAPU = '" + cBnkPerApu + "' AND T14.T14_TRABAL = '" + cBnkTrabal + "' AND T14.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "C9K" ) + " C9K ON C9K.C9K_FILIAL = T14.T14_FILIAL AND C9K.C9K_ID = T14.T14_ID AND C9K.C9K_VERSAO = T14.T14_VERSAO AND C9K.C9K_RECIBO = T14.T14_IDEDMD AND C9K.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "C9L" ) + " C9L ON C9L.C9L_FILIAL = C9K.C9K_FILIAL AND C9L.C9L_ID = C9K.C9K_ID AND C9L.C9L_VERSAO = C9K.C9K_VERSAO AND C9L.C9L_RECIBO = C9K.C9K_RECIBO AND C9L.C9L_ESTABE = C9K.C9K_ESTABE AND C9L.C9L_LOTACA = C9K.C9K_LOTACA AND C9L.C9L_CODLOT = C9K.C9K_CODLOT AND C9L.C9L_TPINSC = C9K.C9K_TPINSC AND C9L.C9L_NRINSC = C9K.C9K_NRINSC AND C9L.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "C9M" ) + " C9M ON C9M.C9M_FILIAL = ? AND C9M.C9M_ID = C9L.C9L_ID AND C9M.C9M_VERSAO = C9L.C9L_VERSAO AND C9M.C9M_RECIBO = C9L.C9L_RECIBO AND C9M.D_E_L_E_T_ = ' ' "
    cQuery += " AND ( "
    cQuery += "   ( C9L.C9L_ESTABE > ' ' AND C9L.C9L_LOTACA > ' ' AND C9M.C9M_ESTABE = C9L.C9L_ESTABE AND C9M.C9M_LOTACA = C9L.C9L_LOTACA AND C9M.C9M_TRABAL = C9L.C9L_TRABAL ) "
    cQuery += "   OR "
    cQuery += "   ( (C9L.C9L_ESTABE <= ' ' OR C9L.C9L_ESTABE IS NULL OR C9L.C9L_LOTACA <= ' ' OR C9L.C9L_LOTACA IS NULL) AND C9M.C9M_CODLOT = C9L.C9L_CODLOT AND C9M.C9M_TPINSC = C9L.C9L_TPINSC AND C9M.C9M_NRINSC = C9L.C9L_NRINSC AND C9M.C9M_DTRABA = C9L.C9L_DTRABA ) "
    cQuery += " ) "
    cQuery += " WHERE C91.C91_FILIAL = ? AND C91.C91_PERAPU >= ? AND C91.C91_PERAPU <= ? "
    cQuery +=   cWhereCpf
    cQuery += " AND C91.C91_ATIVO = '1' AND C91.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY C91.C91_TRABAL, C91.C91_PERAPU, T14.T14_IDEDMD, C9M.C9M_CODRUB "

    oStmt := FWExecStatement():New( ChangeQuery( cQuery ) )
    oStmt:SetString( 1, cFilC9M )
    oStmt:SetString( 2, cFil )
    oStmt:SetString( 3, cPerIni )
    oStmt:SetString( 4, cPerFim )

    nPar := 5

    If lHasTrab
        oStmt:SetIn( nPar, aTrabal )
        nPar++
    EndIf

    If lHasCpf
        oStmt:SetIn( nPar, aCpf )
    EndIf

    cAliasQry := oStmt:OpenAlias()
    
    oFirstHead := THashMap():New()
    
    If !Empty( cAliasQry )

        While !( cAliasQry )->( EoF() )
            
            cTrabal := AllTrim( ( cAliasQry )->TRABAL )
            cCpfStr := AllTrim( ( cAliasQry )->CPF )
            cPerApu := AllTrim( ( cAliasQry )->PERAPU )
            cIdEdmd := AllTrim( ( cAliasQry )->IDEDMD )

            cHeaderKey := "Q1|" + ;
                          IIf( !Empty( cTrabal ), "T|" + cTrabal, "C|" + cCpfStr ) + "|" + ;
                          cPerApu + "|" + ;
                          cIdEdmd

            cHeaderId := AllTrim( ( cAliasQry )->HEADER_ID )

            If oFirstHead:Get( cHeaderKey, @cFirstId )
                If cHeaderId != cFirstId
                    ( cAliasQry )->( DbSkip() )
                    Loop
                EndIf
            Else
                oFirstHead:Set( cHeaderKey, cHeaderId )
            EndIf

            cIdEdmd    := AllTrim( ( cAliasQry )->IDEDMD )
            cCodCat    := IIf( ValType( ( cAliasQry )->CODCAT ) == "C", AllTrim( ( cAliasQry )->CODCAT ), "" )
            cCatEFD    := TAFCacheFast( "C87_COD", cFil, cCodCat )
            cIndRRA    := AllTrim( ( cAliasQry )->INDRRA )
            cIndApurIR := AllTrim( ( cAliasQry )->APURIR )
            nValor     := ( cAliasQry )->VLRRUB

            If !Empty( ( cAliasQry )->ESTABE ) .And. !Empty( ( cAliasQry )->LOTACA )
                cCodRubr := ( cAliasQry )->CODRUB
                cMvLoad  := ""
            Else
                cCodRubr := IIf( !Empty( ( cAliasQry )->RUBRIC ), ( cAliasQry )->RUBRIC, ( cAliasQry )->CODRUB )
                cMvLoad  := IIf( !Empty( ( cAliasQry )->RUBRIC ), "MV", "" )
            EndIf

            If !Empty( cTrabal )
                cKey := "PER1200|" + cTrabal + "|" + cPerApu + "|" + cIdEdmd
                If oMap:Get( cKey, @aRows )
                    aAdd( aRows, { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } )
                Else
                    oMap:Set( cKey, { { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } } )
                EndIf
            EndIf

            If !Empty( cCpfStr ) .And. cCpfStr != cTrabal
                cKey := "PER1200|" + cCpfStr + "|" + cPerApu + "|" + cIdEdmd
                If oMap:Get( cKey, @aRows )
                    aAdd( aRows, { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } )
                Else
                    oMap:Set( cKey, { { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } } )
                EndIf
            EndIf
            
            ( cAliasQry )->( DbSkip() )
            
        EndDo

        ( cAliasQry )->( DbCloseArea() )

    EndIf

    If oStmt != Nil
        oStmt:Destroy()
        FreeObj( oStmt )
        oStmt := Nil
    EndIf

    // =========================================================================
    // QUERY 2: TAFAnt1200 (Retroativos Base C91 e C9R)
    // =========================================================================
    cQuery := " SELECT "
    cQuery += "     C91.C91_ID AS HEADER_ID, C91.C91_TRABAL AS TRABAL, C91.C91_CPF AS CPF, C91.C91_PERAPU AS PERAPU, C91.C91_MV AS MV, "
    cQuery += "     T14.T14_IDEDMD AS IDEDMD, T14.T14_INDRRA AS INDRRA, T14.T14_CODCAT AS CODCAT, "
    cQuery += "     C9R.C9R_CODRUB AS CODRUB, C9R.C9R_RUBRIC AS RUBRIC, C9R.C9R_APURIR AS APURIR, C9R.C9R_VLRRUB AS VLRRUB "
    cQuery += " FROM " + RetSQLName( "C91" ) + " C91 "
    cQuery += " INNER JOIN " + RetSQLName( "T14" ) + " T14 ON T14.T14_FILIAL = C91.C91_FILIAL AND T14.T14_ID = C91.C91_ID AND T14.T14_VERSAO = C91.C91_VERSAO AND T14.T14_INDAPU = '" + cBnkIndApu + "' AND T14.T14_PERAPU = '" + cBnkPerApu + "' AND T14.T14_TRABAL = '" + cBnkTrabal + "' AND T14.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "C9N" ) + " C9N ON C9N.C9N_FILIAL = T14.T14_FILIAL AND C9N.C9N_ID = T14.T14_ID AND C9N.C9N_VERSAO = T14.T14_VERSAO AND C9N.C9N_RECIBO = T14.T14_IDEDMD AND C9N.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "C9O" ) + " C9O ON C9O.C9O_FILIAL = C9N.C9N_FILIAL AND C9O.C9O_ID = C9N.C9N_ID AND C9O.C9O_VERSAO = C9N.C9N_VERSAO AND C9O.C9O_RECIBO = C9N.C9N_RECIBO AND C9O.C9O_DTACOR = C9N.C9N_DTACOR AND C9O.C9O_TPACOR = C9N.C9N_TPACOR AND C9O.C9O_COMPAC = C9N.C9N_COMPAC AND C9O.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "C9P" ) + " C9P ON C9P.C9P_FILIAL = C9O.C9O_FILIAL AND C9P.C9P_ID = C9O.C9O_ID AND C9P.C9P_VERSAO = C9O.C9O_VERSAO AND C9P.C9P_RECIBO = C9O.C9O_RECIBO AND C9P.C9P_DTACOR = C9O.C9O_DTACOR AND C9P.C9P_TPACOR = C9O.C9O_TPACOR AND C9P.C9P_COMPAC = C9O.C9O_COMPAC AND C9P.C9P_PERREF = C9O.C9O_PERREF AND C9P.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "C9Q" ) + " C9Q ON C9Q.C9Q_FILIAL = ? AND C9Q.C9Q_ID = C9P.C9P_ID AND C9Q.C9Q_VERSAO = C9P.C9P_VERSAO AND C9Q.C9Q_RECIBO = C9P.C9P_RECIBO AND C9Q.C9Q_DTACOR = C9P.C9P_DTACOR AND C9Q.C9Q_TPACOR = C9P.C9P_TPACOR AND C9Q.C9Q_PERREF = C9P.C9P_PERREF AND C9Q.C9Q_ESTABE = C9P.C9P_ESTABE AND C9Q.D_E_L_E_T_ = ' ' AND ( ( C91.C91_MV = '1' AND C9Q.C9Q_LOTACA = C9P.C9P_LOTACA AND C9Q.C9Q_CODLOT = C9P.C9P_CODLOT ) OR ( C91.C91_MV <> '1' AND C9Q.C9Q_COMPAC = C9P.C9P_COMPAC AND C9Q.C9Q_LOTACA = C9P.C9P_LOTACA ) ) "
    cQuery += " INNER JOIN " + RetSQLName( "C9R" ) + " C9R ON C9R.C9R_FILIAL = ? AND C9R.C9R_ID = C9Q.C9Q_ID AND C9R.C9R_VERSAO = C9Q.C9Q_VERSAO AND C9R.C9R_RECIBO = C9Q.C9Q_RECIBO AND C9R.C9R_DTACOR = C9Q.C9Q_DTACOR AND C9R.C9R_TPACOR = C9Q.C9Q_TPACOR AND C9R.C9R_COMPAC = C9Q.C9Q_COMPAC AND C9R.C9R_PERREF = C9Q.C9Q_PERREF AND C9R.C9R_ESTABE = C9Q.C9Q_ESTABE AND C9R.C9R_LOTACA = C9Q.C9Q_LOTACA AND C9R.C9R_TRABAL = C9Q.C9Q_TRABAL AND C9R.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE C91.C91_FILIAL = ? AND C91.C91_PERAPU >= ? AND C91.C91_PERAPU <= ? "
    cQuery += cWhereCpf
    cQuery += " AND C91.C91_ATIVO = '1' AND C91.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY C91.C91_TRABAL, C91.C91_PERAPU, T14.T14_IDEDMD, C9R.C9R_CODRUB "

    oStmt := FWExecStatement():New( ChangeQuery( cQuery ) )
    oStmt:SetString( 1, cFilC9Q )
    oStmt:SetString( 2, cFilC9R )
    oStmt:SetString( 3, cFil )
    oStmt:SetString( 4, cPerIni )
    oStmt:SetString( 5, cPerFim )

    nPar := 6

    If lHasTrab
        oStmt:SetIn( nPar, aTrabal )
        nPar++
    EndIf

    If lHasCpf
        oStmt:SetIn( nPar, aCpf )
    EndIf

    cAliasQry := oStmt:OpenAlias()

    If oFirstHead != Nil
        HMClean( oFirstHead )
        FreeObj( oFirstHead )
        oFirstHead := Nil
    EndIf
    
    oFirstHead := THashMap():New()

    If !Empty( cAliasQry )
        
        While !( cAliasQry )->( EoF() )
            
            cTrabal := AllTrim( ( cAliasQry )->TRABAL )
            cCpfStr := AllTrim( ( cAliasQry )->CPF )
            cPerApu := AllTrim( ( cAliasQry )->PERAPU )
            cIdEdmd := AllTrim( ( cAliasQry )->IDEDMD )

            cHeaderKey := "Q2|" + ;
                          IIf( !Empty( cTrabal ), "T|" + cTrabal, "C|" + cCpfStr ) + "|" + ;
                          cPerApu + "|" + ;
                          cIdEdmd

            cHeaderId := AllTrim( ( cAliasQry )->HEADER_ID )

            If oFirstHead:Get( cHeaderKey, @cFirstId )
                If cHeaderId != cFirstId
                    ( cAliasQry )->( DbSkip() )
                    Loop
                EndIf
            Else
                oFirstHead:Set( cHeaderKey, cHeaderId )
            EndIf

            cIdEdmd    := AllTrim( ( cAliasQry )->IDEDMD )
            cCodCat    := IIf( ValType( ( cAliasQry )->CODCAT ) == "C", AllTrim( ( cAliasQry )->CODCAT ), "" )
            cCatEFD    := TAFCacheFast( "C87_COD", cFil, cCodCat )
            cIndRRA    := AllTrim( ( cAliasQry )->INDRRA )
            cIndApurIR := AllTrim( ( cAliasQry )->APURIR )
            nValor     := ( cAliasQry )->VLRRUB

            If ( cAliasQry )->MV == "1" 
                cCodRubr := ( cAliasQry )->RUBRIC
                cMvLoad  := "MV"
            Else
                cCodRubr := ( cAliasQry )->CODRUB
                cMvLoad  := ""
            EndIf

            If !Empty( cTrabal )
                cKey := "ANT1200|" + cTrabal + "|" + cPerApu + "|" + cIdEdmd
                If oMap:Get( cKey, @aRows )
                    aAdd( aRows, { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } )
                Else
                    oMap:Set( cKey, { { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } } )
                EndIf
            EndIf

            If !Empty( cCpfStr ) .And. cCpfStr != cTrabal
                cKey := "ANT1200|" + cCpfStr + "|" + cPerApu + "|" + cIdEdmd
                If oMap:Get( cKey, @aRows )
                    aAdd( aRows, { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } )
                Else
                    oMap:Set( cKey, { { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } } )
                EndIf
            EndIf

            ( cAliasQry )->( DbSkip() )
        EndDo
        
        ( cAliasQry )->( DbCloseArea() )

    EndIf

    If oStmt != Nil
        oStmt:Destroy()
        FreeObj( oStmt )
        oStmt := Nil
    EndIf

    // =========================================================================
    // QUERY 3: TAFPer2299 (Desligamentos CMD e T05)
    // =========================================================================
    cQuery := " SELECT "
    cQuery += "     CMD.CMD_ID AS HEADER_ID, CMD.CMD_FUNC AS TRABAL, CMD.CMD_DTDESL AS PERAPU, "
    cQuery += "     T06.T06_IDEDMD AS IDEDMD, T06.T06_INDRRA AS INDRRA, "
    cQuery += "     T05.T05_CODRUB AS CODRUB, T05.T05_APURIR AS APURIR, T05.T05_VLRRUB AS VLRRUB "
    cQuery += " FROM " + RetSqlName( "CMD" ) + " CMD "
    cQuery += " INNER JOIN " + RetSQLName( "T06" ) + " T06 ON T06.T06_FILIAL = CMD.CMD_FILIAL AND T06.T06_ID = CMD.CMD_ID AND T06.T06_VERSAO = CMD.CMD_VERSAO AND T06.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "T3G" ) + " T3G ON T3G.T3G_FILIAL = T06.T06_FILIAL AND T3G.T3G_ID = T06.T06_ID AND T3G.T3G_VERSAO = T06.T06_VERSAO AND T3G.T3G_RECPAG = T06.T06_IDEDMD AND T3G.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "T05" ) + " T05 ON T05.T05_FILIAL = T3G.T3G_FILIAL AND T05.T05_ID = T3G.T3G_ID AND T05.T05_VERSAO = T3G.T3G_VERSAO AND T05.T05_RECPAG = T3G.T3G_RECPAG AND T05.T05_ESTABE = T3G.T3G_ESTABE AND T05.T05_LOTTRB = T3G.T3G_LOTTRB AND T05.D_E_L_E_T_ = ' ' "   
    cQuery += " WHERE CMD.CMD_FILIAL = ? AND CMD.CMD_DTDESL >= ? AND CMD.CMD_DTDESL <= ? AND CMD.CMD_ATIVO = '1' AND CMD.D_E_L_E_T_ = ' ' AND CMD.CMD_FUNC IN (?) "
    cQuery += " ORDER BY CMD.CMD_FUNC, CMD.CMD_DTDESL, T06.T06_IDEDMD, T05.T05_CODRUB "

    oStmt := FWExecStatement():New( ChangeQuery( cQuery ) )
    oStmt:SetString( 1, cFil )
    oStmt:SetString( 2, cPerIniSQL )
    oStmt:SetString( 3, cPerFimSQL )
    oStmt:SetIn( 4, aTrabal )   

    cAliasQry := oStmt:OpenAlias()
    
    If oFirstHead != Nil
        HMClean( oFirstHead )
        FreeObj( oFirstHead )
        oFirstHead := Nil
    EndIf
    
    oFirstHead := THashMap():New()

    If !Empty( cAliasQry )

        While !( cAliasQry )->( EoF() )

            cTrabal := AllTrim( ( cAliasQry )->TRABAL )
            cCpfStr := AllTrim( TAFCacheFast( "CPF_BENEFI", cFil, cTrabal ) )
            cPerApu := SubStr( ( cAliasQry )->PERAPU, 1, 6 )
            cIdEdmd := AllTrim( ( cAliasQry )->IDEDMD )
            
            cHeaderKey := "Q3|" + cTrabal + "|" + cPerApu + "|" + cIdEdmd
            cHeaderId  := AllTrim( ( cAliasQry )->HEADER_ID )
            If oFirstHead:Get( cHeaderKey, @cFirstId )
                If cHeaderId != cFirstId
                    ( cAliasQry )->( DbSkip() )
                    Loop
                EndIf
            Else
                oFirstHead:Set( cHeaderKey, cHeaderId )
            EndIf

            cCatCUP    := TAFCacheFast( "CUP_CAT", cFil, cTrabal )
            cCatEFD    := TAFCacheFast( "C87_COD", cFil, cCatCUP )
            cIndRRA    := AllTrim( ( cAliasQry )->INDRRA )
            cIndApurIR := AllTrim( ( cAliasQry )->APURIR )
            nValor     := ( cAliasQry )->VLRRUB
            cCodRubr   := ( cAliasQry )->CODRUB
            cMvLoad    := ""

            // Payload fiscal principal: prioriza matricula; usa CPF apenas se a origem nao tiver matricula
            cMainKeyID := IIf( !Empty( cTrabal ), cTrabal, cCpfStr )

            If !Empty( cMainKeyID )
                cKey := "PER2299|" + cMainKeyID + "|" + cPerApu + "|" + cIdEdmd
                If oMap:Get( cKey, @aRows )
                    aAdd( aRows, { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } )
                Else
                    oMap:Set( cKey, { { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } } )
                EndIf
            EndIf

            // Indice auxiliar seguro: CPF -> Matricula unica
            If !Empty( cTrabal ) .And. !Empty( cCpfStr ) .And. cCpfStr != cTrabal
                cIdxKey     := "IDX2299|" + cCpfStr + "|" + cPerApu + "|" + cIdEdmd
                cExistTrab  := ""

                If oMap:Get( cIdxKey, @cExistTrab )
                    If cExistTrab != cTrabal
                        oMap:Set( cIdxKey, "#AMBIG" )
                    EndIf
                Else
                    oMap:Set( cIdxKey, cTrabal )
                EndIf
            EndIf
            
            ( cAliasQry )->( DbSkip() )
        EndDo

        ( cAliasQry )->( DbCloseArea() )

    EndIf

    If oStmt != Nil
        oStmt:Destroy()
        FreeObj( oStmt )
        oStmt := Nil
    EndIf

    // =========================================================================
    // QUERY 4: TAFAnt2299 (Desligamentos Retroativos CMD e T5S)
    // =========================================================================
    cQuery := " SELECT "
    cQuery += "     CMD.CMD_ID AS HEADER_ID, CMD.CMD_FUNC AS TRABAL, CMD.CMD_DTDESL AS PERAPU, "
    cQuery += "     T06.T06_IDEDMD AS IDEDMD, T06.T06_INDRRA AS INDRRA, "
    cQuery += "     T5S.T5S_CODRUB AS CODRUB, T5S.T5S_APURIR AS APURIR, T5S.T5S_VLRRUB AS VLRRUB "
    cQuery += " FROM " + RetSqlName( "CMD" ) + " CMD "
    cQuery += " INNER JOIN " + RetSQLName( "T06" ) + " T06 ON T06.T06_FILIAL = CMD.CMD_FILIAL AND T06.T06_ID = CMD.CMD_ID AND T06.T06_VERSAO = CMD.CMD_VERSAO AND T06.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "T5I" ) + " T5I ON T5I.T5I_FILIAL = T06.T06_FILIAL AND T5I.T5I_ID = T06.T06_ID AND T5I.T5I_VERSAO = T06.T06_VERSAO AND T5I.T5I_IDEDMD = T06.T06_IDEDMD AND T5I.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "T5J" ) + " T5J ON T5J.T5J_FILIAL = T5I.T5I_FILIAL AND T5J.T5J_ID = T5I.T5I_ID AND T5J.T5J_VERSAO = T5I.T5I_VERSAO AND T5J.T5J_IDEDMD = T5I.T5I_IDEDMD AND T5J.T5J_DTACCO = T5I.T5I_DTACCO AND T5J.T5J_TPACCO = T5I.T5I_TPACCO AND T5J.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "T5Q" ) + " T5Q ON T5Q.T5Q_FILIAL = T5J.T5J_FILIAL AND T5Q.T5Q_ID = T5J.T5J_ID AND T5Q.T5Q_VERSAO = T5J.T5J_VERSAO AND T5Q.T5Q_IDEDMD = T5J.T5J_IDEDMD AND T5Q.T5Q_DTACCO = T5J.T5J_DTACCO AND T5Q.T5Q_TPACCO = T5J.T5J_TPACCO AND T5Q.T5Q_PERREF = T5J.T5J_PERREF AND T5Q.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "T5S" ) + " T5S ON T5S.T5S_FILIAL = T5Q.T5Q_FILIAL AND T5S.T5S_ID = T5Q.T5Q_ID AND T5S.T5S_VERSAO = T5Q.T5Q_VERSAO AND T5S.T5S_IDEDMD = T5Q.T5Q_IDEDMD AND T5S.T5S_DTACCO = T5Q.T5Q_DTACCO AND T5S.T5S_TPACCO = T5Q.T5Q_TPACCO AND T5S.T5S_PERREF = T5Q.T5Q_PERREF AND T5S.T5S_ESTABE = T5Q.T5Q_ESTABE AND T5S.T5S_LOTTRB = T5Q.T5Q_LOTTRB AND T5S.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE CMD.CMD_FILIAL = ? AND CMD.CMD_DTDESL >= ? AND CMD.CMD_DTDESL <= ? AND CMD.CMD_ATIVO = '1' AND CMD.D_E_L_E_T_ = ' ' AND CMD.CMD_FUNC IN (?) "
    cQuery += " ORDER BY CMD.CMD_FUNC, CMD.CMD_DTDESL, T06.T06_IDEDMD, T5S.T5S_CODRUB "

    oStmt := FWExecStatement():New( ChangeQuery( cQuery ) )
    oStmt:SetString( 1, cFil )
    oStmt:SetString( 2, cPerIniSQL )
    oStmt:SetString( 3, cPerFimSQL )
    oStmt:SetIn( 4, aTrabal )

    cAliasQry := oStmt:OpenAlias()
    
    If oFirstHead != Nil
        HMClean( oFirstHead )
        FreeObj( oFirstHead )
        oFirstHead := Nil
    EndIf
    
    oFirstHead := THashMap():New()

    If !Empty( cAliasQry )

        While !( cAliasQry )->( EoF() )

            cTrabal := AllTrim( ( cAliasQry )->TRABAL )
            cCpfStr := AllTrim( TAFCacheFast( "CPF_BENEFI", cFil, cTrabal ) ) 
            cPerApu := SubStr( ( cAliasQry )->PERAPU, 1, 6 )
            cIdEdmd := AllTrim( ( cAliasQry )->IDEDMD )
            
            cHeaderKey := "Q4|" + cTrabal + "|" + cPerApu + "|" + cIdEdmd
            cHeaderId  := AllTrim( ( cAliasQry )->HEADER_ID )
            If oFirstHead:Get( cHeaderKey, @cFirstId )
                If cHeaderId != cFirstId
                    ( cAliasQry )->( DbSkip() )
                    Loop
                EndIf
            Else
                oFirstHead:Set( cHeaderKey, cHeaderId )
            EndIf

            cCatCUP    := TAFCacheFast( "CUP_CAT", cFil, cTrabal )
            cCatEFD    := TAFCacheFast( "C87_COD", cFil, cCatCUP )
            cIndRRA    := AllTrim( ( cAliasQry )->INDRRA )
            cIndApurIR := AllTrim( ( cAliasQry )->APURIR )
            nValor     := ( cAliasQry )->VLRRUB
            cCodRubr   := ( cAliasQry )->CODRUB
            cMvLoad    := ""

            // Payload fiscal principal: prioriza matricula; usa CPF apenas se a origem nao tiver matricula
            cMainKeyID := IIf( !Empty( cTrabal ), cTrabal, cCpfStr )

            If !Empty( cMainKeyID )
                cKey := "ANT2299|" + cMainKeyID + "|" + cPerApu + "|" + cIdEdmd
                If oMap:Get( cKey, @aRows )
                    aAdd( aRows, { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } )
                Else
                    oMap:Set( cKey, { { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } } )
                EndIf
            EndIf

            // Indice auxiliar seguro: CPF -> Matricula unica
            If !Empty( cTrabal ) .And. !Empty( cCpfStr ) .And. cCpfStr != cTrabal
                cIdxKey     := "IDXANT2299|" + cCpfStr + "|" + cPerApu + "|" + cIdEdmd
                cExistTrab  := ""

                If oMap:Get( cIdxKey, @cExistTrab )
                    If cExistTrab != cTrabal
                        oMap:Set( cIdxKey, "#AMBIG" )
                    EndIf
                Else
                    oMap:Set( cIdxKey, cTrabal )
                EndIf
            EndIf

            ( cAliasQry )->( DbSkip() )
        EndDo

        ( cAliasQry )->( DbCloseArea() )

    EndIf

    If oStmt != Nil
        oStmt:Destroy()
        FreeObj( oStmt )
        oStmt := Nil
    EndIf

    // =========================================================================
    // QUERY 5: TAFPer2399 (Trabalhador sem Vinculo T92 e CMK)
    // =========================================================================
    cQuery := " SELECT "
    cQuery += "     T92.T92_ID AS HEADER_ID, T92.T92_TRABAL AS TRABAL, T92.T92_DTERAV AS PERAPU, "
    cQuery += "     T3I.T3I_IDEDMD AS IDEDMD, T3I.T3I_INDRRA AS INDRRA, "
    cQuery += "     CMK.CMK_CODRUB AS CODRUB, CMK.CMK_APURIR AS APURIR, CMK.CMK_VLRRUB AS VLRRUB "
    cQuery += " FROM " + RetSQLName( "T92" ) + " T92 "
    cQuery += " INNER JOIN " + RetSQLName( "T3I" ) + " T3I ON T3I.T3I_FILIAL = T92.T92_FILIAL AND T3I.T3I_ID = T92.T92_ID AND T3I.T3I_VERSAO = T92.T92_VERSAO AND T3I.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN " + RetSQLName( "CMK" ) + " CMK ON CMK.CMK_FILIAL = T3I.T3I_FILIAL AND CMK.CMK_ID = T3I.T3I_ID AND CMK.CMK_VERSAO = T3I.T3I_VERSAO AND CMK.CMK_IDEDMD = T3I.T3I_IDEDMD AND CMK.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE T92.T92_FILIAL = ? AND T92.T92_DTERAV >= ? AND T92.T92_DTERAV <= ? AND T92.T92_ATIVO = '1' AND T92.D_E_L_E_T_ = ' ' AND T92.T92_TRABAL IN (?) "
    cQuery += " ORDER BY T92.T92_TRABAL, T92.T92_DTERAV, T3I.T3I_IDEDMD, CMK.CMK_CODRUB "

    oStmt := FWExecStatement():New( ChangeQuery( cQuery ) )
    oStmt:SetString( 1, cFil )
    oStmt:SetString( 2, cPerIniSQL )
    oStmt:SetString( 3, cPerFimSQL )
    oStmt:SetIn( 4, aTrabal )

    cAliasQry := oStmt:OpenAlias()
    
    If oFirstHead != Nil
        HMClean( oFirstHead )
        FreeObj( oFirstHead )
        oFirstHead := Nil
    EndIf
    
    oFirstHead := THashMap():New()

    If !Empty( cAliasQry )

        While !( cAliasQry )->( EoF() )

            cTrabal := AllTrim( ( cAliasQry )->TRABAL )
            cCpfStr := AllTrim( TAFCacheFast( "CPF_BENEFI", cFil, cTrabal ) ) 
            cPerApu := SubStr( ( cAliasQry )->PERAPU, 1, 6 )
            cIdEdmd := AllTrim( ( cAliasQry )->IDEDMD )
            
            cHeaderKey := "Q5|" + cTrabal + "|" + cPerApu + "|" + cIdEdmd
            cHeaderId  := AllTrim( ( cAliasQry )->HEADER_ID )
            If oFirstHead:Get( cHeaderKey, @cFirstId )
                If cHeaderId != cFirstId
                    ( cAliasQry )->( DbSkip() )
                    Loop
                EndIf
            Else
                oFirstHead:Set( cHeaderKey, cHeaderId )
            EndIf

            cCatC9V := AllTrim( TAFCacheFast( "C9V_CAT", cFil, cTrabal ) )

            If Empty( cCatC9V )
                cCatCUP := AllTrim( TAFCacheFast( "CUP_CAT", cFil, cTrabal ) )
                cCatEFD := AllTrim( TAFCacheFast( "C87_COD", cFil, cCatCUP ) )
            Else
                cCatCUP := ""
                cCatEFD := AllTrim( TAFCacheFast( "C87_COD", cFil, cCatC9V ) )
            EndIf

            cIndRRA    := AllTrim( ( cAliasQry )->INDRRA )
            cIndApurIR := AllTrim( ( cAliasQry )->APURIR )
            
            // TSV sem apuracao assume Mensal ("0")
            If Empty( cIndApurIR )
                cIndApurIR := "0"
            EndIf
            
            nValor     := ( cAliasQry )->VLRRUB
            cCodRubr   := ( cAliasQry )->CODRUB
            cMvLoad    := ""
            
            // Payload fiscal principal: prioriza matricula; usa CPF apenas se a origem nao tiver matricula
            cMainKeyID := IIf( !Empty( cTrabal ), cTrabal, cCpfStr )

            If !Empty( cMainKeyID )
                cKey := "PER2399|" + cMainKeyID + "|" + cPerApu + "|" + cIdEdmd
                If oMap:Get( cKey, @aRows )
                    aAdd( aRows, { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } )
                Else
                    oMap:Set( cKey, { { cCatEFD, cIndRRA, cIndApurIR, nValor, cCodRubr, cMvLoad } } )
                EndIf
            EndIf

            // Indice auxiliar seguro: CPF -> Matricula unica
            If !Empty( cTrabal ) .And. !Empty( cCpfStr ) .And. cCpfStr != cTrabal
                cIdxKey     := "IDX2399|" + cCpfStr + "|" + cPerApu + "|" + cIdEdmd
                cExistTrab  := ""

                If oMap:Get( cIdxKey, @cExistTrab )
                    If cExistTrab != cTrabal
                        oMap:Set( cIdxKey, "#AMBIG" )
                    EndIf
                Else
                    oMap:Set( cIdxKey, cTrabal )
                EndIf
            EndIf
            
            ( cAliasQry )->( DbSkip() )
        EndDo

        ( cAliasQry )->( DbCloseArea() )

    EndIf
    
    If oStmt != Nil
        oStmt:Destroy()
        FreeObj( oStmt )
        oStmt := Nil
    EndIf

    If oFirstHead != Nil
        HMClean( oFirstHead )
        FreeObj( oFirstHead )
        oFirstHead := Nil
    EndIf

    RestArea( aAreaAnt )

    TafConOut( "[TAFBulkPayroll] Folha de Pagamento gerada em memoria." )

Return oMap

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFPerRefLot
@type        Static Function
@description Localiza o menor V6M_PERREF real do lote ja carregado
             no HashMap, para abrir a janela do Bulk da Folha apenas
             no intervalo realmente necessario.

@author     Denis R. Oliveira
@since      05/03/2026
@version    1.0

@param      a1210, Array, Lote atual do S-1210.
@param      oHashMap, Object, HashMap ja carregado pelo TAFBulkMap.
@return     Character, Menor PERREF encontrado no formato YYYYMM.
/*/
//-------------------------------------------------------------------
Static Function TAFPerRefLot( a1210 As Array, oHashMap As Object ) As Character

    //-------------------------------------------------------------------------
    // Declaração de Variáveis
    //-------------------------------------------------------------------------
    Local aRows   As Array
    Local cKey    As Character
    Local cPerMin As Character
    Local cPerRef As Character
    Local jLine   As Json
    Local nI      As Numeric
    Local nJ      As Numeric

    //-------------------------------------------------------------------------
    // Inicialização de Parâmetros (Defaults)
    //-------------------------------------------------------------------------
    Default a1210    := {}
    Default oHashMap := Nil

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis Locais
    //-------------------------------------------------------------------------
    aRows   := {}
    cKey    := ""
    cPerMin := ""
    cPerRef := ""
    jLine   := Nil
    nI      := 0
    nJ      := 0

    // Bloqueia execucao se nao ha dados para processar
    If oHashMap == Nil .Or. Empty( a1210 ); Return cPerMin; EndIf

    For nI := 1 To Len( a1210 )

        If ValType( a1210[nI] ) == "A" .And. Len( a1210[nI] ) >= 3

            cKey := "V6M|" + ;
                    AllTrim( cValToChar( a1210[nI][1] ) ) + "|" + ;
                    AllTrim( cValToChar( a1210[nI][2] ) ) + "|" + ;
                    AllTrim( cValToChar( a1210[nI][3] ) )

            If oHashMap:Get( cKey, @aRows ) .And. ValType( aRows ) == "A"

                For nJ := 1 To Len( aRows )

                    jLine := aRows[nJ]

                    // Checa se jLine e um JSON (ou Objeto tradicional) valido
                    If jLine != Nil .And. ( ValType( jLine ) == "J" .Or. ValType( jLine ) == "O" )
                        
                        cPerRef := Left( StrTran( AllTrim( cValToChar( jLine["V6M_PERREF"] ) ), "-", "" ), 6 )

                        // Tratamento para 13º salário
                        // Permite que períodos anuais (Tamanho 4) sejam reconhecidos
                        If ( Len( cPerRef ) == 6 .Or. Len( cPerRef ) == 4 ) .And. Val( cPerRef ) > 0
                            If Empty( cPerMin ) .Or. cPerRef < cPerMin
                                cPerMin := cPerRef
                            EndIf
                        EndIf
            
                    EndIf

                Next nJ

            EndIf

        EndIf

    Next nI

Return cPerMin


//---------------------------------------------------------------------
/*/{Protheus.doc} TAFCleanID
@type           Static Function
@description    Limpa CPF/CNPJ para uso em chaves semanticas.

@author         Denis R. de Oliveira
@since          23/03/2026
@version        1.0

@param      cVal, Character, CPF/CNPJ que será limpado
@return     cRet, Character, CPF/CNPJ após a limpeza
/*/
//---------------------------------------------------------------------
Static Function TAFCleanID( cVal As Character ) As Character

    Local cRet As Character

    Default cVal := ""

    cRet := AllTrim( cVal )
    cRet := StrTran( cRet, ".", "" )
    cRet := StrTran( cRet, "-", "" )
    cRet := StrTran( cRet, "/", "" )
    cRet := StrTran( cRet, " ", "" )

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTok
@type           Static Function
@description    Extrai um token de uma string com base em um delimitador.
                Criada para suprir a ausência da função customizada original.

@author         Denis R. de Oliveira
@since          23/03/2026
@version        1.0

@param          cString, Character, String original
@param          nIndex, Numeric, Posição do token desejado
@param          cDelim, Character, Caractere delimitador
@return         Character, Token extraído
/*/
//---------------------------------------------------------------------
Static Function GetTok(cString As Character, nIndex As Numeric, cDelim As Character)
    
    Local aTokens   as array
    Local cRet      as character

    Default cString := ""
    Default nIndex  := 1
    Default cDelim  := "|"

    aTokens := {}
    cRet    := ""

    // Utiliza a função nativa do AdvPL para quebrar a string em um array
    aTokens := StrTokArr(cString, cDelim)

    // Valida se o array possui o índice solicitado para evitar error.log
    If Len(aTokens) >= nIndex
        cRet := aTokens[nIndex]
    EndIf

Return cRet
