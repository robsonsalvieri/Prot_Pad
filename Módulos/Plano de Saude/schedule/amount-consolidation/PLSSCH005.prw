#Include 'Protheus.ch'

/*/{Protheus.doc} PLSSCH005
Schedule para a programacao da consolidacao de valores
@version 12.1.2510
@author diogo.sousa
@since 03/04/2025
/*/
Function PLSSCH005()

	If IsBlind()
		totvs.protheus.health.plan.schedule.amountConsolidation()
	EndIf

Return

/*/{Protheus.doc} schedDef
Definicao dos perguntes para o botao parametros do schedule
@type function
@version 12.1.2510
@author diogo.sousa
@since 03/04/2025
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo.
/*/
Static Function schedDef()

	Local aParams As array

	aParams := {"P", "PLS180", nil, nil, nil}

Return aParams
