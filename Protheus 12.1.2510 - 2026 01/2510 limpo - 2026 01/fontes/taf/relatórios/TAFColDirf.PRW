#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "PRTOPDEF.CH"

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
// VARIÁVEIS ESTÁTICAS (CACHE DE MÓDULO)
// Visíveis para todas as funções deste arquivo (TafMainLoad e TafClearCache)
//---------------------------------------------------------------------
Static hCacheC87_Mod        as object
Static hCacheC8R_Mod        as object
Static hCacheC8U_Mod        as object
Static hCacheC9V_Mod        as object
Static hClasTri_Cache_Mod   as object
Static hCacheC6R_Mod        as object

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFColDirf
@type           Function
@description    Realiza a coleta e processamento de dados para a DIRF (Eventos S-1210 e S-5002).
                A rotina é responsável pela orquestração do processo, gerenciando:
                - Paginação de dados (Batch processing);
                - Controle de memória e Cache;
                - Bloqueio de concorrência (Semáforo/Lock);
                - Tentativas de gravação com resiliência (Retry).

@param          cGroup, Character, Grupo de empresas
@param          cFil  , Character, Filial

@return         Logical, .T. = Processamento com sucesso; .F. = Erro ou inconsistência bloqueante.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@see            TAFColQry, TAFGrvDIRF, TAFinfosGrid
/*/
//---------------------------------------------------------------------
Function TAFColDirf( cGroup as character, cFil as character ) as logical

    // Arrays de Dados e Controle
    Local a1210         as array    // Dados brutos retornados pela Query (Lote atual)
    Local aAnalitico    as array    // Dados processados e transformados (Prontos para gravação)
    Local aTable        as array    // Lista das tabelas principais a processar (Ordem de execução)
    Local aIncons       as array    // Lista acumulada de inconsistências/erros
    
    // Controles de Loop e Paginação
    Local nX            as numeric  // Contador de tabelas
    Local nRetry        as numeric  // Contador de tentativas de gravação (Resiliência)
    Local nTotReg       as numeric  // Total de registros pendentes na tabela
    Local nPag          as numeric  // Número da página atual
    Local nPagTot       as numeric  // Total de páginas calculado
    
    // Controles de Tempo e Estado
    Local nTimeIni      as numeric  // Timestamp de início do processo
    Local nTimeFim      as numeric  // Timestamp de fim do processo
    Local lLibAcsRel    as logical  // Flag de controle geral (Sucesso/Erro)
    Local lOk           as logical  // Flag de sucesso da operação unitária
    Local cAlias        as character // Alias da tabela em processamento (T3P/T2G)

    // Variáveis de Tratamento de Erro
    Local bError        as block    //Bloco de erro
    Local bErrorOld     as block    // Bloco de erro
    
    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cGroup := ""
    Default cFil   := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    a1210       := {}
    aAnalitico  := {}
    aTable      := { "T3P", "T2G" } // Define a ordem: 1º S-1210, 2º S-5002
    aIncons     := {}

    nX          := 0
    nRetry      := 0
    nTotReg     := 0
    nPag        := 0
    nPagTot     := 0
    
    lLibAcsRel  := .T. // Assume sucesso inicialmente
    lOk         := .F.
    cAlias      := ""
    
    nTimeIni    := 0
    nTimeFim    := 0

    //-------------------------------------------------------------------------
    // Preparação do Ambiente (RPC)
    //-------------------------------------------------------------------------
    // Garante que o ambiente esteja montado corretamente para a empresa/filial alvo
    If !Empty( cGroup )
        RPCSetType( 3 )
        RPCSetEnv( cGroup, cFil,, "TAF", "TAFColDirf" )
    EndIf

    //-------------------------------------------------------------------------
    // Proteção contra travamento
    //-------------------------------------------------------------------------
    // Define um bloco de código que será executado se houver erro fatal.
    // 1. Destrava o parametro MV_COLDIRF para .T. (Liberado)
    // 2. Remove o Lock de exclusividade (Lock_DIRF)
    // 3. Executa o erro padrão do sistema (Eval) para gravar o log corretamente
    bErrorOld := ErrorBlock() 
    bError := {|e| UnLockByName("Lock_DIRF"), PutMV("MV_COLDIRF", .T.), Eval(bErrorOld, e) }
    ErrorBlock( bError ) 

    // Limpa caches de execuções anteriores para garantir integridade
    TafClearCache()

    // Inicia cronômetro de performance
    nTimeIni := Seconds()

    TafConOut( "=========================================" )
    TafConOut( "TAFColDirf - INÍCIO DO PROCESSAMENTO     " )
    TafConOut( "=========================================" )
    
    //-------------------------------------------------------------------------
    // Controle de Concorrência (Lock)
    //-------------------------------------------------------------------------
    // Sinaliza via parâmetro MV que o relatório está em uso
    PutMV( "MV_COLDIRF", .F. )

    // Tenta obter acesso exclusivo ao processo. 
    If !LockByName( "Lock_DIRF", .T., .T. )
        TafConOut( "[TAFColDirf] ERRO: Processo bloqueado por outra execução." )
        ErrorBlock( bErrorOld )  // Restaura ErrorBlock
        PutMV( "MV_COLDIRF", .T. )
        Return .F.
    EndIf

    //=========================================================================
    // LOOP PRINCIPAL: Processa Tabela por Tabela
    //=========================================================================
    For nX := 1 To Len( aTable )

        cAlias := aTable[nX]

        //---------------------------------------------------------------------
        // 1. Análise de Volume (Count)
        //---------------------------------------------------------------------
        // Conta quantos registros ainda precisam ser processados (Status pendente)
        nTotReg := TAFCountRegs( cAlias )

        // Se não houver nada pendente, pula para a próxima tabela imediatamente
        If nTotReg == 0
            TafConOut( "[" + cAlias + "] Nenhum registro pendente para processar." )
            Loop
        EndIf

        //---------------------------------------------------------------------
        // 2. Cálculo de Paginação (Lotes de 100)
        //---------------------------------------------------------------------
        // Divide o total por 100 e arredonda para cima para definir o número de lotes
        nPagTot := Ceiling( nTotReg / 100 )

        TafConOut( "[" + cAlias + "] Volume Total: " + cValToChar( nTotReg ) + " registros" )
        TafConOut( "[" + cAlias + "] Paginação: " + cValToChar( nPagTot ) + " lotes de 100" )

        //---------------------------------------------------------------------
        // 3. Loop de Paginação (Processamento em Lotes)
        //---------------------------------------------------------------------
        For nPag := 1 To nPagTot

            TafConOut( "" )
            TafConOut( "[" + cAlias + "] >>> LOTE " + cValToChar( nPag ) + " de " + cValToChar( nPagTot ) + " <<<" )

            // Reinicializa arrays para garantir memória limpa a cada lote
            ASize( a1210, 0 )
            a1210 := {}
            
            ASize( aAnalitico, 0 )
            aAnalitico := {}
            
            ASize( aIncons, 0 )
            aIncons := {}
            
            lOk := .F.

            //-----------------------------------------------------------------
            // A. Coleta de Dados (Query)
            //-----------------------------------------------------------------
            // Busca os próximos 100 registros pendentes
            a1210 := TAFColQry( cAlias )
            
            // [SEGURANÇA] Se a query não retornou dados (ex: contagem defasada), interrompe
            If Len( a1210 ) == 0
                TafConOut( "[" + cAlias + "] Fim dos registros detectado (Query vazia)." )
                Exit
            EndIf

            TafConOut( "[" + cAlias + "] Query retornou: " + cValToChar( Len( a1210 ) ) + " registros" )

            //-----------------------------------------------------------------
            // B. Processamento de Regras (Grids)
            //-----------------------------------------------------------------
            // Processa as tabelas filhas e popula o array aAnalitico
            // Nota: Utiliza otimizações de Cache de Estrutura internamente
            TAFinfosGrid( a1210, @aAnalitico, cAlias )

            TafConOut( "[" + cAlias + "] Analítico gerado: " + cValToChar( Len( aAnalitico ) ) + " registros" )

            //-----------------------------------------------------------------
            // C. Gravação Persistente (Com Retry)
            //-----------------------------------------------------------------
            // Só tenta gravar se houver dados processados
            If Len( aAnalitico ) > 0

                lOk := .F.

                // Loop de Retry: Tenta gravar até 10 vezes em caso de Deadlock ou falha de I/O
                For nRetry := 1 To 10

                    TafConOut( "[" + cAlias + "] Gravando lote... (Tentativa " + cValToChar( nRetry ) + "/10)" )

                    // Chama a rotina de gravação
                    TafGrvDIRF( aAnalitico, a1210, cAlias, @lOk, @aIncons, ( nPag == 1 ) )

                    // Se gravou com sucesso, sai do loop de retry
                    If lOk
                        TafConOut( "[" + cAlias + "] Sucesso na gravação do lote." )
                        Exit
                    EndIf

                    // Se falhou, loga e aguarda (Backoff)
                    TafConOut( "[" + cAlias + "] [AVISO] Falha na gravação. Retentando em " + cValToChar(nRetry) + "s..." )
                    
                    // Aguarda tempo proporcional à tentativa (1s, 2s, 3s...)
                    If nRetry < 10
                        Sleep( nRetry * 1000 )
                    EndIf

                Next nRetry

                //-------------------------------------------------------------
                // Validação Pós-Gravação
                //-------------------------------------------------------------
                // Se falhou após todas as tentativas, marca erro crítico e aborta
                If !lOk
                    
                    TafConOut( "[TAFColDirf] [ERRO CRÍTICO] Falha persistente na gravação." )
                    
                    If Len( aIncons ) > 0
                        TafConOut( "[TAFColDirf] Detalhe: " + cValToChar( Len( aIncons ) ) + " inconsistências encontradas." )
                    EndIf
                    
                    lLibAcsRel := .F. // Sinaliza erro global
                    Exit // Aborta o loop de paginação desta tabela
                    
                EndIf

            Else
                TafConOut( "[" + cAlias + "] [AVISO] Nenhum dado analítico gerado para este lote (Lote ignorado)." )
            EndIf
            
            //-----------------------------------------------------------------
            // Limpeza de Memória (Fim do Lote)
            //-----------------------------------------------------------------
            // Força a liberação dos arrays grandes da memória
            ASize( a1210, 0 )
            ASize( aAnalitico, 0 )
            ASize( aIncons, 0 )
            
            a1210      := {}
            aAnalitico := {}
            aIncons    := {}
            
            // Pausa para aliviar I/O do Banco e Threads
            Sleep( 50 )

        Next nPag

        //---------------------------------------------------------------------
        // Verificação de Erro na Tabela
        //---------------------------------------------------------------------
        // Se a flag de sucesso foi desligada, interrompe o processamento geral
        If !lLibAcsRel
            TafConOut( "[TAFColDirf] Processamento abortado devido a erros na tabela " + cAlias )
            Exit
        EndIf

        TafConOut( "[" + cAlias + "] Tabela finalizada com sucesso." )

    Next nX

    //=========================================================================
    // FINALIZAÇÃO E LIBERAÇÃO
    //=========================================================================
    
    // Controla o parâmetro MV com base no sucesso total
    If lLibAcsRel
        PutMV( "MV_COLDIRF", .T. )
        TafConOut( "[TAFColDirf] Status: SUCESSO - Relatório liberado para uso." )
    Else
        TafConOut( "[TAFColDirf] Status: ERRO - Relatório permanece bloqueado para análise." )
    EndIf

    // Limpa caches após processamento para liberar memória
    TafClearCache()

    // Calcula tempo total de execução
    nTimeFim := Seconds()

    TafConOut( "" )
    TafConOut( "=========================================" )
    TafConOut( "TAFColDirf - PROCESSAMENTO CONCLUÍDO" )
    TafConOut( "Tempo Total: " + Transform( nTimeFim - nTimeIni, "@E 999,999.99" ) + " segundos" )
    TafConOut( "=========================================" )
    TafConOut( "" )

    // Destrava o ambiente (Fundamental para liberar o processo para outros usuários)
    UnLockByName( "Lock_DIRF" )

    // Encerra o ambiente RPC se foi aberto por esta rotina
    If !Empty( cGroup )
        RpcClearEnv()
    EndIf

Return lLibAcsRel

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFColQry
@type           Function
@description    Monta e executa a query SQL para coleta de dados dos eventos periódicos (S-1210) e consolidados (S-5002).
                A função realiza o tratamento de sintaxe para diferentes bancos de dados (MSSQL, Oracle, Postgres), 
                incluindo paginação otimizada para Oracle (ROW_NUMBER) e cache de posições de campos para performance.

@param          cAlias, Character, Alias da tabela principal a ser consultada ("T3P" para S-1210 ou "T2G" para S-5002).

@return         Array, Retorna um array multidimensional (a1210) contendo os registros coletados do banco.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@see            TAFColDirf
/*/
//---------------------------------------------------------------------
Function TAFColQry( cAlias as character ) as array

    //-------------------------------------------------------------------------
    // Declaração de Variáveis
    //-------------------------------------------------------------------------
    Local a1210         as array      // Array de retorno
    Local cQuery        as character  // String da Query SQL
    Local cWhere        as character  // Cláusula WHERE
    Local cOrder        as character  // Cláusula ORDER BY (SQL Server/Postgres)
    Local cOrderBy      as character  // Cláusula ORDER BY (Específica Oracle)
    Local cInnerSql     as character  // SQL Interno para paginação Oracle
    Local cAliasQry     as character  // Alias temporário para a query
    Local nProgress     as numeric    // Contador de registros
    
    Local cDB           as character  // Tipo do Banco de Dados

    Local cFiliaisIN    as character  // Lista formatada com as filiais
    
    // Variáveis de Controle e Performance (Cache de Posição de Campos)
    Local nPosFil       as numeric    // Posição: Filial
    Local nPosId        as numeric    // Posição: ID
    Local nPosVer       as numeric    // Posição: Versão
    Local nPosCpf       as numeric    // Posição: CPF
    Local nPosPer       as numeric    // Posição: Período
    Local nPosBen       as numeric    // Posição: Beneficiário (T3P)
    Local nPosEve       as numeric    // Posição: Evento (T3P)

    //-------------------------------------------------------------------------
    //  Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cAlias  := "" 

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    a1210       := {}
    cQuery      := ""
    cWhere      := ""
    cOrder      := ""
    cOrderBy    := ""
    cInnerSql   := ""
    cAliasQry   := GetNextAlias() // Gera alias único para evitar conflito
    nProgress   := 0
    
    // Identifica o banco para montar a query correta
    cDB         := IIf( Type("cMockDBType") == "C", Upper(cMockDBType), Upper(TcGetDB()) )

    //Obtêm as filiais 
    cFiliaisIN  := GetFiliaisIN()

    // Inicializa posições (serão preenchidas após abrir a query)
    nPosFil     := 0
    nPosId      := 0
    nPosVer     := 0
    nPosCpf     := 0
    nPosPer     := 0
    nPosBen     := 0
    nPosEve     := 0

    TafConOut( "[TAFColQry] Iniciando query para " + cAlias )

    //-------------------------------------------------------------------------
    // Tratamento para filiais
    //------------------------------------------------------------------------
    // Se a função retornar vazio (tabela totalmente compartilhada ou erro)
    If Empty(cFiliaisIN)
        // Se não tiver acesso ou der erro, usa a filial atual logada por segurança
        cFiliaisIN := "'" + xFilial(cAlias) + "'"
    EndIf

    //=========================================================================
    // 1. MONTAGEM DOS FILTROS (WHERE)
    // Garante que espaços em branco sejam respeitados na concatenação
    //=========================================================================
    cWhere := "WHERE " + cAlias + "_FILIAL IN (" + cFiliaisIN + ") "
    cWhere += "  AND " + cAlias + "_PERAPU >= '202501' "
    cWhere += "  AND " + cAlias + "_ATIVO = '1' "
    cWhere += "  AND " + cAlias + "_CHKDIR IN (' ', 'F') "
    cWhere += "  AND " + cAlias + ".D_E_L_E_T_ = ' ' "
    
    If cAlias == "T3P"
        cWhere += "  AND T3P_ORIEVE <> 'S2190' "
    EndIf

    //-------------------------------------------------------------------------
    // 2. DEFINIÇÃO DA ORDENAÇÃO
    //-------------------------------------------------------------------------
    // Para SQL Server / Postgres (Com "ORDER BY")
    cOrder   := ( "ORDER BY " + cAlias + "_PERAPU, " + cAlias + "_ID, " + cAlias + "_VERSAO " )
    
    // Para Oracle (Sem "ORDER BY", usado dentro da Window Function)
    cOrderBy := ( cAlias + "_PERAPU, " + cAlias + "_ID, " + cAlias + "_VERSAO" )
    
    //=========================================================================
    // 3. MONTAGEM DA QUERY PAGINADA (Por Banco)
    //=========================================================================
    Do Case
        
        //---------------------------------------------------------------------
        // MSSQL: Usa TOP
        //---------------------------------------------------------------------
        Case cDB == "MSSQL"
            cQuery := "SELECT TOP 100 * "
            cQuery += "FROM " + RetSQLName(cAlias) + " " + cAlias + " "
            cQuery += cWhere + " "
            cQuery += cOrder
    
        //---------------------------------------------------------------------
        // ORACLE: Usa Subquery com ROW_NUMBER()
        // NOTA: Esta estrutura é a padrão para paginação segura em Oracle.
        // A query interna (cInnerSql) seleciona os dados brutos.
        // A query externa filtra pelo número da linha (RN <= 100).
        //---------------------------------------------------------------------
        Case cDB == "ORACLE"
            // Query Interna: Seleciona dados + Filtros
            cInnerSql := "SELECT " + cAlias + ".* " // Garantir alias explicito na projeção interna se possível, ou * simples
            cInnerSql += "FROM " + RetSQLName( cAlias ) + " " + cAlias + " "
            cInnerSql += cWhere

            // Query Externa: Aplica paginação com Alias na tabela derivada final
            cQuery := "SELECT * FROM ( "
            cQuery += "  SELECT a.*, ROW_NUMBER() OVER (ORDER BY " + cOrderBy + ") RN "
            cQuery += "  FROM ( " + cInnerSql + " ) a "
            cQuery += ") TBL_PAG WHERE RN <= 100" // Alias TBL_PAG na externa é boa prática
                
        //---------------------------------------------------------------------
        // POSTGRES: Usa LIMIT
        //---------------------------------------------------------------------
        Case cDB $ "POSTGRES"
            cQuery := "SELECT * "
            cQuery += "FROM " + RetSQLName(cAlias) + " " + cAlias + " "
            cQuery += cWhere + " "
            cQuery += cOrder + " "
            cQuery += " LIMIT 100"
            
    EndCase

    //=========================================================================
    // 4. EXECUÇÃO DA QUERY
    //=========================================================================
    // ChangeQuery ajusta formatos de data e funções proprietárias do banco
    cQuery := ChangeQuery(cQuery)
    
    // Tenta abrir a query. Se falhar, o alias não será criado corretamente.
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T.)
    
    //=========================================================================
    // 5. LEITURA DOS DADOS (Com Segurança de Alias)
    //=========================================================================
    If Select( cAliasQry ) > 0
        
        //---------------------------------------------------------------------
        // Cache de FieldPos - Resolve a posição dos campos uma única vez 
        // Isso evita overhead de processamento em loops grandes.
        //---------------------------------------------------------------------
        If cAlias == "T3P"
            nPosFil := (cAliasQry)->( FieldPos( "T3P_FILIAL" ) )
            nPosId  := (cAliasQry)->( FieldPos( "T3P_ID" ) )
            nPosVer := (cAliasQry)->( FieldPos( "T3P_VERSAO" ) )
            nPosCpf := (cAliasQry)->( FieldPos( "T3P_CPF" ) )
            nPosPer := (cAliasQry)->( FieldPos( "T3P_PERAPU" ) )
            nPosBen := (cAliasQry)->( FieldPos( "T3P_BENEFI" ) )
            nPosEve := (cAliasQry)->( FieldPos( "T3P_EVENTO" ) )
        Else
            nPosFil := (cAliasQry)->( FieldPos( "T2G_FILIAL" ) )
            nPosId  := (cAliasQry)->( FieldPos( "T2G_ID" ) )
            nPosVer := (cAliasQry)->( FieldPos( "T2G_VERSAO" ) )
            nPosCpf := (cAliasQry)->( FieldPos( "T2G_CPFBEN" ) )
            nPosPer := (cAliasQry)->( FieldPos( "T2G_PERAPU" ) )
        EndIf
        
        (cAliasQry)->(DbGoTop())

        //---------------------------------------------------------------------
        // Loop de Carga do Array
        //---------------------------------------------------------------------
        While !(cAliasQry)->(EoF())
            
            nProgress++
            
            If cAlias == "T3P"
                // Usa FieldGet com a posição cacheada (Muito mais rápido)
                aAdd(a1210, {;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosFil ) ) ),;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosId  ) ) ),;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosVer ) ) ),;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosCpf ) ) ),;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosPer ) ) ),;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosBen ) ) ),;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosEve ) ) );
                })
            Else
                aAdd(a1210, {;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosFil ) ) ),;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosId  ) ) ),;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosVer ) ) ),;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosCpf ) ) ),;
                    AllTrim( ( cAliasQry )->( FieldGet( nPosPer ) ) );
                })
            EndIf
            
            (cAliasQry)->(DbSkip())

        EndDo
        
        // Fecha o alias para liberar memória
        ( cAliasQry )->( DbCloseArea() )
        
    Else
        // Log de erro crítico se o banco não devolver o alias
        TafConOut( "[TAFColQry] ERRO CRÍTICO: Nao foi possivel abrir a query para " + cAlias )
    EndIf
    
    TafConOut( "[TAFColQry] Processados " + cValToChar(nProgress) + " registros")

Return a1210

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFCountRegs
@type           Function
@description    Contabiliza o total de registros com status pendente de processamento na tabela informada.
                A função executa uma query direta (SELECT COUNT) para garantir performance e baixo consumo de memória.

@param          cAlias, Character, Alias da tabela alvo a ser consultada (Ex: "T3P", "T2G").

@return         Numeric, Retorna a quantidade de registros pendentes encontrados.

@author         Denis R. de Oliveira
@since          17/12/2025
@version        1.0
/*/
//---------------------------------------------------------------------
Function TAFCountRegs( cAlias as character ) as numeric

    Local cQuery        as character // String que armazenará o comando SQL
    Local cAliasCnt     as character // Nome do alias temporário para o resultado
    Local nTotReg       as numeric   // Variável de retorno (Total de registros)

    Local cFiliaisIN    as character // Lista formatada com as filiais
   
    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cAlias := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cQuery      := ""
    cAliasCnt   := GetNextAlias() // Obtém um nome de alias único no sistema
    nTotReg     := 0

    //-------------------------------------------------------------------------
    // Obtêm as filiais
    //-------------------------------------------------------------------------
    cFiliaisIN  := GetFiliaisIN()

    //-------------------------------------------------------------------------
    // Validação de Segurança
    //-------------------------------------------------------------------------
    // Se o alias não foi informado, retorna 0 imediatamente para evitar erro na query
    If Empty( cAlias )
        TafConOut( "[TAFCountRegs] [AVISO] Alias nao informado. Retornando 0." )
        Return 0
    EndIf

    //-------------------------------------------------------------------------
    // Tratamento para filiais
    //------------------------------------------------------------------------
    // Se a função retornar vazio (tabela totalmente compartilhada ou erro)
    If Empty(cFiliaisIN)
        // Se não tiver acesso ou der erro, usa a filial atual logada por segurança
        cFiliaisIN := "'" + xFilial(cAlias) + "'"
    EndIf

    //=========================================================================
    // CONTA REGISTROS PENDENTES (não processados)
    //=========================================================================
    cQuery := "SELECT COUNT(*) QTD "
    cQuery += "FROM " + RetSQLName( cAlias ) + " " + cAlias + " "
    cQuery += "WHERE " + cAlias + "_FILIAL IN (" + cFiliaisIN + ") "
    cQuery += "  AND " + cAlias + "_PERAPU >= '202501' "
    cQuery += "  AND " + cAlias + "_ATIVO = '1' "
    cQuery += "  AND " + cAlias + "_CHKDIR IN (' ', 'F') " 
    cQuery += "  AND " + cAlias + ".D_E_L_E_T_ = ' ' "

    If cAlias == "T3P"
        // Ignora registros com origem 'S2190' (Admissão Preliminar)
        cQuery += "  AND T3P_ORIEVE <> 'S2190' "
    EndIf

    // Adapta a query para o banco de dados em uso
    cQuery := ChangeQuery( cQuery )

    //=========================================================================
    // EXECUÇÃO DA QUERY
    //=========================================================================
    // Executa a query e associa o resultado ao alias temporário gerado
    TcQuery cQuery New Alias &cAliasCnt

    //-------------------------------------------------------------------------
    // Leitura do Resultado
    //-------------------------------------------------------------------------
    // Verifica se o alias foi aberto com sucesso (Select > 0)
    If Select( cAliasCnt ) > 0
        
        // Verifica se retornou algum registro (sempre retorna 1 linha no COUNT, mas validamos por segurança)
        If !( cAliasCnt )->( EoF() )
            
            // Atribui o valor da coluna QTD à variável de retorno
            nTotReg := ( cAliasCnt )->QTD
            
        EndIf
        
        // Fecha o alias temporário imediatamente após o uso para liberar recursos
        ( cAliasCnt )->( DbCloseArea() )
        
    Else
        // Log de erro caso a query falhe (banco indisponível ou erro de sintaxe)
        TafConOut( "[TAFCountRegs] [ERRO] Falha ao abrir query para tabela: " + cAlias )
    EndIf

    // Log informativo para acompanhamento de processamento
    TafConOut( "[TAFCountRegs] Registros PENDENTES em " + cAlias + ": " + cValToChar( nTotReg ) )

Return nTotReg

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFinfosGrid
@type           Function
@description    Orquestrador de processamento dos grids (tabelas filhas) da DIRF.
                Utiliza a estratégia de BULK LOADING (Carga em Lote) via HashMap para 
                minimizar o I/O no banco de dados e maximizar a performance.

@param          a1210, Array, Array contendo o lote de registros principais (Cabeçalhos) a serem processados.
@param          aAnalitico, Array, Array de retorno que receberá os dados processados. (Passagem por Referência).
@param          cTable, Character, Tabela origem que define o fluxo: "T3P" (S-1210) ou "T2G" (S-5002).

@return         Logical, .T. = Processamento do grid concluído com sucesso; .F. = Erro crítico.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0
@see            TAFBulkMap, TAFGRID
/*/
//---------------------------------------------------------------------
Function TAFinfosGrid( a1210 as array, aAnalitico as array, cTable as character ) as logical

    Local aTabsT3P      as array    // Lista de tabelas filhas do S-1210
    Local aTabsT2G      as array    // Lista de tabelas filhas do S-5002
    Local oHashMap      as object   // Objeto para acesso rápido aos dados (Bulk Load)
    Local hStructCache  as object   // Cache de estruturas de tabela (Performance)
    Local aAliases      as array    // Controle de aliases abertos pelo BulkMap
    Local nX            as numeric  // Contador de Loop (Registros Pai)
    Local nY            as numeric  // Contador de Loop (Tabelas Filhas)
        
    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default a1210      := {}
    Default aAnalitico := {}
    Default cTable     := ""
    
    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    aTabsT3P     := {}
    aTabsT2G     := {}
    oHashMap     := Nil
    hStructCache := Nil 
    aAliases     := {}
    nX           := 0
    nY           := 0
    
    // Definição das tabelas filhas relacionadas ao S-1210 (T3P)
    aTabsT3P := { 'V6M', 'V7U', 'V7V', 'V7W', 'V7X', 'V7Y', 'V7Z', 'V8A', 'V8B', 'V8C', 'V8D', 'V8E', 'V8F', 'V8G' }
    
    // Definição das tabelas filhas relacionadas ao S-5002 (T2G)
    aTabsT2G := { 'T8G', 'V61', 'V62', 'V63', 'V64', 'V65', 'V66', 'V67', 'V68', 'V69', 'V6A', 'V54', 'V50', 'V51' }
    
    // Limpa o array de retorno Analítico para garantir integridade
    ASize(aAnalitico, 0) 
    
    //-------------------------------------------------------------------------
    // 1. BULK LOADING (Carrega dados em memória de uma só vez)
    //-------------------------------------------------------------------------
    // Carrega todas as tabelas filhas para a memória em um HashMap indexado
    // Isso evita milhares de queries individuais (Seek) dentro do loop.
    If cTable == "T3P"
        oHashMap := TAFBulkMap( a1210, aTabsT3P, @aAliases )
    Else
        oHashMap := TAFBulkMap( a1210, aTabsT2G, @aAliases )
    EndIf

    If oHashMap == Nil
        TafConOut("[TAFinfosGrid] ERRO: Falha ao criar HashMap")
        Return .F.
    EndIf
    
    //-------------------------------------------------------------------------
    // 2. INICIALIZA CACHE DE ESTRUTURAS (Performance de I/O)
    //-------------------------------------------------------------------------
    // Cria um HashMap para armazenar o DbStruct() de cada tabela filha.
    // Evita ler o dicionário de dados repetidamente.
    hStructCache := THashMap():New()

    //-------------------------------------------------------------------------
    // 3. PROCESSAMENTO EM BLOCOS (Loop Principal)
    //-------------------------------------------------------------------------
    TafConOut( "[TAFinfosGrid] PASSO 2: Processamento em blocos..." )
    
    // Percorre cada registro Pai (Funcionário/Beneficiário)
    For nX := 1 To Len( a1210 )
        
        // Para cada registro, percorre todas as tabelas filhas possíveis
        If cTable == "T3P"
            For nY := 1 To Len( aTabsT3P )
                // Chama processador do Grid, passando o Cache de Estrutura
                TAFGRID( aTabsT3P[nY], a1210[nX], oHashMap, @aAnalitico, cTable, hStructCache )
            Next nY
        Else
            For nY := 1 To Len( aTabsT2G )
                // Chama processador do Grid, passando o Cache de Estrutura
                TAFGRID( aTabsT2G[nY], a1210[nX], oHashMap, @aAnalitico, cTable, hStructCache )
            Next nY
        EndIf
        
    Next nX
    
    //-------------------------------------------------------------------------
    // 4. LIMPEZA DE RECURSOS 
    //-------------------------------------------------------------------------
    TafConOut( "[TAFinfosGrid] PASSO 3: Liberando recursos..." )
    
    // Fecha os aliases abertos na função TAFBulkMap
    TAFClsAlias( @aAliases )
    
    // Limpa e destrói o HashMap de dados
    If oHashMap != Nil
        HMClean( oHashMap )
        FreeObj( oHashMap )
        oHashMap := Nil
    EndIf

    // Limpa e destrói o Cache de Estruturas
    If hStructCache != Nil
        HMClean( hStructCache )
        FreeObj( hStructCache )
        hStructCache := Nil
    EndIf
    
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFBulkMap
@type           Function
@description    Realiza o carregamento em massa (Bulk Loading) das tabelas filhas para memória.
                Gera um objeto HashMap indexado por chave composta (Tabela + Filial + ID + Versão),
                permitindo acesso direto aos dados e eliminando I/O de banco (Seeks) dentro dos loops.

