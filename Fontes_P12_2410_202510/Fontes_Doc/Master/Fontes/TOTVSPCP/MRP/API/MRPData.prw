#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "MRPDATA.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE N_POS_ESTOQUE         1
#DEFINE N_POS_ENTRADAS        2
#DEFINE N_POS_SAIDAS          3
#DEFINE N_POS_TRANSF_ENTRADA  4
#DEFINE N_POS_TRANSF_SAIDA    5
#DEFINE N_POS_SAIDA_ESTRUTURA 6
#DEFINE N_POS_SUBSTITUICAO    7
#DEFINE N_POS_SALDO_FINAL     8
#DEFINE N_POS_NECESSIDADE     9
#DEFINE N_POS_VALOR_NECESS    10
#DEFINE N_POS_VALOR_ESTOQUE   11
#DEFINE N_POS_QUANT_PMP       12
#DEFINE N_TAM_ARRAY_TIPOS     12

#DEFINE C_NUMBER_FIELD_MASK '1.2-10'

Static _aTamQtd   := TamSX3("HWG_QTEMPE")
Static _oDescAgl  := Nil
Static _lPctRas   := Nil
Static _oCachePer := Nil
Static _oCacheFil := Nil
Static _oQryOPs   := Nil
Static _oQryEmp   := Nil
Static _oQryEmpOp := Nil
Static _oQrySCs   := Nil
Static _oQryDem   := Nil
Static _oQryItDem := Nil
Static _lSMI      := Nil
Static _lFldLoTMI := Nil

//Melhoria de performance
Static _oQryHWB    := Nil
Static _oQryInSub  := Nil
Static _oQryOutSu  := Nil
Static _oQryLotVe  := Nil
Static _oQryPlanM  := Nil
Static _oQryHasAg  := Nil
Static _oQryEstoq  := Nil
Static _oQryEvent  := Nil
Static _lAgluMrp   := Nil
Static _oFilsIn    := Nil
Static _oQryAllDem := Nil
Static _oQryEmpAll := Nil

/*/{Protheus.doc} mrpdata
API de integracao de Resultados do MRP

@type  WSCLASS
@author renan.roeder
@since 31/07/2019
@version P12.1.27
/*/
WSRESTFUL mrpdata DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Resultados do MRP"
	WSDATA allBranches         AS BOOLEAN OPTIONAL
	WSDATA branchId            AS STRING  OPTIONAL
	WSDATA clean               AS STRING  OPTIONAL
	WSDATA finalDate           AS STRING  OPTIONAL
	WSDATA initialDate         AS STRING  OPTIONAL
	WSDATA Order               AS STRING  OPTIONAL
	WSDATA optionalId          AS STRING  OPTIONAL
	WSDATA product             AS STRING  OPTIONAL
	WSDATA productDescription  AS STRING  OPTIONAL
	WSDATA productGroup        AS STRING  OPTIONAL
	WSDATA purchaseGroup       AS STRING  OPTIONAL
	WSDATA productType         AS STRING  OPTIONAL
	WSDATA ticket              AS STRING  OPTIONAL
	WSDATA filter              AS STRING  OPTIONAL
	WSDATA filterZero          AS BOOLEAN OPTIONAL
	WSDATA Page                AS INTEGER OPTIONAL
	WSDATA PageSize            AS INTEGER OPTIONAL
	WSDATA productFrom         AS STRING  OPTIONAL
	WSDATA productTo           AS STRING  OPTIONAL
	WSDATA costOption          AS INTEGER OPTIONAL
	WSDATA periodFrom          AS STRING  OPTIONAL
	WSDATA periodTo            AS STRING  OPTIONAL
	WSDATA ordem               AS STRING  OPTIONAL
	WSDATA demanda             AS STRING  OPTIONAL
	WSDATA tipo                AS STRING  OPTIONAL
	WSDATA inicioDe            AS STRING  OPTIONAL
	WSDATA inicioAte           AS STRING  OPTIONAL
	WSDATA entregaDe           AS STRING  OPTIONAL
	WSDATA entregaAte          AS STRING  OPTIONAL
	WSDATA compra              AS STRING  OPTIONAL
	WSDATA documento           AS STRING  OPTIONAL
	WSDATA productEMP          AS STRING  OPTIONAL
	WSDATA origem              AS STRING  OPTIONAL
	WSDATA filialOrigem        AS STRING  OPTIONAL
	WSDATA filialDestino       AS STRING  OPTIONAL
	WSDATA status              AS STRING  OPTIONAL
	WSDATA CRP                 AS BOOLEAN OPTIONAL
	WSDATA filtraIN            AS BOOLEAN OPTIONAL
	WSDATA export              AS BOOLEAN OPTIONAL

	WSMETHOD GET RESULTS;
		DESCRIPTION STR0002; //"Retorna os resultados do cálculo do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/results" ;
		PATH "api/pcp/v1/mrpdata/results" ;
		TTALK "v1"

	WSMETHOD GET TICKETS;
		DESCRIPTION STR0003; //"Retorna todos tickets processados pelo MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/tickets" ;
		PATH "api/pcp/v1/mrpdata/tickets" ;
		TTALK "v1"

	WSMETHOD GET PRODRESULT;
		DESCRIPTION STR0012; //"Retorna os resultados de um produto específico"
		WSSYNTAX "api/pcp/v1/mrpdata/prodresult" ;
		PATH "api/pcp/v1/mrpdata/prodresult" ;
		TTALK "v1"

	WSMETHOD GET STGERADOC;
		DESCRIPTION STR0024; //"Retorna o status da geração dos documentos de acordo com o resultado do processamento do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/stgeradoc/{ticket}" ;
		PATH "api/pcp/v1/mrpdata/stgeradoc/{ticket}" ;
		TTALK "v1"

	WSMETHOD POST GERADOC;
		DESCRIPTION STR0017; //"Geração dos documentos de acordo com o resultado do processamento do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/geradoc/" ;
		PATH "api/pcp/v1/mrpdata/geradoc/" ;
		TTALK "v1"

	WSMETHOD GET REPORT;
		DESCRIPTION STR0026; //"Busca resultados do MRP para exportação de relatório"
		WSSYNTAX "api/pcp/v1/mrpdata/report/{ticket}" ;
		PATH "api/pcp/v1/mrpdata/report/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET PRODSINFO;
		DESCRIPTION STR0027; //"Busca informações de produtos"
		WSSYNTAX "api/pcp/v1/mrpdata/products/{ticket}" ;
		PATH "api/pcp/v1/mrpdata/products/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET PERIODS;
		DESCRIPTION STR0033; //"Busca informações dos períodos";
		WSSYNTAX "api/pcp/v1/mrpdata/periods/{ticket}" ;
		PATH "api/pcp/v1/mrpdata/periods/{ticket}" ;
		TTALK "v1"

	WSMETHOD GET SUBSALT;
		DESCRIPTION STR0049; //"Busca os produtos alternativos a partir de um produto original"
		WSSYNTAX "api/pcp/v1/mrpdata/subst/alt";
		PATH "api/pcp/v1/mrpdata/subst/alt";
		TTALK "v1"

	WSMETHOD GET SUBSORI;
		DESCRIPTION STR0050; //"Busca os produtos originais a partir de um produto alternativo"
		WSSYNTAX "api/pcp/v1/mrpdata/subst/ori";
		PATH "api/pcp/v1/mrpdata/subst/ori";
		TTALK "v1"

	WSMETHOD GET GEN_INFO;
		DESCRIPTION STR0052; //"Retorna informações que não dependem do ticket selecionado."
		WSSYNTAX "api/pcp/v1/mrpdata/generics" ;
		PATH "api/pcp/v1/mrpdata/generics" ;
		TTALK "v1"

	WSMETHOD GET OPTIONAL;
		DESCRIPTION STR0051; //"Busca os opcionais do produto em um ticket";
		WSSYNTAX "api/pcp/v1/mrpdata/optional/{ticket}/{product}/{optionalId}" ;
		PATH "api/pcp/v1/mrpdata/optional/{ticket}/{product}/{optionalId}" ;
		TTALK "v1"

	WSMETHOD GET EXP_OPC;
		DESCRIPTION STR0055; //"Retorna as informações dos opcionais para exportação"
		WSSYNTAX "api/pcp/v1/mrpdata/expopc/{ticket}";
		PATH "api/pcp/v1/mrpdata/expopc/{ticket}";
		TTALK "v1"

	WSMETHOD GET ORDENS;
		DESCRIPTION STR0063; // "Retorna as ordens de produção de um ticket do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/{ticket}/ordens" ;
		PATH "api/pcp/v1/mrpdata/{ticket}/ordens" ;
		TTALK "v1"

	WSMETHOD GET EMPENHOS;
		DESCRIPTION STR0064; // "Retorna os empenhos de um ticket do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/{ticket}/empenhos" ;
		PATH "api/pcp/v1/mrpdata/{ticket}/empenhos" ;
		TTALK "v1"

	WSMETHOD GET COMPRAS;
		DESCRIPTION STR0065; // "Retorna as compras de um ticket do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/{ticket}/compras" ;
		PATH "api/pcp/v1/mrpdata/{ticket}/compras" ;
		TTALK "v1"

	WSMETHOD GET DEMANDAS;
		DESCRIPTION STR0066; // "Retorna as demandas de um ticket do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/{ticket}/demandas" ;
		PATH "api/pcp/v1/mrpdata/{ticket}/demandas" ;
		TTALK "v1"

	WSMETHOD GET EMP_OP;
		DESCRIPTION STR0067; // "Retorna os empenhos de uma ordem de produção considerada pelo MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/{ticket}/empenhos/{branchId}/{ordem}" ;
		PATH "api/pcp/v1/mrpdata/{ticket}/empenhos/{branchId}/{ordem}" ;
		TTALK "v1"

	WSMETHOD GET DEMS_DEM;
		DESCRIPTION STR0068; // "Retorna os itens de uma demanda considerada pelo MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/{ticket}/demandas/{branchId}/{demanda}" ;
		PATH "api/pcp/v1/mrpdata/{ticket}/demandas/{branchId}/{demanda}" ;
		TTALK "v1"

	WSMETHOD GET TRANSFS;
		DESCRIPTION STR0075; // "Retorna as transferências consideras pelo MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/{ticket}/transferencias";
		PATH "api/pcp/v1/mrpdata/{ticket}/transferencias";
		TTALK "v1"

	WSMETHOD GET ALLEMPENHOS;
		DESCRIPTION STR0064; // "Retorna os empenhos de um ticket do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/{ticket}/allempenhos";
		PATH "api/pcp/v1/mrpdata/{ticket}/allempenhos";
		TTALK "v1"

	WSMETHOD GET ALLDEMANDAS;
		DESCRIPTION STR0066; // "Retorna as demandas de um ticket do MRP"
		WSSYNTAX "api/pcp/v1/mrpdata/{ticket}/alldemandas" ;
		PATH "api/pcp/v1/mrpdata/{ticket}/alldemandas" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET PRODSINFO api/pcp/v1/mrpdata/products/{ticket}
Retorna todos os produtos do ticket

@type WSMETHOD
@author douglas.heydt
@since 25/04/2021
@version P12.1.27
@param 01 ticket      , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 product     , Caracter, Código do produto
@param 03 productFrom , Caracter, Código inicial do filtro de produto
@param 04 productTo   , Caracter, Código final do filtro de produto
@param 05 costOption  , Numeral , Tipo do custo de produto
@param 06 optionalId  , Caracter, ID Opcional do produto
@param 07 allBranches , Lógico  , Indica se deve retornar as informações dos produtos de todas as filiais
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PRODSINFO WSRECEIVE ticket, product, productFrom, productTo, costOption, optionalId, allBranches WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getProds(Self:ticket, Self:product, Self:productFrom, Self:productTo, Self:costOption, Self:optionalId, Self:allBranches)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} GET PRODRESULT api/pcp/v1/mrpdata/prodresult
Retorna os resultados de um produto específico (HWC)

@type WSMETHOD
@author douglas.heydt
@since 25/04/2021
@version P12.1.27
@param 01 branchId, Caracter, Codigo da filial para fazer a pesquisa
@param 02 ticket  , Caracter, Codigo único do processo para fazer a pesquisa
@param 03 Order   , Caracter, Ordenação do retorno da consulta
@param 04 Page    , Caracter, Página de retorno
@param 05 PageSize, Caracter, Tamanho da página
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PRODRESULT WSRECEIVE ticket, product, optionalId, filterZero QUERYPARAM Order, Page, PageSize WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getPrdRes(Self:ticket, Self:product, Self:optionalId, Self:filterZero)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} GET RESULTS api/pcp/v1/mrpdata/results/{branchId}/{ticket}
Retorna o Resultado do processamento do MRP (HWB)

@type WSMETHOD
@author marcelo.neumann
@since 26/03/2021
@version P12.1.27
@param 01 branchId, Caracter, Codigo da filial para fazer a pesquisa
@param 02 ticket  , Caracter, Codigo único do processo para fazer a pesquisa
@param 03 Order   , Caracter, Ordenação do retorno da consulta
@param 04 Page    , Caracter, Página de retorno
@param 05 PageSize, Caracter, Tamanho da página
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/

WSMETHOD GET RESULTS WSRECEIVE branchId, ticket, product, productDescription, productGroup, purchaseGroup, productType, filterZero  QUERYPARAM Order, Page, PageSize WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetRes(Self:branchId, Self:ticket, Self:product, Self:productDescription, Self:productGroup, Self:purchaseGroup, Self:productType, Self:filterZero, Self:Order, Self:Page, Self:PageSize)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetRes
Retorna o Resultado do processamento do MRP (HWB)

@type Function
@author marcelo.neumann
@since 26/03/2021
@version P12.1.27
@param 01 cBranch    , Caracter, Codigo da filial
@param 02 cTicket    , Caracter, Codigo único do processo
@param 03 cProduct   , Caracter, Código do produto
@param 04 cPrdDescri , Caracter, Descrição do produto
@param 05 cProdGroup , Caracter, grupo do produto
@param 06 cPurcGroup , Caracter, grupo de compras
@param 07 cProdType  , Caracter, tipo do produto
@param 08 lExibeZero , Lógico  , Indica se deve retornar registros com a necesssidade zerada
@param 09 cOrder     , Caracter, Ordenação do retorno da consulta
@param 10 nPage      , Caracter, Página de retorno
@param 11 cPageSize  , Caracter, Tamanho da página
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi
/*/
Function MrpGetRes(cBranch, cTicket,  cProduct, cPrdDescri, cProdGroup, cPurcGroup, cProdType, lExibeZero, cOrder, nPage, nPageSize)
	Local aFiliais   := {}
	Local aResult 	 := {.F., EncodeUTF8(STR0016), 400} //"Não existem registros para atender os filtros informados"
	Local cAliasPrd  := GetNextAlias()
	Local cFiliaisIN := ""
	Local cQuery     := ""
	Local lMultiEmp  := .F.
	Local lEventos   := .F.
	Local nIndex     := 0
	Local nPos       := 0
	Local nStart     := 0
	Local nTotFils   := 0
	Local nInSubs    := 0
	Local nOutSubs   := 0
	Local nLtVenc    := 0
	Local nPMP       := 0
	Local nEstoque   := 0
	Local oJson      := JsonObject():New()
	Local oQtdsHWB   := Nil

	Default nPage      := 1
	Default nPageSize  := 20
	Default cPrdDescri := ""
	Default cProdGroup := ""
	Default cPurcGroup := ""
	Default cProdType  := ""
	Default lExibeZero := .T.
	Default cOrder     := 'product, optionalId'

	If _oFilsIn == Nil
		_oFilsIn := JsonObject():New()
	EndIf

	If !Empty(cTicket) .And. _oFilsIn:HasProperty(cTicket)
		cFiliaisIN := _oFilsIn[cTicket]
		lMultiEmp  := At("','", _oFilsIn[cTicket]) > 0
	Else
		If Empty(cTicket) .Or. !Empty(cBranch)
			If !Empty(cBranch)
				cBranch := PadR(cBranch, FWSizeFilial())
			EndIf

			cFiliaisIN := "'" + xFilial("HWB", cBranch) + "'"
		Else
			MrpTickeME(cTicket, .F., , , aFiliais)
			nTotFils := Len(aFiliais)
			If nTotFils == 0
				cFiliaisIN := "'" + xFilial("HWB") + "'"
			Else
				lMultiEmp := .T.
				For nIndex := 1 To nTotFils
					If nIndex > 1
						cFiliaisIN += ","
					EndIf
					cFiliaisIN += "'" + aFiliais[nIndex][1] + "'"
				Next nIndex
			EndIf
		EndIf

		If !Empty(cTicket)
			_oFilsIn[cTicket] := cFiliaisIN
		EndIf
	EndIf

	cQuery := "SELECT DISTINCT HWB.HWB_TICKET ticket,"                  + ;
	                         " HWB.HWB_PRODUT product,"                 + ;
	                         " HWB.HWB_IDOPC  optionalId,"              + ;
	                         " HWA.HWA_TIPO   productType,"             + ;
	                         " HWA.HWA_GRUPO  productGroup,"            + ;
	                         " HWA.HWA_DESC   productDescription,"      + ;
	                         " HWA.HWA_GRPCOM purchaseGroup,"           + ;
	                         " HWA.HWA_GCDESC purchaseGroupDescription" + ;
	           " FROM " + RetSqlName("HWB") + " HWB"                    + ;
	          " INNER JOIN " +RetSqlName("HWA") + " HWA"                + ;
	             " ON HWA.HWA_FILIAL = '" + xFilial("HWA") + "'"        + ;
	            " AND HWA.HWA_PROD   = HWB.HWB_PRODUT"                  + ;
	            " AND HWA.D_E_L_E_T_ = ' '"                             + ;
	          " WHERE HWB.HWB_FILIAL IN (" + cFiliaisIN + ")"           + ;
	            " AND HWB.D_E_L_E_T_ = ' '"

	If !Empty(cTicket)
		cQuery += " AND HWB.HWB_TICKET = '" + cTicket + "'"
	EndIf

	If !Empty(cProduct)
		cQuery += " AND HWB.HWB_PRODUT like '%" + cProduct + "%'"
	EndIf

	If !Empty(cProdType)
		cQuery += " AND HWA.HWA_TIPO like '%" + cProdType + "%'"
	EndIf

	If !Empty(cProdGroup)
		cQuery += " AND HWA.HWA_GRUPO like '%" + cProdGroup + "%'"
	EndIf

	If !Empty(cPrdDescri)
		cQuery += " AND HWA.HWA_DESC like '%" + cPrdDescri + "%'"
	EndIf

	If !Empty(cPurcGroup)
		cQuery += " AND HWA.HWA_GRPCOM like '%" + cPurcGroup + "%'"
	EndIf

	If !lExibeZero
		cQuery += " GROUP BY HWB.HWB_TICKET, HWB.HWB_PRODUT, HWB.HWB_IDOPC, HWA.HWA_TIPO, HWA.HWA_GRUPO, HWA.HWA_DESC, HWA.HWA_GRPCOM, HWA.HWA_GCDESC "
		cQuery += " HAVING Sum(HWB.HWB_QTNECE) > 0 "
	EndIf

	cQuery += " ORDER BY " + cOrder

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasPrd,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasPrd)->(dbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}

	While (cAliasPrd)->(!Eof())
		aAdd(oJson["items"], JsonObject():New())
        nPos++

		nInSubs  := getInSubst(cFiliaisIN, (cAliasPrd)->ticket, (cAliasPrd)->product, (cAliasPrd)->optionalId)
		nOutSubs := getOutSubs(cFiliaisIN, (cAliasPrd)->ticket, (cAliasPrd)->product, (cAliasPrd)->optionalId)
		nLtVenc  := getLotVenc(cFiliaisIN, (cAliasPrd)->ticket, (cAliasPrd)->product, (cAliasPrd)->optionalId)
		nPMP     := getPlanMes(cFiliaisIN, (cAliasPrd)->ticket, (cAliasPrd)->product, (cAliasPrd)->optionalId)
		lHasAgl  := getHasAglu(cFiliaisIN, (cAliasPrd)->ticket, (cAliasPrd)->product, (cAliasPrd)->optionalId)
		nEstoque := getSaldoEs(cFiliaisIN, (cAliasPrd)->ticket, (cAliasPrd)->product, (cAliasPrd)->optionalId)
		lEventos := getHasEven(cFiliaisIN, (cAliasPrd)->ticket, (cAliasPrd)->product)
		oQtdsHWB := getQtdsHWB(cFiliaisIN, (cAliasPrd)->ticket, (cAliasPrd)->product, (cAliasPrd)->optionalId, (nTotFils > 0))

		oJson["items"][nPos]["link"             ] := {'link'}
		oJson["items"][nPos]["ticket"           ] := (cAliasPrd)->ticket
		oJson["items"][nPos]["product"          ] := RTrim((cAliasPrd)->product)
		oJson["items"][nPos]["inFlows"          ] := oQtdsHWB["inFlows"]  - nInSubs  + nPMP
		oJson["items"][nPos]["outFlows"         ] := oQtdsHWB["outFlows"] + nOutSubs - nPMP
		oJson["items"][nPos]["substitution"     ] := nInSubs + nOutSubs
		oJson["items"][nPos]["structureOutFlows"] := oQtdsHWB["structureOutFlows"]
		oJson["items"][nPos]["necessityQuantity"] := oQtdsHWB["necessityQuantity"]
		oJson["items"][nPos]["events"			] := lEventos
		oJson["items"][nPos]["optionalId"       ] := (cAliasPrd)->optionalId
		oJson["items"][nPos]["stockBalance"     ] := nEstoque
		oJson["items"][nPos]["transferIn"       ] := oQtdsHWB["transferIn"]
		oJson["items"][nPos]["transferOut"      ] := oQtdsHWB["transferOut"]

		oJson["items"][nPos]["mrpDataDetail"] := {}
		aAdd(oJson["items"][nPos]["mrpDataDetail"], JsonObject():New())

		oJson["items"][nPos]["mrpDataDetail"][1]["productDescription"      ] := (cAliasPrd)->productDescription
		oJson["items"][nPos]["mrpDataDetail"][1]["productType"             ] := (cAliasPrd)->productType
		oJson["items"][nPos]["mrpDataDetail"][1]["productGroup"            ] := (cAliasPrd)->productGroup
		oJson["items"][nPos]["mrpDataDetail"][1]["purchaseGroup"           ] := (cAliasPrd)->purchaseGroup
		oJson["items"][nPos]["mrpDataDetail"][1]["purchaseGroupDescription"] := (cAliasPrd)->purchaseGroupDescription

		//Atualiza as informações de opcional
		If Empty((cAliasPrd)->optionalId)
			oJson["items"][nPos]["viewOptional" ] := {''}
		Else
			oJson["items"][nPos]["viewOptional" ] := {'viewOptional'}
		EndIf

		If lHasAgl
			oJson["items"][nPos]["qtyOfAgglutinateMRP"] := 1
		Else
			oJson["items"][nPos]["qtyOfAgglutinateMRP"] := 0
		EndIf

		oJson["items"][nPos]["existeSMI"         ] := validSMI()
		oJson["items"][nPos]["existeLotMinTransf"] := fldLtMinTr()
		oJson["items"][nPos]["optionalSelected"  ] := (cAliasPrd)->optionalId
		oJson["items"][nPos]["finalBalance"      ] := oJson["items"][nPos]["stockBalance"]      + ;
		                                              oQtdsHWB["inFlows"]                       + ;
		                                              oJson["items"][nPos]["transferIn"]        - ;
		                                              oQtdsHWB["outFlows"]                      - ;
		                                              oJson["items"][nPos]["structureOutFlows"] - ;
		                                              oJson["items"][nPos]["transferOut"]       - ;
		                                              nLtVenc

		(cAliasPrd)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	lHasNext := (cAliasPrd)->(!Eof())

	(cAliasPrd)->(dbCloseArea())

	oJson["ticketMultiEmpresa"] := lMultiEmp
	oJson["hasNext"]            := lHasNext

	If Len(oJson["items"]) > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	EndIf

	aSize(oJson["items"], 0)
	FreeObj(oJson)
	aSize(aFiliais, 0)

Return aResult

/*/{Protheus.doc} GET TICKETS api/pcp/v1/mrpdata/tickets
Retorna todos tickets processados pelo MRP

@type WSMETHOD
@author douglas.heydt
@since 31/03/2021
@version P12.1.27
@param 01 filter      , Caracter, usado para buscar ticket especifico
@param 02 initialDate , Caracter, data inicial de processamento do ticket
@param 03 finalDate   , Caracter, data final de processamento do ticket
@param 04 clean       , Caracter, indica se a busca é efetuada pela limpeza de tickets Po UI ( true ou false)
@param 05 Order       , Caracter, Ordenação do retorno da consulta
@param 06 Page        , Caracter, Página de retorno
@param 07 PageSize    , Caracter, Tamanho da página
@param 08 CRP         , Logico  , Indica que a consulta está sendo feita pelo CRP.
@param 09 filtraIN    , Logico  , Indica que deve filtrar com IN ao invés de LIKE.
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET TICKETS WSRECEIVE filter,initialDate, finalDate, clean QUERYPARAM Order, Page, PageSize, CRP, filtraIN WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	If Self:clean == "true"
	  Self:clean := .T.
	Else
		Self:clean := .F.
	EndIf

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetTick(Self:filter, Self:initialDate, Self:finalDate , Self:clean, Self:Order, Self:Page, Self:PageSize, Self:CRP, Self:filtraIN)

	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} MrpGetTick
Retorna todos tickets processados pelo MRP

@type Function
@author douglas.heydt
@since 31/03/2021
@version P12.1.27
@param 01 cTicket     , Caracter, ticket que será buscado
@param 02 initialDate , Caracter, Data inicial de processamento do ticket
@param 03 finalDate   , Caracter, Data final de processamento do ticket
@param 04 lClean      , Caracter, indica se a busca é efetuada pela limpeza de tickets Po UI ( true ou false)
@param 05 cOrder      , Caracter, Ordenação do retorno da consulta
@param 06 nPage       , Caracter, Página de retorno
@param 07 cPageSize   , Caracter, Tamanho da página
@param 08 lCRP        , Logico  , Indica que está buscando os tickest na tela do CRP.
@param 09 lFiltIn     , Logico  , Indica que deve fazer o filtro do ticket usando IN ao invés do LIKE.
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro identificado pelo MRPApi
/*/
Function MrpGetTick(cTicket, initialDate, finalDate, lClean, cOrder, nPage, nPageSize, lCRP, lFiltIn)
	Local aResult 	   := {}
	Local cAliasQry    := GetNextAlias()
	Local cStatus      := ""
	Local cQuery       := ""
	Local nPos         := 0
	Local nStart       := 0
	Local oJson        := JsonObject():New()

	Default cTicket   :=" "
	Default cOrder    := 'ticket'
	Default nPage     := 1
	Default nPageSize := 20
	Default lClean    := .F.
	Default lFiltIn   := .F.
	Default lCRP      := .F.

	dbSelectArea("HW3")

	cQuery := " SELECT "+;
                    " HW3_FILIAL  branchId, "    +;
                    " HW3_TICKET  ticket, "      +;
                    " HW3_STATUS  status,"       +;
                    " HW3_DTINIC  initialDate, " +;
                    " HW3_HRINIC  InitialTime, " +;
                    " HW3_DTFIM   finalDate, "   +;
                    " HW3_HRFIM   finalTime, "   +;
					" HW3_USER    usuario, "     +;
					" ( select HW1_VAL from "+RetSqlName("HW1")+" where HW1_FILIAL = '"+xFilial("HW1")+"' AND HW1_TICKET = HW3_TICKET AND HW1_PARAM = 'demandEndDate' AND D_E_L_E_T_ = ' ' ) AS demandEndDate, " +;
				    " ( select HW1_VAL from "+RetSqlName("HW1")+" where HW1_FILIAL = '"+xFilial("HW1")+"' AND HW1_TICKET = HW3_TICKET AND HW1_PARAM = 'demandStartDate' AND D_E_L_E_T_ = ' ' ) AS demandStartDate " +;
             " FROM "+RetSqlName("HW3")+" "+;
             " WHERE HW3_FILIAL = '"+xFilial("HW3")+"' AND D_E_L_E_T_ = ' ' "

	If !Empty(initialDate)
		cQuery += "AND HW3_DTINIC >= '" + convDate(initialDate, 2) + "' "
	Endif
	If !Empty(finalDate)
		cQuery += "AND HW3_DTINIC <= '" + convDate(finalDate, 2) + "' "
	EndIf
	If lClean
		cQuery += " AND HW3_STATUS <> '8' "
	ElseIf lCRP
		cQuery += " AND HW3_STATUS IN ('6', '7') "
		cQuery += " AND EXISTS (SELECT 1 "
		cQuery +=               " FROM " + RetSqlName("SC2") + " SC2 "
		cQuery +=              " WHERE SC2.C2_FILIAL = '" + xFilial("SC2") + "' "
		cQuery +=                " AND SC2.C2_SEQMRP = HW3_TICKET "
		cQuery +=                " AND SC2.C2_BATROT = 'PCPA144' "
		cQuery +=                " AND SC2.D_E_L_E_T_ = ' ') "
	Else
		cQuery += " AND HW3_STATUS IN ('3','6','7') "
	EndIf
	If !Empty(cTicket)
		If lFiltIn
			cQuery += " AND HW3_TICKET IN ('" + StrTran(cTicket, ",", "','") + "') "
		Else
			cQuery += " AND HW3_TICKET like '%"+cTicket+"%' "
		EndIf
	EndIf
	cQuery += " ORDER BY "+cOrder+" DESC "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	TcSetField(cAliasQry, 'initialDate', 'D', GetSx3Cache("HW3_DTINIC", "X3_TAMANHO"), 0)
	TcSetField(cAliasQry, 'finalDate', 'D', GetSx3Cache("HW3_DTFIM", "X3_TAMANHO"), 0)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"], JsonObject():New())
		nPos++

		cStatus := P144Status((cAliasQry)->status)

		oJson["items"][nPos]["branchId"]        := (cAliasQry)->branchId
		oJson["items"][nPos]["ticket"]          := (cAliasQry)->ticket
		oJson["items"][nPos]["idStatus"]        := (cAliasQry)->status
		oJson["items"][nPos]["status"]          := cStatus
		oJson["items"][nPos]["initialDate"]     := convDate((cAliasQry)->initialDate, 1)
		oJson["items"][nPos]["initialTime"]     := (cAliasQry)->InitialTime
		oJson["items"][nPos]["finalDate"]       := convDate((cAliasQry)->finalDate, 1)
		oJson["items"][nPos]["finalTime"]       := (cAliasQry)->finalTime
		oJson["items"][nPos]["demandStartDate"] := convDate(trim((cAliasQry)->demandStartDate), 3)
		oJson["items"][nPos]["demandEndDate"]   := convDate(trim((cAliasQry)->demandEndDate), 3)
		oJson["items"][nPos]["user"]            := (cAliasQry)->usuario

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End
	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0 .Or. lCRP
		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJSON()))
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, EncodeUTF8(STR0016)) //"Não existem registros para atender os filtros informados"
		aAdd(aResult, 400)
	EndIf

	aSize(oJson["items"], 0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} convDate
Converte formatos de data conforme o tipo definid.or.

@type  Static Function
@author douglas.heydt
@since 12/04/2021
@version P12.1.27
@param cData, Date, Data que será convertida
@param nType, numeral, tipo de conversão executada
		1 - date para DD/MM/AAAA
		2 - AAAA-MM-DD para AAAAMMDD
		3 - AAAA-MM-DD para DD/MM/AAAA
		4 - AAAAMMDD para AAAA-MM-DD


@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Static Function convDate(cData, nType)

	If !Empty(cData)
		If nType == 1
			cData := StrZero(Day(cData),2) + "/" + StrZero(Month(cData),2) + "/" +  StrZero(Year(cData),4)
		ElseIf nType == 2
			cData := StrTran(cData, "-", "")
		ElseIf nType == 3
			cData := StrTran(cData, "-", "")
			cData := SUBSTR(cData, 7, 2)  + "/" + SUBSTR(cData, 5, 2)  + "/" +  SUBSTR(cData, 0, 4)
		ElseIf nType == 4
			cData := SUBSTR(cData, 0, 4) +"-"+ SUBSTR(cData, 5, 2)+"-"+SUBSTR(cData, 7, 2)
		EndIf
	EndIf

Return cData

/*/{Protheus.doc} getPrdRes
Retorna o Resultado de um produto específico

