#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSCHARTS.CH"

/*/{Protheus.doc} Charts
  API Cadastro de Gráficos do Dashboard
  @author		Squad CRM/Faturamento
  @since		07/04/2020
/*/
WSRESTFUL Charts DESCRIPTION STR0001 // "Charts Dashboard Protheus"
  WSDATA IDChart  AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL

  WSMETHOD GET tgs ;
  DESCRIPTION STR0002;  // "Retorna todos os Gráficos"
  WSSYNTAX "/Charts/Charts/" ;
  PATH "/Charts/Charts/";
  PRODUCES APPLICATION_JSON

  WSMETHOD GET tg ;
  DESCRIPTION STR0003; // "Retorna um gráfico Específico"
  WSSYNTAX "/Charts/Charts/{IDChart}" ;
  PATH "/Charts/Charts/{IDChart}";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST tg ;
  DESCRIPTION STR0004; // "Insere um novo gráfico"
  WSSYNTAX "/Charts/Charts/" ;
  PATH "/Charts/Charts/"

  WSMETHOD PUT tg ;
  DESCRIPTION STR0005; //"Altere um gráfico"
  WSSYNTAX "/Charts/Charts/{IDChart}" ;
  PATH "/Charts/Charts/{IDChart}"

  WSMETHOD DELETE tg ;
  DESCRIPTION STR0006; // "Deleta um gráfico"
  WSSYNTAX "/Charts/Charts/{IDChart}" ;
  PATH "/Charts/Charts/{IDChart}"
ENDWSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} GET FatReg
  Retorna os dados do Gráfico
  @author Nairan Alves/Débora Constantino
  @since 27/03/2020
  @version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET tgs WSRECEIVE JsonFilter WSSERVICE Charts
  Local cError		  := STR0007 // "Erro na Requisição"
	Local lRet			  := .T.
  Local oCoreDash   := CoreDash():New()
  Local oResponse		:= JsonObject():New()
  Local nPage       := 0
  Local nPageSize   := 0
  Local nPos        := 0

  If Len(Self:aQueryString) == 0
    oCoreDash:SetPageSize(500)
  Endif

  Self:SetContentType("application/json")

  oCoreDash:SetFields(DePara())
  oCoreDash:SetApiQstring(Self:aQueryString)

  If Len(oCoreDash:GetAPIFilter()) == 0

    nPos  := aScan(Self:aQueryString, {|x| Upper(x[1]) == "PAGE" })
    If nPos > 0
      nPage := self:aQueryString[nPos][2]
    Endif

    nPos      := aScan(Self:aQueryString, {|x| Upper(x[1]) == "PAGESIZE" })
    If nPos > 0
      nPageSize := self:aQueryString[nPos][2]
    Endif
  EndIf

  MntQuery(@oCoreDash, @oResponse, .T.,nPage,nPageSize)

	If lRet
		Self:SetResponse( FWhttpEncode(oResponse:ToJson()))
	Else
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

	oCoreDash:Destroy()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET tg
  Retornar apenas um tipo de Painel
  @author Nairan Alves/Débora Constantino
  @since 27/03/2020
  @version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET tg WSRECEIVE IDChart WSSERVICE Charts
  Local aFilter     := {}
  Local cError		  := STR0007 // "Erro na Requisição"
	Local lRet			  := .T.
  Local oCoreDash  := CoreDash():New()
  Local oResponse		:=	JsonObject():New()

  Self:SetContentType("application/json")

  aAdd(aFilter, {" A1Q.A1Q_ID = '" + self:IDChart + "' " })

  oCoreDash:SetApiFilter(aFilter)
  oCoreDash:SetFields(DePara())
  oCoreDash:SetApiQstring(Self:aQueryString)

  MntQuery(@oCoreDash, @oResponse, .F.)

	If lRet
		Self:SetResponse( EncodeUtf8(oResponse:ToJson()))
	EndIf

	oCoreDash:Destroy()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DePara
