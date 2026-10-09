#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COREDASH.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CoreDash
Classe responsável por tratar as mensagens do Dashboard

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Class CoreDash
	Data aFields       As Array
  Data aFieldFPO     as Array
  Data aChartInfo    as Array
  Data aFilter		   As Array
  Data aFieldsFil    As Array
  Data aRelatFields  As Array
  Data aCposLGPD     As Array
  Data cAlias        As String
  Data cIndexFather  As String
	Data cJoin         As String
  Data cQuery        As String
	Data cWhere        As String
  Data cGroup        As String
  Data cOrder        As String
	Data nPage         As Numeric
	Data nPageSize     As Numeric
  Data oJFormPO      As Object
  Data oJsonData     As Object
  Data cMessageErr   As String

  Method New() Constructor

  Method SetQuery()
  Method SetWhere()
  Method SetOrder()
  Method SetFields()
  Method SetApiFilter()
  Method SetPage()
  Method SetPageSize()
  Method SetFieldsFilt()
  Method SetApiQstring()
  Method SetUpsertData()
  Method SetTable()
  Method SetPOHeader()
  Method SetPOFilter()
  Method SetPOCombo()
  Method SetGroupBy()
  Method SetPOForm()
  Method SetChartInfo()
  Method SetChart()
  Method SetIndexKey()

  Method GetApiFilter()
  Method GetJsonObject()
  Method GetChartInfo()
  Method GetDataType()
  Method GetPOForm()
  Method GetCposLGPD()
  Method GetColorChart()
  Method GetOrderBy()
  Method DefFields()
  Method SetJson()
  Method BuildJson()
  Method ToObjectJson()
  Method ToSingleObject()
  Method Destroy()
  Method GetJsonError()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method New() Class CoreDash

	Self:aFields      := {}
  Self:aFieldFPO    := {}
  Self:aFieldsFil   := {}
  Self:aChartInfo   := {}
  Self:cAlias       := ""
  Self:cIndexFather := ""
	Self:cJoin        := ""
  self:cQuery       := ""
	Self:cWhere       := ""
  Self:cGroup       := ""
  Self:cOrder       := ""
	Self:aFilter      := {}
  Self:aCposLGPD    := {}
	Self:nPage        := 1
	Self:nPageSize    := 10
  Self:oJsonData    := JsonObject():New()
  Self:oJFormPO     := JsonObject():New()
  Self:cMessageErr  := ""

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFields
Define os campos que serão retornarnos no Json

@param aFields, array, Array com os De/Para entre os campos do serviço e Protheus

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetFields(aFields) Class CoreDash

  self:aFields = aFields

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetQuery
Define a query e os Joins que serão executados

@param cQuery, string, Query com os Joins que serão executados

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetQuery(cQuery) Class CoreDash

  self:cQuery = cQuery

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetWhere
Define a where que será executado

@param cWhere, string, Where que será executado na Query

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetWhere(cWhere) Class CoreDash

  self:cWhere = cWhere

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPage
Método que atribui o número da página que o usuário irá navegar

@nPage	, Numérico, Número da página que o usuário deseja navegar

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetPage(nPage) Class CoreDash
	Default nPage	:= 1
	If nPage > 0
    Self:nPage		:= nPage
	Else
		Self:nPage	:= 1
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPageSize
Método que atribui a quantidade de registro por páginas
@nPageSize	, Numérico, Número de registros por página

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetPageSize(nPageSize) Class CoreDash
	Default nPageSize	:= 20

	If nPageSize > 0
    Self:nPageSize 		:= nPageSize
	Else
		Self:nPageSize	:= 20
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DefFields
Faz a conversão entre campos do Objeto e Protheus

@lConvProt, lógico, Define se deve converter os campos para padrão Protheus
@cField, Caracter, Campo que será convertido

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Method DefFields(lConvProt, cField) Class CoreDash
  Local aFields := self:aFields
  Local cRet    := ""
  Local nPos    := 0

  Default cField    := ""
  Default lConvProt := .T.

  If !lConvProt
    nPos := aScan(aFields, {|x| Upper(x[2]) == Upper(cField) })
    If nPos > 0
      cRet := aFields[nPos][1]
    EndIf
  Else
    nPos := aScan(aFields, {|x| Upper(x[1]) == Upper(cField) })
    If nPos > 0
      cRet := aFields[nPos][2]
    EndIf
  EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDataType
Retorna o Tipo de Dado do Campo

