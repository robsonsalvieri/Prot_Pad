#Include "FISA171.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

// Proteção pois em binários 32 bits o objeto TSay não possui o método SetTextAlign.
STATIC oSayCheck  := IIf(!IsBlind(), TSay():New(), NIL)
STATIC cMethIsMemberOf := "MethIsMemberOf"
STATIC lMethAlign := IIf(!IsBlind(), &cMethIsMemberOf.(oSayCheck,"SetTextAlign"), .F.)

STATIC cQryInsert	:= ""
STATIC __nCountIns	:= 0

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA171WIZ()

Função responsável por montar a wizard do facilitador conforme a opção
passada por parâmetro.

Esta rotina estará disponível somente na versão 12.

@author joao.pellegrini
@since 02/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FSA171WIZ(cTpWiz,cTpPerfil, cTpPart)

Local oPanel          := NIL
Local oNewPag         := NIL
Local cNome           := ""
Local cFornec         := ""
Local cAcao           := ""
Local oStepWiz        := NIL
Local aCoords         := FWGetDialogSize()
Local oMarkPerfil     := NIL
Local oMarkUfOri      := NIL
Local oMarkUfDest     := NIL
Local oMarkCFOP       := NIL
Local oMarkTpOpe      := NIL
Local oMarkISS        := NIL
Local nSteps          := 0
Local oModel          := Iif(cTpWiz == '1', NIL, FWModelActive()() )
Local lProc           := .T.
Local cModelo         := "" 

DEFAULT cTpPerfil     := ""
DEFAULT cTpPart       := ""

PRIVATE oFont18       := TFont():New('Arial',,18,,.F.,,,,,.F.,.F.) // Fonte do texto
PRIVATE lAllPerfil    := .T.
PRIVATE lAllCFOP      := .T.
PRIVATE lAllISS       := .T.
PRIVATE lAllTPOP      := .T.
PRIVATE lAllPUFO      := .T.
PRIVATE lAllPUFD      := .T.
PRIVATE lAllOrigem    := .T.
PRIVATE lAllProd      := .T.
PRIVATE lAllCLi       := .T.
PRIVATE lAllFor       := .T.
PRIVATE lAliasCIO     := AliasInDic("CIO")
PRIVATE aCmpCli       := {}
PRIVATE aCmpFor       := {}
PRIVATE aCmpUFORI     := {}
PRIVATE aCmpUFDES     := {}
PRIVATE aColsUFORI    := {}
PRIVATE aColsUFDES    := {}
PRIVATE aColsCLi      := {}
PRIVATE aColsFor      := {}
PRIVATE oMarkProd     := NIL
PRIVATE oMarkOriPr    := NIL
PRIVATE oMarkCli      := NIL
PRIVATE oMarkFor      := NIL

// Browses dos Resumos
PRIVATE oPerfil       := NIL
PRIVATE aResumoPerfil := {}
PRIVATE oUFOri        := NIL
PRIVATE aResumoUfO    := {}
PRIVATE oUFDest       := NIL
PRIVATE aResumoUfD    := {}

PRIVATE oCFOP        := NIL
PRIVATE aResumoCFOP  := {}
PRIVATE oTpOper      := NIL
PRIVATE aResumoTPOP  := {}
PRIVATE oCodISS      := NIL
PRIVATE aResumoISS   := {}

PRIVATE oCliente      := NIL
PRIVATE aResumoCLi    := {}
PRIVATE oFornecedor   := NIL
PRIVATE aResumoFor    := {}
PRIVATE oProduto      := NIL
PRIVATE aResumoProd   := {}

PRIVATE oPgFiltro     := NIL

