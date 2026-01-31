#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CHILD1 1,1
#DEFINE CHILD2 1,2
#DEFINE F_C1E_MATRIZ 09
#DEFINE EV_PERIODICOS 'R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-3010|R-4010|R-4020|R-4040|R-4080'

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF004
WS para retorno das informações referente ao detalhe das movimentações da base

@author Henrique Fabiano Pateno Pereira
@since 29/03/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSRESTFUL WSTAF004 DESCRIPTION "API Reinf - Monitor de Eventos"

WSDATA companyId			AS STRING
WSDATA period				AS STRING
WSDATA event				AS STRING
WSDATA page					AS INTEGER OPTIONAL
WSDATA pageSize				AS INTEGER OPTIONAL
WSDATA key					AS STRING
WSDATA item					AS STRING
WSDATA id					AS STRING
WSDATA customerProviders	AS STRING
WSDATA transmit				AS BOOLEAN

WSMETHOD GET eventDetail;
	DESCRIPTION "Detalhe do Evento Visão de Transmissão";
	WSSYNTAX "/eventDetail";
	PATH "eventDetail";
	PRODUCES APPLICATION_JSON

WSMETHOD GET invoiceDetail;
	DESCRIPTION "Detalhe dos Eventos a Transmistir";
	WSSYNTAX "/invoiceDetail";
	PATH "invoiceDetail";
	PRODUCES APPLICATION_JSON

WSMETHOD GET taxDetail;
	DESCRIPTION "Detalhe dos Recursos Recebidos";
	WSSYNTAX "/taxDetail";
	PATH "taxDetail";
	PRODUCES APPLICATION_JSON

WSMETHOD POST transmitionReinf;
	DESCRIPTION "Transmissão";
	WSSYNTAX "/transmitionReinf";
	PATH "transmitionReinf";
	PRODUCES APPLICATION_JSON

WSMETHOD POST deleteEvent;
	DESCRIPTION "Excluir Evento";
	WSSYNTAX "/deleteEvent";
	PATH "deleteEvent";
	PRODUCES APPLICATION_JSON

WSMETHOD POST undelete;
	DESCRIPTION "Desfazer Exclusão";
	WSSYNTAX "/undelete";
	PATH "undelete";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET eventDetail QUERYPARAM companyId, period, event, page, pageSize WSREST WSTAF004

Local aEvents		as array
Local aFindFil		as array
Local aCompany		as array
Local cAliasTmp		as character
Local cFilName		as character
Local cBranch		as character
Local cAlsChild		as character
Local aAlsAuxCh		as character
Local cAlsPai		as character
Local cAlsfilho		as character
Local cTpProc		as character
Local cTpInsc		as character
Local cNrInsc		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local nTAnalitc		as numeric
Local lObra			as logical
Local lRet			as logical
Local lHasNext		as logical
Local oResponse		as object
Local nRegIni		as numeric
Local nRegFim		as numeric
Local nPage			as numeric
Local nPageSize		as numeric
Local cCode			as character
Local cUser			as character
Local cModule		as character
Local cRoutine		as character

