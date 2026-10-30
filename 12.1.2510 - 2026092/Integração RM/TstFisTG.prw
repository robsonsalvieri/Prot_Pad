#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'MATXDEF.CH'
#INCLUDE 'TBICONN.CH' // Inclusao obrigatoria para o uso do PREPARE ENVIRONMENT

/*/{Protheus.doc} u_TstFisTG
Exemplo de simulacao do motor fiscal para teste do Configurador de Tributos,
com controle de abertura e fechamento seguro do ambiente (RPC).
/*/
User Function TstFisTG()
    // ---------------------------------------------------------
    // DECLARACOES LOCAIS (Sempre no topo da funcao)
    // ---------------------------------------------------------
    Local aDadosImp := {}
    Local cMsg      := ""
    Local nI        := 0
    Local nItem     := 1
    
    // Variaveis de teste (Substitua por dados reais do seu ambiente)
    Local cCliente  := PadR("SP0001", TamSx3("A1_COD")[1])
    Local cLoja     := PadR("01", TamSx3("A1_LOJA")[1])
    Local cProduto  := PadR("PA0000000000000000000000000001", TamSx3("B1_COD")[1])
    Local cTes      := PadR("516", TamSx3("F4_CODIGO")[1])
    Local nQtde     := 1
    Local nPrcUni   := 100.00

    // Variavel de controle: Verifica se o ambiente ja esta aberto
    Local lAbreEnv  := Type("cEmpAnt") == "U" .Or. Select("SX2") == 0

    // ---------------------------------------------------------
    // 1. PREPARACAO DO AMBIENTE
    // ---------------------------------------------------------
    // Prepara o ambiente apenas se ele nao existir
    If lAbreEnv
        PREPARE ENVIRONMENT EMPRESA "T1" FILIAL "XIFIS26" MODULO "FIS" TABLES "SF2","SD2","SA1","SA2","SB1","SB2","SF4","SED","SE1"
    EndIf

    // ---------------------------------------------------------
    // 2. SIMULACAO DO MOTOR FISCAL
    // ---------------------------------------------------------
    // Inicializa o motor fiscal (MaFisIni)
    MaFisIni(cCliente,; // 1-Cod. Cli/For
             cLoja,;    // 2-Lj do Cli/For
             "C",;      // 3-C:Cliente , F:Fornecedor
             "N",;      // 4-Tp NF( "N","D","B","C","P","I" )
             "F",;      // 5-Tp do Cli/For (Ex: F=Consumidor Final, R=Revendedor)
             Nil, Nil, Nil, "SB1", "MATA461", Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,;
             .T.)       // 33-Flag lCalcTG: ATIVA OS TRIBUTOS GENERICOS

    // Adiciona o Item para o calculo (MaFisAdd)
    MaFisAdd(cProduto,; // 1-Codigo do Produto
             cTes,;     // 2-Codigo do TES
             nQtde,;    // 3-Quantidade
             nPrcUni)   // 4-Preco Unitario

    // ---------------------------------------------------------
    // 3. CAPTURA E EXIBICAO DOS RESULTADOS
    // ---------------------------------------------------------
    aDadosImp := MaFisRet(nItem, "IT_TRIBGEN")

    If ValType(aDadosImp) == "A" .And. Len(aDadosImp) > 0
        For nI := 1 To Len(aDadosImp)
            cMsg += "Imposto: " + aDadosImp[nI][TG_IT_SIGLA] + CRLF
            cMsg += "Base: "    + cValToChar(aDadosImp[nI][TG_IT_BASE]) + CRLF
            cMsg += "Aliquota: "+ cValToChar(aDadosImp[nI][TG_IT_ALIQUOTA]) + CRLF
            cMsg += "Valor: "   + cValToChar(aDadosImp[nI][TG_IT_VALOR]) + CRLF
            cMsg += Replicate("-", 30) + CRLF
        Next nI
        
        FwAlertInfo(cMsg, "Tributos Genericos Simulados")
    Else
        FwAlertError("Nenhum tributo generico foi calculado para a combinacao informada.", "Atencao")
    EndIf

    // ---------------------------------------------------------
    // 4. ENCERRAMENTO E LIMPEZA
    // ---------------------------------------------------------
    // Limpa a memoria estatica do motor fiscal (Obrigatorio para nao dar "sujeira" na proxima execucao)
    MaFisEnd()

    // Encerra o ambiente se foi esta mesma rotina que o abriu
    If lAbreEnv
        RESET ENVIRONMENT
    EndIf

Return
