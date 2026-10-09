#include "protheus.ch"
#include "parmtype.ch"
#INCLUDE "GPEM921B.CH"


/*/{Protheus.doc} function fSendComp
Realiza a consulta dos dados de acordo com a competência e os envia através da API.
@author  hugo.de.oliveira
@since   25/11/2019
@version 1.0
/*/
Function GPEM921B( aParam )
	Local aData	:= {}
	Local aMV	:= {}

	DEFAULT aParam 	:= {}

	Conout( EncodeUTF8( STR0001 ) ) // STR0001: "JOB de Consulta de Eventos Iniciado"

	If !Empty( aParam )
		RpcSetType(3) // Licença
		RPCsetEnv(aParam[1], aParam[2]) // Abertura do Ambiente

		// Verifica se a rotina está sendo executada e realiza o Lock
		If LockByName( "GPEM921B" + cEmpAnt + cFilAnt, .T., .T., .T. )
			// Seleção dos Parâmetros
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_GPEAMBE",, "" ) ) ) // Tipo de Ambiente a ser utilizado
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_GPEMURL",, "" ) ) ) // Ambiente TSS Configurado
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI01",, "" ) ) ) // URL do ambiente com serviço Rest Configurado
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI03",, "" ) ) ) // Tipo de Inscrição
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI04",, "" ) ) ) // Inscrição
			Aadd( aMV , ALLTRIM( SuperGetMv( "MV_APIMI09",, "" ) ) ) // Serviço, método e a versão da API de Envio e Consulta do Middleware

			aData := fGetData( aMV ) // Selecão dos dados com base nos filtros e suas regras
			fGetEvt( aData, aMV )	// Chamada da API de consulta

			// Libera a rotina após finalizar a execução das Threads
			UnLockByName("GPEM921B" + cEmpAnt + cFilAnt, .T., .T., .T.)
		Else
			Conout( EncodeUTF8( STR0002 ) ) // STR0002: "A rotina 'GPEM921B' está sendo executada por outro processo"
		EndIf

		RpcClearEnv()
	Else
		Conout( EncodeUTF8( STR0003 ) ) // STR0003: "Erro no recebimento dos parâmetros utilizados na execução do JOB"
	EndIf

	Conout( EncodeUTF8( STR0004 ) ) // STR0004: "JOB de Consulta de Eventos Finalizado"
Return


/*/{Protheus.doc} function fGetData
Retorna todos os dados para processamento
@author  hugo.de.oliveira
@since   23/09/2019
@version 1.0
/*/
Static Function fGetData( aMV )
	Local aData 	:= {}
	Local cEvt 		:= ""
	Local cRetKey	:= ""
	Local cXML 		:= ""
	Local cRJE		:= "RJE"

	// Consulta a tabela de Eventos
	DbSelectArea( cRJE )
	( cRJE )->( DbSetOrder( 2 ) ) // RJE_TPINSC, RJE_INSCR
	DbSeek( aMV[4] + SUBSTR( aMV[5], 0, 8 ) )

	While ( cRJE )->( !EOF() ) .AND. aMV[4] + SUBSTR( aMV[5], 0, 8 ) == ALLTRIM( ( cRJE )->RJE_TPINSC ) + ALLTRIM( ( cRJE )->RJE_INSCR )
		If ( cRJE )->RJE_STATUS == "2" // Aguardando Retorno
			cEvt	:= ALLTRIM( ( cRJE )->RJE_EVENTO )
			cRetKey	:= ALLTRIM( ( cRJE )->RJE_RETKEY )
			cXML	:= ALLTRIM( ( cRJE )->RJE_XML )
			Aadd( aData, { cEvt, cRetKey, cXML } )
		EndIf

		( cRJE )->( dbSkip() )
	EndDo

	aData := fSortEvt( aData) // Ordenação dos eventos
Return aData


/*/{Protheus.doc} function fGetEvt
Realiza a consulta do retorno do processamento do Middleware.
@author  hugo.de.oliveira
@since   01/10/2019
@version 1.0
/*/
Static Function fGetEvt( aData, aMV )
	Local oMID
	Local oRet
	Local oItem
	Local oBody
	Local nY		:= 1
	Local nX 		:= 1
	Local lRet	 	:= .F.
	Local lRetResp	:= .T.
	Local aHeader   := {}
	Local aLote 	:= {}
	Local cBody		:= ""
	Local cEvtRJE 	:= ""
	Local cRetKey 	:= ""
	Local cSrcBra	:= ""
	Local cRJEAlias	:= "RJE"
	Local cRJ9Alias	:= "RJ9"
	Local nQtdeReg 	:= Len( aData )
	Local cEvenExcl := "S3000|S3500"
	Local cEvenTot 	:= "S1200/S2299/S2399"
	Local cVersTss	:= ""
	Local cClient	:= ""
	Local cSecret	:= ""
	Local nFimTxt	:= 0
	Local cToken	:= ""

	Private lIRRFComp := ChkFile("RUQ") .And. FindFunction("fGrvRUQ")

	If RJO->(ColumnPos("RJO_IDEDMD")) > 0
		cEvenTot := cEvenTot + "/S1210"
	EndIf

	If nQtdeReg < 1
		Return
	EndIf

	// Divide os dados em lotes de 50 itens
	aData 	 := fGetLote( aData )
	nQtdeReg := Len( aData )

	// Pega a entidade do cadastro do trabalhador
	DbSelectArea( cRJ9Alias )
	( cRJ9Alias )->( DbSetOrder( 5 ) ) // RJ9_NRINSC, RJ9_INI
	( cRJ9Alias )->( DbGoTop() )

	If ( cRJ9Alias )->( DbSeek( aMV[5] ) ) .Or. ( cRJ9Alias )->( DbSeek( SubStr( aMV[5], 1, 8 ) ) )
		If ( cRJ9Alias )->( ColumnPos( "RJ9_IDENT" ) ) > 0
			cSrcBra := ( cRJ9Alias )->RJ9_IDENT
			If ( cRJ9Alias )->( ColumnPos( "RJ9_CLIENT" ) ) > 0
				cClient := ( cRJ9Alias )->RJ9_CLIENT
				cSecret := ( cRJ9Alias )->RJ9_SECRET
			EndIf
		EndIf
	EndIf

	//Verifica versão do TSS
	If FindFunction("GpeVerTSS")
		cVersTss 	:= GpeVerTSS(cSrcBra)
		nFimTxt		:= AT( "|", cVersTss )
		cVersTss	:= alltrim(Substr(cVersTss, 1, nFimTxt -1))
	EndIf

	//Procura o token válido
	If  FindFunction("fGPETokenMid") .And. cVersTss >= "12.1.033" .And. !Empty(cClient) .And. !Empty(cSecret)
		cToken := fGPETokenMid(cClient,cSecret)
	EndIf

	// Montagem do Header
	If Empty(cToken)
		aadd(aHeader, "Content-Type: application/json; charset=UTF-8")
	Else
		aadd(aHeader, "TokenAuthTSS: " + cToken)
	EndIf

	If FindFunction("fAuthMid")
		aAdd( aHeader, "Authorization: Basic " + fAuthMid() )
	EndIf

	// Processamento dos registros
	For nY := 1 To nQtdeReg
		For nX := 1 to LEN( aData[nY] )
			cEvtRJE	:= aData[nY][nX][1]
			cRetKey	:= aData[nY][nX][2]

			// Montagem dos dados do array de propriedades 'Lote'
			oItem	:= JsonObject():new()
			oItem["registryType"] := SUBSTR(cEvtRJE, 1, 1) + "-" + SUBSTR(cEvtRJE, 2)

			dbSelectArea( cRJEAlias )
			( cRJEAlias )->( DbSetOrder( 3 ) ) // RJE_EVENTO, RJE_RETKEY
			( cRJEAlias )->( DbGoTop() )

			If ( cRJEAlias )->( DbSeek( cEvtRJE + cRetKey ) )
				oItem['ticketCode'] := ALLTRIM( ( cRJEAlias )->RJE_TCK )
			EndIf

			oItem["registryKey"]		:= cRetKey
			oItem["returnRetResponse"]	:= lRetResp

			// Adiciona os items no array de Lote
			AAdd( aLote, oItem )

			FreeObj( oItem )
		Next nX

		// Montagem do Body
		oBody := JsonObject():new()
		oBody['sourceBranch']	:= cSrcBra	// Código Identificador da entidade TSS ( retornado na configuração do certificado)
		oBody['tpAmb']			:= aMV[1] 	// Parâmetro contendo o Tipo do Ambiente
		oBody['urlTSS']			:= aMV[2]	// Parâmetro contendo a URL do Ambiente

		// Adiciona o Array de Itens no 'Body'
		oBody["lote"] := aLote

		// Compress String And Set Response
		cBody := fCompress( @oBody )

		// Chamada da API
		oMID := FwRest():New( aMV[3] )
		oMID:setPath( "/" + aMV[6] + "/get/" )
		oMID:SetPostParams( cBody )

		// Verificação de Retorno
		FreeObj( oRet )
		oRet	:= JsonObject():New()

		lHeader := oMID:Post( aHeader )
		lRet 	:= FWJsonDeserialize( oMID:GetResult(), @oRet )

		If lHeader .And. lRet .And. LEN(oRet:ITEMS) > 0
			For nX := 1 To LEN(oRet:ITEMS)
				dbSelectArea( cRJEAlias )
				( cRJEAlias )->( DbSetOrder( 3 ) ) // RJE_EVENTO, RJE_RETKEY
				( cRJEAlias )->( DbGoTop() )

				If ( cRJEAlias )->( DbSeek( REPLACE(oRet:ITEMS[nX]:registrytype,"-","") + oRet:ITEMS[nX]:registrykey ) )
					Begin Transaction
						Reclock( cRJEAlias, .F.)
							( cRJEAlias )->RJE_STATUS	:= oRet:ITEMS[nX]:STATUSCODE
							( cRJEAlias )->RJE_RTN 		:= Decode64( oRet:items[nX]:XMLRETRESPONSE )
							( cRJEAlias )->RJE_RECIB	:= ALLTRIM( oRet:ITEMS[nX]:RECEIPTNUMBER )
						MsUnlock()

						If ( cRJEAlias )->RJE_EVENTO $ cEvenExcl .And. oRet:ITEMS[nX]:STATUSCODE == "4"
						   fGrvExcOri(alltrim(( cRJEAlias )->RJE_KEY))
						Endif

						If ( cRJEAlias )->RJE_EVENTO $ cEvenTot .And. oRet:ITEMS[nX]:STATUSCODE == "4"
						   fGrvTotal( ( cRJEAlias )->RJE_FILIAL, ( cRJEAlias )->RJE_FIL, ( cRJEAlias )->RJE_TPINSC, ( cRJEAlias )->RJE_INSCR, ( cRJEAlias )->RJE_INI, ( cRJEAlias )->RJE_KEY, ( cRJEAlias )->RJE_RTN )
						EndIf

					End Transaction
				EndIf
			Next nX
		EndIf

		// Limpeza dos Objetos utilizados
		aLote := {}
		FreeObj( oBody )
		FreeObj( oItem )
		FreeObj( oRet )
		FreeObj( oMID )
	Next nY
