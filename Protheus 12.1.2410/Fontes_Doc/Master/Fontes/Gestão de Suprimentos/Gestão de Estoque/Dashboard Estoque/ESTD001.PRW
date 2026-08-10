#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "ESTD001.CH"

/*/{Protheus.doc} CardEst01

Card de Quantidade e Valor em Estoque

@author		Adriano Vieira
@since		14/12/2020
/*/
WSRESTFUL CardEst01 DESCRIPTION OemToAnsi(STR0015) // "Card Quantidade e Valor em Estoque"
	WSDATA Fields			AS STRING   OPTIONAL
	WSDATA Order			AS STRING	  OPTIONAL
	WSDATA Page				AS INTEGER  OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL
	WSDATA Code       AS STRING 	OPTIONAL

    WSMETHOD POST itemsDetails ;
    DESCRIPTION OemToAnsi(STR0016)  ;//"Carrega os Itens Utilizados para Montagem do Painel"
    WSSYNTAX "/cards/itemsDetails/{Order, Page, PageSize, Fields}" ;
    PATH "/cards/itemsDetails";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET headerItens ;
    DESCRIPTION OemToAnsi(STR0017)  ; //"Carrega os Cabeçalho a ser apresentado nos detalhes"
    WSSYNTAX "/cards/headerItens/" ;
    PATH "/cards/headerItens";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET cardInfo ;
    DESCRIPTION OemToAnsi(STR0018) ; //"Carrega as informações do Painel"
    WSSYNTAX "/cards/cardInfo/" ;
    PATH "/cards/cardInfo";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET fieldsInfo ;
    DESCRIPTION OemToAnsi(STR0019) ; //"Carrega os campos que podem que ser utilizados"
    WSSYNTAX "/cards/fieldsInfo/" ;
    PATH "/cards/fieldsInfo";
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} POST itemsDetails
Carrega os Itens Utilizados para Montagem do Card

