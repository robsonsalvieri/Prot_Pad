#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#Include "TBICONN.CH"
#Include "FWAdapterEAI.ch"

#DEFINE ERRORCODE_DEF	400

//---------------------------------------------------------------------
/*/{Protheus.doc} reportEsocialInssDctfWeb
@type			method
@description	Serviço dos Relatórios de Conferência do eSocial.
@author			lidio.oliveira
@since			01/11/2022
/*/
//---------------------------------------------------------------------
WSRESTFUL reportEsocialInssDctfWeb DESCRIPTION "Serviço do Relatório DCTFWEB" FORMAT APPLICATION_JSON

WSDATA companyId	    	AS STRING
WSDATA requestId			AS STRING
WSDATA paymentPeriod		AS STRING
WSDATA registrationNumber	AS STRING
WSDATA differencesOnly		AS BOOLEAN OPTIONAL


WSMETHOD POST;
	DESCRIPTION "Método para iniciar o processamento do relatório DCTFWEB";
	WSSYNTAX "api/rh/esocial/v1/reportEsocialInssDctfWeb/?{companyId}&{paymentPeriod}";
	PATH "api/rh/esocial/v1/reportEsocialInssDctfWeb/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET InssValues;
	DESCRIPTION "Método para consultar resultado do relatório DCTFWEB";
	WSSYNTAX "api/rh/esocial/v1/reportEsocialInssDctfWeb/InssValues/?{companyId}&{paymentPeriod}&{registrationNumber}&{differencesOnly}";
	PATH "api/rh/esocial/v1/reportEsocialInssDctfWeb/InssValues/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Método responsável por recepcionar os parâmetros e iniciar o processamento do relatório..
@author			lidio.oliveira
@since			01/11/2022
@return			Id. da resuisição: requestId (string)

- Empresa e Filial (obrigatório) - companyId (string)
- Período Folha (obrigatório) - paymentPeriod (string)
    - MMAAAA - mensal
    - AAAA - anual
/*/
//---------------------------------------------------------------------
WSMETHOD POST WSRESTFUL reportEsocialInssDctfWeb

Local aAmb			:= {}
Local oParams   	:= JsonObject():New()
Local oResp     	:= JsonObject():New()
Local cTicket   	:= ""
Local cBody	    	:= self:GetContent()
Local lRet      	:= .T.
Local cEmpAntBck := cEmpAnt
Local cFilAntBck := cFilAnt

Private bError      := { |e| oError := e, Break(e) }
Private bErrorBlock := ErrorBlock( bError )
Private oError

oParams:FromJSON( cBody )

BEGIN SEQUENCE
	If checkParams(oParams)
		aAmb 	:= StrTokArr( oParams["companyId"], "|")
		// Inicialização de Ambiente
		fSetErrorHandler( EncodeUTF8( "Falha ao Inicializar o Ambiente com os dados informados!" ) ) // STR0006: "Falha ao Inicializar o Ambiente com os dados informados!"
		If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
			fTrGrpGPE( aAmb[1], aAmb[2], "RU0", "GPE" )
		EndIf

		//-- Gera o ticket
		cTicket := GeraTicket(cBody, oParams)

		If !Empty(cTicket)
			oResp["requestId"] := cTicket
			//-- faz a resposta para o frontend
			self:SetResponse( oResp:ToJson() )
		EndIf
	Else
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Parâmetros inválidos: Verifique as informações enviadas" ) )
	EndIf
RECOVER
	lRet := .F.
	ErrorBlock( bErrorBlock )
	SetRestFault( 500, EncodeUTF8( "Ocorreu uma falha no retorno da informação." ) + CHR(13) + CHR(10) + oError:Description ) // STR0007: "Ocorreu uma falha no retorno da informação."
END SEQUENCE

FreeObj( oResp)
oResp := Nil
DelClassIntF()

If !Empty(aAmb) .And. Len(aAmb) >= 2 .And. (cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2])
    fTrGrpGPE(cEmpAntBck, cFilAntBck)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} checkParams
Validação dos parâmetros recebidos.

@author lidio.oliveira
@since 01/11/2022
/*/
//-------------------------------------------------------------------
Static Function checkParams(oParams)

    Local lRet	:=	.T.

    If Empty( oParams["companyId"] )
        lRet := .F.
    ElseIf Empty( oParams["paymentPeriod"] )
        lRet := .F.
    EndIf

Return( lRet )


//---------------------------------------------------------------------
/*/{Protheus.doc} GeraTicket
@type			function
@description	Cria e armazena ticket para a requisição.
@author			lidio.oliveira
@since			01/11/2022
@param			cTicket		-	Ticket da requisição
/*/
//---------------------------------------------------------------------
Static Function GeraTicket( cReqJSon, oParams )

    Local cTicket	:=	FWuuId( "GPEDCTFWEB" )

    If VarSetUID(cTicket, .T.)
        VarSetXD(cTicket, "cParams", cReqJSon)
        VarSetXD(cTicket, "cStatus", "1")
    EndIf

Return( cTicket )

//---------------------------------------------------------------------
/*/{Protheus.doc} function fSetErrorHandler
Função para setar erros tratados
@author  lidio.oliveira
@since   01/11/2022
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fSetErrorHandler( cTitle )
	bError  := { |e| oError := e , oError:Description := cTitle + CHR(13) + CHR(10) + oError:Description, Break(e) }
	bErrorBlock	:= ErrorBlock( bError )
Return .T.


//---------------------------------------------------------------------
/*/{Protheus.doc} function fResetErrorHandler
Função para limpar o retorno de erros
@author  lidio.oliveira
@since   01/11/2022
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function fResetErrorHandler( cTitle )
	bError  	:= { |e| oError := e , Break( e ) }
	bErrorBlock := ErrorBlock( bError )
Return .T.



//---------------------------------------------------------------------
/*/{Protheus.doc} InssValues
@type			method
@description	Método para consultar resultado do relatório
@author			lidio.oliveira
@since			09/11/2022
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET InssValues QUERYPARAM companyId, paymentPeriod, registrationNumber, differencesOnly WSRESTFUL reportEsocialInssDctfWeb

Local oResponse		:=	Nil
Local aCompany		:=	{}
Local aEstab		:=	{}
Local lOnlyDiverg	:=	.F.
Local lRet			:=	.T.
Local nX			:=  0
Local cInscr		:=  ""

Private cEmpRequest	:=	""
Private cFilRequest	:=	""

If self:companyId == Nil
	lRet := .F.
	SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:paymentPeriod == Nil
	lRet := .F.
	SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Período não informado no parâmetro 'paymentPeriod'." ) )
ElseIf self:registrationNumber == Nil
	lRet := .F.
	SetRestFault( ERRORCODE_DEF, EncodeUTF8( "CNPJ dos estabelecimentos não informados no parâmetro 'registrationNumber'." ) )
Else

	If !Empty(self:registrationNumber)
		aEstab := StrTokArr( self:registrationNumber, "," )
		//Verifica se há CNPJ diferentes
		For nX := 1 to Len(aEstab)
			If Empty(cInscr)
				cInscr := Substr(aEstab[nX], 1, 8)
			EndIf
			If Substr(aEstab[nX], 1, 8) <> cInscr
				lRet := .F.
				SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Selecione apenas estabelecimentos de mesma raiz de CNPJ." ) )
				Loop
			EndIf
		Next Nx
	Else
		lRet := .F.
		SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Selecione ao menos um estabelecimento." ) )
	EndIf

	If lRet
		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2
			lRet := .F.
			SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )
					If self:differencesOnly <> Nil
						lOnlyDiverg := self:differencesOnly
					EndIf

					GetReport( @oResponse, self:paymentPeriod , lOnlyDiverg, aEstab )

					self:SetResponse( oResponse:toJson() )
			Else
				lRet := .F.
				SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
			EndIf
		EndIf
	EndIf
EndIf

oResponse := Nil
FreeObj( oResponse )
DelClassIntF()

Return( lRet )


//---------------------------------------------------------------------
/*/{Protheus.doc} PrepEnv
@type			function
@description	Prepara o ambiente de acordo com os parâmetros.
@author			lidio.oliveira
@since			09/11/2022
@param			cEmpRequest	-	Empresa indicada no parâmetro companyId
@param			cFilRequest	-	Filial indicada no parâmetro companyId
@return			lRet		-	Indica se o ambiente foi preparado
/*/
//---------------------------------------------------------------------
Static Function PrepEnv( cEmpRequest, cFilRequest )

	Local lRet	:=	.T.

	//Trecho comentado para ser validado a partir da execução via menu protheus
	If Type( "cEmpAnt" ) == "U" .or. Type( "cFilAnt" ) == "U"
		RPCClearEnv()
		RPCSetType( 3 )
		RPCSetEnv( cEmpRequest, cFilRequest,,, "GPE" )
	EndIf

	If lRet
		lRet := FWFilExist( cEmpRequest, cFilRequest )
	EndIf

Return( lRet )


//---------------------------------------------------------------------
/*{Protheus.doc} fGetXMLRet
@type			function
@description	Função que retorna o XML com o evento S-5011 no middleware
@author			lidio.oliveira
@since			09/11/2022
@param			nIndice		-	Indice da tabela
@param			cChave 		-	chave para pesquisa do registro
@return			cXMLRet		-	Retorna o XML RET
/*/
//---------------------------------------------------------------------
Static Function fGetXMLRet(nIndice, cChave)

	Local aArea		:=	GetArea()
	Local cXMLRet	:= ""

	//Abre a Tabela RJE para pesquisar o registro recebido nos parâmetros:
	DbSelectArea( "RJE" )
	DbSetOrder( nIndice )

	//Posiciona no registros encontrado:
	If ( "RJE" )-> (DbSeek( cChave ))
		If RJE->RJE_STATUS == "4"
			cXMLRet := RJE->RJE_RTN
		EndIf
	EndIf

	RestArea( aArea )

