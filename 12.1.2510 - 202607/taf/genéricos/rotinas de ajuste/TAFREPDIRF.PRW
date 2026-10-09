#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TafRepDIRF
Interface de Reprocessamento Analitico da DIRF.
Utiliza FWWizardControl para garantir a persistencia da sessao Protheus.

@type           Function
@author         rodrigo.nicolino
@since          09/02/2026
@version        2.0
/*/
//---------------------------------------------------------------------
Function TafRepDIRF()

    Local oDlg          as object
    Local oNewPag       as object
    Local oStepWiz      as object
    Local oTPanel       as object

    Private aEventosParm := {}
    Private aFiliais     := {}
    Private cArquivo     := ""
    Private cFunc        := Space(6)
    Private cLog         := ""
    Private cPeriodo     := Space(6)
    Private cTempPath    := ""
    Private lForce       := .F.
    Private lLogError    := .F.
    Private oEdit        := Nil
    Private oLog         := Nil

    oDlg         := Nil
    oNewPag      := Nil
    oStepWiz     := Nil
    oTPanel      := Nil


	DBSelectArea("C1E")
	C1E->( DBSetOrder(3) )
	If C1E->( MSSeek( xFilial("C1E") + PadR( SM0->M0_CODFIL, TamSX3( "C1E_FILTAF" )[1] ) + "1" ) )
		If !C1E->C1E_MATRIZ 
			Aviso("Rotina de Reprocessamento tabela T8R - Relatório IRRF " , "Essa rotina deve ser executada somente na filial Matriz.", { "Ok" }, 2 )
            Return Nil 
		EndIf
	EndIf

    DEFINE DIALOG oDlg TITLE "Gerenciamento de Reprocessamento DIRF" PIXEL STYLE nOR(WS_VISIBLE, WS_POPUP)
        
        oDlg:nWidth     := 1000
        oDlg:nHeight    := 800

        oTPanel         := TPanel():New(20,70, "Reprocessamento DIRF", oDlg,,,,,, 300, 300) 
        oTPanel:Align   := CONTROL_ALIGN_ALLCLIENT

        oStepWiz := FWWizardControl():New(oTPanel)
        oStepWiz:ActiveUISteps()
        
        oNewPag := oStepWiz:AddStep("1")
        oNewPag:SetStepDescription("Início") // "Início"
        oNewPag:SetConstruction({|oPanel| Start(oPanel)})
        oNewPag:SetCancelAction({|| .T., oDlg:End()})
        
        oNewPag := oStepWiz:AddStep("2", {|oPanel| Params(oPanel)})
        oNewPag:SetStepDescription("Parâmetros") // "Parâmetros"
        oNewPag:SetCancelAction({|| .T., oDlg:End()})
        oNewPag:SetNextTitle("Processar") // "Processar"
        oNewPag:SetNextAction({|| Validation()})

        oNewPag := oStepWiz:AddStep("3", {|oPanel| Finish(oPanel), FWMsgRun(, {|| Processing()}, "Processamento", "Atualizando a tabela T8R...")}) 
        oNewPag:SetStepDescription("Processamento") // "Processamento"
        oNewPag:SetNextTitle("Fechar") // "Fechar"
        oNewPag:SetNextAction({|| .T., oDlg:End()})
        oNewPag:SetCancelWhen({|| .F.})
        oNewPag:SetPrevWhen({|| .F.})
        
        oStepWiz:Activate()

    ACTIVATE DIALOG oDlg CENTER

    oStepWiz:Destroy()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Start
Monta tela de Início

@param oPanel - Objeto FWWizardControl()

@author rodrigo.nicolino
@since 09/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Start(oPanel as object)

    Local bBrower as codeblock
    Local cLink   as character 
    Local oButton as object

    Default oPanel  := Nil

    bBrower   := {|| }
    cLink     := "https://tdn.totvs.com/display/TAF/Reprocessamento+DIRF+-+TafRepDIRF"
    oButton   := Nil

    WizSay("Rotina de atualização da tabela T8R para o período de apuração da DIRF."                                      , oPanel, 007, 055, 6, "#3C769C",, .T., .F., 2, oPanel:nClientWidth * 0.47, 040) // "Rotina de atualização da tabela T8R para o período de apuração da DIRF."
    WizSay("Esta rotina realiza o reprocessamento da tabela T8R de acordo com o Período, Filial e Trabalhador informados.", oPanel, 067, 010, 5, "#737373",, .F., .F., 1, oPanel:nClientWidth * 0.47, 040) // "Esta rotina realiza o reprocessamento da tabela T8R de acordo com o Período, Filial e Trabalhador informados."
    WizSay("Recomendamos que seja feito o backup da tabela T8R antes da utilização dessa rotina, caso haja um histórico que queira preservar, pois a mesma realiza a exclusão lógica total dos registros da tabela T8R e recria ela, somente a partir dos registros dos eventos e totalizadores existentes na base.", oPanel, 127, 010, 3, "#C64840",, .F., .F., 1, oPanel:nClientWidth * 0.47, 040) // ""Recomendamos que seja feito o backup da tabela T8R antes da utilização dessa rotina, caso haja um histórico que queira preservar, pois a mesma realiza a exclusão lógica total dos registros da tabela T8R e recria ela, somente a partir dos registros dos eventos e totalizadores existentes na base."

    Iif( GetRemoteType() == 2, bBrower := {|| ShellExecute("Browser", "/usr/bin/firefox", cLink, "/", 1)}, bBrower := {|| ShellExecute("Open", cLink, "", "C:\", 1)})

    oButton := THButton():New(180, 180, "Clique aqui para acessar a documentação", oPanel, bBrower, 120, 010,, cLink) // "Clique aqui para acessar a documentação"

    oButton:SetCss("QPushButton{ color: #3C769C; }")

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Params
Monta tela de parâmetros

@param oPanel - Objeto FWWizardControl()

@author rodrigo.nicolino
@since 09/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Params(oPanel as object)

    Local cTheme    as character
    Local oFontBold as object
    Local oGetCPF   as object
    Local oGetPer   as object
    Local oSayCPF   as object
    Local oSayFil   as object
    Local oSayInfo  as object
    Local oSayInstr as object
    Local oSayPer   as object
    Local oTheme    as object

    Default oPanel  := Nil

    oTheme := totvs.framework.css.ProtheusTheme():New()
    cTheme := oTheme:GetTheme()
    oFontBold   := TFont():New("Arial",, -12, .T.)
    
    oSayInstr := TSay():New(010, 010, {|| "Instrucoes de Uso:"}, oPanel, , oFontBold, , , , .T.)
    oSayInfo  := TSay():New(022, 010, {|| "Selecione o periodo e as filiais para reprocessar a coleta analitica."}, oPanel, , , , , , .T., , , 400, 20)

    //--- Campo Periodo (AAAAMM) ---
    oSayPer := TSay():New(065, 010, {|| "Periodo (AAAAMM) ou (AAAA):"}, oPanel, , oFontBold, , , , .T.)
    oGetPer := TGet():New(077, 010, bSETGET(cPeriodo), oPanel, 060, 012, "@R 9999/99", {|| !Empty(cPeriodo)}, Nil, Nil, , , , .T., , , , , , , , , , , , , , .T.)

    //--- Campo Funcionario (6 digitos) ---
    oSayCPF := TSay():New(065, 150, {|| "Funcionario (Opcional):"}, oPanel, , oFontBold, , , , .T.)
    oGetCPF := TGet():New(077, 150, bSETGET(cFunc), oPanel, 080, 012, "@R 999999", Nil, Nil, Nil, , , , .T., , , , , , , , , "C9VD", , , , , .T., .F.)

    //--- Selecao de Filiais ---
    oSayFil := TSay():New(110, 010, {|| "Filiais:"}, oPanel, , oFontBold, , , , .T.)
    
    TButton():New(125, 010, "Selecionar Filiais", oPanel, {|| aFiliais := {}, FWMsgRun(, {|| aFiliais := FwListBranches()}, "Aguarde!", "Carregando filiais...")}, 100, 015,,, .F., .T., .F.,, .F.,,, .F.)

    //--- Checkbox Forcar ---
    TCheckBox():New(160, 010, "Forcar Reprocessamento (Sobrescreve dados na T8R)", bSETGET(lForce), oPanel, 250, 012, , , , , , , , .T.)    
    
    FreeObj(oTheme)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Validation
Valida os parâmetros informados antes de avançar

@return .T. ou .F. de acordo com a validação

@author rodrigo.nicolino
@since 09/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Validation()

    Local cAno as character
    Local cMes as character

    cAno := ""
    cMes := ""

    If Len(AllTrim(cPeriodo)) != 4 .AND. Len(AllTrim(cPeriodo)) != 6

        MsgAlert("Informar Ano (AAAA) ou Mês e Ano (AAAAMM). Ex: 2025 ou 202510", "Período Inválido!") // "Informar Ano (AAAA) ou Mês e Ano (AAAAMM). Ex: 2025 ou 202510" // "Período Inválido!"

        Return .F.

    Else

        If Len(AllTrim(cPeriodo)) == 6
        
    	    cMes := SubStr(AllTrim(cPeriodo), 5, 2)
		    cAno := SubStr(AllTrim(cPeriodo), 1, 4)
        
        Else

            cAno := AllTrim(cPeriodo)

        EndIf

		If Len(AllTrim(cPeriodo)) == 6 .AND. (Val(cMes) > 12 .OR. Val(cMes) < 1)

			MsgAlert("O Mês informado inválido. Informar Ano (AAAA) ou Mês e Ano (AAAAMM). Ex: 2025 ou 202510", "Mês Inválido!")

            Return .F.
            
		ElseIf Len(AllTrim(cPeriodo)) == 4 .AND. Val(cAno) < 2018 

            MsgAlert("O Ano informado é anterior ao início do envio dos eventos periódicos do e-Social (2018).", "Ano Inválido!")

            Return .F.
        
        ElseIf Len(AllTrim(cPeriodo)) == 6 .AND. (Val(cAno) < 2018 .OR. Val(cAno) == 2018 .AND. Val(cMes) < 5)

			MsgAlert("O Período informado é anterior ao início do envio dos eventos periódicos do e-Social (05/2018).", "Período Inválido!")

            Return .F.

		EndIf

    EndIf

    If Empty(aFiliais)

        MsgAlert("É necessário informar uma Filial para realizar o processamento.", "Filial Inválida!")

        Return .F.
        
    EndIf 

    If lForce

        Return MsgNoYes("A opção de Forçar Reprocessamento, habilita a substituição de todos os registros processados anteriormente.", "Deseja Continuar?") // '"Atenção!"'
        
    EndIf 

Return MsgNoYes("Deseja Continuar?", "Processamento") // "Deseja Continuar?" // "Processamento"

//-------------------------------------------------------------------
/*/{Protheus.doc} Processing
Executa o processo de atualização da T8R

