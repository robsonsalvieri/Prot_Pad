#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PRODUCTIONORDERAPI.CH"

#DEFINE POS_FIELD_COD     1
#DEFINE POS_FIELD_ORDEM   2
#DEFINE POS_FIELD_TITULO  3
#DEFINE POS_FIELD_TIPO    4
#DEFINE POS_FIELD_PICTURE 7
#DEFINE POS_FIELD_OBRIGAT 20

#DEFINE POS_X3_CAMPO    1
#DEFINE POS_X3_ORDEM    2
#DEFINE POS_X3_TIPO     3
#DEFINE POS_X3_TAMANHO  4
#DEFINE POS_X3_DECIMAL  5
#DEFINE POS_X3_TITULO   6
#DEFINE POS_X3_PICTURE  7
#DEFINE POS_X3_PROPRI   8
#DEFINE POS_X3_CBOX     9
#DEFINE POS_X3_OBRIGAT 10
#DEFINE POS_X3_VISUAL  11

#DEFINE RETURN_POS_STATUS     1
#DEFINE RETURN_POS_ERROR      2
#DEFINE RETURN_POS_ERROR_CODE 1
#DEFINE RETURN_POS_ERROR_MSG  2
#DEFINE RETURN_POS_JSON       3

STATIC __CBoxDesc := NIL

Function PCPprdOrd()
Return

/*/{Protheus.doc} pcpPrdOrd
API para consulta de solicitações e pedidos de compra

@type  API
@author douglas.heydt
@since 20/09/2021
@version P12.1.30
/*/
WSRESTFUL prodOrders DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ordens de produção"

	WSDATA Page         AS INTEGER OPTIONAL
	WSDATA PageSize     AS INTEGER OPTIONAL
	WSDATA Quantity     AS FLOAT   OPTIONAL

	WSDATA BranchId     AS STRING OPTIONAL
	WSDATA Crop         AS STRING OPTIONAL
	WSDATA deliveryDate AS STRING OPTIONAL
	WSDATA Document     AS STRING OPTIONAL
	WSDATA Filter       AS STRING OPTIONAL
	WSDATA idCostCntr   AS STRING OPTIONAL
	WSDATA idItemAcco   AS STRING OPTIONAL
	WSDATA idRoute      AS STRING OPTIONAL
	WSDATA idValueCls   AS STRING OPTIONAL
	WSDATA Operation    AS STRING OPTIONAL
	WSDATA OrderId      AS STRING OPTIONAL
	WSDATA Product      AS STRING OPTIONAL
	WSDATA Route        AS STRING OPTIONAL
	WSDATA Warehouse    AS STRING OPTIONAL
	
	WSMETHOD GET prodOrders;
	    DESCRIPTION STR0002; //"Busca todas as ordens de produção"
		WSSYNTAX "api/pcp/v1/prodOrders" ;
		PATH "/api/pcp/v1/prodOrders" ;
		TTALK "v1"

	WSMETHOD GET getFields;
	    DESCRIPTION STR0004; //"Busca todos os campos usados"
		WSSYNTAX "api/pcp/v1/prodOrders/fields" ;
		PATH "/api/pcp/v1/prodOrders/fields" ;
		TTALK "v1"

	WSMETHOD POST prodOrders;
		DESCRIPTION STR0005; //"Inclusão de Ordens de Produção"
		WSSYNTAX "api/pcp/v1/prodOrders" ;
		PATH "/api/pcp/v1/prodOrders" ;
		TTALK "v1"

	WSMETHOD PUT prodOrders;
		DESCRIPTION STR0034; //"Alteração de Ordem de Produção"
		WSSYNTAX "api/pcp/v1/prodOrders" ;
		PATH "/api/pcp/v1/prodOrders" ;
		TTALK "v1"

	WSMETHOD DELETE prodOrders;
		DESCRIPTION STR0037; //"Exclusão de Ordens de Produção"
		WSSYNTAX "api/pcp/v1/prodOrders" ;
		PATH "/api/pcp/v1/prodOrders" ;
		TTALK "v1"

	WSMETHOD GET products;
	    DESCRIPTION STR0020; //"Busca todos os produtos"
		WSSYNTAX "api/pcp/v1/prodOrders/products" ;
		PATH "/api/pcp/v1/prodOrders/products" ;
		TTALK "v1"

	WSMETHOD GET idProduct;
	    DESCRIPTION STR0020; //"Busca um produto"
		WSSYNTAX "api/pcp/v1/prodOrders/products/{Product}" ;
		PATH "/api/pcp/v1/prodOrders/products/{Product}" ;
		TTALK "v1"

	WSMETHOD GET warehouses;
	    DESCRIPTION STR0021; //"Busca todos os armazéns"
		WSSYNTAX "api/pcp/v1/prodOrders/warehouses" ;
		PATH "/api/pcp/v1/prodOrders/warehouses" ;
		TTALK "v1"

	WSMETHOD GET idWarehouse;
	    DESCRIPTION STR0022; //"Busca um armazém"
		WSSYNTAX "api/pcp/v1/prodOrders/warehouses/{Warehouse}" ;
		PATH "/api/pcp/v1/prodOrders/warehouses/{Warehouse}" ;
		TTALK "v1"

	WSMETHOD GET routes;
	    DESCRIPTION STR0025; //'Busca todos os roteiros'
		WSSYNTAX "api/pcp/v1/prodOrders/routes" ;
		PATH "/api/pcp/v1/prodOrders/routes" ;
		TTALK "v1"

	WSMETHOD GET idRoute;
	    DESCRIPTION STR0026; //'Busca um roteiro'
		WSSYNTAX "api/pcp/v1/prodOrders/routes/{idRoute}" ;
		PATH "/api/pcp/v1/prodOrders/routes/{idRoute}" ;
		TTALK "v1"

	WSMETHOD GET itemsAccounting;
	    DESCRIPTION STR0027; //'Busca todos os itens contábeis'
		WSSYNTAX "api/pcp/v1/prodOrders/accountingitems" ;
		PATH "/api/pcp/v1/prodOrders/accountingitems" ;
		TTALK "v1"

	WSMETHOD GET idItemAccounting;
	    DESCRIPTION STR0028; //'Busca um item contábil'
		WSSYNTAX "api/pcp/v1/prodOrders/accountingitems/{idItemAcco}" ;
		PATH "/api/pcp/v1/prodOrders/accountingitems/{idItemAcco}" ;
		TTALK "v1"

	WSMETHOD GET valueClassItemsAccounting;
	    DESCRIPTION STR0029; //'Busca todas as classes de valor'
		WSSYNTAX "api/pcp/v1/prodOrders/valueclassaccountingitems" ;
		PATH "/api/pcp/v1/prodOrders/valueclassaccountingitems" ;
		TTALK "v1"

	WSMETHOD GET idValueClass;
	    DESCRIPTION STR0030; //'Busca uma classe de valor'
		WSSYNTAX "api/pcp/v1/prodOrders/valueclassaccountingitems/{idValueCls}" ;
		PATH "/api/pcp/v1/prodOrders/valueclassaccountingitems/{idValueCls}" ;
		TTALK "v1"

	WSMETHOD GET costCenter;
	    DESCRIPTION STR0032; //'Busca todos os centros de custo'
		WSSYNTAX "api/pcp/v1/prodOrders/costcenter" ;
		PATH "/api/pcp/v1/prodOrders/costcenter" ;
		TTALK "v1"

	WSMETHOD GET idCostCenter;
	    DESCRIPTION STR0033; //'Busca um centro de custo'
		WSSYNTAX "api/pcp/v1/prodOrders/costcenter/{idCostCntr}" ;
		PATH "/api/pcp/v1/prodOrders/costcenter/{idCostCntr}" ;
		TTALK "v1"

	WSMETHOD GET hdrFields;
	    DESCRIPTION STR0040; //"Busca campos do Cabeçalho";
		WSSYNTAX "api/pcp/v1/prodOrders/hdrfields" ;
		PATH "/api/pcp/v1/prodOrders/hdrfields" ;
		TTALK "v1"		

	WSMETHOD GET engFields;
	    DESCRIPTION STR0038; //"Busca campos da aba Engenharia";
		WSSYNTAX "api/pcp/v1/prodOrders/engfields" ;
		PATH "/api/pcp/v1/prodOrders/engfields" ;
		TTALK "v1"
	
	WSMETHOD GET detFields;
	    DESCRIPTION STR0039; //"Busca campos da aba Detalhes";
		WSSYNTAX "api/pcp/v1/prodOrders/detfields" ;
		PATH "/api/pcp/v1/prodOrders/detfields" ;
		TTALK "v1"

	WSMETHOD GET athFields;
	    DESCRIPTION STR0042; //"Busca campos da aba Outras Informações";
		WSSYNTAX "api/pcp/v1/prodOrders/athfields" ;
		PATH "/api/pcp/v1/prodOrders/athfields" ;
		TTALK "v1"		

	WSMETHOD GET register;
	    DESCRIPTION STR0041; //"Busca ordem de produção específica";
		WSSYNTAX "api/pcp/v1/prodOrders/register/{orderid}" ;
		PATH "/api/pcp/v1/prodOrders/register/{orderid}" ;
		TTALK "v1"

	WSMETHOD GET crops;
	    DESCRIPTION STR0043; //"Busca todas as safras";
		WSSYNTAX "api/pcp/v1/prodOrders/crops" ;
		PATH "/api/pcp/v1/prodOrders/crops" ;
		TTALK "v1"

	WSMETHOD GET idCrop;
	    DESCRIPTION STR0044; //"Busca uma safra";
		WSSYNTAX "api/pcp/v1/prodOrders/crops/{Crop}" ;
		PATH "/api/pcp/v1/prodOrders/crops/{Crop}" ;
		TTALK "v1"		
	
	WSMETHOD GET vldEntrega;
	    DESCRIPTION STR0045 ; //"Valida a data de entrega da ordem de produção";
		WSSYNTAX "api/pcp/v1/prodOrders/validatedeliverydate" ;
		PATH "/api/pcp/v1/prodOrders/validatedeliverydate" ;
		TTALK "v1"		

