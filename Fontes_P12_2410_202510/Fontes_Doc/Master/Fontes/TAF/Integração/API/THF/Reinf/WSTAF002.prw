#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"

#DEFINE SINTETICO 1,1
#DEFINE DELETSINT 1,2
#DEFINE DELETANAL 2,2

#DEFINE CONTRIB			1
#DEFINE SOURCEBRANCH	1
#DEFINE PERIOD			2
#DEFINE STATUS			3
#DEFINE EVENTS			4
#DEFINE EVENTTYPE		5
#DEFINE PAGE			6
#DEFINE PAGESIZE		7
#DEFINE EMPPROC			8
#DEFINE FILPROC			9

#DEFINE MSGFIMREG 'Não exitem mais registros para serem apurados!'

Static __oTmpFil 		:= Nil
Static __cEvtTot 		:= Nil
Static __cEvtTotContrib := Nil

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF002
WS para retorno das informções referente ao detalhe das movimentações da base

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSRESTFUL WSTAF002 DESCRIPTION "API Reinf - Info Base para Apuração"

	WSDATA companyId	AS STRING
	WSDATA period		AS STRING
	WSDATA event		AS STRING
	WSDATA branchId		AS STRING
	WSDATA id			AS STRING
	WSDATA item			AS STRING
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL
	WSDATA routine 		AS STRING OPTIONAL
	WSDATA nif          AS STRING OPTIONAL
	WSDATA providerCode AS STRING OPTIONAL

	WSMETHOD POST eventDetail;
		DESCRIPTION "Documentos pendentes de apuração por eventos";
		WSSYNTAX "/eventDetail";
		PATH "eventDetail";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET invoiceDetail;
		DESCRIPTION "Detalhe dos documentos pendentes de apuração por eventos";
		WSSYNTAX "/invoiceDetail";
		PATH "invoiceDetail";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET taxDetail;
		DESCRIPTION "Detalhe dos tributos por documento";
		WSSYNTAX "/taxDetail";
		PATH "taxDetail";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET errorMessageApurReinf;
		DESCRIPTION "Detalhe da mensagem de erro retornado durante a apuração";
		WSSYNTAX "/errorMessageApurReinf";
		PATH "errorMessageApurReinf";
		PRODUCES APPLICATION_JSON

	WSMETHOD POST apurReinf;
		DESCRIPTION "Apuração da API";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Método responsável pela consulta ao programa nativo da reinf e montagem da mensagem de resposta para camada THF

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD POST eventDetail PATHPARAM companyId, period, event, page, pageSize, routine WSREST WSTAF002

Local aApurac		as array
Local aFiliais		as array
Local aSelFils		as array
Local aCompany		as array
Local cResponse		as character
Local cNrInsc		as character
Local cTpInsc		as character
Local cBranch		as character
Local cFils			as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local cAliasPge		as character 
Local nTSintetic	as numeric
Local nTotReg       as numeric
Local lRet			as logical
Local oResponse		as object
Local oBody			as object
Local oPrepare      as object
Local cCode			as character
Local cUser			as character
Local cModule		as character
Local cRoutine		as character
Local cRelTela		as character

aApurac			:=	{}
aFiliais		:=	{}
aSelFils		:=	{}
aCompany		:=	{}
cResponse		:=	""
cNrInsc			:=	""
cTpInsc			:=	"1"
cBranch			:=	""
cFils			:=	""
cEmpRequest		:=	""
cFilRequest		:=	""
cAliasPge       :=  ""
nTSintetic		:=	0
nTotReg         :=  0
lRet			:= .T.
lHasNext        := .F.
cCode			:= "LS006"
cUser			:= ""
cModule			:= "84"
cRoutine 		:= "TAFReinf"+StrTran(self:event,"-", "")+"BtnPen"
cRelTela 		:= "TAFReinf"+StrTran(self:event,"-", "")+"RelTela"

//-----------------------------------------------
// Inicialização variáveis do tipo object
//-----------------------------------------------
oResponse	:=	JsonObject():New()
oBody		:=	JsonObject():New()
oPrepare    :=  Nil

self:SetContentType( "application/json" )

If Empty( self:GetContent() )
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Corpo da requisição não enviado." ) )
ElseIf self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:period == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
ElseIf self:event == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informado no parâmetro 'event'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			cUser := RetCodUsr()
			aFiliais := WSLoadFil()
			If __cEvtTot 	== Nil
				__cEvtTot := IIf(FindFunction("GetTotalizerEventCode"),GetTotalizerEventCode("evtTot"),'R-5001')
				__cEvtTotContrib :=  IIf(FindFunction("GetTotalizerEventCode"),GetTotalizerEventCode("evtTotContrib"),'R-5011')
			EndiF 
			oBody:FromJSON( self:GetContent() )

			If FindFunction( "FWLSPutAsyncInfo" )
				If self:routine == 'validation'
					FWLSPutAsyncInfo( cCode, cUser, cModule, cRoutine )
					TAFConOut( "-> " +cRoutine,1,.F.,"LSTAF")
				Elseif self:routine == 'report'
					FWLSPutAsyncInfo( cCode, cUser, cModule, cRelTela )
					TAFConOut( "-> " +cRelTela,1,.F.,"LSTAF")
				Endif				
			EndIf 

			//----------------------------------------------//
			// Consulta a apuração da Reinf conforme Evento //
			//----------------------------------------------//
			aApurac := TAFGetEvt( self:period, self:event, "", aFiliais, 1, "", "", "", "", self:page, self:pageSize, .T.,,,,@oPrepare )

			oResponse["eventDetail"] := {}

			If self:event $ "R-1000" .and. !Empty( aApurac )
				While ( aApurac[1] )->( !Eof() )
					cNrInsc := Posicione( "SM0", 1, SM0->M0_CODIGO + ( aApurac[CONTRIB] )->C1E_FILTAF, "M0_CGC" )
					cBranch := AllTrim( EncodeUTF8( SM0->M0_FILIAL ) )
					cTpInsc := IIf( Len( AllTrim( cNrInsc ) ) == 11, "2", "1" )

					aAdd( oResponse["eventDetail"], JsonObject():New() )

					nTSintetic := Len( oResponse["eventDetail"] )

					//Nome da Filial
					oResponse["eventDetail"][nTSintetic]["branch"] := cBranch

					//Código da Filial
					oResponse["eventDetail"][nTSintetic]["branchId"] := cBranch

					//Tipo de Inscrição [1] - CNPJ [2] - CPF
					oResponse["eventDetail"][nTSintetic]["typeOfInscription"] := Iif( cTpInsc == "1", "1 - CNPJ", "2 - CPF" )

					//CNPJ/CPF Contribuinte
					oResponse["eventDetail"][nTSintetic]["taxNumber"] := Iif( cTpInsc == "1", SubStr( cNrInsc, 1, 8 ), cNrInsc )

					//Classificação Tributária
					oResponse["eventDetail"][nTSintetic]["taxClassification"] := ( aApurac[CONTRIB] )->C1E_CLAFIS

					//Informativo de obrigatoriedade do Contribuinte
					oResponse["eventDetail"][nTSintetic]["isMandatoryBookkeeping"] := EncodeUTF8( Iif( ( aApurac[CONTRIB] )->C1E_INDESC == "0", "0 - Empresa não obrigada a ECD", "1 - Empresa obrigada a ECD" ) )

					//Indicativo de desoneração da Folha de Pagamento
					oResponse["eventDetail"][nTSintetic]["isPayrollExemption"] := EncodeUTF8( Iif( ( aApurac[CONTRIB] )->C1E_INDDES == "0", "0 - Não Aplicável", "1 - Empresa enquadrada nos artigos 7º a 9º da Lei 12.546/2011" ) )

					//Indicativo da existência de acordo internacional para isenção de multa
					oResponse["eventDetail"][nTSintetic]["hasFineExemptionAgreement"] := Iif( ( aApurac[CONTRIB] )->C1E_ISEMUL == "0", "0 - Sem acordo", "1 - Com acordo" )

					//Data de início da validade do Contribuinte
					oResponse["eventDetail"][nTSintetic]["beginingDate"] := ( aApurac[CONTRIB] )->C1E_INIPER

					//Data de início da validade do Contribuinte
					oResponse["eventDetail"][nTSintetic]["finishingdate"] := ( aApurac[CONTRIB] )->C1E_FINPER

					//Contato
					oResponse["eventDetail"][nTSintetic]["contact"] := EncodeUTF8( Iif( TAFColumnPos( "C1E_RNOMEC" ), ( aApurac[CONTRIB] )->C1E_RNOMEC, ( aApurac[CONTRIB] )->C1E_NOMCNT ) )

					//CPF do Contato
					oResponse["eventDetail"][nTSintetic]["contactTaxNumber"] := Iif( TAFColumnPos( "C1E_RCPFC" ), ( aApurac[CONTRIB] )->C1E_RCPFC, ( aApurac[CONTRIB] )->C1E_CPFCNT )

					//Status
					oResponse["eventDetail"][nTSintetic]["status"] := Iif( TAFRStatEv( self:period,,, self:event, aFiliais, 2,,,,, cNrInsc ) $ " |0|1|", "notValidated", "validated" )

					//ID de Apuração
					oResponse["eventDetail"][nTSintetic]["key"] := SubStr( cNrInsc, 1, 8 )

					//Propriedade errors que habilita o ícone no frontend
					oResponse["eventDetail"][nTSintetic]["errors"] := "errors"

					If !Empty( self:GetContent() ) .and. self:GetContent() <> "{}"
						//Chave de busca do erro da apuração
						oResponse["eventDetail"][nTSintetic]["keyValidationErrors"] := KeyError( oResponse["eventDetail"][nTSintetic], oBody )
					EndIf

					( aApurac[1] )->( DBSkip() )
				EndDo

			ElseIf self:event $ "R-1050"
				WS0021050( aApurac, @oResponse, oBody )			

			ElseIf self:event $ "R-1070" .and. !Empty( aApurac )
				WS0021070( aApurac, oResponse, oBody, self:page, self:pageSize )

			ElseIf self:event $ "R-2010|R-2020"

				//--------------------------------------------------------------//
				// Monta a mensagem JSON de retorno referente a R-2010 e R-2020 //
				//--------------------------------------------------------------//
				WS002APRCP( aApurac, oResponse, self:period, aFiliais, self:event, oBody )

			ElseIf self:event $ "R-2030|R-2040" .and. !Empty( aApurac )
				WS002PRECAD( aApurac, oResponse, self:event, oBody )
			ElseIf self:event $ "R-2050" .and. !Empty( aApurac )
				WS0022050( aApurac, oResponse, oBody, self:page, self:pageSize )
			ElseIf self:event $ "R-2055" .and. !Empty( aApurac )
				WS0022055( aApurac, oResponse, oBody, self:period, self:event, aFiliais, self:page, self:pageSize )
			ElseIf self:event $ "R-4010" .and. !Empty( aApurac )
				WS0024010( aApurac, oResponse, self:period, self:event, aFiliais, /*6*/, oBody )
			ElseIf self:event $ "R-2060" .and. aApurac[6]
				WS0022060( aApurac, oResponse, self:period, oBody, self:page, self:pageSize )
			ElseIf self:event $ "R-3010" .and. !Empty( aApurac )
				WS0023010( aApurac, oResponse, oBody, self:page, self:pageSize )
			ElseIf self:event $ "R-4020" .and. !Empty( aApurac )
				WS0024020( aApurac, oResponse, self:period, self:event, aFiliais, /*6*/, oBody )
			ElseIf self:event $ "R-4040" .and. !Empty( aApurac )
				WS0024040( aApurac, oResponse, self:period, self:event, aFiliais, oBody )
			ElseIf self:event $ "R-4080" .and. !Empty( aApurac )
				WS0024080( aApurac, oResponse, self:period, self:event, aFiliais, oBody )												
			ElseIf self:event $ __cEvtTot
				aSelFils := ValidFils( aFiliais )
				cFils := TAFRetFilC( "V0W", aSelFils )
				TAFDelTmpFil()
				WS0025001( oResponse, cFils, self:period, self:event,, 1 )
			ElseIf self:event $ __cEvtTotContrib
				aSelFils := ValidFils( aFiliais )
				cFils := TAFRetFilC( "V0C", aSelFils )
				TAFDelTmpFil()
				WS0025011( oResponse, cFils, self:period, self:event,, 1 )
			ElseIf self:event $ "R-9005"
				aSelFils := ValidFils( aFiliais )
				cFils := TAFRetFilC( "V9D", aSelFils )
				WS0029005( oResponse, cFils, self:period, self:event,, 1 )
			ElseIf self:event $ "R-9015"
				aSelFils := ValidFils( aFiliais )
				cFils := TAFRetFilC( "V9F", aSelFils )
				WS0029015( oResponse, cFils, self:period, self:event,, 1 )
			EndIf

			lRet := .T.
			cResponse := FWJsonSerialize( oResponse, .T., .T.,, .F. )
			self:SetResponse( cResponse )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf	
	EndIf
	If oPrepare != Nil
		oPrepare:Destroy()
		oPrepare := Nil
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Método responsável pela consulta ao programa nativo da reinf e montagem da mensagem de resposta para camada THF

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET invoiceDetail QUERYPARAM companyId, period, event, id, branchId, page, pageSize, nif, providerCode WSREST WSTAF002

