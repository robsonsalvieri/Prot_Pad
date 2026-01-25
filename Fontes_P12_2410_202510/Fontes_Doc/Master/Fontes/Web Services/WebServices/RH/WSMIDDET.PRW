#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"
#INCLUDE "WSMIDDET.CH"

#DEFINE PAGESIZE_DEF	250
#DEFINE ERRORCODE_DEF	400
#DEFINE TAB  			CHR ( 13 ) + CHR ( 10 )


// STR0001: "Serviço do Monitor de Transmissão do eSocial"
WSRESTFUL GPEEsocialDetailTransmission DESCRIPTION oEmToAnsi( STR0001 ) FORMAT APPLICATION_JSON
	WSDATA companyCode 	AS STRING
	WSDATA branchCode  	AS STRING
	WSDATA id 		   	AS STRING
	WSDATA eventCode	AS STRING
	WSDATA period		AS STRING
	WSDATA status		AS STRING
	WSDATA userId		AS STRING
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL

	/*
		 STR0002: "Método para consultar o detalhamento das tramissões dos eventos do Esocial para o governo"
		 STR0003: "api/rh/esocial/v1/GPEEsocialDetailTransmission/"
		 STR0004: "v1"
	*/
	WSMETHOD POST DESCRIPTION oEmToAnsi( STR0002 );
	WSSYNTAX "api/rh/esocial/v1/GPEEsocialDetailTransmission/";
	PATH "api/rh/esocial/v1/GPEEsocialDetailTransmission/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON
	END WSRESTFUL

WSMETHOD POST WSREST GPEEsocialDetailTransmission

	Local oInput
	Local cRet			:= ""
	Local lRet			:= .T.
	Local aData			:= {}
	Local aHeader		:= {}
	Local aAmb			:= {}
	Local lHasNext		:= .F.
	Local nPageSize		:= PAGESIZE_DEF
	Local nPage			:= 1
	Local cEmpAntBck := cEmpAnt
	Local cFilAntBck := cFilAnt

	oInput 		:= JsonObject():New()
	cBody     	:= ::GetContent()
	oInput:FromJson( cBody )

	BEGIN SEQUENCE

		// Realiza pré-validações
		If lRet := fPreValid( oInput )
			fSetErrorHandler( EncodeUTF8( STR0005 ) ) // STR0005: "Erro ao preparar o ambiente com a Empresa e Filial informados!"

			// Controle de Paginação
			If !Empty( oInput["pageSize"] ) .And. oInput["pageSize"] > 1
				nPageSize := oInput["pageSize"]
			Endif

			IF (nPageSize < PAGESIZE_DEF)
				nPageSize := PAGESIZE_DEF
			EndIf

			If !Empty( oInput["page"] ) .AND. oInput["page"] > 1
				nPage := oInput["page"]
			EndIf

			// Inicialização de Ambiente
			aAmb := StrTokArr( oInput["companyId"], "|")

			If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
				fTrGrpGPE(aAmb[1], aAmb[2], "RJE,RJN", "GPE")
			EndIf

			aHeader := fGetHeader( oInput )
			aHeader := fSortCol( aHeader )
			aData 	:= fGetData( oInput, aHeader, nPage, nPageSize, @lHasNext )
		EndIf

		// Montagem de retorno da API de Processamento
		cRet := fReturn( aHeader, aData, lHasNext, oInput["eventCode"] )
		::SetResponse( cRet )

	RECOVER
		lRet := .F.
		ErrorBlock( bErrorBlock ) // STR0006: "Ocorreu uma falha no retorno da informação."
		SetRestFault(ERRORSRV_DEF, EncodeUTF8( STR0006 ) + TAB + oError:Description, , , , , )
	END SEQUENCE

	If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
		fTrGrpGPE(cEmpAntBck, cFilAntBck)
	EndIf

Return( lRet )