@type Function
@author douglas.heydt
@since 03/05/2021
@version P12.1.27
@param 01 cTicket     , Caracter, Codigo único do processo
@param 02 cProduto    , Caracter, Código do produto
@param 03 cOptional   , Caracter, Id do opcional
@param 04 lExibeZero  , Lógico  , Indica se deve retornar registros com a necesssidade zerada
@return aResult, Array, Array com as informacoes da requisicao
/*/
Function getPrdRes(cTicket, cProduto, cOptional, lExibeZero)
	Local aDates     := {}
	Local aFiliais   := {}
	Local aResult 	 := {}
	Local cFiliaisIN := ""
	Local lMultiEmp  := .F.
	Local nIndex     := 0
	Local nTamDates  := 0
	Local nTotFils   := 0
	Local oJson      := JsonObject():New()

	Default cOptional  := ""
	Default lExibeZero := .T.

	If Empty(cTicket)
		cFiliaisIN := "'" + xFilial("HWB") + "'"
	Else
		MrpTickeME(cTicket, .F., , , aFiliais)
		nTotFils := Len(aFiliais)
		If nTotFils == 0
			cFiliaisIN := "'" + xFilial("HWB") + "'"
		Else
			lMultiEmp := .T.
			For nIndex := 1 To nTotFils
				If nIndex > 1
					cFiliaisIN += ","
				EndIf
				cFiliaisIN += "'" + aFiliais[nIndex][1] + "'"
			Next nIndex
		EndIf
	EndIf

	oJson["items"] := Array(N_TAM_ARRAY_TIPOS)

	oJson["items"][N_POS_ESTOQUE         ] := JsonObject():New()
	oJson["items"][N_POS_ENTRADAS        ] := JsonObject():New()
	oJson["items"][N_POS_SAIDAS          ] := JsonObject():New()
	oJson["items"][N_POS_TRANSF_ENTRADA  ] := JsonObject():New()
	oJson["items"][N_POS_TRANSF_SAIDA    ] := JsonObject():New()
	oJson["items"][N_POS_SAIDA_ESTRUTURA ] := JsonObject():New()
	oJson["items"][N_POS_SUBSTITUICAO    ] := JsonObject():New()
	oJson["items"][N_POS_SALDO_FINAL     ] := JsonObject():New()
	oJson["items"][N_POS_NECESSIDADE     ] := JsonObject():New()
	oJson["items"][N_POS_VALOR_NECESS    ] := JsonObject():New()
	oJson["items"][N_POS_VALOR_ESTOQUE   ] := JsonObject():New()
	oJson["items"][N_POS_QUANT_PMP       ] := JsonObject():New()

	aDates := getHWB(cTicket, cProduto, cOptional, cFiliaisIN, oJson["items"], lExibeZero, nTotFils)

	//Remove do JSON as linhas que não devem ser exibidas na tela de resultados do produto.
	If lMultiEmp
		aSize(oJson["items"], N_POS_NECESSIDADE)
	Else
		aDel(oJson["items"] , N_POS_TRANSF_SAIDA)
		aDel(oJson["items"] , N_POS_TRANSF_ENTRADA)
		aSize(oJson["items"], N_POS_NECESSIDADE-2)
	EndIf

	oJson["columns"] := {}
	nTamDates := Len(aDates)

	For nIndex := 1 To nTamDates
		aAdd(oJson["columns"], JsonObject():New())
		oJson["columns"][nIndex]["property"] := DTOS(aDates[nIndex])
		oJson["columns"][nIndex]["label"   ] := convDate(aDates[nIndex],1)
		oJson["columns"][nIndex]["type"    ] := 'number'
		oJson["columns"][nIndex]["format"  ] := C_NUMBER_FIELD_MASK
	Next nIndex

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 400)
	EndIf

	aSize(oJson["items"], 0)
	FreeObj(oJson)
	aSize(aFiliais, 0)

Return aResult

/*/{Protheus.doc} getHWB
Retorna o Resultado de um produto específico

@type Function
@author douglas.heydt
@since 03/05/2021
@version P12.1.27
@param 01 cTicket    , Caracter, Codigo único do processo
@param 02 cProduto   , Caracter, Código do produto
@param 03 cOptional  , Caracter, Id do opcional
@param 04 cFiliaisIN , Caracter, Filiais do ticket
@param 05 aItems     , Array   , Array que será composto pelos resultados do produto
@param 06 lExibeZero , Lógico  , Indica se deve retornar registros com a necesssidade zerada
@param 07 nTotFils   , Numeral , > 0 indica que ticket foi processado considerando multi-empresas.
@return aReturn, Array, Array com os resultados do produto
/*/
Static Function getHWB(cTicket, cProduto, cOptional, cFiliaisIN, aItems, lExibeZero, nTotFils)
	Local aReturn   := {}
	Local cAliasQry := GetNextAlias()
	Local cChave    := ""
	Local cQuery    := ""

	If Empty(cOptional)
		//Tratativa para banco oracle, utiliza ao menos um espaço em branco na query.
		cOptional := " "
	Endif

	cQuery := "SELECT HWB_DATA, SUM(HWB_QTSLES) stockBalance, SUM(HWB_QTENTR) inFlows, SUM(HWB_QTSAID) outFlows,"

	If nTotFils > 0
		cQuery += " SUM(HWB_QTRENT) inFlowTrans, SUM(HWB_QTRSAI) outFlowTrans, "
	EndIf

	cQuery += " SUM(HWB_QTSEST) structOutFlows, SUM(HWB_QTNECE) necessity,"
	cQuery += " (SELECT COALESCE(SUM(HWC_QTSUBS),0)"
	cQuery +=    " FROM " + RetSqlName("HWC")
	cQuery +=   " WHERE HWC_FILIAL IN (" + cFiliaisIN + ")"
	cQuery +=     " AND HWC_TICKET = '"  + cTicket    + "'"
	cQuery +=     " AND HWC_PRODUT = '"  + cProduto   + "'"
	cQuery +=     " AND HWC_IDOPC  = '"  + cOptional  + "'"
	cQuery +=     " AND HWC_DATA   = HWB_DATA AND HWC_QTSUBS > 0) insubs,"

	cQuery += " (SELECT COALESCE(SUM(HWC_QTSUBS),0)"
	cQuery +=    " FROM " + RetSqlName("HWC")
	cQuery +=   " WHERE HWC_FILIAL IN (" + cFiliaisIN + ")"
	cQuery +=     " AND HWC_TICKET = '"  + cTicket    + "'"
	cQuery +=     " AND HWC_PRODUT = '"  + cProduto   + "'"
	cQuery +=     " AND HWC_IDOPC  = '"  + cOptional  + "'"
	cQuery +=     " AND HWC_DATA   = HWB_DATA AND HWC_QTSUBS < 0) outsubs,"

	cQuery += " (SELECT COALESCE(SUM(HWC_QTNEOR),0)"
	cQuery +=    " FROM " + RetSqlName("HWC")
	cQuery +=   " WHERE HWC_FILIAL IN (" + cFiliaisIN + ")"
	cQuery +=     " AND HWC_TICKET = '"  + cTicket    + "'"
	cQuery +=     " AND HWC_PRODUT = '"  + cProduto   + "'"
	cQuery +=     " AND HWC_IDOPC  = '"  + cOptional  + "'"
	cQuery +=     " AND HWC_DATA   = HWB_DATA"
	cQuery +=     " AND HWC_TPDCPA IN ('1','SUBPRD')) masterPlan"

	cQuery +=  " FROM " + RetSqlName("HWB")
	cQuery += " WHERE HWB_FILIAL IN (" + cFiliaisIN + ")"
	cQuery +=   " AND HWB_PRODUT = '"  + cProduto   + "'"
	cQuery +=   " AND HWB_IDOPC  = '"  + cOptional  + "'"
	cQuery +=   " AND HWB_TICKET = '"  + cTicket    + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY HWB_DATA"

	If !lExibeZero
		cQuery += " HAVING SUM(HWB_QTNECE) > 0"
	EndIf

	cQuery += " ORDER BY HWB_DATA"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	TcSetField(cAliasQry, 'HWB_DATA', 'D', GetSx3Cache("HWB_DATA", "X3_TAMANHO"), 0)

	While (cAliasQry)->(!Eof())

       	aAdd(aReturn, (cAliasQry)->HWB_DATA)
		cChave := DTOS((cAliasQry)->HWB_DATA)

		aItems[N_POS_ESTOQUE  ][cChave] := (cAliasQry)->stockBalance
		aItems[N_POS_ENTRADAS ][cChave] := (cAliasQry)->inFlows - (cAliasQry)->insubs + (cAliasQry)->masterPlan
		aItems[N_POS_SAIDAS   ][cChave] := (cAliasQry)->outFlows + (cAliasQry)->outsubs - (cAliasQry)->masterPlan
		If nTotFils > 0
			aItems[N_POS_TRANSF_ENTRADA  ][cChave] := (cAliasQry)->inFlowTrans
			aItems[N_POS_TRANSF_SAIDA    ][cChave] := (cAliasQry)->outFlowTrans
		Else
			aItems[N_POS_TRANSF_ENTRADA  ][cChave] := 0
			aItems[N_POS_TRANSF_SAIDA    ][cChave] := 0
		EndIf
		aItems[N_POS_SAIDA_ESTRUTURA ][cChave] := (cAliasQry)->structOutFlows
		aItems[N_POS_SUBSTITUICAO    ][cChave] := (cAliasQry)->insubs+(cAliasQry)->outsubs

		aItems[N_POS_SALDO_FINAL     ][cChave] := aItems[N_POS_ESTOQUE         ][cChave] + ;
		                                          aItems[N_POS_ENTRADAS        ][cChave] - ;
												  aItems[N_POS_SAIDAS          ][cChave] + ;
												  aItems[N_POS_TRANSF_ENTRADA  ][cChave] - ;
												  aItems[N_POS_TRANSF_SAIDA    ][cChave] - ;
												  aItems[N_POS_SAIDA_ESTRUTURA ][cChave] + ;
												  aItems[N_POS_SUBSTITUICAO    ][cChave]
		aItems[N_POS_NECESSIDADE     ][cChave] := (cAliasQry)->necessity

		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

Return aReturn

/*/{Protheus.doc} GET STGERADOC api/pcp/v1/mrpdata/stgeradoc/{ticket}

@param ticket     , Character, Codigo único do processo

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
@author	parffit.silva
@since 04/08/2021
@version 12.1.33
/*/
WSMETHOD GET STGERADOC PATHPARAM ticket WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetSTGD( Self:ticket )
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} MrpGetSTGD
Retorna status da geração de documentos de um ticket

@param cticket  , Character, Codigo único do processo

@return aResult	, Array, resultados obtidos pela query
@author	parffit.silva
@since 04/08/2021
@version 12.1.33
/*/
Function MrpGetSTGD( cTicket )
	Local aParMrp    := {}
	Local aResult 	 := {}
	Local aValida    := {}
	Local cDetError  := ""
	Local cError     := ""
	Local cProgText  := ""
	Local lError     := .F.
	Local nProgress  := 0
	Local nProgRast  := 0
	Local oGeraDoc   := Nil
	Local oJson      := JsonObject():New()
	Local oPCPError  := Nil

	If _lPctRas == Nil
		_lPctRas := FindFunction("P145DelRas")
	EndIf

	aValida := validaGera(cTicket,"GET")
	If aValida[1] = .F.
		lError := .T.
		cError := aValida[2]
	Else
		If aValida[2] == "3"
			loadParam(cTicket, @aParMrp)
			oGeraDoc := ProcessaDocumentos():New(cticket, .T., aParMrp, RetCodUsr() )
			nProgress := oGeraDoc:getProgress()
			cProgText := oGeraDoc:getProgrText()
			If _lPctRas
				nProgRast := oGeraDoc:getRastProgress()
			EndIf
		Else
			If aValida[2] $ "6|7"
				nProgress := 100
				nProgRast := 100
				oPCPError := PCPMultiThreadError():New("PCPA145_"+ cTicket, .F.)
				If oPCPError:possuiErro()
					cDetError := oPCPError:getcError(3)
					lError := .T.

					Iif(Empty(cDetError), cError := STR0022, cError := STR0023) //"Erro indeterminado. Entre em contato com o departamento de TI e solicite consulta ao console.log" "Ocorreu erro na geração dos documentos"
					MrpDados_Logs():gravaLogMrp("geracao_documentos", "status", {"Erro ao buscar status da geracao de documentos: " + cError})
					GravaCV8("4", GetGlbValue(cTicket + "PCPA145PROCCV8"), /*cMsg*/, cDetError, "", "", NIL, GetGlbValue(cTicket + "PCPA145PROCIDCV8"), cFilAnt)
				EndIf
				oPCPError:destroy()
			EndIf
		EndIf

		oJson["text"        ] := cProgText
		oJson["progress"    ] := nProgress
		oJson["progressRast"] := nProgRast
		oJson["status"      ] := P144Status(aValida[2])
		oJson["idStatus"    ] := aValida[2]
		oJson["msg"         ] := cDetError
	EndIf

	If aValida[1] = .T.
		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, EncodeUTF8(cError))
		aAdd(aResult, 400)
	EndIf
Return aResult

/*/{Protheus.doc} POST GERADOC api/pcp/v1/mrpdata/geradoc/

@param ticket     , Character, Codigo único do processo

@return lRet	, Lógico, Informa se o processo foi executado com sucesso.
@author	parffit.silva
@since 04/08/2021
@version 12.1.33
/*/
WSMETHOD POST GERADOC WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpPostGD( Self:GetContent() )
	MRPApi():restReturn(Self, aReturn, "POST", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} MrpPostGD
Inicia geração de documentos de um ticket

@param cBody, Character, Parâmetros para a geração de documentos (String JSON)

@return aResult	, Array, resultados obtidos pela query
@author	parffit.silva
@since 04/08/2021
@version 12.1.33
/*/
Function MrpPostGD( cBody )
	Local aParMrp    := {}
	Local aResult    := {}
	Local aValida    := {}
	Local cRecover   := ""
	Local cDetError  := ""
	Local cError     := ""
	Local cErrorUID  := ""
	Local cTicket    := ""
	Local lError     := .F.
	Local lAbriu     := .F.
	Local oPCPError  := Nil
	Local oBody      := JsonObject():New()
	Local oJsError   := Nil

	cError := oBody:FromJson(cBody)
	If !Empty(cError)
		lError    := .T.
		cDetError := STR0034 //"Erro ao identificar os parâmetros recebidos na requisição."
	EndIf

	If !lError
		cTicket := oBody["ticket"]

		aValida := validaGera(cTicket, "POST")
		If aValida[1] == .F.
			lError := .T.
			cError := aValida[2]
		Else
			cRecover  := '{|| PCPUnlock("PCPA145") }'
			cErrorUID := "PCPA145_"+ cTicket
			oPCPError := PCPMultiThreadError():New(cErrorUID, .T.)

			loadParam(cTicket, @aParMrp)
			PutGlbValue(cTicket + "P145LOCK", "PEND")

			oPCPError:startJob("PCPA145", GetEnvServer(), .F., cEmpAnt, cFilAnt, cTicket, aClone(aParMrp), .F., cErrorUID, RetCodUsr(), oBody["periodsSC"], oBody["periodsOP"], oBody["opInitialNumber"], , , , cRecover)
			lAbriu := oPCPError:abriuUltimaThread()

			If lAbriu .And. !iniGerDoc(cTicket, oPCPError)
				lError := .T.
				cError := STR0018 //"Existe outro processo bloqueando a geração de documentos. Aguarde e tente novamente mais tarde"
			EndIf

			//Verifica oorrencia de erros no PCPA145
			If !lAbriu .Or. oPCPError:possuiErro()
				cDetError := oPCPError:getcError(3)
				lError := .T.

				Iif(Empty(cDetError), cError := STR0022, cError := STR0023) //"Erro indeterminado. Entre em contato com o departamento de TI e solicite consulta ao console.log" "Ocorreu erro na geração dos documentos"
				MrpDados_Logs():gravaLogMrp("geracao_documentos", "preparacao", {"Erro ao iniciar a geracao de documentos do ticket: " + cTicket + ". Erro: " + cError})
				GravaCV8("4", GetGlbValue(cTicket + "PCPA145PROCCV8"), /*cMsg*/, cDetError, "", "", NIL, GetGlbValue(cTicket + "PCPA145PROCIDCV8"), cFilAnt)
			EndIf

			oPCPError:destroy()
		EndIf
	EndIf

	If lError
		oJsError := JsonObject():New()
		oJsError["code"           ] := 400
		oJsError["message"        ] := cError
		oJsError["detailedMessage"] := cDetError

		aAdd(aResult, 400)
		aAdd(aResult, oJsError:ToJson())
		FreeObj(oJsError)
	Else
		aAdd(aResult, 200)
		aAdd(aResult, '{"code":"200", "ticket":"'+cTicket+'"}')
	EndIf

	FreeObj(oBody)
Return aResult

/*/{Protheus.doc} validaGera
Valida se um ticket pode iniciar o processamento da geração de documentos.

@type  Static Function
@author parffit.silva
@since 04/08/2021
@version P12.1.33
@param cTicket, Character, Ticket do MRP para validação
       cMethod, Character, Identifica método chamador "POST" ou "GET"
@return aReturn, Array   , Identifica se o ticket pode gerar os documentos e possível erro.
/*/
Static Function validaGera(cTicket, cMethod)
	Local aReturn := {.T.,""}

	If Empty(cTicket)
		aReturn[1] := .F.
		aReturn[2] := STR0019 //"Não foi informado o ticket de processamento do MRP"
	EndIf

	If aReturn[1] = .T.
		HW3->(dbSetOrder(1))
		If HW3->(dbSeek(xFilial("HW3")+cTicket))
			If cMethod == 'POST'
				If HW3->HW3_STATUS != "3"
					aReturn[1] := .F.
					aReturn[2] := STR0020 //"Somente processamentos do MRP com o status 'Finalizado' podem iniciar a geração de documentos"
				EndIf
			Else
				aReturn[2] := HW3->HW3_STATUS
			EndIf
		Else
			aReturn[1] := .F.
			aReturn[2] := STR0021 //"Ticket não encontrado nos processamentos do MRP"
		EndIf
	EndIf

Return aReturn

/*/{Protheus.doc} loadParam
Carga de parâmetros do MRP.

@type  Static Function
@author parffit.silva
@since 04/08/2021
@version P12.1.33
@param cTicket   , Caracter, Codigo único do processo
@param aParametro, Array   , Retorna por referência o array com os parâmetros do MRP.
                              Estrutura do array:
                              aParametro[nIndex][1] - ID do Registro (utilizado para exibir em tela). Sempre 0
                              aParametro[nIndex][2] -> Array
                              aParametro[nIndex][2][nIndice][1] - Descrição do parâmetro
                              aParametro[nIndex][2][nIndice][2] - Descrição do conteúdo do parâmetro
                              aParametro[nIndex][2][nIndice][3] - Código do parâmetro
                              aParametro[nIndex][2][nIndice][4] - Valor do parâmetro
@return lRet     , Lógico  , Validação do campo ticket
/*/
Static Function loadParam(cTicket, aParametro)
	Local aItems   := {}
	Local aParam   := {}
	Local cError   := ""
	Local lRet     := .T.
	Local nLenIte  := 0
	Local nX       := 0
	Local oJsonPar := JsonObject():New()

	aParam := MrpGetPar(cFilAnt, cTicket, "ticket,parameter,value,list",,,9999,"Parametros")
	cError := oJsonPar:FromJson(aParam[2])

	aSize(aParametro, 0)

	If Empty(cError)
		aItems := oJsonPar["items"]
		nLenIte := Len(aItems)

		For nX := 1 to nLenIte
			If (aItems[nX]["parameter"] == "structurePrecision";
					.Or. aItems[nX]["parameter"] == "cAutomacao";
					.Or. aItems[nX]["parameter"] == "setupCode";
					.Or. aItems[nX]["parameter"] == "cAutomacao";
					.Or. aItems[nX]["parameter"] == "ticket";
					.Or. aItems[nX]["parameter"] == "processLogs";
					.Or. aItems[nX]["parameter"] == "periodType";
					.Or. aItems[nX]["parameter"] == "demandStartDate";
					.Or. aItems[nX]["parameter"] == "demandEndDate")
				Loop
			EndIf

			aAdd(aParametro, {0, {aItems[nX]["parameter"], aItems[nX]["value"], aItems[nX]["parameter"], aItems[nX]["value"]} })
		Next nX

		aParametro := aSort(aParametro,,, { |x, y| x[2][1] < y[2][1] } )
	EndIf

	aSize(aItems, 0)
	FreeObj(oJsonPar)

Return lRet


