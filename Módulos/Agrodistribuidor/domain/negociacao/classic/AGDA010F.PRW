#INCLUDE "AGDA010.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} AGDA010F
Chama rotina para inclusão Fechamento Financeiro conforme negociação posicionada
@type function
@version P12
@author Gilson.Venturi
@since 31/01/2025
@return Logical, valor logico .T. ou .F.
/*/
Function AGDA010F()
	Local aAreaNEA  := NEA->(GetArea())
	Local oModel    := nil
	Local oModelNEJ := nil
	Local lRet 		:= .T.

	If NEA->NEA_STSAUT == '2' //1=Nao liberado / 2=Liberado
		oModel := FwLoadModel('AGDA060')
		oModelNEJ := oModel:GetModel("AGDA060_NEJ")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If oModel:Activate()
			oModelNEJ:SetValue('NEJ_FILIAL', NEA->NEA_FILIAL)
			oModelNEJ:SetValue('NEJ_CODBRT', NEA->NEA_CODIGO)

			FWExecView(oModel:GetDescription(), "AGDA060", MODEL_OPERATION_INSERT, , , ,0, , , , , oModel)

		Endif
	else
		lRet := .F.
		AGDHELP(STR0008,STR0032,STR0033)
	Endif

	RestArea(aAreaNEA)

Return .T.