Realiza o De/Para entre os objetos do Json e os campos do Protheus

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function DePara()
  Local aCampos := {}

  aCampos := {;
    {"typechartId"    , "A1Q_IDTIPO " },;
    {"id"             , "A1Q_ID "     },;
    {"title"          , "A1Q_TITULO"  },;
    {"helpChart"      , "A1Q_HELP"    };
  }
Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} MntQuery
Monta a query responsável por trazer os itens utilizados no Painel

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MntQuery(oCoreDash, oResponse, lItems,nPage,nPageSize)
  Local aFilter   := ""
  Local aItems    := {}
  Local cAliasQry := GetNextAlias()
  Local cFrom     := ""
  Local cSelect   := ""
  Local cWhere    := ""
  Local nFiltro   := 0
  Local nCount    := 0
  Local oitem := JsonObject():New()
  Local lRetRest  := .T. 

  Default lItems    := .T.
  Default nPage     := 0
  Default nPageSize := 0

  cSelect := "% A1Q.R_E_C_N_O_ RECNOA1Q %"

  cFrom  := "%" + RetSqlName("A1Q") + " A1Q " + "%"

  cWhere := " A1Q.D_E_L_E_T_ = ' ' AND A1Q.A1Q_FILIAL = '" + xFilial("A1Q") + "' "

  aFilter := oCoreDash:GetApiFilter()

  For nFiltro := 1 to Len(aFilter)
    cWhere += " AND " + aFilter[nFiltro][1]
  Next

  cWhere := "%" + cWhere + "%"

	BeginSQL Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%
	EndSQL

  If nPage > 1
    nStart := ( (nPage-1) * nPageSize )
    If nStart > 0
      (cAliasQry)->( DbSkip( nStart ) )
    EndIf
  EndIf

  While (cAliasQry)->(!EOF())
    nCount++
    A1Q->(DbGoTo((cAliasQry)->RECNOA1Q))
    oitem := JsonObject():New()
    oitem:FromJSON( A1Q->A1Q_JSON )

    AADD(aItems, oitem)

    (cAliasQry)->(DbSkip())

    If nCount == nPageSize
      EXIT
    EndIf

  EndDo

  If (cAliasQry)->(Eof())
    lRetRest := .F.
  EndIf

  If lItems
    oResponse['items'] := aItems
    oResponse['hasNext'] := lRetRest
  Else
    oResponse := oitem
  EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Post tg
Realiza a inclusão de um Painel

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST tg WSSERVICE Charts

	Local cBody 	  	:= Self:GetContent()
	Local lRet        := .T.
  Local oCoreDash  := CoreDash():New()
  Local oJson       := JsonObject():new()

  oCoreDash:SetFields(DePara())
  lRet := oCoreDash:SetUpsertData("A1Q", Nil, cBody)

  If lRet
    If A1Q->(DbSeek(xFilial("A1Q") + A1Q->A1Q_ID))
      oJson:fromJson(cBody)
      oJson['id'] := A1Q->A1Q_ID
      RecLock("A1Q",.F.)
        A1Q->A1Q_JSON := DecodeUtf8(oJson:toJson())
      A1Q->(MsUnlock())
    EndIf
    self:IDChart := A1Q->A1Q_ID
    self:GET_tg()
  Else
    SetRestFault( 500, FWhttpEncode(STR0008) ) // "Falha ao converter o arquivo."
  Endif

  oCoreDash:Destroy()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET tg
Retornar apenas um tipo de Painel

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD PUT tg WSRECEIVE IDChart WSSERVICE Charts
	Local cBody 	  	:= Self:GetContent()
	Local lRet        := .F.
  Local oCoreDash   := CoreDash():New()
  Local oJson       := JsonObject():new()
  Local oA1QJson    := JsonObject():new()

  Default self:IDChart := ""

  If !Empty(self:IDChart)
    oCoreDash:SetFields(DePara())
    lRet := oCoreDash:SetUpsertData("A1Q", xFilial("A1Q") + self:IDChart, cBody)
  EndIf

  If lRet
    If A1Q->(DbSeek(xFilial("A1Q") + self:IDChart))
      oJson:fromJson(cBody)
      If oJson:GetJsonObject('title') != Nil
        oJson['id'] := A1Q->A1Q_ID
        RecLock("A1Q",.F.)
          A1Q->A1Q_JSON := A1Q->A1Q_JSON := DecodeUtf8(oJson:toJson())
        A1Q->(MsUnlock())
      Elseif oJson:GetJsonObject('status') != Nil
        oA1QJson:FromJson(A1Q->A1Q_JSON)
        oA1QJson['status'] := oJson:GetJsonObject('status')
        RecLock("A1Q",.F.)
          A1Q->A1Q_JSON := oA1QJson:toJson()
        A1Q->(MsUnlock())
      EndIf
    EndIf
    self:GET_tg()
  Else
    SetRestFault( 500, FWhttpEncode(STR0008) ) // "Falha ao converter o arquivo."
  Endif

  oCoreDash:Destroy()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE tg
Deleta um Gráfico

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE tg WSRECEIVE IDChart WSSERVICE Charts
	Local lRet        := .F.
  Local lVldDel     := .T.
  Local oJsonPositions:= JsonObject():New()

  Default self:IDChart := ""

  If !Empty(self:IDChart)
    A1Q->(DbSetOrder(1))
    If A1Q->(DbSeek(xFilial("A1Q") + self:IDChart))
      A1R->(DbSetOrder(1))
      A1R->(DbGoTop())
        While A1R->(!EOF())
          If self:IDChart $ A1R->A1R_CHARTS
            lVldDel := .F.
            Exit
          Endif
          A1R->(DbSkip())
        EndDo

      If lVldDel
        lRet := .T.
        A1Q->(RecLock("A1Q", .F.))
        A1Q->(DbDelete())
        A1Q->(MsUnLock())
      Endif
    EndIf
  EndIf

  If lRet
		oJsonPositions['response'] := FWhttpEncode("Id " + self:IDChart + " "  + STR0009) //"excluído com sucesso."
		Self:SetResponse( oJsonPositions:ToJson() )
  Else
    SetRestFault( 500, FWhttpEncode(STR0010) ) // "Gráfico não pode ser deletado."
  Endif

Return lRet
