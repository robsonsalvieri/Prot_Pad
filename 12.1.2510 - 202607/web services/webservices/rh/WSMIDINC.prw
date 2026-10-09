#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"
#INCLUDE "WSMIDINC.CH"

#DEFINE ERRORCODE_DEF	400

/*/{Protheus.doc} GPEEsocialDetailError
Serviço de Detalhamento de Inconsistencias
@author  lidio.oliveira
@since   
@version 1.0
/*/
WSRESTFUL GPEEsocialDetailError DESCRIPTION oEmToAnsi( STR0001 ) FORMAT APPLICATION_JSON
	WSDATA CompanyId	 AS STRING
	WSDATA Key			 AS STRING
	WSDATA branchCode    AS STRING OPTIONAL
	WSDATA eventCode     AS STRING

	WSMETHOD GET DESCRIPTION oEmToAnsi( STR0002 ); 
	WSSYNTAX "api/rh/esocial/v1/GPEEsocialDetailError/"; 
	PATH "api/rh/esocial/v1/GPEEsocialDetailError/"; 
	TTALK "v1"; 
	PRODUCES APPLICATION_JSON   
END WSRESTFUL

/*/{Protheus.doc} GET
Metodo para retornar o detalhamento das inconsistencias
@author  lidio.oliveira
@since   
@version 1.0
/*/
WSMETHOD GET QUERYPARAM CompanyId, Key, branchCode, eventCode WSRESTFUL GPEEsocialDetailError
	Local lRet			:=	.T.
	Local oResponse		:= Nil
	Local cCompId		:= ""
	Local cKey			:= ""
	Local cEvent		:= ""
	Local cEmpAntBck	:= cEmpAnt
    Local cFilAntBck	:= cFilAnt

	DEFAULT Self:companyId 		:= ""
	DEFAULT Self:Key 			:= ""
	DEFAULT Self:branchCode 	:= ""
	DEFAULT Self:eventCode 		:= ""

	cCompId 	:= Self:CompanyId
	cKey    	:= Self:Key
	cEvent		:= StrTran( Self:eventCode , "-")

	If Empty( cCompId )
		lRet := .F.
		SetRestFault( ERRORCODE_DEF, EncodeUTF8( STR0006 ) )
	Else
		aCompany := StrTokArr( cCompId, "|" )
		
		fSetErrorHandler( STR0007 )
		
		If cEmpAntBck <> aCompany[1] .Or. cFilAntBck <> aCompany[2]
			fTrGrpGPE( aCompany[1], aCompany[2], "RJE", "GPE" )
		EndIf

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( ERRORCODE_DEF, EncodeUTF8( STR0006 ) ) // STR0006: "Grupo, Empresa e Filial logada não foram informados no parâmetro 'companyId'."
		ElseIf Empty(cCompId) .Or. Empty(cKey) .Or. Empty(cEvent)
			lRet := .F.
		Else
			fGetError( @oResponse, cCompId, cKey, cEvent )
	        self:SetResponse( oResponse:ToJson() )
		EndIf	
	EndIf

	If cEmpAntBck <> aCompany[1] .Or. cFilAntBck <> aCompany[2]
        fTrGrpGPE(cEmpAntBck, cFilAntBck)
    EndIf

	oResponse := Nil
	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )	


