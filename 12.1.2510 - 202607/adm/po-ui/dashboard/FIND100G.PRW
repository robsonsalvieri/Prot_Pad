#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "FIND100G.CH"

/*/{Protheus.doc} FD100GNat

API Gráfico Financeiro X Naturezas

@author		francisco.oliveira
@since		09/11/2020
/*/

//SUBIDA PARA O D-1 EM 08/06/2021

WSRESTFUL FD100GNat DESCRIPTION STR0001 //"Gráfico Financeiro X Naturezas"
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

  WSMETHOD POST fd100GDado ;
  DESCRIPTION "" ;
  WSSYNTAX "/charts/fd100GDado/{JsonFilter}" ;
  PATH "/charts/fd100GDado";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST itemsDetails ;
  DESCRIPTION STR0003 ; //"Carrega os Itens Utilizados para Montagem da Grid"
  WSSYNTAX "/charts/itemsDetails/{JsonFilter}" ;
  PATH "/charts/itemsDetails";
  PRODUCES APPLICATION_JSON
ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST fd100GDado
Retorna os dados do Gráfico

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

WSMETHOD POST fd100GDado WSRECEIVE JsonFilter WSSERVICE FD100GNat

  Local oResponse := JsonObject():New()
  Local oCoreDash := CoreDash():New()
  Local oJson     := JsonObject():New()
  Local lRet      := .T.
  Local nMoeda    := 0
  Local cMsg      := ""

  oJson:FromJson(DecodeUtf8(Self:GetContent()))

  nMoeda  := RecMoeda(Date(), SubStr(oJson['moedas'], 1, 2), .T.)

  If nMoeda > 0
    fd100GDado(@oResponse, oCoreDash, oJson)
    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
  Else
    cMsg := STR0053 + Alltrim(oJson['moedas']) + STR0054 + dtoc(Date()) // "Cadastre a cotação da moeda " # " para o dia "
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
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

WSMETHOD GET form WSSERVICE FD100GNat

    Local oResponse := JsonObject():New()
    Local oCoreDash  := CoreDash():New()

    oCoreDash:SetPOForm(STR0013, "charttype" , 6, STR0004, .T., "string" , oCoreDash:SetPOCombo({{"line",STR0038}, {"bar",STR0039}})) //"Tipo de Gráfico" # "Tipo de Gráfico" # "Linha" # "Barra"
    oCoreDash:SetPOForm(STR0014, "dateIni"   , 6, STR0005, .T., 'date'   ,                   , .T.) //"Filtros" # "Data Inicial"
    oCoreDash:SetPOForm(""     , "dateFim"   , 6, STR0006, .T., 'date'   ,                   , .T.) //"Data Final" 
    oCoreDash:SetPOForm(""     , "moedas"    , 6, STR0007, .T.,          , FD100GMoed()      , .F.) //"Qual Moeda"
    oCoreDash:SetPOForm(""     , "tpSaldo"   , 6, STR0008, .T.,          , FD100GTpSd()      , .T.) //"Tipo de Saldo"
    oCoreDash:SetPOForm(""     , "consProv"  , 6, STR0009, .T.,          , FD100GCons()      , .F.) //"Quanto aos Títulos Provisórios"
    oCoreDash:SetPOForm(""     , "consNCCF"  , 6, STR0010, .T.,          , FD100GCons()      , .F.) //"Considera Notas Credito/Debito"
    oCoreDash:SetPOForm(""     , "consPRRA"  , 6, STR0011, .T.,          , FD100GCons()      , .F.) //"Considera Pagto/Receb. Antecipado"
    oCoreDash:SetPOForm(""     , "exibeNat"  , 6, STR0012, .T.,          , {STR0036, STR0037}, .F.) //"Exibe Natureza Sintética" # "Sim" # "Não"
    
    oResponse  := oCoreDash:GetPOForm()

    Self:SetResponse( EncodeUtf8(oResponse:ToJson()))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST itemsDetails
MÃ©todo para retornar os dados do Painel

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