Return

/*/{Protheus.doc} function fCompress
Compress String Object
@author  Hugo de Oliveira
@since   30/09/2019
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


/*/{Protheus.doc} function fSortEvt
Realiza a ordenação dos eventos
@author  Hugo de Oliveira
@since   30/10/2019
@version 1.0
/*/
Static Function fSortEvt( aData)
	Local nX 		:= 1
	Local cEvtRJE 	:= ""
	Local nInd		:= 0

	// Cria uma nova posição no Array de dados para servir de "Índice" e assim poder ser ordenado
	For nX := 1 To Len( aData )
		cEvtRJE		:= aData[nX][1]

		// Eventos de Cadastro
		If cEvtRJE == "S1000" // Empregador
			nInd := 1
		ElseIf cEvtRJE == "S1070" // Processos
			nInd := 2
		ElseIf cEvtRJE == "S1005" // Estabelecimentos
			nInd := 3
		ElseIf cEvtRJE == "S1010" // Verbas
			nInd := 4
		ElseIf cEvtRJE == "S1020" // Lotações
			nInd := 5
		ElseIf cEvtRJE == "S1030" // Cargos
			nInd := 6
		ElseIf cEvtRJE == "S1040" // Funções
			nInd := 7
		ElseIf cEvtRJE == "S1050" // Horários
			nInd := 8

		// Eventos Não Periódicos
		ElseIf cEvtRJE == "S2190" // Adm Preliminar
			nInd := 9
		ElseIf cEvtRJE == "S2200" // Admissão
			nInd := 10
		ElseIf cEvtRJE == "S2300" // Início TSV
			nInd := 11
		ElseIf cEvtRJE == "S2205" // Alteração Cadastral
			nInd := 12
		ElseIf cEvtRJE == "S2206" // Alteração Contratual
			nInd := 13
		ElseIf cEvtRJE == "S2306" // Alteração Contratual TSV
			nInd := 14
		ElseIf cEvtRJE == "S2210" // CAT
			nInd := 15
		ElseIf cEvtRJE == "S2220" // Monitoramento Saúde Trabalhador
			nInd := 16
		ElseIf cEvtRJE == "S2221" // Exame Toxicológico
			nInd := 17
		ElseIf cEvtRJE == "S2230" // Afastamentos
			nInd := 18
		ElseIf cEvtRJE == "S2240" // Condições de trabalho
			nInd := 19
		ElseIf cEvtRJE == "S2245" // Treinamentos
			nInd := 20
		ElseIf cEvtRJE == "S2250" // Aviso Prévio
			nInd := 21
		ElseIf cEvtRJE == "S2298" // Reintegração
			nInd := 22
		ElseIf cEvtRJE == "S2299" // Rescisão
			nInd := 23
		ElseIf cEvtRJE == "S2299" // Rescisão
			nInd := 24
		ElseIf cEvtRJE == "S2399" // Término TSV
			nInd := 25
		ElseIf cEvtRJE == "S3000" // Exclusão
			nInd := 26

		// Periódicos
		ElseIf cEvtRJE == "S1200" // Folha
			nInd := 27
		ElseIf cEvtRJE == "S1210" // Pagamentos
			nInd := 28
		ElseIf cEvtRJE == "S1280" // Desoneração
			nInd := 29
		ElseIf cEvtRJE == "S1300" // Contribuições Sindicais
			nInd := 30
		EndIf

		AADD( aData[nX], nInd )
	Next nX

	// Ordena os dados
	ASORT(aData, , , { | x,y | x[4] < y[4] } )

Return aData


/*/{Protheus.doc} function fGetLote
Divide os dados em Lote
@author  Hugo de Oliveira
@since   30/09/2019
@version 1.0
/*/
Static Function fGetLote( aArray )
	Local aLote
	Local aClone	:= {}
	Local nSizeDef	:= 50
	Local nX		:= 1
	Local nPos		:= 1
	Local nEndPos	:= nSizeDef
	Local nSize 	:= Len(aArray)
	Local nSzClone	:= ( nSize / nSizeDef )

	// Caso os lotes não possuam tamanho completo de 50 itens
	If (nSize % nSizeDef) > 0
		nSzClone := INT(nSzClone) + 1
	EndIf

	aLote := ARRAY( nSzClone, {} )
	For nX := 1 To nSzClone
		aClone	:= {}
		For nPos := nPos  To nEndPos
			If  nPos <= nSize
				aadd( aClone, aArray[nPos] )
			EndIf
		Next nPos

		aLote[nX] := aClone
		nEndPos += nSizeDef
	Next nX

Return aLote

/*/{Protheus.doc} function fGetLote
Efetiva exclusão evento original
@author  Silvia Taguti
@since   18/12/2019
@version 1.0
/*/
Static Function fGrvExcOri(cRecibOr)

	Local aAreaRJE 		:= GetArea()
	Local cRJE			:= "RJE"

	Default cRecibOr 	:= ""

	dbSelectArea( cRJE )
	( cRJE )->(dbSetOrder(6))

	If ( cRJE )->(dbSeek( cRecibOr ) )
		//Realiza a exclusão dos dados complementares do IRRF
		If lIRRFComp .And. (cRJE)->RJE_EVENTO == "S1210"
			fExcIRComp((cRJE)->RJE_FIL, (cRJE)->RJE_INI, fGetXML( "cpfBenef", (cRJE)->RJE_XML))
		EndIf
		Reclock( cRJE, .F.)
			( cRJE )->RJE_EXC := "1"
		( cRJE )->(MsUnlock())
	Endif

	RestArea( aAreaRJE )

Return


/*/{Protheus.doc} fGrvTotal()
Função que grava os totalizadores (S-5001/S-5003) na tabela RJE
@author allyson.mesashi
@since 03/02/2020
@version 1.0
@param cRJEFilial	= Filial da RJE
@param cRJEFil		= Filial do registro
@param cRJETpIns	= Tipo de Inscrição
@param cRJEInsc		= Número de Inscrição
@param cRJEIni		= Período do registro
@param cRJEKey		= Key do registro
@param cXMLRet		= XML de Retorno

