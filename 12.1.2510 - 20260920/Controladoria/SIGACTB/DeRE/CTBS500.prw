#include "totvs.ch"

//===================================================================
// ATENCAO - NUMERO DE PROCESSO PROVISORIO (41)
// O numero de processo 41 esta sendo usado PROVISORIAMENTE (decisao
// do usuario). Esse numero JA pertence ao processo padrao do Ativo
// Fixo (ATFA070 - descalculo de depreciacao). Antes de compilar/
// instalar num ambiente que contenha o processo 41 padrao, TROQUE:
//   - o #define CSP_PROC abaixo, e
//   - o sufixo numerico das funcoes de callback (EngSPS41Signature,
//     EngPre41Compile, EngPos41Compile, EngSPS41Delete),
// por um numero de processo DEDICADO ao D-1101, para nao sobrescrever
// os callbacks do processo 41 do Ativo Fixo.
//===================================================================

// Nome logico da stored procedure (CTBS500.sql) e numero do processo.
#define CSP_NAME  "CTBS500"
#define CSP_PROC  "41"
// Assinatura de versao da procedure (deve casar com EngSPS41Signature).
// "002": CODTRIB passou a ser derivado da amarracao QLT (removido o
//        parametro de CODTRIB pseudo "000") e o Saldo Liquido passou a
//        ser calculado pelo movimento bruto.
// "003": movimento bruto passou a vir da CQ0 (saldo mensal, ultimo dia
//        do mes) e os estornos apenas da CT2; novo parametro de data da
//        ultima apuracao (@IN_dUltApur) para expurgo do lote de apuracao.
// "004": natureza do vApur (natVApur) passou a vir de QLT_NATCTA (D/C),
//        com fallback pela predominancia do movimento quando V/invalida.
// "005": mapeamento CRUZADO do estorno (partida reversa) - o estorno
//        lancado a credito reverte um debito e alimenta vAjusteDebt; o
//        estorno lancado a debito reverte um credito e alimenta
//        vAjusteCred. Alinha o de-para ao duplo proposito do ajuste no
//        Manual (o ajuste de uma posicao compoe a posicao oposta no
//        vApur) e faz o CONFERIR_VAPUR anular o estorno reverso puro.
// "006": natureza do vApur (natVApur) passou a ser determinada pelo
//        PREFIXO do CODTRIB (QLT_CODTRB), conforme regra_natVapur.txt
//        (2/3->C, 4->D, 1->prefixos devedores->D senao C), substituindo
//        a derivacao por QLT_NATCTA/predominancia do movimento.
#define CSP_SIGN  "001"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS500
    Executor da apuracao do Balancete da DeRE (evento D-1101 /
    evtBalancete) via stored procedure CTBS500.

    Fonte "a parte", sem interface (ParamBox/Help): recebe os
    parametros por argumento e executa a procedure que apura os
    movimentos da CT2 e grava o resultado na tabela QLU. Destinado a
    ser consumido por outro modulo (orquestrador).

    Fluxo:
      1. Valida o periodo (AAAA-MM) e monta o intervalo do mes.
      2. Garante a instalacao do pacote de procedures (CTBInstPRC) e
         resolve o nome fisico da SP (GetSPName), conferindo a
         assinatura com ExistProc.
      3. Executa a procedure via TCSPExec, passando os parametros de
         entrada; o resultado (OUT_RESULT) volta em aResult[1].

    @author totvs
    @since 17/09/2026
    @version P12.1.2510

    @param cFilEnv, character, filial a apurar; vazio usa a logada
    @param cPerApur, character, periodo de apuracao no formato AAAA-MM
    @param cMoeda, character, moeda dos movimentos (CT2_MOEDLC); vazio
    assume "01"
    @param cTpSald, character, tipo de saldo (CT2_TPSALD); vazio assume
    "01"
    @param dUltApur, date, data da ultima apuracao/fechamento. Quando
    informada, a procedure expurga os lancamentos de apuracao dessa
    data: na CQ0 os registros com CQ0_DTLP = dUltApur e CQ0_LP = "Z";
    na CT2 os registros com CT2_DTLP = dUltApur. Vazio desliga o
    expurgo.

    @return logical, .T. quando a procedure retornou sucesso
    (OUT_RESULT = "1"); .F. em caso de parametro invalido, procedure
    indisponivel ou falha na execucao
