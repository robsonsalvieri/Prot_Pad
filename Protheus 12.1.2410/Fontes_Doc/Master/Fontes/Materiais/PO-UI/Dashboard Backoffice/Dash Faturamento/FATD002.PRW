#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FATD002.CH"
#INCLUDE "FWLIBVERSION.CH"

Static __aPrepared  := {}

//------------------------------------------------------------------------
/*/{Protheus.doc} FATD002 - NFiscalUF
  API Gráfico de NF por UF - Dashboard

  @author	Aline Navarro
  @since	22/12/2020
  @version  12.1.27
  @return 	Json
/*/
//------------------------------------------------------------------------
WSRESTFUL FATD002 DESCRIPTION STR0052 // "Grafico de Notas Fiscais por Estado"
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
WSMETHOD GET form WSSERVICE FATD002
	Local oResponse  := JsonObject():New()
	Local oCoreDash  := CoreDash():New()

	oCoreDash:SetPOForm(STR0025 , "charttype"       , 6   , STR0025 , .T., "string" , oCoreDash:SetPOCombo({{"bar",STR0026}}))
	oCoreDash:SetPOForm(STR0027 , "datainicio"      , 6   , STR0028 , .T., "date")
	oCoreDash:SetPOForm(""      , "datafim"         , 6   , STR0029 , .T., "date")
	oCoreDash:SetPOForm(""      , "tpNota"          , 6   , STR0030 , .T.,          , GetTipoNF()                           , .T.)
	oCoreDash:SetPOForm(""      , "uf"              , 6   , STR0031 , .T.,          , GetUF()                               , .T.)
	oCoreDash:SetPOForm(STR0032 , "prodgp"          , 6   , STR0033 , .F.,          , GetProdGp()                           , .T.)
	oCoreDash:SetPOForm(""      , "cfop"            , 6   , STR0034 , .F.,          , GetCFOP()                             , .T.)
	oCoreDash:SetPOForm(""      , "vend"            , 6   , STR0035 , .F.,          , GetSA3()                              , .T.)
	oCoreDash:SetPOForm(""      , "vendwhere"       , 6   , STR0036 , .F., "string" , oCoreDash:SetPOCombo({{"ped",STR0037}, {"cli",STR0007}}))
	oCoreDash:SetPOForm(""      , "tranfil"         , 6   , STR0038 , .F., "string" , oCoreDash:SetPOCombo({{"tyes",STR0039}, {"tno",STR0040}}))
	oCoreDash:SetPOForm(""      , "f4duplic"        , 6   , STR0041 , .F., "string" , oCoreDash:SetPOCombo({{"yes",STR0042}, {"no",STR0043}}))

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
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL FATD002

	Local aHeader     := {}
	Local aItems      := {}
	Local aRet        := {}
	Local aFilter     := {}
	Local lRet	      := .T.
	Local cSelect     := ""
	Local cWhere      := ""
	Local cFilter     := ""
	Local cUFs        := ""
	Local cError	  := STR0044
	Local cMoeda      := Iif(cPaisLoc == "RUS", '1.2-2', SuperGetMV("MV_SIMB1",.F.,"BRL"))
  	Local cTypeFMT    := Iif(cPaisLoc == "RUS","number","currency")
	Local cBody       := DecodeUtf8(Self:GetContent())
	Local oCoreDash   := CoreDash():New()
	Local oBody       := JsonObject():New()
	Local oJsonFilter := JsonObject():New()
	Local oJsonDD     := JsonObject():New()
	Local nLenFilter  := 0
//	Local nJsonFilter := 0
	Local nLenUf      := 0