@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE CardEst01

  Local aHeader     := {}
  Local aRet        := {}
  Local aFilter     := {}
  Local nFiltro     := 0
  Local cWhere      := ""
  Local cError      := STR0001 //"Erro na Requisição"
  Local cBody       := IIF( Self:GetContent() == Nil, '', DecodeUtf8(Self:GetContent()))
	Local lRet			  := .T.
  Local oBody       := JsonObject():New()
  Local oCoreDash   := CoreDash():New()
  Local oJsonDD     := JsonObject():New()

  Self:SetContentType("application/json")

  If !Empty(cBody)
      oBody:FromJson(cBody)
      If ValType(oBody["detailFilter"]) == "A"
          oJsonDD := oBody["detailFilter"]
      EndIf
  EndIf

  aHeader := Headers()

  oCoreDash:SetFields(DePara())
  oCoreDash:SetApiQstring(Self:aQueryString)
  aFilter := oCoreDash:GetApiFilter()

  For nFiltro := 1 to Len(aFilter)
    If !SubStr(Alltrim(aFilter[nFiltro][1]),1,13) == "SB2.B2_FILIAL"
      If nFiltro < Len(aFilter)
          cWhere += aFilter[nFiltro][1] + " AND "
      else
          cWhere += aFilter[nFiltro][1]
      Endif
    EndIf
  Next

  aRet := MntQuery( cWhere, aFilter )

  oCoreDash:SetQuery(aRet[1])
  oCoreDash:SetWhere(aRet[2])

  oCoreDash:SetFields(DePara())
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
/*/{Protheus.doc} MntQuery
Monta a query responsavel por trazer os itens utilizados no botao Detalhes do Card

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQuery(  cWhereFilter, aFilter )
  Local cQuery  := ""
  Local cSelect := " SB2.B2_COD, SB1.B1_DESC, SB2.B2_QATU, SB2.B2_VATU1, SB2.B2_LOCAL, SB2.B2_LOCALIZ, SB2.B2_FILIAL  "
  Local nY  := 0
  Local nCont := 0
  Local cWhere := " "
  Local cFilJoinSB1   := ""
  Local nTamFilSB1    := Len(AllTrim(FWxFilial('SB1')))
  Local nTamFilSB2    := Len(AllTrim(FWxFilial('SB2')))

  Default cWhereFilter  := ""
  Default aFilter  := {}

  If (nTamFilSB1 == nTamFilSB2) // filiais com mesmo compartilhamento
    cFilJoinSB1 := " AND SB2.B2_FILIAL = SB1.B1_FILIAL "
  EndIf 

  For nY := 1 To Len(aFilter)
    If SubStr(Alltrim(aFilter[nY][1]),1,13) == "SB2.B2_FILIAL"
      cWhereFilter := aFilter[nY][1]
      nCont ++
    Endif
  Next nY

  If Len(aFilter) > 0

    cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SB2") + " SB2 INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = SB2.B2_COD "+ cFilJoinSB1 

    If nCont > 0
      If !(Empty(cWhereFilter))
        cQuery += " WHERE " + cWhereFilter + " AND  SB2.D_E_L_E_T_ = ' ' AND  SB1.D_E_L_E_T_ = ' ' "
      Else
        cQuery += " WHERE SB2.D_E_L_E_T_ = ' ' AND  SB1.D_E_L_E_T_ = ' ' " 
      EndIf
    Else
      If !(Empty(cWhereFilter))
        cQuery += " WHERE " + cWhereFilter + " AND SB2.B2_FILIAL = '" + xFilial("SB2") + "'  AND  SB2.D_E_L_E_T_ = ' ' AND  SB1.D_E_L_E_T_ = ' ' "
      Else
        cQuery += " WHERE SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND  SB2.D_E_L_E_T_ = ' ' AND  SB1.D_E_L_E_T_ = ' ' "
      EndIf
    EndIf

    cWhere := " "

  Else

    cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SB2") + " SB2 INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = SB2.B2_COD "+ cFilJoinSB1 
    cWhere := " SB2.D_E_L_E_T_ = ' ' AND  SB1.D_E_L_E_T_ = ' ' "
    cWhere += " AND SB2.B2_FILIAL = '" + xFilial("SB2") + "' "

  EndIf

Return {cQuery, cWhere}

//-------------------------------------------------------------------
/*/{Protheus.doc} DePara
Realiza o De/Para entre os objetos do Json e os campos do Protheus

@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function DePara()
  Local aCampos := {}

  aCampos := {;
    {"filial"   , "SB2.B2_FILIAL"   },;
    {"produto"  , "SB2.B2_COD"      },;
    {"desc"     , "SB2.B1_DESC"     },;
    {"qtd"      , "SB2.B2_QATU"     },;
    {"valor"    , "SB2.B2_VATU1"    },;
    {"local"    , "SB2.B2_LOCAL"    },;
    {"localiz"  , "SB2.B2_LOCALIZ"  };
  }
Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} GET Headers
Monta o cabecalho (headers) das colunas conforme o nivel

@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function Headers()
Local aHeader := {}
Local cFmtCurr1 := Iif(cPaisLoc == 'BRA', 'currency', 'number' )
Local cFmtCurr2 := Iif(cPaisLoc == 'BRA', 'BRL', '1.2-2' )
aHeader := {;
        {"produto"      , STR0014,,,.T.,.T.                 },;
        {"desc"         , STR0006,,,.T.,.F.                 },;
        {"qtd"	        , STR0003, "number",'1.2-5',.T.,.T. },;
        {"valor"        , STR0004, cFmtCurr1, cFmtCurr2,.T.,.T.},;
        {"local"        , STR0005,,,.T.,.T.                 },;
        {"localiz"	    , STR0006                           },;
        {"filial"       , STR0007                           };
      }

