#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"

#DEFINE FILTRO_TIPO_EQUIPAMENTO_APENAS_PAI   1
#DEFINE FILTRO_TIPO_EQUIPAMENTO_TODAS_ORDENS 2


Static _lTemHZ7 := Nil

/*/{Protheus.doc} PCPA152PRIORIDADE
API que envia as informações para tela de consulta e manutenção de prioridades.

@type  WSCLASS
@author Lucas Fagundes
@since 23/08/2024
@version P12
/*/
WSRESTFUL PCPA152PRIORIDADE DESCRIPTION "PCPA152Prioridade" FORMAT APPLICATION_JSON
	WSDATA page               as INTEGER OPTIONAL
	WSDATA pageSize           as INTEGER OPTIONAL
	WSDATA filtroEquipamentos as INTEGER OPTIONAL
	WSDATA centroTrabalho     AS STRING  OPTIONAL
	WSDATA chave              AS STRING  OPTIONAL
	WSDATA ordemProducao      AS STRING  OPTIONAL
	WSDATA produto            AS STRING  OPTIONAL
	WSDATA programacao        AS STRING  OPTIONAL
	WSDATA recurso            AS STRING  OPTIONAL
	WSDATA tipo               AS STRING  OPTIONAL
	WSDATA grupo              AS STRING  OPTIONAL

	WSMETHOD GET PRIO_MASTER;
		DESCRIPTION STR0555; // "Retorna os registros para consulta de prioridade"
		WSSYNTAX "/api/pcp/v1/pcpa152prioridade/{programacao}";
		PATH "/api/pcp/v1/pcpa152prioridade/{programacao}";
		TTALK "v1"

	WSMETHOD GET PRIO_DET;
		DESCRIPTION STR0556; // "Retorna os detalhes da consulta de prioridade"
		WSSYNTAX "/api/pcp/v1/pcpa152prioridade/{programacao}/detalhes/{chave}";
		PATH "/api/pcp/v1/pcpa152prioridade/{programacao}/detalhes/{chave}";
		TTALK "v1"

	WSMETHOD GET PRIO_EXP;
		DESCRIPTION STR0557; // "Retorna os registros de priodade para exportação"
		WSSYNTAX "/api/pcp/v1/pcpa152prioridade/{programacao}/exportacao";
		PATH "/api/pcp/v1/pcpa152prioridade/{programacao}/exportacao";
		TTALK "v1"

	WSMETHOD POST UPD_PRIO;
		DESCRIPTION STR0558; // "Atualiza a prioridade dos registros"
		WSSYNTAX "/api/pcp/v1/pcpa152prioridade/{programacao}/update";
		PATH "/api/pcp/v1/pcpa152prioridade/{programacao}/update";
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET PRIO_MASTER /api/pcp/v1/pcpa152prioridade/{programacao}
Retornar os registros para consulta de prioridades
@type  WSMETHOD
@author Lucas Fagundes
@since 13/08/2024
@version P12
@param 01 programacao       , Caracter, Código da programação.
@param 02 page              , Numerico, Página da consulta.
@param 03 pageSize          , Numerico, Tamanho da página.
@param 04 ordemProducao     , Caracter, Filtro de ordem de produção.
@param 05 produto           , Caracter, Filtro de produto.
@param 06 tipo              , Caracter, Filtro de tipo de produto.
@param 07 grupo             , Caracter, Filtro de grupo de produto.
@param 08 filtroEquipamentos, Numerico, Tipo de filtro de equipamentos.
@param 09 recurso           , Caracter, Filtro de recurso.
@param 10 centroTrabalho    , Caracter, Filtro de centro de trabalho.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET PRIO_MASTER PATHPARAM programacao QUERYPARAM page, pageSize, ordemProducao, produto, tipo, grupo, filtroEquipamentos, recurso, centroTrabalho WSSERVICE PCPA152PRIORIDADE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRIORIDADE"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := masterPrior(Self:programacao, Self:page, Self:pageSize, Self:ordemProducao, Self:produto, Self:tipo, Self:grupo, Self:filtroEquipamentos, Self:recurso, Self:centroTrabalho)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lReturn