//	Local nLenAFilter := 0
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
				{"amountSF2"   , STR0011 , cTypeFMT	 ,cMoeda   };  // # "Total da Nota"
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
			nLenUf := Len(oJsonFilter['uf'])
			For nX := 1 to nLenUf
				cUFs += "'"+oJsonFilter['uf'][nX]+"'," //prepara para o IN na query
			Next
			If !Empty(cUFs)
				cUFs := Substr(cUFs,1,Len(cUFs)-1) //tira a virgula
				cFilter += " AND SD2.D2_EST IN (  " + cUFs + " ) " //filtro UFs, do formulário
			Endif

			cFilter += FilterForm(oJsonFilter) //pega filtros do formulário, com exceção da UF
			oCoreDash:SetFields(aItems) //filtros da pesquisa rápida e avançada
			oCoreDash:SetApiQstring(Self:aQueryString) //filtros da pesquisa rápida e avançada
			aFilter := oCoreDash:GetApiFilter() //filtros da pesquisa rápida e avançada
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
				{"saleprice", STR0015 , cTypeFMT ,cMoeda,.T.,.T.  },; // # "Preço de Venda"
				{"sale"     , STR0016 , "number"  ,"1.2-5",.T.,.T. },; // # "Quantidade"
				{"amountSD2", STR0017 , cTypeFMT ,cMoeda          };  // # "Total da Nota"
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
			oCoreDash:SetFields(aItems) //filtros da pesquisa rápida e avançada
			oCoreDash:SetApiQstring(Self:aQueryString) //filtros da pesquisa rápida e avançada
			aFilter := oCoreDash:GetApiFilter() //filtros da pesquisa rápida e avançada
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
	// segundo nível do gráfico
	// Else
	// 	aHeader := {;
	// 		{"document"    , STR0018 ,           ,      ,.T.,.T. },; // # "Nota"
	// 		{"series"	   , STR0019 ,           ,      ,.T.,.T. },; // # "Serie"
	// 		{"client"      , STR0020 ,           ,      ,.T.,.T. },; // # "Cliente"
	// 		{"store"       , STR0021 ,           ,      ,.T.,.T. },; // # "Loja"
	// 		{"name"        , STR0022                             },; // # "Nome Cliente"
	// 		{"dateOfIssue" , STR0023 ,           ,      ,.T.,.T. },; // # "Emissão"
	// 		{"amountSF2"   , STR0024 , cTypeFMT,cMoeda         };  // # "Total da Nota"
	// 		}

	// 	aItems := {;
	// 		{"document"    , "SF2.F2_DOC"     },;
	// 		{"series"	   , "SF2.F2_SERIE"   },;
	// 		{"client"      , "SF2.F2_CLIENTE" },;
	// 		{"store"       , "SF2.F2_LOJA"    },;
	// 		{"name"        , "SA1.A1_NREDUZ"  },;
	// 		{"dateOfIssue" , "SF2.F2_EMISSAO" },;
	// 		{"amountSF2"   , "TOTALSD2"       };
	// 		}

	// 	cSelect :=" SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_TIPO, SF2.F2_EMISSAO, SA1.A1_NREDUZ, SUM(SD2.D2_TOTAL) AS TOTALSD2  "
	// 	nJsonFilter := Len(oJsonFilter['uf'])
	// 	For nX := 1 to nJsonFilter
	// 		cUFs += "'"+oJsonFilter['uf'][nX]+"'," //prepara para o IN na query
	// 	Next
	// 	If !Empty(cUFs)
	// 		cUFs := Substr(cUFs,1,Len(cUFs)-1) //tira a virgula
	// 		cFilter += " AND SD2.D2_EST IN (  " + cUFs + " ) " //filtro UFs, do formulário
	// 	Endif

	// 	cFilter += FilterForm(oJsonFilter) //pega filtros do formulário, com exceção da UF
	// 	oCoreDash:SetFields(aItems) //filtros da pesquisa rápida e avançada
	// 	oCoreDash:SetApiQstring(Self:aQueryString) //filtros da pesquisa rápida e avançada
	// 	aFilter := oCoreDash:GetApiFilter() //filtros da pesquisa rápida e avançada
	// 	nLenAFilter := Len(aFilter)
	// 	If nLenAFilter > 0
	// 		For nX := 1 to nLenAFilter
	// 			cFilter += " AND " + aFilter[nX][1]
	// 		Next
	// 	EndIf

	// 	aRet := QuerySF2(cSelect,cFilter)
	// 	oCoreDash:SetQuery(aRet[1])
	// 	oCoreDash:SetWhere(aRet[2])
	// 	oCoreDash:SetGroupBy(aRet[3])
	EndIf

	lRet := oCoreDash:BuildJson()

	If lRet
		oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson() )
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 404,  FWhttpEncode(cError) )
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
WSMETHOD POST retdados WSRECEIVE JsonFilter WSSERVICE FATD002
	Local oResponse := JsonObject():New()
	Local oCoreDash := CoreDash():New()
	Local oJson     := JsonObject():New()

	FWLsPutAsyncInfo("LS006",RetCodUsr(),'05',"FATD002")

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
    Local aUfTot    := {}
	Local aClrChart := oCoreDash:GetColorChart() //cor do gráfico
	Local cFilter   := ""
	Local nX        := 0
	Local nLenUf    := 0
	Local nCor		:= 0

	cFilter := FilterForm(oJson) //pega filtros do formulário, com exceção da UF

	If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0
		 nLenUf := Len(oJson['uf'])

		If (Ascan(oJson['uf'],STR0045) == 0) 
			For nX := 1 to nLenUf
				aAdd(aCab,oJson['uf'][nX])
				aAdd(aData, RetTotNF(oJson['uf'][nX],cFilter) )
			Next
		Else
			aUfTot := GetUF()
			nLenUf := len(aUfTot)
			For nX := 2 to nLenUf
				aAdd(aCab,aUfTot[nX])
				aAdd(aData, RetTotNF(aUfTot[nX],cFilter) )
			Next
		EndIf

		For nX := 1 To Len(aData)
			nCor++
			nCor := IIf(nCor>28,1,nCor)//Tratamento para caso o país utilizado tenha mais que 28 estados
      		oCoreDash:SetChartInfo( {aData[nX]}, aCab[nX] , /*cType*/, aClrChart[nCor][3] /*"cColorBackground"*/ )
		Next

		aDataFim := {}
		aAdd(aDataFim, oCoreDash:SetChart({STR0031},,/*lCurrency*/.T.,,))
	EndIf
	oResponse["items"] := aDataFim

	Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetTotNF
Retorna Total de NF, query principal

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function RetTotNF(cUF,cFilter)

	Local cQuery       := ""
	Local cTemp        := GetNextAlias()
	Local xRet         := ""
	Local nSF4         := AT( "SF4", cFilter )
	Local cMD5         := ""
	Local nPosPrepared := 0
	Local __oQrySd2    := Nil

	Default cUF  := ""

	cQuery := " SELECT SUM(SD2.D2_TOTAL) AS TOTALSD2  FROM " + RetSqlName("SD2") + " SD2 "
	cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 "
	cQuery += " ON SF2.F2_FILIAL = SD2.D2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE "
	cQuery += " AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "

	If nSF4 > 0
		cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4 "
		cQuery += " ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D2_TES "
	EndIf
	cQuery += " WHERE "
	cQuery += " SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
	If !Empty(cFilter)
		cQuery += cFilter
	Endif
	If !Empty(cUF)
		cQuery += " AND SD2.D2_EST = ? "
	Endif
	cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
	cQuery += " AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
	If nSF4 > 0
		cQuery += " AND SF4.D_E_L_E_T_ = ' ' "
	EndIf

	cMD5 := MD5(cQuery) 
	If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0
		cQuery	:= ChangeQuery(cQuery)
		__oQrySd2 := IIf(A002FWExecStat(), FwExecStatement():New(cQuery), FWPreparedStatement():New(cQuery))
		Aadd(__aPrepared,{__oQrySd2, cMD5})
		nPosPrepared := Len(__aPrepared)
	EndIf		

	__aPrepared[nPosPrepared][1]:SetString(1,cUF)

	If A002FWExecStat()
		__aPrepared[nPosPrepared][1]:OpenAlias(cTemp)
	Else
		cQuery := __aPrepared[nPosPrepared][1]:GetFixQuery()
		DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .T., .T. )
	EndIf

	xRet :=	(cTemp)->TOTALSD2

	(cTemp)->( DBCloseArea() )

