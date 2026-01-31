#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSVISIONS.CH"

/*/{Protheus.doc} Visions

API Cadastro de Visões do Dashboard

@author		Squad CRM/Faturamento
@since		07/04/2020
/*/
WSRESTFUL Visions DESCRIPTION STR0001// "Visões do Dashboard Backoffice"
  WSDATA IDVision   AS STRING	OPTIONAL
	WSDATA Page				AS INTEGER OPTIONAL
	WSDATA PageSize		AS INTEGER OPTIONAL

  WSMETHOD GET tvs ;
  DESCRIPTION STR0002; // "Retorna Todas as Visões"
  WSSYNTAX "Visions/Visions/{Page,PageSize}" ;
  PATH "Visions/Visions/";
  PRODUCES APPLICATION_JSON

  WSMETHOD GET tv ;
  DESCRIPTION STR0003; // "Retorna uma Visão específica"
  WSSYNTAX "Visions/Visions/{IDVision}" ;
  PATH "Visions/Visions/{IDVision}";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST tv ;
  DESCRIPTION STR0004; //"Insere uma Visão"
  WSSYNTAX "Visions/Visions/" ;
  PATH "Visions/Visions/"

  WSMETHOD PUT tv ;
  DESCRIPTION STR0005; // "Altera uma Visão"
  WSSYNTAX "Visions/Visions/{IDVision}" ;
  PATH "Visions/Visions/{IDVision}"

  WSMETHOD DELETE tv ;
  DESCRIPTION STR0006;// "Deleta uma Visão"
  WSSYNTAX "Visions/Visions/{IDVision}" ;
  PATH "Visions/Visions/{IDVision}"

ENDWSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} GET tvs
Retorna Todas as Visões

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET tvs WSRECEIVE JsonFilter, Page, PageSize WSSERVICE Visions
  Local aRet        := {}
  Local cError		  := STR0007 // "Erro na Requisição"
  Local cGroup      := ""
  Local cUser       := ""
  Local cStatus     := ""
	Local cWhere      := ""
  Local lRet			  := .T.
  Local nFilter     := 0
  Local nLenGroups  := 0
  Local nGroups     := 0
  Local oCoreDash  := CoreDash():New()

  Self:SetContentType("application/json")

  For nFilter := 1 To Len (Self:aQueryString)
    If UPPER(self:aQueryString[nFilter][1]) == "EQ_GROUPS" .And. !Empty(self:aQueryString[nFilter][2])
      aGroups := StrTokArr(self:aQueryString[nFilter][2], ",")
      nLenGroups := Len(aGroups)
      cGroup +=  " (
      For nGroups := 1 to nLenGroups
        cGroup +=  "  A1R_GRUPOS LIKE '%"+aGroups[nGroups]+"%' "
        If nGroups != nLenGroups
          cGroup +=  " OR "
        EndIf
      Next
      cGroup +=  " )
    ElseIf UPPER(self:aQueryString[nFilter][1]) == "EQ_USERS"  .And. !Empty(self:aQueryString[nFilter][2])
      cUser +=  " A1R_USERS LIKE '%"+ self:aQueryString[nFilter][2] + "%' "
    ElseIf UPPER(self:aQueryString[nFilter][1]) == "EQ_STATUS" .And. !Empty(self:aQueryString[nFilter][2])
      cStatus +=  " A1R_STATUS = '"+ self:aQueryString[nFilter][2] + "' "
    EndIf
  Next

  If !Empty(cGroup) .And. !Empty(cUser)
    cWhere := " AND ( " + cGroup + " OR " + cUser + " ) "
  ElseIf Empty(cGroup) .And. !Empty(cUser)
    cWhere := " AND ( " + cUser + " ) "
  ElseIf !Empty(cGroup) .And. Empty(cUser)
    cWhere := " AND ( " + cGroup + " ) "
  EndIf

  If !Empty(cStatus)
    cWhere += " AND ( " + cStatus + " )"
  EndIf
  aRet := MntQuery(cWhere)

  oCoreDash:SetQuery(aRet[1])
  oCoreDash:SetWhere(aRet[2])
  oCoreDash:SetApiQstring(Self:aQueryString)
  oCoreDash:SetFields(DePara())
  oCoreDash:BuildJson()

	If lRet
		Self:SetResponse( oCoreDash:ToObjectJson())
	Else
		cError := oCoreDash:GetJsonError()
		SetRestFault( 500,  EncodeUtf8(cError) )
	EndIf

	oCoreDash:Destroy()
  FreeObj(aRet)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET tv
