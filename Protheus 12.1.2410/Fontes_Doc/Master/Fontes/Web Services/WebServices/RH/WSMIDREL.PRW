#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"

#DEFINE RECIBO_TRANSMISSAO								01
#DEFINE ESTABELECIMENTO									02
#DEFINE CPFFUNC											03
#DEFINE NOMEFUNC										04
#DEFINE MATRIC											05
#DEFINE CATEG											06
#DEFINE LOTAC											07
#DEFINE EVENTO_ESOCIAL									08
#DEFINE TIPO_BASE_CALCULO								09
#DEFINE FOLHA_BASE_INSS									10
#DEFINE FOLHA_VALOR_INSS								11
#DEFINE FOLHA_VALOR_SALARIO_FAMILIA						12
#DEFINE FOLHA_VALOR_SALARIO_MATERNIDADE					13
#DEFINE FOLHA_BASE_INSS_13_SALARIO						14
#DEFINE FOLHA_VALOR_INSS_13_SALARIO						15
#DEFINE FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO		16
#DEFINE GOVERNO_BASE_INSS								17
#DEFINE GOVERNO_VALOR_INSS								18
#DEFINE GOVERNO_VALOR_SALARIO_FAMILIA					19
#DEFINE GOVERNO_VALOR_SALARIO_MATERNIDADE				20
#DEFINE GOVERNO_BASE_INSS_13_SALARIO					21
#DEFINE GOVERNO_VALOR_INSS_13_SALARIO					22
#DEFINE GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO	23
#DEFINE OBSERVACAO										24
#DEFINE TIPO_FUNCIONARIO								25
#DEFINE GOVERNO_LOCALIZADO								26
#DEFINE GOVERNO_VALOR_INSS_RET							27
#DEFINE GOVERNO_VALOR_INSS_13_SALARIO_RET				28
#DEFINE FOLHA_BASE_PISPASEP								29
#DEFINE GOVERNO_BASE_PISPASEP							30
#DEFINE FOLHA_BASE_PISPASEP_13_SALARIO					31
#DEFINE GOVERNO_BASE_PISPASEP_13_SALARIO				32

#DEFINE HASH_BASE_RECIBO_TRANSMISSAO					01
#DEFINE HASH_BASE_ESTABELECIMENTO						02
#DEFINE HASH_BASE_CPF									03
#DEFINE HASH_BASE_NOME									04
#DEFINE HASH_BASE_MATRICULA								05
#DEFINE HASH_BASE_CATEGORIA								06
#DEFINE HASH_BASE_LOTACAO								07
#DEFINE HASH_BASE_EVENTO_ESOCIAL						08
#DEFINE HASH_BASE_FOLHA_BASE_FGTS						09
#DEFINE HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO			10
#DEFINE HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO			11
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS						12
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO			13
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO			14
#DEFINE HASH_BASE_GOVERNO_LOCALIZADO					15

#DEFINE HASH_DEPOSITO_RECIBO_TRANSMISSAO				01
#DEFINE HASH_DEPOSITO_CPF								02
#DEFINE HASH_DEPOSITO_NOME								03
#DEFINE HASH_DEPOSITO_MATRICULA							04
#DEFINE HASH_DEPOSITO_CATEGORIA							05
#DEFINE HASH_DEPOSITO_EVENTO_ESOCIAL					06
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS				07
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO	08
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO	09
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS				10
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO	11
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO	12
#DEFINE HASH_DEPOSITO_GOVERNO_LOCALIZADO				13

//---------------------------------------------------------------------
/*/{Protheus.doc} GPEreportEsocialBaseConfer
@type			method
@description	Serviço dos Relatórios de Conferência do eSocial.
@author			Allyson Mesashi
@since			13/02/2020
/*/
//---------------------------------------------------------------------
WSRESTFUL GPEreportEsocialBaseConfer DESCRIPTION "Serviço dos Relatórios de Conferência do eSocial" FORMAT APPLICATION_JSON

WSDATA companyId			AS STRING
WSDATA requestId			AS STRING
WSDATA paymentPeriod		AS STRING
WSDATA registrationNumber	AS STRING OPTIONAL
WSDATA lotationCode			AS STRING OPTIONAL
WSDATA eSocialCategory		AS STRING OPTIONAL
WSDATA cpfNumber			AS STRING OPTIONAL
WSDATA eSocialRegistration	AS STRING OPTIONAL
WSDATA tribute				AS INTEGER
WSDATA page					AS INTEGER OPTIONAL
WSDATA pageSize				AS INTEGER OPTIONAL
WSDATA synthetic			AS BOOLEAN OPTIONAL
WSDATA differencesOnly		AS BOOLEAN OPTIONAL
WSDATA level				AS STRING
WSDATA demonstrativeId		AS STRING
WSDATA warningsOnly			AS BOOLEAN OPTIONAL

WSMETHOD POST;
	DESCRIPTION "Método para iniciar o processamento do relatório de conferência do eSocial";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialBaseConfer/?{companyId}&{registrationNumber}&{lotationCode}&{eSocialCategory}&{cpfNumber}&{eSocialRegistration}&{paymentPeriod}&{tribute}";
	PATH "api/rh/esocial/v1/GPEreportEsocialBaseConfer/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET Status;
	DESCRIPTION "Método para consultar o percentual de execução do relatório";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialBaseConfer/Status/?{companyId}&{requestId}";
	PATH "api/rh/esocial/v1/GPEreportEsocialBaseConfer/Status/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET InssValues;
	DESCRIPTION "Método para consultar resultado do relatório de conferência de INSS";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialBaseConfer/InssValues/?{companyId}&{requestId}&{synthetic}&{differencesOnly}&{page}&{pageSize}";
	PATH "api/rh/esocial/v1/GPEreportEsocialBaseConfer/InssValues/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET FgtsValues;
	DESCRIPTION "Método para consultar resultado do relatório de conferência de FGTS";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialBaseConfer/FgtsValues/?{companyId}&{requestId}&{synthetic}&{differencesOnly}&{page}&{pageSize}";
	PATH "api/rh/esocial/v1/GPEreportEsocialBaseConfer/FgtsValues/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET InssRetValues;
	DESCRIPTION "Método para consultar resultado do relatório de conferência de INSS";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialBaseConfer/InssRetValues/?{companyId}&{requestId}&{synthetic}&{differencesOnly}&{page}&{pageSize}";
	PATH "api/rh/esocial/v1/GPEreportEsocialBaseConfer/InssRetValues/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET IRRFRetValues;
	DESCRIPTION "Método para consultar resultado do relatório de conferência de IRRF";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialBaseConfer/IRRFRetValues/?{companyId}&{requestId}&{level}&{demonstrativeId}&{cpfNumber}&{synthetic}&{differencesOnly}&{page}&{pageSize}";
	PATH "api/rh/esocial/v1/GPEreportEsocialBaseConfer/IRRFRetValues/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Método responsável por recepcionar os parâmetros e iniciar o processamento do relatório..
@author			Allyson Mesashi
@since			13/02/2020
@return			Id. da resuisição: requestId (string)

- Inscrição Estabelecimento - registrationNumber (string)
- Código Lotação - lotationCode (string)
- Categoria eSocial - eSocialCategory (string)
- CPF - cpfNumber (string)
- Matrícula eSocial - eSocialRegistration (string)
- Período Folha (obrigatório) - paymentPeriod (string)
- MMAAAA - mensal
- AAAA - anual

/*/
//---------------------------------------------------------------------
WSMETHOD POST WSRESTFUL GPEreportEsocialBaseConfer

Local aAmb			:= {}
Local oParams   	:= JsonObject():New()
Local oResp     	:= JsonObject():New()
Local cTicket   	:= ""
Local cBody	    	:= self:GetContent()
Local lRet      	:= .T.
Local cEmpAntBck	:= cEmpAnt
Local cFilAntBck	:= cFilAnt

Private lGrvTab		:= .F.
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
			fTrGrpGPE( aAmb[1], aAmb[2], "RJE", "GPE" )
		EndIf

		lGrvTab := Len(FWTAMSX3("RU4_FILIAL")) > 0 .And. oParams["tribute"] $ "1*3"

		If oParams["tribute"] $ "1*2" .Or. (lGrvTab .And. oParams["tribute"] == "3")
			//-- Gera o ticket
			cTicket := GeraTicket(cBody, oParams)

			If !Empty(cTicket)
				//-- inicia o processamento antes de retornar
				If StartProc(cTicket)
					oResp["requestId"] := cTicket
					//-- faz a resposta para o frontend
					self:SetResponse( oResp:ToJson() )
				Else
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "Não foi possível iniciar processamento do relatório." ) )
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Não foi possível gerar o ticket de processamento no Protheus." ) )
			EndIf
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Ambiente desatualizado."),,, EncodeUTF8( "Aplique a última atualização da expedição contínua do RH. Para correta execução do relatório as tabelas RU4 e RU5 devem existir no ambiente.")  )
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

If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
	fTrGrpGPE(cEmpAntBck, cFilAntBck)
EndIf

FreeObj( oResp)
oResp := Nil
DelClassIntF()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} checkParams
Validação dos parâmetros recebidos.

@author Allyson Mesashi
@since 13/02/2020
/*/
//-------------------------------------------------------------------
Static Function checkParams( oParams )

Local lRet	:=	.T.

If Empty( oParams["companyId"] )
	lRet := .F.
ElseIf Empty( oParams["paymentPeriod"] )
	lRet := .F.
ElseIf Empty( oParams["tribute"] )
	lRet := .F.
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GeraTicket
@type			function
@description	Cria e armazena ticket para a requisição.
@author			Allyson Mesashi
@since			13/02/2020
@param			cTicket		-	Ticket da requisição
/*/
//---------------------------------------------------------------------
Static Function GeraTicket( cReqJSon, oParams )

Local cTicket	:=	FWuuId( "WSMIDREL" )
Local cServ		:= ""
Local cMetodo	:= ""

If oParams["tribute"] == "1"
	cServ 	:= "GPEreportEsocialBaseConfer/InssRetValues"
	cMetodo	:= "POST"
ElseIf oParams["tribute"] == "3"
	cServ 	:= "GPEreportEsocialBaseConfer/IRRFRetValues"
	cMetodo	:= "POST"
EndIf

If lGrvTab
	fGrvRU4(cTicket, cServ, cMetodo, Date(), StrTran( Time(), ":", "" ), "1", cReqJSon)
Else
	If VarSetUID(cTicket, .T.)
		VarSetXD(cTicket, "cParams", cReqJSon)
		VarSetXD(cTicket, "cStatus", "1")
	EndIf
EndIf

Return( cTicket )

//-------------------------------------------------------------------
/*/{Protheus.doc} StartProc
Inicia o processamento da requisição em um job secundário.

@author Allyson Mesashi
@since 13/02/2020
/*/
//-------------------------------------------------------------------
Static Function StartProc( cTicket )

Local lRet		:=	.T.

StartJob("MidRelThd", GetEnvServer(), .F., cEmpAnt, cFilAnt, "000000", cTicket)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} MidRelThd
Processa a parte assincrona da requisição.

@author Allyson Mesashi
@since 13/02/2020
/*/
//-------------------------------------------------------------------
Function MidRelThd( xEmp, xFil, xUser, cTicket )

Local cParams	:= ""
Local oRequest	:= Nil
Local lRet		:= .F.
Local lTemTab	:= .F.

Private lGrvTab	:= .F.

cFilAnt 	:= xFil

//Prepara ambiente
RPCSetType( 3 )
RpcSetEnv( xEmp, xFil,,,"GPE")
SetsDefault()

lTemTab := Len(FWTAMSX3("RU4_FILIAL")) > 0

oRequest := JsonObject():New()

If lTemTab
	RU4->(DbSetOrder(1))
	If RU4->( dbSeek( xFilial( "RU4" ) + PadR( cTicket, TamSX3( "RU4_ID" )[1] ) ) )
		oRequest:FromJson( RU4->RU4_PARAMS )
		lGrvTab := .T.
	EndIf
EndIf

If !lGrvTab
	VarSetXD(cTicket, "cFinished", "1")
	VarGetXD(cTicket, "cParams", @cParams)

	oRequest:FromJson( cParams )
EndIf

If AllTrim( oRequest["tribute"] ) == "1"
	GetINSSData( oRequest, cTicket )
ElseIf AllTrim( oRequest["tribute"] ) == "2"
	GetFGTSData( oRequest, cTicket )
ElseIf AllTrim( oRequest["tribute"] ) == "3"
	GetIRRFData( oRequest, cTicket )
EndIf

lRet := .T.

oRequest := Nil

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GrvItRes
@type			function
@description	Grava o item do resultado da requisição.
@author			Allyson Mesashi
@since			13/02/2020
@param			cResp		-	Resposta da API
@param			cSeq		-	Sequencial
@param			lDiverg		-	INSS Folha e Governo Divergentes
@param			cTipo		-	1- Sintético 2 - Analítico
@param			cCPF		-	CPF
/*/
//---------------------------------------------------------------------
Static Function GrvItRes( oHashM, cResp, cSeq, lDiverg, cTipo, cCPF, cTicket, cLevel, lRelIRRF, lWarning)

Default lDiverg		:=	.F.
Default cCPF		:= ""
Default cTicket		:= ""
Default cLevel		:= ""
Default lRelIRRF	:= .F.
Default lWarning	:= .F.

If !lRelIRRF
	HMAdd(oHashM, { cResp, cSeq, Iif( lDiverg, "1", "2" ), cTipo, cCPF})
EndIf

If lGrvTab .And. !Empty(cTicket)
	//RU5_FILIAL+RU5_ID+RU5_TIPO+RU5_SEQ+RU5_NIVEL
	RU5->(DbSetOrder(1))
    lNovo := RU5->( !dbSeek( xFilial("RU5") + cTicket + cTipo + cSeq + cLevel ))

    If RU5->( RecLock("RU5", lNovo) )
		RU5->RU5_ID			:= cTicket
		RU5->RU5_RESP		:= cResp
		RU5->RU5_SEQ		:= cSeq
		RU5->RU5_DIVERG		:= Iif( lDiverg, "1", "2" )
		RU5->RU5_TIPO		:= cTipo
		RU5->RU5_CPF		:= cCPF
		RU5->RU5_NIVEL		:= cLevel
		If Len(FWTAMSX3("RU5_AVISO")) > 0
			RU5->RU5_AVISO	:= Iif( lWarning, "1", "2" )
		EndIf
		RU5->(MsUnlock())
	EndIf
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} setPercent
@type			function
@description	Incrementa o percentual de processamento da requisição.
@author			Allyson Mesashi
@since			13/02/2020
/*/
//---------------------------------------------------------------------
Static Function setPercent(cTicket, nItem, nQtdRegs)

Local lRet		:= .F.
Local nPerc     := 0
Local nPercHM   := 0
Local nDif      := 0
Local nPeso     := 50 //-- Significa que o processamento tem duas etapas
Local aAreaRU4  := {}

If lGrvTab
	aAreaRU4 := RU4->(GetArea())
	If RU4->( dbSeek( xFilial( "RU4" ) + PadR( cTicket, TamSX3( "RU4_ID" )[1] ) ) )
		nPercHM := RU4->RU4_PERC
	EndIf
Else
	VarGetXD(cTicket, "nPerc", @nPercHM)
EndIf

nPerc := (Int( ( nItem / nQtdRegs ) * 100 ) * (nPeso/100))
nDif := (nPerc - nPercHM)

If nPerc > 0
	If nPercHM>= nPeso
		nPerc := (nPeso + nPerc)
	Else
		nPerc := (nPercHM + nDif)
	EndIf

	If lGrvTab
		RecLock("RU4", .F.)
			RU4->RU4_PERC := Int( nPerc )
		RU4->(MsUnlock())
	Else
		VarSetXD(cTicket, "nPerc", Int( nPerc ))
	EndIf
EndIf

lRet := .T.
If len(aAreaRU4) > 0
	RestArea(aAreaRU4)
EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetFinish
@type			function
@description	Indica a finalização do processamento da requisição.
@author			Allyson Mesashi
@since			13/02/2020
@param			cTicket	-	Identificador da Requisição
@param			aValues	-	Valores do relatório
/*/
//---------------------------------------------------------------------
Static Function SetFinish( cTicket, aValues, aValuesRET )

Local aAreaRU4	:={}

Default	aValuesRET := {}

If lGrvTab
	aAreaRU4 :=	RU4->( GetArea() )
	RU4->(DbSetOrder(1))
    lNovo := RU4->( !dbSeek( xFilial( "RU4" ) + PadR( cTicket, TamSX3( "RU4_ID" )[1] ) ))

    If RU4->( RecLock("RU4", lNovo) )
		RU4->RU4_STATUS		:= "2"
		RU4->RU4_DTRESP		:= Date()
		RU4->RU4_HRRESP		:= StrTran( Time(), ":", "")
		RU4->(MsUnlock())
	EndIf
Else
	VarSetXD(cTicket, "cFinished", "2")
	VarSetXD(cTicket, "nPerc", 100)
	VarSetAD(cTicket, "aValues", aClone(aValues) )

	If Len(aValuesRET) > 0
		VarSetAD(cTicket, "aValuesRET", aClone(aValuesRET) )
	EndIf
EndIf

If len(aAreaRU4) > 0
	RestArea( aAreaRU4 )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GetINSSData
Escopo: INSS
Prepara os dados filtrados no formato JSON para retornar ao front.

@author Allyson Mesashi
@since 13/02/2020
/*/
//-------------------------------------------------------------------
Static Function GetINSSData( oReq, cTicket )

