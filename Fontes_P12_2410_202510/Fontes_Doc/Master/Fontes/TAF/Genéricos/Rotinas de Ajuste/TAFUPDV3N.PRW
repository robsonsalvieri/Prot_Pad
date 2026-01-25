#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFUPDV3N.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFUPDV3N
Atualiza dados da tabela V3N baseado nos registros existentes nos eventos 
S-1200, S-1210, S-1299, S-2299, S-2399 e seus respectivos totalizadores

@author Melkz Siqueira 
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFUPDV3N()

    Local cCPF              := ""
    Local lExtern           := .F.
    Local oNewPag           := Nil
    Local oStepWiz          := Nil
    Local oTPanel           := Nil
    Local oDlg              := Nil

    Private aEventosParm    := {}
    Private aFiliais        := {}
    Private cLog            := ""
    Private cArquivo        := ""
    Private cTempPath       := ""
    Private __cPeriodo      := Space(6)
    Private __lForce        := .F.
    Private lLogError       := .F.
    Private oEdit           := Nil
    Private oLog            := Nil

    If FWIsAdmin(__cUserID)

        DEFINE DIALOG oDlg TITLE STR0001 PIXEL STYLE nOR(WS_VISIBLE, WS_POPUP) // "Atualiza V3N"
            
            oDlg:nWidth     := 600
            oDlg:nHeight    := 420

            oTPanel         := TPanel():New(0, 0, STR0001, oDlg,,,,,, 300, 300) // "Atualiza V3N"
            oTPanel:Align   := CONTROL_ALIGN_ALLCLIENT

            oStepWiz := FWWizardControl():New(oTPanel)
            oStepWiz:ActiveUISteps()
            
            oNewPag := oStepWiz:AddStep("1")
            oNewPag:SetStepDescription(STR0002) // "Início"
            oNewPag:SetConstruction({|oPanel| Start(oPanel)})
            oNewPag:SetCancelAction({|| .T., oDlg:End()})
            
            oNewPag := oStepWiz:AddStep("2", {|oPanel| Params(oPanel)})
            oNewPag:SetStepDescription(STR0003) // "Parâmetros"
            oNewPag:SetCancelAction({|| .T., oDlg:End()})
            oNewPag:SetNextTitle(STR0004) // "Processar"
            oNewPag:SetNextAction({|| Validation()})

            oNewPag := oStepWiz:AddStep("2", {|oPanel| Finish(oPanel), FWMsgRun(, {|oSay| Processing(oSay, lExtern, cCPF)}, STR0005, STR0006)}) // "Processamento" // "Atualizando a tabela V3N..."          
            oNewPag:SetStepDescription(STR0005) // "Processamento"
            oNewPag:SetNextTitle(STR0007) // "Fechar"
            oNewPag:SetNextAction({|| .T., oDlg:End()})
            oNewPag:SetCancelWhen({|| .F.})
            oNewPag:SetPrevWhen({|| .F.})
            
            oStepWiz:Activate()

        ACTIVATE DIALOG oDlg CENTER

        oStepWiz:Destroy()

    Else

        MsgStop(STR0008 + cUserName + STR0009, STR0010) // "Usuário sem acesso!"

    EndIf

Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Start
Monta tela de Início

