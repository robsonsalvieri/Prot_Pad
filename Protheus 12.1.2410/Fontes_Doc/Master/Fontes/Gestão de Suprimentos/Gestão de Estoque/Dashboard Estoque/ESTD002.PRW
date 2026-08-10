#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "ESTD002.CH"

/*/{Protheus.doc} CardEst02

Card de Card Lotes Vencidos

@author		Adriano Vieira
@since		20/12/2020
/*/
WSRESTFUL CardEst02 DESCRIPTION OemToAnsi(STR0011) //"Card Lotes Vencidos"
	WSDATA Fields			AS STRING   OPTIONAL
	WSDATA Order			AS STRING	  OPTIONAL
	WSDATA Page				AS INTEGER  OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL
	WSDATA Code       AS STRING 	OPTIONAL

    WSMETHOD POST itemsDetails ;
    DESCRIPTION  OemToAnsi(STR0012) ; //"Carrega os Itens Utilizados para Montagem do Painel"
    WSSYNTAX "/cards/itemsDetails/{Order, Page, PageSize, Fields}" ;
    PATH "/cards/itemsDetails";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET headerItens ;
    DESCRIPTION OemToAnsi(STR0013) ; //"Carrega os Cabeçalho a ser apresentado nos detalhes"
    WSSYNTAX "/cards/headerItens/" ;
    PATH "/cards/headerItens";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET cardInfo ;
    DESCRIPTION OemToAnsi(STR0014) ; //"Carrega as informações do Painel"
    WSSYNTAX "/cards/cardInfo/" ;
    PATH "/cards/cardInfo";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET fieldsInfo ;
    DESCRIPTION OemToAnsi(STR0015)  ; //"Carrega os campos que podem que ser utilizados"
    WSSYNTAX "/cards/fieldsInfo/" ;
    PATH "/cards/fieldsInfo";
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} POST itemsDetails
Carrega os Itens Utilizados para Montagem do Card

@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE CardEst02

  Local aHeader     := {}
  Local aRet        := {}
  Local aFilter     := {}
  Local nFiltro     := 0
  Local cWhere      := ""
  Local cError      := STR0001 //"Erro na Requisição"
	Local lRet			  := .T.
  Local oCoreDash   := CoreDash():New()

  Self:SetContentType("application/json")

  aHeader := Headers()

  oCoreDash:SetFields(DePara())
  oCoreDash:SetApiQstring(Self:aQueryString)

  aFilter := oCoreDash:GetApiFilter()

  For nFiltro := 1 to Len(aFilter)
      If nFiltro < Len(aFilter)
          cWhere += aFilter[nFiltro][1] + " AND "
      else
          cWhere += aFilter[nFiltro][1]
      Endif
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
Monta a query responsável por trazer os itens utilizados no Detalhes do Card

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQuery(  cWhere, aFilter )
  Local cQuery  := ""
  Local cInner  := " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = SB8.B8_PRODUTO AND SB1.D_E_L_E_T_ = ' '  "
  Local cSelect := " SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_SALDO, SB8.B8_LOTECTL, SB8.B8_DTVALID, SB1.B1_DESC "
  Local cFilJoinSB1   := ""
  Local nTamFilSB1    := Len(AllTrim(FWxFilial('SB1')))
  Local nTamFilSB8    := Len(AllTrim(FWxFilial('SB8')))

  Default cWhere  := ""

  If (nTamFilSB1 == nTamFilSB8) // filiais com mesmo compartilhamento
    cFilJoinSB1 := "  AND SB1.B1_FILIAL = SB8.B8_FILIAL "
    cInner      += cFilJoinSB1
  EndIf

  If Len(aFilter) > 0
    cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SB8") + " SB8 "+cInner
    cWhere := " " + cWhere + " AND  '" + dtos(ddatabase) + "' > SB8.B8_DTVALID  AND  SB8.D_E_L_E_T_ = ' ' "
  Else
    cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SB8") + " SB8 "+cInner
    cWhere += " SB8.B8_FILIAL = '" + xFilial("SB8") + "'   "
    cWhere += " AND  '" + dtos(ddatabase) + "' > SB8.B8_DTVALID  AND  SB8.D_E_L_E_T_ = ' ' "
  
  EndIf

Return {cQuery, cWhere}

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQuery2
Monta a query responsável por trazer as informações principais do card

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQuery2(cSelect,cWhere)
  Local cQuery  := ""
  
  Default cWhere  := " SB8.B8_FILIAL = '" + xFilial("SB8") + " ' AND  SB8.D_E_L_E_T_ = ' ' "
  Default cSelect := " COUNT(SB8.B8_LOTECTL) lotes "

  cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SB8") + " SB8 "

Return {cQuery, cWhere}