@lConvProt, lógico, Define se deve converter os campos para padrão Protheus
@cField, Caracter, Campo que será convertido

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method GetDataType(lConvProt, cField) Class CoreDash
  Local aFields := self:aFields
  Local cRet    := ""
  Local nPos    := 0

  Default cField    := ""
  Default lConvProt := .T.

  If !lConvProt
    nPos := aScan(aFields, {|x| Upper(x[2]) == Upper(cField) })
    If nPos > 0
      If Len(aFields[nPos]) >= 3
        cRet := aFields[nPos][3]
      Else
        cRet := GetSx3Cache(SubStr(aFields[nPos][2],At('.',aFields[nPos][2]) +1, Len(aFields[nPos][2])),"X3_TIPO")
      EndIf
    EndIf
  Else
    nPos := aScan(aFields, {|x| Upper(x[1]) == Upper(cField) })
    If nPos > 0
      If Len(aFields[nPos]) >= 3
        cRet := aFields[nPos][3]
      Else
        cRet := GetSx3Cache(SubStr(aFields[nPos][1],At('.',aFields[nPos][1]) +1, Len(aFields[nPos][1])),"X3_TIPO")
      EndIf
    EndIf
  EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFieldsFilt
  Método que define quais campos serão retornados pelo serviço.

  @cFields, Caracter, Campos que serão retornados no Json

  @author Nairan Alves/Débora Constantino
  @since 27/03/2020
  @version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetFieldsFilt(cFields) class CoreDash
  Self:aFieldsFil := StrToArray(Upper(cFields), ",")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ToObjectJson
Método que retorna o JsonSerializado.

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method ToObjectJson() Class CoreDash
Return EncodeUtf8(FwJsonSerialize(Self:oJsonData,.T.,.T.))

//-------------------------------------------------------------------
/*/{Protheus.doc} ToSingleObject
Método que retorna o JsonSerializado apanas para um objeto e não um array de objetos.

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method ToSingleObject() Class CoreDash
	Local cRet	:= ""
	Local oRet 	:= Self:GetJsonObject()

	If oRet['items'] != Nil .And. ValType(oRet['items']) == "A" .And. Len(oRet['items']) > 0
		cRet := EncodeUtf8(FwJsonSerialize(oRet['items'][1],.T.,.T.))
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetJsonObject
Método que retorna o objeto Json da classe

@author Squad CRM/Faturamento
@since 24/07/2018
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method GetJsonObject() Class CoreDash
Return Self:oJsonData

//-------------------------------------------------------------------
/*/{Protheus.doc} SetApiQstring
Método que seta o Fields, PageSize, Page, Order e Filtros

@param aQueryString   , array, Parâmetros passados na chamada do WebService (Self:aQueryString)

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetApiQstring(aQueryString) Class CoreDash
  Local cApiValue     := ''
  Local nQueryString  := 0
  Local nLen          := len(aQueryString)
  Local aMyFilter     := Self:GetApiFilter()
  local cOperador     := ''
  Local cConteudo     := ''

  Default aQueryString := {}

	For nQueryString := 1 to nLen
		Do Case
			Case Upper(aQueryString[nQueryString][1]) == "PAGE"
				Self:SetPage( aQueryString[nQueryString][2] )

			Case Upper(aQueryString[nQueryString][1]) == "PAGESIZE"
				Self:SetPageSize( aQueryString[nQueryString][2] )

			Case Upper(aQueryString[nQueryString][1]) == "ORDER"
				Self:SetIndexKey( aQueryString[nQueryString][2] )

			Case Upper(aQueryString[nQueryString][1]) == "FIELDS"
				Self:SetFieldsFilt(aQueryString[nQueryString][2])

			OtherWise
        TrataFiltro(Self, @cOperador, @cApiValue, @cConteudo, aQueryString[nQueryString])
				If !Empty(cApiValue) .And. !Empty(cOperador)
					aAdd(aMyFilter, {' ' + cApiValue + ' ' + cOperador + " " + cConteudo + " " })
				EndIf
		EndCase
	Next

	If Len(aMyFilter) > 0
		Self:SetApiFilter(aMyFilter)
	EndIf

	FreeObj(aMyFilter)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataFiltro
Realiza a tratativa do filtro de acordo com os parâmetros recebidos via Rest

