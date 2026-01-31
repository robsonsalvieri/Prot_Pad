
#Include 'Protheus.ch'
#define ARQUIVO_LOG	"Pls_Grr_critica.log"
#define INT_COMPANY 1
#define INT_BRANCH 2
#define GRR_LOAD_METADATA       2   // Leitura do metadata vindo da plataforma
#define VARIABLE oJBody AS CLASS JSONArray NO-UNDO.

#define OPERATION_PATCH_INTEGRATION "1"
#define OPERATION_PATCH_BILL "2"

#define STATUS_ACTIVE "1"
#define STATUS_FAILED "2"
#define STATUS_CANCELED "3"

//------------------------------------------------------------------- 
/*/{Protheus.doc} IntegPlsGrr
Responsavel pela chamada do job diário para que o PLS veririque se há faturas a serem geradas na plataforma GRR, com base no BM1
Obs.: Somente irá geras as faturas no GRR caso o lote de fatura do mes ja esteja gerado

@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 


Function IntegPlsGrr(aEmpresa)


	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Inicio do Job IntegPlsGrr" , 0, 0, {})

	PutGlbVars("EMP_SM0", aEmpresa)


	lret := startjob("PlsGrrIniRPC",getenvserver(),.T.,"Data Atual " + cvaltochar(date()))


	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Fim do Job IntegPlsGrr" , 0, 0, {})

Return .T.

//------------------------------------------------------------------- 
/*/{Protheus.doc} PlsGrrIniRPC
Responsavel pela chamada do job diário para que o PLS veririque se há faturas a serem geradas na plataforma do GRR, com base no BM1
Obs.: Somente irá fgeras as faturas no GRR caso o lote de fatura do mes ja esteja gerado

@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 
Function PlsGrrIniRPC()
	local aSM0Grp := {}

	GetGlbVars("EMP_SM0",aSM0Grp)
	RpcSetType(3)
	RpcSetEnv( aSM0Grp[1],aSM0Grp[2],,,"PLS","PLSXGRR_JOB",,,,.T. )

	If LockByName("INTEGPLSGRR", .T., .T.,.T.)
		cCodInt	:= PLSIntPad()

		//---------------------------------------------------------------------------------
		// Configuração de regua de cobrança responsável por determinar o prazo de tempo de dias
		// da geração ao envio da fatatura para a plataforma GRR(BillingRuler)
		//---------------------------------------------------------------------------------
		BA0->(dbsetorder(1))
		if BA0->(DbSeek(xFilial("BA0")+cCodInt))

			if BA0->BA0_GRRREG <> "1" //Atualizando a flag o sistema entende que a regua ja foi atualizada
				IntegGrrBillin()
				Sleep(5000)

				RecLock( 'BA0', .F. )
				BA0->BA0_GRRREG = "1"
				msunlock()

			endif
		endIf

		if getNewPar("MV_PLUPBFQ",.t.)
			//---------------------------------------------------------------------------------
			// Atualização dos itens dos produtos
			//---------------------------------------------------------------------------------
			IntegGrr01()
			Sleep(5000)
		endif

		//---------------------------------------------------------------------------------
		// Inclusão de subscrição/Criação da fatura/Medição
		//---------------------------------------------------------------------------------
		IntegGrr02()

	endif

	RpcClearEnv()

	fwFreeArray(aSM0Grp)
Return



