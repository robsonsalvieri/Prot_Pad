#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTit
    Gera títulos financeiros para pagamento de despesas
    @param aCodDesp      Array com códigos das despesas (JOF_CODIGO)
    @param cMsgRet       Mensagem de retorno (referência)
    @param cCodRet       Código de retorno (referência)
    @param cDtVenc       Data de vencimento no formato AAAAMMDD
    @param lAgrupar      Se .T. agrupa por tipo de despesa, se .F. cria título para cada código
    @return lRet         .T. se sucesso, .F. se erro
    @author              Silas Gomes
/*/
Function GeraTit(aCodDesp as array, cNumero as character, cMsgRet as character, cCodRet as character, cDtVenc as character, cDtBase as character, lAgrupar as logical, lReembo as logical)

    Local aCodigosDesp as array
    Local aItem        as array
    Local cAliasTmp    as character
    Local cCodigoDesp  as character
    Local cDescricao   as character
    Local cFile        as character
    Local cFornecedor  as character
    Local cInClause    as character
    Local cLoja        as character
    Local cNumTitulo   as character
    Local cNatureza    as character
    Local cParcela     as character
    Local cPath        as character
    Local cPrefixo     as character
    Local cTipoTit     as character
    Local cDataReal    as character
    Local dDataVenc    as date
    Local dDtPagReal    as date
    Local lRet         as logical
    Local nI           as numeric
    Local nItems       as numeric
    Local nValor       as numeric

    aCodigosDesp     := {}
    aItem            := {}
    cAliasTmp        := GetNextAlias()
    cCodigoDesp      := ""
    cDescricao       := ""
    cFile            := ""
    cFornecedor      := ""
    cInClause        := ""
    cLoja            := ""
    cNumTitulo       := ""
    cNatureza        := ""
    cParcela         := "1"
    cPath            := GetSrvProfString("Rootpath","")
    cPrefixo         := ""
    cTipoTit         := "TF"
    cDataReal        := ""
    dDataVenc        := CtoD("")
    dDtPagReal       := CtoD("")
    lRet             := .T.
    nI               := 0
    nItems           := 0
    nValor           := 0
    
    Default aCodDesp := {}
    Default cNumero  := ''
    Default cMsgRet  := ''
    Default cCodRet  := ''
    Default cDtVenc  := ''
    Default lAgrupar := .T.
    Default lReembo  := .F.
    
    Private lMsErroAuto := .F.

    If !Empty(cDtVenc)
        dDataVenc := StoD(cDtVenc)
        dDtPagReal := DataValida(dDataVenc,.T.)
        cDataReal :=DtoS(dDtPagReal)
    
        If Empty(dDataVenc)
            cMsgRet := 'Data de vencimento inválida: ' + cDtVenc
            lRet := .F.
        EndIf
    EndIf

    For nI := 1 To Len(aCodDesp)
        If !Empty(AllTrim(aCodDesp[nI]))
            cCodigo := AllTrim(aCodDesp[nI])
            AAdd(aCodigosDesp, cCodigo)
            cInClause += "'" + cCodigo + "'"

            If nI < Len(aCodDesp)
                cInClause += ","
            EndIf
        EndIf
    Next nI
    
    Begin Transaction

    CreateQry(cInClause, lAgrupar, @cAliasTmp, lReembo)
    
    (cAliasTmp)->(DbGoTop())
    
    // Processa cada registro
    While !(cAliasTmp)->(EoF())

        aItem := {}
    
        cCodigoDesp := AllTrim((cAliasTmp)->DESPESA)
        cDescricao  := AllTrim((cAliasTmp)->DESCRICAO)
        cFornecedor := AllTrim((cAliasTmp)->FORNECEDOR)
        cPrefixo    := AllTrim((cAliasTmp)->PREFIXO)
        cNatureza   := AllTrim((cAliasTmp)->NATUREZA)
        cLoja       := AllTrim((cAliasTmp)->LOJA)
        nValor      := (cAliasTmp)->VALOR

        If !lReembo
        
            cNumTitulo := GerNumTit("SE2", cPrefixo, cParcela, cTipoTit)

            aAdd(aItem, {"E2_FILIAL" , xFilial("SE2"), Nil}) //[1]
            aAdd(aItem, {"E2_PREFIXO", cPrefixo      , Nil}) //[2] 
            aAdd(aItem, {"E2_NUM"    , cNumTitulo    , Nil}) //[3]
            aAdd(aItem, {"E2_PARCELA", cParcela      , Nil}) //[4]
            aAdd(aItem, {"E2_TIPO"   , cTipoTit      , Nil}) //[5]
            aAdd(aItem, {"E2_NATUREZ", cNatureza     , Nil}) //[6]
            aAdd(aItem, {"E2_FORNECE", cFornecedor   , Nil}) //[6]
            aAdd(aItem, {"E2_LOJA"   , cLoja         , Nil}) //[7]
            aAdd(aItem, {"E2_EMISSAO", StoD(cDtBase) , Nil}) //[8]
            aAdd(aItem, {"E2_VENCTO" , dDataVenc     , Nil}) //[9]
            aAdd(aItem, {"E2_VENCREA", dDtPagReal    , Nil})//[10]
            aAdd(aItem, {"E2_VALOR"  , nValor        , Nil}) //[11]
            aAdd(aItem, {"E2_SALDO"  , nValor        , Nil}) //[12]
            aAdd(aItem, {"E2_HIST"   , "DESP: " + cCodigoDesp + " - " + cDescricao, Nil}) //[13]
            aAdd(aItem, {"E2_ORIGEM" , "FSMX006"     , Nil}) //[14]

            MsExecAuto({|x,y| FINA050(x,y)}, aItem, 3)  // 3 - Inclusao

        Else //Reembolso despesa

            aAdd(aItem, {"E2_FILIAL" , xFilial("SE2"), Nil}) //[1]
            aAdd(aItem, {"E2_PREFIXO", cPrefixo      , Nil}) //[2] 
            aAdd(aItem, {"E2_NUM",     cNumero       , Nil}) //[3] 
            aAdd(aItem, {"E2_PARCELA", cParcela      , Nil}) //[4]
            aAdd(aItem, {"E2_TIPO"   , cTipoTit      , Nil}) //[5]
            aAdd(aItem, {"E2_NATUREZ", cNatureza     , Nil}) //[6]
            aAdd(aItem, {"E2_FORNECE", cFornecedor   , Nil}) //[6]
            aAdd(aItem, {"E2_LOJA"   , cLoja         , Nil}) //[7]
            aAdd(aItem, {"E2_EMISSAO", StoD(cDtBase) , Nil}) //[8]

            MsExecAuto({|x,y,z| FINA050(x,y,z)}, aItem,, 5) // Exclui o título

        EndIf

        If lMsErroAuto
            RollbackSx8()
            DisarmTransaction()
            cMsgRet := MostraErro(cPath,cFile) + CRLF
            lRet := .F.
            Exit
        Else
            UpdateJOF(cNumTitulo, cDataReal, cCodigoDesp, cPrefixo, cFornecedor, cLoja, cInClause, lReembo, cNumero)
            nItems++
        EndIf
        
        (cAliasTmp)->(DbSkip())
    EndDo
    
    (cAliasTmp)->(DbCloseArea())
    
    If lRet
        cCodRet := "OK"
    
        If !lReembo
            cMsgRet := "Gerado" + If(nItems > 1, "s ", " ") + ;
                cValToChar(nItems) + " título" + If(nItems > 1, "s", "") + ;
                " com sucesso"
        Else
            cMsgRet := "Título cancelado"
        EndIf
    EndIf

    End Transaction
    
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GerNumTit
    Gera número de título único usando GetSxEnum
    @param cAlias     Alias da tabela (SE1 ou SE2)
    @param cPrefixo   Prefixo do título
    @param cParcela   Parcela do título
    @param cTipo      Tipo do título
    @return cNum      Número gerado
    @author           Silas Gomes
/*/
Function GerNumTit(cAlias as character, cPrefixo as character, cParcela as character, cTipo as character)
    Local cField as character
    Local cNum   as character

    cField := 'E2_NUM'
    cNum   := GetSxEnum(cAlias, cField, cEmpAnt + xFilial(cAlias) + cPrefixo + cParcela + cTipo)    
    ConfirmSX8()
    
