#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "ESTD005.CH"

/*/{Protheus.doc} GEst02

API Grafico de Evolucao dos Estoques

@author		Squad Entradas
@since		21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSRESTFUL GEst02 DESCRIPTION OemToAnsi(STR0016) //"Grafico de Evolucao dos Estoques"
	WSDATA Fields			AS STRING	OPTIONAL
	WSDATA Order			AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL

  WSMETHOD GET form ;
  DESCRIPTION OemToAnsi(STR0017) ; //"Carrega os campos que serao apresentados no formulario" 
  WSSYNTAX "/charts/form/" ;
  PATH "/charts/form";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST retDados ;
  DESCRIPTION "" ;
  WSSYNTAX "/charts/retDados/{JsonFilter}" ;
  PATH "/charts/retDados";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST itemsDetails ;
  DESCRIPTION OemToAnsi(STR0018)  ; //"Carrega os Itens Utilizados para Montagem do itens"
  WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
  PATH "/charts/itemsDetails";
  PRODUCES APPLICATION_JSON

ENDWSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} POST retDados
Retorna os dados do Grafico

@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST retDados WSRECEIVE JsonFilter WSSERVICE GEst02

  Local oResponse   := JsonObject():New()
  Local oCoreDash  := CoreDash():New()
  Local oJson       := JsonObject():New()

  oJson:FromJson(DecodeUtf8(Self:GetContent()))

  retDados(@oResponse, oCoreDash, oJson)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
  // Telemetria - Uso da classe FWLsPutAsyncInfo                  //
  // Mecanismo para registro de métricas e envio                  //
  // das mesmas ao License Serve da Totvs                         //
  //?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
  FWLsPutAsyncInfo("LS006",RetCodUsr(),"04","ESTD005")

  oResponse := Nil
  FreeObj( oResponse )

  oCoreDash:Destroy()
  FreeObj( oCoreDash )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET retDados
Retorna periodo e valor dos ultimos 12 fechamentos e tambem realiza o calculo da linha de media
informados

@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function retDados(oResponse, oCoreDash, oJson)
  Local aDataFim  := {}
  Local aData1    := {}
  Local aCab      := {}
  Local aSaldo    := {}
  Local aData     := {}
  Local aFil      := {}
  Local cDate     := ""
  Local cPeriodo  := ""
  Local cDateJson := ""
  Local aCores    := oCoreDash:GetColorChart()
  Local nSaldo    := 0
  Local nCont1    := 0
  Local nCont3    := 0
  Local nTotal1   := 0
  Local nX        := 0

  If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0
    aFil := oJson["filial"]
    cDateJson := oJson["dateIni"]
    If !Empty(cDateJson)
      cDate := strTran(cDateJson,"-","")
    Else
      cDate := ""
    EndIf

    aData := RetData(aFil,1,,cDate)

    nTotal1 := IIF(Len(aData[1])>12,12,Len(aData[1]))
    For nCont1 := nTotal1 to 1 step - 1
      aAdd(aCab,DTOC(STOD(aData[1][nCont1])))
      aAdd(aData1,aData[2][nCont1])
    Next nCont1

    oCoreDash:SetChartInfo( aData1, STR0001,,aCores[4][3] )//"Valor"

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    // Este For calcula a linha de media do grafico                  ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For nCont3 := 1 To Len(aData1)
      nSaldo := 0

      For nX := 1 To nCont3
          nSaldo += aData1[nX]
      Next nX

      aAdd(aSaldo, (nSaldo / nCont3))

    Next nCont3

    oCoreDash:SetChartInfo( aSaldo, STR0003, 'line', aCores[10][3] )//"Media"

    aDataFim := {}
    aAdd(aDataFim, oCoreDash:SetChart(aCab,,.T., ,STR0004))//"Evolucao dos estoques por fechamento"

    oResponse["items"] := aDataFim

  ElseIf Len(oJson["level"]) == 1
    aFil := oJson["filial"]
    cPeriJson := oJson["level"][1]["label"]
    cPeriodo  := DTOS(CTOD(cPeriJson))

    aData := RetData(aFil,2,cPeriodo)

    nTotal1 := IIF(Len(aData[1])>12,12,Len(aData[1]))
    For nCont1 := 1 to nTotal1
      aAdd(aCab,DTOC(STOD(aData[1][nCont1])))
      aAdd(aData1,aData[2][nCont1])
    Next nCont1

    oCoreDash:SetChartInfo( aData1, 'Valor',,aCores[4][3] )

    aDataFim := {}
    aAdd(aDataFim, oCoreDash:SetChart(aCab,,.T., ,STR0004))

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
WSMETHOD GET form WSSERVICE GEst02

    Local oResponse := JsonObject():New()
    Local oCoreDash  := CoreDash():New()

    oCoreDash:SetPOForm("Tipo de Gráfico", "charttype" , 6 , STR0005, .T. , "string", oCoreDash:SetPOCombo({{"line","Linha"},{"bar","Barra"}}))
    oCoreDash:SetPOForm("Filtros"        , "filial"    , 6 , STR0006, .F. ,         , GetFil()  , .T.)
    oCoreDash:SetPOForm(""               , "dateIni"   , 6 , STR0007, .F. ,'date'   ,           , .T.)

    oResponse  := oCoreDash:GetPOForm()

    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFil
Retorna as filiais disponiveis no sistema para montar o combo de opcoes

@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function GetFil()
  Local aFil      := {}
  Local nSMO      := 0
  Local aAreaSM0 :=SM0->(GetArea())
  Local aSM0     := FWLoadSM0(.T.,.T.)

  For nSMO := 1 to Len(aSM0)
    If nSMO <= Len(aSM0)
      aAdd(aFil, aSM0[nSMO][2])
    Endif
  Next

  RestArea(aAreaSM0)

Return aFil

//-------------------------------------------------------------------
/*/{Protheus.doc} POST itemsDetails
Metodo para retornar os dados do Painel

