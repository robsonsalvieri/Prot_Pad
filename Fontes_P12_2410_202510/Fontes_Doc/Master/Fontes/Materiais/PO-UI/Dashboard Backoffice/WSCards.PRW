#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSCARDS.CH"

/*/{Protheus.doc} Cards
  API Cadastro de Cards do Dashboard
  @author		Squad CRM/Faturamento
  @since		07/04/2020
/*/
WSRESTFUL Cards DESCRIPTION STR0001 // "Cards Dashboard Protheus"
  WSDATA IDCard AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize		AS INTEGER	OPTIONAL

  WSMETHOD GET tps ;
  DESCRIPTION STR0002; //"Retorna os Tipos de Painéis Cadastrados"
  WSSYNTAX "/cards/cards/" ;
  PATH "/cards/cards/";
  PRODUCES APPLICATION_JSON

  WSMETHOD GET tp ;
  DESCRIPTION STR0002; // "Retorna um Painel Específico"
  WSSYNTAX "/cards/cards/{IDCard}" ;
  PATH "/cards/cards/{IDCard}";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST tp ;
  DESCRIPTION STR0004; // "Insere um novo Painel"
  WSSYNTAX "/cards/cards/" ;
  PATH "/cards/cards/"

  WSMETHOD PUT tp ;
  DESCRIPTION STR0005; //"Altera um novo Painel"
  WSSYNTAX "/cards/cards/{IDCard}" ;
  PATH "/cards/cards/{IDCard}"


  WSMETHOD DELETE tp ;
  DESCRIPTION STR0006; // "Exclui um Painel"
  WSSYNTAX "/cards/cards/{IDCard}" ;
  PATH "/cards/cards/{IDCard}"

ENDWSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} GET FatReg
  Retorna os dados do Gráfico
  @author Nairan Alves/Débora Constantino
  @since 27/03/2020
  @version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET tps WSRECEIVE JsonFilter WSSERVICE Cards
  Local aRet        := {}
  Local cError		  := STR0007 // "Erro na Requisição"
	Local lRet			  := .T.
  Local oCoreDash  := CoreDash():New()

  A1N->(GetArea())
  A1O->(GetArea())
  A1P->(GetArea())
  A1Q->(GetArea())
  A1R->(GetArea())

  If Len(Self:aQueryString) == 0
    oCoreDash:SetPageSize(500)
  Endif
  
  Self:SetContentType("application/json")

  oCoreDash:SetFields(DePara())
  oCoreDash:SetApiQstring(Self:aQueryString)

  MntQuery(@oCoreDash)

  lRet := oCoreDash:BuildJson()

	If lRet
		Self:SetResponse( oCoreDash:ToObjectJson())
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault(404, FWhttpEncode(cError) )
	EndIf

	oCoreDash:Destroy()
  FreeObj(aRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET tp
Retornar apenas um tipo de Painel

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET tp WSRECEIVE IDCard WSSERVICE Cards
  Local aRet        := {}
  Local aFilter     := {}
  Local cError		  := STR0007 // "Erro na Requisição"
	Local lRet			  := .T.
  Local oCoreDash  := CoreDash():New()

  Self:SetContentType("application/json")

  oCoreDash:SetFields(DePara())
  oCoreDash:SetApiQstring(Self:aQueryString)

  aAdd(aFilter, {" A1O.A1O_ID = '" + self:IDCard + "' " })

  oCoreDash:SetApiFilter(aFilter)

  aRet := MntQuery(@oCoreDash)

  lRet := oCoreDash:BuildJson()

	If lRet
		Self:SetResponse( oCoreDash:ToSingleObject())
	Else
		SetRestFault(500, FWhttpEncode(cError) )
	EndIf

	oCoreDash:Destroy()
  FreeObj(aRet)

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
    {"title"          , "A1O_TITULO"  },;
    {"more"           , "A1O_DETALH"  },;
    {"info1"          , "A1O_INFO1 "  },;
    {"info2"          , "A1O_INFO2 "  },;
    {"info3"          , "A1O_INFO3 "  },;
    {"info4"          , "A1O_INFO4 "  },;
    {"fields"         , "A1O_CAMPOS"  },;
    {"expFilter"      , "A1O_EXPFIL"  },;
    {"endPointFilter" , "A1O_ENDFIL"  },;
    {"status"         , "A1O_STATUS"  },;
    {"typecardId"     , "A1O_IDTIPO"  },;
    {"label1"         , "A1O_LABEL1"  },;
    {"label2"         , "A1O_LABEL2"  },;
    {"label3"         , "A1O_LABEL3"  },;
    {"label4"         , "A1O_LABEL4"  },;
    {"id"             , "A1O_ID    "  },;
    {"displayFilter"  , "A1O_FILTRO"  },;
    {"helpCard"       , "A1O_HELP"    };
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
Static Function MntQuery(oCoreDash)

  //Local cQuery  := ""
  Local cWhere    := ""
  Local cFrom     := ""
  Local nFiltro   := 0
  Local cAliasQry := GetNextAlias()

  cSelect := "% A1O_FILIAL,A1O_TITULO ,A1O_DETALH,A1O_INFO1 ,A1O_INFO2 ,A1O_INFO3 ,A1O_INFO4 ,A1O_CAMPOS,A1O_EXPFIL,A1O_ENDFIL,A1O_STATUS,A1O_IDTIPO,A1O_LABEL1,A1O_LABEL2,A1O_LABEL3,A1O_LABEL4,A1O_ID,A1O_FILTRO, A1O_HELP %"
  cFrom  := "%" + RetSqlName("A1O") + " A1O " + "%"
  cWhere := " A1O.D_E_L_E_T_ = ' ' AND A1O.A1O_FILIAL = '" + xFilial("A1O") + "' "
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

  oCoreDash:SetTable(cAliasQry)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Post tp
Realiza a inclusão de um Painel

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST tp WSSERVICE Cards
	Local cBody 	  	:= Self:GetContent()
	Local lRet        := .T.
  Local oCoreDash  := CoreDash():New()

  oCoreDash:SetFields(DePara())
  lRet := oCoreDash:SetUpsertData("A1O", Nil, cBody)

  If lRet
    self:IDCard := A1O->A1O_ID
    self:GET_TP('000000')
  Else
    SetRestFault( 500, FWhttpEncode(STR0008) ) // "Falha ao converter o arquivo."
  Endif

  oCoreDash:Destroy()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET tp
Retornar apenas um tipo de Painel

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD PUT tp WSRECEIVE IDCard WSSERVICE Cards
	Local cBody 	  	:= Self:GetContent()
	Local lRet        := .F.
  Local oCoreDash  := CoreDash():New()

  Default self:IDCard := ""

  If !Empty(self:IDCard)
    oCoreDash:SetFields(DePara())
    lRet := oCoreDash:SetUpsertData("A1O", xFilial("A1O") + self:IDCard, cBody)
  EndIf

  If lRet
    self:GET_TP()
  Else
    SetRestFault( 500, FWhttpEncode(STR0008) ) // "Falha ao converter o arquivo."
  Endif

  oCoreDash:Destroy()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE tp
Deleta um Gráfico

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE tp WSRECEIVE IDCard WSSERVICE Cards
	Local lRet        := .F.
  Local lVldDel     := .T.
  Local oJsonPositions:= JsonObject():New()

  Default self:IDCard := ""

  If !Empty(self:IDCard)
    A1O->(DbSetOrder(1))
    If A1O->(DbSeek(xFilial("A1O") + self:IDCard))
      A1R->(DbSetOrder(1))
      A1R->(DbGoTop())
        While A1R->(!EOF())
          If self:IDCard $ A1R->A1R_CARDS
            lVldDel := .F.
            Exit
          Endif
          A1R->(DbSkip())
        EndDo

        If lVldDel
          lRet := .T.
          A1O->(RecLock("A1O", .F.))
          A1O->(DbDelete())
          A1O->(MsUnLock())
        Endif
        
    EndIf
  EndIf

  If lRet
		oJsonPositions['response'] := FWhttpEncode("Id " + self:IDCard + " " + STR0010) // " excluído com sucesso."
		Self:SetResponse( oJsonPositions:ToJson() )
  Else
    SetRestFault( 500, FWhttpEncode(STR0009) ) // "Card não pode ser deletado."
  Endif

Return lRet
