#Include "agdp120evt.ch"
#INCLUDE "TOTVS.ch"


/*/{Protheus.doc} AGDP120EVT
Classe de eventos do modelo do AGDP120
@type class
@version 12
@author jean.schulze
@since 29/07/2026
/*/
Class AGDP120EVT From FWModelEvent

	Method New() CONSTRUCTOR
	Method ModelPosVld(oModel, cModelId)

End Class

/*/{Protheus.doc} New
Instancia a classe de eventos do modelo do AGDP120
@type method
@version 12
@author jean.schulze
@since 10/08/2026
@return variant, verdadeiro 
/*/
Method New() Class AGDP120EVT
Return nil

/*/{Protheus.doc} ModelPosVld
Validações do Cadastro de Movimento de Cooperado
@type method
@version 12
@author jean.schulze
@since 10/08/2026
@param oModel, object, model
@param cModelId, character, id do modelo
@return variant, valido informando se o modelo é válido ou não
/*/
Method ModelPosVld(oModel, cModelId) Class AGDP120EVT
	Local aArea			:= FWGetArea()
	Local lRet			:= .T.
	Local oNF5			:= oModel:GetModel("AGDP120_NF5")

	if oNF5:GetValue("NF5_GMOVAD") == "1" 

		if empty(oNF5:GetValue("NF5_CMOVAD"))
			AGDHELP(STR0002, STR0001)  //"Informe o Codigo do Movimento Adicional" //"Ajuda"
			lRet := .F.
		endif	

		if oNF5:GetValue("NF5_CMOVAD") == oNF5:GetValue("NF5_CODIGO")
			AGDHELP(STR0002, STR0003)  //"O Código do Movimento Adicional não pode ser o próprio código do tipo de movimento." //"Ajuda"
			lRet := .F.
		endif	
		
		if POSICIONE('NF5', 1, xFilial("NF5")+ oNF5:GetValue("NF5_CMOVAD"), "NF5_GMOVAD") == "1"
			AGDHELP(STR0002, STR0004)  //"O Código do Movimento Adicional não pode gerar movimento adicional." //"Ajuda"
			lRet := .F.
		endif	

	endif

	if oNF5:GetValue("NF5_GERFIN")  <> "1" 
		
		if empty(oNF5:GetValue("NF5_PREFIX")) .or. empty(oNF5:GetValue("NF5_TIPTIT")) .or. empty(oNF5:GetValue("NF5_CONDPG")) .or. empty(oNF5:GetValue("NF5_FLUXOC")) .or. empty(oNF5:GetValue("NF5_BAIXAU")) 
			AGDHELP(STR0002, STR0005)  //"Informe os Dados para Geração do Financeiro" //"Ajuda"
			lRet := .F.
		endif

		if oNF5:GetValue("NF5_BAIXAU") == "1" .and. empty(oNF5:GetValue("NF5_MOTBXA"))
			AGDHELP(STR0002, STR0006)  //"Informe o Motivo da Baixa Automática" //"Ajuda"
			lRet := .F.	
		endif

	endif

	FWRestArea(aArea)
Return lRet
