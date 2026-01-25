#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"

#DEFINE PAGE_DEF			1
#DEFINE PAGESIZE_DEF		15
#DEFINE ERRORCODE_DEF		400

#DEFINE SM0_GRP_EMP			01
#DEFINE SM0_FILIAL_COD		02
#DEFINE SM0_FILIAL_DESC		03
#DEFINE SM0_FILIAL_CGC		04
#DEFINE API_CODE			"WSTAF020"

/*/{Protheus.doc} WSRESTFUL monitorEsocial
Serviço de retorno de filiais de acordo com os parâmetros informados
@author  Totvs
@since   05/11/2019
@version 12.1.25
/*/
WSRESTFUL TAFEsocialBranches DESCRIPTION oEmToAnsi( "Serviço do Monitor de Transmissão do eSocial (TAFFULL) " ) FORMAT APPLICATION_JSON
	
	WSDATA companyId	AS STRING	
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL
	
	WSMETHOD GET DESCRIPTION oEmToAnsi( "Método para consultar as filiais para a transmissão dos eventos do E-Social" ) WSSYNTAX "api/rh/esocial/v1/TAFEsocialBranches/?{companyId}&{page}&{pageSize}" PATH "api/rh/esocial/v1/TAFEsocialBranches/" TTALK "v1" PRODUCES APPLICATION_JSON

END WSRESTFUL

//--------------------------------------------------------------------
/*/{Protheus.doc} WSMETHOD GET TAFEsocialBranches
Retorna as filiais de acordo com os parâmetros informados
@author  Totvs
@since   05/11/2019
@version 12.1.25
/*/
//--------------------------------------------------------------------
WSMETHOD GET QUERYPARAM companyId, page, pageSize WSRESTFUL TAFEsocialBranches

	Local oResponse   := Nil
	Local cEmpRequest := ""
	Local cFilRequest := ""
	Local nPage       := 1
	Local nPageSize   := 1
	Local aCompany    := {}
	Local lAmbiente   := .T.
	Local lRet        := .T.
	Local cCompId     := ""
		
	DEFAULT Self:companyId 		:= {}	
	DEFAULT Self:page 			:= PAGE_DEF
	DEFAULT Self:pageSize 		:= PAGESIZE_DEF
		
	cCompId    := Self:companyId	
	nPage 	   := Self:page
	nPageSize  := Self:pageSize
	cAuth 	   := self:GetHeader("Authorization")
	If Empty( cCompId )

		lRet := .F.
		SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Grupo, Empresa e Filial logada não foram informados no parâmetro 'companyId'." ) )

	Else

		aCompany := StrTokArr( cCompId, "|" )
	
		If Len( aCompany ) < 2

			lRet := .F.
			SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Grupo, Empresa e Filial logada não foram informados no parâmetro 'companyId'." ) ) 

		Else

			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]
	
			If Type( "cEmpAnt" ) == "U" .or. Type( "cFilAnt" ) == "U"

				PrepEnv( cEmpRequest, cFilRequest, "WSTAF020" )
			
			ElseIf cEmpAnt <> cEmpRequest

				If FWFilExist( cEmpRequest, cFilRequest )
					
					PrepEnv( cEmpRequest, cFilRequest, "WSTAF020" )
					
				Else
					lAmbiente := .F.
				EndIf
			
			ElseIf cFilAnt <> cFilRequest

				cFilAnt := cFilRequest

			EndIf
	
			If lAmbiente .and. FWFilExist( cEmpRequest, cFilRequest )
	            oResponse := getResponse( cEmpRequest, cFilRequest, nPage, nPageSize, cAuth )
	            self:SetResponse( oResponse:ToJson() )
			Else
				lRet := .F.
				SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" ) + cEmpRequest + EncodeUTF8( "' e Filial '" ) + cFilRequest + "'." )
			EndIf

		EndIf

	EndIf
	
	oResponse := Nil
	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )

//--------------------------------------------------------------------
/*/{Protheus.doc} function getResponse
Retorna as filiais de acordo com os parâmetros informados
@author  Totvs
@since   05/11/2019
@version 12.1.25
/*/
//--------------------------------------------------------------------
Static Function getResponse( cCompanyId as character, cBranchId as character, nPage as numeric, nPageSize as numeric, cAuth as character )
	
	Local aBranches 	as array
	Local nRegFim       as numeric
	Local nRegIni       as numeric
	Local nX            as numeric
	Local oResponse		as object

	Default cAuth 		:= ""

	aBranches 			:= getBranchesByUser(cCompanyId, cBranchId, cAuth)
	nRegFim       		:= 1
	nRegIni       		:= 1
	nX            		:= 1
	nRegIni 			:= ( ( nPage - 1 ) * nPageSize ) + 1
	nRegFim 			:= nPage * nPageSize	
	oResponse           := JsonObject():New()
	oResponse["items"]  := {}

	For nX := nRegIni To nRegFim

		If nX <= Len( aBranches )

			If cCompanyId == ALLTRIM( aBranches[nX][SM0_GRP_EMP] )

				aAdd( oResponse["items"], JsonObject():New() )
				oResponse["items"][Len( oResponse["items"] )]["branchCode"]	        := aBranches[nX][SM0_FILIAL_COD]
				oResponse["items"][Len( oResponse["items"] )]["branchDescription"]	:= EncodeUTF8( Rtrim( StrTran( Upper( aBranches[nX][SM0_FILIAL_DESC] ), "FILIAL", "" ) ) )

			EndIf

		EndIf

	Next nX

	oResponse["hasNext"] := Iif( Len( aBranches ) > nRegFim, .T., .F. )

Return oResponse

/*/{Protheus.doc} getBranchesByUser
	Obtem lista de filiais autorizadas ao usuario via cache de filiais. Caso ainda nao exista o cache, cria-o
	
	@author 	Fabio Mendonca
	@since 		25/07/2024
	@version 	1.0
	@param 		cCompanyId	-> Grupo de Empresas da Requisicao
	@param 		cBranchId	-> Filial da Requisicao
	@param 		cAuth		-> Cabecalho Authorization da Requisicao
	@return 	Array de registro de filiais autorizadas ao usuario no formato:
				-> [GRUPO DE EMPRESA][CODIGO DA FILIAL][DESCRICAO DA FILIAL]
/*/
Static Function getBranchesByUser(cCompanyId as Character, cBranchId as Character, cAuth as Character) as Array

	Local lGlbVarFunctions	as Logical
	Local nPosBranch    	as Numeric
	Local cUID				as Character
	Local cFilInfoKey		as Character
	Local cFilCodeKey		as Character
	Local cIdFilCache		as Character
	Local aProdRur      	as Array
	Local aSM0				as Array
	Local aFilInfo			as Array
	Local aFilCode			as Array

	lGlbVarFunctions	:= FindFunction("hasUKeyByUID")
	nPosBranch			:= 0
	cUserId    			:= IIf(lGlbVarFunctions,;
							   getIdUserFromRequest(cAuth),;
							   "000000")
	cIdFilCache			:= cUserId + cCompanyId + cBranchId
	cUID				:= aWSTAF020GlobalVarIDs()[1] 			 	// wstaf020UID
	cFilCodeKey			:= aWSTAF020GlobalVarIDs()[2] + cIdFilCache // filCodeKey + (cUserId + cCompanyId + cBranchId)
	cFilInfoKey			:= aWSTAF020GlobalVarIDs()[3] + cIdFilCache	// filInfoKey + (cUserId + cCompanyId + cBranchId)
	aFilInfo			:= {}
	aFilCode			:= {}
	aSM0				:= {}

	If lGlbVarFunctions .And. hasUKeyByUID(cUID, cFilInfoKey)
		
		aFilInfo := getGlobalHashMapContent(cUID, cFilInfoKey, API_CODE)

	Else
		aSM0 := Eval({||;
						aSM0RawParsed := {},;
						aEval(FWLoadSM0(), {|branch| aAdd(aSM0RawParsed, { branch[1], branch[2], branch[7], branch[18] })}),;
						aSM0RawParsed};
					)
		
		//Utilizado para obter o CNPJ da filial recebida por parâmetro
		nPosBranch := aScan( aSM0, { |x| AllTrim( x[SM0_GRP_EMP] ) == AllTrim( cCompanyId ) .and. AllTrim( x[SM0_FILIAL_COD] ) == AllTrim( cBranchId ) } )
		aProdRur   := Eval({||;
								aVProdRural := {},;
								aEval(VProdRural(), {|info| aAdd(aVProdRural, { info[7], info[2], info[3] })}),;
								aVProdRural};
							)
		cFil	   := getUserAuthorizedBranches(cUserId)	
			
		If nPosBranch > 0

			If Len( aProdRur ) > 0

				aEval(aProdRur, {|branch| parserBeforeAdd(branch, @aFilInfo, @aFilCode)})

			Else

				cRaizCNPJ := SubStr( aSM0[nPosBranch][SM0_FILIAL_CGC], 1, 8 )
				
				//Monta a cláusula IN com as filiais do grupo de empresas logado--
				aEval( aSM0, { |branch| IIf( !Empty(branch[SM0_FILIAL_CGC]) .And. branch[SM0_GRP_EMP] == cCompanyId .And. (Alltrim(branch[SM0_FILIAL_COD]) $ cFil .Or. '@' $ cFil) .And. ( SubStr( branch[SM0_FILIAL_CGC], 1, 8 ) == cRaizCNPJ ),;
										parserBeforeAdd(branch, @aFilInfo, @aFilCode) , Nil ) } )

			EndIf

			If lGlbVarFunctions

				setGlobalHashMapContent(cUId, cFilInfoKey, aFilInfo, API_CODE)
				setGlobalHashMapContent(cUId, cFilCodeKey, aFilCode, API_CODE)

			EndIf

		EndIf

	EndIf
	
