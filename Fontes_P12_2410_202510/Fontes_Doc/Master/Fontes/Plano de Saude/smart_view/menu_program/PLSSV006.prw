#include "protheus.ch"

/*/{Protheus.doc} PLSSV006
Quantidade de Inclusão /Exclusão de Beneficiários por Produto (Visão de Dados e Tabela Dinãmica)

@type function
@version 12.1.2510  
@author guilherme.bonni
@since 14/10/2024
/*/ 
Function PLSSV006()

	local oSmartView as object

	if totvs.protheus.health.smartview.plan.utils.UtilsBusinessObject():isConfig()
		oSmartView := totvs.framework.smartview.callSmartView():new("health.sv.plan.familyinclusionexclusionbenef")

		oSmartView:executeSmartView()

		oSmartView:destroy()
	endif

	freeObj(oSmartView)

Return
