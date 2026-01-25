#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "ESTD004.CH"

/*/{Protheus.doc} GEst01

API Grafico Lotes a Vencer

@author		Squad Entradas
@since		21/12/2020
/*/
WSRESTFUL GEst01 DESCRIPTION OemToAnsi(STR0015) //"Grafico Lotes a Vencer"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL

  WSMETHOD GET form ;
  DESCRIPTION OemToAnsi(STR0016)  ; //"Carrega os campos que serao apresentados no formulario"
  WSSYNTAX "/charts/form/" ;
  PATH "/charts/form";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST retDados ;
  DESCRIPTION "" ;
  WSSYNTAX "/charts/retDados/{JsonFilter}" ;
  PATH "/charts/retDados";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST itemsDetails ;
  DESCRIPTION "" ;
  WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
  PATH "/charts/itemsDetails";
  PRODUCES APPLICATION_JSON
ENDWSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} GET retDados
Retorna os dados do Grafico

@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST retDados WSRECEIVE JsonFilter WSSERVICE GEst01

  Local oResponse  := JsonObject():New()
  Local oCoreDash  := CoreDash():New()
  Local oJson      := JsonObject():New()

  oJson:FromJson(DecodeUtf8(Self:GetContent()))

  retDados(@oResponse, oCoreDash, oJson)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
  // Telemetria - Uso da classe FWLsPutAsyncInfo                  //
  // Mecanismo para registro de métricas e envio                  //
  // das mesmas ao License Serve da Totvs                         //
  //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
  FWLsPutAsyncInfo("LS006",RetCodUsr(),"04","ESTD004")

  oResponse := Nil
  oCoreDash:Destroy()
  FreeObj( oCoreDash )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET retDados
Retorna o valor das Meta e o Valor Vendido de acordo com parametros
informados

@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function retDados(oResponse, oCoreDash, oJson)
  Local aData     := {}
  Local aDataFim  := {}
  Local aCab      := {}
  Local aFil      := {}
  Local cPeriodo  := ""
  Local cPeriJson := ""
  Local nPerQuery := 0
  Local nLote     := 0
  Local nLote30   := 0
  Local nLote60   := 0
  Local nLote90   := 0
  Local nLote120  := 0

  If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0
    
    aFil := oJson["filial"]

    oData       := JsonObject():New()

    nLote30  := RetLotVen(30,  aFil  )
    nLote60  := RetLotVen(60,  aFil  )
    nLote90  := RetLotVen(90,  aFil  )
    nLote120 := RetLotVen(120, aFil  )

    aData   := { nLote30, nLote60, nLote90, nLote120 }

    If nLote30 == 0 .AND. nLote60 == 0 .AND. nLote90 == 0 .AND. nLote120 == 0
      aCab := { STR0001 } //"Sistema não possui Lotes a Vencer"
    Else
      aCab := { STR0002, STR0003, STR0004, STR0005 } //"30 Dias", "60 Dias", "90 Dias", "120 Dias"
    EndIf

    aDataFim := {}
    aAdd(aDataFim, oCoreDash:SetChart(aCab, aData,/*lCurrency*/))

    oResponse["items"] := aDataFim
    
  ElseIf Len(oJson["level"]) == 1

    aFil      := oJson["filial"]
    cPeriJson := oJson["level"][1]["label"]
    cPeriodo  := Alltrim(substr(cPeriJson,1,3))
    nPerQuery := VAL(cPeriodo)

    nLote     := RetLotVen( nPerQuery, aFil )

    aCab := { cPeriJson }

    oData       := JsonObject():New()

    aData   := { nLote }

    aDataFim := {}
    aAdd(aDataFim, oCoreDash:SetChart(aCab, aData,/*lCurrency*/))

    oResponse["items"] := aDataFim

  EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GET form
Retorna os campos que serao apresentados no formulario.
O padrao do campo deve seguir o Dynamic Form do PO UI.