Local aApurac		as array
Local aFiliais		as array
Local aFil			as array
Local aCompany		as array
Local cResponse		as character
Local cID			as character
Local cCNPJAtu		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local nPage			as numeric
Local nPageSize		as numeric
Local lRet			as logical
Local oResponse		as object
Local oPrepare      as object

aApurac			:=	{}
aFiliais		:=	{}
aFil			:=	{}
aCompany		:=	{}
cResponse		:=	""
cID				:=	""
cCNPJAtu		:=	""
cEmpRequest		:=	""
cFilRequest		:=	""
nPage			:=	0
nPageSize		:=	0
lRet			:=	.T.

//-----------------------------------------------
// Inicialização variáveis do tipo object
//-----------------------------------------------
oResponse	:=	JsonObject():New()
oPrepare    :=  Nil

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:period == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
ElseIf self:event == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informado no parâmetro 'event'." ) )
ElseIf self:id == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificador do Processamento não informado no parâmetro 'id'." ) )
ElseIf self:branchId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Filial não informada no parâmetro 'branchId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			aFiliais := WSLoadFil()

			If __cEvtTot 	== Nil
				__cEvtTot := IIf(FindFunction("GetTotalizerEventCode"),GetTotalizerEventCode("evtTot"),'R-5001')
				__cEvtTotContrib :=  IIf(FindFunction("GetTotalizerEventCode"),GetTotalizerEventCode("evtTotContrib"),'R-5011')
			EndiF 
			
			If !( self:event $ "R-1070|R-2060" )
				cCNPJAtu := aFiliais[aScan( aFiliais, { |x| AllTrim( x[3] ) == AllTrim( self:branchId ) } )][6]
				aFil := RetFilDet( aFiliais, cCNPJAtu, self:event )
				cID := WSRetId( self:aQueryString )

				//-------------------------------------------------------------------
				// Consulta a apuração da Reinf conforme Evento
				//-------------------------------------------------------------------
				If !(self:event $ "R-4010|R-4020")
					aApurac := TAFGetEvt( self:period, self:event, cID, aFil, 2, "", "", "", self:branchId )
				Else
					aApurac := TafGetEvt( self:period, self:event, cID, aFil, 2, "", "", "", self:branchId, "", "", "", "", self:providerCode, self:nif, @oPrepare )
				EndIf

			Else
				If self:event $ "R-2060"
					cID := WSRetId( self:aQueryString )
				EndIf

				aApurac := TAFGetEvt( self:period, self:event, "", aFiliais, 2, "", "", self:id, "" )
			EndIf

			oResponse["invoices"] := {}

			If self:event $ "R-1070"
				WS002D1070( aApurac, oResponse )
			ElseIf self:event $ "R-2010|R-2020" .and. !Empty( aApurac )
				WSPagination( self:page, self:pageSize, @nPage, @nPageSize ) //Paginação

				( aApurac[SINTETICO] )->( DBSetOrder( 4 ) )

				If nPage > 1
					( aApurac[SINTETICO] )->( DBGoTo( nPage ) )
				Else
					( aApurac[SINTETICO] )->( DBGoTop() )
				EndIf

				//-------------------------------------------------------------------
				// Monta a mensagem JSON de retorno referente a R-2010 e R-2020
				//-------------------------------------------------------------------
				Det002APRCP( oResponse, aApurac, cID )

				aApurac[DELETSINT]:Delete()
				aApurac[DELETANAL]:Delete()
			ElseIf self:event $ "R-2030|R-2040" .and. !Empty( aApurac )
				WS002DPRECAD( aApurac, oResponse, self:event )
			ElseIf self:event $ "R-2050" .and. !Empty( aApurac )
				WS002D2050( aApurac, oResponse )
			ElseIf self:event $ "R-2060" .and. aApurac[6]
				WS002D2060( aApurac, oResponse, cID )
			ElseIf self:event $ "R-3010" .and. !Empty( aApurac )
				WS002D3010( aApurac, oResponse )
			ElseIf self:event $ "R-4010" .and. !Empty( aApurac )
				WS002D4010( aApurac, oResponse )
			ElseIf self:event $ "R-4020" .and. !Empty( aApurac )
				WS002D4020( aApurac, oResponse )
			ElseIf self:event $ "R-4080" .and. !Empty( aApurac )
				WS002D4080( aApurac, oResponse )
			ElseIf self:event $ __cEvtTot
				WS0025001( oResponse, self:branchId, self:period, self:event,, 2 )
			ElseIf self:event $ __cEvtTotContrib
				WS0025011( oResponse, self:branchId, self:period, self:event,, 2 )
			ElseIf self:event $ "R-9005"
				WS0029005( oResponse, self:branchId, self:period, self:event,, 2, self:page, self:pageSize )
			ElseIf self:event $ "R-9015"
				WS0029015( oResponse, self:branchId, self:period, self:event,, 2 )
			EndIf

			lRet := .T.
			cResponse := FWJsonSerialize( oResponse, .T., .T.,, .F. )
			self:SetResponse( cResponse )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf

		If oPrepare != Nil
			oPrepare:Destroy()
			oPrepare := Nil
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Método responsável pela consulta dos detalhes dos tributos por documento.

@author Bruno Cremaschi
@since 19/11/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET taxDetail QUERYPARAM companyId, period, event, id, item, branchId, page, pageSize WSREST WSTAF002

Local aApurac		as array
Local aFiliais		as array
Local aFil			as array
Local aCompany		as array
Local cResponse		as character
Local cID			as character
Local cCNPJAtu		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local cCodPart      as character
Local lRet			as logical
Local oResponse		as object


aApurac		:=	{}
aFiliais	:=	{}
aFil		:=	{}
aCompany	:=	{}
cResponse	:=	""
cID			:=	""
cCNPJAtu	:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
cCodPart    :=  ""
lRet		:=	.T.

