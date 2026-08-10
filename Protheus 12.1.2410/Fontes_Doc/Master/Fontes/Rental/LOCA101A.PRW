#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "LOCA101A.CH"
 
/*/{Protheus.doc} User Function LOCA101
APROVAÇÃO DE ORDEM DE SERVIÇO
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
 
Function LOCA101A(nApr)
Local aArea    := FWGetArea()
Local cOs      := FH1->FH1_ORDEM
Local aAreaFH1 := FH1->(GetArea())
Local cPed     := ""
Private nAp    := nApr
    
    If nApr == 2
        If MsgYesNo(STR0001,STR0001) //"Confirma a rejeição?"###"Atenção!"

            FH1->(dbSetOrder(1))
            FH1->(dbSeek(xFilial("FH1")+cOS))
            While !FH1->(Eof()) .and. FH1->(FH1_FILIAL+FH1_ORDEM) == xFilial("FH1")+cOS
                If !empty(FH1->FH1_PEDCOM)
                    cPed := FH1->FH1_PEDCOM
                    Exit
                EndIF
                FH1->(dbSkip())
            EndDo
            If !empty(cPed)
                Help( ,, "LOCA101",, STR0003, 1, 0,,,,,,{STR0004}) //"Inconsistênca nos dados."###"Não pode ser rejeitado um item com pedido de compras gerado."
                FH1->(RestArea(aAreaFH1))
                Return .F.
            EndIf

            FH1->(dbSetOrder(1))
            FH1->(dbSeek(xFilial("FH1")+cOS))
            While !FH1->(Eof()) .and. FH1->(FH1_FILIAL+FH1_ORDEM) == xFilial("FH1")+cOS
                FH1->(RecLock("FH1",.F.))
                FH1->FH1_STAPRO := "3"
                FH1->(MsUnlock())
                FH1->(dbSkip())
            EndDo
            FH1->(RestArea(aAreaFH1))
            Return .T.
        Else
            FH1->(RestArea(aAreaFH1))
            Return .T.
        EndIF
    EndIf

    fMontaTela()
     
    FWRestArea(aArea)
Return
 
/*/{Protheus.doc} fMontaTela
Monta a tela com a marcação de dados
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
 
Static Function fMontaTela()
Local aArea         := GetArea()
Local aCampos := {}
Local oTempTable := Nil
Local aColunas := {}
Local cFontPad    := 'Tahoma'
Local oFontGrid   := TFont():New(cFontPad, /*uPar2*/, -14)
Local bBlocoOk     := {|| lOk := .T., oDlgBrow:End()}
Local bBlocoCan    := {|| lOk := .F., oDlgBrow:End()}
Local aOutrasAc    := {}
Local bBlocoIni    := {|| EnchoiceBar(oDlgBrow, bBlocoOk, bBlocoCan, , aOutrasAc)}
Local cResult      := ""