WSMETHOD POST itemsDetails WSRECEIVE JsonFilter, drillDownFilter WSRESTFUL FD100GNat

  Local aHeader     AS Array
  Local aItems      AS Array
  Local aRet        AS Array
  Local aRetTipo    AS Array
  Local aFilter     AS Array
  Local cBody       As Character
  Local cError		  As Character
  Local cAno        As Character
  Local cDiaIni     As Character
  Local cMesIni     As Character
  Local cAnoIni     As Character
  Local cDataIni    As Character
  Local cDiaFim     As Character
  Local cMesFim     As Character
  Local cAnoFim     As Character
  Local cDataFim    As Character
  Local cAliasQry   As Character
  Local cExibNat    As Character
  Local cConsProv   As Character
  Local cConsRAPA   As Character
  Local cConsNDFC   As Character
  Local cMoeda      As Character
  Local cDataSet    As Character
	Local lRet			  AS Logical
  Local lDash       AS Logical
  Local oCoreDash   AS Object
  Local oBody       AS Object
  Local oJsonFilter AS Object
  Local oJsonDD     AS Object
  Local nPosPage    AS Numeric
  Local nPageSize   AS Numeric
  
  aHeader     := {}
  aItems      := {}
  aRet        := {}
  aRetTipo    := {}
  aFilter     := {}
  cBody       := DecodeUtf8(Self:GetContent())
  cError		  := STR0015 //"Erro na Requisição"
  cAno        := ""
  cDia        := ""
  cMes        := ""
  cAno        := ""
  cDataIni    := ""
  cDiaFim     := "" 
  cMesFim     := ""
  cAnoFim     := ""
  cDataFim    := ""
  cExibNat    := ""
  cConsProv   := ""
  cConsRAPA   := ""
  cConsNDFC   := ""
  cMoeda      := ""
  cDataSet    := ""
	lRet			  := .T.
  lDash       := .F.
  nPosPage    := 0
  nPageSize   := 0
  oCoreDash   := CoreDash():New()
  oBody       := JsonObject():New()
  oJsonFilter := JsonObject():New()
  oJsonDD     := JsonObject():New()

  If !Empty(cBody)
    oBody:FromJson(cBody)
    If ValType(oBody["chartFilter"]) == "J"
      oJsonFilter := oBody["chartFilter"]
    EndIf
    If ValType(oBody["detailFilter"]) == "A"
      oJsonDD := oBody["detailFilter"]
    EndIf
  EndIf

  nPosPage  := aScan(Self:aQueryString, {|x| Upper(x[1]) == "PAGE" } )

  If nPosPage > 0
    nPosPage := Self:aQueryString[nPosPage][2]
  Endif

  nPageSize := aScan(Self:aQueryString, {|x| Upper(x[1]) == "PAGESIZE" } )
  
  If nPageSize > 0
    nPageSize := Self:aQueryString[nPageSize][2]
  Endif

  cMoeda    := SubStr(oJsonFilter['moedas'], 1, 2)
  cDiaIni   := SubStr(oJsonFilter['dateIni'], 9, 2)
  cMesIni   := SubStr(oJsonFilter['dateIni'], 6, 2)
  cAnoIni   := SubStr(oJsonFilter['dateIni'], 1, 4)
  cDataIni  := cAnoIni + cMesIni + cDiaIni

  cDiaFim   := SubStr(oJsonFilter['dateFim'], 9, 2)
  cMesFim   := SubStr(oJsonFilter['dateFim'], 6, 2)
  cAnoFim   := SubStr(oJsonFilter['dateFim'], 1, 4)
  cDataFim  := cAnoFim + cMesFim + cDiaFim
  
  Self:SetContentType("application/json")

  cExibNat:= Iif(oJsonFilter['exibeNat'] = "Sim", "1", "2")

  cConsProv := subStr(oJsonFilter['consProv'],1,1) 
  cConsRAPA := subStr(oJsonFilter['consPRRA'],1,1) 
  cConsNDFC := subStr(oJsonFilter['consNCCF'],1,1) 

  aRetTipo := FD100GTipo(cConsProv, cConsRAPA, cConsNDFC )

  ctpSaldo  := FD100LTpSl(oJsonFilter['tpSaldo'])

  If oJsonFilter:GetJsonText("level") == "null" .Or. Len(oJsonFilter["level"]) == 0
    if Len(oJsonDD) == 0
      aHeader   := FD100LHeNa(cExibNat, cMoeda)
      aItems    := FD100LItNa(cExibNat)
      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter  := oCoreDash:GetApiFilter()
      cAliasQry := FD100LSNat(cDataIni, cDataFim, , cExibNat, aRetTipo, cMoeda, aFilter, ctpSaldo )
      lDash     := .T.
    ElseIf Len(oJsonDD) == 1
      aHeader   := FD100LHePR()
      aItems    := FD100LItPR(Iif(oJsonDD[1]['tpmovto'] = "Receita", "SE1", "SE2"))
      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter   := oCoreDash:GetApiFilter()
      cAliasQry := FD100LQyPR(oJsonDD[1]['tpmovto'], oJsonDD[1]['codnatur'], cDataIni, cDataFim, aFilter, nPosPage, nPageSize )
      lDash     := .T.
    EndIf
  ElseIf Len(oJsonFilter["level"]) == 1
    If Len(oJsonDD) == 0
      aHeader   := FD100LHeNa(cExibNat, cMoeda)
      aItems    := FD100LItNa(cExibNat)
      cMes      := FD100GReMe(Substr(oJsonFilter['level'][1]['label'][1],1, AT('/',oJsonFilter['level'][1]['label'][1]) - 1 ))
      cAno      := Substr(oJsonFilter['level'][1]['label'][1], AT('/',oJsonFilter['level'][1]['label'][1]) + 1, 4 )
      cDataIni  := cAno + cMes + "01"
      cDataFim  := DtoS(LastDate(StoD(cDataIni)))
      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter   := oCoreDash:GetApiFilter()
      cAliasQry := FD100LSNat(cDataIni, cDataFim, , cExibNat, aRetTipo, cMoeda, aFilter, ctpSaldo )
      lDash     := .T.
    ElseIf Len(oJsonDD) == 1
      aHeader   := FD100LHePR()
      aItems    := FD100LItPR(Iif(oJsonDD[1]['tpmovto'] = "Receita", "SE1", "SE2"))
      cMes      := FD100GReMe(Substr(oJsonFilter['level'][1]['label'][1],1, AT('/',oJsonFilter['level'][1]['label'][1]) - 1 ))
      cAno      := Substr(oJsonFilter['level'][1]['label'][1], AT('/',oJsonFilter['level'][1]['label'][1]) + 1, 4 )
      cDataIni  := cAno + cMes + "01"
      cDataFim  := DtoS(LastDate(StoD(cDataIni)))
      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter   := oCoreDash:GetApiFilter()
      cAliasQry := FD100LQyPR(oJsonDD[1]['tpmovto'], oJsonDD[1]['codnatur'], cDataIni, cDataFim, aFilter, nPosPage, nPageSize )
      lDash     := .T.
    Endif
  ElseIf Len(oJsonFilter["level"]) == 2
    If Len(oJsonDD) == 0
      cDataSet  := oJsonFilter['level'][2]['labelDataSet']
      aHeader   := FD100LHeNa(cExibNat, cMoeda)
      aItems    := FD100LItNa(cExibNat)
      cMes      := FD100GReMe(Substr(oJsonFilter['level'][1]['label'][1],1, AT('/',oJsonFilter['level'][1]['label'][1]) - 1 ))
      cAno      := Substr(oJsonFilter['level'][1]['label'][1], AT('/',oJsonFilter['level'][1]['label'][1]) + 1, 4 )
      cDataIni  := cAno + cMes + "01"
      cDataFim  := DtoS(LastDate(StoD(cDataIni)))
      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter   := oCoreDash:GetApiFilter()
      cAliasQry := FD100LSNat(cDataIni, cDataFim, cDataSet, cExibNat, aRetTipo, cMoeda, aFilter, ctpSaldo )
      lDash     := .T.
    ElseIf Len(oJsonDD) == 1
      aHeader   := FD100LHePR()
      aItems    := FD100LItPR(Iif(oJsonDD[1]['tpmovto'] = "Receita", "SE1", "SE2"))
      cMes      := FD100GReMe(Substr(oJsonFilter['level'][1]['label'][1],1, AT('/',oJsonFilter['level'][1]['label'][1]) - 1 ))
      cAno      := Substr(oJsonFilter['level'][1]['label'][1], AT('/',oJsonFilter['level'][1]['label'][1]) + 1, 4 )
      cDataIni  := cAno + cMes + "01"
      cDataFim  := DtoS(LastDate(StoD(cDataIni)))
      oCoreDash:SetFields(aItems)
      oCoreDash:SetApiQstring(Self:aQueryString)
      aFilter   := oCoreDash:GetApiFilter()
      cAliasQry := FD100LQyPR(oJsonDD[1]['tpmovto'], oJsonDD[1]['codnatur'], cDataIni, cDataFim, aFilter, nPosPage, nPageSize )
      lDash     := .T.
    Endif
  EndIf

  oCoreDash:SetTable(cAliasQry)
  oCoreDash:BuildJson()

	If lRet
    oCoreDash:SetPOHeader(aHeader)
		Self:SetResponse( oCoreDash:ToObjectJson() )
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

  If Select(cAliasQry) > 0
    (cAliasQry)->(DBCloseArea())
  Endif

	oCoreDash:Destroy()
  FreeObj(aRet)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} fd100GDado
