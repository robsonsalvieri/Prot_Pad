#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

Static __aSM0	:=	Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} EsocialMotives
@type			method
@description	Serviço para obter os motivos de afastamento do eSocial.
@author			Diego Santos
@since			20/10/2020
/*/
//---------------------------------------------------------------------
WSRESTFUL EsocialMotives DESCRIPTION "Consulta da lista de motivos de afastamento ( eSocial )" FORMAT APPLICATION_JSON

	WSDATA companyId	AS STRING
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL

	WSMETHOD GET;
		DESCRIPTION "Método para obter os motivos de afastamento";
		WSSYNTAX "api/rh/esocial/v1/EsocialMotives/?{companyId}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/EsocialMotives/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Método para obter a lista de estabelecimentos.
@author			Diego Santos
@since			17/07/2019
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET QUERYPARAM companyId, page, pageSize WSRESTFUL EsocialMotives

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

				PrepEnv( cEmpRequest, cFilRequest, "WSTAF033" )
				

			ElseIf cEmpAnt <> cEmpRequest

				If FWFilExist( cEmpRequest, cFilRequest )

					PrepEnv( cEmpRequest, cFilRequest, "WSTAF033" )

				Else

					lAmbiente := .F.

				EndIf

			ElseIf cFilAnt <> cFilRequest

				cFilAnt := cFilRequest
				
			EndIf

			If lAmbiente .and. FWFilExist( cEmpRequest, cFilRequest )

				//Inicialização de variáveis estáticas
				InitStatic()

				If self:page <> Nil
					nPage := self:page
				EndIf

				If self:pageSize <> Nil
					nPageSize := self:pageSize
				EndIf

				WS030GetMotives( @oResponse, cEmpRequest, cFilRequest, nPage, nPageSize )

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
/*/{Protheus.doc} WS030GetMotives
@type			function
@description	Executa a consulta de estabelecimentos.
@author			Diego Santos
@since			17/07/2019
@param			oResponse	-	Json com as lotações tributárias
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
/*/
//---------------------------------------------------------------------
Static Function WS030GetMotives( oResponse, cEmpRequest, cFilRequest, nPage, nPageSize )

	Local cNextAlias := GetNextAlias()
	Local cRaizCNPJ  := ""
	Local cInFiliais := ""
	Local nPosBranch := 0
	Local nPosReg    := 0
	Local nRegIni    := 0
	Local nRegFim    := 0
	Local dDate      := Date()
	Local aArea      := GetArea()
	Local cBanco     := TcGetDb()

	//Utilizado para obter o CNPJ da filial recebida por parâmetro
	nPosBranch := aScan( __aSM0, { |x| AllTrim( x[1] ) == AllTrim( cEmpRequest ) .and. AllTrim( x[2] ) == AllTrim( cFilRequest ) } )

	nRegIni := IIF (cBanco != "OPENEDGE", ( ( nPage - 1 ) * nPageSize ) + 1, ( nPage - 1 ) * nPageSize ) 
	nRegFim := nPage * nPageSize

	oResponse["items"] := {}

	If nPosBranch > 0

		cRaizCNPJ := SubStr( __aSM0[nPosBranch][18], 1, 8 )

		//Monta a cláusula IN com as filiais do grupo de empresas logado
		cInFiliais := TAFCacheFil("C8N")

		If cBanco != "OPENEDGE"
			BeginSQL Alias cNextAlias

				SELECT * 
					FROM ( 	SELECT ROW_NUMBER() OVER( ORDER BY C8N_CODIGO, C8N_ID ) LINE_NUMBER, C8N_CODIGO, C8N_DESCRI
							FROM %table:C8N% C8N
							WHERE C8N.C8N_FILIAL IN ( 
								SELECT FILIAIS.FILIAL 
									FROM %temp-table:cInFiliais% FILIAIS
								)
							AND ( C8N.C8N_VALIDA = '' OR C8N_VALIDA > %EXP:dDate% )
							AND C8N.%notdel%
							GROUP BY C8N_ID, C8N_CODIGO, C8N_DESCRI
						) TAB
				WHERE LINE_NUMBER BETWEEN %exp:nRegIni% AND %exp:nRegFim%
				
			EndSQL
		Else
			BeginSQL Alias cNextAlias

			SELECT  C8N_ID, C8N_CODIGO, C8N_DESCRI
				FROM %table:C8N% C8N
				WHERE C8N.C8N_FILIAL IN ( 
					SELECT FILIAIS.FILIAL 
						FROM %temp-table:cInFiliais% FILIAIS
					)
				AND ( C8N.C8N_VALIDA = '' OR C8N_VALIDA > %EXP:dDate% )
				AND C8N.%notdel%
				GROUP BY C8N_ID, C8N_CODIGO, C8N_DESCRI
				ORDER BY C8N_CODIGO
				OFFSET %exp:nRegIni% ROWS FETCH NEXT %exp:nRegFim% ROWS ONLY
			EndSQL
		EndIf

		( cNextAlias )->( DBGoTop() )

		While ( cNextAlias )->( !Eof() )

			nPosReg ++

			aAdd( oResponse["items"], JsonObject():New() )

			oResponse["items"][nPosReg]["motivesCode"]					:=	AllTrim( ( cNextAlias )->C8N_CODIGO )
			oResponse["items"][nPosReg]["motivesDescription"]		:=	EncodeUtf8( RTrim( ( cNextAlias )->C8N_DESCRI ) )

			( cNextAlias )->( DBSkip() )

		EndDo

		oResponse["hasNext"] := WS030HasNext( cInFiliais, nRegFim )

		( cNextAlias )->( DBCloseArea() )

	EndIf

	RestArea( aArea )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} WS030HasNext
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados.
@author			Diego Santos
@since			17/09/2019
@param			cInFiliais	-	Cláusula IN com as filiais do grupo de empresas logado
@param			nRegFim		-	Identificador do último registro retornado
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
/*/
//---------------------------------------------------------------------
Static Function WS030HasNext( cInFiliais, nRegFim )

	Local cAliasMax	:=	GetNextAlias()
	Local cBanco    	:= TcGetDb()
	Local lHasNext	:=	.F.
	Local dDate     := Date()

	If cBanco != "OPENEDGE"

		BeginSQL Alias cAliasMax

			SELECT MAX( LINE_NUMBER ) MAX_LINE 
				FROM ( 	SELECT ROW_NUMBER() OVER( ORDER BY C8N_CODIGO, C8N_ID ) LINE_NUMBER, C8N_CODIGO, C8N_DESCRI
						FROM %table:C8N% C8N
						WHERE C8N.C8N_FILIAL IN (
							SELECT FILIAIS.FILIAL 
								FROM %temp-table:cInFiliais% FILIAIS
							)
						AND ( C8N.C8N_VALIDA = '' OR C8N_VALIDA > %EXP:dDate% )
						AND C8N.%notdel%
						GROUP BY C8N_ID, C8N_CODIGO, C8N_DESCRI
					) TAB

		EndSQL 
	Else

		BeginSQL Alias cAliasMax

		SELECT COUNT(*) MAX_LINE FROM (
			SELECT  C8N_CODIGO, C8N_DESCRI
				FROM %table:C8N% C8N
						WHERE C8N.C8N_FILIAL IN ( 
							SELECT FILIAIS.FILIAL 
								FROM %temp-table:cInFiliais% FILIAIS
							)
						AND ( C8N.C8N_VALIDA = '' OR C8N_VALIDA > %EXP:dDate% )
						AND C8N.%notdel%
						GROUP BY C8N_ID, C8N_CODIGO, C8N_DESCRI		
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

//---------------------------------------------------------------------
/*/{Protheus.doc} InitStatic
@type			function
@description	Inicialização de variáveis estáticas
@author			Diego Santos
@since			17/09/2019
/*/
//---------------------------------------------------------------------
Static Function InitStatic()

	If __aSM0 == Nil
		__aSM0 := FWLoadSM0()
	EndIf

Return()