/*/{Protheus.doc} function fPreValid
Função que realiza as pré-validações
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fPreValid( oInput )
	Local lRet 	   	:= .T.
	Local cMessage	:= ""

	If Empty( oInput["companyId"] )
		cMessage := STR0007 // STR0007: "O parâmetro 'companyId' é obrigatório e não foi informado."
		lRet 	 := .F.

	ElseIf Empty( oInput["branches"] )
		cMessage := STR0008 // STR0008: "O parâmetro 'branches' é obrigatório e não foi informado."
		lRet 	 := .F.

	ElseIf Empty( oInput["eventCode"] )
		cMessage := STR0009 // STR0009: "O parâmetro 'eventCode' é obrigatório e não foi informado."
		lRet 	 := .F.
	EndIf

	If !lRet
		SetRestFault(ERRORCODE_DEF, EncodeUTF8( cMessage ), , , , , )
	EndIf
Return lRet


/*/{Protheus.doc} function fReturn
Função que monta a estrutura de retorno da API
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fReturn( aHeader, aData, lHasNext, cEvento )
	Local oRet
	Local oItem
	Local oItems
	Local oColums
	Local oHeader
	Local nX		:= 1
	Local nY		:= 1
	Local aAux		:= {}
	Local aItems	:= {}
	Local aColums	:= {}
	Local aHeadProp	:= {}
	Local cRet		:= ""
	Local aLabel	:= {}

	fSetErrorHandler( EncodeUTF8( STR0032 ) ) // "Falha na leitura dos dados de retorno"

	oRet				:= JsonObject():new()
	oRet["finished"]	:= .T.
	oRet["percent"]		:= 100
	oRet["hasNext"]		:= lHasNext

	aLabel	:= fGetLabel( aHeader, cEvento )

	// Montagem do Header
	If !Empty( aHeader )
		For nX := 1 To Len( aHeader )

			If !aHeader[nX] $ ("RJE_RETKEY|RJE_EXC")
				oHeader := JsonObject():new()

				If aHeader[nX] == "RJE_STATUS"
					oHeader["property"] := "status"
				Else
					oHeader["property"] := aHeader[nX]
				EndIf

				oHeader["label"] 	:= EncodeUTF8( aLabel[nX] )
				If aHeader[nX] == "RJE_DTG" .Or. "dt" $ aHeader[nX]
					oHeader["type"]		:= "date"
				else
					oHeader["type"]		:= "string"
				EndIf

				AAdd( aHeadProp, oHeader )
				FreeObj( oHeader )
			EndIF
		Next nX
	EndIf

	oRet["header"] 	:= aHeadProp

	// Montagem dos dados
	If !Empty( aData )
		aAux := {}

		For nX := 1 To Len( aData )
			oItem   := JsonObject():new()
			aColums := {}

			For nY := 1 To Len( aHeader )
				If aHeader[nY] == "RJE_RETKEY"
					oItem["key"] := aData[nX][nY]
				Else
					If aHeader[nY] != "RJE_EXC"
						oColums := JsonObject():new()

						If aHeader[nY] == "RJE_STATUS"
							oColums["property"] := "status"

							// Se registro estiver excluído
							If ALLTRIM( aData[nX][1] ) == "1"
								oColums["value"] 	:= "5" // Front-End espera receber status 5 para tratar corretamente os registros excluídos
							Else
								oColums["value"] 	:= ALLTRIM( aData[nX][nY] )
								oItem["hasError"] 	:= IIf( ALLTRIM( aData[nX][nY] ) == "3" .AND. ALLTRIM( aData[nX][1] ) != "1", .T., .F.)
							EndIf

						ElseIf aHeader[nY] == "RJE_RETF"
							oColums["property"] := aHeader[nY]

							If ALLTRIM( aData[nX][nY] ) == "1"
								oColums["value"] := EncodeUTF8( "Não" )
							Else
								oColums["value"] := EncodeUTF8( "Sim" )
							EndIf
						Else
							oColums["property"] := aHeader[nY]
							oColums["value"] 	:= ALLTRIM( aData[nX][nY] )
						EndIf

						If aHeader[nY] == "error" .And. oItem["hasError"]
							oColums["value"] 	:= EncodeUTF8(STR0050)
						EndIf

						AAdd( aColums, oColums )
						FreeObj( oColums )
					EndIf
				EndIf
			Next nY

			oItem["columns"] := aColums

			AAdd( aAux, oItem )
			FreeObj( oItem )
		Next nX
	EndIf

	oItems 		 	:= JsonObject():new()
	oItems["item"] 	:= aAux

	AAdd( aItems, oItems )
	FreeObj( oItems )

	oRet["items"] := aItems

	// Compactação do objeto JSON
	cRet := fCompress( oRet )
	FreeObj( oRet )
	fResetErrorHandler()

Return cRet


