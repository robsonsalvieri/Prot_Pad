#Include 'Protheus.ch'

/*/{Protheus.doc} PLSSCH006
Schedule para a programacao reajuste de preco de produtos do plano de saude
@version 12.1.2510
@author diogo.sousa
@since 07/04/2025
/*/
Function PLSSCH006()

	If IsBlind()
		totvs.protheus.health.plan.schedule.productPriceAdjustment()
	EndIf

Return

/*/{Protheus.doc} schedDef
Definicao dos perguntes para o botao parametros do schedule
@type function
@version 12.1.2510
@author diogo.sousa
@since 07/04/2025
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo
/*/
Static Function schedDef()

	Local aParams As array

	aParams := {"P", "PLSSCH006", nil, nil, nil}

Return aParams
