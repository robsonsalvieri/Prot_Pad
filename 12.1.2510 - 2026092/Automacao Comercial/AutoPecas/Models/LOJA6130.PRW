#include "TOTVS.CH"
#include "FWMVCDEF.CH"
#include "LOJA6130.CH"
#include "FWPrintSetup.ch"
#include "RPTDEF.CH"

//------------------------------------------------------------------------
/*/{Protheus.doc} LOJA6130
Entrada de Sucata.
Essa rotina tem por objetivo registrar o movimento de entrada de sucata
de bateria, permitindo o cadastro do cabeçalho (cliente, vendedor e forma
de pagamento) e dos itens (produtos, peso, amperagem e valores), e
confirmando o movimento com a geração automática da Nota Fiscal de
Entrada e da respectiva contrapartida financeira.

@type    Function
@author  Alberto Deviciente
@since   18/08/2026
@version 12
@return  Nil, Nulo
/*/
//------------------------------------------------------------------------
Function LOJA6130()
    // A função principal apenas dispara o browse
    // A configuração fica na BrowseDef (Static Function)
    Local oBrowse As Object

    oBrowse := FWLoadBrw("LOJA6130")
    oBrowse:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Definição do browse da rotina

@type    Static Function
@author  Alberto Deviciente
@since   18/08/2026
@version 12
@return  oBrowse, object, objeto do browse
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
    Local oBrowse As Object

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("MFV")
    oBrowse:SetDescription(STR0001) //"Entrada de Sucata"

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu da rotina

@type    Static Function
@author  Alberto Deviciente
@since   18/08/2026
@version 12
@return  aRotina, array, opcoes do menu
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina As Array
    aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.LOJA6130" OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.LOJA6130" OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0005 ACTION "Lj6130Excl" OPERATION 5 ACCESS 0 //"Excluir"
    ADD OPTION aRotina TITLE STR0011 ACTION "Lj6130Imp" OPERATION 8 ACCESS 0 //"Imprimir Comprovante"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados

@type    Static Function
@author  Alberto Deviciente
@since   18/08/2026
@version 12
@return  oModel, object, modelo de dados
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oModel    As Object
    Local oStruMFV  As Object
    Local oStruMFX  As Object
    Local bPosVld   As Codeblock
    Local bCommit   As Codeblock

    oStruMFV  := FWFormStruct(1, "MFV")
    oStruMFX  := FWFormStruct(1, "MFX")
    bPosVld := {|oModel| Lj6130VlPs(oModel)} //Validação pós gravação do movimento de Entrada de Sucata
    bCommit := {|oModel| Lj6130Grv(oModel)} //Gravação do modelo

    // Cria o modelo de dados
    oModel := MPFormModel():New("LOJA6130", /*bPreVld*/,  bPosVld, bCommit, /*bCancel*/)

    oModel:SetDescription(STR0001) //"Entrada de Sucata"

    // Adiciona o formulário de cabeçalho (MFV)
    oModel:AddFields("MFVMASTER", "", oStruMFV)

    // Adiciona a grid de itens (MFX)
    oModel:AddGrid("MFXDETAIL", "MFVMASTER", oStruMFX)

    // Define o relacionamento MFV -> MFX
    oModel:SetRelation("MFXDETAIL", { {"MFX_FILIAL", "xFilial('MFX')"}, {"MFX_COD", "MFV_COD"} }, "MFX_FILIAL+MFX_COD")

    // Campo totalizador (somente leitura) com o somatorio da coluna MFX_VLTOT
    oModel:AddCalc("CMPCALCTOT", "MFVMASTER", "MFXDETAIL", "MFX_VLTOT", "MFVVLRTOT", "SUM",,,"") //"Total"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@type    Static Function
@author  Alberto Deviciente
@since   18/08/2026
@version 12
@return  oView, object, objeto da view
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local oModel    As Object
    Local oStruMFV  As Object
    Local oStruMFX  As Object
    Local oCalcMFV  As Object
    Local oView     As Object

    oModel   := FWLoadModel("LOJA6130")
    oStruMFV := FWFormStruct(2, "MFV")
    oStruMFX := FWFormStruct(2, "MFX")
    oCalcMFV := FWCalcStruct(oModel:GetModel("CMPCALCTOT"))
    oView    := FWFormView():New()

    // Remove campo da estrutura que nao deve ser apresentado na tela
    oStruMFX:RemoveField("MFX_COD")
    
    oView:SetDescription(STR0001) //"Entrada de Sucata"

    oView:SetModel(oModel)

    // Adiciona o formulário de cabeçalho (MFV)
    oView:AddField("VIEW_MFV", oStruMFV, "MFVMASTER")

    // Adiciona a grid de itens (MFX)
    oView:AddGrid("VIEW_MFX", oStruMFX, "MFXDETAIL")

    oView:AddIncrementField('VIEW_MFX', 'MFX_ITEM')

    // Adiciona o campo totalizador (somente leitura) da soma de MFX_VLTOT
    oView:AddField("VIEW_TOTAL", oCalcMFV, "CMPCALCTOT")

    // Define os boxes de layout
    oView:CreateHorizontalBox("SUPERIOR", 50)
    oView:CreateHorizontalBox("GRIDITENS", 30)
    oView:CreateHorizontalBox("RODAPE", 20)

    // Divide o RODAPE em duas colunas para alinhar o totalizador a direita da tela
    oView:CreateVerticalBox("RODAPE_ESQ", 70, "RODAPE", .F.)
    oView:CreateVerticalBox("RODAPE_DIR", 30, "RODAPE", .F.)

    // Associa os componentes aos boxes
    oView:SetOwnerView("VIEW_MFV", "SUPERIOR")
    oView:SetOwnerView("VIEW_MFX", "GRIDITENS")
    oView:SetOwnerView("VIEW_TOTAL", "RODAPE_DIR")

    // Exibe STR0009 como titulo em destaque (negrito) do totalizador
    oView:EnableTitleView("VIEW_TOTAL", STR0009) //"Total"

Return oView

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130VLFP
Função de validação do campo MFV_FORPAG.

@type    Function
@author  Alberto Deviciente
@since   18/08/2026
@version 12
@return  lRet, Logical, Returna .T. se valdiação for bem sucedida, .F. caso contrário
/*/
//-------------------------------------------------------------------------------
Function Lj6130VLFP()
    Local lRet      As Logical
    Local oModel    As Object
    Local oMdlCab   As Object
    Local cForPag   As Character
    
    lRet    := .T.
    oModel  := FWModelActive()
    oMdlCab := oModel:GetModel('MFVMASTER')
    cForPag := oMdlCab:GetValue("MFV_FORPAG")

    If LjIsCliPad(oMdlCab:GetValue("MFV_CODCLI"), oMdlCab:GetValue("MFV_LOJA")) .And. cForPag <> "1"
        //Bloqueia forma de pagamento diferente de Dinheiro para o Cliente Padrão
        Help(" ", 1, "HELP", NIL, STR0006, 1, 0,,,,,, {STR0012}) //Para o Cliente Padrão, somente é permitido pagamento em Dinheiro ### "Escolha a forma de pagamento em dinheiro para cliente padrão ou identifique o cliente para utilizar outras formas de pagamento"
        lRet := .F.
    EndIf

    If lRet
        If cForPag == "1" .Or. cForPag == "4" //1=Dinheiro ; 4=Crédito NCC
            oMdlCab:LoadValue("MFV_CHPIX", Space(TamSX3("MFV_CHPIX")[1]))
            oMdlCab:LoadValue("MFV_BANCO", Space(TamSX3("MFV_BANCO")[1]))
            oMdlCab:LoadValue("MFV_AGENC", Space(TamSX3("MFV_AGENC")[1]))
            oMdlCab:LoadValue("MFV_CONTA", Space(TamSX3("MFV_CONTA")[1]))
        ElseIf cForPag == "2" //2=PIX
            oMdlCab:LoadValue("MFV_BANCO", Space(TamSX3("MFV_BANCO")[1]))
            oMdlCab:LoadValue("MFV_AGENC", Space(TamSX3("MFV_AGENC")[1]))
            oMdlCab:LoadValue("MFV_CONTA", Space(TamSX3("MFV_CONTA")[1]))
        ElseIf cForPag == "3" //3=Depósito
			oMdlCab:LoadValue("MFV_CHPIX", Space(TamSX3("MFV_CHPIX")[1]))
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} LjIsCliPad
Verifica se o cliente/loja informado corresponde ao Cliente Padrão (MV_CLIPAD/MV_LOJAPAD)

@type    Static Function
@author  Alberto Deviciente
@since   18/08/2026
@version 12
@param   cCodCli, Character, Código do cliente
@param   cLoja, Character, Loja do cliente
@return  lRet, Logical, .T. se for o Cliente Padrão
/*/
//-------------------------------------------------------------------------------
Static Function LjIsCliPad(cCodCli, cLoja)
    Local lRet As Logical

    lRet := AllTrim(cCodCli) + AllTrim(cLoja) == AllTrim(SuperGetMv("MV_CLIPAD", .F., "")) + AllTrim(SuperGetMv("MV_LOJAPAD", .F., ""))

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130VlEx
Valida se pode efetuar a exclusão do registro de Entrada de Sucata.