/*/{Protheus.doc} function fGetLabel
Função responsável por montar as labels que serão exibidas na tela
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fGetLabel( aHeader, cEvento )
	Local aLabel := {}
	Local nX 	 := 1

	For nX := 1 To Len( aHeader )
		If aHeader[nX] == "RJE_STATUS"
			aadd( aLabel, "Status") // "status"

		ElseIf aHeader[nX] == "RJE_RETKEY"
			aadd( aLabel, "key" ) // "key"

		// S1000
		ElseIf aHeader[nX] == "RJE_TPINSC"
			aadd( aLabel, STR0010 ) // "Tipo de Inscrição"

		ElseIf aHeader[nX] == "RJE_INSCR"
			aadd( aLabel, STR0011 ) // "Número de Inscrição"

		ElseIf aHeader[nX] == "nmRazao"
			aadd( aLabel, STR0012 ) // "Nome Razão Social"

		// S1010
		ElseIf aHeader[nX] == "RJE_RETF"
			aadd( aLabel, STR0013 ) // "Retificação"

		ElseIf aHeader[nX] == "RJE_DTG"
			aadd( aLabel, STR0014  ) // "Data de Geração"

		ElseIf aHeader[nX] == "RJE_HORAG"
			aadd( aLabel, STR0015 ) // "Hora de Geração"

		ElseIf aHeader[nX] == "codRubr"
			aadd( aLabel, STR0016  ) // "Código da Rubrica"

		ElseIf aHeader[nX] == "ideTabRubr"
			aadd( aLabel, STR0017 ) // "Ident. Tabela de Rubrica"

		ElseIf aHeader[nX] == "dscRubr"
			aadd( aLabel, STR0018 ) // "Descrição da Rubrica"

		// S-1020
		ElseIf aHeader[nX] == "codLotacao"
			aadd( aLabel, STR0019 ) // "Código Lotação"

		ElseIf aHeader[nX] == "tpLotacao"
			aadd( aLabel, STR0020 ) // "Tipo da Lotação"

		// S-1030
		ElseIf aHeader[nX] == "codCargo"
			aadd( aLabel, STR0021 ) // "Código do Cargo"

		ElseIf aHeader[nX] == "nmCargo"
			aadd( aLabel, STR0022 ) // "Número do Cargo"

		// S-1035
		ElseIf aHeader[nX] == "codCarreira"
			aadd( aLabel, STR0023 ) // "Código da Carreira"

		ElseIf aHeader[nX] == "dscCarreira"
			aadd( aLabel, STR0024 ) // "Descrição da Carreira"

		// S-1040
		ElseIf aHeader[nX] == "codFuncao"
			aadd( aLabel, STR0025 ) // "Código da Função"

		ElseIf aHeader[nX] == "dscFuncao"
			aadd( aLabel, STR0026 ) // "Descrição da Função"

		// S-1050
		ElseIf aHeader[nX] == "codHorContrat"
			aadd( aLabel, STR0027 ) // "Código Horário de Trabalho"

		// S-1060
		ElseIf aHeader[nX] == "codAmb"
			aadd( aLabel, STR0028 ) // "Código do Ambiente"

		ElseIf aHeader[nX] == "nmAmb"
			aadd( aLabel, STR0029 ) // "Nome do Ambiente"

		// S-1070
		ElseIf aHeader[nX] == "tpProc"
			aadd( aLabel, STR0030 ) // "Tipo do Processo"

		ElseIf aHeader[nX] == "nrProc"
			aadd( aLabel, STR0031 ) // "Nome do Processo"

		ElseIf aHeader[nX] == "RA_CIC"
			aadd( aLabel, STR0034 ) // "CPF do Trabalhador"

		ElseIf aHeader[nX] == "RA_NOME"
			aadd( aLabel, STR0035 ) // "Nome do Trabalhador"

		ElseIf aHeader[nX] == "RA_MAT"
			aadd( aLabel, STR0036 ) // "Matrícula do Trabalhador"

		ElseIf aHeader[nX] == "dtAlteracao"
			aadd( aLabel, STR0037   ) // "Data de Alteração"

		ElseIf aHeader[nX] == "RA_FILIAL"
			aadd( aLabel, STR0038 ) // "Filial do Trabalhador"

		ElseIf aHeader[nX] == "RJE_KEY" .And. cEvento $ "S-2190,S-2200,S-2205,S-2206,S-2230,S-2298,S-2299,S-2300,S-2306,S-2399"
			aadd( aLabel, STR0039 ) // "Matrícula eSocial"

		ElseIf aHeader[nX] == "RJE_KEY" .And. cEvento $ "S-1005,S-1200,S-1210,S-1280,S-1295,S-1298,S-1299,S-1300"
			aadd( aLabel, STR0051 ) // "Chave de Identificação"

		ElseIf aHeader[nX] == "codMotAfast"
			aadd( aLabel, STR0040 ) // "Cód. Mot. Afast."

		ElseIf aHeader[nX] == "dtIniAfast"
			aadd( aLabel, STR0041 ) // "Data Início Afast."

		ElseIf aHeader[nX] == "dtTermAfast"
			aadd( aLabel, STR0042 ) // "Data Fim Afast."

		ElseIf aHeader[nX] == "perApur"
			aadd( aLabel, STR0043 ) // "Competência"

		ElseIf aHeader[nX] == "dtDeslig"
			aadd( aLabel, STR0044 ) // "Data de Desligamento"
		ElseIf aHeader[nX] == "dtEfetRetorno"
			aadd( aLabel, STR0045 ) // "Data Efetivação Retorno"
		ElseIf aHeader[nX] == "dtEfeito"
			aadd( aLabel, STR0046 ) // "Data Efeito"
		ElseIf aHeader[nX] == "indApuracao"
			aadd( aLabel, STR0047 ) // "Indic. de Apuração"
		ElseIf aHeader[nX] == "RJE_RECIB"
			aadd( aLabel, STR0048 ) // "Recibo de Transmissão"
		ElseIf aHeader[nX] == "RJE_FIL"
			aadd( aLabel, STR0049 ) // "Filial"
		ElseIf aHeader[nX] == "dtAcid"
			aadd( aLabel, STR0052 ) // "Data do Acidente"
		ElseIf aHeader[nX] == "tpAcid"
			aadd( aLabel, STR0053 ) // "Tipo do Acidente"
		ElseIf aHeader[nX] == "tpExameOcup"
			aadd( aLabel, STR0054 ) // "Tipo do Exame"
		ElseIf aHeader[nX] == "dtAso"
			aadd( aLabel, STR0055 ) // "Data de Emissão"
		ElseIf aHeader[nX] == "dtIniCondicao"
			aadd( aLabel, STR0056 ) // "Data de Início Condição"
		ElseIf aHeader[nX] == "RJE_USRXML"
			aadd( aLabel, STR0057 ) // "Usuário Alteração XML"
		ElseIf aHeader[nX] == "cpfTrab"
			aadd( aLabel, STR0034 ) // "CPF do Trabalhador"
		ElseIf aHeader[nX] == "nmTrab"
			aadd( aLabel, STR0035 ) // "Nome do Trabalhador"
		ElseIf aHeader[nX] == "nrProcTrab"
			aadd( aLabel, STR0058 ) // "Nr. Processo"
		ElseIf aHeader[nX] == "perApurPgto"
			aadd( aLabel, STR0061 ) // "Mês Pagto Parcela"
		ElseIf aHeader[nX] == "dtExame"
			aadd( aLabel, STR0066 ) // "Data do Exame"
		ElseIf aHeader[nX] == "ideSeqProc"
			aadd( aLabel, STR0064 ) // "Número da Sequência"
		ElseIf aHeader[nX] == "tpEvento"
			aadd( aLabel, STR0065 ) // "Tipo do Evento"
		Else
			aadd( aLabel, "" )
		EndIf
	Next nX

Return aLabel


/*/{Protheus.doc} function fGetHeader
Função que monta os campos que serão retornados de acordo com o evento filtrado
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Function fGetHeader( oInput )
	Local aHeader 	:= {}

	// Adiciona campos que controle da API
	aadd( aHeader, "RJE_STATUS" )
	aadd( aHeader, "RJE_RETKEY" )
	aadd( aHeader, "RJE_EXC" )

	// Adiciona campos necessários para todos os eventos
	aadd( aHeader, "RJE_RETF" )
	aadd( aHeader, "RJE_DTG" )
	aadd( aHeader, "RJE_HORAG" )
	aadd( aHeader, "error" )

	// Adiciona somente os campos necessários de acordo com cada evento
	If oInput["eventCode"] == "S-1000"
		aadd( aHeader, "RJE_TPINSC" )
		aadd( aHeader, "RJE_INSCR" )
		aadd( aHeader, "nmRazao" )

	ElseIf oInput["eventCode"] == "S-1005"
		aadd( aHeader, "RJE_TPINSC" )
		aadd( aHeader, "RJE_INSCR" )

	ElseIf oInput["eventCode"] == "S-1010"
		aadd( aHeader, "codRubr" )
		aadd( aHeader, "ideTabRubr" )
		aadd( aHeader, "dscRubr" )

	ElseIf oInput["eventCode"] == "S-1020"
		aadd( aHeader, "RJE_TPINSC" )
		aadd( aHeader, "RJE_INSCR" )
		aadd( aHeader, "codLotacao" )
		aadd( aHeader, "tpLotacao" )

	ElseIf oInput["eventCode"] == "S-1030"
		aadd( aHeader, "codCargo" )
		aadd( aHeader, "nmCargo" )

	ElseIf oInput["eventCode"] == "S-1035"
		aadd( aHeader, "codCarreira" )
		aadd( aHeader, "dscCarreira" )

	ElseIf oInput["eventCode"] == "S-1040"
		aadd( aHeader, "codFuncao" )
		aadd( aHeader, "dscFuncao" )

	ElseIf oInput["eventCode"] == "S-1050"
		aadd( aHeader, "codHorContrat" )

	ElseIf oInput["eventCode"] == "S-1060"
		aadd( aHeader, "codAmb" )
		aadd( aHeader, "nmAmb" )

	ElseIf oInput["eventCode"] == "S-1070"
		aadd( aHeader, "tpProc" )
		aadd( aHeader, "nrProc" )
	EndIf

	If oInput["eventCode"] $ "S-2190,S-2200,S-2205,S-2206,S-2210,S-2220,S-2230,S-2240,S-2298,S-2299,S-2300,S-2306,S-2399"
		aadd( aHeader, "RA_CIC" )
		aadd( aHeader, "RA_NOME" )
		aadd( aHeader, "RA_FILIAL" )
	EndIf

	If oInput["eventCode"] $ "S-1200,S-1210"
		aadd( aHeader, "RA_CIC" )
		aadd( aHeader, "RA_NOME" )
		aadd( aHeader, "RJE_FIL" )
	EndIf

	If oInput["eventCode"] $ "S-1005,S-1200,S-1210,S-1280,S-1295,S-1298,S-1299,S-1300,S-2190,S-2200,S-2205,S-2206,S-2230,S-2298,S-2299,S-2300,S-2306,S-2399"
		aadd( aHeader, "RJE_KEY" )
	EndIf

	If oInput["eventCode"] $ "S-1280,S-1295,S-1298,S-1299,S-1300"
		aadd( aHeader, "indApuracao" )
		aadd( aHeader, "RJE_RECIB" )
	EndIf

	If oInput["eventCode"] $ "S-1005,S-1010,S-1280,S-1295,S-1298,S-1299,S-1300"
		aadd( aHeader, "RJE_FIL" )
	EndIf

	If oInput["eventCode"] $ "S-1200,S-1210,S-1280,S-1295,S-1298,S-1299,S-1300"
		aadd( aHeader, "perApur" )
	EndIf

	If oInput["eventCode"] $ "S-2200,S-2205,S-2206,S-2210,S-2220,S-2230,S-2240,S-2298,S-2299,S-2300,S-2399"
		aadd( aHeader, "RA_MAT" )
	EndIf

	If oInput["eventCode"] $ "S-2205,S-2206,S-2306"
		aadd( aHeader, "dtAlteracao" )
	EndIf

	If oInput["eventCode"] $ "S-2210"
		aadd( aHeader, "dtAcid" )
		aadd( aHeader, "tpAcid" )
	EndIf

	If oInput["eventCode"] $ "S-2220"
		aadd( aHeader, "tpExameOcup" )
		aadd( aHeader, "dtAso" )
	EndIf

	If oInput["eventCode"] $ "S-2221"
		aadd( aHeader, "cpfTrab" )
		aadd( aHeader, "matricula" )
		aadd( aHeader, "RA_NOME" )
		aadd( aHeader, "dtExame" )
	EndIf

	If oInput["eventCode"] $ "S-2230"
		aadd( aHeader, "codMotAfast" )
		aadd( aHeader, "dtIniAfast" )
		aadd( aHeader, "dtTermAfast" )
	EndIf

	If oInput["eventCode"] $ "S-2240"
		aadd( aHeader, "dtIniCondicao" )
	EndIf

	If oInput["eventCode"] $ "S-2299,S-2399"
		aadd( aHeader, "dtDeslig" )
	EndIf

	If oInput["eventCode"] $ "S-2298"
		aadd( aHeader, "dtEfetRetorno" )
		aadd( aHeader, "dtEfeito" )
	EndIf

	If oInput["eventCode"] $ "S-2500"
		aadd( aHeader, "cpfTrab" )
		aadd( aHeader, "nmTrab" )
		aadd( aHeader, "nrProcTrab" )
		aadd( aHeader, "origem" )
	EndIf

	If oInput["eventCode"] $ "S-2501"
		aadd( aHeader, "perApurPgto" )
		aadd( aHeader, "nrProcTrab" )
		aadd( aHeader, "ideSeqProc" )
	EndIf

	If oInput["eventCode"] $ "S-2555"
		aadd( aHeader, "nrProcTrab" )
		aadd( aHeader, "perApurPgto" )
	EndIf

	If oInput["eventCode"] $ "S-3500"
		aadd( aHeader, "tpEvento")
		aadd( aHeader, "nrProcTrab" )
		aadd( aHeader, "perApurPgto" )
		aadd( aHeader, "ideSeqProc" )
	EndIf

	aadd( aHeader, "RJE_USRXML" )

