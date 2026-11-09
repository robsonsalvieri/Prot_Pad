#INCLUDE "TOTVS.CH"
#INCLUDE "TECJ002.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECJ002
	Job de Importação de Marcações via clockin de Atendentes x Carol
	@type function
	@since	21/07/2026
	@author Breno.gomes
/*/
//------------------------------------------------------------------------------
Function TECJ002(aParam)

	Local cNomeFile := "TECJ002intcarol"
	Local cCodEmp   := ""
	Local cCodFil   := ""
	Local lJob      := GetRemoteType() == -1 //-1= Job, 1 = Windows, 2 = Linux

	If lJob
		cCodEmp := aParam[1]
		cCodFil := aParam[2]
		If !Empty(cCodEmp) .And. !Empty(cCodFil)
			RpcSetType(3)
			RpcSetEnv(cCodEmp,cCodFil,,,"TEC","TECJ002",{"T40", "ABB"})
			atPRTCarol(dDataBase-1, dDataBase, lJob, .T., cNomeFile, .F.)
			RpcClearEnv()
		EndIf
	ElseIf(Aviso("TECJ002", STR0001 + CRLF + STR0002 + DToc(dDataBase), {STR0003, STR0004}) == 1) //"Confirma a importação das Marcações dos Atendentes?"##"Data do Processamento: "##"Sim"##"Não"
		atPRTCarol(dDataBase, dDataBase, lJob, .T., cNomeFile, .F.)
	EndIf

Return Nil