Return cNum

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateQry
    Cria query temporária para processamento de títulos
    @param cInClause  Cláusula IN com filtros
    @param lAgrupar   Flag para indicar se deve agrupar resultados
    @param cAliasTmp  Alias da tabela temporária
    @return           Retorno da função
    @author           Silas Gomes
/*/
Static Function CreateQry(cInClause as character, lAgrupar as logical, cAliasTmp as character, lReembo as logical)
    Local cQuery  as character
    Local oQryTmp as object

    cQuery  := ""
    oQryTmp := Nil
    
    cQuery := " SELECT "
    cQuery +=   " JOF.JOF_CODJOD DESPESA, "
    
    If lAgrupar
        cQuery +=   " SUM(JOF.JOF_VLRDES) VALOR, "
    Else
        cQuery +=   " JOF.JOF_VLRDES VALOR, "
    EndIf
    
    cQuery +=   " JOD.JOD_PREFIX PREFIXO, "
    cQuery +=   " JOD.JOD_NATFIN NATUREZA, "
    cQuery +=   " AA1.AA1_CODFOR FORNECEDOR, "
    cQuery +=   " AA1.AA1_LOJFOR LOJA, "
    cQuery +=   " JOD.JOD_TPDESP DESCRICAO "
    cQuery += " FROM " + RetSqlName('JOF') + " JOF "
    cQuery +=   " INNER JOIN " + RetSqlName('JOD') + " JOD "
    cQuery +=       " ON JOD.JOD_FILIAL = JOF.JOF_FILIAL "
    cQuery +=       " AND JOD.JOD_CODIGO = JOF.JOF_CODJOD "
    cQuery +=       " AND JOD.D_E_L_E_T_ = ' ' "
    cQuery +=   " INNER JOIN " + RetSqlName('AA1') + " AA1 "
    cQuery +=       " ON AA1.AA1_FILIAL = JOF.JOF_FILIAL "
    cQuery +=       " AND AA1.AA1_CODTEC = JOF.JOF_CODAA1 "
    cQuery +=       " AND AA1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE "
    cQuery +=   " JOF.JOF_FILIAL = '" + xFilial("JOF") + "' "
    cQuery +=   " AND JOF.D_E_L_E_T_ = ' ' "
    cQuery +=   " AND JOF.JOF_CODIGO IN (" + cInClause + ") "
    
    If !lReembo
        cQuery +=   " AND JOF.JOF_STATUS != '5' "
    Else 
        cQuery +=   " AND JOF.JOF_STATUS = '5' "
    EndIf
    
    If lAgrupar
        cQuery += " GROUP BY "
        cQuery +=   " JOF.JOF_CODJOD, "
        cQuery +=   " JOD.JOD_PREFIX, "
        cQuery +=   " JOD.JOD_NATFIN, "
        cQuery +=   " AA1.AA1_CODFOR, "
        cQuery +=   " AA1.AA1_LOJFOR, "
        cQuery +=   " JOD.JOD_TPDESP "
    EndIf
        
    If lAgrupar
        cQuery += " ORDER BY JOF.JOF_CODJOD "
    Else
        cQuery += " ORDER BY JOF.JOF_CODIGO "
    EndIf

    oQryTmp := FwPreparedStatement():New(cQuery)
    cQuery    := oQryTmp:GetFixQuery()
    cAliasTmp := MpSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateJOF
    Atualiza registros na tabela JOF com base nos parâmetros fornecidos
    @param cNumTitulo    Número do título
    @param cDtVenc       Data de vencimento
    @param cCodigoDesp   Código da despesa
    @param cPrefixo      Prefixo do título
    @param cFornecedor   Código do fornecedor
    @param cLoja         Loja do fornecedor
    @param cInClause     Cláusula IN para filtros adicionais
    @return              Retorno da função
    @author              Silas Gomes
/*/
Static Function UpdateJOF(cNumTitulo, cDataReal, cCodigoDesp, cPrefixo, cFornecedor, cLoja, cInClause, lReembo, cNumero )

    Local cQryUpd  := ""

    If !lReembo

        cQryUpd := " UPDATE " + RetSqlName("JOF") + " "
        cQryUpd += " SET "
        cQryUpd +=      " JOF_TITULO = '" + cNumTitulo + "', "
        cQryUpd +=      " JOF_STATUS = '5', "
        cQryUpd +=      " JOF_DTPAGA = '" + cDataReal + "'"
        cQryUpd += " WHERE JOF_CODJOD = '" + cCodigoDesp + "'"
        cQryUpd +=      " AND JOF_PREFIX = '" + cPrefixo + "'"
        cQryUpd +=      " AND JOF_CODFOR = '" + cFornecedor + "'"
        cQryUpd +=      " AND JOF_LOJA = '" + cLoja + "'"
        cQryUpd +=      " AND JOF_STATUS = '1'"
        cQryUpd +=      " AND JOF_CODIGO IN (" + cInClause + ") "
        cQryUpd +=      " AND D_E_L_E_T_ = '' "

    Else 

        cQryUpd := " UPDATE " + RetSqlName("JOF") + " "
        cQryUpd += " SET "
        cQryUpd +=      " JOF_STATUS = '1' "
        cQryUpd += " WHERE JOF_CODJOD = '" + cCodigoDesp + "'"
        cQryUpd +=      " AND JOF_PREFIX = '" + cPrefixo + "'"
        cQryUpd +=      " AND JOF_CODFOR = '" + cFornecedor + "'"
        cQryUpd +=      " AND JOF_LOJA = '" + cLoja + "'"
        cQryUpd +=      " AND JOF_TITULO = '" + cNumero + "'"
        cQryUpd +=      " AND D_E_L_E_T_ = '' "

    EndIf

    TcSqlExec(cQryUpd)

Return
