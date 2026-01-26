#include "Protheus.ch"
#include "ApWizard.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#include "TbIconn.ch" 
#include "FILEIO.CH"
#include "FWEVENTVIEWCONSTS.CH"
#include "WizImp.ch"
#Include "POSCSS.CH"

Static oTFont   := Nil
Static oTFont1  := Nil
Static oTFont2  := Nil
Static oTFont3  := Nil
Static oTFont4  := Nil

/*/{Protheus.doc} WizImp
Wizard para configuração do ambiente TOTVS Colaboração

@author Rodrigo.mpontes
@since 21/10/2013
/*/
Function WizImp()

    Private oOK 	    := LoadBitmap(GetResources(),'NGBIOALERTA_02.png')
    Private oNO 	    := LoadBitmap(GetResources(),'NGBIOALERTA_03.png')
    Private oYE         := LoadBitmap(GetResources(),'NGBIOALERTA_01.png')
    Private oDlg        := Nil
    Private oPanelWiz   := Nil
    Private oStepWiz    := Nil
    Private oNewPag1    := Nil
    Private oNewPag2    := Nil
    Private oNewPag3    := Nil
    Private oBrw1Pg2    := Nil 
    Private oBrw1Pg3    := Nil
    Private oBrw1Pg4    := Nil
    Private oBrw1Pg5    := Nil
    Private oBrw1Pg7    := Nil
    Private oBrw2Pg7    := Nil
    Private oBrw3Pg7    := Nil
    Private oBrw1Pg8    := Nil
    Private oBrw1Pg9    := Nil
    Private oBrw2Pg9    := Nil
    Private oG1Pg2      := Nil
    Private oG2Pg2      := Nil
    Private oG1Pg7      := Nil
    Private oG2Pg7      := Nil
    Private oMGetPg7    := Nil
    Private oG1Pg8      := Nil
    Private oG2Pg8      := Nil
    Private oMGetPg8    := Nil
    Private oGrp1Pg7    := Nil
    Private oGrp2Pg7    := Nil
    Private oGrp3Pg7    := Nil
    Private oGrp1Pg8    := Nil
    Private oBt1Pg1     := Nil
    Private oBt2Pg1     := Nil
    Private oBt3Pg1     := Nil
    Private oBt4Pg1     := Nil
    Private oBt5Pg1     := Nil
    Private oBt6Pg1     := Nil
    Private oBt7Pg1     := Nil
    Private oBt8Pg1     := Nil
    Private oBt9Pg1     := Nil
    Private oBt1Pg3     := Nil
    Private oBt2Pg3     := Nil
    Private oBt3Pg3     := Nil
    Private oBt4Pg3     := Nil
    Private oBt5Pg3     := Nil

    Private oS1Pg3      := Nil
    Private oS2Pg3      := Nil
    Private oS3Pg3      := Nil
    Private oG1Pg3      := Nil
    Private oG2Pg3      := Nil
    Private oG3Pg3      := Nil
    Private oG4Pg3      := Nil
    Private oG5Pg3      := Nil
    Private oG6Pg3      := Nil
    Private oG7Pg3      := Nil

    Private oBtn2Sts    := Nil
    Private oBtn3Sts    := Nil
    Private oBtn4Sts    := Nil
    Private oBtn5Sts    := Nil
    Private oBtn6Sts    := Nil
    Private oBtn7Sts    := Nil

    Private cMsgTab     := ""
    Private cMsgPrw     := ""
    Private cMsgMV1     := ""
    Private cMsgMV2     := ""
    Private cMsgSch     := ""
    Private cMVNGIN     := ""
    Private cMVNGLI     := ""
    Private cMVPar      := ""
    Private xMVCont     := Nil
    Private cMVDesc     := ""
    Private aMVWizIni   := WizImpMV("Wiz")
    Private lWIZCFG     := .F.
    Private lMVImp      := .F.
    Private lMVTraExp   := .F.
    Private lMVSched    := .F.
    Private cDOCIMP     := ""
    Private nCOMCOL1    := 0
    Private cCLIID      := ""
    Private cCLISECR    := ""
    Private lExecImp    := .F.
    Private aMVGer      := {}
    Private aMVNFe      := {}
    Private aMVCTe      := {}
    Private aMVIxT      := {}
    Private nOpcConf    := 1
    Private lBtNFE      := .F.
    Private lBtCTE      := .F.
    Private lBtNFS      := .F.
    Private lBtCTO      := .F.
    Private lBtMon      := .F.
    Private lBtPre      := .F.
    Private lBtCla      := .F.
    Private lBtImpXTra  := Iif(lWIZCFG, lMVTraExp, .T.)

    Private lBtCfgAvc   := .F.

    Private lStsTransm  := .F.
    Private lStsTabsEs  := .F.
    Private lStsPrgBin  := .F.
    Private lStsParImp  := .F.
    Private lStsParInt  := .F.
    Private lStsEmpFil  := .F.
    Private lStsSched   := .F.

    Private aTabelas    := {}
    Private aSchedule   := {}
    Private aFontes     := {}
    Private aMVImp      := {}
    Private aMVTra      := {}
    Private aAllGroup   := {}
    Private aFilial     := {}
    Private aFilSel     := {}

    lWIZCFG     := Iif(aMVWizIni[1][1] == 1, GetMV(aMVWizIni[1][2]), .F.)
    lMVImp      := Iif(aMVWizIni[2][1] == 1, GetMV(aMVWizIni[2][2]), .F.)
    lMVTraExp   := Iif(aMVWizIni[3][1] == 1, GetMV(aMVWizIni[3][2]), .F.)
    cDOCIMP     := Iif(aMVWizIni[4][1] == 1, aMVWizIni[4][4], Space(50))
    nCOMCOL1    := Iif(aMVWizIni[5][1] == 1, GetMV(aMVWizIni[5][2]), 0)
    cCLIID      := Iif(aMVWizIni[6][1] == 1, aMVWizIni[6][4], Space(150))
    cCLISECR    := Iif(aMVWizIni[7][1] == 1, aMVWizIni[7][4], Space(150))

    oTFont := TFont():New('Arial',,-16,,.F.)
    oTFont1:= TFont():New('Arial',,-16,,.T.)
    oTFont2:= TFont():New('Arial',,-20,,.F.)
    oTFont3:= TFont():New('Arial',,-20,,.T.)
    oTFont4:= TFont():New('Arial',,-16,,.T.,,,,,.T.)

    //Para que a tela da classe FWWizardControl fique no layout com bordas arredondadas iremos fazer com que a janela do Dialog oculte as bordas e a barra de titulo
    //para isso usaremos os estilos WS_VISIBLE e WS_POPUP
    DEFINE DIALOG oDlg TITLE STR0001 PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP ) //'Importador de XML'
        
        oDlg:nWidth := 1150
        oDlg:nHeight := 620

        oPanelWiz:= tPanel():New(0,0,"",oDlg,,,,,,300,150)
        oPanelWiz:Align := CONTROL_ALIGN_ALLCLIENT

        //Instancia a classe FWWizard
        oStepWiz:= FWWizardControl():New(oPanelWiz)
        oStepWiz:ActiveUISteps()

        // Pagina 1
        oNewPag1 := oStepWiz:AddStep("1")
        oNewPag1:SetStepDescription(STR0002) //"Boas Vindas"
        oNewPag1:SetConstruction({|Panel| WizImpPg(Panel,1)})
        oNewPag1:SetNextAction({|| WizImpVld(1)})
        oNewPag1:SetCancelAction({|| .T., oDlg:End()})

        //Pagina 2
        oNewPag2 := oStepWiz:AddStep("2")
        oNewPag2:SetStepDescription(STR0089) //"Credenciais"
        oNewPag2:SetConstruction({|Panel| WizImpPg(Panel,2)})
        oNewPag2:SetNextAction({|| WizImpVld(2)})
        oNewPag2:SetCancelAction({|| .T., oDlg:End()})
        oNewPag2:SetPrevAction({|| .T.})
        oNewPag2:SetPrevTitle(STR0004) //"Voltar"

        //Pagina 3
        oNewPag3 := oStepWiz:AddStep("3")
        oNewPag3:SetStepDescription(STR0090) //"Configurações"
        oNewPag3:SetConstruction({|Panel| WizImpPg(Panel,3)})
        oNewPag3:SetNextAction({|| Iif(WizImpVld(3),oDlg:End(),.F.)})
        oNewPag3:SetCancelAction({|| .T., oDlg:End()})
        oNewPag3:SetPrevAction({|| WizPgBack()})
        oNewPag3:SetPrevTitle(STR0004) //"Voltar"

        oStepWiz:Activate()

    ACTIVATE DIALOG oDlg CENTER

    oStepWiz:Destroy()

    FwFreeArray(aTabelas)
    FwFreeArray(aFontes)
    FwFreeArray(aMVImp)
    FwFreeArray(aMVTra)
    FwFreeArray(aAllGroup)
    FwFreeArray(aFilial)
    FwFreeArray(aFilSel)
    FwFreeArray(aMVWizIni)
    FwFreeArray(aMVGer)
    FwFreeArray(aMVNFe)
    FwFreeArray(aMVCTe)
    FwFreeArray(aMVIxT)
    FwFreeArray(aSchedule)

Return

