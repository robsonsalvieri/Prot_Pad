#include "protheus.ch"

/*/{Protheus.doc} PLSSV004
Apresenta cadastro de Beneficiários e também informações de seu contrato

@type function
@version 12.1.2510  
@author guilherme.bonni
@since 07/10/2024
/*/ 
Function PLSSV004()

	local oSmartView as object

	if totvs.protheus.health.smartview.plan.utils.UtilsBusinessObject():isConfig()
		oSmartView := totvs.framework.smartview.callSmartView():new("health.sv.plan.beneficiariesregistration.default.dg", "data-grid")

		oSmartView:executeSmartView()

		oSmartView:destroy()
	endif

	freeObj(oSmartView)

Return 