/*/{Protheus.doc} masterPrior
Retorna os registros master da consulta de prioridades.
@type  Static Function
@author Lucas Fagundes
@since 13/08/2024
@version P12
@param 01 cProg     , Caracter, Código da programação.
@param 02 nPage     , Numerico, Página da consulta.
@param 03 nPageSize , Numerico, Tamanho da página.
@param 04 cOrdem    , Caracter, Filtro de ordem de produção.
@param 05 cProduto  , Caracter, Filtro de produto.
@param 06 cTipo     , Caracter, Filtro de tipo de produto.
@param 07 cGrupo    , Caracter, Filtro de grupo de produto.
@param 08 nTipoEquip, Numerico, Tipo de filtro de equipamentos.
@param 09 cRecurso  , Caracter, Filtro de recurso.
@param 10 cCTrab    , Caracter, Filtro de centro de trabalho.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function masterPrior(cProg, nPage, nPageSize, cOrdem, cProduto, cTipo, cGrupo, nTipoEquip, cRecurso, cCTrab)
	Local aReturn   := Array(3)
	Local cAlias    := GetNextAlias()
	Local cAliTotal := GetNextAlias()
	Local cQuery    := ""
	Local nCont     := 0
	Local nStart    := 0
	Local nTotalReg := 0
	Local oReturn   := JsonObject():New()
	Local oDetail   := JsonObject():New()

	cQuery := " SELECT SMF.MF_PRIOR,"
	cQuery +=        " SMF.MF_OP,"
	cQuery +=        " SC2.C2_PRODUTO,"
	cQuery +=        " SB1.B1_DESC,"
	cQuery +=        " agrupChave.chave,"
	cQuery +=        " agrupChave.total,"
	cQuery +=        " saldo.MF_SALDO saldo,"
	cQuery +=        " SMF.MF_ARVORE"
	cQuery +=  " FROM (SELECT COUNT(1) total,"
	cQuery +=               " MIN(SMF.MF_PRIOR) menorPrioridade,"
	cQuery +=               " CASE"
	cQuery +=                   " WHEN SMF.MF_ARVORE = ' ' THEN '_' || SMF.MF_OP"
	cQuery +=                   " ELSE SMF.MF_ARVORE || '_'"
	cQuery +=               " END chave"
	cQuery +=          " FROM " + RetSqlName("SMF") + " SMF"
	cQuery +=         " WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "'"
	cQuery +=           " AND SMF.MF_PROG    = '" + cProg + "'"
	cQuery +=           " AND SMF.D_E_L_E_T_ = ' '"
	cQuery +=         " GROUP BY CASE"
	cQuery +=                      " WHEN SMF.MF_ARVORE = ' ' THEN '_' || SMF.MF_OP"
	cQuery +=                      " ELSE SMF.MF_ARVORE || '_'"
	cQuery +=                  " END) agrupChave"
	cQuery +=  " INNER JOIN " + RetSqlName("SMF") + " SMF"
	cQuery +=     " ON SMF.MF_FILIAL = '" + xFilial("SMF") + "'"
	cQuery +=    " AND SMF.MF_PROG   = '" + cProg + "'"
	cQuery +=    " AND SMF.MF_PRIOR  = agrupChave.menorPrioridade"
	cQuery +=    " AND CASE"
	cQuery +=            " WHEN SMF.MF_ARVORE = ' ' THEN '_' || SMF.MF_OP"
	cQuery +=            " ELSE SMF.MF_ARVORE || '_'"
	cQuery +=        " END = agrupChave.chave "
	If !Empty(cOrdem)
		cQuery += " AND SMF.MF_OP IN ('" + StrTran(cOrdem, ",", "','") + "') "
	EndIf
	cQuery +=    " AND SMF.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "'"
	cQuery +=    " AND " + PCPQrySC2("SC2", "SMF.MF_OP")
	If !Empty(cProduto)
		cQuery += " AND SC2.C2_PRODUTO IN ('" + StrTran(cProduto, ",", "','") + "') "
	EndIf
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1"
	cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
	cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO"
	If !Empty(cTipo)
		cQuery += " AND SB1.B1_TIPO IN ('" + StrTran(cTipo, ",", "','") + "') "
	EndIf
	If cGrupo != Nil
		cQuery += " AND SB1.B1_GRUPO IN ('" + StrTran(cGrupo, ",", "','") + "') "
	EndIf
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN (SELECT SMFb.MF_SALDO, SMFb.MF_OP "
	cQuery +=                " FROM " + RetSqlName("SMF") + " SMFb"
	cQuery +=               " WHERE SMFb.MF_FILIAL = '" + xFilial("SMF") + "'"
	cQuery +=                 " AND SMFb.MF_PROG   = '" + cProg + "'"
	cQuery +=                 " AND SMFb.MF_OPER   = (SELECT MAX(SMFc.MF_OPER)"
	cQuery +=                                         " FROM " + RetSqlName("SMF") + " SMFc"
	cQuery +=                                        " WHERE SMFc.MF_FILIAL = SMFb.MF_FILIAL"
	cQuery +=                                          " AND SMFc.MF_PROG = SMFb.MF_PROG"
	cQuery +=                                          " AND SMFc.MF_OP = SMFb.MF_OP"
	cQuery +=                                          " AND SMFc.D_E_L_E_T_ = ' ')"
	cQuery +=                 " AND SMFb.D_E_L_E_T_ = ' '"
	cQuery +=               ") saldo"
	cQuery +=     " ON saldo.MF_OP = SMF.MF_OP"
	If !Empty(cRecurso) .Or. cCTrab != Nil
		cQuery += " WHERE agrupChave.chave IN (SELECT CASE "
		cQuery +=                                       " WHEN SMFd.MF_ARVORE = ' ' THEN '_' || SMFd.MF_OP"
		cQuery +=                                       " ELSE SMFd.MF_ARVORE || '_'"
		cQuery +=                                   " END chave"
		cQuery +=                              " FROM " + RetSqlName("SMF") + " SMFd "
		cQuery +=                             " WHERE SMFd.MF_FILIAL = SMF.MF_FILIAL "
		cQuery +=                               " AND SMFd.MF_PROG   = SMF.MF_PROG "
		If nTipoEquip == FILTRO_TIPO_EQUIPAMENTO_APENAS_PAI
			cQuery +=                           " AND SMFd.MF_OP = SMF.MF_OP "
		EndIf
		If !Empty(cRecurso)
			cQuery +=                           " AND SMFd.MF_RECURSO IN ('" + StrTran(cRecurso, ",", "','") + "') "
		EndIf
		If cCTrab != Nil
			cQuery +=                           " AND SMFd.MF_CTRAB IN ('" + StrTran(cCTrab, ",", "','") + "') "
		EndIf
		cQuery +=                               " AND SMFd.D_E_L_E_T_ = ' ') "
	EndIf
	cQuery +=  " ORDER BY SMF.MF_PRIOR"

	If "MSSQL" $ TcGetDb()
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"    ] := {}
	oDetail["data"     ] := {}
	oDetail["isLoading"] := .F.

	If (cAlias)->(!Eof())
		BeginSql Alias cAliTotal
			SELECT COUNT(*) TOTAL
			  FROM %Table:SMF% SMF
			 WHERE SMF.MF_FILIAL = %xFilial:SMF%
			   AND SMF.MF_PROG   = %Exp:cProg%
			   AND SMF.%NotDel%
		EndSql
		nTotalReg := (cAliTotal)->TOTAL
		(cAliTotal)->(dbCloseArea())
	EndIf

	While (cAlias)->(!EoF())
		nCont++

		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCont]["prioridade"   ] := (cAlias)->MF_PRIOR
		oReturn["items"][nCont]["ordemProducao"] := (cAlias)->MF_OP
		oReturn["items"][nCont]["produto"      ] := RTrim((cAlias)->C2_PRODUTO) + " - " + RTrim((cAlias)->B1_DESC)
		oReturn["items"][nCont]["saldo"        ] := (cAlias)->saldo
		oReturn["items"][nCont]["arvore"       ] := (cAlias)->MF_ARVORE
		oReturn["items"][nCont]["chave"        ] := RTrim((cAlias)->chave)
		oReturn["items"][nCont]["qtdChave"     ] := (cAlias)->total
		oReturn["items"][nCont]["total"        ] := nTotalReg
		oReturn["items"][nCont]["posicao"      ] := Val((cAlias)->MF_PRIOR)
		oReturn["items"][nCont]["details"      ] := JsonObject():New()
		oReturn["items"][nCont]["details"      ] := oDetail

		(cAlias)->(dbSkip())

		If nCont >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FreeObj(oReturn)
	FreeObj(oDetail)
Return aReturn

/*/{Protheus.doc} GET PRIO_DET /api/pcp/v1/pcpa152prioridade/{programacao}/detalhes/{chave}
Retorna os detalhes da consulta de prioridade.
@type  WSMETHOD
@author Lucas Fagundes
@since 13/08/2024
@version P12
@param 01 programacao, Caracter, Código da programação.
@param 02 chave      , Caracter, Chave da árvore.
@param 03 page       , Numerico, Página da consulta.
@param 04 pageSize   , Numerico, Tamanho da página.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET PRIO_DET PATHPARAM programacao, chave QUERYPARAM page, pageSize WSSERVICE PCPA152PRIORIDADE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRIORIDADE"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := detPrior(Self:programacao, Self:chave, Self:page, Self:pageSize)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lReturn

