#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSJURCFGASSJUR.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurCfgAssJur
Métodos WS REST do Jurídico para configuração de assuntos jurídicos.

@since 05/02/2026
/*/
//-------------------------------------------------------------------
WSRESTFUL JURCFGASSJUR DESCRIPTION STR0001 //"Métodos WS REST do Jurídico para configuração de assuntos jurídicos."

    WSDATA entidade AS STRING
	WSDATA assJur   AS STRING

	WSMETHOD GET  fieldsNUZ    DESCRIPTION STR0002 PATH "fieldsNUZ/{entidade}" PRODUCES APPLICATION_JSON // "Retorna os campos da tabela NUZ a partir da entidade"

	WSMETHOD POST configNUZ    DESCRIPTION STR0003 PATH "configNUZ"            PRODUCES APPLICATION_JSON // "Configura os campos da tabela NUZ para um assunto jurídico"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} fieldsNUZ
Consulta os campos da tabela NUZ para uma determinada entidade e assunto jurídico

@param entidade - Entidade que se deseja consultar os campos da tabela NUZ
@param assJur   - Código do assunto jurídico

@since 03/02/2026
@example GET -> http://localhost:12173/rest/JURCFGASSJUR/fieldsNUZ/O0W?assJur=001
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET fieldsNUZ PATHPARAM entidade WSRECEIVE assJur WSREST JURCFGASSJUR
Local cEntidade  := AllTrim(Self:entidade)
Local cAssJur    := AllTrim(Self:assJur)
Local aFldStruct := {}
Local nI         := 0
Local oResponse  := JsonObject():New()
Local oStruct    := Nil

	Self:SetContentType("application/json")
	oResponse["listaCampos"] := {}

	If !Empty(cEntidade) .And. !Empty(cAssJur)
		oStruct := FWFormStruct(2, cEntidade)
		aFldStruct := oStruct:GetFields()

		DbSelectArea("NUZ")
		NUZ->(DbSetOrder(1)) // NUZ_FILIAL+NUZ_CTAJUR+NUZ_CAMPO

		For nI := 1 To Len(aFldStruct)
			aAdd(oResponse["listaCampos"], JsonObject():New())
			// Verifica se o campo existe na tabela NUZ
			If NUZ->(dbSeek(xFilial("NUZ") + cAssJur + aFldStruct[nI][1]))
				aTail(oResponse["listaCampos"])["existeNUZ"] := .T.
			Else
				aTail(oResponse["listaCampos"])["existeNUZ"] := .F.
			EndIf

			aTail(oResponse["listaCampos"])["campo"]     := aFldStruct[nI][1]
			aTail(oResponse["listaCampos"])["titulo"]    := JConvUTF8(aFldStruct[nI][3])
			aTail(oResponse["listaCampos"])["descricao"] := JConvUTF8(aFldStruct[nI][4])
		Next nI

		NUZ->(DbCloseArea())
	EndIf
	
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} configNUZ
Realiza a configuração dos campos da tabela NUZ para uma determinada entidade e assunto jurídico

@param assJur - Código do assunto jurídico

@since 03/02/2026
@example POST -> http://localhost:12173/rest/JURCFGASSJUR/configNUZ?assJur=001
@body - Exemplo de body da requisição:
	{
		"listaCampos": [
			{
				"campo": "O0W_COD",
				"titulo": "Cód Id Verba"
			}
		]
	}
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST configNUZ WSRECEIVE assJur WSREST JURCFGASSJUR
Local oResponse := JsonObject():New()
Local oJsonBody := JsonObject():New()
Local oModel158    := Nil
Local oModelNUZ := Nil
Local cAssJur   := AllTrim(Self:assJur)
Local cBody     := Self:GetContent()
Local lRet      := .T.
Local nI        := 0

	Self:SetContentType("application/json")

	If !Empty(cAssJur) .And. !Empty(cBody)
		If LockByName("configNUZ", .T., .T.)
			oJsonBody:fromJson(cBody)

			DbSelectArea("NYB")
			NYB->(DbSetOrder(1)) // NYB_FILIAL + NYB_COD
			If NYB->(dbSeek(xFilial("NYB") + cAssJur))
				oModel158 := FWLoadModel("JURA158")
				oModel158:SetOperation(4)
				oModel158:Activate()

				oModelNUZ := oModel158:GetModel("NUZDETAIL")
				DbSelectArea("NUZ")
				NUZ->(DbSetOrder(1)) // NUZ_FILIAL+NUZ_CTAJUR+NUZ_CAMPO
				For nI := 1 To Len(oJsonBody["listaCampos"])
					// Apenas adiciona os campos que não existem na tabela NUZ
					If !(NUZ->(dbSeek(xFilial("NUZ") + cAssJur + oJsonBody["listaCampos"][nI]["campo"])))
						oModelNUZ:AddLine()
						oModelNUZ:SetValue("NUZ_CAMPO", oJsonBody["listaCampos"][nI]["campo"])
						oModelNUZ:SetValue("NUZ_DESCPO", DecodeUTF8(oJsonBody["listaCampos"][nI]["titulo"]))
					EndIf
				Next nI

				If oModelNUZ:IsModified()
					If !oModel158:VldData() .OR. !oModel158:CommitData()
						lRet := .F.
						If !Empty(oModel158:GetErrorMessage()[6])
							JRestError(400, oModel158:GetErrorMessage()[6])
						EndIf
					EndIf
				EndIf

				NUZ->(DbCloseArea())
				oModel158:DeActivate()
			EndIf
			NYB->(DbCloseArea())
			
			If lRet
				oResponse["message"] := STR0004 // "Configurações de campos NUZ atualizadas com sucesso."
				Self:SetResponse(oResponse:toJson())
			EndIf

			oJsonBody:fromJson("{}")
			oJsonBody := NIL
			oResponse:fromJson("{}")
			oResponse := NIL
			UnlockByName("configNUZ", .T., .T.)
		Else
			lRet := .F.
			JRestError(400, STR0005) //"A migração de campos NUZ está em andamento. Tente novamente mais tarde."
		EndIf
	EndIf

Return lRet