Return aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} GET headerItens
Retorna o aHeader que sera utilizado no detalhamento do Card
Itens apresentados no cadastro do filtro
@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET headerItens WSSERVICE CardEst01

  Local aHeader     := {}
  Local oCoreDash   := CoreDash():New()
  Local oResponse		:= JsonObject():New()

  aHeader := {;
    {"filial"    ,  STR0007 },;
    {"produto"   ,  STR0002 },;
    {"qtd"       ,  STR0003 },;
    {"valor"     ,  STR0004 },;
    {"local"     ,  STR0005 };
  }

  oResponse["items"] := oCoreDash:SetPOHeader(aHeader)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET cardInfo
Método para retornar os dados do Card

@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET cardInfo WSRESTFUL CardEst01

Local cWhere      := ""
Local lRet			  := .T.
Local aFilter     := {}
Local nFiltro     := 0
Local oCoreDash   := CoreDash():New()
Local oResponse		:= JsonObject():New()

oCoreDash:SetFields(DePara())
oCoreDash:SetApiQstring(Self:aQueryString)

aFilter := oCoreDash:GetApiFilter()

For nFiltro := 1 to Len(aFilter)
  If !SubStr(Alltrim(aFilter[nFiltro][1]),1,13) == "SB2.B2_FILIAL"
    If nFiltro < Len(aFilter)
        cWhere += aFilter[nFiltro][1] + " AND "
    else
        cWhere += aFilter[nFiltro][1]
    Endif
  EndIf
Next

RetCardInfo( @oResponse, cWhere, aFilter)

