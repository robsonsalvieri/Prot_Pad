#Include "FISA171.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

// Proteção pois em binários 32 bits o objeto TSay não possui o método SetTextAlign.
STATIC oSayCheck  := IIf(!IsBlind(), TSay():New(), NIL)
STATIC cMethIsMemberOf := "MethIsMemberOf"
STATIC lMethAlign := IIf(!IsBlind(), &cMethIsMemberOf.(oSayCheck,"SetTextAlign"), .F.)


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

Local oNewPag         := NIL
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
PRIVATE aAmostra      := {}
PRIVATE oFornecedor   := NIL
PRIVATE oProduto      := NIL
PRIVATE aResumoProd   := {}

PRIVATE oPgFiltro     := NIL
PRIVATE aParamQry     := {}

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
            oPgFiltro:SetNextAction({|| VLDMARK(oMarkCli,STR0011)}) //"Deverá ser selecionado ao menos um cliente para prosseguir"

            nSteps +=1
            oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
            //Altera a descrição do step
            oNewPag:SetStepDescription(STR0008) //"Confirmação"
            //Define o bloco de construção
            oNewPag:SetConstruction({|Panel|ResumoCli(Panel,oMarkPerfil,cAcao, cTpWiz)})
            //Define o bloco ao clicar no botão Próximo
            oNewPag:SetNextAction({||FwMsgRun(,{|oSay| GRVF22CLI(cAcao, oSay, cTpWiz, oModel) },STR0009,""), .T. })

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
            oPgFiltro:SetNextAction({|| VLDMARK(oMarkFor,STR0012)}) //"Deverá ser selecionado ao menos um Fornecedor para prosseguir"

            nSteps +=1
            oNewPag := oStepWiz:AddStep(cValToChar(nSteps))
            //Altera a descrição do step
            oNewPag:SetStepDescription(STR0008) //"Confirmação"
            //Define o bloco de construção
            oNewPag:SetConstruction({|Panel| ResumoFor(Panel,oMarkPerfil,cAcao, cTpWiz) })
            //Define o bloco ao clicar no botão Próximo
            oNewPag:SetNextAction({||FwMsgRun(,{|oSay| GRVF22FOR(cAcao, oSay, cTpWiz, oModel) },STR0009,""), .T. })

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
        oNewPag:SetNextAction({||FwMsgRun(,{|oSay| GRVF24PRD(cAcao, oSay, cTpWiz, oModel) },STR0009,""), .T. })

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

        If !( "|" $ cCodF20 )
            If cAcao == "1"
                cQuery += " LEFT JOIN " + RetSQLName("F22") + " F22 "
            Else
                cQuery += " RIGHT JOIN " + RetSQLName("F22") + " F22 "
            EndIf
            cQuery += " ON  F22.F22_FILIAL = " + ValToSQL(xFilial("F22"))
            cQuery += " AND F22.F22_CODIGO = " + ValToSQL(cCodF20)
            cQuery += " AND F22.F22_TPPART = '2' "
            cQuery += " AND F22.F22_CLIFOR = SA1.A1_COD  "
            cQuery += " AND F22.F22_LOJA   = SA1.A1_LOJA "
            cQuery += " AND F22.D_E_L_E_T_ = ' ' "
            cQuery += " AND EXISTS (SELECT 1 FROM " + RetSQLName("F20") + " F20E "
            cQuery += " WHERE F20E.F20_FILIAL = F22.F22_FILIAL "
            cQuery += " AND F20E.F20_CODIGO = F22.F22_CODIGO "
            cQuery += " AND F20E.F20_TIPO   = '02' "
            cQuery += " AND F20E.D_E_L_E_T_ = ' ') "
        EndIf

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
        If !( "|" $ cCodF20 ) .AND. cAcao == "1" //Somente na inclusão eu devo considerar apenas os registros que não estão cadastrados no perfil de participante.
            cQuery += " AND F22.F22_CODIGO IS NULL"
        EndIf

    Case cTpQuery == "SA2"

        cQuery += " FROM " + RETSQLNAME("SA2") + " SA2 "

        If !( "|" $ cCodF20 )
            If cAcao == "1"
                cQuery += " LEFT JOIN " + RetSQLName("F22") + " F22 "
            Else
                cQuery += " RIGHT JOIN " + RetSQLName("F22") + " F22 "
            EndIf
            cQuery += " ON  F22.F22_FILIAL = " + ValToSQL(xFilial("F22"))
            cQuery += " AND F22.F22_CODIGO = " + ValToSQL(cCodF20)
            cQuery += " AND F22.F22_TPPART = '1' "
            cQuery += " AND F22.F22_CLIFOR = SA2.A2_COD  "
            cQuery += " AND F22.F22_LOJA   = SA2.A2_LOJA "
            cQuery += " AND F22.D_E_L_E_T_ = ' ' "
            cQuery += " AND EXISTS (SELECT 1 FROM " + RetSQLName("F20") + " F20E "
            cQuery += " WHERE F20E.F20_FILIAL = F22.F22_FILIAL "
            cQuery += " AND F20E.F20_CODIGO = F22.F22_CODIGO "
            cQuery += " AND F20E.F20_TIPO   = '02' "
            cQuery += " AND F20E.D_E_L_E_T_ = ' ') "
        EndIf

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

        If !( "|" $ cCodF20 ) .AND. cAcao == "1" //Somente na inclusão eu devo considerar apenas os registros que não estão cadastrados no perfil de participante.
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
Static Function AddMarkBro(oPanel, lAllMark, aCampos, aColumns, cQuery, cAliasTab, lHabilita)

Local bMark        := {||IIf((oMark:cAlias)->OK == 1, "LBOK", "LBNO")}
Local bMarkOne     := {||IIf((oMark:cAlias)->OK == 0,(oMark:cAlias)->OK := 1, (oMark:cAlias)->OK := 0 )}
Local bMarkAll     := {||SetMarkAll(@oMark, @lAllMark)}
Local oMark        := NIL
Default lHabilita := .T.

oMark := FwFormBrowse():New()
if lHabilita
    oMark:AddMarkColumns(bMark,bMarkOne,bMarkAll)
    oMark:SetDoubleClick(bMarkOne)
endif
oMark:SetDataQuery(.T.)
oMark:SetQuery(cQuery)
oMark:SetAlias(cAliasTab)
oMark:SetOwner(oPanel)
oMark:SetColumns(aColumns)
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
Local cAlsMark   := oMarkProd:cAlias

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

aCmpProd := CamposBrw('aAmostra', 'oProduto', 'SB1')

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

//Monta amostra de produtos selecionados para exibicao no resumo
aAmostra := {}
(cAlsMark)->(DbGoTop())
While (cAlsMark)->(!EOF()) .And. Len(aAmostra) < 50
    If (cAlsMark)->OK == 1
        AAdd(aAmostra, {(cAlsMark)->B1_COD, (cAlsMark)->B1_DESC})
    EndIf
    (cAlsMark)->(DbSkip())
EndDo

//Browse de perfil
IF cTpWiz == '1'
    ADDBrwResumo(@oPerfil, aColPerfil, aResumoPerfil, oPanel2)
EndIF

//Browse de produtos
ADDBrwResumo(@oProduto, aColsProd, aAmostra, oPanel3)

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

    //Monta array de resumo com Perfis selecionados
    If cTpWiz == '1'
        aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
        oPerfil:SetArray(aResumoPerfil)
        oPerfil:Refresh(.T.)
    EndIf

    //No resumo de produto atualizamos apenas o browse visual
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
Local oBulk     := nil
Local aCpoBulk  := {}
Local nQtdRegBulk := 100000
Local nTamResPer := 0
Local nTamResPro := 0
Local cFilF24 := xFilial("F24")
Local cTipoF24 := "04"

aAdd(aCpoBulk,{"F24_FILIAL"})
aAdd(aCpoBulk,{"F24_CODIGO"})
aAdd(aCpoBulk,{"F24_CDPROD"})
aAdd(aCpoBulk,{"F24_TIPOPF"})

nTamResPer := len(aResumoPerfil)
nTamResPro := len(aResumoProd)

oBulk := FWBulk():New(RetSqlName("F24"),nQtdRegBulk)
oBulk:SetFields(aCpoBulk)

dbSelectArea('F24')
F24->(dbSetOrder(1))

