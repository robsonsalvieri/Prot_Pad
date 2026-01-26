#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FATD001.CH"

/*/{Protheus.doc} MODCARD

API Cards de Pedidos com Bloqueio - Dashboard 

@author		Aline Navarro
@since		10/11/2020
/*/
WSRESTFUL MODCARD DESCRIPTION STR0001   // #"Pedidos com Bloqueio"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL
	WSDATA Code		    AS STRING	OPTIONAL
  WSDATA TpBlq      AS STRING OPTIONAL

    WSMETHOD POST itemsDetails ;
    DESCRIPTION STR0002 ;   // #"Carrega os Itens Utilizados para Montagem do Painel"
    WSSYNTAX "/cards/itemsDetails/{TpBlq}/{Order, Page, PageSize, Fields}" ;
    PATH "/cards/itemsDetails/{TpBlq}";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET headerItens ;
    DESCRIPTION STR0003 ;   // #"Carrega os Cabeçalho a ser apresentado nos detalhes"
    WSSYNTAX "/cards/headerItens/" ;
    PATH "/cards/headerItens";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET fieldsInfo ;
    DESCRIPTION STR0004 ;   // #"Carrega os campos que podem que ser utilizados"
    WSSYNTAX "/cards/fieldsInfo/" ;
    PATH "/cards/fieldsInfo";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET cardInfo ;
    DESCRIPTION STR0005 ;   // #"Carrega as informações do Painel"
    WSSYNTAX "/cards/cardInfo/{TpBlq}" ;
    PATH "/cards/cardInfo/{TpBlq}";
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST itemsDetails
Carrega os Itens Utilizados para Montagem do Card

