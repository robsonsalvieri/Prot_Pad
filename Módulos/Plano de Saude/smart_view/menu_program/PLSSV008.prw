#include "protheus.ch"

/*/{Protheus.doc} PLSSV008
Cadastro de Rede de Atendimento - Smart View (Relatório)

@type function
@version 12.1.2510  
@author guilherme.bonni
@since 15/10/2024
/*/ 
Function PLSSV008()

	local oSmartView as object

	if totvs.protheus.health.smartview.plan.utils.UtilsBusinessObject():isConfig()
		oSmartView := totvs.framework.smartview.callSmartView():new("health.sv.plan.servicenetwork.default.rep", "report")

		oSmartView:executeSmartView()

		oSmartView:destroy()
	endif

	freeObj(oSmartView)

Return 