Return aFilInfo

/*/{Protheus.doc} parserBeforeAdd
	Salva filiais autorizadas ao usuarios nos arrays de retorno da API e do envio ao cache

	@author 	Fabio Mendonca
	@since 		18/07/2024
	@version 	1.0
	@param 		aSM0 		-> Array com informacoes da filial corrente da interacao do aEval
	@param 		aFil 		-> Array de registro de filiais autorizadas no formato:
							-> [GRUPO DE EMPRESA][CODIGO DA FILIAL][DESCRICAO DA FILIAL]
	@param 		aFilToCache	-> Array de registro de filiais autorizadas para realizar cache, no formato:
							-> [CODIGO DA FILIAL]
/*/
Static Function parserBeforeAdd(aSM0 as Array, aFil as Array, aFilToCache as Array)
	
	aAdd( aFil, { aSM0[SM0_GRP_EMP], aSM0[SM0_FILIAL_COD], aSM0[SM0_FILIAL_DESC] } )
	aAdd( aFilToCache, aSM0[SM0_FILIAL_COD] )

Return

/*/{Protheus.doc} getUserAuthorizedBranches
	Obtem lista de filiais que o usuario esta autorizado

	@author 	Fabio Mendonca
	@since 		17/07/2024
	@version 	1.0
	@param		cUserId -> ID do usuario a ser pesquisado permissoes
	@return 	Lista de filiais autorizadas ao usuario em formato de string
/*/
Static Function getUserAuthorizedBranches(cUserId as Character) as Character

	Local nY 				as Numeric
	Local cFil				as Character
	Local cPrioSom			as Character
	Local aRetPsw			as Array
	Local aGrupo 			as Array

	cFil				:= ""
	cPrioSom			:= ""
	aRetPsw				:= {}
	aGrupo				:= {}	

	If PswSeek( cUserId , .T. )  

		aRetPsw  := PswRet() // Retorna vetor com informações do usuário

		If Len(aRetPsw)
			
			aGrupo   := FWSFUsrGrps(aRetPsw[1][1]) // Array com o grupo de usuário
			cPrioSom := FWUsrGrpRule(aRetPsw[1][1]) // Priorizar ou Somar as configurações dos grupos

		EndIf


	EndIf

	If cPrioSom $ "1" .AND. Len(aGrupo) > 0

		For nY := 1 To Len(aGrupo)
			cFil += ArrTokStr(FWGrpEmp( aGrupo[nY] ),"|") // Retorna Empresa e filial do Grupo de Usuário			 
		Next

	ElseIf cPrioSom $ "3" .AND. Len(aGrupo) > 0

		cFil := ArrTokStr(aRetPsw[2][6],"|") 

		For nY := 1 To Len(aGrupo)
			cFil += ArrTokStr(FWGrpEmp( aGrupo[nY] ),"|") // Retorna Empresa e filial do Grupo de Usuário			 
		Next

	Else

		cFil := ArrTokStr(FWUsrEmp(cUserId),"|") 

	EndIf	
	
Return cFil

/*/{Protheus.doc} aWSTAF020GlobalVarIDs
	Obtem Identificadores e Keys de Variaveis Globais usados no WSTAF020
	
	@author 	Fabio Mendonca
	@since 		17/07/2024
	@version 	1.0
	@return 	[1] UID da Secao de Variaveis Globais do WSTAF020
				[2] Ukey que faz cache da lista de filiais que o usuario tem acesso
				[3] Ukey que faz cache das permissões do usuário
/*/
Function aWSTAF020GlobalVarIDs()
Return {"wstaf020UID", "filCodeKey", "filInfoKey"}