/*/{Protheus.doc} GET RESULTS api/pcp/v1/mrpdata/results/{branchId}/{ticket}
Retorna o Resultado do processamento do MRP (HWB)

@type WSMETHOD
@author douglas.heydt
@since 09/09/2021
@version P12.1.27
@param 01 ticket  , Caracter, Codigo único do processo
@param 02 productFrom , Caracter, código inicial do filtro de produto
@param 03 productTo   , Caracter, código final do filtro de produto
@param 04 costOption  , Numeral, tipo do custo de produto
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET REPORT WSRECEIVE productFrom, productTo, costOption, filterZero PATHPARAM ticket WSSERVICE mrpdata
	Local aProducts := {}
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	aReturn := getResults( Self:ticket, Self:productFrom, Self:productTo, Self:costOption, Self:filterZero)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
	aSize(aProducts, 0)

Return lRet

/*/{Protheus.doc} getResults
Busca os resultados de todos os produtos de um ticket MRP
@type  Function
@author douglas.heydt
@since 06/09/2021
@version P12.1.30
@param 01 cTicket   , Caracter, ticket MRP
@param 02 cProdDe   , Caracter, código inicial do filtro de produto
@param 03 cProdAte  , Caracter, código final do filtro de produto
@param 04 nTpCusto  , Numeral, tipo do custo de produto
@param 05 lExibeZero, Lógico , Indica se deve retornar registros com a necesssidade zerada
/*/
Function getResults( cTicket, cProdDe, cProdAte, nTpCusto, lExibeZero)

	Local aFiliais   := {}
	Local aResult    := {}
	Local cAliasQry  := GetNextAlias()
	Local cFiliaisIN := ""
	Local cChave     := ""
	Local cProduto   := ""
	Local cIdOpc     := ""
	Local cQuery     := ""
	Local nCusto     := 0
	Local nIndex     := 0
	Local nTotFils   := 0
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default lExibeZero := .T.

	If Empty(cTicket)
		cFiliaisIN := "'" + xFilial("HWB") + "'"
	Else
		MrpTickeME(cTicket, .F., , , aFiliais)
		nTotFils := Len(aFiliais)
		If nTotFils == 0
			cFiliaisIN := "'" + xFilial("HWB") + "'"
		Else
			For nIndex := 1 To nTotFils
				If nIndex > 1
					cFiliaisIN += ","
				EndIf
				cFiliaisIN += "'" + aFiliais[nIndex][1] + "'"
			Next nIndex
		EndIf
	EndIf

	cQuery := " SELECT HWB.HWB_TICKET, "
	cQuery += "     HWB.HWB_PRODUT, "
	cQuery += "     HWB.HWB_IDOPC, "
	cQuery += "     HWB.HWB_DATA, "
	cQuery += "     SUM(HWB.HWB_QTSLES) stockBalance, "
	cQuery += "     SUM(HWB.HWB_QTENTR) inFlows, "
	cQuery += "     SUM(HWB.HWB_QTSAID) outFlows, "
	If nTotFils > 0
		cQuery += " SUM(HWB.HWB_QTRENT) inFlowTrans, SUM(HWB.HWB_QTRSAI) outFlowTrans, "
	EndIf
	cQuery += "     SUM(HWB.HWB_QTSEST) structOutFlows, SUM(HWB.HWB_QTNECE) necessity, "

	cQuery += " 	( SELECT COALESCE(SUM(HWC_QTSUBS),0) "
	cQuery += " 	   FROM "+RetSqlName("HWC")+" "
	cQuery += " 	   WHERE HWC_FILIAL  IN (" + cFiliaisIN + ") "
	cQuery += " 	     AND HWC_TICKET = '" + cTicket + "' "
	cQuery += " 	     AND HWC_PRODUT = HWB.HWB_PRODUT "
	cQuery += " 	     AND HWC_IDOPC = HWB.HWB_IDOPC "
	cQuery += " 	     AND HWC_DATA = HWB.HWB_DATA "
	cQuery += " 	     AND HWC_QTSUBS > 0 ) insubs, "
	cQuery += " 	( SELECT COALESCE(SUM(HWC_QTSUBS),0) "
	cQuery += " 	   FROM "+RetSqlName("HWC")+" "
	cQuery += " 	   WHERE HWC_FILIAL  IN (" + cFiliaisIN + ") "
	cQuery += " 	     AND HWC_TICKET = '" + cTicket + "' "
	cQuery += " 	     AND HWC_PRODUT = HWB.HWB_PRODUT "
	cQuery += " 	     AND HWC_IDOPC = HWB.HWB_IDOPC "
	cQuery += " 	     AND HWC_DATA = HWB.HWB_DATA "
	cQuery += " 	     AND HWC_QTSUBS < 0 ) outsubs, "
	cQuery += " 	( SELECT COALESCE(SUM(HWC_QTNECE),0) "
	cQuery += " 	   FROM "+RetSqlName("HWC")+" "
	cQuery += " 	   WHERE HWC_FILIAL  IN (" + cFiliaisIN + ") "
	cQuery += " 	     AND HWC_TICKET = '" + cTicket + "' "
	cQuery += " 	     AND HWC_PRODUT = HWB.HWB_PRODUT "
	cQuery += " 	     AND HWC_IDOPC = HWB.HWB_IDOPC "
	cQuery += " 	     AND HWC_DATA = HWB.HWB_DATA "
	cQuery += " 	     AND HWC_TPDCPA IN ('1','SUBPRD')) masterPlan "

	cQuery += " FROM " + RetSqlName("HWB")  + " HWB"          + ;
			  " WHERE HWB.HWB_FILIAL IN (" + cFiliaisIN + ")" + ;
			  " AND HWB.HWB_TICKET = '" + cTicket + "' "

	If !Empty(cProdDe)
		cQuery += " AND HWB.HWB_PRODUT >= '"+cProdDe+"'"
	EndIf

	If !Empty(cProdAte)
		cQuery += " AND HWB.HWB_PRODUT <= '"+cProdAte+"'"
	EndIf

	cQuery += " AND HWB.D_E_L_E_T_ = ' '"

	If !lExibeZero
		cQuery += "  AND (SELECT SUM(HWBQTD.HWB_QTNECE)"
		cQuery += " 	   FROM "+RetSqlName("HWB")+"  HWBQTD"
		cQuery += " 	   WHERE HWBQTD.HWB_FILIAL  IN (" + cFiliaisIN + ") "
		cQuery += " 	     AND HWBQTD.HWB_TICKET = '" + cTicket + "' "
		cQuery += " 	     AND HWBQTD.HWB_PRODUT = HWB.HWB_PRODUT "
		cQuery += " 	     AND HWBQTD.HWB_IDOPC  = HWB.HWB_IDOPC) > 0 "
	EndIf

	cQuery += " GROUP BY HWB.HWB_TICKET, HWB.HWB_PRODUT, HWB.HWB_IDOPC, HWB.HWB_DATA"

	cQuery += " ORDER BY HWB.HWB_PRODUT,HWB.HWB_IDOPC, HWB.HWB_DATA "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	TcSetField(cAliasQry, 'HWB_DATA', 'D', GetSx3Cache("HWB_DATA", "X3_TAMANHO"), 0)

	oJson["items"] := {}
	While (cAliasQry)->(!Eof())
		IF cProduto+cIdOpc != (cAliasQry)->HWB_PRODUT+(cAliasQry)->HWB_IDOPC
			aAdd(oJson["items"], JsonObject():New())
			nPos++
			cProduto := (cAliasQry)->HWB_PRODUT
			nCusto   := GetCost((cAliasQry)->HWB_PRODUT, nTpCusto)
			cIdOpc   := (cAliasQry)->HWB_IDOPC
			oJson["items"][nPos]["results"] := Array(N_TAM_ARRAY_TIPOS)
			oJson["items"][nPos]["results"][N_POS_ESTOQUE         ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_ENTRADAS        ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_SAIDAS          ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_TRANSF_ENTRADA  ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_TRANSF_SAIDA    ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_SAIDA_ESTRUTURA ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_SUBSTITUICAO    ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_SALDO_FINAL     ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_NECESSIDADE     ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_VALOR_NECESS    ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_VALOR_ESTOQUE   ] := JsonObject():New()
			oJson["items"][nPos]["results"][N_POS_QUANT_PMP       ] := JsonObject():New()
		EndIf

		cChave := DTOS((cAliasQry)->HWB_DATA)
		oJson["items"][nPos]["results"][N_POS_ESTOQUE         ][cChave] := (cAliasQry)->stockBalance
		oJson["items"][nPos]["results"][N_POS_ENTRADAS        ][cChave] := (cAliasQry)->inFlows + (cAliasQry)->masterPlan
		oJson["items"][nPos]["results"][N_POS_SAIDAS          ][cChave] := (cAliasQry)->outFlows - (cAliasQry)->masterPlan
		If nTotFils > 0
			oJson["items"][nPos]["results"][N_POS_TRANSF_ENTRADA  ][cChave] := (cAliasQry)->inFlowTrans
			oJson["items"][nPos]["results"][N_POS_TRANSF_SAIDA    ][cChave] := (cAliasQry)->outFlowTrans
		Else
			oJson["items"][nPos]["results"][N_POS_TRANSF_ENTRADA  ][cChave] := 0
			oJson["items"][nPos]["results"][N_POS_TRANSF_SAIDA    ][cChave] := 0
		EndIf
		oJson["items"][nPos]["results"][N_POS_SAIDA_ESTRUTURA ][cChave] := (cAliasQry)->structOutFlows
		oJson["items"][nPos]["results"][N_POS_SUBSTITUICAO    ][cChave] := (cAliasQry)->insubs

		oJson["items"][nPos]["results"][N_POS_SALDO_FINAL     ][cChave] := oJson["items"][nPos]["results"][N_POS_ESTOQUE         ][cChave] + ;
		                                                                   oJson["items"][nPos]["results"][N_POS_ENTRADAS        ][cChave] - ;
												                           oJson["items"][nPos]["results"][N_POS_SAIDAS          ][cChave] + ;
												                           oJson["items"][nPos]["results"][N_POS_TRANSF_ENTRADA  ][cChave] - ;
												                           oJson["items"][nPos]["results"][N_POS_TRANSF_SAIDA    ][cChave] - ;
												                           oJson["items"][nPos]["results"][N_POS_SAIDA_ESTRUTURA ][cChave]
		oJson["items"][nPos]["results"][N_POS_NECESSIDADE     ][cChave]  := (cAliasQry)->necessity
		oJson["items"][nPos]["results"][N_POS_VALOR_NECESS    ][cChave]  := (cAliasQry)->necessity*nCusto
		oJson["items"][nPos]["results"][N_POS_VALOR_ESTOQUE   ][cChave]  := custoEstoq( oJson["items"][nPos]["results"][N_POS_SALDO_FINAL     ][cChave], ;
		                                                                                 ((cAliasQry)->outFlows - (cAliasQry)->masterPlan)             , ;
																						 (cAliasQry)->structOutFlows                                   , ;
																						 (cAliasQry)->stockBalance                                     , ;
																						 ((cAliasQry)->inFlows + (cAliasQry)->masterPlan)              , ;
																						nCusto)
		oJson["items"][nPos]["results"][N_POS_QUANT_PMP       ][cChave]  := (cAliasQry)->masterPlan
		oJson["items"][nPos]["product"] := cProduto
		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())

	oJson["periods"] := {}
    oJson["periods"] := getPeriods(cTicket)

	dbSelectArea("HWB")
	oJson["transfers"] := JsonObject():New()
	If FieldPos("HWB_QTRENT") > 0 .And. FieldPos("HWB_QTRSAI") > 0
    	getTransf(cTicket, oJson["transfers"], cProdDe, cProdAte)
	EndIf
	dbclosearea()
	fillDates(oJson)

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .T.)
		aAdd(aResult, oJson:toJSON())
		aAdd(aResult, 400)
	EndIf
	aSize(aFiliais, 0)

	aSize(oJson["periods"], 0)
	aSize(oJson["items"], 0)

	FreeObj(oJson)
	oJson := Nil

Return aResult


/*/{Protheus.doc} fillDates
Função responsável por preencher as datas que não tem resultado do MRP para cada produto.
@type  Function
@author douglas.heydt
@since 06/09/2021
@version P12.1.30
@param 01 oJson, JSON, Json contendo os resultados do MRP
/*/
Static Function fillDates(oJson)

	Local cPeriod    := ""
	Local cPrevDate  := ""
	Local nFirstDate := 0
	Local nIndPer    := 2// indice inicia no 2 pois a primeira posição é o identificar 'Períodos'
	Local nIndRes    := 1
	Local nTotRes    := Len(oJson["items"])
	Local nTotPer    := Len(oJson["periods"])

	For nIndRes := 1 To nTotRes
		For nIndPer := 2 To nTotPer
			cPeriod := oJson["periods"][nIndPer]
			IF !oJson["items"][nIndRes]["results"][N_POS_ESTOQUE]:HasProperty(cPeriod)
				If nIndPer == 2
					nFirstDate := getFrstDat(oJson, nIndRes)
					oJson["items"][nIndRes]["results"][N_POS_ESTOQUE    ][cPeriod] := oJson["items"][nIndRes]["results"][N_POS_ESTOQUE][nFirstDate]
					oJson["items"][nIndRes]["results"][N_POS_SALDO_FINAL][cPeriod] := oJson["items"][nIndRes]["results"][N_POS_ESTOQUE][nFirstDate]
				Else
					cPrevDate := oJson["periods"][nIndPer -1]
					oJson["items"][nIndRes]["results"][N_POS_ESTOQUE    ][cPeriod] := oJson["items"][nIndRes]["results"][N_POS_SALDO_FINAL][cPrevDate] + (oJson["items"][nIndRes]["results"][N_POS_NECESSIDADE][cPrevDate] - oJson["items"][nIndRes]["results"][N_POS_QUANT_PMP][cPrevDate])
					oJson["items"][nIndRes]["results"][N_POS_SALDO_FINAL][cPeriod] := oJson["items"][nIndRes]["results"][N_POS_ESTOQUE    ][cPeriod]
				EndIf

				oJson["items"][nIndRes]["results"][N_POS_ENTRADAS       ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_SAIDAS         ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_TRANSF_ENTRADA ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_TRANSF_SAIDA   ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_SAIDA_ESTRUTURA][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_SUBSTITUICAO   ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_NECESSIDADE    ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_VALOR_NECESS   ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_VALOR_ESTOQUE  ][cPeriod] := 0
				oJson["items"][nIndRes]["results"][N_POS_QUANT_PMP      ][cPeriod] := 0
			EndIf
		Next nIndPer
	Next nIndRes
Return


/*/{Protheus.doc} getFrstDat
Retorna a primeira data com resultados no array de resultados do MRP para um produto
@type  Function
@author douglas.heydt
@since 06/09/2021
@version P12.1.30
@param 01 oJson   , JSON    , Json contendo os resultados do MRP
@param 02 nProdPos, numérico, Posição do produto no array de resultados
@return cFirstDate, caracter, primeira data do produto que tem resultado
/*/
Static Function getFrstDat(oJson, nProdPos)

	Local cFirstDate := ""
	Local nIndex     := 2 // indice inicia no 2 pois a primeira posição é o identificar 'Períodos'

	For nIndex := 2 To Len(oJson["periods"])
		IF oJson["items"][nProdPos]["results"][N_POS_ESTOQUE         ]:HasProperty(oJson["periods"][nIndex])
			cFirstDate := oJson["periods"][nIndex]
			Exit
		EndIf
	Next nIndex

Return cFirstDate

/*/{Protheus.doc} getPeriods
Busca os períodos resultantes no cálculo do MRP
@type  Function
@author douglas.heydt
@since 06/09/2021
@version P12.1.30
@param 01 cTicket, Caracter, ticket MRP dos quais serão buscados os período
@return aPeriods, Array, Array com os periodos do ticket informado
/*/
Function getPeriods(cTicket)
	Local aPeriods := {}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""

	cQuery := " select DISTINCT HWB_DATA from "+RetSqlName("HWB")+" where HWB_TICKET = '"+cTicket+"' ORDER BY HWB_DATA"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	aAdd(aPeriods, STR0025)//"Período"

	WHILE (cAliasQry)->(!Eof())
		aAdd(aPeriods, (cAliasQry)->HWB_DATA)
		(cAliasQry)->(dbSkip())
	END
	(cAliasQry)->(dbCloseArea())

return aPeriods

/*/{Protheus.doc} getTransf
Busca todas as transferencias realizadas no mesmo ticket
@type  Function
@author douglas.heydt
@since 20/09/2021
@version P12.1.30
@param 01 cTicket, Caracter, ticket MRP dos quais serão buscadas as transferencias
@param 02 oJson, Obejct, objeto json que irá conter as transferencias
@param 03 cProdDe  , Caracter, código inicial do filtro de produto
@param 04 cProdAte , Caracter, código final do filtro de produto
@param 05 nTpCusto , Numeral, tipo do custo de produto
/*/
Function getTransf(cTicket, oJson, cProdDe, cProdAte)

	Local aTransfers := {}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nPos       := 0

	cQuery := " SELECT HWB_FILIAL, HWB_TICKET, HWB_DATA, HWB_PRODUT, HWB_QTRENT, 0 AS HWB_QTRSAI "
	cQuery += " FROM "+RetSqlName("HWB")+" "
	cQuery += " WHERE HWB_TICKET = '"+cTicket+"'  AND  HWB_QTRENT > 0 "
	If !Empty(cProdDe)
		cQuery += " AND HWB_PRODUT >= '"+cProdDe+"'"
	EndIf
	If !Empty(cProdAte)
		cQuery += " AND HWB_PRODUT <= '"+cProdAte+"'"
	EndIf
	cQuery += " UNION "
	cQuery += " SELECT HWB_FILIAL, HWB_TICKET, HWB_DATA, HWB_PRODUT, 0 AS HWB_QTRENT, HWB_QTRSAI "
	cQuery += " FROM "+RetSqlName("HWB")+"  "
	cQuery += " WHERE HWB_TICKET = '"+cTicket+"'  AND HWB_QTRSAI > 0 "
	If !Empty(cProdDe)
		cQuery += " AND HWB_PRODUT >= '"+cProdDe+"'"
	EndIf
	If !Empty(cProdAte)
		cQuery += " AND HWB_PRODUT <= '"+cProdAte+"'"
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	WHILE (cAliasQry)->(!Eof())
		If 	oJson[(cAliasQry)->HWB_PRODUT] == Nil
			oJson[(cAliasQry)->HWB_PRODUT] := {}
		EndIf

		aAdd(oJson[(cAliasQry)->HWB_PRODUT], JsonObject():New())
		nPos := Len(oJson[(cAliasQry)->HWB_PRODUT])
		oJson[(cAliasQry)->HWB_PRODUT][nPos]["HWB_FILIAL"] := (cAliasQry)->HWB_FILIAL+'-'+FwFilialName(cEmpAnt,(cAliasQry)->HWB_FILIAL)
		oJson[(cAliasQry)->HWB_PRODUT][nPos]["HWB_DATA"]   := (cAliasQry)->HWB_DATA
		oJson[(cAliasQry)->HWB_PRODUT][nPos]["HWB_PRODUT"] := (cAliasQry)->HWB_PRODUT
		oJson[(cAliasQry)->HWB_PRODUT][nPos]["HWB_QTRSAI"] := (cAliasQry)->HWB_QTRSAI
		oJson[(cAliasQry)->HWB_PRODUT][nPos]["HWB_QTRENT"] := (cAliasQry)->HWB_QTRENT

		(cAliasQry)->(dbSkip())
	END
	(cAliasQry)->(dbCloseArea())

return aTransfers

/*/{Protheus.doc} getProds
Retorna o Resultado de todos os produtos para um ticket MRP

@type Function
@author douglas.heydt
@since 03/05/2021
@version P12.1.27
@param 01 cTicket , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 cProduct, Caracter, Código do produto
@param 03 cProdDe , Caracter, Código inicial do filtro de produto
@param 04 cProdAte, Caracter, Código final do filtro de produto
@param 05 nTpCusto, Numeral , Tipo do custo de produto
@param 06 cIdOpc  , Caracter, ID Opcional do produto
@param 07 lAllFils, Lógico  , Indica se deve retornar as informações dos produtos de todas as filiais
@return    aResult, Array   , Array com as informacoes da requisicao
/*/
Function getProds(cTicket, cProduct, cProdDe, cProdAte, nTpCusto, cIdOpc, lAllFils)
	Local aFiliais   := {}
	Local aResult 	 := {.F., EncodeUTF8(STR0016), 400} //"Não existem registros para atender os filtros informados"
	Local cAliasQry  := GetNextAlias()
	Local cAglutina  := ""
	Local cArqProd   := arqProdTkt(cTicket)
	Local cBanco     := Upper(TCGETDB())
	Local cQuery     := ""
	Local cFilPrinci := ""
	Local lAddAglut  := .F.
	Local lAgluMrp   := .F.
	Local lDefInHWD  := .F.
	Local lMultiEmp  := .F.
	Local nPos       := 0
	Local oDominio   := Nil
	Local oJson      := JsonObject():New()
	Local oParametro := Nil

	Default cIdOpc   := ""
	Default lAllFils := .F.

	lDefInHWD := !Empty(GetSx3Cache("HWD_DEFAUL", "X3_TAMANHO"))

	DbSelectArea("HWB")
	lAgluMrp := (FieldPos("HWB_AGLPRD") > 0)

	If lAgluMrp .And. _oDescAgl == Nil
		_oDescAgl := JsonObject():New()
		_oDescAgl["0"] := ""
		_oDescAgl["1"] := STR0058 //"Diário"
		_oDescAgl["2"] := STR0059 //"Semanal"
		_oDescAgl["3"] := STR0060 //"Quinzenal"
		_oDescAgl["4"] := STR0061 //"Mensal"
		_oDescAgl["5"] := STR0076 //"Semestral"
	EndIf

	lMultiEmp := MrpTickeME(cTicket, .T., @oParametro, @oDominio, aFiliais) .And. Len(aFiliais) > 0
	If lMultiEmp
		cFilPrinci := RTrim(oParametro["branchCentralizing"])
	Else
		cFilPrinci := xFilial("HWB")
	EndIf

	cQuery := "SELECT DISTINCT HWB.HWB_FILIAL branchId,"
	cQuery +=                " HWA.HWA_PROD   product,"
	cQuery +=                " HWA.HWA_DESC   productDescription,"
	cQuery +=                " HWA.HWA_TIPO   productType,"
	cQuery +=                " HWB.HWB_IDOPC  optionalId,"

	If cArqProd == "SBZ"
		cQuery += " COALESCE(HWE.HWE_LOCPAD, HWA.HWA_LOCPAD) warehouse,"
		cQuery += " COALESCE(HWE.HWE_QE, HWA.HWA_QE) packing,"
		cQuery += " COALESCE(HWE.HWE_PE, HWA.HWA_PE) deliveryLeadTime,"
		cQuery += " CASE COALESCE(HWE.HWE_TIPE, HWA.HWA_TIPE)"
		cQuery +=    " WHEN '1' THEN '" + STR0028 + "'"
		cQuery +=    " WHEN '2' THEN '" + STR0029 + "'"
		cQuery +=    " WHEN '3' THEN '" + STR0030 + "'"
		cQuery +=    " WHEN '4' THEN '" + STR0031 + "'"
		cQuery +=    " WHEN '5' THEN '" + STR0032 + "'"
		cQuery +=    " ELSE '-'"
		cQuery += " END deadlineType,"
		cQuery += " COALESCE(HWE.HWE_LM, HWA.HWA_LM) minimumLotSize,"
		cQuery += " COALESCE(HWE.HWE_LE, HWA.HWA_LE) economicLotSize,"
		cQuery += " COALESCE(HWE.HWE_ESTSEG, HWA.HWA_ESTSEG) safetyStock,"
		cQuery += " COALESCE(HWE.HWE_EMIN, HWA.HWA_EMIN) orderPoint,"
	Else
		cQuery += " HWA.HWA_LOCPAD warehouse,"
		cQuery += " HWA.HWA_QE packing,"
		cQuery += " HWA.HWA_PE deliveryLeadTime,"
		cQuery += " CASE HWA.HWA_TIPE"
		cQuery +=    " WHEN '1' THEN '" + STR0028 + "'"
		cQuery +=    " WHEN '2' THEN '" + STR0029 + "'"
		cQuery +=    " WHEN '3' THEN '" + STR0030 + "'"
		cQuery +=    " WHEN '4' THEN '" + STR0031 + "'"
		cQuery +=    " WHEN '5' THEN '" + STR0032 + "'"
		cQuery +=    " ELSE '-'"
		cQuery += " END deadlineType,"
		cQuery += " HWA.HWA_LM minimumLotSize,"
		cQuery += " HWA.HWA_LE economicLotSize,"
		cQuery += " HWA.HWA_ESTSEG safetyStock,"
		cQuery += " HWA.HWA_EMIN orderPoint,"
	EndIf

	cQuery += " HWA.HWA_UM unity"

	If lDefInHWD
		cQuery += ", HWD.HWD_DEFAUL opcIsDefault"
	EndIf

	If lAgluMrp
		If lAllFils
			cQuery +=", SMI.MI_AGLUMRP aglMRP"
			If validSMI()
				cQuery +=", SMI.MI_TRANSF transferencia "
				cQuery +=", SMI.MI_FILCOM filCompras "
				cQuery +=", SMI.MI_LEADTR transferLeadTime "
			EndIf
			If fldLtMinTr()
				cQuery +=", SMI.MI_LMTRANS loteMinTransf "
			EndIf
		Else
			cQuery +=",( SELECT"
			If "MSSQL" $ cBanco //Tratativa para retornar 1° registro encontrado na query.
				cQuery += " TOP 1"
			EndIf
			cQuery += " HWB_AGLPRD"
			cQuery += " FROM " +RetSqlName("HWB") + " HWBAGL"

			If lMultiEmp
				cQuery += " WHERE HWBAGL.HWB_FILIAL " + oDominio:oMultiEmp:queryFilial("HWB", "", .F.)
			Else
				cQuery += " WHERE HWBAGL.HWB_FILIAL = '" + cFilPrinci + "'"
			EndIf

			cQuery += " AND HWBAGL.HWB_TICKET = '" + cTicket + "'"
			cQuery += " AND HWBAGL.HWB_PRODUT = HWB.HWB_PRODUT"
			cQuery += " AND HWBAGL.HWB_IDOPC  = HWB.HWB_IDOPC"
			cQuery += " AND HWBAGL.HWB_AGLPRD NOT IN(' ', '0')"

			If cBanco == "ORACLE" //Tratativa para retornar 1° registro encontrado na query.
				cQuery += " AND ROWNUM = 1"
			EndIf
			If cBanco == "POSTGRES" //Tratativa para retornar 1° registro encontrado na query.
				cQuery += " LIMIT 1"
			EndIf
			cQuery += ") aglMRP"
			If validSMI()
				cQuery += ", '' transferencia "
				cQuery += ", '' filCompras "
				cQuery += ", '' transferLeadTime "
			EndIf
			If fldLtMinTr()
				cQuery +=", '' loteMinTransf "
			EndIf
		EndIf
	EndIf

	cQuery += " FROM " + RetSqlName("HWA") + " HWA"
	cQuery += " LEFT JOIN " + RetSqlName("HWB") + " HWB"
	cQuery +=   " ON HWA.HWA_PROD = HWB.HWB_PRODUT"
	cQuery +=  " AND HWB.D_E_L_E_T_ = ' '"
	cQuery +=  " AND HWB.HWB_TICKET = '" + cTicket + "'"
	If !Empty(cIdOpc)
		cQuery += " AND HWB_IDOPC = '" + RTrim(cIdOpc) + "' "
	EndIf
	If lMultiEmp .And. lAllFils
		cQuery += " AND HWB.HWB_FILIAL " + oDominio:oMultiEmp:queryFilial("HWB", "", .F.)
		If lAgluMrp
			cQuery += " LEFT JOIN " +RetSqlName("SMI") + " SMI" + ;
			             " ON SMI.MI_FILIAL  = HWB.HWB_FILIAL"   + ;
			            " AND SMI.MI_PRODUTO = HWB.HWB_PRODUT"   + ;
			            " AND SMI.D_E_L_E_T_ = ' '"
		EndIf
	Else
		cQuery += " AND HWB.HWB_FILIAL = '" + xFilial("HWB", cFilPrinci) + "'"
	EndIf

	If cArqProd == "SBZ"
		cQuery += " LEFT JOIN " + RetSqlName("HWE") + " HWE"
		cQuery +=   " ON ( ( HWB.HWB_FILIAL IS NOT NULL AND HWE.HWE_FILIAL = HWB.HWB_FILIAL) "
		cQuery +=    " OR (HWB.HWB_FILIAL IS NULL AND HWE.HWE_FILIAL = '"+ xFilial("HWE", cFilPrinci) +"'))"
		cQuery +=  " AND HWE.HWE_PROD = HWB.HWB_PRODUT"
		cQuery +=  " AND HWE.D_E_L_E_T_ = ' '"
	EndIf

	If lDefInHWD
		cQuery += " LEFT OUTER JOIN " + RetSqlName("HWD") + " HWD"
		cQuery +=   " ON HWD.HWD_TICKET = HWB.HWB_TICKET"
		cQuery +=  " AND HWD.HWD_FILIAL = HWB.HWB_FILIAL"
		cQuery +=  " AND HWD.HWD_KEYMAT = HWB.HWB_IDOPC"
	EndIf

	If lMultiEmp .And. lAllFils
		cQuery += " WHERE HWA.HWA_FILIAL " + oDominio:oMultiEmp:queryFilial("HWA", "", .F.)
	Else
		cQuery += " WHERE HWA.HWA_FILIAL = '" + xFilial("HWA", cFilPrinci) + "'"
	EndIf
	cQuery +=       " AND HWA.D_E_L_E_T_ = ' '"


	If !Empty(cProduct)
		cQuery +=   " AND HWA.HWA_PROD = '" + cProduct + "'"
    Else
		If !Empty(cProdDe)
		    cQuery += " AND HWA.HWA_PROD >= '" + cProdDe + "'"
		EndIf
		If !Empty(cProdAte)
			cQuery += " AND HWA.HWA_PROD <= '" + cProdAte + "'"
		EndIf
	EndIf

	cQuery += " ORDER BY branchId, product"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	oJson["items"] := {}
	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"], JsonObject():New())
        nPos++

		oJson["items"][nPos]["branchId"          ] := RTRIM((cAliasQry)->branchId)
		oJson["items"][nPos]["product"           ] := RTRIM((cAliasQry)->product)
		oJson["items"][nPos]["productDescription"] := AllTrim((cAliasQry)->productDescription)
		oJson["items"][nPos]["productType"       ] := (cAliasQry)->productType
		oJson["items"][nPos]["packing"           ] := (cAliasQry)->packing
		oJson["items"][nPos]["deliveryLeadTime"  ] := (cAliasQry)->deliveryLeadTime
		oJson["items"][nPos]["deadlineType"      ] := (cAliasQry)->deadlineType
		oJson["items"][nPos]["warehouse"         ]  := (cAliasQry)->warehouse

		If Empty(oJson["items"][nPos]["branchId"])
			oJson["items"][nPos]["branchId"] := cFilPrinci
		EndIf

		If Empty((cAliasQry)->optionalId)
			oJson["items"][nPos]["optionalSelected"] := STR0054 //"Não"
			oJson["items"][nPos]["hasOptional"] := .F.
		Else
			oJson["items"][nPos]["optionalSelected"] := STR0053 //"Sim"
			oJson["items"][nPos]["hasOptional"] := .T.
		EndIf
		oJson["items"][nPos]["optional"] := (cAliasQry)->optionalId

		oJson["items"][nPos]["minimumLotSize" ] := (cAliasQry)->minimumLotSize
		oJson["items"][nPos]["economicLotSize"] := (cAliasQry)->economicLotSize

		If !lDefInHWD .Or. (lDefInHWD .And. (cAliasQry)->opcIsDefault == "S") .Or. Empty((cAliasQry)->opcIsDefault)
			oJson["items"][nPos]["safetyStock"] := (cAliasQry)->safetyStock
			oJson["items"][nPos]["orderPoint" ] := (cAliasQry)->orderPoint
		Else
			oJson["items"][nPos]["safetyStock"] := 0
			oJson["items"][nPos]["orderPoint" ] := 0
		EndIf

		oJson["items"][nPos]["unity"] := (cAliasQry)->unity
		oJson["items"][nPos]["value"] := GetCost((cAliasQry)->product, nTpCusto)

		If lAgluMrp .And. !Empty((cAliasQry)->aglMrp)
			cAglutina := (cAliasQry)->aglMrp
			If lAllFils
				cAglutina := cValToChar( MrpDados_Carga_Engenharia():tipoPeriodoAglutinaProduto(cAglutina) )
			Endif

			oJson["items"][nPos]["agglutinateMRP"] := _oDescAgl[cAglutina]
			lAddAglut := .T.
		Else
			oJson["items"][nPos]["agglutinateMRP"] := ""
		EndIf

		If validSMI()
			oJson["items"][nPos]["transferencia"   ] := labelTran((cAliasQry)->transferencia)
			oJson["items"][nPos]["filCompras"      ] := (cAliasQry)->filCompras
			oJson["items"][nPos]["transferLeadTime"] := (cAliasQry)->transferLeadTime
		EndIf

		If fldLtMinTr()
			oJson["items"][nPos]["loteMinTransf"] := (cAliasQry)->loteMinTransf
		EndIf

		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	oJson["headers"] := {}
	addHeader(oJson["headers"], lAddAglut)

	oJson["usesProductIndicator"] := cArqProd == "SBZ"

	If !Empty(nTpCusto) .And.ExistBlock("MRPEDITEXP")
		ExecBlock("MRPEDITEXP", .F., .F., {cTicket, oJson})
	EndIf

	If Len(oJson["items"]) > 0
		aResult[1] := .T.
		aResult[2] := PCPEncUtf8(oJson:toJson())
		aResult[3] := 200
	EndIf

	If lMultiEmp
		oDominio:oDados:destruir()
		FreeObj(oDominio)
		FreeObj(oParametro)
	EndIf

	aSize(oJson["items"], 0)
	FreeObj(oJson)
	aSize(aFiliais, 0)

Return aResult

/*/{Protheus.doc} addHeader
Preenche o array com o cabeçalho

@type Static Function
@author marcelo.neumann
@since 08/08/2022
@version P12
@param 01 aHeaders , Array, Header a ser preenchido
@param 02 lAddAglut, Logic, Indica se deve adicionar opção de "Aglutina MRP"
/*/
Static Function addHeader(aHeaders, lAddAglut)
	Local nIndex := 0

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "product"
	aHeaders[nIndex]["label"] := STR0035 //"Produto"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "productDescription"
	aHeaders[nIndex]["label"] := STR0036 //"Descrição"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "productType"
	aHeaders[nIndex]["label"] := STR0037 //"Tipo"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "packing"
	aHeaders[nIndex]["label"] := STR0038 //"Embalagem"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "deliveryLeadTime"
	aHeaders[nIndex]["label"] := STR0039 //"Lead Time"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "deadlineType"
	aHeaders[nIndex]["label"] := STR0040 //"Tipo Prazo"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "warehouse"
	aHeaders[nIndex]["label"] := STR0041 //"Armazém"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "optionalSelected"
	aHeaders[nIndex]["label"] := STR0042 //"Opcional"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "minimumLotSize"
	aHeaders[nIndex]["label"] := STR0043 //"Lote Mínimo"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "economicLotSize"
	aHeaders[nIndex]["label"] := STR0044 //"Lote Econômico"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "safetyStock"
	aHeaders[nIndex]["label"] := STR0045 //"Estoque Segurança"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "orderPoint"
	aHeaders[nIndex]["label"] := STR0046 //"Ponto Pedido"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "unity"
	aHeaders[nIndex]["label"] := STR0047 //"Unidade de Medida"

	aAdd(aHeaders, JsonObject():New())
	nIndex++
	aHeaders[nIndex]["id"]    := "value"
	aHeaders[nIndex]["label"] := STR0048 //"Valor"

	If lAddAglut
		aAdd(aHeaders, JsonObject():New())
		nIndex++
		aHeaders[nIndex]["id"]    := "agglutinateMRP"
		aHeaders[nIndex]["label"] := STR0062 //"Aglutina MRP"
	EndIf

Return Nil

/*/{Protheus.doc} GetPrdCost
Busca o custo de um produto considerando o parametro MV_CUSTPRD
@type  Function
@author douglas.heydt
@since 06/09/2021
@version P12.1.30
@param 01 cProduct, Caracter, produto que terá o custo buscado
@param 02 nTpCusto , Numeral, tipo do custo de produto
/*/
Function GetCost(cProduct, nTpCusto)
	Local aAreaSB1 	 := SB1->(GetArea())
	Local nCusto     := 0
	Local nTipoCusto := Iif(!Empty(nTpCusto), nTpCusto, SuperGetMv("MV_CUSTPRD",.F.,1))

	cProduct := Padr(cProduct, GetSx3Cache("B1_COD", "X3_TAMANHO"))
	SB1->(MsSeek(xFilial("SB1") + cProduct))
	If nTipoCusto == 1
		nCusto := RetFldProd(cProduct,"B1_CUSTD")
	ElseIf nTipoCusto == 2
		nCusto := PegaCmAtu(cProduct, RetFldProd(cProduct,"B1_LOCPAD"))[1]
	ElseIf nTipoCusto == 3
		nCusto := RetFldProd(cProduct,"B1_UPRC")
	EndIf

	RestArea( aAreaSB1 )

Return nCusto

/*/{Protheus.doc} GET PERIODS api/pcp/v1/mrpdata/periods/{ticket}
Retorna os períodos considerados em uma rodada do MRP

@type WSMETHOD
@author renan.roeder
@since 14/01/2022
@version P12.1.37
@param 01 ticket  , Caracter, Codigo único do processo
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PERIODS PATHPARAM ticket WSSERVICE mrpdata
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	aReturn := getPerRes( Self:ticket)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet


/*/{Protheus.doc} getPerRes
Monta o json que retornará os períodos de uma rodada do MRP
@type  Function
@author renan.roeder
@since 14/01/2022
@version P12.1.37
@param 01 cTicket, Caracter, ticket MRP
@return aResult, Array, Array com as informacoes da requisicao
/*/
Function getPerRes(cTicket)
	Local aResult    := {}
	Local aParMrp    := {}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nPosType   := 0
	Local nPosRast   := 0
	Local nContPer   := 0
	Local oJson      := JsonObject():New()

	loadParam(cTicket, @aParMrp)
	nPosType := aScan(aParMrp, {|x| AllTrim(x[2][3]) == "productionOrderType"})
	nPosRast := aScan(aParMrp, {|x| AllTrim(x[2][3]) == "lRastreiaEntradas"})

	oJson["usaRast"] := .F.
	If nPosRast > 0 .And. aParMrp[nPosRast][2][4] == "1"
		oJson["usaRast"] := .T.
	EndIf

	cQuery := " select DISTINCT HWB_DATA from "+RetSqlName("HWB")+" where HWB_TICKET = '"+cTicket+"' ORDER BY HWB_DATA"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	oJson["items"] := {}
	While (cAliasQry)->(!Eof())
		nContPer++
		aAdd(oJson["items"], JsonObject():New())
		oJson["items"][nContPer]["period"] := convDate((cAliasQry)->HWB_DATA, 4)
		oJson["items"][nContPer]["type"]   := aParMrp[nPosType][2][4]
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If Len(oJson["items"]) > 0
		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))
		aAdd(aResult, 200)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJson())
		aAdd(aResult, 400)
	EndIf

	aSize(aParMrp,0)
    aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET SUBSALT api/pcp/v1/mrpdata/subst/alt
