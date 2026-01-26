#INCLUDE 'TOTVS.CH'
#INCLUDE 'OFCNHA09.CH'

/*/{Protheus.doc} OFCNHA09
Tela com a referencia do pedido gerado na VBE
@type function
@version 1.0  
@author Rodrigo
@since 28/05/2025
@param cNumPed, character, numero do pedido
/*/  
Function OFCNHA09(cNumPed As Char)
    Local aArea := FWGetArea() As Array
 
    MontaTela(cNumPed)
 
    FWRestArea(aArea)
Return

/*/{Protheus.doc} MontaTela
Monta tela com FWLayer
@type function
@version 1.0  
@author Rodrigo
@since 28/05/2025
@param cNumPed, character, numero do pedido
/*/ 
Static Function MontaTela(cNumPed)
    Local nLargBtn      := 50 As Numeric
    /*
    Objetos e componentes
    */
    Private oDlg As Object
    Private oFWLayer As Object
    Private oPanTitulo As Object
    Private oPanGrid As Object
    /*
    Cabeçalho
    */
    Private oSayModulo As Object
    Private cSayModulo := '' As Char
    Private oSayTitulo As Object
    Private cSayTitulo := STR0001 As Char /*Pedido Protheus: */
    Private oSaySubTit As Object
    Private cSaySubTit := cNumPed As Char 
    /*
    Tamanho da janela
    */
    Private aSize := MsAdvSize(.F.) As Array
    Private nJanLarg := aSize[5] As Numeric
    Private nJanAltu := aSize[6] As Numeric
    /*
    Fontes
    */
    Private cFontUti    := 'Tahoma' As Char
    Private oFontMod    := TFont():New(cFontUti, , -38) As Object
    Private oFontSub    := TFont():New(cFontUti, , -20) As Object
    Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.) As Object
    Private oFontBtn    := TFont():New(cFontUti, , -14) As Object
    Private oFontSay    := TFont():New(cFontUti, , -12) As Object
    /*
    Grid
    */
    Private aCampos := {} As Array
    Private cAliasTmp := GetNextAlias()
    Private aColunas := {}
 
    /*
    Campos da Temporária
    */
    aAdd(aCampos, {'VBE_CODIGO', 'C', FWTamSX3('VBE_CODIGO')[1], FWTamSX3('VBE_CODIGO')[2] })
    aAdd(aCampos, {'VBE_PRODUT', 'C', FWTamSX3('VBE_PRODUT')[1], FWTamSX3('VBE_PRODUT')[2] })
    aAdd(aCampos, {'VBE_QTDLIN', 'N', FWTamSX3('VBE_QTDLIN')[1], FWTamSX3('VBE_QTDLIN')[2] })
    aAdd(aCampos, {'VBE_VLRTOT', 'N', FWTamSX3('VBE_VLRTOT')[1], FWTamSX3('VBE_VLRTOT')[2] })
    aAdd(aCampos, {'VBE_TIPPED', 'C', FWTamSX3('VBE_TIPPED')[1], FWTamSX3('VBE_TIPPED')[2] })
    aAdd(aCampos, {'VBE_NUMPED', 'C', FWTamSX3('VBE_NUMPED')[1], FWTamSX3('VBE_NUMPED')[2] })
 
    /*
    Cria a tabela temporária
    */
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields(aCampos)
    oTempTable:Create()
 
    /*
    Busca as colunas do browse
    */
    aColunas := CriaCols()
 
    /*
    Popula a tabela temporária
    */
    Processa({|| Popula(cNumPed)}, STR0002) /*Processando...*/
 
    /*
    Cria a janela
    */
    DEFINE MSDIALOG oDlg TITLE STR0003  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL /*Pedido PRIM*/
 
        /*
        Criando a camada
        */
        oFWLayer := FWLayer():New()
        oFWLayer:init(oDlg,.F.)
 
        /*
        Adicionando 3 linhas, a de título, a superior e a do calendário
        */
        oFWLayer:addLine('TIT', 10, .F.)
        oFWLayer:addLine('COR', 90, .F.)
 
        /*
        Adicionando as colunas das linhas
        */
        oFWLayer:addCollumn('HEADERTEXT',   050, .T., 'TIT')
        oFWLayer:addCollumn('BLANKBTN',     040, .T., 'TIT')
        oFWLayer:addCollumn('BTNSAIR',      010, .T., 'TIT')
        oFWLayer:addCollumn('COLGRID',      100, .T., 'COR')
 
        /*
        Criando os paineis
        */
        oPanHeader := oFWLayer:GetColPanel('HEADERTEXT', 'TIT')
        oPanSair   := oFWLayer:GetColPanel('BTNSAIR',    'TIT')
        oPanGrid   := oFWLayer:GetColPanel('COLGRID',    'COR')
 
        /*
        Títulos e SubTítulos
        */
        oSayModulo := TSay():New(004, 003, {|| cSayModulo}, oPanHeader, '', oFontMod,  , , , .T., RGB(149, 179, 215), , 200, 30, , , , , , .F., , )
        oSayTitulo := TSay():New(004, 045, {|| cSayTitulo}, oPanHeader, '', oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
        oSaySubTit := TSay():New(014, 045, {|| cSaySubTit}, oPanHeader, '', oFontSubN, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )
 
        /*
        Criando os botões
        */
        oBtnSair := TButton():New(006, 001, STR0004,             oPanSair, {|| oDlg:End()}, nLargBtn, 018, , oFontBtn, , .T., , , , , , ) /*Fechar*/
 
        /*
        Cria a grid
        */
        oGetGrid := FWBrowse():New()
        oGetGrid:SetDataTable()
        oGetGrid:SetInsert(.F.)
        oGetGrid:SetDelete(.F., { || .F. })
        oGetGrid:SetAlias(cAliasTmp)
        oGetGrid:DisableReport()
        oGetGrid:DisableFilter()
        oGetGrid:DisableConfig()
        oGetGrid:DisableReport()
        oGetGrid:DisableSeek()
        oGetGrid:DisableSaveConfig()
        oGetGrid:SetFontBrowse(oFontSay)
        oGetGrid:SetColumns(aColunas)
        oGetGrid:SetOwner(oPanGrid)
        oGetGrid:Activate()
    ACTIVATE MSDIALOG oDlg CENTERED
    oTempTable:Delete()
Return

/*/{Protheus.doc} CriaCols
Cria o aCols para apresentação dos dados
@type function
@version 1.0  
@author Rodrigo
@since 28/05/2025
@return array, estrutura de dados
/*/ 
Static Function CriaCols() As Array
    Local nAtual   := 0 As Numeric

    Local aColunas := {} As Array
    Local aEstrut  := {} As Array
    
    Local oColumn As Object
     
    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    aAdd(aEstrut, {'VBE_CODIGO', GetSX3Cache('VBE_CODIGO','X3_TITULO'), GetSX3Cache('VBE_CODIGO','X3_TIPO'), FWTamSX3('VBE_CODIGO')[1], FWTamSX3('VBE_CODIGO')[2], X3Picture('VBE_CODIGO')})
    aAdd(aEstrut, {'VBE_PRODUT', GetSX3Cache('VBE_PRODUT','X3_TITULO'), GetSX3Cache('VBE_PRODUT','X3_TIPO'), FWTamSX3('VBE_PRODUT')[1], FWTamSX3('VBE_PRODUT')[2], X3Picture('VBE_PRODUT')})
    aAdd(aEstrut, {'VBE_QTDLIN', GetSX3Cache('VBE_QTDLIN','X3_TITULO'), GetSX3Cache('VBE_QTDLIN','X3_TIPO'), FWTamSX3('VBE_QTDLIN')[1], FWTamSX3('VBE_QTDLIN')[2], X3Picture('VBE_QTDLIN')})
    aAdd(aEstrut, {'VBE_VLRTOT', GetSX3Cache('VBE_VLRTOT','X3_TITULO'), GetSX3Cache('VBE_VLRTOT','X3_TIPO'), FWTamSX3('VBE_VLRTOT')[1], FWTamSX3('VBE_VLRTOT')[2], X3Picture('VBE_VLRTOT')})
    aAdd(aEstrut, {'VBE_TIPPED', GetSX3Cache('VBE_TIPPED','X3_TITULO'), GetSX3Cache('VBE_TIPPED','X3_TIPO'), FWTamSX3('VBE_TIPPED')[1], FWTamSX3('VBE_TIPPED')[2], X3Picture('VBE_TIPPED')})
    aAdd(aEstrut, {'VBE_NUMPED', GetSX3Cache('VBE_NUMPED','X3_TITULO'), GetSX3Cache('VBE_NUMPED','X3_TIPO'), FWTamSX3('VBE_NUMPED')[1], FWTamSX3('VBE_NUMPED')[2], X3Picture('VBE_NUMPED')})
     
    /*
    Percorrendo todos os campos da estrutura
    */
    For nAtual := 1 To Len(aEstrut)
        /*
        Cria a coluna
        */
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{|| (cAliasTmp)->" + aEstrut[nAtual][1] +"}"))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])
 
        /*
        Adiciona a coluna
        */
        aAdd(aColunas, oColumn)
    Next
Return aColunas

/*/{Protheus.doc} Popula
Seleção de dados
@type function
@version 1.0  
@author Rodrigo
@since 28/05/2025
@param cNumPed, character, numero do pedido
/*/ 
Static Function Popula(cNumPed As Char)
    Local nAtual := 0 As Numeric
    Local nTotal := 0 As Numeric

    Local aQryVBE := {} As Array

    Local cAlias := '' As Char
    Local cQryVBE:= '' As Char

    cAlias := GetNextAlias()

    BEGINSQL ALIAS cAlias
        SELECT VBE_CODIGO
            ,VBE_PRODUT
            ,VBE_QTDLIN
            ,VBE_VLRTOT
            ,VBE_TIPPED
            ,VBE_NUMPED
        FROM
            %Table:VBE% VBE
        WHERE
            VBE_FILIAL = %xFilial:VBE%
            AND VBE_NUMPED = %Exp:cNumPed%
            AND VBE.%NotDel%
    ENDSQL

    aQryVBE := GetLastQuery()
    cQryVBE := aQryVBE[2]
 
    /*
    Define o tamanho da régua
    */
    COUNT TO nTotal
    ProcRegua(nTotal)
    (cAlias)->(dbGoTop())
 
    /*
    Enquanto houver itens
    */
    While ! (cAlias)->(EOF())
        /*
        Incrementa a régua
        */
        nAtual++
        IncProc(STR0005 + cValToChar(nAtual) + STR0006 + cValToChar(nTotal) + STR0007) /*Adicionando registro */ /* de */ /*...*/
 
        /*
        Grava na temporária
        */
        RecLock(cAliasTmp, .T.)
        (cAliasTmp)->VBE_CODIGO := (cAlias)->VBE_CODIGO
        (cAliasTmp)->VBE_PRODUT := (cAlias)->VBE_PRODUT
        (cAliasTmp)->VBE_QTDLIN := (cAlias)->VBE_QTDLIN
        (cAliasTmp)->VBE_VLRTOT := (cAlias)->VBE_VLRTOT
        (cAliasTmp)->VBE_TIPPED := (cAlias)->VBE_TIPPED
        (cAliasTmp)->VBE_NUMPED := (cAlias)->VBE_NUMPED
        (cAliasTmp)->(MsUnlock())
 
        (cAlias)->(dbSkip())
    EndDo
Return
