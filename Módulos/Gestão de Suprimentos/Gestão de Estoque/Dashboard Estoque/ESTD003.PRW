#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "ESTD003.CH"

/*/{Protheus.doc} CardEst03

API Card de Itens a Enderecar

@author		Adriano Vieira
@since		14/12/2020
/*/
WSRESTFUL CardEst03 DESCRIPTION OemToAnsi(STR0012) //"Card Itens a Enderecar"
	WSDATA Fields			AS STRING   OPTIONAL
	WSDATA Order			AS STRING	  OPTIONAL
	WSDATA Page				AS INTEGER  OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL
	WSDATA Code       AS STRING 	OPTIONAL

    WSMETHOD POST itemsDetails ;
    DESCRIPTION OemToAnsi(STR0013)  ; //"Carrega os Itens Utilizados para Montagem do Painel"
    WSSYNTAX "/cards/itemsDetails/{Order, Page, PageSize, Fields}" ;
    PATH "/cards/itemsDetails";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET headerItens ;
    DESCRIPTION OemToAnsi(STR0014)  ; //"Carrega o Cabecalho a ser apresentado nos detalhes"
    WSSYNTAX "/cards/headerItens/" ;
    PATH "/cards/headerItens";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET cardInfo ;
    DESCRIPTION OemToAnsi(STR0015)  ; //"Carrega as informacoes do Painel"
    WSSYNTAX "/cards/cardInfo/" ;
    PATH "/cards/cardInfo";
    PRODUCES APPLICATION_JSON

    WSMETHOD GET fieldsInfo ;
    DESCRIPTION OemToAnsi(STR0016)  ; //"Carrega os campos que podem que ser utilizados"
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
WSMETHOD POST itemsDetails WSRECEIVE Order, Page, PageSize, Fields WSSERVICE CardEst03

  Local aHeader     := {}
  Local aRet        := {}
  Local aFilter     := {}
  Local nFiltro     := 0
  Local cWhere      := ""
  Local cError      := STR0001 //"Erro na Requisicão"
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
Monta a query responsavel por trazer os itens utilizados no Detalhes do Card

@param oCoreDash, objeto, Objeto responsavel pela montagem do json
@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQuery(  cWhere, aFilter )
  Local cQuery  := ""
  Local cSelect := " SDA.DA_PRODUTO, SB1.B1_DESC, SDA.DA_LOCAL, SDA.DA_SALDO, SDA.DA_LOTECTL, SDA.DA_DOC, SDA.DA_DATA "
  Local cInner  := " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SDA.DA_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ' "
  Local cFilJoinSB1   := ""
  Local nTamFilSB1 := Len(AllTrim(FWxFilial('SB1')))
  Local nTamFilSDA := Len(AllTrim(FWxFilial('SDA')))

  Default cWhere  := ""

  If (nTamFilSB1 == nTamFilSDA) // filiais com mesmo compartilhamento
    cFilJoinSB1 := "  AND SDA.DA_FILIAL = SB1.B1_FILIAL  "
    cInner      += cFilJoinSB1
  EndIf  

  If Len(aFilter) > 0

    cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SDA") + " SDA " + cInner
    cWhere := " " + cWhere + " AND SDA.DA_SALDO > '0' AND SDA.D_E_L_E_T_ = ' ' "

  Else

    cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SDA") + " SDA " + cInner
    cWhere += " SDA.DA_FILIAL = '" + xFilial("SDA") + "'   "
    cWhere += " AND SDA.DA_SALDO > '0' AND  SDA.D_E_L_E_T_ = ' '  "

  EndIf

Return {cQuery, cWhere}

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQuery2
Monta a query responsavel por trazer as informacoes principais do card

@param oCoreDash, objeto, Objeto responsavel pela montagem do json
@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQuery2(cSelect,cWhere)
  Local cQuery  := ""
  
  Default cWhere  := " SDA.DA_FILIAL = '" + xFilial("SDA") + " ' AND  SDA.DA_SALDO > '0'  AND  SDA.D_E_L_E_T_ = ' ' "
  Default cSelect := " COUNT(DA_DOC) prod "

  cQuery += " SELECT " + cSelect + " FROM " + RetSqlName("SDA") + " SDA "

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
    {"filial"   , "SDA.DA_FILIAL"   },; 
    {"produto"  , "SDA.DA_PRODUTO"  },; 
    {"desc"     , "SB1.B1_DESC"     },; 
    {"local"    , "SDA.DA_LOCAL"    },; 
    {"saldo"    , "SDA.DA_SALDO"    },;
    {"lote"     , "SDA.DA_LOTECTL"  },;
    {"doc"      , "SDA.DA_DOC"      },;
    {"data"     , "SDA.DA_DATA"     };
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