@param CoreDash, Objeto, Objetos utilizado no CoreDash
@param cOperador, Caracter, Operador que será utilizado no Filtro
@param cApiValue, Caracter, Nome do campo no Json
@param cConteudo, Caracter, Conteúdo recebido no filtro
@param aFiltro, Array, Filtro recebido via Rest

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function TrataFiltro(CoreDash, cOperador, cApiValue, cConteudo, aFiltro)
  Local aExpCustom := {}
  Local lExpCustom := .T.
  Local bExpCustom := {||}
  cOperador := SubStr(aFiltro[1],1,at('_',aFiltro[1]) - 1)

  cOperador = StrTran(cOperador,  "LE", "<=")
  cOperador = StrTran(cOperador, "GE", ">=")
  cOperador = StrTran(cOperador, "EQ", "=")
  cOperador = StrTran(cOperador, "GT", ">")
  cOperador = StrTran(cOperador, "LT", "<",)
  cOperador = StrTran(cOperador, "LIKE", "LIKE")
  cOperador = StrTran(cOperador,  "NE", "!=")

  cApiValue := CoreDash:DefFields(.T., SubStr(aFiltro[1],at('_',aFiltro[1]) + 1,Len(aFiltro[1])))

  If !Empty(cApiValue) .And. !Empty(cOperador)
    If !('[' $ aFiltro[2] .And. ']' $ aFiltro[2])
      If cOperador == 'CF'
        bExpCustom := ErrorBlock( { |e| ChecErro(e) } )
        BEGIN SEQUENCE
          aExpCustom := &(aFiltro[2])
          RECOVER
          lExpCustom := .F.
        END SEQUENCE
        ErrorBlock(bExpCustom)

        If lExpCustom .And. ValType(aExpCustom) == 'A' .And. Len(aExpCustom) >= 2 ;
        .And. ValType(aExpCustom[1]) == 'C' .And. ValType(aExpCustom[2]) == 'C'
          cOperador := aExpCustom[1]
          cConteudo := aExpCustom[2]
        Else
          cApiValue := cOperador := cConteudo := ''
        Endif
      ElseIf CoreDash:GetDataType(.F., cApiValue) == "D"
        if At('-', aFiltro[2])
          cConteudo := "'" + StrTran(aFiltro[2],'-','') + "'"
        else
          cConteudo := "'" + DTOS(CTOD(aFiltro[2])) + "'"
        Endif
      Elseif cOperador == 'LIKE'
        cConteudo := "'%" + aFiltro[2] + "%'"
      Elseif CoreDash:GetDataType(.F., cApiValue) == "N" .And. ValType(aFiltro[2]) == "C"
        cConteudo = "'" + cValToChar(Val(aFiltro[2])) + "'"
      Else
        cConteudo = "'" + aFiltro[2] + "'"
      EndIf
    Else
      cConteudo = aFiltro[2]
      cOperador := " IN "
      If GetSx3Cache(SubStr(cApiValue,At('.',cApiValue) +1, Len(cApiValue)),"X3_TIPO") $ "DC"
        cConteudo := StrTran(cConteudo, "[", "('")
        cConteudo := StrTran(cConteudo, "]", "')")
        cConteudo := StrTran(cConteudo, ",", "','")
      Else
        cConteudo := StrTran(cConteudo, aFiltro[1], "")
        cConteudo := StrTran(cConteudo, "[", "(")
        cConteudo := StrTran(cConteudo, "]", ")")
      EndIf
    EndIf
  EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetApiFilter
Método que atribui um filtro de pesquisa

@param aFilter , array, Array contendo o filtro a ser executado.

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetApiFilter (aFilter) Class CoreDash

	Self:aFilter := aFilter

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetApiFilter
Método que retorna o filtro de pesquisa

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method GetApiFilter () Class CoreDash

Return Self:aFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildJson
Método que monta o objeto Json

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method BuildJson() class CoreDash

  Local aConteudo := aClone(self:aFields)
  Local aItems    := {}
  Local cQuery    := ""
  Local cTemp     := GetNextAlias()
  Local lHasnext  := .T.
  Local lRet      := .T.
  Local nCount    := 0
  Local nLenFields:= Len(self:aFields)
  Local aFildsFil := Self:aFieldsFil
  Local nFields   := 0
  Local nFiltro   := 0
  Local aCposLGPD := {}

  If Empty(self:cAlias)
    cQuery 		:= self:cQuery

    If !Empty( self:cWhere)
      cQuery 		+= " WHERE " + self:cWhere
      For nFiltro := 1 to Len(self:aFilter)
        cQuery 		+= " AND " + self:aFilter[nFiltro][1]
      Next
    EndIf

    If !Empty(Self:cGroup)
      cQuery += " GROUP BY " + Self:cGroup
    EndIf

    If !Empty(Self:cIndexFather)
      cQuery += " ORDER BY " + Self:cIndexFather
    EndIf

    MPSysOpenQuery( cQuery, cTemp )

  Else
    cTemp := self:cAlias
  EndIf

  If self:nPage > 1
    nStart := ( (self:nPage-1) * self:nPageSize )
    If nStart > 0
      (cTemp)->( DbSkip( nStart ) )
    EndIf
  EndIf

  aCposLGPD := self:GetCposLGPD()

	While (cTemp)->(!Eof())
    nCount++

		oItem := JsonObject():New()

    For nFields := 1 To nLenFields
      xConteudo := ""
      If Empty(aFildsFil) .Or. aScan(aFildsFil, Upper(Self:aFields[nFields][1])) > 0
        TrataRet(@xConteudo, cTemp, nFields, aConteudo, aCposLGPD )
        If xConteudo != Nil //.And. (!Empty(xConteudo) .Or. ValType(xConteudo) == "L" .And. !xConteudo)
          oItem[Self:aFields[nFields][1]] := IIf(ValType(xConteudo) == "C", AllTrim(xConteudo), xConteudo)
        EndIf
      EndIf
    Next

    aAdd(aItems,oItem)

		(cTemp)->( DBSkip() )

		If nCount == self:nPageSize
			Exit
		EndIf

  EndDo

  If (cTemp)->(Eof())
    lHasnext := .F.
  EndIf

  self:SetJson(lHasnext, aItems)

  (cTemp)->(DBCloseArea())

  FreeObj(aConteudo)

  If Len(aItems) == 0
    lRet := .F.
    self:cMessageErr := STR0002 //Não há items sendo devolvidos no Json através do método BuildJson() da classe CoreDash
  EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetJson
Método que monta o objeto Json

