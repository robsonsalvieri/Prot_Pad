#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDef.ch'

#DEFINE ARQUIVO_LOG	"cen_sip_wizard.log"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenSIPWiz

	Funcao que monta a tela do Wizard
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Function CenSIPWiz(lHabMetric)
    Local oPanel
    Local oNewPag
    Local oStepWiz     := nil
    Local oDlg         := nil
    Local cPar9       := Space(3)
    Local aPar7        :=   {"","","","","","","","","","","","","","","","","","","","","","","","","",""}
    Default lHabMetric := .F.

    CenBusPro(@aPar7)

    oFontCabec := TFont():New('Arial',,-13,,.T.)

    DEFINE DIALOG oDlg TITLE 'Wizard de Parametrização Central de Obrigações SIP' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )
    oDlg:nWidth  := 1450
    oDlg:nHeight := 760

    oPanel:= tPanel():New(0,0,"",oDlg,,,,,,300,300)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    oStepWiz:= FWWizardControl():New(oPanel)
    oStepWiz:ActiveUISteps()

    //----------------------
    // Pagina 1
    //----------------------
    oNewPag := oStepWiz:AddStep("1PASSO")
    oNewPag:SetStepDescription("Compromisso Status")
    oNewPag:SetConstruction({|Panel|cria_pg1(Panel)})
    oNewPag:SetNextAction({||valida_pg1()})
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 1"), .T., oDlg:End()})

    //----------------------
    // Pagina 2
    //----------------------
    oNewPag := oStepWiz:AddStep("2PASSO", {|Panel|cria_pg2(Panel)})
    oNewPag:SetStepDescription("Segmentação e   Tipo Contrato")
    oNewPag:SetNextAction({||valida_pg2()})
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 2"), .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")

    //----------------------
    // Pagina 3
    //----------------------
    oNewPag := oStepWiz:AddStep("3PASSO", {|Panel|cria_pg3(Panel)})
    oNewPag:SetStepDescription("Natureza de Saúde")
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 3"), .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")

    //----------------------
    // Pagina 4
    //----------------------
    oNewPag := oStepWiz:AddStep("4PASSO", {|Panel|cria_pg4(Panel)})
    oNewPag:SetStepDescription("Especialidade")
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 4"), .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")

    //----------------------
    // Pagina 5
    //----------------------
    oNewPag := oStepWiz:AddStep("5PASSO", {|Panel|cria_pg5(Panel)})
    oNewPag:SetStepDescription("Produto Saúde")
    oNewPag:SetNextAction({||valida_pg5()})
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 5"), .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")

    //----------------------
    // Pagina 6
    //----------------------
    oNewPag := oStepWiz:AddStep("6PASSO", {|Panel|cria_pg6(Panel)})
    oNewPag:SetStepDescription("Produto Saúde - Cons.ANS")
    oNewPag:SetNextAction({||valida_pg6()})
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 6"), .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")


    //----------------------
    // Pagina 7
    //----------------------
    oNewPag := oStepWiz:AddStep("7PASSO", {|Panel|cria_pg7(Panel,@aPar7)})
    oNewPag:SetStepDescription("Tabela Padrão - Expostos")
    oNewPag:SetNextAction({||valida_pg7(aPar7)})
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 7"), .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")

    //----------------------
    // Pagina 8
    //----------------------
    oNewPag := oStepWiz:AddStep("8PASSO", {|Panel|cria_pg8(Panel,@aPar7)})
    oNewPag:SetStepDescription("Tabela Padrão - Expostos Od.")
    oNewPag:SetNextAction({||valida_pg8(aPar7)})
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 8"), .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")

    //----------------------
    // Pagina 9
    //----------------------
    oNewPag := oStepWiz:AddStep("9PASSO", {|Panel|cria_pg9(Panel)})
    oNewPag:SetStepDescription("Tabela Padrão - SIP X TUSS")
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 9"), .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")


    //----------------------
    // Pagina 10
    //----------------------
    oNewPag := oStepWiz:AddStep("10PASSO", {|Panel|cria_pg10(Panel, @cPar9)})
    oNewPag:SetStepDescription("Importações e Validações")
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 10"), .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")


    //----------------------
    // Pagina 11
    //----------------------
    oNewPag := oStepWiz:AddStep("11PASSO", {|Panel|cria_pg11(Panel)})
    oNewPag:SetStepDescription("Download dos XSDs SIP")
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 11"), .T., oDlg:End()})
    oNewPag:SetPrevAction({|| .T.})
    oNewPag:SetPrevTitle("Voltar")

    //----------------------
    // Pagina 12
    //----------------------
    oNewPag := oStepWiz:AddStep("12PASSO", {|Panel|cria_pn12(Panel)})
    oNewPag:SetStepDescription("Wizard Finalizado")
    oNewPag:SetNextAction({||CenPrcSIP(lHabMetric,aPar7,cPar9) , .T., oDlg:End()})
    oNewPag:SetCancelAction({||Alert("Cancelou na Etapa 12"), .T., oDlg:End()})
    oNewPag:SetCancelWhen({||.T.})
    oStepWiz:Activate()

    ACTIVATE DIALOG oDlg CENTER
    oStepWiz:Destroy()

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPrcSIP

	Funcao acionada após o concluir do wizard. Processa tudo que foi colhido nas telas do wizard e aciona as métricas
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Function CenPrcSIP(lHabMetric,aPar7,cPar9)
    Default lHabMetric := .F.

    if lHabMetric
        FWMetrics():addMetrics("CenSIPWiz - Wizard SIP", {{"totvs-saude-central-obrigacoes_Wizard-SIP", 1 }} )
    endif

    ContrProc(B3D->B3D_ANO+Substr(B3D->B3D_CODIGO,2,2),B3D->B3D_CODOPE,aPar7,cPar9)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ContrProc

	Dispara funções ao concluir o Wizard
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Function ContrProc(cTrirec,cRegANS,aPar7,cPar9)
    Default cTrirec := ""
    Default cRegANS := ""
    Default aPar7   := {}

    MsgRun("Finaliza Compromissos Anteriores..."                                      ,"TOTVS",{||DelUpdSip("B3D",cTrirec)})   //fecho compromissos anteriores
    MsgRun("Recriando tabela de Natureza de Saúde..."                                 ,"TOTVS",{||DelUpdSip("BF0",cTrirec)})   //deleto a tabela BF0, pois será criado uma nova
    MsgRun("Ajustando Especialidades..."                                              ,"TOTVS",{||AjuEspSip(cTrirec)})         //ajusto especialidades de acordo com o CBO
    MsgRun("Campo Informa ANS no Beneficiário, Contrato e Subcontrato..."             ,"TOTVS",{||CenPlaPls(cTrirec)})         //marco INFANS nos contratos, beneficiários e subcontrato
    MsgRun("Parametrizando expostos na tabela Padrão..."                              ,"TOTVS",{||CenTbExp(cTrirec,aPar7)})    //Indico procedimentos nromais e odonto que serão utilizados como expostos
    MsgRun("Classificando Tabela Padrão conforme  SIP X TUSS..."                      ,"TOTVS",{||CenSipTus(cTrirec,aPar7)})   //parametrizo tabela padrão de acordo com tabela TUSS
    MsgRun("Importando/ Validando Produtos e Beneficiários..."                        ,"TOTVS",{||CenImpVal(cTriRec,cPar9)})   //Importar e Validar Produtos e beneficiários
    MsgRun("Baixando arquivos XSDs necessários para o SIP.."                          ,"TOTVS",{||CenDowFil(cTriRec)})         //baixo os XSDs do SIP

    MsgInfo("Processamento do Wizard SIP Finalizado!")

Return

//----------------------------------------
// Validação do botão Próximo da página 1
//----------------------------------------
Static Function valida_pg1()
    Local aAreaBA0 := BA0->(GetArea())
    Local lRetorno := .T.
    Local cSql     := ""
    Local aRegs    := {}
    Local cMsg     := ""
    Local lPlExco  := GetNewPar("MV_PLSEXCO",.F.)

    If Alltrim(B3D->B3D_STATUS) == '6'
        cMsg+= + CRLF +"Para utilizar o Wizard, o Status do compromisso atual não pode ser finalizado(Verde). Saia do Wizard, clique no botão Obrigações, escolha a opção Mudar Status Compromisso."
        lRetorno:= .f.
    EndIF

    If lRetorno
        BA0->(dbSetOrder(5))
        If BA0->(dbSeek(xFilial("BA0")+B3D->B3D_CODOPE)) //vi que ele tem o vinculo da operadora na Central com o PLS.
            //agora preciso saber se há mais de um vinculo. Caso tenha mais de um registro na BA0 com o mesmo SUSEP critico.
            cSql := " SELECT COUNT(*) TOTAL FROM " + RetSqlName("BA0") + " "
            cSql += " WHERE BA0_FILIAL = '" + xFilial("BA0") + "' AND BA0_SUSEP = '" + BA0->BA0_SUSEP +"' "
            cSql += " AND D_E_L_E_T_ = ' ' "

            cSql := ChangeQuery(cSql)

            dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBA0",.F.,.T.)

            lRetorno:= TRBBA0->TOTAL == 1

            TRBBA0->(DBCloseArea())

            If !lRetorno
                cMsg+= + CRLF +"Há mais de uma Operadora no módulo Plano de Saúde, com o campo Num Reg ANS (BA0_SUSEP) preenchido como  "+ BA0->BA0_SUSEP +". Deve existir apenas 1 vínculo. Favor ajustar! "
            EndIF
        Else
            cMsg+= + CRLF +"O Número do Registro desta Operadora ("+B3D->B3D_CODOPE+") deve estar associado a apenas uma Operadora do Módulo Plano de Saúde. No campo Num Reg ANS (BA0_SUSEP). Favor ajustar!"
            lRetorno:= .F.
        EndIf

        IF !("2" $ GetNewPar("MV_PLSTIPO",""))
            cMsg+= + CRLF +"Favor corrigir o parâmetro MV_PLSTIPO. Ele deve ter o conteúdo 1,2 "
            lRetorno:= .F.
        EndIf

        IF !lPlExco
            cMsg+= + CRLF +"Favor corrigir o parâmetro MV_PLSEXCO. Ele deve ter o conteúdo igual a .T. "
            lRetorno:= .F.
        EndIf

        If ExistBlock("PLSDADCON")
            aRegs:= ExecBlock("PLSDADCON",.f.,.f.,{})

            If ValType(aRegs) <> "A" .Or. (Len(aRegs)>0 .And. Len(aRegs[1])==0)
                cMsg+= + CRLF +"Favor avaliar o retorno do Ponto de Entrada PLSDADCON antes de prosseguir."
                lRetorno:= .F.
            EndIf

        Endif
        BA0->(RestArea(aAreaBA0))

    EndIF

    If !Empty(cMsg)
        MsgInfo(cMsg)
    EndIf

Return lRetorno

//----------------------------------------
// Validação do botão Próximo da página 2
//----------------------------------------
Static Function valida_pg2()
    Local cSql    := ""
    Local cMsg    := "As segmentações abaixo permanecem com o campo Seg.SIP (BI6_SEGSIP) em branco: "
    Local nCnt    := 0
    Local nCnt1   := 0

    cMsg+=  + CRLF +""

    cSql := " SELECT BI6_CODSEG,BI6_DESCRI FROM " + RetSqlName("BI6") + " "
    cSql += " WHERE BI6_FILIAL = '" + xFilial("BI6") + "' "
    cSql += " AND BI6_SEGSIP = ' ' "
    cSql += " AND D_E_L_E_T_ = ' ' "

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBI6",.F.,.T.)

    Do While !TRBBI6->(Eof())
        nCnt++
        cMsg+= + CRLF + Alltrim(TRBBI6->BI6_CODSEG) +"-"+ Alltrim(TRBBI6->BI6_DESCRI) +""
        TRBBI6->(DBSkip())
    EndDo

    If nCnt > 0
        cMsg+= + CRLF + ""
        cMsg+= + CRLF + "Favor Ajustar todas Segmentações"
        cMsg+= + CRLF + ""
    Else
        cMsg:=""
    EndIf

    cSql := " SELECT BII_CODIGO,BII_DESCRI FROM " + RetSqlName("BII") + " "
    cSql += " WHERE BII_FILIAL = '" + xFilial("BII") + "' "
    cSql += " AND BII_TIPPLA = ' ' "
    cSql += " AND D_E_L_E_T_ = ' ' "

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBII",.F.,.T.)

    Do While !TRBBII->(Eof())
        If nCnt1 == 0
            cMsg+= + CRLF + "Os Tipos de Contratos abaixo, estão com o campo Tp Plano (BII_TIPPLA) em branco:"
            cMsg+= + CRLF + ""
        EndIf
        nCnt1++
        cMsg+= + CRLF + Alltrim(TRBBII->BII_CODIGO) +"-"+ Alltrim(TRBBII->BII_DESCRI) +""
        TRBBII->(DBSkip())
    EndDo

    If nCnt1 > 0
        cMsg +=  + CRLF + ""
        cMsg +=  + CRLF + "Favor Ajustar todos os Tipos de Contrato"
    EndIf

    If nCnt > 0 .Or. nCnt1 > 0
        MsgInfo(cMsg)
    EndIf

    TRBBII->(dbCloseArea())
    TRBBI6->(dbCloseArea())