Recupera os produtos alternativos a partir de um produto original

@type WSMETHOD
@author lucas.franca
@since 28/10/2022
@version P12
@param 01 ticket      , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 product     , Caracter, Produto substituído
@param 03 optionalId  , Caracter, ID do Opcional
@param 04 periodFrom  , Caracter, data inicial de busca de substituições
@param 05 periodTo    , Caracter, data final de busca de substituições
@parma 06 page        , number  , Número da página para consulta
@parma 07 pageSize    , number  , Quantidade de registros por página
@return lRet, Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET SUBSALT QUERYPARAM ticket, product, optionalId, periodFrom, periodTo, Page, PageSize  WSSERVICE mrpdata
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")
	//Chama a funcao para retornar os dados.
	aReturn := getSubsAlt(Self:ticket, Self:product, Self:optionalId, Self:periodFrom, Self:periodTo, Self:Page, Self:PageSize)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getSubsAlt
Recupera os produtos alternativos a partir de um produto original

@type  Static Function
@author lucas.franca
@since 28/10/2022
@version P12
@param 01 cTicket     , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 cProduto    , Caracter, Produto substituído
@param 03 cIdOpc      , Caracter, ID do Opcional
@param 04 cPerDe      , Caracter, data inicial de busca de substituições
@param 05 cPerAte     , Caracter, data final de busca de substituições
@parma 06 nPage       , number  , Número da página para consulta
@parma 07 nPageSize   , number  , Quantidade de registros por página
@return aResult, Array, Array com os dados da consulta
/*/
Static Function getSubsAlt(cTicket, cProduto, cIdOpc, cPerDe, cPerAte, nPage, nPageSize)
	Local aResult   := {.F., "", 204}
	Local aValFil   := getFilMRP(cTicket, "HWC")
	Local cAlias    := ""
	Local cBanco    := AllTrim(TcGetDB())
	Local cQuery    := ""
	Local lUsaME    := Len(aValFil) > 1
	Local nIndex    := 0
	Local nStart    := 0
	Local oExec     := Nil
	Local oJson     := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	cQuery := " SELECT HWC.HWC_FILIAL,"
	cQuery +=        " HWC.HWC_PRODUT,"
	cQuery +=        " HWC.HWC_DATA,"
	cQuery +=        " HWC.HWC_DOCPAI,"
	cQuery +=        " HWC.HWC_QTSBVL,"
	cQuery +=        " HWC.HWC_QTSUBS,"
	cQuery +=        " HWC.HWC_QTEMPE,"
	cQuery +=        " HWC.HWC_QTNECE"
	cQuery +=   " FROM " + RetSqlName("HWC") + " HWC"
	cQuery +=  " WHERE HWC.HWC_FILIAL IN (?)"
	cQuery +=    " AND HWC.HWC_TICKET = ?"
	cQuery +=    " AND HWC.HWC_DATA  >= ?"
	cQuery +=    " AND HWC.HWC_DATA  <= ?"
	cQuery +=    " AND HWC.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND HWC.HWC_CHVSUB IN(SELECT "

	If cBanco == "ORACLE"
		cQuery += " RPAD("//RPAD para padronizar o tamanho da string para banco ORACLE
	EndIf

	//Caso seja Multi-empresa, concatena o código da filial a chave do registro do produto original
	If lUsaME .And. cBanco == "POSTGRES"
		//Para banco POSTGRES utiliza o comando CONCAT
		cQuery +=                                  " TRIM(CONCAT(HWC_ORI.HWC_FILIAL, "
	ElseIf lUsaME
		//Para demais bancos concatena com || ou +
		cQuery +=                                  " HWC_ORI.HWC_FILIAL || "
	EndIf

	If Empty(cIdOpc)
		cQuery +=                                  " HWC_ORI.HWC_CHAVE"
	Else
		//Quando existe ID Opcional, adiciona o IDOPC antes do número do período no valor da coluna HWC_CHAVE.
		//SUBSTR de HWC_CHAVE, contendo até o caractere onde está posicionado o número do período
		cQuery +=                                  " SUBSTR(HWC_CHAVE, 1, LENGTH(RTRIM(HWC_CHAVE)) - "
		cQuery +=                                                       " LENGTH(RTRIM(LTRIM( REPLACE( HWC_CHAVE, RTRIM(HWC_PRODUT),'')))))"
		//Concatena o separador | com o HWC_IDOPC
		cQuery +=                                  " || '|' || RTRIM(HWC_IDOPC) "
		//Concatena o número do período após o HWC_IDOPC
		cQuery +=                                  " || LTRIM(REPLACE(HWC_CHAVE, RTRIM(HWC_PRODUT),''))"
	EndIf

	//Se multi-empresa e banco POSTGRES, fecha o ) do comando CONCAT e do TRIM.
	If lUsaME .And. cBanco == "POSTGRES"
		cQuery += "))"
	EndIf

	If cBanco == "ORACLE"
		cQuery += ", LENGTH(HWC_CHAVE))" //Parâmetro do RPAD com o tamanho da string.
	EndIf

	cQuery +=                            " FROM " + RetSqlName("HWC") + " HWC_ORI"
	cQuery +=                           " WHERE HWC_ORI.HWC_FILIAL = HWC.HWC_FILIAL"
	cQuery +=                             " AND HWC_ORI.HWC_TICKET = HWC.HWC_TICKET"
	cQuery +=                             " AND HWC_ORI.HWC_DATA   = HWC.HWC_DATA"
	cQuery +=                             " AND HWC_ORI.HWC_PRODUT = ?"
	cQuery +=                             " AND HWC_ORI.HWC_IDOPC  = ?"
	cQuery +=                             " AND HWC_ORI.D_E_L_E_T_ = ' ')"
	cQuery +=  " ORDER BY HWC.HWC_DATA, HWC.HWC_FILIAL, HWC.HWC_PRODUT"

	If "MSSQL" $ cBanco
		//Faz adequações na query para o banco SQL SERVER.
		cQuery := StrTran(cQuery, "||", "+") //Troca concatenação
		cQuery := StrTran(cQuery, "LENGTH", "LEN") //Troca função LENGTH por LEN
		cQuery := StrTran(cQuery, "SUBSTR", "SUBSTRING") //Troca função SUBSTR por SUBSTRING
	EndIf

	oExec  := FwExecStatement():New(cQuery)

	If Empty(cPerDe)
		cPerDe := " "
	EndIf
	If Empty(cPerAte)
		cPerAte := "ZZZZZZZZ"
	EndIf
	If Empty(cIdOpc)
		cIdOpc := " "
	EndIf

	cPerDe  := convDate(cPerDe, 2)
	cPerAte := convDate(cPerAte, 2)

	oExec:SetIn(1    , aValFil ) //HWC_FILIAL IN(xxx)
	oExec:SetString(2, cTicket ) //HWC_TICKET = cTicket
	oExec:SetString(3, cPerDe  ) //HWC_DATA >= cPerDe
	oExec:SetString(4, cPerAte ) //HWC_DATA <= cPerAte
	oExec:SetString(5, cProduto) //HWC_PRODUT = cProduto
	oExec:SetString(6, cIdOpc  ) //HWC_IDOPC = cIdOpc

	cAlias := oExec:OpenAlias()

	TcSetField(cAlias, 'HWC_DATA'  , 'D', GetSx3Cache("HWC_DATA"  , "X3_TAMANHO"), 0)
	TcSetField(cAlias, 'HWC_QTSBVL', 'N', GetSx3Cache("HWC_QTSBVL", "X3_TAMANHO"), GetSx3Cache("HWC_QTSBVL", "X3_DECIMAL"))
	TcSetField(cAlias, 'HWC_QTSUBS', 'N', GetSx3Cache("HWC_QTSUBS", "X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS", "X3_DECIMAL"))
	TcSetField(cAlias, 'HWC_QTEMPE', 'N', GetSx3Cache("HWC_QTEMPE", "X3_TAMANHO"), GetSx3Cache("HWC_QTEMPE", "X3_DECIMAL"))
	TcSetField(cAlias, 'HWC_QTNECE', 'N', GetSx3Cache("HWC_QTNECE", "X3_TAMANHO"), GetSx3Cache("HWC_QTNECE", "X3_DECIMAL"))

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}
	nIndex         := 0
	While (cAlias)->(!Eof())

		nIndex++
		aAdd(oJson["items"], JsonObject():New())
		oJson["items"][nIndex]["branchId"    ] := (cAlias)->HWC_FILIAL
		oJson["items"][nIndex]["product"     ] := (cAlias)->HWC_PRODUT
		oJson["items"][nIndex]["period"      ] := convDate((cAlias)->HWC_DATA, 1)
		oJson["items"][nIndex]["document"    ] := (cAlias)->HWC_DOCPAI
		oJson["items"][nIndex]["originalQty" ] := -(cAlias)->HWC_QTSBVL
		oJson["items"][nIndex]["substitution"] := -(cAlias)->HWC_QTSUBS
		oJson["items"][nIndex]["allocation"  ] := (cAlias)->HWC_QTEMPE
		oJson["items"][nIndex]["necessity"   ] := (cAlias)->HWC_QTNECE

		(cAlias)->(dbSkip())

		//Verifica tamanho da página
		If nIndex >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAlias)->(!Eof())

	(cAlias)->(dbCloseArea())
	oExec:Destroy()
	FwFreeObj(oExec)

	aResult[2] := EncodeUTF8(oJson:toJson())
	If nIndex > 0
		aResult[1] := .T.
		aResult[3] := 200
	EndIf
	FwFreeObj(oJson)

	aSize(aValFil, 0)

Return aResult

/*/{Protheus.doc} GET SUBSORI api/pcp/v1/mrpdata/subst/ori
Recupera os produtos originais a partir de um produto alternativo

@type WSMETHOD
@author lucas.franca
@since 28/10/2022
@version P12
@param 01 ticket      , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 product     , Caracter, Produto substituto
@param 03 periodFrom  , Caracter, data inicial de busca de substituições
@param 04 periodTo    , Caracter, data final de busca de substituições
@parma 05 page        , number  , Número da página para consulta
@parma 06 pageSize    , number  , Quantidade de registros por página
@return lRet, Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET SUBSORI QUERYPARAM ticket, product, periodFrom, periodTo, Page, PageSize  WSSERVICE mrpdata
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")
	//Chama a funcao para retornar os dados.
	aReturn := getSubsOri(Self:ticket, Self:product, Self:periodFrom, Self:periodTo, Self:Page, Self:PageSize)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getSubsOri
Recupera os produtos originais a partir de um produto alternativo

@type  Static Function
@author lucas.franca
@since 28/10/2022
@version P12
@param 01 cTicket     , Caracter, Codigo único do processo para fazer a pesquisa
@param 02 cProduto    , Caracter, Produto substituído
@param 03 cPerDe      , Caracter, data inicial de busca de substituições
@param 04 cPerAte     , Caracter, data final de busca de substituições
@parma 05 nPage       , number  , Número da página para consulta
@parma 06 nPageSize   , number  , Quantidade de registros por página
@return aResult, Array, Array com os dados da consulta
/*/
Static Function getSubsOri(cTicket, cProduto, cPerDe, cPerAte, nPage, nPageSize)
	Local aResult := {.F., "", 204}
	Local aValFil := getFilMRP(cTicket, "HWC")
	Local cAlias  := ""
	Local cBanco  := AllTrim(TcGetDb())
	Local cQuery  := ""
	Local lUsaME  := Len(aValFil) > 1
	Local nIndex  := 0
	Local nStart  := 0
	Local oExec   := Nil
	Local oJson   := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20

	cQuery := " SELECT HWC_ORI.HWC_FILIAL,"
	cQuery +=        " HWC_ORI.HWC_PRODUT,"
	cQuery +=        " HWC_ORI.HWC_DATA,"
	cQuery +=        " HWC_ORI.HWC_DOCPAI,"
	cQuery +=        " HWC_ORI.HWC_QTSUBS QTORIG,"
	cQuery +=        " HWC_ALT.HWC_QTSUBS QTALT"
	cQuery +=   " FROM " + RetSqlName("HWC") + " HWC_ORI"
	cQuery +=  " INNER JOIN " + RetSqlName("HWC") + " HWC_ALT"
	cQuery +=     " ON HWC_ALT.HWC_FILIAL = HWC_ORI.HWC_FILIAL"
	cQuery +=    " AND HWC_ALT.HWC_TICKET = HWC_ORI.HWC_TICKET"
	cQuery +=    " AND HWC_ALT.HWC_DATA   = HWC_ORI.HWC_DATA"
	cQuery +=    " AND HWC_ALT.HWC_PRODUT = ?"
	cQuery +=    " AND HWC_ALT.HWC_DATA  >= ?"
	cQuery +=    " AND HWC_ALT.HWC_DATA  <= ?"
	//Comparação de HWC_CHVSUB com HWC_CHAVE com as tratativas para considerar o IDOPC correto para o HWC_CHAVE.
	cQuery +=    " AND HWC_ALT.HWC_CHVSUB = "

	If cBanco == "ORACLE"
		cQuery += "RPAD(" //RPAD para padronizar o tamanho final da string para banco ORACLE
	EndIf

	//Concatena o código da filial na chave do produto original caso utilize multi-empresa.
	If lUsaME .And. cBanco == "POSTGRES"
		//Para banco POSTGRES, utiliza comando CONCAT
		cQuery += " TRIM(CONCAT(HWC_ORI.HWC_FILIAL,"
	ElseIf lUsaME
		//Para demais bancos, utiliza comando || ou +
		cQuery += " HWC_ORI.HWC_FILIAL || "
	EndIf

	cQuery +=                                  " CASE "
	//Se não tiver IDOPC no produto origem, compara diretamente HWC_ALT.HWC_CHVSUB = HWC_ORI.HWC_CHAVE
	cQuery +=                                  " WHEN HWC_ORI.HWC_IDOPC = ' ' THEN"
	cQuery +=                                       " HWC_ORI.HWC_CHAVE"
	cQuery +=                                  " ELSE"
	//Se tiver IDOPC no produto origem, precisa fazer a comparação com o HWC_ORI.HWC_IDOPC concatenado na coluna HWC_ORI.HWC_CHAVE
	//Pega o HWC_CHAVE sem a informação do período
	cQuery +=                                       " SUBSTR(HWC_ORI.HWC_CHAVE, 1, LENGTH( RTRIM(HWC_ORI.HWC_CHAVE) ) - "
	cQuery +=                                                                    " LENGTH( RTRIM(LTRIM( REPLACE(HWC_ORI.HWC_CHAVE, "
	cQuery +=                                                                                          " RTRIM(HWC_ORI.HWC_PRODUT),'')))))"
	//Concatena o separador | + HWC_IDOPC
	cQuery +=                                       " || '|' || RTRIM(HWC_ORI.HWC_IDOPC)"
	//Concatena o número do período após o IDOPC.
	cQuery +=                                       " || LTRIM(REPLACE(HWC_ORI.HWC_CHAVE, RTRIM(HWC_ORI.HWC_PRODUT),''))"
	cQuery +=                                  " END"

	If lUsaME .And. cBanco == "POSTGRES"
		cQuery += "))" //Se multi-empresa e banco POSTGRES, fecha o ) do comando CONCAT e do TRIM.
	EndIf

	If cBanco == "ORACLE"
		//Parâmetro do RPAD com o tamanho da string.
		cQuery += " ,LENGTH(HWC_ORI.HWC_CHAVE))"
	EndIf
	cQuery +=    " AND HWC_ALT.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE HWC_ORI.HWC_FILIAL IN (?)"
	cQuery +=    " AND HWC_ORI.HWC_TICKET = ?"
	cQuery +=    " AND HWC_ORI.HWC_QTSUBS > 0"
	cQuery +=    " AND HWC_ORI.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY HWC_ORI.HWC_DATA, HWC_ORI.HWC_FILIAL, HWC_ORI.HWC_PRODUT"

	If "MSSQL" $ cBanco
		//Faz adequações na query para o banco SQL SERVER.
		cQuery := StrTran(cQuery, "||", "+") //Troca concatenação
		cQuery := StrTran(cQuery, "LENGTH", "LEN") //Troca função LENGTH por LEN
		cQuery := StrTran(cQuery, "SUBSTR", "SUBSTRING") //Troca função SUBSTR por SUBSTRING
	EndIf

	oExec  := FwExecStatement():New(cQuery)

	If Empty(cPerDe)
		cPerDe := " "
	EndIf
	If Empty(cPerAte)
		cPerAte := "ZZZZZZZZ"
	EndIf

	cPerDe  := convDate(cPerDe, 2)
	cPerAte := convDate(cPerAte, 2)

	oExec:SetString(1, cProduto) //HWC_PRODUT = cProduto
	oExec:SetString(2, cPerDe  ) //HWC_DATA >= cPerDe
	oExec:SetString(3, cPerAte ) //HWC_DATA <= cPerAte
	oExec:SetIn(    4, aValFil ) //HWC_FILIAL IN(xxx)
	oExec:SetString(5, cTicket ) //HWC_TICKET = cTicket

	cAlias := oExec:OpenAlias()

	TcSetField(cAlias, 'HWC_DATA', 'D', GetSx3Cache("HWC_DATA"  , "X3_TAMANHO"), 0)
	TcSetField(cAlias, 'QTORIG'  , 'N', GetSx3Cache("HWC_QTSUBS", "X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS", "X3_DECIMAL"))
	TcSetField(cAlias, 'QTALT'   , 'N', GetSx3Cache("HWC_QTSUBS", "X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS", "X3_DECIMAL"))

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}
	nIndex         := 0
	While (cAlias)->(!Eof())

		nIndex++
		aAdd(oJson["items"], JsonObject():New())
		oJson["items"][nIndex]["branchId"    ] := (cAlias)->HWC_FILIAL
		oJson["items"][nIndex]["product"     ] := (cAlias)->HWC_PRODUT
		oJson["items"][nIndex]["period"      ] := convDate((cAlias)->HWC_DATA, 1)
		oJson["items"][nIndex]["document"    ] := (cAlias)->HWC_DOCPAI
		oJson["items"][nIndex]["originalQty" ] := (cAlias)->QTORIG
		oJson["items"][nIndex]["substitution"] := -(cAlias)->QTALT

		(cAlias)->(dbSkip())

		//Verifica tamanho da página
		If nIndex >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAlias)->(!Eof())

	(cAlias)->(dbCloseArea())
	oExec:Destroy()
	FwFreeObj(oExec)

	aResult[2] := EncodeUTF8(oJson:toJson())
	If nIndex > 0
		aResult[1] := .T.
		aResult[3] := 200
	EndIf
	FwFreeObj(oJson)

	aSize(aValFil, 0)

Return aResult

/*/{Protheus.doc} getFilMRP
Retorna um array com as filiais do MRP para adicionar em query.

@type  Static Function
@author lucas.franca
@since 28/10/2022
@version P12
@param 01 cTicket, Caracter, Número do ticket do MRP
@param 02 cTabela, Caracter, Tabela para retorno da filial
@return aFilMRP, Array, Array com as filiais para considerar
/*/
Static Function getFilMRP(cTicket, cTabela)
	Local aFilMRP  := {}
	Local aFiliais := {}
	Local nIndex   := 0
	Local nTotFils := 0

	MrpTickeME(cTicket, .F., , , @aFiliais)

	nTotFils := Len(aFiliais)
	If nTotFils == 0
		aAdd(aFilMRP, xFilial(cTabela))
	Else
		For nIndex := 1 To nTotFils
			aAdd(aFilMRP, xFilial(cTabela, aFiliais[nIndex][1]))
		Next nIndex
	EndIf
	FwFreeArray(aFiliais)

Return aFilMRP

/*/{Protheus.doc} custoEstoq
Calcula o custo de estoque para um período ( relatório excel )
@type  Function
@author douglas.heydt
@since 30/06/2022
@version P12.1.2210
@param 01 nSaldo     , Numeral, Saldo resultante do período
@param 02 nSaida     , Numeral, Saídas do período
@param 03 nSaidaEst  , Numeral, Saídas de estrutura no período
@param 04 nEstoque   , Numeral, Estoque do produto no período
@param 05 nEntrada   , Numeral, Entradas
@param 06 nCustoUnit , Numeral, Custo unitário, conforme função getCost()

@Return nCusto, Numeral, Custo calculado
/*/
Static Function custoEstoq(nSaldo, nSaida, nSaidaEst, nEstoque, nEntrada, nCustoUnit)

	Local nCusto := 0
	Local nEstoqUsad := 0
	Local nSaidasUsa := 0

	If nEstoque > 0
		nEstoqUsad :=  nEstoque + nEntrada
		nSaidasUsa :=  nSaida + nSaidaEst
	Else
		nEstoqUsad :=  nEntrada
		nSaidasUsa :=  nSaida + nSaidaEst - nEstoque
	EndIf

	If nSaidasUsa < nEstoqUsad
		nCusto := nSaidasUsa * nCustoUnit
	Else
		nCusto := nEstoqUsad * nCustoUnit
	EndIf

	If nCusto < 0
		nCusto := 0
	EndIf

Return nCusto

/*/{Protheus.doc} GET OPTIONAL api/pcp/v1/mrpdata/optional/{ticket}/{product}/{optionalId}
Retorna os opcionais do produto de acordo com o ticket e idOpc

@type WSMETHOD
@author marcelo.neumann
@since 09/11/2022
@version P12.1.27
@param 01 ticket    , Caracter, Ticket do MRP
@param 02 product   , Caracter, Código do produto
@param 03 optionalId, Caracter, ID do opcional do produto (MRP)
@return   lRet      , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET OPTIONAL PATHPARAM ticket, product, optionalId WSSERVICE mrpdata
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getOpcProd(Self:ticket, Self:product, Self:optionalId)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getOpcProd
Retorna os opcionais do produto de acordo com o ticket e idOpc

@type Static Function
@author marcelo.neumann
@since 09/11/2022
@version P12
@param 01 cTicket , Caracter, Ticket do MRP
@param 02 cProduto, Caracter, Código do produto
@param 03 cIdOpc  , Caracter, ID do opcional do produto (MRP)
@return   aResult , Array   , Array com as informacoes da requisicao
/*/
Static Function getOpcProd(cTicket, cProduto, cIdOpc)
	Local aFiliais   := {}
	Local aOpcional  := {}
	Local aResult    := {}
	Local cAliasQry  := GetNextAlias()
	Local cFiliaisIN := ""
	Local nIndex     := 0
	Local oJson      := JsonObject():New()
	Local nTotal     := 0

	MrpTickeME(cTicket, .F., , , aFiliais)
	nTotal := Len(aFiliais)

	cFiliaisIN := "%("
	If nTotal == 0
		cFiliaisIN += "'" + xFilial("HWD") + "'"
	Else
		For nIndex := 1 To nTotal
			If nIndex > 1
				cFiliaisIN += ","
			EndIf
			cFiliaisIN += "'" + xFilial("HWD", aFiliais[nIndex][1]) + "'"
		Next nIndex

		aSize(aFiliais, 0)
	EndIf
	cFiliaisIN += ")%"

	oJson["items"] := {}

	BeginSql Alias cAliasQry
	  SELECT HWD_ERPOPC, HWD_ERPMOP
	    FROM %table:HWD%
	   WHERE HWD_FILIAL IN %Exp:cFiliaisIN%
	     AND HWD_TICKET = %Exp:cTicket%
	     AND HWD_KEYMAT = %Exp:cIdOpc%
		 AND %NotDel%
       ORDER BY HWD_KEYMAT
	EndSql

	If (cAliasQry)->(!Eof())
		aOpcional := aClone(ListOpc(cProduto, (cAliasQry)->HWD_ERPMOP, (cAliasQry)->HWD_ERPOPC, 2))
	EndIf

	(cAliasQry)->(dbCloseArea())

	nTotal := Len(aOpcional)
	If nTotal > 0
		For nIndex := 1 To nTotal
			aAdd(oJson["items"], JsonObject():New())
			oJson["items"][nIndex]["product"          ] := aOpcional[nIndex][1]
			oJson["items"][nIndex]["description"      ] := aOpcional[nIndex][2]
			oJson["items"][nIndex]["groupOptional"    ] := aOpcional[nIndex][3]
			oJson["items"][nIndex]["descGroupOptional"] := aOpcional[nIndex][4]
			oJson["items"][nIndex]["itemOptional"     ] := aOpcional[nIndex][5]
			oJson["items"][nIndex]["descItemOptional" ] := aOpcional[nIndex][6]
		Next nIndex

		aAdd(aResult, .T.)
		aAdd(aResult, EncodeUTF8(oJson:toJson()))
		aAdd(aResult, 200)

		aSize(aOpcional, 0)
	Else
		aAdd(aResult, .F.)
		aAdd(aResult, oJson:toJson())
		aAdd(aResult, 204)
	Endif

	FwFreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET GEN_INFO api/pcp/v1/mrpdata/generics
Retorna informações que não dependem do ticket selecionado

@type WSMETHOD
@author marcelo.neumann
@since 11/11/2022
@version P12
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET GEN_INFO WSSERVICE mrpdata
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := MrpGetGen()
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} MrpGetGen
Retorna informações que não dependem do ticket selecionado

@type Function
@author marcelo.neumann
@since 11/11/2022
@version P12
@return aResult, Array, Array com as informacoes da requisicao
/*/
Function MrpGetGen()
	Local aResult   := {}
	Local cAliasQry := GetNextAlias()
	Local cHasOpc   := "N"
	Local oJson     := JsonObject():New()

	oJson["items"] := {}

	BeginSql Alias cAliasQry
	  SELECT 1
	    FROM %table:HWD%
	   WHERE %NotDel%
	EndSql

	If (cAliasQry)->(!Eof())
		cHasOpc := "S"
	EndIf

	aAdd(oJson["items"], JsonObject():New())

	oJson["items"][1]["hasOptional"] := cHasOpc

	aAdd(aResult, .T.)
	aAdd(aResult, EncodeUTF8(oJson:toJson()))
	aAdd(aResult, 200)

	FwFreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET EXP_OPC api/pcp/v1/mrpdata/expopc/{ticket}
Retorna os opcionais para exportação via excel.

@type WSMETHOD
@author Lucas Fagundes
@since 05/12/2022
@version P12
@param ticket, Caracter, Ticket do MRP
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET EXP_OPC PATHPARAM ticket WSSERVICE mrpdata
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getOpcExp(Self:ticket)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getOpcExp
Retorna as informações de opcionais para exportação do excel.
@type  Function
@author Lucas Fagundes
@since 05/12/2022
@version P12
@param cTicket, Caracter, Ticket do MRP.
@return aResult, Array, Array com os dados da requisição.
/*/
Function getOpcExp(cTicket)
	Local aResult   := {}
	Local oJson     := JsonObject():New()
	Local oJsonData := Nil

	oJsonData := getDataOpc(cTicket)

	oJson["items"] := JsonObject():New()

	oJson["items"]["header"] := getHeadOpc()
	oJson["items"]["data"  ] := oJsonData

	oJson["hasNext"] := .F.

	aAdd(aResult, .T.)
	aAdd(aResult, EncodeUTF8(oJson:toJson()))
	aAdd(aResult, 200)

	FwFreeObj(oJson)
	FwFreeObj(oJsonData)

Return aResult

/*/{Protheus.doc} getDataOpc
Retorna os dados dos opcionais de uma execução do MRP.
@type  Static Function
@author Lucas Fagundes
@since 06/12/2022
@version P12
@param cTicket, Caracter, Ticket do MRP.
@return oJson, Object, Objeto json com os dados dos opcionais.
/*/
Static Function getDataOpc(cTicket)
	Local aDadosOpc := {}
	Local cAlias    := GetNextAlias()
	Local nIndex    := 0
	Local nTotal    := 0
	Local oJsAux    := Nil
	Local oJson     := JsonObject():New()

	BeginSql alias cAlias
		SELECT HWD.HWD_KEYMAT,
		       HWD.HWD_ERPOPC,
		       HWB.HWB_PRODUT,
		       HWD.HWD_ERPMOP
		  FROM %table:HWD% HWD
		 INNER JOIN (SELECT DISTINCT HWB_IDOPC, HWB_PRODUT
		               FROM %table:HWB%
		              WHERE HWB_TICKET = %Exp:cTicket%) HWB
		    ON HWB.HWB_IDOPC  = HWD.HWD_KEYMAT
		 WHERE HWD.HWD_TICKET = %Exp:cTicket%
	EndSql

	While (cAlias)->(!Eof())

		If !oJson:hasProperty((cAlias)->HWB_PRODUT)
			oJson[(cAlias)->HWB_PRODUT] := JsonObject():New()
		EndIf

		aDadosOpc := ListOpc((cAlias)->HWB_PRODUT, (cAlias)->HWD_ERPMOP, (cAlias)->HWD_ERPOPC, 2)
		nTotal    := Len(aDadosOpc)

		oJson[(cAlias)->HWB_PRODUT][(cAlias)->HWD_KEYMAT] := {}
		For nIndex := 1 To nTotal
			oJsAux := JsonObject():New()
			oJsAux["product"           ] := RTrim(aDadosOpc[nIndex][1])
			oJsAux["productDescription"] := RTrim(aDadosOpc[nIndex][2])
			oJsAux["group"             ] := RTrim(aDadosOpc[nIndex][3])
			oJsAux["groupDescription"  ] := RTrim(aDadosOpc[nIndex][4])
			oJsAux["item"              ] := RTrim(aDadosOpc[nIndex][5])
			oJsAux["itemDescription"   ] := RTrim(aDadosOpc[nIndex][6])

			aAdd(oJson[(cAlias)->HWB_PRODUT][(cAlias)->HWD_KEYMAT], oJsAux)
		Next

		FwFreeArray(aDadosOpc)
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return oJson

/*/{Protheus.doc} getHeadOpc
Retorna as informações para montar o header dos opcionais.
@type  Static Function
@author Lucas Fagundes
@since 06/12/2022
@version P12
@return aHeaders, Array, Array com as informações do cabeçalho.
/*/
Static Function getHeadOpc()
	Local aHeaders := {}
	Local nIndex   := 0

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "product"
	aHeaders[nIndex]["label"] := STR0035 // "Produto"

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "productDescription"
	aHeaders[nIndex]["label"] := STR0036 // "Descrição"

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "group"
	aHeaders[nIndex]["label"] := STR0056 // "Grupo"

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "groupDescription"
	aHeaders[nIndex]["label"] := STR0036 // "Descrição"

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "item"
	aHeaders[nIndex]["label"] := STR0057 // "Item"

	aAdd(aHeaders, JsonObject():New())
	nIndex++

	aHeaders[nIndex]["id"] := "itemDescription"
	aHeaders[nIndex]["label"] := STR0036 // "Descrição"

Return aHeaders

/*/{Protheus.doc} arqProdTkt
Recupera o conteudo do parâmetro MV_ARQPROD utilizado em uma execução do mrp.
@type  Static Function
@author Lucas Fagundes
@since 13/02/2023
@version P12
@param cTicket, Caracter, Ticket de execução do mrp
@return cValor, Caracter, Conteudo do parâmetro MV_ARQPROD no ticket verificado
/*/
Static Function arqProdTkt(cTicket)
	Local cValor := ""

	HW1->(DbSetOrder(1)) // HW1_FILIAL+HW1_TICKET+HW1_PARAM
	If HW1->(DbSeek(xFilial("HW1")+cTicket+"usesProductIndicator"))
		If AllTrim(HW1->HW1_VAL) == "1"
			cValor := "SBZ"
		Else
			cValor := "SB1"
		EndIf
	EndIf

Return cValor

/*/{Protheus.doc} GET ORDENS api/pcp/v1/mrpdata/{ticket}/ordens
Retorna as ordens de produção consideradas e criadas em um ticket do MRP.
@type WSMETHOD
@author Lucas Fagundes
@since 29/08/2023
@version P12
@param 01 ticket    , Caracter, Ticket do MRP que irá buscar as ordens.
@param 02 Page      , Number  , Página de busca
@param 03 PageSize  , Number  , Tamanho da página
@param 04 ordem     , Caracter, Filtro de ordem de produção.
@param 05 product   , Caracter, Filtro de produto.
@param 06 tipo      , Caracter, Filtro de tipo da ordem.
@param 07 inicioDe  , Caracter, Filtro de data de inicio da ordem (De).
@param 08 inicioAte , Caracter, Filtro de data de inicio da ordem (Até).
@param 09 entregaDe , Caracter, Filtro de data de entrega da ordem (De).
@param 10 entregaAte, Caracter, Filtro de data de entrega da ordem (Até).
@param 11 origem    , Caracter, Filtro de origem.
@param 12 branchId  , Caracter, Filtro de filial.
@param 13 export    , Logical , Indica se imprime todas as informações.
@return lRet, Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ORDENS PATHPARAM ticket WSRECEIVE Page, PageSize, ordem, product, tipo, inicioDe, inicioAte, entregaDe, entregaAte, origem, branchId, export WSSERVICE mrpdata
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "MRPData"), Break(oError)})
	Local lRet      := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getOrdens(Self:ticket, Self:Page, Self:PageSize, Self:ordem, Self:product, Self:tipo, PCPConvDat(Self:inicioDe, 1), PCPConvDat(Self:inicioAte, 1), PCPConvDat(Self:entregaDe, 1), PCPConvDat(Self:entregaAte, 1), Self:origem, Self:branchId, Self:export)
	END SEQUENCE

	lRet := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lRet

