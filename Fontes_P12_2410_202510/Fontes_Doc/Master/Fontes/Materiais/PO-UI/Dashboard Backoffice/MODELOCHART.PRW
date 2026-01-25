#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FATD002.CH"

Static __oQrySd2 As Object

//------------------------------------------------------------------------
/*/{Protheus.doc} MODCHART - NFiscalUF
API Gráfico de NF por UF - Dashboard

@author	Aline Navarro
@since	22/12/2020
@version  12.1.27
@return 	Json
/*/
//------------------------------------------------------------------------
WSRESTFUL MODCHART DESCRIPTION "Grafico de Notas Fiscais por Estado"

	WSDATA JsonFilter       AS STRING	OPTIONAL
	WSDATA drillDownFilter  AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL

	WSMETHOD GET form ;
		DESCRIPTION STR0001 ; // #"Carrega os campos que serão apresentados no formulário"
	WSSYNTAX "/charts/form/" ;
		PATH "/charts/form";
		PRODUCES APPLICATION_JSON

	WSMETHOD POST retdados ;
		DESCRIPTION STR0003 ; // # "Carrega os itens"
	WSSYNTAX "/charts/retdados/{JsonFilter}" ;
		PATH "/charts/retdados";
		PRODUCES APPLICATION_JSON

	WSMETHOD POST itemsDetails ;
		DESCRIPTION STR0004 ; // # "Carrega os Itens Utilizados para Montagem do itens"
	WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
		PATH "/charts/itemsDetails";
		PRODUCES APPLICATION_JSON

ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET form
Retorna os campos que serão apresentados no formulário.
O padrão do campo deve seguir o Dynamic Form do Portinari.

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
WSMETHOD GET form WSSERVICE MODCHART

	Local oResponse  := JsonObject():New()
	Local oCoreDash  := CoreDash():New()

	oCoreDash:SetPOForm(STR0025 , "charttype"       , 6   , STR0025 , .T., "string" , oCoreDash:SetPOCombo({{"bar",STR0026}}))
	oCoreDash:SetPOForm(STR0027 , "datainicio"      , 6   , STR0028 , .T., "date")
	oCoreDash:SetPOForm(""      , "datafim"         , 6   , STR0029 , .T., "date")
	
	oResponse  := oCoreDash:GetPOForm()

	Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST itemsDetails