aEvents		:=	{}
aFindFil	:=	{}
aCompany	:=	{}
cAliasTmp	:=	""
cFilName	:=	""
cBranch		:=	""
cAlsChild	:=	""
aAlsAuxCh	:=	""
cAlsPai		:=	""
cAlsfilho	:=	""
cTpProc		:=	""
cTpInsc		:=	"1"
cNrInsc		:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
nTAnalitc	:=	0
lObra		:=	.F.
lRet		:=	.T.
lHasNext	:=	.F.
nRegIni		:=	0
nRegFim		:=	0
nPage		:=	0
nPageSize	:=	0
cCode		:= "LS006"
cUser		:= ""
cModule		:= "84"
cRoutine 	:= "TAFReinf"+StrTran(self:event,"-", "")+"Trans"

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
			aEvents		:=	TAFRotinas( self:event, 4, .F., 5 )
			cAlsChild	:=	AlsChld( self:event )
			aAlsAuxCh	:=	AlsAuxCh( self:event )
			cAlsPai		:=	AlsPai( self:event )

			If FindFunction( "FWLSPutAsyncInfo" )
				FWLSPutAsyncInfo( cCode, cUser, cModule, cRoutine )
				TAFConOut( "-> " +cRoutine,1,.F.,"LSTAF")
			EndIf 

			If self:page <> Nil
				nPage       :=	self:page
				If self:pageSize <> Nil
					nPageSize   :=	self:pageSize
				Else
					nPageSize   := 20
				EndIf

				nRegIni := ( ( nPage - 1 ) * nPageSize ) + 1
				nRegFim := nPage * nPageSize
			EndIf

			If self:event == "R-1070"
				cAlsfilho := "C07"
			ElseIf self:event == "R-2020"
				cAlsfilho := "C1H"
			ElseIf self:event == "R-2030"
				cAlsfilho := "V1G"
			ElseIf self:event == "R-2040"
				cAlsfilho := "V1J"
			ElseIf self:event == "R-3010"
				cAlsfilho := "T9G"
			ElseIf self:event == "R-2055"
				cAlsfilho := "V5T"
			ElseIf self:event == "R-9000"
				cAlsfilho := "T9B"
			ElseIf self:event == "R-4010"
				cAlsfilho := "V5E"
			ElseIf self:event == "R-4020"
				cAlsfilho := "V4S"
			ElseIf self:event == "R-4040"
				cAlsfilho := "V4P"
			ElseIf self:event == "R-4080"
				cAlsfilho := "V99"
			ElseIf self:event == "R-1050"
				cAlsfilho := "V82"
			Else
				cAlsfilho := ""
			EndIf

			cAliasTmp := WS004Event( aEvents, self:period, cAlsfilho,,, nRegIni, nRegFim, @lHasNext )

			oResponse["eventDetail"] := {}

			While ( cAliasTmp )->( !Eof() )
				aAdd( oResponse["eventDetail"], JsonObject():New() )

				nTAnalitc := Len( oResponse["eventDetail"] )

				If self:event $ "R-1000"
					cBranch := Posicione( "SM0", 1, SM0->M0_CODIGO + cFilAnt, "M0_FILIAL" )
					cTpInsc := Iif( Len( AllTrim( ( cAliasTmp )->CNPJ ) ) == 11, "2", "1" )

					//Filial
					oResponse["eventDetail"][nTAnalitc]["branch"] := EncodeUTF8( cBranch )

					//Tipo de Inscrição [1] - CNPJ [2]-  CPF
					oResponse["eventDetail"][nTAnalitc]["typeOfInscription"] := Iif( cTpInsc == "1", "1 - CNPJ", "2 - CPF" )

					//CNPJ/CPF Contribuinte
					oResponse["eventDetail"][nTAnalitc]["taxNumber"] := Iif( cTpInsc == "1", SubStr( ( cAliasTmp )->CNPJ, 1, 8 ), ( cAliasTmp )->CNPJ )

					//Classificação Tributária
					oResponse["eventDetail"][nTAnalitc]["taxClassification"] := ( cAliasTmp )->CLAFIS

					//Informativo de obrigatoriedade do Contribuinte
					oResponse["eventDetail"][nTAnalitc]["isMandatoryBookkeeping"] := EncodeUTF8( Iif( ( cAliasTmp )->INDESC == "0", "0 - Empresa não obrigada a ECD", "1 - Empresa obrigada a ECD" ) )

					//Indicativo de Desoneração da Folha de Pagamento
					oResponse["eventDetail"][nTAnalitc]["isPayrollExemption"] := EncodeUTF8( Iif( ( cAliasTmp )->INDDES == "0", "0 - Não Aplicável", "1 - Empresa enquadrada nos artigos 7º a 9º da Lei 12.546/2011" ) )

					//Indicativo da existência de acordo internacional para isenção de multa
					oResponse["eventDetail"][nTAnalitc]["hasFineExemptionAgreement"] := Iif( ( cAliasTmp )->ISEMUL == "0", "0 - Sem acordo", "1 - Com acordo" )

					//Data de início da validade do Contribuinte
					oResponse["eventDetail"][nTAnalitc]["beginingDate"] := ( cAliasTmp )->INIPER

					//Data de início da validade do Contribuinte
					oResponse["eventDetail"][nTAnalitc]["finishingdate"] := ( cAliasTmp )->FINPER

					//Contato
					oResponse["eventDetail"][nTAnalitc]["contact"] := ( cAliasTmp )->CONTATO

					//CPF do Contato
					oResponse["eventDetail"][nTAnalitc]["contactTaxNumber"] := ( cAliasTmp )->CPFCTT
				ElseIf self:event $ "R-1070"
					If ( cAliasTmp )->TPPROC == "1"
						cTpProc := "Administrativo"
					ElseIf ( cAliasTmp )->TPPROC == "2"
						cTpProc := "Judicial"
					ElseIf ( cAliasTmp )->TPPROC == "3"
						cTpProc := "Número do benefício (NB) do INSS"
					ElseIf ( cAliasTmp )->TPPROC == "4"
						cTpProc := "Processo FAP"
					EndIf

					//Tipo de Processo
					oResponse["eventDetail"][nTAnalitc]["proccesType"] := AllTrim( EncodeUTF8( cTpProc ) )

					//Número do Processo
					oResponse["eventDetail"][nTAnalitc]["proccesNumber"] := ( cAliasTmp )->NUMPROC

					//UF Vara
					oResponse["eventDetail"][nTAnalitc]["courtFederatedUnit"] := AllTrim( EncodeUTF8( ( cAliasTmp )->DESCUFVARA ) )

					//Município
					oResponse["eventDetail"][nTAnalitc]["cityCode"] := ( cAliasTmp )->CODMUN + " - " + AllTrim( EncodeUTF8( ( cAliasTmp )->DESCMUN ) )

					//Código Município
					oResponse["eventDetail"][nTAnalitc]["courtId"] := ( cAliasTmp)->IDMUN

					//Data Início
					oResponse["eventDetail"][nTAnalitc]["beginingDate"] := ( cAliasTmp )->DTINI

					//Data Fim
					oResponse["eventDetail"][nTAnalitc]["finishingDate"] := ( cAliasTmp )->DTFIM

					//Status
					oResponse["eventDetail"][nTAnalitc]["status"] := Iif( Empty( ( cAliasTmp )->STATUS ), "notValidated", "validated" )

					//ID de Apuração
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->NUMPROC
				ElseIf self:event $ "R-2010|R-2020"
					lObra := !Empty( ( cAliasTmp )->DOBRA )

					cBranch := Posicione( "SM0", 1, SM0->M0_CODIGO + ( cAliasTmp )->FILIAL, "M0_FILIAL" )

					//Filial
					oResponse["eventDetail"][nTAnalitc]["branch"] := EncodeUTF8( cBranch )

					//Filial
					oResponse["eventDetail"][nTAnalitc]["branchTaxNumber"] := AllTrim( ( cAliasTmp )->NRINSC )

					//CNPJ
					oResponse["eventDetail"][nTAnalitc]["taxNumber"] := AllTrim( Iif( lObra, AllTrim( SubStr( ( cAliasTmp )->CNO, 2 ) ), AllTrim( ( cAliasTmp )->CNPJ ) ) )

					//Descrição Participante C1H
					oResponse["eventDetail"][nTAnalitc]["company"] := AllTrim( Iif( lObra, ( cAliasTmp )->DOBRA, ( cAliasTmp )->DPARTI ) )

					//Quantidade de Notas/Faturas
					oResponse["eventDetail"][nTAnalitc]["totalInvoice"] := WS004Docs( ( cAliasTmp )->ID, cAlsChild, aAlsAuxCh, .T., self:event, cAlsPai )

					//ID do Registro
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID

					//Valor Bruto
					oResponse["eventDetail"][nTAnalitc]["totalGrossValue"] := ( cAliasTmp )->BRUTO

					//Valor Total da Base de Cálculo
					oResponse["eventDetail"][nTAnalitc]["totalTaxBase"] := ( cAliasTmp )->VLRBASE

					//Valor Total
					oResponse["eventDetail"][nTAnalitc]["totalTaxes"] := ( cAliasTmp )->VALOR
				ElseIf self:event $ "R-2030|R-2040"
					//Filial
					oResponse["eventDetail"][nTAnalitc]["branchId"] := ( cAliasTmp )->FILIAL

					//Número de Inscrição do Estabelecimento
					oResponse["eventDetail"][nTAnalitc]["taxNumber"] := ( cAliasTmp )->NRINSC

					//Valor Bruto dos Recursos Recebidos
					oResponse["eventDetail"][nTAnalitc]["totalGrossValue"] := ( cAliasTmp )->VLREPA

					//Valor Total da Retenção
					oResponse["eventDetail"][nTAnalitc]["totalReceivedWithholdAmount"] := ( cAliasTmp )->VLRET

					//Valor Total da Retenção Previdênciária com exigibilidade suspensa
					oResponse["eventDetail"][nTAnalitc]["totalValueOfRetentionWithSuspendedLiability"] := ( cAliasTmp )->VLNRET

					//ID do Registro
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID
				ElseIf self:event $ "R-2050"
					aFindFil := WSFindFil( ( cAliasTmp )->NRINSC )

					If Len( aFindFil ) > 0
						cFilName := aFindFil[17]
					EndIf

					//ID do Registro
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID

					//Razão Social
					oResponse["eventDetail"][nTAnalitc]["company"] := EncodeUTF8( AllTrim( cFilName ) )

					//Número da Inscrição
					oResponse["eventDetail"][nTAnalitc]["taxNumber"] := ( cAliasTmp )->NRINSC

					//Valor da Receita Bruta
					oResponse["eventDetail"][nTAnalitc]["totalGrossValue"] := ( cAliasTmp )->BRUTO

					//Valor da Contribuição Previdenciária
					oResponse["eventDetail"][nTAnalitc]["sociaSecurityContributionValue"] := ( cAliasTmp )->VLRCONTR

					//Valor da Contribuição Previdenciária GILRAT
					oResponse["eventDetail"][nTAnalitc]["sociaSecurityContributionValueGilrat"] := ( cAliasTmp )->GILRAT

					//Valor da Contribuição Previdenciária SENAR
					oResponse["eventDetail"][nTAnalitc]["sociaSecurityContributionValueSenar"] := ( cAliasTmp )->SENAR
				ElseIf self:event $ "R-2055"
					cNrInsc := AllTrim( ( cAliasTmp )->NRINSC )

					//ID de Apuração
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID

					//Código da Filial
					oResponse["eventDetail"][nTAnalitc]["branchId"] := ( cAliasTmp )->FILIAL

					//Código da Filial
					oResponse["eventDetail"][nTAnalitc]["acquiringBranch"] := ( cAliasTmp )->FILTAF

					//Número Inscrição Estabelecimento
					oResponse["eventDetail"][nTAnalitc]["acquiringCNPJ"] := ( cAliasTmp )->NRINSCEST

					//CNPJ
					oResponse["eventDetail"][nTAnalitc]["taxNumber"] := cNrInsc

					If Len( cNrInsc ) == 14
						cTpInsc := "1 - CNPJ"
					Else
						cTpInsc := "2 - CPF"
					EndIf

					//Tipo Inscrição
					oResponse["eventDetail"][nTAnalitc]["typeOfInscription"] := cTpInsc

					//Razão Social
					oResponse["eventDetail"][nTAnalitc]["company"] := ( cAliasTmp )->DPARTI

					//Total Bruto
					oResponse["eventDetail"][nTAnalitc]["totalGrossValue"] := ( cAliasTmp )->VBRTPR

					//Valor da Contribuição Previdenciária
					oResponse["eventDetail"][nTAnalitc]["valueINSS"] := ( cAliasTmp )->VLRCONTR

					//Valor da Contribuição Previdenciária GILRAT
					oResponse["eventDetail"][nTAnalitc]["valueGilRat"] := ( cAliasTmp )->GILRAT

					//Valor da Contribuição Previdenciária SENAR
					oResponse["eventDetail"][nTAnalitc]["valueSenar"] := ( cAliasTmp )->SENAR
				ElseIf self:event $ "R-2060"
					//Filial
					oResponse["eventDetail"][nTAnalitc]["branch"] := AllTrim( ( cAliasTmp )->FILIAL )

					//Tipo de Inscrição do Estabelecimento
					oResponse["eventDetail"][nTAnalitc]["typeOfInscription"] := ( cAliasTmp )->CTPINSC + Iif( ( cAliasTmp )->CTPINSC == "1", " - CNPJ", " - CNO" )

					//Número de Inscrição do Estabelecimento
					oResponse["eventDetail"][nTAnalitc]["companyTaxNumber"] := AllTrim( ( cAliasTmp )->CNRINSC )

					//Quantidade de Registro de Atividade
					oResponse["eventDetail"][nTAnalitc]["totalInvoice"] := WS004Docs( ( cAliasTmp )->ID, cAlsChild, aAlsAuxCh, .T., self:event, cAlsPai )

					//Valor da Receita Bruta Total
					oResponse["eventDetail"][nTAnalitc]["totalGrossValue"] := ( cAliasTmp )->VLRECBTT

					//Valor Total da Contribuição Previdenciária sobre a Receita Bruta
					oResponse["eventDetail"][nTAnalitc]["sociaSecurityContributionValue"] := ( cAliasTmp )->VLCPAPUT

					//Valor Total da Contribuição Previdenciária com exigibilidade suspensa
					oResponse["eventDetail"][nTAnalitc]["sociaSecurityContributionValueSuspended"] := ( cAliasTmp )->VLCSUSPT

					//ID de Transmissão
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID
				ElseIf self:event $ "R-3010"
					//Código da Filial
					oResponse["eventDetail"][nTAnalitc]["branch"] := ( cAliasTmp )->FILIAL

					//Nº do Boletim
					oResponse["eventDetail"][nTAnalitc]["newsletterNumber"] := ( cAliasTmp )->BOLETIM

					//Modalidade
					oResponse["eventDetail"][nTAnalitc]["mode"] := ( cAliasTmp )->MODALIDADE

					//Competição
					oResponse["eventDetail"][nTAnalitc]["competition"] := ( cAliasTmp )->COMPETICAO

					//CNPJ do Mandatário
					oResponse["eventDetail"][nTAnalitc]["taxNumberPrincipal"] := ( cAliasTmp )->CNPJMAND

					//CNPJ do Visitante
					oResponse["eventDetail"][nTAnalitc]["taxNumberVisited"] := ( cAliasTmp )->CNPJVI

					//Quantidade Pgantes
					oResponse["eventDetail"][nTAnalitc]["payingOffValue"] := ( cAliasTmp )->PAGANTES

					//Quantidade não Pagantes
					oResponse["eventDetail"][nTAnalitc]["dontPayingOffValue"] := ( cAliasTmp )->NAOPAGANTES

					//Total Receita Bruta
					oResponse["eventDetail"][nTAnalitc]["grossValue"] := ( cAliasTmp )->TOTALBRUTO

					//Contribuição Previdenciária
					oResponse["eventDetail"][nTAnalitc]["contributionValue"] := ( cAliasTmp )->TRIBUTO

					//Valor Retido
					oResponse["eventDetail"][nTAnalitc]["contributionValueSuspended"] := ( cAliasTmp )->VALORRETIDO

					//Chave de Registro
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID
				ElseIf self:event $ "R-9000"
					//ID da Exclusão
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID

					//Código da Filial
					oResponse["eventDetail"][nTAnalitc]["branchId"] := ( cAliasTmp )->FILIAL

					//Evento
					oResponse["eventDetail"][nTAnalitc]["event"] := ( cAliasTmp )->EVENTOEX

					//Recibo da Transmissão
					oResponse["eventDetail"][nTAnalitc]["receipt"] := ( cAliasTmp )->RECIBO

					//Status
					If Empty( ( cAliasTmp )->STATUS ) .or. ( cAliasTmp )->STATUS $ "0|1|3|"
						oResponse["eventDetail"][nTAnalitc]["status"] := "notTransmitted"
					ElseIf ( cAliasTmp )->STATUS $ "2|4|"
						oResponse["eventDetail"][nTAnalitc]["status"] := "transmitted"
					EndIf
				
				// R-4010
				ElseIf self:event $ "R-4010"
					//ID da Exclusão
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID

					//Código da Filial
					oResponse["eventDetail"][nTAnalitc]["branchId"] := ( cAliasTmp )->FILIAL

					//CPF
					oResponse["eventDetail"][nTAnalitc]["cpf"] := ( cAliasTmp )->CPF

					//Nome
					oResponse["eventDetail"][nTAnalitc]["name"] := EncodeUTF8(AllTrim( ( cAliasTmp )->NOME) )

					//Valor Bruto
					oResponse["eventDetail"][nTAnalitc]["grossValue"] := ( cAliasTmp )->VLRBRUTO

					//Valor IR
					oResponse["eventDetail"][nTAnalitc]["irValue"] := ( cAliasTmp )->VLRIR
				
				// R-4020
				ElseIf self:event $ "R-4020"
					//ID da Exclusão
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID

					//Código da Filial
					oResponse["eventDetail"][nTAnalitc]["branchId"] := ( cAliasTmp )->FILIAL

					//CPNJ
					oResponse["eventDetail"][nTAnalitc]["cnpj"] := ( cAliasTmp )->CNPJ

					//Nome do Beneficiário
					oResponse["eventDetail"][nTAnalitc]["beneficiaryName"] := EncodeUTF8(AllTrim( ( cAliasTmp )->NOMEBEN) )

					//Valor Bruto
					oResponse["eventDetail"][nTAnalitc]["totalValue"] := ( cAliasTmp )->VLRTOT

					//Valor BASE IR
					oResponse["eventDetail"][nTAnalitc]["irBaseValue"] := ( cAliasTmp )->BASEIR

					//Valor IR
					oResponse["eventDetail"][nTAnalitc]["irValue"] := ( cAliasTmp )->VLRIR

					//Valor CSLL
					oResponse["eventDetail"][nTAnalitc]["csllValue"] := ( cAliasTmp )->VLCSLL

					//Valor COFIN
					oResponse["eventDetail"][nTAnalitc]["cofinValue"] := ( cAliasTmp )->VCOFIN
					
					//Valor IR
					oResponse["eventDetail"][nTAnalitc]["ppValue"] := ( cAliasTmp )->VLRPP

					//Valor Agregado
					oResponse["eventDetail"][nTAnalitc]["agregValue"] := ( cAliasTmp )->VAGREG

				// R-4040
				ElseIf self:event $ "R-4040"
					//ID da Exclusão
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID

					//Código da Filial
					oResponse["eventDetail"][nTAnalitc]["branchId"] := ( cAliasTmp )->FILIAL

					//Num. Insc
					oResponse["eventDetail"][nTAnalitc]["numInsc"] := ( cAliasTmp )->NUMINSC

					//Valor Liquido
					oResponse["eventDetail"][nTAnalitc]["liquidValue"] :=  ( cAliasTmp )->VLRLIQUI

					//Valor BASE IR
					oResponse["eventDetail"][nTAnalitc]["irBaseValue"] := ( cAliasTmp )->BASEIR

					//Valor IR
					oResponse["eventDetail"][nTAnalitc]["irValue"] := ( cAliasTmp )->VLRIR

				// R-4080
				ElseIf self:event $ "R-4080"
					//ID da Exclusão
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID

					//Código da Filial
					oResponse["eventDetail"][nTAnalitc]["branchId"] := ( cAliasTmp )->FILIAL

					//Num. Insc
					oResponse["eventDetail"][nTAnalitc]["numInsc"] := ( cAliasTmp )->NUMINSF

					//Nome da Fonte Pagadora
					oResponse["eventDetail"][nTAnalitc]["fontName"] := EncodeUTF8(AllTrim( ( cAliasTmp )->NOME) )

					//Valor Bruto
					oResponse["eventDetail"][nTAnalitc]["liquidValue"] :=  ( cAliasTmp )->VLRBRU

					//Valor BASE IR
					oResponse["eventDetail"][nTAnalitc]["irBaseValue"] := ( cAliasTmp )->BASEIR

					//Valor IR
					oResponse["eventDetail"][nTAnalitc]["irValue"] := ( cAliasTmp )->VLRIR

				// R-1050
				ElseIf self:event $ "R-1050"
					//ID da Exclusão
					oResponse["eventDetail"][nTAnalitc]["key"] := ( cAliasTmp )->ID

					//Código da Filial
					oResponse["eventDetail"][nTAnalitc]["branchId"] := ( cAliasTmp )->FILIAL

					//Num. Insc
					oResponse["eventDetail"][nTAnalitc]["cnpj"] := ( cAliasTmp )->CNPJ

					//Classificação da entidade ligada
					If ( cAliasTmp )->ENTIDA == '1'
						oResponse["eventDetail"][nTAnalitc]["tpEntLig"] := EncodeUTF8('1 - Fundo de Investimento')
					ElseIf ( cAliasTmp )->ENTIDA == '2'
						oResponse["eventDetail"][nTAnalitc]["tpEntLig"] := EncodeUTF8('2 - Fundo de Investimento Imobiliário')
					ElseIf ( cAliasTmp )->ENTIDA == '3'
						oResponse["eventDetail"][nTAnalitc]["tpEntLig"] := EncodeUTF8('3 - Clube de Investimento')
					ElseIf ( cAliasTmp )->ENTIDA == '4'
						oResponse["eventDetail"][nTAnalitc]["tpEntLig"] := EncodeUTF8('4 - Sociedade em Conta de Participação')
					EndIf
				EndIf

				If !( self:event $ "R-9000" )
					//Transmitidos? Status diferente de branco, 0 e 1
					oResponse["eventDetail"][nTAnalitc]["status"] := Iif( Empty( ( cAliasTmp )->STATUS ) .or. ( cAliasTmp )->STATUS $ "0|1|", "notTransmitted", "transmitted" )
				EndIf

				( cAliasTmp )->( DBSkip() )
			EndDo

			lRet := .T.

			oResponse["hasNext"] := lHasNext
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

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} WS004Event

Executa a consulta aos eventos passíveis de transmissão 

@Author		henrique.pereira
@Since		25/04/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Function WS004Event( aEvents, cPerIni, cAlsfilho, oTableId, lAll, nRegIni, nRegFim, lHasNext)
local cSelectQry   as character
local cSelect		as character
Local cFields		as character
local cSelectPage   as character
local cFrom			as character
local cwhere		as character
local cWhereQry   as character
local cAlias		as character
local cLayout		as character
local cNrInsc		 as character
local cAlsneto		as character
local aSM0			as array 
local nMatriz		as numeric 
local lIdCheck		as logical
local aInfoEUF		as array 
local cCompC1H		as character
local cBd			as character
local cCpoId		as character
Local cWherePage	as character

cSelectQry  := ""
cWhereQry	:= ""
cSelect		:= ""
cFields		:= ""
cSelectPage := ""
cFrom		:= ""
cwhere		:= ""
cAlias		:= getnextalias()
cAlsneto	:= ""
cLayout		:= ""
cNrInsc		:= ""
aSM0		:= {}
aInfoEUF	:= {}
cCompC1H	:= ""
cBd			:= ""
nMatriz		:= 0
cCpoId		:= ''
cWherePage	:= ''