Return aHeader


/*/{Protheus.doc} function fGetData
Função que consulta e retorna os valores dos campos no banco de dados
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fGetData( oInput, aHeader, nPage, nPageSize, lHasNext )
	Local nX 		:= 1
	Local aData		:= {}
	Local aAux		:= {}
	Local aControl	:= {}
	Local cXML		:= ""
	Local cQuery	:= ""
	Local cBranQry  := ""
	Local cFieldRJE	:= ""
	Local cDtDeslig := ""
	Local cPerApur	:= ""
	Local cIndApur	:= ""
	Local cAliasRJE	:= GetNextAlias()
	Local lCpoFil	:= RJE->(ColumnPos("RJE_DTEVE")) > 0

	fSetErrorHandler( EncodeUTF8( STR0033 ) ) // "Falha ao buscar dados do cliente!"

	// Verifica conexões abertas
	If Select ("RJE") > 0
		RJE->( dbCloseArea() )
	EndIf

	cBranQry := fGetFil( oInput["eventCode"], oInput["branches"] ) // Retorno da Filial origem da RJE

	// Array de controle de campos - Campos necessários para tratamento dos dados na API
	aadd( aControl, "RJE_XML" )
	aadd( aControl, "RJE_EVENTO" )

	// Montagem dos campos que serão retornados na consulta da tabela RJE
	cFieldRJE := ""
	For nX := 1 To Len( aControl )
		cFieldRJE += aControl[nX]

		If nX != Len( aControl )
			cFieldRJE += ","
		EndIf
	Next nX

	cFieldRJE += ","

	For nX := 1 To Len( aHeader )
		IF AT("RJE_",  aHeader[nX] ) == 1
			cFieldRJE += aHeader[nX ]

			If nX != Len( aHeader )
				cFieldRJE += ","
			EndIf
		EndIf
	Next nX

	If SUBSTR( cFieldRJE, -1) == ","
		cFieldRJE := SUBSTR( cFieldRJE, 0, LEN( cFieldRJE )-1 )
	EndIf

	// Montagem da consulta
	cQuery := "SELECT * FROM ( "
	cQuery += "SELECT ROW_NUMBER() OVER(ORDER BY RJE_INSCR) ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER,"
	cQuery += cFieldRJE + " FROM " + RetSqlName("RJE")
	cQuery += " WHERE RJE_EVENTO = '" + REPLACE(oInput["eventCode"], "-", "") + "' "

	If !Empty( ALLTRIM( oInput["period"] ) ) .AND. !oInput["eventCode"] $ ("S-1299,S-2190,S-2200,S-2205,S-2206,S-2230,S-2250,S-2260,S-2298,S-2299,S-2300,S-2306,S-2399,S-3000")
		cQuery += "AND RJE_INI = '" + REPLACE( oInput["period"], "/", "" ) + "' "
	EndIf

	If lCpoFil .And. (oInput["eventCode"] == "S-2230" .Or. oInput["eventCode"] == "S-2200") .And. !Empty(oInput["periodFrom"]) .And. !Empty(oInput["periodTo"])
		cQuery += "AND RJE_DTEVE BETWEEN '" + oInput["periodFrom"] + "' AND '" + oInput["periodTo"] + "' "
	EndIf

	If ValType(oInput["status"]) == "C" .And. !Empty( ALLTRIM( oInput["status"] ) ) .AND. ALLTRIM( oInput["status"] ) != "-1"
		cQuery += "AND RJE_STATUS = '" + ALLTRIM( oInput["status"] ) + "' "
	ElseIf ValType(oInput["status"]) == "A"
		If !Empty(oInput["status"]) .And. !Empty(oInput["status"][1]) .And. ValType(oInput["status"][1]) == "C"
			If ALLTRIM( oInput["status"][1] ) != "-1"
				cQuery += " AND RJE_STATUS IN ("
				aEval(oInput["status"], { |x| cQuery += "'" + x + "'," })
				cQuery := LEFT(cQuery, Len(cQuery)-1)
				cQuery += ") "
				cQuery += "AND RJE_EXC <> '1' "
			Else
				cQuery += "AND RJE_EXC = '1' "
			EndIf
		EndIf
	EndIf

	If ValType(oInput["status"]) == "C" .And. ALLTRIM( oInput["status"] ) == "-1"
		cQuery += "AND RJE_EXC = '1' "
	EndIf

	cQuery += "AND " + RetSqlName("RJE") + ".D_E_L_E_T_ <> '*' "
	cQuery += "AND RJE_FIL IN ( " + cBranQry + ") ) QRY "
	cQuery += "WHERE (QRY.ITEMNUMBER BETWEEN " + Alltrim(Str((nPage - 1) * nPageSize + 1)) + " AND " + Alltrim(Str((nPage * nPageSize))) + ") "

	// Execute Query
	cQuery := ChangeQuery(cQuery)
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cAliasRJE, .T., .T. )

	// Pega todas as ocorrências encontradas na consulta
	aData 		:= {}
	aAux		:= {}
	cXML		:= ""

	While ( cAliasRJE )->( !Eof() )
		// Pega o XML
		dbSelectArea( "RJE" )
		( "RJE" )->( DbSetOrder( 3 ) ) // RJE_EVENTO, RJE_RETKEY
		( "RJE" )->( DbGoTop() )

		If ( "RJE" )->( DbSeek( ( cAliasRJE )->RJE_EVENTO + ( cAliasRJE )->RJE_RETKEY ) )
			cXML := ( "RJE" )->RJE_XML
		EndIf

		// Preenchimento do retorno
		For nX := 1 To Len( aHeader )

			If aHeader[nX] $ ( "RJE_DTG" )
				AADD( aAux, SUBSTR( ( cAliasRJE )->&( aHeader[nX] ), 0, 4 ) + "-" + SUBSTR( ( cAliasRJE )->&( aHeader[nX] ), 5, 2 ) + "-" + SUBSTR( ( cAliasRJE )->&( aHeader[nX] ), 7, 2 ) )

			ElseIf aHeader[nX] == "RJE_XML"
				AADD( aAux, cXML )

			ElseIf aHeader[nX] == "RJE_FIL"
				AADD( aAux, ("RJE")->RJE_FIL )

			ElseIf SUBSTR( aHeader[nX], 0, 4 ) == "RJE_"
				AADD( aAux, ( cAliasRJE )->&( aHeader[nX] ) )

			ElseIf aHeader[nX] == "RA_FILIAL"
				AADD( aAux, ("RJE")->RJE_FIL )

			ElseIf SUBSTR( aHeader[nX], 0, 3 ) == "RA_"
				AADD( aAux, fGetSRA( cXML, aHeader[nX], ( "RJE" )->RJE_FIL, ( cAliasRJE )->RJE_EVENTO ) )

			ElseIf aHeader[nX] == "perApur"
				cPerApur := fGetXML( aHeader[nX], cXML )
				cPerApur := SUBSTR(cPerApur, 0, 4) + "/" + SUBSTR(cPerApur, 6, 2)
				AADD( aAux, cPerApur )

			ElseIf aHeader[nX] == "indApuracao"
				cIndApur := fGetXML( aHeader[nX], cXML )
				AADD( aAux, cIndApur )

			ElseIf aHeader[nX] == "dtDeslig"
				cDtDeslig := fGetXML( aHeader[nX], cXML )

				If Empty( cDtDeslig )
					cDtDeslig := fGetXML( "dtTerm", cXML )
				EndIf

				AADD( aAux, cDtDeslig )

			ElseIf aHeader[nX] == "nmRazao" .And. Findfunction("GPENorStrES")
				AADD( aAux, GPENorStrES(fGetXML( aHeader[nX], cXML ),2) )

			ElseIf aHeader[nX] == "origem"

				cOrigem := fGetXML( aHeader[nX], cXML )

				If cOrigem == "1"
					cOrigem := STR0062 //"PROCESSO JUDICIAL"
				ElseIf cOrigem == "2"
					cOrigem := STR0063 //"DEMANDA SUBMETIDA À CCP OU AO NINTER"
				EndIf

				AADD( aAux, cOrigem)

			Else
				AADD( aAux, fGetXML( aHeader[nX], cXML ) )
			EndIf

		Next nX

		AADD( aData, aAux )
		aAux := {}
		( cAliasRJE )->( DBSkip() )
	EndDo

	( cAliasRJE )->( DbCloseArea() )

	cQuery := "SELECT MAX( ITEMNUMBER ) MAX_LINE FROM ("
	cQuery += "SELECT ROW_NUMBER() OVER(ORDER BY RJE_INSCR) ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER,"
	cQuery += cFieldRJE + " FROM " + RetSqlName("RJE")
	cQuery += " WHERE RJE_EVENTO = '" + REPLACE(oInput["eventCode"], "-", "") + "' "

	If !Empty( ALLTRIM( oInput["period"] ) )
		cQuery += "AND RJE_INI = '" + REPLACE( oInput["period"], "/", "" ) + "' "
	EndIf

	If ValType(oInput["status"]) == "C" .And. !Empty( ALLTRIM( oInput["status"] ) ) .AND. ALLTRIM( oInput["status"] ) != "-1"
		cQuery += "AND RJE_STATUS = '" + ALLTRIM( oInput["status"] ) + "' "
	ElseIf ValType(oInput["status"]) == "A"
		If !Empty(oInput["status"]) .And. !Empty(oInput["status"][1]) .And. ValType(oInput["status"][1]) == "C"
			If ALLTRIM( oInput["status"][1] ) != "-1"
				cQuery += " AND RJE_STATUS IN ("
				aEval(oInput["status"], { |x| cQuery += "'" + x + "'," })
				cQuery := LEFT(cQuery, Len(cQuery)-1)
				cQuery += ") "
				cQuery += "AND RJE_EXC <> '1' "
			Else
				cQuery += "AND RJE_EXC = '1' "
			EndIf
		EndIf
	EndIf

	If ValType(oInput["status"]) == "C" .And. ALLTRIM( oInput["status"] ) == "-1"
		cQuery += "AND RJE_EXC = '1' "
	EndIf

	cQuery += "AND " + RetSqlName("RJE") + ".D_E_L_E_T_ <> '*' "
	cQuery += "AND RJE_FIL IN ( " + cBranQry + ") ) QRY "

	// Execute Query
	cQuery := ChangeQuery(cQuery)
	DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cAliasRJE, .T., .T. )

	If (cAliasRJE)->( !Eof() )
		If (cAliasRJE)->MAX_LINE > nPage * nPageSize
			lHasNext := .T.
		EndIf
	EndIf
	(cAliasRJE)->( DBCloseArea() )
	fResetErrorHandler()

Return aData


/*/{Protheus.doc} function fGetSRA
Retorna os dados da SRA
@author  Hugo de Oliveira
@since   08/01/2020
@version 1.0
/*/
Static Function fGetSRA( cXML, cField, cFilRJE, cEvt )
	Local cRet 		:= ""
	Local cCIC 		:= ""
	Local cSRA		:= "SRA"
	Local cCodUnic	:= ""

	If !Empty(cXML)
		If cEvt == "S1210"
			cCIC := fGetXML( "cpfBenef", cXML )
		Else
			cCIC := fGetXML( "cpfTrab", cXML )
		EndIf
		cCodUnic := fGetXML( "matricula", cXML )

		If cField == "RA_CIC"
			cRet := cCIC

		Else
			If !Empty(cCodUnic)
				dbSelectArea( cSRA )
				( cSRA )->( DbSetOrder(24) ) // CodUnic
				( cSRA )->( DbGoTop() )

				If ( cSRA )->( dbSeek( cCodUnic ) )
					cRet := ALLTRIM( ( cSRA )->&( cField ))
				EndIf
			Else
				dbSelectArea( cSRA )
				( cSRA )->( DbSetOrder(5) ) // Filial + CPF
				( cSRA )->( DbGoTop() )

				If ( cSRA )->( dbSeek( cFilRJE + cCIC ) )
					cRet := ALLTRIM( ( cSRA )->&( cField ))
				EndIf
			EndIf
		EndIf
	EndIf

Return cRet


/*/{Protheus.doc} function fCompress
Função que compacta e converte objeto JSON para String
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.

	// Set gzip format to Json Object
	cJson := oObj:toJSON()

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf

	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif
