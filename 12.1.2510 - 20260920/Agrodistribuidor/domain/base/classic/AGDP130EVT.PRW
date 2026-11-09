#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP130.CH"

/*/{Protheus.doc} AGDP130EVT
Classe de eventos do modelo do AGDP130
@type class
@version 12
@author gilson.venturi
@since 29/07/2026
/*/
Class AGDP130EVT From FWModelEvent

	Method New() CONSTRUCTOR
	Method ModelPosVld(oModel, cModelId)

End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author gilson.venturi
@since 29/07/2026
@return variant, self
/*/
Method New() Class AGDP130EVT
Return .T.

/*/{Protheus.doc} ModelPosVld
Validação do Modelo de Dados
@type method
@version 12
@author gilson.venturi
@since 29/07/2026
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDP130EVT
	Local aArea			:= FWGetArea()
	Local lRet			:= .T.
	Local cQuery		:= ""
	Local nRegNNI		:= 0
	Local nOperation	:= oModel:GetOperation()
	Local oNF9			:= oModel:GetModel("AGDP130_NF9")
	Local oStatement

	If nOperation == MODEL_OPERATION_INSERT
		DbSelectArea("NF9")
		DbSetOrder(1)
		If DbSeek(FWxFilial("NF9") + oNF9:GetValue("NF9_TPVEND") + oNF9:GetValue("NF9_OPINTE") + oNF9:GetValue("NF9_CMDTY"))
			AGDHELP(STR0006, STR0007) //Ajuda - Produto já cadastrado para este Tipo de Venda e Operação Interestadual
			lRet := .F.
		Endif
	Endif

	If nOperation != MODEL_OPERATION_DELETE
		If oNF9:GetValue("NF9_TPVEND") == "1" 
			If Empty(oNF9:GetValue("NF9_CMDTY"))
				AGDHELP(STR0006, STR0009) // "O produto deve ser informado quando selecionado Tipo Venda 1=BARTER."
				lRet := .F.
			EndIf
			If lRet .And. !Empty(oNF9:GetValue("NF9_TABELA"))
				cQuery := " SELECT COUNT(NNI_CODIGO) AS REG "
				cQuery += " FROM " + RetSQLName("NNI")
				cQuery += " WHERE  NNI_FILIAL = '" + FWxFilial("NNI") + "' "
				cQuery += "   AND  NNI_CODIGO = ? "
				cQuery += "   AND (NNI_CODPRO = ? OR NNI_CODPRO = ' ') "
				cQuery += "   AND  D_E_L_E_T_ = ''"
				cQuery := ChangeQuery( cQuery )

				oStatement := FWPreparedStatement():New()
				oStatement:SetQuery(cQuery)
				oStatement:SetString( 1, oNF9:GetValue("NF9_TABELA"))
				oStatement:SetString( 2, oNF9:GetValue("NF9_CMDTY"))
				cQuery := oStatement:GetFixQuery()

				// Executa a query e armazena o resultado na variável
				nRegNNI := MPSysExecScalar(cQuery,"REG")
				// Se não encontrou registros, exibe mensagem e impede a inserção
				If nRegNNI == 0
					AGDHELP(STR0006, STR0008) //"Ajuda"#"Tabela não cadastrada para esse produto."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf


	FWRestArea(aArea)
Return lRet