ENDWSRESTFUL

/*/{Protheus.doc} GET prodOrders api/pcp/v1/prodOrders
Retorna todas as ordens de produção

@type WSMETHOD
@author douglas.heydt
@since 20/09/2021
@version P12.1.33
@param 01 Page        , Caracter, Página de retorno
@param 02 PageSize    , Caracter, Tamanho da página
@param 03 Document    , Caracter, Filtro da busca de ordens
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET prodOrders WSRECEIVE Page, PageSize, Document WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := GetPrdOrd(Self:Page, Self:PageSize, Self:Document)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} GetPrdOrd
Busca todos os registros de ordens de produção
@type  Function
@author douglas.heydt
@since 17/09/2021
@version P12.1.30
@param 01 Page        , Caracter, Página de retorno
@param 02 PageSize    , Caracter, Tamanho da página
@param 03 cDocument   , Caracter, Filtro da busca de ordens
@return, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Function GetPrdOrd(nPage, nPageSize, cDocument)
	Local aFields   := {}
	Local aResult   :={.T., "", 200}
	Local cAliasQry := GetNextAlias()
	Local cBoxDesc  := ""
	Local cFields   := ""
	Local cQuery    := ""
	Local nPos      := 0
	Local nStart    := 0
	Local nX        := 0
	Local oJson     := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20
	Default cDocument := " "

	__CBoxDesc := JsonObject():New()

	aFields := getFields("SC2")

	For nX := 1 To Len(aFields)
		IF aFields[nX][POS_FIELD_COD] <> "STATUS"
			cFields += aFields[nX][POS_FIELD_COD]
			IF nX != Len(aFields)
				cFields += ", "
			ENDIF
		ENDIF
	Next nX

	cQuery += "SELECT " + cFields + ", R_E_C_N_O_"
	cQuery +=  " FROM " + RetSqlName("SC2")
	cQuery += " WHERE D_E_L_E_T_ = ' '"

	If !Empty(cDocument)
		cQuery += " AND C2_NUM like '%" + cDocument + "%'"
	EndIf

	cQuery += " ORDER BY C2_FILIAL, C2_NUM, C2_ITEM, C2_ITEMGRD  "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["columns"] := Array(Len(aFields))
	For nX := 1 To Len(aFields)
		oJson["columns"][nX] := JsonObject():New()
		oJson["columns"][nX][ "id"          ]  := aFields[nX][POS_FIELD_COD]
		oJson["columns"][nX][ "order"       ]  := aFields[nX][POS_FIELD_ORDEM]
		oJson["columns"][nX][ "description" ]  := aFields[nX][POS_FIELD_TITULO]
	Next nX

	oJson["items"] := {}

	aDel(aFields, 2)//Retirar o campo status do array
	aSize(aFields, Len(aFields)-1)

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"], JsonObject():New())
        nPos++
		For nX := 1 To Len(aFields)
			cBoxDesc := getDesOrig("SC2", aFields[nX][1])
			If !Empty(cBoxDesc)
				oJson["items"][nPos][ aFields[nX][POS_FIELD_COD] ] := cBoxDesc
			Else
				oJson["items"][nPos][ aFields[nX][POS_FIELD_COD] ] := (cAliasQry)->&(aFields[nX][POS_FIELD_COD])
			EndIf

			If aFields[nX][POS_FIELD_TIPO] == "D"
				oJson["items"][nPos][ aFields[nX][POS_FIELD_COD]] := PCPConvDat(StoD(oJson["items"][nPos][ aFields[nX][POS_FIELD_COD]]), 2)
			EndIf
		Next nX

		oJson["items"][nPos][ "STATUS" ]  := getStatus((cAliasQry)->R_E_C_N_O_)
		oJson["items"][nPos][ "RECNO"  ]  := (cAliasQry)->R_E_C_N_O_

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

    aSize(oJson["items"],0)
	aSize(oJson["columns"],0)
	aSize(aFields,0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} getDesOrig
para campos do tipo checkbox, busca o valor em string correspondente. Ex:  F retorna 'Firme'
@type  Function
@author douglas.heydt
@since 17/09/2021
@version P12.1.30
@param 01 cAlias    , Caracter, Alias da tabela de busca
@param 02 cCampo    , Caracter, campo ao qual deve verificar o valor
@return cDesc, caracter, retorna o valor do campo em string
/*/
Static Function getDesOrig(cAlias, cCampo)
	Local aOpcoes := {}
    Local cBox    := ""
	Local cDesc   := ""
	Local nOrigem := (cAlias)->&(cCampo)
	Local nX      := 1

	IF __CBoxDesc[cCampo] == NIl
		cBox := GetSX3Cache(cCampo, "X3_CBOX")

		IF Empty(cBox)
			__CBoxDesc[cCampo] := " "
		ELSE
			__CBoxDesc[cCampo] := JsonObject():New()
			aOpcoes := RetSX3Box(cBox,,,1)
			For nX := 1 To Len(aOpcoes)
				__CBoxDesc[cCampo][aOpcoes[nX][2]] := aOpcoes[nX][3]
			Next nX
			aSize(aOpcoes,0)
		ENDIF
	ENDIF

	IF ValType(__CBoxDesc[cCampo]) == "J"
		cDesc := __CBoxDesc[cCampo][nOrigem]
	ENDIF

Return cDesc

/*/{Protheus.doc} GET getFields api/pcp/v1/prodOrders/fields
Retorna todas as ordens de produção

@type WSMETHOD
@author douglas.heydt
@since 20/09/2021
@version P12.1.33
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET getFields WSRECEIVE Filter WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar todos os campos.
	aReturn := GetAllflds(Self:Filter)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf
	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} POST prodOrders api/pcp/v1/prodOrders
Inclui Ordem de Produção

@type WSMETHOD
@author brunno.costa
@since 18/10/2021
@version P12.1.33
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST prodOrders WSSERVICE prodOrders

	Local aResult   := {.T., {0,""}, ""}
	Local lRet      := .T.
	Local oPrdOrder := Nil

	Self:SetContentType("application/json")

	// Identificando o tipo do Body
	lRet := vldAccept(Self)
	
	// Executando a função
	If lRet
		oPrdOrder := ProductionOrder():New()
		aResult   := oPrdOrder:incluiOP(Self:GetContent())
		oPrdOrder:Destroy()
		FreeObj(oPrdOrder)
	
		If !aResult[RETURN_POS_STATUS]
			If Len(aResult[RETURN_POS_ERROR]) > 1
				SetRestFault(aResult[RETURN_POS_ERROR][RETURN_POS_ERROR_CODE], EncodeUTF8(aResult[RETURN_POS_ERROR][RETURN_POS_ERROR_MSG]))
			Else
				SetRestFault(500, EncodeUTF8(STR0007)) //"Erro não identificado"
			EndIf
			lRet := .F.
		Else
			Self:SetResponse(aResult[RETURN_POS_JSON])
		EndIf
	EndIf

	FwFreeArray(aResult)

Return lRet

/*/{Protheus.doc} PUT prodOrders api/pcp/v1/prodOrders
Altera Ordem de Produção