//-----------------------------------------------
// Inicialização variáveis do tipo object
//-----------------------------------------------
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:period == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
ElseIf self:event == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informado no parâmetro 'event'." ) )
ElseIf self:id == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Código Documento Fiscal não informado no parâmetro 'id'." ) )
ElseIf self:item == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Número do Item não informado no parâmetro 'item'." ) )
ElseIf self:branchId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Filial não informada no parâmetro 'branchId'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			aFiliais := WSLoadFil()
			cCNPJAtu := aFiliais[aScan( aFiliais, { |x| AllTrim( x[3] ) == AllTrim( self:branchId ) } )][6]
			aFil := RetFilDet( aFiliais, cCNPJAtu, self:event )
			cID := WSRetId( self:aQueryString )

			If self:event == 'R-2030'
				cCodPart := WsPartEx(self:aQueryString, 'PROVIDERCODE')
			EndIf
			
			If __cEvtTot == Nil
				__cEvtTot := IIf(FindFunction("GetTotalizerEventCode"),GetTotalizerEventCode("evtTot"),'R-5001')
				__cEvtTotContrib :=  IIf(FindFunction("GetTotalizerEventCode"),GetTotalizerEventCode("evtTotContrib"),'R-5011')
			EndiF 
			//-------------------------------------------------------------------
			// Consulta a apuração da Reinf conforme evento
			//-------------------------------------------------------------------
			aApurac := TAFGetEvt( self:period, self:event, cID, aFil, 3, self:id, self:item, "", AllTrim( self:branchId ), , , , , cCodPart )

			oResponse["tax"] := {}

			If self:event $ "R-2030|R-2040" .and. !Empty( aApurac )
				WS002SPRECAD( aApurac, oResponse )
			ElseIf self:event $ "R-2050" .and. !Empty( aApurac )
				WS002S2050( aApurac, oResponse )
			ElseIf self:event $ __cEvtTot
				WS0025001( oResponse, self:branchId, self:period, self:event, AllTrim( self:id ), 3 )
			ElseIf self:event $ __cEvtTotContrib
				WS0025011( oResponse, self:branchId, self:period, self:event, AllTrim( self:id ), 3 )
			EndIf

			lRet := .T.
			cResponse := FWJsonSerialize( oResponse, .T., .T.,, .F. )
			self:SetResponse( cResponse )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TafGetEvt()
Executa a consulta dos registros na base que devem ser considerados para apuração

@type  Static Function
@author henrique.pereira
@since 09/04/2019
@param cPerApu periodo para apuração
@param cEvent evento requisitante da estrutura
@return aAliasQry, array, alias e objeto retornados por Apur1020
/*/
//---------------------------------------------------------------------------------------------------------------
static function TafGetEvt(cPerApu, cEvent, cId, aFiliais, nLevel, cChvNF, cItemNF, cNumProc, cFilDoc, nPage, nSize, lNewQuery, lAll, cCodPart, cNif, oPrepare)

	local cAliasQry as character
    local nX        as numeric
    local aRet      as array
    local aFil      as array
    local aAliasQry as array

	Default nPage     := 0
	Default nSize     := 0
	Default lNewQuery := .F.
	Default lAll      := .F.
	Default cCodPart  := ""
	Default cNif      := ""
	Default oPrepare  := Nil

	cAliasQry   := ""
    aFil        := {}
    aRet        := {}
    aAliasQry   := {}
    aInfEUF 	:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))

    dbSelectArea("C1H")

    do case
    case cEvent $ "R-1000"
        aFil := ValidFils( aFiliais )
        cAliasQry := TAFR1000COP( cEvent, substr(cPerApu,3,4)+substr(cPerApu,1,2) , cToD(' / / '), cToD(' / / '), '', aFil, nil, .F., .T.  )
        aAdd(aAliasQry, cAliasQry)

    case cEvent $ "R-1070"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil,{ aFiliais[nX][9] , aFiliais[nX][3] })
        Next nX

        aAliasQry := WSQry1070(aFil, nLevel, cNumProc)

    case cEvent $ "R-2010|R-2020"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil,{ aFiliais[nX][9] , aFiliais[nX][3] })
        Next nX

        If lNewQuery
			aAliasQry := EvtDet1020( substr(cPerApu,3,4) + substr(cPerApu,1,2), cEvent, aFil, aInfEUF, nPage, nSize )
		Else
			aAliasQry := Apur1020(substr(cPerApu,3,4)+substr(cPerApu,1,2), cEvent, aFil, aInfEUF, .t., cId, nLevel, cFilDoc)
		Endif

    case cEvent $ "R-2030|R-2040"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil,{ aFiliais[nX][9] , aFiliais[nX][3] })
        Next nX

        aAliasQry := WSQryPreCa(substr(cPerApu,3,4)+substr(cPerApu,1,2), aFil, nLevel, cChvNF, cEvent, cCodPart)

    case cEvent $ "R-2050"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil, {    aFiliais[nx][2], ;
                PadR(aFiliais[nx][3], FwSizeFilial(), " "), ;
                aFiliais[nx][4], ;
                aFiliais[nx][5], ;
                aFiliais[nx][6], ;
                aFiliais[nx][7], ;
                TAFGFilMatriz()[6] })
        Next nX
      
		aAliasQry := WSQry2050(substr(cPerApu,3,4)+substr(cPerApu,1,2), aFil, nLevel, cChvNF, cItemNF)

    case cEvent $ "R-2055"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil, {    aFiliais[nx][2], ;
                PadR(aFiliais[nx][3], FwSizeFilial(), " "), ;
                aFiliais[nx][4], ;
                aFiliais[nx][5], ;
                aFiliais[nx][6], ;
                aFiliais[nx][7], ;
                TAFGFilMatriz()[6] })
        Next nX

        aAliasQry := WSQry2055(substr(cPerApu,3,4)+substr(cPerApu,1,2), aFil, nLevel, cId ,cChvNF, cItemNF,cFilDoc)

    case cEvent $ "R-2060"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil,{ aFiliais[nX][9] , aFiliais[nX][3] })
        Next nX

        aAliasQry := Qury2060(substr(cPerApu,3,4)+substr(cPerApu,1,2), .T., .F. , aFil, aInfEUF, {}, cNumProc)

    case cEvent $ "R-3010"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil,{ aFiliais[nX][9] , aFiliais[nX][3] })
        Next nX

        aAliasQry := WSQry3010(substr(cPerApu,3,4)+substr(cPerApu,1,2), aFil, nLevel, cId )

    case cEvent $ "R-4010"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil,{ aFiliais[nX][9] , aFiliais[nX][3] })
        Next nX
		If nLevel == 1
        	aAliasQry := WSQry4010( substr(cPerApu,3,4) + substr(cPerApu,1,2), aFil, aInfEUF, nPage, nSize, lAll, @oPrepare )
		Else
			aAliasQry := QryInv4010( substr(cPerApu,3,4) + substr(cPerApu,1,2), aFil, aInfEUF, cId, cNif, cCodPart, cFilDoc, @oPrepare )
		EndIf

	case cEvent $ "R-4020"
        If nLevel == 1
			For nX:=1 To Len(aFiliais)
				aAdd(aFil,{ aFiliais[nX][9] , aFiliais[nX][3] })
			Next nX
		
        	aAliasQry := WSQry4020(substr(cPerApu,3,4) + substr(cPerApu,1,2), aFil, aInfEUF, nPage, nSize, lAll )
		Else
			aAliasQry := QryInv4020( substr(cPerApu,3,4) + substr(cPerApu,1,2), aFil, aInfEUF, cId, cNif, cCodPart,/*cCompV3X*/, cFilDoc )
		EndIf

	case cEvent $ "R-1050"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil,{ aFiliais[nX][9] , aFiliais[nX][3] })
        Next nX
        aAliasQry := WSQry1050( aFil, nPage, nSize, lAll )			

	case cEvent $ "R-4040"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil,{ aFiliais[nX][9] , aFiliais[nX][3] })
        Next nX
        aAliasQry := WSQry4040(substr(cPerApu,3,4) + substr(cPerApu,1,2), aFil, nPage, nSize, lAll)
	case cEvent $ "R-4080"
        For nX:=1 To Len(aFiliais)
            aAdd(aFil,{ aFiliais[nX][9] , aFiliais[nX][3] })
        Next nX
		If nLevel == 1
        	aAliasQry := WSQry4080(substr(cPerApu,3,4) + substr(cPerApu,1,2), aFil, aInfEUF, nPage, nSize, lAll )
		Else
			aAliasQry := QryInv4080( substr(cPerApu,3,4) + substr(cPerApu,1,2), aFil, aInfEUF, cId, cFilDoc)
		EndIf

    endCase

return aAliasQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} metodo POST apurReinf
invoca a apuração do determinado evento

@author Henrique Fabiano Pateno Pereira
@since 23/04/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD POST apurReinf PATHPARAM companyId, event, period WSREST WSTAF002

Local aEvents		as array
Local aFil			as array
Local aRegRec		as array
Local aFiliais		as array
Local aLoadFil		as array
Local aRetErro		as array
Local aIDLog		as array
Local aRegKey		as array
Local aRetorno		as array
Local aCompany		as array
Local aProcFil 		as array
Local a4010Fil		as array
Local a4020Fil		as array
Local cIDApReinf	as character
Local cIDLog		as character
Local cAliasTmp		as character
Local cRetProc		as character
Local cMsgRet		as character
Local cMsgErro		as character
Local cIDTrans		as character
Local cNumProc		as character
Local cResponse		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local cErroApur		as character
Local cCPF   		as character
Local cCodPar 		as character
Local cNif 			as character
Local cCNPJ         as character
Local cCNPJFil      as character
Local cBranchAnt    as character
Local cM0CGC		as character
Local nX			as numeric
Local nY			as numeric
Local nZ			as numeric
Local nConTSS		as numeric
Local nAntNx		as numeric
Local nPos			as numeric
Local nlA      		as numeric
Local lSucesso		as logical
Local lValid		as logical
Local lApi			as logical
Local lRet			as logical
Local lvalidOk		as logical
Local oRequest		as object
Local oResponse		as object
Local oRegKey		as object
Local oTmpCGC       as object
Local cCode			as character
Local cUser			as character
Local cModule		as character
Local cRoutine		as character
Local cBtnApur		as character
Local cFechB2040    as character
Local cReabB2040    as character
Local lReinf212     as logical
Local lCentApr		as logical

//----------------------------------
// Inicialização variáveis array
//----------------------------------
aEvents		:=	{}
aFil		:=	{}
aRegRec		:=	{}
aFiliais	:=	{}
aLoadFil	:=	{}
aRetErro	:=	{}
aIDLog		:=	{}
aRegKey		:=	{}
aRetorno	:=	{}
aCompany	:=	{}
aProcFil    :=  {}
a4010Fil    :=  {}
a4020Fil    :=  {}

