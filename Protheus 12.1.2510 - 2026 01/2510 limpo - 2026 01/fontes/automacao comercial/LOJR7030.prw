#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJR7030.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJR7030
Visão de dados de vendas gerenciais (SmartView)

Chamada do objeto de negócios totvs.protheus.retail.vendasgerenciais 
e visão de dados no Smart View pela função totvs.framework.treports.callSmartView

@author  Jorge Martins
@since   15/05/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function LOJR7030()
Local oSmartView as object

	If Alltrim(__FWLibVersion()) >= "20231009" .And. totvs.framework.smartview.util.isConfig() .And. FindFunction("LJSView") // Proteção

		oSmartView := totvs.framework.smartview.callSmartView():new("varejo.sv.loja.vendasgerenciais.default.dg", "data-grid")
		oSmartView:setShowWizard(.T.)

		IIf(!oSmartView:executeSmartView(), LjGrvLog("Vendas gerenciais - SmartView", "Erro na abertura do SmartView", oSmartView:getError()), Nil)

		oSmartView:destroy()

	Else
		Help("", 1, "HELP", ProcName(0), STR0001, 1,,,,,,, {STR0002}) // "Ambiente desatualizado!" ## "Necessário versão da LIB igual ou superior a '20231009' e a configuração do Smart View no ambiente."
	EndIf

Return