Private lOk        := .F.
Private oDlgBrow
Private oPanGrid
Private oFWBrowse
Private cAliasTmp := GetNextAlias()
Private aTamanho := MsAdvSize()
Private nJanLarg := aTamanho[5]
Private nJanAltu := aTamanho[6]
Private oSayLog
Private cSayLog := "..."
Private oFont
Private oSay
Private nQtd := 0
Private nVlr := 0
Private nTotalQtd := 0
Private nTotalVlr := 0
Private cProdFilter := ''

    aAdd(aOutrasAc, {'BMP', {|| fMarkTod()}, STR0005}) //'* (Des) Marcar todos registros'
    oFont := TFont():New('Courier new',,-18,.T.)  
    aAdd(aCampos, { 'FLAG_OK'   , 'L', 1,                        0}) //Flag para marcação
    aAdd(aCampos, { 'FH1_CODIGO', 'C', TamSX3('FH1_CODIGO')[1],  0}) //Produto
    aAdd(aCampos, { 'B1_DESC'   , 'C', TamSX3('B1_DESC')[1],     0}) //Produto
    aAdd(aCampos, { 'FH1_QUANTI', 'N', TamSX3('FH1_QUANTI')[1],  0}) //Produto
    aAdd(aCampos, { 'FH1_VLRUNI', 'N', TamSX3('FH1_VLRUNI')[1],  0}) //Tipo
    aAdd(aCampos, { 'FH1_VLRTOT', 'N', TamSX3('FH1_VLRTOT')[1],  0}) //Unid. Med.
    aAdd(aCampos, { 'FH1_VLRAUN', 'N', TamSX3('FH1_VLRAUN')[1],  0}) //Descrição
    aAdd(aCampos, { 'FH1_VLRATO', 'N', TamSX3('FH1_VLRATO')[1],  0}) //Descrição
    aAdd(aCampos, { 'RECNO'     , 'N', 16,                       0}) //RecNo da SB1
 
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:Create()  
 
    Processa({|| fPopula()}, STR0006) //'Processando...'
 
    aColunas := fCriaCols(nAp)
      
    oDlgBrow := TDialog():New(0, 0, nJanAltu, nJanLarg, STR0007+FH1->FH1_ORDEM, , , , , , /*nCorFundo*/, , , .T.) //'Aprovação de Ordem de serviço: '
    Eval(bBlocoIni)
    @ 001,10 SAY oSay PROMPT STR0008+FH1->FH1_ORDEM SIZE 200,20 COLORS CLR_RED,CLR_RED FONT oFont OF oDlgBrow PIXEL //"Ordem de Serviço: "
    @ (001), 250 SAY oSay PROMPT STR0009 SIZE 200,20 COLORS CLR_RED,CLR_RED FONT oFont OF oDlgBrow PIXEL //"Qtd Total:"
    @ (001), 300 SAY oSay PROMPT nTotalQtd  PICTURE "999,999.99" SIZE 200,20 COLORS CLR_RED,CLR_RED FONT oFont OF oDlgBrow PIXEL
    @ (001), 380 SAY oSay PROMPT STR0010 SIZE 200,20 COLORS CLR_RED,CLR_RED FONT oFont OF oDlgBrow PIXEL //"Valor Total:"
    @ (001), 430 SAY oSay PROMPT nTotalVlr   PICTURE "999,999,999.99" SIZE 200,20 COLORS CLR_RED,CLR_RED FONT oFont OF oDlgBrow PIXEL

    SA2->(dbSetOrder(1))
    SA2->(dbSeek(xFilial("SA2")+FH1->FH1_CODFOR+FH1->FH1_LOJFOR))

    //DENNIS CALABREZ - DSERLOCA-8328 - 01/09/2025
    @ 015,10 SAY oSay PROMPT STR0032+alltrim(SA2->A2_NOME)+" / "+alltrim(FH1->FH1_CODFOR)+"/"+alltrim(FH1->FH1_LOJFOR) SIZE 200,20 OF oDlgBrow PIXEL
    @ 015,150 SAY oSay PROMPT STR0033+alltrim(Posicione('STJ', 1, FWxFilial('STJ') + FH1->FH1_ORDEM, 'TJ_PROJETO')) SIZE 200,20 OF oDlgBrow PIXEL
    @ 015,200 SAY oSay PROMPT STR0034+alltrim(Posicione('STJ', 1, FWxFilial('STJ') + FH1->FH1_ORDEM, 'TJ_OBRA')) SIZE 200,20 OF oDlgBrow PIXEL
    @ 015,250 SAY oSay PROMPT STR0035+alltrim(Posicione('STJ', 1, FWxFilial('STJ') + FH1->FH1_ORDEM, 'TJ_AS')) SIZE 200,20 OF oDlgBrow PIXEL

    oFWBrowse := FWBrowse():New()
    oFWBrowse:DisableFilter()
    oFWBrowse:DisableConfig()
    oFWBrowse:DisableReport()
    oFWBrowse:DisableSeek()
    oFWBrowse:DisableSaveConfig()
    oFWBrowse:SetFontBrowse(oFontGrid)
    oFWBrowse:SetAlias(cAliasTmp)
    oFWBrowse:SetDataTable()
    oFWBrowse:SetEditCell(.T., {|| .T.}) 
    oFWBrowse:lHeaderClick := .T.
    oFWBrowse:AddMarkColumns(;
        {|| Iif((cAliasTmp)->FLAG_OK, 'LBOK', 'LBNO') },;      //ícones
        {|| (cAliasTmp)->FLAG_OK := ! (cAliasTmp)->FLAG_OK,AtualizaTot(cAliasTmp)};   //ao dar duplo clique
    )
        
    oFWBrowse:SetColumns(aColunas)
    oFWBrowse:SetOwner(oDlgBrow)
    oFWBrowse:Activate()

    oDlgBrow:Activate(, , , .T., , , /*bBlocoIni*/)
 
    If lOk
        fConfirmou(nAp)
    EndIf
     
    oTempTable:Delete()
    oFWBrowse:DeActivate()
     
    RestArea(aArea)