Local oResponse		:=	Nil
Local oPISPASEP		:=	Nil
Local oArqTrb		:=	HMNew()
Local oArqInss		:=	HMNew()
Local oArqRETInss	:=	HMNew()
Local cStatusGov	:=	""
Local nI			:=	1
Local nINSSOrig		:=	0
Local nINSSGov		:=	0
Local nINSSGovRET	:=	0
Local aINSSSint		:=	{ "", "", "", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
Local aINSSDivSint	:=	{ "", "", "", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
Local aINSSCPF		:=	{}
Local aArqTrb		:=	{}
Local aArqInss		:=	{}
Local aArqRETInss	:=	{}
Local aArea			:=	GetArea()
Local lDiverg		:=	.F.
Local lDivergTot	:=	.F.

Local nFuncDiverg   := 0
Local nFuncTotal    := 0
Local cCPFTrab		:= ""
Local nPos			:= 0

//Filtra os dados do INSS e gera o hash
FilINSSData( oReq, @oArqTrb, cTicket )

//Grava o conteúdo dos hashs em arrays
HMList(oArqTrb, @aArqTrb)

//Monta o retorno para a API de INSS
For nI := 1 to Len( aArqTrb )
	oResponse 	:= JsonObject():New()
	oPISPASEP	:= JsonObject():New()
	cCPFTrab	:= ""
	nPos 		:= 0

	If !aArqTrb[nI,2,1,GOVERNO_LOCALIZADO]
		cStatusGov := "Nao Transmitido/Nao Localizado"
	Else
		cStatusGov := ""
	EndIf

	lDiverg := .F.

	nINSSOrig	:=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS] + aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
	nINSSGov	:=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS] + aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO]
	nINSSGovRet	:=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_RET] + aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO_RET]

	If nINSSOrig <> nINSSGov .or.;
		aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] .or.;
		aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] .or.;
		aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .Or.;
		aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP] <> aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP] .Or.;
		aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP_13_SALARIO] .Or.;
		nINSSOrig <> nINSSGovRet

        aINSSDivSint[7]	    +=	aArqTrb[nI,2,1,FOLHA_BASE_INSS]
        aINSSDivSint[8]	    +=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS]
        aINSSDivSint[9]	    +=	aArqTrb[nI,2,1,FOLHA_BASE_INSS_13_SALARIO]
        aINSSDivSint[10]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
        aINSSDivSint[11]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA]
        aINSSDivSint[12]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE]
        aINSSDivSint[13]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
		aINSSDivSint[23]	+=	aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP]
		aINSSDivSint[25]	+=	aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP_13_SALARIO]

        If Empty( cStatusGov )
            aINSSDivSint[14]	+=	aArqTrb[nI,2,1,GOVERNO_BASE_INSS]
            aINSSDivSint[15]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS]
            aINSSDivSint[16]	+=	aArqTrb[nI,2,1,GOVERNO_BASE_INSS_13_SALARIO]
            aINSSDivSint[17]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO]
            aINSSDivSint[18]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA]
            aINSSDivSint[19]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE]
            aINSSDivSint[20]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
			aINSSDivSint[21]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_RET]
			aINSSDivSint[22]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO_RET]
			aINSSDivSint[24]	+=	aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP]
			aINSSDivSint[26]	+=	aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP_13_SALARIO]
	    EndIf

		lDiverg		:=	.T.
        lDivergTot	:=	.T.

        nFuncDiverg++
	EndIf

	//API INSSVALUES
    oResponse["cpfNumber"]					:=	aArqTrb[nI,2,1,CPFFUNC]
    oResponse["name"]						:=	aArqTrb[nI,2,1,NOMEFUNC]
    oResponse["esocialRegistration"]		:=	aArqTrb[nI,2,1,MATRIC]
    oResponse["esocialCategory"]			:=	aArqTrb[nI,2,1,CATEG]
	oResponse["lotationCode"]				:=	aArqTrb[nI,2,1,LOTAC]
	oResponse["branchId"]					:=	aArqTrb[nI,2,1,ESTABELECIMENTO]

	oResponse["inssBasis"]					:=	aArqTrb[nI,2,1,FOLHA_BASE_INSS]
	oResponse["inssValue"]					:=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS]
	oResponse["inss13Basis"]				:=	aArqTrb[nI,2,1,FOLHA_BASE_INSS_13_SALARIO]
	oResponse["inss13Value"]				:=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
	oResponse["familySalaryValue"]			:=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA]
	oResponse["maternitySalaryValue"]		:=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE]
	oResponse["maternitySalary13Value"]		:=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
	oResponse["pisPasepBasis"]				:=  0
	oResponse["pisPasep13Basis"]			:=  0
	oResponse["pisPasepRetBasis"]			:=  0
	oResponse["pisPasep13RetBasis"]			:=  0

	If Empty( cStatusGov )
		oResponse["inssRetBasis"]				:=	aArqTrb[nI,2,1,GOVERNO_BASE_INSS]
		oResponse["inssRetValue"]				:=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS]
		oResponse["inss13RetBasis"]				:=	aArqTrb[nI,2,1,GOVERNO_BASE_INSS_13_SALARIO]
		oResponse["inss13RetValue"]				:=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO]
		oResponse["familySalaryRetValue"]		:=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA]
		oResponse["maternitySalaryRetValue"]	:=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE]
		oResponse["maternitySalary13RetValue"]	:=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
	Else
		oResponse["inssRetBasis"]				:=	0
		oResponse["inssRetValue"]				:=	0
		oResponse["inss13RetBasis"]				:=	0
		oResponse["inss13RetValue"]				:=	0
		oResponse["familySalaryRetValue"]		:=	0
		oResponse["maternitySalaryRetValue"]	:=	0
		oResponse["maternitySalary13RetValue"]	:=	0
	EndIf

	aINSSSint[7]	+=	aArqTrb[nI,2,1,FOLHA_BASE_INSS]
	aINSSSint[8]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS]
	aINSSSint[9]	+=	aArqTrb[nI,2,1,FOLHA_BASE_INSS_13_SALARIO]
	aINSSSint[10]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
	aINSSSint[11]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA]
	aINSSSint[12]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE]
	aINSSSint[13]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
	aINSSSint[23]	+=	aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP]
	aINSSSint[25]	+=	aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP_13_SALARIO]

	If Empty( cStatusGov )
		aINSSSint[14]	+=	aArqTrb[nI,2,1,GOVERNO_BASE_INSS]
		aINSSSint[15]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS]
		aINSSSint[16]	+=	aArqTrb[nI,2,1,GOVERNO_BASE_INSS_13_SALARIO]
		aINSSSint[17]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO]
		aINSSSint[18]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA]
		aINSSSint[19]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE]
		aINSSSint[20]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
		aINSSSint[21]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_RET]
		aINSSSint[22]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO_RET]
		aINSSSint[24]	+=	aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP]
		aINSSSint[26]	+=	aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP_13_SALARIO]
	EndIf

	//Verifica se o CPF já foi incluído no Array
	If Len(aINSSCPF) > 0
		cCPFTrab	:= aArqTrb[nI,2,1,CPFFUNC]
		nPos 		:= aScan( aINSSCPF, {|x| x[1] == cCPFTrab } )
	EndIf

	//Se for o mesmo CPF soma no registro, caso contrário adiciona no array
	If nPos > 0
		aINSSCPF[nPos,3] += aArqTrb[nI,2,1,FOLHA_VALOR_INSS]//inssGrossValue
		aINSSCPF[nPos,4] += aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]//inss13GrossValue
		aINSSCPF[nPos,5] += aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA]//familySalaryValue
		aINSSCPF[nPos,6] += aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE]//maternitySalaryValue
		aINSSCPF[nPos,7] += aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]//maternitySalary13Value
		aINSSCPF[nPos,8] += aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_RET]//inssRetGrossValue
		aINSSCPF[nPos,9] += aArqTrb[nI,2,1,GOVERNO_VALOR_INSS]//inssRetDescGrossValue
		aINSSCPF[nPos,10] += aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO_RET]//inss13RetGrossValue
		aINSSCPF[nPos,11] += aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO]//inss13DescGrossValue
		aINSSCPF[nPos,12] += aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA]//familySalaryRetValue
		aINSSCPF[nPos,13] += aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE]//maternitySalaryRetValue
		aINSSCPF[nPos,14] += aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]//maternitySalary13RetValue
		aINSSCPF[nPos,15] += aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP]//pisPasepBasis
		aINSSCPF[nPos,16] += aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP]//pisPasepRetBasis
		aINSSCPF[nPos,17] += aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP_13_SALARIO]//pisPasep13Basis
		aINSSCPF[nPos,18] += aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP_13_SALARIO]//pisPasep13RetBasis
	Else
		aAdd( aINSSCPF, {aArqTrb[nI,2,1,CPFFUNC],; //1 - cpfNumber
		 aArqTrb[nI,2,1,NOMEFUNC],; //2 - name
		 aArqTrb[nI,2,1,FOLHA_VALOR_INSS],; // 3- inssGrossValue
		 aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO],; //4 - inss13GrossValue
		 aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA],; //5 - familySalaryValue
		 aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE],; //6 - maternitySalaryValue
		 aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO],; //7 - maternitySalary13Value
		 aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_RET],; //8 - inssRetGrossValue
		 aArqTrb[nI,2,1,GOVERNO_VALOR_INSS],; //9 - inssRetDescGrossValue
		 aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO_RET],; //10 -inss13RetGrossValue
		 aArqTrb[nI,2,1,GOVERNO_VALOR_INSS_13_SALARIO],; //11 - inss13DescGrossValue
		 aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA],; //12 - familySalaryRetValue
		 aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE],; //13 - maternitySalaryRetValue
		 aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO],; //14 - maternitySalary13RetValue
		 aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP],; //15 - pisPasepBasis
		 aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP],; //16 - pisPasepRetBasis
		 aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP_13_SALARIO],; //17 - pisPasep13Basis
		 aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP_13_SALARIO]}) //18 - pisPasep13RetBasis
	EndIf

	//Grava item
	GrvItRes( @oArqInss, oResponse:ToJson(), StrZero( nI, 6 ), lDiverg, "2", aArqTrb[nI,2,1,CPFFUNC], If(lGrvTab, cTicket, ""))

	//Grava novamente desta vez zerando a lotação e preenchendo os dados do PIS
    oPISPASEP["cpfNumber"]					:=	aArqTrb[nI,2,1,CPFFUNC]
    oPISPASEP["name"]						:=	aArqTrb[nI,2,1,NOMEFUNC]
    oPISPASEP["esocialRegistration"]		:=	aArqTrb[nI,2,1,MATRIC]
    oPISPASEP["esocialCategory"]			:=	aArqTrb[nI,2,1,CATEG]
	oPISPASEP["lotationCode"]				:=	""
	oPISPASEP["branchId"]					:=	aArqTrb[nI,2,1,ESTABELECIMENTO]

	oPISPASEP["inssBasis"]					:=	0
	oPISPASEP["inssValue"]					:=	0
	oPISPASEP["inss13Basis"]				:=	0
	oPISPASEP["inss13Value"]				:=	0
	oPISPASEP["familySalaryValue"]			:=	0
	oPISPASEP["maternitySalaryValue"]		:=	0
	oPISPASEP["maternitySalary13Value"]		:=	0
	oPISPASEP["pisPasepBasis"]				:=  aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP]
	oPISPASEP["pisPasep13Basis"]			:=  aArqTrb[nI,2,1,FOLHA_BASE_PISPASEP_13_SALARIO]
	oPISPASEP["inssRetBasis"]				:=	0
	oPISPASEP["inssRetValue"]				:=	0
	oPISPASEP["inss13RetBasis"]				:=	0
	oPISPASEP["inss13RetValue"]				:=	0
	oPISPASEP["familySalaryRetValue"]		:=	0
	oPISPASEP["maternitySalaryRetValue"]	:=	0
	oPISPASEP["maternitySalary13RetValue"]	:=	0
	If Empty( cStatusGov )
		oPISPASEP["pisPasepRetBasis"]			:=  aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP]
		oPISPASEP["pisPasep13RetBasis"]			:=  aArqTrb[nI,2,1,GOVERNO_BASE_PISPASEP_13_SALARIO]
	Else
		oPISPASEP["pisPasepRetBasis"]			:=  0
		oPISPASEP["pisPasep13RetBasis"]			:=  0
	EndIf
	GrvItRes( @oArqInss, oPISPASEP:ToJson(), "9" + StrZero( nI, 5 ), lDiverg, "2", aArqTrb[nI,2,1,CPFFUNC], If(lGrvTab, cTicket, ""))

	SetPercent( cTicket, nI, Len( aArqTrb ) )

    nFuncTotal++

Next nI

//Se não encontrou os dados
If Len( aArqTrb ) == 0
	SetPercent( cTicket, 100, 100 )
Else
	//Grava a totalização por CPF para a API INSSRETVALUES
	GrvINSSCPF( aINSSCPF, @oArqRETInss, cTicket)

	//Grava a parte sintética
    GrvINSSSint( aINSSSint, nFuncTotal, .F.,  nI, @oArqInss, @oArqRETInss, cTicket)
    GrvINSSSint( aINSSDivSint, nFuncDiverg, .T., ++nI, @oArqInss, @oArqRETInss, cTicket)
EndIf

//Grava o conteúdo dos hashs em arrays
HMList(oArqInss, @aArqInss)
HMList(oArqRETInss, @aArqRETInss)

fOrdena(aArqInss)
fOrdena(aArqRETInss)

SetFinish( cTicket, aArqInss, aArqRETInss )

HMClean(oArqTrb)
HMClean(oArqInss)
HMClean(oArqRETInss)

RestArea( aArea )

Return()

/*/{Protheus.doc} fOrdena
Ordena o array em ordem de sequencia
@type  static
@author Allyson Mesashi
@since 13/02/2020
@param			aValues	-	Valores do relatório
@version 1
/*/
Static Function fOrdena(aValues)

Local aAux	:= {}
Local nCont := ""

For nCont := 1 To Len(aValues)
	aAdd( aAux, aClone(aValues[nCont, 2, 1]) )
Next nCont
aSort( aAux ,,, { |x, y| x[2] < y[2] } )
aValues := aClone(aAux)

Return

/*/{Protheus.doc} R123InitArray
Inicializa o array com as devidas posi??es em branco/zerada
@type  static
@author Allyson Mesashi
@since 13/02/2020
@version 1
/*/
Static Function R123InitArray()

Local aInit := Array(33)