Return nCnt == 0 .And. nCnt1 == 0

//----------------------------------------
// Validação do botão Próximo da página 5
//----------------------------------------
Static Function valida_pg5()
    Local cSql    := ""
    Local cMsg    := ""

    cSql := " SELECT BI3_CODIGO,BI3_DESCRI,BI3_CODSEG,BI3_TIPCON,BI3_VERSAO FROM " + RetSqlName("BI3") + " "
    cSql += " WHERE BI3_FILIAL = '" + xFilial("BI3") + "' "
    cSql += " AND (BI3_CODSEG = ' ' OR BI3_TIPCON = ' ') "
    cSql += " AND BI3_GRUPO = '001' "
    cSql += " AND D_E_L_E_T_ = ' ' "

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBI3",.F.,.T.)

    Do While !TRBBI3->(Eof())

        cMsg+= " " + CRLF + "Campos em branco no Produto/Versão: " +TRBBI3->(BI3_CODIGO+BI3_VERSAO)+" - "+Alltrim(TRBBI3->BI3_DESCRI)+" " + CRLF + ""

        If Empty(TRBBI3->(BI3_CODSEG))
            cMsg+= " Segmentação (BI3_CODSEG). " + CRLF + ""
        EndIf

        If Empty(TRBBI3->(BI3_TIPCON))
            cMsg+= "Tipo Contrato (BI3_TIPCON). " + CRLF + ""
        EndIf

        TRBBI3->(DBSkip())

    EndDo

    IIF (SELECT("TRBBI3") > 0,TRBBI3->(DBCloseArea()),"")

    IF !Empty(cMsg)
        cMsg+= ""+ CRLF + "Favor ajustar o(s) Produtos listado(s) antes de prosseguir."
    EndIf

    IIF(!Empty(cMsg),MsgAlert(cMsg),"")

Return  Empty(cMsg)

//----------------------------------------
// Validação do botão Próximo da página 6
//----------------------------------------
Static Function valida_pg6()
    Local cSql    := ""
    Local cMsg    := ""
    Local nCnt    := 0
    Local lRetorno:= .T.
    Local nBrco   := 0

    cSql := " SELECT BI3_CODIGO,BI3_VERSAO,BI3_DESCRI,BI3_INFANS FROM " + RetSqlName("BI3") + " "
    cSql += " WHERE BI3_FILIAL = '" + xFilial("BI3") + "' "
    cSql += " AND BI3_INFANS <> '1' "
    cSql += " AND BI3_GRUPO = '001' "
    cSql += " AND D_E_L_E_T_ = ' ' "

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBI3",.F.,.T.)

    Do While !TRBBI3->(Eof())

        If Empty(TRBBI3->(BI3_INFANS))

            If nBrco == 0
                cMsg+= " " + CRLF + "Campo Consid.ANS (BI3_INFANS) em branco no(s) Produto(s)/Versão: " + CRLF + ""
            EndIf

            cMsg+="" +TRBBI3->(BI3_CODIGO+BI3_VERSAO)+" - "+Alltrim(TRBBI3->BI3_DESCRI)+"" + CRLF + ""

            lRetorno:= .F.
            nBrco++
        EndIf

        If Alltrim(TRBBI3->(BI3_INFANS)) == "0"
            nCnt++
        EndIf

        TRBBI3->(DBSkip())

    EndDo

    IIF (SELECT("TRBBI3") > 0,TRBBI3->(DBCloseArea()),"")

    IF !Empty(cMsg)
        MsgAlert(cMsg)
        lRetorno:= .F.
    EndIf

    IF nCnt > 0 .And. lRetorno

        If !MsgYesNo("Há "+cValToChar(nCnt)+" Produtos com o campo Consid.ANS igual a não. Esse conteúdo será replicado p/os Beneficiários, Contratos e Subcontratos.","Deseja Prosseguir para próxima etapa?")
            lRetorno:= .F.
        EndIf
    EndIf

Return  lRetorno

//----------------------------------------
// Validação do botão Próximo da página 7
//----------------------------------------
Static Function valida_pg7(aPar7)
    Local lRetorno:= Len(aPar7)>0
    Local nI      := 0
    Local cMsg    := ""
    Local cAux    := ""
    Default aPar7 := {}

    For nI:= 1 To 14
        If Empty(aPar7[nI])
            cMsg += "Favor preencher todos os campos!"
            lRetorno:= .F.
            Exit
        EndIf
    Next nI

    For nI:= 1 To 14
        If !Empty(aPar7[nI])
            If SubStr(Alltrim(aPar7[nI]),4,Len(AllTrim(aPar7[nI]))) $ cAux
                lRetorno:= .F.
                cMsg+= "Há Procedimentos repetidos. Favor ajustar! "
                Exit
            Else
                cAux+= SubStr(Alltrim(aPar7[nI]),4,Len(AllTrim(aPar7[nI]))) + "/"
            EndIf
        EndIf
    Next nI

    If !lRetorno
        MsgInfo(cMsg)
    EndIf

Return lRetorno


//----------------------------------------
// Validação do botão Próximo da página 8
//----------------------------------------
Static Function valida_pg8(aPar7)
    Local lRetorno:= Len(aPar7)>0
    Local nI      := 0
    Local cMsg    := ""
    Local cAux    := ""
    Default aPar7 := {}

    For nI:= 1 To Len(aPar7)
        If !Empty(aPar7[nI])
            If SubStr(Alltrim(aPar7[nI]),4,Len(AllTrim(aPar7[nI]))) $ cAux
                lRetorno:= .F.
                cMsg+= "Há Procedimentos repetidos. Favor ajustar! "
                Exit
            Else
                cAux+= SubStr(Alltrim(aPar7[nI]),4,Len(AllTrim(aPar7[nI]))) + "/"
            EndIf
        EndIf
    Next nI

    If !lRetorno
        MsgInfo(cMsg)
    EndIf

Return lRetorno

//--------------------------
// Construção da página 1
//--------------------------
Static Function cria_pg1(oPanel)

    oFont1:= TFont():New('Arial',,-18,,.T.)

    oSay1:= TSay():New(10,10,{||'Wizard SIP - É necessário ter lido a documentação desta rotina antes de utilizá-la!'},oPanel,,oFont1,,,,.T.,CLR_RED,,600,20)
    oSay1:= TSay():New(40,10,{||'Esta etapa irá finalizar os compromissos do SIP anteriores a este. Isso evita processamento desnecessário de trimestres já enviados à ANS.'},oPanel,,oFontCabec,,,,.T.,,,600,20)

    If !ExistBlock("PLSDADCON")
        oSay1:= TSay():New(80,10,{||'Importante: Conforme documentação do Wizard SIP, não foi encontrado o Ponto de Entrada PLSDADCON. Caso realmente não seja necessário, desconsidere este aviso.'},oPanel,,oFontCabec,,,,.T.,CLR_BLUE,,600,20)
    Endif

Return

//--------------------------
// Construção da página 2
//--------------------------
Static Function cria_pg2(oPanel)
    Local cFilSeg  :="BI6_FILIAL=B3D->B3D_FILIAL .And. BI6_SEGSIP=''"
    Local cFilCon  :="BII_FILIAL=B3D->B3D_FILIAL .And. BII_TIPPLA=''"

    oSay2   := TSay():New(10,10,{||'Esta etapa é para configurar o Cadastro de Segmentações e Tipos de Contrato do módulo Plano de Saúde. Clique em cada um dos botões abaixo.'},oPanel,,oFontCabec,,,,.T.,,,600,20)
    oSay2   := TSay():New(20,10,{||'Para cada segmentação, o campo Seg.SIP (BI6_SEGSIP) deve ser preenchido. Para cada Tipo de Contrato, o campo Tp Plano (BII_TIPPLA) deve ser preenchido'},oPanel,,oFontCabec,,,,.T.,,,600,20)
    oSay2   := TSay():New(40,10,{||'Somente será apresentado na tela, registros que devem ser corrigidos.'},oPanel,,oFontCabec,,,,.T.,CLR_BLUE,,600,20)
    oTButt2 := TButton():New(100, 220, "Segmentação" ,oPanel,{|| CenPlsSeg(cFilSeg)} , 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButt2 := TButton():New(100, 320, "Tipos de Contratos" ,oPanel,{|| CenPlsCon(cFilCon)} , 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )

Return

//--------------------------
// Construção da página 3
//--------------------------
Static Function cria_pg3(oPanel)
    oSay3   := TSay():New(10,10,{||'Esta etapa irá deletar (caso tenha) o cadastro de Natureza de Saúde e recriá-lo de acordo com a Documentação do SIP disponível em: '},oPanel,,oFontCabec,,,,.T.,,,600,20)
    oSay3   := TSay():New(10,438,{||'https://tdn.totvs.com/display/PROT/SIP '},oPanel,,oFontCabec,,,,.T.,CLR_BLUE,,600,20,,,,,,.T.)
    oSay3   := TSay():New(20,10,{||'Seção: "Cadastrar Naturezas de saúde" '},oPanel,,oFontCabec,,,,.T.,,,600,20)

Return

//--------------------------
// Construção da página 4
//--------------------------
Static Function cria_pg4(oPanel)

    oSay4   := TSay():New(10,10,{||'Esta etapa irá ajustar seu cadastro de Especialidades para o SIP. Isso será feito preenchendo o campo Classif.SIP (BAQ_ESPSP2) de acordo com o campo CBO-S (BAQ_CBOS).'},oPanel,,oFontCabec,,,,.T.,,,600,20)
    oSay4   := TSay():New(20,10,{||'Exemplo: CBO-S = 225125 (Médico Clínico). Neste caso, esta rotina irá preencher o campo Classif.SIP = A15 (Clínica Médica)'},oPanel,,oFontCabec,,,,.T.,,,600,20)

Return

//--------------------------
// Construção da página 5
//--------------------------
Static Function cria_pg5(oPanel)

    oSay5   := TSay():New(10,10,{||'Esta etapa irá analisar se a parametrização de seus Produtos Saúde estão adequados ao SIP. Clique no Botão Produtos Saúde.'},oPanel,,oFontCabec,,,,.T.,,,600,20)
    oSay5   := TSay():New(20,10,{||'A tela somente apresentará registros, caso tenha necessidade de ajustar um dos campos: Segmentação (BI3_CODSEG) e/ou Tp.Contrato (BI3_TIPCON).'},oPanel,,oFontCabec,,,,.T.,,,600,20)

    oTButt5 := TButton():New(100, 220, "Produtos Saúde" ,oPanel,{|| CenPlsPro("1")} , 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )

Return

//--------------------------
// Construção da página 6
//--------------------------
Static Function cria_pg6(oPanel)
    Local aRegs    := {}

    oSay6   := TSay():New(10,10,{||'Esta Etapa é para parametrização do campo Considera ANS (BI3_INFANS). Ao clicar no botão abaixo, será apresentado todos seus produtos'},oPanel,,oFontCabec,,,,.T.,,,600,20)
    oSay6   := TSay():New(10,457,{||'que estão com o campo em questão diferente de sim. Ao concluir este Wizard, '},oPanel,,oFontCabec,,,,.T.,,,600,20)
    oSay6   := TSay():New(20,10,{||'o sistema vai replicar o conteúdo do campo para todos Beneficiários, Contratos e Subcontratos que utilizam o produto.'},oPanel,,oFontCabec,,,,.T.,,,600,20)
    oSay6   := TSay():New(50,10,{||'As Empresas informadas no Ponto de Entrada PLSDADCON serão desconsideradas.'},oPanel,,oFontCabec,,,,.T.,,,600,20)

    oTButt6 := TButton():New(100, 220, "Produtos Saúde" ,oPanel,{|| CenPlsPro("2")} , 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )

    If ExistBlock("PLSDADCON")
        aRegs:= ExecBlock("PLSDADCON",.f.,.f.,{})

        If Len(aRegs)==0
            oSay6:= TSay():New(180,10,{||'Importante: Conforme documentação do Wizard SIP, o Ponto de Entrada PLSDADCON está compilado, mas não está retornando as empresas.'},oPanel,,oFontCabec,,,,.T.,CLR_RED,,600,20)
        EndIf

    Endif

Return

//--------------------------
// Construção da página 7
//--------------------------
Static Function cria_pg7(oPanel, aPar7)
    Local o7A1,o7A2,o7B,o7C,o7C3,o7C101,o7C14,o7D,o7E,o7E141,o7E124,o7E21,o7E22,o7E23
    Default aPar7  := {}

    oSay7:= TSay():New(010,010,{||'Esta etapa irá parametrizar os procedimentos da Tabela Padrão para expostos. Selecione o procedimento de acordo com a classificação.'},oPanel,,oFontCabec,,,,.T.,,,800,20)

    oSay7:= TSay():New(050,100,{||'A1   Consultas Médicas Ambulatoriais                                                                '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(065,100,{||'A2   Consultas Médicas em Pronto Socorro                                                            '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(080,100,{||'B    Outros Atendimentos Ambulatoriais                                                              '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(095,100,{||'C    Exames                                                                                         '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(110,100,{||'C3   Procedimento Diagnóstico em Citopatologia cérvico-vaginal oncótica em mulheres de 25 a 59 anos '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(125,100,{||'C101 Mamografia em mulheres de 50 a 69 anos                                                         '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(140,100,{||'C14  Pesq.sangue oculto nas fezes em pessoas (50-69 anos)                                           '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(155,100,{||'D    Terapias                                                                                       '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(170,100,{||'E    Internações                                                                                    '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(185,100,{||'E124 Fratura de Fêmur (60 anos ou mais)                                                             '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(200,100,{||'E141 Internação de 0 a 5 anos de idade por doenças respiratórias                                    '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(215,100,{||'E21  Regime de Internação Hospitalar                                                                '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(230,100,{||'E22  Regime de Internação Hospital-Dia                                                              '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay7:= TSay():New(245,100,{||'E23  Regime de Internação Domiciliar                                                                '},oPanel,,oFontCabec,,,,.T.,,,600,30)

    o7A1      := TGet():New(050,010,{|u| If(PCount() > 0,aPar7[1] := u,aPar7[1])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[1],,,,.t.,.f.)
    o7A1:bF3  := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[1] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7A1:Refresh()}),.T.)}')

    o7A2      := TGet():New(065,010,{|u| If(PCount() > 0,aPar7[2] := u,aPar7[2])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[2])
    o7A2:bF3  := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[2] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7A2:Refresh()}),.T.)}')

    o7B       := TGet():New(080,010,{|u| If(PCount() > 0,aPar7[3] := u,aPar7[3])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[3])
    o7B:bF3   := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[3] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7B:Refresh()}),.T.)}')

    o7C       := TGet():New(095,010,{|u| If(PCount() > 0,aPar7[4] := u,aPar7[4])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[4])
    o7C:bF3   := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[4] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7C:Refresh()}),.T.)}')

    o7C3      := TGet():New(110,010,{|u| If(PCount() > 0,aPar7[5] := u,aPar7[5])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[5])
    o7C3:bF3  := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[5] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7C3:Refresh()}),.T.)}')

    o7C101    := TGet():New(125,010,{|u| If(PCount() > 0,aPar7[6] := u,aPar7[6])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[6])
    o7C101:bF3:= &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[6] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7C101:Refresh()}),.T.)}')

    o7C14     := TGet():New(140,010,{|u| If(PCount() > 0,aPar7[7] := u,aPar7[7])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[7])
    o7C14:bF3 := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[7] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7C14:Refresh()}),.T.)}')

    o7D       := TGet():New(155,010,{|u| If(PCount() > 0,aPar7[8] := u,aPar7[8])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[8])
    o7D:bF3   := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[8] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7D:Refresh()}),.T.)}')

    o7E       := TGet():New(170,010,{|u| If(PCount() > 0,aPar7[9] := u,aPar7[9])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[9])
    o7E:bF3   := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[9] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7E:Refresh()}),.T.)}')

    o7E124    := TGet():New(185,010,{|u| If(PCount() > 0,aPar7[10] := u,aPar7[10])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[10])
    o7E124:bF3:= &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[10] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7E124:Refresh()}),.T.)}')

    o7E141    := TGet():New(200,010,{|u| If(PCount() > 0,aPar7[11] := u,aPar7[11])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[11])
    o7E141:bF3:= &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[11] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7E141:Refresh()}),.T.)}')

    o7E21     := TGet():New(215,010,{|u| If(PCount() > 0,aPar7[12] := u,aPar7[12])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[12])
    o7E21:bF3 := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[12] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7E21:Refresh()}),.T.)}')

    o7E22     := TGet():New(230,010,{|u| If(PCount() > 0,aPar7[13] := u,aPar7[13])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[13])
    o7E22:bF3 := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[13] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7E22:Refresh()}),.T.)}')

    o7E23     := TGet():New(245,010,{|u| If(PCount() > 0,aPar7[14] := u,aPar7[14])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[14])
    o7E23:bF3 := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[14] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o7E23:Refresh()}),.T.)}')

