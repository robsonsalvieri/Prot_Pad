#Include 'Protheus.ch'

/*/{Protheus.doc} PLSSCH007
Schedule para a programacao reajuste de preco de contrato do plano de saude
@version 12.1.2510
@author diogo.sousa
@since 09/05/2025
/*/
Function PLSSCH007()

	If IsBlind()
		totvs.protheus.health.plan.schedule.contractpriceadjustment()
	EndIf

Return

/*/{Protheus.doc} schedDef
Definicao dos perguntes para o botao parametros do schedule
@type function
@version 12.1.2510
@author diogo.sousa
@since 09/05/2025
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo
/*/
Static Function schedDef()

	Local aParams As array

	aParams := {"P", "PLSSCH007", nil, nil, nil}

Return aParams