//----------------------------------
// Inicialização variáveis string
//----------------------------------
cIDApReinf		:=	""
cIDLog			:=	""
cAliasTmp		:=	""
cRetProc		:=	""
cMsgRet			:=	""
cMsgErro		:=	""
cIDTrans		:=	""
cNumProc		:=	""
cResponse		:=	""
cEmpRequest		:=	""
cFilRequest		:=	""
cErroApur		:=  'Houve erros na apuração dos itens selecionados!'
cCPF  			:=  ""
cCodPar			:=  ""
cNif			:=  ""
cCNPJ       	:=  ""
cCNPJFil    	:=  ""
cBranchAnt  	:=  ""
cM0CGC      	:=  ""
cCode			:= "LS006"
cUser			:= ""
cModule			:= "84"
cRoutine 		:= ""
cBtnApur		:= "TAFReinf"+StrTran(self:event,"-", "")+"BtnApur"
cFechB2040		:= "TAFReinfFechBlc"+SubStr(self:event,3,2)
cReabB2040		:= "TAFReinfReabBlc"+SubStr(self:event,3,2)
lReinf212		:= .F.	

//----------------------------------
// Inicialização variáveis numéricas
//----------------------------------
nX		:=	1
nY		:=	1
nZ		:=	0
nConTss	:=	0
nAntNx	:=	0
nPos	:=	0
nlA     :=  0

//----------------------------------
// Inicialização variáveis booleana
//----------------------------------
lSucesso	:=	.F.
lValid		:=	.F.
lApi		:=	.T.
lRet		:=	.T.
lValidOk	:=  .t.
lCentApr	:= SuperGetMv("MV_TAFCAPR",.F.,.F.)

//----------------------------------
// Inicialização variáveis objeto
//----------------------------------
oRequest	:=	JsonObject():New()
oResponse	:=	JsonObject():New()
oRegKey		:=	Nil
oTmpCGC     :=  Nil

self:SetContentType( "application/json" )

