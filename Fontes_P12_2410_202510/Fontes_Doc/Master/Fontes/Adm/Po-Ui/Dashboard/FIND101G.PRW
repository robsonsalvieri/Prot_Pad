#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FIND101G.CH"

Static _lIntTOP   := GetMv("MV_INTPMS") == 'S' .AND. !Empty(GetMv("MV_RMCOLIG")) As Logical //Variavel utilizada na integração RM X TOP

/*/{Protheus.doc} FD101GNat

API Gráfico Financeiro X Naturezas

@author		francisco.oliveira
@since		09/10/2022
/*/

WSRESTFUL FD101GNat DESCRIPTION STR0001 //"Gráfico Financeiro X Naturezas"
  WSDATA JsonFilter       As Character	  OPTIONAL
  WSDATA drillDownFilter  As Character	  OPTIONAL
	WSDATA Fields			      As Character	  OPTIONAL
	WSDATA Order			      As Character	  OPTIONAL
	WSDATA Page				      AS INTEGER	OPTIONAL
	WSDATA PageSize		      AS INTEGER	OPTIONAL

  WSMETHOD GET form ;
  DESCRIPTION STR0002 ; //"Carrega os campos que serão apresentados no formulário"
  WSSYNTAX "/charts/form/" ;
  PATH "/charts/form";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST fd101GDado ;
  DESCRIPTION "" ;
  WSSYNTAX "/charts/fd101GDado/{JsonFilter}" ;
  PATH "/charts/fd101GDado";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST itemsDetails ;
  DESCRIPTION STR0003 ; //"Carrega os Itens Utilizados para Montagem da Grid"
  WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
  PATH "/charts/itemsDetails";
  PRODUCES APPLICATION_JSON
ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST fd101GDado
Retorna os dados do Gráfico

@author		francisco.oliveira
@since		09/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

WSMETHOD POST fd101GDado WSRECEIVE JsonFilter WSSERVICE FD101GNat

  Local oResponse := JsonObject():New()
  Local oCoreDash := CoreDash():New()
  Local oJson     := JsonObject():New()
  Local lRet      := .T.
  Local nMoeda    := 0
  Local cMsg      := ""
  Local cMsgErro  := ""

  preExec()

  oJson:FromJson(DecodeUtf8(Self:GetContent()))

  nMoeda  := RecMoeda(Date(), SubStr(oJson['moedas'], 1, 2), .T.)

  If nMoeda > 0
    fd101GDado(@oResponse, oCoreDash, oJson, @cMsgErro)
    If Empty(cMsgErro)
      Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
    Else
      cMsg := STR0004 + cMsgErro // "Período da pesquisa invalido "
      SetRestFault(400, EncodeUtf8(cMsg))
      lRet := .F.
    Endif
  Else
    cMsg := STR0005 + Alltrim(oJson['moedas']) + STR0006 + dtoc(Date()) // "Cadastre a cotação da moeda " # " para o dia "
    SetRestFault(400, EncodeUtf8(cMsg))
    lRet := .F.
  Endif

  oResponse := Nil
  FreeObj( oResponse )

  oCoreDash:Destroy()
  FreeObj( oCoreDash )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET form
Retorna os campos que serão apresentados no formulário.
O padrão do campo deve seguir o Dynamic Form do Portinari.

@author		francisco.oliveira
@since		09/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

WSMETHOD GET form WSSERVICE FD101GNat

    Local oResponse := JsonObject():New()
    Local oCoreDash := CoreDash():New()
  
    preExec()

    oCoreDash:SetPOForm(STR0007, "charttype" , 6, STR0007, .T., "string" , oCoreDash:SetPOCombo({{"bar",STR0008}})) //"Tipo de Gráfico" # "Tipo de Gráfico" # "Barra"
    oCoreDash:SetPOForm(STR0009, "dateIni"   , 6, STR0010, .T., 'date'   ,             , .T.) //"Filtros" # "Data Inicial"
    oCoreDash:SetPOForm(""     , "dateFim"   , 6, STR0011, .T., 'date'   ,             , .T.) //"Data Final" 
    oCoreDash:SetPOForm(""     , "natureza"  , 6, STR0012, .T.,          , FD101GSED() , .T.) //"Naturezas"
    oCoreDash:SetPOForm(""     , "considFil" , 6, STR0013, .T.,          , FD101GFil() , .T.) //"Considera Filiais" # "Sim" # "Não"
    oCoreDash:SetPOForm(""     , "periodos"  , 6, STR0014, .T.,          , FD101GPer() , .F.) //"Mostrar Períodos Em"
    oCoreDash:SetPOForm(""     , "conBancos" , 6, STR0015, .T.,          , FD101GBco() , .T.) //"Bancos"
    oCoreDash:SetPOForm(""     , "tpSaldo"   , 6, STR0016, .T.,          , FD101GSal() , .F.) //"Tipo de Saldo"
    oCoreDash:SetPOForm(""     , "moedas"    , 6, STR0017, .T.,          , FD100GMoed(), .F.) //"Qual Moeda"

    If _lIntTOP
      oCoreDash:SetPOForm(""     , "ccusto"  , 6,  STR0051, .T.,          , FD101CCust() , .T.) // "Centro de Custos"
    Endif

    oCoreDash:SetPOForm(""     , "diversos"  , 6, STR0018, .F.,          , FD101GDive(), .T.) //"Diversos"

    oResponse  := oCoreDash:GetPOForm()

    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST itemsDetails