@type    Static Function
@author  Alberto Deviciente
@since   28/08/2026
@version 12
@return  lRet, Logical, .T. se o registro pode ser excluído, .F. caso contrário
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130VlEx()
	Local lRet      As Logical
    Local aArea     As Array
    Local cParcela  As Character
    Local cTipo     As Character

    lRet        := .T.
    aArea       := GetArea()
    cParcela    := LJParcela(1, SuperGetMV("MV_1DUP"))
    cTipo       := LjTipoTit(MFV->MFV_FORPAG)

    //Verificar se o titulo de contas a pagar (SE2) gerado pelo movimento de Entrada de Sucata (MFV) ainda não foi baixado
    If !Empty(MFV->MFV_DOC)
        
        If MFV->MFV_FORPAG $ "1|2|3" //1=Dinheiro, 2=PIX ou 3=Depósito 
            DbSelectArea("SE2")
            SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
            If SE2->(DbSeek(xFilial("SE2") + MFV->MFV_SERIE + MFV->MFV_DOC + cParcela + cTipo + MFV->MFV_FORNEC + MFV->MFV_LOJFOR))
                If SE2->E2_SALDO <> SE2->E2_VALOR
                    Help(" ", 1, "HELP", NIL, STR0013, 1, 0) //"Não é permitida a exclusão deste registro, pois o pagamento já foi realizado."
                    lRet := .F.
                Else
                    lRet := MsgYesNo(STR0014 + CRLF+CRLF + STR0015, STR0016) //"Existe movimentação de entrada com Documento Fiscal." ### "Deseja realmente excluir este registro e os movimentos de entrada fiscal e financeiro?" ### "Atenção!"
                EndIf
            EndIf
        EndIf

        If MFV->MFV_FORPAG == "4" //4=Crédito NCC
            DbSelectArea("SE1")
            SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
            If SE1->(DbSeek(xFilial("SE1") + MFV->MFV_SERIE + MFV->MFV_DOC + cParcela + cTipo ))
                If SE1->E1_SALDO <> SE1->E1_VALOR
                    Help(" ", 1, "HELP", NIL, STR0018, 1, 0) //"Não é permitida a exclusão deste registro, pois o crédito (NCC) já foi utilizado."
                    lRet := .F.
                Else
                    lRet := MsgYesNo(STR0014 + CRLF+CRLF + STR0015, STR0016) //"Existe movimentação de entrada com Documento Fiscal." ### "Deseja realmente excluir este registro e os movimentos de entrada fiscal e financeiro?" ### "Atenção!"
                EndIf
            EndIf
        EndIf

    EndIf

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130VlPs
Bloco de validação do movimento de Entrada de Sucata (obrigatoriedade de PIX/dados
bancários conforme a forma de pagamento e obrigatoriedade de CPF/CNPJ para clientes identificados)

@type    Static Function
@author  Alberto Deviciente
@since   18/08/2026
@version 12
@param   oModel, Object, Objeto de Model do movimento de Entrada de Sucata
@return  lRet, Logical, Resultado da validação do movimento de Entrada de Sucata
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130VlPs(oModel)
    Local lRet       As Logical
    Local aArea      As Array
    Local nOperation As Numeric
    Local oMFV       As Object
    Local cForPag    As Character
    Local lIsCliPad  As Logical

    lRet        := .T.
    aArea       := GetArea()
    nOperation  := oModel:GetOperation()
    
    If nOperation == MODEL_OPERATION_INSERT

        oMFV        := oModel:GetModel("MFVMASTER")
        cForPag     := oMFV:GetValue("MFV_FORPAG")
        lIsCliPad   := LjIsCliPad(oMFV:GetValue("MFV_CODCLI"), oMFV:GetValue("MFV_LOJA"))

        If cForPag == "2" //PIX
            If Empty(oMFV:GetValue("MFV_CHPIX"))
                Help(" ", 1, "HELP", NIL, STR0007, 1, 0) //"Chave PIX é obrigatória para a Forma de Pagamento PIX"
                lRet := .F.
            EndIf
        ElseIf cForPag == "3" //Depósito
            If Empty(oMFV:GetValue("MFV_BANCO")) .Or. Empty(oMFV:GetValue("MFV_AGENC")) .Or. Empty(oMFV:GetValue("MFV_CONTA"))
                Help(" ", 1, "HELP", NIL, STR0008, 1, 0) //"Banco, Agência e Conta são obrigatórios para a Forma de Pagamento Depósito"
                lRet := .F.
            EndIf
        EndIf

        If lRet .And. lIsCliPad .And. cForPag <> "1"
            Help(" ", 1, "HELP", NIL, STR0006, 1, 0,,,,,, {STR0012}) //Para o Cliente Padrão, somente é permitido pagamento em Dinheiro ### "Escolha a forma de pagamento em dinheiro para cliente padrão ou identifique o cliente para utilizar outras formas de pagamento"
            lRet := .F.
        EndIf

        If lRet .And. !lIsCliPad
            //Se for cliente identificado, verifica se o CPF/CNPJ do cliente (SA1) está alimentado
            DbSelectArea("SA1")
            SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
            If SA1->(DbSeek(xFilial("SA1") + oMFV:GetValue("MFV_CODCLI") + oMFV:GetValue("MFV_LOJA")))
                If Empty(SA1->A1_CGC)
                    Help(" ", 1, "HELP", NIL, STR0019, 1, 0,,,,,, {STR0020}) //"O cliente informado não possui CPF/CNPJ cadastrado." ### "Para prosseguir, é necessário incluir essa informação no cadastro do cliente."
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130Grv
Executa a gravação do modelo LOJA6130.

@type    Static Function
@author  Alberto Deviciente
@since   30/08/2026
@version 12
@param   oModel, Object, Objeto do modelo de dados
@return  lRet, Logical, .T. se a gravação e geração foram concluídas com sucesso
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130Grv(oModel)
    Local lRet       As Logical
    Local nOperation As Numeric
    Local cMsgAlert  As Character

    lRet       := .T.
    nOperation := oModel:GetOperation()
    cMsgAlert  := ""

    BEGIN TRANSACTION
        // Executa a gravação padrão das tabelas MFV e MFX
        lRet := FwFormCommit(oModel)

        If nOperation == MODEL_OPERATION_INSERT
            If lRet
                // Na operação de inclusão, executa a geração do documento fiscal de entrada (Lj6130GNF) dentro da mesma transação
                lRet := Lj6130GNF()
                If !lRet
                    DisarmTransaction()
                EndIf
            EndIf
        EndIf
    END TRANSACTION

    If nOperation == MODEL_OPERATION_INSERT
        If lRet
            If MFV->MFV_FORPAG $ "1|2|3" //1=Dinheiro, 2=PIX ou 3=Depósito 
                cMsgAlert := STR0021 + " - " + STR0022 + MFV->MFV_DOC + " / " + STR0023 + MFV->MFV_SERIE + CRLF + CRLF //"Titulo a Pagar" ### " - " ### "Núm: "  ### " / "Prefixo: ": "
            EndIf
            If MFV->MFV_FORPAG == "4" //4=Crédito NCC
                cMsgAlert := STR0024 + " - " + STR0022 + MFV->MFV_DOC + " / " + STR0023 + MFV->MFV_SERIE + CRLF + CRLF //"Nota de Crédito (NCC)" ### " - " ### "Núm: " ### " / "Prefixo: "
            EndIf
            
            cMsgAlert :=    STR0025 + CRLF + CRLF + ; //"Informações geradas: "
                            STR0026 + " - " + STR0027 + MFV->MFV_DOC + " /  " + STR0028 + MFV->MFV_SERIE + CRLF + CRLF + ; //"Nota Fiscal de Entrada" ### "Doc: " ### "Série: "
                            cMsgAlert
            MsgInfo(cMsgAlert, STR0029) //"Processo concluído!"

            If MsgYesNo(STR0017, STR0016) //"Atenção!" ### "Deseja imprimir o comprovante da entrada de sucata?"
                Lj6130Imp()
            EndIf
        Else
            oModel:SetErrorMessage(, , , , , STR0030, , , ) //"Problema ao realizar a gravação"
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130GNF
Gera a Nota Fiscal de Entrada (MATA103) para o registro de Entrada de Sucata posicionado