/*/
//-------------------------------------------------------------------
Function CTBS500(cFilEnv, cPerApur, cMoeda, cTpSald, dUltApur)

    Local lRet     := .F. as Logical
    Local cFilProc := "" as Character
    Local cSP      := "" as Character
    Local dIniPer  := CToD("") as Date
    Local dFimPer  := CToD("") as Date
    Local cUltApur := "" as Character
    Local aResult  := {} as Array

    Default cFilEnv  := ""
    Default cPerApur := ""
    Default cMoeda   := "01"
    Default cTpSald  := "01"
    Default dUltApur := CToD("")

    cFilEnv  := AllTrim(cFilEnv)
    cPerApur := AllTrim(cPerApur)

    If Empty(cMoeda)
        cMoeda := "01"
    EndIf
    If Empty(cTpSald)
        cTpSald := "01"
    EndIf

    // Data da ultima apuracao para o expurgo. Vazia vira " " (o SQL
    // trata a condicao como neutra, sem expurgar nada).
    If Empty(dUltApur)
        cUltApur := " "
    Else
        cUltApur := DToS(dUltApur)
    EndIf

    // Filial base: vazio usa a logada.
    If Empty(cFilEnv)
        cFilProc := cFilAnt
    Else
        cFilProc := cFilEnv
    EndIf

    // Valida o periodo e monta o intervalo do mes (1o e ultimo dia).
    If !CTBS500Per(cPerApur, @dIniPer, @dFimPer)
        FWLogMsg("ERROR", , "CTBS500", , , "0000", ;
            "Periodo invalido (esperado AAAA-MM): " + cPerApur, 0, 0, , )
        Return .F.
    EndIf

    // Garante o pacote de procedures instalado e resolve o nome fisico.
    If FindFunction("CTBInstPRC")
        CTBInstPRC(CSP_PROC)
    EndIf

    cSP := GetSPName(CSP_NAME, CSP_PROC)

    If !ExistProc(cSP, CSP_SIGN)
        FWLogMsg("ERROR", , "CTBS500", , , "0000", ;
            "Stored procedure indisponivel ou assinatura divergente: " + cSP, 0, 0, , )
        Return .F.
    EndIf

    // Executa a procedure. A ordem dos parametros casa com a
    // assinatura de CTBS500.sql; o OUT_RESULT volta em aResult[1].
    // O CODTRIB nao e mais parametro: a procedure o deriva da QLT.
    // O movimento bruto vem da CQ0 e os estornos da CT2; cUltApur
    // controla o expurgo do lote de apuracao.
    aResult := TCSPExec( xProcedures(cSP), ;
                         cFilProc, ;
                         cPerApur, ;
                         DToS(dIniPer), ;
                         DToS(dFimPer), ;
                         cMoeda, ;
                         cTpSald, ;
                         cUltApur, ;
                         DToS(Date()), ;
                         Time() )

    lRet := ( !Empty(aResult) .And. aResult[1] == "1" )

    If !lRet
        FWLogMsg("ERROR", , "CTBS500", , , "0000", ;
            "Falha na execucao da procedure " + cSP + " para o periodo " + cPerApur, 0, 0, , )
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS500Per
    Valida o periodo no formato AAAA-MM (ano de 4 digitos, separador
    "-" e mes entre 01 e 12) e devolve, por referencia, o primeiro e o
    ultimo dia do mes correspondente.

    @author totvs
    @since 17/09/2026
    @version P12.1.2510

    @param cPerApur, character, periodo a validar (AAAA-MM)
    @param dIniPer, date, primeiro dia do mes (por referencia)
    @param dFimPer, date, ultimo dia do mes (por referencia)

    @return logical, .T. quando o periodo e valido
/*/
//-------------------------------------------------------------------
Static Function CTBS500Per(cPerApur, dIniPer, dFimPer)

    Local lRet := .T. as Logical
    Local nMes := 0 as Numeric
    Local nAno := 0 as Numeric

    Default cPerApur := ""

    If Len(AllTrim(cPerApur)) != 7
        lRet := .F.
    ElseIf SubStr(cPerApur, 5, 1) != "-"
        lRet := .F.
    ElseIf !IsDigit(Left(cPerApur, 4)) .Or. !IsDigit(SubStr(cPerApur, 6, 2))
        lRet := .F.
    Else
        nAno := Val(Left(cPerApur, 4))
        nMes := Val(SubStr(cPerApur, 6, 2))
        If nMes < 1 .Or. nMes > 12
            lRet := .F.
        Else
            dIniPer := CToD("01/" + StrZero(nMes, 2) + "/" + StrZero(nAno, 4))
            dFimPer := LastDay(dIniPer)
        EndIf
    EndIf