@author Adriano Vieira
@since 21/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL GEst02
  Local aHeader     := {}
  Local aItems      := {}
  Local aRet        := {}
  Local aFilter     := {}
  Local cBody       := DecodeUtf8(Self:GetContent())
  Local cError      := STR0008 //"Erro na Requisicao"
  Local cDate       := ""
  Local cDateJson   := ""
	Local lRet			  := .T.
  Local oCoreDash   := CoreDash():New()
  Local oBody       := JsonObject():New()
  Local oJsonFilter := JsonObject():New()
  Local oJsonDD     := JsonObject():New()
  Local cFmtCurr1 := Iif(cPaisLoc == 'BRA', 'currency', 'number' )
  Local cFmtCurr2 := Iif(cPaisLoc == 'BRA', 'BRL', '1.2-2' )
  Local cFmtCurr3 := Iif(cPaisLoc == 'BRA', 'BRL', '1.2-5' )

  Default aFil      := ""

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
    {"produto"    , STR0009,,,.T.,.T.                 },;
    {"desc"       , STR0015,,,.T.,.F.                 },;
    {"local"      , STR0010,,,.T.,.T.                 },;
    {"data"       , STR0011                           },;
    {"qtd"	      , STR0012, "number",'1.2-5',.T.,.T. },;
    {"valor"      , STR0013, cFmtCurr1,cFmtCurr2,.T.,.T. },;
    {"cm1"        , STR0014, cFmtCurr1,cFmtCurr3         };
  }

  aItems := {;
    {"produto"	  , "SB9.B9_COD"    },;
    {"desc"	      , "SB1.B1_DESC"   },;
    {"local"      , "SB9.B9_LOCAL"  },;
    {"data"       , "SB9.B9_DATA"   },;
    {"qtd"        , "SB9.B9_QINI"   },;
    {"valor"      , "SB9.B9_VINI1"  },;
    {"cm1"        , "SB9.B9_CM1"    };
  }

  Self:SetContentType("application/json")

  If oJsonFilter:GetJsonText("level") == "null" .Or. Len(oJsonFilter["level"]) == 0

    aFil := oJsonFilter["filial"]
    cDateJson := oJsonFilter["dateIni"]
    If !Empty(cDateJson)
      cDate := strTran(cDateJson,"-","")
    Else
      cDate := ""
    EndIf

    oCoreDash:SetFields(aItems)
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter  := oCoreDash:GetApiFilter()

    aRet := MntQuery1(aFil,1,,aFilter,cDate)

  ElseIf Len(oJsonFilter["level"]) == 1

    aFil := oJsonFilter["filial"]
    cPeriJson := oJsonFilter["level"][1]["label"]
    cPeriodo  := DTOS(CTOD(cPeriJson))

    oCoreDash:SetFields(aItems)
    oCoreDash:SetApiQstring(Self:aQueryString)
    aFilter  := oCoreDash:GetApiFilter()

    aRet := MntQuery1(aFil,2,cPeriodo,aFilter)

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
/*/{Protheus.doc} MntQuery1
Monta a query responsavel por trazer os itens do botao Detalhe do Grafico

@param aFil, parametro responsavel pelas as Filiais selecionadas no cadastro do Grafico
@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQuery1(aFil,nNivel,cPeriodo,aFilter,cData)
  Local cQuery  := ""
  Local cWhere  := ""
  Local cSearch := ""
  Local cInner  := " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = SB9.B9_COD AND SB1.D_E_L_E_T_ = ' '  "
  Local cSelect := " SB9.B9_COD, SB9.B9_LOCAL, SB9.B9_DATA, SB9.B9_QINI, SB9.B9_VINI1, SB9.B9_CM1, SB1.B1_DESC "
  Local nCont   := 0
  Local nY      := 0
  Local nPeriodo:= 730
  Local cFilJoinSB1   := ""
  Local nTamFilSB1    := Len(AllTrim(FWxFilial('SB1')))
  Local nTamFilSB9    := Len(AllTrim(FWxFilial('SB9')))

  Default aFil      := {}
  Default cPeriodo  := ""
  Default aFilter   := {}

  If (nTamFilSB1 == nTamFilSB9) // filiais com mesmo compartilhamento
    cFilJoinSB1 := " AND SB1.B1_FILIAL = SB9.B9_FILIAL "
    cInner      += cFilJoinSB1
  EndIf

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

  cQuery := " SELECT " + cSelect + " FROM " + RetSqlName("SB9") + " SB9 "+ cInner"

  If nNivel == 1
    If !Empty(aFil)
      cQuery += " WHERE SB9.B9_FILIAL IN (" + cWhere + ") "
    Else
      cQuery += " WHERE SB9.B9_FILIAL = '" + xFilial("SB9") + "' "
    EndIf
    If !Empty(cData)
      cQuery += " AND  SB9.B9_DATA >= '" + cData + "' AND  SB9.D_E_L_E_T_ = ' '  "
    Else
      cQuery += " AND  SB9.B9_DATA >= '" + Dtos(ddatabase - nPeriodo) + "' AND  SB9.D_E_L_E_T_ = ' '  "
    EndIf
    If !Empty(aFilter)
      cQuery += " AND " + cSearch
    EndIf

  ElseIf nNivel == 2
    If !Empty(aFil)
      cQuery += " WHERE SB9.B9_FILIAL IN (" + cWhere + ") AND SB9.B9_DATA = '" + cPeriodo + "' AND  SB9.D_E_L_E_T_ = ' '  "
    Else
      cQuery += " WHERE SB9.B9_FILIAL = '" + xFilial("SB9") + "' AND  SB9.B9_DATA = '" + cPeriodo + "' AND SB9.D_E_L_E_T_ = ' '  "
    EndIf
    If !Empty(aFilter)
      cQuery += " AND " + cSearch
    EndIf
  EndIf

Return {cQuery}

//-------------------------------------------------------------------
/*/{Protheus.doc} RetData
Monta a query responsavel por trazer as datas e valor dos ultimos fechamentos(SB9)