Retorna o valor do movimento financeiro e das naturezas informadas

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function fd100GDado(oResponse, oCoreDash, oJson)

  Local aDataFim  AS Array
  Local aData1    AS Array
  Local aData2    AS Array
  Local aData3    AS Array
  Local aData4    AS Array
  Local aCab      AS Array
  Local aRetTipo  AS Array
  Local aClrChart AS Array
  Local nPeriodo  AS Numeric
  Local nPerData  AS Numeric
  Local nY        AS Numeric
  Local cMes      As Character
  Local cAno      As Character
  Local dDiaIni   As Character
  Local dDiaFim   As Character
  Local dMesIni   As Character
  Local dMesFim   As Character
  Local dAnoIni   As Character
  Local dAnoFim   As Character
  Local ctpSaldo  As Character
  Local cMoeda    As Character
  Local cAuxAno   As Character
  Local cDtIni    As Character
  Local cDtFim    As Character
  Local cGreenDk  As Character
  Local cGreenLht As Character
  Local cRedDk    As Character
  Local cRedLht   As Character
  Local cYellDk   As Character
  Local cYellLht  As Character
  Local cConsProv As Character
  Local cConsRAPA As Character
  Local cConsNDFC As Character
  Local cPagRec   As Character
  Local cPagReal  As Character
  Local cRecReal  As Character
  Local cReceita  As Character
  Local cDespesa  As Character
  Local cRecPrE1  As Character 
  Local cPagPrE2  As Character 
  Local cRecReE1  As Character 
  Local cPagReE2  As Character 
  Local dDataIni  AS Date
  Local dDataFim  AS Date
  Local lVldExec  AS Logical
  Local lLegenda  AS Logical
  Local lVldNiv   AS Logical
  Local lRecPag   AS Logical
  Local lRetOrc   AS Logical
  Local lRetOPr   As Logical

  aDataFim  := {}
  aData1    := {}
  aData2    := {}
  aData3    := {}
  aData4    := {}
  aCab      := {}
  aRetTipo  := {}
  nPeriodo  := 0
  nPerData  := 0
  nY        := 0
  cMes      := ""
  cAno      := ""
  ctpSaldo  := ""
  cMoeda    := ""
  cAuxAno   := ""
  cDtIni    := ""
  cDtFim    := ""
  cConsRAPA := ""
  cConsNDFC := ""
  cConsProv := ""
  cPagRec   := ""
  cPagReal  := ""
  cRecReal  := ""
  cReceita  := ""
  cDespesa  := ""
  cRecPrE1  := ""
  cPagPrE2  := ""
  cRecReE1  := ""
  cPagReE2  := ""

  aClrChart := oCoreDash:GetColorChart()

  cGreenDk  := aClrChart[1][3] //"rgba(  0,178,142, 1)"
  cGreenLht := aClrChart[2][3] //"rgba(  0,201,161, 1)"
  cRedDk    := aClrChart[3][3] //"rgba(198, 72, 64, 1)"
  cRedLht   := aClrChart[4][3] //"rgba(227, 73, 64, 1)"
  cYellDk   := aClrChart[5][3] //"rgba(252,203, 76, 1)"
  cYellLht  := aClrChart[6][3] //"rgba(255,212,100, 1)" 

  lVldExec  := .F.
  lLegenda  := .F.
  lVldNiv   := .F.
  lRecPag   := .F.
  lRetOrc   := .F.
  lRetOPr   := .F.

  dDiaIni   := subStr(oJson['dateIni'],9,2)
  dDiaFim   := subStr(oJson['dateFim'],9,2)
  dMesIni   := subStr(oJson['dateIni'],6,2)
  dMesFim   := subStr(oJson['dateFim'],6,2)
  dAnoIni   := subStr(oJson['dateIni'],1,4)
  dAnoFim   := subStr(oJson['dateFim'],1,4)

  dDataIni  := StoD(dAnoIni + dMesIni + dDiaIni)
  dDataFim  := StoD(dAnoFim + dMesFim + dDiaFim)

  nPeriodo  := (DateDiffMonth(dDataFim,dDataIni) + 1)

  ctpSaldo  := FD100LTpSl(oJson['tpSaldo'])

  cMoeda    := subStr(oJson['moedas'],1,2)

  // "1 = Não Considera" -- Não considera PR no Total da Natureza FIW - Subtrai do Total
  // "2 = Considera Somente Despesa" -- Considera PR no Total da Natureza FIW - Mantem do Total - Pagar
  // "3 = Considera Somente Receita" -- Considera PR no Total da Natureza FIW - Mantem do Total - Receber
  // "4 = Considera Ambos" -- Considera PR no Total da Natureza FIW - Mantem do Total

  cConsProv := subStr(oJson['consProv'],1,1) 
  cConsRAPA := subStr(oJson['consPRRA'],1,1) 
  cConsNDFC := subStr(oJson['consNCCF'],1,1) 

  aRetTipo := FD100GTipo(cConsProv, cConsRAPA, cConsNDFC )

  cRecPrE1 := Iif(Len(aRetTipo) >= 1, aRetTipo[1], "")
  cPagPrE2 := Iif(Len(aRetTipo) >= 2, aRetTipo[2], "")
  cRecReE1 := Iif(Len(aRetTipo) >= 3, aRetTipo[3], "")
  cPagReE2 := Iif(Len(aRetTipo) >= 4, aRetTipo[4], "")

  nPerData  := Val(dMesIni)

  cAuxAno   := dAnoIni

  If oJson:GetJsonText("level") == "null" .Or. Len(oJson["level"]) == 0
    For nY := 1 To nPeriodo
      Aadd(aCab, {MesExtenso(nPerData) + "/" + cAuxAno})
      nPerData++
      If nPerData > 12
        cAuxAno := Alltrim(Str(Val(cAuxAno) + 1))
        nPerData := 1
      Endif
    Next nY

    lVldExec  := .T.
  ElseIf Len(oJson["level"]) == 1
    dMesIni := oJson["level"][1]['label'][1]
    dAnoIni := Substr(dMesIni, AT('/',dMesIni) + 1, 4 )
    dAnoFim := dAnoIni
    dMesIni := FD100GReMe(Substr(dMesIni,1, AT('/',dMesIni) - 1 ))
    nPeriodo:= 1
    
    aCab := { oJson["level"][1]['label'][1]}

    lVldExec  := .T.
    lLegenda  := .T.
  ElseIf Len(oJson["level"]) == 2
    aCab    := { oJson["level"][1]['label'][1] }
    cMes    := oJson["level"][1]['label'][1]
    cAno    := Substr(cMes, AT('/',cMes) + 1, 4 )
    cMes    := FD100GReMe(Substr(cMes,1, AT('/',cMes) - 1 ))
    cDtIni  := cAno + cMes + "01"
    cDtFim  := DtoS(LastDate(StoD(cDtIni)))

    lVldNiv := .T.
  Endif

  If lVldExec .And. !lVldNiv
    If "0" $ ctpSaldo .Or. ("1" $ ctpSaldo .And. "2" $ ctpSaldo .And. "3" $ ctpSaldo)
      aData1 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "2", cRecPrE1)
      aData2 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "3", cRecReE1)
      aData3 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "2", cPagPrE2)
      aData4 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "3", cPagReE2)
      aData5 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "1")
      aData6 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "1")
      
      oCoreDash:SetChartInfo( aData1, STR0016, , cGreenDk ,, .T. ) // 'Previsto Receita'
      oCoreDash:SetChartInfo( aData2, STR0017, , cGreenLht,, .T. ) // 'Realizado Receita'
      oCoreDash:SetChartInfo( aData3, STR0018, , cRedDk   ,, .T. ) // 'Previsto Despesas'
      oCoreDash:SetChartInfo( aData4, STR0019, , cRedLht  ,, .T. ) // 'Realizado Despesas'
      oCoreDash:SetChartInfo( aData5, STR0020, , cYellDk  ,, .T. ) // 'Orçado Receita'
      oCoreDash:SetChartInfo( aData6, STR0021, , cYellLht ,, .T. ) // 'Orçado Despesas'
    ElseIf "2" $ ctpSaldo .And. "3" $ ctpSaldo
      aData1 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "2", cRecPrE1)
      aData2 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "3", cRecReE1)
      aData3 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "2", cPagPrE2)
      aData4 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "3", cPagReE2)
      
      oCoreDash:SetChartInfo( aData1, STR0016, , cGreenDk ,, .T. ) // 'Previsto Receita'
      oCoreDash:SetChartInfo( aData2, STR0017, , cGreenLht,, .T. ) // 'Realizado Receita'
      oCoreDash:SetChartInfo( aData3, STR0018, , cRedDk   ,, .T. ) // 'Previsto Despesas'
      oCoreDash:SetChartInfo( aData4, STR0019, , cRedLht  ,, .T. ) // 'Realizado Despesas'
    ElseIf "1" $ ctpSaldo .And. "2" $ ctpSaldo
      aData1 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "2", cRecPrE1)
      aData2 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "2", cPagPrE2)
      aData3 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "1")
      aData4 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "1")
      
      oCoreDash:SetChartInfo( aData1, STR0016, , cGreenDk  ,, .T. ) // 'Previsto Receita'
      oCoreDash:SetChartInfo( aData2, STR0018, , cGreenLht ,, .T. ) // 'Previsto Despesas'
      oCoreDash:SetChartInfo( aData3, STR0020, , cYellDk   ,, .T. ) // 'Orçado Receita'
      oCoreDash:SetChartInfo( aData4, STR0021, , cYellLht  ,, .T. ) // 'Orçado Despesas'
    ElseIf "1" $ ctpSaldo .And. "3" $ ctpSaldo
      aData1 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "3", cRecReE1)
      aData2 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "3", cPagReE2)
      aData3 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "1")
      aData4 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "1")

      oCoreDash:SetChartInfo( aData1, STR0017, , cRedDk   ,, .T. ) // 'Realizado Receita'
      oCoreDash:SetChartInfo( aData2, STR0019, , cRedLht  ,, .T. ) // 'Realizado Despesas'
      oCoreDash:SetChartInfo( aData3, STR0020, , cYellDk  ,, .T. ) // 'Orçado Receita'
      oCoreDash:SetChartInfo( aData4, STR0021, , cYellLht ,, .T. ) // 'Orçado Despesas'
    ElseIf "1" $ ctpSaldo
      aData1 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "1")
      aData2 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "1")

      oCoreDash:SetChartInfo( aData1, STR0020, , cYellDk ,, .T. ) // 'Orçado Receita'
      oCoreDash:SetChartInfo( aData2, STR0021, , cYellLht,, .T. ) // 'Orçado Despesas'
    ElseIf "2" $ ctpSaldo
      aData1 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "2", cRecPrE1)
      aData2 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "2", cPagPrE2)

      oCoreDash:SetChartInfo( aData1, STR0016, , cGreenDk ,, .T. ) // 'Previsto Receita'
      oCoreDash:SetChartInfo( aData2, STR0018, , cGreenLht,, .T. ) // 'Previsto Despesas'
    ElseIf "3" $ ctpSaldo
      aData1 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "R", cMoeda, "3", cRecReE1)
      aData2 := FD100LNatu(dMesIni, dAnoIni, dAnoFim, nPeriodo, "P", cMoeda, "3", cPagReE2)

      oCoreDash:SetChartInfo( aData1, STR0017, , cRedDk ,, .T. ) // 'Realizado Receita'
      oCoreDash:SetChartInfo( aData2, STR0019, , cRedLht,, .T. ) // 'Realizado Despesas'
    Endif

    aDataFim := {}

    If !lLegenda
      aAdd(aDataFim, oCoreDash:SetChart(aCab,,.T., , , retMask(cMoeda, 10, 2)))
    Else
      aAdd(aDataFim, oCoreDash:SetChart(aCab,,.T., ,STR0022 + STR0023 + " - " + oJson["level"][1]["label"][1], retMask(cMoeda, 10, 2))) //"Financeiro - " # "Movimentos do Período "
    Endif
    
    oResponse["items"] := aDataFim
  Endif

  If !lVldExec .And. lVldNiv
    If oJson['level'][2]['labelDataSet'] = STR0016 // 'Previsto Receita'
      cVencer   := STR0024 //'Previsto Receita A Vencer'
      cVencido  := STR0025 //'Previsto Receita Vencidos'
      cPagRec   := 'Rec'
      lRecPag   := .T.
    ElseIf oJson['level'][2]['labelDataSet'] = STR0018 // "Previsto Despesas"
      cVencer   := STR0026 //'Previsto Despesas A Vencer'
      cVencido  := STR0027 //'Previsto Despesas Vencidos'
      cPagRec   := 'Pag'
      lRecPag   := .T.
    ElseIf oJson['level'][2]['labelDataSet'] == STR0021 // 'Orçado Despesas'
      cVencer   := STR0021 // 'Orçado Despesas'
      cPagRec   := 'Pag'
      lRetOrc   := .T.
    ElseIf oJson['level'][2]['labelDataSet'] == STR0020 //'Orçado Receita'
      cVencer   := STR0020 //'Orçado Receita'
      cPagRec   := 'Rec'
      lRetOrc   := .T.
      lRetOPr   := .T.
    ElseIf oJson['level'][2]['labelDataSet'] = STR0017 .Or. oJson['level'][2]['labelDataSet'] = STR0019 //'Realizado Receita' # 'Realizado Despesas'
      cReceita  := STR0017 //'Realizado Receita'
      cDespesa  := STR0019 //'Realizado Despesas'
      cPagReal  := "Pag"
      cRecReal  := "Rec"
      lRecPag := .F.
    Endif

    If lRecPag
      If cMes == Month2Str(Date()) .And. cAno == Year2Str(Date())
        aData1 := FD100LPgRe(cDtIni, cDtFim, "A", , cMoeda, "2", cPagRec) // A = Titulos a Vencer
        aData2 := FD100LPgRe(cDtIni, cDtFim, "V", , cMoeda, "2", cPagRec) // V = Titulos Vencidos
        oCoreDash:SetChartInfo( aData1, cVencer , , cGreenLht,, .T. )
        oCoreDash:SetChartInfo( aData2, cVencido , , cRedLht ,, .T. )
      ElseIf cMes == Month2Str(Date()) .And. cAno < Year2Str(Date())
        aData1 := FD100LPgRe(cDtIni, cDtFim, , , cMoeda, "2", cPagRec) // Titulos Vencidos
        oCoreDash:SetChartInfo( aData1, cVencido , , cRedLht,, .T. )
      ElseIf cMes == Month2Str(Date()) .And. cAno > Year2Str(Date())
        aData1 := FD100LPgRe(cDtIni, cDtFim, , , cMoeda, "2", cPagRec) // Titulos A Vencer
        oCoreDash:SetChartInfo( aData1, cVencer , , cGreenLht,, .T. )
      ElseIf cMes < Month2Str(Date()) .And. (cAno == Year2Str(Date()) .Or. cAno < Year2Str(Date()))
        aData1 := FD100LPgRe(cDtIni, cDtFim, , , cMoeda, "2", cPagRec) // Titulos Vencidos
        oCoreDash:SetChartInfo( aData1, cVencido , , cRedLht,, .T. )
      ElseIf cMes < Month2Str(Date()) .And. cAno > Year2Str(Date())
        aData1 := FD100LPgRe(cDtIni, cDtFim, , , cMoeda, "2", cPagRec) // Titulos A Vencer
        oCoreDash:SetChartInfo( aData1, cVencer , , cGreenLht,, .T. )
      ElseIf cMes > Month2Str(Date()) .And. (cAno == Year2Str(Date()) .Or. cAno > Year2Str(Date()))
        aData1 := FD100LPgRe(cDtIni, cDtFim, , , cMoeda, "2", cPagRec) // Titulos A Vencer
        oCoreDash:SetChartInfo( aData1, cVencer , , cGreenLht,, .T. )
      ElseIf cMes > Month2Str(Date()) .And. cAno < Year2Str(Date())
        aData1 := FD100LPgRe(cDtIni, cDtFim, , , cMoeda, "2", cPagRec) // Titulos Vencidos
        oCoreDash:SetChartInfo( aData1, cVencido , , cRedLht,, .T. )
      Endif
    ElseIf !lRecPag .And. !lRetOrc
      aData1 := FD100LPgRe(cDtIni, cDtFim, , "R", cMoeda, "3", cRecReal) 
      aData2 := FD100LPgRe(cDtIni, cDtFim, , "P", cMoeda, "3", cPagReal) 
      oCoreDash:SetChartInfo( aData1, cReceita , , cGreenLht,, .T. )
      oCoreDash:SetChartInfo( aData2, cDespesa, , cRedLht,, .T. )
    ElseIf lRetOrc
      nPeriodo  := 1
      If lRetOPr
        aData1 := FD100LNatu(cMes, cAno, cAno, nPeriodo, "R", cMoeda, "1")
        oCoreDash:SetChartInfo( aData1, STR0020 , , cGreenDk ,, .T. ) //'Orçado Receita'
      Else
        aData1 := FD100LNatu(cMes, cAno, cAno, nPeriodo, "P", cMoeda, "1")
        oCoreDash:SetChartInfo( aData1, STR0021 , , cRedDk   ,, .T. ) // 'Orçado Despesas'
      Endif
    Endif

    aDataFim := {}
    aAdd(aDataFim, oCoreDash:SetChart(aCab,,.T., ,STR0022 + STR0023 + " - " + oJson["level"][1]["label"][1], retMask(cMoeda, 10, 2))) //"Financeiro - " # "Movimentos do Período "
    oResponse["items"] := aDataFim
  EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100GReMe
