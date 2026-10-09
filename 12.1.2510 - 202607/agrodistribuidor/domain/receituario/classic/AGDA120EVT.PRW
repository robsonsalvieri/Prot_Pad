#Include "agda120evt.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE RECIPE_REPOSITORY totvs.protheus.agrobusiness.agd.RecipeRepository

/*/{Protheus.doc} AGDA120EVT
Classe de eventos do modelo do AGDA120
@type class
@version P12
@author jean.schulze
@since 26/11/2025
/*/
Class AGDA120EVT From FWModelEvent
	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)
End Class

/*/{Protheus.doc} New
Constructor
@type method
@version P12
@author jean.schulze
@since 26/11/2025
/*/
Method New() Class AGDA120EVT
Return Nil


/*/{Protheus.doc} ModelPosVld
Pós valid
@type method
@version p12
@author jean.schulze
@since 03/03/2026
@param oModel, object, modelo
@param cModelId, character, id
@return variant, return_true or false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDA120EVT
	Local oModelNE6  := oModel:GetModel("AGDA120_NE6")
	Local oRepo 	 := RECIPE_REPOSITORY():New()

	//validacao para garantir nao chamada dupla do processo.
	If oModel:getOperation() == MODEL_OPERATION_INSERT .and. !empty(oModelNE6:GetValue("NE6_CODEXT"))
		if oRepo:existByCodigoExterno(oModelNE6:GetValue("NE6_CODEXT")) //receita já informada
			oModel:SetErrorMessage(,,,,,STR0002 + oModelNE6:GetValue("NE6_CODEXT") + STR0001) //"Receituário ou Guia de Trânsito não informados." //" já informada." //"Receita com ID Externo "
			Return .F.	
		endif		
	Endif

Return .t.

