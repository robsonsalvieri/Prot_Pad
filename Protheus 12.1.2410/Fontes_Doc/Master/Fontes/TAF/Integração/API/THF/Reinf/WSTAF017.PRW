#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE SINTETICO 1,1
#DEFINE ANALITICO 2,1
#DEFINE ATIVIDADE 2,1
#DEFINE PROCESSOS 4,1
#DEFINE AJUSTE	  5,1
#DEFINE TINSC 1
#DEFINE NINSC 2
#DEFINE GEFIL 1
#DEFINE M0FIL 2
#DEFINE PAA   4

Static __lApurBx

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSTAF017
WS para retorno das informações referente ao detalhe das movimentações da base

@author Leticia Campos da Silva
@since 20/09/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSRESTFUL WSTAF017 DESCRIPTION "API Reinf - Info Base para Relatório"

	WSDATA companyId	AS STRING
	WSDATA period		AS STRING
	WSDATA event		AS STRING

	WSMETHOD GET eventDetail;
		DESCRIPTION "Detalhes do Evento informado";
		WSSYNTAX "/eventDetail";
		PATH "eventDetail";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Método responsável pela consulta ao programa nativo da reinf e montagem da mensagem de resposta para camada THF

@author Leticia Campos da Silva
@since 24/09/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET eventDetail QUERYPARAM companyId, period, event WSREST WSTAF017

Local aApurac		as array
Local aFilToReinf	as array
Local aCompany		as array
Local cEvento		as character
Local cMacro		as character
Local cEmpRequest	as character
Local cFilRequest	as character
Local lRet			as logical
Local oEstruct		as object
Local cCode			as character
Local cUser			as character
Local cModule		as character
Local cRoutine		as character

aApurac		:=	{}
aFilToReinf	:=	{}
aCompany	:=	{}
cEvento		:=	""
cMacro		:=	""
cEmpRequest	:=	""
cFilRequest	:=	""
lRet		:=	.T.
oEstruct	:=	JsonObject():New()
cCode		:= "LS006"
cUser		:= ""
cModule		:= "84"
cRoutine 	:= ""

self:SetContentType("application/json")

If self:companyId == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
ElseIf self:period == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Período não informado no parâmetro 'period'." ) )
ElseIf self:event == Nil
	lRet := .F.
	SetRestFault( 400, EncodeUTF8( "Evento não informados no parâmetro 'event'." ) )
Else
	cRoutine 	:= "TAFReinf"+StrTran(self:event,"-", "")+"RelXLS"
	aCompany := StrTokArr( self:companyId, "|" )

	If Len( aCompany ) < 2
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( "Empresa|Filial não informado no parâmetro 'companyId'." ) )
	Else
		cEmpRequest := aCompany[1]
		cFilRequest := aCompany[2]

		If PrepEnv( cEmpRequest, cFilRequest )
			cUser := RetCodUsr()
			aFilToReinf := { { .T., "", cFilAnt, cEmpAnt + cFilAnt, "", "", "", .T., .T. } }

			If FindFunction( "FWLSPutAsyncInfo" )
				FWLSPutAsyncInfo( cCode, cUser, cModule, cRoutine )
				TAFConOut( "-> " +cRoutine,1,.F.,"LSTAF")								
			EndIf 

			oEstruct["eventDetail"] := {}

			cEvento := StrTran( self:event, "-", "" )
			cMacro := cEvento + "( aApurac, @oEstruct, aFilToReinf, self:period, self:event )"
			&( cMacro )
			lRet := .T.
			self:SetResponse( FWJsonSerialize( oEstruct, .T., .T.,, .F. ) )
		Else
			lRet := .F.
			SetRestFault( 400, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
		EndIf
	EndIf
EndIf

FreeObj( oEstruct )
oEstruct := Nil
DelClassIntF()

Return( lRet )


/*/{Protheus.doc} R2010
	@type  Static Function
	@author user
	@since 23/07/2020
	@version version
	@param 
		aApurac - Array com os dados a serem retornados.
		oEstruct- Estrura a ser retornada para o fronted. - @Passada por referência.
	@return 
	@see (links_or_references)
	/*/

Static Function R2010(aApurac, oEstruct, aFilToReinf, cPeriod, cEvent)
	R10E20(aApurac, @oEstruct, aFilToReinf, cPeriod, cEvent)
Return

/*/{Protheus.doc} R2020
	@type  Static Function
	@author user
	@since 23/07/2020
	@version version
	@param 
		aApurac - Array com os dados a serem retornados.
		oEstruct- Estrura a ser retornada para o fronted. - @Passada por referência.
	@return 
	@see (links_or_references)
	/*/
Static Function R2020(aApurac, oEstruct, aFilToReinf, cPeriod, cEvent)
	R10E20(aApurac, @oEstruct, aFilToReinf, cPeriod, cEvent)
Return

/*/{Protheus.doc} R4040
	@type  Static Function
	@author Denis Souza
	@since 28/02/2023
	@version 1.0
	@param 
		aApurac - Array com os dados a serem retornados.
		oEstruct- Estrura a ser retornada para o fronted. - @Passada por referência.
/*/
Static Function R4040(aApurac as array, oEstruct as object, aFilToReinf as array, cPeriod as character, cEvent as character)
	R40E80(aApurac, @oEstruct, aFilToReinf, cPeriod, cEvent)
Return

/*/{Protheus.doc} R4080
	@type  Static Function
	@author Denis Souza
	@since 28/02/2023
	@version 1.0
	@param 
		aApurac - Array com os dados a serem retornados.
		oEstruct- Estrura a ser retornada para o fronted. - @Passada por referência.
/*/
Static Function R4080(aApurac as array, oEstruct as object, aFilToReinf as array, cPeriod as character, cEvent as character)
	R40E80(aApurac, @oEstruct, aFilToReinf, cPeriod, cEvent)
Return

/*/{Protheus.doc} R2010
	@type  Static Function
	@author user
	@since 23/07/2020
	@version version
	@param 
		aApurac - Array com os dados a serem retornados.
		oEstruct- Estrura a ser retornada para o fronted. - @Passada por referência.
	@return 
	@see (links_or_references)
	/*/
Static Function R10E20(aApurac, oEstruct, aFilToReinf, cPeriod, cEvent)
	Local aInfos        as array
	Local cCode	  		as character
	Local cNome			as character
	Local cCGC			as character
	Local cObra			as character
	Local nTAnalitic	as numeric
	Local nTSintetic 	as numeric
	Local cCompC1H 		as character
	Local aInfEUF		as Array
	Local cIDAnalitic   as character
	Local cIDSintetic   as character
	Local cDescrObra    as character

	Default aApurac	:= {}

	cCode			:= ""
	cNome			:= ""
	cCGC			:= ""
	cObra       	:= ""
	aApurac 		:= TafGetEvt(cPeriod, cEvent)
	aInfos			:= {}
	nTAnalitic		:= 0
	nTSintetic		:= 0
	cCompC1H 		:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
	aInfEUF 		:= TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	cIDAnalitic     := ""
	cIDSintetic     := ""
	cDescrObra      := ""

	(aApurac[SINTETICO])->(DbSetOrder(1))
	(aApurac[ANALITICO])->(DbSetOrder(1))
	
	(aApurac[SINTETICO])->(DBGOTOP())
	(aApurac[ANALITICO])->(DBGOTOP())

	While (aApurac[SINTETICO])->(!EOF())

		cIDSintetic := AllTrim((aApurac[SINTETICO])->ID)
		cIDAnalitic := AllTrim((aApurac[ANALITICO])->ID)

		While (aApurac[ANALITICO])->(!EOF()) .And. cIDSintetic == cIDAnalitic
			
			aadd(oEstruct["eventDetail"],JsonObject():New())
			
			nTSintetic  := len(oEstruct["eventDetail"])
			nTAnalitic  := len(oEstruct["eventDetail"])
			cObra       :=(aApurac[SINTETICO])->CINDOBRA
			cCGC        := RETCGC((aApurac[ANALITICO])->FIL)
			aInfos      := RETINFOC1H((aApurac[ANALITICO])->IDPART,(aApurac[ANALITICO])->FIL,cCompC1H,aInfEUF)

			If len(aInfos) > 0
				cCode  := aInfos[1][1]
				cNome  := aInfos[1][2]
			Else
				cCode  := "Participante nao encontrado na C1H"
				cNome  := "Participante nao encontrado na C1H"
			Endif

			// Número de inscrição do contribuinte
			oEstruct["eventDetail"][nTAnalitic]["taxNumberBranch"]									:=  cCGC

			// Indicativo de Prestação de Serviços em Obra de Construção Civil
			cDescrObra                                                                              := EncodeUTF8(IndObra(cObra))
			oEstruct["eventDetail"][nTAnalitic]["serviceProvidingIndication"]	  					:= AllTrim(cDescrObra)

			// Descrição da Obra		
			oEstruct["eventDetail"][nTAnalitic]["constructionSiteDescription"]  					:=  IIF(Substr(cDescrObra,1,1) <> "0",Alltrim((aApurac[SINTETICO])->CDSOBRA),"")

			// Valor da retenção principal
			oEstruct["eventDetail"][nTAnalitic]["mainWithHoldingValue"]  							:=  (aApurac[SINTETICO])->VLRTNRPRNC

			// Valor da retenção adicional não efetivado
			oEstruct["eventDetail"][nTAnalitic]["additionalHoldValueNotConfirmed"]  				:=  (aApurac[SINTETICO])->VLRTNRADIC

			// Nome do Participante
			oEstruct["eventDetail"][nTAnalitic]["company"]  										:=  cNome

			// Código do participante
			oEstruct["eventDetail"][nTAnalitic]["employeeCode"]  									:=  cCode

			// Tipo de inscrição do participante [1] CNPJ [4] CNO
			oEstruct["eventDetail"][nTAnalitic]["typeOfInscriptionEmployee"]						:=  IIf(len((aApurac[SINTETICO])->CTPINSCTOM) == 1, "1 - CNPJ", "4 - CNO")

			// Tipo do documento
			oEstruct["eventDetail"][nTAnalitic]["documentType"]  									:=  (aApurac[ANALITICO])->ROTINA

			// Filial
			oEstruct["eventDetail"][nTAnalitic]['branch'] 											:=  (aApurac[ANALITICO])->FIL

			// Número Documento Fiscal
			oEstruct["eventDetail"][nTAnalitic]['invoice'] 											:=  alltrim((aApurac[ANALITICO])->NUMDOCTO)

			// Serie Documento Fiscal
			oEstruct["eventDetail"][nTAnalitic]['invoiceSeries'] 									:=  alltrim((aApurac[ANALITICO])->SERIE)

			// Data Documento Fiscal
			oEstruct["eventDetail"][nTAnalitic]['issueDate'] 										:=  (aApurac[ANALITICO])->DTEMISSNF

			// Valor do Documento
			oEstruct["eventDetail"][nTAnalitic]['grossValue'] 										:=  (aApurac[ANALITICO])->VLRBRUTO

			// Observação
			oEstruct["eventDetail"][nTAnalitic]['observation'] 										:=  alltrim((aApurac[ANALITICO])->OBS)

			//Remoção do campo item do backend e front-end

			// Base Calculo Tributo
			oEstruct["eventDetail"][nTAnalitic]['taxBase']  		 								:=  (aApurac[ANALITICO])->VLRBASERET

			// Valor do Tributo
			oEstruct["eventDetail"][nTAnalitic]['tax']  		 									:=  (aApurac[ANALITICO])->VLRRETENC

			// Valor Serviço Subcontrata
			oEstruct["eventDetail"][nTAnalitic]['subcontractServiceValue'] 							:=  (aApurac[ANALITICO])->VLRRETSUB

			// Vlr Retenção Não Pago
			oEstruct["eventDetail"][nTAnalitic]['unpaiRetentionAmount'] 							:=  (aApurac[ANALITICO])->VLRNRETPRI

			// Val Serv Cond Espec 15A
			oEstruct["eventDetail"][nTAnalitic]['valueServicesProvidedOnSpecialCondition15Years']	:=  (aApurac[ANALITICO])->VLRSERV15

			// Vlr Serv Cond Esp 20A
			oEstruct["eventDetail"][nTAnalitic]["valueServicesProvidedOnSpecialCondition20Years"]	:=  (aApurac[ANALITICO])->VLRSERV20

			// Vlr Serv Cond Esp 25A
			oEstruct["eventDetail"][nTAnalitic]["valueServicesProvidedOnSpecialCondition25Years"]	:=  (aApurac[ANALITICO])->VLRSERV25

			// Valor Retenção Adicional
			oEstruct["eventDetail"][nTAnalitic]["additionalHoldValue"]  							:=  (aApurac[ANALITICO])->VLRADICC

			// Vlr Ret Adic Não Pago
			oEstruct["eventDetail"][nTAnalitic]['additionalUnpaidRetentionAmount']					:=  (aApurac[ANALITICO])->VLRNRTADIC

			// Cód. Documento Fiscal
			oEstruct["eventDetail"][nTAnalitic]['taxDocumentCode'] 									:=  (aApurac[ANALITICO])->CHVNF
			// Alíquota do Tributo
			oEstruct["eventDetail"][nTAnalitic]['aliquot'] 											:=  ((aApurac[ANALITICO])->ALIQ)

			// Contrib CPRB
			oEstruct["eventDetail"][nTAnalitic]['CPRB'] 											:=  EncodeUTF8(Iif((aApurac[ANALITICO])->CPRB $ "0|' '", "0 - Não é contribuinte da CPBR - Retenção 11%", "1 - Contribuinte da CPBR - Retenção 3,5%"))

			// CNPJ do Participante
			oEstruct["eventDetail"][nTAnalitic]['taxNumber'] 										:=  (aApurac[ANALITICO])->CNPJ

			// Tipo do Serviço
			oEstruct["eventDetail"][nTAnalitic]['serviceType'] 										:=  (aApurac[ANALITICO])->TPSERVICO

			// Codigo do Serviço
			oEstruct["eventDetail"][nTAnalitic]['serviceCode']										:=  (aApurac[ANALITICO])->CODSERVIC

			// Descrição do Serviço
			oEstruct["eventDetail"][nTAnalitic]['service']											:=  alltrim((aApurac[ANALITICO])->C8CDESCRI)

			(aApurac[ANALITICO])->(dbSkip())

			If (aApurac[ANALITICO])->(!EOF())
				cIDAnalitic := AllTrim((aApurac[ANALITICO])->ID)
			Endif
		EndDo
		(aApurac[SINTETICO])->(dbSkip())
	EndDo
Return

Static Function R2030(aApurac, oEstruct,aFilToReinf, cPeriodo,cEvent)
	R30E40(aApurac, @oEstruct,aFilToReinf, cPeriodo,cEvent)
Return

Static Function R2040(aApurac, oEstruct,aFilToReinf, cPeriodo,cEvent)
	R30E40(aApurac, @oEstruct,aFilToReinf, cPeriodo,cEvent)
Return

/*/{Protheus.doc} R9001
	Compatibilização com Código legado do evento R-9001 (R-5001 no leiaute 1.5)

	@type  Static Function
	@author Fabio Mendonça
	@since 09/12/2022
	@version 1.0
/*/
Static Function R9001(aApurac as array, oEstruct as object, aFilToReinf as array, cPeriodo as character, cEvent as character)
	R5001(aApurac, @oEstruct, aFilToReinf, cPeriodo, cEvent)
Return

Static Function R5001(aApurac as array, oEstruct as object, aFilToReinf as array, cPeriodo as character, cEvent as character)
	Local cQuery 	 as character
	Local nX     	 as numeric
	Local nTSintetic as numeric
	Local aFil   	 as array
	Local aFiliais 	 as array

	cQuery     := ""
	aFil 	   := {}
	aFiliais   := {}
	nX         := 1
	nTSintetic := 1

	aFil 	  := wsLoadFil()

	For nX := 1 to len(aFil)
		aadd(aFiliais, {aFil[nX][1],aFil[nX][3]})
	Next nX
	
	cQuery := QryRel5001(cPeriodo,  aFiliais)
	
	(cQuery)->(dbGoTop())

	While !(cQuery)->(eof())
		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])

		oEstruct["eventDetail"][nTSintetic]["branchId"]                     := ALLTRIM((cQuery)->FILIAL)
		oEstruct["eventDetail"][nTSintetic]["branch"]                       := FWSM0Util( ):GetSM0Data( ,(cQuery)->FILIAL , { 'M0_FILIAL' } )[1][2] 
		oEstruct["eventDetail"][nTSintetic]["taxNumber"]                    := FWSM0Util( ):GetSM0Data( ,(cQuery)->FILIAL , { 'M0_CGC'    } )[1][2] 
		oEstruct["eventDetail"][nTSintetic]["event"]                        := ALLTRIM((cQuery)->EVENTO)
		oEstruct["eventDetail"][nTSintetic]["protocol"]                     := ALLTRIM((cQuery)->RECIBO)
		oEstruct["eventDetail"][nTSintetic]["recipeCode"]                   := ALLTRIM((cQuery)->CODREC)
		oEstruct["eventDetail"][nTSintetic]["registrationNumber"]           := ALLTRIM((cQuery)->NRINSC)
		oEstruct["eventDetail"][nTSintetic]["taxBase"]                      := (cQuery)->BASE_CALCULO
		oEstruct["eventDetail"][nTSintetic]["tax"]                          := (cQuery)->IMPOSTO
		oEstruct["eventDetail"][nTSintetic]["suspendedContribution"]        := (cQuery)->IMPSUS
		oEstruct["eventDetail"][nTSintetic]["additionalHoldValue"]          := (cQuery)->ADICIONAL
		oEstruct["eventDetail"][nTSintetic]["additionalHoldValueSuspended"] := (cQuery)->ADICSUSP
		(cQuery)->(dbSkip())
	EndDo