Retorna o mes como numeros

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD100GReMe(cMes As Character) As Character

Default cMes := ""

If !Empty(cMes)
  If cMes = STR0040 // "Janeiro"
    cMes = "01"
  ElseIf cMes = STR0041 // "Fevereiro"
    cMes = "02"
  ElseIf cMes = STR0042 .Or. cMes = STR0043 // "Marco" # "Março"
    cMes = "03"
  ElseIf cMes = STR0044 // "Abril"
    cMes = "04"
  ElseIf cMes = STR0045 // "Maio"
    cMes = "05"
  ElseIf cMes = STR0046 // "Junho"
    cMes = "06"
  ElseIf cMes = STR0047 // "Julho"
    cMes = "07"
  ElseIf cMes = STR0048 // "Agosto"
    cMes = "08"
  ElseIf cMes = STR0049 // "Setembro"
    cMes = "09"
  ElseIf cMes = STR0050 // "Outubro"
    cMes = "10"
  ElseIf cMes = STR0051 // "Novembro"
    cMes = "11"
  ElseIf cMes = STR0052 // "Dezembro"
    cMes = "12"
  Endif
Endif

Return cMes

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100GMoed
Retorna as moedas cadastradas

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100GMoed() AS Array

Local aMoedas AS Array
Local cQuery  As Character
Local cTemp   As Character