@type    Function
@author  Alberto Deviciente
@since   27/08/2026
@version 12
@return  Nil, Logical, .T. se o documento de entrada foi gerado com sucesso, .F. caso contrário
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130GNF()
    Local lRet As Logical

    FwMsgRun( , { || lRet := LjRunGerNF() },STR0031,STR0032 ) //"Aguarde..." ### "Gerando dados de entrada..."

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} LjRunGerNF
Executa a geração a Nota Fiscal de Entrada (MATA103) para o registro de Entrada de Sucata posicionado

@type    Function
@author  Alberto Deviciente
@since   27/08/2026
@version 12
@return  lRet, Logical, .T. se nota gerada com sucesso
/*/
//-------------------------------------------------------------------------------
Static Function LjRunGerNF()
    Local lRet          As Logical
    Local aArea         As Array
    Local cCodMov       As Character
    Local cCliente      As Character
    Local cLoja         As Character
    Local cForPag       As Character
    Local cNumDoc       As Character
    Local cSerie        As Character
    Local cCodFornec    As Character
    Local cLojaForne    As Character
    Local cErro         As Character
    Local aCab          As Array
    Local aItens        As Array

    Private lMsErroAuto As Logical

    lRet            := .F.
    aArea           := GetArea()
    cCodMov         := MFV->MFV_COD
    cCliente        := MFV->MFV_CODCLI
    cLoja           := MFV->MFV_LOJA
    cForPag         := MFV->MFV_FORPAG
    cNumDoc         := ""
    cSerie          := ""
    cCodFornec      := ""
    cLojaForne      := ""
    cErro           := ""
    aCab            := Lj6130Cab(cCodMov, cCliente, cLoja, @cNumDoc, @cSerie, @cCodFornec, @cLojaForne, cForPag)
    aItens          := Lj6130Item()

    lMsErroAuto     := .F.

    If Len(aCab) > 0 .And. Len(aItens) > 0
        lRet := .T.
    EndIf

    If lRet

        BEGIN TRANSACTION

            MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCab, aItens, 3) //3=Inclusao

            If lMsErroAuto
                lRet := .F.
                cErro := STR0035 + CRLF //"Problema na inclusão do Documento Fiscal de Entrada"
                cErro += MostraErro()
                LjGrvLog(cCodMov, cErro )
                DisarmTransaction()
            Else
                lRet := .T.
                LjGrvLog(cCodMov, "Sucesso na inclusão do Documento Fiscal de Entrada - Doc: " + cNumDoc + " - Série: " + cSerie )
                LjAtuDados(cCodMov, cSerie, cNumDoc, cCodFornec, cLojaForne)

                //Inclui o Titulo Financeiro de Contas a Pagar ou Contas a Receber
                If lRet
                    If MFV->MFV_FORPAG $ "1|2|3" //1=Dinheiro, 2=PIX ou 3=Depósito 
                        lRet := Lj6130CtPg(3)
                    EndIf
                    If MFV->MFV_FORPAG == "4" //4=Crédito NCC
                        lRet := Lj6130CtRb(3)
                    EndIf
                EndIf
            EndIf

        END TRANSACTION
        
    EndIf

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130Cab
Monta o cabeçalho (aCab) para o MSExecAuto(MATA103) do movimento de Entrada de Sucata

@type  Static Function
@author  Alberto Deviciente
@since   18/08/2026
@version 12
@param   cCodMov, Character, Código do movimento de Entrada de Sucata (MFV_COD)
@param   cCliente, Character, Código do cliente (SA1)
@param   cLoja, Character, Loja do cliente (SA1)
@param   cNumDoc, Character, Número do Documento Fiscal de Entrada (SF1)
@param   cSerie, Character, Número da Série do Documento Fiscal de Entrada (SF1)
@param   cCodFornec, Character, Código do Fornecedor do Documento Fiscal de Entrada (SF1)
@param   cLojaForne, Character, Loja do Fornecedor do Documento Fiscal de Entrada (SF1)
@param   cForPag, Character, Forma de pagamento informada no MFV_FORPAG
@return  aCab, Array, Dados do Cabeçalho para a Nota de Entrada (MATA103)
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130Cab(cCodMov, cCliente, cLoja, cNumDoc, cSerie, cCodFornec, cLojaForne, cForPag)
    Local aCab          As Array
    Local cEspecie      As Character
    Local cCond         As Character
    Local cHoraRMT      As Character
    Local aHorario      As Array
    Local cF1Hora       As Character
    Local aNota         As Array
    Local lFornecOk     As Logical
    
    Default cSerie      := ""
    Default cNumDoc     := ""
    Default cCodFornec  := ""
    Default cLojaForne  := ""

    aCab        := {}
    cSerie      := SuperGetMv("MV_LJSERSU",.F.,"")
    cEspecie    := LjNfEspeci(cSerie, )
    cCond       := SuperGetMv("MV_LJCNDSU",.F., "")
    cHoraRMT    := SuperGetMv("MV_HORARMT",.F.,"2")
    cF1Hora     := Time()
    aHorario    := {}
    aNota       := {}
   
    // Busca o fornecedor a ser utilizado na geração da nota fiscal de entrada
    lFornecOk := Lj6130Forn(cCodMov, cCliente, cLoja, @cCodFornec, @cLojaForne)

    If lFornecOk
        
        //Busca o próximo número de documento fiscal para a série informada
        LjxDNota(cSerie, 3, .F., 1, @aNota,,,,,,,,,,,,, cEspecie)
        cNumDoc := aNota[1][2]

        //Verifica onde pegar a hora de acordo com a configuração do Parametro MV_HORARMT
        If cHoraRMT == '1' //Horario do Client
            cF1Hora := GetRmtTime()
        ElseIf cHoraRMT =='3' //Horario de acordo com o estado da filial corrente
            aHorario := A103HORA()
            If !Empty(aHorario[2])
                cF1Hora := aHorario[2]
            EndIf
        EndIf

        AAdd(aCab, {"F1_TIPO"   , "N"       , Nil}) //Tipo da NF (Normal)
        AAdd(aCab, {"F1_FORMUL" , "S"       , Nil}) //Formulário Proprio (S=Sim)
        AAdd(aCab, {"F1_FORNECE", cCodFornec, Nil})
        AAdd(aCab, {"F1_LOJA"   , cLojaForne, Nil})
        AAdd(aCab, {"F1_EMISSAO", dDataBase , Nil})
        AAdd(aCab, {"F1_HORA"   , cF1Hora   , Nil})
        AAdd(aCab, {"F1_ESPECIE", cEspecie  , Nil})
        AAdd(aCab, {"F1_COND"   , cCond     , Nil})
        AAdd(aCab, {"F1_SERIE"  , cSerie    , Nil } ) // Serie da NF
        AAdd(aCab, {"F1_DOC"    , cNumDoc   , Nil } ) // Numero da NF
        AAdd(aCab, {"F1_ORIGLAN", "LO"      , Nil } ) // Origem LO=Loja

    EndIf

Return aCab

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130Item
Monta os itens (aItens) para o MSExecAuto(MATA103) a partir da tabela MFX ou do grid

@type    Static Function
@author  Alberto Deviciente
@since   18/08/2026
@version 12
@return  aItens, Array, Itens para os itens da nota de entrada (MATA103)
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130Item()
    Local aArea         As Array
    Local aItens        As Array
    Local aLinha        As Array
    Local cTes          As Character
    Local cFilMGA       As Character
    Local cCodProd      As Character

    aArea       := GetArea()
    aItens      := {}
    cTes        := SuperGetMv("MV_LJTESSU", .F., "")
    cFilMGA     := FwxFilial("MGA")

    DbSelectArea("MFX")
    MFX->(DbSetOrder(1))
    If MFX->(DbSeek(xFilial("MFX") + MFV->MFV_COD))
        While MFX->(!Eof()) .And. MFX->MFX_FILIAL == xFilial("MFX") .And. MFX->MFX_COD == MFV->MFV_COD
            aLinha := {}
            cCodProd := GetAdvFVal("MGA", "MGA_PRODUT", cFilMGA + MFX->MFX_TIPSUC, 1)
            AAdd(aLinha, {"D1_COD",   cCodProd,        Nil})
            AAdd(aLinha, {"D1_QUANT", MFX->MFX_QTD,    Nil})
            AAdd(aLinha, {"D1_VUNIT", MFX->MFX_VLUNIT, Nil})
            AAdd(aLinha, {"D1_TOTAL", MFX->MFX_VLTOT,  Nil})
            AAdd(aLinha, {"D1_TES",   cTes,            Nil})
            AAdd(aItens, aLinha)
            MFX->(DbSkip())
        EndDo
    EndIf

    RestArea(aArea)

Return aItens

//-------------------------------------------------------------------------------
/*/{Protheus.doc} LjAtuDados
Atualiza dados do Movimentod e Entrada de sucata (MFV) com os dados da Nota Fiscal 
de Entrada gerada (MATA103).