self:SetResponse( EncodeUtf8(FwJsonSerialize(oResponse,.T.,.T.)) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
// Telemetria - Uso da classe FWLsPutAsyncInfo                  //
// Mecanismo para registro de métricas e envio                  //
// das mesmas ao License Serve da Totvs                         //
//?ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
FWLsPutAsyncInfo("LS006",RetCodUsr(),"04","ESTD001")

oResponse := Nil
FreeObj( oResponse )
oCoreDash := Nil
FreeObj( oCoreDash )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RetCardInfo
Retorna os dados que poderao ser apresentados no Card

@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function RetCardInfo( oResponse, cWhere, aFilter )

    Local item      := {}
    Local aItems    := {}
    Local nY        := 0
    Local cFil      := ""
    Local cTable    := " FROM " + RetSqlName("SB2") + " SB2 "

    Default aFilter := {}

    item := JsonObject():New()

    For nY := 1 To Len(aFilter)
      If SubStr(Alltrim(aFilter[nY][1]),1,13) == "SB2.B2_FILIAL"
        cFil :=  aFilter[nY][1]
      Endif
    Next nY

    If Len(aFilter) > 0
      If !Empty(cFil) 
        If !Empty(cWhere)
          cWhere  := " WHERE " + cWhere + " AND  " + cFil + " AND  D_E_L_E_T_ = ' ' "
        Else
          cWhere  := " WHERE " + cFil + " AND  D_E_L_E_T_ = ' ' "
        EndIf
      Else
        cWhere  := " WHERE " + cWhere + " AND SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND  D_E_L_E_T_ = ' ' "
      EndIf
    Else
      cWhere := " WHERE SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND  D_E_L_E_T_ = ' ' "
    EndIf

    item["total"]  :=	RetVlrEst(" SELECT SUM(B2_VATU1) valor " + cTable + " ", cWhere, '1')
    item["quant"]  :=	RetVlrEst(" SELECT SUM(B2_QATU)  quant " + cTable + " ", cWhere, '2')
    item["mod2"]   :=	RetVlrEst(" SELECT SUM(B2_VATU2) valor " + cTable + " ", cWhere, '3')
    item["mod3"]   :=	RetVlrEst(" SELECT SUM(B2_VATU3) valor " + cTable + " ", cWhere, '4')
    item["mod4"]   :=	RetVlrEst(" SELECT SUM(B2_VATU4) valor " + cTable + " ", cWhere, '5')
    item["mod5"]   :=	RetVlrEst(" SELECT SUM(B2_VATU5) valor " + cTable + " ", cWhere, '6')

    AADD(aItems, item)

    item := {}

    oResponse['hasNext'] := 'false'
    oResponse["items"]   := aItems

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET fieldsInfo
Carrega os campos que podem que ser utilizados

@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET fieldsInfo WSSERVICE CardEst01

    Local aItems    := {}
    Local item      := {}
    Local oResponse	:= JsonObject():New()

    item := JsonObject():New()
    item["label"] :=  STR0008 //"Quantidade de Produtos: "
    item["value"] :=  "quant"

    AADD(aItems, item)

    item := JsonObject():New()
    item["label"] :=  STR0009 //"Valor Total: "
    item["value"] :=  "total"

    AADD(aItems, item)

    item := JsonObject():New()
    item["label"] :=  STR0010 //"Moeda 2: "
    item["value"] :=  "mod2"

    AADD(aItems, item)

    item := JsonObject():New()
    item["label"] :=  STR0011	//"Moeda 3: "
    item["value"] :=  "mod3"

    AADD(aItems, item)

    item := JsonObject():New()
    item["label"] :=  STR0012 //"Moeda 4: "
    item["value"] :=  "mod4"

    AADD(aItems, item)

    item := JsonObject():New()
    item["label"] :=  STR0013 //"Moeda 5: "
    item["value"] :=  "mod5"

    AADD(aItems, item)

    oResponse["items"]  := aItems

    Self:SetResponse( FwHttpEncode(oResponse:ToJson()))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RetTotPed
Monta a query que sera utilizada para retornar as informacoes

@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function RetVlrEst(cSelect, cWhere, cOpc)
  Local cQuery  := ""
  Local cTemp   := GetNextAlias()
  Local xRet    := ''
  Local nRet    := ''
  Local cSimb1  := Alltrim(SuperGetMv("MV_SIMB1",.F.,"R$"))
  Local cSimb2  := Alltrim(SuperGetMv("MV_SIMB2",.F.,"US$"))
  Local cSimb3  := Alltrim(SuperGetMv("MV_SIMB3",.F.,"UFIR"))
  Local cSimb4  := Alltrim(SuperGetMv("MV_SIMB4",.F.,"EURO"))
  Local cSimb5  := Alltrim(SuperGetMv("MV_SIMB5",.F.,"IENE"))

  Default cWhere  := " WHERE "

  cQuery := cSelect + cWhere

  DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .F., .T. )
  If cOpc $ '1'
    While (cTemp)->( !Eof() )
      xRet :=	(cTemp)->valor
      nRet := cSimb1 + " "+Alltrim(Transform(xRet,'@E 9,999,999,999,999.99'))
      (cTemp)->(DbSkip())
    EndDo
  ElseIf cOpc $ '2'
    While (cTemp)->( !Eof() )
      xRet :=	(cTemp)->quant
      nRet := Alltrim(Transform(xRet,'@E 9,999,999,999,999'))
      (cTemp)->(DbSkip())
    EndDo
  ElseIf cOpc $ '3'
    While (cTemp)->( !Eof() )
      xRet :=	(cTemp)->valor
      nRet := cSimb2 + ": " + Alltrim(Transform(xRet,'@E 9,999,999,999,999.99'))
      (cTemp)->(DbSkip())
    EndDo
  ElseIf cOpc $ '4'
    While (cTemp)->( !Eof() )
      xRet :=	(cTemp)->valor
      nRet := cSimb3 + ": " + Alltrim(Transform(xRet,'@E 9,999,999,999,999.99'))
      (cTemp)->(DbSkip())
    EndDo
  ElseIf cOpc $ '5'
    While (cTemp)->( !Eof() )
      xRet :=	(cTemp)->valor
      nRet := cSimb4 + ": " + Alltrim(Transform(xRet,'@E 9,999,999,999,999.99'))
      (cTemp)->(DbSkip())
    EndDo
  ElseIf cOpc $ '6'
    While (cTemp)->( !Eof() )
        xRet :=	(cTemp)->valor
        nRet := cSimb5 + ": " + Alltrim(Transform(xRet,'@E 9,999,999,999,999.99'))
        (cTemp)->(DbSkip())
      EndDo
  EndIf

  (cTemp)->( DBCloseArea() )

Return nRet