//------------------------------------------------------------------- 
/*/{Protheus.doc} IntegGrr01
Inclusão de items(Produtos), efetuado no momento da implantação do GRR no cliente

o	(1º) Inclusão de items(Produtos) 
        Efetuado no momento da implantação do GRR no cliente
o	(2º) Criação de Subscription(Subscrição)  
        É efetuado atraves da função IntegGrr02 que é executado no momento da geração do lote de cobrança é se alguns dos campos BT5_INTGRR,BQC_INTGRR,BA3_INTGRR estiverem ativo como SIM
o	(3º) Listagem de Bills(Fatura) “Aguardando medição” a serem liberadas para cobrança;
        É efetuado atraves da função IntegGrr03 que é executado via Job, o seu retono será as faturas com vencimento do dia ou as que ja venceu, essa listagem é importante para os itens 4,5 e 6.
o	(4º) Atualização dos campos Reference e IntegrationId;
        É efetuado atraves da função IntegGrr03 que é executado via Job, e é nesse que gravamos o eference e IntegrationId no GRR, é uam preparação para medição; 
o	(5º) Atualização de Bills(Fatura);
o	(6º) Atualização do Status “Medição Completa” da Bill(Fatura) para liberação para cobrança.
o	(7º) Associar a Fatura ao Título Financeiro.
o	(8º) Provisão de Receita e Conciliação.

@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 

Function IntegGrr01(lAutoma,cResult,cMsg)

	local cEndpoint := ''
	local cPath := '/items'         // Endereço para envio de produtos em lote
	local cTmpAlias := GetNextAlias()
	local jItem := NIL
	local lRet := .F.
	local lAddItems := .F.

	default lAutoma :=.F.
	default cResult:=''
	default cMsg := ''

	cEndPoint := GRRURL()

	cQuery := "SELECT  BFQ_FILIAL, BFQ_CODINT, BFQ_PROPRI, BFQ_CODLAN, BFQ_DESCRI " + ;
		" FROM " + RetSqlName( "BFQ" ) + " BFQ " + ;
		" WHERE BFQ_FILIAL = '" + xFilial( "BFQ", cFilAnt ) + "' " + ;
		" AND BFQ_DEBCRE = '1' " + ;    // somente leva pra plataforma "produtos" de debito
	" AND BFQ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmpAlias,.F.,.T.)

	While ( cTmpAlias )->( !EOF() )
		jItem := SetItemJson( cTmpAlias )

		cResult := if(!lAutoma,GRRSyncData( NIL, jItem, cEndPoint, cPath, , , @cMsg),nil)

		lAddItems := .T.

		( cTmpAlias )->( DBSkip() )
	Enddo

	//--------------------------------------------------------------
	// Chama o sincronismo para cada paginação se estiver rodando em lote
	//--------------------------------------------------------------
	if lAddItems
		lRet := .T.

		PutMv("MV_PLUPBFQ",.F.)
	endIf

	(cTmpAlias)->(dbCloseArea())

	freeObj(jItem)

Return lRet

//------------------------------------------------------------------- 
/*/{Protheus.doc} SetItemJson
Responsavel pela criação do Json de itens para o produto de integração com GRR

@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 

Static Function SetItemJson( cTmpAlias )
	Local jItem := NIL

	jItem := JsonObject():New()

	jItem[ "organizationIntegrationId" ] :=  cEmpAnt + '|' + cFilAnt
	jItem[ "name" ] :=  Alltrim( ( cTmpAlias )->BFQ_DESCRI )
	jItem[ "reference" ] :=  ( cTmpAlias )->BFQ_CODINT + ( cTmpAlias )->BFQ_PROPRI + ( cTmpAlias )->BFQ_CODLAN
	jItem[ "description" ] :=  Alltrim( ( cTmpAlias )->BFQ_DESCRI )
	jItem[ "typeCalculation" ] :=  '1'                              // 2=PriceByQuantity
	jItem[ "unitMeasurement" ] := 'Mb'
	jItem[ "currencyCode" ] :=  GRRISOCurrency( )
	jItem[ "value" ] := 0
	jItem[ "isActive" ] := "true"
	jItem[ "integrationId" ] := cEmpAnt + '|'+ cFilant + '|' + ( cTmpAlias )->BFQ_CODINT + '|' + ( cTmpAlias )->BFQ_PROPRI + ( cTmpAlias )->BFQ_CODLAN
	jItem[ "source" ] := "PLS"

Return jItem


