#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TafAjIdT3P
Interface de Reprocessamento Analitico da DIRF.
Utiliza FWWizardControl para garantir a persistencia da sessao Protheus.

@type           Function
@author         rodrigo.nicolino
@since          09/02/2026
@version        2.0
/*/
//---------------------------------------------------------------------
Function TafAjIdT3P()

    Local oDlg          as object
    Local oNewPag       as object
    Local oStepWiz      as object
    Local oTPanel       as object

    Private aFiliais     := {}
    Private cArquivo     := ""
    Private cLog         := ""
    Private cPeriodo     := Space(6)
    Private cTempPath    := ""
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
			Aviso("Rotina de Ajuste dos IDs dos trabalhadores na tabela T3P" , "Essa rotina deve ser executada somente na filial Matriz.", { "Ok" }, 2 )
            Return Nil 
		EndIf
	EndIf

    DEFINE DIALOG oDlg TITLE "Gerenciamento do Processamento de IDs dos Trabalhadores na Tabela T3P" PIXEL STYLE nOR(WS_VISIBLE, WS_POPUP)
        
        oDlg:nWidth     := 1000
        oDlg:nHeight    := 800

        oTPanel         := TPanel():New(20,70, "Processamento dos IDs dos Trabalhadores na Tabela T3P", oDlg,,,,,, 300, 300) 
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

        oNewPag := oStepWiz:AddStep("3", {|oPanel| Finish(oPanel), FWMsgRun(, {|| Processing()}, "Processamento", "Atualizando a tabela T3P...")}) 
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
    cLink     := "https://tdn.totvs.com/pages/viewpage.action?pageId=1046837528"
    oButton   := Nil

    WizSay("Rotina de ajuste dos IDs dos trabalhadores na tabela T3P."                                      , oPanel, 007, 055, 6, "#3C769C",, .T., .F., 2, oPanel:nClientWidth * 0.47, 040) // "Rotina de ajuste dos IDs dos trabalhadores na tabela T3P."
    WizSay("Esta rotina realiza o processamento de ajuste na tabela T3P de acordo com o Período e Filial informados.", oPanel, 067, 010, 5, "#737373",, .F., .F., 1, oPanel:nClientWidth * 0.47, 040) // "Esta rotina realiza o reprocessamento da tabela T3P de acordo com o Período, Filial e Trabalhador informados."
    WizSay("Recomendamos que seja feito o backup da tabela T3P antes da utilização dessa rotina, caso haja um histórico que queira preservar.", oPanel, 127, 010, 3, "#C64840",, .F., .F., 1, oPanel:nClientWidth * 0.47, 040) // ""Recomendamos que seja feito o backup da tabela T3P antes da utilização dessa rotina, caso haja um histórico que queira preservar."

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
    Local oGetPer   as object
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

    //--- Selecao de Filiais ---
    oSayFil := TSay():New(110, 010, {|| "Filiais:"}, oPanel, , oFontBold, , , , .T.)
    
    TButton():New(125, 010, "Selecionar Filiais", oPanel, {|| aFiliais := {}, FWMsgRun(, {|| aFiliais := FwListBranches()}, "Aguarde!", "Carregando filiais...")}, 100, 015,,, .F., .T., .F.,, .F.,,, .F.)

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
    Local nRegUpd   as numeric
    Local nX        as numeric

    aFilIn    := {}
    cLog1     := ""
    cTimeFim  := ""
    cTimeIni  := Time()
    lContinue := .T.
    nRegUpd   := 0
    nX        := 0

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
        oLog:Write(cLog1)

        lContinue := MsgYesNo("Deseja Continuar?", "Atenção!") // "Deseja Continuar? // "Atenção!"

        If lContinue

            FwMsgRun(Nil, {|| lRet := TafPIdT3P(cEmpAnt, aFilIn, cPeriodo, @lLockFree, @nRegUpd) }, "Ajuste T3P", "Reprocessando dados ...")

        EndIf
        
        cTimeFim    := Time()
        If lLockFree
            cLog1       := "Processamento concluído com sucesso!" + CRLF // "Processamento concluído com sucesso!"
            cLog1       += "Quantidade de registros corrigidos: " + cValToChar(nRegUpd) + CRLF
            cLog1       += "Data: " + DToC(Date()) + " Hora: " + cTimeFim + CRLF + CRLF 
            cLog1       += "Tempo de processamento: " + ElapTime(cTimeIni, cTimeFim)
        Else
            cLog1       := "Processamento já sendo executado por outro processo." + CRLF 
            cLog1       += "É permitido o processamento em paralelo somente entre empresas."
        EndIf 
        cLog        += cLog1

        oEdit:Load(cLog)
        oLog:Write(cLog1)
        oLog:Close()

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

    TButton():New(091, 125, "Exportar Log", oPanel, {|| ExportLog()}, 50, 10,,, .F., .T., .F.,, .F.,,, .F.) // "Exportar Log"

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
    oLog      := FWFileWriter():New(cTempPath + cArquivo, .T.)
    
    oLog:Create()
/*
    If !oLog:Create()

        MsgStop("Falha ao gerar o arquivo de Log: " + CRLF + oLog:Error():Message, "Atenção!") // "Falha ao gerar o arquivo de Log: " // "Atenção!"

        lLogError := .T.

    EndIf

Return lLogError
*/
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
/*
    If lLogError

        MsgStop("Falha ao gerar o arquivo de Log: " + CRLF + oLog:Error():Message, "Atenção!") // "Falha ao gerar o arquivo de Log: " // "Atenção!"

        Return

    EndIf
*/
    cDirIni   := Iif(GetRemoteType() == 2, "/", "C:\")
    cDiretor  := cGetFile("Todos os arquivos" + "|*.*", "Exportar Log",, cDirIni, .T., 176, .T., .T.) // "Todos os arquivos" // "Exportar Log"

    __CopyFile(cTempPath + cArquivo, cDiretor + cArquivo)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafPIdT3P
Executa o processamento principal para ajustar os IDs da tabela T3P 
com base na tabela C91 (Analítico de Folha). 

Utiliza uma abordagem híbrida para máxima performance: 
- Para vínculos únicos (COUNT = 1), utiliza diretamente o retorno do Banco de Dados.
- Para múltiplos vínculos (> 1), aciona a TAFGetIdFunc para tratar exceções.

Possui controle de concorrência (Semáforo) para evitar execuções simultâneas 
e controle de transação (BeginTran/EndTran) para garantir a integridade ACID.

@type      Function
@author    rodrigo.nicolino
@since     09/02/2026
@version   3.0

@param     cEmpAnt,   character, Código da empresa anterior (ambiente)
@param     aFilIn,    array,     Array contendo as filiais selecionadas no wizard
@param     cPeriodo,  character, Período de apuração (AAAA ou AAAAMM)
@param     lLockFree, logical,   Flag passada por referência para indicar liberação/sucesso

@return    lRet, logical, Retorna .T. se o processamento ocorreu sem falhas
/*/
//-------------------------------------------------------------------
Function TafPIdT3P(cEmpAnt as character, aFilIn as array, cPeriodo as character, lLockFree as logical, nRegUpd as numeric)

    Local cNextAlias as character
    Local cQuery     as character
    Local oStmt      as object
    Local lErroTran  as logical
    Local cIdCorreto as character
    Local cSemaforo  as character

    Default aFilIn    := {}
    Default cPeriodo  := ""
    Default lLockFree := .F.
    Default nRegUpd   := 0

    lErroTran := .F.

    // 1. Controle de Concorrência (Semáforo)
    // Cria um nome único para o bloqueio baseado na Rotina + Empresa
    cSemaforo := "AJUSTE_T3P_" + cEmpAnt 

    // Tenta criar o bloqueio exclusivo. Se retornar .F., outro processo já possui o Lock.
    If !LockByName(cSemaforo, .F., .F.)
        lLockFree := .F. // Informa ao Processing() que o processo está travado
        Return .F.
    EndIf

    // Se passou do LockByName, garante que a flag indique sucesso inicial
    lLockFree := .T. 

    // 2. Montagem da Query: Traz as divergências e conta a quantidade de vínculos
    cQuery := " SELECT C91.C91_FILIAL, C91.C91_CPF, C91.C91_PERAPU, MAX(C91.C91_TRABAL) AS C91_TRABAL, COUNT(C91.C91_CPF) AS QTD_VINCULOS "
    cQuery += " FROM " + RetSQLName("C91") + " C91 "
    cQuery += " INNER JOIN " + RetSQLName("T3P") + " T3P "
    cQuery += "  ON T3P.T3P_FILIAL = C91.C91_FILIAL "
    cQuery += "  AND T3P.T3P_CPF = C91.C91_CPF "
    cQuery += "  AND T3P.T3P_PERAPU = C91.C91_PERAPU "
    cQuery += "  AND T3P.T3P_ATIVO = '1' AND T3P.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE C91.C91_FILIAL IN (?) "

    If Len(Alltrim(cPeriodo)) == 6
        cQuery += " AND C91.C91_PERAPU = ? "
    Else
        cQuery += " AND C91.C91_PERAPU BETWEEN ? AND ? "
    EndIf

    cQuery += " AND C91.C91_ATIVO = '1' AND C91.D_E_L_E_T_ = ' ' "
    cQuery += " AND T3P.T3P_BENEFI <> C91.C91_TRABAL " 
    cQuery += " GROUP BY C91.C91_FILIAL, C91.C91_CPF, C91.C91_PERAPU "

    // 3. Prepara e Executa o Statement
    oStmt := FWExecStatement():New( ChangeQuery(cQuery) )
    oStmt:SetIn( 1, aFilIn )

    If Len(Alltrim(cPeriodo)) == 6
        oStmt:SetString( 2, cPeriodo )
    Else
        oStmt:SetString( 2, SubStr(Alltrim(cPeriodo), 1, 4) + "01" )
        oStmt:SetString( 3, SubStr(Alltrim(cPeriodo), 1, 4) + "12" )
    EndIf

    cNextAlias := oStmt:OpenAlias()
    
    // Loga a query final no console
    cQuery := oStmt:getFixQuery()
    TafConOut(procname() + " - Query Executada: " + cQuery)

    // 4. Inicia a transação no banco de dados
    BeginTran(.F.)

        While (cNextAlias)->( !Eof() )

            // Identifica se é Vínculo Único ou Múltiplo
            If (cNextAlias)->QTD_VINCULOS == 1
                // A Massa: Usa o ID retornado pelo próprio banco de dados
                cIdCorreto := (cNextAlias)->C91_TRABAL
            Else
                // A Exceção: Aciona a inteligência do TAF para múltiplos vínculos
                cIdCorreto := TAFGetIdFunc( (cNextAlias)->C91_CPF, (cNextAlias)->C91_PERAPU )
            EndIf

            // Só atualiza se realmente encontrou um ID válido
            If !Empty(cIdCorreto)

                TafUpdT3P( (cNextAlias)->C91_FILIAL, (cNextAlias)->C91_CPF, (cNextAlias)->C91_PERAPU, cIdCorreto )
                /*
                If !TafUpdT3P( (cNextAlias)->C91_FILIAL, (cNextAlias)->C91_CPF, (cNextAlias)->C91_PERAPU, cIdCorreto )
                    lErroTran := .T.
                    Exit
                EndIf
                */
                nRegUpd++

            EndIf

            (cNextAlias)->( DbSkip() )
            
        EndDo

        (cNextAlias)->( DbCloseArea() ) 
/*
        // 5. Finaliza transação (Rollback ou Commit)
        If lErroTran

            DisarmTransaction()
            lLockFree := .F. // Define como .F. para cair no Log de erro do Processing()

        EndIf
*/
    EndTran()

    // 6. Libera o semáforo para o próximo usuário poder rodar a rotina
    UnlockByName(cSemaforo, .F., .F.)
    
Return !lErroTran

//-------------------------------------------------------------------
/*/{Protheus.doc} TafUpdT3P
Função auxiliar para executar o comando UPDATE (DML) na tabela T3P,
ajustando o ID do beneficiário.

@type      Function
@author    rodrigo.nicolino
@since     09/02/2026
@version   2.0

@param     cFil,      character, Filial do registro
@param     cCpf,      character, CPF do trabalhador
@param     cPerApur,  character, Período de apuração (AAAAMM)
@param     cChange,   character, Novo ID (correto) que será gravado

@return    lRet, logical, Retorna .T. se o UPDATE foi executado com sucesso
/*/
//-------------------------------------------------------------------
Function TafUpdT3P(cFil as character, cCpf as character, cPerApur as character, cChange as character)

    Local cQuery  as character
    Local lRet    as logical

    lRet := .F.

    // Comando DML sem a cláusula FROM para manter compatibilidade Multi-Banco (Oracle/Postgre/SQLServer)
    cQuery := " UPDATE " + RetSQLName("T3P") + " "
    cQuery += " SET T3P_BENEFI = '" + cChange + "' "
    cQuery += " WHERE T3P_FILIAL = '" + cFil + "' "
    cQuery += " AND T3P_PERAPU = '" + cPerApur + "' "
    cQuery += " AND T3P_CPF = '" + cCpf + "' "

    TafConOut(procname() + " - Executando DML: " + cQuery)

    // Usa TCSqlExec para operações DML. Retorno < 0 indica falha no banco.
    lRet := TCSqlExec( cQuery ) >= 0
    /*
    If TCSqlExec( cQuery ) < 0

        TafConOut("Erro ao atualizar T3P: " + TCSqlError())
        lRet := .F.

    EndIf
    */

Return lRet
