#include "Protheus.ch"
#include "ApWizard.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#include "TbIconn.ch" 
#include "FILEIO.CH"
#include "FWEVENTVIEWCONSTS.CH"
#include "WIZINTPCP.ch"
#Include "POSCSS.CH"

Static oTFont   := Nil
Static oTFont1  := Nil
Static oTFont2  := Nil
Static oTFont3  := Nil
Static oTFont4  := Nil

/*/{Protheus.doc} WIZINTPCP
Wizard para configuração da integração do SIGAGCP x Portal de Compras Públicas

@author Leonardo Kichitaro
@since 05/04/2024
/*/
Function WIZINTPCP()

    Local aVldAmb       := {}

    Local lVldPar       := .F.
    Local lVldTab       := .F.
    Local lVldGrp       := .F. 

    Private oDlg        := Nil
    Private oPanelWiz   := Nil
    Private oStepWiz    := Nil

    Private oBTDoc      := Nil
    Private oTBitmap    := Nil

    Private oNewPag1    := Nil
    Private oS1Pg1      := Nil
    Private oS2Pg1      := Nil
    Private oS3Pg1      := Nil
    Private oS4Pg1      := Nil
    Private oG1Pg1      := Nil
    Private oBt1Pg1     := Nil
    Private oBt2Pg1     := Nil

    Private oNewPag2    := Nil
    Private oS1Pg2      := Nil
    Private oS2Pg2      := Nil
    Private oS3Pg2      := Nil
    Private oS4Pg2      := Nil
    Private oS5Pg2      := Nil
    Private oG1Pg2      := Nil
    Private oG2Pg2      := Nil
    Private oG3Pg2      := Nil
    Private oG4Pg2      := Nil
    Private oG5Pg2      := Nil

    Private cPbKyAnt    := ""
    Private cMsgEstru   := ""

    Private cGetPbcKey  := ""
    Private cGetUser1   := ""
    Private cGetUser2   := ""
    Private cGetUser3   := ""
    Private cGetUser4   := ""
    Private cGetUser5   := ""

    Private nAmbiAnt    := 1

    Private lProduc     := .F.
    Private lWarning    := .F.

    Private aMVWizPCP   := {}

    //Verifica estruturas necessários no ambiente para integração
    lVldPar := WizPcpMV(@aVldAmb)
    lVldTab := WizPcpTab(@aVldAmb)
    lVldGrp := WizPcpGrp(@aVldAmb)
    
	//Efetua validações para criação do Agendamento do Schedule
    WizPcpSchd(@aVldAmb,.T.) 
    
    If lVldPar .And. lVldTab .And. lVldGrp

        If lWarning
            WizDetCfg(aVldAmb)
        EndIf

        nAmbiAnt := SuperGetMV("MV_AMBPCP", .F. , 2)
        lProduc  := Iif(nAmbiAnt == 2, .F., .T.)

        aAdd(aMVWizPCP,{"MV_AMBPCP", nAmbiAnt})

        //Carrega os parâmetros de informações do cofre para montagem do Wizard e add na array 'aMVWizPCP'
        WizPcpCfr()

        cPbKyAnt := aMVWizPCP[2][2]

        cGetPbcKey := Iif(!Empty(aMVWizPCP[2][2]), aMVWizPCP[2][2], Space(100))
        cGetUser1  := Iif(!Empty(aMVWizPCP[3][2]), aMVWizPCP[3][2], Space(11))
        cGetUser2  := Iif(!Empty(aMVWizPCP[4][2]), aMVWizPCP[4][2], Space(11))
        cGetUser3  := Iif(!Empty(aMVWizPCP[5][2]), aMVWizPCP[5][2], Space(11))
        cGetUser4  := Iif(!Empty(aMVWizPCP[6][2]), aMVWizPCP[6][2], Space(11))
        cGetUser5  := Iif(!Empty(aMVWizPCP[7][2]), aMVWizPCP[7][2], Space(11))

        oTFont := TFont():New('Arial',,-16,,.F.)
        oTFont1:= TFont():New('Arial',,-16,,.T.)
        oTFont2:= TFont():New('Arial',,-20,,.F.)
        oTFont3:= TFont():New('Arial',,-20,,.T.)
        oTFont4:= TFont():New('Arial',,-16,,.T.,,,,,.T.)

        //Para que a tela da classe FWWizardControl fique no layout com bordas arredondadas iremos fazer com que a janela do Dialog oculte as bordas e a barra de titulo
        //para isso usaremos os estilos WS_VISIBLE e WS_POPUP
        DEFINE DIALOG oDlg TITLE STR0001 PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP ) //'Integração com Portal de Compras Públicas'

            oDlg:nWidth := 1000
            oDlg:nHeight := 620

            oPanelWiz:= tPanel():New(0,0,"",oDlg,,,,,,300,150)
            oPanelWiz:Align := CONTROL_ALIGN_ALLCLIENT

            //Instancia a classe FWWizard
            oStepWiz:= FWWizardControl():New(oPanelWiz)
            oStepWiz:ActiveUISteps()

            // Pagina 1
            oNewPag1 := oStepWiz:AddStep("1")
            oNewPag1:SetStepDescription(STR0002) //"Boas Vindas"
            oNewPag1:SetConstruction({|Panel| WizIntPg(Panel,1)})
            oNewPag1:SetNextAction({|| WizPcpVld(1)})
            oNewPag1:SetCancelAction({|| .T., oDlg:End()})

            //Pagina 2
            oNewPag2 := oStepWiz:AddStep("2")
            oNewPag2:SetStepDescription(STR0003) //"Usuários Portal"
            oNewPag2:SetConstruction({|Panel| WizIntPg(Panel,2)})
            oNewPag2:SetNextAction({|| Iif(WizPcpVld(2),oDlg:End(),.F.)})
            oNewPag2:SetCancelAction({|| .T., oDlg:End()})
            oNewPag2:SetPrevAction({|| .T.})
            oNewPag2:SetPrevTitle(STR0004) //"Voltar"

            oStepWiz:Activate()

        ACTIVATE DIALOG oDlg CENTER

        oStepWiz:Destroy()
    Else
        WizDetCfg(aVldAmb)
        Help(Nil, Nil, STR0005, Nil, STR0006, 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
    EndIf

    //-- Limpa objetos da memória
    FreeObj(oDlg)
    FreeObj(oPanelWiz)
    FreeObj(oStepWiz)
    FreeObj(oNewPag1)
    FreeObj(oNewPag2)
    FwFreeArray(aMVWizPCP)
    FwFreeArray(aVldAmb)

Return

/*/{Protheus.doc} WizIntPg
Wizard - Dados das paginas para configuração da Integração com o Portal de Compras Públicas

@param  oPanel  Painel de dados
@param  nPage   Pagina do painel

@author Leonardo Kichitaro
@since 05/04/2024
/*/
Static Function WizIntPg(oPanel, nPage)

    oBTDoc := TSay():New(185,010,{|| STR0007 },oPanel,,oTFont4,,,,.T.,,,100,50) //"Documentações"
    oBTDoc:blClicked := {|| WizPcpDoc()}
    oBTDoc:nClrText  := CLR_BLUE

    oTBitmap := TBitmap():New(169,390,100,032,,"\portal\pcp\portal_compras_publicas.jpg",.T.,oPanel,{||},,.F.,.F.,,,.F.,,.T.,,.F.)
    oTBitmap:lStretch:= .T.

    If nPage == 1
        oS1Pg1 := TSay():New(005,000,{|| STR0008 },oPanel,,oTFont2,,,,.T.,,,480,150)//"Boas-vindas ao Configurador de Integração"
        oS1Pg1:SetTextAlign(2,0)

        oS2Pg1 := TSay():New(025,000,{|| STR0009 },oPanel,,oTFont2,,,,.T.,,,480,150) //"Portal de Compras Públicas"                       //"Portal de Compras Públicas"
        oS2Pg1:SetTextAlign(2,0)

        oS3Pg1 := TSay():New(052,000,{|| STR0010 },oPanel,,oTFont,,,,.T.,,,480,150)//"Qual ambiente deseja utilizar para integração?"
        oS3Pg1:SetTextAlign(2,0)

        oBt1Pg1	:= tButton():New(067,190,STR0011,oPanel,{|| AtuButt(1), oBt1Pg1:Refresh(), oPanel:Refresh()},53,35,,,.F.,.T.,.F.,,.F.,,,.F.)   //"Produção"
        oBt1Pg1:cTooltip := STR0012  //"Integra com o ambiente de produção do Portal de Compras Públicas"
        Iif(lProduc, oBt1Pg1:SetCSS(getCSS(1)), oBt1Pg1:SetCSS(getCSS(2)))

        oBt2Pg1	:= tButton():New(067,250,STR0013,oPanel,{|| AtuButt(2), oBt2Pg1:Refresh(), oPanel:Refresh()},53,35,,,.F.,.T.,.F.,,.F.,,,.F.)      //"Teste"
        oBt2Pg1:cTooltip := STR0014 //"Integra com o ambiente de teste do Portal de Compras Públicas"
        Iif(!lProduc, oBt2Pg1:SetCSS(getCSS(1)), oBt2Pg1:SetCSS(getCSS(2)))

        oS4Pg1 := TSay():New(116,000,{|| STR0015 },oPanel,,oTFont,,,,.T.,,,480,150) //"Credencial de Acesso(Public Key):"
        oS4Pg1:SetTextAlign(2,0)
        oG1Pg2 := TGet():New(131,142,{|u|If(PCount()==0,cGetPbcKey,cGetPbcKey := u)},oPanel,200,15,,,,,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetPbcKey",,,,)

        oBt1Pg1:SetFocus()
    Elseif nPage == 2
        oS1Pg2 := TSay():New(10,10,{|| STR0016 },oPanel,,oTFont2,,,,.T.,,,480,150) //"Configurações dos CPFs dos usuários cadastrados/habilitados"
        oS1Pg2:SetTextAlign(2,0)

        oS1Pg2 := TSay():New(045,138,{|| STR0017 },oPanel,,oTFont,,,,.T.,,,480,150) //"Autoridade Competente:"
        oS1Pg2:SetTextAlign(3,0)
        oG1Pg2 := TGet():New(040,258,{|u|If(PCount()==0,cGetUser1,cGetUser1 := u)},oPanel,100,15,"@R 999.999.999-99",,,,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetUser1",,,,)

        oS2Pg2 := TSay():New(065,138,{|| STR0018 },oPanel,,oTFont,,,,.T.,,,480,150) //"Pregoeiro:"
        oS2Pg2:SetTextAlign(3,0)
        oG2Pg2 := TGet():New(060,258,{|u|If(PCount()==0,cGetUser2,cGetUser2 := u)},oPanel,100,15,"@R 999.999.999-99",,,,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetUser2",,,,)

        oS3Pg2 := TSay():New(085,138,{|| STR0019 },oPanel,,oTFont,,,,.T.,,,480,150) //"Leiloeiro:"
        oS3Pg2:SetTextAlign(3,0)
        oG3Pg2 := TGet():New(080,258,{|u|If(PCount()==0,cGetUser3,cGetUser3 := u)},oPanel,100,15,"@R 999.999.999-99",,,,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetUser3",,,,)

        oS4Pg2 := TSay():New(105,138,{|| STR0020 },oPanel,,oTFont,,,,.T.,,,480,150) //"Responsável:"
        oS4Pg2:SetTextAlign(3,0)
        oG4Pg2 := TGet():New(100,258,{|u|If(PCount()==0,cGetUser4,cGetUser4 := u)},oPanel,100,15,"@R 999.999.999-99",,,,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetUser4",,,,)

        oS5Pg2 := TSay():New(125,138,{|| STR0021 },oPanel,,oTFont,,,,.T.,,,480,150) //"Operador Compra Direta:"
        oS5Pg2:SetTextAlign(3,0)
        oG5Pg2 := TGet():New(120,258,{|u|If(PCount()==0,cGetUser5,cGetUser5 := u)},oPanel,100,15,"@R 999.999.999-99",,,,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetUser5",,,,)

        oG1Pg2:SetFocus()
    Endif

Return

/*/{Protheus.doc} WizPcpVld
Validações das paginas

@param  nPage   Pagina a ser validada

@author Leonardo Kichitaro 
@since 05/04/2024
/*/
Static Function WizPcpVld(nPage)

    Local oGCPApiPCP    := Nil

    Local nX            := 0

    Local lRet          := .T.

    aMVWizPCP[2][2] := cGetPbcKey
    aMVWizPCP[3][2] := cGetUser1
    aMVWizPCP[4][2] := cGetUser2
    aMVWizPCP[5][2] := cGetUser3
    aMVWizPCP[6][2] := cGetUser4
    aMVWizPCP[7][2] := cGetUser5

    If nPage == 1 //Realiza validação de comunicação com o Portal de Compras Públicas com os acessos informados
        //Altera o parâmentro antes de chamar a integração
        PutMV("MV_AMBPCP", Iif(lProduc, 1, 2))
        PutSafePcP(aMVWizPCP[2][1], aMVWizPCP[2][2], .T.)

        oGCPApiPCP := GCPApiPCP():New()
        If !oGCPApiPCP:StatusInteg()
            lRet := .F.
        EndIf

        //Retorna as informações anteriores dos parâmetros em caso de cancelamento do wizard
        PutMV("MV_AMBPCP", nAmbiAnt)
        PutSafePcP(aMVWizPCP[2][1], cPbKyAnt, .T.)

        FreeObj(oGCPApiPCP)
    Elseif nPage == 2  //Realiza gravação dos parâmetros configurados no Wizard
        //Altera o parâmentro antes de chamar a integração
        PutMV("MV_AMBPCP", Iif(lProduc, 1, 2))
        For nX := 2 To Len(aMVWizPCP)
            PutSafePcP(aMVWizPCP[nX][1], aMVWizPCP[nX][2], .T.)
        Next

        //Cria os agendamentos da schedule automaticamente
        WizPcpSchd()
    Endif

Return lRet

/*/{Protheus.doc} WizPcpCfr
Busca parâmetros com dados sensíveis no cofre

@param  nOper     Tipo de operação 1=Get/2=Put
@param  cNameVar  Para realizar Get/Put de alguma variável especifica do cofre
@param  cPutCofre Conteúdo que será gravado em caso de Put

@author Leonardo Kichitaro
@since 05/04/2024
/*/
Static Function WizPcpCfr()

    Local cValSafe  := ""

    Local nX        := 0

    Local aParCofre := {"cPublicKeyPCP", "cCFPAutoResPCP", "cCFPPregoeiPCP", "cCFPLeiloeiPCP", "cCFPResponsPCP", "cCFPOpComDiPCP"}
    Local aValDefau := {Space(100), Space(11), Space(11), Space(11), Space(11), Space(11)}

    For nX := 1 To Len(aParCofre)
        cValSafe := PutSafePcP(aParCofre[nX], aValDefau[nX])
        aAdd(aMVWizPCP,{aParCofre[nX], cValSafe})
    Next

    FwFreeArray(aParCofre)
    FwFreeArray(aValDefau)

Return cValSafe

/*/{Protheus.doc} GetSafeExt
Busca Ids que foram gravaos no cofre

@param  cIdSafe Identificador que do registro armazenado

@author Leonardo Kichitaro
@since 05/04/2024
/*/
Function GetSafeExt(cIdSafe)

    Local cValSafe  := ""

    cValSafe := AllTrim(PutSafePcP(cIdSafe))

Return cValSafe

/*/{Protheus.doc} PutSafePcP
Grava valores no cofre

@param  cIdSafe     Identificador que do registro armazenado
@param  cPutCofre   Conteúdo que será gravado em caso de Put

@author Leonardo Kichitaro
@since 05/04/2024
/*/
Static Function PutSafePcP(cIdSafe, cPutSafe, lGrava)

    Local oVault        := Nil
    Local cValSafe      := ""

    Default cIdSafe     := ""
    Default cPutSafe    := ""
    Default lGrava      := .F.

    oVault := FwSafeVault():New()
    cValSafe := oVault:Get(cIdSafe)
    If Empty(cValSafe) .Or. lGrava
        If lGrava .And. !Empty(cValSafe) .And. Empty(cPutSafe)
            oVault:Delete(cIdSafe)
        Else
            oVault:Put(cIdSafe, cPutSafe)
        EndIf
    EndIf

    FreeObj(oVault)

Return cValSafe

/*/{Protheus.doc} WizPcpMV
Validação dos parametros

@author Leonardo Kichitaro
@since 05/04/2024
/*/
Static Function WizPcpMV(aVldAmb)

    Local aMVVer    := {}
    Local nI        := 0
    Local cMsg      := ""
    Local cDescMV   := ""
    Local xConteudo := Nil
    Local lParShow  := .F.
    Local lRet      := .T.

  
    aMVVer :=  {{"MV_AMBPCP",  STR0022},; //Ambiente para integralção com o Portal de Compras Publicas 
                {"MV_URLPCP1", STR0050},; //Url de Produção da Integração com o PCP  
                {"MV_URLPCP2", STR0051},; //Url de Teste da Integração com o PCP   
                {"MV_PTHPCP1", STR0052},; //EndPoint utilizado na integração com o PCP
                {"MV_PTHPCP2", STR0052},; //EndPoint utilizado na integração com o PCP
                {"MV_PTHPCP3", STR0053},; //EndPoint do Objeto de Envio com o PCP
                {"MV_PTHPCP4", STR0053}}  //EndPoint do Objeto de Envio com o PCP
   
    dbSelectArea( "SX6" )
    SX6->( dbSetOrder( 1 ) )

    For nI := 1 To Len(aMVVer)

        cMsg += "Parâmetro: " + aMVVer[nI][1]  + CRLF
        cDescMV := ""
        lParShow := FWSX6Util():ExistsParam(aMVVer[nI][1])

        If lParShow
            If SX6->( MsSeek( FwxFilial("SX6") + aMVVer[nI][1]) )
                cDescMV     := AllTrim(X6Descric()) + " " + AllTrim(X6Desc1()) + " " + AllTrim(X6Desc2())
                xConteudo	:= X6Conteud()

                cMsg += "[OK]............. " + STR0023 + CRLF + CRLF //"Parâmetro: OK"
                aAdd(aVldAmb,{1,aMVVer[nI][1],cDescMV,xConteudo}) 
            Endif
        Else
            cMsg += "[ERROR].......... " + STR0024 + CRLF + CRLF //"Parâmetro: inexistente no ambiente"
            aAdd(aVldAmb,{2,aMVVer[nI][1],aMVVer[nI][2]})
            lRet := .F.
        Endif
    Next nI

    cMsgEstru += cMsg + CRLF + CRLF

    FwFreeArray(aMVVer)
Return lRet

/*/{Protheus.doc} WizPcpTab
Validação das tabelas/estrutura

@author Leonardo Kichitaro
@since 08/04/2024
/*/
Static Function WizPcpTab(aVldAmb)

    Local aTabVer   := {{"CO1",;
                        {'CO1_ANOAB','CO1_ORCSIG','CO1_APL147','CO1_BENELO','CO1_EXIGEG','CO1_FASELA','CO1_INTERL','CO1_VLINTL','CO1_DTFINP','CO1_DTLINP',;
                        'CO1_DTABPR','CO1_DTLIES','CO1_ACPROS','CO1_TEMPAL','CO1_ENQJUR','CO1_COTARE','CO1_OPERLO','CO1_CADRES'}},;
                        {"CO2",;
                        {'CO2_QTDRSV'}},;
                        {"CP3",;
                        {'CP3_LOTMPE','CP3_COTARE'}},;
                        {"DKF",;
                        {'DKF_FILIAL','DKF_TPINTG','DKF_IDLICT','DKF_NRLICT','DKF_ANOAB','DKF_CODEDT','DKF_NUMPRO','DKF_VERSAO','DKF_REVISA','DKF_MODALI','DKF_DESMOD',;
                        'DKF_OBJETO','DKF_STATUS','DKF_DSCSTS','DKF_MSGENV','DKF_DTINTE','DKF_HRINTE','DKF_MSGRET','DKF_DTATUA','DKF_HRATUA','DKF_MSGATU','DKF_URLPRO',; 
                        'DKF_TPDOC','DKF_NUMDOC'}},;
                        {"DKG",;
                        {'DKG_FILIAL','DKG_IDLICT','DKG_ITEM','DKG_NRLICT','DKG_ANOAB','DKG_CODEDT','DKG_NUMPRO','DKG_VERSAO','DKG_REVISA','DKG_DESMOD','DKG_STATUS',;
                        'DKG_DSCSTS','DKG_DTSTAT','DKG_HRSTAT','DKG_MSGRET'}}}

    Local nI        := 0
    Local cMsgEst   := ""
    Local lRet      := .T.

    For nI := 1 To Len(aTabVer)
        cMsgEst := ""
        cMsgEstru += STR0025 + aTabVer[nI,1] + CRLF //"Tabela: "
        If ChkFile(aTabVer[nI,1])
            cMsgEstru += "[OK]............. " + STR0026 + CRLF //"Tabela: OK"
            cMsgEst := WizPcpEst(aTabVer[nI,1],aTabVer[nI,2]) + CRLF + CRLF + CRLF
            cMsgEstru += cMsgEst
            aAdd(aVldAmb,{Iif("WARNING" $ cMsgEst,3,1),aTabVer[nI,1],FwSX2Util():GetX2Name(aTabVer[nI,1])})
            If "WARNING" $ cMsgEst
                lWarning := .T.
            EndIf
        Else
            cMsgEstru += "[ERROR].......... " + STR0027 + CRLF + CRLF + CRLF + CRLF //"Tabela: inexistente no ambiente"
            aAdd(aVldAmb,{2,aTabVer[nI,1],FwSX2Util():GetX2Name(aTabVer[nI,1])})
            lRet := .F.
        Endif
    Next nI

Return lRet

/*/{Protheus.doc} WizPcpEst
Validação das estrutura da tabela

@author Leonardo Kichitaro
@since 08/04/2024
/*/
Static Function WizPcpEst(cTab,aEstTab)

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
        cMsgRet += "[WARNING]........ " + STR0028 + cMsg + STR0029 //"Estrutura: "#" campo(s) inexistente(s) no ambiente"
    Else
        cMsgRet += "[OK]............. " + STR0030 //"Estrutura: OK"
    Endif

Return cMsgRet



/*/{Protheus.doc} WizPcpGrp
Validação de tamanho dos campos e grupos de campos 
@author Maxsuel Alves
@since 13/08/2025
/*/
Static Function WizPcpGrp(aVldAmb)

    Local aInfGrp       As Array
    Local aGrupo        As Array
    Local aArea         As Array
    Local lRet          As Logical
    Local nI            As Numeric
    Local nTamCPZ_NOME  As Numeric
    Local nTamA2_NOME   As Numeric
    Local nTamSXG       As Numeric
    Local cFindG        As Character

    aInfGrp   := {}
    aGrupo    := {"174","177"}
    aArea     := GetArea()
    lRet      := .T.
    nTamSXG   := 0
    cFindG    := ""

    // Busca tamanhos dos campos CPZ_NOME e A2_NOME
    nTamCPZ_NOME := TamSX3("CPZ_NOME")[1]
    nTamA2_NOME  := TamSX3("A2_NOME")[1]


    // Faz a busca dos grupos 174 e 177 na tabela SXG
    For nI := 1 To Len(aGrupo)

        cFindG := aGrupo[nI]
        nTamSXG := FWSXGUtil():SXGSize(cFindG) //Busca o tamanho do grupo de campo na SXG

        If FWSXGUtil():FieldGroupExists(cFindG)
            Do Case
                Case cFindG == "174"

                    aAdd(aInfGrp, {cFindG,STR0045, nTamSXG})//174, Nome do Participante, "SIZE"

                Case cFindG == "177"

                    aAdd(aInfGrp, {cFindG,STR0046, nTamSXG})//177, Nome do Fornecedor, "SIZE"
            EndCase
        endif
    Next nI

    // Se os grupos 174 e 177 forem encontrados
    If Len(aInfGrp) == 2

        If aInfGrp[1,3] <> aInfGrp[2,3] // Grupo 174 <> 177

            cMsgEstru += "[ERROR]........ " + STR0040 + " " + aInfGrp[1,1] + " (" + AllTrim(aInfGrp[1,2]) + ") " + " " + ; //Tamanho do grupo de campo(s):
                    STR0041 + " " + aInfGrp[2,1] + " (" + AllTrim(aInfGrp[2,2]) + ") " + CRLF + CRLF + CRLF //divergente(s) do Grupo:
            AAdd(aVldAmb, {2, aInfGrp[1,1], STR0042 + " " + cValToChar(aInfGrp[1,3])})
            AAdd(aVldAmb, {2, aInfGrp[2,1], STR0042 + " " + cValToChar(aInfGrp[2,3])}) 

            lRet := .F.

        else
            
            cMsgEstru += STR0043 + ": " + aInfGrp[1,1] + " | " + aInfGrp[2,1] + CRLF //Grupo de Campo(s)
            cMsgEstru += "[OK]........ " + STR0030 + CRLF + CRLF + CRLF //"Estrutura: OK"
            aAdd(aVldAmb,{1,aInfGrp[1,1], aInfGrp[1,2]})
            aAdd(aVldAmb,{1,aInfGrp[2,1], aInfGrp[2,2]})

        endIf
    else 

        // Se não encontrar os grupos de campos
        If Len(aInfGrp) == 0

            cMsgEstru += "[WARNING]........ " + STR0028 + STR0044 + CRLF + CRLF + CRLF + CRLF //Estrutura: "#" Grupo de campo(s) 144 e 177 inexistente(s) no ambiente
            
            aAdd(aVldAmb,{3,"174",STR0045 }) //Nome do Participante
            aAdd(aVldAmb,{3,"177",STR0046 }) //Nome do Fornecedor

            If  nTamA2_NOME <> nTamCPZ_NOME
        
                cMsgEstru += "[ERROR]........ " + STR0048 + " " + STR0049 + CRLF + CRLF + CRLF + CRLF //Tamanho do campo A2_NOME "#"  divergente do campo CPZ_NOME
                        
                AAdd(aVldAmb, {2, "CPZ_NOME", STR0042  + " " + cValToChar(nTamCPZ_NOME)})
                AAdd(aVldAmb, {2, "A2_NOME", STR0042  + " " + cValToChar(nTamA2_NOME)})

                lRet := .F.
            else

                cMsgEstru += STR0047 + "CPZ_NOME" + " | " + "A2_NOME" + CRLF //Campo(s)
                cMsgEstru += "[OK]........ " + STR0030 + CRLF + CRLF + CRLF //"Estrutura: OK"
                AAdd(aVldAmb, {1, "CPZ_NOME", STR0042  + " " + cValToChar(nTamCPZ_NOME)})
                AAdd(aVldAmb, {1, "A2_NOME", STR0042  + " " + cValToChar(nTamA2_NOME)})

            endIf

        EndIf

    EndIf

    
    RestArea(aArea)

    FwFreeArray(aArea)
    FwFreeArray(aInfGrp)
    FwFreeArray(aGrupo)
Return lRet


/*/{Protheus.doc} WizDetCfg
Tela com detalhes da configuração automatica
@type      Function
@author    Leonardo Kichitaro
@since     08/04/2024
/*/
Static Function WizDetCfg(aVldAmb)

    Local oDetCfg   := Nil
    Local oFWLayer  := Nil
    Local oPanDet   := Nil
    Local oBtnDet   := Nil
    Local oOK 	    := LoadBitmap(GetResources(),'NGBIOALERTA_02.png')
    Local oNO 	    := LoadBitmap(GetResources(),'NGBIOALERTA_03.png')
    Local oYE       := LoadBitmap(GetResources(),'NGBIOALERTA_01.png')
    Local oBrwDet   := Nil
    Local oMGetDet  := Nil
    Local aHdTab    := {}
    Local aTamTab   := {}
    Local cDscTel   := ""
    Local cDesc1    := ""

    cDscTel := Upper(STR0031) //"PARÂMETROS/TABELAS E ESTRUTURAS"
    aHdTab  := {"Ok",STR0032+STR0054,STR0033} //"Ok"#"Parâmetro/Tabela"#"Descrição"
    aTamTab := {1,10,200}
    cDesc1  := STR0034 + ":" + CRLF + CRLF + STR0035 //"Validação de estruturas para integração"#""Detalhes da validação de parâmetros, tabelas e campos da integração com o Portal de Compras Públicas"

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

        oS1Dt2 := TSay():New(10,05,{|| cDesc1 },oPanDet,,oTFont,,,,.T.,,,600,100)

        oBrwDet := TWBrowse():New(50,05,298,190,,aHdTab,aTamTab,oPanDet,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
        oBrwDet:SetArray(aVldAmb)
        oBrwDet:bLine	:= { || {   Iif(aVldAmb[oBrwDet:nAt,1]==1,oOK,Iif(aVldAmb[oBrwDet:nAt,1]==2,oNO,oYE)),;
                                    aVldAmb[oBrwDet:nAt,2],;
                                    aVldAmb[oBrwDet:nAt,3]}}

        oMGetDet := tMultiget():new( 50, 310, {| u | if( pCount() > 0, cMsgEstru := u, cMsgEstru ) },oPanDet, 245, 190, , , , , , .T. )

        oBtnDet := TButton():New(289,270,"OK",oDetCfg,{||oDetCfg:End()},45,15,,,,.T.) //"OK"
        oBtnDet:SetCSS(getCSS(2))

    ACTIVATE DIALOG oDetCfg CENTER

Return

/*/{Protheus.doc} WizPcpSchd
Função responsável para inclusão de agendamentos no smartSchedule

@author Leonardo Kichitaro
@since 09/04/2024
/*/
Static Function WizPcpSchd(aVldAmb,lVldExec)
    Local aParam    As Array
    Local aGrpComp  As Array
    Local aSM0Fil   As Array
    Local oSchedule As Object 
    Local lVLib     As Character

    Default lVldExec := .F. 

    aParam      := {}
    aSM0Fil     := {}
    oSchedule   := totvs.protheus.backoffice.gcp.general.schedule():new()
    lVLib       := "20240408"


    If lVldExec
        
        cMsgEstru += "SCHEDULE: " + CRLF

        If Empty(FWSchdByFunction("SCHEDGCPPCP"))  
            If  !( oSchedule:lLibVersion ) .or.  ;
                !( oSchedule:lUsrAdmin )
                
                lWarning := .T.
                cMsgEstru += "[WARNING]........ " + STR0037 + lVLib + STR0038  // "Lib Label inferior a " # " " ou usuário não possui previlegios de administrador para criação do Agendamento."   
                aAdd(aVldAmb,{3,"SCHEDULE","Agendamento do Schedule" })
            Else 
                aAdd(aVldAmb,{1,"SCHEDULE","Agendamento do Schedule" })
                cMsgEstru += "[OK]............. " + STR0039
            EndIf     
        Else 
            cMsgEstru += "[OK]............. " + STR0039
        EndIf   
    Else 
        If  Empty(FWSchdByFunction("SCHEDGCPPCP"))
                aGrpComp := FWAllGrpCompany()

                aEval(aGrpComp,{|x| aadd(aSM0Fil, { x, FWAllFilial( , , x, .F.) }) })

                aAdd(aParam,{ "SCHEDGCPPCP"             ,;  // setRoutine
                            nModulo                 ,;  // setModule
                            "000000"                ,;  // setUser
                            STR0036                 ,;  // setDescription   # "Busca processos no Portal de Compras Públicas e atualiza status"
                            .T.                     ,;  // setRecurrence
                            {'D', , 1, 0, }         ,;  // setPeriod
                            {'M', 20, , , }         ,;  // setFrequency
                            .T.                     ,;  // setDiscard
                            .T.                     ,;  // setManageable
                            aSM0Fil                 ,; 
                            { DATE(),TIME() }       ,;   // setFirstExecution
                            .F.                     ;
                        })

                totvs.protheus.backoffice.gcp.general.schedule():createSched(aParam[1])
        EndIf 
    endIf 

    FwFreeArray(aParam)
    FwFreeArray(aGrpComp)
    FwFreeArray(aSM0Fil)

Return

/*/{Protheus.doc} WizPcpDoc
Apresenta documentações disponíveis e 
redireciona para página da doc selecionada
@type      Function
@author    Leonardo Kichitaro
@since     05/04/2024
/*/
Static Function WizPcpDoc()

    ShellExecute("Open", "https://tdn.totvs.com/x/6BIXMg", "", "", 1)

Return

/*/{Protheus.doc} AtuButt
Atualiza botões

@type      Function
@author    Leonardo Kichitaro
@since     05/04/2024
/*/
Static Function AtuButt(nButt)

    If nButt == 1
        oBt1Pg1:SetCSS(getCSS(1))
        oBt2Pg1:SetCSS(getCSS(2))
        lProduc := .T.
    ElseIf nButt == 2
        oBt1Pg1:SetCSS(getCSS(2))
        oBt2Pg1:SetCSS(getCSS(1))
        lProduc := .F.
    EndIf

Return .T.

/*/{Protheus.doc} getCSS
Retorna comandos CSS para definir as cores dos botões
@type      Static function
@author    Leonardo Kichitaro
@since     05/04/2024
/*/
Static Function getCSS(nOpc)

	Local cCSS := '' as character

    If nOpc == 1
        cCSS := "TButton{ font: 13px; padding: 6px; background-color: #3C7799; border: 1px solid #3C7799; border-radius: 6px; background-image: linear-gradient(180deg, #3dafcc 0%,#0d9cbf 100%); color: #FFFFFF;}"
    ElseIf nOpc == 2
        cCSS := "TButton{ font-size: 12px; font: bold large; padding: 4px; color: #858585; background-color: #FFFFFF; border: 1px solid #787878; border-bottom-color: #A4A4A6; border-radius: 6px; background-image: color: #FFFFFF;}"
    EndIf

Return cCSS