Return aPar7

//--------------------------
// Construção da página 8
//--------------------------
Static Function cria_pg8(oPanel, aPar7)
    Local o8I,o8I1,o8I2,o8I3,o8I33,o8I4,o8I5,o8I6,o8I7,o8I8,o8I9,o8I10
    Default aPar7  := {}

    oSay8:= TSay():New(010,010,{||'Esta etapa irá parametrizar os procedimentos Odontológicos da Tabela Padrão para expostos.'},oPanel,,oFontCabec,,,,.T.,,,800,20)
    oSay8:= TSay():New(010,310,{||'Caso não tenha produto Odontológico, favor avançar esta etapa.                            '},oPanel,,oFontCabec,,,,.T.,,,800,20)

    oSay8:= TSay():New(050,100,{||'I   Procedimentos Odontológicos                                                           '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(065,100,{||'I1  Consultas odontológicas iniciais                                                      '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(080,100,{||'I2  Exames Radiográficos                                                                  '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(095,100,{||'I3  Procedimentos preventivos                                                             '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(110,100,{||'I33 Selante por elemento dentário (menores de 12 anos)                                    '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(125,100,{||'I4  Raspagem supra-gengival por hemi-arcada (12 anos ou mais)                             '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(140,100,{||'I5  Restaur.dentes decíduos por elemento (menores de 12 anos)                             '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(155,100,{||'I6  Restaur.dentes permanentes por elemento (12 anos ou mais)                             '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(170,100,{||'I7  Exodontias simples de permanentes (12 anos ou mais)                                   '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(185,100,{||'I8  Trat.endodôntico concluido dentes decíduos p/elemento (menos de 12 anos)              '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(200,100,{||'I9  Trat.endodôntico concluido dentes permanentes por elemento (12 anos ou mais)          '},oPanel,,oFontCabec,,,,.T.,,,600,30)
    oSay8:= TSay():New(215,100,{||'I10 Próteses odontológicas unitárias (Coroa Total e Restauração Metálica Fundida)         '},oPanel,,oFontCabec,,,,.T.,,,600,30)

    o8I      := TGet():New(050,010,{|u| If(PCount() > 0,aPar7[15] := u,aPar7[15])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[15],,,,.t.,.f.)
    o8I:bF3  := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[15] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I:Refresh()}),.T.)}')

    o8I1      := TGet():New(065,010,{|u| If(PCount() > 0,aPar7[16] := u,aPar7[16])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[16])
    o8I1:bF3  := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[16] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I1:Refresh()}),.T.)}')

    o8I2       := TGet():New(080,010,{|u| If(PCount() > 0,aPar7[17] := u,aPar7[17])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[17])
    o8I2:bF3   := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[17] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I2:Refresh()}),.T.)}')

    o8I3       := TGet():New(095,010,{|u| If(PCount() > 0,aPar7[18] := u,aPar7[18])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[18])
    o8I3:bF3   := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[4] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I3:Refresh()}),.T.)}')

    o8I33      := TGet():New(110,010,{|u| If(PCount() > 0,aPar7[19] := u,aPar7[19])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[19])
    o8I33:bF3  := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[19] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I33:Refresh()}),.T.)}')

    o8I4    := TGet():New(125,010,{|u| If(PCount() > 0,aPar7[20] := u,aPar7[20])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[20])
    o8I4:bF3:= &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[20] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I4:Refresh()}),.T.)}')

    o8I5     := TGet():New(140,010,{|u| If(PCount() > 0,aPar7[21] := u,aPar7[21])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[21])
    o8I5:bF3 := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[21] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I5:Refresh()}),.T.)}')

    o8I6       := TGet():New(155,010,{|u| If(PCount() > 0,aPar7[22] := u,aPar7[22])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[22])
    o8I6:bF3   := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[22] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I6:Refresh()}),.T.)}')

    o8I7       := TGet():New(170,010,{|u| If(PCount() > 0,aPar7[23] := u,aPar7[23])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[23])
    o8I7:bF3   := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[23] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I7:Refresh()}),.T.)}')

    o8I8    := TGet():New(185,010,{|u| If(PCount() > 0,aPar7[24] := u,aPar7[24])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[24])
    o8I8:bF3:= &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[24] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I8:Refresh()}),.T.)}')

    o8I9    := TGet():New(200,010,{|u| If(PCount() > 0,aPar7[25] := u,aPar7[25])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[25])
    o8I9:bF3:= &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[25] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I9:Refresh()}),.T.)}')

    o8I10     := TGet():New(215,010,{|u| If(PCount() > 0,aPar7[26] := u,aPar7[26])},oPanel,080,10,"@!",,,,,,,.T.,,,{|| .T.},,,,.T.,.F.,,aPar7[26])
    o8I10:bF3 := &('{|| IIf(ConPad1(,,,"PLSPRP",,,.F.),Eval({|| aPar7[26] := BR8->BR8_CODPAD+ "-"+BR8->BR8_CODPSA, o8I10:Refresh()}),.T.)}')

Return aPar7

//--------------------------
// Construção da página 9
//--------------------------
Static Function cria_pg9(oPanel)

    oSay9   := TSay():New(10,10,{||'Esta etapa irá classificar sua tabela Padrão de acordo com a Tabela SIP X TUSS.'},oPanel,,oFontCabec,,,,.T.,,,600,20)

Return

//--------------------------
// Construção da página 10
//--------------------------
Static Function cria_pg10(oPanel,cPar9)
    Local oCombo10
    Local aItens   := {'Não','Sim'}
    Default cPar9 := ""

    oSay10    := TSay():New(10,10,{||'Esta etapa irá Importar e validar seus Produtos (BI3/B3J) e Beneficiários (BA1/B3K)'},oPanel,,oFontCabec,,,,.T.,,,600,20)
    oSay10    := TSay():New(100,10,{||'Considerar Beneficiário de Repasse?'},oPanel,,oFontCabec,,,,.T.,,,600,20)

    oCombo10  := TComboBox():New(100,130  ,{|u| If(PCount()>0,cPar9:=u,cPar9)},aItens,080,010,oPanel,,{|| },,,,.T.,,,,,,,,,'cPar9')

Return

//--------------------------
// Construção da página 11
//--------------------------
Static Function cria_pg11(oPanel)

    oSay11    := TSay():New(10,10,{||'Esta Etapa irá baixar os arquivos XSDs do SIP e disponibilizá-los no diretório SIP na estrutura Protheus.'},oPanel,,oFontCabec,,,,.T.,,,600,20)

Return

