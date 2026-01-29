#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP060.CH"

#DEFINE PropriedadeRuralService agd.propriedadeRuralService.agdPropriedadeRuralService

/*/{Protheus.doc} AGDP060EVT
Classe de eventos do modelo do AGDP060
@type class
@version 12
@author AgroDistribuidor
@since 24/09/2025
/*/
Class AGDP060EVT From FWModelEvent

	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)

End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author AgroDistribuidor
@since 24/09/2025
@return variant, self
/*/
Method New() Class AGDP060EVT
Return Nil


/*/{Protheus.doc} ModelPosVld
Validação do Modelo de Dados
@type method
@version 12
@author AgroDistribuidor
@since 07/01/2026
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDP060EVT

	Local oModelNEP := oModel:GetModel("AGDP060_NEP")
	Local oPropService := PropriedadeRuralService():New()

	// Validação de Altitude obrigatória para SC e Propriedade Rural
	cCodCli := oModelNEP:GetValue("NEP_CODCLI")
	cLojCli := oModelNEP:GetValue("NEP_LOJCLI")
	cAltitu := oModelNEP:GetValue("NEP_ALTITU")
	cProRur := oModelNEP:GetValue("NEP_PRORUR")

	// Só exige altitude se for propriedade rural (NEP_PRORUR = 1) e UF = SC
	If cProRur == "1" .and. oPropService:validaUfSc(cCodCli, cLojCli)
		If Empty(cAltitu)
			AGDHELP(STR0007,STR0013, STR0014) //"Ajuda"#" Altitude obrigatória para propriedades de SC."#"Informe o campo Altitude."
			Return .F.
		EndIf
	EndIf

Return .T.
