#INCLUDE "RESTFUL.CH"
#INCLUDE "TOTVS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TsiBranches
API TAF Fiscal TSI - Retorna todos as filiais do grupo de empresas
@author Renan Gomes
@since 07/04/2022
@version 1.0 
/*/
//------------------------------------------------------------------------------
WSRESTFUL TsiBranches DESCRIPTION "API TSIBranches - Retorna todos as filiais do grupo de empresas" FORMAT APPLICATION_JSON // "API TAF Fiscal TSI - Retorna todos as filiais do grupo de empresas"
	WSDATA companyId	AS STRING

	WSMETHOD GET TsiBranches;
		DESCRIPTION "Retorna todas as filiais do grupo de empresa logada";
		WSSYNTAX "/api/tsi/v1/TsiBranches/?{companyId}";
		PATH "/api/tsi/v1/TsiBranches/";
		TTALK "v1";

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Método para obter a lista de filiais de acordo com o companyId enviado.
@author			Renan Gomes
@since			07/04/2022
@return			lRet - Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET TsiBranches QUERYPARAM companyId WSRESTFUL TsiBranches

Local lRet             := .T.
Local nFil             := 0
Local nCodeError       := 404
Local cMessage         := EncodeUTF8("Empresa|Filial não informado no parâmetro 'companyId' ." )
Local cDetailedMessage := EncodeUTF8("Verifique o parâmetro 'companyId' enviado na requisição.")
Local cHelpUrl         := EncodeUTF8("https://api.totvs.com.br/apidetails/TSIBranches_v1_000.json")
Local aTSIFil          := {}
Local aCompany		   := {}
Local oResponse        := nil
Local oBrancheItem	   := nil
Local cEmpRequest	   := ""
Local cFilRequest	   := ""


//-----------------------------------------------
// Inicialização variáveis do tipo object
//-----------------------------------------------
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault(404,cMessage,.T.,,cDetailedMessage,cHelpUrl)
Else
	aCompany := StrTokArr( self:companyId, "|" )
	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage,cHelpUrl)
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := PADR(alltrim(aCompany[2]),FWSizeFilial())

		If PrepEnv( cEmpRequest, cFilRequest )

			oResponse["branches"]             := {}
			oBrancheItem                      := JSONObject():New()
			oBrancheItem["branchCode"]        := 'Todas'
			oBrancheItem["branchDescription"] := 'Todas'

			Aadd(oResponse["branches"], oBrancheItem)

			aTSIFil := getFilTSI(cFilRequest)

			for nFil := 1 to len(aTSIFil)
				oBrancheItem := JSONObject():New()

				oBrancheItem["branchCode"]        := aTSIFil[nFil][1]
				oBrancheItem["branchDescription"] := alltrim(aTSIFil[nFil][2])
				Aadd(oResponse["branches"], oBrancheItem)
			next

			self:SetResponse(oResponse:toJSON())

		Else
			lRet     := .F.
			cMessage := EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + alltrim(cFilRequest) + "'." )
			SetRestFault(nCodeError,cMessage,.T.,,cDetailedMessage,cHelpUrl)
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

/*/{Protheus.doc} getFilTSI
	(Retorna lista de filiais da empresa logada)
	@author Renan Gomes
	@since 08/04/2022
	@return aRetFil, array, filiais da empresa
/*/
Static Function getFilTSI(cFilRequest)

	Local nFil    := 0
	Local aRetFil := TAFGetFil(.F.,.T.,"C20",.F.,.F.,.F.)

	for nFil := 1 to len(aRetFil)
		//Após o uso da SetRestFault(), em alguns casos, a função TAFGetFil está trazendo apenas a empresa e filial atual na requisição subsequente, por isso essa proteção
		aRetFil[nFil] := iif(ValType(aRetFil[nFil]) == "C", StrTokArr( aRetFil[nFil] , "-" ),aRetFil[nFil])
		//Proteção para evitar retorno zerado da função TAFGetFil. Com a compilação do TAFGetFil() atualizado esse problema não irá mais ocorrer
		aRetFil[nFil] := iif(ValType(aRetFil[nFil]) == "A", aRetFil[nFil] ,{cFilRequest, cFilRequest})
	next

	/*//Apenas utilizar esse trecho se a função TAFGetFil não retornar os dados necessários, criar as variáveis cCodEmp, nFilSM0, lGestao e aFils
	//Se a função TAFGetFil não retornar os dados necessários, utilizo a LoadSM0 para retornar as filiais
	if (len(aRetFil) > 1 .and. (ValType(aRetFil[1]) <> "A")) .or. (len(aRetFil) == 0)
		aFils   := FWLoadSM0()
		for nFilSM0 := 1 to len(aFils)
			//Se utilização gestão corporativa, faço a comparação pela posição 3 da FWLoadSM0 alem do grupo
			If lGestao
				if aFils[nFilSM0][3] == cCodEmp .AND. aFils[nFilSM0][1] == cEmpRequest
					aadd(aRetFil,{aFils[nFilSM0][2],aFils[nFilSM0][7]})
				endif
			else
				if aFils[nFilSM0][1] == cEmpRequest
					aadd(aRetFil,{aFils[nFilSM0][2],aFils[nFilSM0][7]})
				endif
			Endif
		next
	endif
	*/

Return aRetFil