@author Aline Navarro 
@since 10/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST itemsDetails PATHPARAM TpBlq WSRECEIVE Order, Page, PageSize, Fields WSSERVICE MODCARD

  Local aHeader     := {}
  Local aRet        := {}
  Local cFilter     := ""
  Local aFilter     := {}
  Local nX          := 0
  Local cBody       := DecodeUtf8(Self:GetContent())
  Local cError		  := STR0006    // #"Erro na Requisição"
	Local lRet			  := .T.
  Local oBody       := JsonObject():New()
  Local oCoreDash   := CoreDash():New()
  Local oJsonDD     := JsonObject():New()
  Local cTpBloq     := ""
  Local nQtdFilter  := 0
  cTpBloq := Self:TpBlq

  Self:SetContentType("application/json")

  If !Empty(cBody)
    oBody:FromJson(cBody)
    If ValType(oBody["detailFilter"]) == "A"
      oJsonDD := oBody["detailFilter"]
    EndIf
  EndIf

  If Len(oJsonDD) == 0
    aHeader := RetHeader("SC9")
    oCoreDash:SetFields(DePara("SC9"))
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter := oCoreDash:GetApiFilter()

    nQtdFilter := Len(aFilter) 
    If nQtdFilter > 0 
      For nX := 1 to nQtdFilter
        cFilter += " AND " + aFilter[nX][1] 
      Next
    EndIf

    aRet := MntQuery(cTpBloq,,cFilter)
  ElseIf Len(oJsonDD) == 1
    aHeader := RetHeader("SC5")
    oCoreDash:SetFields(DePara("SC5"))
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter := oCoreDash:GetApiFilter()

    nQtdFilter := Len(aFilter)
    If nQtdFilter > 0 
      For nX := 1 to nQtdFilter
        cFilter += " AND " + aFilter[nX][1]
      Next
    EndIf

    cFilter += " AND SC5.C5_NUM = '" + oJsonDD[1]['order'] + "' "
    aRet := QuerySC5(cTpBloq,cFilter)
 ElseIf Len(oJsonDD) == 2
    aHeader := RetHeader("SC9CLI")
    oCoreDash:SetFields(DePara("SC9CLI"))
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter := oCoreDash:GetApiFilter()

    nQtdFilter := Len(aFilter)
    If nQtdFilter > 0 
      For nX := 1 to nQtdFilter
        cFilter += " AND " + aFilter[nX][1]
      Next
    EndIf

    cFilter += " AND SA1.A1_COD = '" + oJsonDD[1]['client'] + "' AND SA1.A1_LOJA = '" + oJsonDD[1]['store'] + "' "

    aRet := MntQuery(cTpBloq,,cFilter)
  EndIf

  oCoreDash:SetQuery(aRet[1])
  oCoreDash:SetWhere(aRet[2])
  If Len(aRet) >= 3
    oCoreDash:SetGroupBy(aRet[3])
  EndIf
  oCoreDash:BuildJson()

	If lRet
    oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson())
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

	oCoreDash:Destroy()
  FreeObj(aRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET headerItens
Retorna o aHeader que será utilizado no detalhamento do Card

@author Aline Navarro
@since 10/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET headerItens WSSERVICE MODCARD

  Local aHeader    := {}
  Local oCoreDash:= CoreDash():New()
  Local oResponse		:=	JsonObject():New()

  aHeader := {;
    {"emission"	    , STR0007      },;    // #"Data de Emissão"
    {"product"	    , STR0008      },;    // #"Produto"
    {"prodgroup"	  , STR0009      },;    // #"Grupo de Produto"
    {"client"	      , STR0010      },;    // #"Cliente"
    {"store"        , STR0011      },;    // #"Loja"
    {"name"         , STR0012      },;    // #"Nome"
    {"cfop"         , STR0013      },;    // #"CFOP"
    {"paymentterms" , STR0014      },;    // #"Condição de Pagamento"
    {"deliverydate"	, STR0015      };     // #"Entrega"
  }

  oResponse["items"]   := oCoreDash:SetPOHeader(aHeader)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET fieldsInfo
Carrega os campos que podem que ser utilizados

@author Aline Navarro
@since 10/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET fieldsInfo WSSERVICE MODCARD

    Local aItems    := {}
    Local item      := {}
    Local oResponse		:=	JsonObject():New()

    item := JsonObject():New()
    item["label"]  :=	"Modelo 1:"
    item["value"] :=	"totalFat"

    AADD(aItems, item)

    item := JsonObject():New()
    item["label"]  :=	"Modelo 2:"
    item["value"] :=	"totalDup"

    AADD(aItems, item)

    oResponse["items"]      := aItems

    Self:SetResponse( oResponse:ToJson())
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET cardInfo
Método para retornar os dados do Card

@author Aline Navarro
@since 19/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET cardInfo PATHPARAM TpBlq WSRESTFUL MODCARD

Local aFilter     := {}
Local cWhere      := ""
Local lRet			  :=	.T.
Local nFiltro     := 0
Local oCoreDash   := CoreDash():New()
Local oResponse		:=	JsonObject():New()
Local cTpBloq     := ""
Local nQtdFilter  := 0
cTpBloq := Self:TpBlq

oCoreDash:SetFields(DePara())
oCoreDash:SetApiQstring(Self:aQueryString)
aFilter := oCoreDash:GetApiFilter()

nQtdFilter := Len(aFilter)
For nFiltro := 1 to nQtdFilter
  cWhere += " AND " + aFilter[nFiltro][1]
Next

RetCardInfo( @oResponse, cWhere, cTpBloq )

self:SetResponse( EncodeUtf8(FwJsonSerialize(oResponse,.T.,.T.)) )

oResponse := Nil
FreeObj( oResponse )
oCoreDash := Nil
FreeObj( oCoreDash )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RetCardInfo
Retorna os dados que poderão ser apresentados no Card

@author Aline Navarro
@since 10/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function RetCardInfo( oResponse, cWhere, cTpBloq )

    Local item    := {}
    Local aItems  := {}

    item := JsonObject():New()

    item["totalFat"]    :=	"R$ " + Transform(1557032, "@E 999,999,999,999.99")

    item["totalDup"]    :=	"R$ " + Transform(3652326, "@E 999,999,999,999.99")

    AADD(aItems, item)

    item := {}

    oResponse['hasNext']  := 'false'
    oResponse["items"]    := aItems

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQuery
Query responsável por trazer os itens utilizados no Card e dos Níveis 1 e 3 dos Detalhes

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Aline Navarro
@since 10/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQuery(cTpBloq,cSelect,cFilter,cInfo)
  Local cQuery  := ""
  Local cWhere  := ""

  Default cFilter := ""
  Default cInfo   := ""
  Default cSelect := " SC5.C5_NUM, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NREDUZ, SC9.C9_PRODUTO, SC9.C9_ITEM, SC9.C9_SEQUEN, SC9.C9_LOCAL, SC9.C9_DATALIB, SC9.C9_PRCVEN, SC9.C9_LOTECTL, SC9.C9_NUMLOTE, SC9.C9_NUMSERI, (SC9.C9_QTDLIB * SC9.C9_PRCVEN) AS TOTALSC9, SC5.C5_VEND1, SC5.C5_EMISSAO, SC5.C5_CONDPAG, SC9.C9_QTDLIB, SC6.C6_ENTREG, SC6.C6_VALOR, SC6.C6_CF, SB1.B1_DESC, SB1.B1_GRUPO "

  cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SC9") + " SC9 "
  cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5  ON SC5.C5_FILIAL = SC9.C9_FILIAL  AND SC5.C5_NUM = SC9.C9_PEDIDO "
  cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6  ON SC6.C6_FILIAL = SC9.C9_FILIAL  AND SC6.C6_NUM = SC9.C9_PEDIDO AND SC6.C6_ITEM = SC9.C9_ITEM "
  If cInfo == "totalDup"
    cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4  ON SF4.F4_FILIAL = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO = SC6.C6_TES "
  EndIf
  cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1  ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI "
  cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1  ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SC9.C9_PRODUTO "

  cWhere := " SC9.C9_FILIAL = '" + xFilial("SC9") + "' "
 
  If !Empty(cFilter)
    cWhere += cFilter
  Endif
  cWhere += " AND SC5.C5_TIPO = 'N' " // só considera pedidos normais
  cWhere += " AND SC5.C5_EMISSAO <> ' ' " // só considera pedidos com data de emissão

  If cTpBloq == "cred"
    cWhere += " AND SC9.C9_BLCRED <> ' ' AND SC9.C9_BLCRED <> '10' AND SC9.C9_BLEST = ' ' "
  ElseIf cTpBloq == "est"
    cWhere += " AND SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST <> ' ' AND SC9.C9_BLEST <> '10' "
  ElseIf cTpBloq == "credest"
    cWhere += " AND SC9.C9_BLCRED <> ' ' AND SC9.C9_BLCRED <> '10' AND SC9.C9_BLEST <> ' '  AND SC9.C9_BLEST <> '10' "
  Elseif cTpBloq == "aptos"
    cWhere += " AND SC9.C9_BLCRED = ' ' AND SC9.C9_BLEST = ' '  AND SC9.C9_NFISCAL = ' ' "
  EndIf

  cWhere += " AND SC9.D_E_L_E_T_ = ' ' "
  cWhere += " AND SC5.D_E_L_E_T_ = ' ' "
  cWhere += " AND SC6.D_E_L_E_T_ = ' ' "
  cWhere += " AND SA1.D_E_L_E_T_ = ' ' "
  cWhere += " AND SB1.D_E_L_E_T_ = ' ' "

  If cInfo == "totalDup"
    cWhere += " AND SF4.D_E_L_E_T_ = ' ' "
  Endif
 
Return {cQuery, cWhere}

//-------------------------------------------------------------------
/*/{Protheus.doc} QuerySC5
Query responsável por trazer os itens do segundo nível do Detalhes do Card

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Aline Navarro
@since 10/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function QuerySC5(cTpBloq,cFilter)
  Local cQuery  := ""
  Local cWhere  := ""
  Local cGroup  := ""

  Default cFilter := ""

  cSelect := " SC5.C5_NUM, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NREDUZ, DA0.DA0_DESCRI, SE4.E4_DESCRI, SUM(SC6.C6_VALOR) AS TOTALSC6 "

  cQuery := " SELECT " + cSelect + " FROM " + RetSqlName("SC6") + " SC6 "
  cQuery += " INNER JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = SC6.C6_FILIAL  AND SC5.C5_NUM = SC6.C6_NUM AND SC5.D_E_L_E_T_ = ' ' "
  cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' "
  cQuery += " LEFT JOIN " + RetSqlName("SE4") + " SE4 ON SE4.E4_FILIAL = '" + xFilial("SE4") + "' AND SE4.E4_CODIGO = SC5.C5_CONDPAG AND SE4.D_E_L_E_T_ = ' ' "
  cQuery += " LEFT JOIN " + RetSqlName("DA0") + " DA0 ON DA0.DA0_FILIAL = '" + xFilial("DA0") + "' AND DA0.DA0_CODTAB = SC5.C5_TABELA AND DA0.D_E_L_E_T_ = ' ' "
  
  cWhere := " SC6.C6_FILIAL = '" + xFilial("SC6") + "' "

  If !Empty(cFilter)
    cWhere += cFilter
  Endif

  cWhere += " AND SC5.C5_TIPO = 'N' " // só considera pedidos normais
  cWhere += " AND SC5.C5_EMISSAO <> ' ' " // só considera pedidos com data de emissão

  cWhere += " AND SC6.D_E_L_E_T_ = ' ' "
  cGroup += " SC5.C5_NUM, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NREDUZ, DA0.DA0_DESCRI, SE4.E4_DESCRI "

Return {cQuery, cWhere, cGroup}

//-------------------------------------------------------------------
/*/{Protheus.doc} DePara
Realiza o De/Para entre os objetos do Json e os campos do Protheus

@author Aline Navarro
@since 10/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function DePara(cTab)
  Local aCampos := {}

  Default cTab := "SC9"

  If cTab == "SC9"
    aCampos := {;
      {"order"	      , "SC5.C5_NUM"     },;
      {"item"         , "SC9.C9_ITEM"    },;
      {"sequen"       , "SC9.C9_SEQUEN"  },;
      {"client"       , "SA1.A1_COD"     },;
      {"store"        , "SA1.A1_LOJA"    },;
      {"name"         , "SA1.A1_NREDUZ"  },;
      {"product"      , "SC9.C9_PRODUTO" },;
      {"prodname"     , "SB1.B1_DESC"    },;
      {"prodgroup"    , "SB1.B1_GRUPO"   },;
      {"saleprice"    , "SC9.C9_PRCVEN"  },;
      {"sale"	        , "SC9.C9_QTDLIB"  },;
      {"amount"	      , "TOTALSC9"       },;
      {"lot"	        , "SC9.C9_LOTECTL" },;
      {"sublot"	      , "SC9.C9_NUMLOTE" },;
      {"deliverydate" , "SC6.C6_ENTREG"  },;
      {"emission"     , "SC5.C5_EMISSAO" },;
      {"paymentterms" , "SC5.C5_CONDPAG" },;
      {"amountsc6"    , "TOTALSC6"       },;
      {"cfop"         , "SC6.C6_CF"      },;
      {"serialnum"    , "SC9.C9_NUMSERI" };
    }
  ElseIf cTab == "SC5"
    aCampos := {;
      {"order"	      , "SC5.C5_NUM"     },;
      {"client"       , "SA1.A1_COD"     },;
      {"store"        , "SA1.A1_LOJA"    },;
      {"name"         , "SA1.A1_NREDUZ"  },;
      {"product"      , "SC6.C6_PRODUTO" },;
      {"prodname"     , "SB1.B1_DESC"    },;
      {"prodgroup"    , "SB1.B1_GRUPO"   },;
      {"deliverydate" , "SC6.C6_ENTREG"  },;
      {"emission"     , "SC5.C5_EMISSAO" },;
      {"paymentterms" , "SC5.C5_CONDPAG" },;
      {"paymentdesc"  , "SE4.E4_DESCRI"  },;
      {"pricelistdesc", "DA0.DA0_DESCRI" },;
      {"amountsc6"    , "TOTALSC6"       },;
      {"cfop"         , "SC6.C6_CF"      };
    }
  ElseIf cTab == "SC9CLI"
    aCampos := {;
      {"order"	      , "SC5.C5_NUM"     },;
      {"item"         , "SC9.C9_ITEM"    },;
      {"sequen"       , "SC9.C9_SEQUEN"  },;
      {"client"       , "SA1.A1_COD"     },;
      {"store"        , "SA1.A1_LOJA"    },;
      {"name"         , "SA1.A1_NREDUZ"  },;
      {"product"      , "SC9.C9_PRODUTO" },;
      {"prodname"     , "SB1.B1_DESC"    },;
      {"prodgroup"    , "SB1.B1_GRUPO"   },;
      {"saleprice"    , "SC9.C9_PRCVEN"  },;
      {"sale"	        , "SC9.C9_QTDLIB"  },;
      {"amount"	      , "TOTALSC9"       },;
      {"lot"	        , "SC9.C9_LOTECTL" },;
      {"sublot"	      , "SC9.C9_NUMLOTE" },;
      {"deliverydate" , "SC6.C6_ENTREG"  },;
      {"emission"     , "SC5.C5_EMISSAO" },;
      {"paymentterms" , "SC5.C5_CONDPAG" },;
      {"amountsc6"    , "TOTALSC6"       },;
      {"cfop"         , "SC6.C6_CF"      },;
      {"serialnum"    , "SC9.C9_NUMSERI" };
    }
  EndIf

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} RetHeader
Retorna o aHeader