@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET form WSSERVICE GEst01

  Local oResponse := JsonObject():New()
  Local oCoreDash  := CoreDash():New()

  oCoreDash:SetPOForm("Tipo de Gráfico", "charttype", 6, STR0006, .T., "string", oCoreDash:SetPOCombo({{"pie","Pizza"},{"polarArea","Polar"}}))
  oCoreDash:SetPOForm("Filial"         , "filial"   , 6, STR0007, .F., , GetFil(), .T.)
  
  oResponse  := oCoreDash:GetPOForm()
  
  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFil
Retorna as filiais disponiveis no sistema para montar o combo de opcoes
O padrao do campo deve seguir o Dynamic Form do PO UI.

@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function GetFil()
  Local aFil     := {}
  Local nSMO     := 0
  Local aAreaSM0 := SM0->(GetArea())
  Local aSM0     := FWLoadSM0(.T.,.T.)

  For nSMO := 1 to Len(aSM0)
    If nSMO <= Len(aSM0)
      aAdd(aFil, aSM0[nSMO][2])
    Endif
  Next

  RestArea(aAreaSM0)

Return aFil

//-------------------------------------------------------------------
/*/{Protheus.doc} GET itemsDetails
Metodo para retornar os dados do Painel

@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL GEst01

  Local aHeader     := {}
  Local aItems      := {}
  Local aRet        := {}
  Local aFilter     := {}
  Local aFil        := {}
  Local cBody       := DecodeUtf8(Self:GetContent())
  Local cError      := STR0008 //"Erro na Requisicao"
  Local cPeriodo    := ""
  Local cPeriJson   := ""
  Local nPerQuery   := 0
	Local lRet			  := .T.
  Local oCoreDash   := CoreDash():New()
  Local oBody       := JsonObject():New()
  Local oJsonFilter := JsonObject():New()
  Local oJsonDD     := JsonObject():New()

  If !Empty(cBody)
    oBody:FromJson(cBody)
    If ValType(oBody["chartFilter"]) == "J"
      oJsonFilter := oBody["chartFilter"]
    EndIf
    If ValType(oBody["detailFilter"]) == "A"
      oJsonDD := oBody["detailFilter"]
    EndIf
  EndIf

  aHeader := {;
    {"produto"   , STR0009,,,.T.,.T.                },;
    {"desc"      , STR0014,,,.T.,.F.                },;
    {"local"     , STR0010,,,.T.,.T.                },;
    {"qtd"       , STR0011,"number",'1.2-5',.T.,.T. },;
    {"lote"      , STR0012,,,.T.,.T.                },;
    {"date"      , STR0013                          };
  }

  aItems := {;
    {"produto"   , "SB8.B8_PRODUTO" },;
    {"desc"      , "SB1.B1_DESC" },;
    {"local"     , "SB8.B8_LOCAL"   },;
    {"qtd"       , "SB8.B8_SALDO"   },;
    {"lote"      , "SB8.B8_LOTECTL" },;
    {"date"      , "SB8.B8_DTVALID" };
  }

  Self:SetContentType("application/json")

  If oJsonFilter:GetJsonText("level") == "null" .Or. Len(oJsonFilter["level"]) == 0

      aFil := oJsonFilter["filial"]

      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter  := oCoreDash:GetApiFilter()

      aRet := MntQueryN1( 120, aFil, aFilter )

  ElseIf Len(oJsonFilter["level"]) == 1

    aFil      := oJsonFilter["filial"]
    cPeriJson := oJsonFilter["level"][1]["label"]
    cPeriodo  := Alltrim(substr(cPeriJson,1,3))
    nPerQuery := VAL(cPeriodo)

    oCoreDash:SetFields(aItems)
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter  := oCoreDash:GetApiFilter()

    aRet := MntQueryN1(nPerQuery, aFil, aFilter)
    
  EndIf

  oCoreDash:SetQuery(aRet[1])
  oCoreDash:BuildJson()

	If lRet
    oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson() )
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

	oCoreDash:Destroy()
  FreeObj(aRet)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQueryN1
Monta a query responsavel por trazer a lista de produtos do botao Detalhes

@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQueryN1( nPeriodo, aFil, aFilter )
  Local cQuery  := ""
  Local cWhere  := ""
  Local cSearch := ""
  Local cSelect := " SB8.B8_PRODUTO, SB1.B1_DESC, SB8.B8_LOCAL, SB8.B8_SALDO, SB8.B8_LOTECTL, SB8.B8_DTVALID "
  Local cInner  := " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB8.B8_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ' "
  Local nCont   := 0
  Local nY      := 0
  Local cFilJoinSB1   := ""
  Local nTamFilSB1    := Len(AllTrim(FWxFilial('SB1')))
  Local nTamFilSB8    := Len(AllTrim(FWxFilial('SB8')))

  Default aFil    := {}
  Default aFilter := {}

  If (nTamFilSB1 == nTamFilSB8) // filiais com mesmo compartilhamento
    cFilJoinSB1 := " AND SB8.B8_FILIAL = SB1.B1_FILIAL "
    cInner      += cFilJoinSB1
  EndIf

  cQuery := " SELECT " + cSelect + " FROM " + RetSqlName("SB8") + " SB8 " + cInner
  
  For nCont := 1 to Len(aFil)
    If nCont < Len(aFil)
        cWhere += " '" + aFil[nCont] + "', "
    else
        cWhere += " '" + aFil[nCont] + "'"
    Endif
  Next
  
  If Len(aFilter) > 0
    For nY := 1 to Len(aFilter)
        If nY < Len(aFilter)
            cSearch += aFilter[nY][1] + " AND "
        else
            cSearch += aFilter[nY][1]
        Endif
    Next
  EndIf

  If !Empty(aFil)
      cQuery += " WHERE SB8.B8_FILIAL IN (" + cWhere + ") AND  SB8.D_E_L_E_T_ = ' '  AND "
  Else
      cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND  SB8.D_E_L_E_T_ = ' '  AND "
  EndIf

  cQuery += " SB8.B8_DTVALID  BETWEEN  '" + Dtos(ddatabase) + "'  AND  '" + Dtos(ddatabase + nPeriodo) + "'  "

  If !Empty(aFilter)
    cQuery += " AND " + cSearch
  EndIf

Return {cQuery}

//-------------------------------------------------------------------
/*/{Protheus.doc} RetLotVen
Monta a query responsavel por trazer as informacoes principais do primeiro nivel do grafico