/*/{Protheus.doc} detPrior
Retorna os detalhes da consulta de prioridades.
@type  Static Function
@author Lucas Fagundes
@since 21/08/2024
@version P12
@param 01 cProg    , Caracter, Código da programação.
@param 02 cChave   , Caracter, Chave da árvore.
@param 03 nPage    , Numerico, Página da consulta.
@param 04 nPageSize, Numerico, Tamanho da página.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function detPrior(cProg, cChave, nPage, nPageSize)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cBanco  := TcGetDb()
	Local cOPPai  := ""
	Local cQuery  := ""
	Local nCont   := 0
	Local nStart  := 0
	Local oReturn := JsonObject():New()

	cQuery := " SELECT SMF.MF_PRIOR,   "
	cQuery += "        SMF.MF_OP,      "
	cQuery += "        SMF.MF_OPER,    "
	cQuery += "        SMF.MF_ARVORE,  "
	cQuery += "        SMF.MF_DTINI,   "
	cQuery += "        SMF.MF_DTENT,   "
	cQuery += "        SMF.MF_SALDO,   "
	cQuery += "        SMF.MF_SEQPAI,  "
	cQuery += "        SC2.C2_NUM,     "
	cQuery += "        SC2.C2_ITEM,    "
	cQuery += "        SC2.C2_ITEMGRD, "
	cQuery += "        SC2.C2_PRODUTO, "
	cQuery += "        SB1.B1_DESC,    "
	cQuery += "        COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) AS G2_DESCRI, "
	cQuery += "        SMF.MF_RECURSO, "
	cQuery += "        SH1.H1_DESCRI, "
	If possuiHZ7()
		cQuery +=    " HZ7.HZ7_SEQ, "
	EndIf
	cQuery += "        SMF.MF_CTRAB, "
	cQuery += "        SHB.HB_NOME, "
	cQuery += "        SH1.H1_ILIMITA "
	cQuery += "   FROM " + RetSqlName("SMF") + " SMF "
	If possuiHZ7()
		cQuery += " INNER JOIN " + RetSqlName("HZ7") + " HZ7 "
		cQuery +=    " ON HZ7.HZ7_FILIAL = '" + xFilial("HZ7") + "' "
		cQuery +=   " AND HZ7.HZ7_PROG   = SMF.MF_PROG "
		cQuery +=   " AND HZ7.HZ7_ID     = SMF.MF_ID "
		cQuery +=   " AND HZ7.HZ7_RECURS = SMF.MF_RECURSO "
		cQuery +=   " AND HZ7.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery += "  INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery += "     ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery += "    AND " + PCPQrySC2("SC2", "SMF.MF_OP")
	cQuery += "    AND SC2.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "     ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery += "    AND SB1.B1_COD     = SC2.C2_PRODUTO "
	cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "   LEFT JOIN " + RetSqlName("SHY") + " SHY "
	cQuery += "     ON SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
	cQuery += "    AND SHY.HY_OP      = SMF.MF_OP "
	cQuery += "    AND SHY.HY_ROTEIRO = SMF.MF_ROTEIRO "
	cQuery += "    AND SHY.HY_OPERAC  = SMF.MF_OPER "
	cQuery += "    AND SHY.HY_TEMPAD <> 0 "
	cQuery += "    AND SHY.D_E_L_E_T_ = ' ' "
	cQuery += "   LEFT JOIN " + RetSqlName("SG2") + " SG2 "
	cQuery += "     ON SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
	cQuery += "    AND SG2.G2_CODIGO  = SMF.MF_ROTEIRO "
	cQuery += "    AND SG2.G2_OPERAC  = SMF.MF_OPER "
	cQuery += "    AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
	cQuery += "    AND SHY.HY_OP IS NULL "
	cQuery += "    AND SG2.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cQuery += "     ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cQuery += "    AND SH1.H1_CODIGO  = SMF.MF_RECURSO "
	cQuery += "    AND SH1.D_E_L_E_T_ = ' ' "
	cQuery += "   LEFT JOIN " + RetSqlName("SHB") + " SHB "
	cQuery += "     ON SHB.HB_FILIAL  = '" + xFilial("SHB") + "' "
	cQuery += "    AND SHB.HB_COD     = SMF.MF_CTRAB "
	cQuery += "    AND SHB.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
	cQuery += "    AND SMF.MF_PROG    = '" + cProg + "' "
	If "MSSQL" $ cBanco
		cQuery += "    AND CASE  "
		cQuery += "             WHEN SMF.MF_ARVORE = ' ' THEN '_' || SMF.MF_OP "
		cQuery += "             ELSE SMF.MF_ARVORE || '_' "
		cQuery += "        END = '" + cChave + "' "
	Else
		cQuery += "    AND CASE  "
		cQuery += "             WHEN SMF.MF_ARVORE = ' ' THEN RTRIM('_' || SMF.MF_OP) "
		cQuery += "             ELSE RTRIM(SMF.MF_ARVORE || '_') "
		cQuery += "        END = RTRIM('" + cChave + "') "
	EndIf
	cQuery += "    AND SMF.D_E_L_E_T_ = ' '  "
	cQuery += "  ORDER BY SMF.MF_PRIOR "

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		cOPPai := ""
		nCont++

		If !Empty((cAlias)->MF_SEQPAI)
			cOPPai := (cAlias)->C2_NUM + (cAlias)->C2_ITEM + (cAlias)->MF_SEQPAI + (cAlias)->C2_ITEMGRD
		EndIf

		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCont]["prioridade"       ] := (cAlias)->MF_PRIOR
		oReturn["items"][nCont]["ordemProducao"    ] := (cAlias)->MF_OP
		oReturn["items"][nCont]["operacao"         ] := RTrim((cAlias)->MF_OPER) + Iif(Empty((cAlias)->G2_DESCRI), "", " - " + (cAlias)->G2_DESCRI)
		oReturn["items"][nCont]["recurso"          ] := RTrim((cAlias)->MF_RECURSO) + " - " + RTrim((cAlias)->H1_DESCRI)
		oReturn["items"][nCont]["arvore"           ] := (cAlias)->MF_ARVORE
		oReturn["items"][nCont]["produto"          ] := RTrim((cAlias)->C2_PRODUTO) + " - " + RTrim((cAlias)->B1_DESC)
		oReturn["items"][nCont]["dataInicio"       ] := PCPConvDat((cAlias)->MF_DTINI, 4)
		oReturn["items"][nCont]["dataEntrega"      ] := PCPConvDat((cAlias)->MF_DTENT, 4)
		oReturn["items"][nCont]["saldo"            ] := (cAlias)->MF_SALDO
		oReturn["items"][nCont]["ordemPai"         ] := cOPPai
		oReturn["items"][nCont]["chave"            ] := cChave
		oReturn["items"][nCont]["alocouAlternativo"] := .F.
		oReturn["items"][nCont]["recursoIlimitado" ] := (cAlias)->H1_ILIMITA == "S"

		If possuiHZ7()
			oReturn["items"][nCont]["alocouAlternativo"] := (cAlias)->HZ7_SEQ != PCPA152TempoOperacao():getSequenciaRecursoPrincipal()
		EndIf

		oReturn["items"][nCont]["centroTrabalho"] := RTrim((cAlias)->MF_CTRAB)
		If !Empty((cAlias)->HB_NOME)
			oReturn["items"][nCont]["centroTrabalho"] += " - " + RTrim((cAlias)->HB_NOME)
		EndIf

		(cAlias)->(dbSkip())

		If nCont >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET PRIO_EXP /api/pcp/v1/pcpa152prioridade/{programacao}/exportacao
Retorna os registros de priodade para exportação
@type  WSMETHOD
@author Lucas Fagundes
@since 22/08/2024
@version P12
@param 01 programacao   , Caracter, Código da programação.
@param 02 ordemProducao , Caracter, Filtra as ordens de produção.
@param 03 produto       , Caracter, Filtra os produtos.
@param 04 recurso       , Caracter, Filtra os recursos.
@param 05 centroTrabalho, Caracter, Filtra os centros de trabalho.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET PRIO_EXP PATHPARAM programacao QUERYPARAM ordemProducao, produto, recurso, centroTrabalho WSSERVICE PCPA152PRIORIDADE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRIORIDADE"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := expPrior(Self:programacao, Self:ordemProducao, Self:produto, Self:recurso, Self:centroTrabalho)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lReturn

/*/{Protheus.doc} expPrior
Retorna os registros de prioridade para exportação.
@type  Static Function
@author Lucas Fagundes
@since 22/08/2024
@version P12
@param 01 cProg  , Caracter, Código da programação.
@param 02 cOrdens, Caracter, Filtra as ordens de produção.
@param 03 cProds , Caracter, Filtra os produtos.
@param 04 cRecs  , Caracter, Filtra os recursos.
@param 05 cCTs   , Caracter, Filtra os centros de trabalho.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function expPrior(cProg, cOrdens, cProds, cRecs, cCTs)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cOPPai  := ""
	Local cQuery  := ""
	Local oItem   := Nil
	Local oReturn := JsonObject():New()

	cQuery := " SELECT SMF.MF_PRIOR,   "
	cQuery +=        " SMF.MF_OP,      "
	cQuery +=        " SMF.MF_OPER,    "
	cQuery +=        " SMF.MF_ARVORE,  "
	cQuery +=        " SC2.C2_PRODUTO, "
	cQuery +=        " SMF.MF_DTINI,   "
	cQuery +=        " SMF.MF_DTENT,   "
	cQuery +=        " SMF.MF_SALDO,   "
	cQuery +=        " SMF.MF_SEQPAI,  "
	cQuery +=        " SC2.C2_NUM,     "
	cQuery +=        " SC2.C2_ITEM,    "
	cQuery +=        " SC2.C2_ITEMGRD, "
	cQuery +=        " SB1.B1_DESC,    "
	cQuery +=        " COALESCE(SHY.HY_DESCRI, SG2.G2_DESCRI) AS G2_DESCRI, "
	cQuery +=        " SMF.MF_RECURSO, "
	cQuery +=        " SH1.H1_DESCRI   "
	cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND " + PCPQrySC2("SC2", "SMF.MF_OP")
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "

	If !Empty(cProds)
		cQuery += " AND SC2.C2_PRODUTO IN ('" + StrTran(cProds, ",", "','") + "') "
	EndIf

	cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "     ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery += "    AND SB1.B1_COD     = SC2.C2_PRODUTO "
	cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "   LEFT JOIN " + RetSqlName("SHY") + " SHY "
	cQuery += "     ON SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
	cQuery += "    AND SHY.HY_OP      = SMF.MF_OP "
	cQuery += "    AND SHY.HY_ROTEIRO = SMF.MF_ROTEIRO "
	cQuery += "    AND SHY.HY_OPERAC  = SMF.MF_OPER "
	cQuery += "    AND SHY.HY_TEMPAD <> 0 "
	cQuery += "    AND SHY.D_E_L_E_T_ = ' ' "
	cQuery += "   LEFT JOIN " + RetSqlName("SG2") + " SG2 "
	cQuery += "     ON SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
	cQuery += "    AND SG2.G2_CODIGO  = SMF.MF_ROTEIRO "
	cQuery += "    AND SG2.G2_OPERAC  = SMF.MF_OPER "
	cQuery += "    AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
	cQuery += "    AND SHY.HY_OP IS NULL "
	cQuery += "    AND SG2.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cQuery += "     ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cQuery += "    AND SH1.H1_CODIGO  = SMF.MF_RECURSO "
	cQuery += "    AND SH1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
	cQuery +=    " AND SMF.MF_PROG    = '" + cProg + "' "
	cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "

	If !Empty(cOrdens)
		cQuery += " AND SMF.MF_OP IN ('" + StrTran(cOrdens, ",", "','") + "') "
	EndIf

	If !Empty(cRecs)
		cQuery += " AND SMF.MF_RECURSO IN ('" + StrTran(cRecs, ",", "','") + "') "
	EndIf

	If !Empty(cCTs)
		cQuery += " AND SMF.MF_CTRAB IN ('" + StrTran(cCTs, ",", "','") + "') "
	EndIf

	cQuery +=  " ORDER BY SMF.MF_PRIOR "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		cOPPai := ""
		oItem  := JsonObject():New()

		If !Empty((cAlias)->MF_SEQPAI)
			cOPPai := (cAlias)->C2_NUM + (cAlias)->C2_ITEM + (cAlias)->MF_SEQPAI + (cAlias)->C2_ITEMGRD
		EndIf

		oItem["prioridade"   ] := (cAlias)->MF_PRIOR
		oItem["ordemProducao"] := (cAlias)->MF_OP
		oItem["operacao"     ] := RTrim((cAlias)->MF_OPER) + Iif(Empty((cAlias)->G2_DESCRI), "", " - " + (cAlias)->G2_DESCRI)
		oItem["recurso"      ] := RTrim((cAlias)->MF_RECURSO) + " - " + RTrim((cAlias)->H1_DESCRI)
		oItem["arvore"       ] := (cAlias)->MF_ARVORE
		oItem["produto"      ] := RTrim((cAlias)->C2_PRODUTO) + " - " + RTrim((cAlias)->B1_DESC)
		oItem["dataInicio"   ] := PCPConvDat((cAlias)->MF_DTINI, 4)
		oItem["dataEntrega"  ] := PCPConvDat((cAlias)->MF_DTENT, 4)
		oItem["saldo"        ] := (cAlias)->MF_SALDO
		oItem["ordemPai"     ] := cOPPai

		aAdd(oReturn["items"], oItem)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FreeObj(oItem)
	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} POST UPD_PRIO /api/pcp/v1/pcpa152prioridade/{programacao}/update
