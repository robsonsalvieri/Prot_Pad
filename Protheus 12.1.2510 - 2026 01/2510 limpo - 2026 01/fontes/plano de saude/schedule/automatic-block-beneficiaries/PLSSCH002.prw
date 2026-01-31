#Include 'Protheus.ch'

/*/{Protheus.doc} PLSSCH002
Schedule para bloqueio automatico
@version 12.1.2510
@author diogo.sousa
@since 17/01/2025
/*/
Function PLSSCH002()
	Local nOpcao := 0

	If isBlind()
		totvs.protheus.health.plan.schedule.autoBlockBeneficiaries()
	Else

		nOpcao := Aviso("Bloqueio Automatico", "Deseja analisar ou realizar o bloqueio?", {"Analisar", "Bloquear"}, 2,/*Sub-Titulo*/)

		If nOpcao == 1
			PLSA770()
		Else
			callSchedule('PLSSCH002')
		EndIf

	EndIf
Return

/*/{Protheus.doc} schedDef
Definicao dos perguntes para o botao parametros do schedule
@type function
@version 12.1.2510
@author diogo.sousa
@since 17/01/2025
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo.
/*/
Static Function schedDef()

	Local aParams As array

	aParams := {"P", "PLSSCH002", nil, nil, nil}

Return aParams