@type    Static Function
@author  Alberto Deviciente
@since   27/08/2026
@version 12
@param   cCodMov, Character, Código do Movimento de Entrada de Sucata (MFV)
@param   cSerie, Character, Número da Série do Documento Fiscal de Entrada (SF1)
@param   cNumDoc, Character, Número do Documento Fiscal de Entrada (SF1)
@param   cCodFornec, Character, Código do Fornecedor do Documento Fiscal de Entrada (SF1)
@param   cLojaForne, Character, Loja do Fornecedor do Documento Fiscal de Entrada (SF1)
@return  Nil, Nulo
/*/
//-------------------------------------------------------------------------------
Static Function LjAtuDados(cCodMov, cSerie, cNumDoc, cCodFornec, cLojaForne)

    MFV->(DbSetOrder(1)) //MFV_FILIAL+MFV_COD
    If MFV->(DbSeek(xFilial("MFV") + cCodMov))
        
        RecLock("MFV", .F.)
        //Alimanta os campos que relaciona o documento fiscal de entrada (SF1)
        MFV->MFV_DOC    := cNumDoc
        MFV->MFV_SERIE  := cSerie
        MFV->MFV_FORNEC := cCodFornec
        MFV->MFV_LOJFOR := cLojaForne
        MFV->(MsUnLock())

    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130Forn
Verifica se existe fornecedor (SA2) cadastrado com o mesmo CPF/CNPJ (A1_CGC) do
cliente (SA1). Caso não exista, inclui o novo fornecedor na SA2 copiando as
informações básicas do cadastro de clientes (SA1).

@type    Static Function
@author  Alberto Deviciente
@since   27/08/2026
@version 12
@param   cCodMov, Character, Código do movimento de Entrada de Sucata (MFV_COD)
@param   cCliente, Character, Código do cliente (SA1)
@param   cLoja, Character, Loja do cliente (SA1)
@param   cCodFornec, Character, Código do fornecedor (SA2) passado por referência
@param   cLojaForne, Character, Loja do fornecedor (SA2) passado por referência
@return  lRet, Logical, .T. se o fornecedor foi encontrado com sucesso
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130Forn(cCodMov, cCliente, cLoja, cCodFornec, cLojaForne)
    Local aArea         As Array
    Local lRet          As Logical
    Local cCpfCnpj      As Character
    Local nTamCodFor    As Numeric
    Local nTamLojFor    As Numeric

    Default cCodFornec := ""
    Default cLojaForne := ""

    aArea       := GetArea()
    lRet        := .F.
    cCpfCnpj    := ""
    nTamCodFor  := TamSX3("A2_COD")[1]
    nTamLojFor  := TamSX3("A2_LOJA")[1]

    //Verifica se o cliente/loja informado corresponde ao Cliente Padrão (MV_CLIPAD/MV_LOJAPAD)
    If LjIsCliPad(cCliente, cLoja)
        //Considera o Fornecedor padrão para o Cliente Padrão
        cCodFornec := SuperGetMv("MV_LJFORSU", .F., "")
        cLojaForne := SuperGetMv("MV_LJLOJSU", .F., "")
        cCodFornec := PadR(cCodFornec, nTamCodFor)
        cLojaForne := PadR(cLojaForne, nTamLojFor)
        DbSelectArea("SA2")
        SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
        If SA2->(DbSeek(xFilial("SA2") + cCodFornec + cLojaForne))
            lRet := .T.
        Else
            Help(" ", 1, "HELP", NIL, STR0036 + " MV_LJFORSU / MV_LJLOJSU ", 1, 0) //"Não existe o Fornecedor padrão configurado nos parâmetros: "
            lRet  := .F.
            LjGrvLog(cCodMov, "Não existe o Fornecedor padrão configurado nos parâmetros: MV_LJFORSU / MV_LJLOJSU" )
        EndIf
    Else
        DbSelectArea("SA1")
        SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
        If SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja))
            cCpfCnpj := SA1->A1_CGC
        EndIf

        If !Empty(cCpfCnpj)
            // Pesquisa no cadastro de fornecedores (SA2) por CPF/CNPJ
            //para verificar se já existe o cliente cadastrado também como fornecedor
            DbSelectArea("SA2")
            SA2->(DbSetOrder(3)) //A2_FILIAL+A2_CGC
            If SA2->(DbSeek(xFilial("SA2") + PadR(cCpfCnpj, TamSX3("A2_CGC")[1])))
                cCodFornec := SA2->A2_COD
                cLojaForne := SA2->A2_LOJA
                lRet       := .T.
            EndIf
        EndIf

        If !lRet
            // Fornecedor não encontrado: inclui novo fornecedor na SA2 copiando dados do SA1
            lRet := LjIncForne(cCodMov, @cCodFornec, @cLojaForne, cLoja)
        EndIf
    EndIf
    
    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} LjIncForne
Inclui um novo fornecedor na SA2 copiando as informações básicas do cadastro de clientes (SA1).

@type    Static Function
@author  Alberto Deviciente
@since   27/08/2026
@version 12
@param   cCodMov, Character, Código do movimento de Entrada de Sucata (MFV_COD)
@param   cCodFornec, Character, Código do fornecedor (SA2) passado por referência
@param   cLojaForne, Character, Loja do fornecedor (SA2) passado por referência
@param   cLojaCli, Character, Loja do cliente (SA1)
@return  lRet, Logical, .T. se o fornecedor foi incluído com sucesso.
/*/
//-------------------------------------------------------------------------------
Static Function LjIncForne(cCodMov, cCodFornec, cLojaForne, cLojaCli)
    Local aArea         As Array
    Local lRet          As Logical
    Local cCodFor       As Character
    Local cLojFor       As Character
    Local nTamCodFor    As Numeric
    Local nTamLojFor    As Numeric
    Local aCabFornec    As Array
    Local cTipFornec    As Character
    Local cErro         As Character

    Private lMsErroAuto As Logical

    Default cCodFornec := ""
    Default cLojaForne := ""

    aArea       := GetArea()
    lRet        := .F.
    cCodFor     := ""
    cLojFor     := ""
    nTamCodFor  := TamSX3("A2_COD")[1]
    nTamLojFor  := TamSX3("A2_LOJA")[1]
    aCabFornec  := {}
    cTipFornec  := "X" //X=Outros
    cErro       := ""

    lMsErroAuto := .F.

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
    //Primeiro tenta pegar a numeração pelo inicializador padrão do campo 
    cCodFor := CRIAVAR("A2_COD")
    cLojFor := CRIAVAR("A2_LOJA")
    If Empty(cLojFor)
        cLojFor := cLojaCli
    EndIf
    If Empty(cCodFor)
        //Se não tiver inicializador padrão do campo, então pega o próximo numero disponível pela função GetSXENum
        cCodFor := GetSXENum("SA2", "A2_COD")
    EndIf
    cCodFor := PadR(cCodFor, nTamCodFor)
    cLojFor := PadR(cLojFor, nTamLojFor)
    While SA2->(MsSeek(xFilial("SA2")+cCodFor+cLojFor)) 
        ConfirmSX8() 
        cCodFor := GetSxeNum("SA2","A2_COD") 
        cCodFor := PadR(cCodFor, nTamCodFor)
    EndDo

    If !Empty(SA1->A1_PESSOA)
        cTipFornec := SA1->A1_PESSOA
    Endif

    //Considera os dados do cliente (SA1) para incluir o fornecedor (SA2)
    aAdd(aCabFornec,{"A2_COD"     ,cCodFor                  ,Nil})
    aAdd(aCabFornec,{"A2_LOJA"    ,cLojFor                  ,Nil})
    aAdd(aCabFornec,{"A2_NOME"    ,AllTrim(SA1->A1_NOME)    ,Nil})
    aAdd(aCabFornec,{"A2_NREDUZ"  ,AllTrim(SA1->A1_NREDUZ)  ,Nil})
    aAdd(aCabFornec,{"A2_TIPO"    ,cTipFornec               ,Nil})
    aAdd(aCabFornec,{"A2_CGC"     ,SA1->A1_CGC              ,Nil})
    aAdd(aCabFornec,{"A2_END"     ,AllTrim(SA1->A1_END)     ,Nil})
    aAdd(aCabFornec,{"A2_BAIRRO"  ,AllTrim(SA1->A1_BAIRRO)  ,Nil})
    aAdd(aCabFornec,{"A2_EST"     ,SA1->A1_EST              ,Nil})
    aAdd(aCabFornec,{"A2_COD_MUN" ,SA1->A1_COD_MUN          ,Nil})
    aAdd(aCabFornec,{"A2_MUN"     ,AllTrim(SA1->A1_MUN)     ,Nil})
    aAdd(aCabFornec,{"A2_CEP"     ,SA1->A1_CEP              ,Nil})
    aAdd(aCabFornec,{"A2_DDD"     ,AllTrim(SA1->A1_DDD)     ,Nil})
    aAdd(aCabFornec,{"A2_TEL"     ,AllTrim(SA1->A1_TEL)     ,Nil})
    aAdd(aCabFornec,{"A2_EMAIL"   ,AllTrim(SA1->A1_EMAIL)   ,Nil})
    aAdd(aCabFornec,{"A2_PAIS"    ,SA1->A1_PAIS             ,Nil})

    BEGIN TRANSACTION

        MSExecAuto({|x,y| MATA020(x)},aCabFornec,3) //Chama ExecAuto para inclusao do fornecedor na SA2
    
        If lMsErroAuto
            lRet  := .F.
            RollBackSx8()
            cErro := STR0037 + CRLF //"Problema na inclusão do Fornecedor para Geração do Documento Fiscal de Entrada"
            cErro += MostraErro()
            LjGrvLog(cCodMov, cErro )
            DisarmTransaction()
            Break
        Else
            lRet       := .T.
            cCodFornec := cCodFor
            cLojaForne := cLojFor
            ConfirmSX8()
            LjGrvLog(cCodMov, "Sucesso no processamento da ExecAuto MATA020. Fornecedor/Loja Incluido: " + cCodFornec+"/"+cLojaForne )
        EndIf

    END TRANSACTION

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130Excl
Realiza o processo de Exclusão do registro de Entrada de Sucata.