Atualiza a prioridade dos registros
@type  WSMETHOD
@author Lucas Fagundes
@since 22/08/2024
@version P12
@param programacao, Caracter, Código da programação
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD POST UPD_PRIO PATHPARAM programacao WSSERVICE PCPA152PRIORIDADE
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152PRIORIDADE"), Break(oError)})
	Local cBody     := ""
	Local oBody     := JsonObject():New()

	cBody := DecodeUTF8(Self:getContent())
	oBody:fromJson(cBody)

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := updPriors(Self:programacao, oBody)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

	FreeObj(oBody)
Return lReturn

/*/{Protheus.doc} updPriors
Atualiza a prioridade dos registros.
@type  Static Function
@author Lucas Fagundes
@since 22/08/2024
@version P12
@param 01 cProg, Caracter, Código da programação
@param 02 oPriors, Caracter, Registros que terão sua prioridade atualizada.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function updPriors(cProg, oPriors)
	Local aReturn    := Array(3)
	Local cErro      := ""
	Local cUpdate    := ""
	Local lSucesso   := .T.
	Local oReturn    := JsonObject():New()
	Local oTemp      := Nil

	oTemp := tempUpdate()

	BEGIN TRANSACTION

		lSucesso := insereTemp(cProg, oPriors, oTemp, @cErro)

		If lSucesso
			cUpdate := " UPDATE " + RetSqlName("SMF")
			cUpdate +=    " SET MF_PRIOR = (SELECT TEMP.PRIORIDADE "
			cUpdate +=                      " FROM " + oTemp:getRealName() + " TEMP "
			cUpdate +=                     " WHERE TEMP.RECNO = " + RetSqlName("SMF") + ".R_E_C_N_O_) "
			cUpdate +=  " WHERE " + RetSqlName("SMF") + ".R_E_C_N_O_ IN (SELECT TEMP.RECNO "
			cUpdate +=   " FROM " + oTemp:getRealName() + " TEMP) "

			lSucesso := TcSqlExec(cUpdate) >= 0
			cErro    := TcSqlError()
		EndIf

		If lSucesso
			PCPA152Process():atualizaPendenciaDeReprocessamento(cProg, REPROCESSAMENTO_PENDENTE)
		Else
			oReturn["message"        ] := STR0575 // "Ocorreu um erro ao atualizar as prioridades"
			oReturn["detailedMessage"] := AllTrim(cErro)

			DisarmTransaction()
		EndIf

	END TRANSACTION

	aReturn[1] := lSucesso
	aReturn[2] := Iif(lSucesso, 200, 500)
	aReturn[3] := oReturn:toJson()

	oTemp:delete()
	FreeObj(oTemp)

	FreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} insereTemp
Carrega os dados na tabela temporaria.
@type  Static Function
@author Lucas Fagundes
@since 03/09/2024
@version P12
@param 01 cProg , Caracter, Código da programação.
@param 02 oDados, Object  , Prioridades que devem ser atualizadas.
@param 03 oTemp , Object  , Instancia da tabela temporaria.
@param 04 cErro , Caracter, Retorna por referencia a mensagem de erro.
@return lSucesso, Logico, Indica se concluiu a inclusão com sucesso.
/*/
Static Function insereTemp(cProg, oDados, oTemp, cErro)
	Local aChaves    := {}
	Local cAlias     := GetNextAlias()
	Local cChave     := ""
	Local cMaiorPrio := ""
	Local cMenorPrio := ""
	Local cPrior     := ""
	Local cQuery     := ""
	Local lSucesso   := .T.
	Local nIndex     := 0
	Local nTamPrior  := GetSx3Cache("MF_PRIOR", "X3_TAMANHO")
	Local nTotal     := 0
	Local oAlteradas := oDados["alteradas"]
	Local oBulk      := Nil
	Local oChaves    := JsonObject():New()
	Local oFilhos    := Nil

	oBulk   := bulkTemp(oTemp)
	oFilhos := qryFilhos(cProg)

	idInterv(oAlteradas, @cMenorPrio, @cMaiorPrio, @oChaves)

	cQuery := " SELECT MIN(SMF.MF_PRIOR) MF_PRIOR, "
	cQuery +=        " CASE  "
	cQuery +=            " WHEN SMF.MF_ARVORE = ' ' THEN '_' || SMF.MF_OP "
	cQuery +=            " ELSE SMF.MF_ARVORE || '_' "
	cQuery +=        " END chave "
	cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
	cQuery +=  " WHERE SMF.MF_FILIAL  = '" + xFilial("SMF") + "' "
	cQuery +=    " AND SMF.MF_PROG    = '" + cProg          + "' "
	cQuery +=    " AND SMF.MF_PRIOR   >= '" + cMenorPrio + "' "
	cQuery +=    " AND SMF.MF_PRIOR   <= '" + cMaiorPrio + "' "
	cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
	cQuery +=  " GROUP BY CASE "
	cQuery +=               " WHEN SMF.MF_ARVORE = ' ' THEN '_' || SMF.MF_OP "
	cQuery +=               " ELSE SMF.MF_ARVORE || '_' "
	cQuery +=           " END "
	cQuery +=  " ORDER BY MF_PRIOR "

	If "MSSQL" $ TcGetDb()
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	cPrior := (cAlias)->MF_PRIOR

	While (cAlias)->(!EoF()) .And. lSucesso
		cChave := RTrim((cAlias)->chave)

		If oChaves:hasProperty(cChave)
			(cAlias)->(dbSkip())
			Loop
		EndIf

		While oAlteradas:hasProperty(cPrior)
			cPrior := PadL(Val(cPrior) + oAlteradas[cPrior]["qtdChave"], nTamPrior, "0")
		End

		lSucesso := insertChav(cChave, oFilhos, oBulk, @cPrior)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If lSucesso
		aChaves := oChaves:getNames()
		nTotal  := Len(aChaves)
		nIndex  := 1

		While nIndex <= nTotal .And. lSucesso
			cChave := aChaves[nIndex]
			cPrior := oChaves[cChave]

			lSucesso := insertChav(cChave, oFilhos, oBulk, @cPrior)

			nIndex++
		End
	EndIf

	cErro := oBulk:getError()
	If lSucesso
		lSucesso := oBulk:close()
		cErro    := oBulk:getError()
	EndIf

	oBulk:destroy()
	FreeObj(oBulk)

	oFilhos:destroy()
	FreeObj(oFilhos)

	FreeObj(oChaves)
	aSize(aChaves, 0)