IF cTpWiz == '1' //Wizard por "Fora"   

    For nPerfil := 1 to nTamResPer
       
        For nProd := 1 to nTamResPro
            AtualizaMsg( oSay, STR0046 + aResumoPerfil[nPerfil][1]  + STR0045 + aResumoProd[nProd][2] ) //" , Produto: " //"Processando perfil: "
            nQtdTot += 1
            //Verifica se a informação já existe gravada
            lAchouF24 := F24->( MsSeek ( xFilial('F24') + aResumoPerfil[nPerfil][1] + aResumoProd[nProd][1] ) )
           
            IF cAcao == "1" .AND. !lAchouF24 //Inclusão e não existe ainda gravado
                oBulk:AddData({;
                   cFilF24,;
                   aResumoPerfil[nPerfil][1],;
                   aResumoProd[nProd][1],;
                   cTipoF24;
                })                
                nQtdProc += 1
            ElseIF cAcao == "2" .AND. !lAchouF24 //Remoção e existe gravado
                //Deleta da tabela
                RecLock("F24",.F.)
                F24->(dbDelete())
                MsUnLock()
                F24->(FkCommit())
                nQtdProc += 1
            EndIF
        Next nProd
    Next nPerfil
    oBulk:Close()
    oBulk:DesTroy()
    FreeObj(oBulk)     

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

//-------------------------------------------------------------------
/*/{Protheus.doc} GRVF24PRD
    Grava Produto em lote via SQL (SB1/F24)
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 20/05/2026
    @version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function GRVF24PRD(cAcao, oSay, cTpWiz, oModel)

    Local nPerfil        := 0
    Local nQtdProc       := 0
    Local nQtdLote       := 0
    Local nPerfilProc    := 0
    Local nPerfilAlter   := 0
    Local nQtdSel        := 0
    Local cMsg           := ''
    Local nTamResPer     := 0
    Local cFilF24        := xFilial("F24")
    Local cCodF20        := ''
    Local aPerfilValidos := {}
    Local cF24Sql        := RetSqlName("F24")
    Local cSB1Sql        := RetSqlName("SB1")
    Local cAlsTemp       := ''
    Local oTempSB1       := NIL
    Local aTempFlds      := {}
    Local cTempSql       := ''
    Local lF24Tipo       := F24->(FieldPos("F24_TIPOPF")) > 0
    Local cColTipo       := ""
    Local cValTipo       := ""
    Local cJoinIns       := ""
    Local cWhereTipo     := ""
    Local cWhereIns      := ""
    Local cWhereN1       := ""
    Local cWhereDel      := ""

    If lF24Tipo
        cColTipo  := ", F24_TIPOPF"
        cValTipo  := ", '04'"
        cJoinIns  := " AND F24X.F24_TIPOPF = '04'"
        cWhereTipo := " AND F24_TIPOPF = '04'"
    EndIf

    cWhereIns := MontaWSB1(aParamQry, "")
    cWhereN1  := " AND " + MontaWSB1(aParamQry, "SB1.")
    cWhereDel := MontaWSB1(aParamQry, "SRC.")

    nTamResPer := Len(aResumoPerfil)
    nQtdSel    := CntMarkSel(oMarkProd)

    If cTpWiz == '1'

        If cAcao == "1"

            For nPerfil := 1 to nTamResPer
                cCodF20 := aResumoPerfil[nPerfil][1]
                AtualizaMsg(oSay, STR0046 + cCodF20)
                AAdd(aPerfilValidos, cCodF20)
            Next

            If Len(aPerfilValidos) > 0

                If Len(aPerfilValidos) == 1
                    cCodF20 := aPerfilValidos[1]
                    AtualizaMsg(oSay, STR0046 + cCodF20)
                    nPerfilProc++
                    nQtdLote := InsF24SQL(cCodF20, cFilF24, cF24Sql, cSB1Sql, "SB1", "B1_COD", cWhereN1, cColTipo, cValTipo, cJoinIns)
                    nQtdProc += nQtdLote
                    If nQtdLote > 0
                        nPerfilAlter++
                    EndIf

                Else
                    cAlsTemp := GetNextAlias()
                    oTempSB1 := FWTemporaryTable():New(cAlsTemp)
                    AAdd(aTempFlds, {"B1_FILIAL", "C", TamSX3("B1_FILIAL")[1], 0})
                    AAdd(aTempFlds, {"B1_COD",    "C", TamSX3("B1_COD")[1],    0})
                    oTempSB1:SetFields(aTempFlds)
                    oTempSB1:Create()
                    cTempSql := oTempSB1:GetRealName()

                    TCSqlExec("INSERT INTO " + cTempSql + " (B1_FILIAL, B1_COD)" + ;
                              " SELECT B1_FILIAL, B1_COD FROM " + cSB1Sql + " WHERE " + cWhereIns)
                    FkCommit()

                    For nPerfil := 1 to Len(aPerfilValidos)
                        cCodF20 := aPerfilValidos[nPerfil]
                        AtualizaMsg(oSay, STR0046 + cCodF20)
                        nPerfilProc++
                        nQtdLote := InsF24SQL(cCodF20, cFilF24, cF24Sql, cTempSql, "T", "B1_COD", "", cColTipo, cValTipo, cJoinIns)
                        nQtdProc += nQtdLote
                        If nQtdLote > 0
                            nPerfilAlter++
                        EndIf
                    Next

                    oTempSB1:Delete()
                    FreeObj(oTempSB1)
                EndIf

            EndIf

        ElseIf cAcao == "2"

            For nPerfil := 1 to nTamResPer
                cCodF20 := aResumoPerfil[nPerfil][1]
                AtualizaMsg(oSay, STR0046 + cCodF20)
                nPerfilProc++
                nQtdLote := DelF24SQL(cCodF20, cFilF24, cF24Sql, cSB1Sql, "B1_COD", cWhereDel, cWhereTipo)
                nQtdProc += nQtdLote
                If nQtdLote > 0
                    nPerfilAlter++
                EndIf
            Next

        EndIf

    Else

        cCodF20 := oModel:GetValue("FISA166","F20_CODIGO")

        If cAcao == "1"
            AtualizaMsg(oSay, STR0046 + cCodF20)
            nPerfilProc := 1
            GrvF20SQLPRD(oModel)
            nQtdProc := InsF24SQL(cCodF20, cFilF24, cF24Sql, cSB1Sql, "SB1", "B1_COD", cWhereN1, cColTipo, cValTipo, cJoinIns)
            If nQtdProc > 0
                nPerfilAlter := 1
            EndIf
        ElseIf cAcao == "2"
            AtualizaMsg(oSay, STR0046 + cCodF20)
            nPerfilProc := 1
            nQtdProc := DelF24SQL(cCodF20, cFilF24, cF24Sql, cSB1Sql, "B1_COD", cWhereDel, cWhereTipo)
            If nQtdProc > 0
                nPerfilAlter := 1
            EndIf
        EndIf

        lWizOK := .T.
    EndIf

    cMsg := MontaMsgLote(cAcao, "produto(s)", nPerfilProc, nPerfilAlter, nQtdProc, nQtdSel)

    AtualizaMsg(oSay, STR0041)
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

Return NIL

/*/{Protheus.doc} CntMarkSel
    Conta registros marcados em browse de selecao do facilitador.
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 09/06/2026
    @version 12.1.2510
/*/
Static Function CntMarkSel(oMark)

    Local nRet := 0
    Local cAls := ""

    If ValType(oMark) != "O"
        Return 0
    EndIf

    cAls := oMark:cAlias
    (cAls)->(DbGoTop())
    While (cAls)->(!Eof())
        If (cAls)->OK == 1
            nRet++
        EndIf
        (cAls)->(DbSkip())
    EndDo
    (cAls)->(DbGoTop())

Return nRet

/*/{Protheus.doc} MontaMsgLote
    Monta mensagem de conclusao do facilitador com estatisticas para o usuario.
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 09/06/2026
    @version 12.1.2510