MÃ©todo para retornar os dados do Painel

@author		francisco.oliveira
@since		09/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL FD101GNat

  Local aHeader     AS Array
  Local aItems      AS Array
  Local aRet        AS Array
  Local aFilter     AS Array
  Local aCab        As Array
  Local aItemsAux   As Array
  Local aGrvTtl     As Array
  Local aGrvSldIn   As Array
  Local cBody       As Character
  Local cError		  As Character
  Local cDataIni    As Character
  Local cDataFim    As Character
  Local cAliasQry   As Character
  Local cMoeda      As Character
  Local cPeriodo    As Character
	Local lRet			  AS Logical
  Local oCoreDash   AS Object
  Local oBody       AS Object
  Local oJsonFilter AS Object
  Local oJsonDD     AS Object
  Local nY          As Numeric
  Local nAux        As Numeric
  Local dDataIni    As Date
  Local dDataFim    As Date
  Local dDataAux    As Date
  Local oDates      As Json
  
  preExec()
  
  aHeader     := {}
  aItems      := {}
  aRet        := {}
  aFilter     := {}
  aCab        := {}
  aItemsAux   := {}
  aGrvTtl     := {}
  aGrvSldIn   := {}
  cBody       := DecodeUtf8(Self:GetContent())
  cError		  := STR0019 //"Erro na Requisição"
  cMoeda      := ""
  cPeriodo    := ""
	lRet			  := .T.
  nY          := 0
  nAux        := 0
  oCoreDash   := CoreDash():New()
  oBody       := JsonObject():New()
  oJsonFilter := JsonObject():New()
  oJsonDD     := JsonObject():New()
  oDates      := JsonObject():New()

  If !Empty(cBody)
    oBody:FromJson(cBody)
    If ValType(oBody["chartFilter"]) == "J"
      oJsonFilter := oBody["chartFilter"]
    EndIf
    If ValType(oBody["detailFilter"]) == "A"
      oJsonDD := oBody["detailFilter"]
    EndIf
  EndIf

  cMoeda    := SubStr(oJsonFilter['moedas'], 1, 2)

  cPeriodo  := SubStr(oJsonFilter['periodos'], 1, 1)

  dDataIni  := StoD(StrTran(oJsonFilter['dateIni'],"-",""))
  dDataFim  := StoD(StrTran(oJsonFilter['dateFim'],"-",""))

  cDataIni    := StrTran(oJsonFilter['dateIni'],"-","")
  cDataFim    := StrTran(oJsonFilter['dateFim'],"-","")

  If cPeriodo == '1' // Por Dia
    nAux      := DateDiffDay(dDataIni, dDataFim)
    dDataAux  := dDataIni
    For nY := 1 To nAux + 1
      Aadd(aCab, {Day2Str(dDataAux) + "/" + Month2Str(dDataAux) + "/" + Year2Str(dDataAux)})
      dDataAux++
    Next nY
  ElseIf cPeriodo == '2' // Por Semana
    nAux      := DateDiffDay(dDataIni, dDataFim) / 7
    dDataAux  := dDataIni
    For nY := 1 To nAux + 1
      Aadd(aCab, {FD101GSem(dDataAux, dDataIni, dDataFim )})
      dDataAux := dDataAux + 7
    Next nY
  ElseIf cPeriodo == '3' // Por Mes
    nAux      := DateDiffMonth(dDataIni, dDataFim)
    dDataAux  := dDataIni
    For nY := 1 To nAux + 1
      Aadd(aCab, {Month2Str(dDataAux) + "/" + Year2Str(dDataAux)})
      dDataAux  := MonthSum(dDataAux, 1)
    Next nY
  ElseIf cPeriodo == '4' // Por Ano
    nAux      := DateDiffYear(dDataIni, dDataFim)
    dDataAux  := dDataIni
    For nY := 1 To nAux + 1
      Aadd(aCab, {Year2Str(dDataAux)})
      dDataAux  := YearSum(dDataAux, 1)
    Next nY
  Endif

  Self:SetContentType("application/json")

  If oJsonFilter:GetJsonText("level") == "null" .Or. Len(oJsonFilter["level"]) == 0
    if Len(oJsonDD) == 0
      aHeader   := FD101LHedN(cMoeda, aCab, cPeriodo)
      aItems    := FD101LIteN(aCab, cPeriodo, @aItemsAux, @aGrvTtl, cDataIni, cDataFim, @aGrvSldIn)
      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter  := oCoreDash:GetApiFilter()
      cAliasQry := FD101LSNat(oJsonFilter, cDataIni, cDataFim, cPeriodo, aItems, aItemsAux, aGrvTtl, aGrvSldIn)
    ElseIf Len(oJsonDD) == 1
      aHeader   := FD101LHedD(cMoeda)
      aItems    := FD101LIteD()
      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter   := oCoreDash:GetApiFilter()
      cAliasQry := FD101LQryD(oJsonDD[1]['natureza'], cDataIni, cDataFim, cMoeda)
    EndIf
  ElseIf Len(oJsonFilter["level"]) == 1
    nAux  := 0
    If Len(oJsonDD) == 0
      If cPeriodo == "1"
        cDataIni  := DtoS(CtoD(oJsonFilter['level'][1]['label'][1]))
        cDataFim  := DtoS(CtoD(oJsonFilter['level'][1]['label'][1]))
      ElseIf cPeriodo == "2"
        oDates := FD101Dates(cPeriodo, oJsonFilter['level'][1]['label'][1])
        cDataIni  := oDates['sqlStartDate']
        cDataFim  := oDates['sqlEndDate']
      ElseIf cPeriodo == "3"
        If !SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataFim))
          cDataIni  := DtoS(Firstday(StoD(cDataFim)))
        ElseIf !SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. !SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataFim))
          cDataIni  := DtoS(CtoD("01/" + oJsonFilter['level'][1]['label'][1]))
          cDataFim  := DtoS(CtoD(cValToChar(Last_Day(CtoD("01/" + oJsonFilter['level'][1]['label'][1]))) + "/" + oJsonFilter['level'][1]['label'][1]))
        ElseIf SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. !SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataFim))
          cDataFim  := DtoS(CtoD(cValToChar(Last_Day(CtoD("01/" + oJsonFilter['level'][1]['label'][1]))) + "/" + oJsonFilter['level'][1]['label'][1]))
        Endif 
      ElseIf cPeriodo == "4"
        If !oJsonFilter['level'][1]['label'][1] $ cDataIni .And. oJsonFilter['level'][1]['label'][1] $ cDataFim
          cDataIni  := oJsonFilter['level'][1]['label'][1] + "0101"
        ElseIf !oJsonFilter['level'][1]['label'][1] $ cDataIni .And. !oJsonFilter['level'][1]['label'][1] $ cDataFim
          cDataIni  := oJsonFilter['level'][1]['label'][1] + "0101"
          cDataFim  := oJsonFilter['level'][1]['label'][1] + "1231"
        ElseIf oJsonFilter['level'][1]['label'][1] $ cDataIni .And. !oJsonFilter['level'][1]['label'][1] $ cDataFim
          cDataFim  := oJsonFilter['level'][1]['label'][1] + "1231"
        Endif 
      Endif

      nAux  := aScan(aCab, {|x| x[1] == oJsonFilter['level'][1]['label'][1] })
      aHeader   := FD101LHedN(cMoeda, {aCab[nAux]}, cPeriodo)
      aItems    := FD101LIteN({aCab[nAux]}, cPeriodo, @aItemsAux, @aGrvTtl, cDataIni, cDataFim, @aGrvSldIn)
      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter   := oCoreDash:GetApiFilter()
      cAliasQry := FD101LSNat(oJsonFilter, cDataIni, cDataFim, cPeriodo, aItems, aItemsAux, aGrvTtl, aGrvSldIn)
    ElseIf Len(oJsonDD) == 1
      If cPeriodo == "1"
        cDataIni  := DtoS(CtoD(oJsonFilter['level'][1]['label'][1]))
        cDataFim  := DtoS(CtoD(oJsonFilter['level'][1]['label'][1]))
      ElseIf cPeriodo == "2"
        oDates := FD101Dates(cPeriodo, oJsonFilter['level'][1]['label'][1])
        cDataIni  := oDates['sqlStartDate']
        cDataFim  := oDates['sqlEndDate']
      ElseIf cPeriodo == "3"
        If !SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataFim))
          cDataIni  := DtoS(Firstday(StoD(cDataFim)))
        ElseIf !SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. !SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataFim))
          cDataIni  := DtoS(CtoD("01/" + oJsonFilter['level'][1]['label'][1]))
          cDataFim  := DtoS(CtoD(cValToChar(Last_Day(CtoD("01/" + oJsonFilter['level'][1]['label'][1]))) + "/" + oJsonFilter['level'][1]['label'][1]))
        ElseIf SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. !SubStr(oJsonFilter['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataFim))
          cDataFim  := DtoS(CtoD(cValToChar(Last_Day(CtoD("01/" + oJsonFilter['level'][1]['label'][1]))) + "/" + oJsonFilter['level'][1]['label'][1]))
        Endif 
      ElseIf cPeriodo == "4"
        If !oJsonFilter['level'][1]['label'][1] $ cDataIni .And. oJsonFilter['level'][1]['label'][1] $ cDataFim
          cDataIni  := oJsonFilter['level'][1]['label'][1] + "0101"
        ElseIf !oJsonFilter['level'][1]['label'][1] $ cDataIni .And. !oJsonFilter['level'][1]['label'][1] $ cDataFim
          cDataIni  := oJsonFilter['level'][1]['label'][1] + "0101"
          cDataFim  := oJsonFilter['level'][1]['label'][1] + "1231"
        ElseIf oJsonFilter['level'][1]['label'][1] $ cDataIni .And. !oJsonFilter['level'][1]['label'][1] $ cDataFim
          cDataFim  := oJsonFilter['level'][1]['label'][1] + "1231"
        Endif 
      Endif

      aHeader   := FD101LHedD(cMoeda)
      aItems    := FD101LIteD()
      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter   := oCoreDash:GetApiFilter()
      cAliasQry := FD101LQryD(oJsonDD[1]['natureza'], cDataIni, cDataFim, cMoeda)
    Endif
  EndIf

  oCoreDash:SetTable(cAliasQry)
  oCoreDash:BuildJson()

	If lRet
    oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson() )
	EndIf

	oCoreDash:Destroy()
  FreeObj(aRet)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101GDado
Retorna o valor do movimento financeiro e das naturezas informadas

@author		francisco.oliveira
@since		09/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101GDado(oResponse, oCoreDash, oJson, cMsgErro)

  Local cGreenDk  As Character
  Local cGreenLht As Character
  Local cRedDk    As Character
  Local cRedLht   As Character
  Local cYellDk   As Character
  Local cYellLht  As Character
  Local cBlueDk   As Character
  Local cBlueLht  As Character
  Local cMoeda    As Character
  Local cPeriodo  As Character
  Local cCartAux  As Character
  Local cTpSalAux As Character
  Local cColorAux As Character
  Local cbaseTop  As Character
  Local cSaldTop  As Character
  Local dDataIni  AS Date
  Local dDataFim  AS Date
  Local dDataAux  AS Date
  Local aClrChart AS Array
  Local aConside  As Array
  Local aCab      AS Array
  Local aData1    As Array
  Local aData2    As Array
  Local aData3    As Array
  Local aData4    As Array
  Local aData5    As Array
  Local aData6    As Array
  Local aData7    As Array
  Local aData8    As Array
  Local nY        As Numeric
  Local nAux      As Numeric

  aClrChart := {}
  aConside  := {}
  aCab      := {}
  aData1    := {}
  aData2    := {}
  aData3    := {}
  aData4    := {}
  aData5    := {}
  aData6    := {}
  aData7    := {}
  aData8    := {}
  cMoeda    := ""
  cCartAux  := ""
  cTpSalAux := ""
  cColorAux := ""
  cbaseTop  := ""
  cSaldTop  := ""
  nY        := 0
  nAux      := 0

  dDataIni  := StoD(StrTran(oJson['dateIni'],"-",""))
  dDataFim  := StoD(StrTran(oJson['dateFim'],"-",""))

  //MOSTRA PERIODOS EM
  //"1 - Dias"
  //"2 - Semanas"
  //"3 - Meses"
  //"4 - Anos"
  cPeriodo  := SubStr(oJson['periodos'], 1, 1)

  cMsgErro  := FD101GErr(dDataIni, dDataFim, cPeriodo)

  If !Empty(cMsgErro)
    Return
  Endif

  //CONSIDERA
  //"1 - Considera Pedidos de Venda"
  //"2 - Considera Pedidos de Compra"
  //"3 - Considera Aplicações/Emprestimos"
  //"4 - Considera Saldos Bancários"
  // For nY := 1 To Len(oJson['considera'])
  //   AAdd(aConside, SubStr(oJson['considera'][nY], 1, 1))
  // Next nY

  //TIPOS DE SALDOS
  //"1 - Normais"
  //"2 - Conciliados"
  //"3 - Não Conciliados"
  
  cMoeda    := subStr(oJson['moedas'],1,2)

  aClrChart := oCoreDash:GetColorChart()

  cGreenDk  := aClrChart[1][3] //"rgba(  0,178,142, 1)"
  cGreenLht := aClrChart[2][3] //"rgba(  0,201,161, 1)"
  cRedDk    := aClrChart[3][3] //"rgba(198, 72, 64, 1)"
  cRedLht   := aClrChart[4][3] //"rgba(227, 73, 64, 1)"
  cYellDk   := aClrChart[5][3] //"rgba(252,203, 76, 1)"
  cYellLht  := aClrChart[6][3] //"rgba(255,212,100, 1)" 
  cBlueDk   := aClrChart[9][3] //"rgba(255,212,100, 1)" 
  cBlueLht  := aClrChart[10][3] //"rgba(255,212,100, 1)" 

  If _lIntTOP
    cbaseTop  := "B"
    cSaldTop  := "S"
  Endif

  If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0

    If cPeriodo == '1' // Por Dia
      nAux      := DateDiffDay(dDataIni, dDataFim)
      dDataAux  := dDataIni
      For nY := 1 To nAux + 1
        Aadd(aCab, {Day2Str(dDataAux) + "/" + Month2Str(dDataAux) + "/" + Year2Str(dDataAux)})
        dDataAux++
      Next nY
      aData1 := FD101LGrfD(oJson, "R", "2", aCab, .F., "" ) // R = Receita  # 2 = PREVISTO  # (.F. "") para a integração com RM - TOP
      aData2 := FD101LGrfD(oJson, "R", "3", aCab, .F., "" ) // R = Receita  # 3 = REALIZADO # (.F. "") para a integração com RM - TOP
      aData3 := FD101LGrfD(oJson, "P", "2", aCab, .F., "" ) // P = Despesas # 2 = PREVISTO  # (.F. "") para a integração com RM - TOP
      aData4 := FD101LGrfD(oJson, "P", "3", aCab, .F., "" ) // P = Despesas # 3 = REALIZADO # (.F. "") para a integração com RM - TOP

      If _lIntTOP
        aData7  := FD101LGrfD(oJson, , , aCab, _lIntTOP, cbaseTop ) // Linha Base
        aData8  := FD101LGrfD(oJson, , , aCab, _lIntTOP, cSaldTop ) // Saldo
      Endif
    ElseIf cPeriodo == '2' // Por Semana
      nAux      := DateDiffDay(dDataIni, dDataFim) / 7
      dDataAux  := dDataIni
      For nY := 1 To nAux + 1
        Aadd(aCab, {FD101GSem(dDataAux, dDataIni, dDataFim )})
        dDataAux := dDataAux + 7
      Next nY
      aData1 := FD101LGSMA(oJson, "R", "2", aCab, cPeriodo, .F., "" ) // R = Receita  # 2 = PREVISTO  # (.F. "") para a integração com RM - TOP
      aData2 := FD101LGSMA(oJson, "R", "3", aCab, cPeriodo, .F., "" ) // R = Receita  # 3 = REALIZADO # (.F. "") para a integração com RM - TOP
      aData3 := FD101LGSMA(oJson, "P", "2", aCab, cPeriodo, .F., "" ) // P = Despesas # 2 = PREVISTO  # (.F. "") para a integração com RM - TOP
      aData4 := FD101LGSMA(oJson, "P", "3", aCab, cPeriodo, .F., "" ) // P = Despesas # 3 = REALIZADO # (.F. "") para a integração com RM - TOP

      If _lIntTOP
        aData7 := FD101LGSMA(oJson, , , aCab, cPeriodo, _lIntTOP, cbaseTop )  // Linha Base
        aData8 := FD101LGSMA(oJson, , , aCab, cPeriodo, _lIntTOP, cSaldTop )  // Saldo
      Endif
    ElseIf cPeriodo == '3' // Por Mes
      nAux      := DateDiffMonth(dDataIni, dDataFim)
      dDataAux  := dDataIni
      For nY := 1 To nAux + 1
        Aadd(aCab, {Month2Str(dDataAux) + "/" + Year2Str(dDataAux)})
        dDataAux  := MonthSum(dDataAux, 1)
      Next nY
    ElseIf cPeriodo == '4' // Por Ano
      nAux      := DateDiffYear(dDataIni, dDataFim)
      dDataAux  := dDataIni
      For nY := 1 To nAux + 1
        Aadd(aCab, {Year2Str(dDataAux)})
        dDataAux  := YearSum(dDataAux, 1)
      Next nY
    Endif

    If cPeriodo == "3" .Or. cPeriodo == "4"
      aData1 := FD101LGSMA(oJson, "R", "2", aCab, cPeriodo, .F., "" ) // R = Receita  # 2 = PREVISTO  # (.F. "") para a integração com RM - TOP
      aData2 := FD101LGSMA(oJson, "R", "3", aCab, cPeriodo, .F., "" ) // R = Receita  # 3 = REALIZADO # (.F. "") para a integração com RM - TOP
      aData3 := FD101LGSMA(oJson, "P", "2", aCab, cPeriodo, .F., "" ) // P = Despesas # 2 = PREVISTO  # (.F. "") para a integração com RM - TOP
      aData4 := FD101LGSMA(oJson, "P", "3", aCab, cPeriodo, .F., "" ) // P = Despesas # 3 = REALIZADO # (.F. "") para a integração com RM - TOP
      aData5 := FD101LGSMA(oJson, "R", "1", aCab, cPeriodo, .F., "" ) // R = Receita  # 1 = ORÇADO    # (.F. "") para a integração com RM - TOP
      aData6 := FD101LGSMA(oJson, "P", "1", aCab, cPeriodo, .F., "" ) // P = Despesas # 1 = ORÇADO    # (.F. "") para a integração com RM - TOP

      If _lIntTOP
        aData7 := FD101LGSMA(oJson, , , aCab, cPeriodo, _lIntTOP, cbaseTop )  // Linha Base
        aData8 := FD101LGSMA(oJson, , , aCab, cPeriodo, _lIntTOP, cSaldTop )  // Saldo
      Endif
    Endif
  ElseIf Len(oJson["level"]) == 1
    aCab := { oJson["level"][1]['label'][1]}
    If cPeriodo == '1' .Or. cPeriodo == '2'  // Por Dia OU // Por Semana
      aData1 := FD101LGNUM(oJson, "R", "2", aCab, cPeriodo, .F., "" ) // R = Receita  # 2 = PREVISTO  # (.F. "") para a integração com RM - TOP
      aData2 := FD101LGNUM(oJson, "R", "3", aCab, cPeriodo, .F., "" ) // R = Receita  # 3 = REALIZADO # (.F. "") para a integração com RM - TOP
      aData3 := FD101LGNUM(oJson, "P", "2", aCab, cPeriodo, .F., "" ) // P = Despesas # 2 = PREVISTO  # (.F. "") para a integração com RM - TOP
      aData4 := FD101LGNUM(oJson, "P", "3", aCab, cPeriodo, .F., "" ) // P = Despesas # 3 = REALIZADO # (.F. "") para a integração com RM - TOP

      If _lIntTOP
        aData7 := FD101LGNUM(oJson, , , aCab, cPeriodo, _lIntTOP, cbaseTop  )  // Linha Base
        aData8 := FD101LGNUM(oJson, , , aCab, cPeriodo, _lIntTOP, cSaldTop  )  // Saldo
      Endif
    ElseIf cPeriodo == '3' .Or. cPeriodo == '4' // Por Mes OU // Por Ano
      aData1 := FD101LGNUM(oJson, "R", "2", aCab, cPeriodo, .F., "" ) // R = Receita  # 2 = PREVISTO  # (.F. "") para a integração com RM - TOP
      aData2 := FD101LGNUM(oJson, "R", "3", aCab, cPeriodo, .F., "" ) // R = Receita  # 3 = REALIZADO # (.F. "") para a integração com RM - TOP
      aData3 := FD101LGNUM(oJson, "P", "2", aCab, cPeriodo, .F., "" ) // P = Despesas # 2 = PREVISTO  # (.F. "") para a integração com RM - TOP
      aData4 := FD101LGNUM(oJson, "P", "3", aCab, cPeriodo, .F., "" ) // P = Despesas # 3 = REALIZADO # (.F. "") para a integração com RM - TOP
      aData5 := FD101LGNUM(oJson, "R", "1", aCab, cPeriodo, .F., "" ) // R = Receita  # 1 = ORÇADO    # (.F. "") para a integração com RM - TOP
      aData6 := FD101LGNUM(oJson, "P", "1", aCab, cPeriodo, .F., "" ) // P = Despesas # 1 = ORÇADO    # (.F. "") para a integração com RM - TOP

      If _lIntTOP
        aData7 := FD101LGNUM(oJson, , , aCab, cPeriodo, _lIntTOP, cbaseTop  )  // Linha Base
        aData8 := FD101LGNUM(oJson, , , aCab, cPeriodo, _lIntTOP, cSaldTop  )  // Saldo
      Endif
    Endif
  Endif

  If (cPeriodo == '1' .Or. cPeriodo == '2') .And. (oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0 .Or. Len(oJson["level"]) == 1)
    oCoreDash:SetChartInfo( aData1, STR0020, , cGreenDk ,, .T. ) // "Previsto Receita"
    oCoreDash:SetChartInfo( aData2, STR0021, , cGreenLht,, .T. ) // "Realizado Receita"
    oCoreDash:SetChartInfo( aData3, STR0022, , cRedDk   ,, .T. ) // "Previsto Despesa"
    oCoreDash:SetChartInfo( aData4, STR0023, , cRedLht  ,, .T. ) // "Realizado Despesa"

    If _lIntTOP
      oCoreDash:SetChartInfo( aData7, STR0049, , cBlueDk  ,, .T. ) // "Projeto - Linha Base "
      oCoreDash:SetChartInfo( aData8, STR0050, , cBlueLht ,, .T. ) // "Projeto - Saldo "
    Endif
  ElseIf (cPeriodo == '3' .Or. cPeriodo == '4') .And. (oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0 .Or. Len(oJson["level"]) == 1)
    oCoreDash:SetChartInfo( aData1, STR0020, , cGreenDk ,, .T. ) // "Previsto Receita"
    oCoreDash:SetChartInfo( aData2, STR0021, , cGreenLht,, .T. ) // "Realizado Receita"
    oCoreDash:SetChartInfo( aData3, STR0022, , cRedDk   ,, .T. ) // "Previsto Despesa"
    oCoreDash:SetChartInfo( aData4, STR0023, , cRedLht  ,, .T. ) // "Realizado Despesa"
    oCoreDash:SetChartInfo( aData5, STR0024, , cYellDk  ,, .T. ) // "Orçado Receita"
    oCoreDash:SetChartInfo( aData6, STR0025, , cYellLht ,, .T. ) // "Orçado Despesa"

    If _lIntTOP
      oCoreDash:SetChartInfo( aData7, STR0049, , cBlueDk  ,, .T. ) // "Projeto - Linha Base "
      oCoreDash:SetChartInfo( aData8, STR0050, , cBlueLht ,, .T. ) // "Projeto - Saldo "
    Endif
  Endif

  aDataFim := {}

  aAdd(aDataFim, oCoreDash:SetChart(aCab,,.T., , , ))
  oResponse["items"] := aDataFim

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101GPer
Retorna os peridos possiveis para filtragem.

@author		francisco.oliveira
@since		09/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101GPer() AS Array

  Local aPeriodos AS Array

  aPeriodos := {}

  AAdd(aPeriodos, "1 - " + STR0026 + " ") // "Dias"
  AAdd(aPeriodos, "2 - " + STR0027 + " ") // "Semanas"
  AAdd(aPeriodos, "3 - " + STR0028 + " ") // "Meses"
  AAdd(aPeriodos, "4 - " + STR0029 + " ") // "Anos"

Return aPeriodos

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101GCon
Retorna o tipo de saldo do movimento

@author		francisco.oliveira
@since		09/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

// Static Function FD101GCon() AS Array

//   Local aConsidera AS Array

//   aConsidera := {}

  // AAdd(aConsidera, "1 - " + STR0030 + " " ) //"1 - "Considera Pedidos de Venda"
  // AAdd(aConsidera, "2 - " + STR0031 + " " ) //"2 - "Considera Pedidos de Compra"
  // AAdd(aConsidera, "3 - " + STR0032 + " " ) //"3 - "Considera Aplicações/Empréstimos"
  //AAdd(aConsidera, "4 - " + STR0033 + " " ) //"4 - "Considera Saldos Bancários"

// Return aConsidera

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101GSal
Retorna o tipo de saldo do movimento

@author		francisco.oliveira
@since		09/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101GSal() AS Array

  Local aTpSaldo AS Array

  aTpSaldo := {}

  AAdd(aTpSaldo, "" ) 
  AAdd(aTpSaldo, "1 - " + STR0034 + " " ) //"1 - "Normais"
  AAdd(aTpSaldo, "2 - " + STR0035 + " " ) //"2 - "Conciliados"
  AAdd(aTpSaldo, "3 - " + STR0036 + " " ) //"3 - "Não Conciliados"

Return aTpSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101GSED
Retorna as Naturezas cadastradas

@author		francisco.oliveira
@since		09/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101GSED() AS Array

  Local aNaturez AS Array
  Local cQuery   As Character
  Local cTemp    As Character

  aNaturez := {}
  cQuery   := ""
  cTemp    := GetNextAlias()

  cQuery := " SELECT DISTINCT SED.ED_CODIGO "
  cQuery += " FROM " + RetSqlName("SED") + " SED " 
  cQuery += " WHERE "
  cQuery += " D_E_L_E_T_ = '' "
  cQuery += " AND SED.ED_FILIAL = '" + xFilial("SED") + "' "

  If SED->(FieldPos( "ED_MSBLQL")) > 0
    cQuery  += " AND SED.ED_MSBLQL != '1' "
  EndIf

  cQuery += " ORDER BY ED_CODIGO

  cQuery	:= ChangeQuery(cQuery)

  MPSysOpenQuery( cQuery, cTemp )

  (cTemp)->(DbGoTop())

  AAdd(aNaturez, STR0048) // "Todas"

  While (cTemp)->(!Eof())
    AAdd(aNaturez, Alltrim((cTemp)->ED_CODIGO))
    (cTemp) ->(dbSkip())
  EndDo

  (cTemp)->(DBCloseArea())

Return aNaturez

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101GErr
Retorna a mensagem de erro da validação do Perido X Datas

@author		francisco.oliveira
@since		22/09/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101GErr(dDataIni As Date, dDataFim As Date, cPeriodo As Character) As Character

  Local cMsgErro  := ""

  //"1 - Dias"
  //"2 - Semanas"
  //"3 - Meses"
  //"4 - Anos"

  If cPeriodo == '1'
    If (dDataFim - dDataIni) > 31
      cMsgErro  := STR0037 // "O período máximo para consulta é de um mes, quando deseja visualizar em dias"
    Endif
  ElseIf cPeriodo == '2'
    If (dDataFim - dDataIni) > (365/2)
			cMsgErro  := STR0038 // "O período máximo para consulta é de seis meses, quando deseja visualizar em semanas"
		Endif
  ElseIf cPeriodo == '3'
    If (dDataFim - dDataIni) > 365
      cMsgErro  := STR0039 // "O período máximo para consulta é de um ano, quando deseja visualizar em meses"
		Endif
  Else
    If (dDataFim - dDataIni) > (365*3)
      cMsgErro  := STR0040 // "Período máximo para consulta é de três anos."
    Endif
  Endif

Return cMsgErro

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101GSem
Retorna a mensagem de erro da validação do Perido X Datas

FD101GSem(dData, dDtIni, dDtFin)
dData  -> Data a ser considerada
dDtFin -> Data inicial do periodo (data minima)
dDtFin -> Data final do periodo (data maxima) 

@author		francisco.oliveira
@since		22/09/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101GSem(dDataAux, dDtIni, dDtFin)

  Local cSemana As Character
  Local nSemana As Numeric
  Local nInicio As Numeric
  Local nFim    As Numeric 
  Local nAux    As Numeric

  cSemana := ""
  nSemana := 0
  nInicio := 0
  nFim    := 0
  nAux    := 0
  
  nDias := Day(dDataAux) + (Dow(Firstday(dDataAux)-1))

  If (nDias % 7) > 0
    nAux  := 1
  Endif

  nSemana := NoRound( nDias / 7, 0) + nAux
  
  nInicio := Dow(dDataAux)
  nFim := (7-Dow(dDataAux))

  cSemana := DtoC(Max(dDtIni, dDataAux - nInicio + 1)) + " a " + DtoC(Min(dDtFin, dDataAux + nFim)) //" a "

Return cSemana 

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101GFil
Retorna as filiais disponiveis no sistema para montar o combo de opcoes
O padrao do campo deve seguir o Dynamic Form do PO UI.

@author Francisco Oliveira
@since 22/09/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101GFil()

  Local nSMO      As Numeric
  Local aSM0      As Array
  Local aFil      As Array

  aFil      := {}
  nSMO      := 0
  aSM0      := FWLoadSM0(.T.,,.T.)

  For nSMO := 1 to Len(aSM0)
    If nSMO == 1
      aAdd(aFil, "1 - " + STR0041 + " ") // "Todas Filiais"
    Endif

    If aSM0[nSMO][1] == cEmpAnt
      aAdd(aFil, aSM0[nSMO][2])
    Endif
  Next

Return aFil

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101GDive
Retorna as opções diversos

"Apenas movimentações bancárias"
"Considera Comissão de Venda"
"Considera Títulos a Receber"
"Considera Titulos a Pagar"  

@author Francisco Oliveira
@since 22/09/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101GDive() As Array

  Local aRetDiv As Array

  aRetDiv := {}

  AAdd(aRetDiv, "1 - " + STR0043 + " " ) // "Considera Comissão de Venda"
  AAdd(aRetDiv, "2 - " + STR0044 + " " ) // "Considera Títulos a Receber"
  AAdd(aRetDiv, "3 - " + STR0045 + " " ) // "Considera Titulos a Pagar"  

Return aRetDiv

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101GBco
Retorna os Bancos listados para calculo de Saldos Iniciais.

@author Francisco Oliveira
@since 05/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101GBco()

  Local aRetBco   As Array
  Local cQuery    As Character
  Local cAliasSA6 As Character

  aRetBco   := {}
  cQuery    := ""
  cAliasSA6 := GetNextAlias()

  cQuery  := " SELECT "
  cQuery  += " SA6.A6_FILIAL, SA6.A6_COD, SA6.A6_AGENCIA, SA6.A6_NUMCON, SA6.A6_NOME "
  cQuery  += " FROM " + RetSqlName("SA6") + " SA6 " 
  cQuery  += " WHERE "
  cQuery  += " (SA6.A6_BLOCKED != '1' "
  cQuery  += " OR (SA6.A6_BLOCKED = '1' AND SA6.A6_DTBLOQ > '" + DtoS(dDataBase) + "')) "

  If SA6->(FieldPos( "A6_MSBLQL")) > 0
    cQuery  += " AND SA6.A6_MSBLQL != '1' "
  EndIf

  cQuery  += " AND SA6.D_E_L_E_T_ = ' ' "
  cQuery  += " ORDER BY A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON "
  
  cQuery	:= ChangeQuery(cQuery)

  MPSysOpenQuery( cQuery, cAliasSA6 )

  (cAliasSA6)->(DbGoTop())

  AAdd(aRetBco, "1 - " + STR0046 + " " ) // "Todos"
  AAdd(aRetBco, "2 - " + STR0047 + " " ) // "Não Considera"

  While (cAliasSA6)->(!Eof())
    AAdd(aRetBco, (cAliasSA6)->A6_FILIAL + " - " + (cAliasSA6)->A6_COD + " - " + (cAliasSA6)->A6_AGENCIA + " - " + (cAliasSA6)->A6_NUMCON + " - " + Alltrim((cAliasSA6)->A6_NOME) )
    (cAliasSA6) ->(dbSkip())
  EndDo

  (cAliasSA6)->(DBCloseArea())

Return aRetBco

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101CCust
Retorna os Centros de Custos listados para filtro na query

@author Francisco Oliveira
@since 12/12/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101CCust() As Array

  Local aRetCTT   As Array
  Local cQuery    As Character
  Local cAliasCTT As Character

  aRetCTT   := {}
  cQuery    := ""
  cAliasCTT := GetNextAlias()

  cQuery  := " SELECT "
  cQuery  += " CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01, CTT.CTT_CLASSE "
  cQuery  += " FROM " + RetSqlName("CTT") + " CTT " 
  cQuery  += " WHERE "

  cQuery  += " CTT.D_E_L_E_T_ = ' ' "
  cQuery  += " ORDER BY CTT_FILIAL, CTT_CUSTO "
  
  cQuery	:= ChangeQuery(cQuery)

  MPSysOpenQuery( cQuery, cAliasCTT )

  AAdd(aRetCTT, "1 - " + STR0046 + " " ) // "Todos"
  AAdd(aRetCTT, "2 - " + STR0047 + " " ) // "Não Considera"

  While (cAliasCTT)->(!Eof())
    AAdd(aRetCTT, Alltrim((cAliasCTT)->CTT_CUSTO) + " - " + Alltrim((cAliasCTT)->CTT_DESC01) )
    (cAliasCTT) ->(dbSkip())
  EndDo

  (cAliasCTT)->(DBCloseArea())

Return aRetCTT

//-------------------------------------------------------------------
/*/{Protheus.doc} preExec
@description Executado antes de qualquer requisição a este recurso.
Visa garantir que todas as requisições processadas neste recurso respeitem o 
mesmo padrão de exibição de data pois há várias funções que dependem disso,
e a variação do formato de data, seja pelo cadastro de usuário ou pela configuração da
chave security poderia causar um comportamento inesperado nessas funções.
@author guilherme.sordi@totvs.com.br
@since 19/07/2024
@version Protheus 12
/*/
//-------------------------------------------------------------------
static function preExec()
    SET DATE FORMAT "dd/mm/yyyy"
return