Return lSucesso

/*/{Protheus.doc} idInterv
Identifica o intervalo das prioridades que deve ser alterado.
@type  Static Function
@author Lucas Fagundes
@since 03/09/2024
@version P12
@param 01 oAlteradas, Object  , Json com as prioridades que serão atualizadas.
@param 02 cMenorPrio, Caracter, Retorna por referencia a primeira prioridade do intervalo.
@param 03 cMaiorPrio, Caracter, Retorna por referencia a ultima prioridade do intervalo.
@param 04 oChaves   , Object  , Retorna por referencia o json com as chaves dos registros alterados.
@return Nil
/*/
Static Function idInterv(oAlteradas, cMenorPrio, cMaiorPrio, oChaves)
	Local aPriors    := {}
	Local cPrior     := ""
	Local nAntMaior  := 0
	Local nIndex     := 0
	Local nMaiorPrio := 0
	Local nNewMaior  := 0
	Local nTotal     := 0

	aPriors := oAlteradas:getNames()
	nTotal  := Len(aPriors)

	For nIndex := 1 To nTotal
		cPrior := aPriors[nIndex]

		nNewMaior := (Val(cPrior)                           + (oAlteradas[cPrior]["qtdChave"]-1))
		nAntMaior := (Val(oAlteradas[cPrior]["prioridade"]) + (oAlteradas[cPrior]["qtdChave"]-1))
		If nNewMaior > nMaiorPrio .Or. nAntMaior > nMaiorPrio
			nMaiorPrio := Iif(nNewMaior > nAntMaior, nNewMaior, nAntMaior)
		EndIf

		If cMenorPrio == "" .Or. cPrior < cMenorPrio .Or. oAlteradas[cPrior]["prioridade"] < cMenorPrio
			cMenorPrio := Iif(cPrior < oAlteradas[cPrior]["prioridade"], cPrior, oAlteradas[cPrior]["prioridade"])
		EndIf

		oChaves[oAlteradas[cPrior]["chave"]] := cPrior
	Next

	cMaiorPrio := PadL(nMaiorPrio, GetSX3Cache("MF_PRIOR", "X3_TAMANHO"), "0")

	aSize(aPriors, 0)