/*/
Static Function MontaMsgLote(cAcao, cRotulo, nPerfilProc, nPerfilAlter, nQtdNovos, nQtdSel)

    Local cMsg := ""
    Local nExistentes := 0

    Default cRotulo      := "registro(s)"
    Default nPerfilProc  := 0
    Default nPerfilAlter := 0
    Default nQtdNovos    := 0
    Default nQtdSel      := 0

    If nQtdSel < nQtdNovos
        nQtdSel := nQtdNovos
    EndIf

    If nPerfilProc > 1
        nExistentes := (nQtdSel * nPerfilProc) - nQtdNovos
    Else
        nExistentes := nQtdSel - nQtdNovos
    EndIf
    If nExistentes < 0
        nExistentes := 0
    EndIf

    If cAcao == "1"

        If nQtdNovos == 0 .And. nQtdSel > 0
            cMsg := "Processamento concluido." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
            cMsg += "Os " + cValToChar(nQtdSel) + " " + cRotulo + " selecionado(s) ja estavam vinculados"
            If nPerfilProc > 1
                cMsg += " aos " + cValToChar(nPerfilProc) + " perfil(is) informado(s)"
            Else
                cMsg += " ao perfil informado"
            EndIf
            cMsg += "."
        ElseIf nQtdNovos > 0
            cMsg := STR0036 + Chr(13) + Chr(10) + Chr(13) + Chr(10)
            If nPerfilProc > 1
                cMsg += "Perfil(is) processado(s): " + cValToChar(nPerfilProc) + Chr(13) + Chr(10)
                cMsg += "Perfil(is) com vinculo(s) novo(s): " + cValToChar(nPerfilAlter) + Chr(13) + Chr(10)
            EndIf
            If nQtdSel > 0
                cMsg += cRotulo + " selecionado(s): " + cValToChar(nQtdSel) + Chr(13) + Chr(10)
            EndIf
            cMsg += "Vinculo(s) incluido(s): " + cValToChar(nQtdNovos)
            If nExistentes > 0
                cMsg += Chr(13) + Chr(10) + "Ja existente(s) no perfil: " + cValToChar(nExistentes)
            EndIf
        Else
            cMsg := "Processamento concluido." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
            cMsg += "Nenhum " + cRotulo + " foi incluido."
        EndIf

    Else

        If nQtdNovos == 0 .And. nQtdSel > 0
            cMsg := "Processamento concluido." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
            cMsg += "Os " + cValToChar(nQtdSel) + " " + cRotulo + " selecionado(s) nao estavam vinculados"
            If nPerfilProc > 1
                cMsg += " aos " + cValToChar(nPerfilProc) + " perfil(is) informado(s)"
            Else
                cMsg += " ao perfil informado"
            EndIf
            cMsg += "."
        ElseIf nQtdNovos > 0
            cMsg := STR0036 + Chr(13) + Chr(10) + Chr(13) + Chr(10)
            If nPerfilProc > 1
                cMsg += "Perfil(is) processado(s): " + cValToChar(nPerfilProc) + Chr(13) + Chr(10)
                cMsg += "Perfil(is) com vinculo(s) removido(s): " + cValToChar(nPerfilAlter) + Chr(13) + Chr(10)
            EndIf
            If nQtdSel > 0
                cMsg += cRotulo + " selecionado(s): " + cValToChar(nQtdSel) + Chr(13) + Chr(10)
            EndIf
            cMsg += "Vinculo(s) removido(s): " + cValToChar(nQtdNovos)
        Else
            cMsg := "Processamento concluido." + Chr(13) + Chr(10) + Chr(13) + Chr(10)
            cMsg += "Nenhum " + cRotulo + " foi removido."
        EndIf

    EndIf

Return cMsg

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
Local oPanel1      := NIL
Local oPanel2      := NIL
Local oPanel3      := NIL
Local aCampos    := {}
Local cQuery     := ""
Local cAliasSB1  := GetNextAlias()
Local oSayTitulo := NIL

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
oMarkProd := AddMarkBro(oPanel3, @lAllProd, aCampos, aColumns, cQuery, cAliasSB1 , .F.)

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
Local cQuery        := ""
Local cAlsCliente   := GetNextAlias()
Local oPanel1       := NIL
Local oPanel2       := NIL
Local oPanel3       := NIL
Local oSayTitulo    := NIL
Local cCodF20       := ""
Local oModel        := Nil
Local aResPer       := {}
Local nPer          := 0

Default oMarkPerfil := Nil

If ValType(oMarkPerfil) == "O"
    aResPer := MontaResumo(oMarkPerfil, 'F20')
    cCodF20 := ''
    For nPer := 1 to Len(aResPer)
        cCodF20 += IIf(nPer > 1, '|', '') + aResPer[nPer][1]
    Next
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
oLCli:AddWindow('C1','W1',STR0053,100,.F.,.F.,,'L2')
oPanel3 := oLCli:getWinPanel('C1','W1','L2')

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0055 + Iif(cAcao == '1' ,STR0051 , STR0052) + STR0054},oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10)
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

aParamQry := {Substr(cA1Pessoa,1,1), Substr(cA1Tipo,1,1), Substr(cA1TPessoa,1,2), Substr(cA1SimpNac,1,1), Substr(cA1Contrib,1,1), cA1GrpTrib, cA1Estado, cA1GrpVen, cA1Mun}
cQuery := FSA171QRY("SA1", aParamQry, @aCampos, , ,cCodF20, cAcao)

aColumns  := HeaderMark(aCampos)

oMarkCli := AddMarkBro(oPanel3, @lAllCLi, aCampos, aColumns, cQuery, cAlsCliente, .F.)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AtuQryBro()

Função que refaz o MarkBorwse considerando alteração dos campos de filtros

@author Erick G Dias
@since 10/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AtuQryBro(oPanel, cAcao, oObjMark, cConstrutor, oMarkPerfil)

Local cQuery       := ''
Local cAliasTab    := GetNextAlias()
Local lRefreshMArk := .F.
Local cCodF20      := ""
Local aResPer      := {}
Local nPer         := 0

DEFAULT oMarkPerfil := Nil

IF Valtype(oMarkPerfil) == "O"
    aResPer := MontaResumo(oMarkPerfil, 'F20')
    cCodF20 := ''
    For nPer := 1 to Len(aResPer)
        cCodF20 += IIf(nPer > 1, '|', '') + aResPer[nPer][1]
    Next
EndIf

IF Valtype(oObjMark) == "O"

    If Select(oObjMark:cAlias) > 0
        dbSelectArea(oObjMark:cAlias)
        dbCloseArea()
    EndIF

    If cConstrutor == 'CLIENTE'
        aParamQry := {Substr(cA1Pessoa,1,1), Substr(cA1Tipo,1,1), Substr(cA1TPessoa,1,2), Substr(cA1SimpNac,1,1), Substr(cA1Contrib,1,1), cA1GrpTrib, cA1Estado, cA1GrpVen, cA1Mun}
        cQuery := FSA171QRY("SA1", aParamQry, , , , cCodF20, cAcao)
        lRefreshMArk := .T.
    ElseIf cConstrutor == 'PRODUTO'
        aParamQry := {cCodPrDe, cCodPrAte, cNcmDe, cNcmAte, cTpProd, cGrTrib, GetOrigens(), cCestDe, cCestAte, cGrpDe, cGrpAt}
        cQuery := FSA171QRY("SB1", aParamQry, , , , cCodF20)
        lRefreshMArk := .T.
    ElseIf cConstrutor == 'FORNECEDOR'
        aParamQry := {Substr(cA2Tipo,1,1), cA2Estado, cA2GrpTrib, Substr(cA2SimpNac,1,1), Substr(cA2Contrib,1,1), cA2Mun}
        cQuery := FSA171QRY("SA2", aParamQry, , , , cCodF20, cAcao)
        lRefreshMArk := .T.
    EndIF

    If lRefreshMArk
        oObjMark:SetQuery(cQuery)
        oObjMark:SetAlias(cAliasTab)
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
Local aCmpPerfil   := {}
Local aColPerfil   := {}
Local oSayTitulo   := NIL
Local oPanel1      := NIL
Local oPanel2      := NIL
Local oPanel3      := NIL
Local oPanel4      := NIL
Local cAlsMark     := oMarkCli:cAlias

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
aCmpCli  := CamposBrw('aAmostra', 'oCliente', 'SA1')

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
aAmostra := {}

(cAlsMark)->(DbGoTop())
While (cAlsMark)->(!EOF()) .and. Len(aAmostra) < 50 
    AAdd(aAmostra, {(cAlsMark)->A1_COD, (cAlsMark)->A1_LOJA, (cAlsMark)->A1_NOME})
    (cAlsMark)->(DbSkip())
EndDo

//Browse de perfil
IF cTpWiz == '1'
    ADDBrwResumo(@oPerfil, aColPerfil, aResumoPerfil, oPanel2)
EndIF

//Browse de cliente
ADDBrwResumo(@oCliente, aColsCLi, aAmostra, oPanel4)

Return

/*/{Protheus.doc} GRVF22CLI
    Grava Cliente em lote via SQL (SA2)
    @type  Static Function
    @author user
    @since 28/04/2026
    @version 12.1.2510