aHeader := {;
        {"produto"  , STR0002,,,.T.,.T. },;
        {"desc"     , STR0009,,,.T.,.F. },;
        {"local"    , STR0003,,,.T.,.T. },;
        {"saldo"    , STR0010,,,.T.,.F. },;
        {"lote"     , STR0011,,,.T.,.F. },;
        {"doc"      , STR0004,,,.T.,.T. },;
        {"data"	    , STR0005           };
      }

Return aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} GET headerItens
Retorna o aHeader que sera utilizado no detalhamento do Card

@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET headerItens WSSERVICE CardEst03

  Local aHeader     := {}
  Local oCoreDash   := CoreDash():New()
  Local oResponse		:= JsonObject():New()

  aHeader := {;
    {"filial"    , STR0006  },;
    {"produto"   , STR0002  },;
    {"local"     , STR0003  },;
    {"doc"       , STR0004  };
  }

  oResponse["items"] := oCoreDash:SetPOHeader(aHeader)

  Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET cardInfo
Metodo para retornar os dados do Card

@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET cardInfo WSRESTFUL CardEst03

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
FWLsPutAsyncInfo("LS006",RetCodUsr(),"04","ESTD003")

oResponse := Nil
FreeObj( oResponse )
oCoreDash := Nil
FreeObj( oCoreDash )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GET RetCardInfo
Retorna os dados que poderão ser apresentados no Card

@author Adriano Vieira
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function RetCardInfo( oResponse, cWhere, aFilter )

    Local item      := {}
    Local aItems    := {}

    Default cWhere  := " "

    item := JsonObject():New()

    If Len(aFilter) > 0
      item["Docs"]    :=	RetSldEnd(" COUNT(DA_DOC) prod ", " WHERE " + cWhere + " AND  SDA.DA_SALDO > '0'  AND  DA_DOC <> ''  AND  D_E_L_E_T_ = ' ' ")
      item["QtdProd"] :=	RetSldEnd(" COUNT(DA_PRODUTO) prod ", " WHERE " + cWhere + " AND  SDA.DA_SALDO > '0'  AND  D_E_L_E_T_ = ' ' ")
    Else
      cWhere := " SDA.DA_FILIAL = '" + xFilial("SDA") + "'  AND  SDA.DA_SALDO > '0'  AND  D_E_L_E_T_ = ' ' "
      item["Docs"]    :=	RetSldEnd(" COUNT(DA_DOC) prod  "," WHERE " + cWhere + " AND  DA_DOC <> '' ")
      item["QtdProd"] :=	RetSldEnd(" COUNT(DA_PRODUTO) prod "," WHERE " + cWhere + " ")
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
@since 14/12/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET fieldsInfo WSSERVICE CardEst03

    Local aItems    := {}
    Local item      := {}
    Local oResponse	:= JsonObject():New()

    item := JsonObject():New()
    item["label"] :=	STR0007 //"Quantidade de Documentos: "
    item["value"] :=	"Docs"

    AADD(aItems, item)
    item := JsonObject():New()
    item["label"] :=	STR0008 //"Quantidade de Produtos: "
    item["value"] :=	"QtdProd"

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
Static Function RetSldEnd(cSelect, cWhere)
  Local aQuery  := MntQuery2(cSelect,cWhere)
  Local cQuery  := ""
  Local cTemp   := GetNextAlias()
  Local xRet    := ''
  Local nRet    := ''

  Default cWhere  := " WHERE "

  cQuery := aQuery[1] + aQuery[2]

  DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTemp, .F., .T. )

  While (cTemp)->( !Eof() )
    xRet :=	(cTemp)->prod
    nRet := Alltrim(Transform(xRet,'@E 9,999,999,999'))
    (cTemp)->(DbSkip())
  EndDo

  (cTemp)->( DBCloseArea() )

Return nRet
