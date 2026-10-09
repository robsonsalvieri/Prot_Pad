#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "OFIA617.CH"

/*/{Protheus.doc} OFIA617
Tela de Reprocessamento de Eventos - Control Tower
Permite consulta, visualizacao e reprocessamento de eventos com falha/erro
na integracao.
@type Source
@version 2.0
@author Diogo Barros
@since 20/03/2026
/*/

#Define MESSAG_VX5       "083"  // VX5: chave da tabela generica para descricao do evento (VK5_MESSAG)
#Define DATTYP_VX5       "084"  // VX5: chave da tabela generica para descricao do tipo de dado (VK5_DATTYP)
#Define VK5_DATTYP_CT    "06"   // Tipo de dado Control Tower gravado em VK5_DATTYP (VX5 chave 084, codigo 06)

#Define VK5_STA_PENDENTE  "0" // status pendente
#Define VK5_STA_SUCESSO   "2" // status sucesso
#Define VK5_STA_ERRO      "3" // status erro

#Define FLT_ERRO        1 // filtro erro 
#Define FLT_SUCESSO     2 // filtro sucesso
#Define FLT_TODOS       3 // filtro todos
#Define FLT_ERROPEND    4 // filtro erro + pendentes

#Define BIND_STRING     1 // string
#Define BIND_NUMERIC    2 // numero
#Define POS_MARK      1 // Checkbox selecao
#Define POS_STATUS    2 // Status derivado
#Define POS_METODO    3 // Metodo HTTP
#Define POS_RESPHTTP  4 // Codigo resposta HTTP
#Define POS_FILIAL    5 // Filial
#Define POS_CHASSI    6 // chassi  
#Define POS_CODEVT    7 // codigo evento
#Define POS_DESCEVT   8 // posicao desc evento
#Define POS_UUID      9 // UUID truncado
#Define POS_TIPODADO  10 // Tipo de dado (descricao) 
#Define POS_DATINC    11 // posicao data inclusao
#Define POS_URL       12 // URL da requisicao
#Define POS_REQBODY   13 // Body da requisicao (detalhe)
#Define POS_RECNO     14 // RecNo do registro
#Define POS_ORIKEY    15 // Chave de origem
#Define POS_DATTYP    16 // Codigo tipo de dado
#Define POS_MESSAG    17 // Codigo tipo de mensagem
#Define POS_ORITAB    18 // Tabela de origem
#Define POS_FULLUUID  19 // UUID completo
#Define POS_RESBOD    20 // posicao response body

#Define ROW_FLT       08 // linha do filtro
#Define ROW_GRD       32 // linha da grid

Static aStaOpt := {STR0001, STR0002, STR0003, STR0031} // Erro, Sucesso, Todos, Erros + Pendentes

/*/{Protheus.doc} OFIA617
Entrada principal da tela de Reprocessamento de Eventos.
Inicializa filtros padrao, executa carga inicial e exibe o dialog.
@type Function
@return Nil
/*/
Function OFIA617()
    Local   aArea       := FWGetArea()
    Private cCadastro   := STR0004 // Reprocessamento de Eventos
    Private nDlgW       := 0
    Private nDlgH       := 0
    Private nGrdH       := 0
    Private nDtlLabY    := 0
    Private nDtlMemY    := 0
    Private nMemH       := 0
    Private nMidX       := 0
    Private nMemW       := 0
    Private oDlg        := Nil
    Private oBrw        := Nil
    Private oMBody      := Nil
    Private oMResp      := Nil
    Private oBtnPesq    := Nil
    Private oBtnLeg     := Nil
    Private oBtnCancel  := Nil
    Private oBtnRepr    := Nil
    Private aData       := {}
    Private cMemBod     := ""
    Private cMenHist    := ""
    Private cFltFil     := ""
    Private cFltCha     := ""
    Private dFltDat     := Nil
    Private cFltSta     := aStaOpt[FLT_ERROPEND]

    If FWGetRunSchedule()
        OA617SCH_Processar()
    Else
        OA6170001M_IniciaFiltros()
        OA6170002M_CarregaDados()
        OA6170003M_Tela()
    EndIf

    FWRestArea(aArea)
Return

/*/{Protheus.doc} OA6170003M_Tela
Constroi o dialog principal com todos os componentes diretamente no oDlg.
@type Static Function
@return Nil
/*/
Static Function OA6170003M_Tela()
    Local aSizeMax := MsAdvSize(.F.)
    Local nAvail   := 0
    
    nDlgW    := aSizeMax[5]
    nDlgH    := aSizeMax[6]
    nAvail   := (nDlgH / 2) - ROW_GRD - 25
    nGrdH    := Int(nAvail * 0.45)
    nDtlLabY := ROW_GRD + nGrdH + 8
    nDtlMemY := nDtlLabY + 10
    nMemH    := Int(nAvail * 0.40)
    nMidX    := Int(nDlgW / 4)
    nMemW    := nMidX - 15

    DEFINE MSDIALOG oDlg ;
    TITLE cCadastro ;
    FROM aSizeMax[7], 0 TO nDlgH, nDlgW PIXEL

    OA6170004M_CriaFiltros()
    OA6170005M_CriaGrid()
    OA6170006M_CriaDetalhe()
    OA6170007M_CriaBotao()

    ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} OA6170004M_CriaFiltros