/*/{Protheus.doc} WizImpPg
Wizard - Dados das paginas para configuração do Importador XML x Totvs Transmite

@param  oPanel  Painel de dados
@param  nPage   Pagina do painel

@author rodrigo.mpontes
@since 21/10/2013
/*/
Static Function WizImpPg(oPanel,nPage)

    Local cDesc1    := ""
    Local cDesc2    := ""
    Local cDesc3    := ""
    Local cDesc4    := ""
    Local bBtImp    := {|| .T.}
    Local bBtTra    := {|| .T.}
    Local cToolTip1 := ""
    Local cToolTip2 := ""

    If nPage == 1

        lBtNFE := "NFE" $ cDOCIMP
        lBtCTE := "CTE" $ cDOCIMP
        lBtCTO := "CTO" $ cDOCIMP
        lBtNFS := "NFS" $ cDOCIMP

        lBtMon := (nCOMCOL1 == 0)
        lBtPre := (nCOMCOL1 == 1)
        lBtCla := (nCOMCOL1 == 2)

        cDesc1 := STR0091 + " " + STR0148 + " " + STR0149 //"Boas-vindas ao Configurador de Integração do"
        cDesc2 := STR0145 //"Qual configuração deseja realizar?"
        cDesc3 := STR0093 //"Quais tipos de documentos serão importados?"
        cDesc4 := STR0094 //"Como gostaria que os documentos fossem integrados?"

        oS1Pg1 := TSay():New(005,000,{|| cDesc1 },oPanel,,oTFont2,,,,.T.,,,530,150)
        oS1Pg1:SetTextAlign(2,0)
        oS6Pg1 := TSay():New(025,000,{|| cDesc2 },oPanel,,oTFont,,,,.T.,,,530,150)
        oS6Pg1:SetTextAlign(2,0)

        If !lWIZCFG .Or. (lWIZCFG .And. !lMVTraExp)
            bBtImp := {|| AtuButt(3,1), oBt8Pg1:Refresh()}
            bBtTra := {|| AtuButt(3,2), oBt9Pg1:Refresh()}
            cToolTip1 := STR0146 //"Configurações para utilização apenas do importador xml"
            cToolTip2 := STR0147 //"Configurações para integração do Importador XML x TOTVS Transmite"
        EndIf

        oBt8Pg1	:= tButton():New(037,207,STR0148+CRLF+STR0149,oPanel,bBtImp,53,35,,,.F.,.T.,.F.,,.F.,,,.F.) //"Importador"#"XML"
        oBt8Pg1:cTooltip := cToolTip1
        Iif(!lWIZCFG, oBt8Pg1:SetCSS(getCSS(2)), oBt8Pg1:SetCSS(getCSS(1)))

        oBt9Pg1	:= tButton():New(037,267,STR0148+" "+STR0149+CRLF+"x"+CRLF+STR0151,oPanel,bBtTra,53,35,,,.F.,.T.,.F.,,.F.,,,.F.) //"Importador XML"#"Transmite"
        oBt9Pg1:cTooltip := cToolTip2
        Iif(lBtImpXTra, oBt9Pg1:SetCSS(getCSS(1)), oBt9Pg1:SetCSS(getCSS(2)))

        oS3Pg1 := TSay():New(082,000,{|| cDesc3 },oPanel,,oTFont,,,,.T.,,,530,150)
        oS3Pg1:SetTextAlign(2,0)

        oBt1Pg1	:= tButton():New(094,170,Upper(STR0036),oPanel,{|| AtuButt(1,1), oBt1Pg1:Refresh()},40,35,,,.F.,.T.,.F.,,.F.,,,.F.) //"NFE"
        Iif(lBtNFE, oBt1Pg1:SetCSS(getCSS(1)), oBt1Pg1:SetCSS(getCSS(2)))

        oBt2Pg1	:= tButton():New(094,220,Upper(STR0037),oPanel,{|| AtuButt(1,2), oBt2Pg1:Refresh()},40,35,,,.F.,.T.,.F.,,.F.,,,.F.) //"CTE"
        Iif(lBtCTE, oBt2Pg1:SetCSS(getCSS(1)), oBt2Pg1:SetCSS(getCSS(2)))

        oBt3Pg1	:= tButton():New(094,270,STR0095,oPanel,{|| AtuButt(1,3), oBt3Pg1:Refresh()},40,35,,,.F.,.T.,.F.,,.F.,,,.F.) //"CTOS"
        Iif(lBtCTO, oBt3Pg1:SetCSS(getCSS(1)), oBt3Pg1:SetCSS(getCSS(2)))

        oBt4Pg1	:= tButton():New(094,320,STR0096,oPanel,{|| AtuButt(1,4), oBt4Pg1:Refresh()},40,35,,,.F.,.T.,.F.,,.F.,,,.F.) //"NFSE"
        Iif(lBtNFS, oBt4Pg1:SetCSS(getCSS(1)), oBt4Pg1:SetCSS(getCSS(2)))

        oS4Pg1 := TSay():New(140,000,{|| cDesc4 },oPanel,,oTFont,,,,.T.,,,530,150)
        oS4Pg1:SetTextAlign(2,0)

        oBt5Pg1	:= tButton():New(152,190,STR0097,oPanel,{|| AtuButt(2,1)},45,35,,,.F.,.T.,.F.,,.F.,,,.F.) //"Monitor XML"
        Iif(lBtMon, oBt5Pg1:SetCSS(getCSS(1)), oBt5Pg1:SetCSS(getCSS(2)))

        oBt6Pg1	:= tButton():New(152,245,STR0098,oPanel,{|| AtuButt(2,2)},45,35,,,.F.,.T.,.F.,,.F.,,,.F.) //"Pré-Nota"
        Iif(lBtPre, oBt6Pg1:SetCSS(getCSS(1)), oBt6Pg1:SetCSS(getCSS(2)))

        oBt7Pg1	:= tButton():New(152,300,STR0099+CRLF+STR0100,oPanel,{|| AtuButt(2,3)},45,35,,,.F.,.T.,.F.,,.F.,,,.F.) //"Documento"#"Classificado"
        Iif(lBtCla, oBt7Pg1:SetCSS(getCSS(1)), oBt7Pg1:SetCSS(getCSS(2)))

        oS5Pg1 := TSay():New(185,010,{|| STR0101 },oPanel,,oTFont4,,,,.T.,,,100,50) //"Documentações"
        oS5Pg1:blClicked := {|| WizDocs()}
        oS5Pg1:nClrText  := CLR_BLUE

    Elseif nPage == 2

        cCLIID := Iif(!Empty(cCLIID), Padr(cCLIID,150), Space(150))
        cCLISECR := Iif(!Empty(cCLISECR), Padr(cCLISECR,150), Space(150))

        oS1Pg2 := TSay():New(10,10,{|| STR0102 },oPanel,,oTFont2,,,,.T.,,,530,150) //"CONFIGURAÇÕES DE CREDENCIAIS - TOTVS TRANSMITE"
        oS1Pg2:SetTextAlign(2,0)

        oS2Pg2 := TSay():New(80,10,{|| STR0103 },oPanel,,oTFont3,,,,.T.,,,80,20)
        oG1Pg2 := TGet():New(73,100,{|u|If(PCount()==0,cCLIID,cCLIID := u ) },oPanel,450,20,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCLIID",,,,) //"Client ID:"
        Iif(!lBtImpXTra, oG1Pg2:Disable(), oG1Pg2:Enable())

        oS3Pg2 := TSay():New(110,10,{|| STR0104 },oPanel,,oTFont3,,,,.T.,,,80,20)
        oG2Pg2 := TGet():New(103,100,{|u|If(PCount()==0,cCLISECR,cCLISECR := u ) },oPanel,450,20,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCLISECR",,,,) //"Client SECRET:"
        Iif(!lBtImpXTra, oG2Pg2:Disable(), oG2Pg2:Enable())

        oS2Pg2 := TSay():New(185,10,{|| STR0101 },oPanel,,oTFont4,,,,.T.,,,100,50) //"Documentações"
        oS2Pg2:blClicked := {|| WizDocs()}
        oS2Pg2:nClrText  := CLR_BLUE

    Elseif nPage == 3

        oS1Pg3 := TSay():New(10,10,{|| STR0105 },oPanel,,oTFont2,,,,.T.,,,530,150) //"CONFIGURAÇÕES AUTOMÁTICAS"
        oS1Pg3:SetTextAlign(2,0)

        oBt1Pg3	:= tButton():New(055,220,STR0106,oPanel,{|| FWMsgRun(,{|| WizProcAut(.T.)},STR0107,STR0108), WizTelaCfg(oPanel), oPanel:Refresh()},100,60,,,.F.,.T.,.F.,,.F.,,,.F.) //"CONFIGURAR"#"Configuração Automática"#"Realizando configurações automáticas"
        oBt1Pg3:SetCSS(getCSS(2))

        oS2Pg3 := TSay():New(185,055,{|| STR0101 },oPanel,,oTFont4,,,,.T.,,,100,50) //"Documentações"
        oS2Pg3:blClicked := {|| WizDocs()}
        oS2Pg3:nClrText  := CLR_BLUE

        oS3Pg3 := TSay():New(185,370,{|| STR0109 },oPanel,,oTFont4,,,,.T.,,,150,50) //"Acessar configurações avançadas"
        oS3Pg3:blClicked := {|| WizCfgAvc(oPanel), lBtCfgAvc := .T.}
        oS3Pg3:nClrText  := CLR_BLUE
        If !lWIZCFG
            oS3Pg3:Disable()
            oS3Pg3:Hide()
        Else
            WizProcAut(.F.)
            WizTelaCfg(oPanel)
        EndIf
    Endif

Return

/*/{Protheus.doc} WizPgBack
Remonta a tela de resumo da página 3 do Wizard

@param  oPanel  Painel de dados

@author Leonardo Kichitaro
@since 19/01/2024
/*/
Static Function WizPgBack()

    If lBtCfgAvc
        oS1Pg3:cCaption := STR0105 //"CONFIGURAÇÕES AUTOMÁTICAS"

        If lBtImpXTra
            oBt2Pg3:Disable()
            oBt2Pg3:Hide()
            oBt3Pg3:Disable()
            oBt3Pg3:Hide()
            oBt4Pg3:Disable()
            oBt4Pg3:Hide()
            oBt5Pg3:Disable()
            oBt5Pg3:Hide()
        Else
            oBt2Pg3:Disable()
            oBt2Pg3:Hide()
            oBt3Pg3:Disable()
            oBt3Pg3:Hide()
        EndIf

        WizTelaCfg()
    EndIf

Return .T.

/*/{Protheus.doc} WizImpCGrp
Wizard - Importador XML x Totvs Transmite
Duplo clique para selecionar Filial integrada com o Totvs Transmite

@param  oObj    Browse de dados
@param  aDados  Array de dados
@param  cOpc    A - ALL / I - Item

@author rodrigo.mpontes
@since 21/10/2013
/*/
Static Function WizImpCGrp(oObj,aDados,cOpc)

    Local nI        := 0
    Local nPerc     := 0
    Local cMsgAdd   := ""
    Local cMsgNAd   := ""
    Local cMsgDel   := ""

    Default cOpc    := "I"

    If cOpc == "I"
        //Grava DHW ou Deleta DHW (CodFil)
        aDados[oObj:nAt,1] := WizImpTGrp(!aDados[oObj:nAt,1],oObj)
    Elseif cOpc == "A"
        ProcRegua(Len(aDados))
        For nI := 1 To Len(aDados)
            nPerc := Round((nI*100)/Len(aDados),0)
            IncProc(STR0050 + AllTrim(Str(nPerc)) + "%") //"Verificando se filial(ais) integra com o Totvs Transmite: "
            aDados[nI,1] := WizImpTGrp(!aDados[nI,1],oObj,nI,@cMsgAdd,@cMsgNAd,@cMsgDel)
        Next nI
    Endif

    //Atualiza Browse
    oObj:SetArray(aDados)
    oObj:bLine := {|| {If(aDados[oObj:nAT,1],oOK,oNo),aDados[oObj:nAt,02],aDados[oObj:nAt,03],aDados[oObj:nAt,04]}}
    oObj:Refresh()

    If cOpc == "A"
        WizImpHlp(cMsgAdd + CRLF + CRLF + cMsgNAd + CRLF + CRLF + cMsgDel,"D")
    Endif

Return

/*/{Protheus.doc} WizImpTGrp
Wizard - Importador XML x Totvs Transmite
Gravação ou Exclusão da DHW - Amarração Protheus x Totvs Transmite (CodFil)

@param  lGrvDhW Logico para verificar se filial foi gravada ou não
@param  oObj    Objeto - Browse

@author rodrigo.mpontes
@since 21/10/2013
/*/
Static Function WizImpTGrp(lGrvDhW,oObj,nLin,cMsgAdd,cMsgNAd,cMsgDel,lTela)

    Local lFindDHW  := .F.
    Local nTamGrp   := TamSX3("DHW_GRPEMP")[1]
    Local nTamFil   := TamSX3("DHW_FILEMP")[1]
    Local aSM0Dados	:= {}
    Local aDadosFil := {}
    Local cCodFil   := ""
    Local lAll      := .F.

    Default nLin    := 0
    Default lTela   := .T.

    If lTela
        If nLin == 0
            nLin := oObj:nAt
        Else //Header Click
            lAll := .T.
        Endif
        aDadosFil := oObj:aArray
    Else
        lAll := .T.
        aDadosFil := oObj
    EndIf

    DbSelectArea("DHW") 
    DHW->(DbSetOrder(1))
    lFindDHW := DHW->(DbSeek(xFilial("DHW") + PadR(aDadosFil[nLin,2],nTamGrp) + PadR(aDadosFil[nLin,3],nTamFil)))

    If lGrvDhW .And. !lFindDHW //Grava DHW
        aSM0Dados 	:= FWSM0Util():GetSM0Data( aDadosFil[nLin,2] , aDadosFil[nLin,3] , { "M0_CGC","M0_INSC","M0_ESTENT" } )
        cCodFil		:= WizImpCodFil(aDadosFil[nLin,2],aDadosFil[nLin,3],aSM0Dados[1,2],aSM0Dados[2,2],aSM0Dados[3,2])

        If !Empty(cCodFil) 
            If RecLock("DHW",.T.)
                DHW->DHW_FILIAL := xFilial("DHW") 
                DHW->DHW_GRPEMP := aDadosFil[nLin,2]
                DHW->DHW_FILEMP := aDadosFil[nLin,3]
                DHW->DHW_CGC    := aSM0Dados[1,2]
                DHW->DHW_IE     := aSM0Dados[2,2]
                DHW->DHW_UF     := aSM0Dados[3,2]
                DHW->DHW_CODFIL := cCodFil 

                DHW->(MsUnlock())
            Endif
            If lAll
                If Empty(cMsgAdd)
                    cMsgAdd += STR0051 + AllTrim(aDadosFil[nLin,3]) //"Filial(ais) conectadas ao Totvs Transmite: "
                Else
                    cMsgAdd += " | " + AllTrim(aDadosFil[nLin,3])
                Endif
            Endif
        Else
            lGrvDhW := .F.
            If lAll
                If Empty(cMsgNAd)
                    cMsgNAd += STR0052 + AllTrim(aDadosFil[nLin,3]) //"Filial(ais) não encontradas no Totvs Transmite: "
                Else
                    cMsgNAd += " | " + AllTrim(aDadosFil[nLin,3])
                Endif
            Else
                WizImpHlp(STR0053,"B") //"Não foi encontrada Grp Empresa/Filial no Totvs Transmite"
            Endif
        Endif
    Elseif !lGrvDhW .And. lFindDHW //Deleta DHW
        If RecLock("DHW",.F.)
            DHW->(dbDelete())
            DHW->(MsUnlock())
        Endif
        If lAll
            If Empty(cMsgDel)
                cMsgDel += STR0054 + AllTrim(aDadosFil[nLin,3]) //"Filial(ais) desconectadas ao Totvs Transmite: "
            Else
                cMsgDel += " | " + AllTrim(aDadosFil[nLin,3])
            Endif
        Endif
    Endif

Return lGrvDhW

/*/{Protheus.doc} WizImpCodFil
Integração com Transmite para busca Codigo Filial correspondente

@author rodrigo.mpontes
@since 05/08/19
/*/
Static Function WizImpCodFil(cEmp,cFil,cCGC,cIE,cUF)

    Local oComTransmite	:= Nil
    Local lImpXML       := CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))
    Local cConteudo		:= ""

    If lImpXML
        oComTransmite := ComTransmite():New()

        If oComTransmite:TokenTotvsTransmite()
            cConteudo := oComTransmite:GetCodigoFilial(cCGC,cIE,cUF,cEmp,cFil)
        Endif

        FreeObj(oComTransmite)
    Endif 

Return cConteudo

/*/{Protheus.doc} WizImpAGrp
Wizard - Importador XML x Totvs Transmite
Atualização de Filiais por Grupo de Empresa

@param  nEmpLin     Posição do Grupo de Empresa
@param  aFilial     Dados dos Grupos e Filiais    
@param  oObjFil     Objeto - Browse
@param  aFilGrp     Array para atualizar as filiais do grupo selecionado

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpAGrp(nEmpLin,aFilial,oObjFil,aFilGrp) 

    //Busca Filiais, a partir da Grupo selecionado
    Local aAux  := WizImpGrp(aFilial,nEmpLin)

    If Len(aAux) > 0
        aFilGrp := aAux[2]
        oObjFil:SetArray(aFilGrp)
        oObjFil:bLine := {|| {If(aFilGrp[oObjFil:nAT,1],oOK,oNo),aFilGrp[oObjFil:nAt,02],aFilGrp[oObjFil:nAt,03],aFilGrp[oObjFil:nAt,04]}}
        oObjFil:Refresh()
    Endif

Return

/*/{Protheus.doc} WizImpGrp
Wizard - Importador XML x Totvs Transmite
Carrega todos Grupos e Filias