Return Nil

/*/{Protheus.doc} qryFilhos
Retorna o objeto para busca das prioridades filhas de uma chave.
@type  Static Function
@author Lucas Fagundes
@since 03/09/2024
@version P12
@param cProg, Caracter, Código da programação.
@return oFilhos, Object, Instancia da classe FwExecStatement com a query para buscar as prioridades filhas.
/*/
Static Function qryFilhos(cProg)
	Local cBanco  := TcGetDb()
	Local cQuery  := ""
	Local oFilhos := Nil

	cQuery := " SELECT R_E_C_N_O_ recno "
	cQuery +=   " FROM " + RetSqlName("SMF") + " SMF "
	cQuery +=  " WHERE SMF.MF_FILIAL = '" + xFilial("SMF") + "' "
	cQuery +=    " AND SMF.MF_PROG   = '" + cProg          + "' "

	If cBanco == "POSTGRES"
		cQuery +=" AND CASE  "
		cQuery +=        " WHEN SMF.MF_ARVORE = ' ' THEN RTRIM('_' || SMF.MF_OP) "
		cQuery +=        " ELSE RTRIM(SMF.MF_ARVORE || '_') "
		cQuery +=    " END = RTRIM(?) "
	Else
		cQuery +=" AND CASE  "
		cQuery +=        " WHEN SMF.MF_ARVORE = ' ' THEN '_' || SMF.MF_OP "
		cQuery +=        " ELSE SMF.MF_ARVORE || '_' "
		cQuery +=    " END = ? "
	EndIf

	cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
	cQuery +=  " ORDER BY SMF.MF_PRIOR "

	If "MSSQL" $ cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	oFilhos := FWExecStatement():New(cQuery)