//-------------------------------------------------------------------
/*/{Protheus.doc} DePara
Realiza o De/Para entre os objetos do Json e os campos do Protheus

@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function DePara()
  Local aCampos := {}

  aCampos := {;
    {"filial"   , "SB8.B8_FILIAL"   },;
    {"produto"  , "SB8.B8_PRODUTO"  },;
    {"desc"     , "SB1.B1_DESC"     },;
    {"local"    , "SB8.B8_LOCAL"    },;
    {"lote"     , "SB8.B8_LOTECTL"  },;
    {"qtd"      , "SB8.B8_SALDO"    },;
    {"data"     , "SB8.B8_DTVALID"  };
  }
Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} GET Headers
Monta o cabeçalho (headers) das colunas conforme o nivel

@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function Headers()
Local aHeader := {}

aHeader := {;
        {"produto"  , STR0002,,,.T.,.T.                 },;
        {"desc"     , STR0010,,,.T.,.F.                 },; 
        {"local"    , STR0003,,,.T.,.T.                 },;
        {"qtd"      , STR0004, "number",'1.2-5',.T.,.T. },;
        {"lote"     , STR0005,,,.T.,.T.                 },;
        {"data"	    , STR0006                           };
      }

Return aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} GET headerItens
Retorna o aHeader que será utilizado no detalhamento do Card

@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET headerItens WSSERVICE CardEst02

  Local aHeader     := {}
  Local oCoreDash   := CoreDash():New()
  Local oResponse		:= JsonObject():New()

  aHeader := {;
    {"filial"    , STR0007  },;
    {"produto"   , STR0002  },;
    {"local"     , STR0003  },;
    {"lote"      , STR0005  },;
    {"qtd"       , STR0004  };
  }

  oResponse["items"] := oCoreDash:SetPOHeader(aHeader)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET cardInfo
Método para retornar os dados do Card

@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET cardInfo WSRESTFUL CardEst02

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
    If nFiltro < Len(aFilter)
        cWhere += aFilter[nFiltro][1] + " AND "
    else
        cWhere += aFilter[nFiltro][1]
    Endif
Next

RetCardInfo( @oResponse, cWhere, aFilter)

self:SetResponse( EncodeUtf8(FwJsonSerialize(oResponse,.T.,.T.)) )

FWLsPutAsyncInfo("LS006",RetCodUsr(),"04","ESTD002")

oResponse := Nil
FreeObj( oResponse )
oCoreDash := Nil
FreeObj( oCoreDash )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RetCardInfo
Retorna os dados que poderão ser apresentados no Card

@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function RetCardInfo( oResponse, cWhere, aFilter )

    Local item      := {}
    Local aItems    := {}

    item := JsonObject():New()

    If Len(aFilter) > 0
      cWhere += " AND '" + dtos(ddatabase) + "' > B8_DTVALID "
      item["produto"]  :=	RetLotVen(" COUNT(distinct B8_PRODUTO) lotes ", " WHERE " + cWhere + " AND  D_E_L_E_T_ = ' ' ")
      item["lote"]     :=	RetLotVen(" COUNT(B8_LOTECTL) lotes ", " WHERE " + cWhere + " AND  D_E_L_E_T_ = ' ' ")
    Else
      cWhere += " SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND '" + dtos(ddatabase) + "' > B8_DTVALID  AND  D_E_L_E_T_ = ' ' "
      item["produto"]  :=	RetLotVen(" COUNT(distinct B8_PRODUTO) lotes  "," WHERE " + cWhere + " ")
      item["lote"]     :=	RetLotVen(" COUNT(B8_LOTECTL) lotes "," WHERE " + cWhere + " ")
    EndIf

    AADD(aItems, item)

    item := {}

    oResponse['hasNext'] := 'false'
    oResponse["items"]   := aItems

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET fieldsInfo
Carrega os campos que podem que ser utilizados

@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET fieldsInfo WSSERVICE CardEst02

    Local aItems    := {}
    Local item      := {}
    Local oResponse	:= JsonObject():New()

    item := JsonObject():New()
    item["label"] :=	STR0008 //"Quantidade de Produtos: "
    item["value"] :=	"produto"

    AADD(aItems, item)

    item := JsonObject():New()
    item["label"] :=	STR0009 //"Lotes Vencidos: "
    item["value"] :=	"lote"

    AADD(aItems, item)

    oResponse["items"]  := aItems

    Self:SetResponse( FwHttpEncode(oResponse:ToJson()))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RetTotPed
Monta a query que será utilizada para retornar as informações

@author Adriano Vieira
@since 20/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function RetLotVen(cSelect, cWhere)
  Local aQuery  := MntQuery2(cSelect,cWhere)
  Local cQuery  := ""
  Local cTemp   := GetNextAlias()
  Local xRet    := ''
  Local nRet    := ''

  Default cWhere  := " WHERE "

  cQuery := aQuery[1] + aQuery[2]

  DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .F., .T. )

  While (cTemp)->( !Eof() )
    xRet :=	(cTemp)->lotes
    nRet := Alltrim(Transform(xRet,'@E 9,999,999,999'))
    (cTemp)->(DbSkip())
  EndDo

  (cTemp)->( DBCloseArea() )

Return nRet
