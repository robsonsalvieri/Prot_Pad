#INCLUDE "AGDP010.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AGDP010EVT
Classe de eventos do modelo do AGDA010
@type class
@version 12
@author jean.schulze
@since 02/09/2025
/*/
Class AGDP010EVT From FWModelEvent
	public Data cHistorico As string

	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)
	Method VldActivate(oModel, cModelId)



End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@return variant, self
/*/
Method New() Class AGDP010EVT
Return Nil

/*/{Protheus.doc} ModelPosVld
Validação do Modelo de Dados
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDP010EVT
	Local aArea			:= FWGetArea()
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oNEO			:= oModel:GetModel("AGDP010_NEO")
	Local _cFiltroNEO   := Nil

	If nOperation == MODEL_OPERATION_DELETE
		//Futuramente validar e não permitir eliminar cadastro caso mesmo esteja atrelado ao pedido de venda
	else

		If !empty(oNEO:GetValue("NEO_EST")) .OR. !empty(oNEO:GetValue("NEO_CODMUN"))
			If !ExistCpo("CC2",FwFldGet("NEO_EST")+oNEO:GetValue("NEO_CODMUN"))
				AGDHELP(STR0008, STR0009) //Ajuda - Estado/Municipio não cadastrado
				lRet := .F.
			Endif
		Endif

		If oNEO:GetValue("NEO_PADRAO") == '1' // 1-Sim, 2=Não
			If oNEO:GetValue("NEO_BLOQUE") == '1' // 1-Sim, 2=Não
				AGDHELP(STR0008, STR0013)
				lRet := .F.
			else
				// Realizar bloqueio caso já tenha registro padrão
				_cFiltroNEO :=  " NEO->NEO_FILIAL == '" + fWxFilial( 'NEO' ) + "' .AND." +;
					" NEO->NEO_PADRAO == '1' .AND. NEO->NEO_CODIGO != '" + oNEO:GetValue("NEO_CODIGO") + "'"

				dbSelectArea("NEO")
				NEO->( dbSetOrder(1) )
				NEO->( dbSetFilter( {|| &_cFiltroNEO}, _cFiltroNEO) )
				NEO->( dbGoTop() )
				IF NEO->( !EOF() )
					//O Registro XXX já é o registro padrão de local de descarte.
					AGDHELP(STR0008, STR0010 + NEO->NEO_FILIAL + "/ " + NEO->NEO_CODIGO + STR0011, STR0012)
					lRet := .F.
				Endif
				NEO->( dbCloseArea() )
			Endif
		Endif
	Endif

	FWRestArea(aArea)
Return lRet

Method VldActivate(oModel, cModelId) Class AGDP010EVT
	Local aArea			:= FWGetArea()
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_DELETE
		If ExistCpo('NEQ', NEO->NEO_FILIAL+NEO->NEO_CODIGO, 3)
			AGDHELP(STR0008, STR0014) //Ajuda - Não é possível excluir local de descarte de embalagem, pois, existe registro vinculado. Favor verificar.
			lRet := .F.
		Endif
	endif

	FWRestArea(aArea)
Return lRet
