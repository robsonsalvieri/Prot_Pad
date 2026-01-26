#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA681.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE STATUS_ATIVO          "1"
#DEFINE STATUS_INATIVO        "2"

#DEFINE MR_TIPO_RECURSO    "1"
#DEFINE MR_TIPO_FERRAMENTA "2"

#DEFINE HWK_ORIGEM_HWF        "1"
#DEFINE HWK_ORIGEM_SMK        "2"
#DEFINE HWK_ORIGEM_CALENDARIO "3"

#DEFINE ADADOS_HWK_POS_RECURSO 1
#DEFINE ADADOS_HWK_POS_CTRAB   2
#DEFINE ADADOS_HWK_POS_DATA    3
#DEFINE ADADOS_HWK_POS_HRINI   4
#DEFINE ADADOS_HWK_POS_HRFIM   5
#DEFINE ADADOS_HWK_POS_TEMPOT  6
#DEFINE ADADOS_HWK_POS_ORIGEM  7

Static _aDadosHWK := {}
Static _oOPsProgr := Nil
Static _oSelf     := Nil
Static _lApoCRP AS Logical
Static _lDicFerra := Nil

/*/{Protheus.doc} MATA681ApontamentoCRP
Classe reponsável pelo controle dos apontamentos do CRP.
@author Lucas Fagundes
@since 05/12/2023
@version P12
/*/
Class MATA681ApontamentoCRP From LongClassName
	Data aDados       as Array
	Data cFilterQuery as Caracter
	Data lPerdInf     as Logical
	Data oDados       as Object
	Data oBkpCampos   as Object
	Data oMapModel    as Object
	Data oModel       as Object
	Data oStructSH6   as Object
	Data oView        as Object
	Data oViewExec    as Object

	Method new() Constructor
	Method destroy()

	Method abreTela()
	Method armazenaDados()
	Method carregaDados()
	Method carregaSemTela(oDados)
	Method getApontamentos()
	Method getQuery()
	Method mapaModelo()
	Method montaModel()
	Method montaView()
	Method recuperaDados()
	Method setFilterQuery(cFilter)

	Method carregaDataEHora()
	Method carregaSelecionado()
	Method executaTrigger(cCampo)
	Method executaValid(cCampo)
	Method gravaBackupCampos()
	Method limpaFormulario()
	Method restauraCampos()
	Method setaCampo(cCampo, cValue)

	Static Method ativaHWF()
	Static Method ativaHZL()
	Static Method buscaTempoProgramado(cOp, cOperac, cRecurso, dIniApont, cIniAponHr, dFimApont, cFimAponHr, lUsaCalend)
	Static Method encerraOrdemDeProducao(cOrdem)
	Static Method estornoApontamento(cOp, cOperacao, cIdent)
	Static Method gravaApontamentosCRP(cOp, cOperacao, cIdent)
	Static Method inativaHWF()
	Static Method inativaHZL()
	Static Method opOperacaoProgramadas(cOp, cOperac)

EndClass

/*/{Protheus.doc} new
Método construtor da classe.
@author Lucas Fagundes
@since 05/12/2023
@version P12
@return Self
/*/
Method new() Class MATA681ApontamentoCRP
	::aDados     := {}
	::lPerdInf   := SuperGetMV("MV_PERDINF", .F., .F.)
	::oBkpCampos := JsonObject():New()
	::oStructSH6 := FWFormStruct(1, "SH6")
	::oDados     := JsonObject():New()

	::montaModel()
	::montaView()

	_oSelf := Self

Return Self

/*/{Protheus.doc} destroy
Método destrutor da classe.
@author Lucas Fagundes
@since 05/12/2023
@version P12
@return Nil
/*/
Method destroy() Class MATA681ApontamentoCRP

	::oModel:destroy()
	FreeObj(::oModel)

	::oView:destroy()
	FreeObj(::oView)

	FreeObj(::oDados)
	FwFreeArray(::aDados)

	FwFreeObj(::oViewExec)
	FwFreeObj(::oBkpCampos)
	FwFreeObj(::oStructSH6)
	FwFreeObj(::oMapModel)


	_oSelf := Nil
Return Nil

/*/{Protheus.doc} abreTela
Abre a tela de consulta dos apontamentos do CRP.
@author Lucas Fagundes
@since 05/12/2023
@version P12
@return Nil
/*/
Method abreTela() Class MATA681ApontamentoCRP
	Local aArea    := GetArea()
	Local aButtons := {}

	If ::oViewExec == Nil
		aButtons  := { {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F. ,Nil}, {.F., Nil}, {.F., Nil},;
		               {.T., STR0030}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil} } // "Selecionar"

		::oViewExec := FWViewExec():New()

		::oViewExec:setView(::oView)

		::oViewExec:setTitle(STR0029) // "Apontamentos CRP"
		::oViewExec:setOperation(MODEL_OPERATION_VIEW)
		::oViewExec:setReduction(45)

		::oViewExec:setButtons(aButtons)
		::oViewExec:setCancel({|oModel| confirmCRP()})
	EndIf

	::oViewExec:openView(.F.)

	RestArea(aArea)
	aSize(aArea, 0)
Return Nil

