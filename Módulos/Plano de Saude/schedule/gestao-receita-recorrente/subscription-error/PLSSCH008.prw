#include "protheus.ch"

/*/{Protheus.doc} PLSSCH008
Schedule para reprocessar as subscrições que apresentaram erro durante a integração com o GRR.
@type function
@version 12.1.2510
@author vinicius.queiros
@since 04/06/2025
/*/
function PLSSCH008()

	if isBlind()
		totvs.protheus.health.plan.schedule.subscriptionErrorGRR()
	endif

return

/*/{Protheus.doc} schedDef
Definição dos perguntes para o botão de parãmetros do schedule
@type function
@version 12.1.2510
@author vinicius.queiros
@since 04/06/2025
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo.
/*/
static function schedDef()

	local aParams := {} as array

	aParams := {"P", "PARAMDEF", "", {}, ""}

return aParams