Cria os filtros diretamente no oDlg.
@type Static Function
@return Nil
/*/
Static Function OA6170004M_CriaFiltros()
    Local oSay    := Nil
    Local oGetFil := Nil
    Local oGetChs := Nil
    Local oGet    := Nil

    oSay := TSay():New(ROW_FLT + 2, 5, {|| STR0005}, oDlg, , , , , , .T., , , 30, 10) // Filial
    oGetFil := TGet():New(ROW_FLT, 38, {|u| IIf(PCount() > 0, cFltFil := u, cFltFil)}, ;
                        oDlg, 30, 10, "@!", , 0, , , .F., , .T., , .F., , .F., .F., , .F., .F., , 'cFltFil')
    oGetFil:cF3 := "SM0"

    oSay := TSay():New(ROW_FLT + 2, 80, {|| STR0006}, oDlg, , , , , , .T., , , 30, 10) // Chassi
    oGetChs := TGet():New(ROW_FLT, 115, {|u| IIf(PCount() > 0, cFltCha := u, cFltCha)}, ;
                        oDlg, 80, 10, "@!", , 0, , , .F., , .T., , .F., , .F., .F., , .F., .F., , 'cFltCha')
    oGetChs:cF3 := "VV1"

    oSay := TSay():New(ROW_FLT + 2, 210, {|| STR0007}, oDlg, , , , , , .T., , , 55, 10) // Data Inclusao
    oGet := TGet():New(ROW_FLT, 270, {|u| IIf(PCount() > 0, dFltDat := u, dFltDat)}, ;
                        oDlg, 55, 10, "99/99/9999", , 0, , , .F., , .T., , .F., , .F., .F., , .F., .F., , 'dFltDat')

    oSay := TSay():New(ROW_FLT + 2, 338, {|| STR0008}, oDlg, , , , , , .T., , , 30, 10) // Status
    TComboBox():New(ROW_FLT, 372, {|u| IIf(PCount() > 0, cFltSta := u, cFltSta)}, ;
                    aStaOpt, 50, 10, oDlg, , , , , , .T., , , , , , , , , 'cFltSta')
Return

/*/{Protheus.doc} OA6170005M_CriaGrid
Cria o TCBrowse diretamente no oDlg
@type Static Function
@return Nil
/*/
Static Function OA6170005M_CriaGrid()
    Local nGrdW   := nDlgW
    Local oClrOk  := LoadBitmap(GetResources(), "BR_VERDE")
    Local oClrErr := LoadBitmap(GetResources(), "BR_VERMELHO")

    If Len(aData) == 0
        OA6170008M_AddLinhaVazia()
    EndIf

    oBrw := TCBrowse():New(ROW_GRD, 2, (nGrdW - 15), nGrdH, , , , ;
                           oDlg, , , , , , , , , , , , , , .T., , , , .T., .T.)
    oBrw:SetArray(aData)

    // Coluna de selecao checkbox
    oBrw:AddColumn(TCColumn():New("",;
        {|| IIf(aData[oBrw:nAt][POS_MARK], "LBOK", "LBNO")},;
        , , , "LEFT", 20, .T., .F.))

    oBrw:AddColumn(TCColumn():New("",;
        {|| IIf(aData[oBrw:nAt][POS_STATUS] == STR0002, oClrOk, oClrErr)},; // Sucesso
        , , , "CENTER", 10, .T., .F.))

    oBrw:AddColumn(TCColumn():New(STR0008,; // Status
        {|| aData[oBrw:nAt][POS_STATUS]},;
        , , , "LEFT", 50, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0032,; // Chassi
        {|| aData[oBrw:nAt][POS_CHASSI]},;
        , , , "LEFT", 80, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0033,; // Evento
        {|| aData[oBrw:nAt][POS_CODEVT]},;
        , , , "LEFT", 25, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0033,; // Evento
        {|| aData[oBrw:nAt][POS_DESCEVT]},;
        , , , "LEFT", 100, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0014,; // Metodo
        {|| aData[oBrw:nAt][POS_METODO]},;
        , , , "LEFT", 35, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0009,; // Resp. HTTP
        {|| aData[oBrw:nAt][POS_RESPHTTP]},;
        , , , "LEFT", 40, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0005,; // Filial
        {|| aData[oBrw:nAt][POS_FILIAL]},;
        , , , "LEFT", 30, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0010,; // UUID
        {|| aData[oBrw:nAt][POS_UUID]},;
        , , , "LEFT", 60, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0011,; // Tipo de Dado
        {|| aData[oBrw:nAt][POS_TIPODADO]},;
        , , , "LEFT", 80, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0007,; // Data Inclusao
        {|| aData[oBrw:nAt][POS_DATINC]},;
        , , , "LEFT", 90, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0013,; // URL Requisicao
        {|| aData[oBrw:nAt][POS_URL]},;
        , , , "LEFT", 150, .F., .F.))

    oBrw:AddColumn(TCColumn():New(STR0034,; // Resp.Req.
        {|| "Memo" },;
        , , , "LEFT", 60, .F., .F.))

    oBrw:bLDblClick := {|| IIf(oBrw:nColPos == Len(oBrw:aColumns), OA6170036M_ExibirRespBody(), OA6170009M_ToggleMark())}
    oBrw:bChange    := {|| OA6170010M_SelecionaLinha()}
    oBrw:Refresh()
Return

/*/{Protheus.doc} OA6170006M_CriaDetalhe
Cria os campos Memo (Body e Historico) diretamente no oDlg.
@type Static Function
@return Nil
/*/
Static Function OA6170006M_CriaDetalhe()
    Local oFntBold := TFont():New('Arial',, -11,, .T.)
    Local oSayBody := Nil
    Local oSayResp := Nil
    
    oFntBold:Bold := .T.

    oSayBody := TSay():New(nDtlLabY, 5, {|| STR0015}, oDlg, , oFntBold, , , , .T., , , 50, 10) // Req.Body
    oMBody := TMultiGet():New(nDtlMemY, 5, ;
        {|u| IIf(PCount() > 0, cMemBod := u, cMemBod)}, ;
        oDlg, nMemW, nMemH, , , , , , .T.)
    oMBody:lReadOnly := .T.

    oSayResp := TSay():New(nDtlLabY, nMidX + 15, {|| STR0016}, ; // Historico de Processamento
                           oDlg, , oFntBold, , , , .T., , , 120, 10)
    oMResp := TMultiGet():New(nDtlMemY, nMidX + 15, ;
        {|u| IIf(PCount() > 0, cMenHist := u, cMenHist)}, ;
        oDlg, nMemW, nMemH, , , , , , .T.)
    oMResp:lReadOnly := .T.
Return

/*/{Protheus.doc} OA6170007M_CriaBotao
Cria os botoes do oDlg.
@type Static Function
@return Nil
/*/
Static Function OA6170007M_CriaBotao()
    Local nRowFlt := ROW_FLT - 2           // linha dos botoes da area de filtro
    Local nRowRdp := nDtlMemY + nMemH + 5  // linha dos botoes do rodape
    Local nBtnX   := (nDlgW / 2) - 130

    oBtnPesq := TButton():New(nRowFlt, (nDlgW / 2) - 50, STR0017, oDlg, {|| OA6170011M_ExecFiltro()}, 40, 14, , , .F., .T., .F., , .F., , , .F.) // Pesquisar
    oBtnPesq:SetCss("QPushButton{background-color:#1976D2; color:#FFFFFF; font-weight:bold; border-radius:3px;}")

    oBtnLeg :=  TButton():New(nRowFlt, (nDlgW / 2) - 90, "Legenda", oDlg, {|| OA6170040M_Legenda()}, 35, 14, , , .F., .T., .F., , .F., , , .F.)

    oBtnCancel := TButton():New(nRowRdp, nBtnX, STR0018, oDlg, {|| oDlg:End()}, 50, 14, , , .F., .T., .F., , .F., , , .F.) // Cancelar

    oBtnRepr := TButton():New(nRowRdp, nBtnX + 60, STR0019, oDlg, ; // Reprocessar Evento
                              {|| OA6170022M_ReprocessarEvento()}, 70, 14, , , .F., .T., .F., , .F., , , .F.)
    oBtnRepr:SetCss("QPushButton{background-color:#1976D2; color:#FFFFFF; font-weight:bold; border-radius:3px;}")
Return

/*/{Protheus.doc} OA6170001M_IniciaFiltros
Inicializa os filtros com valores padrao.
@type Static Function
@return Nil
/*/
Static Function OA6170001M_IniciaFiltros()
    cFltFil := FWCodFil()
    cFltCha := Space(100)
    dFltDat := CtoD("")
    cFltSta := aStaOpt[FLT_ERROPEND]
Return

/*/{Protheus.doc} OA6170011M_ExecFiltro
Executa a pesquisa com base nos filtros atuais e atualiza o grid.
@type Static Function
@return Nil
/*/
Static Function OA6170011M_ExecFiltro()
    OA6170002M_CarregaDados()
    OA6170012M_AtualizaGrid()
    OA6170010M_SelecionaLinha()
Return

/*/{Protheus.doc} OA6170002M_CarregaDados
Carrega os dados da VK5 via servico, aplicando os filtros atuais.
@type Static Function
@return Nil
/*/
Static Function OA6170002M_CarregaDados()
    Local cDataDe  := ""
    Local cChassi  := ""
    Local nStatus  := 1

    If !Empty(dFltDat)
        cDataDe := DtoS(dFltDat)
    EndIf
    cChassi := AllTrim(cFltCha)
    nStatus := Max(aScan(aStaOpt, cFltSta), 1)
    aData := OA6170013M_Query(AllTrim(cFltFil), cChassi, cDataDe, nStatus)
    If Len(aData) == 0
        OA6170008M_AddLinhaVazia()
    EndIf
Return

/*/{Protheus.doc} OA6170012M_AtualizaGrid
Atualiza o TCBrowse com os dados atuais.
@type Static Function
@return Nil
/*/
Static Function OA6170012M_AtualizaGrid()
    If oBrw != Nil
        oBrw:SetArray(aData)
        oBrw:GoTop()
        oBrw:Refresh()
    EndIf
Return

/*/{Protheus.doc} OA6170010M_SelecionaLinha
Atualiza os paineis de detalhe ao selecionar uma linha no grid.
@type Static Function
@return Nil
/*/
Static Function OA6170010M_SelecionaLinha()
    Local nLine := 0

    If oBrw == Nil .Or. Len(aData) == 0
        OA6170021M_LimpaDetalhes()
        Return
    EndIf
    nLine := oBrw:nAt
    If nLine < 1 .Or. nLine > Len(aData)
        OA6170021M_LimpaDetalhes()
        Return
    EndIf
    If aData[nLine][POS_RECNO] == 0
        OA6170021M_LimpaDetalhes()
        Return
    EndIf

    cMemBod := aData[nLine][POS_REQBODY]
    cMemBod := OA6170035M_JsonFormat(cMemBod)

    DbSelectArea("VK5")
    VK5->(DbGoTo(aData[nLine][POS_RECNO]))
    cMenHist := AllTrim(VK5->VK5_HISTOR)

    If oMBody != Nil
        oMBody:Refresh()
    EndIf
    If oMResp != Nil
        oMResp:Refresh()
    EndIf
Return

/*/{Protheus.doc} OA6170009M_ToggleMark
Alterna o checkbox de selecao da linha atual no grid.
@type Static Function
@return Nil
/*/
Static Function OA6170009M_ToggleMark()
    Local nLine     := 0
    Local lNovoMark := .F.

    If oBrw == Nil .Or. Len(aData) == 0
        Return
    EndIf
    nLine := oBrw:nAt
    If nLine < 1 .Or. nLine > Len(aData) .Or. aData[nLine][POS_RECNO] == 0
        Return
    EndIf

    lNovoMark := !aData[nLine][POS_MARK]
    aData[nLine][POS_MARK] := lNovoMark

    If lNovoMark
        OA6170037M_MarcarPredecessores(nLine)
    EndIf
    oBrw:Refresh()
Return

/*/{Protheus.doc} OA6170037M_MarcarPredecessores
Executa o reprocessamento dos eventos selecionados.
@type Static Function
@return Nil
/*/
Static Function OA6170037M_MarcarPredecessores(nLinhaRef)
    Local cOriKey    := aData[nLinhaRef][POS_ORIKEY]
    Local nRecnoRef  := aData[nLinhaRef][POS_RECNO]
    Local nI         := 0
    Local nMarcados  := 0
    Local nForaGrid  := 0
    Local nTotalPred := 0

    For nI := 1 To Len(aData)
        If nI == nLinhaRef
            Loop
        EndIf
        If aData[nI][POS_ORIKEY] == cOriKey .And. aData[nI][POS_RECNO] < nRecnoRef .And. aData[nI][POS_RECNO] > 0 .And. !aData[nI][POS_MARK]
            DbSelectArea("VK5")
            VK5->(DbGoTo(aData[nI][POS_RECNO]))
            If AllTrim(VK5->VK5_STATUS) == VK5_STA_PENDENTE .Or. AllTrim(VK5->VK5_STATUS) == VK5_STA_ERRO
                aData[nI][POS_MARK] := .T.
                nMarcados++
            EndIf
        EndIf
    Next nI

    nTotalPred := OA6170038M_ContarPredecessoresBase(cOriKey, nRecnoRef)
    nForaGrid  := nTotalPred - nMarcados

    If nForaGrid > 0
        aData[nLinhaRef][POS_MARK] := .F.
        For nI := 1 To Len(aData)
            If nI != nLinhaRef .And. aData[nI][POS_ORIKEY] == cOriKey .And. aData[nI][POS_RECNO] < nRecnoRef
                aData[nI][POS_MARK] := .F.
            EndIf
        Next nI        
        FWAlertWarning( ;
            STR0035 + CRLF + CRLF + ; // Nao e permitido reprocessar este evento.
            AllTrim(Str(nForaGrid)) + " " + STR0036 + CRLF + ; // evento(s) predecessor(es) do mesmo chassi
            STR0037 + CRLF + CRLF + ; // que NAO estao visiveis no grid atual (filtro diferente).
            STR0038, ; // Altere o filtro para Erro + Pendente para visualizar e reprocessar todos os eventos
            STR0039) // Reprocessamento Bloqueado - Predecessores Pendentes
    ElseIf nMarcados > 0
        FWAlertInfo( ;
            AllTrim(Str(nMarcados)) + " " + STR0036 + CRLF + ; // evento(s) predecessor(es) do mesmo chassi
            STR0040, ; // foram marcados automaticamente para reprocessamento.
            STR0041) // Predecessores Marcados
    EndIf
Return

/*/{Protheus.doc} OA6170038M_ContarPredecessoresBase
Reprocessa um unico evento.
@type Static Function
@param nLine, Numerico, Indice da linha no array aData
@return Logico, .T. se reprocessou com sucesso
/*/
Static Function OA6170038M_ContarPredecessoresBase(cOriKey, nRecnoRef)
    Local nTotal   := 0
    Local cAlias   := ""
    Local cQuery   := ""
    Local oStmt    := Nil
    Local cDatInc  := ""
    Local aArea    := GetArea()

    Default cOriKey   := ""
    Default nRecnoRef := 0

    If Empty(cOriKey) .Or. nRecnoRef <= 0
        RestArea(aArea)
        Return nTotal
    EndIf

    DbSelectArea("VK5")
    VK5->(DbGoTo(nRecnoRef))
    cDatInc := AllTrim(VK5->VK5_DATINC)

    If Empty(cDatInc)
        RestArea(aArea)
        Return nTotal
    EndIf

    cQuery := " SELECT COUNT(*) AS QTDE "
    cQuery += " FROM " + RetSQLName("VK5") + " VK5 "
    cQuery += " WHERE VK5.D_E_L_E_T_ = ' ' "
    cQuery += "   AND VK5_DATTYP = ? "
    cQuery += "   AND VK5_ORIKEY = ? "
    cQuery += "   AND VK5_STATUS IN (?, ?) "
    cQuery += "   AND VK5_DATINC < ? "
    cQuery += "   AND VK5.R_E_C_N_O_ <> ? "
    cQuery := ChangeQuery(cQuery)

    oStmt := FWExecStatement():New(cQuery)    
    oStmt:SetString(1, VK5_DATTYP_CT)
    oStmt:SetString(2, cOriKey)
    oStmt:SetString(3, VK5_STA_PENDENTE)
    oStmt:SetString(4, VK5_STA_ERRO)
    oStmt:SetString(5, cDatInc)
    oStmt:SetNumeric(6, nRecnoRef)

    cAlias := oStmt:OpenAlias()

    If !(cAlias)->(EoF())
        nTotal := (cAlias)->QTDE
    EndIf

    (cAlias)->(DbCloseArea())
    RestArea(aArea)
Return nTotal

/*/{Protheus.doc} OA6170022M_ReprocessarEvento
Executa o reprocessamento dos eventos selecionados.
@type Static Function
@return Nil
/*/
Static Function OA6170022M_ReprocessarEvento()
    Local aSelected     := {}
    Local nI            := 0
    Local nLine         := 0
    Local nSuccess      := 0
    Local nFail         := 0
    Local nSkip         := 0
    Local nSkipStatus   := 0
    Local lResult       := .F.
    Local cStatus       := ""
    Local cOriKey       := ""
    Local cOriKeyAnt    := ""
    Local lFalhouChassi := .F.

    If oBrw == Nil .Or. Len(aData) == 0
        FMX_HELP("OA6170022A", STR0020) // Nenhum registro disponivel para reprocessamento.
        Return
    EndIf

    aSelected := OA6170020M_GetSel()

    If Len(aSelected) == 0
        nLine := oBrw:nAt
        If nLine >= 1 .And. nLine <= Len(aData) .And. aData[nLine][POS_RECNO] > 0
            aAdd(aSelected, nLine)
        EndIf
    EndIf

    If Len(aSelected) == 0
        FMX_HELP("OA6170022B", STR0021) // Selecione ao menos um registro para reprocessar.
        Return
    EndIf

    OA6170033M_OrdenarPorChassi(aSelected)

    If !FWAlertYesNo(;
        STR0022 + AllTrim(Str(Len(aSelected))) + STR0023, ; // Deseja reprocessar ,  evento(s)?
        STR0024) // Confirmacao de Reprocessamento
        Return
    EndIf

    ProcRegua(Len(aSelected))
    cOriKeyAnt    := ""
    lFalhouChassi := .F.

    For nI := 1 To Len(aSelected)
        IncProc(STR0025 + AllTrim(Str(nI)) + STR0026 + AllTrim(Str(Len(aSelected))) + "...") // Reprocessando ,  de 
        nLine := aSelected[nI]

        If nLine < 1 .Or. nLine > Len(aData) .Or. aData[nLine][POS_RECNO] <= 0
            Loop
        EndIf

        cOriKey := aData[nLine][POS_ORIKEY]
        If cOriKey != cOriKeyAnt
            cOriKeyAnt    := cOriKey
            lFalhouChassi := .F.
        EndIf

        If lFalhouChassi
            nSkip++
            Loop
        EndIf

        DbSelectArea("VK5")
        VK5->(DbGoTo(aData[nLine][POS_RECNO]))
        cStatus := AllTrim(VK5->VK5_STATUS)
        If cStatus != VK5_STA_PENDENTE .And. cStatus != VK5_STA_ERRO
            nSkipStatus++
            Loop
        EndIf

        lResult := OA6170023M_ProcessaItem(nLine)
        If lResult
            nSuccess++
        Else
            nFail++
            lFalhouChassi := .T.
        EndIf
    Next nI

    FWAlertInfo( ;
        STR0027 + CRLF + ; // Reprocessamento concluido.
        STR0028 + AllTrim(Str(nSuccess)) + CRLF + ; // Sucesso: 
        STR0029 + AllTrim(Str(nFail)) + ; // Falha: 
        IIf(nSkip > 0, CRLF + "Suspensos (chassi anterior falhou): " + AllTrim(Str(nSkip)), "") + ;
        IIf(nSkipStatus > 0, CRLF + "Ignorados (ja processados): " + AllTrim(Str(nSkipStatus)), ""), ;
        STR0030 ; // Resultado
    )
    OA6170011M_ExecFiltro()
Return

/*/{Protheus.doc} OA6170023M_ProcessaItem
Reprocessa um unico evento.
@type Static Function
@param nLine, Numerico, Indice da linha no array aData
@return Logico, .T. se reprocessou com sucesso
/*/
Static Function OA6170023M_ProcessaItem(nLine)
    Local lRet   := .F.
    Local nRecno := 0

    If nLine < 1 .Or. nLine > Len(aData)
        Return lRet
    EndIf
    nRecno := aData[nLine][POS_RECNO]
    If nRecno <= 0
        Return lRet
    EndIf

    lRet := OA6170024M_ReprocessarVK5(nRecno, Nil, "")
Return lRet

/*/{Protheus.doc} OA6170024M_ReprocessarVK5
    Reprocessa
    @type   Static Function
    @return Array Parametros do Schedule