Return ( cXMLRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} GetReport
Prepara os dados filtrados no formato JSON para retornar ao front.
@author lidio.oliveira
@since 09/11/2022
/*/
//-------------------------------------------------------------------
Static Function GetReport( oReq, cPeriodo, lOnlyDiverg, aEstab )

	Local aArea			:=	GetArea()
	Local nX			:=  0
	Local lMiddleware	:=  SuperGetMv("MV_MID",,.F.)
	Local nPos			:=  0
	Local cXMLRet		:=  ""
	Local cXMLS5011		:=  ""
	Local aFilias		:=  {}
	Local aFilInTaf		:=  {}
	Local lHasNext		:= .F.
	Local aValues		:=  {}

	//Variáveis para uso no middleware
	Local aInfos		:= {}
	Local lAdmPubl		:= .F.
	Local cTpInsc		:= ""
	Local cNrInsc		:= ""
	Local cChave1299	:= ""

	Private aSM0		:=  FWLoadSM0()
	Private aInfoFil	:= {}
	Private cIndiFol	:= ""

	//aEstab = Establecimentos selecionados pelo usuário

	oReq := JsonObject():New()

	//Pesquisa as filiais que devem ser processadas conforme o CNPJ selecionado
	For nX := 1 to Len(aEstab)
		nPos := aScan(aSM0, { |x| x[1] == cEmpAnt .And. x[18] == aEstab[nX] })
		If nPos > 0
			aAdd(aFilias, {aSM0[nPos,2]}) //Array somente com os códigos das filiais que devem ser processadas
			aAdd(aInfoFil, {aEstab[nX], aSM0[nPos,2], aSM0[nPos,6]}) //Adiciona na array todos os dados da filial para uso posterior
		EndIf
	Next Nx

	cIndiFol := If( Len(cPeriodo) > 4, "1", "2") //Se o período recebido for maior que 4 é folha (1), se não, 13 (2)

	//Pesquisa pelo S-5011
	If !lMiddleware
		If len(aFilias) > 0
			aFilInTaf	:= LoadSM0BaseCNPJ(aFilias[1, 1])
			cXMLRet 	:= fGetTAF1299(aFilInTaf, cPeriodo)
		EndIf
	Else
		aInfos   := fXMLInfos() //Retorna dados do cadastro da empregador RJ9
		If Len(aInfos) > 0
			cTpInsc		:= aInfos[1]
			lAdmPubl	:= aInfos[4]
			cNrInsc		:= Padr(Iif(!lAdmPubl .And. cTpInsc == "1", SubStr(aInfos[2], 1, 8), aInfos[2]), 14)

			//Pesquisa o código da filial na aSM0 a partir do CNPJ da RJ9 (Matriz)
			IF Len(aSM0) > 0
				nPos := aScan(aSM0, { |x| x[1] == cEmpAnt .And. x[18] == aInfos[2]})
				If nPos > 0
					cFilEnv := aSM0[nPos,2]
				EndIf
			EndIf

			cChave1299	:= cTpInsc + cNrInsc + "S1299" + Padr(cFilEnv + cPeriodo + cIndiFol, 40, " ")
			cXMLRet	:= fGetXMLRet(2, cChave1299)
		EndIf
	EndIf

	//Filtro somente os dados do evento S-5011
	If !Empty(cXMLRet)
		cIniRet		:= At('<tot tipo="S5011"', cXMLRet) + 18
		cFimRet		:= At('</tot>', cXMLRet, cIniRet)
		cXMLS5011	:= SubStr( cXMLRet, cIniRet, cFimRet-cIniRet )
	EndIf

	//Pesquisa os dados que devem ser gerados no cjson de retorno
	If Len(aFilias) > 0
		aValues := fGeraDados( cPeriodo, aFilias, lOnlyDiverg, cXMLS5011, aEstab)
	EndIf

	oReq["hasNext"]		:=	lHasNext
	oReq["items"]		:=	aValues

	RestArea( aArea )

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} GetReport
Prepara os dados filtrados no formato JSON para retornar ao front.
@author lidio.oliveira
@since 09/11/2022
/*/
//-------------------------------------------------------------------

