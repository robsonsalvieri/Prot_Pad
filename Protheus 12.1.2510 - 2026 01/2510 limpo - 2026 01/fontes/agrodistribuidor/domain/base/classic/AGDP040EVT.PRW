#INCLUDE "AGDP040.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"

#DEFINE TAB_PRECO_SERVICE agd.TabelaPrecoService.agdTabelaPrecoService

/*/{Protheus.doc} AGDP040EVT
Classe de eventos do modelo do AGDA010
@type class
@version 12
@author jean.schulze
@since 02/09/2025
/*/
Class AGDP040EVT From FWModelEvent

	Method New() Public Constructor
	Method ModelPosVld(oModel, cModelId)
	Method InTTS(oModel, cModelId)	
	Method GridLinePosVld() 
	
	Method validaLinhaProdutoParidade()
	Method hasNegociacaoParidade()
	Method hasPedidoTabelaPreco()
End Class

/*/{Protheus.doc} New
Constructor
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@return variant, self
/*/
Method New() Class AGDP040EVT
Return Nil

/*/{Protheus.doc} ModelPosVld
Validação do Modelo de Dados
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, true/false
/*/
Method ModelPosVld(oModel, cModelId) Class AGDP040EVT
	Local nOperation := oModel:GetOperation()
	Local cCodTabPrc
	Local cCodPrgPar

	If nOperation == MODEL_OPERATION_DELETE
		cCodTabPrc := oModel:GetValue("AGDP040_NEG", "NEG_TABPRP")
		If Self:hasPedidoTabelaPreco(cCodTabPrc)
			AGDHELP(STR0009, STR0012, STR0013) //"AJUDA", "Este programa de paridade possui vinculo(s), não é possível excluí-lo.", "Selecione outro programa de paridade."
			Return .F.
		EndIf

		cCodPrgPar := oModel:GetValue("AGDP040_NEG", "NEG_CODIGO")
		If Self:hasNegociacaoParidade(cCodPrgPar)
			AGDHELP(STR0009, STR0018, STR0019) //"AJUDA", "Programa de paridade utilizado em uma Negociação, não sendo possível sua exclusão.", "Bloquear o Programa de Paridade."
			Return .F.
		EndIf
	EndIf
Return .t.

/*/{Protheus.doc} InTTS
Pós Commit
@type method
@version 12
@author jean.schulze
@since 02/09/2025
@param oModel, object, modelo
@param cModelId, character, modelo id
@return variant, nil
/*/
Method InTTS(oModel, cModelId)  Class AGDP040EVT
	Local aArea      := FWgetArea()
	Local nOperation := oModel:GetOperation()
	Local cCodigoNEG := oModel:GetModel("AGDP040_NEG"):Getvalue('NEG_CODIGO')
	Local cFilNEG	 := FWxFilial("NEG")
	Local cMsg
	Local oNewTabPrc
	Local lCommitOk  := .T.

	Do Case
	Case nOperation == MODEL_OPERATION_INSERT
		cMsg := STR0004 //Incluir

		oNewTabPrc := TAB_PRECO_SERVICE():New()
		oNewTabPrc:createFromProgramaParidade(cCodigoNEG)
		If (lCommitOk := oNewTabPrc:isSuccess())
			//Vincula a tabela de preço gerada ao programa de paridade
			recLock("NEG", .F.)
			NEG->NEG_TABPRP := oNewTabPrc:getIdTabelaPreco()
			NEG->(MsUnlock())
		Else
			AGDHELP(STR0009, oNewTabPrc:getMessageError())
		EndIf
		FreeObj(oNewTabPrc)

	Case nOperation == MODEL_OPERATION_UPDATE
		cMsg := STR0005 //Alterar

	Case nOperation == MODEL_OPERATION_DELETE
		cMsg := STR0006 //Excluir
	EndCase

	If lCommitOk
		AGDGRAVAHIS("", "NEG", cFilNEG + cCodigoNEG, Upper(cMsg), .F.)
	EndIf

	fwRestArea(aArea)

return lCommitOk