@param lHasNext	, lógico, Informa se existe mais páginas para consulta
@param aItens	, array	, Array contendo os dados encontrados

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetJson(lHasNext, aItens) Class CoreDash
	Default lHasNext	:= .T.
	Default aItens		:= {}
	Self:oJsonData  := JsonObject():New()

	Self:oJsonData["hasNext"] 	:= lHasNext
	Self:oJsonData['items']	:= aItens

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTable
Recebe o Alias responsável pela geração do Json

@param cAlias	, Caracter  , Alias utilizado para geração do Json

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetTable(cAlias) Class CoreDash
  self:cAlias := cAlias
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetUpsertData
Realiza a Inclusão/Alteração de Registros

@param cAlias	, Caracter  , Alias que sofrerá Manutenção
@param cIndex	, Caracter	, Índice 1 utilizado na Busca
@param cBody	, Caracter	, Json recebido no Body da mensagem

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetUpsertData(cAlias, cIndex, cBody) Class CoreDash
	Local cContArray := ""
  Local lRet       := .T.
  Local nFields    := 0
  Local nArray     := 0
  Local nLenFields := Len(self:aFields)
  Local oJson      := JsonObject():new()
  Local lRecLock   := .F.
  Local lInclusion := .T.
  Local cProxNum   := ""

  Default cAlias	:= ""
	Default cIndex	:= ""
  Default cBody		:= ""

  If !Empty(cAlias)
    If Empty(cIndex) .Or. !((cAlias)->(DbSeek(cIndex)))
      lInclusion := .T.
      lRecLock := .T.
      cProxNum := GetSXENum(cAlias , cAlias + "_ID")
      cIndex := xFilial(cAlias) + cProxNum

      While (cAlias)->(DbSeek(cIndex))
        ConfirmSX8()
        cProxNum := GetSXENum(cAlias , cAlias + "_ID")
        cIndex := xFilial(cAlias) + cProxNum
      Enddo
    ElseIf (cAlias)->(DbSeek(cIndex))
      lInclusion := .F.
      lRecLock := (cAlias)->(SimpleLock())
      (cAlias)->(MsRUnlock())
    EndIf

    If oJson:fromJson(DecodeUtf8(cBody)) == Nil
      If lRecLock
        RecLock(cAlias, lInclusion)
        For nFields := 1 to nLenFields
          If oJson:GetJsonObject(self:aFields[nFields][1]) != Nil
            nFieldPos := FieldPos( self:aFields[nFields][2] )
            If nFieldPos > 0 .And. !(AllTrim(self:aFields[nFields][2]) == cAlias + "_ID") .And. AllTrim(self:aFields[nFields][2]) != cAlias + "_FILIAL"
              //Retirar esse IF após a migração oficial... a Chave no Protheus é caracter mas atualmente o Json Server trabalha com Numérico.
              If GetSx3Cache(self:aFields[nFields][2],"X3_TIPO") == "C" .And. ValType(oJson:GetJsonObject(self:aFields[nFields][1])) == "N"
                FieldPut( nFieldPos, StrZero((oJson:GetJsonObject(self:aFields[nFields][1])), 6))
              ElseIf ValType(oJson:GetJsonObject(self:aFields[nFields][1])) == "A"
                cContArray := ""
                For nArray := 1 To Len(oJson:GetJsonObject(self:aFields[nFields][1]))
                  cContArray += oJson:GetJsonObject(self:aFields[nFields][1])[nArray]
                  If !(nArray == Len(oJson:GetJsonObject(self:aFields[nFields][1])))
                    cContArray += ","
                  EndIf
                Next
                FieldPut( nFieldPos, cContArray )
              Else
                FieldPut( nFieldPos, oJson:GetJsonObject(self:aFields[nFields][1]) )
              EndIf
            EndIf
          EndIf
        Next
      Else
        lRet := .F.
        ::cMessageErr := STR0003 + " " + STR0004 // O registro está bloqueado para uso. Tente novamente mais tarde.
      EndIf
    Else
      lRet := .F.
      SetRestFault( 500,  FwHttpEncode(STR0001) ) // Falha ao converter o arquivo.
    Endif
    If lRet .And. lInclusion
      //Retirar esse IF após a migração oficial... a Chave no Protheus é caracter mas atualmente o Json Server trabalha com Numérico.
      nFieldPos := FieldPos( cAlias + "_ID" )
      FieldPut( nFieldPos, cProxNum )
      ConfirmSX8()
      nFieldPos := FieldPos( cAlias + "_FILIAL" )
      FieldPut( nFieldPos, xFilial(cAlias) )
    EndIf
    (cAlias)->(MsUnlock())
  EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TrataRet
Realiza a tratativa dos campos Api x Protheus