/*/
Function fGrvTotal( cRJEFilial, cRJEFil, cRJETpIns, cRJEInsc, cRJEIni, cRJEKey, cXMLRet )

	Local lNovo		:= .T.
	Local nIni5001	:= At('<tot tipo="S5001">', cXMLRet)
	Local nFim5001	:= 0
	Local nIni5003	:= At('<tot tipo="S5003">', cXMLRet)
	Local nFim5003	:= 0
	Local nIni5002	:= At('<tot tipo="S5002">', cXMLRet)
	Local nFim5002	:= 0
	Local nIniId	:= 0

	RJE->( dbSetOrder(4) )//RJE_EVENTO+RJE_KEY

	If nIni5001 > 0
		nIni5001 := At('<eSocial', cXMLRet, nIni5001)
		nFim5001 := At('</eSocial>', cXMLRet, nIni5001) + 10
		nIniId	 := At('<evtBasesTrab Id=', cXMLRet, nIni5001) + 18

		lNovo := !RJE->( dbSeek( "S5001" + cRJEKey ) )

		If RJE->(Reclock( "RJE", lNovo) )
			RJE->RJE_FILIAL	:= cRJEFilial
			RJE->RJE_FIL	:= cRJEFil
			RJE->RJE_TPINSC	:= cRJETpIns
			RJE->RJE_INSCR	:= cRJEInsc
			RJE->RJE_EVENTO	:= "S5001"
			RJE->RJE_INI	:= cRJEIni
			RJE->RJE_KEY	:= cRJEKey
			RJE->RJE_RETKEY	:= SubStr( cXMLRet, nIniId, 36 )
			RJE->RJE_VERS	:= "12"
			RJE->RJE_STATUS	:= "4"
			RJE->RJE_XML	:= SubStr( cXMLRet, nIni5001, nFim5001-nIni5001 )
			RJE->RJE_DTG	:= Date()
			RJE->RJE_HORAG	:= Time()
			RJE->( MsUnlock() )
		EndIf
		fGrvTotCS( RJE->RJE_FIL, RJE->RJE_TPINSC, RJE->RJE_INSCR, RJE->RJE_XML )
	EndIf

	If nIni5002 > 0
		nIni5002 := At('<eSocial', cXMLRet, nIni5002)
		nFim5002 := At('</eSocial>', cXMLRet, nIni5002) + 10
		nIniId	 := At('<evtIrrfBenef Id=', cXMLRet, nIni5002) + 18

		lNovo := !RJE->( dbSeek( "S5002" + cRJEKey ) )

		If RJE->(Reclock( "RJE", lNovo) )
			RJE->RJE_FILIAL	:= cRJEFilial
			RJE->RJE_FIL	:= cRJEFil
			RJE->RJE_TPINSC	:= cRJETpIns
			RJE->RJE_INSCR	:= cRJEInsc
			RJE->RJE_EVENTO	:= "S5002"
			RJE->RJE_INI	:= cRJEIni
			RJE->RJE_KEY	:= cRJEKey
			RJE->RJE_RETKEY	:= SubStr( cXMLRet, nIniId, 36 )
			RJE->RJE_VERS	:= "12"
			RJE->RJE_STATUS	:= "4"
			RJE->RJE_XML	:= SubStr( cXMLRet, nIni5002, nFim5002-nIni5002 )
			RJE->RJE_DTG	:= Date()
			RJE->RJE_HORAG	:= Time()
			RJE->( MsUnlock() )
		EndIf
		fGrvTotIR( RJE->RJE_FIL, RJE->RJE_TPINSC, RJE->RJE_INSCR, RJE->RJE_XML )
	EndIf

	If nIni5003 > 0
		nIni5003 := At('<eSocial', cXMLRet, nIni5003)
		nFim5003 := At('</eSocial>', cXMLRet, nIni5003) + 10
		nIniId	 := At('<evtBasesFGTS Id=', cXMLRet, nIni5003) + 18

		lNovo := !RJE->( dbSeek( "S5003" + cRJEKey ) )

		If RJE->(Reclock( "RJE", lNovo) )
			RJE->RJE_FILIAL	:= cRJEFilial
			RJE->RJE_FIL	:= cRJEFil
			RJE->RJE_TPINSC	:= cRJETpIns
			RJE->RJE_INSCR	:= cRJEInsc
			RJE->RJE_EVENTO	:= "S5003"
			RJE->RJE_INI	:= cRJEIni
			RJE->RJE_KEY	:= cRJEKey
			RJE->RJE_RETKEY	:= SubStr( cXMLRet, nIniId, 36 )
			RJE->RJE_VERS	:= "12"
			RJE->RJE_STATUS	:= "4"
			RJE->RJE_XML	:= SubStr( cXMLRet, nIni5003, nFim5003-nIni5003 )
			RJE->RJE_DTG	:= Date()
			RJE->RJE_HORAG	:= Time()
			RJE->( MsUnlock() )
		EndIf
		fGrvTotFG( RJE->RJE_FIL, RJE->RJE_TPINSC, RJE->RJE_INSCR, RJE->RJE_XML )
	EndIf

Return

/*/{Protheus.doc} fGrvTotCS()
Função que grava o totalizador (S-5001) na tabela RJO
@author allyson.mesashi
@since 03/02/2020
@version 1.0
@param cRJEFil		= Filial do registro
@param cRJETpIns	= Tipo de Inscrição
@param cRJEInsc		= Número de Inscrição
@param cXMLRet		= XML de Retorno

