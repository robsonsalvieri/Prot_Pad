#Include "Protheus.ch"
#Include "ApWizard.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#include "TbIconn.ch" 
#include "FILEIO.CH"
#include "FWEVENTVIEWCONSTS.CH"

Static __lHelpDic As Logical
Static __nQtdFil  As Numeric
Static __nErroIns As Numeric
Static __cUsuario As Character
Static __cSenha   As Character
Static __cGrpRead As Character 
Static __aMatSM0  As Array
Static __lChkTA   As Logical
Static __dDtIni   As Date
Static __aUsuario As Array

/*/{Protheus.doc} FIXREINF
    FIX - Atualização de ambiente REINF (Compras / Faturamento / Financeiro)

    @author rodrigo.mpontes 
    @since 06/10/2023
/*/
User Function FIXREINF()
    Local cTblTmp    As Char
    Local aMatGrpFil As Array
    Local oDaialog   As Object
    Local oPnlCentro As Object
    Local oPnlRodape As Object
    Local oFntRodape As Object
    Local oWizard    As Object
    Local oPagina01  As Object
    Local oPagina02  As Object    
    Local oPagina03  As Object
    Local oPagina04  As Object
    Local oPagina05  As Object
    Local oPagina06  As Object
    Local oGrpEmpres As Object
    
    //Inicializa variáveis
	cTblTmp    := ""
    aMatGrpFil := {}
    oDaialog   := Nil
    oPnlCentro := Nil
    oPnlRodape := Nil
    oFntRodape := Nil
    oWizard    := Nil   
    oPagina01  := Nil
    oPagina02  := Nil
    oPagina03  := Nil
    oPagina04  := Nil
    oPagina05  := Nil
    oPagina06  := Nil
    oGrpEmpres := Nil
    
    SET DATE FORMAT TO "dd/mm/yyyy"

    If Date() >= cToD("01/07/2024")
        Aviso("Atenção", "Data limite para execução do ajuste de base Reinf expirado.", {"OK"})
    ElseIf ((Type("cEmpAnt") != "U") .Or. (Type("cFilAnt") != "U"))
        Aviso("Atenção", "O ajuste de base Reinf não pode ser executado via menu.", {"OK"})
    Else        
        //Inicializa static.
        InicStatic()
        
        //Janela de apresentação
        Define Dialog oDaialog Title ("Ajuste de base Reinf")  PIXEL STYLE NOR(WS_VISIBLE, WS_POPUP) 
        oDaialog:nWidth  := 950
        oDaialog:nHeight := 600
        
        //Painel para apresentação dos helps
        oFntRodape := TFont():New("Courier new", Nil, 18, .T., .T., Nil, Nil, Nil, Nil, Nil)
        oPnlRodape := TPanel():New(0, 0, "", oDaialog, oFntRodape, .T., Nil, CLR_RED, Nil, 100, 10, .F., .F.)
        oPnlRodape:Align := CONTROL_ALIGN_BOTTOM
        
        //Painel para apresentação dos steps
        oPnlCentro := TPanel():New(0, 0,"", oDaialog, Nil, .T., Nil, Nil, Nil, 200, 200, .T., .T.)
        oPnlCentro:Align := CONTROL_ALIGN_ALLCLIENT
        
        //Instância da classe de construção do wizard
        oWizard := FwWizardControl():New(oPnlCentro, {400, 300})
        oWizard:ActiveUISteps()
        
        //Pagina 1: Tela de boas vindas
        oPagina01 := oWizard:AddStep("1Pag", {|Panel|WizardPag1(Panel)})
        oPagina01:SetStepDescription("Bem Vindo")
        oPagina01:SetNextTitle("Avançar")
        oPagina01:SetNextAction({||btnAvançar("1Pag", Nil, Nil, Nil, Nil)})
        oPagina01:SetCancelAction({||btnFechar(oDaialog)})
        
        //Pagina 2: Tela de termo de aceite
        oPagina02 := oWizard:AddStep("2Pag", {|Panel|WizardPag2(Panel)})
        oPagina02:SetStepDescription("Termo de Aceite")
        oPagina02:SetNextTitle("Avançar")
        oPagina02:SetNextAction({||btnAvançar("2Pag", @cTblTmp, Nil, @oPnlRodape, Nil)})
        oPagina02:SetCancelAction({||btnFechar(oDaialog)})                
        
        //Pagina 3: Seleção do(s) grupo (s) de empresa (s) e filial (is)
        oPagina03 := oWizard:AddStep("3Pag", {|Panel|WizardPag3(Panel, oDaialog, cTblTmp, @oGrpEmpres, @oPnlRodape)})
        oPagina03:SetStepDescription("Empresa e Filial")
        oPagina03:SetNextTitle("Avançar")
        oPagina03:SetNextAction({||btnAvançar("3Pag", cTblTmp, @oGrpEmpres, @oPnlRodape, @aMatGrpFil)})
        oPagina03:SetCancelAction({||btnFechar(oDaialog)})
        
        //Pagina 4: Autenticação do administrador
        oPagina04 := oWizard:AddStep("4Pag", {|Panel|WizardPag4(Panel)})
        oPagina04:SetStepDescription("Autenticação")
        oPagina04:SetNextTitle("Avançar")
        oPagina04:SetNextAction({||btnAvançar("4Pag", @cTblTmp, @oGrpEmpres, @oPnlRodape, Nil)})
        oPagina04:SetCancelAction({||btnFechar(oDaialog)})
        oPagina04:SetPrevAction({||.F.})
        oPagina04:SetPrevWhen({||.F.})
        
        //Pagina 5: Processamento
        oPagina05 := oWizard:AddStep("5Pag", {|Panel|WizardPag5(Panel, @oPnlRodape, aMatGrpFil, .F.)})
        oPagina05:SetStepDescription("Processamento")    
        oPagina05:SetNextTitle("Processar")
        oPagina05:SetNextAction({||WizardPag5(oPnlCentro, @oPnlRodape, aMatGrpFil, .T.)})
        oPagina05:SetPrevAction({||.F.})
        oPagina05:SetPrevWhen({||.F.})
        oPagina05:SetCancelAction({||btnFechar(oDaialog)})
        
        //Pagina 6: Fim
        oPagina06 := oWizard:AddStep("6Pag", {|Panel|WizardPag6(Panel, @oPnlRodape)})
        oPagina06:SetStepDescription("Fim")
        oPagina06:SetNextTitle("Concluir")
        oPagina06:SetNextAction({||oDaialog:End()})
        oPagina06:SetPrevAction({||.F.})
        oPagina06:SetPrevWhen({||.F.})
        oPagina06:SetCancelAction({||oDaialog:End()})
        
        oWizard:Activate()
        Activate Dialog oDaialog CENTER
        oWizard:Destroy()        
    EndIf