Return cComp


/*/{Protheus.doc} function fGetXML
Retorna o valor de uma TAG do XML informado
@author  Hugo de Oliveira
@since   09/12/2019
@version 1.0
/*/
Static Function fGetXML( cTAG, cXML )
	Local nIni 	:= 0
	Local nFim 	:= 0
	Local cData := ""

	nIni 	:= AT("<" + cTAG + ">",  cXML )
	nFim 	:= AT("</" + cTAG + ">", cXML )
	cData 	:= ALLTRIM( STRTRAN(  SUBSTR( cXML, nIni, nFim-nIni ), "<" + cTAG + ">","" ) )

Return cData


/*/{Protheus.doc} function fCompress
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


/*/{Protheus.doc} function fGetFil
Função que retorna as filiais de acordo com o compartilhamento da tabela que originou o evento gravado na RJE
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fGetFil( cEvent, aBranch )
	Local aRet		:= {}
	Local cRet  	:= ""
	Local nX 		:= 1
	Local nY		:= 1
	Local lParcial 	:= .F.

	For nX := 1 TO LEN( aBranch )
		If cEvent == "S-1005"
			AADD( aRet, aBranch[nX] )

			If fVldObraRJ(@lParcial, .F.) .And. !lParcial
				AADD( aRet, xFilial( "RJ4", aBranch[nX] ) )
			Else
				AADD( aRet, xFilial( "CTT", aBranch[nX] ) )
			EndIf

		ElseIf cEvent == "S-1010"
			AADD( aRet, xFilial( "SRV", aBranch[nX] ) )

		ElseIf cEvent == "S-1020"
			If fVldObraRJ(@lParcial, .F.) .And. !lParcial
				AADD( aRet, xFilial( "RJ3", aBranch[nX] ) )
			Else
				AADD( aRet, xFilial( "CTT", aBranch[nX] ) )
			EndIf

		ElseIf cEvent == "S-1030"
			If SuperGetMv("MV_CARGSQ3",,.F.)
				AADD( aRet, xFilial( "SQ3", aBranch[nX] ) )
			Else
				AADD( aRet, xFilial( "SRJ", aBranch[nX] ) )
			EndIf

		ElseIf cEvent == "S-1035"
			AADD( aRet, xFilial( "SGY", aBranch[nX] ) )

		ElseIf cEvent == "S-1040"
			AADD( aRet, xFilial( "SRJ", aBranch[nX] ) )

		ElseIf cEvent == "S-1050"
			AADD( aRet, xFilial( "SR6", aBranch[nX] ) )

		ElseIf cEvent $ ("S-1000|S-1200|S-1210|S-1280|S-1295|S-1298|S-1299|S-1300|S-2190|S-2200|S-2205|S-2206|S-2210|S-2220|S-2221|S-2230|S-2240|S-2250|S-2260|S-2298|S-2299|S-2300|S-2306|S-2399|S-2500|S-2501|S-2555|S-3000|S-3500")
			AADD( aRet, aBranch[nX] )
		EndIf
	Next nX

	// Preenchimento das filiais no retorno
	cRet := ""
	For nY := 1 To LEN( aRet )
		cRet += " '" + aRet[nY] + "' "

		If nY != LEN( aRet )
			cRet += ","
		EndIf
	Next nY

