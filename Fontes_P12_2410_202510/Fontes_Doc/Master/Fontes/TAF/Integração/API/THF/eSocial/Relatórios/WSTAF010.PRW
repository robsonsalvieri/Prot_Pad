#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE HASH_BASE_RECIBO_TRANSMISSAO			01
#DEFINE HASH_BASE_ESTABELECIMENTO				02
#DEFINE HASH_BASE_CPF							03
#DEFINE HASH_BASE_NOME							04
#DEFINE HASH_BASE_MATRICULA						05
#DEFINE HASH_BASE_CATEGORIA						06
#DEFINE HASH_BASE_LOTACAO						07
#DEFINE HASH_BASE_EVENTO_ESOCIAL				08
#DEFINE HASH_BASE_FOLHA_BASE_FGTS				09
#DEFINE HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO	10
#DEFINE HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO	11
#DEFINE HASH_BASE_TAF_BASE_FGTS					12
#DEFINE HASH_BASE_TAF_BASE_FGTS_13_SALARIO		13
#DEFINE HASH_BASE_TAF_BASE_FGTS_RESCISORIO		14
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS				15
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO	16
#DEFINE HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO	17
#DEFINE HASH_BASE_GOVERNO_LOCALIZADO			18

#DEFINE HASH_DEPOSITO_RECIBO_TRANSMISSAO				01
#DEFINE HASH_DEPOSITO_CPF								02
#DEFINE HASH_DEPOSITO_NOME								03
#DEFINE HASH_DEPOSITO_MATRICULA							04
#DEFINE HASH_DEPOSITO_CATEGORIA							05
#DEFINE HASH_DEPOSITO_EVENTO_ESOCIAL					06
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS				07
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO	08
#DEFINE HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO	09
#DEFINE HASH_DEPOSITO_TAF_DEPOSITO_FGTS					10
#DEFINE HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO		11
#DEFINE HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO		12
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS				13
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO	14
#DEFINE HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO	15
#DEFINE HASH_DEPOSITO_GOVERNO_LOCALIZADO				16
#DEFINE HASH_TOTAL_DEPOSITO_FOLHA_DEPOSITO_FGTS			17
#DEFINE HASH_TOTAL_DEPOSITO_TAF_DEPOSITO_FGTS			18
#DEFINE HASH_TOTAL_DEPOSITO_GOVERNO_DEPOSITO_FGTS		19
#DEFINE HASH_DEPOSITO_FGTS_ECONSIGNADO					20

#DEFINE HASH_DESCONTO_RECIBO_TRANSMISSAO				01
#DEFINE HASH_DESCONTO_ESTABELECIMENTO					02
#DEFINE HASH_DESCONTO_CPF								03
#DEFINE HASH_DESCONTO_NOME								04
#DEFINE HASH_DESCONTO_MATRICULA							05
#DEFINE HASH_DESCONTO_CATEGORIA							06
#DEFINE HASH_DESCONTO_LOTACAO							07
#DEFINE HASH_DESCONTO_EVENTO_ESOCIAL					08
#DEFINE HASH_DESCONTO_NUMERO_CONTRATO					09 
#DEFINE HASH_DESCONTO_INSTITUICAO_FINANCEIRA			10
#DEFINE HASH_DESCONTO_FOLHA_DEPOSITO_CONSIGNADO			11                    
#DEFINE HASH_DESCONTO_TAF_DEPOSITO_CONSIGNADO			12                    
#DEFINE HASH_DESCONTO_GOVERNO_DEPOSITO_CONSIGNADO		13                   
#DEFINE HASH_DESCONTO_DIVERGENCIA_CONSIGNADO			14
#DEFINE HASH_DESCONTO_FGTS_ECONSIGNADO					15
#DEFINE HASH_DESCONTO_GOVERNO_LOCALIZADO				16   

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
#DEFINE TAF_BASE_INSS									17
#DEFINE TAF_VALOR_INSS									18
#DEFINE TAF_VALOR_SALARIO_FAMILIA						19
#DEFINE TAF_VALOR_SALARIO_MATERNIDADE					20
#DEFINE TAF_BASE_INSS_13_SALARIO						21
#DEFINE TAF_VALOR_INSS_13_SALARIO						22
#DEFINE TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO		23
#DEFINE GOVERNO_BASE_INSS								24
#DEFINE GOVERNO_VALOR_INSS								25
#DEFINE GOVERNO_VALOR_SALARIO_FAMILIA					26
#DEFINE GOVERNO_VALOR_SALARIO_MATERNIDADE				27
#DEFINE GOVERNO_BASE_INSS_13_SALARIO					28
#DEFINE GOVERNO_VALOR_INSS_13_SALARIO					29
#DEFINE GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO	30
#DEFINE OBSERVACAO										31
#DEFINE TIPO_FUNCIONARIO								32
#DEFINE GOVERNO_LOCALIZADO								33
#DEFINE GOVERNO_GROSS_VALUE								34
#DEFINE GOVERNO_DESC_GROSS_VALUE						35
#DEFINE GOVERNO_13_GROSS_VALUE							36
#DEFINE GOVERNO_13_DESC_GROSS_VALUE						37
#DEFINE CAT_DESCRI										38
#DEFINE GOVERNO_BASE_SUSPENSAO                          39
#DEFINE GOVERNO_BASE_TOTAL_INSS                         40
#DEFINE TAF_VALOR_BASE_PISPASEP                         41
#DEFINE FOLHA_VALOR_BASE_PISPASEP                       42
#DEFINE GOVERNO_VALOR_BASE_PISPASEP                     43
#DEFINE TAF_VALOR_BASE_PISPASEP_13                      44
#DEFINE FOLHA_VALOR_BASE_PISPASEP_13                    45
#DEFINE GOVERNO_VALOR_BASE_PISPASEP_13                  46

//---------------------------------------------------------------------
/*/{Protheus.doc} reportEsocialBaseConfer
@type			method
@description	Serviço dos Relatórios de Conferência do eSocial.
@author			Robson Santos
@since			15/08/2019
/*/
//---------------------------------------------------------------------

WSRESTFUL reportEsocialBaseConfer DESCRIPTION "Serviço dos Relatórios de Conferência do eSocial" FORMAT APPLICATION_JSON

	WSDATA companyId			AS STRING
	WSDATA requestId			AS STRING
	WSDATA paymentPeriod		AS STRING
	WSDATA level				AS STRING OPTIONAL
	WSDATA registrationNumber	AS STRING OPTIONAL
	WSDATA lotationCode			AS STRING OPTIONAL
	WSDATA eSocialCategory		AS STRING OPTIONAL
	WSDATA cpfNumber			AS STRING OPTIONAL
	WSDATA eSocialRegistration	AS STRING OPTIONAL
	WSDATA demonstrativeId	    AS STRING OPTIONAL
	WSDATA tribute				AS INTEGER
	WSDATA page					AS INTEGER OPTIONAL
	WSDATA pageSize				AS INTEGER OPTIONAL
	WSDATA synthetic			AS BOOLEAN OPTIONAL
	WSDATA differencesOnly		AS BOOLEAN OPTIONAL
    WSDATA warningsOnly			AS BOOLEAN OPTIONAL

	WSMETHOD POST;
		DESCRIPTION "Método para iniciar o processamento do relatório de conferência do eSocial";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/?{companyId}&{registrationNumber}&{lotationCode}&{eSocialCategory}&{cpfNumber}&{eSocialRegistration}&{paymentPeriod}&{tribute}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET Status;
		DESCRIPTION "Método para consultar o percentual de execução do relatório";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/Status/?{companyId}&{requestId}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/Status/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET InssValues;
		DESCRIPTION "Método para consultar resultado do relatório de conferência de INSS";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/InssValues/?{companyId}&{requestId}&{synthetic}&{differencesOnly}&{cpfNumber}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/InssValues/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET FgtsValues;
		DESCRIPTION "Método para consultar resultado do relatório de conferência de FGTS";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/FgtsValues/?{companyId}&{requestId}&{synthetic}&{differencesOnly}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/FgtsValues/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET InssRetValues;
		DESCRIPTION "Método para consultar os valores sintéticos do Relatório de conferência de INSS";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/InssRetValues/?{companyId}&{requestId}&{differencesOnly}&{synthetic}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/InssRetValues/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET IrrfRetValues;
		DESCRIPTION "Método para consultar os valores sintéticos do Relatório de conferência de Irrf";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/IrrfRetValues/?{companyId}&{requestId}&{differencesOnly}&{warningsOnly}&{synthetic}&{page}&{pageSize}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/IrrfRetValues/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET LegacyStatus;
		DESCRIPTION "Método para consultar o Status da API de valores das linhas";
		WSSYNTAX "api/rh/esocial/v1/reportEsocialBaseConfer/LegacyStatus/?{companyId}";
		PATH "api/rh/esocial/v1/reportEsocialBaseConfer/LegacyStatus/";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//---------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Método responsável por recepcionar os parâmetros e iniciar o processamento do relatório..
@author			Robson Santos
@since			15/08/2019
@return			Id. da resuisição: requestId (string)

- Inscrição Estabelecimento - registrationNumber (string)
- Código Lotação - lotationCode (string)
- Categoria eSocial - eSocialCategory (string)
- CPF - cpfNumber (string)
- Matrícula eSocial - eSocialRegistration (string)
- Período Folha (obrigatorio) - paymentPeriod (string)
- MMAAAA - mensal
- AAAA - anual

/*/
//---------------------------------------------------------------------
WSMETHOD POST WSRESTFUL reportEsocialBaseConfer

	Local lRet			as Logical
	Local cEmpRequest	as Character
	Local cFilRequest	as Character
	Local cRequestID	as Character
	Local aCompany		as Array
	Local oRequest		as Json
	Local oResponse		as Json

	oRequest    := JsonObject():New()
	oResponse   := Nil
	cEmpRequest := ""
	cFilRequest := ""
	cRequestID  := ""
	aCompany    := {}
	lRet        := .T.

	If Empty( self:GetContent() )

		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Corpo da requisição não enviado." ) )

	Else

		oRequest:FromJson( self:GetContent() )

		If Empty( oRequest["companyId"] )

			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )

		ElseIf Empty( oRequest["paymentPeriod"] )

			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'paymentPeriod'." ) )

		ElseIf Empty( oRequest["tribute"] )

			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Tributo não informado no parâmetro 'tribute'." ) )

		Else

			aCompany := StrTokArr( oRequest["companyId"], "|" )

			If Len( aCompany ) < 2

				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )

			Else

				cEmpRequest := aCompany[1]
				cFilRequest := aCompany[2]

				If PrepEnv( cEmpRequest, cFilRequest )

					cRequestID := GeraTicket( oRequest, self:GetContent() )

					If Empty( cRequestID )

						lRet := .F.
						SetRestFault( 400, EncodeUTF8( "Não foi possível gerar o ticket de processamento no Protheus." ) )

					Else

						//Inicia o processamento do relatório, antes de devolver o ticket da requisição
						StartJob( "TAFPRCCONF", GetEnvServer(), .F., cEmpRequest, cFilRequest, cRequestID )

						oResponse              := JsonObject():New()
						oResponse["requestId"] := cRequestID

						//Envia o ticket da requisição para o frontend
						self:SetResponse( oResponse:ToJson() )	

					EndIf

				Else

					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )

				EndIf

			EndIf

		EndIf

	EndIf

	FreeObj( oRequest )
	FreeObj( oResponse )

	DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} IrrfRetValues
@type			method
@description	Método para consultar os valores sintéticos do Relatório de conferência de INSS
@author			Alexandre Lima Santos / Fábio Mendonça
@since			
@return			lRet	-	Indica se o Método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET IrrfRetValues QUERYPARAM companyId, requestId, level, cpfNumber, differencesOnly, warningsOnly, page, pageSize, demonstrativeId WSRESTFUL reportEsocialBaseConfer

	Local lDiverg     as Logical
    Local lWarning    as Logical
	Local lRet        as Logical
	Local lIsLegacy   as Logical
	Local lSynthetic  as Logical
	Local nPage       as Numeric
	Local nPageSize   as Numeric
	Local cEmpRequest as Character
	Local cCPFNumber  as Character
	Local cFilRequest as Character
	Local cRequestID  as Character
	Local cPeriod     as Character
	Local cDMDEV      as Character
	Local aCompany    as Array
	Local aCPFCabec   as Array
	Local oResponse   as Object

	oResponse   := Nil
	cEmpRequest := ""
	cFilRequest := ""
	cRequestID  := ""
	cPeriod     := ""
	cCPFNumber	:= ""
	cDMDEV      := ""

	nPage       := 1
	nPageSize   := 15
    lWarning    := .F.
	lDiverg     := .F.

	lRet        := .T.
	lIsLegacy   := .F.
	lSynthetic  := .F.

	aCompany    := {}
	aCPFCabec   := {}

	If ::companyId == Nil

		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )

	ElseIf ::requestId == Nil

		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )

	ElseIf ::level == Nil

		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Nível de informação desejada não informada no parâmetro 'level'." ) )	

	Else

		aCompany := StrTokArr( ::companyId, "|" )

		If Len( aCompany ) < 2

			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )

		Else
			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )

				lIsLegacy := TAFAlsInDic( "V5H" ) .and. !Empty( AllTrim( GetNewPar( "MV_TAFRHUR", "" ) ) )

				If ValidID( ::requestId, @cPeriod, lIsLegacy, @aCPFCabec )
				
					cRequestID := ::requestId

					If ::level == "0"; lSynthetic := .T.; EndIf
					If ::differencesOnly != Nil; lDiverg := ::differencesOnly; EndIf
                    If ::warningsOnly != Nil; lWarning := ::warningsOnly; EndIf
					If ::page != Nil; nPage := ::page; EndIf
					If ::pageSize != Nil; nPageSize := ::pageSize; EndIf
					If ::cpfNumber != Nil; cCPFNumber := ::cpfNumber; EndIf
					If ::demonstrativeId != Nil; cDMDEV := ::demonstrativeId; EndIf 
					

					GetIrrfRet( @oResponse, cRequestID, lSynthetic, ::level, cCPFNumber, lDiverg, lWarning, nPage, nPageSize, cPeriod, lIsLegacy, ::companyId, aCPFCabec, cDMDEV )

					::SetResponse( oResponse:toJson() )

				Else

					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "A Identificação da Requisição '" + ::requestId + "' informado no parâmetro 'requestId' não existe." ) )
					
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
			EndIf
		EndIf
	EndIf

	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GeraTicket
@type			function
@description	Cria e armazena o ticket para a requisição.
@author			Robson Santos
@since			05/09/2019
@param			oRequest	-	Objeto da requisição
@param			cBody		-	Corpo da requisição com os parâmetros desejados
/*/
//---------------------------------------------------------------------
Static Function GeraTicket( oRequest as Json, cBody as Character ) as Character

	Local cServ		as Character
	Local cTicket	as Character
	Local oModelV3J	as Object

	oModelV3J := FWLoadModel( "TAFA531" )
	cTicket   := FWuuId( "WSTAF010" )
	cServ     := ""

	If oRequest["tribute"] == "1"

		cServ := "reportEsocialBaseConfer/InssRetValues"
		APILogAccess("ReportEsocialBaseConfer", "INSS")

	ElseIf oRequest["tribute"] == "2"

		cServ := "reportEsocialBaseConfer/FgtsValues"
		APILogAccess("ReportEsocialBaseConfer", "FGTS")

	ElseIf oRequest["tribute"] == "3"

		cServ := "reportEsocialBaseConfer/IrrfRetValues"
		APILogAccess("ReportEsocialBaseConfer", "IRRF")

	EndIf

	oModelV3J:SetOperation( MODEL_OPERATION_INSERT )
	oModelV3J:Activate()
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_ID"		, cTicket 						)
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_SERVIC"	, cServ 						)
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_METODO"	, "POST" 						)
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTREQ"	, Date() 						)
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRREQ"	, StrTran( Time(), ":", "" ) 	)
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_STATUS"	, "1" 							)
	oModelV3J:LoadValue( "MODEL_V3J", "V3J_PARAMS"	, cBody 						)

	FWFormCommit( oModelV3J )

	oModelV3J:DeActivate()
	oModelV3J:Destroy()

Return cTicket

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFPRCCONF
Processa a parte assincrona da requisição.

@author Robson Santos
@since 15/08/2019
/*/
//-------------------------------------------------------------------
Function TAFPRCCONF( cEmpRequest as Character, cFilRequest as Character, cTicket as Character ) as Logical

	Local lIsLegacy	as Logical
	Local lRet		as Logical
	Local cTribute	as Character
	Local cFilRH	as Character
	Local aHeader	as Array
	Local oRequest	as Object

	aHeader   := {}
	cTribute  := ""
	cFilRH    := ""
	lIsLegacy := .F.
	lRet      := .F.
	oRequest  := Nil

	RPCSetType( 3 )
	RPCSetEnv( cEmpRequest, cFilRequest,,, "TAF", "WSTAF010" )

	oRequest := JsonObject():New()

	V3J->(DbSetOrder(1))

	If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cTicket, TamSX3( "V3J_ID" )[1] ) ) )

		oRequest:FromJson( V3J->V3J_PARAMS )
		lIsLegacy := TAFAlsInDic( "V5H" ) .And. !Empty( AllTrim( GetNewPar( "MV_TAFRHUR", "" ) ) )

		//Antes de fazer o processamento dos dados, refaz os valores de RH da V3N com base no retorno da API
		If lIsLegacy

			aHeader		:=	Iif( !Empty( AllTrim( GetNewPar( "MV_TAFRHLG", "" ) ) ), GetHeader(), {} )
			cFilRH		:=	GetFilRH( aHeader )
			cTribute	:=	IIf( "inssretvalues" $ Lower( V3J->V3J_SERVICE ), "1", IIf( "irrfretvalues" $ Lower( V3J->V3J_SERVICE ), "3", "2" ) )

			TAFConOut( ProcName() + "RM SOLICITANDO INFO DE BASE" )
			TAFConOut( ProcName() + oRequest:ToJson() )

			GetRHValues( oRequest, oRequest["paymentPeriod"], cTribute, .T., V3J->V3J_ID, cFilRH, aHeader )

		EndIf

		If AllTrim( oRequest["tribute"] ) == "1"
			GetINSSVal( oRequest, cTicket, lIsLegacy )
		ElseIf AllTrim( oRequest["tribute"] ) == "2"
			GetFGTSData( oRequest, cTicket, lIsLegacy )
		ElseIf AllTrim( oRequest["tribute"] ) == "3"
			GetIrrfData( oRequest, cTicket, lIsLegacy, oRequest["eSocialCategory"] )
		EndIf

		lRet := .T.

	EndIf

	oRequest := Nil

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIrrfData
	Escopo: IRRF
	Prepara os dados filtrados no formato JSON para retornar ao front.

	@type  Static Function
	@author Alexandre de Lima Santos / Fábio Mendonça
	@since 01/08/2023
	@version 1.0
	@param oReq, 		json, 		array para dados filtrados
	@param cTicket, 	character, 	ticket gerado
	@param lIsLegacy, 	logical, 	param_descr
	@param aCateg , 	array, 	    param_descr
/*/
//---------------------------------------------------------------------
Static Function GetIrrfData( oReq as Json, cTicket as Character, lIsLegacy as Logical, aCateg as array )

	Local lDiverg			as Logical 
	Local lDivergTot		as Logical
    Local lWarning          as Logical
	Local lTransmitido		as Logical
	Local nI				as Numeric	
	Local aIRRFAna			as Array 
	Local aIRRFDivAna		as Array
	Local aIRRFSin			as Array
	Local aArqTrb			as Array
	Local aArea				as Array
	Local oArqTrb			as Object 

	Private oModelV3J		:=	FWLoadModel( "TAFA531" )
	Default aCateg := {}

	oArqTrb			:=	TAFXHMNew()
	nI				:=	1
	aIRRFSin		:=	{ 0, 0, 0 }
	aArqTrb			:=	{}
	aArea			:=	GetArea()
	lDiverg			:=	.F.
	lDivergTot		:=	.F.
	lTransmitido	:=	.F.

	// Filtra os dados do IRRF e gera objeto tHashMap com os dados
	FilIRRFRet( oReq, @oArqTrb, cTicket, lIsLegacy, aCateg )

	// Grava o conteúdo dos objetoS tHashMap em Arrays
	TAFXHMList( oArqTrb, aArqTrb )

	//Se não encontrou os dados
	If Len( aArqTrb ) == 0

		SetPercent( cTicket, 100, 100,,, .F. )

	Else

		//Monta o retorno da API de IRRF
		For nI := 1 to Len( aArqTrb )

			aIRRFAna	 :=	{ "", "", "", "", "", "", "", 0, 0, {}, 0, 0 ,.F.,{},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,.F.}
			aIRRFDivAna	 :=	{ "", "", "", "", "", "", "", 0, 0, {}, 0, 0 ,.F.}
			lTransmitido := (!Empty( aArqTrb[nI,2,1,12] ) )
			lDiverg      := .F.

			TafConOut(procname() + " lTransmitido: " + Iif( lTransmitido, "true", "false" ) + " CPF: " + aArqTrb[nI,2,1,1] )

			If lIsLegacy
				If aArqTrb[nI,2,1,8] != aArqTrb[nI,2,1,9] .OR. aArqTrb[nI,2,1,8] != aArqTrb[nI,2,1,11]
					lDiverg		:= .T.
				EndIf
			Else
				If aArqTrb[nI,2,1,8] != aArqTrb[nI,2,1,11]
					lDiverg		:= .T.
				EndIf
			EndIf

			If lDiverg

				aIRRFDivAna[8]	+=	aArqTrb[nI,2,1,8]
				aIRRFDivAna[9]  +=	aArqTrb[nI,2,1,9]
				aIRRFDivAna[11]	+=	aArqTrb[nI,2,1,11]			
				lDivergTot		:=	.T.

			EndIf

			lWarning := TafWarning( aArqTrb[nI,2,1,14], lIsLegacy)

			aIRRFAna[1]		:=	aArqTrb[nI,2,1,1]
			aIRRFAna[2]		:=	aArqTrb[nI,2,1,2]
			aIRRFAna[3]		:=	aArqTrb[nI,2,1,3]
			aIRRFAna[4]		:=	aArqTrb[nI,2,1,4]
			aIRRFAna[5]		:=	aArqTrb[nI,2,1,5]
			aIRRFAna[6]		:=	aArqTrb[nI,2,1,6]
			aIRRFAna[7]		:=	aArqTrb[nI,2,1,7]
			aIRRFAna[8]		+=	aArqTrb[nI,2,1,8]
			aIRRFAna[9]		+=	aArqTrb[nI,2,1,9]
			aIRRFAna[10]	:=	aArqTrb[nI,2,1,10]
			aIRRFAna[11]	+=	aArqTrb[nI,2,1,11]
			aIRRFAna[12]	:=	aArqTrb[nI,2,1,12]
			aIRRFAna[13]	:=	lDiverg
			aIRRFAna[14]	:=	aArqTrb[nI,2,1,14]
			aIRRFAna[15]	:=	aArqTrb[nI,2,1,15]
			aIRRFAna[16]	:=	aArqTrb[nI,2,1,16]
			aIRRFAna[17]	:=	aArqTrb[nI,2,1,17]
			aIRRFAna[18]	:=	aArqTrb[nI,2,1,18]
			aIRRFAna[19]	:=	aArqTrb[nI,2,1,19]
			aIRRFAna[20]	:=	aArqTrb[nI,2,1,20]
			aIRRFAna[21]	:=	aArqTrb[nI,2,1,21]
			aIRRFAna[22]	:=	aArqTrb[nI,2,1,22]
			aIRRFAna[23]	:=	aArqTrb[nI,2,1,23]
			aIRRFAna[24]	:=	aArqTrb[nI,2,1,24]
			aIRRFAna[25]	:=	aArqTrb[nI,2,1,25]
			aIRRFAna[26]	:=	aArqTrb[nI,2,1,26]
			aIRRFAna[27]	:=	aArqTrb[nI,2,1,27]
			aIRRFAna[28]	:=	aArqTrb[nI,2,1,28]
			aIRRFAna[29]	:=	aArqTrb[nI,2,1,29]
			aIRRFAna[30]	:=	aArqTrb[nI,2,1,30]
			aIRRFAna[31]    :=  lWarning

			// Soma Parte sintética 
			aIRRFSin[1] += aIRRFAna[8] 	// taf
			aIRRFSin[2] += aIRRFAna[9] 	// erp
			aIRRFSin[3] += aIRRFAna[11] // ret 

			//Grava a parte analítica
			TafConOut(procname() + " Antes GrvIRRFV45 0 Sintetico false: ")
			GrvIRRFV45( aIRRFAna, lDiverg,  nI, .F., lWarning )
			SetPercent( cTicket, nI, Len( aArqTrb ),,, .F. )

			If nI == Len( aArqTrb )

				// Grava a parte sintética
				TafConOut(procname() + " Antes GrvIRRFV45 1 Sintetico true: ")
				GrvIRRFV45( aIRRFSin, .F.,  nI, .T., .F. )

				TafConOut(procname() + " Antes GrvIRRFV45 2 Sintetico true: ")
				GrvIRRFV45( aIRRFSin, .T.,  ++nI, .T., .T. )

			EndIf 

		Next nI

	EndIf

	//Se não encontrou os dados
	If Len( aArqTrb ) == 0
		SetPercent( cTicket, 100, 100,,, .F. )
	Else
		// Grava a parte sintética
		GrvIRRFV45( aIRRFSin, .F.,  nI, .T., .F. )
		GrvIRRFV45( aIRRFSin, .T.,  ++nI, .T., .T. )
	EndIf

	SetFinish( cTicket )

	oModelV3J:Destroy()

	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GrvIRRFV45
	Grava a parte analítica do Relatório.

	@type  Static Function
	@author Alexandre de Lima Santos / Fábio Mendonça
	@since 01/08/2023
	@version 1.0
/*/
//---------------------------------------------------------------------
Static Function GrvIRRFV45( aIRRF as Array, lDivergTot as Logical, nSeq as Numeric, lSynthetic as Logical, lWarninTot as Logical)

	Local nI        as Numeric
	Local nX        as Numeric
	Local nTaftax   as Numeric
	Local nErpTax   as Numeric
	Local nRetTax   as Numeric
	Local nTafRet   as Numeric
	Local nErpRet   as Numeric
	Local nRetRet   as Numeric
	Local nTafNon   as Numeric
    Local nErpNon   as Numeric
    Local nRetNon   as Numeric
	Local nTafDed   as Numeric
    Local nErpDed   as Numeric
	Local nRetDed   as Numeric
	Local nTafComeSu as Numeric
	Local nErpComeSu as Numeric
	Local nRetComeSu as Numeric
	Local nTafDeducSup as Numeric
	Local nErpDeducSup as Numeric
	Local nRetDeducSup as Numeric
	Local nTafJudCom as Numeric
    Local nErpJudCom as Numeric
	Local nRetJudCom as Numeric
	Local nCount    as numeric
	Local nCalc     as numeric
	Local cCPF		as Character
	Local oResponse as Json
	
	oResponse	:= JsonObject():New()
	cCPF		:= ""

	If lSynthetic

		oResponse["totalIRRFCompany"]             := JsonObject():New()
		oResponse["totalIRRFCompany"]["tafValue"] := aIRRF[1]
		oResponse["totalIRRFCompany"]["erpValue"] := aIRRF[2]
		oResponse["totalIRRFCompany"]["retValue"] := aIRRF[3]

	Else

		cCPF                                        := aIRRF[1]
		oResponse["cpfNumber"]                      := cCPF
		oResponse["name"]                           := aIRRF[2]
		oResponse["period"]                         := aIRRF[3]
		oResponse["totalIrrfRetention"]             := JsonObject():New()
		oResponse["totalIrrfRetention"]["tafValue"] := aIRRF[8]
		oResponse["totalIrrfRetention"]["erpValue"] := aIRRF[9]
		oResponse["totalIrrfRetention"]["retValue"] := aIRRF[11]

		oResponse["demonstrative"] := {}

		For nI := 1 to Len( aIRRF[10] )
			
			aAdd(oResponse["demonstrative"], JsonObject():New())

			oResponse["demonstrative"][nI]["demonstrativeId"]           := AllTrim(aIRRF[10][nI][1])
			oResponse["demonstrative"][nI]["category"]                  := aIRRF[10][nI][8]
			oResponse["demonstrative"][nI]["referencePeriod"]           := IIF(empty(aIRRF[10][nI][6]), Transform(aIRRF[3], "@R 9999/99"),Transform(aIRRF[10][nI][6], "@R 9999/99"))
			oResponse["demonstrative"][nI]["origin"]                    := IIF(Empty(aIRRF[10][nI][7]), aIRRF[6], aIRRF[10][nI][7])
			oResponse["demonstrative"][nI]["payday"]                    := Transform(aIRRF[10][nI][5], "@R 9999-99-99")

			oResponse["demonstrative"][nI]["irrfRetention"]             := JsonObject():New()
			oResponse["demonstrative"][nI]["irrfRetention"]["tafValue"] := aIRRF[10][nI][2]
			oResponse["demonstrative"][nI]["irrfRetention"]["erpValue"] := aIRRF[10][nI][3]
			oResponse["demonstrative"][nI]["irrfRetention"]["retValue"] := aIRRF[10][nI][4]
			
			nTaftax := 0
			nErptax := 0
			nRettax := 0
			nTafRet := 0
			nErpRet := 0
			nRetRet := 0
			nTafNon := 0
			nErpNon := 0
			nRetNon := 0
			nTafDed := 0
			nErpDed := 0
			nRetDed := 0
			nTafComeSu := 0
			nErpComeSu := 0
			nRetComeSu := 0
			nTafRetSup := 0
			nErpRetSup := 0
			nRetRetSup := 0
			nTafDeducSup := 0
			nErpDeducSup := 0
			nRetDeducSup := 0
			nTafJudCom := 0
			nErpJudCom := 0
			nRetJudCom := 0
			nCalc      := 0

			For nX := 1 to Len( aIRRF[14] )
			
				If Alltrim( aIRRF[10][nI][1] ) == Alltrim( aIRRF[14][nX][6] )

					If !oResponse["demonstrative"][nI]:hasProperty("typesIrrfValues")
						oResponse["demonstrative"][nI]["typesIrrfValues"] := JsonObject():New()
					EndIf
					
					If  Alltrim(aIRRF[14][nX][1]) $ "11|12|14"
						
						nCount := 0

						If !oResponse["demonstrative"][nI]["typesIrrfValues"]:hasProperty("taxableIncome")
							
							oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]          := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["total"] := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["items"] := {}	
						EndIf

						nTaftax += aIRRF[14][nX][3]
						nErptax += aIRRF[14][nX][4]

						If aIRRF[14][nX][5] < 0
							nRettax += aIRRF[14][nX][5] * -1
							nCalc := aIRRF[14][nX][5] * -1
						Else
						    nRettax += aIRRF[14][nX][5]
							nCalc := aIRRF[14][nX][5]
						EndIf

						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["total"]["tafValue"] :=  nTaftax
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["total"]["erpValue"] :=  nErptax
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["total"]["retValue"] :=  nRettax
						
						aAdd(oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["items"], JsonObject():New())
						nCount := Len(oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["items"])
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["items"][nCount]["type"]     		   := aIRRF[14][nX][1]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["items"][nCount]["descriptionType"]     := EncodeUTF8( aIRRF[14][nX][2] )
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["items"][nCount]["tafValue"] 		   := aIRRF[14][nX][3] 
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["items"][nCount]["erpValue"]            := aIRRF[14][nX][4]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncome"]["items"][nCount]["retValue"]            := nCalc

					ElseIf Alltrim(aIRRF[14][nX][1]) $ "70|71|72|73|74|75|76|77|700|701|79|7900|702|703|704" .AND. !Alltrim(aIRRF[14][nX][1]) $ "00|7950"
						
						nCount := 0

						If !oResponse["demonstrative"][nI]["typesIrrfValues"]:hasProperty("nonTaxableIncome")
							//nonTaxableIncome
							oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]          := JsonObject():New()   		
							oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["total"] := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["items"] := {}
						EndIf

						nTafNon += aIRRF[14][nX][3]
						nErpNon += aIRRF[14][nX][4]

						If aIRRF[14][nX][5] < 0
							nRetNon += aIRRF[14][nX][5] * -1
							nCalc := aIRRF[14][nX][5] * -1
						Else
							nRetNon += aIRRF[14][nX][5]
							nCalc := aIRRF[14][nX][5]
						EndIf

						oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["total"]["tafValue"] := nTafNon
						oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["total"]["erpValue"] := nErpNon
						oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["total"]["retValue"] := nRetNon 

						aAdd(oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["items"], JsonObject():New())
						nCount := Len(oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["items"])
						oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["items"][nCount]["type"]     			  := aIRRF[14][nX][1]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["items"][nCount]["descriptionType"]     := EncodeUTF8( aIRRF[14][nX][2] )
						oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["items"][nCount]["tafValue"]            := aIRRF[14][nX][3] 
						oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["items"][nCount]["erpValue"]            := aIRRF[14][nX][4] 
						oResponse["demonstrative"][nI]["typesIrrfValues"]["nonTaxableIncome"]["items"][nCount]["retValue"]            := nCalc

					ElseIf Alltrim(aIRRF[14][nX][1]) $ "31|32|34"
						
						nCount := 0
						
						If !oResponse["demonstrative"][nI]["typesIrrfValues"]:hasProperty("retention")
							//retention
							oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]          := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["total"] := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["items"] := {}
						EndIf
						
						nTafRet += aIRRF[14][nX][3]
						nErpRet += aIRRF[14][nX][4]
						nRetRet += aIRRF[14][nX][5]

						oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["total"]["tafValue"] := nTafRet
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["total"]["erpValue"] := nErpRet
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["total"]["retValue"] := nRetRet

						aAdd(oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["items"], JsonObject():New())
						nCount := Len(oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["items"])
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["items"][nCount]["type"]                := aIRRF[14][nX][1]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["items"][nCount]["descriptionType"]     := EncodeUTF8( aIRRF[14][nX][2] )
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["items"][nCount]["tafValue"] 		   := aIRRF[14][nX][3]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["items"][nCount]["erpValue"]            := aIRRF[14][nX][4]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retention"]["items"][nCount]["retValue"]            := aIRRF[14][nX][5]
					
					ElseIf Alltrim(aIRRF[14][nX][1]) $ "41|42|46|47|51|52|54|61|62|63|64|67|68"
						
						nCount := 0

						If !oResponse["demonstrative"][nI]["typesIrrfValues"]:hasProperty("deductions")
							//deductions
							oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]          := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["total"] := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["items"] := {}
						EndIf
						
						nTafDed += aIRRF[14][nX][3] 
						nErpDed += aIRRF[14][nX][4]

						If aIRRF[14][nX][5] < 0
							nRetDed += aIRRF[14][nX][5] * -1 
							nCalc := aIRRF[14][nX][5] * -1 
						Else
							nRetDed += aIRRF[14][nX][5]
							nCalc := aIRRF[14][nX][5] 
						EndIf

						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["total"]["tafValue"] := nTafDed
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["total"]["erpValue"] := nErpDed
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["total"]["retValue"] := nRetDed

						aAdd(oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["items"], JsonObject():New())
						nCount := Len(oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["items"])
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["items"][nCount]["type"]                := aIRRF[14][nX][1]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["items"][nCount]["descriptionType"]     := EncodeUTF8( aIRRF[14][nX][2] )
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["items"][nCount]["tafValue"]            := aIRRF[14][nX][3]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["items"][nCount]["erpValue"]            := aIRRF[14][nX][4]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductions"]["items"][nCount]["retValue"]            := nCalc
					
					ElseIf Alltrim(aIRRF[14][nX][1]) $ "9011|9012|9014"
						
						nCount := 0

						If !oResponse["demonstrative"][nI]["typesIrrfValues"]:hasProperty("taxableIncomeSuspended")
					
							oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]          := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["total"] := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["items"] := {}
						EndIf

						nTafComeSu += aIRRF[14][nX][3]
						nErpComeSu += aIRRF[14][nX][4]
						nRetComeSu += aIRRF[14][nX][5]

						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["total"]["tafValue"] := nTafComeSu
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["total"]["erpValue"] := nErpComeSu
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["total"]["retValue"] := nRetComeSu

						aAdd(oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["items"], JsonObject():New())
						nCount := Len(oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["items"])
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nCount]["type"]                := aIRRF[14][nX][1]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nCount]["descriptionType"]     := EncodeUTF8( aIRRF[14][nX][2] )
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nCount]["tafValue"]            := aIRRF[14][nX][3]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nCount]["erpValue"]            := aIRRF[14][nX][4]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nCount]["retValue"]            := aIRRF[14][nX][5]
					
					ElseIf Alltrim(aIRRF[14][nX][1]) $ "9031|9032|9034|9831|9832|9834"
						
						nCount := 0

						If !oResponse["demonstrative"][nI]["typesIrrfValues"]:hasProperty("retentionSuspended")
							//retentionSuspended
							oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]          := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["total"] := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["items"] := {}
						EndIf

						nTafRetSup += aIRRF[14][nX][3]
						nErpRetSup += aIRRF[14][nX][4]
						nRetRetSup += aIRRF[14][nX][5]

						oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["total"]["tafValue"] := nTafRetSup
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["total"]["erpValue"] := nErpRetSup
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["total"]["retValue"] := nRetRetSup
					
						aAdd(oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["items"], JsonObject():New())
						nCount := Len(oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["items"])
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["items"][nCount]["type"]                := aIRRF[14][nX][1]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["items"][nCount]["descriptionType"]     := EncodeUTF8( aIRRF[14][nX][2] )
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["items"][nCount]["tafValue"]            := aIRRF[14][nX][3]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["items"][nCount]["erpValue"]            := aIRRF[14][nX][4]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["retentionSuspended"]["items"][nCount]["retValue"]            := aIRRF[14][nX][5]
					
					ElseIf alltrim(aIRRF[14][nX][1]) $ "9041|9042|9046|9047|9051|9052|9054|9061|9062|9063|9064|9067"
						
						nCount := 0

						If !oResponse["demonstrative"][nI]["typesIrrfValues"]:hasProperty("deductionsSuspended")
							//deductionsSuspended
							oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]          := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["total"] := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["items"] := {}
						EndIf

						nTafDeducSup += aIRRF[14][nX][3]
						nErpDeducSup += aIRRF[14][nX][4]
						nRetDeducSup += aIRRF[14][nX][5]

						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["total"]["tafValue"] := nTafDeducSup
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["total"]["erpValue"] := nErpDeducSup
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["total"]["retValue"] := nRetDeducSup

						aAdd(oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["items"], JsonObject():New())
						nCount := Len(oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["items"])
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["items"][nCount]["type"]                := aIRRF[14][nX][1]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["items"][nCount]["descriptionType"]     := EncodeUTF8( aIRRF[14][nX][2] )
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["items"][nCount]["tafValue"]            := aIRRF[14][nX][3]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["items"][nCount]["erpValue"]            := aIRRF[14][nX][4]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["deductionsSuspended"]["items"][nCount]["retValue"]            := aIRRF[14][nX][5]

					ElseIf Alltrim(aIRRF[14][nX][1]) $ "9082|9083"

						nCount := 0

						If !oResponse["demonstrative"][nI]["typesIrrfValues"]:hasProperty("judicialCompensation") 
							oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]          := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["total"] := JsonObject():New()
							oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["items"] := {}
						EndIf

						nTafJudCom += aIRRF[14][nX][3]
						nErpJudCom += aIRRF[14][nX][4]
						nRetJudCom += aIRRF[14][nX][5]

						oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["total"]["tafValue"] := nTafJudCom
						oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["total"]["erpValue"] := nErpJudCom
						oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["total"]["retValue"] := nRetJudCom

						aAdd(oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["items"], JsonObject():New())
						nCount := Len(oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["items"])
						oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["items"][nCount]["type"]            := aIRRF[14][nX][1]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["items"][nCount]["descriptionType"] := EncodeUTF8( aIRRF[14][nX][2] )
						oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["items"][nCount]["tafValue"]        := aIRRF[14][nX][3]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["items"][nCount]["erpValue"]        := aIRRF[14][nX][4]
						oResponse["demonstrative"][nI]["typesIrrfValues"]["judicialCompensation"]["items"][nCount]["retValue"]        := aIRRF[14][nX][5]

					EndIf
				EndIf

			Next nX
                
		Next nI
		GerLevel(@oResponse)
		oResponse["divergent"]                      := aIRRF[13]
		oResponse["warning"]                        := aIRRF[31]

	EndIf

	GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nSeq, 6 ), lDivergTot, IIf( lSynthetic, "1", "2" ), cCPF, lWarninTot )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FilIRRFRet
	Filtra os dados e carrega no objeto de armazenamento hash

	@type  Static Function
	@author Alexandre de Lima Santos / Fábio Mendonça
	@since 01/08/2023
	@version 1.0
		@param oReq,    	Json, 		Informações de filtro na Requisição
	@param oArqTrb, 	Object, 	Guarda valores do relatorio para serem add no objeto
	@param cTicket, 	character, 	ticket de Requisição
	@param lIsLegacy, 	logical, 	param_descr
/*/
//---------------------------------------------------------------------
Static Function FilIRRFRet( oReq as Json, oArqTrb as Object, cTicket as Character, lIsLegacy as Logical, aCateg as array )

	Local cAlias		as Character
	Local cLevel        as Character
	Local cLabel        as Character
	Local cIncidRRF     as Character
	Local cPeriodo      as Character
	Local cChar1        as Character
	Local cChar2        as Character
	Local cTipvlr       as Character
	Local cTpRubr       as Character
	Local cOrigem       as Character
	Local cNome         as Character
	Local cCpf          as Character   
	Local cCmatric      as Character 
	Local cDtPgto       as Character 
	Local cCateg        as Character  
	Local cPerref       as Character  
	Local cEvento       as Character  
	Local cIndapu       as Character
	Local cCrmen        as Character
	Local cNatureza     as Character
	Local nValor        as numeric
	Local aFiltro       as Array
	Local nQtdRegs		as Numeric
	Local nEmplTafValue as Numeric
	Local nEmplErpValue as Numeric
	Local nEmplRetValue as Numeric
	Local nDmTafVal     as Numeric
	Local nDmRetVal     as Numeric
	Local nDmErpVal     as Numeric
	Local nRegistro		as Numeric
	Local nItem       	as Numeric
	Local nTaxableTtt 	as numeric
	Local nOnTaxbleTtt 	as numeric
	Local nRetenTtt 	as numeric 
	Local nDeducTtt 	as numeric 
	Local nTaxSuspTtt 	as numeric 
	Local nRetSuspTtt 	as numeric 
	Local nDedSusTtt 	as numeric
	Local nJudCompTtt 	as numeric
	Local nTaxableTrR 	as numeric
	Local nOnTaxbleRrR 	as numeric
	Local nRetenTrR 	as numeric 
	Local nDeducTrR 	as numeric 
	Local nTaxSuspTrR 	as numeric 
	Local nRetSuspTrR 	as numeric 
	Local nDedSusTrR 	as numeric
	Local nJudCompTrR 	as numeric
	Local nVlIRRF       as numeric
	Local Nx            as numeric
	Local nA            as numeric
	Local aOrigem       as array
	Local lAdd			as Logical

	Default cPeriod 	:= ''
	Default aCateg      := {}

	cAlias			:= GetNextAlias()
	cPeriodo        := oReq["paymentPeriod"]
	cChar1          := ""
	cChar2          := ""
	cIndapu         := ""
	cCrmen          := ""
	aFiltro         := {}
	aOrigem         := {'4', '2'}
	nQtdRegs		:= 0
	nEmplTafValue 	:= 0
	nEmplErpValue 	:= 0
	nEmplRetValue 	:= 0
	nDmTafVal     	:= 0	
	nDmRetVal     	:= 0	
	nDmErpVal     	:= 0
	nRegistro		:= 0
	nItem       	:= 0
	nTaxableTtt 	:= 0
	nOnTaxbleTtt 	:= 0
	nRetenTtt 		:= 0 
	nDeducTtt 		:= 0 
	nTaxSuspTtt 	:= 0 
	nRetSuspTtt 	:= 0 
	nDedSusTtt 		:= 0
	nJudCompTtt 	:= 0
	nTaxableTrR 	:= 0
	nOnTaxbleRrR 	:= 0
	nRetenTrR 		:= 0 
	nDeducTrR 		:= 0 
	nTaxSuspTrR 	:= 0 
	nRetSuspTrR 	:= 0 
	nDedSusTrR 		:= 0
	nJudCompTrR 	:= 0
	nVlIRRF         := 0
	nX              := 0
	nA              := 0
	lAdd			:= .F.
	cLevel        	:= ""
	cTipvlr         := ""
    cTpRubr         := ""
	cOrigem			:= ""
	cNome           := ""
	cCpf            := ""
	cCmatric        := ""
	cDtPgto         := ""
	cCateg          := ""
	cPerref         := ""
	cOrigem         := "" 
	cPerapu         := ""
	cDmDev          := ""
	cRecibo         := ""
	nValor			:= 0
	cNatureza       := ""

	// Retorna as filiais do TAF referente a Matriz logada
	cFilSel := TAFCacheFil("V3N", FilMatriz(), .T.)

	// Faz consulta do banco

	nQtdRegs += IIf(TafColumnPos("V3N_CRMEN"),FilIRRFSynthetic(@cAlias, cFilSel, oReq, @aFiltro), 0)
	
	cLevel := oReq["level"] 

	If nQtdRegs > 0

		For nA := 1 to Len(aFiltro)
			
			cOrigem   := aFiltro[nA][14]
			cIncidRRF := IIf(cOrigem == '4', aFiltro[nA][21],aFiltro[nA][20])
			cTpRubr   := aFiltro[nA][17]
			cTipvlr   := IIf(cOrigem == '4', aFiltro[nA][21],aFiltro[nA][20])
			nValor    := aFiltro[nA][26]
			cIndapu   := aFiltro[nA][2]
			cCrmen    := aFiltro[nA][24]
			cNome     := aFiltro[nA][7]
			cCpf      := aFiltro[nA][6]
			cCmatric  := aFiltro[nA][8]
			cDtPgto   := aFiltro[nA][22]
			cCateg    := aFiltro[nA][9]
			cPerref   := aFiltro[nA][4]
			cEvento   := aFiltro[nA][13]
			cPerapu   := afiltro[nA][3]
			cDmDev    := afiltro[nA][18]
			cRecibo   := afiltro[nA][15]
			cNatureza := afiltro[nA][16]

			nRegistro++
			lAdd := CalcIRRFVal(aFiltro, @nEmplTafValue, @nEmplErpValue, @nDmTafVal, @nDmRetVal, @nDmErpVal, @nEmplRetValue, @cIncidRRF, @nVlIRRF,;
							@nTaxableTtt, @nOnTaxbleTtt, @nRetenTtt, @nDeducTtt, @nTaxSuspTtt, @nRetSuspTtt,  @nDedSusTtt, @nJudCompTtt,;
							@nTaxableTrR, @nOnTaxbleRrR, @nRetenTrR, @nDeducTrR, @nTaxSuspTrR, @nRetSuspTrR, @nDedSusTrR, @nJudCompTrR, @cLabel, cOrigem, cTpRubr, cTipvlr, nValor, cIndapu, cNatureza )
			TafConOut(procname() + " Apos CalcValor nRetValue: " + cValtoChar( 0 ) )
		

			If lAdd
				// Carrega o Hash
				LoadIRRFHash('SINTETICO',@cAlias, @oArqTrb, @nEmplTafValue, @nEmplErpValue, @nDmTafVal, @nDmRetVal, @nDmErpVal, @nEmplRetValue, cIncidRRF, @nVlIRRF,;
							@nTaxableTtt, @nOnTaxbleTtt, @nRetenTtt, @nDeducTtt, @nTaxSuspTtt, @nRetSuspTtt,  @nDedSusTtt, @nJudCompTrt, @nTaxableTrR, @nOnTaxbleRrR,; 
							@nRetenTrR, @nDeducTrR, @nTaxSuspTrR, @nRetSuspTrR, @nDedSusTrR, @nJudCompTrR, cCrmen, @cLabel, cNome, cCpf, cCmatric, cDtPgto, cCateg, cPerref,;
							cEvento, cOrigem, cPerapu, cDmDev, cRecibo, cTpRubr  )
				TafConOut(procname() + " Apos LoadHash nRetValue: " + cValtoChar( 0 ) )
			EndIf

			nItem++
			setPercent(cTicket, nItem, nQtdRegs,,, lIsLegacy)
			(cAlias)->( dbSkip() )
			

		Next nA
	EndIf
	

	If lIsLegacy .and. TAFColumnPos("V5H_DMDEV")
		HashLegacyIRFF( cTicket, oArqTrb, aCateg, nTaxableTtt, nOnTaxbleTtt, nRetenTtt, nDeducTtt, nTaxSuspTtt, nRetSuspTtt,  nDedSusTtt, nJudCompTtt )
	EndIf

	If nRegistro == 0
		setPercent( cTicket, 100, 100,,, lIsLegacy )
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FilIRRFSynthetic
	Grava a parte sintética do Relatório de IRRF.

	@type  Static Function
	@author Alexandre de Lima Santos / Fábio Mendonça
	@since 01/08/2023
	@version 1.0
	@param cAlias,  Character, alias temporario
	@param cFilSel, Character, lista de filiais
	@param oReq,    Json,      objeto para gravar os valores
/*/
//---------------------------------------------------------------------
Static Function FilIRRFSynthetic( cAlias as Character, cFilSel as Character, oReq as Json, aFiltro as Array) as Numeric
	
	Local aCategoria  as Array
	Local aFiliais    as Array
	Local aModoAcess  as Array
	Local aPeriodo    as Array
	Local aDmDev      as Array
	Local aSelect     as Array
	Local cBanco      as Character
	Local cColumnTemp as Character
	Local cJoinT2Q    as Character
	Local cPeriodo    as Character
	Local cPeriodo2   as Character
	Local cWhere1     as Character
	Local cWhere2     as Character
	Local cTpVlr      as Character
	Local lRetInss    as Logical
	Local nRet        as Numeric
	Local nA          as Numeric
	Local xCPFs       as Variant
	Local  cCpf        as Character
	
	Default cAlias  := GetNextAlias()
	Default cFilSel := ""
	Default oReq    := JsonObject():New()
	Default aFiltro := {}
	Default cOrigem := ""

	aCategoria  := IIf( oReq["eSocialCategory"] == Nil, {}, oReq["eSocialCategory"] )
	aFiliais    := {}
	aModoAcess  := {}
	aPeriodo    := {}
	aDmDev      := {}
	aSelect     := {}
	na := 0

	cBanco      := Upper( TcGetDb() )
	cColumnTemp := ""
	cJoinT2Q    := ""
	cPeriodo    := oReq["paymentPeriod"]
	cPeriodo2   := ""
	cWhere1     := ""
	cWhere2     := ""
	cTpVlr      := ""
	lRetInss    := IIf( FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F. )
	nRet        := 0
	xCPFs       := IIf( oReq["cpfNumber"] == Nil, {}, oReq["cpfNumber"] )
	cCpf        := ""

	cWhere1 += " T3P.T3P_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
	cWhere2 += " V3N.V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If !Empty( xCPFs )

		If ValType( xCPFs ) == 'C'

			cWhere1 += " AND T3P.T3P_CPF = '" + xCPFs + "' "
			cWhere2 += " AND V3N.V3N_CPF = '" + xCPFs + "' "

		Else

			cWhere1 += " AND T3P.T3P_CPF IN " + FormatIn( ArrayToStr( xCPFs ), ";" ) + " "
			cWhere2 += " AND V3N.V3N_CPF IN " + FormatIn( ArrayToStr( xCPFs ), ";" ) + " "

		EndIf
		
	EndIf

	If !Empty( aCategoria )
		cWhere2 += " AND V3N.V3N_CATEG IN " + FormatIn( ArrayToStr( aCategoria ), ";" ) + " "
	EndIf

	cWhere1 := "%" + cWhere1 + "%"    

	If Select( cAlias ) > 0
		( cAlias )->( dbCloseArea() )
	EndIf

	BeginSql Alias cAlias

		SELECT V6M.V6M_FILIAL, V6M.V6M_PERREF, V6M.V6M_VERSAO, V6M.V6M_INDDEV, V6M.V6M_ID, T3P.T3P_BENEFI
			FROM %Table:T3P% T3P
			INNER JOIN %Table:V6M% V6M
			ON V6M.V6M_ID = T3P.T3P_ID
			AND V6M.V6M_VERSAO = T3P.T3P_VERSAO
			AND V6M.%NotDel%
			WHERE %Exp:cWhere1%
			AND T3P.T3P_PERAPU = %Exp:cPeriodo%
			AND T3P.T3P_ATIVO = '1'
			AND ((V6M_TPPGTO = '1' )
			OR   (V6M_TPPGTO = '2' )
			OR   (V6M_TPPGTO = '3' )
			OR   (V6M_TPPGTO = '4' )
			OR   (V6M_TPPGTO = '5' ))
			AND T3P.%NotDel%
			GROUP BY V6M.V6M_FILIAL, V6M.V6M_PERREF, V6M.V6M_VERSAO, V6M.V6M_INDDEV, V6M.V6M_ID, T3P.T3P_BENEFI

	EndSql

	( cAlias )->( dbGoTop() )

	While ( cAlias )->( !Eof() )

		T3P->( DbSetOrder( 1 ) ) //T3P_FILIAL+T3P_ID+T3P_ATIVO
        If T3P->( MsSeek( xFilial( 'T3P', ( cAlias )->V6M_FILIAL  ) + ( cAlias )->V6M_ID + ( cAlias )->V6M_VERSAO  ) )
			

			If Empty(T3P->T3P_CPF)
				("C9V")->( DbSetOrder( 2 ) )
				If ("C9V")->( MsSeek( xFilial("C9V", ( cAlias )->V6M_FILIAL) + ( cAlias )->T3P_BENEFI + '1' ) )
					cCpf :=  C9V->C9V_CPF
				EndIf
			Else
				cCpf := T3P->T3P_CPF
			EndIf 
		EndIf

		If !Empty(aPeriodo)
			If aScan(aPeriodo,{|x| x[1] == ( cAlias )->V6M_PERREF .AND. x[2] == cCpf .AND. aLLTRIM(x[3]) == Alltrim(( cAlias )->V6M_INDDEV) }) == 0
				AaDD(aPeriodo,{ ( cAlias )->V6M_PERREF, cCpf, ( cAlias )->V6M_INDDEV })
			EndIf
		Else
			AaDD(aPeriodo,{ ( cAlias )->V6M_PERREF, cCpf, ( cAlias )->V6M_INDDEV })
		EndIf

		(cAlias)->(dbSkip())

	EndDo
    
	( cAlias )->( dbCloseArea() )

	cWhere2 += " AND V3N.V3N_PERAPU = '" + cPeriodo + "' "

	cWhere2 := "%" + cWhere2 + "%"  

	BeginSql Alias cAlias

		SELECT 
			V3N.V3N_FILIAL,
			V3N.V3N_INDAPU,
			V3N.V3N_PERAPU,
			V3N.V3N_PERREF,
			V3N.V3N_INDDEC,
			V3N.V3N_CPF,
			V3N.V3N_NOME,
			V3N.V3N_MATRIC,
			V3N.V3N_CATEG,
			V3N.V3N_TPINSC,
			V3N.V3N_NRINSC,
			V3N.V3N_CODLOT,
			V3N.V3N_EVENTO,
			V3N.V3N_ORIGEM,
			V3N.V3N_RECIBO,
			V3N.V3N_NATRUB,
			V3N.V3N_TPRUBR,
			V3N.V3N_DMDEV,
			V3N.V3N_ITCP,
			V3N.V3N_ITIRRF,
			V3N.V3N_TPVLR,
			V3N.V3N_DTPGTO,
			V3N.V3N_ID,
			V3N_CRMEN,
			0 AS T2O_VRCPSE,
			0 AS T2O_VRDESC,
			'' AS T2O_IDCODR,
			V3N.V3N_VALOR
		FROM %Table:V3N% V3N
		WHERE %Exp:cWhere2%
		AND ( V3N.V3N_INDAPU = '1' OR V3N.V3N_INDAPU = '2' ) 
		AND V3N.V3N_ORIGEM IN ('4')
		AND V3N.%NotDel%
		ORDER BY V3N.V3N_ORIGEM

	EndSql 

	TafConOut( procname() + GetLastQuery()[2] )

	( cAlias )->( dbGoTop() )

	While ( cAlias )->( !Eof() )

		cTpVlr := ( cAlias )->V3N_TPVLR

		If ALLTRIM(( cAlias )->V3N_TPVLR) == "11"
			cTpVlr := "11|13"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "9011"
			cTpVlr := "9011|9013"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "31"
			cTpVlr := "31|33"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "41"
		    cTpVlr := "41|43"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "46"
			cTpVlr := "46|48"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "51"
			cTpVlr := "51|53
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "61"
			cTpVlr := "61|66"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "63"
			cTpVlr := "63|65"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "9031"
			cTpVlr :="9031|9033"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "9831"
			cTpVlr := "9831|9833"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "9041"
			cTpVlr := "9041|9043"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "9046"
			cTpVlr := "9046|9048"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "9051"
			cTpVlr := "9051|9090"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "9061"
			cTpVlr := "9061|9066"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "9063"
			cTpVlr := "9063|9065"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "7900"
			cTpVlr := "09|7900"
		ElseIf Alltrim(( cAlias )->V3N_TPVLR) == "7950"
			cTpVlr := "00|7950"
		EndIf
		
		AaDD(aFiltro,{( cAlias )->V3N_FILIAL,;
			( cAlias )->V3N_INDAPU,;
			( cAlias )->V3N_PERAPU,;
			( cAlias )->V3N_PERREF,;
			( cAlias )->V3N_INDDEC,;
			( cAlias )->V3N_CPF,;
			( cAlias )->V3N_NOME,;
			( cAlias )->V3N_MATRIC,;
			( cAlias )->V3N_CATEG,;
			( cAlias )->V3N_TPINSC,;
			( cAlias )->V3N_NRINSC,;
			( cAlias )->V3N_CODLOT,;
			( cAlias )->V3N_EVENTO,;
			( cAlias )->V3N_ORIGEM,;
			( cAlias )->V3N_RECIBO,;
			( cAlias )->V3N_NATRUB,;
			( cAlias )->V3N_TPRUBR,;
			( cAlias )->V3N_DMDEV,;
			( cAlias )->V3N_ITCP,;
			( cAlias )->V3N_ITIRRF,;
			( cAlias )->V3N_TPVLR,;
			( cAlias )->V3N_DTPGTO,;
			( cAlias )->V3N_ID,;
			( cAlias )->V3N_CRMEN,; 
			cTpVlr,;
			( cAlias )->V3N_VALOR })

		(cAlias)->(dbSkip())

	EndDo
	//ate aqui ori 4
    For nA := 1 to Len(aPeriodo)
		
		cWhere2 := ""
		cWhere2 += " V3N.V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
		
		( cAlias )->( dbCloseArea() )

		cWhere2 += " AND V3N.V3N_PERAPU = '" + aPeriodo[nA][1]  + "' "
		cWhere2 += " AND V3N.V3N_CPF    = '" + aPeriodo[nA][2]  + "' "
		cWhere2 += " AND V3N.V3N_RECIBO = '" + aPeriodo[nA][3]  + "' "

		If !Empty( aCategoria )
			cWhere2 += " AND V3N.V3N_CATEG IN " + FormatIn( ArrayToStr( aCategoria ), ";" ) + " "
		EndIf
		
		cWhere2 := "%" + cWhere2 + "%"

		BeginSql Alias cAlias

			SELECT 
				V3N.V3N_FILIAL,
				V3N.V3N_INDAPU,
				V3N.V3N_PERAPU,
				V3N.V3N_PERREF,
				V3N.V3N_INDDEC,
				V3N.V3N_CPF,
				V3N.V3N_NOME,
				V3N.V3N_MATRIC,
				V3N.V3N_CATEG,
				V3N.V3N_TPINSC,
				V3N.V3N_NRINSC,
				V3N.V3N_CODLOT,
				V3N.V3N_EVENTO,
				V3N.V3N_ORIGEM,
				V3N.V3N_RECIBO,
				V3N.V3N_NATRUB,
				V3N.V3N_TPRUBR,
				V3N.V3N_DMDEV,
				V3N.V3N_ITCP,
				V3N.V3N_ITIRRF,
				V3N.V3N_TPVLR,
				V3N.V3N_DTPGTO,
				V3N.V3N_ID,
				V3N_CRMEN,
				0 AS T2O_VRCPSE,
				0 AS T2O_VRDESC,
				'' AS T2O_IDCODR,
				V3N.V3N_VALOR
			FROM %Table:V3N% V3N
			WHERE %Exp:cWhere2%
			AND ( V3N.V3N_INDAPU = '1' OR V3N.V3N_INDAPU = '2' ) 
			AND V3N.V3N_ORIGEM IN ('2')
			AND V3N.%NotDel%
			ORDER BY V3N.V3N_ORIGEM

		EndSql

		TafConOut( procname() + GetLastQuery()[2] )

		( cAlias )->( dbGoTop() )

		While ( cAlias )->( !Eof() )

			AaDD(aFiltro,{( cAlias )->V3N_FILIAL,;
			( cAlias )->V3N_INDAPU,;
			( cAlias )->V3N_PERAPU,;
			( cAlias )->V3N_PERREF,;
			( cAlias )->V3N_INDDEC,;
			( cAlias )->V3N_CPF,;
			( cAlias )->V3N_NOME,;
			( cAlias )->V3N_MATRIC,;
			( cAlias )->V3N_CATEG,;
			( cAlias )->V3N_TPINSC,;
			( cAlias )->V3N_NRINSC,;
			( cAlias )->V3N_CODLOT,;
			( cAlias )->V3N_EVENTO,;
			( cAlias )->V3N_ORIGEM,;
			( cAlias )->V3N_RECIBO,;
			( cAlias )->V3N_NATRUB,;
			( cAlias )->V3N_TPRUBR,;
			( cAlias )->V3N_DMDEV,;
			( cAlias )->V3N_ITCP,;
			( cAlias )->V3N_ITIRRF,;
			( cAlias )->V3N_TPVLR,;
			( cAlias )->V3N_DTPGTO,;
			( cAlias )->V3N_ID,;
			( cAlias )->V3N_CRMEN,; 
			"",;
			( cAlias )->V3N_VALOR })
			
			(cAlias)->(dbSkip())

		EndDo

	Next nA

	( cAlias )->( dbGoTop() )

Return Len(aFiltro)

//---------------------------------------------------------------------
/*/{Protheus.doc} CalcIRRFVal
	Atribui valor devido para as variáveis de controle

	@type  Static Function
	@author Alexandre de Lima Santos / Fábio Mendonça
	@since 01/08/2023
	@version 1.0
	@param cAlias               type character - alias temporario
	@param nEmplTafValue        type numeric   - Valores por funcionario na base do taf
    @param nEmplErpValue        type numeric   - Valores por funcionario na base das linhas
	@param nDmTafVal            type numeric   - Valores por demonstrativo na base do taf 
	@param nDmRetVal            type numeric   - valores por demostrativo na base do governo 
	@param nDmErpVal            type numeric   - Valores por demostrativo na base das linhas
	@param nEmplRetValue        type numeric   - valores por funcionario na base das linhas
/*/
//---------------------------------------------------------------------
Static Function CalcIRRFVal( aFilter as Array, nEmplTafValue as Numeric, nEmplErpValue as Numeric,  nDmTafVal as Numeric,;
							 nDmRetVal as Numeric, nDmErpVal as Numeric, nEmplRetValue as Numeric, cIncidRRF as Character, nVlIRRF as Numeric,;
							 nTaxableTtt as Numeric, nOnTaxbleTtt as Numeric, nRetenTtt as Numeric, nDeducTtt as Numeric, nTaxSuspTtt as Numeric, nRetSuspTtt as Numeric,  nDedSusTtt,;
							 nJudCompTtt as Numeric, nTaxableTrR as numeric, nOnTaxbleRrR as numeric, nRetenTrR as numeric, nDeducTrR as numeric ,nTaxSuspTrR as numeric, nRetSuspTrR as numeric, nDedSusTrR as numeric, nJudCompTrR as numeric, cLabel as character, cOrigem as Character,;
							 cTipo as character, cTipvlr as character, nValor as numeric, cIndapu as Character, cNatureza as Character ) as Logical

	Local lRet					as Logical
	
	Default nEmplTafValue   := 0 
    Default nEmplErpValue   := 0
	Default nDmTafVal       := 0 
	Default nDmRetVal       := 0
	Default nDmErpVal       := 0
	Default nEmplRetValue   := 0
	Default  nVlIRRF 	 	:= 0
	Default  nTaxableTtt 	:= 0
	Default  nOnTaxbleTtt 	:= 0
	Default  nRetenTtt 		:= 0
	Default  nDeducTtt 		:= 0
	Default  nTaxSuspTtt 	:= 0
	Default  nRetSuspTtt 	:= 0
	Default  nDedSusTtt 	:= 0 
	Default  nJudCompTtt 	:= 0
	Default  nTaxableTrR 	:= 0
	Default  nOnTaxbleRrR 	:= 0
	Default  nRetenTrR 		:= 0
	Default  nDeducTrR 		:= 0
	Default  nTaxSuspTrR 	:= 0
	Default  nRetSuspToR 	:= 0
	Default  nDedSusTrR 	:= 0 
	Default  nJudCompTrR 	:= 0
	Default cIncidRRF       := ""
	Default cLabel          := ""
	Default cTipo		    := ""
	Default cTipvlr         := ""
	DefaULT cIndapu         := ""
	Default aFilter         := {}
	Default cNatureza	    := ""

	lRet		:= .F.

	Do Case
	Case cOrigem $ "|2"

		If Alltrim(cIncidRRF) == "31" 
			
			cIncidRRF := "31"

		ElseIf Alltrim(cIncidRRF) $ "11|13"

			cIncidRRF := "11"

		ElseIf Alltrim(cIncidRRF) == "9013"

			cIncidRRF := "9013"

		ElseIf Alltrim(cIncidRRF) == "33"

			cIncidRRF := "33"

		ElseIf Alltrim(cIncidRRF) == "48" 
			
			cIncidRRF := "46"

		ElseIf Alltrim(cIncidRRF) == "53"

			cIncidRRF := "51"

		ElseIf Alltrim(cIncidRRF) == "66"
			
			cIncidRRF := "61"

		ElseIf Alltrim(cIncidRRF) == "65"
			
			cIncidRRF := "63"

		ElseIf Alltrim(cIncidRRF) == "9033"

			cTipoIRRF := "9031"

		ElseIf Alltrim(cIncidRRF) == "9833"
			
			cIncidRRF := "9831"

		ElseIf Alltrim(cIncidRRF) == "9043"

			cIncidRRF := "9041"

		ElseIf Alltrim(cIncidRRF) == "9048"

			cIncidRRF := "9046"

		ElseIf Alltrim(cIncidRRF) == "9053" 

			cIncidRRF := "9053"

		ElseIf Alltrim(cIncidRRF) == "9066"

			cIncidRRF := "9061"

		ElseIf Alltrim(cIncidRRF) == "9065"

			cIncidRRF := "9063"
		ElseIf Alltrim(cIncidRRF) == "00"

			cIncidRRF := "7950"

		ElseIf Alltrim(cIncidRRF) $ "9|09"

			cIncidRRF := "7900"

		ElseIf Alltrim(cIncidRRF) $ "41|43"

			cIncidRRF := "41"

		EndIf

		If cIndapu $ "1|2"

			If Alltrim(cIncidRRF) $ "31|32|33|34"

				If cTipo $ "2|4"

					nEmplTafValue 	:= nValor
					nEmplErpValue 	:= nValor
					nDmTafVal  		+= nValor
					nDmErpVal  		+= nValor
					lRet 			:= .T.

				ElseIf cTipo $ "1|3"

					nEmplTafValue := nValor * -1
					nEmplErpValue := nValor
					nDmTafVal 	  -= nValor
					nDmErpVal 	  -= nValor
					lRet          := .T.

				EndIf

			ElseIf Alltrim(cIncidRRF) $ "11|12|41|42|46|47|51|52|54|61|63|64|67|68|70|71|72|73|74|75|76|77|79|700|701|7900|7950|7951|7952|702|703|704"

				nDmTafVal  	    := 0
				nEmplTafValue 	+= 0
				lRet 			:= .T.

			ElseIf Alltrim(cIncidRRF) $ "7952|7953|7954|7955|7956|7957|7958|7959|7960|7961|7962|7963|7964|9011|9012|9014|9031|9032|9034|9831|9832|9834|9041|9042|9046|9047|9051|9052|9054|9061|9062|9063|9064|9067|9082|9083"
				
				nDmTafVal  		:= 0
				nEmplTafValue 	+= 0
				lRet 			:= .T.

			EndIF
			
			nVlIRRF := nValor
			rAnalitico(Alltrim(cIncidRRF), nVlIRRF, @nTaxableTtt, @nOnTaxbleTtt, @nRetenTtt, @nDeducTtt, @nTaxSuspTtt, @nRetSuspTtt, @nDedSusTtt, @nJudCompTtt, cOrigem, @nTaxableTrR, @nOnTaxbleRrR, @nRetenTrR, @nDeducTrR, @nTaxSuspTrR, @nRetSuspToR, @nDedSusTrR, @nJudCompTrR, @cLabel, cTipo )
		
			
		EndIf

	Case cOrigem $ "4"

		If Alltrim(cTipvlr) $ "31|32|34"
			
			nEmplRetValue := nValor
			lRet 		  := .T.

		ElseIf Alltrim(cTipvlr) $ "11|12|41|42|46|47|51|52|54|61|63|64|67|68|70|71|72|73|74|75|76|77|79|700|701|7900|7950|7951|7952|702|703|704"
			
			nEmplRetValue := 0
			lRet 		  := .T.

		ElseIf Alltrim(cTipvlr) $ "7952|7953|7954|7955|7956|7957|7958|7959|7960|7961|7962|7963|7964|9011|9012|9014|9031|9032|9034|9831|9832|9834|9041|9042|9046|9047|9051|9052|9054|9061|9062|9063|9064|9067|9082|9083"
			
			nEmplRetValue := 0
			lRet 		  := .T.

		EndIf
			
		If Alltrim(cTipvlr) $ "31|32|33|34"
			
			nDmRetVal += nValor
			lRet 	  := .T.

		ElseIf Alltrim(cTipvlr) $ "11|12|41|42|46|47|51|52|54|61|63|64|67|68|70|71|72|73|74|75|76|77|79|700|701|7900|7950|7951|7952|702|703|704"
			
			nDmRetVal += 0
			lRet 	  := .T.

		ElseIf Alltrim(cTipvlr) $ "7952|7953|7954|7955|7956|7957|7958|7959|7960|7961|7962|7963|7964|9011|9012|9014|9031|9032|9034|9831|9832|9834|9041|9042|9046|9047|9051|9052|9054|9061|9062|9063|9064|9067|9082|9083"
			
			nDmRetVal += 0
			lRet 	  := .T.

		EndIf

		nVlIRRF := nValor
		cIncidRRF := Alltrim( cTipvlr )
		rAnalitico(cIncidRRF, @nVlIRRF, @nTaxableTtt , @nOnTaxbleTtt, @nRetenTtt, @nDeducTtt, @nTaxSuspTtt, @nRetSuspTtt, @nDedSusTtt, @nJudCompTtt, cOrigem, @nTaxableTrR, @nOnTaxbleRrR, @nRetenTrR, @nDeducTrR, @nTaxSuspTrR, @nRetSuspToR, @nDedSusTrR, @nJudCompTrR, @cLabel )
	
		TafConOut(procname() + " Dentro CalcValor nRetValue: " + cValtoChar( 0 ) )
	
	OtherWise
		lRet := .F.
	EndCase

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadIRRFHash
	Carrega o hash de acodo com o arquivo de trabalho oArqTrb

	@type  Static Function
	@author Alexandre de Lima Santos / Fábio Mendonça
	@since 01/08/2023
	@version 1.0
	@param cTipo 				type character - relatorio se o relatorio é analitico ou sintetico
	@param cAlias 				type character - alias temporario
	@param oArqTrb 				type object    - Objeto com as informações do relatorio 
	@param nEmplTafValue        type numeric   - Valores por funcionario na base do taf
    @param nEmplErpValue        type numeric   - Valores por funcionario na base das linhas
	@param nDmTafVal            type numeric   - Valores por demonstrativo na base do taf 
	@param nDmRetVal            type numeric   - valores por demostrativo na base do governo 
	@param nDmErpVal            type numeric   - Valores por demostrativo na base das linhas
	@param nEmplRetValue        type numeric   - valores por funcionario na base das linhas
/*/
//---------------------------------------------------------------------
Static Function LoadIRRFHash( cTipo as Character, cAlias as Character, oArqTrb as Object, nEmplTafValue as Numeric,;
                               nEmplErpValue as Numeric, nDmTafVal as Numeric, nDmRetVal as Numeric, nDmErpVal as Numeric, nEmplRetValue as Numeric, cTypeIRRF as Character, nVlIRRF as Numeric,;
							   nTaxableTtt as Numeric, nOnTaxbleTtt as Numeric, nRetenTtt as Numeric, nDeducTtt as Numeric, nTaxSuspTtt as Numeric,;
							   nRetSuspTtt as Numeric,  nDedSusTtt as Numeric, nJudCompTtt as Numeric, nTaxableTrR as numeric, nOnTaxbleRrR as numeric, nRetenTrR as numeric, nDeducTrR as numeric ,;
							   nTaxSuspTrR as numeric, nRetSuspToR as numeric, nDedSusTrR as numeric, nJudCompTrR as numeric, cCrmen as character, cLabel as character, cNome as character , cCpf as character,;
							   cCmatric as character, cDtPgto as character, cCateg as character, cPerref as character, cEvento as character, cOrigem as character, cPerapu as character, cDmDev as character, cRecibo as character, cTpRubr as character ) as Object
							   
	Local aPos				as Array

    Default cLabel          := ""
	Default cTipo			:= ""
	Default cAlias			:= ""
	Default cTypeIRRF       := ""
	Default jDados			:= JsonObject():New()
	Default oArqTrb			:= Nil
	Default nEmplTafValue   := 0 
    Default nEmplErpValue   := 0
	Default nDmTafVal       := 0 
	Default nDmRetVal       := 0
	Default nDmErpVal       := 0
	Default nEmplRetValue   := 0
	Default  nVlIRRF 	 	:= 0
	Default  nTaxableTtt 	:= 0
	Default  nOnTaxbleTtt 	:= 0
	Default  nRetenTtt 		:= 0
	Default  nDeducTtt 		:= 0
	Default  nTaxSuspTtt 	:= 0
	Default  nRetSuspTtt 	:= 0
	Default  nDedSusTtt 	:= 0 
	Default  nJudCompTtt 	:= 0
    Default  nTaxableTrR 	:= 0
	Default  nOnTaxbleRrR 	:= 0
	Default  nRetenTrR 		:= 0
	Default  nDeducTrR 		:= 0
	Default  nTaxSuspTrR 	:= 0
	Default  nRetSuspToR 	:= 0
	Default  nDedSusTrR 	:= 0 
	Default  nJudCompTrR 	:= 0
	Default  cNome          := ""
    Default  cCpf           := ""
	Default  cCmatric       := ""
	Default  cDtPgto        := ""
	Default  cOrigem        := ""
	Default  cPerapu        := ""
	Default  cDmDev         := "" 
	Default  cRecibo        := ""
	Default  cEvento        := ""
	Default  cPerref        := ""
	Default  cCateg         := ""
	Default cTpRubr         := ""

	aPos		:= {}

	If cTipo == 'SINTETICO'

		If TAFXHMGet( oArqTrb, AllTrim( cCpf ), @aPos )
			
			aPos[1][1] := AllTrim( cCpf )
			
			aPos[1][3] := AllTrim( cPerapu 	)
			aPos[1][4] := AllTrim( cCateg  	)
			aPos[1][5] := AllTrim( cPerref	)
			aPos[1][6] := AllTrim( cEvento	)
			aPos[1][7] := AllTrim( cDtPgto	)

			Do Case	

				Case cOrigem == "2"

					aPos[1][8]	+=	nEmplTafValue	
					aPos[1][10]	:=	addDmDev( aPos[1][10], cRecibo, nDmTafVal, "cDmTafVal", cDtPgto, cPerref, AllTrim( cEvento ), cCateg )
					aPos[1][14]	:=	typesIrrf( aPos[1][14], cTypeIRRF, nVlIRRF, "cDmTafVal", cCrmen, cLabel, cRecibo,,'2', cTpRubr )
					aPos[1][15] :=  nTaxableTtt 
					aPos[1][16] :=  nOnTaxbleTtt
					aPos[1][17] :=  nRetenTtt
					aPos[1][18] :=  nDeducTtt 
					aPos[1][19] :=  nTaxSuspTtt
					aPos[1][20] :=  nRetSuspTtt
					aPos[1][21] :=  nDedSusTtt
					aPos[1][22] :=  nJudCompTtt
					
				Case cOrigem == "4"

					If Empty( aPos[1][2] )
						aPos[1][2] :=	EncodeUTF8( AllTrim( cNome ) )
					EndIf
					
					aPos[1][11]	+=	nEmplRetValue
					aPos[1][10]	:=	addDmDev( aPos[1][10], cDmDev, nDmRetVal, "cDmRetVal", cDtPgto, cPerref, AllTrim( cEvento ), cCateg )
					aPos[1][14]	:=	typesIrrf( aPos[1][14], cTypeIRRF, nVlIRRF, "cDmRetVal", cCrmen, cLabel, cDmDev,,'4')
					aPos[1][23] :=  nTaxableTrR
					aPos[1][24] :=  nOnTaxbleRrR
					aPos[1][25] :=  nRetenTrR
					aPos[1][26] :=  nDeducTrR
					aPos[1][27] :=  nTaxSuspTrR
					aPos[1][28] :=  nRetSuspToR
					aPos[1][29] :=  nDedSusTrR
					aPos[1][30] :=  nJudCompTrR

			EndCase

			aPos[1][12]		:= cRecibo

			TafConOut(procname() + " Dentro LoadHash ALTERA  CPF: " + aPos[1, 1] )
			TafConOut(procname() + " Dentro LoadHash altera valores" )

			TAFXHMSet( oArqTrb, aPos[1], aPos )

		Else

			aPos := IRRFInitArray()
			
			aPos[1] := AllTrim( cCpf )
			
			If Empty( aPos[2] )
				aPos[2] :=	EncodeUTF8( AllTrim( cNome ) )
			EndIf

			aPos[3] := AllTrim( cPerapu	)
			aPos[4] := AllTrim( cCateg	) 
			aPos[5] := AllTrim( cPerref )
			aPos[6] := AllTrim( cEvento	)
			aPos[7] := AllTrim( cDtPgto )

			Do Case
			
				Case cOrigem == "2"
					
					aPos[8]  += nEmplTafValue
					aPos[10] :=	addDmDev( aPos[10], cRecibo, nDmTafVal, "cDmTafVal", cDtPgto, cPerref, AllTrim( cEvento ), cCateg )
				    aPos[14] :=	typesIrrf( aPos[14], cTypeIRRF, nVlIRRF, "cDmTafVal", cCrmen, cLabel, cRecibo,,'2', cTpRubr )
					aPos[15] :=  nTaxableTtt
					aPos[16] :=  nOnTaxbleTtt
					aPos[17] :=  nRetenTtt
					aPos[18] :=  nDeducTtt
					aPos[19] :=  nTaxSuspTtt
					aPos[20] :=  nRetSuspTtt
					aPos[21] :=  nDedSusTtt
					aPos[22] :=  nJudCompTtt

				Case cOrigem == "4"

					If Empty( aPos[2] )
						aPos[2] :=	EncodeUTF8( AllTrim( cNome ) )
					EndIf
					
					aPos[11] +=	nEmplRetValue
					aPos[10] :=	addDmDev( aPos[10], cDmDev, nDmRetVal, "cDmRetVal", cDtPgto, cPerref, AllTrim( cEvento ), cCateg )
			        aPos[14] :=	typesIrrf( aPos[14], cTypeIRRF, nVlIRRF, "cDmRetVal", cCrmen, cLabel, cDmDev,,'4')
					aPos[23] :=  nTaxableTrR
					aPos[24] :=  nOnTaxbleRrR
					aPos[25] :=  nRetenTrR
					aPos[26] :=  nDeducTrR
					aPos[27] :=  nTaxSuspTrR
					aPos[28] :=  nRetSuspToR
					aPos[29] :=  nDedSusTrR
					aPos[30] :=  nJudCompTrR

			EndCase

			aPos[12]			:= cRecibo
			TAFXHMAdd( oArqTrb, aPos, 1, 3 )

		EndIf

		nEmplTafValue := 0
		nEmplErpValue := 0	
		nDmTafVal 	  := 0
		nDmErpVal 	  := 0
		nEmplRetValue := 0
		nDmRetVal     := 0

		aPos := {}
		FreeObj(aPos)

	EndIf

Return oArqTrb

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFGTSData
Escopo: FGTS
Prepara os dados filtrados no formato JSON para retornar ao front.

@author Robson Santos
@since 26/08/2019
/*/
//-------------------------------------------------------------------
Static Function GetFGTSData( oReq as Json, cTicket as Character, lIsLegacy as Logical )

	Local aArea       as Array
	Local aArqBase    as Array
	Local aArqDepo    as Array
	Local aArqDesc	  as Array
	Local aBaseDiverg as Array
	Local aBaseSint   as Array
	Local aDepoDiverg as Array
	Local aDepoSint   as Array
	Local aDescDiverg as Array
	Local aDescSint   as Array
	Local aEconsig    as Array
	Local aInfoEcons  as Array
	Local aResponse   as Array
	Local cChave      as Character
	Local cStatusGov  as Character
	Local lDiverg     as Logical
	Local lFim        as Logical
	Local nFuncDiverg as Numeric
	Local nFuncTotal  as Numeric
	Local nDescDiverg as Numeric
	Local nI          as Numeric
	Local nIni        as Numeric
	Local nPerc       as Numeric
	Local nPosBase    as Numeric
	Local nPosDesc    as Numeric
	Local nQtdRegs    as Numeric
	Local nQtdFgts	  as Numeric	
	Local nSeq        as Numeric
	Local nVlrGov     as Numeric
	Local nVlrRh      as Numeric
	Local nVlrTaf     as Numeric
	Local oHashBase   as Object
	Local oHashDepo   as Object
	Local oHashDesc	  as Object
	Local oResponse   as Object

	Local nRegProc    := 0
	Local nTotalReg   := 0

	Private oModelV3J	:=	FWLoadModel( "TAFA531" )

	aArea       := GetArea()
	aArqBase    := {}
	aArqDepo    := {}
	aArqDesc	:= {}
	aBaseDiverg := {"", "", 0 , 0 , 0, 0, 0, 0, 0, 0, 0}
	aBaseSint   := {"", "", 0 , 0 , 0, 0, 0, 0, 0, 0, 0}
	aDepoDiverg := {"", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	aDepoSint   := {"", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	aDescDiverg := {"", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	aDescSint   := {"", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	aEconsig	:= {}
	aInfoEcons	:= {}
	aResponse   := {}
	cChave      := ""
	cStatusGov  := ""
	lDiverg     := .F.
	lFim        := .F.
	nFuncDiverg := 0
	nFuncTotal  := 0
	nDescDiverg	:= 0
	nI          := 0
	nIni        := 0
	nPerc       := 0
	nPosBase    := 0
	nPosDesc    := 0
	nQtdRegs    := 0
	nQtdFgts	:= 0
	nSeq        := 0
	nVlrGov     := 0
	nVlrRh      := 0
	nVlrTaf     := 0
	oHashBase   := TAFXHMNew()
	oHashDepo   := TAFXHMNew()
	oHashDesc   := TAFXHMNew()
	oResponse   := Nil

	//Filtra os dados do FGTS e gera o hash
	FilFGTSData( oReq, @oHashBase, @oHashDepo, cTicket, lIsLegacy, @oHashDesc )

	//Grava o conteúdo dos hashs em arrays
	TAFXHMList( oHashBase, aArqBase )
	TAFXHMList( oHashDepo, aArqDepo )
	TAFXHMList( oHashDesc, aArqDesc )

	nTotalReg := Len(aArqBase) + Len(aArqDesc)

	//Monta o retorno para a API de FGTS
	For nI := 1 to Len( aArqDepo )

		oResponse := JsonObject():New()

		If Empty( aArqDepo[nI,2,1,HASH_DEPOSITO_RECIBO_TRANSMISSAO] )
			cStatusGov := "Não Transmitido"
		ElseIf !aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_LOCALIZADO]
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

		oResponse["fgtsTafValue"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]
		oResponse["fgts13TafValue"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]
		oResponse["fgtsRescissionTafValue"]	:=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]

		If Empty( cStatusGov )

			oResponse["fgtsRetValue"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]
			oResponse["fgts13RetValue"]			:=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]
			oResponse["fgtsRescissionRetValue"]	:=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]

		Else

			oResponse["fgtsRetValue"]			:=	0
			oResponse["fgts13RetValue"]			:=	0
			oResponse["fgtsRescissionRetValue"]	:=	0

		EndIf

		If TafColumnPos("V3N_CONSG")
			oResponse["fgtsEconsig"]	:=	aArqDepo[nI,2,1,HASH_DEPOSITO_FGTS_ECONSIGNADO]
		EndIf	

		aDepoSint[6]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]
		aDepoSint[7]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]
		aDepoSint[8]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]

		aDepoSint[9]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]
		aDepoSint[10]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]
		aDepoSint[11]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]

		If Empty( cStatusGov )

			aDepoSint[12]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]
			aDepoSint[13]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]
			aDepoSint[14]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]

		EndIf

        aDepoSint[15] += aArqDepo[nI,2,1,HASH_TOTAL_DEPOSITO_FOLHA_DEPOSITO_FGTS]
		aDepoSint[16] += aArqDepo[nI,2,1,HASH_TOTAL_DEPOSITO_TAF_DEPOSITO_FGTS]
		aDepoSint[17] += aArqDepo[nI,2,1,HASH_TOTAL_DEPOSITO_GOVERNO_DEPOSITO_FGTS]
		nFuncTotal ++

		lDiverg := .F.
		nVlrRh	:= aArqDepo[nI,2,1,HASH_TOTAL_DEPOSITO_FOLHA_DEPOSITO_FGTS] 
		nVlrTaf	:= aArqDepo[nI,2,1,HASH_TOTAL_DEPOSITO_TAF_DEPOSITO_FGTS]
		nVlrGov	:= aArqDepo[nI,2,1,HASH_TOTAL_DEPOSITO_GOVERNO_DEPOSITO_FGTS]

		If  !(nVlrRh == nVlrTaf .And. nVlrTaf == nVlrGov) .Or. ;
				!(aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO] == aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO] .And.;
				aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO] == aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO] )

			lDiverg		:=	.T.

			aDepoDiverg[6]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]
			aDepoDiverg[7]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]
			aDepoDiverg[8]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]

			aDepoDiverg[9]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]
			aDepoDiverg[10]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]
			aDepoDiverg[11]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]

			If Empty( cStatusGov )

				aDepoDiverg[12]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]
				aDepoDiverg[13]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]
				aDepoDiverg[14]	+=	aArqDepo[nI,2,1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]

			EndIf

			aDepoDiverg[15] += aArqDepo[nI,2,1,HASH_TOTAL_DEPOSITO_FOLHA_DEPOSITO_FGTS]
			aDepoDiverg[16] += aArqDepo[nI,2,1,HASH_TOTAL_DEPOSITO_TAF_DEPOSITO_FGTS]
			aDepoDiverg[17] += aArqDepo[nI,2,1,HASH_TOTAL_DEPOSITO_GOVERNO_DEPOSITO_FGTS]

			nFuncDiverg ++

		EndIf

		cChave := aArqDepo[nI,2,1,HASH_DEPOSITO_CPF] + aArqDepo[nI,2,1,HASH_DEPOSITO_CATEGORIA] + aArqDepo[nI,2,1,HASH_DEPOSITO_MATRICULA]

		lFim		:= .F.
		nIni		:= 1
		aResponse	:= {}

		While !lFim

			nPosBase := aScan( aArqBase, { |x| x[2,1,HASH_BASE_CPF] + x[2,1,HASH_BASE_CATEGORIA] + x[2,1,HASH_BASE_MATRICULA] == cChave }, nIni )

			//Se achar a base para o valor, adiciona um item novo no array
			If nPosBase > 0

				aAdd( aResponse, JsonObject():New() )

				If Empty( aArqBase[nPosBase,2,1,HASH_BASE_RECIBO_TRANSMISSAO] )
					cStatusGov := "Não Transmitido"
				ElseIf !aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_LOCALIZADO]
					cStatusGov := "Não Localizado"
				Else
					cStatusGov := ""
				EndIf

				aResponse[Len( aResponse )]["branchId"]					:=	aArqBase[nPosBase,2,1,HASH_BASE_ESTABELECIMENTO]
				aResponse[Len( aResponse )]["lotationCode"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_LOTACAO]

				aResponse[Len( aResponse )]["fgtsBasis"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS]
				aResponse[Len( aResponse )]["fgts13Basis"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
				aResponse[Len( aResponse )]["fgtsRescissionBasis"]		:=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

				aResponse[Len( aResponse )]["fgtsTafBasis"]				:=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS]
				aResponse[Len( aResponse )]["fgts13TafBasis"]			:=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
				aResponse[Len( aResponse )]["fgtsRescissionTafBasis"]	:=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]

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

				aBaseSint[6]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS]
				aBaseSint[7]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
				aBaseSint[8]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]

				If Empty( cStatusGov )

					aBaseSint[9]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
					aBaseSint[10]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
					aBaseSint[11]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]

				EndIf

				If lDiverg

					aBaseDiverg[3]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS]
					aBaseDiverg[4]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
					aBaseDiverg[5]	+=	aArqBase[nPosBase,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

					aBaseDiverg[6]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS]
					aBaseDiverg[7]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
					aBaseDiverg[8]	+=	aArqBase[nPosBase,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]

					If Empty( cStatusGov )

						aBaseDiverg[9]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
						aBaseDiverg[10]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
						aBaseDiverg[11]	+=	aArqBase[nPosBase,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]

					EndIf

				EndIf

				aDel( aArqBase, nPosBase )
				aSize( aArqBase, Len( aArqBase ) - 1 )

				nIni := nPosBase
				nPosBase := 0

				nRegProc ++
				SetPercent( cTicket, nRegProc, nTotalReg,,, lIsLegacy )

			Else

				lFim := .T.

			EndIf

		EndDo

		oResponse["basis"] := aResponse

		//Grava o item na V45
		nSeq ++
		GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nSeq, 6 ), lDiverg, "2" )

	Next nI

	lDiverg := .F.
	aSort( aArqBase,,, { |x,y| x[2,1,HASH_BASE_CPF] + x[2,1,HASH_BASE_NOME] + x[2,1,HASH_BASE_MATRICULA] + x[2,1,HASH_BASE_CATEGORIA] < y[2,1,HASH_BASE_CPF] + y[2,1,HASH_BASE_NOME] + y[2,1,HASH_BASE_MATRICULA] + y[2,1,HASH_BASE_CATEGORIA] } )

	//Bases que não possuem vínculos com depósitos
	For nI := 1 to Len( aArqBase )

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

		nFuncTotal ++

		FwFreeArray(aResponse)

		aResponse := {}

		aAdd( aResponse, JsonObject():New() )

		If Empty( aArqBase[nI,2,1,HASH_BASE_RECIBO_TRANSMISSAO] )
			cStatusGov := "Não Transmitido"
		ElseIf !aArqBase[nI,2,1,HASH_BASE_GOVERNO_LOCALIZADO]
			cStatusGov := "Não Localizado"
		Else
			cStatusGov := ""
		EndIf

		aResponse[Len( aResponse )]["branchId"]					:=	aArqBase[nI,2,1,HASH_BASE_ESTABELECIMENTO]
		aResponse[Len( aResponse )]["lotationCode"]				:=	aArqBase[nI,2,1,HASH_BASE_LOTACAO]

		aResponse[Len( aResponse )]["fgtsBasis"]				:=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS]
		aResponse[Len( aResponse )]["fgts13Basis"]				:=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]
		aResponse[Len( aResponse )]["fgtsRescissionBasis"]		:=	aArqBase[nI,2,1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]

		aResponse[Len( aResponse )]["fgtsTafBasis"]				:=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS]
		aResponse[Len( aResponse )]["fgts13TafBasis"]			:=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
		aResponse[Len( aResponse )]["fgtsRescissionTafBasis"]	:=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]

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

		aBaseSint[6]	+=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS]
		aBaseSint[7]	+=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]
		aBaseSint[8]	+=	aArqBase[nI,2,1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]

		If Empty( cStatusGov )

			aBaseSint[9]	+=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS]
			aBaseSint[10]	+=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]
			aBaseSint[11]	+=	aArqBase[nI,2,1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]

		EndIf

		oResponse["basis"] := aResponse
		
		//Grava o item na V45
		nSeq ++
		GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nSeq, 6 ), lDiverg, "2" )

		nRegProc++
		SetPercent( cTicket, nRegProc, nTotalReg,,, lIsLegacy )

	Next nI

	If TafColumnPos("V3N_CONSG")

		For nI := 1 To Len(aArqDesc)

			cKey := aArqDesc[nI,2,1,HASH_DESCONTO_CPF] + aArqDesc[nI,2,1,HASH_DESCONTO_CATEGORIA] + aArqDesc[nI,2,1,HASH_DESCONTO_MATRICULA] + aArqDesc[nI,2,1,HASH_DESCONTO_NUMERO_CONTRATO] + aArqDesc[nI,2,1,HASH_DESCONTO_INSTITUICAO_FINANCEIRA]

			aInfoEcons := {}
			nIniDesc   := 1
			lFim       := .F.

			oResponse["eConsigInfo"]             					:= JsonObject():New()
			oResponse["eConsigInfo"]["branchId"]					:=	aArqDesc[nI,2,1,HASH_DESCONTO_ESTABELECIMENTO]
			oResponse["eConsigInfo"]["lotationCode"]				:=	aArqDesc[nI,2,1,HASH_DESCONTO_LOTACAO]

			aAdd( aInfoEcons, JsonObject():New() )

			If Empty( aArqDesc[nI,2,1,HASH_DESCONTO_RECIBO_TRANSMISSAO] )
				cStatusGov := "Não Transmitido"
			ElseIf !aArqDesc[nI,2,1,HASH_DESCONTO_GOVERNO_LOCALIZADO]
				cStatusGov := "Não Localizado"
			Else
				cStatusGov := ""
			EndIf

			aInfoEcons[Len( aInfoEcons )]["contractNumber"]				:=	aArqDesc[nI,2,1,HASH_DESCONTO_NUMERO_CONTRATO]
			aInfoEcons[Len( aInfoEcons )]["financiInst"]				:=	aArqDesc[nI,2,1,HASH_DESCONTO_INSTITUICAO_FINANCEIRA]

			aInfoEcons[Len( aInfoEcons )]["consigErpValue"]				:=	aArqDesc[nI,2,1,HASH_DESCONTO_FOLHA_DEPOSITO_CONSIGNADO]

			aInfoEcons[Len( aInfoEcons )]["consigTafValue"]				:=	aArqDesc[nI,2,1,HASH_DESCONTO_TAF_DEPOSITO_CONSIGNADO]

			If Empty( cStatusGov )

				aInfoEcons[Len( aInfoEcons )]["consigRetValue"]			:=	aArqDesc[nI,2,1,HASH_DESCONTO_GOVERNO_DEPOSITO_CONSIGNADO]

			Else

				aInfoEcons[Len( aInfoEcons )]["consigRetValue"]			:=	0

			EndIf
			aInfoEcons[Len( aInfoEcons )]["divergConsig"]			:=	aArqDesc[nI,2,1,HASH_DESCONTO_DIVERGENCIA_CONSIGNADO]

			aDescSint[5]	+=	aArqDesc[nI,2,1,HASH_DESCONTO_FOLHA_DEPOSITO_CONSIGNADO]

			aDescSint[6]	+=	aArqDesc[nI,2,1,HASH_DESCONTO_TAF_DEPOSITO_CONSIGNADO]

			If Empty( cStatusGov )

				aDescSint[7]	+=	aArqDesc[nI,2,1,HASH_DESCONTO_GOVERNO_DEPOSITO_CONSIGNADO]

			EndIf

			If lDiverg

				aDescDiverg[5]		+=	aArqDesc[nI,2,1,HASH_DESCONTO_FOLHA_DEPOSITO_CONSIGNADO]

				aDescDiverg[6]		+=	aArqDesc[nI,2,1,HASH_DESCONTO_TAF_DEPOSITO_CONSIGNADO]

				If Empty( cStatusGov )

					aDescDiverg[7]	+=	aArqDesc[nI,2,1,HASH_DESCONTO_GOVERNO_DEPOSITO_CONSIGNADO]

				EndIf

			EndIf

			nRegProc++
			SetPercent( cTicket, nRegProc, nTotalReg,,, lIsLegacy )

			//Grava o item na V45
			nSeq ++
			GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nSeq, 6 ), lDiverg, "2" )

			oResponse["eConsigInfo"]["infoContract"] := JsonObject():New()
			oResponse["eConsigInfo"]["infoContract"] := aInfoEcons

		Next nI

	EndIf

	//Se não encontrou os dados
	If Empty(aArqDepo) .And. Empty(aArqBase) .And. Empty(aArqDesc)

		SetPercent( cTicket, 100, 100,,, lIsLegacy )

	Else

		//Grava a parte sintética
		GrvFGTSSint( aDepoSint, aBaseSint, nFuncTotal, .F., 1, aDescSint )
		GrvFGTSSint( aDepoDiverg, aBaseDiverg, nFuncDiverg, .T., 2, aDescDiverg )

	EndIf

	SetFinish( cTicket )

	oModelV3J:Destroy()
	RestArea( aArea )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GrvItRes
@type			function
@description	Grava o item do resultado da requisição.
@author			Robson Santos
@since			21/08/2019
@param			aItem		-	Array com os itens do resultado
/*/
//---------------------------------------------------------------------
Static Function GrvItRes( cTicket as Character, cResp as Character, cSeq as Character, lDiverg as Logical,;
						  cTipo as Character, cCPF as Character, lWarning as Logical)

	Default lDiverg  := .F.
	Default lWarning := .F.

	RecLock('V45',.T.)

		V45->V45_ID     := cTicket
		V45->V45_RESP   := cResp
		V45->V45_SEQ    := cSeq
		V45->V45_DIVERG := Iif( lDiverg, "1", "2" )
		V45->V45_TIPO   := cTipo
        If TafColumnPos("V45_WARNIN") ; V45->V45_WARNIN := Iif( lWarning, "1", "2" ); EndIf
		If !Empty(cCPF) .And. TafColumnPos("V45_CPF"); V45->V45_CPF := cCPF; EndIf

	V45->(MsUnlock())

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FilFGTSData
@type			function
@description	Filtra os dados de acordo com os parametros recebidos e salva em um hash.
@author			Robson Santos
@since			26/08/19
/*/
//---------------------------------------------------------------------
Static Function FilFGTSData(oReq as json, oHashBase as object, oHashDepo as object, cTicket as character, lIsLegacy as logical, oHashDesc as object)

	Local aCategoria  as array
	Local aCPFs       as array
	Local aEstabe     as array
	Local aLotacao    as array
	Local aMats       as array
	Local aPosBase    as array
	Local aPosDepo    as array
	Local aPosDesc    as array
	Local aReq        as array
	Local cFilSel     as character
	Local cIncidFGTS  as character
	Local cIndEConsg  as character
	Local cMV_TAFFGMD as character
	Local cNatureza   as character
	Local cNextAlias  as character
	Local cPeriodo    as character
	Local cQry        as character
	Local cSelect     as character
	Local cTipo       as character
	Local cWhere1     as character
	Local cWhere2     as character
	Local cWhere3     as character
	Local cWhere4     as character
	Local cWhere5     as character
	Local cWhere6     as character
	Local lAddBase    as logical
	Local lAddDepo    as logical
	Local lAddDesc    as logical
	Local lOnlyDiv    as logical
	Local lTafGpeFgts as logical
	Local nBasFGTS    as numeric
	Local nBasFGTS13  as numeric
	Local nBasFGTSRes as numeric
	Local nDepFGTS    as numeric
	Local nDepFGTS13  as numeric
	Local nDepFGTSRes as numeric
	Local nDesEconsig as numeric
	Local nDesEcoResp as numeric
	Local nItem       as numeric
	Local nPos        as numeric
	Local nQtdRegs    as numeric
	Local nValor      as numeric
	Local nVlrGOV     as numeric
	Local nVlrRH      as numeric
	Local nVlrTAF     as numeric
	Local nX          as numeric
	Local oStmt       as object

	Default cTicket   := ""
	Default lIsLegacy := .F.
	Default oHashBase := Nil
	Default oHashDepo := Nil
	Default oHashDesc := Nil
	Default oReq      := JsonObject():New()

	aCategoria  := oReq["eSocialCategory"]
	aCPFs       := oReq["cpfNumber"]
	aEstabe     := oReq["registrationNumber"]
	aLotacao    := oReq["lotationCode"]
	aMats       := oReq["eSocialRegistration"]
	aPosBase    := {}
	aPosDepo    := {}
	aPosDesc    := {}
	aReq        := {"differencesOnly"}
	cFilSel     := TAFCacheFil("V3N", FilMatriz(), .T.)
	cIncidFGTS  := ""
	cIndEConsg  := ""
	cMV_TAFFGMD := SuperGetMv("MV_TAFFGMD", .F., "02|03|05|06|14|17|26|27|33")
	cNatureza   := ""
	cNextAlias  := GetNextAlias()
	cPeriodo    := oReq["paymentPeriod"]
	cQry        := ""
	cSelect     := ""
	cTipo       := ""
	cWhere1     := ""
	cWhere2     := ""
	cWhere3     := ""
	cWhere4     := ""
	cWhere5     := ""
	cWhere6     := ""
	lAddBase    := .F.
	lAddDepo    := .F.
	lAddDesc    := .F.
	lOnlyDiv    := oReq["differencesOnly"]
	lTafGpeFgts := IIf(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F.)
	nBasFGTS    := 0
	nBasFGTS13  := 0
	nBasFGTSRes := 0
	nDepFGTS    := 0
	nDepFGTS13  := 0
	nDepFGTSRes := 0
	nDesEconsig := 0
	nDesEcoResp := 0
	nItem       := 0
	nPos        := 1
	nQtdRegs    := 0
	nValor      := 0
	nVlrGOV     := 0
	nVlrRH      := 0
	nVlrTAF     := 0
	nX          := 0
	oStmt       := Nil

	If TafColumnPos("V3N_CONSG")

		cSelect += "    V3N.V3N_CONSG,  "
		cSelect += "    V3N.V3N_INSTFI, "
		cSelect += "    V3N.V3N_NRCRT,  "

	EndIf	

	If !EmptY(cPeriodo)
		cWhere1 += "    AND V3N_PERAPU = ? "
		aAdd(aReq, "paymentPeriod")
		nPos++
	EndIf

	If !Empty(aCategoria)
		cWhere2 += "    AND V3N_CATEG IN (?)  "
		aAdd(aReq, "eSocialCategory")
		nPos++
	EndIf

	If !Empty(aLotacao)
		cWhere3 += "    AND V3N_CODLOT IN (?) "
		aAdd(aReq, "lotationCode")
		nPos++
	EndIf

	If !Empty(aEstabe)
		cWhere4 += "    AND V3N_NRINSC IN (?) "
		aAdd(aReq, "registrationNumber")
		nPos++
	EndIf

	If !Empty(aCPFs)
		cWhere5 += " AND V3N_CPF IN (?) "
		aAdd(aReq, "cpfNumber")
		nPos++
	EndIf

	If !Empty(aMats)
		cWhere6 += " AND V3N_MATRIC IN (?) "
		aAdd(aReq, "eSocialRegistration")
		nPos++
	EndIf 

	cQry += " SELECT "
	cQry += "    V3N.V3N_FILIAL, "
	cQry += "    V3N.V3N_INDAPU,  "
	cQry += "    V3N.V3N_PERAPU, "
	cQry += "    V3N.V3N_CPF, "
	cQry += "    V3N.V3N_NOME, "
	cQry += "    V3N.V3N_MATRIC, "
	cQry += "    V3N.V3N_CATEG, "
	cQry += "    V3N.V3N_TPINSC, "
	cQry += "    V3N.V3N_NRINSC, "
	cQry += "    V3N.V3N_CODLOT, "
	cQry += "    V3N.V3N_EVENTO, "
	cQry += "    V3N.V3N_ORIGEM, "
	cQry += "    V3N.V3N_RECIBO, "
	cQry += "    V3N.V3N_NATRUB, "
	cQry += "    V3N.V3N_TPRUBR, "
	cQry += "    V3N.V3N_ITFGTS, "
	cQry += "    V3N.V3N_TPVLR, "
	cQry += "    V3N.V3N_MOTDES, "
	cQry += "    V3N.V3N_VLRDEP, "
	cQry += "    V3N.V3N_VALOR,  "
	cQry +=      cSelect
	cQry += "    C8O.C8O_CODIGO  " 
	cQry += " FROM  "+RetSqlName("V3N")+" V3N  " 
	cQry += " LEFT JOIN " + RetSqlName("C9V") + " C9V "
	cQry += "	ON C9V.C9V_FILIAL = V3N.V3N_FILIAL "
	cQry += "		AND C9V.C9V_CPF = V3N.V3N_CPF "
	cQry += "		AND (C9V.C9V_MATRIC = V3N.V3N_MATRIC "
	cQry += "			OR C9V.C9V_MATTSV = V3N.V3N_MATRIC) "
	cQry += "		AND C9V.C9V_ATIVO = '1' "
	cQry += "		AND	C9V.D_E_L_E_T_ = '' "
	cQry += " LEFT JOIN " + RetSqlName("CMD") + " CMD "
	cQry += "	ON CMD.CMD_FILIAL =	V3N.V3N_FILIAL "
	cQry += "		AND CMD.CMD_FUNC = C9V.C9V_ID "
	cQry += "		AND	CMD.CMD_ATIVO =	'1' "
	cQry += "		AND	CMD.D_E_L_E_T_ = '' "
	cQry += " LEFT JOIN " + RetSqlName("C8O") + " C8O "
	cQry += "	ON C8O.C8O_ID = CMD.CMD_MOTDES "
	cQry += "		AND	C8O.D_E_L_E_T_ = '' "
	cQry += " WHERE V3N.D_E_L_E_T_ = '' "
	cQry += "	 AND V3N.V3N_EVENTO <> 'S-1200'"
	cQry += "	 AND V3N_ORIGEM IN (?) "
	cQry += "    AND V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) " 
	cQry += 	 cWhere1
	cQry += 	 cWhere2
	cQry += 	 cWhere3
	cQry += 	 cWhere4
	cQry += 	 cWhere5
	cQry += 	 cWhere6

	cQry += "	UNION "

	cQry += " SELECT "
	cQry += "   V3N.V3N_FILIAL, "
	cQry += "    V3N.V3N_INDAPU,  "
	cQry += "    V3N.V3N_PERAPU, "
	cQry += "    V3N.V3N_CPF, "
	cQry += "    V3N.V3N_NOME, "
	cQry += "    V3N.V3N_MATRIC, "
	cQry += "    V3N.V3N_CATEG, "
	cQry += "    V3N.V3N_TPINSC, "
	cQry += "    V3N.V3N_NRINSC, "
	cQry += "    V3N.V3N_CODLOT, "
	cQry += "    V3N.V3N_EVENTO, "
	cQry += "    V3N.V3N_ORIGEM, "
	cQry += "    V3N.V3N_RECIBO, "
	cQry += "    V3N.V3N_NATRUB, "
	cQry += "    V3N.V3N_TPRUBR, "
	cQry += "    V3N.V3N_ITFGTS, "
	cQry += "    V3N.V3N_TPVLR, "
	cQry += "    V3N.V3N_MOTDES, "
	cQry += "    V3N.V3N_VLRDEP, "
	cQry += "    V3N.V3N_VALOR,  "
	cQry +=      cSelect
	cQry += "    C8O.C8O_CODIGO  " 
	cQry += " FROM  "+RetSqlName("V3N")+" V3N  "
	cQry += " LEFT JOIN " + RetSqlName("C9V") + " C9V "
	cQry += "	ON C9V.C9V_FILIAL = V3N.V3N_FILIAL "
	cQry += "		AND C9V.C9V_CPF = V3N.V3N_CPF "
	cQry += "		AND (C9V.C9V_MATRIC = V3N.V3N_MATRIC "
	cQry += "			OR C9V.C9V_MATTSV = V3N.V3N_MATRIC) "
	cQry += "		AND C9V.C9V_ATIVO = '1' "
	cQry += "		AND	C9V.D_E_L_E_T_ = '' "
	cQry += " LEFT JOIN " + RetSqlName("CMD") + " CMD "
	cQry += "	ON CMD.CMD_FILIAL =	V3N.V3N_FILIAL "
	cQry += "		AND CMD.CMD_FUNC = C9V.C9V_ID "
	cQry += "		AND	CMD.CMD_ATIVO =	'1' "
	cQry += "		AND	CMD.D_E_L_E_T_ = '' "
	cQry += " LEFT JOIN " + RetSqlName("C8O") + " C8O "
	cQry += "	ON C8O.C8O_ID = CMD.CMD_MOTDES "
	cQry += "		AND	C8O.D_E_L_E_T_ = '' "
	cQry += " WHERE V3N.D_E_L_E_T_ = '' "
	cQry += " AND V3N.V3N_EVENTO = 'S-1200' "
	cQry += "	 AND V3N.V3N_MOTDES = '' "
	cQry += "	 AND V3N_ORIGEM IN (?) "
	cQry += "    AND V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) " 
	cQry += 	 cWhere1
	cQry += 	 cWhere2
	cQry += 	 cWhere3
	cQry += 	 cWhere4
	cQry += 	 cWhere5
	cQry += 	 cWhere6
	cQry += " ORDER BY V3N_ORIGEM "

	oStmt := FWExecStatement():New( ChangeQuery(cQry) )

	For nX := 1 To Len(aReq)

		If aReq[nX] == "differencesOnly"
			If lOnlyDiv .And. lIsLegacy
				oStmt:setIn( nX, { '2', '5' } )
				oStmt:setIn( nX + nPos, { '2', '5' } )
			Else
				oStmt:setIn( nX, { '1', '2', '5' } )
				oStmt:setIn( nX + nPos, { '1', '2', '5' } )
			EndIf
		EndIf

		If aReq[nX] == "paymentPeriod" .And. !Empty(cPeriodo)
			oStmt:SetString( nX, cPeriodo )
			oStmt:SetString( nX + nPos, cPeriodo )
		EndIf

		If aReq[nX] == "eSocialCategory" .And. !Empty(aCategoria)
			oStmt:setIn( nX, aCategoria )
			oStmt:setIn( nX + nPos, aCategoria )
		EndIf

		If aReq[nX] == "lotationCode" .And. !Empty(aLotacao)
			oStmt:setIn( nX, aLotacao )
			oStmt:setIn( nX + nPos, aLotacao )
		EndIf

		If aReq[nX] == "registrationNumber" .And. !Empty(aEstabe)
			oStmt:setIn( nX, aEstabe )
			oStmt:setIn( nX + nPos, aEstabe )
		EndIf

		If aReq[nX] == "cpfNumber" .And. !Empty(aCPFs)
			oStmt:setIn( nX, aCPFs )
			oStmt:setIn( nX + nPos, aCPFs )
		EndIf

		If aReq[nX] == "eSocialRegistration" .And. !Empty(aMats)
			oStmt:setIn( nX, aMats )
			oStmt:setIn( nX + nPos, aMats )
		EndIf
	
	Next

	If Select(cNextAlias) > 0
		(cNextAlias)->( dbCloseArea() )
	EndIf

	cNextAlias := oStmt:OpenAlias()

	//Recupera a consulta já com os parâmetros injetados
	cQry := oStmt:getFixQuery()

	TafConOut(procname() + cQry)

	oStmt:executeQuery( cNextAlias )

	If (cNextAlias)->( !Eof() )
		( cNextAlias )->( DBEval( { || nQtdRegs ++ } ) )
	EndIf

	(cNextAlias)->( dbGoTop() )

	While (cNextAlias)->( !Eof() )

		cEvento := AllTrim( ( cNextAlias )->V3N_EVENTO )

		Do Case

		Case ( cNextAlias )->V3N_ORIGEM $ "1|2"

			cNatureza	:=	AllTrim( ( cNextAlias )->V3N_NATRUB )
			cTipo		:=	AllTrim( ( cNextAlias )->V3N_TPRUBR )
			cIncidFGTS	:=	AllTrim( ( cNextAlias )->V3N_ITFGTS )

			If TafColumnPos("V3N_CONSG")
				cIndEConsg  :=  Alltrim( ( cNextAlias )->V3N_CONSG  )
			EndIf	

			If ( cNextAlias )->V3N_INDAPU == "1"
				If cNatureza == "9902" .And. cTipo == "3"
					nBasFGTS := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.
				ElseIf cNatureza == "9902" .And. cTipo == "4"
					nBasFGTS := ( cNextAlias )->V3N_VALOR * -1
					lAddBase := .T.
				ElseIf cNatureza == "9904" .And. cTipo == "3"
					nBasFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.
				ElseIf cNatureza == "9908" .And. cTipo == "3"
					// Ser S-2299/S-2399 não é motivo para automaticamente incluir como FGTS Rescisório.
					// Se o Desligamento tiver Motiv de Desligamento diferente de 02|03|05|06|14|17|26|27|33, ele não gera guia de FGTS Rescisório, sendo considerado FGTS Mensal
					If cEvento == "S-1200" .Or. ( val(( cNextAlias )->V3N_MOTDES) > 0 .And. !( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) 
						nDepFGTS := ( cNextAlias )->V3N_VALOR
						lAddDepo := .T.
					Else
						nDepFGTSRes := ( cNextAlias )->V3N_VALOR
						lAddDepo := .T.
					EndIf

				ElseIf cNatureza == "9908" .And. cTipo == "4"
					// Ser S-2299/S-2399 não é motivo para automaticamente incluir como FGTS Rescisório.
					// Se o Desligamento tiver Motiv de Desligamento diferente de 02|03|05|06|14|17|26|27|33, ele não gera guia de FGTS Rescisório, sendo considerado FGTS Mensal
					If cEvento == "S-1200" .Or. ( val(( cNextAlias )->V3N_MOTDES) > 0 .And. !( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) 
						nDepFGTS := ( cNextAlias )->V3N_VALOR * -1
						lAddDepo := .T.
					Else
						nDepFGTSRes := ( cNextAlias )->V3N_VALOR * -1
						lAddDepo := .T.
					EndIf
				EndIf

				//Condição para eConsignado
				If cIndEConsg == "T" .And. cNatureza == "9253" .And. cTipo == "2" .And. cIncidFGTS == '31'
					nDesEconsig := ( cNextAlias )->V3N_VALOR
					lAddDesc := .T.
					lAddDepo := .T.
				EndIf

			ElseIf ( cNextAlias )->V3N_INDAPU == "2"
				If cNatureza == "9902" .And. cTipo == "3"
					nBasFGTS13 := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.
				ElseIf cNatureza == "9908" .And. cTipo == "3"
					nDepFGTS13 := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
				ElseIf lTafGpeFgts  .And. cNatureza == "9989" .And. cTipo == "4" .And. cIncidFGTS =="12"
					nBasFGTS13 -= ( cNextAlias )->V3N_VALOR
					lAddBase := .T.
				EndIf
			EndIf
			
		Case ( cNextAlias )->V3N_ORIGEM == "5"
			
			cTipo := AllTrim( ( cNextAlias )->V3N_TPVLR )

			If cTipo $ "11|13|15|17|41|43" 
				If ( ( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) .And. !Empty(( cNextAlias )->V3N_MOTDES)
					nBasFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.

					If ( cNextAlias )->V3N_VLRDEP > 0
						nDepFGTSRes := ( cNextAlias )->V3N_VLRDEP
						lAddDepo := .T.
					EndIf 
				Else
					nBasFGTS := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.

					If ( cNextAlias )->V3N_VLRDEP > 0
						nDepFGTS := ( cNextAlias )->V3N_VLRDEP
						lAddDepo := .T.
					EndIf
					
				EndIf
			ElseIf cTipo $ "12|14|16|18|22|25|28|31|42|44|46|49"
				If ( ( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) .And. !Empty(( cNextAlias )->V3N_MOTDES)
					nBasFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.

					If  ( cNextAlias )->V3N_VLRDEP > 0
						nDepFGTSRes := ( cNextAlias )->V3N_VLRDEP
						lAddDepo := .T.
					EndIf 
				
				Else
					nBasFGTS13 := ( cNextAlias )->V3N_VALOR
					lAddBase := .T.

					If ( cNextAlias )->V3N_VLRDEP > 0
						nDepFGTS13 := ( cNextAlias )->V3N_VLRDEP
						lAddDepo := .T.
					EndIf
					
				EndIf
			ElseIf cTipo $ "21|23|24|26|27|29|30|32|45|47|48|50"
				nBasFGTSRes := ( cNextAlias )->V3N_VALOR
				lAddBase := .T.

				If ( cNextAlias )->V3N_VLRDEP > 0
					nDepFGTSRes := ( cNextAlias )->V3N_VLRDEP
					lAddDepo := .T.
				EndIf

			ElseIf cTipo $ "51|53|55|57"
				If ( ( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) .And. !Empty(( cNextAlias )->V3N_MOTDES)
					nDepFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
				Else
					nDepFGTS := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
				EndIf
			ElseIf cTipo $ "52|54|56|58|65|68|71"
				If ( ( cNextAlias )->V3N_MOTDES $ cMV_TAFFGMD ) .And. !Empty(( cNextAlias )->V3N_MOTDES)
					nDepFGTSRes := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
				Else
					nDepFGTS13 := ( cNextAlias )->V3N_VALOR
					lAddDepo := .T.
				EndIf
			ElseIf cTipo $ "61|62|63|64|66|67|69|70|72"
				nDepFGTSRes := ( cNextAlias )->V3N_VALOR
				lAddDepo := .T.

			//Condição para eConsignado	
			ElseIf cTipo == "" .And. ( cNextAlias )->V3N_CONSG == "T" 	
				nDesEcoResp := ( cNextAlias )->V3N_VALOR
				lAddDesc := .T.
			EndIf

		OtherWise
			lAddBase := .F.
			lAddDepo := .F.
		EndCase

		If lAddBase
			If TAFXHMGet( oHashBase, AllTrim( ( cNextAlias )->V3N_NRINSC ) + AllTrim( ( cNextAlias )->V3N_CPF ) + AllTrim( ( cNextAlias )->V3N_MATRIC ) + AllTrim( ( cNextAlias )->V3N_CATEG ) + AllTrim( ( cNextAlias )->V3N_CODLOT ), @aPosBase )
				aPosBase[1,HASH_BASE_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
				aPosBase[1,HASH_BASE_NOME]				:=	AllTrim( ( cNextAlias )->V3N_NOME )
				aPosBase[1,HASH_BASE_MATRICULA]			:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
				aPosBase[1,HASH_BASE_LOTACAO]			:=	AllTrim( ( cNextAlias )->V3N_CODLOT )
				aPosBase[1,HASH_BASE_ESTABELECIMENTO]	:=	AllTrim( ( cNextAlias )->V3N_NRINSC )
				aPosBase[1,HASH_BASE_CATEGORIA]			:=	AllTrim( ( cNextAlias )->V3N_CATEG )
				aPosBase[1,HASH_BASE_EVENTO_ESOCIAL]	:=	cEvento

				Do Case

				Case ( cNextAlias )->V3N_ORIGEM == "1"
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS]				+=	nBasFGTS
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "2"
					aPosBase[1,HASH_BASE_TAF_BASE_FGTS]				+=	nBasFGTS
					aPosBase[1,HASH_BASE_TAF_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
					aPosBase[1,HASH_BASE_TAF_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "5"
					aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS]				+=	nBasFGTS
					aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	+=	nBasFGTS13
					aPosBase[1,HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	+=	nBasFGTSRes
					aPosBase[1,HASH_BASE_GOVERNO_LOCALIZADO]			:=	.T.

				EndCase

				aPosBase[1,HASH_BASE_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

				TAFXHMSet( oHashBase, aPosBase[1,HASH_BASE_ESTABELECIMENTO] + aPosBase[1,HASH_BASE_CPF] + aPosBase[1,HASH_BASE_MATRICULA] + aPosBase[1,HASH_BASE_CATEGORIA] + aPosBase[1,HASH_BASE_LOTACAO], aPosBase )
			Else
				aPosBase := InitBase()

				aPosBase[HASH_BASE_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
				aPosBase[HASH_BASE_NOME]			:=	AllTrim( ( cNextAlias )->V3N_NOME )
				aPosBase[HASH_BASE_MATRICULA]		:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
				aPosBase[HASH_BASE_LOTACAO]			:=	AllTrim( ( cNextAlias )->V3N_CODLOT )
				aPosBase[HASH_BASE_ESTABELECIMENTO]	:=	AllTrim( ( cNextAlias )->V3N_NRINSC )
				aPosBase[HASH_BASE_CATEGORIA]		:=	AllTrim( ( cNextAlias )->V3N_CATEG )
				aPosBase[HASH_BASE_EVENTO_ESOCIAL]	:=	cEvento

				Do Case

				Case ( cNextAlias )->V3N_ORIGEM == "1"
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS]				:=	nBasFGTS
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "2"
					aPosBase[HASH_BASE_TAF_BASE_FGTS]				:=	nBasFGTS
					aPosBase[HASH_BASE_TAF_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
					aPosBase[HASH_BASE_TAF_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes

				Case ( cNextAlias )->V3N_ORIGEM == "5"
					aPosBase[HASH_BASE_GOVERNO_BASE_FGTS]				:=	nBasFGTS
					aPosBase[HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	:=	nBasFGTS13
					aPosBase[HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	:=	nBasFGTSRes
					aPosBase[HASH_BASE_GOVERNO_LOCALIZADO]				:=	.T.

				EndCase

				aPosBase[HASH_BASE_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

				TAFXHMAdd( oHashBase, aPosBase, HASH_BASE_ESTABELECIMENTO, 3, HASH_BASE_CPF, 3, HASH_BASE_MATRICULA, 3, HASH_BASE_CATEGORIA, 3, HASH_BASE_LOTACAO, 3 )
			EndIf
		EndIf

		If lAddDepo
			If TAFXHMGet( oHashDepo, AllTrim( ( cNextAlias )->V3N_CPF ) + AllTrim( ( cNextAlias )->V3N_MATRIC ) + AllTrim( ( cNextAlias )->V3N_CATEG ), @aPosDepo )
				aPosDepo[1,HASH_DEPOSITO_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
				aPosDepo[1,HASH_DEPOSITO_NOME]				:=	AllTrim( ( cNextAlias )->V3N_NOME )
				aPosDepo[1,HASH_DEPOSITO_MATRICULA]			:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
				aPosDepo[1,HASH_DEPOSITO_CATEGORIA]			:=	AllTrim( ( cNextAlias )->V3N_CATEG )
				aPosDepo[1,HASH_DEPOSITO_EVENTO_ESOCIAL]	:=	cEvento

				Do Case

				Case ( cNextAlias )->V3N_ORIGEM == "1"
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				+=	nDepFGTS
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes
					nVlrRH += nDepFGTS + nDepFGTS13 + nDepFGTSRes
					aPosDepo[1,HASH_TOTAL_DEPOSITO_FOLHA_DEPOSITO_FGTS] 	+= nVlrRH

				Case ( cNextAlias )->V3N_ORIGEM == "2"
					aPosDepo[1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS]				+=	nDepFGTS
					aPosDepo[1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
					aPosDepo[1,HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes
					nVlrTAF += nDepFGTS + nDepFGTS13 + nDepFGTSRes 
					aPosDepo[1,HASH_TOTAL_DEPOSITO_TAF_DEPOSITO_FGTS] 		+= nVlrTAF

				Case ( cNextAlias )->V3N_ORIGEM == "5"
					aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				+=	nDepFGTS
					aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	+=	nDepFGTS13
					aPosDepo[1,HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	+=	nDepFGTSRes
					aPosDepo[1,HASH_DEPOSITO_GOVERNO_LOCALIZADO]				:=	.T.
					nVlrGOV += nDepFGTS + nDepFGTS13 + nDepFGTSRes 
					aPosDepo[1,HASH_TOTAL_DEPOSITO_GOVERNO_DEPOSITO_FGTS] 	+= nVlrGOV

				EndCase

				aPosDepo[1,HASH_DEPOSITO_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

				If TafColumnPos("V3N_CONSG ") 

					If cIndEConsg == "T"
						aPosDepo[1,HASH_DEPOSITO_FGTS_ECONSIGNADO]			:=	.T.
					Else
						aPosDepo[1,HASH_DEPOSITO_FGTS_ECONSIGNADO]			:=	.F.
					EndIf	

				EndIf	

				TAFXHMSet( oHashDepo, aPosDepo[1,HASH_DEPOSITO_CPF] + aPosDepo[1,HASH_DEPOSITO_MATRICULA] + aPosDepo[1,HASH_DEPOSITO_CATEGORIA], aPosDepo )
			Else
				aPosDepo := InitDeposito()

				aPosDepo[HASH_DEPOSITO_CPF]				:=	AllTrim( ( cNextAlias )->V3N_CPF )
				aPosDepo[HASH_DEPOSITO_NOME]			:=	AllTrim( ( cNextAlias )->V3N_NOME )
				aPosDepo[HASH_DEPOSITO_MATRICULA]		:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
				aPosDepo[HASH_DEPOSITO_CATEGORIA]		:=	AllTrim( ( cNextAlias )->V3N_CATEG )
				aPosDepo[HASH_DEPOSITO_EVENTO_ESOCIAL]	:=	cEvento

				Do Case

				Case ( cNextAlias )->V3N_ORIGEM == "1"
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	nDepFGTS
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes
					nVlrRH := nDepFGTS + nDepFGTS13 + nDepFGTSRes
					aPosDepo[HASH_TOTAL_DEPOSITO_FOLHA_DEPOSITO_FGTS] 	:= nVlrRH

				Case ( cNextAlias )->V3N_ORIGEM == "2"
					aPosDepo[HASH_DEPOSITO_TAF_DEPOSITO_FGTS]				:=	nDepFGTS
					aPosDepo[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
					aPosDepo[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes
					nVlrTAF := nDepFGTS + nDepFGTS13 + nDepFGTSRes
					aPosDepo[HASH_TOTAL_DEPOSITO_TAF_DEPOSITO_FGTS] 	:= nVlrTAF

				Case ( cNextAlias )->V3N_ORIGEM == "5"
					aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				:=	nDepFGTS
					aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	:=	nDepFGTS13
					aPosDepo[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	:=	nDepFGTSRes
					aPosDepo[HASH_DEPOSITO_GOVERNO_LOCALIZADO]					:=	.T.
					nVlrGOV := nDepFGTS + nDepFGTS13 + nDepFGTSRes
					aPosDepo[HASH_TOTAL_DEPOSITO_GOVERNO_DEPOSITO_FGTS] := nVlrGOV

				EndCase

				aPosDepo[HASH_DEPOSITO_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

				If TafColumnPos("V3N_CONSG ")

					If cIndEConsg == "T"
						aPosDepo[HASH_DEPOSITO_FGTS_ECONSIGNADO]			:=	.T.
					Else
						aPosDepo[HASH_DEPOSITO_FGTS_ECONSIGNADO]			:=	.F.
					EndIf	

				EndIf

				TAFXHMAdd( oHashDepo, aPosDepo, HASH_DEPOSITO_CPF, 3, HASH_DEPOSITO_MATRICULA, 3, HASH_DEPOSITO_CATEGORIA, 3 )
			EndIf
		EndIf

		If lAddDesc

			aPosDesc := InitDesc()

			aPosDesc[HASH_DESCONTO_CPF]						:=	AllTrim( ( cNextAlias )->V3N_CPF )
			aPosDesc[HASH_DESCONTO_NOME]					:=	AllTrim( ( cNextAlias )->V3N_NOME )
			aPosDesc[HASH_DESCONTO_MATRICULA]				:=	AllTrim( ( cNextAlias )->V3N_MATRIC )
			aPosDesc[HASH_DESCONTO_LOTACAO]					:=	AllTrim( ( cNextAlias )->V3N_CODLOT )
			aPosDesc[HASH_DESCONTO_ESTABELECIMENTO]			:=	AllTrim( ( cNextAlias )->V3N_NRINSC )
			aPosDesc[HASH_DESCONTO_CATEGORIA]				:=	AllTrim( ( cNextAlias )->V3N_CATEG )
			aPosDesc[HASH_DESCONTO_EVENTO_ESOCIAL]			:=	cEvento

			Do Case

			Case ( cNextAlias )->V3N_ORIGEM == "1"
				aPosDesc[HASH_DESCONTO_FOLHA_DEPOSITO_CONSIGNADO]			:=	nDesEconsig

			Case ( cNextAlias )->V3N_ORIGEM == "2"
				aPosDesc[HASH_DESCONTO_TAF_DEPOSITO_CONSIGNADO]				:=	nDesEconsig

			Case ( cNextAlias )->V3N_ORIGEM == "5"
				aPosDesc[HASH_DESCONTO_GOVERNO_DEPOSITO_CONSIGNADO]			:=	nDesEcoResp
				aPosDesc[HASH_DESCONTO_GOVERNO_LOCALIZADO]					:=	.T.

			EndCase

			aPosDesc[HASH_DESCONTO_RECIBO_TRANSMISSAO]	:=	AllTrim( ( cNextAlias )->V3N_RECIBO )

			If TafColumnPos("V3N_CONSG")
				aPosDesc[HASH_DESCONTO_FGTS_ECONSIGNADO]		:=	AllTrim( ( cNextAlias )->V3N_CONSG  )
				aPosDesc[HASH_DESCONTO_NUMERO_CONTRATO]			:=	AllTrim( ( cNextAlias )->V3N_NRCRT  )
				aPosDesc[HASH_DESCONTO_INSTITUICAO_FINANCEIRA]	:=	AllTrim( ( cNextAlias )->V3N_INSTFI )
			EndIf	

			TAFXHMAdd( oHashDesc, aPosDesc, HASH_DESCONTO_ESTABELECIMENTO, 3, HASH_DESCONTO_CPF, 3, HASH_DESCONTO_MATRICULA, 3, HASH_DESCONTO_CATEGORIA, 3, HASH_DESCONTO_LOTACAO, 3, HASH_DESCONTO_NUMERO_CONTRATO, 3, HASH_DESCONTO_INSTITUICAO_FINANCEIRA, 3 )
			
		EndIf

		(cNextAlias)->(dbSkip())

		nItem++

		setPercent(cTicket, nItem, nQtdRegs,,, lIsLegacy)

		cNatureza	:=	""
		cTipo		:=	""
		cIncidFGTS	:=	""
		nBasFGTS	:=	0
		nDepFGTS	:=	0
		nBasFGTS13	:=	0
		nDepFGTS13	:=	0
		nBasFGTSRes	:=	0
		nDepFGTSRes	:=	0
		nDesEconsig	:= 	0
		nVlrRH      := 0
		nVlrTAF     := 0
		nVlrGOV     := 0
		aPosBase	:=	{}
		aPosDepo	:=	{}
		lAddBase	:=	.F.
		lAddDepo	:=	.F.
		lAddDesc	:=  .F.

	EndDo

	If lIsLegacy

		cAliasV5H	:= V5HByTicket(cTicket)

		If !Empty(cAliasV5H)
			(cAliasV5H)->( dbGoTop() )
			

			While (cAliasV5H)->( !Eof() )
				
				aPosBase	:= {}
				aPosDepo	:= {}
				aPosDesc	:= {}
				
				If TAFXHMGet( oHashBase, AllTrim((cAliasV5H)->V5H_ESTABE) + AllTrim((cAliasV5H)->V5H_CPF) + AllTrim((cAliasV5H)->V5H_MATRIC) + AllTrim((cAliasV5H)->V5H_CATEG) + AllTrim((cAliasV5H)->V5H_LOTACA), @aPosBase )

					aPosBase[1,HASH_BASE_CPF]							:=	AllTrim( (cAliasV5H)->V5H_CPF )
					aPosBase[1,HASH_BASE_NOME]							:=	AllTrim( (cAliasV5H)->V5H_NOME )
					aPosBase[1,HASH_BASE_MATRICULA]						:=	AllTrim( (cAliasV5H)->V5H_MATRIC )
					aPosBase[1,HASH_BASE_LOTACAO]						:=	AllTrim( (cAliasV5H)->V5H_LOTACA )
					aPosBase[1,HASH_BASE_ESTABELECIMENTO]				:=	AllTrim( (cAliasV5H)->V5H_ESTABE )
					aPosBase[1,HASH_BASE_CATEGORIA]						:=	AllTrim( (cAliasV5H)->V5H_CATEG )
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS]				:=	(cAliasV5H)->V5H_BSFGTS
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	:=	(cAliasV5H)->V5H_BSFG13
					aPosBase[1,HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	:=	(cAliasV5H)->V5H_BSFGRE

					TAFXHMSet( oHashBase, aPosBase[1,HASH_BASE_ESTABELECIMENTO] + aPosBase[1,HASH_BASE_CPF] + aPosBase[1,HASH_BASE_MATRICULA] + aPosBase[1,HASH_BASE_CATEGORIA] + aPosBase[1,HASH_BASE_LOTACAO], aPosBase )
				Else
					aPosBase	:= InitBase()

					aPosBase[HASH_BASE_CPF]							:=	AllTrim( (cAliasV5H)->V5H_CPF )
					aPosBase[HASH_BASE_NOME]						:=	AllTrim( (cAliasV5H)->V5H_NOME )
					aPosBase[HASH_BASE_MATRICULA]					:=	AllTrim( (cAliasV5H)->V5H_MATRIC )
					aPosBase[HASH_BASE_LOTACAO]						:=	AllTrim( (cAliasV5H)->V5H_LOTACA )
					aPosBase[HASH_BASE_ESTABELECIMENTO]				:=	AllTrim( (cAliasV5H)->V5H_ESTABE )
					aPosBase[HASH_BASE_CATEGORIA]					:=	AllTrim( (cAliasV5H)->V5H_CATEG )
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS]				:=	(cAliasV5H)->V5H_BSFGTS
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS_13_SALARIO]	:=	(cAliasV5H)->V5H_BSFG13
					aPosBase[HASH_BASE_FOLHA_BASE_FGTS_RESCISORIO]	:=	(cAliasV5H)->V5H_BSFGRE

					TAFXHMAdd( oHashBase, aPosBase, HASH_BASE_ESTABELECIMENTO, 3, HASH_BASE_CPF, 3, HASH_BASE_MATRICULA, 3, HASH_BASE_CATEGORIA, 3, HASH_BASE_LOTACAO, 3 )

				EndIf

				If TAFXHMGet( oHashDepo, AllTrim((cAliasV5H)->V5H_CPF) + AllTrim((cAliasV5H)->V5H_MATRIC) + AllTrim((cAliasV5H)->V5H_CATEG), @aPosDepo )

					aPosDepo[1,HASH_DEPOSITO_CPF]								:=	AllTrim( (cAliasV5H)->V5H_CPF )
					aPosDepo[1,HASH_DEPOSITO_NOME]								:=	AllTrim( (cAliasV5H)->V5H_NOME )
					aPosDepo[1,HASH_DEPOSITO_MATRICULA]							:=	AllTrim( (cAliasV5H)->V5H_MATRIC )
					aPosDepo[1,HASH_DEPOSITO_CATEGORIA]							:=	AllTrim( (cAliasV5H)->V5H_CATEG )
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	(cAliasV5H)->V5H_VLFGTS
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	:=	(cAliasV5H)->V5H_VLFG13
					aPosDepo[1,HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	:=	(cAliasV5H)->V5H_VLFGRE

					TAFXHMSet( oHashDepo, aPosDepo[1,HASH_DEPOSITO_CPF] + aPosDepo[1,HASH_DEPOSITO_MATRICULA] + aPosDepo[1,HASH_DEPOSITO_CATEGORIA], aPosDepo )

				Else

					aPosDepo	:= InitDeposito()

					aPosDepo[HASH_DEPOSITO_CPF]								:=	AllTrim( (cAliasV5H)->V5H_CPF )
					aPosDepo[HASH_DEPOSITO_NOME]							:=	AllTrim( (cAliasV5H)->V5H_NOME )
					aPosDepo[HASH_DEPOSITO_MATRICULA]						:=	AllTrim( (cAliasV5H)->V5H_MATRIC )
					aPosDepo[HASH_DEPOSITO_CATEGORIA]						:=	AllTrim( (cAliasV5H)->V5H_CATEG )
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:=	(cAliasV5H)->V5H_VLFGTS
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]	:=	(cAliasV5H)->V5H_VLFG13
					aPosDepo[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]	:=	(cAliasV5H)->V5H_VLFGRE

					TAFXHMAdd( oHashDepo, aPosDepo, HASH_DEPOSITO_CPF, 3, HASH_DEPOSITO_MATRICULA, 3, HASH_DEPOSITO_CATEGORIA, 3 )

				EndIf

				//Condição para eConsignado	
				If TafColumnPos("V5H_CONSG")

					aPosDesc	:= InitDesc()

					aPosDesc[HASH_DESCONTO_CPF]								:=	AllTrim( (cAliasV5H)->V5H_CPF )
					aPosDesc[HASH_DESCONTO_NOME]							:=	AllTrim( (cAliasV5H)->V5H_NOME )
					aPosDesc[HASH_DESCONTO_MATRICULA]						:=	AllTrim( (cAliasV5H)->V5H_MATRIC )
					aPosDesc[HASH_DESCONTO_LOTACAO]							:=	AllTrim( (cAliasV5H)->V5H_LOTACA )
					aPosDesc[HASH_DESCONTO_ESTABELECIMENTO]					:=	AllTrim( (cAliasV5H)->V5H_ESTABE )
					aPosDesc[HASH_DESCONTO_CATEGORIA]						:=	AllTrim( (cAliasV5H)->V5H_CATEG )
					aPosDesc[HASH_DESCONTO_FGTS_ECONSIGNADO]				:=	AllTrim( (cAliasV5H)->V5H_CONSG  )
					aPosDesc[HASH_DESCONTO_NUMERO_CONTRATO]					:=	AllTrim( (cAliasV5H)->V5H_NRCRT  )
					aPosDesc[HASH_DESCONTO_INSTITUICAO_FINANCEIRA]			:=	AllTrim( (cAliasV5H)->V5H_INSTFI )
					aPosDesc[HASH_DESCONTO_FOLHA_DEPOSITO_CONSIGNADO]		:=	(cAliasV5H)->V5H_DECONS	

					TAFXHMAdd( oHashDesc, aPosDesc, HASH_DESCONTO_ESTABELECIMENTO, 3, HASH_DESCONTO_CPF, 3, HASH_DESCONTO_MATRICULA, 3, HASH_DESCONTO_CATEGORIA, 3, HASH_DESCONTO_LOTACAO, 3, HASH_DESCONTO_NUMERO_CONTRATO, 3, HASH_DESCONTO_INSTITUICAO_FINANCEIRA, 3 )

				EndIf

				(cAliasV5H)->( dbSkip() )
			EndDo

		EndIf

	EndIf

	If nItem == 0
		SetPercent( cTicket, 100, 100,,, lIsLegacy )
	EndIf

Return

//---------------------------------------------------------------------
/*/
InitBase
/*/
//---------------------------------------------------------------------
Static Function InitBase()

	Local aInit	:=	Array( 18 )

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
	aInit[HASH_BASE_TAF_BASE_FGTS]					:=	0
	aInit[HASH_BASE_TAF_BASE_FGTS_13_SALARIO]		:=	0
	aInit[HASH_BASE_TAF_BASE_FGTS_RESCISORIO]		:=	0
	aInit[HASH_BASE_GOVERNO_BASE_FGTS]				:=	0
	aInit[HASH_BASE_GOVERNO_BASE_FGTS_13_SALARIO]	:=	0
	aInit[HASH_BASE_GOVERNO_BASE_FGTS_RESCISORIO]	:=	0
	aInit[HASH_BASE_GOVERNO_LOCALIZADO]				:=	.F.

Return( aInit )

//---------------------------------------------------------------------
/*/
InitDeposito
/*/
//---------------------------------------------------------------------
Static Function InitDeposito()

	Local aInit	:=	Array( 20 )

	aInit[HASH_DEPOSITO_RECIBO_TRANSMISSAO]					:= ""
	aInit[HASH_DEPOSITO_CPF]								:= ""
	aInit[HASH_DEPOSITO_NOME]								:= ""
	aInit[HASH_DEPOSITO_MATRICULA]							:= ""
	aInit[HASH_DEPOSITO_CATEGORIA]							:= ""
	aInit[HASH_DEPOSITO_EVENTO_ESOCIAL]						:= 0
	aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS]				:= 0
	aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_13_SALARIO]		:= 0
	aInit[HASH_DEPOSITO_FOLHA_DEPOSITO_FGTS_RESCISORIO]		:= 0
	aInit[HASH_DEPOSITO_TAF_DEPOSITO_FGTS]					:= 0
	aInit[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_13_SALARIO]		:= 0
	aInit[HASH_DEPOSITO_TAF_DEPOSITO_FGTS_RESCISORIO]		:= 0
	aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS]				:= 0
	aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_13_SALARIO]	:= 0
	aInit[HASH_DEPOSITO_GOVERNO_DEPOSITO_FGTS_RESCISORIO]	:= 0
	aInit[HASH_DEPOSITO_GOVERNO_LOCALIZADO]					:= .F.
	aInit[HASH_TOTAL_DEPOSITO_FOLHA_DEPOSITO_FGTS] 			:= 0   
	aInit[HASH_TOTAL_DEPOSITO_TAF_DEPOSITO_FGTS] 			:= 0   
	aInit[HASH_TOTAL_DEPOSITO_GOVERNO_DEPOSITO_FGTS] 		:= 0 
	aInit[HASH_DEPOSITO_FGTS_ECONSIGNADO]					:= .F.

Return( aInit )

//---------------------------------------------------------------------
/*/
InitDesc - Desconto do Valor de eConsignado
/*/
//---------------------------------------------------------------------
Static Function InitDesc()

	Local aInit	:=	Array( 16 )

	aInit[HASH_DESCONTO_RECIBO_TRANSMISSAO]				:=	""
	aInit[HASH_DESCONTO_ESTABELECIMENTO]				:=	""
	aInit[HASH_DESCONTO_CPF]							:=	""
	aInit[HASH_DESCONTO_NOME]							:=	""
	aInit[HASH_DESCONTO_MATRICULA]						:=	""
	aInit[HASH_DESCONTO_CATEGORIA]						:=	""
	aInit[HASH_DESCONTO_LOTACAO]						:=	""
	aInit[HASH_DESCONTO_EVENTO_ESOCIAL]					:=	0
	aInit[HASH_DESCONTO_GOVERNO_LOCALIZADO]				:=	.F.
	aInit[HASH_DESCONTO_NUMERO_CONTRATO]				:= 	"" 
	aInit[HASH_DESCONTO_INSTITUICAO_FINANCEIRA]			:= 	""
	aInit[HASH_DESCONTO_FOLHA_DEPOSITO_CONSIGNADO]		:= 	0                   
	aInit[HASH_DESCONTO_TAF_DEPOSITO_CONSIGNADO]		:= 	0                    
	aInit[HASH_DESCONTO_GOVERNO_DEPOSITO_CONSIGNADO]	:= 	0                  
	aInit[HASH_DESCONTO_DIVERGENCIA_CONSIGNADO]			:= 	.F.
	aInit[HASH_DESCONTO_FGTS_ECONSIGNADO]				:= 	.F.  


Return( aInit )

//---------------------------------------------------------------------
/*/{Protheus.doc} setPercent
@type			function
@description	Incrementa o percentual de processamento da requisição.
@author			Robson Santos
@since			26/08/19
/*/
//---------------------------------------------------------------------
Static Function setPercent( cTicket as Character, nItem as Numeric, nQtdRegs as Numeric, lPercRH as Logical,;
							nPercRH as Numeric, lIsLegacy as Logical )

	Local lRet		as Logical
	Local nPerc     as Numeric
	Local nDif      as Numeric
	Local nPeso     as Numeric
	Local aArea     as Array

	aArea := GetArea()
	lRet  := .F.
	nPerc := 0
	nDif  := 0
	nPeso := 50

	Default lPercRH	:= .F.
	Default nPercRH	:= 0

	If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cTicket, TamSX3( "V3J_ID" )[1] ) ) )

		If !lPercRH

			nPerc := ( Int( ( nItem / nQtdRegs ) * 100 ) * ( nPeso/100 ) )

			If lIsLegacy
				nDif := ( ( V3J->V3J_PERC + nPerc ) - V3J->V3J_PERC )
			Else
				nDif := ( nPerc - V3J->V3J_PERC )
			EndIf

		Else
			nPerc := nPercRH
		EndIf

		If nPerc > 0

			If !lPercRH
				If V3J->V3J_PERC >= nPeso
					nPerc := ( nPeso + nPerc )
				Else
					nPerc := ( V3J->V3J_PERC + nDif )
				EndIf
			EndIf
			
			RecLock( "V3J", .F. )
				V3J->V3J_PERC := Int( nPerc )
			V3J->( MsUnlock() )

		EndIf

		lRet := .T.

	EndIf

	RestArea( aArea )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetFinish
@type			function
@description	Indica a finalização do processamento da requisição.
@author			Felipe C. Seolin
@since			18/09/2019
@param			cTicket	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function SetFinish( cTicket as Character )

	Local aAreaV3J	:=	V3J->( GetArea() )

	If V3J->( MsSeek( xFilial( "V3J" ) + PadR( cTicket, TamSX3( "V3J_ID" )[1] ) ) )

		oModelV3J:SetOperation( MODEL_OPERATION_UPDATE )
		oModelV3J:Activate()
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_STATUS", "2" )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_DTRESP", Date() )
		oModelV3J:LoadValue( "MODEL_V3J", "V3J_HRRESP", StrTran( Time(), ":", "" ) )

		FWFormCommit( oModelV3J )

		oModelV3J:DeActivate()

	EndIf

	RestArea( aAreaV3J )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} GrvFGTSSint
@type			function
@description	Grava a parte sintética do relatório.
@author			Robson Santos
@since			27/08/19
/*/
//---------------------------------------------------------------------
Static Function GrvFGTSSint( aDepoSint as Array, aBaseSint as Array, nEmployees as Numeric, lDiverg as Logical, nSeq as Numeric, aDescSint as Array )

	Local oResponse		as Object
	Local aResponse		as Array
	Local aEconsig		as Array
	Local aInfoEcons	as Array

	oResponse		:=	JsonObject():New()
	aResponse		:=	{}
	aEconsig		:=  {}
	aInfoEcons		:=  {}

	oResponse["cpfNumber"]				:=	aDepoSint[1]
	oResponse["name"]					:=	aDepoSint[2]
	oResponse["esocialRegistration"]	:=	aDepoSint[3]
	oResponse["esocialCategory"]		:=	aDepoSint[4]
	oResponse["numberEmployees"]		:=	nEmployees

	oResponse["fgtsValue"]				:=	aDepoSint[6]
	oResponse["fgts13Value"]			:=	aDepoSint[7]
	oResponse["fgtsRescissionValue"]	:=	aDepoSint[8]

	oResponse["fgtsTafValue"]			:=	aDepoSint[9]
	oResponse["fgts13TafValue"]			:=	aDepoSint[10]
	oResponse["fgtsRescissionTafValue"]	:=	aDepoSint[11]

	oResponse["fgtsRetValue"]			:=	aDepoSint[12]
	oResponse["fgts13RetValue"]			:=	aDepoSint[13]
	oResponse["fgtsRescissionRetValue"]	:=	aDepoSint[14]

	oResponse["fgtsTotValue"]	    	:=	aDepoSint[15]
	oResponse["fgtsTotTafValue"]		:=	aDepoSint[16]
	oResponse["fgtsTotRetValue"]		:=	aDepoSint[17]

	If TafColumnPos("V3N_CONSG") 
		oResponse["fgtsEconsig"]	    	:=	IIF(Empty(aDescSint),.F.,.T.)
	EndIf

	//Base
	aAdd( aResponse, JsonObject():New() )

	aResponse[Len( aResponse )]["branchId"]					:=	aBaseSint[1]
	aResponse[Len( aResponse )]["lotationCode"]				:=	aBaseSint[2]

	aResponse[Len( aResponse )]["fgtsBasis"]				:=	aBaseSint[3]
	aResponse[Len( aResponse )]["fgts13Basis"]				:=	aBaseSint[4]
	aResponse[Len( aResponse )]["fgtsRescissionBasis"]		:=	aBaseSint[5]

	aResponse[Len( aResponse )]["fgtsTafBasis"]				:=	aBaseSint[6]
	aResponse[Len( aResponse )]["fgts13TafBasis"]			:=	aBaseSint[7]
	aResponse[Len( aResponse )]["fgtsRescissionTafBasis"]	:=	aBaseSint[8]

	aResponse[Len( aResponse )]["fgtsRetBasis"]				:=	aBaseSint[9]
	aResponse[Len( aResponse )]["fgts13RetBasis"]			:=	aBaseSint[10]
	aResponse[Len( aResponse )]["fgtsRescissionRetBasis"]	:=	aBaseSint[11]

	oResponse["basis"] := aResponse
	
	//eConsignado
	If !Empty(aDescSint)	

		oResponse["eConsigInfo"]								:=	JsonObject():New()
		oResponse["eConsigInfo"]["branchId"]					:=	aDescSint[1]
		oResponse["eConsigInfo"]["lotationCode"]				:=	aDescSint[2]

		aAdd( aInfoEcons, JsonObject():New() )

		aInfoEcons[Len( aInfoEcons )]["contractNumber"]			:=	aDescSint[3]
		aInfoEcons[Len( aInfoEcons )]["financiInst"]			:=	aDescSint[4]
		aInfoEcons[Len( aInfoEcons )]["consigErpValue"]			:=	aDescSint[5]
		aInfoEcons[Len( aInfoEcons )]["consigTafValue"]			:=	aDescSint[6]
		aInfoEcons[Len( aInfoEcons )]["consigRetValue"]			:=	aDescSint[7]
		aInfoEcons[Len( aInfoEcons )]["divergConsig"]			:=  lDiverg

		oResponse["eConsigInfo"]["infoContract"]				:=	JsonObject():New()
		oResponse["eConsigInfo"]["infoContract"] 				:=  aInfoEcons

	EndIf

	GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nSeq, 6 ), lDiverg, "1" )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} R123InitArray
Inicializa o array com as devidas posições em branco/zerada
@type  static
@author Victor A. Barbosa
@since 20/05/2019
@version 1
/*/
//---------------------------------------------------------------------
Static Function R123InitArray()

	Local aInit as array

	aInit 												:= Array(46)
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
	aInit[TAF_BASE_INSS]								:= 0
	aInit[TAF_VALOR_INSS]								:= 0
	aInit[TAF_VALOR_SALARIO_FAMILIA]					:= 0
	aInit[TAF_VALOR_SALARIO_MATERNIDADE]				:= 0
	aInit[TAF_VALOR_INSS_13_SALARIO]					:= 0
	aInit[TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		:= 0
	aInit[TAF_BASE_INSS_13_SALARIO]						:= 0
	aInit[GOVERNO_BASE_INSS]							:= 0
	aInit[GOVERNO_VALOR_INSS]							:= 0
	aInit[GOVERNO_VALOR_SALARIO_FAMILIA]				:= 0
	aInit[GOVERNO_VALOR_SALARIO_MATERNIDADE]			:= 0
	aInit[GOVERNO_BASE_INSS_13_SALARIO]					:= 0
	aInit[GOVERNO_VALOR_INSS_13_SALARIO]				:= 0
	aInit[GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= 0
	aInit[GOVERNO_LOCALIZADO]							:= .F.
	aInit[GOVERNO_GROSS_VALUE]							:= 0
	aInit[GOVERNO_DESC_GROSS_VALUE]						:= 0
	aInit[GOVERNO_13_GROSS_VALUE]						:= 0
	aInit[GOVERNO_13_DESC_GROSS_VALUE]					:= 0
	aInit[CAT_DESCRI]									:= 0
	aInit[GOVERNO_BASE_SUSPENSAO]						:= 0
	aInit[GOVERNO_BASE_TOTAL_INSS]						:= 0
	aInit[FOLHA_VALOR_BASE_PISPASEP]					:= 0
	aInit[TAF_VALOR_BASE_PISPASEP]					    := 0
	aInit[GOVERNO_VALOR_BASE_PISPASEP]					:= 0
	aInit[FOLHA_VALOR_BASE_PISPASEP_13]					:= 0
	aInit[TAF_VALOR_BASE_PISPASEP_13]					:= 0
	aInit[GOVERNO_VALOR_BASE_PISPASEP_13]				:= 0

Return aInit

//---------------------------------------------------------------------
/*/{Protheus.doc} Status
@type			method
@description	Método para consultar o percentual de execução do relatório.
@author			Felipe C. Seolin
@since			30/08/2019
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET Status QUERYPARAM companyId, requestId WSRESTFUL reportEsocialBaseConfer

	Local lRet			as Logical
	Local lIsLegacy		as Logical
	Local cEmpRequest	as Character
	Local cFilRequest	as Character
	Local cRequestID	as Character
	Local aCompany		as Array
	Local oResponse		as Json

	oResponse   := Nil
	cEmpRequest := ""
	cFilRequest := ""
	cRequestID  := ""
	aCompany    := {}
	lRet        := .T.
	lIsLegacy   := .F.

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

				lIsLegacy := TAFAlsInDic( "V5H" ) .and. !Empty( AllTrim( GetNewPar( "MV_TAFRHUR", "" ) ) )

				If ValidID( self:requestId,, lIsLegacy )

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

	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
@type			function
@description	Executa a consulta do percentual de execução do relatório.
@author			Felipe C. Seolin
@since			30/08/2019
@param			oResponse	-	Json com os valores do relatório totalizador
@param			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function GetStatus( oResponse as Json, cRequestID as Character )

	oResponse := JsonObject():New()

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )

	If V3J->( DBSeek( xFilial( "V3J" ) + cRequestID ) )

		oResponse["percent"]	:=	V3J->V3J_PERC

		If V3J->V3J_PERC == 100
			oResponse["finished"]	:= .T.	
		Else
			oResponse["finished"]	:= .F.
		EndIf

	EndIf

	TAFConOut(ProcName() + oResponse:ToJson() + ' ' +  V3J->V3J_STATUS + ' ' + cValToChar(V3J->V3J_PERC) )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FgtsValues
@type			method
@description	Método para consultar resultado do relatório de conferência de FGTS.
@author			Felipe C. Seolin
@since			29/08/2019
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET FgtsValues QUERYPARAM companyId, requestId, synthetic, differencesOnly, page, pageSize WSRESTFUL reportEsocialBaseConfer

	Local oResponse		:=	Nil

	Local cEmpRequest	:=	""
	Local cFilRequest	:=	""
	Local cRequestID	:=	""
	Local cPeriod		:=	""
	
	Local nPage			:=	1
	Local nPageSize		:=	30

	Local lSynthetic	:=	.F.
	Local lDiverg		:=	.F.
	Local lRet			:=	.T.
	Local lIsLegacy			:=	.F.

	Local aCompany		:=	{}
	Local aCPFCabec		:=  {}

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
				lIsLegacy := TAFAlsInDic( "V5H" ) .and. !Empty( AllTrim( GetNewPar( "MV_TAFRHUR", "" ) ) )

				If ValidID( self:requestId, @cPeriod, lIsLegacy,@aCPFCabec )
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

					GetReport( @oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize, "2", cPeriod, lIsLegacy, aCompany[2],aCPFCabec )

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

	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} PrepEnv
@type			function
@description	Prepara o ambiente de acordo com os parâmetros.
@author			Felipe C. Seolin
@since			16/10/2019
@param			cEmpRequest	-	Empresa indicada no parâmetro companyId
@param			cFilRequest	-	Filial indicada no parâmetro companyId
@return			lRet		-	Indica se o ambiente foi preparado
/*/
//---------------------------------------------------------------------
Function PrepEnv( cEmpRequest as Character, cFilRequest as Character, cProgName as Character ) as Logical

	Local lRet as Logical
	Local lMPP as Logical

	Default cProgName := "WSTAF010"

	lRet := .T.
	lMPP := .F.

	If FindFunction( "NewRestMPP" )
		lMPP := NewRestMPP()
	EndIf

	If !lMPP .And. Type( "cEmpAnt" ) == "U" .or. Type( "cFilAnt" ) == "U"

		TafPrepRPC( cEmpRequest, cFilRequest, "TAF", cProgName )

	ElseIf cEmpAnt <> cEmpRequest

		If !lMPP .And. FWFilExist( cEmpRequest, cFilRequest )
			TafPrepRPC( cEmpRequest, cFilRequest, "TAF", cProgName )
		Else
			lRet := .F.
		EndIf

	ElseIf cFilAnt <> cFilRequest

		cFilAnt := cFilRequest
		SM0->( dbSetOrder( 1 ) )
		SM0->( MsSeek( cEmpRequest + cFilRequest ) )

	EndIf

	If lRet
		lRet := FWFilExist( cEmpRequest, cFilRequest )
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafPrepRPC
@type			static function
@description	Prepara o ambiente de acordo com os parâmetros.
@author			Denis Souza
@since			16/03/2022
@param			cEmpRequest	-	Empresa indicada no parâmetro companyId
@param			cFilRequest	-	Filial indicada no parâmetro companyId
@param			cMod		-	Prefixo do Modulo
@param			cProgName	-	Nome do Programa
@return			Nulo
/*/
//---------------------------------------------------------------------
Static Function TafPrepRPC( cEmpRequest as Character, cFilRequest as Character, cMod as Character, cProgName as Character )

	Default cEmpRequest := ''
	Default cFilRequest := ''
	Default cMod		:= ''
	Default cProgName	:= ''

	RPCClearEnv()
	RPCSetType( 3 )
	RPCSetEnv( cEmpRequest, cFilRequest, , , cMod, cProgName )

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} GetReport
@type			function
@description	Executa a consulta do resultado do relatório de conferência de INSS.
@author			Felipe C. Seolin
@since			19/08/2019
@param			oResponse	-	Json com os valores do relatório totalizador
@param			cRequestID	-	Identificador da Requisição
@param			lSynthetic	-	Indica se o retorno deve ser sintético ou analítico
@param			lDiverg		-	Indica se deve retornar apenas as divergências
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
@param			cPeriod		-	Período de emissão do relatório
@param			lIsLegacy		-	Indica se utiliza mecanismo de busca das Bases na linha RM
@param			cTribute	-	1 - INSS | 2 - FGTS
/*/
//---------------------------------------------------------------------
Static Function GetReport( oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize, cTribute, cPeriod, lIsLegacy, cCompanyId,aCPFCabec )

	Local oJson			:=	Nil
	Local nTamV45_ID	:=	TamSX3( "V45_ID" )[1]
	Local aJson			:=	{}
	Local lHasNext		:=	.F.

	Default aCPFCabec := {}

	oResponse := JsonObject():New()

	cRequestID := PadR( cRequestID, nTamV45_ID )

	DBSelectArea( "V45" )

	If lSynthetic

		V45->( DBSetOrder( 2 ) )
		If V45->( MsSeek( xFilial( "V45" ) + cRequestID + "1" + Iif( lDiverg, "1", "2" ) ) )

			If CheckDiv(V45->V45_RESP)

				oJson := JsonObject():New()
				oJson:FromJson( V45->V45_RESP )
				aAdd( aJson, oJson )
				FreeObj( oJson )

			EndIf

		EndIf

	Else

		aJson := GetDetails( cRequestID, lDiverg, nPage, nPageSize, @lHasNext, cTribute, cPeriod, lIsLegacy, cCompanyId, aCPFCabec )

	EndIf

	oResponse["items"]		:=	aJson
	oResponse["hasNext"]	:=	lHasNext

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidID
@type			function
@description	Verifica se o Identificador da Requisição é válido.
@author			Felipe C. Seolin
@since			19/08/2019
@param			cPeriod		-	Utilizado para retornar o período por referência
@param			cRequestID	-	Identificador da Requisição
@param			lIsLegacy		-	Indica se utiliza mecanismo de busca das Bases na linha RM
@return			lRet		-	Indica se o Identificador da Requisição é válido
/*/
//---------------------------------------------------------------------
Static Function ValidID( cRequestID as Character, cPeriod as Character, lIsLegacy as Logical, aCPFCabec as Array ) as Logical

	Local lRet		as Logical
	Local oRequest	as Json

	lRet		:=	.F.
	oRequest	:=	Nil

	Default aCPFCabec := {}

	DBSelectArea( "V3J" )
	V3J->( DBSetOrder( 1 ) )
	lRet := V3J->( MsSeek( xFilial( "V3J" ) + cRequestID ) )

	If lRet .And. lIsLegacy

		oRequest  := JsonObject():New()
		oRequest:FromJson( V3J->V3J_PARAMS )
		cPeriod   := oRequest["paymentPeriod"]
		aCPFCabec := oRequest["cpfNumber"]
		FreeObj( oRequest )

	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDetails
@type			function
@description	Retorna os registros analíticos com controle de paginação.
@author			Victor A. Barbosa
@since			17/09/2019
@param			cRequestID	-	Identificador da Requisição
@param			cTribute	-	1 - INSS | 2 - FGTS | 3 - IRRF
@param			cPeriod		-	Período de emissão do relatório
@param			lDiverg		-	Indica se deve retornar apenas as divergências
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
@param			lHasNext	-	Indica se há existência de mais registros além dos retornados ( Referência )
@param			lIsLegacy		-	Indica se utiliza mecanismo de busca das Bases na linha RM
@param			cCompanyId
@param			aCPFCabec	-	CPFs que serão consultados
@return			aJson		-	Json com o resultado processado para o relatório
/*/
//---------------------------------------------------------------------
Static Function GetDetails( cRequestID as Character, lDiverg as Logical, nPage as Numeric, nPageSize as Numeric,;
							lHasNext as Logical, cTribute as Character, cPeriod as Character, lIsLegacy as Logical,;
							cCompanyId as Character, aCPFCabec as Array, cLevel  as Character, cDMDEV as character, cCPF as Character, lWarning as Logical ) as Array

	Local nRegIni		as Numeric
	Local nRegFim		as Numeric
	Local cWhere		as Character
	Local cBanco    	as Character
	Local cNextAlias	as Character
	Local aJson			as Array
	Local oJson			as Json
	Local oJsonAnalit   as Json
	Local nX            as Numeric

	Default lWarning := .F.

	aJson        := {}
	cWhere       := ""
	cBanco       := TcGetDb()
	cNextAlias   := GetNextAlias()
	nRegIni   	 := 0
	nRegFim   	 := 0
	nX           := 0
	oJson     	 := Nil
	oJsonAnalit  := JsonObject():New()

	Default aCPFCabec 	:=  {}

	If lDiverg
		cWhere := " V45.V45_DIVERG = '1' "
	Else
		cWhere := " V45.V45_DIVERG IN ('1', '2') "
	EndIf

	If TafColumnPos("V45_WARNIN")
		If lWarning 
			cWhere += " AND V45.V45_WARNIN = '1' "
		Else
			cWhere += " AND V45.V45_WARNIN IN ('1', '2') "
		EndIf
	EndIf

	cWhere	:= "%" + cWhere + "%"

	nRegIni := IIf (cBanco != "OPENEDGE", ( ( nPage - 1 ) * nPageSize ) + 1, ( nPage - 1 ) * nPageSize )
	nRegFim := nPage * nPageSize

	If cBanco != "OPENEDGE"
		BeginSQL Alias cNextAlias
			SELECT * FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) LINE_NUMBER, R_E_C_N_O_ V45_RECNO
				FROM %table:V45% V45
				WHERE V45.V45_FILIAL = %xFilial:V45%
					AND V45.V45_ID = %exp:cRequestID%
					AND V45.V45_TIPO = '2'
					AND %exp:cWhere%
					AND V45.%notdel%
			) TAB
			WHERE LINE_NUMBER BETWEEN %exp:nRegIni% AND %exp:nRegFim%
		EndSQL
	Else
		BeginSQL Alias cNextAlias
			SELECT R_E_C_N_O_ V45_RECNO
			FROM %table:V45% V45
			WHERE V45.V45_FILIAL = %xFilial:V45%
				AND V45.V45_ID = %exp:cRequestID%
				AND V45.V45_TIPO = '2'
				AND %exp:cWhere%
				AND V45.%notdel%
				OFFSET %exp:nRegIni% ROWS FETCH NEXT %exp:nRegFim% ROWS ONLY
		EndSQL
	EndIf

	( cNextAlias )->( DBGoTop() )

	While ( cNextAlias )->( !Eof() )

		V45->( DBGoTo( ( cNextAlias )->V45_RECNO ) )

		If ( lDiverg .and. V45->V45_DIVERG == "1" ) .or. !lDiverg

			oJson := JsonObject():New()
			oJson:FromJson( V45->V45_RESP )

			If cTribute == "3" .And. cLevel == "1"
				
				oJson:DelName( "demonstrative" )

			ElseIf cTribute == "3" 
				
				If cLevel == "4"

					oJsonAnalit:FromJson( V45->V45_RESP ) 
					oJson:DelName( "totalIrrfRetention" )
					oJson:DelName( "demonstrative" )
					oJson:DelName( "totalDemonstratives" )

					For nX := 1 To len( oJsonAnalit:GetJsonObject("demonstrative") )
						
						If cDMDEV == oJsonAnalit["demonstrative"][nX]["demonstrativeId"]

							oJson["demonstrative"] := oJsonAnalit["demonstrative"][nX]
							
							Exit
						EndIf

					Next nX

				ElseIf cLevel == "3"

					If cCPF == oJson["cpfNumber"]

						oJson:DelName( "totalIrrfRetention" )
						oJson:DelName( "demonstrative" )
			
					EndIf

				EndIf

			EndIf
			
			If cLevel != "3" .AND. cLevel != "9"
				aAdd( aJson, oJson )
				FreeObj( oJson )
			ElseIf cCPF == oJson["cpfNumber"] .and. cLevel == "3"
				aAdd( aJson, oJson )
				FreeObj( oJson )
				exit
			ElseIf cCPF == oJson["cpfNumber"] .and. cLevel == "9"
				aAdd( aJson, oJson )
				FreeObj( oJson )
				exit
			ElseIf cLevel != '3' .And. Empty(cCPF)
				aAdd( aJson, oJson )
				FreeObj( oJson )
			EndIf

		EndIf

		( cNextAlias )->( DBSkip() )
		
	EndDo

	( cNextAlias )->( DBCloseArea() )

	lHasNext := HasNext( cRequestID, nRegFim, lDiverg, lWarning )

Return aJson

//---------------------------------------------------------------------
/*/{Protheus.doc} HasNext
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados.
@author			Victor A. Barbosa
@since			17/09/2019
@param			cRequestID	-	Identificador da Requisição
@param			nRegFim		-	Identificador do último registro retornado
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
@param			lDiverg		-	Indica se é para filtrar somente os registros com diverências
/*/
//---------------------------------------------------------------------
Static Function HasNext( cRequestID as Character, nRegFim as Numeric, lDiverg as Logical, lWarning as Logical ) as Logical

	Local lHasNext	as Logical
	Local cWhere	as Character
	Local cBanco	as Character
	Local cAliasMax	as Character

	DEfault lWarning := .F.

	cWhere    := ""
	cBanco    := TcGetDb()
	cAliasMax := GetNextAlias()
	lHasNext  := .F.

	If lDiverg
		cWhere := " V45.V45_DIVERG = '1' "
	Else
		cWhere := " V45.V45_DIVERG IN ('1', '2') "
	EndIf

	If TafColumnPos("V45_WARNIN")
		If lWarning
			cWhere += " AND V45.V45_WARNIN = '1' "
		Else
			cWhere += " AND V45.V45_WARNIN IN ('1', '2') "
		EndIf
	EndIf

	cWhere	:= "%" + cWhere + "%"

	If cBanco != "OPENEDGE"
		BeginSQL Alias cAliasMax
			SELECT MAX(LINE_NUMBER) MAX_LINE FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) LINE_NUMBER
				FROM %table:V45% V45
				WHERE V45.V45_FILIAL = %xFilial:V45%
					AND V45.V45_ID = %exp:cRequestID%
					AND V45.V45_TIPO = '2'
					AND %Exp:cWhere%
					AND V45.%notdel%
			) TAB
		EndSQL
	Else
		BeginSQL Alias cAliasMax
			SELECT COUNT(*) MAX_LINE FROM (
				SELECT V45.V45_ID
				FROM %table:V45% V45
				WHERE V45.V45_FILIAL = %xFilial:V45%
					AND V45.V45_ID = %exp:cRequestID%
					AND V45.V45_TIPO = '2'
					AND %Exp:cWhere%
					AND V45.%notdel%
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
/*/{Protheus.doc} LoadSM0BaseCNPJ
@type			function
@description	Busca as Filias com a mesma Raiz de CNPJ.
@author			Felipe C. Seolin
@since			09/12/2019
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
		//---------------------------------------------------------------------------
		//Desconsidera Empresa não autorizada e Filiais que o usuário não tem acesso
		//---------------------------------------------------------------------------
		//If !aSM0[nI][SM0_EMPOK] .or. !aSM0[nI][SM0_USEROK]
		//	Loop
		//EndIf

		If cBaseCNPJ == AllTrim( Left( aSM0[nI][SM0_CGC], 8 ) )
			If aSM0[nI][SM0_GRPEMP] <> cEmpAnt
				If Len( aGroup ) == 0
					aAdd( aGroup, aSM0[nI][SM0_GRPEMP] )

					If !IsShared( cEmpAnt, aSM0[nI][SM0_GRPEMP] )
						Loop
					EndIf
				Else
					nPos := aScan( aGroup, {|x| x == aSM0[nI][SM0_GRPEMP] } )

					If nPos == 0
						aAdd( aGroup, aSM0[nI][SM0_GRPEMP] )

						If !IsShared( cEmpAnt, aSM0[nI][SM0_GRPEMP] )
							Loop
						EndIf
					EndIf
				EndIf
			EndIf

			aAdd( aFilial, aSM0[nI][SM0_CODFIL] )
		EndIf
	Next nI

Return( aFilial )

//---------------------------------------------------------------------
/*/{Protheus.doc} IsShared
@type			function
@description	Informa se alguma tabela do escopo eSocial está com o Grupo de Empresa compartilhado.
@author			Felipe C. Seolin
@since			09/12/2019
@param			cGrpLogged		-	Grupo de Empresa logada
@param			cGrpSameRoot	-	Grupo de Empresa que possui Filiais com Raiz de CNPJ iguais a Empresa logada
@return			lShared			-	Indica se o Grupo de Empresa comparado está compartilhado, ou seja, possui alguma tabela relacionada ao eSocial com o X2_ARQUIVO apontando para a tabela da Filial logada.
/*/
//---------------------------------------------------------------------
Static Function IsShared( cGrpLogged, cGrpSameRoot )

	Local lShared	:=	.F.

	lShared := StartJob( "TAFCSX2Share", GetEnvServer(), .T., cGrpLogged, cGrpSameRoot )

Return( lShared )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetRHValues
@type			Static function
@description	Retorna por referência o objeto serializado, contendo os valores de RH
@author			Victor A. Barbosa
@since			22/11/2019
@param			oJson		-	Objeto contendo as informações de busca dos valores, além de ser retornado por referência
@param			cPeriod		-	Período de Geração do relatório
@param			cTribute	-	1 - INSS | 2 - FGTS | 3 - IRRF
@param			lGrvRH		-	Indica se deve gravar a tabela com os valores de RH

@return			Nil
/*/
//---------------------------------------------------------------------
Static Function GetRHValues(oJson as Json, cPeriod as Character, cTribute as Character,;
							lGrvRH as Logical, cIDV3J as Character, cCompanyID as Character,;
							aHeader as Array, aCPFCabec as Array, lAnalytic as Logical, aRHValues as Array)

	Local lIsFinish		as Logical
	Local lHasNext		as Logical
	Local nPage			as Numeric
	Local nX			as Numeric
	Local nZ			as Numeric
	Local cTicket		as Character
	Local cError		as Character
	Local cPath			as Character
	Local cURLErp		as Character
	Local aSM0			as Array
	Local aEstab		as Array
	Local aLotation		as Array
	Local aCPF			as Array
	Local aMatric		as Array
	Local aCateg		as Array
	Local oResponse		as Json

	aSM0      := {}
	aEstab    := {}
	aLotation := IIf(oJson <> Nil .And. oJson["lotationCode"] <> Nil, oJson["lotationCode"], {})
	aCPF      := IIf(oJson <> Nil .And. oJson["cpfNumber"] <> Nil, oJson["cpfNumber"], {})
	aMatric   := IIf(oJson <> Nil .And. oJson["eSocialRegistration"] <> Nil, oJson["eSocialRegistration"], {})
	aCateg    := IIf(oJson <> Nil .And. oJson["eSocialCategory"] <> Nil, oJson["eSocialCategory"], {})
	cTicket   := ""
	cError    := ""
	cPath     := "/api/rh/esocial/v1/reportEsocialBaseConfer"
	cURLErp   := GetNewPar("MV_TAFRHUR")
	lIsFinish := .F.
	lHasNext  := .T.
	nPage     := 0
	nX        := 0
	nZ        := 0
	oResponse := Nil

	Default aCPFCabec 	:= {}
	Default aRHValues	:= {}
	Default lAnalytic 	:= .F.
	Default lGrvRh 		:= .F.

	If cTribute == "1"
		aSM0	:= FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {"M0_TPINSC"}) 
		aNrInsc := IIf(oJson <> Nil .And. oJson["registrationNumber"] <> Nil, oJson['registrationNumber'], {})
		
		For nZ := 1 To Len(aNrInsc)
			If AllTrim(Str(aSM0[1][2])) $ "1|3" .And. Len(AllTrim(aNrInsc[nZ])) == 14
				AAdd(aEstab, TpInscPic("3", aNrInsc[nZ]))
			ElseIf Len(AllTrim(aNrInsc[nZ])) == 14
				AAdd(aEstab, TpInscPic("1", aNrInsc[nZ]))
			ElseIf Len(AllTrim(aNrInsc[nZ])) == 11
				AAdd(aEstab, TpInscPic("2", aNrInsc[nZ]))
			ElseIf Len(AllTrim(aNrInsc[nZ])) == 12
				AAdd(aEstab, TpInscPic("4", aNrInsc[nZ]))
			EndIf
		Next 
	Else
		aEstab := IIf(oJson <> Nil .And. oJson["branchId"] <> Nil, oJson['branchId'], {})
	EndIf
	
	// Solicitação de Cálculo dos valores
	cTicket	:= CallInit(cURLErp, cPath, cCompanyID, cPeriod, aLotation, aCPF, aMatric, aEstab, aCateg, cTribute, @cError, aHeader,aCPFCabec)
	
	If !Empty(cTicket)
		
		// Fica consultando até a API retornar que o processamento foi finalizado
		lIsFinish := IsFinished(cURLErp, cPath, cTicket, cIDV3J, aHeader)
		While !lIsFinish
			lIsFinish := IsFinished(cURLErp, cPath, cTicket, cIDV3J, aHeader)
		EndDo

		If lGrvRH

			If lAnalytic
				While lHasNext
					oResponse := GetResult(cURLErp, cPath, cCompanyID, cTicket, cTribute, nPage, aHeader, "InssValues")
					
					For nX := 1 To Len(oResponse["items"])
						aAdd(aRHValues,oResponse["items"][nX] )
					Next

					lHasNext := oResponse["hasNext"]
					FreeObj(oResponse)
				EndDo
			Else

				dbSelectArea("V5H")

				While lHasNext
					nPage++
					oResponse := GetResult(cURLErp, cPath, cCompanyID, cTicket, cTribute, nPage, aHeader)

        			If Len(oResponse["items"]) > 0
						CreateV5H(oResponse, cIDV3J, cTribute )
					EndIf

					lHasNext := oResponse["hasNext"]

					FreeObj(oResponse)
				EndDo

				V5H->( dbCloseArea() )
			EndIf
		Else
			oResponse := GetResult(cURLErp, cPath, cCompanyID, cTicket, cTribute,, aHeader)
			UpdResponse(@oJson, oResponse, cTribute)
		EndIf

		FreeObj(oResponse)
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CallInit
@type			Static function
@description	Retorna por referência o objeto serializado, contendo os valores de RH
@author			Victor A. Barbosa
@since			22/11/2019
@param			cURLErp		-	URL do ERP
@param			cPath		-	Path principal para o Endpoint
@param			cCompanyID	-	Código da empresa no software de RH
@param			cPeriod		-	Período
@param			cLotation	-	Lotação
@param			cCPF		-	CPF
@param			cMatric		-	Matricula
@param			cEstab		-	Estabelecimento
@param			cCateg		- 	Categoria
@param			cTribute	- 	1 - INSS | 2 - FGTS
@param			cError		-	Retorna mensagem de erro por referência
@param			aHeader		-	Cabeçalho da requisição

@return			cTicket		-	Código do Ticket que o ERP retornou
/*/
//---------------------------------------------------------------------
Static Function CallInit(cURLErp, cPath, cCompanyID, cPeriod, aLotation, aCPF, aMatric, aEstab, aCateg, cTribute, cError, aHeader, aCPFCabec)

	Local cTicket	:= ""
	Local oRest 	:= FWRest():New(cURLErp)
	Local oRequest	:= JsonObject():New()
	Local oResponse	:= JsonObject():New()

	oRest:SetPath(cPath)
	
	oRequest["companyId"]		:= cCompanyID
	oRequest["paymentPeriod"]	:= StrTran(cPeriod, "-", "")
	oRequest["tribute"]			:= cTribute

	If ValType(aEstab) <> "U" .And. ValType(aEstab) == "A"
		oRequest["registrationNumber"] := aEstab
	EndIf

	If ValType(aLotation) <> "U" .And. ValType(aLotation) == "A"
		oRequest["lotationCode"] := aLotation
	EndIf

	If ValType(aCateg) <> "U" .And. ValType(aCateg) == "A"
		oRequest["eSocialCategory"] := aCateg
	EndIf

	If ValType(aCPF) <> "U" .And. ValType(aCPF) == "A"
		oRequest["cpfNumber"] := aCPF
	ElseIf ValType(aCPF) <> "U" .And. ValType(aCPF) == "C" .And. !Empty(aCPF)
		oRequest["cpfNumber"] := {aCPF}
	ElseIf ValType(aCPFCabec) <> "U" .And. ValType(aCPFCabec) == "A" .And. !Empty(aCPFCabec)
		oRequest["cpfNumber"] := aCPFCabec
	EndIf
	
	If ValType(aMatric) <> "U" .And. ValType(aMatric) == "A"
		oRequest["eSocialRegistration"] := aMatric
	EndIf

	TafConOut(procname() + oRequest:ToJson())

	oRest:SetPostParams(oRequest:ToJson())

	TAFConOut(procname() + ' oRequest:ToJson(): ' + oRequest:ToJson())

	If oRest:Post(aHeader)
		oResponse:FromJson(oRest:GetResult())
		
		cTicket := oResponse["requestId"]
	Else
		TAFConOut("[" + ProcName() + "] " + oRest:GetLastError() + ": Falha na conexão com a API do software de RH. API indisponível: " + cURLErp + cPath)
	EndIf

	FwFreeObj(oRest)
	FwFreeObj(oRequest)
	FwFreeObj(oResponse)

Return cTicket

//---------------------------------------------------------------------
/*/{Protheus.doc} IsFinished
@type			Static function
@description	Retorna por referência o objeto serializado, contendo os valores de RH
@author			Victor A. Barbosa
@since			22/11/2019
@param			cURLErp		-	URL do ERP
@param			cPath		-	Path principal para o Endpoint
@param			cTicket		-	Ticket a ser consultado o percentual
@param			cTicketV3J
@param			aHeader		-	Cabeçalho da requisição

@return			lRet		- 	Indica que a API retornou que o cálculo foi concluído
/*/
//---------------------------------------------------------------------
Static Function IsFinished(cURLErp, cPath, cTicket, cTicketV3J, aHeader)

	Local lRet      := .F.
	Local oRest     := FWRest()    :New(cURLErp)
	Local oResponse := JsonObject():New()
	Local cEndPoint := cPath + "/Status/" + AllTrim(cTicket)
	Local nPercent  := 0

	// Manter compatibilidade com a função SetPercent ...
	Private oModelV3J		:=	FWLoadModel( "TAFA531")

	oRest:SetPath(cEndPoint)

	If oRest:Get(aHeader)
		oResponse:FromJson(oRest:GetResult())
		lRet 		:= oResponse["finished"]
		nPercent	:= (oResponse["percent"] / 3)
		SetPercent( cTicketV3J,,, .T., nPercent, .T. )
	EndIf

	FreeObj(oRest)
	FreeObj(oResponse)
	FreeObj(oModelV3J)

Return(lRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GetResult
@type			Static function
@description	Retorna por referência o objeto serializado, contendo os valores de RH
@author			Victor A. Barbosa
@since			22/11/2019
@param			cURLErp		-	URL do ERP
@param			cPath		-	Path principal para o Endpoint
@param			cCompanyID	-	Código do Empresa no software de RH
@param			cTicket		-	Ticket a ser consultado o percentual
@param			cTribute	-	1 - INSS | 2 - FGTS
@param			nPage		-	Página que deverá ser retornada
@param			aHeader		-	Cabeçalho da requisição

@return			Nil
/*/
//---------------------------------------------------------------------
Static Function GetResult(cURLErp as Character, cPath as Character, cCompanyID as Character, cTicket as Character, cTribute as Character, nPage as Numeric, aHeader as Array, cReport as Character) as Json

	Local oRest     as Object
	Local oResponse as Json
	Local cEndPoint as Character
	Local cError    as Character

	oRest     := FWRest():New(cURLErp)
	oResponse := JsonObject():New()
	cEndPoint := ""
	cError    := "" 

	Default cReport		:= Iif(cTribute == "1", "InssRetValues", Iif(cTribute == "3", "IrrfRetValues", "FgtsValues"))

	Default nPage := 1

	cEndPoint	:= cPath + "/" + cReport + "?companyId=" + cCompanyID + "&requestId=" +;
		AllTrim(cTicket) + "&page=" + cValToChar(nPage) + "&pageSize=50"

	If cTribute == "3"
		cEndPoint += "&level=9"
	EndIf

	oRest:SetPath(cEndPoint)

	If oRest:Get(aHeader)
		oResponse:FromJson(oRest:GetResult())
	Else
		cError := "Erro ao retornar os valores da FOLHA. " + oRest:GetLastError()
		TAFConOut(procname() + cError)
		oResponse["hasNext"] := .F.
		oResponse["items"]   := {}
	EndIf

	FreeObj(oRest)  
	

Return(oResponse)

//---------------------------------------------------------------------
/*/{Protheus.doc} GetHeader
@type			Static function
@description	Retorna o Header das requisições
@author			Victor A. Barbosa
@since			22/11/2019

@return			aHeader - Header das Requisições
/*/
//---------------------------------------------------------------------
Static Function GetHeader()

	Local aHeader 	:= {}
	Local cUser		:= GetNewPar("MV_TAFRHLG")
	Local cPass		:= GetNewPar("MV_TAFRHPW")

	aAdd(aHeader, "Content-Type: application/json")
	Aadd(aHeader, "Authorization: Basic " + Encode64(cUser+":"+cPass) )

Return(aHeader)

//---------------------------------------------------------------------
/*/{Protheus.doc} UpdResponse
@type			Static function
@description	Atualiza o JSON de retorno e devolve por referência
@author			Victor A. Barbosa
@since			26/11/2019
@param			oJson		-	Objeto JSON que será atualizado e retornado por referência
@param			oResponse	-	Objeto com a resposta do software de RH
@param			cTribute	-	1 - INSS | 2 - FGTS | 3 - IRRF

@return
/*/
//---------------------------------------------------------------------
Static Function UpdResponse(oJson, oResponse, cTribute)

	Local nX			:= 0
	Local nPosKey		:= 0
	Local aBasis		:= {}
	Local cBranchID		:= ""

	If Len(oResponse["items"]) > 0
		If cTribute == "1"
			oJson["inssBasis"]		:= oResponse["items"][1]["inssBasis"]
			oJson["inss13Basis"]	:= oResponse["items"][1]["inss13Basis"]
		ElseIf cTribute == "2"

			aBasis := oResponse["items"][1]["basis"]
			For nX := 1 To Len(aBasis)

				cBranchID := StrTran(aBasis[nX]["branchId"], ".", "")
				cBranchID := StrTran(cBranchID, "/", "")
				cBranchID := StrTran(cBranchID, "-", "")

				nPosKey	:= aScan( oJson["basis"],;
					{ |x| AllTrim(x["lotationCode"]) + AllTrim(x["branchId"]) == aBasis[nX]["lotationCode"] + cBranchID } )

				If nPosKey > 0
					oJson["basis"][nPosKey]["fgtsBasis"]			:= aBasis[nX]["fgtsBasis"]
					oJson["basis"][nPosKey]["fgts13Basis"]			:= aBasis[nX]["fgts13Basis"]
					oJson["basis"][nPosKey]["fgtsRescissionBasis"]	:= aBasis[nX]["fgtsRescissionBasis"]
				EndIf

				nPosKey := 0
			Next nX
		EndIf
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateV5H
@type			Static function
@description	Gravação da Tabela V5H com os valores do software de RH
@author			Victor A. Barbosa
@since			27/11/2019
@param			oResponse	-	Objeto JSON contendo o retorno do software de RH
@param			cTicket	 	-	ID da V3J
@param			cTribute	-	1 - INSS | 2 - FGTS | 3 - FGTS

@return
/*/
//---------------------------------------------------------------------
Static Function CreateV5H( oResponse as Json, cTicket as Character, cTribute as Character )

	Local nX         as Numeric
	Local nY         as Numeric
	Local nZ         as Numeric
	Local nTamCateg  as Numeric
	Local nTamEstab  as Numeric
	Local nTamLotac  as Numeric
	Local nTamMatric as Numeric
	Local nTamCPF    as Numeric
	Local nTcomp     as numeric
	Local nVlTotDm   as numeric 
	Local cCateg     as Character
	Local cEstab     as Character
	Local cLotacao   as Character
	Local cMatric    as Character
	Local cCPF       as Character
	Local cName      as Character
	Local cPeriod    as character
	Local cEvento    as character

	nX         := 0
	nY         := 0
	nZ         := 0
	nTamCateg  := GetSX3Cache("V5H_CATEG", "X3_TAMANHO")
	nTamEstab  := GetSX3Cache("V5H_ESTABE", "X3_TAMANHO")
	nTamLotac  := GetSX3Cache("V5H_LOTACA", "X3_TAMANHO")
	nTamMatric := GetSX3Cache("V5H_MATRIC", "X3_TAMANHO")
	nTamCPF    := GetSX3Cache("V5H_CPF", "X3_TAMANHO")
	nTcomp     := 0
	nVlTotDm   := 0
	cCateg     := PadR("", nTamCateg)
	cEstab     := PadR("", nTamEstab)
	cLotacao   := PadR("", nTamLotac)
	cMatric    := PadR("", nTamMatric)
	cCPF       := PadR("", nTamCPF)
	cPeriod    := ""
	cEvento    := ""

	If cTribute == "1"

		For nX := 1 To Len(oResponse["items"])

			cEstab		:= PadR(cValToChar(oResponse["items"][nX]["branchId"]), nTamEstab)	
			cCateg		:= PadR(cValToChar(oResponse["items"][nX]["esocialCategory"]), nTamCateg)	
			cLotacao	:= PadR(oResponse["items"][nX]["lotationCode"], nTamLotac)
			cMatric		:= PadR(oResponse["items"][nX]["esocialRegistration"], nTamMatric)
			cCPF		:= PadR(oResponse["items"][nX]["cpfNumber"], nTamCPF)
		
			If !V5H->(MsSeek(xFilial("V5H") + cTicket + cCPF + cCateg + cEstab + cLotacao + cMatric + cTribute))

				If RecLock("V5H", .T.)
					V5H->V5H_FILIAL	:= xFilial("V5H")
					V5H->V5H_ID    	:= cTicket
					V5H->V5H_CPF   	:= cCPF
					V5H->V5H_NOME	:= oResponse["items"][nX]["name"]
					V5H->V5H_MATRIC	:= cMatric
					V5H->V5H_CATEG	:= cCateg
					V5H->V5H_ESTABE	:= cEstab
					V5H->V5H_LOTACA	:= cLotacao
					V5H->V5H_BSINSS	:= oResponse["items"][nX]["inssBasis"]
					V5H->V5H_VLINSS	:= oResponse["items"][nX]["inssGrossValue"]
					V5H->V5H_VLFAM 	:= oResponse["items"][nX]["familySalaryValue"]
					V5H->V5H_VLMAT 	:= oResponse["items"][nX]["maternitySalaryValue"]
					V5H->V5H_BS13  	:= oResponse["items"][nX]["inss13Basis"]
					V5H->V5H_VL13  	:= oResponse["items"][nX]["inss13GrossValue"]
					V5H->V5H_VLMT13	:= oResponse["items"][nX]["maternitySalary13Value"]

					If TafColumnPos("V5H_PISPAS")
						V5H->V5H_PISPAS	:= oResponse["items"][nX]["pisPasepBasis"]
						V5H->V5H_PIS13	:= oResponse["items"][nX]["pisPasep13Basis"]
					EndIf

					V5H->V5H_TIPO	:= cTribute
					
					V5H->(MsUnlock())
				EndIf
				
			EndIf
		Next nX

	ElseIf cTribute == "2"
        
		For nX := 1 To Len(oResponse["items"])

			For nY := 1 To Len(oResponse["items"][nX]["basis"])

				If Valtype(oResponse["items"][nX]["eConsigInfo"]["infoContract"]) != 'U' .And. TafColumnPos("V5H_CONSG")

					For nZ := 1 To Len(oResponse["items"][nX]["eConsigInfo"]["infoContract"])

						cCateg		:= PadR( cValToChar(oResponse["items"][nX]["esocialCategory"]), nTamCateg )
						cEstab		:= PadR( GetBranchID(oResponse["items"][nX]["eConsigInfo"]["branchId"]), nTamEstab )
						cLotacao	:= PadR( oResponse["items"][nX]["eConsigInfo"]["lotationCode"], nTamLotac )
						cMatric		:= PadR( oResponse["items"][nX]["esocialRegistration"], nTamMatric )
						cCPF		:= PadR( oResponse["items"][nX]["cpfNumber"], nTamCPF )

						If !V5H->( MsSeek( xFilial("V5H") + cTicket + cCPF + cCateg + cEstab + cLotacao + cMatric + cTribute ) )
							RecLock("V5H", .T.)
							V5H->V5H_FILIAL	:= xFilial("V5H")
							V5H->V5H_ID    	:= cTicket
							V5H->V5H_CPF   	:= cCPF
							V5H->V5H_CATEG	:= cCateg
							V5H->V5H_ESTABE	:= cEstab
							V5H->V5H_LOTACA	:= cLotacao
							V5H->V5H_MATRIC	:= cMatric
							V5H->V5H_NOME	:= oResponse["items"][nX]["name"]
							V5H->V5H_VLFGTS	:= oResponse["items"][nX]["fgtsValue"]
							V5H->V5H_VLFG13	:= oResponse["items"][nX]["fgts13Value"]
							V5H->V5H_VLFGRE	:= oResponse["items"][nX]["fgtsRescissionValue"]
							V5H->V5H_BSFGTS	:= oResponse["items"][nX]["basis"][nY]["fgtsBasis"]
							V5H->V5H_BSFG13	:= oResponse["items"][nX]["basis"][nY]["fgts13Basis"]
							V5H->V5H_BSFGRE	:= oResponse["items"][nX]["basis"][nY]["fgtsRescissionBasis"]
							V5H->V5H_CONSG 	:= .T.
							V5H->V5H_NRCRT 	:= oResponse["items"][nX]["eConsigInfo"]["infoContract"][nZ]['contractNumber']
							V5H->V5H_INSTFI := oResponse["items"][nX]["eConsigInfo"]["infoContract"][nZ]['financiInst']  
							V5H->V5H_DECONS := oResponse["items"][nX]["eConsigInfo"]["infoContract"][nZ]['consigErpValue']
							V5H->V5H_TIPO	:= cTribute
							V5H->( MsUnlock() )
						EndIf

					Next nZ	

				Else

						cCateg		:= PadR( cValToChar(oResponse["items"][nX]["esocialCategory"]), nTamCateg )
						cEstab		:= PadR( GetBranchID(oResponse["items"][nX]["basis"][nY]["branchId"]), nTamEstab )
						cLotacao	:= PadR( oResponse["items"][nX]["basis"][nY]["lotationCode"], nTamLotac )
						cMatric		:= PadR( oResponse["items"][nX]["esocialRegistration"], nTamMatric )
						cCPF		:= PadR( oResponse["items"][nX]["cpfNumber"], nTamCPF )

						If !V5H->( MsSeek( xFilial("V5H") + cTicket + cCPF + cCateg + cEstab + cLotacao + cMatric + cTribute ) )
							RecLock("V5H", .T.)
							V5H->V5H_FILIAL	:= xFilial("V5H")
							V5H->V5H_ID    	:= cTicket
							V5H->V5H_CPF   	:= cCPF
							V5H->V5H_CATEG	:= cCateg
							V5H->V5H_ESTABE	:= cEstab
							V5H->V5H_LOTACA	:= cLotacao
							V5H->V5H_MATRIC	:= cMatric
							V5H->V5H_NOME	:= oResponse["items"][nX]["name"]
							V5H->V5H_VLFGTS	:= oResponse["items"][nX]["fgtsValue"]
							V5H->V5H_VLFG13	:= oResponse["items"][nX]["fgts13Value"]
							V5H->V5H_VLFGRE	:= oResponse["items"][nX]["fgtsRescissionValue"]
							V5H->V5H_BSFGTS	:= oResponse["items"][nX]["basis"][nY]["fgtsBasis"]
							V5H->V5H_BSFG13	:= oResponse["items"][nX]["basis"][nY]["fgts13Basis"]
							V5H->V5H_BSFGRE	:= oResponse["items"][nX]["basis"][nY]["fgtsRescissionBasis"]
							V5H->V5H_TIPO	:= cTribute
							V5H->( MsUnlock() )
						EndIf

				EndIf		

			Next nY

		Next nX

	ElseIf cTribute == "3" .AND. TafColumnPos("V5H_DMDEV")

		For nX := 1 To Len(oResponse["items"])

			If ValType(oResponse["items"][nX]["totalIRRFCompany"]) != 'U'
				nTcomp := oResponse["items"][nX]["totalIRRFCompany"]["erpValue"]
			EndIf 

			For nY := 1 To Len(oResponse["items"][nX]["employees"])

				cCPF		:= PadR( oResponse["items"][nX]["employees"][nY]["cpfNumber"], nTamCPF )
				cName       := Alltrim(oResponse["items"][nX]["employees"][nY]["name"]) 
				cPeriod     := oResponse["items"][nX]["employees"][nY]["period"]

				dbSelectArea("V5H")
				dbSetOrder(2)

				If Valtype(oResponse["items"][nX]["employees"][nY]["demonstrative"]) != 'U'
					For nZ := 1 To Len(oResponse["items"][nX]["employees"][nY]["demonstrative"])

						cIdDev      := PadR( cValToChar(oResponse["items"][nX]["employees"][nY]["demonstrative"][nZ]["demonstrativeId"]), 30 )
						cCateg		:= PadR( cValToChar(oResponse["items"][nX]["employees"][nY]["demonstrative"][nZ]["category"]), nTamCateg )
						cEstab		:= PadR( "", nTamEstab )
						cLotacao	:= PadR( "", nTamLotac )
						cMatric		:= PadR( "", nTamMatric )
						cEvento     := Strtran(oResponse["items"][nX]["employees"][nY]["demonstrative"][nZ]["origin"],"-", "")
					
						If Valtype(oResponse["items"][nX]["employees"][nY]["totalIrrfRetention"]) != 'U'
							nVlTotDm    := oResponse["items"][nX]["employees"][nY]["totalIrrfRetention"]["erpValue"] 
						EndIf 

						If !V5H->( DBSeek( xFilial("V5H") + cTicket + cCPF + cMatric + cTribute + cIdDev ) )

							RecLock("V5H", .T.)

								V5H->V5H_FILIAL	:= xFilial("V5H")
								V5H->V5H_ID    	:= cTicket
								V5H->V5H_CPF   	:= cCPF
								V5H->V5H_CATEG	:= cCateg
								V5H->V5H_TIRFC  := nTcomp
								V5H->V5H_ESTABE	:= cEstab
								V5H->V5H_LOTACA	:= cLotacao
								V5H->V5H_MATRIC	:= cMatric
								V5H->V5H_NOME	:= cName
								V5H->V5H_DMDEV	:= cIdDev
								V5H->V5H_EVENTO	:= cEvento
								V5H->V5H_VLFGRE	:= oResponse["items"][nX]["employees"][nY]["demonstrative"][nZ]["irrfRetention"]["erpValue"] //CAMPO PROVISORIO PARA VALORES POR DEMOSTRATIVO
								If ValType(oResponse["items"][nX]["employees"][nY]["demonstrative"][nZ]['typesIrrfValues']) != 'U'
									If TafColumnPos( "V5H_DETAIL" ); V5H->V5H_DETAIL := oResponse["items"][nX]["employees"][nY]["demonstrative"][nZ]['typesIrrfValues']:toJson(); EndIf
								EndIf 
								V5H->V5H_VLTDMR	:= nVlTotDm
								V5H->V5H_PERAPU := Strtran(cPeriod,"-","")
								If ValType(oResponse["items"][nX]["employees"][nY]["demonstrative"][nZ]["payday"]) != 'U'
									V5H->V5H_DTPAG  := Stod(Strtran(oResponse["items"][nX]["employees"][nY]["demonstrative"][nZ]["payday"],"-",""))
								EndIf 
								V5H->V5H_TIPO	:= cTribute

							V5H->( MsUnlock() )

						EndIf
					Next nZ
				EndIf 

			Next nY

		Next nX
		
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} V5HByTicket
@type			Static function
@description	Retorno da Tabela V5H com os valores do software de RH
@author			Victor A. Barbosa
@since			27/11/2019
@param			cTicket	 	-	ID da V3J
@param			cCPF		-	Filtrar CPF específico
@param			cTribute	-	1 - INSS
								2 - FGTS
								3 - IRRF
								(vazio) - TODOS

@return			cAliasRet	-	Alias com a V5H filtrada
/*/
//---------------------------------------------------------------------
Static Function V5HByTicket(cTicket as Character, cCPF as Character, cTribute as Character, aCateg as Array) as Character

	Local cAliasV5H	as Character
	Local cQryCPF	as Character
	Local cQryCat   as Character 
	Local cFields	as Character
	Local nI        as numeric

	Default cTribute 	:= " "
	Default cCPF		:= ""	
	Default aCateg      := {}

	cQryCat := ""
	nI      := 0

	If Len( aCateg ) > 0

		cQryCat := "%("

		For nI := 1 to Len(aCateg)
			
			If nI > 1
				cQryCat += ",'"  + aCateg[nI]+ "'"
			Else
				cQryCat += "'"  + aCateg[nI] + "'"
			EndIf
			
		Next nI

		cQryCat += ")%"

	Endif

	cAliasV5H	:= GetNextAlias()	
	cQryCPF		:= "%" + IIf(Empty(cCPF), "IS NOT NULL", "= '" + cCPF + "'")  + "%"
	cFields		:= "V5H_CPF, V5H_NOME, V5H_MATRIC, V5H_CATEG, V5H_ESTABE, V5H_LOTACA" // Campos Id Trabalhador	

	If cTribute $ ("1| ") // Campos INSS

		cFields += ", V5H_BSINSS, V5H_VLINSS, V5H_VLFAM,V5H_VLMAT, V5H_BS13, V5H_VL13, V5H_VLMT13"	

		If TafColumnPos("V5H_PISPAS")
			cFields += ", V5H_PISPAS, V5H_PIS13"
		EndIf

	EndIf	

	If cTribute $ ("2| ") // Campos FGTS
		cFields += ", V5H_VLFGTS, V5H_VLFG13, V5H_VLFGRE, V5H_BSFGTS, V5H_BSFG13, V5H_BSFGRE"	

		If TafColumnPos("V5H_CONSG")
			cFields += ", V5H_CONSG, V5H_NRCRT, V5H_INSTFI, V5H_DECONS"
		EndIf	
	EndIf

	If cTribute $ ("3| ") // Campos IRRF
		cFields += ", V5H_TIRFC, V5H_PERAPU, V5H_DMDEV, V5H_DTPAG, V5H_VLDMRE, V5H_VLFGRE, V5H_VLTDMR, V5H_EVENTO"
		If TafColumnPos( "V5H_DETAIL" ); cFields += ", V5H_DETAIL"; EndIf
	EndIf

	cFields		:= "%" + cFields + "%"	

	If Select(cAliasV5H) > 0
		(cAliasV5H)->( dbCloseArea() )
	EndIf
	
	If Len( aCateg ) > 0 .AND. cTribute == "3"

		BeginSQL Alias cAliasV5H
			SELECT %Exp:cFields%
			FROM %table:V5H% V5H
			WHERE 	V5H_FILIAL = %xFilial:V5H%
			AND		V5H_ID = %Exp:cTicket%
			AND 	V5H_CPF %Exp:cQryCPF%
			AND 	V5H_CATEG IN %Exp:cQryCat%
			AND		V5H.%notdel%
		EndSQL

	Else

		BeginSQL Alias cAliasV5H
			SELECT %Exp:cFields%
			FROM %table:V5H% V5H
			WHERE 	V5H_FILIAL = %xFilial:V5H%
			AND		V5H_ID = %Exp:cTicket%
			AND 	V5H_CPF %Exp:cQryCPF%
			AND		V5H.%notdel%
		EndSQL

	EndIf

	(cAliasV5H)->( dbGoTop() )

	If (cAliasV5H)->( Eof() )
		cAliasV5H := ""
	EndIf

Return(cAliasV5H)

//---------------------------------------------------------------------
/*/{Protheus.doc} GetBranchID
@type			Static function
@description	Retorna o BranchID formatado
@author			Victor A. Barbosa
@since			29/11/2019
@param			cTicket	 	-	BranchID

@return			cAliasRet	-	BranchID formatado
/*/
//---------------------------------------------------------------------
Static Function GetBranchID(cBranchID)

	Local cBranchRet	:= ""

	cBranchRet := StrTran(cBranchID, ".", "")
	cBranchRet := StrTran(cBranchRet, "/", "")
	cBranchRet := StrTran(cBranchRet, "-", "")

Return(cBranchRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} CheckDiv
@type			Static function
@description	Função para verificar se existe uma divergência ou não no relatório
@author			Diego Santos
@since			15/05/2020
@param			cResponse	 -	V45->V45_RESP

@return			lRet	-	.T. = Existe Divergência no relatório, .F. = Não existe divergência no relatório
/*/
//---------------------------------------------------------------------
Static Function CheckDiv(cResponse)

	Local lRet := .F.
	Local aValores
	Local nCont
	Local aAux

	aValores := StrTokArr( StrTran( StrTran( StrTran( StrTran( StrTran( StrTran( V45->V45_RESP, '"basis":', ""), "]", ""), "[", ""),'"', "") , "{", ""), "}", ""), "," )

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
/*/{Protheus.doc} GetFilRH
@type			Static function
@description	Realiza o de-para das filiais do TAF com as coligadas do RH
@author			Matheus Prada
@since			23/09/2020
@return			Retorna a filial do RH
/*/
//---------------------------------------------------------------------
Static Function GetFilRH(aHeader as array)

	Local aInfoFilial 	as array
	Local cAPI			as character
	Local cURLErp		as character
	Local oRest			as object
	Local oResponse		as object
	Local xResponse		as variant

    aInfoFilial := TAFGFilMatriz()
	cAPI		:= "/api/rh/esocial/v1/reportEsocialBaseConfer/company/"
	cURLErp		:= GetNewPar("MV_TAFRHUR")
	oRest		:= Nil
	oResponse	:= Nil
	xResponse	:= Nil

	oRest := FWRest():New(cURLErp)
	
	If LEN(aInfoFilial) == 8
		oRest:SetPath(cAPI + StrTran(aInfoFilial[8], " ", "%20"))
	else
		oRest:SetPath(cAPI + StrTran(cEmpAnt, " ", "%20") + StrTran(cFilAnt, " ", "%20"))
	EndIf
	
	If oRest:Get(aHeader)

		oResponse := JsonObject():New()

		oResponse:FromJSON(oRest:GetResult())

		xResponse := oResponse["companyId"]

	Else

		TAFConOut("[" + ProcName() + "] " + oRest:GetLastError() + ": Falha na conexão com a API do software de RH. API indisponível: " + cURLErp + cAPI)

		If ProcName(1) == "GET_LEGACYSTATUS"
			xResponse := "(ERRO " +  oRest:GetLastError() + ") Mensagem: " + IIF(oRest:GetResult() == Nil,"undefined", oRest:GetResult())
		EndIf

	EndIf

Return xResponse

//---------------------------------------------------------------------
/*/{Protheus.doc} InssRetValues
@type			method
@description	Método para consultar os valores sintéticos do Relatório de conferência de INSS
@author		
@since			
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET InssRetValues QUERYPARAM companyId, requestId, differencesOnly, synthetic, page, pageSize WSRESTFUL reportEsocialBaseConfer

	Local oResponse		:=	Nil
	Local cEmpRequest	:=	""
	Local cFilRequest	:=	""
	Local cRequestID	:=	""
	Local cPeriod		:=	""

	Local nPage			:=	1
	Local nPageSize		:=	15

	Local lDiverg		:=	.F.
	Local lRet			:=	.T.
	Local lIsLegacy		:=	.F.
	Local lSynthetic	:=	.F.

	Local aCompany		:=	{}
	Local aCPFCabec		:=  {}

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
				lIsLegacy := TAFAlsInDic( "V5H" ) .and. !Empty( AllTrim( GetNewPar( "MV_TAFRHUR", "" ) ) )

				If ValidID( self:requestId, @cPeriod, lIsLegacy, @aCPFCabec )
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

					GetInssRet( @oResponse, cRequestID, lSynthetic,  lDiverg, nPage, nPageSize, cPeriod, lIsLegacy, self:companyId,aCPFCabec)

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

	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetIrrfRet
	Executa a consulta do resultado do Relatório de conferência de IRRF.

	@type  Static Function
	@author Alexandre de Lima Santos / Fábio Mendonça
	@since 01/08/2023
	@version 1.0
	@param param_name, param_type, param_descr
/*/
//---------------------------------------------------------------------
Static Function GetIrrfRet( oResponse as Json, cRequestID as Character, lSynthetic as Logical, cLevel as Character, cCPF as Character,;
							lDiverg as Logical, lWarning as Logical, nPage as Numeric, nPageSize as Numeric, cPeriod as Character, lIsLegacy as Logical,;
							cCompanyId as Character, aCPFCabec as Array, cDMDEV as Character )

	Local lHasNext		as Logical
	Local nIndex		as Numeric
	Local aJson			as Array

	Default aCPFCabec	:= {}
	Default cDMDEV      := ""
	
	oResponse          := JsonObject():New()
	oResponse["items"] := {}
	cRequestID         := PadR( cRequestID, TamSX3( "V45_ID" )[1] )
	aJson              := {}
	lHasNext           := .F.
	nIndex			   := IIf( !lSynthetic .And. TafColumnPos("V45_CPF"), 3, 2 )

	DBSelectArea( "V45" )

	If lSynthetic .Or. cLevel $ "2"

		V45->( DBSetOrder( nIndex ) )
                                                                                                                         
		If V45->( MsSeek( xFilial( "V45" ) + cRequestID + IIf( lSynthetic, "1", "2" ) + IIf( lSynthetic, IIf( lDiverg, "1", "2" ), cCPF ) ) )

			If CheckDiv( V45->V45_RESP )

				oJson := JsonObject():New()
				oJson:FromJson( V45->V45_RESP )
				
				If lSynthetic

					aAdd( oResponse["items"], oJson )

				Else

					If cLevel == '2'
				    	oJson:DelName( "totalDemonstratives" )
						oJson:DelName( "totalIrrfRetention" )
					EndIf

					aAdd( oResponse["items"], ParserObjEmployee(oJson) )

				EndIf

				FreeObj( oJson )
				
			EndIf

		EndIf

	Else

 		aJson := GetDetails( cRequestID, lDiverg, nPage, nPageSize, @lHasNext, '3', cPeriod, lIsLegacy, cCompanyId, aCPFCabec, cLevel, cDMDEV, cCPF, lWarning )
		aAdd( oResponse["items"], ParserObjEmployee( aJson ) )

	EndIf

	oResponse["hasNext"]	:=	lHasNext

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ParserObjEmployee
	(long_description)
	@type  Static Function
	@author user
	@since 11/08/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
//---------------------------------------------------------------------
Static Function ParserObjEmployee( xEmployeeData as Any ) as Array

	Local oEmployee		as Json
	Local aEmployeeData	as Array
	
	aEmployeeData := {}
	
	If ValType( xEmployeeData ) == "A"
		aEmployeeData := xEmployeeData
	Else
		aAdd( aEmployeeData, xEmployeeData )
	EndIf

	oEmployee              := JsonObject():New()
	oEmployee["employees"] := aEmployeeData
	
Return oEmployee

//---------------------------------------------------------------------
/*/{Protheus.doc} GetInssRet
@type			function
@description	Executa a consulta do resultado do relatório de conferência de INSS.
@author			Verônica de Almeida
@since			19/07/2021
@param			oResponse	-	Json com os valores do relatório totalizador
@param			cRequestID	-	Identificador da Requisição
@param			lSynthetic	-	Indica se o retorno deve ser sintético ou analítico
@param			lDiverg		-	Indica se deve retornar apenas as divergências
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
@param			cPeriod		-	Período de emissão do relatório
@param			lIsLegacy		-	Indica se utiliza mecanismo de busca das Bases na linha RM
@param			cCompanyId - Identificados da empresa e filial
@param			aCPFCabec	- CPFs que serão consultados
/*/
//---------------------------------------------------------------------
Static Function GetInssRet( oResponse, cRequestID, lSynthetic, lDiverg, nPage, nPageSize, cPeriod, lIsLegacy, cCompanyId,aCPFCabec )

	Local nTamV45_ID	:=	TamSX3( "V45_ID" )[1]
	Local aJson			:=	{}
	Local lHasNext		:=	.F.

	Default aCPFCabec	:= {}

	oResponse	:= JsonObject():New()
	cRequestID	:= PadR( cRequestID, nTamV45_ID )

	DBSelectArea( "V45" )

	If lSynthetic

		V45->( DBSetOrder( 2 ) )
		If V45->( MsSeek( xFilial( "V45" ) + cRequestID + "1" + Iif( lDiverg, "1", "2" ) ) )

			If CheckDiv(V45->V45_RESP)

				oJson := JsonObject():New()
				oJson:FromJson( V45->V45_RESP )
				aAdd( aJson, oJson )
				FreeObj( oJson )

			EndIf

		EndIf

	Else

		aJson := GetDetails( cRequestID, lDiverg, nPage, nPageSize, @lHasNext, '1', cPeriod, lIsLegacy, cCompanyId, aCPFCabec )

	EndIf

	oResponse["items"]		:=	aJson
	oResponse["hasNext"]	:=	lHasNext

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GetINSSVal
Escopo: INSS
Prepara os dados filtrados no formato JSON para retornar ao front.
Chamado na parte assíncrona do relatório
@author Verônica de Almeida
@since 19/07/2021
/*/
//-------------------------------------------------------------------
Static Function GetINSSVal( oReq, cTicket, lIsLegacy )

	Local oResponse			:=	Nil
	Local oArqTrb			:=	TAFXHMNew()
	Local nI				:=	1
	Local nINSSOrig			:=	0
	Local nINSSTAF			:=	0
	Local nINSSGov			:=	0
	Local aINSSSint			:=	{ "", "", "", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	Local aINSSDivSint		:=	{ "", "", "", "", "", "", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	Local aArqTrb			:=	{}
	Local aArea				:=	GetArea()
	Local lDiverg			:=	.F.
	Local lDivergTot		:=	.F.
	Local lTransmitido		:=	.F.
	Local nFuncDiverg		:= 0
	Local nFuncTotal		:= 0

	Private oModelV3J		:=	FWLoadModel( "TAFA531" )

	//Filtra os dados do INSS e gera o hash
	FilINSSRet( oReq, @oArqTrb, cTicket, lIsLegacy )

	//Grava o conteúdo dos hashs em arrays
	TAFXHMList( oArqTrb, aArqTrb )

	//Monta o retorno para a API de INSS
	For nI := 1 to Len( aArqTrb )

		oResponse := JsonObject():New()

		lTransmitido := (!Empty( aArqTrb[nI,2,1,RECIBO_TRANSMISSAO] ) ).And. aArqTrb[nI,2,1,GOVERNO_LOCALIZADO]	

		TafConOut(procname() + " lTransmitido: " + Iif( lTransmitido, "true", "false" ) + " CPF: " + aArqTrb[nI,2,1,CPFFUNC] )

		lDiverg		:= .F.
		nINSSOrig	:=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS] + aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
		nINSSTAF	:=	aArqTrb[nI,2,1,TAF_VALOR_INSS] + aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
		nINSSGov	:=	aArqTrb[nI,2,1,GOVERNO_GROSS_VALUE] + aArqTrb[nI,2,1,GOVERNO_13_GROSS_VALUE]

		// Comparo os valores da FOLHA somente se estiver configurado o parâmetro de busca na API do sistema Legado
		If lIsLegacy

			lDiverg		:=	nINSSOrig <> nINSSTAF .or. ; 
										nINSSOrig <> nINSSGov .or. ;				
										nINSSTAF <> nINSSGov .or.;
										aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] .or.;
										aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] .or.;
										aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] .or.;
										aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] .or.;
										aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] .or.;
										aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] .or.;
										aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .or.;
										aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .or.;
										aArqTrb[nI,2,1,FOLHA_VALOR_BASE_PISPASEP] <> aArqTrb[nI,2,1,TAF_VALOR_BASE_PISPASEP] .Or.;
										aArqTrb[nI,2,1,FOLHA_VALOR_BASE_PISPASEP] <> aArqTrb[nI,2,1,GOVERNO_VALOR_BASE_PISPASEP] .Or.;
										aArqTrb[nI,2,1,FOLHA_VALOR_BASE_PISPASEP_13] <> aArqTrb[nI,2,1,TAF_VALOR_BASE_PISPASEP_13] .Or.;
										aArqTrb[nI,2,1,FOLHA_VALOR_BASE_PISPASEP_13] <> aArqTrb[nI,2,1,GOVERNO_VALOR_BASE_PISPASEP_13]
		Else

			lDiverg		:=	nINSSTAF <> nINSSGov .or.;
										aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA] .or.;
										aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE] .or.;
										aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .or.;
										aArqTrb[nI,2,1,TAF_VALOR_BASE_PISPASEP] <> aArqTrb[nI,2,1,GOVERNO_VALOR_BASE_PISPASEP] .or.;
										aArqTrb[nI,2,1,TAF_VALOR_BASE_PISPASEP_13] <> aArqTrb[nI,2,1,GOVERNO_VALOR_BASE_PISPASEP_13]
		
		EndIf

		If lDiverg

			aINSSDivSint[8]		+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS]
			aINSSDivSint[10]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
			aINSSDivSint[11]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA]
			aINSSDivSint[12]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE]
			aINSSDivSint[13]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
			aINSSDivSint[28]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_BASE_PISPASEP]
			aINSSDivSint[31]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_BASE_PISPASEP_13]

			If lTransmitido

				aINSSDivSint[21]	+=	aArqTrb[nI,2,1,GOVERNO_GROSS_VALUE]
				aINSSDivSint[22]	+=	aArqTrb[nI,2,1,GOVERNO_DESC_GROSS_VALUE]
				aINSSDivSint[23]	+=	aArqTrb[nI,2,1,GOVERNO_13_GROSS_VALUE]
				aINSSDivSint[24]	+=	aArqTrb[nI,2,1,GOVERNO_13_DESC_GROSS_VALUE]
				aINSSDivSint[25]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA]
				aINSSDivSint[26]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE]
				aINSSDivSint[27]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
				aINSSDivSint[30]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_BASE_PISPASEP]
				aINSSDivSint[33]	+=  aArqTrb[nI,2,1,GOVERNO_VALOR_BASE_PISPASEP_13]

			EndIf

			aINSSDivSint[15]	+=	aArqTrb[nI,2,1,TAF_VALOR_INSS]
			aINSSDivSint[17]	+=	aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
			aINSSDivSint[18]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA]
			aINSSDivSint[19]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE]
			aINSSDivSint[20]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
			aINSSDivSint[29]	+=	aArqTrb[nI,2,1,TAF_VALOR_BASE_PISPASEP]
			aINSSDivSint[32]	+=	aArqTrb[nI,2,1,TAF_VALOR_BASE_PISPASEP_13]
			
			lDivergTot	:=	.T.

			nFuncDiverg++

		EndIf

		oResponse["cpfNumber"]								:=	aArqTrb[nI,2,1,CPFFUNC]
		oResponse["name"]									:=	aArqTrb[nI,2,1,NOMEFUNC]
		oResponse["inssGrossValue"]							:=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS]
		oResponse["inssTafGrossValue"]						:=	aArqTrb[nI,2,1,TAF_VALOR_INSS]
		oResponse["inss13GrossValue"]						:=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
		oResponse["inss13TafGrossValue"]					:=	aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
		oResponse["familySalaryValue"]						:=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA]
		oResponse["familySalaryTafValue"]					:=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA]
		oResponse["maternitySalaryValue"]					:=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE]
		oResponse["maternitySalaryTafValue"]				:=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE]
		oResponse["maternitySalary13Value"]					:=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
		oResponse["maternitySalary13TafRetValue"]			:=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] 
		oResponse["pisPasepBasis"]			                :=	aArqTrb[nI,2,1,FOLHA_VALOR_BASE_PISPASEP]
		oResponse["pisPasepTafRetBasis"]			        :=	aArqTrb[nI,2,1,TAF_VALOR_BASE_PISPASEP]
		oResponse["pisPasep13Basis"]			            :=	aArqTrb[nI,2,1,FOLHA_VALOR_BASE_PISPASEP_13]
		oResponse["pisPasep13TafRetBasis"]			        :=	aArqTrb[nI,2,1,TAF_VALOR_BASE_PISPASEP_13]

		If lTransmitido
		
			oResponse["familySalaryRetValue"]				:=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA]
			oResponse["maternitySalaryRetValue"]			:=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE]
			oResponse["maternitySalary13RetValue"]			:=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
			oResponse["pisPasepRetBasis"]                   :=  aArqTrb[nI,2,1,GOVERNO_VALOR_BASE_PISPASEP]
			oResponse["pisPasep13RetBasis"]                 :=  aArqTrb[nI,2,1,GOVERNO_VALOR_BASE_PISPASEP_13]

			oResponse["inssRetGrossValue"]					:=	aArqTrb[nI,2,1,GOVERNO_GROSS_VALUE]
			oResponse["inssRetDescGrossValue"]				:=	aArqTrb[nI,2,1,GOVERNO_DESC_GROSS_VALUE]
			oResponse["inss13RetGrossValue"]				:=	aArqTrb[nI,2,1,GOVERNO_13_GROSS_VALUE]
			oResponse["inss13DescGrossValue"]				:=	aArqTrb[nI,2,1,GOVERNO_13_DESC_GROSS_VALUE]
		
		Else

			oResponse["familySalaryRetValue"]				:=	0
			oResponse["maternitySalaryRetValue"]			:=	0
			oResponse["maternitySalary13RetValue"]			:=	0
			oResponse["pisPasepRetBasis"]                   :=  0
			oResponse["pisPasep13RetBasis"]                 :=  0

			oResponse["inssRetGrossValue"]					:=	0									
			oResponse["inssRetDescGrossValue"]				:=	0									
			oResponse["inss13RetGrossValue"]				:=	0								
			oResponse["inss13DescGrossValue"]				:=	0		

		EndIf

		oResponse["divergent"]	:=	lDiverg

		aINSSSint[8]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS]
		aINSSSint[10]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_INSS_13_SALARIO]
		aINSSSint[11]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_FAMILIA]
		aINSSSint[12]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE]
		aINSSSint[13]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
		aINSSSint[28]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_BASE_PISPASEP]
		aINSSSint[31]	+=	aArqTrb[nI,2,1,FOLHA_VALOR_BASE_PISPASEP_13]
		aINSSSint[15]	+=	aArqTrb[nI,2,1,TAF_VALOR_INSS]
		aINSSSint[17]	+=	aArqTrb[nI,2,1,TAF_VALOR_INSS_13_SALARIO]
		aINSSSint[18]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_FAMILIA]
		aINSSSint[19]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE]
		aINSSSint[20]	+=	aArqTrb[nI,2,1,TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
		aINSSSint[29]	+=	aArqTrb[nI,2,1,TAF_VALOR_BASE_PISPASEP]
		aINSSSint[32]	+=	aArqTrb[nI,2,1,TAF_VALOR_BASE_PISPASEP_13]

		If lTransmitido

			aINSSSint[21]	+=	aArqTrb[nI,2,1,GOVERNO_GROSS_VALUE]
			aINSSSint[22]	+=	aArqTrb[nI,2,1,GOVERNO_DESC_GROSS_VALUE]
			aINSSSint[23]	+=	aArqTrb[nI,2,1,GOVERNO_13_GROSS_VALUE]
			aINSSSint[24]	+=	aArqTrb[nI,2,1,GOVERNO_13_DESC_GROSS_VALUE]
			aINSSSint[25]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_FAMILIA]
			aINSSSint[26]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE]
			aINSSSint[27]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
			aINSSSint[30]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_BASE_PISPASEP]
			aINSSSint[33]	+=	aArqTrb[nI,2,1,GOVERNO_VALOR_BASE_PISPASEP_13]

			TafConOut(procname() + " Soma: " + cValToChar( aArqTrb[nI,2,1,GOVERNO_GROSS_VALUE] ) + " CPF: " + aArqTrb[nI,2,1,CPFFUNC] )
			TafConOut(procname() + " Acumulado: " + cValToChar( aINSSSint[21] ) + " CPF: " + aArqTrb[nI,2,1,CPFFUNC] )

		Else

			TafConOut(procname() + " Não transmitido: CPF: " + aArqTrb[nI,2,1,CPFFUNC] )

		EndIf

		//Grava a parte analítica
		GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nI, 6 ), lDiverg, "2" )

		SetPercent( cTicket, nI, Len( aArqTrb ),,, .F. )

		nFuncTotal++

	Next nI

	//Se não encontrou os dados
	If Len( aArqTrb ) == 0

		SetPercent( cTicket, 100, 100,,, .F. )

	Else

		//Grava a parte sintética
		GrvINSSRetValues( aINSSSint, nFuncTotal, .F.,  nI )
		GrvINSSRetValues( aINSSDivSint, nFuncDiverg, .T., ++nI  )

	EndIf

	SetFinish( cTicket )

	oModelV3J:Destroy()
	RestArea( aArea )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GrvINSSRetValues
@type			function
@description	Grava a parte sintética do relatório.
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function GrvINSSRetValues( aINSSSint, nEmployees, lDivergTot, nSeq)

	Local oResponse	:=	JsonObject():New()

	oResponse["cpfNumber"]							:=	aINSSSint[1]
	oResponse["name"]								:=	aINSSSint[2]
	oResponse["inssGrossValue"]						:=	aINSSSint[8]
	oResponse["inss13GrossValue"]					:=	aINSSSint[10]
	oResponse["familySalaryValue"]					:=	aINSSSint[11]
	oResponse["maternitySalaryValue"]				:=	aINSSSint[12]
	oResponse["maternitySalary13Value"]				:=	aINSSSint[13]
	oResponse["inssTafGrossValue"]					:=	aINSSSint[15]
	oResponse["inss13TafGrossValue"]				:=	aINSSSint[17]
	oResponse["familySalaryTafValue"]				:=	aINSSSint[18]
	oResponse["maternitySalaryTafValue"]			:=	aINSSSint[19]
	oResponse["maternitySalary13TafRetValue"]		:=	aINSSSint[20]
	oResponse["inssRetGrossValue"]					:=	aINSSSint[21]
	oResponse["inssRetDescGrossValue"]				:=	aINSSSint[22]
	oResponse["inss13RetGrossValue"]				:=	aINSSSint[23]
	oResponse["inss13DescGrossValue"]				:=	aINSSSint[24]
	oResponse["familySalaryRetValue"]				:=	aINSSSint[25]
	oResponse["maternitySalaryRetValue"]			:=	aINSSSint[26]
	oResponse["maternitySalary13RetValue"]			:=	aINSSSint[27]
	oResponse["pisPasepBasis"]			            :=	aINSSSint[28]
	oResponse["pisPasepTafRetBasis"]			    :=  aINSSSint[29]
	oResponse["pisPasepRetBasis"]			        :=	aINSSSint[30]
	oResponse["pisPasep13Basis"]			        :=	aINSSSint[31]
	oResponse["pisPasep13TafRetBasis"]			    :=  aINSSSint[32]
	oResponse["pisPasep13RetBasis"]			        :=	aINSSSint[33]

	GrvItRes( V3J->V3J_ID, oResponse:ToJson(), StrZero( nSeq, 6 ), lDivergTot, "1" )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} InssValues
@type			method
@description	Método responsável por retornar os valores analíticos do painel de INSS
@author			Verônica de Almeida
@since			19/07/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET InssValues QUERYPARAM companyId, requestId, synthetic, differencesOnly, cpfNumber, page, pageSize WSRESTFUL reportEsocialBaseConfer

	Local oResponse			as object
	Local oReqV3J 			as object
	Local cEmpRequest		as character
	Local cFilRequest		as character
	Local cRequestID		as character
	Local cPeriod			as character
	Local lRet				as logical
	Local aCompany			as array

	oResponse   := Nil
	oReqV3J     := JsonObject():New()
	cEmpRequest := ""
	cFilRequest := ""
	cRequestID  := ""
	cPeriod     := ""
	lRet        := .T.
	aCompany    := {}

	If self:companyId == Nil

		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )

	ElseIf self:requestId == Nil

		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Identificação da Requisição não informada no parâmetro 'requestId'." ) )

	ElseIf self:synthetic == Nil

		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Tipo de relatório Sintético ou Analítico não informado no parâmetro 'synthetic'." ) )

	Else

		aCompany := StrTokArr( self:companyId, "|" )

		If Len( aCompany ) < 2

			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )

		Else

			cEmpRequest := aCompany[1]
			cFilRequest := aCompany[2]

			If PrepEnv( cEmpRequest, cFilRequest )

				If ValidID( self:requestId, @cPeriod, .F. )

					cRequestID := self:requestId

					If V3J->(MsSeek(xFilial("V3J") + PadR(cRequestID, GetSX3Cache("V3J_ID", "X3_TAMANHO"))))

						oReqV3J:FromJson(V3J->V3J_PARAMS)

						cPeriod 	:= oReqV3J["paymentPeriod"]
						lIsLegacy 	:= TAFAlsInDic("V5H") .And. !Empty(AllTrim(GetNewPar("MV_TAFRHUR", "")))

						If GetINSSVaData(::self, cRequestID, cPeriod, @oResponse, lIsLegacy)

							TafConOut(procname() + oResponse:toJson())
							self:SetResponse( oResponse:toJson() )

						Else

							SetRestFault( 400, EncodeUTF8( "Empresa|Filial não encontrado no complemento cadastral." ) )

						EndIf

					EndIf

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

	FreeObj( oResponse )
	DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetINSSVaData
@type			function
@description	Retorna os registros analíticos.
@author			Verônica de Almeida
@since			19/07/2021
@param			oReq	-	
@param			cTicket	-	
@param			cPeriod		-	Período de emissão do relatório
@param			oResponse		-	
@return			lRet		-	Json com o resultado processado para o relatório
/*/
//---------------------------------------------------------------------
Static Function GetINSSVaData(oReq as json, cTicket as character, cPeriod as character, oResponse as json, lIsLegacy as logical)

	Local aArea			as array
	Local aArqTrb		as array
	Local aJson			as array
	Local oJson 		as object
	Local oArqTrb		as object
	Local nI			as numeric
	Local nINSSOri		as numeric
	Local nINSSTAF		as numeric
	Local nINSSGov		as numeric
	Local nArqTrb		as numeric
	Local lRet			as logical
	Local lDiverg		as logical
	Local lTransmitido	as logical
	Local lOnlyDiff		as logical

	Default cPeriod		:= ""
	Default cTicket 	:= ""
	Default lIsLegacy	:= .F.
	Default oResponse 	:= JsonObject():New()
	Default oReq 		:= JsonObject():New()
	
	aArqTrb			:= {}
	aJson			:= {}
	aArea			:= GetArea()
	nI				:= 0
	nINSSOri		:= 0
	nINSSTAF		:= 0
	nINSSGov		:= 0
	nArqTrb			:= 0		
	lRet			:= .T.
	lDiverg			:= .F.
	lTransmitido	:= .F.
	lOnlyDiff		:= IIf(oReq["differencesOnly"] == Nil, .F., oReq["differencesOnly"])
	oJson 			:= Nil
	oArqTrb			:= TAFXHMNew()

	FilInssValues(oReq, @oArqTrb, cPeriod, lIsLegacy)
	TAFXHMList(oArqTrb, aArqTrb)

	nArqTrb := Len(aArqTrb)

	For nI := 1 To nArqTrb

		lTransmitido	:= !Empty(aArqTrb[nI][2][1][RECIBO_TRANSMISSAO]) .And. aArqTrb[nI][2][1][GOVERNO_LOCALIZADO]		
		oJson 			:= JsonObject():New()

		nINSSGov 		:= aArqTrb[nI][2][1][GOVERNO_GROSS_VALUE] + aArqTrb[nI][2][1][GOVERNO_13_GROSS_VALUE]

		If nI < nArqTrb .And. aArqTrb[nI][2][1][CPFFUNC] == aArqTrb[nI + 1][2][1][CPFFUNC]

			nINSSTAF	:= aArqTrb[nI][2][1][TAF_VALOR_INSS] + aArqTrb[nI][2][1][TAF_VALOR_INSS_13_SALARIO] +; 
							aArqTrb[nI + 1][2][1][TAF_VALOR_INSS] + aArqTrb[nI + 1][2][1][TAF_VALOR_INSS_13_SALARIO]

			nINSSOrig	:= aArqTrb[nI][2][1][FOLHA_VALOR_INSS] + aArqTrb[nI][2][1][FOLHA_VALOR_INSS_13_SALARIO] +;
							aArqTrb[nI + 1][2][1][FOLHA_VALOR_INSS] + aArqTrb[nI + 1][2][1][FOLHA_VALOR_INSS_13_SALARIO]
		
		ElseIf nI == 1 .Or. aArqTrb[nI][2][1][CPFFUNC] != aArqTrb[nI - 1][2][1][CPFFUNC]
			
			nINSSTAF	:= aArqTrb[nI][2][1][TAF_VALOR_INSS] + aArqTrb[nI][2][1][TAF_VALOR_INSS_13_SALARIO]
			nINSSOrig	:= aArqTrb[nI][2][1][FOLHA_VALOR_INSS] + aArqTrb[nI][2][1][FOLHA_VALOR_INSS_13_SALARIO]			
		
		EndIf

		If lIsLegacy

			lDiverg := nINSSOrig <> nINSSTAF .Or.; 
						nINSSOrig <> nINSSGov .Or.; 
						nINSSTAF <> nINSSGov .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI][2][1][TAF_VALOR_SALARIO_FAMILIA] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_FAMILIA] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_FAMILIA] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_BASE_PISPASEP_13] <> aArqTrb[nI][2][1][TAF_VALOR_BASE_PISPASEP_13] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_BASE_PISPASEP_13] <> aArqTrb[nI][2][1][GOVERNO_VALOR_BASE_PISPASEP_13] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_BASE_PISPASEP_13] <> aArqTrb[nI][2][1][GOVERNO_VALOR_BASE_PISPASEP_13] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_BASE_PISPASEP] <> aArqTrb[nI][2][1][TAF_VALOR_BASE_PISPASEP] .Or.;
						aArqTrb[nI][2][1][FOLHA_VALOR_BASE_PISPASEP] <> aArqTrb[nI][2][1][GOVERNO_VALOR_BASE_PISPASEP] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_BASE_PISPASEP] <> aArqTrb[nI][2][1][GOVERNO_VALOR_BASE_PISPASEP]
		Else

			lDiverg := nINSSTAF <> nINSSGov .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_FAMILIA] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_FAMILIA] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO] <> aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_BASE_PISPASEP] <> aArqTrb[nI][2][1][GOVERNO_VALOR_BASE_PISPASEP] .Or.;
						aArqTrb[nI][2][1][TAF_VALOR_BASE_PISPASEP_13] <> aArqTrb[nI][2][1][GOVERNO_VALOR_BASE_PISPASEP_13]
		EndIf
		
		If !lOnlyDiff .Or. (lOnlyDiff .And. lDiverg)

			oJson["cpfNumber"]						:= aArqTrb[nI][2][1][CPFFUNC]
			oJson["name"]							:= EncodeUTF8(aArqTrb[nI][2][1][NOMEFUNC])
			oJson["branchId"]						:= aArqTrb[nI][2][1][ESTABELECIMENTO]
			oJson["lotationCode"]					:= aArqTrb[nI][2][1][LOTAC]
			oJson["esocialCategory"]				:= aArqTrb[nI][2][1][CAT_DESCRI]
			oJson["esocialRegistration"]			:= aArqTrb[nI][2][1][MATRIC]

			oJson["inssValue"]						:= aArqTrb[nI][2][1][FOLHA_VALOR_INSS]
			oJson["inssTafValue"]					:= aArqTrb[nI][2][1][TAF_VALOR_INSS]
			oJson["inss13Value"]					:= aArqTrb[nI][2][1][FOLHA_VALOR_INSS_13_SALARIO]
			oJson["inss13TafValue"]					:= aArqTrb[nI][2][1][TAF_VALOR_INSS_13_SALARIO]
			oJson["inssBasis"]						:= aArqTrb[nI][2][1][FOLHA_BASE_INSS]
			oJson["inssTafBasis"]					:= aArqTrb[nI][2][1][TAF_BASE_INSS]
			oJson["familySalaryValue"]				:= aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_FAMILIA]
			oJson["familySalaryTafValue"]			:= aArqTrb[nI][2][1][TAF_VALOR_SALARIO_FAMILIA]
			oJson["maternitySalaryValue"]			:= aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE]
			oJson["maternitySalaryTafValue"]		:= aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE]
			oJson["inss13Basis"]					:= aArqTrb[nI][2][1][FOLHA_BASE_INSS_13_SALARIO]
			oJson["inss13TafBasis"]					:= aArqTrb[nI][2][1][TAF_BASE_INSS_13_SALARIO]
			oJson["maternitySalary13Value"]			:= aArqTrb[nI][2][1][FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
			oJson["maternitySalary13TafRetValue"]	:= aArqTrb[nI][2][1][TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
			oJson["pisPasepBasis"]			        := aArqTrb[nI][2][1][FOLHA_VALOR_BASE_PISPASEP]
			oJson["pisPasepTafRetBasis"]	        := aArqTrb[nI][2][1][TAF_VALOR_BASE_PISPASEP]
			oJson["pisPasep13Basis"]			    := aArqTrb[nI][2][1][FOLHA_VALOR_BASE_PISPASEP_13]
			oJson["pisPasep13TafRetBasis"]	        := aArqTrb[nI][2][1][TAF_VALOR_BASE_PISPASEP_13]

			If lTransmitido

				oJson["inssRetValue"]				:= aArqTrb[nI][2][1][GOVERNO_VALOR_INSS]
				oJson["inss13RetValue"]				:= aArqTrb[nI][2][1][GOVERNO_VALOR_INSS_13_SALARIO]
				oJson["inssRetBasis"]				:= aArqTrb[nI][2][1][GOVERNO_BASE_INSS]
				oJson["inssRetSuspJudBasis"]		:= aArqTrb[nI][2][1][GOVERNO_BASE_SUSPENSAO]
				oJson["inssRetTotalBasis"]			:= aArqTrb[nI][2][1][GOVERNO_BASE_TOTAL_INSS]
				oJson["familySalaryRetValue"]		:= aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_FAMILIA]
				oJson["maternitySalaryRetValue"]	:= aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE]
				oJson["inss13RetBasis"]				:= aArqTrb[nI][2][1][GOVERNO_BASE_INSS_13_SALARIO]
				oJson["maternitySalary13RetValue"]	:= aArqTrb[nI][2][1][GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]
				oJson["pisPasepRetBasis"]	        := aArqTrb[nI][2][1][GOVERNO_VALOR_BASE_PISPASEP]
				oJson["pisPasep13RetBasis"]	        := aArqTrb[nI][2][1][GOVERNO_VALOR_BASE_PISPASEP_13]
	
				oJson["inssRetGrossValue"]			:= aArqTrb[nI][2][1][GOVERNO_GROSS_VALUE]									
				oJson["inssRetDescGrossValue"]		:= aArqTrb[nI][2][1][GOVERNO_DESC_GROSS_VALUE]									
				oJson["inss13RetGrossValue"]		:= aArqTrb[nI][2][1][GOVERNO_13_GROSS_VALUE]								
				oJson["inss13DescGrossValue"]		:= aArqTrb[nI][2][1][GOVERNO_13_DESC_GROSS_VALUE]		
			
			Else
				oJson["inssRetValue"]				:= 0
				oJson["inss13RetValue"]				:= 0
				oJson["inssRetBasis"]				:= 0
				oJson["inssRetSuspJudBasis"]		:= 0
				oJson["inssRetTotalBasis"]			:= 0			
				oJson["familySalaryRetValue"]		:= 0
				oJson["maternitySalaryRetValue"]	:= 0
				oJson["inss13RetBasis"]				:= 0
				oJson["maternitySalary13RetValue"]	:= 0 
				oJson["pisPasepRetBasis"]	        := 0
				oJson["pisPasep13RetBasis"]	        := 0
			
				oJson["inssRetGrossValue"]			:= 0									
				oJson["inssRetDescGrossValue"]		:= 0									
				oJson["inss13RetGrossValue"]		:= 0								
				oJson["inss13DescGrossValue"]		:= 0	

			EndIf

			oJson["inconsistent"] := lDiverg

			AAdd(aJson, oJson)
			
		EndIf

		FreeObj(oJson)

	Next

	oResponse["items"]		:= aJson
	oResponse["hasNext"]	:= .F.

	RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} FilINSSRet
@type			function
@description	Filtra os dados e carrega no hash
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function FilINSSRet( oReq, oArqTrb, cTicket, lIsLegacy )

	Local cAlias		   	:= GetNextAlias()
	Local nQtdRegs			:= 0
	Local nBasINSS			:= 0
	Local nRessInss			:= 0
	Local nVlINSS			:= 0
	Local nSalFam			:= 0
	Local nSalMat			:= 0
	Local nBasINSS13		:= 0
	Local nVlINSS13			:= 0
	Local nSalMat13			:= 0
	Local nRetValue			:= 0
	Local nRetDescValue		:= 0
	Local nRet13Value		:= 0
	Local nRet13DescValue	:= 0
	Local nRegistro			:= 0
	Local nItem       		:= 0
	Local nValPis           := 0
	LocaL nValPis13         := 0
	Local nBasSusJud        := 0
	Local jDados            := 0
	Local lAnalytic         := .F.
	Local lAdd				:= .F.

	Default cPeriod 		:= ''

	// Retorna as filiais do TAF referente a Matriz logada
	cFilSel := TAFCacheFil("V3N", FilMatriz(), .T.)

	// Faz consulta do banco
	nQtdRegs := FilInssSynthetic(@cAlias, cFilSel, oReq)

	While (cAlias)->( !Eof() )

		nRegistro++

		lAdd := CalcValor(@cAlias,@nRessInss,@nVlINSS,@nVlINSS13,@nBasINSS,@nSalFam,@nSalMat,@nSalMat13,@nBasINSS13,@nRetValue,@nRetDescValue,@nRet13Value,@nRet13DescValue,.T., lAnalytic, nBasSusJud, @nValPis, @nValPis13)
		TafConOut(procname() + " Apos CalcValor nRetValue: " + cValtoChar( nRetValue ) )

		If lAdd
			// Carrega o Hash
			LoadHash('SINTETICO',cAlias,oArqTrb,@nRessInss,@nVlINSS,@nVlINSS13,@nBasINSS,@nSalFam,@nSalMat,@nSalMat13,@nBasINSS13,@nRetValue,@nRetDescValue,@nRet13Value,@nRet13DescValue, jDados, nBasSusJud, @nValPis, @nValPis13 )
			TafConOut(procname() + " Apos LoadHash nRetValue: " + cValtoChar( nRetValue ) )
		EndIf

		nItem++

		setPercent(cTicket, nItem, nQtdRegs,,, lIsLegacy)

		(cAlias)->( dbSkip() )

	EndDo

	If lIsLegacy
		LoadHashLegacy(cTicket,oArqTrb)
	EndIf

	If nRegistro == 0
		setPercent(cTicket, 100, 100,,, lIsLegacy)
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FilInssValues
@type			function
@description	Filtra os dados e carrega no hash
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function FilInssValues(oReq as json, oArqTrb as object, cPeriod as character, lIsLegacy as logical)

	Local aHeader			as array
	Local aRHValues			as array
	Local cAlias    		as character
	Local cFilRH			as character
	Local cCPF				as character
	Local cLotacao          as character
	Local cCategoria        as character
	Local cEstabe           as character
	Local cMats             as character
	Local cTicket			as character
	Local nQtdRegs			as numeric
	Local nBasINSS			as numeric
	Local nVlINSS			as numeric
	Local nRessInss			as numeric
	Local nSalFam			as numeric
	Local nSalMat			as numeric
	Local nBasINSS13		as numeric
	Local nVlINSS13			as numeric
	Local nSalMat13			as numeric
	Local nRetValue			as numeric
	Local nRetDescValue		as numeric
	Local nRet13Value		as numeric
	Local nRet13DescValue	as numeric
	Local nBasSusJud 		as numeric
	Local nValPis           as numeric
	Local nValPis13         as numeric
	Local nX				as numeric
	
	Default cPeriod 		:= ""
	Default lIsLegacy		:= .F.
	Default oArqTrb			:= Nil
	Default oReq			:= JsonObject():New()

	aHeader			:= {}
	aRHValues		:= {}
	cAlias    		:= ""
	cFilRH			:= ""
	cCPF			:= IIf(oReq["cpfNumber"] == Nil, "", oReq["cpfNumber"])
	cLotacao    	:= IIf( oReq[ "lotationCode" ] == Nil .Or. Empty( oReq[ "lotationCode" ] ), Nil , "'" + StrTran( oReq["lotationCode"], ";", "','" ) + "'" )
    cCategoria  	:= IIf( oReq[ "eSocialCategory" ] == Nil .Or. Empty( oReq[ "eSocialCategory" ] ), Nil , "'" + StrTran( oReq["eSocialCategory"], ";", "','" ) + "'" )
    cEstabe     	:= IIf( oReq[ "registrationNumber" ] == Nil .Or. Empty( oReq[ "registrationNumber" ] ), Nil , "'" + StrTran( oReq["registrationNumber"], ";", "','" ) + "'" )
    cMats       	:= IIf( oReq[ "eSocialRegistration" ] == Nil .Or. Empty( oReq[ "eSocialRegistration" ] ), Nil , "'" + StrTran( oReq["eSocialRegistration"], ";", "','" ) + "'" )
	cTicket			:= IIf(oReq["requestId"] == Nil, "", oReq["requestId"])
	nBasINSS		:= 0
	nVlINSS			:= 0
	nRessInss		:= 0
	nSalFam			:= 0
	nSalMat			:= 0
	nBasINSS13		:= 0
	nVlINSS13		:= 0
	nSalMat13		:= 0
	nRetValue		:= 0
	nRetDescValue	:= 0
	nRet13Value		:= 0
	nRet13DescValue	:= 0
	nBasSusJud		:= 0
	nValPis         := 0
	nValPis13       := 0
	nX				:= 0
	nQtdRegs 		:= FilInssAnalytic(@cAlias, cCPF, cPeriod, cTicket, cLotacao, cCategoria, cEstabe, cMats)
	
	While !(cAlias)->(EOF())
		If CalcValor(cAlias, @nRessInss, @nVlINSS, @nVlINSS13, @nBasINSS, @nSalFam, @nSalMat, @nSalMat13, @nBasINSS13, @nRetValue, @nRetDescValue, @nRet13Value, @nRet13DescValue, .T., .T., @nBasSusJud, @nValPis, @nValPis13 )
			LoadHash("ANALITICO", cAlias, oArqTrb, @nRessInss, @nVlINSS, @nVlINSS13, @nBasINSS, @nSalFam, @nSalMat, @nSalMat13, @nBasINSS13, @nRetValue, @nRetDescValue, @nRet13Value, @nRet13DescValue,,@nBasSusJud, @nValPis, @nValPis13 )
		EndIf
		(cAlias)->(DBSkip())
	EndDo

	If lIsLegacy		
		aRhValues := V5HGetRhValues(cTicket, cCPF)

		For nX := 1 To Len(aRHValues)
			LoadHash("RH", cAlias, oArqTrb, @nRessInss, @nVlINSS, @nVlINSS13, @nBasINSS, @nSalFam, @nSalMat, @nSalMat13, @nBasINSS13, @nRetValue, @nRetDescValue, @nRet13Value, @nRet13DescValue, aRHValues[nX])
		Next
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FilInssSynthetic
@type			function
@description	Realiza select no banco para a visão sintética - InssRetValues
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function FilInssSynthetic(cAlias as character, cFilSel as character, oReq as json)
	
	Local aCategoria  as array
	Local aEstabe     as array
	Local aFiliais    as array
	Local aLotacao    as array
	Local aMats       as array
	Local aModoAcess  as array
	Local cBanco      as character
	Local cColumnTemp as character
	Local cCpf        as character
	Local cJoinT2Q    as character
	Local cPeriodo    as character
	Local cQuery      as character
	LocaL cSelect1    as character
	LocaL cSelect2    as character
	LocaL cSelect3    as character
	Local cWhere1     as character
	Local cWhere10    as character
	Local cWhere2     as character
	Local cWhere3     as character
	Local cWhere4     as character
	Local cWhere5     as character
	Local cWhere6     as character
	Local cWhere7     as character
	Local cWhere8     as character
	Local cWhere9     as character
	Local lRetInss    as logical
	Local nRet        as numeric
	Local oStmt       as object
	Local xCPFs       as variant
	
	Default cAlias  := GetNextAlias()
	Default cFilSel := ""
	Default oReq    := JsonObject():New()

	aCategoria  := IIf(oReq["eSocialCategory"] == Nil, {}, oReq["eSocialCategory"])
	aEstabe     := IIf(oReq["registrationNumber"] == Nil, {}, oReq["registrationNumber"])
	aFiliais    := {}
	aLotacao    := IIf(oReq["lotationCode"] == Nil, {}, oReq["lotationCode"])
	aMats       := IIf(oReq["eSocialRegistration"] == Nil, {}, oReq["eSocialRegistration"])
	aModoAcess  := {}
	cBanco      := Upper(TcGetDb())
	cColumnTemp := ""
	cJoinT2Q    := ""
	cPeriodo    := oReq["paymentPeriod"]
	cQuery      := ""
	cSelect1    := ""
	cSelect2    := ""
	cSelect3    := ""
	cWhere1     := ""
	cWhere10    := ""
	cWhere2     := ""
	cWhere3     := ""
	cWhere4     := ""
	cWhere5     := ""
	cWhere6     := ""
	cWhere7     := ""
	cWhere8     := ""
	cWhere9     := ""
	lRetInss    := TafGpeFgtsInss()
	nRet        := 0
	oStmt       := Nil
	xCPFs       := IIf(oReq["cpfNumber"] == Nil, {}, oReq["cpfNumber"])

	// ------------------------------------------------------------------------
    // Popula aFiliais e aModoAcess
    // ------------------------------------------------------------------------
    FilTabela("C92", @aFiliais, @aModoAcess)
    FilTabela("C99", @aFiliais, @aModoAcess)
    FilTabela("C87", @aFiliais, @aModoAcess)

	// ------------------------------------------------------------------------
    // Monta WHERE principal (V3N)
    // ------------------------------------------------------------------------
    If TafColumnPos("V3N_PISPAS")
        cWhere1 += " OR (V3N.V3N_PISPAS IN ('11','12','91','92')) "
    EndIf

    If lRetInss
        cWhere1 += " OR (V3N.V3N_NATRUB = '9989' AND V3N.V3N_ITCP = '11' AND V3N.V3N_TPRUBR = '4') "
        cWhere1 += " OR (V3N.V3N_NATRUB = '9989' AND V3N.V3N_ITCP = '31' AND V3N.V3N_TPRUBR = '3') "
    EndIf

    If TafColumnPos("V3N_PISPAS")
        cWhere2 += " OR (V3N.V3N_ORIGEM = '3' AND V3N.V3N_PISPAS IN ('11','12','91','92')) "
    EndIf

	If TafColumnPos("V3N_PISPAS")
		cSelect1 := " V3N.V3N_PISPAS, "
	Else
		cSelect1 := " '' AS V3N_PISPAS, "
	EndIf

	If !Empty(aEstabe) .And. Empty(aCategoria)

		cWhere3	 += " AND V3N.V3N_NRINSC IN " + FormatIn(ArrayToStr(aEstabe), ";") + " "
		cSelect2 := "       AND V3N.V3N_NRINSC IN (" + Strtran(Strtran(FormatIn(ArrayToStr(aEstabe), ";"),'(',''),')','') + " ) "
	
	EndIf

	If !Empty(aLotacao) .And. Empty(aCategoria)
		cWhere4 += " AND V3N.V3N_CODLOT IN " + FormatIn(ArrayToStr(aLotacao), ";") + " "
	EndIf

	If !Empty(aMats) 
		cWhere5 += " AND V3N.V3N_MATRIC IN " + FormatIn(ArrayToStr(aMats), ";") + " "
	EndIf

	If !Empty(aCategoria)
		cWhere6 += " AND V3N.V3N_CATEG IN " + FormatIn(ArrayToStr(aCategoria), ";") + " "
	EndIf

	If !Empty(xCPFs)

		If ValType(xCPFs) == 'C'

			cCpf := " = '" + xCPFs + "' "

		Else

			cCpf :=  " IN " + FormatIn(ArrayToStr(xCPFs),";") + " "

		EndIf

		cWhere8  += " AND V3N.V3N_CPF " + cCpf
		cWhere9  += " AND T2M.T2M_CPFTRB " + cCpf
		cWhere10 += " AND T2MA.T2M_CPFTRB " + cCpf
		cSelect3 := " AND V3N.V3N_CPF " + cCpf

	EndIf

	cQuery := " SELECT V3N.V3N_FILIAL, V3N.V3N_INDAPU, V3N.V3N_PERAPU, V3N.V3N_INDDEC, "
	cQuery += "        V3N.V3N_CPF, V3N.V3N_NOME, V3N.V3N_MATRIC, V3N.V3N_CATEG, "
	cQuery += "        V3N.V3N_TPINSC, V3N.V3N_NRINSC, V3N.V3N_CODLOT, V3N.V3N_EVENTO, "
	cQuery += "        V3N.V3N_ORIGEM, V3N.V3N_RECIBO, V3N.V3N_NATRUB, V3N.V3N_TPRUBR, "
	cQuery += "        V3N.V3N_ITCP, V3N.V3N_TPVLR, V3N.V3N_ID, "
	cQuery +=          cSelect1
	cQuery += "        0 AS T2O_VRCPSE, 0 AS T2O_VRDESC, COALESCE(NULL,'') AS T2O_IDCODR, "
	cQuery += "        CASE WHEN V3N.V3N_NATRUB = '1623' AND V3N.V3N_TPRUBR = '1' "
	cQuery += "             THEN V3N.V3N_VALOR * -1 ELSE V3N.V3N_VALOR END AS V3N_VALOR "
	cQuery += " FROM " + RetSQLName("V3N") + " V3N "
	cQuery += " WHERE ( "
	cQuery += "         ( V3N.V3N_ORIGEM = '2' AND V3N.V3N_INDAPU IN ('1','2') "
	cQuery += "           AND ( (V3N.V3N_NATRUB = '9201' AND V3N.V3N_ITCP = '31') "
	cQuery += "              OR (V3N.V3N_NATRUB = '9201' AND V3N.V3N_ITCP = '32') "
	cQuery += "              OR (V3N.V3N_NATRUB = '9901' AND V3N.V3N_TPRUBR = '3') "
	cQuery += "              OR (V3N.V3N_NATRUB = '1409' AND V3N.V3N_ITCP = '51') "
	cQuery += "              OR (V3N.V3N_NATRUB = '4050' AND V3N.V3N_ITCP = '21') "
	cQuery += "              OR (V3N.V3N_NATRUB = '1623' AND V3N.V3N_TPRUBR = '1') "
	cQuery +=                cWhere1
	cQuery += "              OR (V3N.V3N_NATRUB = '4051' AND V3N.V3N_ITCP = '22') ) "
	cQuery += "         ) "
	cQuery +=           cWhere2
	cQuery += "       ) "
	cQuery += "   AND V3N.V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
	cQuery +=     cWhere3
	cQuery +=     cWhere4
	cQuery +=     cWhere5
	cQuery +=     cWhere6
	cQuery += "   AND V3N.D_E_L_E_T_ = ' ' "
	cQuery += "   AND V3N.V3N_PERAPU = ? "
	cQuery +=     cWhere8  

	cQuery += " UNION "

	cQuery += " SELECT T2M.T2M_FILIAL AS V3N_FILIAL, "
	cQuery += "        T2M.T2M_INDAPU AS V3N_INDAPU, "
	cQuery += "        T2M.T2M_PERAPU AS V3N_PERAPU, "
	cQuery += "        COALESCE(NULL,'') AS V3N_INDDEC, "
	cQuery += "        T2M.T2M_CPFTRB AS V3N_CPF, "
	cQuery += "        V3N.V3N_NOME, "
	cQuery += "        COALESCE(NULL,'') AS V3N_MATRIC, "
	cQuery += "        COALESCE(NULL,'') AS V3N_CATEG, "
	cQuery += "        COALESCE(NULL,'') AS V3N_TPINSC, "
	cQuery += "        COALESCE(NULL,'') AS V3N_NRINSC, "
	cQuery += "        COALESCE(NULL,'') AS V3N_CODLOT, "
	cQuery += "        COALESCE(NULL,'') AS V3N_EVENTO, "
	cQuery += "        '3' AS V3N_ORIGEM, "
	cQuery += "        T2M.T2M_NRRECI AS V3N_RECIBO, "
	cQuery += "        COALESCE(NULL,'') AS V3N_NATRUB, "
	cQuery += "        COALESCE(NULL,'') AS V3N_TPRUBR, "
	cQuery += "        COALESCE(NULL,'') AS V3N_ITCP, "
	cQuery += "        COALESCE(NULL,'') AS V3N_TPVLR, "
	cQuery += "        COALESCE(NULL,'') AS V3N_ID, "
	cQuery += "        COALESCE(NULL,'') AS V3N_PISPAS, "
	cQuery += "        T2O.T2O_VRCPSE, T2O.T2O_VRDESC, T2O.T2O_IDCODR, "
	cQuery += "        0 AS V3N_VALOR "
	cQuery += " FROM " + RetSQLName("T2M") + " T2M "
	cQuery += " INNER JOIN " + RetSQLName("V3N") + " V3N "
	cQuery += "         ON T2M.T2M_FILIAL = V3N.V3N_FILIAL "
	cQuery += "        AND V3N.V3N_PERAPU = T2M.T2M_PERAPU "
	cQuery += "        AND V3N.V3N_CPF = T2M.T2M_CPFTRB "
	cQuery += "        AND V3N.V3N_RECIBO = T2M.T2M_NRRECI "
	cQuery += "        AND V3N.D_E_L_E_T_ = '' "
	cQuery +=          cSelect3
	cQuery += "        AND V3N.V3N_ORIGEM = '3' "
	cQuery +=          cSelect2
	cQuery += "        AND V3N.V3N_TPVLR IN ('21','11') "

	If !Empty(aEstabe) .Or. !Empty(aLotacao) .Or. !Empty(aMats) .Or. !Empty(aCategoria)

		cQuery += " INNER JOIN " + RetSQLName("T2Q") + " T2Q "
		cQuery += "         ON T2Q.D_E_L_E_T_ = '' "
		cQuery += "        AND T2Q.T2Q_FILIAL = T2M.T2M_FILIAL "
		cQuery += "        AND T2Q.T2Q_ID = T2M.T2M_ID "
		cQuery += "        AND T2Q.T2Q_VERSAO = T2M.T2M_VERSAO "

		If !Empty(aEstabe) .And. Empty(aCategoria)
			cQuery += "        AND ( T2Q.T2Q_ESTABE IN ( "
			cQuery += "              SELECT C92.C92_ID "
			cQuery += "              FROM " + RetSQLName("C92") + " C92 "
			cQuery += "              WHERE C92.D_E_L_E_T_ = '' "
			cQuery += "                AND C92.C92_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + TAFCacheFil(, aFiliais, .T.) + " FILIAIS " + " ) "
			cQuery += "                AND C92.C92_NRINSC IN " + FormatIn(ArrayToStr(aEstabe), ";") + " ) "
			cQuery += "              OR T2Q.T2Q_NRINSC IN " + FormatIn(ArrayToStr(aEstabe), ";") + " ) "
		EndIf

		If !Empty(aLotacao) .And. Empty(aCategoria)
			cQuery += "        AND ( T2Q.T2Q_LOTACA IN ( "
			cQuery += "  	         SELECT C99.C99_ID "
			cQuery += "   		     FROM " + RetSQLName("C99") + " C99 "
			cQuery += "  		     WHERE C99.D_E_L_E_T_ = '' "
			cQuery += "   			   AND C99.C99_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + TAFCacheFil(, aFiliais, .T.) + " FILIAIS " + " ) "
			cQuery += "   			   AND C99.C99_CODIGO IN " + FormatIn(ArrayToStr(aLotacao), ";") + " ) "
			cQuery += "              OR T2Q.T2Q_CODLOT IN " + FormatIn(ArrayToStr(aLotacao), ";") + " ) "
		EndIf

		If !Empty(aMats) 
			cQuery += "        AND T2Q.T2Q_MATRIC IN " + FormatIn(ArrayToStr(aMats), ";")
		EndIf

		If !Empty(aCategoria)
			cQuery += "        AND T2Q.T2Q_CODCAT IN ( "
			cQuery += " 	       SELECT C87.C87_ID "
			cQuery += "  		   FROM " + RetSQLName("C87") + " C87 "
			cQuery += " 		   WHERE C87.D_E_L_E_T_ = '' "
			cQuery += "  			 AND C87.C87_CODIGO IN " + FormatIn(ArrayToStr(aCategoria), ";") + " ) "
		EndIf

	EndIf

	cQuery += " LEFT JOIN " + RetSQLName("T2O") + " T2O "
	cQuery += "        ON T2O.T2O_ID = T2M.T2M_ID "
	cQuery += "       AND T2O.T2O_VERSAO = T2M.T2M_VERSAO "
	cQuery += "       AND T2O.T2O_FILIAL = T2M.T2M_FILIAL "
	cQuery += "       AND T2O.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE T2M.T2M_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS " + " ) "
	cQuery +=     cWhere9
	cQuery += "   AND T2M.D_E_L_E_T_ = ' ' "
	cQuery += "   AND T2M.T2M_PERAPU = ? "
	cQuery += "   AND T2M.T2M_NRRECI IN ( "
	cQuery += "         SELECT MAX(T2MA.T2M_NRRECI) "
	cQuery += "         FROM " + RetSQLName("T2M") + " T2MA "
	cQuery += "         WHERE T2MA.T2M_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS " + " ) "
	cQuery +=             cWhere10
	cQuery += "           AND T2MA.D_E_L_E_T_ = ' ' "
	cQuery += "           AND T2MA.T2M_PERAPU = ? "
	cQuery += "           AND T2MA.T2M_ATIVO = '1' "
	cQuery += "         GROUP BY T2MA.T2M_FILIAL, T2MA.T2M_CPFTRB, T2MA.T2M_INDAPU, T2MA.T2M_PERAPU "
	cQuery += "       ) "
	cQuery += " ORDER BY V3N_ORIGEM "

	oStmt := FWExecStatement():New( cQuery )

	// ?? Bind dos parâmetros
	// Ordem dos ? na query:
	// 1 - V3N_PERAPU
	// 2 - T2M_PERAPU
	// 3 - T2MA.T2M_PERAPU
	oStmt:SetString( 1, cPeriodo )
	oStmt:SetString( 2, cPeriodo )
	oStmt:SetString( 3, cPeriodo )

	If Select(cAlias) > 0
		(cAlias)->( dbCloseArea() )
	EndIf

	cAlias := oStmt:OpenAlias()

	//Recupera a consulta já com os parâmetros injetados
	cQuery := oStmt:getFixQuery()

	TafConOut(procname() + cQuery)

	oStmt:executeQuery( cAlias )

	If (cAlias)->( !Eof() )
		( cAlias )->( DBEval( { || nRet ++ } ) )
	EndIf

	(cAlias)->( dbGoTop() )
	
Return nRet

//---------------------------------------------------------------------
/*/{Protheus.doc} FilInssAnalytic
@type			function
@description	Realiza select no banco para a visão analítica - InssValues
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function FilInssAnalytic(cAlias as character, cCPF as character, cPeriod as character, cTicket as character, cLotacao as character, cCategoria as character, cEstabe as character, cMatric as character) as numeric

	Local lRetTaf		as logical
	Local nRet	   		as numeric
	Local cColumnTmp 	as character
	Local cWhere		as character
	Local cWCPF			as character
	Local cFilSel		as character
	Local cWhereT2M		as character	
	Local cJoinT2P		as character
	Local cJoinT2R		as character
	Local cSelect       as character

	Default cAlias	:= ""
	Default cCPF	:= ""
	Default cLotacao := ""
	Default cCategoria := ""
	Default cEstabe := ""
	Default cMatric := ""
	Default cPeriod	:= ""
	Default cTicket	:= ""

	cColumnTmp	:= ""
	cWhereT2M	:= ""
	cWhere		:= ""
	cWCPF		:= ""
	cJoinT2P	:= "%%"
	cJoinT2R	:= "%%"
	cAlias		:= GetNextAlias()
	cFilSel		:= TAFCacheFil("V3N", FilMatriz(), .T.)
	cSelect     := ""
	lRetTaf 	:= TafGpeFgtsInss()
	nRet		:= 0

	cJoinT2P := "% AND T2P_CODLOT = V3N_CODLOT AND T2P_TPINSC = V3N_TPINSC AND T2P_NRINSC = V3N_NRINSC %"
	cJoinT2R := "% AND T2R_CODLOT = T2P_CODLOT AND T2R_TPINSC = T2P_TPINSC AND T2R_NRINSC = T2P_NRINSC %"
	
	cWhere := " ( (V3N_ORIGEM = '2' AND V3N_INDAPU IN ('1','2') AND  (	(V3N_NATRUB = '9201' AND V3N_ITCP IN ( '31','32') ) "
	cWhere += " 																			OR (V3N_NATRUB = '9901' AND V3N_TPRUBR = '3') "
	cWhere += " 																			OR (V3N_NATRUB = '1409' AND V3N_ITCP = '51') "
	cWhere += " 																			OR (V3N_NATRUB = '4050' AND V3N_ITCP = '21') "
	cWhere += " 																			OR (V3N_NATRUB = '4051' AND V3N_ITCP = '22') "
	cWhere += " 																			OR (V3N_NATRUB = '1623' AND V3N_TPRUBR = '1') "
	cWhere += " 																			OR (V3N_NATRUB = '9901' AND V3N_TPRUBR = '4') "

	If TafColumnPos("V3N_PISPAS")
		cWhere += " 																			OR (V3N_PISPAS IN ('11','12','91','92')) "
	EndIf
		
	If lRetTaf
		cWhere += "						  OR  (V3N_NATRUB = '9989' AND V3N_ITCP = '11' AND V3N_TPRUBR = '4' ) "
		cWhere += "						  OR  (V3N_NATRUB = '9989' AND V3N_ITCP = '31' AND V3N_TPRUBR = '3' ) "
	EndIf

	cWhere += " 																		) )  "

	If TafColumnPos("V3N_PISPAS")
		cWhere += "	OR V3N_ORIGEM = '3' AND V3N_PISPAS IN ('11','12','91','92')  "
	EndIf

	cWhere += " ) "
	
	cWhereT2M := " T2M_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) " 

	If !Empty(cCPF)
		cWCPF 		:= " AND V3N_CPF = '" + cCPF + "' "
		cWhereT2M 	+= " AND T2M_CPFTRB = '" + cCPF + "' "
	EndIf

	If !Empty(cEstabe)
		cWCPF 		+= " AND V3N_NRINSC IN (" + cEstabe + ") "
	EndIf

	If !Empty(cLotacao)
		cWCPF 		+= " AND V3N_CODLOT IN (" + cLotacao + ") "
	EndIf

	If !Empty(cMatric)
		cWCPF 		+= " AND V3N_MATRIC = " + cMatric + " "
		
	EndIf

	If !Empty(cCategoria)
		cWCPF 		+= " AND V3N_CATEG IN ( " + cCategoria + " ) "
	EndIf

	cWhereT2M	:= "%" + cWhereT2M + "%"
	cWhere  	:= "%" + cWhere + "%"
	cWCPF		:= "%" + cWCPF + "%"

	If TafColumnPos("V3N_PISPAS")
		cSelect := '%V3N_PISPAS%'
	Else
		cSelect := "%'' AS V3N_PISPAS%"
	EndIf

	If Select(cAlias) > 0
		(cAlias)->(DBCloseArea())
	EndIf

	BeginSql Alias cAlias

		SELECT DISTINCT 
				V3N_FILIAL,
				V3N_INDAPU,
				V3N_PERAPU,
				V3N_INDDEC,
				V3N_CPF,
				V3N_NOME,
				V3N_MATRIC,
				V3N_CATEG,
				V3N_TPINSC,
				V3N_NRINSC,
				V3N_CODLOT,
				V3N_EVENTO,
				V3N_ORIGEM,
				V3N_RECIBO,
				V3N_NATRUB,
				V3N_TPRUBR,
				C87_DESCRI,
				V3N_ITCP,
				V3N_TPVLR,
				V3N_ID,
				T2O_VRCPSE,
				T2O_VRDESC,
				T2O_IDCODR,
				V3N_VALOR,
				%Exp:cSelect%
		FROM (
			SELECT 
				V3N_FILIAL,
				V3N_INDAPU,
				V3N_PERAPU,
				V3N_INDDEC,
				V3N_CPF,
				V3N_NOME,
				V3N_MATRIC,
				V3N_CATEG,
				V3N_TPINSC,
				V3N_NRINSC,
				V3N_CODLOT,
				V3N_EVENTO,
				V3N_ORIGEM,
				V3N_RECIBO,
				V3N_NATRUB,
				V3N_TPRUBR,
				C87_DESCRI,
				V3N_ITCP,
				V3N_TPVLR,
				V3N_ID,
				0 AS T2O_VRCPSE,
				0 AS T2O_VRDESC,
				'' AS T2O_IDCODR,
				CASE WHEN V3N.V3N_NATRUB = '1623' AND V3N.V3N_TPRUBR = '1' THEN V3N.V3N_VALOR * -1 ELSE V3N.V3N_VALOR END V3N_VALOR,
				%Exp:cSelect%
			FROM %Table:V3N% V3N
			LEFT JOIN %Table:C87% C87 ON C87.C87_CODIGO = V3N.V3N_CATEG AND C87.C87_FILIAL = %xFilial:C87% AND C87.%NotDel%
			WHERE %Exp:cWhere%
				AND V3N_FILIAL IN ( 
					SELECT FILIAIS.FILIAL 
						FROM %temp-table:cFilSel% FILIAIS
				)
				AND V3N_PERAPU = %Exp:cPeriod%
				AND V3N.%NotDel%  
				%Exp:cWCPF%

			UNION

			SELECT 
				T2M_FILIAL AS V3N_FILIAL,
				T2M_INDAPU AS V3N_INDAPU,
				T2M_PERAPU AS V3N_PERAPU,
				T2R_INDDEC AS V3N_INDDEC,
				T2M_CPFTRB AS V3N_CPF,
				V3N_NOME,
				V3N_MATRIC,
				V3N_CATEG,
				V3N_TPINSC,
				V3N_NRINSC,
				V3N_CODLOT,
				'' AS V3N_EVENTO,
				'3' AS V3N_ORIGEM,
				T2M_NRRECI AS V3N_RECIBO,
				'' AS V3N_NATRUB,
				'' AS V3N_TPRUBR,
				C87_DESCRI,
				'' AS V3N_ITCP,
				T2T_CODIGO AS V3N_TPVLR,
				'' AS V3N_ID,
				0 AS T2O_VRCPSE,
				0 AS T2O_VRDESC,
				'' AS T2O_IDCODR,
				T2R_VALOR AS V3N_VALOR,
				%Exp:cSelect%
			FROM %Table:T2M% T2M 
			INNER JOIN %Table:V3N% V3N 
				ON V3N_FILIAL = T2M_FILIAL
					AND V3N_PERAPU = T2M_PERAPU
					AND V3N_CPF = T2M_CPFTRB
					AND V3N_RECIBO = T2M_NRRECI
					AND V3N_ORIGEM = '3'
					AND V3N_TPVLR = '21'
					AND V3N.%NotDel%
					%Exp:cWCPF%
			LEFT JOIN %Table:C87% C87 
				ON C87.C87_CODIGO = V3N.V3N_CATEG 
					AND C87.C87_FILIAL = %xFilial:C87%
					AND C87.%NotDel%
			LEFT JOIN %Table:T2P% T2P
				ON T2P_ID = T2M_ID
					AND	T2P_VERSAO = T2M_VERSAO
					AND	T2P_FILIAL = T2M_FILIAL
					%Exp:cJoinT2P%
					AND	T2P.%NotDel%
			INNER JOIN %Table:T2R% T2R
				ON T2R_ID = T2P_ID
					AND T2R_VERSAO = T2P_VERSAO
					AND T2R_FILIAL = T2P_FILIAL
					%Exp:cJoinT2R%
					AND T2R.%NotDel%
			INNER JOIN %Table:T2T% T2T
				ON T2T_FILIAL = %xFilial:T2T%
					AND T2T_ID = T2R_TPVLR
					AND T2T.%NotDel%
			WHERE %Exp:cWhereT2M%
				AND T2M.%NotDel% 
				AND T2M_PERAPU = %Exp:cPeriod%
				AND T2M_NRRECI IN (
					SELECT MAX(T2MB.T2M_NRRECI) AS T2M_NRRECI 
						FROM %Table:T2M% T2MB
						WHERE %Exp:cWhereT2M% 
							AND T2MB.%NotDel% 
							AND T2MB.T2M_PERAPU = %Exp:cPeriod%
							AND T2MB.T2M_ATIVO = '1'
						GROUP BY T2MB.T2M_FILIAL, T2MB.T2M_CPFTRB, T2MB.T2M_INDAPU, T2MB.T2M_PERAPU
				)

			UNION

			SELECT 
				T2M_FILIAL AS V3N_FILIAL,
				T2M_INDAPU AS V3N_INDAPU,
				T2M_PERAPU AS V3N_PERAPU,
				'' AS V3N_INDDEC,
				T2M_CPFTRB AS V3N_CPF,
				V3N_NOME,
				V3N_MATRIC,
				V3N_CATEG,
				V3N_TPINSC,
				V3N_NRINSC,
				V3N_CODLOT,
				'' AS V3N_EVENTO,
				'3' AS V3N_ORIGEM,
				T2M_NRRECI AS V3N_RECIBO,
				'' AS V3N_NATRUB,
				'' AS V3N_TPRUBR,
				C87_DESCRI,
				'' AS V3N_ITCP,
				'' AS V3N_TPVLR,
				'' AS V3N_ID,
				T2O_VRCPSE,
				T2O_VRDESC,
				T2O_IDCODR,
				0 AS V3N_VALOR,
				'' AS V3N_PISPAS
			FROM %Table:T2M% T2M 
			INNER JOIN %Table:V3N% V3N 
				ON V3N_FILIAL = T2M_FILIAL
					AND V3N_PERAPU = T2M_PERAPU
					AND V3N_CPF = T2M_CPFTRB
					AND V3N_RECIBO = T2M_NRRECI
					AND V3N_ORIGEM = '3'
					AND V3N_TPVLR IN ('21','11')
					AND V3N.%NotDel%  
					%Exp:cWCPF%
			LEFT JOIN %Table:C87% C87 
				ON C87.C87_CODIGO = V3N.V3N_CATEG 
					AND C87.C87_FILIAL = %xFilial:C87%
					AND C87.%NotDel%
			LEFT JOIN %Table:T2O% T2O 
				ON T2O_ID = T2M_ID
					AND T2O_VERSAO = T2M_VERSAO
					AND T2O_FILIAL = T2M_FILIAL
					AND T2O.%NotDel%
			WHERE %Exp:cWhereT2M%
				AND T2M.%NotDel% 
				AND T2M_PERAPU = %Exp:cPeriod%
				AND T2M_NRRECI IN (
					SELECT MAX(T2MB.T2M_NRRECI) AS T2M_NRRECI 
						FROM %Table:T2M% T2MB
						WHERE %Exp:cWhereT2M% 
							AND T2MB.%NotDel% 
							AND T2MB.T2M_PERAPU = %Exp:cPeriod%
							AND T2MB.T2M_ATIVO = '1'
						GROUP BY T2MB.T2M_FILIAL, T2MB.T2M_CPFTRB, T2MB.T2M_INDAPU, T2MB.T2M_PERAPU
				)
		) TRB_TAB
		
		ORDER BY TRB_TAB.V3N_NRINSC, TRB_TAB.V3N_CODLOT, TRB_TAB.V3N_CPF, TRB_TAB.V3N_MATRIC, TRB_TAB.V3N_CATEG, TRB_TAB.V3N_ORIGEM, TRB_TAB.T2O_IDCODR	
		
	EndSql

	TafConOut(Procname() + GetLastQuery()[2])

	(cAlias)->(DBGoTop())

	Count To nRet

	(cAlias)->(DBGoTop())

Return nRet

//---------------------------------------------------------------------
/*/{Protheus.doc} CalcValor
@type			function
@description	Atribui valor devido para as variáveis de controle
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function CalcValor(cAlias as character, nRessInss as numeric, nVlINSS as numeric, nVlINSS13 as numeric,; 
							nBasINSS as numeric, nSalFam as numeric, nSalMat as numeric, nSalMat13 as numeric,;
							nBasINSS13 as numeric, nRetValue as numeric, nRetDescValue as numeric, nRet13Value as numeric,;
							nRet13DescValue as numeric, lCalcGrossValue as logical, lAnalytic as logical, nBasSusJud as numeric, nValPis as numeric, nValPis13 as numeric)

	Local cIncidPis   as character
	Local cIncidPS    as character
	Local cIndDec     as character
	Local cNatureza   as character
	Local cTipo       as character
	Local lRet        as logical
	Local lTafGpeInss as logical

	Default cAlias          := ""
	Default lAnalytic       := .F.
	Default lCalcGrossValue := .F.
	Default nBasINSS        := 0
	Default nBasINSS13      := 0
	Default nBasSusJud      := 0
	Default nRessInss       := 0
	Default nRet13DescValue := 0
	Default nRet13Value     := 0
	Default nRetDescValue   := 0
	Default nRetValue       := 0
	Default nSalFam         := 0
	Default nSalMat         := 0
	Default nSalMat13       := 0
	Default nValPis         := 0
	Default nValPis13       := 0
	Default nVlINSS         := 0
	Default nVlINSS13       := 0

	cIncidPis   := ""
	cIncidPS    := ""
	cIndDec     := ""
	cNatureza   := ""
	cTipo       := ""
	lRet        := .F.
	lTafGpeInss := IIf(FindFunction("TafGpeFgtsInss"), TafGpeFgtsInss(), .F.)

	Do Case
	Case (cAlias)->V3N_ORIGEM $ "1|2"

		cNatureza	:= AllTrim((cAlias)->V3N_NATRUB)
		cTipo		:= AllTrim((cAlias)->V3N_TPRUBR)
		cIncidPS	:= AllTrim((cAlias)->V3N_ITCP)
		cIncidPis	:= Iif(TafColumnPos("V3N_PISPAS"), AllTrim((cAlias)->V3N_PISPAS), "")

		If (cAlias)->V3N_INDAPU == "1"

			If cNatureza == "9201" .and. cIncidPS == "31" 
				If  cTipo == "2"
					nVlINSS := (cAlias)->V3N_VALOR
				Else
					nVlINSS -= (cAlias)->V3N_VALOR
				EndIf 
				lRet := .T.
			ElseIf cNatureza == "9201" .and. cIncidPS == "32" 
				If cTipo == "2"
					nVlINSS13 += (cAlias)->V3N_VALOR
				Else
					nVlINSS13 -= (cAlias)->V3N_VALOR
				EndIf
				lRet := .T.
			ElseIf cNatureza == "9901" .And. cTipo == "3"
				nBasINSS := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "1409" .And. cIncidPS == "51"
				nSalFam := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "4050" .And. cIncidPS == "21"
				nSalMat := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "4051" .and. cIncidPS == "22"
				nSalMat13 += (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "1623" .and. cTipo == "1"
				nRessInss  := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "11" .And. cTipo == "4"
				nBasINSS -= (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf lTafGpeInss .And. cNatureza == "9989" .And. cIncidPS == "31" .And. cTipo == "3"
				nVlINSS -= (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf lTafGpeInss .And. cNatureza == "9901" .And. cTipo == "4"
				nBasINSS -= (cAlias)->V3N_VALOR
				lRet := .T.
			EndIf

		ElseIf (cAlias)->V3N_INDAPU == "2"

			If cNatureza == "9201" .And. cIncidPS == "32" 
				If cTipo == "2"
					nVlINSS13 := (cAlias)->V3N_VALOR
				Else 
					nVlINSS13 -= (cAlias)->V3N_VALOR
				EndIf
				lRet := .T.
			ElseIf cNatureza == "9901" .And. cTipo == "3"
				nBasINSS13 := (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cNatureza == "4051" .And. cIncidPS == "22"
				nSalMat13 := (cAlias)->V3N_VALOR
				lRet := .T.
			EndIf

		EndIf

		Tafsum( cIncidPis, cTipo, @nValPis, (cAlias)->V3N_VALOR, @lRet, (cAlias)->V3N_ORIGEM, @nValPis13, cIndDec )

	Case (cAlias)->V3N_ORIGEM $ "3"

		cTipo 		:= AllTrim((cAlias)->V3N_TPVLR)
		cIndDec     := AllTrim((cAlias)->V3N_INDDEC)
		cIncidPis	:= Iif(TafColumnPos("V3N_PISPAS"), AllTrim((cAlias)->V3N_PISPAS), "")

		If lCalcGrossValue

			If (cAlias)->V3N_INDAPU == '1'
				nRetValue 			:= (cAlias)->T2O_VRCPSE
				nRetDescValue 		:= (cAlias)->T2O_VRDESC
				lRet := .T.
			ElseIf (cAlias)->V3N_INDAPU == '2'
				nRet13Value 		:= (cAlias)->T2O_VRCPSE
				nRet13DescValue 	:= (cAlias)->T2O_VRDESC
				lRet := .T.
			EndIf

			TafConOut(procname() + " Dentro CalcValor nRetValue: " + cValtoChar( nRetValue ) )
			
		EndIf

		If (cAlias)->V3N_INDDEC == "0"

			If cTipo $ "11|12|13|14|15|16|17|18|19|41|42|43|44|45|46|47|48|49|81|82|83|84|85|86|87|88"
				nBasINSS 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo $ "91|92|93|94|95|96|97|98"
				nBasSusJud 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo == "21"
				nVlINSS 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo == "31"
				nSalFam += (cAlias)->V3N_VALOR
				lRet := .T.
			ElseIf cTipo == "32"
				nSalMat += (cAlias)->V3N_VALOR
				lRet := .T.
			EndIf

		ElseIf (cAlias)->V3N_INDDEC == "1"

			If cTipo $ "11|12|13|14|15|16|17|18|19|41|42|43|44|45|46|47|48|49|81|82|83|84|85|86|87|88"
				nBasINSS13 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo $ "91|92|93|94|95|96|97|98"
				nBasSusJud 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo == "21"
				nVlINSS13 	+= (cAlias)->V3N_VALOR
				lRet 		:= .T.
			ElseIf cTipo == "32"
				nSalMat13 += (cAlias)->V3N_VALOR
				lRet := .T.
			EndIf

		EndIf

		Tafsum( cIncidPis, cTipo, @nValPis, (cAlias)->V3N_VALOR, @lRet, (cAlias)->V3N_ORIGEM, @nValPis13, cIndDec )
	
	OtherWise
		lRet := .F.
	EndCase

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadHash
@type			function
@description	Carrega o hash de acodo com o arquivo de trabalho oArqTrb
@author			Verônica de Almeida
@since			19/07/2021
/*/
//---------------------------------------------------------------------
Static Function LoadHash(cTipo as character, cAlias as character, oArqTrb as object, nRessInss as numeric, nVlINSS as numeric,;
							nVlINSS13 as numeric, nBasINSS as numeric, nSalFam as numeric, nSalMat as numeric, nSalMat13 as numeric,;
							nBasINSS13 as numeric, nRetValue as numeric, nRetDescValue as numeric, nRet13Value as numeric,; 
							nRet13DescValue as numeric, jDados as json, nBasSusJud as numeric, nValPis as numeric, nValPis13 as numeric)

	Local aPos				as array
	Local cCateg			as character
	Local cEstab			as character
	Local cLotacao			as character
	Local cMatric			as character
	Local cCPF				as character

	Default cTipo			:= ""
	Default cAlias			:= ""
	Default jDados			:= JsonObject():New()
	Default nVlINSS			:= 0
	Default nRessInss		:= 0
	Default nVlINSS13		:= 0
	Default nBasINSS		:= 0
	Default nSalFam			:= 0
	Default nSalMat			:= 0
	Default nSalMat13		:= 0
	Default nBasINSS13		:= 0
	Default nRetValue		:= 0
	Default nRetDescValue	:= 0
	Default nRet13Value		:= 0
	Default nRet13DescValue	:= 0
	Default nBasSusJud		:= 0
	Default nValPis         := 0
	Default nValPis13       := 0
	Default oArqTrb			:= Nil

	aPos		:= {}
	cCateg		:= ""
	cEstab		:= ""
	cLotacao	:= ""
	cMatric		:= ""
	cCPF		:= ""

	If cTipo == 'SINTETICO'

		If TAFXHMGet( oArqTrb, AllTrim((cAlias)->V3N_CPF), @aPos )

			aPos[1, CPFFUNC]			:=	AllTrim((cAlias)->V3N_CPF)

			If !Empty((cAlias)->V3N_NOME)
				aPos[1, NOMEFUNC]			:=	EncodeUTF8(AllTrim((cAlias)->V3N_NOME))
			EndIf

			aPos[1, MATRIC]          := AllTrim((cAlias)->V3N_MATRIC)
			aPos[1, LOTAC]           := Iif(nValPis > 0 .Or. nValPis13 > 0, '' , AllTrim((cAlias)->V3N_CODLOT))
			aPos[1, ESTABELECIMENTO] := AllTrim((cAlias)->V3N_NRINSC)
			aPos[1, CATEG]           := AllTrim((cAlias)->V3N_CATEG)

			Do Case
			Case (cAlias)->V3N_ORIGEM == "1"

				aPos[1, FOLHA_BASE_INSS]								+=	nBasINSS
				aPos[1, FOLHA_VALOR_INSS]								+=	nVlINSS + nRessInss
				aPos[1, FOLHA_VALOR_SALARIO_FAMILIA]					+=	nSalFam
				aPos[1, FOLHA_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
				aPos[1, FOLHA_BASE_INSS_13_SALARIO]						+=	nBasINSS13
				aPos[1, FOLHA_VALOR_INSS_13_SALARIO]					+=	nVlINSS13 + nRessInss
				aPos[1, FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		+=	nSalMat13

			Case (cAlias)->V3N_ORIGEM == "2"

				aPos[1, TAF_BASE_INSS]									+=	nBasINSS
				aPos[1, TAF_VALOR_INSS]									+=	nVlINSS + nRessInss
				aPos[1, TAF_VALOR_SALARIO_FAMILIA]						+=	nSalFam
				aPos[1, TAF_VALOR_SALARIO_MATERNIDADE]					+=	nSalMat
				aPos[1, TAF_BASE_INSS_13_SALARIO]						+=	nBasINSS13
				aPos[1, TAF_VALOR_INSS_13_SALARIO]						+=	nVlINSS13 + nRessInss
				aPos[1, TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		+=	nSalMat13
				aPos[1, TAF_VALOR_BASE_PISPASEP]		                +=	nValPis
				aPos[1, TAF_VALOR_BASE_PISPASEP_13]		                +=	nValPis13

			Case (cAlias)->V3N_ORIGEM == "3"

				aPos[1, GOVERNO_BASE_INSS]								+=	nBasINSS
				aPos[1, GOVERNO_VALOR_INSS]								+=	nVlINSS + nRessInss
				aPos[1, GOVERNO_VALOR_SALARIO_FAMILIA]					+=	nSalFam
				aPos[1, GOVERNO_VALOR_SALARIO_MATERNIDADE]				+=	nSalMat
				aPos[1, GOVERNO_BASE_INSS_13_SALARIO]					+=	nBasINSS13
				aPos[1, GOVERNO_VALOR_INSS_13_SALARIO]					+=	nVlINSS13 + nRessInss
				aPos[1, GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+=	nSalMat13
				aPos[1, GOVERNO_VALOR_BASE_PISPASEP]		            +=	nValPis
				aPos[1, GOVERNO_VALOR_BASE_PISPASEP_13]		            +=	nValPis13
				aPos[1, GOVERNO_LOCALIZADO]								:=	.T.

				aPos[1, GOVERNO_GROSS_VALUE]							+=	nRetValue
				aPos[1, GOVERNO_DESC_GROSS_VALUE]						+=	nRetDescValue
				aPos[1, GOVERNO_13_GROSS_VALUE]							+=	nRet13Value
				aPos[1, GOVERNO_13_DESC_GROSS_VALUE]					+=	nRet13DescValue

			EndCase

			aPos[1, RECIBO_TRANSMISSAO]		:= (cAlias)->V3N_RECIBO

			TafConOut(procname() + " Dentro LoadHash ALTERA nRetValue: " + cValtoChar( nRetValue ) + " CPF: " + aPos[1, CPFFUNC] )
			TafConOut(procname() + " Dentro LoadHash ALTERA GOVERNO_GROSS_VALUE: " + cValtoChar( aPos[1, GOVERNO_GROSS_VALUE] ) + " CPF: " + aPos[1, CPFFUNC] )

			TAFXHMSet( oArqTrb, aPos[1, CPFFUNC], aPos )

		Else

			aPos := R123InitArray()

			aPos[CPFFUNC]         := AllTrim((cAlias)->V3N_CPF)
			aPos[NOMEFUNC]        := EncodeUTF8(AllTrim((cAlias)->V3N_NOME))
			aPos[MATRIC]          := AllTrim((cAlias)->V3N_MATRIC)
			aPos[LOTAC]           := Iif(nValPis > 0 .Or. nValPis13 > 0, '' , AllTrim((cAlias)->V3N_CODLOT))
			aPos[ESTABELECIMENTO] := AllTrim((cAlias)->V3N_NRINSC)
			aPos[CATEG]           := AllTrim((cAlias)->V3N_CATEG)

			Do Case
			Case (cAlias)->V3N_ORIGEM == "1"

				aPos[FOLHA_BASE_INSS]								:= nBasINSS
				aPos[FOLHA_VALOR_INSS]								:= nVlINSS + nRessInss
				aPos[FOLHA_VALOR_SALARIO_FAMILIA]					:= nSalFam
				aPos[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= nSalMat
				aPos[FOLHA_BASE_INSS_13_SALARIO]					:= nBasINSS13
				aPos[FOLHA_VALOR_INSS_13_SALARIO]					:= nVlINSS13 + nRessInss
				aPos[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= nSalMat13

			Case (cAlias)->V3N_ORIGEM == "2"

				aPos[TAF_BASE_INSS]									:=	nBasINSS
				aPos[TAF_VALOR_INSS]								:=	nVlINSS + nRessInss
				aPos[TAF_VALOR_SALARIO_FAMILIA]						:=	nSalFam
				aPos[TAF_VALOR_SALARIO_MATERNIDADE]					:=	nSalMat
				aPos[TAF_BASE_INSS_13_SALARIO]						:=	nBasINSS13
				aPos[TAF_VALOR_INSS_13_SALARIO]						:=	nVlINSS13 + nRessInss
				aPos[TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		:=	nSalMat13
				aPos[TAF_VALOR_BASE_PISPASEP]		                :=	nValPis
				aPos[TAF_VALOR_BASE_PISPASEP_13]		            :=	nValPis13

			Case (cAlias)->V3N_ORIGEM == "3"

				aPos[GOVERNO_BASE_INSS]								:= nBasINSS
				aPos[GOVERNO_VALOR_INSS]							:= nVlINSS + nRessInss
				aPos[GOVERNO_VALOR_SALARIO_FAMILIA]					:= nSalFam
				aPos[GOVERNO_VALOR_SALARIO_MATERNIDADE]				:= nSalMat
				aPos[GOVERNO_BASE_INSS_13_SALARIO]					:= nBasINSS13
				aPos[GOVERNO_VALOR_INSS_13_SALARIO]					:= nVlINSS13 + nRessInss
				aPos[GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= nSalMat13
				aPos[GOVERNO_LOCALIZADO]							:= .T.

				aPos[GOVERNO_GROSS_VALUE]							:= nRetValue
				aPos[GOVERNO_DESC_GROSS_VALUE]						:= nRetDescValue
				aPos[GOVERNO_13_GROSS_VALUE]						:= nRet13Value
				aPos[GOVERNO_13_DESC_GROSS_VALUE]					:= nRet13DescValue
				aPos[GOVERNO_VALOR_BASE_PISPASEP]		            := nValPis
				aPos[GOVERNO_VALOR_BASE_PISPASEP_13]		        := nValPis13

			EndCase

			aPos[RECIBO_TRANSMISSAO]	:= (cAlias)->V3N_RECIBO

			TafConOut(procname() + " Dentro LoadHash INCLUI nRetValue: " + cValtoChar( nRetValue ) + " CPF: " + aPos[CPFFUNC] )
			TafConOut(procname() + " Dentro LoadHash INCLUI GOVERNO_GROSS_VALUE: " + cValtoChar( aPos[GOVERNO_GROSS_VALUE] ) + " CPF: " + aPos[CPFFUNC] )

			TAFXHMAdd(oArqTrb, aPos, CPFFUNC, 3)
		EndIf

		nBasINSS			:= 0
		nVlINSS				:= 0
		nRessInss			:= 0
		nSalFam				:= 0
		nSalMat				:= 0
		nBasINSS13			:= 0
		nVlINSS13			:= 0
		nSalMat13			:= 0
		nRetValue 			:= 0
		nRetDescValue 		:= 0
		nRet13Value 		:= 0
		nRet13DescValue 	:= 0
		nValPis             := 0
		nValPis13           := 0

		aPos := {}
		FreeObj(aPos)

	ElseIf cTipo == 'ANALITICO'

		If nValPis > 0 .Or. nValPis13 > 0

			TAFXHMGet( oArqTrb, AllTrim((cAlias)->V3N_NRINSC) + AllTrim((cAlias)->V3N_CPF) + AllTrim((cAlias)->V3N_MATRIC) + AllTrim((cAlias)->V3N_CATEG), @aPos )

		Else
	
			TAFXHMGet( oArqTrb, AllTrim((cAlias)->V3N_NRINSC) + AllTrim((cAlias)->V3N_CPF) + AllTrim((cAlias)->V3N_MATRIC) + AllTrim((cAlias)->V3N_CATEG) + AllTrim((cAlias)->V3N_CODLOT), @aPos )

		EndIf

		If !Empty(aPos)
			
			aPos[1, CPFFUNC]			:= AllTrim((cAlias)->V3N_CPF)
			aPos[1, NOMEFUNC]			:= EncodeUTF8(AllTrim((cAlias)->V3N_NOME))
			aPos[1, MATRIC]				:= AllTrim((cAlias)->V3N_MATRIC)
			aPos[1, LOTAC]	          	:= Iif(nValPis > 0 .Or. nValPis13 > 0, '' , AllTrim((cAlias)->V3N_CODLOT))
			aPos[1, ESTABELECIMENTO]	:= AllTrim((cAlias)->V3N_NRINSC)
			aPos[1, CATEG]				:= AllTrim((cAlias)->V3N_CATEG)
			aPos[1, CAT_DESCRI]			:= EncodeUTF8(AllTrim((cAlias)->V3N_CATEG)  + ' - ' +  AllTrim((cAlias)->C87_DESCRI))

			Do Case

				Case (cAlias)->V3N_ORIGEM == "1"

					aPos[1, FOLHA_BASE_INSS]								+= nBasINSS					// inssBasis
					aPos[1, FOLHA_VALOR_INSS]								+= nVlINSS + nRessInss		// inssValue
					aPos[1, FOLHA_VALOR_SALARIO_FAMILIA]					+= nSalFam					// familySalaryValue
					aPos[1, FOLHA_VALOR_SALARIO_MATERNIDADE]				+= nSalMat					// maternitySalaryValue
					aPos[1, FOLHA_BASE_INSS_13_SALARIO]						+= nBasINSS13				// inss13Basis
					aPos[1, FOLHA_VALOR_INSS_13_SALARIO]					+= nVlINSS13 + nRessInss	// inss13Value
					aPos[1, FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		+= nSalMat13				// maternitySalary13Value
				
				Case (cAlias)->V3N_ORIGEM == "2"

					aPos[1, TAF_BASE_INSS]									+= nBasINSS					// inssTafBasis
					aPos[1, TAF_VALOR_INSS]									+= nVlINSS + nRessInss		// inssTafValue
					aPos[1, TAF_VALOR_SALARIO_FAMILIA]						+= nSalFam					// familySalaryTafValue
					aPos[1, TAF_VALOR_SALARIO_MATERNIDADE]					+= nSalMat					// maternitySalaryTafValue
					aPos[1, TAF_BASE_INSS_13_SALARIO]						+= nBasINSS13				// inss13TafBasis
					aPos[1, TAF_VALOR_INSS_13_SALARIO]						+= nVlINSS13 + nRessInss	// inss13TafValue
					aPos[1, TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		+= nSalMat13				// maternitySalary13TafRetValue
                    aPos[1, TAF_VALOR_BASE_PISPASEP]                        += nValPis                  // pisPasepTafValue
					aPos[1, TAF_VALOR_BASE_PISPASEP_13]                     += nValPis13                // pisPasep13TafValue

				Case (cAlias)->V3N_ORIGEM == "3"

					aPos[1, GOVERNO_BASE_INSS]								+= nBasINSS	- nBasSusJud	// inssRetBasis
					aPos[1, GOVERNO_BASE_SUSPENSAO]							+= nBasSusJud
					aPos[1, GOVERNO_BASE_TOTAL_INSS]						+= nBasINSS
					aPos[1, GOVERNO_VALOR_INSS]								+= nVlINSS + nRessInss		// inssRetValue
					aPos[1, GOVERNO_VALOR_SALARIO_FAMILIA]					+= nSalFam					// familySalaryRetValue
					aPos[1, GOVERNO_VALOR_SALARIO_MATERNIDADE]				+= nSalMat					// maternitySalaryRetValue
					aPos[1, GOVERNO_BASE_INSS_13_SALARIO]					+= nBasINSS13				// inss13RetBasis
					aPos[1, GOVERNO_VALOR_INSS_13_SALARIO]					+= nVlINSS13 + nRessInss	// inss13RetValue
					aPos[1, GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+= nSalMat13				// maternitySalary13RetValue
					aPos[1, GOVERNO_VALOR_BASE_PISPASEP]                    += nValPis                  // pisPasepRetBasis
					aPos[1, GOVERNO_VALOR_BASE_PISPASEP_13]                 += nValPis13                // pisPasep13RetBasis
					aPos[1, GOVERNO_LOCALIZADO]								:= .T.

					aPos[1, GOVERNO_GROSS_VALUE]							+= nRetValue
					aPos[1, GOVERNO_DESC_GROSS_VALUE]						+= nRetDescValue
					aPos[1, GOVERNO_13_GROSS_VALUE]							+= nRet13Value
					aPos[1, GOVERNO_13_DESC_GROSS_VALUE]					+= nRet13DescValue

			EndCase

			aPos[1, RECIBO_TRANSMISSAO]	:= (cAlias)->V3N_RECIBO

			TAFXHMSet(oArqTrb, aPos[1, ESTABELECIMENTO] + aPos[1, CPFFUNC] + aPos[1, MATRIC] + aPos[1, CATEG] + aPos[1, LOTAC], aPos)

		Else

			aPos                  := R123InitArray()
			aPos[CPFFUNC]         := AllTrim((cAlias)->V3N_CPF)
			aPos[NOMEFUNC]        := EncodeUTF8(AllTrim((cAlias)->V3N_NOME))
			aPos[MATRIC]          := AllTrim((cAlias)->V3N_MATRIC)
			aPos[LOTAC]           := Iif(nValPis > 0 .Or. nValPis13 > 0, '' , AllTrim((cAlias)->V3N_CODLOT))
			aPos[ESTABELECIMENTO] := AllTrim((cAlias)->V3N_NRINSC)
			aPos[CATEG]           := AllTrim((cAlias)->V3N_CATEG)
			aPos[CAT_DESCRI]      := EncodeUTF8(AllTrim((cAlias)->V3N_CATEG) + " - " + AllTrim((cAlias)->C87_DESCRI))

			Do Case
				Case (cAlias)->V3N_ORIGEM == "1"

					aPos[FOLHA_BASE_INSS]								:= nBasINSS
					aPos[FOLHA_VALOR_INSS]								:= nVlINSS + nRessInss
					aPos[FOLHA_VALOR_SALARIO_FAMILIA]					:= nSalFam
					aPos[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= nSalMat
					aPos[FOLHA_BASE_INSS_13_SALARIO]					:= nBasINSS13
					aPos[FOLHA_VALOR_INSS_13_SALARIO]					:= nVlINSS13 + nRessInss
					aPos[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= nSalMat13           
				
				Case (cAlias)->V3N_ORIGEM == "2"

					aPos[TAF_BASE_INSS]									:= nBasINSS
					aPos[TAF_VALOR_INSS]								:= nVlINSS + nRessInss
					aPos[TAF_VALOR_SALARIO_FAMILIA]						:= nSalFam
					aPos[TAF_VALOR_SALARIO_MATERNIDADE]					:= nSalMat
					aPos[TAF_BASE_INSS_13_SALARIO]						:= nBasINSS13
					aPos[TAF_VALOR_INSS_13_SALARIO]						:= nVlINSS13 + nRessInss
					aPos[TAF_VALOR_SALARIO_MATERNIDADE_13_SALARIO]		:= nSalMat13
					aPos[TAF_VALOR_BASE_PISPASEP]                       := nValPis
					aPos[TAF_VALOR_BASE_PISPASEP_13]                    := nValPis13

				Case (cAlias)->V3N_ORIGEM == "3"

					aPos[GOVERNO_BASE_INSS]								:= nBasINSS - nBasSusJud
					aPos[GOVERNO_BASE_SUSPENSAO]						:= nBasSusJud
					aPos[GOVERNO_BASE_TOTAL_INSS]						:= nBasINSS
					aPos[GOVERNO_VALOR_INSS]							:= nVlINSS + nRessInss
					aPos[GOVERNO_VALOR_SALARIO_FAMILIA]					:= nSalFam
					aPos[GOVERNO_VALOR_SALARIO_MATERNIDADE]				:= nSalMat
					aPos[GOVERNO_BASE_INSS_13_SALARIO]					:= nBasINSS13
					aPos[GOVERNO_VALOR_INSS_13_SALARIO]					:= nVlINSS13 + nRessInss
					aPos[GOVERNO_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= nSalMat13
					aPos[GOVERNO_VALOR_BASE_PISPASEP]                   := nValPis
					aPos[GOVERNO_VALOR_BASE_PISPASEP_13]                := nValPis13
					aPos[GOVERNO_LOCALIZADO]							:= .T.

					aPos[GOVERNO_GROSS_VALUE]							:= nRetValue
					aPos[GOVERNO_DESC_GROSS_VALUE]						:= nRetDescValue
					aPos[GOVERNO_13_GROSS_VALUE]						:= nRet13Value
					aPos[GOVERNO_13_DESC_GROSS_VALUE]					:= nRet13DescValue

			EndCase

			aPos[RECIBO_TRANSMISSAO] := (cAlias)->V3N_RECIBO

			TAFXHMAdd(oArqTrb, aPos, ESTABELECIMENTO, 3, CPFFUNC, 3, MATRIC, 3, CATEG, 3, LOTAC, 3)

		EndIf

		nBasINSS		:= 0
		nVlINSS			:= 0
		nRessInss		:= 0
		nSalFam			:= 0
		nSalMat			:= 0
		nBasINSS13		:= 0
		nVlINSS13		:= 0
		nSalMat13		:= 0
		nRetValue 		:= 0
		nRetDescValue 	:= 0
		nRet13Value 	:= 0
		nRet13DescValue := 0
		nBasSusJud		:= 0
		nValPis         := 0
		nValPis13       := 0
		aPos 			:= {}
		
		FreeObj(aPos)

	ElseIf cTipo == 'RH'

		cCateg		:= AllTrim(IIf(ValType(jDados["esocialCategory"]) == "N", cValToChar(jDados["esocialCategory"]), jDados["esocialCategory"]))
		cEstab		:= AllTrim(GetBranchID(jDados["branchId"]))
		cLotacao	:= AllTrim(jDados["lotationCode"])
		cMatric		:= AllTrim(jDados["esocialRegistration"])
		cCPF		:= AllTrim(jDados["cpfNumber"])

		If jDados["pisPasepBasis"] > 0 .Or. jDados["pisPasep13Basis"] > 0

			TAFXHMGet(oArqTrb, cEstab + cCPF + cMatric + cCateg, @aPos)

		Else
	
			TAFXHMGet(oArqTrb, cEstab + cCPF + cMatric + cCateg + cLotacao, @aPos)

		EndIf

		If !Empty(aPos)

			aPos[1][CPFFUNC]									:=	cCPF
			aPos[1][NOMEFUNC]									:=	EncodeUTF8(AllTrim(jDados["name"]))
			aPos[1][MATRIC]										:=	cMatric
			aPos[1][LOTAC]										:=	cLotacao
			aPos[1][ESTABELECIMENTO]							:=	cEstab
			aPos[1][CATEG]										:=	cCateg
			aPos[1][CAT_DESCRI]									:=	EncodeUTF8(cCateg  + ' - ' + AllTrim(Posicione('C87',2,xFilial('C87') + cCateg,'C87_DESCRI')) )

			aPos[1][FOLHA_BASE_INSS]							+= jDados["inssBasis"]
			aPos[1][FOLHA_VALOR_INSS]							+= jDados["inssValue"]
			aPos[1][FOLHA_VALOR_SALARIO_FAMILIA]				+= jDados["familySalaryValue"]
			aPos[1][FOLHA_VALOR_SALARIO_MATERNIDADE]			+= jDados["maternitySalaryValue"]
			aPos[1][FOLHA_BASE_INSS_13_SALARIO]					+= jDados["inss13Basis"]
			aPos[1][FOLHA_VALOR_INSS_13_SALARIO]				+= jDados["inss13Value"]
			aPos[1][FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	+= jDados["maternitySalary13Value"]
			aPos[1][FOLHA_VALOR_BASE_PISPASEP]	                += jDados["pisPasepBasis"]
			aPos[1][FOLHA_VALOR_BASE_PISPASEP_13]	            += jDados["pisPasep13Basis"]

			TAFXHMSet(oArqTrb, aPos[1][ESTABELECIMENTO] + aPos[1][CPFFUNC] + aPos[1][MATRIC] + aPos[1][CATEG] + aPos[1][LOTAC], aPos)

		Else

			aPos 												:= R123InitArray()

			aPos[CPFFUNC]										:=	cCPF
			aPos[NOMEFUNC]										:=	EncodeUTF8(AllTrim(jDados["name"]))
			aPos[MATRIC]										:=	cMatric
			aPos[LOTAC]											:=	cLotacao
			aPos[ESTABELECIMENTO]								:=	cEstab
			aPos[CATEG]											:=	cCateg
			aPos[CAT_DESCRI]									:=	EncodeUTF8(cCateg + ' - ' + AllTrim(Posicione('C87',2,xFilial('C87') + cCateg,'C87_DESCRI')) )

			aPos[FOLHA_BASE_INSS]								:= jDados["inssBasis"]
			aPos[FOLHA_VALOR_INSS]								:= jDados["inssValue"]
			aPos[FOLHA_VALOR_SALARIO_FAMILIA]					:= jDados["familySalaryValue"]
			aPos[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= jDados["maternitySalaryValue"]
			aPos[FOLHA_BASE_INSS_13_SALARIO]					:= jDados["inss13Basis"]
			aPos[FOLHA_VALOR_INSS_13_SALARIO]					:= jDados["inss13Value"]
			aPos[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= jDados["maternitySalary13Value"]
			aPos[FOLHA_VALOR_BASE_PISPASEP]	                    := jDados["pisPasepBasis"]
			aPos[FOLHA_VALOR_BASE_PISPASEP_13]	                := jDados["pisPasep13Basis"]

			TAFXHMAdd(oArqTrb, aPos, ESTABELECIMENTO, 3, CPFFUNC, 3, MATRIC, 3, CATEG, 3, LOTAC, 3)

		EndIf

		aPos		:= {}
		nBasINSS	:= 0
		nVlINSS		:= 0
		nRessInss	:= 0
		nSalFam		:= 0
		nSalMat		:= 0
		nBasINSS13	:= 0
		nVlINSS13	:= 0
		nSalMat13	:= 0
		nValPis     := 0
		nValPis13     := 0

		FWFreeArray(aPos)

	EndIf

Return oArqTrb

//---------------------------------------------------------------------
/*/{Protheus.doc} LegacyStatus
@type			method
@description	Método para consultar status do serviço do ERP Legado.
@author			Verônica de Almeida
@since			19/07/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET LegacyStatus QUERYPARAM companyId WSRESTFUL reportEsocialBaseConfer

	Local aCompany			as array
	Local aHeader			as array
	Local cEmpRequest		as character
	Local cFilRequest 		as character
	Local cRmUrl			as character
	Local cFilRH			as character
	Local cError			as character
	Local cPath				as character
	Local cErrorApi			as character
	Local lRet        		as logical
	Local lIsConfigured		as logical
	Local lIsAvailable		as logical
	Local lInssIsUpToDate	as logical
	Local lFgtsIsUpToDate	as logical
	Local lIrrfIsUpToDate   as logical
	Local oRest				as object
	Local oResponse   		as object

	aCompany			:= {}
	aHeader				:= {}
	cEmpRequest			:= ""
	cFilRequest 		:= ""
	cRmUrl				:= ""
	cFilRH				:= ""
	cError				:= ""
	cPath				:= "/api/rh/esocial/v1/reportEsocialBaseConfer"
	lRet        		:= .T.
	lIsConfigured		:= .T.
	lIsAvailable		:= .T.
	lInssIsUpToDate		:= .T.
	lFgtsIsUpToDate		:= .T.
	lIrrfIsUpToDate   	:= .T.
	cErrorApi			:= ""
	oRest				:= Nil
	oResponse   		:= JsonObject():New()

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

			If PrepEnv( cEmpRequest, cFilRequest )

				cRmUrl 			:= AllTrim( GetNewPar( "MV_TAFRHUR", "" ))
				lIsConfigured 	:= (TAFAlsInDic( "V5H" ) .And. !Empty( cRmUrl ) )

				If lIsConfigured

					aHeader := Iif( !Empty( AllTrim( GetNewPar( "MV_TAFRHLG", "" ) ) ), GetHeader(), {} )

					// Busca coligada RM
					cFilRH 			:= GetFilRH(aHeader)
					lIsAvailable 	:= (cFilRH <> Nil)

					If lIsAvailable .and. SubStr(cFilRH, 1, 5) ==  "(ERRO"

						cErrorApi 		:= cFilRH
						lIsAvailable 	:= .F.
						lInssIsUpToDate := .F.
						lIrrfIsUpToDate := .F.

					EndIf 

					If lIsAvailable

						oRest := FWRest():New(cRmUrl)

						oRest:SetPath(cPath + "/InssRetValues")
						oRest:Get(aHeader)
						
						cError 			:= oRest:GetLastError()
						lInssIsUpToDate := !("404" $ cError)
						oRest 			:= Nil
						
						FreeObj(oRest)

					EndIf

				EndIf

				oResponse["isConfigured"]	:= lIsConfigured
				oResponse["isAvailable"]	:= lIsAvailable
				oResponse["inssIsUpToDate"]	:= lInssIsUpToDate
				oResponse["fgtsIsUpToDate"]	:= lFgtsIsUpToDate
				oResponse["irrfIsUpToDate"]	:= lIrrfIsUpToDate  
				oResponse["apiReturnError"]	:= cErrorApi
						
				::SetResponse(oResponse:ToJson())

			Else

				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )

			EndIf

		EndIf

	EndIf

	FwFreeObj(oResponse)

Return lRet 

//---------------------------------------------------------------------
/*/{Protheus.doc} LoadHashLegacy
@type			method
@description	Método carregar o hash com valores do RH
@author			Verônica de Almeida
@since			19/07/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
Static Function LoadHashLegacy(cTicket, oArqTrb)

	Local aPos	:= {}
	Local cAliasV5H := V5HByTicket(cTicket)

	If !Empty(cAliasV5H)

		(cAliasV5H)->( dbGoTop() )

		While (cAliasV5H)->( !Eof() )

			If TAFXHMGet( oArqTrb, AllTrim((cAliasV5H)->V5H_CPF), @aPos )

				aPos[1][CPFFUNC]									:=	AllTrim((cAliasV5H)->V5H_CPF)
				aPos[1][NOMEFUNC]									:=	AllTrim((cAliasV5H)->V5H_NOME)
				aPos[1][MATRIC]										:=	AllTrim((cAliasV5H)->V5H_MATRIC)
				aPos[1][LOTAC]										:=	AllTrim((cAliasV5H)->V5H_LOTACA)
				aPos[1][ESTABELECIMENTO]							:=	AllTrim((cAliasV5H)->V5H_ESTABE)
				aPos[1][CATEG]										:=	AllTrim((cAliasV5H)->V5H_CATEG)
				aPos[1][FOLHA_BASE_INSS]							:= (cAliasV5H)->V5H_BSINSS
				aPos[1][FOLHA_VALOR_INSS]							:= (cAliasV5H)->V5H_VLINSS
				aPos[1][FOLHA_VALOR_SALARIO_FAMILIA]				:= (cAliasV5H)->V5H_VLFAM
				aPos[1][FOLHA_VALOR_SALARIO_MATERNIDADE]			:= (cAliasV5H)->V5H_VLMAT
				aPos[1][FOLHA_BASE_INSS_13_SALARIO]					:= (cAliasV5H)->V5H_BS13
				aPos[1][FOLHA_VALOR_INSS_13_SALARIO]				:= (cAliasV5H)->V5H_VL13
				aPos[1][FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= (cAliasV5H)->V5H_VLMT13

				If TafColumnPos("V5H_PISPAS")
					aPos[1][FOLHA_VALOR_BASE_PISPASEP]	                := (cAliasV5H)->V5H_PISPAS
					aPos[1][FOLHA_VALOR_BASE_PISPASEP_13]	            := (cAliasV5H)->V5H_PIS13
				EndIf

				TAFXHMSet( oArqTrb, aPos[1][CPFFUNC], aPos )
			Else
				aPos := R123InitArray()

				aPos[CPFFUNC]										:=	AllTrim((cAliasV5H)->V5H_CPF)
				aPos[NOMEFUNC]										:=	AllTrim((cAliasV5H)->V5H_NOME)
				aPos[MATRIC]										:=	AllTrim((cAliasV5H)->V5H_MATRIC)
				aPos[LOTAC]											:=	AllTrim((cAliasV5H)->V5H_LOTACA)
				aPos[ESTABELECIMENTO]								:=	AllTrim((cAliasV5H)->V5H_ESTABE)
				aPos[CATEG]											:=	AllTrim((cAliasV5H)->V5H_CATEG)
				aPos[FOLHA_BASE_INSS]								:= (cAliasV5H)->V5H_BSINSS
				aPos[FOLHA_VALOR_INSS]								:= (cAliasV5H)->V5H_VLINSS
				aPos[FOLHA_VALOR_SALARIO_FAMILIA]					:= (cAliasV5H)->V5H_VLFAM
				aPos[FOLHA_VALOR_SALARIO_MATERNIDADE]				:= (cAliasV5H)->V5H_VLMAT
				aPos[FOLHA_BASE_INSS_13_SALARIO]					:= (cAliasV5H)->V5H_BS13
				aPos[FOLHA_VALOR_INSS_13_SALARIO]					:= (cAliasV5H)->V5H_VL13
				aPos[FOLHA_VALOR_SALARIO_MATERNIDADE_13_SALARIO]	:= (cAliasV5H)->V5H_VLMT13

				If TafColumnPos("V5H_PISPAS")
					aPos[FOLHA_VALOR_BASE_PISPASEP]	                := (cAliasV5H)->V5H_PISPAS
					aPos[FOLHA_VALOR_BASE_PISPASEP_13]	            := (cAliasV5H)->V5H_PIS13
				EndIf

				TAFXHMAdd(oArqTrb, aPos, CPFFUNC, 3)

			EndIf

			(cAliasV5H)->( dbSkip() )

		EndDo

	EndIf

	aPos := {}
	FreeObj(aPos)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FilMatriz
@type function
@description Retorna todas as filiais da matriz logada
@author Melkz Siqueira
@since 06/04/2022
@version 1.0		
@return aFiliais - Retornar um array com as filiais
/*/
//-------------------------------------------------------------------
Static Function FilMatriz()

	Local aFiliais := {}

	C1E->(DBSetOrder(3))
	
	If C1E->(MsSeek(xFilial("C1E") + PadR(cFilAnt, GetSX3Cache("C1E_FILTAF", "X3_TAMANHO")) + "1"))
		If C1E->C1E_MATRIZ
			aFiliais := LoadSM0BaseCNPJ()
		EndIf
	EndIf

	If Empty(aFiliais)
		aAdd(aFiliais, cFilAnt)
	EndIf

Return aFiliais

//-------------------------------------------------------------------
/*/{Protheus.doc} FilTabela
@type function
@description Retorna todas as filiais de acordo com o compartilhamento da tabela
@author Melkz Siqueira
@since 06/04/2022
@version 1.0
@param cTabela - Alias da tabela
@param aFiliais - Array de filiais retornado por referência		
/*/
//-------------------------------------------------------------------
Static Function FilTabela(cTabela, aFiliais, aModoAcess)

	Local aFilMatriz	:= {}
	Local nX			:= 0

	Default aFiliais	:= {}
	Default aModoAcess	:= {}
	Default cTabela 	:= ""
	
	If CheckMdAcc(cTabela, @aModoAcess)
		If !Empty(cTabela)
			aFilMatriz := FilMatriz()

			For nX := 1 To Len(aFilMatriz)
				AAdd(aFiliais, xFilial(cTabela, aFilMatriz[nX]))
			Next
		EndIf
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckMdAcc
@type function
@description Compara os modos de acesso entre as tabelas 
@author Melkz Siqueira
@since 06/04/2022
@version 1.0
@param cTabela - Alias da tabela
@param aModoAcess - Array com os modos de acesso	
/*/
//-------------------------------------------------------------------
Static Function CheckMdAcc(cTabela, aModoAcess)

	Local aSX2Data		:= {}
	Local lRet			:= .F.
	Local nX			:= 0

	Default aModoAcess	:= {} 
	Default cTabela 	:= ""

	If !Empty(cTabela)
		If FwLibVersion() >= "20180912"
			aSX2Data := FwSX2Util():GetSX2data(cTabela, {"X2_MODO", "X2_MODOUN", "X2_MODOEMP"})
			
			If !(aSX2Data[1][2] == "C" .And. aSX2Data[2][2] == "C" .And. aSX2Data[3][2] == "C")
				If Empty(aModoAcess)
					AAdd(aModoAcess, aSX2Data)

					lRet := .T.
				Else
					For nX := 1 To Len(aModoAcess)
						If !(aModoAcess[nX][1][2] == aSX2Data[1][2] .And. aModoAcess[nX][2][2] == aSX2Data[2][2] .And. aModoAcess[nX][3][2] == aSX2Data[3][2])
							AAdd(aModoAcess, aSX2Data)

							lRet := .T.
						EndIf
					Next
				EndIf
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TpInscPic
@Description Faz o tratamento do número de inscrição com a picture 
de acordo com o tipo de inscrição informado.

Tipo de inscrição:	1 - CNPJ
					2 - CPF
					3 - CAEPF
					4 - CNO

@param cTpInsc - Tipo de inscrição
@param cNrInsc - Número de inscrição

@return cNrInsc - Número de inscrição com o tratamento de picture

@author Melkz Siqueira
@since 12/04/2022
@version 1.0		
/*/
//-------------------------------------------------------------------
Static Function TpInscPic(cTpInsc, cNrInsc)

	Default cTpInsc := ""
	Default cNrInsc	:= ""
	
	If !("/" $ cNrInsc .Or. "." $ cNrInsc .Or. "-" $ cNrInsc) .And. !Empty(cTpInsc) .And. !Empty(cNrInsc)

		Do Case
			Case cTpInsc == '1'
				cNrInsc := Transform(AllTrim(cNrInsc), "@R! NN.NNN.NNN/NNNN-99")

			Case cTpInsc == '2'
				cNrInsc := Transform(AllTrim(cNrInsc), "@R 999.999.999-99")

			Case cTpInsc == '3'
				cNrInsc := Transform(AllTrim(cNrInsc), "@R 999.999.999/999-99")

			Case cTpInsc == '4'
				cNrInsc := Transform(AllTrim(cNrInsc), "@R 99.999.99999/99")
		EndCase

	EndIf

Return cNrInsc

//---------------------------------------------------------------------
/*/{Protheus.doc} V5HGetRhValues
	Recupera informações de valores de INSS já calculados e anteriormente gravados na V5H 
	
	@type  Static Function
	@author Fabio Mendonça
	@since 17/02/2023
	@version 1.0
	@param 	cTicket	-	Ticket da Requisição
	@param 	cCPF	-	CPF do Trabalhador

	@return aRetRhValues	-	Array com Valores de INSS filtrados da V5H
/*/
//---------------------------------------------------------------------
Static Function V5HGetRhValues(cTicket as character, cCPF as character) as array

	Local aRetRhValues 	as array
	Local jRhValues		as json

	aRetRhValues	:= {}
	cAliasV5H		:= V5HByTicket(cTicket, cCPF, "1")

	If !Empty(cAliasV5H)

		(cAliasV5H)->(dbGoTop())

		While (cAliasV5H)->(!Eof()) 

			jRhValues 							:= JsonObject():New()
			jRhValues["esocialCategory"]        := AllTrim((cAliasV5H)->V5H_CATEG)
			jRhValues["branchId"]               := AllTrim((cAliasV5H)->V5H_ESTABE)
			jRhValues["lotationCode"]           := AllTrim((cAliasV5H)->V5H_LOTACA)
			jRhValues["esocialRegistration"]    := AllTrim((cAliasV5H)->V5H_MATRIC)
			jRhValues["cpfNumber"]              := AllTrim((cAliasV5H)->V5H_CPF)
			jRhValues["name"]                   := AllTrim((cAliasV5H)->V5H_NOME)
			jRhValues["inssBasis"]              := (cAliasV5H)->V5H_BSINSS
			jRhValues["inssValue"]              := (cAliasV5H)->V5H_VLINSS
			jRhValues["familySalaryValue"]      := (cAliasV5H)->V5H_VLFAM
			jRhValues["maternitySalaryValue"]   := (cAliasV5H)->V5H_VLMAT
			jRhValues["inss13Basis"]            := (cAliasV5H)->V5H_BS13
			jRhValues["inss13Value"]            := (cAliasV5H)->V5H_VL13
			jRhValues["maternitySalary13Value"] := (cAliasV5H)->V5H_VLMT13

			If TafColumnPos("V5H_PISPAS")
				jRhValues["pisPasepBasis"]      := (cAliasV5H)->V5H_PISPAS
				jRhValues["pisPasep13Basis"]    := (cAliasV5H)->V5H_PIS13
			EndIf

			AADD(aRetRhValues, jRhValues)
			(cAliasV5H)->(dbSkip())

		EndDo

	EndIf
	
Return aRetRhValues

//---------------------------------------------------------------------
/*/{Protheus.doc} IRRFInitArray
Inicializa o array com as devidas posições em branco/zerada
@type  static
@author Alexandre de Lima Santos / Fábio Mendonça
@since 20/05/2019
@version 1

Return aInit - Array inicializado do zero
/*/
//---------------------------------------------------------------------
Static Function IRRFInitArray()

	Local aInit as array

	aInit 		:= Array(30)
	aInit[1]	:= ""
	aInit[2]	:= ""
	aInit[3]	:= ""
	aInit[4]	:= ""
	aInit[5]	:= ""
	aInit[6]	:= ""
	aInit[7]	:= ""
	aInit[8]	:= 0
	aInit[9]	:= 0
	aInit[10]	:= {}
	aInit[11]	:= 0
	aInit[12]	:= .F.
	aInit[13]   := 0
	aInit[14]   := {}
	aInit[15]   := 0
	aInit[16]   := 0
	aInit[17]   := 0
	aInit[18]   := 0
	aInit[19]   := 0
	aInit[20]   := 0
	aInit[21]   := 0
	aInit[22]   := 0
	aInit[23]   := 0
	aInit[24]   := 0
	aInit[25]   := 0
	aInit[26]   := 0
	aInit[27]   := 0
	aInit[28]   := 0
	aInit[29]   := 0
	aInit[30]   := 0

Return aInit

//---------------------------------------------------------------------
/*/{Protheus.doc} addDmDev
	Função para somar o nível por demostrativos
	@type  Function
	@author Alexandre de Lima / Fábio Mendonça
	@since 09/08/2023
	@version version

	@param aPos - array - [1][1] - Id do demostrativo
	                      [1][2] - Valor do taf
						  [1][3] - Valor do Erp
						  [1][4] - Valor do ret
						  [1][5] - Data de pagamento do demostrativo
						  [1][6] - Data de referencia do demostrativo
						  [1][7] - Evento que originou o S-5002

	paramc DmDev as character 	- Identifição do demonstrativo
	paramn DmTafVal as numeric 	- Valor a ser somado 
	paramc DmDevar as character	- Variavel de controle para sabermos a qual coluna devemos somar
	paramc DtPag as character, 	- Data de pagamento do demostrativo	
	paramc PerRef as character, - Data de referencia do demostrativo
	param  cEvento as character - Evento que originou o S-5002
	@return aPos, Array, Array com a soma por demostrativos atualizado
	/*/
//---------------------------------------------------------------------
Function addDmDev(aPos as array ,cDmDev as character, nDmTafVal as numeric, cDmDevar as character, cDtPag as character, cPerRef as character, cEvento as character, cCateg as character )
	
	Local nI 		as numeric
	Local lFound 	as logical

	Default aPos 		:= {} 
	Default cDmDev 		:= ""
	Default nDmTafVal 	:= 0
	Default cDmDevar  	:= ""
	Default cCateg      := ""

	nI := 0
	lFound := .F.

	If Empty( apos )

		If cDmDevar == "cDmTafVal"
			AADD( aPos, { cDmDev, nDmTafVal, 0, 0, cDtPag, cPerRef, cEvento, cCateg } )
		ElseIf cDmDevar == "cDmRetVal"
			AADD( aPos, { cDmDev, 0, 0, nDmTafVal , cDtPag, cPerRef, cEvento, cCateg } )
		Else
			AADD( aPos, { cDmDev, 0, nDmTafVal, 0 , cDtPag, cPerRef, cEvento, cCateg } )
		EndIf

	Else
	
		For nI := 1 to Len( aPos )
				
			If Alltrim(aPos[nI][1]) == Alltrim(cDmDev)
				
				If cDmDevar == "cDmTafVal"

					aPos[nI][2] += nDmTafVal

				ElseIf cDmDevar == "cDmRetVal"

					aPos[nI][4] += nDmTafVal
					aPos[nI][5] := cDtPag
					aPos[nI][6] := cPerRef
					
				Else

					aPos[nI][3] += nDmTafVal

				EndIf
				
				lFound := .T.

				Exit
				
			EndIf
		Next nI

		If !lFound

			If cDmDevar == "cDmTafVal"
				AADD( aPos, { cDmDev, nDmTafVal, 0, 0, cDtPag, cPerRef, cEvento, cCateg } )
			ElseIf cDmDevar == "cDmRetVal"
				AADD( aPos, { cDmDev, 0, 0, nDmTafVal, cDtPag, cPerRef, cEvento, cCateg } )
			Else
				AADD( aPos, { cDmDev, 0, nDmTafVal, 0, cDtPag, cPerRef, cEvento, cCateg } )
			EndIf

		EndIf

	EndIf

Return aPos

//---------------------------------------------------------------------
/*/{Protheus.doc} HashLegacyIRFF
@type			method
@description	Método carregar o hash com valores do RH
@author			Alexandre de Lima / Fábio Mendonça
@since			19/07/2021
@return			lRet	-	Indica se o método aceitou a execução do processo
                cTicket -   Ticket de processamento
				oArqTrb - objeto de load do hash
/*/
//---------------------------------------------------------------------
Static Function HashLegacyIRFF( cTicket as character, oArqTrb as object , aCateg as array, nTaxableTrR as numeric, nOnTaxbleRrR as numeric,;
								nRetenTrR as numeric, nDeducTrR as numeric, nTaxSuspTrR as numeric, nRetSuspToR as numeric, nDedSusTrR as numeric,;
								nJudCompTrR as numeric, cTypeIRRF as Character, nVlIRRF as Numeric, cCrmen as Character, cLabel as Character) 

	Local aPos          as array
	Local cAliasV5H     as character
	Local aRubrRhValues as array

	Default aCateg 		 := {}
	Default nTaxableTrR  := 0
	Default nOnTaxbleRrR := 0
	Default nRetenTrR    := 0
	Default nDeducTrR    := 0
	Default nTaxSuspTrR  := 0
	Default nRetSuspToR  := 0
	Default nDedSusTrR   := 0
	Default nJudCompTrR  := 0
	Default cTypeIRRF    := ""
	Default nVlIRRF      := 0
	Default cCrMen       := ""
	Default cLabel       := ""

	aPos	:= {}
	aRubrRhValues := {}
	cAliasV5H := V5HByTicket(cTicket,,"3",aCateg)

	If !Empty(cAliasV5H)

		(cAliasV5H)->( dbGoTop() )

		While (cAliasV5H)->( !Eof() )

			aRubrRhValues := getRubrRhValues( IIf( TafColumnPos( "V5H_DETAIL" ), ( cAliasV5H )->V5H_DETAIL, Nil ) )

			If TAFXHMGet( oArqTrb, AllTrim((cAliasV5H)->V5H_CPF), @aPos )

				aPos[1][1] 	:= AllTrim((cAliasV5H)->V5H_CPF)
				aPos[1][2] 	:= AllTrim((cAliasV5H)->V5H_NOME)
				aPos[1][3] 	:= AllTrim(( cAliasV5H )->V5H_PERAPU )
				aPos[1][4] 	:= AllTrim((cAliasV5H)->V5H_CATEG )
				aPos[1][5] 	:= AllTrim(( cAliasV5H )->V5H_PERAPU )
				aPos[1][6] 	:= AllTrim(( cAliasV5H )->V5H_EVENTO	)
				aPos[1][7] 	:= AllTrim(( cAliasV5H )->V5H_DTPAG	)
				aPos[1][9]  := ( cAliasV5H )->V5H_VLTDMR
				aPos[1][10]	:= addDmDev( aPos[1][10], ( cAliasV5H )->V5H_DMDEV, ( cAliasV5H )->V5H_VLFGRE, "cDmErpVal", ( cAliasV5H )->V5H_DTPAG, ( cAliasV5H )->V5H_PERAPU, AllTrim( ( cAliasV5H )->V5H_EVENTO ), ( cAliasV5H )->V5H_CATEG	)		
				apos[1][13] := ( cAliasV5H )->V5H_TIRFC
				aPos[1][14]	:= typesIrrf( aPos[1][14], cTypeIRRF, nVlIRRF, "cDmErpVal", cCrmen, cLabel, ( cAliasV5H )->V5H_DMDEV, aRubrRhValues )
				aPos[1][23] +=  nTaxableTrR
				aPos[1][24] +=  nOnTaxbleRrR
				aPos[1][25] +=  nRetenTrR
				aPos[1][26] +=  nDeducTrR
				aPos[1][27] +=  nTaxSuspTrR
				aPos[1][28] +=  nRetSuspToR
				aPos[1][29] +=  nDedSusTrR
				aPos[1][30] +=  nJudCompTrR
						

				TAFXHMSet( oArqTrb, aPos[1][1], aPos )
			Else
				aPos := IRRFInitArray()

				aPos[1] 	:= AllTrim((cAliasV5H)->V5H_CPF)
				aPos[2] 	:= AllTrim((cAliasV5H)->V5H_NOME)
				aPos[3] 	:= AllTrim(( cAliasV5H )->V5H_PERAPU )
				aPos[4] 	:= AllTrim((cAliasV5H)->V5H_CATEG )
				aPos[5] 	:= AllTrim(( cAliasV5H )->V5H_PERAPU )
				aPos[6] 	:= AllTrim(( cAliasV5H )->V5H_EVENTO	)
				aPos[7] 	:= AllTrim(( cAliasV5H )->V5H_DTPAG	)
				aPos[9]     := ( cAliasV5H )->V5H_VLTDMR
				aPos[10]	:= addDmDev( aPos[10], ( cAliasV5H )->V5H_DMDEV, ( cAliasV5H )->V5H_VLFGRE, "cDmErpVal", ( cAliasV5H )->V5H_DTPAG, ( cAliasV5H )->V5H_PERAPU, AllTrim( ( cAliasV5H )->V5H_EVENTO ), ( cAliasV5H )->V5H_CATEG )		
				apos[13]    := ( cAliasV5H )->V5H_TIRFC
				aPos[14]	:= typesIrrf( aPos[14], cTypeIRRF, nVlIRRF, "cDmErpVal", cCrmen, cLabel, ( cAliasV5H )->V5H_DMDEV, aRubrRhValues )
				aPos[23] +=  nTaxableTrR
				aPos[24] +=  nOnTaxbleRrR
				aPos[25] +=  nRetenTrR
				aPos[26] +=  nDeducTrR
				aPos[27] +=  nTaxSuspTrR
				aPos[28] +=  nRetSuspToR
				aPos[29] +=  nDedSusTrR
				aPos[30] +=  nJudCompTrR

				TAFXHMAdd(oArqTrb, aPos, 1, 3)

			EndIf

			(cAliasV5H)->( dbSkip() )
		EndDo

	EndIf

	aPos := {}
	FreeObj(aPos)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} typesIrrf
	Função para somar o incidencias de IRRF
	@type  Function
	@author Alexandre de Lima / Fábio Mendonça
	@since 29/11/2023
	@version version

	@param aPos - array - [1][1] - cTipoIRRF
	                      [1][2] - Valor do taf
						  [1][3] - Valor do Erp
						  [1][4] - Valor do ret
						  [1][5] - Descrição do tipo do IRRF
	paramc cTipoIRRF as character 	- cTipoIRRF 
	paramc DmDev as character 	- cTipoIRRF
	paramn DmTafVal as numeric 	- Valor a ser somado 
	paramc DmDevar as character	- Variavel de controle para sabermos a qual coluna devemos somar
	
	paramc cCrmen as character, - Valor do campo V3N_CRMEN
	param  cLabel as character  - Descrição d codigo V3N_CRMEN
	@return aPos, Array, Array com a soma por demostrativos atualizado
	/*/
//---------------------------------------------------------------------
Function typesIrrf( aPos as array ,cTipoIRRF as character, nDmTafVal as numeric, cDmDevar as character, cCrmen as character, cLabel as Character, cDem as character, aRubrRhValues as array, cOrigem as character, cTpRubr as Character )
	
	Local nI 		as numeric
	Local nTamC6R	as numeric
	Local nk        as numeric	
	Local lFound 	as logical
   
	Default aPos 			:= {}
	Default aRubrRhValues 	:= {}
	Default cDmDev 			:= ""
	Default nDmTafVal 		:= 0
	Default cDmDevar  		:= ""
	Default cCateg      	:= ""
	Default cCrmen      	:= ""
	Default cLabel      	:= ""
	Default cDem        	:= ""
	Default cOrigem         := ""
	Default cTpRubr         := ""

	nTamC6R :=	TamSx3("C6R_CODIGO")[1]
	nI := 0
	nK := 0
	lFound := .F.


	If Empty( apos )

		If cDmDevar == "cDmTafVal"
			AADD( aPos, { alltrim(cTipoIRRF), cLabel, nDmTafVal, 0, 0, cDem  } )
		ElseIf cDmDevar == "cDmRetVal"
			AADD( aPos, { alltrim(cTipoIRRF), cLabel, 0, 0, nDmTafVal, cDem  } )
		Else
			AADD( aPos, { alltrim(cTipoIRRF), cLabel, 0, nDmTafVal, 0, cDem  } )
		EndIf

	Else

		For nI := 1 to Len( aPos )

			If Empty(aRubrRhValues)	
				
				If (Alltrim(aPos[nI][1]) == Alltrim(cTipoIRRF) .AND. Alltrim(aPos[nI][6]) == Alltrim(cDem)) .OR. (Alltrim(aPos[nI][1]) == Iif(Len(aRubrRhValues) > 0, Alltrim(aRubrRhValues[nI][1]), "") .AND. Alltrim(aPos[nI][6]) == Alltrim(cDem))
					
					If cDmDevar == "cDmTafVal"

						If aPos[nI][1] != "31"
							If cTpRubr $ '1|3'
								aPos[nI][3] += nDmTafVal
							else
								aPos[nI][3] -= nDmTafVal
							EndIf 
						Else
							If cTpRubr != "3"
								aPos[nI][3] += nDmTafVal
							Else
								aPos[nI][3] -= nDmTafVal
							EndIf
						EndIf

					ElseIf cDmDevar == "cDmRetVal"

						aPos[nI][5] += nDmTafVal
						
					Else

						aPos[nI][4] += nDmTafVal

					EndIf
					
					lFound := .T.

					Exit
					
				EndIf

			Else

				For nk := 1 to len(aRubrRhValues)
					If (Alltrim(aPos[nI][1]) == Alltrim(cTipoIRRF) .AND. Alltrim(aPos[nI][6]) == Alltrim(cDem)) .OR. (Alltrim(aPos[nI][1]) == Alltrim(aRubrRhValues[nk][1]) .AND. Alltrim(aPos[nI][6]) == Alltrim(cDem))
						
						aPos[nI][4] += aRubrRhValues[nk][4]
						lFound := .T.

						Exit
						
					EndIf
				Next nK
			EndIf

		Next nI

		If !lFound
		
			If cDmDevar == "cDmTafVal"
				AADD( aPos, { alltrim(cTipoIRRF), cLabel, nDmTafVal, 0, 0, cDem } )
			ElseIf cDmDevar == "cDmRetVal"
				AADD( aPos, { alltrim(cTipoIRRF), cLabel, 0, 0, nDmTafVal, cDem } )
			Else
				AADD( aPos, { alltrim(cTipoIRRF), cLabel, 0, nDmTafVal, 0, cDem } )
			EndIf

		EndIf

	EndIf

Return aPos

//---------------------------------------------------------------------
/*/{Protheus.doc} rAnalitico
	rAnalitico - Realiza o de para das ifromações por tipo de IRRF
	
	@type  Static Function
	@author Alexandre de lima santos
	@since 23/11/2023
	@version 1.0
	@param cIncidRRF - Tipo de incidencia do IRRF
	
	@Param nVlIRRF   - Valor que será somado para cada incidencia
	@param nTaxableTtt  - Total de Rendimentos tributáveis pelo taf
	@param nOnTaxbleTtt - Total de Rendimento não tributável ou isento do IRRF pelo taf
	@param nRetenTtt    - Total de Retenções do IRRF pelo tafa
	@param nDeducTtt    - Total de Deduções da base de cálculo do IRRF pelo taf 
	@param nTaxSuspTtt  - Total de Exigibilidade suspensa - Rendimento tributável pelo taf
	@param nRetSuspTtt  - Total de Exigibilidade suspensa - Retenção do IRRF pelo taf 
	@param nDedSusTtt   - Total de Exigibilidade suspensa - Dedução da base de cálculo do IRRF  pelo taf
	@param nJudCompTtt  - Total de Compensação judicial pelo taf 
	@param cOrigem      - Origem do da informação para se extrair os valores 4- Se refere a S-1210 trasnmitido, 2 - eventos como S-1200, S-2299 ou S-2399
	@param nTaxableTrR  - Total de Rendimentos tributáveis pelo ret
	@param nOnTaxbleRrR - Total de Rendimento não tributável ou isento do IRRF pelo ret
	@param nRetenTrR    - Total de Retenções do IRRF pelo ret
	@param nDeducTrR    - Total de Deduções da base de cálculo do IRRF pelo ret
	@param nTaxSuspTrR  - Total de Exigibilidade suspensa - Rendimento tributável pelo ret
	@param nRetSuspToR  - Total de Exigibilidade suspensa - Retenção do IRRF pelo ret
	@param nDedSusTrR   - Total de Total de Exigibilidade suspensa - Dedução da base de cálculo do IRRF  pelo ret
	@param nJudCompTrR  - Total de Compensação judicial pelo ret 
	@param cLabel    - Tipo de incidencia que será retornada ao front

	@return 
	/*/
//---------------------------------------------------------------------
Function rAnalitico( cIncidRRF as Character, nVlIRRF as Numeric, nTaxableTtt as Numeric, nOnTaxbleTtt as Numeric, nRetenTtt as Numeric, nDeducTtt as Numeric, nTaxSuspTtt as Numeric, nRetSuspTtt as Numeric, nDedSusTtt as Numeric, nJudCompTtt as Numeric, cOrigem as character,;
                   nTaxableTrR as numeric, nOnTaxbleRrR as numeric, nRetenTrR as numeric, nDeducTrR as numeric ,nTaxSuspTrR as numeric, nRetSuspToR as numeric, nDedSusTrR as numeric, nJudCompTrR as numeric, cLabel as Character, cTipo as character)
	
	Default  cTipo          := ""
	Default  cIncidRRF 	 	:= ""
	Default  cLabel         := ""
	Default  nVlIRRF 	 	:= 0
	Default  nTaxableTtt 	:= 0
	Default  nOnTaxbleTtt 	:= 0
	Default  nRetenTtt 		:= 0
	Default  nDeducTtt 		:= 0
	Default  nTaxSuspTtt 	:= 0
	Default  nRetSuspTtt 	:= 0
	Default  nDedSusTtt 	:= 0 
	Default  nJudCompTtt 	:= 0
	Default  cIncidRRF 	 	:= ""
	Default  nTaxableTrR 	:= 0
	Default  nOnTaxbleRrR 	:= 0
	Default  nRetenTrR 		:= 0
	Default  nDeducTrR 		:= 0
	Default  nTaxSuspTrR 	:= 0
	Default  nRetSuspToR 	:= 0
	Default  nDedSusTrR 	:= 0 
	Default  nJudCompTrR 	:= 0

	If cIncidRRF $ "11|12|14"
       
		If cIncidRRF == "11"
			cLabel := "Remuneração mensal"
		ElseIf cIncidRRF == "12"
			cLabel := "13º salário"
		ElseIf cIncidRRF == '14'
			cLabel := "PLR"
		EndIf 
	    
		If cOrigem == '2'
			
			If cTipo $ '1|3'
				nTaxableTtt += nVlIRRF
			Else 
				nTaxableTtt -= nVlIRRF 
			EndIf

		ElseIf cOrigem == '4'
			nTaxableTrR += nVlIRRF 
		EndIf

		Return

	ElseIf cIncidRRF $ "70|71|72|73|74|75|76|77|700|701|702|703|704|79|7900"
		
		If cIncidRRF == "70"
			cLabel := "Parcela isenta 65 anos - Remuneração mensal"
		ElseIf cIncidRRF == "71"
			cLabel := "Parcela isenta 65 anos - 13º salário"
		ElseIf cIncidRRF == "72"
			cLabel := "Diárias"
		ElseIf cIncidRRF == "73"
			cLabel := "Ajuda de custo"
		ElseIf cIncidRRF == "74"
		    cLabel := "Indenização e rescisão de contrato, inclusive a título de PDV e acidentes de trabalho"
		ElseIf cIncidRRF == "75"
		    cLabel := "Abono pecuniário"
		ElseIf cIncidRRF == "76"
		    cLabel := "Rendimento de beneficiário com moléstia grave ou acidente em serviço - Remuneração mensal"
		ElseIf cIncidRRF == "77"
			cLabel := "Rendimento de beneficiário com moléstia grave ou acidente em serviço - 13º salário"
		ElseIf cIncidRRF == "700"
		    cLabel := "Auxílio moradia"
		ElseIf cIncidRRF == "701"
		    cLabel := "Parte não tributável do valor de serviço de transporte de passageiros ou cargas"
		ElseIf cIncidRRF == "702"
			cLabel := "Bolsa médico residente - remuneração mensal"
		ElseIf cIncidRRF == "703"
			cLabel := "Bolsa médico residente - 13º salário"
		ElseIf cIncidRRF == "704"
			cLabel := "Juros de mora recebidos, devidos pelo atraso no pagamento de remuneração por exercício de emprego, cargo ou função"			
		ElseIf cIncidRRF == "79"
			cLabel := "Outras isenções"
		ElseIf cIncidRRF $ "7900"
			cLabel := "Verba transitada pela folha de pagamento de natureza diversa de rendimento ou retenção/isenção/dedução de IR (exemplo: desconto de convênio farmácia, desconto de consignações, etc.)"
		EndIf 

		If cOrigem == '2'

			If cTipo $ '1|3'
				nOnTaxbleTtt += nVlIRRF
			Else
				nOnTaxbleTtt += nVlIRRF
			EndIf

		ElseIf cOrigem == '4'
			nOnTaxbleRrR += nVlIRRF 
		EndIf

		Return

	ElseIf cIncidRRF $ "31|32|34"

		If cIncidRRF == "31"
			cLabel := "Remuneração mensal"
		ElseIf cIncidRRF == "32"
			cLabel := "13º salário"
		ElseIf cIncidRRF == "34"
			cLabel := "PLR"
		EndIf
		
		If cOrigem == '2'
			
			If cTipo $ '2|4'
				nRetenTtt += nVlIRRF
			Else
			    nRetenTtt -= nVlIRRF
			EndIf

		ElseIf cOrigem == '4'
			nRetenTrR += nVlIRRF
		EndIf

		Return

	ElseIf cIncidRRF $ "41|42|46|47|51|52|54|61|62|63|64|67|68"
		
		If cIncidRRF == "41"
			cLabel := "Previdência Social Oficial - PSO - Remuneração mensal"
		ElseIf cIncidRRF == "42"
			cLabel := "PSO - 13º salário"
		ElseIf cIncidRRF == "46"
			cLabel := "Previdência complementar - Salário mensal"
		ElseIf cIncidRRF == "47"
			cLabel := "Previdência complementar - 13º salário"
		ElseIf cIncidRRF == "51"
		    cLabel := "Pensão alimentícia - Remuneração mensal"
		ElseIf cIncidRRF == "52"
		    cLabel := "Pensão alimentícia - 13º salário"
		ElseIf cIncidRRF == "54"
		    cLabel := "Pensão alimentícia - PLR"
		ElseIf cIncidRRF == "61"
			cLabel := "Fundo de Aposentadoria Programada Individual - FAPI - Remuneração mensal"
		ElseIf cIncidRRF == "62"
		    cLabel := "Fundo de Aposentadoria Programada Individual - FAPI - 13º salário"
		ElseIf cIncidRRF == "63"
		    cLabel := "Fundação de previdência complementar do servidor público - Remuneração mensal"
		ElseIf cIncidRRF == "64"
		    cLabel := "Fundação de previdência complementar do servidor público - 13º salário"
		ElseIf cIncidRRF == "67"
		    cLabel := "Plano privado coletivo de assistência à saúde"
		ElseIf cIncidRRF == "68"
		    cLabel := "Desconto simplificado mensal"
		EndIf

		If cOrigem == '2'

			If cTipo $ '2|4'
				nDeducTtt += nVlIRRF
			Else
				nDeducTtt -= nVlIRRF
			EndIf

		ElseIf cOrigem == '4'
		    nDeducTrR += nVlIRRF 
		EndIf

		Return

	ElseIf cIncidRRF $ "9011|9012|9014"
		
		If cIncidRRF == "9011"
			cLabel := "Remuneração mensal"
		ElseIf cIncidRRF == "9012"
			cLabel := "13º salário"
		ElseIf cIncidRRF == "9014"
			cLabel := "PLR"
		EndIf

		If cOrigem == '2'
			
			If cTipo $ '2|4'
				nTaxSuspTtt += nVlIRRF
			Else
				nTaxSuspTtt -= nVlIRRF
			EndIf

		ElseIf cOrigem == '4'
			nTaxSuspTrR += nVlIRRF
		EndIf

		Return

	ElseIf cIncidRRF $ "9031|9032|9034|9831|9832|9834"
		
		If cIncidRRF == "9031"
			cLabel := "Remuneração mensal"
		ElseIf cIncidRRF == "9032"
			cLabel := "13º salário"
		ElseIf cIncidRRF == "9034"
			cLabel := "PLR"
		ElseIf cIncidRRF == "9831"
			cLabel := "Depósito judicial - Mensal"
		ElseIf cIncidRRF == "9832"
		    cLabel := "Depósito judicial - 13º salário"
		ElseIf cIncidRRF == "9834"
		    cLabel := "Depósito judicial - PLR"	
		EndIf

		If cOrigem == '2'
			
			If cTipo $ '2|4'
				nRetSuspTtt += nVlIRRF 
			Else
				nRetSuspTtt -= nVlIRRF 
			EndIf

		ElseIf cOrigem == '4'
			nRetSuspToR += nVlIRRF 
		EndIf

		Return

	ElseIf cIncidRRF $ "9041|9042|9046|9047|9051|9052|9054|9061|9062|9063|9064|9067"
		
		If cIncidRRF == "9041"
			cLabel := "Previdência Social Oficial - PSO - Remuneração mensal"
		ElseIf cIncidRRF == "9042"
			cLabel := "PSO - 13º salário"
		ElseIf cIncidRRF == "9046"
			cLabel := "Previdência complementar - Salário mensal"
		ElseIf cIncidRRF == "9047"
			cLabel := "Previdência complementar - 13º salário"
		ElseIf cIncidRRF == "9051"
		    cLabel := "Pensão alimentícia - Remuneração mensal"
		ElseIf cIncidRRF == "9052"
			cLabel := "Pensão alimentícia - 13º salário"
		ElseIf cIncidRRF == "9054"
			cLabel := "Pensão alimentícia - PLR"
		ElseIf cIncidRRF == "9061"
			cLabel := "Fundo de Aposentadoria Programada Individual - FAPI - Remuneração mensal"
		ElseIf cIncidRRF == "9062"
			cLabel := "Fundo de Aposentadoria Programada Individual - FAPI - 13º salário"
		ElseIf cIncidRRF == "9063"
			cLabel := "Fundação de previdência complementar do servidor público - Remuneração mensal"
		ElseIf cIncidRRF == "9064"
			cLabel := "Fundação de previdência complementar do servidor público - 13º salário"
		ElseIf cIncidRRF == "9067"
		    cLabel := "Plano privado coletivo de assistência à saúde"	
		EndIf

		If cOrigem == '2'
		    
			If cTipo $ '2|4'
				nDedSusTtt += nVlIRRF 
			Else
				nDedSusTtt -= nVlIRRF
			EndIf

		ElseIf cOrigem == '4'
			nDedSusTtt += nVlIRRF
		EndIf

		Return

	ElseIf cIncidRRF $ "9082|9083"
		
		If cIncidRRF == "9082"
			cLabel := "Compensação judicial do ano-calendário"
		ElseIf cIncidRRF == "9083"
			cLabel := "Compensação judicial de anos anteriores"
		EndIf

		If cOrigem == '2'
			If cTipo $ '2|4'
				nJudCompTtt += nVlIRRF 
			Else
			    nJudCompTtt -= nVlIRRF
			EndIf
		ElseIf cOrigem == '4'
		    nJudCompTrR += nVlIRRF
		EndIf

		Return
	Else
	    
	 	nVlIRRF := nVlIRRF

	EndIf
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} getRubrRhValues
	Extrai Valores Analíticos do objeto <typesIrrfValues> das rubricas obtidas das linhas
	
	@type  Static Function
	@author Fábio Mendonça/ alexandre lima 
	@since 23/11/2023
	@version 1.0
	@param cRubrRhValues, Character, String Json com valores analíticos das rubricas oriundas das linhas
	@return aRet, Array, Vetor com dados de rubricas analíticas, no formato:
						 [1] - type
						 [2] - descriptionType
						 [3] - tafValue 
						 [4] - erpValue
						 [5] - retValue
/*/
//---------------------------------------------------------------------
Static Function getRubrRhValues( cRubrRhValues as Character ) as Array

	Local nI				as Numeric
	Local nX				as Numeric
	Local aRet 				as Array
	Local aTypesIrrfValues 	as Array
	Local oRubrRhValues		as Json

	Default cRubrRhValues := ""

	oRubrRhValues := JsonObject():New()
	oRubrRhValues:FromJson( cRubrRhValues )
	aTypesIrrfValues 	:= oRubrRhValues:getNames()
	aRet 				:= {}

	For nI := 1 To Len( aTypesIrrfValues )

		For nX := 1 To Len( oRubrRhValues[ aTypesIrrfValues[ nI ] ][ 'items' ] )

			aAdd( aRet, {	oRubrRhValues[ aTypesIrrfValues[ nI ] ][ 'items' ][ nX ][ 'type' 			],;
							oRubrRhValues[ aTypesIrrfValues[ nI ] ][ 'items' ][ nX ][ 'descriptionType' ],;
							oRubrRhValues[ aTypesIrrfValues[ nI ] ][ 'items' ][ nX ][ 'tafValue' 		],;
							oRubrRhValues[ aTypesIrrfValues[ nI ] ][ 'items' ][ nX ][ 'erpValue' 		],;
							oRubrRhValues[ aTypesIrrfValues[ nI ] ][ 'items' ][ nX ][ 'retValue' 		] } )
		
		Next nX

	Next nI
	
Return aRet

//---------------------------------------------------------------------
/*/{Protheus.doc} GerLevel
	(long_description)
	@type  Function
	@author alexandre de lima santos
	@since 07/12/2023
	@version version
	@param oResponse, object, objeto json a ser retonado ao front
/*/
//---------------------------------------------------------------------
Function GerLevel(oResponse)
	
	Local lFound     as logical
    Local nCount     as numeric
	Local nDedSusERP as numeric
	Local nDedSusRET as numeric
	Local nDedSusTAF as numeric
	Local nDetERP    as numeric
	Local nDetRET    as numeric
	Local nDetSupERP as numeric
	Local nDetSupRET as numeric
	Local nDetSupTAF as numeric
	Local nDetTAF    as numeric
	Local nErpIncome as numeric
	Local nInc1E     as numeric
	Local nInc1R     as numeric
	Local nInc1T     as numeric
	Local nInc2E     as numeric
	Local nInc2R     as numeric
	Local nInc2T     as numeric
	Local nInc3E     as numeric
	Local nInc3R     as numeric
	Local nInc3T     as numeric
	Local nInc4E     as numeric
	Local nInc4R     as numeric
	Local nInc4T     as numeric
	Local nInc5E     as numeric
	Local nInc5R     as numeric
	Local nInc5T     as numeric
	Local nInc6E     as numeric
	Local nInc6R     as numeric
	Local nInc6T     as numeric
	Local nInc7E     as numeric
	Local nInc7R     as numeric
	Local nInc7T     as numeric
	Local nInc8E     as numeric
	Local nInc8R     as numeric
	Local nInc8T     as numeric
	Local nJudComERP as numeric
	Local nJudComRET as numeric
	Local nJudComTAF as numeric
	Local nK         as numeric
	Local nRetERP    as numeric
	Local nRetIncome as numeric
	Local nRetRET    as numeric
	Local nRetSupERP as numeric
	Local nRetSupRET as numeric
	Local nRetSupTAF as numeric
	Local nRetTAF    as numeric
	Local nTafIncome as numeric
	Local nTaxaERP   as numeric
	Local nTaxaret   as numeric
	Local nTaxaTAF   as numeric
	Local nX         as numeric
	Local nY         as numeric
	Local nW         as numeric

	lFound     := .F.
	nCount     := 0
	nDedSusERP := 0
	nDedSusRET := 0
	nDedSusTAF := 0
	nDetERP    := 0
	nDetRET    := 0
	nDetSupERP := 0
	nDetSupRET := 0
	nDetSupTAF := 0
	nDetTAF    := 0
	nErpIncome := 0
	nInc1E     := 0
	nInc1R     := 0
	nInc1T     := 0
	nInc2E     := 0
	nInc2R     := 0
	nInc2T     := 0
	nInc3E     := 0
	nInc3R     := 0
	nInc3T     := 0
	nInc4E     := 0
	nInc4R     := 0
	nInc4T     := 0
	nInc5E     := 0
	nInc5R     := 0
	nInc5T     := 0
	nInc6E     := 0
	nInc6R     := 0
	nInc6T     := 0
	nInc7E     := 0
	nInc7R     := 0
	nInc7T     := 0
	nInc8E     := 0
	nInc8R     := 0
	nInc8T     := 0
	nJudComERP := 0
	nJudComRET := 0
	nJudComTAF := 0
	nK         := 0
	nRetERP    := 0
	nRetIncome := 0
	nRetRET    := 0
	nRetSupERP := 0
	nRetSupRET := 0
	nRetSupTAF := 0
	nRetTAF    := 0
	nTafIncome := 0
	nTaxaERP   := 0
	nTaxaret   := 0
	nTaxaTAF   := 0
	nX         := 0
	nY         := 0
	nW         := 0

	Default oResponse := Nil

	For nX := 1 to Len( oResponse["demonstrative"])
		
		If !oResponse:hasProperty("totalDemonstratives")

			oResponse["totalDemonstratives"] 					:= JsonObject():New()                                                                                                                                                                           
			oResponse["totalDemonstratives"]["demonstrative"] 	:= {}
		    oResponse["totalDemonstratives"]["typesIrrfValues"] := JsonObject():New()

		EndIf
		
		aAdd(oResponse["totalDemonstratives"]["demonstrative"],oResponse["demonstrative"][nX]["demonstrativeId"])

		If oResponse["demonstrative"][nX]["typesIrrfValues"]:hasProperty("taxableIncome")
			
			nCount := 0
			
			If !oResponse["totalDemonstratives"]["typesIrrfValues"]:hasProperty("taxableIncome")

				oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]          := JsonObject():New()
				oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"] := {}	

			EndIf
				
			For nY := 1 to Len( oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"] )

				If Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"] ) >= 1

					nW := 0

					For nK := 1 to Len( oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"])

						nW++

						If oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nK]["type"] ==  oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["type"] 
							
							nInc1T := oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nK]["tafValue"]    
							nInc1E := oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nK]["erpValue"]    
							nInc1R := oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nK]["retValue"]      		 
							lFound := .T.

							exit

						EndIf

					Next
		
				EndIf

				nTafIncome  += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["tafValue"]
				nErpIncome  += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["erpValue"]
				nRetIncome  += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["retValue"]
				
				If !lFound

					aAdd(oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"], JsonObject():New())	
					nCount := Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"])
					
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nCount]["type"]             := oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["type"]
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nCount]["descriptionType"]  := oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["descriptionType"]
					
					nInc1T := oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["tafValue"]
					nInc1E := oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["erpValue"]
					nInc1R := oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["retValue"]
					
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nCount]["tafValue"] := nInc1T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nCount]["erpValue"] := nInc1E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nCount]["retValue"] := nInc1R

				Else

					nInc1T += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["tafValue"]
					nInc1E += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["erpValue"]
					nInc1R += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncome"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nW]["tafValue"]    := nInc1T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nW]["erpValue"]    := nInc1E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["items"][nW]["retValue"]    := nInc1R
				
				EndIf

			Next nY

			If !oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]:hasProperty("total")
				oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["total"] := JsonObject():New()
			EndIf

			oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["total"]["tafValue"] := nTafIncome
			oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["total"]["erpValue"] := nErpIncome
			oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncome"]["total"]["retValue"] := nRetIncome

            lFound := .F.

		EndIf

		If oResponse["demonstrative"][nX]["typesIrrfValues"]:hasProperty("nonTaxableIncome")
			
			nCount := 0

			If !oResponse["totalDemonstratives"]["typesIrrfValues"]:hasProperty("nonTaxableIncome")

				oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"] 		 := JsonObject():New()
				oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"] := {}	

			EndIf
			
			For nY := 1 to Len( oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"] )

				If Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"] ) >= 1

					nW := 0

					For nK := 1 to Len( oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"]) 

						nW++
						
						If oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nK]["type"] ==  oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["type"]  
							
							nInc2T := oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nK]["tafValue"]    
							nInc2E := oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nK]["erpValue"]    
							nInc2R := oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nK]["retValue"]     		 
							lFound := .T.

							exit

						EndIf

					Next
		
				EndIf

				nTaxaTAF += oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["tafValue"]
				nTaxaERP += oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["erpValue"]
				nTaxaRET += oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["retValue"]
				
				If !lFound

					aAdd(oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"], JsonObject():New())	
					nCount := Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"])
					
					oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nCount]["type"]             := oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["type"]
					oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nCount]["descriptionType"]  := oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["descriptionType"] 

					nInc2T := oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["tafValue"]
					nInc2E := oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["erpValue"]
					nInc2R := oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nCount]["tafValue"] 		 := nInc2T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nCount]["erpValue"]         := nInc2E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nCount]["retValue"]         := nInc2R

				Else

					nInc2T += oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["tafValue"]
					nInc2E += oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["erpValue"]
					nInc2R += oResponse["demonstrative"][nX]["typesIrrfValues"]["nonTaxableIncome"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nW]["tafValue"]    := nInc2T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nW]["erpValue"]    := nInc2E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["items"][nW]["retValue"]    := nInc2R

				EndIf

			Next nY

			If !oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]:hasProperty("total")
				oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["total"]:= JsonObject():New()
			EndIf

			oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["total"]["tafValue"] := nTaxaTAF
			oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["total"]["erpValue"] := nTaxaERP
			oResponse["totalDemonstratives"]["typesIrrfValues"]["nonTaxableIncome"]["total"]["retValue"] := nTaxaRET

			lFound := .F. 

		EndIf

		If oResponse["demonstrative"][nX]["typesIrrfValues"]:hasProperty("retention")
			
			nCount := 0

			If !oResponse["totalDemonstratives"]["typesIrrfValues"]:hasProperty("retention")

				oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]          := JsonObject():New()      	  
				oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"] := {}	

			EndIf	

			For nY := 1 to Len( oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"] )

				If Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"] ) >= 1

					nW := 0

					For nK := 1 to Len( oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"])

						nW++

						If oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nK]["type"] ==  oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["type"]   	
							
							nInc3T := oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nK]["tafValue"]             
							nInc3E := oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nK]["erpValue"]             
					        nInc3R := oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nK]["retValue"]             	 
							lFound := .T.

							exit

						EndIf

					Next
		
				EndIf

				nRetTAF += oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["tafValue"]
				nRetERP += oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["erpValue"]
				nRetRET += oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["retValue"]
				
				If !lFound
					aAdd(oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"], JsonObject():New())	
					nCount := Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"])
					
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nCount]["type"]             := oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["type"]
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nCount]["descriptionType"]  := oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["descriptionType"] 
					
					nInc3T := oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["tafValue"]
					nInc3E := oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["erpValue"]
					nInc3R := oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nCount]["tafValue"] 		  := nInc3T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nCount]["erpValue"]         := nInc3E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nCount]["retValue"]         := nInc3R
				Else

					nInc3T += oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["tafValue"]
					nInc3E += oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["erpValue"]
					nInc3R += oResponse["demonstrative"][nX]["typesIrrfValues"]["retention"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nW]["tafValue"]             := nInc3T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nW]["erpValue"]             := nInc3E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["items"][nW]["retValue"]             := nInc3R
				EndIf

			Next nY

			If !oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]:hasProperty("total")
				oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["total"] := JsonObject():New()
			EndIf

			oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["total"]["tafValue"] := nRetTAF
			oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["total"]["erpValue"] := nRetERP
			oResponse["totalDemonstratives"]["typesIrrfValues"]["retention"]["total"]["retValue"] := nRetRET
            
			lFound := .F.

		EndIf

		If oResponse["demonstrative"][nX]["typesIrrfValues"]:hasProperty("deductions")
			
			nCount := 0
			
			If !oResponse["totalDemonstratives"]["typesIrrfValues"]:hasProperty("deductions")

				oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]          := JsonObject():New()
				oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"] := {}

			EndIf	
			
			For nY := 1 to Len( oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"] )

				If Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"] ) >= 1

					nW := 0

					For nK := 1 to Len( oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"]) 

						nW++

						If oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nK]["type"] ==  oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["type"]   
							
							nInc4T := oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nK]["tafValue"]             
							nInc4E := oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nK]["erpValue"]             
							nInc4R := oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nK]["retValue"]             		 
							lFound := .T.

							exit

						EndIf

					Next
		
				EndIf

				nDetTAF += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["tafValue"]
				nDetERP += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["erpValue"]
				nDetRET += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["retValue"]
				
				If !lFound

					aAdd(oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"], JsonObject():New())	
					nCount := Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"])
					
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nCount]["type"]             := oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["type"]
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nCount]["descriptionType"]  := oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["descriptionType"] 
					
					nInc4T := oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["tafValue"]
					nInc4E := oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["erpValue"]
					nInc4R := oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nCount]["tafValue"] 		   := nInc4T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nCount]["erpValue"]         := nInc4E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nCount]["retValue"]         := nInc4R

				Else

					nInc4T += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["tafValue"]
					nInc4E += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["erpValue"]
					nInc4R += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductions"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nW]["tafValue"]             := nInc4T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nW]["erpValue"]             := nInc4E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["items"][nW]["retValue"]             := nInc4R

				EndIf

			Next nY

			If !oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]:hasProperty("total")
				oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["total"] := JsonObject():New()
			EndIf

			oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["total"]["tafValue"] := nDetTAF
			oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["total"]["erpValue"] := nDetERP
			oResponse["totalDemonstratives"]["typesIrrfValues"]["deductions"]["total"]["retValue"] := nDetRET

            lFound := .F.

		EndIf

		If oResponse["demonstrative"][nX]["typesIrrfValues"]:hasProperty("taxableIncomeSuspended")
			
			nCount := 0
			
			If !oResponse["totalDemonstratives"]["typesIrrfValues"]:hasProperty("taxableIncomeSuspended")

				oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]          := JsonObject():New()
				oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"] := {}

			EndIf	
			
			For nY := 1 to Len( oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"] )

				If Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"] ) >= 1

					nW := 0

					For nK := 1 to Len( oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"]) 

						nW++

						If oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nK]["type"] ==  oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["type"]   		 
							
							nInc5T := oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nK]["tafValue"]             
							nInc5E := oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nK]["erpValue"]             
							nInc5R := oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nK]["retValue"]             
							lFound := .T.

							exit

						EndIf

					Next
		
				EndIf

				nDetSupTAF += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["tafValue"]
				nDetSupERP += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["erpValue"]
				nDetSupRET += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["retValue"]
				
				If !lFound

					aAdd(oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"], JsonObject():New())	
					nCount := Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"])
					
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nCount]["type"]             := oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["type"]
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nCount]["descriptionType"]  := oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["descriptionType"] 
					
					nInc5T := oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["tafValue"]
					nInc5E := oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["erpValue"]
					nInc5R := oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nCount]["tafValue"] 		   := nInc5T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nCount]["erpValue"]         := nInc5E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nCount]["retValue"]         := nInc5R

				Else

					nInc5T += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["tafValue"]
					nInc5E += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["erpValue"]
					nInc5R += oResponse["demonstrative"][nX]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nW]["tafValue"]             := nInc5T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nW]["erpValue"]             := nInc5E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["items"][nW]["retValue"]             := nInc5R
			
				EndIf

			Next nY

			If !oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]:hasProperty("total")
				oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["total"] := JsonObject():New()
			EndIf

			oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["total"]["tafValue"] := nDetSupTAF
			oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["total"]["erpValue"] := nDetSupERP
			oResponse["totalDemonstratives"]["typesIrrfValues"]["taxableIncomeSuspended"]["total"]["retValue"] := nDetSupRET
           
		    lFound := .F.

		EndIf

		If oResponse["demonstrative"][nX]["typesIrrfValues"]:hasProperty("retentionSuspended")
			
			nCount := 0
			
			If !oResponse["totalDemonstratives"]["typesIrrfValues"]:hasProperty("retentionSuspended")

				oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]          := JsonObject():New()
				oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"] := {}

			EndIf	
			
			For nY := 1 to Len( oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"] )

				If Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"] ) >= 1

					nW := 0

					For nK := 1 to Len( oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"]) 

						nW++

						If oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nK]["type"] ==  oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["type"]   		 
							
							nInc6T := oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nK]["tafValue"]            
							nInc6E := oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nK]["erpValue"]             
							nInc6R := oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nK]["retValue"]             
							lFound := .T.

							exit

						EndIf

					Next
		
				EndIf

				nRetSupTAF += oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["tafValue"]
				nRetSupERP += oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["erpValue"]
				nRetSupRET += oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["retValue"]
				
				If !lFound

					aAdd(oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"], JsonObject():New())	
					nCount := Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"])
					
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nCount]["type"]             := oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["type"]
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nCount]["descriptionType"]  := oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["descriptionType"] 
					
					nInc6T := oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["tafValue"]
					nInc6E := oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["erpValue"]
					nInc6R := oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nCount]["tafValue"] 		   := nInc6T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nCount]["erpValue"]         := nInc6E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nCount]["retValue"]         := nInc6R

				Else

					nInc6T += oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["tafValue"]
					nInc6E += oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["erpValue"]
					nInc6R += oResponse["demonstrative"][nX]["typesIrrfValues"]["retentionSuspended"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nW]["tafValue"]             := nInc6T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nW]["erpValue"]             := nInc6E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["items"][nW]["retValue"]             := nInc6R

				EndIf

			Next nY

			If !oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]:hasProperty("total")
				oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["total"] := JsonObject():New()
			EndIf
			
			oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["total"]["tafValue"] := nRetSupTAF
			oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["total"]["erpValue"] := nRetSupERP
			oResponse["totalDemonstratives"]["typesIrrfValues"]["retentionSuspended"]["total"]["retValue"] := nRetSupRET

            lFound := .F.

		EndIf
		
		If oResponse["demonstrative"][nX]["typesIrrfValues"]:hasProperty("deductionsSuspended")
			
			nCount := 0
			
			If !oResponse["totalDemonstratives"]["typesIrrfValues"]:hasProperty("deductionsSuspended")

				oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]          := JsonObject():New()
				oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"] := {}	

			EndIf
			
			For nY := 1 to Len( oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"] )

				If Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"] ) >= 1

					nW := 0

					For nK := 1 to Len( oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"])

						nW++

						If oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nK]["type"] !=  oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["type"]   		 
							
							nInc7T := oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nK]["tafValue"]    
							nInc7E := oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nK]["erpValue"]    
							nInc7R := oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nK]["retValue"]    
							lFound := .T.

							exit

						EndIf

					Next
		
				EndIf

				nDedSusTAF += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["tafValue"]
				nDedSusERP += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["erpValue"]
				nDedSusRET += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["retValue"]
				
				If !lFound

					aAdd(oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"], JsonObject():New())	
					nCount := Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"])
					
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nCount]["type"]             := oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["type"]
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nCount]["descriptionType"]  := oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["descriptionType"] 
					
					nInc7T := oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["tafValue"]
					nInc7E := oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["erpValue"]
					nInc7R := oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nCount]["tafValue"] 		:= nInc7T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nCount]["erpValue"]         := nInc7E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nCount]["retValue"]         := nInc7R

				Else

					nInc7T += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["tafValue"]
					nInc7E += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["erpValue"]
					nInc7R += oResponse["demonstrative"][nX]["typesIrrfValues"]["deductionsSuspended"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nW]["tafValue"]    := nInc7T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nW]["erpValue"]    := nInc7E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["items"][nW]["retValue"]    := nInc7R

				EndIf

			Next nY
			
			If !oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]:hasProperty("total")
				oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["total"] := JsonObject():New()
			EndIf

			oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["total"]["tafValue"] := nDedSusTAF
			oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["total"]["erpValue"] := nDedSusERP
			oResponse["totalDemonstratives"]["typesIrrfValues"]["deductionsSuspended"]["total"]["retValue"] := nDedSusRET

            lFound := .F.

		EndIf

		If oResponse["demonstrative"][nX]["typesIrrfValues"]:hasProperty("judicialCompensation")
			
			nCount := 0

			If !oResponse["totalDemonstratives"]["typesIrrfValues"]:hasProperty("judicialCompensation")	

				oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]          := JsonObject():New()	
				oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"] := {}	

			EndIf

			For nY := 1 to Len( oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"] )

				If Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"] ) >= 1

					nW := 0

					For nK := 1 to Len( oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"]) 

						nW++

						If oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nK]["type"] ==  oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["type"]   
							
							nInc8T := oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nK]["tafValue"]    
							nInc8E := oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nK]["erpValue"]  
							nInc8R := oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nK]["retValue"]    	 
							lFound := .T.

							exit

						EndIf

					Next
		
				EndIf

				nJudComTAF += oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["tafValue"]
				nJudComERP += oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["erpValue"]
				nJudComRET += oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["retValue"]
				
				If !lFound

					aAdd(oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"], JsonObject():New())	
					nCount := Len(oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"])
					
					oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nCount]["type"]             := oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["type"]
					oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nCount]["descriptionType"]  := oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["descriptionType"] 
					
					nInc8T := oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["tafValue"]
					nInc8E := oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["erpValue"]
					nInc8R := oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nCount]["tafValue"] 		 := nInc8T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nCount]["erpValue"]         := nInc8E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nCount]["retValue"]         := nInc8R

				Else

					nInc8T += oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["tafValue"]
					nInc8E += oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["erpValue"]
					nInc8R += oResponse["demonstrative"][nX]["typesIrrfValues"]["judicialCompensation"]["items"][nY]["retValue"]

					oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nW]["tafValue"]    := nInc8T
					oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nW]["erpValue"]    := nInc8E
					oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["items"][nW]["retValue"]    := nInc8R

				EndIf

			Next nY

			If !oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]:hasProperty("total")
				oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["total"] := JsonObject():New()
			EndIf

			oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["total"]["tafValue"] := nJudComTAF
			oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["total"]["erpValue"] := nJudComERP
			oResponse["totalDemonstratives"]["typesIrrfValues"]["judicialCompensation"]["total"]["retValue"] := nJudComRET

            lFound := .F.

		EndIf

	Next nX

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} TafWarning
	(long_description)
	@type  Function
	@author Alexandre de lima santos
	@since 22/12/2023
	@version version
	@param aWarnig, array, Array com os valores da rubricas coletadas no relatorio
	@param lIsLegacy , logical, Se na comparação dos valores devem ser comparados os valores de rh.
	@return lWar , logical, Caso tenha divergencias nos valores das rubricas o valor sera true
	@example
	(examples)
	@see (links_or_references)
/*/
//---------------------------------------------------------------------
Function TafWarning(aWarnig as array, lIsLegacy as logical)
	
	Local lWar 		as logical
	Local nX   		as numeric
    Local nPosit    as numeric

	Default aWarning := {}

	lWar := .F.
	nX   := 0
	nPosit := 0
   
	For nX := 1 to Len(aWarnig)
		
		If Alltrim(aWarnig[nX][1]) $ "70|71|72|73|74|75|76|77|700|701|702|703|704|79|7900" .AND. aWarnig[nX][5] < 0 .AND. !Alltrim(aWarnig[nX][1]) $ "00|7950"
			nPosit := aWarnig[nX][5] * -1
		ElseIf Alltrim(aWarnig[nX][1]) $ "41|42|46|47|51|52|54|61|62|63|64|67" .AND. aWarnig[nX][5] < 0
			nPosit := aWarnig[nX][5] * -1
		ElseIf Alltrim(aWarnig[nX][1]) $ "11|13|14" .AND. aWarnig[nX][5] < 0
			nPosit := aWarnig[nX][5] * -1
		Else
			nPosit := aWarnig[nX][5]
		EndIf

	    If !lIsLegacy
			If aWarnig[nX][3] != nPosit
				lwar := .T.
				Exit
			EndIf
		Else
			If aWarnig[nX][3] != aWarnig[nX][4] .AND. aWarnig[nX][4] != nPosit
				lwar := .T.
				Exit
			EndIf
		EndIf

	Next nX

Return lWar

//---------------------------------------------------------------------
/*/{Protheus.doc} Tafsum
	(long_description)
	@type  Function
	@author alexandre de lima
	@since 13/02/2025
	@version version
	@param cIncid,    character, tipo de incidencia informada
	@param cTipo,     character, Tipo que denominam a soma ou subtração dos valores
	@param nVal,      numeric, Valor que será retornado por referencia
	@param nValQuery, numeric, Valor trazido na query
	@param lRet,      logical, lRet para 'true' caso add valor no relatorio
	@param cOrigem,   character, Origem dos tipos quando for folha -taf - governo
	@param nValPis13, numeric, Para valores de 13°
	@param cIndDec,   character,indicativo de 13° na origem 3 ( 0 - não 1 - sim )
	@return lRet, logical, return_desCaso o valor tenha que ser adicionado ao relatorio retorna true

	Obser: caso essa função no futuro fique muito grande, avaliar a performance nas perguntas.
/*/
//---------------------------------------------------------------------	
Function Tafsum( cIncid as character, cTipo as character, nVal as numeric, nValQuery as numeric, lRet as logical , cOrigem as character, nValPis13 as numeric, cIndDec as character )
	
	Default cIncidPis := ""
	Default cTipo     := ""
	Default lRet      := .F.
	Default nVal      := 0
	Default nValPis13 := 0
	Default nValQuery := 0

	If cIncid $ "11|91" 
	
		If cOrigem != '3'

			If cTipo $ '1|3'
				nVal += nValQuery 
			Else
				nVal -= nValQuery
			EndIf

		ElseIf cIndDec == '0' .AND.	cIncid == '11'
			nVal += nValQuery
		EndIf

		lRet := .T.

	EndIf

	If cIncid $ "12|92"		

		If cTipo $ '1|3'
			nValPis13 += nValQuery 
		Else
			nValPis13 -= nValQuery
		EndIf

		lRet := .T.
	
	ElseIf cIndDec == '1' .AND.	cIncid == '11'

		nValPis13 += nValQuery
		lRet := .T.

	EndIf

Return