Return

/*/{Protheus.doc} R9011
	Compatibilização com Código legado do evento R-9011 (R-5011 no leiaute 1.5)

	@type  Static Function
	@author Fabio Mendonça
	@since 09/12/2022
	@version 1.0
/*/
Static Function R9011(aApurac as array, oEstruct as object, aFilToReinf as array, cPeriodo as character, cEvent as character)
	R5011(aApurac, @oEstruct,aFilToReinf, cPeriodo,cEvent)
Return

Static Function R5011(aApurac as array, oEstruct as object, aFilToReinf as array, cPeriodo as character, cEvent as character)
	Local cQuery 	 as character
	Local nX     	 as numeric
	Local nTSintetic as numeric
	Local aFil   	 as array
	Local aFiliais 	 as array

	cQuery     := ""
	aFil 	   := {}
	aFiliais   := {}
	nX         := 1
	nTSintetic := 1

	aFil 	  := wsLoadFil()

	For nX := 1 to len(aFil)
		aadd(aFiliais, {aFil[nX][1],aFil[nX][3]})
	Next nX

	cQuery := QryRel5011(cPeriodo,  aFiliais)
	
	(cQuery)->(dbGoTop())

	While !(cQuery)->(eof())
		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])

		oEstruct["eventDetail"][nTSintetic]["branchId"]                     := ALLTRIM((cQuery)->FILIAL)
		oEstruct["eventDetail"][nTSintetic]["branch"]                       := FWSM0Util( ):GetSM0Data( ,(cQuery)->FILIAL , { 'M0_FILIAL' } )[1][2] 
		oEstruct["eventDetail"][nTSintetic]["taxNumber"]                    := FWSM0Util( ):GetSM0Data( ,(cQuery)->FILIAL , { 'M0_CGC'    } )[1][2] 
		oEstruct["eventDetail"][nTSintetic]["event"]                        := ALLTRIM((cQuery)->EVENTO)
		oEstruct["eventDetail"][nTSintetic]["protocol"]                     := ALLTRIM((cQuery)->RECIBO)
		oEstruct["eventDetail"][nTSintetic]["recipeCode"]                   := ALLTRIM((cQuery)->CODREC)
		oEstruct["eventDetail"][nTSintetic]["registrationNumber"]           := ALLTRIM((cQuery)->NRINSC)
		oEstruct["eventDetail"][nTSintetic]["taxBase"]                      := (cQuery)->BASECALC
		oEstruct["eventDetail"][nTSintetic]["tax"]                          := (cQuery)->IMPOSTO
		oEstruct["eventDetail"][nTSintetic]["suspendedContribution"]        := (cQuery)->IMPSUS
		oEstruct["eventDetail"][nTSintetic]["additionalHoldValue"]          := (cQuery)->ADICIONAL
		oEstruct["eventDetail"][nTSintetic]["additionalHoldValueSuspended"] := (cQuery)->ADICSUSP
		(cQuery)->(dbSkip())
	EndDo
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Função R2060
Retorna o objeto json do relatório do evento R-2060

@author Leticia Campos da Silva
@since 06/08/2020
@version 1.0
@param aReport - Array com os dados a serem retornados.
@param oReportCprb- Estrura a ser retornada para o frontend. - @Passada por referência.
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function R2060(aReport, oReportCprb, aFilToReinf, cPeriod, cEvent)

	Local aFil       	as array
	Local aFiliais   	as array
	Local aInfEUF		as array
	Local aMovs			as array
	Local cBranch		as character
	Local nPos  		as numeric
	Local nX			as numeric
	Local nValSus		as numeric

	default aReport 		:= {}
	default aFilToReinf		:= {}
	default	cPeriod			:= ""
	default cEvent			:= "R-2060"

	aFiliais    := {}
	aFil        := wsLoadFil()
	aInfEUF 	:= TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	cBranch		:= ""
	nPos    	:= 0
	nValSus		:= 0

	For nX := 1 to len(aFil)
		aadd(aFiliais, {aFil[nX][1],aFil[nX][3]})
	Next nX

	aReport		:= Qury2060(substr(cPeriod,3,4)+substr(cPeriod,1,2), .T., .F., aFiliais, aInfEUF, @aMovs, "")

	(aReport[AJUSTE])->(DbSetOrder(2))
	(aReport[AJUSTE])->(dbGoTop())

	(aReport[ATIVIDADE])->(DbSetOrder(2))
	(aReport[ATIVIDADE])->(dbGoTop())

	(aReport[PROCESSOS])->(DbSetOrder(2))
	(aReport[PROCESSOS])->(dbGoTop())

	while (aReport[ATIVIDADE])->(!Eof())
		cBranch  := Posicione("SM0",1,SM0->M0_CODIGO + (aReport[ATIVIDADE])->FILIAL,"M0_FILIAL")

		nValSus := 0

		aadd(oReportCprb["eventDetail"],JsonObject():New())
		nPos := len(oReportCprb["eventDetail"])

		// Filial do registro
		oReportCprb["eventDetail"][nPos]['branchId']									:= (aReport[ATIVIDADE])->FILIAL

		// Descrição da Filial
		oReportCprb["eventDetail"][nPos]["branch"]       								:= alltrim(EncodeUTF8(cBranch))

		//Tipo de inscricao
		oReportCprb["eventDetail"][nPos]['typeOfInscription']                           := (aReport[ATIVIDADE])->CTPINSC + Iif((aReport[ATIVIDADE])->CTPINSC == '1', " - CNPJ", " - CNO")

		// CNPJ/CNO Auferiu CPRB
		oReportCprb["eventDetail"][nPos]["taxNumberBranch"]								:= alltrim((aReport[ATIVIDADE])->CNRINSC)

		// Código da Atividade econômica
		oReportCprb["eventDetail"][nPos]["activityCode"]       							:= (aReport[ATIVIDADE])->CODATIV + " - " + EncodeUTF8( Alltrim( ( aReport[ATIVIDADE])->CDSATIV ) )

		// Valor da receita bruta
		oReportCprb["eventDetail"][nPos]["totalGrossValue"]     						:= (aReport[ATIVIDADE])->C5MVATIV

		// Valor de adição da receita bruta
		oReportCprb["eventDetail"][nPos]["additionalValueOfAdjustment"]					:= (aReport[ATIVIDADE])->T9TVAJU

		// Valor de exclusão da receita bruta
		if (aReport[ATIVIDADE])->T9TVEXC > 0
			oReportCprb["eventDetail"][nPos]["exclusionValueOfAdjustment"]				:= (aReport[ATIVIDADE])->T9TVEXC
		else
			oReportCprb["eventDetail"][nPos]["exclusionValueOfAdjustment"]				:= (aReport[ATIVIDADE])->C5MVEXC
		endIf

		// Valor base da CPRB
		oReportCprb["eventDetail"][nPos]['totalTaxBase']                				:= (aReport[ATIVIDADE])->VBCCPRB

		// Valor total da CPRB
		oReportCprb["eventDetail"][nPos]['sociaSecurityContributionValue']              := Round((aReport[ATIVIDADE])->VBCCPRB * (aReport[ATIVIDADE])->ALQATIV / 100,2)

		if (aReport[AJUSTE])->(DbSeek((aReport[ATIVIDADE])->CHAVE+(aReport[ATIVIDADE])->IDATIV))
			// Tipo de ajuste
			oReportCprb["eventDetail"][nPos]['reviewType']									:= (aReport[AJUSTE])->CTPAJST

			// Código/Descrição do ajuste
			oReportCprb["eventDetail"][nPos]['reviewDescription']							:= alltrim(EncodeUTF8((aReport[AJUSTE])->CCODAJST + " - " + (aReport[AJUSTE])->DSCAJST))

			// Período do ajuste
			oReportCprb["eventDetail"][nPos]['reviewPeriod']								:= (aReport[AJUSTE])->DTAJUS

		endIf

		if (aReport[PROCESSOS])->(DbSeek((aReport[ATIVIDADE])->CHAVE+(aReport[ATIVIDADE])->IDATIV))
			// Tipo de processo
			oReportCprb["eventDetail"][nPos]['proccesType']									:= RETPROC(AllTrim((aReport[PROCESSOS])->C1GTPPROC))

			// Número do processo
			oReportCprb["eventDetail"][nPos]['proccesNumber']								:= (aReport[PROCESSOS])->C1GNUMPRO

			// Código de suspensão do processo
			oReportCprb["eventDetail"][nPos]['suspensionCode']								:= (aReport[PROCESSOS])->CODSUS

			While !(aReport[PROCESSOS])->(Eof()) .AND. (aReport[PROCESSOS])->CHAVE == (aReport[ATIVIDADE])->CHAVE + (aReport[ATIVIDADE])->IDATIV 
				nValSus += (aReport[PROCESSOS])->VALSUS
				(aReport[PROCESSOS])->(DbSkip())
			endDo

		endIf

		// Valor total da CPRB com exigibilidade suspensa
		oReportCprb["eventDetail"][nPos]['socialSecurityContributionValueSuspended']	:= nValSus

		(aReport[ATIVIDADE])->(dbSkip())

	EndDo