Return xRet

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
/*/{Protheus.doc} GetUF
Retorna UF

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetUF()

	Local aUF       := {}
	Local aUFX5     := {}
	Local nX        := 0
	Local nLenAUFX5 := 0

	aUFX5 := FWGetSX5("12")
	nLenAUFX5 := Len(aUFX5)
	For nX := 1 To nLenAUFX5
		aAdd(aUF,RTrim(aUFX5[nX,3])) //X5_CHAVE
	Next

Return aUF

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTipoNF
Retorna Tipos de NF

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetTipoNF()

	Local aTpNota := {}

	aAdd(aTpNota, "N - " + STR0046) //Normal
	aAdd(aTpNota, "C - " + STR0047)  // Compl.Preco/Quantidade
	If cPaisLoc == 'BRA'
		aAdd(aTpNota, "I - " + STR0048) //Compl.ICMS
		aAdd(aTpNota, "P - " + STR0049) //Compl.IPI
	Endif
	aAdd(aTpNota, "D - " + STR0050) //Dev.Compras
	aAdd(aTpNota, "B - " + STR0051) //Utiliza Fornecedor

Return aTpNota

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProdGp
Retorna Grupos de Produtos

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetProdGp()

	Local aProdGp := {}
	Local cQuery  := ""
	Local cTemp   := GetNextAlias()

	cQuery := " SELECT BM_GRUPO "
	cQuery += " FROM " + RetSqlName("SBM") + " SBM "
	cQuery += " WHERE "
	cQuery += " SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
	cQuery += " AND SBM.D_E_L_E_T_ = ' ' "

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .F., .T. )

	While (cTemp)->( !Eof() )
		aAdd( aProdGp, 	(cTemp)->BM_GRUPO )
		(cTemp)->(DbSkip())
	EndDo

	(cTemp)->( DBCloseArea() )

Return aProdGp

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCFOP
Retorna os dados CFOP

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetCFOP()

	Local aCFOP := {}
	Local aCFOPX5 := {}
	Local nX := 0
	Local nLenACFO := 0

	aCFOPX5 := FWGetSX5("13")
	nLenACFO := Len(aCFOPX5)
	For nX := 1 To nLenACFO
		aAdd(aCFOP,RTrim(aCFOPX5[nX,3])) //X5_CHAVE
	Next

Return aCFOP

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSA3
Retorna Vendedores

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function GetSA3()

	Local aVend  := {}
	Local cQuery := ""
	Local cTemp  := GetNextAlias()

	cQuery := " SELECT A3_COD "
	cQuery += " FROM " + RetSqlName("SA3") + " SA3 "
	cQuery += " WHERE "
	cQuery += " SA3.A3_FILIAL = '" + xFilial("SA3") + "' "
	cQuery += " AND SA3.D_E_L_E_T_ = ' ' "

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .F., .T. )

	While (cTemp)->( !Eof() )
		aAdd( aVend, 	(cTemp)->A3_COD )
		(cTemp)->(DbSkip())
	EndDo

	(cTemp)->( DBCloseArea() )

Return aVend

//-------------------------------------------------------------------
/*/{Protheus.doc} FilterForm
Retorna filtros do formulário com exceção da UF