/*/
Static Function fGrvTotCS( cRJEFil, cRJETpIns, cRJEInsc, cXMLRet )

	Local cCabec		:= "/eSocial/evtBasesTrab/"
	Local cPCpCal		:= ""
	Local cPIdeEstL		:= ""
	Local cPInfCatI		:= ""
	Local cPInfBasC		:= ""
	Local cTpFolha		:= ""
	Local cPerApur		:= ""
	Local cCpfTrab		:= ""
	Local cTpCR			:= ""
	Local cVrCpSeg		:= ""
	Local cTpInsc		:= ""
	Local cNrInsc		:= ""
	Local cCodLota		:= ""
	Local cMatric		:= ""
	Local cCodCateg		:= ""
	Local cInd13		:= ""
	Local cTpValor		:= ""
	Local cValor		:= ""
	Local cInfoPIS		:= ""
	Local cInfCatPIS	:= ""
	Local cInfBasPIS	:= ""
	Local nCpCal		:= 0
	Local nIdeEstL		:= 0
	Local nInfCatI		:= 0
	Local nInfBasC		:= 0
	Local nInfoPIS		:= 0
	Local nInfCatPIS	:= 0
	Local nInfBasPIS	:= 0
	Local oXml 			:= tXmlManager():New()
	Local cNome			:= ""

	If oXml:Parse( fMidTrPath(cXMLRet,"eSocial") )
		cTpFolha := oXml:XPathGetNodeValue( cCabec + "ideEvento[1]" + "/indApuracao" )
		cPerApur := AllTrim( StrTran( oXml:XPathGetNodeValue( cCabec + "ideEvento[1]" + "/perApur" ), "-" ) )
		cCpfTrab := oXml:XPathGetNodeValue( cCabec + "ideTrabalhador[1]" + "/cpfTrab" )
		fExcRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, "S-5001" )

		// ENCONTRA AS INFORMAÇÕES DE MATRICULA E NOME DO FUNCIONARIO.
		If !Empty(cCpfTrab)
			cMatric 	:= Posicione("SRA", 5, xFilial("SRA") + cCpfTrab, "RA_CODUNIC")
			cNome		:= Alltrim(SRA->RA_NOME)
		EndIf

		nCpCal := 1
		cPCpCal := cCabec + "infoCpCalc[" + cValToChar(nCpCal) + "]"
		While oXml:XPathHasNode(cPCpCal)
			cTpCR 		:= AllTrim( StrTran( oXml:XPathGetNodeValue( cPCpCal + "/tpCR" ), "-" ) )
			cVrCpSeg 	:= oXml:XPathGetNodeValue( cPCpCal + "/vrCpSeg" )

			fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, /*cCateg*/, /*cTpInsc*/, /*cNrInsc*/, /*cCodLot*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cVrCpSeg), "S-5001", /*cIndDec*/, "99", cTpCR )

			nCpCal++
			cPCpCal := cCabec + "infoCpCalc[" + cValToChar(nCpCal) + "]"
		EndDo

		nIdeEstL := 1
		cPIdeEstL := cCabec + "infoCp/ideEstabLot[" + cValToChar(nIdeEstL) + "]"
		While oXml:XPathHasNode(cPIdeEstL)
			cTpInsc 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/tpInsc" )
			cNrInsc 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/nrInsc" )
			cCodLota 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/codLotacao" )

			nInfCatI := 1
			cPInfCatI := cPIdeEstL + "/infoCategIncid[" + cValToChar(nInfCatI) + "]"
			While oXml:XPathHasNode(cPInfCatI)

				cCodCateg 	:= oXml:XPathGetNodeValue( cPInfCatI + "/codCateg" )
				cMatric 	:= oXml:XPathGetNodeValue( cPInfCatI + "/matricula" )

				nInfBasC := 1
				cPInfBasC := cPInfCatI + "/infoBaseCS[" + cValToChar(nInfBasC) + "]"
				While oXml:XPathHasNode(cPInfBasC)
					cInd13 		:= oXml:XPathGetNodeValue( cPInfBasC + "/ind13" )
					cTpValor 	:= oXml:XPathGetNodeValue( cPInfBasC + "/tpValor" )
					cValor 		:= oXml:XPathGetNodeValue( cPInfBasC + "/valor" )

					If cTpValor $ "11/12/13/14/15/16/17/18/19/21/22/23/31/32/41/42/43/44/45/46/47/48/49"
						fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5001", cInd13, cTpValor )
					EndIf

					nInfBasC++
					cPInfBasC := cPInfCatI + "/infoBaseCS[" + cValToChar(nInfBasC) + "]"
				EndDo

				nInfCatI++
				cPInfCatI := cPIdeEstL + "/infoCategIncid[" + cValToChar(nInfCatI) + "]"
			EndDo

			nIdeEstL++
			cPIdeEstL := cCabec + "infoCp/ideEstabLot[" + cValToChar(nIdeEstL) + "]"
		EndDo

		nInfoPIS := 1
		cInfoPIS := cCabec + "infoPisPasep/ideEstab[" + cValToChar(nInfoPIS) + "]"
		While oXml:XPathHasNode(cInfoPIS)
			cTpInsc 	:= oXml:XPathGetNodeValue( cInfoPIS + "/tpInsc" )
			cNrInsc 	:= oXml:XPathGetNodeValue( cInfoPIS + "/nrInsc" )

			nInfCatPIS := 1
			cInfCatPIS := cInfoPIS + "/infoCategPisPasep[" + cValToChar(nInfCatPIS) + "]"
			While oXml:XPathHasNode(cInfCatPIS)
				cMatric 	:= oXml:XPathGetNodeValue( cInfCatPIS + "/matricula" )
				cCodCateg 	:= oXml:XPathGetNodeValue( cInfCatPIS + "/codCateg" )

				nInfBasPIS := 1
				cInfBasPIS := cInfCatPIS + "/infoBasePisPasep[" + cValToChar(nInfBasPIS) + "]"
				While oXml:XPathHasNode(cInfBasPIS)
					cInd13 		:= oXml:XPathGetNodeValue( cInfBasPIS + "/ind13" )
					cTpValor 	:= oXml:XPathGetNodeValue( cInfBasPIS + "/tpValorPisPasep" )
					cValor 		:= oXml:XPathGetNodeValue( cInfBasPIS + "/valorPisPasep" )

					fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5001", cInd13, cTpValor, "830102" )

					nInfBasPIS++
					cInfBasPIS := cInfCatPIS + "/infoBasePisPasep[" + cValToChar(nInfBasPIS) + "]"
				EndDo

				nInfCatPIS++
				cInfCatPIS := cInfoPIS + "/infoCategPisPasep[" + cValToChar(nInfCatPIS) + "]"
			EndDo

			nInfoPIS++
			cInfoPIS := cCabec + "infoPisPasep[" + cValToChar(nInfoPIS) + "]"
		EndDo

	EndIf

	oXml := Nil

Return