@param xConteudo, não Definido	, Conteúdo que será retornado no Json
@param cAlias	, caracter		, Alias posicionado
@param nFields		, Numérico		, Posição do campo posicionado
@param aConteudo	, caracter		, Campos De/Para entre o Json e o Protheus

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function TrataRet(xConteudo, cAlias, nFields, aConteudo, aCposLGPD )

	Local nFieldPos	:= 0
	Local uValue	:= Nil
  Local lVldLGPD  := .T.
  Local nY        := 0

	Default xConteudo := Nil
	Default cAlias	  := ''
	Default nFields	  := 0
  Default aCposLGPD := {}

	DbSelectArea(cAlias)

    If '.' $ aConteudo[nFields][2]
      aConteudo[nFields][2] := SubStr(aConteudo[nFields][2], at('.',aConteudo[nFields][2]) + 1, Len(aConteudo[nFields][2]))
    EndIf

    If Len(aCposLGPD[1]) == 0 .And. aCposLGPD[2][1] == "1"
      lVldLGPD := .F.
    ElseIf Len(aCposLGPD[1]) > 0 .And. aCposLGPD[2][1] == "2"
      lVldLGPD := .T.
    ElseIf Len(aCposLGPD[1]) > 0 .And. aCposLGPD[2][1] == "3"
      For nY := 1 To Len(aCposLGPD[1])
        lVldLGPD := .F.
        If aCposLGPD[1][nY] = Alltrim(Upper(aConteudo[nFields][2]))
          lVldLGPD := .T.
          Exit
        Endif
      Next
    Else
      lVldLGPD := .T.
    Endif

    nFieldPos := FieldPos( aConteudo[nFields][2] )
    If nFieldPos > 0 .And. lVldLGPD
      uValue := FieldGet( nFieldPos )
      If ValType(uValue) == "D"
        xConteudo := DToS(uValue)
      ElseIf ValType(uValue) == "N"
        If GetSx3Cache(aConteudo[nFields][2],"X3_TIPO") == "N"
          xConteudo := uValue
        Else
          xConteudo := uValue
        EndIf
      ElseIf ValType(uValue) == "C"
        xConteudo := uValue
      EndIf

      If GetSx3Cache(aConteudo[nFields][2],"X3_TIPO") == "D"
        xConteudo := DTOC(STOD(xConteudo))
      EndIf
    ElseIf nFieldPos > 0 .And. !lVldLGPD
      xConteudo := Replicate("*", 20 )
    EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Método que destroi o objeto

@author Nairan Alves/Débora Constantino
@since 27/03/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method Destroy() Class CoreDash

	FreeObj(Self:aFields)
  FreeObj(Self:aFieldsFil)
	Self:cJoin      := ""
  self:cQuery     := ""
	Self:cWhere     := ""
  Self:cGroup     := ""
  Self:cOrder     := ""
  aSize(Self:aChartInfo, 0)
	FreeObj(Self:aFilter)
  FreeObj(Self:oJsonData)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetIndexKey
Método que atribui a ordem do Alias principal

@param cIndexFather   , caracter, Ordem utilizada no alias

@author Squad CRM/Faturamento
@since 24/07/2018
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetIndexKey(cIndexFather) Class CoreDash
	Local aCampos	:= StrToArray(cIndexFather, ",")
	Local cApiValue	:= ""
	Local lAsc		:= .F.
	Local nLoop		:= Len(aCampos)
	Local nX		:= 0

	Default	cIndexFather	:= ""

	If SubStr(cIndexFather, 1, 1) == "-"
		cIndexFather	:= SubStr(cIndexFather, 2, Len(cIndexFather))
		lAsc := .T.
	EndIf

	For nX := 1 To nLoop
		cApiValue := self:DefFields(.T.,StrTran(aCampos[nX],"-",""))///Self:GetProtField(Self:cNickAlias, StrTran(aCampos[nX],"-",""))

		If !Empty(cApiValue)
      If Empty(Self:cIndexFather)
        If lAsc
          Self:cIndexFather	+= cApiValue + " DESC "
        Else
          Self:cIndexFather	+= cApiValue
        EndIf
      Else
        If lAsc
          Self:cIndexFather	+= "," + cApiValue  + " DESC "
        Else
          Self:cIndexFather	+= "," + cApiValue
        EndIf
      Endif
		Endif
	Next
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPOHeader

Método responsável pelo tratamento da propriedade [p-columns] do componente
PO Table, que espera receber, no mínimo, property e label.

@param aDados, array, Array com os dados do property e do label.

@author Nairan Alves/Débora Constantino
@since 17/05/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetPOHeader(aFields) Class CoreDash

  Local aItems     := {}
  Local item       := {}
  Local nFields    := 0
  Local nLenFields := Len(aFields)

  Default aFields   := {}

  For nFields := 1 To nLenFields
    item := JsonObject():New()
    item['property'] := aFields[nFields][1]
    item['label']    := aFields[nFields][2]
    If Len(aFields[nFields]) >= 3
      If aFields[nFields][3] != Nil
        item['type']     := aFields[nFields][3]
        If AllTrim(Upper(aFields[nFields][3])) == 'LINK'
          item['action']  := 'Link'
        EndIf
      Endif
    EndIf

    if Len(aFields[nFields]) >= 4
      If aFields[nFields][4] != Nil
        item['format']  := aFields[nFields][4]
      Endif
    EndIf

    if Len(aFields[nFields]) >= 5
      If aFields[nFields][5] != Nil
        item['showFilter']  := aFields[nFields][5]
      Else
        item['showFilter']  := .T.
      Endif
    else
      item['showFilter']  := .T.
    EndIf

    if Len(aFields[nFields]) >= 6
      If aFields[nFields][6] != Nil
        item['visible'] := aFields[nFields][6]
      Endif
    EndIf

    if Len(aFields[nFields]) >= 7
      If aFields[nFields][7] != Nil
        item['type']  := "label"
        item['labels'] := aFields[nFields][7]
      Endif
    EndIf

    If Len(aFields[nFields]) >= 8
      If aFields[nFields][8] != Nil
        item['width']  := aFields[nFields][8]
      Endif
    EndIf

    If Len(aFields[nFields]) >= 9
      If aFields[nFields][9] != Nil
        item['disabled']  := aFields[nFields][9]
      Endif
    EndIf

    aAdd(aItems, item)
  Next

  Self:oJsonData["header"] := aItems