If Empty( self:GetContent() )
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Corpo da requisição não enviado." ) )
ElseIf self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:event == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informado no parâmetro 'event'." ) )
ElseIf self:period == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			cUser := RetCodUsr()
			lValid := Left( GetNewPar( "MV_TAFRVLD", "N" ), 1 ) == "S"

			oRequest:FromJSON( self:GetContent() )

			aLoadFil := WSLoadFil()

			If FindFunction( "FWLSPutAsyncInfo" )
				if !( self:event $ "R-2098|R-2099|R-4099" )
					cRoutine := cBtnApur
				ElseIf self:event $ "R-2099|R-4099"
					cRoutine := cFechB2040
				ElseIf self:event == "R-2098"						
					cRoutine := cReabB2040
				Endif
				FWLSPutAsyncInfo( cCode, cUser, cModule, cRoutine )
				TAFConOut( "-> " +cRoutine,1,.F.,"LSTAF")
			EndIf

			lReinf212  := Len(aLoadFil[1]) > 9  .and. TAFColumnPos( "C1E_EVADIC" )

			//-----------------------------------------------------------------------------------------------------
			// Trata a variável cIDTrans concatenando os CNPJs para filtro dos Eventos R-2010 e R-2020 para apuração
			//-----------------------------------------------------------------------------------------------------
			If self:event == "R-1000"
				aFil := { { TAFGFilMatriz()[6], cFilAnt, cFilAnt, cEmpAnt + cFilAnt, "", "", .T., .T., .T. } }

				cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )

				aAdd( aIDLog, { cIDApReinf, oRequest["customerProviders"][nX]["branchId"], AllTrim( oRequest["customerProviders"][nX]["id"] ) } )

				TAFAPR1000( self:event, self:period, CToD( "01/03/2019"), CToD( "31/03/2019" ), cIDApReinf, aFil,, lValid, .F., @lSucesso, @cMsgRet )
				TAFXLogFim( cIDApReinf, self:event, self:period )

				If !Empty( cMsgRet )
					oResponse["message"] := EncodeUTF8( cMsgRet )
				EndIf
			ElseIf self:event == "R-1070"
				For nX := 1 to Len( oRequest["customerProviders"] )
					cNumProc := oRequest["customerProviders"][nX]["id"]

					For nY := 1 to Len( aLoadFil )
						aAdd( aFil, {	aLoadFil[nY][2],;
										aLoadFil[nY][3],;
										aLoadFil[nY][4],;
										aLoadFil[nY][5],;
										"",;
										"",;
										aLoadFil[nY][9]} )
					Next nY

					cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
					aAdd( aIDLog, { cIDApReinf, oRequest["customerProviders"][nX]["branchId"], AllTrim( oRequest["customerProviders"][nX]["id"] ) } )
					TAFAPR1070( self:event, self:period, CToD( "01/03/2019" ), CToD( "31/03/2019" ), cIDApReinf, aFil, Nil, lValid, cNumProc, @lSucesso )
					cIDApReinf := TAFXLogFim( cIDApReinf, self:event, self:period )
				Next nX
			ElseIf self:event $ "R-2010|R-2020"
				//Carrega os dados para a opção "Apurar todos"
				if Len( oRequest["customerProviders"] ) = 0
					lvalidOk := EvDetail(self, @oRequest)
				endif
							
				if lvalidOk
					For nX := 1 to Len( oRequest["customerProviders"] )
						If nPos := aScan( aFiliais, { |x| x[1] == oRequest["customerProviders"][nX]["branchId"] } )
							aAdd( aFiliais[nPos][2], oRequest["customerProviders"][nX]["id"] )
						Else
							aAdd( aFiliais, { oRequest["customerProviders"][nX]["branchId"], { oRequest["customerProviders"][nX]["id"] } } )
						EndIf
					Next nX

					nAntNx := 0

					For nX := 1 to Len( aFiliais )
						For nY := 1 to Len( aFiliais[nX][2] )
							cIDTrans := ""

							If nY == Len( aFiliais[nX][2] )
								cIDTrans += "'" + aFiliais[nX][2][nY] + "'"
							Else
								cIDTrans += "'" + aFiliais[nX][2][nY] + "',"
							EndIf

							If nAntNx <> nX
								aFil := RetFil( aLoadFil, aFiliais[nX], self:event )
								nAntNx := nX
							EndIf

							cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
							aAdd( aIDLog, { cIDApReinf, oRequest["customerProviders"][nY]["branchId"], AllTrim( oRequest["customerProviders"][nY]["id"] ) } )
							TAFAPRCP( self:event, self:period, CToD( "01/03/2019"), CToD( "31/03/2019" ), cIDApReinf, aFil, Nil, lValid, @lSucesso, cIDTrans )
							TAFXLogFim( cIDApReinf, self:event, self:period )
						Next nY
					Next nX
				else
					cErroApur := MSGFIMREG
					lSucesso := .f.
				endif
			ElseIf self:event $ "R-2030|R-2040"
				For nX := 1 to Len( oRequest["customerProviders"] )
					If nPos := aScan( aFiliais, { |x| x[1] == oRequest["customerProviders"][nX]["branchId"] } )
						aAdd( aFiliais[nPos][2], oRequest["customerProviders"][nX]["id"] )
					Else
						aAdd( aFiliais, { oRequest["customerProviders"][nX]["branchId"], { oRequest["customerProviders"][nX]["id"] } } )
					EndIf
				Next nX

				nAntNx := 0

				For nX := 1 to Len( aFiliais )
					For nY := 1 to Len( aFiliais[nX][2] )
						cIDTrans := ""

						If nY == Len( aFiliais[nX][2] )
							cIDTrans += "'" + aFiliais[nX][2][nY] + "'"
						Else
							cIDTrans += "'" + aFiliais[nX][2][nY] + "',"
						EndIf

						If nAntNx <> nX
							aFil := RetFil( aLoadFil, aFiliais[nX], self:event )
							nAntNx := nX
						EndIf

						cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
						aAdd( aIDLog, { cIDApReinf, oRequest["customerProviders"][nY]["branchId"], AllTrim( oRequest["customerProviders"][nY]["id"] ) } )
						TAFApRecAD( self:event, self:period, CToD( "01/03/2019" ), CToD( "31/03/2019" ), cIDApReinf, aFil, Nil, lValid, @lSucesso, cIDTrans )
						cIDApReinf := TAFXLogFim( cIDApReinf, self:event, self:period )
					Next nY
				Next nX
			ElseIf self:event $ "R-2050"
				For nX := 1 to Len( oRequest["customerProviders"] )
					If nPos := aScan( aFiliais, { |x| x[1] == oRequest["customerProviders"][nX]["branchId"] } )
						aAdd( aFiliais[nPos][2], oRequest["customerProviders"][nX]["id"] )
					Else
						aAdd( aFiliais, { oRequest["customerProviders"][nX]["branchId"], { oRequest["customerProviders"][nX]["id"] } } )
					EndIf
				Next nX

				nAntNx := 0

				For nX := 1 to Len( aFiliais )
					cIDTrans := ""

					For nY := 1 to Len( aFiliais[nX][2] )
						If nY == Len( aFiliais[nX][2] )
							cIDTrans += "'" + aFiliais[nX][2][nY] + "'"
						Else
							cIDTrans += "'" + aFiliais[nX][2][nY] + "',"
						EndIf
					Next nY

					If nAntNx <> nX
						aFil := RetFil( aLoadFil, aFiliais[nX], self:event )
						nAntNx := nX
					EndIf

					cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
					aAdd( aIDLog, { cIDApReinf, oRequest["customerProviders"][nX]["branchId"], AllTrim( oRequest["customerProviders"][nX]["id"] ) } )
					TAFAPR2050( "", self:period, CToD( "01/03/2019" ), CToD( "31/03/2019" ), cIDApReinf, aFil, Nil, lValid, @lSucesso )
					cIDApReinf := TAFXLogFim( cIDApReinf, self:event, self:period )
				Next nX
			ElseIf self:event $ "R-2055"
				For nX := 1 to Len( oRequest["customerProviders"] )
					nPos := aScan( aFiliais, { |x| x[2] == oRequest["customerProviders"][nX]["id"] } )

					If nPos == 0
						aAdd( aFiliais, { oRequest["customerProviders"][nX]["branchId"],  oRequest["customerProviders"][nX]["id"] }  )
					EndIf
				Next nX

				nAntNx := 0

				For nX := 1 to Len( aFiliais )
					If nAntNx <> nX
						aFil := RetFil( aLoadFil, aFiliais[nX], self:event )
						nAntNx := nX
					EndIf

					cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
					aAdd( aIDLog, { cIDApReinf, oRequest["customerProviders"][nX]["branchId"], AllTrim( oRequest["customerProviders"][nX]["id"] ) } )
					TAFAPR2055( "", self:period, CToD( "01/03/2019" ), CToD( "31/03/2019" ), cIDApReinf, aFil, Nil, lValid, @lSucesso)
					cIDApReinf := TAFXLogFim( cIDApReinf, self:event, self:period )
				Next nX
			ElseIf self:event $ "R-2060"
				For nX := 1 to Len( oRequest["customerProviders"] )
					If nPos := aScan( aFiliais, { |x| x[1] == oRequest["customerProviders"][nX]["branchId"] } )
						aAdd( aFiliais[nPos][2], oRequest["customerProviders"][nX]["id"] )
					Else
						aAdd( aFiliais, { oRequest["customerProviders"][nX]["branchId"], { oRequest["customerProviders"][nX]["id"] } } )
					EndIf
				Next nX

				For nX := 1 to Len( aLoadFil )
					aAdd( aFil, {	aLoadFil[nx][2],;
									PadR( aLoadFil[nx][3], FWSizeFilial(), " " ),;
									aLoadFil[nx][4],;
									aLoadFil[nx][5],;
									aLoadFil[nx][6],;
									aLoadFil[nx][7],;
									TAFGFilMatriz()[6] } )
				Next nX

				For nX := 1 to Len( oRequest["customerProviders"] )
					cIDTrans := "'" + AllTrim( oRequest["customerProviders"][nX]["id"] ) + "'"

					cIDApReinf := TAFXLogIni( cIDLog, self:event, self:period )

					aAdd( aIDLog, { cIDApReinf, oRequest["customerProviders"][nX]["branchId"], AllTrim( oRequest["customerProviders"][nX]["id"] ) } )

					TAFAPR2060( self:event, self:period, CToD( "01/03/2019" ), CToD( "31/03/2019" ), cIDApReinf, aFil, Nil, lValid, cIDTrans, @lSucesso )
					TAFXLogFim( cIDApReinf, self:event, self:period )
				Next nX
			ElseIf self:event == "R-3010"
				For nX := 1 to Len( oRequest["customerProviders"] )
					If nPos := aScan( aFiliais, { |x| x[1] == oRequest["customerProviders"][nX]["branchId"] } )
						aAdd( aFiliais[nPos][2], oRequest["customerProviders"][nX]["id"] )
					Else
						aAdd( aFiliais, { oRequest["customerProviders"][nX]["branchId"], { oRequest["customerProviders"][nX]["id"] } } )
					EndIf
				Next nX

				nAntNx := 0

				For nX := 1 to Len( aFiliais )
					For nY := 1 to Len( aFiliais[nX][2] )
						nZ ++

						cIDTrans := "'" + aFiliais[nX][2][nY] + "'"

						If nAntNx <> nX
							aFil := RetFil( aLoadFil, aFiliais[nX], self:event )
							nAntNx := nX
						EndIf

						cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
						aAdd( aIDLog, { cIDApReinf, oRequest["customerProviders"][nZ]["branchId"], AllTrim( oRequest["customerProviders"][nZ]["id"] ) } )
						TAFAPR3010( self:event, self:period, CTOD( "01/03/2019" ), CToD( "31/03/2019"), cIDApReinf, aFil, Nil, @lSucesso, cIDTrans, lApi )
						cIDApReinf := TAFXLogFim( cIDApReinf, self:event, self:period )
					Next nY
				Next nX
			ElseIf self:event $ "R-2099|R-2098|R-4099"
				aFil := { { TAFGFilMatriz()[6], cFilAnt, cFilAnt, cEmpAnt + cFilAnt, "", "", .T., .T., .T. } }

				If self:event == "R-2099"
					//CToD( "01/03/2019" ), CToD( "31/03/2019" ) são passados chumbados. A função TAFAPRCP possui os parâmetros na assinatura, mas não são usados para nada.
					cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
					cRetProc := TAFAPR2099( self:event, self:period, CToD( "01/03/2019" ), CToD( "31/03/2019" ), cIDApReinf, aFil, Nil, .T. )

					If !Empty( cRetProc )
						oResponse["message"] := EncodeUTF8( cRetProc )
					EndIf

					cIDApReinf := TAFXLogFim( cIDApReinf, self:event, self:period )
				ElseIf self:event == "R-2098"
					//CToD( "01/03/2019" ), CToD( "31/03/2019" ) são passados chumbados. A função TAFAPRCP possui os parâmetros na assinatura, mas não são usados para nada.
					cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
					cRetProc := TAFAPR2098( self:event, self:period, CToD( "01/03/2019" ), CToD( "31/03/2019" ), cIDApReinf, aFil, Nil, .T. )

					If !Empty( cRetProc )
						oResponse["message"] := EncodeUTF8( cRetProc )
					EndIf

					cIDApReinf := TAFXLogFim( cIDApReinf, self:event, self:period )

				ElseIf self:event == "R-4099"
					lSucesso := .F.
					If AliasInDic("V3W")
						aFil := { {TAFGFilMatriz()[6],cFilAnt,cFilAnt,cEmpAnt+cFilAnt,"","",.T.,.T.,.T.} }
						cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
						cRetProc := TAFAPR4099( self:event, self:period, cIDApReinf, aFil, @lSucesso )
						If !Empty( cRetProc )
							oResponse["message"] := EncodeUTF8( cRetProc )
						EndIf
						cIDApReinf := TAFXLogFim( cIDApReinf, self:event, self:period )
					else
						oResponse["message"] := EncodeUTF8( "Tabela V3W (apuração do fechamento R-4099) não encontrada." )
					endif
				EndIf

				aEvents := TAFRotinas( self:event, 4, .F., 5 )

				//--------------------------------------------------------------------
				// Executa a query dos registros que devem ser transmitidos
				//--------------------------------------------------------------------
				cAliasTmp := WS004Event( aEvents, self:Period )

				VarInfo( "aEvents", aEvents )

				//--------------------------------------------------------------------------------------------------------
				// Com base na query acima, alimenta o array aRegRec para a função TAFProc9TSS execitar a transmissão
				//--------------------------------------------------------------------------------------------------------
				aRegRec := WSTAFRecno( cAliasTmp )
				aRetorno := TAFProc9TSS( .T., aEvents, Nil, Nil, Nil, Nil, Nil, @cMsgRet, Nil, Nil, Nil, Nil, Nil, aRegRec,, lApi, @aRetErro )
				nConTSS := At( "Não foi possível conectar com o servidor do TSS", cMsgRet )

				If Len( aRetorno ) == 0 .or. nConTSS > 0
					lSucesso := .F.

					If !Empty( cMsgRet )
						oResponse["message"] := EncodeUTF8( cMsgRet )
					EndIf
				Else
					oResponse["message"] := EncodeUTF8( "Evento transmitido com sucesso." )
					lSucesso := .T.
				EndIf
			ElseIf self:event $ "R-4010"
				//Carrega os dados para a opção "Apurar todos"
				if Len( oRequest["customerProviders"] ) == 0
					lvalidOk := EvDetail(self, @oRequest)
				endif
				if lvalidOk
					For nX := 1 to Len( oRequest["customerProviders"] )
						nPos := aScan( aFiliais, { |x| x[1] == oRequest["customerProviders"][nX]["branchId"] } )
						If nPos > 0
							aAdd( aFiliais[nPos][2], {oRequest["customerProviders"][nX]["id"],oRequest["customerProviders"][nX]["nif"],oRequest["customerProviders"][nX]["code"]} )
						Else
							cM0CGC := Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,oRequest["customerProviders"][nX]["branchId"],{ "M0_CGC" })[1][2]) 
							aAdd( aFiliais, { oRequest["customerProviders"][nX]["branchId"], {{ oRequest["customerProviders"][nX]["id"],oRequest["customerProviders"][nX]["nif"], oRequest["customerProviders"][nX]["code"]}  },cM0CGC} )
						EndIf
					Next nX

					TafOrdFil( aFiliais, @aProcFil, lReinf212, aLoadFil )

					For nX := 1 to Len( aProcFil )
						cCPF := "" //acumula os cnpj para todas as filiais com a mesma raiz de CNPJ
						cCodPar := ""
						cNif  := ""
						a4010Fil := Separa( aProcFil[nX][2], "," )
						For nlA := 1 to Len(a4010Fil)
							nPos := aScan( aFiliais, { |x| Alltrim(x[1]) == Alltrim(a4010Fil[nlA]) } )
							if nPos > 0
								For nY := 1 to Len( aFiliais[nPos][2] )
									If !Empty(aFiliais[nPos][2][nY][1])
										If Empty( cCPF )
											cCPF 	+= "'" + Substr(aFiliais[nPos][2][nY][1],1,11) + "'"
										Else
											cCPF 	+= iif( (cCPF $ aFiliais[nPos][2][nY][1]), "", (",'" + aFiliais[nPos][2][nY][1] + "'") )
										EndIf
									ElseIf !Empty(aFiliais[nPos][2][nY][2])	
										If Empty( cNif )
											cNif += "'" + Alltrim(aFiliais[nPos][2][nY][2]) + "'"
										Else
											cNif	+= iif( (cNif $ aFiliais[nPos][2][nY][2]), "", (",'" + Alltrim(aFiliais[nPos][2][nY][2]) + "'") )
										EndIf	
									ElseIf !Empty(aFiliais[nPos][2][nY][3])	
										If Empty( cCodPar )
											cCodPar += "'" + Alltrim(aFiliais[nPos][2][nY][3]) + "'"
										Else
											cCodPar	+= iif( (cCodPar $ aFiliais[nPos][2][nY][3]), "", (",'" + Alltrim(aFiliais[nPos][2][nY][3]) + "'") )
										EndIf	
									EndIf	
								Next nY
							endif
							if nlA == 1 //passar apenas no primeiro codigo da filial do aFiliais para retornar todos os cnpj com a mesma raiz
								aFil := RetFil( aLoadFil, aFiliais[nPos], self:event, lReinf212, aProcFil[nX][3], lCentApr )
							endif
						Next nlA
						If !Empty(cCPF)
							TafPopTmp( @oTmpCGC , @cCPF, 11)
							//Chamada da apuracao por blocos com a mesma raiz de CNPJ e possui CPF
							TAFAPR4010( self:period, aFil, lValid, @lSucesso, cCPF, @aIDLog, '', ,lReinf212, lCentApr  )
						EndIf	
						If !Empty(cCodPar)
							TafPopTmp( @oTmpCGC , @cCodPar, 60)
							
							//Chamada da apuracao por do fornecedor exterior que nao possui cpf nem NIF
							TAFAPR4010( self:period, aFil, lValid, @lSucesso, '', @aIDLog, cCodPar, , lReinf212, lCentApr  )
						EndIf	
						If !Empty(cNif)
							TafPopTmp( @oTmpCGC , @cNif, TamSx3("C1H_NIF")[2])
							//Chamada da apuracao por do fornecedor exterior que nao possui cpf mas possui NIF
							TAFAPR4010( self:period, aFil, lValid, @lSucesso, '', @aIDLog, '', cNif, lReinf212, lCentApr  )
						EndIf	

						TafDelTmp( @oTmpCGC ) //Apaga apos ser utilizado na query do TAFAPR4010
					Next nX
					aSize(aProcFil,0)
					aSize(a4010Fil,0)
				else
					cErroApur := MSGFIMREG
					lSucesso := .f.
				endif
			ElseIf self:event $ "R-4020"
				//Carrega os dados para a opção "Apurar todos"
				if Len( oRequest["customerProviders"] ) == 0
					lvalidOk := EvDetail(self, @oRequest)
				endif
				if lvalidOk
					For nX := 1 to Len( oRequest["customerProviders"] )
						nPos := aScan( aFiliais, { |x| x[1] == oRequest["customerProviders"][nX]["branchId"] } )
						If nPos > 0
							aAdd( aFiliais[nPos][2], {oRequest["customerProviders"][nX]["id"],oRequest["customerProviders"][nX]["nif"],oRequest["customerProviders"][nX]["code"]} )
						Else
							cM0CGC := Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,oRequest["customerProviders"][nX]["branchId"],{ "M0_CGC" })[1][2]) 
							aAdd( aFiliais, { oRequest["customerProviders"][nX]["branchId"], {{ oRequest["customerProviders"][nX]["id"],oRequest["customerProviders"][nX]["nif"], oRequest["customerProviders"][nX]["code"]}  },cM0CGC} )
						EndIf
					Next nX

					TafOrdFil( aFiliais, @aProcFil, lReinf212, aLoadFil )

					For nX := 1 to Len( aProcFil )
						cCNPJ := "" //acumula os cnpj para todas as filiais com a mesma raiz de CNPJ
						cCodPar := ""
						cNif  := ""

						a4020Fil := Separa( aProcFil[nX][2], "," )
						For nlA := 1 to Len(a4020Fil)
							nPos := aScan( aFiliais, { |x| Alltrim(x[1]) == Alltrim(a4020Fil[nlA]) } )
							if nPos > 0
								For nY := 1 to Len( aFiliais[nPos][2] )
									If !Empty(aFiliais[nPos][2][nY][1])	
										If Empty( cCNPJ )
											cCNPJ += "'" + aFiliais[nPos][2][nY][1] + "'"
										Else
											cCNPJ += iif( (cCNPJ $ aFiliais[nPos][2][nY][1]), "", (",'" + aFiliais[nPos][2][nY][1] + "'") )
										EndIf
									ElseIf !Empty(aFiliais[nPos][2][nY][2])	
										If Empty( cNif )
											cNif += "'" + Alltrim(aFiliais[nPos][2][nY][2]) + "'"
										Else
											cNif	+= iif( (cNif $ aFiliais[nPos][2][nY][2]), "", (",'" + Alltrim(aFiliais[nPos][2][nY][2]) + "'") )
										EndIf	
									ElseIf !Empty(aFiliais[nPos][2][nY][3])	
										If Empty( cCodPar )
											cCodPar += "'" + Alltrim(aFiliais[nPos][2][nY][3]) + "'"
										Else
											cCodPar	+= iif( (cCodPar $ aFiliais[nPos][2][nY][3]), "", (",'" + Alltrim(aFiliais[nPos][2][nY][3]) + "'") )
										EndIf	
									EndIf	
								Next nY
							endif
							if nlA == 1 //passar apenas no primeiro codigo da filial do aFiliais para retornar todos os cnpj com a mesma raiz
								aFil := RetFil( aLoadFil, aFiliais[nPos], self:event, lReinf212, aProcFil[nX][3], lCentApr )
							endif
						Next nlA


						If !Empty(cCNPJ)
							TafPopTmp( @oTmpCGC , @cCNPJ, 14)
							//Chamada da apuracao por blocos com a mesma raiz de CNPJ e possui CNPJ
							TAFAPR4020( self:period, aFil, lValid, @lSucesso, cCNPJ, @aIDLog,,,lReinf212, lCentApr)
						EndIf	
						If !Empty(cCodPar)
							TafPopTmp( @oTmpCGC , @cCodPar, 60)
							//Chamada da apuracao por do fornecedor exterior que nao possui CNPJ nem NIF
							TAFAPR4020( self:period, aFil, lValid, @lSucesso, '', @aIDLog, cCodPar,,lReinf212, lCentApr)
						EndIf	
						If !Empty(cNif)
							TafPopTmp( @oTmpCGC , @cNif, TamSx3("C1H_NIF")[2])
							//Chamada da apuracao por do fornecedor exterior que nao possui CNPJ mas possui NIF
							TAFAPR4020( self:period, aFil, lValid, @lSucesso, '', @aIDLog, '', cNif,lReinf212, lCentApr)
						EndIf	

						TafDelTmp( @oTmpCGC ) //Apaga apos ser utilizado na query do TAFAPR4020
					Next nX
					aSize(aProcFil,0)
					aSize(a4020Fil,0)
				else
					cErroApur := MSGFIMREG
					lSucesso := .F.
				endif
			ElseIf self:event $ "R-4040"
				If Len( oRequest["customerProviders"] ) == 0
					lvalidOk := EvDetail(self, @oRequest)
				Endif
				If lvalidOk
					For nX := 1 to Len( oRequest["customerProviders"] )
						If aScan( aFiliais, { |x| x[2][1] == oRequest["customerProviders"][nX]["id"] .And. x[1]== oRequest["customerProviders"][nX]["branchId"]} ) == 0 
							aAdd( aFiliais, { oRequest["customerProviders"][nX]["branchId"], { oRequest["customerProviders"][nX]["id"] }, oRequest["customerProviders"][nX]["id"] } )
						EndIf
					Next nX

					TafOrdFil( aFiliais, @aProcFil, lReinf212, aLoadFil )

					nAntNx := 0
					For nX := 1 to Len( aProcFil )
						a4010Fil := Separa( aProcFil[nX][2], "," )
						nPos := aScan( aFiliais, { |x| Alltrim(x[1]) == Alltrim(a4010Fil[1]) } )
						if nPos > 0
							If nAntNx <> nX
								aFil := RetFil( aLoadFil, aFiliais[nPos], self:event, lReinf212, aProcFil[nX][3] )									
								nAntNx := nX
							EndIf
							cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
							aAdd( aIDLog, { cIDApReinf, oRequest["customerProviders"][nX]["branchId"], AllTrim( oRequest["customerProviders"][nX]["id"] ) } )
							TAFAPR4040( self:period, cIdApReinf, aFil, lValid, @lSucesso, lReinf212, aProcFil[nX][3] ) 
							TAFXLogFim( cIDApReinf, self:event, self:period )
						Endif
					Next nX
				Else
					cErroApur := MSGFIMREG
					lSucesso := .F.
				Endif
			ElseIf self:event $ "R-4080"
				If Len( oRequest["customerProviders"] ) == 0
					lvalidOk := EvDetail(self, @oRequest)
				Endif
				If lvalidOk
					For nX := 1 to Len( oRequest["customerProviders"] )											
						If cBranchAnt <> oRequest["customerProviders"][nX]["branchId"]
							cCNPJFil := Alltrim(FWSM0Util():GetSM0Data(cEmpAnt,oRequest["customerProviders"][nX]["branchId"],{ "M0_CGC" })[1][2])
							cBranchAnt := oRequest["customerProviders"][nX]["branchId"]
						EndIf
						nPos := aScan( aFiliais, { |x| x[3] == cCNPJFil } )					
						If nPos == 0
							aAdd( aFiliais, { oRequest["customerProviders"][nX]["branchId"], { oRequest["customerProviders"][nX]["id"] }, cCNPJFil } )
						Else
							nPosId := aScan(aFiliais,{|x| x[2][1] == oRequest["customerProviders"][nX]["id"]})
							If nPosId == 0
								aAdd( aFiliais[nPos][2], oRequest["customerProviders"][nX]["id"] )
							EndIf
						EndIf
					Next nX
					nAntNx := 0
					For nX := 1 to Len( aFiliais )
						For nY := 1 to Len( aFiliais[nX][2] )
							cCNPJ := "'" + aFiliais[nX][2][nY] + "'"
							If nAntNx <> nX
								aFil := RetFil( aLoadFil, aFiliais[nX], self:event )
								nAntNx := nX
							EndIf
							cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
							aAdd( aIDLog, { cIDApReinf, oRequest["customerProviders"][nY]["branchId"], AllTrim( oRequest["customerProviders"][nY]["id"] ) } )
							TAFAPR4080( self:period, cIdApReinf, aFil, lValid, @lSucesso, cCNPJ, lReinf212 ) 
							TAFXLogFim( cIDApReinf, self:event, self:period )
						Next nY
					Next nX
				Else
					cErroApur := MSGFIMREG
					lSucesso := .F.
				Endif					
			elseif self:event == 'R-1050'

				//Carrega os dados para a opção "Apurar todos"
				if Len( oRequest["customerProviders"] ) == 0
					lvalidOk := EvDetail(self, @oRequest)
				endif

				if lValidOk
					for nX := 1 to Len( oRequest['customerProviders'] )
						cCnpj := oRequest['customerProviders'][nX]['id']
						cIDApReinf := TAFXLogIni( cIDApReinf, self:event, self:period )
						aAdd( aIDLog, { cIDApReinf, oRequest['customerProviders'][nX]['branchId'], AllTrim( oRequest['customerProviders'][nX]['id'] ) } )
						TAFAPR1050( self:event, self:period, cIDApReinf, @lSucesso, cCnpj )
						cIDApReinf := TAFXLogFim( cIDApReinf, self:event, self:period )
					next 
				else
					cErroApur := MSGFIMREG
					lSucesso := .f.				
				endif

			EndIf

			oResponse["success"] := lSucesso

			If !( self:event $ "R-2098|R-2099|R-4099" )
				aIDLog := RetErAl( cFilAnt, self:event, aIDLog )
				For nX := 1 to Len( aIDLog )
					oRegKey := JsonObject():New()
					oRegKey["error"]	:= aIDLog[nX][1]
					oRegKey["branchId"]	:= aIDLog[nX][2]
					oRegKey["id"]		:= aIDLog[nX][3]
					aAdd( aRegKey, oRegKey )
					FreeObj( oRegKey )
				Next nX
			EndIf

			If lSucesso .And. !( self:event $ "R-2098|R-2099|R-4099" )
				oResponse["message"] := Iif( !Empty( aIDLog ), EncodeUTF8( ErrorMsg( cFilAnt, self:event, aIDLog[1][1] ) ), "" )
				If !Empty( oResponse["message"] )
					oResponse["registryKey"] := aRegKey
				EndIf
			ElseIf !( self:event $ "R-2098|R-2099|R-4099" )
				cMsgErro := Iif( Len( aIDLog ) == 1, EncodeUTF8( ErrorMsg( cFilAnt, self:event, aIDLog[1][1] ) ), EncodeUTF8( cErroApur ) )
				oResponse["message"]		:= cMsgErro
				oResponse["registryKey"]	:= aRegKey
			EndIf

			lRet := .T.
			cResponse := FWJsonSerialize( oResponse )
			self:SetResponse( cResponse )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetFil
Função para retornar a filial do registro selecionado para apuração

@author Bruno Cremaschi
@since 29/10/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function RetFil(aLoadFil, aFilial, cEvent, lReinf212, cIdEvAdic, lCentApr)

    local cCNPJAtu  as character
    local nX        as numeric
    local aRet      as array
    local lDifCNPJ  as logical
    local cIdEstMat as character
    Local cCnpjSM0  as character
	Local lTemEvAdic as logical

	Default lReinf212  := .F.
	Default cIdEvAdic  := ""
	Default lCentApr   := .F.

    cCNPJAtu    := ""
    nX          := 0
    aRet        := {}
    lDifCNPJ    := .F.
    cIdEstMat   := TAFGFilMatriz()[6]
	lTemEvAdic  := .F.

    If !(cEvent $ "R-2050|R-2055")
		If lReinf212 .and. cEvent $ "R-4010|R-4020|R-4040"
			lTemEvAdic := aScan( aLoadFil, { |x| !Empty(x[ 10 ]) } ) > 0
		EndIf	
		//se centralizar pegar todos os CNPJs da mesma raiz, exceto o EvAdic
		If lCentApr == .T. .and. cEvent $ "R-4010|R-4020" .and. Empty(cIdEvAdic)
			cCnpjSM0 := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , aFilial[1] , { "M0_CGC" } )[1][2])
			For nX := 1 to Len(aLoadFil)
				If Alltrim(Substring(aLoadFil[nX][6],1,8)) == Substring(cCnpjSM0,1,8) .and. Iif(lTemEvAdic,Alltrim(aLoadFil[nX][10]) == Alltrim(cIdEvAdic), .T.)
					aAdd(aRet, {     aLoadFil[nx][2], ;
						aLoadFil[nx][3], ;
						aLoadFil[nx][4], ;
						aLoadFil[nx][5], ;
						"", ;
						"", ;
						aLoadFil[nx][9],;
						iif(lTemEvAdic, aLoadFil[nx][10],"" ) })
				EndIf
			next nX
		Else
			cCnpjSM0 := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , aFilial[1] , { "M0_CGC" } )[1][2])
			For nX := 1 to Len(aLoadFil)
				If Alltrim(aLoadFil[nX][6]) == cCnpjSM0 .and. Iif(lTemEvAdic,Alltrim(aLoadFil[nX][10]) == Alltrim(cIdEvAdic), .T.)
					aAdd(aRet, {     aLoadFil[nx][2], ;
						aLoadFil[nx][3], ;
						aLoadFil[nx][4], ;
						aLoadFil[nx][5], ;
						"", ;
						"", ;
						aLoadFil[nx][9],;
						iif(lTemEvAdic, aLoadFil[nx][10],"" ) })
				EndIf
			next nX
		EndIf
    Else
        cCNPJAtu := aLoadFil[aScan(aLoadFil, {|x| AllTrim(x[3]) == AllTrim(aFilial[1]) })][6]

        For nX := 1 to Len(aLoadFil)
            If AllTrim(aLoadFil[nx][6]) <> cCNPJAtu
                lDifCNPJ := .T.
            EndIf
        Next nX

        If lDifCNPJ
            cCNPJAtu := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , aFilial[1] , { "M0_CGC" } )[1][2])
            For nX := 1 to Len(aLoadFil)
                If Alltrim(aLoadFil[nX][6]) == cCNPJAtu
                    aAdd(aRet, {    aLoadFil[nx][2], ;
                        PadR(aLoadFil[nx][3], FwSizeFilial(), " "), ;
                        aLoadFil[nx][4], ;
                        aLoadFil[nx][5], ;
                        aLoadFil[nx][6], ;
                        aLoadFil[nx][7], ;
                        TAFGFilMatriz()[6] })
                EndIf
            Next nX
        Else
            For nX := 1 to Len(aLoadFil)
                aAdd(aRet, {    aLoadFil[nx][2], ;
                    PadR(aLoadFil[nx][3], FwSizeFilial(), " "), ;
                    aLoadFil[nx][4], ;
                    aLoadFil[nx][5], ;
                    aLoadFil[nx][6], ;
                    aLoadFil[nx][7], ;
                    TAFGFilMatriz()[6] })
            Next nX
        EndIf
    EndIf