default     cPerIni     :=  ''
default     lAll        := .f.
default     nRegIni     := 0
default     nRegFim     := 0
default     lHasNext    := .F.

cAlsneto  := "V0Q"
cAliasLay := aEvents[3] //Alias do Evento
cLayout   := alltrim(aEvents[4]) //Layout

lIdCheck := valtype(oTableId) == 'O' .and. (oTableId:GetAlias())->(RecCount()) > 0

if cLayout == "R-1000"
    aSM0 := WsLoadFil()
    nMatriz := aScan(aSM0,{|x| x[F_C1E_MATRIZ] })
    cNrInsc := aSM0[nMatriz][6]   
endif

//Condição criada para a paginação dos eventos do bloco 40
If cLayout $ "R-4010|R-4020|R-4040|R-4080|R-1050" .And. nRegIni > 0

	If cLayout == 'R-4010'
		cSelectPage += " EVENTO , FILIAL, ID, STATUS, CPF, NOME, VLRBRUTO, VLRIR, RECNO FROM ( "
	ElseIf cLayout == 'R-4020'
		cSelectPage += " EVENTO , FILIAL, ID, STATUS, CNPJ, NOMEBEN, VLRTOT,BASEIR, VLRIR, VLCSLL, VCOFIN, VLRPP, VAGREG, RECNO FROM ( "
	ElseIf cLayout == 'R-4040'
		cSelectPage += " EVENTO , FILIAL, ID, STATUS, NUMINSC, VLRLIQUI, BASEIR , VLRIR, RECNO FROM ( "
		cOrderFld   := " " + cAliasLay + "." +"R_E_C_N_O_ "
	ElseIf cLayout == 'R-4080'
		cSelectPage += " EVENTO , FILIAL, ID, STATUS, NUMINSF, NOME, VLRBRU, BASEIR , VLRIR, RECNO FROM ( "
	ElseIf cLayout == 'R-1050'
		cSelectPage += " EVENTO , FILIAL, ID, STATUS, CNPJ, ENTIDA, RECNO FROM ( "
	EndIf
	
	cSelectPage += " SELECT ROW_NUMBER() OVER( ORDER BY " + cAliasLay + "."  + cAliasLay +"_STATUS) LINE_NUMBER, "
	cFields := cAliasLay + "." + "R_E_C_N_O_ ) LINE_NUMBER, "

EndIf

cSelect += "' " + cLayout   + "' EVENTO "
cSelect += " ," + cAliasLay + "." + cAliasLay + "_FILIAL FILIAL " 
cSelect += " ," + cAliasLay + "." + cAliasLay + "_ID ID "
cSelect += " ," + cAliasLay + "." + cAliasLay + "_STATUS STATUS "

If cLayout $ "R-2010|R-2020"
  	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_CNPJPR  CNPJ "
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_DPARTI  DPARTI "
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_TPNUOB  CNO "   // Inscrição da Obra
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_DOBRA   DOBRA " // descrição da Obra
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSC  NRINSC "
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VLRPRI  VALOR " 
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VLRBRU  BRUTO "
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VLRBRE  VLRBASE "
    cSelect += " ," + cAliasLay + "." + cAliasLay + "_PERAPU PERAPU " 
EndIf

If cLayout $ "R-2030|R-2040"
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSC NRINSC"   // número de inscrição do estabelecimento
    cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLREPA) VLREPA"   // valor total recebido
    cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRET)  VLRET"    // valor total da retenção
    cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VLNRET) VLNRET"   // valor total da retenção com exibilidade suspensa
endif

If cLayout $ "R-2060"
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_FILIAL FILIAL "  // filial
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_TPINSC CTPINSC"   // tipo de inscrição
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSC CNRINSC"   // número de inscrição
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VLRBRT VLRECBTT"  // valor da receita bruta
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VLCPAP VLCPAPUT"  // valor da CPBR
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VLSCPR VLCSUSPT"  // valor da CPBR com exibilidade suspensa
endif

If cLayout $ "R-2050"
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_TPINSC  TPINSC "    // tipo de inscrição
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSC  NRINSC "    // número da inscrição
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VRECBT  BRUTO "     // valor da receita bruta
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VCPAPU  VLRCONTR "  // valor da contribuição previdenciária
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VRAAPU  GILRAT "    // valor da contribuição previdenciária GILRAT
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_VSEAPU  SENAR "     // valor da contribuição previdenciária SENAR
EndIf

If cLayout $ "R-2055"

    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSC  NRINSCEST "  // número da inscrição estabelecimento 
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSP  NRINSC "     // número da inscrição
	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_DPARTI  DPARTI "	 // nome participante
    cSelect += " , C1E.C1E_FILTAF FILTAF " //Codigo do Estabelecimento (necessario para apresentar corretamente a Razão Social )

    if !Empty( cAlsfilho )
        cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VBRTPR) VBRTPR"   // valor total recebido
        cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VCPPR ) VLRCONTR" // valor da contribuição previdenciária
        cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VRATPR ) GILRAT"  // valor da contribuição previdenciária GILRAT
        cSelect += " , SUM(" + cAlsfilho + "." + cAlsfilho + "_VSENPR ) SENAR"   // valor da contribuição previdenciária SENAR
    endif
EndIf

If cLayout $ "R-1070"
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_TPPROC TPPROC "      // tipo de processo
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_NUMPRO NUMPROC "     // número do processo
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_DSUFVA DESCUFVARA "  // uf da vara
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_IDMUNI IDMUN "       // id do municipio
    cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_CODIGO CODMUN "      // código do municipio
    cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_DESCRI DESCMUN "     // descrição do municipio
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_IDVARA IDVARA "      // id da vara
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_DTINI  DTINI "       // data de inicio
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_DTFIN  DTFIM "       // data de fim
EndIf

If cLayout $ "R-1000"
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_NRINSC  CNPJ "
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_CLAFIS  CLAFIS "
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_INDECD  INDESC "
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_IDCPRB  INDDES "
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_INDACR  ISEMUL "
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_DTINI   INIPER "
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_DTFIN   FINPER "
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_NOMCTT  CONTATO "
    cSelect += ", " + cAliasLay + "." + cAliasLay + "_CPFCTT  CPFCTT "
EndIf

If cLayout $ "R-3010"
    cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_NUMBOL  BOLETIM "
    cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_MODDES  MODALIDADE "
    cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_NOMCOM  COMPETICAO "
    cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_CNPJMA  CNPJMAND "
    cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_CNPJVI  CNPJVI "
    cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_PAGANT  PAGANTES "
    cSelect += ", " + cAlsfilho + "." + cAlsfilho + "_NPAGAN  NAOPAGANTES "
    cSelect += ", " + cAlsneto  + "." + cAlsneto  + "_VLRTOT  TOTALBRUTO "
    cSelect += ", " + cAlsneto  + "." + cAlsneto  + "_VLRCP   TRIBUTO "
    cSelect += ", " + cAlsneto  + "." + cAlsneto  + "_VLRRET  VALORRETIDO "
EndIf

If cLayout $ "R-9000"
    cSelect += " ,  " + cAlsfilho + "." + cAlsfilho + "_CODIGO  EVENTOEX "    // evento excluído
    cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRRECI  RECIBO "     // recibo
EndIf

// R-4010
If cLayout $ "R-4010"
  	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_CPF CPF"   // Numero de CPF
	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NOME NOME"   // Nome
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRBRU) VLRBRUTO" // Valor bruto total
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRIR) VLRIR"   // Valor total de IR
endif

// R-4020
If cLayout $ "R-4020"
  	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_CNPJBN CNPJ"   // Numero de CNPJ
	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NMBENE NOMEBEN"   // Nome
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRTOT) VLRTOT" // Valor total
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_BASEIR) BASEIR" // Valor base de IR
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRIR) VLRIR"   // Valor total de IR
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLCSLL) VLCSLL"   // Valor total de CSLL
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VCOFIN) VCOFIN"   // Valor total de COFINS
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRPP) VLRPP"   // Valor total de PIS	
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VAGREG) VAGREG" // Valor agregado
endif

// R-4040
If cLayout $ "R-4040|"
  	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSC NUMINSC"   // Numero de Inscrição
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRLIQ) VLRLIQUI" // Valor liquido
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_BASEIR) BASEIR" // Valor base de IR
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRIR) VLRIR"   // Valor total de IR
endif

// R-4080
If cLayout $ "R-4080|"
  	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_NRINSF NUMINSF"     // Numero de Inscrição da Fonte Pagadora
  	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_DPARTI NOME"        // Nome da Fonte Pagadora
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRBRU) VLRBRU" // Valor Bruto
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_BASEIR) BASEIR" // Valor base de IR
	cSelect += " ,  SUM(" + cAlsfilho + "." + cAlsfilho + "_VLRIR) VLRIR"   // Valor total de IR
endif

// R-1050
If cLayout $ "R-1050|"
  	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_CNPJ CNPJ"      // Numero de CNPJ
  	cSelect += " ,  " + cAliasLay + "." + cAliasLay + "_TPENTL ENTIDA"  // Entidade Ligada
endif

cSelect += " ," + cAliasLay + ".R_E_C_N_O_ RECNO " 
// FROM
cFrom += RetSqlName( cAliasLay ) + " " + cAliasLay + " "	

if cLayout $ "R-1070"
    cFrom += " LEFT JOIN " +  RetSqlName( cAlsfilho  ) + " " + cAlsfilho  + " ON "
    cFrom += cAlsfilho + "." + cAlsfilho + "_ID = " + cAliasLay + "." + cAliasLay + "_IDMUNI "
    cFrom += " AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "
elseif cLayout $ "R-2030|R-2040"
    cFrom += " LEFT JOIN " + RetSqlName( cAlsfilho ) + " " + cAlsfilho + " ON "
    cFrom += cAlsfilho + "." + cAlsfilho + "_ID =" + cAliasLay + "." + cAliasLay + "_ID "
    cFrom += " AND " + cAlsfilho + "." + cAlsfilho + "_VERSAO =" + cAliasLay + "." + cAliasLay + "_VERSAO "
    cFrom += " AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "
elseif cLayout $ "R-2055"
    cFrom += " INNER JOIN " + RetSqlName( "C1E" ) + " C1E ON "
    cFrom += " C1E.C1E_ID = " + cAliasLay + "." + cAliasLay + "_IDESTA AND C1E.C1E_ATIVO = '1' AND C1E.D_E_L_E_T_ = ' ' "
    if !Empty( cAlsfilho )
        cFrom += " LEFT JOIN " + RetSqlName( cAlsfilho ) + " " + cAlsfilho + " ON "
        cFrom += cAlsfilho + "." + cAlsfilho + "_ID =" + cAliasLay + "." + cAliasLay + "_ID "
        cFrom += " AND " + cAlsfilho + "." + cAlsfilho + "_VERSAO =" + cAliasLay + "." + cAliasLay + "_VERSAO "
        cFrom += " AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "
    endif
elseif cLayout $ "R-3010"
    cFrom += " LEFT JOIN " + RetSqlName( cAlsfilho ) + " " + cAlsfilho + " ON "
    cFrom += cAlsfilho + "." + cAlsfilho + "_ID =" + cAliasLay + "." + cAliasLay + "_ID "
    cFrom += " AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "
    cFrom += " LEFT JOIN " + RetSqlName( cAlsneto ) + " " + cAlsneto + " ON "
    cFrom += cAlsneto + "." + cAlsneto + "_ID =" + cAliasLay + "." + cAliasLay + "_ID "
    cFrom += " AND " + cAlsneto + "." + cAlsneto + "_VERSAO =" + cAliasLay + "." + cAliasLay + "_VERSAO "
    cFrom += " AND " + cAlsneto + ".D_E_L_E_T_ = ' ' "
elseif cLayout $ "R-9000"
    cFrom += " LEFT JOIN " + RetSqlName( cAlsfilho ) + " " + cAlsfilho + " ON "
    cFrom += cAlsfilho + "." + cAlsfilho + "_ID =" + cAliasLay + "." + cAliasLay + "_IDTPEV "
    cFrom += " AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "

elseif cLayout $ "R-4010|R-4020|R-4040|R-4080"
    cFrom += " LEFT JOIN " + RetSqlName( cAlsfilho ) + " " + cAlsfilho + " ON "
    cFrom += cAlsfilho + "." + cAlsfilho + "_ID =" + cAliasLay + "." + cAliasLay + "_ID "
	cFrom += " AND " + cAlsfilho + "." + cAlsfilho + "_FILIAL = " + cAliasLay + "." + cAliasLay + "_FILIAL ""
	cFrom += " AND " + cAlsfilho + "." + cAlsfilho + "_VERSAO =" + cAliasLay + "." + cAliasLay + "_VERSAO "
    cFrom += " AND " + cAlsfilho + ".D_E_L_E_T_ = ' ' "

endif

if lIdCheck
	cCpoId := iif( cLayout == 'R-1070', '_NUMPRO', '_ID')
	cFrom += " INNER JOIN " + oTableId:GetRealName() + " QRYTMP ON QRYTMP.IDCHECKED = " + cAliasLay + "." + cAliasLay + cCpoId
endif

cWhere += cAliasLay + "." + cAliasLay + "_FILIAL = '" + xFilial(cAliasLay) + "'"
cWhere += "  AND " + cAliasLay + ".D_E_L_E_T_ = ' ' " 
cWhere += "  AND " + cAliasLay + "." + cAliasLay + "_ATIVO = '1' "