@author Aline Navarro
@since 22/12/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function FilterForm(oJson)

	Local cTpNota := ""
	Local cFilter := ""
	Local cProdGp := ""
	Local cCfop   := ""
	Local cVend   := ""
	Local cAnoIni := SubStr(oJson['datainicio'], 1, 4)
	Local cMesIni := SubStr(oJson['datainicio'], 6, 2)
	Local cDiaIni := SubStr(oJson['datainicio'], 9, 2)
	Local cDtIni  := cAnoIni + cMesIni + cDiaIni
	Local cAnoFim := SubStr(oJson['datafim'], 1, 4)
	Local cMesFim := SubStr(oJson['datafim'], 6, 2)
	Local cDiaFim := SubStr(oJson['datafim'], 9, 2)
	Local cDtFim  := cAnoFim + cMesFim + cDiaFim
	Local nLenTpNota := 0
	Local nLenProdgp := 0
	Local nLenCfop   := 0
	Local nLenVend   := 0
	Local nx         := 0

	//Data de
	If !Empty(cDtIni)
		cFilter += " AND SD2.D2_EMISSAO  >= '" + cDtIni + "' "
	Endif

	//Data ate
	If !Empty(cDtFim)
		cFilter += " AND SD2.D2_EMISSAO  <= '" + cDtFim + "' "
	Endif

	//Tipos de nota
	nLenTpNota := Len(oJson['tpNota'])
	For nX := 1 to nLenTpNota
		cTpNota += "'"+SubStr(oJson['tpNota'][nX],1,1)+"'," //prepara para o IN na query
	Next

	If !Empty(cTpNota) 
		cTpNota := Substr(cTpNota,1,Len(cTpNota)-1) //tira a virgula
		cFilter += " AND SD2.D2_TIPO IN (  " + cTpNota + " ) "
	Endif

	//Grupos de produto
	If oJson:GetJsonText('prodgp') <> 'null' .And. Len(oJson["prodgp"]) <> 0
		nLenProdgp := Len(oJson['prodgp'])
		For nX := 1 to nLenProdgp
			cProdGp += "'"+oJson['prodgp'][nX]+"'," //prepara para o IN na query
		Next

		cProdGp := Substr(cProdGp,1,Len(cProdGp)-1) //tira a virgula
		cFilter += " AND SD2.D2_GRUPO IN (  " + cProdGp + " ) "
	EndIf

	//CFOP
	If oJson:GetJsonText('cfop') <> 'null' .And. Len(oJson["cfop"]) <> 0 
		nLenCfop := Len(oJson['cfop'])
		For nX := 1 to nLenCfop
			cCfop += "'"+oJson['cfop'][nX]+"'," //prepara para o IN na query
		Next

		cCfop := Substr(cCfop,1,Len(cCfop)-1) //tira a virgula
		cFilter += " AND SD2.D2_CF IN (  " + cCfop + " ) "
	EndIf

	//Vendedores
	If oJson:GetJsonText('vend') <> 'null' .And. Len(oJson["vend"]) <> 0
		nLenVend := Len(oJson['vend'])
		For nX := 1 to nLenVend
			cVend += "'"+oJson['vend'][nX]+"'," //prepara para o IN na query
		Next

		cVend := Substr(cVend,1,Len(cVend)-1) //tira a virgula
		If oJson["vendwhere"] == "cli" //vendedor do cliente
			cFilter += " AND SA1.A1_VEND IN (  " + cVend + " ) "
		Else
			cFilter += " AND SF2.F2_VEND1 IN (  " + cVend + " ) " //vendedor do pedido ou param em branco
		EndIf
	EndIf

	//NF de Transferência entre Filiais
	If oJson:GetJsonText('tranfil') <> 'null' .And. Len(oJson["tranfil"]) <> 0
		If oJson["tranfil"] == "tno" //desconsidera notas de transferencia entre filiais
			cFilter += "  AND SF4.F4_TRANFIL = '2' "
		EndIf
	EndIf

	//Somente NF que geram Financeiro?
	If oJson:GetJsonText('f4duplic') <> 'null' .And. Len(oJson["f4duplic"]) <> 0
		If oJson["f4duplic"] == "yes" // somente nf que geram duplicata
			cFilter += "  AND SF4.F4_DUPLIC  = 'S' "
		EndIf
	EndIf

Return cFilter

/*/{Protheus.doc} A002FWExecStat
Função utilizada para validar a data da LIB para utilização da classe FWExecStatement

@type       Function
@author     CRM/Faturamento
@since      Mar/2022
@version    12.1.33
@return     __Ft002VerLib, lógico, se pode ser utilizado a classe FWExecStatement
/*/
Static Function A002FWExecStat()

Static __Ft002VerLib := Nil

If __Ft002VerLib == Nil
	__Ft002VerLib := FWLibVersion() >= "20211116"
EndIf

Return __Ft002VerLib