Return aRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetFilDet
Função para retornar a filial do registro posicionado, para apresentação dos documentos.

@author Bruno Cremaschi
@since 30/10/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function RetFilDet(aFiliais, cCNPJFil, cEvent)

    local nX        as numeric
    local aRet      as array
    local lDifCNPJ  as logical

    nX          := 0
    aRet        := {}
    lDifCNPJ    := .F.

    If cEvent <> "R-2050"
        For nX := 1 to Len(aFiliais)
            If AllTrim(aFiliais[nx][6]) == AllTrim(cCNPJFil)
                aAdd(aRet, aFiliais[nx])
            EndIf
        Next nX
    Else
        For nX := 1 to Len(aFiliais)
            If AllTrim(aFiliais[nx][6]) <> cCNPJFil
                lDifCNPJ := .T.
            EndIf
        Next nX

        If lDifCNPJ
            For nX := 1 to Len(aFiliais)
                If AllTrim(aFiliais[nx][6]) == AllTrim(cCNPJFil)
                    aAdd(aRet, aFiliais[nx])
                EndIf
            Next nX
        Else
            aRet := aFiliais
        EndIf
    EndIf

Return aRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Método responsável pela consulta detalhada do erro ocorrido durante a apuração do evento

@author Leticia Campos
@since 27/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET errorMessageApurReinf QUERYPARAM companyId, event, id WSREST WSTAF002

Local aCompany		as array
Local cResponse		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local lRet			as logical
Local oResponse		as object

aCompany	:=	{}
cResponse	:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
lRet		:=	.T.
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:event == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informado no parâmetro 'event'." ) )
ElseIf self:id == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificador do Processamento não informado no parâmetro 'id'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			oResponse["message"] := EncodeUTF8( ErrorMsg( cFilAnt, self:event, self:id ) )

			lRet := .T.
			cResponse := FWJsonSerialize( oResponse )
			self:SetResponse( cResponse )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oResponse )
oResponse := Nil
DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ErrorMsg
Função que retorna a mensagem de erro ocorrida na apuração do evento

@author Leticia Campos
@since 27/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function ErrorMsg(cBranch, cEvent, cIdLog)

    Local cAlias        := GetNextAlias()
    Local cMessage      := ''

    Default cIdLog      := ''
    Default cBranch     := ''
    Default cEvent      := ''

    BeginSql Alias cAlias
    SELECT
        V0K_TIPO TIPO, V0K_INFO INFO 
    FROM 
        %table:V0K%
    WHERE 
        V0K_FILORI = %Exp:cBranch% 
        AND V0K_EVENTO = %Exp:cEvent% 
        AND V0K_TIPO NOT IN ('INICIO', 'FIM', 'MSG')
        AND V0K_PROCID = %Exp:cIdLog%
    EndSql

        While (cAlias)->( !Eof() )
            cMessage += (cAlias)->INFO 
            cMessage += Chr(13) + Chr(10)
            cMessage += Replicate("-",40)
            cMessage += Chr(13) + Chr(10)
            (cAlias)->( DBSkip() )
        EndDo

    (cAlias)->(DBCloseArea())

Return ( cMessage )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Leticia Campos
@since 30/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function KeyError(oResponse, oBody)
    local cKeyError as character
    local nX        as numeric

    cKeyError       := ""
    nX              := 1

    For nX := 1 to Len(oBody["registryKey"])
        if alltrim(oBody["registryKey"][nX]["id"]) == alltrim(oResponse["key"])
            cKeyError := oBody["registryKey"][nX]["error"]
        endif
    Next nX

return ( cKeyError )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetErAl
Função que retorna o array somente com registros que estiverem com erro ou apresentar um alerta

