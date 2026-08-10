#Include 'Protheus.ch'

/*/{Protheus.doc} PLSSCH003
Schedule para calculo de comissao
@version 12.1.2510
@author diogo.sousa
@since 19/02/2025
/*/
Function PLSSCH003()

	If IsBlind()
		totvs.protheus.health.plan.schedule.salesCommissionCalculator()
	EndIf
    
Return

/*/{Protheus.doc} schedDef
Definicao dos perguntes para o botao parametros do schedule
@type function
@version 12.1.2510
@author diogo.sousa
@since 19/02/2025
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo.
/*/
Static Function schedDef()

	Local aParams As array

	aParams := {"P", "PLM151", nil, nil, nil}

Return aParams
