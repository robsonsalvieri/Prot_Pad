#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AGDI033
Função para remover movimentos do relacionamento entre os documentos fiscais saida 
e romaneios de cargas ao contrato de compra de grãos X Negociação
@type function
@version 12
@author Gilson.Venturi
@since 23/01/2025
@return variant, nil
/*/
Function AGDI033()
	Local aAreaAtu  := GetArea()
	Local oModel 	  := Nil 			//Objeto com o model da rotina de fazenda

	if SUPERGETMV("MV_SIGAAGD", .f., .f.)

		dbSelectArea('NEI')
		NEI->(dbSetOrder(2))	//Filial + Nota
		If NEI->(dbSeek(SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_ITEM)))

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