Return
 
/*/{Protheus.doc} MenuDef
Botões usados no Browse
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
 /*
Static Function MenuDef()
    Local aRotina := {}
      
    //Criação das opções
    //ADD OPTION aRotina TITLE 'Continuar'  ACTION 'u_zVid72Ok'     OPERATION 2 ACCESS 0
Return aRotina
*/ 
/*/{Protheus.doc} fPopula
Executa a query SQL e popula essa informação na tabela temporária usada no browse
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
 
Static Function fPopula()
Local cQryDados := ''
Local nTotal := 0
Local nAtual := 0
 
    cQryDados := "SELECT FH1.FH1_CODIGO,FH1.FH1_VLRUNI,FH1.FH1_VLRTOT,FH1.FH1_VLRAUN, " //B1_COD, B1_TIPO, B1_UM, B1_DESC, SB1.R_E_C_N_O_ AS SB1REC "        + CRLF
    cQryDados += "FH1.FH1_VLRATO, FH1.R_E_C_N_O_ RECNO,FH1.FH1_QUANTI, SB1.B1_DESC "
    cQryDados += "FROM "+RetSqlName("FH1")+" FH1 "
    cQryDados += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON FH1.FH1_CODIGO = SB1.B1_COD "
    cQryDados += "AND SB1.B1_FILIAL = '" +xFilial("SB1") + "' AND SB1.D_E_L_E_T_ = '' "
    cQryDados += "WHERE FH1_ORDEM = ? AND FH1.D_E_L_E_T_ = ' ' AND FH1.FH1_FILIAL = '" +xFilial("FH1") + "' "
    cQryDados += "AND FH1_STAPRO = '1' "
    cQryDados += "ORDER BY FH1_SEQTAR"
    cQryDados := CHANGEQUERY(cQryDados)
    aBindParam := {FH1->FH1_ORDEM}
    MPSysOpenQuery(cQryDados,"QRYDADTMP",,,aBindParam)
 
    DbSelectArea('QRYDADTMP')
    Count to nTotal
    ProcRegua(nTotal)
    QRYDADTMP->(DbGoTop())
 
    While ! QRYDADTMP->(EoF())
        nAtual++
        IncProc(STR0011 + cValToChar(nAtual) + STR0012 + cValToChar(nTotal) + '...') //'Analisando registro '###' de '
 
        RecLock(cAliasTmp, .T.)
        (cAliasTmp)->FLAG_OK := .F.
        (cAliasTmp)->FH1_CODIGO := QRYDADTMP->FH1_CODIGO
        (cAliasTmp)->B1_DESC    := QRYDADTMP->B1_DESC
        (cAliasTmp)->FH1_QUANTI := QRYDADTMP->FH1_QUANTI
        (cAliasTmp)->FH1_VLRUNI := QRYDADTMP->FH1_VLRUNI
        (cAliasTmp)->FH1_VLRTOT := QRYDADTMP->FH1_VLRTOT
        (cAliasTmp)->FH1_VLRAUN := QRYDADTMP->FH1_VLRAUN
        (cAliasTmp)->FH1_VLRATO := QRYDADTMP->FH1_VLRATO
        (cAliasTmp)->RECNO      := QRYDADTMP->RECNO
        (cAliasTmp)->(MsUnlock())
 
        QRYDADTMP->(DbSkip())
    EndDo
    QRYDADTMP->(DbCloseArea())
    (cAliasTmp)->(DbGoTop())
Return
 
/*/{Protheus.doc} fCriaCols
Função que gera as colunas usadas no browse (similar ao antigo aHeader)
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
 