/*/

Static function GRVF22CLI(cAcao as character, oSay as object, cTpWiz as character, oModel as object)

    Local nPerfil        := 0
    Local nQtdProc       := 0
    Local nQtdLote       := 0
    Local nPerfilProc    := 0
    Local nPerfilAlter   := 0
    Local nQtdSel        := 0
    Local cMsg           := ''
    Local nTamResPer     := 0
    Local cFilF22        := xFilial("F22")
    Local cCodF22        := ''
    Local aPerfilValidos := {}
    Local cF22Sql        := RetSqlName("F22")
    Local cSA1Sql        := RetSqlName("SA1")
    Local cAlsTemp       := ''
    Local oTempSA1       := NIL
    Local aTempFlds      := {}
    Local cTempSql       := ''
    Local lF22Tipo       := F22->(FieldPos("F22_TIPOPF")) > 0
    Local cColTipo       := IIf(lF22Tipo, ", F22_TIPOPF", "")
    Local cValTipo       := IIf(lF22Tipo, ", '02'", "")
    Local cWhereIns      := ""
    Local cWhereN1       := ""
    Local cWhereDel      := ""

    cWhereIns := MontaWSA1(aParamQry, "")
    cWhereN1  := "AND " + MontaWSA1(aParamQry, "SA1.")
    cWhereDel := MontaWSA1(aParamQry, "SRC.")

    nTamResPer := Len(aResumoPerfil)
    nQtdSel    := CntMarkSel(oMarkCli)

    If cTpWiz == '1'

        If cAcao == "1"  //--- Inclusao ---

            For nPerfil := 1 to nTamResPer
                cCodF22 := aResumoPerfil[nPerfil][1]
                AtualizaMsg(oSay, STR0046 + cCodF22)
                If F22ExistTodos(cCodF22, "2")
                    FWAlertWarning("No perfil de participantes ja existe o codigo TODOS, " + ;
                        "sendo assim nao sera adicionado nenhum novo codigo, no perfil: " + cCodF22 + "!", 'Alerta')
                Else
                    AAdd(aPerfilValidos, cCodF22)
                EndIf
            Next

            If Len(aPerfilValidos) > 0

                If Len(aPerfilValidos) == 1
                    cCodF22 := aPerfilValidos[1]
                    AtualizaMsg(oSay, STR0046 + cCodF22)
                    nPerfilProc++
                    nQtdLote := InsF22SQL(cCodF22, "2", cFilF22, cF22Sql, cSA1Sql, "SA1", "A1_COD", "A1_LOJA", cWhereN1, cColTipo, cValTipo)
                    nQtdProc += nQtdLote
                    If nQtdLote > 0
                        nPerfilAlter++
                    EndIf

                Else
                    // N>1: popula temp uma vez, itera perfis
                    cAlsTemp := GetNextAlias()
                    oTempSA1 := FWTemporaryTable():New(cAlsTemp)
                    aTempFlds := {}
                    AAdd(aTempFlds, {"A1_FILIAL", "C", TamSX3("A1_FILIAL")[1], 0})
                    AAdd(aTempFlds, {"A1_COD",    "C", TamSX3("A1_COD")[1],    0})
                    AAdd(aTempFlds, {"A1_LOJA",   "C", TamSX3("A1_LOJA")[1],   0})
                    oTempSA1:SetFields(aTempFlds)
                    oTempSA1:Create()
                    cTempSql := oTempSA1:GetRealName()

                    TCSqlExec("INSERT INTO " + cTempSql + " (A1_FILIAL, A1_COD, A1_LOJA)" + ;
                              " SELECT A1_FILIAL, A1_COD, A1_LOJA FROM " + cSA1Sql + " WHERE " + cWhereIns)
                    FkCommit()

                    For nPerfil := 1 to Len(aPerfilValidos)
                        cCodF22 := aPerfilValidos[nPerfil]
                        AtualizaMsg(oSay, STR0046 + cCodF22)
                        nPerfilProc++
                        nQtdLote := InsF22SQL(cCodF22, "2", cFilF22, cF22Sql, cTempSql, "T", "A1_COD", "A1_LOJA", "", cColTipo, cValTipo)
                        nQtdProc += nQtdLote
                        If nQtdLote > 0
                            nPerfilAlter++
                        EndIf
                    Next

                    oTempSA1:Delete()
                    FreeObj(oTempSA1)
                EndIf

            EndIf

        ElseIf cAcao == "2"  //--- Exclusao ---

            For nPerfil := 1 to nTamResPer
                cCodF22 := aResumoPerfil[nPerfil][1]
                AtualizaMsg(oSay, STR0046 + cCodF22)
                nPerfilProc++
                nQtdLote := DelF22SQL(cCodF22, "2", cFilF22, cF22Sql, cSA1Sql, "A1_COD", "A1_LOJA", cWhereDel)
                nQtdProc += nQtdLote
                If nQtdLote > 0
                    nPerfilAlter++
                EndIf
            Next

        EndIf

    Else  // cTpWiz == '2': dentro do formulario MVC (FISA164) - sempre N=1 perfil

        cCodF22 := oModel:GetValue("FISA164","F20_CODIGO")

        If cAcao == "1"

            If F22ExistTodos(cCodF22, "2")
                FWAlertWarning("No perfil de participantes ja existe o codigo TODOS, " + ;
                    "sendo assim nao sera adicionado nenhum novo codigo, no perfil: " + cCodF22 + "!", 'Alerta')
            Else
                AtualizaMsg(oSay, STR0046 + cCodF22)
                nPerfilProc := 1
                GrvF20SQL(oModel)
                nQtdProc := InsF22SQL(cCodF22, "2", cFilF22, cF22Sql, cSA1Sql, "SA1", "A1_COD", "A1_LOJA", cWhereN1, cColTipo, cValTipo)
                If nQtdProc > 0
                    nPerfilAlter := 1
                EndIf
            EndIf

        ElseIf cAcao == "2"

            AtualizaMsg(oSay, STR0046 + cCodF22)
            nPerfilProc := 1
            nQtdProc := DelF22SQL(cCodF22, "2", cFilF22, cF22Sql, cSA1Sql, "A1_COD", "A1_LOJA", cWhereDel)
            If nQtdProc > 0
                nPerfilAlter := 1
            EndIf

        EndIf
        lWizOK := .T.
    EndIf

    cMsg := MontaMsgLote(cAcao, "cliente(s)", nPerfilProc, nPerfilAlter, nQtdProc, nQtdSel)

    AtualizaMsg(oSay, STR0041)
    MsgInfo(cMsg)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GRVF22FOR
    Grava Fornecedor em lote via SQL (SA2)    
    @type  Static Function
    @author Ricardo Henrique de Mello Lima
    @since 05/05/2026
    @version version
/*/
//-------------------------------------------------------------------
Static function GRVF22FOR(cAcao as character, oSay as object, cTpWiz as character, oModel as object)

    Local nPerfil        := 0
    Local nQtdProc       := 0
    Local nQtdLote       := 0
    Local nPerfilProc    := 0
    Local nPerfilAlter   := 0
    Local nQtdSel        := 0
    Local cMsg           := ''
    Local nTamResPer     := 0
    Local cFilF22        := xFilial("F22")
    Local cCodF22        := ''
    Local aPerfilValidos := {}
    Local cF22Sql        := RetSqlName("F22")
    Local cSA2Sql        := RetSqlName("SA2")
    Local cAlsTemp       := ''
    Local oTempSA2       := NIL
    Local aTempFlds      := {}
    Local cTempSql       := ''
    Local lF22Tipo       := F22->(FieldPos("F22_TIPOPF")) > 0
    Local cColTipo       := IIf(lF22Tipo, ", F22_TIPOPF", "")
    Local cValTipo       := IIf(lF22Tipo, ", '02'", "")
    Local cWhereIns      := ""
    Local cWhereN1       := ""
    Local cWhereDel      := ""

    cWhereIns := MontaWSA2(aParamQry, "")
    cWhereN1  := "AND " + MontaWSA2(aParamQry, "SA2.")
    cWhereDel := MontaWSA2(aParamQry, "SRC.")

    nTamResPer := Len(aResumoPerfil)
    nQtdSel    := CntMarkSel(oMarkFor)

    If cTpWiz == '1'

        If cAcao == "1"  //--- Inclusao ---

            For nPerfil := 1 to nTamResPer
                cCodF22 := aResumoPerfil[nPerfil][1]
                AtualizaMsg(oSay, STR0046 + cCodF22)
                If F22ExistTodos(cCodF22, "1")
                    FWAlertWarning("No perfil de participantes ja existe o codigo TODOS, " + ;
                        "sendo assim nao sera adicionado nenhum novo codigo, no perfil: " + cCodF22 + "!", 'Alerta')
                Else
                    AAdd(aPerfilValidos, cCodF22)
                EndIf
            Next

            If Len(aPerfilValidos) > 0

                If Len(aPerfilValidos) == 1
                    cCodF22 := aPerfilValidos[1]
                    AtualizaMsg(oSay, STR0046 + cCodF22)
                    nPerfilProc++
                    nQtdLote := InsF22SQL(cCodF22, "1", cFilF22, cF22Sql, cSA2Sql, "SA2", "A2_COD", "A2_LOJA", cWhereN1, cColTipo, cValTipo)
                    nQtdProc += nQtdLote
                    If nQtdLote > 0
                        nPerfilAlter++
                    EndIf

                Else
                    cAlsTemp := GetNextAlias()
                    oTempSA2 := FWTemporaryTable():New(cAlsTemp)
                    aTempFlds := {}
                    AAdd(aTempFlds, {"A2_FILIAL", "C", TamSX3("A2_FILIAL")[1], 0})
                    AAdd(aTempFlds, {"A2_COD",    "C", TamSX3("A2_COD")[1],    0})
                    AAdd(aTempFlds, {"A2_LOJA",   "C", TamSX3("A2_LOJA")[1],   0})
                    oTempSA2:SetFields(aTempFlds)
                    oTempSA2:Create()
                    cTempSql := oTempSA2:GetRealName()

                    TCSqlExec("INSERT INTO " + cTempSql + " (A2_FILIAL, A2_COD, A2_LOJA)" + ;
                              " SELECT A2_FILIAL, A2_COD, A2_LOJA FROM " + cSA2Sql + " WHERE " + cWhereIns)
                    FkCommit()

                    For nPerfil := 1 to Len(aPerfilValidos)
                        cCodF22 := aPerfilValidos[nPerfil]
                        AtualizaMsg(oSay, STR0046 + cCodF22)
                        nPerfilProc++
                        nQtdLote := InsF22SQL(cCodF22, "1", cFilF22, cF22Sql, cTempSql, "T", "A2_COD", "A2_LOJA", "", cColTipo, cValTipo)
                        nQtdProc += nQtdLote
                        If nQtdLote > 0
                            nPerfilAlter++
                        EndIf
                    Next

                    oTempSA2:Delete()
                    FreeObj(oTempSA2)
                EndIf

            EndIf

        ElseIf cAcao == "2"  //--- Exclusao ---

            For nPerfil := 1 to nTamResPer
                cCodF22 := aResumoPerfil[nPerfil][1]
                AtualizaMsg(oSay, STR0046 + cCodF22)
                nPerfilProc++
                nQtdLote := DelF22SQL(cCodF22, "1", cFilF22, cF22Sql, cSA2Sql, "A2_COD", "A2_LOJA", cWhereDel)
                nQtdProc += nQtdLote
                If nQtdLote > 0
                    nPerfilAlter++
                EndIf
            Next

        EndIf

    Else  // cTpWiz == '2': dentro do formulario MVC (FISA164) - sempre N=1 perfil

        cCodF22 := oModel:GetValue("FISA164","F20_CODIGO")

        If cAcao == "1"

            If F22ExistTodos(cCodF22, "1")
                FWAlertWarning("No perfil de participantes ja existe o codigo TODOS, " + ;
                    "sendo assim nao sera adicionado nenhum novo codigo, no perfil: " + cCodF22 + "!", 'Alerta')
            Else
                AtualizaMsg(oSay, STR0046 + cCodF22)
                nPerfilProc := 1
                GrvF20SQL(oModel)
                nQtdProc := InsF22SQL(cCodF22, "1", cFilF22, cF22Sql, cSA2Sql, "SA2", "A2_COD", "A2_LOJA", cWhereN1, cColTipo, cValTipo)
                If nQtdProc > 0
                    nPerfilAlter := 1
                EndIf
            EndIf

        ElseIf cAcao == "2"

            AtualizaMsg(oSay, STR0046 + cCodF22)
            nPerfilProc := 1
            nQtdProc := DelF22SQL(cCodF22, "1", cFilF22, cF22Sql, cSA2Sql, "A2_COD", "A2_LOJA", cWhereDel)
            If nQtdProc > 0
                nPerfilAlter := 1
            EndIf

        EndIf
        lWizOK := .T.
    EndIf

    cMsg := MontaMsgLote(cAcao, "fornecedor(es)", nPerfilProc, nPerfilAlter, nQtdProc, nQtdSel)

    AtualizaMsg(oSay, STR0041)
    MsgInfo(cMsg)