IF cTpWiz == '2' 
    If !(oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
        Alert(STR0001) //"Operação permitida somente na inclusão ou edição!"
        lProc   := .F.
    EndIf
   
    cModelo := oModel:GetID()

    If lProc .And. (Empty(oModel:GetValue(cModelo,"F20_CODIGO")) .Or. Empty(oModel:GetValue(cModelo,"F20_DESC")))
        Alert("Para utilização do facilitador, os campos de código e descrição do perfil devem estar preenchidos!") //"Para utilização do facilitador, os campos de código e descrição do perfil devem estar preenchidos!"
        lProc   := .F.
    EndIf
EndIF

IF lProc
    oStepWiz:= FWWizardControl():New(,{aCoords[3] * 0.8, aCoords[4] * 0.8})
    oStepWiz:ActiveUISteps()

    //----------------------
    // Pagina 1 - Início
    //----------------------
    nSteps +=1

    oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
    //Altera a descrição do step
    oNewPag:SetStepDescription(STR0002) //"Início"
    //Define o bloco de construção
    oNewPag:SetConstruction({|Panel|FSA171PNIN(Panel, cTpPerfil, @cAcao)})

    //------------------------------
    // Pagina 2 - Seleção de Perfis
    //-----------------------------
    If cTpWiz == '1' //Wizard chamada através do menu principal FISA170 - "por fora"
        nSteps +=1
        oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
        //Altera a descrição do step
        oNewPag:SetStepDescription(STR0003) //"Perfis"
        //Define o bloco de construção
        oNewPag:SetConstruction({|Panel|MarkPerfil(Panel, cTpPerfil, @lAllPerfil, @oMarkPerfil)})
        //Define o bloco ao clicar no botão Próximo
        oNewPag:SetNextAction({||VLDMARK(oMarkPerfil,STR0004)}) //"Deverá ser selecionado ao menos um perfil para prosseguir"
    EndIF

    //------------------------------------------
    //Seleção do filtro a ser exibido na Wizard
    //------------------------------------------

    IF cTpPerfil == "01"

        //-----------------------------------------
        //Filtros do Perfil de Uf Origem e Destino
        //-----------------------------------------
        nSteps +=1
        oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
        //Altera a descrição do step
        oNewPag:SetStepDescription(STR0005) //"Filtros"
        //Define o bloco de construção
        oNewPag:SetConstruction({|Panel|FSA171PUF(Panel,@oMarkUfOri,@oMarkUfDest)})
        //Define o bloco ao clicar no botão Próximo
        oNewPag:SetNextAction({||VLDMARK(oMarkUfOri,STR0006) .AND. VLDMARK(oMarkUfDest,STR0007) .AND. AtuResumoUF(oMarkPerfil,oMarkUfOri,oMarkUfDest,cTpWiz)}) //"Deverá ser selecionado ao menos uma UF de Origem para prosseguir" //"Deverá ser selecionado ao menos uma UF de Destino para prosseguir"

        //Próximo passo - Resumo e confirmação

        nSteps +=1
        oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
        //Altera a descrição do step
        oNewPag:SetStepDescription(STR0008) //"Confirmação"
        //Define o bloco de construção
        oNewPag:SetConstruction({|Panel|ResumoUF(Panel,oMarkPerfil,oMarkUfOri,oMarkUfDest,cAcao, cTpWiz)})
        //Define o bloco ao clicar no botão Próximo
        oNewPag:SetNextAction({||FwMsgRun(,{|oSay| GravarUF( cAcao, oSay, cTpWiz, oModel ) },STR0009,"") .OR. .T. }) //"Processando Informações..."

    ElseIF cTpPerfil == "02"

        IF cTpPart == 'CLI'

            //-------
            //CLIENTE
            //-------
            nSteps +=1
            oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
            //Altera a descrição do step
            oNewPag:SetStepDescription(STR0005) //"Filtros"
            //Define o bloco de construção
            oNewPag:SetConstruction({|Panel|FSA171CLI(Panel)})
            //Define o bloco ao clicar no botão Próximo
            oNewPag:SetNextAction({||AtuQryBro(oPgFiltro:GetPanel(), cAcao, oMarkCli, "CLIENTE",oMarkPerfil) .AND. .T. })

            nSteps +=1
            oPgFiltro := oStepWiz:AddStep(cValToChar(nSteps))
            //Altera a descrição do step
            oPgFiltro:SetStepDescription(STR0010) //"Seleção"
            //Define o bloco de construção
            oPgFiltro:SetConstruction({|Panel|SelCliente(Panel, cAcao, oMarkPerfil)})
            //Define o bloco ao clicar no botão Próximo
            oPgFiltro:SetNextAction({|| VLDMARK(oMarkCli,STR0011) .AND. AtuResumoCli(oMarkPerfil, cTpWiz) }) //"Deverá ser selecionado ao menos um cliente para prosseguir"

            nSteps +=1
            oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
            //Altera a descrição do step
            oNewPag:SetStepDescription(STR0008) //"Confirmação"
            //Define o bloco de construção
            oNewPag:SetConstruction({|Panel|ResumoCli(Panel,oMarkPerfil,cAcao, cTpWiz)})
            //Define o bloco ao clicar no botão Próximo
            oNewPag:SetNextAction({||FwMsgRun(,{|oSay| GravarCli(cAcao, oSay, cTpWiz, oModel) },STR0009,"") .OR. .T. }) //"Processando Informações..."

        ElseIF cTpPart == 'FOR'

            //-------
            //FORNECEDOR
            //-------
            nSteps +=1
            oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
            //Altera a descrição do step
            oNewPag:SetStepDescription(STR0005) //"Filtros"
            //Define o bloco de construção
            oNewPag:SetConstruction({|Panel|FSA171FOR(Panel)})
            //Define o bloco ao clicar no botão Próximo
            oNewPag:SetNextAction({||AtuQryBro(oPgFiltro:GetPanel(), cAcao, oMarkFor, "FORNECEDOR",oMarkPerfil) .AND. .T. })

            nSteps +=1
            oPgFiltro := oStepWiz:AddStep(cValToChar(nSteps))
            //Altera a descrição do step
            oPgFiltro:SetStepDescription(STR0010) //"Seleção"
            //Define o bloco de construção
            oPgFiltro:SetConstruction({|Panel|SelFornecedor(Panel, cAcao, oMarkPerfil)})
            //Define o bloco ao clicar no botão Próximo
            oPgFiltro:SetNextAction({|| VLDMARK(oMarkFor,STR0012) .AND. AtuResumoFor(oMarkPerfil, cTpWiz) }) //"Deverá ser selecionado ao menos um Fornecedor para prosseguir"

            nSteps +=1
            oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
            //Altera a descrição do step
            oNewPag:SetStepDescription(STR0008) //"Confirmação"
            //Define o bloco de construção
            oNewPag:SetConstruction({|Panel|ResumoFor(Panel,oMarkPerfil,cAcao, cTpWiz)})
            //Define o bloco ao clicar no botão Próximo
            oNewPag:SetNextAction({||FwMsgRun(,{|oSay| GravarFor(cAcao, oSay, cTpWiz, oModel) },STR0009,"") .OR. .T. }) //"Processando Informações..."

        EndIF

    ElseIF cTpPerfil == "03"
        
        //----------------------------------------------------------------------------------
        //Filtros do Perfil de Operação, considerando CFOP e Tipo de Operação
        //----------------------------------------------------------------------------------        
        
        nSteps +=1
        oNewPag := oStepWiz:AddStep(cValToChar(nSteps)) 
        //Altera a descrição do step
        oNewPag:SetStepDescription(STR0005) //"Filtros"
        //Define o bloco de construção
        oNewPag:SetConstruction({|Panel|FSA171POPE(Panel,@oMarkCFOP,@oMarkTpOpe)})

        //ISS
        If lAliasCIO
            nSteps +=1
            oNewPag := oStepWiz:AddStep(cValToChar(nSteps)) 
            //Altera a descrição do step
            oNewPag:SetStepDescription(STR0005) //"Filtros"
            //Define o bloco de construção
            oNewPag:SetConstruction({|Panel|FSA171OISS(Panel,@oMarkISS)})
        EndIf
        
        //Define o bloco ao clicar no botão Próximo
        oNewPag:SetNextAction({||VldPerOper(oMarkCFOP,oMarkTpOpe,IIF(lAliasCIO,STR0070,STR0013),oMarkISS) .AND. AtuResOper(oMarkPerfil,oMarkCFOP,oMarkTpOpe,cTpWiz,oMarkISS)}) //"Deverá ser selecionado ao menos um CFOP, um Tipo de Operação ou um código de ISS"--"Deverá ser selecionado ao menos um CFOP ou um Tipo de Operação"

        //Próximo passo - Resumo e confirmação

        nSteps +=1
        oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
        //Altera a descrição do step
        oNewPag:SetStepDescription(STR0008) //"Confirmação"
        //Define o bloco de construção
        oNewPag:SetConstruction({|Panel|RESUMOOPER(Panel,oMarkPerfil,oMarkCFOP,oMarkTpOpe,cAcao, cTpWiz, oMarkISS)})
        //Define o bloco ao clicar no botão Próximo
        oNewPag:SetNextAction({||FwMsgRun(,{|oSay| GravaPerOp( cAcao, oSay, cTpWiz, oModel ) },STR0009,"") .OR. .T. }) //"Processando Informações..."

    ElseIF cTpPerfil == "04"

        // Filtros do Perfil de Produto

        nSteps +=1
        oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
        //Altera a descrição do step
        oNewPag:SetStepDescription(STR0005) //"Filtros"
        //Define o bloco de construção
        oNewPag:SetConstruction({|Panel|FSA171PRD(Panel)})
        //Define o bloco ao clicar no botão Próximo
        oNewPag:SetNextAction({||AtuQryBro(oPgFiltro:GetPanel(), cAcao, oMarkProd, "PRODUTO",oMarkPerfil) .AND. .T. })

        // Seleção dos registros após a aplicação do filtro

        nSteps +=1
        oPgFiltro := oStepWiz:AddStep(cValToChar(nSteps))
        //Altera a descrição do step
        oPgFiltro:SetStepDescription(STR0014) //"Seleção dos Produtos"
        //Define o bloco de construção
        oPgFiltro:SetConstruction({|Panel|SelProduto(Panel, cAcao)})
        //Define o bloco ao clicar no botão Próximo
        oPgFiltro:SetNextAction({|| VLDMARK(oMarkProd,STR0015) .AND. AtuResumoPR(oMarkPerfil, cTpWiz) }) //"Deverá ser selecionado ao menos um produto para prosseguir!"

        // Resumo e confirmação

        nSteps +=1
        oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
        //Altera a descrição do step
        oNewPag:SetStepDescription(STR0008) //"Confirmação"
        //Define o bloco de construção
        oNewPag:SetConstruction({|Panel|ResumoProd(Panel, oMarkPerfil, cAcao, cTpWiz)})
        //Define o bloco ao clicar no botão Próximo
        oNewPag:SetNextAction({||FwMsgRun(,{|oSay| GravarProd(cAcao, oSay, cTpWiz, oModel) },STR0009,"") .OR. .T. }) //"Processando Informações..."

    EndIF

    oStepWiz:Activate()
    oStepWiz:Destroy()

EndIF

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA171PNINT()

Função responsável por montar o painel com os filtros do facilitador
de produtos.

Esta rotina estará disponível somente na versão 12.

@author joao.pellegrini
@since 02/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function FSA171PNIN(oPanel, cTpPerfil, cAcao)

Local cTexto    := ""
Local aCoords   := FWGetDialogSize(oPanel)
Local aItems    := {}
Local oPanel1   := NIL
Local oPanel2   := NIL
Local oLayer    := NIL
Local oCombo1   := NIL
Local oSayIntro := NIL
Local oSayOpc   := NIL

cTexto += "<table width='100%' border=0 cellpadding='15' cellspacing='5' align:'justify'>"
cTexto += "<tr>"
cTexto += "<td colspan='5'>"

cTexto += "<p> Bem vindo ao facilitador de perfis de " + DescPerfil(cTpPerfil,"01") + "<br><br>"
cTexto += "Esta rotina irá auxiliá-lo na manutenção dos perfis. Seu objetivo é adicionar ou remover registros do perfil em questão." + "<br><br>"
cTexto += "Nos próximos passos serão disponibilizados filtros para seleção dos registros que deverão ser vinculados ou removidos do(s) perfil(is). </p>"

cTexto += "</td>"
cTexto += "</tr>"
cTexto += "</table>"

oLayer := FWLayer():New()
oLayer:Init(oPanel, .F.)
oLayer:AddLine('LIN1', 60, .F.)

oLayer:AddLine('LIN2', 40, .F.)

oPanel1  := oLayer:getLinePanel('LIN1')
oPanel2  := oLayer:getLinePanel('LIN2')

//Para os demais perfis o usuário terá duas opções
aItems    := {'1=Adicionar ' + DescPerfil(cTpPerfil,'02'),'2=Remover ' + DescPerfil(cTpPerfil,'02')}

oSayIntro := TSay():New(5,5,{||cTexto},oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10,,,,,,.T.)
If lMethAlign
    oSayIntro:SetTextAlign(3, 2)
EndIf

oSayOpc := TSay():New(10,10,{||STR0016},oPanel2,,oFont18,,,,.T.,,,(oPanel2:nWidth / 2) - 10,(oPanel2:nHeight / 2) - 10,,,,,,.T.) //"Selecione a ação deste facilitador:"
cAcao:= aItems[1]

oCombo1 := TComboBox():New(20,10,{|u|if(PCount()>0,cAcao:=u,cAcao)},aItems,160,30,oPanel2,,{|| },,,,.T.,oFont18,,,,,,,,'cAcao')

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA171PRD()

Função responsável por montar o painel com os filtros do facilitador
de produtos.

Esta rotina estará disponível somente na versão 12.

@author joao.pellegrini
@since 02/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function FSA171PRD(oPanel)

Local oSayOrigem := NIL
Local oSayTitulo := NIL
Local aCampos    := {}
Local aColumns   := {}
Local cQuery     := ""
Local cAliasOrig := GetNextAlias()

Local oLayer   := NIL
Local oPanel0  := NIL
Local oPanel1  := NIL
Local oPanel2  := NIL

Local aFields := {}
Local aEstrut := {}

PRIVATE oGetsProd := NIL

oLayer := FWLayer():New()
oLayer:Init(oPanel,.F.)
oLayer:AddLine('LIN0', 10, .F.)
oLayer:AddLine('LIN1', 45, .F.)
oLayer:addCollumn('LIN1_COL1',100,.F.,'LIN1')
oLayer:AddLine('LIN2', 45, .F.)
oLayer:addCollumn('LIN2_COL1',100,.F.,'LIN2')
oLayer:AddWindow('LIN2_COL1','W1',STR0017,100,.F.,.F.,,'LIN2') //"Origens dos Produtos"

oPanel0 := oLayer:getLinePanel('LIN0')
oPanel1 := oLayer:getColPanel('LIN1_COL1', 'LIN1')
oPanel2 := oLayer:getWinPanel('LIN2_COL1', 'W1', 'LIN2')

// Título da página
oSayTitulo := TSay():New(5,5,{||STR0018},oPanel0,,oFont18,,,,.T.,,,(oPanel0:nWidth / 2) - 10,(oPanel0:nHeight / 2) - 10) //"Utilize os filtros abaixo para selecionar os produtos que serão adicionados ou removidos do(s) perfil(is) selecionado(s)"
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

// Montagem da MsMGet
aEstrut := MontaEstrut('SB1')
aEval(aEstrut, {|x| aAdd(aFields, x[2])})
oGetsProd := MsmGet():New(,,3,,,,aFields,{0,3,(oPanel1:nClientHeight-4)/2,(oPanel1:nClientWidth/2)-5},,,,,,oPanel1,,,.T.,,,.T.,aEstrut,,,,,.T.)

// Seleção das origens
oSayOrigem := TSay():New(0,0,{|| STR0019},oPanel2,,oFont18,,,,.T.,,,15,0,,,,,,.T.) //"Selecione a(s) origem(ns) a serem consideradas no filtro:"

//Chama função para montar query e array com os campos do Header
cQuery := FSA171QRY("SX5", {'S0'}, @aCampos)

//Chama função para montar as colunas do aHeader
aColumns  := HeaderMark(aCampos)

//Chama função para montar o browse para origem
oMarkOriPr := AddMarkBro(oPanel2, @lAllOrigem, aCampos, aColumns, cQuery, cAliasOrig)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaEstrut()

Função responsável por retornar a estrutura dos campos utilizados nas
MGMGET's dos filtros.

Esta rotina estará disponível somente na versão 12.

@author joao.pellegrini
@since 14/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MontaEstrut(cTpEstrut)

Local aRet := {}
Local nPos := 0
Local cXBF0G := alltrim(posicione("SXB", 1, "F0G1", "XB_ALIAS")) 

Do Case

    Case cTpEstrut == "SB1"

        // Codigo De:

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Código De"
        aRet[nPos][02] := 'cCodPrDe'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_COD")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_COD")
        aRet[nPos][07] := {||VldGet("B1_COD", cCodPrDe, @cDescPrDe)}
        aRet[nPos][11] := "SB1"
         _SetNamedPrvt( "cCodPrDe" , CriaVar('B1_COD'), 'FSA171WIZ')

        // Descrição De

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDescPrDe'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_DESC")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_DESC")
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt( "cDescPrDe" , CriaVar('B1_COD'), 'FSA171WIZ')

         // Codigo Ate:

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Código Até"
        aRet[nPos][02] := 'cCodPrAte'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_COD")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_COD")
        aRet[nPos][07] := {||VldGet("B1_COD", cCodPrAte, @cDescPrAte)}
        aRet[nPos][11] := "SB1"
        _SetNamedPrvt( "cCodPrAte" , CriaVar('B1_COD'), 'FSA171WIZ')

        // Descrição Ate

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDescPrAte'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_DESC")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_DESC")
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt( "cDescPrAte" , CriaVar('B1_COD'), 'FSA171WIZ')

        // NCM De:

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "NCM De"
        aRet[nPos][02] := 'cNcmDe'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_POSIPI")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_POSIPI")
        aRet[nPos][07] := {||VldGet("B1_POSIPI", cNcmDe, @cDescNCMDe)}
        aRet[nPos][11] := "SYD"
         _SetNamedPrvt( "cNcmDe" , CriaVar('B1_POSIPI'), 'FSA171WIZ')

         // Descricao NCM De

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDescNCMDe'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("YD_DESC_P")[1]
        aRet[nPos][06] := PesqPict("SYD", "YD_DESC_P")
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt( "cDescNCMDe" , CriaVar('YD_DESC_P'), 'FSA171WIZ')

         // NCM Ate:

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "NCM Até"
        aRet[nPos][02] := 'cNcmAte'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_POSIPI")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_POSIPI")
        aRet[nPos][07] := {||VldGet("B1_POSIPI", cNcmAte, @cDescNCMAte)}
        aRet[nPos][11] := "SYD"
         _SetNamedPrvt( "cNcmAte" , CriaVar('B1_POSIPI'), 'FSA171WIZ')

         // Descricao NCM Ate

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDescNCMAte'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("YD_DESC_P")[1]
        aRet[nPos][06] := PesqPict("SYD", "YD_DESC_P")
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt( "cDescNCMAte" , CriaVar('YD_DESC_P'), 'FSA171WIZ')

         // Tipo de Produto

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Tipo de Produto"
        aRet[nPos][02] := 'cTpProd'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_TIPO")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_TIPO")
        aRet[nPos][07] := {||VldGet("B1_TIPO", cTpProd, @cDescTpPrd)}
        aRet[nPos][11] := "02"
        _SetNamedPrvt( "cTpProd" , CriaVar('B1_TIPO'), 'FSA171WIZ')

        // Descrição - Tipo de Produto

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDescTpPrd'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := 60
        aRet[nPos][06] := "@!"
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt("cDescTpPrd", Space(60), 'FSA171WIZ')

         // Grupo de Tributação

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Grupo de Tributação"
        aRet[nPos][02] := 'cGrTrib'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_GRTRIB")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_GRTRIB")
        aRet[nPos][07] := {||VldGet("B1_GRTRIB", cGrTrib, @cDescGrpTr)}
        aRet[nPos][11] := "21"
        _SetNamedPrvt("cGrTrib", CriaVar('B1_GRTRIB'), 'FSA171WIZ')

        nPos := AddStruct(@aRet)

        //Descrição - Grupo de Tributação

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDescGrpTr'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := 60
        aRet[nPos][06] := '@!'
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt("cDescGrpTr", Space(60), 'FSA171WIZ')

        //CEST De:

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "CEST De"
        aRet[nPos][02] := 'cCestDe'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_CEST")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_CEST")
        If cXBF0G $ "F0G1"
            aRet[nPos][07] := {||VldGet("B1_CEST", cCestDe, @cDescCSTDe)}
            aRet[nPos][11] := "F0G1"
        Else
            aRet[nPos][11] := "F0G"
        EndIf
        _SetNamedPrvt( "cCestDe" , CriaVar('B1_CEST'), 'FSA171WIZ')

        If cXBF0G $ "F0G1"
            // Descricao CEST De

            nPos := AddStruct(@aRet)

            aRet[nPos][01] := "Descrição"
            aRet[nPos][02] := 'cDescCSTDe'
            aRet[nPos][03] := 'C'
            aRet[nPos][04] := TamSx3("F0G_DESCRI")[1]
            aRet[nPos][06] := PesqPict("F0G", "F0G_DESCRI")
            aRet[nPos][12] := {||.F.}
            _SetNamedPrvt( "cDescCSTDe" , CriaVar('F0G_DESCRI'), 'FSA171WIZ')
        EndIf

        // CEST Ate:

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "CEST Até"
        aRet[nPos][02] := 'cCestAte'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_CEST")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_CEST")
        If cXBF0G $ "F0G1"
            aRet[nPos][07] := {||VldGet("B1_CEST", cCestAte, @cDescCSTAt)}
            aRet[nPos][11] := "F0G1"
        Else
            aRet[nPos][11] := "F0G"
        EndIf
        _SetNamedPrvt( "cCestAte" , CriaVar('B1_CEST'), 'FSA171WIZ')

        If cXBF0G $ "F0G1"
        
            // Descricao CEST Ate

            nPos := AddStruct(@aRet)

            aRet[nPos][01] := "Descrição"
            aRet[nPos][02] := 'cDescCSTAt'
            aRet[nPos][03] := 'C'
            aRet[nPos][04] := TamSx3("F0G_DESCRI")[1]
            aRet[nPos][06] := PesqPict("F0G", "F0G_DESCRI")
            aRet[nPos][12] := {||.F.}
            _SetNamedPrvt( "cDescCSTAt" , CriaVar('F0G_DESCRI'), 'FSA171WIZ')
        EndIf

        //GRUPO B1_GRUPO
        //Grupo De:
        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "GRUPO De"
        aRet[nPos][02] := 'cGrpDe'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_GRUPO")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_GRUPO")
        aRet[nPos][07] := {||VldGet("B1_GRUPO", cCestDe, @cDescGrpDe)}
        aRet[nPos][11] := "SBM"
        
        _SetNamedPrvt( "cGrpDe" , CriaVar('B1_GRUPO'), 'FSA171WIZ')
        
        // Descricao Grupo De
        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDescGrpDe'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("BM_DESC")[1]
        aRet[nPos][06] := PesqPict("SBM", "BM_DESC")
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt( "cDescGrpDe" , CriaVar('BM_DESC'), 'FSA171WIZ')
        
        //Grupo Ate
        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "GRUPO Até"
        aRet[nPos][02] := 'cGrpAt'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("B1_GRUPO")[1]
        aRet[nPos][06] := PesqPict("SB1", "B1_GRUPO")
        aRet[nPos][07] := {||VldGet("B1_GRUPO", cCestDe, @cDescGrpAt)}
        aRet[nPos][11] := "SBM"
        
        _SetNamedPrvt( "cGrpAt" , CriaVar('B1_GRUPO'), 'FSA171WIZ')

        
        // Descricao Grupo Ate
        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDescGrpAt'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("BM_DESC")[1]
        aRet[nPos][06] := PesqPict("SBM", "BM_DESC")
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt( "cDescGrpAt" , CriaVar('BM_DESC'), 'FSA171WIZ')
        

    Case cTpEstrut == "SA1"

         // Pessoa Física / Jurídica:

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Pessoa Física/Jurídica"
        aRet[nPos][02] := 'cA1Pessoa'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A1_PESSOA")[1]
        aRet[nPos][06] := PesqPict("SA1", "A1_PESSOA")
        aRet[nPos][15] := Posicione("SX3", 2, "A1_PESSOA", "X3CBox()" )
        _SetNamedPrvt( "cA1Pessoa" , CriaVar('A1_PESSOA'), 'FSA171WIZ')

        // Tipo:

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Tipo de Cliente"
        aRet[nPos][02] := 'cA1Tipo'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A1_TIPO")[1]
        aRet[nPos][06] := PesqPict("SA1", "A1_TIPO")
        aRet[nPos][15] := Posicione("SX3", 2, "A1_TIPO", "X3CBox()" )
        _SetNamedPrvt( "cA1Tipo" , CriaVar('A1_TIPO'), 'FSA171WIZ')

        // Tipo Pessoa:

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Tipo de Pessoa"
        aRet[nPos][02] := 'cA1TPessoa'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A1_TPESSOA")[1]
        aRet[nPos][06] := PesqPict("SA1", "A1_TPESSOA")
        aRet[nPos][15] := Posicione("SX3", 2, "A1_TPESSOA", "X3CBox()")
        _SetNamedPrvt( "cA1TPessoa" , CriaVar('A1_TPESSOA'), 'FSA171WIZ')

        // Optante pelo simples nacional

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Optante Pelo SIMPLES Nacional"
        aRet[nPos][02] := 'cA1SimpNac'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A1_SIMPNAC")[1]
        aRet[nPos][06] := PesqPict("SA1", "A1_SIMPNAC")
        aRet[nPos][15] := Posicione("SX3", 2, "A1_SIMPNAC", "X3CBox()" )
        _SetNamedPrvt( "cA1SimpNac" , CriaVar('A1_SIMPNAC'), 'FSA171WIZ')

         // Contribuinte

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Contribuinte"
        aRet[nPos][02] := 'cA1Contrib'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A1_CONTRIB")[1]
        aRet[nPos][06] := PesqPict("SA1", "A1_CONTRIB")
        aRet[nPos][15] := Posicione("SX3", 2, "A1_CONTRIB", "X3CBox()")
        _SetNamedPrvt( "cA1Contrib" , CriaVar('A1_CONTRIB'), 'FSA171WIZ')

        // Grupo de Tributação

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Grupo de Tributação"
        aRet[nPos][02] := 'cA1GrpTrib'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A1_GRPTRIB")[1]
        aRet[nPos][06] := PesqPict("SA1", "A1_GRPTRIB")
        _SetNamedPrvt( "cA1GrpTrib" , CriaVar('A1_GRPTRIB'), 'FSA171WIZ')

        // Estado

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Estado"
        aRet[nPos][02] := 'cA1Estado'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A1_EST")[1]
        aRet[nPos][06] := PesqPict("SA1", "A1_EST")
        aRet[nPos][07] := {||VldGet("A1_EST", cA1Estado, @cDesA1Est)}
        aRet[nPos][11] := "12"
        _SetNamedPrvt( "cA1Estado" , CriaVar('A1_EST'), 'FSA171WIZ')

         // Descrição - Estado

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDesA1Est'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := 60
        aRet[nPos][06] := '@!'
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt("cDesA1Est", Space(60), 'FSA171WIZ')

        // Código de Município

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Código Município"
        aRet[nPos][02] := 'cA1Mun'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A1_COD_MUN")[1]
        aRet[nPos][06] := PesqPict("SA1", "A1_COD_MUN")
        aRet[nPos][07] := {||VldGet("A1_COD_MUN", cA1Mun, @cDesA1Mun, cA1Estado)}
        aRet[nPos][11] := "CC2CIY"
        _SetNamedPrvt( "cA1Mun" , CriaVar('A1_COD_MUN'), 'FSA171WIZ')

         // Descrição - Município

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDesA1Mun'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := 60
        aRet[nPos][06] := '@!'
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt("cDesA1Mun", Space(60), 'FSA171WIZ')

        // Grupo de Vendas

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Grupo de Vendas"
        aRet[nPos][02] := 'cA1GrpVen'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A1_GRPVEN")[1]
        aRet[nPos][06] := PesqPict("SA1", "A1_GRPVEN")
        aRet[nPos][07] := {||VldGet("A1_GRPVEN", cA1GrpVen, @cDesA1GVen)}
        aRet[nPos][11] := "ACY"
        _SetNamedPrvt( "cA1GrpVen" , CriaVar('A1_GRPVEN'), 'FSA171WIZ')

         // Descrição - Estado

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDesA1GVen'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := 60
        aRet[nPos][06] := '@!'
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt("cDesA1GVen", Space(60), 'FSA171WIZ')

    Case cTpEstrut == "SA2"

         // Tipo de Pessoa:

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Tipo de Pessoa"
        aRet[nPos][02] := 'cA2Tipo'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A2_TIPO")[1]
        aRet[nPos][06] := PesqPict("SA2", "A2_TIPO")
        aRet[nPos][15] := Posicione("SX3", 2, "A2_TIPO", "X3CBox()")
        _SetNamedPrvt( "cA2Tipo" , CriaVar('A2_TIPO'), 'FSA171WIZ')

         // Grupo de Tributação

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Grupo de Tributação"
        aRet[nPos][02] := 'cA2GrpTrib'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A2_GRPTRIB")[1]
        aRet[nPos][06] := PesqPict("SA2", "A2_GRPTRIB")
        _SetNamedPrvt( "cA2GrpTrib" , CriaVar('A2_GRPTRIB'), 'FSA171WIZ')

         // Contribuinte

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Contribuinte"
        aRet[nPos][02] := 'cA2Contrib'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A2_CONTRIB")[1]
        aRet[nPos][06] := PesqPict("SA2", "A2_CONTRIB")
        aRet[nPos][15] := Posicione("SX3", 2, "A2_CONTRIB", "X3CBox()" )
        _SetNamedPrvt( "cA2Contrib" , CriaVar('A2_CONTRIB'), 'FSA171WIZ')

        // Optante pelo simples nacional

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Optante Pelo SIMPLES Nacional"
        aRet[nPos][02] := 'cA2SimpNac'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A2_SIMPNAC")[1]
        aRet[nPos][06] := PesqPict("SA2", "A2_SIMPNAC")
        aRet[nPos][15] := Posicione("SX3", 2, "A2_SIMPNAC", "X3CBox()" )
        _SetNamedPrvt( "cA2SimpNac" , CriaVar('A2_SIMPNAC'), 'FSA171WIZ')

        // Estado

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Estado"
        aRet[nPos][02] := 'cA2Estado'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A2_EST")[1]
        aRet[nPos][06] := PesqPict("SA2", "A2_EST")
        aRet[nPos][07] := {||VldGet("A2_EST", cA2Estado, @cDesA2Est)}
        aRet[nPos][11] := "12"
        _SetNamedPrvt( "cA2Estado" , CriaVar('A2_EST'), 'FSA171WIZ')

         // Descrição - Estado

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDesA2Est'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := 60
        aRet[nPos][06] := '@!'
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt("cDesA2Est", Space(60), 'FSA171WIZ')

        // Código de Município

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Código Município"
        aRet[nPos][02] := 'cA2Mun'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := TamSx3("A2_COD_MUN")[1]
        aRet[nPos][06] := PesqPict("SA2", "A2_COD_MUN")
        aRet[nPos][07] := {||VldGet("A2_COD_MUN", cA2Mun, @cDesA2Mun, cA2Estado)}
        aRet[nPos][11] := "CC2CIY"
        _SetNamedPrvt( "cA2Mun" , CriaVar('A2_COD_MUN'), 'FSA171WIZ')

         // Descrição - Município

        nPos := AddStruct(@aRet)

        aRet[nPos][01] := "Descrição"
        aRet[nPos][02] := 'cDesA2Mun'
        aRet[nPos][03] := 'C'
        aRet[nPos][04] := 60
        aRet[nPos][06] := '@!'
        aRet[nPos][12] := {||.F.}
        _SetNamedPrvt("cDesA2Mun", Space(60), 'FSA171WIZ')