@type    Function
@author  Alberto Deviciente
@since   28/08/2026
@version 12
@return  Nil, Nulo
/*/
//-------------------------------------------------------------------------------
Function Lj6130Excl()
    Local lContinua As Logical
    Local oModel    As Object
    Local lRet      As Logical
    Local bOk       As Codeblock

    lContinua   := Lj6130VlEx()
    lRet        := .F.
    bOk         := { || lRet := Lj6130GoEx() }

    If lContinua
        FWExecView(STR0008,"LOJA6130", MODEL_OPERATION_DELETE,/*oDlg*/,/*bCloseOnOk*/, bOk ,,,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //'Excluir'
    EndIf

Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130GoEx
Executa o processo de Exclusão do registro de Entrada de Sucata.

@type    Function
@author  Alberto Deviciente
@since   28/08/2026
@version 12
@return  lRet, Logical, .T. se Exclusão executada com sucesso
/*/
//-------------------------------------------------------------------------------
Function Lj6130GoEx()
    Local lRet      As Logical
    Local aArea     As Array

    lRet    := .F.
    aArea   := GetArea()

    FwMsgRun( , { || lRet := LjRunExcl() },STR0031,STR0033 ) //"Aguarde..." ### "Processando a exclusão..."

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} LjRunExcl
Executa o processo de Exclusão do registro de Entrada de Sucata, exclusão do 
Documento Fiscal de Entrada (MATA103) e do título de Contas a Pagar (SE2) ou 
Contas a Receber (SE1).

@type    Function
@author  Alberto Deviciente
@since   28/08/2026
@version 12
@return  lRet, Logical, .T. se Exclusão executada com sucesso
/*/
//-------------------------------------------------------------------------------
Static Function LjRunExcl()
    Local lRet  As Logical

    lRet := .T.

    If !Empty(MFV->MFV_DOC)

        BEGIN TRANSACTION
            
            //Exclui o Documento Fiscal de Entrada
            lRet := Lj6130ExNF()
            
            //Exclui o Titulo Financeiro de Contas a Pagar ou Contas a Receber
            If lRet
                If MFV->MFV_FORPAG $ "1|2|3" //1=Dinheiro, 2=PIX ou 3=Depósito 
                    lRet := Lj6130CtPg(5)
                EndIf
                If MFV->MFV_FORPAG == "4" //4=Crédito NCC
                    lRet := Lj6130CtRb(5)
                EndIf
            EndIf

            If !lRet
                DisarmTransaction()
                Break
            EndIf

        END TRANSACTION

    EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130ExNF
Executa a exclusão do Documento Fiscal de Entrada (MATA103) gerado.

@type    Function
@author  Alberto Deviciente
@since   28/08/2026
@version 12
@return  lRet, Logical, .T. se o do Documento de Entrada foi excluído com sucesso.
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130ExNF()
    Local lRet          As Logical
    Local aArea         As Array
    Local cMsgLog       As Character
    Local aCab          As Array
    Local aItens        As Array
    
    Private lMsErroAuto As Logical

    lRet            := .T.
    aArea           := GetArea()
    cMsgLog         := ""
    aCab            := {}
    aItens          := {}

    lMsErroAuto     := .F.

    DbSelectArea("SF1")
    SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
    lRet := SF1->(DbSeek(xFilial("SF1") + MFV->MFV_DOC + MFV->MFV_SERIE + MFV->MFV_FORNEC + MFV->MFV_LOJFOR + "N"))

    If lRet
        //Cabeçalho do Documento de Entrada
        Aadd( aCab, { "F1_DOC"	    , SF1->F1_DOC		,Nil } )
        Aadd( aCab, { "F1_SERIE"	, SF1->F1_SERIE		,Nil } )
        Aadd( aCab, { "F1_FORNECE"  , SF1->F1_FORNECE	,Nil } )
        Aadd( aCab, { "F1_LOJA"	    , SF1->F1_LOJA		,Nil } )
        Aadd( aCab, { "F1_TIPO"	    , SF1->F1_TIPO		,Nil } )

        MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCab, aItens, 5) //5=Exclusao
        
        cMsgLog := STR0027 + MFV->MFV_DOC + " - " + STR0028 + MFV->MFV_SERIE //"Doc: " ### "Série: "

        If lMsErroAuto
            lRet := .F.
            cMsgLog := STR0038 + cMsgLog + CRLF //"Problema na exclusao do Documento Fiscal de Entrada. "
            cMsgLog += MostraErro()
            DisarmTransaction()
        Else
            lRet := .T.
            cMsgLog := STR0039 + cMsgLog //"Sucesso na exclusao do Documento Fiscal de Entrada. "
        EndIf

        LjGrvLog(MFV->MFV_COD, cMsgLog)

    EndIf

    RestArea(aArea)
    
Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130CtPg
Efetua a inclusao ou exclusão do título de Contas a Pagar (SE2) de acordo com a 
forma de pagamento (MFV_FORPAG) escolhida na Entrada de Sucata.