@param  aFilial     Dados dos Grupos e Filiais    
@param  nEmp        Posição do Grupo de Empresa

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpGrp(aFilial,nEmp)

    Local nI        := 0
    Local aAux      := {}
    Local aGrp      := {}
    Local aFilGrp   := {}
    Local aSM0Dados := {}
    Local nTamGrp   := TamSX3("DHW_GRPEMP")[1]
    Local nTamFil   := TamSX3("DHW_FILEMP")[1]

    //Grupo de Empresas
    For nI := 1 To Len(aFilial)
        aAdd(aGrp,aFilial[nI,1])
    Next nI

    //Filiais do Grupo
    aAux := Separa(aFilial[nEmp,2],"|")
    For nI := 1 To Len(aAux)
        
        aSM0Dados 	:= FWSM0Util():GetSM0Data( aFilial[nEmp,1] , aAux[nI] , { "M0_FILIAL" } )

        //Verifica se ja possui vinculo com o Transmite (DHW)
        If !Empty(GetAdvFVal("DHW","DHW_CODFIL",xFilial("DHW") + PadR(aFilial[nEmp,1],nTamGrp) + PadR(aAux[nI],nTamFil),1))
            aAdd(aFilGrp,{.T.,aFilial[nEmp,1],aAux[nI],aSM0Dados[1,2]}) 
        Else
            aAdd(aFilGrp,{.F.,aFilial[nEmp,1],aAux[nI],aSM0Dados[1,2]}) 
        Endif
    Next nI

    If Len(aGrp) > 0 .And. Len(aFilGrp) > 0
        aRet := {aGrp,aFilGrp}
    Endif

Return aRet

/*/{Protheus.doc} WizImpVld
Wizard - Importador XML x Totvs Transmite
Validações das paginas

@param  nPage   Pagina a ser validada

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpVld(nPage)

    Local lRet      := .T.
    Local cMsg      := ""
    Local cOpc      := "" // B-Bloqueio / A-Aviso
    Local cParPut   := ""
    Local cXMLCID   := ""
    Local cXMLCSEC  := ""
    Local cAPITRAN  := ""

    If nPage == 1 //Grava parâmetros informados na página 1 do Wizard
        cParPut += Iif(lBtNFE,"NFE","")
        cParPut += Iif(lBtNFS .And. !Empty(cParPut),"/","") + Iif(lBtNFS,"NFS","")
        cParPut += Iif(lBtCTE .And. !Empty(cParPut),"/","") + Iif(lBtCTE,"CTE","")
        cParPut += Iif(lBtCTO .And. !Empty(cParPut),"/","") + Iif(lBtCTO,"CTO","")

        cDOCIMP := cParPut
        PutMV("MV_DOCIMP",cParPut)

        nCOMCOL1 := Iif(lBtPre,1,Iif(lBtCla,2,0))
        PutMV("MV_COMCOL1",nCOMCOL1)

        lRet := .T.

        If !lBtImpXTra .And. oG1Pg2 <> Nil .And. oG2Pg2 <> Nil
            oG1Pg2:Disable()
            oG2Pg2:Disable()
        ElseIf oG1Pg2 <> Nil .And. oG2Pg2 <> Nil
            oG1Pg2:Enable()
            oG2Pg2:Enable()
        EndIf

        If lBtImpXTra .And. lWIZCFG .And. !lMVTraExp
            lWIZCFG := .F.
        EndIf
    Elseif nPage == 2  //Valida comunicação com TOTVS Transmite e grava parâmetros informados na página 2 do Wizard
        If lBtImpXTra
            cXMLCID     := AllTrim(cCLIID)
            cXMLCSEC    := AllTrim(cCLISECR)
            cAPITRAN    := Iif(aMVWizIni[8][1] == 1, AllTrim(aMVWizIni[8][4]), "")
            cAPITRAN    := Iif(Empty(cAPITRAN), "production", cAPITRAN)

            If Empty(cXMLCID) .Or. Empty(cXMLCSEC) .Or. Empty(cAPITRAN)
                lRet := .F.
                lStsTransm := lRet
                cMsg := STR0063 + ; //"Sem informação nos parametros MV_XMLCID/MV_XMLCSEC/MV_APITRAN integração com Totvs Transmite não funcionara "
                        CRLF + STR0064
                cOpc := "C"
            Elseif !Empty(cXMLCID) .Or. !Empty(cXMLCSEC) .Or. !Empty(cAPITRAN)
                cMsg := STR0065 //"Validando conexão com o Totvs Transmite!"
                cOpc := "C"

                lRet := WizImpVldTra(cXMLCID,cXMLCSEC,cAPITRAN)
                lStsTransm := lRet
                cMsg := ""

                If lRet
                    PutMV("MV_XMLCID",cCLIID)
                    PutMV("MV_XMLCSEC",cCLISECR)
                    PutMV("MV_APITRAN",cAPITRAN)

                    If lBtImpXTra .And. !lMVTraExp .And. lExecImp 
                        oG2Pg3:Hide()
                        oBtn2Sts:Disable()
                        oBtn2Sts:Hide()

                        oG3Pg3:Hide()
                        oBtn3Sts:Disable()
                        oBtn3Sts:Hide()

                        oG4Pg3:Hide()
                        oBtn4Sts:Disable()
                        oBtn4Sts:Hide()

                        if lMVSched
                            oG7Pg3:Hide()
                            if !(lStsSched)
                                oBtn7Sts:Disable()
                                oBtn7Sts:Hide()
                            endif
                        endif

                        oS3Pg3:Disable()
                        oS3Pg3:Hide()

                        oBt1Pg3:Enable()
                        oBt1Pg3:Show()
                        oBt1Pg3:Refresh()

                        lBtCfgAvc := .F.
                    EndIf
                EndIf
            EndIf
        EndIf
    Elseif nPage == 3
        lRet := lWIZCFG
        cOpc := "A"
        If !lRet
            cMsg := STR0110 + CRLF + CRLF +; //"Configurações automáticas não executada."
                    STR0110 + CRLF + CRLF +; //"Para realizar as configurações automáticas clique em 'CONFIGURAR' que é apresentado na última etapa do configurador de integração."
                    STR0112                  //"Deseja finalizar o processo de configuração sem as configurações mínimas necessárias para integração do Importador XML x TOTVS Transmite?"
        EndIf
    Endif

    If !lRet .And. !Empty(cMsg)
        If nPage == 2
            WizImpHlp(cMsg,cOpc)
        Else
            lRet := WizImpHlp(cMsg,cOpc)
        EndIf
    Endif

Return lRet

/*/{Protheus.doc} WizImpHlp
Wizard - Importador XML x Totvs Transmite
Avisos do wizard

@param  cMsg   Mensagem a ser exibida
@param  cOpc   B-Bloqueio / A-Aviso    

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpHlp(cMsg,cOpc)

    Local lRet      := .F.
    Local aOpc    := {}
    Local nOpc      := 0

    If cOpc == "B" .Or. cOpc == "C"
        aOpc := {STR0019} //"Ok"
    Elseif cOpc == "A"
        aOpc := {STR0066,STR0067} //"Sim"#"Não"
    Endif

    If cOpc <> "D"
        nOpc := Aviso(STR0068,cMsg,aOpc) //"Atenção"
    Elseif cOpc == "D"
        DEFINE MSDIALOG oDlgFil TITLE STR0069 FROM 000,000 TO 600,800 PIXEL //"Filial(ais) - Importador XML x Totvs Transmite"

        oTMGetFil := tMultiget():new(05,05, {| u | if( pCount() > 0, cMsg := u, cMsg ) },oDlgFil, 390, 290, , , , , , .T. ) 

        ACTIVATE MSDIALOG oDlgFil CENTERED  
    Endif

    If cOpc == "A"
        lRet := (nOpc == 1)
    Elseif cOpc == "C" .Or. cOpc == "D"
        lRet := .T.
    Endif

Return lRet

Static Function WizImpSched()

local aAux	    := {}
local aRet	    := {}
local nX	    := 0
Local nAddAgend := 0
Local lTemAgend
Local lCadAgend := .F.
Local aSM0Grp   := { FWAllFilial( , , cEmpAnt, .F.)[1] }
Local aSM0Fil   := {}
Local aParam    := {}
Local aGrpComp  := {}

    If lBtImpXTra
        aParam   := {  "SCHEDIMPTRA"       ,;  // setRoutine
                       nModulo             ,;  // setModule
                       "000000"            ,;  // setUser
                       STR0154             ,;  // setDescription   # "Rotina para requisitar e ler recibos retornados do TOTVS Transmite"
                       .T.                 ,;  // setRecurrence
                       {'D', , 1, 0, }     ,;  // setPeriod
                       {'M', 10, , , }     ,;  // setFrequency
                       .T.                 ,;  // setDiscard
                       .T.                 ,;  // setManageable
                       {{ cEmpAnt, aSM0Grp }},; 
                       { DATE(),TIME() }    ;   // setFirstExecution
                    }

        AADD(aAux,{'SCHEDIMPTRA',STR0154,aParam})	// "Rotina para requisitar e ler recibos retornados do TOTVS Transmite"

        aParam  := {    "SCHEDUPDTRA"       ,;  // setRoutine
                        nModulo             ,;  // setModule
                        "000000"            ,;  // setUser
                        STR0155             ,;  // setDescription   # "Rotina para atualização dos status dos documentos no TOTVS Transmite"
                        .T.                 ,;  // setRecurrence
                        {'D', , 1, 0, }     ,;  // setPeriod
                        {'M', 20, , , }     ,;  // setFrequency
                        .T.                 ,;  // setDiscard
                        .T.                 ,;  // setManageable
                        {{ cEmpAnt, aSM0Grp }},; 
                        { DATE(),TIME() }   ;   // setFirstExecution
                    }

        AADD(aAux,{'SCHEDUPDTRA',STR0155,aParam})	// "Rotina para atualização dos status dos documentos no TOTVS Transmite"
    Else
        aParam  := {    "COLAUTOREAD"       ,;  // setRoutine
                        nModulo             ,;  // setModule
                        "000000"            ,;  // setUser
                        STR0153             ,;  // setDescription   # "Rotina para importação dos arquivos XML's para o diretório IN (MV_NGINN), gravando as informações na tabela CKO"
                        .T.                 ,;  // setRecurrence
                        {'D', , 1, 0, }     ,;  // setPeriod
                        {'M', 30, , , }     ,;  // setFrequency
                        .T.                 ,;  // setDiscard
                        .T.                 ,;  // setManageable
                        {{ cEmpAnt, aSM0Grp }} ,; 
                        { DATE(),TIME() }   ;   // setFirstExecution
                    }

        AADD(aAux,{'COLAUTOREAD',STR0153,aParam})	// "Rotina para importação dos arquivos XML's para o diretório IN (MV_NGINN), gravando as informações na tabela CKO"
    Endif

    aGrpComp := FWAllGrpCompany()
    aSM0Fil  := {}

    aEval(aGrpComp,{|x| aadd(aSM0Fil, { x, FWAllFilial( , , x, .F.) }) })

    aParam  := {    "SCHEDCOMCOL"       ,;  // setRoutine
                    nModulo             ,;  // setModule
                    "000000"            ,;  // setUser
                    STR0156             ,;  // setDescription   # "Rotina para efetuar a leitura dos XML's na tabela CKO e importar ao monitor (Tabelas SDS e SDT)."
                    .T.                 ,;  // setRecurrence
                    {'D', , 1, 0, }     ,;  // setPeriod
                    {'M', 20, , , }     ,;  // setFrequency
                    .T.                 ,;  // setDiscard
                    .T.                 ,;  // setManageable
                    aSM0Fil             ,; 
                    { DATE(),TIME() }   ;   // setFirstExecution
                }

    AADD(aAux,{'SCHEDCOMCOL',STR0156,aParam})	// "Rotina para efetuar a leitura dos XML's na tabela CKO e importar ao monitor (Tabelas SDS e SDT)."

    for nX := 1 to len(aAux)
        lTemAgend := !Empty(FWSchdByFunction(aAux[nX][1]))
        If lTemAgend
            nAddAgend++
        Endif
    next nX

    If Len(aAux) > nAddAgend
        lCadAgend := .T.
    Endif

    for nX := 1 to len(aAux)
        lTemAgend := !Empty(FWSchdByFunction(aAux[nX][1]))
        AADD(aRet,{ if( lTemAgend,.T.,.F.), aAux[nX][1], aAux[nX][2], lCadAgend, aAux[nX][3], lTemAgend })
    next nX

return aRet