EndCase

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AddStruct()

Função responsável por adicionar um item de estrutura com os valores
DEFAULT. Este item será utilizado pela função MontaEstrut para composição
das MGMGET's utilizadas nos steps de filtro.

Esta rotina estará disponível somente na versão 12.

@author joao.pellegrini
@since 14/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AddStruct(aEstruct)

Local nPosicao   := 0

DEFAULT aEstruct := {}

Aadd(aEstruct,{})
nPosicao := Len(aEstruct)

Aadd(aEstruct[nPosicao],'')			// 01 - Titulo
Aadd(aEstruct[nPosicao],'')			// 02 - Campo
Aadd(aEstruct[nPosicao],'')			// 03 - Tipo
Aadd(aEstruct[nPosicao],0)			// 04 - Tamanho
Aadd(aEstruct[nPosicao],0)			// 05 - Decimal
Aadd(aEstruct[nPosicao],'')			// 06 - Picture
Aadd(aEstruct[nPosicao],{|| .T. })	// 07 - Valid
Aadd(aEstruct[nPosicao],.F.)		// 08 - Obrigat
Aadd(aEstruct[nPosicao],1)			// 09 - Nivel
Aadd(aEstruct[nPosicao],'')			// 10 - Inicializador Padrão
Aadd(aEstruct[nPosicao],'')			// 11 - F3
Aadd(aEstruct[nPosicao],{|| })		// 12 - When
Aadd(aEstruct[nPosicao],.F.)		// 13 - Visual
Aadd(aEstruct[nPosicao],.F.)		// 14 - Chave
Aadd(aEstruct[nPosicao],'')			// 15 - Box - Opção do combo
Aadd(aEstruct[nPosicao],0)			// 16 - Folder
Aadd(aEstruct[nPosicao],.F.)		// 17 - Não Alterável
Aadd(aEstruct[nPosicao],'')			// 18 - PictVar
Aadd(aEstruct[nPosicao],'N')		// 19 - Gatilho

Return nPosicao

//-------------------------------------------------------------------
/*/{Protheus.doc} VldGet()

Função responsável por fazer a validação dos gets das MGMGET's

Esta rotina estará disponível somente na versão 12.

@author joao.pellegrini
@since 08/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function VldGet(cTbValid, cVarCod, cVarDesc, cVarSecond)

Local lRet   := .T.
Local lTodos := .F.
Default cVarSecond  := ""

dbSelectArea("SX5")

If Empty(cVarCod)
    cVarDesc := ""
Else
    Do Case
        Case cTbValid == "B1_COD"
            lTodos := AllTrim(cVarCod) == Replicate("Z", TamSX3("B1_COD")[1])
            lRet := lTodos .Or. ExistCpo("SB1")
            cVarDesc := IIf(lTodos, "TODOS", Posicione("SB1", 1, xFilial("SB1") + cVarCod , "B1_DESC"))
        Case cTbValid == "B1_POSIPI"
            lTodos := AllTrim(cVarCod) == Replicate("Z", TamSX3("B1_POSIPI")[1])
            lRet := lTodos .Or. ExistCpo("SYD")
            cVarDesc := IIf(lTodos, "TODOS", Posicione("SYD", 1, xFilial("SYD") + cVarCod , "YD_DESC_P"))
        Case cTbValid == "B1_TIPO"
            If SX5->(dbSeek(xFilial("SX5") + "02" + cVarCod))
                lRet := .T.
                cVarDesc := X5DESCRI()
            Else
                lRet := .F.
                cVarDesc := ""
                Alert(STR0020) //"Registro Não Encontrado!"
            EndIf
        Case cTbValid $ "B1_GRTRIB/A1_GRPTRIB/A2_GRPTRIB"
            If SX5->(dbSeek(xFilial("SX5") + "21" + cVarCod))
                lRet := .T.
                cVarDesc := X5DESCRI()
            Else
                lRet := .F.
                cVarDesc := ""
                Alert(STR0020) //"Registro Não Encontrado!"
            EndIf
        Case cTbValid $ "A1_EST/A2_EST"
            If SX5->(dbSeek(xFilial("SX5") + "12" + cVarCod))
                lRet := .T.
                cVarDesc := X5DESCRI()

                //Se altera o Estado irei limpar o código de ´muincípio e descrição
                IF cTbValid == "A1_EST"
                    cA1Mun  := CriaVar('A1_COD_MUN')
                    cDesA1Mun   := space(60)
                ElseIf cTbValid == "A2_EST"
                    cA2Mun  := CriaVar('A2_COD_MUN')
                    cDesA2Mun   := space(60)
                EndIF
            Else
                lRet := .F.
                cVarDesc := ""
                Alert(STR0020) //"Registro Não Encontrado!"
            EndIf

        Case cTbValid $ "A1_COD_MUN/A2_COD_MUN"
            
            IF !Empty(cVarSecond)
                CC2->(dbSetOrder(1))
                If CC2->(dbSeek(xFilial("CC2") + cVarSecond + cVarCod))
                    lRet    := .T.
                    cVarDesc := Posicione("CC2", 1, xFilial("CC2") + cVarSecond +  cVarCod , "CC2_MUN")
                Else
                    lRet    := .F.
                    cVarDesc    := ""
                    Alert(STR0020) //"Registro Não Encontrado!"
                EndIF
            Else
                lRet    := .F.
                cVarDesc    := ""
                Alert("Informe o Estado primeiro.") //"Registro Não Encontrado!"
            EndIF

        Case cTbValid == "A1_GRPVEN"
            lRet     := ExistCpo("ACY")
            cVarDesc := Posicione("ACY", 1, xFilial("ACY") + cVarCod , "ACY_DESCRI")
    EndCase
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MarkPerfil

Função que realiza a montagem dos perfis tributários, criando um browse
com opção de mark, para selecionar os perfis que serão alterados.

@author Erick Dias
@since 03/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MarkPerfil(oPanel, cTpPerfil, lAllPerfil,oMark)

Local cAliasF20  := GetNextAlias()
Local cQuery     := ""
Local aCampos    := {}
Local aColumns   := {}
Local oLayer     := FWLayer():new()
Local oPanel1     := NIL
Local oPanel2     := NIL
Local oSayTitulo := NIL

//Chama função para montar query e array com os campos do Header
cQuery := FSA171QRY("F20", {cTpPerfil}, @aCampos)

//Chama função para montar as colunas do aHeader
aColumns  := HeaderMark(aCampos)

//Cria Layer
oLayer:Init(oPanel,.F.)

// Adicionando linhas
oLayer:AddLine('L1',10,.F.)
oLayer:AddLine('L2',90,.F.)
oPanel1 := oLayer:getLinePanel('L1')
oPanel2 := oLayer:getLinePanel('L2')

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0022 + DescPerfil(cTpPerfil,'01') + STR0021 },oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //' que será(ão) alterado(s)' //'Selecione o(s) perfil(is) de '
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//Criando o Browse
oMark := AddMarkBro(oPanel2, @lAllPerfil, aCampos, aColumns, cQuery, cAliasF20)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA171QRY()

Função responsável por centralizar as queries executadas nas etapas
dos facilitadores.

@author joao.pellegrini
@since 17/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function FSA171QRY(cTpQuery, aParamQry, aCampos, cArrayRes, cObjREs,cCodF20, cAcao)

Local cQuery      := ""
Local nX          := 0

DEFAULT cArrayRes := ''
DEFAULT cObjREs   := ''
DEFAULT cCodF20   := ''
Default cAcao     := ''

aCampos := CamposBrw(cArrayRes, cObjRes, cTpQuery)

If cTpQuery == "F20"
    cQuery  := "SELECT 0 OK"
Else
    cQuery  := "SELECT 1 OK"
EndIf

//Adiciona os campos do Header na seção do select
For nX := 1 to Len(aCampos)
    cQuery  += " , " + aCampos[nX][1]
Next nX

Do Case

    Case cTpQuery == "F20"

        cQuery  += "FROM " + RETSQLNAME("F20") + " F20 WHERE F20.F20_FILIAL = " + ValToSQL(xFilial("F20")) + " AND F20.F20_TIPO = " + ValToSql(aParamQry[1])  +  " AND F20.D_E_L_E_T_ = ' ' "

    Case cTpQuery == "SB1"

        cQuery += " FROM " + RETSQLNAME("SB1") + " SB1 "
        cQuery += " WHERE SB1.B1_FILIAL = " + ValToSQL(xFilial("SB1"))

        // Codigo de / Codigo até
        If !Empty(aParamQry[1]) .And. !Empty(aParamQry[2])
            cQuery += " AND (SB1.B1_COD >= " + ValToSql(aParamQry[1])  +  " AND SB1.B1_COD <= " + ValToSql(aParamQry[2]) + ")"
        EndIf

        // NCM de / NCM até
        If !Empty(aParamQry[3]) .And. !Empty(aParamQry[4])
            cQuery += " AND (SB1.B1_POSIPI >= " + ValToSql(aParamQry[3]) + " AND SB1.B1_POSIPI <= "  + ValToSql(aParamQry[4]) + ")"
        EndIf

        // Tipo de Produto
        If !Empty(aParamQry[5])
            cQuery += " AND SB1.B1_TIPO = " + ValToSql(aParamQry[5])
        EndIf

        // Grupo de Tributação
        If !Empty(aParamQry[6])
            cQuery += " AND B1_GRTRIB = " + ValToSql(aParamQry[6])
        EndIf

        // Origem(ns)
        If !Empty(aParamQry[7])
            cQuery += " AND B1_ORIGEM IN " + FormatIn(aParamQry[7], "|")
        EndIF

        // CEST de / CEST até
        If !Empty(aParamQry[8]) .And. !Empty(aParamQry[9])
            cQuery += " AND (SB1.B1_CEST >= " + ValToSql(aParamQry[8]) + " AND SB1.B1_CEST <= "  + ValToSql(aParamQry[9]) + ")"
        EndIF

        // GRUPO De / GRUPO Até
        If !Empty(aParamQry[10]) .And. !Empty(aParamQry[11])
            cQuery += " AND (SB1.B1_GRUPO >= " + ValToSql(aParamQry[10]) + " AND SB1.B1_GRUPO <= "  + ValToSql(aParamQry[11]) + ")"
        EndIF

        If fisExtCmp('12.1.2310', .F.,'SB1','B1_MSBLQL')
            cQuery += " AND SB1.B1_MSBLQL <> '1'" // Não considerar os registros que estão com o campo de bloqueio.
        EndIf

        cQuery += " AND SB1.D_E_L_E_T_ = ' ' "

    Case cTpQuery == "SA1"

        cQuery += " FROM " + RETSQLNAME("SA1") + " SA1 "

        If cAcao == "1" // Para inclusão, considero todos os participantes que não estão cadastrados no perfil de participante.
            cQuery += " LEFT JOIN " + RetSQLName("F22") + " F22 "  
        Else // Para exclusão, considero somente os participantes que estão cadastrados no perfil de participante.
            cQuery += " RIGHT JOIN " + RetSQLName("F22") + " F22 "  
        EndIf
        cQuery += " ON  F22.F22_FILIAL = " + ValToSQL(xFilial("F22"))
        cQuery += " AND F22.F22_CODIGO = " + ValToSQL(cCodF20)
        cQuery += " AND F22.F22_TPPART = '2' "
        cQuery += " AND F22.F22_CLIFOR = SA1.A1_COD  "
        cQuery += " AND F22.F22_LOJA   = SA1.A1_LOJA "
        cQuery += " AND F22.D_E_L_E_T_ = ' ' "

        cQuery += "WHERE SA1.A1_FILIAL = " + ValToSQL(xFilial("SA1"))

        //Física/Jurídica cA1Pessoa
        If !Empty(aParamQry[1])
            cQuery += " AND SA1.A1_PESSOA = " + ValToSql(aParamQry[1])
        EndIf

        //Tipo Cliente cA1Tipo
        If !Empty(aParamQry[2])
            cQuery += " AND SA1.A1_TIPO = " + ValToSql(aParamQry[2])
        EndIf

        //Tipo Pessoa cA1TPessoa
        If !Empty(aParamQry[3])
            cQuery += " AND SA1.A1_TPESSOA = " + ValToSql(aParamQry[3])
        EndIf

        //Optante Simples Nacional cA1SimpNac
        If !Empty(aParamQry[4])
            cQuery += " AND SA1.A1_SIMPNAC = " + ValToSql(aParamQry[4])
        EndIf

        //Contribuinte cA1Contrib
        If !Empty(aParamQry[5])
            cQuery += " AND SA1.A1_CONTRIB = " + ValToSql(aParamQry[5])
        EndIF

        //Grupo de Tributação cA1GrpTrib
        If !Empty(aParamQry[6])
            cQuery += " AND SA1.A1_GRPTRIB = " + ValToSql(aParamQry[6])
        EndIF

        //Estado cA1Estado
        If !Empty(aParamQry[7])
            cQuery += " AND SA1.A1_EST = " + ValToSql(aParamQry[7])
        EndIF

        //Grupo de Vendas cA1GrpVen
        If !Empty(aParamQry[8])
            cQuery += " AND SA1.A1_GRPVEN = " + ValToSql(aParamQry[8])
        EndIF

        //Código de Município cA1Mun
        If !Empty(aParamQry[9]) .AND. !Empty(aParamQry[7])
            cQuery += " AND SA1.A1_COD_MUN = " + ValToSql(aParamQry[9])
        EndIF

        If fisExtCmp('12.1.2310', .F.,'SA1','A1_MSBLQL')
            cQuery += " AND SA1.A1_MSBLQL <> '1' " // Não considerar os registros que estão com o campo de bloqueio.
        EndIf

        cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
        If cAcao == "1" //Somente na inclusão eu devo considerar apenas os registros que não estão cadastrados no perfil de participante.
            cQuery += " AND F22.F22_CODIGO IS NULL"
        EndIf

    Case cTpQuery == "SA2"

        cQuery += " FROM " + RETSQLNAME("SA2") + " SA2 "

        If cAcao == "1" // Para inclusão, considero todos os participantes que não estão cadastrados no perfil de participante.
            cQuery += " LEFT JOIN " + RetSQLName("F22") + " F22 "  
        Else // Para exclusão, considero somente os participantes que estão cadastrados no perfil de participante.
            cQuery += " RIGHT JOIN " + RetSQLName("F22") + " F22 "  
        EndIf
        cQuery += " ON  F22.F22_FILIAL = " + ValToSQL(xFilial("F22"))
        cQuery += " AND F22.F22_CODIGO = " + ValToSQL(cCodF20)
        cQuery += " AND F22.F22_TPPART = '1' "
        cQuery += " AND F22.F22_CLIFOR = SA2.A2_COD  "
        cQuery += " AND F22.F22_LOJA   = SA2.A2_LOJA "
        cQuery += " AND F22.D_E_L_E_T_ = ' ' "

        cQuery += "WHERE SA2.A2_FILIAL = " + ValToSQL(xFilial("SA2"))

        //Física/Jurídica cA1Pessoa
        If !Empty(aParamQry[1])
            cQuery += " AND SA2.A2_TIPO = " + ValToSql(aParamQry[1])
        EndIf

        //Tipo Cliente cA1Tipo
        If !Empty(aParamQry[2])
            cQuery += " AND SA2.A2_EST = " + ValToSql(aParamQry[2])
        EndIf

        //Tipo Pessoa cA1TPessoa
        If !Empty(aParamQry[3])
            cQuery += " AND SA2.A2_GRPTRIB = " + ValToSql(aParamQry[3])
        EndIf

        //Optante Simples Nacional cA1SimpNac
        If !Empty(aParamQry[4])
            cQuery += " AND SA2.A2_SIMPNAC = " + ValToSql(aParamQry[4])
        EndIf

        //Contribuinte cA1Contrib
        If !Empty(aParamQry[5])
            cQuery += " AND SA2.A2_CONTRIB = " + ValToSql(aParamQry[5])
        EndIF

        //Código de Município cA2Mun
        If !Empty(aParamQry[6]) .And. !Empty(aParamQry[2])
            cQuery += " AND SA2.A2_COD_MUN = " + ValToSql(aParamQry[6])
        EndIF

        If fisExtCmp('12.1.2310', .F.,'SA2','A2_MSBLQL')
            cQuery += " AND SA2.A2_MSBLQL <> '1' " // Não considerar os registros que estão com o campo de bloqueio.
        EndIf
        
        cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
        If cAcao == "1" //Somente na inclusão eu devo considerar apenas os registros que não estão cadastrados no perfil de participante.
            cQuery += " AND F22.F22_CODIGO IS NULL"
        EndIf

    Case cTpQuery == "SX5"

        cQuery  += "FROM " + RETSQLNAME("SX5") + " SX5 WHERE SX5.X5_FILIAL = " + ValToSQL(xFilial("SX5")) + " AND SX5.X5_TABELA = " + ValToSql(aParamQry[1]) + " AND SX5.D_E_L_E_T_ = ' ' "

EndCase

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} HeaderMark(aCampos)

Fubnção responsável por criar as colunas do Header do Browse

@author Erick Dias
@since 03/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function HeaderMark(aCampos, lQuery)

Local oColuna   := NIL
Local aColumns  := {}
Local nX        := 0

DEFAULT lQuery  := .T.

For nX  := 1 to Len(aCampos)
    oColuna := FWBrwColumn():New()	    // Cria objeto
    oColuna:SetEdit(.F.)    	   	    // Indica se <E9> editavel
    oColuna:SetTitle(aCampos[nX][2])	// Define titulo
    oColuna:SetType(aCampos[nX][3])	    // Define tipo
    oColuna:SetSize(aCampos[nX][4])	    // Define tamanho
    oColuna:SetPicture(aCampos[nX][5])  // Define picture
    oColuna:SetAlign(aCampos[nX][6])    // Define alinhamento
    If lQuery
        oColuna:SetData(&('{||'+aCampos[nX][1]+'}'))
    Else
        oColuna:SetData(&(aCampos[nX][7]))
    EndIf
    Aadd(aColumns,oColuna)
Next nX

Return aColumns

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll()

Função responsável por fazer controle de marcar ou desmarcar todas
as linhas do grid

@author Erick Dias
@since 03/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function SetMarkAll( oObjMark, lMarkAll )

Local cMarkABB := ''

//Busco o Alias do Browse
cMarkABB := oObjMark:cAlias

//Percorro todoas as linhas e marco/desmarco todas as linhas
(cMarkABB)->( DbGoTop() )
While (cMarkABB)->( !EOF() )
    (cMarkABB)->OK := Iif(lMarkAll,1,0)
    (cMarkABB)->( DbSkip() )
EndDo

//Retorno para a primeira linha
(cMarkABB)->( DbGoTop() )

//Atualizo a variável de controle e do refresh no Browse
lMarkAll := !lMarkAll
oObjMark:Refresh(,.T.)
oObjMark:Refresh(,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDMARK()

Função que faz validação da seleção dos perfis, é necessário ter ao menos um perfil selecionado
para prosseguir.

@author Erick Dias
@since 03/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function VLDMARK(oObjMark, cMsg)

Local lRet      := .F.

lRet    := ChkMarkOk(oObjMark)

If !lRet
    Alert(cMsg)
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPerOper()

Função que faz a validação do facilitador de perfil de operação, será necessário
selecionar ao menos um CFOP ou então um tipo de operação.

@author Erick Dias
@since 25/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function VldPerOper(oObjCfop, oObjTpOp, cMsg, oMarkISS)

Local lRet      := .F.

//Verifica se ao menos 1 linha de CFOP, tipo de operação ou ISS foi selecionado
If ChkMarkOk(oObjCfop) .Or. ChkMarkOk(oObjTpOp) .Or. (lAliasCIO .And. ChkMarkOk(oMarkISS))
    lRet := .T.
EndIF

If !lRet
    Alert(cMsg)
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkMarkOk()

Função que percorre as linhas do mark browse e verifica se existe ao menos
1 linha selecionada.

@author Erick Dias
@since 25/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ChkMarkOk(ObjMark)

Local lRet      := .F.
Local cMark     := ObjMark:cAlias

//Percorro todoas as linhas e verifico se existe ao menos 1 linha selecionada
(cMark)->( DbGoTop() )
While (cMark)->( !EOF() )
    If (cMark)->OK == 1
        lRet    := .T.
        Exit
    EndIF
    (cMark)->( DbSkip() )
EndDo

//Retorno para a primeira linha
(cMark)->( DbGoTop() )
ObjMark:Refresh(,.T.)
ObjMark:Refresh(,.T.)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DescPerfil()

Função que retorna a descrição do tipo de perfil

@author Erick Dias
@since 03/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function DescPerfil(cTpPerfil, cTpDescr)

Local cRet  := ''

IF cTpPerfil == "01"
    cRet := STR0023 //"Origem e Destino"
ElseIF cTpPerfil == "02"
    cRet := STR0024 //"Participante"
ElseIF cTpPerfil == "03"
    IF cTpDescr == '01'
        cRet := STR0025 //"Operação"
    Else
        If lAliasCIO
            cRet := STR0067 //"CFOP / Tipo de Operação / ISS"
        Else
            cRet := STR0026 //"CFOP / Tipo de Operação"
        EndIf
    EndIf
ElseIf cTpPerfil == "04"
    cRet := "Produto"
EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA171PUF()

Fiunção que montará os GRIDs para filtros da UFs

@author Erick Dias
@since 03/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function FSA171PUF(oPanel, oMarkUfOri, oMarkUfDest)

Local oLayer     := FWLayer():new()
Local aCampos    := {}
Local aColumns   := {}
Local cQuery     := ""
Local cAliasOri  := GetNextAlias()
Local cAliasDest := GetNextAlias()
Local oSayTitulo := NIL
Local oPanel1    := NIL
Local oPanel2    := NIL
Local oPanel3    := NIL
Local oPanel4    := NIL

//Cria Layer
oLayer:Init(oPanel,.F.)

// Adicionando linhas
oLayer:AddLine('L1',10,.F.)
oLayer:AddLine('L2',90,.F.)
oPanel1 := oLayer:getLinePanel('L1')
oPanel2 := oLayer:getLinePanel('L2')

//Adicionando colunas
oLayer:addCollumn('C1',50,.F.,'L2')
oLayer:addCollumn('C2',50,.F.,'L2')

oLayer:AddWindow('C1','W1',STR0027,100,.F.,.F.,,'L2') //"UF de Origem"
oLayer:AddWindow('C2','W2',STR0028,100,.F.,.F.,,'L2') //"UF de Destino"

oPanel3 := oLayer:getWinPanel('C1','W1','L2')
oPanel4 := oLayer:getWinPanel('C2','W2','L2')

//Crio o TSay na primeira linha da Layer
oSayTitulo:= TSay():New(5,5,{||STR0029 },oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //'Selecione abaixo as UFs de Origem e Destino'
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//Chama função para montar query e array com os campos do Header
cQuery := FSA171QRY("SX5", {'12'}, @aCampos)

//Chama função para montar as colunas do aHeader
aColumns  := HeaderMark(aCampos)

//Chama função para montar o browse para origem
oMarkUfOri := AddMarkBro(oPanel3, @lAllPUFO, aCampos, aColumns, cQuery, cAliasOri)

//Chama função para montar o browse para destino
oMarkUfDest := AddMarkBro(oPanel4, @lAllPUFD, aCampos, aColumns, cQuery, cAliasDest)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA171POPE()

Função que criará os filtros de CFOP e tipo de operação para alteração em
lote dos perfis de Operações

@author Erick Dias
@since 25/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function FSA171POPE(oPanel, oMarkCfop, oMarkTpOpe)

Local oLayer      := FWLayer():new()
Local aCmpCFOP    := {}
Local aCmpTpOp    := {}
Local aColsCFOP   := {}
Local aColsTPOP   := {}
Local cQueryCfop  := ""
Local cQueryTpOp  := ""
Local cAliasCfop := GetNextAlias()
Local cAliasTpOp := GetNextAlias()
Local oSayTitulo := NIL
Local oPanel1    := NIL
Local oPanel2    := NIL
Local oPanel3    := NIL
Local oPanel4    := NIL

//Cria Layer
oLayer:Init(oPanel,.F.)

// Adicionando linhas
oLayer:AddLine('L1',10,.F.)
oLayer:AddLine('L2',90,.F.)
oPanel1 := oLayer:getLinePanel('L1')
oPanel2 := oLayer:getLinePanel('L2')

//Adicionando colunas
oLayer:addCollumn('C1',50,.F.,'L2')
oLayer:addCollumn('C2',50,.F.,'L2')

oLayer:AddWindow('C1','W1',"CFOPs",100,.F.,.F.,,'L2')
oLayer:AddWindow('C2','W2',STR0030,100,.F.,.F.,,'L2') //"Tipos de Operação"

oPanel3 := oLayer:getWinPanel('C1','W1','L2')
oPanel4 := oLayer:getWinPanel('C2','W2','L2')

//Crio o TSay na primeira linha da Layer
oSayTitulo:= TSay():New(5,5,{||STR0031 },oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //'Selecione abaixo os CFOPs e/ou Tipos de Operação'
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//Chama função para montar query e array com os campos do Header
cQueryCfop := FSA171QRY("SX5", {'13'}, @aCmpCFOP)
cQueryTpOp := FSA171QRY("SX5", {'DJ'}, @aCmpTpOp)

//Chama função para montar as colunas do aHeader
aColsCFOP  := HeaderMark(aCmpCFOP)
aColsTPOP  := HeaderMark(aCmpTpOp)

//Chama função para montar o browse para CFOPs
oMarkCfop := AddMarkBro(oPanel3, @lAllCFOP, aCmpCFOP, aColsCFOP, cQueryCfop, cAliasCfop)

//Chama função para montar o browse para Tipo de Operação
oMarkTpOpe := AddMarkBro(oPanel4, @lAllTPOP, aCmpTpOp, aColsTPOP, cQueryTpOp, cAliasTpOp)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA171CLI()

Função responsável por montar a tela de filtros do cadastro de Cliente
SA1.

@author Erick Dias
@since 09/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function FSA171CLI(oPanel)

Local oLayer     := FWLayer():New()
Local oPanel0    := NIL
Local oPanel1    := NIL
Local aEstrut    := {}
Local aFields    := {}

PRIVATE oGetsCli := NIL

//Criando duas linhas
oLayer:Init(oPanel,.F.)
oLayer:AddLine('LIN0', 10, .F.)
oLayer:AddLine('LIN1', 90, .F.)

oPanel0 := oLayer:getLinePanel('LIN0')
oPanel1 := oLayer:getLinePanel('LIN1')

// Título da página
oSayTitulo := TSay():New(5,5,{||STR0032},oPanel0,,oFont18,,,,.T.,,,(oPanel0:nWidth / 2) - 10,(oPanel0:nHeight / 2) - 10) //"Preencha os filtros abaixo para selecionar os clientes que serão adicionados ou removidos do(s) perfil(is)"
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

// Montagem da MsMGet
aEstrut := MontaEstrut('SA1')
aEval(aEstrut, {|x| aAdd(aFields, x[2])})
oGetsCli := MsmGet():New(,,3,,,,aFields,{0,3,(oPanel1:nClientHeight-4)/2,(oPanel1:nClientWidth/2)-5},,,,,,oPanel1,,,.T.,,,.T.,aEstrut,,,,,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddMarkBro()

Função que monta o MarkBrowse

@author Erick Dias
@since 03/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AddMarkBro(oPanel, lAllMark, aCampos, aColumns, cQuery, cAliasTab)

Local bMark        := {||IIf((oMark:cAlias)->OK == 1, "LBOK", "LBNO")}
Local bMarkOne     := {||IIf((oMark:cAlias)->OK == 0,(oMark:cAlias)->OK := 1, (oMark:cAlias)->OK := 0 )}
Local bMarkAll     := {||SetMarkAll(@oMark, @lAllMark)}
Local oMark        := NIL

oMark := FwFormBrowse():New()
oMark:AddMarkColumns(bMark,bMarkOne,bMarkAll)
oMark:SetDataQuery(.T.)
oMark:SetQuery(cQuery)
oMark:SetAlias(cAliasTab)
oMark:SetOwner(oPanel)
oMark:SetColumns(aColumns)
oMark:SetDoubleClick(bMarkOne)
oMark:DisableDetails()
oMark:DisableReport()
oMark:DisableConfig()
oMark:Activate()
oMark:GoTop(.T.)
oMark:SetFocus()

Return oMark


//-------------------------------------------------------------------
/*/{Protheus.doc} RESUMOOPER()