/*/{Protheus.doc} fGrvTotFG()
Função que grava o totalizador (S-5003) na tabela RJO
@author allyson.mesashi
@since 20/02/2020
@version 1.0
@param cRJEFil		= Filial do registro
@param cRJETpIns	= Tipo de Inscrição
@param cRJEInsc		= Número de Inscrição
@param cXMLRet		= XML de Retorno

/*/
Static Function fGrvTotFG( cRJEFil, cRJETpIns, cRJEInsc, cXMLRet )

	Local cCabec		:= "/eSocial/evtBasesFGTS/"
	Local cPIdeEstL		:= ""
	Local cPTrabFgt		:= ""
	Local cPBaseFgt		:= ""
	Local cPTrabDps		:= ""
	Local cPDpsPA		:= ""
	Local cPInfDPAE		:= ""
	Local cTpFolha		:= ""
	Local cPerApur		:= ""
	Local cCpfTrab		:= ""
	Local cTpInsc		:= ""
	Local cNrInsc		:= ""
	Local cCodLota		:= ""
	Local cMatric		:= ""
	Local cCodCateg		:= ""
	Local cTpValor		:= ""
	Local cValor		:= ""
	Local cIncid		:= ""
	Local cPIdeEst		:= ""
	Local cPIdeLot		:= ""
	Local nIdeEst		:= 0
	Local nIdeLot		:= 0
	Local nIdeEstL		:= 0
	Local nInfTraF		:= 0
	Local nBaseFgt		:= 0
	Local nInfTraD		:= 0
	Local nDpsPA		:= 0
	Local nInfDPAE		:= 0
	Local oXml 			:= tXmlManager():New()
	Local cNome			:= ""

	If oXml:Parse( fMidTrPath(cXMLRet,"eSocial") )
		cPerApur := AllTrim( StrTran( oXml:XPathGetNodeValue( cCabec + "ideEvento[1]" + "/perApur" ), "-" ) )
		cTpFolha := Iif( Len(cPerApur) == 4, "2", "1" )
		cCpfTrab := oXml:XPathGetNodeValue( cCabec + "ideTrabalhador[1]" + "/cpfTrab" )
		fExcRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, "S-5003" )

		// ENCONTRA AS INFORMAÇÕES DE MATRICULA E NOME DO FUNCIONARIO.
		If !Empty(cCpfTrab)
			cMatric 	:= Posicione("SRA", 5, xFilial("SRA") + cCpfTrab, "RA_CODUNIC")
			cNome		:= Alltrim(SRA->RA_NOME)
		EndIf

		nIdeEstL := 1
		cPIdeEstL := cCabec + "infoFGTS/ideEstabLot[" + cValToChar(nIdeEstL) + "]"
		While oXml:XPathHasNode(cPIdeEstL)
			cTpInsc 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/tpInsc" )
			cNrInsc 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/nrInsc" )
			cCodLota 	:= oXml:XPathGetNodeValue( cPIdeEstL + "/codLotacao" )

			nInfTraF := 1
			cPTrabFgt := cPIdeEstL + "/infoTrabFGTS[" + cValToChar(nInfTraF) + "]"
			While oXml:XPathHasNode(cPTrabFgt)

				cCodCateg 	:= oXml:XPathGetNodeValue( cPTrabFgt + "/codCateg" )

				nBaseFgt := 1
				cPBaseFgt := cPTrabFgt + "/infoBaseFGTS/basePerApur[" + cValToChar(nBaseFgt) + "]"
				While oXml:XPathHasNode(cPBaseFgt)
					cTpValor 	:= oXml:XPathGetNodeValue( cPBaseFgt + "/tpValor" )
					cValor 		:= oXml:XPathGetNodeValue( cPBaseFgt + "/remFGTS" )

					If cTpValor $ "11/12/13/14/15/16/17/21/22/23/24/25/26/27/28/29/30/31/32"
						fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
					EndIf

					nBaseFgt++
					cPBaseFgt := cPTrabFgt + "/infoBaseFGTS/basePerApur[" + cValToChar(nBaseFgt) + "]"
				EndDo

				nBasePAE := 1
				cPBasPAE := cPTrabFgt + "/infoBasePerAntE/basePerAntE[" + cValToChar(nBasePAE) + "]"
				While oXml:XPathHasNode(cPBasPAE)
					cTpValor 	:= oXml:XPathGetNodeValue( cPBasPAE + "/tpValorE" )
					cValor 		:= oXml:XPathGetNodeValue( cPBasPAE + "/remFGTSE" )

					If cTpValor $ "11/12/13/14/15/16/17/21/22/23/24/25/26/27/28/29/30/31/32"
						fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
					EndIf

					nBasePAE++
					cPBasPAE := cPTrabFgt + "/infoBasePerAntE/basePerAntE[" + cValToChar(nBasePAE) + "]"
				EndDo

				nInfTraF++
				cPTrabFgt := cPIdeEstL + "/infoTrabFGTS[" + cValToChar(nInfTraF) + "]"
			EndDo

			nIdeEstL++
			cPIdeEstL := cCabec + "infoFGTS/ideEstabLot[" + cValToChar(nIdeEstL) + "]"
		EndDo

		nInfTraD := 1
		cPTrabDps := cCabec + "/infoDpsFGTS/infoTrabDps[" + cValToChar(nInfTraD) + "]"
		While oXml:XPathHasNode(cPTrabDps)

			cCodCateg 	:= oXml:XPathGetNodeValue( cPTrabDps + "/codCateg" )

			nDpsPA := 1
			cPDpsPA := cPTrabDps + "/dpsPerApur[" + cValToChar(nDpsPA) + "]"
			While oXml:XPathHasNode(cPDpsPA)
				cTpValor 	:= oXml:XPathGetNodeValue( cPDpsPA + "/tpDps" )
				cValor 		:= oXml:XPathGetNodeValue( cPDpsPA + "/dpsFGTS" )

				If cTpValor $ "51/52/53/54/55/56/57/58/61/62/63/64/65/66/67/68/69/70/71/72"
					fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, /*cTpInsc*/, /*cNrInsc*/, /*cCodLota*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
				EndIf

				nDpsPA++
				cPDpsPA := cPTrabDps + "/dpsPerApur[" + cValToChar(nDpsPA) + "]"
			EndDo

			nInfDPAE := 1
			cPInfDPAE := cPTrabDps + "/infoDpsPerAntE[" + cValToChar(nInfDPAE) + "]"
			While oXml:XPathHasNode(cPInfDPAE)
				nDpsPAE  := 1
				cPDpsPAE := cPInfDPAE + "/dpsPerAntE[" + cValToChar(nDpsPAE) + "]"

				While oXml:XPathHasNode(cPDpsPAE)
					cTpValor 	:= oXml:XPathGetNodeValue( cPDpsPAE + "/tpDpsE" )
					cValor 		:= oXml:XPathGetNodeValue( cPDpsPAE + "/dpsFGTSE" )

					If cTpValor $ "51/52/53/54/55/56/57/58/61/62/63/64/65/66/67/68/69/70/71/72"
						fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, /*cTpInsc*/, /*cNrInsc*/, /*cCodLota*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
					EndIf

					nDpsPAE++
					cPDpsPAE := cPInfDPAE + "/dpsPerAntE[" + cValToChar(nDpsPAE) + "]"
				EndDo

				nInfDPAE++
				cPInfDPAE := cPTrabDps + "/infoDpsPerAntE[" + cValToChar(nInfDPAE) + "]"
			EndDo

			nInfTraD++
			cPTrabDps := cCabec + "/infoDpsFGTS/infoTrabDps[" + cValToChar(nInfTraD) + "]"
		EndDo

		//S-1.0
		nIdeEst := 1
		cPIdeEst := cCabec + "infoFGTS/ideEstab[" + cValToChar(nIdeEst) + "]" //9.0 n tem o grupo, é infoFGTS/ideEstab[ /ideLotacao[]]
		While oXml:XPathHasNode(cPIdeEst)
			cTpInsc 	:= oXml:XPathGetNodeValue( cPIdeEst + "/tpInsc" )
			cNrInsc 	:= oXml:XPathGetNodeValue( cPIdeEst + "/nrInsc" )

			nIdeLot := 1
			cPIdeLot := cPIdeEst + "/ideLotacao[" + cValToChar(nIdeLot) + "]" //infoFGTS/ideEstab/ideLotacao[]
			While oXml:XPathHasNode(cPIdeLot)
				cCodLota 	:= oXml:XPathGetNodeValue( cPIdeLot + "/codLotacao" )
				//Tratar se tipo de Lotacao 04, query do relatório hoje busca pelo estab
					//cTpInsc 	:= oXml:XPathGetNodeValue( cPIdeLot + "/tpInsc" )
					//cNrInsc 	:= oXml:XPathGetNodeValue( cPIdeLot + "/nrInsc" )

				nInfTraF := 1
				cPTrabFgt := cPIdeLot + "/infoTrabFGTS[" + cValToChar(nInfTraF) + "]"
				While oXml:XPathHasNode(cPTrabFgt)
					cCodCateg 	:= oXml:XPathGetNodeValue( cPTrabFgt + "/codCateg" )

					nBaseFgt := 1
					cPBaseFgt := cPTrabFgt + "/infoBaseFGTS/basePerApur[" + cValToChar(nBaseFgt) + "]"
					While oXml:XPathHasNode(cPBaseFgt)
						cTpValor 	:= oXml:XPathGetNodeValue( cPBaseFgt + "/tpValor" )
						cValor 		:= oXml:XPathGetNodeValue( cPBaseFgt + "/remFGTS" )
						cIncid		:= oXml:XPathGetNodeValue( cPBaseFgt + "/indIncid" )

						If cTpValor $ "11/12/13/14/15/16/17/21/22/23/24/25/26/27/28/29/30/31/32/41/42/43/44/45/46/47/48/49/50"
							fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
						EndIf

						If cIncid == '1' //dps só informa se indIncid = 1
							cValor	:= oXml:XPathGetNodeValue( cPBaseFgt + "/dpsFGTS" )
							fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, /*cTpInsc*/, /*cNrInsc*/, /*cCodLota*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, /*cTpValor*/ )
						EndIf

						nBaseFgt++
						cPBaseFgt := cPTrabFgt + "/infoBaseFGTS/basePerApur[" + cValToChar(nBaseFgt) + "]"
					EndDo


					nBasePAE := 1
					cPBasPAE := cPTrabFgt + "/infoBasePerAntE/basePerAntE[" + cValToChar(nBasePAE) + "]"
					While oXml:XPathHasNode(cPBasPAE)
						cTpValor 	:= oXml:XPathGetNodeValue( cPBasPAE + "/tpValorE" )
						cValor 		:= oXml:XPathGetNodeValue( cPBasPAE + "/remFGTSE" )
						cIncid		:= oXml:XPathGetNodeValue( cPBaseFgt + "/indIncidE" )


						If cTpValor $ "11/12/13/14/15/16/17/21/22/23/24/25/26/27/28/29/30/31/32/43/44/48/49/50"
							fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cTpInsc, cNrInsc, cCodLota, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, cTpValor )
						EndIf

						If cIncid == '1'
							cValor 		:= oXml:XPathGetNodeValue( cPDpsPAE + "/dpsFGTSE" )
							fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, /*cTpInsc*/, /*cNrInsc*/, /*cCodLota*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, Val(cValor), "S-5003", /*cInd13*/, /*cTpValor*/ )
						EndIf


						nBasePAE++
						cPBasPAE := cPTrabFgt + "/infoBasePerAntE/basePerAntE[" + cValToChar(nBasePAE) + "]"
					EndDo

					nInfTraF++
					cPTrabFgt := cPIdeLot + "/infoTrabFGTS[" + cValToChar(nInfTraF) + "]"
				EndDo

				nIdeLot++
				cPIdeLot := cPIdeEst + "/ideLotacao[" + cValToChar(nIdeLot) + "]" //infoFGTS/ideEstab/ideLotacao[]
			EndDo

			nIdeEst++
			cPIdeEst := cCabec + "infoFGTS/ideEstab[" + cValToChar(nIdeEst) + "]" //9.0 nao tem
		EndDo

	EndIf

	oXml := Nil