Return aItems

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPOFilter

Método responsável pela montagem de um Json utilizado para filtros de Card.

@param aFields, array, Array com as seguintes informaçõe: aFields[property, label, type (C,N,D), combo(array)].

@author Nairan Alves/Débora Constantino
@since 17/05/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetPOFilter(aFields) Class CoreDash

  Local aItems     := {}
  Local item       := {}
  Local nFields    := 0
  Local nLenFields := Len(aFields)

  Default aFields   := {}

  For nFields := 1 To nLenFields
    item := JsonObject():New()
    item['property'] := aFields[nFields][1]
    item['label']    := aFields[nFields][2]

    if Len(aFields[nFields]) >= 3
      item['type']     := aFields[nFields][3]
    EndIf

    if Len(aFields[nFields]) >= 4
      item['combo']    := self:SetPOCombo(aFields[nFields][4])
    EndIf

    aAdd(aItems, item)
  Next

Return aItems

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPOCombo

Método responsável pelo tratamento da propriedade [p-options] do componente
PO Combo, que espera receber, no mínimo, value e label.

@param aOptions, array, Array com os dados do value e do label.

@author Nairan Alves/Débora Constantino
@since 17/05/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetPOCombo(aOptions) Class CoreDash

  Local aItems     := {}
  Local item       := {}
  Local nFields    := 0
  Local nLenFields := Len(aOptions)

  Default aOptions   := {}

  For nFields := 1 To nLenFields
    item := JsonObject():New()
    item['value'] := aOptions[nFields][1]
    item['label'] := aOptions[nFields][2]

    aAdd(aItems, item)
  Next

Return aItems

//-------------------------------------------------------------------
/*/{Protheus.doc} SetGroupBy

Método responsável por definir a cláusula GroupBy da Query Utilizada

@param cGroup, Caracter, Cláusula GroupBy

@author Nairan Alves/Débora Constantino
@since 17/05/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetGroupBy(cGroup) Class CoreDash
  Self:cGroup     := cGroup
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPOForm

Método responsável por Receber Atributos e Montar um formulário
com base no DynamicForm do PO-UI

@param cDivider, Caracter, Nome da divisória a ser criada
@param cProperty, Caracter, Nome da Propriedade
@param cGridColumns, Caracter, Número de Colunas Ocupado pelo Campo
@param cLabel, Caracter, Label do Campo
@param lRequired, lógico, Obrigatório ou não
@param cType, Caracter, Tipo do Campo
@param aOptions, Array, Array com as opinões
@param loptionsMulti, lógico, Informe se o Options é multiselect

@author Nairan Alves/Débora Constantino
@since 15/06/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method SetPOForm (cDivider, cProperty, cGridColumns, cLabel, lRequired, cType, aOptions, loptionsMulti) Class CoreDash
    Local oitem      := JsonObject():New()

    Default cDivider      := ""
    Default cProperty     := ""
    Default cGridColumns  := ""
    Default cLabel        := ""
    Default lRequired     := .F.
    Default aOptions      := {}
    Default loptionsMulti := .F.

    If !Empty(cDivider)
      oitem["divider"]       :=	cDivider
    EndIf

    oitem["property"]      :=	cProperty
    oitem["gridColumns"]   := cGridColumns
    oitem["label"]         := cLabel
    oitem["required"]      := lRequired
    If !Empty(cType)
      oitem["type"]         := cType
    EndIf
    oitem["gridSmColumns"] := 12

    If !Empty(aOptions)
      oitem["options"] := aOptions
      If loptionsMulti
        oitem["optionsMulti"] := loptionsMulti
      EndIf
    EndIf

    AADD(self:aFieldFPO, oitem)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} oJFormPO
Método responsável por Retornar um objeto JSON utilizando como base no DynamicForm do PO-UI

@author Nairan Alves/Débora Constantino
@since 15/06/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------
Method GetPOForm()  Class CoreDash
  Self:oJFormPO["items"]      := self:aFieldFPO
Return Self:oJFormPO

/*/{Protheus.doc} SetChartInfo
  Adiciona informações de um novo Grafico de Barra/Linha.

  @author Danilo Salve
  @since 07/07/2020
  @version 12.1.27
  @param aDados, Array, Array de Valores utilizados no Grafico.
  @param cLegenda, Char, Legenda/Label
  @param cTipo, Char, Tipo do Grafico
  @param cBgColor, Char, Cor de fundo
  @param lbackGround, Boleano, Informa se o gráfico de linhas terá cor de fundo
  @param lDrillDown, Boleano, Informa se irá ativar o efeito de Drill Down ao clicar na linha.
  @return lRet, Loigi, Array de dados informados no Método SetChartInfo.