/*/{Protheus.doc} GridLinePosVld
Validação de linhas da Grid
@type method
@version 12
@author jean.schulze
@since 03/09/2025
@param oSubModel, object, modelo
@param cModelID, character, modelo id
@param nLine, numeric, linha
@return variant, retorno
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class AGDP040EVT
	if cModelID == 'AGDP040_NEH'
		return Self:validaLinhaProdutoParidade(oSubModel)
	endif
return .t.


/*/{Protheus.doc} validaLinhaProdutoParidade
Valida a linha de produto da paridade
@type method
@version 12
@author jean.schulze
@since 04/09/2025
@return variant, retorno
/*/
Method validaLinhaProdutoParidade(oGridNEH) Class AGDP040EVT
	Local nX	  := 0
	Local nPosBKP := oGridNEH:GetLine()

	For nX := 1 To oGridNEH:Length()
		oGridNEH:GoLine(nX)

		If Empty(oGridNEH:GetValue("NEH_CODPRO"))
			AGDHELP(STR0009, STR0016, STR0017) //"AJUDA", "Lista de produtos vazia.", "Defina uma tabela de preço de origem para carregar os produtos."
			oGridNEH:GoLine(nPosBKP)
			Return .F.
		EndIf

		If oGridNEH:GetValue("NEH_PRC") <= 0
			AGDHELP(STR0009, STR0010, STR0011) //"AJUDA", "Item com preço inválido.", "É obrigatório informar o preço para cada item."
			oGridNEH:GoLine(nPosBKP)
			Return .F.
		EndIf
	Next nX

	oGridNEH:GoLine(nPosBKP)
return .T.


/*/{Protheus.doc} hasNegociacaoParidade
Verifica se o programa de paridade ja foi utilizado em alguma negociacao
@type method
@version 12
@author jc.maldonado
@since 25/02/2025
@param cCodPrgPar, character, codigo do programa de paridade
@return logical, .t. or .f.
/*/
Method hasNegociacaoParidade(cCodPrgPar) Class AGDP040EVT
	Local cQuery
	Local cAlias
	Local aParams := {}
	Local lVinculado

	cQuery := " SELECT"
	cQuery += "     COUNT(NEA_CODIGO) AS TOTAL"
	cQuery += " FROM "
	cQuery +=       retSQLName("NEA")
	cQuery += " WHERE"
	cQuery += "     NEA_FILIAL = ?"     ; aAdd(aParams, FWxFilial("NEA"))
	cQuery += "     AND NEA_PARIDA = ?" ; aAdd(aParams, cCodPrgPar)
	cQuery += "     AND D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry2(,,cQuery, aParams), cAlias, .F., .T.)

	lVinculado := (cAlias)->TOTAL > 0

	(cAlias)->(DBcloseArea())
Return lVinculado

/*/{Protheus.doc} hasPedidoTabelaPreco
Verifica se a tabela de preco informada esta vinculada a algum pedido
@type method
@version 12
@author jc.maldonado
@since 06/02/2025
@param cCodTabPrc, character, codigo da tabela de preco
@return logical, .t. or .f.
/*/
Method hasPedidoTabelaPreco(cCodTabPrc)  Class AGDP040EVT
	Local cAlias 	:= ""
	Local cQuery 	:= ""
	Local aParams 	:= {}
	Local lVinculada := .F.


	If Empty(cCodTabPrc)
		Return .F.
	EndIf

	cQuery := "SELECT COUNT(C5_NUM) AS TOTAL"
	cQuery += " FROM " + retSQLName("SC5")
	cQuery += " WHERE"
	cQuery += "	C5_FILIAL = ?"     ; aAdd(aParams, FWxFilial("SC5"))
	cQuery += "	AND C5_TABELA = ?" ; aAdd(aParams, cCodTabPrc)
	cQuery += "	AND D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry2(,,cQuery, aParams), cAlias, .F., .T.)

	lVinculada := (cAlias)->TOTAL > 0

	(cAlias)->(DBcloseArea())
Return lVinculada

