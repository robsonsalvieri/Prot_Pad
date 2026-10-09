#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#Include 'FWMVCDEF.CH'
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSTYPECARDS.CH"

#DEFINE ITEMSDETAILS "itemsService"
#DEFINE HEADERITEMS  "headerService"
#DEFINE FIELDSINFO   "fieldsService"
#DEFINE CARDSINFO    "cardService"

Static lA1NCustom := A1N->(ColumnPos("A1N_CUSTOM"))
Static lFATA902   := !Empty(GetAPOInfo("FATA902.PRW"))

/*/{Protheus.doc} TypeCard

API Cadastro de Tipos de Cards do Dashboard

@author		Squad CRM/Faturamento
@since		07/04/2020
/*/
WSRESTFUL TypeCard DESCRIPTION STR0001 //#"DashBoard Protheus"
  WSDATA IDTypeCard AS STRING	OPTIONAL
	WSDATA Page				 AS INTEGER	OPTIONAL
	WSDATA PageSize		 AS INTEGER	OPTIONAL

  WSMETHOD GET tps ;
  DESCRIPTION STR0002 ; //#"Retorna os Tipos de Cards Cadastrados" 
  WSSYNTAX "/typecard/typecard/" ;
  PATH "/typecard/typecard/";
  PRODUCES APPLICATION_JSON

  WSMETHOD GET tp ;
  DESCRIPTION STR0003 ; //#"Retorna um Tipo de Card Específico"
  WSSYNTAX "/typecard/typecard/{IDTypeCard}" ;
  PATH "/typecard/typecard/{IDTypeCard}";
  PRODUCES APPLICATION_JSON

  WSMETHOD POST tp ;
  DESCRIPTION STR0004 ; //#"Insere um novo Tipo de Card"
  WSSYNTAX "/typecard/typecard/" ;
  PATH "/typecard/typecard/" ;
  TTALK "v1"

  WSMETHOD POST vtp ;
  DESCRIPTION STR0025 ;  //#"Valida os endpoints a serem incluídos/alterados"
  WSSYNTAX "/typecard/typecard/valid" ;
  PATH "/typecard/typecard/valid" ;
  TTALK "v1"

  WSMETHOD PUT tp ;
  DESCRIPTION STR0005 ; //#"Altera um Tipo de Card"
  WSSYNTAX "/typecard/typecard/{IDTypeCard}" ;
  PATH "/typecard/typecard/{IDTypeCard}" ;
  TTALK "v1"

  WSMETHOD DELETE tp ;
  DESCRIPTION STR0006 ; //#"Exclui um Tipo de Card" 
  WSSYNTAX "/typecard/typecard/{IDTypeCard}" ;
  PATH "/typecard/typecard/{IDTypeCard}" ;
  TTALK "v1"


ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET FatReg
Retorna os dados do Gráfico

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD GET tps WSRECEIVE JsonFilter WSSERVICE TypeCard

  Local cError		  := STR0007  //#"Erro na Requisição"
	Local lRet			  := .T.
  Local oCoreDash  := CoreDash():New()

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
		SetRestFault( 404,  FWhttpEncode(cError) )
	EndIf

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
WSMETHOD GET tp WSRECEIVE IDTypeCard WSSERVICE TypeCard

  Local aFilter     := {}
  Local cError		  := STR0007  //#"Erro na Requisição"
	Local lRet			  := .T.
  Local oCoreDash  := CoreDash():New()

  Self:SetContentType("application/json")

  oCoreDash:SetFields(DePara())
  oCoreDash:SetApiQstring(Self:aQueryString)

  aAdd(aFilter, {" A1N.A1N_ID = '" + self:IDTypeCard + "' " })

  oCoreDash:SetApiFilter(aFilter)

  MntQuery(@oCoreDash)

  lRet := oCoreDash:BuildJson()

	If lRet
		Self:SetResponse( oCoreDash:ToSingleObject())
	Else
		SetRestFault( 404,  FWhttpEncode(cError) )
	EndIf

	oCoreDash:Destroy()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Post tp
Realiza a inclusão de um Tipo de Card

@param oCoreDash, objeto, Objeto responsável pela montagem do json
@author Rafael Mota Previdi
@since 10/01/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST tp WSSERVICE TypeCard
  Local lRet := .T.
  lRet := PostFunc(Self, .F.)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Post vtp
Realiza a validação dos endpoints de um Tipo de Card
@author Rafael Mota Previdi
@since 18/01/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD POST vtp WSSERVICE TypeCard
  Local lRet := .T.
  lRet := PostFunc(Self, .T.)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT tp
Alterar um Tipo de Card