If lAll
	cWhere += "  AND " + cAliasLay + "." + cAliasLay + "_STATUS IN (' ','0','1') "
endif	

If cLayout $ "R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-2098|R-2099|R-9000|R-4010|R-4020|R-4040|R-4080|R-4099"
    cWhere += " AND " + cAliasLay + "." + cAliasLay + "_PERAPU = '" + STRTRAN(cPerIni,"/","") + "'"
    if cLayout $ "R-2030|R-2040|R-2055" 
        cWhere += " GROUP BY " + cAliasLay + "." + cAliasLay + "_FILIAL "
        cWhere += ", " + cAliasLay + "." + cAliasLay + "_STATUS "
        If  cLayout $ "R-2055" 
            cWhere += ", " + cAliasLay + "." + cAliasLay + "_NRINSC "
            cWhere += ", " + cAliasLay + "." + cAliasLay + "_NRINSP "
            cWhere += ", " + cAliasLay + "." + cAliasLay + "_TPINSP "
            cWhere += ", " + cAliasLay + "." + cAliasLay + "_IDESTA "
			cWhere += ", " + cAliasLay + "." + cAliasLay + "_DPARTI "
            cWhere += ", C1E.C1E_FILTAF "
        Else
            cWhere += ", " + cAliasLay + "." + cAliasLay + "_NRINSC "
        Endif
        cWhere += ", " + cAliasLay + "." + cAliasLay + "_ID "
        cWhere += ", " + cAliasLay + ".R_E_C_N_O_ " 
    endif
EndIf
// R-4010
If cLayout $ "R-4010|"
	cWhere += " GROUP BY " + cAliasLay + "." + cAliasLay + "_FILIAL "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_ID "
	cWhere += ", " + cAliasLay + "." + cAliasLay + "_STATUS "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_CPF "
	cWhere += ", " + cAliasLay + "." + cAliasLay + "_NOME "
	cWhere += ", " + cAliasLay + ".R_E_C_N_O_ "
EndIf

// R-4020
If cLayout $ "R-4020|"
	cWhere += " GROUP BY " + cAliasLay + "." + cAliasLay + "_FILIAL "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_ID "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_STATUS "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_CNPJBN "
	cWhere += ", " + cAliasLay + "." + cAliasLay + "_NMBENE "
	cWhere += ", " + cAliasLay + ".R_E_C_N_O_ "
EndIf

If cLayout == "R-4040"
	cWhere += " GROUP BY " + cAliasLay + "." + cAliasLay + "_FILIAL "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_ID "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_STATUS "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_NRINSC "
	cWhere += ", " + cAliasLay + ".R_E_C_N_O_ "
EndIf

If cLayout == "R-4080"
	cWhere += " GROUP BY " + cAliasLay + "." + cAliasLay + "_FILIAL "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_ID "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_STATUS "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_NRINSF "
    cWhere += ", " + cAliasLay + "." + cAliasLay + "_DPARTI "
	cWhere += ", " + cAliasLay + ".R_E_C_N_O_ "
EndIf

If nRegIni > 0
	cWhere		+= " ) TAB "
	cWherePage	:= " WHERE LINE_NUMBER BETWEEN " + cValTochar(nRegIni) + " AND " + cValTochar(nRegFim) + " "
EndIf

if cLayout $ "R-1000" .and. !empty(cNrInsc)
    cWhere += " AND " + cAliasLay + "." + cAliasLay + "_NRINSC = '" + cNrInsc + " '"  
endIf

if cLayout $ "R-9000"
    cWhere += " AND " + cAliasLay + "." + cAliasLay + "_STATUS IN (' ','0','1','2','3','4')"  
endIf

cSelectQry :=  "%" + cSelectPage + cSelect + "%" 
cFrom   :=  "%" +   cFrom   +   "%"
cWhereQry  :=  "%" +   cWhere  + cWherePage 

if cLayout $ "R-4010|R-4020"
	cWhereQry += ' ORDER BY STATUS '
endIf

cWhereQry += "%"

BeginSql Alias cAlias
    SELECT DISTINCT
    %Exp:cSelectQry% 
    FROM 
    %Exp:cFrom%
    WHERE
    %Exp:cWhereQry% 
EndSql

If nRegIni > 0

	If cLayout $ "R-4010|R-4020|R-4040|R-4080|R-1050"
		lHasNext := HasNext( cFields, cSelect, cFrom, cWhere, nRegFim )
	EndIf

EndIf
Return(cAlias) 

//---------------------------------------------------------------------
/*/{Protheus.doc} Ws004Docs

Devolve a quantidade de documentos dos eventos apurados do tipo: pendentes de transmissão
                                    Ou
Se lTotal = .f., retorna o detalhamento dos documentos a serem transmitidos

@Author		henrique.pereira
@Since		25/04/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
static function Ws004Docs(cID, cAlsChild, aAlsAuxCh, lTotal, cEvento, cAlsPai)

local cSelect   as character
local cSelRec   as character
local cFrom     as character
local cFromRec  as character
local cWhere    as character
local cWheRec   as character
local cAlsBegin as character
local nTotal    as numeric

default nTotal  := 0
default lTotal  := .f.
default cEvento := ''
default cAlsPai := ""

  
cSelect     :=  ''
cSelRec     :=  ''
cFrom       :=  ''
cFromRec    :=  ''
cWhere      :=  ''
cWheRec     :=  ''
cAlsBegin   :=  getnextalias()
nTotal      :=  0

If lTotal
    cSelect :=  "COUNT(*) AS TOTAL"

    cFrom   :=  RetSqlName(cAlsChild) + " " + cAlsChild

ElseIf cEvento $ "R-1070"
    cSelect += aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_CODSUS AS CODSUSP,"
    cSelect += aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_DTDEC AS DECISIONDATE,"
    cSelect += aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_INDDEP AS DEPINDICATOR,"
    cSelect += aAlsAuxCh[CHILD2] + "." + aAlsAuxCh[CHILD2] + "_DESCRI AS INDICSUSP"

    cFrom   :=  RetSqlName(cAlsChild) + " " + cAlsChild

    cFrom  += " INNER JOIN " + RetSqlName(aAlsAuxCh[CHILD1]) + " " + aAlsAuxCh[CHILD1] + " ON "
    cFrom  += aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_FILIAL = " + cAlsChild +'.'+cAlsChild + "_FILIAL"
    cFrom  += " AND " + aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_ID = " + cAlsChild +'.'+cAlsChild + "_ID"
    cFrom  += " AND " + aAlsAuxCh[CHILD1] + ".D_E_L_E_T_ = ' '"

    cFrom  += " INNER JOIN " + RetSqlName(aAlsAuxCh[CHILD2]) + " " + aAlsAuxCh[CHILD2] + " ON "
    cFrom  += aAlsAuxCh[CHILD2] + "." + aAlsAuxCh[CHILD2] + "_FILIAL = '" + xFilial(aAlsAuxCh[CHILD2]) + "'"
    cFrom  += " AND " + aAlsAuxCh[CHILD2] + "." + aAlsAuxCh[CHILD2] + "_ID = " + aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_INDDEC"
    cFrom  += " AND " + aAlsAuxCh[CHILD2] + ".D_E_L_E_T_ = ' '"

ElseIf cEvento $ "R-2010|R-2020"
    cSelect := cAlsChild +'.'+cAlsChild + "_FILIAL  AS FILIAL, "
    cSelect += cAlsChild +'.'+cAlsChild + "_NUMFAT  AS NUMFAT, "
    cSelect += cAlsChild +'.'+cAlsChild + "_SERIE   AS SERIE, "
    cSelect += cAlsChild +'.'+cAlsChild + "_NUMDOC  AS NUMDOC, "
    cSelect += cAlsChild +'.'+cAlsChild + "_DTEMIS  AS DATAEMISSAO, "

    if cEvento == 'R-2010'
        cSelect += cAlsChild +'.'+cAlsChild + "_VLBRUT  AS VALORBRUTO, "
    elseif cEvento == 'R-2020
        cSelect += cAlsChild +'.'+cAlsChild + "_VLRBRU  AS VALORBRUTO, "
    endif

    cSelect += aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_CODSER AS CODSER,"
    cSelect += aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_DTPSER AS DESCSER,"
    cSelect += aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_VLRBAS AS VLRBAS,"
    cSelect += aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_VLRRET AS VLRRET,"
    cSelect += cAlsChild + '.' + cAlsChild + "_OBSERV  AS OBSERVACAO "

    cFrom   :=  RetSqlName(cAlsChild) + " " + cAlsChild

    cFrom  += " INNER JOIN " + RetSqlName(aAlsAuxCh[CHILD1]) + " " + aAlsAuxCh[CHILD1] + " ON "
    cFrom  += aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_FILIAL = '" + xFilial(aAlsAuxCh[CHILD1]) + "'"
    cFrom  += " AND " + aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_ID = '" + cID + "'"
    cFrom  += " AND " + aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_VERSAO = " + cAlsChild + "." + cAlsChild + "_VERSAO"
    cFrom  += " AND " + aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_NUMDOC = " + cAlsChild + "." + cAlsChild + "_NUMDOC"
    cFrom  += " AND " + aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_SERIE = " + cAlsChild + "." + cAlsChild + "_SERIE"
    cFrom  += " AND " + aAlsAuxCh[CHILD1] + "." + aAlsAuxCh[CHILD1] + "_NUMFAT = " + cAlsChild + "." + cAlsChild + "_NUMFAT"
    cFrom  += " AND " + aAlsAuxCh[CHILD1] + "." + "D_E_L_E_T_ = ' '"

ElseIf cEvento $ "R-2030|R-2040"
    cSelect := cAlsChild +'.'+cAlsChild + "_FILIAL  AS FILIAL, "   //filial

    if cEvento == "R-2030"
        cSelect += cAlsChild +'.'+cAlsChild + "_CNPJOR  AS CNPJOR, "   //cnpj de origem do recurso
		If TAFColumnPos("V1G_IDEXTE")
			cSelect += cAlsChild +'.'+cAlsChild + "_IDEXTE AS IDEXTE, "   //ID Participante residente exterior
		Else
			cSelect += " ' ' AS IDEXTE, "
		EndIf
    else
        cSelect += cAlsChild +'.'+cAlsChild + "_CNPJAD  AS CNPJAD, "   //cnpj da associação desportiva
    endif

    cSelect += cAlsChild +'.'+cAlsChild + "_VLREPA  AS VLREPA, "   //valor repasse
    cSelect += cAlsChild +'.'+cAlsChild + "_VLRET   AS VLBRUT, "   //valor bruto
    cSelect += cAlsChild +'.'+cAlsChild + "_VLNRET  AS VLRECP, "  //valor da retenção
    cSelect += cAlsChild +'.'+cAlsChild + "_ID  AS ID   "  //id

    cFrom   := RetSqlName(cAlsChild) + " " + cAlsChild

ElseIf cEvento $ "R-2050"
    cSelect := cAlsChild +'.'+cAlsChild + "_FILIAL  AS FILIAL, "
    cSelect := cAlsChild +'.'+cAlsChild + "_IDCOM AS INDCOM, "
    cSelect += cAlsChild +'.'+cAlsChild + "_VRECBR  AS RECBRU "

    cFrom   :=  RetSqlName(cAlsChild) + " " + cAlsChild

ElseIf cEvento $ "R-2055"

    cSelect += cAlsChild +'.'+cAlsChild + "_FILIAL AS FILIAL, "
    cSelect += cAlsChild +'.'+cAlsChild + "_NUMDOC AS NUMDOC, "
    cSelect += cAlsChild +'.'+cAlsChild + "_NUMFAT AS NUMFAT, "
    cSelect += cAlsChild +'.'+cAlsChild + "_SERIE  AS SERIE, "
    cSelect += cAlsChild +'.'+cAlsChild + "_CHVNF  AS CHVNF, "
    cSelect += cAlsChild +'.'+cAlsChild + "_IDFAT  AS IDFAT, "
    cSelect += cAlsChild +'.'+cAlsChild + "_DTEMIS AS DTEMIS, "
    cSelect += cAlsChild +'.'+cAlsChild + "_VBRTPR AS VBRTPR, "
    cSelect += cAlsChild +'.'+cAlsChild + "_VCPPR  AS VLRCONTR, "
    cSelect += cAlsChild +'.'+cAlsChild + "_VRATPR AS GILRAT, "
    cSelect += cAlsChild +'.'+cAlsChild + "_VSENPR AS SENAR "
    
    cFrom   :=  RetSqlName(cAlsChild) + " " + cAlsChild

ElseIf cEvento $ "R-2060"
    cSelect := cAlsChild +'.'+cAlsChild + "_FILIAL  AS FILIAL,  "   //filial
    cSelect := cAlsChild +'.'+cAlsChild + "_CDATIV  AS CODATIV, "   //código da atividade
    cSelect += cAlsChild +'.'+cAlsChild + "_DESATV  AS CDSATIV, "   //descrição da atividade
    cSelect += cAlsChild +'.'+cAlsChild + "_VLBTAT  AS VLBATIV, "   //valor da atividade
    cSelect += cAlsChild +'.'+cAlsChild + "_VLBCPR  AS VBCCPRB, "   //valor base da cpbr
    cSelect += cAlsChild +'.'+cAlsChild + "_VLARBT  AS VLRAJU,  "   //valor do ajuste
    cSelect += cAlsChild +'.'+cAlsChild + "_VLERBT  AS VLREXC,  "   //valor da exclusão do ajuste
    cSelect += cAlsChild +'.'+cAlsChild + "_ALQCON  AS ALQATIV, "   //aliquota da atividade
    cSelect += cAlsChild +'.'+cAlsChild + "_CPRBAP  AS VLRCPRBAP"   //valor da exclusão do ajuste"

    cFrom   :=  RetSqlName(cAlsChild) + " " + cAlsChild

ElseIf cEvento $ "R-3010"
    cSelect := "'INGRESSO' AS RECEITA, "                                //receita do tipo ingresso
    cSelect += cAlsChild +'.'+cAlsChild + "_TPINGR  AS TIPORECEITA, "   //tipo do ingresso
    cSelect += cAlsChild +'.'+cAlsChild + "_DESCIN  AS DESCRECEITA, "   //descricao do ingresso
    cSelect += cAlsChild +'.'+cAlsChild + "_QTDING  AS QTDVENDA, "      //quantidade de ingressos a venda
    cSelect += cAlsChild +'.'+cAlsChild + "_QTDIVE  AS QTDVENDIDO, "    //quantidade de ingressos vendidos
    cSelect += cAlsChild +'.'+cAlsChild + "_QTDIDE  AS QTDDEVOLVIDO,  " //quantidade de ingressos devolvidos
    cSelect += cAlsChild +'.'+cAlsChild + "_PRECOI  AS VALOR,  "        //valor unitario do ingresso
    cSelect += cAlsChild +'.'+cAlsChild + "_VLRTOT  AS TOTAL "          //total do ingresso
    cSelRec := "'OUTRAS RECEITAS' AS RECEITA, "                         //receita do tipo outras receitas
    cSelRec += aAlsAuxCh[CHILD1] +'.'+aAlsAuxCh[CHILD1] + "_TPRECE  AS TIPORECEITA, "   //tipo de outras receitas
    cSelRec += aAlsAuxCh[CHILD1] +'.'+aAlsAuxCh[CHILD1] + "_DESREC  AS DESCRECEITA, "   //descricao de outras receitas
    cSelRec += "'0' AS QTDVENDA, "                                                      //quantidade de outras receitas a venda
    cSelRec += "'0' AS QTDVENDIDO, "                                                    //quantidade de outras receitas vendidos
    cSelRec += "'0' AS QTDDEVOLVIDO,  "                                                 //quantidade de outras receitas devolvidos
    cSelRec += aAlsAuxCh[CHILD1] +'.'+aAlsAuxCh[CHILD1] + "_VLRREC  AS VALOR,  "  //valor unitario de outras receitas
    cSelRec += aAlsAuxCh[CHILD1] +'.'+aAlsAuxCh[CHILD1] + "_VLRREC  AS TOTAL "   //total de outras receitas
    
    cFrom       :=  RetSqlName(cAlsChild) + " " + cAlsChild
    cFromRec    :=  RetSqlName(aAlsAuxCh[CHILD1]) + " " + aAlsAuxCh[CHILD1]
EndIf

If !Empty(cAlsPai) .and. cEvento != "R-1070"
    cFrom   += " INNER JOIN " + RetSqlName(cAlsPai) + " " + cAlsPai + " ON "
    cFrom   += cAlsPai + '.' + cAlsPai + "_FILIAL = " + cAlsChild + '.' + cAlsChild + "_FILIAL  AND "
    cFrom   += cAlsPai + '.' + cAlsPai + "_ID = " + cAlsChild + '.' + cAlsChild + "_ID AND "
    cFrom   += cAlsPai + '.' + cAlsPai + "_VERSAO = " + cAlsChild + '.' + cAlsChild + "_VERSAO AND "
    cFrom   += cAlsPai + '.' + cAlsPai + "_ATIVO = '1' AND "
    cFrom   += cAlsPai + '.' + "D_E_L_E_T_ = ' ' "
EndIf

cWhere  :=  cAlsChild + ".D_E_L_E_T_ = ' ' "
If cEvento == "R-1070"
    cWhere  +=  " AND " + cAlsChild + '.'+ cAlsChild + "_ATIVO = '1' "    
EndIf
cWhere  +=  " AND " + cAlsChild + '.'+ cAlsChild + "_FILIAL = '" + xFilial(cAlsChild) + "'"

If !cEvento == 'R-1070' 
    cWhere  +=  " AND " + cAlsChild + '.'+ cAlsChild + "_ID = '" + cID +"'"
Else
    cWhere  +=  " AND " + cAlsChild + '.'+ cAlsChild + "_NUMPRO = '" + cID +"'"
EndIf

cWhere  +=  " AND " + cAlsChild + ".D_E_L_E_T_ = ' '"

if cEvento == "R-3010"
    If !Empty(cAlsPai)
        cFromRec   += " INNER JOIN " + RetSqlName(cAlsPai) + " " + cAlsPai + " ON "
        cFromRec   += cAlsPai + '.' + cAlsPai + "_FILIAL = " + aAlsAuxCh[CHILD1] + '.' + aAlsAuxCh[CHILD1] + "_FILIAL  AND "
        cFromRec   += cAlsPai + '.' + cAlsPai + "_ID = " + aAlsAuxCh[CHILD1] + '.' + aAlsAuxCh[CHILD1] + "_ID AND "
        cFromRec   += cAlsPai + '.' + cAlsPai + "_VERSAO = " + aAlsAuxCh[CHILD1] + '.' + aAlsAuxCh[CHILD1] + "_VERSAO AND "
        cFromRec   += cAlsPai + '.' + cAlsPai + "_ATIVO = '1' AND "
        cFromRec   += cAlsPai + '.' + "D_E_L_E_T_ = ' ' "
    EndIf
    cWheRec :=  aAlsAuxCh[CHILD1] + ".D_E_L_E_T_ = ' ' "
    cWheRec +=  " AND " + aAlsAuxCh[CHILD1] + '.'+ aAlsAuxCh[CHILD1] + "_FILIAL = '" + xFilial(aAlsAuxCh[CHILD1]) + "'"
    cWheRec +=  " AND " + aAlsAuxCh[CHILD1] + '.'+ aAlsAuxCh[CHILD1] + "_ID = '" + cID +"'"
    cWheRec +=  " AND " + aAlsAuxCh[CHILD1] + ".D_E_L_E_T_ = ' '"
EndIf

cSelect     :=  "%" + cSelect   + "%"
cSelRec     :=  "%" + cSelRec   + "%"
cFrom       :=  "%" + cFrom     + "%"
cFromRec    :=  "%" + cFromRec  + "%"
cWhere      :=  "%" + cWhere    + "%"    
cWheRec     :=  "%" + cWheRec   + "%"    

If cEvento == "R-3010"
    beginsql Alias cAlsBegin  
        SELECT
            %exp:cSelect%  
        FROM
            %exp:cFrom%
        WHERE
            %exp:cWhere% 

        UNION ALL

        SELECT
            %exp:cSelRec%  
        FROM
            %exp:cFromRec%
        WHERE
            %exp:cWheRec% 
    endsql
Else
    beginsql Alias cAlsBegin  
        SELECT
            %exp:cSelect%  
        FROM
            %exp:cFrom%
        WHERE
            %exp:cWhere% 
    endsql
EndIf

(cAlsBegin)->(DbGoTop())

if !(cAlsBegin)->(eof()) .and. lTotal 
    nTotal  :=  (cAlsBegin)->TOTAL
endif

if lTotal 
    (cAlsBegin)->(DbCloseArea())
endif

return (iif(lTotal, nTotal, cAlsBegin))

//---------------------------------------------------------------------
/*/{Protheus.doc} AlsChld
Retorna o alias filho referente aos documentos existentes na tabelas espelho