Static Function fGeraDados( cPeriodo, aFilEstab, lOnlyDiverg, cXMLS5011, aEstab)

	Local aArea			:= GetArea()
	Local lParcial		:= .F.
	Local lGeraRat  	:= SuperGetMv("MV_RATESOC",, .T.)
	Local lVerRJ5		:= FindFunction("fVldObraRJ") .And. (fVldObraRJ(@lParcial, .T.) .And. !lParcial .And. lGeraRat)
	Local a001			:= {} //Guarda dados do establecimento
	Local a002			:= {} //Guarda os valores por estabelecimento
	Local a003			:= {} //Guarda dados da lotação
	Local a004			:= {} //Guardo os valores por lotação
	Local aDados		:= {}
	Local aDadosLot		:= {}
	Local aRet			:= {}
	Local aTpVlrLot		:= {}
	Local aTpVlrRet		:= {}
	Local aTabS037      := {}
	Local oDados		:= Nil
	Local oDadosLot		:= Nil
	Local oRet			:= Nil
	Local oXml 			:= tXmlManager():New()
	Local cCabec		:= "/eSocial/evtCS/infoCS/"
	Local cCodRec		:= ""
	Local cQry			:= ""
	Local cFilSel		:= ""
	Local cFilOld		:= ""
	Local cinfoContr	:= ""
	Local cInSbPa		:= "N"
	Local nL			:= 0
	Local nI 			:= 0
	Local nPos			:= 0
	Local nX 			:= 0
	Local nZ 			:= 0
	Local nW			:= 0
	Local nIdeEstab		:= 0
	Local nvrDescCP		:= 0
	Local nvrCpSeg		:= 0
	Local nVlrRec		:= 0
	Local nvrInSbPa		:= 0
	Local nTotCR		:= 0
	Local nTotVrCR		:= 0
	Local nTotDed		:= 0
	Local nTotDedRet	:= 0
	Local nPosRatA		:= 0
	Local lProcFil		:= .T.
	Local lInSbPa		:= .F.
	Local l37InSbPa		:= .F.

	Private cNextAlias	:= GetNextAlias()
	Private cSRDTabRJ	:= GetNextAlias()
	Private oTmpTabRJ	:= Nil
	Private oTmpTable	:= Nil
	Private lCpoPIS 	:= RU0->( ColumnPos( "RU0_PIS" ) ) > 0

	oRet:= JsonObject():New()

	For nI := 1 to Len( aFilEstab )
		If !Empty( cFilSel )
			cFilSel += ","
		EndIf

		cFilSel += "'" + aFilEstab[nI,1] + "'"
	Next nI

	cQry := "SELECT "
	cQry += "   RU0.RU0_FILIAL FILIAL, "
	cQry += "    RU0.RU0_MAT MATRICULA,  "
	cQry += "    RU0.RU0_PERIOD PERIODO, "
	cQry += "    RU0.RU0_SEMANA SEMANA, "
	cQry += "    RU0.RU0_EAGNOC EAGNOC, "
	cQry += "    RU0.RU0_CATEFD CATEFD, "
	cQry += "    RU0.RU0_CONVEA CONVEA, "
	cQry += "    RU0.RU0_TOTBSC TOTBSC, "
	cQry += "    RU0.RU0_TOTBCS TOTBCS, "
	cQry += "    RU0.RU0_SEST SEST, "
	cQry += "    RU0.RU0_SENAT SENAT, "
	cQry += "    RU0.RU0_SALMAT SALMAT, "
	cQry += "    RU0.RU0_SALFAM SALFAM, "
	cQry += "    RU0.RU0_SALEDU SALEDU, "
	cQry += "    RU0.RU0_VLRPAT VLRPAT, "
	cQry += "    RU0.RU0_INCRA INCRA, "
	cQry += "    RU0.RU0_SENAC SENAC, "
	cQry += "    RU0.RU0_SESC SESC, "
	cQry += "    RU0.RU0_SEBRAE SEBRAE, "
	cQry += "    RU0.RU0_LOTACA LOTACAO, "
	cQry += "    RU0.RU0_FAP FAP, "
	cQry += "    RU0.RU0_RAT RAT,  "
	cQry += "    RU0.RU0_RAJU RATAJUST,  "
	cQry += "    RU0.RU0_FPAS FPAS,  "
	cQry += "    RU0.RU0_CODTER CODTER,  "
	cQry += "    RU0.RU0_SENAI SENAI,  "
	cQry += "    RU0.RU0_SESI SESI,  "
	cQry += "    RU0.RU0_DPC DPC,  "
	cQry += "    RU0.RU0_FAER FAER,  "
	cQry += "    RU0.RU0_SENAR SENAR,  "
	cQry += "    RU0.RU0_SECONC SECONC,  "
	cQry += "    RU0.RU0_SESCOO SESCOO,  "
	cQry += "    RU0.RU0_GILRAT GILRAT,  "
	If lCpoPIS
		cQry += "    RU0.RU0_PIS PIS,  "
	EndIf
	cQry += "    RU0.RU0_INSSTE INSSTE  "
	cQry += "	 FROM  "+RetSqlName("RU0")+" RU0  "
	cQry += "	 WHERE RU0.D_E_L_E_T_ = '' "
	cQry += "    AND RU0_FILIAL IN ( " + cFilSel + " ) "
	cQry += "    AND RU0_PERIOD = '"+ cPeriodo +"'  "
	cQry += "	 ORDER BY RU0.RU0_FILIAL,RU0.RU0_LOTACA,RU0.RU0_CATEFD "

	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), cNextAlias,.T.,.T.)

	If lVerRJ5
		fVerRJ5A(cNextAlias, cSRDTabRJ, cPeriodo /*, @lRJ5Ok, /*@aRJ5CC*/)
	EndIf

	//Carrega a tabela S037
	fCarrTab(@aTabS037, "S037")

	//Processo a tabela
	While (cNextAlias)->( !Eof() )

		//Varíveis usadas no establishments
		nPosFil := aScan(aInfoFil, { |x| x[2] == (cNextAlias)->FILIAL})
		cCNPJ	:= aInfoFil[nPosFil,1]
		cDesc	:= aInfoFil[nPosFil,3]

		If cFilOld <> (cNextAlias)->FILIAL
			cCNAE	:= Posicione('SM0', 1, cEmpAnt + (cNextAlias)->FILIAL, "M0_CNAE")
			cFPAS	:= Posicione('SM0', 1, cEmpAnt + (cNextAlias)->FILIAL, "M0_FPAS")
			cFilOld := (cNextAlias)->FILIAL
		EndIf

		If lVerRJ5
			cFPAS := (cNextAlias)->FPAS
		EndIf

		//Obtém o valor do RAT
		nRAT	:= (cNextAlias)->RAT

		If Len(aTabS037) > 0 
			//Obtém o valor do RAT Ajustado (% Acidente de Trabalho), caso esteja vazio procura o valor na tabela S037
			nRATAJU	:= (cNextAlias)->RATAJUST			
			//Procura o resgistro com filial e com o mês de referência
			If (nPosRatA := Ascan(aTabS037,{ |x| x[1] == "S037" .And. x[2] == (cNextAlias)->FILIAL .And. x[3] == cPeriodo })) > 0
				nRATAJU 	:=  If(Empty(nRATAJU), aTabS037[nPosRatA][7],nRATAJU)
				cInSbPa		:= aTabS037[nPosRatA][10]
			//Procura o registro sem filial mas com o mesmo mês de referência
			ElseIf (nPosRatA := Ascan(aTabS037,{ |x| x[1] == "S037" .And.x[2] == Space(Len((cNextAlias)->FILIAL)) .And. x[3] == cPeriodo })) > 0
				nRATAJU 	:= If(Empty(nRATAJU), aTabS037[nPosRatA][7],nRATAJU)
				cInSbPa		:= aTabS037[nPosRatA][10]
			//Procura o resgistro com filial e sem mês referência
			ElseIf (nPosRatA := Ascan(aTabS037,{ |x| x[1] == "S037" .And. x[2] == (cNextAlias)->FILIAL})) > 0
				nRATAJU 	:= If(Empty(nRATAJU), aTabS037[nPosRatA][7],nRATAJU)
				cInSbPa		:= aTabS037[nPosRatA][10]
			//Procura o resgistro sem filial e sem mês referência
			ElseIf (nPosRatA := Ascan(aTabS037,{ |x| x[1] == "S037" .And. x[2] == Space(Len((cNextAlias)->FILIAL))})) > 0
				nRATAJU 	:= If(Empty(nRATAJU), aTabS037[nPosRatA][7],nRATAJU)
				cInSbPa		:= aTabS037[nPosRatA][10]
			EndIf				
			l37InSbPa	:= If(cInSbPa # 'N', .T., .F.)
		EndIf

		//Obtém o valor do FAP 
		nFAP	:= (cNextAlias)->FAP
		If Empty(nFAP)
			nFap := NoRound(nRATAJU / nRAT, 4)
		EndIf

		//Variáveis usadas para a lotação
		cCodLot  	:= xFilial("CTT", (cNextAlias)->FILIAL) + (cNextAlias)->LOTACAO

		If lVerRJ5
			cDescLot 	:= encodeUtf8("Lotação " + cCodLot)
		Else
			cDescLot 	:= Posicione( "CTT", 1, cCodLot , "CTT_DESC01" )
		EndIf

		cCodTer  	:= (cNextAlias)->CODTER
		nValor 	 	:= 0
		nVlrRec		:= 0
		cTpValor 	:= ""
		aTpVlrLot	:= {}

		//Variveis usados para as valores por categoria
		cCateg	:= (cNextAlias)->CATEFD
		If (cNextAlias)->TOTBSC > 0
			nValor	:= (cNextAlias)->TOTBSC
		EndIf

		//Adiciona no array de estabecimentos
		If Len(a001) == 0
			Aadd(a001,{cCNPJ, cDesc, cCNAE, nRAT, nRATAJU, nFAP, l37InSbPa, "", 0, 0, 0, .F.})
		Else
			nPos := aScan(a001, { |x| x[1] == cCNPJ})
			If nPos == 0
				Aadd(a001,{cCNPJ, cDesc, cCNAE, nRAT, nRATAJU, nFAP, l37InSbPa, "", 0, 0, 0, .F.})
			EndIf
		EndIf

		//Carrega os valores por código de receita
		aVlrCodRec :=  fCodRec(cIndiFol, alltrim(cFPAS))

		//Adiciona no array de valores por receita
		For nW := 1 to Len(aVlrCodRec)
			//Adiciona na array de valores do estabelecimento
			cCodRec := aVlrCodRec[nW, 1]
			nVlrRec := aVlrCodRec[nW, 2]

			If Len(a002) == 0
				Aadd(a002,{cCNPJ, cCodRec, nVlrRec, 0, .T.})
			Else
				nPos := aScan(a002, { |x| x[1] == cCNPJ .And. x[2] == cCodRec})
				If nPos > 0
					a002[nPos, 3] += nVlrRec
				else
					Aadd(a002,{cCNPJ, cCodRec, nVlrRec, 0, .T.})
				EndIf
			EndIf

			nTotCR += nVlrRec

		Next nW

		//Adiciona no array de Lotações
		If Len(a003) == 0
			Aadd(a003,{cCNPJ, alltrim(cCodLot), alltrim(cDescLot), cFPAS, cCodTer, "", ""})
		Else
			nPos := aScan(a003, { |x| x[1] == cCNPJ .And. x[2] == alltrim(cCodLot)})
			If nPos == 0
				Aadd(a003,{cCNPJ, alltrim(cCodLot), alltrim(cDescLot), cFPAS, cCodTer, "", ""})
			EndIf
		EndIf

		//Carrega os valores de encargos
		aTpVlrLot :=  fCodBsCont()

		//Adiciona no array de valores da Lotações
		For nW := 1 to Len(aTpVlrLot)

			cTpValor := aTpVlrLot[nW, 1]
			nValor 	 := aTpVlrLot[nW, 2]

			If Len(a004) == 0
				Aadd(a004,{cCNPJ, alltrim(cCodLot), cCateg, cTpValor, nValor, 0, .T.})
			Else
				nPos := aScan(a004, { |x| x[1] == cCNPJ .And. x[2] == alltrim(cCodLot) .And. x[3] == cCateg .And. x[4] == cTpValor})
				If nPos > 0
					a004[nPos, 5] += nValor
				Else
					Aadd(a004,{cCNPJ, alltrim(cCodLot), cCateg, cTpValor, nValor, 0, .T.})
				EndIf
			EndIf

			//Somatório das Deduções
			If cTpValor $ "vrSalFam*vrSalMat"
				nTotDed += nValor
			EndIf
		Next nW

	    (cNextAlias)->( dbSkip() )

	EndDo

	(cNextAlias)->( dbCloseArea() )

	If Select( cSRDTabRJ ) > 0
		(cSRDTabRJ)->( dbCloseArea() )
	EndIf

	//Varre o XML de retorno para preencher os valores do RET
	If !Empty(cXMLS5011)

		//adiciona no "aTpVlrRet" os tipos de valores a serem pesquisados
		aAdd(aTpVlrRet, "vrBcCp00")
		aAdd(aTpVlrRet, "vrBcCp15")
		aAdd(aTpVlrRet, "vrBcCp20")
		aAdd(aTpVlrRet, "vrBcCp25")
		aAdd(aTpVlrRet, "vrSuspBcCp00")
		aAdd(aTpVlrRet, "vrSuspBcCp15")
		aAdd(aTpVlrRet, "vrSuspBcCp20")
		aAdd(aTpVlrRet, "vrSuspBcCp25")
		aAdd(aTpVlrRet, "vrDescSest")
		aAdd(aTpVlrRet, "vrCalcSest")
		aAdd(aTpVlrRet, "vrDescSenat")
		aAdd(aTpVlrRet, "vrCalcSenat")
		aAdd(aTpVlrRet, "vrSalFam")
		aAdd(aTpVlrRet, "vrSalMat")

		//Varre o XML Ajustando os valores no array
		If oXml:Parse( fMidTrPath(cXMLS5011,"eSocial") )

			cinfoCPSeg := cCabec + "infoCPSeg[1]"
			If oXml:XPathHasNode(cinfoCPSeg)
				nvrDescCP := Val(oXml:XPathGetNodeValue( cinfoCPSeg + "/vrDescCP " ))
				nvrCpSeg  := Val(oXml:XPathGetNodeValue( cinfoCPSeg + "/vrCpSeg " ))
			EndIf

			cinfoContr := cCabec + "infoContrib/infoPJ/indSubstPatr"
			If oXml:XPathHasNode(cinfoContr)
				nvrInSbPa	:= Val(oXml:XPathGetNodeValue( cinfoContr ))
				lInSbPa		:= If(nvrInSbPa > 0, .T., .F.)
			EndIf

			nIdeEstab := 1
			cOcorren := cCabec + "ideEstab[" + cValToChar(nIdeEstab) + "]"

			//Dados do estabelecimento
			While oXml:XPathHasNode(cOcorren)
				cCNPJ := oXml:XPathGetNodeValue( cOcorren + "/nrInsc" )
				nInfoEstab := 1
				cInfoEstab := cOcorren + "/infoEstab[" + cValToChar(nInfoEstab) + "]"
				lProcFil := aScan(aEstab, { |x| x == cCNPJ }) > 0 //Processa apenas as filais indicadas no filtro

				If lProcFil
					//Informações do estabelecimento
					While oXml:XPathHasNode(cInfoEstab)
						cCNAERet 	:= oXml:XPathGetNodeValue( cInfoEstab + "/cnaePrep" )
						nAliqRATRET := Val(oXml:XPathGetNodeValue( cInfoEstab + "/aliqRat" ))
						nFAPRet 	:= Val(oXml:XPathGetNodeValue( cInfoEstab + "/fap" ))
						nRATAjusRET := Val(oXml:XPathGetNodeValue( cInfoEstab + "/aliqRatAjust" ))

						//Atualiza os dados do RET no array
						If Len(a001) == 0
							Aadd(a001,{cCNPJ, "cDesc", "cCNAE", 0, 0, 0, .F., cCNAERet, nAliqRATRET, nFAPRet, nRATAjusRET, lInSbPa})
						Else
							nPos := aScan(a001, { |x| x[1] == cCNPJ})
							If nPos == 0
								Aadd(a001,{cCNPJ, "cDesc", "cCNAE", 0, 0, 0, .F., cCNAERet, nAliqRATRET, nFAPRet, nRATAjusRET, lInSbPa})
							Else
								a001[nPos, 8] := cCNAERet
								a001[nPos, 9] := nAliqRATRET
								a001[nPos, 10] := nFAPRet
								a001[nPos, 11] := nRATAjusRET
								a001[nPos, 12] := lInSbPa
							EndIf
						EndIf
						nInfoEstab ++
						cInfoEstab := cOcorren + "/infoEstab[" + cValToChar(nInfoEstab) + "]"
					EndDo

					//Verifica os valores por estabecilmento(Cod Receita)
					ninfoCREstab := 1
					cinfoCREstab := cOcorren + "/infoCREstab[" + cValToChar(ninfoCREstab) + "]"
					While oXml:XPathHasNode(cinfoCREstab)
						ctpCR 	:= Substr(oXml:XPathGetNodeValue( cinfoCREstab + "/tpCR" ), 1, 4) + "-";
							+ Substr(oXml:XPathGetNodeValue( cinfoCREstab + "/tpCR" ), 5, 2)
						nvrCR	:= Val(oXml:XPathGetNodeValue( cinfoCREstab + "/vrCR" ))

						nTotVrCR += nvrCR

						//Adiciona na array de valores do estabelecimento
						If Len(a002) == 0
							Aadd(a002,{cCNPJ, ctpCR, 0, nvrCR, .T.})
						Else
							nPos := aScan(a002, { |x| x[1] == cCNPJ .And. x[2] == ctpCR})
							If nPos > 0
								a002[nPos, 4] += nvrCR
							else
								Aadd(a002,{cCNPJ, ctpCR, 0, nvrCR, .T.})
							EndIf
						EndIf

						ninfoCREstab ++
						cinfoCREstab := cOcorren + "/infoCREstab[" + cValToChar(ninfoCREstab) + "]"
					EndDo


					//Verifica os dados por lotação
					nideLotacao := 1
					cIdeLotacao := cOcorren + "/ideLotacao[" + cValToChar(nideLotacao) + "]"
					While oXml:XPathHasNode(cIdeLotacao)
						cLotRet 	:= oXml:XPathGetNodeValue( cIdeLotacao + "/codLotacao" )
						cFPASRet	:= oXml:XPathGetNodeValue( cIdeLotacao + "/fpas" )
						cTercRet	:= oXml:XPathGetNodeValue( cIdeLotacao + "/codTercs" )

						//Adiciona no array de Lotações
						If Len(a003) == 0
							Aadd(a003,{cCNPJ, alltrim(cLotRet), "", "", "", cFPASRet, cTercRet})
						Else
							nPos := aScan(a003, { |x| x[1] == cCNPJ .And. x[2] == alltrim(cLotRet)})
							If nPos == 0
								Aadd(a003,{cCNPJ, alltrim(cLotRet), "", "", "", cFPASRet, cTercRet})
							Else
								a003[nPos, 6] := cFPASRet
								a003[nPos, 7] := cTercRet
							EndIf
						EndIf

						//Verifica os dados por categoria
						nBasesRemun := 1
						cBasesRemun := cIdeLotacao + "/basesRemun[" + cValToChar(nBasesRemun) + "]"

						While oXml:XPathHasNode(cBasesRemun)
							cCategRet	:= oXml:XPathGetNodeValue( cBasesRemun + "/codCateg" )

							nBasesCP := 1
							cBasesCp := cBasesRemun + "/basesCp[" + cValToChar(nBasesCP) + "]"
							While oXml:XPathHasNode(cBasesCp)

								For nL := 1 to Len(aTpVlrRet)
									cTpVlr 	:= aTpVlrRet[nL]
									nVlrRet	:= Val(oXml:XPathGetNodeValue( cBasesCp + "/" + cTpVlr ))

									If nVlrRet > 0
										If Len(a004) == 0
											Aadd(a004,{cCNPJ, alltrim(cLotRet), cCategRet, cTpVlr, 0, nVlrRet, .T.})
										Else
											nPos := aScan(a004, { |x| x[1] == cCNPJ .And. x[2] == alltrim(cLotRet) .And. x[3] == cCategRet .And. x[4] == cTpVlr})
											If nPos > 0
												a004[nPos, 6] += nVlrRet
											Else
												Aadd(a004,{cCNPJ, alltrim(cLotRet), cCategRet, cTpVlr, 0, nVlrRet, .T.})
											EndIf
										EndIf
									EndIf

									//Somatório das Deduções
									If cTpVlr $ "vrSalFam*vrSalMat"
										nTotDedRet += nVlrRet
									EndIf

								Next nL

								nBasesCP ++
								cBasesCp := cBasesRemun + "/basesCp[" + cValToChar(nBasesCP) + "]"
							EndDo

							nBasesRemun ++
							cBasesRemun := cIdeLotacao + "/basesRemun[" + cValToChar(nBasesRemun) + "]"
						EndDo

						nideLotacao ++
						cIdeLotacao := cOcorren + "/ideLotacao[" + cValToChar(nideLotacao) + "]"
					EndDo
				EndIf
				nIdeEstab ++
				cOcorren := cCabec + "ideEstab[" + cValToChar(nIdeEstab) + "]"
			EndDo
		EndIf
	EndIf

	//Dados Por Estabelecimento
	For nX := 1 To Len(a001)

		oDados:= JsonObject():New()
		aDadosLot := {}

		oDados["registrationNumber"] 	:= Transform(a001[nX,1], "@R ##.###.###/####-##")
		oDados["description"] 			:= alltrim(a001[nX,2])
		oDados["cnae"] 					:= a001[nX,3]
		oDados["aliquotRat"] 			:= a001[nX,4]
		oDados["aliquotRatAdjusted"] 	:= a001[nX,5]
		oDados["fap"]					:= a001[nX,6]
		oDados["employerReplacement"] 	:= a001[nX,7]
		oDados["cnaeRet"] 				:= a001[nX,8]
		oDados["aliquotRatRet"] 		:= a001[nX,9]
		oDados["aliquotRatAdjustedRet"] := a001[nX,11]
		oDados["fapRet"] 				:= a001[nX,10]
		oDados["employerReplacementRet"]:= a001[nX,12]
		oDados["establishmentValues"]	:= fEstabValues(a001[nX, 1], a002, lOnlyDiverg) //Valores do Estabelecimento

		//Dados da lotação
		For nZ := 1 To Len(a003)

			oDadosLot:= JsonObject():New()

			If a003[nZ,1] == a001[nX,1] //Se for o Mesmo CNPJ
				oDadosLot["lotationCode"] 		:= a003[nZ,2]
				oDadosLot["description"] 		:= a003[nZ,3]
				oDadosLot["fpas"] 				:= a003[nZ,4]
				oDadosLot["thirdCode"] 			:= a003[nZ,5]
				oDadosLot["fpasRet"] 			:= a003[nZ,6]
				oDadosLot["thirdCodeRet"]		:= a003[nZ,7]
				oDadosLot["lotationValues"]		:= fLotValues(a003[nZ, 1] + a003[nZ, 2], a004, lOnlyDiverg) //Valores da lotação
				aAdd(aDadosLot, oDadosLot)
			EndIf

		Next nZ

		oDados["lotations"]	:= aDadosLot
		aAdd(aDados, oDados)

	Next Nx

	IF Len(a001) > 0
		oRet["companyId"] 			:= cEmpRequest + "|" + cFilRequest
		oRet["month"] 				:= Val(If(cIndiFol == "1", SubStr(cPeriodo, 5, 2), "12"))
		oRet["year"] 				:= Val(SubStr(cPeriodo, 1, 4))
		oRet["period"] 				:= Val(cIndiFol)
		oRet["totalEmployees"] 		:= nvrDescCP
		oRet["totalCompany"] 		:= nTotCR
		oRet["totalDeductions"] 	:= nTotDed
		oRet["totalInss"] 			:= nvrDescCP + nTotCR - nTotDed
		oRet["totalEmployeesRet"] 	:= nvrCpSeg
		oRet["totalCompanyRet"] 	:= nTotVrCR
		oRet["totalDeductionsRet"] 	:= nTotDedRet
		oRet["totalInssRet"] 		:= nvrCpSeg + nTotVrCR - nTotDedRet
		oRet["establishments"] 		:= aDados

		aAdd(aRet, oRet)
	EndIf

	RestArea( aArea )

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} fEstabValues
Retorna os valores por estabelecimento.
@author lidio.oliveira
@since 09/11/2022
/*/
//-------------------------------------------------------------------
Static Function fEstabValues(cChave, aEstabVal, lOnlyDiverg)

	Local oVal		:= Nil
	Local nX		:= 0
	Local aJson		:= {}

	Default aLotVal := {}

	//Ordenado o array pela chave (CNPJ) + Código de Receita
	aSort(aEstabVal,,, { |x, y| x[1]+x[2] < y[1]+ y[2] } )

	For nX := 1 to Len(aEstabVal)

		oVal:= JsonObject():New()

		If aEstabVal[nX,1] == cChave //Mesmo CNPJ
			oVal["code"] 			:= aEstabVal[nX,2]
			oVal["payrollValue"] 	:= aEstabVal[nX,3]
			oVal["retValue"] 		:= aEstabVal[nX,4]
			oVal["divergent"] 		:= If(aEstabVal[nX,3] <> aEstabVal[nX,4], .T., .F.)

			If (lOnlyDiverg .And. oVal["divergent"] ) .Or. !lOnlyDiverg
				aAdd( aJson, oVal )
			EndIf
		EndIf
	Next nX

Return( aJson )


//-------------------------------------------------------------------
/*/{Protheus.doc} fLotValues
Retorna os valores por lotação.
@author lidio.oliveira
@since 09/11/2022
/*/
//-------------------------------------------------------------------
Static Function fLotValues(cChave, aLotVal, lOnlyDiverg)

	Local oVal		:= Nil
	Local nX		:= 0
	Local aJson		:= {}

	Default aLotVal := {}

	//Ordenado o array pela chave (CNPJ) + Código Lotação + Código Categoria
	aSort(aLotVal,,, { |x, y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] } )

	For nX := 1 to Len(aLotVal)

		oVal:= JsonObject():New()

		If aLotVal[nX,1] + aLotVal[nX,2] == cChave //MESMO CNPJ E LOTACAO
			oVal["category"] 		:= aLotVal[nX,3]
			oVal["valueType"] 		:= aLotVal[nX,4]
			oVal["payrollValue"] 	:= aLotVal[nX,5]
			oVal["retValue"] 		:= aLotVal[nX,6]
			oVal["divergent"] 		:= If(aLotVal[nX,5] <> aLotVal[nX,6], .T., .F.)

			If (lOnlyDiverg .And. oVal["divergent"] ) .Or. !lOnlyDiverg
				aAdd( aJson, oVal )
			EndIf
		EndIf
	Next nX

Return( aJson )


//-------------------------------------------------------------------
/*/{Protheus.doc} fCodBsCont
Monta array com os valores vs tag
@author lidio.oliveira
@since 14/11/2022
/*/
//-------------------------------------------------------------------
Static Function fCodBsCont()

	Local aRet 		:= {}
	Local aRegra	:= {}
	Local aRegraSus	:= {}
	Local nPos		:= 0

	//REGRA PARA O CAMPO RU0_VLRBSC
				//Agente nocivo  //Cont. Verd. Ama.  	//Tag
	aAdd(aRegra, {"1" 			,"N"				, "vrBcCp00"})
	aAdd(aRegra, {"2" 			,"N"				, "vrBcCp15"})
	aAdd(aRegra, {"3" 			,"N"				, "vrBcCp20"})
	aAdd(aRegra, {"4" 			,"N"				, "vrBcCp25"})
	aAdd(aRegra, {"1" 			,"S"				, "vrBcCp00VA"})
	aAdd(aRegra, {"2" 			,"S"				, "vrBcCp15VA"})
	aAdd(aRegra, {"3" 			,"S"				, "vrBcCp25VA"})
	aAdd(aRegra, {"4" 			,"S"				, "vrBcCp25VA"})

	//REGRA PARA O CAMPO RU0_VLRBCS
					//Agente nocivo  //Cont. Verd. Ama.  	//Tag				//tagVA
	aAdd(aRegraSus, {"1" 			,"N"				, "vrSuspBcCp00"})
	aAdd(aRegraSus, {"2" 			,"N"				, "vrSuspBcCp15"})
	aAdd(aRegraSus, {"3" 			,"N"				, "vrSuspBcCp20"})
	aAdd(aRegraSus, {"4" 			,"N"				, "vrSuspBcCp25"})
	aAdd(aRegraSus, {"1" 			,"S"				, "vrSuspBcCp00VA"})
	aAdd(aRegraSus, {"2" 			,"S"				, "vrSuspBcCp15VA"})
	aAdd(aRegraSus, {"3" 			,"S"				, "vrSuspBcCp20VA"})
	aAdd(aRegraSus, {"4" 			,"S"				, "vrSuspBcCp25VA"})

	//adiciona o valor de base cálculo
	If (cNextAlias)->TOTBSC > 0
		nPos := aScan(aRegra, { |x| x[1] == (cNextAlias)->EAGNOC .And. x[2] == (cNextAlias)->CONVEA })
		If nPos > 0
			aAdd(aRet,{aRegra[nPos,3],(cNextAlias)->TOTBSC})
		EndIf
	EndIf

	////adiciona o valor de base cálculo suspenso
	If (cNextAlias)->TOTBCS > 0
		nPos := aScan(aRegraSus, { |x| x[1] == (cNextAlias)->EAGNOC .And. x[2] == (cNextAlias)->CONVEA })
		If nPos > 0
			aAdd(aRet, {aRegraSus[nPos,3], (cNextAlias)->TOTBCS})
		EndIf
	EndIf

	//adiciona o valor de desconto SEST
	If (cNextAlias)->SEST > 0
		aAdd(aRet, {"vrDescSest", (cNextAlias)->SEST})
		aAdd(aRet, {"vrCalcSest", (cNextAlias)->SEST})
	EndIf

	//adiciona o valor de desconto SENAT
	If (cNextAlias)->SENAT > 0
		aAdd(aRet, {"vrDescSenat", (cNextAlias)->SENAT})
		aAdd(aRet, {"vrCalcSenat", (cNextAlias)->SENAT})
	EndIf

	//adiciona o valor salário família
	If (cNextAlias)->SALFAM > 0
		aAdd(aRet, {"vrSalFam", (cNextAlias)->SALFAM})
	EndIf

	//adiciona o valor salário manternidade
	If (cNextAlias)->SALMAT > 0
		aAdd(aRet, {"vrSalMat", (cNextAlias)->SALMAT})
	EndIf

Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} fCodBsCont
Monta array com os valores vs tag
@author lidio.oliveira
@since 14/11/2022
/*/
//-------------------------------------------------------------------
Static Function fCodRec(cInd13, cCodFPAS)

	Local aRet 		:= {} //Retorna o código de receita e o valor
	Local aRegra	:= {}
	Local nPos		:= 0
	Local nInd		:= 0
	Local lAutonomo := .F.

	Default cInd13 		:= "1"
	Default cCodFPAS	:= ""

	nInd := Val(cInd13)

	//Código de Receita FOLHA | 13 | SE AUTONOMO | CAMPO RU0 | código FPAS
	aAdd(aRegra, {"1138-01", "1138-21", .F., "VLRPAT", ""}) //20% sobre empregado
	//aAdd(aRegra, {"1138-02", "1138-22", .F., "XXX", }) //2.5% alíquota adicional (N TRATADO)
	//aAdd(aRegra, {"1138-03", "1138-23", .F., "XXX"}) //20% Simples Concomitante (N TRATADO)
	aAdd(aRegra, {"1138-04", "NAplica", .T., "VLRPAT", ""}) // 20% sobre autonomo
	//aAdd(aRegra, {"1138-05", "NAplica", .T., "XXX", } ) //2.5% alíquota adicional autonomo (N TRATADO)
	//aAdd(aRegra, {"1138-06", "NAplica", .T., "XXX", } ) //20% Simples Concomitante autonomo (N TRATADO)
	//aAdd(aRegra, {"1138-07", "1138-27", .F., "XXX", } ) //MEI 3% (N TRATADO)
	//aAdd(aRegra, {"1138-08", "1138-28", .F., "XXX", } ) //Empregador Doméstico (N TRATADO)
	//aAdd(aRegra, {"1141-01", "1141-21", .F., "XXX", } ) //Adicional Agente Nocivo (N TRATADO)
	//aAdd(aRegra, {"1131-02", "1142-21", .F., "XXX", } ) //Adicional Agente Nocivo Simples Concomitante (N TRATADO)
	aAdd(aRegra, {"1646-01", "1646-21", .F., "GILRAT", ""}) //GilRat Ajustado x%
	//aAdd(aRegra, {"1646-02", "1646-22", .F., "XXX", }) //GilRat Simples Concomitante x%
	//aAdd(aRegra, {"1646-09", "1646-29", .F., "XXX", }) //GilRat Empregador Doméstico 0.8%  (N TRATADO)
	aAdd(aRegra, {"1170-01", "1170-21", .F., "SALEDU", ""}) //Salário Educação - 2.5%
	aAdd(aRegra, {"1176-01", "1176-21", .F., "INCRA", "All"}) //INCRA 0.2%
	aAdd(aRegra, {"1176-02", "1176-22", .F., "INCRA", "0531*0795*0825"}) //INCRA (Adic. FPAS 531/795/825) – 2,7%
	aAdd(aRegra, {"1181-01", "1181-21", .F., "SENAI", ""}) //SENAI – 1,0%
	aAdd(aRegra, {"1184-01", "1184-21", .F., "SESI", ""}) //SESI – 1,5%
	aAdd(aRegra, {"1191-01", "1191-21", .F., "SENAC", ""}) //SENAC – 1,0%
	aAdd(aRegra, {"1196-01", "1196-21", .F., "SESC", ""}) //SESC – 1,5%
	aAdd(aRegra, {"1200-01", "1200-21", .F., "SEBRAE", "All"}) //SEBRAE – 0,6%
	aAdd(aRegra, {"1200-02", "1200-21", .F., "SEBRAE", "0566*0574*0647"}) //SEBRAE (FPAS 566/574/647) – 0,3%
	aAdd(aRegra, {"1205-01", "1205-21", .F., "DPC", ""}) //FDEPM – 2,5%
	aAdd(aRegra, {"1209-01", "1209-21", .F., "FAER", ""}) //Fundo Aeroviário – 2,5%
	aAdd(aRegra, {"1213-01", "1213-21", .F., "SENAR", ""}) //SENAR PJ/Agroind.(s/FPG FPAS 787/795) – 2,5%
	aAdd(aRegra, {"1218-01", "1218-21", .F., "SEST", ""}) //SEST (a cargo empresa – FPAS 612) – 1,5%
	aAdd(aRegra, {"1221-01", "1221-21", .F., "SENAT", ""}) //SENAT (a cargo empresa – FPAS 612) – 1,0%
	aAdd(aRegra, {"1225-01", "1225-21", .F., "SESCOO", ""}) //SESCOOP – 2,5%
	If lCpoPIS
		aAdd(aRegra, {"8301-02", "8301-22", .F., "PIS", ""}) //PIS
	EndIf

	//Indifica se é um autônomo
	lAutonomo := ((cNextAlias)->CATEFD $ fCatTrabEFD("TSV"))

	//Zera código FPAS se não for preciso utiliza-lo para consulta no array
	If !(cCodFPAS $ "0531*0795*0825*0566*0574*0647")
		cCodFPAS := ""
	EndIf

	//Percorre o array para retornar os códigos de receita que possuem valor
	For nPos := 1 To Len(aRegra)
		If (cNextAlias)->&(aRegra[nPos, 4]) > 0 .And. aRegra[nPos, 3] == lAutonomo .And.;
		(cCodFPAS $ aRegra[nPos, 5] .Or. Empty(aRegra[nPos, 5]) .Or. (Empty(cCodFPAS) .And. aRegra[nPos, 5] == "All"))
			aAdd(aRet,{aRegra[nPos,nInd], (cNextAlias)->&(aRegra[nPos, 4])})
		EndIf
	Next

