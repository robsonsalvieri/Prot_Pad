#Include "TOTVS.ch"
#Include "FwSchedule.ch"
#Include "FINA893.ch"

Static __lIsBlind As Logical
Static __lReadOn  As Logical
Static __cClienId As Character
Static __cClienSe As Character
Static __cAppKey  As Character
Static __cKeyCert As Character
Static __cCert    As Character
Static __cUrlWebH As Character
Static __nRadio   As Numeric
Static __nQtdMark As Numeric
Static __nLoop    As Numeric
Static __oBanco   As Object
Static __oStrTmp  As Object
Static __nRadMult As Numeric
Static __nVlMulta As Numeric

/*/{Protheus.doc} FINA893A
    Cria o wizard de configuração de conexão com a API
    
    @author Sivaldo Oliveira
    @since 23/11/2022
    
    @param cBancoOfi, Char, (COMPE) Código do sistema de operações 
    monetárias e compensação de outros papéis.
    /*/
Function FINA893A(cBancoOfi As Char)
    Local cTblTmp  As Char
    Local oDaialog As Object
    Local oPanel   As Object 
    Local oWizard  As Object
    Local oPage01  As Object
    Local oPage02  As Object
    Local oPage03  As Object
    Local oPage04  As Object
    Local oPage05  As Object
    Local oPage06  As Object
    Local oBrwCta  As Object
    
    //Parâmetros de entrada da função.
    Default cBancoOfi := ""
    
    //Inicializa variáveis.
    InicStatic()
    
    cTblTmp  := ""
    oDaialog := Nil
    oPanel   := Nil
    oWizard  := Nil
    oPage01  := Nil
    oPage02  := Nil
    oPage03  := Nil
    oPage04  := Nil
    oPage05  := Nil
    oPage06  := Nil
    oBrwCta  := Nil
    
    //Cria o objeto daialog (Tela/caixa de diálogo)
	Define Dialog oDaialog Title (STR0069+STR0070)  PIXEL STYLE NOR(WS_VISIBLE,WS_POPUP) 
    oDaialog:nWidth  := 900
    oDaialog:nHeight := 600
    
    oPanel := TPanel():New(10, 20,"", oDaialog, Nil, Nil, Nil, Nil, Nil, 600, 400)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    //Instância a classe (FwWizardControl)
    oWizard := FwWizardControl():New(oPanel)
    oWizard:ActiveUISteps()
    
    //Pagina 1: Tela de boas vindas
    oPage01 := oWizard:AddStep("1Pag", {|Panel|WizPage01(Panel)})
    oPage01:SetStepDescription(STR0071)
    oPage01:SetNextTitle(STR0005)
    oPage01:SetNextAction({||.T.})
    oPage01:SetCancelAction({||BtnCancela(oDaialog)})
    
    //Pagina 2: Seleção das contas bancárias
    oPage02 := oWizard:AddStep("2Pag", {|Panel|WizPage02(oDaialog, Panel, @oBrwCta, cBancoOfi, @cTblTmp)})
    oPage02:SetStepDescription(STR0072)    
    oPage02:SetNextTitle(STR0005)
    oPage02:SetNextAction({||ValidaPag2(oPanel, oBrwCta, cTblTmp)})
    oPage02:SetCancelAction({||BtnCancela(oDaialog)})   
    
    //Pagina 3: Credenciais de Conexão
    oPage03 := oWizard:AddStep("3Pag", {|Panel|WizPage03(Panel, cTblTmp)})
    oPage03:SetStepDescription(STR0061)
    oPage03:SetNextTitle(STR0005)
    oPage03:SetNextAction({||__nQtdMark > 0 .And. BtnGrava(oDaialog, oBrwCta, oPanel, cBancoOfi, cTblTmp)})
    oPage03:SetCancelAction({||BtnCancela(oDaialog)})
    oPage03:SetPrevAction({||.F.})
    oPage03:SetPrevWhen({||.F.})

    //Pagina 4: Configuração do certificado
    oPage04 := oWizard:AddStep("4Pag", {|Panel|WizPage04(Panel, cTblTmp)})
    oPage04:SetStepDescription(STR0130)
    oPage04:SetNextTitle(STR0005)
    oPage04:SetNextAction({||GrvCert(oDaialog, oBrwCta, cTblTmp)})
    oPage04:SetCancelAction({||BtnCancela(oDaialog)})
    oPage04:SetPrevAction({||.F.})
    oPage04:SetPrevWhen({||.F.})
    
    //Pagina 5: Url de callback (WebHook)
    oPage05 := oWizard:AddStep("5Pag", {|Panel|WizPage05(Panel, cTblTmp)})
    oPage05:SetStepDescription(STR0115)
    oPage05:SetNextTitle(STR0005)
    oPage05:SetNextAction({||GrvWebHook(oDaialog, oBrwCta, cTblTmp)})
    oPage05:SetCancelAction({||BtnCancela(oDaialog)})
    oPage05:SetPrevAction({||.F.})
    oPage05:SetPrevWhen({||.F.})    
    
    //Pagina 6: Concluir
    oPage06 := oWizard:AddStep("6Pag", {|Panel|WizPage06(Panel)})
    oPage06:SetStepDescription(STR0114)
    oPage06:SetNextTitle(STR0011)
    oPage06:SetNextAction({||oDaialog:End()})
    oPage06:SetCancelAction({||BtnCancela(oDaialog)})
    oPage06:SetPrevAction({||.F.})
    oPage06:SetPrevWhen({||.F.})    
    
    oWizard:Activate()
    ACTIVATE DIALOG oDaialog CENTER
    oWizard:Destroy()

Return Nil

