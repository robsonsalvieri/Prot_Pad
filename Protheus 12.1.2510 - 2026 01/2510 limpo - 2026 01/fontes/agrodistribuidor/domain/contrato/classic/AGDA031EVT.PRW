#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE NEGOCIO_STATUS_SERVICE agd.negocioStatusService.agdNegocioStatusService
#DEFINE NEGOCIO_SERVICE agd.negocioService.agdNegocioService

/*/{Protheus.doc} AGDA031EVT
Classe de eventos do modelo do AGDA031
@type class
@version 12
@author Gilson.Venturi
@since 26/09/2025
/*/
Class AGDA031EVT From FWModelEvent

	Method New() Public Constructor
	Method InTTS(oModel, cModelId)

End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author Gilson.Venturi
@since 26/09/2025
@return variant, self
/*/
Method New() Class AGDA031EVT
Return Nil

/*/{Protheus.doc} InTTS
Pós Commit
@type method
@version 12
@author Gilson.VEnturi
@since 26/09/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method InTTS(oModel, cModelId) Class AGDA031EVT
	Local oNEI	:= oModel:GetModel("AGDA031_NEI")

	Local oNegocioService		As Object
	Local oNegocioSatusService 	As Object

	//Proteção do campo
	If NEA->(ColumnPos('NEA_STSREC')) > 0
		NEF->(dbSetOrder(1)) //NEF_FILIAL+NEF_IDCTR+NEF_CODBRT++NEF_ITECTR
		If NEF->(dbSeek(fwXFilial("NEI")+oNEI:Getvalue('NEI_IDCTR')))
			oNegocioService	:= NEGOCIO_SERVICE():New()
			cVersaoNegocio	:= oNegocioService:buscarVersaoAtualValida(NEF->NEF_CODBRT)

			oNegocioSatusService := NEGOCIO_STATUS_SERVICE()():new(FWxFilial("NEA") + NEF->(NEF_CODBRT) + cVersaoNegocio)
			oNegocioSatusService:atualizarStRecebNegocio()
			oNegocioSatusService:concluirNegocio()
			FreeObj(oNegocioSatusService)
			FreeObj(oNegocioService)
		Endif
	Endif

Return .T.