/*/{Protheus.doc} WizImpTab
Wizard - Importador XML x Totvs Transmite
Validação das tabelas/estrutura

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpTab()

    Local aTabVer   := {{"CKO",;
                        {"CKO_ARQUIV","CKO_XMLRET","CKO_FLAG","CKO_CODEDI","CKO_CODERR","CKO_FILPRO","CKO_EMPPRO","CKO_CNPJIM","CKO_ARQXML","CKO_MSGERR",;
                        "CKO_DOC","CKO_NOMFOR","CKO_SERIE","CKO_CHVDOC","CKO_ORIGEM","CKO_STRAN","CKO_ERRTRA","CKO_RECIBO"}},;
                        {"SDS",;
                        {"DS_DOC","DS_SERIE","DS_FORNEC","DS_LOJA","DS_NOMEFOR","DS_CNPJ","DS_TIPO","DS_ESPECI","DS_EMISSA","DS_FORMUL","DS_EST","DS_ARQUIVO",;
                        "DS_CHAVENF","DS_UFDESTR","DS_MUDESTR","DS_MUORITR","DS_UFORITR"}},;
                        {"SDT",;
                        {"DT_ITEM","DT_COD","DT_PRODFOR","DT_DESCFOR","DT_FORNEC","DT_LOJA","DT_DOC","DT_SERIE","DT_CNPJ","DT_QUANT","DT_VUNIT","DT_PEDIDO",;
                        "DT_ITEMPC","DT_NFORI","DT_SERIORI","DT_ITEMORI","DT_TES","DT_LOTE","DT_DTVALID","DT_LOCAL","DT_CHVNFO","DT_UM","DT_SEGUM","DT_QTSEGUM","DT_CLASFIS"}},;
                        {"DHW",;
                        {"DHW_GRPEMP","DHW_FILEMP","DHW_CGC","DHW_IE","DHW_UF","DHW_CODFIL"}},;
                        {"DHY",;
                        {"DHY_CODFIL","DHY_ID","DHY_TPXML","DHY_DTID","DHY_FILTRO","DHY_MESSAG"}},;
                        {"DHZ",;
                        {"DHZ_CODFIL","DHZ_ID","DHZ_TPXML","DHZ_DTID","DHZ_FILTRO","DHZ_DTLID","DHZ_MESSAG"}}}

    Local aTabRet   := {}
    Local nI        := 0
    Local cMsgEst   := ""
    Local cSqlName  := ""

    For nI := 1 To Len(aTabVer)
        cMsgTab += STR0070 + aTabVer[nI,1] + CRLF //"Tabela: "
        cMsgEst := ""
        If ChkFile(aTabVer[nI,1])
            If aTabVer[nI,1] == "CKO"
                cSqlName := RetSqlName("CKO")
                lStsTabsEs := Iif(cSqlName <> "CKOCOL", .F., lStsTabsEs)
                If cSqlName <> "CKOCOL"
                    cMsgTab += "[ERROR].......... " + STR0071 + CRLF + CRLF + CRLF + CRLF //"Tabela: inexistente e/ou diferente de CKOCOL no ambiente"
                    aAdd(aTabRet,{2,aTabVer[nI,1],FwSX2Util():GetX2Name(aTabVer[nI,1])})
                Else
                    cMsgTab += "[OK]............. " + STR0072 + CRLF //"Tabela: OK"
                    cMsgEst := WizImpEst(aTabVer[nI,1],aTabVer[nI,2]) + CRLF + CRLF + CRLF
                    cMsgTab += cMsgEst
                    aAdd(aTabRet,{Iif("WARNING" $ cMsgEst,3,1),aTabVer[nI,1],FwSX2Util():GetX2Name(aTabVer[nI,1])})
                Endif
            Else
                cMsgTab += "[OK]............. " + STR0072 + CRLF //"Tabela: OK"
                cMsgEst := WizImpEst(aTabVer[nI,1],aTabVer[nI,2]) + CRLF + CRLF + CRLF
                cMsgTab += cMsgEst
                aAdd(aTabRet,{Iif("WARNING" $ cMsgEst,3,1),aTabVer[nI,1],FwSX2Util():GetX2Name(aTabVer[nI,1])}) 
            Endif
        Else
            cMsgTab += "[ERROR].......... " + STR0073 + CRLF + CRLF + CRLF + CRLF //"Tabela: inexistente no ambiente"
            aAdd(aTabRet,{2,aTabVer[nI,1],FwSX2Util():GetX2Name(aTabVer[nI,1])})
        Endif
    Next nI

Return aTabRet

/*/{Protheus.doc} WizImpEst
Wizard - Importador XML x Totvs Transmite
Validação das estrutura da tabela

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpEst(cTab,aEstTab)

    Local aAllCpo   := FWSX3Util():GetAllFields( cTab ,.T.)
    Local cMsgRet   := ""
    Local nI        := 0
    Local cMsg      := ""

    For nI := 1 To Len(aEstTab)
        nPos := aScan(aAllCpo,{|x| AllTrim(x) == AllTrim(aEstTab[nI])})
        If nPos == 0
            cMsg += " | " + aEstTab[nI]
        Endif
    Next nI

    If !Empty(cMsg)
        cMsg := SubStr(cMsg,4,Len(cMsg))
        cMsgRet += "[WARNING]........ " + STR0074 + cMsg + STR0075 //"Estrutura: "#" campo(s) inexistente(s) no ambiente"
    Else
        cMsgRet += "[OK]............. " + STR0076 //"Estrutura: OK"
    Endif

Return cMsgRet

/*/{Protheus.doc} WizImpEst
Wizard - Importador XML x Totvs Transmite
Validação do binario e fontes

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpPrw() 

    Local aPrwVer   := {{"APPSERVER","20.3.0.14","TEC"},;
                        {"COLAUTOREAD.PRW","19/09/2023","TSS"},;
                        {"COMTRANSMITE.PRW","24/04/2024","COM"},;
                        {"SCHEDCOMCOL.PRW","09/05/2024","COM"},;
                        {"COMXCOL.PRW","27/05/2024","COM"},;
                        {"COMXCOL2.PRW","27/05/2024","COM"},;
                        {"MATA140I.PRW","27/05/2024","COM"},;
                        {"MATA116I.PRW","27/05/2024","COM"},;
                        {"SCHEDIMPTRA.PRW","13/03/2024","COM"},;
                        {"SCHEDUPDTRA.PRW","19/09/2023","COM"},;
                        {"IMPTRATOOL.PRW","11/01/2024","COM"}}
    Local aPrwRet   := {}
    Local nI        := 0
    Local aDados    := {}
    Local cDtTime   := ""
    Local cDtTRpo   := ""
    Local cBuild    := ""

    For nI := 1 To Len(aPrwVer)
        If aPrwVer[nI,1] <> "APPSERVER" 
            cMsgPrw += STR0077 + aPrwVer[nI,1] + CRLF //"Programa: "
            cDtTime := aPrwVer[nI,2]
            
            aDados := GetApoInfo(aPrwVer[nI,1])
            lStsPrgBin := Iif(Len(aDados) == 0, .F., lStsPrgBin)

            If Len(aDados) > 0
                cDtTRpo := DtoC(aDados[4])
                lStsPrgBin := Iif(CtoD(cDtTRpo) < CtoD(cDtTime), .F., lStsPrgBin)
                If CtoD(cDtTRpo) < CtoD(cDtTime)
                    cMsgPrw += "[WARNING]........ " + STR0078 + CRLF + CRLF //"Programa: Desatualizado"
                    aAdd(aPrwRet,{3,aPrwVer[nI,1],aPrwVer[nI,3],cDtTime,cDtTRpo})
                Else
                    cMsgPrw += "[OK]............. " + STR0079 + CRLF + CRLF //"Programa: OK"
                    aAdd(aPrwRet,{1,aPrwVer[nI,1],aPrwVer[nI,3],cDtTime,cDtTRpo}) 
                Endif
            Else
                cMsgPrw += "[ERROR].......... " + STR0080 + CRLF + CRLF //"Programa: inexistente no ambiente"
                aAdd(aPrwRet,{2,aPrwVer[nI,1],aPrwVer[nI,3],cDtTime,""})
            Endif
        ElseIf aPrwVer[nI,1] == "APPSERVER" 
            cMsgPrw += "AppServer" + CRLF
            cBuild  := GetSrvVersion()
            cMsgPrw += Iif(cBuild < aPrwVer[nI,2],"[WARNING]........ " + STR0081 + CRLF + CRLF,"[OK]............. " + STR0082 + CRLF + CRLF)
            lStsPrgBin := Iif(cBuild < aPrwVer[nI,2], .F., lStsPrgBin)
            aAdd(aPrwRet,{Iif(cBuild < aPrwVer[nI,2],3,1),aPrwVer[nI,1],aPrwVer[nI,3],aPrwVer[nI,2],cBuild})
        Endif
    Next nI

Return aPrwRet

/*/{Protheus.doc} WizImpMV
Wizard - Importador XML x Totvs Transmite
Validação dos parametros

@param  cOpc    Tipo dos parametros
                    Imp - Importador XML
                    Tra/IxT - Importador XML x Totvs Transmite
                    Ger - Geral - Importador XML
                    NFe - NFe - Importador XML
                    CTe - CTe - Importador XML

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpMV(cOpc) 

    Local aMVVer    := {}
    Local aMVRet    := {}
    Local aAux      := {}
    Local nI        := 0
    Local cMsg      := ""
    Local cDescMV   := ""
    Local xConteudo := Nil
    Local lParShow  := .F.

    If cOpc == "Imp" //Importador XML
        aMVVer := {"MV_IMPXML","MV_COMCOL1","MV_COMCOL2","MV_COMCOL3","MV_MSGCOL","MV_FILREP","MV_XMLCFPC","MV_XMLCFBN","MV_XMLCFDV","MV_XMLCFND","MV_XMLCFNO",;
                    "MV_CTECLAS","MV_XMLPFCT","MV_XMLTECT","MV_XMLCPCT","MV_COLVCHV","MV_VLRCTE","MV_WIZCFG","MV_COLVDCS","MV_UFNFSF","MV_WIZSCHD"}
    Elseif cOpc == "Tra" .Or. cOpc == "IxT" //Importador XML x Totvs Transmite
        aMVVer := {"MV_DOCIMP","MV_XMLCID","MV_XMLCSEC","MV_APITRAN","MV_XMLCAUT","MV_DTINITR","MV_TRAXML","MV_DOCREQ"}
    Elseif cOpc == "Avc" //Parâmetros para alterações na opção avançadas
        aMVVer := {"MV_DOCREQ","MV_XMLCAUT","MV_DTINITR"}
    Elseif cOpc == "Ger" //Geral
        aMVVer := {"MV_COMCOL1","MV_COMCOL2","MV_COMCOL3","MV_MSGCOL","MV_FILREP","MV_UFNFSF","MV_WIZSCHD"}
    Elseif cOpc == "Nfe"
        aMVVer := {"MV_XMLCFPC","MV_XMLCFBN","MV_XMLCFDV","MV_XMLCFND","MV_XMLCFNO"}
    Elseif cOpc == "Cte"
        aMVVer := {"MV_CTECLAS","MV_XMLPFCT","MV_XMLTECT","MV_XMLCPCT","MV_COLVCHV","MV_VLRCTE","MV_COLVDCS"}
    Elseif cOpc == "Wiz"
        aMVVer := {"MV_WIZCFG","MV_IMPXML","MV_TRAEXP","MV_DOCIMP","MV_COMCOL1","MV_XMLCID","MV_XMLCSEC","MV_APITRAN"}
    Elseif cOpc == "Arq" //Parâmetros para alterações na opção avançadas
        aMVVer := {"MV_NGINN","MV_NGLIDOS"}
    Endif

    dbSelectArea( "SX6" )
    SX6->( dbSetOrder( 1 ) )

    For nI := 1 To Len(aMVVer)
        cMsg += "Parâmetro: " + aMVVer[nI] + CRLF
        cDescMV := ""
        lParShow := FWSX6Util():ExistsParam(aMVVer[nI])
        If cOpc == "Imp"
            lStsParImp := Iif(!lParShow, .F., lStsParImp)
        Elseif cOpc == "Tra"
            lStsParInt := Iif(!lParShow, .F., lStsParInt)
        EndIf
        If lParShow
            If SX6->( MsSeek( FwxFilial("SX6") + aMVVer[nI] ) )
                cDescMV     := AllTrim(X6Descric()) + " " + AllTrim(X6Desc1()) + " " + AllTrim(X6Desc2())
                xConteudo	:= X6Conteud()

                cMsg += "[OK]............. " + STR0083 + CRLF + CRLF //"Parâmetro: OK"
                aAdd(aMVRet,{1,aMVVer[nI],cDescMV,xConteudo}) 
            Endif
        Else
            cMsg += "[ERROR].......... " + STR0084 + CRLF + CRLF //"Parâmetro: inexistente no ambiente"
            aAdd(aMVRet,{2,aMVVer[nI],cDescMV})
        Endif
    Next nI

    If cOpc == "Imp"
        cMsgMV1 := cMsg
    Elseif cOpc == "Tra"
        cMsgMV2 := cMsg
    Endif

    If cOpc == "Ger" .Or. cOpc == "Nfe" .Or. cOpc == "Cte" .Or. cOpc == "IxT" .Or. cOpc == "Avc"
        For nI := 1 To Len(aMVRet)
            aAdd(aAux,{aMVRet[nI,2],aMVRet[nI,4],aMVRet[nI,3]})
        Next nI

        If Len(aAux) > 0
            aMVRet := aAux
        Endif
    Endif

Return aMVRet

/*/{Protheus.doc} WizImpAtuMV
Wizard - Importador XML x Totvs Transmite
Refresh Parametros

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpAtuMV(oObj,nLinha,oObjG1,oObjG2,oObjM1)

    cMVPar  := oObj:aArray[nLinha,1]
    xMVCont := oObj:aArray[nLinha,2]
    cMVDesc := oObj:aArray[nLinha,3]

    oObjG1:Refresh()
    oObjG2:Refresh()
    oObjM1:Refresh()

Return

/*/{Protheus.doc} WizImpSaveMV
Wizard - Importador XML x Totvs Transmite
Atualizar parametros MV

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpSaveMV(aObj)

    Local nPos  := 0
    Local nI    := 0
    Local oObj  := Nil

    PutMV(cMVPar,xMVCont)

    For nI := 1 To Len(aObj)
        oObj := aObj[nI]

        nPos := aScan(oObj:aArray,{|x| AllTrim(x[1]) == AllTrim(cMVPar)})
        If nPos > 0
            oObj:aArray[nPos,2] := xMVCont
            oObj:Refresh()
        Endif
    Next nI