Return cRet



/*/{Protheus.doc} function fSortCol
Realiza a ordenação das colunas a serem exibidas
@author  Hugo de Oliveira
@since   10/01/2020
@version 1.0
/*/
Static Function fSortCol( aData )
	Local nX 		:= 1
	Local cEvtRJE 	:= ""
	Local nInd		:= 0
	Local aInd		:= {}
	Local aBox		:= {}

	// Cria uma nova posição no Array de dados para servir de "Índice" e assim poder ser ordenado
	For nX := 1 To Len( aData )
		cEvtRJE := aData[nX]

		If cEvtRJE == "RJE_STATUS"
			nInd := 1
		ElseIf cEvtRJE == "RA_CIC"
			nInd := 2
		ElseIf cEvtRJE == "RA_FILIAL"
			nInd := 3
		ElseIf cEvtRJE == "RA_MAT"
			nInd := 4
		ElseIf cEvtRJE == "RJE_FIL"
			nInd := 5
		ElseIf cEvtRJE == "RJE_KEY"
			nInd := 6
		ElseIf cEvtRJE == "RA_NOME"
			nInd := 7
		ElseIf cEvtRJE == "RJE_TPINSC"
			nInd := 8
		ElseIf cEvtRJE == "RJE_INSCR"
			nInd := 9
		ElseIf cEvtRJE == "nmRazao"
			nInd := 10
		ElseIf cEvtRJE == "codRubr"
			nInd := 11
		ElseIf cEvtRJE == "ideTabRubr"
			nInd := 12
		ElseIf cEvtRJE == "dscRubr"
			nInd := 13
		ElseIf cEvtRJE == "codLotacao"
			nInd := 14
		ElseIf cEvtRJE == "tpLotacao"
			nInd := 15
		ElseIf cEvtRJE == "codCargo"
			nInd := 16
		ElseIf cEvtRJE == "nmCargo"
			nInd := 17
		ElseIf cEvtRJE == "codCarreira"
			nInd := 18
		ElseIf cEvtRJE == "dscCarreira"
			nInd := 19
		ElseIf cEvtRJE == "codFuncao"
			nInd := 20
		ElseIf cEvtRJE == "dscFuncao"
			nInd := 21
		ElseIf cEvtRJE == "codHorContrat"
			nInd := 22
		ElseIf cEvtRJE == "codAmb"
			nInd := 23
		ElseIf cEvtRJE == "nmAmb"
			nInd := 24
		ElseIf cEvtRJE == "tpProc"
			nInd := 25
		ElseIf cEvtRJE == "nrProc"
			nInd := 26
		ElseIf cEvtRJE == "dtAlteracao"
			nInd := 27
		ElseIf cEvtRJE == "RJE_RETF"
			nInd := 28
		ElseIf cEvtRJE == "RJE_DTG"
			nInd := 29
		ElseIf cEvtRJE == "RJE_HORAG"
			nInd := 30
		ElseIf cEvtRJE == "codMotAfast"
			nInd := 31
		ElseIf cEvtRJE == "dtIniAfast"
			nInd := 32
		ElseIf cEvtRJE == "dtTermAfast"
			nInd := 33
		ElseIf cEvtRJE == "indApuracao"
			nInd := 34
		ElseIf cEvtRJE == "perApur"
			nInd := 35
		ElseIf cEvtRJE == "dtDeslig"
			nInd := 36
		ElseIf cEvtRJE == "dtEfeito"
			nInd := 37
		ElseIf cEvtRJE == "dtEfetRetorno"
			nInd := 38
		ElseIf cEvtRJE == "RJE_RECIB"
			nInd := 39
		ElseIf cEvtRJE == "dtAcid"
			nInd := 40
		ElseIf cEvtRJE == "tpAcid"
			nInd := 41
		ElseIf cEvtRJE == "tpExameOcup"
			nInd := 42
		ElseIf cEvtRJE == "dtAso"
			nInd := 43
		ElseIf cEvtRJE == "dtIniCondicao"
			nInd := 44
		ElseIf cEvtRJE == "matricula"
			nInd := 4
		ElseIf cEvtRJE == "dtExame"
			nInd := 8
		ElseIf cEvtRJE == "cpfTrab"
			nInd := 2
		ElseIf cEvtRJE == "nmTrab"
			nInd := 3
		ElseIf cEvtRJE == "nrProcTrab"
			nInd := 5
		ElseIf cEvtRJE == "origem"
			nInd := 4
		ElseIf cEvtRJE == "perApurPgto"
			nInd := 6
		ElseIf cEvtRJE == "ideSeqProc"
			nInd := 7
		ElseIf cEvtRJE == "tpEvento"
			nInd := 4
		ElseIf cEvtRJE == "error"//Manter sempre por último
			nInd := 98
		ElseIf cEvtRJE == "RJE_USRXML"//Manter sempre por último
			nInd := 99
		EndIf

		aadd( aInd, nInd )
	Next nX

	For nX := 1 To Len( aData )
		aadd( aBox, {} )
		aadd( aBox[nX], aData[nX] )
		aadd( aBox[nX], aInd[nX] )
	Next nX

	ASORT(aBox, , , { | x,y | x[2] < y[2] } )

	aData := {}
	For nX := 1 To Len( aBox )
		aadd( aData, aBox[nX][1] )
	Next nX

Return aData