@author Leticia Campos
@since 27/08/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function RetErAl(cBranch, cEvent, aIdLog)
	local cAlErros  := ''
	local cProcIds  := ''
    local aErrors   := {}
	local nX        := 0
	Local nTamIdLog := 0
	Local nIni      := 0
	Local nFin      := 0
	Local nLimite   := 2000
    
    default cBranch := ''
    default cEvent  := ''
    default aIdLog  := {}

	nTamIdLog := Len(aIdLog)
	nIni      := 1

	If nTamIdLog > nLimite
		nFin := nLimite
	Else
		nFin := nTamIdLog
	EndIf

	While nIni <= nTamIdLog

		cProcIds  := RetId(aIdLog, nIni, nFin)
		cAlErros  := GetNextAlias()    
		BeginSql Alias cAlErros
		SELECT DISTINCT
			V0K_PROCID PROCID
		FROM 
			%table:V0K%
		WHERE 
			V0K_FILORI = %Exp:cBranch% 
			AND V0K_EVENTO = %Exp:cEvent% 
			AND V0K_TIPO NOT IN ('INICIO', 'FIM', 'MSG')
			AND V0K_PROCID IN (%Exp:cProcIds%)
		EndSql

		(cAlErros)->(DbGoTop())

		While (cAlErros)->(!Eof())
			if (nX := aScan( aIdLog, {|x| x[1] == (cAlErros)->PROCID } )) > 0
				AADD(aErrors, aIdLog[nX])
			endif
			(cAlErros)->(DBSkip())
		EndDo

		(cAlErros)->(DBCloseArea())
		nIni := nFin + 1
		If nTamIdLog > (nFin + nLimite)
			nFin := nFin + nLimite
		Else
			nFin := nTamIdLog
		EndIf
	EndDo

Return ( aErrors )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetId()

Trata o array de ProcId para que fique no formato de execucao do IN no SQL

@since 27/08/2020
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function RetId(aIdLog, nIni, nFin)
	Local cIdLog	as character
	Local nX		as numeric
	Local lFirst    as logical

	Default nIni := 1
	Default nFin := Len(aIdLog)

	cIdLog	:= ""
	nX      := 0
	lFirst  := .t.

	For nX := nIni to nFin
		If !lFirst
			cIdLog += "' , '" + aIdLog[nX][1] + ""
		Else
			cIdLog += "" + aIdLog[nX][1] + ""
			lFirst := .F.
		EndIf
	Next nX

Return cIdLog

   
Static Function TafDelTmpFil() As Character
	If __oTmpFil <> Nil
		__oTmpFil:Delete()
		__oTmpFil := Nil
	Endif
	__cLayFil := ""
Return

/*---------------------------------------------------------------------
{Protheus.doc} EvDetail()
Simula a chamada do  metodo eventDetail coforme os parâmetros passados,
sem a necessidade de chamar como API.

@since 15/09/2022
@version 1.0
@return
---------------------------------------------------------------------*/
Static Function EvDetail(oSelf,oRequest)

Local i 		:= 0
Local nLenReq	:= 0
Local oBody		:= Nil
Local oResponse	:= Nil
Local oPrepare  := Nil
Local aFiliais	:= WSLoadFil()
Local aApurac 	:= {}
Local lHasNext	:= .F.
Local lAll      := .T.

oBody := JsonObject():New()
oBody:FromJSON( oSelf:GetContent() )

oResponse := JsonObject():New()
oResponse["eventDetail"] := {}

//Monta a mensagem JSON de retorno referente ao evento passado por parametro (R-2010/R-2020)
if oSelf:Event $ 'R-2010|R-2020'
	aApurac := TAFGetEvt( oSelf:period, oSelf:event, '', aFiliais, 0, '', '', '', '', , ,.T. )
	WS002APRCP( aApurac, oResponse, oSelf:period, aFiliais, oSelf:event, oBody, lHasNext )
elseif oSelf:Event $ 'R-4010'
	aApurac := TAFGetEvt( oSelf:period, oSelf:event, '', aFiliais, 1, '', '', '', '', /*10*/, /*11*/, .T., lAll,,,@oPrepare )
	WS0024010( aApurac, @oResponse, oSelf:period, oSelf:event, aFiliais, lAll )
elseif oSelf:Event $ 'R-4020'
	aApurac := TAFGetEvt( oSelf:period, oSelf:event, '', aFiliais, 1, '', '', '', '', /*10*/, /*11*/, .T., lAll )
	WS0024020( aApurac, @oResponse, oSelf:period, oSelf:event, aFiliais, lAll )
elseif oSelf:Event $ 'R-1050'
	aApurac := TAFGetEvt( oSelf:period, oSelf:event, '', aFiliais, 1, '', '', '', '', /*10*/, /*11*/, .T., lAll )
	WS0021050( aApurac, @oResponse, oBody )
elseif oSelf:Event $ 'R-4040'
	aApurac := TAFGetEvt( oSelf:period, oSelf:event, '', aFiliais, 1, '', '', '', '', /*10*/, /*11*/, .T., lAll )
	WS0024040( aApurac, @oResponse, oSelf:period, oSelf:event, aFiliais )
elseif oSelf:Event $ 'R-4080'
	aApurac := TAFGetEvt( oSelf:period, oSelf:event, '', aFiliais, 1, '', '', '', '', /*10*/, /*11*/, .T., lAll )
	WS0024080( aApurac, @oResponse, oSelf:period, oSelf:event, aFiliais )	
endif

//Carrega o jSon que será usado como referencia para apuração de todos os itens.
for i := 1 to len(oResponse['eventDetail'])
	if alltrim(oResponse['eventDetail'][i]['status']) == 'notValidated' //Não apurado
		aadd(oRequest['customerProviders'],JsonObject():new())
		nLenReq := len(oRequest['customerProviders'])
		oRequest['customerProviders'][nLenReq]['id'] 		:= oResponse['eventDetail'][i]['key']
		oRequest['customerProviders'][nLenReq]['branchId']	:= oResponse['eventDetail'][i]['branchId']
		if oSelf:Event $ 'R-4010|R-4020'
			oRequest['customerProviders'][nLenReq]['nif']	:= oResponse['eventDetail'][i]['nif']
			oRequest['customerProviders'][nLenReq]['code']	:= oResponse['eventDetail'][i]['providerCode']
		endif
	endif	
next

FreeObj( oBody )
oBody := Nil

FreeObj( oResponse )
oResponse := Nil

If oPrepare != Nil
	oPrepare:Destroy()
	oPrepare := Nil
EndIf

return nLenReq > 0

/*---------------------------------------------------------------------
{Protheus.doc} TafPopTmp()

@since 17/11/2022
@version 1.0
@return
---------------------------------------------------------------------*/
Static Function TafPopTmp( oTmpCGC , cFilter, nTmFiler)

Local aList    As Array
Local aStruTmp As Array
Local nlA      As Numeric
Local nAte     As Numeric
Local cTmp     As Character
Local cTable   As Character
Local cInsert  As Character
Local cValues  As Character

Default oTmpCGC  := Nil
Default cFilter  := ''
Default nTmFiler := 0

nlA      := 1
nAte  	 := 0
cTmp  	 := ''
cTable   := ''
cInsert  := ''
cValues  := ''
aList 	 := Separa(cFilter,",")
nAte  	 := Len( aList )
aStruTmp := {}

if nAte >= 5
	cTmp := GetNextAlias()
	aStruTmp := {}
	aAdd(aStruTmp,{'CGCCPF','C',nTmFiler,0})

	oTmpCGC := FwTemporaryTable():New(cTmp)
	oTmpCGC:SetFields(aStruTmp)
	oTmpCGC:AddIndex('01',{'CGCCPF'})
	oTmpCGC:Create()

	cTable := oTmpCGC:GetRealName()

	cInsert := " INSERT INTO " + cTable + " (CGCCPF) "

	For nlA := 1 to nAte
		cValues := " VALUES (" + aList[nlA]+ ")  "
		TcSqlExec( cInsert + cValues)
	Next nlA

	If Upper(TcGetDb()) $ "MSSQL7"
		cTable := StrTran (cTable,'dbo.') 
	EndIf
	cFilter := " SELECT DISTINCT CGCCPF FROM " + cTable //caso exista CNPJ duplicado remove no select
endif

Return Nil

/*---------------------------------------------------------------------
{Protheus.doc} TafDelTmp()

@since 17/11/2022
@version 1.0
@return
---------------------------------------------------------------------*/
Static Function TafDelTmp(oTmpCGC)

Default oTmpCGC := Nil

If oTmpCGC <> Nil
	oTmpCGC:Delete()
	oTmpCGC := Nil
Endif

Return Nil

/*---------------------------------------------------------------------
{Protheus.doc} TafOrdFil()

@since 23/11/2022
@version 1.0
@return
---------------------------------------------------------------------*/
Static Function TafOrdFil(aFiliais, aProcFil, lEvAdic, aLoadFil)

Local cFil  as character
Local cCNPJ as character
Local nX    as Numeric
Local nPos  as Numeric
Local cIdEvAdic as character

Default aFiliais := {}
Default aProcFil := {}
Default lEvAdic  := .F.
Default aLoadFil := {}

cFil  := ''
cCNPJ := ''
nX    := 0
nPos  := 0
cIdEvAdic := ''

//Restrutura Array com CNPJ x Filiais
For nX := 1 to Len( aFiliais )
	cFil  := aFiliais[nX][1]
	cCNPJ := aFiliais[nX][3]
	If lEvAdic
		nPos := aScan(aLoadFil,{|x| x[6]==cCNPJ .and. Alltrim(x[3])==Alltrim(cFil)})
		If nPos > 0
			cIdEvAdic := aLoadFil[nPos][10]
		EndIf	
	EndIf	
	If !lEvAdic
		nPos := aScan(aProcFil,{|x| x[1]==cCNPJ })
	Else
		nPos := aScan(aProcFil,{|x| x[1]==cCNPJ .and. x[3]==cIdEvAdic})
	EndIf	
	if nPos == 0
		If !lEvAdic
			aAdd( aProcFil, { cCNPJ,  cFil, "" } )
		Else
			aAdd( aProcFil, { cCNPJ,  cFil, cIdEvAdic } )
		EndIf	
	else
		aProcFil[nPos][2] += ',' + cFil
	endif
Next nX

Return Nil