@author rodrigo.nicolino
@since 09/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Processing()

    Local aFilIn    as array
    Local cLog1     as character
    Local cTimeFim  as character
    Local cTimeIni  as character
    Local lContinue as logical
    Local lLockFree as logical
    Local lRet      as logical
    Local nX        as numeric

    aFilIn    := {}
    aProcEve  := {}
    cLog1     := ""
    cTimeFim  := ""
    cTimeIni  := Time()
    lContinue := .T.
    nX        := 0

    If !Empty(cFunc)

        cFunc := AllTrim(Posicione("C9V", 2, xFilial("C9V") + PadR(cFunc, TamSx3("C9V_ID")[1]) + "1", "C9V_CPF"))

    EndIf

    If !CreateLog()

        For nX := 1 To Len(aFiliais)

            Aadd(aFilIn, aFiliais[nX][2])

        Next

        cPeriodo := AllTrim(cPeriodo)
        
        cLog1 := "Iniciando Processamento..." + CRLF // "Iniciando Processamento..."
        cLog1 += "Data: " + DToC(Date()) + " Hora: " + cTimeIni + CRLF // "Data: " // " Hora: "
        cLog1 += "Usuário: " + cUserName + CRLF + CRLF // "Usuário: "
        cLog  += cLog1

        oEdit:Load(cLog)

        lContinue := MsgYesNo("Deseja Continuar?", "Atenção!") // "Deseja Continuar? // "Atenção!"

        If lContinue

            FwMsgRun(Nil, {|| lRet := TAFColDirf(cEmpAnt, xFilial("T3P"), aFilIn, cPeriodo, AllTrim(cFunc), lForce, @lLockFree) }, "DIRF", "Reprocessando dados analíticos...")

        EndIf
        
        cTimeFim    := Time()
        If lLockFree
            cLog1       := "Processamento concluído com sucesso!" + CRLF // "Processamento concluído com sucesso!"
            cLog1       += "Data: " + DToC(Date()) + " Hora: " + cTimeFim + CRLF + CRLF // "Data: " // " Hora: "
            cLog1       += "Tempo de processamento: " + ElapTime(cTimeIni, cTimeFim) // "Tempo de processamento: "
        Else
            cLog1       := "Processamento já sendo executado por outro processo." + CRLF 
            cLog1       += "É permitido o processamento em paralelo somente entre empresas."
        EndIf 
        cLog        += cLog1

        oEdit:Load(cLog)

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Finish
Tela final do wizard

@param oPanel - Objeto FWWizardControl()

@author rodrigo.nicolino
@since 09/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Finish(oPanel as object)
    
    Default oPanel  := Nil

    oEdit := TSimpleEditor():New(0.47, 0.47, oPanel, 480, 082,, .T.)
    
    oEdit:SetWordWrap(.T.)
    oEdit:TextFormat(2)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateLog
Cria arquivo de log

@return lLogError - Informa se houve erro na geração do Log 

@author rodrigo.nicolino
@since 09/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CreateLog()

    cArquivo  := "tafrepdirf_" + DToS(Date()) + StrTran(Time(), ":") + ".log"
    cTempPath := GetTempPath(.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExportLog
Exporta arquivo de log

@author rodrigo.nicolino
@since 09/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExportLog()

    Local cDirIni  as character
    Local cDiretor as character
    
    cDirIni   := ""
    cDiretor  := ""

    cDirIni   := Iif(GetRemoteType() == 2, "/", "C:\")
    cDiretor  := cGetFile("Todos os arquivos" + "|*.*", "Exportar Log",, cDirIni, .T., 176, .T., .T.) // "Todos os arquivos" // "Exportar Log"

    __CopyFile(cTempPath + cArquivo, cDiretor + cArquivo)

Return
