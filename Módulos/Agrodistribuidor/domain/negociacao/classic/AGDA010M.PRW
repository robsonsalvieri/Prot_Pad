#INCLUDE "AGDA010M.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} AGDA010MIE
Chama rotina para inclusão da instrução de embarque conforme negociação posicionada
@type function
@version P12.1.2410
@author claudineia.reinert
@since 10/12/2024
@return Logical, valor logico .T. ou .F.
/*/
Function AGDA010MIE()
	Local aAreaNEA  := NEA->(GetArea())
	Local oModel    := nil
	Local oModelNEC := nil
	Local lRet 		:= .T.

	If NEA->NEA_STSAUT == '2' .and. NEA->NEA_STATUS <> '3' 

		oModel := FwLoadModel('AGDA020')
		oModelNEC := oModel:GetModel("AGDA020_NEC")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		If oModel:Activate()
			oModelNEC:SetValue('NEC_FILIAL', NEA->NEA_FILIAL)
			oModelNEC:SetValue('NEC_CODBRT', NEA->NEA_CODIGO)
			if !Empty(oModel:GetErrorMessage()[4]) .or. !Empty(oModel:GetErrorMessage()[6])
				//Recuperando mensagem de erro do modelo caso retorne erro nos SETVALUE dos campos acima
				AGDHELP(oModel:GetErrorMessage()[5],oModel:GetErrorMessage()[6],oModel:GetErrorMessage()[7])
				oModel:DeActivate()
			else
				FWExecView(oModel:GetDescription(), "AGDA020", MODEL_OPERATION_INSERT, , , ,0, , , , , oModel)
			endif
		Endif
	elseif NEA->NEA_STSAUT == '1'	
		lRet := .F.
		AGDHELP(STR0001,STR0002,STR0003) //"Negociação com status não liberado" ##"Será necessário a liberação da negociação para seguir com a geração da Instrução de Embarque"
	elseif NEA->NEA_STATUS == '3' 
		lRet := .F.
		AGDHELP(STR0001,STR0004,STR0005) //"Negociação com status Cancelado" #"Será necessário incluir uma nova negociação"
	Endif

	RestArea(aAreaNEA)

Return .T.