/*/
Method SetChartInfo( aDados, cLegenda, cTipo, cBgColor, lBackGround, lDrillDown ) Class CoreDash
  Local oChart  := JsonObject():New()
  Local lRet      := .T.

  Default cTipo       := ""
  Default cBgColor    := ""
  Default lBackGround := .F.
  Default lDrillDown  := .T.

  If Empty(aDados) .Or. Empty(cLegenda)
    lRet := .F.
  Else
    oChart["data"]   := aDados
    oChart["label"]  := cLegenda

    If !Empty(cTipo)
      oChart["type"]   := cTipo
    Endif

    oChart["fill"]   := lBackGround

    oChart["lineTension"] := 0

    If !Empty(cBgColor)
      oChart["borderColor"]           := cBgColor
      oChart["backgroundColor"]       := cBgColor
      oChart["hoverBackgroundColor"]  := cBgColor
    Endif

    oChart["drillDown"] := lDrillDown

    aAdd(Self:aChartInfo, oChart)
  Endif

  FreeObj(oChart)

Return lRet

/*/{Protheus.doc} GetChartInfo
  Retorna em um Array todas as informações de Graficos de Barra/Linha

  @author Danilo Salve
  @since 07/07/2020
  @version 12.1.27
  @return aChartInfo, Array, Array contendo todos os Dados informados através do Método SetChartInfo.
/*/
Method GetChartInfo() Class CoreDash
Return Self:aChartInfo

/*/{Protheus.doc} Method SetChart
  Retorna em um Array todas as informações de Graficos de Barra/Linha

  @author Danilo Salve
  @since 07/07/2020
  @version 12.1.27
  @param cLegenda, Char, Legendas apresentadas no Gráfico
  @param aDados, Array, Dados impressos no Gráfico. Para gráficos do tipo barra/linha, pode se usar o próprio GetChartInfo
  @param lCurrency, Logico, Informa se a máscara retornada será ou não do tipo moeda - Opcional
  @param cType, Char, Tipo de Gráfico que será retornado.
  @param cTitulo, Char, Título apresentado no Gráfico.
  @return oChart, Object, Grafico
/*/
Method SetChart( aLegenda, aDados, lCurrency, cType, cTitle, aMaskFrac ) Class CoreDash

  Local oChart     := JsonObject():New()
  Local aItems     := {}
  Local aItem

  Default aLegenda  := {}
  Default aDados    := Self:GetChartInfo()
  Default lCurrency := .F.
  Default cType     := ""
  Default aMaskFrac := {}

  oChart["chartLabels"] := aLegenda
  oChart["chartData"] := aDados

  If lCurrency
    oChart["chartMask"] := "currency"
  Endif

  If Len(aMaskFrac) > 0
    oChart["currencyMask"] := aMaskFrac
  Else
    aItem   := JsonObject():New()
    aItem['maskFrac'] := SuperGetMV("MV_SIMB1")
    aItem['maxiFrac'] := 10
    aItem['miniFrac'] := 2
    AAdd(aItems,aItem)
    oChart["currencyMask"] := aItems
  Endif

  oChart["charttype"] := cType
  oChart["title"] := cTitle

Return oChart

/*/{Protheus.doc} Method GetCposLGPD
  Retorna em um Array todos os campos que deveram ter controle para LGPD

  @author Francisco Oliveira
  @since 23/09/2020
  @version 12.1.27
  @return aCposLGPD
/*/

Method GetCposLGPD() Class CoreDash

  Local aFields   := self:aFields
  Local aCposLGPD := {}
  Local aRetLGPD  := {}
  Local aAuxLGPD  := {}
  Local cNomeCpo  := ""
  Local nY        := 0
  Local lLGPDDash	:= cPaisLoc == "BRA" .And. FindFunction( "FwPDCanUse" ) .And. FwPDCanUse(.T.)
  Local lRetLGPD  := .F.

  If lLGPDDash
    For nY := 1 To Len(aFields)
      If '.' $ aFields[nY][2]
        cNomeCpo := SubStr(aFields[nY][2], at('.',aFields[nY][2]) + 1, Len(aFields[nY][2]))
      Else
        cNomeCpo := aFields[nY][2]
      EndIf
      Aadd(aCposLGPD, cNomeCpo )
    Next

    aAuxLGPD := FwProtectedDataUtil():UsrAccessPDField( cUserName, aCposLGPD )

    lRetLGPD := .T.

  Endif

  If lRetLGPD .And. Len(aAuxLGPD) == 0
    Aadd(aRetLGPD, aAuxLGPD )
    Aadd(aRetLGPD, {"1"} )
  ElseIf lRetLGPD .And. (Len(aAuxLGPD) == Len(aCposLGPD))
    Aadd(aRetLGPD, aAuxLGPD )
    Aadd(aRetLGPD, {"2"} )
  ElseIf lRetLGPD .And. (Len(aAuxLGPD) < Len(aCposLGPD))
    Aadd(aRetLGPD, aAuxLGPD )
    Aadd(aRetLGPD, {"3"} )
  Else
    Aadd(aRetLGPD, aAuxLGPD )
    Aadd(aRetLGPD, {"4"} )
  Endif

Return aRetLGPD

// Função criada pelo Rafael Duran.
STATIC FUNCTION ChecErro(e)
	Conout(e:Description)
	BREAK
Return()

/*/{Protheus.doc} Method GetColorChart
  Retorna em um Array com todas as cores padronizadas para uso nos gráficos

  @author Francisco Oliveira
  @since 01/02/2021
  @version 12.1.27
  @return aClrChart
