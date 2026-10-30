#INCLUDE "TOTVS.CH"
#INCLUDE "TECJ001.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECJ001
Job de Importação de Marcações de Atendentes x CAROL
@sample TECJ001()
@since	30/08/2024
@author flavio.vicco
@return Nil
/*/
//------------------------------------------------------------------------------
Function TECJ001(aParam)

	Local cNomeFile := "TECJ001intcarol"
	Local cCodEmp   := ""
	Local cCodFil   := ""
	Local lJob      := GetRemoteType() == -1 //-1= Job, 1 = Windows, 2 = Linux

	//-- Verifica se a rotina e executada atraves de um JOB
	If lJob
		//-- Execucao por JOB
		cCodEmp := aParam[1]
		cCodFil := aParam[2]
		If !Empty(cCodEmp) .And. !Empty(cCodFil)
			RpcSetType(3)
			RpcSetEnv(cCodEmp,cCodFil,,,"TEC","TECJ001",{"T40", "ABB"})
			atPRTCarol(dDataBase-1, dDataBase, lJob, .T., cNomeFile)
			RpcClearEnv()
		EndIf
	ElseIf(Aviso("TECJ001", STR0001 + CRLF + STR0004 + DToc(dDataBase), {STR0002, STR0003}) == 1) //"Confirma a importação das Marcações dos Atendentes?"##"Data processamento: "##"Sim"##"Não"
		//-- Execucao por Menu
		atPRTCarol(dDataBase, dDataBase, lJob, .T., cNomeFile)
	EndIf

Return Nil