/*/
Static Function OA6170024M_ReprocessarVK5(nRecno, oConfig, cToken)
    Local lRet    := .F.
    Local oReproc := OFSReprocessarControlTower():New()
    Local cRet    := ""

    Default oConfig := Nil
    Default cToken  := ""

    If ValType(oConfig) == "J"
        oReproc:SetConfig(oConfig)
    EndIf
    If !Empty(cToken)
        oReproc:SetToken(cToken)
    EndIf

    cRet := oReproc:ExecutarReprocessamento(nRecno)
    lRet := (cRet == "SUCESSO")
Return lRet

/*/{Protheus.doc} OA6170033M_OrdenarPorChassi
    Ordena por chassi    
    @type   Static Function
    @return Array Parametros do Schedule
/*/
Static Function OA6170033M_OrdenarPorChassi(aSelected)
    Local nI     := 0
    Local nJ     := 0
    Local nLen   := Len(aSelected)
    Local nTemp  := 0
    Local cKeyI  := ""
    Local cKeyJ  := ""
    Local nLineI := 0
    Local nLineJ := 0

    If nLen <= 1
        Return
    EndIf

    For nI := 1 To nLen - 1
        For nJ := nI + 1 To nLen
            nLineI := aSelected[nI]
            nLineJ := aSelected[nJ]
            If nLineI >= 1 .And. nLineI <= Len(aData) .And. nLineJ >= 1 .And. nLineJ <= Len(aData)
                cKeyI := aData[nLineI][POS_ORIKEY]
                cKeyJ := aData[nLineJ][POS_ORIKEY]
                If cKeyI > cKeyJ .Or. (cKeyI == cKeyJ .And. aData[nLineI][POS_RECNO] > aData[nLineJ][POS_RECNO])
                    nTemp         := aSelected[nI]
                    aSelected[nI] := aSelected[nJ]
                    aSelected[nJ] := nTemp
                EndIf
            EndIf
        Next nJ
    Next nI
Return


/*/{Protheus.doc} OA6170020M_GetSel
Retorna array com os indices das linhas marcadas no grid.
@type Static Function
@return Array, Indices das linhas marcadas
/*/
Static Function OA6170020M_GetSel()
    Local aRet := {}
    Local nI   := 0
    For nI := 1 To Len(aData)
        If aData[nI][POS_MARK]
            aAdd(aRet, nI)
        EndIf
    Next nI
Return aRet

/*/{Protheus.doc} OA6170008M_AddLinhaVazia
Adiciona uma linha vazia ao array de dados.
@type Static Function
@return Nil
/*/
Static Function OA6170008M_AddLinhaVazia()
    aData := {{.F., "", "", "", "", "", "", "", "", "", "", "", "", 0, "", "", "", "", "", ""}}
Return

/*/{Protheus.doc} OA6170021M_LimpaDetalhes
Limpa os paineis de detalhe.
@type Static Function
@return Nil
/*/
Static Function OA6170021M_LimpaDetalhes()
    cMemBod  := ""
    cMenHist := ""
    If oMBody != Nil
        oMBody:Refresh()
    EndIf
    If oMResp != Nil
        oMResp:Refresh()
    EndIf
Return

Static Function OA6170040M_Legenda()
    Local aLegenda := {}
    aAdd(aLegenda, {"BR_VERDE",    STR0002}) // Sucesso
    aAdd(aLegenda, {"BR_VERMELHO", STR0001}) // Erro
    BrwLegenda(cCadastro, "Legenda", aLegenda)
Return

Static Function OA6170036M_ExibirRespBody()
    Local nLine     := 0
    Local cConteudo := ""
    Local oModal    := Nil
    Local oGet      := Nil
    Local oFont     := TFont():New('Courier New',, -12,, .F.)

    If oBrw == Nil .Or. Len(aData) == 0
        Return
    EndIf
    nLine := oBrw:nAt
    If nLine < 1 .Or. nLine > Len(aData) .Or. aData[nLine][POS_RECNO] == 0
        Return
    EndIf

    DbSelectArea("VK5")
    VK5->(DbGoTo(aData[nLine][POS_RECNO]))
    cConteudo := AllTrim(VK5->VK5_RESBOD)
    cConteudo := OA6170035M_JsonFormat(cConteudo)

    oModal := FWDialogModal():New()
    oModal:SetEscClose(.T.)
    oModal:SetTitle("Body da Resposta - Control Tower")
    oModal:SetSize(300, 400)
    oModal:CreateDialog()

    oModal:AddButton("JSON", {|| cConteudo := OA6170035M_JsonFormat(cConteudo), oGet:Refresh()}, "Formata conteudo JSON", , .T., .F., .T.)
    oModal:AddButton("Sair", {|| oModal:DeActivate()}, "Fechar", , .T., .F., .T.)

    oGet := TMultiGet():New(0, 0, {|u| IIf(PCount() > 0, cConteudo := u, cConteudo)}, ;
                            oModal:GetPanelMain(), 399, 049, oFont, .F., , , , .T.)
    oGet:lReadOnly := .T.
    oGet:Align := CONTROL_ALIGN_ALLCLIENT

    oModal:Activate()
Return

/*/{Protheus.doc} OA6170013M_Query
Consulta registros na VK5 aplicando os filtros informados.
Retorna array pronto para exibicao no grid.
@type Static Function
@param cRestFil,  Caracter, Filial para filtro
@param cChassi,   Caracter, Chassi para filtro (busca no body JSON)
@param cDataDe,   Caracter, Data inicial no formato YYYYMMDD (vazio = sem filtro)
@param nStatus,   Numerico, 1=Erro, 2=Sucesso, 3=Todos
@return Array, Array de registros formatados para o grid
/*/
Static Function OA6170013M_Query(cRestFil, cChassi, cDataDe, nStatus)
    Local aRet        := {}
    Local cAlias      := ""
    Local cQuery      := ""
    Local cWhere      := ""
    Local aBinds      := {}
    Local aVx5Binds   := {}
    Local oStatement  := Nil
    Local aRecMemo    := {}
    Local nI          := 0

    Default cRestFil := ""
    Default cChassi  := ""
    Default cDataDe  := ""
    Default nStatus  := FLT_ERRO

    OA6170014M_BuildWhere(cRestFil, cDataDe, nStatus, @cWhere, @aBinds)

    cQuery := " SELECT "
    cQuery += "     VK5.R_E_C_N_O_ AS NRECNO, "
    cQuery += "     VK5_FILIAL, "
    cQuery += "     VK5_UUID, "
    cQuery += "     ISNULL(VX5DAT.VX5_DESCRI, '') AS DESCTYP, "
    cQuery += "     VK5_ORIGEM, "
    cQuery += "     ISNULL(VX5MES.VX5_DESCRI, '') AS DESCMSG, "
    cQuery += "     VK5_ORITAB, "
    cQuery += "     VK5_ORIKEY, "
    cQuery += "     VK5_RESCOD, "
    cQuery += "     VK5_DATINC, "
    cQuery += "     VK5_DATALT, "
    cQuery += "     VK5_DATTYP, "
    cQuery += "     VK5_MESSAG, "
    cQuery += "     VK5_URLREQ "
    cQuery += " FROM " + RetSQLName("VK5") + " VK5 "
    cQuery += " LEFT JOIN " + RetSQLName("VX5") + " VX5DAT "
    cQuery += "   ON VX5DAT.VX5_CHAVE = ? "
    cQuery += "   AND VX5DAT.VX5_CODIGO = VK5_DATTYP "
    cQuery += "   AND VX5DAT.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN " + RetSQLName("VX5") + " VX5MES "
    cQuery += "   ON VX5MES.VX5_CHAVE = ? "
    cQuery += "   AND VX5MES.VX5_CODIGO = VK5_MESSAG "
    cQuery += "   AND VX5MES.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE VK5.D_E_L_E_T_ = ' ' "
    cQuery +=   cWhere
    cQuery += " ORDER BY VK5_DATINC ASC, VK5_ORIKEY ASC, VK5_MESSAG ASC "

    cQuery := ChangeQuery(cQuery)
    oStatement := FwExecStatement():New(cQuery)

    aAdd(aVx5Binds, {BIND_STRING, DATTYP_VX5})
    aAdd(aVx5Binds, {BIND_STRING, MESSAG_VX5})
    For nI := 1 To Len(aBinds)
        aAdd(aVx5Binds, aBinds[nI])
    Next
    aBinds := aClone(aVx5Binds)

    For nI := 1 To Len(aBinds)
        If aBinds[nI][1] == BIND_STRING
            oStatement:setString(nI, aBinds[nI][2])
        ElseIf aBinds[nI][1] == BIND_NUMERIC
            oStatement:setNumeric(nI, aBinds[nI][2])
        EndIf
    Next nI

    cAlias := oStatement:OpenAlias()
    While (cAlias)->(!Eof())
        aRecMemo := OA6170015M_MontaLinhaGrid(cAlias, cChassi)
        If Len(aRecMemo) > 0
            aAdd(aRet, aRecMemo)
        EndIf
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())
    oStatement:Destroy()
    oStatement := Nil
Return aRet

/*/{Protheus.doc} OA6170014M_BuildWhere
Monta a clausula WHERE dinamica
@type Static Function
@param cRestFil,  Caracter, Filial
@param cDataDe,   Caracter, Data no formato YYYYMMDD
@param nStatus,   Numerico, Filtro de status
@param cWhere,    Caracter, Clausula WHERE 
@param aBinds,    Array,    Array de binds {{nTipo, xValor}, ...}
@return Nil
/*/
Static Function OA6170014M_BuildWhere(cRestFil, cDataDe, nStatus, cWhere, aBinds)
    Default cWhere := ""
    Default aBinds := {}
    cWhere := ""
    aBinds := {}

    If !Empty(cRestFil)
        cWhere += " AND LEFT(VK5_ORIKEY, ?) = ? "
        aAdd(aBinds, {BIND_NUMERIC, Len(cRestFil)})
        aAdd(aBinds, {BIND_STRING, cRestFil})
    EndIf

    If !Empty(cDataDe)
        cWhere += " AND LEFT(VK5_DATINC, 8) = ? "
        aAdd(aBinds, {BIND_STRING, cDataDe})
    EndIf

    Do Case
        Case nStatus == FLT_ERRO
            cWhere += " AND (VK5_RESCOD = ? OR VK5_RESCOD >= ?) "
            aAdd(aBinds, {BIND_NUMERIC, 0})
            aAdd(aBinds, {BIND_NUMERIC, 400})
        Case nStatus == FLT_SUCESSO
            cWhere += " AND (VK5_RESCOD >= ? AND VK5_RESCOD < ?) "
            aAdd(aBinds, {BIND_NUMERIC, 200})
            aAdd(aBinds, {BIND_NUMERIC, 300})
        Case nStatus == FLT_ERROPEND
            cWhere += " AND VK5_STATUS IN (?, ?) "
            aAdd(aBinds, {BIND_STRING, VK5_STA_PENDENTE})
            aAdd(aBinds, {BIND_STRING, VK5_STA_ERRO})
    EndCase
Return

/*/{Protheus.doc} OA6170015M_MontaLinhaGrid
Processa um registro da query e monta a linha do grid.
Se houver filtro de chassi, valida contra o body JSON.
@type Static Function
@param cAlias,  Caracter, Alias da query aberta
@param cChassi, Caracter, Filtro de chassi (vazio = sem filtro)
@return Array, Array com dados da linha ou array vazio se nao atender filtro
/*/
Static Function OA6170015M_MontaLinhaGrid(cAlias, cChassi)
    Local aRow        := {}
    Local nRecno      := (cAlias)->NRECNO
    Local cReqBod     := ""
    Local cResBod     := ""
    Local cChasBody   := ""
    Local cChasOriKey := ""

    Default cChassi := ""

    DbSelectArea("VK5")
    VK5->(DbGoTo(nRecno))
    cReqBod     := AllTrim(VK5->VK5_REQBOD)
    cResBod     := AllTrim(VK5->VK5_RESBOD)
    cChasOriKey := OA6170039M_ExtrairChassiDaOriKey(AllTrim(VK5->VK5_ORIKEY))

    If !Empty(cChassi)
        cChasBody := OA6170017M_RetornaChassi(cReqBod)
        If !(Upper(AllTrim(cChassi)) $ Upper(cChasOriKey)) .And. ;
           (Empty(cChasBody) .Or. !(Upper(AllTrim(cChassi)) $ Upper(cChasBody)))
            Return aRow
        EndIf
    EndIf

    aRow := { ;
        .F.,;                                                           // [01] POS_MARK
        OA6170016M_RetornaStatus((cAlias)->VK5_RESCOD),;                // [02] POS_STATUS
        "POST",;                                                        // [03] POS_METODO
        AllTrim(Str((cAlias)->VK5_RESCOD, 3)),;                         // [04] POS_RESPHTTP
        AllTrim((cAlias)->VK5_FILIAL),;                                 // [05] POS_FILIAL
        cChasOriKey,;                                                   // [06] POS_CHASSI
        AllTrim((cAlias)->VK5_MESSAG),;                                 // [07] POS_CODEVT
        AllTrim((cAlias)->DESCMSG),;                                    // [08] POS_DESCEVT
        SubStr(AllTrim((cAlias)->VK5_UUID), 1, 10) + "...",;            // [09] POS_UUID
        AllTrim((cAlias)->DESCTYP),;                                    // [10] POS_TIPODADO
        OA6170018M_FormataData(AllTrim((cAlias)->VK5_DATINC)),;         // [11] POS_DATINC
        AllTrim((cAlias)->VK5_URLREQ),;                                 // [12] POS_URL
        cReqBod,;                                                       // [13] POS_REQBODY
        nRecno,;                                                        // [14] POS_RECNO
        AllTrim((cAlias)->VK5_ORIKEY),;                                 // [15] POS_ORIKEY
        AllTrim((cAlias)->VK5_DATTYP),;                                 // [16] POS_DATTYP
        AllTrim((cAlias)->VK5_MESSAG),;                                 // [17] POS_MESSAG
        AllTrim((cAlias)->VK5_ORITAB),;                                 // [18] POS_ORITAB
        AllTrim((cAlias)->VK5_UUID),;                                   // [19] POS_FULLUUID
        cResBod;                                                        // [20] POS_RESBOD
    }
Return aRow

/*/{Protheus.doc} OA6170016M_RetornaStatus
Deriva o status de processamento a partir do codigo de resposta HTTP.
Regra: 200-299 = Sucesso, qualquer outro (incluindo 0) = Erro.
@type Static Function
@param nRescod, Numerico, Codigo HTTP de resposta
@return Caracter, Status derivado (Erro/Sucesso)
/*/
Static Function OA6170016M_RetornaStatus(nRescod)
    Default nRescod := 0
Return IIf(nRescod >= 200 .And. nRescod < 300, STR0002, STR0001) // Sucesso, Erro

/*/{Protheus.doc} OA6170017M_RetornaChassi
Extrai o valor do campo chassi do JSON armazenado no VK5_REQBOD.
@type Static Function
@param cBody, Caracter, Conteudo do campo memo VK5_REQBOD
@return Caracter, Valor do chassi encontrado ou vazio
/*/
Static Function OA6170017M_RetornaChassi(cBody)
    Local cChassi := ""
    Default cBody := ""
    If Empty(cBody)
        Return cChassi
    EndIf
    cChassi := OA6170019M_JsonValue(cBody, "chassiVeiculo")
    If Empty(cChassi)
        cChassi := OA6170019M_JsonValue(cBody, "chassis")
    EndIf
    If Empty(cChassi)
        cChassi := OA6170019M_JsonValue(cBody, "chassi")
    EndIf
Return AllTrim(cChassi)

/*/{Protheus.doc} OA6170018M_FormataData
Formata timestamp "YYYYMMDDHHMMSS" para "DD/MM/YYYY HH:MM:SS".
@type Static Function
@param cTimestamp, Caracter, Timestamp no formato YYYYMMDDHHMMSS
@return Caracter, Data formatada DD/MM/YYYY HH:MM:SS
/*/
Static Function OA6170018M_FormataData(cTimestamp)
    Local cFmt := ""
    Default cTimestamp := ""
    If Len(AllTrim(cTimestamp)) < 14
        Return cTimestamp
    EndIf
    cFmt := SubStr(cTimestamp, 7, 2) + "/"
    cFmt += SubStr(cTimestamp, 5, 2) + "/"
    cFmt += SubStr(cTimestamp, 1, 4) + " "
    cFmt += SubStr(cTimestamp, 9, 2) + ":"
    cFmt += SubStr(cTimestamp, 11, 2) + ":"
    cFmt += SubStr(cTimestamp, 13, 2)
Return cFmt

/*/{Protheus.doc} OA6170019M_JsonValue
Extrai o valor de uma chave de um JSON.
@type Static Function
@param cJson, Caracter, String JSON
@param cKey,  Caracter, Nome da chave a buscar
@return Caracter, Valor encontrado ou vazio
/*/
Static Function OA6170019M_JsonValue(cJson, cKey)
    Local cValue  := ""
    Local cSearch := ""
    Local nPos    := 0
    Local nStart  := 0
    Local nEnd    := 0
    Default cJson := ""
    Default cKey  := ""

    If Empty(cJson) .Or. Empty(cKey)
        Return cValue
    EndIf
    cSearch := '"' + Lower(cKey) + '"'
    nPos := At(cSearch, Lower(cJson))
    If nPos == 0
        Return cValue
    EndIf
    nPos := At(":", cJson, nPos)
    If nPos == 0
        Return cValue
    EndIf
    nStart := nPos + 1
    While nStart <= Len(cJson) .And. SubStr(cJson, nStart, 1) $ ' "' + Chr(9) + Chr(10) + Chr(13)
        nStart++
    EndDo
    nEnd := nStart
    While nEnd <= Len(cJson) .And. !(SubStr(cJson, nEnd, 1) $ '",}')
        nEnd++
    EndDo
    If nEnd > nStart
        cValue := SubStr(cJson, nStart, nEnd - nStart)
    EndIf
Return AllTrim(cValue)


/*/{Protheus.doc} OA6170035M_JsonFormat
    Formata arquivo json    
    @type   Static Function
    @return Array Parametros do Schedule