/*/

Method GetColorChart(xClrColor) Class CoreDash

Local aClrChart := {}
Local nPos      := 0

Default xClrColor := ""

aClrChart := {}
nPos      := 0

Aadd(aClrChart, {"cGreenDk"   ,"1"  ,"rgba(  0,178,142, 1)"} )
Aadd(aClrChart, {"cGreenLht"  ,"2"  ,"rgba(  0,201,161, 1)"} )
Aadd(aClrChart, {"cRedDk"     ,"3"  ,"rgba(198, 72, 64, 1)"} )
Aadd(aClrChart, {"cRedLht"    ,"4"  ,"rgba(227, 73, 64, 1)"} )
Aadd(aClrChart, {"cYellDk"    ,"5"  ,"rgba(252,203, 76, 1)"} )
Aadd(aClrChart, {"cYellLht"   ,"6"  ,"rgba(255,212,100, 1)"} )
Aadd(aClrChart, {"cOrangeDk"  ,"7"  ,"rgba(234,155, 62, 1)"} )
Aadd(aClrChart, {"cOrangeLht" ,"8"  ,"rgba(255,162, 54, 1)"} )
Aadd(aClrChart, {"cBlueDk"    ,"9"  ,"rgba(  0,120,255, 1)"} )
Aadd(aClrChart, {"cBlueLht"   ,"10" ,"rgba( 50,165,255, 1)"} )
Aadd(aClrChart, {"cGreyDk"    ,"11" ,"rgba(192,192,192, 1)"} )
Aadd(aClrChart, {"cGreyLht"   ,"12" ,"rgba(200,200,210, 1)"} )
Aadd(aClrChart, {"cPurpleDk"  ,"13" ,"rgba(128,  0,128, 1)"} )
Aadd(aClrChart, {"cPurpleLht" ,"14" ,"rgba(185, 35,185, 1)"} )
Aadd(aClrChart, {"cBrownDk"   ,"15" ,"rgba(128,  0,  0, 1)"} )
Aadd(aClrChart, {"cBrownLht"  ,"16" ,"rgba(160, 80, 40, 1)"} )
Aadd(aClrChart, {"cFuchsiaDk" ,"17" ,"rgba(255,  0,255, 1)"} )
Aadd(aClrChart, {"cFuchsiaLht","18" ,"rgba(255,120,255, 1)"} )

Aadd(aClrChart, {"cMnightBlue","19" ,"rgba( 25, 25,112, 1)"} )
Aadd(aClrChart, {"cMediumBlue","20" ,"rgba(  0,  0,205, 1)"} )
Aadd(aClrChart, {"cDGreen"    ,"21" ,"rgba(  0,100,  0, 1)"} )
Aadd(aClrChart, {"cFGreen"    ,"22" ,"rgba( 34,139, 34, 1)"} )
Aadd(aClrChart, {"cGreenYel"  ,"23" ,"rgba(173,255, 47, 1)"} )
Aadd(aClrChart, {"cSalmon"    ,"24" ,"rgba(250,128,114, 1)"} )
Aadd(aClrChart, {"cTan"       ,"25" ,"rgba(210,180,140, 1)"} )
Aadd(aClrChart, {"cWheat"     ,"26" ,"rgba(245,222,179, 1)"} )
Aadd(aClrChart, {"cSlateGray" ,"27" ,"rgba(112,128,144, 1)"} )
Aadd(aClrChart, {"cMistyRose" ,"28" ,"rgba(255,228,225, 1)"} )

If !Empty(xClrColor ) .And. ValType(xClrColor) == "C"
  nPos := Val(xClrColor)
ElseIf !Empty(xClrColor ) .And. ValType(xClrColor) == "N"
  nPos := xClrColor
Elseif Empty(xClrColor )
  nPos := 0
Endif

If nPos > 0 .And. nPos <= Len(aClrChart)
  aClrChart := aClrChart[nPos]
Endif

Return aClrChart

/*/{Protheus.doc} Method GetOrderBy
  Retorna string com a ORDER BY definida pelo ordenação de colunas

  @author Francisco Oliveira
  @since 24/07/2021
  @version 12.1.27
  @return String
/*/

Method GetOrderBy() Class CoreDash

Return Self:cIndexFather

/*/{Protheus.doc} Method GetJsonError
  Retorna string com a mensagem de erro do JSON

  @author Lucas Panão 
  @since 25/04/2022
  @version 12.1.33
  @return String
/*/
Method GetJsonError() Class CoreDash
Return Self:cMessageErr