Return .T.

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
Static Function SelFornecedor(oPanel, cAcao, oMarkPerfil)

Local oLCli           := FWLayer():new()
Local aCampos         := {}
Local aColumns        := {}
Local cQuery          := ""
Local cAlsFornecedor  := GetNextAlias()
Local oPanel1         := NIL
Local oPanel2         := NIL
Local oPanel3         := NIL
Local oSayTitulo      := NIL
Local cCodF20         := ""
Local oModel          := Nil
Local aResPer         := {}
Local nPer            := 0

Default oMarkPerfil   := Nil

If ValType(oMarkPerfil) == "O"
    aResPer := MontaResumo(oMarkPerfil, 'F20')
    cCodF20 := ''
    For nPer := 1 to Len(aResPer)
        cCodF20 += IIf(nPer > 1, '|', '') + aResPer[nPer][1]
    Next
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
oLCli:AddWindow('C1','W1',STR0059,100,.F.,.F.,,'L2')
oPanel3 := oLCli:getWinPanel('C1','W1','L2')

//Crio o TSay na primeira linha da Layer
oSayTitulo := TSay():New(5,5,{||STR0060 + Iif(cAcao == '1' ,STR0051 , STR0052) + STR0054},oPanel1,,oFont18,,,,.T.,,,(oPanel1:nWidth / 2) - 10,(oPanel1:nHeight / 2) - 10)
If lMethAlign
    oSayTitulo:SetTextAlign(2,2)
EndIf

aParamQry := {Substr(cA2Tipo,1,1), cA2Estado, cA2GrpTrib, Substr(cA2SimpNac,1,1), Substr(cA2Contrib,1,1), cA2Mun}
cQuery := FSA171QRY("SA2", aParamQry, @aCampos, , , cCodF20, cAcao)

aColumns  := HeaderMark(aCampos)

oMarkFor := AddMarkBro(oPanel3, @lAllFor, aCampos, aColumns, cQuery, cAlsFornecedor, .F.)

Return

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
Local aCmpPerfil   := {}
Local aColPerfil   := {}
Local oSayTitulo   := NIL
Local oPanel1      := NIL
Local oPanel2      := NIL
Local oPanel3      := NIL
Local oPanel4      := NIL
Local cAlsMark     := oMarkFor:cAlias


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
aCmpFOr  := CamposBrw('aAmostra', 'oFornecedor', 'SA2')

//Monta o cabeçalho dos perfis
IF cTpWiz == '1'
    aColPerfil  := HeaderMark(aCmpPerfil, .F.)
EndIF

aColsFor    := HeaderMark(aCmpFor, .F.)

//Monta array de resumo com Perfis selecionados
IF cTpWiz == '1'
    aResumoPerfil  := MontaResumo(oMarkPerfil, 'F20')
EndIF

aAmostra := {}
(cAlsMark)->(DbGoTop())
While (cAlsMark)->(!EOF()) .and. Len(aAmostra) < 50
    AAdd(aAmostra, {(cAlsMark)->A2_COD, (cAlsMark)->A2_LOJA, (cAlsMark)->A2_NOME})
    (cAlsMark)->(DbSkip())
EndDo

//Browse de perfil
IF cTpWiz == '1'
    ADDBrwResumo(@oPerfil, aColPerfil, aResumoPerfil, oPanel2)
EndIF

//Browse de cliente
ADDBrwResumo(@oFornecedor, aColsFor, aAmostra, oPanel4)

Return

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