@param          a1210, Array, Array do lote principal contendo as chaves para filtro (Filial, ID, Versão).
@param          aTables, Array, Lista de strings com os nomes das tabelas filhas a serem carregadas.
@param          aAliases, Array, Array de controle (Passado por Referência) que receberá os nomes dos Aliases temporários abertos.

@return         Object, Retorna um objeto THashMap populado com os dados estruturados das tabelas solicitadas.

@author         Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@see            TAFinfosGrid, TAFExtract
/*/
//---------------------------------------------------------------------
Function TAFBulkMap( a1210 as array, aTables as array, aAliases as array ) as object

    Local oHashMap      as object   // Objeto Hash para armazenamento dos dados
    Local aFiliais      as array    // Lista de Filiais únicas do lote
    Local aIds          as array    // Lista de IDs únicos do lote
    Local aVersoes      as array    // Lista de Versões únicas do lote
    
    Local cInFilial     as character // String da cláusula IN para Filial
    Local cInId         as character // String da cláusula IN para ID
    Local cInVersao     as character // String da cláusula IN para Versão
    Local cQuery        as character // Query SQL dinâmica
    Local cAliasQry     as character // Alias temporário para a query
    Local cTable        as character // Nome da tabela corrente no loop
    Local cKey          as character // Chave única para o HashMap
    
    Local aData         as array    // Dados extraídos de uma linha
    Local aLines        as array    // Lista de linhas para uma mesma chave
    Local aTableStruct  as array    // Cache da estrutura da tabela (Performance)
    Local aFieldMap     as array    // Mapa de posições
    
    Local nY            as numeric  // Contador de tabelas
    Local nX            as numeric  // Contador de registros do lote
    Local nK            as numeric  // Contador de posições
    Local nRecCount     as numeric  // Contador de registros carregados (Log)
    Local nPosFil       as numeric  // Posição: Filial
    Local nPosId        as numeric  // Posição: Id
    Local nPosVer       as numeric  // Posição: Versão

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default a1210    := {}
    Default aTables  := {}
    Default aAliases := {}
    
    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    oHashMap    := THashMap():New()
    aFiliais    := {}
    aIds        := {}
    aVersoes    := {}

    cInFilial   := ""
    cInId       := ""
    cInVersao   := ""
    cQuery      := ""
    cAliasQry   := ""
    cTable      := ""
    cKey        := ""

    aData       := {}
    aLines      := {}
    aTableStruct:= {}
    aFieldMap   := {}

    nY          := 0
    nX          := 0
    nK          := 0
    nRecCount   := 0
    nPosFil     := 0
    nPosId      := 0
    nPosVer     := 0

    //-------------------------------------------------------------------------
    // PASSO 1: Extração de Chaves Únicas
    // Percorre o array do lote para pegar chaves únicas e montar o WHERE.
    // Isso evita que a query traga dados repetidos ou fique muito grande.
    //-------------------------------------------------------------------------
    For nX := 1 To Len( a1210 )
        
        // Validação de segurança do array de entrada
        If Len( a1210[nX] ) < 3
            Loop
        EndIf
        
        // Verifica se Filial já está na lista, se não, adiciona
        If aScan( aFiliais, {|x| x == a1210[nX][1]} ) == 0
            AAdd( aFiliais, a1210[nX][1] )
        EndIf
        
        // Verifica se ID já está na lista, se não, adiciona
        If aScan( aIds, {|x| x == a1210[nX][2]} ) == 0
            AAdd( aIds, a1210[nX][2] )
        EndIf
        
        // Verifica se Versão já está na lista, se não, adiciona
        If aScan( aVersoes, {|x| x == a1210[nX][3]} ) == 0
            AAdd( aVersoes, a1210[nX][3] )
        EndIf
        
    Next nX
    
    // Log informativo sobre a abrangência da busca
    TafConOut( "[TAFBulkMap] Filtros Únicos: " + cValToChar(Len(aFiliais)) + " filiais, " + ;
               cValToChar(Len(aIds)) + " IDs, " + cValToChar(Len(aVersoes)) + " versoes" )
    
    //-------------------------------------------------------------------------
    // PASSO 2: Montagem das Cláusulas SQL (IN)
    // Transforma os arrays em strings SQL: ('01','02') usando TAFBuildIn
    // O limite de 900 é seguro para evitar estouro no Oracle (limite 1000)
    //-------------------------------------------------------------------------
    cInFilial := TAFBuildIn( aFiliais, 900 )
    cInId     := TAFBuildIn( aIds, 900 )
    cInVersao := TAFBuildIn( aVersoes, 900 )

    // Limpa arrays auxiliares para liberar memória imediatamente
    ASize( aFiliais, 0 )
    ASize( aIds, 0 )
    ASize( aVersoes, 0 )
    aFiliais := Nil
    aIds     := Nil
    aVersoes := Nil
    
    //-------------------------------------------------------------------------
    // PASSO 3: Carga das Tabelas (Loop Principal)
    // Percorre cada tabela filha definida (V6M, V7U, etc...)
    //-------------------------------------------------------------------------
    For nY := 1 To Len( aTables )
        
        // Define tabela atual do loop
        cTable    := aTables[nY]
        
        // Gera um alias único para a query desta tabela
        cAliasQry := GetNextAlias()
        
        // Log de progresso
        TafConOut( "[TAFBulkMap] Carregando tabela [" + cValToChar(nY) + "/" + cValToChar(Len(aTables)) + "]: " + cTable )
        
        // Montagem da Query SQL
        // Nota: SELECT * é usado pois precisamos de todos os campos para montar a TempTable depois
        cQuery := "SELECT " 
        cQuery += "    " + cTable + ".* "  // Seleciona TODOS os campos
        cQuery += "FROM " + RetSQLName( cTable ) + " " + cTable + " "
        cQuery += "WHERE " + cTable + "_FILIAL IN " + cInFilial + " "
        cQuery += "  AND " + cTable + "_ID IN " + cInId + " "
        cQuery += "  AND " + cTable + "_VERSAO IN " + cInVersao + " "
        cQuery += "  AND " + cTable + ".D_E_L_E_T_ = ' ' "
        
        // Ajusta query para o banco de dados atual (Oracle/MSSQL/Postgres)
        cQuery := ChangeQuery( cQuery )
        
        // Executa a Query e abre o Alias Temporário
        dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .F., .T. )
        
        // Adiciona alias à lista de controle para fechamento posterior (TAFClsAlias)
        AAdd( aAliases, cAliasQry )
        
        //---------------------------------------------------------------------
        // Lê a estrutura da tabela física APENAS UMA VEZ por tabela.
        // Isso evita chamar DbStruct() dentro do loop While (milhares de vezes).
        //---------------------------------------------------------------------
        aTableStruct := {}
        DbSelectArea( cTable )
        aTableStruct := ( cTable )->( DbStruct() )

        aFieldMap := Array(Len(aTableStruct))

        // Cria mapa de posições UMA VEZ fora do loop
        For nK := 1 To Len(aTableStruct)
            aFieldMap[nK] := (cAliasQry)->( FieldPos( aTableStruct[nK][1] ) )
        Next nK
        
        // Posiciona no início da query
        ( cAliasQry )->( DbGoTop() )
        
        // Loop pelos registros retornados do banco
        nPosFil := (cAliasQry)->( FieldPos( cTable + "_FILIAL" ) )
        nPosId  := (cAliasQry)->( FieldPos( cTable + "_ID" ) )
        nPosVer := (cAliasQry)->( FieldPos( cTable + "_VERSAO" ) )
        
        While !( cAliasQry )->( EoF() )
            
            // Monta a chave composta para indexação no HashMap
            cKey := cTable + "|" 
            cKey += AllTrim( ( cAliasQry )->( FieldGet( nPosFil ) ) ) + "|" 
            cKey += AllTrim( ( cAliasQry )->( FieldGet( nPosId ) ) ) + "|" 
            cKey += AllTrim( ( cAliasQry )->( FieldGet( nPosVer ) ) )
            
            // Extrai os dados da linha para um array usando a função auxiliar
            // Passamos a estrutura (aTableStruct) para evitar ler o dicionário novamente
            aData := TAFExtract( cAliasQry, aTableStruct, aFieldMap )
            
            // Se houve extração válida, armazena no Hash
            If Len( aData ) > 0

                If oHashMap == Nil
                    TafConOut("[TAFBulkMap] HashMap não inicializado")
                    Return Nil
                EndIf
                
                // Verifica se já existe uma entrada para esta chave no Hash
                If !oHashMap:Get( cKey, @aLines )
                    // Se não existe, cria um novo array de linhas para esta chave
                    aLines := {}
                EndIf
                
                // Adiciona os dados da linha atual (usando Clone para segurança de memória)
                AAdd( aLines, aClone( aData ) )
                
                // Atualiza o HashMap com a nova lista de linhas
                oHashMap:Set( cKey, aLines )
                
                // Incrementa contador global para log
                nRecCount++
                
            EndIf
            
            // Move para o próximo registro
            ( cAliasQry )->( DbSkip() )
            
        EndDo
        
        // Limpa variável de estrutura para a próxima iteração
        aTableStruct := {}
        
    Next nY
    
    // Log final de resumo
    TafConOut( "[TAFBulkMap] Cache Carregado. Total de registros em memória: " + cValToChar( nRecCount ) )

Return oHashMap

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFExtract
@type           Function
@description    Extrai e sanitiza os dados da linha atual do Alias da Query para um Array em memória.
                Projetada para alta performance em loops massivos:
                - Utiliza acesso posicional direto (FieldGet) via cache (aFieldMap);
                - Realiza conversão e limpeza de tipos (AllTrim em strings, tratamento de NULL);
                - Prepara os dados para inserção na tabela temporária (FWTemporaryTable).

@param          cAliasQry, Character, Alias da query aberta contendo os registros a serem lidos.
@param          aStruct  , Array    , Estrutura da tabela de destino (Formato padrão DbStruct).
@param          aFieldMap, Array    , Cache contendo as posições numéricas (FieldPos) dos campos no Alias.

@return         Array, Retorna um array unidimensional contendo os valores tratados da linha atual.

@author         Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@see            TAFBulkMap
/*/
//---------------------------------------------------------------------
Function TAFExtract( cAliasQry as character, aStruct as array, aFieldMap as array ) as array

    Local aData     as array    // Array de retorno com os dados
    Local nX        as numeric  // Contador do loop
    Local xValue    as variant  // Valor extraído do campo
    Local nFieldPos as numeric  // Posição do campo no alias da query
    Local nLen      as numeric  // Quantidade de campos na estrutura

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cAliasQry := ""     
    Default aStruct   := {}  
    Default aFieldMap := {} 

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    aData       := {}
    nX          := 0
    xValue      := Nil
    nFieldPos   := 0
    nLen        := 0
    
    // Cacheia o tamanho da estrutura
    nLen        := Len( aStruct )

    //-------------------------------------------------------------------------
    // Validação de Segurança
    //-------------------------------------------------------------------------
    If nLen == 0
        // Se não há estrutura definida, não há o que processar. Retorna vazio imediatamente.
        Return aData
    EndIf

    // Validação de Integridade do Cache de Campos (aFieldMap)
    // Se o mapa de campos não foi passado ou está desatualizado em relação à estrutura, recriamos ele
    If Len(aFieldMap) != nLen
        
        // Aloca array do tamanho exato necessário
        aFieldMap := Array(nLen)
        
        // Loop de recuperação
        For nX := 1 To nLen
             // Busca a posição do campo pelo nome (String Compare na memória do Alias).
             // aStruct[nX][1] contém o nome do campo físico.
             aFieldMap[nX] := (cAliasQry)->( FieldPos( aStruct[nX][1] ) )
        Next nX
        
    EndIf

    //-------------------------------------------------------------------------
    // EXTRAÇÃO DE DADOS (CORE LOOP)
    //-------------------------------------------------------------------------
    // Pré-alocação de memória. 
    // Evita a realocação dinâmica que ocorre ao usar AAdd(), array já nasce com o tamanho final
    aData := Array( nLen ) 

    For nX := 1 To nLen
        
        // 1. Acesso Direto (O(1))
        // Recupera o ID numérico da coluna no cursor do banco.
        // Isso elimina a necessidade de buscar pelo nome da coluna (String).
        nFieldPos := aFieldMap[nX]
           
        // 2. Validação de Existência da Coluna
        // Se nFieldPos for 0, significa que o campo existe no Dicionário de Dados (aStruct),
        // mas NÃO existe na Query SQL executada (ex: SELECT específico que não trouxe todas as colunas).
        If nFieldPos == 0
            
            // Se o campo não veio na query, inicializa com o valor padrão do tipo
            If aStruct[nX][2] == "N"
                aData[nX] := 0
            ElseIf aStruct[nX][2] == "D"
                aData[nX] := CToD("//")
            Else
                aData[nX] := ""
            EndIf
            
        Else
            // 3. Leitura de Memória
            // FieldGet acessa o valor diretamente pelo ID da coluna. 
            // O operador (Alias)-> força o contexto para a workarea correta sem precisar de DbSelectArea().
            xValue := (cAliasQry)->( FieldGet( nFieldPos ) )
            
            // 4. Sanitização de Dados
            // Bancos de dados retornam tipos variados. Precisamos tratar especificamente Strings.
            If xValue == Nil
                
                // Se o campo não veio na query, inicializa com o valor padrão do tipo
                If aStruct[nX][2] == "N"
                    aData[nX] := 0
                ElseIf aStruct[nX][2] == "D"
                    aData[nX] := CToD("//")
                Else
                    aData[nX] := ""
                EndIf
            
            ElseIf ValType( xValue ) == "C"
                // Remove espaços em branco
                aData[nX] := AllTrim( xValue )
            Else
                // Para tipos Numéricos, Data, Lógico e Memo, mantém o valor original
                aData[nX] := xValue
            EndIf
            
        EndIf
        
    Next nX

Return aData

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGRID
@type           Function
@description    Núcleo de processamento de tabelas filhas (Grids).
                A função realiza as seguintes etapas:
                1. Recupera os dados da memória (HashMap) para a chave atual;
                2. Cria uma tabela temporária (FWTemporaryTable) com esses dados;
                3. Roteia (Dispatch) para a função específica de tratamento da tabela (Ex: TAFInV7U, TAFFil1200);
                4. Realiza a limpeza da tabela temporária após o uso.

@param          cTable      , Character , Nome da tabela filha a ser processada (Ex: "V6M", "V7U").
@param          aInfos      , Array     , Array contendo os dados contextuais do registro pai (Filial, ID, Versão, etc.).
@param          oHashMap    , Object    , Objeto THashMap contendo o cache de dados pré-carregados (Bulk Loading).
@param          aAnalitico  , Array     , Array de retorno que receberá os dados processados (Passado por Referência).
@param          cAlias      , Character , Contexto do evento pai: "T3P" (S-1210) ou "T2G" (S-5002).
@param          hStructCache, Object    , Cache de estruturas (DbStruct) para evitar leitura repetitiva do dicionário de dados.

@return         Logical, .T. = Processamento concluído (mesmo se vazio); .F. = Erro crítico na criação da tabela temporária.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@see            TAFTempAls, TAFinfosGrid
/*/
//---------------------------------------------------------------------
Function TAFGRID( cTable as character, aInfos as array, oHashMap as object, aAnalitico as array, cAlias as character, hStructCache as object ) as logical

    Local cKey        as character  // Chave de busca no Hash
    Local aAllLines   as array      // Linhas encontradas para este registro
    Local cAliasTemp  as character  // Nome do alias temporário
    Local oTempTable  as object     // Objeto da tabela temporária
    Local aStruct     as array      // Estrutura da tabela (Campos)

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTable       := ""
    Default aInfos       := {}
    Default oHashMap     := Nil
    Default aAnalitico   := {}
    Default cAlias       := ""
    Default hStructCache := Nil
    
    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cKey       := ""
    aAllLines  := {}
    oTempTable := Nil
    cAliasTemp := ""
    aStruct    := {}
    
    //-------------------------------------------------------------------------
    // 1. BUSCA DADOS NO HASHMAP (Memória)
    //-------------------------------------------------------------------------
    If Len(aInfos) < 3
        TafConOut("[TAFGRID] Array aInfos com menos de 3 elementos")
        Return .F.
    EndIf
    
    // Monta a chave composta: Tabela|Filial|ID|Versão
    cKey := cTable + "|" + AllTrim( aInfos[1] ) + "|" + AllTrim( aInfos[2] ) + "|" + AllTrim( aInfos[3] )
    
    // Verifica se existem dados pré-carregados para esta chave
    If !oHashMap:Get( cKey, @aAllLines )
        // Se não encontrou, apenas retorna .T. (Grid vazio para este func)
        Return .T.
    EndIf
    
    //-------------------------------------------------------------------------
    // 2. GESTÃO INTELIGENTE DE ESTRUTURA (Cache)
    //-------------------------------------------------------------------------
    // Verifica se a estrutura já está no cache para evitar DbStruct() repetitivo
    If hStructCache != Nil
        If !hStructCache:Get( cTable, @aStruct )
            // Primeira vez: Lê do dicionário e salva no cache
            DbSelectArea( cTable )
            aStruct := ( cTable )->( DbStruct() )
            hStructCache:Set( cTable, aStruct )
        EndIf
    Else
        // Fallback: Se não passou cache, lê direto (Menor performance)
        DbSelectArea( cTable )
        aStruct := ( cTable )->( DbStruct() )
    EndIf
    
    //-------------------------------------------------------------------------
    // 3. CRIAÇÃO DE TABELA TEMPORÁRIA
    //-------------------------------------------------------------------------
    // Cria tabela física temporária e popula com os dados do array
    oTempTable := TAFTempAls( cTable, aAllLines, aStruct )

    If oTempTable == Nil
        Return .F.
    EndIf
    
    // Armazena o alias gerado para garantir o fechamento posterior
    cAliasTemp := oTempTable:GetAlias()
    
    //-------------------------------------------------------------------------
    // 4. REGRAS DE NEGÓCIO (Despacho para funções específicas)
    //-------------------------------------------------------------------------
	If cAlias == "T3P"
		
		//---------------------------------------------------------------
		// GRIDS DO EVENTO S-1210
		//---------------------------------------------------------------
		Do Case
			
			Case cTable == "V6M"
				TAFFil1200( cAliasTemp, aInfos, @aAnalitico )
				
			Case cTable == "V7U"
				TAFInV7U( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V7V"
				TAFInV7V( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V7W"
				TAFInV7W( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V7X"
				TAFInV7X( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V7Y"
				TAFInV7Y( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V7Z"
				TAFInV7Z( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V8A"
				TAFInV8A( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V8B"
				TAFInV8B( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V8C"
				TAFInV8C( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V8D"
				TAFInV8D( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V8E"
				TAFInV8E( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V8F"
				TAFInV8F( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
			Case cTable == "V8G"
				TAFInV8G( cAliasTemp, aInfos[5], cTable, @aAnalitico, aInfos[6], aInfos[7], aInfos[4], aInfos[1] )
				
		EndCase
		
	Else
		
		//-----------------------------------------------------------------
		// GRIDS DO EVENTO S-5002 (T2G)
		//-----------------------------------------------------------------
		Do Case
			
			Case cTable == "T8G"
				TAFCon5002( cAliasTemp, aInfos, @aAnalitico )
				
			Case cTable == "V61"
				TAFInV61( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V62"
				TAFInV62( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V63"
				TAFInV63( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V64"
				TAFInV64( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V65"
				TAFInV65( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V66"
				TAFInV66( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V67"
				TAFInV67( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V68"
				TAFInV68( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V69"
				TAFInV69( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V6A"
				TAFInV6A( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V54"
				TAFInV54( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V50"
				TAFInV50( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
			Case cTable == "V51"
				TAFInV51( cAliasTemp, aInfos[5], @aAnalitico, aInfos[4], aInfos[1] )
				
		EndCase
		
	EndIf
	
    //---------------------------------------------------------------------
    // 5. LIMPEZA BLINDADA DE RECURSOS (WorkArea e I/O)
    //---------------------------------------------------------------------
    If oTempTable != Nil

        // 1. Tenta exclusão padrão (Drop Table + Close Area internos)
        // Isso é o correto para garantir que o arquivo suma do banco temporário
        oTempTable:Delete()
        
        // 2. Destrói o objeto da memória
        FreeObj( oTempTable )
        oTempTable := Nil
        
        // 3. Verifica se, mesmo após o Delete(), o Alias continua preso na memória.
        // Se estiver, força o fechamento para evitar erro de limite (1024).
        If !Empty(cAliasTemp) .And. Select(cAliasTemp) > 0
            (cAliasTemp)->(DbCloseArea())
        EndIf

        // 4. Pausa para estabilidade do I/O do Sistema Operacional
        Sleep( 20 )

    EndIf
    
Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTempAls
@type           Function
@description    Cria, estrutura e popula uma tabela temporária (FWTemporaryTable) em memória.
                A função gerencia a integridade dos dados realizando a conversão estrita de tipos 
                (Data, Lógico, Numérico) antes da gravação, evitando erros de "Type Mismatch".

@param          cTable   , Character, Nome da tabela física original (Ex: "V6M") para consulta ao dicionário (caso aStruct não seja informado).
@param          aAllLines, Array    , Array bidimensional contendo os registros (linhas x colunas) a serem inseridos.
@param          aStruct  , Array    , (Opcional) Cache da estrutura da tabela (DbStruct) para otimização de performance.

@return         Object   , Retorna a instância do objeto FWTemporaryTable já populada e posicionada no topo.

@author         Denis R. de Oliveira
@since          17/12/2025
@version        1.0
@see            TAFGRID
/*/
//---------------------------------------------------------------------
Function TAFTempAls( cTable as character, aAllLines as array, aStruct as array ) as object

    Local cAliasTemp as character   // Nome do alias temporário
    Local oTempTable as object      // Objeto da tabela temporária
    Local aLine      as array       // Array auxiliar para a linha corrente
    Local nLine      as numeric     // Contador de linhas
    Local nField     as numeric     // Contador de campos
    Local xValue     as variant     // Valor do campo atual
    Local cFieldType as character   // Tipo do campo (C, N, D, L, M)
    Local nFieldSize as numeric     // Tamanho do campo
    Local nLenStruct as numeric     // Quantidade de campos na estrutura

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTable    := ""
    Default aAllLines := {}
    Default aStruct   := {}

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cAliasTemp := GetNextAlias() // Gera nome único para o alias (Ex: TMP001)
    oTempTable := Nil
    aLine      := {}
    nLine      := 0
    nField     := 0
    xValue     := Nil
    cFieldType := ""
    nFieldSize := 0
    nLenStruct := 0
    
    //-------------------------------------------------------------------------
    // Definição da Estrutura
    //-------------------------------------------------------------------------
    // Se a estrutura não veio por parâmetro (Cache), busca agora no dicionário
    If Len(aStruct) == 0 .And. !Empty(cTable)
        DbSelectArea( cTable )
        aStruct := ( cTable )->( DbStruct() )
    EndIf
    
    nLenStruct := Len( aStruct )
    
    // Se não tem estrutura, não é possível criar tabela
    If nLenStruct == 0
        Return Nil
    EndIf
    
    //-------------------------------------------------------------------------
    // Criação da Tabela Temporária
    //-------------------------------------------------------------------------
    oTempTable := FWTemporaryTable():New( cAliasTemp )
    oTempTable:SetFields( aStruct )
    oTempTable:Create()
    
    //-------------------------------------------------------------------------
    // Popula Dados (Loop de Inserção)
    //-------------------------------------------------------------------------
    For nLine := 1 To Len( aAllLines )
        
        aLine := aAllLines[nLine]
        
        // Validação básica do array da linha (Integridade)
        If ValType( aLine ) != "A" .Or. Len( aLine ) == 0
            Loop
        EndIf
        
        // Abre lock para inserção do registro
        RecLock( cAliasTemp, .T. )
        
        // Loop Otimizado pelos campos da estrutura
        For nField := 1 To nLenStruct
            
            // Proteção contra array de dados menor que a estrutura da tabela
            If nField > Len( aLine )
                Exit
            EndIf
            
            // Extrai metadados do campo para conversão correta
            cFieldType := aStruct[nField][2]
            nFieldSize := aStruct[nField][3]
            xValue     := aLine[nField]
            
            //-----------------------------------------------------------------
            // Switch de Tipagem (Validação Estrita de Tipos e Conversão)
            //-----------------------------------------------------------------
            Do Case
                
                // Tipo Caracter (C)
                Case cFieldType == "C"
                    If ValType(xValue) != "C"
                        xValue := cValToChar(xValue)
                    EndIf
                    (cAliasTemp)->(FieldPut(nField, PadR(xValue, nFieldSize)))
                    
                // Tipo Numérico (N)
                Case cFieldType == "N"
                    If ValType(xValue) == "C"
                        // Substitui vírgula por ponto antes de converter para garantir decimais
                        xValue := Val(StrTran(AllTrim(xValue), ",", "."))
                    ElseIf ValType(xValue) != "N"
                        xValue := 0 // Para evitar Nil
                    EndIf
                    (cAliasTemp)->(FieldPut(nField, xValue))
                    
                // Tipo Data (D)
                Case cFieldType == "D"
                    If ValType(xValue) == "C"
                        xValue := StoD(xValue)
                    EndIf

                    If ValType(xValue) != "D"
                        xValue := CToD("//")
                    EndIf
                    (cAliasTemp)->(FieldPut(nField, xValue))
                    
                // Tipo Lógico (L)
                Case cFieldType == "L"
                    If ValType(xValue) == "C"
                        // Converte string "T"/"F", "S"/"N", "1"/"0" para lógico
                        xValue := Upper(AllTrim(xValue)) $ "T|.T.|S|1|YES|VERDADEIRO|TRUE"
                    EndIf
                    (cAliasTemp)->(FieldPut(nField, xValue))
                    
                // Tipo Memo (M)
                Case cFieldType == "M"
                    If ValType(xValue) != "C"
                        xValue := cValToChar(xValue)
                    EndIf
                    (cAliasTemp)->(FieldPut(nField, xValue))
                    
            EndCase
            
        Next nField
        
        MsUnlock() // Confirma gravação da linha no banco temporário
        
    Next nLine
    
    // Posiciona no início da tabela para leitura posterior
    ( cAliasTemp )->( DbGoTop() )
    
Return oTempTable

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFBuildIn
@type           Function
@description    Gera uma string formatada para uso em cláusulas SQL "IN (...)" a partir de um array.
                A função implementa mecanismos de segurança e estabilidade:
                - Sanitização de dados (Escape de aspas e remoção de keywords de injeção);
                - Conversão automática de tipos (Números/Datas para String);
                - Limitação de volume (Paginação) para evitar estouro de buffer do banco;
                - Tratamento de array vazio (Retorna "('')" para evitar erro de sintaxe SQL).

@param          aValues   , Array  , Lista contendo os valores brutos a serem formatados.
@param          nMaxValues, Numeric, Limite máximo de itens a serem processados (Paginação).

@return         Character , String formatada pronta para concatenação na Query. Ex: "('val1','val2')"

