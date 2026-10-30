#INCLUDE "TOTVS.CH"

//------------------------------------------------------------------------------
// /{Protheus.doc} TEC250JOB
// Job responsável pela execução da rotina At250Auto via Schedule,
// garantindo o processamento automático dos contratos de serviço.
// @author Silas Gomes
// @since 27/04/2026
// @version 1.0
//------------------------------------------------------------------------------
Function TEC250JOB(aParam)

	Local cCodEmp   := ""
	Local cCodFil   := ""
	Local cCodUser  := ""
	Local lAbriuEnv := .F.

	FWLogMsg("INFO",, "TEC250JOB",,,, "Iniciando TEC250JOB...")

	Begin Sequence

		cCodEmp  := aParam[1]
		cCodFil  := aParam[2]
		cCodUser := aParam[3]

		FWLogMsg("INFO",, "TEC250JOB",,,, "Empresa recebida: " + cCodEmp)
		FWLogMsg("INFO",, "TEC250JOB",,,, "Filial recebida : " + cCodFil)
		FWLogMsg("INFO",, "TEC250JOB",,,, "Usuario recebido: " + cCodUser)

		RpcSetType(3)
		RpcSetEnv(cCodEmp, cCodFil,,,"TEC","TEC250JOB")
		lAbriuEnv := .T.	

		At250Auto(cCodUser)

	End Sequence

	If lAbriuEnv
		RpcClearEnv()
	EndIf

	FWLogMsg("INFO",, "TEC250JOB",,,, "Finalizando TEC250JOB...")
	
Return Nil