Função que monta a tela de resumo antes da gravação dos perfis de
Operações

@author Erick Dias
@since 25/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function RESUMOOPER(oPanel,oMarkPerfil,oMarkCFOP,oMarkTpOpe,cAcao, cTpWiz, oMarkISS)
Local oLayer       := FWLayer():new()
Local aCmpPerfil   := {}
Local aColPerfil   := {}
Local aCmpCFOP  := {}
Local aCmpTpOp  := {}
Local aCmpISS   := {}
Local aColsCFOP := {}
Local aColsTPOP := {}
Local aColsISS  := {}
Local oSayTitulo   := NIL
Local oPanel1      := NIL
Local oPanel2      := NIL
Local oPanel3      := NIL
Local oPanel4      := NIL
Local oPanel5      := NIL
Local oPanel6      := NIL

//Criando a Layer
oLayer:Init(oPanel,.F.)

IF cTpWiz == '1'
    // Adicionando linhas
    oLayer:AddLine('L1',10,.F.)
    oLayer:AddLine('L2',35,.F.)
    oLayer:AddLine('L3',55,.F.)
    oPanel1 := oLayer:getLinePanel('L1')
    oPanel2 := oLayer:getLinePanel('L2')
    oPanel3 := oLayer:getLinePanel('L3')

    //Adicionando colunas
    If lAliasCIO 
        oLayer:addCollumn('C1',33,.F.,'L3')
        oLayer:addCollumn('C2',34,.F.,'L3')
        oLayer:addCollumn('C3',33,.F.,'L3')

        oLayer:AddWindow('C3','W3',STR0068,100,.F.,.F.,,'L3') //"Códigos de ISS"

        oPanel6 := oLayer:getWinPanel('C3','W3','L3')
    Else
        oLayer:addCollumn('C1',50,.F.,'L3')
        oLayer:addCollumn('C2',50,.F.,'L3')
    EndIf

    // Adicionando Janelas
    oLayer:AddWindow('C1','W1',"CFOP",100,.F.,.F.,,'L3')
    oLayer:AddWindow('C2','W2',STR0030,100,.F.,.F.,,'L3') //"Tipos de Operação"

    oPanel4 := oLayer:getWinPanel('C1','W1','L3')
    oPanel5 := oLayer:getWinPanel('C2','W2','L3')
Else
    // Adicionando linhas
    oLayer:AddLine('L1',10,.F.)
    oLayer:AddLine('L2',90,.F.)
    oPanel1 := oLayer:getLinePanel('L1')
    oPanel2 := oLayer:getLinePanel('L2')

    //Adicionando colunas
    If lAliasCIO
        oLayer:addCollumn('C1',33,.F.,'L2')
        oLayer:addCollumn('C2',34,.F.,'L2')
        oLayer:addCollumn('C3',33,.F.,'L2')

        oLayer:AddWindow('C3','W3',STR0068,100,.F.,.F.,,'L2') //"Códigos de ISS"

        oPanel6 := oLayer:getWinPanel('C3','W3','L2')
    Else
        oLayer:addCollumn('C1',50,.F.,'L2')
        oLayer:addCollumn('C2',50,.F.,'L2')
    EndIf

    // Adicionando Janelas
    oLayer:AddWindow('C1','W1',"CFOP",100,.F.,.F.,,'L2')
    oLayer:AddWindow('C2','W2',STR0030,100,.F.,.F.,,'L2') //"Tipos de Operação"

    oPanel4 := oLayer:getWinPanel('C1','W1','L2')
    oPanel5 := oLayer:getWinPanel('C2','W2','L2')
EndIF

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0035 + Iif(cAcao == '1' ,STR0033 , STR0034) },oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //'ADICIONADAS' //'REMOVIDAS' //'Resumo das informações que serão '
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//--------------------------------------------------------------
//Montando os campos do browse de perfil, uf origem e uf destino
//--------------------------------------------------------------
//Monta os campos dos perfis
IF cTpWiz == '1'
    aCmpPerfil  := CamposBrw('aResumoPerfil', 'oPerfil', 'F20')
EndIF

//Monta os campos de CFOP
aCmpCFOP   := CamposBrw('aResumoCFOP', 'oCFOP', 'SX5')
//Monta os campos do Tipo de Operação
aCmpTpOp   := CamposBrw('aResumoTPOP', 'oTpOper', 'SX5')
//Monta os campos do código de ISS
aCmpISS    := CamposBrw('aResumoISS', 'oCodISS', 'SX5')

//--------------------------------------------------------------
//Montando header do browse de perfil, CFOP
//--------------------------------------------------------------
//Monta o cabeçalho dos perfis
IF cTpWiz == '1'
    aColPerfil  := HeaderMark(aCmpPerfil, .F.)
EndIF

//Monta o cabeçalho do CFOP
aColsCFOP  := HeaderMark(aCmpCFOP, .F.)
//Monta o cabeçalho do Tipo de Operação
aColsTPOP  := HeaderMark(aCmpTpOp, .F.)
//Monta o cabeçalho do Código de ISS
aColsISS  := HeaderMark(aCmpISS, .F.)

//--------------------------------------------------------------
//Montando array com conteúdo do browse de perfil, uf origem e uf destino
//--------------------------------------------------------------
//Monta array de resumo com Perfis selecionados
IF cTpWiz == '1'
    aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
EndIF