/*/{Protheus.doc} F22ExistTodos
Funcao estatica valida se tem o valor TODOS no perfil de participantes
@type function
@version 12.1.X
@author joao.manoel
@since 19/03/2026
@param cCodPerfil, character, codigo do pefil de participantes
@param cTipo, character, tipo do perfil de participantes se 1 -> fornecedor, 2-> cliente
@return logical, se encontrar o registro retorna .T.
/*/
Static Function F22ExistTodos(cCodPerfil,cTipo) as logical
    Local lExist    := .F. as logical
    Local oStmt     := Nil    
    Local cSql      := ""
    Local cParTodos := AvKey("TODOS", 'F22_CLIFOR')
    Local cParLoja  := AvKey("ZZ", 'F22_LOJA')    
    Local nTotal    := 0
    
    cSql := "SELECT COUNT(*) TOTAL FROM "+RetSqlName("F22")+" F22 "
    cSql += "WHERE F22.F22_FILIAL = ? "
    cSql += "  AND F22.F22_CODIGO = ? "    
    cSql += "  AND F22.F22_TPPART = ? "
    cSql += "  AND F22.F22_CLIFOR = ? "
    cSql += "  AND F22.F22_LOJA   = ? "
    cSql += "  AND F22.D_E_L_E_T_ = ? "

    oStmt := FWExecStatement():New( ChangeQuery(cSql) )    
    oStmt:SetString(1, xFilial("F22"))
    oStmt:SetString(2, cCodPerfil)    
    oStmt:SetString(3, cTipo)
    oStmt:SetString(4, cParTodos)
    oStmt:SetString(5, cParLoja)
    oStmt:SetString(6, " ") 

    nTotal := oStmt:ExecScalar('TOTAL')

    if nTotal >= 1
        lExist := .T.
    endif

    oStmt:Destroy()
    FreeObj(oStmt)
Return lExist

/*/{Protheus.doc} \
   
     Retorna clausula de filtros de SA1 sem a palavra WHERE.

    @type  Static Function MontaWSA1
    @author Ricardo Henrique de Mello Lima
    @since 12/05/2026
    @version 12.1.2510
    @param aParamQry  array, parametros do wizard
    @param cPref      character, prefixo de alias: "" | "SA1." | "SRC."
    @return character
/*/

Static Function MontaWSA1(aParamQry, cPref)

    Local cW := cPref + "A1_FILIAL = " + ValToSQL(xFilial("SA1"))

    If !Empty(aParamQry[1]) ; cW += " AND " + cPref + "A1_PESSOA  = " + ValToSQL(aParamQry[1]) ; EndIf
    If !Empty(aParamQry[2]) ; cW += " AND " + cPref + "A1_TIPO    = " + ValToSQL(aParamQry[2]) ; EndIf
    If !Empty(aParamQry[3]) ; cW += " AND " + cPref + "A1_TPESSOA = " + ValToSQL(aParamQry[3]) ; EndIf
    If !Empty(aParamQry[4]) ; cW += " AND " + cPref + "A1_SIMPNAC = " + ValToSQL(aParamQry[4]) ; EndIf
    If !Empty(aParamQry[5]) ; cW += " AND " + cPref + "A1_CONTRIB = " + ValToSQL(aParamQry[5]) ; EndIf
    If !Empty(aParamQry[6]) ; cW += " AND " + cPref + "A1_GRPTRIB = " + ValToSQL(aParamQry[6]) ; EndIf
    If !Empty(aParamQry[7]) ; cW += " AND " + cPref + "A1_EST     = " + ValToSQL(aParamQry[7]) ; EndIf
    If !Empty(aParamQry[8]) ; cW += " AND " + cPref + "A1_GRPVEN  = " + ValToSQL(aParamQry[8]) ; EndIf
    If !Empty(aParamQry[9]) .AND. !Empty(aParamQry[7])
        cW += " AND " + cPref + "A1_COD_MUN = " + ValToSQL(aParamQry[9])
    EndIf
    If fisExtCmp('12.1.2310', .F., 'SA1', 'A1_MSBLQL')
        cW += " AND " + cPref + "A1_MSBLQL <> '1'"
    EndIf
    cW += " AND " + cPref + "D_E_L_E_T_  = ' '"
Return cW

/*/{Protheus.doc} \
   
    Retorna clausula de filtros de SA2 sem a palavra WHERE.

    @type  Static Function InsF22SQL
    @author Ricardo Henrique de Mello Lima
    @since 12/05/2026
    @version 12.1.2510
    @param aParamQry  array, parametros do wizard
    @param cPref      character, prefixo de alias: "" | "SA2." | "SRC."
/*/
Static Function MontaWSA2(aParamQry, cPref)

    Local cW := cPref + "A2_FILIAL = " + ValToSQL(xFilial("SA2"))

    If !Empty(aParamQry[1]) ; cW += " AND " + cPref + "A2_TIPO    = " + ValToSQL(aParamQry[1]) ; EndIf
    If !Empty(aParamQry[2]) ; cW += " AND " + cPref + "A2_EST     = " + ValToSQL(aParamQry[2]) ; EndIf
    If !Empty(aParamQry[3]) ; cW += " AND " + cPref + "A2_GRPTRIB = " + ValToSQL(aParamQry[3]) ; EndIf
    If !Empty(aParamQry[4]) ; cW += " AND " + cPref + "A2_SIMPNAC = " + ValToSQL(aParamQry[4]) ; EndIf
    If !Empty(aParamQry[5]) ; cW += " AND " + cPref + "A2_CONTRIB = " + ValToSQL(aParamQry[5]) ; EndIf
    If !Empty(aParamQry[6]) .AND. !Empty(aParamQry[2])
        cW += " AND " + cPref + "A2_COD_MUN = " + ValToSQL(aParamQry[6])
    EndIf
    If fisExtCmp('12.1.2310', .F., 'SA2', 'A2_MSBLQL')
        cW += " AND " + cPref + "A2_MSBLQL <> '1'"
    EndIf
    cW += " AND " + cPref + "D_E_L_E_T_  = ' '"

Return cW


/*/{Protheus.doc} \
   
    INSERT em lote na F22 via LEFT JOIN anti-join a partir de qualquer tabela fonte.
    Funciona para SA1, SA2 ou tabela temporaria (N>1 perfis).

    @type  Static Function InsF22SQL
    @author Ricardo Henrique de Mello Lima
    @since 12/05/2026
    @version 12.1.2510

    @param cCodF22    character, codigo do perfil F22
    @param cTpPart    character, "1"=fornecedor / "2"=cliente
    @param cFilF22    character, filial F22
    @param cF22Sql    character, nome SQL da F22
    @param cSrcSql    character, nome SQL da fonte (SA1, SA2 ou temp)
    @param cSrcAlias  character, alias da fonte na query ("SA1", "SA2" ou "T")
    @param cCodFld    character, campo codigo ("A1_COD" ou "A2_COD")
    @param cLojaFld   character, campo loja   ("A1_LOJA" ou "A2_LOJA")
    @param cWhereAdd  character, condicoes extras pos-LEFT JOIN; "" quando a fonte ja foi filtrada (temp)
    @param cColTipo   character, ", F22_TIPOPF" ou ""
    @param cValTipo   character, ", '02'" ou ""
/*/
Static Function InsF22SQL(cCodF22, cTpPart, cFilF22, cF22Sql, cSrcSql, cSrcAlias, cCodFld, cLojaFld, cWhereAdd, cColTipo, cValTipo)

    Local oStmt := NIL
    Local cCnt  := ""
    Local nQtd  := 0
    Local cIns := ""
    Local cExistF20 := ""

    cExistF20 := " AND EXISTS (SELECT 1 FROM " + RetSqlName("F20") + " F20E"
    cExistF20 += " WHERE F20E.F20_FILIAL = " + ValToSQL(cFilF22)
    cExistF20 += " AND F20E.F20_CODIGO = " + ValToSQL(cCodF22)
    cExistF20 += " AND F20E.F20_TIPO   = '02'"
    cExistF20 += " AND F20E.D_E_L_E_T_ = ' ')"

    cCnt  := "SELECT COUNT(1) TOTAL"
    cCnt  += " FROM " + cSrcSql + " " + cSrcAlias
    cCnt  += " LEFT JOIN " + cF22Sql + " F22X"
    cCnt  += " ON  F22X.F22_FILIAL = " + ValToSQL(cFilF22)
    cCnt  += " AND F22X.F22_CODIGO = " + ValToSQL(cCodF22)
    cCnt  += " AND F22X.F22_TPPART = '" + cTpPart + "'"
    cCnt  += " AND F22X.F22_CLIFOR = " + cSrcAlias + "." + cCodFld
    cCnt  += " AND F22X.F22_LOJA   = " + cSrcAlias + "." + cLojaFld
    cCnt  += " AND F22X.D_E_L_E_T_ = ' '"
    cCnt  += " WHERE F22X.R_E_C_N_O_ IS NULL " + cWhereAdd + cExistF20

    oStmt := FWExecStatement():New(ChangeQuery(cCnt))
    nQtd  := oStmt:ExecScalar("TOTAL")
    oStmt:Destroy()

    cIns  := "INSERT INTO " + cF22Sql
    cIns  += " (R_E_C_N_O_, F22_FILIAL, F22_CODIGO, F22_TPPART, F22_CLIFOR, F22_LOJA" + cColTipo + ", D_E_L_E_T_)"
    cIns  += " SELECT COALESCE((SELECT MAX(R_E_C_N_O_) FROM " + cF22Sql + "), 0)"
    cIns  +=        " + ROW_NUMBER() OVER (ORDER BY " + cSrcAlias + "." + cCodFld + ", " + cSrcAlias + "." + cLojaFld + "),"
    cIns  +=        " " + ValToSQL(cFilF22) + ", " + ValToSQL(cCodF22) + ","
    cIns  +=        " '" + cTpPart + "', " + cSrcAlias + "." + cCodFld + ", " + cSrcAlias + "." + cLojaFld + cValTipo + ", ' '"
    cIns  += " FROM " + cSrcSql + " " + cSrcAlias
    cIns  += " LEFT JOIN " + cF22Sql + " F22X"
    cIns  += " ON  F22X.F22_FILIAL = " + ValToSQL(cFilF22)
    cIns  += " AND F22X.F22_CODIGO = " + ValToSQL(cCodF22)
    cIns  += " AND F22X.F22_TPPART = '" + cTpPart + "'"
    cIns  += " AND F22X.F22_CLIFOR = " + cSrcAlias + "." + cCodFld
    cIns  += " AND F22X.F22_LOJA   = " + cSrcAlias + "." + cLojaFld
    cIns  += " AND F22X.D_E_L_E_T_ = ' '"
    cIns  += " WHERE F22X.R_E_C_N_O_ IS NULL " + cWhereAdd + cExistF20
    
    TCSqlExec(cIns)
    FkCommit()
