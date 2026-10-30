#Include "Totvs.ch"
#Include "TCBrowse.ch"
#Include "FATVINCNFND.ch"

Static __oQryNDNF := Nil
Static __oQryNDVi := Nil

//------------------------------------------------------------------------------ 
/*/{Protheus.doc} VincNFND
    Componente de vínculo de Notas de Débito (ND) tipo 6 (F2_TPCOMPL = '6') sem RA
    ao Documento de Saída (SF2), gravando/excluindo registros na tabela DKN.

    @param cDocNF    Caractere  Número do Documento de Saída (F2_DOC)
    @param cSerieNF  Caractere  Série do Documento de Saída (F2_SERIE)
    @param cCliente  Caractere  Código do Cliente (F2_CLIENTE)
    @param cLoja     Caractere  Loja do Cliente (F2_LOJA)
    @param aUpdDKN   Array      (Opcional) Array com registros para gravar e deletar na DKN
                                Formato: { {nAction (gravar e deletar a DKN), cDocND, cSerieND, cCliND, cLojND}, ... }
                                Quando informado, executa sem abrir tela (modo automático).
    @param lAutomato Logical    Indica se a chamada da função ocorre via execução automática

    @return lRet     Lógico     .T. se processamento concluído com sucesso

    @author		SQUAD CRM / FAT
    @since		Julho/2026  
    @version	P12.1.2510
/*/
//------------------------------------------------------------------------------ 
Function VincNFND(cDocNF, cSerieNF, cCliente, cLoja, aUpdDKN, lAutomato)

    Local aArea     As Array
    Local lRet      As Logical
    Local cFIMP     As Character
    Local cMsg      As Character

    Default cDocNF    := ""
    Default cSerieNF  := ""
    Default cCliente  := ""
    Default cLoja     := ""
    Default aUpdDKN   := {}
    Default lAutomato := .F.

    aArea := GetArea()
    lRet  := .T.
    cFIMP := ""
    cMsg  := ""

    // Valida se o Documento de Saída foi informado
    If Empty(cDocNF) .Or. Empty(cSerieNF)
        If FwIsInCallStack("AButVincND")
            cMsg := STR0001 //--"Para vincular uma Nota de Débito, é necessário associá-la a um Pedido de Venda já faturado."
        Else
            cMsg :=  STR0002 + Chr(13) + STR0003 //--"O Documento de Saída e/ou a Série não foram informados." --"Operação cancelada."
        EndIf

        Help(Nil, Nil, STR0004, Nil, cMsg, 1, 0) //--"Vínculo ND"

        lRet := .F.
    EndIf

    If lRet
        // Lê os dados do Documento de Saída posicionado no browse
        dbSelectArea("SF2")
        SF2->(dbSetOrder(1))
        If SF2->(MsSeek(FWxFilial("SF2")+cDocNF+cSerieNF+cCliente+cLoja))
            cDocNF   := SF2->F2_DOC
            cSerieNF := SF2->F2_SERIE
            cCliente := SF2->F2_CLIENTE
            cLoja    := SF2->F2_LOJA
            cFImp    := SF2->F2_FIMP
        EndIF
    EndIf

    // Verifica se o Documento de Saída já foi transmitido (F2_FIMP = 'T')
    // Regra: não permitir vínculo após transmissão
    If lRet
        If cFImp == "T"
            Help(Nil, Nil, STR0005, Nil, STR0006 + Chr(13) + ; //--"Nota Transmitida. --"O Documento de Saída já foi transmitido. "
                STR0007, 1, 0) //--"Após a transmissão, não é permitido vincular Notas de Débito.""
            lRet := .F.
        EndIf
    EndIf

    // Decide o modo de execução:
    //   - Automático: aDKNGrv informado com registros
    //   - Interativo: abre tela de seleção
    If lRet
        If lAutomato // Modo automático: processa diretamente sem tela
            If !Empty(aUpdDKN)
                aUpdDKN := GetMarkND(aUpdDKN)
                lRet := SaveLink(cDocNF, cSerieNF, cCliente, cLoja, aUpdDKN, lAutomato)
            Else
                Help(Nil, Nil, STR0009, Nil, STR0010 + Chr(13) + ; //--"Erro ExecAuto" --"Nota de Débito não informada."
                    STR0003 , 1, 0) //--"Operação Cancelada."
                lRet := .F.
            EndIf
        Else
            // Modo interativo: abre tela de seleção de NDs
            lRet := BrwVincND(cDocNF, cSerieNF, cCliente, cLoja)
        EndIf
    EndIf

    RestArea(aArea)
    FWFreeArray(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrwVincND
    Abre a tela de seleção de Notas de Débito tipo 6 sem RA vinculado (F7Q).
    Usa TCBrowse com SetArray para exibir os registros em modo array,
    com coluna de marcação via bitmap LBOK/LBNO (padrão Protheus).
    Carrega marcados os registros já vinculados ao Documento de Saída na DKN.

    @param cDocNF    Caractere  Número do Documento de Saída
    @param cSerieNF  Caractere  Série do Documento de Saída
    @param cCliente  Caractere  Código do Cliente
    @param cLoja     Caractere  Loja do Cliente

    @return lRet     Lógico     .T. se confirmado e gravado com sucesso

    @author		SQUAD CRM / FAT
    @since		Julho/2026  
    @version	P12.1.2510
/*/
//------------------------------------------------------------------------------
Static Function BrwVincND(cDocNF, cSerieNF, cCliente, cLoja)

    Local oDlg      As Object
    Local oBrw      As Object
    Local oBtnOk    As Object
    Local oBtnCanc  As Object
    Local oOk       As Object
    Local oNo       As Object

    Local aNotaDeb  As Array    // Array com todas as NDs disponíveis
    Local aVinc     As Array    // Array com NDs já vinculadas ao Doc de Saída
    Local aSelect   As Array    // Array com seleção final do usuário
    Local aHeaders  As Array    // Cabeçalhos das colunas do TCBrowse
    Local aColSizes As Array    // Larguras das colunas do TCBrowse
    Local lRet      As Logical
    Local nI        As Numeric
    Local cTitulo   As Character
    
    // Variáveis para maximização usando MsAdvSize
    Local aSize     As Array    // Retorno do MsAdvSize
    Local aObjects  As Array    // Objetos para MsObjSize
    Local aInfo     As Array    // Info para MsObjSize
    Local aPosObj   As Array    // Posições calculadas

    Default cDocNF   := ""
    Default cSerieNF := ""
    Default cCliente := ""
    Default cLoja    := ""

    oDlg      := Nil
    oBrw      := Nil
    oBtnOk    := Nil
    oBtnCanc  := Nil
    oOk       := Nil
    oNo       := Nil

    aNotaDeb  := {}
    aVinc     := {}
    aSelect   := {}
    aHeaders  := {}
    aColSizes := {}
    lRet      := .T.
    nI        := 0
    cTitulo   := STR0011 + AllTrim(cDocNF) + "/" + AllTrim(cSerieNF) //--"Vínculo de Notas de Débito (ND Tipo 6) — Doc: "

    aSize     := {}
    aObjects  := {}
    aInfo     := {}
    aPosObj   := {}

    // Carrega as NDs tipo 6 disponíveis (sem RA vinculado na F7Q)
    // Estrutura: { lMarcado, cDoc, cSerie, cCli, cLoja, dEmissao, nValor, Controle de interação com a tela}
    aNotaDeb := LoadND(cCliente, cLoja)

    If Len(aNotaDeb) == 0
        Help(Nil, Nil, STR0012, Nil, STR0013,1, 0) //--"ND não encontrada" --"Não foram encontradas Notas de Débito (Tipo 6) disponíveis para vinculação ao Documento de Saída deste cliente."
        lRet := .F.
    EndIf

    If lRet
        // Carrega as NDs já vinculadas ao Documento de Saída (DKN)
        aVinc := LoadLinkND(cDocNF, cSerieNF, cCliente, cLoja)

        // Pré-marca no array aNotaDeb os registros já vinculados na DKN
        // aNotaDeb[n][1] = .T. - já vinculado (aparece marcado na tela)
        For nI := 1 To Len(aNotaDeb)
            aNotaDeb[nI][8] := (AScan(aVinc, {|aV| ;
                AllTrim(aV[1]) == AllTrim(aNotaDeb[nI][2]) .And. ;
                AllTrim(aV[2]) == AllTrim(aNotaDeb[nI][3])}) > 0)
        Next nI

        // Carrega os bitmaps de marcação (padrão Protheus)
        // LBOK = ícone de "marcado"  |  LBNO = ícone de "desmarcado"
        oOk := LoadBitmap(GetResources(), "LBOK")
        oNo := LoadBitmap(GetResources(), "LBNO")

        // Define cabeçalhos e larguras das colunas do TCBrowse
        aHeaders  := { "", STR0014, STR0015, STR0016, STR0017, STR0018, STR0019 } //--"Documento" --"Série" --"Cliente" --"Loja" --"Emissão" --"Valor"
        aColSizes := { 20, 80, 50, 70, 40, 70, 100 }

        // Calcula dimensões da tela usando MsAdvSize para maximizar
        // aSize[1] = Linha inicial
        // aSize[2] = Coluna inicial
        // aSize[3] = Linha final
        // aSize[4] = Coluna final
        // aSize[5] = Largura da janela
        // aSize[6] = Altura da janela
        // aSize[7] = Linha inicial da área útil
        aSize := MsAdvSize(.T.)  // .T. = considera barra de ferramentas
        
        // Define áreas: Browse (90%) e Botões (10%)
        aObjects := {}
        AAdd(aObjects, {100, 80, .T., .T.})  // Browse ocupa 90% da altura
        AAdd(aObjects, {100, 20, .T., .F.})  // Botões ocupam 10% da altura
        
        aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}
        aPosObj := MsObjSize(aInfo, aObjects)

        // Cria a tela maximizada
        DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7], 0 TO aSize[6], aSize[5] OF oMainWnd PIXEL

        // TCBrowse em modo array - usa as coordenadas calculadas
        oBrw := TCBrowse():New(aPosObj[1,1], aPosObj[1,2], aPosObj[1,4] - aPosObj[1,2], aPosObj[1,3] - aPosObj[1,1],, aHeaders, aColSizes, oDlg,,,,,{|| },,,,,,,.F.,, .T.,,.F.,,,.T.)

        // Alimenta o TCBrowse com o array de NDs
        oBrw:SetArray(aNotaDeb)

        // bLine: retorna os dados de cada linha para o TCBrowse renderizar
        // Coluna 1: bitmap de marcação (LBOK se marcado, LBNO se não)
        // Colunas 2-7: dados da ND
        oBrw:bLine := {|| { ;
            IIf(aNotaDeb[oBrw:nAt][8], oOk, oNo), ;  // [1] Marcação visual
            AllTrim(aNotaDeb[oBrw:nAt][2]),         ;  // [2] Documento ND
            AllTrim(aNotaDeb[oBrw:nAt][3]),         ;  // [3] Série ND
            AllTrim(aNotaDeb[oBrw:nAt][4]),         ;  // [4] Cliente
            AllTrim(aNotaDeb[oBrw:nAt][5]),         ;  // [5] Loja
            Stod(aNotaDeb[oBrw:nAt][6]),            ;  // [6] Emissão
            Transform(aNotaDeb[oBrw:nAt][7], "@E 999,999,999.99") ;  // [7] Valor
        }}

        // Duplo clique: alterna marcação e redesenha a linha
        // Controla o que marcou e desmarcou
        oBrw:bLDblClick := {|| ;
            aNotaDeb[oBrw:nAt][8] := !aNotaDeb[oBrw:nAt][8], ;
            IIf(aNotaDeb[oBrw:nAt][8], aNotaDeb[oBrw:nAt][1] := 1, aNotaDeb[oBrw:nAt][1] := 2), ;
            oBrw:DrawSelect() ;
        }

        // Scroll contínuo (padrão Protheus)
        oBrw:nScrollType := 1

        // Botões de seleção múltipla - Lado esquerdo da área de botões
        // aPosObj[2] = área dos botões (10% inferior da tela)
        
        // Botão "Marcar Todos" - Marca todos os registros do array
        // Para cada registro: [8] = .T. (marcado visualmente) e [1] = 1 (controle de interação)
        @ aPosObj[2,1], 10 BUTTON STR0020 SIZE 70, 15 OF oDlg PIXEL ; //--"Marcar Todos"
            ACTION ( ;
                AEval(aNotaDeb, {|aItem| aItem[8] := .T., aItem[1] := 1}), ;
                oBrw:Refresh() ;
            )

        // Botão "Inverter Seleção" - Inverte o estado de marcação de todos os registros
        // Se estava marcado ([8] = .T.) -> desmarca ([8] = .F., [1] = 2)
        // Se estava desmarcado ([8] = .F.) -> marca ([8] = .T., [1] = 1)
        @ aPosObj[2,1], 85 BUTTON STR0021 SIZE 70, 15 OF oDlg PIXEL ; //--"Inverter Seleção"
            ACTION ( ;
                InvertSel(aNotaDeb), ;
                oBrw:Refresh() ;
            )

        // Botão "Desmarcar Todos" - Desmarca todos os registros do array
        // Para cada registro: [8] = .F. (desmarcado visualmente) e [1] = 2 (controle de interação)
        @ aPosObj[2,1], 160 BUTTON STR0022 SIZE 70, 15 OF oDlg PIXEL ; //--"Desmarcar Todos"
            ACTION ( ;
                AEval(aNotaDeb, {|aItem| aItem[8] := .F., aItem[1] := 2}), ;
                oBrw:Refresh() ;
            )

        // Botões principais - Posicionados no canto inferior direito da área de botões
        @ aPosObj[2,1], aPosObj[2,4] - 210 BUTTON oBtnOk PROMPT STR0023 SIZE 90, 15 OF oDlg PIXEL ; //--"Confirmar"
            ACTION ( ;
                aSelect := GetMarkND(aNotaDeb), ;
                lRet    := SaveLink(cDocNF, cSerieNF, cCliente, cLoja, aSelect), ;
                oDlg:End() ;
            )

        @ aPosObj[2,1], aPosObj[2,4] - 110 BUTTON oBtnCanc PROMPT STR0024 SIZE 90, 15 OF oDlg PIXEL ; //--"Cancelar"
            ACTION ( lRet := .F., oDlg:End() )

        ACTIVATE MSDIALOG oDlg
    EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} InvertSel
    Inverte o estado de marcação de todos os registros no array de Notas de Débito.
    Para cada registro: inverte o flag visual [8] e atualiza o controle de interação [1].

    @param aNotaDeb   Array  Array de NDs com estrutura {nControle, cDoc, cSerie, cCli, cLoja, dEmissao, nValor, lMarcado}

    @return Nil

    @author		SQUAD CRM / FAT
    @since		Julho/2026  
    @version	P12.1.2510
/*/
//------------------------------------------------------------------------------
Static Function InvertSel(aNotaDeb)

    Local nI As Numeric

    Default aNotaDeb := {}

    For nI := 1 To Len(aNotaDeb)
        // Inverte o flag visual
        aNotaDeb[nI][8] := !aNotaDeb[nI][8]
        
        // Atualiza o controle de interação conforme o novo estado
        If aNotaDeb[nI][8]
            aNotaDeb[nI][1] := 1  // Marcado
        Else
            aNotaDeb[nI][1] := 2  // Desmarcado
        EndIf
    Next nI

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} LoadND
    Carrega todas as Notas de Débito (SF2) do tipo 6 (F2_TPCOMPL = '6')
    que NÃO possuem RA vinculado na tabela F7Q.
    Filtra pelo cliente/loja informados.

    @param cCliente  Caractere  Código do Cliente
    @param cLoja     Caractere  Loja do Cliente

    @return aRet     Array  { {lMarcado, cDoc, cSerie, cCli, cLoja, dEmissao, nValor}, ... }

    @author		SQUAD CRM / FAT
    @since		Julho/2026  
    @version	P12.1.2510