//Monta array de resumo com UF de origem selecionadas
aResumoCFOP     := MontaResumo(oMarkCFOP, 'SX5')
//Monta array de resumo com UF de destino selecionadas
aResumoTPOP     := MontaResumo(oMarkTpOpe, 'SX5')
//Monta array de resumo com os códigos de ISS selecionados
If lAliasCIO
    aResumoISS     := MontaResumo(oMarkISS, 'SX5')
EndIf

//------------------------------------------------------------------------
//Montando Browse do resumo de perfil, UF origem e UF destino selecionados
//------------------------------------------------------------------------
//Browse de perfil
IF cTpWiz == '1'
    ADDBrwResumo(@oPerfil, aColPerfil, aResumoPerfil, oPanel2)
EndIF

//Browse de CFOP
ADDBrwResumo(@oCFOP, aColsCFOP, aResumoCFOP, oPanel4)

//Browse de Tipo de Operação
ADDBrwResumo(@oTpOper, aColsTPOP, aResumoTPOP, oPanel5)

//Browse de código de ISS
If lAliasCIO
    ADDBrwResumo(@oCodISS, aColsISS, aResumoISS, oPanel6)
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RESUMOUF()

Função que monta a tela de resumo antes da gravação dos perfis de
origem e destino.

@author Erick Dias
@since 07/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ResumoUF(oPanel,oMarkPerfil,oMarkUfOri,oMarkUfDest,cAcao, cTpWiz)

Local oLayer       := FWLayer():new()
Local aCmpPerfil   := {}
Local aColPerfil   := {}
Local oSayTitulo   := NIL
Local oPanel1      := NIL
Local oPanel2      := NIL
Local oPanel3      := NIL
Local oPanel4      := NIL
Local oPanel5      := NIL

//Criando a Layer
oLayer:Init(oPanel,.F.)

IF cTpWiz == '1'
    // Adicionando linhas
    oLayer:AddLine('L1',10,.F.)
    oLayer:AddLine('L2',35,.F.)
    oLayer:AddLine('L3',55,.F.)
    oPanel1 := oLayer:getLinePanel('L1')
    oPanel2 := oLayer:getLinePanel('L2')
    oPanel3 := oLayer:getLinePanel('L3')

    //Adicionando colunas
    oLayer:addCollumn('C1',50,.F.,'L3')
    oLayer:addCollumn('C2',50,.F.,'L3')

    // Adicionando Janelas
    oLayer:AddWindow('C1','W1',STR0027,100,.F.,.F.,,'L3') //"UF de Origem"
    oLayer:AddWindow('C2','W2',STR0028,100,.F.,.F.,,'L3') //"UF de Destino"

    oPanel4 := oLayer:getWinPanel('C1','W1','L3')
    oPanel5 := oLayer:getWinPanel('C2','W2','L3')
Else
    // Adicionando linhas
    oLayer:AddLine('L1',10,.F.)
    oLayer:AddLine('L2',90,.F.)
    oPanel1 := oLayer:getLinePanel('L1')
    oPanel2 := oLayer:getLinePanel('L2')

    //Adicionando colunas
    oLayer:addCollumn('C1',50,.F.,'L2')
    oLayer:addCollumn('C2',50,.F.,'L2')

    // Adicionando Janelas
    oLayer:AddWindow('C1','W1',STR0027,100,.F.,.F.,,'L2') //"UF de Origem"
    oLayer:AddWindow('C2','W2',STR0028,100,.F.,.F.,,'L2') //"UF de Destino"

    oPanel4 := oLayer:getWinPanel('C1','W1','L2')
    oPanel5 := oLayer:getWinPanel('C2','W2','L2')
EndIF

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0035 + Iif(cAcao == '1' ,STR0033 , STR0034) },oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //'ADICIONADAS' //'REMOVIDAS' //'Resumo das informações que serão '
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//--------------------------------------------------------------
//Montando os campos do browse de perfil, uf origem e uf destino
//--------------------------------------------------------------
//Monta os campos dos perfis
IF cTpWiz == '1'
    aCmpPerfil  := CamposBrw('aResumoPerfil', 'oPerfil', 'F20')
EndIF

//Monta os campos da UF de Origem
aCmpUFORI   := CamposBrw('aResumoUfO', 'oUFOri', 'SX5')
//Monta os campos da UF de Destino
aCmpUFDES   := CamposBrw('aResumoUfD', 'oUFDest', 'SX5')

//--------------------------------------------------------------
//Montando header do browse de perfil, uf origem e uf destino
//--------------------------------------------------------------
//Monta o cabeçalho dos perfis
IF cTpWiz == '1'
    aColPerfil  := HeaderMark(aCmpPerfil, .F.)
EndIF

//Monta o cabeçalho da UF de origem
aColsUFORI  := HeaderMark(aCmpUFORI, .F.)
//Monta o cabeçalho da UF de destino
aColsUFDES  := HeaderMark(aCmpUFDES, .F.)

//--------------------------------------------------------------
//Montando array com conteúdo do browse de perfil, uf origem e uf destino
//--------------------------------------------------------------
//Monta array de resumo com Perfis selecionados
IF cTpWiz == '1'
    aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
EndIF

//Monta array de resumo com UF de origem selecionadas
aResumoUfO     := MontaResumo(oMarkUfOri, 'SX5')
//Monta array de resumo com UF de destino selecionadas
aResumoUfD     := MontaResumo(oMarkUfDest, 'SX5')

//------------------------------------------------------------------------
//Montando Browse do resumo de perfil, UF origem e UF destino selecionados
//------------------------------------------------------------------------
//Browse de perfil
IF cTpWiz == '1'
    ADDBrwResumo(@oPerfil, aColPerfil, aResumoPerfil, oPanel2)
EndIF

//Browse de UF Origem
ADDBrwResumo(@oUFOri, aColsUFORI, aResumoUfO, oPanel4)

//Browse de UF Destino
ADDBrwResumo(@oUFDest, aColsUFDES, aResumoUfD, oPanel5)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ResumoProd()

Função que monta a tela de resumo antes da gravação dos perfis de
produto

@author joao.pellegrini
@since 10/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ResumoProd(oPanel, oMarkPerfil, cAcao, cTpWiz)

Local oLayer     := FWLayer():New()
Local oPanel1    := NIL
Local oPanel2    := NIL
Local oPanel3    := NIL
Local oSayTitulo := NIL

Local aCmpPerfil := {}
Local aCmpProd   := {}

Local aColPerfil := {}
Local aColsProd  := {}

oLayer:Init(oPanel, .F.)

// Wizard "Por Fora"
If cTpWiz == '1'
    oLayer:AddLine('LIN1',10,.F.)
    oLayer:AddLine('LIN2',35,.F.)
    oLayer:AddLine('LIN3',55,.F.)

    oPanel1 := oLayer:getLinePanel('LIN1')
    oPanel2 := oLayer:getLinePanel('LIN2')
    oPanel3 := oLayer:getLinePanel('LIN3')
Else
    oLayer:AddLine('LIN1',10,.F.)
    oLayer:AddLine('LIN2',90,.F.)

    oPanel1 := oLayer:getLinePanel('LIN1')
    oPanel3 := oLayer:getLinePanel('LIN2')
EndIf

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0035 + Iif(cAcao == '1' ,STR0033 , STR0034) },oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //'ADICIONADAS' //'REMOVIDAS' //'Resumo das informações que serão '
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//Monta os campos dos perfis
IF cTpWiz == '1'
    aCmpPerfil := CamposBrw('aResumoPerfil', 'oPerfil', 'F20')
EndIF

aCmpProd := CamposBrw('aResumoProd', 'oProduto', 'SB1')

//Monta o cabeçalho dos perfis
IF cTpWiz == '1'
    aColPerfil := HeaderMark(aCmpPerfil, .F.)
EndIF

//Monta o cabeçalho dos produtos
aColsProd := HeaderMark(aCmpProd, .F.)

//Monta array de resumo com Perfis selecionados
IF cTpWiz == '1'
    aResumoPerfil := MontaResumo(oMarkPerfil, 'F20')
EndIF

//Monta array de resumo com UF de origem selecionadas
aResumoProd  := MontaResumo(oMarkProd, 'SB1')

//Browse de perfil
IF cTpWiz == '1'
    ADDBrwResumo(@oPerfil, aColPerfil, aResumoPerfil, oPanel2)
EndIF

//Browse de produtos
ADDBrwResumo(@oProduto, aColsProd, aResumoProd, oPanel3)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaResumo()

Função responsável por poplar array com as informações selecionadas
pelo usuário, para montarmos a tela com resumo antes do processamento
do faciltiador.

@author Erick Dias
@since 08/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MontaResumo(oObjtForm, cTab)

Local cAls      := oObjtForm:cAlias
Local aResumo   := {}

//Percorro todoas as linhas e marco/desmarco todas as linhas
(cAls)->( DbGoTop() )
While (cAls)->( !EOF() )
    If (cAls)->OK == 1
        If cTab == 'SX5'
            Aadd(aResumo,{(cAls)->X5_CHAVE, (cAls)->X5_DESCRI})
        ElseIf cTab == 'F20'
            Aadd(aResumo,{(cAls)->F20_CODIGO, (cAls)->F20_DESC})
        ElseIf cTab == 'SB1'
            Aadd(aResumo,{(cAls)->B1_COD, (cAls)->B1_DESC})
        ElseIf cTab == 'SA1'
            Aadd(aResumo,{(cAls)->A1_COD, (cAls)->A1_LOJA,(cAls)->A1_NOME})
        ElseIf cTab == 'SA2'
            Aadd(aResumo,{(cAls)->A2_COD, (cAls)->A2_LOJA,(cAls)->A2_NOME})
        EndIF
    EndIF
    (cAls)->( DbSkip() )
EndDo

//Volto para primeiro registro e atualizo o componente
(cAls)->( DbGoTop() )
oObjtForm:Refresh(,.T.)
oObjtForm:Refresh(,.T.)

Return aResumo

