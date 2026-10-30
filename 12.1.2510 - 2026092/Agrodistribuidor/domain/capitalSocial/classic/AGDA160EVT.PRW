#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} AGDA160EVT
Eventos do modelo MVC da rotina de Informe de Rendimentos
sobre Capital Social.
@type class
@version 12
@author rodrigo.nsoledade
@since 06/08/2026
/*/
Class AGDA160EVT From FWModelEvent

	Public Method New() Constructor
	Public Method AfterTTS(oModel,cModelId)

EndClass

/*/{Protheus.doc} New
Construtor da classe de eventos da rotina AGDA160.
@type method
@author rodrigo.nsoledade
@since 06/08/2026
@return object, instância da classe
/*/
Method New() Class AGDA160EVT
Return Self

/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC após a transação.
@type method
@author rodrigo.nsoledade
@since 10/08/2026
@param oModel, object, modelo principal
@param cModelId, character, identificador do modelo
@return nil
/*/
Method AfterTTS(oModel,cModelId) Class AGDA160EVT
Return Nil