Return lRet

//===================================================================
// Callbacks do gerenciador de pacotes de stored procedures (SPMANAGER)
// para o processo CSP_PROC. Ver ATENCAO no topo do fonte: enquanto o
// numero de processo for 41, estes callbacks CONFLITAM com os do
// processo 41 padrao do Ativo Fixo (ATFA070). Ao definir o numero de
// processo dedicado, renomeie o sufixo numerico destas funcoes.
//
// D-1101 nao usa tabela de trabalho (a procedure le CT2/CT1/CQ0 e
// grava a QLU diretamente); os callbacks Pre/Delete sao triviais. O
// EngPos<NN>Compile reinjeta as expressoes CASE WHEN (removidas pelo
// parser do instalador) no buffer JA parseado, via tokens SPTK_*.
//===================================================================

//-------------------------------------------------------------------
/*/{Protheus.doc} EngSPS41Signature
    Assinatura de versao da procedure CTBS500 (processo 41 provisorio).
    Qualquer alteracao que afete diretamente a stored procedure deve
    incrementar esta assinatura.

    @author totvs
    @since 17/09/2026
    @version P12.1.2510

    @param cProcess, character, codigo do processo

    @return character, assinatura de versao
/*/
//-------------------------------------------------------------------
Function EngSPS41Signature(cProcess)
Return CSP_SIGN

//-------------------------------------------------------------------
/*/{Protheus.doc} EngPre41Compile
    Executada antes da compilacao da procedure ("Pre-Compile"). O
    D-1101 nao possui tabela de trabalho, portanto nao ha estrutura a
    criar; apenas restringe o processo ao Brasil. Sem interface/
    interacao com o usuario. Erros retornam em cError (por referencia).

    @author totvs
    @since 17/09/2026
    @version P12.1.2510

    @param cProcesso, character, codigo do processo
    @param cEmpresa, character, codigo da empresa
    @param cError, character, mensagem de erro (por referencia)

    @return logical, .T. quando a compilacao pode prosseguir
/*/
//-------------------------------------------------------------------
Function EngPre41Compile(cProcesso, cEmpresa, cError)

    Local lRet := .T. as Logical

    cError := ""

    If cPaisLoc != "BRA"
        cError := "O processo D-1101 (DeRE) esta disponivel somente para o ambiente Brasil."
        lRet   := .F.
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EngPos41Compile
    Executada apos o parse do SQL da procedure ("Pos-Compile"). Recebe
    o buffer JA traduzido para o SGBD destino (cBuffer, por referencia)
    e reinjeta as expressoes CASE WHEN que o parser do instalador
    remove. No CTBS500.sql cada CASE foi trocado por um token neutro
    'SPTK_xxx' (string literal que sobrevive ao parser); aqui os tokens
    sao substituidos pelo CASE real.

    A sintaxe CASE WHEN e padrao (MSSQL/Oracle/Postgres), portanto a
    reinjecao independe de cLocalDB. Atua apenas na procedure do D-1101
    (o processo pode estar compartilhado enquanto o numero for
    provisorio).

    @author totvs
    @since 17/09/2026
    @version P12.1.2510

    @param cProcesso, character, codigo do processo
    @param cEmpresa, character, codigo da empresa
    @param cProcName, character, nome da procedure em compilacao
    @param cLocalDB, character, SGBD em uso (MSSQL/ORACLE/POSTGRES)
    @param cBuffer, character, buffer SQL ja parseado (por referencia)
    @param cError, character, mensagem de erro (por referencia)

    @return logical, .T. quando a compilacao pode prosseguir