aMoedas := {}
cQuery  := ""
cTemp   := GetNextAlias()

cQuery := " SELECT DISTINCT CTO_MOEDA, CTO_DESC "
cQuery += " FROM " + RetSqlName("CTO") + " CTO " 
cQuery += " WHERE "
cQuery += " D_E_L_E_T_ = '' "
cQuery += " AND CTO_FILIAL = '" + xFilial("CTO") + "' "

cQuery	:= ChangeQuery(cQuery)

MPSysOpenQuery( cQuery, cTemp )

(cTemp)->(DbGoTop())

While (cTemp)->(!Eof())
  AAdd(aMoedas, (cTemp)->CTO_MOEDA + " - " + (cTemp)->CTO_DESC)
  (cTemp) ->(dbSkip())
EndDo

(cTemp)->(DBCloseArea())

Return aMoedas

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100GTpSd
Retorna o tipo de saldo do movimento

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD100GTpSd() AS Array

Local aTpSald AS Array

aTpSald := {}

AAdd(aTpSald, STR0028 ) //"0 = Todos"
AAdd(aTpSald, STR0029 ) //"1 = Orcado"
AAdd(aTpSald, STR0030 ) //"2 = Previsto"
AAdd(aTpSald, STR0031 ) //"3 = Realizado"

