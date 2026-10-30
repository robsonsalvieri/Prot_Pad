#INCLUDE "AGDA010M.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE NEGOCIO_SERVICE totvs.protheus.agrobusiness.agd.BusinessService

/*/{Protheus.doc} AGDA010MIE
Chama rotina para inclusão da instrução de embarque conforme negociação posicionada
@type function
@version P12.1.2410
@author claudineia.reinert
@since 10/12/2024
@return Logical, valor logico .T. ou .F.
/*/
Function AGDA010MIE()
	Local cCodBarter := NEA->NEA_CODIGO
	Local aAreaNEA   := NEA->(GetArea())
	Local oModel     := Nil
	Local oModelNEC  := Nil

	oModel := FwLoadModel('AGDA020')
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	If oModel:Activate()
		oModelNEC := oModel:GetModel("AGDA020_NEC")
		if ! oModelNEC:SetValue('NEC_CODBRT', cCodBarter)
			AGDHELP(oModel:GetErrorMessage()[MODEL_MSGERR_ID], oModel:GetErrorMessage()[MODEL_MSGERR_MESSAGE], oModel:GetErrorMessage()[MODEL_MSGERR_SOLUCTION])
			oModel:DeActivate()
		else
			FWExecView(oModel:GetDescription(), "AGDA020", MODEL_OPERATION_INSERT, , , ,0, , , , , oModel)
		endif
	Endif

	FWFreeObj(oModel)
	RestArea(aAreaNEA)
Return .T.