/*/{Protheus.doc} getOrdens
Retorna as ordens de produção de um ticket do MRP.
@type  Static Function
@author Lucas Fagundes
@since 29/08/2023
@version P12
@param 01 cTicket   , Caracter, Ticket do MRP que irá buscar os empenhos.
@param 02 nPage     , Numerico, Página de busca.
@param 03 nPageSize , Numerico, Tamanho da página.
@param 04 cOrdem    , Caracter, Filtro de ordem de produção.
@param 05 cProduto  , Caracter, Filtro de produto.
@param 06 cTipo     , Caracter, Filtro de tipo da ordem.
@param 07 dInicioDe , Date    , Filtro de data de inicio da ordem (De).
@param 08 dInicioAte, Date    , Filtro de data de inicio da ordem (Até).
@param 09 dEntregaDe, Date    , Filtro de data de entrega da ordem (De).
@param 10 dEntregaAt, Date    , Filtro de data de entrega da ordem (Até).
@param 11 cOrigem   , Caracter, Filtro de origem.
@param 12 cFiltFil  , Caracter, Filtro de filial.
@param 13 lExport   , Logical , Indica se imprime todas as informações.
@return aReturn, Array, Array com as informações para retorno da API.
/*/
Static Function getOrdens(cTicket, nPage, nPageSize, cOrdem, cProduto, cTipo, dInicioDe, dInicioAte, dEntregaDe, dEntregaAt, cOrigem, cFiltFil, lExport)
	Local aReturn  := Array(3)
	Local cAlias   := ""
	Local cBanco   := ""
	Local cFiltro  := ""
	Local cQuery   := ""
	Local lDelete  := .F.
	Local lEdit    := .F.
	Local lView    := .F.
	Local nCont    := 0
	Local nStart   := 0
	Local oItem    := Nil
	Local oReturn  := JsonObject():New()

	Default lExport := .F.

	If _oQryOPs == Nil
		cBanco := TcGetDB()

		cQuery := " SELECT aux.filial, "
		cQuery += "        aux.numero, "
		cQuery += "        aux.item, "
		cQuery += "        aux.sequencia, "
		cQuery += "        aux.itemGrade, "
		cQuery += "        aux.produto, "
		cQuery += "        SB1.B1_DESC descricao, "
		cQuery += "        aux.armazem, "
		cQuery += "        aux.quantidade, "
		cQuery += "        aux.dataInicio, "
		cQuery += "        aux.dataEnt, "
		cQuery += "        aux.tipo, "
		cQuery += "        aux.recno, "
		cQuery += "        aux.origem  "
		cQuery += "   FROM (SELECT SC2.C2_FILIAL filial, "
		cQuery += "                SC2.C2_NUM numero, "
		cQuery += "                SC2.C2_ITEM item, "
		cQuery += "                SC2.C2_SEQUEN sequencia, "
		cQuery += "                SC2.C2_ITEMGRD itemGrade, "
		cQuery += "                SC2.C2_PRODUTO produto, "
		cQuery += "                SC2.C2_LOCAL armazem, "
		cQuery += "                SC2.C2_QUANT quantidade, "
		cQuery += "                SC2.C2_DATPRI dataInicio, "
		cQuery += "                SC2.C2_DATPRF dataEnt, "
		cQuery += "                SC2.C2_TPOP tipo, "
		cQuery += "                SC2.R_E_C_N_O_ recno, "
		cQuery += "                'P' origem "
		cQuery += "           FROM " + RetSqlName("HW3") + " HW3 "
		cQuery += "          INNER JOIN " + RetSqlName("SMV") + " SMV "
		cQuery += "             ON SMV.MV_TICKET  = HW3.HW3_TICKET "
		cQuery += "            AND SMV.MV_FILIAL  IN (?) "
		cQuery += "            AND SMV.MV_TABELA  = 'T4Q' "
		cQuery += "            AND SMV.D_E_L_E_T_ = ' ' "
		cQuery += "          INNER JOIN " + RetSqlName("SC2") + " SC2 "
		cQuery += "             ON SC2.C2_FILIAL IN (?) "
		If cBanco == "POSTGRES"
			cQuery += "        AND TRIM(CONCAT(SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD)) = TRIM(SMV.MV_DOCUM) "
		Else
			cQuery += "        AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SMV.MV_DOCUM "
		EndIf
		cQuery += "            AND SC2.D_E_L_E_T_ = ' ' "
		cQuery += "          WHERE HW3.HW3_FILIAL IN (?) "
		cQuery += "            AND HW3.HW3_STATUS IN ('3', '6', '7') "
		cQuery += "            AND HW3.HW3_TICKET = ? "
		cQuery += "            AND HW3.D_E_L_E_T_ = ' ' "
		cQuery += "          UNION "
		cQuery += "         SELECT SC2.C2_FILIAL filial, "
		cQuery += "                SC2.C2_NUM numero, "
		cQuery += "                SC2.C2_ITEM item, "
		cQuery += "                SC2.C2_SEQUEN sequencia, "
		cQuery += "                SC2.C2_ITEMGRD itemGrade, "
		cQuery += "                SC2.C2_PRODUTO produto, "
		cQuery += "                SC2.C2_LOCAL armazem, "
		cQuery += "                SC2.C2_QUANT quantidade, "
		cQuery += "                SC2.C2_DATPRI dataInicio, "
		cQuery += "                SC2.C2_DATPRF dataEnt, "
		cQuery += "                SC2.C2_TPOP tipo, "
		cQuery += "                SC2.R_E_C_N_O_ recno, "
		cQuery += "                'M' origem "
		cQuery += "           FROM " + RetSqlName("HW3") + " HW3 "
		cQuery += "          INNER JOIN " + RetSqlName("SC2") + " SC2 "
		cQuery += "             ON SC2.C2_FILIAL  IN (?) "
		cQuery += "            AND SC2.C2_SEQMRP  = ? "
		cQuery += "            AND SC2.D_E_L_E_T_ = ' ' "
		cQuery += "          WHERE HW3.HW3_FILIAL IN (?) "
		cQuery += "            AND HW3.HW3_STATUS IN ('6', '7') "
		cQuery += "            AND HW3.HW3_TICKET = ? "
		cQuery += "            AND HW3.D_E_L_E_T_ = ' ') aux "
		cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "     ON SB1.B1_FILIAL IN (?) "
		cQuery += "    AND SB1.B1_COD = aux.produto "
		cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE ? "
		cQuery += "  ORDER BY produto, dataEnt, filial, numero, item, sequencia "

		If "MSSQL" $ cBanco
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQryOPs := FwExecStatement():New()
		_oQryOPs:setQuery(cQuery)
		_oQryOPs:setFields({{"dataInicio", "D", 8, 0}, {"dataEnt", "D", 8, 0}})
	EndIf

	cFiltro := " 1=1 "

	If !Empty(cOrdem)
		cBanco := TCGetDB()

		If cBanco == "POSTGRES"
			cFiltro += " AND CONCAT(aux.numero, aux.item, aux.sequencia) LIKE '" + cOrdem + "%' "
		Else
			cFiltro += " AND aux.numero || aux.item || aux.sequencia LIKE '" + cOrdem + "%' "
		EndIf

		If "MSSQL" $ cBanco
			cFiltro := StrTran(cFiltro, "||", "+")
		EndIf
	EndIf

	If cProduto != Nil
		cFiltro += " AND aux.produto LIKE '" + cProduto + "%' "
	EndIf

	If cTipo != Nil
		cFiltro += " AND aux.tipo IN ('" + StrTran(cTipo, ",", "','") + "') "
	EndIf

	If !Empty(dInicioDe)
		cFiltro += " AND aux.dataInicio >= '" + DToS(dInicioDe) + "' "
	EndIf

	If !Empty(dInicioAte)
		cFiltro += " AND aux.dataInicio <= '" + DToS(dInicioAte) + "' "
	EndIf

	If !Empty(dEntregaDe)
		cFiltro += " AND aux.dataEnt >= '" + DToS(dEntregaDe) + "' "
	EndIf

	If !Empty(dEntregaAt)
		cFiltro += " AND aux.dataEnt <= '" + DToS(dEntregaAt) + "' "
	EndIf

	If cOrigem != Nil
		cFiltro += " AND aux.origem IN ('" + StrTran(cOrigem, ",", "','") + "') "
	EndIf

	If cFiltFil != Nil
		cFiltro += " AND aux.filial = '" + cFiltFil + "' "
	EndIf

	_oQryOPs:setIn(1, getFilsTab(cTicket, "SMV")) // MV_FILIAL
	_oQryOPs:setIn(2, getFilsTab(cTicket, "SC2")) // C2_FILIAL
	_oQryOPs:setIn(3, getFilsTab(cTicket, "HW3")) // HW3_FILIAL
	_oQryOPs:setString(4, cTicket) // HW3_TICKET
	_oQryOPs:setIn(5, getFilsTab(cTicket, "SC2")) // C2_FILIAL
	_oQryOPs:setString(6, cTicket) // C2_SEQMRP
	_oQryOPs:setIn(7, getFilsTab(cTicket, "HW3")) // HW3_FILIAL
	_oQryOPs:setString(8, cTicket) // HW3_TICKET
	_oQryOPs:setIn(9, getFilsTab(cTicket, "SB1")) // B1_FILIAL
	_oQryOPs:setUnsafe(10, cFiltro)

	cAlias := _oQryOPs:openAlias()

	If nPage > 1 .And. !lExport
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	getPerms("MATA650", .F., @lView, @lEdit, @lDelete)

	While (cAlias)->(!EoF())
		nCont++
		oItem := JsonObject():New()

		oItem["filial"     ] := (cAlias)->filial
		oItem["ordem"      ] := (cAlias)->numero + (cAlias)->item + (cAlias)->sequencia + (cAlias)->itemGrade
		oItem["produto"    ] := i18n("#1[produto]# - #2[descricao]#", {RTrim((cAlias)->produto), RTrim((cAlias)->descricao)})
		oItem["armazem"    ] := (cAlias)->armazem
		oItem["quantidade" ] := (cAlias)->quantidade
		oItem["dataInicio" ] := PCPConvDat(DToS((cAlias)->dataInicio), 4)
		oItem["dataEntrega"] := PCPConvDat(DToS((cAlias)->dataEnt), 4)
		oItem["tipo"       ] := (cAlias)->tipo
		oItem["origem"     ] := (cAlias)->origem
		oItem["recno"      ] := (cAlias)->recno
		oItem["actions"    ] := {}

		If lView
			aAdd(oItem["actions"], "view")
		EndIf

		If lEdit
			aAdd(oItem["actions"], "edit")
		EndIf

		If lDelete
			aAdd(oItem["actions"], "delete")
		EndIf

		aAdd(oReturn["items"], oItem)
		(cAlias)->(dbSkip())

		If nCont >= nPageSize .And. !lExport
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oItem)
	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET EMPENHOS api/pcp/v1/mrpdata/{ticket}/empenhos
Retorna os empenhos consideradas e criadas em um ticket do MRP.
@type WSMETHOD
@author Lucas Fagundes
@since 30/08/2023
@version P12
@param 01 ticket    , Caracter, Ticket do MRP que irá buscar os empenhos.
@param 02 Page      , Number  , Página de busca
@param 03 PageSize  , Number  , Tamanho da página
@param 04 productEMP, Caracter, Filtro produto.
@param 05 periodFrom, Caracter, Filtro data do empenho (De).
@param 06 periodTo  , Caracter, Filtro data do empenho (Até).
@param 07 ordem     , Caracter, Filtro de ordem de produção.
@param 08 product   , Caracter, Filtro de produto pai.
@param 09 tipo      , Caracter, Filtro de tipo da ordem.
@param 10 inicioDe  , Caracter, Filtro de data de inicio da ordem (De).
@param 11 inicioAte , Caracter, Filtro de data de inicio da ordem (Até).
@param 12 entregaDe , Caracter, Filtro de data de entrega da ordem (De).
@param 13 entregaAte, Caracter, Filtro de data de entrega da ordem (Até).
@param 14 origem    , Caracter, Filtro de origem.
@param 15 branchId  , Caracter, Filtro de filial.
@return lRet, Logico, Indica se teve sucesso na requisição.
/*/
WSMETHOD GET EMPENHOS PATHPARAM ticket WSRECEIVE Page, PageSize, productEMP, periodFrom, periodTo, ordem, product, tipo, inicioDe, inicioAte, entregaDe, entregaAte, origem, branchId WSSERVICE mrpdata
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "MRPData"), Break(oError)})
	Local lRet      := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getEmps(Self:ticket, Self:Page, Self:PageSize, Self:productEMP, PCPConvDat(Self:periodFrom, 1), PCPConvDat(Self:periodTo, 1),  Self:ordem, Self:product, Self:tipo, PCPConvDat(Self:inicioDe, 1), PCPConvDat(Self:inicioAte, 1), PCPConvDat(Self:entregaDe, 1), PCPConvDat(Self:entregaAte, 1), Self:origem, Self:branchId)
	END SEQUENCE

	lRet := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lRet

/*/{Protheus.doc} getEmps
Retorna os empenhos de um ticket do MRP.
@type  Static Function
@author Lucas Fagundes
@since 30/08/2023
@version P12
@param 01 cTicket   , Caracter, Ticket do MRP que irá buscar os empenhos.
@param 02 nPage     , Numerico, Página de busca.
@param 03 nPageSize , Numerico, Tamanho da página.
@param 04 cProdEmp  , Caracter, Filtro de produto do empenho.
@param 05 dDataDe   , Date,   , Filtro data do empenho (De).
@param 06 dDataAte  , Date,   , Filtro data do empenho (Até).
@param 07 cOrdem    , Caracter, Filtro de ordem de produção.
@param 08 cProdOP   , Caracter, Filtro de produto da ordem.
@param 09 cTipo     , Caracter, Filtro de tipo da ordem.
@param 10 dInicioDe , Date    , Filtro de data de inicio da ordem (De).
@param 11 dInicioAte, Date    , Filtro de data de inicio da ordem (Até).
@param 12 dEntregaDe, Date    , Filtro de data de entrega da ordem (De).
@param 13 dEntregaAt, Date    , Filtro de data de entrega da ordem (Até).
@param 14 cOrigem   , Caracter, Filtro de origem.
@param 15 cFiltFil  , Caracter, Filtro de filial.
@return aReturn, Array, Array com as informações para retorno da API.
/*/
Static Function getEmps(cTicket, nPage, nPageSize, cProdEmp, dDataDe, dDataAte, cOrdem, cProdOP, cTipo, dInicioDe, dInicioAte, dEntregaDe, dEntregaAt, cOrigem, cFiltFil)
	Local aReturn    := Array(3)
	Local cAlias     := ""
	Local cBanco     := ""
	Local cFiltroEMP := ""
	Local cFiltroOP  := ""
	Local cQuery     := ""
	Local lDelete    := .F.
	Local lEdit      := .F.
	Local lView      := .F.
	Local nCont      := 0
	Local nStart     := 0
	Local oItem      := Nil
	Local oReturn    := JsonObject():New()

	If _oQryEmp == Nil
		cBanco := TCGetDB()

		cQuery += " SELECT aux.filial, "
		cQuery += "        aux.ordemProd, "
		cQuery += "        aux.produtoPai, "
		cQuery += "        aux.descPai, "
		cQuery += "        aux.dataInicio, "
		cQuery += "        aux.dataEnt, "
		cQuery += "        aux.qtdOp, "
		cQuery += "        aux.tipo, "
		cQuery += "        aux.origem, "
		cQuery += "        (SELECT MIN(SD4b.R_E_C_N_O_) "
		cQuery += "           FROM " + RetSqlName("SD4") + " SD4b "
		cQuery += "          WHERE SD4b.D4_FILIAL = aux.filial "
		cQuery += "            AND SD4b.D4_OP     = aux.ordemProd) recno "
		cQuery += "   FROM (SELECT DISTINCT SD4.D4_FILIAL filial, "
		cQuery += "                         SD4.D4_OP ordemProd, "
		cQuery += "                         SD4.D4_PRODUTO produtoPai, "
		cQuery += "                         descPai.B1_DESC descPai, "
		cQuery += "                         SC2.C2_DATPRI dataInicio, "
		cQuery += "                         SC2.C2_DATPRF dataEnt, "
		cQuery += "                         SC2.C2_QUANT qtdOp, "
		cQuery += "                         SC2.C2_TPOP tipo, "
		cQuery += "                         CASE "
		cQuery += "                             WHEN SMV.MV_TICKET IS NULL THEN 'M' "
		cQuery += "                             ELSE 'P' "
		cQuery += "                         END origem "
		cQuery += "           FROM " + RetSqlName("SD4") + " SD4 "
		cQuery += "          INNER JOIN " + RetSqlName("SC2") + " SC2 "
		cQuery += "             ON " + FwJoinFilial("SC2", "SD4", "SC2", "SD4", .T.)
		If cBanco == "POSTGRES"
			cQuery += "        AND TRIM(CONCAT(SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD)) = TRIM(SD4.D4_OP) "
		Else
			cQuery += "        AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SD4.D4_OP "
		EndIf
		cQuery += "            AND SC2.D_E_L_E_T_ = ' ' "
		cQuery += "            AND ? "
		cQuery += "           LEFT JOIN " + RetSqlName("SMV") + " SMV "
		cQuery += "             ON SMV.MV_FILIAL IN (?) "
		cQuery += "            AND SMV.MV_TICKET = ? "
		cQuery += "            AND SMV.MV_TABELA = 'T4S' "
		If cBanco == "POSTGRES"
			cQuery +=         "AND TRIM(SMV.MV_DOCUM) = TRIM(CONCAT(RTRIM(SC2.C2_PRODUTO), '|', "
			cQuery +=                                             " RTRIM(SD4.D4_FILIAL), ';', "
			cQuery +=                                             " RTRIM(SD4.D4_COD), ';', "
			cQuery +=                                             " RTRIM(SD4.D4_SEQ), ';', "
			cQuery +=                                             " RTRIM(SD4.D4_LOCAL), ';', "
			cQuery +=                                             " RTRIM(SD4.D4_OP), ';', "
			cQuery +=                                             " RTRIM(SD4.D4_OPORIG), ';', "
			cQuery +=                                             " SD4.D4_DATA)) "
		Else
			cQuery +=         "AND RTRIM(SMV.MV_DOCUM) = RTRIM(RTRIM(SC2.C2_PRODUTO) || '|' || "
			cQuery +=                                        " RTRIM(SD4.D4_FILIAL) || ';' || "
			cQuery +=                                        " RTRIM(SD4.D4_COD) || ';' || "
			cQuery +=                                        " RTRIM(SD4.D4_SEQ) || ';' || "
			cQuery +=                                        " RTRIM(SD4.D4_LOCAL) || ';' || "
			cQuery +=                                        " RTRIM(SD4.D4_OP) || ';' || "
			cQuery +=                                        " RTRIM(SD4.D4_OPORIG) || ';' || "
			cQuery +=                                        " SD4.D4_DATA) "
		EndIf
		cQuery += "            AND SMV.D_E_L_E_T_ = ' ' "
		cQuery += "           LEFT JOIN " + RetSqlName("SB1") + " descPai "
		cQuery += "             ON descPai.B1_FILIAL IN (?) "
		cQuery += "            AND descPai.B1_COD = SD4.D4_PRODUTO "
		cQuery += "            AND descPai.D_E_L_E_T_ = ' ' "
		cQuery += "          WHERE SD4.D4_FILIAL IN (?) "
		cQuery += "            AND (SMV.MV_TICKET IS NOT NULL OR SC2.C2_SEQMRP = ?) "
		cQuery += "            AND SD4.D_E_L_E_T_ = ' ' "
		cQuery += "            AND ?) aux "
		cQuery += "  ORDER BY produtoPai, dataEnt, filial, ordemProd "

		If "MSSQL" $ cBanco
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQryEmp := FwExecStatement():New()
		_oQryEmp:setQuery(cQuery)
		_oQryEmp:setFields({{"dataInicio", "D", 8, 0}, {"dataEnt", "D", 8, 0}})
	EndIf

	cFiltroEMP := " 1=1 "
	cFiltroOP  := " 1=1 "

	If !Empty(cOrdem)
		cBanco := TcGetDB()

		If cBanco == "POSTGRES"
			cFiltroOP += " AND CONCAT(SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD) LIKE '" + cOrdem + "%' "
		Else
			cFiltroOP += " AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD LIKE '" + cOrdem + "%' "
		EndIf

		If "MSSQL" $ cBanco
			cFiltroOP := StrTran(cFiltroOP, "||", "+")
		EndIf
	EndIf

	If cProdOP != Nil
		cFiltroOP += " AND SC2.C2_PRODUTO LIKE '" + cProdOP + "%' "
	EndIf

	If cTipo != Nil
		cFiltroOP += " AND SC2.C2_TPOP IN ('" + StrTran(cTipo, ",", "','") + "') "
	EndIf

	If !Empty(dInicioDe)
		cFiltroOP += " AND SC2.C2_DATPRI >= '" + DToS(dInicioDe) + "' "
	EndIf

	If !Empty(dInicioAte)
		cFiltroOP += " AND SC2.C2_DATPRI <= '" + DToS(dInicioAte) + "' "
	EndIf

	If !Empty(dEntregaDe)
		cFiltroOP += " AND SC2.C2_DATPRF >= '" + DToS(dEntregaDe) + "' "
	EndIf

	If !Empty(dEntregaAt)
		cFiltroOP += " AND SC2.C2_DATPRF <= '" + DToS(dEntregaAt) + "' "
	EndIf

	If cProdEmp != Nil
		cFiltroEMP += " AND SD4.D4_COD LIKE '" + cProdEmp + "%' "
	EndIf

	If !Empty(dDataDe)
		cFiltroEMP += " AND SD4.D4_DATA >= '" + DToS(dDataDe) + "' "
	EndIf

	If !Empty(dDataAte)
		cFiltroEMP += " AND SD4.D4_DATA <= '" + DToS(dDataAte) + "' "
	EndIf

	If cOrigem != Nil
		cFiltroEMP += " AND CASE "
		cFiltroEMP += "        WHEN SMV.MV_TICKET IS NULL THEN 'M' "
		cFiltroEMP += "        ELSE 'P' "
		cFiltroEMP += "     END IN ('" + StrTran(cOrigem, ",", "','") + "') "
	EndIf

	_oQryEmp:setUnsafe(1, cFiltroOP)
	_oQryEmp:setIn(2, Iif(Empty(cFiltFil), getFilsTab(cTicket, "SMV"), {xFilial("SMV", cFiltFil)})) // MV_FILIAL
	_oQryEmp:setString(3, cTicket) // MV_TICKET
	_oQryEmp:setIn(4, Iif(Empty(cFiltFil), getFilsTab(cTicket, "SB1"), {xFilial("SB1", cFiltFil)})) // B1_FILIAL
	_oQryEmp:setIn(5, Iif(Empty(cFiltFil), getFilsTab(cTicket, "SD4"), {xFilial("SD4", cFiltFil)})) // D4_FILIAL
	_oQryEmp:setString(6, cTicket   ) // C2_SEQMRP
	_oQryEmp:setUnsafe(7, cFiltroEMP)

	cAlias := _oQryEmp:openAlias()

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	getPerms("MATA381", .F., @lView, @lEdit, @lDelete)

	While (cAlias)->(!EoF()) .And. nCont < nPageSize
		nCont++
		oItem := JsonObject():New()

		oItem["filial"       ] := (cAlias)->filial
		oItem["ordemProducao"] := (cAlias)->ordemProd
		oItem["produtoPai"   ] := i18n("#1[produto]# - #2[descricao]#", {RTrim((cAlias)->produtoPai), RTrim((cAlias)->descPai)})
		oItem["dataInicio"   ] := PCPConvDat(DToS((cAlias)->dataInicio), 4)
		oItem["dataEntrega"  ] := PCPConvDat(DToS((cAlias)->dataEnt), 4)
		oItem["qtdOp"        ] := (cAlias)->qtdOp
		oItem["tipo"         ] := (cAlias)->tipo
		oItem["origem"       ] := (cAlias)->origem
		oItem["recno"        ] := (cAlias)->recno
		oItem["actions"      ] := {}
		oItem["detail"       ] := {JsonObject():New()}

		If lView
			aAdd(oItem["actions"], "view")
		EndIf

		If lEdit
			aAdd(oItem["actions"], "edit")
		EndIf

		If lDelete
			aAdd(oItem["actions"], "delete")
		EndIf

		aAdd(oReturn["items"], oItem)

		(cAlias)->(dbSkip())
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oItem)
	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET COMPRAS api/pcp/v1/mrpdata/{ticket}/compras
Retorna as compras consideradas e criadas em um ticket do MRP.
@type WSMETHOD
@author Lucas Fagundes
@since 04/09/2023
@version P12
@param 01 ticket     , Caracter, Ticket do MRP que irá buscar as compras.
@param 02 Page       , Number  , Página de busca.
@param 03 PageSize   , Number  , Tamanho da página.
@param 04 compra     , Caracter, Filtro solitações de compra.
@param 05 ordem      , Caracter, Filtro ordens de produção.
@param 06 product    , Caracter, Filtro produtos.
@param 07 periodFrom , Caracter, Filtro data solicitações de compra (De).
@param 08 periodTo   , Caracter, Filtro data solicitações de compra (Até).
@param 09 origem     , Caracter, Filtro de origem.
@param 09 documento  , Caracter, Filtro de documento.
@param 10 branchId   , Caracter, Filtro de filial.
@param 11 tipo       , Caracter, Filtro de tipo.
@param 12 export     , Logical , Indica se imprime todos os registros.
@return lRet, Logico, Indica se o processo foi executado com sucesso.
/*/
WSMETHOD GET COMPRAS PATHPARAM ticket WSRECEIVE Page, PageSize, compra, ordem, product, periodFrom, periodTo, origem, documento, branchId, tipo, export WSSERVICE mrpdata
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "MRPData"), Break(oError)})
	Local lRet      := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getCompras(Self:ticket, Self:Page, Self:PageSize, Self:compra, Self:ordem, Self:product, PCPConvDat(Self:periodFrom, 1), PCPConvDat(Self:periodTo, 1), Self:origem, Self:documento, Self:branchId, Self:tipo, Self:export)
	END SEQUENCE

	lRet := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lRet