Return

/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Static Function
	@author user
	@since 28/07/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function R30E40(aApurac, oEstruct,aFilToReinf, cPeriodo, cEvent)

	Local cQuery     as array
	Local aFil       as array
	Local aFiliais   as array
	Local nTAnalitic as numeric
	Local nX         as numeric
	Local nProp      as numeric

	aQuery	   := {}
	aFil       := {}
	aFiliais   := {}
	nTAnalitic := 0
	nX         := 0
	nProp	   := 0
	cPeriodo   := substr(cPeriodo,3,4)+substr(cPeriodo,1,2)
	aFil 	   := wsLoadFil()

	For nX := 1 to len(aFil)
		aadd(aFiliais, {aFil[nX][1],aFil[nX][3]})
	Next nX

	SetalApurBx()

	cQuery := WSRETREL(cPeriodo,cEvent,aFiliais)

	(cQuery)->(dbGoTop())

	While !(cQuery)->(eof())
		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTAnalitic := len(oEstruct["eventDetail"])
		oEstruct["eventDetail"][nTAnalitic]['doctype'] := ALLTRIM((cQuery)->TIPODOC)
		oEstruct["eventDetail"][nTAnalitic]['branch'] := ALLTRIM((cQuery)->FILIAL)
		oEstruct["eventDetail"][nTAnalitic]['taxNumberBranch'] := ALLTRIM((cQuery)->CNPJ)
		oEstruct["eventDetail"][nTAnalitic]['name'] := ALLTRIM((cQuery)->NOME)
		oEstruct["eventDetail"][nTAnalitic]['numberdocument'] := ALLTRIM((cQuery)->NUMDOCTO)
		oEstruct["eventDetail"][nTAnalitic]['keydocument'] := ALLTRIM((cQuery)->CHAVE)
		oEstruct["eventDetail"][nTAnalitic]['serie'] := ALLTRIM((cQuery)->SERIE)
		oEstruct["eventDetail"][nTAnalitic]['itemdoc'] := ALLTRIM((cQuery)->CODITEM)
		oEstruct["eventDetail"][nTAnalitic]['itemdescription'] := ALLTRIM((cQuery)->DESCITEM)
		oEstruct["eventDetail"][nTAnalitic]['type'] :=  ALLTRIM(ENCODEUTF8(RETTIPO((cQuery)->TPREPASSE)))
		oEstruct["eventDetail"][nTAnalitic]['issuedate'] := (cQuery)->DTEMISSAONF

		oEstruct["eventDetail"][nTAnalitic]['grossvalue'] := (cQuery)->VLRBRUTO
		oEstruct["eventDetail"][nTAnalitic]['totaltax'] := (cQuery)->TOTTRIB

        If __lApurBx
            nProp := TafCalProp((cQuery)->VLRBRUTO,(cQuery)->VLPGTO)
			oEstruct["eventDetail"][nTAnalitic]['payvalue'] := (cQuery)->VLPGTO
			oEstruct["eventDetail"][nTAnalitic]['paytax'] := Round((cQuery)->TOTTRIB * nProp, 2)
		else
			oEstruct["eventDetail"][nTAnalitic]['payvalue'] := 0
			oEstruct["eventDetail"][nTAnalitic]['paytax'] := 0
        EndIf

		oEstruct["eventDetail"][nTAnalitic]['proccess'] := ALLTRIM((cQuery)->PROCESSO)
		oEstruct["eventDetail"][nTAnalitic]['typeproccess'] := RETPROC(ALLTRIM((cQuery)->TIPOPROC))
		oEstruct["eventDetail"][nTAnalitic]['descriptionproccess'] := ALLTRIM((cQuery)->DESCPROC)
		oEstruct["eventDetail"][nTAnalitic]['suspendedvalue'] := (cQuery)->VLRNRET
		(cQuery)->(DbSkip())
	EndDo

Return

/*/{Protheus.doc} RETTIPO
    Retorna o tipo de repasse.
    @type  Static Function
    @author José Mauro
    @since 27/07/2020
    @version version
    @param 
        cTipo - Valor do tipo de repasse.
    @return 
        aTipoRet[VAL(cTipo)] - Posição do array referente ao valor do repasse informado.
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RETTIPO(cTipo)
	Local aTipoRet as array

	aTipoRet := {}

	AADD(aTipoRet, "Patrocínio")
	AADD(aTipoRet, "Licenciamento de marcas e símbolos")
	AADD(aTipoRet, "Publicidade")
	AADD(aTipoRet, "Propaganda")
	AADD(aTipoRet, "Transmissão de espetáculos")

Return aTipoRet[VAL(cTipo)]

/*/{Protheus.doc} RETPROC
    Retorna o tipo do processo.
    @type  Static Function
    @author José Mauro
    @since 27/07/2020
    @version version
    @param 
        cTipo - Tipo do processo.
    @return 
        cTipoPro - Descrição do tipo do processo.
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RETPROC(cTipo)

	Local aTipoRet := {}

	cTipo := Iif( Empty(cTipo), "3", cTipo )

	AADD(aTipoRet, "Administrativo")
	AADD(aTipoRet, "Judicial")
	AADD(aTipoRet, "")

Return aTipoRet[VAL(cTipo)]


/*/{Protheus.doc} R2050
	@type  Static Function
	@author user
	@since 29/07/2020
	@version version
	@param 
		aApurac - Array com os dados a serem retornados.
		oEstruct- Estrura a ser retornada para o fronted. - @Passada por referência.
	@return 
	@see (links_or_references)
	/*/
Static Function R2050(aApurac, oEstruct, aFilToReinf, cPeriod, cEvent)

	local cNrInsc		as character
	local cBranch		as character
	local cCompany		as character
	local cCompAux 		as character
	local cChave		as character
	local oPrepare		as object

	cNrInsc		:= ""
	cBranch		:= ""
	cCompany	:= ""
	cCompAux	:= ""
	cChave		:= ""
	oPrepare	:= Nil

	aApurac 	:= TafGetEvt(cPeriod, cEvent, @oPrepare)

	(aApurac[SINTETICO])->(DBGOTOP())

	While !(aApurac[SINTETICO])->(eof())
		cBranch    := Posicione("SM0",1,SM0->M0_CODIGO + (aApurac[SINTETICO])->FIL,"M0_FILIAL")
		cCompany   := SM0->M0_NOMECOM
		cNrInsc	   := SM0->M0_CGC
		cChave     := (aApurac[SINTETICO])->CHVNF + (aApurac[SINTETICO])->NUMITE
		lNewDoc	   := cChave <> cCompAux

		If lNewDoc
			aadd(oEstruct["eventDetail"],JsonObject():New())
			nTSintetic := len(oEstruct["eventDetail"])

			//Código da Filial
			oEstruct["eventDetail"][nTSintetic]["branchId"]   					:= (aApurac[SINTETICO])->FIL

			// Nome da Filial
			oEstruct["eventDetail"][nTSintetic]["branch"]     					:= alltrim(EncodeUTF8(cBranch))

			// CNPJ
			oEstruct["eventDetail"][nTSintetic]["taxNumber"]    				:= cNrInsc

			// Chave  da nota
			oEstruct["eventDetail"][nTSintetic]["keyInvoice"]   				:= (aApurac[SINTETICO])->CHVNF

			// Numero da nota
			oEstruct["eventDetail"][nTSintetic]["numberInvoice"]				:= (aApurac[SINTETICO])->NUMDOC

			// Serie da nota
			oEstruct["eventDetail"][nTSintetic]['serie'] 						:=  ALLTRIM((aApurac[SINTETICO])->SERIE)

			// Numero do Item
			oEstruct["eventDetail"][nTSintetic]["item"] 						:= (aApurac[SINTETICO])->NUMITE

			// Data de emissão
			oEstruct["eventDetail"][nTSintetic]["issueDate"] 					:= StoD((aApurac[SINTETICO])->DTEMISSAONF)

			// Valor receita bruta
			oEstruct["eventDetail"][nTSintetic]["grossValue"] 					:= (aApurac[SINTETICO])->VLRRECBRUTA

			// Indicativo de comercialização
			oEstruct["eventDetail"][nTSintetic]["commercialization"]  			:= EncodeUTF8(RetInfo2050((aApurac[SINTETICO])->INDCOM))

			//Tributo
			if (aApurac[SINTETICO])->CODTRI == "000013"
				oEstruct["eventDetail"][nTSintetic]["valueINSS"] 				:= (aApurac[SINTETICO])->VALOR

			elseIf (aApurac[SINTETICO])->CODTRI == "000024"
				oEstruct["eventDetail"][nTSintetic]["valueGilRat"] 				:= (aApurac[SINTETICO])->VALOR

			else
				oEstruct["eventDetail"][nTSintetic]["valueSenar"] 				:= (aApurac[SINTETICO])->VALOR
			endIf

			//Processos
			if !Empty((aApurac[SINTETICO])->NUMPRO)
				// Numero do processo
				oEstruct["eventDetail"][nTSintetic]["processNumber"]     			:= (aApurac[SINTETICO])->NUMPRO

				if (aApurac[SINTETICO])->CODTRI == "000013" .and. !Empty((aApurac[SINTETICO])->NUMPRO)
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessINSS"] 		:= (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueINSSNRet"]     	:= (aApurac[SINTETICO])->VALSUS

				elseif (aApurac[SINTETICO])->CODTRI == "000024" .and. !Empty((aApurac[SINTETICO])->NUMPRO)
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessGilRat"]   	:= (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueGilRatNRet"] 		:= (aApurac[SINTETICO])->VALSUS

				else
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessSenar"]		:= (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueSenarNRet"]		:= (aApurac[SINTETICO])->VALSUS

				endIf
			endIf
		else
			//Tributos
			if (aApurac[SINTETICO])->CODTRI == "000013"
				oEstruct["eventDetail"][nTSintetic]["valueINSS"] 				:= (aApurac[SINTETICO])->VALOR
			elseIf (aApurac[SINTETICO])->CODTRI == "000024"
				oEstruct["eventDetail"][nTSintetic]["valueGilRat"] 				:= (aApurac[SINTETICO])->VALOR
			else
				oEstruct["eventDetail"][nTSintetic]["valueSenar"] 				:= (aApurac[SINTETICO])->VALOR
			endIf

			//Processos
			if !Empty((aApurac[SINTETICO])->NUMPRO)
				// Numero do processo
				oEstruct["eventDetail"][nTSintetic]["processNumber"] 			:= (aApurac[SINTETICO])->NUMPRO

				if (aApurac[SINTETICO])->CODTRI == "000013"
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessINSS"]    	:= (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueINSSNRet"]     	:= (aApurac[SINTETICO])->VALSUS

				elseif (aApurac[SINTETICO])->CODTRI == "000024"
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessGilRat"]    := (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueGilRatNRet"]  	:= (aApurac[SINTETICO])->VALSUS

				else
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessSenar"]    	:= (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueSenarNRet"]    	:= (aApurac[SINTETICO])->VALSUS

				endIf
			endIf
		endIf

		//Tratamento para enviar os campos mesmo se não tiver processo
		if empty(oEstruct["eventDetail"][nTSintetic]["processNumber"] )
			oEstruct["eventDetail"][nTSintetic]["processNumber"] 		:= ""
		endIf

		if empty(oEstruct["eventDetail"][nTSintetic]["codeProcessINSS"] )
			oEstruct["eventDetail"][nTSintetic]["codeProcessINSS"]    	:= ""
			oEstruct["eventDetail"][nTSintetic]["valueINSSNRet"]     	:= 0
		endIf

		If empty(oEstruct["eventDetail"][nTSintetic]["codeProcessGilRat"] )
			oEstruct["eventDetail"][nTSintetic]["codeProcessGilRat"]    := ""
			oEstruct["eventDetail"][nTSintetic]["valueGilRatNRet"]  	:= 0
		endIf

		If empty(oEstruct["eventDetail"][nTSintetic]["codeProcessSenar"] )
			oEstruct["eventDetail"][nTSintetic]["codeProcessSenar"]    	:= ""
			oEstruct["eventDetail"][nTSintetic]["valueSenarNRet"]    	:= 0
		endIf

		cCompAux := cChave

		(aApurac[SINTETICO])->(dbSkip())
	EndDo

	( aApurac[SINTETICO] )->( dbCloseArea())
	if oPrepare != Nil
		oPrepare:Destroy()
		oPrepare := nil
	endif

