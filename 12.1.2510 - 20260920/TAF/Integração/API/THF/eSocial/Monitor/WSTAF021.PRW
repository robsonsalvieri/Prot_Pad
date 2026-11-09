#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFEsocialDetailError
@type			method
@description	Serviço para obter o detalhe do erro de transmissão do eSocial.
@author			Matheus Prada
@since			06/04/2020
/*/
//---------------------------------------------------------------------
WSRESTFUL TAFEsocialDetailError DESCRIPTION "Serviço para obter o detalhe do erro de transmissão do eSocial" FORMAT APPLICATION_JSON

	WSDATA companyId	AS STRING
	WSDATA key			AS STRING

	WSMETHOD GET;
		DESCRIPTION "Método para consultar a inconsistência do XML transmitido ao eSocial";
		WSSYNTAX "api/rh/esocial/v1/TAFEsocialDetailError/?{companyId}&{key}";
		PATH "api/rh/esocial/v1/TAFEsocialDetailError/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} GET
@type			method
@description	Método para consultar a inconsistência do XML transmitido ao eSocial.
@author			Matheus Prada
@since			08/05/2020
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET QUERYPARAM companyId, key WSRESTFUL TAFEsocialDetailError

	Local oResponse		:=	Nil
	Local cEmpRequest	:=	""
	Local cFilRequest	:=	""
	Local aCompany		:=	{}
	Local lRet			:=	.T.

	If self:companyId == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	ElseIf self:key == Nil
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Chave única não informada no parâmetro 'key'." ) )
	Else
		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
				XmlError( @oResponse, self:key )
				self:SetResponse( oResponse:ToJson() )
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
			EndIf
		EndIf
	EndIf

	FreeObj( oResponse )
	oResponse := Nil
	DelClassIntF()

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} XmlError
@type			function
@description	Busca o erro da transmissão.
@author			Matheus Prada
@since			08/05/2020
@param			oResponse	-	Json com a descrição do erro de transmissão
@param			cKey		-	Chave única contendo Filial + Eevento + ID + Versão
/*/
//---------------------------------------------------------------------
Static Function XmlError(oResponse, cKey)

	Local cChave		:= ""
	Local cRet			:= ""
	Local cTipoErro		:= ""
	Local cSequencia	:= "" 
	Local nSequencia	:= 0
	Local nTamSeq		:= GetSX3Cache("V2H_SEQERR", "X3_TAMANHO")
	Local cSeqPad		:= StrZero(0, nTamSeq)

	If !Empty(cKey)

		cChave := RTrim(StrTran(cKey, "|", "")) //FILIAL + EVENTO + ID + VERSAO

	EndIf

	oResponse := JsonObject():New()

	V2H->(DBSetOrder(2))
	V2H->(DBGoTop())

	If V2H->(MsSeek(cChave))

		While V2H->(!Eof()) .AND. cChave == RTrim(V2H->(V2H_FILIAL + V2H_IDCHVE))
				
			If !Empty(V2H->V2H_DCERRO)
					
				nSequencia++

				cTipoErro	:= Iif(V2H->V2H_TPERRO == "1", "Erro", "Advertência")
				cSequencia	:= Iif(StrZero(Val(AllTrim(V2H->V2H_SEQERR)), nTamSeq) == cSeqPad, StrZero(nSequencia, nTamSeq), V2H->V2H_SEQERR)
					
				If nSequencia > 1
					
					cRet += CRLF
					
				EndIf

				cRet += "Sequência: " 				+ cSequencia	
				cRet += " - Tipo: " 				+ cTipoErro			
				cRet += " - Codigo da ocorrência: "	+ V2H->V2H_CODERR + CRLF

				If !Empty(AllTrim(V2H->V2H_LOCERR))						
					cRet += "Localização: " + AllTrim(V2H->V2H_LOCERR) + CRLF
				EndIf

				cRet += "Descrição: " + ChangeDesc(V2H->V2H_DCERRO) + CRLF

			ElseIf Empty(V2H->V2H_DCERRO) .And. !Empty(V2H->V2H_DSCREC) 
					
				nSequencia++

				cTipoErro	:= Iif(V2H->V2H_TPERRO == "1", "Erro", "Advertência")
				cSequencia	:= Iif(StrZero(Val(AllTrim(V2H->V2H_SEQERR)), nTamSeq) == cSeqPad, StrZero(nSequencia, nTamSeq), V2H->V2H_SEQERR)
					
				cRet += "Sequência: " 				+ cSequencia	
				cRet += " - Tipo: " 				+ cTipoErro			
				cRet += " - Codigo da ocorrência: "	+ V2H->V2H_CODERR + CRLF
				cRet += "Descrição: " + ChangeDesc(V2H->V2H_DSCREC) + CRLF

			EndIf

			V2H->(DBSkip())

		EndDo

		oResponse["description"] := EncodeUTF8(cRet)

		V2H->(DBCloseArea())

	Else

		T0X->(DBSetOrder(3))
		T0X->(DBGoTop())
		
		If T0X->(MsSeek(cChave))
			cRet 						:= T0X->T0X_DCERRO
			oResponse["description"] 	:= EncodeUTF8(cRet)
		EndIf

		T0X->(DBCloseArea())

	EndIf

	If Empty(cRet)

		oResponse["description"] := EncodeUTF8( "Não foi possível obter o detalhe da inconsistência. Realize a transmissão novamente." )

	EndIf	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChangeDesc
@description Realiza o tratamento da descrição convertendo os caracteres especiais
das entidades HTML para caracteres normais

@param cDescricao - String contendo a descrição a ser tratada

@author Melkz Siqueira
@since 23/11/2021
@version 1.0		

@return cDescricao - Descrição tratada
/*/
//-------------------------------------------------------------------
Static Function ChangeDesc(cDescricao)

	Default cDescricao := ""

	cDescricao := StrTran(StrTran(AllTrim(cDescricao), "#39;", "'"), "quot;", '"')

Return cDescricao