//------------------------------------------------------------------- 
/*/{Protheus.doc} IntegGrr02
Determina a integração com a plataforma Gestão de Receita Recorrente(GRR)
A função IntegGrr02 é responsãvel pela inclusão da subscrição no GRR, esse
é o primeiro passo dos que precisa gerar fatura na plataforma.

o	(1º) Inclusão de items(Produtos) 
        Efetuado no momento da implantação do GRR no cliente
o	(2º) Criação de Subscription(Subscrição)  
        É efetuado atraves da função IntegGrr02 que é executado no momento da geração do lote de cobrança é se alguns dos campos BT5_INTGRR,BQC_INTGRR,BA3_INTGRR estiverem ativo como SIM
o	(3º) Listagem de Bills(Fatura) “Aguardando medição” a serem liberadas para cobrança;
        É efetuado atraves da função IntegGrr03 que é executado via Job, o seu retono será as faturas com vencimento do dia ou as que ja venceu, essa listagem é importante para os itens 4,5 e 6.
o	(4º) Atualização dos campos Reference e IntegrationId;
        É efetuado atraves da função IntegGrr03 que é executado via Job, e é nesse que gravamos o eference e IntegrationId no GRR, é uam preparação para medição; 
o	(5º) Atualização de Bills(Fatura);
o	(6º) Atualização do Status “Medição Completa” da Bill(Fatura) para liberação para cobrança.
o	(7º) Associar a Fatura ao Título Financeiro.
o	(8º) Provisão de Receita e Conciliação.

@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 

Function IntegGrr02()

	local cTmpItems := getNextAlias() as character
	local oSubscription as object
	local oFamilyIdData as object
	local oCustomer as object
	local cIntegrationId as character
	local lAddSubscription := .F. as logical
	local oBill as object
	local cStatus as character
	local cErrorMessage as character

	BeginSql Alias cTmpItems
		SELECT 
			BM1.BM1_FILIAL,
			BM1.BM1_CODINT,
			BM1.BM1_CODEMP,
			BM1.BM1_CONEMP,
			BM1.BM1_VERCON,
			BM1.BM1_SUBCON,
			BM1.BM1_VERSUB,
			BM1.BM1_MATRIC,
			BM1.BM1_PREFIX,
			BM1.BM1_NUMTIT,
			BM1.BM1_PARCEL,
			BM1.BM1_TIPTIT,
			BM1.BM1_MES,
			BM1.BM1_ANO,
			BA3.BA3_INTGRR,
			BQC.BQC_INTGRR,
			BT5.BT5_INTGRR
		FROM %Table:BBT% BBT

		INNER JOIN %table:BM1% BM1 ON 
			BM1.BM1_FILIAL = %xfilial:BM1% AND
			BM1.BM1_PREFIX = BBT.BBT_PREFIX AND
			BM1.BM1_NUMTIT = BBT.BBT_NUMTIT AND
			BM1.BM1_PARCEL = BBT.BBT_PARCEL AND
			BM1.BM1_TIPTIT = BBT.BBT_TIPTIT AND
			BM1.%notDel%

		INNER JOIN %table:BA3% BA3 ON 
			BA3.BA3_FILIAL = %xfilial:BA3% AND
			BA3.BA3_CODINT = BBT.BBT_CODOPE AND
			BA3.BA3_CODEMP = BBT.BBT_CODEMP AND
			BA3.BA3_MATRIC = BBT.BBT_MATRIC AND
			BA3.%notDel%

		LEFT JOIN %table:BQC% BQC ON 
			BQC.BQC_FILIAL = %xfilial:BQC% AND 
			BQC.BQC_CODIGO = BM1.BM1_CODINT + BM1.BM1_CODEMP AND 
			BQC.BQC_NUMCON = BM1.BM1_CONEMP AND 
			BQC.BQC_VERCON = BM1.BM1_VERCON AND 
			BQC.BQC_SUBCON = BM1.BM1_SUBCON AND 
			BQC.BQC_VERSUB = BM1.BM1_VERSUB AND 
			BQC.%notDel%

		LEFT JOIN %table:BT5% BT5 ON 
			BT5.BT5_FILIAL = %xfilial:BT5% AND 
			BT5.BT5_CODINT = BM1.BM1_CODINT AND 
			BT5.BT5_CODIGO = BM1.BM1_CODEMP AND 
			BT5.BT5_NUMCON = BM1.BM1_CONEMP AND 
			BT5.BT5_VERSAO = BM1.BM1_VERCON AND 
			BT5.%notDel%

		WHERE BBT.BBT_FILIAL = %xfilial:BBT%
			AND BBT.BBT_CODOPE = %exp:PlsIntPad()%
			AND BBT.BBT_MESTIT = %exp:StrZero(month(dDatabase),2)%
			AND BBT.BBT_ANOTIT = %exp:StrZero(year(dDatabase),4)%
			AND BBT.BBT_INTGRR <> %exp:'1'%
			AND BBT.BBT_TIPTIT <> %exp:'NCC'%
			AND (
				(BA3.BA3_INTGRR = %exp:'1'%) OR
				(BA3.BA3_INTGRR = %exp:' '% AND BQC.BQC_INTGRR = %exp:'1'%) OR 
				(BA3.BA3_INTGRR = %exp:' '% AND BQC.BQC_INTGRR = %exp:' '% AND BT5.BT5_INTGRR = %exp:'1'%)
			)
			AND BBT.%notDel%

		GROUP BY 
				BM1.BM1_FILIAL,
				BM1.BM1_CODINT,
				BM1.BM1_CODEMP,
				BM1.BM1_CONEMP,
				BM1.BM1_VERCON,
				BM1.BM1_SUBCON,
				BM1.BM1_VERSUB,
				BM1.BM1_MATRIC,
				BM1.BM1_PREFIX,
				BM1.BM1_NUMTIT,
				BM1.BM1_PARCEL,
				BM1.BM1_TIPTIT,
				BM1.BM1_MES,
				BM1.BM1_ANO,
				BA3.BA3_INTGRR,
				BQC.BQC_INTGRR,
				BT5.BT5_INTGRR
	EndSql

	if (cTmpItems )->(!eof())
		SE1->(dbSetOrder(1))
		BBT->(dbSetOrder(7))
		BA3->(dbSetOrder(1))

		oSubscription := totvs.protheus.health.plan.integration.grr.Subscriptions():new()

		oCustomer := JsonObject():new()
		oFamilyIdData := JsonObject():new()

		while (cTmpItems )->(!eof())
			lAddSubscription := .F.
		
			if SE1->(msSeek(xFilial("SE1") + (cTmpItems)->(BM1_PREFIX + BM1_NUMTIT + BM1_PARCEL)))
				cIntegrationId := (cTmpItems)->BM1_CODINT + '|' + (cTmpItems)->BM1_CODEMP + '|' + (cTmpItems)->BM1_MATRIC + '|' + SE1->E1_CLIENTE + '|' + SE1->E1_LOJA

				if BA3->(msSeek(xFilial("BA3") + (cTmpItems)->BM1_CODINT + (cTmpItems)->BM1_CODEMP + (cTmpItems)->BM1_MATRIC))
					if oSubscription:getSubscriptionId(cIntegrationId)
						lAddSubscription := .T.
					else
						cErrorMessage := ""

						oCustomer["code"] := alltrim(SE1->E1_CLIENTE)
						oCustomer["branch"] := alltrim(SE1->E1_LOJA)

						oFamilyIdData["healthInsurerCode"] := (cTmpItems)->BM1_CODINT
						oFamilyIdData["companyCode"] := (cTmpItems)->BM1_CODEMP
						oFamilyIdData["registration"] := (cTmpItems)->BM1_MATRIC

						if oSubscription:addSubscription(oFamilyIdData, oCustomer)
							lAddSubscription := .T.
							cStatus := STATUS_ACTIVE
						else
							cStatus := STATUS_FAILED
							cErrorMessage := oSubscription:getResponse()
						endif

						oSubscription:commitSubscriptionStatus(cStatus, cErrorMessage)
					endif

					if lAddSubscription
						if oSubscription:commitInvoice(alltrim(cEmpAnt + "|" + SE1->E1_FILIAL + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO))
							if BBT->(msSeek(xFilial("BBT") + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + SE1->E1_TIPO)))
								BBT->(recLock("BBT", .F.))
								BBT->BBT_INTGRR = "1"
								BBT->(msunlock())
							endIf
						endif
					else
						plsLogFil("Subscrição: " + cIntegrationId, ARQUIVO_LOG)
						plsLogFil("Critica: " + oSubscription:getResponse(), ARQUIVO_LOG)
						plsLogFil(" ", ARQUIVO_LOG)
					endif
				endif
			endIf

			(cTmpItems)->(dbskip())
		enddo

		oSubscription:destroy()
	endif

	Sleep(5000)

	oBill := totvs.protheus.health.plan.integration.grr.Bills():new()
	oBill:getBills(OPERATION_PATCH_INTEGRATION)

	Sleep(5000)
	//---------------------------------------------------------------------------------
	// Apos a finalização dos passos 3 e 4 iremos chamar os passo 5 e 6 para ecerrar
	//---------------------------------------------------------------------------------
	IntegGrr05()

	freeObj(oSubscription)
	freeObj(oFamilyIdData)
	freeObj(oCustomer)
	freeObj(oBill)

Return

//------------------------------------------------------------------- 
/*/{Protheus.doc} IntegGrr05
Determina a integração com a plataforma Gestão de Receita Recorrente(GRR)
A função IntegGrr05 é responsãvel pela medição, isso é, prepara a fataura para envion dentro da plataforma e com isso executaremos os passos 5 e 6