Return oFilhos

/*/{Protheus.doc} tempUpdate
Cria tabela temporaria para realizar atualização das prioridades.
@type  Static Function
@author Lucas Fagundes
@since 30/08/2024
@version P12
@return oTemp, Object, Tabela temporaria.
/*/
Static Function tempUpdate()
	Local oTemp := FwTemporaryTable():New()

	oTemp:setFields(tempFields())
	oTemp:AddIndex("01", {"RECNO", "PRIORIDADE"})

	oTemp:create()

Return oTemp

/*/{Protheus.doc} bulkTemp
Cria o FwBulk para inserção dos itens na tabela temporária.
@type  Static Function
@author Lucas Fagundes
@since 30/08/2024
@version P12
@param oTemp, Object, Tabela temporária.
@return oBulk, Object, Bulk criado para inserir os itens na temporária.
/*/
Static Function bulkTemp(oTemp)
	Local oBulk := FwBulk():New(oTemp:getTableNameForTCFunctions())

	oBulk:setFields(tempFields())

Return oBulk

/*/{Protheus.doc} tempFields
Retorna os campos da tabela temporária.
@type  Static Function
@author Lucas Fagundes
@since 30/08/2024
@version P12
@return aFields, Array, Campos da tabela temporária
/*/
Static Function tempFields()
	Local aFields := {}

	aAdd(aFields, {"RECNO"     , "N", 11, 0})
	aAdd(aFields, {"PRIORIDADE", "C", GetSX3Cache("MF_PRIOR", "X3_TAMANHO"), 0})

