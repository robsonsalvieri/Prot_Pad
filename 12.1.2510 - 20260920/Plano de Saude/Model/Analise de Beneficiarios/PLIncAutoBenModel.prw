#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "PLINCBENMODEL.CH"

// API REST para realizara a inclusão dos beneficiários direto no grupo familiar utilizando 
// o protocolo da rotina de Analise de Beneficiários (PLSA977AB)
PUBLISH MODEL REST NAME PLINCAUTOBENMODEL RESOURCE OBJECT PLIncRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados para a analise de beneficiários referente ao Layout 
de Inclusão cadastral - Geração automatica de beneficiários no grupo
familiar

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()

    Local nX := 0
    Local oModel := FWLoadModel("PLIncBenModel")

    oModel:SetDescription(STR0001 + STR0033) // " (Automático)"

    If ValType(oModel:oEventHandler) == "O" .And. Len(oModel:oEventHandler:aEvents) > 0
        For nX := 1 To Len(oModel:oEventHandler:aEvents)

            If oModel:oEventHandler:aEvents[nX]:cIdEvent == "PLIncBenEvent"
                oModel:oEventHandler:aEvents[nX]:SetGrvGrupoFamiliar()
            EndIf

        Next nX
    EndIf

Return oModel