/*/
//------------------------------------------------------------------------------
Static Function LoadND(cCliente, cLoja)

    Local aRet      As Array
    Local aInsParam As Array
    Local cQuery    As Character
    Local cAliasSQL As Character
    Local cFilSF2   As Character
    Local cFilF7Q   As Character

    Default cCliente := ""
    Default cLoja    := ""

    aRet      := {}
    aInsParam := {}
    cQuery    := ""
    cAliasSQL := ""
    cFilSF2   := FWxFilial("SF2")
    cFilF7Q   := FWxFilial("F7Q")
    nX        := 0

    If __oQryNDNF == Nil
        // Query: busca NDs tipo 6 sem RA vinculado (F7Q)
        // NOT EXISTS garante que não há vínculo com adiantamento
        cQuery := "SELECT SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, "
        cQuery += "SF2.F2_EMISSAO, SF2.F2_VALBRUT "
        cQuery += "FROM " + RetSQLName("SF2") + " SF2 "
        cQuery += "WHERE SF2.F2_FILIAL  = ? "
        cQuery += "AND SF2.F2_TIPO = ? "
        cQuery += "AND SF2.F2_TPCOMPL = ? "
        cQuery += "AND SF2.F2_CLIENTE = ? "
        cQuery += "AND SF2.F2_LOJA    = ? "
        cQuery += "AND SF2.D_E_L_E_T_ = ? "
        cQuery += "AND NOT EXISTS ( "
        cQuery += "SELECT 1 FROM " + RetSQLName("F7Q") + " F7Q "
        cQuery += "WHERE F7Q.F7Q_FILIAL = ? "
        cQuery += "AND F7Q.F7Q_DOC    = SF2.F2_DOC "
        cQuery += "AND F7Q.F7Q_SERIE  = SF2.F2_SERIE "
        cQuery += "AND F7Q.F7Q_CLIFOR = SF2.F2_CLIENTE "
        cQuery += "AND F7Q.F7Q_LOJA   = SF2.F2_LOJA "
        cQuery += "AND F7Q.D_E_L_E_T_ = ? "
        cQuery += ") "
        cQuery += "ORDER BY SF2.F2_EMISSAO DESC, SF2.F2_DOC "

        cQuery	:= ChangeQuery(cQuery)

        __oQryNDNF := FwExecStatement():New(cQuery)
    EndIf

    aAdd(aInsParam, cFilSF2)
    aAdd(aInsParam, '6')
    aAdd(aInsParam, '6')
    aAdd(aInsParam, cCliente)
    aAdd(aInsParam, cLoja)
    aAdd(aInsParam, ' ')
    aAdd(aInsParam, cFilF7Q)
    aAdd(aInsParam, ' ')

    __oQryNDNF:SetParams(aInsParam)

    cAliasSQL := __oQryNDNF:OpenAlias()

    FWFreeArray(aInsParam)

    While (cAliasSQL)->(!Eof())

        aAdd(aRet, { ;
            0,                               ;  // [1] Controle de interação com a tela
            (cAliasSQL)->F2_DOC,             ;  // [2] Documento ND
            (cAliasSQL)->F2_SERIE,           ;  // [3] Série ND
            (cAliasSQL)->F2_CLIENTE,         ;  // [4] Cliente
            (cAliasSQL)->F2_LOJA,            ;  // [5] Loja
            (cAliasSQL)->F2_EMISSAO,         ;  // [6] Data de Emissão
            (cAliasSQL)->F2_VALBRUT,         ;  // [7] Valor Bruto
            .F.                              ;  // [8] lMarcado (default desmarcado)
        })

        (cAliasSQL)->(dbSkip())
    EndDo

    (cAliasSQL)->(dbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} LoadLinkND
    Carrega os vínculos já existentes na tabela DKN para o Documento de Saída.
    Filtra por DKN_ORIGEM = 'MATA461' para isolar registros deste componente.

    @param cDocNF    Caractere  Número do Documento de Saída
    @param cSerieNF  Caractere  Série do Documento de Saída
    @param cCliente  Caractere  Código do Cliente
    @param cLoja     Caractere  Loja do Cliente

    @return aRet     Array  { {cDocRef, cSerieRef, cCliRef, cLojRef}, ... }

    @author		SQUAD CRM / FAT
    @since		Julho/2026  
    @version	P12.1.2510
/*/
//------------------------------------------------------------------------------
Static Function LoadLinkND(cDocNF, cSerieNF, cCliente, cLoja)

    Local aRet      As Array
    Local cQuery    As Character
    Local cAliasSQL As Character
    Local cFilDKN   As Character
    Local aInsParam As Array
    Local nX        As Numeric

    Default cDocNF   := ""
    Default cSerieNF := ""
    Default cCliente := ""
    Default cLoja    := ""

    aRet      := {}
    aInsParam := {}    
    cQuery    := ""
    cAliasSQL := ""
    cFilDKN   := FWxFilial("DKN")
    nX        := 0

    If __oQryNDVi == Nil
        // Query: busca NDs tipo 6 já vinculadas a nota fiscal
        cQuery := "SELECT DKN.DKN_DOCREF, DKN.DKN_SERREF, DKN.DKN_PARREF, DKN.DKN_LOJREF "
        cQuery += "FROM " + RetSQLName("DKN") + " DKN "
        cQuery += "WHERE DKN.DKN_FILIAL = ? "
        cQuery += "AND DKN.DKN_DOC    = ? "
        cQuery += "AND DKN.DKN_SERIE  = ? "
        cQuery += "AND DKN.DKN_CLIFOR = ? "
        cQuery += "AND DKN.DKN_LOJA   = ? "
        cQuery += "AND DKN.DKN_TPMOV  = ? "
        cQuery += "AND DKN.DKN_ORIGEM = ? "
        cQuery += "AND DKN.D_E_L_E_T_ = ? "

        cQuery	:= ChangeQuery(cQuery)

        __oQryNDVi := FwExecStatement():New(cQuery)
    EndIf

    aAdd(aInsParam, cFilDKN )
    aAdd(aInsParam, cDocNF  )
    aAdd(aInsParam, cSerieNF)
    aAdd(aInsParam, cCliente)
    aAdd(aInsParam, cLoja   )
    aAdd(aInsParam, '2')
    aAdd(aInsParam, 'MATA461')
    aAdd(aInsParam, ' ')

    __oQryNDVi:SetParams(aInsParam)

    cAliasSQL := __oQryNDVi:OpenAlias()

    FWFreeArray(aInsParam)

    While (cAliasSQL)->(!Eof())
        aAdd(aRet, { ;
            (cAliasSQL)->DKN_DOCREF, ;  // [1] Documento ND referenciado
            (cAliasSQL)->DKN_SERREF, ;  // [2] Série ND referenciada
            (cAliasSQL)->DKN_PARREF, ;  // [3] Cliente ND referenciada
            (cAliasSQL)->DKN_LOJREF  ;  // [4] Loja ND referenciada
        })
        (cAliasSQL)->(dbSkip())
    EndDo

    (cAliasSQL)->(dbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetMarkND
    Coleta do array aNotaDeb apenas os registros marcados pelo usuário.

    @param aNotaDeb   Array  Array completo de NDs com flag de seleção

    @return aRet Array  { {cDocND, cSerieND, cCliND, cLojND}, ... }

    @author		SQUAD CRM / FAT
    @since		Julho/2026  
    @version	P12.1.2510
/*/
//------------------------------------------------------------------------------
Static Function GetMarkND(aNotaDeb)

    Local aRet As Array
    Local nI   As Numeric

    Default aNotaDeb := {}

    aRet := {}

    For nI := 1 To Len(aNotaDeb)
        If aNotaDeb[nI][1] <> 0 // Considera apenas os itens marcados e desmarcados
            aAdd(aRet, { ;
                aNotaDeb[nI][1], ;  // 1-Marcado 2-Desmarcado
                aNotaDeb[nI][2], ;  // cDocND
                aNotaDeb[nI][3], ;  // cSerieND
                aNotaDeb[nI][4], ;  // cCliND
                aNotaDeb[nI][5]  ;  // cLojND6
            })
        EndIf
    Next nI

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} SaveLink
    Realiza a gravação e exclusão de vínculos na tabela DKN.

    Lógica:
      1. Inclui os registros marcados na tabela DKN.
      2. Exclui os registros desmarcados na tabela DKN.

    @param cDocNF    Caractere  Número do Documento de Saída
    @param cSerieNF  Caractere  Série do Documento de Saída
    @param cCliente  Caractere  Código do Cliente
    @param cLoja     Caractere  Loja do Cliente
    @param aSelect   Array      NDs selecionadas: { {1-Marca 2-Desmarca, cDocND, cSerieND, cCliND, cLojND}, ... }

    @return lRet     Lógico     .T. se gravação concluída sem erros

    @author		SQUAD CRM / FAT
    @since		Julho/2026  
    @version	P12.1.2510
/*/
//------------------------------------------------------------------------------
Static Function SaveLink(cDocNF, cSerieNF, cCliente, cLoja, aSelect, lAutomato)

    Local lRet  As Logical
    Local nI    As Numeric
    Local cMsg  As Character

    Default cDocNF    := ""
    Default cSerieNF  := ""
    Default cCliente  := ""
    Default cLoja     := ""
    Default aSelect   := {}
    Default lAutomato := .F.

    lRet := .T.
    nI   := 0
    cMsg := ""

    For nI := 1 To Len(aSelect)
        If aSelect[nI][1] == 1
            lRet := AddLink(cDocNF, cSerieNF, cCliente, cLoja, aSelect[nI][2], aSelect[nI][3])
            If !lRet
                Help(Nil, Nil, STR0025, Nil, STR0026 + AllTrim(aSelect[nI][2]) + ; //--"Erro na Gravação" --"Já existe vínculo da Nota de Débito: "
                    STR0027 + Alltrim(cDocNF) + Chr(13) + STR0028 , 1, 0) //--" com o Documento de Saída: " --". Operação interrompida."
                Exit
            EndIf
        Else
            lRet := DelLink(cDocNF, cSerieNF, cCliente, cLoja, aSelect[nI][2], aSelect[nI][3])
            If !lRet
                Help(Nil, Nil, STR0029, Nil, STR0030 + AllTrim(aSelect[nI][2]) + ; //--"Erro na Exclusão" --"O vínculo da Nota Débito: "
                    STR0031 + Alltrim(cDocNF)  + STR0032 + Chr(13) + STR0028 , 1, 0) //--" com o Documento de Saída: " --" não foi encontrado" --". Operação interrompida."
                Exit
            EndIf
        EndIf
    Next nI

    If lRet
        If Empty(aSelect)
            lRet := .F.
        EndIf

        If lRet
            cMsg := STR0033 //--"Operação concluída com sucesso! Os vínculos foram atualizados."

            If lAutomato
                FwLogMsg('INFO',, STR0004,,,, cMsg,,,) //--"Vínculo ND"
            Else
                MsgInfo(cMsg, STR0004) //--"Vínculo ND"
            EndIf
        Else
            MsgInfo(STR0034, STR0004) //--"Nenhuma Nota de Débito foi selecionada ou desmarcada." --"Vínculo ND"
        EndIf
    EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AddLink
    Inclui um registro de vínculo na tabela DKN via RecLock.

    @param cDocNF    Caractere  Número do Documento de Saída
    @param cSerieNF  Caractere  Série do Documento de Saída
    @param cCliente  Caractere  Código do Cliente do Doc de Saída
    @param cLoja     Caractere  Loja do Cliente do Doc de Saída
    @param cDocND    Caractere  Número da ND referenciada
    @param cSerieND  Caractere  Série da ND referenciada

    @return lRet     Lógico     .T. se inclusão realizada com sucesso

    @author		SQUAD CRM / FAT
    @since		Julho/2026  
    @version	P12.1.2510
/*/
//------------------------------------------------------------------------------
Static Function AddLink(cDocNF, cSerieNF, cCliente, cLoja, cDocND, cSerieND)

    Local aArea   As Array
    Local lRet    As Logical
    Local cFilDKN As Character

    Default cDocNF   := ""
    Default cSerieNF := ""
    Default cCliente := ""
    Default cLoja    := ""
    Default cDocND   := ""
    Default cSerieND := ""

    aArea := GetArea()
    lRet    := .F.
    cFilDKN := FWxFilial("DKN")

    dbSelectArea("DKN")
	DKN->(DbSetOrder(1)) // -- DKN_FILIAL+DKN_DOC+DKN_SERIE+DKN_CLIFOR+DKN_LOJA+DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF+DKN_ITNFRE+DKN_TPMOV
	If DKN->(!MsSeek(FWxFilial("DKN")+cDocNF+cSerieNF+cCliente+cLoja+cDocND+cSerieND+cCliente+cLoja+Space(GetSX3Cache("DKN_ITNFRE", "X3_TAMANHO"))+"2"+"MATA461"))

        // Inclusão de novo registro na DKN
        RecLock("DKN", .T.)
        DKN->DKN_FILIAL := cFilDKN
        DKN->DKN_TPMOV  := "2"          // 2 = Saída
        DKN->DKN_DOC    := cDocNF       // Documento de Saída (NF principal)
        DKN->DKN_SERIE  := cSerieNF     // Série do Documento de Saída
        DKN->DKN_CLIFOR := cCliente     // Cliente do Documento de Saída
        DKN->DKN_LOJA   := cLoja        // Loja do Cliente
        DKN->DKN_DOCREF := cDocND       // Documento da ND referenciada
        DKN->DKN_SERREF := cSerieND     // Série da ND referenciada
        DKN->DKN_PARREF := cCliente     // Cliente da ND referenciada
        DKN->DKN_LOJREF := cLoja        // Loja da ND referenciada
        DKN->DKN_ORIGEM := "MATA461"    // Identificador deste componente
        DKN->(MsUnlock())

        lRet := .T.
    EndIf

    RestArea(aArea)
    FWFreeArray(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} DelLink
    Exclui logicamente (dbDelete) os registros da tabela DKN referentes
    ao vínculo entre o Documento de Saída e a ND informada.

    @param cDocNF    Caractere  Número do Documento de Saída
    @param cSerieNF  Caractere  Série do Documento de Saída
    @param cCliente  Caractere  Código do Cliente
    @param cLoja     Caractere  Loja do Cliente
    @param cDocND    Caractere  Número da ND a desvincular
    @param cSerieND  Caractere  Série da ND a desvincular

    @return lRet     Lógico     .T. se exclusão realizada com sucesso

    @author		SQUAD CRM / FAT
    @since		Julho/2026  
    @version	P12.1.2510
/*/
//------------------------------------------------------------------------------
Static Function DelLink(cDocNF, cSerieNF, cCliente, cLoja, cDocND, cSerieND)

    Local aArea As Array
    Local lRet  As Logical

    Default cDocNF   := ""
    Default cSerieNF := ""
    Default cCliente := ""
    Default cLoja    := ""
    Default cDocND   := ""
    Default cSerieND := ""

    aArea := GetArea()
    lRet  := .F.

	DbSelectArea("DKN")
	DKN->(DbSetOrder(1)) // -- DKN_FILIAL+DKN_DOC+DKN_SERIE+DKN_CLIFOR+DKN_LOJA+DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF+DKN_ITNFRE+DKN_TPMOV
	If DKN->(MsSeek(FWxFilial("DKN")+cDocNF+cSerieNF+cCliente+cLoja+cDocND+cSerieND+cCliente+cLoja+Space(GetSX3Cache("DKN_ITNFRE", "X3_TAMANHO"))+"2"+"MATA461"))
        Reclock("DKN",.F.)
        DKN->(DbDelete())
        DKN->(MsUnlock())

        lRet := .T.
	EndIf

	RestArea(aArea)
    FWFreeArray(aArea)

Return lRet