//-------------------------------------------------------------------
/*/{Protheus.doc} CamposBrw()

Função que monta array com os campos que farão parte do Browse

@author Erick Dias
@since 08/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function CamposBrw(cArrayRes, cObjRes, cAlias)

Local aRet          := {}

DEFAULT cArrayRes   := ''
DEFAULT cObjRes     := ''

Do Case

    Case cAlias == "SX5"

        //Campos que farão parte da seção select da query e do Header
        aAdd(aRet,{;
        "X5_CHAVE",; //Campo
        "",;//Descrição
        "C",;//Tipo
        TamSx3("X5_CHAVE")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][1] }'})//Bloco de Código para exibição do resumo

        aAdd(aRet,{;
        "X5_DESCRI",; //Campo
        "",;//Descrição
        "C",;//Tipo
        60,;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][2] }'})//Bloco de Código para exibição do resumo

    Case cAlias == "F20"

        //Campos que farão parte da seção select da query e do Header
        aAdd(aRet,{;
        "F20_CODIGO",; //Campo
        "Código",;//Descrição
        "C",;//Tipo
        TamSx3("F20_CODIGO")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][1] }'})//Bloco de Código para exibição do resumo

        aAdd(aRet,{;
        "F20_DESC",; //Campo
        "Descrição do Perfil",;//Descrição
        "C",;//Tipo
        TamSx3("F20_DESC")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][2] }'})//Bloco de Código para exibição do resumo

    Case cAlias == "SB1"

        //Campos que farão parte da seção select da query e do Header
        aAdd(aRet,{;
        "B1_COD",; //Campo
        "Código",;//Descrição
        "C",;//Tipo
        TamSx3("B1_COD")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][1] }'})//Bloco de Código para exibição do resumo

        aAdd(aRet,{;
        "B1_DESC",; //Campo
        "Descrição do Produto",;//Descrição
        "C",;//Tipo
        TamSx3("B1_DESC")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][2] }'})//Bloco de Código para exibição do resumo

    Case cAlias == "SA1"

        //Campos que farão parte da seção select da query e do Header
        aAdd(aRet,{;
        "A1_COD",; //Campo
        "Código",;//Descrição
        "C",;//Tipo
        TamSx3("A1_COD")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][1] }'})//Bloco de Código para exibição do resumo

        aAdd(aRet,{;
        "A1_LOJA",; //Campo
        "Loja",;//Descrição
        "C",;//Tipo
        TamSx3("A1_LOJA")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][2] }'})//Bloco de Código para exibição do resumo

        aAdd(aRet,{;
        "A1_NOME",; //Campo
        "Nome",;//Descrição
        "C",;//Tipo
        TamSx3("A1_NOME")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][3] }'})//Bloco de Código para exibição do resumo

    Case cAlias == "SA2"

        //Campos que farão parte da seção select da query e do Header
        aAdd(aRet,{;
        "A2_COD",; //Campo
        "Código",;//Descrição
        "C",;//Tipo
        TamSx3("A2_COD")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][1] }'})//Bloco de Código para exibição do resumo

        aAdd(aRet,{;
        "A2_LOJA",; //Campo
        "Loja",;//Descrição
        "C",;//Tipo
        TamSx3("A2_LOJA")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][2] }'})//Bloco de Código para exibição do resumo

        aAdd(aRet,{;
        "A2_NOME",; //Campo
        "Nome",;//Descrição
        "C",;//Tipo
        TamSx3("A2_NOME")[1],;//Tamanho
        "@!",;//Picture;
        "LEFT",;//Alinhamento
        '{|| ' + cArrayRes + '[' + cObjRes +':At()][3] }'})//Bloco de Código para exibição do resumo

EndCase

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ADDBrwResumo()

Função que cria Browse de resumo, este browse não possui coluna de mark,
somente para visualização.

@author Erick Dias
@since 08/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ADDBrwResumo(oBrowse, aColsBrw, aArrayBrw, oOwner)

oBrowse := FwFormBrowse():New()
oBrowse:SetColumns(aColsBrw)
oBrowse:SetDataArray()
oBrowse:SetArray(aArrayBrw)
oBrowse:SetOwner(oOwner)
oBrowse:DisableDetails()
oBrowse:DisableReport()
oBrowse:DisableConfig()
oBrowse:Activate()
oBrowse:SetFocus()
oBrowse:Refresh(.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuResumoUF()

Função que atualiza as informações nos browses de resumo da UF, pois
a construção do painel é chamada somente na primera vez, por este motivo
preciso atualizar aqui também.

@author Erick Dias
@since 08/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AtuResumoUF(oMarkPerfil,oMarkUfOri,oMarkUfDest,cTpWiz)

//Somente terá ação se os objetos abaixo existirem
IF Valtype(oUFOri) == "O" .AND. Valtype(oUFDest) == "O" .And. IIf(cTpWiz == '1', Valtype(oPerfil) == "O", .T.)

    aResumoPerfil   := {}
    aResumoUfO      := {}
    aResumoUfD      := {}

    //Monta array de resumo com Perfis selecionados
    If cTpWiz == '1'
        aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
        oPerfil:SetArray(aResumoPerfil)
        oPerfil:Refresh(.T.)
    EndIf

    //Monta array de resumo com UF de origem selecionadas
    aResumoUfO     := MontaResumo(oMarkUfOri, 'SX5')
    oUFOri:SetArray(aResumoUfO)
    oUFOri:Refresh(.T.)

    //Monta array de resumo com UF de destino selecionadas
    aResumoUfD     := MontaResumo(oMarkUfDest, 'SX5')
    oUFDest:SetArray(aResumoUfD)
    oUFDest:Refresh(.T.)

EndIF

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} AtuResOper()

Função que atualiza o resumo do perfil de operação

@author Erick Dias
@since 08/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AtuResOper(oMarkPerfil,oMarkCFOP,oMarkTpOpe,cTpWiz,oMarkISS)

//Somente terá ação se os objetos abaixo existirem
IF Valtype(oCFOP) == "O" .AND. Valtype(oTpOper) == "O" .And. IIf(cTpWiz == '1', Valtype(oPerfil) == "O", .T.)

    aResumoPerfil    := {}
    aResumoCFOP      := {}
    aResumoTPOP      := {}
    aResumoISS       := {}

    //Monta array de resumo com Perfis selecionados
    If cTpWiz == '1'
        aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
        oPerfil:SetArray(aResumoPerfil)
        oPerfil:Refresh(.T.)
    EndIf

    //Monta array de resumo com UF de origem selecionadas
    aResumoCFOP     := MontaResumo(oMarkCFOP, 'SX5')
    oCFOP:SetArray(aResumoCFOP)
    oCFOP:Refresh(.T.)

    //Monta array de resumo com UF de destino selecionadas
    aResumoTPOP     := MontaResumo(oMarkTpOpe, 'SX5')
    oTpOper:SetArray(aResumoTPOP)
    oTpOper:Refresh(.T.)

    If lAliasCIO .And. Valtype(oCodISS) == "O"
        //Monta array de resumo com os códigos de ISS selecionados
        aResumoISS     := MontaResumo(oMarkISS, 'SX5')
        oCodISS:SetArray(aResumoISS)
        oCodISS:Refresh(.T.)
    EndIf
EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuResumoPR()

Função que atualiza as informações nos browses de resumo do produto, pois
a construção do painel é chamada somente na primera vez, por este motivo
preciso atualizar aqui também.

@author joao.pellegrini
@since 10/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AtuResumoPR(oMarkPerfil, cTpWiz)

IF Valtype(oProduto) == "O" .And. IIf(cTpWiz == '1', Valtype(oPerfil) == "O" , .T.)

    aResumoPerfil   := {}
    aResumoProd     := {}

    //Monta array de resumo com Perfis selecionados
    If cTpWiz == '1'
        aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
        oPerfil:SetArray(aResumoPerfil)
        oPerfil:Refresh(.T.)
    EndIf

    //Monta array de resumo com UF de origem selecionadas
    aResumoProd     := MontaResumo(oMarkProd, 'SB1')
    oProduto:SetArray(aResumoProd)
    oProduto:Refresh(.T.)

EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GravarUF()

Função que faz gravação em lote dos perfis de origem e destino

@author Erick Dias
@since 08/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravarUF(cAcao, oSay , cTpWiz, oModel)

Local nPerfil   := 0
Local nUfOri    := 0
Local nUfDest   := 0
Local nQtdProc  := 0
Local nQtdTot   := 0
Local cMsg      := ''
Local lAchouF21 := .F.
Local oGrid     := Nil
Local lRet      := .T.

dbSelectArea('F21')
F21->(dbSetOrder(1))

IF cTpWiz == '1' //Wizard por "Fora"

    BEGIN TRANSACTION

        For nPerfil := 1 to len(aResumoPerfil)

            For nUfOri := 1 to Len(aResumoUfO)

                For nUfDest := 1 to Len(aResumoUfD)

                    AtualizaMsg( oSay, STR0046 + aResumoPerfil[nPerfil][1]  + STR0063 + aResumoUfO[nUfOri][1] + STR0064 + aResumoUfD[nUfDest][1] )

                    nQtdTot += 1

                    //Verifica se a informação já existe gravada
                    lAchouF21 := F21->( MsSeek ( xFilial('F21') + aResumoPerfil[nPerfil][1] + aResumoUfO[nUfOri][1] + aResumoUfD[nUfDest][1] ) )

                    IF cAcao == "1" .AND. !lAchouF21 //Inclusão e não existe ainda gravado

                        //Grava informação na tabela
                        lRet := FSA163GF21(aResumoPerfil[nPerfil][1], aResumoUfO[nUfOri][1] , aResumoUfD[nUfDest][1])
                        nQtdProc += 1

                    ElseIF cAcao == "2" .AND. lAchouF21 //Remoção e existe gravado

                        //Deleta da tabela
                        RecLock("F21",.F.)
                        F21->(dbDelete())
                        MsUnLock()
                        F21->(FkCommit())

                        nQtdProc += 1

                    EndIF

                Next

            Next nUfOri

        Next nPerfil

    END TRANSACTION

Else
    //Todo atualizar o grid
    oGrid     := oModel:GetModel("FISA163ORIGEMDESTINO")

    For nUfOri := 1 to Len(aResumoUfO)

        For nUfDest := 1 to Len(aResumoUfD)

            AtualizaMsg( oSay, STR0065 + aResumoUfO[nUfOri][1] + STR0066 + aResumoUfD[nUfDest][1] )
            nQtdTot += 1

            lAchouF21  := oGrid:SeekLine( { {"F21_UFORI", Alltrim(aResumoUfO[nUfOri][1])}, {"F21_UFDEST", Alltrim(aResumoUfD[nUfDest][1]) }} )

            IF cAcao == "1" .AND. !lAchouF21 //Inclusão e não existe ainda gravado

                //Grava informação na tabela
                oGrid:AddLine()
                //oGrid:GoLine(oGrid:Length(.T.))
                oGrid:SetValue("F21_UFORI" , Alltrim(aResumoUfO[nUfOri][1]))
                oGrid:SetValue("F21_DUFORI" , Alltrim(aResumoUfO[nUfOri][2]))
                oGrid:SetValue("F21_UFDEST" , Alltrim(aResumoUfD[nUfDest][1] ))
                oGrid:SetValue("F21_DUFDST" , Alltrim(aResumoUfD[nUfDest][2] ))
                nQtdProc += 1

            ElseIF cAcao == "2" .AND. lAchouF21 //Remoção e existe gravado

                //Deleta da tabela
                oGrid:DeleteLine()
                nQtdProc += 1

            EndIF

        Next nUfDest

    Next nUfOri

    oGrid:SetLine(1)

ENdIF

cMsg    := STR0036 + CHR(10)+CHR(13) + ; //"Processamento concluído com sucesso!"
           STR0037 + cValToChar(nQtdTot) + CHR(10)+CHR(13) + ; //"Quantidade total de registro(s) processado(s): "
           STR0039 + Iif(cAcao == '1' , STR0040 , STR0038 ) + cVAltoChar(nQtdProc ) //"Removido(s): " //"Quantidade total de registro(s) " //"Adicionado(s): "

AtualizaMsg( oSay, STR0041) //"Processamento Concluído com Sucesso!"
MsgInfo(cMsg)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaPerOp()

Função que faz gravação em lote dos perfis de origem e destino

@author Erick Dias
@since 25/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravaPerOp(cAcao, oSay , cTpWiz, oModel)

Local nPerfil   := 0
Local nPosCfop  := 0
Local nPosTpOp  := 0
Local nPosISS   := 0
Local nQtdProc  := 0
Local nQtdTot   := 0
Local cMsg      := ''
Local lAchouF23 := .F.
Local lAchouF26 := .F.
Local lAchouCIO := .F.
Local oGrid     := Nil
Local oGridTpOper := Nil
Local oGridISS  := Nil
Local lRet      := .T.

dbSelectArea('F23')
F23->(dbSetOrder(1))

IF cTpWiz == '1' //Wizard por "Fora"

    BEGIN TRANSACTION

        For nPerfil := 1 to len(aResumoPerfil)

            AtualizaMsg( oSay, STR0042 + aResumoPerfil[nPerfil][1] ) //"Processando CFOPs do Perfil: "
                
            lRet := FSA165GF23(aResumoPerfil[nPerfil][1], aResumoCFOP, cAcao, @nQtdTot, @nQtdProc,@oSay)

            lRet := FSA165GF26(aResumoPerfil[nPerfil][1], aResumoTPOP, cAcao, @nQtdTot, @nQtdProc,@oSay)

            If lAliasCIO
                lRet := FSA165GCIO(aResumoPerfil[nPerfil][1], aResumoISS, cAcao, @nQtdTot, @nQtdProc,@oSay)
            EndIf

        Next nPerfil

    END TRANSACTION

Else
    //Atualiza o Grid
    oGrid     := oModel:GetModel("FISA165CFOP")
    For nPosCfop := 1 to Len(aResumoCFOP)    
        
        AtualizaMsg( oSay,STR0043 + aResumoCFOP[nPosCfop][1] ) //"Processando CFOP: "
        nQtdTot += 1

        lAchouF23  := oGrid:SeekLine( { {"F23_CFOP", Alltrim(aResumoCFOP[nPosCfop][1])} } )

        IF cAcao == "1" .AND. !lAchouF23 //Inclusão e não existe ainda gravado

            //Grava informação na tabela
            oGrid:AddLine()
            //oGrid:GoLine(oGrid:Length(.T.))
            oGrid:SetValue("F23_CFOP" , Alltrim(aResumoCFOP[nPosCfop][1]))            
            nQtdProc += 1

        ElseIF cAcao == "2" .AND. lAchouF23 //Remoção e existe gravado

            //Deleta da tabela
            oGrid:DeleteLine()
            nQtdProc += 1

        EndIF        

    Next nPosCfop

    oGrid:SetLine(1)
    
    oGridTpOper     := oModel:GetModel("FISA165TPOPER")
    For nPosTpOp := 1 to Len(aResumoTPOP)    
        
        AtualizaMsg( oSay,STR0044 + aResumoTPOP[nPosTpOp][1] ) //"Processando Tipo de Operação: "
        nQtdTot += 1

        lAchouF26  := oGridTpOper:SeekLine( { {"F26_TPOPER", Alltrim(aResumoTPOP[nPosTpOp][1])} } )

        IF cAcao == "1" .AND. !lAchouF26 //Inclusão e não existe ainda gravado

            //Grava informação na tabela
            oGridTpOper:AddLine()
            //oGrid:GoLine(oGrid:Length(.T.))
            oGridTpOper:SetValue("F26_TPOPER" , Alltrim(aResumoTPOP[nPosTpOp][1]))            
            nQtdProc += 1

        ElseIF cAcao == "2" .AND. lAchouF26 //Remoção e existe gravado

            //Deleta da tabela
            oGridTpOper:DeleteLine()
            nQtdProc += 1

        EndIF        

    Next nPosTpOp

    oGridTpOper:SetLine(1)

    //Gravar o código de Serviço
    If lAliasCIO
        oGridISS     := oModel:GetModel("FISA165CDSERV")
        For nPosISS := 1 to Len(aResumoISS)    
            
            AtualizaMsg( oSay,STR0069 + aResumoISS[nPosISS][1] )//"Processando Código de Serviço: "
            nQtdTot += 1

            lAchouCIO  := oGridISS:SeekLine( { {"CIO_CODISS", Alltrim(aResumoISS[nPosISS][1])} } )

            IF cAcao == "1" .AND. !lAchouCIO //Inclusão e não existe ainda gravado

                //Grava informação na tabela
                oGridISS:AddLine()
                oGridISS:SetValue("CIO_CODISS" , Alltrim(aResumoISS[nPosISS][1]))            
                nQtdProc += 1

            ElseIF cAcao == "2" .AND. lAchouCIO //Remoção e existe gravado

                //Deleta da tabela
                oGridISS:DeleteLine()
                nQtdProc += 1

            EndIF        

        Next nPosISS

        oGridISS:SetLine(1)
    EndIf

ENdIF

cMsg    := STR0036 + CHR(10)+CHR(13) + ; //"Processamento concluído com sucesso!"
           STR0037 + cValToChar(nQtdTot) + CHR(10)+CHR(13) + ; //"Quantidade total de registro(s) processado(s): "
           STR0039 + Iif(cAcao == '1' , STR0040 , STR0038 ) + cVAltoChar(nQtdProc ) //"Adicionado(s): " //"Removido(s): " //"Quantidade total de registro(s) "

AtualizaMsg( oSay, STR0041) //"Processamento Concluído com Sucesso!"
MsgInfo(cMsg)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GravarProd()

Função que faz gravação em lote dos perfis de produto

@author joao.pellegrini
@since 17/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravarProd(cAcao, oSay, cTpWiz, oModel)

Local nPerfil   := 0
Local nQtdProc  := 0
Local nQtdTot   := 0
Local nProd      := 0
Local cMsg      := ''
Local lAchouF24 := .F.
Local oGrid     := Nil

dbSelectArea('F24')
F24->(dbSetOrder(1))

IF cTpWiz == '1' //Wizard por "Fora"

    BEGIN TRANSACTION

        For nPerfil := 1 to len(aResumoPerfil)

            For nProd := 1 to Len(aResumoProd)

                AtualizaMsg( oSay, STR0046 + aResumoPerfil[nPerfil][1]  + STR0045 + aResumoProd[nProd][2] ) //" , Produto: " //"Processando perfil: "

                nQtdTot += 1

                //Verifica se a informação já existe gravada
                lAchouF24 := F24->( MsSeek ( xFilial('F24') + aResumoPerfil[nPerfil][1] + aResumoProd[nProd][1] ) )

                IF cAcao == "1" .AND. !lAchouF24 //Inclusão e não existe ainda gravado

                    //Grava informação na tabela
                    FSA166GF24(aResumoPerfil[nPerfil][1], "INCLUI", aResumoProd[nProd][1])
                    nQtdProc += 1

                ElseIF cAcao == "2" .AND. lAchouF24 //Remoção e existe gravado

                    //Deleta da tabela
                    RecLock("F24",.F.)
                    F24->(dbDelete())
                    MsUnLock()
                    F24->(FkCommit())
                    nQtdProc += 1

                EndIF

            Next nProd

        Next nPerfil

    END TRANSACTION

Else
    //Todo atualizar o grid
    oGrid := oModel:GetModel("FISA166PRODUTO")

    For nProd := 1 to Len(aResumoProd)

        AtualizaMsg( oSay, STR0047 + aResumoProd[nProd][2] ) //"Processando Produto: "
        nQtdTot += 1

        lAchouF24  := oGrid:SeekLine( { {"F24_CDPROD", aResumoProd[nProd][1] } } )

        IF cAcao == "1" .AND. !lAchouF24 //Inclusão e não existe ainda gravado

            //Grava informação na tabela
            oGrid:AddLine()
            oGrid:SetValue("F24_CDPROD" , Alltrim(aResumoProd[nProd][1]))
            oGrid:SetValue("F24_DSPROD" , Alltrim(aResumoProd[nProd][2]))
            nQtdProc += 1

        ElseIF cAcao == "2" .AND. lAchouF24 //Remoção e existe gravado

            //Deleta da tabela
            oGrid:DeleteLine()
            nQtdProc += 1

        EndIF

    Next nProd

    oGrid:SetLine(1)

ENdIF

cMsg    := STR0036 + CHR(10)+CHR(13) + ; //"Processamento concluído com sucesso!"
           STR0037 + cValToChar(nQtdTot) + CHR(10)+CHR(13) + ; //"Quantidade total de registro(s) processado(s): "
           STR0039 + Iif(cAcao == '1' , STR0040 , STR0038 ) + cVAltoChar(nQtdProc ) //"Removido(s): " //"Quantidade total de registro(s) " //"Adicionado(s): "

AtualizaMsg( oSay, STR0041) //"Processamento Concluído com Sucesso!"
MsgInfo(cMsg)

Return .T.

//------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Erick G. Dias
@since 08/08/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function AtualizaMsg( oSay, cMsg )

oSay:cCaption := (cMsg)
ProcessMessages()

Return

//------------------------------------------------------------------
/*/{Protheus.doc} SelProduto

Função responsável por montar o painel de seleção de produtos.

@author joao.pellegrini
@since 09/08/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function SelProduto(oPanel, cAcao)

Local oLayer     := NIL
Local aColumns   := {}
Local aParamQry  := {}
Local oPanel1      := NIL
Local oPanel2      := NIL
Local oPanel3      := NIL
Local aCampos    := {}
Local cQuery     := ""
Local cAliasSB1  := GetNextAlias()
Local oSayTitulo := NIL
Local cAliasMark := oMarkOriPr:cAlias

oLayer := FWLayer():New()
oLayer:Init(oPanel, .F.)
oLayer:AddLine('LIN1', 10, .F.)
oLayer:AddLine('LIN2', 90, .F.)

oPanel1 := oLayer:getLinePanel('LIN1')
oPanel2 := oLayer:getLinePanel('LIN2')

oLayer:addCollumn('COL1',100,.F.,'LIN2')
oLayer:AddWindow('COL1','W1',STR0048,100,.F.,.F.,,'LIN2') //"Produtos"
oPanel3 := oLayer:getWinPanel('COL1','W1','LIN2')

// Adicionando SAY de título
oSayTitulo := TSay():New(5,5,{||STR0049 + Iif(cAcao == '1' ,STR0051 , STR0052) + STR0050},oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //"Selecione os produtos que serão "
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

// Lista de parâmetros para a query
aParamQry := {cCodPrDe, cCodPrAte, cNcmDe, cNcmAte, cTpProd, cGrTrib, GetOrigens(), cCestDe, cCestAte, cGrpDe, cGrpAt}

//Chama função para montar query e array com os campos do Header
cQuery := FSA171QRY("SB1", aParamQry, @aCampos)

//Chama função para montar as colunas do aHeader
aColumns := HeaderMark(aCampos)

//Criando o Browse
oMarkProd := AddMarkBro(oPanel3, @lAllProd, aCampos, aColumns, cQuery, cAliasSB1)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} SelCliente

Função responsável por montar a tela de seleção dos clientes

@author Erick G Dias
@since 10/08/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function SelCliente(oPanel, cAcao, oMarkPerfil)

Local oLCli         := FWLayer():new()
Local aCampos       := {}
Local aColumns      := {}
Local aParamQry     := {}
Local cQuery        := ""
Local cAlsCliente   := GetNextAlias()
Local oPanel1       := NIL
Local oPanel2       := NIL
Local oPanel3       := NIL
Local oSayTitulo    := NIL
Local cCodF20       := ""
Local oModel        := Nil

Default oMarkPerfil := Nil

If ValType(oMarkPerfil) == "O"
    cCodF20  := MontaResumo(oMarkPerfil, 'F20')[1,1]
Else
    oModel   := FwModelActive()
    cCodF20  := oModel:GetValue("FISA164","F20_CODIGO")
EndIf

//Cria Layer
oLCli:Init(oPanel,.F.)

// Adicionando linhas
oLCli:AddLine('L1',10,.F.)
oLCli:AddLine('L2',90,.F.)
oPanel1 := oLCli:getLinePanel('L1')
oPanel2 := oLCli:getLinePanel('L2')

//Adicionando colunas
oLCli:addCollumn('C1',100,.F.,'L2')

//Adicionando Window
oLCli:AddWindow('C1','W1',STR0053,100,.F.,.F.,,'L2') //"Clientes"
oPanel3 := oLCli:getWinPanel('C1','W1','L2')

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0055 + Iif(cAcao == '1' ,STR0051 , STR0052) + STR0054},oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //'ADICIONADOS ao(s)'
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//Chama função para montar query e array com os campos do Header
aParamQry := {Substr(cA1Pessoa,1,1), Substr(cA1Tipo,1,1), Substr(cA1TPessoa,1,2), Substr(cA1SimpNac,1,1), Substr(cA1Contrib,1,1), cA1GrpTrib, cA1Estado, cA1GrpVen, cA1Mun}
cQuery := FSA171QRY("SA1", aParamQry, @aCampos, , ,cCodF20, cAcao)

//Chama função para montar as colunas do aHeader
aColumns  := HeaderMark(aCampos)

//Chama função para montar o browse para seleção dos clientes
oMarkCli := AddMarkBro(oPanel3, @lAllCLi, aCampos, aColumns, cQuery, cAlsCliente)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuQryBro()