o	(1º) Inclusão de items(Produtos) 
        Efetuado no momento da implantação do GRR no cliente
o	(2º) Criação de Subscription(Subscrição)  
        É efetuado atraves da função IntegGrr02 que é executado no momento da geração do lote de cobrança é se alguns dos campos BT5_INTGRR,BQC_INTGRR,BA3_INTGRR estiverem ativo como SIM
o	(3º) Listagem de Bills(Fatura) “Aguardando medição” a serem liberadas para cobrança;
        É efetuado atraves da função IntegGrr03 que é executado via Job, o seu retono será as faturas com vencimento do dia ou as que ja venceu, essa listagem é importante para os itens 4,5 e 6.
o	(4º) Atualização dos campos Reference e IntegrationId;
        É efetuado atraves da função IntegGrr03 que é executado via Job, e é nesse que gravamos o eference e IntegrationId no GRR, é uam preparação para medição; 
o	(5º) Atualização de Bills(Fatura);
o	(6º) Atualização do Status “Medição Completa” da Bill(Fatura) para liberação para cobrança.
o	(7º) Associar a Fatura ao Título Financeiro.
o	(8º) Provisão de Receita e Conciliação.



@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 
Function IntegGrr05()
	Local cEndpoint := GRRURL()
	Local cPath := '/bills?status=2'
	Local cPage := ''
	Local cResult := ''
	Local cAux := ""
	Local cBKPFil := ""
	Local lHasNext := .T.
	Local lApprovedQuant := .F.
	Local nI := 0
	Local nPage := 0
	Local oRest
	Local oResult
	Local oJson
	Local aSvAlias := {}

	aSvAlias := BM1->( GetArea() )

	cBKPFil := cFilAnt

	While lHasNext
		oRest := NIL

		nPage++
		cPage := "&page=" + Alltrim( Str( nPage ) )

		//Listando os itens que ja tem fatura gerada para efetuar a medição
		cResult := GRRRestExec( 'GET', cEndpoint, cPath + cPage, @oRest )

		If !Empty( cResult )
			oResult := JSONObject():New()
			oResult:FromJSON( cResult )

			lHasNext := oResult[ 'hasNext' ]
			aResult := oResult[ 'responseData' ]

			If !Empty( aResult )
				If FWJsonDeserialize( cResult, @oJson)
					If AttIsMemberOf( oJson, "responseData" )
						For nI := 1 to len( oJson:responseData )
							cAux := oJson:responseData[ nI ]:organizationIntegrationId

							If cAux <> nil .and. oJson:responseData[ nI ]:INTEGRATIONID <> nil
								aIntegration := StrTokArr2( cAux, '|' )

								If aIntegration[ INT_COMPANY ] == cEmpAnt
									//---------------------------------------------------------
									// Atribui a variável do sistema a filial do registro que
									// está sendo processada.
									//---------------------------------------------------------
									cFilAnt := aIntegration[ INT_BRANCH ]
									SetDataOld( oJson:responseData[ nI ], lApprovedQuant )
								EndIf
							EndIf
						Next
					EndIf
				EndIf
			EndIF
		EndIf
	End

	//---------------------------------------------------------
	// Volta a informação da filial logada
	//---------------------------------------------------------
	cFilAnt := cBKPFil

	If !Empty( aSvAlias )
		RestArea( aSvAlias )
	EndIf

	FWFreeArray( aSvAlias )
	FreeObj( oRest )
	FreeObj( oResult )
	FreeObj( oJson )