Return Nil

/*/{Protheus.doc} WizardPag1
    Construção da primeira página do wizard, página de boas vindas
    
    @author Sivaldo Oliveira
    @since 19/10/2023
    
    @param oPainel, Object, Painel onde é apresentado o texto de bem vindo.
/*/
Static Function WizardPag1(oPnlCentro As Object)
	Local oFont As Object
    
    //Parâmetros de entrada
    Default oPnlCentro := Nil
    
    //Inicializa variáveis
	oFont := TFont():New(Nil, Nil, -25, .T., .T., Nil, Nil, Nil, Nil, Nil)
    
    If oPnlCentro != Nil 
        TSay():New(010, 015, {||("Bem vindo ao wizard de configuração de ajuste de base Reinf")}, oPnlCentro, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
        oFont:Bold    := .F.
        oFont:nHeight := -15
        
        TSay():New(055, 015, {||"Este FIX tem como objetivo fazer o vínculo automático da(s) natureza(s) de rendimento "}, oPnlCentro, Nil, oFont,   Nil, Nil, Nil, .T., CLR_BLUE, Nil)
        TSay():New(065, 015, {||"com as notas de entrada e saída e títulos contas a pagar e receber que devem ser "}, oPnlCentro, Nil, oFont,   Nil, Nil, Nil, .T., CLR_BLUE, Nil)
        TSay():New(075, 015, {||"considerados no EFD-Reinf Bloco 40."}, oPnlCentro, Nil, oFont,   Nil, Nil, Nil, .T., CLR_BLUE, Nil)      
    EndIf
    
    FreeObj(oFont)
Return Nil

/*/{Protheus.doc} WizardPag2
    Construção da segunda página do wizard página de termo de aceite
    
    @author Alberto Teixeira
    @since 26/10/2023
    
    @param oPnlCentro, Object, Objeto panel de apresentação da seleção de empresa/filiais 
/*/
Static Function WizardPag2(oPnlCentro As Object)    
	Local cLink    As Character
    Local oFont    As Object
    Local oSayLink As Object    
    
    //Parâmetros de entrada
    Default oPnlCentro := Nil
    
    //Inicializa variáveis
	cLink    := "https://tdn.totvs.com/pages/viewpage.action?pageId=786554814"
    oFont    := TFont():New(Nil, Nil, -25, .T., .T., Nil, Nil, Nil, Nil, Nil)
    oSayLink := NIL
    
    If oPnlCentro != Nil 
        TSay():New(010, 015, {||"Termo de aceite"}, oPnlCentro, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
        oFont:Bold    := .F.
        oFont:nHeight := -15
        
        TSay():New(035, 015, {||"Por se tratar de um processo de ajuste de base, é necessário fazer o backup da mesma e o teste primeiramente "}, oPnlCentro, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
        TSay():New(045, 015, {||"seja realizado em base de homologação."}, oPnlCentro, Nil, oFont,   Nil, Nil, Nil, .T., CLR_BLUE, Nil)
        TSay():New(055, 015, {||"É obrigatória a leitura de toda documentação disponibilizada para a execução desta rotina, garantindo que todos"}, oPnlCentro, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)      
        TSay():New(065, 015, {||"os processos e conceitos implementados sejam avaliados de forma preventiva antes de realizar a atualização."}, oPnlCentro, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
        
        oFont:Bold    := .T.
        oFont:nHeight := -25                
        TSay():New(90, 015, {||"Link do tdn"}, oPnlCentro, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)      
        
        oFont:Bold    := .F.
        oFont:nHeight := -15        
        
        oSayLink := TSay():New(115, 015, {|| "Ajuste - Vínculo da Natureza de Rendimento para títulos lançados antes da vigência do EFD-Reinf Bloco 40" }, oPnlCentro, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
        oSayLink:blClicked := {|| ShellExecute("Open", cLink, "", "", 1)}
        oSayLink:nClrText  := CLR_RED
        
        TCheckBox():New(150, 015, "Li e aceito todas as alterações propostas pela rotina", {|| __lChkTA }, oPnlCentro, 350, 260, Nil, {|| __lChkTA := !__lChkTA }, oFont, Nil, CLR_BLUE, Nil, Nil, .T., Nil, Nil, Nil)
    EndIf
    
    FreeObj(oFont)
Return Nil

/*/{Protheus.doc} WizardPag3
    Construção da terceira página do wizard página de seleção do(s) grupo(s) de empresa(s) / filial(is)
    
    @author Sivaldo Oliveira
    @since 29/11/2022
    
    @param oDaialog,  Object, Objeto de interface visual.
    @param oPanel,    Object, Objeto panel de apresentação da seleção de empresa/filiais 
/*/
Static Function WizardPag3(oPnlCentro As Object, oDaialog As Object, cTblTmp As Varchar, oGrpEmpres As Object, oPnlRodape As Object)
    Local nLinha     As Numeric
    Local aColuna    As Array
    Local aStruct    As Array
    
    //Parâmetros de Entrada.
    Default oPnlCentro := Nil 
    Default oDaialog   := Nil
    Default cTblTmp    := ""
    Default oGrpEmpres := Nil
    Default oPnlRodape := Nil
    
    //Inicializa variáveis
    nLinha     := 0
    aColuna    := {}
    aStruct    := {}
    
    If __nErroIns == 0 .And. !Empty(cTblTmp)        
        AAdd(aStruct, {"GRUPO",   "Grupo", Len(SM0->M0_CODIGO), 0, "@!"})
        AAdd(aStruct, {"FILIAL",  "Código da filial", Len(SM0->M0_CODFIL), 0, "@!"})
        AAdd(aStruct, {"NOMEFIL", "Nome da filial", Len(SM0->M0_FILIAL), 0, "@!"})
        
        For nLinha := 1 To Len(aStruct)
            AAdd(aColuna, FWBrwColumn():New())
            aColuna[nLinha]:SetData( &("{||" + aStruct[nLinha,1] + "}") )
            aColuna[nLinha]:SetTitle(aStruct[nLinha, 2])
            aColuna[nLinha]:SetSize(aStruct[nLinha, 3])
            aColuna[nLinha]:SetDecimal(aStruct[nLinha, 4])
            aColuna[nLinha]:SetPicture(aStruct[nLinha,5])
        Next nLinha
        
        oGrpEmpres := FWMarkBrowse():New(oPnlCentro)    
        oGrpEmpres:SetAlias(cTblTmp)
        oGrpEmpres:SetDescription("Selecione o(s) grupo(s) de empresa(s) / filial(is), e clique em avançar")            
        oGrpEmpres:SetTemporary(.T.)
        oGrpEmpres:SetOwner(oPnlCentro)
        oGrpEmpres:SetFieldMark("MARCA")            
        oGrpEmpres:bMark    := {||MarcaGrupo(.F., cTblTmp, oGrpEmpres, oPnlRodape)}
        oGrpEmpres:bAllMark := {||MarcaGrupo(.T., cTblTmp, oGrpEmpres, oPnlRodape)}
        oGrpEmpres:SetColumns(aColuna)
        oGrpEmpres:SetUseFilter(.T.)
        oGrpEmpres:Activate()
        
        FwFreeArray(aStruct)
        FwFreeArray(aColuna)
    EndIf
Return Nil

/*/{Protheus.doc} WizardPag4
    Construção da quarta página do wizard, autenticação de usuário administrador
    
    @author Sivaldo Oliveira
    @since 19/10/2023
    
    @param oPainel, Object, Objeto panel de apresentação dos campos de usuário e senha
/*/
Static Function WizardPag4(oPnlCentro As Object)
    Local oFont As Object    
    
    //Parâmetros de entrada
    Default oPnlCentro := Nil   
    
    //Inicializa variáveis
    oFont := TFont():New(Nil, Nil, -25, .T., .T., Nil, Nil, Nil, Nil, Nil)
    
    TSay():New(010, 15, {||"Autenticação de usuário do grupo administrador"}, oPnlCentro, Nil, oFont, Nil, Nil, Nil, .T., CLR_BLUE, Nil)    
    oFont:Bold    := .F.
    oFont:nHeight := -15    
    
    //Usuário
    TMultiGet():New(060, 015, {|u|If(PCount() > 0, __cUsuario := u, __cUsuario)}, oPnlCentro, 400, 012, Nil, Nil, Nil, Nil, Nil, .T., Nil, .T., Nil, .F., Nil, .F., Nil, Nil, .F., .F., .F., "Usuário", 1, oFont, CLR_BLUE)
    
    //Senha
    TGet():New(090, 015, {|u|If(PCount() > 0, __cSenha := u, __cSenha)}, oPnlCentro, 400, 012, "",   Nil, Nil, Nil,   Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, .F., .T., Nil,       "Senha", Nil, Nil, Nil, Nil, Nil, Nil,      "Senha", 1, oFont, CLR_BLUE)
    TGet():New(140, 015, {|u|If(PCount() > 0, __dDtIni := u, __dDtIni)}, oPnlCentro, 120, 015, "@D", Nil, Nil, Nil, oFont, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, .F., .F., Nil, "DataInicial", Nil, Nil, Nil, Nil, Nil, Nil, "Data inicial para ajuste de base", 1, oFont, CLR_BLUE)
Return Nil

/*/{Protheus.doc} WizardPag5
    Construção da quinta página do wizard, status de processamento
    
    @author Sivaldo Oliveira
    @since 19/10/2023
    
    @param oPainel, Object, Objeto panel para apresentação de status de processamento
/*/
Static Function WizardPag5(oPnlCentro As Object, oPnlRodape As Object, aMatGrpFil As Array, lProcessa As Logical)
    Local lValidaDic As Logical
    Local nQtdFilSel As Numeric
    Local nGrupo     As Numeric
    Local cDataIni   As Character
    Local aFiliais   As Array    
    Local oFonte     As Object
    Local oStatus    As Object    
    
    //Parâmetros de entrada.
    Default oPnlCentro := Nil
    Default oPnlRodape := Nil
    Default aMatGrpFil := {}
    Default lProcessa  := .F.
    
    //Inicializa variáveis
    If !lProcessa      
        If oPnlCentro != Nil 
            oFonte := TFont():New(Nil, Nil, -15, .T., .F., Nil, Nil, Nil, Nil, Nil)
            
            TSay():New(010, 015, {||("Observação")}, oPnlCentro, Nil, oFonte, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
            
            TSay():New(055, 015, {||"Esta rotina não atende aos cenário de suspensão, isenção e dedução. Caso seu cenário seja um destes"}, oPnlCentro, Nil, oFonte, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
            TSay():New(065, 015, {||"não contemplado por esta rotina, o ajuste pode ser realizado diretamente no TAF."}, oPnlCentro, Nil, oFonte,   Nil, Nil, Nil, .T., CLR_BLUE, Nil)
            TSay():New(075, 015, {||"Certifique-se de ter realizado o backup e avaliado a necessidade de execução desta rotina."}, oPnlCentro, Nil, oFonte,   Nil, Nil, Nil, .T., CLR_BLUE, Nil)      
        EndIf
       
        Return Nil
    EndIf
    
    lValidaDic := .F.
    nQtdFilSel := Len(aMatGrpFil)
    nGrupo     := 0
    cDataIni   := DToS(__dDtIni) 
    aFiliais   := {}    
    oFonte     := TFont():New(Nil, Nil, -25, .T., .T., Nil, Nil, Nil, Nil, Nil)
    oStatus    := TSay():New(160, 100, {||"Processando, aguarde!"}, oPnlCentro, Nil, oFonte, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
    oStatus:SetTextAlign(2,2)    
    
    If nQtdFilSel > 0
        If AllTrim(aMatGrpFil[1,1]) != __cGrpRead           
            RESET ENVIRONMENT                            
            PREPARE ENVIRONMENT EMPRESA aMatGrpFil[1,1] FILIAL aMatGrpFil[1,2] MODULO "COM" TABLES "SE2", "SE5", "SA6", "SED", "SA2", "SA1", "DHR", "SC6"
             __cGrpRead := AllTrim(aMatGrpFil[1,1])
        EndIf
        
        For nGrupo := 1 To nQtdFilSel
            If !lValidaDic
                If nGrupo > 1
                    If AllTrim(aMatGrpFil[nGrupo,1]) == __cGrpRead
                        Loop
                    EndIf
                    
                    __cGrpRead := AllTrim(aMatGrpFil[nGrupo,1])
                    RESET ENVIRONMENT                            
                    PREPARE ENVIRONMENT EMPRESA aMatGrpFil[nGrupo,1] FILIAL aMatGrpFil[nGrupo,2] MODULO "COM" TABLES "SE2", "SE5", "SA6", "SED", "SA2", "SA1", "DHR", "SC6"                    
                EndIf
                
                If ((SED->(ColumnPos("ED_NATREN")) <= 0) .Or. (SC6->(ColumnPos("C6_NATREN")) <= 0) .Or. (F2Q->(ColumnPos("F2Q_NATREN")) <= 0) .Or.;
                    (FKW->(ColumnPos("FKW_NATREN")) <= 0) .Or. (FKY->(ColumnPos("FKY_NATREN")) <= 0))
                    lValidaDic := .F.
                    Loop
                EndIf
                
                lValidaDic := .T.
                __lHelpDic := .F.
                CriaTblLog()
            EndIf
            
            cFilAnt := aMatGrpFil[nGrupo,2]
            AAdd(aFiliais, cFilAnt)            
            
            //Componente de suprimentos
            oPnlRodape:cCaption := "Processando notas de entrada, módulo de compras, grupo: " + AllTrim(__cGrpRead) + " filial: " + AllTrim(cFilAnt)
            FIXCOMREIN(cDataIni) //COM
            
            //Componente de faturamento
            oPnlRodape:cCaption := "Processando notas de saídas, módulo de faturamento, grupo: " + AllTrim(__cGrpRead) + " Filial: " + AllTrim(cFilAnt)
            FIXFATREIN(cDataIni) //FAT        
            
            If ((nGrupo == nQtdFilSel) .Or. (nGrupo < nQtdFilSel .And. AllTrim(aMatGrpFil[(nGrupo + 1),1]) != __cGrpRead))
                //Componente do financeiro
                oPnlRodape:cCaption := "Processando títulos avulso, módulo financeiro, grupo: " + AllTrim(__cGrpRead) + " todas as filiais selecionadas"
                FIXFINREIN(aFiliais, cDataIni) //FIN                      
                aFiliais := {}
                
                If nGrupo < nQtdFilSel .And. AllTrim(aMatGrpFil[(nGrupo + 1),1]) != __cGrpRead
                    lValidaDic := .F.
                EndIf
            EndIf
        Next nGrupo
    EndIf   
    
    oStatus:SetText("")
Return lProcessa

/*/{Protheus.doc} WizardPag6
    Construção da sexta página do wizard, pagina de conclusão
    
    @author Sivaldo Oliveira
    @since 19/10/2023
    
    @param oPainel, Object, Objeto panel para apresentação da msg de conclusão.
/*/
Static Function WizardPag6(oPnlCentro As Object, oPnlRodape As Object)    
    Local oFonte  As Object
    Local oStatus As Object 
    
    //Parâmetros de entrada.
    Default oPnlCentro := Nil
    Default oPnlRodape := Nil 
    
    //Inicializa variáveis
    oFonte  := Nil
    oStatus := Nil
    
    If oPnlCentro != Nil
        oFonte  := TFont():New(Nil, Nil, -25, .T., .T., Nil, Nil, Nil, Nil, Nil)
        oStatus := TSay():New(70, 015, {||"Processamento concluído!"}, oPnlCentro, Nil, oFonte, Nil, Nil, Nil, .T., CLR_BLUE, Nil)
        oStatus:SetTextAlign(2,2)
    EndIf
    
    If oPnlRodape != Nil
        oPnlRodape:cCaption := ""
        
        If __lHelpDic
            oPnlRodape:cCaption := "O ajuste de base não pôde ser realizado porque o dicionário de dados está desatualizado"
        EndIf
    EndIf 
Return Nil

/*/{Protheus.doc} btnAvançar
    Valida se pode avançar para a próxima página.
    
    @author Sivaldo Oliveira
    @since 19/10/2023
    
    @param  cPagina, Varchar, Nome da página que será submetida a validação
    @param cTblTmp, Char,   Arquivo / tabela temporária com a lista dos grupos de empresas / filiais
    @Return lRetorno, Logical, Lógico que indica se pode avançar para a próxima página 
/*/
Static Function btnAvançar(cPagina As Character, cTblTmp As Char, oGrpEmpres As Object, oPnlRodape As Object, aMatGrpFil As Array) As Logical
    Local lRetorno   As Logical    
    Local nGrupo     As Numeric
    Local nRecno     As Numeric
    Local nQtdFilSel As Numeric
    Local cSGBD      As Char    
    Local cInsert    As Char
    Local cLoginUser As Char
    Local cSenhaUser As Char
    Local aStruTmp   As Array
    Local aFiliais   As Array
    Local oObjTmp    As Object
    
    //Parâmetros de entrada.
    Default cPagina    := ""
    Default cTblTmp    := ""
    Default oGrpEmpres := Nil
    Default oPnlRodape := Nil
    Default aMatGrpFil := Nil
    
    //Inicializa variáveis
    lRetorno   := .T.
    nRecno     := 0
    nGrupo     := 0
    nQtdFilSel := 0
    cInsert    := ""
    cSGBD      := ""
    cLoginUser := ""
    cSenhaUser := ""
    aStruTmp   := Nil
    aFiliais   := Nil
    oObjTmp    := Nil   
    
    If !Empty(cPagina := AllTrim(cPagina))
        lRetorno := .F.
        
        Do Case
            Case cPagina == "1Pag"                                
                lRetorno := .T. 
            Case cPagina == "2Pag"                
                If oPnlRodape != Nil
                    oPnlRodape:cCaption := ""
                EndIf
                
                If (lRetorno := __lChkTA)
                    If __nQtdFil <= 0
                        OpenSM0()
                        DbSelectArea("SM0")
                        SM0->(DbGoTop())
                        
                        __aMatSM0 := FwLoadSM0()
                        __nQtdFil := Len(__aMatSM0)
                        
                        If __nQtdFil > 0                            
                            cSGBD    := Alltrim(Upper(TCGetDB()))
                            aStruTmp := {}
                            
                            AAdd(aStruTmp, {"MARCA",   "C", 1, 0})
                            AAdd(aStruTmp, {"GRUPO",   "C", Len(SM0->M0_CODIGO), 0})
                            AAdd(aStruTmp, {"FILIAL",  "C", Len(SM0->M0_CODFIL), 0})
                            AAdd(aStruTmp, {"NOMEFIL", "C", Len(SM0->M0_FILIAL), 0})
                            oObjTmp := FWTemporaryTable():New()
                            
                            oObjTmp:SetFields(aStruTmp)
                            oObjTmp:AddIndex("1", {"MARCA"})
                            oObjTmp:AddIndex("2", {"GRUPO"})
                            oObjTmp:Create()
                            
                            cTabela := oObjTmp:GetRealName()
                            
                            If oPnlRodape != Nil
                                oPnlRodape:cCaption := "Carregando o(s) grupo(s) de empresa(s) / filial(is), aguarde..."
                            EndIf                        
                            
                            For nGrupo := 1 To __nQtdFil                                
                                Values  := "' ', '" + AllTrim(__aMatSM0[nGrupo,1]) + "', '" + AllTrim(__aMatSM0[nGrupo,2]) + "', '" + AllTrim(__aMatSM0[nGrupo,7]) + "'"                                
                                cInsert := "INSERT " + IIf(cSGBD == "ORACLE", "/*+ APPEND */ ", "")                                
                                cInsert += "INTO " + cTabela + " (MARCA, GRUPO, FILIAL, NOMEFIL) VALUES (" + Values + ") "                                
                                
                                If TcSQLExec(cInsert) >= 0 .And. __nErroIns < 0
                                    __nErroIns := 0
                                EndIf
                            Next nGrupo
                            
                            cTblTmp := ""
                            
                            If __nErroIns == 0                                
                                PREPARE ENVIRONMENT EMPRESA __aMatSM0[1,1] FILIAL __aMatSM0[1,2] MODULO "COM" TABLES "SE2", "SE5", "SA6", "SED", "SA2", "SA1", "DHR", "SC6"
                                cTblTmp    := oObjTmp:GetAlias()                                
                                __cGrpRead := AllTrim(__aMatSM0[1,1])
                                __aUsuario := FWSFALLUSERS()
                                (cTblTmp)->(DbSetOrder(2))
                            EndIf
                            
                            If oPnlRodape != Nil
                                oPnlRodape:cCaption := IIf(__nErroIns == 0, oPnlRodape:cCaption, "Não foi possível carregar o(s) grupo(s) de empresa(s) / filial(is)")
                            EndIf
                        EndIf
                    EndIf
                    
                    If (lRetorno := (__nQtdFil > 0 .And. __nErroIns == 0)) .And. oPnlRodape != Nil
                        oPnlRodape:cCaption := ""
                    EndIf
                ElseIf oPnlRodape != Nil
                    oPnlRodape:cCaption := "Para continuar com o ajuste de base reinf, é necessário o aceite do termo"
                EndIf
            Case cPagina == "3Pag"
                nRecno := (cTblTmp)->(Recno())                     
                oPnlRodape:cCaption := ""
                (cTblTmp)->(DbSetOrder(1))
                
                If (lRetorno := (cTblTmp)->(DbSeek(oGrpEmpres:cMark)))
                    aMatGrpFil := {}
                    
                    While (cTblTmp)->(!Eof()) .And. (cTblTmp)->MARCA == oGrpEmpres:cMark
                        AAdd(aMatGrpFil, {(cTblTmp)->GRUPO,  (cTblTmp)->FILIAL, (cTblTmp)->NOMEFIL})
                        (cTblTmp)->(DbSkip())
                    EndDo
                    
                    (cTblTmp)->(DbCloseArea())
                    oGrpEmpres:SetAlias("SE1")                    
                Else
                    (cTblTmp)->(DbGotop())
                    (cTblTmp)->(DbGoto(nRecno))                        
                    oPnlRodape:cCaption := "Para continuar, é necessário selecionar pelos menos um grupo de empresa/filial."                
                EndIf
            Case cPagina == "4Pag"                
                If oPnlRodape != Nil
                    oPnlRodape:cCaption := ""
                EndIf            
                
                cLoginUser := LimpaEspac(__cUsuario)
                
                If (nPosUser := AScan(__aUsuario, {|userlogin| upper(AllTrim(userlogin[3])) == upper(cLoginUser)})) > 0
                    If FWIsAdmin(__aUsuario[nPosUser,2])                        
                        cSenhaUser := LimpaEspac(__cSenha)                        
                        PswOrder(1)
                        
                        If (PswSeek(__aUsuario[nPosUser,2]) .And. PswName(cSenhaUser))                        
                            If !(lRetorno := !Empty(__dDtIni)) .And. oPnlRodape != Nil
                                oPnlRodape:cCaption := "A data inicial para processamento do ajuste de base não foi preenchida"
                            EndIf
                        Else
                            oPnlRodape:cCaption := "Usuário ou senha inválidos"
                        EndIf
                    Else
                        oPnlRodape:cCaption := "Usuário não pertence ao grupo de administrador"
                    EndIf
                Else
                    oPnlRodape:cCaption := "Usuário não encontrado."
                EndIf                
        EndCase
    EndIf
Return lRetorno

/*/{Protheus.doc} MarcaGrupo
    Função responsável por marcar/selecionar os grupos de empresas e filiais
    
    @author Sivaldo Oliveira
    @since 19/10/2023
    
    @param lMarcaAll, Logical, Indica se a marcação/seleção será apenas da linha posicionada 
    ou de todos os grupos de empresas / filiais
    @param cTblTmp, Char,   Arquivo / tabela temporária com a lista dos grupos de empresas / filiais
    @param oGrpEmpres, Object, Instância da classe FWMarkBrowse para seleção do grupo de empresa / filial
/*/
Static Function MarcaGrupo(lMarcaAll As Logical, cTblTmp As Char, oGrpEmpres As Object, oPnlRodape As Object)
    Local nRecno As Numeric
    Local cMarca As Char
    
    //Parâmetros de entrada.
    Default lMarcaAll  := .F.
    Default cTblTmp    := ""
    Default oGrpEmpres := Nil    
    
    If oGrpEmpres != Nil .And. !Empty(cTblTmp)
        //Inicializa variáveis
        nRecno := (cTblTmp)->(Recno())
        cMarca := oGrpEmpres:cMark     
        
        If oPnlRodape != Nil .And. !Empty(oPnlRodape:cCaption)
            oPnlRodape:cCaption := ""
        EndIf
        
        If lMarcaAll
            (cTblTmp)->(DbGotop())
            (cTblTmp)->(DbSetOrder(0))
        EndIf
        
        While (cTblTmp)->(!Eof())        
            If (cTblTmp)->(MsRLock())
                If lMarcaAll 
                    If oGrpEmpres:IsMark()
                        (cTblTmp)->MARCA := " "
                    Else
                        (cTblTmp)->MARCA := cMarca
                    EndIf
                    (cTblTmp)->(MsUnlock())
                EndIf
            EndIf
            
            If !lMarcaAll
                exit
            EndIf
            
            (cTblTmp)->(DbSkip())
        EndDo
        
        (cTblTmp)->(DbGotop())
        (cTblTmp)->(DbSetOrder(2))
        (cTblTmp)->(DbGoto(nRecno))
        
        If lMarcaAll
            oGrpEmpres:Obrowse:Refresh()
        EndIf
    EndIf
Return Nil

/*/{Protheus.doc} btnFechar
    Fecha o wizard de configuração de ajuste de base do reinf
    
    @author Sivaldo Oliveira
    @since 19/10/2023
    
    @Param oDaialog, Object, Objeto daialog (janela) 
    @Return lRetorno, Logical, Verdadeiro ou Falso
    que indica se confirmou ou não o cancelamento.    
/*/
Static Function btnFechar(oDaialog As Object) As Logical
    Local lRetorno As Logical
    
    //Parâmetros de entrada
    Default oDaialog := Nil    
    
    //Inicializa variáveis.
    lRetorno := MsgYesNo("Deseja realmente cancelar?", "Aviso")
    
    If lRetorno .And. oDaialog != Nil
        oDaialog:End()
        oDaialog := Nil
    EndIf
Return lRetorno

/*/{Protheus.doc} LimpaEspac
    Remove linhas e espaços vazios de campo multiget
    
    @author Sivaldo Oliveira
    @since 30/10/2023
    
    @return cTexto, Char, Retorna um texto sem as alinha e espaços vazios.
/*/
Static Function LimpaEspac(cConteudo As Char) As Character
    Local cCaracter As Char
    Local cTexto    As Char    
    Local cCHR10    As Char
    Local cCHR13    As Char
    Local cCHR1310  As Char
    Local nPosicao  As Numeric
    Local nTamanho  As Numeric    
    
    //Parâmetros de entrada.
    Default cConteudo := ""
    
    //Inicializa variáveis.
    cCaracter := ""
    cTexto    := ""
    cCHR10    := ""
    cCHR13    := ""
    cCHR1310  := ""
    nPosicao  := 0
    nTamanho  := Len(Alltrim(cConteudo))
    
    If nTamanho > 0
        cConteudo  := Alltrim(cConteudo)
        cCHR10   := CHR(10)
        cCHR13   := CHR(13)
        cCHR1310 := (CHR(13)+CHR(10))
        
        For nPosicao := 1 To nTamanho
            cCaracter := SubStr(cConteudo, nPosicao, 1)
            
            If (cCaracter == cCHR10) .Or. (cCaracter == cCHR13) .Or. (cCaracter == cCHR1310)
                Loop
            EndIf
            
            cTexto += cCaracter
        Next nPosicao
    EndIf
    
    cTexto := Alltrim(cTexto)
Return cTexto

/*/{Protheus.doc} CriaTblLog
    Criação da tabela temporária para gravação dos logs de atualização 
    de inclusão de módulos de Compras, Faturamento e Financeiro
    
    @author Rodrigo Pontes
    @since  @since 30/09/2023
/*/
Static Function CriaTblLog()
    Local lCriaTbl   As Logical
    Local aStruct    As Array    
    Local aAreaAtual As Array
    
    //Inicializa variáveis.
    lCriaTbl   := !TCCanOpen("REINFLOG") 
    aAreaAtual := GetArea()
    
    If lCriaTbl 
        aStruct := {}
        
        AAdd(aStruct, {"GRUPO",    "C",  008, 00}) //Grupo de empresa
        AAdd(aStruct, {"EMPFIL",   "C",  008, 00}) //Empresa/filial do documento/título
        AAdd(aStruct, {"DATAPROC", "C",  020, 00}) //Data e hora do processamento
        AAdd(aStruct, {"TIPO",     "C",  002, 00}) //DE=Documento de entrada / DS = Documento de Saída / CP = Contas a Pagar / CR = Contas a Receber
        AAdd(aStruct, {"CHAVE",    "C",  220, 00}) //Chave do documento/título
        AAdd(aStruct, {"FATC6",    "C",  001, 00}) //Identifica se foi atualizada natureza de rendimento no pedido de venda
        AAdd(aStruct, {"FATFKW",   "C",  001, 00}) //Identifica se foi criado o registro na FKW referente ao documento de saída
        AAdd(aStruct, {"COMDHR",   "C",  001, 00}) //Identifica se foi criado/atualizado o registro na tabela DHR referente ao documento de entrada
        AAdd(aStruct, {"COMFKW",   "C",  001, 00}) //Identifica se foi criado o registro na tabela FKW referente ao documento de entrada
        AAdd(aStruct, {"FINFKF",   "C",  001, 00}) //Identifica se foi atualizado o registro na tabela FKF referente ao título avulso
        AAdd(aStruct, {"FINFKW",   "C",  001, 00}) //Identifica se foi criado o registro na tabela FKW referente ao título avulso
        AAdd(aStruct, {"CQUERYP",  "C",  001, 00}) //Identifica se foi usada a query padrão. P = consulta padrão, C = consulta customizada
        
        MsCreate("REINFLOG", aStruct, "TOPCONN")
        DbUseArea(.T., "TOPCONN", "REINFLOG", "REINFLOG", .T., .F.)        
        REINFLOG->(DBCreateIndex("IND1", "TIPO + CHAVE"))
    Else    
        DbUseArea(.T., "TOPCONN", "REINFLOG", "REINFLOG", .T., .F.)
    EndIf
    
    RestArea(aAreaAtual)
    FwFreeArray(aAreaAtual)
Return Nil

/*/{Protheus.doc} InicStatic
    Inicializa as variáveis estáticas.
    
    @author Sivaldo Oliveira
    @since  @since 19/10/2023
/*/
Static Function InicStatic()
    __nQtdFil  := 0
    __nErroIns := -1
    __cUsuario := ""
    __cSenha   := Padr("", 400)
    __cGrpRead := ""
    __aMatSM0  := Nil
    __lChkTA   := .F.
    __dDtIni   := Date()
    __aUsuario := Nil
    __lHelpDic := .T.
Return Nil
