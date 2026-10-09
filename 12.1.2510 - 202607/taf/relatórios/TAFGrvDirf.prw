#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TafGrvDIRF
@type           Function
@description    Realiza a gravacao dos dados da DIRF na tabela intermediaria (T8R).
                Gerencia a transacao, exclusao em lote (Bulk Delete) e insercao.
@author         Denis R de Oliveira
@since          10/11/2025
@version        2.0
@param          aAnalitico, Array,     Dados analiticos para gravacao na T8R.
@param          a1210,      Array,     Dados do cabecalho para posicionamento/exclusao.
@param          cTable,     Character, Tabela alvo (T3P/T2G).
@param          lOk,        Logical,   Flag de sucesso da operacao (referencia).
@param          aIncons,    Array,     Lista de erros/inconsistencias (referencia).
@param          lDeleteAll, Logical,   Indica se deve excluir registros anteriores.
@param          lReproc,    Logical,   Flag indicando reprocessamento.
@param          aFil,       Array,     Array de filiais para exclusao massiva.
@param          cPeriodo,   Character, Periodo de apuracao base.
@return         lOk,        Logical,   Indica se foi gravado com sucesso.
/*/
//---------------------------------------------------------------------
Function TafGrvDIRF( aAnalitico As Array, a1210 As Array, cTable As Character, lOk As Logical, aIncons As Array, lDeleteAll As Logical, lReproc As Logical, aFil As Array, cPeriodo As Character )

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local aArea        As Array
    Local aBatchCPFs   As Array
    Local aBatchIDs    As Array
    Local aT8R         As Array
    Local aT8Rvalue    As Array
    
    Local cCPF         As Character
    Local cFil         As Character
    Local cId          As Character
    Local cKey         As Character
    Local cOrigem      As Character
    Local cPerapur     As Character
    Local cVersao      As Character

    Local nI           As Numeric

    Local oBulkT8R     As Object

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default aAnalitico := {}
    Default a1210      := {}
    Default cTable     := ""
    Default lOk        := .T.
    Default aIncons    := {}
    Default lDeleteAll := .F.
    Default lReproc    := .F.
    Default aFil       := {}
    Default cPeriodo   := ""

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis 
    //-----------------------------------------------------------------------
    aArea        := FWGetArea( cTable )
    aBatchCPFs   := {}
    aBatchIDs    := {}
    aT8R         := {} 
    aT8Rvalue    := {}
    
    cCPF         := ""
    cFil         := ""
    cId          := ""
    cKey         := ""
    cOrigem      := "1"
    cPerapur     := ""
    cVersao      := ""
    
    nI           := 0
    
    oBulkT8R     := Nil 

    //-----------------------------------------------------------------------
    // Validacao Inicial
    //-----------------------------------------------------------------------
    If Len( aAnalitico ) == 0
        Return .F.
    EndIf

    TafConOut( "[TafGrvDIRF] Iniciando gravacao do lote Bulk" )

    //-----------------------------------------------------------------------
    // INICIO DA TRANSACAO E EXCLUSAO MASSIVA (BULK DELETE)
    //-----------------------------------------------------------------------
    Begin Transaction

        If lDeleteAll
            
            DbSelectArea( "T8R" )
            ( "T8R" )->( DbSetOrder( 2 ) )
   
            If lReproc .And. Len( a1210 ) > 0
                
                cFil     := PadR( cValToChar( a1210[1][1] ), TamSx3( "T3P_FILIAL" )[1] )
                cPerapur := PadR( cValToChar( a1210[1][5] ), TamSx3( "T3P_PERAPU" )[1] )

                TafDelDIRF( cFil, "", cPerapur, "", "1", lReproc, aFil, cPeriodo )
                TafDelDIRF( cFil, "", cPerapur, "", "3", lReproc, aFil, cPeriodo )

            Else
                // Extrai a origem dinamicamente do array (Posição 76 informada pela API)
                If Len( a1210[1] ) >= 76 .And. !Empty( a1210[1][76] )
                    cOrigem := a1210[1][76]
                Else
                    // Extrai as chaves de origem baseadas na tabela principal
                    If cTable == "T3P"
                        cOrigem := "1" // S-1210
                    ElseIf cTable == "T2G"
                        cOrigem := "3" // S-5002
                    EndIf
                EndIf

                cFil     := PadR( cValToChar( a1210[1][1] ), TamSx3( "T3P_FILIAL" )[1] )
                cPerapur := PadR( cValToChar( a1210[1][5] ), TamSx3( "T3P_PERAPU" )[1] )

                // Prepara os arrays com todos os CPFs e IDs do Lote para a clausula IN
                For nI := 1 To Len( a1210 )
                    aAdd( aBatchIDs,  PadR( cValToChar( a1210[nI][2] ), TamSx3( "T3P_ID" )[1] ) )
                    aAdd( aBatchCPFs, PadR( cValToChar( a1210[nI][4] ), TamSx3( "T3P_CPF" )[1] ) )
                Next nI
                        
                // Executa a exclusao de todas as linhas do lote em UMA unica chamada
                TafDelDIRF( cFil, aBatchIDs, cPerapur, aBatchCPFs, cOrigem, .F., {}, "" )
            EndIf
            
        EndIf
        
        //-----------------------------------------------------------------------
        // DEFINICAO DA ESTRUTURA PARA INSERCAO MASSIVA (FWBULK)
        //-----------------------------------------------------------------------
        aT8R :={{"T8R_FILIAL" },;
                {"T8R_ID    " },;
                {"T8R_VERSAO" },;
                {"T8R_PERAPU" },;
                {"T8R_CPF   " },;
                {"T8R_NOME  " },;
                {"T8R_EVENTO" },;
                {"T8R_CODREC" },;
                {"T8R_SEQUEN" },;
                {"T8R_VLRTRI" },;
                {"T8R_VRTR13" },;
                {"T8R_VLRPRE" },;
                {"T8R_VPRE13" },;
                {"T8R_VLIRRF" },;
                {"T8R_IRRF13" },;
                {"T8R_VLRISE" },;
                {"T8R_VLRI13" },;
                {"T8R_VLRDIA" },;
                {"T8R_VLRAJU" },;
                {"T8R_VLRRSC" },;
                {"T8R_VLRABN" },;
                {"T8R_VLRMLG" },;
                {"T8R_VMLG13" },;
                {"T8R_VLRAXM" },;
                {"T8R_VLBMED" },;
                {"T8R_BMED13" },;
                {"T8R_VLRMOR" },;
                {"T8R_VLRISO" },;
                {"T8R_TPREND" },;
                {"T8R_CPFDEP" },;
                {"T8R_VLRDED" },;
                {"T8R_TPRPAL" },;
                {"T8R_CPFDPA" },;
                {"T8R_VLRPAL" },;
                {"T8R_TPPREV" },;
                {"T8R_CNPJPC" },;
                {"T8R_VLDEPC" },;
                {"T8R_VLPC13" },;
                {"T8R_VLPCSP" },;
                {"T8R_PCVP13" },;
                {"T8R_TPPROC" },;
                {"T8R_NRPROC" },;
                {"T8R_CODSUP" },;
                {"T8R_INDAPU" },;
                {"T8R_VLRRTC" },;
                {"T8R_DEPJUD" },;
                {"T8R_CANOCA" },;
                {"T8R_CANOAN" },;
                {"T8R_RENDSU" },;
                {"T8R_INDDED" },;
                {"T8R_DEDSUS" },;
                {"T8R_CNPJEC" },;
                {"T8R_VLCONT" },;
                {"T8R_CPFSUS" },;
                {"T8R_DEPSUS" },;
                {"T8R_CNPJOP" },;
                {"T8R_REGANS" },;
                {"T8R_VLRPLS" },;
                {"T8R_CPFDPS" },;
                {"T8R_VLRDPS" },;
                {"T8R_ORIREE" },;
                {"T8R_CNPJPS" },;
                {"T8R_ANSRRE" },;
                {"T8R_INSCRE" },;
                {"T8R_NRPSRE" },;
                {"T8R_VLREEM" },;
                {"T8R_VLRANT" },;
                {"T8R_CPFRED" },;
                {"T8R_DINSCR" },;
                {"T8R_DNRPSR" },;
                {"T8R_DVLRRE" },;
                {"T8R_DVLRAN" },;
                {"T8R_FORABA" },;
                {"T8R_ABAFOL" },;
                {"T8R_PERREF" },;
                {"T8R_ORIGEM" },;
                {"T8R_RELACO" }}        

        oBulkT8R := FWBulk():New( RetSQLName( "T8R" ) )            
        oBulkT8R:SetFields( aT8R )

        For nI := 1 To Len( aAnalitico ) 
            
            aT8Rvalue := {}
            
            // Preenchimento dos valores do registro
            aadd( aT8Rvalue /*"T8R_FILIAL"*/, aAnalitico[nI][1])
            aadd( aT8Rvalue /*"T8R_ID     */, aAnalitico[nI][2])
            aadd( aT8Rvalue /*"T8R_VERSAO"*/, aAnalitico[nI][3])
            aadd( aT8Rvalue /*"T8R_PERAPU */, aAnalitico[nI][4])
            aadd( aT8Rvalue /*"T8R_CPF    */, aAnalitico[nI][5])
            aadd( aT8Rvalue /*"T8R_NOME  "*/, aAnalitico[nI][6])
            aadd( aT8Rvalue /*"T8R_EVENTO"*/, aAnalitico[nI][7])
            aadd( aT8Rvalue /*"T8R_CODREC"*/, aAnalitico[nI][8])
            aadd( aT8Rvalue /*"T8R_SEQUEN"*/, aAnalitico[nI][9])
            aadd( aT8Rvalue /*"T8R_VLRTRI"*/, aAnalitico[nI][10])
            aadd( aT8Rvalue /*"T8R_VRTR13"*/, aAnalitico[nI][11])
            aadd( aT8Rvalue /*"T8R_VLRPRE"*/, aAnalitico[nI][12])
            aadd( aT8Rvalue /*"T8R_VPRE13"*/, aAnalitico[nI][13])
            aadd( aT8Rvalue /*"T8R_VLIRRF"*/, aAnalitico[nI][14])
            aadd( aT8Rvalue /*"T8R_IRRF13"*/, aAnalitico[nI][15])
            aadd( aT8Rvalue /*"T8R_VLRISE"*/, aAnalitico[nI][16])
            aadd( aT8Rvalue /*"T8R_VLRI13"*/, aAnalitico[nI][17])
            aadd( aT8Rvalue /*"T8R_VLRDIA"*/, aAnalitico[nI][18])
            aadd( aT8Rvalue /*"T8R_VLRAJU"*/, aAnalitico[nI][19])
            aadd( aT8Rvalue /*"T8R_VLRRSC"*/, aAnalitico[nI][20])
            aadd( aT8Rvalue /*"T8R_VLRABN"*/, aAnalitico[nI][21])
            aadd( aT8Rvalue /*"T8R_VLRMLG"*/, aAnalitico[nI][22])
            aadd( aT8Rvalue /*"T8R_VMLG13"*/, aAnalitico[nI][23])
            aadd( aT8Rvalue /*"T8R_VLRAXM"*/, aAnalitico[nI][24])
            aadd( aT8Rvalue /*"T8R_VLBMED"*/, aAnalitico[nI][25])
            aadd( aT8Rvalue /*"T8R_BMED13"*/, aAnalitico[nI][26])
            aadd( aT8Rvalue /*"T8R_VLRMOR"*/, aAnalitico[nI][27])
            aadd( aT8Rvalue /*"T8R_VLRISO"*/, aAnalitico[nI][28])
            aadd( aT8Rvalue /*"T8R_TPREND"*/, aAnalitico[nI][29])
            aadd( aT8Rvalue /*"T8R_CPFDEP"*/, aAnalitico[nI][30])
            aadd( aT8Rvalue /*"T8R_VLRDED"*/, aAnalitico[nI][31])
            aadd( aT8Rvalue /*"T8R_TPRPAL"*/, aAnalitico[nI][32])
            aadd( aT8Rvalue /*"T8R_CPFDPA"*/, aAnalitico[nI][33])
            aadd( aT8Rvalue /*"T8R_VLRPAL"*/, aAnalitico[nI][34])
            aadd( aT8Rvalue /*"T8R_TPPREV"*/, aAnalitico[nI][35])
            aadd( aT8Rvalue /*"T8R_CNPJPC"*/, aAnalitico[nI][36])
            aadd( aT8Rvalue /*"T8R_VLDEPC"*/, aAnalitico[nI][37])
            aadd( aT8Rvalue /*"T8R_VLPC13"*/, aAnalitico[nI][38])
            aadd( aT8Rvalue /*"T8R_VLPCSP"*/, aAnalitico[nI][39])
            aadd( aT8Rvalue /*"T8R_PCVP13"*/, aAnalitico[nI][40])
            aadd( aT8Rvalue /*"T8R_TPPROC"*/, aAnalitico[nI][41])
            aadd( aT8Rvalue /*"T8R_NRPROC"*/, aAnalitico[nI][42])
            aadd( aT8Rvalue /*"T8R_CODSUP"*/, aAnalitico[nI][43])
            aadd( aT8Rvalue /*"T8R_INDAPU"*/, aAnalitico[nI][44])
            aadd( aT8Rvalue /*"T8R_VLRRTC"*/, aAnalitico[nI][45])
            aadd( aT8Rvalue /*"T8R_DEPJUD"*/, aAnalitico[nI][46])
            aadd( aT8Rvalue /*"T8R_CANOCA"*/, aAnalitico[nI][47])
            aadd( aT8Rvalue /*"T8R_CANOAN"*/, aAnalitico[nI][48])
            aadd( aT8Rvalue /*"T8R_RENDSU"*/, aAnalitico[nI][49])
            aadd( aT8Rvalue /*"T8R_INDDED"*/, aAnalitico[nI][50])
            aadd( aT8Rvalue /*"T8R_DEDSUS"*/, aAnalitico[nI][51])
            aadd( aT8Rvalue /*"T8R_CNPJEC"*/, aAnalitico[nI][52])
            aadd( aT8Rvalue /*"T8R_VLCONT"*/, aAnalitico[nI][53])
            aadd( aT8Rvalue /*"T8R_CPFSUS"*/, aAnalitico[nI][54])
            aadd( aT8Rvalue /*"T8R_DEPSUS"*/, aAnalitico[nI][55])
            aadd( aT8Rvalue /*"T8R_CNPJOP"*/, aAnalitico[nI][56])
            aadd( aT8Rvalue /*"T8R_REGANS"*/, aAnalitico[nI][57])
            aadd( aT8Rvalue /*"T8R_VLRPLS"*/, aAnalitico[nI][58])
            aadd( aT8Rvalue /*"T8R_CPFDPS"*/, aAnalitico[nI][59])
            aadd( aT8Rvalue /*"T8R_VLRDPS"*/, aAnalitico[nI][60])
            aadd( aT8Rvalue /*"T8R_ORIREE"*/, aAnalitico[nI][61])
            aadd( aT8Rvalue /*"T8R_CNPJPS"*/, aAnalitico[nI][62])
            aadd( aT8Rvalue /*"T8R_ANSRRE"*/, aAnalitico[nI][63])
            aadd( aT8Rvalue /*"T8R_INSCRE"*/, aAnalitico[nI][64])
            aadd( aT8Rvalue /*"T8R_NRPSRE"*/, aAnalitico[nI][65])
            aadd( aT8Rvalue /*"T8R_VLREEM"*/, aAnalitico[nI][66])
            aadd( aT8Rvalue /*"T8R_VLRANT"*/, aAnalitico[nI][67])
            aadd( aT8Rvalue /*"T8R_CPFRED"*/, aAnalitico[nI][68])
            aadd( aT8Rvalue /*"T8R_DINSCR"*/, aAnalitico[nI][69])
            aadd( aT8Rvalue /*"T8R_DNRPSR"*/, aAnalitico[nI][70])
            aadd( aT8Rvalue /*"T8R_DVLRRE"*/, aAnalitico[nI][71])
            aadd( aT8Rvalue /*"T8R_DVLRAN"*/, aAnalitico[nI][72])
            aadd( aT8Rvalue /*"T8R_FORABA"*/, aAnalitico[nI][73])
            aadd( aT8Rvalue /*"T8R_ABAFOL"*/, aAnalitico[nI][74])
            aadd( aT8Rvalue /*"T8R_PERREF"*/, aAnalitico[nI][75])
            aadd( aT8Rvalue /*"T8R_ORIGEM"*/, aAnalitico[nI][76])
            aadd( aT8Rvalue /*"T8R_RELACO"*/, aAnalitico[nI][77])

            oBulkT8R:AddData( aT8Rvalue )
            
        Next nI

        // Dispara o buffer para o banco de dados
        oBulkT8R:Flush()        
        
        // Verificacao de integridade
        If !Empty( oBulkT8R:GetError() )
            TafConOut( "TAF_ROLLBACK: Erro na gravacao do lote Bulk. " + oBulkT8R:GetError() )
        EndIf

        // Destruicao limpa do objeto de Bulk
        If oBulkT8R != Nil
            oBulkT8R:Close()
            oBulkT8R:Destroy()
            FreeObj( oBulkT8R )
            oBulkT8R := Nil
        EndIf
            
        //-----------------------------------------------------------------------
        // ATUALIZACAO DE FLAGS (CHKDIR) DA TABELA PRINCIPAL
        //-----------------------------------------------------------------------
        TafConOut( "[TafGrvDIRF] Atualizando flag CHKDIR..." )  
        
        DbSelectArea( cTable )
        ( cTable )->( DbSetOrder( 1 ) )

        For nI := 1 To Len( a1210 ) 

            cFil    := a1210[nI][1]
            cId     := a1210[nI][2]
            cVersao := a1210[nI][3]

            If Len( a1210[nI] ) >= 76
                cOrigem := a1210[nI][76]
            Else
                If cTable == "T3P"
                    cOrigem := "1" 
                ElseIf cTable == "T2G"
                    cOrigem := "3" 
                EndIf
            EndIf

            cKey := PadR( cValToChar( cFil ),    TamSx3( cTable + "_FILIAL" )[1] ) + ;
                    PadR( cValToChar( cId ),     TamSx3( cTable + "_ID" )[1] ) + ;
                    PadR( cValToChar( cVersao ), TamSx3( cTable + "_VERSAO" )[1] )

            // Ignora origem de integracao (2) e trava a linha para atualizar a flag
            If cOrigem != "2" .And. ( cTable )->( DbSeek( cKey ) )                    
                If RecLock( cTable, .F. )
                    ( cTable )->&( cTable + "_CHKDIR" ) := .T.
                    ( cTable )->( MsUnlock() )
                EndIf     
            EndIf

        Next nI

    // Finaliza transacao de banco (Commit implicito)
    End Transaction

    TafConOut( "[TafGrvDIRF] Processamento concluido" )

    // Restaura ambiente original
    FWRestArea( aArea )

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInitDIRF
@type           function
@description    Inicializa o Job responsável pela coleta de dados para o relatório da DIRF.
                Dispara a função "TAFColDirf" em background utilizando o contexto atual.