Return

/*/{Protheus.doc} R2055
	@type  Static Function
	@author Renan Gomes
	@since 05/02/2021
	@version version
	@param 
		aApurac - Array com os dados a serem retornados.
		oEstruct- Estrura a ser retornada para o fronted. - @Passada por referência.
	@return 
	@see (links_or_references)
	/*/
Static Function R2055(aApurac, oEstruct, aFilToReinf, cPeriod, cEvent)

	local cNrInsc	as character
	local cBranch	as character
	local cCompany	as character
	local cCompAux 	as character
	local cChave	as character
	local cGpEpFil	as character
	local nPos		as numeric
	local nTamFil   as numeric
	local aSM0Fil  	as array
	local aCmpsC1E 	as array
	local lColPAA   as logical
	local lColNCPF	as logical

	cNrInsc	 := ""
	cBranch	 := ""
	cCompany := ""
	cCompAux := ""
	cChave	 := ""
	cGpEpFil := ""
	nPos	 := 0
	aApurac  := TafGetEvt(cPeriod, cEvent)
	aSM0Fil  := {}
	aCmpsC1E := {}
	lColPAA  := TAFColumnPos("C1E_PAA")
	lColNCPF := TAFColumnPos("C1E_NRCPF")
	nTamFil  := TamSX3( "C1E_FILTAF" )[1]

	(aApurac[SINTETICO])->(DBGOTOP())
	While !(aApurac[SINTETICO])->(eof())
		//Cache para cBranch, senao executaria o posicione na SM0 para cada registro.
		cGpEpFil := SM0->M0_CODIGO + (aApurac[SINTETICO])->FIL
		nPos := aScan( aSM0Fil, {|x| Upper(AllTrim(x[GEFIL])) == cGpEpFil } )
		if nPos > 0
			cBranch := aSM0Fil[nPos][M0FIL]
		else
			cBranch := Alltrim( Posicione("SM0",1,SM0->M0_CODIGO + (aApurac[SINTETICO])->FIL,"M0_FILIAL") )
			AAdd(aSM0Fil, { cGpEpFil, cBranch } )
		endif
		cCompany := alltrim((aApurac[SINTETICO])->NOME)
		cNrInsc	 := alltrim((aApurac[SINTETICO])->PARTI)
		cChave   := (aApurac[SINTETICO])->FIL + (aApurac[SINTETICO])->CHVNF + (aApurac[SINTETICO])->NUMITE
		lNewDoc	 := cChave <> cCompAux

		If lNewDoc
			aadd(oEstruct["eventDetail"],JsonObject():New())
			nTSintetic := len(oEstruct["eventDetail"])

			//Código da Filial
			oEstruct["eventDetail"][nTSintetic]["branchId"]   		 := (aApurac[SINTETICO])->FIL

			// Nome da Filial
			oEstruct["eventDetail"][nTSintetic]["branch"]     		 := alltrim(EncodeUTF8(cBranch))

			// CNPJ
			oEstruct["eventDetail"][nTSintetic]["taxNumber"]    	 := cNrInsc

			// Chave  da nota
			oEstruct["eventDetail"][nTSintetic]["keyInvoice"]   	 := (aApurac[SINTETICO])->CHVNF

			// Numero da nota
			oEstruct["eventDetail"][nTSintetic]["numberInvoice"]	 := (aApurac[SINTETICO])->NUMDOC

			// Serie da nota
			oEstruct["eventDetail"][nTSintetic]['serie'] 			 := ALLTRIM((aApurac[SINTETICO])->SERIE)

			// Tipo Inscrição
			oEstruct["eventDetail"][nTSintetic]['typeOfInscription'] := IIf(len(cNrInsc) == 14, "1 - CNPJ", "2 - CPF")

			// Numero do Item
			oEstruct["eventDetail"][nTSintetic]["item"] 			 := (aApurac[SINTETICO])->NUMITE

			// Data de emissão
			oEstruct["eventDetail"][nTSintetic]["issueDate"] 		 := (aApurac[SINTETICO])->DTEMISSAONF

			// Valor receita bruta
			oEstruct["eventDetail"][nTSintetic]["grossValue"] 		 := (aApurac[SINTETICO])->VLRRECBRUTA

			// Indicativo de comercialização
			oEstruct["eventDetail"][nTSintetic]["acquisition"]  	 := EncodeUTF8(RetIndAq2055((aApurac[SINTETICO])->INDISE,aApurac[SINTETICO],cGpEpFil,@aCmpsC1E,lColPAA,lColNCPF,nTamFil))

			//Tributo
			if (aApurac[SINTETICO])->CODTRI == "000013"
				oEstruct["eventDetail"][nTSintetic]["valueINSS"] 	 := (aApurac[SINTETICO])->VALOR

			elseIf (aApurac[SINTETICO])->CODTRI == "000024"
				oEstruct["eventDetail"][nTSintetic]["valueGilRat"] 	 := (aApurac[SINTETICO])->VALOR

			else
				oEstruct["eventDetail"][nTSintetic]["valueSenar"] 	 := (aApurac[SINTETICO])->VALOR
			endIf

			//Processos
			if !Empty((aApurac[SINTETICO])->NUMPRO)
				// Numero do processo
				oEstruct["eventDetail"][nTSintetic]["processNumber"]			:= (aApurac[SINTETICO])->NUMPRO

				if (aApurac[SINTETICO])->CODTRI == "000013" .and. !Empty((aApurac[SINTETICO])->NUMPRO)
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessINSS"] 		:= (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueINSSNRet"]     	:= (aApurac[SINTETICO])->VALSUS

				elseif (aApurac[SINTETICO])->CODTRI == "000024" .and. !Empty((aApurac[SINTETICO])->NUMPRO)
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessGilRat"]   	:= (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueGilRatNRet"] 		:= (aApurac[SINTETICO])->VALSUS

				else
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessSenar"]		:= (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueSenarNRet"]		:= (aApurac[SINTETICO])->VALSUS

				endIf
			endIf
		else
			//Tributos
			if (aApurac[SINTETICO])->CODTRI == "000013"
				oEstruct["eventDetail"][nTSintetic]["valueINSS"] 				:= (aApurac[SINTETICO])->VALOR
			elseIf (aApurac[SINTETICO])->CODTRI == "000024"
				oEstruct["eventDetail"][nTSintetic]["valueGilRat"] 				:= (aApurac[SINTETICO])->VALOR
			else
				oEstruct["eventDetail"][nTSintetic]["valueSenar"] 				:= (aApurac[SINTETICO])->VALOR
			endIf

			//Processos
			if !Empty((aApurac[SINTETICO])->NUMPRO)
				// Numero do processo
				oEstruct["eventDetail"][nTSintetic]["processNumber"] 			:= (aApurac[SINTETICO])->NUMPRO

				if (aApurac[SINTETICO])->CODTRI == "000013"
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessINSS"]    	:= (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueINSSNRet"]     	:= (aApurac[SINTETICO])->VALSUS

				elseif (aApurac[SINTETICO])->CODTRI == "000024"
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessGilRat"]    := (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueGilRatNRet"]  	:= (aApurac[SINTETICO])->VALSUS

				else
					// Código de suspensão
					oEstruct["eventDetail"][nTSintetic]["codeProcessSenar"]    	:= (aApurac[SINTETICO])->CODSUS

					//Valor suspenso
					oEstruct["eventDetail"][nTSintetic]["valueSenarNRet"]    	:= (aApurac[SINTETICO])->VALSUS

				endIf
			endIf
		endIf

		//Tratamento para enviar os campos mesmo se não tiver processo
		if empty(oEstruct["eventDetail"][nTSintetic]["processNumber"] )
			oEstruct["eventDetail"][nTSintetic]["processNumber"] 		:= ""
		endIf

		if empty(oEstruct["eventDetail"][nTSintetic]["codeProcessINSS"] )
			oEstruct["eventDetail"][nTSintetic]["codeProcessINSS"]    	:= ""
			oEstruct["eventDetail"][nTSintetic]["valueINSSNRet"]     	:= 0
		endIf

		If empty(oEstruct["eventDetail"][nTSintetic]["codeProcessGilRat"] )
			oEstruct["eventDetail"][nTSintetic]["codeProcessGilRat"]    := ""
			oEstruct["eventDetail"][nTSintetic]["valueGilRatNRet"]  	:= 0
		endIf

		If empty(oEstruct["eventDetail"][nTSintetic]["codeProcessSenar"] )
			oEstruct["eventDetail"][nTSintetic]["codeProcessSenar"]    	:= ""
			oEstruct["eventDetail"][nTSintetic]["valueSenarNRet"]    	:= 0
		endIf
		
		//Indicativo da opcao rural
		oEstruct["eventDetail"][nTSintetic]["indCp"]  := IIf((aApurac[SINTETICO])->INDCP == '2', "2 - Sobre a folha de pagamento", "1 - Sobre a comercializacao da sua producao")

		cCompAux := cChave

		(aApurac[SINTETICO])->(dbSkip())
	EndDo

Return

/*/{Protheus.doc} R3010
	
	@type  Function
	@author José Mauro
	@since 28/08/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function R3010(aApurac, oEstruct, aFilToReinf, cPeriod, cEvent)
	Local cQuery 	 as character
	Local nX     	 as numeric
	Local nTSintetic as numeric
	Local aFil   	 as array
	Local aFiliais 	 as array

	cQuery     := ""
	aFil 	   := {}
	aFiliais   := {}
	nX         := 1
	nTSintetic := 1

	aFil 	  := wsLoadFil()

	For nX := 1 to len(aFil)
		aadd(aFiliais, {aFil[nX][1],aFil[nX][3]})
	Next nX

	cQuery := WSQry3010(cPeriod, aFiliais, 1 )
	(cQuery)->(dbGoTop())

	While !(cQuery)->(eof())
		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])

		oEstruct["eventDetail"][nTSintetic]["branch"]   			:= ALLTRIM((cQuery)->FILIAL)
		oEstruct["eventDetail"][nTSintetic]["numberId"]   			:= ALLTRIM((cQuery)->BOLETIM)
		oEstruct["eventDetail"][nTSintetic]["typeOfCompetition"]   	:= RETTYPE(ALLTRIM((cQuery)->TIPO))
		oEstruct["eventDetail"][nTSintetic]["category"]   			:= RETCATEG(ALLTRIM((cQuery)->CATEGORIA))
		oEstruct["eventDetail"][nTSintetic]["modality"]   			:= ALLTRIM((cQuery)->MODALIDADE)
		oEstruct["eventDetail"][nTSintetic]["nameOfCompetition"]   	:= ALLTRIM((cQuery)->COMPETICAO)
		oEstruct["eventDetail"][nTSintetic]["homeTeam"]   			:= ALLTRIM((cQuery)->CNPJMAND)
		oEstruct["eventDetail"][nTSintetic]["visitors"]   			:= ALLTRIM((cQuery)->CNPJVI)
		oEstruct["eventDetail"][nTSintetic]["nameVisitor"]   		:= ALLTRIM((cQuery)->VISITANTE)
		oEstruct["eventDetail"][nTSintetic]["square"]   			:= ALLTRIM((cQuery)->PRACA)
		oEstruct["eventDetail"][nTSintetic]["country"]   			:= ALLTRIM((cQuery)->ESTADO)
		oEstruct["eventDetail"][nTSintetic]["city"]   				:= ALLTRIM((cQuery)->CIDADE)
		oEstruct["eventDetail"][nTSintetic]["payers"]   			:= (cQuery)->PAGANTES
		oEstruct["eventDetail"][nTSintetic]["notPayers"]   			:= (cQuery)->NAOPAGANTES
		oEstruct["eventDetail"][nTSintetic]["totalGross"]   		:= (cQuery)->TOTALBRUTO
		oEstruct["eventDetail"][nTSintetic]["contributionValue"]   	:= (cQuery)->TRIBUTO
		oEstruct["eventDetail"][nTSintetic]["totalWithoutTaxes"]   	:= (cQuery)->RECEITA
		oEstruct["eventDetail"][nTSintetic]["totalOfTaxes"]   		:= (cQuery)->VALORRETIDO

		(cQuery)->(dbSkip())
	EndDo

Return

/*/{Protheus.doc} R9005
	Evento totalizador R9005

	@type  Static Function
	@author Wesley Matos
	@since 30/01/2023
	@version 1.0