aInit[CPFFUNC]										:= ""
aInit[NOMEFUNC]										:= ""
aInit[MATRIC]										:= ""
aInit[LOTAC]										:= ""
aInit[ESTABELECIMENTO]								:= ""
aInit[CATEG]										:= ""
aInit[RECIBO_TRANSMISSAO]							:= ""
aInit[TIPO_BASE_CALCULO]							:= ""
aInit[OBSERVACAO]									:= ""
aInit[TIPO_FUNCIONARIO]								:= ""
aInit[EVENTO_ESOCIAL]								:= ""
aInit[FOLHA_BASE_INSS]								:= 0
aInit[FOLHA_VALOR_INSS]								:= 0
aInit[FOLHA_VALOR_SALARIO_FAMILIA]					:= 0
aInit[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= 0
aInit[FOLHA_BASE_INSS_13_SALARIO]					:= 0
aInit[FOLHA_VALOR_INSS_13_SALARIO]					:= 0
aInit[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= 0
aInit[GOVERNO_BASE_INSS]							:= 0
aInit[GOVERNO_VALOR_INSS]							:= 0
aInit[GOVERNO_VALOR_SALARIO_FAMILIA]				:= 0
aInit[GOVERNO_VALOR_SALARIO_MATERNIDADE]			:= 0
aInit[GOVERNO_BASE_INSS_13_SALARIO]					:= 0
aInit[GOVERNO_VALOR_INSS_13_SALARIO]				:= 0
aInit[GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= 0
aInit[GOVERNO_LOCALIZADO]							:= .F.
aInit[GOVERNO_VALOR_INSS_RET]						:= 0
aInit[GOVERNO_VALOR_INSS_13_SALARIO_RET]			:= 0
aInit[FOLHA_BASE_PISPASEP]							:= 0
aInit[GOVERNO_BASE_PISPASEP]						:= 0
aInit[FOLHA_BASE_PISPASEP_13_SALARIO]				:= 0
aInit[GOVERNO_BASE_PISPASEP_13_SALARIO]				:= 0

Return(aInit)

//---------------------------------------------------------------------
/*/{Protheus.doc} filINSSData
@type			function
@description	Filtra os dados de acordo com os parametros recebidos e salva em um hash.
@author			Allyson Mesashi
@since			13/02/2020
/*/
//---------------------------------------------------------------------
Static Function filINSSData(oReq, oArqTrb, cTicket)

Local cNextAlias    := GetNextAlias()
Local cNatureza		:= ""
Local cTipo			:= ""
Local nQtdRegs		:= 0
Local cQry          := ""
Local cIncidPS		:= ""
Local cTipoBC		:= ""
Local nBasINSS		:= 0
Local nVlINSS		:= 0
Local nVlINSSRET	:= 0
Local nSalFam		:= 0
Local nSalMat		:= 0
Local nVlPIS		:= 0
Local nVlPISRet		:= 0
Local nVlPIS13		:= 0
Local nVlPIS13Ret	:= 0
Local nBasINSS13	:= 0
Local nVlINSS13		:= 0
Local nVlINSS13RET	:= 0
Local nSalMat13		:= 0
Local nRegistro		:= 0
Local lAdd			:= .F.
Local nItem         := 0
Local lIncAnd		:= .F.

Local aPos			:= {}
Local aLotacao      := {}
Local aCategoria    := {}
Local aEstabe       := {}
Local aCPFs		    := {}
Local aMats         := {}

Local cFilSel	:=	""
Local nI		:=	0
Local aFilial	:=	{}
Local lCpoPIS	:= RJO->(ColumnPos("RJO_INCPIS")) > 0
Local cIncPIS	:= ""

aFilial := LoadSM0BaseCNPJ()

For nI := 1 to Len( aFilial )
	If !Empty( cFilSel )
		cFilSel += ","
	EndIf

	cFilSel += "'" + aFilial[nI] + "'"
Next nI

//-- Monta a query na RJO para filtrar os dados
If Select(cNextAlias) > 0
    (cNextAlias)->( dbCloseArea() )
EndIf

cPeriodo    := oReq["paymentPeriod"]
aCategoria  := oReq["eSocialCategory"]
aLotacao    := oReq["lotationCode"]
aEstabe     := oReq["registrationNumber"]
aCPFs		:= oReq["cpfNumber"]
aMats 		:= oReq["eSocialRegistration"]

cQry := "SELECT "
cQry += "   RJO.RJO_FILIAL, "
cQry += "    RJO.RJO_INDAPU INDAPU,  "
cQry += "    RJO.RJO_PERAPU, "
cQry += "    RJO.RJO_INDDEC IND_DEC, "
cQry += "    RJO.RJO_CPF CPF, "
cQry += "    RJO.RJO_NOME NOME, "
cQry += "    RJO.RJO_MATRIC MATRICULA, "
cQry += "    RJO.RJO_CATEG CATEGORIA, "
cQry += "    RJO.RJO_TPINSC, "
cQry += "    RJO.RJO_NRINSC ESTAB, "
cQry += "    RJO.RJO_CODLOT LOTACAO, "
cQry += "    RJO.RJO_EVENTO, "
cQry += "    RJO.RJO_NATRUB NATUREZA, "
cQry += "    RJO.RJO_TPRUBR TP_RUBRICA, "
cQry += "    RJO.RJO_INCFGT, "
cQry += "    RJO.RJO_INCCP INC_CP, "
If lCpoPIS
	cQry += "    RJO.RJO_INCPIS INC_PIS, "
EndIf
cQry += "    RJO.RJO_TPVLR TIPO_BASE, "
cQry += "    RJO.RJO_TPCR TPCR, "
cQry += "    RJO.RJO_VALOR VALOR  "
cQry += "FROM  "+RetSqlName("RJO")+" RJO  "
cQry += "WHERE RJO.D_E_L_E_T_ = ' ' "
cQry += "    AND RJO_FILIAL IN ( " + cFilSel + " ) "
cQry += "    AND RJO_PERAPU = '"+oReq["paymentPeriod"]+"'  "

If !Empty(aCategoria) .Or. !Empty(aLotacao) .OR. !Empty(aEstabe) .Or. !Empty(aCPFs) .OR. !Empty(aMats)

	cQry += " AND ("

	If !Empty(aCategoria)
		cQry += " RJO_CATEG IN "+FormatIn(ArrayToStr(aCategoria),";")+"  "
		lIncAnd := .T.
	EndIf

	If !Empty(aLotacao)
		If lIncAnd
			cQry += " AND "
		EndIf
		cQry += " RJO_CODLOT IN "+FormatIn(ArrayToStr(aLotacao),";")+" "
		lIncAnd := .T.
	EndIf

	If !Empty(aEstabe)
		If lIncAnd
			cQry += " AND "
		EndIf
		cQry += " RJO_NRINSC IN "+FormatIn(ArrayToStr(aEstabe),";")+" "
		lIncAnd := .T.
	EndIf

	If !Empty(aCPFs)
		If lIncAnd
			cQry += " AND "
		EndIf
		cQry += " RJO_CPF IN " + FormatIn(ArrayToStr(aCPFs),";")+" "
		lIncAnd := .T.
	EndIf

	If !Empty(aMats)
		If lIncAnd
			cQry += " AND "
		EndIf
		cQry += " RJO_MATRIC IN " + FormatIn(ArrayToStr(aMats),";") + " "
		lIncAnd := .T.
	EndIf

	cQry += " OR RJO_TPVLR = '99' )"
EndIf

TCQUERY cQry NEW ALIAS (cNextAlias)

If (cNextAlias)->( !Eof() )
	( cNextAlias )->( DBEval( { || nQtdRegs ++ } ) )
EndIf

(cNextAlias)->( dbGoTop() )

While (cNextAlias)->( !Eof() )

    nRegistro++

    cEvento := (cNextAlias)->RJO_EVENTO

    If cEvento $ "S-1200/S-2299/S-2399"
		cNatureza	:= AllTrim((cNextAlias)->NATUREZA)
		cTipo		:= AllTrim((cNextAlias)->TP_RUBRICA)
		cIncidPS	:= AllTrim((cNextAlias)->INC_CP)
		If lCpoPIS
			cIncPIS		:= AllTrim((cNextAlias)->INC_PIS)
		EndIf

		If (cNextAlias)->INDAPU == "1"
			If cNatureza $ "9201*9205*9989" .and. cIncidPS == "31"
				nVlINSS := If(cTipo $ "2*4", (cNextAlias)->VALOR, (cNextAlias)->VALOR * -1 )
				lAdd := .T.
			ElseIf cNatureza == "9201" .and. cIncidPS == "32"
				nVlINSS13 += ( cNextAlias )->VALOR
				lAdd := .T.
			ElseIf cIncidPS == "11"
				nBasINSS := If(cTipo $ "1*3", (cNextAlias)->VALOR, (cNextAlias)->VALOR * -1 )
				lAdd := .T.
			ElseIf cNatureza == "1409" .And. cIncidPS == "51"
				nSalFam := (cNextAlias)->VALOR
				lAdd := .T.
			ElseIf cNatureza == "4050" .And. cIncidPS == "21"
				nSalMat := (cNextAlias)->VALOR
				lAdd := .T.
			ElseIf cNatureza == "4051" .and. cIncidPS == "22"
				nSalMat13 += ( cNextAlias )->VALOR
				lAdd := .T.
			EndIf
			If cIncPIS == '11'
				nVlPIS := Iif(cTipo $ "1*3", (cNextAlias)->VALOR, (cNextAlias)->VALOR * -1 )
				lAdd := .T.
			ElseIf cIncPIS == '12'
				nVlPIS13 := Iif(cTipo $ "1*3", (cNextAlias)->VALOR, (cNextAlias)->VALOR * -1 )
				lAdd := .T.
			EndIf
		ElseIf (cNextAlias)->INDAPU == "2"
			If cNatureza == "9201" .And. cIncidPS == "32"
				nVlINSS13 := (cNextAlias)->VALOR
				lAdd := .T.
			ElseIf cNatureza == "9901" .And. cTipo == "3"
				nBasINSS13 := (cNextAlias)->VALOR
				lAdd := .T.
			ElseIf cNatureza == "4051" .And. cIncidPS == "22"
				nSalMat13 := (cNextAlias)->VALOR
				lAdd := .T.
			EndIf
			If cIncPIS == '12'
				nVlPIS13 := Iif(cTipo $ "1*3", (cNextAlias)->VALOR, (cNextAlias)->VALOR * -1 )
				lAdd := .T.
			EndIf
		EndIf
    ElseIf cEvento == "S-5001"
		cTipo	:= AllTrim((cNextAlias)->TIPO_BASE)

		If (cNextAlias)->IND_DEC == "0"
			If cTipo $ "11|12|13|14|15|16|17|18|19|91"
				If !( cTipo $ cTipoBC )
					cTipoBC += Iif( Empty( cTipoBC ), cTipo, "," + cTipo )
				EndIf
				nBasINSS += (cNextAlias)->VALOR
				lAdd := .T.
			ElseIf cTipo == "21"
				nVlINSS += (cNextAlias)->VALOR
				lAdd := .T.
			ElseIf cTipo == "31"
				nSalFam += (cNextAlias)->VALOR
				lAdd := .T.
			ElseIf cTipo == "32"
				nSalMat += (cNextAlias)->VALOR
				lAdd := .T.
			EndIf
			If cTipo == "11" .And. AllTrim((cNextAlias)->TPCR) == "830102"
				nVlPISRet := (cNextAlias)->VALOR
				lAdd := .T.
			EndIf
		ElseIf (cNextAlias)->IND_DEC == "1"
			If cTipo $ "11|12|13|14|15|16|17|18|19|91"
				If !( cTipo $ cTipoBC )
					cTipoBC += Iif( Empty( cTipoBC ), cTipo, "," + cTipo )
				EndIf
				nBasINSS13 += (cNextAlias)->VALOR
				lAdd := .T.
			ElseIf cTipo == "21"
				nVlINSS13 += (cNextAlias)->VALOR
				lAdd := .T.
			ElseIf cTipo == "32"
				nSalMat13 += (cNextAlias)->VALOR
				lAdd := .T.
			EndIf
			If cTipo == "11" .And. AllTrim((cNextAlias)->TPCR) == "830102"
				nVlPIS13Ret := (cNextAlias)->VALOR
				lAdd := .T.
			EndIf
		ElseIf Empty((cNextAlias)->IND_DEC)
			//Obtem valor de INSS da DCTFWEB
			If cTipo == "99" .And. ALLTRIM((cNextAlias)->TPCR) == "108201"
				nVlINSSRET += (cNextAlias)->VALOR
				lAdd := .F.
			//Obtem valor de INSS 13 da DCTFWEB
			ElseIf cTipo == "99" .And. ALLTRIM((cNextAlias)->TPCR) == "108221"
				nVlINSS13RET += (cNextAlias)->VALOR
				lAdd := .F.
			EndIf
		EndIf
    Else
		lAdd := .F.
	EndIf

    If lAdd

		If HMGet( oArqTrb, AllTrim((cNextAlias)->ESTAB) + AllTrim((cNextAlias)->CPF) + AllTrim((cNextAlias)->MATRICULA) + AllTrim((cNextAlias)->CATEGORIA) + AllTrim((cNextAlias)->LOTACAO), @aPos )

            aPos[1, CPFFUNC]			:=	AllTrim((cNextAlias)->CPF)
            If !Empty(AllTrim((cNextAlias)->NOME))
				aPos[1, NOMEFUNC]			:=	AllTrim((cNextAlias)->NOME)
			EndIf
            aPos[1, MATRIC]				:=	AllTrim((cNextAlias)->MATRICULA)
            aPos[1, LOTAC]				:=	AllTrim((cNextAlias)->LOTACAO)
            aPos[1, ESTABELECIMENTO]	:=	AllTrim((cNextAlias)->ESTAB)
            aPos[1, CATEG]				:=	AllTrim((cNextAlias)->CATEGORIA)
            aPos[1, EVENTO_ESOCIAL]		:=	cEvento

            If cEvento $ "S-1200/S-2299/S-2399"
				aPos[1, FOLHA_BASE_INSS]								+=	nBasINSS
				aPos[1, FOLHA_VALOR_INSS]								+=	nVlINSS
				aPos[1, FOLHA_VALOR_SALARIO_FAMILIA]					+=	nSalFam
				aPos[1, FOLHA_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
				aPos[1, FOLHA_BASE_INSS_13_SALARIO]						+=	nBasINSS13
				aPos[1, FOLHA_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
				aPos[1, FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		+=	nSalMat13
				aPos[1, FOLHA_BASE_PISPASEP]							+=	nVlPIS
				aPos[1, FOLHA_BASE_PISPASEP_13_SALARIO]					+=	nVlPIS13
            ElseIf cEvento == "S-5001"
				aPos[1, GOVERNO_BASE_INSS]								+=	nBasINSS
				aPos[1, GOVERNO_VALOR_INSS]								+=	nVlINSS
				aPos[1, GOVERNO_VALOR_SALARIO_FAMILIA]					+=	nSalFam
				aPos[1, GOVERNO_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
				aPos[1, GOVERNO_BASE_INSS_13_SALARIO]					+=	nBasINSS13
				aPos[1, GOVERNO_VALOR_INSS_13_SALARIO]					+=	nVlINSS13
				aPos[1, GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13
				aPos[1, GOVERNO_LOCALIZADO]								:=	.T.
				aPos[1, GOVERNO_VALOR_INSS_RET]							+=	nVlINSSRET
				aPos[1, GOVERNO_BASE_PISPASEP]							+=	nVlPISRet
				aPos[1, GOVERNO_BASE_PISPASEP_13_SALARIO]				+=	nVlPIS13Ret
            EndIf

            aPos[1, TIPO_BASE_CALCULO]	:= ""
            aPos[1, OBSERVACAO]			:= ""
            aPos[1, TIPO_FUNCIONARIO]	:= ""

            HMSet( oArqTrb, aPos[1, ESTABELECIMENTO] + aPos[1, CPFFUNC] + aPos[1, MATRIC] + aPos[1, CATEG] + aPos[1, LOTAC], aPos )

        Else

            aPos := R123InitArray()

            aPos[CPFFUNC]			:=	AllTrim((cNextAlias)->CPF)
            aPos[NOMEFUNC]			:=	AllTrim((cNextAlias)->NOME)
            aPos[MATRIC]			:=	AllTrim((cNextAlias)->MATRICULA)
            aPos[LOTAC]				:=	AllTrim((cNextAlias)->LOTACAO)
            aPos[ESTABELECIMENTO]	:=	AllTrim((cNextAlias)->ESTAB)
            aPos[CATEG]				:=	AllTrim((cNextAlias)->CATEGORIA)
            aPos[EVENTO_ESOCIAL]	:=	cEvento

           If cEvento $ "S-1200/S-2299/S-2399"
				aPos[FOLHA_BASE_INSS]								:= nBasINSS
				aPos[FOLHA_VALOR_INSS]								:= nVlINSS
				aPos[FOLHA_VALOR_SALARIO_FAMILIA]					:= nSalFam
				aPos[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= nSalMat
				aPos[FOLHA_BASE_INSS_13_SALARIO]					:= nBasINSS13
				aPos[FOLHA_VALOR_INSS_13_SALARIO]					:= nVlINSS13
				aPos[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= nSalMat13
				aPos[FOLHA_BASE_PISPASEP]							:= nVlPIS
				aPos[FOLHA_BASE_PISPASEP_13_SALARIO]				:= nVlPIS13
            ElseIf cEvento == "S-5001"
				aPos[GOVERNO_BASE_INSS]								:= nBasINSS
				aPos[GOVERNO_VALOR_INSS]							:= nVlINSS
				aPos[GOVERNO_VALOR_SALARIO_FAMILIA]					:= nSalFam
				aPos[GOVERNO_VALOR_SALARIO_MATERNIDADE]				:= nSalMat
				aPos[GOVERNO_BASE_INSS_13_SALARIO]					:= nBasINSS13
				aPos[GOVERNO_VALOR_INSS_13_SALARIO]					:= nVlINSS13
				aPos[GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= nSalMat13
				aPos[GOVERNO_LOCALIZADO]							:= .T.
				aPos[GOVERNO_VALOR_INSS_RET]				    	:= nVlINSSRET
				aPos[GOVERNO_VALOR_INSS_13_SALARIO_RET]				:= nVlINSS13RET
				aPos[GOVERNO_BASE_PISPASEP]							:= nVlPISRet
				aPos[GOVERNO_BASE_PISPASEP_13_SALARIO]				:= nVlPIS13Ret
            EndIf

            aPos[TIPO_BASE_CALCULO]		:= ""
            aPos[OBSERVACAO]			:= ""
            aPos[TIPO_FUNCIONARIO]		:= ""

            HMAdd(oArqTrb, aPos, ESTABELECIMENTO, 3, CPFFUNC, 3, MATRIC, 3, CATEG, 3, LOTAC, 3)

        EndIf

        nBasINSS		:= 0
        nVlINSS			:= 0
        nSalFam			:= 0
        nSalMat			:= 0
        nBasINSS13		:= 0
        nVlINSS13		:= 0
        nSalMat13		:= 0
        lAdd			:= .F.
		nVlINSSRET  	:= 0
		nVlINSS13RET 	:= 0
		nVlPIS			:= 0
		nVlPISRet		:= 0
		nVlPIS13		:= 0
		nVlPIS13Ret		:= 0

        aPos := {}

    EndIf

    nItem++

    setPercent(cTicket, nItem, nQtdRegs)

    (cNextAlias)->( dbSkip() )

EndDo

If nRegistro == 0
    setPercent(cTicket, 100, 100)
EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} grvINSSSint
@type			function
@description	Grava a parte sintética do relatório.
@author			Allyson Mesashi
@since			13/02/2020
/*/
//---------------------------------------------------------------------
Static Function GrvINSSSint( aINSSSint, nEmployees, lDivergTot, nSeq, oHash, oHashRET, cTicket)

Local oResponse	:=	JsonObject():New()
Local oRespRET	:=	JsonObject():New()

Default cTicket	:= ""

//Geração sintetica para a API INSSVALUES
oResponse["cpfNumber"]					:=	aINSSSint[1]
oResponse["name"]						:=	aINSSSint[2]
oResponse["esocialRegistration"]		:=	aINSSSint[3]
oResponse["esocialCategory"]			:=	aINSSSint[4]
oResponse["lotationCode"]				:=	aINSSSint[5]
oResponse["branchId"]					:=	aINSSSint[6]
oResponse["numberEmployees"]			:=	nEmployees

oResponse["inssBasis"]					:=	aINSSSint[7]
oResponse["inssValue"]					:=	aINSSSint[8]
oResponse["inss13Basis"]				:=	aINSSSint[9]
oResponse["inss13Value"]				:=	aINSSSint[10]
oResponse["familySalaryValue"]			:=	aINSSSint[11]
oResponse["maternitySalaryValue"]		:=	aINSSSint[12]
oResponse["maternitySalary13Value"]		:=	aINSSSint[13]
oResponse["pisPasepBasis"]				:=	aINSSSint[23]
oResponse["pisPasep13Basis"]			:=	aINSSSint[25]

oResponse["inssRetBasis"]				:=	aINSSSint[14]
oResponse["inssRetValue"]				:=	aINSSSint[15]
oResponse["inss13RetBasis"]				:=	aINSSSint[16]
oResponse["inss13RetValue"]				:=	aINSSSint[17]
oResponse["familySalaryRetValue"]		:=	aINSSSint[18]
oResponse["maternitySalaryRetValue"]	:=	aINSSSint[19]
oResponse["maternitySalary13RetValue"]	:=	aINSSSint[20]
oResponse["pisPasepRetBasis"]			:=	aINSSSint[24]
oResponse["pisPasep13RetBasis"]			:=	aINSSSint[26]

GrvItRes( @oHash, oResponse:ToJson(), StrZero( nSeq, 6 ), lDivergTot, "1", aINSSSint[1], cTicket)

//Geração sintetica para a API INSSRETVALUES
oRespRET["cpfNumber"]					:=	aINSSSint[1]
oRespRET["name"]						:=	aINSSSint[2]
oRespRET["inssGrossValue"]				:=	aINSSSint[8]
oRespRET["inssRetGrossValue"]			:=	aINSSSint[21]
oRespRET["inssRetDescGrossValue"]		:=	aINSSSint[15]
oRespRET["inss13GrossValue"]			:=	aINSSSint[10]
oRespRET["inss13RetGrossValue"]			:=	aINSSSint[22]
oRespRET["inss13DescGrossValue"]		:=	aINSSSint[17]
oRespRET["familySalaryValue"]			:=	aINSSSint[11]
oRespRET["familySalaryRetValue"]		:=	aINSSSint[18]
oRespRET["maternitySalaryValue"]		:=	aINSSSint[12]
oRespRET["maternitySalaryRetValue"]		:=	aINSSSint[19]
oRespRET["maternitySalary13Value"]		:=	aINSSSint[13]
oRespRET["maternitySalary13RetValue"]	:=	aINSSSint[20]

GrvItRes( @oHashRET, oRespRET:ToJson(), StrZero( nSeq, 6 ), lDivergTot, "1", aINSSSint[1], cTicket, "1")

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} Status
@type			method
@description	Método para consultar o percentual de execução do relatório.
@author			Allyson Mesashi
@since			13/02/2020
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET Status QUERYPARAM companyId, requestId WSRESTFUL GPEreportEsocialBaseConfer

Local oResponse		:=	Nil
Local cEmpRequest	:=	""
Local cFilRequest	:=	""
Local cRequestID	:=	""
Local aCompany		:=	{}
Local lRet			:=	.T.

Private lGrvTab		:= .F.

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:requestId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			lGrvTab := Len(FWTAMSX3("RU4_FILIAL")) > 0
			If ValidID( self:requestId )
				cRequestID := self:requestId

				GetStatus( @oResponse, cRequestID )

				self:SetResponse( oResponse:toJson() )
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
			EndIf
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
/*/{Protheus.doc} GetStatus
@type			function
@description	Executa a consulta do percentual de execução do relatório.
@author			Allyson Mesashi
@since			13/02/2020
@param			oResponse	-	Json com os valores do relatório totalizador
@param			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function GetStatus( oResponse, cRequestID )

Local cFim 			:= ""
Local nPerc			:= 0
Local lRegTab		:= .F.

oResponse := JsonObject():New()

If lGrvTab
	DBSelectArea( "RU4" )
	RU4->( DBSetOrder( 1 ) )
	If RU4->( dbSeek( xFilial( "RU4" ) + cRequestID ) )
		lRegTab := .T.
		oResponse["percent"]	:=	RU4->RU4_PERC
		If RU4->RU4_PERC == 100
			oResponse["finished"]	:= .T.
		Else
			oResponse["finished"]	:= .F.
		EndIf
	EndIf
EndIf

If !lRegTab
	VarGetXD(cRequestID, "nPerc", @nPerc)
	VarGetXD(cRequestID, "cFinished", @cFim)

	oResponse["finished"]	:=	Iif( cFim == "1", .F., .T. )
	oResponse["percent"]	:=	nPerc
EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} InssValues
@type			method
@description	Método para consultar resultado do relatório de conferência de INSS.
@author			Allyson Mesashi
@since			13/02/2020
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET InssValues QUERYPARAM companyId, requestId, synthetic, differencesOnly, page, pageSize, cpfNumber WSRESTFUL GPEreportEsocialBaseConfer

Local oResponse		:=	Nil
Local cEmpRequest	:=	""
Local cFilRequest	:=	""
Local cRequestID	:=	""
Local cCPF			:=  ""
Local nPage			:=	1
Local nPageSize		:=	15
Local aCompany		:=	{}
Local lSynthetic	:=	.F.
Local lDiverg		:=	.F.
Local lRet			:=	.T.

Private lGrvTab		:= .F.

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:requestId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			lGrvTab := Len(FWTAMSX3("RU4_FILIAL")) > 0
			If ValidID( self:requestId )
				cRequestID := self:requestId

				If self:synthetic <> Nil
					lSynthetic := self:synthetic
				EndIf

				If self:differencesOnly <> Nil
					lDiverg := self:differencesOnly
				EndIf

				If self:page <> Nil
					nPage := self:page
				EndIf

				If self:pageSize <> Nil
					nPageSize := self:pageSize
				EndIf

				If self:cpfNumber <> Nil
					cCPF := self:cpfNumber
				EndIf

				GetReport( @oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize, , cCPF )

				self:SetResponse( oResponse:toJson() )
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
			EndIf
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
/*/{Protheus.doc} PrepEnv
@type			function
@description	Prepara o ambiente de acordo com os parâmetros.
@author			Allyson Mesashi
@since			13/02/2020
@param			cEmpRequest	-	Empresa indicada no parâmetro companyId
@param			cFilRequest	-	Filial indicada no parâmetro companyId
@return			lRet		-	Indica se o ambiente foi preparado
/*/
//---------------------------------------------------------------------
Static Function PrepEnv( cEmpRequest, cFilRequest )

Local lRet	:=	.T.

If Type( "cEmpAnt" ) == "U" .or. Type( "cFilAnt" ) == "U"
	RPCClearEnv()
	RPCSetType( 3 )
	RPCSetEnv( cEmpRequest, cFilRequest,,, "GPE" )
ElseIf cEmpAnt <> cEmpRequest
	If FWFilExist( cEmpRequest, cFilRequest )
		RPCClearEnv()
		RPCSetType( 3 )
		RPCSetEnv( cEmpRequest, cFilRequest,,, "GPE" )
	Else
		lRet := .F.
	EndIf
ElseIf cFilAnt <> cFilRequest
	cFilAnt := cFilRequest
EndIf

If lRet
	lRet := FWFilExist( cEmpRequest, cFilRequest )
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetReport
@type			function
@description	Executa a consulta do resultado do relatório de conferência de INSS.
@author			Allyson Mesashi
@since			13/02/2020
@param			oResponse	-	Json com os valores do relatório totalizador
@param			cRequestID	-	Identificador da Requisição
@param			lSynthetic	-	Indica se o retorno deve ser sintético ou analítico
@param			lDiverg		-	Indica se deve retornar apenas as divergências
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
/*/
//---------------------------------------------------------------------
Static Function GetReport( oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize, lRETValues, cCPF, cLevel, lWarning )

Local oJson			:=	Nil
Local aJson			:=	{}
Local lHasNext		:=	.F.
Local aValues		:= {}
Local nPos			:= 0
Local lTemReg		:= .F.

Default lRETValues	:= .F.
Default cCPF		:= ""
Default cLevel		:= ""
Default lWarning	:= .F.

oResponse := JsonObject():New()

If lSynthetic
	If lGrvTab
		RU5->( DBSetOrder( 2 ) )
		If RU5->( dbSeek( xFilial( "RU5" ) + cRequestID + "1" + Iif( lDiverg, "1", "2" ) + Iif(lRETValues, "1", cLevel)) )
			lTemReg := .T.
			If CheckDiv(RU5->RU5_RESP)
				oJson := JsonObject():New()
				oJson:FromJson( RU5->RU5_RESP )
				aAdd( aJson, oJson )
				FreeObj( oJson )
			EndIf
		EndIf
	EndIf

	If !lTemReg
		If !lRETValues
			VarGetAD(cRequestID, "aValues", @aValues)
		Else
			VarGetAD(cRequestID, "aValuesRET", @aValues)
		EndIf
		If ( nPos := aScan( aValues, { |x| x[4] == "1" .And. x[3] == Iif( lDiverg, "1", "2" ) } ) ) > 0
			oJson := JsonObject():New()
			oJson:FromJson( aValues[nPos, 1] )
			aAdd( aJson, oJson )
			FreeObj( oJson )
		EndIf
	EndIf
Else
	aJson := GetDetails( cRequestID, lDiverg, nPage, nPageSize, @lHasNext, lRETValues, cCPF, cLevel, lWarning)
EndIf

oResponse["items"]		:=	aJson
oResponse["hasNext"]	:=	lHasNext

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidID
@type			function
@description	Verifica se o Identificador da Requisição é válido.
@author			Allyson Mesashi
@since			13/02/2020
@param			cRequestID	-	Identificador da Requisição
@return			lRet		-	Indica se o Identificador da Requisição é válido
/*/
//---------------------------------------------------------------------
Static Function ValidID( cRequestID )

Local lRet		:=	.F.

If lGrvTab
	DBSelectArea( "RU4" )
	RU4->( DBSetOrder( 1 ) )
	lRet := RU4->( MsSeek( xFilial( "RU4" ) + cRequestID ) )
EndIf

//Se não encontrou registro na tabela RU4
If !lRet
	lRet := VarIsUID( cRequestID )
EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDetails
@type			function
@description	Retorna os registros analíticos com controle de paginação.
@author			Allyson Mesashi
@since			13/02/2020
@param			cRequestID	-	Identificador da Requisição
@param			lDiverg		-	Indica se deve retornar apenas as divergências
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
@param			lHasNext	-	Indica se há existência de mais registros além dos retornados ( Referência )
@return			aJson		-	Json com o resultado processado para o relatório
/*/
//---------------------------------------------------------------------
Static Function GetDetails( cRequestID, lDiverg, nPage, nPageSize, lHasNext, lRETValues, cCPF, cLevel, lWarning)

Local oJson			:= Nil
Local oTotIRRFComp	:= JsonObject():New()
Local cAliasTMP		:= GetNextAlias()
Local cNextAlias	:= GetNextAlias()
Local cNextAlias2	:= GetNextAlias()
Local cRealName		:= ""
Local cQuery		:= ""
Local nRegIni		:= 0
Local nRegFim		:= 0
Local aJson			:= {}
Local aValues		:= {}
Local oTmpTable		:= {}
Local aValuesBkp	:= 0
Local nCont			:= 0
Local nSeq			:= 1
Local lTemTab		:= .F.
Local cWhere		:= ""
Local cBanco		:= TcGetDb()

Default lRETValues	:= .F.
Default cCPF		:= ""
Default cLevel		:= ""

If lGrvTab
	If lDiverg
		cWhere := " RU5.RU5_DIVERG = '1' "
	Else
		cWhere := " RU5.RU5_DIVERG IN ('1', '2') "
	EndIf

	If lWarning
		cWhere += " AND RU5.RU5_AVISO = '1' "
	Else
		cWhere += " AND RU5.RU5_AVISO IN (' ', '1', '2') "
	EndIf

	If !Empty( cCPF )
		cWhere += " AND RU5.RU5_CPF = '"+ cCPF +"' "
	EndIf

	If cLevel <> "9"
		cWhere += " AND RU5.RU5_TIPO = '2' "
		If lRETValues
			cWhere += " AND RU5.RU5_NIVEL = '1' "
		Else
			cWhere += " AND RU5.RU5_NIVEL = ' ' "
		EndIf
	Else
		cWhere += " AND RU5.RU5_TIPO IN ('1', '2') "
	EndIf

	cWhere	:= "%" + cWhere + "%"

	nRegIni := IIf(cBanco != "OPENEDGE", ((nPage - 1) * nPageSize) + 1, (nPage - 1) * nPageSize)
	nRegFim := nPage * nPageSize

	BeginSQL Alias cNextAlias2
		SELECT * FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) LINE_NUMBER, R_E_C_N_O_ RU5_RECNO
				FROM %table:RU5% RU5
				WHERE RU5.RU5_FILIAL = %xFilial:RU5%
					AND RU5.RU5_ID = %exp:cRequestID%
					AND %exp:cWhere%
					AND RU5.%notdel%
			) TAB
			WHERE LINE_NUMBER BETWEEN %exp:nRegIni% AND %exp:nRegFim%
		EndSQL

		While ( cNextAlias2 )->( !Eof() )
			lTemTab := .T.
			RU5->( DBGoTo( ( cNextAlias2 )->RU5_RECNO ) )

			If (( lDiverg .and. RU5->RU5_DIVERG == "1" ) .or. !lDiverg) .And. (( lWarning .and. RU5->RU5_AVISO == "1" ) .or. !lWarning)
				oJson := JsonObject():New()
				oJson:FromJson( RU5->RU5_RESP )
				If cLevel == "1"
					oJson:DelName("demonstrative")
					oJson:DelName("typesIrrfValues")
					oJson:DelName("totalDemonstratives")
				ElseIf cLevel == "2"
					oJson:DelName("totalIrrfRetention")
					oJson:DelName("typesIrrfValues")
					oJson:DelName("totalDemonstratives")
				ElseIf cLevel == "3"
					oJson:DelName("totalIrrfRetention")
					oJson:DelName("typesIrrfValues")
					oJson:DelName("demonstrative")
				ElseIf cLevel == "4"
					oJson:DelName("totalIrrfRetention")
					oJson:DelName("totalDemonstratives")
				EndIf

				If cLevel <> "9" .Or. (cLevel == "9" .And. RU5->RU5_NIVEL <> "0")
					aAdd( aJson, oJson )
				ElseIf (lDiverg .and. RU5->RU5_DIVERG == "1") .Or. (!lDiverg .and. RU5->RU5_DIVERG == "2")
					oTotIRRFComp := JsonObject():New()
					If RU5->RU5_NIVEL == "0"
						oTotIRRFComp:FromJson( RU5->RU5_RESP )
					EndIf
				EndIf
				FreeObj( oJson )
			EndIf

			( cNextAlias2 )->( DBSkip() )
		EndDo

		If cLevel $ "1*2*3*4*9"
			oJson := JsonObject():New()
			oJson["employees"] := aJson
			aJson := {}
			If cLevel == "9"
				aAdd( aJson, oTotIRRFComp )
				FreeObj( oTotIRRFComp )
			EndIf
			aAdd( aJson, oJson )
			FreeObj( oJson )
		EndIf

	( cNextAlias2 )->( DBCloseArea() )

	lHasNext := HasNextTab( cRequestID, nRegFim, lDiverg )
EndIf

If !lTemTab
	If !lRETValues
		VarGetAD(cRequestID, "aValues", @aValues)
	Else
		VarGetAD(cRequestID, "aValuesRET", @aValues)
	EndIf

	//Pesquisa pelo CPF para o apresentar o detalhamento dos registros
	If !Empty(cCPF)
		aValuesBkp := aClone(aValues)
		aValues	   := {}
		For nCont := 1 To Len(aValuesBkp)
			If aValuesBkp[nCont,5] == cCPF
				aAdd( aValues, {aValuesBkp[nCont,1], StrZero(nSeq, 6), aValuesBkp[nCont,3], aValuesBkp[nCont,4]})
				nSeq ++
			EndIf
		Next nCont
	EndIf

	fCriaTmp(cAliasTMP, aValues, oTmpTable)
	cRealName	:= oTmpTable:GetRealName()

	nRegIni := ( ( nPage - 1 ) * nPageSize ) + 1
	nRegFim := nPage * nPageSize

	cQuery := "SELECT * FROM ("
	cQuery += "	SELECT ROW_NUMBER() OVER( ORDER BY SEQ ) LINE_NUMBER"
	cQuery += "	FROM " + cRealName
	cQuery += "	WHERE TIPO = '2' "
	cQuery += "	) TAB "
	cQuery += "	WHERE LINE_NUMBER BETWEEN '" + cValToChar(nRegIni) + "' AND '" + cValToChar(nRegFim) + "'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cNextAlias,.T.,.T.)

	While (cNextAlias)->( !Eof() )
		(cAliasTMP)->( dbSeek( StrZero((cNextAlias)->LINE_NUMBER, 6) + "2" ) )
		If ( cAliasTMP )->TIPO == "2" .And. ( ( lDiverg .and. (cAliasTMP)->DIVERG == "1" ) .or. !lDiverg )
			oJson := JsonObject():New()
			oJson:FromJson( (cAliasTMP)->RESP1+(cAliasTMP)->RESP2+(cAliasTMP)->RESP3+(cAliasTMP)->RESP4 )
			aAdd( aJson, oJson )
			FreeObj( oJson )
		EndIf

		(cNextAlias)->( DBSkip() )
	EndDo

	(cNextAlias)->( DBCloseArea() )

	lHasNext := HasNext( cRequestID, nRegFim, cRealName )

	oTmpTable:Delete()
	oTmpTable := Nil
EndIf

Return( aJson )

//---------------------------------------------------------------------
/*/{Protheus.doc} HasNext
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados.
@author			Allyson Mesashi
@since			13/02/2020
@param			cRequestID	-	Identificador da Requisição
@param			nRegFim		-	Identificador do último registro retornado
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
/*/
//---------------------------------------------------------------------
Static Function HasNext( cRequestID, nRegFim, cAliasTMP )

Local cAliasMax	:=	GetNextAlias()
Local lHasNext	:=	.F.

cQuery := "SELECT MAX( LINE_NUMBER ) MAX_LINE FROM ("
cQuery += "	SELECT ROW_NUMBER() OVER( ORDER BY SEQ ) LINE_NUMBER"
cQuery += "	FROM " + cAliasTMP
cQuery += "	WHERE TIPO = '2' "
cQuery += "	) TAB "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasMax,.T.,.T.)

If (cAliasMax)->( !Eof() )
	If (cAliasMax)->MAX_LINE > nRegFim
		lHasNext := .T.
	EndIf
EndIf

(cAliasMax)->( DBCloseArea() )

Return( lHasNext )

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadSM0BaseCNPJ
@type			function
@description	Busca as Filias com a mesma Raiz de CNPJ.
@author			Allyson Mesashi
@since			13/02/2020
@return			aFilial	-	Filiais com a mesma Raiz de CNPJ da Filial logada
/*/
//---------------------------------------------------------------------
Static Function LoadSM0BaseCNPJ()

Local cBaseCNPJ	:=	Left( AllTrim( Posicione( "SM0", 1, cEmpAnt + cFilAnt, "M0_CGC" ) ), 8 )
Local nI		:=	0
Local nPos		:=	0
Local aGroup	:=	{}
Local aSM0		:=	FWLoadSM0( .T.,,.T. )
Local aFilial	:=	{}

For nI := 1 to Len( aSM0 )
	If cBaseCNPJ == AllTrim( Left( aSM0[nI][SM0_CGC], 8 ) )
		If aSM0[nI][SM0_GRPEMP] <> cEmpAnt
			If Len( aGroup ) == 0
				aAdd( aGroup, aSM0[nI][SM0_GRPEMP] )
			Else
				nPos := aScan( aGroup, {|x| x == aSM0[nI][SM0_GRPEMP] } )
				If nPos == 0
					aAdd( aGroup, aSM0[nI][SM0_GRPEMP] )
				EndIf
			EndIf
		EndIf
		aAdd( aFilial, aSM0[nI][SM0_CODFIL] )
	EndIf
Next nI

Return( aFilial )

/*/{Protheus.doc} function fSetErrorHandler
Função para setar erros tratados
@author  Hugo de Oliveira
@since   07/02/2020
@version 1.0
/*/
Static Function fSetErrorHandler( cTitle )
	bError  := { |e| oError := e , oError:Description := cTitle + CHR(13) + CHR(10) + oError:Description, Break(e) }
	bErrorBlock	:= ErrorBlock( bError )
Return .T.

/*/{Protheus.doc} function fResetErrorHandler
Função para limpar o retorno de erros
@author  Hugo de Oliveira
@since   07/02/2020
@version 1.0
/*/
Static Function fResetErrorHandler( cTitle )
	bError  	:= { |e| oError := e , Break( e ) }
	bErrorBlock := ErrorBlock( bError )
Return .T.

/*/{Protheus.doc} fCriaTmp()
Função que gera os valores do Array para tabela temporária auxiliar
@type function
@author Allyson Mesashi
@since 13/02/2020
@version 1.0
@param cAliasTmp	= Alias da tabela temporária principal
@param aValues		= Array com valores de INSS
/*/
Static Function fCriaTmp(cAliasTmp, aValues, oTmpTable)
Local aColumns	 := {}
Local nCont		 := {}

aAdd( aColumns, { "TIPO"		,"C",1,0})
aAdd( aColumns, { "SEQ"			,"C",6,0})
aAdd( aColumns, { "DIVERG"		,"C",1,0})
aAdd( aColumns, { "RESP1"		,"C",254,0 })
aAdd( aColumns, { "RESP2"		,"C",254,0 })
aAdd( aColumns, { "RESP3"		,"C",254,0 })
aAdd( aColumns, { "RESP4"		,"C",254,0 })

oTmpTable := FWTemporaryTable():New(cAliasTmp)
oTmpTable:SetFields( aColumns )
oTmpTable:AddIndex( "IND", { "SEQ", "TIPO", "DIVERG" } )
oTmpTable:Create()

For nCont := 1 To Len(aValues)
	If RecLock(cAliasTmp, .T.)
		(cAliasTmp)->TIPO	:= aValues[nCont, 4]
		(cAliasTmp)->SEQ 	:= aValues[nCont, 2]
		(cAliasTmp)->DIVERG := aValues[nCont, 3]
		(cAliasTmp)->RESP1 	:= SubStr( aValues[nCont, 1], 1, 254 )
		(cAliasTmp)->RESP2 	:= SubStr( aValues[nCont, 1], 255, 508 )
		(cAliasTmp)->RESP3 	:= SubStr( aValues[nCont, 1], 509, 762 )
		(cAliasTmp)->RESP4 	:= SubStr( aValues[nCont, 1], 763, 1016 )
		(cAliasTmp)->(MsUnLock())
	EndIf
Next nCont

(cAliasTmp)->( dbGoTop() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFGTSData
Escopo: FGTS
Prepara os dados filtrados no formato JSON para retornar ao front.

@author Allyson Mesashi
@since 21/02/2020
/*/
//-------------------------------------------------------------------
Static Function GetFGTSData( oReq, cTicket )

Local oResponse		:=	Nil
Local oHashBase		:=	HMNew()
Local oHashDepo		:=	HMNew()
Local oArqFgts		:=	HMNew()
Local cStatusGov	:=	""
Local cChave		:=	""
Local nI			:=	0
Local nFuncTotal	:=	0
Local nFuncDiverg	:=	0
Local nIni			:=	0
Local nPosBase		:=	0
Local nQtdRegs		:=	0
Local nSeq			:=	0
Local nPerc			:=	0
Local aBaseSint		:=	{ "", "", 0, 0, 0, 0, 0, 0 }
Local aBaseDiverg	:=	{ "", "", 0, 0, 0, 0, 0, 0 }
Local aDepoSint		:=	{ "", "", "", "", 0, 0, 0, 0, 0, 0, 0 }
Local aDepoDiverg	:=	{ "", "", "", "", 0, 0, 0, 0, 0, 0, 0 }
Local aArqBase		:=	{}
Local aArqDepo		:=	{}
Local aArqFgt		:=	{}
Local aResponse		:=	{}
Local aArea			:=	GetArea()
Local lFim			:=	.F.
Local lDiverg		:=	.F.

//Filtra os dados do FGTS e gera o hash
FilFGTSData( oReq, @oHashBase, @oHashDepo, cTicket )

//Grava o conteúdo dos hashs em arrays
HMList( oHashBase, @aArqBase )
HMList( oHashDepo, @aArqDepo )

nQtdRegs := Len( aArqBase )

//Monta o retorno para a API de FGTS
For nI := 1 to Len( aArqDepo )
	oResponse := JsonObject():New()

	If !aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_LOCALIZADO]
		cStatusGov := "Não Localizado"
	Else
		cStatusGov := ""
	EndIf

    oResponse["cpfNumber"]				:=	aArqDepo[nI,2,1,HASH_DEPOSITO_CPF]

	oResponse["name"]					:=	aArqDepo[nI,2,1,HASH_DEPOSITO_NOME]
	oResponse["esocialRegistration"]	:=	aArqDepo[nI,2,1,HASH_DEPOSITO_MATRICULA]
	oResponse["esocialCategory"]		:=	aArqDepo[nI,2,1,HASH_DEPOSITO_CATEGORIA]

	oResponse["fgtsValue"]				:=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]
	oResponse["fgts13Value"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]
	oResponse["fgtsRescissionValue"]	:=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]

	If Empty( cStatusGov )
		oResponse["fgtsRetValue"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]
		oResponse["fgts13RetValue"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]
		oResponse["fgtsRescissionRetValue"]	:=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]
	Else
		oResponse["fgtsRetValue"]			:=	0
		oResponse["fgts13RetValue"]			:=	0
		oResponse["fgtsRescissionRetValue"]	:=	0
	EndIf

	aDepoSint[6]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]
	aDepoSint[7]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]
	aDepoSint[8]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]

	If Empty( cStatusGov )
		aDepoSint[9]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]
		aDepoSint[10]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]
		aDepoSint[11]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]
	EndIf

	nFuncTotal ++

	lDiverg := .F.

	If 	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS] <> aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS] .or.;
		aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO] <> aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO] .or.;
		aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO] <> aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]

		lDiverg		:=	.T.

		aDepoDiverg[6]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]
		aDepoDiverg[7]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]
		aDepoDiverg[8]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]

		If Empty( cStatusGov )
			aDepoDiverg[9]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]
			aDepoDiverg[10]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]
			aDepoDiverg[11]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]
		EndIf

		nFuncDiverg ++
	EndIf

	cChave := aArqDepo[nI,2,1,HASH_DEPOSITO_CPF] + aArqDepo[nI,2,1,HASH_DEPOSITO_CATEGORIA] + aArqDepo[nI,2,1,HASH_DEPOSITO_MATRICULA]

	lFim		:=	.F.
	nIni		:=	1
	aResponse	:=	{}

	While !lFim
		nPosBase := aScan( aArqBase, { |x| x[2,1,HASH_BASE_CPF] + x[2,1,HASH_BASE_CATEGORIA] + x[2,1,HASH_BASE_MATRICULA] == cChave }, nIni )

		//Se achar a base para o valor, adiciona um item novo no array
		If nPosBase > 0
			aAdd( aResponse, JsonObject():New() )

			If !aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_LOCALIZADO]
				cStatusGov := "Não Localizado"
			Else
				cStatusGov := ""
			EndIf

			aResponse[Len( aResponse )]["branchId"]					:=	aArqBase[nPosBase,2,1,HASH_BASE_ESTABELECIMENTO]
			aResponse[Len( aResponse )]["lotationCode"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_LOTACAO]

			aResponse[Len( aResponse )]["fgtsBasis"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS]
			aResponse[Len( aResponse )]["fgts13Basis"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
			aResponse[Len( aResponse )]["fgtsRescissionBasis"]		:=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

			If Empty( cStatusGov )
				aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
				aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
				aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]
			Else
				aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	0
				aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	0
				aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	0
			EndIf

			aBaseSint[3]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS]
			aBaseSint[4]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
			aBaseSint[5]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

			If Empty( cStatusGov )
				aBaseSint[6]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
				aBaseSint[7]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
				aBaseSint[8]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]
			EndIf

			If lDiverg
				aBaseDiverg[3]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS]
				aBaseDiverg[4]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
				aBaseDiverg[5]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

				If Empty( cStatusGov )
					aBaseDiverg[6]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
					aBaseDiverg[7]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
					aBaseDiverg[8]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]
				EndIf
			EndIf

			aDel( aArqBase, nPosBase )
			aSize( aArqBase, Len( aArqBase ) - 1 )

			nIni := nPosBase
			nPosBase := 0

			nPerc ++
			SetPercent( cTicket, nPerc, nQtdRegs )
		Else
			lFim := .T.
		EndIf
	EndDo

	oResponse["basis"] := aResponse

	nSeq ++
	GrvItRes( @oArqFgts, oResponse:ToJson(), StrZero( nSeq, 6 ), lDiverg, "2" )
Next nI

lDiverg := .F.
aSort( aArqBase,,, { |x,y| x[2,1,HASH_BASE_CPF] + x[2,1,HASH_BASE_NOME] + x[2,1,HASH_BASE_MATRICULA] + x[2,1,HASH_BASE_CATEGORIA] < y[2,1,HASH_BASE_CPF] + y[2,1,HASH_BASE_NOME] + y[2,1,HASH_BASE_MATRICULA] + y[2,1,HASH_BASE_CATEGORIA] } )

//Bases que não possuem vínculos com depósitos
For nI := 1 to Len( aArqBase )
	If nI > 1 .and. aArqBase[nI,2,1,HASH_BASE_CPF] + aArqBase[nI,2,1,HASH_BASE_NOME] + aArqBase[nI,2,1,HASH_BASE_MATRICULA] + aArqBase[nI,2,1,HASH_BASE_CATEGORIA] <> cChave
		oResponse := JsonObject():New()

		oResponse["cpfNumber"]				:=	aArqBase[nI,2,1,HASH_BASE_CPF]
		oResponse["name"]					:=	aArqBase[nI,2,1,HASH_BASE_NOME]
		oResponse["esocialRegistration"]	:=	aArqBase[nI,2,1,HASH_BASE_MATRICULA]
		oResponse["esocialCategory"]		:=	aArqBase[nI,2,1,HASH_BASE_CATEGORIA]

		oResponse["fgtsValue"]				:=	0
		oResponse["fgts13Value"]			:=	0
		oResponse["fgtsRescissionValue"]	:=	0

		oResponse["fgtsTafValue"]			:=	0
		oResponse["fgts13TafValue"]			:=	0
		oResponse["fgtsRescissionTafValue"]	:=	0

		oResponse["fgtsRetValue"]			:=	0
		oResponse["fgts13RetValue"]			:=	0
		oResponse["fgtsRescissionRetValue"]	:=	0

		oResponse["basis"] := aResponse

		nSeq ++
		GrvItRes( @oArqFgts, oResponse:ToJson(), StrZero( nSeq, 6 ), lDiverg, "2" )

		aResponse := {}

		nFuncTotal ++
	EndIf

	aAdd( aResponse, JsonObject():New() )

	If !aArqBase[nI,2,1,HASH_BASE_GOVERNO_LOCALIZADO]
		cStatusGov := "Não Localizado"
	Else
		cStatusGov := ""
	EndIf

	aResponse[Len( aResponse )]["branchId"]					:=	aArqBase[nI,2,1,HASH_BASE_ESTABELECIMENTO]
	aResponse[Len( aResponse )]["lotationCode"]				:=	aArqBase[nI,2,1,HASH_BASE_LOTACAO]

	aResponse[Len( aResponse )]["fgtsBasis"]				:=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS]
	aResponse[Len( aResponse )]["fgts13Basis"]				:=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
	aResponse[Len( aResponse )]["fgtsRescissionBasis"]		:=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

	If Empty( cStatusGov )
		aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
		aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
		aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]
	Else
		aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	0
		aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	0
		aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	0
	EndIf

	aBaseSint[3]	+=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS]
	aBaseSint[4]	+=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
	aBaseSint[5]	+=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

	If Empty( cStatusGov )
		aBaseSint[6]	+=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
		aBaseSint[7]	+=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
		aBaseSint[8]	+=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]
	EndIf

	cChave := aArqBase[nI,2,1,HASH_BASE_CPF] + aArqBase[nI,2,1,HASH_BASE_NOME] + aArqBase[nI,2,1,HASH_BASE_MATRICULA] + aArqBase[nI,2,1,HASH_BASE_CATEGORIA]

	nPerc ++
	SetPercent( cTicket, nPerc, nQtdRegs )
Next nI

//Se não encontrou os dados
If Len( aArqDepo ) == 0
	SetPercent( cTicket, 100, 100 )
Else
	//Grava a parte sintética
	GrvFGTSSint( aDepoSint, aBaseSint, nFuncTotal, .F., 1, @oArqFgts )
	GrvFGTSSint( aDepoDiverg, aBaseDiverg, nFuncDiverg, .T., 2, @oArqFgts )
EndIf

//Grava o conteúdo dos hashs em arrays
HMList(oArqFgts, @aArqFgt)

fOrdena(aArqFgt)

SetFinish( cTicket, aArqFgt )

HMClean(oHashBase)
HMClean(oHashDepo)
HMClean(oArqFgts)

RestArea( aArea )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} filFGTSData
@type			function
@description	Filtra os dados de acordo com os parametros recebidos e salva em um hash.
@author			Allyson Mesashi
@since			21/02/20
/*/
//---------------------------------------------------------------------
Static Function filFGTSData(oReq, oHashBase, oHashDepo, cTicket)

Local cNextAlias    := GetNextAlias()
Local cNatureza		:= ""
Local cTipo			:= ""
Local cIncidFGTS	:= ""
Local nBasFGTS		:= 0
Local nDepFGTS		:= 0
Local nBasFGTSRes	:= 0
Local nDepFGTSRes	:= 0
Local nBasFGTS13	:= 0
Local nDepFGTS13	:= 0
Local nQtdRegs		:= 0
Local aPosBase		:= {}
Local aPosDepo		:= {}
Local lAddBase		:= .F.
Local lAddDepo		:= .F.
Local nItem         := 0
Local cQry          := ""

Local aLotacao      := {}
Local aCategoria    := {}
Local aEstabe       := {}
Local aCPFs		    := {}
Local aMats         := {}

Local cFilSel	:=	""
Local nI		:=	0
Local aFilial	:=	{}

aFilial := LoadSM0BaseCNPJ()

For nI := 1 to Len( aFilial )
	If !Empty( cFilSel )
		cFilSel += ","
	EndIf

	cFilSel += "'" + aFilial[nI] + "'"
Next nI

If Select(cNextAlias) > 0
    (cNextAlias)->( dbCloseArea() )
EndIf

cPeriodo    := oReq["paymentPeriod"]
aCategoria  := oReq["eSocialCategory"]
aLotacao    := oReq["lotationCode"]
aEstabe     := oReq["registrationNumber"]
aCPFs		:= oReq["cpfNumber"]
aMats 		:= oReq["eSocialRegistration"]

cQry := "SELECT "
cQry += "   RJO.RJO_FILIAL, "
cQry += "    RJO.RJO_INDAPU INDAPU,  "
cQry += "    RJO.RJO_PERAPU, "
cQry += "    RJO.RJO_INDDEC IND_DEC, "
cQry += "    RJO.RJO_CPF CPF, "
cQry += "    RJO.RJO_NOME NOME, "
cQry += "    RJO.RJO_MATRIC MATRICULA, "
cQry += "    RJO.RJO_CATEG CATEGORIA, "
cQry += "    RJO.RJO_TPINSC, "
cQry += "    RJO.RJO_NRINSC ESTAB, "
cQry += "    RJO.RJO_CODLOT LOTACAO, "
cQry += "    RJO.RJO_EVENTO, "
cQry += "    RJO.RJO_NATRUB NATUREZA, "
cQry += "    RJO.RJO_TPRUBR TP_RUBRICA, "
cQry += "    RJO.RJO_INCFGT INC_FG, "
cQry += "    RJO.RJO_INCCP INC_CP, "
cQry += "    RJO.RJO_TPVLR TIPO_BASE, "
cQry += "    RJO.RJO_VALOR VALOR  "
cQry += "FROM  "+RetSqlName("RJO")+" RJO  "
cQry += "WHERE RJO.D_E_L_E_T_ = ' ' "
cQry += "    AND RJO_FILIAL IN ( " + cFilSel + " ) "
cQry += "    AND RJO_PERAPU = '"+oReq["paymentPeriod"]+"'  "

If !Empty(aCategoria)
    cQry += "    AND RJO_CATEG IN "+FormatIn(ArrayToStr(aCategoria),";")+"  "
EndIf

If !Empty(aLotacao)
    cQry += "    AND RJO_CODLOT IN "+FormatIn(ArrayToStr(aLotacao),";")+" "
EndIf

If !Empty(aEstabe)
	cQry += "    AND RJO_NRINSC IN "+FormatIn(ArrayToStr(aEstabe),";")+" "
EndIf

If !Empty(aCPFs)
    cQry += " AND RJO_CPF IN " + FormatIn(ArrayToStr(aCPFs),";")+" "
EndIf

If !Empty(aMats)
	cQry += " AND RJO_MATRIC IN " + FormatIn(ArrayToStr(aMats),";") + " "
EndIf

TCQUERY cQry NEW ALIAS (cNextAlias)

If (cNextAlias)->( !Eof() )
	( cNextAlias )->( DBEval( { || nQtdRegs ++ } ) )
EndIf

(cNextAlias)->( dbGoTop() )

While (cNextAlias)->( !Eof() )
    cEvento := AllTrim( ( cNextAlias )->RJO_EVENTO )

    If cEvento $ "S-1200/S-2299/S-2399"
        cNatureza	:=	AllTrim( (cNextAlias)->NATUREZA )
        cTipo		:=	AllTrim( (cNextAlias)->TP_RUBRICA )
        cIncidFGTS	:=	AllTrim( (cNextAlias)->INC_FG )

        If (cNextAlias)->INDAPU == "1"
            If cNatureza == "9902" .and. cTipo == "3"
                nBasFGTS := (cNextAlias)->VALOR
                lAddBase := .T.
            ElseIf cNatureza == "9904" .and. cTipo == "3"
                nBasFGTSRes := (cNextAlias)->VALOR
                lAddBase := .T.
            ElseIf cNatureza == "9908" .and. cTipo == "3"
                If cEvento == "S-1200"
                    nDepFGTS := (cNextAlias)->VALOR
                    lAddDepo := .T.
                Else
                    nDepFGTSRes := (cNextAlias)->VALOR
                    lAddDepo := .T.
                EndIf
            EndIf
        ElseIf (cNextAlias)->INDAPU == "2"
            If cNatureza == "9902" .and. cTipo == "3"
                nBasFGTS13 := (cNextAlias)->VALOR
                lAddBase := .T.
            ElseIf cNatureza == "9908" .and. cTipo == "3"
                nDepFGTS13 := (cNextAlias)->VALOR
                lAddDepo := .T.
            EndIf
        EndIf
	 ElseIf cEvento == "S-5003"
        cTipo := AllTrim( (cNextAlias)->TIPO_BASE )

        If cTipo $ "11|13|15|17"
            nBasFGTS := (cNextAlias)->VALOR
            lAddBase := .T.
        ElseIf cTipo $ "12|14|16|18|22|25|28|31"
            nBasFGTS13 := (cNextAlias)->VALOR
            lAddBase := .T.
        ElseIf cTipo $ "21|23|24|26|27|29|30|32"
            nBasFGTSRes := (cNextAlias)->VALOR
            lAddBase := .T.
        ElseIf cTipo $ "51|53|55|57"
            nDepFGTS := (cNextAlias)->VALOR
            lAddDepo := .T.
        ElseIf cTipo $ "52|54|56|58|62|65|68|71"
            nDepFGTS13 := (cNextAlias)->VALOR
            lAddDepo := .T.
        ElseIf cTipo $ "61|63|64|66|67|69|70|72"
            nDepFGTSRes := (cNextAlias)->VALOR
            lAddDepo := .T.
        EndIf
	Else
        lAddBase := .F.
        lAddDepo := .F.
    EndIf

	If lAddBase
        If HMGet( oHashBase, AllTrim( (cNextAlias)->ESTAB ) + AllTrim( (cNextAlias)->CPF ) + AllTrim( (cNextAlias)->MATRICULA ) + AllTrim( (cNextAlias)->CATEGORIA ) + AllTrim( (cNextAlias)->LOTACAO ), @aPosBase )
			aPosBase[1,HASH_BASE_CPF]				:=	AllTrim( (cNextAlias)->CPF )
            If !Empty(AllTrim((cNextAlias)->NOME))
				aPosBase[1,HASH_BASE_NOME]				:=	AllTrim( (cNextAlias)->NOME )
			EndIf
            aPosBase[1,HASH_BASE_MATRICULA]			:=	AllTrim( (cNextAlias)->MATRICULA )
            aPosBase[1,HASH_BASE_LOTACAO]			:=	AllTrim( (cNextAlias)->LOTACAO )
            aPosBase[1,HASH_BASE_ESTABELECIMENTO]	:=	AllTrim( (cNextAlias)->ESTAB )
            aPosBase[1,HASH_BASE_CATEGORIA]			:=	AllTrim( (cNextAlias)->CATEGORIA )
            aPosBase[1,HASH_BASE_EVENTO_ESOCIAL]	:=	cEvento

            If cEvento $ "S-1200/S-2299/S-2399"
				aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS]				+=	nBasFGTS
				aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
				aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes
            ElseIf cEvento == "S-5003"
				aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS]				+=	nBasFGTS
				aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
				aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes
				aPosBase[1,HASH_BASE_GOVERNO_LOCALIZADO]			:=	.T.
            EndIf

            HMSet( oHashBase, aPosBase[1,HASH_BASE_ESTABELECIMENTO] + aPosBase[1,HASH_BASE_CPF] + aPosBase[1,HASH_BASE_MATRICULA] + aPosBase[1,HASH_BASE_CATEGORIA] + aPosBase[1,HASH_BASE_LOTACAO], aPosBase )
		Else
            aPosBase := InitBase()

            aPosBase[HASH_BASE_CPF]				:=	AllTrim( (cNextAlias)->CPF )
            aPosBase[HASH_BASE_NOME]			:=	AllTrim( (cNextAlias)->NOME )
            aPosBase[HASH_BASE_MATRICULA]		:=	AllTrim( (cNextAlias)->MATRICULA )
            aPosBase[HASH_BASE_LOTACAO]			:=	AllTrim( (cNextAlias)->LOTACAO )
            aPosBase[HASH_BASE_ESTABELECIMENTO]	:=	AllTrim( (cNextAlias)->ESTAB )
            aPosBase[HASH_BASE_CATEGORIA]		:=	AllTrim( (cNextAlias)->CATEGORIA )
            aPosBase[HASH_BASE_EVENTO_ESOCIAL]	:=	cEvento

            If cEvento $ "S-1200/S-2299/S-2399"
				aPosBase[HASH_BASE_FOLHA_BASE_FGTS]				:=	nBasFGTS
				aPosBase[HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
				aPosBase[HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes
			ElseIf cEvento == "S-5003"
				aPosBase[HASH_BASE_GOVERNO_BASE_FGTS]				:=	nBasFGTS
				aPosBase[HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
				aPosBase[HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes
				aPosBase[HASH_BASE_GOVERNO_LOCALIZADO]				:=	.T.
            EndIf

            HMAdd( oHashBase, aPosBase, HASH_BASE_ESTABELECIMENTO, 3, HASH_BASE_CPF, 3, HASH_BASE_MATRICULA, 3, HASH_BASE_CATEGORIA, 3, HASH_BASE_LOTACAO, 3 )
        EndIf
    EndIf

	If lAddDepo
        If HMGet( oHashDepo, AllTrim( (cNextAlias)->CPF ) + AllTrim( (cNextAlias)->MATRICULA ) + AllTrim( (cNextAlias)->CATEGORIA ), @aPosDepo )
            aPosDepo[1,HASH_DEPOSITO_CPF]				:=	AllTrim( (cNextAlias)->CPF )
            If !Empty(AllTrim((cNextAlias)->NOME))
				aPosDepo[1,HASH_DEPOSITO_NOME]				:=	AllTrim( (cNextAlias)->NOME )
			EndIf
            aPosDepo[1,HASH_DEPOSITO_MATRICULA]			:=	AllTrim( (cNextAlias)->MATRICULA )
            aPosDepo[1,HASH_DEPOSITO_CATEGORIA]			:=	AllTrim( (cNextAlias)->CATEGORIA )
            aPosDepo[1,HASH_DEPOSITO_EVENTO_ESOCIAL]	:=	cEvento

            If cEvento $ "S-1200/S-2299/S-2399"
				aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				+=	nDepFGTS
				aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
				aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes
			ElseIf cEvento == "S-5003"
				aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				+=	nDepFGTS
				aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
				aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes
				aPosDepo[1,HASH_DEPOSITO_GOVERNO_LOCALIZADO]				:=	.T.
            EndIf

            HMSet( oHashDepo, aPosDepo[1,HASH_DEPOSITO_CPF] + aPosDepo[1,HASH_DEPOSITO_MATRICULA] + aPosDepo[1,HASH_DEPOSITO_CATEGORIA], aPosDepo )
        Else
            aPosDepo := InitDeposito()

            aPosDepo[HASH_DEPOSITO_CPF]				:=	AllTrim( (cNextAlias)->CPF )
            aPosDepo[HASH_DEPOSITO_NOME]			:=	AllTrim( (cNextAlias)->NOME )
            aPosDepo[HASH_DEPOSITO_MATRICULA]		:=	AllTrim( (cNextAlias)->MATRICULA )
            aPosDepo[HASH_DEPOSITO_CATEGORIA]		:=	AllTrim( (cNextAlias)->CATEGORIA )
            aPosDepo[HASH_DEPOSITO_EVENTO_ESOCIAL]	:=	cEvento

            If cEvento $ "S-1200/S-2299/S-2399"
				aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	nDepFGTS
				aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
				aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes
 			ElseIf cEvento == "S-5003"
				aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				:=	nDepFGTS
				aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
				aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes
				aPosDepo[HASH_DEPOSITO_GOVERNO_LOCALIZADO]					:=	.T.
            EndIf

            HMAdd( oHashDepo, aPosDepo, HASH_DEPOSITO_CPF, 3, HASH_DEPOSITO_MATRICULA, 3, HASH_DEPOSITO_CATEGORIA, 3 )
        EndIf
    EndIf

    (cNextAlias)->(dbSkip())

    nItem++

    setPercent(cTicket, nItem, nQtdRegs)

    cNatureza	:=	""
    cTipo		:=	""
    cIncidFGTS	:=	""
    nBasFGTS	:=	0
    nDepFGTS	:=	0
    nBasFGTS13	:=	0
    nDepFGTS13	:=	0
    nBasFGTSRes	:=	0
    nDepFGTSRes	:=	0
    aPosBase	:=	{}
    aPosDepo	:=	{}
    lAddBase	:=	.F.
    lAddDepo	:=	.F.

EndDo

If nItem == 0
	SetPercent( cTicket, 100, 100 )
EndIf

Return()

Static Function InitBase()

Local aInit	:=	Array( 15 )

aInit[HASH_BASE_RECIBO_TRANSMISSAO]				:=	""
aInit[HASH_BASE_ESTABELECIMENTO]				:=	""
aInit[HASH_BASE_CPF]							:=	""
aInit[HASH_BASE_NOME]							:=	""
aInit[HASH_BASE_MATRICULA]						:=	""
aInit[HASH_BASE_CATEGORIA]						:=	""
aInit[HASH_BASE_LOTACAO]						:=	""
aInit[HASH_BASE_EVENTO_ESOCIAL]					:=	0
aInit[HASH_BASE_FOLHA_BASE_FGTS]				:=	0
aInit[HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]		:=	0
aInit[HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]		:=	0
aInit[HASH_BASE_GOVERNO_BASE_FGTS]				:=	0
aInit[HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	:=	0
aInit[HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	:=	0
aInit[HASH_BASE_GOVERNO_LOCALIZADO]				:=	.F.

Return( aInit )

Static Function InitDeposito()

Local aInit	:=	Array( 13 )

aInit[HASH_DEPOSITO_RECIBO_TRANSMISSAO]					:=	""
aInit[HASH_DEPOSITO_CPF]								:=	""
aInit[HASH_DEPOSITO_NOME]								:=	""
aInit[HASH_DEPOSITO_MATRICULA]							:=	""
aInit[HASH_DEPOSITO_CATEGORIA]							:=	""
aInit[HASH_DEPOSITO_EVENTO_ESOCIAL]						:=	0
aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	0
aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]		:=	0
aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]		:=	0
aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				:=	0
aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	:=	0
aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	:=	0
aInit[HASH_DEPOSITO_GOVERNO_LOCALIZADO]					:=	.F.

Return( aInit )

//---------------------------------------------------------------------
/*/{Protheus.doc} GrvFGTSSint
@type			function
@description	Grava a parte sintética do relatório.
@author			Allyson Mesashi
@since			21/02/20
/*/
//---------------------------------------------------------------------
Static Function GrvFGTSSint( aDepoSint, aBaseSint, nEmployees, lDiverg, nSeq, oHash )

Local oResponse	:=	JsonObject():New()
Local aResponse	:=	{}

oResponse["cpfNumber"]				:=	aDepoSint[1]
oResponse["name"]					:=	aDepoSint[2]
oResponse["esocialRegistration"]	:=	aDepoSint[3]
oResponse["esocialCategory"]		:=	aDepoSint[4]
oResponse["numberEmployees"]		:=	nEmployees

oResponse["fgtsValue"]				:=	aDepoSint[6]
oResponse["fgts13Value"]			:=	aDepoSint[7]
oResponse["fgtsRescissionValue"]	:=	aDepoSint[8]

oResponse["fgtsRetValue"]			:=	aDepoSint[9]
oResponse["fgts13RetValue"]			:=	aDepoSint[10]
oResponse["fgtsRescissionRetValue"]	:=	aDepoSint[11]

//Base
aAdd( aResponse, JsonObject():New() )

aResponse[Len( aResponse )]["branchId"]					:=	aBaseSint[1]
aResponse[Len( aResponse )]["lotationCode"]				:=	aBaseSint[2]

aResponse[Len( aResponse )]["fgtsBasis"]				:=	aBaseSint[3]
aResponse[Len( aResponse )]["fgts13Basis"]				:=	aBaseSint[4]
aResponse[Len( aResponse )]["fgtsRescissionBasis"]		:=	aBaseSint[5]

aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	aBaseSint[6]
aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	aBaseSint[7]
aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	aBaseSint[8]

oResponse["basis"] := aResponse

GrvItRes( @oHash, oResponse:ToJson(), StrZero( nSeq, 6 ), lDiverg, "1" )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FgtsValues
@type			method
@description	Método para consultar resultado do relatório de conferência de INSS.
@author			Allyson Mesashi
@since			21/02/2020
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET FgtsValues QUERYPARAM companyId, requestId, synthetic, differencesOnly, page, pageSize WSRESTFUL GPEreportEsocialBaseConfer

Local oResponse		:=	Nil
Local cEmpRequest	:=	""
Local cFilRequest	:=	""
Local cRequestID	:=	""
Local nPage			:=	1
Local nPageSize		:=	15
Local aCompany		:=	{}
Local lSynthetic	:=	.F.
Local lDiverg		:=	.F.
Local lRet			:=	.T.

Private lGrvTab		:= ""

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:requestId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			lGrvTab := Len(FWTAMSX3("RU4_FILIAL")) > 0
			If ValidID( self:requestId )
				cRequestID := self:requestId

				If self:synthetic <> Nil
					lSynthetic := self:synthetic
				EndIf

				If self:differencesOnly <> Nil
					lDiverg := self:differencesOnly
				EndIf

				If self:page <> Nil
					nPage := self:page
				EndIf

				If self:pageSize <> Nil
					nPageSize := self:pageSize
				EndIf

				GetReport( @oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize )

				self:SetResponse( oResponse:toJson() )
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
			EndIf
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
/*/{Protheus.doc} InssRetValues
@type			method
@description	Método para consultar resultado dos valores sintéticos do painel do INSS.
@author			lidio.oliveira
@since			07/08/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET InssRetValues QUERYPARAM companyId, requestId, synthetic, differencesOnly, page, pageSize WSRESTFUL GPEreportEsocialBaseConfer

Local oResponse		:=	Nil
Local cEmpRequest	:=	""
Local cFilRequest	:=	""
Local cRequestID	:=	""
Local nPage			:=	1
Local nPageSize		:=	30
Local aCompany		:=	{}
Local lSynthetic	:=	.F.
Local lDiverg		:=	.F.
Local lRet			:=	.T.

Private lGrvTab		:= .F.

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:requestId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			lGrvTab := Len(FWTAMSX3("RU4_FILIAL")) > 0
			If ValidID( self:requestId )
				cRequestID := self:requestId

				If self:synthetic <> Nil
					lSynthetic := self:synthetic
				EndIf

				If self:differencesOnly <> Nil
					lDiverg := self:differencesOnly
				EndIf

				If self:page <> Nil
					nPage := self:page
				EndIf

				If self:pageSize <> Nil
					nPageSize := self:pageSize
				EndIf

				GetReport( @oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize, .T. )

				self:SetResponse( oResponse:toJson() )
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
			EndIf
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
/*/{Protheus.doc} GrvINSSSCPF
@type			function
@description	Grava a totalização por CPF.
@author			lidio.oliveira
@since			06/08/2021
/*/
//---------------------------------------------------------------------
Static Function GrvINSSCPF ( aINSSCPF, oHashRET, cTicket)

Local oRespRET		:= JsonObject():New()
Local nX			:= 0
Local nSeq			:= 1
Local lDiverg		:= .F.

Default cTicket		:= ""

For nX := 1 To Len(aINSSCPF)

	lDiverg := .F.

	oRespRET["cpfNumber"]					:=	aINSSCPF[nX,1]
	oRespRET["name"]						:=	aINSSCPF[nX,2]
	oRespRET["inssGrossValue"]				:=	aINSSCPF[nX,3]
	oRespRET["inssRetGrossValue"]			:=	aINSSCPF[nX,8]
	oRespRET["inssRetDescGrossValue"]		:=	aINSSCPF[nX,9]
	oRespRET["inss13GrossValue"]			:=	aINSSCPF[nX,4]
	oRespRET["inss13RetGrossValue"]			:=	aINSSCPF[nX,10]
	oRespRET["inss13DescGrossValue"]		:=	aINSSCPF[nX,11]
	oRespRET["familySalaryValue"]			:=	aINSSCPF[nX,5]
	oRespRET["familySalaryRetValue"]		:=	aINSSCPF[nX,12]
	oRespRET["maternitySalaryValue"]		:=	aINSSCPF[nX,6]
	oRespRET["maternitySalaryRetValue"]		:=	aINSSCPF[nX,13]
	oRespRET["maternitySalary13Value"]		:=	aINSSCPF[nX,7]
	oRespRET["maternitySalary13RetValue"]	:=	aINSSCPF[nX,14]
	oRespRET["pisPasepBasis"]				:=	aINSSCPF[nX,15]
	oRespRET["pisPasepRetBasis"]			:=	aINSSCPF[nX,16]
	oRespRET["pisPasep13Basis"]				:=	aINSSCPF[nX,17]
	oRespRET["pisPasep13RetBasis"]			:=	aINSSCPF[nX,18]

	If ((aINSSCPF[nX,3] + aINSSCPF[nX,4]) <> (aINSSCPF[nX,8] + aINSSCPF[nX,10])) .Or. ; //INSS Folha + 13 divergente de INSS + 13 Calculados pelo RET
	((aINSSCPF[nX,3] + aINSSCPF[nX,4]) <> (aINSSCPF[nX,9] + aINSSCPF[nX,11])) .Or. ; //INSS Folha + 13 divergente de INSS + 13 Descontados pelo RET
	((aINSSCPF[nX,8] + aINSSCPF[nX,10]) <> (aINSSCPF[nX,9] + aINSSCPF[nX,11])) //INSS Folha + 13 Calculados pelo RET divergente de INSS + 13 Descontados pelo RET
		oRespRET["divergent"]	:=	"true"
		lDiverg := .T.
	Else
		oRespRET["divergent"]	:=	""
	EndIf

	GrvItRes( @oHashRET, oRespRET:ToJson(), StrZero( nSeq, 6 ), lDiverg, "2", aINSSCPF[nX,1], cTicket, "1")

	nSeq ++
Next Nx

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} fGrvRU4
@type			function
@description	Grava a tabela RU4 ao iniciar a requisição.
@author			lidio.oliveira
@since			08/08/2023
/*/
//---------------------------------------------------------------------
Function fGrvRU4(cTicket, cServ, cMetodo, dDateReq, cHoraReq, cStatus, cParams)

    Local aArea	    := GetArea()
    Local aAreaRU4  := RU4->(GetArea())
    Local lNovo 	:= .T.

    //Trava o registro na SRD para edição
    dbSelectArea("RU4")
    RU4->( dbSetOrder(1) ) //Ordem 1 - RU4_FILIAL+RU4_ID
    lNovo := RU4->( !dbSeek( xfilial("RU4") + cTicket))

    If RU4->( RecLock("RU4", lNovo) )
        If lNovo
            RU4->RU4_FILIAL	:= xFilial("RU4")
            RU4->RU4_ID    	:= cTicket
            RU4->RU4_SERVIC := cServ
            RU4->RU4_METODO	:= cMetodo
            RU4->RU4_DTREQ 	:= dDateReq
            RU4->RU4_HRREQ  := cHoraReq
            RU4->RU4_STATUS := cStatus
            RU4->RU4_PARAMS	:= cParams
        EndIf

		//Libera o registro da RU4
        RU4->( MsUnlock() )
    EndIf

    RestArea(aAreaRU4)
    RestArea(aArea)

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} CheckDiv
@type			Static function
@description	Função para verificar se existe uma divergência ou não no relatório
@author			lidio.oliveira
@since			09/08/2023
@param			cResponse	 -	RU5->RU5_RESP
@return			lRet	-	.T. = Existe Divergência no relatório, .F. = Não existe divergência no relatório
/*/
//---------------------------------------------------------------------
Static Function CheckDiv(cResponse)

	Local lRet := .F.
	Local aValores
	Local nCont
	Local aAux

	aValores := StrTokArr( StrTran( StrTran( StrTran( StrTran( StrTran( StrTran( RU5->RU5_RESP, '"basis":', ""), "]", ""), "[", ""),'"', "") , "{", ""), "}", ""), "," )

	For nCont := 1  To Len(aValores)
		aAux := StrTokArr(aValores[nCont], ":")
		If Len(aAux) > 1
			xValor := aAux[2]
			If !(xValor == "0" .Or. Empty(xValor))
				lRet := .T.
				Exit
			EndIf
		EndIf
	Next nCont

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} HasNextTab
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados.
@author			lidio.oliveira
@since			08/08/2023
@param			cRequestID	-	Identificador da Requisição
@param			nRegFim		-	Identificador do último registro retornado
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
@param			lDiverg		-	Indica se é para filtrar somente os registros com diverências
/*/
//---------------------------------------------------------------------
Static Function HasNextTab(cRequestID, nRegFim, lDiverg, cCPF, lRETValues)

	Local cWhere	:= ""
	Local cBanco	:= TcGetDb()
	Local cAliasMax	:= GetNextAlias()
	Local lHasNext	:= .F.

	If lDiverg
		cWhere := " RU5.RU5_DIVERG = '1' "
	Else
		cWhere := " RU5.RU5_DIVERG IN ('1', '2') "
	EndIf

	cWhere += " AND RU5.RU5_NIVEL = ' ' "

	cWhere	:= "%" + cWhere + "%"

	If cBanco != "OPENEDGE"
		BeginSQL Alias cAliasMax
			SELECT MAX(LINE_NUMBER) MAX_LINE FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) LINE_NUMBER
				FROM %table:RU5% RU5
				WHERE RU5.RU5_FILIAL = %xFilial:RU5%
					AND RU5.RU5_ID = %exp:cRequestID%
					AND RU5.RU5_TIPO = '2'
					AND %Exp:cWhere%
					AND RU5.%notdel%
			) TAB
		EndSQL

		( cAliasMax )->( DBGoTop() )

		If ( cAliasMax )->( !Eof() )
			If ( cAliasMax )->MAX_LINE > nRegFim
				lHasNext := .T.
			EndIf
		EndIf

		( cAliasMax )->( DBCloseArea() )
	EndIf

Return( lHasNext )


//---------------------------------------------------------------------
/*/{Protheus.doc} IRRFRetValues
@type			method
@description	Método para consultar resultado do relatório de conferência de IRRF.
@author			lidio.oliveira
@since			10/08/2023
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET IRRFRetValues QUERYPARAM companyId, requestId, level, synthetic, differencesOnly, warningsOnly, cpfNumber, page, pageSize WSRESTFUL GPEreportEsocialBaseConfer

Local oResponse		:=	Nil
Local cEmpRequest	:=	""
Local cFilRequest	:=	""
Local cRequestID	:=	""
Local clevel		:=	"0"
Local nPage			:=	1
Local nPageSize		:=	15
Local aCompany		:=	{}
Local lSynthetic	:=	.F.
Local lDiverg		:=	.F.
Local lWarning		:=  .F.
Local lRet			:=	.T.
Local cCPF			:=  ""

Private lGrvTab		:= ""

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:requestId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			lGrvTab := Len(FWTAMSX3("RU4_FILIAL")) > 0
			If lGrvTab
				If ValidID( self:requestId )
					cRequestID := self:requestId

					If self:differencesOnly <> Nil
						lDiverg := self:differencesOnly
					EndIf

					If self:warningsOnly <> Nil
						lWarning := self:warningsOnly
					EndIf

					If self:page <> Nil
						nPage := self:page
					EndIf

					If self:pageSize <> Nil
						nPageSize := self:pageSize
					EndIf

					If self:level <> Nil
						clevel := self:level
					EndIf

					If self:cpfNumber <> Nil
						cCPF := self:cpfNumber
					EndIf

					If clevel == "0"
						lSynthetic := .T.
					EndIf

					GetReport( @oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize, , cCPF, clevel, lWarning)

					self:SetResponse( oResponse:toJson() )
				Else
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe." ) )
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Ambiente desatualizado."),,, EncodeUTF8( "Aplique a última atualização da expedição contínua do RH. Para correta execução do relatório as tabelas RU4 e RU5 devem existir no ambiente.")  )
			EndIf
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


//-------------------------------------------------------------------
/*/{Protheus.doc} GetIRRFData
Escopo: IRRF
Prepara os dados filtrados no formato JSON para retornar ao front.
@author lidio.oliveira
@since 10/08/2023
/*/
//-------------------------------------------------------------------
Static Function GetIRRFData( oReq, cTicket )

Local oResponse		:=	JsonObject():New()
Local odemonstrative:=  JsonObject():New()
Local oemployees	:=  JsonObject():New()
Local oirrfRetention:=  JsonObject():New()
Local oTotIRRFRet	:=  JsonObject():New()
Local oTotIRRFComp	:=  JsonObject():New()
Local oTpsIRValues	:=  JsonObject():New()
Local oTpIRTot		:=  JsonObject():New()
Local oDescTotal 	:=  JsonObject():New()
Local oDescItems 	:=  JsonObject():New()
Local oTotDemonst	:=  JsonObject():New()
Local aArea			:=	GetArea()
Local ccpfNumber	:=  ""
Local cDemonst		:=  ""
Local cCPFBkp		:=  ""
Local cDescTpIr		:=  ""
Local nI			:=	0
Local nX			:=  0
Local nZ			:=  0
Local nQtdRegs		:=	0
Local nSeq			:=	0
Local nPerc			:=	0
Local nTotFunERP	:=  0
Local nTotFunRET	:=  0
Local nTotComERP	:=  0
Local nTotComRET	:=  0
Local nTotDComERP	:=  0
Local nTotDComRET	:=  0
Local nPosDescIr	:=  0
Local lDiverg		:=	.F.
Local lWarning		:=  .F.
Local aArqIRRF		:=  {}
Local aDemonst		:=  {}
Local aemployees	:=  {}
Local aIRRFRet		:=  {}
Local aTabIRRF		:=  {}
Local aDescItems	:=  {}
Local aListDemonst	:=  {}

//Carrega a tabela de incidências para irrf
fCarrTab( @aTabIRRF, "S138", , , xFilial("RCC"))

//Filtra os dados do IRRF
FilIRRFData( oReq, @aArqIRRF, cTicket )

nQtdRegs := Len( aArqIRRF ) + 1

//Monta o retorno para a API de IRRF
For nI := 1 to Len( aArqIRRF )
	oResponse := JsonObject():New()

	If Empty(ccpfNumber) .Or. ccpfNumber <> aArqIRRF[nI, 1]

		If ccpfNumber <> aArqIRRF[nI, 1] .And. nI > 1
			oemployees["demonstrative"]			:=	aDemonst

			oTotDemonst["demonstrative"]		:= aListDemonst
			oTotDemonst["typesIrrfValues"]		:= fSomaTpIRRF(aDemonst)
			oemployees["totalDemonstratives"]	:= oTotDemonst

			lDiverg	:= (nTotFunERP <> nTotFunRET)
			oTotIRRFRet["erpValue"]				:= nTotFunERP
			oTotIRRFRet["retValue"]				:= nTotFunRET

			oemployees["totalIrrfRetention"] 	:= oTotIRRFRet
			oemployees["divergent"]				:= If(lDiverg, .T., .F.)
			oemployees["warning"]				:= If(lWarning, .T., .F.)
			aAdd(aemployees, oemployees)

			oResponse["employees"] := aemployees

			nSeq ++
			GrvItRes(, oemployees:ToJson(), StrZero( nSeq, 6 ), lDiverg, "2", ccpfNumber, cTicket, "", .T.)
		EndIf

		//Zera variáveis
		nTotFunERP	:= 0
		nTotFunRET	:= 0
		lDiverg 	:= .F.
		aDemonst	:= {}
		aemployees	:= {}
		ccpfNumber	:= aArqIRRF[nI, 1]
		lWarning 	 := .F.
		aListDemonst := {}

		FreeObj( oResponse )
		FreeObj( oemployees )
		oResponse	:= JsonObject():New()
		oemployees	:= JsonObject():New()

		oemployees["cpfNumber"]				:=	aArqIRRF[nI, 1]
		oemployees["name"]					:=	alltrim(aArqIRRF[nI, 2])
		oemployees["period"]				:=	SUBSTR(aArqIRRF[nI, 3], 1, 4) + "-" + SUBSTR(aArqIRRF[nI, 3], 5, 2)
	EndIf

	If (Empty(cDemonst) .Or. cDemonst <> aArqIRRF[nI, 4] .Or. cCPFBkp <> aArqIRRF[nI, 1] )

		aIRRFRet := {}

		If cDemonst <> aArqIRRF[nI, 4] .Or. cCPFBkp <> aArqIRRF[nI, 1]
			cCPFBkp			:= aArqIRRF[nI, 1]
			FreeObj( odemonstrative )
			FreeObj( oirrfRetention )
			FreeObj( oTpsIRValues )
			odemonstrative 	:= JsonObject():New()
			oirrfRetention 	:= JsonObject():New()
			oTpsIRValues 	:= JsonObject():New()
		EndIf

		cDemonst := aArqIRRF[nI, 4]
		aAdd(aListDemonst , alltrim(cDemonst))
		odemonstrative["demonstrativeId"]	:=	alltrim(aArqIRRF[nI, 4])
		odemonstrative["category"]			:=	aArqIRRF[nI, 6]
		odemonstrative["referencePeriod"]	:=	SUBSTR(aArqIRRF[nI, 7], 1, 4) + "-" + SUBSTR(aArqIRRF[nI, 7], 5, 2)
		odemonstrative["origin"]			:=	aArqIRRF[nI, 8]
		odemonstrative["payday"]			:=	SUBSTR(aArqIRRF[nI, 5], 1, 4) + "-" + SUBSTR(aArqIRRF[nI, 5], 5, 2) + "-" + SUBSTR(aArqIRRF[nI, 5], 7, 2)

		oirrfRetention["erpValue"]			:= 	aArqIRRF[nI, 9]
		oirrfRetention["retValue"]			:=  aArqIRRF[nI, 10]

		//Valores totais do funcionário
		nTotFunERP += aArqIRRF[nI, 9]
		nTotFunRET += aArqIRRF[nI, 10]

		//Valores totais da empresa
		nTotComERP += aArqIRRF[nI, 9]
		nTotComRET += aArqIRRF[nI, 10]

		//Valores totais da empresa quando há divergência
		If aArqIRRF[nI, 9] <> aArqIRRF[nI, 10]
			nTotDComERP += aArqIRRF[nI, 9]
			nTotDComRET += aArqIRRF[nI, 10]
		EndIf

		//Varre a posição 11 do array que contém todas os valores por tipo de IRRF
		For nX := 1 To Len(aArqIRRF[nI, 11])

			aDescItems := {}

			//Consulta se há valor total preenchido
			If aArqIRRF[nI, 11, nX, 2] > 0 .Or. aArqIRRF[nI, 11, nX, 3] > 0

				cTipoIR := aArqIRRF[nI, 11, nX, 1]

				//Grava o valor total do tipo de rendimento
				oDescTotal["erpValue"]	:= aArqIRRF[nI, 11, nX, 2]
				oDescTotal["retValue"]	:= aArqIRRF[nI, 11, nX, 3]

				//Verifica o tamanho do array
				For nZ := 4 To Len(aArqIRRF[nI, 11, nX])
					cDescTpIr := ""

					//Executa apenas se o tipo específico possui valor
					If aArqIRRF[nI, 11, nX, Nz, 2] > 0 .Or. aArqIRRF[nI, 11, nX, Nz, 3] > 0

						//Caso os valores sejam diferentes marca como aviso
						If aArqIRRF[nI, 11, nX, Nz, 2] <> aArqIRRF[nI, 11, nX, Nz, 3]
							lWarning := .T.
						EndIf

						//Procura a descrição do tipo do IR
						nPosDescIr := aScan( aTabIRRF, {|x| alltrim(x[5]) == aArqIRRF[nI, 11, nX, nZ, 1]} )
						If nPosDescIr > 0
							cDescTpIr := EncodeUtf8(Alltrim(aTabIRRF[nPosDescIr, 6]))
						EndIf

						//Detalhamento do items dos tipos de IR
						oDescItems["type"]				:= aArqIRRF[nI, 11, nX, Nz, 1]
						oDescItems["descriptionType"]	:= cDescTpIr
						oDescItems["erpValue"]			:= aArqIRRF[nI, 11, nX, Nz, 2]
						oDescItems["retValue"]			:= aArqIRRF[nI, 11, nX, Nz, 3]

						//Guarda todos os items do tipo de IR
						aAdd(aDescItems, oDescItems)

						//Zero objeto de itens para o próximo tipo de IR
						FreeObj( oDescItems )
						oDescItems := JsonObject():New()
					EndIf
				Next Nz

				//Guarda os dados do total e dos itens
				oTpIRTot["total"]	:= oDescTotal
				oTpIRTot["items"]	:= aDescItems

				//Gurda os dados de tipos de IR
				oTpsIRValues[cTipoIR]	:= oTpIRTot

				//Zera os objetos de descrição de itens e totais
				FreeObj( oDescItems )
				FreeObj( oDescTotal )
				FreeObj( oTpIRTot )
				oDescItems := JsonObject():New()
				oDescTotal := JsonObject():New()
				oTpIRTot  := JsonObject():New()
			EndIf
		Next nX

		odemonstrative["typesIrrfValues"]	:=  oTpsIRValues
		odemonstrative["irrfRetention"]		:=	oirrfRetention
		aAdd(aDemonst, odemonstrative)
	EndIf
	nPerc ++
	SetPercent( cTicket, nPerc, nQtdRegs )
Next nI

//Finaliza o Json do último registro processado
If !Empty(ccpfNumber) .And. Len(aArqIRRF) > 0
	oemployees["demonstrative"]			:=	aDemonst

	oTotDemonst["demonstrative"]		:= aListDemonst
	oTotDemonst["typesIrrfValues"]		:= fSomaTpIRRF(aDemonst)
	oemployees["totalDemonstratives"]	:= oTotDemonst

	lDiverg	:= (nTotFunERP <> nTotFunRET)
	oTotIRRFRet["erpValue"]				:= nTotFunERP
	oTotIRRFRet["retValue"]				:= nTotFunRET

	oemployees["totalIrrfRetention"]	:= oTotIRRFRet
	oemployees["divergent"]				:= If(lDiverg, .T., .F.)
	oemployees["warning"]				:= If(lWarning, .T., .F.)
	aemployees	:= {}
	aAdd(aemployees, oemployees)

	oResponse["employees"] := aemployees

	nSeq ++
	GrvItRes(, oemployees:ToJson(), StrZero( nSeq, 6 ), lDiverg, "2", ccpfNumber, cTicket, "", .T., lWarning)

	nPerc ++
	SetPercent( cTicket, nPerc, nQtdRegs )
EndIf

//Se não encontrou os dados
If Len(aArqIRRF) == 0
	SetPercent( cTicket, 100, 100 )
Else
	//Grava a parte sintética (Total Empresa)
	oResponse := JsonObject():New()
	oTotIRRFComp["erpValue"] 		:= nTotComERP
	oTotIRRFComp["retValue"] 		:= nTotComRET
	oResponse["totalIRRFCompany"] 	:= oTotIRRFComp
	GrvItRes(, oResponse:ToJson(), "000001", .F., "1", "", cTicket, "0", .T.)

	//Grava a parte sintética (Total Empresa Somente divergência)
	FreeObj( oResponse )
	FreeObj( oTotIRRFComp )
	oResponse 		:= JsonObject():New()
	oTotIRRFComp 	:= JsonObject():New()
	oTotIRRFComp["erpValue"] 		:= nTotDComERP
	oTotIRRFComp["retValue"] 		:= nTotDComRET
	oResponse["totalIRRFCompany"] 	:= oTotIRRFComp
	GrvItRes(, oResponse:ToJson(), "000002", .T., "1", "", cTicket, "0", .T.)
EndIf

SetFinish( cTicket )

RestArea( aArea )

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} filIRRFData
@type			function
@description	Filtra os dados de acordo com os parametros recebidos.
@author			lidio.oliveira
@since			10/08/2023
/*/
//---------------------------------------------------------------------
Static Function filIRRFData(oReq, aIRRF, cTicket)

Local cNextAlias    := GetNextAlias()
Local cTipo			:= ""
Local cQry          := ""
Local cPeriodo		:= ""
Local cFilSel		:= ""
Local ccpfNumber	:= ""
Local cIncidIRRF	:= ""
Local cideDmd		:= ""
Local cEvento		:= ""
Local cTpIRRF		:= ""
Local ccpfOld		:= ""
Local nQtdRegs		:= 0
Local nItem         := 0
Local nI			:= 0
Local nJ			:= 0
Local nK			:= 0
Local nPos			:= 0
Local nPosIr		:= 0
Local nerpValue		:= 0
Local nRetValue		:= 0
Local lDeduz		:= .F.
Local aCategoria    := {}
Local aCPFs		    := {}
Local aFilial		:= {}
Local aGrpIRRF		:= fListIRRF()

//Indica os tipos onde as verbas são de provento, desta forma soma os tipos 1(Provento) e 3(Base Provento)
//e subtrai os códigos 2(Desconto) e 4(Base Desconto)
cProvento := "taxableIncome|nonTaxableIncome|taxableIncomeSuspended"

aFilial := LoadSM0BaseCNPJ()

For nI := 1 to Len( aFilial )
	If !Empty( cFilSel )
		cFilSel += ","
	EndIf

	cFilSel += "'" + aFilial[nI] + "'"
Next nI

cPeriodo    := oReq["paymentPeriod"]
aCategoria  := oReq["eSocialCategory"]
aCPFs		:= oReq["cpfNumber"]

cQry := "SELECT "
cQry += "   RJO.RJO_FILIAL, "
cQry += "    RJO.RJO_INDAPU INDAPU,  "
cQry += "    RJO.RJO_PERAPU PERAPU, "
cQry += "    RJO.RJO_INDDEC IND_DEC, "
cQry += "    RJO.RJO_CPF CPF, "
cQry += "    RJO.RJO_NOME NOME, "
cQry += "    RJO.RJO_MATRIC MATRICULA, "
cQry += "    RJO.RJO_CATEG CATEGORIA, "
cQry += "    RJO.RJO_TPINSC, "
cQry += "    RJO.RJO_NRINSC ESTAB, "
cQry += "    RJO.RJO_EVENTO, "
cQry += "    RJO.RJO_NATRUB NATUREZA, "
cQry += "    RJO.RJO_TPRUBR TP_RUBRICA, "
cQry += "    RJO.RJO_INCIRF INC_IRF, "
cQry += "    RJO.RJO_IDEDMD IDEDMD, "
cQry += "    RJO.RJO_DTPGTO DTPGTO, "
cQry += "    RJO.RJO_PERREF PERREF, "
cQry += "    RJO.RJO_TPIRRF TPIRRF, "
cQry += "    RJO.RJO_VALOR VALOR  "
cQry += "FROM  "+RetSqlName("RJO")+" RJO  "
cQry += "WHERE RJO.D_E_L_E_T_ = ' ' "
cQry += "    AND RJO_FILIAL IN ( " + cFilSel + " ) "
cQry += "    AND RJO_DTPGTO BETWEEN '" + oReq["paymentPeriod"]+ "01" + "' AND '" + DTOS(lastday(STOD(oReq["paymentPeriod"]+ "01"))) + "'  "

If !Empty(aCategoria)
    cQry += "    AND RJO_CATEG IN "+FormatIn(ArrayToStr(aCategoria),";")+"  "
EndIf

If !Empty(aCPFs)
    cQry += " AND RJO_CPF IN " + FormatIn(ArrayToStr(aCPFs),";")+" "
EndIf

cQry += "ORDER BY RJO.RJO_FILIAL,RJO.RJO_CPF,RJO.RJO_IDEDMD,RJO.RJO_EVENTO"

TCQUERY cQry NEW ALIAS (cNextAlias)

If (cNextAlias)->( !Eof() )
	( cNextAlias )->( DBEval( { || nQtdRegs ++ } ) )
EndIf

(cNextAlias)->( dbGoTop() )

While (cNextAlias)->( !Eof() )
    cEvento 	:= AllTrim( ( cNextAlias )->RJO_EVENTO )
    cTipo		:= AllTrim( (cNextAlias)->TP_RUBRICA )
	ccpfNumber	:= (cNextAlias)->CPF

	//Adiciona os tipos para o recibo e zera o array
	If !Empty(cideDmd) .And. (cideDmd <> (cNextAlias)->IDEDMD .Or. ccpfOld <> ccpfNumber)
		If Len(aIRRF) > 0
			nPos := aScan( aIRRF, {|x| x[1] + x[4] == ccpfOld + cideDmd} )
			If nPos > 0
				aIRRF[nPos, 11] := aGrpIRRF
			EndIf
		EndIf
		aGrpIRRF := fListIRRF()
	EndIf

    ccpfOld 	:= ccpfNumber
	cIncidIRRF	:= ""
	cideDmd		:= ""
	nerpValue	:= 0
	nPos		:= 0
	nRetValue	:= 0

    If cEvento $ "S-1200/S-2299/S-2399"
        cIncidIRRF	:=	AllTrim( (cNextAlias)->INC_IRF )
		If cIncidIRRF $ "31*32*33*34"
			nerpValue	:= If(cTipo $ "1*3", (cNextAlias)->VALOR * -1, (cNextAlias)->VALOR)
		Else
			nerpValue	:= 0
		EndIf
		cideDmd		:= (cNextAlias)->IDEDMD

		//Verifica se o recibo já está adicionado no array
		If Len(aIRRF) > 0
			nPos := aScan( aIRRF, {|x| x[1] + x[7] + x[4] == ccpfNumber + (cNextAlias)->PERAPU + (cNextAlias)->IDEDMD} )
		EndIf

		//Ajuste o Valor de IR
		If nPos > 0
			aIRRF[nPos, 9] := aIRRF[nPos, 9] + nerpValue
		Else
			//Adiciona o recibo num array
			aAdd( aIRRF, {ccpfNumber,; //1 - cpfNumber
			(cNextAlias)->NOME,; //2 - Nome do Funcionário
			oReq["paymentPeriod"],; //3 - Período de apuração
			(cNextAlias)->IDEDMD,; //4- IdeDmDev
			(cNextAlias)->DTPGTO,; //5 - Data de Pagamento
			(cNextAlias)->CATEGORIA,; //6 - Categoria
			(cNextAlias)->PERAPU,; //7 - Período de referência (O período de referência para os eventos "S-1200/S-2299/S-2399" é o (cNextAlias)->PERUAPU)
			cEvento,; //8 - Origem
			nerpValue,; //9 - Valor de IRRF Retido no ERP
			nRetValue,;   //10 - Valor de IRRF Retido no RET
			{}}) //11 - Array com os valores por tipo de IR
		EndIf
	 ElseIf cEvento == "S-5002"
		nRetValue	:= (cNextAlias)->VALOR
		cideDmd		:= (cNextAlias)->IDEDMD
		cIncidIRRF	:= AllTrim((cNextAlias)->TPIRRF)

		If cIncidIRRF $ "31*32*33*34"
			//Verifica se o recibo já está adicionado no array
			If Len(aIRRF) > 0
				nPos := aScan( aIRRF, {|x| x[1] + x[4] == ccpfNumber + (cNextAlias)->IDEDMD} )
			EndIf

			//Ajuste o Valor de IR
			If nPos > 0
				aIRRF[nPos, 10] := nRetValue
			Else
				//Adiciona o recibo num array
				aAdd( aIRRF, {ccpfNumber,; //1 - cpfNumber
				(cNextAlias)->NOME,; //2 - Nome do Funcionário
				oReq["paymentPeriod"],; //3 - Período de apuração
				(cNextAlias)->IDEDMD,; //4- IdeDmDev
				(cNextAlias)->DTPGTO,; //5 - Data de Pagamento
				(cNextAlias)->CATEGORIA,; //6 - Categoria
				(cNextAlias)->PERREF,; //7 - Período de referência (O período de referência para os eventos "S-1200/S-2299/S-2399" é o (cNextAlias)->PERUAPU)
				"",; //8 - Origem
				nerpValue,; //9 - Valor de IRRF Retido no ERP
				nRetValue,;   //10 - Valor de IRRF Retido no RET
				{}}) //11 - Array com os valores por tipo de IR
			EndIf
		EndIf
    EndIf

	//Identifica qual é tipo de IR do registro processado
	For nI := 1 To Len(aGrpIRRF)
		For nJ := 4 To Len(aGrpIRRF[nI])
			cTpIRRF := ""
			For nK := 4 To Len(aGrpIRRF[Ni, nJ])
				nPosIr := aScan(aGrpIRRF[nI, nJ, nK], cIncidIRRF)
				If nPosIr > 0
					cTpIRRF := aGrpIRRF[nI, nJ, nK, nPosIr]
					//Adiciona valores para o tipo específico
					If cEvento $ "S-1200*S-2299*S-2399"
						//Verifica se deve deduzir o Valor
						If (aGrpIRRF[nI,1] $ cProvento .And. cTipo $ "2*4") .Or. (!(aGrpIRRF[nI,1] $ cProvento) .And. cTipo $ "1*3")
							lDeduz := .T.
						Else
							lDeduz := .F.
						EndIf
						aGrpIRRF[nI, nJ, 2] += If(lDeduz, (cNextAlias)->VALOR * -1, (cNextAlias)->VALOR)
					Elseif cEvento == "S-5002"
						aGrpIRRF[nI, nJ, 3] += (cNextAlias)->VALOR
					EndIf
					Exit
				EndIf
			Next nK
			If !Empty(cTpIRRF)
				//Adiciona nos valores totais
				If cEvento $ "S-1200*S-2299*S-2399"
					aGrpIRRF[nI, 2] += If(lDeduz, (cNextAlias)->VALOR * -1, (cNextAlias)->VALOR)
				Elseif cEvento == "S-5002"
					aGrpIRRF[nI, 3] += (cNextAlias)->VALOR
				EndIf
				Exit
			EndIf
		Next nJ
		If !Empty(cTpIRRF)
			Exit
		EndIf
	Next nI

	//Inclui dados do último registro
	If nPos > 0
		aIRRF[nPos, 11] := aGrpIRRF
	EndIf

	(cNextAlias)->(dbSkip())

    nItem++
    setPercent(cTicket, nItem, nQtdRegs)
EndDo

//Adiciona os tipos para o último recibo
If !Empty(cideDmd)
	If Len(aIRRF) > 0
		nPos := aScan( aIRRF, {|x| x[1] + x[4] == ccpfOld + cideDmd} )
		If nPos > 0
			aIRRF[nPos, 11] := aGrpIRRF
		EndIf
	EndIf
EndIf


If nItem == 0
	SetPercent( cTicket, 100, 100 )
EndIf

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} fListIRRF
@type			function
@description	Devolve um array com a lista de tipos de IRRF.
@author			lidio.oliveira
@since			20/12/2023
/*/
//---------------------------------------------------------------------
Static Function fListIRRF()

	Local aListIRRF := {}

	/*Estrutura do Array
		aGrpIRRF[X][1]: Nome da propriedade gerado no Json
		aGrpIRRF[X][2]: Valor Total ERP da propriedade
		aGrpIRRF[X][3]: Valor Total RET da propriedade
		aGrpIRRF[X][4]: Array com os tipos de IR
		aGrpIRRF[X][4][1]: Código do tipo de IR (Ex.: 11) (Alglutinador)
		aGrpIRRF[X][4][2]: Valor Total ERP do tipo de IR
		aGrpIRRF[X][4][3]: Valor Total RET do tipo de IR
		aGrpIRRF[X][4][4]: Array com os tipos de IR associados ao tipo Aglutinador
		aGrpIRRF[X][4][4][1]: Código X (Ex.: 11)
		aGrpIRRF[X][4][3][2]: Código Y (Ex.: 13)
	*/

	aAdd( aListIRRF, {"taxableIncome", 0, 0, {"11", 0, 0, {"11", "13"}}, {"12", 0, 0, {"12"}}, {"14", 0, 0 , {"14"}} } )
	aAdd( aListIRRF, {"nonTaxableIncome", 0, 0, {"70", 0, 0, {"70"}}, {"71", 0, 0, {"71"}}, {"72", 0, 0, {"72"}},;
	{"73", 0, 0, {"73"}}, {"74", 0, 0, {"74"}}, {"75", 0, 0, {"75"}}, {"76", 0, 0, {"76"}}, {"77", 0, 0, {"77"}},;
	{"700", 0, 0, {"700"}}, {"701", 0, 0, {"701"}}, {"79", 0, 0, {"79"}}, {"7900", 0, 0, {"7900","9","09"}} } )
	aAdd( aListIRRF, {"retention", 0, 0, {"31", 0, 0, {"31", "33"}}, {"32", 0, 0, {"32"}}, {"34", 0, 0, {"34"}} } )
	aAdd( aListIRRF, {"deductions", 0, 0, {"41", 0, 0, {"41","43"}}, {"42", 0, 0, {"42"}}, {"46", 0, 0, {"46","48"}},;
	{"47", 0, 0, {"47"}}, {"51", 0, 0, {"51","53"}}, {"52", 0, 0, {"52"}}, {"54", 0, 0, {"54"}}, {"61", 0, 0, {"61","66"}},;
	{"62", 0, 0, {"62"}}, {"63", 0, 0, {"63","65"}}, {"64", 0, 0, {"64"}}, {"67", 0, 0, {"67"}} } )
	aAdd( aListIRRF, {"taxableIncomeSuspended", 0, 0, {"9011", 0, 0, {"9011","9013"}}, {"9012", 0, 0, {"9012"}}, {"9014", 0, 0, {"9014"}} } )
	aAdd( aListIRRF, {"retentionSuspended", 0, 0, {"9031", 0, 0, {"9031","9033"}}, {"9032", 0, 0, {"9032"}}, {"9034", 0, 0, {"9034"}},;
	{"9831", 0, 0, {"9831","9833"}}, {"9832", 0, 0, {"9832"}}, {"9834", 0, 0, {"9834"}} } )
	aAdd( aListIRRF, {"deductionsSuspended", 0, 0, {"9041", 0, 0, {"9041", "9043"}}, {"9042", 0, 0, {"9042"}}, {"9046", 0, 0 , {"9046", "9048"}},;
	{"9047", 0, 0, {"9047"}}, {"9051", 0, 0, {"9051", "9053"}}, {"9052", 0, 0, {"9052"}}, {"9054", 0, 0, {"9054"}}, {"9061", 0, 0, {"9061", "9066"}},;
	{"9062", 0, 0, {"9062"}}, {"9063", 0, 0, {"9063", "9065"}}, {"9064", 0, 0, {"9064"}}, {"9067", 0, 0, {"9067"}} } )
	aAdd( aListIRRF, {"judicialCompensation", 0, 0, {"9082", 0, 0, {"9082"}}, {"9083", 0, 0, {"9083"}} } )

Return aListIRRF


//------------------------------------------------------------------------
/*/{Protheus.doc} fSomaTpIRRF
@type			function
@description	Soma todos os tipos de IRRF dos recibos
@author			lidio.oliveira
@since			20/12/2023
@param			aRecibos	-	Arrays com os Recibos
@return			oRet		-	Objeto json com os tipos de IR Totalizados
/*/
//------------------------------------------------------------------------
Static Function fSomaTpIRRF(aRecibos)

	Local oRet		:= JsonObject():New()
	Local oDescItems:= JsonObject():New()
	Local oDescTotal:= JsonObject():New()
	Local oTpIRTot	:= JsonObject():New()
	Local cTiposIR	:= ""
	Local cType		:= ""
	Local cDescType	:= ""
	Local nX		:= 0
	Local nY		:= 0
	Local nz		:= 0
	Local nPos		:= 0
	Local nPosTp	:= 0
	Local nPosFunc	:= 0
	Local nTotErp	:= 0
	Local nTotRet	:= 0
	Local nVlrERP	:= 0
	Local nVlrRet	:= 0
	Local aTiposIR	:= {}
	Local aTpsFunc	:= {}
	Local aDescItems:= {}

	Default aRecibos := {}

	For nX := 1 To Len(aRecibos)
		If ValType(aRecibos[nX]) == "J" .And. aRecibos[nX]:hasProperty("typesIrrfValues")
			cTiposIR := ArrTokStr(aRecibos[nX]["typesIrrfValues"]:getNames())
			aTiposIR := StrTokArr( cTiposIR, "|" )
			For nY := 1 To Len(aTiposIR)
				nTotErp	:= aRecibos[nX]["typesIrrfValues"][aTiposIR[nY]]["total"]["erpValue"]
				nTotRet := aRecibos[nX]["typesIrrfValues"][aTiposIR[nY]]["total"]["retValue"]

				If Len(aTpsFunc) > 0
					nPosFunc := aScan(aTpsFunc, {|x| x[1] == aTiposIR[nY]})
				EndIf
				If nPosFunc > 0
					aTpsFunc[nPosFunc, 2] += nTotErp
					aTpsFunc[nPosFunc, 3] += nTotRet
				Else
					aAdd(aTpsFunc, {aTiposIR[nY], nTotErp, nTotRet, {}})
				EndIf

				For nZ := 1 To Len(aRecibos[nX]["typesIrrfValues"][aTiposIR[nY]]["items"])
					cType		:= aRecibos[nX]["typesIrrfValues"][aTiposIR[nY]]["items"][nZ]["type"]
					cDescType	:= aRecibos[nX]["typesIrrfValues"][aTiposIR[nY]]["items"][nZ]["descriptionType"]
					nVlrERP		:= aRecibos[nX]["typesIrrfValues"][aTiposIR[nY]]["items"][nZ]["erpValue"]
					nVlrRet		:= aRecibos[nX]["typesIrrfValues"][aTiposIR[nY]]["items"][nZ]["retValue"]

					nPos := aScan(aTpsFunc, {|x| x[1] == aTiposIR[nY]})
					If Len(aTpsFunc[nPos, 4]) > 0
						nPosTp := aScan(aTpsFunc[nPos, 4], {|x| x[1] == cType})
						If nPosTp > 0
							aTpsFunc[nPos, 4, nPosTp, 3] += nVlrERP
							aTpsFunc[nPos, 4, nPosTp, 4] += nVlrRet
						else
							aAdd(aTpsFunc[nPos, 4], {cType, cDescType, nVlrERP, nVlrRet})
						EndIf
					Else
						aAdd(aTpsFunc[nPos, 4], {cType, cDescType, nVlrERP, nVlrRet})
					EndIf
				Next Nz
			Next nY
		EndIf
	Next nX

	For nY := 1 To Len(aTpsFunc)
		//Grava o valor total do tipo de rendimento
		oDescTotal["erpValue"]	:= aTpsFunc[nY][2]
		oDescTotal["retValue"]	:= aTpsFunc[nY][3]

		For nX := 1 To Len(aTpsFunc[nY][4])
			//Detalhamento do items dos tipos de IR
			oDescItems["type"]				:= aTpsFunc[nY][4][nX][1]
			oDescItems["descriptionType"]	:= aTpsFunc[nY][4][nX][2]
			oDescItems["erpValue"]			:= aTpsFunc[nY][4][nX][3]
			oDescItems["retValue"]			:= aTpsFunc[nY][4][nX][4]

			//Guarda todos os items do tipo de IR
			aAdd(aDescItems, oDescItems)

			//Zero objeto de itens para o próximo tipo de IR
			FreeObj( oDescItems )
			oDescItems := JsonObject():New()
		Next nX

		//Guarda os dados do total e dos itens
		oTpIRTot["total"]	:= oDescTotal
		oTpIRTot["items"]	:= aDescItems

		//Guarda os dados de tipos de IR
		oRet[aTpsFunc[nY][1]]	:= oTpIRTot

		//Zero objeto de itens para o próximo tipo de IR
		FreeObj( oDescTotal )
		FreeObj( oTpIRTot )
		oDescTotal	:= JsonObject():New()
		oTpIRTot	:= JsonObject():New()
		aDescItems	:= {}
	Next nY

Return oRet