Retornar apenas uma visão

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET tv WSRECEIVE IDVision WSSERVICE Visions
  Local aRet        := {}
  Local aFilter     := {}
  Local cError		  := STR0007 // "Erro na Requisição"
	Local lRet			  := .T.
  Local oCoreDash  := CoreDash():New()

  Self:SetContentType("application/json")

  aRet := MntQuery()

  aAdd(aFilter, {" A1R.A1R_ID = '" + self:IDVision + "' " })

  oCoreDash:SetQuery(aRet[1])
  oCoreDash:SetWhere(aRet[2])
  oCoreDash:SetApiFilter(aFilter)
  oCoreDash:SetFields(DePara())
  oCoreDash:SetApiQstring(Self:aQueryString)
  lRet := oCoreDash:BuildJson()

	If lRet
		Self:SetResponse( oCoreDash:ToSingleObject())
	Else
		SetRestFault( 500, FWhttpEncode(cError))
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
    {"id"             , "A1R_ID "  },;
    {"title"          , "A1R_TITULO"  },;
    {"description"    , "A1R_DESCRI "  },;
    {"cards"          , "A1R_CARDS"  },;
    {"charts"         , "A1R_CHARTS"  },;
    {"groups"         , "A1R_GRUPOS"  },;
    {"users"          , "A1R_USERS"  },;
    {"status"         , "A1R_STATUS"  };
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
Static Function MntQuery(cFiltro)
  Local cQuery  := ""
  Local cWhere  := ""

  Default cFiltro := ""

  cQuery += " SELECT A1R_ID, A1R_TITULO, A1R_DESCRI, A1R_CARDS, A1R_CHARTS, A1R_GRUPOS, A1R_USERS, A1R_STATUS FROM " + RetSqlName("A1R") + " A1R "
  cWhere := " A1R.D_E_L_E_T_ = ' ' AND A1R.A1R_FILIAL = '" + xFilial("A1R") + "'

  If !Empty(cFiltro)
    cWhere += cFiltro
  EndIf
Return {cQuery, cWhere}

//-------------------------------------------------------------------
/*/{Protheus.doc} Post tv
Realiza a inclusão de uma Visão

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST tv WSSERVICE Visions
	Local cBody 	  	:= Self:GetContent()
	Local lRet        := .T.
  Local oCoreDash  := CoreDash():New()

  oCoreDash:SetFields(DePara())
  lRet := oCoreDash:SetUpsertData("A1R", Nil, cBody)

  If lRet
    self:IDVision := A1R->A1R_ID
    self:GET_tv('000000')
  Else
    SetRestFault( 500, FWhttpEncode(STR0008) ) // "Falha ao converter o arquivo."
  Endif

  oCoreDash:Destroy()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT tv
Altera uma visão

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD PUT tv WSRECEIVE IDVision WSSERVICE Visions
	Local cBody 	  	:= Self:GetContent()
	Local lRet        := .F.
  Local oCoreDash  := CoreDash():New()

  Default self:IDVision := ""

  If !Empty(self:IDVision)
    oCoreDash:SetFields(DePara())
    lRet := oCoreDash:SetUpsertData("A1R", xFilial("A1R") + self:IDVision, cBody)
  EndIf

  If lRet
    self:GET_tv()
  Else
    SetRestFault( 500, FWhttpEncode(STR0008) ) // "Falha ao converter o arquivo."
  Endif

  oCoreDash:Destroy()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE tv
Deleta uma visão

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE tv WSRECEIVE IDVision WSSERVICE Visions
	Local lRet        := .F.
  Local oJsonPositions:= JsonObject():New()

  Default self:IDVision := ""

  If !Empty(self:IDVision)
    A1R->(DbSetOrder(1))
    If A1R->(DbSeek(xFilial("A1R") + self:IDVision))
      lRet := .T.
      RecLock("A1R", .F.)
      A1R->(DbDelete())
      A1R->(MsUnLock())
    EndIf
  EndIf

  If lRet
		oJsonPositions['response'] := "Id " + self:IDVision + " " + STR0009
		Self:SetResponse( oJsonPositions:ToJson())
  Else
    SetRestFault( 500, FWhttpEncode(STR0008) ) // "Falha ao converter o arquivo."
  Endif
Return lRet