/*/
Static Function R9005(aApurac as array, oEstruct as object, aFilToReinf as array, cPeriodo as character, cEvent as character)
	Local cQuery 	 as character
	Local nX     	 as numeric
	Local nTSintetic as numeric
	Local aFil   	 as array
	Local aFiliais 	 as array

	cQuery     := ""
	aFil 	   := {}
	aFiliais   := {}
	nX         := 1
	nTSintetic := 1

	aFil 	  := wsLoadFil()

	For nX := 1 to len(aFil)
		aadd(aFiliais, {aFil[nX][1],aFil[nX][3]})
	Next nX

	cQuery := QryRel9005(cPeriodo,  aFiliais)
	
	(cQuery)->(dbGoTop())

	While !(cQuery)->(eof())
		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])

		oEstruct["eventDetail"][nTSintetic]["branchId"]                     := ALLTRIM((cQuery)->FILIAL)
		oEstruct["eventDetail"][nTSintetic]["company"]                      := FWSM0Util( ):GetSM0Data( ,(cQuery)->FILIAL , { 'M0_FILIAL' } )[1][2] 
		oEstruct["eventDetail"][nTSintetic]["taxNumberBranch"]              := FWSM0Util( ):GetSM0Data( ,(cQuery)->FILIAL , { 'M0_CGC'    } )[1][2] 
		oEstruct["eventDetail"][nTSintetic]["event"]                        := ALLTRIM((cQuery)->EVENTO)
		oEstruct["eventDetail"][nTSintetic]["yield"]                        := ALLTRIM((cQuery)->NATREN)
		oEstruct["eventDetail"][nTSintetic]["recipeCode"]                   := ALLTRIM((cQuery)->CODREC)
		
		DO CASE
			CASE (cQuery)->PERIODO == '1'
		//MENSAL
		oEstruct["eventDetail"][nTSintetic]["taxBaseMonth"]           		:= (cQuery)->BASETRI   
		oEstruct["eventDetail"][nTSintetic]["taxValueMonth"]                := (cQuery)->VALTRIB   
		oEstruct["eventDetail"][nTSintetic]["taxBaseMonthSuspended"]        := (cQuery)->VLTRIBSUSP
		oEstruct["eventDetail"][nTSintetic]["taxValueMonthSuspended"]       := (cQuery)->VLCALCSUSP
			CASE (cQuery)->PERIODO == '2'
		//QUINZENAL
		oEstruct["eventDetail"][nTSintetic]["taxBaseBiweekly"]        		:= (cQuery)->BASETRI   
		oEstruct["eventDetail"][nTSintetic]["taxValueBiweekly"]        		:= (cQuery)->VALTRIB   
		oEstruct["eventDetail"][nTSintetic]["taxValueBiweeklySuspended"]    := (cQuery)->VLTRIBSUSP
		oEstruct["eventDetail"][nTSintetic]["taxValueBiweekly"]        		:= (cQuery)->VLCALCSUSP
			CASE (cQuery)->PERIODO == '3'
		//DECENDIAL
		oEstruct["eventDetail"][nTSintetic]["taxBaseDecennial"]        		:= (cQuery)->BASETRI   
		oEstruct["eventDetail"][nTSintetic]["taxValueDecennial"]        	:= (cQuery)->VALTRIB   
		oEstruct["eventDetail"][nTSintetic]["taxBaseDecennialSuspended"]    := (cQuery)->VLTRIBSUSP
		oEstruct["eventDetail"][nTSintetic]["taxValueDecennialSuspended"]   := (cQuery)->VLCALCSUSP
			CASE (cQuery)->PERIODO == '4'
		//SEMANAL
		oEstruct["eventDetail"][nTSintetic]["taxBaseWeekly"]        		:= (cQuery)->BASETRI   
		oEstruct["eventDetail"][nTSintetic]["taxValueWeekly"]        		:= (cQuery)->VALTRIB   
		oEstruct["eventDetail"][nTSintetic]["taxBaseWeeklySuspended"]   	:= (cQuery)->VLTRIBSUSP
		oEstruct["eventDetail"][nTSintetic]["taxValueWeeklySuspended"]   	:= (cQuery)->VLCALCSUSP
			CASE (cQuery)->PERIODO == '5'
		//DIARIO
		oEstruct["eventDetail"][nTSintetic]["taxBaseDaily"]        			:= (cQuery)->BASETRI   
		oEstruct["eventDetail"][nTSintetic]["taxValueDaily"]        		:= (cQuery)->VALTRIB   
		oEstruct["eventDetail"][nTSintetic]["taxBaseDailySuspended"]   		:= (cQuery)->VLTRIBSUSP
		oEstruct["eventDetail"][nTSintetic]["taxValueDailySuspended"]   	:= (cQuery)->VLCALCSUSP
		ENDCASE

		(cQuery)->(dbSkip())
	EndDo
Return

/*/{Protheus.doc} R9015
	Evento totalizador R9015

	@type  Static Function
	@author Jose Felipe
	@since 31/01/2023
	@version 1.0
/*/
Static Function R9015(aApurac as array, oEstruct as object, aFilToReinf as array, cPeriodo as character, cEvent as character)
	Local cQuery 	 as character
	Local nX     	 as numeric
	Local nTSintetic as numeric
	Local aFil   	 as array
	Local aFiliais 	 as array

	cQuery     := ""
	aFil 	   := {}
	aFiliais   := {}
	nX         := 1
	nTSintetic := 1

	aFil 	  := wsLoadFil()

	For nX := 1 to len(aFil)
		aadd(aFiliais, {aFil[nX][1],aFil[nX][3]})
	Next nX

	cQuery := QryRel9015(cPeriodo,  aFiliais)
	
	(cQuery)->(dbGoTop())

	While !(cQuery)->(eof())
		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])

		oEstruct["eventDetail"][nTSintetic]["branch"]                       := ALLTRIM((cQuery)->FILIAL)
		oEstruct["eventDetail"][nTSintetic]["branchName"]                   := FWSM0Util( ):GetSM0Data( ,(cQuery)->FILIAL , { 'M0_FILIAL' } )[1][2] 
		oEstruct["eventDetail"][nTSintetic]["branchTaxNumber"]              := FWSM0Util( ):GetSM0Data( ,(cQuery)->FILIAL , { 'M0_CGC'    } )[1][2] 
		oEstruct["eventDetail"][nTSintetic]["event"]                        := ALLTRIM((cQuery)->EVENTO)
		oEstruct["eventDetail"][nTSintetic]["yield"]                        := ALLTRIM((cQuery)->NATREN)
		oEstruct["eventDetail"][nTSintetic]["grossCode"]                    := ALLTRIM((cQuery)->CODRECEITA)
			
		DO CASE
			CASE (cQuery)->PERIODO == '1'
			//MENSAL
			oEstruct["eventDetail"][nTSintetic]["taxValueMonth"]                := (cQuery)->VALTRIB
			oEstruct["eventDetail"][nTSintetic]["taxValueMonthSuspended"]       := (cQuery)->VLTRIBSUSP
			//oEstruct["eventDetail"][nTSintetic]["taxValueMonthSuspended"]       := (cQuery)->VLCALCSUSP
			
			CASE (cQuery)->PERIODO == '2'
			//QUINZENAL
			oEstruct["eventDetail"][nTSintetic]["taxValueBiweekly"]             := (cQuery)->VALTRIB
			oEstruct["eventDetail"][nTSintetic]["taxValueBiweeklySuspended"]    := (cQuery)->VLTRIBSUSP
			//oEstruct["eventDetail"][nTSintetic]["taxValueBiweeklySuspended"]    := (cQuery)->VLCALCSUSP
			
			CASE (cQuery)->PERIODO == '3'
			//DECENDIAL
			oEstruct["eventDetail"][nTSintetic]["taxValueDecennial"]            := (cQuery)->VALTRIB
			oEstruct["eventDetail"][nTSintetic]["taxValueDecennialSuspended"]   := (cQuery)->VLTRIBSUSP

			CASE (cQuery)->PERIODO == '4'
			//SEMANAL
			oEstruct["eventDetail"][nTSintetic]["taxValueWeekly"]               := (cQuery)->VALTRIB
			oEstruct["eventDetail"][nTSintetic]["taxValueWeeklySuspended"]      := (cQuery)->VLTRIBSUSP
			CASE (cQuery)->PERIODO == '5'
			//DIARIO
			oEstruct["eventDetail"][nTSintetic]["taxValueDaily"]                := (cQuery)->VALTRIB
			oEstruct["eventDetail"][nTSintetic]["taxValueDailySuspended"]       := (cQuery)->VLTRIBSUSP
		ENDCASE

		(cQuery)->(dbSkip())
	EndDo
Return

/*/{Protheus.doc} R4010

	@type  Static Function
	@author Denis Souza
	@since 06/02/2023
	@version 1.0