@Author		henrique.pereira
@Since		25/04/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function AlsChld(cEvento)
local cAlsRet   as character

cAlsRet     :=  ''

do case
    case cEvento == 'R-1070'
        cAlsRet  := 'T9V'
    case cEvento == 'R-2010'
        cAlsRet  := 'T96'
    case cEvento == 'R-2020'
        cAlsRet  := 'CRO'
    case cEvento == 'R-2030'
        cAlsRet  := 'V1G'
    case cEvento == 'R-2040'
        cAlsRet  := 'V1J'
    case cEvento == 'R-2050'
        cAlsRet  := 'V1E'
    case cEvento == 'R-2060'
        cAlsRet  := 'V0T'
    case cEvento == 'R-3010'
        cAlsRet  := 'V0O'
    case cEvento == 'R-2055'
        cAlsRet  := 'V5V'
	case cEvento == 'R-4010'
        cAlsRet  := 'V5E'
	case cEvento == 'R-4020'
        cAlsRet  := 'V4S'
	case cEvento == 'R-4040'
        cAlsRet  := 'V4P'
	case cEvento == 'R-4080'
        cAlsRet  := 'V99'
endcase

return(cAlsRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} AlsAuxCh
Retorna o alias auxiliar referente aos documentos existentes na tabelas espelho