Return( aRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} fGetTAF1299
Pega o XML de Retorno do evento S-1299
@author  lidio.oliveira
@since   19/11/2022
@version 1
/*/
//-------------------------------------------------------------------
Static Function fGetTAF1299(aArrayFil, cPeriodo)

	Local aArea 		:= GetArea()
	Local aAreaSM0 		:= SM0->(GetArea())
	Local cAliasQRY 	:= "IMPCUO"
	Local cPrefTab		:= "CUO"
	Local cFilIn		:= ""
	Local cFilQry		:= ""
	Local cQuery		:= ""
	Local cTSSKey		:= .F.
	Local nContFil		:= 0
	Local nX			:= 0
	Local cXMLRet		:= ""
	Local aXmls			:= {}
	Local aXmlsLote		:= {}
	Local cUrlTSS		:= fGetUrlTSS()
	Local cIdEntidade 	:= ""
	Local cFilMat		:= "" //Filial Matriz

	For nContFil := 1 To Len(aArrayFil)
		cFilQry += xFilial('CUO', aArrayFil[nContFil]) 
	Next nContFil

	cFilIn := fSqlIn(cFilQry, FwGetTamFilial)

	cQuery	:= "SELECT * "
	cQuery 	+= "FROM " + RetSqlName('CUO') + " CUO "
	cQuery 	+= "WHERE CUO.CUO_FILIAL IN (" + cFilIn + ") AND CUO.CUO_STATUS IN ('3','4') AND "
	cQuery 	+= " CUO.CUO_PERAPU = '" + cPeriodo + "' AND "
	cQuery 	+= "CUO.D_E_L_E_T_ = ' ' "
	cQuery 	+= "ORDER BY CUO.CUO_PROTUL"
	cQuery 	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.T.,.T.)

	While (cAliasQRY)->( !EoF() )
		If !Empty((cAliasQRY)->CUO_ID) .And. !Empty((cAliasQRY)->CUO_VERSAO) .And. (cAliasQRY)->CUO_ATIVO == "1"
			cTSSKey := "S1299" + AllTrim((cAliasQRY)->&(cPrefTab+"_ID")) + AllTrim((cAliasQRY)->&(cPrefTab+"_VERSAO"))
			cFilMat	:= (cAliasQRY)->CUO_FILIAL
			aAdd( aXmls, cTSSKey )
		EndIf
		(cAliasQRY)->( dbSkip() )
	EndDo

	(cAliasQRY)->( dbCloseArea() )

	If !Empty(cFilMat)
		SM0->( dbSeek( cEmpAnt + cFilMat ) )
	EndIf

	If Len(aXmls) > 0
		aAdd(aXmlsLote,aClone(aXmls))
	EndIf

	If !fGetIdEntidade(cUrlTSS, @cIdEntidade)
		Return
	EndIf

	For nX := 1 To Len(aXmlsLote)
		aXmlsRetorno := fGetXMLTSS(aXmlsLote[nX], cUrlTSS, cIdEntidade)
		If len(aXmlsRetorno) > 0
			cXMLRet := aXmlsRetorno[nX, 4]
		EndIf
	Next nX

	RestArea(aArea)
	RestArea(aAreaSM0)

Return cXMLRet

//-------------------------------------------------------------------
/*/
{Protheus.doc} fGetXMLTSS
Rotina que irá realizar a consulta dos eventos no TSS. (Copia de TafGetXMLTSS)
Para retorno do recibo e do XML de envio
@type  Static Function
@author lidio.oliveira
@since 21/11/2022
@version 1.0
@return return, return_type, return_description
/*/
//-------------------------------------------------------------------
Static Function fGetXMLTSS(aLoteXML, cUrlTSS, cIdEntidade)

	Local nX                := 0
	Local nItemLote         := 0
	Local oSocialRetorno    := Nil
	Local oSocial           := Nil
	Local aXmlsRetorno      := {}
	Local cAmbiente         := SuperGetMv('MV_TAFAMBE',.F.,"2")
	Local cBase64           := ""

	oSocial 	   						:= WSTSSWSSOCIAL():New()
	oSocial:_Url 						:= cUrlTSS
	oSocial:oWSENTEXPDADOS:cUSERTOKEN 	:= "TOTVS"
	oSocial:oWSENTEXPDADOS:cID_ENT    	:= cIdEntidade
	oSocial:oWSENTEXPDADOS:cAMBIENTE   	:= cAmbiente

	oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS := WsClassNew("TSSWSSOCIAL_ARRAYOFENTEXPDOC")
	oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS:OWSENTEXPDOC := {}

	For nItemLote := 1 To Len(aLoteXML)
		aAdd(oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS:OWSENTEXPDOC, WsClassNew("TSSWSSOCIAL_ENTEXPDOC"))
		ATAIL(oSocial:oWSENTEXPDADOS:oWSENTEXPDOCS:OWSENTEXPDOC):CID := aLoteXML[nItemLote]
	Next nItemLote

	oSocial:ExportarDocumentos()

	If ValType(oSocial:oWSEXPORTARDOCUMENTOSRESULT:oWSSAIDAEXPDOCS) <> "U"
		oSocialRetorno := oSocial:oWSEXPORTARDOCUMENTOSRESULT:oWSSAIDAEXPDOCS:oWSSAIDAEXPDOC
		For nX := 1 To Len(oSocialRetorno)
			cBase64 := If(oSocialRetorno[nX]:cXMLRET <> Nil,oSocialRetorno[nX]:cXMLRET,oSocialRetorno[nX]:cXMLRET64)
			aAdd(aXmlsRetorno, {oSocialRetorno[nX]:lSucesso, AllTrim(oSocialRetorno[nX]:cID), oSocialRetorno[nX]:cXMLERP, cBase64})
		Next nX
	EndIf
	FreeObj(oSocialRetorno)
	FreeObj(oSocial)
	oSocialRetorno  := Nil
	oSocial         := Nil
	DelClassIntF()

Return aXmlsRetorno


/*/
{Protheus.doc} fGetIdEntidade
Rotina para retornar a Entidade do TSS (Copia de getIdEntidade no GPEM017B)
@type  Static Function
@author  lidio.oliveira
@since   21/11/2022
@version 1.0
@return return, return_type, return_description
/*/
Static Function fGetIdEntidade(cUrl, cIdEntidade)

	Local lTransFil := .F.
	Local cCheckURL := ""
	Local lRet 		:= .T.

	If FindFunction("TAFTransFil")
		lTransFil := TAFTransFil(.F.)
	EndIf

	cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)

	If TAFCTSpd(cCheckURL,,.T.)
		cIdEntidade := TAFRIdEnt(lTransFil)
		//If Empty(cIdEntidade)
			//lRet := .F.
		//EndIf
	Else
		lRet := .F.
	EndIf

Return lRet


/*/
{Protheus.doc} fGetUrlTSS
Rotina para retornar a URL do TSS (Copia de getUrlTSS no GPEM017B)
@type  Static Function
@author  lidio.oliveira
@since   21/11/2022
@version 1.0
@return return, return_type, return_description
/*/
Static Function fGetUrlTSS()

	Local cUrl := ""

	If FindFunction("TafGetUrlTSS")
		cUrl := AllTrim((TafGetUrlTSS()))
	EndIf

	If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
		cUrl += "/TSSWSSOCIAL.apw"
	EndIf

Return cUrl


//---------------------------------------------------------------------
/*/{Protheus.doc} LoadSM0BaseCNPJ
@type			function
@description	Busca as Filias com a mesma Raiz de CNPJ.
@author			lidio.oliveira
@since			21/11/2022
@return			aFilial	-	Filiais com a mesma Raiz de CNPJ da Filial logada
/*/
//---------------------------------------------------------------------
Static Function LoadSM0BaseCNPJ(cFilTAF)

	Local cBaseCNPJ	:=	Left( AllTrim( Posicione( "SM0", 1, cEmpAnt + cFilTAF, "M0_CGC" ) ), 8 )
	Local nI		:=	0
	Local aSM0		:=	FWLoadSM0( .T.,,.T. )
	Local aFilial	:=	{}

	For nI := 1 to Len( aSM0 )
		If cBaseCNPJ == AllTrim( Left( aSM0[nI][SM0_CGC], 8 ) )
			If aSM0[nI][SM0_GRPEMP] == cEmpAnt
				aAdd( aFilial, aSM0[nI][SM0_CODFIL] )
			EndIf
		EndIf
	Next nI

Return( aFilial )


/*/{Protheus.doc} fVerRJ5A()
Função que verifica o relacionamento da tabela RJ5 e utiliza o centro de custo informado em RJ5_COD
A troca é efetuada manualmente pois cada centro de custo pode ter um relacionamento diferente, com
início de validade diferente, o que impossibilita o "Inner Join" na query dos lançamentos
@type function
@author lidio.oliveira
@since 16/12/2022
@version 1.0
@param cRU0Alias	= Alias da tabela temporária principal
@param cSRDRJ5		= Alias da tabela temporária auxiliar
@param cPeriod		= Período para verificação da validade
@param lRJ5Ok		= Flag de cadastro do relacionamento na RJ5
@param aErrosRJ5	= Array com os centros de custo que não foram encontrados
/*/
Static Function fVerRJ5A(cRU0Alias, cSRDRJ5, cPeriod /*lRJ5Ok, aErrosRJ5*/)
	Local aColumns	 := {}
	Local cFilold	 := ""
	Local cCCAnt	 := ""
	Local cCCRJ5	 := ""
	Local cFPASRJ3	 := ""
	Local cCodTerRJ3 := ""
	Local lNovo		 := .F.
	Local lFilT 	 := RJ5->( ColumnPos( "RJ5_FILT" ) ) > 0
	Local aRH5Filt	 := {}
	Local nTamVal	 := TamSX3("RU0_TOTBSC")[1]
	Local nTamDec	 := TamSX3("RU0_TOTBSC")[2]

	Default lRJ5Ok		:= .T.
	Default aErrosRJ5	:= {}

	aAdd( aColumns, { "FILIAL"		,"C",	FwGetTamFilial			,0})
	aAdd( aColumns, { "MATRICULA"	,"C",	TamSX3("RU0_MAT")[1]	,0})
	aAdd( aColumns, { "PERIODO"		,"C",	TamSX3("RU0_PERIOD")[1]	,0})
	aAdd( aColumns, { "SEMANA"		,"C",	TamSX3("RU0_SEMANA")[1]	,0})
	aAdd( aColumns, { "EAGNOC"		,"C",	TamSX3("RU0_EAGNOC")[1]	,0})
	aAdd( aColumns, { "CATEFD"		,"C",	TamSX3("RU0_CATEFD")[1]	,0})
	aAdd( aColumns, { "CONVEA"		,"C",	TamSX3("RU0_CONVEA")[1]	,0})
	aAdd( aColumns, { "LOTACAO"		,"C",	TamSX3("RU0_LOTACA")[1]	,0})
	aAdd( aColumns, { "FPAS"		,"C",	TamSX3("RU0_FPAS")[1]	,0})
	aAdd( aColumns, { "CODTER"		,"C",	TamSX3("RU0_CODTER")[1]	,0})
	aAdd( aColumns, { "FAP"			,"N",	TamSX3("RU0_FAP")[1]	,TamSX3("RU0_FAP")[2]})
	aAdd( aColumns, { "RAT"			,"N",	TamSX3("RU0_RAT")[1]	,TamSX3("RU0_RAT")[2]})
	aAdd( aColumns, { "RATAJUST"	,"N",	TamSX3("RU0_RAJU")[1]	,TamSX3("RU0_RAJU")[2]})
	aAdd( aColumns, { "TOTBSC"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "TOTBCS"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SEST"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SENAT"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SALMAT"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SALFAM"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "VLRPAT"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SALEDU"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "INCRA"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SENAC"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SESC"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SEBRAE"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SENAI"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SESI"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "DPC"			,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "FAER"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SENAR"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SECONC"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "SESCOO"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "GILRAT"		,"N",	nTamVal					,nTamDec})
	aAdd( aColumns, { "INSSTE"		,"N",	nTamVal					,nTamDec})

	//Cria uma tabela temporária auxiliar
	oTmpTabRJ := FWTemporaryTable():New(cSRDRJ5)
	oTmpTabRJ:SetFields( aColumns )
	oTmpTabRJ:AddIndex( "IND", { "FILIAL", "LOTACAO", "CATEFD" } )
	oTmpTabRJ:Create()

	If lFilT
		aRH5Filt := fRJ5Filt()
	Endif
	//Percorre o resultado da query e verifica o relacionamento na RJ5, efetuando troca do RU0_LOTACA por RJ5_COD
	//gravando o resultado na tabela temporária auxiliar
	While (cRU0Alias)->(!Eof())
		lNovo	:= (cSRDRJ5)->( !dbSeek( (cRU0Alias)->FILIAL+(cRU0Alias)->MATRICULA+(cRU0Alias)->PERIODO+(cRU0Alias)->SEMANA+(cRU0Alias)->LOTACAO ) )
		If RecLock(cSRDRJ5, lNovo)
			If lNovo
				(cSRDRJ5)->FILIAL 		:= (cRU0Alias)->FILIAL
				(cSRDRJ5)->MATRICULA 	:= (cRU0Alias)->MATRICULA
				(cSRDRJ5)->PERIODO 		:= (cRU0Alias)->SEMANA
				(cSRDRJ5)->SEMANA 		:= (cRU0Alias)->SEMANA
				(cSRDRJ5)->EAGNOC 		:= (cRU0Alias)->EAGNOC
				(cSRDRJ5)->CATEFD 		:= (cRU0Alias)->CATEFD
				(cSRDRJ5)->CONVEA 		:= (cRU0Alias)->CONVEA

				If cFilold + cCCAnt != (cRU0Alias)->FILIAL + (cRU0Alias)->LOTACAO
					cCCAnt 	:= (cRU0Alias)->LOTACAO
					cFilold	:= (cRU0Alias)->FILIAL
					cCCRJ5 	:= ""
					If !lFilT
						RJ5->( dbSetOrder(4) )//RJ5_FILIAL+RJ5_CC+RJ5_COD+RJ5_INI
						If RJ5->( dbSeek( xFilial("RJ5", (cRU0Alias)->FILIAL) + (cRU0Alias)->LOTACAO) )
							While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRU0Alias)->FILIAL) .And. RJ5->RJ5_CC == (cRU0Alias)->LOTACAO
								If cPeriod >= RJ5->RJ5_INI
									cCCRJ5 := RJ5->RJ5_COD
								EndIf
								RJ5->( dbSkip() )
							EndDo
							If !Empty(cCCRJ5)
								fGetRJ3(xFilial("RJ3", (cRU0Alias)->FILIAL), cCCRJ5, cPeriod, @cFPASRJ3, @cCodTerRJ3)
							EndIf
						EndIf
					Else   //Controle de Lotações com tabelas compartilhadas e campo RJ5_FILT com a Filial do Funcionario
						RJ5->( dbSetOrder(7) )//RJ5_FILIAL+RJ5_CC+RJ5_FILT+RJ5_COD+RJ5_INI
						RJ5->(dbGotop())
						If Len(aRH5Filt) > 0
							If RJ5->( dbSeek( xFilial("RJ5", (cRU0Alias)->FILIAL) + (cRU0Alias)->LOTACAO + (cRU0Alias)->FILIAL)  )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRU0Alias)->FILIAL) .And. RJ5->RJ5_CC == (cRU0Alias)->LOTACAO .And.;
									IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == (cRU0Alias)->FILIAL, .T.)
									If cPeriod >= RJ5->RJ5_INI
										cCCRJ5 := RJ5->RJ5_COD
									EndIf
									RJ5->( dbSkip() )
								EndDo
								If !Empty(cCCRJ5)
									fGetRJ3(xFilial("RJ3", (cRU0Alias)->FILIAL), cCCRJ5, cPeriod, @cFPASRJ3, @cCodTerRJ3)
								EndIf
							EndIf
						Endif
						If Len(aRH5Filt) == 0 .Or. Empty(cCCRJ5)
							If RJ5->( dbSeek( xFilial("RJ5", (cRU0Alias)->FILIAL) + (cRU0Alias)->LOTACAO )  )
								While RJ5->( !EoF() ) .And. RJ5->RJ5_FILIAL == xFilial("RJ5", (cRU0Alias)->FILIAL) .And. RJ5->RJ5_CC == (cRU0Alias)->LOTACAO .And.;
									IF(!Empty(RJ5->RJ5_FILT) , RJ5->RJ5_FILT == (cRU0Alias)->FILIAL, .T.)
									If cPeriod >= RJ5->RJ5_INI
										cCCRJ5 		:= RJ5->RJ5_COD
									EndIf
									RJ5->( dbSkip() )
								EndDo
								If !Empty(cCCRJ5)
									fGetRJ3(xFilial("RJ3", (cRU0Alias)->FILIAL), cCCRJ5, cPeriod, @cFPASRJ3, @cCodTerRJ3)
								EndIf
							EndIf
						Endif
					Endif

					If Empty(cCCRJ5)
						lRJ5Ok 	:= .F.
						If aScan(aErrosRJ5, { |x| x == cCCAnt }) == 0
							aAdd( aErrosRJ5, cCCAnt )
						EndIf
					EndIf
				EndIf

				(cSRDRJ5)->LOTACAO 		:= cCCRJ5
				(cSRDRJ5)->FPAS			:= cFPASRJ3
				(cSRDRJ5)->CODTER		:= cCodTerRJ3
				(cSRDRJ5)->FAP			:= (cRU0Alias)->FAP
				(cSRDRJ5)->RAT			:= (cRU0Alias)->RAT
				(cSRDRJ5)->RATAJUST		:= (cRU0Alias)->RATAJUST
				(cSRDRJ5)->TOTBSC		:= (cRU0Alias)->TOTBSC
				(cSRDRJ5)->TOTBCS		:= (cRU0Alias)->TOTBCS
				(cSRDRJ5)->SEST			:= (cRU0Alias)->SEST
				(cSRDRJ5)->SENAT		:= (cRU0Alias)->SENAT
				(cSRDRJ5)->SALMAT		:= (cRU0Alias)->SALMAT
				(cSRDRJ5)->SALFAM		:= (cRU0Alias)->SALFAM
				(cSRDRJ5)->VLRPAT		:= (cRU0Alias)->VLRPAT
				(cSRDRJ5)->SALEDU		:= (cRU0Alias)->SALEDU
				(cSRDRJ5)->INCRA		:= (cRU0Alias)->INCRA
				(cSRDRJ5)->SENAC		:= (cRU0Alias)->SENAC
				(cSRDRJ5)->SESC			:= (cRU0Alias)->SESC
				(cSRDRJ5)->SEBRAE		:= (cRU0Alias)->SEBRAE
				(cSRDRJ5)->SENAI		:= (cRU0Alias)->SENAI
				(cSRDRJ5)->SESI			:= (cRU0Alias)->SESI
				(cSRDRJ5)->DPC			:= (cRU0Alias)->DPC
				(cSRDRJ5)->FAER			:= (cRU0Alias)->FAER
				(cSRDRJ5)->SENAR		:= (cRU0Alias)->SENAR
				(cSRDRJ5)->SECONC		:= (cRU0Alias)->SECONC
				(cSRDRJ5)->SESCOO		:= (cRU0Alias)->SESCOO
				(cSRDRJ5)->INSSTE		:= (cRU0Alias)->INSSTE
				(cSRDRJ5)->GILRAT		:= (cRU0Alias)->GILRAT
			EndIf

			(cSRDRJ5)->(MsUnlock())
		EndIf
		(cRU0Alias)->(DbSkip())
	EndDo

	(cRU0Alias)->( dbCloseArea() )
	(cSRDRJ5)->( dbGoTop() )

	//Cria uma tabela temporária com o mesmo alias da query da RU0
	oTmpTable := FWTemporaryTable():New(cRU0Alias)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex( "IND", { "FILIAL", "LOTACAO", "CATEFD" } )
	oTmpTable:Create()

	//Percorre a tabela temporária auxiliar gravando o resultado na tabela temporária com o mesmo alias da query da RU0
	While (cSRDRJ5)->(!Eof())
		lNovo	:= (cRU0Alias)->( !dbSeek( (cSRDRJ5)->FILIAL+(cSRDRJ5)->MATRICULA+(cSRDRJ5)->PERIODO+(cSRDRJ5)->SEMANA+(cSRDRJ5)->LOTACAO ) )
		If RecLock(cRU0Alias, lNovo)
			If lNovo
				(cRU0Alias)->FILIAL 		:= (cSRDRJ5)->FILIAL
				(cRU0Alias)->MATRICULA 		:= (cSRDRJ5)->MATRICULA
				(cRU0Alias)->PERIODO 		:= (cSRDRJ5)->SEMANA
				(cRU0Alias)->SEMANA 		:= (cSRDRJ5)->SEMANA
				(cRU0Alias)->EAGNOC 		:= (cSRDRJ5)->EAGNOC
				(cRU0Alias)->CATEFD 		:= (cSRDRJ5)->CATEFD
				(cRU0Alias)->CONVEA 		:= (cSRDRJ5)->CONVEA
				(cRU0Alias)->LOTACAO 		:= (cSRDRJ5)->LOTACAO
				(cRU0Alias)->FPAS			:= (cSRDRJ5)->FPAS
				(cRU0Alias)->CODTER			:= (cSRDRJ5)->CODTER
				(cRU0Alias)->FAP			:= (cSRDRJ5)->FAP
				(cRU0Alias)->RAT			:= (cSRDRJ5)->RAT
				(cRU0Alias)->RATAJUST		:= (cSRDRJ5)->RATAJUST
				(cRU0Alias)->TOTBSC			:= (cSRDRJ5)->TOTBSC
				(cRU0Alias)->TOTBCS			:= (cSRDRJ5)->TOTBCS
				(cRU0Alias)->SEST			:= (cSRDRJ5)->SEST
				(cRU0Alias)->SENAT			:= (cSRDRJ5)->SENAT
				(cRU0Alias)->SALMAT			:= (cSRDRJ5)->SALMAT
				(cRU0Alias)->SALFAM			:= (cSRDRJ5)->SALFAM
				(cRU0Alias)->VLRPAT			:= (cSRDRJ5)->VLRPAT
				(cRU0Alias)->SALEDU			:= (cSRDRJ5)->SALEDU
				(cRU0Alias)->INCRA			:= (cSRDRJ5)->INCRA
				(cRU0Alias)->SENAC			:= (cSRDRJ5)->SENAC
				(cRU0Alias)->SESC			:= (cSRDRJ5)->SESC
				(cRU0Alias)->SEBRAE			:= (cSRDRJ5)->SEBRAE
				(cRU0Alias)->SENAI			:= (cSRDRJ5)->SENAI
				(cRU0Alias)->SESI			:= (cSRDRJ5)->SESI
				(cRU0Alias)->DPC			:= (cSRDRJ5)->DPC
				(cRU0Alias)->FAER			:= (cSRDRJ5)->FAER
				(cRU0Alias)->SENAR			:= (cSRDRJ5)->SENAR
				(cRU0Alias)->SECONC			:= (cSRDRJ5)->SECONC
				(cRU0Alias)->SESCOO			:= (cSRDRJ5)->SESCOO
				(cRU0Alias)->INSSTE			:= (cSRDRJ5)->INSSTE
				(cRU0Alias)->GILRAT			:= (cSRDRJ5)->GILRAT
			EndIf

			(cRU0Alias)->(MsUnlock())
		EndIf
		(cSRDRJ5)->(DbSkip())
	EndDo

	(cRU0Alias)->( dbGoTop() )

