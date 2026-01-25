#include "totvs.ch"

//------------------------------------------------------------------
/*/{Protheus.doc} GRRA070STA
	@description Função usada no X3_CBOX do campo HRJ_STAT
    @author guilherme.sordi@totvs.com.br
	@since 07/03/2025
/*/
//-------------------------------------------------------------------
function GRRA070STA()
return totvs.protheus.backoffice.apps.grr.integration.financial.FinancialIntegration():getStatusCBox()

//------------------------------------------------------------------
/*/{Protheus.doc} GRRA070STA
	@description Função usada no X3_VALID do campo HRJ_STAT
    @author guilherme.sordi@totvs.com.br
	@since 07/03/2025
/*/
//-------------------------------------------------------------------
function GRRA070SVL(cValue as character)
return totvs.protheus.backoffice.apps.grr.integration.financial.FinancialIntegration():getIsValidStatus(cValue)