@param nPeriodo, parametro responsavel pelo numero de dias a ser consultado
@param aFil, parametro responsavel pelas as Filiais selecionadas no cadastro do Grafico
@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function RetLotVen( nPeriodo, aFil )
  Local cQuery := ""
  Local cTemp  := GetNextAlias()
  Local cWhere := ""
  Local nValor := 0
  Local nCont  := 0 

  Default aFil := {}

  For nCont := 1 to Len(aFil)
    If nCont < Len(aFil)
        cWhere += " '" + aFil[nCont] + "', "
    else
        cWhere += " '" + aFil[nCont] + "'"
    Endif
  Next

  If !Empty(aFil)
    cQuery := " SELECT COUNT(SB8.B8_PRODUTO) TOTAL  FROM " + RetSqlName("SB8") + " SB8 "
    cQuery += " WHERE  SB8.B8_FILIAL IN (" + cWhere + ") AND  SB8.D_E_L_E_T_ = ' ' AND "
    cQuery += " B8_DTVALID  BETWEEN  '" + Dtos(ddatabase) + "'  AND  '" + Dtos(ddatabase + nPeriodo) + "'  "
  Else
    cQuery := " SELECT COUNT(SB8.B8_PRODUTO) TOTAL  FROM " + RetSqlName("SB8") + " SB8 "
    cQuery += " WHERE  SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND  SB8.D_E_L_E_T_ = ' ' AND "
    cQuery += " B8_DTVALID  BETWEEN  '" + Dtos(ddatabase) + "'  AND  '" + Dtos(ddatabase + nPeriodo) + "'  "
  EndIf

  MPSysOpenQuery(cQuery,cTemp)

  While (cTemp)->(!Eof())
    nValor := (cTemp)->TOTAL
    (cTemp)->(dbSkip())
  EndDo

  (cTemp)->(dbCloseArea())

Return nValor