/*/
Static Function R4010(aApurac as array, oEstruct  as object, aFilToReinf as array, cPeriod as character, cEvent as character)

Local cQuery   as character
Local cBanco   as character
Local cAlias   as character
Local cCompC1G as character
Local cCompC1H as character
Local cCompV3X as character
Local cCompV4F as character
Local cIndNIF  as character
Local nX       as numeric
Local nTm      as numeric
Local aFil     as array
Local aInfEUF  as array
Local aFiliais as array
Local aBind    as array
Local aFilsC20 as array
Local aFilsLEM as array
Local aFilsV3U as array
Local aFilsV4B as array
Local oTabTemp as object
Local oPrepare as object

Default aApurac     := {}
Default oEstruct    := Nil
Default aFilToReinf := {}
Default cPeriod     := ''
Default cEvent      := ''

nX		 := 1
nTm 	 := 1
aFil	 := {}
aFiliais := {}
aBind    := {}
cQuery   := ""
cIndNIF  := ""
oTabTemp := Nil
oPrepare := Nil
cBanco   := Upper(AllTrim(tcGetDB()))
cCompC1G := Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3)))
cCompC1H := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
cCompV3X := Upper(AllTrim(FWModeAccess("V3X",1)+FWModeAccess("V3X",2)+FWModeAccess("V3X",3)))
cCompV4F := Upper(AllTrim(FWModeAccess("V4F",1)+FWModeAccess("V4F",2)+FWModeAccess("V4F",3)))
aFil 	 := wsLoadFil()

For nX := 1 to len(aFil)
	aadd(aFiliais,{aFil[nX][1],aFil[nX][3]})
Next nX

aInfEUF  := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
aFilsC20 := Separa(StrTran(StrTran(StrTran(TafRetFilC("C20", aFiliais),"(",""),")",""),"'",""),",")
aFilsLEM := Separa(StrTran(StrTran(StrTran(TafRetFilC("LEM", aFiliais),"(",""),")",""),"'",""),",")
aFilsV3U := Separa(StrTran(StrTran(StrTran(TafRetFilC("V3U", aFiliais),"(",""),")",""),"'",""),",")
aFilsV4B := Separa(StrTran(StrTran(StrTran(TafRetFilC("V4B", aFiliais),"(",""),")",""),"'",""),",")
cPeriod  := substr(cPeriod,3,4) + substr(cPeriod,1,2)

cQuery := WsRel4010(cPeriod,cCompC1G,cCompC1H,aInfEUF,aFilsC20,aFilsLEM,aFilsV3U,aFilsV4B,cBanco,cCompV3X,cCompV4F,@oTabTemp,@aBind)
If !("DB2" $ cBanco )
	cQuery := ChangeQuery(cQuery)
endif

cAlias := GetNextAlias()
oPrepare := FwExecStatement():New(cQuery)

For nX := 1 To Len(aBind)
	If Valtype(aBind[nX]) == 'C'
		oPrepare:setString( nX, aBind[nX] )
	ElseIf Valtype(aBind[nX]) == 'N'
		oPrepare:setNumeric( nX, aBind[nX] )
	ElseIf Valtype(aBind[nX]) == 'A'
	    oPrepare:setIn( nX, aBind[nX] )
	Endif
Next nX

oPrepare:cbasequery := oPrepare:getfixquery()
oPrepare:OpenAlias(cAlias)

aSize(aBind,0)

if valtype( oTabTemp ) == 'O' //Destroi temporaria logo apos o seu uso no TCQuery
	oTabTemp:Delete()
	FreeObj(oTabTemp)
	oTabTemp := Nil
endif

(cAlias)->(dbGoTop())
While !(cAlias)->(eof())
	aadd(oEstruct["eventDetail"],JsonObject():New())
	nTm := len(oEstruct["eventDetail"])

	//01 Filial
	oEstruct["eventDetail"][nTm]["branchId"]				 := EncodeUTF8(Alltrim((cAlias)->FILIAL))
	//02 Descrição da Filial
	oEstruct["eventDetail"][nTm]['branchName']				 := EncodeUTF8(Alltrim(FWSM0Util():GetSM0Data(,(cAlias)->FILIAL,{ 'M0_FILIAL'})[1][2]))
	//03 CNPJ da Filial
	oEstruct["eventDetail"][nTm]['taxNumberBranch']			 := EncodeUTF8(FWSM0Util():GetSM0Data(,(cAlias)->FILIAL,{'M0_CGC'})[1][2])
	//04 CPF Beneficiário
	oEstruct["eventDetail"][nTm]['participantCpf']			 := EncodeUTF8(Alltrim((cAlias)->CPF))
	//05 Código participante (beneficiário)
	oEstruct["eventDetail"][nTm]['participantCode']			 := EncodeUTF8(Alltrim((cAlias)->CODPAR))
	//06 Indicativo NIF
	oEstruct["eventDetail"][nTm]['nifIndicator']			 := EncodeUTF8(Alltrim((cAlias)->INDNIF))
	//07 Numero NIF
	oEstruct["eventDetail"][nTm]['nifNumber']				 := EncodeUTF8(Alltrim((cAlias)->NIF))
	//08 Forma Tributação
	oEstruct["eventDetail"][nTm]['formOfTax']				 := EncodeUTF8(Alltrim(SubStr((cAlias)->FRMTRIB,1,50)))
	//09 Nome Beneficiário
	oEstruct["eventDetail"][nTm]['participantName']			 := EncodeUTF8(Alltrim((cAlias)->NOME))
	//10 Tipo
	oEstruct["eventDetail"][nTm]['documentType']			 := EncodeUTF8(Alltrim((cAlias)->ROTINA))
	//11 Série / Parcela Documento
	oEstruct["eventDetail"][nTm]['invoiceSeries']			 := EncodeUTF8(Alltrim((cAlias)->SERIEPARC))
	//12 Número Documento
	oEstruct["eventDetail"][nTm]['invoiceNumber']			 := EncodeUTF8(Alltrim((cAlias)->DOCTO))
	//13 Data Emissão/Pagamento
	oEstruct["eventDetail"][nTm]['issueDate']				 := stod((cAlias)->DTEMISPGT)
	//14 Id do Documento
	oEstruct["eventDetail"][nTm]["invoiceId"]				 := EncodeUTF8(Alltrim((cAlias)->ID))
	//15 Item Documento
	oEstruct["eventDetail"][nTm]["itemNumber"]				 := EncodeUTF8(Alltrim((cAlias)->NUMITE))
	//16 Natureza de Rendimento
	oEstruct["eventDetail"][nTm]["yield"]  			 		 := EncodeUTF8(Alltrim((cAlias)->CODNAT))
	//17 Indicativo de FCI/SCP
	oEstruct["eventDetail"][nTm]['indicatorSCP']			 := EncodeUTF8(Alltrim((cAlias)->INDFCISCP))
	//18 CNPJ da FCI/SCP
	oEstruct["eventDetail"][nTm]['taxNumberSCP']			 := EncodeUTF8(Alltrim((cAlias)->CNPJFCISCP))
	//19 Informação de RRA ou Processo Judicial
	oEstruct["eventDetail"][nTm]['rraInformation']			 := EncodeUTF8(Alltrim((cAlias)->INDRRA))
	//20 N° de Inscrição do Processo RRA/Processo Judicial
	oEstruct["eventDetail"][nTm]['rraNumber']				 := EncodeUTF8(Alltrim((cAlias)->NRRRAPJD))
	//21 CNPJ Origem Recurso
	oEstruct["eventDetail"][nTm]['sourceTaxNumber']			 := EncodeUTF8(Alltrim((cAlias)->CNPJOR))
	//22 Total de Custas com Advogados
	oEstruct["eventDetail"][nTm]['totalValueLawyer']		 := (cAlias)->CUSTADV
	//23 Total de Custas Judiciais
	oEstruct["eventDetail"][nTm]['totalCourtCosts']			 := (cAlias)->CUSTJUD
	//24 Valor do Documento
	oEstruct["eventDetail"][nTm]['grossValue']				 := (cAlias)->VALBRUTO
	//25 Base de Cálculo IR
	oEstruct["eventDetail"][nTm]['taxBaseIR']				 := (cAlias)->(BASEIR + TOTDEDU)
	//26 Alíquota do IR
	oEstruct["eventDetail"][nTm]['aliquotIR']				 := (cAlias)->ALIQIR
	//27 Valor do IR
	oEstruct["eventDetail"][nTm]['taxIR']					 := (cAlias)->VALIR
	//28 Total de deduções
	oEstruct["eventDetail"][nTm]['deductionValue']			 := (cAlias)->TOTDEDU
	//29 Valor total das deduções de dependentes
	oEstruct["eventDetail"][nTm]['deductionValueDependents'] := (cAlias)->TDEDUDEP
	//30 Total de Rendimentos Isentos
	oEstruct["eventDetail"][nTm]['exemptIncome']			 := (cAlias)->TOTISEN
	//31 Valor do Rendimento Suspenso por processo judicial
	oEstruct["eventDetail"][nTm]['suspendedIncome']			 := (cAlias)->VBSIR
	//32 Valor da retenção não efetuada devido Processo Ref
	oEstruct["eventDetail"][nTm]['suspendedTaxValue']		 := (cAlias)->VRSIR
	//33 Valor da dedução suspensa
	oEstruct["eventDetail"][nTm]['suspendedDeduction']		 := (cAlias)->TDEDUSUSP
	//34 Número do Processo Referenciado
	oEstruct["eventDetail"][nTm]['proccesNumber']			 := EncodeUTF8(Alltrim((cAlias)->NPROCREF))
	//35 CNPJ PLS
	oEstruct["eventDetail"][nTm]['taxNumberPLS']			 := EncodeUTF8(Alltrim((cAlias)->CNPJPLS))
	//36 Beneficiário PLS
	oEstruct["eventDetail"][nTm]['participantPLS']			 := EncodeUTF8(Alltrim((cAlias)->BENEPLS))
	//37 CPF Dependente
	oEstruct["eventDetail"][nTm]['cpfDependents']			 := EncodeUTF8(Alltrim((cAlias)->CPFDEPE))
	//38 Tipo Pagamento (Reembolso ou Co-Participação)
	oEstruct["eventDetail"][nTm]['typeOfPayment']			 := EncodeUTF8(Alltrim((cAlias)->TIPPGTO))
	//39 Valor pago PLS
	oEstruct["eventDetail"][nTm]['valuePLS']				 := (cAlias)->VPGTPLS
	//40 Reembolso ano anterior
	oEstruct["eventDetail"][nTm]['refundPreviousYear']		 := (cAlias)->REEMBAN
	//41 Tipo de Inscrição Médico
	oEstruct["eventDetail"][nTm]['typeOfInscriptionMedic']	 := EncodeUTF8(Alltrim((cAlias)->TPMEDIC))
	//42 Nr. Inscrição Médico
	oEstruct["eventDetail"][nTm]['taxNumberMedic']			 := EncodeUTF8(Alltrim((cAlias)->NINSMED))

	(cAlias)->(dbSkip())
EndDo

(cAlias)->(DbCloseArea())

If oPrepare != Nil
	oPrepare:Destroy()
	oPrepare := Nil
EndIf

Return Nil

/*/{Protheus.doc} R4020

	@type  Static Function
	@author Denis Souza / Jose Riquelme
	@since 06/02/2023
	@version 1.0