Return



//------------------------------------------------------------------- 
/*/{Protheus.doc} SetDataOld
Responsavel pela criação do Json para a medição do passo 5

@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 

Static Function SetDataOld( oData, lApprovedQuant )

	local cEndpoint := GRRURL()
	local cPath := '/bills/
	local oRest
	local oRetItens
	local cResult := ''
	local cIdmain := ''

	oRetItens := atualizaItens(@oData,@cIdmain)
	oResult := JSONObject():New()
	oResult:set(oRetItens )

	oJSON:= JSONObject():new()
	oJSON:FromJSON(oResult:toJson())


	cPath:=  '/bills/'+oData:integrationID

	//Enviando a Medição para a plataforma e encerrando o ciclo do PLS
	cResult := GRRRestExec( 'PATCH', cEndpoint, cPath, @oRest, oJSON )

	If !Empty( cResult )
		//Atualizo na plataforma o Status da medição para medição completa
		cResult := GRRRestExec( 'PUT', cEndpoint, '/bills/'+ oData:integrationID+'/measurement-completed', @oRest, {{"integrationId", oData:integrationID}} )
	endif

	freeObj(oRest)
	freeObj(oRetItens)

Return


//------------------------------------------------------------------- 
/*/{Protheus.doc} SetDataOld
Responsavel pela criação do Json do cabeçalho que contem os valores para apontamento