@type WSMETHOD
@author douglas.heydt
@since 09/11/2021
@version P12.1.33
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD PUT prodOrders WSSERVICE prodOrders

	Local aResult   := {.T., {0,""}, ""}
	Local lRet      := .T.
	Local oPrdOrder := Nil

	Self:SetContentType("application/json")

	// Identificando o tipo do Body
	lRet := vldAccept(Self)

	// Executando a função
	If lRet
		oPrdOrder := ProductionOrder():New()
		aResult   := oPrdOrder:alteraOP(Self:GetContent())
		oPrdOrder:Destroy()
		FreeObj(oPrdOrder)

		If !aResult[RETURN_POS_STATUS]
			If Len(aResult[RETURN_POS_ERROR]) > 1
				SetRestFault(aResult[RETURN_POS_ERROR][RETURN_POS_ERROR_CODE], EncodeUTF8(aResult[RETURN_POS_ERROR][RETURN_POS_ERROR_MSG]))
			Else
				SetRestFault(500, EncodeUTF8(STR0007)) //"Erro não identificado"
			EndIf
			lRet := .F.
		Else
			Self:SetResponse(aResult[RETURN_POS_JSON])
		EndIf
	EndIf

	FwFreeArray(aResult)

Return lRet

/*/{Protheus.doc} DELETE prodOrders api/pcp/v1/prodOrders
Exclui Ordem de Produção

@type WSMETHOD
@author lucas.franca
@since 09/11/2021
@version P12
@return lRet, Lógico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE prodOrders WSSERVICE prodOrders
	
	Local aResult   := {.T., {0,""}, ""}
	Local lRet      := .T.
	Local oPrdOrder := Nil

	Self:SetContentType("application/json")

	// Identificando o tipo do Body
	lRet := vldAccept(Self)
	
	// Executando a função
	If lRet
		oPrdOrder := ProductionOrder():New()
		aResult   := oPrdOrder:excluiOP(Self:GetContent())

		oPrdOrder:Destroy()
		FreeObj(oPrdOrder)
		
		If !aResult[RETURN_POS_STATUS]
			If Len(aResult[RETURN_POS_ERROR]) > 1
				SetRestFault(aResult[RETURN_POS_ERROR][RETURN_POS_ERROR_CODE], EncodeUTF8(aResult[RETURN_POS_ERROR][RETURN_POS_ERROR_MSG]))
			Else
				SetRestFault(500, EncodeUTF8(STR0007)) //"Erro não identificado"
			EndIf
			lRet := .F.
		Else
			Self:SetResponse(aResult[RETURN_POS_JSON])
		EndIf
	EndIf

	FwFreeArray(aResult)

Return lRet

/*/{Protheus.doc} GetAllflds
Retorna todos os campos usados em tela da tabela cAlias
@type  Function
@author douglas.heydt
@since 17/09/2021
@version P12.1.30
@return aResult, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function GetAllflds(cAlias)
	Local aFields := ProductionOrderForm():retornaCamposUsadosDicionario()
	Local aResult := {.T., "", 200}
	Local nX      := 0
	Local oJson   := JsonObject():New()

	oJson["items"] := {}
	For nX := 1 To Len(aFields)
		aAdd(oJson["items"], JsonObject():New())
		oJson["items"][nX][ "X3_CAMPO"   ] := aFields[nX][POS_X3_CAMPO]
		oJson["items"][nX][ "X3_ORDEM"   ] := aFields[nX][POS_X3_ORDEM]
		oJson["items"][nX][ "X3_TIPO"    ] := aFields[nX][POS_X3_TIPO]
		oJson["items"][nX][ "X3_TAMANHO" ] := aFields[nX][POS_X3_TAMANHO]
		oJson["items"][nX][ "X3_DECIMAL" ] := aFields[nX][POS_X3_DECIMAL]
		oJson["items"][nX][ "X3_TITULO"  ] := aFields[nX][POS_X3_TITULO]
		oJson["items"][nX][ "X3_PICTURE" ] := aFields[nX][POS_X3_PICTURE]
		oJson["items"][nX][ "X3_PROPRI"  ] := aFields[nX][POS_X3_PROPRI]
		oJson["items"][nX][ "X3_CBOX"    ] := aFields[nX][POS_X3_CBOX]
		oJson["items"][nX][ "X3_OBRIGAT" ] := aFields[nX][POS_X3_OBRIGAT]
		oJson["items"][nX][ "X3_VISUAL" ]  := aFields[nX][POS_X3_VISUAL]
	Next nX

	If Len(aFields) > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

    aSize(oJson["items"],0)
	aSize(aFields,0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} getStatus
Busca o status de uma ordem de produção

@type  Function
@author douglas.heydt
@since 21/09/2021
@version version
@param 01 nRecno, numerico, recno do registro da op
@return cStatus , character, status da op
/*/
Static Function getStatus(nRecno)
	Local aAreaSC2   := SC2->(GetArea())
	Local cAliasTemp := ""
	Local cQuery     := ""
	Local cStatus    := ""
	Local dEmissao   := dDataBase
	Local nRegSD3    := 0
	Local nRegSH6    := 0

	SC2->(dbGoTo(nRecno))

	If SC2->C2_TPOP == "P"
		cStatus := "1" //Prevista
	Else
		If SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF) .And. SC2->(C2_QUJE < C2_QUANT)  /*Enc.Parcialmente*/
			cStatus := "5" //Encerrada Parcialmente
		Else
			If SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF) .And. SC2->(C2_QUJE >= C2_QUANT)  /*Enc.Totalmente*/
				cStatus := "6" //Encerrada Totalmente
			Else
				cAliasTemp:= "SD3TMP"
				cQuery     := "  SELECT COUNT(*) AS RegSD3, MAX(D3_EMISSAO) AS EMISSAO "
				cQuery     += "   FROM " + RetSqlName('SD3')
				cQuery     += "   WHERE D3_FILIAL   = '" + xFilial('SD3')+ "'"
				cQuery     += "     AND D3_OP       = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "'"
				cQuery     += "     AND D3_ESTORNO <> 'S' "
				cQuery     += "     AND D_E_L_E_T_  = ' '"
				cQuery    += "       GROUP BY D3_EMISSAO "
				cQuery    := ChangeQuery(cQuery)
				dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

				If !SD3TMP->(Eof())
					dEmissao := STOD(SD3TMP->EMISSAO)
					nRegSD3 := SD3TMP->RegSD3
				EndIf
				(cAliasTemp)->(dbCloseArea())
				cAliasTemp:= "SH6TMP"
				cQuery     := "  SELECT COUNT(*) AS RegSH6 "
				cQuery     += "   FROM " + RetSqlName('SH6')
				cQuery     += "   WHERE H6_FILIAL   = '" + xFilial('SH6')+ "'"
				cQuery     += "     AND H6_OP       = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "'"
				cQuery     += "     AND D_E_L_E_T_  = ' '"
				cQuery    := ChangeQuery(cQuery)
				dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

				If !SH6TMP->(Eof())
					nRegSH6 := SH6TMP->RegSH6
				EndIf
				(cAliasTemp)->(dbCloseArea())

				If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (nRegSD3 < 1 .And. nRegSH6 < 1) .And. (Max(dDataBase - SC2->C2_DATPRI,0) < If(SC2->C2_DIASOCI == 0,1,SC2->C2_DIASOCI)) //Em aberto
					cStatus := "2" //Em aberto
				Else
					If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (nRegSD3 > 0 .Or. nRegSH6 > 0) .And. (Max((dDatabase - dEmissao),0) > If(SC2->C2_DIASOCI >= 0,-1,SC2->C2_DIASOCI)) //Iniciada
						cStatus := "3" //Iniciada
					Else
						If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (Max((dDatabase - dEmissao),0) > SC2->C2_DIASOCI .Or. Max((dDatabase - SC2->C2_DATPRI),0) >= SC2->C2_DIASOCI)   //Ociosa
							cStatus := "4" //Ociosa
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSC2)

Return cStatus

