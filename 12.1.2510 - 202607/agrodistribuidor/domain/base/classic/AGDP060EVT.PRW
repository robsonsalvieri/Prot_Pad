#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP060.CH"

#DEFINE PropriedadeRuralService totvs.protheus.agrobusiness.agd.PropertyRuralService

/*/{Protheus.doc} AGDP060EVT
Classe de eventos do modelo do AGDP060
@type class
@version 12
@author AgroDistribuidor
@since 24/09/2025
/*/
Class AGDP060EVT From FWModelEvent

	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)

End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author AgroDistribuidor
@since 24/09/2025
@return variant, self
/*/
Method New() Class AGDP060EVT
Return Nil


/*/{Protheus.doc} ModelPosVld
Validação do Modelo de Dados
@type method
@version 12
@author AgroDistribuidor
@since 07/01/2026
@param oModel, object, modelo
@param cModelId, character, modelo id
@return logical, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDP060EVT
	Local oModelNEP  := oModel:GetModel("AGDP060_NEP")
	Local oPropSrvc  := Nil
	Local lEstadoSC  := .F.
	Local cDEmptFlds := ""

	If oModelNEP:GetValue("NEP_PRORUR") == "1" // Propriedade Rural "1"=Sim
		oPropSrvc := PropriedadeRuralService():New()
		lEstadoSC := oPropSrvc:validaUfSc(oModelNEP:GetValue("NEP_CODCLI"), oModelNEP:GetValue("NEP_LOJCLI"))
		FreeObj(oPropSrvc)

		If Empty(oModelNEP:GetValue("NEP_ALTITU")) .And. lEstadoSC
			AGDHELP(STR0007,STR0013, STR0014) // "Ajuda"#" Altitude obrigatória para propriedades de SC."#"Informe o campo Altitude."
			Return .F.
		EndIf

		If ! Empty(cDEmptFlds := gDEmptFlds({"NEP_LATIT", "NEP_LONGI", "NEP_CLIPRO", "NEP_LOJPRO"}, oModelNEP))
			AGDHELP(STR0007, STR0015, STR0016 + cDEmptFlds) //"Ajuda"#"Campo obrigatório não preenchido para ropriedade rural."#"Informe o(s) campo(s) "
			Return .F.
		EndIf
	EndIf

	If ! Empty(cDEmptFlds := gDEmptFlds({"NEP_END", "NEP_ENDNUM"}, oModelNEP))
		AGDHELP(STR0007, STR0017, STR0018) //"AJUDA", "O padrão utilizado no campo Endereço do cadastro de cliente está incompatível.", "Altere o cadastro do cliente e deixo o endereço no padrão (Logradouro, Número). Exemplo: Av. Brasil, 353"
		Return .F.
	EndIf

	if oModelNEP:GetValue("NEP_COOPER") == "1" // Cooperado "1"=Sim
		If Empty(oModelNEP:GetValue("NEP_MATRIC"))
			AGDHELP(STR0007, STR0019, STR0020) //"Ajuda"#"Campo obrigatório não preenchido para cooperado."#"Informe o campo Matrícula do Cooperado. Exemplo: 0000000000000001"
			Return .F.
		EndIf
	endif
Return .T.

/*/{Protheus.doc} gDEmptFlds
Obtem as descrições dos campos que estão vazios no modelo.
@type function
@version 12
@author jc.maldonado
@since 29/05/2026
@param aFields, array, Lista de campos a serem verificados.
@param oModel, object, Instância do modelo (FWFormFieldsModel)
@return character, Descrição dos campos vazios separados por virgula.
/*/
Static Function gDEmptFlds(aFields, oModel)
	Local nX         := 0
	Local aEmptyFlds := {}
	Local cFieldDesc := ""

	For nX := 1 To Len(aFields)
		If Empty(oModel:GetValue(aFields[nX]))
			AAdd(aEmptyFlds, RTrim(RetTitle(aFields[nX])))
		EndIf
	Next nX

	If ! Empty(aEmptyFlds)
		cFieldDesc := ArrTokStr(aEmptyFlds, ", ")
	EndIf
Return cFieldDesc