/*/{Protheus.doc} getCompras
Retorna as compras de um ticket do MRP.
@type  Static Function
@author Lucas Fagundes
@since 04/09/2023
@version P12
@param 01 cTicket   , Caracter, Ticket do MRP que irá buscar as compras.
@param 02 nPage     , Numerico, Página de busca
@param 03 nPageSize , Numerico, Tamanho da página
@param 04 cCompra   , Caracter, Filtro código do documento.
@param 05 cOrdem    , Caracter, Filtro ordens de produção.
@param 06 cProduto  , Caracter, Filtro produtos.
@param 07 dDataDe   , Date    , Filtro data solicitações de compra (De).
@param 08 dDataAte  , Date    , Filtro data solicitações de compra (Até).
@param 09 cOrigem   , Caracter, Filtro de origem.
@param 10 cDocumento, Caracter, Filtro de documento (SC, PC, AE).
@param 11 cFiltFil  , Caracter, Filtro de filial.
@param 12 cTipo     , Caracter, Filtro de tipo.
@param 13 lExport   , Logical , Indica se Imprime todos os registros.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getCompras(cTicket, nPage, nPageSize, cCompra, cOrdem, cProduto, dDataDe, dDataAte, cOrigem, cDocumento, cFiltFil, cTipo, lExport)
	Local aReturn := Array(3)
	Local cAlias  := ""
	Local cBanco  := ""
	Local cFiltro := ""
	Local cQuery  := ""
	Local nCont   := 0
	Local nStart  := 0
	Local oItem   := Nil
	Local oPerms  := JsonObject():New()
	Local oReturn := JsonObject():New()

	Default lExport := .F.

	If _oQrySCs == Nil
		cBanco := TcGetDB()

		cQuery := " SELECT aux.filial, "
		cQuery += "        aux.numero, "
		cQuery += "        aux.item, "
		cQuery += "        aux.itemGrade, "
		cQuery += "        aux.produto, "
		cQuery += "        aux.descricao, "
		cQuery += "        aux.quantidade, "
		cQuery += "        aux.armazem, "
		cQuery += "        aux.dataEnt, "
		cQuery += "        aux.ordemProd, "
		cQuery += "        aux.origem, "
		cQuery += "        aux.documento, "
		cQuery += "        aux.tipo, "
		cQuery += "        aux.recno "
		cQuery += "   FROM (SELECT SC1.C1_FILIAL filial, "
		cQuery += "                SC1.C1_NUM numero, "
		cQuery += "                SC1.C1_ITEM item, "
		cQuery += "                SC1.C1_ITEMGRD itemGrade, "
		cQuery += "                SC1.C1_PRODUTO produto, "
		cQuery += "                SC1.C1_DESCRI descricao, "
		cQuery += "                SC1.C1_QUANT quantidade, "
		cQuery += "                SC1.C1_LOCAL armazem, "
		cQuery += "                SC1.C1_DATPRF dataEnt, "
		cQuery += "                SC1.C1_OP ordemProd, "
		cQuery += "                CASE "
		cQuery += "         	       WHEN SMV.MV_TICKET IS NULL THEN 'M' "
		cQuery += "         	       ELSE 'P' "
		cQuery += "         	   END origem, "
		cQuery += "                'SC' documento, "
		cQuery += "                CASE "
		cQuery += "         	       WHEN SC1.C1_TPOP = ' ' THEN 'F' "
		cQuery += "         	       ELSE SC1.C1_TPOP "
		cQuery += "         	   END tipo, "
		cQuery += "         	   SC1.R_E_C_N_O_ recno "
		cQuery += "           FROM " + RetSqlName("SC1") + " SC1 "
		cQuery += "           LEFT JOIN " + RetSqlName("SMV") + " SMV "
		cQuery += "             ON " + FwJoinFilial("SMV", "SC1", "SMV", "SC1", .T.)
		cQuery += "            AND SMV.MV_TICKET = ? "
		cQuery += "            AND SMV.MV_TABELA = 'T4T' "
		If cBanco == "POSTGRES"
			cQuery +=        " AND TRIM(SMV.MV_DOCUM) = TRIM(CONCAT(SC1.C1_NUM, SC1.C1_ITEM, SC1.C1_ITEMGRD)) "
		Else
			cQuery +=        " AND SMV.MV_DOCUM = SC1.C1_NUM||SC1.C1_ITEM||SC1.C1_ITEMGRD "
		EndIf
		cQuery += "            AND SMV.D_E_L_E_T_ = ' ' "
		cQuery += "          WHERE SC1.C1_FILIAL IN (?) "
		cQuery += "            AND (SMV.MV_TICKET IS NOT NULL OR SC1.C1_SEQMRP = ?) "
		cQuery += "            AND SC1.D_E_L_E_T_ = ' ' "
		cQuery += "         UNION ALL "
		cQuery += "         SELECT SC7.C7_FILIAL filial, "
		cQuery += "                SC7.C7_NUM numero, "
		cQuery += "                SC7.C7_ITEM item, "
		cQuery += "                SC7.C7_ITEMGRD itemGrade, "
		cQuery += "                SC7.C7_PRODUTO produto, "
		cQuery += "                SC7.C7_DESCRI descricao, "
		cQuery += "                SC7.C7_QUANT quantidade, "
		cQuery += "                SC7.C7_LOCAL armazem, "
		cQuery += "                SC7.C7_DATPRF dataEnt, "
		cQuery += "                SC7.C7_OP ordemProd, "
		cQuery += "                CASE "
		cQuery += "         	       WHEN SMV.MV_TICKET IS NULL THEN 'M' "
		cQuery += "         	       ELSE 'P' "
		cQuery += "         	   END origem, "
		cQuery += "                CASE "
		cQuery += "                    WHEN SMV.MV_TICKET IS NOT NULL AND SMV.MV_TIPDOC IN ('3', 'C') "
		cQuery += "                        THEN 'PC' "
		cQuery += "                    WHEN SMV.MV_TICKET IS NOT NULL AND SMV.MV_TIPDOC IN ('E', 'F') "
		cQuery += "                        THEN 'AE' "
		cQuery += "                    WHEN SMV.MV_TICKET IS NULL AND SC7.C7_TIPO = 2 "
		cQuery += "                        THEN 'AE' "
		cQuery += "                    ELSE 'PC' "
		cQuery += "                END documento, "
		cQuery += "                CASE "
		cQuery += "         	       WHEN SC7.C7_TPOP = ' ' THEN 'F' "
		cQuery += "         	       ELSE SC7.C7_TPOP "
		cQuery += "         	   END tipo, "
		cQuery += "         	   SC7.R_E_C_N_O_ recno "
		cQuery += "           FROM " + RetSqlName("SC7") + " SC7 "
		cQuery += "           LEFT JOIN " + RetSqlName("SMV") + " SMV "
		cQuery += "             ON " + FwJoinFilial("SMV", "SC7", "SMV", "SC7", .T.)
		cQuery += "            AND SMV.MV_TICKET = ? "
		cQuery += "            AND SMV.MV_TABELA = 'T4U' "
		If cBanco == "POSTGRES"
			cQuery +=        " AND TRIM(SMV.MV_DOCUM) = TRIM(CONCAT(SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_ITEMGRD)) "
		Else
			cQuery +=        " AND SMV.MV_DOCUM = SC7.C7_NUM||SC7.C7_ITEM||SC7.C7_ITEMGRD "
		EndIf
		cQuery += "            AND SMV.D_E_L_E_T_ = ' ' "
		cQuery += "          WHERE SC7.C7_FILIAL IN (?) "
		cQuery += "            AND (SMV.MV_TICKET IS NOT NULL OR SC7.C7_SEQMRP = ?) "
		cQuery += "            AND SC7.D_E_L_E_T_ = ' ') aux "
		cQuery += "  WHERE ? "
		cQuery += "  ORDER BY aux.produto, aux.dataEnt, aux.filial, aux.quantidade "

		If "MSSQL" $ cBanco
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQrySCs := FwExecStatement():New()
		_oQrySCs:setQuery(cQuery)
		_oQrySCs:setFields({{"dataEnt", "D", 8, 0}})
	EndIf

	cFiltro := " 1=1 "

	If cCompra != Nil
		cBanco := TCGetDB()

		If cBanco == "POSTGRES"
			cFiltro += " AND CONCAT(aux.numero, aux.item, aux.itemGrade) LIKE '" + cCompra + "%' "
		Else
			cFiltro += " AND aux.numero||aux.item||aux.itemGrade LIKE '" + cCompra + "%' "

			If "MSSQL" $ cBanco
				cFiltro := StrTran(cFiltro, "||", "+")
			EndIf
		EndIf
	EndIf

	If cOrdem != Nil
		cFiltro += " AND aux.ordemProd LIKE '" + cOrdem + "%' "
	EndIf

	If cProduto != Nil
		cFiltro += " AND aux.produto LIKE '" + cProduto + "%' "
	EndIf

	If !Empty(dDataDe)
		cFiltro += " AND aux.dataEnt >= '" + DToS(dDataDe) + "' "
	EndIf

	If !Empty(dDataAte)
		cFiltro += " AND aux.dataEnt <= '" + DToS(dDataAte) + "' "
	EndIf

	If cOrigem != Nil
		cFiltro += " AND aux.origem IN ('" + StrTran(cOrigem, ",", "','") + "') "
	EndIf

	If cDocumento != Nil
		cFiltro += " AND aux.documento IN ('" + StrTran(cDocumento, ",", "','") + "') "
	EndIf

	If cTipo != Nil
		cFiltro += " AND aux.tipo IN ('" + StrTran(cTipo, ",", "','") + "') "
	EndIf

	_oQrySCs:setString(1, cTicket) // MV_TICKET
	_oQrySCs:setIn(2, Iif(Empty(cFiltFil), getFilsTab(cTicket, "SC1"), {xFilial("SC1", cFiltFil)})) // C1_FILIAL
	_oQrySCs:setString(3, cTicket) // C1_SEQMRP
	_oQrySCs:setString(4, cTicket) // MV_TICKET
	_oQrySCs:setIn(5, Iif(Empty(cFiltFil), getFilsTab(cTicket, "SC7"), {xFilial("SC7", cFiltFil)})) // C7_FILIAL
	_oQrySCs:setString(6, cTicket) // C7_SEQMRP
	_oQrySCs:setUnsafe(7, cFiltro)

	cAlias := _oQrySCs:openAlias()

	If nPage > 1 .And. !lExport
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	oPerms["SC"] := JsonObject():New()
	getPerms("MATA110", .F., @oPerms["SC"]["view"], @oPerms["SC"]["edit"], @oPerms["SC"]["delete"])

	oPerms["PC"] := JsonObject():New()
	getPerms("MATA121", .F., @oPerms["PC"]["view"], @oPerms["PC"]["edit"], @oPerms["PC"]["delete"])

	oPerms["AE"] := JsonObject():New()
	getPerms("MATA122", .F., @oPerms["AE"]["view"], @oPerms["AE"]["edit"], @oPerms["AE"]["delete"])

	While (cAlias)->(!EoF())
		nCont++
		oItem := JsonObject():New()

		oItem["filial"    ] := (cAlias)->filial
		oItem["numero"    ] := (cAlias)->numero + (cAlias)->item + (cAlias)->itemGrade
		oItem["produto"   ] := i18n("#1[produto]# - #2[descricao]#", {RTrim((cAlias)->produto), RTrim((cAlias)->descricao)})
		oItem["data"      ] := PCPConvDat(DToS((cAlias)->dataEnt), 4)
		oItem["quantidade"] := (cAlias)->quantidade
		oItem["armazem"   ] := (cAlias)->armazem
		oItem["ordem"     ] := (cAlias)->ordemProd
		oItem["origem"    ] := (cAlias)->origem
		oItem["documento" ] := (cAlias)->documento
		oItem["recno"     ] := (cAlias)->recno
		oItem["tipo"      ] := (cAlias)->tipo
		oItem["actions"   ] := {}

		If oPerms[oItem["documento"]]["view"]
			aAdd(oItem["actions"], "view")
		EndIf

		If oPerms[oItem["documento"]]["edit"]
			aAdd(oItem["actions"], "edit")
		EndIf

		If oPerms[oItem["documento"]]["delete"]
			aAdd(oItem["actions"], "delete")
		EndIf

		aAdd(oReturn["items"], oItem)
		(cAlias)->(dbSkip())

		If nCont >= nPageSize .And. !lExport
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oItem)
	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET DEMANDAS api/pcp/v1/mrpdata/{ticket}/demandas
Retorna as demandas consideradas em um ticket do MRP.
@type WSMETHOD
@author Lucas Fagundes
@since 04/09/2023
@version P12
@param 01 ticket    , Caracter, Ticket do MRP que irá buscar as demandas.
@param 02 Page      , Number  , Página de busca.
@param 03 PageSize  , Number  , Tamanho da página.
@param 04 demanda   , Caracter, Filtro código da demanda.
@param 05 inicioDe  , Caracter, Filtro inicio das demnadas (De).
@param 06 inicioAte , Caracter, Filtro inicio das demnadas (Até).
@param 07 entregaAte, Caracter, Filtro fim das demandas (De).
@param 08 dFimAte   , Caracter, Filtro fim das demandas (Até).
@param 09 product   , Caracter, Filtro produto.
@param 09 periodFrom, Caracter, Filtro data da demanda (De).
@param 09 periodTo  , Caracter, Filtro data da demanda (Até).
@param 09 tipo      , Caracter, Filtro tipo de demanda.
@param 09 documento , Caracter, Filtro documento da demanda.
@param 10 branchId  , Caracter, Filtro de filial.
@return lRet, Logico, Indica se o processo foi executado com sucesso.
/*/
WSMETHOD GET DEMANDAS PATHPARAM ticket WSRECEIVE Page, PageSize, demanda, inicioDe, inicioAte, entregaDe, entregaAte, product, periodFrom, periodTo, tipo, documento, branchId WSSERVICE mrpdata
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "MRPData"), Break(oError)})
	Local lRet      := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getDems(Self:ticket, Self:Page, Self:PageSize, Self:demanda, PCPConvDat(Self:inicioDe, 1), PCPConvDat(Self:inicioAte, 1), PCPConvDat(Self:entregaDe, 1), PCPConvDat(Self:entregaAte, 1), Self:product, PCPConvDat(Self:periodFrom, 1), PCPConvDat(Self:periodTo, 1), Self:tipo, Self:documento, Self:branchId)
	END SEQUENCE

	lRet := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lRet

/*/{Protheus.doc} getDems
Retorna as demandas consideradas em um ticket do MRP.
@type  Static Function
@author Lucas Fagundes
@since 04/09/2023
@version P12
@param 01 cTicket   , Caracter, Ticket do MRP que irá buscar os empenhos.
@param 02 nPage     , Numerico, Página de busca
@param 03 nPageSize , Numerico, Tamanho da página
@param 04 cDemanda  , Caracter, Filtro código da demanda.
@param 05 dInicioDe , Date    , Filtro inicio das demandas (De).
@param 06 dInicioAte, Date    , Filtro inicio das demandas (Até).
@param 07 dFimDe    , Date    , Filtro fim das demandas (De).
@param 08 dFimAte   , Date    , Filtro fim das demandas (Até).
@param 09 cProduto  , Caracter, Filtro produto.
@param 10 dDataDe   , Date    , Filtro da demanda (De).
@param 11 dDataAte  , Date    , Filtro da demanda (Até).
@param 12 cTipo     , Caracter, Filtro tipo de demanda.
@param 13 cDocumento, Caracter, Filtro documento da demanda.
@param 14 cFiltFil  , Caracter, Filtro de filial.
@return aReturn, Array, Array com as informações para retorno da API.
/*/
Static Function getDems(cTicket, nPage, nPageSize, cDemanda, dInicioDe, dInicioAte, dFimDe, dFimAte, cProduto, dDataDe, dDataAte, cTipo, cDocumento, cFiltFil)
	Local aReturn    := Array(3)
	Local cAlias     := ""
	Local cBanco     := ""
	Local cFiltroSVB := ""
	Local cFiltroSVR := ""
	Local cQuery     := ""
	Local lDelete    := .F.
	Local lEdit      := .F.
	Local lView      := .F.
	Local nCont      := 0
	Local nStart     := 0
	Local nTamSeq    := 0
	Local oItem      := Nil
	Local oReturn    := JsonObject():New()

	If _oQryDem == Nil
		cBanco  := TCGetDB()

		cQuery := " SELECT DISTINCT SVB.VB_FILIAL filial, "
		cQuery += "                 SVB.VB_CODIGO codigo, "
		cQuery += "                 SVB.VB_DTINI dataInicio, "
		cQuery += "                 SVB.VB_DTFIM dataFim, "
		cQuery += "                 SVB.R_E_C_N_O_ recno "
		cQuery += "   FROM " + RetSqlName("SVB") + " SVB "
		cQuery += "  INNER JOIN " + RetSqlName("SVR") + " SVR "
		cQuery += "     ON " + FwJoinFilial("SVB", "SVR", "SVB", "SVR", .T.)
		cQuery += "    AND SVR.VR_CODIGO = SVB.VB_CODIGO "
  		cQuery += "    AND SVR.D_E_L_E_T_ = ' ' "
  		cQuery += "    AND ? "
		cQuery += "  INNER JOIN " + RetSqlName("SMV") + " SMV "
		cQuery += "     ON " + FwJoinFilial("SMV", "SVR", "SMV", "SVR", .T.)
		cQuery += "    AND SMV.MV_TICKET = ? "
		cQuery += "    AND SMV.MV_TABELA = 'T4J' "
		If cBanco == "POSTGRES"
			cQuery += "AND TRIM(SMV.MV_DOCUM) = TRIM(CONCAT(SVR.VR_FILIAL, SVR.VR_CODIGO, SVR.VR_SEQUEN)) "
		Else
			nTamSeq := GetSx3Cache("VR_SEQUEN", "X3_TAMANHO")

			cQuery += "AND RTRIM(SMV.MV_DOCUM) = RTRIM(SVR.VR_FILIAL||SVR.VR_CODIGO||CAST(SVR.VR_SEQUEN AS VARCHAR(" + cValToChar(nTamSeq) + "))) "
		EndIf
		cQuery += "    AND SMV.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE SVB.VB_FILIAL IN (?) "
		cQuery += "    AND SVB.D_E_L_E_T_ = ' ' "
		cQuery += "    AND ? "
		cQuery += "  ORDER BY SVB.VB_FILIAL, SVB.VB_CODIGO "

		If "MSSQL" $ cBanco
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQryDem := FwExecStatement():New()
		_oQryDem:setQuery(cQuery)
		_oQryDem:setFields({{"dataInicio", "D", 8, 0}, {"dataFim", "D", 8, 0}})
	EndIf

	cFiltroSVB := " 1=1 "
	cFiltroSVR := " 1=1 "

	If cDemanda != Nil
		cFiltroSVB += " AND SVB.VB_CODIGO LIKE '" + cDemanda + "%' "
	EndIf

	If !Empty(dInicioDe)
		cFiltroSVB += " AND SVB.VB_DTINI >= '" + DToS(dInicioDe) + "' "
	EndIf

	If !Empty(dInicioAte)
		cFiltroSVB += " AND SVB.VB_DTINI <= '" + DToS(dInicioAte) + "' "
	EndIf

	If !Empty(dFimDe)
		cFiltroSVB += " AND SVB.VB_DTFIM >= '" + DToS(dFimDe) + "' "
	EndIf

	If !Empty(dFimAte)
		cFiltroSVB += " AND SVB.VB_DTFIM <= '" + DToS(dFimAte) + "' "
	EndIf

	If cProduto != Nil
		cFiltroSVR += " AND SVR.VR_PROD LIKE '" + cProduto + "%' "
	EndIf

	If !Empty(dDataDe)
		cFiltroSVR += " AND SVR.VR_DATA >= '" + DToS(dDataDe) + "' "
	EndIf

	If !Empty(dDataAte)
		cFiltroSVR += " AND SVR.VR_DATA <= '" + DToS(dDataAte) + "' "
	EndIf

	If cTipo != Nil
		cFiltroSVR += " AND SVR.VR_TIPO IN ('" + StrTran(cTipo, ",", "','") + "') "
	EndIf

	If cDocumento != Nil
		cFiltroSVR += " AND SVR.VR_DOC LIKE '" + cDocumento + "%' "
	EndIf

	_oQryDem:setUnsafe(1, cFiltroSVR)
	_oQryDem:setString(2, cTicket) // MV_TICKET
	_oQryDem:setIn(3, Iif(Empty(cFiltFil), getFilsTab(cTicket, "SVB"), {xFilial("SVB", cFiltFil)})) // VB_FILIAL
	_oQryDem:setUnsafe(4, cFiltroSVB)

	cAlias := _oQryDem:openAlias()

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	getPerms("PCPA136", .T., @lView, @lEdit, @lDelete)

	While (cAlias)->(!EoF()) .And. nCont < nPageSize
		nCont++
		oItem := JsonObject():New()

		oItem["filial"    ] := (cAlias)->filial
		oItem["codigo"    ] := (cAlias)->codigo
		oItem["dataInicio"] := PCPConvDat(DToS((cAlias)->dataInicio), 4)
		oItem["dataFim"   ] := PCPConvDat(DToS((cAlias)->dataFim), 4)
		oItem["recno"     ] := (cAlias)->recno
		oItem["detail"    ] := {JsonObject():New()}
		oItem["actions"   ] := {}

		If lView
			aAdd(oItem["actions"], "view")
		EndIf

		If lEdit
			aAdd(oItem["actions"], "edit")
		EndIf

		If lDelete
			aAdd(oItem["actions"], "delete")
		EndIf

		aAdd(oReturn["items"], oItem)
		(cAlias)->(dbSkip())
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oItem)
	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET EMP_OP api/pcp/v1/mrpdata/{ticket}/empenhos/{branchId}/{ordem}
Retorna os empenhos de uma ordem de produção.
@type WSMETHOD
@author Lucas Fagundes
@since 04/09/2023
@version P12
@param 01 ticket    , Caracter, Ticket do MRP.
@param 02 branchId  , Caracter, Filial da ordem que irá buscar os empenhos.
@param 03 ordem     , Caracter, Ordem de produção que irá buscar os empenhos.
@param 04 product   , Caracter, Filtro de produto.
@param 05 periodFrom, Caracter, Filtro de data (De).
@param 06 periodTo  , Caracter, Filtro de data (Até).
@return lRet, Logico, Indica se o processo foi executado com sucesso.
/*/
WSMETHOD GET EMP_OP PATHPARAM ticket, branchId, ordem WSRECEIVE product, periodFrom, periodTo WSSERVICE mrpdata
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "MRPData"), Break(oError)})
	Local lRet      := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getEmpOrd(Self:ticket, Self:ordem, Self:product, PCPConvDat(Self:periodFrom, 1), PCPConvDat(Self:periodTo, 1), Self:branchId)
	END SEQUENCE

	lRet := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lRet

/*/{Protheus.doc} getEmpOrd
Retorna os empenhos de uma ordem de produção
@type  Static Function
@author Lucas Fagundes
@since 05/09/2023
@version P12
@param 01 cTicket , Caracter, Ticket do MRP.
@param 02 cOrdem  , Caracter, Código da ordem de produção.
@param 03 cProduto, Caracter, Filtro de produtos.
@param 04 dDataDe , Date    , Filtro de data do empenho (De).
@param 05 dDataAte, Date    , Filtro de data do empenho (Ate).
@param 06 cFilAux , Caracter, Filial que irá buscar o empenho.
@return aReturn, Array, Array com as informações para retorno da API.
/*/
Static Function getEmpOrd(cTicket, cOrdem, cProduto, dDataDe, dDataAte, cFilAux)
	Local aReturn := Array(3)
	Local cAlias  := ""
	Local cBanco  := ""
	Local cFiltro := ""
	Local cQuery  := ""
	Local oItem   := Nil
	Local oReturn := JsonObject():New()

	If _oQryEmpOp == Nil
		cBanco := TcGetDB()

		cQuery += " SELECT SD4.D4_COD produto, "
		cQuery += "        SB1.B1_DESC descricao, "
		cQuery += "        SD4.D4_LOCAL armazem, "
		cQuery += "        SD4.D4_DATA data, "
		cQuery += "        SD4.D4_QTDEORI quantidade, "
		cQuery += "        SD4.D4_QUANT saldo        "
		cQuery += "   FROM " + RetSqlName("SD4") + " SD4 "
		cQuery += "   LEFT JOIN " + RetSqlName("SMV") + " SMV "
		cQuery += "     ON SMV.MV_FILIAL = ? "
		cQuery += "    AND SMV.MV_TICKET = ? "
		cQuery += "    AND SMV.MV_TABELA = 'T4S' "
		If cBanco == "POSTGRES"
			cQuery += "AND TRIM(SMV.MV_DOCUM) = TRIM(CONCAT(RTRIM(SD4.D4_PRODUTO), '|', "
			cQuery +=                                     " RTRIM(SD4.D4_FILIAL), ';', "
			cQuery +=                                     " RTRIM(SD4.D4_COD), ';', "
			cQuery +=                                     " RTRIM(SD4.D4_SEQ), ';', "
			cQuery +=                                     " RTRIM(SD4.D4_LOCAL), ';', "
			cQuery +=                                     " RTRIM(SD4.D4_OP), ';', "
			cQuery +=                                     " RTRIM(SD4.D4_OPORIG), ';', "
			cQuery +=                                     " SD4.D4_DATA)) "
		Else
			cQuery += "AND RTRIM(SMV.MV_DOCUM) = RTRIM(RTRIM(SD4.D4_PRODUTO) || '|' || "
			cQuery +=                                " RTRIM(SD4.D4_FILIAL) || ';' || "
			cQuery +=                                " RTRIM(SD4.D4_COD) || ';' || "
			cQuery +=                                " RTRIM(SD4.D4_SEQ) || ';' || "
			cQuery +=                                " RTRIM(SD4.D4_LOCAL) || ';' || "
			cQuery +=                                " RTRIM(SD4.D4_OP) || ';' || "
			cQuery +=                                " RTRIM(SD4.D4_OPORIG) || ';' || "
			cQuery +=                                " SD4.D4_DATA) "
		EndIf
		cQuery += "    AND SMV.D_E_L_E_T_ = ' ' "
		cQuery += "   LEFT JOIN " + RetSqlName("HWC") + " HWC "
		cQuery += "     ON HWC.HWC_FILIAL = ? "
		cQuery += "    AND HWC_TICKET = ? "
		cQuery += "    AND HWC.HWC_TDCERP IN ('1', '4') "
		cQuery += "    AND HWC.HWC_DOCERP = SD4.D4_OP "
		cQuery += "    AND HWC.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "     ON SB1.B1_FILIAL = ? "
		cQuery += "    AND SB1.B1_COD = SD4.D4_COD "
		cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE SD4.D4_FILIAL = ? "
		cQuery += "    AND SD4.D4_OP = ? "
		cQuery += "    AND (SMV.MV_TICKET IS NOT NULL OR HWC.HWC_TICKET IS NOT NULL) "
		cQuery += "    AND SD4.D_E_L_E_T_ = ' ' "
		cQuery += "    AND ? "

		If "MSSQL" $ cBanco
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQryEmpOp := FwExecStatement():New()
		_oQryEmpOp:setQuery(cQuery)
		_oQryEmpOp:setFields({{"data", "D", 8, 0}})
	EndIf

	_oQryEmpOp:setString(1, xFilial("SMV", cFilAux)) // MV_FILIAL
	_oQryEmpOp:setString(2, cTicket) // MV_TICKET
	_oQryEmpOp:setString(3, xFilial("HWC", cFilAux)) // HWC_FILIAL
	_oQryEmpOp:setString(4, cTicket) // HWC_TICKET
	_oQryEmpOp:setString(5, xFilial("SB1", cFilAux)) // B1_FILIAL
	_oQryEmpOp:setString(6, xFilial("SD4", cFilAux)) // D4_FILIAL
	_oQryEmpOp:setString(7, cOrdem) // D4_OP

	cFiltro := " 1=1 "

	If cProduto != Nil
		cFiltro += " AND SD4.D4_COD LIKE '" + cProduto + "%' "
	EndIf

	If !Empty(dDataDe)
		cFiltro += " AND SD4.D4_DATA >= '" + DToS(dDataDe) + "' "
	EndIf

	If !Empty(dDataAte)
		cFiltro += " AND SD4.D4_DATA <= '" + DToS(dDataAte) + "' "
	EndIf

	_oQryEmpOp:setUnsafe(8, cFiltro)

	cAlias := _oQryEmpOp:openAlias()

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		oItem := JsonObject():New()

		oItem["produto"   ] := (cAlias)->produto
		oItem["descricao" ] := (cAlias)->descricao
		oItem["armazem"   ] := (cAlias)->armazem
		oItem["data"      ] := PCPConvDat(DToS((cAlias)->data), 4)
		oItem["quantidade"] := (cAlias)->quantidade
		oItem["saldo"     ] := (cAlias)->saldo

		aAdd(oReturn["items"], oItem)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oItem)
	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} GET DEMS_DEM api/pcp/v1/mrpdata/{ticket}/demandas/{branchId}/{demanda}
Retorna os itens de uma demanda.
@type WSMETHOD
@author Lucas Fagundes
@since 04/09/2023
@version P12
@param 01 ticket    , Caracter, Ticket do MRP.
@param 02 branchId  , Caracter, Filial da demanda que irá buscar os itens.
@param 03 demanda   , Caracter, Demandas que irá buscar os items.
@param 04 product   , Caracter, Filtro de produto.
@param 05 documento , Caracter, Filtro de documento.
@param 06 tipo      , Caracter, Filtro de tipo.
@param 07 periodFrom, Caracter, Filtro de data (De).
@param 08 periodTo  , Caracter, Filtro de data (Até).
@return lRet, Logico, Indica se o processo foi executado com sucesso.
/*/
WSMETHOD GET DEMS_DEM PATHPARAM ticket, branchId, demanda WSRECEIVE product, documento, tipo, periodFrom, periodTo WSSERVICE mrpdata
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "MRPData"), Break(oError)})
	Local lRet      := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getItemDem(Self:ticket, Self:demanda, Self:product, Self:documento, Self:tipo, PCPConvDat(Self:periodFrom, 1), PCPConvDat(Self:periodTo, 1), Self:branchId)
	END SEQUENCE

	lRet := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lRet

