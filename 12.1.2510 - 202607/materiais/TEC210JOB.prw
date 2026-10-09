#INCLUDE "TOTVS.CH"

///------------------------------------------------------------------------------
// /{Protheus.doc} TEC210JOB
// Job responsável pela execução da rotina At210Auto via Schedule,
// garantindo o processamento automático dos contratos e geração de O.S.
// @author Silas Gomes
// @since 27/04/2026
// @version 1.0
//------------------------------------------------------------------------------
Function TEC210JOB(aParam)

	Local cCodEmp   := ""
	Local cCodFil   := ""
	Local lAbriuEnv := .F.

	FWLogMsg("INFO",, "TEC210JOB",,,, "Iniciando TEC210JOB...")

	Begin Sequence
	
		cCodEmp := aParam[1]
		cCodFil := aParam[2]

		FWLogMsg("INFO",, "TEC210JOB",,,, "Empresa recebida: " + cCodEmp)
		FWLogMsg("INFO",, "TEC210JOB",,,, "Filial recebida : " + cCodFil)		

		RpcSetType(3)
		RpcSetEnv(cCodEmp, cCodFil,,,"TEC","TEC210JOB")
		lAbriuEnv := .T.

		At210Auto()

	End Sequence

	If lAbriuEnv
		RpcClearEnv()
	EndIf

	FWLogMsg("INFO",, "TEC210JOB",,,, "Finalizando TEC210JOB...")	

Return Nil