@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 

Static Function atualizaItens( oData ,cIdmain)

	jItems := GetFieldJson(oData,@cIdmain)


return(jItems)


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetItemsPayLoad
Função que prepara as informações necessárias para a montagem dos itens da Payload

@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//-------------------------------------------------------------------------------------

Static Function GetItemsPayLoad( oData, nVlrTotalBm1,cIdmain )
	local jItems
	local cTmpItems := GetNextAlias()
	local i:=1
	local x:=1
	local aItems :={}
	local aProds := {}
	local lItemNovo :=.F.

	aReference := StrTokArr2( oData:integrationId, '|' )

	if len(aReference) == 6
		BeginSql Alias cTmpItems
				SELECT   BM1_FILIAL, BM1_CODINT, BM1_CODEMP, BM1_MATRIC,BM1_CONEMP,BM1_VERCON, BM1_TIPREG, BM1_DIGITO , BM1_SEQ , BM1_NUMTIT ,BM1_PREFIX,BM1_CODTIP,BM1_DESTIP,BM1_VALOR,BM1_ANO,BM1_MES,BM1_CODTIP, R_E_C_N_O_
				FROM %Table:BM1% BM1
				WHERE BM1_FILIAL = %xfilial:BM1%
					AND BM1_PREFIX = %Exp:padr(aReference[3], tamSX3("BM1_PREFIX")[1])%
					AND BM1_NUMTIT = %Exp:padr(aReference[4], tamSX3("BM1_NUMTIT")[1])%
					AND BM1_PARCEL = %Exp:padr(aReference[5], tamSX3("BM1_PARCEL")[1])%
					AND BM1_TIPTIT = %Exp:padr(aReference[6], tamSX3("BM1_TIPTIT")[1])%
					AND BM1.%notDel%
		EndSql

		While ( cTmpItems )->( !Eof() )

			nVlrTotalBm1+=  ( cTmpItems )->BM1_VALOR

			nPos:=ascan( aProds, {|x| x[1] == ( cTmpItems )->(BM1_FILIAL+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES+BM1_CODTIP) } )

			if nPos ==0
				//				1																	2																					3																	4					5
				aAdd(aProds,{( cTmpItems )->(BM1_FILIAL+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES+BM1_CODTIP), cEmpAnt + '|' + cFilAnt+'|'+( cTmpItems )->BM1_CODINT+'|'+( cTmpItems )->BM1_CODTIP, if(BFQ->(Posicione("BFQ",1,xFilial("BFQ")+( cTmpItems )->BM1_CODINT+( cTmpItems )->BM1_CODTIP,"BFQ_TIPFAT"))=='2',0,1),( cTmpItems )->BM1_VALOR,( cTmpItems )->BM1_DESTIP})
			else
				aProds[npos,4]+= ( cTmpItems )->BM1_VALOR
			endif

			( cTmpItems )->( Dbskip() )
		enddo

		for i:=1 to len(aProds)

			lItemNovo :=.t.
			jItems := JsonObject():New()

			for x:=1 to len(oData:items)
				if oData:items[x]:integrationid == aProds[i,2]
					//Apos a Criação da subscrição no decorrer do tempo do plano pode haver cobrança de alguns itens novos
					//tais como carteirnha ou um debito ou algum acessório no plano.
					lItemNovo :=.F.
				endif

			next x

			if len(oData:items)>=i .and. !lItemNovo

				for x:=1 to len(oData:items)

					// No momento da inclusão da subscrição eu ja tenhos alguna tipos de pagamentos tais como 101/103
					//eu preciso incluir dentro desses itens os valores do mes, quando não tiver a plataforma irá entender um novo item na fatura
					if oData:items[x]:integrationid == aProds[i,2]

						jItems[ "id" ] :=  oData:items[x]:id
						jItems[ "integrationId" ] := aProds[i,2]
						jItems[ "description" ] := aProds[i,5]
						jItems[ "unitMeasurement" ] := 'UN'
						jItems[ "billItemReference" ] := oData:reference
						jItems[ "quantity" ] := 1
						jItems[ "baseValue" ] := aProds[i,4]
						jItems[ "value" ] := aProds[i,4]
						jItems[ "totalAmount" ] := aProds[i,4]
						jItems[ "metadata" ] := nil

					endif

				next x

			else

				jItems[ "integrationId" ] := aProds[i,2]
				jItems[ "description" ] := aProds[i,5]
				jItems[ "unitMeasurement" ] := nil
				jItems[ "billItemReference" ] := nil
				jItems[ "quantity" ] := 1
				jItems[ "baseValue" ] := 0
				jItems[ "value" ] := aProds[i,4]
				jItems[ "totalAmount" ] := aProds[i,4]
				jItems[ "source" ] := nil
				jItems[ "metadata" ] := nil

			endif

			AAdd(aItems,jItems)

		next i

		( cTmpItems )->( DbCloseArea() )
	endif

	freeObj(jItems)
	fwFreeArray(aProds)