Return .T.

/*/{Protheus.doc} WizImpVldTra
Wizard - Importador XML x Totvs Transmite
Valida conexão com o Totvs Transmite

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpVldTra(cXMLCID,cXMLCSEC,cAPITRAN)

    Local oComTransmite := ComTransmite():New()
    Local lRet          := .F.
    Local cMsg          := ""

    oComTransmite:cMVXMLCID := AllTrim(cXMLCID)
    oComTransmite:cMVXMLCSEC := AllTrim(cXMLCSEC)
    oComTransmite:cMVAPITran := AllTrim(cAPITRAN)

    If oComTransmite:TokenTotvsTransmite()
        lRet := .T.
        cMsg := STR0085 //"Conexão Totvs Transmite: OK "

        WizImpTraIni(oComTransmite)
    Else
        cMsg := STR0086 + CRLF + STR0087 //"Conexão Totvs Transmite: Não OK "#" Verificar parametro MV_XMLCID/MV_XMLCSEC/MV_APITRAN"
    Endif

    If !lRet
        WizImpHlp(cMsg,"B")
    EndIf

    FreeObj(oComTransmite)

Return lRet

/*/{Protheus.doc} WizImpOpen
Wizard - Importador XML x Totvs Transmite
Abre link recomendado

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpOpen(cLink)

    ShellExecute("Open", cLink, "", "", 1)

Return

/*/{Protheus.doc} WizImpTraIni
Wizard - Importador XML x Totvs Transmite
Atualiza legado para não atualizar TOTVS Transmite

@author rodrigo.mpontes 
@since 21/10/2013
/*/
Static Function WizImpTraIni(oComTransmite)

    Local cQry      := ""
    Local cMVDocImp := ""
    Local cCodEdi   := ""
    Local aCodEdi   := {}
    Local nI        := 0

    If !Empty(oComTransmite:dDataIni)
        cMVDocImp := AllTrim(cDOCIMP)

        If "NFE" $ cMVDocImp
            aAdd(aCodEdi,"109")
        Endif

        If "NFS" $ cMVDocImp
            aAdd(aCodEdi,"319")
        Endif

        If "CTE" $ cMVDocImp
            aAdd(aCodEdi,"214")
        Endif

        If "CTO" $ cMVDocImp
            aAdd(aCodEdi,"273")
        Endif

        For nI := 1 To Len(aCodEdi)
            If Empty(cCodEdi)
                cCodEdi := "'" + aCodEdi[nI] + "'"
            Else
                cCodEdi += ",'" + aCodEdi[nI] + "'"
            Endif
        Next nI

        cQry := " UPDATE " + RetSqlName("CKO")
        cQry += " SET CKO_STRAN = '0'"
        cQry += " WHERE D_E_L_E_T_ = ' '"
        cQry += " AND CKO_CODEDI IN ( " + cCodEdi + " )"
        cQry += " AND CKO_DT_IMP < '" + DtoS(oComTransmite:dDataIni) + "'"

        TcSqlExec(cQry)
    Endif

Return