Carrega os Itens Utilizados para Montagem do Painel

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL MODCHART

	Local aHeader     := {}
	Local aItems      := {}
	Local aRet        := {}
	Local aFilter     := {}
	Local lRet	      := .T.
	Local cSelect     := ""
	Local cWhere      := ""
	Local cFilter     := ""
	Local cError	  := STR0044
	Local cMoeda      := SuperGetMV("MV_SIMB1",.F.,"BRL")
	Local cBody       := DecodeUtf8(Self:GetContent())
	Local oCoreDash   := CoreDash():New()
	Local oBody       := JsonObject():New()
	Local oJsonFilter := JsonObject():New()
	Local oJsonDD     := JsonObject():New()
	Local nLenFilter  := 0
	Local nX          := 0

	If !Empty(cBody)
		oBody:FromJson(cBody)

		If ValType(oBody["chartFilter"]) == "J"
			oJsonFilter := oBody["chartFilter"]
		EndIf

		If ValType(oBody["detailFilter"]) == "A"
			oJsonDD := oBody["detailFilter"]
		EndIf
	EndIf

	Self:SetContentType("application/json")

	If oJsonFilter:GetJsonText("level") == "null" .Or. Len(oJsonFilter["level"]) == 0
		If Len(oJsonDD) == 0
			aHeader := {;
				{"document"    , STR0005 ,"link"     ,,.T.,.T. },; // # "Nota"
				{"series"	   , STR0006 ,           ,,.T.,.T. },; // # "Serie"
				{"client"      , STR0007 ,           ,,.T.,.T. },; // # "Cliente"
				{"store"       , STR0008 ,           ,,.T.,.T. },; // # "Loja"
				{"name"        , STR0009                       },; // # "Nome Cliente"
				{"dateOfIssue" , STR0010 ,           ,,.T.,.T. },; // # "Emissão"
				{"UF"          , STR0031 ,           ,,.T.,.T. },; // # "UF"
				{"amountSF2"   , STR0011 , "currency",cMoeda   };  // # "Total da Nota"
				}

			aItems := {;
				{"document"    , "SF2.F2_DOC"     },;
				{"series"	   , "SF2.F2_SERIE"   },;
				{"client"      , "SF2.F2_CLIENTE" },;
				{"store"       , "SF2.F2_LOJA"    },;
				{"name"        , "SA1.A1_NREDUZ"  },;
				{"dateOfIssue" , "SF2.F2_EMISSAO" },;
				{"UF"          , "SD2.D2_EST"     },;
				{"amountSF2"   , "TOTALSD2"       };
				}

			cSelect :=" SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_TIPO, SF2.F2_EMISSAO, SA1.A1_NREDUZ, SD2.D2_EST, SUM(SD2.D2_TOTAL) AS TOTALSD2  "

			cFilter += FilterForm(oJsonFilter) 
			oCoreDash:SetFields(aItems) 
			oCoreDash:SetApiQstring(Self:aQueryString) 
			aFilter := oCoreDash:GetApiFilter() 
			nLenFilter := Len(aFilter)
			If nLenFilter > 0
				For nX := 1 to nLenFilter
					cFilter += " AND " + aFilter[nX][1]
				Next
			EndIf

			aRet := QuerySF2(cSelect,cFilter)
			oCoreDash:SetQuery(aRet[1])
			oCoreDash:SetWhere(aRet[2])
			oCoreDash:SetGroupBy(aRet[3])

		Elseif Len(oJsonDD) == 1

			aHeader := {;
				{"item"     , STR0012                              },; // # "Item"
				{"product"  , STR0013 ,           ,      ,.T.,.T.  },; // # "Cod. Produto"
				{"prodname" , STR0014                              },; // # "Desc. Produto"
				{"saleprice", STR0015 , "currency",cMoeda,.T.,.T.  },; // # "Preço de Venda"
				{"sale"     , STR0016 , "number"  ,"1.2-5",.T.,.T. },; // # "Quantidade"
				{"amountSD2", STR0017 , "currency",cMoeda          };  // # "Total da Nota"
				}

			aItems := {;
				{"item"      , "SD2.D2_ITEM"   },;
				{"product"	 , "SD2.D2_COD"    },;
				{"prodname"  , "SB1.B1_DESC"   },;
				{"saleprice" , "SD2.D2_PRCVEN" },;
				{"sale"      , "SD2.D2_QUANT"  },;
				{"amountSD2" , "SD2.D2_TOTAL"  };
				}

			cSelect := " SD2.D2_ITEM, SD2.D2_COD, SB1.B1_DESC, SD2.D2_PRCVEN, SD2.D2_QUANT, SD2.D2_TOTAL "
			cWhere := " SD2.D2_DOC = '" + oJsonDD[1]['document'] + "' AND SD2.D2_SERIE = '" + oJsonDD[1]['series'] + "' "
			oCoreDash:SetFields(aItems) 
			oCoreDash:SetApiQstring(Self:aQueryString) 
			aFilter := oCoreDash:GetApiFilter() 
			nLenFilter := Len(aFilter)
			If nLenFilter > 0
				For nX := 1 to nLenFilter
					cWhere += " AND " + aFilter[nX][1]
				Next
			EndIf
			aRet := QuerySD2(cSelect, cWhere)

			oCoreDash:SetQuery(aRet[1])
			oCoreDash:SetWhere(aRet[2])

		Endif
	EndIf

	oCoreDash:BuildJson()

	If lRet
		oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson() )
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

	oCoreDash:Destroy()
	FreeObj(oJsonDD)
	FreeObj(oJsonFilter)
	FreeObj(oBody)

	aSize(aRet, 0)
	aSize(aItems, 0)
	aSize(aHeader, 0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST retDados
Retorna os dados do Gráfico

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE MODCHART

	Local oResponse := JsonObject():New()
	Local oCoreDash := CoreDash():New()
	Local oJson     := JsonObject():New()

	oJson:FromJson(DecodeUtf8(Self:GetContent()))

	retDados(@oResponse, oCoreDash, oJson)

	Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

	oResponse := Nil
	FreeObj( oResponse )

	oCoreDash:Destroy()
	FreeObj( oCoreDash )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} retDados