Return aItems


//------------------------------------------------------------------- 
/*/{Protheus.doc} GetFieldJson
Responsavel pela criação do Json dos itens contem os valores para MEDIÇÃO so passo 5

@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 

Static Function GetFieldJson(oData,cIdmain)
	local aItems :={}
	local aRetItensMed :={}
	local nVlrTotalBm1:= 0
	default nOpt :=0

	jField := JsonObject():New()

	aRetItensMed:= GetItemsPayLoad( oData,@nVlrTotalBm1,@cIdmain  )

	jField["op"] :=  'replace'
	jField["path"] := '/TotalAmount'
	jField["value"] := nVlrTotalBm1

	aAdd(aItems, jField)
	FreeObj( jField )
	jField := JsonObject():New()

	jField["op"] :=  'replace'
	jField["path"] := '/UsageTotalAmount'
	jField["value"] := nVlrTotalBm1

	aAdd(aItems, jField)
	FreeObj( jField )
	jField := JsonObject():New()

	jField["op"] :=  'replace'
	jField["path"] := '/Items'
	jField["value"] := aRetItensMed

	aAdd(aItems, jField)

return aItems



//------------------------------------------------------------------- 
/*/{Protheus.doc} IntegGrrBillin
A função IntegGrrBillin é responsãvel pela configuração de regua de cobrança(BillingRuler)
é nesse momento que determinaremos o dia iniacial para o envio da cobrança.

@author Robson Nayland Benjamim
@since 01/09/2023
@version Protheus 12
/*/
//------------------------------------------------------------------- 

Function IntegGrrBillin(lAutoma)

	local cPath := '/billingrulers'
	Local cEndpoint := GRRURL()
	local oRest := NIL

	default lAutoma = .F.


	cResult := GRRRestExec( 'GET', cEndpoint, cPath , @oRest )

	if !Empty( cResult )

		oResult := JSONObject():New()
		oResult:FromJSON( cResult )

		if Len(oResult["responseData"]) > 0
			oBillin := JsonObject():New()
			oBillin[ "id" ] := oResult["responseData"][Len(oResult["responseData"])]["id"] // Id da regua de cobrança
			oBillin[ "description" ] := oResult["responseData"][Len(oResult["responseData"])]["description"] // Descrição da regra de cobrança
			oBillin[ "sendingCharge" ] := BA0->BA0_DIAGRR   // Quantidade de dias onde o sistema irá gerar a cobrança antes do vencimento(>= vencimento). Onde “0” será realizado a cobrança no mesmo dia do vencimento. Obs.: O valor máximo de dias é de 10 dias.
			oBillin[ "chargeAfterDueDate" ] := '0' // Cobrança após o vencimento (Opção não habilitada no momento).
			oBillin[ "chargeAfterDueDateEachDay" ] := '1' // Quantidade do intervalo de cobrança (Opção não habilitada no momento).
			oBillin[ "chargeAfterDueDatePer" ] := '1' // Quantidade de vezes no qual será cobrado após o vencimento (Opção não habilitada no momento).
			oBillin[ "checkoutExpirationInDays" ] := 30 // Quantiade de dias no qual a cobrança será expirada (Opção não habilitada no momento).

			cJson   := oBillin:toJson()


			cResult := GRRRestExec( 'PUT', cEndpoint, cPath , @oBillin ,oBillin)

		endif

	endif

	freeObj(oRest)

Return


