#INCLUDE "TOTVS.CH"

#DEFINE FEATURE_CODE "INTEGRACAO_COMERCIALIZACAO_TAC"
#DEFINE TCO_REPOSITORY agd.TCORepository.agdTCORepository

/*/{Protheus.doc} AGDXTAC
Realiza validações para permitir ou não a geração de transação no EAI de acordo com a opção informada.
Rotina utilizada no valid (XX4_EXPFIL) dos adapters de integração com o TAC.
@type function
@version 12
@author jc.maldonado
@since 03/11/2025
@param cOpcao, character, opcao para validacao
@return logical, resultado da validação
/*/
Function AGDXTAC(cOpcao)
	Local lRet := .F.

	Default cOpcao := ""

	If ! FWisInCallStack("FWINTEGDEF")
		Return .F.
	EndIf

	Do Case
	Case cOpcao == "DOC_ENTRADA"
		lRet := vDocEntrad()
	Case cOpcao == "DOC_SAIDA"
		lRet := vDocSaida()
	EndCase
Return lRet

/*/{Protheus.doc} vDentrada
Valida se algum produto da nota fiscal de entrada possuí o tipo de commodity maior que '0'='Não Se Aplica'
E se a TES está na tabela de DE-PARA (XXF) com Identificador Externo do TAC
Validação especifica para o MATA103
@type function
@version 12
@author jc.maldonado
@since 03/11/2025
@return logical, resultado da validação
/*/
Static Function vDocEntrad()
	Local cCodInteg := ""
	Local cQuery    := ""
	Local aBindQry  := {}
	Local cNewAlias := ""
	Local cAliasSF4 := "SF4"
	Local cFieldSF4 := "F4_CODIGO"
	Local lRet      := .F.

	If SELECT("SD1") == 0;
			.Or. Empty(SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA));
			.Or. ! (GetRotInteg() == 'MATA103')
		Return .F.
	EndIf

	cQuery := "SELECT"
	cQuery += " 	DISTINCT SD1.D1_TES"
	cQuery += " FROM"
	cQuery += " 	" + retSQLName("SD1") + " SD1"
	cQuery += " JOIN " + retSQLName("SB5") + " SB5 ON"
	cQuery += " 	SB5.B5_COD = SD1.D1_COD"
	cQuery += " WHERE"
	cQuery += " 	SD1.D1_FILIAL = ?"        ; aAdd(aBindQry, SD1->D1_FILIAL)
	cQuery += " 	AND SD1.D1_DOC = ?"       ; aAdd(aBindQry, SD1->D1_DOC)
	cQuery += " 	AND SD1.D1_SERIE = ?"     ; aAdd(aBindQry, SD1->D1_SERIE)
	cQuery += " 	AND SD1.D1_FORNECE = ?"   ; aAdd(aBindQry, SD1->D1_FORNECE)
	cQuery += " 	AND SD1.D1_LOJA = ?"      ; aAdd(aBindQry, SD1->D1_LOJA)
	cQuery += " 	AND SD1.D_E_L_E_T_ = ' '"
	cQuery += " 	AND SB5.B5_FILIAL = ?"    ; aAdd(aBindQry, FWxFilial("SB5"))
	cQuery += " 	AND SB5.B5_TPCOMMO > '0'"
	cQuery += " 	AND SB5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	cNewAlias := MPSysOpenQuery(cQuery,,,,aBindQry)

	cCodInteg := getCodInt()

	While (cNewAlias)->(! EOF())
		if ! Empty(CFGA070Ext(cCodInteg, cAliasSF4, cFieldSF4, (cNewAlias)->D1_TES))
			lRet := .T.
			Exit
		endIf

		(cNewAlias)->(DBSkip())
	EndDo

	(cNewAlias)->(DBCloseArea())
Return lRet

/*/{Protheus.doc} NF_SAIDA
Valida se algum produto da nota fiscal de saída possuí o tipo de commodity maior que '0'='Não Se Aplica'
E se a TES está na tabela de DE-PARA (XXF) com Identificador Externo do TAC
Validação especifica para o IntegDef do MATA461
@type function
@version 12
@author jc.maldonado
@since 03/11/2025
@return logical, resultado da validação
/*/
Static Function vDocSaida()
	Local cCodInteg := ""
	Local cQuery    := ""
	Local aBindQry  := {}
	Local cNewAlias := ""
	Local cAliasSF4 := "SF4"
	Local cFieldSF4 := "F4_CODIGO"
	Local lRet      := .F.

	If SELECT("SD2") == 0;
			.Or. Empty(SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA));
			.Or. ! (GetRotInteg() == "MATA461") //TODO Confirmar nome da rotina de integração após correção de erro na criacao de msg eai (chamado aberto)
		Return .F.
	EndIf

	cQuery := "SELECT"
	cQuery += " 	DISTINCT SD2.D2_TES"
	cQuery += " FROM"
	cQuery += " 	" + retSQLName("SD2") + " SD2"
	cQuery += " JOIN " + retSQLName("SB5") + " SB5 ON"
	cQuery += " 	SB5.B5_COD = SD2.D2_COD"
	cQuery += " WHERE"
	cQuery += " 	SD2.D2_FILIAL = ?"        ; aAdd(aBindQry, SD2->D2_FILIAL)
	cQuery += " 	AND SD2.D2_DOC = ?"       ; aAdd(aBindQry, SD2->D2_DOC)
	cQuery += " 	AND SD2.D2_SERIE = ?"     ; aAdd(aBindQry, SD2->D2_SERIE)
	cQuery += " 	AND SD2.D2_CLIENTE = ?"   ; aAdd(aBindQry, SD2->D2_CLIENTE)
	cQuery += " 	AND SD2.D2_LOJA = ?"      ; aAdd(aBindQry, SD2->D2_LOJA)
	cQuery += " 	AND SD2.D_E_L_E_T_ = ' '"
	cQuery += " 	AND SB5.B5_FILIAL = ?"    ; aAdd(aBindQry, FWxFilial("SB5"))
	cQuery += " 	AND SB5.B5_TPCOMMO > '0'"
	cQuery += " 	AND SB5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	cNewAlias := MPSysOpenQuery(cQuery,,,,aBindQry)

	cCodInteg := getCodInt()

	While (cNewAlias)->(! EOF())
		if ! Empty(CFGA070Ext(cCodInteg, cAliasSF4, cFieldSF4, (cNewAlias)->D2_TES))
			lRet := .T.
			Exit
		endIf

		(cNewAlias)->(DBSkip())
	EndDo

	(cNewAlias)->(DBCloseArea())
Return lRet

/*/{Protheus.doc} getCodInt
Retorna o codigo de identificação da integração com o TAC
@type function
@version 12
@author jc.maldonado
@since 06/11/2025
@return character, codigo integracao tac
/*/
Static Function getCodInt()
	Local oTCOrepo	:= TCO_REPOSITORY():New()
	Local oFtClass	:= oTCOrepo:getFeatureClassById(FEATURE_CODE)
	Local cCodInteg := oFtClass:getIdentificaoIntegracao()
	FwFreeObj(oTCOrepo)
	FwFreeObj(oFtClass)
Return cCodInteg