@type    Static Function
@author  Alberto Deviciente
@since   28/08/2026
@version 12
@param   nOperacao, Numeric, Tipo de operação a ser realizada (3=Inclusão de título; 5=Exclusão de título)
@return  lRet, Logical, .T. se o titulo foi incluído ou excluido com sucesso.
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130CtPg(nOperacao)
	Local lRet          As Logical
	Local aDadosSE2     As Array
    Local cMsgLog       As Character
    Local cParcela      As Character
    Local cTipo         As Character
    Local cNatureza     As Character
    Local cHistorico    As Character
    Local nValor        As Numeric
    Local aTitBx        As Array
    Local cCodBanco   	As Character
    Local cCodAgen   	As Character
    Local cNumCon       As Character
    Local aCxLoja		As Array

    Private lMsErroAuto As Logical

	lRet        := .F.
	aDadosSE2   := {}
    cMsgLog     := ""
    cParcela    := LJParcela(1, SuperGetMV("MV_1DUP"))
    cTipo       := LjTipoTit(MFV->MFV_FORPAG)
    cNatureza   := SuperGetMv("MV_LJNATSU",.F., "")
    cHistorico  := Upper(STR0040) + " " + MFV->MFV_COD //"Entrada de Sucata - Num:"
    nValor      := 0
    aTitBx      := {}
    
    lMsErroAuto := .F.

    If nOperacao == 3 .Or. nOperacao == 5 //3=Inclusão de título; 5=Deleção de título

        Aadd( aDadosSE2, { "E2_PREFIXO"   , MFV->MFV_SERIE  , NIL } )
        Aadd( aDadosSE2, { "E2_NUM"       , MFV->MFV_DOC    , NIL } )
        Aadd( aDadosSE2, { "E2_PARCELA"   , cParcela        , NIL } )
        Aadd( aDadosSE2, { "E2_TIPO"      , cTipo           , NIL } )
        Aadd( aDadosSE2, { "E2_FORNECE"   , MFV->MFV_FORNEC , NIL } )
        Aadd( aDadosSE2, { "E2_LOJA"      , MFV->MFV_LOJFOR , NIL } )

        cMsgLog := "Excluir"

        If nOperacao == 3 //3=Inclusão de título
            nValor := LjValorTit(MFV->MFV_COD)

            Aadd( aDadosSE2, { "E2_NATUREZ"   , cNatureza       , Nil } )
            Aadd( aDadosSE2, { "E2_EMISSAO"   , dDataBase       , Nil } )
            Aadd( aDadosSE2, { "E2_VENCTO"    , dDataBase       , Nil } )
            Aadd( aDadosSE2, { "E2_VALOR"     , nValor          , Nil } )
            Aadd( aDadosSE2, { "E2_HIST"      , cHistorico      , Nil } )
            Aadd( aDadosSE2, { "E2_FORBCO"    , MFV->MFV_BANCO  , Nil } )
            Aadd( aDadosSE2, { "E2_FORAGE"    , MFV->MFV_AGENC  , Nil } )
            Aadd( aDadosSE2, { "E2_FORCTA"    , MFV->MFV_CONTA  , Nil } )

            cMsgLog := "Incluir"
        EndIf

        //Chama a ExecAuto para Incluir ou Deletar o registro de Contas a Pagar (SE2)
        MsExecAuto({|x,y,Z| FINA050(x,y,Z)},aDadosSE2,,nOperacao)

        cMsgLog := cMsgLog + CRLF + "Prefixo: [" + MFV->MFV_SERIE + "] Número: [" + MFV->MFV_DOC + "] Parcela: [" + cParcela + "] Tipo: [" + cTipo + "] Fornecedor: [" + MFV->MFV_FORNEC + "] Loja: [" + MFV->MFV_LOJFOR + "]" + CRLF

        If lMsErroAuto
            lRet := .F.
            cMsgLog := "Problema na ExecAuto FINA050 (Contas a Pagar) - Operação: " + cMsgLog
            cMsgLog += MostraErro()
            DisarmTransaction()
        Else
            lRet := .T.
            cMsgLog := "Sucesso na ExecAuto FINA050 (Contas a Pagar) - Operação: " + cMsgLog
        EndIf

        LjGrvLog(MFV->MFV_COD, cMsgLog )

        If nOperacao == 3 .And. lRet
            //--------------------------------------------------
            //Realiza a baixa do título de Contas a Pagar (SE2)
            //--------------------------------------------------
            
            //Considera o Caixa/Agencia/Conta (CAIXA geral) da loja corrente para realizar a baixa do título de Contas a Pagar (SE2)
            aCxLoja		:= Separa(SuperGetMV("MV_CXLOJA",.F.,""),"/")
            If Len(aCxLoja) >= 3
                cCodBanco   	:= PADR(aCxLoja[1],TamSX3("A6_COD")[1]) //Codigo do banco
                cCodAgen   		:= PADR(aCxLoja[2],TamSX3("A6_AGENCIA")[1]) //Codigo do agencia
                cNumCon       	:= PADR(aCxLoja[3],TamSX3("A6_NUMCON")[1]) //Numero do conta
            EndIf

            cHistorico  := Upper("Pagto de Sucata - Num:") + " " + MFV->MFV_COD

            Aadd(aTitBx, {"E2_PREFIXO", SE2->E2_PREFIXO , NIL})
            Aadd(aTitBx, {"E2_NUM",     SE2->E2_NUM     , NIL})
            Aadd(aTitBx, {"E2_PARCELA", SE2->E2_PARCELA , NIL})
            Aadd(aTitBx, {"E2_TIPO",    SE2->E2_TIPO    , NIL})
            Aadd(aTitBx, {"E2_FORNECE", SE2->E2_FORNECE , NIL})
            Aadd(aTitBx, {"E2_LOJA",    SE2->E2_LOJA    , NIL})
            Aadd(aTitBx, {"AUTMOTBX",   "DEB"           , NIL})
            Aadd(aTitBx, {"AUTDTBAIXA", dDataBase       , NIL})
            Aadd(aTitBx, {"AUTHIST",    cHistorico      , NIL})
            Aadd(aTitBx, {"AUTBANCO",   cCodBanco		, Nil})
            Aadd(aTitBx, {"AUTAGENCIA", cCodAgen		, Nil})
            Aadd(aTitBx, {"AUTCONTA",   cNumCon		    , Nil})

            MsExecAuto({|x,y| FINA080(x,y)}, aTitBx, 3) // Baixa

            If lMsErroAuto
                lRet := .F.
                cMsgLog := "Problema na ExecAuto FINA080 (Baixa a Pagar) - Operação: " + cMsgLog
                cMsgLog += MostraErro()
                DisarmTransaction()
            Else
                lRet := .T.
                cMsgLog := "Sucesso na ExecAuto FINA080 (Baixa a Pagar) - Operação: " + cMsgLog
            EndIf

            LjGrvLog(MFV->MFV_COD, cMsgLog )

        EndIf
        
    EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130CtRb
Efetua a inclusao ou exclusão do título de Contas a Receber (SE1) de acordo com a 
forma de pagamento (MFV_FORPAG) escolhida na Entrada de Sucata.

