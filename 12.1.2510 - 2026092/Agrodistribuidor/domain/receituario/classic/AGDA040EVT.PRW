#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDA040.CH"

#DEFINE SOLICITACAO_ITENS_RECEITA_SERVICE totvs.protheus.agrobusiness.agd.RequestRecipeItemService

#DEFINE RECEITUARIO_ITENS_SERVICE totvs.protheus.agrobusiness.agd.RecipeItemService

/*/{Protheus.doc} AGDA070EVT
Classe de eventos do modelo do AGDA070
@type class
@version P12
@author scheronlini.martins
@since 26/11/2025
/*/
Class AGDA040EVT From FWModelEvent
	Method New() Public Constructor
	Method AfterTTS(oModel, cModelId)
End Class

/*/{Protheus.doc} AGDA070EVT::New
Constructor
@type method
@version P12
@author scheronlini.martins
@since 26/11/2025
/*/
Method New() Class AGDA040EVT
Return Nil

/*/{Protheus.doc} AGDA070EVT::AfterTTS
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
@type method
@version p12
@author scheronlini.martins
@since 26/11/2025
@param oModel, object, modelo
@param cModelId, character, id
/*/
Method AfterTTS(oModel, cModelId) Class AGDA040EVT
	Local aAreaNES := NES->(GetArea())
	Local oMdlSolNET  := oModel:GetModel("AGDA040_NET")
	Local oMdlSolNEU  := oModel:GetModel("AGDA040_NEU")
	Local cChaveIDNE7 := ""
	Local cChaveIDNEU := ""
	Local nLine
	Local oServItSo
	Local oServItRec
	Local cNumPed
	Local oState
	Local cQuery
	Local cAlias

	if oMdlSolNET:getValue("NET_STSSOL") == "3" .and. oMdlSolNET:getValue("NET_STSREC") == "1"

		cNumPed := alltrim(oMdlSolNET:getValue("NET_NUMPED"))

		cQuery := "SELECT DISTINCT NE7_CODREC, NE7_SEQREC, NE7_QTDE "
		cQuery += 	" FROM " + RetSqlname("NE7") + " NE7 "
		cQuery += 		" INNER JOIN " + RetSqlname("NE6") + " NE6"
		cQuery +=  			" ON (NE6.NE6_CODREC = NE7.NE7_CODREC "
		cQuery += 				" AND NE6.NE6_FILIAL = NE7.NE7_FILIAL 
		cQuery += 				" AND NE6.NE6_PEDORI = ?
		cQuery += 				" AND NE6.D_E_L_E_T_ = ' ' )"
		cQuery += 		" INNER JOIN " + RetSqlname("NEU") + " NEU"
		cQuery +=  			" ON (NEU.NEU_FILIAL = ? "
		cQuery += 				" AND NEU.NEU_CODIGO = ? "
		cQuery += 				" AND NEU.NEU_CODREC = NE7.NE7_CODREC "
		cQuery += 				" AND NEU.NEU_SEQREC = NE7.NE7_SEQREC "
		cQuery += 				" AND NEU.D_E_L_E_T_ = ' ' )"
		cQuery += " WHERE NE7.NE7_FILIAL = ? "
		cQuery += 	" AND NE7.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )

		oState := FWPreparedStatement():New()
		oState:SetQuery(cQuery)
		oState:SetString(1, cNumPed)
		oState:SetString(2,FWxFilial('NEU'))
		oState:SetString(3,oMdlSolNEU:getValue("NEU_CODIGO"))
		oState:SetString(4,FWxFilial('NE7'))
		cQuery := oState:GetFixQuery()
		cAlias := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.T.)
		oServItRec := RECEITUARIO_ITENS_SERVICE():New()
		
		While !(cAlias)->(Eof())
			cChaveIDNE7 :=	xFilial("NE7") + (cAlias)->NE7_CODREC + (cAlias)->NE7_SEQREC
			oServItRec:atualizaQtdDIsponivel(cChaveIDNE7, (cAlias)->NE7_QTDE)
			(cAlias)->(DBSkip())
		EndDo
		(cAlias)->(DBCloseArea())

		for nLine:= 1 to len(oMdlSolNEU:acols)
			oServItSo := SOLICITACAO_ITENS_RECEITA_SERVICE():New()
			oMdlSolNEU:GoLine(nLine)
			cChaveIDNEU :=	xFilial("NEU") + oMdlSolNEU:getValue("NEU_CODIGO") + oMdlSolNEU:getValue("NEU_ITEM")
			oServItSo:desvinculaReceita(cChaveIDNEU)
		next

	endif

	RestArea(aAreaNES)

return nil