/*/{Protheus.doc} WizProcAut
Retorna CSS
@type      Function
@author    Leonardo Kichitaro
@since     17/01/2023
/*/
Static Function WizProcAut(lBtnCfg)

    Local cMsgAdd   := ""
    Local cMsgNAd   := ""
    Local cMsgDel   := ""
    Local nI        := 0
    Local nX        := 0
    Local nPos      := 0
    Local aMVVer    := {}
    Local aDados    := {}
    Local aAux      := {}
    Local xConteudo := Nil

    Default lBtnCfg := .F.

    lStsTabsEs  := .T.
    aTabelas    := WizImpTab()

    lStsPrgBin  := .T.
    aFontes     := WizImpPrw()

    lStsParImp  := .T.
    aMVImp      := WizImpMV("Imp")

    lStsParInt  := .T.
    If lBtImpXTra
        aMVTra  := WizImpMV("Tra")
    EndIf

    lStsSched := .T.
	aSchedule := WizImpSched()

    If lBtnCfg 
        If lStsParImp .And. lStsPrgBin .And. lStsTabsEs
            //Parâmetros Importador XML
            aAdd(aMVVer,{"MV_IMPXML"    , .T.})
            aAdd(aMVVer,{"MV_NGINN"     , "\importadorxml\in"})
            aAdd(aMVVer,{"MV_NGLIDOS"   , "\importadorxml\lidos"})
            aAdd(aMVVer,{"MV_TRAXML"    , "\transmite\"})
            aAdd(aMVVer,{"MV_COMCOL2"   , "NDCOTB"})
            aAdd(aMVVer,{"MV_COMCOL3"   , .T.})
            aAdd(aMVVer,{"MV_MSGCOL"    , 3})
            aAdd(aMVVer,{"MV_FILREP"    , .T.})
            aAdd(aMVVer,{"MV_XMLCFPC"   , ""})
            aAdd(aMVVer,{"MV_XMLCFBN"   , ""})
            aAdd(aMVVer,{"MV_XMLCFDV"   , ""})
            aAdd(aMVVer,{"MV_XMLCFND"   , ""})
            aAdd(aMVVer,{"MV_XMLCFNO"   , ""})
            aAdd(aMVVer,{"MV_CTECLAS"   , .F.})
            aAdd(aMVVer,{"MV_XMLPFCT"   , ""})
            aAdd(aMVVer,{"MV_XMLTECT"   , ""})
            aAdd(aMVVer,{"MV_XMLCPCT"   , ""})
            aAdd(aMVVer,{"MV_COLVCHV"   , .T.})
            aAdd(aMVVer,{"MV_VLRCTE"    , .F.})
            aAdd(aMVVer,{"MV_XMLDIAS"   , 30})
            aAdd(aMVVer,{"MV_XMLHIST"   , .F.})
            aAdd(aMVVer,{"MV_XMLCAUT"   , .F.})
            aAdd(aMVVer,{"MV_DTINITR"   , Date()})
            aAdd(aMVVer,{"MV_DOCREQ"    , 500})
            aAdd(aMVVer,{"MV_COLVDCS"   , .F.})
            aAdd(aMVVer,{"MV_UFNFSF"    , .F.})
            aAdd(aMVVer,{"MV_WIZSCHD"   , .F.})

            If !lBtImpXTra
                For nI := 1 To Len(aMVImp)
                    If (nPos := aScan(aMVVer,{|x| x[1] == AllTrim(aMVImp[nI][2])})) > 0
                        If FWSX6Util():ExistsParam(aMVVer[nPos][1])
                            If SX6->(MsSeek(FwxFilial("SX6") + aMVVer[nPos][1]))
                                xConteudo := X6Conteud()
                                If Empty(xConteudo)
                                    PutMV(aMVVer[nPos][1], aMVVer[nPos][2])
                                EndIf
                            Endif
                        Endif
                    EndIf
                Next nI
            Else
                For nI := 1 To Len(aMVVer)
                    If FWSX6Util():ExistsParam(aMVVer[nI][1])
                        If SX6->(MsSeek(FwxFilial("SX6") + aMVVer[nI][1]))
                            xConteudo := X6Conteud()

                            If Empty(xConteudo)
                                PutMV(aMVVer[nI][1], aMVVer[nI][2])
                            EndIf
                        Endif
                    Endif
                Next nI
            EndIf
        
        EndIf
        
        lMVSched := SuperGetMV('MV_WIZSCHD',.F.,.F.)

        If lMVSched .And. lStsSched .And. aSchedule[1,4]
            incSched()
        Endif

        If lBtImpXTra
            oBt8Pg1:Disable()
            oBt9Pg1:Disable()
        EndIf
    EndIf

    If lBtImpXTra
        aAllGroup := FwLoadSM0()

        For nI := 1 To Len(aAllGroup)
            nPos := aScan(aFilial,{|x| x[1] == aAllGroup[nI,1]} )
            If nPos == 0
                aAdd(aFilial,{aAllGroup[nI,1],aAllGroup[nI,2]})
            Else
                aFilial[nPos,2] += "|" + aAllGroup[nI,2] 
            Endif
        Next nI

        If !lWIZCFG
            aFilSel := WizImpGrp(aFilial,1)
            aAux    := aFilSel
            For nI := 1 To Len(aAux[1])
                If nI > 1
                    aAux := WizImpGrp(aFilial,nI)
                EndIf
                aDados  := aAux[2]

                For nX := 1 To Len(aDados)
                    If !aDados[nX,1]
                        aDados[nX,1] := WizImpTGrp(!aDados[nX,1],@aDados,nX,@cMsgAdd,@cMsgNAd,@cMsgDel,.F.)
                    EndIf
                Next nX
            Next
        EndIf

        lStsEmpFil := Empty(cMsgNAd)
    EndIf

    If lBtnCfg .And. lStsParImp .And. lStsPrgBin .And. lStsTabsEs
        lWIZCFG := .T.
        PutMV("MV_WIZCFG", .T.)
        PutMV("MV_IMPXML", .T.)
        If lBtImpXTra
            PutMV("MV_TRAEXP", .T.)
            lMVTraExp := .T.
            lExecImp := .F.
        ElseIf !lBtImpXTra
            lExecImp := .T.
        EndIf
    EndIf

Return

/*/{Protheus.doc} getCSSWiz
Retorna CSS
@type      Function
@author    Leonardo Kichitaro
@since     17/01/2023
/*/
Static Function WizTelaCfg(oPanel)

    Local cSepara       := " - "
    Local cOK           := STR0019 //"OK"
    Local cNOK          := STR0113 //"FALHA"
    Local cEmpOK        := STR0114 //"TODAS CONFIGURADAS"
    Local cEmpNOK       := STR0115 //"PARCIALMENTE CONFIGURADAS"
    Local cEmpATE       := STR0160 //"ATENÇÃO"

    Local cStsTransm    := ""
    Local cStsTabsEs    := ""
    Local cStsPrgBin    := ""
    Local cStsParImp    := ""
    Local cStsParInt    := ""
    Local cStsEmpFil    := ""
    Local cStsSched     := ""

    cStsTransm  := Upper(STR0116) + cSepara + Iif(lStsTransm,cOK,cNOK)          //"STATUS TRANSMITE"
    cStsTabsEs  := Upper(STR0117) + cSepara + Iif(lStsTabsEs,cOK,cNOK)          //"TABELAS E ESTRUTURAS"
    cStsPrgBin  := Upper(STR0118) + cSepara + Iif(lStsPrgBin,cOK,cNOK)          //"PROGRAMAS E BINÁRIO"
    cStsParImp  := Upper(STR0119) + cSepara + Iif(lStsParImp,cOK,cNOK)          //"PARÂMETROS IMPORTADOR XML"
    cStsParInt  := Upper(STR0120) + cSepara + Iif(lStsParInt,cOK,cNOK)          //"PARÂMETROS INTEGRAÇÃO TOTVS TRANSMITE"
    cStsEmpFil  := Upper(STR0121) + cSepara + Iif(lStsEmpFil,cEmpOK,cEmpNOK)    //"EMPRESAS E FILIAIS"
    cStsSched   := Upper(STR0152) + cSepara + Iif(lStsSched,cOK,cEmpATE)        //"AGENDAMENTOS SCHEDULE"

    oBt1Pg3:Disable()
    oBt1Pg3:Hide()

    If !lBtCfgAvc
        If lBtImpXTra
            oG1Pg3 := TGet():New(035,055,{|u|If(PCount()==0,cStsTransm,cStsTransm := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsTransm",,,,)
            oG1Pg3:SetContentAlign(0)
            oG1Pg3:Disable()
            oG2Pg3 := TGet():New(055,055,{|u|If(PCount()==0,cStsTabsEs,cStsTabsEs := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsTabsEs",,,,)
            oG2Pg3:SetContentAlign(0)
            oG2Pg3:Disable()
            oG3Pg3 := TGet():New(075,055,{|u|If(PCount()==0,cStsPrgBin,cStsPrgBin := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsPrgBin",,,,)
            oG3Pg3:SetContentAlign(0)
            oG3Pg3:Disable()
            oG4Pg3 := TGet():New(095,055,{|u|If(PCount()==0,cStsParImp,cStsParImp := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsParImp",,,,)
            oG4Pg3:SetContentAlign(0)
            oG4Pg3:Disable()
            oG5Pg3 := TGet():New(115,055,{|u|If(PCount()==0,cStsParInt,cStsParInt := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsParInt",,,,)
            oG5Pg3:SetContentAlign(0)
            oG5Pg3:Disable()
            oG6Pg3 := TGet():New(135,055,{|u|If(PCount()==0,cStsEmpFil,cStsEmpFil := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsEmpFil",,,,)
            oG6Pg3:SetContentAlign(0)
            oG6Pg3:Disable()

            if lMVSched
                oG7Pg3 := TGet():New(155,055,{|u|If(PCount()==0,cStsSched,cStsSched := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsSched",,,,)
                oG7Pg3:SetContentAlign(0)
                oG7Pg3:Disable()
            endif

            oBtn2Sts := TButton():New(057,445,STR0122,oPanel,{||WizDetCfg(2)},55,15,,,,.T.) //"DETALHES"
            // oBtn2Sts:SetCSS(getCSS(2))

            oBtn3Sts := TButton():New(077,445,STR0122,oPanel,{||WizDetCfg(3)},55,15,,,,.T.) //"DETALHES"
            // oBtn3Sts:SetCSS(getCSS(2))

            oBtn4Sts := TButton():New(097,445,STR0122,oPanel,{||WizDetCfg(4)},55,15,,,,.T.) //"DETALHES"
            // oBtn4Sts:SetCSS(getCSS(2))

            oBtn5Sts := TButton():New(117,445,STR0122,oPanel,{||WizDetCfg(5)},55,15,,,,.T.) //"DETALHES"
            // oBtn5Sts:SetCSS(getCSS(2))
            
            oBtn6Sts := TButton():New(137,445,STR0122,oPanel,{||WizDetCfg(6)},55,15,,,,.T.) //"DETALHES"
            // oBtn6Sts:SetCSS(getCSS(2))
            
            if !(lStsSched) .And. lMVSched
                oBtn7Sts := TButton():New(157,445,STR0122,oPanel,{||WizDetCfg(7)},55,15,,,,.T.) //"DETALHES"
            endif
            
            if lStsTabsEs .And. lStsPrgBin .And. lStsParImp
                oS3Pg3:Enable()
                oS3Pg3:Show()
            endif

            oBt1Pg3:Refresh()
            oPanel:Refresh()
        Else
            oG2Pg3 := TGet():New(035,055,{|u|If(PCount()==0,cStsTabsEs,cStsTabsEs := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsTabsEs",,,,)
            oG2Pg3:SetContentAlign(0)
            oG2Pg3:Disable()
            oG3Pg3 := TGet():New(055,055,{|u|If(PCount()==0,cStsPrgBin,cStsPrgBin := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsPrgBin",,,,)
            oG3Pg3:SetContentAlign(0)
            oG3Pg3:Disable()
            oG4Pg3 := TGet():New(075,055,{|u|If(PCount()==0,cStsParImp,cStsParImp := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsParImp",,,,)
            oG4Pg3:SetContentAlign(0)
            oG4Pg3:Disable()

            if lMVSched
                oG7Pg3 := TGet():New(095,055,{|u|If(PCount()==0,cStsSched,cStsSched := u)},oPanel,450,18,,,,,oTFont1,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cStsSched",,,,)
                oG7Pg3:SetContentAlign(0)
                oG7Pg3:Disable()
            endif

            oBtn2Sts := TButton():New(037,445,STR0122,oPanel,{||WizDetCfg(2)},55,15,,,,.T.) //"DETALHES"
            // oBtn2Sts:SetCSS(getCSS(2))

            oBtn3Sts := TButton():New(057,445,STR0122,oPanel,{||WizDetCfg(3)},55,15,,,,.T.) //"DETALHES"
            // oBtn3Sts:SetCSS(getCSS(2))

            oBtn4Sts := TButton():New(077,445,STR0122,oPanel,{||WizDetCfg(4)},55,15,,,,.T.) //"DETALHES"
            // oBtn4Sts:SetCSS(getCSS(2))
               
            if !(lStsSched) .And. lMVSched
                oBtn7Sts := TButton():New(097,445,STR0122,oPanel,{||WizDetCfg(7)},55,15,,,,.T.) //"DETALHES"
            endif
            
            if lStsTabsEs .And. lStsPrgBin .And.  lStsParImp
                oS3Pg3:Enable()
                oS3Pg3:Show()
            endif
            
            oBt1Pg3:Refresh()
            oPanel:Refresh()
        EndIf
    Else
        If lBtImpXTra
            oG1Pg3:Show()

            oG2Pg3:Show()
            oBtn2Sts:Enable()
            oBtn2Sts:Show()

            oG3Pg3:Show()
            oBtn3Sts:Enable()
            oBtn3Sts:Show()

            oG4Pg3:Show()
            oBtn4Sts:Enable()
            oBtn4Sts:Show()

            oG5Pg3:Show()
            oBtn5Sts:Enable()
            oBtn5Sts:Show()

            oG6Pg3:Show()
            oBtn6Sts:Enable()
            oBtn6Sts:Show()

            if lMVSched
                oG7Pg3:Show()
                if !(lStsSched)
                    oBtn7Sts:Enable()
                    oBtn7Sts:Show()
                endif
            endif

            oS3Pg3:Enable()
            oS3Pg3:Show()
        Else
            oG2Pg3:Show()
            oBtn2Sts:Enable()
            oBtn2Sts:Show()

            oG3Pg3:Show()
            oBtn3Sts:Enable()
            oBtn3Sts:Show()

            oG4Pg3:Show()
            oBtn4Sts:Enable()
            oBtn4Sts:Show()

            if lMVSched
                oG7Pg3:Show()
                if !(lStsSched)
                    oBtn7Sts:Enable()
                    oBtn7Sts:Show()
                endif
            endif

            oS3Pg3:Enable()
            oS3Pg3:Show()
            
        EndIf
    EndIf

Return

/*/{Protheus.doc} WizDetCfg
Tela com detalhes da configuração automatica
@type      Function
@author    Leonardo Kichitaro
@since     17/01/2023
/*/
Static Function WizDetCfg(nOpcDet)

    Local oDetCfg   := Nil
    Local oFWLayer  := Nil
    Local oPanDet   := Nil
    Local oBtnDet   := Nil
    Local aAux      := {}
    Local aGrp      := {}
    Local aFilGrp   := {}
    Local aHdTab    := {}
    Local aTamTab   := {}
    Local cDscTel   := ""
    Local cDesc1    := ""

    If nOpcDet == 2
        cDscTel := Upper(STR0117) //"TABELAS E ESTRUTURAS"
        aHdTab  := {STR0019,STR0020,STR0021} //"Ok"#"Tabela"#"Descrição"
        aTamTab := {1,10,200}
        cDesc1  := STR0117 + ":" + CRLF + CRLF + STR0123 //"Tabelas e Estrutura"#"Detalhes da validação de tabelas e campos do Importador XML e da integração com o TOTVS Transmite"
    ElseIf nOpcDet == 3
        cDscTel := Upper(STR0118) //"PROGRAMAS E BINÁRIO"
        aHdTab  := {STR0019,STR0005,STR0024,STR0025,STR0026} //"Ok"#"Programas/Binário"#"Responsavel"#"Data OK"#"Data Ambiente"
        aTamTab := {1,80,40,60,60}
        cDesc1  := STR0118 + ":" + CRLF + CRLF + STR0124 //"Programas e Binário:"#"Detalhes da validação de binário e programas do Importador XML e da integração com o TOTVS Transmite"
    ElseIf nOpcDet == 4
        cDscTel := Upper(STR0119) //"PARÂMETROS IMPORTADOR XML"
        aHdTab  := {STR0019,STR0028,STR0021} //"Ok"#"Parâmetro"#"Descrição"
        aTamTab := {1,60,100}
        cDesc1  := STR0119 + ":" + CRLF + CRLF + STR0125 //"Parâmetros Importador XML"#"Detalhes da validação dos parâmetros do Importador XML"
    ElseIf nOpcDet == 5
        cDscTel := Upper(STR0120) //"PARÂMETROS INTEGRAÇÃO TOTVS TRANSMITE"
        aHdTab  := {STR0019,STR0028,STR0021} //"Ok"#"Parâmetro"#"Descrição"
        aTamTab := {1,60,100}
        cDesc1  := STR0120 + ":" + CRLF + CRLF + STR0126 //"Parâmetros Integração TOTVS Transmite"#"Detalhes da validação dos parâmetros da integração do Importador XML com Totvs Transmite"
    ElseIf nOpcDet == 6
        cDscTel := Upper(STR0121) //"EMPRESAS E FILIAIS"
        aAux    := WizImpGrp(aFilial,1)
    ElseIf nOpcDet == 7
        cDscTel := Upper("STATUS DO SMART SCHEDULE PROTHEUS") //"STATUS DO SMART SCHEDULE PROTHEUS"
		aHdTab  := {"Ok","Rotina","Descrição da Rotina"}
		aTamTab := {1,60,100}
    EndIf

    DEFINE DIALOG oDetCfg TITLE cDscTel PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)

        oDetCfg:nWidth := 1150
        oDetCfg:nHeight := 620

        //------------------------------------------
        // Divide a tela e organiza os layers a serem apresentados
        oFWLayer := FWLayer():New()
        oFWLayer:Init(oDetCfg,.F.,.T.)

        oFWLayer:AddLine("SUP1",095,.F.)
        oFWLayer:AddColumn("FIL1",100,.T.,"SUP1")

        oFWLayer:AddWindow("FIL1","oPanDet",cDscTel,100,.F.,.T.,,"SUP1",{|| })
        oPanDet := oFWLayer:GetWinPanel("FIL1","oPanDet","SUP1")

        If nOpcDet == 2
            oS1Dt2 := TSay():New(10,05,{|| cDesc1 },oPanDet,,oTFont,,,,.T.,,,600,100)

            oBrw1Pg2 := TWBrowse():New(50,05,298,190,,aHdTab,aTamTab,oPanDet,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oBrw1Pg2:SetArray(aTabelas)
            oBrw1Pg2:bLine	:= { || {   Iif(aTabelas[oBrw1Pg2:nAt,1]==1,oOK,Iif(aTabelas[oBrw1Pg2:nAt,1]==2,oNO,oYE)),;
                                        aTabelas[oBrw1Pg2:nAt,2],;
                                        aTabelas[oBrw1Pg2:nAt,3]}}

            oMGetPg2 := tMultiget():new( 50, 310, {| u | if( pCount() > 0, cMsgTab := u, cMsgTab ) },oPanDet, 245, 190, , , , , , .T. )
        ElseIf nOpcDet == 3
            oS1Dt3 := TSay():New(10,05,{|| cDesc1 },oPanDet,,oTFont,,,,.T.,,,600,100)

            oBrw1Pg3 	:= TWBrowse():New(50,05,298,190,,aHdTab,aTamTab,oPanDet,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oBrw1Pg3:SetArray(aFontes)
            oBrw1Pg3:bLine	:= { || {   Iif(aFontes[oBrw1Pg3:nAt,1]==1,oOK,Iif(aFontes[oBrw1Pg3:nAt,1]==2,oNO,oYE)),;
                                        aFontes[oBrw1Pg3:nAt,2],;
                                        aFontes[oBrw1Pg3:nAt,3],;
                                        aFontes[oBrw1Pg3:nAt,4],;
                                        aFontes[oBrw1Pg3:nAt,5]}}

            oMGetPg3 := tMultiget():new( 50, 310, {| u | if( pCount() > 0, cMsgPrw := u, cMsgPrw ) },oPanDet, 245, 190, , , , , , .T. )
        ElseIf nOpcDet == 4
            oS1Dt4 := TSay():New(10,10,{|| cDesc1 },oPanDet,,oTFont,,,,.T.,,,600,100)

            oBrw1Pg4 	:= TWBrowse():New(50,05,298,190,,aHdTab,aTamTab,oPanDet,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oBrw1Pg4:SetArray(aMVImp)
            oBrw1Pg4:bLine	:= { || {   Iif(aMVImp[oBrw1Pg4:nAt,1]==1,oOK,Iif(aMVImp[oBrw1Pg4:nAt,1]==2,oNO,oYE)),;
                                        aMVImp[oBrw1Pg4:nAt,2],;
                                        aMVImp[oBrw1Pg4:nAt,3]}}

            oMGetPg4 := tMultiget():new( 50, 310, {| u | if( pCount() > 0, cMsgMV1 := u, cMsgMV1 ) },oPanDet, 245, 190, , , , , , .T. )
        ElseIf nOpcDet == 5
            oS1Dt5 := TSay():New(10,05,{|| cDesc1 },oPanDet,,oTFont,,,,.T.,,,600,100)

            oBrw1Pg5 	:= TWBrowse():New(50,05,298,190,,aHdTab,aTamTab,oPanDet,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oBrw1Pg5:SetArray(aMVTra)
            oBrw1Pg5:bLine	:= { || {   Iif(aMVTra[oBrw1Pg5:nAt,1]==1,oOK,Iif(aMVTra[oBrw1Pg5:nAt,1]==2,oNO,oYE)),;
                                        aMVTra[oBrw1Pg5:nAt,2],;
                                        aMVTra[oBrw1Pg5:nAt,3]}}

            oMGetPg5 := tMultiget():new( 50, 310, {| u | if( pCount() > 0, cMsgMV2 := u, cMsgMV2 ) },oPanDet, 245, 190, , , , , , .T. )
        ElseIf nOpcDet == 6
            aGrp    := aAux[1]
            aFilGrp := aAux[2] 

            oS1Dt9 := TSay():New(10,05,{|| STR0088},oPanDet,,oTFont,,,,.T.,,,180,150) //"Selecione a(s) filial(ais) que serão conectadas e/ou desconectadas ao Totvs Transmite"

            //Grupo Empresa
            oBrw1Pg9 := TWBrowse():New(40,05,190,200,,{STR0045},{05,20},oPanDet,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Grupo Empresa"
            oBrw1Pg9:SetArray(aGrp)
            oBrw1Pg9:bLine	:= { || {  aGrp[oBrw1Pg9:nAt]}}
            oBrw1Pg9:bChange    := {|| oBrw2Pg9:nAt := 1, WizImpAGrp(oBrw1Pg9:nAt,aFilial,oBrw2Pg9,@aFilGrp)}

            //Grupo Empresa - Filiais
            oBrw2Pg9 := TWBrowse():New(10,205,350,230,,{"",STR0127,STR0047,STR0048},{50,50,50,100},oPanDet,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Empresa"#"Filial"#"Desc Filial"
            oBrw2Pg9:SetArray(aFilGrp) 
            oBrw2Pg9:bLine	:= { || {   Iif(aFilGrp[oBrw2Pg9:nAt,1],oOK,oNO),;
                                        aFilGrp[oBrw2Pg9:nAt,2],;
                                        aFilGrp[oBrw2Pg9:nAt,3],;
                                        aFilGrp[oBrw2Pg9:nAt,4]}}
            oBrw2Pg9:bLDblClick := {|| WizImpCGrp(oBrw2Pg9,@aFilGrp)}
            oBrw2Pg9:bHeaderClick := {|| Processa({|| WizImpCGrp(oBrw2Pg9,@aFilGrp,"A") }, STR0049) } //"Processando"
        ElseIf nOpcDet == 7
            oS1Dt7 := TSay():New(10,005,{|| "Status do SmartSchedule:"},oPanDet,,oTFont,,,,.T.,,,180,150)
			
			if totvs.framework.smartschedule.startSchedule.smartSchedIsRunning()
				oBmpDt7 := TBitmap():New(008, 110, 260, 184, "NGBIOALERTA_02", NIL, .T., oPanDet, {|| .T. }, NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
				
				oS1Dt8 := TSay():New(10,125,{|| "Em Execução"},oPanDet,,oTFont,,,,.T.,,,180,150)
			else
				oBmpDt7 := TBitmap():New(008, 110, 260, 184, "NGBIOALERTA_03", NIL, .T., oPanDet, {|| .T. }, NIL, .F., .F., NIL, NIL, .F., NIL, .T., NIL, .F.)
				
				oS1Dt8 := TSay():New(10,125,{|| "Parado"},oPanDet,,oTFont,,,,.T.,,,180,150)
			endif
            
            oBrw1Pg7 := TWBrowse():New(50,05,298,190,,aHdTab,aTamTab,oPanDet,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oBrw1Pg7:SetArray(aSchedule)
            oBrw1Pg7:bLine	:= { || {   if(aSchedule[oBrw1Pg7:nAt,1],oOK,oNO),;
                                        aSchedule[oBrw1Pg7:nAt,2],;
                                        aSchedule[oBrw1Pg7:nAt,3]}}
            oMGetPg7 := tMultiget():new( 50, 310, {| u | if( pCount() > 0, cMsgSch := u, cMsgSch ) },oPanDet, 245, 190, , , , , , .T. )
        EndIf

        oBtnDet := TButton():New(289,270,STR0019,oDetCfg,{||oDetCfg:End()},45,15,,,,.T.) //"OK"
        oBtnDet:SetCSS(getCSS(2))

        If nOpcDet == 6
            oBrw2Pg9:nAt := 1
            oBrw2Pg9:SetFocus()
        EndIf

    ACTIVATE DIALOG oDetCfg CENTER

Return

/*/{Protheus.doc} WizCfgAvc
Opções de configurações avançadas
@type      Function
@author    Leonardo Kichitaro
@since     17/01/2023
/*/
Static Function WizCfgAvc(oPanel)

    If lBtImpXTra
        oG1Pg3:Hide()
        oG2Pg3:Hide()
        oG3Pg3:Hide()
        oG4Pg3:Hide()
        oG5Pg3:Hide()
        oG6Pg3:Hide()

        oBtn2Sts:Disable()
        oBtn2Sts:Hide()
        oBtn3Sts:Disable()
        oBtn3Sts:Hide()
        oBtn4Sts:Disable()
        oBtn4Sts:Hide()
        oBtn5Sts:Disable()
        oBtn5Sts:Hide()
        oBtn6Sts:Disable()
        oBtn6Sts:Hide()
        if lMVSched
            oG7Pg3:Hide()
            if !(lStsSched)
                oBtn7Sts:Disable()
                oBtn7Sts:Hide()
            endif
        endif
    Else
        oG2Pg3:Hide()
        oG3Pg3:Hide()
        oG4Pg3:Hide()

        oBtn2Sts:Disable()
        oBtn2Sts:Hide()
        oBtn3Sts:Disable()
        oBtn3Sts:Hide()
        oBtn4Sts:Disable()
        oBtn4Sts:Hide()
        if lMVSched
            oG7Pg3:Hide()
            if !(lStsSched)
                oBtn7Sts:Disable()
                oBtn7Sts:Hide()
            endif
        endif
    EndIf

    oS3Pg3:Disable()
    oS3Pg3:Hide()

    oS1Pg3:cCaption := STR0128 //"CONFIGURAÇÕES AVANÇADAS"

    If !lBtCfgAvc
        If lBtImpXTra
            oBt2Pg3	:= tButton():New(060,070,STR0129 + CRLF + STR0130,oPanel,{|| WizAltCfg(1)},100,60,,,.F.,.T.,.F.,,.F.,,,.F.) //"CAMINHO DOS"#"ARQUIVOS XML"
            oBt2Pg3:SetCSS(getCSS(2))

            oBt3Pg3	:= tButton():New(060,180,STR0131 + CRLF + STR0132,oPanel,{|| WizAltCfg(2)},100,60,,,.F.,.T.,.F.,,.F.,,,.F.) //"PARÂMETROS"#"IMPORTADOR XML"
            oBt3Pg3:SetCSS(getCSS(2))

            oBt4Pg3	:= tButton():New(060,290,STR0131 + CRLF + STR0133,oPanel,{|| WizAltCfg(3)},100,60,,,.F.,.T.,.F.,,.F.,,,.F.) //"PARÂMETROS"#"INTEGRAÇÃO TRANSMITE"
            oBt4Pg3:SetCSS(getCSS(2))

            oBt5Pg3	:= tButton():New(060,400,Upper(STR0121),oPanel,{|| WizDetCfg(6)},100,60,,,.F.,.T.,.F.,,.F.,,,.F.)           //"EMPRESAS E FILIAIS"
            oBt5Pg3:SetCSS(getCSS(2))

            oBt2Pg3:Show()
            oBt2Pg3:Enable()
            oBt3Pg3:Show()
            oBt3Pg3:Enable()
            oBt4Pg3:Show()
            oBt4Pg3:Enable()
            oBt5Pg3:Show()
            oBt5Pg3:Enable()
        Else
            oBt2Pg3	:= tButton():New(060,180,STR0129 + CRLF + STR0130,oPanel,{|| WizAltCfg(1)},100,60,,,.F.,.T.,.F.,,.F.,,,.F.) //"CAMINHO DOS"#"ARQUIVOS XML"
            oBt2Pg3:SetCSS(getCSS(2))

            oBt3Pg3	:= tButton():New(060,290,STR0131 + CRLF + STR0132,oPanel,{|| WizAltCfg(2)},100,60,,,.F.,.T.,.F.,,.F.,,,.F.) //"PARÂMETROS"#"IMPORTADOR XML"
            oBt3Pg3:SetCSS(getCSS(2))

            oBt2Pg3:Show()
            oBt2Pg3:Enable()
            oBt3Pg3:Show()
            oBt3Pg3:Enable()
        EndIf
    Else
        If lBtImpXTra
            oBt2Pg3:Show()
            oBt2Pg3:Enable()
            oBt3Pg3:Show()
            oBt3Pg3:Enable()
            oBt4Pg3:Show()
            oBt4Pg3:Enable()
            oBt5Pg3:Show()
            oBt5Pg3:Enable()
        Else
            oBt2Pg3:Show()
            oBt2Pg3:Enable()
            oBt3Pg3:Show()
            oBt3Pg3:Enable()
        EndIf
    EndIf

    oPanel:Refresh()

Return

/*/{Protheus.doc} getCSSWiz
Retorna CSS
@type      Function
@author    Leonardo Kichitaro
@since     17/01/2023
/*/
Static Function WizAltCfg(nOpcCfg)

    Local oTelCfg   := Nil
    Local oFWLayer  := Nil
    Local oPanCfg   := Nil

    Local oSayCfg   := Nil

    Local oSayMV1   := Nil
    Local oSayMV2   := Nil
    Local oGetMV1   := Nil
    Local oGetMV2   := Nil

    Local oBtnCfg1  := Nil
    Local oBtnCfg2  := Nil

    Local cDescDlg  := ""
    Local cDesc1    := ""
    Local cMVNGIN   := ""
    Local cMVNGLI   := ""

    Local aHdTab    := {}
    Local aTamTab   := {}

    Local aMVArq    := {}
    Local aMVGer    := {}
    Local aMVNfe    := {}
    Local aMVCte    := {}
    Local aMVIxT    := {}

    Local lConfAlt  := .F.

    If nOpcCfg == 1
        aMVArq := WizImpMV("Arq")

        cDescDlg := STR0129 + " " + STR0130 //"CAMINHO DOS ARQUIVOS XML"

        cMVNGIN	:= Iif(aMVArq[1][1] == 1, aMVArq[1][4], Space(150))
        cMVNGIN := Iif(!Empty(cMVNGIN), Padr(cMVNGIN,150), Space(150))
        cMVNGLI	:= Iif(aMVArq[2][1] == 1, aMVArq[2][4], Space(150))
        cMVNGLI := Iif(!Empty(cMVNGLI), Padr(cMVNGLI,150), Space(150))

        cDesc1 := STR0134 + CRLF + CRLF +;  //"Caminho dos arquivos XML:"
                  STR0135 + CRLF +;         //"Definir o caminho(diretório) de onde os XMLs serão lidos e importados."
                  STR0136                   //"Observação: Diretório deve estar dentro do PROTHEUS_DATA"

    ElseIf nOpcCfg == 2
        cDescDlg    := Upper(STR0119) //"PARÂMETROS IMPORTADOR XML"
        aHdTab      := {STR0028,STR0034,STR0021} //"Parâmetro"#"Conteudo"#"Descrição"
        aTamTab     := {40,20,100}

        aMVGer      := WizImpMV("Ger")
        aMVNfe      := WizImpMV("Nfe")
        aMVCte      := WizImpMV("Cte") 
    ElseIf nOpcCfg == 3
        cDescDlg    := Upper(STR0120) //"PARÂMETROS INTEGRAÇÃO TOTVS TRANSMITE"
        aHdTab      := {STR0028,STR0034,STR0021}  //"Parametro"#"Conteudo"#"Descrição"
        aTamTab     := {40,20,100}

        aMVIxT      := WizImpMV("Avc")
    EndIf

    DEFINE DIALOG oTelCfg TITLE cDescDlg PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)

        oTelCfg:nWidth := 1150
        oTelCfg:nHeight := 620

        //------------------------------------------
        // Divide a tela e organiza os layers a serem apresentados
        oFWLayer := FWLayer():New()
        oFWLayer:Init(oTelCfg,.F.,.T.)

        oFWLayer:AddLine("SUP1",095,.F.)
        oFWLayer:AddColumn("FIL1",100,.T.,"SUP1")

        oFWLayer:AddWindow("FIL1","oPanCfg",cDescDlg,100,.F.,.T.,,"SUP1",{|| })
        oPanCfg := oFWLayer:GetWinPanel("FIL1","oPanCfg","SUP1")

        If nOpcCfg == 1
            oSayCfg := TSay():New(10,05,{|| cDesc1 },oPanCfg,,oTFont2,,,,.T.,,,600,100)

            oSayMV1 := TSay():New(80,05,{|| STR0137 },oPanCfg,,oTFont3,,,,.T.,,,110,20) //"Pasta de Entrada:"
            oGetMV1 := TGet():New(73,110,{|u|If(PCount()==0,cMVNGIN,cMVNGIN := u ) },oPanCfg,440,20,,,,,oTFont2,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cMVNGIN",,,,)

            oSayMV2 := TSay():New(110,05,{|| STR0138 },oPanCfg,,oTFont3,,,,.T.,,,110,20) //"Pasta de Histórico:"
            oGetMV2 := TGet():New(103,110,{|u|If(PCount()==0,cMVNGLI,cMVNGLI := u ) },oPanCfg,440,20,,,,,oTFont2,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cMVNGLI",,,,)
        ElseIf nOpcCfg == 2
            //Geral
            oGrp1Pg7 := TGroup():New(05,05,130,185,STR0035,oPanCfg,,,.T.) //'Geral'
            oBrw1Pg7 := TWBrowse():New(15,10,170,110,,aHdTab,aTamTab,oGrp1Pg7,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oBrw1Pg7:SetArray(aMVGer)
            oBrw1Pg7:bLine	:= { || {   aMVGer[oBrw1Pg7:nAt,1],;
                                        aMVGer[oBrw1Pg7:nAt,2],;
                                        aMVGer[oBrw1Pg7:nAt,3]}}  
            oBrw1Pg7:bChange := {|| WizImpAtuMV(oBrw1Pg7,oBrw1Pg7:nAt,oG1Pg7,oG2Pg7,oMGetPg7)}

            //NFe
            oGrp2Pg7 := TGroup():New(05,190,130,375,STR0036,oPanCfg,,,.T.) //'NFe'
            oBrw2Pg7 := TWBrowse():New(15,197,175,110,,aHdTab,aTamTab,oGrp2Pg7,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oBrw2Pg7:SetArray(aMVNFe)
            oBrw2Pg7:bLine	:= { || {   aMVNFe[oBrw2Pg7:nAt,1],;
                                        aMVNFe[oBrw2Pg7:nAt,2],;
                                        aMVNFe[oBrw2Pg7:nAt,3]}}
            oBrw2Pg7:bChange := {|| WizImpAtuMV(oBrw2Pg7,oBrw2Pg7:nAt,oG1Pg7,oG2Pg7,oMGetPg7)}

            //CTe
            oGrp3Pg7 := TGroup():New(05,380,130,562,STR0037,oPanCfg,,,.T.) //'CTe'
            oBrw3Pg7 := TWBrowse():New(15,385,175,110,,aHdTab,aTamTab,oGrp3Pg7,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oBrw3Pg7:SetArray(aMVCte)
            oBrw3Pg7:bLine	:= { || {   aMVCte[oBrw3Pg7:nAt,1],;
                                        aMVCte[oBrw3Pg7:nAt,2],;
                                        aMVCte[oBrw3Pg7:nAt,3]}} 
            oBrw3Pg7:bChange := {|| WizImpAtuMV(oBrw3Pg7,oBrw3Pg7:nAt,oG1Pg7,oG2Pg7,oMGetPg7)}

            oS2Pg7 := TSay():New(160,005,{|| STR0038 },oPanCfg,,oTFont,,,,.T.,,,80,20) //"Parâmetro: "
            oG1Pg7 := TGet():New(153,065,{|u|If(PCount()==0,cMVPar,cMVPar := u ) },oPanCfg,100,20,"@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cMVPar",,,,)
            oG1Pg7:bWhen := {|| .F.}

            oS3Pg7 := TSay():New(190,005,{|| STR0039 },oPanCfg,,oTFont,,,,.T.,,,80,20) //"Conteudo: "
            oG2Pg7 := TGet():New(183,065,{|u|If(PCount()==0,xMVCont,xMVCont := u ) },oPanCfg,100,20,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"xMVCont",,,,)

            oS4Pg7 := TSay():New(155,185,{|| STR0022 },oPanCfg,,oTFont,,,,.T.,,,80,20) //"Descrição: "
            oMGetPg7 := tMultiget():new(153, 240, {| u | if( pCount() > 0, cMVDesc := u, cMVDesc ) },oPanCfg, 320, 085, , , , , , .T. )

            oBtPg7 := TBrowseButton():New( 185,180,STR0040,oPanCfg, {|| WizImpSaveMV({oBrw1Pg7,oBrw2Pg7,oBrw3Pg7})},40,20,,,.F.,.T.,.F.,,.F.,,,) //'Salvar'
            oBtPg7:SetCSS(getCSS(1))
        ElseIf nOpcCfg == 3
            //Totvs Transmite
            oGrp1Pg8 := TGroup():New(05,05,190,280,STR0041,oPanCfg,,,.T.) //'Integração Importador XML x Totvs Transmite'
            oBrw1Pg8 := TWBrowse():New(15,10,265,170,,aHdTab,aTamTab,oGrp1Pg8,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
            oBrw1Pg8:SetArray(aMVIxT)
            oBrw1Pg8:bLine	:= { || {   aMVIxT[oBrw1Pg8:nAt,1],;
                                        aMVIxT[oBrw1Pg8:nAt,2],;
                                        aMVIxT[oBrw1Pg8:nAt,3]}}
            oBrw1Pg8:bChange := {|| WizImpAtuMV(oBrw1Pg8,oBrw1Pg8:nAt,oG1Pg8,oG2Pg8,oMGetPg8)}

            oS2Pg8 := TSay():New(15,310,{|| STR0038 },oPanCfg,,oTFont,,,,.T.,,,80,20) //"Parametro: "
            oG1Pg8 := TGet():New(08,375,{|u|If(PCount()==0,cMVPar,cMVPar := u ) },oPanCfg,150,20,"@!",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cMVPar",,,,)
            oG1Pg8:bWhen := {|| .F.}

            oS3Pg8 := TSay():New(45,310,{|| STR0039 },oPanCfg,,oTFont,,,,.T.,,,80,20) //"Conteudo: "
            oG2Pg8 := TGet():New(38,375,{|u|If(PCount()==0,xMVCont,xMVCont := u ) },oPanCfg,150,20,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"xMVCont",,,,)

            oS4Pg8 := TSay():New(70,310,{|| STR0022 },oPanCfg,,oTFont,,,,.T.,,,80,20) //"Descrição: "
            oMGetPg8 := tMultiget():new(68, 375, {| u | if( pCount() > 0, cMVDesc := u, cMVDesc ) },oPanCfg, 150, 70, , , , , , .T. )

            oBt1Pg8 := TBrowseButton():New( 115,310,STR0040,oPanCfg, {|| WizImpSaveMV({oBrw1Pg8})},40,20,,,.F.,.T.,.F.,,.F.,,,) //'Salvar'
            oBt1Pg8:SetCSS(getCSS(1))
        EndIf

        If nOpcCfg == 1
            oBtnCfg1 := TButton():New(289,470,STR0139,oTelCfg,{||lConfAlt := .F., oTelCfg:End()},45,15,,,,.T.) //"Cancelar"
            oBtnCfg1:SetCSS(getCSS(2))
        EndIf

        oBtnCfg2 := TButton():New(289,520,STR0140,oTelCfg,{||lConfAlt := .T., oTelCfg:End()},45,15,,,,.T.) //"Confirmar"
        oBtnCfg2:SetCSS(getCSS(1))

    ACTIVATE DIALOG oTelCfg CENTER

    If lConfAlt
        If nOpcCfg == 1
            PutMV("MV_NGINN", cMVNGIN)
            PutMV("MV_NGLIDOS", cMVNGLI)
        EndIf
    EndIf

    FwFreeArray(aHdTab)
    FwFreeArray(aTamTab)
    FwFreeArray(aMVArq)
    FwFreeArray(aMVGer)
    FwFreeArray(aMVNfe)
    FwFreeArray(aMVCte)
    FwFreeArray(aMVIxT)

Return

/*/{Protheus.doc} AtuButt
Atualiza botões
@type      Function
@author    Leonardo Kichitaro
@since     17/01/2023
/*/
Static Function AtuButt(nOpcMV, nButt)

    If nOpcMV == 1
        If nButt == 1
            If !lBtNFE
                lBtNFE := .T.
                oBt1Pg1:SetCSS(getCSS(1))
            Else
                lBtNFE := .F.
                oBt1Pg1:SetCSS(getCSS(2))
            EndIf
        ElseIf nButt == 2
            If !lBtCTE
                lBtCTE := .T.
                oBt2Pg1:SetCSS(getCSS(1))
            Else
                lBtCTE := .F.
                oBt2Pg1:SetCSS(getCSS(2))
            EndIf
        ElseIf nButt == 3
            If !lBtCTO
                lBtCTO := .T.
                oBt3Pg1:SetCSS(getCSS(1))
            Else
                lBtCTO := .F.
                oBt3Pg1:SetCSS(getCSS(2))
            EndIf
        ElseIf nButt == 4
            If !lBtNFS
                lBtNFS := .T.
                oBt4Pg1:SetCSS(getCSS(1))
            Else
                lBtNFS := .F.
                oBt4Pg1:SetCSS(getCSS(2))
            EndIf
        EndIf
    ElseIf nOpcMV == 2
        If nButt == 1
            oBt5Pg1:SetCSS(getCSS(1))
            oBt6Pg1:SetCSS(getCSS(2))
            oBt7Pg1:SetCSS(getCSS(2))
            lBtMon := .T.
            lBtPre := .F.
            lBtCla := .F.
        ElseIf nButt == 2
            oBt5Pg1:SetCSS(getCSS(2))
            oBt6Pg1:SetCSS(getCSS(1))
            oBt7Pg1:SetCSS(getCSS(2))
            lBtMon := .F.
            lBtPre := .T.
            lBtCla := .F.
        ElseIf nButt == 3
            oBt5Pg1:SetCSS(getCSS(2))
            oBt6Pg1:SetCSS(getCSS(2))
            oBt7Pg1:SetCSS(getCSS(1))
            lBtMon := .F.
            lBtPre := .F.
            lBtCla := .T.
        EndIf
        oBt5Pg1:Refresh()
        oBt6Pg1:Refresh()
        oBt7Pg1:Refresh()
    Else
        If !lWIZCFG .Or. (lWIZCFG .And. !lMVTraExp)
            If nButt == 1
                oBt8Pg1:SetCSS(getCSS(1))
                oBt9Pg1:SetCSS(getCSS(2))
                lBtImpXTra := .F.
            ElseIf nButt == 2
                oBt8Pg1:SetCSS(getCSS(2))
                oBt9Pg1:SetCSS(getCSS(1))
                lBtImpXTra := .T.
            EndIf
            oBt8Pg1:Refresh()
            oBt9Pg1:Refresh()
        EndIf
    EndIf

Return .T.

/*/{Protheus.doc} WizDocs
Apresenta documentações disponíveis e 
redireciona para página da doc selecionada
@type      Function
@author    Leonardo Kichitaro
@since     17/01/2023
/*/
Static Function WizDocs()

    Local oDoc      := Nil
    Local oFWLayer  := Nil
    Local oPanDocs  := Nil

    Local oSayDoc1  := Nil
    Local oSayDoc2  := Nil
    Local oSayDoc3  := Nil
    Local oSayDoc4  := Nil
    Local oSayDoc5  := Nil

    Local oBtnDoc   := Nil

    DEFINE DIALOG oDoc TITLE STR0101 FROM 001,001 TO 245,480 PIXEL
        //------------------------------------------
        // Divide a tela e organiza os layers a serem apresentados
        oFWLayer := FWLayer():New()
        oFWLayer:Init(oDoc,.F.,.T.)

        oFWLayer:AddLine("SUP1",087,.F.)
        oFWLayer:AddColumn("FIL1",100,.T.,"SUP1")

        oFWLayer:AddWindow("FIL1","oPanDocs",STR0141,100,.F.,.T.,,"SUP1",{|| })
        oPanDocs := oFWLayer:GetWinPanel("FIL1","oPanDocs","SUP1")

        //------------------------------------------
        //  Adiciona conteúdo na label superior 
        oSayDoc1 := TSay():New(004,005,{|| STR0015 },oPanDocs,,oTFont4,,,,.T.,,,500,50)  //"Guia de Referência - Importador XML"
        oSayDoc1:blClicked  := {|| WizImpOpen("https://tdn.totvs.com/x/ZJv1H")}
        oSayDoc1:nClrText   := CLR_BLUE

        oSayDoc2 := TSay():New(018,005,{|| STR0016 },oPanDocs,,oTFont4,,,,.T.,,,500,50)  //"Integração Importador XML x Totvs Transmite"
        oSayDoc2:blClicked  := {|| WizImpOpen("https://tdn.totvs.com/x/m1tyK")}
        oSayDoc2:nClrText   := CLR_BLUE

        oSayDoc3 := TSay():New(032,005,{|| STR0142 },oPanDocs,,oTFont4,,,,.T.,,, 500,50) //"Expedição Contínua - Compras"
        oSayDoc3:blClicked  := {|| WizImpOpen("https://tdn.totvs.com/x/20EdHw")}
        oSayDoc3:nClrText   := CLR_BLUE

        oSayDoc4 := TSay():New(046,005,{|| STR0143 },oPanDocs,,oTFont4,,,,.T.,,,500,50)  //"Expedição Contínua - Documentos Eletrônicos"
        oSayDoc4:blClicked  := {|| WizImpOpen("https://tdn.totvs.com/x/BAdLHw")}
        oSayDoc4:nClrText   := CLR_BLUE

        oSayDoc5 := TSay():New(060,005,{|| STR0144 },oPanDocs,,oTFont4,,,,.T.,,,500,50) //"Estrutura de pastas"
        oSayDoc5:blClicked  := {|| WizImpOpen("https://tdn.totvs.com/x/xMb1H")}
        oSayDoc5:nClrText   := CLR_BLUE

        oBtnDoc := TButton():New(106,100,STR0019,oDoc,{||oDoc:End()},45,15,,,,.T.) //"OK"
        oBtnDoc:SetCSS(getCSS(2))

    ACTIVATE DIALOG oDoc CENTER

Return

/*/{Protheus.doc} getCSS
Retorna comandos CSS para definir as cores dos botões
@type      Static function
@author    Leonardo Kichitaro
@since     09/02/2024
/*/
Static Function getCSS(nOpc)

	Local cCSS := '' as character

    If nOpc == 1
        cCSS := "TButton{ font: 13px; padding: 6px; background-color: #3C7799; border: 1px solid #3C7799; border-radius: 6px; background-image: linear-gradient(180deg, #3dafcc 0%,#0d9cbf 100%); color: #FFFFFF;}"
    ElseIf nOpc == 2
        cCSS := "TButton{ font-size: 12px; font: bold large; padding: 4px; color: #858585; background-color: #FFFFFF; border: 1px solid #787878; border-bottom-color: #A4A4A6; border-radius: 6px; background-image: color: #FFFFFF;}"
    EndIf

Return cCSS

/*/{Protheus.doc} incSched
    Função responsável para inclusão de agendamentos no smartSchedule
@type      Static function
@author    Everton Fregonezi Diniz
@since     09/02/2024
/*/
Static Function incSched()

local nX        := 0
local oSchedule := Nil

    oSchedule := totvs.protheus.backoffice.com.general.schedule():new()

    if  !( oSchedule:lLibVersion ) .or.  ;
        !( oSchedule:lUsrAdmin )

        lStsSched := .F.
        cMsgSch := oSchedule:cMsgError

    else

        for nX := 1 to len(aSchedule)
            If !aSchedule[nX,6]
                oSchedule := totvs.protheus.backoffice.com.general.schedule():new()
                oSchedule:createSched(aSchedule[nX,5])
                lStsSched := oSchedule:lInsert
                if !(lStsSched)
                    exit
                endif
            Endif
        next nX		
    endif
return