@type    Static Function
@author  Alberto Deviciente
@since   28/08/2026
@version 12
@param   nOperacao, Numeric, Tipo de operação a ser realizada (3=Inclusão de título; 5=Exclusão de título)
@return  lRet, Logical, .T. se o titulo foi incluído ou excluido com sucesso.
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130CtRb(nOperacao)
	Local lRet          As Logical
	Local aDadosSE1     As Array
    Local cMsgLog       As Character
    Local cParcela      As Character
    Local cTipo         As Character
    Local cNatureza     As Character
    Local cHistorico    As Character
    Local nValor        As Numeric
    Local dDataVenc     As Date

    Private lMsErroAuto As Logical

	lRet        := .F.
	aDadosSE1   := {}
    cMsgLog     := ""
    cParcela    := LJParcela(1, SuperGetMV("MV_1DUP"))
    cTipo       := LjTipoTit(MFV->MFV_FORPAG)
    cNatureza   := SuperGetMv("MV_LJNATSU",.F., "")
    cHistorico  := Upper(STR0040) + " " + MFV->MFV_COD //"Entrada de Sucata - Num:"
    nValor      := 0
    dDataVenc   := dDataBase
    
    lMsErroAuto := .F.

    If nOperacao == 3 .Or. nOperacao == 5 //3=Inclusão de título; 5=Deleção de título

        Aadd( aDadosSE1, { "E1_PREFIXO"   , MFV->MFV_SERIE  , NIL } )
        Aadd( aDadosSE1, { "E1_NUM"       , MFV->MFV_DOC    , NIL } )
        Aadd( aDadosSE1, { "E1_PARCELA"   , cParcela        , NIL } )
        Aadd( aDadosSE1, { "E1_TIPO"      , cTipo           , NIL } )
        Aadd( aDadosSE1, { "E1_CLIENTE"   , MFV->MFV_CODCLI , NIL } )
        Aadd( aDadosSE1, { "E1_LOJA"      , MFV->MFV_LOJA   , NIL } )

        cMsgLog := "Excluir"

        If nOperacao == 3 //3=Inclusão de título
            nValor := LjValorTit(MFV->MFV_COD)

            Aadd( aDadosSE1, { "E1_NATUREZ"   , cNatureza   ,Nil } )
            Aadd( aDadosSE1, { "E1_EMISSAO"   , dDataBase   ,Nil } )
            If SuperGetMV("MV_LJVLNCC",,.F.)
                dDataVenc := (dDataVenc + SuperGetMV("MV_LJDTNCC",,0))
            EndIf
            Aadd( aDadosSE1, { "E1_VENCTO"    , dDataVenc   ,Nil } )
            Aadd( aDadosSE1, { "E1_VALOR"     , nValor      ,Nil } )
            Aadd( aDadosSE1, { "E1_HIST"      , cHistorico  ,Nil } )

            cMsgLog := "Incluir"
        EndIf

        //Chama a ExecAuto para Incluir ou Deletar o registro de Contas a Receber (SE1)
        MsExecAuto({|x,y,Z| FINA040(x,y)},aDadosSE1,nOperacao)

        cMsgLog := cMsgLog + CRLF + "Prefixo: [" + MFV->MFV_SERIE + "] Número: [" + MFV->MFV_DOC + "] Parcela: [" + cParcela + "] Tipo: [" + cTipo + "] Cliente: [" + MFV->MFV_CODCLI + "] Loja: [" + MFV->MFV_LOJA + "]" + CRLF

        If lMsErroAuto
            lRet := .F.
            cMsgLog := "Problema na ExecAuto FINA040 (Contas a Receber) - Operação: " + cMsgLog
            cMsgLog += MostraErro()
            DisarmTransaction()
        Else
            lRet := .T.
            cMsgLog := "Sucesso na ExecAuto FINA040 (Contas a Receber) - Operação: " + cMsgLog
        EndIf

        LjGrvLog(MFV->MFV_COD, cMsgLog )
        
    EndIf

Return lRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} LjTipoTit
Retorna o tipo de título a ser utilizado na geração do título de Contas a Pagar (SE2) 
ou Contas a Receber (SE1) a partir da forma de pagamento (MFV_FORPAG) escolhida no 
movimento de Entrada de Sucata.

@type    Static Function
@author  Alberto Deviciente
@since   28/08/2026
@version 12
@param   cFormPgto, Character, Forma de pagamento (MFV_FORPAG) escolhida no movimento de Entrada de Sucata
@return  cTipoTit, Character, Tipo de título a ser gerado no Contas a Pagar (SE2) ou Contas a Receber (SE1)
/*/
//-------------------------------------------------------------------------------
Static Function LjTipoTit(cFormPgto)
    Local cTipoTit As Character

    cTipoTit := ""

    Do Case

        Case cFormPgto == "1" //1=Dinheiro

            cTipoTit := "DH" //DH=Dinheiro

        Case cFormPgto == "2" //2=PIX

            cTipoTit := "PX" //PX=PIX

        Case cFormPgto == "3" //3=Depósito

            cTipoTit := "TF" //TF=Deposito

        Case cFormPgto == "4" //4=Crédito NCC

            cTipoTit := "NCC" //NCC=Crédito NCC

    EndCase

    cTipoTit := PadR(cTipoTit,TamSX3("E2_TIPO")[1])

Return cTipoTit

//-------------------------------------------------------------------------------
/*/{Protheus.doc} LjValorTit
Retorna o valor do título a ser gerado no Contas a Pagar (SE2) ou Contas a Receber (SE1) 
a partir da forma de pagamento (MFV_FORPAG) escolhida no movimento de Entrada de Sucata.

@type    Static Function
@author  Alberto Deviciente
@since   28/08/2026
@version 12
@param   cCodMov, Character, Código do movimento de Entrada de Sucata (MFV_COD)
@return  nVlrTitulo, Numeric, Valor do título a ser gerado
/*/
//-------------------------------------------------------------------------------
Static Function LjValorTit(cCodMov)
    Local aArea         As Array
    Local oQueryQry     As Object
    Local nSeq          As Numeric
    Local nVlrTitulo    As Numeric
    Local cQry          As Character

    aArea       := GetArea()
    oQueryQry   := Nil
    nSeq        := 1
    nVlrTitulo  := 0
    
    cQry := " SELECT SUM(MFX_VLTOT) AS VLRTOTAL "
    cQry += " FROM " + RetSqlName("MFX") + " MFX "
    cQry += " WHERE "
    cQry += " MFX.MFX_FILIAL = ? "
    cQry += " AND MFX.MFX_COD = ? "
    cQry += " AND MFX.D_E_L_E_T_ = ? "
    cQry := ChangeQuery(cQry)

    oQueryQry := FwExecStatement():New(cQry)

    oQueryQry:SetString(nSeq++, xFilial("MFX"))
    oQueryQry:SetString(nSeq++, cCodMov)
    oQueryQry:SetString(nSeq++, Space(1))

    nVlrTitulo := oQueryQry:ExecScalar('VLRTOTAL')

    RestArea(aArea)

    oQueryQry:Destroy()

Return nVlrTitulo

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130Imp
Imprime o comprovante de Entrada de Sucata.

@type    Function
@author  Alberto Deviciente
@since   30/08/2026
@version 12
@return  Nil, Nulo
/*/
//-------------------------------------------------------------------------------
Function Lj6130Imp()

    FwMsgRun( , { || Lj6130RImp() },STR0031,STR0034 ) //"Aguarde..." ### "Imprimindo comprovante..."

Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6130RImp
Executa a impressao o comprovante de Entrada de Sucata.