Retorna dados para montagem do gráfico

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function retDados(oResponse, oCoreDash, oJson)

	Local aData     := {}
	Local aDataFim  := {}
	Local aCab      := {}
	Local aClrChart := oCoreDash:GetColorChart() //cor do gráfico
	Local cFilter   := ""
	Local nX        := 0
	Local nAuxClr	:= 0
	
	cFilter := FilterForm(oJson) 

	If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0

		aAdd(aCab,"São Paulo")
		aAdd(aCab,"Rio de Janeiro")
		aAdd(aCab,"Pernambuco")
		aAdd(aData, 110000 )
		aAdd(aData, 100000 )
		aAdd(aData, 120000 )
		
		If __oQrySd2 != Nil
			__oQrySd2:Destroy()
			__oQrySd2 := Nil
		Endif

		For nX := 1 To Len(aData)
			nAuxClr++
			oCoreDash:SetChartInfo( {aData[nX]}, aCab[nX] , /*cType*/, aClrChart[nX + nAuxClr][3] /*"cColorBackground"*/ )
		Next nX 

		aDataFim := {}
		aAdd(aDataFim, oCoreDash:SetChart({"Estados"},,/*lCurrency*/.T.,,))
	EndIf
	oResponse["items"] := aDataFim

	Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QuerySF2
Query nível 1 dos Detalhes

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function QuerySF2(cSelect as Char, cFilter as Char)

	Local cQuery  := ""
	Local cWhere  := ""
	Local cGroup  := ""
	Local nSF4   := AT( "SF4", cFilter ) 

	Default cSelect := " SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_TIPO, SF2.F2_EMISSAO, SA1.A1_NREDUZ, SD2.D2_EST, SUM(SD2.D2_TOTAL) AS TOTALSD2  "
	Default cFilter := ""

	cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SF2") + " SF2 "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
	cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 "
	cQuery += " ON SD2.D2_FILIAL = SF2.F2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA "
	If nSF4 > 0
		cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 "
		cQuery += " ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D2_TES "
	EndIf

	cWhere := " SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
	If !Empty(cFilter)
		cWhere += cFilter
	Endif

	cWhere += " AND SF2.D_E_L_E_T_ = ' ' "
	cWhere += " AND SD2.D_E_L_E_T_ = ' ' "
	cWhere += " AND SA1.D_E_L_E_T_ = ' ' "
	If nSF4 > 0
		cWhere += " AND SF4.D_E_L_E_T_ = ' ' "
	EndIf
	cGroup := " SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_TIPO, SF2.F2_EMISSAO, SA1.A1_NREDUZ, SD2.D2_EST "

Return { cQuery, cWhere, cGroup }

//-------------------------------------------------------------------
/*/{Protheus.doc} QuerySD2
Query nível 2 dos Detalhes, retorna itens da nota

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function QuerySD2(cSelect as Char, cFilter as Char)

	Local cQuery  := ""
	Local cWhere  := ""
	Local nSF4   := AT( "SF4", cFilter ) 

	Default cSelect := " SD2.D2_ITEM, SD2.D2_COD, SB1.B1_DESC, SD2.D2_PRCVEN, SD2.D2_QUANT, SD2.D2_TOTAL "
	Default cFilter := ""

	cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += " ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SD2.D2_COD "
	If nSF4 > 0
		cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 "
		cQuery += " ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D2_TES "
	EndIf

	cWhere := " SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
	If !Empty(cFilter)
		cWhere += " AND " + cFilter
	Endif
	cWhere += " AND SD2.D_E_L_E_T_ = ' ' "
	cWhere += " AND SB1.D_E_L_E_T_ = ' ' "
	If nSF4 > 0
		cWhere += " AND SF4.D_E_L_E_T_ = ' ' "
	EndIf

Return {cQuery, cWhere}

//-------------------------------------------------------------------
/*/{Protheus.doc} FilterForm
Retorna filtros do formulário com exceção da UF

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function FilterForm(oJson)

	Local cFilter := ""
	Local cDtIni  := "20200101"
	Local cDtFim  := "2021231"

	//Data de
	If !Empty(cDtIni)
		cFilter += " AND SD2.D2_EMISSAO  >= '" + cDtIni + "' "
	Endif

	//Data ate
	If !Empty(cDtFim)
		cFilter += " AND SD2.D2_EMISSAO  <= '" + cDtFim + "' "
	Endif

Return cFilter