Return


/*/{Protheus.doc} fGrvTotIR()
Função que grava o totalizador (S-5002) na tabela RJO
@author lidio.oliveira
@since 26/07/2023
@version 1.0
@param cRJEFil		= Filial do registro
@param cRJETpIns	= Tipo de Inscrição
@param cRJEInsc		= Número de Inscrição
@param cXMLRet		= XML de Retorno

/*/
Function fGrvTotIR( cRJEFil, cRJETpIns, cRJEInsc, cXMLRet )

	Local cCabec		:= "/eSocial/evtIrrfBenef/"
	Local oXml 			:= tXmlManager():New()
	Local cPerApur		:= ""
	Local cTpFolha		:= ""
	Local cCpfTrab		:= ""
	Local cMatric		:= ""
	Local cNome			:= ""
	Local ndmDev		:= 0
	Local cdmDev		:= ""
	Local cperRef		:= ""
	Local cideDmDev		:= ""
	Local cTpPgto		:= ""
	Local dDtPgto		:= ""
	Local cCodCateg		:= ""
	Local ninfoIR		:= 0
	Local cinfoIR		:= ""
	Local ctpInfoIR		:= ""
	Local nvalor		:= 0
	Local nValorAnt		:= 0
	Local nX			:= 0
	Local cTotApurMen	:= ""
	Local nTotApurMen	:= 0
	Local aTotApurMen	:= {}
	Local ntotInfoIR	:= 0
	Local ctotInfoIR	:= ""
	Local nConApurMen	:= 0
	Local cConApurMen	:= ""
	Local nIfIRCompl	:= 0
	Local cIfIRCompl	:= ""
	Local ninfoIRCR		:= 0
	Local cinfoIRCR		:= ""
	Local nDedDepen		:= 0
	Local cDedDepen		:= ""
	Local cTpRend		:= ""
	Local cCPFDep		:= ""
	Local nVlrDed		:= 0
	Local cPlanSaude	:= ""
	Local nPlanSaude	:= 0
	Local cCNPJOper		:= ""
	Local cRegANS		:= ""
	Local nIfDepSau		:= 0
	Local cIfDepSau		:= ""
	Local cReemTit		:= ""
	Local nReemTit		:= 0
	Local cTpInscReem	:= ""
	Local cNrInscReem	:= ""
	Local cIfReemDep	:= ""
	Local nIfReemDep	:= 0
	Local cDetReemDep	:= ""
	Local nDetReemDep	:= 0
	Local cPrevCompl	:= ""
	Local nPrevCompl	:= 0
	Local cTpPrev		:= ""
	Local cCNPJPrev		:= ""
	Local nVlrPC		:= 0 
	Local nVlrPC13		:= 0 
	Local nVlrPF		:= 0
	Local nVlrPF13		:= 0
	Local cCRMen		:= ""
	Local cTpCR			:= ""
	Local nPenAlim		:= 0
	Local cPenAlim		:= ""
	Local nIfReemb		:= 0 
	Local cIfReemb		:= ""

	If oXml:Parse( fMidTrPath(cXMLRet,"eSocial") )
		cPerApur := AllTrim( StrTran( oXml:XPathGetNodeValue( cCabec + "ideEvento[1]" + "/perApur" ), "-" ) )
		cTpFolha := Iif( Len(cPerApur) == 4, "2", "1" )
		cCpfTrab := oXml:XPathGetNodeValue( cCabec + "ideTrabalhador[1]" + "/cpfBenef" )
		fExcRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, "S-5002" )
		
		//Realiza a exclusão dos dados complementares do IRRF
		If lIRRFComp 
			fExcIRComp(cRJEFil, cPerApur, cCpfTrab)
		EndIf

		//Informações de nome e matrícula do funcionário
		If !Empty(cCpfTrab)
			cMatric 	:= Posicione("SRA", 5, xFilial("SRA") + cCpfTrab, "RA_CODUNIC")
			cNome		:= Alltrim(SRA->RA_NOME)
		EndIf

		ndmDev := 1
		cdmDev := cCabec + "ideTrabalhador/dmDev[" + cValToChar(ndmDev) + "]"
		While oXml:XPathHasNode(cdmDev)
			cperRef 	:= StrTran(oXml:XPathGetNodeValue( cdmDev + "/perRef" ), "-", "")
			cideDmDev 	:= oXml:XPathGetNodeValue( cdmDev + "/ideDmDev" )
			cTpPgto		:= oXml:XPathGetNodeValue( cdmDev + "/tpPgto" )
			dDtPgto 	:= stod(StrTran(oXml:XPathGetNodeValue( cdmDev + "/dtPgto" ), "-", ""))
			cCodCateg 	:= oXml:XPathGetNodeValue( cdmDev + "/codCateg" )

			ninfoIR := 1
			cinfoIR := cdmDev + "/infoIR[" + cValToChar(ninfoIR) + "]"
			While oXml:XPathHasNode(cinfoIR)

				ctpInfoIR 	:= oXml:XPathGetNodeValue( cinfoIR + "/tpInfoIR" )
				nValor		:= val(oXml:XPathGetNodeValue( cinfoIR + "/valor" ))
				
				If fVbRelIR(,ctpInfoIR)
					fGrvRJO( cRJEFil, cTpFolha, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, /*cTpInsc*/, /*cNrInsc*/, /*cCodLota*/, /*cNaturez*/, /*cTpRub*/, /*cIncCP*/, /*cIncFgts*/, /*cIncIRRF*/, nValor, "S-5002", /*cInd13*/, /*cTpValor*/, /*cTpCR*/, /*cIncop*/, /*cTetoP*/, cideDmDev, dDtPgto, /*cCodRub*/, /*cIdCodRub*/, cperRef, ctpInfoIR, .T.)
				EndIf

				ninfoIR++
				cinfoIR := cdmDev + "/infoIR[" + cValToChar(ninfoIR) + "]"
			EndDo

			//Grava os dados com a totalização da apuração mensal do dmDev processado
			If lIRRFComp 
				ntotApurMen := 1
				ctotApurMen := cdmDev + "/totApurMen[" + cValToChar(ntotApurMen) + "]"
				While oXml:XPathHasNode(ctotApurMen)

					cCRMen		:= oXml:XPathGetNodeValue( ctotApurMen + "/CRMen" )

					//Obtém os nós existentes em totApurMen do DmDev processado
					aTotApurMen := oXML:XPathGetChildArray( ctotApurMen )

					//Grava a Tabela RUQ para cada totalizar retornado
					For nX := 1 To Len(aTotApurMen)
						If !(Upper(aTotApurMen[nX][1]) $ "CRMEN*DESCRENDIMENTO") .And. Val(aTotApurMen[nX][3]) > 0
							fGrvRUQ(cRJEFil, cPerApur, cCpfTrab, cNome, cMatric, cCodCateg, cRJETpIns, cRJEInsc, cCRMen, cPerRef, cideDmDev, cTpPgto, dDtPgto, Upper(aTotApurMen[nX][1]), Val(aTotApurMen[nX][3]))
						EndIf
					Next nX

					ntotApurMen++
					ctotApurMen := cdmDev + "/totApurMen[" + cValToChar(ntotApurMen) + "]"
				EndDo
			EndIf

			ndmDev++
			cdmDev := cCabec + "ideTrabalhador/dmDev[" + cValToChar(ndmDev) + "]"
		EndDo

		//Se as tabelas do complemento de IR existirem grava seus dados
		If lIRRFComp 
			
			//Grava os dados com a totalização da apuração mensal - totInfoIR
			ntotInfoIR := 1
			ctotInfoIR := cCabec + "ideTrabalhador/totInfoIR[" + cValToChar(ntotInfoIR) + "]"
			If oXml:XPathHasNode(ctotInfoIR)
				
				nConApurMen := 1
				cConApurMen := ctotInfoIR + "/consolidApurMen[" + cValToChar(nConApurMen) + "]"				
				While oXml:XPathHasNode(cConApurMen)	
					
					cCRMen		:= oXml:XPathGetNodeValue( cConApurMen + "/CRMen" )

					//Obtém os nós existentes em consolidApurMen
					aTotApurMen := oXML:XPathGetChildArray( cConApurMen )

					//Grava a Tabela RUQ para cada totalizar retornado
					For nX := 1 To Len(aTotApurMen)
						If !(Upper(aTotApurMen[nX][1]) $ "CRMEN*DESCRENDIMENTO") .And. Val(aTotApurMen[nX][3]) > 0
							fGrvRUQ(cRJEFil, cPerApur, cCpfTrab, cNome, /*cMatric*/, /*cCodCateg*/, cRJETpIns, cRJEInsc, cCRMen, /*cPerRef*/, /*cideDmDev*/, /*cTpPgto*/, /*dDtPgto*/, Upper(aTotApurMen[nX][1]), Val(aTotApurMen[nX][3]))
						EndIf
					Next nX

					nConApurMen++
					cConApurMen := ctotInfoIR + "/consolidApurMen[" + cValToChar(nConApurMen) + "]"		
				EndDo
			EndIf

			//Grava os dados complementares do IRRF - infoIRComplem
			nIfIRCompl := 1
			cIfIRCompl := cCabec + "ideTrabalhador/infoIRComplem[" + cValToChar(nIfIRCompl) + "]"
			While oXml:XPathHasNode(cIfIRCompl)
				
				//Busca e Grava as informações de Plano de Saúde - infoIRCR
				ninfoIRCR := 1
				cinfoIRCR := cIfIRCompl + "/infoIRCR[" + cValToChar(ninfoIRCR) + "]"
				While oXml:XPathHasNode(cinfoIRCR)	
					cTpCR		:= oXml:XPathGetNodeValue( cinfoIRCR + "/tpCR" )

					//Busca e grava as deduções de dependente - dedDepen
					nDedDepen := 1
					cDedDepen := cinfoIRCR + "/dedDepen[" + cValToChar(nDedDepen) + "]"					
					While oXml:XPathHasNode(cDedDepen)
						cTpRend	:= oXml:XPathGetNodeValue( cDedDepen + "/tpRend" )
						cCPFDep	:= oXml:XPathGetNodeValue( cDedDepen + "/cpfDep" )
						nVlrDed	:= Val(oXml:XPathGetNodeValue( cDedDepen + "/vlrDedDep" ))
												
						fGrvRUR(cRJEFil, cPerApur, cCpfTrab, /*cMatric*/, /*cCodCateg*/, cRJETpIns, cRJEInsc, cTpCR, "1", cTpRend, cCPFDep, nVlrDed)
		
						nDedDepen++
						cDedDepen := cinfoIRCR + "/dedDepen[" + cValToChar(nDedDepen) + "]"	
					EndDo

					//Busca e grava as deduções de pensão alimentícia - penAlim
					nPenAlim := 1
					cPenAlim := cinfoIRCR + "/penAlim[" + cValToChar(nPenAlim) + "]"					
					While oXml:XPathHasNode(cPenAlim)
						cTpRend		:= oXml:XPathGetNodeValue( cPenAlim + "/tpRend" )
						cCPFDep		:= oXml:XPathGetNodeValue( cPenAlim + "/cpfDep" )
						nVlrDed		:= Val(oXml:XPathGetNodeValue( cPenAlim + "/vlrDedPenAlim" ))
												
						fGrvRUR(cRJEFil, cPerApur, cCpfTrab, /*cMatric*/, /*cCodCateg*/, cRJETpIns, cRJEInsc, cTpCR, "2", cTpRend, cCPFDep, nVlrDed)
							
						nPenAlim++
						cPenAlim := cinfoIRCR + "/penAlim[" + cValToChar(nPenAlim) + "]"	
					EndDo

					//Busca e grava as deduções de pensão alimentícia - previdCompl
					nPrevCompl := 1
					cPrevCompl := cinfoIRCR + "/previdCompl[" + cValToChar(nPrevCompl) + "]"
					While oXml:XPathHasNode(cPrevCompl)
						cTpPrev		:= oXml:XPathGetNodeValue( cPrevCompl + "/tpPrev" )
						cCNPJPrev	:= oXml:XPathGetNodeValue( cPrevCompl + "/cnpjEntidPC" )
						
						//Obtém o valor de vlrDedPC. Pode acontecer da tag não existir no XML
						Iif(oXml:XPathHasNode(cPrevCompl + "/vlrDedPC"), nVlrPC	:= Val(oXml:XPathGetNodeValue(cPrevCompl + "/vlrDedPC")), nVlrPC := 0)
						Iif(oXml:XPathHasNode(cPrevCompl + "/vlrDedPC13"), nVlrPC13 := Val(oXml:XPathGetNodeValue(cPrevCompl + "/vlrDedPC13")), nVlrPC13 := 0)	
						Iif(oXml:XPathHasNode(cPrevCompl + "/vlrPatrocFunp"), nVlrPF := Val(oXml:XPathGetNodeValue(cPrevCompl + "/vlrPatrocFunp")), nVlrPF := 0)
						Iif(oXml:XPathHasNode(cPrevCompl + "/vlrPatrocFunp13"), nVlrPF13 := Val(oXml:XPathGetNodeValue(cPrevCompl + "/vlrPatrocFunp13")), nVlrPF13 := 0)

						fGrvRUS(cRJEFil, cPerApur, cCpfTrab, /*cMatric*/, /*cCodCateg*/, cRJETpIns, cRJEInsc, cTpCR, cTpPrev, cCNPJPrev, nVlrPC, nVlrPC13, nVlrPF, nVlrPF13)

						nPrevCompl++
						cPrevCompl := cinfoIRCR + "/previdCompl[" + cValToChar(nPrevCompl) + "]"
					EndDo

					ninfoIRCR++
					cinfoIRCR := cIfIRCompl + "/infoIRCR[" + cValToChar(ninfoIRCR) + "]"
				EndDo

				//Busca e Grava as informações de Plano de Saúde - planSaude
				nPlanSaude := 1
				cPlanSaude := cIfIRCompl + "/planSaude[" + cValToChar(nPlanSaude) + "]"
				While oXml:XPathHasNode(cPlanSaude)
					cCNPJOper	:= oXml:XPathGetNodeValue( cPlanSaude + "/cnpjOper" )
					cRegANS		:= oXml:XPathGetNodeValue( cPlanSaude + "/regANS" )
					nValor		:= Val(oXml:XPathGetNodeValue( cPlanSaude + "/vlrSaudeTit" ))

					//Grava o Plano de Saúde do Titular
					fGrvRUT(cRJEFil, cPerApur, cCpfTrab, /*cMatric*/, /*cCodCateg*/, cRJETpIns, cRJEInsc, cCNPJOper, cRegANS, "1", /*cTpMed*/, /*cInMed*/, "1", /*cCPFDep*/, nValor)

					nIfDepSau := 1
					cIfDepSau := cPlanSaude + "/infoDepSau[" + cValToChar(nIfDepSau) + "]"
					While oXml:XPathHasNode(cIfDepSau)
						cCPFDep		:= oXml:XPathGetNodeValue( cIfDepSau + "/cpfDep" )
						nValor		:= Val(oXml:XPathGetNodeValue( cIfDepSau + "/vlrSaudeDep" ))						

						//Grava o Plano de Saúde do Dependente
						fGrvRUT(cRJEFil, cPerApur, cCpfTrab, /*cMatric*/, /*cCodCateg*/, cRJETpIns, cRJEInsc, cCNPJOper, cRegANS, "1", /*cTpMed*/, /*cInMed*/, "2", cCPFDep, nValor)

						nIfDepSau++
						cIfDepSau := cPlanSaude + "/infoDepSau[" + cValToChar(nIfDepSau) + "]"
					EndDo

					nPlanSaude++
					cPlanSaude := cIfIRCompl + "/planSaude[" + cValToChar(nPlanSaude) + "]"
				EndDo

				//Busca e Grava as informações de Reembolso - infoReembMed
				nIfReemb := 1
				cIfReemb := cIfIRCompl + "/infoReembMed[" + cValToChar(nIfReemb) + "]"
				While oXml:XPathHasNode(cIfReemb)
					cCNPJOper	:= oXml:XPathGetNodeValue( cIfReemb + "/cnpjOper" )
					cRegANS		:= oXml:XPathGetNodeValue( cIfReemb + "/regANS" )

					//Grava o Reembolso do Titular
					nReemTit := 1
					cReemTit := cIfReemb + "/detReembTit[" + cValToChar(nReemTit) + "]"
					While oXml:XPathHasNode(cReemTit)
						cTpInscReem	:= oXml:XPathGetNodeValue( cReemTit + "/tpInsc" )
						cNrInscReem	:= oXml:XPathGetNodeValue( cReemTit + "/nrInsc" )

						//Obtém o valor do reembolso do titular. Pode acontecer da tag não existir no XML
						Iif(oXml:XPathHasNode(cReemTit + "/vlrReemb"), nValor := Val(oXml:XPathGetNodeValue(cReemTit + "/vlrReemb")), nValor := 0)
						Iif(oXml:XPathHasNode(cReemTit + "/vlrReembAnt"), nValorAnt := Val(oXml:XPathGetNodeValue(cReemTit + "/vlrReembAnt")), nValorAnt := 0)

						If nValor > 0 .Or. nValorAnt > 0
							fGrvRUT(cRJEFil, cPerApur, cCpfTrab, /*cMatric*/, /*cCodCateg*/, cRJETpIns, cRJEInsc, cCNPJOper, cRegANS, "2", cTpInscReem, cNrInscReem, "1", /*cCPFDep*/, nValor, nValorAnt)
						EndIf

						nReemTit++
						cReemTit := cIfReemb + "/detReembTit[" + cValToChar(nReemTit) + "]"
					EndDo

					//Grava o Reembolso do Dependente
					nIfReemDep := 1
					cIfReemDep := cIfReemb + "/infoReembDep[" + cValToChar(nIfReemDep) + "]"
					While oXml:XPathHasNode(cIfReemDep)
						cCPFDep		:= oXml:XPathGetNodeValue( cIfReemDep + "/cpfBenef" )
						
						//Grava o Reembolso do Dependente
						nDetReemDep := 1
						cDetReemDep := cIfReemDep + "/detReembDep[" + cValToChar(nDetReemDep) + "]"						
						While oXml:XPathHasNode(cDetReemDep)
							cTpInscReem	:= oXml:XPathGetNodeValue( cDetReemDep + "/tpInsc" )
							cNrInscReem	:= oXml:XPathGetNodeValue( cDetReemDep + "/nrInsc" )

							//Obtém o valor do reembolso do Dependente. Pode acontecer da tag não existir no XML
							Iif(oXml:XPathHasNode(cDetReemDep + "/vlrReemb"), nValor := Val(oXml:XPathGetNodeValue(cDetReemDep + "/vlrReemb")), nValor := 0)
							Iif(oXml:XPathHasNode(cDetReemDep + "/vlrReembAnt"), nValorAnt := Val(oXml:XPathGetNodeValue(cDetReemDep + "/vlrReembAnt")), nValorAnt := 0)

							If nValor > 0 .Or. nValorAnt > 0
								fGrvRUT(cRJEFil, cPerApur, cCpfTrab, /*cMatric*/, /*cCodCateg*/, cRJETpIns, cRJEInsc, cCNPJOper, cRegANS, "2", cTpInscReem, cNrInscReem, "2", cCPFDep, nValor, nValorAnt)
							EndIf

							nDetReemDep++
							cDetReemDep := cIfReemDep + "/detReembDep[" + cValToChar(nDetReemDep) + "]"		
						EndDo

						nIfReemDep++
						cIfReemDep := cIfReemb + "/infoReembDep[" + cValToChar(nIfReemDep) + "]"
					EndDo

					nIfReemb++
					cIfReemb := cIfIRCompl + "/infoReembMed[" + cValToChar(nIfReemb) + "]"
				EndDo

				nIfIRCompl++
				cIfIRCompl := cCabec + "ideTrabalhador/infoIRComplem[" + cValToChar(nIfIRCompl) + "]"	
			EndDo

		EndIf
	EndIf

	oXml := Nil

Return


/*/{Protheus.doc} function fGetXML
Retorna o valor de uma TAG do XML informado
@author  lidio.oliveira
@since   10/10/2025
@version 1.0
/*/
Static Function fGetXML( cTAG, cXML )
	
	Local nIni 	:= 0
	Local nFim 	:= 0
	Local cData := ""

	Default cTAG := ""
	Default cXML := "" 

	nIni 	:= AT("<" + cTAG + ">",  cXML )
	nFim 	:= AT("</" + cTAG + ">", cXML )
	cData 	:= ALLTRIM( STRTRAN(  SUBSTR( cXML, nIni, nFim-nIni ), "<" + cTAG + ">","" ) )

Return cData