@Author		Leticia Campos da Silva
@Since		30/10/2019
@Version	1.0
/*/
//---------------------------------------------------------------------

Static Function AlsAuxCh(cEvento)
local aAlsRet   as array

default cEvento := ''

aAlsRet     := {}

do case
    case cEvento == 'R-1070'
        aAdd(aAlsRet, {'T5L', 'C8S'})
    case cEvento == 'R-2010'
        aAdd(aAlsRet, {'T97'})
    case cEvento == 'R-2020'
        aAdd(aAlsRet, {'T9Y'})
    case cEvento == 'R-3010'
        aAdd(aAlsRet, {'V0P'})
endcase

return(aAlsRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} AlsPai
Retorna o alias Pai referente a cada evento das tabelas espelho

@Author		Karen e Rafael
@Since		23/02/2021
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function AlsPai(cEvento)
local cAlsRet   as character

cAlsRet     :=  ''

do case
    case cEvento == 'R-1070'
        cAlsRet  := 'T9V'
    case cEvento == 'R-2010'
        cAlsRet  := 'T95'
    case cEvento == 'R-2020'
        cAlsRet  := 'CMN'
    case cEvento == 'R-2030'
        cAlsRet  := 'C9B'
    case cEvento == 'R-2040'
        cAlsRet  := 'T9K'
    case cEvento == 'R-2050'
        cAlsRet  := 'V1D'
    case cEvento == 'R-2060'
        cAlsRet  := 'V0S'
    case cEvento == 'R-3010'
        cAlsRet  := 'V0L'
    case cEvento == 'R-2055'
        cAlsRet  := 'V5S'
	case cEvento == 'R-4010'
        cAlsRet  := 'V4Q'
	case cEvento == 'R-4020'
        cAlsRet  := 'V5C'
	case cEvento == 'R-4040'
        cAlsRet  := 'V4N'
	case cEvento == 'R-4080'
        cAlsRet  := 'V97'
endcase

return(cAlsRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} TafIndCom
Retorna o indicativo de comercialização correspondente

@Author		Leticia Campos da Silva
@Since		31/10/2019
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function TafIndCom(cIndCom)
local cRet as character

do case
    case cIndCom == '1'
        cRet := '1 - Comercialização da Produção por Prod. Rural PJ/Agroindústria, exceto para entidades executoras do PAA.'
    case cIndCom == '7'
        cRet := '7 - Comercialização da Produção com Isenção de Contribuição Previdenciária, de acordo com a Lei n° 13.606/2018.'
    case cIndCom == '8'
        cRet := '8 - Comercialização da Produção para Entidade do Programa de Aquisição de Alimentos - PAA.'
    case cIndCom == '9'
        cRet := '9 - Comercialização direta da Produção no Mercado Externo.'
endcase  

return(cRet)

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} metodo POST apurReinf
invoca a apuração do determinado evento

@author Henrique Fabiano Pateno Pereira
@since 23/04/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD POST transmitionReinf PATHPARAM companyId, event, period, customerProviders WSREST WSTAF004

Local aEvents		as array
Local aRegRec		as array
Local aRetorno		as array
Local aRetErro		as array
Local aCompany		as array
Local cAliasTmp		as character
Local cIDEnt		as character
Local cAlsFilho		as character
Local cMsgRet		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local nTmItems		as numeric
Local lSucesso		as logical
Local lAll			as logical
Local lRet			as logical
Local lAut          as logical
Local oRequest		as object
Local oResponse		as object
Local oTableID		as object
Local cCode			as character
Local cUser			as character
Local cModule		as character
Local cRoutine		as character

aEvents		:=	{}
aRegRec		:=	{}
aRetorno	:=	{}
aRetErro	:=	{}
aCompany	:=	{}
cAliasTmp	:=	""
cIDEnt		:=	""
cAlsFilho	:=	""
cMsgRet		:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
nTmItems	:=	0
lSucesso	:=	.T.
lAll		:=	.F.
lRet		:=	.T.
lAut        :=  .F.
oRequest	:=	JsonObject():New()
oResponse	:=	JsonObject():New()
oTableID	:=	Nil
cCode		:= "LS006"
cUser		:= ""
cModule		:= "84"
cRoutine 	:= "TAFReinf"+StrTran(self:event,"-", "")+"BtnTrans"

self:SetContentType( "application/json" )

If Valtype(self:Getheader("Content-Advpr")) == 'U'
	lAut := .F.
Else
	lAut := iif(self:Getheader("Content-Advpr")=='false',.F.,.T.)
Endif

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
			aEvents := TAFRotinas( self:event, 4, .F., 5 )

			If FindFunction( "FWLSPutAsyncInfo" )
				FWLSPutAsyncInfo( cCode, cUser, cModule, cRoutine )
				TAFConOut( "-> " +cRoutine,1,.F.,"LSTAF")
			EndIf 

			If Len( aEvents ) > 0
				cIDEnt := TAFGFilMatriz()[6]

				oRequest:FromJSON( self:GetContent() )

			 	If self:event $ "R-1070|R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-3010|R-9000|R-4010|R-4020|R-4040|R-4080|R-1050"
					nTmItems := Len( oRequest["transmissionItems"] )

					If nTmItems == 1
						lAll := oRequest["transmissionItems"][1]["id"] == "All"
					EndIf
				EndIf

				//--------------------------------------------------------------------
				// Trata a variável cIDTrans concatenando os CNPJs para filtro dos Eventos R-1070, R-2010, R-2020, R-2030, R-2050, R-2060 e R-3010 para transnmissão
				//--------------------------------------------------------------------
				If self:event $ "R-1070|R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-3010|R-9000|R-4010|R-4020|R-4040|R-4080|R-1050" 
					//Retorna Tabela Temporária com os IDs selecionados para transmissão
					If !lAll
						oTableID := WSProviders( oRequest["transmissionItems"] )
					EndIf
				EndIf

				//--------------------------------------------------------------------
				// Executa a query dos registros que devem ser transmitidos
				//--------------------------------------------------------------------
				If self:event == "R-1070"
					cAlsFilho := "C07"
				ElseIf self:event == "R-2020"
					cAlsFilho := "C1H"
				ElseIf self:event == "R-2030"
					cAlsFilho := "V1G"
				ElseIf self:event == "R-2040"
					cAlsFilho := "V1J"
				ElseIf self:event == "R-3010"
					cAlsFilho := "T9G"
				ElseIf self:event == "R-9000"
					cAlsFilho := "T9B"
				ElseIf self:event == "R-4010"
					cAlsFilho := "V5E"
				ElseIf self:event == 'R-4020'
       				cAlsFilho  := 'V4S'
				ElseIf self:event == 'R-4040'
        			cAlsFilho  := 'V4P'
				ElseIf self:event == 'R-4080'
        			cAlsFilho  := 'V99'
				
				Else
					cAlsFilho := ""
				EndIf

				cAliasTmp := WS004Event( aEvents, self:period, cAlsFilho, oTableID, lAll )

				//Proteção para não ocorrer erro no R-1000, já que o objeto não é criado para ele
				If self:event $ "R-1070|R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-3010|R-9000|R-4010|R-4020|R-4040|R-4080|R-1050"
					If !lAll
						oTableID:Delete() //Fecho a Tabela Temporária
					EndIf
				EndIf

				//--------------------------------------------------------------------
				// Com base na query acima, alimenta o array aRegRec para a função TAFProc9TSS executar a transmissão
				//--------------------------------------------------------------------
				aRegRec := WSTAFRecno( cAliasTmp )

				If self:event $ "R-1000|R-1070|R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-2099|R-2098|R-3010|R-9000|R-4010|R-4020|R-4040|R-4080|R-4099|R-1050" 
					If Len( aRegRec ) > 0
						aRetorno := TAFProc9TSS( .T.,aEvents,Nil,Nil,Nil,Nil,Nil,@cMsgRet,Nil,Nil,Nil,Nil,Nil,aRegRec,,.T.,@aRetErro,lAut )
						lSucesso := aRetorno[1][1]

						oResponse["status"] := lSucesso

						If !lSucesso
							TAFMErrT0X( aRetorno, .F. ) //Grava erros de transmissão com origem na camada TAF/TSS

							oResponse["type"] := RetType( aRetErro )

							If Empty( EncodeUTF8( aRetorno[1][2] ) )
								oResponse["message"] := EncodeUTF8( cMsgRet )
							Else
								oResponse["message"] := EncodeUTF8( aRetorno[1][2] )
							EndIf
						EndIf

						lRet := .T.
						self:SetResponse( oResponse:ToJson() )
					Else
						lRet := .F.
						SetRestFault( 400, EncodeUTF8( "Não existem registros pendentes para transmissão" ) )
					EndIf
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Evento: " + self:event + " não encontrado" ) )
			EndIf
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oRequest )
FreeObj( oResponse )

oRequest	:=	Nil
oResponse	:=	Nil

DelClassIntF()

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} metodo GET invoiceDetail
Retorna o detalhe dos documentos existentes para transmissão dos eventos R-2010, R-2020 e R-2050

@author Henrique Fabiano Pateno Pereira/Leticia Campos da Silva
@since 23/04/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET invoiceDetail QUERYPARAM companyId, id, event WSREST WSTAF004

Local aAlsAuxCh		as array
Local aCompany		as array
Local cAlias		as character
Local cAlsPai		as character
Local cAlsChild		as character
Local cCNPJ			as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local nTAnalitc		as numeric
Local lFatura		as logical
Local lRet			as logical
Local oResponse		as object

//-----------------------------------------------
// Inicialização variáveis do tipo array
//-----------------------------------------------
aAlsAuxCh	:=	{}
aCompany	:=	{}

//-----------------------------------------------
// Inicialização variáveis do tipo string
//-----------------------------------------------
cAlias		:=	""
cAlsPai		:=	""
cAlsChild	:=	""
cCNPJ		:=	""
cEmpRequest	:=	""
cFilRequest	:=	""

//-----------------------------------------------
// Inicialização variáveis do tipo numérico
//-----------------------------------------------
nTAnalitc	:=	0

//-----------------------------------------------
// Inicialização variáveis do tipo booleana
//-----------------------------------------------
lFatura		:=	.F.
lRet		:=	.T.

//-----------------------------------------------
// Inicialização variáveis do tipo object
//-----------------------------------------------
oResponse	:=	JsonObject():New()

self:SetContentType( "application/json" )

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:id == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Identificador do Registro não informado no parâmetro 'id'." ) )
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
			cAlsChild	:=	AlsChld( self:event )
			aAlsAuxCh	:=	AlsAuxCh( self:event )
			cAlsPai		:=	AlsPai( self:event )

			cAlias := WS004Docs( self:id, cAlsChild, aAlsAuxCh, .F., self:event, cAlsPai )

			( cAlias )->( DBGoTop() )

			oResponse["invoices"] := {}

			While ( cAlias )->( !Eof() )
				aAdd( oResponse["invoices"], JsonObject():New() )

				nTAnalitc := Len( oResponse["invoices"] )

				If self:event $ "R-1070"
					//Código da Suspensão
					oResponse["invoices"][nTAnalitc]["suspensionCode"] := ( cAlias )->CODSUSP

					//Indicativo da Suspensão
					oResponse["invoices"][nTAnalitc]["suspensionIndicator"] := AllTrim( EncodeUTF8( ( cAlias )->INDICSUSP ) )

					//Data da Decisão
					oResponse["invoices"][nTAnalitc]["decisionDate"] := SToD( ( cAlias )->DECISIONDATE )

					//Indicativo de Depósito
					oResponse["invoices"][nTAnalitc]["depositIndicator"] := ( cAlias )->DEPINDICATOR
				ElseIf self:event $ "R-2010|R-2020"
					lFatura := !Empty( ( cAlias )->NUMFAT )

					//Tipo Nota ou Fatura
					oResponse["invoices"][nTAnalitc]["type"] := Iif( lFatura, "FAT", "NFS" )

					//Número da Nota ou Fatura
					oResponse["invoices"][nTAnalitc]["invoice"] := Iif( lFatura, ( cAlias )->NUMFAT, ( cAlias )->NUMDOC )

					//Série da Nota ou Fatura
					oResponse["invoices"][nTAnalitc]["invoiceSeries"] := Iif( lFatura, 0, ( cAlias )->SERIE )

					//Código Serviço
					oResponse["invoices"][nTAnalitc]["serviceCode"] := ( cAlias )->CODSER + "-" + ( cAlias )->DESCSER

					//Data de Emissão da Nota ou Fatura
					oResponse["invoices"][nTAnalitc]["issueDate"] := SToD( ( cAlias )->DATAEMISSAO )

					//Valor Bruto
					oResponse["invoices"][nTAnalitc]["grossValue"] := ( cAlias )->VALORBRUTO

					//Base de Cálculo
					oResponse["invoices"][nTAnalitc]["taxBase"] := ( cAlias )->VLRBAS

					//Tributo
					oResponse["invoices"][nTAnalitc]["tax"] := ( cAlias )->VLRRET

					//Observação
					oResponse["invoices"][nTAnalitc]["note"] := AllTrim( ( cAlias )->OBSERVACAO )
				ElseIf self:event $ "R-2050"
					//Indicativo de Comercialização
					oResponse["invoices"][nTAnalitc]["typeOfTrading"] := EncodeUTF8( TAFIndCom( ( cAlias )->INDCOM ) )

					//Valor Bruto
					oResponse["invoices"][nTAnalitc]["grossValue"] := ( cAlias )->RECBRU
				ElseIf self:event $ "R-2030|R-2040"
					cCNPJ := Iif( self:event == "R-2030", ( cAlias )->CNPJOR, ( cAlias )->CNPJAD )

					//CNPJ Origem/Repasse do Recurso
					oResponse["invoices"][nTAnalitc]["branchId"] := ( cAlias )->FILIAL

					//CNPJ Origem/Repasse do Recurso
					oResponse["invoices"][nTAnalitc]["sourceTaxNumber"] := cCNPJ

					If self:event == "R-2030"
						//ID Participante residente exterior
						oResponse["invoices"][nTAnalitc]["foreignResident"] := ( cAlias )->IDEXTE
					EndIf

					//Valor Bruto
					oResponse["invoices"][nTAnalitc]["grossValue"] := ( cAlias )->VLREPA

					//Valor Retido
					oResponse["invoices"][nTAnalitc]["receivedAmount"] := ( cAlias )->VLBRUT

					//Valor Total da Retenção
					oResponse["invoices"][nTAnalitc]["totalValueOfRetentionWithSuspendedLiability"] := ( cAlias )->VLRECP

					//Item
					oResponse["invoices"][nTAnalitc]["item"] := cCNPJ

					//id
					oResponse["invoices"][nTAnalitc]["invoiceKey"] := ( cAlias )->ID
				ElseIf self:event $ "R-2055"
					//Filial
					oResponse["invoices"][nTAnalitc]["branchId"] := ( cAlias )->FILIAL

					If !Empty( ( cAlias )->NUMDOC )
						//invoiceKey
						oResponse["invoices"][nTAnalitc]["invoiceKey"] := ( cAlias )->CHVNF

						//Número Documento
						oResponse["invoices"][nTAnalitc]["invoice"] := ( cAlias )->NUMDOC

						//Tipo
						oResponse["invoices"][nTAnalitc]["typeinvoice"] := "NFS"
					Else
						//invoiceKey
						oResponse["invoices"][nTAnalitc]["invoiceKey"] := ( cAlias )->IDFAT

						//Número Fatura
						oResponse["invoices"][nTAnalitc]["invoice"] := ( cAlias )->NUMFAT

						//Tipo
						oResponse["invoices"][nTAnalitc]["typeinvoice"] := "FAT"
					EndIf

					//Série
					oResponse["invoices"][nTAnalitc]["invoiceSeries"] := ( cAlias )->SERIE

					//Data de Emissão
					oResponse["invoices"][nTAnalitc]["issueDate"] := SToD( ( cAlias )->DTEMIS )

					//Valor Bruto
					oResponse["invoices"][nTAnalitc]["grossValue"] := ( cAlias )->VBRTPR

					//Valor INSS
					oResponse["invoices"][nTAnalitc]["valueINSS"] := ( cAlias )->VLRCONTR

					//Valor GILRAT
					oResponse["invoices"][nTAnalitc]["valueGilRat"] := ( cAlias )->GILRAT

					//Valor SENAR
					oResponse["invoices"][nTAnalitc]["valueSenar"] := ( cAlias )->SENAR
				ElseIf self:event $ "R-2060"
					//Código de Atividade
					oResponse["invoices"][nTAnalitc]["activityCode"] := ( cAlias )->CODATIV + " - " + EncodeUTF8( AllTrim( ( cAlias )->CDSATIV ) )

					//Valor Bruto da Atividade
					oResponse["invoices"][nTAnalitc]["grossValue"] := ( cAlias )->VLBATIV

					//Valor Base
					oResponse["invoices"][nTAnalitc]["taxBase"] := ( cAlias )->VBCCPRB

					//Valor Adicional de Ajuste
					oResponse["invoices"][nTAnalitc]["additionalValueOfAdjustment"] := ( cAlias )->VLRAJU

					//Valor de Exclusão do Ajuste
					oResponse["invoices"][nTAnalitc]["exclusionValueOfAdjustment"] := ( cAlias )->VLREXC

					//Alíquota
					oResponse["invoices"][nTAnalitc]["aliquot"] := ( cAlias )->ALQATIV

					//Valor de Contribuição
					oResponse["invoices"][nTAnalitc]["contributionValue"] := ( cAlias )->VLRCPRBAP
				ElseIf self:event $ "R-3010"
					//Receita
					oResponse["invoices"][nTAnalitc]["income"] := ( cAlias )->RECEITA

					//Tipo
					oResponse["invoices"][nTAnalitc]["type"] := ( cAlias )->TIPORECEITA + " - " + ( cAlias )->DESCRECEITA

					//Quantidade Ingressos a Venda
					oResponse["invoices"][nTAnalitc]["saleAmount"] := ( cAlias )->QTDVENDA

					//Quantidade Ingressos Vendidos
					oResponse["invoices"][nTAnalitc]["soldAmount"] := ( cAlias )->QTDVENDIDO

					//Quantidade Ingressos Devolvidos
					oResponse["invoices"][nTAnalitc]["refundAmount"] := ( cAlias )->QTDDEVOLVIDO

					//Valor Unitário
					oResponse["invoices"][nTAnalitc]["unitaryValue"] := ( cAlias )->VALOR

					//Total
					oResponse["invoices"][nTAnalitc]["totalGrossValue"] := ( cAlias )->TOTAL
				EndIf

				( cAlias )->( DBSkip() )
			EndDo

			lRet := .T.
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

Return( lRet )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Método responsável pela consulta dos detalhes dos recursos recebidos por documento.

@author Leticia Campos
@since 28/01/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET taxDetail QUERYPARAM companyId, period, event, id, item, page, pageSize WSREST WSTAF004

Local aCompany		as array
Local cDescr        as character
Local cAlias        as character
Local cTable        as character
Local cAlsPai       as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local cIDExte       as character
Local nTAnalitc     as numeric
Local lRet			as logical
Local oResponse     as object

//-----------------------------------------------
// Inicialização variáveis do tipo array
//-----------------------------------------------
aCompany	:=	{}

//-----------------------------------------------
// Inicialização variáveis do tipo string
//-----------------------------------------------
cDescr		:=	""
cAlias		:=	""
cTable		:=	""
cAlsPai		:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
cIDExte     :=  ""

//-----------------------------------------------
// Inicialização variáveis do tipo numérico
//-----------------------------------------------
nTAnalitc	:=	0

//-----------------------------------------------
// Inicialização variáveis do tipo booleana
//-----------------------------------------------
lRet	:=	.T.

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
	SetRestFault( 400, EncodeUTF8( "Identificador do Registro não informado no parâmetro 'id'." ) )
ElseIf self:item == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "CNPJ não informado no parâmetro 'item'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			cTable	:=	Iif( self:event == "R-2030", "V1H", "V1K" )
			cAlsPai	:=	AlsPai( self:event )

			If self:event == 'R-2030'
				cIDExte := WsPartEx(self:aQueryString, 'FOREIGNRESIDENT')
			EndIf
			
			cAlias := WS004Det( self:id, cTable, self:event, self:item, cAlsPai, cIDExte )

			( cAlias )->( DBGoTop() )

			oResponse["tax"] := {}

			While ( cAlias )->( !Eof() )
				aAdd( oResponse["tax"], JsonObject():New() )

				nTAnalitc := Len( oResponse["tax"] )

				If self:event $ "R-2030|R-2040"
					If ( cAlias )->TPREPA == "1"
						cDescr := "1 - Patrocínio"
					ElseIf ( cAlias )->TPREPA == "2"
						cDescr := "2 - Licenciamento de marcas e símbolos"
					ElseIf ( cAlias )->TPREPA == "3"
						cDescr := "3 - Publicidade"
					ElseIf ( cAlias )->TPREPA == "4"
						cDescr := "4 - Propaganda"
					ElseIf ( cAlias )->TPREPA == "5"
						cDescr := "5 - Transmissão de espetáculos"
					EndIf

					//Tipo do Repasse e Descrição do Recurso
					oResponse["tax"][nTAnalitc]["typeOfTransfer"] := AllTrim( EncodeUTF8( cDescr ) )

					//Valor Bruto
					oResponse["tax"][nTAnalitc]["grossValue"] := ( cAlias )->VLBRUT

					//Valor da Retenção
					oResponse["tax"][nTAnalitc]["receivedAmount"] := ( cAlias )->VLRECP
				EndIf

				( cAlias )->( DBSkip() )
			EndDo

			lRet := .T.
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

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} Ws004Det

Retorna o detalhamento dos recursos a serem transmitidos

@Author		leticia.campos
@Since		28/01/2020
@Version	1.0
/*/
//---------------------------------------------------------------------
static function Ws004Det(cID, cAlsChild, cEvento, cCNPJ, cAlsPai, cIDExte)