@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function RetData(aFil,nNivel,cPeriodo,cData)
  Local cQuery  := ""
  Local cWhere  := ""
  Local nCont   := 0
  Local nPeriodo:= 730
  Local cTemp   := GetNextAlias()
  Local aData   := {}
  Local aValor  := {}

  Default aFil := {}
  Default cPeriodo := ""
  Default cData := ""

  For nCont := 1 to Len(aFil)
    If nCont < Len(aFil)
        cWhere += " '" + aFil[nCont] + "', "
    else
        cWhere += " '" + aFil[nCont] + "'"
    Endif
  Next

  If nNivel == 1
    If !Empty(aFil) .OR. !Empty(cData)
      cQuery := " SELECT SB9.B9_DATA periodo, SUM(SB9.B9_VINI1) valor  FROM " + RetSqlName("SB9") + " SB9 "
      If !Empty(aFil)
        cQuery += " WHERE SB9.B9_FILIAL IN (" + cWhere + ") "
      Else
        cQuery += " WHERE SB9.B9_FILIAL = '" + xFilial("SB9") + "' "
      EndIf
      If !Empty(cData)
        cQuery += " AND  SB9.B9_DATA >= '" + cData + "' AND  SB9.D_E_L_E_T_ = ' ' "
      Else
        cQuery += " AND  SB9.B9_DATA >= '" + Dtos(ddatabase - nPeriodo) + "' AND  SB9.D_E_L_E_T_ = ' ' "
      EndIf
      cQuery += " GROUP BY SB9.B9_DATA "
      cQuery += " ORDER BY SB9.B9_DATA DESC "
    Else
      cQuery := " SELECT SB9.B9_DATA periodo, SUM(SB9.B9_VINI1) valor  FROM " + RetSqlName("SB9") + " SB9 "
      cQuery += " WHERE SB9.B9_FILIAL = '" + xFilial("SB9") + "' AND  SB9.B9_DATA >= '" + Dtos(ddatabase - nPeriodo) + "' AND  SB9.D_E_L_E_T_ = ' ' "
      cQuery += " GROUP BY SB9.B9_DATA "
      cQuery += " ORDER BY SB9.B9_DATA DESC "
    EndIf
  ElseIf nNivel == 2
    If !Empty(aFil)
      cQuery := " SELECT SB9.B9_DATA periodo, SUM(SB9.B9_VINI1) valor  FROM " + RetSqlName("SB9") + " SB9 "
      cQuery += " WHERE SB9.B9_FILIAL IN (" + cWhere + ")  AND SB9.B9_DATA = '" + cPeriodo + "' AND SB9.D_E_L_E_T_ = ' '  "
      cQuery += " GROUP BY SB9.B9_DATA "
      cQuery += " ORDER BY SB9.B9_DATA DESC "
    Else
      cQuery := " SELECT SB9.B9_DATA periodo, SUM(SB9.B9_VINI1) valor  FROM " + RetSqlName("SB9") + " SB9 "
      cQuery += " WHERE SB9.B9_FILIAL = '" + xFilial("SB9") + "' AND  SB9.B9_DATA = '" + cPeriodo + "' AND  SB9.D_E_L_E_T_ = ' ' "
      cQuery += " GROUP BY SB9.B9_DATA "
      cQuery += " ORDER BY SB9.B9_DATA DESC "
    EndIf
  EndIf
  
  MPSysOpenQuery(cQuery,cTemp)

  While (cTemp)->(!Eof())
    aAdd(aData, (cTemp)->periodo)
    aAdd(aValor,(cTemp)->valor)
    (cTemp)->(dbSkip())
  EndDo

  (cTemp)->(dbCloseArea())

Return {aData,aValor}