Static Function fCriaCols(nAp)
Local nAtual       := 0 
Local aColunas := {}
Local aEstrut  := {}
Local oColumn
     
    aAdd(aEstrut, { 'FH1_CODIGO', STR0013 , 'C', TamSX3('FH1_CODIGO')[1],  0, '',     .F.}) //'Produto'
    aAdd(aEstrut, { 'B1_DESC'   , STR0014 , 'C', TamSX3('B1_DESC')[1],  0, '',     .F.}) //'Descrição'
    aAdd(aEstrut, { 'FH1_QUANTI', STR0015 , 'C', TamSX3('FH1_QUANTI')[1],  0, '',     .F.}) //'Quantidade'
    aAdd(aEstrut, { 'FH1_VLRUNI', STR0016 , 'C', TamSX3('FH1_VLRUNI')[1], 0, PesqPict("FH1", "FH1_VLRUNI"),     .F.}) //'Vlr. Unitário'
    aAdd(aEstrut, { 'FH1_VLRTOT', STR0017 , 'C', TamSX3('FH1_VLRTOT')[1],   0, PesqPict("FH1", "FH1_VLRTOT"),     .F.}) //'Vlr. Total'
    If nAp == 1
        aAdd(aEstrut, { 'FH1_VLRAUN', STR0018,  'C', TamSX3('FH1_VLRAUN')[1], 0, PesqPict("FH1", "FH1_VLRAUN"),     .T.}) //'Vlr. Uni. Aprov'
    elseif nAp == 2
        aAdd(aEstrut, { 'FH1_VLRAUN', STR0018,  'C', TamSX3('FH1_VLRAUN')[1], 0, PesqPict("FH1", "FH1_VLRAUN"),     .F.}) //'Vlr. Uni. Aprov'    
    EndIf    
    aAdd(aEstrut, { 'FH1_VLRATO',   STR0019, 'C', TamSX3('FH1_VLRATO')[1],   0, PesqPict("FH1", "FH1_VLRATO"),     .F.}) //'Vlr. Total Aprov'
 
    For nAtual := 1 To Len(aEstrut)
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])
 
        If aEstrut[nAtual][7]
            oColumn:SetEdit(.T.)
            oColumn:SetReadVar(aEstrut[nAtual][1])
            oColumn:SetValid({|| VldValor(cAliasTmp)})
        EndIf
        aAdd(aColunas, oColumn)
    Next
Return aColunas
 
/*/{Protheus.doc} fConfirmou
Função acionada após fechar a tela se o usuário confirmou
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
 
Static Function fConfirmou(nAp)
    Processa({|| fProcessa(nAp)}, 'Processando...')
Return
 
/*/{Protheus.doc} fProcessa
Função que percorre os registros da tela
Aprova os Itens e gera pedido de compras
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
 