@author         Denis R. de Oliveira
@since          17/10/2025
@version        1.0
/*/
//---------------------------------------------------------------------
Function TAFBuildIn( aValues as array, nMaxValues as numeric ) as character

    Local cInClause     as character // Armazena o resultado final da cláusula
    Local cValue        as character // Variável temporária para valor atual
    Local cValueUpper   as character // Variável temporária para validação (Uppercase)
    Local xRawValue     as variant   // Valor bruto do array (qualquer tipo)
    
    Local nX            as numeric   // Contador do laço principal
    Local nCount        as numeric   // Contador de itens válidos adicionados
    Local nLimit        as numeric   // Limite calculado de iterações
    Local nMaxLen       as numeric   // Tamanho máximo de cada string individual
    Local nInputLen     as numeric   // Tamanho do array de entrada

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default aValues    := {}
    Default nMaxValues := 1000

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cInClause   := "("
    cValue      := ""
    cValueUpper := ""
    xRawValue   := Nil
    
    nX          := 0
    nCount      := 0
    nLimit      := 0
    nInputLen   := 0
    nMaxLen     := 200 // Limite de caracteres por campo (segurança)

    //-------------------------------------------------------------------------
    // Validação de Entrada: Se não for array ou estiver vazio, retorna vazio seguro
    //-------------------------------------------------------------------------
    If ValType( aValues ) != "A"
        Return "('')"
    EndIf
    
    nInputLen := Len( aValues )
    
    If nInputLen == 0
        Return "('')"
    EndIf

    //-------------------------------------------------------------------------
    // Definição do Limite de Processamento
    // Garante que não excederá nem o tamanho do array nem o limite do banco
    //-------------------------------------------------------------------------
    nLimit := Min( nInputLen, nMaxValues )

    If nInputLen > nMaxValues
        TafConOut( "[ALERTA] TAFBuildIn: Array excede o limite (" + cValToChar(nMaxValues) + "). Itens excedentes serao ignorados!" )
    EndIf

    //-------------------------------------------------------------------------
    // Loop Principal de Construção
    //-------------------------------------------------------------------------
    For nX := 1 To nLimit
        
        // Recupera o valor bruto do array
        xRawValue := aValues[nX]
        
        // CONVERSÃO DE TIPO (Estabilidade):
        // Garante que números, datas ou lógicos virem string antes de processar.
        // Isso evita error log de "Type Mismatch" no AllTrim.
        If ValType( xRawValue ) != "C"
            cValue := cValToChar( xRawValue )
        Else
            cValue := xRawValue
        EndIf
        
        // Remove espaços em branco desnecessários
        cValue := AllTrim( cValue )
        
        // Truncamento de segurança (evita strings gigantescas maliciosas)
        If Len( cValue ) > nMaxLen
            cValue := SubStr( cValue, 1, nMaxLen )
        EndIf
        
        // Ignora valores vazios após o tratamento
        If Empty( cValue )
            Loop
        EndIf
        
        //---------------------------------------------------------------------
        // Sanitização SQL (Prevenção de Injection)
        //---------------------------------------------------------------------
        // Escapa aspas simples (padrão SQL)
        cValue := StrTran( cValue, "'", "''" )
        
        // Remove caracteres de controle e comentários de banco
        cValue := StrTran( cValue, ";", "" )   // Finalizador de comando
        cValue := StrTran( cValue, "--", "" )  // Comentário de linha
        cValue := StrTran( cValue, "/*", "" )  // Início de bloco de comentário
        cValue := StrTran( cValue, "*/", "" )  // Fim de bloco de comentário
        cValue := StrTran( cValue, "\", "" )   // Barra invertida
        
        // Remove quebras de linha e nulos
        cValue := StrTran( cValue, Chr(0), "" )
        cValue := StrTran( cValue, Chr(10), "" )
        cValue := StrTran( cValue, Chr(13), "" )
        
        //---------------------------------------------------------------------
        // Bloqueio de Palavras-Chave (Keywords)
        // Evita comandos DDL/DML dentro do valor
        //---------------------------------------------------------------------
        cValueUpper := Upper( cValue )
        
        If "DROP "      $ cValueUpper .Or. ;
           "DELETE "    $ cValueUpper .Or. ;
           "TRUNCATE "  $ cValueUpper .Or. ;
           "EXEC "      $ cValueUpper .Or. ;
           "UNION "     $ cValueUpper .Or. ;
           "INSERT "    $ cValueUpper .Or. ;
           "UPDATE "    $ cValueUpper
            // Se encontrar palavra suspeita seguida de espaço, ignora este item
            Loop
        EndIf
        
        //---------------------------------------------------------------------
        // Montagem da String
        //---------------------------------------------------------------------
        // Adiciona vírgula se não for o primeiro item adicionado
        If nCount > 0
            cInClause += ","
        EndIf
        
        // Concatena o valor sanitizado entre aspas simples
        cInClause += "'" + cValue + "'"
        
        // Incrementa contador de itens válidos
        nCount++
    
    Next nX

    // Fecha a cláusula
    cInClause += ")"

    //-------------------------------------------------------------------------
    // Validação Final
    // Se nenhum item foi válido (todos vazios ou bloqueados), retorna inócuo.
    // Evita erro de sintaxe SQL "IN ()"
    //-------------------------------------------------------------------------
    If nCount == 0
        cInClause := "('')"
    EndIf

Return cInClause

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFClsAlias
@type           Function
@description    Realiza o fechamento seguro e em lote de WorkAreas (Aliases) temporárias.
                A função itera sobre o array fornecido, valida se cada Alias está efetivamente aberto 
                (Select > 0) e executa o fechamento (DbCloseArea), garantindo a liberação de recursos 
                do banco de dados e prevenindo vazamento de handles (Memory Leak).

@param          aAliases, Array, Lista de strings contendo os nomes dos Aliases a serem encerrados.

@return         Nil, A função não possui retorno.

@author         Denis R. de Oliveira
@since          28/10/2025
@version        1.0
@see            TAFBulkMap
/*/
//---------------------------------------------------------------------
Function TAFClsAlias( aAliases as array )

    Local cAlias  as character  // Nome do alias corrente no loop
    Local nX      as numeric    // Contador do loop
    Local nClosed as numeric    // Contador de aliases efetivamente fechados

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default aAliases := {}
    
    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cAlias  := ""
    nX      := 0
    nClosed := 0
    
    //-------------------------------------------------------------------------
    // Validação de Entrada
    //-------------------------------------------------------------------------
    // Verifica se o parâmetro é válido e se contém itens
    If ValType( aAliases ) != "A" .Or. Len( aAliases ) == 0
        
        // Log informativo de saída antecipada
        TafConOut( "[TAFClsAlias] Nenhum alias para fechar (Array vazio ou inválido)" )
        
        Return
        
    EndIf
    
    // Log de início do processo
    TafConOut( "[TAFClsAlias] Fechando " + cValToChar( Len( aAliases ) ) + " aliases..." )
    
    //-------------------------------------------------------------------------
    // Loop de Fechamento (Cleanup)
    //-------------------------------------------------------------------------
    For nX := 1 To Len( aAliases )
        
        // Validação de Segurança: O item do array deve ser Texto (Nome do Alias)
        If ValType( aAliases[nX] ) == "C"
            
            // Atribui o nome do alias
            cAlias := aAliases[nX]
            
            // Verifica se o alias é válido e se realmente está aberto (Select > 0)
            // Isso evita erros de runtime ao tentar fechar algo inexistente
            If !Empty( cAlias ) .And. Select( cAlias ) > 0
                
                // Fecha a WorkArea
                ( cAlias )->( DbCloseArea() )
                
                // Incrementa contador de sucesso
                nClosed++
                
            EndIf
            
        EndIf
        
    Next nX
    
    //-------------------------------------------------------------------------
    // Limpeza de Memória (Referência)
    //-------------------------------------------------------------------------
    ASize( aAliases, 0 )
    aAliases := Nil
    
    // Log final de resumo
    TafConOut( "[TAFClsAlias] Total fechados: " + cValToChar( nClosed ) )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7U
@type           Function
@description    Processa registros da tabela V7U (Info. Pagamento - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query com os dados processados
@param          cPeriodo    , Character , Período de apuração (AAAAMM)
@param          cTable      , Character , Prefixo da tabela (Ex: "V7U")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento (Ex: S-1210)
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7U( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric      // Índice do array
    Local cReceita      as character    // Código da Receita
    Local cNome         as character    // Nome do Trabalhador
    Local cKeyCache     as character    // Key
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_TPREND     as numeric
    Local nP_CPFDEP     as numeric
    Local nP_VLRDED     as numeric
    Local nP_VERSAO     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cReceita    := ""
    cNome       := ""
    cKeyCache   := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_TPREND   := 0
    nP_CPFDEP   := 0
    nP_VLRDED   := 0
    nP_VERSAO   := 0

     // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos (Fora do Loop)
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos(cTable + "_TPCR"))
        nP_TPREND := (cAliasQry)->(FieldPos(cTable + "_TPREND"))
        nP_CPFDEP := (cAliasQry)->(FieldPos(cTable + "_CPFDEP"))
        nP_VLRDED := (cAliasQry)->(FieldPos(cTable + "_VLRDED"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            
            // Inicializa tipos de dados no array
            TAFInitArray( aAnalitico, nPosValores )

            // ----------------------------------------------------------------
            // OTIMIZAÇÃO DE PERFORMANCE: Cache de Código de Receita (C6R)
            // ----------------------------------------------------------------
            // Inicializa o HashMap na primeira utilização se estiver vazio
            If hCacheC6R_Mod == Nil
                hCacheC6R_Mod := THashMap():New()
            EndIf

            // Monta a chave única para busca no Hash: Filial + Codigo Receita (TPCR)
            cKeyCache := cValToChar((cAliasQry)->(FieldGet(nP_FILIAL))) + "|" + AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))

            // Verifica se já existe no cache
            If !hCacheC6R_Mod:Get(cKeyCache, @cReceita)
                
                // Se não existe, busca no banco de dados (I/O)
                cReceita := AllTrim(Posicione("C6R", 3, xFilial("C6R", (cAliasQry)->(FieldGet(nP_FILIAL))) + PadR((cAliasQry)->(FieldGet(nP_TPCR)), TamSx3("C6R_ID")[1]), "C6R_CODIGO"))
                
                // Salva no cache para as próximas iterações
                hCacheC6R_Mod:Set(cKeyCache, cReceita)
                
            EndIf

            // Carga de Dados (FieldGet)
            aAnalitico[nPosValores][ANALITICO_FILIAL]     := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]         := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]     := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]        := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]       := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]     := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]  := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA] := cReceita
            
            // Tratamento de Domínio
            aAnalitico[nPosValores][ANALITICO_TPREND]     := TAFTpRend( (cAliasQry)->(FieldGet(nP_TPREND)) )
            
            aAnalitico[nPosValores][ANALITICO_CPFDEP]     := (cAliasQry)->(FieldGet(nP_CPFDEP))
            aAnalitico[nPosValores][ANALITICO_VLRDED]     := (cAliasQry)->(FieldGet(nP_VLRDED))
            aAnalitico[nPosValores][ANALITICO_FORABA]     := "DEDDEP"
            aAnalitico[nPosValores][ANALITICO_ABA]        := "02"
            aAnalitico[nPosValores][ANALITICO_PERREF]     := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]     := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]     := (cAliasQry)->(FieldGet(nP_VERSAO))
            
            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV61
@type           Function
@description    Processa registros da tabela V61 (IRRF - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV61( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_TPREND     as numeric
    Local nP_CPFDEP     as numeric
    Local nP_VLRDED     as numeric
    Local nP_VERSAO     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_TPREND   := 0
    nP_CPFDEP   := 0
    nP_VLRDED   := 0
    nP_VERSAO   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos("V61_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V61_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos("V61_TPCR"))
        nP_TPREND := (cAliasQry)->(FieldPos("V61_TPREND"))
        nP_CPFDEP := (cAliasQry)->(FieldPos("V61_CPFDEP"))
        nP_VLRDED := (cAliasQry)->(FieldPos("V61_VLRDED"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V61_VERSAO"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )
            
            aAnalitico[nPosValores][ANALITICO_FILIAL]     := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]         := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]     := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]        := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]       := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]     := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]  := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA] := (cAliasQry)->(FieldGet(nP_TPCR))
            aAnalitico[nPosValores][ANALITICO_TPREND]     := TAFTpRend( (cAliasQry)->(FieldGet(nP_TPREND)) )
            aAnalitico[nPosValores][ANALITICO_CPFDEP]     := (cAliasQry)->(FieldGet(nP_CPFDEP))
            aAnalitico[nPosValores][ANALITICO_VLRDED]     := (cAliasQry)->(FieldGet(nP_VLRDED))
            aAnalitico[nPosValores][ANALITICO_FORABA]     := "DEDDEP"
            aAnalitico[nPosValores][ANALITICO_ABA]        := "02"
            aAnalitico[nPosValores][ANALITICO_PERREF]     := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]     := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]     := (cAliasQry)->(FieldGet(nP_VERSAO))
            
            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV62
@type           Function
@description    Processa registros da tabela V62 (Pensão Alimentícia - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV62( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_TPREND     as numeric
    Local nP_CPFDEP     as numeric
    Local nP_VLPEN      as numeric
    Local nP_VERSAO     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_TPREND   := 0
    nP_CPFDEP   := 0
    nP_VLPEN    := 0
    nP_VERSAO   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V62_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V62_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos("V62_TPCR"))
        nP_TPREND := (cAliasQry)->(FieldPos("V62_TPREND"))
        nP_CPFDEP := (cAliasQry)->(FieldPos("V62_CPFDEP"))
        nP_VLPEN  := (cAliasQry)->(FieldPos("V62_VLPEN"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V62_VERSAO"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )
            
            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA]   := (cAliasQry)->(FieldGet(nP_TPCR))
            aAnalitico[nPosValores][ANALITICO_TPRENDALIM]   := TAFTpRend( (cAliasQry)->(FieldGet(nP_TPREND)) )
            aAnalitico[nPosValores][ANALITICO_CPFDEPALIM]   := (cAliasQry)->(FieldGet(nP_CPFDEP))
            aAnalitico[nPosValores][ANALITICO_VLRDEDALIM]   := (cAliasQry)->(FieldGet(nP_VLPEN))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "PENALI"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "03"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
            
            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV63
@type           Function
@description    Processa registros da tabela V63 (Previdência Complementar - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV63( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_TPREV      as numeric
    Local nP_INSCPL     as numeric
    Local nP_VLCOMP     as numeric
    Local nP_VLCO13     as numeric
    Local nP_VLPATR     as numeric
    Local nP_VLPA13     as numeric
    Local nP_VERSAO     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_TPREV    := 0
    nP_INSCPL   := 0
    nP_VLCOMP   := 0
    nP_VLCO13   := 0
    nP_VLPATR   := 0
    nP_VLPA13   := 0
    nP_VERSAO   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V63_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V63_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos("V63_TPCR"))
        nP_TPREV  := (cAliasQry)->(FieldPos("V63_TPREV"))
        nP_INSCPL := (cAliasQry)->(FieldPos("V63_INSCPL"))
        nP_VLCOMP := (cAliasQry)->(FieldPos("V63_VLCOMP"))
        nP_VLCO13 := (cAliasQry)->(FieldPos("V63_VLCO13"))
        nP_VLPATR := (cAliasQry)->(FieldPos("V63_VLPATR"))
        nP_VLPA13 := (cAliasQry)->(FieldPos("V63_VLPA13"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V63_VERSAO"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]         := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]             := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]         := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]            := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]           := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]         := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]      := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA]     := (cAliasQry)->(FieldGet(nP_TPCR))
            aAnalitico[nPosValores][ANALITICO_TPPREV]         := TAFTpPrev( (cAliasQry)->(FieldGet(nP_TPREV)) )
            aAnalitico[nPosValores][ANALITICO_CNPJPREV]       := (cAliasQry)->(FieldGet(nP_INSCPL))
            aAnalitico[nPosValores][ANALITICO_VLRDEDPCPREV]   := (cAliasQry)->(FieldGet(nP_VLCOMP))
            aAnalitico[nPosValores][ANALITICO_VLRDEDPCPREV13] := (cAliasQry)->(FieldGet(nP_VLCO13))
            aAnalitico[nPosValores][ANALITICO_VLRDEDFUNP]     := (cAliasQry)->(FieldGet(nP_VLPATR))
            aAnalitico[nPosValores][ANALITICO_VLRDEDFUNP13]   := (cAliasQry)->(FieldGet(nP_VLPA13))
            aAnalitico[nPosValores][ANALITICO_FORABA]         := "PREVCL"
            aAnalitico[nPosValores][ANALITICO_ABA]            := "04"
            aAnalitico[nPosValores][ANALITICO_PERREF]         := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]         := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]         := (cAliasQry)->(FieldGet(nP_VERSAO))
            
            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV64
@type           Function
@description    Processa registros da tabela V64 (Processos Judiciais - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV64( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPPROC     as numeric
    Local nP_NRPROC     as numeric
    Local nP_CODSUP     as numeric
    Local nP_TPCR       as numeric
    Local nP_SEQIRC     as numeric
    Local nP_VERSAO     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0    
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPPROC   := 0
    nP_NRPROC   := 0
    nP_CODSUP   := 0
    nP_TPCR     := 0
    nP_SEQIRC   := 0
    nP_VERSAO   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V64_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V64_ID"))
        nP_TPPROC := (cAliasQry)->(FieldPos("V64_TPPROC"))
        nP_NRPROC := (cAliasQry)->(FieldPos("V64_NRPROC"))
        nP_CODSUP := (cAliasQry)->(FieldPos("V64_CODSUP"))
        nP_TPCR   := (cAliasQry)->(FieldPos("V64_TPCR"))
        nP_SEQIRC := (cAliasQry)->(FieldPos("V64_SEQIRC"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V64_VERSAO"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]     := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]         := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]     := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]        := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]       := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]     := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]  := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_TPPROC]     := TAFTpProc( (cAliasQry)->(FieldGet(nP_TPPROC)) )
            aAnalitico[nPosValores][ANALITICO_NRPROC]     := (cAliasQry)->(FieldGet(nP_NRPROC))
            aAnalitico[nPosValores][ANALITICO_CODSUP]     := (cAliasQry)->(FieldGet(nP_CODSUP))
            aAnalitico[nPosValores][ANALITICO_FORABA]     := "PROCRE"
            aAnalitico[nPosValores][ANALITICO_ABA]        := "05"
            aAnalitico[nPosValores][ANALITICO_PERREF]     := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]     := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]     := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA] := (cAliasQry)->(FieldGet(nP_TPCR))
            aAnalitico[nPosValores][ANALITICO_RELACAO]    := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))   + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPPROC)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRPROC)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CODSUP)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV65
@type           Function
@description    Processa registros da tabela V65 (RRA - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV65( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_INDAPU     as numeric
    Local nP_VLRRET     as numeric
    Local nP_VLRJUD     as numeric
    Local nP_VLACAL     as numeric
    Local nP_VLAANT     as numeric
    Local nP_VLSUSP     as numeric
    Local nP_VERSAO     as numeric
    
    Local nP_TPPROC     as numeric
    Local nP_NRPROC     as numeric
    Local nP_CODSUP     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0    
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_INDAPU   := 0
    nP_VLRRET   := 0
    nP_VLRJUD   := 0
    nP_VLACAL   := 0
    nP_VLAANT   := 0
    nP_VLSUSP   := 0
    nP_VERSAO   := 0

    nP_TPPROC   := 0
    nP_NRPROC   := 0
    nP_CODSUP   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V65_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V65_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos("V65_TPCR"))
        nP_INDAPU := (cAliasQry)->(FieldPos("V65_INDAPU"))
        nP_VLRRET := (cAliasQry)->(FieldPos("V65_VLRRET"))
        nP_VLRJUD := (cAliasQry)->(FieldPos("V65_VLRJUD"))
        nP_VLACAL := (cAliasQry)->(FieldPos("V65_VLACAL"))
        nP_VLAANT := (cAliasQry)->(FieldPos("V65_VLAANT"))
        nP_VLSUSP := (cAliasQry)->(FieldPos("V65_VLSUSP"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V65_VERSAO"))
        
        // Campos para construção da Relação
        nP_TPPROC := (cAliasQry)->(FieldPos("V65_TPPROC"))
        nP_NRPROC := (cAliasQry)->(FieldPos("V65_NRPROC"))
        nP_CODSUP := (cAliasQry)->(FieldPos("V65_CODSUP"))
        nP_SEQIRC := (cAliasQry)->(FieldPos("V65_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]     := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]         := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]     := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]        := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]       := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]     := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]  := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA] := (cAliasQry)->(FieldGet(nP_TPCR))
            aAnalitico[nPosValores][ANALITICO_PRCINDAPU]  := TAFTpIndapu( (cAliasQry)->(FieldGet(nP_INDAPU)) )
            aAnalitico[nPosValores][ANALITICO_PRCVLRRET]  := (cAliasQry)->(FieldGet(nP_VLRRET))
            aAnalitico[nPosValores][ANALITICO_PRCVLRJUD]  := (cAliasQry)->(FieldGet(nP_VLRJUD))
            aAnalitico[nPosValores][ANALITICO_PRCVLACAL]  := (cAliasQry)->(FieldGet(nP_VLACAL))
            aAnalitico[nPosValores][ANALITICO_PRCVLAANT]  := (cAliasQry)->(FieldGet(nP_VLAANT))
            aAnalitico[nPosValores][ANALITICO_PRCVLSUSP]  := (cAliasQry)->(FieldGet(nP_VLSUSP))
            aAnalitico[nPosValores][ANALITICO_FORABA]     := "PRCVAL"
            aAnalitico[nPosValores][ANALITICO_ABA]        := "5A"
            aAnalitico[nPosValores][ANALITICO_PERREF]     := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]     := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]     := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]    := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))   + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPPROC)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRPROC)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CODSUP)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV66
@type           Function
@description    Processa registros da tabela V66 (Deduções Processo - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV66( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPDEDU     as numeric
    Local nP_VLSUSP     as numeric
    Local nP_INSCPL     as numeric
    Local nP_VLFUNP     as numeric
    Local nP_TPCR       as numeric
    Local nP_VERSAO     as numeric
    
    Local nP_TPPROC     as numeric
    Local nP_NRPROC     as numeric
    Local nP_CODSUP     as numeric
    Local nP_INDAPU     as numeric
    Local nP_SEQUEN     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização das variáveis de posição
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPDEDU   := 0
    nP_VLSUSP   := 0
    nP_INSCPL   := 0
    nP_VLFUNP   := 0
    nP_TPCR     := 0
    nP_VERSAO   := 0

    nP_TPPROC   := 0
    nP_NRPROC   := 0
    nP_CODSUP   := 0
    nP_INDAPU   := 0
    nP_SEQUEN   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V66_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V66_ID"))
        nP_TPDEDU := (cAliasQry)->(FieldPos("V66_TPDEDU"))
        nP_VLSUSP := (cAliasQry)->(FieldPos("V66_VLSUSP"))
        nP_INSCPL := (cAliasQry)->(FieldPos("V66_INSCPL"))
        nP_VLFUNP := (cAliasQry)->(FieldPos("V66_VLFUNP"))
        nP_TPCR   := (cAliasQry)->(FieldPos("V66_TPCR"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V66_VERSAO"))
        
     
        nP_TPPROC := (cAliasQry)->(FieldPos("V66_TPPROC"))
        nP_NRPROC := (cAliasQry)->(FieldPos("V66_NRPROC"))
        nP_CODSUP := (cAliasQry)->(FieldPos("V66_CODSUP"))
        nP_INDAPU := (cAliasQry)->(FieldPos("V66_INDAPU"))
        nP_SEQUEN := (cAliasQry)->(FieldPos("V66_SEQUEN"))
        nP_SEQIRC := (cAliasQry)->(FieldPos("V66_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_PRCDEDTPDEDU] := TAFTpDed( (cAliasQry)->(FieldGet(nP_TPDEDU)) )
            aAnalitico[nPosValores][ANALITICO_PRCDEDVLSUSP] := (cAliasQry)->(FieldGet(nP_VLSUSP))
            aAnalitico[nPosValores][ANALITICO_PRCDEDINSCPL] := (cAliasQry)->(FieldGet(nP_INSCPL))
            aAnalitico[nPosValores][ANALITICO_PRCDEDVLFUNP] := (cAliasQry)->(FieldGet(nP_VLFUNP))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "PRCDED"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "5B"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := "" 
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "3"
            aAnalitico[nPosValores][ANALITICO_CODRECEITA]   := (cAliasQry)->(FieldGet(nP_TPCR))
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]      := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))   + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPPROC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRPROC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CODSUP)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_INDAPU)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQUEN)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))
                                                                                                                                                                                                                                                                                                                            
            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV67
@type           Function
@description    Processa registros da tabela V67 (Beneficiários Processo - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV67( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_CPFDEP     as numeric
    Local nP_VLSUSP     as numeric
    Local nP_VERSAO     as numeric
    Local nP_TPCR       as numeric
    
    Local nP_TPPROC     as numeric
    Local nP_NRPROC     as numeric
    Local nP_CODSUP     as numeric
    Local nP_INDAPU     as numeric
    Local nP_SEQV66     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização das variáveis
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_CPFDEP   := 0
    nP_VLSUSP   := 0
    nP_VERSAO   := 0
    nP_TPCR     := 0
    nP_TPPROC   := 0
    nP_NRPROC   := 0
    nP_CODSUP   := 0
    nP_INDAPU   := 0
    nP_SEQV66   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V67_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V67_ID"))
        nP_CPFDEP := (cAliasQry)->(FieldPos("V67_CPFDEP"))
        nP_VLSUSP := (cAliasQry)->(FieldPos("V67_VLSUSP"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V67_VERSAO"))
        nP_TPCR   := (cAliasQry)->(FieldPos("V67_TPCR"))
        
     
        nP_TPPROC := (cAliasQry)->(FieldPos("V67_TPPROC"))
        nP_NRPROC := (cAliasQry)->(FieldPos("V67_NRPROC"))
        nP_CODSUP := (cAliasQry)->(FieldPos("V67_CODSUP"))
        nP_INDAPU := (cAliasQry)->(FieldPos("V67_INDAPU"))
        nP_SEQV66 := (cAliasQry)->(FieldPos("V67_SEQV66"))
        nP_SEQIRC := (cAliasQry)->(FieldPos("V67_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_PRCBENCPFDEP] := (cAliasQry)->(FieldGet(nP_CPFDEP))
            aAnalitico[nPosValores][ANALITICO_PRCBENVLSUSP] := (cAliasQry)->(FieldGet(nP_VLSUSP))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "PRCBEN"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "5C"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := "" 
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA]   := (cAliasQry)->(FieldGet(nP_TPCR))
            aAnalitico[nPosValores][ANALITICO_RELACAO]      := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))   + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPPROC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRPROC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CODSUP)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_INDAPU)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQV66)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CPFDEP)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV68
@type           Function
@description    Processa registros da tabela V68 (Plano Saúde Titular - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV68( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_CNPJOP     as numeric
    Local nP_REGANS     as numeric
    Local nP_VLRTIT     as numeric
    Local nP_VERSAO     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0    
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_CNPJOP   := 0
    nP_REGANS   := 0
    nP_VLRTIT   := 0
    nP_VERSAO   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V68_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V68_ID"))
        nP_CNPJOP := (cAliasQry)->(FieldPos("V68_CNPJOP"))
        nP_REGANS := (cAliasQry)->(FieldPos("V68_REGANS"))
        nP_VLRTIT := (cAliasQry)->(FieldPos("V68_VLRTIT"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V68_VERSAO"))
        nP_SEQIRC := (cAliasQry)->(FieldPos("V68_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]        := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]            := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]        := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]           := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]          := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]        := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]     := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_PLSAUDECNPJ]   := (cAliasQry)->(FieldGet(nP_CNPJOP))
            aAnalitico[nPosValores][ANALITICO_PLSAUDEREGANS] := (cAliasQry)->(FieldGet(nP_REGANS))
            aAnalitico[nPosValores][ANALITICO_PLSAUDEVLRTIT] := (cAliasQry)->(FieldGet(nP_VLRTIT))
            aAnalitico[nPosValores][ANALITICO_FORABA]        := "PLASAU"
            aAnalitico[nPosValores][ANALITICO_ABA]           := "06"
            aAnalitico[nPosValores][ANALITICO_PERREF]        := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]        := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]        := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]       := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CNPJOP)))) + "|" + ;
                                                                AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV69
@type           Function
@description    Processa registros da tabela V69 (Plano Saúde Dependente - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV69( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_CPFDEP     as numeric
    Local nP_VLRDEP     as numeric
    Local nP_VERSAO     as numeric
    Local nP_CNPJOP     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_CPFDEP   := 0
    nP_VLRDEP   := 0
    nP_VERSAO   := 0
    nP_CNPJOP   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V69_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V69_ID"))
        nP_CPFDEP := (cAliasQry)->(FieldPos("V69_CPFDEP"))
        nP_VLRDEP := (cAliasQry)->(FieldPos("V69_VLRDEP"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V69_VERSAO"))
        nP_CNPJOP := (cAliasQry)->(FieldPos("V69_CNPJOP"))
        nP_SEQIRC := (cAliasQry)->(FieldPos("V69_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]         := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]             := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]         := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]            := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]           := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]         := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]      := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_DEPSAUDECPF]    := (cAliasQry)->(FieldGet(nP_CPFDEP))
            aAnalitico[nPosValores][ANALITICO_DEPSAUDEVLRDEP] := (cAliasQry)->(FieldGet(nP_VLRDEP))
            aAnalitico[nPosValores][ANALITICO_FORABA]         := "DEPSAU"
            aAnalitico[nPosValores][ANALITICO_ABA]            := "6A"
            aAnalitico[nPosValores][ANALITICO_PERREF]         := "" 
            aAnalitico[nPosValores][ANALITICO_ORIGEM]         := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]         := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]        := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CNPJOP)))) + "|" + ;
                                                                 AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CPFDEP)))) + "|" + ;
                                                                 AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))                                                                                                                                                                                                                                                                                                                            

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV6A
@type           Function
@description    Processa registros da tabela V6A (Reembolso Médico - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV6A( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_INDREM     as numeric
    Local nP_CNPJOP     as numeric
    Local nP_REGANS     as numeric
    Local nP_VERSAO     as numeric
    Local nP_SEQUEN     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_INDREM   := 0
    nP_CNPJOP   := 0
    nP_REGANS   := 0
    nP_VERSAO   := 0
    nP_SEQUEN   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V6A_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V6A_ID"))
        nP_INDREM := (cAliasQry)->(FieldPos("V6A_INDREM"))
        nP_CNPJOP := (cAliasQry)->(FieldPos("V6A_CNPJOP"))
        nP_REGANS := (cAliasQry)->(FieldPos("V6A_REGANS"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V6A_VERSAO"))
        nP_SEQUEN := (cAliasQry)->(FieldPos("V6A_SEQUEN"))
        nP_SEQIRC := (cAliasQry)->(FieldPos("V6A_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_REMMEDINDREM] := TAFIndRee( (cAliasQry)->(FieldGet(nP_INDREM)) )
            aAnalitico[nPosValores][ANALITICO_REMMEDCNPJOP] := (cAliasQry)->(FieldGet(nP_CNPJOP))
            aAnalitico[nPosValores][ANALITICO_REMMEDREGANS] := (cAliasQry)->(FieldGet(nP_REGANS))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "REMMED"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "07"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "3" 
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]      := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQUEN)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV54
@type           Function
@description    Processa registros da tabela V54 (Info. Complementar - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV54( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
   
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPINSC     as numeric
    Local nP_NRINSC     as numeric
    Local nP_VLREMB     as numeric
    Local nP_VLRANT     as numeric
    Local nP_VERSAO     as numeric
    Local nP_SEQUEN     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPINSC   := 0
    nP_NRINSC   := 0
    nP_VLREMB   := 0
    nP_VLRANT   := 0
    nP_VERSAO   := 0
    nP_SEQUEN   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V54_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V54_ID"))
        nP_TPINSC := (cAliasQry)->(FieldPos("V54_TPINSC"))
        nP_NRINSC := (cAliasQry)->(FieldPos("V54_NRINSC"))
        nP_VLREMB := (cAliasQry)->(FieldPos("V54_VLREMB"))
        nP_VLRANT := (cAliasQry)->(FieldPos("V54_VLRANT"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V54_VERSAO"))
        nP_SEQUEN := (cAliasQry)->(FieldPos("V54_SEQUEN"))
        nP_SEQIRC := (cAliasQry)->(FieldPos("V54_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_REMTIDTPINSC] := TAFTpInscr( (cAliasQry)->(FieldGet(nP_TPINSC)) )
            aAnalitico[nPosValores][ANALITICO_REMTIDNRINSC] := (cAliasQry)->(FieldGet(nP_NRINSC))
            aAnalitico[nPosValores][ANALITICO_REMTIDVLREMB] := (cAliasQry)->(FieldGet(nP_VLREMB))
            aAnalitico[nPosValores][ANALITICO_REMTIDVLRANT] := (cAliasQry)->(FieldGet(nP_VLRANT))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "REMTID"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "7A"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "3" 
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]      := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQUEN)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPINSC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRINSC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV50
@type           Function
@description    Processa registros da tabela V50 (Remuneração Dependente - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV50( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_CPFDEP     as numeric
    Local nP_VERSAO     as numeric
    Local nP_SEQUEN     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_CPFDEP   := 0
    nP_VERSAO   := 0
    nP_SEQUEN   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V50_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V50_ID"))
        nP_CPFDEP := (cAliasQry)->(FieldPos("V50_CPFDEP"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V50_VERSAO"))
        nP_SEQUEN := (cAliasQry)->(FieldPos("V50_SEQUEN"))
        nP_SEQIRC := (cAliasQry)->(FieldPos("V50_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]    := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]        := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]    := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]       := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]      := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]    := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA] := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_REMDEPCPF] := (cAliasQry)->(FieldGet(nP_CPFDEP))
            aAnalitico[nPosValores][ANALITICO_FORABA]    := "REMDEP"
            aAnalitico[nPosValores][ANALITICO_ABA]       := "7B"
            aAnalitico[nPosValores][ANALITICO_PERREF]    := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]    := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]    := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]   := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQUEN)))) + "|" + ;
                                                            AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CPFDEP)))) + "|" + ;
                                                            AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV51
@type           Function
@description    Processa registros da tabela V51 (Detalhe Dependente - S-5002).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          aAnalitico  , Array     , Array de retorno
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV51( cAliasQry as Character, cPeriodo as Character, aAnalitico as Array, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPINSC     as numeric
    Local nP_NRINSC     as numeric
    Local nP_VLREMB     as numeric
    Local nP_VLRANT     as numeric
    Local nP_VERSAO     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default aAnalitico  := {}
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPINSC   := 0
    nP_NRINSC   := 0
    nP_VLREMB   := 0
    nP_VLRANT   := 0
    nP_VERSAO   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        nP_FILIAL := (cAliasQry)->(FieldPos("V51_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos("V51_ID"))
        nP_TPINSC := (cAliasQry)->(FieldPos("V51_TPINSC"))
        nP_NRINSC := (cAliasQry)->(FieldPos("V51_NRINSC"))
        nP_VLREMB := (cAliasQry)->(FieldPos("V51_VLREMB"))
        nP_VLRANT := (cAliasQry)->(FieldPos("V51_VLRANT"))
        nP_VERSAO := (cAliasQry)->(FieldPos("V51_VERSAO"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun("", cCpf, cFil)

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-5002'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_DETDEPTPINSC] := TAFTpInscr( (cAliasQry)->(FieldGet(nP_TPINSC)) )
            aAnalitico[nPosValores][ANALITICO_DETDEPNRINSC] := (cAliasQry)->(FieldGet(nP_NRINSC))
            aAnalitico[nPosValores][ANALITICO_DETDEPVLREMB] := (cAliasQry)->(FieldGet(nP_VLREMB))
            aAnalitico[nPosValores][ANALITICO_DETDEPVLRANT] := (cAliasQry)->(FieldGet(nP_VLRANT))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "DETDEP"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "7C"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := "" 
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7V
@type           Function
@description    Processa registros da tabela V7V (Pensão Alimentícia - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V7V")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7V( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cReceita      as character
    Local cNome         as character
    Local cKeyCache     as character
    Local nSequen       as numeric

    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_TPREND     as numeric
    Local nP_CPFDEP     as numeric
    Local nP_VLPEN      as numeric
    Local nP_VERSAO     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cReceita    := ""
    cNome       := ""
    cKeyCache   := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_TPREND   := 0
    nP_CPFDEP   := 0
    nP_VLPEN    := 0
    nP_VERSAO   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos(cTable + "_TPCR"))
        nP_TPREND := (cAliasQry)->(FieldPos(cTable + "_TPREND"))
        nP_CPFDEP := (cAliasQry)->(FieldPos(cTable + "_CPFDEP"))
        nP_VLPEN  := (cAliasQry)->(FieldPos(cTable + "_VLPEN"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            // ----------------------------------------------------------------
            // OTIMIZAÇÃO DE PERFORMANCE: Cache de Código de Receita (C6R)
            // ----------------------------------------------------------------
            // Inicializa o HashMap na primeira utilização se estiver vazio
            If hCacheC6R_Mod == Nil
                hCacheC6R_Mod := THashMap():New()
            EndIf

            // Monta a chave única para busca no Hash: Filial + Codigo Receita (TPCR)
            cKeyCache := cValToChar((cAliasQry)->(FieldGet(nP_FILIAL))) + "|" + AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))

            // Verifica se já existe no cache
            If !hCacheC6R_Mod:Get(cKeyCache, @cReceita)
                
                // Se não existe, busca no banco de dados (I/O)
                cReceita := AllTrim(Posicione("C6R", 3, xFilial("C6R", (cAliasQry)->(FieldGet(nP_FILIAL))) + PadR((cAliasQry)->(FieldGet(nP_TPCR)), TamSx3("C6R_ID")[1]), "C6R_CODIGO"))
                
                // Salva no cache para as próximas iterações
                hCacheC6R_Mod:Set(cKeyCache, cReceita)
                
            EndIf

            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA]   := cReceita
            aAnalitico[nPosValores][ANALITICO_TPRENDALIM]   := TAFTpRend( (cAliasQry)->(FieldGet(nP_TPREND)) )
            aAnalitico[nPosValores][ANALITICO_CPFDEPALIM]   := (cAliasQry)->(FieldGet(nP_CPFDEP))
            aAnalitico[nPosValores][ANALITICO_VLRDEDALIM]   := (cAliasQry)->(FieldGet(nP_VLPEN))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "PENALI"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "03"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := "" 
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
                
            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7W
@type           Function
@description    Processa registros da tabela V7W (Previdência Complementar - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração (AAAAMM)
@param          cTable      , Character , Prefixo da tabela (Ex: "V7W")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7W( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cReceita      as character
    Local cNome         as character
    Local cKeyCache     as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_TPREV      as numeric
    Local nP_INSCPL     as numeric
    Local nP_VLCOMP     as numeric
    Local nP_VLDEP1     as numeric
    Local nP_VLPATR     as numeric
    Local nP_VLPA13     as numeric
    Local nP_VERSAO     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cReceita    := ""
    cNome       := ""
    cKeyCache   := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_TPREV    := 0
    nP_INSCPL   := 0
    nP_VLCOMP   := 0
    nP_VLDEP1   := 0
    nP_VLPATR   := 0
    nP_VLPA13   := 0
    nP_VERSAO   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento dos índices dos campos na estrutura da tabela
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos(cTable + "_TPCR"))
        nP_TPREV  := (cAliasQry)->(FieldPos(cTable + "_TPREV"))
        nP_INSCPL := (cAliasQry)->(FieldPos(cTable + "_INSCPL"))
        nP_VLCOMP := (cAliasQry)->(FieldPos(cTable + "_VLCOMP"))
        nP_VLDEP1 := (cAliasQry)->(FieldPos(cTable + "_VLDEP1"))
        nP_VLPATR := (cAliasQry)->(FieldPos(cTable + "_VLPATR"))
        nP_VLPA13 := (cAliasQry)->(FieldPos(cTable + "_VLPA13"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            // ----------------------------------------------------------------
            // OTIMIZAÇÃO DE PERFORMANCE: Cache de Código de Receita (C6R)
            // ----------------------------------------------------------------
            // Inicializa o HashMap na primeira utilização se estiver vazio
            If hCacheC6R_Mod == Nil
                hCacheC6R_Mod := THashMap():New()
            EndIf

            // Monta a chave única para busca no Hash: Filial + Codigo Receita (TPCR)
            cKeyCache := cValToChar((cAliasQry)->(FieldGet(nP_FILIAL))) + "|" + AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))

            // Verifica se já existe no cache
            If !hCacheC6R_Mod:Get(cKeyCache, @cReceita)
                
                // Se não existe, busca no banco de dados (I/O)
                cReceita := AllTrim(Posicione("C6R", 3, xFilial("C6R", (cAliasQry)->(FieldGet(nP_FILIAL))) + PadR((cAliasQry)->(FieldGet(nP_TPCR)), TamSx3("C6R_ID")[1]), "C6R_CODIGO"))
                
                // Salva no cache para as próximas iterações
                hCacheC6R_Mod:Set(cKeyCache, cReceita)
                
            EndIf

            aAnalitico[nPosValores][ANALITICO_FILIAL]         := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]             := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]         := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]            := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]           := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]         := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]      := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA]     := cReceita
            
            // Tratamento de Domínio
            aAnalitico[nPosValores][ANALITICO_TPPREV]         := TAFTpPrev( (cAliasQry)->(FieldGet(nP_TPREV)) )
            
            aAnalitico[nPosValores][ANALITICO_CNPJPREV]       := (cAliasQry)->(FieldGet(nP_INSCPL))
            aAnalitico[nPosValores][ANALITICO_VLRDEDPCPREV]   := (cAliasQry)->(FieldGet(nP_VLCOMP))
            aAnalitico[nPosValores][ANALITICO_VLRDEDPCPREV13] := (cAliasQry)->(FieldGet(nP_VLDEP1))
            aAnalitico[nPosValores][ANALITICO_VLRDEDFUNP]     := (cAliasQry)->(FieldGet(nP_VLPATR))
            aAnalitico[nPosValores][ANALITICO_VLRDEDFUNP13]   := (cAliasQry)->(FieldGet(nP_VLPA13))
            aAnalitico[nPosValores][ANALITICO_FORABA]         := "PREVCL"
            aAnalitico[nPosValores][ANALITICO_ABA]            := "04"
            aAnalitico[nPosValores][ANALITICO_PERREF]         := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]         := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]         := (cAliasQry)->(FieldGet(nP_VERSAO))
            
            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7X
@type           Function
@description    Processa registros da tabela V7X (Processos Judiciais - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V7X")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7X( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cReceita      as character
    Local cNome         as character
    Local cKeyCache     as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_TPPROC     as numeric
    Local nP_NRPROC     as numeric
    Local nP_CODSUP     as numeric
    Local nP_VERSAO     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cReceita    := ""
    cNome       := ""
    cKeyCache   := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_TPPROC   := 0
    nP_NRPROC   := 0
    nP_CODSUP   := 0
    nP_VERSAO   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos(cTable + "_TPCR"))
        nP_TPPROC := (cAliasQry)->(FieldPos(cTable + "_TPPROC"))
        nP_NRPROC := (cAliasQry)->(FieldPos(cTable + "_NRPROC"))
        nP_CODSUP := (cAliasQry)->(FieldPos(cTable + "_CODSUP"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))
        nP_SEQIRC := (cAliasQry)->(FieldPos(cTable + "_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )
    
        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            // ----------------------------------------------------------------
            // OTIMIZAÇÃO DE PERFORMANCE: Cache de Código de Receita (C6R)
            // ----------------------------------------------------------------
            // Inicializa o HashMap na primeira utilização se estiver vazio
            If hCacheC6R_Mod == Nil
                hCacheC6R_Mod := THashMap():New()
            EndIf

            // Monta a chave única para busca no Hash: Filial + Codigo Receita (TPCR)
            cKeyCache := cValToChar((cAliasQry)->(FieldGet(nP_FILIAL))) + "|" + AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))

            // Verifica se já existe no cache
            If !hCacheC6R_Mod:Get(cKeyCache, @cReceita)
                
                // Se não existe, busca no banco de dados (I/O)
                cReceita := AllTrim(Posicione("C6R", 3, xFilial("C6R", (cAliasQry)->(FieldGet(nP_FILIAL))) + PadR((cAliasQry)->(FieldGet(nP_TPCR)), TamSx3("C6R_ID")[1]), "C6R_CODIGO"))
                
                // Salva no cache para as próximas iterações
                hCacheC6R_Mod:Set(cKeyCache, cReceita)
                
            EndIf

            aAnalitico[nPosValores][ANALITICO_FILIAL]     := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]         := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]     := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]        := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]       := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]     := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]  := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA] := cReceita
            
            // Tratamento de Domínio (Tipo Processo)
            aAnalitico[nPosValores][ANALITICO_TPPROC]     := TAFTpProc( (cAliasQry)->(FieldGet(nP_TPPROC)) )
            
            aAnalitico[nPosValores][ANALITICO_NRPROC]     := (cAliasQry)->(FieldGet(nP_NRPROC))
            aAnalitico[nPosValores][ANALITICO_CODSUP]     := (cAliasQry)->(FieldGet(nP_CODSUP))
            aAnalitico[nPosValores][ANALITICO_FORABA]     := "PROCRE"
            aAnalitico[nPosValores][ANALITICO_ABA]        := "05"
            aAnalitico[nPosValores][ANALITICO_PERREF]     := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]     := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]     := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]    := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))   + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPPROC)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRPROC)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CODSUP)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))
                                                                                                                                                                                                                                                                                                                            
            (cAliasQry)->(DbSkip())
                                                                                                                                                                                                                                                                                                                            
        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7Y
@type           Function
@description    Processa registros da tabela V7Y (RRA - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V7Y")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7Y( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cReceita      as character
    Local cNome         as character
    Local cKeyCache     as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_INDAPU     as numeric
    Local nP_VLRRET     as numeric
    Local nP_VLRJUD     as numeric
    Local nP_VLACAL     as numeric
    Local nP_VLAANT     as numeric
    Local nP_VLSUSP     as numeric
    Local nP_VERSAO     as numeric
 
    Local nP_TPPROC     as numeric
    Local nP_NRPROC     as numeric
    Local nP_CODSUP     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cReceita    := ""
    cNome       := ""
    cKeyCache   := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_INDAPU   := 0
    nP_VLRRET   := 0
    nP_VLRJUD   := 0
    nP_VLACAL   := 0
    nP_VLAANT   := 0
    nP_VLSUSP   := 0
    nP_VERSAO   := 0

    nP_TPPROC   := 0
    nP_NRPROC   := 0
    nP_CODSUP   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos(cTable + "_TPCR"))
        nP_INDAPU := (cAliasQry)->(FieldPos(cTable + "_INDAPU"))
        nP_VLRRET := (cAliasQry)->(FieldPos(cTable + "_VLRRET"))
        nP_VLRJUD := (cAliasQry)->(FieldPos(cTable + "_VLRJUD"))
        nP_VLACAL := (cAliasQry)->(FieldPos(cTable + "_VLACAL"))
        nP_VLAANT := (cAliasQry)->(FieldPos(cTable + "_VLAANT"))
        nP_VLSUSP := (cAliasQry)->(FieldPos(cTable + "_VLSUSP"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))
        
        nP_TPPROC := (cAliasQry)->(FieldPos(cTable + "_TPPROC"))
        nP_NRPROC := (cAliasQry)->(FieldPos(cTable + "_NRPROC"))
        nP_CODSUP := (cAliasQry)->(FieldPos(cTable + "_CODSUP"))
        nP_SEQIRC := (cAliasQry)->(FieldPos(cTable + "_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            // ----------------------------------------------------------------
            // OTIMIZAÇÃO DE PERFORMANCE: Cache de Código de Receita (C6R)
            // ----------------------------------------------------------------
            // Inicializa o HashMap na primeira utilização se estiver vazio
            If hCacheC6R_Mod == Nil
                hCacheC6R_Mod := THashMap():New()
            EndIf

            // Monta a chave única para busca no Hash: Filial + Codigo Receita (TPCR)
            cKeyCache := cValToChar((cAliasQry)->(FieldGet(nP_FILIAL))) + "|" + AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))

            // Verifica se já existe no cache
            If !hCacheC6R_Mod:Get(cKeyCache, @cReceita)
                
                // Se não existe, busca no banco de dados (I/O)
                cReceita := AllTrim(Posicione("C6R", 3, xFilial("C6R", (cAliasQry)->(FieldGet(nP_FILIAL))) + PadR((cAliasQry)->(FieldGet(nP_TPCR)), TamSx3("C6R_ID")[1]), "C6R_CODIGO"))
                
                // Salva no cache para as próximas iterações
                hCacheC6R_Mod:Set(cKeyCache, cReceita)
                
            EndIf
            
            aAnalitico[nPosValores][ANALITICO_FILIAL]     := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]         := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]     := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]        := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]       := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]     := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]  := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA] := cReceita
            
            // Tratamento de Domínio (Indicador Apuração)
            aAnalitico[nPosValores][ANALITICO_PRCINDAPU]  := TAFTpIndapu( (cAliasQry)->(FieldGet(nP_INDAPU)) )
            
            aAnalitico[nPosValores][ANALITICO_PRCVLRRET]  := (cAliasQry)->(FieldGet(nP_VLRRET))
            aAnalitico[nPosValores][ANALITICO_PRCVLRJUD]  := (cAliasQry)->(FieldGet(nP_VLRJUD))
            aAnalitico[nPosValores][ANALITICO_PRCVLACAL]  := (cAliasQry)->(FieldGet(nP_VLACAL))
            aAnalitico[nPosValores][ANALITICO_PRCVLAANT]  := (cAliasQry)->(FieldGet(nP_VLAANT))
            aAnalitico[nPosValores][ANALITICO_PRCVLSUSP]  := (cAliasQry)->(FieldGet(nP_VLSUSP))
            aAnalitico[nPosValores][ANALITICO_FORABA]     := "PRCVAL"
            aAnalitico[nPosValores][ANALITICO_ABA]        := "5A"
            aAnalitico[nPosValores][ANALITICO_PERREF]     := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]     := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]     := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]    := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))   + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPPROC)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRPROC)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CODSUP)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_INDAPU)))) + "|" + ;
                                                             AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))                                                                                                                                                                                                                                                                                                                            

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV7Z
@type           Function
@description    Processa registros da tabela V7Z (Deduções Processo - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V7Z")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV7Z( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cReceita      as character
    Local cNome         as character
    Local cKeyCache     as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_TPDEDU     as numeric
    Local nP_VLSUSP     as numeric
    Local nP_INSCPL     as numeric
    Local nP_VLFUNP     as numeric
    Local nP_VERSAO     as numeric

    Local nP_TPPROC     as numeric
    Local nP_NRPROC     as numeric
    Local nP_CODSUP     as numeric
    Local nP_INDAPU     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cReceita    := ""
    cNome       := ""
    cKeyCache   := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_TPDEDU   := 0
    nP_VLSUSP   := 0
    nP_INSCPL   := 0
    nP_VLFUNP   := 0
    nP_VERSAO   := 0

    nP_TPPROC   := 0
    nP_NRPROC   := 0
    nP_CODSUP   := 0
    nP_INDAPU   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos(cTable + "_TPCR"))
        nP_TPDEDU := (cAliasQry)->(FieldPos(cTable + "_TPDEDU"))
        nP_VLSUSP := (cAliasQry)->(FieldPos(cTable + "_VLSUSP"))
        nP_INSCPL := (cAliasQry)->(FieldPos(cTable + "_INSCPL"))
        nP_VLFUNP := (cAliasQry)->(FieldPos(cTable + "_VLFUNP"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))
        
        nP_TPPROC := (cAliasQry)->(FieldPos(cTable + "_TPPROC"))
        nP_NRPROC := (cAliasQry)->(FieldPos(cTable + "_NRPROC"))
        nP_CODSUP := (cAliasQry)->(FieldPos(cTable + "_CODSUP"))
        nP_INDAPU := (cAliasQry)->(FieldPos(cTable + "_INDAPU"))
        nP_SEQIRC := (cAliasQry)->(FieldPos(cTable + "_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            // ----------------------------------------------------------------
            // OTIMIZAÇÃO DE PERFORMANCE: Cache de Código de Receita (C6R)
            // ----------------------------------------------------------------
            // Inicializa o HashMap na primeira utilização se estiver vazio
            If hCacheC6R_Mod == Nil
                hCacheC6R_Mod := THashMap():New()
            EndIf

            // Monta a chave única para busca no Hash: Filial + Codigo Receita (TPCR)
            cKeyCache := cValToChar((cAliasQry)->(FieldGet(nP_FILIAL))) + "|" + AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))

            // Verifica se já existe no cache
            If !hCacheC6R_Mod:Get(cKeyCache, @cReceita)
                
                // Se não existe, busca no banco de dados (I/O)
                cReceita := AllTrim(Posicione("C6R", 3, xFilial("C6R", (cAliasQry)->(FieldGet(nP_FILIAL))) + PadR((cAliasQry)->(FieldGet(nP_TPCR)), TamSx3("C6R_ID")[1]), "C6R_CODIGO"))
                
                // Salva no cache para as próximas iterações
                hCacheC6R_Mod:Set(cKeyCache, cReceita)
                
            EndIf
                    
            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA]   := cReceita
            
            // Tratamento de Domínio (Tipo Dedução)
            aAnalitico[nPosValores][ANALITICO_PRCDEDTPDEDU] := TAFTpDed( (cAliasQry)->(FieldGet(nP_TPDEDU)) )
            
            aAnalitico[nPosValores][ANALITICO_PRCDEDVLSUSP] := (cAliasQry)->(FieldGet(nP_VLSUSP))
            aAnalitico[nPosValores][ANALITICO_PRCDEDINSCPL] := (cAliasQry)->(FieldGet(nP_INSCPL))
            aAnalitico[nPosValores][ANALITICO_PRCDEDVLFUNP] := (cAliasQry)->(FieldGet(nP_VLFUNP))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "PRCDED"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "5B"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]      := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))   + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPPROC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRPROC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CODSUP)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_INDAPU)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))                                                                                                                                                                                                                                                                                                                            

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8A
@type           Function
@description    Processa registros da tabela V8A (Beneficiários Processo - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V8A")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8A( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cReceita      as character
    Local cNome         as character
    Local cKeyCache     as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPCR       as numeric
    Local nP_CPFDEP     as numeric
    Local nP_VLSUSP     as numeric
    Local nP_VERSAO     as numeric

    Local nP_TPPROC     as numeric
    Local nP_NRPROC     as numeric
    Local nP_CODSUP     as numeric
    Local nP_INDAPU     as numeric
    Local nP_SEQUEN     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cReceita    := ""
    cNome       := ""
    cKeyCache   := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPCR     := 0
    nP_CPFDEP   := 0
    nP_VLSUSP   := 0
    nP_VERSAO   := 0

    nP_TPPROC   := 0
    nP_NRPROC   := 0
    nP_CODSUP   := 0
    nP_INDAPU   := 0
    nP_SEQUEN   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_TPCR   := (cAliasQry)->(FieldPos(cTable + "_TPCR"))
        nP_CPFDEP := (cAliasQry)->(FieldPos(cTable + "_CPFDEP"))
        nP_VLSUSP := (cAliasQry)->(FieldPos(cTable + "_VLSUSP"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))
        
        nP_TPPROC := (cAliasQry)->(FieldPos(cTable + "_TPPROC"))
        nP_NRPROC := (cAliasQry)->(FieldPos(cTable + "_NRPROC"))
        nP_CODSUP := (cAliasQry)->(FieldPos(cTable + "_CODSUP"))
        nP_INDAPU := (cAliasQry)->(FieldPos(cTable + "_INDAPU"))
        nP_SEQUEN := (cAliasQry)->(FieldPos(cTable + "_SEQUEN"))
        nP_SEQIRC := (cAliasQry)->(FieldPos(cTable + "_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            // ----------------------------------------------------------------
            // OTIMIZAÇÃO DE PERFORMANCE: Cache de Código de Receita (C6R)
            // ----------------------------------------------------------------
            // Inicializa o HashMap na primeira utilização se estiver vazio
            If hCacheC6R_Mod == Nil
                hCacheC6R_Mod := THashMap():New()
            EndIf

            // Monta a chave única para busca no Hash: Filial + Codigo Receita (TPCR)
            cKeyCache := cValToChar((cAliasQry)->(FieldGet(nP_FILIAL))) + "|" + AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))

            // Verifica se já existe no cache
            If !hCacheC6R_Mod:Get(cKeyCache, @cReceita)
                
                // Se não existe, busca no banco de dados (I/O)
                cReceita := AllTrim(Posicione("C6R", 3, xFilial("C6R", (cAliasQry)->(FieldGet(nP_FILIAL))) + PadR((cAliasQry)->(FieldGet(nP_TPCR)), TamSx3("C6R_ID")[1]), "C6R_CODIGO"))
                
                // Salva no cache para as próximas iterações
                hCacheC6R_Mod:Set(cKeyCache, cReceita)
                
            EndIf

            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA]   := cReceita
            aAnalitico[nPosValores][ANALITICO_PRCBENCPFDEP] := (cAliasQry)->(FieldGet(nP_CPFDEP))
            aAnalitico[nPosValores][ANALITICO_PRCBENVLSUSP] := (cAliasQry)->(FieldGet(nP_VLSUSP))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "PRCBEN"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "5C"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := "" 
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]      := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPCR))))   + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPPROC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRPROC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CODSUP)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_INDAPU)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQUEN)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8B
@type           Function
@description    Processa registros da tabela V8B (Plano Saúde Titular - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V8B")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8B( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_CNPJOP     as numeric
    Local nP_REGANS     as numeric
    Local nP_VLRTIT     as numeric
    Local nP_VERSAO     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0    
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_CNPJOP   := 0
    nP_REGANS   := 0
    nP_VLRTIT   := 0
    nP_VERSAO   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_CNPJOP := (cAliasQry)->(FieldPos(cTable + "_CNPJOP"))
        nP_REGANS := (cAliasQry)->(FieldPos(cTable + "_REGANS"))
        nP_VLRTIT := (cAliasQry)->(FieldPos(cTable + "_VLRTIT"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))
        nP_SEQIRC := (cAliasQry)->(FieldPos(cTable + "_SEQIRC"))

         // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]        := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]            := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]        := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]           := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]          := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]        := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]     := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_DEPSAUDECPF]   := '' // Campo vazio conforme original
            aAnalitico[nPosValores][ANALITICO_PLSAUDECNPJ]   := (cAliasQry)->(FieldGet(nP_CNPJOP))
            aAnalitico[nPosValores][ANALITICO_PLSAUDEREGANS] := (cAliasQry)->(FieldGet(nP_REGANS))
            aAnalitico[nPosValores][ANALITICO_PLSAUDEVLRTIT] := (cAliasQry)->(FieldGet(nP_VLRTIT))
            aAnalitico[nPosValores][ANALITICO_FORABA]        := "PLASAU"
            aAnalitico[nPosValores][ANALITICO_ABA]           := "06"
            aAnalitico[nPosValores][ANALITICO_PERREF]        := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]        := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]        := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]       := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CNPJOP)))) + "|" + ;
                                                                AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC)))) 

            (cAliasQry)->(DbSkip())

        EndDo

    EndIF

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8C
@type           Function
@description    Processa registros da tabela V8C (Plano Saúde Dependente - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V8C")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8C( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_CPFDEP     as numeric
    Local nP_VLRDEP     as numeric
    Local nP_VERSAO     as numeric
    Local nP_CNPJOP     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_CPFDEP   := 0
    nP_VLRDEP   := 0
    nP_VERSAO   := 0
    nP_CNPJOP   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_CPFDEP := (cAliasQry)->(FieldPos(cTable + "_CPFDEP"))
        nP_VLRDEP := (cAliasQry)->(FieldPos(cTable + "_VLRDEP"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))
        nP_CNPJOP := (cAliasQry)->(FieldPos(cTable + "_CNPJOP"))
        nP_SEQIRC := (cAliasQry)->(FieldPos(cTable + "_SEQIRC"))

         // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]         := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]             := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]         := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]            := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]           := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]         := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]      := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_DEPSAUDECPF]    := (cAliasQry)->(FieldGet(nP_CPFDEP))
            aAnalitico[nPosValores][ANALITICO_DEPSAUDEVLRDEP] := (cAliasQry)->(FieldGet(nP_VLRDEP))
            aAnalitico[nPosValores][ANALITICO_FORABA]         := "DEPSAU"
            aAnalitico[nPosValores][ANALITICO_ABA]            := "6A"
            aAnalitico[nPosValores][ANALITICO_PERREF]         := "" 
            aAnalitico[nPosValores][ANALITICO_ORIGEM]         := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]         := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]        := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CNPJOP)))) + "|" + ;
                                                                 AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CPFDEP)))) + "|" + ;
                                                                 AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8D
@type           Function
@description    Processa registros da tabela V8D (Reembolso Médico - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V8D")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8D( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_INDREM     as numeric
    Local nP_CNPJOP     as numeric
    Local nP_REGANS     as numeric
    Local nP_VERSAO     as numeric
    Local nP_SEQUEN     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_INDREM   := 0
    nP_CNPJOP   := 0
    nP_REGANS   := 0
    nP_VERSAO   := 0
    nP_SEQUEN   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_INDREM := (cAliasQry)->(FieldPos(cTable + "_INDREM"))
        nP_CNPJOP := (cAliasQry)->(FieldPos(cTable + "_CNPJOP"))
        nP_REGANS := (cAliasQry)->(FieldPos(cTable + "_REGANS"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))
        nP_SEQUEN := (cAliasQry)->(FieldPos(cTable + "_SEQUEN"))
        nP_SEQIRC := (cAliasQry)->(FieldPos(cTable + "_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )
            
            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            
            // Tratamento de Domínio (Indicador Reembolso)
            aAnalitico[nPosValores][ANALITICO_REMMEDINDREM] := TAFIndRee( (cAliasQry)->(FieldGet(nP_INDREM)) )
            
            aAnalitico[nPosValores][ANALITICO_REMMEDCNPJOP] := (cAliasQry)->(FieldGet(nP_CNPJOP))
            aAnalitico[nPosValores][ANALITICO_REMMEDREGANS] := (cAliasQry)->(FieldGet(nP_REGANS))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "REMMED"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "07"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "1" 
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]      := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQUEN)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8E
@type           Function
@description    Processa registros da tabela V8E (Reembolso Trans. - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V8E")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8E( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPINSC     as numeric
    Local nP_NRINSC     as numeric
    Local nP_VLREMB     as numeric
    Local nP_VLRANT     as numeric
    Local nP_VERSAO     as numeric
    Local nP_SEQUEN     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPINSC   := 0
    nP_NRINSC   := 0
    nP_VLREMB   := 0
    nP_VLRANT   := 0
    nP_VERSAO   := 0
    nP_SEQUEN   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_TPINSC := (cAliasQry)->(FieldPos(cTable + "_TPINSC"))
        nP_NRINSC := (cAliasQry)->(FieldPos(cTable + "_NRINSC"))
        nP_VLREMB := (cAliasQry)->(FieldPos(cTable + "_VLREMB"))
        nP_VLRANT := (cAliasQry)->(FieldPos(cTable + "_VLRANT"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))
        nP_SEQUEN := (cAliasQry)->(FieldPos(cTable + "_SEQUEN"))
        nP_SEQIRC := (cAliasQry)->(FieldPos(cTable + "_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            // Carga de Dados
            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            
            // Tratamento de Domínio (Tipo Inscrição)
            aAnalitico[nPosValores][ANALITICO_REMTIDTPINSC] := TAFTpInscr( (cAliasQry)->(FieldGet(nP_TPINSC)) )
            
            aAnalitico[nPosValores][ANALITICO_REMTIDNRINSC] := (cAliasQry)->(FieldGet(nP_NRINSC))
            aAnalitico[nPosValores][ANALITICO_REMTIDVLREMB] := (cAliasQry)->(FieldGet(nP_VLREMB))
            aAnalitico[nPosValores][ANALITICO_REMTIDVLRANT] := (cAliasQry)->(FieldGet(nP_VLRANT))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "REMTID"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "7A"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "1" 
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]      := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPINSC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRINSC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQUEN)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8F
@type           Function
@description    Processa registros da tabela V8F (Remuneração Dependente - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V8F")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8F( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_CPFDEP     as numeric
    Local nP_VERSAO     as numeric
    Local nP_SEQUEN     as numeric
    Local nP_SEQIRC     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis de Cache
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_CPFDEP   := 0
    nP_VERSAO   := 0
    nP_SEQUEN   := 0
    nP_SEQIRC   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_CPFDEP := (cAliasQry)->(FieldPos(cTable + "_CPFDEP"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))
        nP_SEQUEN := (cAliasQry)->(FieldPos(cTable + "_SEQUEN"))
        nP_SEQIRC := (cAliasQry)->(FieldPos(cTable + "_SEQIRC"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            aAnalitico[nPosValores][ANALITICO_FILIAL]    := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]        := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]    := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]       := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]      := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]    := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA] := CVALTOCHAR(STRZERO(nSequen, 3))
            aAnalitico[nPosValores][ANALITICO_REMDEPCPF] := (cAliasQry)->(FieldGet(nP_CPFDEP))
            aAnalitico[nPosValores][ANALITICO_FORABA]    := "REMDEP"
            aAnalitico[nPosValores][ANALITICO_ABA]       := "7B"
            aAnalitico[nPosValores][ANALITICO_PERREF]    := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]    := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]    := (cAliasQry)->(FieldGet(nP_VERSAO))
            aAnalitico[nPosValores][ANALITICO_RELACAO]   := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CPFDEP)))) + "|" + ;
                                                            AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQUEN)))) + "|" + ;
                                                            AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))  

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInV8G
@type           Function
@description    Processa registros da tabela V8G (Detalhe Dependente - S-1210).
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query de dados
@param          cPeriodo    , Character , Período de apuração
@param          cTable      , Character , Prefixo da tabela (Ex: "V8G")
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cIdFunc     , Character , ID do Funcionário
@param          cTipoEve    , Character , Tipo do Evento
@param          cCpf        , Character , CPF do Trabalhador
@param          cFil        , Character , Filial

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInV8G( cAliasQry as Character, cPeriodo as Character, cTable as Character, aAnalitico as Array, cIdFunc as Character, cTipoEve as Character, cCpf as Character, cFil as Character )

    // Declaração de Variáveis Locais
    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis de Cache de Posição de Posição
    Local nP_FILIAL     as numeric
    Local nP_ID         as numeric
    Local nP_TPINSC     as numeric
    Local nP_NRINSC     as numeric
    Local nP_VLREMB     as numeric
    Local nP_VLRANT     as numeric
    Local nP_VERSAO     as numeric
    Local nP_SEQUEN     as numeric
    Local nP_SEQIRC     as numeric
  
    Local nP_CPFDEP     as numeric

    // Inicialização dos parâmetros com valores default
    Default cAliasQry   := ""
    Default cPeriodo    := ""
    Default cTable      := ""
    Default aAnalitico  := {}
    Default cIdFunc     := ""
    Default cTipoEve    := ""
    Default cCpf        := ""
    Default cFil        := ""

    // Inicialização de Variáveis
    nPosValores := 0
    cNome       := ""
    nSequen     := 0
    
    // Inicialização de Variáveis de Cache
    nP_FILIAL   := 0
    nP_ID       := 0
    nP_TPINSC   := 0
    nP_NRINSC   := 0
    nP_VLREMB   := 0
    nP_VLRANT   := 0
    nP_VERSAO   := 0
    nP_SEQUEN   := 0
    nP_SEQIRC   := 0

    nP_CPFDEP   := 0

    // Verifica se o Alias da query temporária está aberto e válido antes de processar
    If Select( cAliasQry ) > 0

        // Mapeamento de Campos
        nP_FILIAL := (cAliasQry)->(FieldPos(cTable + "_FILIAL"))
        nP_ID     := (cAliasQry)->(FieldPos(cTable + "_ID"))
        nP_TPINSC := (cAliasQry)->(FieldPos(cTable + "_TPINSC"))
        nP_NRINSC := (cAliasQry)->(FieldPos(cTable + "_NRINSC"))
        nP_VLREMB := (cAliasQry)->(FieldPos(cTable + "_VLREMB"))
        nP_VLRANT := (cAliasQry)->(FieldPos(cTable + "_VLRANT"))
        nP_VERSAO := (cAliasQry)->(FieldPos(cTable + "_VERSAO"))
        nP_SEQUEN := (cAliasQry)->(FieldPos(cTable + "_SEQUEN"))
        nP_SEQIRC := (cAliasQry)->(FieldPos(cTable + "_SEQIRC"))
        
        // Campo necessário para montagem da relação (Filho do Pai V8F)
        nP_CPFDEP := (cAliasQry)->(FieldPos(cTable + "_CPFDEP"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( cIdFunc, cCpf, cFil )

        ( cAliasQry )->( DbGoTop() )

        // Loop de Processamento
        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)
            TAFInitArray( aAnalitico, nPosValores )

            // Carga de Dados
            aAnalitico[nPosValores][ANALITICO_FILIAL]       := (cAliasQry)->(FieldGet(nP_FILIAL))
            aAnalitico[nPosValores][ANALITICO_ID]           := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]       := cPeriodo
            aAnalitico[nPosValores][ANALITICO_CPF]          := cCpf
            aAnalitico[nPosValores][ANALITICO_NOME]         := cNome
            aAnalitico[nPosValores][ANALITICO_EVENTO]       := 'S-1210'
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]    := CVALTOCHAR(STRZERO(nSequen, 3))
            
            // Tratamento de Domínio (Tipo Inscrição)
            aAnalitico[nPosValores][ANALITICO_DETDEPTPINSC] := TAFTpInscr( (cAliasQry)->(FieldGet(nP_TPINSC)) )
            
            aAnalitico[nPosValores][ANALITICO_DETDEPNRINSC] := (cAliasQry)->(FieldGet(nP_NRINSC))
            aAnalitico[nPosValores][ANALITICO_DETDEPVLREMB] := (cAliasQry)->(FieldGet(nP_VLREMB))
            aAnalitico[nPosValores][ANALITICO_DETDEPVLRANT] := (cAliasQry)->(FieldGet(nP_VLRANT))
            aAnalitico[nPosValores][ANALITICO_FORABA]       := "DETDEP"
            aAnalitico[nPosValores][ANALITICO_ABA]          := "7C"
            aAnalitico[nPosValores][ANALITICO_PERREF]       := "" 
            aAnalitico[nPosValores][ANALITICO_ORIGEM]       := "1"
            aAnalitico[nPosValores][ANALITICO_VERSAO]       := (cAliasQry)->(FieldGet(nP_VERSAO))
            
            // Concatenação de Chave Relacional
            aAnalitico[nPosValores][ANALITICO_RELACAO]      := AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_CPFDEP)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_TPINSC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_NRINSC)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQUEN)))) + "|" + ;
                                                               AllTrim(cValToChar((cAliasQry)->(FieldGet(nP_SEQIRC))))

            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFNomeFun
@type           Function
@description    Função auxiliar otimizada para buscar o Nome do Trabalhador (C9V)
                baseada no CPF ou no ID, com contexto de Filial.
                Utilizada para evitar chamadas de banco repetitivas dentro de loops.
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cIdFunc     , Character , ID do Funcionário
@param          cCpf        , Character , CPF do Funcionário
@param          cFil        , Character , Filial

@return         cNome       , Character , Nome do trabalhador
/*/
//---------------------------------------------------------------------
Static Function TAFNomeFun( cIdFunc as Character, cCpf as Character, cFil as Character )

    // --------------------------------------------------------------------
    // Declaração de Variáveis
    // --------------------------------------------------------------------
    Local cNome     as Character
    Local cKeyCache as Character
    Local nTamFil   as Numeric
    Local nTamID    as Numeric
    Local nTamCPF   as Numeric
    Local cFilBusca as Character

    // --------------------------------------------------------------------
    // Inicialização dos parâmetros
    // --------------------------------------------------------------------
    Default cIdFunc := ""
    Default cCpf    := ""
    Default cFil    := "" 

    // --------------------------------------------------------------------
    // Inicialização
    // --------------------------------------------------------------------
    cNome     := ""
    cKeyCache := ""
    nTamFil   := TamSx3("C9V_FILIAL")[1]
    nTamID    := TamSx3("C9V_ID")[1]
    nTamCPF   := TamSx3("C9V_CPF")[1]

    // Inicializa Cache
    If hCacheC9V_Mod == Nil
        hCacheC9V_Mod := THashMap():New()
    EndIf

    // --------------------------------------------------------------------
    // LÓGICA DE FILIAL
    // --------------------------------------------------------------------
    // Se xFilial retornar algo, é exclusiva -> Usa a filial do parâmetro.
    // Se retornar vazio, é compartilhada -> Usa vazio.
    If !Empty(xFilial("C9V"))
        cFilBusca := cFil 
    Else
        cFilBusca := ""
    EndIf

    // ----------------------------------------------------------------
    // TENTATIVA 1: BUSCA POR ID 
    // ----------------------------------------------------------------
    If !Empty( cIdFunc )
        
        cKeyCache := cFilBusca + "|ID|" + cIdFunc

        If !hCacheC9V_Mod:Get( cKeyCache, @cNome )
            
            // Busca Exata no Banco (Sem + "1" para achar demitidos)
            cNome := AllTrim(Posicione("C9V", 2, PadR(cFilBusca, nTamFil) + PadR(cIdFunc, nTamID), "C9V_NOME"))
            
            // Grava no cache
            If !Empty(cNome)
                hCacheC9V_Mod:Set( cKeyCache, cNome )
                Return cNome // Se achou pelo ID, retorna e encerra. Seguro.
            EndIf
        EndIf
    EndIf

    // ----------------------------------------------------------------
    // TENTATIVA 2: BUSCA POR CPF
    // ----------------------------------------------------------------
    If !Empty( cCpf )
        
        cKeyCache := cFilBusca + "|CPF|" + cCpf

        If !hCacheC9V_Mod:Get( cKeyCache, @cNome )
            
            // Busca Exata no Banco
            cNome := AllTrim(Posicione("C9V", 3, PadR(cFilBusca, nTamFil) + PadR(cCpf, nTamCPF), "C9V_NOME"))

            // Grava no cache 
            If !Empty(cNome)
                hCacheC9V_Mod:Set( cKeyCache, cNome )
            EndIf
        EndIf
    EndIf

Return cNome

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFInitArray
@type           Function
@description    Inicializa uma linha do array analítico com tipagem estrita (String/Numeric).
                
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.1

@param          aAnalitico  , Array     , Array multidimensional de dados
@param          nPosValores , Numeric   , Índice da linha a ser inicializada

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFInitArray( aAnalitico as Array, nPosValores as Numeric )

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default aAnalitico  := {}
    Default nPosValores := 0

    //-------------------------------------------------------------------------
    // Validação de Limites de Array
    // Evita erro fatal "Array Access Out of Bounds" se o índice for inválido
    //-------------------------------------------------------------------------
    If nPosValores <= 0 .Or. nPosValores > Len(aAnalitico)
        Return
    EndIf

    //-------------------------------------------------------------------------
    // Bloco 01 a 09: Identificadores e Chaves (Strings)
    //-------------------------------------------------------------------------
    aAnalitico[nPosValores][01] := ""
    aAnalitico[nPosValores][02] := ""
    aAnalitico[nPosValores][03] := ""
    aAnalitico[nPosValores][04] := ""
    aAnalitico[nPosValores][05] := ""
    aAnalitico[nPosValores][06] := ""
    aAnalitico[nPosValores][07] := ""
    aAnalitico[nPosValores][08] := ""
    aAnalitico[nPosValores][09] := ""

    //-------------------------------------------------------------------------
    // Bloco 10 a 28: Valores Monetários Principais (Numéricos)
    //-------------------------------------------------------------------------
    aAnalitico[nPosValores][10] := 0
    aAnalitico[nPosValores][11] := 0
    aAnalitico[nPosValores][12] := 0
    aAnalitico[nPosValores][13] := 0
    aAnalitico[nPosValores][14] := 0
    aAnalitico[nPosValores][15] := 0
    aAnalitico[nPosValores][16] := 0
    aAnalitico[nPosValores][17] := 0
    aAnalitico[nPosValores][18] := 0
    aAnalitico[nPosValores][19] := 0
    aAnalitico[nPosValores][20] := 0
    aAnalitico[nPosValores][21] := 0
    aAnalitico[nPosValores][22] := 0
    aAnalitico[nPosValores][23] := 0
    aAnalitico[nPosValores][24] := 0
    aAnalitico[nPosValores][25] := 0
    aAnalitico[nPosValores][26] := 0
    aAnalitico[nPosValores][27] := 0
    aAnalitico[nPosValores][28] := 0

    //-------------------------------------------------------------------------
    // Bloco 29 a 44: Campos Mistos (Controle e Intermediários)
    //-------------------------------------------------------------------------
    aAnalitico[nPosValores][29] := ""
    aAnalitico[nPosValores][30] := ""
    aAnalitico[nPosValores][31] := 0
    aAnalitico[nPosValores][32] := ""
    aAnalitico[nPosValores][33] := ""
    aAnalitico[nPosValores][34] := 0
    aAnalitico[nPosValores][35] := ""
    aAnalitico[nPosValores][36] := ""
    aAnalitico[nPosValores][37] := 0
    aAnalitico[nPosValores][38] := 0
    aAnalitico[nPosValores][39] := 0
    aAnalitico[nPosValores][40] := 0
    aAnalitico[nPosValores][41] := ""
    aAnalitico[nPosValores][42] := ""
    aAnalitico[nPosValores][43] := ""
    aAnalitico[nPosValores][44] := ""

    //-------------------------------------------------------------------------
    // Bloco 45 a 49: Valores Complementares (Numéricos)
    //-------------------------------------------------------------------------
    aAnalitico[nPosValores][45] := 0
    aAnalitico[nPosValores][46] := 0
    aAnalitico[nPosValores][47] := 0
    aAnalitico[nPosValores][48] := 0
    aAnalitico[nPosValores][49] := 0

    //-------------------------------------------------------------------------
    // Bloco 50 a 60: Campos Intercalados (Mapeamento Específico)
    //-------------------------------------------------------------------------
    aAnalitico[nPosValores][50] := ""
    aAnalitico[nPosValores][51] := 0
    aAnalitico[nPosValores][52] := ""
    aAnalitico[nPosValores][53] := 0
    aAnalitico[nPosValores][54] := ""
    aAnalitico[nPosValores][55] := 0
    aAnalitico[nPosValores][56] := ""
    aAnalitico[nPosValores][57] := ""
    aAnalitico[nPosValores][58] := 0
    aAnalitico[nPosValores][59] := ""
    aAnalitico[nPosValores][60] := 0

    //-------------------------------------------------------------------------
    // Bloco 61 a 77: Finalizadores (Controles Finais e Totais)
    //-------------------------------------------------------------------------
    aAnalitico[nPosValores][61] := ""
    aAnalitico[nPosValores][62] := ""
    aAnalitico[nPosValores][63] := ""
    aAnalitico[nPosValores][64] := ""
    aAnalitico[nPosValores][65] := ""
    aAnalitico[nPosValores][66] := 0
    aAnalitico[nPosValores][67] := 0
    aAnalitico[nPosValores][68] := ""
    aAnalitico[nPosValores][69] := ""
    aAnalitico[nPosValores][70] := ""
    aAnalitico[nPosValores][71] := 0
    aAnalitico[nPosValores][72] := 0
    aAnalitico[nPosValores][73] := ""
    aAnalitico[nPosValores][74] := ""
    aAnalitico[nPosValores][75] := ""
    aAnalitico[nPosValores][76] := ""
    aAnalitico[nPosValores][77] := ""

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpRend
@type           Function
@description    Retorna a descrição do Tipo de Rendimento (IRRF).
                Realiza o mapeamento de códigos (11-18) para descrição textual.
                Caso não mapeado, retorna "79 - Rendimento isento...".

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTpRend     , Character , Código do Tipo de Rendimento

@return         cRetorno    , Character , Descrição formatada do rendimento
/*/
//---------------------------------------------------------------------
Function TAFTpRend( cTpRend as character )

    Local cRetorno as character

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTpRend := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cRetorno := ""

    //-------------------------------------------------------------------------
    // Mapeamento: Código -> Descrição do Rendimento
    //-------------------------------------------------------------------------
    Do Case
        
        Case cTpRend == "11"
            cRetorno := "11 - Remuneração mensal"

        Case cTpRend == "12"
            cRetorno := "12 - 13º salário"

        Case cTpRend == "13"
            cRetorno := "13 - Férias"

        Case cTpRend == "14"
            cRetorno := "14 - PLR"

        Case cTpRend == "18"
            cRetorno := "18 - RRA"

        // Regra Default
        Otherwise
            cRetorno := "79 - Rendimento isento ou não tributável"

    EndCase

Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpPrev
@type           Function
@description    Retorna a descrição do Tipo de Previdência Complementar.
                Realiza o mapeamento:
                1=Privada, 2=FAPI, Outros=Funpresp.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTpPrev     , Character , Código do Tipo de Previdência

@return         cRetorno    , Character , Descrição formatada da previdência
/*/
//---------------------------------------------------------------------
Function TAFTpPrev( cTpPrev as character )

    Local cRetorno as character

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTpPrev := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cRetorno := ""

    //-------------------------------------------------------------------------
    // Mapeamento: Código -> Descrição da Previdência
    //-------------------------------------------------------------------------
    Do Case
        
        Case cTpPrev == "1"
            cRetorno := "1 - Privada"

        Case cTpPrev == "2"
            cRetorno := "2 - FAPI"

        // Regra Default
        Otherwise
            cRetorno := "3 - Funpresp"

    EndCase

Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpProc
@type           Function
@description    Retorna a descrição do Tipo de Processo (Administrativo/Judicial).
                Realiza o mapeamento:
                1=Administrativo, Outros=Judicial.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTpProc     , Character , Código do Tipo de Processo

@return         cRetorno    , Character , Descrição formatada do processo
/*/
//---------------------------------------------------------------------
Function TAFTpProc( cTpProc as character )

    Local cRetorno as character

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTpProc := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cRetorno := ""

    //-------------------------------------------------------------------------
    // Mapeamento: Código -> Descrição do Processo
    //-------------------------------------------------------------------------
    If cTpProc == "1"
        cRetorno := "1 - Administrativo"
    Else
        cRetorno := "2 - Judicial"
    EndIf

Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpIndapu
@type           Function
@description    Retorna a descrição do Indicador de Apuração (Mensal/Anual).
                Realiza o mapeamento:
                1=Mensal, Outros=Anual (13º).

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTpIndapu   , Character , Código do Indicador de Apuração

@return         cRetorno    , Character , Descrição formatada da apuração
/*/
//---------------------------------------------------------------------
Function TAFTpIndapu( cTpIndapu as character )

    Local cRetorno as character

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTpIndapu := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cRetorno := ""

    //-------------------------------------------------------------------------
    // Mapeamento: Código -> Descrição da Apuração
    //-------------------------------------------------------------------------
    If cTpIndapu == "1"
        cRetorno := "1 - Mensal"
    Else
        cRetorno := "2 - Anual (13° salário)"
    EndIf

Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpDed
@type           Function
@description    Retorna a descrição do Tipo de Dedução (IRRF) baseado no código informado.
                Realiza o mapeamento para exibição em relatórios/interfaces.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTpEdu      , Character , Código do Tipo de Dedução ("1" a "5")

@return         cRetorno    , Character , Descrição formatada. 
                                          Caso não encontre (1-5), retorna "7 - Dependentes".
/*/
//---------------------------------------------------------------------
Function TAFTpDed( cTpEdu as character )

    Local cRetorno as character

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTpEdu := ""

     //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------     
    cRetorno := ""

    //-------------------------------------------------------------------------
    // Mapeamento: Código -> Descrição da Dedução
    //-------------------------------------------------------------------------
    Do Case
        
        Case cTpEdu == "1"
            cRetorno := "1 - Previdência oficial"

        Case cTpEdu == "2"
            cRetorno := "2 - Previdência privada"

        Case cTpEdu == "3"
            cRetorno := "3 - Fundo de Aposentadoria Programada Individual - FAPI"

        Case cTpEdu == "4"
            cRetorno := "4 - Fundação de Previdência Complementar do Servidor Público - Funpresp"

        Case cTpEdu == "5"
            cRetorno := "5 - Pensão alimentícia"

        // Qualquer outro código assume "Dependentes"
        Otherwise
            cRetorno := "7 - Dependentes"

    EndCase

Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFIndRee
@type           Function
@description    Retorna a descrição amigável do Indicador de Reembolso 
                de Plano de Saúde (eSocial/DIRF).
                Realiza o mapeamento:
                "1" -> Reembolso via operadora
                Outros -> Reembolso direto (Benefício)

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cIndRem     , Character , Código do indicador de reembolso ("1" ou "2")

@return         cRetorno    , Character , Descrição formatada do indicador.
/*/
//---------------------------------------------------------------------
Function TAFIndRee( cIndRem as character )

    Local cRetorno as character

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cIndRem := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------    
    cRetorno := ""

    //-------------------------------------------------------------------------
    // Definição da Descrição (De/Para)
    //-------------------------------------------------------------------------
    If cIndRem == "1"
        cRetorno := "1 - Reembolso efetuado pelo empregador no âmbito do plano de saúde (a operadora reembolsa o empregador)"
    Else
        // Qualquer valor diferente de "1" assume o fluxo do código "2"
        cRetorno := "2 - Reembolso efetuado pelo empregador como benefício do próprio empregador"
    EndIf

Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpInscr
@type           Function
@description    Formata a descrição do Tipo de Inscrição (CNPJ/CPF) para exibição em relatórios/interfaces.
                Realiza o mapeamento: 
                "1" -> "1 - CNPJ"
                Outros -> "2 - CPF"

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTpInscr    , Character , Código do Tipo de Inscrição ("1" ou "2")

@return         cRetorno    , Character , Descrição formatada (Ex: "1 - CNPJ")
/*/
//---------------------------------------------------------------------
Function TAFTpInscr( cTpInscr as character )

    Local cRetorno as character

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTpInscr := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cRetorno := ""

    //-------------------------------------------------------------------------
    // Definição da Descrição (De/Para)
    //-------------------------------------------------------------------------
    If cTpInscr == "1"
        cRetorno := "1 - CNPJ"
    Else
        // Qualquer valor diferente de "1" é tratado como Pessoa Física (CPF).
        cRetorno := "2 - CPF"
    EndIf

Return cRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFFil1200
@type           Function
@description    Itera sobre os registros processados na Query Auxiliar (V6M - S-1210) 
                e dispara a orquestração para carga das tabelas filhas (C91, CMD, T92).

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cAliasQry   , Character , Alias da query temporária contendo os dados do S-1210 (V6M)
@param          aInfos      , Array     , Dados contextuais do processamento [1]=Filial, [5]=Periodo, etc.
@param          aAnalitico  , Array     , Array de retorno para o relatório/processamento
@param          cPeriodo    , Character , Período de apuração (Sobrescrito por aInfos[5] na lógica interna)

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFFil1200( cAliasQry as character, aInfos as Array, aAnalitico as Array, cPeriodo as character )

    Local cEvento       as character
    Local cPerRef       as character
    Local cTable        as character
    Local cDmDev        as character
    Local cPaisExt      as character
    Local nSequen       as numeric

    //-------------------------------------------------------------------------
    // Variáveis de Cache de Posição de Posição
    //------------------------------------------------------------------------- 
    Local nP_TPPGTO     as numeric
    Local nP_PERREF     as numeric
    Local nP_PAIEXT     as numeric
    Local nP_INDDEV     as numeric

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cAliasQry   := ""
    Default aInfos      := {}
    Default aAnalitico  := {}
    Default cPeriodo    := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cEvento     := ""
    cPerRef     := ""
    cTable      := ""
    cDmDev      := ""
    cPaisExt    := ""
    nSequen     := 0

    // Verifica se o Alias existe e tem dados
    If Select( cAliasQry ) > 0

        //---------------------------------------------------------------------
        // Mapeamento de Campos (Fora do Loop)
        // Evita o uso de Macro (&) repetitiva, reduzindo uso de CPU.
        //---------------------------------------------------------------------
        nP_TPPGTO := (cAliasQry)->(FieldPos("V6M_TPPGTO"))
        nP_PERREF := (cAliasQry)->(FieldPos("V6M_PERREF"))
        nP_PAIEXT := (cAliasQry)->(FieldPos("V6M_PAIEXT"))
        nP_INDDEV := (cAliasQry)->(FieldPos("V6M_INDDEV"))

        ( cAliasQry )->( DbGoTop() )

        //---------------------------------------------------------------------
        // Loop de Processamento
        //---------------------------------------------------------------------
        While !(cAliasQry)->(EoF())
            
            // Leitura dos dados via FieldGet (Rápido) e Resolução de Domínios
            cEvento   := TAFTpEven( (cAliasQry)->(FieldGet(nP_TPPGTO)) )
            cPerRef   := (cAliasQry)->(FieldGet(nP_PERREF))
            cPaisExt  := (cAliasQry)->(FieldGet(nP_PAIEXT))
            cDmDev    := (cAliasQry)->(FieldGet(nP_INDDEV))
            
            // Definição da Tabela Principal baseada no Evento
            cTable    := TAFDefTable( cEvento )
            
            // Definição do Período (Prioridade para o array de infos - Regra Original Mantida)
            cPeriodo  := aInfos[5]

            // Chamada da Função Orquestradora (Dispatcher)
            // Passagem de nSequen e aAnalitico por referência (@) é crucial e foi mantida
            TAFMainFil(cTable, cPerRef, aInfos, @aAnalitico, cPaisExt, cEvento, cPeriodo, @nSequen, cDmDev )
        
            (cAliasQry)->(DbSkip())

        EndDo

    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFTpEven
@type           Function
@description    Converte o código interno de seleção do processamento para 
                o ID oficial do Evento eSocial.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTpEven     , Character , Código interno do tipo de evento:
                                          "1" = S-1200 (Remuneração)
                                          "2" = S-2299 (Desligamento)
                                          "3" = S-2399 (Término TSVE)

@return         cEvento     , Character , ID do Evento (Ex: "S-1200")
/*/
//---------------------------------------------------------------------
Function TAFTpEven( cTpEven as character )

    Local cEvento as character

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTpEven := ""

     //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------   
    cEvento := ""

    //-------------------------------------------------------------------------
    // Mapeamento: Código Interno -> Evento eSocial
    //-------------------------------------------------------------------------
    Do Case
        
        // Remuneração de Trabalhador
        Case cTpEven == "1"
            cEvento := "S-1200"

        // Desligamento
        Case cTpEven == "2"
            cEvento := "S-2299"

        // Término de Trabalhador Sem Vínculo
        Case cTpEven == "3"
            cEvento := "S-2399"
            
        // Case Other: Retorna "" (vazio)

    EndCase

Return cEvento

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDefTable
@type           Function
@description    Retorna o Alias da tabela principal correspondente ao Evento do eSocial.
                Utilizada para definir o fluxo de processamento (Dispatcher).

@author         Alexandre de Lima Santos / Denis R. de Oliveira 
@since          28/10/2025
@version        1.0

@param          cEvento     , Character , Código do evento (Ex: "S-1200", "S-2299")

@return         cTable      , Character , Alias da tabela principal (Ex: "C91", "CMD") 
/*/
//---------------------------------------------------------------------
Function TAFDefTable( cEvento as character )

    Local cTable as character

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cEvento := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cTable := ""

    //-------------------------------------------------------------------------
    // Mapeamento: Evento eSocial -> Tabela TAF (Alias)
    //-------------------------------------------------------------------------
    Do Case
        
        // S-1200: Remuneração de Trabalhador
        // S-1202: Remuneração de Servidor (RPPS)
        Case cEvento $ "S-1200|S-1202"
            cTable := "C91"

        // S-2299: Desligamento
        Case cEvento == "S-2299"
            cTable := "CMD"

        // S-2399: Término de Trabalhador Sem Vínculo (TSVE)
        Case cEvento == "S-2399"
            cTable := "T92"
            
        // Case Other: Retorna vazio (cTable inicializado como "")

    EndCase

Return cTable

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFMainFil
@type           Function
@description    Função Orquestradora (Dispatcher).
                Responsável por direcionar o processamento para as rotinas específicas 
                (Periódicas ou Anteriores) com base na tabela origem (Evento).

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTable      , Character , Tabela principal que define o fluxo (C91, CMD, T92)
@param          cPerRef     , Character , Período de referência
@param          aInfos      , Array     , Dados contextuais do registro pai
@param          aAnalitico  , Array     , Array de retorno
@param          cPaisExt    , Character , Código do país
@param          cEvento     , Character , Tipo do evento
@param          cPeriodo    , Character , Período de apuração
@param          nSequen     , Numeric   , Sequencial numérico
@param          cDmDev      , Character , ID do Demonstrativo

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFMainFil( cTable as character, cPerRef as character, aInfos as Array, aAnalitico as Array, cPaisExt as character, cEvento as character, cPeriodo as character, nSequen as numeric, cDmDev as character )

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTable      := ""
    Default cPerRef     := ""
    Default aInfos      := {}
    Default aAnalitico  := {}
    Default cPaisExt    := ""
    Default cEvento     := ""
    Default cPeriodo    := ""
    Default nSequen     := 0
    Default cDmDev      := ""   

    //-------------------------------------------------------------------------
    // Estrutura de Decisão
    // Direciona para as funções de carga baseada na tabela origem do evento
    //-------------------------------------------------------------------------
    Do Case
        
        // C91: Remuneração (S-1200)
        Case cTable == "C91"
            // Processa Período Atual
            TAFPer1200( cTable, cPerRef, aInfos, @aAnalitico, cPaisExt, cEvento, cPeriodo, @nSequen, cDmDev )
            // Processa Períodos Anteriores/Complementares
            TAFAnt1200( cTable, cPerRef, aInfos, @aAnalitico, cPaisExt, cEvento, cPeriodo, @nSequen, cDmDev )
    
        // CMD: Desligamento (S-2299)
        Case cTable == "CMD"
            // Processa Período Atual
            TAFPer2299( cTable, cPerRef, aInfos, @aAnalitico, cPaisExt, cEvento, cPeriodo, @nSequen, cDmDev )
            // Processa Anteriores
            TAFAnt2299( cTable, cPerRef, aInfos, @aAnalitico, cPaisExt, cEvento, cPeriodo, @nSequen, cDmDev )
    
        // T92: Término de TSVE (S-2399)
        Case cTable == "T92"
            // Processa Período Atual
            TAFPer2399( cTable, cPerRef, aInfos, @aAnalitico, cPaisExt, cEvento, cPeriodo, @nSequen, cDmDev )
    
    EndCase

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TafMainLoad
@type           Function
@description    Carrega os dados de rendimentos no array analítico com alta performance.
                Utiliza Caches Estáticos (Memória) para evitar I/O repetitivo no banco.
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cCateg      , Character , Categoria do trabalhador (Origem)
@param          indRRA      , Character , Indicador de RRA
@param          cCodRubr    , Character , Código da Rubrica
@param          cIndApIR    , Character , Indicador de Apuração de IR
@param          nValor      , Numeric   , Valor do Rendimento
@param          aAnalitico  , Array     , Array de ponteiro para output
@param          cPaisExt    , Character , País Exterior
@param          cEvento     , Character , Tipo do Evento (S-1200, S-2299, etc)
@param          cPeriodo    , Character , Período de Apuração
@param          cPer1210    , Character , Período S-1210 
@param          cIdFunc     , Character , ID do Funcionário (TAF)
@param          cBenef      , Character , ID do Beneficiário
@param          cTipoEve    , Character , Tipo do Evento Detalhado
@param          cPerRef     , Character , Período de Referência
@param          nSequen     , Numeric   , Sequencial do registro no array
@param          cVersao     , Character , Versão do Layout
@param          cCpf        , Character , CPF do Beneficiário
@param          cMv         , Character , Indicador de Múltiplos Vínculos ("MV" ou vazio)
@param          cFilialReg  , Character , Filial do registro de origem

@return         Nil
/*/
//---------------------------------------------------------------------
Function TafMainLoad( cCateg as character, indRRA as character, cCodRubr as character, cIndApIR as character, nValor as Numeric , aAnalitico as Array, cPaisExt as character,;
                      cEvento as character, cPeriodo as character, cPer1210 as character, cIdFunc as character, cBenef as character, cTipoEve as character, cPerRef as character,;
                      nSequen as numeric, cVersao as character , cCpf as character, cMv as character, cFilialReg as character ) 

    Local nPosValores       as numeric
    Local cClasTri          as character
    Local cC8RIr            as character
    Local cCodC8D           as character
    Local cTpIR             as character
    Local cCodRec           as character
    Local cCategRes         as character    // Categoria resolvida (resultado do cache)
    Local cCpfRes           as character    // CPF resolvido
    Local cNomeRes          as character    // Nome resolvido
    Local cKeyCache         as character    // Chave única para HashMaps

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cCateg      := ""
    Default indRRA      := ""
    Default cCodRubr    := ""
    Default cIndApIR    := ""
    Default nValor      := 0
    Default aAnalitico  := {}
    Default cPaisExt    := ""
    Default cEvento     := ""
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
    Default cFilialReg  := xFilial("C9V")
  
    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    nPosValores := 0
    cClasTri    := ""
    cC8RIr      := ""
    cCodC8D     := ""
    cTpIR       := ""
    cCodRec     := ""
    cCategRes   := ""
    cCpfRes     := ""
    cNomeRes    := ""
    cKeyCache   := ""

    //-------------------------------------------------------------------------
    // Inicialização dos Caches (apenas na primeira execução)
    //-------------------------------------------------------------------------
    If hCacheC87_Mod == Nil
        hCacheC87_Mod := THashMap():New()
    EndIf

    If hCacheC8R_Mod == Nil
        hCacheC8R_Mod := THashMap():New()
    EndIf

    If hCacheC8U_Mod == Nil
        hCacheC8U_Mod := THashMap():New()
    EndIf

    If hCacheC9V_Mod == Nil
        hCacheC9V_Mod := THashMap():New()
    EndIf

    If hClasTri_Cache_Mod == Nil
        hClasTri_Cache_Mod := THashMap():New()
    EndIf

    If hCacheC6R_Mod == Nil
        hCacheC6R_Mod := THashMap():New()
    EndIf

    //-------------------------------------------------------------------------
    // Incrementa sequência e prepara array
    //-------------------------------------------------------------------------
    nSequen++

    // Adiciona nova linha ao array principal
    aAdd(aAnalitico, Array(77))
    nPosValores := Len(aAnalitico)

    // Inicializa a linha com valores vazios/zeros para evitar sujeira de memória
    TAFInitArray( aAnalitico, nPosValores )

    //=========================================================================
    // BLOCO 1: RESOLUÇÃO DE CATEGORIA (COM CACHE)
    // A categoria do trabalhador não muda durante o processamento do mesmo
    //=========================================================================
    If !cEvento $ "S-2299|S-2399"
        // --------------------------------------------------------------------
        // CENÁRIO A: Eventos Periódicos (S-1200/S-1202)
        // Regra: A origem da categoria depende do tipo de evento (S-1200 vs Desligamento)
        // --------------------------------------------------------------------
        cKeyCache := cFilialReg + "|S1200|" + cCateg

        //---------------------------------------------------------------------
        // Evento S-1200/S-1202: Busca categoria direta
        //---------------------------------------------------------------------
        If !hCacheC87_Mod:Get( cKeyCache, @cCategRes ) 
            cCategRes := AllTrim( Posicione("C87", 1, xFilial("C87", cFilialReg) + cCateg , "C87_CODIGO") )
            hCacheC87_Mod:Set( cKeyCache, cCategRes )
        EndIf

    ElseIf cEvento == "S-2399"
        // --------------------------------------------------------------------
        // CENÁRIO B: Término (S-2399)
        // Busca categoria no cadastro de trabalhadores sem vínculo (C9V/C87).
        // --------------------------------------------------------------------
        cKeyCache := cFilialReg + "|S2399|" + cBenef
        
        If !hCacheC87_Mod:Get( cKeyCache, @cCategRes )
            // Busca intermediária no C9V
            cCategRes := AllTrim( Posicione("C9V", 16, xFilial("C9V", cFilialReg) + cBenef + "S2300" + "1", "C9V_CATCI") )
            // Busca final no C87
            cCategRes := AllTrim( Posicione("C87", 1, xFilial("C87", cFilialReg) + cCategRes , "C87_CODIGO") )
            
            hCacheC87_Mod:Set( cKeyCache, cCategRes )
        EndIf

    Else
        // --------------------------------------------------------------------
        // CENÁRIO C: Desligamento (S-2299)
        // Busca categoria no cadastro de vínculos (CUP/C87).
        // --------------------------------------------------------------------
        cKeyCache := cFilialReg + "|S2299|" + cBenef
        
        If !hCacheC87_Mod:Get( cKeyCache, @cCategRes )
            // Busca intermediária no CUP (Vínculos)
            cCategRes := AllTrim( Posicione("CUP", 1, xFilial("CUP", cFilialReg) + cBenef + "S2300", "CUP_CODCAT") )
            // Busca final no C87
            cCategRes := AllTrim( Posicione("C87", 1, xFilial("C87", cFilialReg) + cCategRes , "C87_CODIGO") )
            
            hCacheC87_Mod:Set( cKeyCache, cCategRes )
        EndIf

    EndIf

    // Atualiza a variável local para uso posterior na função
    cCateg := cCategRes

    //=========================================================================
    // BLOCO 2: CLASSIFICAÇÃO TRIBUTÁRIA DA EMPRESA (C1E)
    // Regra: Dado único por empresa/filial matriz.
    // Carregado apenas uma vez se a variável estiver vazia.
    //=========================================================================
    If !hClasTri_Cache_Mod:Get( cFilialReg, @cClasTri )
        
        // 1. Busca ID da Classificação na tabela da Empresa (C1E)
        cClasTri := AllTrim( Posicione("C1E", 3, xFilial("C1E", cFilialReg) + cFilialReg + "1", "C1E_CLAFIS") )
        
        // Busca segura na C8D (Tenta filial específica, se falhar, tenta compartilhada)
        cCodC8D := AllTrim( Posicione("C8D", 1, xFilial("C8D", cFilialReg) + cClasTri, "C8D_CODIGO") )
        
        If Empty(cCodC8D) .And. xFilial("C8D", cFilialReg) != xFilial("C8D")
            cCodC8D := AllTrim( Posicione("C8D", 1, xFilial("C8D") + cClasTri, "C8D_CODIGO") )
        EndIf
        
        cClasTri := cCodC8D
        
        // Salva no cache
        hClasTri_Cache_Mod:Set( cFilialReg, cClasTri )
        
    EndIf
    
    //=========================================================================
    // BLOCO 3: RESOLUÇÃO DE RUBRICA E TIPO IR (C8R -> C8U)
    // Regra: O código de IR depende da rubrica.
    //=========================================================================
    
    // Define chave de cache: Filial + Modo MV + Código Rubrica
    cKeyCache := cFilialReg + "|" + IIf(cMv == "MV", "MV", "NM") + "|" + cCodRubr

    If !hCacheC8R_Mod:Get( cKeyCache, @cC8RIr )
        
        If cMv == "MV"
            // Modo Múltiplos Vínculos: Busca pelo ID (Índice 3) depois recupera CINTIR
            cC8RIr := AllTrim( Posicione("C8R", 3, xFilial("C8R", cFilialReg) + cCodRubr + "1", "C8R_ID") )
            // Busca o código interno de tributação (CINTIR)
            cC8RIr := AllTrim( Posicione("C8R", 5, xFilial("C8R", cFilialReg) + cC8RIr + "1", "C8R_CINTIR") )
        Else
            // Modo Normal: Busca direta pelo índice 5
            // Tentativa 1: Busca na filial específica do movimento (cFilialReg)
            cC8RIr := AllTrim( Posicione("C8R", 5, xFilial("C8R", cFilialReg) + cCodRubr + "1", "C8R_CINTIR") )
            
            // Tentativa 2:
            // Se não encontrou E a filial do registro for diferente da filial corrente/padrão,
            // tenta buscar na tabela compartilhada (xFilial sem parâmetros ou filial vazia).
            If Empty(cC8RIr) .And. xFilial("C8R", cFilialReg) != xFilial("C8R")
                 cC8RIr := AllTrim( Posicione("C8R", 5, xFilial("C8R") + cCodRubr + "1", "C8R_CINTIR") )
            EndIf
        EndIf
        
        hCacheC8R_Mod:Set( cKeyCache, cC8RIr )
    EndIf

    // Busca o Código do Tipo de IR (Tabela C8U)
    // Usa cC8RIr como chave. Filial geralmente irrelevante para tabela compartilhada C8U, 
    // mas usa-se cFilialReg por consistência se for exclusiva.
    cKeyCache := cFilialReg + "|" + cC8RIr
    
    If !hCacheC8U_Mod:Get( cKeyCache, @cTpIR )
        cTpIR := AllTrim( Posicione("C8U", 1, xFilial("C8U", cFilialReg) + cC8RIr, "C8U_CODIGO") )
        hCacheC8U_Mod:Set( cKeyCache, cTpIR )
    EndIf

    cCodRec := "" // Será preenchido por referência dentro de TAFVlrRend se aplicável

    //=========================================================================
    // BLOCO 4: DADOS DO BENEFICIÁRIO (CPF/NOME) - C9V
    // Regra: Se não tiver CPF, busca pelo ID. Se tiver CPF, busca Nome.
    //=========================================================================
    
    If Empty(cCpf)
        // --------------------------------------------------------------------
        // Busca CPF pelo ID do Beneficiário
        // --------------------------------------------------------------------
        cKeyCache := cFilialReg + "|CPF|" + cBenef
        
        If !hCacheC9V_Mod:Get( cKeyCache, @cCpfRes )
            cCpfRes := AllTrim( Posicione("C9V", 2, xFilial("C9V", cFilialReg) + PadR(cBenef, TamSx3("C9V_ID")[1]) + "1", "C9V_CPF") )
            hCacheC9V_Mod:Set( cKeyCache, cCpfRes )
        EndIf
        cCpf := cCpfRes

        // Busca Nome pelo ID
        cKeyCache := cFilialReg + "|NOME|ID|" + cBenef
        
        If !hCacheC9V_Mod:Get( cKeyCache, @cNomeRes )
            cNomeRes := AllTrim( Posicione("C9V", 2, xFilial("C9V", cFilialReg) + PadR(cBenef, TamSx3("C9V_ID")[1]) + "1", "C9V_NOME") )
            hCacheC9V_Mod:Set( cKeyCache, cNomeRes )
        EndIf
    Else
        // --------------------------------------------------------------------
        // Busca Nome pelo CPF 
        // --------------------------------------------------------------------
        cKeyCache := cFilialReg + "|NOME|CPF|" + cCpf
        
        If !hCacheC9V_Mod:Get( cKeyCache, @cNomeRes )
            cNomeRes := AllTrim( Posicione("C9V", 3, xFilial("C9V", cFilialReg) + PadR(cCpf, TamSx3("C9V_CPF")[1]) + "1", "C9V_NOME") )
            hCacheC9V_Mod:Set( cKeyCache, cNomeRes )
        EndIf
    EndIf

    //=========================================================================
    // BLOCO 5: POPULAÇÃO DO ARRAY ANALÍTICO
    // Transfere os dados resolvidos para a estrutura de memória.
    //=========================================================================
    aAnalitico[nPosValores][ANALITICO_FILIAL]           := cFilialReg 
    aAnalitico[nPosValores][ANALITICO_ID]               := cIdFunc
    aAnalitico[nPosValores][ANALITICO_PERAPU]           := cPeriodo
    aAnalitico[nPosValores][ANALITICO_CPF]              := cCpf
    aAnalitico[nPosValores][ANALITICO_NOME]             := cNomeRes
    aAnalitico[nPosValores][ANALITICO_EVENTO]           := cEvento
    aAnalitico[nPosValores][ANALITICO_SEQUENCIA]        := CVALTOCHAR(STRZERO(nSequen, 3))
    
    // ------------------------------------------------------------------------
    // Cálculo de Valores por Tipo de Rendimento (TAFVlrRend)
    // A função TAFVlrRend contém a regra de negócio tributária
    // para decidir em qual coluna o valor deve cair baseado no Tipo de IR (cTpIR).
    // ------------------------------------------------------------------------
    aAnalitico[nPosValores][ANALITICO_VLRRENDTRIB]      := Iif( cTpIR $ "11|12|14", TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRRENDTRIB13]    := Iif( cTpIR == "12",      TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRPREVOFICIAL]   := Iif( cTpIR $ "41|42",    TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRPREVOFICIAL13] := Iif( cTpIR == "41",      TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRCRMEN]         := Iif( cTpIR $ "31|32|34", TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRCRMEN13]       := Iif( cTpIR == "32",      TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRPARC65]        := Iif( cTpIR $ "70|71",    TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRPARC65DEC]     := Iif( cTpIR == "71",      TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRDIARIAS]       := Iif( cTpIR == "72",      TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRAJDCUSTO]      := Iif( cTpIR == "73",      TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRINDRESCTR]     := Iif( cTpIR == "74",      TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRABONOPEC]      := Iif( cTpIR == "75",      TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRRENMOLGRV]     := Iif( cTpIR $ "76|77",    TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRRENMOLGRV13]   := Iif( cTpIR == "77",      TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRAUXMOR]        := Iif( cTpIR == "700",     TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRBOLMEDIC]      := Iif( cTpIR == "702",     TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRBOLMEDIC13]    := Iif( cTpIR == "703",     TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRJUROSMORA]     := Iif( cTpIR == "704",     TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    aAnalitico[nPosValores][ANALITICO_VLRINSEOUTROS]    := Iif( cTpIR == "79",      TAFVlrRend(indRRA, cClasTri, cPaisExt, cTpIR, cIndApIR, nValor, cCateg, cEvento, @cCodRec ), 0 )
    
    aAnalitico[nPosValores][ANALITICO_CODRECEITA]       := cCodRec      
    aAnalitico[nPosValores][ANALITICO_FORABA]           := "TRIBUT"
    aAnalitico[nPosValores][ANALITICO_ABA]              := "01" //Aba de tributos
    aAnalitico[nPosValores][ANALITICO_PERREF]           := cPerRef
    aAnalitico[nPosValores][ANALITICO_ORIGEM]           := "1"
    aAnalitico[nPosValores][ANALITICO_VERSAO]           := cVersao

    // Limpa variável auxiliar para evitar propagação indevida
    cCodRec := ""

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TafClearCache
@type           Function
@description    Executa a limpeza integral dos caches de memória (HashMaps Estáticos) utilizados pelo módulo.
                Esta função atua como um Garbage Collector manual, garantindo:
                1. A liberação de recursos do servidor (FreeObj) após o processamento;
                2. A integridade dos dados, evitando que resíduos de uma execução anterior contaminem a atual.
                
                Deve ser invocada obrigatoriamente no INÍCIO (Setup) e no FIM (Teardown) da rotina principal.

@return         Nil, A função não possui retorno.

@author         Denis R. de Oliveira
@since          10/01/2026
@version        1.0
@see            TAFColDirf, TafMainLoad
/*/
//---------------------------------------------------------------------
Function TafClearCache()

    //-------------------------------------------------------------------------
    // Limpa e destrói cada cache se existir (Usa variáveis de escopo de arquivo)
    //-------------------------------------------------------------------------
    If hCacheC87_Mod != Nil
        HMClean( hCacheC87_Mod )
        FreeObj( hCacheC87_Mod )
        hCacheC87_Mod := Nil
    EndIf

    If hCacheC8R_Mod != Nil
        HMClean( hCacheC8R_Mod )
        FreeObj( hCacheC8R_Mod )
        hCacheC8R_Mod := Nil
    EndIf

    If hCacheC8U_Mod != Nil
        HMClean( hCacheC8U_Mod )
        FreeObj( hCacheC8U_Mod )
        hCacheC8U_Mod := Nil
    EndIf

    If hCacheC9V_Mod != Nil
        HMClean( hCacheC9V_Mod )
        FreeObj( hCacheC9V_Mod )
        hCacheC9V_Mod := Nil
    EndIf

    If hClasTri_Cache_Mod != Nil
        HMClean( hClasTri_Cache_Mod )
        FreeObj( hClasTri_Cache_Mod )
        hClasTri_Cache_Mod := Nil
    EndIf

    If hCacheC6R_Mod != Nil
        HMClean( hCacheC6R_Mod )
        FreeObj( hCacheC6R_Mod )
        hCacheC6R_Mod := Nil
    EndIf

    TafConOut( "[TafClearCache] Caches de módulo liberados." )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFVlrRend
@type           Function
@description    Valida se um rendimento deve ser considerado para um Código de Receita (DIRF/eSocial)
                baseado nas regras tributárias, categoria, país e indicadores de IR.
                Se a regra for atendida, preenche o Código de Receita (por referência) e retorna o valor.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          indRRA      , Character , Indicador de Rendimentos Recebidos Acumuladamente
@param          cClasTri    , Character , Classificação Tributária da Empresa
@param          cPaisExt    , Character , Código do País no Exterior
@param          cTpIR       , Character , Tipo de IR (Tabela C8U)
@param          cIndApIR    , Character , Indicador de Apuração de IR
@param          nValor      , Numeric   , Valor do Rendimento
@param          cCateg      , Character , Categoria do Trabalhador
@param          cEvento     , Character , Evento eSocial (S-1200, S-2299, etc.)
@param          cCrmen      , Character , Variável que receberá o Código da Receita acumulado

@return         Numeric     , Retorna nValor se aplicável, ou 0 se não.
/*/
//---------------------------------------------------------------------
Function TAFVlrRend( indRRA as character, cClasTri as character, cPaisExt as character, cTpIR as character, cIndApIR as character, nValor as numeric, cCateg as character, cEvento as character, cCrmen as character )

    Local lIsRRA     as logical
    Local lIsExt     as logical
    Local lIndApZero as logical
    Local lEntidEd   as logical

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default indRRA   := ""
    Default cClasTri := ""
    Default cPaisExt := ""
    Default cTpIR    := ""
    Default cIndApIR := ""
    Default nValor   := 0
    Default cCateg   := ""
    Default cEvento  := ""
    Default cCrmen   := "" // Passado por Referência (@) pelo chamador

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    lIsRRA     := !Empty(indRRA) .And. indRRA == '1'
    lIsExt     := !Empty(cPaisExt)
    lIndApZero := cIndApIR == '0'
    lEntidEd   := !Empty(cClasTri) .And. (cClasTri == '22' .Or. cClasTri == '80') // Entidade Educativa/Beneficente

    // Se o valor do rendimento for zero, aborta processamento imediatamente
    If nValor == 0
        Return 0
    EndIf

    //-------------------------------------------------------------------------
    // REGRA 1: Trabalhadores Gerais (Assalariados, Agentes Públicos, etc.)
    // Eventos: Periódicos e Desligamentos
    //-------------------------------------------------------------------------
    If cCateg $ '|101|102|103|105|106|107|108|111|301|302|303|304|305|306|307|308|309|310|311|312|313|314|401|410|501|721|722|723|761|901|902|903|904|906|'
        
        If lIndApZero .And. cEvento $ "S-1200|S-1202|S-2299|S-2399" .And. !lIsRRA .And. !lIsExt
            
            // Regra A: Empresa Normal (Não é Entidade Educativa)
            If !Empty(cClasTri) .And. !lEntidEd
                If ("|" + AllTrim(cTpIR) + "|") $ '|11|12|31|32|41|42|72|73|74|75|700|702|703|79|'
                    If !("056107" $ cCrmen)
                        cCrmen += '056107|'
                    EndIf
                EndIf
            EndIf    

            // Regra B: Entidade Educativa (ClassTri 22)
            If lEntidEd
                If ("|" + AllTrim(cTpIR) + "|") $ '|11|31|41|72|73|74|75|700|79|'
                    If !("056111" $ cCrmen)
                        cCrmen += '056111|'
                    EndIf
                EndIf
            EndIf
        
        EndIf
    
    EndIf

    //-------------------------------------------------------------------------
    // REGRA 2: Doméstico (104)
    //-------------------------------------------------------------------------
    If cCateg == '104' .And. lIndApZero
        
        If !lIsRRA .And. !lIsExt
            If ("|" + AllTrim(cTpIR) + "|") $ '|11|31|41|72|73|74|75|700|79|'
                If !("056108" $ cCrmen)
                    cCrmen += '056108|'
                EndIf
            EndIf
        EndIf

        // Regra Específica: 13º Salário / Férias (TpIR 12, 32, 42)
        If !lIsRRA .And. !lIsExt
            If cEvento == "S-2299" // Desligamento
                If ("|" + AllTrim(cTpIR) + "|") $ '|12|32|42|'
                    If !("056109" $ cCrmen)
                        cCrmen += '056109|'
                    EndIf
                EndIf
            Else // Periódico
                If ("|" + AllTrim(cTpIR) + "|") $ '|12|32|42|'
                    If !("056110" $ cCrmen)
                        cCrmen += '056110|'
                    EndIf
                EndIf
            EndIf
        
        EndIf
    
    EndIf

    //-------------------------------------------------------------------------
    // REGRA 3: Contribuintes Individuais / Diretores / Autônomos
    //-------------------------------------------------------------------------
    If cCateg $ '|201|202|701|711|712|731|734|738|741|751|771|781|' .And. lIndApZero
        If !lIsRRA .And. !lIsExt
            If ("|" + AllTrim(cTpIR) + "|") $ '|11|12|31|32|41|42|72|73|74|75|700|79|'
                If !("058806" $ cCrmen)
                    cCrmen += '058806|'
                EndIf
            EndIf
        EndIf
    EndIf

    //-------------------------------------------------------------------------
    // REGRA 4: Transportador Autônomo (Exterior)
    //-------------------------------------------------------------------------
    If cCateg == '712' .And. lIndApZero
        If cPaisExt == '586' // Paraguai
            If ("|" + AllTrim(cTpIR) + "|") $ '|11|31|41|'
                If !("061001" $ cCrmen)
                    cCrmen += '061001|'
                EndIf
            EndIf
        EndIf
    EndIf

    //-------------------------------------------------------------------------
    // REGRA 5: Empregados - Regra Específica Entidade Educativa (13º Salário)
    //-------------------------------------------------------------------------
    If cCateg $ '|101|102|103|105|106|107|108|111|'
        
        If lIndApZero .And. !lIsRRA .And. !lIsExt .And. lEntidEd
            
            // Periódico (Não Desligamento)
            If !cEvento $ "S-2299|S-2399"
                If ("|" + AllTrim(cTpIR) + "|") $ '|12|32|42|'
                    If !("056112" $ cCrmen)
                        cCrmen += '056112|'
                    EndIf
                EndIf
            EndIf

            // Desligamento
            If cEvento $ "S-2299|S-2399"
                If ("|" + AllTrim(cTpIR) + "|") $ '|12|32|42|'
                    If !("056113" $ cCrmen)
                        cCrmen += '056113|'
                    EndIf
                EndIf
            EndIf
        
        EndIf
    
    EndIf

    //-------------------------------------------------------------------------
    // REGRA 6: Categoria Grupo 1 (Empregados) - Rendimentos Isentos Específicos
    //-------------------------------------------------------------------------
    If SubStr(cCateg, 1, 1) == '1' .And. lIndApZero
        If !lIsRRA .And. !lIsExt
            If ("|" + AllTrim(cTpIR) + "|") $ '|14|34|'
                If !("356201" $ cCrmen)
                    cCrmen += '356201|'
                EndIf
            EndIf
        EndIf
    EndIf

    //-------------------------------------------------------------------------
    // REGRA 7: Rendimentos RRA (Recebidos Acumuladamente)
    //-------------------------------------------------------------------------
    If !lIsExt .And. lIndApZero .And. lIsRRA
        If ("|" + AllTrim(cTpIR) + "|") $ '|31|32|34|41|42|70|71|704|'
            If !("188901" $ cCrmen)
                cCrmen += '188901|'
            EndIf
        EndIf
    EndIf
        
Return Iif( !Empty(cCrmen), nValor, 0 )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFPer1200
@type           Function
@description    Processa os registros do evento S-1200 (Remuneração de Trabalhador).
                Realiza a leitura hierárquica da estrutura:
                C91 (Pai) -> T14 -> C9K -> C9L -> [C9M].
                Possui lógica de bifurcação para tratar Vínculos Normais vs Múltiplos Vínculos.

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTable      , Character , Tabela principal (Referência apenas)
@param          cPerRef     , Character , Período de referência (AAAAMM)
@param          aInfos      , Array     , Dados do registro pai: [1]=Filial, [2]=ID, [4]=CPF, etc.
@param          aAnalitico  , Array     , Array de retorno (Passagem por referência)
@param          cPaisExt    , Character , Código do país no exterior (se aplicável)
@param          cEvento     , Character , Tipo do evento (Ex: "S-1200")
@param          cPeriodo    , Character , Período de apuração completo
@param          nSequen     , Numeric   , Controle sequencial do array analítico
@param          cDmDev      , Character , Identificador do Demonstrativo (IDEDMD)

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFPer1200( cTable as character, cPerRef as character, aInfos as Array, aAnalitico as Array, cPaisExt as character, cEvento as character, cPeriodo as character, nSequen as numeric, cDmDev as character )

    Local cQuery    as character
    Local cAliasQry as character
    Local cCateg    as character 
    Local indRRA    as character
    Local cCodRubr  as character
    Local cIndApIR  as character
    Local nValor    as numeric

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTable     := ""
    Default cPerRef    := ""
    Default aInfos     := {}
    Default aAnalitico := {}
    Default cPaisExt   := ""
    Default cEvento    := ""
    Default cPeriodo   := ""
    Default cDmDev     := ""
    Default nSequen    := 0
    
    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cQuery    := ""
    cAliasQry := GetNextAlias()
    cCateg    := "" 
    indRRA    := ""
    cCodRubr  := ""
    cIndApIR  := ""
    nValor    := 0

    //-------------------------------------------------------------------------
    // 1. MONTAGEM DA QUERY PRINCIPAL (C91 - Cabeçalho S-1200)
    //-------------------------------------------------------------------------
    cQuery := "SELECT "
    cQuery += "    C91_FILIAL AS FILIAL, "
    cQuery += "    C91_ID AS ID, "
    cQuery += "    C91_VERSAO AS VERSAO, "
    cQuery += "    C91_INDAPU AS INDAPU, "
    cQuery += "    C91_PERAPU AS PERAPU, "
    cQuery += "    C91_CPF AS CPF, "
    cQuery += "    C91_TRABAL AS TRABAL "
    cQuery += "FROM " + RetSQLName("C91") + " C91 " 
    
    // Filtro de Filial: Usa o contexto do registro pai (S-1210)
    // Isso impede que, em ambientes compartilhados com múltiplas raízes de CNPJ,
    // o processamento misture dados de empresas diferentes.
    cQuery += "WHERE C91_FILIAL = '" + xFilial("C91", aInfos[1]) + "' "
    cQuery += "  AND C91.C91_PERAPU = '" + cPerRef + "' "
    
    // Filtros Opcionais (Performance)
    If !Empty( aInfos[6] )
        cQuery += "  AND C91_TRABAL = '" + aInfos[6] + "' "
    Else
        cQuery += "  AND C91_CPF = '" + aInfos[4] + "' "
    EndIf

    cQuery += "  AND C91.C91_ATIVO = '1' "
    cQuery += "  AND C91.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    // Execução da Query
    TcQuery cQuery New Alias &cAliasQry

    If Select( cAliasQry ) > 0
    
        ( cAliasQry )->( DbGoTop() )    

        //---------------------------------------------------------------------
        // 2. LOOP DE PROCESSAMENTO
        //---------------------------------------------------------------------
        If !(cAliasQry)->(EoF())                                                                                                                                                                                                                            

            //-----------------------------------------------------------------
            // NÍVEL 1: Identificação do Evento (T14)
            //-----------------------------------------------------------------
            T14->( DbSetOrder(1) )
            // Seek utiliza dados da query (já seguros/filtrados)
            If T14->(MsSeek((cAliasQry)->( FILIAL )+(cAliasQry)->( ID )+(cAliasQry)->( VERSAO )+PadR("", TamSx3("T14_INDAPU")[1])+PadR("", TamSx3("T14_PERAPU")[1])+PadR("", TamSx3("T14_TRABAL")[1])+cDmDev))
                
                cCateg := T14->T14_CODCAT
                indRRA := T14->T14_INDRRA

                //-------------------------------------------------------------
                // NÍVEL 2: Recibo de Pagamento (C9K)
                //-------------------------------------------------------------
                C9K->( DbSetOrder(1) )
                // Seek contextualizado com filial do pai (T14)
                If C9K->(MsSeek( xFilial("C9K", T14->T14_FILIAL) + T14->(T14_ID + T14_VERSAO + T14_IDEDMD) ))

                    While !C9K->(EOF()) .And. ;
                          C9K->C9K_FILIAL == xFilial("C9K", T14->T14_FILIAL) .And. ;
                          C9K->C9K_ID     == T14->T14_ID .And. ;
                          C9K->C9K_VERSAO == T14->T14_VERSAO .And. ;
                          C9K->C9K_RECIBO == T14->T14_IDEDMD

                        //-----------------------------------------------------
                        // NÍVEL 3: Informações Complementares (C9L)
                        //-----------------------------------------------------
                        C9L->( DbSetOrder(3) ) // Índice hierárquico específico
                        If C9L->(MsSeek( xFilial("C9L", C9K->C9K_FILIAL) + C9K->(C9K_ID + C9K_VERSAO + C9K_RECIBO + C9K_ESTABE + C9K_LOTACA + C9K_CODLOT + C9K_TPINSC + C9K_NRINSC) ))

                            While !C9L->(EOF()) .And. ;
                                  C9L->C9L_FILIAL == xFilial("C9L", C9K->C9K_FILIAL) .And. ;
                                  C9L->C9L_ID     == C9K->C9K_ID .And. ;
                                  C9L->C9L_VERSAO == C9K->C9K_VERSAO .And. ;
                                  C9L->C9L_RECIBO == C9K->C9K_RECIBO .And. ;
                                  C9L->C9L_ESTABE == C9K->C9K_ESTABE .And. ;
                                  C9L->C9L_LOTACA == C9K->C9K_LOTACA .And. ;
                                  C9L->C9L_CODLOT == C9K->C9K_CODLOT .And. ;
                                  C9L->C9L_TPINSC == C9K->C9K_TPINSC .And. ;
                                  C9L->C9L_NRINSC == C9K->C9K_NRINSC

                                //=========================================================
                                // BIFURCAÇÃO DE REGRA: NORMAL VS MÚLTIPLOS VÍNCULOS (MV)
                                //=========================================================
                                If !Empty(C9L->C9L_ESTABE) .And. !Empty(C9L->C9L_LOTACA)

                                    //---------------------------------------------
                                    // CENÁRIO A: Vínculo Normal (Tem Estab e Lotação)
                                    //---------------------------------------------
                                    C9M->(DbSetOrder(1))
                                    If C9M->(MsSeek( xFilial("C9M", C9L->C9L_FILIAL) + C9L->(C9L_ID + C9L_VERSAO + C9L_RECIBO + C9L_ESTABE + C9L_LOTACA) ))

                                        // O While garante que estamos lendo apenas registros deste escopo
                                        While !C9M->(EOF()) .And. ;
                                            C9M->C9M_FILIAL == xFilial("C9M", C9L->C9L_FILIAL) .And. ;
                                            C9M->C9M_ID     == C9L->C9L_ID .And. ;
                                            C9M->C9M_VERSAO == C9L->C9L_VERSAO .And. ;
                                            C9M->C9M_RECIBO == C9L->C9L_RECIBO .And. ;
                                            C9M->C9M_ESTABE == C9L->C9L_ESTABE .And. ;
                                            C9M->C9M_LOTACA == C9L->C9L_LOTACA 
                                            
                                            // Se por acaso o índice trouxer outro trabalhador, ignoramos.
                                            // Mas processamos se for o correto.
                                            If C9M->C9M_TRABAL == C9L->C9L_TRABAL
                                            
                                                cCodRubr  := C9M->C9M_CODRUB
                                                cIndApIR  := C9M->C9M_APURIR
                                                nValor    := C9M->C9M_VLRRUB
                                                
                                                // Carga Normal
                                                TafMainLoad( cCateg, indRRA, cCodRubr, cIndApIR ,nValor, @aAnalitico, cPaisExt, cEvento, cPeriodo, aInfos[5], aInfos[2], aInfos[6], aInfos[7], cPerRef, @nSequen, aInfos[3], aInfos[4], "", C9M->C9M_FILIAL )
                                            
                                            EndIf

                                            C9M->(DbSkip())
                                        EndDo
                                    EndIf

                                Else
                                    //---------------------------------------------
                                    // CENÁRIO B: Múltiplos Vínculos (Sem Estab na chave)
                                    //---------------------------------------------
                                    C9M->(DbSetOrder(3)) 
                                    If C9M->(MsSeek( xFilial("C9M", C9L->C9L_FILIAL) + C9L->(C9L_ID + C9L_VERSAO + C9L_RECIBO + C9L_CODLOT + C9L_TPINSC + C9L_NRINSC) ))

                                        While !C9M->(EOF()) .And. ;
                                            C9M->C9M_FILIAL == xFilial("C9M", C9L->C9L_FILIAL) .And. ;
                                            C9M->C9M_ID     == C9L->C9L_ID .And. ;
                                            C9M->C9M_VERSAO == C9L->C9L_VERSAO .And. ;
                                            C9M->C9M_RECIBO == C9L->C9L_RECIBO .And. ;
                                            C9M->C9M_CODLOT == C9L->C9L_CODLOT .And. ;
                                            C9M->C9M_TPINSC == C9L->C9L_TPINSC .And. ;
                                            C9M->C9M_NRINSC == C9L->C9L_NRINSC
                                            
                                            // Valida a Data do Trabalhador dentro do loop
                                            If DTOS(C9M->C9M_DTRABA) == DTOS(C9L->C9L_DTRABA)
                                            
                                                cCodRubr  := C9M->C9M_RUBRIC
                                                cIndApIR  := C9M->C9M_APURIR
                                                nValor    := C9M->C9M_VLRRUB
                                                
                                                // Carga MV
                                                TafMainLoad( cCateg, indRRA, cCodRubr, cIndApIR ,nValor, @aAnalitico, cPaisExt, cEvento, cPeriodo, aInfos[5], aInfos[2], aInfos[6], aInfos[7], cPerRef, @nSequen, aInfos[3], aInfos[4], "MV", C9M->C9M_FILIAL )
                                            
                                            EndIf

                                            C9M->(DbSkip())
                                        EndDo
                                    EndIf
                                
                                EndIf

                                C9L->(DbSkip())
                            EndDo
                        EndIf

                        C9K->(DbSkip())
                    EndDo
                EndIf
            
            EndIf

        Else
            Tafconout("Não há registros a serem processados.")
        EndIf

        (cAliasQry)->(DbCloseArea())

    Else
        // Log de erro crítico de infraestrutura
        TafConOut( "[TAFPer1200] [ERRO CRÍTICO] Falha ao abrir query na função: " + ProcName() )
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFPer2299
@type           Function
@description    Processa os registros do evento S-2299 (Desligamento) para o período atual.
                Realiza a leitura da estrutura CMD -> T06 -> T3G -> T05.
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTable      , Character , Tabela principal (CMD)
@param          cPerRef     , Character , Período de referência (AAAAMM)
@param          aInfos      , Array     , Array com dados do registro pai
@param          aAnalitico  , Array     , Array de retorno
@param          cPaisExt    , Character , Código do país
@param          cEvento     , Character , Tipo do evento (S-2299)
@param          cPeriodo    , Character , Período de apuração
@param          nSequen     , Numeric   , Sequencial
@param          cDmDev      , Character , ID do Demonstrativo
/*/
//---------------------------------------------------------------------
Function TAFPer2299( cTable as character, cPerRef as character, aInfos as Array, aAnalitico as Array, cPaisExt as character, cEvento as character, cPeriodo as character, nSequen as numeric, cDmDev as character )

    Local cQuery    as character
    Local cAliasQry as character
    Local cCateg    as character 
    Local indRRA    as character
    Local cCodRubr  as character
    Local cIndApIR  as character
    Local nValor    as numeric
    Local dDataRef  as date

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTable     := ""
    Default cPerRef    := ""
    Default aInfos     := {}
    Default aAnalitico := {}
    Default cPaisExt   := ""
    Default cEvento    := ""
    Default cPeriodo   := ""
    Default cDmDev     := ""
    Default nSequen    := 0
    
    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cQuery    := ""
    cAliasQry := GetNextAlias()
    cCateg    := "" 
    indRRA    := ""
    cCodRubr  := ""
    cIndApIR  := ""
    nValor    := 0

    // Define data de referência para calcular o último dia do mês corretamente
    dDataRef := STOD(cPerRef + "01")
    If Empty(dDataRef)
        dDataRef := Date()
    EndIf

    //-------------------------------------------------------------------------
    // 1. MONTAGEM DA QUERY (CMD - Cabeçalho Desligamento)
    //-------------------------------------------------------------------------
    cQuery := "SELECT "
    cQuery += "    CMD_FILIAL AS FILIAL, "
    cQuery += "    CMD_ID AS ID, "
    cQuery += "    CMD_VERSAO AS VERSAO, "
    cQuery += "    CMD_DTDESL AS PERAPU, "
    cQuery += "    CMD_FUNC AS FUNCTRAB "
    cQuery += "FROM " + RetSqlName("CMD") + " CMD "
    
    // Filtros de Integridade
    cQuery += "WHERE CMD.CMD_FILIAL = '" + xFilial("CMD", aInfos[1]) + "' "
    cQuery += "  AND CMD.CMD_DTDESL BETWEEN '" + cPerRef + "01' AND '" + cPerRef + StrZero(Day(LastDay(dDataRef)), 2) + "' "
    
    If !Empty( aInfos[6] )
        cQuery += "  AND " + cTable + "_FUNC = '" + aInfos[6] + "' "
    EndIf

    cQuery += "  AND CMD.CMD_ATIVO = '1' "
    cQuery += "  AND CMD.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    TcQuery cQuery New Alias &cAliasQry

    If Select( cAliasQry ) > 0
    
        ( cAliasQry )->( DbGoTop() )

        //---------------------------------------------------------------------
        // 2. LOOP DE PROCESSAMENTO
        //---------------------------------------------------------------------
        If !(cAliasQry)->(EoF())

            // NÍVEL 1: Identificação (T06)
            T06->( DbSetOrder(1) ) // Filial + ID + Versão + ID Demo
            
            If T06->(MsSeek(xFilial("T06", (cAliasQry)->( FILIAL ))+(cAliasQry)->( ID )+(cAliasQry)->( VERSAO )+cDmDev))
                
                indRRA := T06->T06_INDRRA

                // NÍVEL 2: Verbas Rescisórias (T3G)
                T3G->(DbSetOrder(1))
                If T3G->(MsSeek(xFilial("T3G", T06->T06_FILIAL)+T06->(T06_ID+T06_VERSAO+T06_IDEDMD)))

                    While !T3G->(EOF()) .And. ;
                          T3G->T3G_FILIAL == xFilial("T3G", T06->T06_FILIAL) .And. ;
                          T3G->T3G_ID     == T06->T06_ID .And. ;
                          T3G->T3G_VERSAO == T06->T06_VERSAO .And. ;
                          T3G->T3G_RECPAG == T06->T06_IDEDMD

                        // NÍVEL 3: Itens da Rescisão (T05)
                        T05->( DbSetOrder(1) )
                        If T05->(MsSeek(xFilial("T05", T3G->T3G_FILIAL)+T3G->(T3G_ID+T3G_VERSAO+T3G_RECPAG+T3G_ESTABE+T3G_LOTTRB)))

                            While !T05->(EOF()) .And. ;
                                  T05->T05_FILIAL == xFilial("T05", T3G->T3G_FILIAL) .And. ;
                                  T05->T05_ID     == T3G->T3G_ID .And. ;
                                  T05->T05_VERSAO == T3G->T3G_VERSAO .And. ;
                                  T05->T05_RECPAG == T3G->T3G_RECPAG .And. ;
                                  T05->T05_ESTABE == T3G->T3G_ESTABE .And. ;
                                  T05->T05_LOTTRB == T3G->T3G_LOTTRB
                                
                                cCodRubr  := T05->T05_CODRUB
                                cIndApIR  := T05->T05_APURIR
                                nValor    := T05->T05_VLRRUB
                                                                                
                                // Carga Analítica (Passando "" para MV e Filial do Registro T05)
                                TafMainLoad( cCateg, indRRA, cCodRubr, cIndApIR ,nValor, @aAnalitico, cPaisExt, cEvento, cPeriodo, aInfos[5], aInfos[2], aInfos[6], aInfos[7], cPerRef, @nSequen, aInfos[3], aInfos[4], "", T05->T05_FILIAL )

                                T05->(DbSkip())
                            EndDo
                        EndIf

                        T3G->(DbSkip())
                    EndDo
                EndIf

            EndIf

        EndIf

        (cAliasQry)->(DbCloseArea())

    Else
        Tafconout("[TAFPer2299] Não há registros a serem processados.")
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAnt2299
@type           Function
@description    Processa registros anteriores do S-2299 (Complementares).
                Realiza a leitura da estrutura CMD -> T06 -> T5I -> T5J -> T5Q -> T5S.
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTable      , Character , Tabela principal (CMD)
@param          cPerRef     , Character , Período de referência
@param          aInfos      , Array     , Dados do registro pai
@param          aAnalitico  , Array     , Array de retorno
@param          cPaisExt    , Character , Código do país
@param          cEvento     , Character , Tipo do evento
@param          cPeriodo    , Character , Período de apuração
@param          nSequen     , Numeric   , Sequencial
@param          cDmDev      , Character , ID do Demonstrativo
/*/
//---------------------------------------------------------------------
Function TAFAnt2299( cTable as character, cPerRef as character, aInfos as Array, aAnalitico as Array, cPaisExt as character, cEvento as character, cPeriodo as character, nSequen as numeric, cDmDev as character )

    Local cQuery    as character
    Local cAliasQry as character
    Local cCateg    as character 
    Local indRRA    as character
    Local cCodRubr  as character
    Local cIndApIR  as character
    Local nValor    as numeric
    Local dDataRef  as date

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTable     := ""
    Default cPerRef    := ""
    Default aInfos     := {}
    Default aAnalitico := {}
    Default cPaisExt   := ""
    Default cEvento    := ""
    Default cPeriodo   := ""
    Default cDmDev     := ""
    Default nSequen    := 0
    
    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cQuery    := ""
    cAliasQry := GetNextAlias()
    cCateg    := "" 
    indRRA    := ""
    cCodRubr  := ""
    cIndApIR  := ""
    nValor    := 0

    // Define data de referência
    dDataRef := STOD(cPerRef + "01")
    If Empty(dDataRef)
        dDataRef := Date()
    EndIf

    //-------------------------------------------------------------------------
    // 1. MONTAGEM DA QUERY (CMD - Cabeçalho Desligamento)
    //-------------------------------------------------------------------------
    cQuery := "SELECT "
    cQuery += "    CMD_FILIAL AS FILIAL, "
    cQuery += "    CMD_ID AS ID, "
    cQuery += "    CMD_VERSAO AS VERSAO, "
    cQuery += "    CMD_DTDESL AS PERAPU, "
    cQuery += "    CMD_FUNC AS FUNCTRAB "
    cQuery += "FROM " + RetSqlName("CMD") + " CMD " 
    
    // Filtros de Integridade
    cQuery += "WHERE CMD.CMD_FILIAL = '" + xFilial("CMD", aInfos[1]) + "' "
    cQuery += "  AND CMD.CMD_DTDESL BETWEEN '" + cPerRef + "01' AND '" + cPerRef + StrZero(Day(LastDay(dDataRef)), 2) + "' "
    
    If !Empty( aInfos[6] )
        cQuery += "  AND " + cTable + "_FUNC = '" + aInfos[6] + "' "
    EndIf

    cQuery += "  AND CMD.CMD_ATIVO = '1' "
    cQuery += "  AND CMD.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    TcQuery cQuery New Alias &cAliasQry
    
    If Select( cAliasQry ) > 0
    
        ( cAliasQry )->( DbGoTop() )

        //---------------------------------------------------------------------
        // 2. LOOP DE PROCESSAMENTO
        //---------------------------------------------------------------------
        If !(cAliasQry)->(EoF())     

            // NÍVEL 1: Identificação (T06)
            T06->( DbSetOrder(1) )
            If T06->(MsSeek(xFilial("T06", (cAliasQry)->( FILIAL ))+(cAliasQry)->( ID )+(cAliasQry)->( VERSAO )+cDmDev))
                
                indRRA := T06->T06_INDRRA

                // NÍVEL 2: Informações Complementares (T5I)
                // [CORREÇÃO] O original estava T51 (cinquenta e um), alterado para T5I (cinco e i)
                T5I->(DbSetOrder(1)) 
                If T5I->(MsSeek(xFilial("T5I", T06->T06_FILIAL)+T06->(T06_ID+T06_VERSAO+T06_IDEDMD)))

                    While !T5I->(EOF()) .And. ;
                          T5I->T5I_FILIAL == xFilial("T5I", T06->T06_FILIAL) .And. ;
                          T5I->T5I_ID     == T06->T06_ID .And. ;
                          T5I->T5I_VERSAO == T06->T06_VERSAO .And. ;
                          T5I->T5I_IDEDMD == T06->T06_IDEDMD

                        // NÍVEL 3: Períodos Anteriores (T5J)
                        T5J->( DbSetOrder(1) )
                        If T5J->(MsSeek(xFilial("T5J", T5I->T5I_FILIAL)+T5I->(T5I_ID+T5I_VERSAO+T5I_IDEDMD+DTOS(T5I_DTACCO)+T5I_TPACCO)))

                            While !T5J->(EOF()) .And. ;
                                  T5J->T5J_FILIAL == xFilial("T5J", T5I->T5I_FILIAL) .And. ;
                                  T5J->T5J_ID     == T5I->T5I_ID .And. ;
                                  T5J->T5J_VERSAO == T5I->T5I_VERSAO .And. ;
                                  T5J->T5J_IDEDMD == T5I->T5I_IDEDMD .And. ;
                                  DTOS(T5J->T5J_DTACCO) == DTOS(T5I->T5I_DTACCO) .And. ;
                                  T5J->T5J_TPACCO == T5I->T5I_TPACCO
                                
                                // NÍVEL 4: Base de Cálculo (T5Q)
                                T5Q->( DbSetOrder(1) )
                                If T5Q->(MsSeek(xFilial("T5Q", T5J->T5J_FILIAL)+T5J->(T5J_ID+T5J_VERSAO+T5J_IDEDMD+DTOS(T5J_DTACCO)+T5J_TPACCO+T5J_PERREF)))

                                    While !T5Q->(EOF()) .And. ;
                                          T5Q->T5Q_FILIAL == xFilial("T5Q", T5J->T5J_FILIAL) .And. ;
                                          T5Q->T5Q_ID     == T5J->T5J_ID .And. ;
                                          T5Q->T5Q_VERSAO == T5J->T5J_VERSAO .And. ;
                                          T5Q->T5Q_IDEDMD == T5J->T5J_IDEDMD .And. ;
                                          DTOS(T5Q->T5Q_DTACCO) == DTOS(T5J->T5J_DTACCO) .And. ;
                                          T5Q->T5Q_TPACCO == T5J->T5J_TPACCO .And. ;
                                          T5Q->T5Q_PERREF == T5J->T5J_PERREF
                                        
                                        // NÍVEL 5: Itens da Remuneração (T5S)
                                        T5S->( DbSetOrder(1) )
                                        If T5S->(MsSeek(xFilial("T5S", T5Q->T5Q_FILIAL)+T5Q->(T5Q_ID+T5Q_VERSAO+T5Q_IDEDMD+DTOS(T5Q_DTACCO)+T5Q_TPACCO+T5Q_PERREF+T5Q_ESTABE+T5Q_LOTTRB)))

                                            While !T5S->(EOF()) .And. ;
                                                  T5S->T5S_FILIAL == xFilial("T5S", T5Q->T5Q_FILIAL) .And. ;
                                                  T5S->T5S_ID     == T5Q->T5Q_ID .And. ;
                                                  T5S->T5S_VERSAO == T5Q->T5Q_VERSAO .And. ;
                                                  T5S->T5S_IDEDMD == T5Q->T5Q_IDEDMD .And. ;
                                                  DTOS(T5S->T5S_DTACCO) == DTOS(T5Q->T5Q_DTACCO) .And. ;
                                                  T5S->T5S_TPACCO == T5Q->T5Q_TPACCO .And. ;
                                                  T5S->T5S_PERREF == T5Q->T5Q_PERREF .And. ;
                                                  T5S->T5S_ESTABE == T5Q->T5Q_ESTABE .And. ;
                                                  T5S->T5S_LOTTRB == T5Q->T5Q_LOTTRB
                                            
                                                cCodRubr  := T5S->T5S_CODRUB
                                                cIndApIR  := T5S->T5S_APURIR
                                                nValor    := T5S->T5S_VLRRUB
                                                                                                        
                                                // Carga Analítica (Passando "" para MV e Filial do Registro T5S)
                                                TafMainLoad( cCateg, indRRA, cCodRubr, cIndApIR ,nValor, @aAnalitico, cPaisExt, cEvento, cPeriodo, aInfos[5], aInfos[2], aInfos[6], aInfos[7], cPerRef, @nSequen, aInfos[3], aInfos[4], "", T5S->T5S_FILIAL )

                                                T5S->(DbSkip())
                                            EndDo
                                        EndIf

                                        T5Q->(DbSkip())
                                    EndDo
                                EndIf

                                T5J->(DbSkip())
                            EndDo
                        EndIf

                        T5I->(DbSkip())
                    EndDo
                EndIf

            EndIf

        EndIf

        (cAliasQry)->(DbCloseArea())

    Else
        Tafconout("[TAFAnt2299] Não há registros a serem processados.")
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFPer2399
@type           Function
@description    Processa registros do S-2399 (Término de Trabalhador Sem Vínculo).
                Realiza a leitura das tabelas filhas (T3I, T3J, CMK) para compor o analítico.
@author         Alexandre de Lima Santos / Denis R. de Oliveira 
@since          28/10/2025
@version        1.0

@param          cTable      , Character , Tabela principal de origem (T92)
@param          cPerRef     , Character , Período de referência (AAAAMM)
@param          aInfos      , Array     , Array com dados do registro pai
@param          aAnalitico  , Array     , Array de retorno com os dados processados
@param          cPaisExt    , Character , Código do país no exterior (se houver)
@param          cEvento     , Character , Identificador do evento (Ex: "S-2399")
@param          cPeriodo    , Character , Período de apuração
@param          nSequen     , Numeric   , Sequencial numérico para controle do array analítico
@param          cDmDev      , Character , Identificador do Demonstrativo de Valores (IDEDMD)

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFPer2399( cTable as character, cPerRef as character, aInfos as Array, aAnalitico as Array, cPaisExt as character, cEvento as character, cPeriodo as character, nSequen as numeric, cDmDev as character )

    Local cQuery    as character
    Local cAliasQry as character
    Local cCateg    as character
    Local cCodRubr  as character
    Local cIndApIR  as character  
    Local indRRA    as character  
    Local nValor    as numeric 
    
    Local dDataRef  as date

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTable     := ""
    Default cPerRef    := ""
    Default aInfos     := {}
    Default aAnalitico := {}
    Default cPaisExt   := ""
    Default cEvento    := ""
    Default cPeriodo   := ""
    Default nSequen    := 0
    Default cDmDev     := ""

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cQuery    := ""
    cAliasQry := GetNextAlias()
    cCateg    := ""
    cCodRubr  := "" 
    cIndApIR  := ""  
    indRRA    := ""  
    nValor    := 0

    dDataRef := STOD(cPerRef + "01")
    If Empty(dDataRef)
        dDataRef := Date()  // Fallback para data atual
    EndIf

    //-------------------------------------------------------------------------
    // 1. MONTAGEM DA QUERY (T92 - Cabeçalho S-2399)
    //-------------------------------------------------------------------------
    cQuery := " SELECT T92_FILIAL AS FILIAL, T92_ID AS ID, T92_VERSAO AS VERSAO, T92_DTERAV AS PERAPU, T92_TRABAL AS FUNCTRAB FROM " + RetSqlName("T92") + " T92" 
    
    // Filtro de Filial usando o contexto do registro pai (S-1210)
    // Garante que só processa demissões da empresa/filial corrente
    cQuery += " WHERE T92_FILIAL = '" + xFilial("T92", aInfos[1]) + "' "
    
    // Filtro de Data (Período de Apuração dentro do mês de referência)
    cQuery += "	 AND T92.T92_DTERAV BETWEEN '" + cPerRef + "01' "
    cQuery += "  AND '" + cPerRef + StrZero(Day(LastDay(dDataRef)), 2) + "' "
   
    // Filtro de Trabalhador
    If !Empty( aInfos[6] )
        cQuery += " AND " + cTable + "_TRABAL = '" + aInfos[6] + "' "
    EndIf

    cQuery += " AND T92.T92_ATIVO = '1' "
    cQuery += " AND T92.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    TcQuery cQuery New Alias &cAliasQry

    If Select( cAliasQry ) > 0
    
        ( cAliasQry )->( DbGoTop() )

        //---------------------------------------------------------------------
        // 2. LOOP DE PROCESSAMENTO
        //---------------------------------------------------------------------
        If !(cAliasQry)->(EoF())

            // NÍVEL 1: Identificação do Evento (T3I)
            T3I->( DbSetOrder(1) ) // Índice: ID + Versão + ID Demo (cDmDev)
            
            // Seek usa xFilial para garantir compatibilidade se T3I for compartilhada/exclusiva
            // Usa os dados da Query (já filtrada) + ID Demonstrativo (Parâmetro)
            If T3I->(MsSeek( xFilial("T3I", aInfos[1]) + (cAliasQry)->( ID ) + (cAliasQry)->( VERSAO ) + cDmDev ))
            
                indRRA := T3I->T3I_INDRRA

                // NÍVEL 2: Informações de Pagamento (T3J)
                T3J->(DbSetOrder(1)) // Índice: Filial + ID + Versão + ID Demo
                
                // Seek usa a filial do pai (T3I) como referência
                If T3J->(MsSeek( xFilial("T3J", T3I->T3I_FILIAL) + T3I->(T3I_ID + T3I_VERSAO + T3I_IDEDMD) ))

                    // Loop T3J: Comparação Direta (Performance)
                    // Verifica filial, ID, Versão e ID Demo
                    While !T3J->(EOF()) .And. T3J->T3J_FILIAL == xFilial("T3J", T3I->T3I_FILIAL) .And. ;
                          T3J->T3J_ID     == T3I->T3I_ID .And. ;
                          T3J->T3J_VERSAO == T3I->T3I_VERSAO .And. ;
                          T3J->T3J_IDEDMD == T3I->T3I_IDEDMD

                        // NÍVEL 3: Detalhamento do Pagamento/Rubricas (CMK)
                        CMK->( DbSetOrder(1) ) // Índice: Filial + ID + Versão + ID Demo + Estab + Lotacao
                        
                        // Seek usa a filial do pai (T3J)
                        If CMK->(MsSeek( xFilial("CMK", T3J->T3J_FILIAL) + T3J->(T3J_ID + T3J_VERSAO + T3J_IDEDMD + T3J_ESTABE + T3J_LOTTRB) ))

                            // Loop CMK: Comparação Direta (Performance)
                            // Verifica toda a chave composta para garantir que estamos no bloco certo
                            While !CMK->(EOF()) .And. ;
                                  CMK->CMK_FILIAL == xFilial("CMK", T3J->T3J_FILIAL) .And. ;
                                  CMK->CMK_ID     == T3J->T3J_ID .And. ;
                                  CMK->CMK_VERSAO == T3J->T3J_VERSAO .And. ;
                                  CMK->CMK_IDEDMD == T3J->T3J_IDEDMD .And. ;
                                  CMK->CMK_ESTABE == T3J->T3J_ESTABE .And. ;
                                  CMK->CMK_LOTTRB == T3J->T3J_LOTTRB
                                
                                cCodRubr  := CMK->CMK_CODRUB
                                cIndApIR  := CMK->CMK_APURIR
                                nValor    := CMK->CMK_VLRRUB
                                                           
                                // Chamada da Carga com Filial do Registro (CMK->FILIAL)
                                // cMv vazio ("") pois S-2399 não usa lógica de múltiplos vínculos padrão do S-1200
                                TafMainLoad( cCateg, indRRA, cCodRubr, cIndApIR, nValor, @aAnalitico, cPaisExt, cEvento, cPeriodo, aInfos[5], aInfos[2], aInfos[6], aInfos[7], cPerRef, @nSequen, aInfos[3], aInfos[4], "", CMK->CMK_FILIAL )

                                CMK->(DbSkip())
 
                            EndDo
                        EndIf 

                        T3J->(DbSkip())
                    EndDo 
                EndIf 

            EndIf 

        Else
            // Tafconout("Não há registros a serem processados no S-2399 para este ID.")
        EndIf

        (cAliasQry)->(DbCloseArea())

    Else
        // Log de erro de infraestrutura
        TafConOut( "[TAFPer2399] [ERRO CRÍTICO] Falha ao abrir query na função: " + ProcName() )
    EndIf 

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAnt1200
@type           Function
@description    Processa registros anteriores do S-1200 (Complementares/Múltiplos Vínculos).
                Realiza a leitura hierárquica das tabelas C91 -> T14 -> C9N -> C9O -> C9P -> C9Q -> C9R.
@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          28/10/2025
@version        1.0

@param          cTable      , Character , Tabela principal (não utilizada diretamente na lógica)
@param          cPerRef     , Character , Período de referência (AAAAMM)
@param          aInfos      , Array     , Array com dados do registro pai (Filial, ID, Versão, etc.)
@param          aAnalitico  , Array     , Array de retorno (passado por referência)
@param          cPaisExt    , Character , Código do país no exterior
@param          cEvento     , Character , Tipo do evento
@param          cPeriodo    , Character , Período de apuração
@param          nSequen     , Numeric   , Sequencial numérico
@param          cDmDev      , Character , Identificador do Demonstrativo (IDEDMD)

@return         Nil
/*/
//---------------------------------------------------------------------
Function TAFAnt1200( cTable as character, cPerRef as character, aInfos as Array, aAnalitico as Array, cPaisExt as character, cEvento as character, cPeriodo as character, nSequen as numeric, cDmDev as character )
    
    Local cQuery    as character
    Local cAliasQry as character
    Local cCateg    as character 
    Local indRRA    as character
    Local cCodRubr  as character
    Local cIndApIR  as character
    Local cMv       as character
    Local nValor    as numeric

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cTable     := ""
    Default cPerRef    := ""
    Default aInfos     := {}
    Default aAnalitico := {}
    Default cPaisExt   := ""
    Default cEvento    := ""
    Default cPeriodo   := ""
    Default cDmDev     := ""
    Default nSequen    := 0
  
    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    cQuery    := ""
    cAliasQry := GetNextAlias()
    cCateg    := "" 
    indRRA    := ""
    cCodRubr  := ""
    cIndApIR  := ""
    cMv       := ""
    nValor    := 0

    //-------------------------------------------------------------------------
    // 1. QUERY PRINCIPAL (C91 - Cabeçalho Anterior)
    //-------------------------------------------------------------------------
    cQuery := "SELECT C91_FILIAL AS FILIAL, C91_ID AS ID, C91_VERSAO AS VERSAO, C91_INDAPU AS INDAPU, C91_PERAPU AS PERAPU, C91_CPF AS CPF, C91_TRABAL AS TRABAL, C91_MV AS MV FROM " +  RetSQLName("C91") + " C91" 
    
    // Filtra apenas registros da filial do contexto (aInfos[1])
    // Garante que não misture dados de empresas diferentes (Raízes de CNPJ distintas)
    cQuery += " WHERE C91_FILIAL = '" + xFilial("C91", aInfos[1]) + "' "
    cQuery += "   AND C91.C91_PERAPU = '" + cPerRef + "' "
    
    If !Empty( aInfos[6] )
        cQuery += "AND C91_TRABAL = '" + aInfos[6] + "' " 
    Else
        cQuery += "AND C91_CPF = '" + aInfos[4] + "' "
    EndIf

    cQuery += "AND C91.C91_ATIVO = '1' "
    cQuery += "AND C91.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)

    TcQuery cQuery New Alias &cAliasQry

    If Select( cAliasQry ) > 0

        ( cAliasQry )->( DbGoTop() )

        //---------------------------------------------------------------------
        // 2. LOOP DE PROCESSAMENTO
        //---------------------------------------------------------------------
        If !(cAliasQry)->(EoF())                                                                                                                                                                                                                                
            
            cMv := (cAliasQry)->( MV )

            //-----------------------------------------------------------------
            // NÍVEL 1: Identificação do Evento (T14)
            //-----------------------------------------------------------------
            T14->( DbSetOrder(1) )
            // Seek utiliza dados da query (já seguros/filtrados)
            If T14->(MsSeek((cAliasQry)->( FILIAL )+(cAliasQry)->( ID )+(cAliasQry)->( VERSAO )+PadR("", TamSx3("T14_INDAPU")[1])+PadR("", TamSx3("T14_PERAPU")[1])+PadR("", TamSx3("T14_TRABAL")[1])+cDmDev))     
                
                cCateg := T14->T14_CODCAT
                indRRA := T14->T14_INDRRA

                //-------------------------------------------------------------
                // NÍVEL 2: Recibo de Pagamento (C9N)
                //-------------------------------------------------------------
                C9N->(DbSetOrder(1))
                If C9N->(MsSeek(xFilial("C9N", T14->T14_FILIAL)+T14->(T14_ID+T14_VERSAO+T14_IDEDMD)))

                    While !C9N->(EOF()) .And. C9N->C9N_FILIAL == xFilial("C9N", T14->T14_FILIAL) .And. C9N->C9N_ID == T14->T14_ID .And. C9N->C9N_VERSAO == T14->T14_VERSAO .And. C9N->C9N_RECIBO == T14->T14_IDEDMD

                        //-----------------------------------------------------
                        // NÍVEL 3: Informações Complementares (C9O)
                        //-----------------------------------------------------
                        C9O->( DbSetOrder(1) )
                        If C9O->(MsSeek(xFilial("C9O", C9N->C9N_FILIAL)+C9N->(C9N_ID+C9N_VERSAO+C9N_RECIBO+DTOS(C9N_DTACOR)+C9N_TPACOR+C9N_COMPAC)))

                            While !C9O->(EOF()) .And. AllTrim(C9O->(C9O_FILIAL+C9O_ID+C9O_VERSAO+C9O_RECIBO+DTOS(C9O_DTACOR)+C9O_TPACOR+C9O_COMPAC)) == AllTrim(C9N->(C9N_FILIAL+C9N_ID+C9N_VERSAO+C9N_RECIBO+DTOS(C9N_DTACOR)+C9N_TPACOR+C9N_COMPAC))
                                //-----------------------------------------------------
                                // NÍVEL 4: Informações do Período (C9P)
                                //-----------------------------------------------------                           
                                C9P->(DbSetOrder(1))
                                If C9P->(MsSeek(xFilial("C9P", C9O->C9O_FILIAL)+C9O->(C9O_ID+C9O_VERSAO+C9O_RECIBO+DTOS(C9O_DTACOR)+C9O_TPACOR+C9O_COMPAC+C9O_PERREF)))

                                    While !C9P->(EOF()) .And. AllTrim(C9P->(C9P_FILIAL+C9P_ID+C9P_VERSAO+C9P_RECIBO+DTOS(C9P_DTACOR)+C9P_TPACOR+C9P_COMPAC+C9P_PERREF)) == AllTrim(C9O->(C9O_FILIAL+C9O_ID+C9O_VERSAO+C9O_RECIBO+DTOS(C9O_DTACOR)+C9O_TPACOR+C9O_COMPAC+C9O_PERREF))
                                        
                                        //=============================================================
                                        // CENÁRIO 1: MÚLTIPLOS VÍNCULOS (MV)
                                        //=============================================================
                                        If cMv == "1" 
                                            
                                            // [NÍVEL 5 - MV] Informações Complementares (C9Q - Índice 3)
                                            C9Q->( DbSetOrder( 3 ) )                     
                                            If C9Q->(MsSeek( xFilial("C9Q", C9P->C9P_FILIAL) + C9P->(C9P_ID + C9P_VERSAO + C9P_RECIBO + DTOS(C9P_DTACOR) + C9P_TPACOR + C9P_PERREF + C9P_ESTABE + C9P_LOTACA + C9P_CODLOT) ))

                                                // Loop Otimizado (Comparação Direta)
                                                While !C9Q->(EOF()) ;
                                                       .And. C9Q->C9Q_FILIAL == xFilial("C9Q", C9P->C9P_FILIAL) ;
                                                       .And. C9Q->C9Q_ID  == C9P->C9P_ID ;
                                                       .And. C9Q->C9Q_VERSAO == C9P->C9P_VERSAO ;
                                                       .And. C9Q->C9Q_RECIBO == C9P->C9P_RECIBO ;
                                                       .And. DTOS(C9Q->C9Q_DTACOR) == DTOS(C9P->C9P_DTACOR) ;
                                                       .And. C9Q->C9Q_TPACOR == C9P->C9P_TPACOR ;
                                                       .And. C9Q->C9Q_COMPAC == C9P->C9P_COMPAC ;
                                                       .And. C9Q->C9Q_PERREF == C9P->C9P_PERREF ;
                                                       .And. C9Q->C9Q_ESTABE == C9P->C9P_ESTABE ;
                                                       .And. C9Q->C9Q_LOTACA == C9P->C9P_LOTACA ;
                                                       .And. C9Q->C9Q_CODLOT == C9P->C9P_CODLOT

                                                    // [NÍVEL 6 - MV] Processos Relacionados (C9R)
                                                    C9R->( DbSetOrder( 1 ) )                     
                                                    If C9R->( MsSeek( xFilial("C9R", C9Q->C9Q_FILIAL) + C9Q->(C9Q_ID + C9Q_VERSAO + C9Q_RECIBO + DTOS(C9Q_DTACOR) + C9Q_TPACOR + C9Q_COMPAC + C9Q_PERREF + C9Q_ESTABE + C9Q_LOTACA) ))

                                                        While !C9R->(Eof()) ;
                                                            .And. C9R->C9R_FILIAL == xFilial("C9R", C9Q->C9Q_FILIAL) ;
                                                            .And. C9R->C9R_ID == C9Q->C9Q_ID ;
                                                            .And. C9R->C9R_VERSAO == C9Q->C9Q_VERSAO ;
                                                            .And. C9R->C9R_RECIBO == C9Q->C9Q_RECIBO ;
                                                            .And. DTOS(C9R->C9R_DTACOR) == DTOS(C9Q->C9Q_DTACOR) ;
                                                            .And. C9R->C9R_TPACOR == C9Q->C9Q_TPACOR ;
                                                            .And. C9R->C9R_COMPAC == C9Q->C9Q_COMPAC ;
                                                            .And. C9R->C9R_PERREF == C9Q->C9Q_PERREF ;
                                                            .And. C9R->C9R_ESTABE == C9Q->C9Q_ESTABE ;
                                                            .And. C9R->C9R_LOTACA == C9Q->C9Q_LOTACA
                                                            
                                                            // Valida Trabalhador
                                                            If C9R->C9R_TRABAL == C9Q->C9Q_TRABAL
                                                                    
                                                                    cCodRubr  := C9R->C9R_RUBRIC 
                                                                    cIndApIR  := C9R->C9R_APURIR
                                                                    nValor    := C9R->C9R_VLRRUB

                                                                    TafMainLoad( cCateg, indRRA, cCodRubr, cIndApIR, nValor, @aAnalitico, cPaisExt, cEvento, cPeriodo, aInfos[5], aInfos[2], aInfos[6], aInfos[7], cPerRef, @nSequen, aInfos[3], aInfos[4], "MV", C9R->C9R_FILIAL )
                                                            
                                                            EndIf

                                                            C9R->(DbSkip())                          
                                                        EndDo
                                                    EndIf  
                                                   
                                                    C9Q->(DbSkip())    
                                                EndDo
                                            EndIf

                                        //=============================================================
                                        // CENÁRIO 2: VÍNCULO ÚNICO (NORMAL)
                                        //=============================================================
                                        Else
                                            
                                            // [NÍVEL 5 - Normal] Informações Complementares (C9Q - Índice 1)
                                            C9Q->(DbSetOrder(1))
                                            If C9Q->(MsSeek( xFilial("C9Q", C9P->C9P_FILIAL) + C9P->(C9P_ID + C9P_VERSAO + C9P_RECIBO + DTOS(C9P_DTACOR) + C9P_TPACOR + C9P_COMPAC + C9P_PERREF + C9P_ESTABE + C9P_LOTACA) ))

                                                // Loop Otimizado (Comparação Direta)
                                                While !C9Q->(EOF()) ;
                                                       .And. C9Q->C9Q_FILIAL == xFilial("C9Q", C9P->C9P_FILIAL) ;
                                                       .And. C9Q->C9Q_ID == C9P->C9P_ID ;
                                                       .And. C9Q->C9Q_VERSAO == C9P->C9P_VERSAO ;
                                                       .And. C9Q->C9Q_RECIBO == C9P->C9P_RECIBO ;
                                                       .And. DTOS(C9Q->C9Q_DTACOR) == DTOS(C9P->C9P_DTACOR) ;
                                                       .And. C9Q->C9Q_TPACOR == C9P->C9P_TPACOR ;
                                                       .And. C9Q->C9Q_COMPAC == C9P->C9P_COMPAC ;
                                                       .And. C9Q->C9Q_PERREF == C9P->C9P_PERREF ;
                                                       .And. C9Q->C9Q_ESTABE == C9P->C9P_ESTABE ; 
                                                       .And. C9Q->C9Q_LOTACA == C9P->C9P_LOTACA

                                                    // [NÍVEL 6 - Normal] Processos Relacionados (C9R)
                                                    C9R->( DbSetOrder( 1 ) )                     
                                                    If C9R->( MsSeek( xFilial("C9R", C9Q->C9Q_FILIAL) + C9Q->(C9Q_ID + C9Q_VERSAO + C9Q_RECIBO + DTOS(C9Q_DTACOR) + C9Q_TPACOR + C9Q_COMPAC + C9Q_PERREF + C9Q_ESTABE + C9Q_LOTACA) ))

                                                        While !C9R->(Eof()) ;
                                                            .And. C9R->C9R_FILIAL == xFilial("C9R", C9Q->C9Q_FILIAL) ;
                                                            .And. C9R->C9R_ID == C9Q->C9Q_ID ;
                                                            .And. C9R->C9R_VERSAO == C9Q->C9Q_VERSAO ;
                                                            .And. C9R->C9R_RECIBO == C9Q->C9Q_RECIBO ;
                                                            .And. DTOS(C9R->C9R_DTACOR) == DTOS(C9Q->C9Q_DTACOR) ;
                                                            .And. C9R->C9R_TPACOR == C9Q->C9Q_TPACOR ;
                                                            .And. C9R->C9R_COMPAC == C9Q->C9Q_COMPAC ;
                                                            .And. C9R->C9R_PERREF == C9Q->C9Q_PERREF ;
                                                            .And. C9R->C9R_ESTABE == C9Q->C9Q_ESTABE ;
                                                            .And. C9R->C9R_LOTACA == C9Q->C9Q_LOTACA 
                                                            
                                                            // Valida Trabalhador
                                                            If C9R->C9R_TRABAL == C9Q->C9Q_TRABAL
                                                                    
                                                                    cCodRubr  := C9R->C9R_CODRUB 
                                                                    cIndApIR  := C9R->C9R_APURIR
                                                                    nValor    := C9R->C9R_VLRRUB

                                                                    TafMainLoad( cCateg, indRRA, cCodRubr, cIndApIR, nValor, @aAnalitico, cPaisExt, cEvento, cPeriodo, aInfos[5], aInfos[2], aInfos[6], aInfos[7], cPerRef, @nSequen, aInfos[3], aInfos[4], "", C9R->C9R_FILIAL )
                                                            
                                                            EndIf

                                                            C9R->(DbSkip())
                                                        EndDo
                                                    EndIf

                                                    C9Q->(DbSkip())
                                                EndDo
                                            EndIf

                                        EndIF

                                        C9P->(DbSkip())
                                    EndDo
                                EndIf

                                C9O->(DbSkip())
                            EndDo
                        EndIf

                        C9N->(DbSkip())
                    EndDo
                EndIf
           
            EndIf

        Else
            Tafconout("Não há registros a serem processados.")
        EndIf

        (cAliasQry)->(DbCloseArea())

    Else
        // Log de erro de infraestrutura
        TafConOut( "[TAFAnt1200] [ERRO CRÍTICO] Falha ao abrir query na função: " + ProcName() )
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFCon5002
@type           Function
@description    Realiza o processamento e transformação dos dados consolidados de IRRF (Evento eSocial S-5002).
                A função utiliza mapeamento prévio de campos (FieldPos) para garantir alta performance 
                no acesso aos dados (Complexidade O(1)) durante a iteração do cursor[cite: 1039, 1043].

@param          cAliasQry , Character, Alias do cursor (tabela temporária ou query) posicionado com os dados do S-5002[cite: 1034, 1037].
@param          aInfos    , Array    , Vetor contendo metadados do registro pai (Filial, CPF, Período, etc.)[cite: 1034, 1043, 1044].
@param          aAnalitico, Array    , Vetor de retorno (Passado por Referência) que receberá os dados formatados para gravação.

@return         Nil, A função popula o array aAnalitico por referência.

@author         Alexandre de Lima Santos / Denis R. de Oliveira 
@since          28/10/2025 
@version        1.0 
@see            TAFColDirf, TAFGRID
/*/
//---------------------------------------------------------------------
Function TAFCon5002( cAliasQry as Character, aInfos as Array, aAnalitico as Array ) 

    Local nPosValores   as numeric
    Local cNome         as character
    Local nSequen       as numeric
    
    // Variáveis para Cache de Posição de Campos (Performance)
    Local nP_ID         as numeric
    Local nP_RENDTR     as numeric
    Local nP_RENT13     as numeric
    Local nP_PREVOF     as numeric
    Local nP_PROF13     as numeric
    Local nP_VCRMEN     as numeric
    Local nP_CR13ME     as numeric
    Local nP_PAIS65     as numeric
    Local nP_PIS65D     as numeric
    Local nP_VLDIAR     as numeric
    Local nP_VLAJUC     as numeric
    Local nP_VINRES     as numeric
    Local nP_ABONPE     as numeric
    Local nP_VLRIMG     as numeric
    Local nP_IMG13      as numeric
    Local nP_VLMORD     as numeric
    Local nP_BOLMED     as numeric
    Local nP_BOLM13     as numeric
    Local nP_JURMOR     as numeric
    Local nP_ISEOUT     as numeric
    Local nP_CRMEN      as numeric
    Local nP_VERSAO     as numeric

    //-------------------------------------------------------------------------
    // Inicialização dos parâmetros com valores default
    //-------------------------------------------------------------------------
    Default cAliasQry   := ""
    Default aInfos      := {}
    Default aAnalitico  := {}

    //-------------------------------------------------------------------------
    // Inicialização de Variáveis
    //-------------------------------------------------------------------------
    nPosValores := 0
    cNome       := ""
    nSequen     := 0

    nP_ID       := 0
    nP_RENDTR   := 0
    nP_RENT13   := 0
    nP_PREVOF   := 0
    nP_PROF13   := 0
    nP_VCRMEN   := 0
    nP_CR13ME   := 0
    nP_PAIS65   := 0
    nP_PIS65D   := 0
    nP_VLDIAR   := 0
    nP_VLAJUC   := 0
    nP_VINRES   := 0
    nP_ABONPE   := 0
    nP_VLRIMG   := 0
    nP_IMG13    := 0
    nP_VLMORD   := 0
    nP_BOLMED   := 0
    nP_BOLM13   := 0
    nP_JURMOR   := 0
    nP_ISEOUT   := 0
    nP_CRMEN    := 0
    nP_VERSAO   := 0

    // Verifica se o alias foi criado com sucesso
    If Select( cAliasQry ) > 0 

        //---------------------------------------------------------------------
        // Mapeamento de Campos (Executado 1x fora do loop)
        // Evita milhares de chamadas de macro (&) e FieldPos dentro do While
        //---------------------------------------------------------------------
        nP_ID         := (cAliasQry)->(FieldPos("T8G_ID"))
        nP_RENDTR     := (cAliasQry)->(FieldPos("T8G_RENDTR"))
        nP_RENT13     := (cAliasQry)->(FieldPos("T8G_RENT13"))
        nP_PREVOF     := (cAliasQry)->(FieldPos("T8G_PREVOF"))
        nP_PROF13     := (cAliasQry)->(FieldPos("T8G_PROF13"))
        nP_VCRMEN     := (cAliasQry)->(FieldPos("T8G_VCRMEN"))
        nP_CR13ME     := (cAliasQry)->(FieldPos("T8G_CR13ME"))
        nP_PAIS65     := (cAliasQry)->(FieldPos("T8G_PAIS65"))
        nP_PIS65D     := (cAliasQry)->(FieldPos("T8G_PIS65D"))
        nP_VLDIAR     := (cAliasQry)->(FieldPos("T8G_VLDIAR"))
        nP_VLAJUC     := (cAliasQry)->(FieldPos("T8G_VLAJUC"))
        nP_VINRES     := (cAliasQry)->(FieldPos("T8G_VINRES"))
        nP_ABONPE     := (cAliasQry)->(FieldPos("T8G_ABONPE"))
        nP_VLRIMG     := (cAliasQry)->(FieldPos("T8G_VLRIMG"))
        nP_IMG13      := (cAliasQry)->(FieldPos("T8G_IMG13"))
        nP_VLMORD     := (cAliasQry)->(FieldPos("T8G_VLMORD"))
        nP_BOLMED     := (cAliasQry)->(FieldPos("T8G_BOLMED"))
        nP_BOLM13     := (cAliasQry)->(FieldPos("T8G_BOLM13"))
        nP_JURMOR     := (cAliasQry)->(FieldPos("T8G_JURMOR"))
        nP_ISEOUT     := (cAliasQry)->(FieldPos("T8G_ISEOUT"))
        nP_CRMEN      := (cAliasQry)->(FieldPos("T8G_CRMEN"))
        nP_VERSAO     := (cAliasQry)->(FieldPos("T8G_VERSAO"))

        // Busca o Nome do Trabalhador (Executado 1x fora do loop)
        cNome := TAFNomeFun( "", aInfos[4], aInfos[1] )

        ( cAliasQry )->( DbGoTop() )

        While !(cAliasQry)->(EoF())

            nSequen++

            aAdd(aAnalitico, Array(77))
            nPosValores := Len(aAnalitico)

            TAFInitArray( aAnalitico, nPosValores )
        
            // Filial: Usa a do registro pai (aInfos[1])
            // Garante que o dado analítico pertença à filial correta do lote
            aAnalitico[nPosValores][ANALITICO_FILIAL]           := aInfos[1]
            
            // Acesso via FieldGet usando posições cacheadas
            // Transforma acesso O(n) em O(1) - Ultra rápido
            aAnalitico[nPosValores][ANALITICO_ID]               := (cAliasQry)->(FieldGet(nP_ID))
            aAnalitico[nPosValores][ANALITICO_PERAPU]           := aInfos[5]
            aAnalitico[nPosValores][ANALITICO_CPF]              := aInfos[4] 
            aAnalitico[nPosValores][ANALITICO_NOME]             := cNome 
            aAnalitico[nPosValores][ANALITICO_EVENTO]           := "S-5002"
            aAnalitico[nPosValores][ANALITICO_SEQUENCIA]        := CVALTOCHAR(STRZERO(nSequen, 3))
            
            // Valores obtidos via FieldGet
            aAnalitico[nPosValores][ANALITICO_VLRRENDTRIB]      := (cAliasQry)->(FieldGet(nP_RENDTR))
            aAnalitico[nPosValores][ANALITICO_VLRRENDTRIB13]    := (cAliasQry)->(FieldGet(nP_RENT13))
            aAnalitico[nPosValores][ANALITICO_VLRPREVOFICIAL]   := (cAliasQry)->(FieldGet(nP_PREVOF))
            aAnalitico[nPosValores][ANALITICO_VLRPREVOFICIAL13] := (cAliasQry)->(FieldGet(nP_PROF13))
            aAnalitico[nPosValores][ANALITICO_VLRCRMEN]         := (cAliasQry)->(FieldGet(nP_VCRMEN))
            aAnalitico[nPosValores][ANALITICO_VLRCRMEN13]       := (cAliasQry)->(FieldGet(nP_CR13ME))
            aAnalitico[nPosValores][ANALITICO_VLRPARC65]        := (cAliasQry)->(FieldGet(nP_PAIS65))
            aAnalitico[nPosValores][ANALITICO_VLRPARC65DEC]     := (cAliasQry)->(FieldGet(nP_PIS65D))
            aAnalitico[nPosValores][ANALITICO_VLRDIARIAS]       := (cAliasQry)->(FieldGet(nP_VLDIAR))
            aAnalitico[nPosValores][ANALITICO_VLRAJDCUSTO]      := (cAliasQry)->(FieldGet(nP_VLAJUC))
            aAnalitico[nPosValores][ANALITICO_VLRINDRESCTR]     := (cAliasQry)->(FieldGet(nP_VINRES))
            aAnalitico[nPosValores][ANALITICO_VLRABONOPEC]      := (cAliasQry)->(FieldGet(nP_ABONPE))
            aAnalitico[nPosValores][ANALITICO_VLRRENMOLGRV]     := (cAliasQry)->(FieldGet(nP_VLRIMG))
            aAnalitico[nPosValores][ANALITICO_VLRRENMOLGRV13]   := (cAliasQry)->(FieldGet(nP_IMG13))
            aAnalitico[nPosValores][ANALITICO_VLRAUXMOR]        := (cAliasQry)->(FieldGet(nP_VLMORD))
            aAnalitico[nPosValores][ANALITICO_VLRBOLMEDIC]      := (cAliasQry)->(FieldGet(nP_BOLMED))
            aAnalitico[nPosValores][ANALITICO_VLRBOLMEDIC13]    := (cAliasQry)->(FieldGet(nP_BOLM13))
            aAnalitico[nPosValores][ANALITICO_VLRJUROSMORA]     := (cAliasQry)->(FieldGet(nP_JURMOR))
            aAnalitico[nPosValores][ANALITICO_VLRINSEOUTROS]    := (cAliasQry)->(FieldGet(nP_ISEOUT))
            aAnalitico[nPosValores][ANALITICO_CODRECEITA]       := (cAliasQry)->(FieldGet(nP_CRMEN))
            
            aAnalitico[nPosValores][ANALITICO_FORABA]           := "TRIBUT"
            aAnalitico[nPosValores][ANALITICO_ABA]              := "01" 
            aAnalitico[nPosValores][ANALITICO_PERREF]           := ""
            aAnalitico[nPosValores][ANALITICO_ORIGEM]           := "3"
            aAnalitico[nPosValores][ANALITICO_VERSAO]           := (cAliasQry)->(FieldGet(nP_VERSAO))

            (cAliasQry)->(DbSkip())

        EndDo

    Else
        // Log de erro de infraestrutura
        TafConOut( "[ERRO CRÍTICO] Falha ao abrir query na função: " + ProcName() )
    EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GetFiliaisIN
@type           Function
@description    Gera string para SQL (IN) com as filiais da empresa atual

@return         cRet, Character, String formatada: 'M SP 01','M SP 02'

@author         Denis R. de Oliveira
@since          13/01/2026
@version        1.0
/*/
//---------------------------------------------------------------------
Static Function GetFiliaisIN()

    Local cRet      as Character  // String final de retorno
    Local cEmpAtual as Character  // Empresa corrente
    Local aArea     as Array      // Área salva

    cRet        := ""
    cEmpAtual   := cEmpAnt
    aArea       := GetArea()

    // Verifica se a tabela SM0 está realmente aberta antes de tentar usar.
    If Select("SM0") > 0

        // Vamos ler a SM0 para pegar o código REAL que está no banco (M SP 01)
        DbSelectArea("SM0")
        SM0->(DbSetOrder(1)) // M0_CODIGO + M0_CODFIL
        
        If SM0->(DbSeek(cEmpAtual))

            While !SM0->(Eof()) .And. SM0->M0_CODIGO == cEmpAtual

                // Adiciona o código LONGO (M0_CODFIL) que é o que o SQL precisa.      
                If !Empty(cRet)
                    cRet += ","
                EndIf
                
                // Formata com aspas e preserva o conteúdo original do M0_CODFIL
                cRet += "'" + AllTrim(SM0->M0_CODFIL) + "'"
                
                SM0->(DbSkip())
            EndDo

        EndIf

    EndIf

    RestArea(aArea)

Return cRet
