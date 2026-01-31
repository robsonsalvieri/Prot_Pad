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
Function GeraTit(aCodDesp as array, cMsgRet as character, cCodRet as character, cDtVenc as character, cDtBase as character, lAgrupar as logical)

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
    Local dDAtaVenc    as date
    Local lRet         as logical
    Local nI           as numeric
    Local nItems       as numeric
    Local nValor       as numeric

    aCodigosDesp        := {}
    aItem               := {}
    cAliasTmp           := GetNextAlias()
    cCodigoDesp         := ""
    cDescricao          := ""
    cFile               := ""
    cFornecedor         := ""
    cInClause           := ""
    cLoja               := ""
    cNumTitulo          := ""
    cNatureza           := ""
    cParcela            := "1"
    cPath               := GetSrvProfString("Rootpath","")
    cPrefixo            := ""
    cTipoTit            := "TF"
    dDAtaVenc           := CtoD("")
    lRet                := .T.
    nI                  := 0
    nItems              := 0
    nValor              := 0
    
    Default aCodDesp    := {}
    Default cMsgRet     := ''
    Default cCodRet     := ''
    Default cDtVenc     := ''
    Default lAgrupar    := .T.
    
    Private lMsErroAuto := .F.
    
    If Len(aCodDesp) == 0
        cMsgRet := 'Nenhum código de despesa informado'
        Return .F.
    EndIf

    If !Empty(cDtVenc)
        dDataVenc := StoD(cDtVenc)
    
        If Empty(dDataVenc)
            cMsgRet := 'Data de vencimento inválida: ' + cDtVenc
            Return .F.
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

    CreateQry(cInClause, lAgrupar, @cAliasTmp)
    
    (cAliasTmp)->(DbGoTop())
    
    // Processa cada registro
    While !(cAliasTmp)->(EoF())
        cCodigoDesp := AllTrim((cAliasTmp)->DESPESA)
        cDescricao  := AllTrim((cAliasTmp)->DESCRICAO)
        cFornecedor := AllTrim((cAliasTmp)->FORNECEDOR)
        cPrefixo    := AllTrim((cAliasTmp)->PREFIXO)
        cNatureza   := AllTrim((cAliasTmp)->NATUREZA)
        cLoja       := AllTrim((cAliasTmp)->LOJA)
        nValor      := (cAliasTmp)->VALOR
        
        If nValor <= 0
            lRet := .F.
            cMsgRet := 'Despesa ' + cCodigoDesp + ' - ' + cDescricao + ' com valor inválido ou zerado'
            Exit
        EndIf
        
        If Empty(cFornecedor)
            lRet := .F.
            cMsgRet := 'Despesa ' + cCodigoDesp + ' - ' + cDescricao + ' sem fornecedor cadastrado'
            Exit
        EndIf
        
        If Empty(cPrefixo)
            lRet := .F.
            cMsgRet := 'Despesa ' + cCodigoDesp + ' - ' + cDescricao + ' sem prefixo configurado'
            Exit
        EndIf
        
        cNumTitulo := GerNumTit("SE2", cPrefixo, cParcela, cTipoTit)
        
        If Empty(cNumTitulo)
            lRet := .F.
            cMsgRet := 'Erro ao gerar número do título para despesa ' + cCodigoDesp + ' - ' + cDescricao
            Exit
        EndIf
        
        aItem := {}
        
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
        aAdd(aItem, {"E2_VENCREA", dDataVenc     , Nil}) //[10]
        aAdd(aItem, {"E2_VALOR"  , nValor        , Nil}) //[11]
        aAdd(aItem, {"E2_SALDO"  , nValor        , Nil}) //[12]
        aAdd(aItem, {"E2_HIST"   , "DESP: " + cCodigoDesp + " - " + cDescricao, Nil}) //[13]
        aAdd(aItem, {"E2_ORIGEM" , "FSMX006"     , Nil}) //[14]

        DbSelectArea("SE2")
        SE2->(DbSetOrder(1))        
        If !SE2->(DbSeek(xFilial("SE2")+cPrefixo+cNumTitulo+cParcela+cTipoTit))
            MsExecAuto({|x,y| FINA050(x,y)}, aItem, 3)  // 3 - Inclusao
            
            If lMsErroAuto
                RollbackSx8()
                DisarmTransaction()
                cMsgRet := MostraErro(cPath,cFile) + CRLF
                lRet := .F.
                Exit
            Else
                UpdateJOF(cNumTitulo, cDtVenc, cCodigoDesp, cPrefixo, cFornecedor, cLoja, cInClause)
                nItems++
            EndIf
        Else
            RollbackSx8()
            DisarmTransaction()
            lRet := .F.
            cMsgRet := "Título " + cNumTitulo + " já existe para fornecedor " + cFornecedor
            Exit
        EndIf
        
        (cAliasTmp)->(DbSkip())
    EndDo
    
    (cAliasTmp)->(DbCloseArea())
    
    If lRet        
        cCodRet := "OK"
        cMsgRet := "Gerados " + cValToChar(nItems) + " título(s) com sucesso"
    Else
        DisarmTransaction()
        cCodRet := "ERRO"
            
        If !Empty(cMsgRet)
            cMsgRet := "Erro ao gerar títulos: " + cMsgRet
        Else
            cMsgRet := "Erro ao gerar títulos: Erro desconhecido"
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
    
    Default cPrefixo := ""
    Default cParcela := ""
    Default cTipo    := ""
    
    (cAlias)->(DbSetOrder(1))

    While (cAlias)->(DbSeek(xFilial(cAlias) + cPrefixo + cNum + cParcela + cTipo))
        ConfirmSX8()
        cNum := GetSxEnum(cAlias, cField, cEmpAnt + xFilial(cAlias) + cPrefixo + cParcela + cTipo)
    EndDo
    
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
Static Function CreateQry(cInClause as character, lAgrupar as logical, cAliasTmp as character)
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
    cQuery +=   " AND JOF.JOF_STATUS != '5' "
    
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
Static Function UpdateJOF(cNumTitulo, cDtVenc, cCodigoDesp, cPrefixo, cFornecedor, cLoja, cInClause )

    Loca cQryUpd  := ""

    cQryUpd := " UPDATE " + RetSqlName("JOF") + " "
    cQryUpd += " SET "
    cQryUpd +=      " JOF_TITULO = '" + cNumTitulo + "', "
    cQryUpd +=      " JOF_STATUS = '5', "
    cQryUpd +=      " JOF_DTPAGA = '" + cDtVenc + "'"
    cQryUpd += " WHERE JOF_CODJOD = '" + cCodigoDesp + "'"
    cQryUpd +=      " AND JOF_PREFIX = '" + cPrefixo + "'"
    cQryUpd +=      " AND JOF_CODFOR = '" + cFornecedor + "'"
    cQryUpd +=      " AND JOF_LOJA = '" + cLoja + "'"
    cQryUpd +=      " AND JOF_STATUS = '1'"
    cQryUpd +=      " AND JOF_CODIGO IN (" + cInClause + ") "
    cQryUpd +=      " AND D_E_L_E_T_ = '' "

    TcSqlExec(cQryUpd)

Return