Return nQtd

/*/{Protheus.doc} \
   
    DELETE em lote na F22 respeitando os filtros de origem via EXISTS.

    @type  Static Function GrvF20SQL
    @author Ricardo Henrique de Mello Lima
    @since 12/05/2026
    @version 12.1.2510

    @param cCodF22   character, codigo do perfil F22
    @param cTpPart   character, "1"=fornecedor / "2"=cliente
    @param cFilF22   character, filial F22
    @param cF22Sql   character, nome SQL da F22
    @param cSrcSql   character, nome SQL da origem (SA1 ou SA2)
    @param cCodFld   character, "A1_COD" ou "A2_COD"
    @param cLojaFld  character, "A1_LOJA" ou "A2_LOJA"
    @param cWhere    character, filtros com prefixo "SRC." (ex: MontaWSA1(aParamQry,"SRC."))
/*/

Static Function DelF22SQL(cCodF22, cTpPart, cFilF22, cF22Sql, cSrcSql, cCodFld, cLojaFld, cWhere)
    
    Local oStmt := NIL
    Local cCnt  := ""
    Local nQtd  := 0
    Local cDel := "" as character

    cCnt := "SELECT COUNT(1) TOTAL FROM " + cF22Sql
    cCnt += " WHERE F22_FILIAL = " + ValToSQL(xFilial("F22"))
    cCnt += " AND F22_CODIGO   = " + ValToSQL(cCodF22)
    cCnt += " AND F22_TPPART   = '" + cTpPart + "'"
    cCnt += " AND D_E_L_E_T_   = ' '"
    cCnt += " AND EXISTS (SELECT 1 FROM " + cSrcSql + " SRC"
    cCnt += "             WHERE SRC." + cCodFld  + " = " + cF22Sql + ".F22_CLIFOR"
    cCnt += "             AND SRC." + cLojaFld + "  = " + cF22Sql + ".F22_LOJA"
    cCnt += "             AND " + cWhere + ")"

    oStmt := FWExecStatement():New(ChangeQuery(cCnt))
    nQtd  := oStmt:ExecScalar("TOTAL")
    oStmt:Destroy()
    
    cDel := "DELETE FROM " + cF22Sql
    cDel += " WHERE F22_FILIAL = " + ValToSQL(xFilial("F22"))
    cDel += " AND F22_CODIGO   = " + ValToSQL(cCodF22)
    cDel += " AND F22_TPPART   = '" + cTpPart + "'"
    cDel += " AND D_E_L_E_T_   = ' '"
    cDel += " AND EXISTS (SELECT 1 FROM " + cSrcSql + " SRC"
    cDel += "             WHERE SRC." + cCodFld  + " = " + cF22Sql + ".F22_CLIFOR"
    cDel += "             AND SRC." + cLojaFld + "  = " + cF22Sql + ".F22_LOJA"
    cDel += "             AND " + cWhere + ")"
    TCSqlExec(cDel)
    FkCommit()
Return nQtd


/*/{Protheus.doc} \
   
    Garante cabecalho F20 ativo antes da gravacao em lote do detalhe (F22/F24).
    Corrige exclusoes legadas, reativa registro excluido logico ou insere novo.

    @type  Static Function EnsF20SQL
    @author Ricardo Henrique de Mello Lima
    @since 09/06/2026
    @version 12.1.2510
    @param cFilF20  character, filial F20
    @param cCodF20  character, codigo do perfil
    @param cDesc    character, descricao do perfil
    @param cTipo    character, tipo do perfil (ex.: '02' participante, '04' produto)
/*/
Static Function EnsF20SQL(cFilF20, cCodF20, cDesc, cTipo)

    Local cF20Sql   := RetSqlName("F20")
    Local lOracle   := "ORACLE" $ Upper(TcGetDB())
    Local cFromDual := ""
    Local cUpd      := ""
    Local cIns      := ""

    If lOracle
        cFromDual := " FROM DUAL"
    EndIf

    cUpd := "UPDATE " + cF20Sql + " SET R_E_C_D_E_L_ = R_E_C_N_O_"
    cUpd += " WHERE F20_FILIAL = " + ValToSQL(cFilF20)
    cUpd += " AND F20_CODIGO   = " + ValToSQL(cCodF20)
    cUpd += " AND F20_TIPO     = " + ValToSQL(cTipo)
    cUpd += " AND D_E_L_E_T_   = '*'"
    cUpd += " AND R_E_C_D_E_L_ = 0"
    TCSqlExec(cUpd)

    cUpd := "UPDATE " + cF20Sql + " SET D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = 0,"
    cUpd += " F20_DESC = " + ValToSQL(cDesc) + ", F20_STATUS = '1'"
    cUpd += " WHERE F20_FILIAL = " + ValToSQL(cFilF20)
    cUpd += " AND F20_CODIGO   = " + ValToSQL(cCodF20)
    cUpd += " AND F20_TIPO     = " + ValToSQL(cTipo)
    cUpd += " AND D_E_L_E_T_   = '*'"
    cUpd += " AND R_E_C_N_O_   = (SELECT MAX(F20M.R_E_C_N_O_) FROM " + cF20Sql + " F20M"
    cUpd += "   WHERE F20M.F20_FILIAL = " + ValToSQL(cFilF20)
    cUpd += "   AND F20M.F20_CODIGO = " + ValToSQL(cCodF20)
    cUpd += "   AND F20M.F20_TIPO   = " + ValToSQL(cTipo)
    cUpd += "   AND F20M.D_E_L_E_T_ = '*')"
    TCSqlExec(cUpd)

    cIns := "INSERT INTO " + cF20Sql
    cIns += " (R_E_C_N_O_, R_E_C_D_E_L_, F20_FILIAL, F20_CODIGO, F20_DESC, F20_TIPO, F20_STATUS, D_E_L_E_T_)"
    cIns += " SELECT COALESCE((SELECT MAX(R_E_C_N_O_) FROM " + cF20Sql + "), 0) + 1,"
    cIns += " 0, " + ValToSQL(cFilF20) + ", " + ValToSQL(cCodF20) + ","
    cIns += " " + ValToSQL(cDesc) + ","
    cIns += " " + ValToSQL(cTipo) + ","
    cIns += " '1', ' '"
    cIns += cFromDual
    cIns += " WHERE NOT EXISTS (SELECT 1 FROM " + cF20Sql
    cIns += "   WHERE F20_FILIAL = " + ValToSQL(cFilF20)
    cIns += "   AND   F20_CODIGO = " + ValToSQL(cCodF20)
    cIns += "   AND   F20_TIPO   = " + ValToSQL(cTipo)
    cIns += "   AND   D_E_L_E_T_ = ' ')"

    TCSqlExec(cIns)
    FkCommit()

Return NIL