/*/{Protheus.doc} montaModel
Monta o modelo de dados para consulta de apontamentos do CRP.
@author Lucas Fagundes
@since 05/12/2023
@version P12
@return Nil
/*/
Method montaModel() Class MATA681ApontamentoCRP
	Local oStruCab   := FWFormModelStruct():New()
	Local oStruGrid  := FWFormStruct(1, "HWF", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|HWF_OP|HWF_OPER|HWF_RECURS|"})

	::oModel := MPFormModel():New("MATA681CRP")

	oStruCab:AddField("", "", "CAB", "N", 2, 0, {|| .T.}, Nil, {}, .T., Nil, .F., .F., .F., Nil)

	::oModel:addFields("CAB_INVISIVEL", /*cOwner*/, oStruCab, , , {|| loadCabInv()})
	::oModel:GetModel("CAB_INVISIVEL"):SetDescription(STR0031) // "Consulta CRP"
	::oModel:GetModel("CAB_INVISIVEL"):SetOnlyQuery(.T.)
	::oModel:GetModel("CAB_INVISIVEL"):setForceLoad(.T.)

	oStruGrid:AddField(STR0032, STR0032, "DATAINI"   , "D", GetSx3Cache("HWF_DATA"  , "X3_TAMANHO"), GetSx3Cache("HWF_DATA"  , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Data inicial"
	oStruGrid:AddField(STR0033, STR0033, "HORAINI"   , "C", GetSx3Cache("HWF_HRINI" , "X3_TAMANHO"), GetSx3Cache("HWF_HRINI" , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Hora inicial"
	oStruGrid:AddField(STR0034, STR0034, "DATAFIM"   , "D", GetSx3Cache("HWF_DATA"  , "X3_TAMANHO"), GetSx3Cache("HWF_DATA"  , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Data final"
	oStruGrid:AddField(STR0035, STR0035, "HORAFIM"   , "C", GetSx3Cache("HWF_HRFIM" , "X3_TAMANHO"), GetSx3Cache("HWF_HRFIM" , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Hora final"
	oStruGrid:AddField(STR0036, STR0036, "SALDO"     , "N", GetSx3Cache("C2_QUANT"  , "X3_TAMANHO"), GetSx3Cache("C2_QUANT"  , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Saldo"
	oStruGrid:AddField(STR0038, STR0038, "C2_PRODUTO", "C", GetSx3Cache("C2_PRODUTO", "X3_TAMANHO"), GetSx3Cache("C2_PRODUTO", "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Produto"
	oStruGrid:AddField(STR0039, STR0040, "B1_DESC"   , "C", GetSx3Cache("B1_DESC"   , "X3_TAMANHO"), GetSx3Cache("B1_DESC"   , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Descrição" "Descrição do produto"
	oStruGrid:AddField(STR0039, STR0041, "H1_DESCRI" , "C", GetSx3Cache("H1_DESCRI" , "X3_TAMANHO"), GetSx3Cache("H1_DESCRI" , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Descrição" "Descrição do recurso"
	oStruGrid:AddField(STR0042, STR0042, "LOCAL"     , "C", GetSx3Cache("C2_LOCAL"  , "X3_TAMANHO"), GetSx3Cache("C2_LOCAL"  , "X3_DECIMAL"), {|| .T.}, Nil, {}, .F., Nil, .F., .F., .F., Nil) // "Local"

	::oModel:AddGrid("GRID_APONTAMENTOS", "CAB_INVISIVEL", oStruGrid, , , , ,{|oGridModel| getAponCRP()})
	::oModel:GetModel("GRID_APONTAMENTOS"):SetDescription(STR0029) // "Apontamentos CRP"
	::oModel:GetModel("GRID_APONTAMENTOS"):SetOnlyQuery(.T.)
	::oModel:GetModel("GRID_APONTAMENTOS"):SetOptional(.T.)
	::oModel:GetModel("GRID_APONTAMENTOS"):setForceLoad(.T.)

	::oModel:SetDescription(STR0029) // "Apontamentos CRP"
	::oModel:SetPrimaryKey({})

	::mapaModelo()

Return Nil

/*/{Potheus.doc} mapaModelo
Cria o mapa que relaciona os campos da tela com os campos do modelo.
@author Lucas Fagundes
@since 06/12/2023
@version P1
@return Nil
/*/
Method mapaModelo() Class MATA681ApontamentoCRP

	::oMapModel := JsonObject():New()
	::oMapModel["H6_OP"     ] := "HWF_OP"
	::oMapModel["H6_OPERAC" ] := "HWF_OPER"
	::oMapModel["H6_RECURSO"] := "HWF_RECURS"
	::oMapModel["H6_DATAINI"] := "DATAINI"
	::oMapModel["H6_DATAFIN"] := "DATAFIM"
	::oMapModel["H6_HORAINI"] := "HORAINI"
	::oMapModel["H6_HORAFIN"] := "HORAFIM"
	::oMapModel["H6_QTDPROD"] := "SALDO"
	::oMapModel["H6_LOCAL"  ] := "LOCAL"

Return Nil

/*/{Protheus.doc} montaView
Monta a view para a tela de consulta dos apontamentos do CRP.
@author Lucas Fagundes
@since 05/12/2023
@version P12
@return Nil
/*/
Method montaView() Class MATA681ApontamentoCRP
	Local oStruGrid := FWFormStruct(2, "HWF", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|HWF_OP|HWF_OPER|HWF_RECURS|"})

	::oView := FWFormView():New()
	::oView:SetModel(::oModel)

	oStruGrid:AddField("C2_PRODUTO", "02", STR0038, STR0038, {}, "C", GetSX3Cache("C2_PRODUTO" , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Produto"
	oStruGrid:AddField("B1_DESC"   , "03", STR0039, STR0040, {}, "C", GetSX3Cache("B1_DESC"    , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Descrição" "Descrição do produto"
	oStruGrid:AddField("DATAINI"   , "04", STR0032, STR0032, {}, "D", GetSX3Cache("HWF_DATA"   , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Data inicial"
	oStruGrid:AddField("HORAINI"   , "05", STR0033, STR0033, {}, "C", GetSX3Cache("HWF_HORAINI", "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Hora inicial"
	oStruGrid:AddField("DATAFIM"   , "06", STR0034, STR0034, {}, "D", GetSX3Cache("HWF_DATA"   , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Data final"
	oStruGrid:AddField("HORAFIM"   , "07", STR0035, STR0035, {}, "C", GetSX3Cache("HWF_HORAFIM", "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Hora final"
	oStruGrid:AddField("SALDO"     , "08", STR0036, STR0036, {}, "N", GetSX3Cache("C2_QUANT"   , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Saldo"
	oStruGrid:AddField("H1_DESCRI" , "10", STR0039, STR0041, {}, "C", GetSX3Cache("H1_DESCRI"  , "X3_PICTURE"), Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, .T., Nil, Nil) // "Descrição" "Descrição do recurso"

	oStruGrid:SetProperty("HWF_OP"    , MVC_VIEW_ORDEM, "00")
	oStruGrid:SetProperty("HWF_OPER"  , MVC_VIEW_ORDEM, "01")
	oStruGrid:SetProperty("HWF_RECURS", MVC_VIEW_ORDEM, "09")

	::oView:AddGrid("V_GRID_APONTAMENTOS", oStruGrid, "GRID_APONTAMENTOS")

	::oView:CreateHorizontalBox("BOX_GRID", 100)
	::oView:SetOwnerView("V_GRID_APONTAMENTOS", 'BOX_GRID')

	::oView:SetViewProperty("V_GRID_APONTAMENTOS", "ONLYVIEW")
	::oView:SetViewProperty("V_GRID_APONTAMENTOS", "GRIDFILTER", {.T.})
	::oView:SetViewProperty("V_GRID_APONTAMENTOS", "GRIDSEEK", {.T.})
	::oView:SetViewProperty("V_GRID_APONTAMENTOS", "GRIDDOUBLECLICK", {{|oFormulario, cFieldName, nLineGrid, nLineModel| dblClick()}})

	::oView:showUpdateMsg(.F.)

Return Nil

/*/{Protheus.doc} dblClick
Confirma a seleção da linha que teve double click e fecha a view.
@type  Static Function
@author Lucas Fagundes
@since 12/12/2023
@version P12
@return .F., Logico, Não permite editar o campo ao realizar o double click.
/*/
Static Function dblClick()

	If confirmCRP()
		_oSelf:oView:CloseOwner()
	EndIf

Return .F.

/*/{Protheus.doc} loadCabInv
Carga do cabeçalho invisivel da consulta de apontamentos do CRP.
@type  Static Function
@author Lucas Fagundes
@since 30/11/2023
@version P12
@return aLoad, Array, Dados do cabeçalho invisivel.
/*/
Static Function loadCabInv()
	Local aLoad := {}

	aAdd(aLoad, {1}) //dados
	aAdd(aLoad, 1  ) //recno

Return aLoad

/*/{Protheus.doc} confirmCRP
Inicia a carga do formulário com o apontamento selecionado.
@type  Static Function
@author Lucas Fagundes
@since 04/12/2023
@version P12
@return lFecha, Logico, Indica se deve fechar a tela.
/*/
Static Function confirmCRP()
	Local lFecha := .T.

	lFecha := _oSelf:carregaSelecionado()

Return lFecha

/*/{Protheus.doc} armazenaDados
Armazena dados já carregados nas variáveis de memória (M->)

@author lucas.franca
@since 06/09/2024
@version P12
@return Nil
/*/
Method armazenaDados() Class MATA681ApontamentoCRP
	Local aFields := Self:oStructSH6:getFields()
	Local cCampo  := ""
	Local nIndex  := 0
	Local nTotal  := Len(aFields)

	For nIndex := 1 To nTotal
		cCampo := aFields[nIndex][3]

		If Type("M->" + cCampo) != "U"
			Self:oDados[cCampo] := &("M->" + cCampo)
		EndIf
	Next nTotal

	aFields := Nil
Return

/*/{Protheus.doc} recuperaDados
Recupera para as variáveis de memória os valores armazenados no método armazenaDados

@author lucas.franca
@since 06/09/2024
@version P12
@return Nil
/*/
Method recuperaDados() Class MATA681ApontamentoCRP
	Local aCampos := Self:oDados:getNames()
	Local nIndex  := 0
	Local nTotal  := Len(aCampos)

	For nIndex := 1 To nTotal
		&("M->" + aCampos[nIndex]) := Self:oDados[aCampos[nIndex]]

		Self:oDados:delName(aCampos[nIndex])
	Next nIndex

	aSize(aCampos, 0)
Return

/*/{Protheus.doc} carregaDados
Realiza a carga dos dados para consulta na tela de apontamentos do CRP.
@author Lucas Fagundes
@since 05/12/2023
@version P12
@return Nil
/*/
Method carregaDados() Class MATA681ApontamentoCRP
	Local cAlias := GetNextAlias()
	Local cQuery := ""

	cQuery := ::getQuery()
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	TcSetField(cAlias, 'DATAINI', 'D', 8, 0)
	TcSetField(cAlias, 'DATAFIM', 'D', 8, 0)

	::aDados := {}

	While (cAlias)->(!EoF())

		aAdd(::aDados, {0, {;
			(cAlias)->HWF_OP       ,;
			(cAlias)->HWF_OPER     ,;
			(cAlias)->HWF_RECURS   ,;
			(cAlias)->DATAINI      ,;
			(cAlias)->HORAINI      ,;
			(cAlias)->DATAFIM      ,;
			(cAlias)->HORAFIM      ,;
			Max(0, (cAlias)->SALDO),;
			(cAlias)->C2_PRODUTO   ,;
			(cAlias)->B1_DESC      ,;
			(cAlias)->H1_DESCRI    ,;
			(cAlias)->C2_LOCAL     ,;
		}})

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} carregaSemTela
Carrega os dados na tela do apontamento sem exibir a tela de seleção

@author lucas.franca
@since 06/09/2024
@version P12
@param oDados, Object, Dados da chave do registro (OP e Operação)
@return lRet, Logic, Indica que os dados foram carregados com sucesso
/*/
Method carregaSemTela(oDados) Class MATA681ApontamentoCRP
	Local cFilter := ""
	Local lRet    := .F.

	Private aTELA := {}
	Private aGETS := {}

	cFilter := " AND HWF.HWF_OP   = '" + oDados["ordem"   ] + "' "
	cFilter += " AND HWF.HWF_OPER = '" + oDados["operacao"] + "' "

	Self:setFilterQuery(cFilter)

	Self:oModel:setOperation(MODEL_OPERATION_VIEW)
	Self:oModel:Activate()

	If ::oModel:getModel("GRID_APONTAMENTOS"):isEmpty()
		Help( , , "Help", , STR0048, 1, 0,,,,,, {STR0049}) //"Não foi possível localizar os dados para realizar o apontamento." # "Atualize os dados consultados para realizar novos apontamentos."
		CockpitDaProducao():defineRetorno("refresh-all") //define que vai atualizar a tela completa no front ao sair da execução do advpl.
	Else
		RegToMemory("SH6", .T., .F.)
		lRet := Self:carregaSelecionado()

		If lRet
			//Se conseguiu atribuir todos os dados, armazena os valores em memória
			//para atribuir os valores novamente, pois ao abrir o AxInclui os dados serão apagados
			//da variável M->
			Self:armazenaDados()
		Else
			CockpitDaProducao():defineRetorno("no-refresh") //define que não vai atualizar os dados no front ao sair da execução do advpl.
		EndIf
	EndIf

	Self:oModel:deActivate()
	Self:setFilterQuery(Nil)
Return lRet

/*/{Protheus.doc} setFilterQuery
Define o filtro que deve ser adicionado na query de busca de dados

@author lucas.franca
@since 06/09/2024
@version P12
@param cFilter, Caracter, Filtro para utilizar na query
@return Nil
/*/
Method setFilterQuery(cFilter) Class MATA681ApontamentoCRP
	Self:cFilterQuery := cFilter
Return Nil

/*/{Protheus.doc} getAponCRP
Busca os apontamentos do CRP para consulta.
@type  Static Function
@author Lucas Fagundes
@since 30/11/2023
@version P12
@return aLoad, Array, Retorna o array com os dados para carga inicial do modelo.
/*/
Static Function getAponCRP()
	Local aLoad := _oSelf:getApontamentos()

Return aLoad

/*/{Protheus.doc} getQuery
Retorna a query para buscar os apontamentos do CRP.
@author Lucas Fagundes
@since 06/12/2023
@version P12
@return cQuery, Caracter, Query para buscar os apontamentos do CRP.
/*/
Method getQuery() Class MATA681ApontamentoCRP
	Local cQuery    := ""

	cQuery += " SELECT DISTINCT HWF.HWF_OP, "
	cQuery +=                 " SC2.C2_PRODUTO, "
	cQuery +=                 " SB1.B1_DESC, "
	cQuery +=                 " HWF.HWF_OPER, "
	cQuery +=                 " hwfMenor.HWF_DATA DATAINI, "
	cQuery +=                 " hwfMenor.HWF_HRINI HORAINI, "
	cQuery +=                 " hwfMaior.HWF_DATA DATAFIM, "
	cQuery +=                 " hwfMaior.HWF_HRFIM HORAFIM, "
	cQuery +=                 " HWF.HWF_RECURS, "
	cQuery +=                 " SH1.H1_DESCRI, "
	cQuery +=                 " SC2.C2_LOCAL, "
	cQuery +=                 " (SC2.C2_QUANT - COALESCE((SELECT SUM(SH6saldo.H6_QTDPROD) " + Iif(::lPerdInf, "", " + SUM(SH6saldo.H6_QTDPERD) ")
	cQuery +=                                             " FROM " + RetSqlName("SH6") + " SH6saldo "
	cQuery +=                                            " WHERE SH6saldo.H6_FILIAL  = '" + xFilial("SH6") + "' "
	cQuery +=                                              " AND SH6saldo.H6_OP      = HWF.HWF_OP "
	cQuery +=                                              " AND SH6saldo.H6_OPERAC  = HWF.HWF_OPER "
	cQuery +=                                              " AND SH6saldo.D_E_L_E_T_ = ' '), 0) "
	cQuery +=                 " ) SALDO "
	cQuery +=   " FROM " + RetSqlName("HWF") + " HWF "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
	cQuery +=    " AND RTRIM(SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD) = RTRIM(HWF.HWF_OP) "
	cQuery +=    " AND SC2.C2_DATRF   = ' ' "
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("HWF") + " hwfMenor "
	cQuery +=     " ON hwfMenor.HWF_FILIAL = HWF.HWF_FILIAL "
	cQuery +=    " AND hwfMenor.HWF_OP     = HWF.HWF_OP "
	cQuery +=    " AND hwfMenor.HWF_OPER   = HWF.HWF_OPER "
	cQuery +=    " AND hwfMenor.HWF_RECURS = HWF.HWF_RECURS "
	cQuery +=    " AND hwfMenor.HWF_CTRAB  = HWF.HWF_CTRAB "
	cQuery +=    " AND hwfMenor.HWF_SEQ    = (SELECT Min(hwfMenorAux.HWF_SEQ) "
	cQuery +=                                 " FROM " + RetSqlName("HWF") + " hwfMenorAux "
	cQuery +=                                " WHERE hwfMenorAux.HWF_FILIAL = hwfMenor.HWF_FILIAL "
	cQuery +=                                  " AND hwfMenorAux.HWF_OP     = hwfMenor.HWF_OP "
	cQuery +=                                  " AND hwfMenorAux.HWF_OPER   = hwfMenor.HWF_OPER "
	cQuery +=                                  " AND hwfMenorAux.HWF_RECURS = hwfMenor.HWF_RECURS "
	cQuery +=                                  " AND hwfMenorAux.HWF_CTRAB  = hwfMenor.HWF_CTRAB "
	cQuery +=                                  " AND hwfMenorAux.D_E_L_E_T_ = ' ') "
	cQuery +=    " AND hwfMenor.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("HWF") + " hwfMaior "
	cQuery +=     " ON hwfMaior.HWF_FILIAL = HWF.HWF_FILIAL "
	cQuery +=    " AND hwfMaior.HWF_OP     = HWF.HWF_OP "
	cQuery +=    " AND hwfMaior.HWF_OPER   = HWF.HWF_OPER "
	cQuery +=    " AND hwfMaior.HWF_RECURS = HWF.HWF_RECURS "
	cQuery +=    " AND hwfMaior.HWF_CTRAB  = HWF.HWF_CTRAB "
	cQuery +=    " AND hwfMaior.HWF_SEQ    = (SELECT Max(hwfMaiorAux.HWF_SEQ) "
	cQuery +=                                 " FROM " + RetSqlName("HWF") + " hwfMaiorAux "
	cQuery +=                                " WHERE hwfMaiorAux.HWF_FILIAL = hwfMaior.HWF_FILIAL "
	cQuery +=                                  " AND hwfMaiorAux.HWF_OP     = hwfMaior.HWF_OP "
	cQuery +=                                  " AND hwfMaiorAux.HWF_OPER   = hwfMaior.HWF_OPER "
	cQuery +=                                  " AND hwfMaiorAux.HWF_RECURS = hwfMaior.HWF_RECURS "
	cQuery +=                                  " AND hwfMaiorAux.HWF_CTRAB  = hwfMaior.HWF_CTRAB "
	cQuery +=                                  " AND hwfMaiorAux.D_E_L_E_T_ = ' ') "
	cQuery +=    " AND hwfMaior.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
	cQuery +=     " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cQuery +=    " AND SH1.H1_CODIGO  = HWF.HWF_RECURS "
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
	cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "' "
	cQuery +=    " AND NOT EXISTS (SELECT 1  "
	cQuery +=                      " FROM " + RetSqlName("SH6") + " SH6 "
	cQuery +=                     " WHERE SH6.H6_FILIAL  = '" + xFilial("SH6") + "' "
	cQuery +=                       " AND SH6.H6_OP      = HWF.HWF_OP "
	cQuery +=                       " AND SH6.H6_OPERAC  = HWF.HWF_OPER "
	cQuery +=                       " AND SH6.H6_PT      = 'T' "
	cQuery +=                       " AND SH6.D_E_L_E_T_ = ' ') "
	cQuery +=    " AND HWF.D_E_L_E_T_ = ' ' "

	If Self:cFilterQuery != Nil
		cQuery += Self:cFilterQuery
	EndIf

	cQuery +=  " ORDER BY HWF_OP, HWF_OPER "

	If "MSSQL" $ TcGetDb()
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

Return cQuery

/*/{Protheus.doc} getApontamentos
Retorna os apontamentos carregados na memória da classe para exibição em tela.
@author Lucas Fagundes
@since 05/12/2023
@version P12
@return ::aDados, Array, Array com os apontamentos para exibição
/*/
Method getApontamentos() Class MATA681ApontamentoCRP

	FWMsgRun(Nil, {|| ::carregaDados()}, STR0044, STR0045) // "Aguarde" "Carregando dados..."

Return aClone(::aDados)

/*/{Protheus.doc} carregaSelecionado
Carrega os dados do apontamento selecionado para o formulário.
@author Lucas Fagundes
@since 05/12/2023
@version P12
@return lOk, Logico, Indica que carregou o formulário com sucesso.
/*/
Method carregaSelecionado() Class MATA681ApontamentoCRP
	Local aCampos  := ::oStructSH6:getFields()
	Local cCampo   := ""
	Local cValor   := ""
	Local lOk      := .T.
	Local lHelp    := .T.
	Local nIndex   := 1
	Local nTotal   := Len(aCampos)
	Local oMdlGrid := ::oModel:getModel("GRID_APONTAMENTOS")

	If oMdlGrid:isEmpty()
		Return lOk
	EndIf

	::gravaBackupCampos()
	::limpaFormulario()

	While nIndex <= nTotal .And. lOk
		cCampo  := aCampos[nIndex][3]

		// Campos preenchidos de forma externa (triggers ou em outra função)
		If cCampo $ "|H6_PRODUTO|H6_TEMPO|H6_DATAINI|H6_DATAFIN|H6_HORAINI|H6_HORAFIN|"
			nIndex++
			Loop
		EndIf

		If ::oMapModel:hasProperty(cCampo)
			cValor := oMdlGrid:getValue(::oMapModel[cCampo])
		ElseIf cCampo == "H6_PT"
			cValor := "T"
		Else
			nIndex++
			Loop
		EndIf

		If cCampo == "H6_QTDPROD"
			lHelp := HelpInDark(.T.)
		EndIf

		lOk := ::setaCampo(cCampo, cValor)

		If cCampo == "H6_QTDPROD"
			HelpInDark(lHelp)

			If !lOk
				lOk := ::setaCampo(cCampo, 0)
			EndIf
		EndIf

		nIndex++
	End

	If lOk
		lOk := ::carregaDataEHora()
	EndIf

	If !lOk
		::restauraCampos()
	EndIf

Return lOk

/*/{Protheus.doc} carregaDataEHora
Realiza a carga dos campos de data e hora inicial e final.
@author Lucas Fagundes
@since 07/12/2023
@version P12
@return lSucesso, Logico, Indica se a carga passou nas validações dos campos
/*/
Method carregaDataEHora() Class MATA681ApontamentoCRP
	Local aCampos  := {"H6_DATAINI", "H6_DATAFIN", "H6_HORAINI", "H6_HORAFIN"}
	Local lSucesso := .T.
	Local nInd     := 0
	Local nTotal   := Len(aCampos)
	Local oMdlGrid := ::oModel:getModel("GRID_APONTAMENTOS")

	For nInd := 1 To nTotal
		&("M->" + aCampos[nInd]) := oMdlGrid:getValue(::oMapModel[aCampos[nInd]])
	Next

	nInd := 1
	While nInd <= nTotal .And. lSucesso
		lSucesso := ::executaValid(aCampos[nInd])

		If lSucesso
			::executaTrigger(aCampos[nInd])
		EndIf

		nInd++
	End

	aSize(aCampos, 0)
Return lSucesso

/*/{Protheus.doc} setaCampo
Seta o valor de um campo, executando as validações e executando triggers.
@author Lucas Fagundes
@since 05/12/2023
@version P12
@param 01 cCampo, Caracter, Campo que terá o valor setado.
@param 02 cValue, Caracter, Valor que será atribuido ao campo.
@return lSucesso, Logico, Indica se o valor passou com sucesso nas validações do campo.
/*/
Method setaCampo(cCampo, cValue) Class MATA681ApontamentoCRP
	Local lSucesso  := .T.

	&("M->" + cCampo) := cValue

	lSucesso := ::executaValid(cCampo)

	If lSucesso
		::executaTrigger(cCampo)
	EndIf

Return lSucesso

/*/{Protheus.doc} executaValid
Realiza as validações de um campo.
@author Lucas Fagundes
@since 07/12/2023
@version P12
@param cCampo, Caracter, Campo que irá validar.
@return lOk, Logico, Indica se passou nas validações do campo.
/*/
Method executaValid(cCampo) Class MATA681ApontamentoCRP
	Local bValid    := Nil
	Local cBkpRdVar := ReadVar()
	Local cValid    := GetSx3Cache(cCampo, "X3_VALID")
	Local lSucesso  := .T.

	__readvar := "M->" + cCampo

	If !Empty(cValid)
		bValid := &("{||" + AllTrim(cValid) + "}")

		lSucesso := Eval(bValid)
	EndIf

	__readvar := cBkpRdVar

Return lSucesso

/*/{Protheus.doc} executaTrigger
Executa a trigger do campo, se houver.
@author Lucas Fagundes
@since 07/12/2023
@version P12
@param cCampo, Caracter, Campo que irá executar as triggers.
@return Nil
/*/
Method executaTrigger(cCampo) Class MATA681ApontamentoCRP
	Local cBkpRdVar := ReadVar()

	__readvar := "M->" + cCampo

	If ExistTrigger(cCampo)
 		RunTrigger(1, Nil, Nil, , cCampo)
	EndIf

	__readvar := cBkpRdVar

Return Nil

/*/{Protheus.doc} gravaBackupCampos
Grava o conteúdo original de cada campo.
@author Lucas Fagundes
@since 06/12/2023
@version P12
@return Nil
/*/
Method gravaBackupCampos() Class MATA681ApontamentoCRP
	Local aCampos := ::oStructSH6:getFields()
	Local cCampo  := ""
	Local nInd    := 0
	Local nTotal  := Len(aCampos)

	For nInd := 1 To nTotal
		cCampo := aCampos[nInd][3]

		::oBkpCampos[cCampo] := &("M->" + cCampo)
	Next

Return Nil

/*/{Protheus.doc} restauraCampos
Restaura o conteúdo original de cada campo.
@author Lucas Fagundes
@since 06/12/2023
@version P12
@return Nil
/*/
Method restauraCampos() Class MATA681ApontamentoCRP
	Local aNames := ::oBkpCampos:getNames()
	Local cCampo := ""
	Local nIndex := 1
	Local nTotal := Len(aNames)

	For nIndex := 1 To nTotal
		cCampo := aNames[nIndex]

		&("M->" + cCampo) := ::oBkpCampos[cCampo]
	Next

	aSize(aNames, 0)
Return Nil

/*/{Protheus.doc} limpaFormulario
Limpa o formulario antes de inserir os dados para não gerar conflito da validação dos novos valores com valores existentes.
@author Lucas Fagundes
@since 06/12/2023
@version P12
@return Nil
/*/
Method limpaFormulario() Class MATA681ApontamentoCRP
	Local aCampos := ::oStructSH6:getFields()
	Local cCampo  := ""
	Local nInd    := 0
	Local nTotal  := Len(aCampos)

	For nInd := 1 To nTotal
		cCampo := aCampos[nInd][3]

		&("M->" + cCampo) := CriaVar(cCampo)
	Next

Return Nil

/*/{Protheus.doc} condApont
Retorna a condição de busca dos apontamentos na HWF a partir da SH6
@type  Static Function
@author Lucas Fagundes
@since 11/12/2023
@version P12
@param lFiltData, Logico, Indica se deve ou não filtrar a data quando for um apontamento parcial.
@return cWhere, Caracter, Condição SQL para buscar os apontamentos na HWF.
/*/
Static Function condApont(lFiltData)
	Local cWhere := ""

	cWhere := "  WHERE HWF_FILIAL  = '" + xFilial("HWF") + "' "
	cWhere += "    AND HWF_OP      = '" + SH6->H6_OP      + "' "
	cWhere += "    AND HWF_OPER    = '" + SH6->H6_OPERAC  + "' "
	cWhere += "    AND HWF_RECURS  = '" + SH6->H6_RECURSO + "' "
	cWhere += "    AND D_E_L_E_T_  = ' ' "

	If SH6->H6_PT != "T" .And. lFiltData
		cWhere += " AND HWF_DATA BETWEEN '" + DToS(SH6->H6_DATAINI) + "' AND '" + DToS(SH6->H6_DATAFIN) + "' "
		cWhere += " AND ((HWF_DATA = '" + DToS(SH6->H6_DATAINI) + "' AND HWF_HRINI >= '" + SH6->H6_HORAINI + "') OR HWF_DATA > '" + DToS(SH6->H6_DATAINI) + "') "
		cWhere += " AND ((HWF_DATA = '" + DToS(SH6->H6_DATAFIN) + "' AND HWF_HRFIM <= '" + SH6->H6_HORAFIN + "') OR HWF_DATA < '" + DToS(SH6->H6_DATAFIN) + "') "
	EndIf

Return cWhere

/*/{Protheus.doc} condFerram
Retorna a condição de busca das efetivações na HZL a partir da SH6.
@type  Static Function
@author Lucas Fagundes
@since 30/04/2025
@version P12
@param lFiltData, Logico, Indica se deve ou não filtrar a data quando for um apontamento parcial.
@return cWhere, Caracter, Condição SQL para buscar as efetivações na HZL.
/*/
Static Function condFerram(lFiltData)
	Local cWhere := ""

	cWhere := "  WHERE HZL_FILIAL  = '" + xFilial("HZL") + "' "
	cWhere += "    AND HZL_OP      = '" + SH6->H6_OP      + "' "
	cWhere += "    AND HZL_OPER    = '" + SH6->H6_OPERAC  + "' "
	cWhere += "    AND HZL_RECURS  = '" + SH6->H6_RECURSO + "' "
	cWhere += "    AND D_E_L_E_T_  = ' ' "

	If SH6->H6_PT != "T" .And. lFiltData
		cWhere += " AND HZL_DATA BETWEEN '" + DToS(SH6->H6_DATAINI) + "' AND '" + DToS(SH6->H6_DATAFIN) + "' "
		cWhere += " AND ((HZL_DATA = '" + DToS(SH6->H6_DATAINI) + "' AND HZL_INICIO >= '" + SH6->H6_HORAINI + "') OR HZL_DATA > '" + DToS(SH6->H6_DATAINI) + "') "
		cWhere += " AND ((HZL_DATA = '" + DToS(SH6->H6_DATAFIN) + "' AND HZL_FIM    <= '" + SH6->H6_HORAFIN + "') OR HZL_DATA < '" + DToS(SH6->H6_DATAFIN) + "') "
	EndIf

Return cWhere

/*/{Protheus.doc} inativaHWF
Inativa os apontamentos da HWF com base no apontamento posicionado na SH6.
@author Lucas Fagundes
@since 06/12/2023
@version P12
@return Nil
/*/
Method inativaHWF() Class MATA681ApontamentoCRP
	Local cWhere := ""

	cWhere := condApont(.T.)
	cWhere += " AND HWF_STATUS != '" + STATUS_INATIVO + "' "

	attStatHWF(STATUS_INATIVO, cWhere)

	MATA681ApontamentoCRP():inativaHZL()

Return Nil

/*/{Protheus.doc} inativaHZL
Inativa as efetivações das ferramentas com base no apontamento posicionado na SH6.
@author Lucas Fagundes
@since 30/04/2025
@version P12
@return Nil
/*/
Method inativaHZL() Class MATA681ApontamentoCRP
	Local cWhere := ""

	If hasDicFerr()
		cWhere := condFerram(.T.)
		cWhere += " AND HZL_STATUS != '" + STATUS_INATIVO + "' "

		attStatHZL(STATUS_INATIVO, cWhere)
	EndIf

Return Nil

/*/{Protheus.doc} ativaHWF
Ativa os apontamentos da HWF com base no apontamento posicionado na SH6.
@author Lucas Fagundes
@since 07/12/2023
@version P12
@return Nil
/*/
Method ativaHWF() Class MATA681ApontamentoCRP
	Local cWhere := ""

	cWhere := condApont(.F.)
	cWhere += " AND HWF_STATUS != '" + STATUS_ATIVO + "' "
	cWhere += " AND NOT EXISTS(SELECT 1 "
	cWhere += "                  FROM " + RetSQLName("SH6") + " SH6 "
	cWhere += "                 WHERE SH6.H6_FILIAL = '" + xFilial("SH6") + "' "
	cWhere += "                   AND SH6.H6_OP     = HWF_OP "
	cWhere += "                   AND SH6.H6_OPERAC = HWF_OPER "
	cWhere += "                   AND HWF_DATA BETWEEN SH6.H6_DATAINI AND SH6.H6_DATAFIN "
	cWhere += "                   AND ((HWF_DATA = SH6.H6_DATAINI AND HWF_HRINI >= SH6.H6_HORAINI) OR HWF_DATA > SH6.H6_DATAINI) "
	cWhere += "                   AND ((HWF_DATA = SH6.H6_DATAFIN AND HWF_HRFIM <= SH6.H6_HORAFIN) OR HWF_DATA < SH6.H6_DATAFIN) "
	cWhere += "                   AND SH6.D_E_L_E_T_ = ' ') "
	cWhere += " AND EXISTS(SELECT 1 "
	cWhere += "              FROM " + RetSqlName("SC2") + " SC2 "
	cWhere += "             WHERE SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
	cWhere += "               AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = HWF_OP "
	cWhere += "               AND SC2.C2_DATRF   = ' ' "
	cWhere += "               AND SC2.D_E_L_E_T_ = ' ') "

	attStatHWF(STATUS_ATIVO, cWhere)

	MATA681ApontamentoCRP():ativaHZL()

Return Nil

/*/{Protheus.doc} ativaHZL
Ativa as efetivações da HZL com base no apontamento posicionado na SH6.
@author Lucas Fagundes
@since 30/04/2025
@version P12
@return Nil
/*/
Method ativaHZL() Class MATA681ApontamentoCRP
	Local cWhere := ""

	If hasDicFerr()
		cWhere := condFerram(.F.)
		cWhere += " AND HZL_STATUS != '" + STATUS_ATIVO + "' "
		cWhere += " AND NOT EXISTS(SELECT 1 "
		cWhere += "                  FROM " + RetSQLName("SH6") + " SH6 "
		cWhere += "                 WHERE SH6.H6_FILIAL = '" + xFilial("SH6") + "' "
		cWhere += "                   AND SH6.H6_OP     = HZL_OP "
		cWhere += "                   AND SH6.H6_OPERAC = HZL_OPER "
		cWhere += "                   AND HZL_DATA BETWEEN SH6.H6_DATAINI AND SH6.H6_DATAFIN "
		cWhere += "                   AND ((HZL_DATA = SH6.H6_DATAINI AND HZL_INICIO >= SH6.H6_HORAINI) OR HZL_DATA > SH6.H6_DATAINI) "
		cWhere += "                   AND ((HZL_DATA = SH6.H6_DATAFIN AND HZL_FIM    <= SH6.H6_HORAFIN) OR HZL_DATA < SH6.H6_DATAFIN) "
		cWhere += "                   AND SH6.D_E_L_E_T_ = ' ') "
		cWhere += " AND EXISTS(SELECT 1 "
		cWhere += "              FROM " + RetSqlName("SC2") + " SC2 "
		cWhere += "             WHERE SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
		cWhere += "               AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = HZL_OP "
		cWhere += "               AND SC2.C2_DATRF   = ' ' "
		cWhere += "               AND SC2.D_E_L_E_T_ = ' ') "

		attStatHZL(STATUS_ATIVO, cWhere)
	EndIf

Return Nil

/*/{Protheus.doc} encerraOrdemDeProducao
Atualiza na tabela HWF os apontamentos da ordem que está sendo encerrada.
@author Lucas Fagundes
@since 07/12/2023
@version P12
@param cOrdem, Caracter, Código da ordem que está sendo encerrada
@return Nil
/*/
Method encerraOrdemDeProducao(cOrdem) Class MATA681ApontamentoCRP
	Local cWhere := ""

	cWhere := "  WHERE HWF_FILIAL  = '" + xFilial("HWF") + "' "
	cWhere += "    AND HWF_OP      = '" + cOrdem + "' "
	cWhere += "    AND HWF_STATUS != '" + STATUS_INATIVO + "' "
	cWhere += "    AND D_E_L_E_T_  = ' ' "

	attStatHWF(STATUS_INATIVO, cWhere)

	If hasDicFerr()
		cWhere := "  WHERE HZL_FILIAL  = '" + xFilial("HZL") + "' "
		cWhere += "    AND HZL_OP      = '" + cOrdem + "' "
		cWhere += "    AND HZL_STATUS != '" + STATUS_INATIVO + "' "
		cWhere += "    AND D_E_L_E_T_  = ' ' "

		attStatHZL(STATUS_INATIVO, cWhere)
	EndIf

Return Nil

/*/{Protheus.doc} attStatHWF
Atualiza o status dos apontamentos na tabela HWF.
@type  Static Function
@author Lucas Fagundes
@since 07/12/2023
@version P12
@param 01 cStatus, Caracter, Status que irá gravar na HWF. "1" - Ativo; "2" - Inativo
@param 02 cCondic, Caracter, Condição WHERE SQL para atualização dos registros.
@return Nil
/*/
Static Function attStatHWF(cStatus, cCondic)
	Local cQuery := ""

	cQuery := " UPDATE " + RetSQLName("HWF") + " SET HWF_STATUS = '" + cStatus + "' " + cCondic

	If "MSSQL" $ TcGetDb()
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	If TCSQLExec(cQuery) < 0
		Final(STR0043, TCSQLError()) // "Ocorreu um erro ao atualizar a tabela HWF."
	EndIf

Return Nil

/*/{Protheus.doc} attStatHZL
Atualiza o status das efetivações na tabela HZL.
@type  Static Function
@author Lucas Fagundes
@since 30/04/2025
@version P12
@param 01 cStatus, Caracter, Status que irá gravar na HZL. "1" - Ativo; "2" - Inativo
@param 02 cCondic, Caracter, Condição WHERE SQL para atualização dos registros.
@return Nil
/*/
Static Function attStatHZL(cStatus, cCondic)
	Local cQuery := ""

	cQuery := " UPDATE " + RetSQLName("HZL") + " SET HZL_STATUS = '" + cStatus + "' " + cCondic

	If "MSSQL" $ TcGetDb()
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	If TCSQLExec(cQuery) < 0
		Final(STR0050, TCSQLError()) // "Ocorreu um erro ao atualizar a tabela HZL."
	EndIf

Return Nil

/*/{Protheus.doc} opOperacaoProgramadas
Verifica se a OP e a Operação foram programadas pelo CRP (PCPA152)
@type Static Method
@author Marcelo Neumann
@since 29/01/2024
@version P12
@param 01 cOp    , Caracter, Número da OP
@param 02 cOperac, Caracter, Código da Operação
@return Lógico, Indica se a OP foi programada pelo CRP (existe na tabela HWF)
/*/
Method opOperacaoProgramadas(cOp, cOperac) Class MATA681ApontamentoCRP
	Local cChave := ""

	If Empty(cOp) .Or. Empty(cOperac)
		Return .F.
	EndIf

	cChave := cOp + cOperac

	If _oOPsProgr == Nil
		_oOPsProgr := JsonObject():New()
	EndIf

	If !_oOPsProgr:hasProperty(cChave)
		HWF->(dbSetOrder(1))
		_oOPsProgr[cChave] := JsonObject():New()
		_oOPsProgr[cChave]["existeHWF"     ] := HWF->(dbSeek(xFilial("HWF") + cChave))
		_oOPsProgr[cChave]["programacao"   ] := HWF->HWF_PROG
		_oOPsProgr[cChave]["centroTrabalho"] := HWF->HWF_CTRAB
		_oOPsProgr[cChave]["recurso"       ] := HWF->HWF_RECURS
	EndIf

Return _oOPsProgr[cChave]["existeHWF"]

/*/{Protheus.doc} buscaTempoProgramado
Busca o tempo conforme a programação do CRP
@type Static Method
@author Marcelo Neumann
@since 29/01/2024
@version P12
@param 01 cOp       , Caracter, Número da OP
@param 02 cOperac   , Caracter, Código da Operação
@param 03 cRecurso  , Caracter, Código do Recurso
@param 04 dIniApont , Data    , Data inicial do apontamento
@param 05 cIniAponHr, Caracter, Hora inicial do apontamento
@param 06 dFimApont , Data    , Data final do apontamento
@param 07 cFimAponHr, Caracter, Hora final do apontamento
@param 08 lUsaCalend, Lógico  , Valor do parâmetro MV_USACALE (usa calendário padrão)
@return   nTempo    , Numérico, Tempo centesimal conforme o programado pelo CRP no período informado
/*/
Method buscaTempoProgramado(cOp, cOperac, cRecurso, dIniApont, cIniAponHr, dFimApont, cFimAponHr, lUsaCalend) Class MATA681ApontamentoCRP
	Local aTempos    := {}
	Local cAlias     := GetNextAlias()
	Local cCenTrab   := ""
	Local cChave     := ""
	Local cFim       := ""
	Local cHoraAux   := ""
	Local cInicio    := ""
	Local cPriHorCRP := ""
	Local cProgramac := ""
	Local cUltHorCRP := ""
	Local cTipoRec   := MR_TIPO_RECURSO
	Local dDataAux   := Nil
	Local dDataFor   := Nil
	Local dPriDatCRP := Nil
	Local dUltDatCRP := Nil
	Local lContinua  := .T.
	Local lTemHWF    := .F.
	Local lTemSMK    := .F.
	Local lRecProg   := .T.
	Local nIndex     := 1
	Local nTempo     := 0
	Local nTempoHWK  := 0

	aSize(_aDadosHWK, 0)

	If Empty(cOp)        .Or. Empty(cOperac)   .Or. Empty(dIniApont) .Or. ;
	   Empty(cIniAponHr) .Or. Empty(dFimApont) .Or. Empty(cFimAponHr)
		Return nTempo
	EndIf

	cChave     := cOp + cOperac
	cProgramac := _oOPsProgr[cChave]["programacao"   ]
	cCenTrab   := _oOPsProgr[cChave]["centroTrabalho"]

	If cIniAponHr == "24:00"
		dIniApont++
		cIniAponHr := "00:00
	EndIf

	If cFimAponHr == "00:00"
		dFimApont--
		cFimAponHr := "24:00
	EndIf

	If usaDisCRP()
		//Verifica se foi informado o mesmo recurso programado para a OP e Operação
		If cRecurso == _oOPsProgr[cChave]["recurso"]
			//Busca as horas na tabela de Efetivação do CRP
			BeginSql Alias cAlias
			COLUMN HWF_DATA AS DATE
			SELECT HWF_DATA, HWF_HRINI, HWF_HRFIM
			  FROM %table:HWF%
			 WHERE HWF_FILIAL = %xFilial:HWF%
			   AND HWF_PROG   = %Exp:cProgramac%
			   AND HWF_OP     = %Exp:cOp%
			   AND HWF_OPER   = %Exp:cOperac%
			   AND HWF_DATA   >= %Exp:dIniApont%
			   AND HWF_DATA   <= %Exp:dFimApont%
			   AND %NotDel%
			 ORDER BY HWF_DATA, HWF_HRINI
			EndSql
			While (cAlias)->(!EoF())
				cInicio := (cAlias)->HWF_HRINI
				cFim    := (cAlias)->HWF_HRFIM

				If (cAlias)->HWF_DATA == dIniApont
					If (cAlias)->HWF_HRFIM <= cIniAponHr
						(cAlias)->(dbSkip())
						Loop
					EndIf

					If (cAlias)->HWF_HRINI < cIniAponHr
						cInicio := cIniAponHr
					EndIf
				EndIf

				If (cAlias)->HWF_DATA == dFimApont
					If (cAlias)->HWF_HRINI >= cFimAponHr
						(cAlias)->(dbSkip())
						Loop
					EndIf

					If (cAlias)->HWF_HRFIM > cFimAponHr
						cFim := cFimAponHr
					EndIf
				EndIf

				If cInicio < cFim
					nTempoHWK := __Hrs2Min(cFim) - __Hrs2Min(cInicio)
					nTempo    += nTempoHWK

					addRegHWK(cRecurso          ,;
					          cCenTrab          ,;
					          (cAlias)->HWF_DATA,;
					          cInicio           ,;
					          cFim              ,;
					          nTempoHWK         ,;
					          HWK_ORIGEM_HWF)
				EndIf

				If !lTemHWF
					dPriDatCRP := (cAlias)->HWF_DATA
					cPriHorCRP := (cAlias)->HWF_HRINI
					lTemHWF    := .T.
				EndIf

				dUltDatCRP := (cAlias)->HWF_DATA
				cUltHorCRP := (cAlias)->HWF_HRFIM

				(cAlias)->(dbSkip())
			End
			(cAlias)->(dbCloseArea())
		Else
			//Se for um recurso diferente do programado, busca o CT e verifica se o recurso participou da programação
			If !_oOPsProgr[cChave]:hasProperty(cRecurso + "_CT")
				//Verifica se o recurso estava na programação
				SMT->(dbSetOrder(1))
				_oOPsProgr[cChave][cRecurso + "_SMT"] := SMT->(dbSeek(xFilial("SMT") + cProgramac + cRecurso))

				//Busca o Centro de Trabalho do Recurso
				_oOPsProgr[cChave][cRecurso + "_CT"] := ""
				SH1->(dbSetOrder(1))
				If SH1->(dbSeek(xFilial("SH1") + cRecurso))
					_oOPsProgr[cChave][cRecurso + "_CT"] := SH1->H1_CTRAB
				EndIf
			EndIf

			cCenTrab := _oOPsProgr[cChave][cRecurso + "_CT" ]
			lRecProg := _oOPsProgr[cChave][cRecurso + "_SMT"]
		EndIf

		If lTemHWF                                                .And. ;
		   dPriDatCRP == dIniApont .And. cPriHorCRP <= cIniAponHr .And. ;
		   dUltDatCRP == dFimApont .And. cUltHorCRP >= cFimAponHr
			lContinua := .F.
		EndIf

		//Se o recurso informado foi utilizado na programação, busca as horas pela tabela de Disponibilidade do CRP
		If lContinua .And. lRecProg
			dDataAux := dFimApont
			cHoraAux := cFimAponHr

			//Se o Apontamento inicia antes da programação
			If lTemHWF .And. (dPriDatCRP > dIniApont .Or. (dPriDatCRP == dIniApont .And. cIniAponHr < cPriHorCRP))
				dDataAux := dPriDatCRP
				cHoraAux := cPriHorCRP
			EndIf

			If !lTemHWF .Or. (lTemHWF .And. (dPriDatCRP > dIniApont .Or. (dPriDatCRP == dIniApont .And. cIniAponHr < cPriHorCRP)))
				BeginSql Alias cAlias
				COLUMN MR_DATDISP AS DATE
				SELECT SMR.MR_DATDISP, SMK.MK_HRINI, SMK.MK_HRFIM
				  FROM %table:SMR% SMR
				 INNER JOIN %table:SMK% SMK
				    ON SMK.MK_FILIAL   = %xFilial:SMK%
				   AND SMK.MK_PROG     = SMR.MR_PROG
				   AND SMK.MK_DISP     = SMR.MR_DISP
				   AND SMK.MK_BLOQUE   = '2'
				   AND SMK.MK_TIPO   IN ('1','3')
				   AND SMK.%NotDel%
				 WHERE SMR.MR_FILIAL   = %xFilial:SMR%
				   AND SMR.MR_PROG     = %Exp:cProgramac%
				   AND SMR.MR_TIPO     = %Exp:cTipoRec%
				   AND SMR.MR_DATDISP >= %Exp:dIniApont%
				   AND SMR.MR_DATDISP <= %Exp:dDataAux%
				   AND SMR.MR_RECURSO  = %Exp:cRecurso%
				   AND SMR.%NotDel%
				 ORDER BY SMR.MR_DATDISP, SMK.MK_HRINI
				EndSql
				While (cAlias)->(!EoF())
					cInicio := (cAlias)->MK_HRINI
					cFim    := (cAlias)->MK_HRFIM

					If (cAlias)->MR_DATDISP == dIniApont
						If (cAlias)->MK_HRFIM <= cIniAponHr
							(cAlias)->(dbSkip())
							Loop
						EndIf

						If (cAlias)->MK_HRINI < cIniAponHr
							cInicio := cIniAponHr
						EndIf
					EndIf

					If (cAlias)->MR_DATDISP == dDataAux
						If (cAlias)->MK_HRINI >= cHoraAux
							Exit
						EndIf

						If (cAlias)->MK_HRFIM > cHoraAux
							cFim := cHoraAux
						EndIf
					EndIf

					If cInicio < cFim
						nTempoHWK := __Hrs2Min(cFim) - __Hrs2Min(cInicio)
						nTempo    += nTempoHWK

						addRegHWK(cRecurso            ,;
						          cCenTrab            ,;
						          (cAlias)->MR_DATDISP,;
						          cInicio             ,;
						          cFim                ,;
						          nTempoHWK           ,;
						          HWK_ORIGEM_SMK)
					EndIf

					If !lTemSMK
						dPriDatCRP := (cAlias)->MR_DATDISP
						cPriHorCRP := (cAlias)->MK_HRINI
						lTemSMK    := .T.
					EndIf

					If !lTemHWF
						dUltDatCRP := (cAlias)->MR_DATDISP
						cUltHorCRP := (cAlias)->MK_HRFIM
					EndIf

					(cAlias)->(dbSkip())
				End
				(cAlias)->(dbCloseArea())
			EndIf

			//Verificação quebrada: do fim da HWF até o fim do apontamento
			If lTemHWF .And. dUltDatCRP < dFimApont .Or. (dUltDatCRP == dFimApont .And. cFimAponHr > cUltHorCRP)
				dDataAux := dUltDatCRP
				cHoraAux := cUltHorCRP

				BeginSql Alias cAlias
				COLUMN MR_DATDISP AS DATE
				SELECT SMR.MR_DATDISP, SMK.MK_HRINI, SMK.MK_HRFIM
				  FROM %table:SMR% SMR
				 INNER JOIN %table:SMK% SMK
				    ON SMK.MK_FILIAL   = %xFilial:SMK%
				   AND SMK.MK_PROG     = SMR.MR_PROG
				   AND SMK.MK_DISP     = SMR.MR_DISP
				   AND SMK.MK_BLOQUE   = '2'
				   AND SMK.MK_TIPO   IN ('1','3')
				   AND SMK.%NotDel%
				 WHERE SMR.MR_FILIAL   = %xFilial:SMR%
				   AND SMR.MR_PROG     = %Exp:cProgramac%
				   AND SMR.MR_TIPO     = %Exp:cTipoRec%
				   AND SMR.MR_DATDISP >= %Exp:dDataAux%
				   AND SMR.MR_DATDISP <= %Exp:dFimApont%
				   AND SMR.MR_RECURSO  = %Exp:cRecurso%
				   AND SMR.%NotDel%
				 ORDER BY SMR.MR_DATDISP, SMK.MK_HRINI
				EndSql
				While (cAlias)->(!EoF())
					cInicio := (cAlias)->MK_HRINI
					cFim    := (cAlias)->MK_HRFIM

					If (cAlias)->MR_DATDISP == dDataAux
						If (cAlias)->MK_HRFIM <= cHoraAux
							(cAlias)->(dbSkip())
							Loop
						EndIf

						If (cAlias)->MK_HRINI < cHoraAux
							cInicio := cHoraAux
						EndIf
					EndIf

					If (cAlias)->MR_DATDISP == dFimApont
						If (cAlias)->MK_HRINI >= cFimAponHr
							(cAlias)->(dbSkip())
							Exit
						EndIf

						If (cAlias)->MK_HRFIM > cFimAponHr
							cFim := cFimAponHr
						EndIf
					EndIf

					If cInicio < cFim
						nTempoHWK := __Hrs2Min(cFim) - __Hrs2Min(cInicio)
						nTempo    += nTempoHWK

						addRegHWK(cRecurso            ,;
						          cCenTrab            ,;
						          (cAlias)->MR_DATDISP,;
						          cInicio             ,;
						          cFim                ,;
						          nTempoHWK           ,;
						          HWK_ORIGEM_SMK)
					EndIf

					dUltDatCRP := (cAlias)->MR_DATDISP
					cUltHorCRP := (cAlias)->MK_HRFIM

					(cAlias)->(dbSkip())
				End
				(cAlias)->(dbCloseArea())
			EndIf

			If dPriDatCRP <> Nil .And. dPriDatCRP == dIniApont .And. cPriHorCRP <= cIniAponHr .And. ;
			   dUltDatCRP <> Nil .And. dUltDatCRP == dFimApont .And. cUltHorCRP >= cFimAponHr
				lContinua := .F.
			EndIf
		EndIf
	EndIf

	nTempo := nTempo / 60

	//Busca as horas pelo calendário padrão
	If lContinua
		//Busca o range de datas da programação
		If usaDisCRP() .And. lRecProg .And. buscaDtPrg(cChave)
			dPriDatCRP := _oOPsProgr[cChave]["dataInicial"]
			cPriHorCRP := "00:00"
			dUltDatCRP := _oOPsProgr[cChave]["dataFinal"  ]
			cUltHorCRP := "24:00"
			lTemSMK    := .T.
		EndIf

		dDataAux := dFimApont
		cHoraAux := cFimAponHr

		//Se o Apontamento inicia antes da programação
		If !lRecProg .Or. !lTemSMK .Or. (dPriDatCRP > dIniApont .Or. (dPriDatCRP == dIniApont .And. cIniAponHr < cPriHorCRP))
			If usaDisCRP() .And. (lTemHWF .Or. lTemSMK) .And. (dFimApont > dPriDatCRP .Or. (dFimApont == dPriDatCRP .And. cFimAponHr > cPriHorCRP))
				dDataAux := dPriDatCRP
				cHoraAux := cPriHorCRP
			EndIf

			cInicio := cIniAponHr
			cFim    := cHoraAux

			If lUsaCalend
				nTempo += A680calen(dIniApont, dDataAux, cRecurso, cInicio, cFim, @aTempos)

				For nIndex := 1 To Len(aTempos)
					addRegHWK(cRecurso             ,;
					          cCenTrab             ,;
					          aTempos[nIndex][1]   ,;
					          aTempos[nIndex][2]   ,;
					          aTempos[nIndex][3]   ,;
					          aTempos[nIndex][4]   ,;
					          HWK_ORIGEM_CALENDARIO)
				Next nIndex

				aSize(aTempos, 0)
			Else
				For dDataFor := dIniApont To dDataAux
					cFim := IIf(dDataFor == dDataAux, cHoraAux, "24:00")

					If cInicio < cFim
						nTempoHWK := A680Tempo(dDataFor, cInicio, dDataFor, cFim)
						nTempo    += nTempoHWK
						nTempoHWK := nTempoHWK * 60

						addRegHWK(cRecurso             ,;
						          cCenTrab             ,;
						          dDataFor             ,;
						          cInicio              ,;
						          cFim                 ,;
						          nTempoHWK            ,;
						          HWK_ORIGEM_CALENDARIO)
					EndIf

					cInicio := "00:00"
				Next dDataFor
			EndIf
		EndIf

		//Busca as horas pelo calendário padrão (da última data da programação até a data final do apontamento)
		If (lTemHWF .Or. lTemSMK) .And. (dUltDatCRP < dFimApont .Or. (dUltDatCRP == dFimApont .And. cFimAponHr > cUltHorCRP))
			dDataAux := dUltDatCRP
			cHoraAux := cUltHorCRP

			If dIniApont > dUltDatCRP .Or. (dIniApont == dUltDatCRP .And. cIniAponHr > cUltHorCRP)
				dDataAux := dIniApont
				cHoraAux := cIniAponHr
			EndIf

			cInicio  := cHoraAux
			cFim     := cFimAponHr

			If lUsaCalend
				nTempo += A680calen(dDataAux, dFimApont, cRecurso, cInicio, cFim, @aTempos)

				For nIndex := 1 To Len(aTempos)
					addRegHWK(cRecurso             ,;
					          cCenTrab             ,;
					          aTempos[nIndex][1]   ,;
					          aTempos[nIndex][2]   ,;
					          aTempos[nIndex][3]   ,;
					          aTempos[nIndex][4]   ,;
					          HWK_ORIGEM_CALENDARIO)
				Next nIndex

				aSize(aTempos, 0)
			Else
				For dDataFor := dDataAux To dFimApont
					cFim := IIf(dDataFor == dFimApont, cFimAponHr, "24:00")

					If cInicio < cFim
						nTempoHWK := A680Tempo(dDataFor, cInicio, dDataFor, cFim)
						nTempo    += nTempoHWK
						nTempoHWK := nTempoHWK * 60

						addRegHWK(cRecurso             ,;
						          cCenTrab             ,;
						          dDataFor             ,;
						          cInicio              ,;
						          cFim                 ,;
						          nTempoHWK            ,;
						          HWK_ORIGEM_CALENDARIO)
					EndIf

					cInicio := "00:00"
				Next dDataFor
			EndIf
		EndIf
	EndIf

Return nTempo

/*/{Protheus.doc} gravaApontamentosCRP
Grava a tabela de apontamento CRP (HWK) com os dados do _aDadosHWK
@type Static Method
@author Marcelo Neumann
@since 29/01/2024
@version P12
@param 01 cOp      , Caracter, Número da OP
@param 02 cOperacao, Caracter, Código da Operação
@param 03 cIdent   , Caracter, Identificador do apontamento (H6_IDENT)
@return   lSucesso , Lógico  , Indica se gravou com sucesso a tabela HWK
/*/
Method gravaApontamentosCRP(cOp, cOperacao, cIdent) Class MATA681ApontamentoCRP
	Local aRegistro := {}
	Local cData     := ""
	Local cErroDet  := ""
	Local cFilHWK   := xFilial("HWK")
	Local lSucesso  := .T.
	Local nIndex    := 1
	Local nTotal    := 1
	Local oBulk     := Nil
	Local oProxSeq  := Nil

	If Empty(_aDadosHWK)
		Return lSucesso
	EndIf

	oProxSeq := JsonObject():New()

	oBulk := FwBulk():New(RetSqlName("HWK"))
	oBulk:SetFields(tabFields())

	nTotal := Len(_aDadosHWK)
	While lSucesso .And. nIndex <= nTotal
		cData := DToS(_aDadosHWK[nIndex][ADADOS_HWK_POS_DATA])

		If oProxSeq:hasProperty(cData)
			oProxSeq[cData]++
		Else
			oProxSeq[cData] := 1
		EndIf

		aRegistro := { cFilHWK                                   , ; //HWK_FILIAL
		               cOp                                       , ; //HWK_OP
		               cOperacao                                 , ; //HWK_OPERAC
		               _aDadosHWK[nIndex][ADADOS_HWK_POS_RECURSO], ; //HWK_RECURS
		               _aDadosHWK[nIndex][ADADOS_HWK_POS_CTRAB  ], ; //HWK_CTRAB
		               _aDadosHWK[nIndex][ADADOS_HWK_POS_DATA   ], ; //HWK_DATA
		               oProxSeq[cData]                           , ; //HWK_SEQ
		               _aDadosHWK[nIndex][ADADOS_HWK_POS_HRINI  ], ; //HWK_HRINI
		               _aDadosHWK[nIndex][ADADOS_HWK_POS_HRFIM  ], ; //HWK_HRFIM
		               _aDadosHWK[nIndex][ADADOS_HWK_POS_TEMPOT ], ; //HWK_TEMPOT
		               _aDadosHWK[nIndex][ADADOS_HWK_POS_ORIGEM ], ; //HWK_ORIGEM
		               cIdent }                                      //HWK_IDENT

		lSucesso := oBulk:addData(aRegistro)

		aSize(_aDadosHWK[nIndex], 0)
		aSize(aRegistro, 0)

		nIndex++
	End

	aSize(_aDadosHWK, 0)

	If lSucesso
		lSucesso := oBulk:close()
	EndIf

	If !lSucesso
		cErroDet := oBulk:getError()
		Help( , , "Help", , STR0046, 1, 0, , , , , , {cErroDet}) //"Ocorreu um erro ao gravar a tabela de Apontamento do CRP (HWK)."
	EndIf

	oBulk:destroy()

	FreeObj(oProxSeq)

Return lSucesso

/*/{Protheus.doc} tabFields
Carrega a estrutura da tabela HWK
O array de retorno deve sempre seguir a ordem das colunas definidas nas constantes utilizadas para a tabela

@author Marcelo Neumann
@since 21/11/2023
@version P12
@return aEstrut, Array, Array com os campos da estrutura da tabela HWK
/*/
Static Function tabFields()
	Local aEstrut := {}

	aAdd(aEstrut, {"HWK_FILIAL"})
	aAdd(aEstrut, {"HWK_OP"    })
	aAdd(aEstrut, {"HWK_OPERAC"})
	aAdd(aEstrut, {"HWK_RECURS"})
	aAdd(aEstrut, {"HWK_CTRAB" })
	aAdd(aEstrut, {"HWK_DATA"  })
	aAdd(aEstrut, {"HWK_SEQ"   })
	aAdd(aEstrut, {"HWK_HRINI" })
	aAdd(aEstrut, {"HWK_HRFIM" })
	aAdd(aEstrut, {"HWK_TEMPOT"})
	aAdd(aEstrut, {"HWK_ORIGEM"})
	aAdd(aEstrut, {"HWK_IDENT" })

Return aEstrut

/*/{Protheus.doc} buscaDtPrg
Busca as datas da programação na tabela T4Y

@author Marcelo Neumann
@since 01/02/2024
@version P12
@param cChave, Caracter, Chave do Objeto _oOPsProgr (Op + Operação)
@return Lógico, Indica se encontrou as datas na T4Y
/*/
Static Function buscaDtPrg(cChave)
	Local cAlias := GetNextAlias()
	Local cProg  := ""

	If !_oOPsProgr[cChave]:hasProperty("dataInicial")
		cProg := _oOPsProgr[cChave]["programacao"]

		BeginSql Alias cAlias
		  SELECT T4Y_PARAM, T4Y_VALOR
		    FROM %table:T4Y%
		   WHERE T4Y_FILIAL = %xFilial:T4Y%
		     AND T4Y_PROG   = %Exp:cProg%
		     AND T4Y_PARAM IN ('dataInicial', 'dataFinal', 'dataRealFim')
		     AND %NotDel%
		   ORDER BY T4Y_PARAM
		EndSql
		While (cAlias)->(!EoF())
			Do Case
				Case RTrim((cAlias)->T4Y_PARAM) == "dataInicial"
					_oOPsProgr[cChave]["dataInicial"] := PCPConvDat((cAlias)->T4Y_VALOR, 1)

				Case RTrim((cAlias)->T4Y_PARAM) == "dataFinal"
					_oOPsProgr[cChave]["dataFinal"]   := PCPConvDat((cAlias)->T4Y_VALOR, 1)

				Case RTrim((cAlias)->T4Y_PARAM) == "dataRealFim"
					_oOPsProgr[cChave]["dataFinal"]   := Max(_oOPsProgr[cChave]["dataFinal"], PCPConvDat((cAlias)->T4Y_VALOR, 1))
			EndCase

			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())
	EndIf

Return !Empty(_oOPsProgr[cChave]["dataInicial"])

/*/{Protheus.doc} estornoApontamento
Deleta o apontamento da tabela de apontamento CRP (HWK)
@type Static Method
@author Marcelo Neumann
@since 29/01/2024
@version P12
@param 01 cOp      , Caracter, Número da OP
@param 02 cOperacao, Caracter, Código da Operação
@param 03 cIdent   , Caracter, Identificador do apontamento (H6_IDENT)
@return   lSucesso , Lógico  , Indica se deletou com sucesso o apontamento da tabela HWK
/*/
Method estornoApontamento(cOp, cOperacao, cIdent) Class MATA681ApontamentoCRP
	Local cQuery   := ""
	Local lSucesso := .T.

	cQuery := "DELETE FROM " + RetSqlName("HWK")
	cQuery += " WHERE HWK_FILIAL = '" + xFilial("HWK") + "'"
	cQuery +=   " AND HWK_OP     = '" + cOp            + "'"
	cQuery +=   " AND HWK_OPERAC = '" + cOperacao      + "'"
	cQuery +=   " AND HWK_IDENT  = '" + cIdent         + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"

	If TCSQLExec(cQuery) < 0
		lSucesso := .F.
		Help( , , "Help", , STR0047, 1, 0, , , , , , {TCSQLError()}) //"Ocorreu um erro ao remover o apontamento da tabela de Apontamento do CRP (HWK)."
	EndIf

Return lSucesso

/*/{Protheus.doc} usaDisCRP()
Verifica se deve utilizar a disponibilidade do CRP
para realizar o cálculo das horas reais do apontamento

@type Static Function
@author lucas.franca
@since 09/04/2024
@version P12
@return lUtiliza, Logic, Utiliza disponibilidade do CRP no cálculo das horas
/*/
Static Function usaDisCRP() AS Logical
	Local lUtiliza AS Logical

	If _lApoCRP == Nil
		_lApoCRP := SuperGetMV("MV_APOCRP", .F., "1") == "2"
	EndIf

	lUtiliza := _lApoCRP

Return lUtiliza

/*/{Protheus.doc} addRegHWK
Adiciona um registro de apontamento a ser inserido na tabela de apontamento CRP (HWK)
@type Static Function
@author Marcelo Neumann
@since 29/02/2024
@version P12
@param 01 cRecurso , Caracter, Código do Recurso - HWK_RECURS
@param 02 cCenTrab , Caracter, Código do Centro de Trabalho - HWK_CTRAB
@param 03 dData    , Data    , Data do registro de apontamento - HWK_DATA
@param 04 cInicio  , Caracter, Hora de início do registro de apontamento - HWK_HRINI
@param 05 cFim     , Caracter, Hora de fim do registro de apontamento - HWK_HRFIM
@param 06 nTempoHWK, Numérico, Tempo do registro - HWK_TEMPOT
@param 07 cOrigem  , Caracter, Origem do registro (HWF, SMK, Calendário) - HWK_ORIGEM
@return Nil
/*/
Static Function addRegHWK(cRecurso, cCenTrab, dData, cInicio, cFim, nTempoHWK, cOrigem)

	If nTempoHWK > 0
 		aAdd(_aDadosHWK, { cRecurso, cCenTrab, dData, cInicio, cFim, nTempoHWK, cOrigem })
	EndIf

Return

/*/{Protheus.doc} hasDicFerr
Verifica se possui a tabela de ferramentas efetivadas no dicionario de dados.
@type  Static Function
@author Lucas Fagundes
@since 30/04/2025
@version P12
@return _lDicFerra, Logico, Indica se possui a tabela de ferramentas efetivadas.
/*/
Static Function hasDicFerr()

	If _lDicFerra == Nil
		_lDicFerra := AliasInDic("HZL")
	EndIf

Return _lDicFerra