@author Rafael Mota Previdi
@since 10/01/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD PUT tp WSRECEIVE IDTypeCard WSSERVICE TypeCard

  Local cBody 	   := Self:GetContent()
  Local lRet       := .F.
  Local oCoreDash  := Nil
  Local cURL       := Self:GetURL()
  Local cAuth      := Self:GetHeader('Authorization')
  Local aDetailErr := {}
  Local lIsCustom   := Nil

  If !lFATA902 .Or. !lA1NCustom
    lRet := .F.
    SetRestFault(501, EncodeUtf8(STR0008 + "put" + STR0009)) //#"O método " #" não está completamente implementado nesta API deste ambiente, pois o fonte FATA902 não está contido no RPO. Ou o campo A1N_CUSTOM não foi criado no banco de dados. Atualize o seu RPO e execute o UPDDISTR com o patch da expedição contínua mais recente."
    FWFreeObj(aDetailErr)
    Return lRet
  EndIf

  Default self:IDTypeCard := ""

  // Validar se a alteração eh de um tipo de card não customizado já existente na base de dados
  If !Empty(self:IDTypeCard)
    lIsCustom := isCstmInDB(xFilial("A1N") + self:IDTypeCard)
  EndIf

  // Validar se a alteração eh de um tipo de card customizado já existente na base de dados para um não customizado
  // Ou se é um tipo de card que nem existe na base de dados (ValType(lIsCustom) == "U")
  If ValType(lIsCustom) == "U" .Or. lIsCustom
    lIsCustom := isCstmInJs(cBody)
    If ValType(lIsCustom) == "U"
      lRet := .F.
      SetRestFault(400,  EncodeUtf8(STR0013) )  //#"Falha ao realizar a leitura do json do body da requisição."
      FWFreeObj(aDetailErr)
      Return lRet
    EndIf
  EndIf

  // Verificar se o tipo de gráfico e é padrão
  If !lIsCustom
    lRet := .F.
    SetRestFault(400, EncodeUtf8(STR0014))  //#"Tipo de card padrão não pode ser incluído/alterado por este serviço."
    FWFreeObj(aDetailErr)
    Return lRet
  EndIf

  // Validacao dos EndPoints informados no body
  lRet := vEndPoints(cBody, cURL, @aDetailErr, cAuth)
  If !lRet
    SetRestFault(400, EncodeUtf8("Bad Request"), .T., , EncodeUtf8(STR0015), , aDetailErr)  //#"Erro na validação dos endpoints enviados na requisição."
    FWFreeObj(aDetailErr)
    Return lRet
  EndIf

  If !Empty(self:IDTypeCard)
    oCoreDash  := CoreDash():New()
    oCoreDash:SetFields(DePara())
    lRet := oCoreDash:SetUpsertData("A1N", xFilial("A1N") + self:IDTypeCard, cBody)
    oCoreDash:Destroy()
  EndIf

  If lRet
    self:IDTypeCard := A1N->A1N_ID
    self:GET_TP(self:IDTypeCard)
  Endif
  FWFreeObj(aDetailErr)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE tp
Excluí um Tipo de Card

