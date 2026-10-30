#INCLUDE "TOTVS.CH"'
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSUSUARIOS.CH"

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} DashUsers
  API Cadastro de Usuários do Dashboard
  @author	    Squad CRM/Faturamento
  @since	    23/07/2020
  @version	  12.1.27
/*/
//-----------------------------------------------------------------------------------
WSRESTFUL DashUsers DESCRIPTION STR0001 FORMAT APPLICATION_JSON // "Consulta de usuarios do dashboard"
  WSDATA Fields			    AS STRING	 OPTIONAL
  WSDATA Order			    AS STRING	 OPTIONAL
  WSDATA Page				    AS INTEGER OPTIONAL
  WSDATA PageSize			  AS INTEGER OPTIONAL
  WSDATA UserId         AS STRING	 OPTIONAL
  WSDATA aQueryString		AS ARRAY	 OPTIONAL
  WSDATA cGroup         AS ARRAY   OPTIONAL

  WSMETHOD GET Main ;
    DESCRIPTION STR0002;// "Retorna uma lista de todos os usuarios."
    WSSYNTAX "/DashUsers/{Order, Page, PageSize, Fields}" ;
    PATH "/DashUsers/" ;
    PRODUCES APPLICATION_JSON

  WSMETHOD GET UserId ;
    DESCRIPTION STR0003; //"Retorna um usuario especifico"
    WSSYNTAX "/DashUsers/{UserId}{Fields}" ;
    PATH "/DashUsers/{UserId}" ;
    PRODUCES APPLICATION_JSON

  WSMETHOD GET Groups ;
    DESCRIPTION STR0004; // "Retorna uma de todos os grupos."
    WSSYNTAX "/DashUsers/dashGroups/{cGroup}" ;
    PATH "/DashUsers/dashGroups/" ;
    PRODUCES APPLICATION_JSON

  WSMETHOD GET IdGroup ;
    DESCRIPTION STR0005; // "Retorna uma de todos os grupos."
    WSSYNTAX "/DashUsers/dashGroups/{cGroup}" ;
    PATH "/DashUsers/dashGroups/{cGroup}" ;
    PRODUCES APPLICATION_JSON

ENDWSRESTFUL

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GET /dashUsers/
  Retorna uma lista com todos os usuarios
  @param	Order		, Caractere , Ordenação da tabela principal
  @param	Page		, Numérico  , Número da página inicial da consulta
  @param	PageSize	, Numérico  , Número de registro por páginas
  @param	Fields		, Caractere , Campos que serão retornados no GET.
  @return lRet	    , Lógico    , Informa se o processo foi executado com sucesso.
  @author Squad Faturamento/CRM
  @since  10/06/2020
  @version	12.1.27
/*/
//-----------------------------------------------------------------------------------
WSMETHOD GET Main WSRECEIVE cRetUser, Page, PageSize, Fields WSSERVICE DashUsers
  Local oResponse	:= JsonObject():New()

  GetUser(@oResponse, cRetUser)

  self:SetResponse(ProcResp(@oResponse))

  oResponse := Nil
  FreeObj( oResponse )
Return .T.

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GET /dashUsers/
Retorna um ID especifico de um usuario

@author Squad Faturamento/CRM
@since  25/09/2020
@version	12.1.27
/*/
//-----------------------------------------------------------------------------------
WSMETHOD GET UserId PATHPARAM UserId WSRECEIVE Order, Page, PageSize, Fields WSSERVICE DashUsers
  Local oResponse	:=	JsonObject():New()
  GetUser(@oResponse, Self:UserId)

  self:SetResponse(ProcResp(@oResponse))

  oResponse := Nil
  FreeObj( oResponse )
Return .T.

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} Function GetUser
Retorna um ID ou um Grupo de usuarios

@author Squad Faturamento/CRM
@since  25/09/2020
@version	12.1.27
/*/
//-----------------------------------------------------------------------------------
Static Function GetUser( oResponse, cRetUser ) as Logical
  Local aUsers    := {}
  Local aItems    := {}
  Local lRet      := .T.
  Local nAllUsers := 0
  Local nUser     := 0
  Local nLenUsers := 1
  Local oUser
  Local cCodUser  := RetCodUsr(cUserName)
  Local lRetUser  := Iif( cRetUser != Nil, Empty(cRetUser), .T. )

  If lRetUser
    aUsers    := FwsfAllUsers( cRetUser, {"USR_NOME", "USR_MSBLQL"}, , , .T.)
    nLenUsers := Len(aUsers)
    nAllUsers := Len(aUsers[1])
  Endif

  For nUser := 1 To nLenUsers
    oUser   := JsonObject():New()
    If nAllUsers > 0
      If aUsers[nUser][4] != '1'
        If lRetUser
          oUser["id"]       := aUsers[nUser, 2]
          oUser["userName"] := RTrim(aUsers[nUser, 3])
          AADD(aItems, oUser)
        Endif
      Endif
    Else
      If !lRetUser
        oUser["id"]       := cCodUser
        oUser["userName"] := cUserName
        oUser["isAdmin"]  := FwIsAdmin()
        AADD(aItems, oUser)
      Endif
    Endif
  Next

  If lRetUser
    oResponse['hasNext']  := 'false'
    oResponse["items"]    := aItems
  Else
    oResponse := oUser
  Endif

  If Valtype(aUsers) == "A"
    aSize(aUsers, 0)
  Endif