@return         Nil

@author         Alexandre de Lima Santos / Denis R. de Oliveira
@since          11/11/2025
@version        1.0
/*/
//-------------------------------------------------------------------
Function TAFInitDIRF()

    Static lMsgShowT8R  as Logical

	Local cEnv          as character
    Local cEmp          as character
    Local cFil          as character 
    Local cLinkUrl      As Character
    Local cMsgDic       As Character
    Local lTafColDirf   as logical
    Local nTamT8R       As Numeric

    cEnv        := GetEnvServer()
    cEmp        := FWGrpCompany()
    cFil        := FWCodFil()
    cLinkUrl    := "https://tdn.totvs.com/display/TAF/DSERTAF1-39952+DT+-+Duplicidade+planos+de+saude+-+Relatorio+do+s-5002+taf+do+futuro"
    cMsgDic     := ""
    nTamT8R     := 0

    //=========================================================================
    // VALIDAÇÃO DE TAMANHO DO DICIONÁRIO
    //=========================================================================
    nTamT8R := GetSX3Cache("T8R_RELACO", "X3_TAMANHO")

    If nTamT8R < 254
        
        // Só exibe a mensagem/log se for a PRIMEIRA vez na sessão
        If !lMsgShowT8R
            
            lMsgShowT8R := .T. // Marca que já avisou o usuário
            
            cMsgDic := "O campo T8R_RELACO possui tamanho atual de " + cValToChar(nTamT8R) + " caracteres, " + ;
                       "mas o exigido pela DIRF é de 254." + CRLF + CRLF + ;
                       "Acao Necessaria:" + CRLF + ;
                       " - Atualize o dicionario de dados (SX3)." + CRLF + ;
                       " - Isso evita falhas de gravacao e inconsistencias graves."

            If IsBlind()
            
                TafConOut( "[TAFInitDIRF] AVISO: Dicionario T8R_RELACO desatualizado. A geracao da DIRF sera IGNORADA neste lote." )
            
            Else
                cMsgDic += CRLF + CRLF + "Deseja abrir a documentacao oficial no seu navegador agora?"
                
                If FWAlertNoYes(cMsgDic, "TAF - Validacao de Dicionario")
                    ShellExecute("open", cLinkUrl, "", "", 1)
                EndIf

                FWAlertInfo("ATENCAO: A geracao da DIRF foi IGNORADA por seguranca devido ao dicionario." + CRLF + ;
                            "O restante dos processos (ex: calculo da Folha) continuara normalmente.", ;
                            "DIRF Ignorada")
            EndIf
        EndIf

        // Retorna .T. silenciosamente para a rotina pai não ser interrompida.
        Return .T. 
    EndIf

    // Recebe o parâmetro de processamento da DIRF (Padrão: Ativo)
    lTafColDirf := GetNewPar( "MV_EXCDIRF", .T. )

    // Verifica se o processamento do relatório da DIRF está ativo
    If lTafColDirf

        //Exibe mensagem de execução
        TAFConOut("[TAFInitDIRF] Iniciando coleta do Relatório da DIRF (MV_EXCDIRF=.T.)")

        //Inicia a coleta para o relatório da DIRF
        StartJob("TAFColDirf", cEnv, .F., cEmp, cFil ) 

    Else
        // Log para saber que a rotina passou por aqui, mas foi abortada propositalmente
        TAFConOut("[TAFInitDIRF] Coleta do Relatório da DIRF desativada (MV_EXCDIRF=.F.)")
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDelDIRF
@type           Function
@description    Exclusao inteligente (Bulk e Individual) utilizando IN para Arrays
                na tabela intermediaria T8R via Execucao Nativa de Statement.
@author         Denis R de Oliveira
@since          17/12/2025
@version        1.0
@param          cFil,     Character, Filial do registro
@param          xId,      Variant,   ID unico do registro (String) ou Array de IDs
@param          cPerapur, Character, Periodo de apuracao
@param          xCPF,     Variant,   CPF do trabalhador (String) ou Array de CPFs
@param          cOrigem,  Character, "1" = S-1210, "2" = Folha, "3" = S-5002
@param          lReproc,  Logical,   Flag indicando reprocessamento em massa
@param          aFil,     Array,     Array de filiais para exclusao massiva
@param          cPeriodo, Character, Periodo de apuracao base
@return         lRet,     Logical,   .T. se executado com sucesso
/*/
//-------------------------------------------------------------------
Function TafDelDIRF( cFil As Character, xId As Variant, cPerapur As Character, xCPF As Variant, cOrigem As Character, lReproc As Logical, aFil As Array, cPeriodo As Character )

    //-----------------------------------------------------------------------
    // Declaracao de Variaveis Locais
    //-----------------------------------------------------------------------
    Local cSql      As Character
    Local cT8R      As Character
    Local lRet      As Logical
    Local oStmt     As Object
    Local cLogMsg   As Character

    //-----------------------------------------------------------------------
    // Inicializacao de Parametros (Defaults)
    //-----------------------------------------------------------------------
    Default cFil     := ""
    Default cPerapur := ""
    Default cOrigem  := "1"
    Default lReproc  := .F.
    Default aFil     := {}
    Default cPeriodo := ""

    //-----------------------------------------------------------------------
    // Inicializacao de Variaveis
    //-----------------------------------------------------------------------
    cSql    := ""
    cT8R    := RetSQLName( "T8R" )
    lRet    := .T.
    oStmt   := Nil
    cLogMsg := ""

    //-----------------------------------------------------------------------
    // EXCLUSAO EXCLUSIVA PARA ORIGEM 3 (RET)
    //-----------------------------------------------------------------------
    If cOrigem == "3"

        //-------------------------------------------------------------------
        // Construcao Dinamica da Query (S-5002)
        //-------------------------------------------------------------------
        cSql := " DELETE FROM " + cT8R + " "
        
        // Define escopo de exclusao da Filial
        If lReproc .And. Len( aFil ) > 0
            cSql += " WHERE T8R_FILIAL IN (?) "
        Else
            cSql += " WHERE T8R_FILIAL = ? "
        EndIf 
        
        cSql += "   AND T8R_PERAPU = ? "
        
        // Seletividade por CPF: Ignorado em reprocessamentos totais
        If !lReproc
            If ValType( xCPF ) == "A"
                cSql += "   AND T8R_CPF IN (?) "
            Else
                cSql += "   AND T8R_CPF = ? "
            EndIf
        EndIf
        
        cSql += "   AND T8R_EVENTO = 'S-5002' "

        // A Classe que apenas prepara e formata a String contra SQL Injection
        oStmt := FWPreparedStatement():New( cSql )
        
        //-------------------------------------------------------------------
        // Injecao Segura dos Parametros (Bind Variables)
        //-------------------------------------------------------------------
        If lReproc .And. Len( aFil ) > 0
            oStmt:SetIn( 1, aFil )
            // Ajuste do periodo anual vs mensal
            oStmt:SetString( 2, IIf( Len( AllTrim( cPeriodo ) ) == 4, cPeriodo, cPerapur ) )
        Else
            oStmt:SetString( 1, cFil )
            oStmt:SetString( 2, cPerapur )
            
            // Injeta a variavel (String ou Array) apenas se o filtro existir na Query
            If !lReproc
                If ValType( xCPF ) == "A"
                    oStmt:SetIn( 3, xCPF )
                Else
                    oStmt:SetString( 3, cValToChar( xCPF ) )
                EndIf
            EndIf
        EndIf

        //-------------------------------------------------------------------
        // Execucao da Transacao
        //-------------------------------------------------------------------
        cSql := oStmt:GetFixQuery()
        lRet := ( TCSQLExec( cSql ) >= 0 )

        // Limpeza da Memoria
        If oStmt != Nil
            oStmt:Destroy()
            FreeObj( oStmt )
            oStmt := Nil
        EndIf

    //-----------------------------------------------------------------------
    // BLOCO 2: EXCLUSAO PRINCIPAL (ORIGEM 1 e 2)
    //-----------------------------------------------------------------------
    Else    

        //-------------------------------------------------------------------
        // Construcao Dinamica da Query Principal (S-1210)
        //-------------------------------------------------------------------
        cSql := " DELETE FROM " + cT8R + " "
        
        // Define escopo de exclusao da Filial
        If lReproc .And. Len( aFil ) > 0
            cSql += " WHERE T8R_FILIAL IN (?) "
        Else
            cSql += " WHERE T8R_FILIAL = ? "
        EndIf 
        
        cSql += "   AND T8R_PERAPU = ? "
        
        // Seletividade por CPF: Ignorado em reprocessamentos totais
        If !lReproc
            If ValType( xCPF ) == "A"
                cSql += "   AND T8R_CPF IN (?) "
            Else
                cSql += "   AND T8R_CPF = ? "
            EndIf
        EndIf

        cSql += "   AND T8R_ORIGEM = ? "  

        // Garante exclusao pontual da chave para a folha principal
        If cOrigem == "1" .And. !lReproc
            If ValType( xId ) == "A"
                cSql += " AND T8R_ID IN (?) "
            Else
                cSql += " AND T8R_ID = ? "
            EndIf
        EndIf

        // A Classe que apenas prepara e formata a String contra SQL Injection
        oStmt := FWPreparedStatement():New( cSql )
        
        //-------------------------------------------------------------------
        // Injecao Segura dos Parametros (Bind Variables)
        //-------------------------------------------------------------------
        If lReproc .And. Len( aFil ) > 0
            oStmt:SetIn( 1, aFil )
        Else
            oStmt:SetString( 1, cFil )
        EndIf
        
        oStmt:SetString( 2, cPerapur )
        
        If !lReproc
            // O Filtro CPF (In ou String) consome o Index 3
            If ValType( xCPF ) == "A"
                oStmt:SetIn( 3, xCPF )
            Else
                oStmt:SetString( 3, cValToChar( xCPF ) )
            EndIf
            
            // Origem assume o Index 4
            oStmt:SetString( 4, cOrigem ) 
        Else 
            // Como CPF nao entrou no lReproc, a Origem 'cai' para o Index 3
            oStmt:SetString( 3, cOrigem ) 
        EndIf 

        If cOrigem == "1" .And. !lReproc
            // O Filtro de ID (In ou String) consome sempre o Index 5 
            // (visto que o lReproc eh .F., o Index 4 ja foi ocupado pela Origem)
            If ValType( xId ) == "A"
                oStmt:SetIn( 5, xId )
            Else
                oStmt:SetString( 5, cValToChar( xId ) ) 
            EndIf
        EndIf

        //-------------------------------------------------------------------
        // Execucao da Transacao
        //-------------------------------------------------------------------
        cSql := oStmt:GetFixQuery()
        lRet := ( TCSQLExec( cSql ) >= 0 )

        // Limpeza da Memoria
        If oStmt != Nil
            oStmt:Destroy()
            FreeObj( oStmt )
            oStmt := Nil
        EndIf
        
    EndIf

    //-----------------------------------------------------------------------
    // AVALIACAO DE SUCESSO OU FALHA (O(1))
    //-----------------------------------------------------------------------
    cLogMsg := IIf( lRet, "OK | TafDelDIRF | Exclusao Processada | Origem: " + cOrigem, "ERRO | TafDelDIRF (Origem " + cOrigem + "): " + TCSQLError() )
    
    // Dispara a mensagem (sucesso ou erro)
    TafConOut( cLogMsg )

Return lRet