/*/
Static Function OA6170035M_JsonFormat(cJson)
    Local cMsg    := ""
    Local nx      := 0
    Local nTab    := 0
    Local cMsg2   := ""
    Local cChar   := ""

    cMsg := FWCutOff(cJson)
    For nx := 1 To Len(cMsg)
        cChar := SubStr(cMsg, nx, 1)
        If cChar $ "{["
            cMsg2 += cChar
            nTab  += 4
            cMsg2 += CRLF
            cMsg2 += Replicate(" ", nTab)
        ElseIf cChar $ "]}"
            nTab  -= 4
            cMsg2 += CRLF
            cMsg2 += Replicate(" ", nTab)
            cMsg2 += cChar
        ElseIf cChar == ","
            cMsg2 += cChar
            cMsg2 += CRLF
            cMsg2 += Replicate(" ", nTab)
        Else
            cMsg2 += cChar
        EndIf
    Next
Return cMsg2

/*/{Protheus.doc} OA6170039M_ExtrairChassiDaOriKey
    Extrai chassi do campo VK5_ORIKEY
    @type   Static Function
    @return Array Parametros do Schedule
/*/
Static Function OA6170039M_ExtrairChassiDaOriKey(cOriKeyVK5)
    Local cChassiInt := ""
    Local nTamFil    := Len(AllTrim(cFilAnt))
    If Len(cOriKeyVK5) > nTamFil
        cChassiInt := SubStr(cOriKeyVK5, nTamFil + 1)
    EndIf
Return AllTrim(cChassiInt)

/*/{Protheus.doc} SchedDef
    Definicao para o Schedule do Protheus.    
    @type   Static Function
    @return Array Parametros do Schedule
/*/
Static Function SchedDef()
    Local aParam := {}
    Aadd(aParam, "P"  )  // 01 - Processo
    Aadd(aParam, ""   )  // 02 - Sem SX1 (limite via MV_CTREPRL, default 100)
    Aadd(aParam, ""   )  // 03 - Alias (apenas Relatorio)
    Aadd(aParam, {}   )  // 04 - Ordens (apenas Relatorio)
    Aadd(aParam, ""   )  // 05 - Titulo (apenas Relatorio)
    Aadd(aParam, ""   )  // 06 - Layout (apenas Relatorio)
    Aadd(aParam, .F.  )  // 07 - Sempre ativo: nao (LIB 20260413)
    Aadd(aParam, .T.  )  // 08 - Por filiais: sim (LIB 20260413)
Return aParam