Return lRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GET /dashUser/dashGroups/
Retorna todos os Grupos de Usuário do sistema

@param	Order		, Caractere , Ordenação da tabela principal
@param	Page		, Numérico  , Número da página inicial da consulta
@param	PageSize	, Numérico  , Número de registro por páginas
@param	Fields		, Caractere , Campos que serão retornados no GET.
@return lRet	    , Lógico    , Informa se o processo foi executado com sucesso.
@author Squad Faturamento/CRM
@since  10/06/2020
@version	12.1.27
/*/
//-----------------------------------------------------------------------------------
WSMETHOD GET Groups WSRECEIVE cGroup WSSERVICE DashUsers
  Local oResponse	:=	JsonObject():New()
  GetGroups(@oResponse, Self:cGroup)

  self:SetResponse(ProcResp(@oResponse))

  oResponse := Nil
  FreeObj( oResponse )
Return .T.

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GET /dashUser/dashGroups/
Retorna o ID de um Usuário especifico do sistema

@author Francisco Oliveira
@since  25/09/2020
@version	12.1.27
/*/
//-----------------------------------------------------------------------------------
WSMETHOD GET IdGroup WSRECEIVE cGroup WSSERVICE DashUsers
  Local oResponse	:=	JsonObject():New()
  GetGroups(@oResponse, Self:cGroup)

  self:SetResponse(ProcResp(@oResponse))

  oResponse := Nil
  FreeObj( oResponse )
Return .T.

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} Function GetGroups
Retorna um ID ou um Grupo de usuarios

@author Squad Faturamento/CRM
@since  25/09/2020
@version	12.1.27
/*/
//-----------------------------------------------------------------------------------
Static Function GetGroups( oResponse, cRetGroup ) as Logical
  Local lRetGroup := Iif( cRetGroup != Nil, Empty(cRetGroup), .T. )
  Local aGroups   := {}
  Local aItems    := {}
  Local lRet      := .T.
  Local nGroups   := 0
  Local oGroups

  If lRetGroup
    aGroups     := FWSFAllGrps()
    nLenGroups  := Len(aGroups)
  Else
    aGroups     := UsrRetGrp(cRetGroup)
    nLenGroups  := Len(aGroups)
  Endif
 
  For nGroups := 1 To nLenGroups
    oGroups := JsonObject():New()
    If lRetGroup
      oGroups["id"]         := aGroups[nGroups, 2]
      oGroups["groupName"]  := RTrim(aGroups[nGroups, 3])
    Else
      oGroups["id"] := aGroups[nGroups]
    Endif
    AADD(aItems, oGroups)
  Next

  oResponse['hasNext']  := 'false'
  oResponse["items"]    := aItems

  aSize(aGroups, 0)
Return lRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} Function ProcResp
Processa a resposta antes de enviar 

@author Squad Faturamento/CRM
@since  11/05/2022
@version	12.1.33
/*/
//-----------------------------------------------------------------------------------
Static Function ProcResp( oResponse ) as String
  Local cResponse	:= NIL
  
  cResponse := FWhttpEncode(oResponse:ToJson())
  cResponse := IIF(cResponse == NIL, oResponse:ToJson(), cResponse) 

Return cResponse