Return

/*/{Protheus.doc} fRJ5Filt
Pesquisa as lotações com campo da filial do trabalhador preenchidos
@type      	Static Function
@author lidio.oliveira
@since 16/12/2022
@version	1.0
@return aRJ5Fil
/*/
Static Function fRJ5Filt()

	Local aAreaRJ5	:= RJ5->(GetArea())
	Local aRJ5Fil   := {}

	RJ5->(dbSetOrder(7))
	RJ5->(dbGotop())

		While RJ5->(!Eof()) .AND. RJ5->RJ5_FILIAL == XFILIAL('RJ5')
			If !Empty(RJ5->RJ5_FILT)
				AADD(aRJ5Fil,{RJ5->RJ5_FILIAL, RJ5->RJ5_CC, RJ5->RJ5_FILT, RJ5->RJ5_COD, RJ5->RJ5_INI})
			Endif
			RJ5->(dbSkip())
		EndDo

	RJ5->(dbGotop())

	RestArea(aAreaRJ5)

Return aRJ5Fil


/*/{Protheus.doc} fGetRJ3
Retorna por parâmetros os dados de FPAS e terceiros da lotação
@type      	Static Function
@author lidio.oliveira
@since 16/12/2022
@version	1.0
@return
/*/
Static Function fGetRJ3(cFilRJ3, cCodRJ3, cIniRJ3, cFPASRJ3, cCodTerRJ3)

	Local aArea		:= GetArea()

	DbSelectArea( "RJ3" )
	RJ3->(dbSetOrder(2))
	RJ3->(dbGotop())

	If ( "RJ3" )-> (DbSeek( cFilRJ3 + cCodRJ3 ))
		While RJ3->(!Eof()) .AND. RJ3->RJ3_FILIAL + RJ3->RJ3_COD == cFilRJ3 + cCodRJ3
			If cIniRJ3 >= RJ3->RJ3_INI
				cFPASRJ3 	:= RJ3->RJ3_FPAS
				cCodTerRJ3	:= RJ3->RJ3_TERC
			Endif
			RJ3->(dbSkip())
		EndDo
	EndIf
	RJ3->(dbGotop())

	RestArea( aArea )

Return
