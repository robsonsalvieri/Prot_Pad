#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FILEIO.ch"
#INCLUDE "GPEM944SCH.CH"


/*/{Protheus.doc} GPEM944SCH
Tela de Importação do arquivo de empréstimos do Programa Crédito do Trabalhador.
@since	27/11/2025
@autor	caio.kretzer
@version P12
/*/
Function GPEM944SCH()
	Processa({|| fGPEM944()})
Return


Static Function fGPEM944()
	Local cFilImp		:= MV_PAR01             as Character
	Local lAtualiza		:= MV_PAR02             as Logical
	Local cArqImp		:= MV_PAR03             as Character
	Local cMsgErro		:= ""                   as Character
	Local lSimula		:= .F.                  as Logical
    Local lRet          := .F.                  as Logical

	Private cTipoImp	:= ""                   as Character
	Private cJsnVers	:= ""                   as Character
    Private aTitle      := {}                   as Array
    Private aDados      := {}                   as Array
    Private oJson       := JsonObject():New()   as Object

    ProcRegua(1)

    Aadd(aTitle, OemToAnsi(STR0001))

	lRet := f944LerArq(@oJson, @cMsgErro, @cArqImp)
	If lRet
		lRet := f944IniGrv(@oJson, @cMsgErro, lSimula, lAtualiza, ,cFilImp)
	EndIf

    If lRet
        FERASE(cArqImp)
    Else
        AAdd(aDados, cMsgErro)
    Endif
    fCreateLog({aDados}, aTitle)

    IncProc()

Return


/*/{Protheus.doc} fCreateLog
    Cria o log da execução em segundo plano.
    @type Function
    @version 12.1.2310
    @author caio.kretzer
    @since 27/11/2025
    @param aLogs, Array, Mensagens de logs
    @param aTitle, Array, Títulos das mensagens de log
    @return Variant, Retorno nulo pré-fixado
/*/
Static Function fCreateLog( aLogs As Array, aTitle As Array ) As Variant
    // Declaração e inicialização das variáveis
    Local cFile   := "" As Character
    Local nLogs   := 0  As Numeric
    Local nLogs2  := 0  As Numeric
    Local nHandle := 0  As Numeric

    // Monta o caminho e nome do arquivo de log
    cFile := "spool\GPEM944SCH_" + FwTimeStamp(1) + ".log" // "Segundo Plano"

    // Se o arquivo de log já existir, o exclui
    If (File(cFile))
        FErase(cFile)
    EndIf

    // Cria o arquivo
    nHandle := FCreate(cFile)

    // Verifica se o arquivo foi criado com sucesso
    If (nHandle >= 0)
        // Escreve o título do arquivo
        FWrite(nHandle, Replicate("*", 134) + CRLF)
        FWrite(nHandle, OemToAnsi(STR0002) + CRLF + CRLF) 												// "Log de Ocorrências da Execução em Segundo Plano - Credito do Trabalhador"
        FWrite(nHandle, AllTrim(FwEmpName(cEmpAnt)) + "/" + AllTrim(FwFilialName()) + CRLF)
        FWrite(nHandle, OemToAnsi(STR0003)  + " "   + DToC(dDataBase) + CRLF) 							// "Data de Referência:"
        FWrite(nHandle, OemToAnsi(STR0004) + " "   + Time() + CRLF) 									// "Hora:"
        FWrite(nHandle, OemToAnsi(STR0005) + " "   + DToC(MsDate()) + CRLF) 							// "Emissão:"
        FWrite(nHandle, Replicate("*", 134) + CRLF + CRLF + CRLF)

        // Percorre o vetor de logs para escrever no arquivo
        For nLogs := 1 To Len(aLogs)
            If (Len(aLogs[nLogs]) > 0)
                // Escreve o título
                FWrite(nHandle, aTitle[nLogs] + CRLF + CRLF)

                // Escreve as linhas
                For nLogs2 := 1 To Len(aLogs[nLogs])
                    FWrite(nHandle, aLogs[nLogs][nLogs2] + CRLF)
                Next nLogs2

                // Pula de linha
                FWrite(nHandle, CRLF + CRLF)
            EndIf
        Next nLogs

        // Fecha o arquivo
        FClose(nHandle)

        GPESmartViewUtils():CreateLogRegSegPlan(STR0006, cFile)
    EndIf
Return NIL

/*/{Protheus.doc} SchedDef
    Definições de agendamento do Schedule.
    @type Function
    @version 12.1.2410
    @author caio.kretzer
    @since 25/11/2025
    @return Array, Definições do agendamento
/*/
Static Function SchedDef() As Array
    // Declaração das variáveis locais
    Local aParam As Array

    // Inicialização das variáveis
    aParam := {}

    // Montagem da estrutura do vetor de retorno
    AAdd(aParam, "P")       // Tipo do agendamento: "P" = Processo | "R" = Relatório
    AAdd(aParam, "GPEM944SCH") // Pergunte (SX1) (usar "PARAMDEF" caso não tenha conjunto de perguntas)
    AAdd(aParam, "")        // Alias principal (exclusivo para relatórios)
    AAdd(aParam, {})        // Vetor de ordenação (exclusivo para relatórios)
    AAdd(aParam, "")        // Título (exclusivo para relatórios)
Return aParam