Return aTpSald

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100GCons
Retorna o tipo de saldo do movimento

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD100GCons() AS Array

Local aRetProv AS Array

aRetProv := {} 

AAdd(aRetProv, STR0032 ) // "1 = Não Considera" 
AAdd(aRetProv, STR0033 ) // "2 = Considera Somente Despesa"
AAdd(aRetProv, STR0034 ) // "3 = Considera Somente Receita"
AAdd(aRetProv, STR0035 ) // "4 = Considera Ambos"

Return aRetProv

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100GTipo
Retorna o Array com os tipos de títulos que devem ser considerados no saldo na natureza

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD100GTipo(cTpPR As Character, cTpRA As Character, cTpNCCF As Character) AS Array

Local aRet      AS Array
Local cPRTitE1  As Character
Local cPRTitE2  As Character
Local cRATitE1  As Character
Local cRATitE2  As Character
Local cRecPrE1  As Character
Local cPagPrE2  As Character
Local cRecReE1  As Character
Local cPagReE2  As Character

Default cTpPR   := ""
Default cTpRA   := ""
Default cTpNCCF := ""

aRet      := {}
cPRTitE1  := ""
cPRTitE2  := ""
cRATitE1  := ""
cRATitE2  := ""
cRecPrE1  := ""
cPagPrE2  := ""
cRecReE1  := ""
cPagReE2  := ""