/*/{Protheus.doc} getFields
Busca os campos usados no browse da tabela
@type  Function
@author douglas.heydt
@since 21/09/2021
@version version
@param 01 cAlias, character, alias para retornar os campos
@return aBrwFields , array, array contendo id, ordem e descrição de cada campo usado no browse
/*/
Static Function getFields(cAlias)
	Local aAllFields := {}
	Local aBrwFields := {}
	Local aFieldAux  := {}
	Local aOrders    := {}
	Local nIndex     := 0
	Local nInd       := 0

	Default cAlias := "SC2"

	aAllFields := FWSX3Util():GetAllFields(cAlias)

	If cAlias == "SC2"
		aAdd(aBrwFields, {"C2_FILIAL",00, GetSX3Cache("C2_FILIAL", "X3_TITULO"), "C"  })
		aAdd(aBrwFields, {"STATUS",01, STR0008, "C"  }) //"Status"
	EndIf

	For nIndex := 1 To Len(aAllFields)
		IF GetSX3Cache(aAllFields[nIndex], "X3_BROWSE") == 'S'
			aAdd(aOrders, GetSX3Cache(aAllFields[nIndex], "X3_ORDEM"))
			aAdd(aFieldAux, {aAllFields[nIndex]                          ,;
								GetSX3Cache(aAllFields[nIndex], "X3_ORDEM") ,;
								GetSX3Cache(aAllFields[nIndex], "X3_TITULO"),;
								GetSX3Cache(aAllFields[nIndex], "X3_TIPO")  })
		EndIf
	Next nIndex

	aSort(aOrders)

	For nIndex := 1 To Len(aOrders)
		For nInd := 1 To Len(aFieldAux)
			If aFieldAux[nInd][2] == aOrders[nIndex]
				aAdd(aBrwFields, aFieldAux[nInd])
			EndIf
		Next nInd
	Next nIndex


	aSize(aAllFields,0)
	aSize(aOrders,0)
	aSize(aFieldAux,0)

Return aBrwFields

/*/{Protheus.doc} GET products api/pcp/v1/prodOrders/products
Retorna todas os produtos

@type WSMETHOD
@author renan.roeder
@since 20/10/2021
@version P12.1.33
@param 01 Page        , Caracter, Página de retorno
@param 02 PageSize    , Caracter, Tamanho da página
@param 03 Filter      , Caracter, Filtro da busca de produtos
@param 04 BranchId    , Caracter, Filtro da filial
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET products WSRECEIVE Page, PageSize, Filter, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getProducts(Self:Page, Self:PageSize, Self:Filter, Self:BranchId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getProducts
Busca os produtos para o cadastro da ordem de produção
@type  Function
@author renan.roeder
@since 20/10/2021
@version version
@param 01 Page        , Numerico, Página de retorno
@param 02 PageSize    , Numerico, Tamanho da página
@param 03 cProduct    , Caracter, Filtro da busca de produtos
@param 04 cBranchId   , Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getProducts(nPage, nPageSize, cProduct, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local lUsaBZ     := SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ"
	Local nStart     := 0
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20
	Default cProduct  := " "

	cQuery += "SELECT SB1.B1_COD,"
	cQuery +=       " SB1.B1_DESC,"
	cQuery +=       " SB1.B1_UM,"
	cQuery +=       " SB1.B1_SEGUM,"
	cQuery +=       " SB1.B1_CC,"
	cQuery +=       " SB1.B1_REVATU,"
	cQuery +=       " SB1.B1_OPERPAD,"
	cQuery +=       " SB1.R_E_C_N_O_,"
	If lUsaBZ
		cQuery += " COALESCE(SBZ.BZ_LOCPAD, SB1.B1_LOCPAD) LOCPAD "
	Else
		cQuery +=   " SB1.B1_LOCPAD LOCPAD "
	EndIf
	cQuery +=  " FROM " + RetSqlName("SB1") + " SB1 "
	
	If lUsaBZ
		cQuery += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ "
		cQuery +=   " ON SBZ.BZ_FILIAL  = '" + xFilial("SBZ", cBranchId) + "' "
		cQuery +=  " AND SBZ.BZ_COD     = SB1.B1_COD "
		cQuery +=  " AND SBZ.D_E_L_E_T_ = ' ' "
	EndIf
	
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' '"

	If !Empty(cBranchId)
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1", cBranchId) + "' "
	EndIf

	If !Empty(cProduct)
		cQuery += " AND SB1.B1_COD = '" + cProduct + "'"
	EndIf

	cQuery += " ORDER BY SB1.B1_COD  "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():New())
        nPos++
		oJson["items"][nPos][ "ID" ]                := AllTrim((cAliasQry)->B1_COD)
		oJson["items"][nPos][ "DESCRIPTION" ]       := AllTrim((cAliasQry)->B1_DESC)
		oJson["items"][nPos][ "STANDARDWAREHOUSE" ] := AllTrim((cAliasQry)->LOCPAD)
		oJson["items"][nPos][ "UNITMEASURE" ]       := AllTrim((cAliasQry)->B1_UM)
		oJson["items"][nPos][ "SECONDUNITMEASURE" ] := AllTrim((cAliasQry)->B1_SEGUM)
		oJson["items"][nPos][ "COSTCENTER" ]        := AllTrim((cAliasQry)->B1_CC)
		oJson["items"][nPos][ "REVATU" ]            := AllTrim((cAliasQry)->B1_REVATU)
		oJson["items"][nPos][ "ROTEIRO" ]           := AllTrim((cAliasQry)->B1_OPERPAD)
		oJson["items"][nPos][ "RECNO"  ]            := (cAliasQry)->R_E_C_N_O_

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

    aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET idProduct api/pcp/v1/prodOrders/products/{Product}
Retorna todas os produtos

@type WSMETHOD
@author renan.roeder
@since 20/10/2021
@version P12.1.33
@param 01 Product     , Caracter, Filtro da busca de produtos
@param 02 BranchId    , Caracter, Filtro da filial
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET idProduct WSRECEIVE Product, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getIdProduct(Self:Product, Self:BranchId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getIdProduct
Busca os produtos para o cadastro da ordem de produção
@type  Function
@author renan.roeder
@since 20/10/2021
@version version
@param 01 cProduct   , Caracter, Filtro da busca de produtos
@param 02 cBranchId  , Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getIdProduct(cProduct, cBranchId)
	Local aResult := {.F.,STR0003,400} //"Nenhum registro encontrado"
	Local oJson   := JsonObject():New()
	Local oJsOP   := JsonObject():New()
	Local oPrdOrd := Nil

	Default cProduct  := " "
	Default cBranchId := cFilAnt

	cProduct := Upper(PadR(cProduct, GetSX3Cache("B1_COD", "X3_TAMANHO")))

	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1", cBranchId) + cProduct ))
		oJson["ID"         ] := RTrim(SB1->B1_COD)
		oJson["DESCRIPTION"] := AllTrim(SB1->B1_DESC)
		oJson["RECNO"      ] := SB1->(Recno())

		//Instancia a classe de OP para buscar valor do roteiro padrão
		oPrdOrd := ProductionOrder():New()
		oJson["ROTEIRO"          ] := oPrdOrd:validaQIP(oJsOP)
		//Demais dados padrões do produto
		oJson["STANDARDWAREHOUSE"] := AllTrim(RetFldProd(SB1->B1_COD,"B1_LOCPAD"))
		oJson["COSTCENTER"       ] := AllTrim(SB1->B1_CC)
		oJson["UNITMEASURE"      ] := AllTrim(SB1->B1_UM)
		oJson["SECONDUNITMEASURE"] := AllTrim(SB1->B1_SEGUM)
		oJson["REVATU"           ] := AllTrim(IIF(SuperGetMv("MV_REVFIL",.F.,.F.), PCPREVATU(SB1->B1_COD), SB1->B1_REVATU))

		//Limpa o objeto da memória.
		oPrdOrd:Destroy()
		FreeObj(oPrdOrd)
		
		//Adiciona os dados no array de retorno
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	EndIf

	FreeObj(oJson)
	FreeObj(oJsOP)

Return aResult

/*/{Protheus.doc} GET warehouses api/pcp/v1/prodOrders/warehouses
Retorna todas os armazens

