#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AGDI032
Função para remover movimentos do relacionamento entre os documentos fiscais entrada 
e romaneios de cargas ao contrato de compra de grãos X Negociação
@type function
@version 12
@author Gilson.Venturi
@since 23/01/2025
@return variant, nil
/*/
Function AGDI032()
    Local aAreaAtu  := GetArea()
    Local oModel 	  := Nil 			//Objeto com o model da rotina de fazenda

    if SUPERGETMV("MV_SIGAAGD", .f., .f.)

        dbSelectArea('NEI')
		NEI->(dbSetOrder(2))	//Filial + Nota
		If NEI->(dbSeek(SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_ITEM)))

			oModel := FwLoadModel("AGDA031")
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			oModel:Activate()
			If oModel:VldData()
				oModel:CommitData()
			EndIf

			oModel:DeActivate()
			oModel:Destroy()
			oModel := NIL
			FreeObj(oModel)

		endif
    endif

    restarea(aAreaAtu)

Return nil