/*/{Protheus.doc} getItemDem
Retorna os itens considerados pelo MRP de uma demanda.
@type  Static Function
@author Lucas Fagundes
@since 05/09/2023
@version P12
@param 01 cTicket   , Caracter, Ticket do MRP.
@param 02 cDemanda  , Caracter, Demandas que irá buscar os items.
@param 03 cProduto  , Caracter, Filtro de produto.
@param 04 cDocumento, Caracter, Filtro de documento.
@param 05 cTipo     , Caracter, Filtro de tipo.
@param 06 dDataDe   , Date    , Filtro de data (De).
@param 07 dDataAte  , Date    , Filtro de data (Até).
@param 08 cFilAux   , Caracter, Filial da demanda que irá buscar os itens.
@return aReturn, Array, Array com as informações para retorno da API.
/*/
Static Function getItemDem(cTicket, cDemanda, cProduto, cDocumento, cTipo, dDataDe, dDataAte, cFilAux)
	Local aReturn := Array(3)
	Local cAlias  := ""
	Local cBanco  := ""
	Local cFiltro := ""
	Local cQuery  := ""
	Local nTamSeq := 0
	Local oItem   := Nil
	Local oReturn := JsonObject():New()

	If _oQryItDem == Nil
		cBanco  := TCGetDB()

		cQuery += " SELECT SVR.VR_PROD produto, "
		cQuery += "        SB1.B1_DESC descricao, "
		cQuery += "        SVR.VR_DATA data, "
		cQuery += "        SVR.VR_QUANT quantidade, "
		cQuery += "        SVR.VR_LOCAL armazem, "
		cQuery += "        SVR.VR_DOC documento, "
		cQuery += "        SVR.VR_TIPO tipo "
		cQuery += "   FROM " + RetSqlName("SVR") + " SVR "
		cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "     ON SB1.B1_FILIAL = ? "
		cQuery += "    AND SB1.B1_COD = SVR.VR_PROD "
		cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN " + RetSqlName("SMV") + " SMV "
		cQuery += "     ON SMV.MV_FILIAL = ? "
		cQuery += "    AND SMV.MV_TICKET = ? "
		cQuery += "    AND SMV.MV_TABELA = 'T4J' "
		If cBanco == "POSTGRES"
			cQuery += "AND TRIM(SMV.MV_DOCUM) = TRIM(CONCAT(SVR.VR_FILIAL, SVR.VR_CODIGO, SVR.VR_SEQUEN)) "
		Else
			nTamSeq := GetSx3Cache("VR_SEQUEN", "X3_TAMANHO")

			cQuery += "AND RTRIM(SMV.MV_DOCUM) = RTRIM(SVR.VR_FILIAL||SVR.VR_CODIGO||CAST(SVR.VR_SEQUEN AS VARCHAR(" + cValToChar(nTamSeq) + "))) "
		EndIf
		cQuery += "    AND SMV.D_E_L_E_T_ = ' ' "
		cQuery += "  WHERE SVR.VR_FILIAL = ? "
		cQuery += "    AND SVR.VR_CODIGO = ? "
		cQuery += "    AND SVR.D_E_L_E_T_ = ' ' "
		cQuery += "    AND ? "

		If "MSSQL" $ cBanco
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQryItDem := FwExecStatement():New()
		_oQryItDem:setQuery(cQuery)
		_oQryItDem:setFields({{"data", "D", 8, 0}})
	EndIf

	_oQryItDem:setString(1, xFilial("SB1", cFilAux)) // B1_FILIAL
	_oQryItDem:setString(2, xFilial("SMV", cFilAux)) // MV_FILIAL
	_oQryItDem:setString(3, cTicket) // MV_TICKET
	_oQryItDem:setString(4, xFilial("SVR", cFilAux)) // VR_FILIAL
	_oQryItDem:setString(5, cDemanda) // VR_CODIGO

	cFiltro := " 1=1 "

	If cProduto != Nil
		cFiltro += " AND SVR.VR_PROD LIKE '" + cProduto + "%' "
	EndIf

	If cDocumento != Nil
		cFiltro += " AND SVR.VR_DOC LIKE '" + cDocumento + "%' "
	EndIf

	If cTipo != Nil
		cFiltro += " AND SVR.VR_TIPO IN ('" + StrTran(cTipo, ",", "','") + "') "
	EndIf

	If !Empty(dDataDe)
		cFiltro += " AND SVR.VR_DATA >= '" + DToS(dDataDe) + "' "
	EndIf

	If !Empty(dDataAte)
		cFiltro += " AND SVR.VR_DATA <= '" + DToS(dDataAte) + "' "
	EndIf

	_oQryItDem:setUnsafe(6, cFiltro)

	cAlias := _oQryItDem:openAlias()

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		oItem := JsonObject():New()

		oItem["produto"   ] := i18n("#1[produto]# - #2[descricao]#", {RTrim((cAlias)->produto), RTrim((cAlias)->descricao)})
		oItem["data"      ] := PCPConvDat(DToS((cAlias)->data), 4)
		oItem["quantidade"] := (cAlias)->quantidade
		oItem["armazem"   ] := (cAlias)->armazem
		oItem["documento" ] := (cAlias)->documento
		oItem["tipo"      ] := LabelTpDem((cAlias)->tipo)

		aAdd(oReturn["items"], oItem)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oItem)
	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} LabelTpDem
Retorna o label de cada tipo de demanda
@type  Static Function
@author Lucas Fagundes
@since 06/09/2023
@version P12
@param cTipo, Caracter, Tipo da demanda
@return cLabel, Caracter, Label para o tipo da demanda
/*/
Static Function LabelTpDem(cTipo)
	Local cLabel := ""

	If cTipo == "1"
		cLabel := STR0069 // "Pedido de venda"
	ElseIf cTipo == "2"
		cLabel := STR0070 // "Previsão de vendas"
	ElseIf cTipo == "3"
		cLabel := STR0071 // "Plano mestre"
	ElseIf cTipo == "4"
		cLabel := STR0072 // "Empenhos de projeto"
	ElseIf cTipo == "5"
		cLabel := STR0073 // "Importação CSV"
	ElseIf cTipo == "9"
		cLabel := STR0074 // "Manual"
	EndIf

Return cLabel

/*/{Protheus.doc} getPerms
Retorna se o usuário tem permissão para incluir, alterar ou excluir os registros de uma rotina.
@type  Static Function
@author Lucas Fagundes
@since 02/10/2023
@version P12
@param 01 cPrograma, Caracter, Programa que irá retornar se o usuario tem permissões
@param 02 lMvc     , Logico  , Indica que é uma rotina MVC.
@param 03 lInclui  , Logico  , Retorna por referência se o usuário tem permissão para incluir.
@param 04 lAltera  , Logico  , Retorna por referência se o usuário tem permissão para alterar.
@param 05 lExclui  , Logico  , Retorna por referência se o usuário tem permissão para excluir.
@return Nil
/*/
Static Function getPerms(cPrograma, lMvc, lInclui, lAltera, lExclui)
	Local aMenu   := {}
	Local cCodUsr := RetCodUsr()
	Local nBusca  := 0
	Local nPos    := 0

	If _oCachePer == Nil
		_oCachePer := JsonObject():New()
	EndIf

	If !_oCachePer:hasProperty(cCodUsr)
		_oCachePer[cCodUsr] := JsonObject():New()
	EndIf

	If !_oCachePer[cCodUsr]:hasProperty(cPrograma)
		_oCachePer[cCodUsr][cPrograma] := JsonObject():New()
		aMenu := FWLoadMenuDef(cPrograma)

		nBusca := Iif(lMvc, OP_VISUALIZAR, 2)
		nPos   := aScan(aMenu, {|x| x[4] == nBusca})
		If nPos > 0
			_oCachePer[cCodUsr][cPrograma]["incluir"] := MPUserHasAccess(cPrograma, nPos)
		EndIf

		nBusca := Iif(lMvc, OP_ALTERAR, 4)
		nPos   := aScan(aMenu, {|x| x[4] == nBusca})
		If nPos > 0
			_oCachePer[cCodUsr][cPrograma]["alterar"] := MPUserHasAccess(cPrograma, nPos)
		EndIf

		nBusca := Iif(lMvc, OP_EXCLUIR, 5)
		nPos   := aScan(aMenu, {|x| x[4] == nBusca})
		If nPos > 0
			_oCachePer[cCodUsr][cPrograma]["excluir"] := MPUserHasAccess(cPrograma, nPos)
		EndIf
	EndIf

	lInclui := _oCachePer[cCodUsr][cPrograma]["incluir"]
	lAltera := _oCachePer[cCodUsr][cPrograma]["alterar"]
	lExclui := _oCachePer[cCodUsr][cPrograma]["excluir"]

Return Nil

/*/{Protheus.doc} getFilsTab
Retorna um array com as filiais para realizar o filtro IN da query.
@type  Static Function
@author Lucas Fagundes
@since 11/10/2023
@version P12
@param 01 cTicket, Caracter, Ticket do MRP que irá buscar as filiais.
@param 02 cTabela, Caracter, Filial que irá filtrar na query.
@return aFiliais, Array, Array com as filiais do ticket convertido.
/*/
Static Function getFilsTab(cTicket, cTabela)
	Local aFilAux  := {}
	Local aFiliais := {}
	Local cFilAux  := ""
	Local nIndex   := 1
	Local nTotal   := 0

	If _oCacheFil == Nil
		_oCacheFil := JsonObject():New()
	EndIf

	If !_oCacheFil:hasProperty(cTicket)
		_oCacheFil[cTicket] := JsonObject():New()

		If MrpTickeME(cTicket, .F., Nil, Nil, @aFilAux)
			_oCacheFil[cTicket]["filiais"] := {}

			nTotal := Len(aFilAux)
			For nIndex := 1 To nTotal
				aAdd(_oCacheFil[cTicket]["filiais"], aFilAux[nIndex][1])
			Next
		Else
			_oCacheFil[cTicket]["filiais"] := {cFilAnt}
		EndIf

		aSize(aFilAux, 0)
	EndIf

	If !_oCacheFil[cTicket]:hasProperty(cTabela)
		_oCacheFil[cTicket][cTabela] := {}

		nTotal := Len(_oCacheFil[cTicket]["filiais"])
		For nIndex := 1 To nTotal
			cFilAux := xFilial(cTabela, _oCacheFil[cTicket]["filiais"][nIndex])

			aAdd(_oCacheFil[cTicket][cTabela], cFilAux)

			If Empty(cFilAux)
				Exit
			EndIf
		Next
	EndIf

	aFiliais := _oCacheFil[cTicket][cTabela]

Return aFiliais

/*/{Protheus.doc} GET TRANSFS api/pcp/v1/mrpdata/{ticket}/transferencias
Retorna as transferências consideradas em um ticket do MRP.
@type WSMETHOD
@author Lucas Fagundes
@since 13/12/2023
@version P12
@param 01 ticket       , Caracter, Ticket do MRP que irá buscar as transferências.
@param 02 Page         , Number  , Página de busca.
@param 03 PageSize     , Number  , Tamanho da página.
@param 04 documento    , Caracter, Filtro de documento.
@param 05 product      , Caracter, Filtro de produto.
@param 06 periodFrom   , Caracter, Filtro de data (De).
@param 07 periodTo     , Caracter, Filtro de data (Até).
@param 08 filialOrigem , Caracter, Filtro de filial origem.
@param 09 filialDestino, Caracter, Filtro de filial destino.
@param 10 status       , Caracter, Filtro de status.
@param 11 entregaDe    , Caracter, Filtro de data de recebimento (De).
@param 12 entregaAte   , Caracter, Filtro de data de recebimento (Ate).
@param 13 export       , Logical , Filtra todos os registros.
@return lRet, Logico, Indica se o processo foi executado com sucesso.
/*/
WSMETHOD GET TRANSFS PATHPARAM ticket WSRECEIVE Page, PageSize, documento, product, periodFrom, periodTo, filialOrigem, filialDestino, status, entregaDe, entregaAte, export WSSERVICE mrpdata
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "MRPData"), Break(oError)})
	Local lRet      := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getTransfs(Self:ticket, Self:page, Self:pageSize, Self:documento, Self:product, PCPConvDat(Self:periodFrom, 1), PCPConvDat(Self:periodTo, 1), Self:filialOrigem, Self:filialDestino, Self:status, PCPConvDat(Self:entregaDe, 1), PCPConvDat(Self:entregaAte, 1), Self:export)
	END SEQUENCE

	lRet := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lRet

/*/{Protheus.doc} getTransfs
Retorna as transferências consideradas em um ticket do MRP.
@type  Static Function
@author Lucas Fagundes
@since 13/12/2023
@version P12
@param 01 cTicket   , Caracter, Ticket do MRP que está consultando as transferências.
@param 02 nPage     , Numerico, Pagina de busca.
@param 03 nPageSize , Numerico, Tamanho da pagina de busca.
@param 04 cDocumento, Caracter, Filtro de documento.
@param 05 cProduto  , Caracter, Filtro de produto.
@param 06 dDataDe   , Date    , Filtro de data (De).
@param 07 dDataAte  , Date    , Filtro de data (Até).
@param 08 cFilOrig  , Caracter, Filtro de filial origem.
@param 09 cFilDest  , Caracter, Filtro de filial destino.
@param 10 cStatus   , Caracter, Filtro de status.
@param 11 dRecbDe   , Date    , Filtro de data de recebimento (De).
@param 12 dRecbAte  , Date    , Filtro de data de recebimento (Até).
@param 13 lExport   , Logical , Filtra todos os registros.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getTransfs(cTicket, nPage, nPageSize, cDocumento, cProduto, dDataDe, dDataAte, cFilOrig, cFilDest, cStatus, dRecbDe, dRecbAte, lExport)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local lDelete := .F.
	Local lEdit   := .F.
	Local lView   := .F.
	Local nCont   := 0
	Local nStart  := 0
	Local oItem   := Nil
	Local oReturn := JsonObject():New()

	Default lExport := .F.

	cQuery := " SELECT SMA.MA_DOCUM, "
	cQuery += "        SMA.MA_FILORIG, "
	cQuery += "        SMA.MA_FILDEST, "
	cQuery += "        SMA.MA_PROD, "
	cQuery += "        SB1.B1_DESC, "
	cQuery += "        SMA.MA_QTDTRAN, "
	cQuery += "        SMA.MA_DTTRANS, "
	cQuery += "        SMA.MA_STATUS, "
	cQuery += "        NNS.NNS_COD, "
	cQuery += "        SMA.MA_MSG, "
	cQuery += "        NNS.R_E_C_N_O_ recnoNNS, "
	cQuery += "        SMA.MA_ARMORIG, "
	cQuery += "        SMA.MA_DTRECEB, "
	cQuery += "        SMA.MA_ARMDEST "
	cQuery += "   FROM " + RetSqlName("SMA") + " SMA "
	cQuery += "   LEFT JOIN " + RetSqlName("NNS") + " NNS "
	cQuery += "     ON NNS.NNS_FILIAL = SMA.MA_FILORIG "
	cQuery += "    AND SMA.MA_STATUS  = '1' "
	cQuery += "    AND NNS.NNS_COD    = SMA.MA_MSG "
	cQuery += "    AND NNS.D_E_L_E_T_ = ' ' "
	cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "     ON SB1.B1_COD      = SMA.MA_PROD "
	cQuery += "    AND SB1.B1_FILIAL   = '" + xFilial("SB1") + "' "
	cQuery += "    AND SB1.D_E_L_E_T_  = ' ' "
	cQuery += "  WHERE SMA.MA_FILIAL   = '" + xFilial("SMA") + "' "
	cQuery += "    AND SMA.MA_TICKET   = '" + cTicket + "' "
	cQuery += "    AND ((SMA.MA_STATUS = '1' AND NNS.NNS_COD IS NOT NULL) OR (SMA.MA_STATUS != '1')) "
	cQuery += "    AND SMA.D_E_L_E_T_  = ' ' "

	If !Empty(cDocumento)
		cQuery += " AND CASE "
		cQuery += "         WHEN SMA.MA_STATUS = '1' THEN NNS.NNS_COD "
		cQuery += "         ELSE SMA.MA_DOCUM "
		cQuery += "      END LIKE '" + cDocumento + "%' "
	EndIf

	If !Empty(cProduto)
		cQuery += " AND SMA.MA_PROD LIKE '" + cProduto + "%' "
	EndIf

	If !Empty(dDataDe)
		cQuery += " AND SMA.MA_DTTRANS >= '" + DToS(dDataDe) + "' "
	EndIf

	If !Empty(dDataAte)
		cQuery += " AND SMA.MA_DTTRANS <= '" + DToS(dDataAte) + "' "
	EndIf

	If !Empty(cFilOrig)
		cQuery += " AND SMA.MA_FILORIG LIKE '" + cFilOrig + "%' "
	EndIf

	If !Empty(cFilDest)
		cQuery += " AND SMA.MA_FILDEST LIKE '" + cFilDest + "%' "
	EndIf

	If !Empty(cStatus)
		cQuery += " AND SMA.MA_STATUS IN ('" + StrTran(cStatus, ",", "','") + "') "
	EndIf

	If !Empty(dRecbDe)
		cQuery += " AND SMA.MA_DTRECEB >= '" + DToS(dRecbDe) + "' "
	EndIf

	If !Empty(dRecbAte)
		cQuery += " AND SMA.MA_DTRECEB <= '" + DToS(dRecbAte) + "' "
	EndIf

	cQuery += " ORDER BY SMA.MA_DTTRANS, SMA.MA_PROD, SMA.MA_FILORIG, SMA.MA_FILDEST "

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .F.)
	TcSetField(cAlias, 'MA_DTTRANS', 'D', 8, 0)
	TcSetField(cAlias, 'MA_DTRECEB', 'D', 8, 0)

	If nPage > 1 .And. !lExport
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	getPerms("MATA311", .T., @lView, @lEdit, @lDelete)

	While (cAlias)->(!EoF())
		nCont++

		oItem := JsonObject():New()
		oItem["document"  ] := Iif((cAlias)->MA_STATUS == "1", (cAlias)->NNS_COD, (cAlias)->MA_DOCUM)
		oItem["filOrigem" ] := (cAlias)->MA_FILORIG
		oItem["filDestino"] := (cAlias)->MA_FILDEST
		oItem["produto"   ] := RTrim((cAlias)->MA_PROD) + " - " + RTrim((cAlias)->B1_DESC)
		oItem["quantidade"] := (cAlias)->MA_QTDTRAN
		oItem["data"      ] := PCPConvDat(DToS((cAlias)->MA_DTTRANS), 4)
		oItem["status"    ] := (cAlias)->MA_STATUS
		oItem["message"   ] := (cAlias)->MA_MSG
		oItem["recno"     ] := (cAlias)->recnoNNS
		oItem["actions"   ] := {}
		If !lExport
			oItem["detail"    ] := {}

			aAdd(oItem["detail"], JsonObject():New())
			oItem["detail"][1]["armazemOrigem"  ] := (cAlias)->MA_ARMORIG
			oItem["detail"][1]["dataRecebimento"] := PCPConvDat(DToS((cAlias)->MA_DTRECEB), 4)
			oItem["detail"][1]["armazemDestino" ] := (cAlias)->MA_ARMDEST
		Else
			oItem["armazemOrigem"  ] := (cAlias)->MA_ARMORIG
			oItem["dataRecebimento"] := PCPConvDat(DToS((cAlias)->MA_DTRECEB), 4)
			oItem["armazemDestino" ] := (cAlias)->MA_ARMDEST
		EndIf

		If (cAlias)->MA_STATUS == "1"
			If lView
				aAdd(oItem["actions"], "view")
			EndIf

			If lEdit
				aAdd(oItem["actions"], "edit")
			EndIf

			If lDelete
				aAdd(oItem["actions"], "delete")
			EndIf
		ElseIf (cAlias)->MA_STATUS == "2"
			aAdd(oItem["actions"], "viewError")
		EndIf

		aAdd(oReturn["items"], oItem)

		(cAlias)->(dbSkip())

		If nCont >= nPageSize  .And. !lExport
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} getInSubst
Retorna a quantidade de entradas por substituição de um produto
@type Static Function
@author Marcelo Neumann
@since 20/09/2024
@version P12
@param 01 cFiliaisIN, Caracter, Filiais a serem consultadas
@param 02 cTicket   , Caracter, Ticket do MRP que está consultado
@param 03 cProduto  , Caracter, Produto a ser consultado
@param 04 cIdOpc    , Caracter, ID Opcional do produto
@return   nInSubs   , Numérico, Quantidade de entradas por substituição
/*/
Static Function getInSubst(cFiliaisIN, cTicket, cProduto, cIdOpc)
	Local cAlias  := ""
	Local cQuery  := ""
	Local nInSubs := 0

	If _oQryInSub == Nil
		cQuery := "SELECT SUM(HWC_QTSUBS) insubs" + ;
		           " FROM " + RetSqlName("HWC")   + ;
		          " WHERE HWC_FILIAL IN (?)"      + ;
		            " AND HWC_TICKET = ?"         + ;
		            " AND HWC_PRODUT = ?"         + ;
		            " AND HWC_IDOPC  = ?"         + ;
		            " AND HWC_QTSUBS > 0"         + ;
		            " AND D_E_L_E_T_ = ' '"
		_oQryInSub := FWExecStatement():New(cQuery)
		_oQryInSub:setFields({{'insubs', 'N', GetSx3Cache("HWC_QTSUBS", "X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS" ,"X3_DECIMAL")}})
	EndIf

	_oQryInSub:setUnsafe(1, cFiliaisIN)
	_oQryInSub:setString(2, cTicket)
	_oQryInSub:setString(3, cProduto)
	_oQryInSub:setString(4, cIdOpc)
	cAlias := _oQryInSub:OpenAlias()
	If (cAlias)->(!Eof())
		_oQryInSub:doTcSetField(cAlias)
		nInSubs := (cAlias)->insubs
	EndIf
	(cAlias)->(dbCloseArea())

Return nInSubs

/*/{Protheus.doc} getOutSubs
Retorna a quantidade de saídas por substituição de um produto
@type Static Function
@author Marcelo Neumann
@since 20/09/2024
@version P12
@param 01 cFiliaisIN, Caracter, Filiais a serem consultadas
@param 02 cTicket   , Caracter, Ticket do MRP que está consultado
@param 03 cProduto  , Caracter, Produto a ser consultado
@param 04 cIdOpc    , Caracter, ID Opcional do produto
@return   nOutSubs  , Numérico, Quantidade de saídas por substituição
/*/
Static Function getOutSubs(cFiliaisIN, cTicket, cProduto, cIdOpc)
	Local cAlias   := ""
	Local cQuery   := ""
	Local nOutSubs := 0

	If _oQryOutSu == Nil
		cQuery := "SELECT SUM(HWC_QTSUBS) outsubs" + ;
		           " FROM " + RetSqlName("HWC")    + ;
		          " WHERE HWC_FILIAL IN (?)"       + ;
		            " AND HWC_TICKET = ?"          + ;
		            " AND HWC_PRODUT = ?"          + ;
		            " AND HWC_IDOPC  = ?"          + ;
		            " AND HWC_QTSUBS < 0"          + ;
		            " AND D_E_L_E_T_ = ' '"
		_oQryOutSu := FWExecStatement():New(cQuery)
		_oQryOutSu:setFields({{'outsubs', 'N', GetSx3Cache("HWC_QTSUBS", "X3_TAMANHO"), GetSx3Cache("HWC_QTSUBS" ,"X3_DECIMAL")}})
	EndIf

	_oQryOutSu:setUnsafe(1, cFiliaisIN)
	_oQryOutSu:setString(2, cTicket)
	_oQryOutSu:setString(3, cProduto)
	_oQryOutSu:setString(4, cIdOpc)
	cAlias := _oQryOutSu:OpenAlias()
	If (cAlias)->(!Eof())
		_oQryOutSu:doTcSetField(cAlias)
		nOutSubs := (cAlias)->outsubs
	EndIf
	(cAlias)->(dbCloseArea())

Return nOutSubs

/*/{Protheus.doc} getLotVenc
Retorna a quantidade total vencida
@type Static Function
@author Marcelo Neumann
@since 20/09/2024
@version P12
@param 01 cFiliaisIN, Caracter, Filiais a serem consultadas
@param 02 cTicket   , Caracter, Ticket do MRP que está consultado
@param 03 cProduto  , Caracter, Produto a ser consultado
@param 04 cIdOpc    , Caracter, ID Opcional do produto
@return   nLtVenc   , Numérico, Quantidade total vencida
/*/
Static Function getLotVenc(cFiliaisIN, cTicket, cProduto, cIdOpc)
	Local cAlias  := ""
	Local cQuery  := ""
	Local nLtVenc := 0

	If _oQryLotVe == Nil
		cQuery := "SELECT SUM(HWC_QTNEOR) expiredBatch" + ;
		           " FROM " + RetSqlName("HWC")         + ;
		          " WHERE HWC_FILIAL IN (?)"            + ;
		            " AND HWC_TICKET = ?"               + ;
		            " AND HWC_PRODUT = ?"               + ;
		            " AND HWC_IDOPC  = ?"               + ;
		            " AND HWC_TPDCPA = 'LTVENC'"        + ;
		            " AND D_E_L_E_T_ = ' '"
		_oQryLotVe := FWExecStatement():New(cQuery)
		_oQryLotVe:setFields({{"expiredBatch", "N", _aTamQtd[1], _aTamQtd[2]}})
	EndIf

	_oQryLotVe:setUnsafe(1, cFiliaisIN)
	_oQryLotVe:setString(2, cTicket)
	_oQryLotVe:setString(3, cProduto)
	_oQryLotVe:setString(4, cIdOpc)
	cAlias := _oQryLotVe:OpenAlias()
	If (cAlias)->(!Eof())
		_oQryLotVe:doTcSetField(cAlias)
		nLtVenc := (cAlias)->expiredBatch
	EndIf
	(cAlias)->(dbCloseArea())

Return nLtVenc

/*/{Protheus.doc} getPlanMes
Retorna a quantidade referente aos planos mestres
@type Static Function
@author Marcelo Neumann
@since 20/09/2024
@version P12
@param 01 cFiliaisIN, Caracter, Filiais a serem consultadas
@param 02 cTicket   , Caracter, Ticket do MRP que está consultado
@param 03 cProduto  , Caracter, Produto a ser consultado
@param 04 cIdOpc    , Caracter, ID Opcional do produto
@return   nPMP      , Numérico, Quantidade referente aos planos mestres
/*/
Static Function getPlanMes(cFiliaisIN, cTicket, cProduto, cIdOpc)
	Local cAlias := ""
	Local cQuery := ""
	Local nPMP   := 0

	If _oQryPlanM == Nil
		cQuery := "SELECT SUM(HWC_QTNEOR) masterPlan"   + ;
		           " FROM " + RetSqlName("HWC")         + ;
		          " WHERE HWC_FILIAL IN (?)"            + ;
		            " AND HWC_TICKET = ?"               + ;
		            " AND HWC_PRODUT = ?"               + ;
		            " AND HWC_IDOPC  = ?"               + ;
		            " AND HWC_TPDCPA IN ('1','SUBPRD')" + ;
		            " AND D_E_L_E_T_ = ' '"
		_oQryPlanM := FWExecStatement():New(cQuery)
		_oQryPlanM:setFields({{"masterPlan", "N", _aTamQtd[1], _aTamQtd[2]}})
	EndIf

	_oQryPlanM:setUnsafe(1, cFiliaisIN)
	_oQryPlanM:setString(2, cTicket)
	_oQryPlanM:setString(3, cProduto)
	_oQryPlanM:setString(4, cIdOpc)
	cAlias := _oQryPlanM:OpenAlias()
	If (cAlias)->(!Eof())
		_oQryPlanM:doTcSetField(cAlias)
		nPMP := (cAlias)->masterPlan
	EndIf
	(cAlias)->(dbCloseArea())

Return nPMP

/*/{Protheus.doc} getHasAglu
Retorna se existe aglutinação no produto
@type Static Function
@author Marcelo Neumann
@since 20/09/2024
@version P12
@param 01 cFiliaisIN, Caracter, Filiais a serem consultadas
@param 02 cTicket   , Caracter, Ticket do MRP que está consultado
@param 03 cProduto  , Caracter, Produto a ser consultado
@param 04 cIdOpc    , Caracter, ID Opcional do produto
@return   lHasAgl   , Lógico  , Indica se existe aglutinação
/*/
Static Function getHasAglu(cFiliaisIN, cTicket, cProduto, cIdOpc)
	Local cAlias  := ""
	Local cQuery  := ""
	Local lHasAgl := .F.

	If _lAgluMrp == Nil
		dbSelectArea("HWB")
		_lAgluMrp := (FieldPos("HWB_AGLPRD") > 0)
	EndIf

	If !_lAgluMrp
		Return .F.
	EndIf

	If _oQryHasAg == Nil
		cQuery := "SELECT MAX(HWB_AGLPRD) hasAglMrp"    + ;
		           " FROM " + RetSqlName("HWB")         + ;
		          " WHERE HWB_FILIAL IN (?)"            + ;
		            " AND HWB_TICKET = ?"               + ;
		            " AND HWB_PRODUT = ?"               + ;
		            " AND HWB_IDOPC  = ?"               + ;
		            " AND HWB_AGLPRD NOT IN (' ', '0')" + ;
		            " AND D_E_L_E_T_ = ' '"
		_oQryHasAg := FWExecStatement():New(cQuery)
	EndIf

	_oQryHasAg:setUnsafe(1, cFiliaisIN)
	_oQryHasAg:setString(2, cTicket)
	_oQryHasAg:setString(3, cProduto)
	_oQryHasAg:setString(4, cIdOpc)
	cAlias := _oQryHasAg:OpenAlias()
	If (cAlias)->(!Eof())
		lHasAgl := !Empty((cAlias)->hasAglMrp)
	EndIf
	(cAlias)->(dbCloseArea())

Return lHasAgl

/*/{Protheus.doc} getSaldoEs
Retorna a quantidade de saldo em estoque
@type Static Function
@author Marcelo Neumann
@since 20/09/2024
@version P12
@param 01 cFiliaisIN, Caracter, Filiais a serem consultadas
@param 02 cTicket   , Caracter, Ticket do MRP que está consultado
@param 03 cProduto  , Caracter, Produto a ser consultado
@param 04 cIdOpc    , Caracter, ID Opcional do produto
@return   nEstoque  , Numérico, Quantidade de saldo em estoque
/*/
Static Function getSaldoEs(cFiliaisIN, cTicket, cProduto, cIdOpc)
	Local cAlias   := ""
	Local cQuery   := ""
	Local nEstoque := 0

	If _oQryEstoq == Nil
		cQuery := "SELECT SUM(HWB_QTSLES) stockBalance"     + ;
		           " FROM " + RetSqlName("HWB") + " HWBEst" + ;
		          " WHERE HWBEst.HWB_FILIAL IN (?)"         + ;
		            " AND HWBEst.HWB_TICKET = ?"            + ;
		            " AND HWBEst.HWB_PRODUT = ?"            + ;
		            " AND HWBEst.HWB_IDOPC  = ?"            + ;
		            " AND HWBEst.HWB_DATA   = (SELECT Min(HWBEst_B.HWB_DATA)"             + ;
		                                       " FROM " + RetSqlName("HWB") + " HWBEst_B" + ;
		                                      " WHERE HWBEst_B.HWB_FILIAL IN (?)"         + ;
		                                        " AND HWBEst_B.HWB_TICKET = ?"            + ;
		                                        " AND HWBEst_B.HWB_PRODUT = ?"            + ;
		                                        " AND HWBEst_B.HWB_IDOPC  = ?"            + ;
		                                        " AND HWBEst_B.D_E_L_E_T_ = ' ')"         + ;
		            " AND HWBEst.D_E_L_E_T_ = ' '"
		_oQryEstoq := FWExecStatement():New(cQuery)
		_oQryEstoq:setFields({{"stockBalance", "N", _aTamQtd[1], _aTamQtd[2]}})
	EndIf

	_oQryEstoq:setUnsafe(1, cFiliaisIN)
	_oQryEstoq:setString(2, cTicket)
	_oQryEstoq:setString(3, cProduto)
	_oQryEstoq:setString(4, cIdOpc)
	_oQryEstoq:setUnsafe(5, cFiliaisIN)
	_oQryEstoq:setString(6, cTicket)
	_oQryEstoq:setString(7, cProduto)
	_oQryEstoq:setString(8, cIdOpc)
	cAlias := _oQryEstoq:OpenAlias()
	If (cAlias)->(!Eof())
		_oQryEstoq:doTcSetField(cAlias)
		nEstoque := (cAlias)->stockBalance
	EndIf
	(cAlias)->(dbCloseArea())

Return nEstoque

/*/{Protheus.doc} getHasEven
Retorna se existe log de eventos
@type Static Function
@author Marcelo Neumann
@since 20/09/2024
@version P12
@param 01 cFiliaisIN, Caracter, Filiais a serem consultadas
@param 02 cTicket   , Caracter, Ticket do MRP que está consultado
@param 03 cProduto  , Caracter, Produto a ser consultado
@return   lEventos  , Lógico  , Indica se existe log de eventos
/*/
Static Function getHasEven(cFiliaisIN, cTicket, cProduto)
	Local cAlias   := ""
	Local cQuery   := ""
	Local lEventos := .F.

	If _oQryEvent == Nil
		cQuery := "SELECT DISTINCT HWM_TICKET eventos" + ;
		           " FROM " + RetSqlName("HWM")        + ;
		          " WHERE HWM_FILIAL IN (?)"           + ;
		            " AND HWM_TICKET = ?"              + ;
		            " AND HWM_PRODUT = ?"              + ;
		            " AND D_E_L_E_T_ = ' '"
		_oQryEvent := FWExecStatement():New(cQuery)
	EndIf

	_oQryEvent:setUnsafe(1, cFiliaisIN)
	_oQryEvent:setString(2, cTicket)
	_oQryEvent:setString(3, cProduto)
	cAlias := _oQryEvent:OpenAlias()
	If (cAlias)->(!Eof())
		lEventos := !Empty((cAlias)->eventos)
	EndIf
	(cAlias)->(dbCloseArea())

Return lEventos

/*/{Protheus.doc} getSaldoEs
Retorna a quantidade de saldo em estoque
@type Static Function
@author Marcelo Neumann
@since 20/09/2024
@version P12
@param 01 cFiliaisIN, Caracter, Filiais a serem consultadas
@param 02 cTicket   , Caracter, Ticket do MRP que está consultado
@param 03 cProduto  , Caracter, Produto a ser consultado
@param 04 cIdOpc    , Caracter, ID Opcional do produto
@param 05 lMultiEmp , Lógico  , Indica se deve buscar as quantidades de transferência
@return   oQtdsHWB, Objeto  , JSON com as quantidades da HWB
/*/
Static Function getQtdsHWB(cFiliaisIN, cTicket, cProduto, cIdOpc, lMultiEmp)
	Local cAlias   := ""
	Local cQuery   := ""
	Local oQtdsHWB := JsonObject():New()

	If _oQryHWB == Nil
		cQuery := "SELECT SUM(HWB_QTENTR) inFlows,"           + ;
						" SUM(HWB_QTSAID) outFlows,"          + ;
						" SUM(HWB_QTSEST) structureOutFlows," + ;
						" SUM(HWB_QTNECE) necessityQuantity"
		If lMultiEmp
			cQuery +=  ", SUM(HWB_QTRENT) transferIn"         + ;
			           ", SUM(HWB_QTRSAI) transferOut"
		EndIf
		cQuery +=  " FROM " + RetSqlName("HWB")               + ;
		          " WHERE HWB_FILIAL IN (?)"                  + ;
		            " AND HWB_TICKET = ?"                     + ;
		            " AND HWB_PRODUT = ?"                     + ;
		            " AND HWB_IDOPC  = ?"                     + ;
		            " AND D_E_L_E_T_ = ' '"
		_oQryHWB := FWExecStatement():New(cQuery)
		_oQryHWB:setFields({{"inFlows"          , "N", _aTamQtd[1], _aTamQtd[2]}, ;
		                    {"outFlows"         , "N", _aTamQtd[1], _aTamQtd[2]}, ;
		                    {"structureOutFlows", "N", _aTamQtd[1], _aTamQtd[2]}, ;
		                    {"necessityQuantity", "N", _aTamQtd[1], _aTamQtd[2]}, ;
		                    {"transferIn"       , "N", _aTamQtd[1], _aTamQtd[2]}, ;
		                    {"transferOut"      , "N", _aTamQtd[1], _aTamQtd[2]}} )
	EndIf

	_oQryHWB:setUnsafe(1, cFiliaisIN)
	_oQryHWB:setString(2, cTicket)
	_oQryHWB:setString(3, cProduto)
	_oQryHWB:setString(4, cIdOpc)
	cAlias := _oQryHWB:OpenAlias()
	If (cAlias)->(!Eof())
		_oQryHWB:doTcSetField(cAlias)
		oQtdsHWB["inFlows"          ] := (cAlias)->inFlows
		oQtdsHWB["outFlows"         ] := (cAlias)->outFlows
		oQtdsHWB["structureOutFlows"] := (cAlias)->structureOutFlows
		oQtdsHWB["necessityQuantity"] := (cAlias)->necessityQuantity
		If lMultiEmp
			oQtdsHWB["transferIn"   ] := (cAlias)->transferIn
			oQtdsHWB["transferOut"  ] := (cAlias)->transferOut
		Else
			oQtdsHWB["transferIn"   ] := 0
			oQtdsHWB["transferOut"  ] := 0
		EndIf
	EndIf
	(cAlias)->(dbCloseArea())

Return oQtdsHWB

/*/{Protheus.doc} GET ALLEMPENHOS api/pcp/v1/mrpdata/{ticket}/allempenhos
Retorna os empenhos consideradas e criadas em um ticket do MRP.
@type WSMETHOD
@author Breno Ferreira
@since 02/10/2024
@version P12
@param 01 ticket    , Caracter, Ticket do MRP que irá buscar os empenhos.
@param 02 Page      , Number  , Página de busca
@param 03 PageSize  , Number  , Tamanho da página
@param 04 productEMP, Caracter, Filtro produto.
@param 05 periodFrom, Caracter, Filtro data do empenho (De).
@param 06 periodTo  , Caracter, Filtro data do empenho (Até).
@param 07 ordem     , Caracter, Filtro de ordem de produção.
@param 08 product   , Caracter, Filtro de produto pai.
@param 09 tipo      , Caracter, Filtro de tipo da ordem.
@param 10 inicioDe  , Caracter, Filtro de data de inicio da ordem (De).
@param 11 inicioAte , Caracter, Filtro de data de inicio da ordem (Até).
@param 12 entregaDe , Caracter, Filtro de data de entrega da ordem (De).
@param 13 entregaAte, Caracter, Filtro de data de entrega da ordem (Até).
@param 14 origem    , Caracter, Filtro de origem.
@param 15 branchId  , Caracter, Filtro de filial.
@param 16 export    , Logical , Filtro para paginação
@return lRet, Logico, Indica se teve sucesso na requisição.
/*/
WSMETHOD GET ALLEMPENHOS PATHPARAM ticket WSRECEIVE Page, PageSize, productEMP, periodFrom, periodTo, ordem, product, tipo, inicioDe, inicioAte, entregaDe, entregaAte, origem, branchId, export WSSERVICE mrpdata
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "MRPData"), Break(oError)})
	Local lRet      := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getEmpAll(Self:ticket, Self:Page, Self:PageSize, Self:productEMP, PCPConvDat(Self:periodFrom, 1), PCPConvDat(Self:periodTo, 1),  Self:ordem, Self:product, Self:tipo, PCPConvDat(Self:inicioDe, 1), PCPConvDat(Self:inicioAte, 1), PCPConvDat(Self:entregaDe, 1), PCPConvDat(Self:entregaAte, 1), Self:origem, Self:branchId, Self:export)
	END SEQUENCE

	lRet := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lRet

/*{Protheus.doc} getEmpAll
Retorna os empenhos de um ticket do MRP.
@type  Static Function
@author Breno Ferreira
@since 02/10/2024
@version P12
@param 01 cTicket   , Caracter, Ticket do MRP que irá buscar os empenhos.
@param 02 nPage     , Numerico, Página de busca.
@param 03 nPageSize , Numerico, Tamanho da página.
@param 04 cProdEmp  , Caracter, Filtro de produto do empenho.
@param 05 dDataDe   , Date,   , Filtro data do empenho (De).
@param 06 dDataAte  , Date,   , Filtro data do empenho (Até).
@param 07 cOrdem    , Caracter, Filtro de ordem de produção.
@param 08 cProdOP   , Caracter, Filtro de produto da ordem.
@param 09 cTipo     , Caracter, Filtro de tipo da ordem.
@param 10 dInicioDe , Date    , Filtro de data de inicio da ordem (De).
@param 11 dInicioAte, Date    , Filtro de data de inicio da ordem (Até).
@param 12 dEntregaDe, Date    , Filtro de data de entrega da ordem (De).
@param 13 dEntregaAt, Date    , Filtro de data de entrega da ordem (Até).
@param 14 cOrigem   , Caracter, Filtro de origem.
@param 15 cFilAux   , Caracter, Filtro de filial.
@param 16 lExport   , Logical , Filtro para paginação.
@return aReturn, Array, Array com as informações para retorno da API.
*/
Static Function getEmpAll(cTicket, nPage, nPageSize, cProdEmp, dDataDe, dDataAte, cOrdem, cProdOP, cTipo, dInicioDe, dInicioAte, dEntregaDe, dEntregaAt, cOrigem, cFilAux, lExport)
	Local aReturn   := Array(3)
	Local cAlias    := ""
	Local cBanco    := ""
	Local cFiltro   := ""
	Local cQuery    := ""
	Local lDelete   := .F.
	Local lEdit     := .F.
	Local lView     := .F.
	Local nCont     := 0
	Local nStart    := 0
	Local oItem     := Nil
	Local oReturn   := JsonObject():New()

	Default lExport := .F.

	If _oQryEmpAll == Nil
		cBanco := TcGetDB()

		cQuery += " SELECT SD4.D4_FILIAL filial, "
		cQuery += "        SD4.D4_OP ordemProd, "
		cQuery += "        SD4.D4_COD produto, "
		cQuery += "        SB1.B1_DESC descricao, "
		cQuery += "        SD4.D4_LOCAL armazem, "
		cQuery += "        SD4.D4_DATA data, "
		cQuery += "        SD4.D4_QTDEORI quantidade, "
		cQuery += "        SD4.D4_QUANT saldo,        "
		cQuery += "        SD4.D4_LOTECTL lote, "
		cQuery += "        SD4.D4_NUMLOTE subLote, "
		cQuery += "        SD4.D4_OPORIG opOrigem, "
		cQuery += "        SC2.C2_PRODUTO produtoPai, "
		cQuery += "        SD4.D4_OPERAC operacao, "
		cQuery += "        SD4.D4_PRDORG produtoOri, "
		cQuery += "        SD4.R_E_C_N_O_ recno "
		cQuery += "   FROM " + RetSqlName("SD4") + " SD4 "
		cQuery += "   LEFT JOIN " + RetSqlName("SMV") + " SMV "
		cQuery += "     ON SMV.MV_FILIAL IN (?) "
		cQuery += "    AND SMV.MV_TICKET = ? "
		cQuery += "    AND SMV.MV_TABELA = 'T4S' "
		If cBanco == "POSTGRES"
			cQuery += "AND TRIM(SMV.MV_DOCUM) = TRIM(CONCAT(RTRIM(SD4.D4_PRODUTO), '|', "
			cQuery +=                                     " RTRIM(SD4.D4_FILIAL), ';', "
			cQuery +=                                     " RTRIM(SD4.D4_COD), ';', "
			cQuery +=                                     " RTRIM(SD4.D4_SEQ), ';', "
			cQuery +=                                     " RTRIM(SD4.D4_LOCAL), ';', "
			cQuery +=                                     " RTRIM(SD4.D4_OP), ';', "
			cQuery +=                                     " RTRIM(SD4.D4_OPORIG), ';', "
			cQuery +=                                     " SD4.D4_DATA)) "
		Else
			cQuery += "AND RTRIM(SMV.MV_DOCUM) = RTRIM(RTRIM(SD4.D4_PRODUTO) || '|' || "
			cQuery +=                                " RTRIM(SD4.D4_FILIAL) || ';' || "
			cQuery +=                                " RTRIM(SD4.D4_COD) || ';' || "
			cQuery +=                                " RTRIM(SD4.D4_SEQ) || ';' || "
			cQuery +=                                " RTRIM(SD4.D4_LOCAL) || ';' || "
			cQuery +=                                " RTRIM(SD4.D4_OP) || ';' || "
			cQuery +=                                " RTRIM(SD4.D4_OPORIG) || ';' || "
			cQuery +=                                " SD4.D4_DATA) "
		EndIf
		cQuery += "    AND SMV.D_E_L_E_T_ = ' ' "
		cQuery += "   LEFT JOIN " + RetSqlName("HWC") + " HWC "
		cQuery += "     ON HWC.HWC_FILIAL IN (?) "
		cQuery += "    AND HWC_TICKET = ? "
		cQuery += "    AND HWC.HWC_TDCERP IN ('1', '4') "
		cQuery += "    AND HWC.HWC_DOCERP = SD4.D4_OP "
		cQuery += "    AND HWC.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "     ON SB1.B1_FILIAL IN (?) "
		cQuery += "    AND SB1.B1_COD = SD4.D4_COD "
		cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN " + RetSqlName("SC2") +" SC2 "
		cQuery += "     ON SC2.C2_FILIAL IN (?) "
		If cBanco == "POSTGRES"
			cQuery += "        AND TRIM(CONCAT(SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD)) = TRIM(SD4.D4_OP) "
		Else
			cQuery += "        AND " + PCPQrySC2("SC2", "SD4.D4_OP")
		EndIf
		cQuery += "    AND SC2.D_E_L_E_T_ = ' '
		cQuery += "  WHERE SD4.D4_FILIAL IN (?) "
		cQuery += "    AND (SMV.MV_TICKET IS NOT NULL OR HWC.HWC_TICKET IS NOT NULL) "
		cQuery += "    AND SD4.D_E_L_E_T_ = ' ' "
		cQuery += "    AND ? "
		cQuery += "  ORDER BY ordemProd, produto, data "

		If "MSSQL" $ cBanco
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQryEmpAll := FwExecStatement():New()
		_oQryEmpAll:setQuery(cQuery)
		_oQryEmpAll:setFields({{"data", "D", 8, 0}})
	EndIf

	cFiltro  := " 1=1 "

	If !Empty(cOrdem)
		cBanco := TcGetDB()

		If cBanco == "POSTGRES"
			cFiltro += " AND CONCAT(SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD) LIKE '" + cOrdem + "%' "
		Else
			cFiltro += " AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD LIKE '" + cOrdem + "%' "
		EndIf

		If "MSSQL" $ cBanco
			cFiltro := StrTran(cFiltro, "||", "+")
		EndIf
	EndIf

	If cProdOP != Nil
		cFiltro += " AND SC2.C2_PRODUTO LIKE '" + cProdOP + "%' "
	EndIf

	If cTipo != Nil
		cFiltro += " AND SC2.C2_TPOP IN ('" + StrTran(cTipo, ",", "','") + "') "
	EndIf

	If !Empty(dInicioDe)
		cFiltro += " AND SC2.C2_DATPRI >= '" + DToS(dInicioDe) + "' "
	EndIf

	If !Empty(dInicioAte)
		cFiltro += " AND SC2.C2_DATPRI <= '" + DToS(dInicioAte) + "' "
	EndIf

	If !Empty(dEntregaDe)
		cFiltro += " AND SC2.C2_DATPRF >= '" + DToS(dEntregaDe) + "' "
	EndIf

	If !Empty(dEntregaAt)
		cFiltro += " AND SC2.C2_DATPRF <= '" + DToS(dEntregaAt) + "' "
	EndIf

	If cProdEmp != Nil
		cFiltro += " AND SD4.D4_COD LIKE '" + cProdEmp + "%' "
	EndIf

	If !Empty(dDataDe)
		cFiltro += " AND SD4.D4_DATA >= '" + DToS(dDataDe) + "' "
	EndIf

	If !Empty(dDataAte)
		cFiltro += " AND SD4.D4_DATA <= '" + DToS(dDataAte) + "' "
	EndIf

	If cOrigem != Nil
		cFiltro += " AND CASE "
		cFiltro += "        WHEN SMV.MV_TICKET IS NULL THEN 'M' "
		cFiltro += "        ELSE 'P' "
		cFiltro += "     END IN ('" + StrTran(cOrigem, ",", "','") + "') "
	EndIf

	_oQryEmpAll:setIn(1, Iif(Empty(cFilAux), getFilsTab(cTicket, "SMV"), {xFilial("SMV", cFilAux)})) // MV_FILIAL
	_oQryEmpAll:setString(2, cTicket) // MV_TICKET
	_oQryEmpAll:setIn(3, Iif(Empty(cFilAux), getFilsTab(cTicket, "HWC"), {xFilial("HWC", cFilAux)})) // HWC_FILIAL
	_oQryEmpAll:setString(4, cTicket) // HWC_TICKET
	_oQryEmpAll:setIn(5, Iif(Empty(cFilAux), getFilsTab(cTicket, "SB1"), {xFilial("SB1", cFilAux)})) // B1_FILIAL
	_oQryEmpAll:setIn(6, Iif(Empty(cFilAux), getFilsTab(cTicket, "SC2"), {xFilial("SC2", cFilAux)})) // C2_FILIAL
	_oQryEmpAll:setIn(7, Iif(Empty(cFilAux), getFilsTab(cTicket, "SD4"), {xFilial("SD4", cFilAux)})) // D4_FILIAL
	_oQryEmpAll:setUnsafe(8, cFiltro)

	cAlias := _oQryEmpAll:openAlias()

	If nPage > 1 .And. !lExport
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	getPerms("MATA381", .F., @lView, @lEdit, @lDelete)

	While (cAlias)->(!EoF())
		nCont++
		oItem := JsonObject():New()

		oItem["filial"    ] := (cAlias)->filial
		oItem["ordemProd" ] := (cAlias)->ordemProd
		oItem["produto"   ] := i18n("#1[produto]# - #2[descricao]#", {RTrim((cAlias)->produto), RTrim((cAlias)->descricao)})
		oItem["data"      ] := PCPConvDat(DToS((cAlias)->data), 4)
		oItem["quantidade"] := (cAlias)->quantidade
		oItem["saldo"     ] := (cAlias)->saldo
		oItem["armazem"   ] := (cAlias)->armazem
		oItem["produtoPai"] := (cAlias)->produtoPai
		oItem["lote"      ] := (cAlias)->lote
		oItem["subLote"   ] := (cAlias)->subLote
		oItem["opOrigem"  ] := (cAlias)->opOrigem
		oItem["operacao"  ] := (cAlias)->operacao
		oItem["produtoOri"] := (cAlias)->produtoOri
		oItem["recno"     ] := (cAlias)->recno
		oItem["actions"   ] := {}

		If lView
			aAdd(oItem["actions"], "view")
		EndIf

		If lEdit
			aAdd(oItem["actions"], "edit")
		EndIf

		If lDelete
			aAdd(oItem["actions"], "delete")
		EndIf

		aAdd(oReturn["items"], oItem)

		(cAlias)->(dbSkip())

		If nCont >= nPageSize .And. !lExport
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oItem)
	FwFreeObj(oReturn)