Função que refaz o MarkBorwse considerando alteração dos campos de filtros

@author Erick G Dias
@since 10/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AtuQryBro(oPanel, cAcao, oObjMark, cConstrutor,oMarkPerfil)

Local aParamQry     := {}
Local cQuery          := ''
Local cAliasTab     := GetNextAlias()
Local lRefreshMArk  := .F.
Local cCodF20       := ""

DEFAULT oMarkPerfil := Nil

IF Valtype(oMarkPerfil) == "O"
    cCodF20 := MontaResumo(oMarkPerfil, 'F20')[1,1]
EndIf

//Verifico se objeto de seleção do cliente já foi criado, se sim farei novamente, caso contrário deixarei ele ser criado da primeira vez
IF Valtype(oObjMark) == "O"

    If Select(oObjMark:cAlias) > 0
        dbSelectArea(oObjMark:cAlias)
        dbCloseArea()
    EndIF

    If cConstrutor == 'CLIENTE'
        aParamQry := {Substr(cA1Pessoa,1,1), Substr(cA1Tipo,1,1), Substr(cA1TPessoa,1,2), Substr(cA1SimpNac,1,1), Substr(cA1Contrib,1,1), cA1GrpTrib, cA1Estado, cA1GrpVen, cA1Mun}
        cQuery := FSA171QRY("SA1", aParamQry, , , , cCodF20, cAcao)
        lRefreshMArk    := .T.
    ElseIf cConstrutor == 'PRODUTO'
        aParamQry := {cCodPrDe, cCodPrAte, cNcmDe, cNcmAte, cTpProd, cGrTrib, GetOrigens(), cCestDe, cCestAte, cGrpDe, cGrpAt}
        cQuery := FSA171QRY("SB1", aParamQry, , , , cCodF20)
        lRefreshMArk    := .T.
    ElseIf cConstrutor == 'FORNECEDOR'
        aParamQry := {Substr(cA2Tipo,1,1), cA2Estado, cA2GrpTrib, Substr(cA2SimpNac,1,1), Substr(cA2Contrib,1,1), cA2Mun}
        cQuery := FSA171QRY("SA2", aParamQry, , , , cCodF20, cAcao)
        lRefreshMArk    := .T.
    EndIF

    If lRefreshMArk
        oObjMark:SetQuery(cQuery)
        oObjMark:SetAlias(cAliasTab)
        oObjMark:Refresh(,.T.)
        oObjMark:Refresh(,.T.)
        oObjMark:GoTop()
    EndIF

EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ResumoCli()

Função que monta a tela de resumo do cliente

@author Erick Dias
@since 10/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ResumoCli(oPanel,oMarkPerfil,cAcao, cTpWiz)

Local oLayer       := FWLayer():new()
Local aCampos      := {}
Local aCmpPerfil   := {}
Local aColsUF      := {}
Local aColPerfil   := {}
Local cQuery       := ""
Local cAls         := ""
Local cAliasOri    := GetNextAlias()
Local cAliasDest   := GetNextAlias()
Local oSayTitulo   := NIL
Local oPanel1      := NIL
Local oPanel2      := NIL
Local oPanel3      := NIL
Local oPanel4      := NIL

//Criando a Layer
oLayer:Init(oPanel,.F.)

IF cTpWiz == '1' //Facilitador por fora
    // Adicionando linhas
    oLayer:AddLine('L1',10,.F.)
    oLayer:AddLine('L2',40,.F.)
    oLayer:AddLine('L3',50,.F.)
    oPanel1 := oLayer:getLinePanel('L1')
    oPanel2 := oLayer:getLinePanel('L2')
    oPanel3 := oLayer:getLinePanel('L3')
    //Adicionando colunas
    oLayer:addCollumn('C1',100,.F.,'L3')
    //Adicionando Window
    oLayer:AddWindow('C1','W1',STR0053,100,.F.,.F.,,'L3') //"Clientes"
    //Painel para resumo de cliente
    oPanel4 := oLayer:getWinPanel('C1','W1','L3')
Else
    // Adicionando linhas
    oLayer:AddLine('L1',10,.F.)
    oLayer:AddLine('L2',90,.F.)
    oPanel1 := oLayer:getLinePanel('L1')
    oPanel2 := oLayer:getLinePanel('L2')
    //Adicionando colunas
    oLayer:addCollumn('C1',100,.F.,'L2')
    //Adicionando Window
    oLayer:AddWindow('C1','W1',STR0053,100,.F.,.F.,,'L2') //"Clientes"
    //Painel para resumo de cliente
    oPanel4 := oLayer:getWinPanel('C1','W1','L2')
EndIF

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0035 + Iif(cAcao == '1' ,STR0033 , STR0034) },oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //'ADICIONADAS'
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//Monta os campos dos perfis
IF cTpWiz == '1'
    aCmpPerfil  := CamposBrw('aResumoPerfil', 'oPerfil','F20')
EndIF

//Monta os campos do cliente
aCmpCli  := CamposBrw('aResumoCLi', 'oCliente', 'SA1')

//Monta o cabeçalho dos perfis
IF cTpWiz == '1'
    aColPerfil  := HeaderMark(aCmpPerfil, .F.)
EndIF

aColsCLi    := HeaderMark(aCmpCli, .F.)

//Monta array de resumo com Perfis selecionados
IF cTpWiz == '1'
    aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
EndIF

//Monta array de resumo dos clientes selecionados
aResumoCLi  := MontaResumo(oMarkCli, 'SA1')

//Browse de perfil
IF cTpWiz == '1'
    ADDBrwResumo(@oPerfil, aColPerfil, aResumoPerfil, oPanel2)
EndIF

//Browse de cliente
ADDBrwResumo(@oCliente, aColsCLi, aResumoCLi, oPanel4)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuResumoCli()

Função que atualiza o resumo dos clientes

@author Erick Dias
@since 10/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AtuResumoCli(oMarkPerfil, cTpWiz)

//Somente terá ação se os objetos abaixo existirem
IF Valtype(oCliente) == "O" .And. IIf(cTpWiz == '1', Valtype(oPerfil) == "O" , .T.)

    aResumoPerfil   := {}
    aResumoCLi      := {}

    //Monta array de resumo com Perfis selecionados
    If cTpWiz == '1'
        aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
        oPerfil:SetArray(aResumoPerfil)
        oPerfil:Refresh(.T.)
    EndIf

    //Monta array de resumo com UF de origem selecionadas
    aResumoCLi  := MontaResumo(oMarkCli, 'SA1')
    oCliente:SetArray(aResumoCLi)
    oCliente:Refresh(.T.)

EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GravarCli()

Função que faz gravação em lote dos clientes

@author Erick Dias
@since 10/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravarCli(cAcao, oSay, cTpWiz, oModel)

Local nPerfil   := 0
Local nQtdProc  := 0
Local nQtdTot   := 0
Local nCli      := 0
Local cMsg      := ''
Local lAchouF22 := .F.
Local oGrid     := Nil
Local cFilF22   := xFilial("F22")
Local cTabF22   := RetSqlName("F22")
Local lF22Tipo  := F22->(Fieldpos("F22_TIPOPF")) > 0
Local cSGBD		:= AllTrim(Upper(TcGetDb()))// Tipo do banco de dados
Local lForce    := .F.
Local nTamResCli:= 0
Local nTamResPar:= 0
Local cCodF22   := ""
Local nF22Recno := 0
Local oView     := Nil
Local aStatement:= {}
Local nOperation:= 0
Local cDescri   := ""

dbSelectArea('F22')
F22->(dbSetOrder(1))

nTamResCli := Len(aResumoCLi)

If cAcao == '1'
    nF22Recno := GetF22Recno( cSGBD )
EndIf

IF cTpWiz == '1' //Wizard por "Fora"

    BEGIN TRANSACTION

        nTamResPar := Len(aResumoPerfil)

        For nPerfil := 1 to nTamResPar

            cCodF22   := aResumoPerfil[nPerfil][1]

            For nCli := 1 to nTamResCli

                AtualizaMsg( oSay, STR0046 + aResumoPerfil[nPerfil][1]  + STR0057 + aResumoCLi[nCli][1]+ STR0056 + aResumoCLi[nCli][2] ) //"Processando perfil: "
                nQtdTot += 1
                If cAcao == "2"
                    lAchouF22  := F22->( MsSeek ( xFilial('F22') + aResumoPerfil[nPerfil][1] + "2" + aResumoCLi[nCli][1] + aResumoCLi[nCli][2] ) )
                EndIf

                IF cAcao == "1" //Inclusão

                    aStatement := {}
                    aAdd(aStatement,cFilF22)                //F22_FILIAL
                    aAdd(aStatement,cCodF22)                //F22_CODIGO
                    aAdd(aStatement,'2')                    //F22_TPPART
                    aAdd(aStatement,aResumoCLi[nCli][1])    //F22_CLIFOR
                    aAdd(aStatement,aResumoCLi[nCli][2])    //F22_LOJA
                    aAdd(aStatement,cValToChar(nF22Recno))  //R_E_C_N_O_
                    IF lF22Tipo
                        aAdd(aStatement,'02')               //F22_TIPOPF
                    EndIf

                    If nCli == nTamResCli
                        lForce := .T.
                    EndIf

                    GrvF22Regs(aStatement, cTabF22, lF22Tipo, lForce, cSGBD)

                    nF22Recno++
                    nQtdProc++

                ElseIF cAcao == "2" .And. lAchouF22 //Remoção 

                    //Deleta da tabela
                    RecLock("F22",.F.)
                    F22->(dbDelete())
                    MsUnLock()
                    F22->(FkCommit())
                    nQtdProc += 1

                EndIF

            Next nCli

        Next nPerfil

    END TRANSACTION

Else
    cCodF22   := oModel:GetValue("FISA164","F20_CODIGO")

    //Todo atualizar o grid
    oGrid      := oModel:GetModel("FISA164PARTICIPANTE")
    oView      := FwViewActive()
    nOperation := oModel:GetOperation()

    BEGIN TRANSACTION

        For nCli := 1 to nTamResCli

            AtualizaMsg( oSay, STR0058 + aResumoCLi[nCli][1]+ STR0056 + aResumoCLi[nCli][2] ) //" , Loja: "
            nQtdTot += 1
            If cAcao == "2"
                lAchouF22  := oGrid:SeekLine( { {"F22_TPPART", "2" }, {"F22_CLIFOR", aResumoCLi[nCli][1]}, {"F22_LOJA", aResumoCLi[nCli][2] } } )
            EndIf

            IF cAcao == "1" 

                aStatement := {}
                aAdd(aStatement,cFilF22)                //F22_FILIAL
                aAdd(aStatement,cCodF22)                //F22_CODIGO
                aAdd(aStatement,'2')                    //F22_TPPART
                aAdd(aStatement,aResumoCLi[nCli][1])    //F22_CLIFOR
                aAdd(aStatement,aResumoCLi[nCli][2])    //F22_LOJA
                aAdd(aStatement,cValToChar(nF22Recno))  //R_E_C_N_O_
                IF lF22Tipo
                    aAdd(aStatement,'02')               //F22_TIPOPF
                EndIf

                If nCli == nTamResCli
                    lForce := .T.
                EndIf

                GrvF22Regs( aStatement, cTabF22, lF22Tipo, lForce, cSGBD)

                nF22Recno++
                nQtdProc++

            ElseIF cAcao == "2" .And. lAchouF22 //Remoção e existe gravado

                //Deleta da tabela
                oGrid:DeleteLine()
                nQtdProc += 1

            EndIF
        Next nCli

        FwFormCommit(oModel)

    END TRANSACTION
    oGrid:SetLine(1)

ENdIF

If cTpWiz = '2' .And. cAcao == "1" .And. nQtdProc > 0

    oView:Deactivate()

    If nOperation == MODEL_OPERATION_INSERT //Forço operação de atualização
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
    EndIf
    AtualizaMsg( oSay, "Aguarde, atualizando os dados inseridos...")
    oView:Activate()
                
    //Forço atualização de campo pro MVC entender que o formulário sofreu alterações e pode ser salvo
    cDescri := oModel:GetValue("FISA164","F20_CODIGO")
    oModel:LoadValue("FISA164","F20_CODIGO","")
    oModel:LoadValue("FISA164","F20_CODIGO",cDescri)

EndIf

cMsg    :=  STR0036 + CHR(10)+CHR(13) + ; //"Processamento concluído com sucesso!"
            STR0037 + cValToChar(nQtdTot) + CHR(10)+CHR(13) + ; //"Quantidade total de registro(s) processado(s): "
            STR0039 + Iif(cAcao == '1' , STR0040 , STR0038 ) + cVAltoChar(nQtdProc )  //"Removido(s): "

AtualizaMsg( oSay, STR0041) //"Processamento Concluído com Sucesso!"
MsgInfo(cMsg)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvF22Regs
@description Efetua o processo de gravação em lote da tabela F22

@author leandro.faggyas
@since 17/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function GrvF22Regs(aStatement, cTabF22, lF22Tipo, lForce, cSGBD)
Local nTamInsert  := 1000 //Tamanho maximo de linhas por Insert
Local cCampos     := ""
Local nX          := 0
Local cStatement  := ""

Default lForce 	  := .F.	

cCampos := F22QryCpo(lF22Tipo)

cStatement := " ("
For nX := 1 to Len(aStatement)
    cStatement += ValToSQL(aStatement[nX])
    If nX <> Len(aStatement)
        cStatement += ","
    EndIf
Next nX
cStatement += ") "

If !Empty(cStatement) 
    if cSGBD $ "ORACLE" //Para o Oracle, o comando de insert de multiplas linhas é diferente, por isso o tratamento abaixo. 
        SetInsQry(cQryInsert + " INTO " + cTabF22 + cCampos + " VALUES " + cStatement + CHR(13) + CHR(10))
    else
        SetInsQry(cQryInsert + cStatement + ",")
    endif
    __nCountIns  += 1
Else
    __nCountIns	 := 0		
EndIf

If (__nCountIns >= nTamInsert) .Or. lForce
    CommitInsQry(cTabF22, cSGBD, lF22Tipo)  //Descarrega todos os dados a serem inseridos na TemporaryTable
    __nCountIns := 0                        //Reseto o contador de inserção de registros
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetF22Recno
@description Obtem o próximo RECNO disponível para gravação da F22.

@author leandro.faggyas
@since 17/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function GetF22Recno( cSGBD )
Local cAliasQry := GetNextAlias() 
Local nRet      := 0

Local cSelect	:= " SELECT "
Local cFrom	    := " FROM "
Local cWhere	:= "  "
Local cOrderBy  := " ORDER BY R_E_C_N_O_ DESC "
Local cQuery    := ""

local oStatement

//Query filtrando filial e regra
If cSGBD $ "INFORMIX|ORACLE|DB2|OPENEDGE|POSTGRES|"
    cSelect += " R_E_C_N_O_ RECNOF22 "
Else
    cSelect += " TOP 1 R_E_C_N_O_ RECNOF22"
EndIf

cFrom   += RetSQLName("F22") + " F22 "

If cSGBD == "ORACLE"
    cWhere := "WHERE ROWNUM <= 1"
EndIf

If cSGBD $ "POSTGRES"
    cOrderBy += " LIMIT 1 "
EndIf

cQuery := cSelect+cFrom+cWhere+cOrderBy


//Prepara classe para query
oStatement := FWPreparedStatement():New(ChangeQuery(cQuery))
cQuery 	   := oStatement:GetFixQuery()
MPSysOpenQuery(cQuery, cAliasQry)	

If (cAliasQry)->(!Eof())
    nRet := (cAliasQry)->RECNOF22 + 1
EndIf

(cAliasQry)->(DbCloseArea())

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTamIns
@description Retorna o tamanho da variavel cQryInsert para o caso de inserção em Lote.

@author leandro.faggyas
@since 17/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function GetTamIns()
Return Len(cQryInsert)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTamIns
@description Função que grava uma string na variavel static cQryInsert.

@author leandro.faggyas
@since 17/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function SetInsQry(cQry)
Return cQryInsert := cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} GetInsQry
@description Função que retorna a string na variavel static cQryInsert.

@author leandro.faggyas
@since 17/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function GetInsQry()
Return cQryInsert

