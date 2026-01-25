#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} EsocialLotation
@type			method
@description	Serviço para obter as lotações do eSocial.
@author			Robson Santos
@since			17/07/2019
/*/
//---------------------------------------------------------------------
WSRESTFUL EsocialLotation DESCRIPTION "Consulta da lista de lotações tributárias ativas ( eSocial )" FORMAT APPLICATION_JSON

	WSDATA companyId	AS STRING
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "Método para obter a lista de lotações tributárias";
		WSSYNTAX "api/rh/esocial/v1/EsocialLotation/?{companyId}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/EsocialLotation/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Método para obter a lista de lotações tributárias.
@author			Robson Santos
@since			17/07/2019
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET QUERYPARAM companyId, page, pageSize WSRESTFUL EsocialLotation

Local oResponse		:=	JsonObject():New()
Local cEmpRequest	:=	""
Local cFilRequest	:=	""
Local nPage			:=	1
Local nPageSize		:=	15
Local aCompany		:=	{}
Local lAmbiente		:=	.T.
Local lRet			:=	.T.

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If Type( "cEmpAnt" ) == "U" .or. Type( "cFilAnt" ) == "U"

			PrepEnv( cEmpRequest, cFilRequest, "WSTAF007" )

		ElseIf cEmpAnt <> cEmpRequest
			If FWFilExist( cEmpRequest, cFilRequest )
				
				PrepEnv( cEmpRequest, cFilRequest, "WSTAF007" )
				
			Else
				lAmbiente := .F.
			EndIf
		ElseIf cFilAnt <> cFilRequest
			cFilAnt := cFilRequest
		EndIf

		If lAmbiente .and. FWFilExist( cEmpRequest, cFilRequest )
			If self:page <> Nil
				nPage := self:page
			EndIf

			If self:pageSize <> Nil
				nPageSize := self:pageSize
			EndIf

			WS007GetLot( @oResponse, nPage, nPageSize )

			self:SetResponse( oResponse:ToJson() )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

oResponse := Nil
FreeObj( oResponse )
DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} WS007GetLot
@type			function
@description	Executa a consulta de lotações tributárias.
@author			Robson Santos
@since			17/07/2019
@param			oResponse	-	Json com as lotações tributárias
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
/*/
//---------------------------------------------------------------------
Static Function WS007GetLot( oResponse as object, nPage as numeric, nPageSize as numeric )

	Local lValida    as logical
	Local nPosReg    as numeric
	Local nRegIni    as numeric
	Local nRegFim    as numeric
	Local nX         as numeric
	Local cNextAlias as character
	Local cBanco     as character
	Local cInFiliais as character
	Local aArea      as array

	cNextAlias := GetNextAlias()
	cBanco     := TcGetDb()
	nPosReg    := 0
	nRegIni    := 0
	nRegFim    := 0
	aArea      := GetArea()
	lValida    := .F.
	nX         := 0
	cInFiliais := TAFCacheFil("C99",, .T.)

	nRegIni    := IIF (cBanco != "OPENEDGE", ( ( nPage - 1 ) * nPageSize ) + 1, ( nPage - 1 ) * nPageSize )
	nRegFim    := nPage * nPageSize

	oResponse["items"] := {}

	If cBanco != "OPENEDGE"
		
		BeginSQL Alias cNextAlias
		SELECT * FROM (
			SELECT ROW_NUMBER() OVER( ORDER BY C99_FILIAL, C99_CODIGO ) LINE_NUMBER, C99_FILIAL, C99_ID, C99_CODIGO, C99_DESCRI
			FROM %table:C99% C99
			WHERE C99.C99_FILIAL IN ( 
				SELECT FILIAIS.FILIAL 
					FROM %temp-table:cInFiliais% FILIAIS
				)
			AND C99.C99_ATIVO = '1'
			AND C99.%notdel%
		) TAB
		WHERE LINE_NUMBER BETWEEN %exp:nRegIni% AND %exp:nRegFim%
		EndSQL
	Else
		
		BeginSQL Alias cNextAlias
		SELECT  C99_FILIAL, C99_ID, C99_CODIGO, C99_DESCRI
				FROM %table:C99% C99
				WHERE C99.C99_FILIAL IN ( 
					SELECT FILIAIS.FILIAL 
						FROM %temp-table:cInFiliais% FILIAIS
					)
					AND C99.C99_ATIVO = '1'
					AND C99.%notdel%
				GROUP BY C99_FILIAL, C99_ID, C99_CODIGO, C99_DESCRI
				ORDER BY C99_FILIAL, C99_CODIGO
				OFFSET %exp:nRegIni% ROWS FETCH NEXT %exp:nRegFim% ROWS ONLY
		EndSQL

	EndIf

	( cNextAlias )->( DBGoTop() )

	While ( cNextAlias )->( !Eof() )

		For nX:= 1 to len(oResponse["items"])
			If !lValida
				lValida := oResponse["items"][nX]:GetJsonObject( "lotationCode" ) == AllTrim( ( cNextAlias )->C99_CODIGO )
			Else
				Exit
			EndIf
		Next

		If !lValida
			nPosReg ++
			aAdd( oResponse["items"], JsonObject():New() )

			oResponse["items"][nPosReg]["companyId"]    := cEmpAnt
			oResponse["items"][nPosReg]["branchId"]     := AllTrim( ( cNextAlias )->C99_FILIAL )
			oResponse["items"][nPosReg]["id"]           := AllTrim( ( cNextAlias )->C99_ID )
			oResponse["items"][nPosReg]["lotationCode"] := AllTrim( ( cNextAlias )->C99_CODIGO )
			oResponse["items"][nPosReg]["description"]  := AllTrim( ( cNextAlias )->C99_DESCRI )
		EndIf

		lValida := .F.

		( cNextAlias )->( DBSkip() )
	EndDo

	oResponse["hasNext"] := WS007HasNext( cInFiliais, nRegFim )

	( cNextAlias )->( DBCloseArea() )

	RestArea( aArea )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} WS007HasNext
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados.
@author			Victor A. Barbosa
@since			17/09/2019
@param			cInFiliais	-	Cláusula IN com as filiais do grupo de empresas logado
@param			nRegFim		-	Identificador do último registro retornado
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
/*/
//---------------------------------------------------------------------
Static Function WS007HasNext( cInFiliais as character, nRegFim as numeric ) as logical

	Local lHasNext  as logical
	Local cAliasMax as character
	Local cBanco    as character

	cAliasMax := GetNextAlias()
	cBanco    := TcGetDb()
	lHasNext  := .F.

	If cBanco != "OPENEDGE"
		BeginSQL Alias cAliasMax
		SELECT MAX( LINE_NUMBER ) MAX_LINE FROM (
			SELECT ROW_NUMBER() OVER( ORDER BY C99_FILIAL, C99_CODIGO ) LINE_NUMBER
			FROM %table:C99% C99
			WHERE C99.C99_FILIAL IN ( 
				SELECT FILIAIS.FILIAL 
					FROM %temp-table:cInFiliais% FILIAIS
				)
			AND C99.C99_ATIVO = '1'
			AND C99.%notdel%
		) TAB
		EndSQL

	Else

		BeginSQL Alias cAliasMax
		SELECT COUNT(*) MAX_LINE FROM (
			SELECT  C99_CODIGO
				FROM %table:C99% C99
				WHERE C99.C99_FILIAL IN ( 
					SELECT FILIAIS.FILIAL 
						FROM %temp-table:cInFiliais% FILIAIS
					)
				AND C99.C99_ATIVO = '1'
				AND C99.%notdel%
				GROUP BY C99_CODIGO	
				ORDER BY C99_FILIAL, C99_CODIGO	
			) TAB
		EndSQL

	EndIf

	( cAliasMax )->( DBGoTop() )

	If ( cAliasMax )->( !Eof() )
		If ( cAliasMax )->MAX_LINE > nRegFim
			lHasNext := .T.
		EndIf
	EndIf

	( cAliasMax )->( DBCloseArea() )

Return( lHasNext )