@param oPanel - Objeto FWWizardControl()

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Start(oPanel)

    Local bBrower   := {|| }
    Local cLink     := "https://tdn.totvs.com/pages/viewpage.action?pageId=648041691"
    Local oButton   := Nil

    Default oPanel  := Nil

    WizSay(STR0011, oPanel, 007, 055, 6, "#3C769C",, .T., .F., 1, oPanel:nClientWidth * 0.47, 020) // "Rotina de atualização da tabela V3N"
    WizSay(STR0012, oPanel, 027, 010, 5, "#737373",, .F., .F., 1, oPanel:nClientWidth * 0.47, 040) // "Esta rotina realiza o reprocessamento da tabela V3N para todos os trabalhadores dos eventos S-1200, S-2299 e S-2399 de acordo com o Período e Filial informada."
    WizSay(STR0054, oPanel, 067, 010, 3, "#C64840",, .F., .F., 1, oPanel:nClientWidth * 0.47, 040) // "Recomendamos que seja feito o backup da tabela V3N antes da utilização dessa rotina, caso haja um histórico que queira preservar, pois a mesma realiza a exclusão lógica total dos registros da tabela V3N e recria ela, somente a partir dos registros dos eventos e totalizadores existentes na base."
    
    If GetRemoteType() == 2 

        bBrower := {|| ShellExecute("Browser", "/usr/bin/firefox", cLink, "/", 1)}

    Else

        bBrower := {|| ShellExecute("Open", cLink, "", "C:\", 1)}

    EndIf

    oButton := THButton():New(089, 85, STR0055, oPanel, bBrower, 120, 010,, cLink) // "Clique aqui para acessar a documentação"

    oButton:SetCss("QPushButton{ color: #3C769C; }")

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Params
Monta tela de parâmetros

@param oPanel - Objeto FWWizardControl()

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Params(oPanel)

    Local oTheme    as Object
    Local cTheme    as Character

    oTheme := totvs.framework.css.ProtheusTheme():New()
    cTheme := oTheme:GetTheme()

    Default oPanel      := Nil

    WizSay(STR0013, oPanel, 015, 080, 4, "#3C769C",, .T., .F., 1, oPanel:nClientWidth * 0.47, 020) // "Informe os parâmetros para o processamento:"
    
    If cTheme $ "SUNSET|CLASSIC" 
        WizSay(STR0014, oPanel, 040, 085, 3, "#383838",, .F., .F., 1, 100, 020) // "Período"
        TGet():New(038, 115, {|u| Iif(PCount() == 0, __cPeriodo, __cPeriodo := PadR(u, 6))}, oPanel, 100, 10,,, CLR_BLACK,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,,,,,, .T.) 

        WizSay(STR0015, oPanel, 060, 085, 3, "#383838",, .F., .F., 1, 100, 020) // "Filial:"
        TButton():New(058, 115, STR0016, oPanel, {|| aFiliais := {}, FWMsgRun(, {|| aFiliais := FwListBranches()}, "Aguarde!", "Carregando filiais...")}, 100, 10,,, .F., .T., .F.,, .F.,,, .F.) // "Selecionar Filial"
    Else
        WizSay(STR0014, oPanel, 040, 085, 3, "#3C769C",, .F., .F., 1, 100, 020) // "Período"
        TGet():New(038, 115, {|u| Iif(PCount() == 0, __cPeriodo, __cPeriodo := PadR(u, 6))}, oPanel, 100, 10,,, CLR_WHITE,,, .F.,, .T.,, .F.,, .F., .F.,, .F., .F.,,,,,, .T.)

        WizSay(STR0015, oPanel, 060, 085, 3, "#3C769C",, .F., .F., 1, 100, 020) // "Filial:"
        TButton():New(058, 115, STR0016, oPanel, {|| aFiliais := {}, FWMsgRun(, {|| aFiliais := FwListBranches()}, "Aguarde!", "Carregando filiais...")}, 100, 10,,, .F., .T., .F.,, .F.,,, .F.) // "Selecionar Filial"
    EndIf        

    

    TCheckBox():New(078, 085, STR0017, {|| __lForce}, oPanel, oPanel:nClientWidth * 0.47, 020,, {|| __lForce := !__lForce},,,,,, .T.) // "Forçar reprocessamento dos Totalizadores"
    
    FreeObj(oTheme)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Validation
Valida os parâmetros informados antes de avançar

@return .T. ou .F. de acordo com a validação

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Validation()

    Local cMes := ""
    Local cAno := ""

    If Len(AllTrim(__cPeriodo)) != 4 .AND. Len(AllTrim(__cPeriodo)) != 6

        MsgAlert(STR0018, STR0019) // "Informar Ano (AAAA) ou Mês e Ano (MMAAAA). Ex: 2021 ou 102021" // "Período Inválido!"

        Return .F.

    Else

        If Len(AllTrim(__cPeriodo)) == 6
        
    	    cMes := SubStr(AllTrim(__cPeriodo), 1, 2)
		    cAno := SubStr(AllTrim(__cPeriodo), 3, 4)
        
        Else

            cAno := AllTrim(__cPeriodo)

        EndIf

		If Len(AllTrim(__cPeriodo)) == 6 .AND. (Val(cMes) > 12 .OR. Val(cMes) <= 0)

			MsgAlert(STR0020, STR0021) // "O Mês informado inválido. Informar Ano (AAAA) ou Mês e Ano (MMAAAA). Ex: 2021 ou 102021" // "Mês Inválido!"

            Return .F.
            
		ElseIf Len(AllTrim(__cPeriodo)) == 4 .AND. Val(cAno) < 2018 

            MsgAlert(STR0022, STR0023) // "O Ano informado é anterior ao início do envio dos eventos periódicos do e-Social (2018)." // "Ano Inválido!"

            Return .F.
        
        ElseIf Len(AllTrim(__cPeriodo)) == 6 .AND. (Val(cAno) < 2018 .OR. Val(cAno) == 2018 .AND. Val(cMes) < 5)

			MsgAlert(STR0024, STR0019) // "O Período informado é anterior ao início do envio dos eventos periódicos do e-Social (05/2018)." // "Período Inválido!"

            Return .F.

		EndIf

    EndIf

    If Empty(aFiliais)

        MsgAlert(STR0025, STR0026) // "É necessário informar uma Filial para realizar o processamento." // "Filial Inválida!"

        Return .F.
        
    EndIf 

    If __lForce

        Return MsgNoYes(STR0027 + CRLF + CRLF + STR0028, STR0029) // "A opção de Forçar Reprocessamento dos Totalizadores, habilita a substituição de todos os totalizadores do período e filial selecionada no processamento." // "Deseja Continuar?" // '"Atenção!"'
        
    EndIf 

Return MsgNoYes(STR0028, STR0005) // "Deseja Continuar?" // "Processamento"


//-------------------------------------------------------------------
/*/{Protheus.doc} Processing
Executa o processo de atualização da V3N

@param oSay - Objeto FWMsgRun()
@param lExtern - Informa se é uma chamada de fora do TAF
@param cCPF - CPF do trabalhador

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Processing(oSay, lExtern, cCPF)

    Local aEvents   := {"S-1200", "S-1210", "S-1299", "S-2299", "S-2399"}
    Local aProcEve  := {}
    Local cTimeIni  := Time()
    Local cTimeFim  := ""
    Local cLog1     := ""
    Local lContinue := .T.

    Default cCPF    := ""
    Default lExtern := .F.
    Default oSay    := Nil

    If !CreateLog()

        __cPeriodo := AllTrim(__cPeriodo)

        aEval(aEvents, {|x| aAdd(aProcEve, TAFRotinas(x, 4, .F., 2))})
        
        cLog1 := STR0030 + CRLF // "Iniciando Processamento..."
        cLog1 += STR0031 + DToC(Date()) + STR0032 + cTimeIni + CRLF // "Data: " // " Hora: "
        cLog1 += STR0033 + cUserName + CRLF + CRLF // "Usuário: "
        cLog  += cLog1

        oEdit:Load(cLog)
        oLog:Write(cLog1)

        If !CleanV3N(aEvents)

            lContinue := MsgYesNo(STR0039 + CRLF + CRLF + STR0028, STR0029) // "Não há registros para serem apagados." // "Deseja Continuar? // "Atenção!"

        EndIf

        If lContinue

            ForceTotal(aProcEve)
            _TAFProc5Tss(aProcEve, oSay)
            _ChargeINSS(oSay)
            _RptCharge(oSay, lExtern, cCPF)

        EndIf
        
        cTimeFim    := Time()
        cLog1       := STR0034 + CRLF // "Processamento concluído com sucesso!"
        cLog1       += STR0031 + DToC(Date()) + STR0032 + cTimeFim + CRLF + CRLF // "Data: " // " Hora: "
        cLog1       += STR0035 + ElapTime(cTimeIni, cTimeFim) // "Tempo de processamento: "
        cLog        += cLog1

        oEdit:Load(cLog)
        oLog:Write(cLog1)
        oLog:Close()

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CleanV3N
Apaga todos os registros da V3N conforme filiais e período informado
antes de recria-la

@param aEvents - Eventos a serem processados
@return lRet - Informa se houve registros apagados

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CleanV3N(aEvents)

    Local aArea     := GetArea()
    Local aConvFil  := {} 
    Local cEvents   := "%"
    Local cCachFil  := ""
    Local cV3N      := GetNextAlias()
    Local cIndApu   := Iif(Len(__cPeriodo) < 6, "%'2'%", "%'1'%") 
    Local cAnoMes   := Iif(Len(__cPeriodo) < 6, "%'" + __cPeriodo + "'%", "%'" + Right(__cPeriodo, 4) + Left(__cPeriodo, 2) + "'%")
    Local cTimeIni  := Time()
    Local cTimeFim  := ""
    Local cLogDel   := ""
    Local cLog2     := ""
    Local lRet      := .F.
    
    Default aEvents := {}

    aEval(aEvents, {|x| cEvents += "'" + x + "', " })
    aEval(aFiliais, {|x| aAdd(aConvFil, x[2])})
    
    cLog2       := STR0036 + CRLF // "Apagando registros da tabela V3N..."
    cLog        += cLog2
    cEvents     += "'" + Space(GetSx3Cache("V3N_EVENTO", "X3_TAMANHO")) + "' %"
    cCachFil    := TAFCacheFil("V3N", aConvFil)
    
    oEdit:Load(cLog)
    oLog:Write(cLog2)

    BeginSQL Alias cV3N
    
        SELECT V3N.R_E_C_N_O_ AS RECNO
            FROM %table:V3N% V3N
            WHERE V3N.%notdel%
                AND V3N.V3N_FILIAL IN (
					SELECT FILIAIS.FILIAL 
						FROM %temp-table:cCachFil% FILIAIS
				)
                AND V3N.V3N_INDAPU = %exp:cIndApu%
                AND V3N.V3N_PERAPU = %exp:cAnoMes% 
                AND V3N.V3N_EVENTO IN (%exp:cEvents%)

    EndSQL

    (cV3N)->(DBGoTop())

    If !(cV3N)->(Eof())

            lRet    := .T.
            cLogDel := "V3N_FILIAL|V3N_INDAPU|V3N_PERAPU|V3N_CPF|V3N_EVENTO|V3N_ORIGEM|R_E_C_N_O_" + CRLF
            
            oLog:Write(cLogDel)

        While !(cV3N)->(Eof())

            V3N->(DBGoTo((cV3N)->RECNO))

            If V3N->(RecLock("V3N", .F.))

                V3N->(DBDelete())
                V3N->(MsUnlock())

                cLogDel := V3N->(V3N_FILIAL + "|" + V3N_INDAPU + "|" + V3N_PERAPU + "|" + V3N_CPF + "|" + V3N_EVENTO + "|" + V3N_ORIGEM) + "|" + AllTrim(Str((cV3N)->RECNO)) + CRLF
                
                oLog:Write(cLogDel)

            EndIf

            (cV3N)->(DBSkip())

        EndDo
        
        cTimeFim    := Time()
        cLog2       := STR0037 + CRLF // "Registros apagados da tabela V3N com êxito!"
        cLog2       += STR0038 + ElapTime(cTimeIni, cTimeFim) + CRLF + CRLF // "Tempo decorrido: "
        cLog        += cLog2

        oEdit:Load(cLog)
        oLog:Write(cLog2)
        
    Else

        cLog2   := STR0039 + CRLF + CRLF // "Não há registros para serem apagados."
        cLog    += cLog2

        oEdit:Load(cLog)
        oLog:Write(cLog2)

    EndIf

    (cV3N)->(DBCloseArea())

    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ForceTotal
Força o reprocessamento dos Totalizadores

@param aEvents - Eventos a serem processados

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ForceTotal(aEvents)

    Local aArea         := {}
    Local cAnoMes       := Iif(Len(__cPeriodo) < 6, __cPeriodo, Right(__cPeriodo, 4) + Left(__cPeriodo, 2))
    Local cDataIni      := cAnoMes + "01" 
    Local cDataFim      := cAnoMes + "31" 
    Local cTimeIni      := Time()
    Local cTimeFim      := ""
    Local cUpdate       := ""
    Local cWhere        := ""
    Local cQuery        := ""
    Local cLog3         := ""
    Local nX	        := 0
    Local nI	        := 0

    Default aEvents     := {}

    If __lForce

        aArea := GetArea()

        cLog3   := STR0042 + CRLF // "Forçando o reprocessamento dos Totalizadores..."
        cLog    += cLog3
        
        oEdit:Load(cLog)
        oLog:Write(cLog3)
    
        For nI := 1 To Len(aFiliais)

            For nX := 1 To Len(aEvents)

                cLog3   := STR0043 + aFiliais[nI][2] + STR0044 + aEvents[nX][4] + STR0045 + aEvents[nX][3] + CRLF // "Filial: " // " Evento: " // " Tabela: "
                cLog    += cLog3

                oEdit:Load(cLog)
                oLog:Write(cLog3)

                cUpdate := "UPDATE "+ RetSqlName( aEvents[nX][3] ) + " SET " + aEvents[nX][3] + "_GRVTOT = 'F' "
                cWhere	:= "WHERE " + aEvents[nX][3] + "_FILIAL = '" + aFiliais[nI][2] + "' "

                If aEvents[nX][3] $ "C91|T3P|T72|CUO"
                   
                    cWhere  += "AND " + aEvents[nX][3] + "_PERAPU BETWEEN '" + cAnoMes + "' AND '" + cAnoMes + "' "
               
                ElseIf aEvents[nX][3] $ "CMD"
                    
                    cWhere  += "AND " + aEvents[nX][3] + "_DTDESL BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
                
                ElseIf aEvents[nX][3] $ "T92"
                    
                    cWhere  += "AND " + aEvents[nX][3] + "_DTERAV BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
                
                EndIf

                cWhere	+= "AND " + aEvents[nX][3] + "_STATUS = '4' "
                cWhere	+= "AND " + aEvents[nX][3] + "_ATIVO = '1' "
                cWhere	+= "AND D_E_L_E_T_ = ' ' "

                cQuery  := cUpdate + cWhere

                TCSqlExec(cQuery)

            Next nX

        Next nI
        
        cTimeFim    := Time()
        cLog3       := STR0046 + CRLF // "Reprocessamento dos Totalizadores concluído com êxito!"
        cLog3       += STR0038 + ElapTime(cTimeIni, cTimeFim) + CRLF + CRLF // "Tempo decorrido: "
        cLog        += cLog3

        oEdit:Load(cLog)
        oLog:Write(cLog3)
   
        RestArea(aArea)

    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} _TAFProc5Tss
Processo responsavel por verificar os registros que devem ser consultados no TSS.

@param aProcEve - Array TAFRotinas()
@param oSay - Objeto FWMsgRun()

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function _TAFProc5Tss(aProcEve, oSay)

    Local aArea     := GetArea()
    Local cTimeIni  := Time()
    Local cTimeFim  := ""
    Local cLog4     := ""
    Local cMes      := SubStr(AllTrim(__cPeriodo), 1, 2)
	Local cAno      := SubStr(AllTrim(__cPeriodo), 3, 4)
    Local cPer      := cAno + cMes
    Local dDataIni  := SToD(cAno + cMes + "01")
    Local dDataFim  := SToD(cAno + cMes + "31")

    cLog4   := STR0047 + CRLF // "Atualizando dados dos Totalizadores na tabela V3N..."
    cLog    += cLog4

    oEdit:Load(cLog)
    oLog:Write(cLog4)

    TAFProc5Tss(.T., aProcEve, "4",,, .F.,, aFiliais, dDataIni, dDataFim,,,,,,,,, oSay, cPer)

    cTimeFim    := Time()
    cLog4       := STR0048 + CRLF // "Atualização dos dados dos Totalizadores na tabela V3N concluída com êxito!"
    cLog4       += STR0038 + ElapTime(cTimeIni, cTimeFim) + CRLF + CRLF // "Tempo decorrido: "
    cLog        += cLog4

    oEdit:Load(cLog)
    oLog:Write(cLog4)

    RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChargeINSS
Executa a carga na tabela V3N para INSS

@param oSay - Objeto FWMsgRun()

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function _ChargeINSS(oSay)

    Local aArea     := GetArea()
    Local cTimeIni  := Time()
    Local cTimeFim  := ""
    Local cLog5     := ""

    cLog5   := STR0040 + CRLF // "Atualizando dados de INSS dos Eventos S-1200, S-2299, S-2399 e S-5001 na tabela V3N..."
    cLog    += cLog5

    oEdit:Load(cLog)
    oLog:Write(cLog5)

    ChargeINSS(oSay, aFiliais, __cPeriodo)

    cTimeFim    := Time()
    cLog5       := STR0041 + CRLF // "Atualização dados de INSS dos Eventos S-1200, S-2299, S-2399 e S-5001 na tabela V3N concluída com êxito!"
    cLog5       += STR0038 + ElapTime(cTimeIni, cTimeFim) + CRLF + CRLF // "Tempo decorrido: "
    cLog        += cLog5

    oEdit:Load(cLog)
    oLog:Write(cLog5)
    
    RestArea(aArea)     

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} _RptCharge
Executa a carga na tabela V3N para FGTS

@param oSay - Objeto FWMsgRun()
@param lExtern - Informa se é uma chamada fora do TAF
@param cCPF - CPF do trabalhador

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function _RptCharge(oSay, lExtern, cCPF)

    Local aArea     := GetArea()
    Local cTimeIni  := Time()
    Local cTimeFim  := ""
    Local cLog6     := ""

    cLog6   := STR0052 + CRLF // "Atualizando dados de FGTS dos Eventos S-1200, S-2299, S-2399 e S-5003 na tabela V3N..."
    cLog    += cLog6

    oEdit:Load(cLog)
    oLog:Write(cLog6)

    RptCharge(oSay, lExtern, __cPeriodo, aFiliais, cCPF)
    
    cTimeFim    := Time()
    cLog6       := STR0053 + CRLF // "Atualização dados de FGTS dos Eventos S-1200, S-2299, S-2399 e S-5003 na tabela V3N concluída com êxito!"
    cLog6       += STR0038 + ElapTime(cTimeIni, cTimeFim) + CRLF + CRLF // "Tempo decorrido: "
    cLog        += cLog6

    oEdit:Load(cLog)
    oLog:Write(cLog6)

    RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Finish
Tela final do wizard

@param oPanel - Objeto FWWizardControl()

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Finish(oPanel)
    
    Default oPanel  := Nil

    oEdit := TSimpleEditor():New(0.47, 0.47, oPanel, 293, 082,, .T.)
    
    oEdit:SetWordWrap(.T.)
    oEdit:TextFormat(2)

    TButton():New(091, 125, STR0049, oPanel, {|| ExportLog()}, 50, 10,,, .F., .T., .F.,, .F.,,, .F.) // "Exportar Log"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateLog
Cria arquivo de log

@return lLogError - Informa se houve erro na geração do Log 

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CreateLog()

    cTempPath   := GetTempPath(.T.)
    cArquivo    := "tafupdv3n_" + DToS(Date()) + StrTran(Time(), ":") + ".log"
    oLog        := FWFileWriter():New(cTempPath + cArquivo, .T.)

    If !oLog:Create()

        MsgStop(STR0051 + CRLF + oLog:Error():Message, STR0029) // "Falha ao gerar o arquivo de Log: " // "Atenção!"

        lLogError := .T.

    EndIf


Return lLogError

//-------------------------------------------------------------------
/*/{Protheus.doc} ExportLog
Exporta arquivo de log

@author Melkz Siqueira
@since 29/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExportLog()
    
    Local cDirIni   := ""
    Local cDiretor  := ""

    If lLogError

        MsgStop(STR0051 + CRLF + oLog:Error():Message, STR0029) // "Falha ao gerar o arquivo de Log: " // "Atenção!"

        Return

    EndIf

    cDirIni   := Iif(GetRemoteType() == 2, "/", "C:\")
    cDiretor  := cGetFile(STR0050 + "|*.*", STR0049,, cDirIni, .T., 176, .T., .T.) // "Todos os arquivos" // "Exportar Log"

    __CopyFile(cTempPath + cArquivo, cDiretor + cArquivo)

Return