//-------------------------------------------------------------------
/*/{Protheus.doc} GetInsInic
@description Formata o início da query de acordo com o banco de dados utilizado.

@author leandro.faggyas
@since 17/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Static Function GetInsInic(cTabela, cSGBD,lF22Tipo)
Local cRet    := ""
Local cCampos := ""

cCampos := F22QryCpo(lF22Tipo)

If cSGBD $ "ORACLE" //Para o Oracle, o inicio do comando do insert com multiplas linhas.
    cRet:="BEGIN INSERT ALL "+ CHR(13) + CHR(10)
Else
    cRet:=" INSERT INTO " + cTabela + cCampos + " VALUES "
Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F22QryCpo
@description Retorna os campos que serão atualizados pelo Insert

@author leandro.faggyas
@since 17/11/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------

Static Function F22QryCpo(lF22Tipo)
Local cRet := ""

cRet := " (F22_FILIAL, F22_CODIGO, F22_TPPART, F22_CLIFOR, F22_LOJA, R_E_C_N_O_"
If lF22Tipo
   cRet += ", F22_TIPOPF"
EndIf
cRet += ") "

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CommitInsQry
@description Efetua a execução do insert, gravando os dados na tabela.

@author leandro.faggyas
@since 12/03/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function CommitInsQry( cTabela, cSGBD, lF22Tipo )
Local cStatement
Local lOracle	:= cSGBD $ "ORACLE"

	If !Empty(cQryInsert) // Só entro se tiver query

		If !lOracle  //Para o Oracle, não precisa retirar o último digito pois não terá , no fim do texto. 
			SetInsQry(Subs(cQryInsert, 1, Len(cQryInsert)-1))	
		EndIf

		cStatement := GetInsInic(cTabela, cSGBD, lF22Tipo)
		cStatement += GetInsQry() 
		
		If lOracle //Para o Oracle, para fechar o comando do insert com multiplas linhas.
			cStatement+= CHR(13) + CHR(10)+" SELECT 1 FROM DUAL; END;" + CHR(13) + CHR(10)
		Else
			cStatement+= ";" + CHR(13) + CHR(10)
		Endif

		If (TCSqlExec(cStatement)) >= 0
			SetInsQry("")

			If lOracle
				TcSqlExec("COMMIT")
			EndIf

			TCRefresh(cTabela)
		Else
			conout("CONFIGURADOR DE TRIBUTOS - Erro ao inserir dados na tabela " + cTabela + " via rotina CommitInsQry() - TCSQLError() : " + TCSQLError())
		EndIf		
	EndIf	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetOrigens()

Função que retorna atualizada a lista de origens selecionadas

@author Erick Dias
@since 10/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GetOrigens()

Local cAliasMark  := oMarkOriPr:cAlias
Local cOrigens    := ""

// Concatenando as origens selecionadas no mark de origens
(cAliasMark)->(dbGoTop())
While !(cAliasMark)->(Eof())
    If (cAliasMark)->OK == 1
        cOrigens += AllTrim((cAliasMark)->X5_CHAVE) + "|"
    EndIf
    (cAliasMark)->(dbSkip())
EndDo
(cAliasMark)->(dbGoTop())

oMarkOriPr:Refresh(,.T.)
oMarkOriPr:Refresh(,.T.)

Return cOrigens


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA171FOR()

Função que monta a tela dos filtros do fornecedor

@author Erick Dias
@since 10/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function FSA171FOR(oPanel)

Local oLayer  := FWLayer():New()
Local oPanel0 := NIL
Local oPanel1 := NIL
Local aFields := {}
Local aEstrut := {}

PRIVATE oGetsFor  := NIL

//Criando duas linhas
oLayer:Init(oPanel,.F.)
oLayer:AddLine('LIN0', 10, .F.)
oLayer:AddLine('LIN1', 90, .F.)

oPanel0 := oLayer:getLinePanel('LIN0')
oPanel1 := oLayer:getLinePanel('LIN1')

// Título da página
oSayTitulo := TSay():New(5,5,{||STR0041},oPanel0,,oFont18,,,,.T.,,,(oPanel0:nWidth / 2) - 10,(oPanel0:nHeight / 2) - 10) // "Preencha os filtros abaixo para selecionar os fornecedores que serão adicionados ou removidos do(s) perfil(is)"
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

// Montagem da MsMGet
aEstrut := MontaEstrut('SA2')
aEval(aEstrut, {|x| aAdd(aFields, x[2])})
oGetsFor := MsmGet():New(,,3,,,,aFields,{0,3,(oPanel1:nClientHeight-4)/2,(oPanel1:nClientWidth/2)-5},,,,,,oPanel1,,,.T.,,,.T.,aEstrut,,,,,.T.)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} SelFornecedor

Função responsável por montar a tela de seleção dos fornecedores

@author Erick G Dias
@since 10/08/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function SelFornecedor(oPanel, cAcao,  oMarkPerfil)

Local oLCli           := FWLayer():new()
Local aCampos         := {}
Local aColumns        := {}
Local aParamQry       := {}
Local cQuery          := ""
Local cAlsFornecedor  := GetNextAlias()
Local oPanel1         := NIL
Local oPanel2         := NIL
Local oPanel3         := NIL
Local oSayTitulo      := NIL
Local cCodF20         := ""
Local oModel          := Nil

Default oMarkPerfil   := Nil

If ValType(oMarkPerfil) == "O"
    cCodF20  := MontaResumo(oMarkPerfil, 'F20')[1,1]
Else
    oModel := FwModelActive()
    cCodF20  := oModel:GetValue("FISA164","F20_CODIGO")
EndIf

//Cria Layer
oLCli:Init(oPanel,.F.)

// Adicionando linhas
oLCli:AddLine('L1',10,.F.)
oLCli:AddLine('L2',90,.F.)
oPanel1 := oLCli:getLinePanel('L1')
oPanel2 := oLCli:getLinePanel('L2')

//Adicionando colunas
oLCli:addCollumn('C1',100,.F.,'L2')

//Adicionando Window
oLCli:AddWindow('C1','W1',STR0059,100,.F.,.F.,,'L2') //"Fornecedores"
oPanel3 := oLCli:getWinPanel('C1','W1','L2')

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0060 + Iif(cAcao == '1' ,STR0051 , STR0052) + STR0054},oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //'ADICIONADOS ao(s)'
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//Chama função para montar query e array com os campos do Header
aParamQry := {Substr(cA2Tipo,1,1), cA2Estado, cA2GrpTrib, Substr(cA2SimpNac,1,1), Substr(cA2Contrib,1,1),cA2Mun}
cQuery := FSA171QRY("SA2", aParamQry, @aCampos, , , cCodF20, cAcao)

//Chama função para montar as colunas do aHeader
aColumns  := HeaderMark(aCampos)

//Chama função para montar o browse para seleção dos Fornecedores
oMarkFor := AddMarkBro(oPanel3, @lAllFor, aCampos, aColumns, cQuery, cAlsFornecedor)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuResumoFor()

Função que atualiza o resumo dos clientes

@author Erick Dias
@since 10/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AtuResumoFor(oMarkPerfil, cTpWiz)

//Somente terá ação se os objetos abaixo existirem
IF Valtype(oFornecedor) == "O" .And. IIf(cTpWiz == '1', Valtype(oPerfil) == "O" , .T.)

    aResumoPerfil   := {}
    aResumoFor      := {}

    //Monta array de resumo com Perfis selecionados
    If cTpWiz == '1'
        aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
        oPerfil:SetArray(aResumoPerfil)
        oPerfil:Refresh(.T.)
    EndIf

    //Monta array de resumo com UF de origem selecionadas
    aResumoFor  := MontaResumo(oMarkFor, 'SA2')
    oFornecedor:SetArray(aResumoFor)
    oFornecedor:Refresh(.T.)

EndIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ResumoFor()

Função que monta a tela de resumo do cliente

@author Erick Dias
@since 10/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ResumoFor(oPanel,oMarkPerfil,cAcao, cTpWiz)

Local oLayer       := FWLayer():new()
Local aCampos      := {}
Local aCmpPerfil   := {}
Local aColsUF      := {}
Local aColPerfil   := {}
Local cQuery       := ""
Local cAls         := ""
Local cAliasOri    := GetNextAlias()
Local cAliasDest   := GetNextAlias()
Local oSayTitulo   := NIL
Local oPanel1      := NIL
Local oPanel2      := NIL
Local oPanel3      := NIL
Local oPanel4      := NIL

//Criando a Layer
oLayer:Init(oPanel,.F.)

IF cTpWiz == '1' //Facilitador por fora
    // Adicionando linhas
    oLayer:AddLine('L1',10,.F.)
    oLayer:AddLine('L2',40,.F.)
    oLayer:AddLine('L3',50,.F.)
    oPanel1 := oLayer:getLinePanel('L1')
    oPanel2 := oLayer:getLinePanel('L2')
    oPanel3 := oLayer:getLinePanel('L3')
    //Adicionando colunas
    oLayer:addCollumn('C1',100,.F.,'L3')
    //Adicionando Window
    oLayer:AddWindow('C1','W1',STR0059,100,.F.,.F.,,'L3') //"Fornecedores"
    //Painel para resumo de cliente
    oPanel4 := oLayer:getWinPanel('C1','W1','L3')
Else
    // Adicionando linhas
    oLayer:AddLine('L1',10,.F.)
    oLayer:AddLine('L2',90,.F.)
    oPanel1 := oLayer:getLinePanel('L1')
    oPanel2 := oLayer:getLinePanel('L2')
    //Adicionando colunas
    oLayer:addCollumn('C1',100,.F.,'L2')
    //Adicionando Window
    oLayer:AddWindow('C1','W1',STR0059,100,.F.,.F.,,'L2') //"Fornecedores"
    //Painel para resumo de cliente
    oPanel4 := oLayer:getWinPanel('C1','W1','L2')
EndIF

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0035 + Iif(cAcao == '1' ,STR0033 , STR0034) },oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10) //'ADICIONADAS'
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//Monta os campos dos perfis
IF cTpWiz == '1'
    aCmpPerfil  := CamposBrw('aResumoPerfil', 'oPerfil','F20')
EndIF

//Monta os campos do cliente
aCmpFOr  := CamposBrw('aResumoFor', 'oFornecedor', 'SA2')

//Monta o cabeçalho dos perfis
IF cTpWiz == '1'
    aColPerfil  := HeaderMark(aCmpPerfil, .F.)
EndIF

aColsFor    := HeaderMark(aCmpFor, .F.)

//Monta array de resumo com Perfis selecionados
IF cTpWiz == '1'
    aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
EndIF

//Monta array de resumo dos clientes selecionados
aResumoFor  := MontaResumo(oMarkFor, 'SA2')

//Browse de perfil
IF cTpWiz == '1'
    ADDBrwResumo(@oPerfil, aColPerfil, aResumoPerfil, oPanel2)
EndIF

//Browse de cliente
ADDBrwResumo(@oFornecedor, aColsFor, aResumoFor, oPanel4)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GravarFor()

Função que faz gravação em lote dos clientes

@author Erick Dias
@since 10/08/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GravarFor(cAcao, oSay, cTpWiz, oModel)

Local nPerfil    := 0
Local nQtdProc   := 0
Local nQtdTot    := 0
Local nFor       := 0
Local cMsg       := ''
Local lAchouF22  := .F.
Local oGrid      := Nil
Local aStatement := {}
Local cFilF22    := xFilial("F22")
Local cCodF22    := ""
Local lF22Tipo   := F22->(Fieldpos("F22_TIPOPF")) > 0
Local cTabF22    := RetSqlName("F22")
Local lForce     := .F.
Local cSGBD		 := AllTrim(Upper(TcGetDb()))// Tipo do banco de dados
Local nF22Recno  := 0
Local nTamResFor := 0
Local cDescri    := ""
Local nOperation := 0

dbSelectArea('F22')
F22->(dbSetOrder(1))

nTamResFor := Len(aResumoFor)

If cAcao == '1'
    nF22Recno := GetF22Recno( cSGBD )
EndIf

IF cTpWiz == '1' //Wizard por "Fora"

    BEGIN TRANSACTION

        For nPerfil := 1 to len(aResumoPerfil)

            cCodF22 := aResumoPerfil[nPerfil][1]

            For nFOr := 1 to nTamResFor

                AtualizaMsg( oSay, STR0046 + aResumoPerfil[nPerfil][1]  + STR0061 + aResumoFor[nFOr][1] + STR0056 + aResumoFor[nFOr][2] ) //"Processando perfil: "
                nQtdTot += 1
                If cAcao == "2"
                    lAchouF22  := F22->( MsSeek ( xFilial('F22') + aResumoPerfil[nPerfil][1] + "1" + aResumoFor[nFOr][1] + aResumoFor[nFOr][2] ) )
                EndIf

                IF cAcao == "1" //Inclusão

                    aStatement := {}
                    aAdd(aStatement,cFilF22)                //F22_FILIAL
                    aAdd(aStatement,cCodF22)                //F22_CODIGO
                    aAdd(aStatement,'1')                    //F22_TPPART
                    aAdd(aStatement,aResumoFor[nFOr][1])    //F22_CLIFOR
                    aAdd(aStatement,aResumoFor[nFOr][2])    //F22_LOJA
                    aAdd(aStatement,cValToChar(nF22Recno))  //R_E_C_N_O_
                    IF lF22Tipo
                        aAdd(aStatement,'02')               //F22_TIPOPF
                    EndIf

                    If nFOr == nTamResFor
                        lForce := .T.
                    EndIf

                    GrvF22Regs(aStatement, cTabF22, lF22Tipo, lForce, cSGBD)

                    nF22Recno++
                    nQtdProc++

                ElseIF cAcao == "2" .And. lAchouF22 //Remoção e existe gravado

                    //Deleta da tabela
                    RecLock("F22",.F.)
                    F22->(dbDelete())
                    MsUnLock()
                    F22->(FkCommit())
                    nQtdProc += 1

                EndIF

            Next nFOr

        Next nPerfil

    END TRANSACTION

Else
    //Todo atualizar o grid
    oGrid      := oModel:GetModel("FISA164PARTICIPANTE")
    cCodF22    := oModel:GetValue("FISA164","F20_CODIGO")
    nOperation := oModel:GetOperation()
    oView      := FwViewActive()

    BEGIN TRANSACTION

        For nFOr := 1 to nTamResFor

            AtualizaMsg( oSay, STR0062 + aResumoFor[nFOr][1]+ STR0056 + aResumoFor[nFOr][2] ) //" , Loja: "
            nQtdTot += 1

            If cAcao == "2"
                lAchouF22  := oGrid:SeekLine( { {"F22_TPPART", "1" }, {"F22_CLIFOR", aResumoFor[nFOr][1]}, {"F22_LOJA", aResumoFor[nFOr][2] } } )
            EndIf

            IF cAcao == "1" //Inclusão 

                aStatement := {}
                aAdd(aStatement,cFilF22)                //F22_FILIAL
                aAdd(aStatement,cCodF22)                //F22_CODIGO
                aAdd(aStatement,'1')                    //F22_TPPART
                aAdd(aStatement,aResumoFor[nFOr][1])    //F22_CLIFOR
                aAdd(aStatement,aResumoFor[nFOr][2])    //F22_LOJA
                aAdd(aStatement,cValToChar(nF22Recno))  //R_E_C_N_O_
                IF lF22Tipo
                    aAdd(aStatement,'02')               //F22_TIPOPF
                EndIf

                If nFOr == nTamResFor
                    lForce := .T.
                EndIf

                GrvF22Regs(aStatement, cTabF22, lF22Tipo, lForce, cSGBD)

                nF22Recno++
                nQtdProc++

            ElseIF cAcao == "2" .And. lAchouF22 //Remoção e existe gravado

                //Deleta da tabela
                oGrid:DeleteLine()
                nQtdProc += 1

            EndIF

        Next nFOr

        //If nOperation == 3 // Para operações de inclusão de perfil, forço a gravação da F20 
        FwFormCommit(oModel)
        //EndIf

    END TRANSACTION
    oGrid:SetLine(1)

ENdIF

If cTpWiz = '2' .And. cAcao == "1" .And. nQtdProc > 0

    oView:Deactivate()

    If nOperation == MODEL_OPERATION_INSERT //Forço operação de atualização
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
    EndIf
    AtualizaMsg( oSay, "Aguarde, atualizando os dados inseridos...")
    oView:Activate()
    
    //Forço atualização de campo pro MVC entender que o formulário sofreu alterações e pode ser salvo
    cDescri := oModel:GetValue("FISA164","F20_CODIGO")
    oModel:LoadValue("FISA164","F20_CODIGO","")
    oModel:LoadValue("FISA164","F20_CODIGO",cDescri)

EndIf

cMsg    :=  STR0036 + CHR(10)+CHR(13) + ; //"Processamento concluído com sucesso!"
            STR0037 + cValToChar(nQtdTot) + CHR(10)+CHR(13) + ; //"Quantidade total de registro(s) processado(s): "
            STR0039 + Iif(cAcao == '1' , STR0040 , STR0038 ) + cVAltoChar(nQtdProc ) //"Removido(s): "

AtualizaMsg( oSay, STR0041) //"Processamento Concluído com Sucesso!"
MsgInfo(cMsg)



Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} FSA171OISS()

Função que criará os filtros de ISS para alteração em
lote dos perfis de Operações

@author Renato Rezende
@since 23/07/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function FSA171OISS(oPanel, oMarkISS)

Local oLayer     := FWLayer():new()
Local aCmpISS    := {}
Local aColsISS   := {}
Local cQueryISS  := ""
Local cAliasISS  := GetNextAlias()
Local oSayTitulo := NIL
Local oPanel1    := NIL
Local oPanel2    := NIL

//Cria Layer
oLayer:Init(oPanel,.F.)

// Adicionando linhas
oLayer:AddLine('L1',10,.F.)
oLayer:AddLine('L2',90,.F.)
oPanel1 := oLayer:getLinePanel('L1')

//Adicionando colunas
oLayer:addCollumn('C1',100,.F.,'L2')

oLayer:AddWindow('C1','W1',"Códigos de ISS",100,.F.,.F.,,'L2')

oPanel2 := oLayer:getWinPanel('C1','W1','L2')

//Crio o TSay na primeira linha da Layer
oSayTitulo:= TSay():New(5,5,{||"Selecione abaixo os Códigos de ISS" },oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10)
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

//Chama função para montar query e array com os campos do Header
cQueryISS := FSA171QRY("SX5", {'60'}, @aCmpISS)

//Chama função para montar as colunas do aHeader
aColsISS  := HeaderMark(aCmpISS)

//Chama função para montar o browse para ISS
oMarkISS := AddMarkBro(oPanel2, @lAllISS, aCmpISS, aColsISS, cQueryISS, cAliasISS)

Return