Static Function fProcessa(nAp)
Local aArea     := FWGetArea()
Local nAtual    := 0
Local nTotal    := 0
Local nTotMarc := 0
Local aCabec := {}
Local aItens := {}
Local cDoc := ""
Local nOpc := 3
Local aLinha := {}
Local lPrim := .T.
Local lRet := .T.
Local _LCVAL     := SUPERGETMV("MV_LOCX051",.F.,.T.)
PRIVATE lMsErroAuto := .F.

    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    Count To nTotal
    ProcRegua(nTotal)
 
    (cAliasTmp)->(DbGoTop())
    While ! (cAliasTmp)->(EoF())
        nAtual++
        IncProc(STR0020 + cValToChar(nAtual) + STR0021 + cValToChar(nTotal) + '...') //'Analisando registro '###' de '
     
        If (cAliasTmp)->FLAG_OK
            nTotMarc++
             
            FH1->(DbSelectArea(1))
            FH1->(DbGoTo((cAliasTmp)->RECNO))

            If nAp = 1
                If lPrim
                    SA2->(DbSetOrder(1))
                    SA2->(DbSeek(xFilial("SA2")+FH1->FH1_CODFOR+FH1->FH1_LOJFOR))   
                    If Empty(SA2->A2_COND)             
                        FWAlertInfo(STR0022 +FH1->FH1_CODFOR+STR0023+FH1->FH1_LOJFOR+STR0024) //"O Fornecedor "###" Loja "###" não tem condição de pagamento em seu cadastro, será exibida um tela para a escolha da condição de pagamento para o pedido de comporas"
                        ConPad1(, , , "SE4")
                    EndIF
                    If Len(aCpoRet) == 0
                        lRet := .F.
                        Exit
                    EndIf 

                    If lRet                       
                        cDoc := GetSXENum("SC7","C7_NUM")
                        ConfirmSX8()

                        aadd(aCabec,{"C7_NUM" ,cDoc})
                        aadd(aCabec,{"C7_EMISSAO" ,dDataBase})
                        aadd(aCabec,{"C7_FORNECE" ,FH1->FH1_CODFOR})
                        aadd(aCabec,{"C7_LOJA" ,FH1->FH1_LOJFOR})
                        SA2->(DbSetOrder(1))
                        SA2->(DbSeek(xFilial("SA2")+FH1->FH1_CODFOR+FH1->FH1_LOJFOR))
                        If !Empty(SA2->A2_COND) 
                            aadd(aCabec,{"C7_COND" ,SA2->A2_COND})
                        Else   
                            aadd(aCabec,{"C7_COND" ,aCpoRet[1]})
                        EndIf     
                        aadd(aCabec,{"C7_CONTATO" ,"AUTO"})
                        aadd(aCabec,{"C7_FILENT" ,cFilAnt})
                        lPrim := .F.
                    EndIf                    
                EndIf
                If lRet
                    aLinha := {}
                    aadd(aLinha,{"C7_PRODUTO" ,(cAliasTmp)->FH1_CODIGO,Nil})
                    aadd(aLinha,{"C7_QUANT" ,(cAliasTmp)->FH1_QUANTI ,Nil})
                    If (cAliasTmp)->FH1_VLRAUN <> 0
                        aadd(aLinha,{"C7_PRECO" ,(cAliasTmp)->FH1_VLRAUN ,Nil})
                        aadd(aLinha,{"C7_TOTAL" ,(cAliasTmp)->FH1_VLRAUN * (cAliasTmp)->FH1_QUANTI  ,Nil})
                    Else
                        aadd(aLinha,{"C7_PRECO" ,(cAliasTmp)->FH1_VLRUNI ,Nil})
                        aadd(aLinha,{"C7_TOTAL" ,(cAliasTmp)->FH1_VLRUNI * (cAliasTmp)->FH1_QUANTI  ,Nil})  
                    EndIf                      
                    aadd(aLinha,{"C7_CC" ,Posicione('STJ', 1, FWxFilial('STJ') + FH1->FH1_ORDEM, 'TJ_CCUSTO') ,Nil})
                    If _LCVAL
                        aadd(aLinha,{"C7_CLVL" ,Posicione('STJ', 1, FWxFilial('STJ') + FH1->FH1_ORDEM, 'TJ_AS') ,Nil})
                    EndIf   
                    aadd(aLinha,{"C7_OP" ,FH1->FH1_ORDEM+"OS"+"001" ,Nil})

                    aadd(aItens,aLinha)
                EndIf
            EndIf 
                If lRet
                    RecLock("FH1", .F.)
                    If (cAliasTmp)->FH1_VLRAUN <> 0
                        FH1->FH1_VLRAUN := (cAliasTmp)->FH1_VLRAUN
                        FH1->FH1_VLRATO := (cAliasTmp)->FH1_VLRAUN * (cAliasTmp)->FH1_QUANTI
                    Else    
                        FH1->FH1_VLRAUN := (cAliasTmp)->FH1_VLRUNI
                        FH1->FH1_VLRATO := (cAliasTmp)->FH1_VLRUNI * (cAliasTmp)->FH1_QUANTI  
                    EndIf                    
                    FH1->FH1_PEDCOM := cDoc
                    FH1->FH1_DTAPRO := dDataBase
                    FH1->FH1_HRAPRO := Time()
                    FH1->FH1_STAPRO := "2"
                    FH1->FH1_NOMAPR := Alltrim( UsrRetName(RetCodUsr()))
                    FH1->FH1_CODAPR := RetCodUsr()
                    FH1->(MsUnlock())            
                EndIf
            If nAp = 2//se for rejeição
                RecLock("FH1", .F.)
                FH1->FH1_STAPRO := "3"
                FH1->(MsUnlock())
            EndIf
        endIf     
        If !(cAliasTmp)->FLAG_OK .AND. nAp = 1 .AND. lRet
            FH1->(DbSelectArea(1))
            FH1->(DbGoTo((cAliasTmp)->RECNO))        
            RecLock("FH1", .F.)
            FH1->FH1_STAPRO := "3"
            FH1->(MsUnlock())        
        EndIf
          
        (cAliasTmp)->(DbSkip())
    EndDo
    If nAp = 1 .AND. lRet
        MSExecAuto({|a,b,c,d,e,f,g,h| MATA120(a,b,c,d,e,f,g,h)},1,aCabec,aItens,nOpc,.F.,,,)
    EndIf     
     If lMsErroAuto   
        MostraErro()
    EndIf
    If lRet 
        FWAlertInfo(STR0025 + cValToChar(nTotal) + STR0026 + cValToChar(nTotMarc) + STR0027, STR0028) //'Dos ['###'] registros, foram processados ['###'] registros'###'Atenção'
    EndIf
    If nAp = 1 .AND. lRet
        FWAlertSuccess(STR0029 + cDoc, STR0030) //"Foi gerado o Pedido de Compras: "###"Inclusão de Pedido de Compra"
    EndIf
    FWRestArea(aArea)
