#Include 'Protheus.ch'

/*/{Protheus.doc} PLSSCH004
Schedule para a programacao do calculo de comissao
@version 12.1.2510
@author diogo.sousa
@since 10/03/2025
/*/
Function PLSSCH004()

	If IsBlind()
		totvs.protheus.health.plan.schedule.commissionProgramCalculator()
	EndIf

Return

/*/{Protheus.doc} schedDef
Definicao dos perguntes para o botao parametros do schedule
@type function
@version 12.1.2510
@author diogo.sousa
@since 10/03/2025
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo.
/*/
Static Function schedDef()

	Local aParams As array

	aParams := {"P", "PLM150", nil, nil, nil}

Return aParams