local cSelect   as character
local cFrom     as character
local cWhere    as character
local cAlsBegin as character

default cID         := ''
default cAlsChild   := ''
default cEvento     := ''
default cCNPJ       := ''
default cAlsPai     := ''

cSelect     :=  ''
cFrom       :=  ''
cWhere      :=  ''
cAlsBegin   :=  getnextalias()

If cEvento $ "R-2030|R-2040"
    cSelect := cAlsChild +'.'+cAlsChild + "_FILIAL  AS FILIAL, "   //filial

    if cEvento == "R-2030"
        cSelect += cAlsChild +'.'+cAlsChild + "_CNPJOR  AS CNPJOR, "   //cnpj de origem do recurso
    else
        cSelect += cAlsChild +'.'+cAlsChild + "_CNPJAD  AS CNPJAD, "   //cnpj de origem do recurso
    endif

    cSelect += cAlsChild +'.'+cAlsChild + "_TPREPA  AS TPREPA, "   //tipo do repasse
    cSelect += cAlsChild +'.'+cAlsChild + "_DESCRE  AS DESCRE, "   //descrição
    cSelect += cAlsChild +'.'+cAlsChild + "_VLBRUT  AS VLBRUT,   "  //valor bruto
    cSelect += cAlsChild +'.'+cAlsChild + "_VLRECP  AS VLRECP   "  //valor bruto

    cFrom   := RetSqlName(cAlsChild) + " " + cAlsChild

    If !Empty(cAlsPai) 
        cFrom   += " INNER JOIN " + RetSqlName(cAlsPai) + " " + cAlsPai + " ON "
        cFrom   += cAlsPai + '.' + cAlsPai + "_FILIAL = " + cAlsChild + '.' + cAlsChild + "_FILIAL  AND "
        cFrom   += cAlsPai + '.' + cAlsPai + "_ID = " + cAlsChild + '.' + cAlsChild + "_ID AND "
        cFrom   += cAlsPai + '.' + cAlsPai + "_VERSAO = " + cAlsChild + '.' + cAlsChild + "_VERSAO AND "
        cFrom   += cAlsPai + '.' + cAlsPai + "_ATIVO = '1' AND "
        cFrom   += cAlsPai + '.' + "D_E_L_E_T_ = ' ' "
    EndIf

    cWhere  :=  cAlsChild + ".D_E_L_E_T_ = ' ' "
    cWhere  +=  " AND " + cAlsChild + '.' + cAlsChild + "_FILIAL = '" + xFilial(cAlsChild) + "'"

    if cEvento == "R-2030"
        cWhere  +=  " AND " + cAlsChild + '.' + cAlsChild + "_CNPJOR = '" + cCNPJ + "'"
		If TAFColumnPos("V1G_IDEXTE")
			cWhere  +=  " AND " + cAlsChild + '.' + cAlsChild + "_IDEXTE = '" + cIDExte + "'"
		EndIf
    else
        cWhere  +=  " AND " + cAlsChild + '.' + cAlsChild + "_CNPJAD = '" + cCNPJ + "'"
    endif

    cWhere  +=  " AND " + cAlsChild + '.' + cAlsChild + "_ID = '" + cID +"'"
EndIf

cSelect :=  "%" + cSelect + "%"
cFrom   :=  "%" + cFrom   + "%"
cWhere  :=  "%" + cWhere  + "%"    

beginsql Alias cAlsBegin  
    SELECT
        %exp:cSelect%  
    FROM
        %exp:cFrom%
    WHERE
        %exp:cWhere% 
endsql

(cAlsBegin)->(DbGoTop())

return  ( cAlsBegin )

/*/{Protheus.doc} RetType
    Retorna o tipo de erro que foi apresentado no TAFProc9.
    @type  Function
    @author José Mauro
    @since 14/07/2020
    @version version
    @param Recebe o array que vem do TAFProc9.
    @return Retorna o tipo de erro.
        1 - Erro de schema
        2 - Erro para se conectar no TSS
        3 - Erro de predecessão.
    /*/
Static Function RetType(aRetorno)
Local nType as numeric
Local nX    as numeric

nX    := 0
nType := 0

For nX := 1 to Len(aRetorno)
    if aRetorno[nX]
        nType :=  nX
    EndIf
Next nX

Return nType

//---------------------------------------------------------------------
/*/{Protheus.doc} deleteEvent
Gera o evento de exclusão do registro selecionado em cada card (R-2010, R-2020,R-2030, R-2040, R-2050, R-2055, R-2060, R-3010 )

@param      companyId - Filial
@param      event - evento (R-2010, R-2020 etc)
@param      period - periodo MMAAAA
@param      transmit - lógico, se realiza a transmissão da exlusão

@Author		karen.yoshie
@Since		18/03/2021
@Version	1.0
/*/
//---------------------------------------------------------------------
WSMETHOD POST deleteEvent PATHPARAM companyId, event, period, transmit WSREST WSTAF004

Local aEvents		as array
Local aRetorno		as array
Local aEvent9000	as array
Local aRecno		as array
Local aRetErro		as array
Local aCompany		as array
Local cAlsPai		as character
Local cAliasTmp		as character
Local cIDTrans		as character
Local cMsgRet		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local nI			as numeric
Local lSucesso		as logical
Local lFound		as logical
Local lRet			as logical
Local oRequest		as object
Local oResponse		as object
Local oTableID		as object

//----------------------------------
// Inicialização variáveis
//----------------------------------
aEvents		:=	{}
aRetorno	:=	{}
aEvent9000	:=	{}
aRecno		:=	{}
aRetErro	:=	{}
aCompany	:=	{}
cAlsPai		:=	""
cAliasTmp	:=	""
cIDTrans	:=	""
cMsgRet		:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
nI			:=	0
lSucesso	:=	.T.
lFound		:=	.F.
lRet		:=	.T.
oRequest	:=	JsonObject():New()
oResponse	:=	JsonObject():New()
oTableID	:=	Nil

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
ElseIf self:transmit == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Transmitir não informado no parâmetro 'transmit'." ) )
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			aEvents := TAFRotinas( self:event, 4, .F., 5 )

			oResponse["deletedDetail"] := {}

			If Len( aEvents ) > 0
				oRequest:FromJSON( self:GetContent() )

				If Len( oRequest["deleteItems"] )
					// Trata a variável cIDTrans concatenando os CNPJs para filtro dos eventos R-1070, R-2010, R-2020, R-2030, R-2050, R-2060 e R-3010 para transnmissão
					If ( self:event $ "R-1070|"+EV_PERIODICOS )
						//Retorna Tabela Temporária com os IDs selecionados para exclusão
						oTableID := WSProviders( oRequest["deleteItems"] )
					EndIf

					cAlsPai := aEvents[3]

					//Executa a query dos registros que devem ser transmitidos
					cAliasTmp := WS004DelReg( aEvents, self:period, oTableID )

					oTableID:Delete()

					If self:event $ EV_PERIODICOS
						If ( cAliasTmp )->( !Eof() )
							lFound := .T.

							If self:transmit
								aEvent9000 := TAFRotinas( "R-9000", 4, .F., 5 )
							EndIf

							While ( cAliasTmp )->( !Eof() )
								aRetorno := {}

								aAdd( oResponse["deletedDetail"], JsonObject():New() )

								nI := Len( oResponse["deletedDetail"] )

								//Posiciona no registro do Evento a ser excluído
								DBSelectArea( cAlsPai )

								( cAlsPai )->( DBGoto( ( cAliasTmp )->RECNO ) )

								//Gera Evento R-9000 de Exclusão
								TAFR9000( cAlsPai, ( cAliasTmp )->RECNO, 1, .T., @aRetorno, aEvents[1] )

								If Len( aRetorno ) > 0
									lSucesso	:=	aRetorno[1][1]
									cMsgRet		:=	aRetorno[1][2]
								Else
									If self:transmit
										cMsgRet		:=	""
										aRecno		:=	{}
										aRetErro	:=	{}

										aAdd( aRecno, T9D->( Recno() ) )

										aRetorno := TAFProc9TSS( .T., aEvent9000, Nil, Nil, Nil, Nil, Nil, @cMsgRet, Nil, Nil, Nil, Nil, Nil, aRecno,, .T., @aRetErro )
										lSucesso := aRetorno[1][1]

										If !lSucesso
											cMsgRet := "Exclusão realizada, porém houveram erros na transmissão: "

											TAFMErrT0X( aRetorno, .F. ) //Grava erros de transmissão com origem na camada TAF/TSS

											If !Empty( aRetorno[1][2] )
												cMsgRet += aRetorno[1][2]
											EndIf
										Else
											cMsgRet := "Exclusão realizada com sucesso."
										EndIf
									Else
										lSucesso	:=	.T.
										cMsgRet		:=	"Exclusão realizada com sucesso."
									EndIf
								EndIf

								oResponse["deletedDetail"][nI]["key"]		:=	( cAliasTmp )->ID
								oResponse["deletedDetail"][nI]["status"]	:=	lSucesso
								oResponse["deletedDetail"][nI]["message"]	:=	EncodeUTF8( cMsgRet )

								( cAliasTmp )->( DBSkip() )
							EndDo
						Else
							lSucesso	:=	.F.
							cMsgRet		:=	"Registros não encontrados para os parâmetros enviados."
						EndIf
					EndIf

					( cAliasTmp )->( DBCloseArea() )

					If !lFound
						aAdd( oResponse["deletedDetail"], JsonObject():New() )

						oResponse["deletedDetail"][1]["key"]		:=	cIDTrans
						oResponse["deletedDetail"][1]["status"]		:=	lSucesso
						oResponse["deletedDetail"][1]["message"]	:=	EncodeUTF8( cMsgRet )
					EndIf

					lRet := .T.
					self:SetResponse( oResponse:ToJson() )
				Else
					lRet := .F.
					SetRestFault( 400, EncodeUTF8( "Nenhum evento selecionado na requisição" ) )
				EndIf
			Else
				lRet := .F.
				SetRestFault( 400, EncodeUTF8( "Evento: " + self:event + " não encontrado." ) )
			EndIf
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oRequest )
FreeObj( oResponse )