Return
 
 /*/{Protheus.doc} fMarkTod
Função que percorre os registros da tela
Marca e desmarca todos os registros em tela
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
Static Function fMarkTod()
    //Percorre todos os registros
    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    While ! (cAliasTmp)->(EoF())
        //Atualiza o registro atual
        RecLock(cAliasTmp, .F.)
        (cAliasTmp)->FLAG_OK := ! (cAliasTmp)->FLAG_OK
        (cAliasTmp)->(MsUnlock())
        (cAliasTmp)->(DbSkip())
    EndDo
    fAtualizaTotal(cAliasTmp)
   
    (cAliasTmp)->(DbGoTop())
    oFWBrowse:Refresh()
Return

 /*/{Protheus.doc} fAtualizaTotal
Função que percorre os registros da tela
E atuliza o valores totais e qtde
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
Function fAtualizaTotal(cAliasTmp)
Local nQtd := 0
Local nVlr := 0

    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    While ! (cAliasTmp)->(EoF())
        If (cAliasTmp)->FLAG_OK
            nQtd += (cAliasTmp)->FH1_QUANTI
            nVlr += (cAliasTmp)->FH1_VLRTOT
            If (cAliasTmp)->FH1_VLRAUN == 0
                (cAliasTmp)->FH1_VLRATO := (cAliasTmp)->FH1_VLRUNI * (cAliasTmp)->FH1_QUANTI
            EndIf             
        EndIf
       (cAliasTmp)->(DbSkip())
    EndDo
    nTotalQtd := nQtd
    nTotalVlr := nVlr
    oFWBrowse:Refresh()
Return

 /*/{Protheus.doc} AtualizaTot
Valida o campo valor unitário aprovado,
não pode ser maior do que o valor unitário
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
Function VldValor(cAliasTmp)
    If (cAliasTmp)->FLAG_OK
        If (cAliasTmp)->FH1_VLRAUN > (cAliasTmp)->FH1_VLRUNI
            Alert(STR0031) //"Valor unitário aprovado não pode ser maior do que o valor unitário"
            (cAliasTmp)->FH1_VLRAUN := (cAliasTmp)->FH1_VLRUNI
            Return(.F.)
        Else
            (cAliasTmp)->FH1_VLRATO := (cAliasTmp)->FH1_VLRAUN * (cAliasTmp)->FH1_QUANTI  
            Return(.T.)    
        EndIf 
    EndIf
    oFWBrowse:Refresh()
Return()

 /*/{Protheus.doc} AtualizaTot
 atuliza o valores totais e qtde qdo a linha é marcada
@author DENNIS CALABREZ
@since 06/06/2025
@version 1.0
@type function
/*/
Function AtualizaTot(cAliasTmp)
    If (cAliasTmp)->FLAG_OK
        nQtd += (cAliasTmp)->FH1_QUANTI
        nVlr += (cAliasTmp)->FH1_VLRTOT
        If (cAliasTmp)->FH1_VLRAUN == 0
            (cAliasTmp)->FH1_VLRATO := (cAliasTmp)->FH1_VLRUNI * (cAliasTmp)->FH1_QUANTI
        EndIf         
    Else
        nQtd -= (cAliasTmp)->FH1_QUANTI
        nVlr -= (cAliasTmp)->FH1_VLRTOT 
        If (cAliasTmp)->FH1_VLRAUN == 0
            (cAliasTmp)->FH1_VLRATO := 0
        EndIf                   
    EndIf
   
    nTotalQtd := nQtd
    nTotalVlr := nVlr
    oFWBrowse:Refresh()
Return