/*/{Protheus.doc} \
   
    INSERT condicional em F20 via SQL. Grava o perfil caso ainda nao exista
    no banco (cenario de inclusao pelo formulario MVC antes do FwFormCommit).

    @type  Static Function GrvF20SQL
    @author Ricardo Henrique de Mello Lima
    @since 12/05/2026
    @version 12.1.2510
/*/
Static Function GrvF20SQL(oModel)

    EnsF20SQL(xFilial("F20"), ;
        oModel:GetValue("FISA164", "F20_CODIGO"), ;
        oModel:GetValue("FISA164", "F20_DESC"), ;
        oModel:GetValue("FISA164", "F20_TIPO"))

Return NIL

/*/{Protheus.doc} \
   
    Retorna clausula de filtros de SB1 sem a palavra WHERE.

    @type  Static Function MontaWSB1
    @author Ricardo Henrique de Mello Lima
    @since 20/05/2026
    @version 12.1.2510
    @param aParamQry  array, parametros do wizard
    @param cPref      character, prefixo de alias: "" | "SB1." | "SRC."
    @return character
/*/
Static Function MontaWSB1(aParamQry, cPref)

    Local cW := cPref + "B1_FILIAL = " + ValToSQL(xFilial("SB1"))

    If !Empty(aParamQry[1]) .And. !Empty(aParamQry[2])
        cW += " AND (" + cPref + "B1_COD >= " + ValToSQL(aParamQry[1])
        cW += " AND " + cPref + "B1_COD <= " + ValToSQL(aParamQry[2]) + ")"
    EndIf

    If !Empty(aParamQry[3]) .And. !Empty(aParamQry[4])
        cW += " AND (" + cPref + "B1_POSIPI >= " + ValToSQL(aParamQry[3])
        cW += " AND " + cPref + "B1_POSIPI <= " + ValToSQL(aParamQry[4]) + ")"
    EndIf

    If !Empty(aParamQry[5])
        cW += " AND " + cPref + "B1_TIPO = " + ValToSQL(aParamQry[5])
    EndIf

    If !Empty(aParamQry[6])
        cW += " AND " + cPref + "B1_GRTRIB = " + ValToSQL(aParamQry[6])
    EndIf

    If !Empty(aParamQry[7])
        cW += " AND " + cPref + "B1_ORIGEM IN " + FormatIn(aParamQry[7], "|")
    EndIf

    If !Empty(aParamQry[8]) .And. !Empty(aParamQry[9])
        cW += " AND (" + cPref + "B1_CEST >= " + ValToSQL(aParamQry[8])
        cW += " AND " + cPref + "B1_CEST <= " + ValToSQL(aParamQry[9]) + ")"
    EndIf

    If !Empty(aParamQry[10]) .And. !Empty(aParamQry[11])
        cW += " AND (" + cPref + "B1_GRUPO >= " + ValToSQL(aParamQry[10])
        cW += " AND " + cPref + "B1_GRUPO <= " + ValToSQL(aParamQry[11]) + ")"
    EndIf

    If fisExtCmp('12.1.2310', .F., 'SB1', 'B1_MSBLQL')
        cW += " AND " + cPref + "B1_MSBLQL <> '1'"
    EndIf

    cW += " AND " + cPref + "D_E_L_E_T_ = ' '"

Return cW

/*/{Protheus.doc} \
   
    INSERT em lote na F24 via LEFT JOIN anti-join a partir de qualquer tabela fonte.
    Funciona para SB1 ou tabela temporaria (N>1 perfis).

    @type  Static Function InsF24SQL
    @author Ricardo Henrique de Mello Lima
    @since 20/05/2026
    @version 12.1.2510
/*/
Static Function InsF24SQL(cCodF20, cFilF24, cF24Sql, cSrcSql, cSrcAlias, cCodFld, cWhereAdd, cColTipo, cValTipo, cJoinTipo)

    Local oStmt := NIL
    Local cCnt  := ""
    Local nQtd  := 0
    Local cIns := ""

    cCnt  := "SELECT COUNT(1) TOTAL"
    cCnt  += " FROM " + cSrcSql + " " + cSrcAlias
    cCnt  += " LEFT JOIN " + cF24Sql + " F24X"
    cCnt  += " ON  F24X.F24_FILIAL = " + ValToSQL(cFilF24)
    cCnt  += " AND F24X.F24_CODIGO = " + ValToSQL(cCodF20)
    cCnt  += " AND F24X.F24_CDPROD = " + cSrcAlias + "." + cCodFld
    cCnt  += cJoinTipo
    cCnt  += " AND F24X.D_E_L_E_T_ = ' '"
    cCnt  += " WHERE F24X.R_E_C_N_O_ IS NULL " + cWhereAdd

    oStmt := FWExecStatement():New(ChangeQuery(cCnt))
    nQtd  := oStmt:ExecScalar("TOTAL")
    oStmt:Destroy()

    cIns  := "INSERT INTO " + cF24Sql
    cIns  += " (R_E_C_N_O_, F24_FILIAL, F24_CODIGO, F24_CDPROD" + cColTipo + ", D_E_L_E_T_)"
    cIns  += " SELECT COALESCE((SELECT MAX(R_E_C_N_O_) FROM " + cF24Sql + "), 0)"
    cIns  += " + ROW_NUMBER() OVER (ORDER BY " + cSrcAlias + "." + cCodFld + "),"
    cIns  += " " + ValToSQL(cFilF24) + ", " + ValToSQL(cCodF20) + ","
    cIns  += " " + cSrcAlias + "." + cCodFld + cValTipo + ", ' '"
    cIns  += " FROM " + cSrcSql + " " + cSrcAlias
    cIns  += " LEFT JOIN " + cF24Sql + " F24X"
    cIns  += " ON  F24X.F24_FILIAL = " + ValToSQL(cFilF24)
    cIns  += " AND F24X.F24_CODIGO = " + ValToSQL(cCodF20)
    cIns  += " AND F24X.F24_CDPROD = " + cSrcAlias + "." + cCodFld
    cIns  += cJoinTipo
    cIns  += " AND F24X.D_E_L_E_T_ = ' '"
    cIns  += " WHERE F24X.R_E_C_N_O_ IS NULL " + cWhereAdd

    TCSqlExec(cIns)
    FkCommit()
Return nQtd

/*/{Protheus.doc} \
   
    DELETE em lote na F24 respeitando os filtros de origem via EXISTS.

    @type  Static Function DelF24SQL
    @author Ricardo Henrique de Mello Lima
    @since 20/05/2026
    @version 12.1.2510
/*/
Static Function DelF24SQL(cCodF20, cFilF24, cF24Sql, cSrcSql, cCodFld, cWhere, cJoinTipo)

    Local oStmt := NIL
    Local cCnt  := ""
    Local nQtd  := 0
    Local cDel := ""

    cCnt := "SELECT COUNT(1) TOTAL FROM " + cF24Sql
    cCnt += " WHERE F24_FILIAL = " + ValToSQL(cFilF24)
    cCnt += " AND F24_CODIGO   = " + ValToSQL(cCodF20)
    cCnt += cJoinTipo
    cCnt += " AND D_E_L_E_T_   = ' '"
    cCnt += " AND EXISTS (SELECT 1 FROM " + cSrcSql + " SRC"
    cCnt += "             WHERE SRC." + cCodFld + " = " + cF24Sql + ".F24_CDPROD"
    cCnt += "             AND " + cWhere + ")"

    oStmt := FWExecStatement():New(ChangeQuery(cCnt))
    nQtd  := oStmt:ExecScalar("TOTAL")
    oStmt:Destroy()

    cDel := "DELETE FROM " + cF24Sql
    cDel += " WHERE F24_FILIAL = " + ValToSQL(cFilF24)
    cDel += " AND F24_CODIGO   = " + ValToSQL(cCodF20)
    cDel += cJoinTipo
    cDel += " AND D_E_L_E_T_   = ' '"
    cDel += " AND EXISTS (SELECT 1 FROM " + cSrcSql + " SRC"
    cDel += "             WHERE SRC." + cCodFld + " = " + cF24Sql + ".F24_CDPROD"
    cDel += "             AND " + cWhere + ")"

    TCSqlExec(cDel)
    FkCommit()
Return nQtd

/*/{Protheus.doc} \
   
    INSERT condicional em F20 via SQL para o fluxo cTpWiz='2' da FISA166.

    @type  Static Function GrvF20SQLPRD
    @author Ricardo Henrique de Mello Lima
    @since 20/05/2026
    @version 12.1.2510
/*/
Static Function GrvF20SQLPRD(oModel)

    EnsF20SQL(xFilial("F20"), ;
        oModel:GetValue("FISA166", "F20_CODIGO"), ;
        oModel:GetValue("FISA166", "F20_DESC"), ;
        oModel:GetValue("FISA166", "F20_TIPO"))

Return NIL