oRequest	:=	Nil
oResponse	:=	Nil

DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} WS004DelReg
Realiza a query com os registros dos eventos a serem excluidos

@param      aEvents - array aEventos
@param      cPerIni - periodo MMAAAA
@param      cIdTrans - string com os códigos dos IDs dos registros

@Author		karen.yoshie
@Since		18/03/2021
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function WS004DelReg(aEvents, cPerIni, oTableId)
local cSelect   as character
local cFrom     as character
local cWhere    as character
local cAlias    as character
local cLayout   as character
local cAliasLay as character
local cBd		as character
local cPerAux	as character

default     cPerIni     := ''

cBd 	 	:= TcGetDb()
cSelect		:=	""
cFrom       :=  ""
cWhere      :=  ""
cAlias      :=  getnextalias()
cAliasLay   := aEvents[3] //Alias do Evento
cLayout     := aEvents[4] //Layout
cPerIni		:= STRTRAN(cPerIni,"/","")

If AllTrim( cLayout ) $ EV_PERIODICOS
	cSelect += "' " + cLayout   + "' EVENTO "
	cSelect += " ," + cAliasLay + "." + cAliasLay + "_FILIAL FILIAL "
	cSelect += " ," + cAliasLay + "." + cAliasLay + "_ID ID "
    cSelect += " ," + cAliasLay + "." + cAliasLay + "_STATUS STATUS "
    cSelect += " ," + cAliasLay + ".R_E_C_N_O_ RECNO " 
    
    cFrom += RetSqlName( cAliasLay ) + " " + cAliasLay + " "
    if ValType(oTableId) == 'O' .and. (oTableId:GetAlias())->(RecCount()) > 0
        cFrom += " INNER JOIN " + oTableId:GetRealName() + " QRYTMP ON QRYTMP.IDCHECKED = " + cAliasLay + "." + cAliasLay + "_ID "
    endif    

    cWhere += cAliasLay + "." + cAliasLay + "_FILIAL = '" + xFilial(cAliasLay) + "'"
    cWhere += " AND " + cAliasLay + ".D_E_L_E_T_ = ' ' " 
    cWhere += " AND " + cAliasLay + "." + cAliasLay + "_ATIVO = '1' "

	If AllTrim( cLayout ) == "R-3010"
		cPerAux := Substr(cPerini,3,4) + Substr(cPerini,1,2)

		If cBd $ "ORACLE|POSTGRES|DB2"
			cWhere += " AND SUBSTR(" + cAliasLay + "." + cAliasLay + "_DTAPUR,1,6) = '" + cPerAux + "'"
        ElseIf cBd $ "INFORMIX"
			cWhere += " AND " + cAliasLay + "." + cAliasLay + "_DTAPUR[1,6]) = '" + cPerAux + "'"
        Else
			cWhere += " AND SUBSTRING(" + cAliasLay + "." + cAliasLay + "_DTAPUR,1,6) = '" + cPerAux + "'"
        EndIf
	Else
    	cWhere += " AND " + cAliasLay + "." + cAliasLay + "_PERAPU = '" + cPerIni + "'"
	EndIf
    cSelect :=  "%" +   cSelect +   "%" 
    cFrom   :=  "%" +   cFrom   +   "%"
    cWhere  :=  "%" +   cWhere  +   "%"   

    BeginSql Alias cAlias
        SELECT 
        %Exp:cSelect% 
        FROM 
        %Exp:cFrom%
        WHERE
        %Exp:cWhere%
    EndSql    
endIf

Return cAlias

//---------------------------------------------------------------------
/*/{Protheus.doc} undelete
Apaga o registro R-9000 criado na tabela T9D

@param      companyId - Filial
@param      period - periodo MMAAAA

@Author		karen.yoshie
@Author     Wesley Pinheiro
@Author     Denis Naves
@Since		18/03/2021
@Version	1.0
/*/
//---------------------------------------------------------------------
WSMETHOD POST undelete PATHPARAM companyId, period WSREST WSTAF004

Local aEvents		as array
Local aRetorno		as array
Local aCompany		as array
Local cMsgRet		as character
Local cAliasEv		as character
Local cAliasTmp		as character
Local cProtul		as character
Local cAlsPai		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local nI			as numeric
Local lSucesso		as logical
Local lRet			as logical
Local oRequest		as object
Local oResponse		as object
Local oTableID		as object

//----------------------------------
// Inicialização variáveis
//----------------------------------
aEvents		:=	{}
aRetorno	:=	{}
aCompany	:=	{}
cMsgRet		:=	""
cAliasEv	:=	""
cAliasTmp	:=	""
cProtul		:=	""
cAlsPai		:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
nI			:=	0
lSucesso	:=	.T.
lRet		:=	.T.
oRequest	:=	JsonObject():New()
oResponse	:=	JsonObject():New()
oTableID	:=	Nil

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
Else
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			oRequest:FromJSON( self:GetContent() )

			//Retorna Tabela Temporária com os IDs selecionados para desfazer a exclusão
			oTableID := WSProviders( oRequest["undeleteItems"] )

			cAliasEv := IDPorEvent( oTableId )

			oTableID:Delete()

			oResponse["undeletedDetail"] := {}

			If ( cAliasEv )->( !Eof() )
				While ( cAliasEv )->( !Eof() )
					aEvents := TAFRotinas( ( cAliasEv )->EVENTO, 4, .F., 5 )

					cProtul := ""
					While ( cAliasEv )->( !Eof() ) .and. aEvents[4] == ( cAliasEv )->EVENTO
						cProtul += "'" + AllTrim( ( cAliasEv )->PROTUL ) + "',"

						( cAliasEv )->( DBSkip() )
					EndDo

					cProtul := SubStr( cProtul, 1, Len( cProtul ) - 1 )

					cAlsPai := aEvents[3]

					//Executa a query dos registros que devem ser desfeitos com o R-9000
					cAliasTmp := WS004T9DDel( aEvents, self:period, cProtul )

					DBSelectArea( cAlsPai )

					While ( cAliasTmp )->( !Eof() )
						aAdd( oResponse["undeletedDetail"], JsonObject():New() )
						nI ++

						//Posiciona no registro do Evento a ser excluído
						( cAlsPai )->( DBGoto( ( cAliasTmp )->RECNO ) )

						//Gera Evento R-9000 de Exclusão
						TAFR9000( cAlsPai, ( cAliasTmp )->RECNO, 2, .T., @aRetorno, aEvents[1] )

						If Len( aRetorno ) > 0
							lSucesso	:=	aRetorno[1][1]
							cMsgRet		:=	aRetorno[1][2]
						Else
							lSucesso	:=	.T.
							cMsgRet		:=	"Exclusão realizada com sucesso."
						EndIf

						oResponse["undeletedDetail"][nI]["key"]		:=	( cAliasTmp )->ID
						oResponse["undeletedDetail"][nI]["status"]	:=	lSucesso
						oResponse["undeletedDetail"][nI]["message"]	:=	EncodeUTF8( cMsgRet )

						( cAliasTmp )->( DBSkip() )
					EndDo

					( cAliasTmp )->( DBCloseArea() )
				EndDo
			Else
				oResponse["undeletedDetail"]["status"]	:=	.F.
				oResponse["undeletedDetail"]["message"]	:=	"Registro(s) não encontrado(s) com o Json enviado."
			EndIf

			( cAliasEv )->( DBCloseArea() )

			lRet := .T.
			self:SetResponse( oResponse:ToJson() )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oRequest )
FreeObj( oResponse )

oRequest	:=	Nil
oResponse	:=	Nil

DelClassIntF()

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} WS004T9DDel
Realiza query para retornar RECNO de registros que serão desfeitos o registro de exclusão ( R-9000 )

@param      aEvents - array aEventos
@param      cPerIni - periodo MMAAAA
@param      cProtul - string dos protocolos ( _PROTUL ) dos registros

@Author		karen.yoshie
@Author		Wesley Pinheiro
@Author		Denis Naves
@Since		25/03/2021
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function WS004T9DDel( aEvents, cPerIni, cProtul )
    
    local cSelect   as character
    local cFrom     as character
    local cWhere    as character
    local cAlias    as character
    local cLayout   as character
    local cAliasLay as character
    local cJoinT9D  as character
    local cJoinT9B  as character

    cSelect		:= ""
    cFrom       := ""
    cWhere      := ""
    cAlias      := getnextalias( )
    cAliasLay   := aEvents[3] //Alias do Evento
    cLayout     := aEvents[4] //Layout

    cSelect += " " + cAliasLay + ".R_E_C_N_O_ RECNO, "
    cSelect += " T9D_ID ID "

    cFrom += RetSqlName( cAliasLay ) + " " + cAliasLay + " "

    cJoinT9D := RetSqlName( "T9D" ) + " T9D "
    cJoinT9D += " ON T9D_FILIAL = " + cAliasLay + "_FILIAL "
    cJoinT9D += " AND T9D.T9D_NRRECI = " + cAliasLay + "_PROTPN "
    cJoinT9D += " AND T9D_STATUS = ' ' "
    cJoinT9D += " AND T9D.D_E_L_E_T_ = ' ' "

    cJoinT9B := RetSqlName( "T9B" ) + " T9B "
    cJoinT9B += " ON T9D.T9D_IDTPEV = T9B_ID "
    cJoinT9B += " AND T9B_CODIGO = '" + cLayout + "' "	
    cJoinT9B += " AND T9B.D_E_L_E_T_ = ' ' "

    cWhere += cAliasLay + "." + cAliasLay + "_FILIAL = '" + xFilial(cAliasLay) + "'"
    cWhere += " AND " + cAliasLay + ".D_E_L_E_T_ = ' ' " 
    cWhere += " AND " + cAliasLay + "." + cAliasLay + "_ATIVO = '1' "
    cWhere += " AND " + cAliasLay + "." + cAliasLay + "_STATUS = '6' "
	If cLayout == "R-3010"
		cWhere += " AND " + cAliasLay + "." + cAliasLay + "_DTAPUR = T9D.T9D_PERAPR "
	Else
    	cWhere += " AND " + cAliasLay + "." + cAliasLay + "_PERAPU = '" + STRTRAN(cPerIni,"/","") + "'"
	EndIf	
    cWhere += " AND " + cAliasLay + "." + cAliasLay + "_PROTUL = ' ' "
    cWhere += " AND " + cAliasLay + "." + cAliasLay + "_PROTPN IN (" + cProtul +")"

    cSelect  :=  "%" +   cSelect  +   "%" 
    cFrom    :=  "%" +   cFrom    +   "%"
    cJoinT9D :=  "%" +   cJoinT9D +   "%"
    cJoinT9B :=  "%" +   cJoinT9B +   "%"
    cWhere   :=  "%" +   cWhere   +   "%"   

    BeginSql Alias cAlias
        SELECT 
        %Exp:cSelect% 
        FROM 
        %Exp:cFrom%
        INNER JOIN 
        %Exp:cJoinT9D%
        INNER JOIN
        %Exp:cJoinT9B%
        WHERE
        %Exp:cWhere%
    EndSql

Return cAlias

//---------------------------------------------------------------------
/*/{Protheus.doc} IdPorEvent
Realiza query que retorna os eventos associados aos ids T9D enviados na requisição

@param      cIdsT9D - string com os códigos dos IDs dos registros T9D

@Author		Wesley Pinheiro
@Author		Denis Naves
@Since		24/03/2021
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function IdPorEvent(oTableId)
Local cAlias    := getnextalias()
Local cTableId  := oTableId:GetRealName()

BeginSql Alias cAlias 
    SELECT
        T9B.T9B_CODIGO EVENTO,
        T9D.T9D_NRRECI PROTUL
    FROM %TABLE:T9D% T9D
        INNER JOIN %TABLE:T9B% T9B ON T9D.T9D_IDTPEV = T9B_ID AND T9B.T9B_FILIAL = %xFilial:T9B% AND T9B.D_E_L_E_T_ = ' '
        INNER JOIN %temp-table:cTableId% QRYTMP ON QRYTMP.IDCHECKED = T9D.T9D_ID
    WHERE T9D.T9D_FILIAL = %xFilial:T9D%
        and T9D.D_E_L_E_T_ = ' '
    ORDER BY T9B.T9B_CODIGO
EndSql

Return cAlias


//---------------------------------------------------------------------
/*/{Protheus.doc} IdPorEvent
Faz o controle de paginacacao

@Author		Verônica Almeida / Wesley Matos
@Since		01/11/2022
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function HasNext(cFields as character, cSelect as character, cFrom as character, cWhere as character, nRegFim as numeric)
	Local cAlias as character
	Local cQry as character
	Local lRet as logical

	lRet :=	.F.

	cQry := " SELECT  MAX( LINE_NUMBER ) MAX_LINE FROM ( "
	cQry += "   SELECT ROW_NUMBER() OVER( ORDER BY " + cFields 
	cQry += StrTran(cSelect,'%', ' ')
	cQry += " 	FROM " + StrTran(cFrom,'%', ' ')
	cQry += " 	WHERE " + StrTran(cWhere,'%', ' ')

	oStatement := FWPreparedStatement():New( ChangeQuery(cQry) )

	cQry := oStatement:getFixQuery()

	cAlias := MPSysOpenQuery(cQry)

	( cAlias )->( DBGoTop() )

	If ( cAlias )->( !Eof() )
		lRet := ( cAlias )->MAX_LINE > nRegFim
	EndIf

	( cAlias )->( DBCloseArea() )

Return( lRet )
