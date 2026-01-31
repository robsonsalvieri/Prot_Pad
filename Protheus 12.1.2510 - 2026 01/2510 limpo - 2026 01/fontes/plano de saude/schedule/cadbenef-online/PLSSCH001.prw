#include "protheus.ch"

/*/{Protheus.doc} PLSSCH001
Schedule para geracao dos lotes de envio dos beneficiarios do Cadbenef Online
@version 12.1.2510
@author vinicius.queiros
@since 18/10/2024
/*/
function PLSSCH001()

	if isBlind()
		totvs.protheus.health.plan.schedule.cadBenefBatch()
	endif

return

/*/{Protheus.doc} schedDef
Definicao dos perguntes para o botao parametros do schedule
@type function
@version 12.1.2510
@author vinicius.queiros
@since 18/10/2024
@return array, com o tipo (P = Processo e R = Relatorios), pergunte, alias, ordem e titulo.
/*/
static function schedDef()

	local aParams as array

	aParams := {"P", "PLSSCH001", nil, nil, nil}

return aParams