Return aFields

/*/{Protheus.doc} possuiHZ7
Verifica se a tabela HZ7 está presente no dicionario de dados.
@type  Static Function
@author Lucas Fagundes
@since 21/10/2024
@version P12
@return _lTemHZ7, Logico, Indica se possui a tabela HZ7 no dicionario de dados.
/*/
Static Function possuiHZ7()

	If _lTemHZ7 == Nil
		_lTemHZ7 := AliasInDic("HZ7")
	EndIf

Return _lTemHZ7

/*/{Protheus.doc} insertChav
Insere na tabela temporária a nova prioridade de uma árvore.

@type  Static Function
@author Lucas Fagundes
@since 02/12/2024
@version P12
@param 01 cChave, Caracter, Chave que irá atualizar a prioridade.
@param 02 oQuery, Object  , FWExecStatement com a query para buscar os registros da chave.
@param 03 oBulk , Object  , FwBulk que irá inserir as prioridades na tabela temporaria.
@param 04 cPrior, Caracter, Prioridade inicial que será atribuida a chave (retorna a prioridade final por referência).
@return lSucesso, Lógico, Retorna se teve sucesso na inserção dos registros.
/*/
Static Function insertChav(cChave, oQuery, oBulk, cPrior)
	Local cAlias   := ""
	Local lSucesso := .T.

	oQuery:setString(1, cChave)
	cAlias := oQuery:openAlias()

	While (cAlias)->(!EoF()) .And. lSucesso

		lSucesso := oBulk:addData({(cAlias)->recno, cPrior})
		cPrior   := Soma1(cPrior)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return lSucesso