/*/
Static Function R4020(aApurac as array, oEstruct  as object, aFilToReinf as array, cPeriod as character, cEvent as character)

Local cQuery 	 as character
Local cBanco	 as character
Local cFilsC20   as character
Local cFilsLEM   as character
Local cFilsV3U   as character
Local cAlias     as character
Local cCompC1H	 as character
Local cCompC1G   as character
Local cCompV3X   as character
Local cCompV4F   as character 
Local nX     	 as numeric
Local nTSintetic as numeric
Local aFil   	 as array
Local aInfEUF 	 as array
Local aFiliais 	 as array
Local cIndNIF    as character

Default aApurac     := {}
Default oEstruct    := Nil
Default aFilToReinf := {}
Default cPeriod     := ''
Default cEvent      := ''

cQuery     := ""
aFiliais   := {}
cBanco     := upper( allTrim( tcGetDB() ) )
cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
cCompC1G   := Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3)))
cCompV3X   := Upper(AllTrim(FWModeAccess("V3X",1)+FWModeAccess("V3X",2)+FWModeAccess("V3X",3)))
cCompV4F   := Upper(AllTrim(FWModeAccess("V4F",1)+FWModeAccess("V4F",2)+FWModeAccess("V4F",3)))

nX         := 1
nTSintetic := 1
aFil       := wsLoadFil()	
For nX := 1 to len(aFil)
	aadd(aFiliais, {aFil[nX][1],aFil[nX][3]})
Next nX

aInfEUF  := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))

cFilsC20 := TafRetFilC( "C20", aFiliais )
cFilsLEM := TafRetFilC( "LEM", aFiliais )
cFilsV3U := TafRetFilC( "V3U", aFiliais )

cPeriod := substr(cPeriod,3,4) + substr(cPeriod,1,2)

cQuery  := WsRel4020( cPeriod, cCompC1H, cCompC1G, aInfEUF, cFilsC20, cFilsLEM, cFilsV3U, cBanco, cCompV3X, cCompV4F )
If !("DB2" $ cBanco )
	cQuery  := ChangeQuery( cQuery )
EndIf
cAlias  := GetNextAlias()
TCQuery cQuery New Alias (cAlias)

(cAlias)->(dbGoTop())

While !(cAlias)->(eof())

	if empty( (cAlias)->INDNIF  )
		cIndNIF := 'Nao Informado'
	elseif (cAlias)->INDNIF == '1'
		cIndNIF := 'Possui'
	elseif (cAlias)->INDNIF == '2'
		cIndNIF := 'Dispensado'
	elseif (cAlias)->INDNIF == '3'
		cIndNIF := 'País não exige'
	endif

	aadd(oEstruct["eventDetail"],JsonObject():New())
	nTSintetic := len(oEstruct["eventDetail"])

	//01 Filial
	oEstruct["eventDetail"][nTSintetic]["branchId"]             := EncodeUTF8(Alltrim((cAlias)->FILIAL))
	//02 Descrição da Filial
	oEstruct["eventDetail"][nTSintetic]["branch"]               := EncodeUTF8(Alltrim(FWSM0Util():GetSM0Data(,(cAlias)->FILIAL,{ 'M0_FILIAL'})[1][2]))
	//03 CNPJ da Filial
	oEstruct["eventDetail"][nTSintetic]["taxNumberBranch"]      := EncodeUTF8(FWSM0Util():GetSM0Data(,(cAlias)->FILIAL,{'M0_CGC'})[1][2])
	//04 CNPJ Participante
	oEstruct["eventDetail"][nTSintetic]["taxNumber"]          	:= EncodeUTF8(Alltrim((cAlias)->CNPJ))
	//05 Código Participante
	oEstruct["eventDetail"][nTSintetic]["participantCode"]      := EncodeUTF8(Alltrim((cAlias)->CODPAR))
	//06 Indicativo NIF
	oEstruct["eventDetail"][nTSintetic]["nifIndicator"]         := EncodeUTF8(Alltrim(cIndNIF))
	//07 Numero NIF
	oEstruct["eventDetail"][nTSintetic]["nifNumber"]            := EncodeUTF8(Alltrim((cAlias)->NIF))
	//08 Forma Tributação
	oEstruct["eventDetail"][nTSintetic]["formOfTax"]            := EncodeUTF8(Alltrim(SubStr((cAlias)->FORMATRIBUTACAO,1,50)))
	//09 Nome Beneficiário
	oEstruct["eventDetail"][nTSintetic]["participantName"]      := EncodeUTF8(Alltrim((cAlias)->NOME))
	//10 Tipo
	oEstruct["eventDetail"][nTSintetic]["documentType"]         := EncodeUTF8(Alltrim((cAlias)->TIPO))
	//11 Série Documento
	oEstruct["eventDetail"][nTSintetic]["invoiceSeries"]        := EncodeUTF8(Alltrim((cAlias)->SERIE_PARC))
	//12 Número Documento
	oEstruct["eventDetail"][nTSintetic]["invoiceNumber"]        := EncodeUTF8(Alltrim((cAlias)->NUMERO))
	//13 Data Emissão/Pagamento
	oEstruct["eventDetail"][nTSintetic]["issueDate"]            := stod((cAlias)->DTEMISPGT)
	//14 ID do Documento
	oEstruct["eventDetail"][nTSintetic]["invoiceId"]            := EncodeUTF8(Alltrim((cAlias)->ID))
	//15 Item Documento
	oEstruct["eventDetail"][nTSintetic]["itemNumber"]			:= EncodeUTF8(Alltrim((cAlias)->NUMITE))
	//16 Natureza de Rendimento
	oEstruct["eventDetail"][nTSintetic]["yield"]                := EncodeUTF8(Alltrim((cAlias)->CODNAT))
	//17 Indicativo de FCI/SCP
	oEstruct["eventDetail"][nTSintetic]["scpIndicator"]         := EncodeUTF8(iif(Empty((cAlias)->INDFCISCP),'Não Informado',iif((cAlias)->INDFCISCP=='1','FCI','SCP')))
	//18 CNPJ da FCI/SCP
	oEstruct["eventDetail"][nTSintetic]["scpTaxNumber"]         := EncodeUTF8(Alltrim((cAlias)->CNPJFCISCP))
	//19 Informação de RRA ou Processo Judicial
	oEstruct["eventDetail"][nTSintetic]["rraInformation"]       := EncodeUTF8(iif(Empty((cAlias)->INDRRA) .Or. (cAlias)->INDRRA =='2','Não','Sim'))
	//20 Número de Inscrição do Processo RRA/Processo Judicial
	oEstruct["eventDetail"][nTSintetic]["rraNumber"]            := EncodeUTF8(Alltrim((cAlias)->NRRRAPJD))
	//21 CNPJ Origem Recurso
	oEstruct["eventDetail"][nTSintetic]["sourceTaxNumber"]      := EncodeUTF8(Alltrim((cAlias)->CNPJOR))
	//22 Total de Custas com Advogados
	oEstruct["eventDetail"][nTSintetic]["totalValueLawyer"]     := (cAlias)->CUSTADV
	//23 Total de Custas Judiciais
	oEstruct["eventDetail"][nTSintetic]["totalCourtCosts"]      := (cAlias)->CUSTJUD
	//24 Valor do Documento
	oEstruct["eventDetail"][nTSintetic]["grossValue"]           := (cAlias)->VALBRUTO
	//25 Base de Cálculo IR
	oEstruct["eventDetail"][nTSintetic]["taxBaseIr"]            := (cAlias)->BASEIR
	//26 Alíquota do IR
	oEstruct["eventDetail"][nTSintetic]["aliquotIr"]            := (cAlias)->ALIQIR
	//27 Valor do IR
	oEstruct["eventDetail"][nTSintetic]["taxIr"]                := (cAlias)->VALIR
	//28 Base de Cálculo PIS
	oEstruct["eventDetail"][nTSintetic]["taxBasePis"]           := (cAlias)->BASEPIS
	//29 Alíquota do PIS
	oEstruct["eventDetail"][nTSintetic]["aliquotPis"]           := (cAlias)->ALIQPIS
	//30 Valor do PIS
	oEstruct["eventDetail"][nTSintetic]["taxPis"]               := (cAlias)->VALPIS
	//31 Base de Cálculo COFINS
	oEstruct["eventDetail"][nTSintetic]["taxBaseCofins"]        := (cAlias)->BASECOFINS
	//32 Alíquota do COFINS
	oEstruct["eventDetail"][nTSintetic]["aliquotCofins"]        := (cAlias)->ALIQCOFINS
	//33 Valor do COFINS
	oEstruct["eventDetail"][nTSintetic]["taxCofins"]            := (cAlias)->VALCOFINS
	//34 Base de Cálculo CSLL
	oEstruct["eventDetail"][nTSintetic]["taxBaseCsll"]          := (cAlias)->BASECSLL
	//35 Alíquota do CSLL
	oEstruct["eventDetail"][nTSintetic]["aliquotCsll"]          := (cAlias)->ALIQCSLL
	//36 Valor do CSLL
	oEstruct["eventDetail"][nTSintetic]["taxCsll"]              := (cAlias)->VALCSLL
	//37 Base Agregado
	oEstruct["eventDetail"][nTSintetic]["agregBase"]            := (cAlias)->BSEAGREG
	//38 Valor Agregado
	oEstruct["eventDetail"][nTSintetic]["agregValue"]           := (cAlias)->VAGREG
	//39 Valor Base Suspensa IR
	oEstruct["eventDetail"][nTSintetic]["suspendedBaseIr"]      := (cAlias)->VBSIR
	//40 Valor Retido Suspenso IR
	oEstruct["eventDetail"][nTSintetic]["suspendedValueIr"]     := (cAlias)->VRSIR
	//41 Valor Base Suspensa PIS
	oEstruct["eventDetail"][nTSintetic]["suspendedBasePis"]     := (cAlias)->VBSPIS
	//42 Valor Retido Suspenso PIS
	oEstruct["eventDetail"][nTSintetic]["suspendedValuePis"]    := (cAlias)->VRSPIS
	//43 Valor Base Suspensa COFINS
	oEstruct["eventDetail"][nTSintetic]["suspendedBaseCofins"]  := (cAlias)->VBSCOFINS
	//44 Valor Retido Suspenso COFINS
	oEstruct["eventDetail"][nTSintetic]["suspendedValueCofins"] := (cAlias)->VRSCOFINS
	//45 Valor Base Suspensa CSLL
	oEstruct["eventDetail"][nTSintetic]["suspendedBaseCsll"]    := (cAlias)->VBSCSLL
	//46 Valor Retido Suspenso CSLL
	oEstruct["eventDetail"][nTSintetic]["suspendedValueCsll"]   := (cAlias)->VRSCSLL
	//47 Número do Processo Referenciado
	oEstruct["eventDetail"][nTSintetic]["processNumber"]        := EncodeUTF8(Alltrim((cAlias)->NPROCREF))

	(cAlias)->(dbSkip())
EndDo
(cAlias)->(DbCloseArea())

Return Nil

/*/{Protheus.doc} R40E80

	@type  Function
	@author Denis Souza
	@since 27/02/2023
	@version 1.0
	@param 
		aApurac - Array com os dados a serem retornados.
		oEstruct- Estrura a ser retornada para o fronted. - @Passada por referência.
/*/
Function R40E80(aApurac as array, oEstruct as object, aFilToReinf as array, cPeriod as character, cEvent as character)

Local cQuery   as character
Local cBanco   as character
Local cFilsV4K as character
Local cAlias   as character
Local cCompC1H as character
Local nX       as numeric
Local aFil     as array
Local aInfEUF  as array
Local aFiliais as array
Local nTm      as numeric

Default aApurac     := {}
Default oEstruct    := Nil
Default aFilToReinf := {}
Default cPeriod     := ''
Default cEvent      := ''

nX		 := 1
nTm 	 := 1
aFil	 := {}
aFiliais := {}
cQuery   := ""

cBanco   := Upper(AllTrim(tcGetDB()))
cCompC1H := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
aFil 	 := wsLoadFil()

For nX := 1 to len(aFil)
	aadd(aFiliais,{aFil[nX][1],aFil[nX][3]})
Next nX

aInfEUF  := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))

cFilsV4K := TafRetFilC( "V4K", aFiliais )

cPeriod := substr(cPeriod,3,4) + substr(cPeriod,1,2)

cQuery := WsRel40E80(cPeriod,cCompC1H,aInfEUF,cFilsV4K,cBanco,cEvent)

cQuery := ChangeQuery(cQuery)
cAlias := GetNextAlias()
TCQuery cQuery New Alias (cAlias)

(cAlias)->(dbGoTop())

While !(cAlias)->(eof())
	aadd(oEstruct["eventDetail"],JsonObject():New())
	nTm := len(oEstruct["eventDetail"])

	//Filial
	oEstruct["eventDetail"][nTm]["branchId"]      			:= Alltrim((cAlias)->FILIAL)

	if "4040" $ cEvent //R-4040 - Pagamentos/créditos a beneficiários não identificados
		//CNPJ da Filial
		oEstruct["eventDetail"][nTm]["taxNumberBranch"]		:= EncodeUTF8(Alltrim(FWSM0Util():GetSM0Data(,(cAlias)->FILIAL,{ 'M0_FILIAL'})[1][2]))

		//Nome da Filial
		oEstruct["eventDetail"][nTm]["branchName"]     		:= EncodeUTF8(FWSM0Util():GetSM0Data(,(cAlias)->FILIAL,{'M0_CGC'})[1][2])

	else //R-4080 - Retenção no recebimento

		//CNPJ da Filial
		oEstruct["eventDetail"][nTm]["fontNameTaxNumber"]	:= EncodeUTF8(Alltrim((cAlias)->CGCFON))

		//Nome da Filial
		oEstruct["eventDetail"][nTm]["fontName"]			:= EncodeUTF8(Alltrim((cAlias)->NOMEFON))
	endif

	//Código Participante
	oEstruct["eventDetail"][nTm]["participantCode"]     	:= EncodeUTF8(Alltrim((cAlias)->CODPAR))

	//ID Documento
	oEstruct["eventDetail"][nTm]["invoiceId"]            	:= EncodeUTF8(Alltrim((cAlias)->ID))

	//Número do documento
	oEstruct["eventDetail"][nTm]["invoiceNumber"]        	:= EncodeUTF8(Alltrim((cAlias)->CODDOC))

	//Data Fato Gerador
	oEstruct["eventDetail"][nTm]["taxableEventDate"]     	:= stod((cAlias)->DTPAG)

	//Natureza de Rendimento
	oEstruct["eventDetail"][nTm]["yield"]                	:= EncodeUTF8(Alltrim((cAlias)->CODNAT))
	
	//Valor Líquido
	oEstruct["eventDetail"][nTm]["liquidValue"]          	:= (cAlias)->VALLIQ

	//Base de Cálculo IR
	oEstruct["eventDetail"][nTm]["taxBaseIR"]            	:= (cAlias)->BASEIR

	//Valor Imposto IR
	oEstruct["eventDetail"][nTm]["taxIr"]                	:= (cAlias)->VALIR

	//Número do Processo Referenciado
	oEstruct["eventDetail"][nTm]["processNumber"]        	:= EncodeUTF8(Alltrim((cAlias)->NRPROC))

	//Base Suspensa IR
	oEstruct["eventDetail"][nTm]["suspendedBaseIr"]      	:= (cAlias)->BSUSIR

	//Valor Retenção Suspenso IR
	oEstruct["eventDetail"][nTm]["suspendedValueIr"]     	:= (cAlias)->VSUSIR

	//Valor depósito Judicial IR
	oEstruct["eventDetail"][nTm]["irCourtDepositAmount"] 	:= (cAlias)->VLRDEP

	//Observação
	oEstruct["eventDetail"][nTm]["obs"]          			:= EncodeUTF8(Alltrim((cAlias)->DESCRI))

	(cAlias)->(dbSkip())
EndDo
(cAlias)->(DbCloseArea())

Return Nil

/*/{Protheus.doc} RETCATEG
	(long_description)
	@type  Function
	@author José Mauro
	@since 31/08/2020
	@version version
	@param cType -> Categoria da competição.
	@return Valor da posição do array informado na variável cType
	@example
	(examples)
	@see (links_or_references)
	/*/
Function RETCATEG(cType)
	Local aType as array
	aType := {}

	AADD(aType, 'Internacional')
	AADD(aType, 'Interestadual')
	AADD(aType, 'Estadual')
	AADD(aType, 'Local')

Return aType[VAL(cType)]

/*/{Protheus.doc} RETTYPE
	(long_description)
	@type  Function
	@author José Mauro
	@since 31/08/2020
	@version version
	@param cType -> Tipo da competição.
	@return Valor da posição do array informado na variável cType
	@example
	(examples)
	@see (links_or_references)
	/*/
Function RETTYPE(cType)
	Local aType as array
	aType := {}

	AADD(aType, 'Oficial')
	AADD(aType, 'Não Oficial')

Return aType[VAL(cType)]
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Função TafGetEvt()
Executa a consulta dos registros na base que devem ser considerados para apuração

@author Leticia Campos da Silva
@since 24/09/2019
@version 1.0
@param cPerApu periodo para apuração
@param cEvent evento requisitante da estrutura
@return aAliasQry, array, alias e objeto retornados por Apur1020
/*/
//---------------------------------------------------------------------------------------------------------------