@author Aline Navarro
@since 03/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function RetHeader(cTab)
  Local aHeader := {}
  Local cMoeda := SuperGetMV("MV_SIMB1",.F.,"BRL") 

  Default cTab := "SC9"
  
  If cTab == "SC9"
    aHeader := {;
      {"order"        , STR0020 ,"link"    ,,.T.,.T.         },;   // #"Pedido"
      {"item"	        , STR0021 ,          ,,.T.,.T.         },;   // #"Item"
      {"sequen"	      , STR0022                              },;   // #"Sequência"
      {"client"	      , STR0010 ,          ,,.T.,.T.         },;   // #"Cliente"
      {"store"        , STR0011 ,          ,,.T.,.T.         },;   // #"Loja"
      {"name"         , STR0023                              },;   // #"Nome Cliente"
      {"product"	    , STR0008 ,          ,,.T.,.T.         },;   // #"Produto"
      {"prodname"     , STR0024                              },;   // #"Descrição do Produto"
      {"saleprice"	  , STR0025 , "currency", cMoeda         },;   // #"Preço de Venda"
      {"sale"	        , STR0026 , "number"  ,"1.2-5"         },;   // #"Quantidade"
      {"amount"	      , STR0027 , "currency",cMoeda          },;   // #"Total"
      {"lot"	        , STR0028 ,           ,,,.F.           },;   // #"Lote"
      {"sublot"	      , STR0029 ,           ,,,.F.           },;   // #"Sub-Lote"
      {"serialnum"	  , STR0030 ,           ,,,.F.           };    // #"Número de Série"
    }
  ElseIf cTab == "SC5"
    aHeader := {;
      {"order"        , STR0020                              },;    // #"Pedido"
      {"client"	      , STR0010, "link"                      },;    // #"Cliente"
      {"store"        , STR0011                              },;    // #"Loja"
      {"name"         , STR0023                              },;    // #"Nome Cliente"
      {"paymentdesc"  , STR0014                              },;    // #"Condição de Pagamento"
      {"pricelistdesc", STR0031                              },;    // #"Tabela de Preço"
      {"amountsc6"    , STR0032, "currency", cMoeda          };     // #"Total do Pedido"
    }
  ElseIf cTab == "SC9CLI"
    aHeader := {;
      {"order"        , STR0020, , , .T., .T.                },;    // #"Pedido"
      {"item"	        , STR0021, , , .T., .T.                },;    // #"Item"
      {"sequen"	      , STR0022                              },;    // #"Sequência"
      {"client"	      , STR0010, , , .T., .T.                },;    // #"Cliente"
      {"store"        , STR0011, , , .T., .T.                },;    // #"Loja"
      {"name"         , STR0023                              },;    // #"Nome Cliente"
      {"product"	    , STR0008, , , .T., .T.                },;    // #"Produto"
      {"prodname"     , STR0024                              },;    // #"Descrição do Produto"
      {"saleprice"	  , STR0025, "currency", cMoeda          },;    // #"Preço de Venda"
      {"sale"	        , STR0026, "number",   "1.2-5"         },;    // #"Quantidade"
      {"amount"	      , STR0027, "currency", cMoeda          },;    // #"Total"
      {"lot"	        , STR0028, , , , .F.                   },;    // #"Lote"
      {"sublot"	      , STR0029, , , , .F.                   },;    // #"Sub-Lote"
      {"serialnum"	  , STR0030, , , , .F.                   };     // #"Número de Série"
    }
  EndIf

Return aHeader