/*/
//-------------------------------------------------------------------
Function EngPos41Compile(cProcesso, cEmpresa, cProcName, cLocalDB, cBuffer, cError)

    cError := ""

    // Atua somente na procedure do D-1101.
    If !("ATF070" $ Upper(AllTrim(cProcName)))
        Return .T.
    EndIf
    
    dbSelectArea("QLU")
    // Bloco EST (estornos da CT2): mapeamento CRUZADO da partida
    // reversa. O estorno lancado a CREDITO (POS='C') reverte um
    // lancamento a debito, logo compoe o ajuste a DEBITO (coluna
    // AJUDEB / vAjusteDebt); o estorno lancado a DEBITO (POS='D')
    // reverte um lancamento a credito, logo compoe o ajuste a CREDITO
    // (coluna AJUCRE / vAjusteCred). Com natVApur pelo prefixo do
    // CODTRIB (ver CTBS500Dir), o CONFERIR_VAPUR anula o estorno reverso
    // puro (vApur = 0).
    cBuffer := StrTran(cBuffer, "'SPTK_ESTAJUDEB'", "SUM(CASE WHEN POS = 'C' THEN VALOR ELSE 0 END)")
    cBuffer := StrTran(cBuffer, "'SPTK_ESTAJUCRE'", "SUM(CASE WHEN POS = 'D' THEN VALOR ELSE 0 END)")

    // Nivel B: saldo inicial resolvido (natureza / valor / origem)
    cBuffer := StrTran(cBuffer, "'SPTK_NATINI'", "CASE WHEN ANT.QLU_CONTA IS NOT NULL THEN ANT.QLU_NATFIM WHEN CT1.CT1_NORMAL = '2' THEN 'C' ELSE 'D' END")
    cBuffer := StrTran(cBuffer, "'SPTK_VLINI'", "CASE WHEN ANT.QLU_CONTA IS NOT NULL THEN ANT.QLU_VLFIM WHEN CQ.CQ0_CONTA IS NOT NULL THEN ABS(CQ.ACUM) ELSE 0 END")
    cBuffer := StrTran(cBuffer, "'SPTK_ORIGSI'", "CASE WHEN ANT.QLU_CONTA IS NOT NULL THEN 'A' WHEN CQ.CQ0_CONTA IS NOT NULL THEN 'Q' ELSE 'Z' END")

    // Nivel C: Saldo Liquido (bruto, Manual) e Valor de Apuracao.
    // A natureza do vApur (natVApur) e determinada pelo PREFIXO do
    // CODTRIB (QLT_CODTRB), conforme regra_natVapur.txt - imune a
    // edicoes nas descricoes das tabelas da RFB e de alta performance.
    // CTBS500Dir monta o CASE de direcao ('D'/'C') para a coluna do
    // CODTRIB (B.CODTRB no vApur, C.CODTRB na natVApur).
    cBuffer := StrTran(cBuffer, "'SPTK_SL'", "(CASE WHEN B.NATINI = 'C' THEN (B.VLINI * -1) ELSE B.VLINI END) + B.MOVDEB - B.MOVCRE")
    cBuffer := StrTran(cBuffer, "'SPTK_VAPUR'", "CASE WHEN (" + CTBS500Dir("B.CODTRB") + ") = 'D' THEN B.MOVDEB - B.AJUDEB + B.AJUCRE ELSE B.MOVCRE - B.AJUCRE + B.AJUDEB END")

    // Saida: saldo final (valor/natureza) e natureza do valor apurado.
    cBuffer := StrTran(cBuffer, "'SPTK_NATFIM'", "CASE WHEN C.SL > 0 THEN 'D' WHEN C.SL < 0 THEN 'C' ELSE C.NATINI END")
    cBuffer := StrTran(cBuffer, "'SPTK_VLFIM'", "CASE WHEN C.SL < 0 THEN (C.SL * -1) WHEN C.SL > 0 THEN C.SL ELSE 0 END")
    cBuffer := StrTran(cBuffer, "'SPTK_NATAPU'", "CASE WHEN C.VAPUR > 0 THEN (" + CTBS500Dir("C.CODTRB") + ") ELSE ' ' END")

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBS500Dir
    Monta a expressao SQL (CASE WHEN ... END) que resolve a DIRECAO de
    apuracao (natVApur: 'D'/'C') a partir do PREFIXO do CODTRIB, para a
    coluna informada. Regra conforme SIGACTB/DERE/regra_natVapur.txt:
      - prefixo '2' (Passivo/PL) ou '3' (Receitas) -> 'C';
      - prefixo '4' (Despesas/Custos)              -> 'D';
      - prefixo '1' (Ativo): prefixos devedores especificos -> 'D';
        demais do Ativo -> 'C';
      - qualquer outro -> 'C' (fallback de seguranca).
    A sintaxe CASE/LIKE e padrao (MSSQL/Oracle/Postgres), independendo
    do SGBD destino.

    @author totvs
    @since 19/09/2026
    @version P12.1.2510

    @param cCol, character, nome da coluna do CODTRIB (ex.: "B.CODTRB")

    @return character, expressao SQL CASE que devolve 'D' ou 'C'
/*/
//-------------------------------------------------------------------
Static Function CTBS500Dir(cCol)

    Local cCase := "" as Character

    cCase := "CASE "
    cCase += "WHEN " + cCol + " LIKE '2%' OR " + cCol + " LIKE '3%' THEN 'C' "
    cCase += "WHEN " + cCol + " LIKE '4%' THEN 'D' "
    cCase += "WHEN " + cCol + " LIKE '11026%' OR " + cCol + " LIKE '1103126%' OR " + cCol + " LIKE '1103146%' "
    cCase += "  OR " + cCol + " LIKE '1103226%' OR " + cCol + " LIKE '1103246%' OR " + cCol + " LIKE '1104126%' "
    cCase += "  OR " + cCol + " LIKE '11056%' OR "   + cCol + " LIKE '1108216%' OR " + cCol + " LIKE '1108226%' "
    cCase += "  OR " + cCol + " LIKE '1111116%' OR " + cCol + " LIKE '1111126%' OR " + cCol + " LIKE '111126%' "
    cCase += "  OR " + cCol + " LIKE '111216%' OR "  + cCol + " LIKE '11136%' OR "   + cCol + " LIKE '12016%' "
    cCase += "  OR " + cCol + " LIKE '12026%' OR "   + cCol + " LIKE '12036%' OR "   + cCol + " LIKE '13016%' THEN 'D' "
    cCase += "WHEN " + cCol + " LIKE '1%' THEN 'C' "
    cCase += "ELSE 'C' END"

Return cCase

//-------------------------------------------------------------------
/*/{Protheus.doc} EngSPS41Delete
    Executada na desinstalacao do processo ("On Uninstall"). O D-1101
    nao possui tabela de trabalho a remover; sem interface. Erros
    retornam em cError (por referencia).

    @author totvs
    @since 17/09/2026
    @version P12.1.2510

    @param cProcesso, character, codigo do processo
    @param cEmpresa, character, codigo da empresa
    @param cError, character, mensagem de erro (por referencia)

    @return logical, .T. quando a desinstalacao pode prosseguir
/*/
//-------------------------------------------------------------------
Function EngSPS41Delete(cProcesso, cEmpresa, cError)

    cError := ""

Return .T.