Static function TafGetEvt(cPerApu, cEvent, oPrepare)
	Local aRet  	as array
	Local aFil 		as array
	Local aFiliais	as array
	Local aAliasQry as array
	Local nX        as numeric
	Local aInfEUF 	:= TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))

	Default oPrepare := Nil 

	nX        := 0
	aRet 	  := {}
	aAliasQry := {}
	aFiliais  := {}

	aFil 	  := wsLoadFil()

	For nX := 1 to len(aFil)
		aadd(aFiliais, {aFil[nX][1],aFil[nX][3]})
	Next nX

	If cEvent $ "R-2010|R-2020"
		aAliasQry := Apur1020(substr(cPerApu,3,4)+substr(cPerApu,1,2), cEvent, aFiliais, aInfEUF, .T.)
	elseIf cEvent $ "R-2050"
		aAliasQry := QryRel2050(substr(cPerApu,3,4)+substr(cPerApu,1,2), aFiliais, @oPrepare )
	elseIf cEvent $ "R-2055"
		aAliasQry := QryRel2055(substr(cPerApu,3,4)+substr(cPerApu,1,2), aFiliais )
	EndIf
return aAliasQry

//-------------------------------------------------------------------
/*/ {Protheus.doc} TamEUF()
	Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial

	@author Leticia Campos da Silva
	@since 24/09/2019
	@version 1.0
/*/ 
//-------------------------------------------------------------------

Static Function TamEUF(cLayout)
	Local aTam 	As Array
	Local nX 	As Numeric

	Default cLayout := Upper(AllTrim(SM0->M0_LEIAUTE))

	aTam := {0,0,0}
	nX	 := 0

	For nX := 1 to Len(cLayout)
		if Upper(substring(cLayout,nX,1)) == "E"
			++aTam[1]
		elseif Upper(substring(cLayout,nX,1)) == "U"
			++aTam[2]
		elseif Upper(substring(cLayout,nX,1)) == "F"
			++aTam[3]
		endif
	Next nX

Return aTam

//-------------------------------------------------------------------
/*/ {Protheus.doc} IndObra()
	Função que verifica qual o indicativo de obra encontrado e retorna o texto correspondente.

	@author Leticia Campos da Silva
	@since 26/09/2019
	@version 1.0
/*/ 
//-------------------------------------------------------------------

Static function IndObra( cOption )
	Local 	aIndObra as array
	default cOption := "0"
	aIndObra := {}

	AADD(aIndObra, "0 - Não é obra de construção civil ou não está sujeita a matrícula de obra" )
	AADD(aIndObra, "1 - Obra de Construção Civil - Empreitada Total" )
	AADD(aIndObra, "2 - Obra de Construção Civil - Empreitada Parcial." )

return aIndObra[VAL(cOption)+1]

/*/{Protheus.doc} RETINFOC1H
	(long_description)
	@type  Static Function
	@author José Mauro
	@since 20/05/2020
	@version version
	@param 
		cCNPJ - CNPJ do participante.
	@return 
		aInfos- Array com informações do do CNPJ informado.
			[1] - Código do participante.
			[2] - Nome do participante.
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function RETINFOC1H(cId,cFilC1H,cCompC1H,aInfEUF)
	Local aInfos as array

	Default cFilC1H := ""
	Default aInfEUF := {}

	aInfos := {}

	C1H->(GETAREA())
	C1H->(DBSETORDER(5)) //C1H_FILIAL+C1H_ID

	If cCompC1H == "EEE"
		if C1H->(DBSEEK( cFilC1H + cId ))
			AADD(aInfos,{C1H->C1H_CODPAR,C1H->C1H_NOME})
		Endif
	ElseIf cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		if C1H->(DBSEEK(PadR( Substr(cFilC1H,1,aInfEUF[1] + aInfEUF[2]),len(cFilC1H)," ") + cId ))
			AADD(aInfos,{C1H->C1H_CODPAR,C1H->C1H_NOME})
		Endif
	Else
		if C1H->(DBSEEK( xFilial( "C1H" ) + cId ))
			AADD(aInfos,{C1H->C1H_CODPAR,C1H->C1H_NOME})
		EndIf
	EndIf

	C1H->(DBCLOSEAREA())

Return aInfos


Static Function RETCGC(cFil)
	Local cCGC  as character
	Local aSM0  as array

	cCGC := ""
	aSM0 := {}

	aSM0 := FWSM0Util():GetSM0Data( cEmpAnt ,cFil, { "M0_CGC" } )
	cCGC := aSM0[1][2]

Return cCGC

Static Function RetInfo2050(cVar)
	local cRet  as character

	if AllTrim(cVar) == "1"
		cRet :=  "Comercialização da Produção por Prod. Rural PJ/Agroindústria, exceto para entidades executoras do PAA;"
	elseIf AllTrim(cVar) == "7"
		cRet :=  "Comercialização da Produção com Isenção de Contribuição Previdenciária, de acordo com a Lei n° 13.606/2018;"
	elseIf AllTrim(cVar) == "8"
		cRet :=  " Comercialização da Produção para Entidade do Programa de Aquisição de Alimentos - PAA;"
	elseIf AllTrim(cVar) == "9"
		cRet :=  "Comercialização direta da Produção no Mercado Externo"
	endIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetIndAq2055

Função responsável por retornar o indicativo de aquisição para o evento 2055

@author Renan Gomes
@since 09/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RetIndAq2055(cVar,cAlias,cGpEpFil,aCmpsC1E,lColPAA,lColNCPF,nTamFil)

	local cPAA 		as character
	local cRet 		as character
	local cIndAquis as character
	local nPos 		as numeric

	Default cVar	 := ''
	Default cAlias   := ''
	Default cGpEpFil := ''
	Default aCmpsC1E := {}
	Default lColPAA	 := .F.
	Default lColNCPF := .F.
	Default nTamFil  := 0

	//Cache para Tp e Nr Insc, senao executaria seek na C1E ou posicione na SM0 a cada registro
	nPos := aScan( aCmpsC1E, {|x| Upper(AllTrim(x[3])) == cGpEpFil } )
	if nPos <= 0
		XGetTPInsc( (cAlias)->FIL, cGpEpFil, @aCmpsC1E, lColNCPF, nTamFil ) //adiciona aqui o grp emp fil, tp insc e nr insc
		nPos := len( aCmpsC1E )
		aCmpsC1E[nPos][PAA] := RetPAA( aCmpsC1E[nPos][NINSC], aCmpsC1E[nPos][TINSC], lColNCPF, nTamFil ) //Para o primeiro registro se obtem o PAA
	endif
	cPAA := aCmpsC1E[nPos][PAA]

	cIndAquis := ""
	If Empty((cAlias)->CPFPR) .AND. !Empty((cAlias)->CNPJPR) //Pessoa jurídica
		If lColPAA
			If cPAA == "1" .AND. (cAlias)->INDISE <> "1"
				cIndAquis := "3"
			Else
				If cPAA == "1" .AND. (cAlias)->INDISE == "1"  
					cIndAquis := "6"
				EndIf
			EndIf
		Else
			If cPAA == "1" .AND. (cAlias)->INDISE == "1" 
				cIndAquis := "6"	
			EndIf
		EndIf
		If cPAA <> "1"
			cIndAquis := "3"
		EndIf
	Else //Produtor pessoa física
		If cPAA == "1" .AND. (cAlias)->INDISE <> "1"
			cIndAquis := "2"
		ElseIf cPAA != "1" .AND. (cAlias)->INDISE <> "1"
			cIndAquis := "1"
		ElseIf cPAA <> "1" .AND. (cAlias)->INDISE == "1" 
			cIndAquis := "4"
		ElseIf cPAA == "1" .AND. (cAlias)->INDISE == "1"
			cIndAquis := "5"		 				
		EndIf
		If (cAlias)->CFOP == "1501" .or. (cAlias)->CFOP == "2501"
			cIndAquis := "7"
		EndIf
	EndIf

	if cIndAquis == "1"
		cRet :=  "Aquisição de produção de produtor rural pessoa física ou segurado especial em geral"
	elseIf cIndAquis == "2"
		cRet :=  "Aquisição de produção de produtor rural pessoa física ou segurado especial em geral por entidade do PAA"
	elseIf cIndAquis == "3"
		cRet :=  "Aquisição de produção de produtor rural pessoa jurídica por entidade do PAA"
	elseif cIndAquis == "4"
		cRet := "Aquisição de produção de produtor rural pessoa física ou segurado especial em geral - Produção isenta (Lei 13.606/2018)"
	elseIf cIndAquis == "5"
		cRet :=  "Aquisição de produção de produtor rural pessoa física ou segurado"
	elseIf cIndAquis == "6"
		cRet :=  " Aquisição de produção de produtor rural pessoa jurídica por entidade do PAA - Produção isenta (Lei 13.606/2018)"
	elseIf cIndAquis == "7"
		cRet :=  "Aquisição de produção de produtor rural pessoa física ou segurado especial para fins de exportação"
	Else
		cRet := ""
	endIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XGetTPInsc

Função responsável por retornar o TIPO da inscrição para a filial logada no sistema CNPJ/CAEPF.

@author Renan Gomes
@since 09/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XGetTPInsc( cFil, cGpEpFil, aCmpsC1E, lColNCPF, nTamFil )

Local cRetTPInsc as Character
Local aArea		 as Array
Local cRetInsc	 as Character
Local cPAA		 as Character

Default cFil	 := ''
Default cGpEpFil := ''
Default aCmpsC1E := {}
Default lColNCPF := .F.
Default nTamFil  := 0

cRetTPInsc	:= ""
aArea		:= GetArea()
cRetInsc	:= ""
cPAA		:= ""

dbSelectArea("C1E")
C1E->(dbSetOrder(3))
If C1E->(MSSeek(XFilial("C1E")+PadR(cFil, nTamFil)+"1")) //-- Posiciona na C1E de acordo com a filial do registro
	If lColNCPF .AND. !Empty(C1E->C1E_NRCPF)
		cRetTPInsc := "3"
		cRetInsc := C1E->C1E_NRCPF
	Else
		cRetTPInsc := "1"
		cRetInsc := Posicione("SM0", 1, cEmpAnt + cFil, "M0_CGC")
	EndIf
EndIf

RestArea(aArea)

//Adiciona aqui o tp e nr de inscricao, o controle de apenas uma insercao por GpEp x Fil fica na funcao chamadora (RetIndAq2055)
aadd(aCmpsC1E,{cRetTPInsc,cRetInsc,cGpEpFil,cPAA})

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPAA

Função responsável por retornar o conteudo do campo PAA 
da tabela C1E de acordo com a raiz do CNPJ.

cInsc: CNPJ do estabelcimento

@author Renan Gomes
@since 09/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetPAA(cInsc, cTpInsc, lColNCPF, nTamFil )

Local cPAA 	  	:= ""
Local aAreaSM0	:= {}
Local aAreaC1E	:= {}
Local lAchou	:= .F.

Default cInsc	 := ""
Default cTpInsc	 := ""
Default lColNCPF := .F.
Default nTamFil	 := 0

If cTpInsc == '1' //-- CNPJ
	aAreaSM0 := SM0->(GetArea())
	aAreaC1E := C1E->(GetArea())
	dbSelectArea("SM0")
	SM0->(dbGoTop())
	While !SM0->(Eof()) .And. !lAchou //-- Posiciona na SM0 com a raiz do CNPJ do estabelecimento
		If !Empty(cInsc)
			If AllTrim(SM0->M0_CGC) == AllTrim(cInsc)
				lAchou := .T.
				cPAA := Posicione("C1E", 3, XFilial("C1E")+PadR(SM0->M0_CODFIL, nTamFil)+"1", "C1E_PAA" )
			EndIf
		EndIf
		SM0->(DbSkip())
	EndDo
	RestArea(aAreaSM0)
	RestArea(aAreaC1E)

ElseIf cTpInsc == '3' //-- CAEPF
	aAreaC1E := C1E->(GetArea())
	dbSelectArea("C1E")
	C1E->(dbGoTop())
	While !C1E->(Eof()) .And. !lAchou
		If !Empty(cInsc)
			If SubStr(AllTrim(C1E->C1E_NRCPF), 1, 9) == SubStr(AllTrim(cInsc),1,9)
				lAchou := .T.
				cPAA := C1E->C1E_PAA
			EndIf
		EndIf
		C1E->(DbSkip())
	EndDo
	RestArea(aAreaC1E)
EndIf

Return cPAA

//-------------------------------------------------------------------
/*/{Protheus.doc} SetalApurBx()
Seta a variavel __lApurBx conforme o parâmetro

@author Karen Honda
@since 20/05/2021
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function SetalApurBx()
If __lApurBx == nil
	__lApurBx	:= SuperGetMv('MV_TAFRECD',.F.,"1") == "2" .and. TAFColumnPos("T5P_PROCID")// "1"- Emissão ; "2" - Baixa    
EndIf
Return