// "1 = Não Considera" -- Não considera PR no Total da Natureza FIW - Subtrai do Total
// "2 = Considera Somente Despesa" -- Considera PR no Total da Natureza FIW - Mantem do Total - Pagar
// "3 = Considera Somente Receita" -- Considera PR no Total da Natureza FIW - Mantem do Total - Receber
// "4 = Considera Ambos" -- Considera PR no Total da Natureza FIW - Mantem do Total

If cTpPR $ "1|2|3"
  If cTpPR = "1"
    cPRTitE1  := "'PR'"
    cPRTitE2  := "'PR'"
  ElseIf cTpPR = "2"
    cPRTitE1  := "'PR'"
  Else
    cPRTitE2  := "'PR'"
  Endif
Endif

If cTpRA $ "1|2|3"
  If cTpRA = "1"
    cRATitE1  := "'RA'"
    cRATitE2  := "'PA'"
  ElseIf cTpRA = "2"
    cRATitE1  := "'RA'"
  Else
    cRATitE2  := "'PA'"
  Endif
Endif

If cTpNCCF $ "1|2|3"
  If cTpNCCF = "1"
      cRecPrE1  := "'NDC','NCF'" + Iif(!Empty(cPRTitE1), ',' + cPRTitE1, cPRTitE1)
      cPagPrE2  := "'NCF'" + Iif(!Empty(cPRTitE2), ',' + cPRTitE2, cPRTitE2)
      cRecReE1  := "'NCC'" + Iif(!Empty(cRATitE1), ',' + cRATitE1, cRATitE1)
      cPagReE2  := "'NDF'" + Iif(!Empty(cRATitE2), ',' + cRATitE2, cRATitE2)

      Aadd(aRet, cRecPrE1)
      Aadd(aRet, cPagPrE2)
      Aadd(aRet, cRecReE1)
      Aadd(aRet, cPagReE2)
  ElseIf cTpNCCF = "2"
      cRecPrE1  := "'NDC','NCF'" + Iif(!Empty(cPRTitE1), ',' + cPRTitE1, cPRTitE1)
      cRecReE1  := "'NCC'" + Iif(!Empty(cRATitE1), ',' + cRATitE1, cRATitE1)

      Aadd(aRet, cRecPrE1)
      Aadd(aRet, "")
      Aadd(aRet, cRecReE1)
      Aadd(aRet, "")
  Else
      cPagPrE2  := "'NCF'" + Iif(!Empty(cPRTitE2), ',' + cPRTitE2, cPRTitE2)
      cPagReE2  := "'NDF'" + Iif(!Empty(cRATitE2), ',' + cRATitE2, cRATitE2)

      Aadd(aRet, "")
      Aadd(aRet, cPagPrE2)
      Aadd(aRet, "")
      Aadd(aRet, cPagReE2)
  Endif
ElseIf cTpPR $ "1|2|3" .Or. cTpRA $ "1|2|3"
  Aadd(aRet, cPRTitE1)
  Aadd(aRet, cPRTitE2)
  Aadd(aRet, cRATitE1)
  Aadd(aRet, cRATitE2)
Endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} retMask
Retorna o Array com a mascara e tamnhos que dos valores que devem ser visualizados no gráfico

@author		francisco.oliveira
@since		22/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function retMask(cMoeda As Character, nMax AS Numeric, nMin AS Numeric) AS Array

Local aItems   AS Array
Local aItem    AS Object
Local cMaskMoe As Character
Local nMaxiFra AS Numeric
Local nMiniFra AS Numeric

Default cMoeda  := "01"
Default nMax    := 10
Default nMin    := 2

aItems    := {}
cMaskMoe  := SuperGetMV("MV_SIMB" + Alltrim(Str(Val(cMoeda))))  
nMaxiFra  := nMax
nMiniFra  := nMin

aItem   := JsonObject():New()
aItem['maskFrac'] := cMaskMoe
aItem['maxiFrac'] := nMaxiFra
aItem['miniFrac'] := nMiniFra

AAdd(aItems,aItem)

Return aItems