/*/{Protheus.doc} WizPage01
    Construção da primeira página do wizard, 
    página de boas vindas
    
    @author Sivaldo Oliveira
    @since 29/11/2022
    
    @param oPanel, Object, Objeto panel onde é exibido o texto de bem vindo.
/*/
Static Function WizPage01(oPanel As Object)
	Local oFont As Object
    
    //Parâmetros de entrada
    Default oPanel := Nil
    
    //Inicializa variáveis
	oFont := TFont():New(Nil, Nil, -25, .T., .T., Nil, Nil, Nil, Nil, Nil)
    
    //Texto de boas vindas da página de informações
    TSay():New(10, 15, {||(STR0073+STR0070)}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
    oFont:Bold    := .F.
    oFont:Italic  := .F.
    oFont:nHeight := -15
    
    TSay():New(35, 15, {||STR0074}, oPanel, Nil, oFont,   Nil, Nil, Nil, .T., CLR_BLUE, Nil)
	TSay():New(45, 15, {||(STR0075+STR0070)}, oPanel, Nil, oFont,   Nil, Nil, Nil, .T., CLR_BLUE, Nil)
	TSay():New(55, 15, {||STR0076}, oPanel, Nil, oFont,   Nil, Nil, Nil, .T., CLR_BLUE, Nil)
    FreeObj(oFont)
Return Nil

/*/{Protheus.doc} WizPage02
    Construção da segunda página do wizard página de seleção das contas bancárias.
    
    @author Sivaldo Oliveira
    @since 29/11/2022
    
    @param oDaialog,  Object, Objeto de interface visual.
    @param oPanel,    Object, Objeto panel onde é exibido o texto de bem vindo.
    @param oBrwCta,   Object, Instância da classe FWMarkBrowse para seleção de registros
    @param cBancoOfi, Char,   Código do sistema de operações monetárias e compensação de outros papéis.
    @param cTblTmp,   Char,   Nome do arquivo/Tabela temporária com a lista de contas bancárias
/*/
Static Function WizPage02(oDaialog As Object, oPanel As Object, oBrwCta As Object, cBancoOfi As Char, cTblTmp As Char)
    Local cMAEmpSA6 As Char
    Local cMAUniSA6 As Char
    Local cMAFilSA6 As Char
    Local nQtdCol   As Numeric
    Local nLinha    As Numeric
    Local nTamEmp   As Numeric
    Local nTamUni   As Numeric
    Local aStruct   As Array
    Local aColuna   As Array
    Local aFwSX3    As Array
    Local oFont     As Object
    
    //Parâmetros de entrada
    Default oDaialog  := Nil
    Default oPanel    := Nil
    Default oBrwCta   := Nil
    Default cBancoOfi := ""
    Default cTblTmp   := ""
    
    //Inicializa variáveis
    cMAEmpSA6 := ""
    cMAUniSA6 := ""
    cMAFilSA6 := ""
    nQtdCol   := 0
    nLinha    := 0
    nTamEmp   := 0
    nTamUni   := 0
    aStruct   := Nil
    aColuna   := Nil
    aFwSX3    := Nil
    oFont     := Nil
    
    If !Empty(cTblTmp := CtaBancPix(@__oBanco, cBancoOfi, @__oStrTmp))        
        aStruct   := {}
        aColuna   := {}        
        aFwSX3    := {}
        cMAEmpSA6 := AllTrim(FWModeAccess("SA6",1))
        cMAUniSA6 := AllTrim(FWModeAccess("SA6",2))
        cMAFilSA6 := AllTrim(FWModeAccess("SA6",3))
        nTamEmp   := Len(FwSM0Layout(,1))
        nTamUni   := Len(FwSM0Layout(,2))
        
        If (nTamEmp+nTamUni) == 0
            cMAEmpSA6 := cMAUniSA6 := cMAFilSA6
        ElseIf nTamEmp == 0
            cMAEmpSA6 := cMAUniSA6
        ElseIf nTamUni == 0 
            cMAUniSA6 := cMAFilSA6
        EndIf
        
        oFont := TFont():New(Nil, Nil, -25, .T., .T., Nil, Nil, Nil, Nil, Nil)
        TSay():New(10, 15, {||STR0077}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)    
        FreeObj(oFont)
        
        //Mostra o campo filial na MakBrowse apenas se a tabela de bancos (SA6) estiver exclusiva
        If ((cMAEmpSA6+cMAUniSA6+cMAFilSA6) == "EEE")
            If Len(aFwSX3 := FWSX3Util():GetFieldStruct("A6_FILIAL")) >= 4
                AAdd(aStruct, {"A6_FILIAL", STR0079, aFwSX3[3], aFwSX3[4], PesqPict("SA6","A6_FILIAL")})
                AAdd(aStruct, {"NOMEFIL", STR0080, Len(SM0->M0_FILIAL), 0, "@!"})
            EndIf
        EndIf
        
        If Len(aFwSX3 := FWSX3Util():GetFieldStruct("A6_COD")) >= 4
            AAdd(aStruct, {"A6_COD", STR0034, aFwSX3[3], aFwSX3[4], PesqPict("SA6","A6_COD")})
        EndIf
        
        If Len(aFwSX3 := FWSX3Util():GetFieldStruct("A6_AGENCIA")) >= 4
            AAdd(aStruct, {"A6_AGENCIA", STR0066, aFwSX3[3], aFwSX3[4], PesqPict("SA6","A6_AGENCIA")})
        EndIf
        
        If Len(aFwSX3 := FWSX3Util():GetFieldStruct("A6_NUMCON")) >= 4
            AAdd(aStruct, {"A6_NUMCON", STR0037, aFwSX3[3], aFwSX3[4], PesqPict("SA6","A6_NUMCON")})
        EndIf
        
        If Len(aFwSX3 := FWSX3Util():GetFieldStruct("A6_NOME")) >= 4
            AAdd(aStruct, {"A6_NOME", STR0078, aFwSX3[3], aFwSX3[4], PesqPict("SA6","A6_NOME")})
        EndIf
        
        If (nQtdCol := Len(aStruct)) > 0
            For nLinha := 1 To nQtdCol
                AAdd(aColuna, FWBrwColumn():New())
                aColuna[nLinha]:SetData( &("{||" + aStruct[nLinha,1] + "}") )
                aColuna[nLinha]:SetTitle(aStruct[nLinha, 2])
                aColuna[nLinha]:SetSize(aStruct[nLinha, 3])
                aColuna[nLinha]:SetDecimal(aStruct[nLinha, 4])
                aColuna[nLinha]:SetPicture(aStruct[nLinha,5])
            Next nLinha
            
            oBrwCta := FWMarkBrowse():New(oPanel)
            oBrwCta:SetAlias(cTblTmp)            
            oBrwCta:SetDescription(STR0082)            
            oBrwCta:SetTemporary(.T.)
            oBrwCta:SetOwner(oPanel)
            oBrwCta:SetFieldMark("OK")            
            oBrwCta:bMark    := {||MarcaConta(.F., cTblTmp, oBrwCta)}
            oBrwCta:bAllMark := {||MarcaConta(.T., cTblTmp, oBrwCta)}
            oBrwCta:AddLegend("STATUS == '1'", "GREEN",  STR0062)
            oBrwCta:AddLegend("STATUS == '2'", "YELLOW", STR0063)
            oBrwCta:AddLegend("Empty(STATUS)", "BLUE",   STR0081)
            oBrwCta:AddStatusColumns({||StatusWebH(cTblTmp) }, {||LedWebHook()})
            oBrwCta:SetColumns(aColuna)
            oBrwCta:oBrowse:aColumns[1]:cTitle := STR0121
            oBrwCta:oBrowse:aColumns[2]:cTitle := STR0122
            oBrwCta:SetProfileID("FINA893A")
            oBrwCta:SetMenuDef('FINA893A')
            oBrwCta:SetUseFilter(.T.)
            oBrwCta:Activate()
        EndIf
        
        FwFreeArray(aFwSX3)
        FwFreeArray(aStruct)
        FwFreeArray(aColuna)
    Else
        Help(" ", 1, "CTABANCATV", Nil, STR0109, 2, 0, Nil, Nil, Nil, Nil, Nil, {STR0110 + CRLF + STR0111})
        
        If oDaialog != Nil
            oDaialog:End()
            oDaialog := Nil
        EndIf       
    EndIf
Return Nil

/*/{Protheus.doc} WizPage03
    Construção da terceira página do wizard, página de input das credenciais de conexão.
    
    @author Sivaldo Oliveira
    @since 29/11/2022
    
    @param oPanel, Object, Objeto panel onde é exibido os inputs das credenciais de conexão
    @param cTblTmp,   Char,   Nome do arquivo/Tabela temporária com a lista de contas bancárias
/*/
Static Function WizPage03(oPanel As Object, cTblTmp As Char)
    Local oFont     As Object
    Local oRadio    As Object
    Local oSayLink  As Object
    Local oRadMulta As Object
    
    //Parâmetros de entrada
    Default oPanel  := Nil
    Default cTblTmp := ""
    
    //Inicializa variáveis
    oFont     := TFont():New(Nil, Nil, 18, .T., .T., Nil, Nil, Nil, Nil, Nil)
    oRadio    := Nil
    oSayLink  := Nil
    oRadMulta := Nil
    
    @00, 00  TO 45, 450 OF oPanel  PIXEL
    @00, 225 TO 45, 450 OF oPanel  PIXEL
    
    TSay():New(5, 015, {||STR0064}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
    TSay():New(5, 240, {||STR0132}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)    
    
    //Ambiente a ser configurado (Produção ou homologação)
    @20, 020 RADIO oRadio VAR __nRadio ITEMS STR0062, STR0063 3D SIZE 100, 12 OF oPanel PIXEL
    @20, 240 RADIO oRadMulta VAR __nRadMult ITEMS STR0133, STR0138 3D SIZE 100, 12 OF oPanel PIXEL
    oRadio:bChange := {||BtnLimpa(oPanel)}
    
    //Input das credenciais de conexão
    TSay():New(50, 15, {||STR0061}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)    
    oFont:Bold    := .F.
    oFont:nHeight := -15
    
    TSay():New(70, 20, {||STR0065 + " " + STR0066 + ": " + (cTblTmp)->A6_AGENCIA + ", " + STR0037 + ": " + (cTblTmp)->A6_NUMCON}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)   
    
    oSayLink := TSay():New(90, 110, {||STR0083 + " | " + STR0084}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_RED, Nil)
    oSayLink:blClicked := {||shellExecute("Open", STR0083, "", "", 1)}    
    
    oFont:Bold    := .F.
    oFont:nHeight := 10
    
    //Client_Id
    TMultiGet():New(110, 20, {|u|If(PCount() > 0, __cClienId := u, __cClienId)},  oPanel, 400, 012, Nil, Nil, Nil, Nil, Nil, .T., Nil, .T., Nil, .F., Nil, .F., Nil, Nil, .F., .F., .F., STR0058, 1, oFont, CLR_BLUE)    
        
    //Client_Secret
    TMultiGet():New(135, 20, {|u| If(PCount() > 0, __cClienSe := u, __cClienSe)}, oPanel, 400, 012, Nil, Nil, Nil, Nil, Nil, .T., Nil, .T., Nil, .F., Nil, .F., Nil, Nil, .F., .F., .F., STR0059, 1, oFont, CLR_BLUE)
    
    //Application_Key
    TMultiGet():New(162, 20, {|u| If(PCount() > 0, __cAppKey := u, __cAppKey)},    oPanel, 400, 012, Nil, Nil, Nil, Nil, Nil, .T., Nil, .T., Nil, .F., Nil, .F., Nil, Nil, .F., .F., .F., STR0060, 1, oFont, CLR_BLUE)
    
    //Valor / Percentual de Multa
    oFont:nHeight := 15
    TGet():Create(oPanel, {|u| If(PCount() > 0, __nVlMulta := u, __nVlMulta)}, 017, 375, 070, 012, PesqPict("SE1","E1_MULTA"), {||.T.}, Nil, Nil,;
    oFont, Nil, Nil, .T., Nil, Nil, {||.T.}, Nil, Nil, {||VldModMult()}, .F., .F., Nil, "", Nil, Nil, Nil, Nil, Nil, Nil, STR0139 ,1, Nil, CLR_BLUE)
    
    FreeObj(oFont)
Return Nil

/*/{Protheus.doc} WizPage04
    Construção da quarta página do wizard, página de input das informações do certificado.
    
    @author Victor Azevedo
    @since 18/01/2023
    
    @param oPanel,  Object, Objeto panel onde é exibido o input da url de callback
    @param cTblTmp, Char,   Nome do arquivo/Tabela temporária com a lista de contas bancárias
/*/
Static Function WizPage04(oPanel As Object, cTblTmp As Char)
    
    Local oFont    As Object
    Local oRadio   As Object
    Local oSayLink As Object
    Local oJson    As Object
    
    //Parâmetros de entrada
    Default oPanel  := Nil
    Default cTblTmp := ""
   
    //Inicializa variáveis
    oFont    := TFont():New(Nil, Nil, -25, .T., .T., Nil, Nil, Nil, Nil, Nil)
    oRadio   := Nil
    oSayLink := Nil
    
    //Configuração do certificado
    TSay():New(7, 15, {||STR0123}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)    
    oFont:Bold    := .F.
    oFont:nHeight := -15
    
    TSay():New(40, 15, {||STR0124}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)   
    
    //Arquivo Chave do Certificado
    TMultiGet():New(60, 20, {|u|If(PCount() > 0, __cKeyCert := u, __cKeyCert)},  oPanel, 400, 012, Nil, Nil, Nil, Nil, Nil, .T., Nil, .T., Nil, .F., Nil, __lReadOn, Nil, Nil, .F., .F., .F., STR0125, 1, oFont, CLR_BLUE)
        
    //Arquivo do Certificado
    TMultiGet():New(90, 20, {|u| If(PCount() > 0, __cCert := u, __cCert)}, oPanel, 400, 012, Nil, Nil, Nil, Nil, Nil, .T., Nil, .T., Nil, .F., Nil, __lReadOn, Nil, Nil, .F., .F., .F., STR0126, 1, oFont, CLR_BLUE)

    oSayLink := TSay():New(120, 100, {||STR0083 + " | " + STR0084}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_RED, Nil)
    oSayLink:blClicked := {||shellExecute("Open", STR0083, "", "", 1)}   

    FreeObj(oJson) 
    
Return Nil

/*/{Protheus.doc} WizPage05
    Construção da quinta página do wizard, página de input da url de callback.
    
    @author Sivaldo Oliveira
    @since 29/11/2022
    
    @param oPanel,  Object, Objeto panel onde é exibido o input da url de callback
    @param cTblTmp, Char,   Nome do arquivo/Tabela temporária com a lista de contas bancárias
/*/
Static Function WizPage05(oPanel As Object, cTblTmp As Char)
    Local oFont    As Object   
    Local oSayWebH As Object
    
    //Parâmetros de entrada
    Default oPanel  := Nil
    Default cTblTmp := ""
    
    //Inicializa variáveis
    oFont    := TFont():New(Nil, Nil, -25, .T., .T., Nil, Nil, Nil, Nil, Nil)
    oSayWebH := Nil
    
    TSay():New(10, 15, {||STR0098}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
    oFont:Bold    := .F.
    oFont:nHeight := -15
    
    TSay():New(35, 15, {||STR0099}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
    TSay():New(45, 15, {||STR0100 + STR0070 + STR0101+STR0066 + " " + (cTblTmp)->A6_AGENCIA + ", " + STR0037 + " " + (cTblTmp)->A6_NUMCON}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
       
    oSayWebH := TSay():New(75, 30, {||STR0097 + " | " + STR0084}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_RED, Nil)
    oSayWebH:blClicked := {||shellExecute("Open", STR0097, "", "", 1)}
    
    oFont:nHeight := 10    
    TMultiGet():New(100, 15, {|u| If(PCount() > 0, __cUrlWebH := u, __cUrlWebH)}, oPanel, 400, 012, Nil, Nil, Nil, Nil, Nil, .T., Nil, .T., Nil, .F., Nil, .F., Nil, Nil, .F., .F., .F., STR0102, 1, oFont, CLR_BLUE)
    FreeObj(oFont)

Return Nil

/*/{Protheus.doc} WizPage06
    Construção da sexta página do wizard, página de conclusão do processo
    
    @author Sivaldo Oliveira
    @since 08/12/2022
    
    @param oPanel, Object, Objeto panel onde é exibido o label de processo concluído
/*/
Static Function WizPage06(oPanel)
    Local oFont  As Object
    
    //Parâmetros de entrada
    Default oPanel  := Nil    
    
    //Inicializa variáveis
    oFont  := TFont():New(Nil, Nil, -25, .T., .T., Nil, Nil, Nil, Nil, Nil)    
    TSay():New(10, 15, {||STR0096}, oPanel, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)

Return Nil

/*/{Protheus.doc} ValidaPag2
    Função responsável por validar se há alguma conta bancária selecionada.
    
    @author Sivaldo Oliveira
    @since 29/11/2022
    
    @param  oPanel,  Object, Objeto panel onde são exibidas as contas bancárias
    @param  oBrwCta, Object, Instância da classe FWMarkBrowse para seleção de registros
    @param  cTblTmp, Char,   Nome do arquivo/Tabela temporária com a lista de contas bancárias
    @return lRet,    Logical, Retorna um valor lógico, verdadeir ou falso, que indica 
    que há registro na tabela temporária.
/*/
Static Function ValidaPag2(oPanel As Object, oBrwCta As Object, cTblTmp As Char) As Logical
    Local lRet     As Logical
    Local cMarca   As Char
    Local aAreaAtu As Array
    
    //Parâmetros de entrada
    Default oPanel  := Nil
    Default oBrwCta := Nil
    Default cTblTmp := ""
    
    //Inicializa variáveis.
    lRet     := !(__nQtdMark <= 0)
    cMarca   := ""
    aAreaAtu := Nil
    
    If lRet        
        aAreaAtu := GetArea()
        cMarca   := oBrwCta:cMark
        
        DbSelectArea("SA6")
        RestArea(aAreaAtu)
        FwFreeArray(aAreaAtu)        
        (cTblTmp)->(DbSetOrder(1))        
        
        If (lRet := (cTblTmp)->(DbSeek(cMarca)))
            SA6->(DbGoTo((cTblTmp)->A6RECNO))
            BtnLimpa()
            
            If !Empty(SA6->A6_CFGPIX)
                CredencCta()                 
            EndIf
        EndIf    
    Else
        BtnLimpa()       
        Help(" ", 1, "NOCONTAS", Nil, STR0085, 2, 0, Nil, Nil, Nil, Nil, Nil, {STR0086})
    EndIf
Return lRet

/*/{Protheus.doc} MarcaConta
    Função responsável por marcar/selecionar uma (n) conta (s) para configurar.
    
    @author Sivaldo Oliveira
    @since 29/11/2022
    
    @param lMarcaAll, Logical, Indica se a marcação/seleção será apenas da linha posicionada 
    ou de toda as contas.
    @param cTblTmp, Char,   Nome do arquivo/Tabela temporária com a lista de contas bancárias
    @param oBrwCta, Object, Instância da classe FWMarkBrowse para seleção de registros    
/*/
Static Function MarcaConta(lMarcaAll As Logical, cTblTmp As Char, oBrwCta)
    Local nRecno As Numeric
    Local cMarca As Char
    
    //Parâmetros de entrada.
    Default lMarcaAll := .F.
    Default cTblTmp   := ""
    Default oBrwCta   := Nil    
    
    If oBrwCta != Nil .And. !Empty(cTblTmp)
        //Inicializa variáveis
        nRecno := (cTblTmp)->(Recno())
        cMarca := oBrwCta:cMark     
        
        If lMarcaAll
            (cTblTmp)->(DbGotop())
            (cTblTmp)->(DbSetOrder(0))
        EndIf
        
        While (cTblTmp)->(!Eof())        
            If (cTblTmp)->(MsRLock())
                If lMarcaAll 
                    If oBrwCta:IsMark()
                        (cTblTmp)->OK := " "
                    Else
                        (cTblTmp)->OK := cMarca
                    EndIf
                    (cTblTmp)->(MsUnlock())
                EndIf
                
                If (cTblTmp)->OK == cMarca
                    __nQtdMark += 1
                Else
                    __nQtdMark -= 1
                EndIf
            EndIf
            
            If !lMarcaAll
                exit
            EndIf
            
            (cTblTmp)->(DbSkip())
        EndDo
        
        (cTblTmp)->(DbSetOrder(1))
        (cTblTmp)->(DbGoto(nRecno))        
        
        If lMarcaAll
            oBrwCta:Obrowse:Refresh()
        EndIf
    EndIf
Return Nil

/*/{Protheus.doc} BtnGrava
    Função responsável por gravar as credenciais da comunicação bancária
    
    @author Sivaldo Oliveira
    @since 29/11/2022
    
    @param oDaialog,  Object, Objeto de interface visual.
    @param oBrwCta,   Object, Instância da classe FWMarkBrowse para seleção de registros
    @param oPanel,    Object, Objeto panel onde é exibido o texto de bem vindo.    
    @param cBancoOfi, Char,   Código do sistema de operações monetárias e compensação de outros papéis.
    @param cTblTmp,   Char,   Nome do arquivo/Tabela temporária com a lista de contas bancárias
    @return lRetorno, Logical, Retorna um valor lógico, verdadeir ou falso.
/*/
Static Function BtnGrava(oDaialog As Object, oBrwCta As Object, oPanel As Object, cBancoOfi As Char, cTblTmp As Char) As Logical
    Local lRetorno  As Logical
    Local lExclusao As Logical
    Local cMarca    As Char
    Local cJSon     As Char
    Local cUrlWebH  As Char
    Local cKeyCert  As Char
    Local cCert     As Char
    Local oToken    As Object
    Local oJSon     As Json
    Local oJSonBco  As JSon
    
    //Parâmetros de entrada
    Default oDaialog  := Nil 
    Default oBrwCta   := Nil
    Default oPanel    := Nil
    Default cBancoOfi := ""
    Default cTblTmp   := ""
    
    //Inicializa variáveis    
    __cClienId := RemLnEmpty(__cClienId)
    __cClienSe := RemLnEmpty(__cClienSe)
    __cAppKey  := RemLnEmpty(__cAppKey)
    lRetorno   := (!Empty(__cClienId) .And. !Empty(__cClienSe) .And. !Empty(__cAppKey))
    lExclusao  := .F.
    cMarca     := ""
    cJSon      := ""
    cUrlWebH   := ""
    cKeyCert   := ""
    cCert      := ""
    oToken     := Nil
    oJSon      := Nil
    oJSonBco   := Nil
    
    If !lRetorno
        If Empty((cTblTmp)->STATUS)
            If Empty(__cClienId)
                Help(" ", 1, "CLIENTID", Nil, STR0087, 2, 0, Nil, Nil, Nil, Nil, Nil, {""})
            ElseIf Empty(__cClienSe)
                Help(" ", 1, "CLIESECRET", Nil, STR0088, 2, 0, Nil, Nil, Nil, Nil, Nil, {""})
            Else
                Help(" ", 1, "APPKEY", Nil, STR0089, 2, 0, Nil, Nil, Nil, Nil, Nil, {""})
            EndIf
        Else
            lExclusao := .T.
            lRetorno  := MsgYesNo(STR0090, STR0068) 
        EndIf
    EndIf
    
    If lRetorno
        If (Empty((cTblTmp)->STATUS) .Or. (!Empty((cTblTmp)->STATUS) .And. !lExclusao))
            oJSon    := EnvConnPix(__nRadio, cBancoOfi, "token", __cClienId, __cClienSe, "")
            oToken   := Token():New(oJSon["urlbase"], oJSon["path"], "", oJSon["grantype"], oJSon["header"])
            lRetorno := !Empty(oToken:GetToken()) .And. oToken:GetGerouTk()
        EndIf
        
        If lRetorno
            If !__lIsBlind .And. !lExclusao
                MsgAlert(STR0030 + "..: " + oJSon["urlbase"], STR0068)
            EndIf
            
            If oDaialog != Nil .And. oBrwCta != Nil .And. !Empty(cTblTmp)
                cMarca := oBrwCta:cMark
                SA6->(DbGoTo((cTblTmp)->A6RECNO))
                
                While (cTblTmp)->(!Eof()) .And. __nLoop <= __nQtdMark .And. (cTblTmp)->OK == cMarca
                    cJSon := ""                    
                    
                    If !lExclusao
                        If !Empty(SA6->A6_CFGPIX)
                            oJSonBco := JsonObject():New()
                            oJSonBco:FromJson(SA6->A6_CFGPIX)
                            cUrlWebH  := AllTrim(oJSonBco["urlwebhook"])
                            cKeyCert  := AllTrim(oJsonBco["keycertificado"])
                            cCert     := AllTrim(oJSonBco["certificado"])
                            FreeObj(oJSonBco)
                        EndIf
                        
                        cJSon := "{"
                        cJSon += '"enviroment": ' + cValToChar(__nRadio)
                        cJSon += ',"clientid": "' + AllTrim(__cClienId) + '"'
                        cJSon += ',"clientsecret": "' + AllTrim(__cClienSe) + '"'
                        cJSon += ',"appkey": "' + AllTrim(__cAppKey) + '"'
                        cJSon += ',"keycertificado": "' + AllTrim(cKeyCert) + '"'
                        cJSon += ',"certificado": "' + AllTrim(cCert) + '"'
                        cJSon += ',"urlwebhook": "' + AllTrim(cUrlWebH) + '"'
                        cJSon += ',"modalidademulta": ' + cValToChar(__nRadMult)
                        cJSon += ',"valordamulta": ' + cValToChar(__nVlMulta)
                        cJSon += "}"
                       
                       If __nRadio == 1
                           __lReadOn  := .F.
                           If Empty(__cKeyCert)  .And. Empty(__cCert)
                                __cKeyCert := cKeyCert
                                __cCert    := cCert
                           EndIf
                       EndIf
                    EndIf
                    
                    Begin Transaction
                        If SA6->(MsRLock())
                            SA6->A6_CFGPIX := cJSon
                            SA6->(MsUnlock())
                        EndIf
                    End Transaction
                    
                    (cTblTmp)->(DbSkip())
                    BtnLimpa(oPanel)
                    __nLoop += 1
                    
                    If !(lRetorno := (__nLoop > __nQtdMark))
                        SA6->(DbGoTo((cTblTmp)->A6RECNO))
                        CredencCta()
                    EndIf
                    
                    Exit                        
                EndDo
            EndIf
            
            If lRetorno
                __nLoop := 1
                (cTblTmp)->(DbGotop())
                (cTblTmp)->(DbSeek(cMarca))
                SA6->(DbGoTo((cTblTmp)->A6RECNO))
                
                If !Empty(SA6->A6_CFGPIX) 
                    CredencCta(.T.)
                EndIf                 
            EndIf
        ElseIf oToken != Nil
            Help(" ", 1, "APINOCONN", Nil, STR0028 + oJSon["urlbase"] + CRLF + CRLF + "Erro: " + oToken:GetErro(), 2, 0, Nil, Nil, Nil, Nil, Nil, {""})
        EndIf    
        
        If oJSon != Nil        
            FreeObj(oJSon)
        EndIf
    EndIf
Return lRetorno

/*/{Protheus.doc} BtnLimpa
    Limpa as credenciais de conexão quando mudar de ambiente a ser configurado (radio buttom)
    
    @author Sivaldo Oliveira
    @since 29/11/2022
    
    @Param oPanel, Object, Container onde estão todos os componentes visual
/*/
Static Function BtnLimpa(oPanel As Object)    
    //Parâmetros de entrada.
    Default oPanel := Nil 
    
    __cUrlWebH := ""
    __cClienId := ""
    __cClienSe := ""
    __cAppKey  := ""    
    
    If oPanel != Nil
        oPanel:Refresh()
    EndIf
Return Nil

/*/{Protheus.doc} BtnCancela
    Cancelar a configuração da comunicação 
    bancária e fechar o wizard.
    
    @author Sivaldo Oliveira
    @since 29/11/2022
    
    @Param oDaialog, Object, Objeto daialog (janela) 
    @Return lRetorno, Logical, Verdadeiro ou Falso
    que indica se confirmou ou não o cancelamento.    
/*/
Static Function BtnCancela(oDaialog) As Logical
    Local lRetorno As Logical
    
    //Parâmetros de entrada
    Default oDaialog := Nil    
    
    //Inicializa variáveis.
    lRetorno := MsgYesNo(STR0067, STR0068)
    
    If lRetorno .And. oDaialog != Nil
        oDaialog:End()
        oDaialog := Nil
    EndIf
Return lRetorno

/*/{Protheus.doc} GrvCert
    Grava os caminhos do certificado no campo A6_CFGPIX 
    
    @author Victor Azevedo
    @since 18/01/2023
    
    @param oDaialog,  Object, Objeto de interface visual.
    @param oBrwCta,   Object, Instância da classe FWMarkBrowse para seleção de registros
    @param cTblTmp,   Char,   Nome do arquivo/Tabela temporária com a lista de contas bancárias
    @return lRetorno, Logical, Retorna um valor lógico, verdadeir ou falso.    
/*/
Static Function GrvCert(oDaialog As Object, oBrwCta As Object, cTblTmp As Char) As Logical

    Local lRetorno   As Logical
    Local lRet       As Logical
    Local lExclusao  As Logical
    Local cMarca     As Char
    Local cJSon      As Char
    Local cKeyCert   As Char
    Local cCert      As Char
    Local cCertifica As Char
    Local cCertKey   As Char
    Local nTamKey    As Numeric
    Local nTamCert   As Numeric
    Local oJSon      As JSon

    //Parâmetros de entrada.
    Default oDaialog := Nil
    Default oBrwCta  := Nil
    Default cTblTmp  := ""
    
    //Inicializa variáveis.
    lRetorno   := .T.
    lRet       := .T.
    lExclusao  := .F.
    cMarca     := ""
    cJSon      := ""
    cKeyCert   := RemLnEmpty(__cKeyCert)
    cCert      := RemLnEmpty(__cCert)
    cCertifica := ""
    cCertKey   := ""
    nTamKey    := Len(cKeyCert)
    nTamCert   := Len(cCert)
    oJSon      := Nil
            
    oJSon := JsonObject():New()
    oJSon:FromJson(SA6->A6_CFGPIX)
    
    If oJson["enviroment"] == 1 .And. ((Empty(cKeyCert) .And. !Empty(oJSon["keycertificado"])) .And. (Empty(cCert) .And. !Empty(oJSon["certificado"])))
        lRetorno  := MsgYesNo(STR0131, STR0068)
        lExclusao := lRetorno
    EndIf
    
    If !lExclusao .And. oJSon["enviroment"] == 1 .And. (Empty(cKeyCert) .Or. Empty(cCert))
        Help(" ", 1, "KEYCERT", Nil, STR0127, 2, 0, Nil, Nil, Nil, Nil, Nil, {""})
        lRetorno    := .F.
    EndIf

    If lRetorno .And. !lExclusao .And. (!Empty(cKeyCert) .And. !Empty(cCert))
        If !(lRetorno := !(("/" $ cKeyCert .Or. "\" $ cKeyCert) .Or. ("/" $ cCert .Or. "\" $ cCert))) 
            Help(" ", 1, "URLCERT", Nil, STR0128, 2, 0, Nil, Nil, Nil, Nil, Nil, {""})
        EndIf

        If lRetorno
            If (AT( ".", cKeyCert ) == 0 .Or. AT( ".", cCert ) == 0 )
                lRet := .F.
            ElseIf (AT( ".pem", cKeycert ) == 0 .Or. AT( ".pem", cCert ) == 0) 
                lRet := .F.
            ElseIf (Substr(cKeyCert, (nTamKey - 3)) <> ".pem" .Or. Substr(cCert, (nTamCert - 3)) <> ".pem")
                lRet := .F.            
            EndIf 
        EndIf
        
        If !lRet
            Help(" ", 1, "EXTCERT", Nil, STR0129, 2, 0, Nil, Nil, Nil, Nil, Nil, {""})
            lRetorno := .F.
        EndIf
    EndIf
        
    If lRetorno .And. oDaialog != Nil .And. oBrwCta != Nil .And. !Empty(cTblTmp)
        cMarca := oBrwCta:cMark
        
        While (cTblTmp)->(!Eof()) .And. lRetorno .And. __nLoop <= __nQtdMark .And. (cTblTmp)->OK == cMarca

            cJson := ""
            
            SA6->(DbGoTo((cTblTmp)->A6RECNO))
            
            Begin Transaction
                oJSon := JsonObject():New()
                oJSon:FromJson(SA6->A6_CFGPIX)
                If !Empty(SA6->A6_CFGPIX) 
                    If lExclusao
                        oJson["keycertificado"] := ""
                        oJson["certificado"]    := ""
                    ElseIf !lExclusao .And. oJson["enviroment"] == 1
                        oJson["keycertificado"] := cKeyCert
                        oJson["certificado"]    := cCert
                    EndIf
                EndIf

                cJson   := oJson:ToJson()
                
                If SA6->(MsRLock())
                    SA6->A6_CFGPIX := cJSon
                    SA6->(MsUnlock())
                EndIf
            End Transaction            
    
            If !Empty(SA6->A6_CFGPIX)                 
                CredencCta(.T.)
            EndIf

            __nLoop    += 1
            (cTblTmp)->(DbSkip())
        EndDo        
    EndIf

    __nLoop := 1

    (cTblTmp)->(DbGotop())
    (cTblTmp)->(DbSeek(cMarca))
    SA6->(DbGoTo((cTblTmp)->A6RECNO))
    If !Empty(SA6->A6_CFGPIX)                 
        CredencCta(.T.)
    EndIf

    If oJSon != Nil
        FreeObj(oJSon)
    EndIf   

Return lRetorno

/*/{Protheus.doc} GrvWebHook
    Grava o endereço(Url) de callback do webhook.
    
    @author Sivaldo Oliveira
    @since 07/12/2022
    
    @param oDaialog,  Object, Objeto de interface visual.
    @param oBrwCta,   Object, Instância da classe FWMarkBrowse para seleção de registros
    @param cTblTmp,   Char,   Nome do arquivo/Tabela temporária com a lista de contas bancárias
    @return lRetorno, Logical, Retorna um valor lógico, verdadeir ou falso.    
/*/
Static Function GrvWebHook(oDaialog As Object, oBrwCta As Object, cTblTmp As Char) As Logical
    Local lRetorno      As Logical
    Local lExclusao     As Logical
    Local cMarca        As Char
    Local cJSon         As Char
    Local cBody         As Char
    Local cUrlWebH      As Char
    Local cErro         As Char
    Local cCertifica    As Char
    Local cCertiKey     As Char
    Local cHttpsQuot    As Char 
    Local cResult       As Char 
    Local cUrlBase      As Char      
    Local cPath         As Char 
    Local cAppKey       As Char 
    Local cHeader       As Char
    Local cToken        As Char
    Local cMsgError     As Char
    Local nTamUrl       As Numeric
    Local nHttpCode     As Numeric
    Local aHeader       As Array
    Local oJSon         As JSon
    Local oJsonWebH     As JSon
    Local oJSonErro     As JSon
    Local oJsonPix      As JSon
   
    //Parâmetros de entrada.
    Default oDaialog := Nil
    Default oBrwCta  := Nil
    Default cTblTmp  := ""
    
    //Inicializa variáveis.
    lRetorno    := .T.
    lExclusao   := .F.
    cMarca      := ""
    cJSon       := ""
    cBody       := ""
    cCertifica  := ""
    cCertiKey   := ""
    cHttpsQuot  := ""
    cResult     := ""
    cUrlBase    := ""       
    cPath       := ""  
    cAppKey     := ""  
    cHeader     := "" 
    cToken      := ""
    cMsgError   := ""
    cUrlWebH    := RemLnEmpty(__cUrlWebH)
    cErro       := ""
    nTamUrl     := 0
    nHttpCode   := 0 
    aHeader     := {}
    oJSon       := Nil
    oJsonWebH   := Nil
    oJSonErro   := Nil
    oJsonPix    := Nil

    If !Empty(SA6->A6_CFGPIX)
        oJSon := JsonObject():New()
        oJSon:FromJson(SA6->A6_CFGPIX)
        
        If Empty(cUrlWebH) .And. !Empty(oJSon["urlwebhook"])
            lRetorno  := MsgYesNo(STR0091, STR0068)
            lExclusao := lRetorno 
        EndIf
    EndIf

    If !lExclusao .And. !Empty(cUrlWebH)
        If !(lRetorno := !(SubStr(cUrlWebH, 1, 8) != "https://"))
            Help(" ", 1, "URLWEBHOOK", Nil, STR0092, 2, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Else
            nTamUrl := len(cUrlWebH)
            
            If SubStr(cUrlWebH, nTamUrl, 1) == "/"
                cUrlWebH := SubStr(cUrlWebH, 1, (nTamUrl - 1))
            EndIf
            
            If !"api/fin/v1/bb/pix/receivables" $ cUrlWebH
                cUrlWebH += "/api/fin/v1/bb/pix/receivables"
            EndIf
            
            cUrlWebH += "/"
        EndIf
    EndIf
        
    If lRetorno .And. oDaialog != Nil .And. oBrwCta != Nil .And. !Empty(cTblTmp)
        cMarca := oBrwCta:cMark
        
        While (cTblTmp)->(!Eof()) .And. lRetorno .And. __nLoop <= __nQtdMark .And. (cTblTmp)->OK == cMarca
            If !Empty(SA6->A6_CFGPIX)            
        
                oJson["keycertificado"] := __cKeyCert
                oJson["certificado"]    := __cCert
                oJson["urlwebhook"]     := AllTrim(cUrlWebH)

                cJson   := oJson:ToJson()

                If lExclusao
                    Begin Transaction
                        If SA6->(MsRLock())
                            SA6->A6_CFGPIX := cJSon
                            SA6->(MsUnlock())
                        EndIf
                    End Transaction                
                ElseIf !Empty(AllTrim(cUrlWebH)) .And. !__lIsBlind
                    oJsonWebH := EnvConnPix(oJSon["enviroment"], "001", "token", oJSon["clientid"], oJSon["clientsecret"], "")
                    oToken   := Token():New(oJsonWebH["urlbase"], oJsonWebH["path"], "", oJsonWebH["grantype"], oJsonWebH["header"])
                    oToken:GetToken()
                    
                    FreeObj(oJsonWebH)
                    
                    If oToken:GetGerouTk()
                        cToken := oToken:GetToken()

                        cBody := "{"
                        cBody += '"webhookUrl": "' + cUrlWebH + '"'
                        cBody += "}"

                        oJsonPix:= EnvConnPix(oJSon["enviroment"], "001", "pix", oJSon["clientid"], oJSon["clientsecret"], AllTrim(oJSon["appkey"]), .F.)

                        oJsonPix["path"] := "/pix/v2/webhook/" + AllTrim((cTblTmp)->F70_CHVPIX)
                        oJsonPix["header"][3] += cToken

                        If oJSon["enviroment"] == 1
                            F892Certif(oJSon, @cCertifica, @cCertiKey)
                        EndIf

                        cUrlBase := oJsonPix["urlbase"]
                        cPath    := oJsonPix["path"]
                        cAppKey  := AllTrim(oJsonPix["appkey"])
                        cHeader  := oJsonPix["header"]

                        cHttpsQuot := 'HTTPSQuote(cUrlBase+cPath+cAppKey, cCertifica, cCertiKey, "", "PUT", "", cBody, 120, cHeader, Nil, .F.)' 
                        cResult    := &cHttpsQuot
                        nHttpCode  := HTTPGetStatus(Nil, Nil)
                        
                        If (nHttpCode == 200)
                            Begin Transaction
                                If SA6->(MsRLock())
                                    SA6->A6_CFGPIX := cJSon
                                    SA6->(MsUnlock())
                                EndIf
                            End Transaction
                        Else 
                            If cResult != Nil .And. ValType(cResult) == "C" .And. !Empty(cResult) 
                                cMsgError := DecodeUTF8(cResult)
                            EndIf 

                            Help(" ", 1, "CADURLWEBH", Nil, STR0093 + CRLF + CRLF + cUrlWebH  + CRLF + CRLF + STR0094 + STR0070 + CRLF + CRLF + STR0095 + CRLF + CRLF + cMsgError, 2, 0, Nil, Nil, Nil, Nil, Nil, {""})
                        EndIf
                    EndIf
                EndIf
            EndIf
            
            __cUrlWebH := ""
            __nLoop += 1            
            (cTblTmp)->(DbSkip())
            
            If !(lRetorno := (__nLoop > __nQtdMark))
                SA6->(DbGoTo((cTblTmp)->A6RECNO))
                
                If !Empty(SA6->A6_CFGPIX)                 
                    CredencCta(.T.)
                EndIf
            EndIf           
            
            Exit
        EndDo        
    EndIf

    If oJSon != Nil
        FreeObj(oJSon)
    EndIf
    
    If oJsonPix != Nil
        FreeObj(oJsonPix)
    EndIf

Return lRetorno

/*/{Protheus.doc} CredencCta
    Carrega as credenciais de conexão da conta    
    
    @author Sivaldo Oliveira
    @since 29/11/2022

    @param lPagWebH, Logical, Indica se a chamada foi realizada da página de 
    cadastro do webhook. 
/*/
Static Function CredencCta(lPagWebH As Logical)     
    Local oJSon   As Json
    Local cResult As Char
    
    //Parâmetros de entrada.
    Default lPagWebH := .F.
    
    //Inicializa variáveis    
    oJSon      := JsonObject():New()
    cResult    := ""
    __nRadMult := 1
    __nVlMulta := 0.00     
    
    //Carga do objeto oJSon
    If !Empty(SA6->A6_CFGPIX) .And.  ValType(cResult := oJSon:FromJson(SA6->A6_CFGPIX)) == "U"
        If lPagWebH
            __cUrlWebH := AllTrim(oJSon["urlwebhook"])
        Else
            __nRadio   := oJSon["enviroment"]
            __cClienId := oJSon["clientid"] 
            __cClienSe := oJSon["clientsecret"] 
            __cAppKey  := oJSon["appkey"]
            
            If oJSon:Hasproperty("modalidademulta") .And. oJSon:Hasproperty("valordamulta")
                __nRadMult := oJSon["modalidademulta"]
                __nVlMulta := oJSon["valordamulta"]
            EndIf        
        EndIf
    Else
        If lPagWebH
            __cUrlWebH := ""
        Else
            __nRadio   := 2
            __cClienId := ""
            __cClienSe := ""
            __cAppKey  := ""
        EndIf    
    EndIf    
    FreeObj(oJSon)
Return Nil

/*/{Protheus.doc} RemLnEmpty
    Remove linhas e espaços vazios de campo multiget
    
    @author Sivaldo Oliveira
    @since 07/02/2023
    
    @return cTexto, Char, Retorna um texto sem as alinha e espaços vazios.
/*/
Static Function RemLnEmpty(cString As Char) As Char
    Local cCaracter As Char
    Local cTexto    As Char    
    Local cCHR10    As Char
    Local cCHR13    As Char
    Local cCHR1310  As Char
    Local nPosicao  As Numeric
    Local nTamanho  As Numeric    
    
    //Parâmetros de entrada.
    Default cString := ""
    
    //Inicializa variáveis.
    cCaracter := ""
    cTexto    := ""
    cCHR10    := ""
    cCHR13    := ""
    cCHR1310  := ""
    nPosicao  := 0
    nTamanho  := Len(AllTrim(cString))
    
    If nTamanho > 0
        cString  := AllTrim(cString)
        cCHR10   := CHR(10)
        cCHR13   := CHR(13)
        cCHR1310 := (CHR(13)+CHR(10))
        
        For nPosicao := 1 To nTamanho
            cCaracter := SubStr(cString, nPosicao, 1)
            
            If (Empty(cCaracter) .Or. (cCaracter == cCHR10) .Or. (cCaracter == cCHR13) .Or. (cCaracter == cCHR1310))
                Loop
            EndIf
            
            cTexto += cCaracter
        Next nPosicao
    EndIf
    
    cTexto := AllTrim(cTexto)
Return cTexto

/*/{Protheus.doc} StatusWebH
    Define a legenda do cadastro de endereço (url) do webhook
    
    @author Sivaldo Oliveira
    @since 03/12/2022
    
    @param cTblTmp,   Char,   Nome do arquivo/Tabela temporária com a lista de contas bancárias
    @return cLegenda, Char, Cor da legenda
/*/
Static Function StatusWebH(cTblTmp As Char) As Char
    Local cLegenda As Char
    
    //Parâmetros de entrada
    Default cTblTmp := ""
    
    //Inicializa variáveis.
    cLegenda := "BR_VERDE"
    
    If !Empty(cTblTmp) .And. (cTblTmp)->WHOOK != "1"
        cLegenda := "BR_VERMELHO"
    EndIf
Return cLegenda

/*/{Protheus.doc} LedWebHook
    Cria o objeto oLegenda com as cores verde e vermela que mostra se o 
    webhook está cadastro ou não para a conta bancária
    
    @author Sivaldo Oliveira
    @since 03/12/2022
/*/
Static Function LedWebHook()
    Local oLegenda As Object
    
    //Inicializa variáveis.
    oLegenda := FWLegend():New()    
    
    oLegenda:Add("", "BR_VERDE",    STR0112)
    oLegenda:Add("", "BR_VERMELHO", STR0113)
    
    oLegenda:Activate()
    oLegenda:View()
    oLegenda:DeActivate()
Return Nil

/*/{Protheus.doc} VldModMult
    Valida se foi digigitado um valor inteiro maior ou igual a 0.
    Caso seja digitado um valor negativo, seta o valor 0.
    Caso seja configurado percentual, e o valor seja maior
    100, seta o valor de 100.
    
    @author Sivaldo Oliveira
    @since 28/02/2023
/*/
Static Function VldModMult()
    If __nVlMulta < 0
        __nVlMulta := 0.00
    ElseIf __nVlMulta > 100 .And. __nRadMult == 2
        __nVlMulta := 100.00
    EndIf
Return .T.

/*/{Protheus.doc} InicStatic
    Inicializa as variáveis 
    estáticas.
    
    @author Sivaldo Oliveira
    @since  @since 29/11/2022
/*/
Static Function InicStatic()
    
    If __lIsBlind == Nil 
        __lIsBlind := IsBlind()
    EndIf    
    
    __cClienId := ""
    __cClienSe := ""
    __cAppKey  := ""
    __cUrlWebH := ""
    __cKeyCert := ""
    __cCert    := ""
    __nRadio   := 2    
    __lReadOn  := .T.
    __nQtdMark := 0
    __nLoop    := 1
    __oBanco   := Nil
    __oStrTmp  := Nil
    __nRadMult := 1
    __nVlMulta := 0.00
Return Nil