/*/{Protheus.doc} function fGetError
Retorna a descrição do erro
@author  lidio.oliveira
@since   09/01/2020
@version 1.0
/*/
Static Function fGetError( oResponse, cCompId, cKey, cEvent)

	Local cAliasRJE 	:= "RJE"
	Local cRet			:= ""
	Local cRetDesc		:= ""
	Local cMsg			:= ""
	Local cCodOc		:= ""
	Local cDescOc		:= ""
	Local nIni			:= 0
	Local nFim			:= 0
	Local cCabec		:= "/eSocial/retornoEvento/processamento/"
	Local cOcorren		:= ""
	Local nOcorren		:= 0
	Local cIniRet		:= 0
	Local cFimRet		:= 0
	Local cXMLRet		:= ""
	Local oXml 			:= tXmlManager():New()
	
	DEFAULT cCompId		= ""
	DEFAULT cKey		= ""
	DEFAULT cEvent		= ""
		
	//Abre a Tabela RJE para pesquisar o registro recebido nos parâmetros:
	DbSelectArea( "RJE" )
	DbSetOrder( 3 )
	( cAliasRJE )->( DbGoTop() )
	
	oResponse          			:= JsonObject():New()
		
	//Posiciona no registros encontrado:
	If ( cAliasRJE )-> (DbSeek( cEvent + cKey ))
		cRet :=	( cAliasRJE )->RJE_RTN
		If Empty(cRet) .OR. ( cAliasRJE )->RJE_STATUS == "4"
			cMsg := EncodeUTF8(STR0008) // STR0008: "No XML de retorno não consta informações de erros, consulte xml no TSS
			oResponse["description"] 	:= cMsg
		ElseIf !Empty(cRet) .And. ( cAliasRJE )->RJE_STATUS $ "1*3"
			cIniRet := At('<eSocial ', cRet) 
			cFimRet	:= At('</eSocial>', cRet) + 10
			cXMLRet := SubStr( cRet, cIniRet, cFimRet-cIniRet )
			
			If oXml:Parse( fMidTrPath(cXMLRet,"eSocial") ) .And. AT("<cdResposta>", cRet) == 0
				nOcorren := 1
				cOcorren := cCabec + "ocorrencias/ocorrencia[" + cValToChar(nOcorren) + "]"
				
				While oXml:XPathHasNode(cOcorren)
					If oXml:XPathGetNodeValue( cOcorren + "/tipo" ) == "1"
						cMsg += OemToAnsi( STR0014 ) + CRLF
					ElseIf oXml:XPathGetNodeValue( cOcorren + "/tipo" ) $ "2*3"
						cMsg += OemToAnsi( STR0015 + oXml:XPathGetNodeValue( cOcorren + "/tipo" ) +  STR0016 ) + CRLF
					Else
						cMsg += OemToAnsi( STR0015 ) + oXml:XPathGetNodeValue( cOcorren + "/tipo" ) + CRLF
					EndIf
					cMsg 	+= OemToAnsi( STR0011 ) + oXml:XPathGetNodeValue( cOcorren + "/codigo" ) + CRLF
					cMsg 	+= OemToAnsi( STR0012 ) + oXml:XPathGetNodeValue( cOcorren + "/descricao" ) + CRLF
					
					//Imprime localização se houver
					If !Empty(oXml:XPathGetNodeValue( cOcorren + "/localizacao" ))
						cMsg 	+= OemToAnsi( STR0017 ) + oXml:XPathGetNodeValue( cOcorren + "/localizacao" ) + CRLF
					EndIf
											
					cMsg 	+= + CRLF

					nOcorren++
					cOcorren := cCabec + "ocorrencias/ocorrencia[" + cValToChar(nOcorren) + "]"
				EndDo

				oResponse          			:= JsonObject():New()
				oResponse["description"]	:= EncodeUTF8(cMsg)
			Else
				//Código de Erro
				If AT("<cdResposta>", cRet) != 0
					nIni 	 := AT("<cdResposta>", cRet) +12
					nFim 	 := AT("</cdResposta>", cRet)
					cRetDesc := SUBSTR( cRet, nIni, nFim-nIni )
					cMsg := OemToAnsi( STR0009 ) + ALLTRIM(cRetDesc) + CRLF //"Código do Erro: "
				Else
					cMsg := cRet
				EndIf
			
				// Descrição do Erro
				If AT("<descResposta>", cRet) != 0
					nIni 	 := AT("<descResposta>", cRet) +14	
					nFim 	 := AT("</descResposta>", cRet)
					cRetDesc := SUBSTR( cRet, nIni, nFim-nIni )
					cMsg 	 += OemToAnsi( STR0010 ) + ALLTRIM(cRetDesc) + CRLF + CRLF//"Descriçao: "
				EndIf
			
				// Ocorrencias
				If AT("<ocorrencias>", cRet) != 0
					//Busca no xml início e fim da tag ocorrencias
					nIni 	 := AT("<ocorrencias>", cRet)
					nFim 	 := AT("</ocorrencias>", cRet) + 14
					nFimO 	 := AT("</processamento>", cRet)
					cRetDesc := SUBSTR( cRet, nIni, nFim-nIni )
							
						//Código da Ocorrência
						nIni 	 := AT("<codigo>", cRetDesc) + 8
						nFim 	 := AT("</codigo>", cRetDesc)
						cCodOc := SUBSTR( cRetDesc, nIni, nFim-nIni )
						cMsg += OemToAnsi( STR0011 ) + ALLTRIM(cCodOc) + CRLF //"Código da Ocorrência: "
						
						//Descrição da Ocorrência
						nIni 	 := AT("<descricao>", cRetDesc) + 11
						nFim 	 := AT("</descricao>", cRetDesc)
						cDescOc := SUBSTR( cRetDesc, nIni, nFim-nIni )
						cMsg 	 += OemToAnsi( STR0012 ) + ALLTRIM(cDescOc) + CRLF//"Descricao da Ocorrencia: "				
				EndIf
			EndIf		
			
			oResponse          			:= JsonObject():New()
			oResponse["description"]	:= EncodeUTF8(cMsg)
					
		EndIf
	Else
		If Empty(cMsg)
			aAdd( oResponse["description"], JsonObject():New() )
			oResponse["description"]	:= EncodeUTF8( STR0012 ) //"Chave nao encontrada na base de dados"
		EndIf
	EndIf
	
Return

/*/{Protheus.doc} function fSetErrorHandler
Tratamento de Erros
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fSetErrorHandler(cTitle)
	bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)


/*/{Protheus.doc} function fResetErrorHandler
Tratamento de Erros
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fResetErrorHandler(cTitle)
	bError  := { |e| oError := e , Break(e) }
	bErrorBlock    := ErrorBlock( bError )
Return(.T.)