//--------------------------
// Construção da Última Página
//--------------------------
Static Function cria_pn12(oPanel)
    oSay12:= TSay():New(10,10,{||'Ao concluir, será processado todas etapas anteriores, a não ser as Etapas 2, 5 e 6 que já foram feitas.'},oPanel,,oFontCabec,,,,.T.,,,600,20)
    oSay12:= TSay():New(10,332,{||'Será disponibilizado no diretório LOGPLS, um arquivo log chamado cen_sip_wizard.log.'},oPanel,,oFontCabec,,,,.T.,,,600,20)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DelUpdSip

	Funcao utilizada para fechar compromissos anteriores, deletar a tabela de naturezas de saúde, ajustar contrato e subcontrato do beneficiário e preparar o campo FCAREN deixando como 2
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function DelUpdSip(cTab,cTrirec,cInfAns)
    Local cSql      := ""
    Local aAreaB3D  := B3D->(GetArea())
    Default cTab    := ""
    Default cTrirec := ""
    Default cInfAns := "1"

    If cTab == "B3D"

        cSql := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("B3D") + " "
        cSql += "WHERE B3D_FILIAL = '" + xFilial("B3D") + "' AND B3D_CODOPE = '" + B3D->B3D_CODOPE + "' "
        cSql += "AND B3D_CDOBRI = '" + B3D->B3D_CDOBRI + "' "
        cSql += "AND B3D_TIPOBR = '1' "
        cSql += "AND B3D_STATUS <> '6' "
        cSql += "AND B3D_VCTO < '" + DTOS(B3D->B3D_VCTO)+ "' "
        cSql += "AND D_E_L_E_T_ = ' '  "

        cSql := ChangeQuery(cSql)
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB3D",.F.,.T.)

        Do While !TRBB3D->(Eof())
            B3D->(DBGoTo(TRBB3D->REC))
            IF B3D->B3D_STATUS <> '6'
                PLCOMPMF(.f., "6")
                TRBB3D->(DBSkip())
                PlsLogFil("Trimestre ["+cTrirec+"] - O Trimestre " +B3D->B3D_ANO +SubStr(B3D->B3D_CODIGO,2,2) +" teve seu status alterado para Finalizado. ",ARQUIVO_LOG)
            EndIF
        EndDo

        TRBB3D->(dbCloseArea())
        aAreaB3D:= B3D->(RestArea(aAreaB3D))

    ElseIf cTab == "BF0"
        //deleto tabela de natureza de saúde
        cSql := " DELETE FROM " + RetSqlName('BF0')
        cSql += " WHERE BF0_FILIAL = '" + xFilial("BF0") + "' AND BF0_GRUGEN = '" + AllTrim(GetNewPar("MV_PLGRSIP","0001")) + "' "
        cSql += " AND D_E_L_E_T_ = ' '  "

        nRet := TCSQLEXEC(cSql)

        If nRet >= 0
            IIf (SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE",nRet := TCSQLEXEC("COMMIT"),"")

            PlsLogFil("Trimestre ["+cTrirec+"] - Tabela de natureza de Saúde deletada. ",ARQUIVO_LOG)

        Endif

        IIf (nRet < 0,PlsLogFil(" Instrução: " + cSql + " Erro: " + TCSQLError(),ARQUIVO_LOG),GerNatSau(cTrirec)) //crio tabela de natureza de saúde

    ElseIf cTab == "BT5"

        //Marco o INFANS dos contratos baseado no beneficiário  com indice:         BT5_FILIAL+BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO
        cSql := " UPDATE " + retSQLName("BT5") + " SET BT5_INFANS = '"+cInfAns+ "' "
        cSql += "  WHERE BT5_FILIAL = '" + BA1->BA1_FILIAL + "' "
        cSql += "    AND BT5_CODINT = '" + BA1->BA1_CODINT + "' "
        cSql += "    AND BT5_CODIGO = '" + BA1->BA1_CODEMP  + "' "
        cSql += "    AND BT5_NUMCON = '" + BA1->BA1_CONEMP + "' "
        cSql += "    AND BT5_VERSAO = '" + BA1->BA1_VERCON + "' "
        cSql += "    AND D_E_L_E_T_ = ' ' "

        nRet := TCSQLEXEC(cSql)

        If nRet >= 0

            IIf (SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE",nRet := TCSQLEXEC("COMMIT"),"")

        Endif

        IIf (nRet < 0,PlsLogFil(" Instrução: " + cSql + " Erro: " + TCSQLError(),ARQUIVO_LOG),"")

    ElseIf cTab == "BQC"

        //Marco INFANS = Sim nos subcontratos usando indice: BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB
        cSql := " UPDATE " + retSQLName("BQC") + " SET BQC_INFANS = '"+cInfAns+ "' "
        cSql += "  WHERE BQC_FILIAL = '" + BA1->BA1_FILIAL + "' "
        cSql += "    AND BQC_CODINT = '" + BA1->BA1_CODINT + "' "
        cSql += "    AND BQC_CODEMP = '" + BA1->BA1_CODEMP + "' "
        cSql += "    AND BQC_NUMCON = '" + BA1->BA1_CONEMP + "' "
        cSql += "    AND BQC_VERCON = '" + BA1->BA1_VERCON + "' "
        cSql += "    AND BQC_SUBCON = '" + BA1->BA1_SUBCON + "' "
        cSql += "    AND BQC_VERSUB = '" + BA1->BA1_VERSUB + "' "
        cSql += "    AND D_E_L_E_T_ = ' ' "

        nRet := TCSQLEXEC(cSql)

        If nRet >= 0

            IIf (SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE",nRet := TCSQLEXEC("COMMIT"),"")

        Endif

        IIf (nRet < 0,PlsLogFil(" Instrução: " + cSql + " Erro: " + TCSQLError(),ARQUIVO_LOG),"")

    ElseIf cTab == "BR8"

        //Ajusto classificações incorretas
        cSql := " UPDATE " + retSQLName("BR8") + " SET BR8_CLASIP = '', BR8_CLASP2='' "
        cSql += "  WHERE BR8_FILIAL = '" + xFilial("BR8") + "' "
        cSql += "    AND (BR8_CLASIP IN ('A','F','F1','F11','F111','F12','F121','F13','F131','F14','F141','F2','F3','F31','F32','F33','F34','F341','F4','F41','F5','G') "
        cSql += " OR BR8_CLASP2 IN ('A','F','F1','F11','F111','F12','F121','F13','F131','F14','F141','F2','F3','F31','F32','F33','F34','F341','F4','F41','F5','G')) "
        cSql += "    AND D_E_L_E_T_ = ' ' "

        nRet := TCSQLEXEC(cSql)

        PlsLogFil("Trimestre ["+cTrirec+"] - Retirando classificações indevidas da tabela padrão como as classificações A, F... e G. ",ARQUIVO_LOG)

        If nRet >= 0

            IIf (SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE",nRet := TCSQLEXEC("COMMIT"),"")

        Endif

        IIf (nRet < 0,PlsLogFil(" Instrução: " + cSql + " Erro: " + TCSQLError(),ARQUIVO_LOG),"")

    ElseIf cTab == "BR8_FCAREN"
        //antes de marcar os procedimentos como expostos, ru retiro todos FCAREN da tabela padrão qu estejam igual a Sim
        cSql := " UPDATE " + retSQLName("BR8") + " SET BR8_FCAREN = '2' "
        cSql += "  WHERE BR8_FILIAL = '" + BA1->BA1_FILIAL + "' "
        cSql += "    AND BR8_FCAREN = '1' "
        cSql += "    AND D_E_L_E_T_ = ' ' "

        nRet := TCSQLEXEC(cSql)

        If nRet >= 0

            IIf (SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE",nRet := TCSQLEXEC("COMMIT"),"")

        Endif

        IIf (nRet < 0,PlsLogFil(" Instrução: " + cSql + " Erro: " + TCSQLError(),ARQUIVO_LOG),"")

    EndIF

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerNatSau

	Funcao que ajusta as naturezas de saúde
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function GerNatSau(cTrirec)
    Local cTabNat   := AllTrim(GetNewPar("MV_PLGRSIP","0001"))
    Local nI        := 0
    Local aTabNat   := {}
    Default cTrirec := ""

    AADD(aTabNat,{cTabNat,' ','A','CONSULTAS MEDICAS                                                                                   ','1','1','1',0,999,' ','1','consultasMedicas'})
    AADD(aTabNat,{cTabNat,'A    ','A1     ','Consultas medicas ambulatoriais                                                           ','2','2','1',0,999,' ','1','consultasMedicasAmb'})
    AADD(aTabNat,{cTabNat,'A1   ','A11    ','Alergia e Imunologia                                                                      ','2','3','1',0,999,' ','1','alergiaImunologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A12    ','Angiologia                                                                                ','2','3','1',0,999,' ','1','angiologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A13    ','Cardiologia                                                                               ','2','3','1',0,999,' ','1','cardiologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A14    ','Cirurgia geral                                                                            ','2','3','1',0,999,' ','1','cirurgiaGeral'})
    AADD(aTabNat,{cTabNat,'A1   ','A15    ','Clinica medica                                                                            ','2','3','1',0,999,' ','1','clinicaMedica'})
    AADD(aTabNat,{cTabNat,'A1   ','A16    ','Dermatologia                                                                              ','2','3','1',0,999,' ','1','dermatologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A17    ','Endocrinologia                                                                            ','2','3','1',0,999,' ','1','endocrinologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A18    ','Gastroenterologia                                                                         ','2','3','1',0,999,' ','1','gastroenterologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A19    ','Geriatria                                                                                 ','2','3','1',0,999,' ','1','geriatria'})
    AADD(aTabNat,{cTabNat,'A1   ','A110   ','Ginecologia e Obstetricia                                                                 ','2','3','1',0,999,' ','1','GinecologiaObstetricia'})
    AADD(aTabNat,{cTabNat,'A1   ','A111   ','Hematologia                                                                               ','2','3','1',0,999,' ','1','hematologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A112   ','Mastologia                                                                                ','2','3','1',0,999,' ','1','mastologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A113   ','Nefrologia                                                                                ','2','3','1',0,999,' ','1','nefrologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A114   ','Neurocirurgia                                                                             ','2','3','1',0,999,' ','1','neurocirurgia'})
    AADD(aTabNat,{cTabNat,'A1   ','A115   ','Neurologia                                                                                ','2','3','1',0,999,' ','1','neurologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A116   ','Oftalmologia                                                                              ','2','3','1',0,999,' ','1','oftalmologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A117   ','Oncologia                                                                                 ','2','3','1',0,999,' ','1','oncologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A118   ','Otorrinolaringologia                                                                      ','2','3','1',0,999,' ','1','otorrinolaringologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A119   ','Pediatria                                                                                 ','2','3','1',0,999,' ','1','pediatria'})
    AADD(aTabNat,{cTabNat,'A1   ','A120   ','Proctologia                                                                               ','2','3','1',0,999,' ','1','proctologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A121   ','Psiquiatria                                                                               ','2','3','1',0,999,' ','1','psiquiatria'})
    AADD(aTabNat,{cTabNat,'A1   ','A122   ','Reumatologia                                                                              ','2','3','1',0,999,' ','1','reumatologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A123   ','Tisiopneumologia                                                                          ','2','3','1',0,999,' ','1','tisiopneumologia'})
    AADD(aTabNat,{cTabNat,'A1   ','A124   ','Traumatologia-ortopedia                                                                   ','2','3','1',0,999,' ','1','traumatologiaOrtopedica'})
    AADD(aTabNat,{cTabNat,'A1   ','A125   ','Urologia                                                                                  ','2','3','1',0,999,' ','1','urologia'})
    AADD(aTabNat,{cTabNat,'A    ','A2     ','Consultas medicas em Pronto Socorro                                                       ','1','2','1',0,999,' ','1','consultaMedProntSoc'})
    AADD(aTabNat,{cTabNat,'     ','B      ','OUTROS ATENDIMENTOS AMBULATORIAIS                                                         ','1','1','1',0,999,' ','1','outrosAtendAmb'})
    AADD(aTabNat,{cTabNat,'B    ','B1     ','Consultas/sessoes com Fisioterapeuta                                                      ','2','2','1',0,999,' ','1','consultaSessaoFisio'})
    AADD(aTabNat,{cTabNat,'B    ','B2     ','Consultas/sessoes com Fonoaudiologo                                                       ','2','2','1',0,999,' ','1','consultaSessaoFono'})
    AADD(aTabNat,{cTabNat,'B    ','B3     ','Consultas/sessoes com Nutricionista                                                       ','2','2','1',0,999,' ','1','consultaSessaoNutri'})
    AADD(aTabNat,{cTabNat,'B    ','B4     ','Consultas/sessoes com Terapeuta ocupacional                                               ','2','2','1',0,999,' ','1','consultaSessaoTerap'})
    AADD(aTabNat,{cTabNat,'B    ','B5     ','Consultas/sessoes com Psicologo                                                           ','2','2','1',0,999,' ','1','consultaSessaoPsico'})
    AADD(aTabNat,{cTabNat,'     ','C      ','EXAMES                                                                                    ','1','1','1',0,999,' ','1','exames'})
    AADD(aTabNat,{cTabNat,'C    ','C1     ','Ressonancia magnetica                                                                     ','2','2','1',0,999,' ','1','ressonanciaMagnet'})
    AADD(aTabNat,{cTabNat,'C    ','C2     ','Tomografia computadorizada                                                                ','2','2','1',0,999,' ','1','tomografiaComputa'})
    AADD(aTabNat,{cTabNat,'C    ','C3     ','Procedimento diagnostico em citopatologia cervico-vaginal oncotica em mulheres de 25 a 59 ','2','2','1',25,59,'2','1','procedDiagnCitopat'})
    AADD(aTabNat,{cTabNat,'C    ','C4     ','Densitometria ossea – qualquer segmento                                                   ','2','2','1',0,999,' ','1','densitometriaOssea'})
    AADD(aTabNat,{cTabNat,'C    ','C5     ','Ecodopplercardiograma transtoracico                                                       ','2','2','1',0,999,' ','1','ecodopplerTranstora'})
    AADD(aTabNat,{cTabNat,'C    ','C6     ','Broncoscopia com ou sem biopsia                                                           ','2','2','1',0,999,' ','1','broncoscopiabiopsia'})
    AADD(aTabNat,{cTabNat,'C    ','C7     ','Endoscopia digestiva alta                                                                 ','2','2','1',0,999,' ','1','endoscopiaDigestiva'})
    AADD(aTabNat,{cTabNat,'C    ','C8     ','Colonoscopia                                                                              ','2','2','1',0,999,' ','1','colonoscopia'})
    AADD(aTabNat,{cTabNat,'C    ','C9     ','Holter de 24 horas                                                                        ','2','2','1',0,999,' ','1','holter24h'})
    AADD(aTabNat,{cTabNat,'C    ','C10    ','Mamografia convencional e digital                                                         ','2','2','1',0,999,' ','1','mamografiaConvDig'})
    AADD(aTabNat,{cTabNat,'C10  ','C101   ','Mamografia em mulheres de 50 a 69 anos                                                    ','2','3','1',50,69,'2','1','mamografia50a69'})
    AADD(aTabNat,{cTabNat,'C    ','C11    ','Cintilografia miocardica                                                                  ','2','2','1',0,999,' ','1','cintilografiaMiocard'})
    AADD(aTabNat,{cTabNat,'C    ','C12    ','Cintilografia renal dinamica                                                              ','2','2','1',0,999,' ','1','cintilografiaRenal'})
    AADD(aTabNat,{cTabNat,'C    ','C13    ','Hemoglobina glicada                                                                       ','2','2','1',0,999,' ','1','hemoglobinaGlicada'})
    AADD(aTabNat,{cTabNat,'C    ','C14    ','Pesquisa de sangue oculto nas fezes                                                       ','2','2','1',50,69,' ','1','pesqSangueOculto'})
    AADD(aTabNat,{cTabNat,'C    ','C15    ','Radiografia                                                                               ','2','2','1',0,999,' ','1','radiografia'})
    AADD(aTabNat,{cTabNat,'C    ','C16    ','Teste ergometrico                                                                         ','2','2','1',0,999,' ','1','testeErgometrico'})
    AADD(aTabNat,{cTabNat,'C    ','C17    ','Ultra-sonografia diagnostica de abdome total                                              ','2','2','1',0,999,' ','1','ultraSonAbdoTotal'})
    AADD(aTabNat,{cTabNat,'C    ','C18    ','Ultra-sonografia diagnostica de abdome inferior                                           ','2','2','1',0,999,' ','1','ultraSonAbdoInfer'})
    AADD(aTabNat,{cTabNat,'C    ','C19    ','Ultra-sonografia diagnostica de abdome superior                                           ','2','2','1',0,999,' ','1','ultraSonAbdoSuper'})
    AADD(aTabNat,{cTabNat,'C    ','C20    ','Ultra-sonografia obstetrica morfologica                                                   ','2','2','1',0,999,' ','1','ultraSonObstMorfo'})
    AADD(aTabNat,{cTabNat,'     ','D      ','TERAPIAS                                                                                  ','1','1','1',0,999,' ','1','terapias'})
    AADD(aTabNat,{cTabNat,'D    ','D1     ','Transfusao ambulatorial                                                                   ','2','2','1',0,999,' ','1','transfusaoAmbulatorial'})
    AADD(aTabNat,{cTabNat,'D    ','D2     ','Quimioterapia sistemica                                                                   ','2','2','1',0,999,' ','1','quimioSistemica'})
    AADD(aTabNat,{cTabNat,'D    ','D3     ','Radioterapia megavoltagem                                                                 ','2','2','1',0,999,' ','1','radioterapiaMegavolt'})
    AADD(aTabNat,{cTabNat,'D    ','D4     ','Hemodialise aguda                                                                         ','2','2','1',0,999,' ','1','hemodialiseAguda'})
    AADD(aTabNat,{cTabNat,'D    ','D5     ','Hemodialise cronica                                                                       ','2','2','1',0,999,' ','1','hemodialiseCronica'})
    AADD(aTabNat,{cTabNat,'D    ','D6     ','Implante de dispositivo intrauterino - DIU                                                ','2','2','1',0,999,' ','1','implanteDispIntrauterino'})
    AADD(aTabNat,{cTabNat,'     ','E      ','INTERNACOES                                                                               ','1','1','1',0,999,' ','1','internacoes'})
    AADD(aTabNat,{cTabNat,'E    ','E11    ','Clinica                                                                                   ','2','2','1',0,999,' ','1','clinica'})
    AADD(aTabNat,{cTabNat,'E    ','E12    ','Cirurgica                                                                                 ','2','2','1',0,999,' ','1','cirurgica'})
    AADD(aTabNat,{cTabNat,'E12  ','E121   ','Cirurgia bariatrica                                                                       ','2','3','1',0,999,' ','1','cirurgiaBariatrica'})
    AADD(aTabNat,{cTabNat,'E12  ','E122   ','Laqueadura tubaria                                                                        ','2','3','1',0,999,' ','1','laqueaduraTubaria'})
    AADD(aTabNat,{cTabNat,'E12  ','E123   ','Vasectomia                                                                                ','2','3','1',0,999,' ','1','vasectomia'})
    AADD(aTabNat,{cTabNat,'E12  ','E124   ','Fratura de femur (60 anos ou mais)                                                        ','2','3','1',60,999,' ','1','fraturaFemur60'})
    AADD(aTabNat,{cTabNat,'E12  ','E125   ','Revisao de artroplastia                                                                   ','2','3','1',0,999,' ','1','revisaoArtroplastia'})
    AADD(aTabNat,{cTabNat,'E12  ','E126   ','Implante de CDI (cardio desfibrilador implantavel)                                        ','2','3','1',0,999,' ','1','implanteCdi'})
    AADD(aTabNat,{cTabNat,'E12  ','E127   ','Implantacao de marcapasso                                                                 ','2','3','1',0,999,' ','1','implantacaoMarcap'})
    AADD(aTabNat,{cTabNat,'E    ','E13    ','Obstetrica                                                                                ','2','2','1',0,999,' ','1','obstetrica'})
    AADD(aTabNat,{cTabNat,'E3   ','E131   ','Parto normal                                                                              ','2','3','1',0,999,' ','1','partoNormal'})
    AADD(aTabNat,{cTabNat,'E3   ','E132   ','Parto cesareo                                                                             ','2','3','1',0,999,' ','1','partoCesareo'})
    AADD(aTabNat,{cTabNat,'E1   ','E14    ','Pediatrica                                                                                ','2','2','1',0,999,' ','1','pediatrica'})
    AADD(aTabNat,{cTabNat,'E14  ','E141   ','Internacao de 0 a 5 anos de idade por doencas respiratorias                               ','2','3','1',0,5,' ','1','internacaoRespira'})
    AADD(aTabNat,{cTabNat,'E14  ','E142   ','Internacao em UTI no periodo neonatal                                                     ','2','3','1',0,28,' ','1','internacaoUtiNeo'})
    AADD(aTabNat,{cTabNat,'E142 ','E1421  ','Internacoes em UTI no periodo neonatal por ate 48 horas                                   ','2','3','1',0,6,' ','1','internacoesUtiNeo48'})
    AADD(aTabNat,{cTabNat,'E1   ','E15    ','Psiquiatrica                                                                              ','2','2','1',0,999,' ','1','psiquiatrica'})
    AADD(aTabNat,{cTabNat,'E2   ','E21    ','Hospitalar                                                                                ','2','3','1',0,999,' ','1','hospitalar'})
    AADD(aTabNat,{cTabNat,'E2   ','E22    ','Hospital-dia                                                                              ','2','2','1',0,999,' ','1','hospitalDia'})
    AADD(aTabNat,{cTabNat,'E21  ','E221   ','Hospital-dia para saude mental                                                            ','2','3','1',0,999,' ','1','hospitalSaudeMental'})
    AADD(aTabNat,{cTabNat,'E2   ','E23    ','Domiciliar                                                                                ','2','3','1',0,999,' ','1','domiciliar'})
    AADD(aTabNat,{cTabNat,'     ','F      ','CAUSAS SELECIONADAS DE INTERNACAO                                                         ','1','1','1',0,999,' ','1','causaSelecInterna'})
    AADD(aTabNat,{cTabNat,'F    ','F1     ','Neoplasias                                                                                ','2','2','1',0,999,' ','1','neoplasias'})
    AADD(aTabNat,{cTabNat,'F1   ','F11    ','Cancer de mama feminino                                                                   ','2','3','1',0,999,' ','1','cancerMamaFem'})
    AADD(aTabNat,{cTabNat,'F11  ','F111   ','Tratamento cirurgico de cancer de mama feminino                                           ','2','3','1',0,999,' ','1','tratCirurgCancerMam'})
    AADD(aTabNat,{cTabNat,'F1   ','F12    ','Cancer de colo de utero                                                                   ','2','3','1',0,999,' ','1','cancerColoUtero'})
    AADD(aTabNat,{cTabNat,'F12  ','F121   ','Tratamento cirurgico de cancer de colo de utero                                           ','2','3','1',0,999,' ','1','tratCirurgCancerColo'})
    AADD(aTabNat,{cTabNat,'F1   ','F13    ','Cancer de colon e reto                                                                    ','2','3','1',0,999,' ','1','cancerColonReto'})
    AADD(aTabNat,{cTabNat,'F13  ','F131   ','Tratamento cirurgico de cancer de colon e reto                                            ','2','3','1',0,999,' ','1','tratCirurgCancerColoReto'})
    AADD(aTabNat,{cTabNat,'F1   ','F14    ','Cancer de prostata                                                                        ','2','3','1',0,999,' ','1','cancerProstata'})
    AADD(aTabNat,{cTabNat,'F14  ','F141   ','Tratamento cirurgico de cancer de prostata                                                ','2','3','1',0,999,' ','1','tratCirurgCancerProst'})
    AADD(aTabNat,{cTabNat,'F    ','F2     ','Diabetes mellitus                                                                         ','2','2','1',0,999,' ','1','diabetesMellitus'})
    AADD(aTabNat,{cTabNat,'F    ','F3     ','Doencas do aparelho circulatorio                                                          ','2','2','1',0,999,' ','1','doencasAparelhoCirc'})
    AADD(aTabNat,{cTabNat,'F3   ','F31    ','Infarto agudo do miocardio                                                                ','2','3','1',0,999,' ','1','infartoAgudoMiocardio'})
    AADD(aTabNat,{cTabNat,'F3   ','F32    ','Doencas hipertensivas                                                                     ','2','3','1',0,999,' ','1','doencasHipertensivas'})
    AADD(aTabNat,{cTabNat,'F3   ','F33    ','Insuficiencia cardiaca congestiva                                                         ','2','3','1',0,999,' ','1','insuficienciaCardCong'})
    AADD(aTabNat,{cTabNat,'F3   ','F34    ','Doencas cerebrovasculares                                                                 ','2','3','1',0,999,' ','1','doencasCerebrovasc'})
    AADD(aTabNat,{cTabNat,'F34  ','F341   ','Acidente vascular cerebral                                                                ','2','3','1',0,999,' ','1','acidenteVascularCere'})
    AADD(aTabNat,{cTabNat,'F    ','F4     ','Doencas do aparelho respiratorio                                                          ','2','2','1',0,999,' ','1','doencasAparelhoResp'})
    AADD(aTabNat,{cTabNat,'F4   ','F41    ','Doenca pulmonar obstrutiva cronica                                                        ','2','3','1',0,999,' ','1','doencaPulmoObstrCron'})
    AADD(aTabNat,{cTabNat,'F    ','F5     ','Causas externas                                                                           ','2','2','1',0,999,' ','1','causasExternas'})
    AADD(aTabNat,{cTabNat,'     ','G      ','NASCIDO VIVO                                                                              ','1','1','1',0,999,' ','1','nascidoVivo'})
    AADD(aTabNat,{cTabNat,'     ','H      ','DEMAIS DESPESAS MEDICOHOSPITALARES                                                        ','1','1','1',0,999,' ','1','demaisDespMedHosp'})
    AADD(aTabNat,{cTabNat,'     ','I      ','PROCEDIMENTOS ODONTOLOGICOS                                                               ','1','1','1',0,999,' ','1','procedimentosOdonto'})
    AADD(aTabNat,{cTabNat,'I    ','I1     ','Consultas odontologicas iniciais                                                          ','2','2','1',0,999,' ','1','consultasOdontoInic'})
    AADD(aTabNat,{cTabNat,'I    ','I2     ','Exames radiograficos                                                                      ','2','2','1',0,999,' ','1','examesRadiograficos'})
    AADD(aTabNat,{cTabNat,'I    ','I3     ','Procedimentos preventivos                                                                 ','2','2','1',0,999,' ','1','procedimentosPrevent'})
    AADD(aTabNat,{cTabNat,'I3   ','I31    ','Atividade educativa individual                                                            ','2','3','1',0,999,' ','1','atividadeEduIndividual'})
    AADD(aTabNat,{cTabNat,'I3   ','I32    ','Aplicacao topica profissional de fluor por hemi-arcada                                    ','2','3','1',0,999,' ','1','aplicTopProfFluorHemi'})
    AADD(aTabNat,{cTabNat,'I3   ','I33    ','Selante por elemento dentario (menores de 12 anos)                                        ','2','3','1',0,12,' ','1','selanteElemDentario'})
    AADD(aTabNat,{cTabNat,'I    ','I4     ','Raspagem supra-gengival por hemiarcada (12 anos ou mais)                                  ','2','2','1',12,999,' ','1','raspSupraGengHemi'})
    AADD(aTabNat,{cTabNat,'I    ','I5     ','Restauracao em dentes deciduos por elemento (menores de 12 anos)                          ','2','2','1',0,12,' ','1','restauraDenteDeciduo'})
    AADD(aTabNat,{cTabNat,'I    ','I6     ','Restauracao em dentes permanentes por elemento (12 anos ou mais)                          ','2','2','1',12,999,' ','1','restauraDentePerma'})
    AADD(aTabNat,{cTabNat,'I    ','I7     ','Exodontias simples de permanentes (12 anos ou mais)                                       ','2','2','1',12,999,' ','1','exodontiasSimplesPer'})
    AADD(aTabNat,{cTabNat,'I    ','I8     ','Tratamento endodontico concluido em dentes deciduos por elemento (menores de 12 anos)     ','2','2','1',0,12,' ','1','trataEndoConclDentesD'})
    AADD(aTabNat,{cTabNat,'I    ','I9     ','Tratamento endodontico concluido em dentes permanentes por elemento (12 anos ou mais)     ','2','2','1',12,999,' ','1','trataEndoConclDentesP'})
    AADD(aTabNat,{cTabNat,'I    ','I10    ','Proteses odontologicas                                                                    ','2','3','1',0,999,' ','1','protesesOdontologicas'})
    AADD(aTabNat,{cTabNat,'I    ','I11    ','Proteses odontologicas unitarias (Coroa Total e Restauracao Metalica Fundida)             ','2','3','1',0,999,' ','1','protesesOdontoUnitarias'})

    BF0->(DBSetOrder(1))
    //Gero natureza de saúde
    If !BF0->(dbSeek(xFilial("BF0")+cTabNat))

        PlsLogFil("Trimestre ["+cTrirec+"] - Tabela de natureza de Saúde Criada. ",ARQUIVO_LOG)

        For nI:=1 To Len(aTabNat)

            BF0->(RecLock("BF0",.T.))
            BF0->BF0_FILIAL:= xFilial("BF0")
            BF0->BF0_GRUGEN:= Alltrim(aTabNat[nI,1])
            BF0->BF0_CODSUP:= Alltrim(aTabNat[nI,2])
            BF0->BF0_CODIGO:= Alltrim(aTabNat[nI,3])
            BF0->BF0_DESCRI:= EncodeUTF8(Alltrim(aTabNat[nI,4]))
            BF0->BF0_CLASSE:= Alltrim(aTabNat[nI,5])
            BF0->BF0_NIVEL := Alltrim(aTabNat[nI,6])
            BF0->BF0_IMPRIM:= Alltrim(aTabNat[nI,7])
            BF0->BF0_IDADE1:= aTabNat[nI,8]
            BF0->BF0_IDADE2:= aTabNat[nI,9]
            BF0->BF0_SEXO  := Alltrim(aTabNat[nI,10])
            BF0->BF0_BENEF := Alltrim(aTabNat[nI,11])
            BF0->BF0_DESSIP:= EncodeUTF8(Alltrim(aTabNat[nI,12]))

            BF0->(MsUnLock())
        Next nI
    EndIf

    BF0->(DBCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AjuEspSip

	Funcao que ajusta as especialidades
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function AjuEspSip(cTriRec)   //ajusto especialidades
    Local aTabEsp  := {}
    Local cCodOpe  := ""
    Local nI       := 0
    Default cTrirec:= ""

    BA0->(dbSetOrder(5))
    BAQ->(DBSetOrder(4)) //BAQ_FILIAL+BAQ_CODINT+BAQ_CBOS

    If BA0->(dbSeek(xFilial("BA0")+B3D->B3D_CODOPE))
        cCodOpe:=BA0->(BA0_CODIDE+BA0_CODINT)
    EndIf

    IIf (FunName()=="RPC",cCodOpe:= "0001","")

    If !Empty(cCodOpe)
        AADD(aTabEsp,{cCodOpe,'A15' ,'225125'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'223268'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'223605'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'223710'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225103'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225105'})
        AADD(aTabEsp,{cCodOpe,'A113','225109'})
        AADD(aTabEsp,{cCodOpe,'A11' ,'225110'})
        AADD(aTabEsp,{cCodOpe,'A115','225112'})
        AADD(aTabEsp,{cCodOpe,'A13' ,'225120'})
        AADD(aTabEsp,{cCodOpe,'A119','225124'})
        AADD(aTabEsp,{cCodOpe,'A123','225127'})
        AADD(aTabEsp,{cCodOpe,'A121','225133'})
        AADD(aTabEsp,{cCodOpe,'A16' ,'225135'})
        AADD(aTabEsp,{cCodOpe,'A122','225136'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225140'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225148'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225150'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225151'})
        AADD(aTabEsp,{cCodOpe,'A17' ,'225155'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225160'})
        AADD(aTabEsp,{cCodOpe,'A18' ,'225165'})
        AADD(aTabEsp,{cCodOpe,'A19' ,'225180'})
        AADD(aTabEsp,{cCodOpe,'A111','225185'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225195'})
        AADD(aTabEsp,{cCodOpe,'A12' ,'225203'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225210'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225215'})
        AADD(aTabEsp,{cCodOpe,'A14' ,'225225'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225230'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225235'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225240'})
        AADD(aTabEsp,{cCodOpe,'A110','225250'})
        AADD(aTabEsp,{cCodOpe,'A112','225255'})
        AADD(aTabEsp,{cCodOpe,'A114','225260'})
        AADD(aTabEsp,{cCodOpe,'A116','225265'})
        AADD(aTabEsp,{cCodOpe,'A124','225270'})
        AADD(aTabEsp,{cCodOpe,'A118','225275'})
        AADD(aTabEsp,{cCodOpe,'A120','225280'})
        AADD(aTabEsp,{cCodOpe,'A125','225285'})
        AADD(aTabEsp,{cCodOpe,'A117','225290'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225305'})
        AADD(aTabEsp,{cCodOpe,'A18' ,'225310'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225315'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'225320'})
        AADD(aTabEsp,{cCodOpe,'A1'  ,'999999'})

        For nI:=1 To Len(aTabEsp)

            If BAQ->(DbSeek(xFilial("BAQ")+aTabEsp[nI,1]+aTabEsp[nI,3]))
                If Alltrim(BAQ->BAQ_CBOS) == aTabEsp[nI,3] .And. Alltrim(BAQ->BAQ_ESPSP2) <> aTabEsp[nI,2]
                    PlsLogFil("Trimestre ["+cTrirec+"] - Especialidade "+BAQ->BAQ_CODESP+" com CBOs "+BAQ->BAQ_CBOS+" teve seu campo BAQ_ESPSP2 alterado de: "+BAQ->BAQ_ESPSP2+" para "+aTabEsp[nI,3]+" ",ARQUIVO_LOG)
                    BAQ->(RecLock("BAQ",.F.))
                    BAQ->BAQ_ESPSP2:=Alltrim(aTabEsp[nI,2])
                    BAQ->(MsUnLock())
                EndIf
            EndIf
        Next nI
    EndIf
    BAQ->(DBCloseArea())
    BA0->(DBCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BuscaOper

	Funcao que posiciona na Operadora do PLS, considerando o SUSEP
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Function BuscaOper(cCodOpe)
    Local aAreaBA0 := BA0->(GetArea())

    BA0->(dbSetOrder(5))
    If BA0->(dbSeek(xFilial("BA0")+B3D->B3D_CODOPE))
        cCodope:= BA0->(BA0_CODIDE+BA0_CODINT)
    EndIf

    BA0->(RestArea(aAreaBA0))

    IIf (FunName()=='RPC',cCodOpe:= "0001","")

Return cCodOpe

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPlaPls

	Pego os produtos que tem o INFANS = 1 e através deles ajusto beneficiários, contratos e subcontratos.
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function CenPlaPls(cTrirec)
    Local cSql      := ""
    Local cStr      := ""
    Local nI        := 0
    Local aRegs     := {}
    Default cTriRec := ""

    If ExistBlock("PLSDADCON")  //ponto de entrada utilizado para informar as empresas que não devem ser alteradas
        aRegs:= ExecBlock("PLSDADCON",.f.,.f.,{})

        For nI := 1 to len(aRegs)
            cStr += "'" + aRegs[nI,1] + "'" + iif(nI < len(aRegs),",","")
        next nI

        If Len(aRegs)==0
            PlsLogFil("Trimestre ["+cTrirec+"] - Ponto de Entrada PLSDADCON compilado, mas não está retornando empresas.",ARQUIVO_LOG)
        Else
            PlsLogFil("Trimestre ["+cTrirec+"] - Ponto de Entrada PLSDADCON retornou as seguintes empresas: "+cStr+"",ARQUIVO_LOG)
        EndIf

    Else
        PlsLogFil("Trimestre ["+cTrirec+"] - Ponto de Entrada PLSDADCON não foi compilado",ARQUIVO_LOG)
    Endif

    cSql := "SELECT BI3_CODINT,BI3_CODIGO,BI3_VERSAO,BI3_INFANS FROM " + RetSqlName("BI3") + " "
    cSql += "   WHERE BI3_FILIAL = '" + xFilial("BI3") + "' AND BI3_CODINT = '" + BuscaOper(B3D->B3D_CODOPE) + "' "
    cSql += "       AND BI3_GRUPO = '001' "
    cSql += "       AND D_E_L_E_T_ = ' ' "
    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBI3",.F.,.T.)

    PlsLogFil("Trimestre ["+cTrirec+"] - Marcando campo INFANS dos beneficiários, contratos e subcontratos.",ARQUIVO_LOG)

    Do While !TRBBI3->(Eof())
        CenAjuGrp(TRBBI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO),cStr,cTrirec,TRBBI3->(BI3_INFANS))
        TRBBI3->(DBSkip())
    EndDo

    TRBBI3->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenAjuGrp

	Encontro os beneficiários que utilizam o produto e marco o campo BA1_INFANS=1. Desconsidero as empresas informadas no P.E.
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function CenAjuGrp(cCodPro,cStr,cTrirec,cInfAns)
    Local cSql      := ""
    Default cCodPro := ""
    Default cStr    := ""
    Default cTrirec := ""
    Default cInfAns := "1"

    BA1->(dbSetOrder(1))
    BA3->(dbSetOrder(1))

    cSql := "SELECT BA1.R_E_C_N_O_ BA1REC, BA3.R_E_C_N_O_ BA3REC FROM " + RetSqlName("BA1") + " BA1, " + RetSqlName("BA3") + " BA3 "
    cSql += "  WHERE BA1_FILIAL = BA3_FILIAL "
    cSql += "    AND BA1_CODINT = BA3_CODINT "
    cSql += "    AND BA1_CODEMP = BA3_CODEMP "
    cSql += "    AND BA1_CONEMP = BA3_CONEMP "
    cSql += "    AND BA1_VERCON = BA3_VERCON "
    cSql += "    AND BA1_SUBCON = BA3_SUBCON "
    cSql += "    AND BA1_VERSUB = BA3_VERSUB "
    cSql += "    AND BA1_MATRIC = BA3_MATRIC "
    cSql += "    AND BA1_CODINT = '"+SubStr(cCodPro,1,4)+"' "
    cSql += "    AND ((BA1_CODPLA = '"+SubStr(cCodPro,5,4)+"' AND BA1_VERSAO = '"+SubStr(cCodPro,9,3)+"') OR "
    cSQL += "         (BA3_CODPLA = '"+SubStr(cCodPro,5,4)+"' AND BA3_VERSAO = '"+SubStr(cCodPro,9,3)+"'))"

    If !Empty(cStr)
        cSql += "    AND BA1_CODEMP NOT IN (" +cStr+ ") "
    EndIf

    cSql += "    AND BA1.D_E_L_E_T_ = ' ' "
    cSql += "    AND BA3.D_E_L_E_T_ = ' ' "

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBA1",.F.,.T.)

    Do While !TRBBA1->(Eof())
        BA1->(DBGoTo(TRBBA1->BA1REC))
        BA3->(DBGoTo(TRBBA1->BA3REC))

        If ((BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO) == cCodPro .And. Empty(BA1->BA1_CODPLA)) .OR. (!Empty(BA1->BA1_CODPLA) .And. BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO) == cCodPro))
            BA1->(RecLock("BA1",.F.))
            BA1->BA1_INFANS:= cInfAns
            BA1->(MsUnLock())
            DelUpdSip("BT5",cTrirec,cInfAns)   //altero o INFANS do contrato do beneficiário acima
            DelUpdSip("BQC",cTrirec,cInfAns)   //altero o INFANS do SubContrato do beneficiário acima
        EndIf
        TRBBA1->(DBSkip())
    EndDo

    TRBBA1->(dbCloseArea())
    BA1->(dbCloseArea())
    BA3->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenTbExp

	Inicialmente coloco todos procedimentos da tabela padrão como BR8_FCAREN = Não.
    Em seguida eu coloco o FCAREN = Sim apenas para os procedimentos informados no Wizard (aPar7).
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function CenTbExp(cTrirec,aPar7)
    Local cSql      := ""
    Local nI        := 0

    PlsLogFil("Trimestre ["+cTrirec+"] - Colocando campos BR8_FCAREN da tabela Padrão igual a Não.",ARQUIVO_LOG)

    DelUpdSip("BR8_FCAREN",cTriRec)

    For nI := 1 To len(aPar7)

        If !Empty(aPar7[nI])

            cSql := " SELECT  R_E_C_N_O_ REC FROM " + RetSqlName("BR8") + " "
            cSql += "   WHERE BR8_FILIAL = '" + xFilial("BR8") + "' AND BR8_CODPAD= '"+SubStr(aPar7[nI],1,2)+"' "
            cSQL += "       AND BR8_CODPSA = '"+SubStr(Alltrim(aPar7[nI]),4,Len(AllTrim(aPar7[nI])))+ "'  AND D_E_L_E_T_ = ' ' "

            cSql := ChangeQuery(cSql)

            dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBPROC",.F.,.T.)

            Do While !TRBPROC->(Eof())

                BR8->(DBGoTo(TRBPROC->REC))

                BR8->(RecLock("BR8",.F.))

                If nI == 1

                    BR8->BR8_CLASIP:= "A1"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_TPCONS:= "1"
                    BR8->BR8_BENUTL:= "1"
                    IF BR8->BR8_REGATD $ "3/ "
                        BR8->BR8_REGATD := "3"
                    ElseIF BR8->BR8_REGATD $ "1/2"
                        BR8->BR8_REGATD := "1"
                    EndIF

                ElseIf nI == 2

                    BR8->BR8_CLASIP:= "A2"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_TPCONS:= "2"
                    BR8->BR8_BENUTL:= "1"

                    IF BR8->BR8_REGATD $ "3/ "
                        BR8->BR8_REGATD := "3"
                    ElseIF BR8->BR8_REGATD $ "1/2"
                        BR8->BR8_REGATD := "1"
                    EndIF

                ElseIf nI == 3

                    BR8->BR8_CLASIP:= "B"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_BENUTL:= "1"

                    IF BR8->BR8_REGATD $ "3/ "
                        BR8->BR8_REGATD := "3"
                    ElseIF BR8->BR8_REGATD $ "1/2"
                        BR8->BR8_REGATD := "1"
                    EndIF

                ElseIf nI == 4

                    BR8->BR8_CLASIP:= "C"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_BENUTL:= "1"

                    IF BR8->BR8_REGATD $ "3/ "
                        BR8->BR8_REGATD := "3"
                    ElseIF BR8->BR8_REGATD $ "1/2"
                        BR8->BR8_REGATD := "1"
                    EndIF

                ElseIf nI == 5

                    BR8->BR8_CLASIP:= "C3"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_BENUTL:= "1"

                    IF BR8->BR8_REGATD $ "3/ "
                        BR8->BR8_REGATD := "3"
                    ElseIF BR8->BR8_REGATD $ "1/2"
                        BR8->BR8_REGATD := "1"
                    EndIF

                ElseIf  nI == 6

                    BR8->BR8_CLASIP:= "C101"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_BENUTL:= "1"

                    IF BR8->BR8_REGATD $ "3/ "
                        BR8->BR8_REGATD := "3"
                    ElseIF BR8->BR8_REGATD $ "1/2"
                        BR8->BR8_REGATD := "1"
                    EndIF

                ElseIf  nI == 7

                    BR8->BR8_CLASIP:= "C14"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_BENUTL:= "1"

                    IF BR8->BR8_REGATD $ "3/ "
                        BR8->BR8_REGATD := "3"
                    ElseIF BR8->BR8_REGATD $ "1/2"
                        BR8->BR8_REGATD := "1"
                    EndIF

                ElseIf  nI == 8

                    BR8->BR8_CLASIP:= "D"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_BENUTL:= "1"

                    IF BR8->BR8_REGATD $ "3/ "
                        BR8->BR8_REGATD := "3"
                    ElseIF BR8->BR8_REGATD $ "1/2"
                        BR8->BR8_REGATD := "1"
                    EndIF

                ElseIf  nI == 9

                    BR8->BR8_CLASIP:= ""
                    BR8->BR8_CLASP2:= "E"
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD := "2"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 10

                    BR8->BR8_CLASIP:= ""
                    BR8->BR8_CLASP2:= "E124"
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD := "2"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 11

                    BR8->BR8_CLASIP:= ""
                    BR8->BR8_CLASP2:= "E141"
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD := "2"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 12

                    BR8->BR8_CLASIP:= ""
                    BR8->BR8_CLASP2:= "E21"
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD := "2"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 13

                    BR8->BR8_CLASIP:= ""
                    BR8->BR8_CLASP2:= "E22"
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "2"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 14

                    BR8->BR8_CLASIP:= ""
                    BR8->BR8_CLASP2:= "E23"
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "2"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 15

                    BR8->BR8_CLASIP:= "I"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 16

                    BR8->BR8_CLASIP:= "I1"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 17

                    BR8->BR8_CLASIP:= "I2"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 18

                    BR8->BR8_CLASIP:= "I3"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 19

                    BR8->BR8_CLASIP:= "I33"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 20

                    BR8->BR8_CLASIP:= "I4"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 21

                    BR8->BR8_CLASIP:= "I5"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 22

                    BR8->BR8_CLASIP:= "I6"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 23

                    BR8->BR8_CLASIP:= "I7"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 24

                    BR8->BR8_CLASIP:= "I8"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 25

                    BR8->BR8_CLASIP:= "I9"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                ElseIf  nI == 26

                    BR8->BR8_CLASIP:= "I10"
                    BR8->BR8_CLASP2:= ""
                    BR8->BR8_FCAREN:= "1"
                    BR8->BR8_REGATD:= "1"
                    BR8->BR8_BENUTL:= "1"

                EndIf

                BR8->(MsUnLock())
                TRBPROC->(DBSkip())
            EndDo

            IIF (SELECT("TRBPROC") > 0,TRBPROC->(DBCloseArea()),"")

        EndIf

    Next nI


Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenSipTus

	Pego procedimentos e classificações da Tabela TUSS e parametrizo a tabela padrão da mesma forma.
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function CenSipTus(cTrirec,aPar7)
    Local nI        := 0
    Local nJ        := 0
    Local cNot      := ""
    Local aTuss     := {}
    Default aPar7   := {}
    Default cTrirec := ""


    cTxt:="10101012,A1/10106014,A1/10106030,A1/10106049,A1/10106146,A1/20101015,A1/20101023,A1/20101074,A1/20101082,A1/20101090,A1/20101171,A1/20101201,A1/"
    cTxt+="10101020,A1/10105034,A1/10105042,A1/10105050,A1/10105069,A1/10106065,A1/10106073,A1/10106090,A1/10106103,A1/10106111,A1/10106120,A1/10106138,A1/20101155,A1/20101465,A1/"
    cTxt+="20101210,A1/20101228,A1/20101236,A1/20101244,A1/20101309,A1/20101317,A1/20101341,A1/20101406,A1/20101414,A1/20101430,A1/20101449,A1/20101457,A1/"
    cTxt+="20201133,A1/10101039,A2/50000144,B1/50000160,B1/50000195,B1/50000209,B1/50000217,B1/50000233,B1/50000241,B1/50000250,B1/50000268,B1/50000276,B1/"
    cTxt+="50000284,B1/50000292,B1/50000306,B1/50000314,B1/50000322,B1/50000330,B1/50000446,B1/50000713,B1/50000730,B1/50000748,B1/50000756,B1/50000764,B1/"
    cTxt+="50000772,B1/50000780,B1/50000837,B1/50000845,B1/50000853,B1/50000861,B1/50000870,B1/50001078,B1/50000586,B2/50000594,B2/50000616,B2/50000624,B2/"
    cTxt+="50000640,B2/50000659,B2/50000667,B2/50000675,B2/50000560,B3/50000578,B3/50000012,B4/50000020,B4/50000039,B4/50000047,B4/50000055,B4/50000063,B4/"
    cTxt+="50000080,B4/50000098,B4/50000110,B4/50000128,B4/50000136,B4/50000470,B5/50000489,B5/50000497,B5/50000500,B5/50000519,B5/50001183,B5/"
    cTxt+="50001191,B5/41101014,C1/41101022,C1/41101030,C1/41101049,C1/41101057,C1/41101065,C1/41101073,C1/41101081,C1/41101090,C1/41101103,C1/41101111,C1/"
    cTxt+="41101120,C1/41101138,C1/41101146,C1/41101154,C1/41101170,C1/41101189,C1/41101197,C1/41101200,C1/41101219,C1/41101227,C1/41101235,C1/41101243,C1/"
    cTxt+="41101251,C1/41101260,C1/41101278,C1/41101286,C1/41101294,C1/41101308,C1/41101316,C1/41101332,C1/41101340,C1/41101359,C1/41101375,C1/41101383,C1/"
    cTxt+="41101430,C1/41101448,C1/41101456,C1/41101464,C1/41101472,C1/41101480,C1/41101499,C1/41101502,C1/41101510,C1/41101529,C1/41101537,C1/41101545,C1/"
    cTxt+="41101553,C1/41101561,C1/41101570,C1/41101588,C1/41101596,C1/41101600,C1/41101618,C1/41101626,C1/41101634,C1/41101642,C1/41101650,C1/41101669,C1/"
    cTxt+="41102010,C1/41001010,C2/41001028,C2/41001036,C2/41001044,C2/41001052,C2/41001060,C2/41001079,C2/41001087,C2/41001095,C2/41001109,C2/41001117,C2/"
    cTxt+="41001125,C2/41001133,C2/41001141,C2/41001150,C2/41001176,C2/41001184,C2/41001192,C2/41001206,C2/41001214,C2/41001222,C2/41001230,C2/41001249,C2/"
    cTxt+="41001257,C2/41001265,C2/41001273,C2/41001281,C2/41001290,C2/41001303,C2/41001311,C2/41001320,C2/41001338,C2/41001346,C2/41001354,C2/41001362,C2/"
    cTxt+="41001370,C2/41001389,C2/41001397,C2/41001400,C2/41001419,C2/41001427,C2/41001435,C2/41001443,C2/41001451,C2/41001460,C2/41001478,C2/41001486,C2/"
    cTxt+="41001494,C2/41001508,C2/41001516,C2/41001524,C2/41001532,C2/41002016,C2/41002040,C2/41002059,C2/40601137,C3/40601323,C3/40808122,C4/40808130,C4/"
    cTxt+="40808149,C4/40901092,C5/40901106,C5/40201031,C6/40201058,C6/40201120,C7/40201139,C7/40201333,C7/40202038,C7/40202615,C7/40202747,C7/40201082,C8/"
    cTxt+="40201090,C8/40201350,C8/40202135,C8/40202666,C8/20102011,C9/20102020,C9/20102100,C9/40808033,C10/40808041,C10/40808173,C10/40701034,C11/40701042,C11/"
    cTxt+="40701050,C11/40701069,C11/40701131,C11/40701140,C11/40704017,C12/40704025,C12/40302075,C13/40302733,C13/40303136,C14/40303250,C14/40801012,C15/"
    cTxt+="40801020,C15/40801039,C15/40801047,C15/40801055,C15/40801063,C15/40801071,C15/40801080,C15/40801098,C15/40801101,C15/40801110,C15/40801128,C15/"
    cTxt+="40801136,C15/40801144,C15/40801152,C15/40801160,C15/40801179,C15/40801195,C15/40801209,C15/40802019,C15/40802027,C15/40802035,C15/"
    cTxt+="40802043,C15/40802051,C15/40802060,C15/40802078,C15/40802086,C15/40802094,C15/40802108,C15/40802116,C15/40803015,C15/40803023,C15/40803031,C15/"
    cTxt+="40803040,C15/40803058,C15/40803066,C15/40803074,C15/40803082,C15/40803090,C15/40803104,C15/40803112,C15/40803120,C15/40803139,C15/40803147,C15/"
    cTxt+="40803155,C15/40804011,C15/40804020,C15/40804038,C15/40804046,C15/40804054,C15/40804062,C15/40804070,C15/40804089,C15/40804097,C15/40804100,C15/"
    cTxt+="40804119,C15/40804127,C15/40804135,C15/40805018,C15/40805026,C15/40805034,C15/40805042,C15/40805050,C15/40805069,C15/40805077,C15/40805085,C15/"
    cTxt+="40805093,C15/40806014,C15/40806022,C15/40806030,C15/40806049,C15/40806057,C15/40806065,C15/40806073,C15/40806081,C15/40806090,C15/40806103,C15/"
    cTxt+="40806111,C15/40806120,C15/40806138,C15/40806146,C15/40806154,C15/40806162,C15/40806170,C15/40806189,C15/40806197,C15/40806200,C15/40806219,C15/"
    cTxt+="40807010,C15/40807029,C15/40807037,C15/40807045,C15/40807053,C15/40807061,C15/40807070,C15/40807088,C15/40807096,C15/40807100,C15/40808017,C15/"
    cTxt+="40808025,C15/40808050,C15/40808114,C15/40808157,C15/40808165,C15/40809021,C15/40809030,C15/40809048,C15/40809056,C15/40809064,C15/40809072,C15/"
    cTxt+="40809080,C15/40809110,C15/40809129,C15/40809137,C15/40810011,C15/40811018,C15/40811026,C15/40812022,C15/40812030,C15/40812049,C15/40812057,C15/"
    cTxt+="40812073,C15/40812081,C15/40812090,C15/40812103,C15/40812111,C15/40812120,C15/40812138,C15/40812146,C15/40814130,C15/"
    cTxt+="40101037,C16/40101045,C16/40101061,C16/41401158,C16/41401166,C16/41401174,C16/41401182,C16/41401190,C16/"
    cTxt+="41401204,C16/40901122,C17/40901572,C17/40901173,C18/40901181,C18/40901130,C19/40901262,C20/40401014,D1/40401022,D1/20104243,D2/20104251,D2/"
    cTxt+="20104278,D2/20104286,D2/20104294,D2/20104308,D2/20104383,D2/20104430,D2/41203070,D3/41203089,D3/41203097,D3/30909139,D4/30909147,D4/30909031,D5/"
    cTxt+="30909155,D5/31303269,D6/31303293,D6/31002218,E121/31002390,E121/31304010,E122/31304052,E122/31205046,E123/31205070,E123/30724058,E124/30724066,E124/"
    cTxt+="30724074,E124/30724082,E124/30724171,E124/30724180,E124/30725100,E124/30725119,E124/30725127,E124/30725135,E124/30725160,E124/30725194,E124/30717159,E125/"
    cTxt+="30724279,E125/30726255,E125/30904021,E126/30904161,E126/30904064,E127/30904080,E127/30904099,E127/30904137,E127/30904145,E127/31309127,E131/31309135,E131/"
    cTxt+="31309054,E132/31309208,E132/81000065,I1/81000294,I2/"
    cTxt+="81000324,I2/81000340,I2/81000367,I2/81000375,I2/81000405,I2/81000413,I2/81000421,I2/81000430,I2/81000456,I2/81000472,I2/81000480,I2/"
    cTxt+="81000510,I2/81000529,I2/81000537,I2/81000561,I2/81000570,I2/41401654,I3/84000031,I3/84000058,I3/84000074,I3/84000090,I3/84000112,I3/84000139,I3/"
    cTxt+="84000163,I3/84000171,I3/84000198,I3/84000201,I3/84000228,I3/84000236,I3/84000252,I3/85300055,I3/87000016,I3/87000024,I3/85300047,I4/83000135,I5/"
    cTxt+="85100218,I5/85100226,I5/85100048,I6/85100064,I6/85100099,I6/85100102,I6/85100110,I6/85100129,I6/85100137,I6/85100145,I6/85100153,I6/85100161,I6/85100196,I6/"
    cTxt+="85100200,I6/82000875,I7/83000151,I8/85200093,I9/85200107,I9/85200115,I9/85200131,I9/85200140,I9/85200158,I9/85200166,I9/85400262,I10/"
    cTxt+="85400297,I10/85400300,I10/85400319,I10/85400327,I10/85400335,I10/85400343,I10/85400351,I10/85400378,I10/85400386,I10/85400408,I10/85400416,I10/85400424,I10/"
    cTxt+="85400564,I10/85400610,I10/85500097,I10/85500100,I10/85500119,I10/85500127,I10/83000020,I11/83000046,I11/83000062,I11/85400092,I11/85400106,I11/85400114,I11/"
    cTxt+="85400122,I11/85400130,I11/85400149,I11/85400157,I11/85400165,I11/85400173,I11/85400181,I11/85400190,I11/85400238,I11/85400513,I11/85400521,I11/85400530,I11/"
    cTxt+="85400548,I11/85400556,I11/85400572,I11/85500038,I11/85500046,I11/85500054,I11/87000040,I11/87000059,I11/87000067,I11/"

    aTuss:=StrTokArr(cTxt,"/")
    cTxt:=""

    For nJ:= 1 to Len(aPar7)
        cNot += Substr(aPar7[nJ],1,2) + Substr(Alltrim(aPar7[nJ]),4,Len(Alltrim(aPar7[nJ]))) + "/"
    Next nJ

    For nI:= 1 to Len(aTuss)

        cSql := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("BR8") + " "
        cSql += "WHERE BR8_FILIAL = '" + xFilial("BR8") + "' "
        cSql += "AND BR8_CODPSA = '" + SubStr(aTuss[nI],1,8) + "' "
        cSql += "AND D_E_L_E_T_ = ' '  "

        cSql := ChangeQuery(cSql)
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBR8",.F.,.T.)

        Do While !TRBBR8->(Eof())
            BR8->(DBGoTo(TRBBR8->REC))

            If Alltrim(BR8->BR8_CODPAD + BR8->BR8_CODPSA) $ cNot
                TRBBR8->(DBSkip())
                Loop
            EndIf

            BR8->(RecLock("BR8",.F.))

            If 'E' $ aTuss[nI]
                BR8->BR8_CLASP2:= SubStr(aTuss[nI],10,Len(aTuss[nI]))
                BR8->BR8_CLASIP:= ""
                BR8->BR8_REGATD:= "2"
                BR8->BR8_BENUTL:= "1"

            Else

                BR8->BR8_CLASP2:= ""
                BR8->BR8_CLASIP:= SubStr(aTuss[nI],10,Len(aTuss[nI]))
                IF BR8->BR8_REGATD $ "3/ "
                    BR8->BR8_REGATD := "3"
                ElseIF BR8->BR8_REGATD $ "1/2"
                    BR8->BR8_REGATD := "1"
                EndIF

                BR8->BR8_BENUTL:= "1"

            EndIf

            BR8->(MsUnLock())
            TRBBR8->(DBSkip())
        EndDo

        TRBBR8->(dbCloseArea())

    Next nI

    IIf (Select("TRBBR8")>0,TRBBR8->(dbCloseArea()),"")

    DelUpdSip("BR8",cTriRec)

Return aTuss

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenImpVal

	Esta função importa e valida os produtos e beneficiários
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function CenImpVal(cTriRec,cPar9)
    Local cDataRef  := DTOS(dDataBase)
    Local cDatBloq  := DTOS(B3D->B3D_VCTO + 100)
    Local lGerRepas := cPar9 == "Sim"
    Local lCriticado:= .F.
    Local cTpData   := "1"
    Local aEmpresas := {}
    Local cRegANS   := B3D->B3D_CODOPE
    Local nI        := 0
    Local cDatVal   := cDataRef

    PlsLogFil("Trimestre ["+cTrirec+"] - Importando Produtos.",ARQUIVO_LOG)

    ImportaProdutos(1,.F.)

    PlsLogFil("Trimestre ["+cTrirec+"] - Validando Produtos.",ARQUIVO_LOG)

    If Len(cTrirec) == 6

        If Substr(cTriRec,5,2) == "01"
            cDatVal:= Substr(cTriRec,1,4)+ "0330"

        ElseIF Substr(cTriRec,5,2) == "02"
            cDatVal:= Substr(cTriRec,1,4)+ "0630"

        ElseIF Substr(cTriRec,5,2) == "03"
            cDatVal:= Substr(cTriRec,1,4)+ "0930"

        ElseIF Substr(cTriRec,5,2) == "04"
            cDatVal:= Substr(cTriRec,1,4)+ "1231"

        EndIf

    EndIf

    PLSIPVLPR(,,,cDatVal,cRegANS,,.f.,,.f.)

    Sleep(2000)

    PlsLogFil("Trimestre ["+cTrirec+"] - Importando beneficiários.",ARQUIVO_LOG)

    ImportaBeneficiarios(2,cRegANS,cDatBloq,lGerRepas,lCriticado,cTpData,.t.)

    PlsLogFil("Trimestre ["+cTrirec+"] - Validando Beneficiários.",ARQUIVO_LOG)

    Sleep(2000)

    aEmpresas := ListaEmpresa(cRegANS)

    For nI := 1 TO Len(aEmpresas)
        PLSIPVLBN(,,,cDatVal,cRegANS,aEmpresas[nI],,,.F.)
    Next nI

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenDowFil

	Baixa XSDs do SIP
	@author jose.paulo
	@since 04/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function CenDowFil(cTriRec)
    Local aFilNam   := {"sipV1_02.xsd","sipSimpleTypeV1_02.xsd","sipComplexTypeV1_02.xsd"}
    Local cDestino  := "\sip\"
    Local cUrl      := "https://cobprostorage.blob.core.windows.net"
    Local cRequest  := "/files/SIGACEN/sip/"
    Local lRetorno  := .F.
    Local nI        := 0
    Local oWzFiles	:= nil
    Default cTriRec := ""

    For nI:= 1 To Len(aFilNam)

        oWzFiles := PrjWzFiles():New(cDestino, aFilNam[nI])
        IIf(oWzFiles:getWDClient(cURL, cRequest + aFilNam[nI]),lRetorno :=.T.,lRetorno :=.F.)
        IIF(lRetorno,PlsLogFil("Trimestre ["+cTrirec+"] - Arquivo XSD: "+aFilNam[nI]+ " do SIP baixado com sucesso.",ARQUIVO_LOG),PlsLogFil("Trimestre ["+cTrirec+"] - Arquivo XSD: "+aFilNam[nI]+ " do SIP não foi baixado.",ARQUIVO_LOG))

        FreeObj(oWzFiles)
        oWzFiles := nil
    Next

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenBusPro

	Busca procedimento e utiliza como sugestão
	@author jose.paulo
	@since 06/10/2022
/*/
//--------------------------------------------------------------------------------------------------
Static Function CenBusPro(aPar7)
    Local cSql    := ""
    Local cCodPad := GETNEWPAR("MV_PLSTBPD","01")
    Local lOk     := .F.
    Local lOkC101 := .F.
    Default aPar7 := {"","","","","","","","","","","","","","","","","","","","","","","","","",""}

    cSql := " SELECT  BR8_CODPAD,BR8_CODPSA FROM " + RetSqlName("BR8") + " "
    cSql += "   WHERE BR8_FILIAL = '" + xFilial("BR8") + "' AND BR8_CODPAD= '"+cCodPad+"' "
    cSQL += "       AND BR8_CODPSA IN ('10101012','10101039','40303136','40601137','40808033','40303250','30725127','30725135','30725160','30725100','30725119','30725194',"
    cSQL += "'30724058','30724066','30724074','30724082') AND D_E_L_E_T_ = ' ' "
    cSql += " UNION SELECT  BR8_CODPAD,BR8_CODPSA FROM " + RetSqlName("BR8") + " "
    cSql += " WHERE BR8_FILIAL='" + xFilial("BR8") + "' AND BR8_ODONTO ='1' AND BR8_CODPSA IN ('84000139','81000065','81000294','87000016','84000074','85300047','83000135','85100048','82000875','83000151','85200131','85100170') "
    cSql += " AND D_E_L_E_T_ = ' ' "

    cSql := ChangeQuery(cSql)

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCEN",.F.,.T.)

    Do While !TRBCEN->(Eof())

        If AllTrim(TRBCEN->BR8_CODPSA) == '10101012'
            aPar7[1]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf AllTrim(TRBCEN->BR8_CODPSA) == '10101039'
            aPar7[2]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf AllTrim(TRBCEN->BR8_CODPSA) == '40303136'
            aPar7[4]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf AllTrim(TRBCEN->BR8_CODPSA) == '40601137'
            aPar7[5]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf !lOkC101 .And. AllTrim(TRBCEN->BR8_CODPSA) $ ("40808033/40808041/40808173")
            aPar7[6]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)
            lOkC101:= .T.

        ElseIf AllTrim(TRBCEN->BR8_CODPSA) == '40303250'
            aPar7[7]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf !lOK .And. AllTrim(TRBCEN->BR8_CODPSA) $ ("30725127/30725135/30725160/30725100/30725119/30725194/30724058/30724066/30724074/30724082")
            aPar7[10]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)
            lOK := .T.
        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '84000139'
            aPar7[15]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '81000065'
            aPar7[16]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '81000294'
            aPar7[17]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '87000016'
            aPar7[18]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '84000074'
            aPar7[19]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '85300047'
            aPar7[20]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '83000135'
            aPar7[21]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '85100048'
            aPar7[22]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '82000875'
            aPar7[23]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '83000151'
            aPar7[24]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '85200131'
            aPar7[25]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)

        ElseIf  AllTrim(TRBCEN->BR8_CODPSA) == '85100170'
            aPar7[26]:=Alltrim(TRBCEN->BR8_CODPAD) +"-"+ Alltrim(TRBCEN->BR8_CODPSA)
        EndIf

        TRBCEN->(DBSkip())

    EndDo

    TRBCEN->(DBCloseArea())

Return aPar7