@author Rafael Mota Previdi
@since 10/01/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE tp WSRECEIVE IDTypeCard WSSERVICE TypeCard

  Local lRet           := .F.
  Local oJsonPositions := JsonObject():New()
  Local cKey           := ""

  Default self:IDTypeCard := ""

  If !lA1NCustom
    lRet := .F.
    SetRestFault(501, EncodeUtf8(STR0008 + "delete" + STR0016))  //#"O método " #" não está completamente implementado nesta API deste ambiente, pois o campo A1P_CUSTOM não foi criado no banco de dados. Atualize o seu RPO e execute o UPDDISTR com o patch da expedição contínua mais recente."
    FWFreeObj(oJsonPositions)
    Return lRet
  EndIf

  If !Empty(self:IDTypeCard)
    cKey := xFilial("A1N") + self:IDTypeCard
    A1N->(DbSetOrder(1))
    If A1N->(DbSeek(cKey))
      If !isCstmInDB(cKey)
        lRet := .F.
        SetRestFault(400, EncodeUtf8(STR0017))  //#"Tipo de card padrão não pode ser excluído por este serviço."
        FWFreeObj(oJsonPositions)
        Return lRet
      ElseIf hasCard(self:IDTypeCard)
        lRet := .F.
        SetRestFault(400, EncodeUtf8(STR0026))  //#"Tipo de Card não pode ser excluído, pois está vinculado à um Card."
        FWFreeObj(oJsonPositions)
        Return lRet
      EndIf
      lRet := .T.
      A1N->(RecLock("A1N", .F.))
      A1N->(DbDelete())
      A1N->(MsUnLock())
    Else
      lRet := .F.
      SetRestFault( 404, EncodeUtf8(STR0018) )  //#"Tipo de card não pode ser excluído, pois não foi encontrado."
      FWFreeObj(oJsonPositions)
      Return lRet
    EndIf
  EndIf

  oJsonPositions['response'] := STR0019 + self:IDTypeCard + STR0020  //#"Id " #" excluído com sucesso."
	Self:SetResponse( EncodeUtf8(oJsonPositions:ToJson()) )

  FWFreeObj(oJsonPositions)
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
    {"branch"         , "A1N_FILIAL"  },;
    {"id"             , "A1N_ID"      },;
    {"cardService"    , "A1N_CARSER"  },;
    {"fieldsService"  , "A1N_FLDSER"  },;
    {"itemsService"   , "A1N_ITSER"   },;
    {"headerService"  , "A1N_CABSER"  },;
    {"title"          , "A1N_TITULO"  };
  }

  If lA1NCustom
    AAdd(aCampos, {"custom", "A1N_CUSTOM"})
  EndIf
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
  Local aFilter   := ""
  Local cAliasQry := GetNextAlias()
  Local cFrom     := ""
  Local cSelect   := ""
  Local cWhere    := ""
  Local nFiltro   := 0

  cSelect := "% A1N_FILIAL, A1N_ID, A1N_CARSER, A1N_FLDSER, A1N_ITSER, A1N_CABSER, A1N_TITULO" 
  If lA1NCustom
    cSelect += ", A1N_CUSTOM"
  EndIf
  cSelect += " %"

  cFrom  := "%" + RetSqlName("A1N") + " A1N " + "%"

  cWhere := " A1N.D_E_L_E_T_ = ' ' AND A1N.A1N_FILIAL = '" + xFilial("A1N") + "' "

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

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} vEndPoints
Funcao que verifica e trata o retorno das funcoes de validacao dos EndPoints enviados no body da requisicao
@param cBody      , character, Body enviado na requisicao
@param cURL       , character, URL para testar os endpoints enviados no body
@param aDetailErr , array    , Array com o detalhe das validações não atendidas pelos endPoints
@param cAuth      , character, Conteudo do usuário e senha para HTTP Basic Authentication
@author Rafael Mota Previdi
@since 13/01/2021
@version Protheus 12
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function vEndPoints(cBody, cURL, aDetailErr, cAuth)
  Local lValid     := .T.
  Local aEndPoints := {}
  // Preparar os dados a serem enviados sobre cada endPoint a ser validado
  // 1 - itemsDetails
  AAdd(aEndPoints, {ITEMSDETAILS /*Tag do EndPoint no body*/, "POST" /*Metodo a ser requisitado*/, /*Estrutura do Json a ser validado*/ })
  aEndPoints[Len(aEndPoints)][3] := { ;
                                      { "header"  /*Atributo*/,"A" /*Tipo*/}, ;
                                      { "items"   /*Atributo*/,"A" /*Tipo*/}, ;
                                      { "hasNext" /*Atributo*/,"L" /*Tipo*/} ;
                                    }
  // 2 - headerItems
  AAdd(aEndPoints, {HEADERITEMS /*Tag do EndPoint no body*/, "GET" /*Metodo a ser requisitado*/, /*Estrutura do Json a ser validado*/ })
  aEndPoints[Len(aEndPoints)][3] := { ;
                                      { "items" /*Atributo*/, "A" /*Tipo*/, { /*Atributos dos objetos contidos no array*/ ;
                                                                              { "showFilter" /*Atributo*/, "L" /*Tipo*/}, ;                
                                                                              { "property"   /*Atributo*/, "C" /*Tipo*/}, ;
                                                                              { "label"      /*Atributo*/, "C" /*Tipo*/}  ;
                                                                            } ;
                                      } ;
                                    }
  // 3 - fieldsInfo 
  AAdd(aEndPoints, {FIELDSINFO /*Tag do EndPoint no body*/, "GET" /*Metodo a ser requisitado*/, /*Estrutura do Json a ser validado*/ })
  aEndPoints[Len(aEndPoints)][3] := { ;
                                      { "items" /*Atributo*/, "A" /*Tipo*/, { /*Atributos dos objetos contidos no array*/ ;
                                                                              { "value" /*Atributo*/, "C" /*Tipo*/},      ;
                                                                              { "label" /*Atributo*/, "C" /*Tipo*/} ;
                                                                            };
                                      } ;
                                    }
  // 4 - cardsInfo
  AAdd(aEndPoints, {CARDSINFO /*Tag do EndPoint no body*/, "GET" /*Metodo a ser requisitado*/, /*Estrutura do Json a ser validado*/ })
  aEndPoints[Len(aEndPoints)][3] := { ;
                                      { "items" /*Atributo*/, "A" /*Tipo*/} ;
                                    }
  // Validacao dos EndPoints informados no body
  aDetailErr := vEndPntsDB(cBody, cURL, aEndPoints, cAuth)
  If Len(aDetailErr) > 0
    lValid := .F.
  EndIf
  
  FWFreeObj(aEndPoints)
