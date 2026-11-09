#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA135.CH"

/*/{Protheus.doc} PCPA135Grv
Modelo utilizado pelo PCPA135 (PCPA135EVDEF.PRW) para efetivar as alterações realizadas.
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@return NIL
/*/
Function PCPA135Grv()

Return Nil

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@return oModel
/*/
Static Function ModelDef()

	Local oStruct := FWFormStruct(1, "SGG", , .F.)
	Local oModel  := MPFormModel():New('PCPA135Grv')

	oModel:SetDescription(STR0006) //"Pré-Estrutura"
	oModel:AddFields("MODEL_COMMIT", /*cOwner*/, oStruct)
	oModel:GetModel("MODEL_COMMIT"):SetDescription(STR0006) //"Pré-Estrutura"
	oModel:SetPrimaryKey({})

Return oModel