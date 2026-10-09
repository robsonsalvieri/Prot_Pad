#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP110.CH"

#DEFINE TAB_PRECO_EXTENSAO_SERVICE totvs.protheus.agrobusiness.agd.TablePriceExtensionService

/*/{Protheus.doc} AGDP110EVT
Classe de eventos do modelo do AGDP110
@type class
@version 12
@author AgroDistribuidor
@since 24/09/2025
/*/
Class AGDP110EVT From FWModelEvent

	Method New() CONSTRUCTOR
	Method FieldPreVld() 

End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author AgroDistribuidor
@since 24/09/2025
@return variant, self
/*/
Method New() Class AGDP110EVT
Return .T.

/*/{Protheus.doc} AGDP110EVT::FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field
@type method
@version P12 
@author claudineia.reinert
@since 17/03/2026
@param oSubModel, object, Modelo principal
@param cModelID, character, Id do submodelo
@param cAction, character, Ação executada no grid, podendo ser: SETVALUE, CANSETVALUE
@param cId, character, nome do campo
@param xValue, variant, Novo valor do campo
@return Logical, indica se a validação foi bem sucedida
/*/
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class AGDP110EVT
	Local lRet := .T.
	Local oServTabPrecoExtensao := nil
	
	//regra para validação do campo
	If cAction == "SETVALUE" .and. cModelID = 'AGDP110_NE8' .AND. cId == "NE8_CODTAB"
		oServTabPrecoExtensao := TAB_PRECO_EXTENSAO_SERVICE():New()
		If !oServTabPrecoExtensao:validateTablePrice(FWxFilial('NE8'), xValue)
			AGDHELP( STR0005 ,oServTabPrecoExtensao:getMessageError(), oServTabPrecoExtensao:getSolutionError() ) //"Ajuda"
			lRet := .F.
		EndIf
		FreeObj(oServTabPrecoExtensao)
	EndIf

Return lRet