Return lValid

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} isJsonCstm
Funcao que verifica o tipo de card é customizado ou não olhando para o json do body da requisicao
@param cBody      , character , Body enviado na requisicao
@author Rafael Mota Previdi
@since 13/01/2021
@version Protheus 12
@return lIsCustom, boolean, indica se o tipo de card em questão é customizado ou não
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function isCstmInJs(cBody)
  Local lIsCustom := .F.
  Local jBody    := JsonObject():new()

  jBody:fromJson(cBody)
  lIsCustom := IIf(ValType(jBody["custom"]) == "L", jBody["custom"], Nil)
  FWFreeObj(jBody)
Return lIsCustom

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} isCstmInDB
Funcao que verifica o tipo de card é customizado ou não olhando para o registro na base dados
@param cKey , character, Chave de pesquisa do tipo de card na base de dados
@author Rafael Mota Previdi
@since 13/01/2021
@version Protheus 12
@return lIsCustom, boolean, indica se o tipo de card em questão é customizado ou não
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function isCstmInDB(cKey)
  Local lIsCustom := Nil

  If (A1N->(A1N_FILIAL + A1N_ID) == cKey .Or. A1N->(DBSeek(cKey)))
    lIsCustom := A1N->A1N_CUSTOM
  EndIf
Return lIsCustom

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PostFunc
Funcao que é executada para os métodos POST da API.
@param oRestFul , object , Objeto responsável pelos dados e controles da requisição
@param lValid   , boolean, Indica se é somente uma validação dos endpoints ou se é para persistir os dados
@author Rafael Mota Previdi
@since 18/01/2021
@version Protheus 12
@return lRet, boolean, indica o resultado do processamento da função onde .T.=Sucesso e .F.=Falha
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function PostFunc(oRestFul, lValid)
  Local cBody 	   := oRestFul:GetContent()
	Local lRet       := .T.
  Local oCoreDash  := Nil
  Local cURL       := oRestFul:GetURL()
  Local cAuth      := oRestFul:GetHeader('Authorization')
  Local aDetailErr := {}
  Local lIsCustom  := Nil

  If !lFATA902 .Or. !lA1NCustom
    lRet := .F.
    SetRestFault(501, EncodeUtf8(STR0008 + "post" + STR0009))  //#"O método " #" não está completamente implementado nesta API neste ambiente, pois o fonte FATA902 não está contido no RPO. Ou o campo A1N_CUSTOM não foi criado no banco de dados. Atualize o seu RPO e execute o UPDDISTR com o patch da expedição contínua mais recente."
    FWFreeObj(aDetailErr)
    Return lRet
  EndIf

  // Validar se a inclusao eh de um tipo de card não customizado
  lIsCustom := isCstmInJs(cBody)
  If ValType(lIsCustom) == "L" .And. !lIsCustom
    lRet := .F.
    SetRestFault(400, EncodeUtf8(STR0010))  //#"Tipo de card padrão não pode ser incluído por este serviço."
    FWFreeObj(aDetailErr)
    Return lRet
  EndIf

  // Validacao dos EndPoints informados no body
  lRet := vEndPoints(cBody, cURL, @aDetailErr, cAuth)
  If !lRet
    SetRestFault(400, EncodeUtf8("Bad Request"), .T., , EncodeUtf8(STR0011), , aDetailErr)  //#"Erro na validação dos endpoints enviados na requisição"
    FWFreeObj(aDetailErr)
    Return lRet
  EndIf

  If lValid
    oRestFul:SetResponse(cBody)
  Else
    oCoreDash := CoreDash():New()
    oCoreDash:SetFields(DePara())
    lRet := oCoreDash:SetUpsertData("A1N", Nil, cBody)

    If lRet
      oRestFul:IDTypeCard := A1N->A1N_ID
      oRestFul:GET_TP(oRestFul:IDTypeCard)
    Endif
    oCoreDash:Destroy()
  EndIf
  FWFreeObj(aDetailErr)
Return lRet


/*/{Protheus.doc} hasCard
  Função que verifica se existe um card (A1O) vinculado ao tipo de card enviado (A1N)
  @type  Static Function
  @author Débora Constantino / Squad CRM/FAT
  @since 18/02/2022
  @version 1.0
  @param idTypeCard, Character, Id do tipo de card a ser pesquisado na A1O
  @return .T., Boolean, Retorna se o tipo de card foi encontrado ou não na A1O
  @example
  hasCard("000031")
/*/
Static Function hasCard(idTypeCard as Character)
  Local lRet := .F.
  Local cKey := xFilial("A1O") + idTypeCard

  A1O->(DbSelectArea("A1O"))
  A1O->(DbSetOrder(2))

  lRet := A1O->(DbSeek(cKey))

Return lRet