@type WSMETHOD
@author renan.roeder
@since 20/10/2021
@version P12.1.33
@param 01 Page        , Caracter, Página de retorno
@param 02 PageSize    , Caracter, Tamanho da página
@param 03 Filter      , Caracter, Filtro da busca de armazens
@param 04 BranchId    , Caracter, Filtro de filial
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET warehouses WSRECEIVE Page, PageSize, Filter, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getWarehouses(Self:Page, Self:PageSize, Self:Filter, Self:BranchId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getWarehouses
Busca os armazéns para o cadastro da ordem de produção
@type  Function
@author renan.roeder
@since 20/10/2021
@version version
@param 01 Page        , Numerico, Página de retorno
@param 02 PageSize    , Numerico, Tamanho da página
@param 03 cWarehouse  , Caracter, Filtro da busca de armazéns
@param 04 cBranchId   , Caracter, Filtro de filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getWarehouses(nPage, nPageSize, cWarehouse, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nStart     := 0
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default nPage      := 1
	Default nPageSize  := 20
	Default cWarehouse := " "

	cQuery += "SELECT NNR_CODIGO, NNR_DESCRI, R_E_C_N_O_"
	cQuery +=  " FROM " + RetSqlName("NNR")
	cQuery += " WHERE D_E_L_E_T_ = ' '"

	If !Empty(cBranchId)
		cQuery += " AND NNR_FILIAL = '" + xFilial("NNR", cBranchId) + "' "
	EndIf

	If !Empty(cWarehouse)
		cQuery += " AND NNR_CODIGO like '%" + cWarehouse + "%'"
	EndIf

	cQuery += " ORDER BY NNR_CODIGO  "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf


	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():New())
        nPos++
		oJson["items"][nPos][ "ID" ]          := AllTrim((cAliasQry)->NNR_CODIGO)
		oJson["items"][nPos][ "DESCRIPTION" ] := AllTrim((cAliasQry)->NNR_DESCRI)
		oJson["items"][nPos][ "RECNO"  ]      := (cAliasQry)->R_E_C_N_O_

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

    aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult


/*/{Protheus.doc} GET idWarehouse api/pcp/v1/prodOrders/warehouses/{Warehouse}
Retorna armazem pelo codigo

@type WSMETHOD
@author renan.roeder
@since 20/10/2021
@version P12.1.33
@param 01 Warehouse   , Caracter, Filtro da busca de armazens
@param 02 BranchId    , Caracter, Filtro da filial
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET idWarehouse WSRECEIVE Warehouse, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getIdWarehouse(Self:Warehouse, Self:BranchId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getIdWarehouse
Busca um armazém para o cadastro da ordem de produção
@type  Function
@author renan.roeder
@since 20/10/2021
@version version
@param 01 cWarehouse   , Caracter, Filtro da busca de armazéns
@param 02 cBranchId    , Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getIdWarehouse(cWarehouse, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default cWarehouse := " "

	cQuery += "SELECT NNR_CODIGO, NNR_DESCRI, R_E_C_N_O_"
	cQuery +=  " FROM " + RetSqlName("NNR")
	cQuery += " WHERE D_E_L_E_T_ = ' '"

	If !Empty(cBranchId)
		cQuery += " AND NNR_FILIAL = '" + xFilial("NNR", cBranchId) + "' "
	EndIf

	If !Empty(cWarehouse)
		cQuery += " AND UPPER(NNR_CODIGO) like '%" + UPPER(cWarehouse) + "%'"
	EndIf

	cQuery += " ORDER BY NNR_CODIGO  "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If (cAliasQry)->(!Eof())
		nPos++
		oJson[ "ID" ]          := AllTrim((cAliasQry)->NNR_CODIGO)
		oJson[ "DESCRIPTION" ] := AllTrim((cAliasQry)->NNR_DESCRI)
		oJson[ "RECNO"  ]      := (cAliasQry)->R_E_C_N_O_
	EndIf

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET routes api/pcp/v1/prodOrders/routes
Retorna todas os roteiros
@type WSMETHOD
@author brunno.costa
@since 02/11/2021
@version P12.1.33
@param 01 Page        , Caracter, Página de retorno
@param 02 PageSize    , Caracter, Tamanho da página
@param 03 cProduct    , Caracter, Filtro da busca de produtos
@param 04 Filter      , Caracter, Filtro da busca de roteiros
@param 05 BranchId    , Caracter, Filtro da filial
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET routes WSRECEIVE Page, PageSize, Product, Filter, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getRoutes(Self:Page, Self:PageSize, Self:Product, Self:Filter, Self:BranchId)
	lRet    := aReturn[1]
	Self:SetResponse(aReturn[2])

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getRoutes
Busca os roteiros para o cadastro da ordem de produção
@type  Function
@author brunno.costa
@since 02/11/2021
@version version
@param 01 nPage       , Numerico, Página de retorno
@param 02 nPageSize   , Numerico, Tamanho da página
@param 03 cProduct    , Caracter, Filtro da busca de produtos
@param 04 cRoute      , Caracter, Filtro da busca de roteiros
@param 05 cBranchId   , Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getRoutes(nPage, nPageSize, cProduct, cRoute, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nStart     := 0
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20
	Default cProduct  := ""
	Default cRoute  := ""

	cQuery += " SELECT DISTINCT G2_CODIGO, G2_PRODUTO "
	cQuery += " FROM " + RetSqlName("SG2")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "

	If !Empty(cBranchId)
		cQuery += " AND G2_FILIAL = '"+ xFilial("SG2", cBranchId) + "' "
	EndIf

	If !Empty(cProduct)
		cQuery += " AND G2_PRODUTO LIKE '%" + cProduct + "%'"
	EndIf

	If !Empty(cRoute)
		cQuery += " AND G2_CODIGO LIKE '%" + cRoute + "%'"
	EndIf

	cQuery += " ORDER BY G2_PRODUTO, G2_CODIGO  "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf


	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():New())
        nPos++

		oJson["items"][nPos]["ID"       ] := RTrim((cAliasQry)->G2_CODIGO)
		oJson["items"][nPos]["PRODUCTID"] := RTrim((cAliasQry)->G2_PRODUTO)

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		oJson["items"] := {}
		oJson["code"]            = 400
		oJson["message"]         = STR0003
		oJson["detailedMessage"] = STR0003
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	EndIf

    aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET idRoute api/pcp/v1/prodOrders/routes/{idRoute}
Retorna um roteiro pelo código
@type WSMETHOD
@author brunno.costa
@since 02/11/2021
@version P12.1.33
@param 01 Product , Caracter, Filtro da busca de produtos
@param 02 idRoute , Caracter, Filtro da busca de roteiros
@param 03 BranchId, Caracter, Filtro da filial
@return   lRet  , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET idRoute WSRECEIVE Product, idRoute, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getIdRoute(Self:Product, Self:idRoute, Self:BranchId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getIdRoute
Busca um roteiro para o cadastro da ordem de produção
@type  Function
@author brunno.costa
@since 02/11/2021
@version version
@param 01 cProduct , Caracter, Filtro da busca de produtos
@param 02 cRoute   , Caracter, Filtro da busca de roteiros
@param 03 cBranchId, Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getIdRoute(cProduct, cRoute, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default cRoute := " "

	cQuery += " SELECT G2_CODIGO, G2_PRODUTO "
	cQuery += " FROM " + RetSqlName("SG2")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "

	If !Empty(cBranchId)
		cQuery += " AND G2_FILIAL = '"+ xFilial("SG2", cBranchId) + "' "
	EndIf

	If !Empty(cProduct)
		cQuery += " AND G2_PRODUTO LIKE '%" + cProduct + "%'"
	EndIf

	If !Empty(cRoute)
		cQuery += " AND G2_CODIGO LIKE '%" + cRoute + "%'"
	EndIf

	cQuery += " ORDER BY G2_PRODUTO, G2_CODIGO "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If (cAliasQry)->(!Eof()) .And. !Empty(cRoute)
		nPos++
		oJson["ID"       ] := RTrim((cAliasQry)->G2_CODIGO)
		oJson["PRODUCTID"] := RTrim((cAliasQry)->G2_PRODUTO)
	EndIf

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET valueClassItemsAccounting api/pcp/v1/prodOrders/valueClassItemsAccounting
Retorna todas as Classes de Valor
@type WSMETHOD
@author brunno.costa
@since 02/11/2021
@version P12.1.33
@param 01 Page    , Caracter, Página de retorno
@param 02 PageSize, Caracter, Tamanho da página
@param 03 Filter  , Caracter, Filtro da busca de classes de valor
@param 04 BranchId, Caracter, Filtro da filial
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET valueClassItemsAccounting WSRECEIVE Page, PageSize, Filter, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getVlClass(Self:Page, Self:PageSize, Self:Filter, Self:BranchId)
	lRet    := aReturn[1]
	Self:SetResponse(aReturn[2])

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getVlClass
Busca as classes valor para o cadastro da ordem de produção
@type  Function
@author brunno.costa
@since 02/11/2021
@version version
@param 01 nPage       , Numerico, Página de retorno
@param 02 nPageSize   , Numerico, Tamanho da página
@param 03 cCLVL       , Caracter, Filtro da busca de classes de valor
@param 04 cBranchId   , Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getVlClass(nPage, nPageSize, cCLVL, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nStart     := 0
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20
	Default cCLVL   := ""

	cQuery += " SELECT CTH_CLVL, CTH_DESC01, R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("CTH")
	cQuery += " WHERE (D_E_L_E_T_ = ' ') "

	If !Empty(cBranchId)
		cQuery += " AND (CTH_FILIAL = '"+ xFilial("CTH", cBranchId) + "') "
	EndIf

	If !Empty(cCLVL)
		cQuery += " AND CTH_CLVL like '%" + cCLVL + "%'"
	EndIf

	cQuery += " ORDER BY CTH_CLVL "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():New())
        nPos++

		oJson["items"][nPos][ "ID" ]          := AllTrim((cAliasQry)->CTH_CLVL)
		oJson["items"][nPos][ "DESCRIPTION" ] := AllTrim((cAliasQry)->CTH_DESC01)
		oJson["items"][nPos][ "RECNO" ]       := (cAliasQry)->R_E_C_N_O_

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		oJson["items"] := {}
		oJson["code"]            = 400
		oJson["message"]         = STR0003
		oJson["detailedMessage"] = STR0003
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	EndIf

    aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult


/*/{Protheus.doc} GET idValueClass api/pcp/v1/prodOrders/valueclassaccountingitems/{idValueCls}
Retorna classe valor pelo código
@type WSMETHOD
@author brunno.costa
@since 02/11/2021
@version P12.1.33
@param 01 idValueCls, Caracter, Filtro da busca de classes valores
@param 02 BranchId  , Caracter, Filtro da filial
@return   lRet  , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET idValueClass WSRECEIVE idValueCls, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getIdVlClass(Self:idValueCls, Self:BranchId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getIdVlClass
Busca uma classe de valor para o cadastro da ordem de produção
@type  Function
@author brunno.costa
@since 02/11/2021
@version version
@param 01 cCLVL    , Caracter, Filtro da busca de classes valores
@param 02 cBranchId, Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getIdVlClass(cCLVL, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default cCLVL := " "

	cQuery += " SELECT CTH_CLVL, CTH_DESC01, R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("CTH")
	cQuery += " WHERE (D_E_L_E_T_ = ' ') "

	If !Empty(cBranchId)
		cQuery += " AND (CTH_FILIAL = '"+ xFilial("CTH", cBranchId) + "') "
	EndIf

	If !Empty(cCLVL)
		cQuery += " AND CTH_CLVL like '%" + cCLVL + "%'"
	EndIf

	cQuery += " ORDER BY CTH_CLVL "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If (cAliasQry)->(!Eof())
		nPos++
		oJson[ "ID" ]          := AllTrim((cAliasQry)->CTH_CLVL)
		oJson[ "DESCRIPTION" ] := AllTrim((cAliasQry)->CTH_DESC01)
		oJson[ "RECNO" ]       := (cAliasQry)->R_E_C_N_O_
	EndIf

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET costCenter api/pcp/v1/prodOrders/costcenter
Retorna todos os Centros de Custos
@type WSMETHOD
@author brunno.costa
@since 08/11/2021
@version P12.1.33
@param 01 Page    , Caracter, Página de retorno
@param 02 PageSize, Caracter, Tamanho da página
@param 03 Filter  , Caracter, Filtro da busca dos centros de custos
@param 04 BranchId, Caracter, Filtro da filial
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET costCenter WSRECEIVE Page, PageSize, Filter, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getCCenter(Self:Page, Self:PageSize, Self:Filter, Self:BranchId)
	lRet    := aReturn[1]
	Self:SetResponse(aReturn[2])

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getCCenter
Busca os centros de custo para o cadastro da ordem de produção
@type  Function
@author brunno.costa
@since 08/11/2021
@version version
@param 01 nPage       , Numerico, Página de retorno
@param 02 nPageSize   , Numerico, Tamanho da página
@param 03 cCostCenter , Caracter, Filtro da busca de centro de custo
@param 04 cBranchId   , Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getCCenter(nPage, nPageSize, cCostCenter, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nStart     := 0
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default nPage       := 1
	Default nPageSize   := 20
	Default cCostCenter := ""

	cQuery += " SELECT CTT_CUSTO, CTT_DESC01, R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("CTT")
	cQuery += " WHERE (D_E_L_E_T_ = ' ') "

	If !Empty(cBranchId)
		cQuery += " AND (CTT_FILIAL = '"+ xFilial("CTT", cBranchId) + "') "
	EndIf

	If !Empty(cCostCenter)
		cQuery += " AND CTT_CUSTO like '%" + cCostCenter + "%'"
	EndIf

	cQuery += " ORDER BY CTT_CUSTO "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():New())
        nPos++

		oJson["items"][nPos][ "ID" ]          := AllTrim((cAliasQry)->CTT_CUSTO)
		oJson["items"][nPos][ "DESCRIPTION" ] := AllTrim((cAliasQry)->CTT_DESC01)
		oJson["items"][nPos][ "RECNO" ]       := (cAliasQry)->R_E_C_N_O_

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		oJson["items"] := {}
		oJson["code"]            = 400
		oJson["message"]         = STR0003
		oJson["detailedMessage"] = STR0003
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	EndIf

    aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET idCostCenter api/pcp/v1/prodOrders/costcenter/{idCostCntr}
Retorna classe valor pelo código
@type WSMETHOD
@author brunno.costa
@since 02/11/2021
@version P12.1.33
@param 01 idCostCntr, Caracter, Filtro da busca de centros de custos
@param 02 BranchId  , Caracter, Filtro da filial
@return   lRet  , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET idCostCenter WSRECEIVE idCostCntr, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getIdCostC(Self:idCostCntr, Self:BranchId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getIdCostC
Busca um centro de custo para o cadastro da ordem de produção
@type  Function
@author brunno.costa
@since 08/11/2021
@version version
@param 01 cCostCenter, Caracter, Filtro da busca de classes valores
@param 02 cBranchId  , Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getIdCostC(cCostCenter, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default cCostCenter := " "

	cQuery += " SELECT CTT_CUSTO, CTT_DESC01, R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("CTT")
	cQuery += " WHERE (D_E_L_E_T_ = ' ') "

	If !Empty(cBranchId)
		cQuery += " AND (CTT_FILIAL = '"+ xFilial("CTT", cBranchId) + "') "
	EndIf

	If !Empty(cCostCenter)
		cQuery += " AND CTT_CUSTO like '%" + cCostCenter + "%'"
	EndIf

	cQuery += " ORDER BY CTT_CUSTO "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If (cAliasQry)->(!Eof())
		nPos++
		oJson[ "ID" ]          := AllTrim((cAliasQry)->CTT_CUSTO)
		oJson[ "DESCRIPTION" ] := AllTrim((cAliasQry)->CTT_DESC01)
		oJson[ "RECNO" ]       := (cAliasQry)->R_E_C_N_O_
	EndIf

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET itemsAccounting api/pcp/v1/prodOrders/itemsAccounting
Retorna todos os itens contábeis
@type WSMETHOD
@author brunno.costa
@since 02/11/2021
@version P12.1.33
@param 01 Page        , Caracter, Página de retorno
@param 02 PageSize    , Caracter, Tamanho da página
@param 03 Filter      , Caracter, Filtro da busca de itens contábeis
@param 04 BranchId    , Caracter, Filtro da filial
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET itemsAccounting WSRECEIVE Page, PageSize, Filter, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getItemCtb(Self:Page, Self:PageSize, Self:Filter, Self:BranchId)
	lRet    := aReturn[1]
	Self:SetResponse(aReturn[2])

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getItemCtb
Busca os itens contábeis para o cadastro da ordem de produção
@type  Function
@author brunno.costa
@since 02/11/2021
@version version
@param 01 nPage       , Numerico, Página de retorno
@param 02 nPageSize   , Numerico, Tamanho da página
@param 03 cItemCTB    , Caracter, Filtro da busca de itens contábeis
@param 04 cBranchId   , Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getItemCtb(nPage, nPageSize, cItemCTB, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nStart     := 0
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default nPage     := 1
	Default nPageSize := 20
	Default cItemCTB  := ""

	cQuery += " SELECT CTD_ITEM, CTD_DESC01, R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("CTD")
	cQuery += " WHERE (D_E_L_E_T_ = ' ') "

	If !Empty(cBranchId)
		cQuery += " AND (CTD_FILIAL = '"+ xFilial("CTD", cBranchId) + "') "
	EndIf

	If !Empty(cItemCTB)
		cQuery += " AND CTD_ITEM like '%" + cItemCTB + "%'"
	EndIf

	cQuery += " ORDER BY CTD_ITEM "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():New())
        nPos++

		oJson["items"][nPos][ "ID" ]          := AllTrim((cAliasQry)->CTD_ITEM)
		oJson["items"][nPos][ "DESCRIPTION" ] := AllTrim((cAliasQry)->CTD_DESC01)
		oJson["items"][nPos][ "RECNO" ]       := (cAliasQry)->R_E_C_N_O_

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		oJson["items"] := {}
		oJson["code"]            = 400
		oJson["message"]         = STR0003
		oJson["detailedMessage"] = STR0003
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	EndIf

    aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET idItemAccounting api/pcp/v1/prodOrders/accountingitems/{idItemAcco}
Retorna item contábil pelo código
@type WSMETHOD
@author brunno.costa
@since 02/11/2021
@version P12.1.33
@param 01 idItemAcco, Caracter, Filtro da busca de armazens
@param 02 BranchId  , Caracter, Filtro da filial
@return   lRet      , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET idItemAccounting WSRECEIVE idItemAcco, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getIdItAcc(Self:idItemAcco, Self:BranchId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getIdItAcc
Busca um item contábil para o cadastro da ordem de produção
@type  Function
@author brunno.costa
@since 02/11/2021
@version version
@param 01 cItemCTB , Caracter, Filtro da busca de itens contábeis
@param 02 cBranchId, Caracter, Filtro da filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getIdItAcc(cItemCTB, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default cItemCTB := " "

	cQuery += " SELECT CTD_ITEM, CTD_DESC01, R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("CTD")
	cQuery += " WHERE (D_E_L_E_T_ = ' ') "

	If !Empty(cBranchId)
		cQuery += " AND (CTD_FILIAL = '"+ xFilial("CTD", cBranchId) + "') "
	EndIf

	If !Empty(cItemCTB)
		cQuery += " AND CTD_ITEM like '%" + cItemCTB + "%'"
	EndIf

	cQuery += " ORDER BY CTD_ITEM "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If (cAliasQry)->(!Eof())
		nPos++
		oJson[ "ID" ]          := AllTrim((cAliasQry)->CTD_ITEM)
		oJson[ "DESCRIPTION" ] := AllTrim((cAliasQry)->CTD_DESC01)
		oJson[ "RECNO" ]       := (cAliasQry)->R_E_C_N_O_
	EndIf

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} vldAccept
Faz a validação do Accept recebido na requisição

@type  Static Function
@author lucas.franca
@since 09/11/2021
@version P12
@param oRest, Object, Instância da chamada REST
@return lRet, Logic, Identifica se o Accept está correto
/*/
Static Function vldAccept(oRest)
	Local cAccept := oRest:GetAccept()
	Local cTpBody := ""
	Local lRet    := .T.

	// Identificando o tipo do Body
	If !Empty(cAccept) .And. ValType(cAccept) == "C"
		cTpBody := Upper(Substr(cAccept, At("/",cAccept)+1))
	EndIf

	If Empty(cTpBody) .Or. (cTpBody != "JSON")
		SetRestFault(400, EncodeUTF8(STR0006)) //"Não foi possível ler o Body, é apenas aceito JsonObject"
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} GET register api/pcp/v1/prodOrders/engFields
Busca campos da aba engenharia
@type WSMETHOD
@author douglas.heydt
@since 01/12/2021
@version P12.1.33
@param 01 Operation, Caracter, Operação que será executada, define os campos habilitados ou não
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET engFields WSRECEIVE Operation WSSERVICE prodOrders
	Local aResult    := {.T., "", 200}
	Local lRet       := .T.
	Local oJsEngForm := Nil
	Local oEngForm   := Nil

	Self:SetContentType("application/json")

	oEngForm   := ProductionOrderForm():New(Self:Operation)
	oJsEngForm := oEngForm:montaEngenhariaAba()
	oEngForm:Destroy()
	FreeObj(oEngForm)

	If oJsEngForm:HasProperty('items') .And. Len(oJsEngForm['items']) > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJsEngForm:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

	lRet := aResult[1]
	If lRet
		Self:SetResponse(aResult[2])
	Else
		SetRestFault(aResult[3], aResult[2])
	EndIf

	aSize(aResult, 0)
	FreeObj(oJsEngForm)
	FreeObj(oEngForm)

Return lRet

/*/{Protheus.doc} GET register api/pcp/v1/prodOrders/detFields
Busca campos da aba detalhes
@type WSMETHOD
@author douglas.heydt
@since 01/12/2021
@version P12.1.33
@param 01 Operation, Caracter, Operação que será executada, define os campos habilitados ou não
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET detfields WSRECEIVE Operation WSSERVICE prodOrders
	Local aResult    := {.T., "", 200}
	Local lRet       := .T.
	Local oJsDetForm := Nil
	Local oDetForm   := Nil

	Self:SetContentType("application/json")

	oDetForm   := ProductionOrderForm():New(Self:Operation)
	oJsDetForm := oDetForm:montaDetalhesAba()
	oDetForm:Destroy()
	FreeObj(oDetForm)

	If oJsDetForm:HasProperty('items') .And. Len(oJsDetForm['items']) > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJsDetForm:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

	lRet := aResult[1]
	If lRet
		Self:SetResponse(aResult[2])
	Else
		SetRestFault(aResult[3], aResult[2])
	EndIf

	aSize(aResult, 0)
	FreeObj(oJsDetForm)
	FreeObj(oDetForm)

Return lRet

/*/{Protheus.doc} GET register api/pcp/v1/prodOrders/hdrfields
Busca campos do cabeçalho da ordem
@type WSMETHOD
@author douglas.heydt
@since 01/12/2021
@version P12.1.33
@param 01 Operation, Caracter, Operação que será executada, define os campos habilitados ou não
@return   lRet     , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET hdrfields WSRECEIVE Operation WSSERVICE prodOrders
	Local aResult    := {.T., "", 200}
	Local lRet       := .T.
	Local oJsHdrForm := Nil
	Local oHdrForm   := Nil

	Self:SetContentType("application/json")

	oHdrForm   := ProductionOrderForm():New(Self:Operation)
	oJsHdrForm := oHdrForm:montaCabecalho()
	oHdrForm:Destroy()
	FreeObj(oHdrForm)

	If oJsHdrForm:HasProperty('items') .And. Len(oJsHdrForm['items']) > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJsHdrForm:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

	lRet := aResult[1]
	If lRet
		Self:SetResponse(aResult[2])
	Else
		SetRestFault(aResult[3], aResult[2])
	EndIf

	aSize(aResult, 0)
	FreeObj(oJsHdrForm)
	FreeObj(oHdrForm)

Return lRet

/*/{Protheus.doc} GET register api/pcp/v1/prodOrders/athfields
Busca campos da aba outras informações
@type WSMETHOD
@author renan.roeder
@since 20/01/2022
@version P12.1.37
@param 01 Operation, Caracter, Operação que será executada, define os campos habilitados ou não
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET athfields WSRECEIVE Operation WSSERVICE prodOrders
	Local aResult    := {.T., "", 200}
	Local lRet       := .T.
	Local oJsAthForm := Nil
	Local oAthForm   := Nil

	Self:SetContentType("application/json")

	oAthForm   := ProductionOrderForm():New(Self:Operation)
	oJsAthForm := oAthForm:montaOutrasInformacoesAba()
	oAthForm:Destroy()
	FreeObj(oAthForm)

	If oJsAthForm:HasProperty('items') .And. Len(oJsAthForm['items']) > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJsAthForm:toJson())
		aResult[3] := 200
	EndIf

	lRet := aResult[1]
	If lRet
		Self:SetResponse(aResult[2])
	EndIf

	aSize(aResult, 0)
	FreeObj(oJsAthForm)
	FreeObj(oAthForm)

Return lRet

/*/{Protheus.doc} GET register api/pcp/v1/prodOrders/register/{orderid}
Busca registro específico
@type WSMETHOD
@author douglas.heydt
@since 01/12/2021
@version P12.1.33
@param 01 OrderId, Caracter, Identificador da ordem de produção
@return   lRet   , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET register WSRECEIVE OrderId WSSERVICE prodOrders
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getReg(Self:OrderId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getReg
Busca registro específico de ordens de produção
@type  Function
@author douglas.heydt
@since 01/12/2021
@version P12.1.30
@param 01 cOrderId, Caracter, Identificador da ordem de produção
@return   aResult , Array   , Array com as informacoes da requisição
                                 aResult[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
                                 aResult[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
                                 aResult[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Function getReg(cOrderId)
	Local aFields    := {}
	Local aResult    :={.T., "", 200}
	Local cFieldVal  := ""
	Local lReg       := .F.
	Local nX         := 0
	Local oJson      := JsonObject():New()
	Local oStructure := FWFormStruct(1, "SC2")

	For nx := 1 To Len(oStructure:aFields)
		If !oStructure:aFields[nX][14] .And. GetSX3Cache(oStructure:aFields[nX][3], "X3_PROPRI" ) != "U"
			aAdd(aFields, oStructure:aFields[nX][3])
		EndIf
	Next nX

	cOrderId := xFilial("SC2")+cOrderId
	If SC2->(dbSeek(cOrderId))
		lReg := .T.		
		For nX := 1 To Len(aFields)
			cFieldVal := SC2->&(aFields[nX])
			If !Empty(cFieldVal)
				oJson[aFields[nX]] := cFieldVal
			EndIf
		Next nX
		oJson["SALDO_ORDEM"] := oJson["C2_QUANT"] - iif(oJson:HasProperty("C2_QUJE"), oJson["C2_QUJE"], 0) - iif(oJson:HasProperty("C2_PERDA"), oJson["C2_PERDA"], 0)
	EndIf

	If lReg
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003
		aResult[3] := 400
	EndIf

	FreeObj(oStructure)
	FreeObj(oJson)
	aSize(aFields, 0)

Return aResult


/*/{Protheus.doc} GET crops api/pcp/v1/prodOrders/crops
Retorna todas as safras

@type WSMETHOD
@author renan.roeder
@since 20/01/2022
@version P12.1.37
@param 01 Page        , Caracter, Página de retorno
@param 02 PageSize    , Caracter, Tamanho da página
@param 03 Filter      , Caracter, Filtro da busca de safras
@param 04 BranchId    , Caracter, Filtro de filial
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET crops WSRECEIVE Page, PageSize, Filter, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getCrops(Self:Page, Self:PageSize, Self:Filter, Self:BranchId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getCrops
Busca as safras para o cadastro da ordem de produção
@type  Function
@author renan.roeder
@since 20/01/2022
@version version
@param 01 Page        , Numerico, Página de retorno
@param 02 PageSize    , Numerico, Tamanho da página
@param 03 cCrop       , Caracter, Filtro da busca de safras
@param 04 cBranchId   , Caracter, Filtro de filial
@return aReturn, Array, Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getCrops(nPage, nPageSize, cCrop, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nStart     := 0
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default nPage      := 1
	Default nPageSize  := 20
	Default cCrop := " "

	cQuery += "SELECT NJU_CODSAF, NJU_DESCRI, R_E_C_N_O_"
	cQuery +=  " FROM " + RetSqlName("NJU")
	cQuery += " WHERE D_E_L_E_T_ = ' '"

	If !Empty(cBranchId)
		cQuery += " AND NJU_FILIAL = '" + xFilial("NJU", cBranchId) + "' "
	EndIf

	If !Empty(cCrop)
		cQuery += " AND NJU_CODSAF like '%" + cCrop + "%'"
	EndIf

	cQuery += " ORDER BY NJU_CODSAF  "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf


	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"],JsonObject():New())
        nPos++
		oJson["items"][nPos][ "ID" ]          := AllTrim((cAliasQry)->NJU_CODSAF)
		oJson["items"][nPos][ "DESCRIPTION" ] := AllTrim((cAliasQry)->NJU_DESCRI)
		oJson["items"][nPos][ "RECNO"  ]      := (cAliasQry)->R_E_C_N_O_

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		oJson["items"] := {}
		oJson["code"]            = 400
		oJson["message"]         = STR0003
		oJson["detailedMessage"] = STR0003
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	EndIf

    aSize(oJson["items"],0)
	FreeObj(oJson)

Return aResult


/*/{Protheus.doc} GET idCrop api/pcp/v1/prodOrders/crops/{Crop}
Retorna safra pelo codigo

@type WSMETHOD
@author renan.roeder
@since 20/01/2022
@version P12.1.37
@param 01 Crop        , Caracter, Filtro da busca de safras
@param 02 BranchId    , Caracter, Filtro da filial
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET idCrop WSRECEIVE Crop, BranchId WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := getIdCrop(Self:Crop, Self:BranchId)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} getIdCrop
Busca uma safra para o cadastro da ordem de produção
@type  Function
@author renan.roeder
@since 20/01/2022
@version version
@param 01 cCrop        , Caracter, Filtro da busca de safras
@param 02 cBranchId    , Caracter, Filtro da filial
@return aReturn, Array , Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getIdCrop(cCrop, cBranchId)
	Local aResult    := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local nPos       := 0
	Local oJson      := JsonObject():New()

	Default cCrop := " "

	cQuery += "SELECT NJU_CODSAF, NJU_DESCRI, R_E_C_N_O_"
	cQuery +=  " FROM " + RetSqlName("NJU")
	cQuery += " WHERE D_E_L_E_T_ = ' '"

	If !Empty(cBranchId)
		cQuery += " AND NJU_FILIAL = '" + xFilial("NJU", cBranchId) + "' "
	EndIf

	If !Empty(cCrop)
		cQuery += " AND UPPER(NJU_CODSAF) like '%" + UPPER(cCrop) + "%'"
	EndIf

	cQuery += " ORDER BY NJU_CODSAF  "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If (cAliasQry)->(!Eof())
		nPos++
		oJson[ "ID" ]          := AllTrim((cAliasQry)->NJU_CODSAF)
		oJson[ "DESCRIPTION" ] := AllTrim((cAliasQry)->NJU_DESCRI)
		oJson[ "RECNO"  ]      := (cAliasQry)->R_E_C_N_O_
	EndIf

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

	FreeObj(oJson)

Return aResult

/*/{Protheus.doc} GET vldEntrega api/pcp/v1/prodOrders/validatedeliverydate
Validação da data de entrega da ordem de produção

@type WSMETHOD
@author lucas.franca
@since 21/02/2022
@version P12
@param 01 deliveryDate, Caracter, Data de entrega da OP
@param 02 Product     , Caracter, Código do produto
@param 03 Quantity    , Numeric , Quantidade da OP
@param 04 Route       , Caracter, Código do roteiro
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET vldEntrega QUERYPARAM deliveryDate, Product, Quantity, Route WSSERVICE prodOrders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := vldEntrega(Self:deliveryDate, Self:Product, Self:Quantity, Self:Route)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} vldEntrega
Faz a validação da data de entrega da OP, e retorna a data de início de acordo com o leadtime do produto.

@type  Function
@author lucas.franca
@since 21/02/2022
@version P12
@param 01 cEntrega, Caracter, Data de entrega da OP
@param 02 cProduto, Caracter, Código do produto
@param 03 nQuant  , Numeric , Quantidade da OP
@param 04 cRoteiro, Caracter, Código do roteiro
@return aReturn, Array , Array com as informacoes da requisicao
                        aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
						aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
						aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function vldEntrega(cEntrega, cProduto, nQuant, cRoteiro)
	Local aResult  := {.F., STR0003, 400} //"Nenhum registro encontrado"
	Local dEntrega := StoD(StrTran(cEntrega, "-", ""))
	Local oJson    := JsonObject():New()

	Default cProduto := ""
	Default nQuant   := 0

	If dEntrega < dDataBase
		aResult[2] := EncodeUTF8(STR0046) //"Data de entrega da ordem de produção não pode ser anterior a Data Base."
	Else 
		dInicio := ProductionOrder():getDataInicio(dEntrega, cProduto, nQuant, cRoteiro)

		oJson["initialDate"] := PCPConvDat(dInicio, 2)

		aResult[1] := .T.
		aResult[2] := EncodeUTF8(oJson:toJson())
		aResult[3] := 200
	EndIf

	FreeObj(oJson)

Return aResult