@type    Function
@author  Alberto Deviciente
@since   30/08/2026
@version 12
@return  Nil, Nulo
/*/
//-------------------------------------------------------------------------------
Static Function Lj6130RImp()
    Local aArea       As Array
    Local oPrint      As Object
    Local oFtTitulo   As Object
    Local oFtSubTit   As Object
    Local oFtTexto    As Object
    Local oFtBold     As Object
    Local nLi         As Numeric
    Local nPosColIte  As Numeric
    Local nColIni     As Numeric
    Local nColMax     As Numeric
    Local cCodMov     As Character
    Local cCliente    As Character
    Local cLoja       As Character
    Local cDescPag    As Character
    Local cDesSucStr  As Character
    Local cNomeCli    As Character
    Local cNomeFor    As Character
    Local nTotVal     As Numeric
    Local aPosColuna  As Array
    Local cFilMGA     As Character
    Local cFilMFX     As Character

    aArea       := GetArea()
    cCodMov     := MFV->MFV_COD
    cCliente    := MFV->MFV_CODCLI
    cLoja       := MFV->MFV_LOJA
    nTotVal     := 0
    nLi         := 150
    nPosColIte  := 0
    nColIni     := 150
    nColMax     := 2250
    cDescPag    := MFV->MFV_FORPAG + " - " + X3CboxDesc( "MFV_FORPAG", MFV->MFV_FORPAG )
    aPosColuna  := {}
    cFilMGA     := xFilial("MGA")
    cFilMFX     := xFilial("MFX")

    //Definição da Posicao de cada coluna dos itens
    aAdd( aPosColuna, nColIni ) //Item
    aAdd( aPosColuna, aPosColuna[Len(aPosColuna)]+090 ) //Qtd
    aAdd( aPosColuna, aPosColuna[Len(aPosColuna)]+100 ) //Tipo Sucata
    aAdd( aPosColuna, aPosColuna[Len(aPosColuna)]+200 ) //Descrição da Sucata
    aAdd( aPosColuna, aPosColuna[Len(aPosColuna)]+810 ) //Amperagem
    aAdd( aPosColuna, aPosColuna[Len(aPosColuna)]+300 ) //Peso
    aAdd( aPosColuna, aPosColuna[Len(aPosColuna)]+300 ) //Vlr. Unit.
    aAdd( aPosColuna, aPosColuna[Len(aPosColuna)]+180 ) //Vlr. Total

    oPrint := FWMSPrinter():New(STR0041 + cCodMov, IMP_PDF, .T., "", .T., .F.,, "LOJA6130") //"Comprovante_Sucata_"
    oPrint:SetPortrait()
    oPrint:StartPage()

    oFtTitulo := TFont():New("Arial",, 18,, .T.,,,,, .F.)
    oFtSubTit := TFont():New("Arial",, 14,, .T.,,,,, .F.)
    oFtTexto  := TFont():New("Arial",, 11,, .F.,,,,, .F.)
    oFtBold   := TFont():New("Arial",, 11,, .T.,,,,, .F.)

    // Cabeçalho da Empresa
    oPrint:Say(nLi, nColIni, SM0->M0_NOMECOM, oFtSubTit)
    oPrint:Say(nLi, 1700, STR0042 + DtoC(Date()) + " " + Time(), oFtTexto) //"Data de Impressão: "
    nLi += 35
    oPrint:Say(nLi, nColIni, STR0043 + Transform(SM0->M0_CGC, "@R! NN.NNN.NNN/NNNN-99"), oFtTexto) //"CNPJ: "
    nLi += 40
    oPrint:Box(nLi, nColIni, nLi, nColMax)

    // Título do Comprovante (Posicionamento vertical deslocado mais para baixo)
    nLi += 60
    oPrint:Say(nLi, 650, UPPER(STR0044), oFtTitulo) //"COMPROVANTE DE ENTRADA DE SUCATA"
    nLi += 35
    oPrint:Box(nLi, nColIni, nLi, nColMax)

    // Dados do Movimento e Cliente
    nLi += 45
    oPrint:Say(nLi, nColIni, STR0045 + cCodMov, oFtBold) //"Cód. Movimento: "
    oPrint:Say(nLi, 1300, STR0046 + DtoC(MFV->MFV_EMISS), oFtBold) //"Data de Entrada: "
    nLi += 35

    cNomeCli := AllTrim(GetAdvFVal("SA1", "A1_NOME", FwxFilial("SA1") + cCliente + cLoja, 1))
    cNomeFor := AllTrim(GetAdvFVal("SA2", "A2_NOME", FwxFilial("SA2") + MFV->MFV_FORNEC + MFV->MFV_LOJFOR, 1))

    oPrint:Say(nLi, nColIni, STR0047 + cCliente + "/" + cLoja + " - " + AllTrim(cNomeCli), oFtTexto) //"Cliente: "
    oPrint:Say(nLi, 1300, STR0048 + MFV->MFV_FORNEC + " / " + MFV->MFV_LOJFOR + " - "+ AllTrim(cNomeFor), oFtTexto) //"Fornecedor: "
    nLi += 35
    
    oPrint:Say(nLi, nColIni, STR0049 + MFV->MFV_DOC + " / " + MFV->MFV_SERIE, oFtTexto) //"Doc. Entrada / Série: "
    oPrint:Say(nLi, 1300, STR0050 +  MFV->MFV_DOC + " / " + MFV->MFV_SERIE, oFtTexto) //"Título: "
    nLi += 35

    oPrint:Say(nLi, nColIni, STR0051 + cDescPag, oFtTexto) //"Forma de Pagamento: "
    If MFV->MFV_FORPAG == "2" .And. !Empty(MFV->MFV_CHPIX)
        oPrint:Say(nLi, 800, STR0052 + AllTrim(MFV->MFV_CHPIX), oFtTexto) //"Chave PIX: "
    ElseIf MFV->MFV_FORPAG == "3" .And. !Empty(MFV->MFV_BANCO)
        oPrint:Say(nLi, 800, STR0053 + AllTrim(MFV->MFV_BANCO) + " " + STR0054 + AllTrim(MFV->MFV_AGENC) + " " + STR0055 + AllTrim(MFV->MFV_CONTA), oFtTexto) //"Banco: " ### "Agência: " ### "Conta: "
    EndIf
    nLi += 60
    oPrint:Box(nLi, nColIni, nLi, nColMax)

    // Grade de Itens
    nLi += 40
    oPrint:Say(nLi, 900, STR0056, oFtSubTit) //"ITENS DA ENTRADA DE SUCATA"
    nLi += 20
    oPrint:Box(nLi, nColIni, nLi, nColMax)
    nLi += 35
    oPrint:Say(nLi, aPosColuna[1], STR0057, oFtBold) //"Item"
    oPrint:Say(nLi, aPosColuna[2], STR0058, oFtBold) //"Qtd"
    oPrint:Say(nLi, aPosColuna[3], STR0059, oFtBold) //"Cód. Sucata"
    oPrint:Say(nLi, aPosColuna[4], STR0060, oFtBold) //"Descrição da Sucata"
    oPrint:Say(nLi, aPosColuna[5], STR0061, oFtBold) //"Amperagem"
    oPrint:Say(nLi, aPosColuna[6], STR0062, oFtBold) //"Peso"
    oPrint:Say(nLi, aPosColuna[7], STR0063, oFtBold) //"Vlr. Unit."
    oPrint:Say(nLi, aPosColuna[8], STR0064, oFtBold) //"Vlr. Total"
    nLi += 20
    oPrint:Box(nLi, nColIni, nLi, nColMax)
    nLi += 35

    DbSelectArea("MFX")
    MFX->(DbSetOrder(1)) // MFX_FILIAL + MFX_COD + MFX_ITEM
    If MFX->(DbSeek(cFilMFX + cCodMov))
        While !MFX->(Eof()) .And. MFX->MFX_FILIAL == cFilMFX .And. MFX->MFX_COD == cCodMov
            nPosColIte := nColIni

            cDesSucStr := AllTrim(GetAdvFVal("MGA", "MGA_DESCRI", cFilMGA + MFX->MFX_TIPSUC, 1))

            oPrint:Say(nLi, aPosColuna[1], MFX->MFX_ITEM, oFtTexto)
            oPrint:Say(nLi, aPosColuna[2], Transform(MFX->MFX_QTD, "@E 999,999"), oFtTexto)
            oPrint:Say(nLi, aPosColuna[3], MFX->MFX_TIPSUC, oFtTexto)
            oPrint:Say(nLi, aPosColuna[4], PadR(cDesSucStr,46), oFtTexto)
            oPrint:Say(nLi, aPosColuna[5], PadR(MFX->MFX_AMPER,17), oFtTexto)
            oPrint:Say(nLi, aPosColuna[6], PadR(MFX->MFX_PESO,17), oFtTexto)
            oPrint:Say(nLi, aPosColuna[7], Transform(MFX->MFX_VLUNIT, "@E 999,999.99"), oFtTexto)
            oPrint:Say(nLi, aPosColuna[8], Transform(MFX->MFX_VLTOT, "@E 999,999.99"), oFtTexto)

            nTotVal  += MFX->MFX_VLTOT
            nLi += 35
            MFX->(DbSkip())
        EndDo
    EndIf

    nLi += 15
    oPrint:Box(nLi, nColIni, nLi, nColMax)

    // Totais (Posicionamento vertical deslocado mais para baixo)
    nLi += 45
    oPrint:Say(nLi, aPosColuna[7], STR0064, oFtBold) //"Vlr. Total"
    oPrint:Say(nLi, aPosColuna[8], Transform(nTotVal, "@E 999,999.99"), oFtBold)
    nLi += 150
    oPrint:Box(nLi, nColIni, nLi, nColMax)
    nLi += 45

    // Termos de Responsabilidade e Assinaturas
    oPrint:Say(nLi, nColIni, STR0065, oFtTexto) //"Declaro ter entregue os materiais de sucata acima."
    oPrint:Say(nLi, nColIni+1300, STR0066, oFtTexto) //"Declaro ter recebido e conferido os materiais acima."
    nLi += 200

    oPrint:Say(nLi, nColIni, "_______________________________________________", oFtTexto)
    oPrint:Say(nLi, nColIni+1300, "_______________________________________________", oFtTexto)
    nLi += 35
    oPrint:Say(nLi, nColIni+200, STR0067, oFtBold) //"Assinatura do Cliente"
    oPrint:Say(nLi, nColIni+1500, STR0068, oFtBold) //"Assinatura do Atendente"

    oPrint:EndPage()
    oPrint:Preview()

    MsgInfo(STR0069, STR0044) //"Comprovante gerado com sucesso!" ### "COMPROVANTE DE ENTRADA DE SUCATA"

    RestArea(aArea)
Return Nil