Return aReturn

/*{Protheus.doc} GET ALLDEMANDAS api/pcp/v1/mrpdata/{ticket}/alldemandas
Retorna as demandas consideradas em um ticket do MRP.
@type WSMETHOD
@author breno ferreira
@since 02/10/2024
@version P12
@param 01 ticket    , Caracter, Ticket do MRP que irá buscar as demandas.
@param 02 Page      , Number  , Página de busca.
@param 03 PageSize  , Number  , Tamanho da página.
@param 04 demanda   , Caracter, Filtro código da demanda.
@param 05 inicioDe  , Caracter, Filtro inicio das demnadas (De).
@param 06 inicioAte , Caracter, Filtro inicio das demnadas (Até).
@param 07 entregaDe , Caracter, Filtro fim das demandas (De).
@param 08 entregaAte, Caracter, Filtro fim das demandas (Até).
@param 09 product   , Caracter, Filtro produto.
@param 09 periodFrom, Caracter, Filtro data da demanda (De).
@param 09 periodTo  , Caracter, Filtro data da demanda (Até).
@param 09 tipo      , Caracter, Filtro tipo de demanda.
@param 09 documento , Caracter, Filtro documento da demanda.
@param 10 branchId  , Caracter, Filtro de filial.
@param 11 export    , Logical , Filtro para paginação
@return lRet, Logico, Indica se o processo foi executado com sucesso.
*/
WSMETHOD GET ALLDEMANDAS PATHPARAM ticket WSRECEIVE Page, PageSize, demanda, inicioDe, inicioAte, entregaDe, entregaAte, product, periodFrom, periodTo, tipo, documento, branchId, export WSSERVICE mrpdata
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "MRPData"), Break(oError)})
	Local lRet      := .T.

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getAllDem(Self:ticket, Self:Page, Self:PageSize, Self:demanda, PCPConvDat(Self:inicioDe, 1), PCPConvDat(Self:inicioAte, 1), PCPConvDat(Self:entregaDe, 1), PCPConvDat(Self:entregaAte, 1), Self:product, PCPConvDat(Self:periodFrom, 1), PCPConvDat(Self:periodTo, 1), Self:tipo, Self:documento, Self:branchId, Self:export)
	END SEQUENCE

	lRet := PCPVldRErr(Self, aReturn, @bErrorBlk)
Return lRet

/*{Protheus.doc} getAllDem
Retorna as demandas consideradas em um ticket do MRP.
@type  Static Function
@author Breno Ferreira
@since 02/10/2024
@version P12
@param 01 cTicket   , Caracter, Ticket do MRP que irá buscar os empenhos.
@param 02 nPage     , Numerico, Página de busca
@param 03 nPageSize , Numerico, Tamanho da página
@param 04 cDemanda  , Caracter, Filtro código da demanda.
@param 05 dInicioDe , Date    , Filtro inicio das demandas (De).
@param 06 dInicioAte, Date    , Filtro inicio das demandas (Até).
@param 07 dFimDe    , Date    , Filtro fim das demandas (De).
@param 08 dFimAte   , Date    , Filtro fim das demandas (Até).
@param 09 cProduto  , Caracter, Filtro produto.
@param 10 dDataDe   , Date    , Filtro da demanda (De).
@param 11 dDataAte  , Date    , Filtro da demanda (Até).
@param 12 cTipo     , Caracter, Filtro tipo de demanda.
@param 13 cDocumento, Caracter, Filtro documento da demanda.
@param 14 cFilAux   , Caracter, Filtro de filial.
@Param 15 lExport   , Logical , Filtro para paginação
@return aReturn, Array, Array com as informações para retorno da API.
*/
Static Function getAllDem(cTicket, nPage, nPageSize, cDemanda, dInicioDe, dInicioAte, dFimDe, dFimAte, cProduto, dDataDe, dDataAte, cTipo, cDocumento, cFilAux, lExport)
	Local aReturn := Array(3)
	Local cAlias  := ""
	Local cBanco  := ""
	Local cFiltro := ""
	Local cQuery  := ""
	Local lDelete := .F.
	Local lEdit   := .F.
	Local lView   := .F.
	Local nCont   := 0
	Local nStart  := 0
	Local nTamSeq := 0
	Local oItem   := Nil
	Local oReturn := JsonObject():New()

	Default lExport := .F.

	If _oQryAllDem == Nil
		cBanco  := TCGetDB()

		cQuery += " SELECT SVR.VR_FILIAL filial, "
		cQuery += "        SVR.VR_PROD produto, "
		cQuery += "        SB1.B1_DESC descricao, "
		cQuery += "        SVR.VR_DATA data, "
		cQuery += "        SVR.VR_QUANT quantidade, "
		cQuery += "        SVR.VR_LOCAL armazem, "
		cQuery += "        SVR.VR_DOC documento, "
		cQuery += "        SVR.VR_TIPO tipo, "
		cQuery += "        SVB.VB_CODIGO codigo, "
		cQuery += "        SVR.VR_SEQUEN sequencia, "
		cQuery += "        SVB.R_E_C_N_O_ recno "
		cQuery += "   FROM " + RetSqlName("SVR") + " SVR "
		cQuery += "  INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "     ON SB1.B1_FILIAL = ? "
		cQuery += "    AND SB1.B1_COD = SVR.VR_PROD "
		cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "  INNER JOIN " + RetSqlName("SMV") + " SMV "
		cQuery += "     ON SMV.MV_FILIAL = SVR.VR_FILIAL "
		cQuery += "    AND SMV.MV_TICKET = ? "
		cQuery += "    AND SMV.MV_TABELA = 'T4J' "
		If cBanco == "POSTGRES"
			cQuery += "AND TRIM(SMV.MV_DOCUM) = TRIM(CONCAT(SVR.VR_FILIAL, SVR.VR_CODIGO, SVR.VR_SEQUEN)) "
		Else
			nTamSeq := GetSx3Cache("VR_SEQUEN", "X3_TAMANHO")

			cQuery += "AND RTRIM(SMV.MV_DOCUM) = RTRIM(SVR.VR_FILIAL||SVR.VR_CODIGO||CAST(SVR.VR_SEQUEN AS VARCHAR(" + cValToChar(nTamSeq) + "))) "
		EndIf
		cQuery += "    AND SMV.D_E_L_E_T_ = ' ' "

		cQuery += "   INNER JOIN " + RetSqlName("SVB") + " SVB "
		cQuery += "      ON SVB.VB_FILIAL = SVR.VR_FILIAL "
		cQuery += "     AND SVB.VB_CODIGO = SVR.VR_CODIGO "
		cQuery += "     AND SVB.D_E_L_E_T_ = ' ' "

		cQuery += "  WHERE SVR.VR_FILIAL IN (?) "
		cQuery += "    AND SVR.D_E_L_E_T_ = ' ' "
		cQuery += "    AND ? "
		cQuery += "  ORDER BY produto, data, tipo "

		If "MSSQL" $ cBanco
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		_oQryAllDem := FwExecStatement():New()
		_oQryAllDem:setQuery(cQuery)
		_oQryAllDem:setFields({{"data", "D", 8, 0}})
	EndIf

	_oQryAllDem:setString(1, xFilial("SB1", cFilAux))
	_oQryAllDem:setString(2, cTicket) // MV_TICKET
	_oQryAllDem:setIn(3, Iif(Empty(cFilAux), getFilsTab(cTicket, "SVR"), {xFilial("SVR", cFilAux)}))

	cFiltro := " 1=1 "

	If cDemanda != Nil
		cFiltro += " AND SVB.VB_CODIGO LIKE '" + cDemanda + "%' "
	EndIf

	If !Empty(dInicioDe)
		cFiltro += " AND SVB.VB_DTINI >= '" + DToS(dInicioDe) + "' "
	EndIf

	If !Empty(dInicioAte)
		cFiltro += " AND SVB.VB_DTINI <= '" + DToS(dInicioAte) + "' "
	EndIf

	If !Empty(dFimDe)
		cFiltro += " AND SVB.VB_DTFIM >= '" + DToS(dFimDe) + "' "
	EndIf

	If !Empty(dFimAte)
		cFiltro += " AND SVB.VB_DTFIM <= '" + DToS(dFimAte) + "' "
	EndIf

	If cProduto != Nil
		cFiltro += " AND SVR.VR_PROD LIKE '" + cProduto + "%' "
	EndIf

	If !Empty(dDataDe)
		cFiltro += " AND SVR.VR_DATA >= '" + DToS(dDataDe) + "' "
	EndIf

	If !Empty(dDataAte)
		cFiltro += " AND SVR.VR_DATA <= '" + DToS(dDataAte) + "' "
	EndIf

	If cTipo != Nil
		cFiltro += " AND SVR.VR_TIPO IN ('" + StrTran(cTipo, ",", "','") + "') "
	EndIf

	If cDocumento != Nil
		cFiltro += " AND SVR.VR_DOC LIKE '" + cDocumento + "%' "
	EndIf

	_oQryAllDem:setUnsafe(4, cFiltro)

	cAlias := _oQryAllDem:openAlias()

	If nPage > 1 .And. !lExport
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	getPerms("PCPA136", .T., @lView, @lEdit, @lDelete)

	While (cAlias)->(!EoF())
		nCont++
		oItem := JsonObject():New()

		oItem["filial"    ] := (cAlias)->filial
		oItem["produto"   ] := i18n("#1[produto]# - #2[descricao]#", {RTrim((cAlias)->produto), RTrim((cAlias)->descricao)})
		oItem["data"      ] := PCPConvDat(DToS((cAlias)->data), 4)
		oItem["quantidade"] := (cAlias)->quantidade
		oItem["armazem"   ] := (cAlias)->armazem
		oItem["documento" ] := (cAlias)->documento
		oItem["tipo"      ] := (cAlias)->tipo
		oItem["codigo"    ] := (cAlias)->codigo
		oItem["sequencia" ] := (cAlias)->sequencia
		oItem["recno"     ] := (cAlias)->recno
		oItem["actions"   ] := {}

		If lView
			aAdd(oItem["actions"], "view")
		EndIf

		If lEdit
			aAdd(oItem["actions"], "edit")
		EndIf

		If lDelete
			aAdd(oItem["actions"], "delete")
		EndIf

		aAdd(oReturn["items"], oItem)

		(cAlias)->(dbSkip())

		If nCont >= nPageSize .And. !lExport
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oItem)
	FwFreeObj(oReturn)
Return aReturn

/*{Protheus.doc} validSMI
Retorna a validação da SMI
@type  Static Function
@author Breno Ferreira
@since 03/12/2024
@version P12
@return _lSMI, logical, Retorna da validação da SMI
*/
Static Function validSMI()
	If _lSMI == Nil
		_lSMI := GetSx3Cache("MI_FILCOM", "X3_TAMANHO") > 0
	EndIf
Return _lSMI

/*{Protheus.doc} labelTran
Retorna o label do campo transferancia
@type  Static Function
@author Breno Ferreira
@since 03/12/2024
@version P12
@return cLabel, character, Retorna o label do campo transferencia
*/
Static Function labelTran(cCampo)
	Local cLabel := ""

	If cCampo == '2'
		cLabel := STR0054 //"Não"
	Else
		cLabel := STR0053 //"Sim"
	EndIf

Return cLabel

/*{Protheus.doc} fldLtMinTr
Verifica se possui o indicador de Lote Mínimo de transferência na tabela SMI

@type  Static Function
@author marcelo.neumann
@since 31/03/2025
@version P12
@return _lFldLoTMI, lógico, indica se possui o indicador de Lote Mínimo de transferência na tabela SMI
*/
Static Function fldLtMinTr()

	If _lFldLoTMI == Nil
		_lFldLoTMI := !Empty(GetSx3Cache("MI_LMTRANS", "X3_TAMANHO"))
	EndIf

Return _lFldLoTMI

/*/{Protheus.doc} iniGerDoc
Verifica se iniciou a geração de documentos e fez o lock do pcpa145.
@type  Static Function
@author Lucas Fagundes
@since 12/06/2025
@version P12
@param cTicket  , Caracter, Ticket que iniciou a geração de documentos.
@param oPCPError, Object  , Instancia da PCPMultiThreadError que iniciou a geração de documentos.
@return lIniciou, Logico, Indica que iniciou a geração de documento.
/*/
Static Function iniGerDoc(cTicket, oPCPError)
	Local cFlag    := "PEND"
	Local lIniciou := .F.

	While cFlag == "PEND" .And. !oPCPError:possuiErro()
		cFlag    := GetGlbValue(cTicket + "P145LOCK")
		lIniciou := cFlag == "S"

		If !lIniciou
			Sleep(100)
		EndIf
	End

Return lIniciou
