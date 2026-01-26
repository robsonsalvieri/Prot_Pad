#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP01.CH"

STATIC oStVacWkfl  := NIL
STATIC oStAbsence  := NIL
STATIC oStVacLim   := NIL
STATIC cGetVacLim  := ""
STATIC cGetAbsenc  := ""
STATIC cGetVacWKF  := ""

	Private cMRrhKeyTree := ""


	WSRESTFUL Team	DESCRIPTION STR0001 //"Servico responsavel pelo tratamento de ausencias."

		WSDATA employeeId        		As String Optional
		WSDATA WsNull            		As String Optional
		WSDATA initView          		As String Optional
		WSDATA endView           		As String Optional
		WSDATA team              		As String Optional
		WSDATA role              		As String Optional
		WSDATA status            		As String Optional
		WSDATA page              		As String Optional
		WSDATA pageSize          		As String Optional
		WSDATA hierarchicalLevel 		As String Optional
		WSDATA id                		As String Optional
		WSDATA userName          		As String Optional
		WSDATA branch      		 		As String Optional
		WSDATA registry      	 		As String Optional
		WSDATA employeeName     		As String Optional		
		WSDATA divisions         		As Array  Optional
		WSDATA name              		As String Optional
		WSDATA canApprove        		As String Optional
		WSDATA startDate         		As String Optional
		WSDATA initDate          		As String Optional
		WSDATA endDate           		As String Optional
		WSDATA coordinatorId     		As String Optional
		WSDATA initPeriod        		As String Optional
		WSDATA endPeriod         		As String Optional
		WSDATA level             		As String Optional
		WSDATA onlyVacationConflicts	As String Optional

//****************************** GETs ***********************************

		WSMETHOD GET DESCRIPTION "GET" ;
			WSSYNTAX "team/absence/all/{coordinatorId} || team/teams/{coordinatorId} || team/roles/{coordinatorId} || team/organizationalsubdivision/{coordinatorId} || team/substitute/eligible/{coordinatorId} || team/substitute/{coordinatorId}"

		WSMETHOD GET AbsenseCount ;
			DESCRIPTION EncodeUTF8(STR0048) ; //"Retorna o contador do monitor de férias do time"
			PATH "/team/absence/all/count/{employeeId}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET getTeam ;
			DESCRIPTION EncodeUTF8(STR0023) ; //"Retorna a equipe de um coordenador"
			PATH "/team/employees/{coordinatorId}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET DetailBalanceTeamSum ;
			DESCRIPTION EncodeUTF8(STR0034) ; //"Retorna os saldos de horas detalhado do time para o período"
		WSSYNTAX "/team/timesheet/balanceDetails/{coordinatorId}/" ;
			PATH "/timesheet/balanceDetails/{coordinatorId}/" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET GetBalanceTeamSum ;
			DESCRIPTION EncodeUTF8(STR0019) ; //"Retorna os saldos de horas do time para o período"
		WSSYNTAX "/team/timesheet/balanceSummary/{coordinatorId}" ;
			PATH "/timesheet/balanceSummary/{coordinatorId}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET EmployeeBirthDate ;
			DESCRIPTION EncodeUTF8(STR0020) ; //"Retorna os aniversariantes do mês da equipe do funcionário"
			PATH "/team/birthdates/{employeeID}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET FindEmployee ;
			DESCRIPTION EncodeUTF8(STR0024) ; //"Retorna uma relacao de funcionarios da empresa"
		WSSYNTAX "/team/employees/find/{employeeId}" ;
			PATH "/employees/find/{employeeId}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET TeamStructure ;
			DESCRIPTION EncodeUTF8(STR0025) ; //"Retorna uma lista com os dados da estrutura hierarquica do funcionario"
		WSSYNTAX "/team/hierarchicalData/{employeeId}" ;
			PATH "/hierarchicalData/{employeeId}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET TypeDemission ;
			DESCRIPTION EncodeUTF8(STR0027) ; //"Retorna uma lista com os Tipos de Desligamento"
		WSSYNTAX "/team/demission/types" ;
			PATH "/demission/types" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET Demission ;
			DESCRIPTION EncodeUTF8(STR0033) ; //Retorna uma requisição de desligamento conforme o codigo solicitado
		WSSYNTAX "/team/demission/{employeeId}/{id}" ;
			PATH "/team/demission/{employeeId}/{id}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET delaysAbsences ;
			DESCRIPTION EncodeUTF8(STR0037) ; //Retorna uma lista com os atrasos e faltas do time
		WSSYNTAX "/team/delaysAndAbsences/{coordinatorId}" ;
			PATH "/team/delaysAndAbsences/{coordinatorId}" ;
			PRODUCES 'application/json;charset=utf-8'		

		WSMETHOD GET TotSumDelaysAbsences ;
			DESCRIPTION EncodeUTF8(STR0038) ; //Retorna o total de atrasos e faltas de todos colaboradores do time
		WSSYNTAX "/team/delaysAndAbsencesTotalizer/{coordinatorId}" ;
			PATH "/team/delaysAndAbsencesTotalizer/{coordinatorId}" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET ReasonsWorkLeave ;
			DESCRIPTION EncodeUTF8(STR0049) ; //"Retorna os Tipos de Ausências"
		WSSYNTAX "/team/workLeave/reasons" ;
			PATH "/team/workLeave/reasons" ;
			PRODUCES 'application/json;charset=utf-8'

		WSMETHOD GET WorkLeave ;
			DESCRIPTION EncodeUTF8(STR0050) ; //Retorna os afastamentos do funcionario
		WSSYNTAX "/team/workLeave/{employeeId}" ;
			PATH "/team/workLeave/{employeeId}" ;
			PRODUCES 'application/json;charset=utf-8'

//****************************** PUTs ************************************

		WSMETHOD PUT putAbsence ;
			DESCRIPTION EncodeUTF8(STR0021) ; //"Serviço responsável pela atualização da ausência."
			WSSYNTAX "/team/absence" ;
			PATH "/absence" ;
			PRODUCES 'application/json;charset=utf-8';
			TTALK "v2"

		WSMETHOD PUT putSubstitute ;
			DESCRIPTION EncodeUTF8(STR0022) ; //"Serviço responsável pela atualização de substituição."
		WSSYNTAX "/team/substitute/{coordinatorId}" ;
			PATH "/substitute/{coordinatorId}" ;
			PRODUCES 'application/json;charset=utf-8'


//****************************** POSTs ***********************************

		WSMETHOD POST DESCRIPTION "POST" ;
			WSSYNTAX "team/substitute/{coordinatorId}"

		WSMETHOD POST Demission DESCRIPTION EncodeUTF8(STR0028) ; //Inclui uma requisição de desligamento
		WSSYNTAX "/team/demission/{employeeId}" ;
			PATH "/demission/{employeeId}" ;
		
		WSMETHOD POST SubEligible DESCRIPTION EncodeUTF8(STR0059) ; //Retorna os funcionário elegíveis a substituto
		WSSYNTAX "team/substitute/eligible/{coordinatorId}" ;
			PATH "/substitute/eligible/{coordinatorId}" ;

//****************************** DELETEs *********************************

		WSMETHOD DELETE delSubstitute ;
			DESCRIPTION STR0013 ; //"Serviço responsável pela exclusão da substituição."
		WSSYNTAX "/team/substitute/{coordinatorId}/{substituteRequestId}" ;
			PATH "/substitute/{coordinatorId}/{substituteRequestId}" ;
			PRODUCES 'application/json;charset=utf-8'

	END WSRESTFUL


// -------------------------------------------------------------------
// POST fazendo o papel de um GET - Retorna os funcionário elegíveis a substituto.
// -------------------------------------------------------------------
WSMETHOD POST SubEligible WSRECEIVE coordinatorId WSSERVICE Team

	Local aEmpresas      := Nil
	Local oItem		     := JsonObject():New()
	Local oQryParam      := JsonObject():New()

	Local aData          := {}
	Local aDataLogin     := {}
	Local aParamAux      := {}
	Local aVision        := {}
	Local aQryParam 	 := {}
	Local aTeam          := {}
	Local cBody 		 := ::GetContent()
	
	Local cVision        := ""
	Local cRoutine       := "W_PWSA210.APW"
	Local cOrgCFG        := SuperGetMv("MV_ORGCFG", NIL, "0")

	Local cToken         := ""
	Local cKeyId         := ""
	Local cMatSRA        := ""
	Local cCodRD0        := ""
	Local cBranchVld     := ""
	Local lRet           := .F.
	Local lMorePages	 := .F.
	
	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  := Self:GetHeader('Authorization')
	cKeyId  := Self:GetHeader('keyId')

	aDataLogin	:= GetDataLogin(cToken, Nil, cKeyId)
	If Len(aDataLogin) > 4
		cMatSRA		:= aDataLogin[1]
		cCodRD0		:= aDataLogin[3]
		cBranchVld	:= aDataLogin[5]
	EndIf

	aVision := GetVisionAI8(cRoutine, cBranchVld)
	cVision := aVision[1][1]

	//QueryParam via body.
	oQryParam:FromJson(cBody)

	If(oQryParam != Nil)
		If(oQryParam:hasProperty('page'))
			aParamAux := {}
			AADD(aParamAux, 'PAGE')
			AADD(aParamAux, Str(oQryParam['page']))
			AADD(aQryParam, aParamAux)
		EndIf
		If(oQryParam:hasProperty('pageSize'))
			aParamAux := {}
			AADD(aParamAux, 'PAGESIZE')
			AADD(aParamAux, Str(oQryParam['pageSize']))
			AADD(aQryParam, aParamAux)
		EndIf
		If(oQryParam:hasProperty('userName') ) 
			aParamAux := {}
			AADD(aParamAux, 'USERNAME')
			AADD(aParamAux, oQryParam['userName'] )
			AADD(aQryParam, aParamAux)
		EndIf
	EndIf

	//Quando utiliza SIGORG carrega a relacao de empresas abrangidas pelo funcionario dentro da visao
	cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)
	If cOrgCFG == "2"
		aEmpresas := {}
		fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T.)
	EndIf

	aTeam := APIGetStructure(cCodRD0, cOrgCFG, cVision, cBranchVld, cMatSRA, Nil, Nil, Nil, Nil, cBranchVld, cMatSRA, Nil, Nil, Nil, Nil, .T., aEmpresas, aQryParam, @lMorePages, Nil, .F.)

	If Len(aTeam) >= 1 .And. !(Len(aTeam) == 3 .And. !aTeam[1])
		fGetSubsEligible(cBranchVld, cMatSRA, aTeam, @aData, @lRet, aQryParam, @lMorePages, cOrgCFG)
		oItem["hasNext"]  := lMorePages
		oItem["items"]    := aData
		
		cJson := oItem:ToJson()
		::SetResponse(cJson)
	Else
		lRet := .F.
		SetRestFault(400, AllTrim( EncodeUTF8(aTeam[2]) +" - " +EncodeUTF8(aTeam[3]) ))
	EndIf


Return(lRet)


WSMETHOD GET WSRECEIVE WsNull WSSERVICE Team

	Local aEmpresas      := Nil
	Local oItem		     := JsonObject():New()
	Local aMessages      := {}
	Local aData          := {}
	Local aDataLogin     := {}
	Local aVision        := {}
	Local nX			 := 0
	Local nLenParms      := Len(::aURLParms)
	Local aQryParam 	 := Self:aQueryString
	Local lAbsenceAll	 := ( nLenParms == 3 .And. !Empty(::aURLParms[3]) ) // Gestão de Férias.
	Local cRequestType   := If( lAbsenceAll, "B", Nil )
	Local cVision        := ""
	Local cRoutine       := Iif( !lAbsenceAll, "W_PWSA210.APW", "W_PWSA100A.APW" ) // Se for gestão de férias, considera o menu de férias, caso contrário, afastamentos.
	Local cOrgCFG        := SuperGetMv("MV_ORGCFG", NIL, "0")

	Local cToken         := ""
	Local cKeyId         := ""
	Local cRD0Login      := ""
	Local cMatSRA        := ""
	Local cCodRD0        := ""
	Local cBranchVld     := ""
	Local lRet           := .F.
	Local lSubsEligible	 := .F.
	Local lSubstitute	 := .F.
	Local lOnlyConf	 	 := .F.
	Local lMorePages	 := .F.

	Private	dDtRobot	 := cTod("//")
	Private aCoordTeam   := {}
	Private aOcurances   := {}

	// - Parammetros enviados pela URL - QueryString
	DEFAULT Self:initView    			:= ""
	DEFAULT Self:endView      			:= ""
	DEFAULT Self:id           			:= ""
	DEFAULT Self:name         			:= ""
	DEFAULT Self:team         			:= ""
	DEFAULT Self:role         			:= ""
	DEFAULT Self:canApprove   			:= ""
	DEFAULT Self:page         			:= ""
	DEFAULT Self:pageSize     			:= ""
	DEFAULT Self:userName     			:= ""
	DEFAULT Self:initDate     			:= ""
	DEFAULT Self:divisions    			:= {}
	DEFAULT Self:onlyVacationConflicts	:= ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  := Self:GetHeader('Authorization')
	cKeyId  := Self:GetHeader('keyId')

	// --------------------------------------------
	// - Efetua a leitura do HEADER AUTORIZATHION
	// - Pega esse valor e recupera as informações
	// - Necessárias, como matrícula, filial, etc.
	// --------------------------------------------
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cRD0Login	:= aDataLogin[2]
		cMatSRA		:= aDataLogin[1]
		cCodRD0		:= aDataLogin[3]
		cBranchVld	:= aDataLogin[5]
	EndIf

	lSubsEligible := (nLenParms == 3 .And. ::aURLParms[1] == "substitute" .And. ::aURLParms[2] == "eligible")
	lSubstitute   := (nLenParms == 2 .And. ::aURLParms[1] == "substitute" .And. !Empty(::aURLParms[2]))
	lOnlyConf     := If( !Empty(Self:onlyVacationConflicts) .And. Self:onlyVacationConflicts == "true", .T., .F. )

	//Obtem a data do queryparam que existe apenas na automação de testes
	For nX := 1 To Len( aQryParam )
		If UPPER(aQryParam[nX,1]) == "DDATEROBOT"
			dDtRobot := sToD( aQryParam[nX,2] )
		EndIf
	Next

	// ----------------------------------------------
	// - A Função GetVisionAI8() devolve por padrao
	// - Um Array com a seguinte estrutura:
	// - aVision[1][1] := "" - AI8_VISAPV
	// - aVision[1][2] := 0  - AI8_INIAPV
	// - aVision[1][3] := 0  - AI8_APRVLV
	// - Por isso as posicoes podem ser acessadas
	// - Sem problemas, ex: cVision := aVision[1][1]
	// ----------------------------------------------
	aVision := GetVisionAI8(cRoutine, cBranchVld)
	cVision := aVision[1][1]

	//Quando utiliza SIGORG carrega a relacao de empresas abrangidas pelo funcionario dentro da visao
	If cOrgCFG == "2"
		aEmpresas := {}
		fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T.)
	EndIf

	//Caso seja Gestão de Férias, exclui estagiários.
	If(lAbsenceAll)
		Aadd(aQryParam , {"CATFUNC"," 'E', 'G' "} )
	EndIf

	cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)
	aCoordTeam := APIGetStructure(cCodRD0, cOrgCFG, cVision, cBranchVld, cMatSRA, , , , cRequestType, cBranchVld, cMatSRA, , , , , .T., aEmpresas, aQryParam, @lMorePages)

	If lSubstitute
		// - Obtem a lista de substituicoes agendadas para o gestor
		fGetSubstitute( cBranchVld, cMatSRA, Self:initDate, @aData, @lRet )
	ElseIf lSubsEligible
		//Obtem os funcionarios da hierarquia para substituicao
		fGetSubsEligible( cBranchVld, cMatSRA, aCoordTeam, @aData, @lRet, aQryParam, @lMorePages, cOrgCFG )
		// - Garante a URL: /team/absence/all/{coordinatorId}
	ElseIf lAbsenceAll
		::aURLParms[3] := Iif(  ::aURLParms[3] == "%7Bcurrent%7D" .Or. ::aURLParms[3] == "{current}", cRD0Login, ::aURLParms[3] )

		// seta as ocorrencias
		setOcurances(aQryParam,@aData,aCoordTeam,cBranchVld,cMatSRA,lOnlyConf,@lMorePages)
	ElseIf nLenParms == 2 .And. !Empty(::aUrlParms[2])

		// - Obtem o LOGIN - CPF ou CODIGO.
		::aURLParms[2] := Iif(  ::aURLParms[2] == "%7Bcurrent%7D" .Or. ::aURLParms[2] == "{current}" .Or. ::aURLParms[2] == "{coordinatorId}", cRD0Login, ::aURLParms[2] )
		filterService(Self:id,Self:name,@aData,aCoordTeam,Lower(::aUrlParms[1]),cBranchVld,cMatSRA)
	EndIf


	If Lower(::aURLParms[1]) $ "absence##organizationalsubdivision" .Or. lSubsEligible .Or. lSubstitute
		If (!lSubsEligible .And. !lSubstitute) .Or. lRet
			oItem["hasNext"]  := lMorePages
			oItem["items"]    := aData
		ElseIf (!lSubstitute)
			oItem["code"] := "400"
			oItem["message"] := EncodeUTF8(STR0009) //"Nao foi localizado nenhum funcionario para substituicao."
		EndIf
	Else
		oItem["data"]     := aData
		oItem["messages"] := aMessages
		oItem["length"]   := Len(aData)
	EndIf

	cJson := oItem:ToJson()
	::SetResponse(cJson)

Return (.T.)

// -------------------------------------------------------------------
// - CARREGA OS DADOS DO CONTADOR DA GESTAO DE FERIAS
// -------------------------------------------------------------------
WSMETHOD GET AbsenseCount WSRECEIVE coordinatorId WSSERVICE Team

	Local nQp			:= 0
	Local cJson	 		:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cRD0Login		:= ""
	Local cMatSRA		:= ""
	Local cCodRD0		:= ""
	Local cBranchVld	:= ""
	Local aData			:= {0,0,0,0,0}
	Local aEmpresas		:= {}
	Local aDataLogin	:= {}
	Local aCoordTeam	:= {}
	Local aQryParam		:= Self:aQueryString

	Local oItem  		:= JsonObject():New()
	Local cVision		:= ""
	Local cRoutine		:= "W_PWSA100A.APW" //Menu de férias
	Local cOrgCFG		:= SuperGetMv("MV_ORGCFG", NIL, "0")

	Private dDtRobot	:= cToD("//")

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken := Self:GetHeader('Authorization')
	cKeyId := Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cCodRD0	    := aDataLogin[3]
		cRD0Login	:= aDataLogin[2]
		cBranchVld	:= aDataLogin[5]
		cMatSRA	    := aDataLogin[1]
	EndIf

	//Quando utiliza SIGORG carrega a relacao de empresas abrangidas pelo funcionario dentro da visao
	If !(cOrgCFG == "0")
		aVision	:= GetVisionAI8(cRoutine, cBranchVld)
		cVision := aVision[1][1]
		fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T.)
	EndIf

	Aadd(aQryParam , {"CATFUNC"," 'E', 'G' "} )
	Aadd(aQryParam , {"PAGESIZE","999"} )

	cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)
	aCoordTeam := APIGetStructure(cCodRD0, cOrgCFG, cVision, cBranchVld, cMatSRA, , , , , cBranchVld, cMatSRA, , , , , .T., aEmpresas, aQryParam)

	//Obtem a data do queryparam que existe apenas na automação de testes
	For nQp := 1 To Len( aQryParam )
		If UPPER(aQryParam[nQp,1]) == "DDATEROBOT"
			dDtRobot := STOD( aQryParam[nQp,2] )
		EndIf
	Next

	If Len(aCoordTeam) > 0 .And. !ValType( aCoordTeam[1] ) == "L"
		fGetCountAbsenses(cBranchVld, cMatSRA, aCoordTeam, @aData)
	EndIf

	oItem["expiredVacation"]   		:= aData[1]
	oItem["vacationsToExpire"] 		:= aData[2]
	oItem["doubleExpiredVacation"] 	:= aData[3]
	oItem["doubleRisk"] 			:= aData[4]
	oItem["onVacation"] 			:= aData[5]

	cJson := oItem:ToJson()
	Self:SetResponse(cJson)

Return (.T.)


WSMETHOD GET getTeam WSRECEIVE coordinatorId WSSERVICE Team

	Local oItem      := JsonObject():New()
	Local aEmpresas  := Nil
	Local aVision    := {}
	Local aDataLogin := {}
	Local aIdFunc	 := {}
	Local cVision    := ""
	Local cRoutine   := "W_PWSA210.APW" // Afastamentos - Utilizada para buscar a VISAO a partir da rotina; (AI8_VISAPV) na funCAO GetVisionAI8().
	Local cOrgCFG    := SuperGetMv("MV_ORGCFG", NIL, "0")

	Local cToken       := ""
	Local cKeyId       := ""
	Local cRD0Login    := ""
	Local cMatSRA      := ""
	Local cCodRD0      := ""
	Local cBranchVld   := ""
	Local cEmpFunc	   := cEmpAnt
	Local lHabil 	   := .T.
	Local aQryParam    := Self:aQueryString

	DEFAULT self:name              := ""
	DEFAULT Self:page              := "1"
	DEFAULT Self:pageSize          := "20"
	DEFAULT self:hierarchicalLevel := "1"

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken 		:= Self:GetHeader('Authorization')
	cKeyId		:= Self:GetHeader('keyId')

	aDataLogin	:= GetDataLogin(cToken, Nil, cKeyId)
	If Len(aDataLogin) > 0
		cCodRD0	    := aDataLogin[3]
		cRD0Login	:= aDataLogin[2]
		cBranchVld	:= aDataLogin[5]
		cMatSRA	    := aDataLogin[1]
	EndIf

	If Len(Self:aUrlParms) > 1 .And. !Empty(Self:aUrlParms[2]) .And. !("current" $ Self:aUrlParms[2])
		If Len( aIdFunc := STRTOKARR( ::aUrlParms[2], "|" ) ) > 1
			If ( cBranchVld	== aIdFunc[1] .And. cMatSRA == aIdFunc[2] .And. cEmpFunc == aIdFunc[3] )

				//Valida Permissionamento
				fPermission(cBranchVld, cRD0Login, cCodRD0, "teamManagement", @lHabil)
				If !lHabil
					SetRestFault(400, EncodeUTF8( STR0047 ) ) //"Permissão negada aos serviços de Gestão do Time"
					Return (.F.)  
				EndIf
			Else
				cBranchVld	:= aIdFunc[1]
				cMatSRA		:= aIdFunc[2]
				cEmpFunc	:= aIdFunc[3]
			EndIf
		EndIf		
	EndIf

	aVision := GetVisionAI8(cRoutine, cBranchVld, cEmpFunc)
	cVision := aVision[1][1]

	//Quando utiliza SIGAORG carrega a relacao de empresas abrangidas pelo funcionario dentro da visao
	If cOrgCFG == "2"
		aEmpresas := {}
		fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T., cEmpFunc)
	EndIf

	cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)

	oItem := GetDataForJob("31", {  cBranchVld	, ;
									   cEmpFunc		, ;
									   cMatSRA		, ;
									   { ""			, ;  // 1
									   cOrgCFG		, ;  // 2
									   cVision		, ;  // 3
									   cBranchVld	, ;  // 4 
									   cMatSRA		, ;  // 5
									   NIL 			, ;  // 6
									   NIL 			, ;  // 7
									   NIL 			, ;  // 8
									   NIL 			, ;  // 9
									   cBranchVld	, ;  // 10
									   cMatSRA		, ;  // 11
									   NIL 			, ;  // 12
									   NIL 			, ;  // 13
									   NIL 			, ;  // 14
									   NIL 			, ;  // 15
									   .T. 			, ;  // 16
									   aEmpresas	, ;  // 17
									   aQryParam }	, ;  // 18
									   }			, ;
									   cEmpFunc   	, ;
									   cEmpAnt )

	cJson := oItem:ToJson()
	::SetResponse(cJson)

Return (.T.)

// -------------------------------------------------------------------
// - EXIBE O BANCO DE HORAS DO TIME
// -------------------------------------------------------------------
WSMETHOD GET GetBalanceTeamSum PATHPARAM coordinatorId WSREST Team

	Local oItem		 	:= JsonObject():New()
	Local aEventos		:= {}
	Local aDataLogin	:= {}
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cLogin		:= ""
	Local cRD0Cod		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local lSexagenal	:= .T.
	Local lDemit		:= .F.
	Local lHabil 		:= .T.

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	DEFAULT Self:initPeriod    := ""
	DEFAULT Self:endPeriod     := ""

	cToken		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cBranchVld := aDataLogin[5]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
	EndIf

	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "dashboardBalanceTeamSum", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0052 )) //"Permissão negada ao serviço do banco de horas do time"
		Return (.F.)  
	EndIf

	aEventos := fTeamBalanc( cBranchVld, cMatSRA, Self:initPeriod, Self:endPeriod, lSexagenal )

	If !Empty(aEventos)
		oItem["totalExtraHours"]    := HourToMs( cValToChar( Abs(aEventos[1]) ) ) * If( aEventos[1] > 0, 1, -1 )
		oItem["totalNegativeHours"] := HourToMs( cValToChar( Abs(aEventos[2]) ) ) * If( aEventos[2] > 0, 1, -1 )
	EndIf

	cJson := oItem:ToJson()
	Self:SetResponse(cJson)
	FreeObj(oItem)

Return(.T.)

// -------------------------------------------------------------------
// - EXIBE O BANCO DE HORAS DETALHADO DO TIME
// -------------------------------------------------------------------
WSMETHOD GET DetailBalanceTeamSum PATHPARAM coordinatorId WSREST Team

	Local oItem           := JsonObject():New()
	Local oItemDetail     := JsonObject():New()
	Local aEventos        := {}
	Local aDataLogin      := {}
	Local aItens          := {}
	Local nX              := 0
	Local nCount          := 0
	Local nPage           := 0
	Local nPageSize       := 0
	Local nRegIni         := 0
	Local nRegFim         := 0
	Local nLenEven		  := 0
	Local cJson           := ""
	Local cToken          := ""
	Local cKeyId          := ""
	Local cMatSRA         := ""
	Local cBranchVld      := ""
	Local cLogin          := ""
	Local cRD0Cod         := ""	
	Local lDemit          := .F.
	Local lHabil          := .T.
	Local lMorePage       := .F.
	Local lSexagenal      := .T. //SuperGetMv("MV_HORASDE",, "N") == "S" //Desabilitado porque no App apresenta somente sexagenal

	DEFAULT Self:initDate     := ""
	DEFAULT Self:endDate      := ""
	DEFAULT Self:page         := "" // Quando é o download excel das informações, o frontEnd não envia as informações do page.
	DEFAULT Self:pageSize	  := "" // Quando é o download excel das informações, o frontEnd não envia as informações do pageSize.
	DEFAULT Self:employeeName := ""

	Self:SetHeader('Access-Control-Allow-Credentials', "true")

	cToken     := Self:GetHeader('Authorization')
	cKeyId     := Self:GetHeader('keyId')
	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA    := aDataLogin[1]
		cBranchVld := aDataLogin[5]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
	EndIf

	If !Empty(cBranchVld) .And. !Empty(cMatSRA)

		//Valida Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "dashboardBalanceTeamSum", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0052 )) //"Permissão negada ao serviço do banco de horas do time"
			Return (.F.)  
		EndIf

		//Carrega os dados do BH do time
		aEventos := fBalanceSumPer( cBranchVld, cMatSRA, Self:initDate, Self:endDate, lSexagenal, Self )
		nLenEven := Len(aEventos)

		// Faz o controle de peginacao
		// No caso do download do arquivo excel, o frontEnd não envia as informações do page e do pageSize.
		// Como o pageSize não será enviado, assume-se então o total dos registros apurados no array aEventos
		nPage     := If( Empty(Self:page), 1, Val(Self:page) )
		nPageSize := If( Empty(Self:pageSize), If( nLenEven > 0, nLenEven, 6 ), Val(Self:pageSize) )
		If nPage == 1
			nRegIni := 1
			nRegFim := nPageSize
		Else
			nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
			nRegFim := ( nRegIni + nPageSize ) - 1
		EndIf

		If nLenEven > 0

			For nX := 1 To nLenEven

				nCount ++

				If ( nCount >= nRegIni .And. nCount <= nRegFim )
					oItemDetail := JsonObject():New()
					oItemDetail["employeeId"]      := aEventos[nX, 4] +"|"+ aEventos[nX, 5] +"|"+ aEventos[nX, 8]	//Filial | Matricula | Empresa
					oItemDetail["employeeName"]    := Alltrim(EncodeUTF8(aEventos[nX, 6]))  //Nome
					oItemDetail["employeeRole"]    := Alltrim(aEventos[nX, 7])              //Descricao da função
					oItemDetail["previousBalance"] := HourToMs( cValToChar( Abs(aEventos[nX,1]) ) ) * If( aEventos[nX,1] > 0, 1, -1 ) //Saldo Anterior
					oItemDetail["currentBalance"]  := HourToMs( cValToChar( Abs(aEventos[nX,3]) ) ) * If( aEventos[nX,3] > 0, 1, -1 ) //Saldo atual
					oItemDetail["totalBalance"]    := HourToMs( cValToChar( Abs(aEventos[nX,2]) ) ) * If( aEventos[nX,2] > 0, 1, -1 ) //Total BH
					aAdd( aItens, oItemDetail)
				ElseIf nCount >= nRegFim
					lMorePage := .T.
					Exit
				EndIf

			Next nX

		EndIf

	EndIf

	oItem["items"] 	 := aItens
	oItem["hasNext"] := lMorePage

	cJson := oItem:ToJson()
	Self:SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// - EXIBE ANIVERSARIANTES DO MÊS
// -------------------------------------------------------------------
WSMETHOD GET EmployeeBirthDate PATHPARAM employeeId WSREST Team

	Local oItem		 	:= JsonObject():New()
	Local aEventos		:= {}
	Local aDataLogin	:= {}
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cLogin		:= ""
	Local cRD0Cod 		:= ""
	Local lMorePage		:= .F.
	Local lDemit		:= .F.
	Local lHabil 		:= .T.

	DEFAULT Self:page 		:= "1"
	DEFAULT Self:pageSize 	:= "6"

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId		:= Self:GetHeader('keyId')

	aDataLogin	:= GetDataLogin(cToken,.T.,cKeyId)
	If Len(aDataLogin) > 0
		cBranchVld := aDataLogin[5]
		cMatSRA    := aDataLogin[1]
		cLogin     := aDataLogin[2]
		cRD0Cod    := aDataLogin[3]
		lDemit     := aDataLogin[6]
	EndIf

	//Valida Permissionamento
	fPermission(cBranchVld, cLogin, cRD0Cod, "dashboardBirthdays", @lHabil)
	If !lHabil .Or. lDemit
		SetRestFault(400, EncodeUTF8( STR0039 )) //"Permissão negada ao serviço de aniversariantes do mês na home."
		Return (.F.)  
	EndIf

	aEventos := fEmpBirth( cBranchVld, cMatSRA, @lMorePage, Self:page, Self:pageSize )

	If !Empty(aEventos)

		oItem["hasNext"] := lMorePage
		oItem["items"]   := aEventos

	EndIf

	cJson := oItem:ToJson()
	::SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// RETORNA DADOS DA ESTRUTURA HIERARQUICA DO FUNCIONARIO
// -------------------------------------------------------------------
WSMETHOD GET TeamStructure PATHPARAM employeeId WSREST Team

	Local oItem			:= JsonObject():New()
	Local oItemDetail	:= JsonObject():New()
	Local cRoutine		:= "W_PWSA100A.APW"
	Local cOrgCFG		:= SuperGetMv("MV_ORGCFG", NIL, "0")
	Local lOrgCFG		:= cOrgCFG == "2"
	Local cRegAtual		:= ""
	Local cBranchVld	:= ""
	Local cCodMat		:= ""
	Local cFilSup		:= ""
	Local cMatSup		:= ""
	Local cNameSup		:= ""
	Local cFuncSup		:= ""
	Local cLevel		:= ""
	Local cNome         := ""
	Local cVision		:= ""
	Local aVision		:= {}
	Local aData			:= {}
	Local aFunc			:= {}
	Local aGetStruct	:= {}
	Local aPairStruct	:= {}
	Local aArrayData	:= {}
	Local aIdFunc		:= {}
	Local lMorePage		:= .F.
	Local lDataLead		:= .F.
	Local lNomeSoc      := SuperGetMv("MV_NOMESOC", NIL, .F.)
	Local nX 	 	 	:= 0
	Local nY 	 	 	:= 0
	Local nCount  	 	:= 0
	Local nPage  	 	:= 0
	Local nPageSize	 	:= 0
	Local nRegIni  	 	:= 0
	Local nRegFim  	 	:= 0
	Local cCodEmp		:= Nil
	Local cEmpSup		:= Nil
	Local aListEmp		:= Nil

	DEFAULT Self:page		:= 1
	DEFAULT Self:pageSize	:= 6
	DEFAULT Self:level		:= "lead"

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	If !Empty( Self:employeeId )
		aIdFunc	:= STRTOKARR( Self:employeeId, "|" )
		If Len( aIdFunc ) > 1
			cBranchVld	:= aIdFunc[1]
			cCodMat		:= aIdFunc[2]
			cCodEmp		:= If( Len(aIdFunc)>2, aIdFunc[3], cEmpAnt )
		EndIf
	EndIf

	If !Empty(cCodMat)

		//A partir da primeira letra identifica o nivel
		cLevel	:= UPPER( SubStr( AllTrim(Self:level), 1, 1 ) )

		//busca visão para a solicitação de férias
		aVision := GetVisionAI8(cRoutine, cBranchVld, cCodEmp )
		cVision := aVision[1][1]

		//Quando utiliza SIGORG obtem a relacao de empresas conforme a visao do funcionario que esta sendo pesquisado
		If lOrgCFG
			aListEmp := {}
			fGetTeamManager(cBranchVld, cCodMat, @aListEmp, cRoutine, cOrgCFG, .T., cCodEmp)
		EndIf

		//Identifica o superior do funcionario
		cMRrhKeyTree := fMHRKeyTree(cBranchVld, cCodMat)
		aGetStruct	:= APIGetStructure("", cOrgCFG, cVision, cBranchVld, cCodMat, , , , , cBranchVld, cCodMat, , , , cCodEmp, .T., aListEmp)

		If Len(aGetStruct) > 0 .And. !ValType( aGetStruct[1] ) == "L"
			cFilSup		:= aGetStruct[1]:ListOfEmployee[1]:SupFilial	//Filial do Superior
			cMatSup		:= aGetStruct[1]:ListOfEmployee[1]:SupRegistration	//Matricula do Superior
			cNameSup    := Alltrim(EncodeUTF8(If(lNomeSoc .And. !Empty(aGetStruct[1]:ListOfEmployee[1]:SocialNameSup), aGetStruct[1]:ListOfEmployee[1]:SocialNameSup, aGetStruct[1]:ListOfEmployee[1]:NameSup))) //Nome do Superior
			lDataLead	:= !Empty(cFilSup) .And. !Empty(cMatSup)
			cEmpSup     := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa	//Empresa do Superior
			cFuncSup	:= Alltrim( EncodeUTF8( fSupGetPosition(cFilSup, cMatSup, cEmpSup) ) ) //Função do Superior
		EndIf

		If cLevel == "L"
			//Superiores (Lead)
			If lDataLead
				aAdd( aFunc, { cFilSup, cMatSup, AllTrim( cNameSup ), AllTrim( cFuncSup ) } )
			EndIf

		ElseIf cLevel == "P"
			//Pares (Pair)
			If lDataLead

				//Considera as empresas do superior que esta sendo pesquisado
				If lOrgCFG
					aListEmp := {}
					fGetTeamManager(cFilSup, cMatSup, @aListEmp, cRoutine, cOrgCFG, .T., cEmpSup)
				EndIf

				cMRrhKeyTree:= fMHRKeyTree(cFilSup, cMatSup)
				aPairStruct	:= APIGetStructure("", cOrgCFG, cVision, cFilSup, cMatSup, , , , , cFilSup, cMatSup, , , , cEmpSup, .T., aListEmp) //Carrega dados da estrutura do Superior
				aArrayData	:= aPairStruct
			EndIf
		Else
			//Subordinados (Subordinate)
			aArrayData	:= aGetStruct
		EndIf

		If cLevel $ "P|S" //Pares ou subordinados

			//Verifica se carregou dados da hierarquia.
			If Len(aArrayData) > 0 .And. !ValType( aArrayData[1] ) == "L"
				For nX := 1 To Len(aArrayData)
					For nY := 1 To Len(aArrayData[nX]:ListOfEmployee)

						cRegAtual := aArrayData[1]:ListOfEmployee[nY]:EmployeeEmp + aArrayData[1]:ListOfEmployee[nY]:Registration

						If !(cRegAtual $ ( cCodEmp + cCodMat +"|"+ cEmpSup + cMatSup)) //Nao considera a propria matricula nem a do superior

							oEmployee := aArrayData[nX]:ListOfEmployee[nY]
							cNome     := Alltrim(EncodeUTF8(If(lNomeSoc .And. !Empty(oEmployee:SocialName), oEmployee:SocialName, oEmployee:Name)))

							aAdd( aFunc,{ 	oEmployee:EmployeeFilial,	;	//Filial
							oEmployee:Registration,						;	//Matricula
							cNome,                                      ;   //Nome
							Alltrim( EncodeUTF8(oEmployee:FunctionDesc) );	//Função
							} )
						EndIf
					Next nY
				Next nX
			EndIf
		EndIf

		If Len( aFunc ) > 0
			//Faz o controle de paginacao
			nPage 		:= If( Self:page == "1" .Or. Self:page == "", 1, Val(Self:page) )
			nPageSize 	:= If( Empty(Self:pageSize), 6, Val(Self:pageSize) )
			If nPage == 1
				nRegIni := 1
				nRegFim := nPageSize
			Else
				nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
				nRegFim := ( nRegIni + nPageSize ) - 1
			EndIf

			//Ordena os funcionarios por nome
			aSort( aFunc,,,{|x,y| x[3] < y[3] } )

			//Adiciona as matriculas compreendidas na pagina e tamanho solicitados
			For nX := 1 To Len( aFunc )
				nCount ++

				If ( nCount >= nRegIni .And. nCount <= nRegFim )
					oItemDetail	:= JsonObject():New()
					oItemDetail["id"] 				:= aFunc[nX, 1] +"|"+ aFunc[nX, 2]
					oItemDetail["name"] 			:= Alltrim( EncodeUTF8( aFunc[nX, 3] ) )
					oItemDetail["roleDescription"]	:= Alltrim( EncodeUTF8( aFunc[nX, 4] ) )
					aAdd( aData, oItemDetail )
				Else
					If nCount >= nRegFim
						lMorePage := .T.
						Exit
					EndIf
				EndIf
			Next nX
		EndIf

	EndIf

	oItem["hasNext"] := lMorePage
	oItem["items"]   := aData

	cJson := oItem:ToJson()
	Self:SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// RETORNA UMA RELACAO DE FUNCIONARIOS DA EMPRESA
// -------------------------------------------------------------------
WSMETHOD GET FindEmployee PATHPARAM employeeId WSREST Team

	Local oItem			:= JsonObject():New()
	Local oItemDetail	:= JsonObject():New()
	Local cRoutine		:= "W_PWSA100A.APW"
	Local cOrgCFG		:= SuperGetMv("MV_ORGCFG",NIL,"0")
	Local cLastFil		:= "!!"
	Local cLastEmp		:= "!!"
	Local cCidade		:= ""
	Local cFilter		:= ""
	Local cAliasSRA		:= ""
	Local cNameSup		:= ""
	Local cVision		:= ""
	Local cFone			:= ""
	Local cNome			:= ""
	Local cJoinSQB		:= ""
	Local cJoinSRJ		:= ""
	Local cBranchVld	:= ""
	Local cMatSRA		:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""		
	Local aVision		:= {}
	Local aFunc			:= {}
	Local aInfo			:= {}
	Local aData			:= {}
	Local aEmpresas		:= {}
	Local aGetStruct	:= {}
	Local aDataLogin	:= {}
	Local lEstruct		:= .T.
	Local lMorePage		:= .F.
	Local lNomeSoc      := SuperGetMv("MV_NOMESOC", NIL, .F.)
	Local nX 	 	 	:= 0
	Local nCount  	 	:= 0
	Local nPage  	 	:= 0
	Local nPageSize	 	:= 0
	Local nRegIni  	 	:= 0
	Local nRegFim  	 	:= 0

	//Posicao de cada elemento incluido na matriz aFunc
	Local nPosEmp  	 	:= 1
	Local nPosFil  	 	:= 2
	Local nPosMat   	:= 3
	Local nPosName 		:= 6
	Local nPosEmail 	:= 7
	Local nPosDDD  		:= 8
	Local nPosFone		:= 9
	Local nPosDepDesc	:= 10
	Local nPosFuncDesc	:= 11

	DEFAULT Self:page		:= "1"
	DEFAULT Self:pageSize	:= "3"
	DEFAULT Self:name		:= ""

	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  	:= Self:GetHeader('Authorization')
	cKeyId		:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cBranchVld := aDataLogin[5]
		cMatSRA    := aDataLogin[1]
	EndIf	

	//Aplica filtro caso seja informado
	If !Empty(Self:name)

		//Faz o controle de paginacao
		nPage 		:= If( Self:page == "1" .Or. Self:page == "", 1, Val(Self:page) )
		nPageSize 	:= If( Empty(Self:pageSize), 3, Val(Self:pageSize) )
		If nPage == 1
			nRegIni := 1
			nRegFim := nPageSize
		Else
			nRegIni := ( nPageSize * ( nPage - 1 ) ) + 1
			nRegFim := ( nRegIni + nPageSize ) - 1
		EndIf

		//Carrega a relacao de empresas que será avaliada e também verifica se o funcionario é lider
		lTeam := fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T.)

		//Considera a propria empresa caso ela nao esteja entre a relacao encotrada
		//Exemplo: quando o funcionario nao é lider, ou é lider só de funcionarios de outra empresa
		If aScan( aEmpresas, { |x| x == cEmpAnt } ) == 0
			aAdd( aEmpresas, cEmpAnt )
		EndIf

		//Pesquisa os funcionarios em cada empresa que sera avaliada
		For nX := 1 To Len( aEmpresas )

			If !( cLastEmp == aEmpresas[nX] )

				cJoinSQB := "% SRA.RA_DEPTO = SQB.QB_DEPTO AND " + fMHRTableJoin("SRA", "SQB") + "%"
				cJoinSRJ := "% SRA.RA_CODFUNC = SRJ.RJ_FUNCAO AND " + fMHRTableJoin("SRA", "SRJ") + "%"

				cFilter := "% (RA_NOME LIKE '%" + UPPER( Self:name ) + "%'" 
				cFilter += If(lNomeSoc, " OR RA_NSOCIAL LIKE '%" + UPPER( Self:name ) + "%' ", "")
				cFilter += " ) AND RA_SITFOLH NOT IN ('D','T') AND %"

				__cSRAtab := "%" + RetFullName("SRA", aEmpresas[nX]) + "%"
				__cSQBtab := "%" + RetFullName("SQB", aEmpresas[nX]) + "%"
				__cSRJtab := "%" + RetFullName("SRJ", aEmpresas[nX]) + "%"

				cAliasSRA  := GetNextAlias()

				BeginSql ALIAS cAliasSRA
				SELECT RA_FILIAL, RA_MAT, RA_DEPTO, RA_CODFUNC, RA_NOME, RA_NSOCIAL, RA_EMAIL, RA_DDDFONE, RA_TELEFON, RA_NOMECMP, QB_DESCRIC, RJ_DESC 
				FROM %exp:__cSRAtab% SRA
				INNER JOIN %exp:__cSQBtab% SQB
					ON %exp:cJoinSQB% 
				INNER JOIN %exp:__cSRJtab% SRJ
					ON %exp:cJoinSRJ%
				WHERE 	%Exp:cFilter%
						SRA.%notDel% AND
						SQB.%notDel% AND
						SRJ.%notDel% 
				ORDER BY 
					5, 1
				EndSql

				While !(cAliasSRA)->(Eof())

					cNome := If(lNomeSoc .And. !Empty((cAliasSRA)->RA_NSOCIAL), (cAliasSRA)->RA_NSOCIAL, (cAliasSRA)->RA_NOMECMP)
					cNome := EncodeUTF8(If(Empty(cNome), (cAliasSRA)->RA_NOME, cNome))

					aAdd( aFunc, {									;
						aEmpresas[nX],								;	//01 - Empresa
					(cAliasSRA)->RA_FILIAL,							;	//02 - Filial
					(cAliasSRA)->RA_MAT,							;	//03 - Matricula
					(cAliasSRA)->RA_DEPTO,							;	//04 - Codigo Departamento
					Alltrim( EncodeUTF8( (cAliasSRA)->RA_CODFUNC) ),;	//05 - Codigo da Função
					Alltrim( EncodeUTF8(cNome) ), 					;	//06 - Nome
					AllTrim( (cAliasSRA)->RA_EMAIL ),				;	//07 - E-mail
					AllTrim( (cAliasSRA)->RA_DDDFONE ),				;	//08 - DDD
					AllTrim( (cAliasSRA)->RA_TELEFON ),				;	//09 - Telefone
					AllTrim( EncodeUTF8((cAliasSRA)->QB_DESCRIC) ),	;	//10 - Descricao do departamento
					AllTrim( EncodeUTF8((cAliasSRA)->RJ_DESC) )		;	//11 - Descricao da funcao
					} )
					(cAliasSRA)->(dbSkip())
				EndDo

				cLastEmp := aEmpresas[nX]

				(cAliasSRA)->( DBCloseArea() )
			EndIf
		Next

		//Ordena os funcionarios por nome
		aSort( aFunc,,,{|x,y| x[6] < y[6] } )

		cLastEmp := "!!"

		//Trata o resultado da consulta
		For nX := 1 To Len( aFunc )

			nCount		++
			cFone		:= ""
			cNameSup	:= ""

			//Identifica a cidade da empresa
			If cLastEmp+cLastFil <> aFunc[nX, nPosEmp]+aFunc[nX, nPosFil]
				aInfo	 := {}
				cLastFil := aFunc[nX, nPosFil]
				cLastEmp := aFunc[nX, nPosEmp]

				fInfo(@aInfo, cLastFil, cLastEmp )
				If Len( aInfo ) > 0
					cCidade := AllTrim( aInfo[05] ) //Cidade
				EndIf
			EndIf

			//Ajusta os dados do telefone
			cFone := TRANSFORM( aFunc[nX, nPosFone], If( Len(aFunc[nX, nPosFone]) > 8, "@R 99999-9999", "@R 9999-9999" ) )
			If !Empty( aFunc[nX, nPosDDD] )
				cFone := aFunc[nX, nPosDDD] +" "+ cFone
			EndIf

			//busca visão para a solicitação de férias
			aVision := GetVisionAI8(cRoutine, aFunc[nX, nPosFil], aFunc[nX, nPosEmp] )
			cVision := aVision[1][1]

			//Identifica o superior do funcionario
			cMRrhKeyTree:= fMHRKeyTree(aFunc[nX, nPosFil], aFunc[nX, nPosMat])
			aGetStruct	:= APIGetStructure("", cOrgCFG, cVision, aFunc[nX, nPosFil], aFunc[nX, nPosMat], , , , , aFunc[nX, nPosFil], aFunc[nX, nPosMat], , , , aFunc[nX, nPosEmp], .T., aEmpresas)
			lEstruct	:= Len(aGetStruct) > 0 .And. !ValType( aGetStruct[1] ) == "L" //Verifica se carregou dados da hierarquia.

			If lEstruct
				cNameSup := AllTrim(EncodeUTF8(If(lNomeSoc .And. !Empty(aGetStruct[1]:ListOfEmployee[1]:SocialNameSup), aGetStruct[1]:ListOfEmployee[1]:SocialNameSup, aGetStruct[1]:ListOfEmployee[1]:NameSup)))
			EndIf

			//Adiciona as matriculas compreendidas na pagina e tamanho solicitados
			If ( nCount >= nRegIni .And. nCount <= nRegFim )
				oItemDetail	:= JsonObject():New()
				oItemDetail["id"] 				:= aFunc[nX, nPosFil] +"|"+ aFunc[nX, nPosMat] +"|"+ aFunc[nX, nPosEmp]
				oItemDetail["name"] 			:= Alltrim( EncodeUTF8( aFunc[nX, nPosName] ) )
				oItemDetail["roleDescription"]	:= Alltrim( EncodeUTF8( aFunc[nX, nPosFuncDesc] ) )
				oItemDetail["department"]		:= Alltrim( EncodeUTF8( aFunc[nX, nPosDepDesc] ) )
				oItemDetail["city"]				:= Alltrim( EncodeUTF8( cCidade ) )
				oItemDetail["leadName"]			:= Alltrim( EncodeUTF8( cNameSup ) )
				oItemDetail["email"]			:= aFunc[nX, nPosEmail]
				oItemDetail["telefone"]			:= cFone
				aAdd( aData, oItemDetail )
			Else
				If nCount >= nRegFim
					lMorePage := .T.
					Exit
				EndIf
			EndIf
		Next

	EndIf

	oItem["hasNext"] 	:= lMorePage
	oItem["items"]		:= aData

	cJson := oItem:ToJson()
	::SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// RETORNA UMA RELACAO COM OS TIPOS DE DESLIGAMENTO
// -------------------------------------------------------------------
WSMETHOD GET TypeDemission WSREST Team

	Local oItem			:= JsonObject():New()
	Local oItemDetail	:= JsonObject():New()
	Local aData			:= {}
	Local aTabS043		:= {}
	Local aDataLogin	:= {}
	Local lRet			:= .F.
	Local nX			:= 0
	Local cToken	 	:= ""
	Local cKeyId	 	:= ""
	Local cMatSRA		:= ""
	Local cBranchVld	:= ""
	Local cMsg			:= EncodeUTF8(STR0026) //"Não foi possível carregar os Tipos de Rescisão."

	Self:SetContentType("application/json")
	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  	:= Self:GetHeader('Authorization')
	cKeyId		:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cBranchVld := aDataLogin[5]
		cMatSRA    := aDataLogin[1]
	EndIf

	If !Empty(cMatSRA) .Or. Empty(cBranchVld)

		fCarrTab( @aTabS043, "S043", date() ,.T., , .T., cBranchVld)

		For nX := 1 To Len( aTabS043 )
			oItemDetail 		:= JsonObject():New()
			oItemDetail["id"]	:= aTabS043[nX, 5]
			oItemDetail["name"]	:= AllTrim( EncodeUTF8(aTabS043[nX, 6]) )
			aAdd( aData, oItemDetail )
		Next nX

	EndIf

	oItem["items"] 	  := aData
	oItem["hasNext"]  := .F.

	If ( lRet := Len(aData) > 0 )
		cJson := oItem:ToJson()
		Self:SetResponse(cJson)
	Else
		SetRestFault(400, cMsg)
	EndIf

Return( lRet )

// -------------------------------------------------------------------
// - RETORNA A REQUISICAO DE DESLIGAMENTO CONFORME O CODIGO SOLICITADO
// -------------------------------------------------------------------
WSMETHOD GET Demission WSREST Team

	Local oType         := JsonObject():New()
	Local oItems        := JsonObject():New()
	Local cMatSRA       := ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cTpDemiss     := ""
	Local cNameDemiss   := ""
	Local cIniJustify   := ""
	Local cJustify      := ""
	Local cIdCrypt      := ""
	Local cFilRH3       := ""
	Local cCodRH3       := ""
	Local cContent      := ""
	Local cNameArq      := ""
	Local cType         := "" 
	Local cMsgError     := ""
	Local lNewHire      := .F.
	Local lRet          := .T.
	LocaL aIdReq        := {}
	LocaL aData         := {}
	Local nX            := 0

	Self:SetContentType("application/json")
	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId		:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cBranchVld := aDataLogin[5]
		cMatSRA    := aDataLogin[1]
	EndIf

	If Len(Self:aUrlParms) > 2 .And. !Empty(Self:aUrlParms[3])
		cIdCrypt := rc4crypt(Self:aUrlParms[3], "MeuRH#Requisicao", .F., .T.)
		aIdReq   := STRTOKARR(cIdCrypt, "|")
	EndIF

	//Validação dos dados.
	lRet      := !Empty(cBranchVld) .And. !Empty(cMatSRA) .And. Len( aIdReq ) > 3
	cMsgError := If(lRet, cMsgError, EncodeUTF8(STR0057)) //"Dados inválidos."

	If lRet

		cFilRH3 := aIdReq[1]
		cCodRH3 := aIdReq[4]

		aData := fGetRH4Cpos( cFilRH3, cCodRH3 )

		//Validação dos dados.
		lRet      := Len(aData) > 0
		cMsgError := If(lRet, cMsgError, EncodeUTF8(STR0057)) //"Dados inválidos."

		If lRet

			for nX := 1 To Len( aData )
				if aData[nX,1] == "RX_COD"
					cTpDemiss := Alltrim( aData[nX,2] )
				elseif aData[nX,1] == "RX_TXT"
					cNameDemiss := Alltrim( aData[nX,2] )
				elseif aData[nX,1] == "TMP_NOVAC"
					lNewHire := UPPER( Alltrim( aData[nX,2] ) ) == "SIM"
				elseif aData[nX,1] == "TMP_OBS"
					cIniJustify := EncodeUTF8( Alltrim( aData[nX,2] ) )
				endif
			next nX

			cJustify := getRGKJustify(xFilial("RGK", aIdReq[1]), aIdReq[4], ,.T.)
			If Empty(cJustify)
				cJustify := DecodeUTF8(cIniJustify)
			EndIf

			//Tipo e descricao da demissao
			oType      		            := JsonObject():New()
			oType["id"]    	            := cTpDemiss
			oType["name"]               := cNameDemiss

			//Dados do desligamento incluindo o objeto com o Tipo
			oItems                     := JsonObject():New()
			oItems["id"]               := rc4crypt(Self:aUrlParms[3], "MeuRH#Requisicao")
			oItems["demissionJustify"] := cJustify
			oItems["newHire"]          := lNewHire
			oItems["demissionType"]    := oType

			// Caso tenha o anexo, faz a busca do anexo.
			If oItems["hasAttachment"] := fHaveAttach(cFilRH3, cCodRH3)
				cContent := fInfBcoFile(1, cFilRH3, cCodRH3, cBranchVld, cMatSRA, @cNameArq, @cType, @cMsgError)
				
				//Valida se os arquivo foi localizado.
				If lRet := Empty(cMsgError)
					oItems["file"]            := JsonObject():New() 	
					oItems["file"]["name"]    := cNameArq
					oItems["file"]["type"]    := cType
					oItems["file"]["content"] := cContent					
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		cJson := oItems:ToJson()
		::SetResponse(cJson)
	Else
		SetRestFault(400, cMsgError)
	EndIf

Return(lRet)

// -------------------------------------------------------------------
// - RETORNA UMA LISTA COM OS ATRASOS E FALTAS DO TIME
// -------------------------------------------------------------------
WSMETHOD GET delaysAbsences WSREST Team

	Local oItems        := NIL
	Local cRoutine		:= "W_PWSA290.APW" //Menu - Consulta Listagem de marcacoes 
	Local cOrgCFG		:= SuperGetMv("MV_ORGCFG",NIL,"0")
	LocaL aVision       := {}
	LocaL aEmpresas     := {}
	LocaL aDataLogin    := {}
	LocaL aCoordTeam    := {}
	LocaL aEventos    	:= {}
	LocaL aData 		:= {}
	Local cCodRD0       := ""	
	Local cMatSRA       := ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cVision       := ""	
	Local aQryParam		:= Self:aQueryString
	Local aFiltroApi	:= {}
	Local nPos		    := 0
	
	LocaL nX        	:= 0
	LocaL nPosEmp 		:= 1
	LocaL nPosFil 		:= 2
	LocaL nPosMat 		:= 3
	LocaL nPosNome 		:= 4
	LocaL nPosData 		:= 5
	LocaL nPosDelay 	:= 6
	LocaL nPosAbsence 	:= 7
	Local nPosOverT		:= 8
	Local nPosTpHe      := 9
	Local lNextPage		:= .F.
	Local lContinua     := .T.	

	Self:SetContentType("application/json")
	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId		:= Self:GetHeader('keyId')

	aDataLogin	:= GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA		:= aDataLogin[1]
		cCodRD0		:= aDataLogin[3]
		cBranchVld	:= aDataLogin[5]
	EndIf

	aVision := GetVisionAI8(cRoutine, cBranchVld)
	cVision := aVision[1][1]

	If ( nPos := aScan(aQryParam, { |x| x[1] == "NAME" } ) ) > 0
		aAdd(aFiltroApi, { aQryParam[nPos,1],aQryParam[nPos,2]})
	EndIf

	//Quando utiliza SIGORG carrega a relacao de empresas abrangidas pelo funcionario dentro da visao
	If cOrgCFG == "2"
		aEmpresas := {}
		fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T.)
	EndIf

	cMRrhKeyTree	:= fMHRKeyTree(cBranchVld, cMatSRA)
	aCoordTeam		:= APIGetStructure(cCodRD0, cOrgCFG, cVision, cBranchVld, cMatSRA, , , , , cBranchVld, cMatSRA, , , , , .T., aEmpresas, aFiltroApi)
	lContinua 		:= Len(aCoordTeam) > 0 .And. !ValType( aCoordTeam[1] ) == "L" //Verifica se carregou dados da hierarquia.

	If lContinua

		aEventos := fGetdelaysAbsences( cBranchVld, cMatSRA, .F., aCoordTeam, aQryParam, @lNextPage )

		For nX := 1 To Len(aEventos)
			If aEventos[nX, nPosDelay] > 0 
				oItems                  := JsonObject():New()
				oItems["id"]            := aEventos[nX, nPosFil] +"|"+ aEventos[nX, nPosMat] +"|"+ aEventos[nX, nPosEmp] +"|"+ cValToChar(nX)
				oItems["branch"]		:= aEventos[nX, nPosFil]
				oItems["registration"]	:= aEventos[nX, nPosMat]
				oItems["name"] 			:= Alltrim(EncodeUTF8(aEventos[nX, nPosNome]))
				oItems["occurrence"]	:= "delay"
				oItems["date"]    		:= FwTimeStamp(6, STOD( aEventos[nX, nPosData] ), "12:00:00")
				oItems["amountHours"]	:= aEventos[nX, nPosDelay]
				aAdd( aData, oItems )
			EndIf
			If aEventos[nX, nPosAbsence] > 0 
				oItems                  := JsonObject():New()
				oItems["id"]            := aEventos[nX, nPosFil] +"|"+ aEventos[nX, nPosMat] +"|"+ aEventos[nX, nPosEmp] +"|"+ cValToChar(nX)
				oItems["branch"]		:= aEventos[nX, nPosFil]
				oItems["registration"]	:= aEventos[nX, nPosMat]
				oItems["name"] 			:= Alltrim(EncodeUTF8(aEventos[nX, nPosNome]))
				oItems["occurrence"]	:= "absence"
				oItems["date"]    		:= FwTimeStamp(6, STOD( aEventos[nX, nPosData] ), "12:00:00")
				oItems["amountHours"]	:= aEventos[nX, nPosAbsence]
				aAdd( aData, oItems )
			EndIf
			If aEventos[nX, nPosOverT] > 0 
				oItems                  := JsonObject():New()
				oItems["id"]            := aEventos[nX, nPosFil] +"|"+ aEventos[nX, nPosMat] +"|"+ aEventos[nX, nPosEmp] +"|"+ cValToChar(nX)
				oItems["branch"]		:= aEventos[nX, nPosFil]
				oItems["registration"]	:= aEventos[nX, nPosMat]
				oItems["name"] 			:= Alltrim(EncodeUTF8(aEventos[nX, nPosNome]))
				oItems["occurrence"]	:= fMrhTypeHe(aEventos[nX, nPosTpHe])
				oItems["date"]    		:= FwTimeStamp(6, STOD( aEventos[nX, nPosData] ), "12:00:00")
				oItems["amountHours"]	:= aEventos[nX, nPosOverT]
				aAdd( aData, oItems )
			EndIf			
		Next nX

	EndIf

	oItems              := JsonObject():New()
	oItems["hasNext"] 	:= lNextPage
	oItems["items"]		:= aData

	cJson := oItems:ToJson()
	::SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// - RETORNA O TOTALIZADOR DE ATRASOS E FALTAS DOS FUNCIONARIOS DO TIME
// -------------------------------------------------------------------
WSMETHOD GET TotSumDelaysAbsences WSREST Team

	Local oItems        := JsonObject():New()
	Local cRoutine		:= "W_PWSA290.APW" //Menu - Consulta Listagem de marcacoes 
	Local cOrgCFG		:= SuperGetMv("MV_ORGCFG",NIL,"0")
	LocaL aVision       := {}
	LocaL aEmpresas     := {}
	LocaL aDataLogin    := {}
	LocaL aCoordTeam    := {}
	LocaL aEventos    	:= {}
	Local aFiltroApi	:= {}
	Local cCodRD0       := ""	
	Local cMatSRA       := ""
	Local cBranchVld    := ""
	Local cToken        := ""
	Local cKeyId        := ""
	Local cVision       := ""	
	Local aQryParam		:= Self:aQueryString
	
	Local nPos			:= 0
	LocaL nX        	:= 0
	Local nAbsences		:= 0
	Local nDelays		:= 0
	Local nOverT		:= 0
	LocaL nPosDelay 	:= 6
	LocaL nPosAbsence 	:= 7
	Local nPosOverT		:= 8
	LocaL lNextPage		:= .F.
	Local lContinua     := .T.

	Self:SetContentType("application/json")
	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken		:= Self:GetHeader('Authorization')
	cKeyId		:= Self:GetHeader('keyId')

	aDataLogin	:= GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA		:= aDataLogin[1]
		cCodRD0		:= aDataLogin[3]
		cBranchVld	:= aDataLogin[5]
	EndIf

	aVision := GetVisionAI8(cRoutine, cBranchVld)
	cVision := aVision[1][1]

	// Filtro na APIGETSTRUCTURE.
	If ( nPos := aScan(aQryParam, { |x| x[1] == "NAME" } ) ) > 0
        aAdd(aFiltroApi, { aQryParam[nPos,1],aQryParam[nPos,2]})
    EndIf

	//Quando utiliza SIGORG carrega a relacao de empresas abrangidas pelo funcionario dentro da visao
	If cOrgCFG == "2"
		aEmpresas := {}
		fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T.)
	EndIf

	cMRrhKeyTree	:= fMHRKeyTree(cBranchVld, cMatSRA)
	aCoordTeam		:= APIGetStructure(cCodRD0, cOrgCFG, cVision, cBranchVld, cMatSRA, , , , , cBranchVld, cMatSRA, , , , , .T., aEmpresas, aFiltroApi)
	lContinua 		:= Len(aCoordTeam) > 0 .And. !ValType( aCoordTeam[1] ) == "L" //Verifica se carregou dados da hierarquia.

	If lContinua

		aEventos := fGetdelaysAbsences( cBranchVld, cMatSRA, .T., aCoordTeam, aQryParam, @lNextPage )

		For nX := 1 To Len(aEventos)
			nDelays += If( aEventos[nX, nPosDelay] > 0, aEventos[nX, nPosDelay], 0 )
			nAbsences += If( aEventos[nX, nPosAbsence] > 0, aEventos[nX, nPosAbsence], 0 )
			nOverT += If( aEventos[nX, nPosOverT] > 0, aEventos[nX, nPosOverT], 0 )
		Next nX

		oItems["qtyHourDelay"]  := nDelays
		oItems["qtyAbsence"] 	:= nAbsences
		oItems["qtyExtraHour"] 	:= nOverT

	EndIf

	cJson := oItems:ToJson()
	::SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// - RETORNA OS TIPOS DE AFASTAMENTOS
// -------------------------------------------------------------------
WSMETHOD GET ReasonsWorkLeave PATHPARAM employeeId WSREST Team

	Local oItem			:= JsonObject():New()
	Local oReason		:= Nil
	Local aData			:= {}
	Local aItens		:= {}
	Local nX	 		:= 0
	Local nRegs			:= 0
	Local cToken	 	:= ""
	Local cKeyId	 	:= ""	
	Local cMatSRA		:= ""
	Local cBranchVld	:= ""

	Self:SetContentType("application/json")
	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  := Self:GetHeader('Authorization')
	cKeyId	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA      := aDataLogin[1]
		cBranchVld   := aDataLogin[5]
	EndIf

	If !Empty(cMatSRA) .Or. Empty(cBranchVld)

		aData := fAbsenseTypes(cBranchVld)
		nRegs := Len(aData)

		If nRegs > 0
			For nX := 1 To nRegs
			 	oReason				:= JsonObject():New()
				oReason["id"]		:= aData[nX, 2]
				oReason["name"]		:= EncodeUTF8(aData[nX, 3])
				oReason["type"]		:= "day"
				aAdd( aItens, oReason )
			Next nX
		EndIf
	EndIf

	oItem["items"] 	  := aItens
	oItem["hasNext"]  := .F.

	cJson := oItem:ToJson()
	Self:SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// - RETORNA OS AFASTAMENTOS DO FUNCIONARIO
// -------------------------------------------------------------------
WSMETHOD GET WorkLeave PATHPARAM employeeId WSREST Team

	Local oItem			:= JsonObject():New()
	Local oReason		:= Nil
	Local aData			:= {}
	Local aItens		:= {}
	Local aParam		:= {cTod("//"), cTod("//"), ""}
	Local aQryParam		:= Self:aQueryString
	Local nX	 		:= 0
	Local nAfast		:= 0
	Local nRegCount		:= 0
	Local nRegIniCount	:= 0 
	Local nRegFimCount	:= 0
	Local cToken	 	:= ""
	Local cKeyId	 	:= ""
	Local cLogin	 	:= ""
	Local cRD0Cod	 	:= ""	
	Local cMatSRA		:= ""
	Local cBranchVld	:= ""
	Local cPage			:= "1"
	Local cPageSize		:= "10"
	Local lHabil		:= .F.
	Local lDemit		:= .F.
	Local lNextPage		:= .F.

	Private dDtRobot	:= CTOD("//")

	Self:SetContentType("application/json")
	Self:SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken  := Self:GetHeader('Authorization')
	cKeyId	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken, .T., cKeyId)
	If Len(aDataLogin) > 0
		cMatSRA		:= aDataLogin[1]
		cBranchVld	:= aDataLogin[5]
		cLogin		:= aDataLogin[2]
		cRD0Cod		:= aDataLogin[3]
		lDemit		:= aDataLogin[6]
	EndIf

	If !Empty(cMatSRA) .Or. Empty(cBranchVld)

		//Valida o Permissionamento
		fPermission(cBranchVld, cLogin, cRD0Cod, "workLeave", @lHabil)
		If !lHabil .Or. lDemit
			SetRestFault(400, EncodeUTF8( STR0051 )) //"Permissão negada aos serviços de afastamentos!"
			Return (.F.)  
		EndIf	

		For nX := 1 To Len(aQryParam)
			DO Case
				CASE UPPER(aQryParam[nX,1]) == "INITDATE"
					aParam[1] := CTOD( Format8601(.T.,aQryParam[nX,2],.T.) )
				CASE UPPER(aQryParam[nX,1]) == "ENDDATE"
					aParam[2] := CTOD( Format8601(.T.,aQryParam[nX,2],.T.) )
				CASE UPPER(aQryParam[nX,1]) == "REASON"
					aParam[3] := UPPER(AllTrim(aQryParam[nX,2]))
				CASE UPPER(aQryParam[nX,1]) $ "PAGE"
					cPage := UPPER(AllTrim(aQryParam[nX,2]))
				CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
					cPageSize := UPPER(AllTrim(aQryParam[nX,2]))
				CASE UPPER(aQryParam[nX,1]) == "DDATEROBOT"
					dDtRobot := STOD(aQryParam[nX,2])
			ENDCASE
		Next nX

		aData  := fGetAbsenses(cBranchVld, cMatSRA, , aParam)
		nAfast := Len(aData)

		If !Empty(aData)
			
			//controle de paginacao
			If !Empty(cPage) .And. !Empty(cPageSize)
				If cPage == "1" .Or. cPage == ""
					nRegIniCount := 1 
					nRegFimCount := If( Empty( Val(cPageSize) ), 10, Val(cPageSize) )
				Else
					nRegIniCount := ( Val(cPageSize) * ( Val(cPage) - 1 ) ) + 1
					nRegFimCount := ( nRegIniCount + Val(cPageSize) ) - 1
				EndIf
				lCount := .T.
			EndIf		
			
			For nX := 1 To nAfast
				nRegCount ++

				If (nRegCount >= nRegIniCount) .And. nRegCount <= nRegFimCount
					oType				:= JsonObject():New()
					oType["id"]			:= aData[nX, 5]
					oType["name"]		:= EncodeUTF8(aData[nX, 7])
					oType["type"]		:= "day"

					oReason				:= JsonObject():New()
					oReason["canAlter"]	:= .F.
					oReason["id"]		:= aData[nX, 1] 
					oReason["initDate"]	:= formatGMT( DTOS(aData[nX,2]), .T. )
					oReason["endDate"]	:= formatGMT( DTOS(aData[nX,3]), .T. )
					oReason["days"]		:= aData[nX, 4]
					oReason["reason"]	:= oType
					
					aAdd( aItens, oReason )
				Else
					If nRegCount >= nRegFimCount
						lNextPage := .T.
						Exit
					EndIf				
				EndIf
			Next nX
		EndIf
	EndIf

	oItem["items"] 	  := aItens
	oItem["hasNext"]  := lNextPage

	cJson := oItem:ToJson()
	Self:SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// - ATUALIZAÇÃO DO SERVIÇO DE AUSENCIAS.
// -------------------------------------------------------------------
WSMETHOD PUT putAbsence WSREST Team
	Local cBody 		:= ::GetContent()
	Local aUrlParam		:= ::aUrlParms
	Local cJsonObj		:= "JsonObject():New()"
	Local oItem			:= JsonObject():New()
	Local oItemDetail	:= JsonObject():New()
	Local lRet			:= .T.
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cMsg			:= ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken  := Self:GetHeader('Authorization')
	cKeyId	:= Self:GetHeader('keyId')

	EditRH3(aUrlParam,cBody,@cJsonObj,@oItem,@oItemDetail,cToken,,@cMsg,cKeyId)

	If Empty(cMsg)
		cJson := oItem:ToJson()
		::SetResponse(cJson)
	Else
		lRet  := .F.
		SetRestFault(400, cMsg, .T.)
	EndIf

Return (lRet)


// -------------------------------------------------------------------
// - ATUALIZAÇÃO DO SERVIÇO DE SUBSTITUTOS.
// -------------------------------------------------------------------
WSMETHOD PUT putSubstitute WSREST Team
	Local cBody          := ::GetContent()
	Local aUrlParam      := ::aUrlParms
	Local oItem          := JsonObject():New()
	Local oItemDetail    := JsonObject():New()
	Local oItemData      := JsonObject():New()
	Local oMsgReturn     := JsonObject():New()
	Local aMessages      := {}
	Local aDataLogin	 := {}
	Local lRet           := .T.
	Local cJson          := ""
	Local cToken         := ""
	Local cKeyId         := ""

	Local cCodMat        := ""
	Local cBranchVld     := ""
	Local cRestFault     := ""
	Local cStatus        := ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken 		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)

	If Len(aDataLogin) > 0
		cCodMat		:= aDataLogin[1]
		cBranchVld	:= aDataLogin[5]
	EndIf	

	If !Empty(cBody) .And. AliasInDic("RJ2")
		oItemDetail:FromJson(cBody)
		cKeyId := Iif(oItemDetail:hasProperty("id"),oItemDetail["id"],"")

		BEGIN TRANSACTION
			//Localiza e elimina substituicao original
			//O id para a alteração não vai na URL como no delete
			//entao é necessário passar a informação recebida
			cRestFault := subsDelete(aUrlParam,cKeyId)

			//Realiza a gravação da nova substituição
			//caso a exclusão tenha sido realizada com sucesso
			If empty(cRestFault)
				SubsRequest(cBranchVld, cCodMat, cBody, @oItem, @cStatus, @lRet)
			EndIF
		END TRANSACTION
	Else
		cRestFault := EncodeUTF8(STR0016) //"requisição invalida ao serviço de exclusão de substituição"
	EndIf

	If empty(cRestFault) .And. lRet
		If !Empty(cStatus)
			::SetHeader('Status', cStatus)
		EndIf

		oMsgReturn["type"]       := "success"
		oMsgReturn["code"]       := "200"
		oMsgReturn["detail"]     := EncodeUTF8(STR0018) //"Atualização realizada com sucesso"

		Aadd(aMessages, oMsgReturn)
	Else
		HttpSetStatus(400)

		oMsgReturn["type"]       := "error"
		oMsgReturn["code"]       := "400"
		oMsgReturn["detail"]     := cRestFault
		Aadd(aMessages, oMsgReturn)
	EndIf

	oItem["data"]     := oItemData
	oItem["messages"] := aMessages
	oItem["length"]   := 1

	cJson :=  oItem:ToJson()
	::SetResponse(cJson)

Return(.T.)

// -------------------------------------------------------------------
// INCLUI O SUBSTITUTO
// -------------------------------------------------------------------
WSMETHOD POST WSRECEIVE WsNull WSSERVICE Team

	Local cBody 		:= ::GetContent()
	Local oItem			:= JsonObject():New()
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cCodMat	 	:= ""
	Local cBranchVld 	:= ""
	Local cStatus		:= ""
	Local lRet			:= .T.
	Local aDataLogin	:= {}

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken 		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)

	If Len(aDataLogin) > 0
		cCodMat		:= aDataLogin[1]
		cBranchVld	:= aDataLogin[5]
	EndIf

	SubsRequest(cBranchVld, cCodMat, cBody, @oItem, @cStatus, @lRet)

	If lRet
		If !Empty(cStatus)
			::SetHeader('Status', cStatus)
		EndIf

		cJson := oItem:ToJson()
		::SetResponse(cJson)
	EndIf

	FreeObj(oItem)

Return (lRet)

// -------------------------------------------------------------------
// INCLUI A REQUISICAO DE DESLIGAMENTO
// -------------------------------------------------------------------
WSMETHOD POST Demission WSRECEIVE employeeId WSSERVICE Team

	Local oItem			:= JsonObject():New()
	Local cBody 		:= Self:GetContent()
	Local cJson			:= ""
	Local cToken		:= ""
	Local cKeyId		:= ""
	Local cCodMat	 	:= ""
	Local cBranchVld 	:= ""
	Local cFilSolic 	:= ""
	Local cMatSolic 	:= ""
	Local cEmpSolic		:= ""
	Local cRD0Cod		:= ""
	Local cVision	 	:= ""
	Local cTpDemiss	 	:= ""
	Local cFileType		:= ""
	Local cFileContent	:= ""	
	Local lNewHire		:= .F.
	Local lAttachment	:= .F.
	Local cMsg			:= ""
	Local cTypeReq		:= "6" 				//Desligamento
	Local cRoutine		:= "W_PWSA130.APW" 	//Desligamento
	Local cOrgCFG		:= SuperGetMv("MV_ORGCFG", NIL, "0")

	Local cEmpApr		:= ""
	Local cFilApr		:= ""
	Local cApprover		:= ""
	Local nSupLevel		:= 0
	Local aIdFunc		:= {}
	Local aDataLogin	:= {}
	Local lRet			:= .F.

	oRequest				:= WSClassNew("TRequest")
	oRequest:RequestType	:= WSClassNew("TRequestType")
	oRequest:Status			:= WSClassNew("TRequestStatus")
	oTerminationRequest		:= WSClassNew("TTermination")

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	If !Empty( cBody )

		oItem:FromJson(cBody)

		cId 		:= If( oItem:hasProperty("id"), oItem["id"], "" )
		cTpDemiss 	:= If( oItem:hasProperty("demissionType"), AllTrim(oItem["demissionType"]["id"]), "" )
		lNewHire  	:= If( oItem:hasProperty("newHire"), oItem["newHire"], .F. )
		cJustify  	:= If( oItem:hasProperty("demissionJustify"), AllTrim(oItem["demissionJustify"]), "" )
		lAttachment := If( oItem:hasProperty("hasAttachment") .And. oItem["hasAttachment"] == .T., .T., .F. )

		If !Empty( cJustify ) .And. ( Len(cJustify) > 50 .Or. Len(cJustify) < 3 )
			SetRestFault(400, EncodeUTF8( STR0058 )) //"A justificativa deve ter no mínimo 3 e no máximo 50 caracteres!"
			Return(.F.)
		EndIf

		If ( ValType(cId) == "C" .And. "|" $ cId )
			aIdFunc := STRTOKARR( cId, "|" )
			If Len(aIdFunc) > 0
				cFilSolic	:= aIdFunc[1]
				cMatSolic	:= aIdFunc[2]
				cEmpSolic	:= aIdFunc[3]
			EndIf
		Else
			cMsg := EncodeUTF8( STR0044 ) //Os dados do colaborador estão incorretos. Clique no ícone de busca para localizar as informações corretas.
		EndIf

		If !Empty( cFilSolic ) .And. !Empty( cMatSolic )

			cToken 		:= Self:GetHeader('Authorization')
			cKeyId 		:= Self:GetHeader('keyId')
			aDataLogin	:= GetDataLogin(cToken,,cKeyId)

			If Len(aDataLogin) > 0
				cCodMat		:= aDataLogin[1]
				cBranchVld	:= aDataLogin[5]
				cRD0Cod		:= aDataLogin[3]
			EndIf

			If !Empty( cBranchVld ) .And. !Empty( cCodMat )

				aVision 	:= GetVisionAI8(cRoutine, cBranchVld)
				cVision 	:= aVision[1][1]

				// -------------------------------------------------------------------------------------------
				// - Efetua a busca dos dados referentes a Estrutura Oreganizacional dos dados da solicitação.
				//- -------------------------------------------------------------------------------------------
				cMRrhKeyTree:= fMHRKeyTree(cBranchVld, cCodMat)
				aGetStruct := APIGetStructure( cRD0Cod, cOrgCFG, cVision, cBranchVld, cCodMat, , , ,cTypeReq , cBranchVld, cCodMat, , , , , .T., {cEmpAnt},NIL,NIL,.T.)

				If Len(aGetStruct) >= 1 .And. !(Len(aGetStruct) == 3 .And. !aGetStruct[1])
					cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
					cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
					nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
					cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
				EndIf

				If lAttachment
					If !ValType( oItem["file"] ) == "U"
						cFileType	:= oItem["file"]["type"]
						cFileContent:= oItem["file"]["content"]
					EndIf

					//Validação dos formatos do arquivo anexo.
					If (Empty(cFileContent) .Or. (Empty(cFileType) .Or. !cFileType $ ("jpg||jpeg||pdf||png||JPG||JPEG||PDF||PNG")) )
						SetRestFault(400, EncodeUTF8(STR0056)) //"Anexo inválido. Selecione um arquivo de imagem do tipo JPG, PNG ou PDF."
						Return(.F.)
					EndIf
				EndIf				

				//Dados do cabecalho da requisicao
				oRequest:Branch 				:= cFilSolic
				oRequest:Registration			:= cMatSolic
				oRequest:ApproverBranch			:= cFilApr
				oRequest:ApproverRegistration 	:= cApprover
				oRequest:EmpresaAPR				:= cEmpApr
				oRequest:Empresa				:= cEmpSolic
				oRequest:StarterBranch			:= cBranchVld
				oRequest:StarterRegistration	:= cCodMat
				oRequest:ApproverLevel		    := nSupLevel
				oRequest:Vision					:= cVision
				oRequest:Observation			:= DecodeUTF8(cJustify)

				//Dados dos itens da requisicao
				oTerminationRequest:Type		:= cTpDemiss	//Tipo de desligamento
				oTerminationRequest:NewHire		:= If( lNewHire, STR0029, STR0030 ) //Gera Nova Contratação - "Sim"#"Não"
				oTerminationRequest:Observation := DecodeUTF8(cJustify)
				oTerminationRequest:FileType	:= cFileType
				oTerminationRequest:FileContent	:= cFileContent

				AddTerminationRequest( oRequest, oTerminationRequest, STR0032, .T., @cMsg ) //"MEURH"
			Else
				cMsg := EncodeUTF8(STR0031) //"Não foi possível obter as credenciais de acesso para processar essa requisição."
			EndIf

		EndIf

		If ( lRet := Empty(cMsg) )
			cJson := oItem:ToJson()
			Self:SetResponse(cJson)
		Else
			SetRestFault(400, cMsg)
		EndIf

	EndIf

Return( lRet )

// -------------------------------------------------------------------
// - DELETE RESPONSÁVEL POR EXCLUIR AS SUBSTITUIÇÕES RECEBIDAS.
// -------------------------------------------------------------------
WSMETHOD DELETE delSubstitute WSREST Team
	Local aUrlParam      := Self:aUrlParms
	Local oItem          := JsonObject():New()
	Local oItemData      := JsonObject():New()
	Local oMsgReturn     := JsonObject():New()
	Local aMessages      := {}
	Local aDataLogin     := {}

	Local cRestFault     := ""
	Local cBranchVld     := ""
	Local cCodMat        := ""
	Local cToken         := ""
	Local cKeyId         := ""
	Local cJson          := ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")
	cToken 		:= Self:GetHeader('Authorization')
	cKeyId 		:= Self:GetHeader('keyId')
	aDataLogin	:= GetDataLogin(cToken,,cKeyId)

	If Len(aDataLogin) > 0
		cCodMat		:= aDataLogin[1]
		cBranchVld	:= aDataLogin[5]
	EndIf

	Begin Transaction
		//realiza a exclusão dos registros da substituicao
		cRestFault := subsDelete(aUrlParam)
	End Transaction

	If empty(cRestFault)
		HttpSetStatus(204)

		oMsgReturn["type"]       := "success"
		oMsgReturn["code"]       := "204"
		oMsgReturn["detail"]     := EncodeUTF8(STR0015) //"Exclusão realizada com sucesso"

		Aadd(aMessages, oMsgReturn)
	Else
		HttpSetStatus(400)

		oMsgReturn["type"]       := "error"
		oMsgReturn["code"]       := "400"
		oMsgReturn["detail"]     := cRestFault
		Aadd(aMessages, oMsgReturn)
	EndIf

	oItem["data"]     := oItemData
	oItem["messages"] := aMessages
	oItem["length"]   := 1

	cJson :=  oItem:ToJson()
	::SetResponse(cJson)

Return(.T.)

/*/{Protheus.doc} SubsRequest
- Responsavel por efetuar a gravacao do substituto

@author:	Marcelo Silveira
@since:	25/02/2018
@param:	cBranchVld - Filial do substituicao;
			cCodMat - Matricula do substituicao;
			cBody - Corpo da requisicao;
			oItem - Objeto da Classe JsonObjects ( return of service ) /*/
Function SubsRequest(cBranchVld, cCodMat, cBody, oItem, cStatus, lRet)

	Local nTamFilial	 := FwSizeFilial()
	Local cSubstitute    := ""
	Local cFilSubstitute := ""
	Local cMatSubstitute := ""
	Local cPosition      := ""
	Local aFuncs         := {}
	Local aSubstitute    := {}
	Local aDeptos        := {}
	Local oFuncs         := {}
	Local aAreaSRA       := {}
	Local oItemDetail    := JsonObject():New()
	Local oMessages      := JsonObject():New()
	Local nX             := 0
	Local lAdd           := .T.

	Default cBody        := ""
	Default oItem        := JsonObject():New()
	Default lRet         := .T.

	If !Empty(cBody) .And. AliasInDic("RJ2")
		oItemDetail:FromJson(cBody)

		cInitDate     := Iif(oItemDetail:hasProperty("initDate"),CTOD(Format8601(.T.,oItemDetail["initDate"])),"")
		cEndDate      := Iif(oItemDetail:hasProperty("endDate"),CTOD(Format8601(.T.,oItemDetail["endDate"])),"")
		cSubstitute   := Iif(oItemDetail:hasProperty("employeeSummary"),oItemDetail["employeeSummary"]["id"]," ")
		cName         := Iif(oItemDetail:hasProperty("employeeSummary"),oItemDetail["employeeSummary"]["name"]," ")
		cPosition     := Iif(oItemDetail:hasProperty("employeeSummary"),oItemDetail["employeeSummary"]["roleDescription"]," ")
		aDeptos       := Iif(oItemDetail:hasProperty("divisions"),oItemDetail["divisions"],{})

		aSubstitute   := StrTokArr(cSubstitute, "|")

		If Len(aSubstitute) > 1
			cFilSubstitute:= aSubstitute[1]
			cMatSubstitute:= aSubstitute[2]
			aAreaSRA      := SRA->( getArea() )

			DbSelectArea("SRA")
			SRA->( dbSetOrder(1) )
			If SRA->( dbSeek(cFilSubstitute + cMatSubstitute) )
				cCodDepto := SRA->RA_DEPTO
			EndIf
			RestArea(aAreaSRA)

			//Verifica se o registro pode ser gravado
			DbSelectArea("RJ2")
			RJ2->( dbSetOrder(1) )
			RJ2->( dbSeek( cBranchVld + cCodMat ) )
			While !Eof() .And. RJ2->(RJ2_FILIAL+RJ2_MAT) == cBranchVld+cCodMat

				//Se algum dos registros ja existir na base aborta a gravacao de todos.
				If RJ2->RJ2_DEPTO == cCodDepto .And. ;
						( (DTOS(cInitDate) <= DTOS(RJ2_DATADE) .And. DTOS(cEndDate) >= DTOS(RJ2_DATATE) ) .Or. ;
						(DTOS(cInitDate) >= DTOS(RJ2_DATADE) .And. DTOS(cEndDate) <= DTOS(RJ2_DATATE) ) .Or. ;
						(DTOS(cInitDate) <= DTOS(RJ2_DATATE) .And. DTOS(cEndDate) >= DTOS(RJ2_DATATE) ) .Or. ;
						(DTOS(cInitDate) >= DTOS(RJ2_DATATE) .And. DTOS(cEndDate) <= DTOS(RJ2_DATATE) ) )
					lAdd := .F.
					Exit
				EndIf
				RJ2->( dBSkip() )
			EndDo

			//Faz a gravavao do substituto
			If lAdd
				For nX := 1 To Len( aDeptos )
					Reclock("RJ2", .T.)
					RJ2->RJ2_FILIAL   := cBranchVld
					RJ2->RJ2_MAT      := cCodMat
					RJ2->RJ2_DEPTO    := SubStr(aDeptos[nX], nTamFilial + 1 , Len(aDeptos[nX]) )
					RJ2->RJ2_FILSUB   := cFilSubstitute
					RJ2->RJ2_MATSUB   := cMatSubstitute
					RJ2->RJ2_DATADE   := cInitDate
					RJ2->RJ2_DATATE   := cEndDate
					RJ2->(MsUnlock())
				Next nX

				If Empty(aFuncs)
					oFuncs                    := JsonObject():New()
					oFuncs["Id"]              := cFilSubstitute + cMatSubstitute
					oFuncs["name"]            := cName
					oFuncs["roleDescription"] := cPosition
					aAdd( aFuncs, oFuncs )
				EndIf
			EndIf

			If !Empty(aFuncs)
				oItem["employeeSummary"] := aFuncs
			Else
				lRet := .F.
				//"Ja existe substituto cadastrado para esse funcionario no periodo informado."
				SetRestFault(400, EncodeUTF8(STR0007), .T.)
			EndIf

			FreeObj(oItemDetail)
			FreeObj(oMessages)
		EndIf

	EndIf

Return (.T.)


/*/{Protheus.doc} SubsDelete
- Responsavel por efetuar a exclusão de substituicoes
@author:   Marcelo Faria
@since:    23/04/2019
@param:    aUrlParam - parametros da url
/*/
Function subsDelete(aUrlParam,idSubs)
	Local cRestFault := ""
	Local cKeyRJ2    := ""
	Local aParam     := {}

	default idSubs   := ""


	If !Empty(aUrlParam[1]) .And. aUrlParam[1] == "substitute"

		If Len(aUrlParam) == 3 .And. aUrlParam[3] != "undefined"
			//origem requisição DELETE
			aParam := StrTokArr(aUrlParam[3], "&")
		Else
			//origem requisição PUT
			aParam := StrTokArr(idSubs, "&")
		EndIf

		If len(aParam) == 6
			//valida matricula do solicitante
			DbSelectArea("SRA")
			SRA->( dbSetOrder(1) )
			If SRA->( dbSeek(aParam[1]+aParam[2]) )
				cRestFault := ""
			Else
				cRestFault := EncodeUTF8(STR0014) //"informações do solicitante para exclusão não conferem"
			EndIf
		Else
			cRestFault := EncodeUTF8(STR0017) //"dados incompletos para o serviço de exclusão de substituição"
		EndIf
	Else
		cRestFault    := EncodeUTF8(STR0016) //"requisição invalida ao serviço de exclusão de substituição"
	EndIf


	If empty(cRestFault) .And. AliasInDic("RJ2") .And. len(aParam) == 6
		cKeyRJ2 := aParam[1]+aParam[2]+aParam[3]+aParam[4]+aParam[5]+aParam[6]

		//realiza a exclusão do registro de substituição
		Begin Transaction
			DbSelectArea("RJ2")
			RJ2->( dbSetOrder(4) ) //RJ2_FILIAL+RJ2_MAT+DTOS(RJ2_DATADE)+DTOS(RJ2_DATATE)+RJ2_FILSUB+RJ2_MATSUB
			RJ2->( dbSeek(cKeyRJ2) )
			While !Eof()                                                                               .And.  ;
					RJ2->(RJ2_FILIAL+RJ2_MAT+DTOS(RJ2_DATADE)+DTOS(RJ2_DATATE)+RJ2_FILSUB+RJ2_MATSUB) == cKeyRJ2;

				RecLock("RJ2",.F.)
				RJ2->(dbDelete())
				RJ2->(MsUnlock())

				RJ2->( dBSkip() )
			EndDo
		End Transaction
	Else
		If empty(cRestFault)
			cRestFault := EncodeUTF8(STR0017) //"dados incompletos para o serviço de exclusão de substituição"
		EndIf
	EndIf

Return (cRestFault)


/*/{Protheus.doc} fGetSubstitute
- Responsavel por listar as substituicoes agendadas/correntes

@author:	Maycon Sacht
@since:		04/03/2019
@param:		cBranchVld - Filial da hierquia que esta sendo pesquisada;
			cMatSRA - Matrícula da hierquia que está sendo pesquisada;
			initDate - Parametro da requisicao para filtrar registro pela data final
			oItem - Objeto da Classe JsonObjects ( return of service );
			lRet - Se verdadeiro indica que foram carregados dados de funcionarios ou departamentos
/*/
Function fGetSubstitute( cBranchVld, cMatSRA, cInitDate, oItem, lRet)

	Local oSubstitute    := JsonObject():New()
	Local oFuncs         := JsonObject():New()
	Local aSubstitute    := {}
	Local cQuery         := GetNextAlias()
	Local cQuerySra      := GetNextAlias()
	Local aArea          := GetArea() // current area
	Local aAreaSRA       := SRA->(GetArea())
	Local cBranch        := ""
	Local cFiltro        := ""
	Local cJoinSRJ       := ""
	Local dCurrentDate   := Date()
	Local cMatSub        := ""
	Local cDataDe        := ""
	Local cDataAte       := ""
	Local aDeps          := {}
	Local aFuncs         := {}
	Local lNomeSoc       := SuperGetMv("MV_NOMESOC", NIL, .F.)

	DEFAULT cBranchVld   := ""
	DEFAULT cMatSRA      := ""
	DEFAULT oItem        := {}
	DEFAULT lRet         := .T.
	DEFAULT cInitDate    := ""

	cBranch := xFilial("RJ2", cBranchVld)

	If !Empty(cInitDate)
		cFiltro := " RJ2.RJ2_DATATE >= '" + cInitDate + "' "
	Else
		cFiltro := " RJ2.RJ2_DATATE >= '" + DTOS(dCurrentDate) + "' "
	EndIf
	cFiltro := "% " + cFiltro + " %"

	BEGINSQL ALIAS cQuery
		SELECT
			RJ2.RJ2_FILIAL,
			RJ2.RJ2_MAT,
			RJ2.RJ2_MATSUB,
			RJ2.RJ2_FILSUB,
			RJ2.RJ2_DEPTO,
			RJ2.RJ2_DATADE,
			RJ2.RJ2_DATATE
		FROM %Table:RJ2% RJ2
		WHERE RJ2.RJ2_FILIAL = %Exp:cBranch%
			AND RJ2.RJ2_MAT	    = %Exp:cMatSRA%
			AND %exp:cFiltro%
			AND RJ2.%NotDel%
		ORDER BY RJ2_MATSUB, RJ2_DATADE
	ENDSQL

	While (cQuery)->(!Eof())

		If cMatSub != (cQuery)->RJ2_MATSUB .Or. cDataDe != (cQuery)->RJ2_DATADE .Or. cDataAte != (cQuery)->RJ2_DATATE

			If (!Empty(cMatSub))
				oSubstitute["divisions"]     := aDeps
				oSubstitute["divisionsType"] := "departament"
				aDeps := {}
				aAdd(aSubstitute, oSubstitute)
				oSubstitute	:= JsonObject():New()
			EndIf

			cMatSub  := (cQuery)->RJ2_MATSUB
			cDataDe  := (cQuery)->RJ2_DATADE
			cDataAte := (cQuery)->RJ2_DATATE

			cJoinSRJ := "% SRA.RA_CODFUNC = SRJ.RJ_FUNCAO AND " + fMHRTableJoin("SRA", "SRJ") + "%"

			BEGINSQL ALIAS cQuerySra
			SELECT
				SRA.RA_NOME,
				SRA.RA_CODFUNC,
				SRA.RA_NSOCIAL,
				SRJ.RJ_DESC
			FROM %Table:SRA% SRA
			INNER JOIN %Table:SRJ% SRJ
				ON %exp:cJoinSRJ%			 
			WHERE SRA.RA_FILIAL = %Exp:(cQuery)->RJ2_FILSUB%
				AND SRA.RA_MAT = %Exp:(cQuery)->RJ2_MATSUB%
				AND SRA.%NotDel%
				AND SRJ.%NotDel%
			ENDSQL

			oFuncs := JsonObject():New()
			oFuncs["id"]					:= (cQuery)->RJ2_FILIAL +"|" +(cQuery)->RJ2_MAT
			oFuncs["name"]					:= Alltrim(EncodeUTF8(If(lNomeSoc .And. !Empty((cQuerySra)->RA_NSOCIAL), (cQuerySra)->RA_NSOCIAL, (cQuerySra)->RA_NOME)))
			oFuncs["roleDescription"]		:= Alltrim(EncodeUTF8((cQuerySra)->RJ_DESC))

			oSubstitute["id"]				:= 	(cQuery)->RJ2_FILIAL +"&"+ (cQuery)->RJ2_MAT +"&"+ ;
												(cQuery)->RJ2_DATADE +"&" +(cQuery)->RJ2_DATATE +"&"+ ;
												(cQuery)->RJ2_FILSUB +"&" +(cQuery)->RJ2_MATSUB +"&"
			oSubstitute["initDate"]			:= Substr((cQuery)->RJ2_DATADE,1,4) + "-" + Substr((cQuery)->RJ2_DATADE,5,2) + "-" + Substr((cQuery)->RJ2_DATADE,7,2)
			oSubstitute["endDate"]			:= Substr((cQuery)->RJ2_DATATE,1,4) + "-" + Substr((cQuery)->RJ2_DATATE,5,2) + "-" + Substr((cQuery)->RJ2_DATATE,7,2)
			oSubstitute["employeeSummary"]	:= oFuncs

			aFuncs := {}
			(cQuerySra)->( DBCloseArea() )

			aAdd(aDeps, (cQuery)->RJ2_DEPTO)
		Else
			aAdd(aDeps, (cQuery)->RJ2_DEPTO)
		EndIf
		(cQuery)->( DbSkip())
	EndDo

	If (!Empty(cMatSub))
		oSubstitute["divisions"]     := aDeps
		oSubstitute["divisionsType"] := "departament"
		aDeps := {}
		aAdd(aSubstitute, oSubstitute)
	EndIf

	(cQuery)->( DBCloseArea() )

	lRet := !Empty(aSubstitute)
	oItem := aSubstitute

	FreeObj(oSubstitute)

	RestArea(aAreaSRA)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} fGetSubsEligible
- Responsavel por listar os departamentos e os funcionarios que podem ser substituidos

@author:	Marcelo Silveira
@since:		25/02/2018
@param:		aGetStruct - Array com os dados da hierquia;
			cBranchVld - Filial da hierquia que esta sendo pesquisada;
			cMatSRA - Matricula da hierquia que esta sendo pesquisada;
			oItem - Objeto da Classe JsonObjects ( return of service );
			lRet - Se verdadeiro indica que foram carregados dados de funcionarios ou departamentos
/*/
Function fGetSubsEligible( cBranchVld, cMatSRA, aGetStruct, oItem, lRet, aQryParam, lMorePages, cOrgCFG )

	Local oFuncs        := NIL
	Local cNameFun      := ""
	Local cEmpStruct	:= ""
	Local cFilStruct    := ""
	Local cMatStruct    := ""
	Local cDepStruct    := ""
	Local cFilGest		:= "" // Filial do Gestor do Funcionário logado para carregar os pares do funcionário logado
	Local cMatGest		:= "" // Matrícula do Gestor do Funcionário logado para carregar os pares do funcionário logado
	Local cNameGestor	:= "" // Nome do Gestor do funcionário logado.
	Local cFuncGest		:= "" // Função do Gestor do funcionário logado.
	Local cFilLead		:= "" // Verifica se traz gestor caso filtro esteja preenchido
	Local nX            := 0
	Local nPage			:= 0
	Local aFuncs        := {}
	Local aGetGestor	:= {}
	Local lMore			:= .F.
	Local lNomeSoc      := SuperGetMv("MV_NOMESOC", NIL, .F.)

	DEFAULT cOrgCFG     := "0"
	DEFAULT cBranchVld  := ""
	DEFAULT cMatSRA     := ""
	DEFAULT aGetStruct  := {}
	DEFAULT oItem       := {}
	DEFAULT aQryParam   := {}
	DEFAULT lRet        := .T.
	DEFAULT lMorePages  := .F.

	//Retorna os Funcionarios da hieraquia
	For nX := 1 To Len( aGetStruct[1]:ListOfEmployee )
		cEmpStruct 	:= aGetStruct[1]:ListOfEmployee[nX]:EmployeeEmp 
		cFilStruct  := aGetStruct[1]:ListOfEmployee[nX]:EmployeeFilial
		cMatStruct 	:= aGetStruct[1]:ListOfEmployee[nX]:Registration
		cDepStruct	:= AllTrim(aGetStruct[1]:ListOfEmployee[nX]:Department)
		cNameFun 	:= UPPER( AllTrim( EncodeUTF8(If(lNomeSoc .And. !Empty(aGetStruct[1]:ListOfEmployee[nX]:SocialName), aGetStruct[1]:ListOfEmployee[nX]:SocialName, aGetStruct[1]:ListOfEmployee[nX]:Name))))

		If !(cEmpStruct+cFilStruct+cMatStruct == cEmpAnt+cBranchVld+cMatSRA)
			oFuncs			:= JsonObject():New()
			oFuncs["id"] 	:= cFilStruct +"|"+ cMatStruct
			oFuncs["name"]	:= cNameFun
			oFuncs["roleDescription"] := AllTrim( EncodeUTF8(aGetStruct[1]:ListOfEmployee[nX]:FunctionDesc) )
			aAdd( aFuncs, oFuncs )
		EndIf
	Next nX	

	If cOrgCFG == "0"

		cFilGest 	:= aGetStruct[1]:ListOfEmployee[1]:SupFilial
		cMatGest 	:= aGetStruct[1]:ListOfEmployee[1]:SupRegistration

		If ( nPos := aScan( aQryParam, { |x| Upper( x[1] ) == "PAGE" } ) ) > 0
			nPage:= Val( aQryParam[nPos,2] )
		EndIf
		
		If ( nPos := aScan( aQryParam, { |x| Upper( x[1] ) == "USERNAME" } ) ) > 0
			cFilLead := aQryParam[nPos,2]
		EndIf
	
		If !Empty(cFilGest) .And. !Empty(cMatGest) .And. Empty(cFilLead)

			If nPage == 1
				cFuncGest  := Alltrim(;
						EncodeUTF8( ;
						FDesc("SRJ", fSraVal(cFilGest,cMatGest,"RA_CODFUNC"), "RJ_DESC",,cFilGest ) ) )
				cNameGestor := UPPER( ;
						AllTrim( ;
						EncodeUTF8(;
						If(lNomeSoc .And. !Empty(aGetStruct[1]:ListOfEmployee[1]:SocialNameSup), ;
						aGetStruct[1]:ListOfEmployee[1]:SocialNameSup, ;
						aGetStruct[1]:ListOfEmployee[1]:NameSup))))

				oFuncs := JsonObject():New()
				oFuncs["id"] 	:= cFilGest +"|"+ cMatGest
				oFuncs["name"]	:= cNameGestor
				oFuncs["roleDescription"] := cFuncGest
				aAdd( aFuncs, oFuncs )
			EndIf

			aGetGestor := APIGetStructure( "", cOrgCFG, , cFilGest, cMatGest, , , , , cFilGest, cMatGest, , , , , .T., { cEmpAnt }, aQryParam, @lMore)

			//Retorna os Funcionarios da hieraquia
			For nX := 1 To Len( aGetGestor[1]:ListOfEmployee )
				cEmpStruct 	:= aGetGestor[1]:ListOfEmployee[nX]:EmployeeEmp 
				cFilStruct  := aGetGestor[1]:ListOfEmployee[nX]:EmployeeFilial
				cMatStruct 	:= aGetGestor[1]:ListOfEmployee[nX]:Registration
				cDepStruct	:= AllTrim(aGetGestor[1]:ListOfEmployee[nX]:Department)
				cNameFun 	:= UPPER( ;
							   AllTrim( ;
							   EncodeUTF8(;
							   If(lNomeSoc .And. !Empty(aGetGestor[1]:ListOfEmployee[nX]:SocialName), ;
							   aGetGestor[1]:ListOfEmployee[nX]:SocialName, ;
							   aGetGestor[1]:ListOfEmployee[nX]:Name))))

				If !(cEmpStruct+cFilStruct+cMatStruct == cEmpAnt+cBranchVld+cMatSRA) .And. ;
					!(cEmpStruct+cFilStruct+cMatStruct == cEmpAnt+cFilGest+cMatGest) 
					oFuncs			:= JsonObject():New()
					oFuncs["id"] 	:= cFilStruct +"|"+ cMatStruct
					oFuncs["name"]	:= cNameFun
					oFuncs["roleDescription"] := AllTrim( EncodeUTF8(aGetGestor[1]:ListOfEmployee[nX]:FunctionDesc) )
					aAdd( aFuncs, oFuncs )
				EndIf
			Next nX
		EndIf
	EndIf

	lMorePages := ( lMore .Or. lMorePages )

	ASORT( aFuncs, , , { |x,y| x["id"] < y["id"] .And. x["name"] < y["name"] } )

	lRet := !Empty(aFuncs)
	oItem := aFuncs

	FreeObj(oFuncs)

Return(Nil)


/*/{Protheus.doc}EditRH3
- Responsavel por efetuar o PUT (Approve or Repprove das solicitacoes)

@author:	Matheus Bizutti
@since:		12/04/2017
@param:		aUrlParam - Parametros da URL;
			cBody - Corpo da requisicao;
			cJsonObj - Objeto da classe JsonObjects;
			oItem - Objeto da Classe JsonObjects ( return of service );
			oItemDetail - Objeto da Classe JsonObjects para ser utilizado como Array de Objetos no oItem.
			cMsg - Mensagens de validacao da rotina
/*/
Function EditRH3(aUrlParam,cBody,cJsonObj,oItem,oItemDetail,cToken,lApproverAll,cMsg,cKeyId)

	Local oMessages     := Nil
	Local oRequest      := Nil
	Local aMessages     := {}
	Local cBranch       := ""
	Local cMat          := ""
	Local cEmp			:= ""
	Local cFilToken     := ""
	Local cMatToken     := ""
	Local cRH3Cod       := ""
	Local cApprover     := ""
	Local cVision       := ""
	Local cTypeReq      := ""
	Local cEmpApr       := ""
	Local cDtIniFer		:= ""
	Local cDtFimFer		:= ""
	Local cDtBsIni		:= ""
	Local cDtBsFim		:= ""
	Local nSupLevel     := 0
	Local nX     		:= 0
	Local nCpos			:= 0
	Local nDiasFer		:= 0
	Local nDiasAbono	:= 0
	Local aAreaRH3      := {}
	Local aGetStruct    := {}
	Local aSubstitute	:= {}
	Local aDataLogin	:= {}
	Local aInfoReq		:= {}
	Local aCposRH4		:= {}	
	Local aDadosSRH		:= {}
	Local aPerFerias	:= {}
	Local cSubMat		:= ""
	Local cSubBranch 	:= ""
	Local cUsrCurrent   := ""
	Local cFilApr       := ""
	Local lSubstitute   := .F.
	Local lContinua   	:= .T.
	Local lSolic13		:= .F.
	Local lAprove		:= .T.
	Local cOrgCFG		:= SuperGetMv("MV_ORGCFG", NIL, "0")

	Default aUrlParam 	 := {}
	Default cBody        := ""
	Default cJsonObj     := JsonObject():New()
	Default oItem 	 	 := JsonObject():New()
	Default oItemDetail	 := JsonObject():New()
	Default cToken		 := ""
	Default lApproverAll := .F.
	Default cMsg		 := ""
	Default cKeyId		 := ""	

	oMessages            := JsonObject():New()
	oRequest             := WSClassNew("TRequest")
	oRequest:Status      := WSClassNew("TRequestStatus")
	oRequest:RequestType := WSClassNew("TRequestType")

	aDataLogin	:= GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cFilToken 	:= aDataLogin[5]
		cMatToken 	:= aDataLogin[1]
		cUsrCurrent := aDataLogin[1]
	EndIf

	oItemDetail:FromJson(cBody)
	lAprove     := If(oItemDetail:hasProperty("approved"), oItemDetail["approved"], .F.)

	If !empty( oItemDetail["id"] )

		aInfoReq := STRTOKARR(oItemDetail["id"], "|")
		If Len(aInfoReq) > 3
			cBranch := aInfoReq[1]
			cMat	:= aInfoReq[2]
			cRH3Cod := aInfoReq[4]
		EndIf

		aAreaRH3 := RH3->(GetArea())

		DbSelectArea("RH3")
		RH3->( dbSetOrder(1) )

		If RH3->( dbSeek(xFilial("RH3", cBranch) + cRH3Cod ) )

			//Somente se for aprovação.
			If lAprove
				//Em caso de férias, valida SRF/SRH antes de realizar a aprovação.
				If (RH3->RH3_TIPO == "B")
					aCposRH4 := fGetRH4Cpos(cBranch, cRH3Cod)
					If Len(aCposRH4) > 0
						For nCpos := 1 To Len(aCposRH4)
							If aCposRH4[nCpos,1] == "R8_DATAINI"
								cDtIniFer := aCposRH4[nCpos,2]
							ElseIf aCposRH4[nCpos,1] == "R8_DATAFIM"
								cDtFimFer := aCposRH4[nCpos,2]
							ElseIf aCposRH4[nCpos,1] == "R8_DURACAO"
								nDiasFer := Val(aCposRH4[nCpos,2])
							ElseIf aCposRH4[nCpos,1] == "TMP_ABONO"
								nDiasAbono := Val(aCposRH4[nCpos,2])
							ElseIf aCposRH4[nCpos,1] == "TMP_1P13SL"
								lSolic13 := &(aCposRH4[nCpos,2])
							ElseIf aCposRH4[nCpos,1] == "RF_DATABAS"
								cDtBsIni := aCposRH4[nCpos,2]
							ElseIf aCposRH4[nCpos,1] == "RF_DATAFIM"
								cDtBsFim := aCposRH4[nCpos,2]
							EndIf 
						Next nCpos

						//Ferias que foram solicitadas pelo Portal GCH não possuem os dados do período aquisitivo.
						If Empty(cDtBsIni) .And. Empty(cDtBsFim)
							GetDtBasFer(cBranch, cMat, @aPerFerias, RH3->RH3_EMP)
							If Len(aPerFerias) > 0
								cDtBsIni := DTOC(aPerFerias[1,1])
								cDtBsFim := DTOC(aPerFerias[1,2])
							EndIf
						EndIf

						If !Empty( cMsg := fVldSRF(cBranch, cMat, cDtIniFer, nDiasFer, nDiasAbono, lSolic13, cDtBsIni, RH3->RH3_EMP) )
							lContinua := .F.
							cMsg := EncodeUTF8(cMsg)
						EndIf
						If lContinua
							aDadosSRH := fGetSRH( cBranch, cMat, CTOD(cDtBsIni), CTOD(cDtBsFim), RH3->RH3_EMP)
							If !Empty(cMsg := fVldSRH(cBranch, cMat, cDtIniFer, cDtFimFer, nDiasFer, nDiasAbono, aDadosSRH, cDtBsIni, cDtBsFim) )
								lContinua := .F.
								cMsg := EncodeUTF8(cMsg)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			If lContinua
				cVision  := RH3->RH3_VISAO
				cTypeReq := RH3->RH3_TIPO
				cEmp	 := RH3->RH3_EMP

				//Verifica se o funcionario esta substituindo o seu superior
				aSubstitute := fGetSupNotify( cFilToken, cMatToken)

				If Len(aSubstitute) > 0
					For nX := 1 To Len(aSubstitute)
						cSubMat	+= aSubstitute[nX, 2]
						cSubBranch += aSubstitute[nX, 1]
						lSubstitute := .T.
					Next nX
				Else
					cSubBranch	:= cFilToken
					cSubMat		:= cMatToken
				EndIf

				// -------------------------------------------------------------------------------------------
				// - Efetua a busca dos dados referentes a Estrutura Oreganizacional dos dados da solicitação.
				//- -------------------------------------------------------------------------------------------
				If lAprove
					cMRrhKeyTree:= fMHRKeyTree(cSubBranch, cSubMat)
					aGetStruct := APIGetStructure("", cOrgCFG, cVision, cSubBranch, cSubMat, , , ,cTypeReq , cSubBranch, cSubMat, , , , , .T., {cEmpAnt})
					//varinfo("aGetStruct: ",aGetStruct)

					//If Len(aGetStruct) >= 1 .And. !(Len(aGetStruct) == 3 .And. !aGetStruct[1])
					If (valtype(aGetStruct[1]:ListOfEmployee[1]:LevelSup) == "N") .and. (aGetStruct[1]:ListOfEmployee[1]:LevelSup != 99)
						cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
						cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
						nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
						cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
					Else
						nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
					EndIf
					//Verifica se o aprovador eh o usuario corrente. Se positivo o APRROVER deve ficar "''"
					cApprover := Iif(cApprover == cUsrCurrent,"",cApprover)
				Else
					cEmpApr		:= cEmpAnt
					cFilApr		:= cFilToken
					cApprover	:= cMatToken
				EndIf

				oRequest:Branch 				:= cBranch
				oRequest:Registration			:= cMat
				oRequest:Code 					:= cRH3Cod
				oRequest:Empresa				:= cEmp

				oRequest:ApproverBranch			:= cFilApr
				oRequest:ApproverRegistration 	:= cApprover
				oRequest:EmpresaAPR				:= cEmpApr
				oRequest:ApproverLevel			:= nSupLevel
				oRequest:RequestType:Code		:= cTypeReq

				//Guarda os dados da aprovacao feita pelo substituto para geracao do historico
				If lSubstitute
					oRequest:ApproverSubBranch		:= cFilToken
					oRequest:ApproverSubRegistration:= cMatToken
				EndIf

				If oItemDetail:hasProperty("approved")

					If lAprove
						If cTypeReq == "B"
							oItemDetail["status"]		:= "approving"
							oItemDetail["statusLabel"]	:= EncodeUTF8(STR0040) //"Em processo de aprovação"
						EndIf
						oRequest:Observation  := Alltrim(EncodeUTF8(STR0011 +Space(1) +dToC(date()) +Space(1) +Time())) //"Aprovado via App MeuRH em"
					Else
						If cTypeReq == "B"
							oItemDetail["status"]		:= "rejected"
							oItemDetail["statusLabel"]	:= EncodeUTF8(STR0041) //"Rejeitado"
							oRequest:Observation  		:= DecodeUTF8(oItemDetail["justify"]) //Justificativa da reprovação

							If Empty(oRequest:Observation)
								cMsg	  := EncodeUTF8(STR0045) //"É obrigatório informar um motivo para a reprovação!"
								lContinua := .F.
							ElseIf Len(oRequest:Observation) > 50
								cMsg	  := EncodeUTF8(STR0046) //"O motivo deve ter no máximo 50 caracteres!"
								lContinua := .F.
							EndIf
						Else
							oRequest:Observation  := Alltrim(EncodeUTF8(STR0012 +Space(1) +dToC(date()) +Space(1) +Time())) //"Reprovado via App MeuRH em"
						EndIf					
					EndIf

					If lContinua
						If lAprove
							ApproveRequest(oRequest, .T.)
						Else
							ReproveRequest(oRequest, .T.)
						EndIf
					EndIf

				EndIf

				oMessages["code"]             := EncodeUTF8(STR0002)               //"Dados atualizados com sucesso."
				oMessages["message"]	      := EncodeUTF8(STR0003 +" 200")       //"Status:"
				oMessages["detailedMessage"]  := EncodeUTF8(STR0004 +" " +cRH3Cod) //"Solicitacao:"
			EndIf
		Else
			oMessages["code"]             := "401"
			oMessages["message"]          := EncodeUTF8(STR0005)               //"Solicitacao nao encontrada."
			oMessages["detailedMessage"]  := EncodeUTF8(STR0004 +" " +cRH3Cod) //"Numero:"
			cMsg	  					  := EncodeUTF8(STR0005)               //"Solicitacao nao encontrada."
		EndIf

		RestArea(aAreaRH3)

		Aadd(aMessages, oMessages)
	EndIf

	If !lApproverAll
		oItem["data"] 	  := oItemDetail
		oItem["length"]   := 0
		oItem["messages"] := aMessages
	Else
		oItem             := oItemDetail
	EndIf

Return(Nil)


/*/{Protheus.doc}setOcurances()
- Set no array aAbsences para alimentar o Json com o mesmo.

@author:	Matheus Bizutti
@since:		12/04/2017
@param:
- initView: QueryString para filtro de data Inicial.
- endView:	QueryString para filtro de data final.
- cJsonObj:	Variável com a classe JsonObject em macro execução.
- oAbsences: Objeto da classe JsonObject.
/*/
Function setOcurances(aQryParam, aData, aCoordTeam, cBranchVld, cMatSRA, lOnlyConf, lMorePages)

	Local nX			:= 0
	Local nPageSize		:= 0

	Default aQryParam   := {}
	Default aData		:= {}
	Default aCoordTeam	:= {}
	Default cBranchVld	:= FwCodFil()
	Default cMatSRA		:= ""
	Default lOnlyConf	:= .F.
	Default lMorePages  := .F.

	//Pode ser trocado por aScan.
	For nX := 1 to Len(aQryParam)
		DO Case
			CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
				nPageSize := Val(aQryParam[nX,2])
			OTHERWISE
				Loop
		ENDCASE
	Next nX

	// - Captura todas as Ocorrências dos funcionarios do time
	If Len(aCoordTeam) >= 1 .And. !(Len(aCoordTeam) == 3 .And. !aCoordTeam[1])		
		If nPageSize == 3
			fProcHomeFer(aCoordTeam, @aData, cBranchVld, cMatSRA, aQryParam)
		else
			fProcGestFer(aCoordTeam, @aData, cBranchVld, cMatSRA, aQryParam, lOnlyConf, @lMorePages)
		EndIf
	EndIf

Return(Nil)


/*/{Protheus.doc} fProcHomeFer
Retorna os dados de férias dos subordinados na Home do gestor
@author: Marcelo Silveira
@since:	13/08/2021
@param:	aCoordTeam - Data para avaliar se é ferias em dobro
        aData - Dados retornados por referencia
        cBranchVld - Filial do gestor
        cMatSRA - Matrícula do gestor
        aFilter - Array com os dados para filtro
        page - Numero da pagina
		pageSize - Numero de registros por pagina
@return: Nil
/*/
Function fProcHomeFer(aCoordTeam, aData, cBranchVld, cMatSRA, aQryParam)

	Local oAbsences	:= NIL
	Local oEmployee	:= NIL
	Local oItemData	:= NIL

	Local nX			:= 0
	Local nY			:= 0
	Local nCount		:= 0

	Local dDtIni		:= cTod("//")
	Local dDtFim		:= cTod("//")

	Local aAbsences		:= {}
	Local aQPDts		:= {}
	Local aDataFunc		:= {}

	Local cEmpStruct	:= ""
	Local cFilStruct	:= ""
	Local cMatStruct	:= ""
	Local cCodStatus	:= "'1','4'"

	Local lNomeSoc      := SuperGetMv("MV_NOMESOC", NIL, .F.)

	Default aQryParam	:= {}
	Default aData   	:= {}
	Default aCoordTeam	:= {}
	Default cBranchVld	:= FwCodFil()
	Default cMatSRA		:= ""

	For nX := 1 to Len(aQryParam)
		DO Case
			CASE UPPER(aQryParam[nX,1]) == "INITVIEW"
				dDtIni := STOD( StrTran( SubStr( aQryParam[nX,2], 1, 10 ), "-" , "" ) )
			CASE UPPER(aQryParam[nX,1]) == "ENDVIEW"
				dDtFim := STOD( StrTran( SubStr( aQryParam[nX,2], 1, 10 ), "-" , "" ) )
			OTHERWISE
				Loop
		ENDCASE
	Next nX

	If !Empty(dDtIni) .And. !Empty(dDtFim)
		Aadd(aQPDts, { dDtIni, dDtFim } )
	EndIf

	// - Captura todas as Ocorrências.
	// - Obtém o período aquisitivo em aberto.
	If Len(aCoordTeam) >= 1 .And. !(Len(aCoordTeam) == 3 .And. !aCoordTeam[1])
		
		For nY := 1 To Len(aCoordTeam[1]:ListOfEmployee)

			If aCoordTeam[1]:ListOfEmployee[nY]:PossuiSolic
		
				cEmpStruct := aCoordTeam[1]:ListOfEmployee[nY]:EmployeeEmp
				cFilStruct := aCoordTeam[1]:ListOfEmployee[nY]:EmployeeFilial
				cMatStruct := aCoordTeam[1]:ListOfEmployee[nY]:Registration		

				If !(cEmpStruct+cFilStruct+cMatStruct == cEmpAnt+cBranchVld+cMatSRA) // - Despreza caso o coordinatorId esteja incluso na estrutura.
					
					aDataFunc  := { ;                              
								UPPER(AllTrim(aCoordTeam[1]:ListOfEmployee[nY]:Name)), ; //Nome
								AllTrim(aCoordTeam[1]:ListOfEmployee[nY]:Department), ;  //Departamento
								AllTrim(aCoordTeam[1]:ListOfEmployee[nY]:FunctionId) }   //Funcao	

					cEmpTeam := aCoordTeam[1]:ListOfEmployee[nY]:EmployeeEmp
					cFilTeam := aCoordTeam[1]:ListOfEmployee[nY]:EmployeeFilial
					cMatTeam := aCoordTeam[1]:ListOfEmployee[nY]:Registration

					//busca ocorrencias do colaborador
					aOcurances := {}
					GetVacationWKF(@aOcurances, cMatSRA, cBranchVld, cMatTeam, cFilTeam, cEmpTeam, cCodStatus, aDataFunc, aQPDts)

					For nX := 1 To Len(aOcurances)
						nCount ++					
						If nCount <= 3
							SetJson(@oAbsences,@aAbsences,@aOcurances,@nX)
							oEmployee 			            := JsonObject():New()
							oEmployee["id"] 				:= cFilTeam +"|"+ cMatTeam + "|" + cEmpTeam
							oEmployee["name"] 				:= EncodeUTF8(Alltrim(If(lNomeSoc .And. !Empty(aCoordTeam[1]:ListOfEmployee[nY]:SocialName), aCoordTeam[1]:ListOfEmployee[nY]:SocialName, aCoordTeam[1]:ListOfEmployee[nY]:Name)))
							oEmployee["roleDescription"] 	:= EncodeUTF8(Alltrim(aCoordTeam[1]:ListOfEmployee[nY]:FunctionDesc))

							oItemData := JsonObject():New()
							oItemData["employee"] := oEmployee
							oItemData["absences"] := aAbsences

							// - aData - Array que irá ser responsável por todo o corpo do JSON
							aAdd(aData, oItemData)
							aAbsences := {}
						else
							Return
						EndIf
					Next nX
				EndIf
			EndIf
		Next nY

	EndIf

Return(Nil)

/*/{Protheus.doc} fProcGestFer
Retorna os dados de férias dos subordinados na Gestão de Férias
@author: Marcelo Silveira
@since:	13/08/2021
@param:	aCoordTeam - Data para avaliar se é ferias em dobro
        aData - Dados retornados por referencia
        cBranchVld - Filial do gestor
        cMatSRA - Matrícula do gestor
        aQryParam - Array com os dados para filtro
        lOnlyConf - Indica se retornara apenas os conflitos de ferias
@return: Nil
/*/
Function fProcGestFer(aCoordTeam, aData, cBranchVld, cMatSRA, aQryParam, lOnlyConf, lMorePages)

	Local oAbsences		:= NIL
	Local oItemData		:= NIL
	Local oEmployee		:= NIL

	Local nX			:= 0
	Local nY			:= 0
	Local nDays			:= 0
	Local nMonthAdv		:= 0
	Local nPage			:= 1
	Local nPageSize		:= 10
	Local nRegCount		:= 0
	Local nRegCountIni	:= 1
	Local nRegCountFim	:= 10
	Local lNomeSoc      := SuperGetMv("MV_NOMESOC", NIL, .F.)

	Local aAbsences		:= {}
	Local aDataFunc		:= {}
	Local aConflict		:= {}
	Local aQPDts		:= {}

	Local lMostra		:= .T.
	Local lAllRegs		:= .F.

	Local cCondition	:= ""
	Local cInitView		:= ""
	Local cEndView		:= ""
	Local cDescStatus   := ""
	Local cCodStatus    := "'1','4'"
	Local cEmpStruct	:= ""
	Local cFilStruct	:= ""
	Local cMatStruct	:= ""
	Local cNome         := ""
	Local cId           := ""

	Default aData		:= {}
	Default aCoordTeam	:= {}
	Default aMessages	:= {}
	Default cBranchVld	:= FwCodFil()
	Default cMatSRA		:= ""
	Default lOnlyConf   := .F.
	Default lMorePages  := .F.

	For nX := 1 to Len(aQryParam)
		DO Case
			CASE UPPER(aQryParam[nX,1]) == "INITVIEW"
				cInitView = aQryParam[nX,2]
				lAllRegs := .T.
			CASE UPPER(aQryParam[nX,1]) == "ENDVIEW"
				cEndView := aQryParam[nX,2]
				lAllRegs := .T.
			CASE UPPER(aQryParam[nX,1]) == "STATUS"
				cCodStatus := getWKFByDesc(aQryParam[nX,2])
				cDescStatus := AllTrim(aQryParam[nX,2])
				lAllRegs := .T.
			CASE UPPER(aQryParam[nX,1]) == "PAGESIZE"
				nPageSize := Val(aQryParam[nX,2])
			CASE UPPER(aQryParam[nX,1]) == "PAGE"
				nPage := Val(aQryParam[nX,2])
			CASE UPPER(aQryParam[nX,1]) == "CONDITION"
				cCondition := getValueByQP(AllTrim(aQryParam[nX,2]), 0 )
				cCondition := StrTran(cCondition,"'","") //remove aspas simples
				lAllRegs := .T.
			CASE UPPER(aQryParam[nX,1]) == "MONTHINADVANCE"
				nMonthAdv := ( Val(aQryParam[nX,2]) * 30 ) // Risco de vencimento calculado meses x 30 dias.
				lAllRegs := .T.
			OTHERWISE
				Loop
		ENDCASE
	Next nX

	If !lOnlyConf 
		If !Empty(cInitView) .And. !Empty(cEndView)
			aAdd(aQPDts, { STOD( StrTran( SubStr( cInitView, 1, 10 ), "-" , "" ) ), ;
						STOD( StrTran( SubStr( cEndView, 1, 10 ), "-" , "" ) ) } )
		EndIf
	EndIf

	// - Captura todas as Ocorrências dos funcionarios do time
	If Len(aCoordTeam) >= 1 .And. !(Len(aCoordTeam) == 3 .And. !aCoordTeam[1])

		// Se a quantidade de colaboradores retornada pela ApiGetStructure for menor que o tamanho da página.
		// Então não limita a paginação a 10 registros, mas exibe os registros de todos os colaboradores.
		lAllRegs := Iif(  ( Len(aCoordTeam[1]:ListOfEmployee) - 1 ) <= nPageSize, .F., .T. )

		//Se for passar todos os registros, faz controle de paginação, pois não foi feito na ApiGetStructure.
		If lAllRegs
			lMorePages := .F.
			If nPage == 1
				nRegCountIni := 1
				nRegCountFim := nPageSize
			Else
				nRegCountIni := ( nPageSize * ( nPage - 1)  ) + 1
				nRegCountFim := nRegCountIni + ( nPageSize - 1 )
			EndIf
		EndIf
		
		For nY := 1 To Len(aCoordTeam[1]:ListOfEmployee)

			If cDescStatus == "approving" .And. !aCoordTeam[1]:ListOfEmployee[nY]:PossuiSolic
				Loop
			EndIf

			cEmpStruct := aCoordTeam[1]:ListOfEmployee[nY]:EmployeeEmp
			cFilStruct := aCoordTeam[1]:ListOfEmployee[nY]:EmployeeFilial
			cMatStruct := aCoordTeam[1]:ListOfEmployee[nY]:Registration						

			// - Despreza caso o coordinatorId esteja incluso na estrutura.
			If !(cEmpStruct+cFilStruct+cMatStruct == cEmpAnt+cBranchVld+cMatSRA)

				aDataFunc  := { ;                              
							UPPER(AllTrim(If(lNomeSoc .And. !Empty(aCoordTeam[1]:ListOfEmployee[nY]:SocialName), aCoordTeam[1]:ListOfEmployee[nY]:SocialName, aCoordTeam[1]:ListOfEmployee[nY]:Name))), ; //Nome
							AllTrim(aCoordTeam[1]:ListOfEmployee[nY]:Department), ;  //Departamento
							AllTrim(aCoordTeam[1]:ListOfEmployee[nY]:FunctionId) }   //Funcao

				cEmpTeam := aCoordTeam[1]:ListOfEmployee[nY]:EmployeeEmp
				cFilTeam := aCoordTeam[1]:ListOfEmployee[nY]:EmployeeFilial
				cMatTeam := aCoordTeam[1]:ListOfEmployee[nY]:Registration
				
				// Se fez busca pelos meses de antecência, não faz sentido trazer no filtro quem está em férias
				If nMonthAdv == 0
					GetAbsences(@aOcurances, cMatTeam, cFilTeam, cEmpTeam, aDataFunc, aQPDts)
				EndIf
				GetVacLimit(@aOcurances, cMatTeam, cFilTeam, cEmpTeam, aDataFunc, aQPDts, nMonthAdv)
				GetVacationWKF(@aOcurances, cMatSRA, cBranchVld, cMatTeam, cFilTeam, cEmpTeam, cCodStatus, aDataFunc, aQPDts, nMonthAdv)
			EndIf
		Next nY

		//Verifica os registros para identificar se existe conflito de Ferias
		For nX := 1 To Len( aOcurances )
			If !UPPER(aOcurances[nX, 3]) == "VACATIONLIMIT" .And. !UPPER(aOcurances[nX, 4]) == "CLOSED" .And. fRetPos(aOcurances, nX, 5, 6) > 0
				aAdd( aConflict, ;
					{ 	aOcurances[nX, 2], ;
						If( ValType(aOcurances[nX, 5])=="C", CTOD(aOcurances[nX, 5]), aOcurances[nX, 5] );
					})		
			EndIf
		Next nX
		
		//Percorre os dados apurados para geracao do json final
		For nX := 1 To Len( aOcurances )

			//valida todos os filtros
			If lOnlyConf
				lMostra := .F.
				If aScan( aConflict, { |x| x[1] == aOcurances[nX, 2] } ) > 0
					lMostra := fRetPos( {aOcurances[nX]}, 1, 5, 6, .T., cInitView, cendView) > 0
				EndIf
			Else
				lMostra := .T.
				If !Empty(cDescStatus)
					lMostra := ( aOcurances[nX][4] $ cDescStatus )
				EndIf
				If lMostra .And. !Empty(cCondition)
					lMostra := ( aOcurances[nX][30] $ cCondition )
				EndIf
			EndIf

			//Atualiza registro das movimentações de férias do colaborador
			If lMostra
			
				//Id no formato FIL|MAT|EMP ou FIL|MAT|EMP|REQ, transforma em FIL|MAT|EMP
				//Localiza o segundo "|" e adiciona 2 (tamanho máximo da empresa)
				cId := Substr(aOcurances[nX,2], 1, At('|', aOcurances[nX,2], At('|', aOcurances[nX,2])+1) + 2)

				nPos := aScan( aCoordTeam[1]:ListOfEmployee, {|x| x:EmployeeFilial +"|"+ x:Registration +"|"+ x:EmployeeEmp == cId} )
				If nPos > 0

					nDays    := 0
					cEmpTeam := aCoordTeam[1]:ListOfEmployee[nPos]:EmployeeEmp
					cFilTeam := aCoordTeam[1]:ListOfEmployee[nPos]:EmployeeFilial
					cMatTeam := aCoordTeam[1]:ListOfEmployee[nPos]:Registration

					//Abate do periodo os dias de ferias que foram solicitados e estão em processo de aprovacao
					If UPPER(aOcurances[nX, 3]) == "VACATIONLIMIT"
						Aeval( aOcurances, { |x| nDays += If ( ;
							Substr(x[2], 1, At('|', x[2], At('|', x[2]) + 1) + 2) == cFilTeam+"|"+cMatTeam+"|"+cEmpTeam .And. x[3] == "vacation" .And. ;
							StoD(x[21]) == StoD(aOcurances[nX,21]) .And. !x[4] == "rejected" .And. !Empty(x[15]), ;
							( x[12] + x[7] ), 0) })
						If nDays > 0
							If aOcurances[nX,29] - nDays > 0
								aOcurances[nX,29] -= nDays
							Else
								Loop
							EndIf
						EndIf
					EndIf

					oItemData := JsonObject():New()
					oEmployee := JsonObject():New()

					If lAllRegs
						nRegCount++	
						If ( nRegCount >= nRegCountIni .And. nRegCount <= nRegCountFim )
							cNome := If(lNomeSoc .And. !Empty(aCoordTeam[1]:ListOfEmployee[nPos]:SocialName), aCoordTeam[1]:ListOfEmployee[nPos]:SocialName, aCoordTeam[1]:ListOfEmployee[nPos]:Name)
							oEmployee["id"] 				:= cFilTeam +"|"+ cMatTeam + "|" + cEmpTeam
							oEmployee["name"] 				:= EncodeUTF8(Alltrim(cNome))
							oEmployee["roleDescription"] 	:= EncodeUTF8(Alltrim(aCoordTeam[1]:ListOfEmployee[nPos]:FunctionDesc))
							SetJson(@oAbsences,@aAbsences,@aOcurances,@nX,aConflict)
							
							oItemData["employee"] := oEmployee
							oItemData["absences"] := aAbsences
							// - aData - Array que irá ser responsável por todo o corpo do JSON
							aAdd(aData, oItemData)
						Else
							If nRegCount > nRegCountFim
								lMorePages := .T.
								Exit
							EndIf
						EndIf
					else
						cNome := If(lNomeSoc .And. !Empty(aCoordTeam[1]:ListOfEmployee[nPos]:SocialName), aCoordTeam[1]:ListOfEmployee[nPos]:SocialName, aCoordTeam[1]:ListOfEmployee[nPos]:Name)
						oEmployee["id"] 				:= cFilTeam +"|"+ cMatTeam + "|" + cEmpTeam
						oEmployee["name"] 				:= EncodeUTF8(Alltrim(cNome))
						oEmployee["roleDescription"] 	:= EncodeUTF8(Alltrim(aCoordTeam[1]:ListOfEmployee[nPos]:FunctionDesc))
						SetJson(@oAbsences,@aAbsences,@aOcurances,@nX,aConflict)
						
						oItemData["employee"] := oEmployee
						oItemData["absences"] := aAbsences
						// - aData - Array que irá ser responsável por todo o corpo do JSON
						aAdd(aData, oItemData)
					EndIf
				EndIf
			EndIf
			aAbsences := {}
		Next nX
	EndIf

Return(Nil)


/*/{Protheus.doc}GetAbsences
- Retorna as ausencias do funcionario;

@author: Matheus Bizutti, Marcelo Silveira (nova versao)
@since:	12/04/2017
@param:	
	- aOcurances = Array passado por referência para obter as ausências;
	- cMatTeam = Matricula que sera utilizada como filtro
	- cFilTeam = Filial que sera utilizada como filtro
	- cEmpTeam = Empresa que sera utilizada como filtro 
	- aDataFunc = Dados do funcionario para inclusão em aOcurances
/*/
Function GetAbsences(aOcurances, cMatTeam, cFilTeam, cEmpTeam, aDataFunc, aQPDts)

	Local cQuery 		:= GetNextAlias()
	Local cQryObj		:= ""
	Local aDtsQry		:= {}
	Local nX			:= 0
	Local nVacAbs		:= 0
	Local dDtBaseInfo	:= DaySub( IIf(!Empty(dDtRobot), dDtRobot, dDatabase), 40)
	Local dDtBaseFim	:= DaySum( IIf(!Empty(dDtRobot), dDtRobot, dDatabase), 365)
	Local nDiasDir		:= 0
	Local nFaltas		:= 0
	Local cDtBsIni 		:= ""
	Local cDtBsFim 		:= ""
	Local cFunName		:= "" 
	Local cFunDepto		:= ""
	Local cFunFuncao	:= ""
	Local cCondition	:= ""
	Local cDescStatus	:= ""
	Local aPeriod		:= {}

	Default aOcurances 	:= {}
	Default cMatTeam	:= ""
	Default cFilTeam	:= FwCodFil()
	Default cEmpTeam	:= cEmpAnt
	Default aDataFunc	:= {}
	Default aQPDts		:= {}

	If Len(aDataFunc) > 2
		cFunName	:= aDataFunc[1]
		cFunDepto	:= aDataFunc[2]
		cFunFuncao	:= aDataFunc[3]
	EndIf

	If !Empty(cMatTeam)

		If oStAbsence == Nil .Or. cGetAbsenc <> cEmpTeam
			oStAbsence := FWPreparedStatement():New()
			cQryObj := "SELECT"
			cQryObj += " RA_FILIAL, RA_MAT, RA_SITFOLH, R8_FILIAL, R8_MAT, R8_SEQ, R8_TIPOAFA, R8_DATAINI, R8_DATAFIM, R8_DURACAO, R8_STATUS"
			cQryObj += " FROM " + RetFullName('SRA', cEmpTeam) + " SRA "
			cQryObj += " INNER JOIN " + RetFullName('SR8', cEmpTeam) + " SR8 "
			cQryObj += " ON SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT "
			cQryObj += " WHERE SRA.RA_FILIAL = ? "
			cQryObj += " AND SRA.RA_MAT = ? "
			cQryObj += " AND SRA.RA_SITFOLH NOT IN ('D','T') "
			cQryObj += " AND SR8.R8_TIPOAFA = '001' "
			cQryObj += " AND SR8.R8_DATAINI >= ? "
			cQryObj += " AND SR8.R8_DATAFIM <= ? "
			cQryObj += " AND SRA.D_E_L_E_T_ = ' '"
			cQryObj += " AND SR8.D_E_L_E_T_ = ' '"

			aAdd(aDtsQry, { "R8_DATAINI", "D", 8, 0 } )
			aAdd(aDtsQry, { "R8_DATAFIM", "D", 8, 0 } )

			oStAbsence:SetFields( aDtsQry )

			cQryObj := ChangeQuery(cQryObj)
			oStAbsence:SetQuery(cQryObj)
			cGetAbsenc := cEmpTeam
		EndIf

		//DEFINIÇÃO DOS PARÂMETROS.
		oStAbsence:SetString(1,cFilTeam)
		oStAbsence:SetString(2,cMatTeam)
		If Len(aQPDts) > 0 .And. !Empty(aQPDts[1,1])
			dDtBaseInfo := aQPDts[1,1]
		EndIf
		oStAbsence:SetDate(3,dDtBaseInfo)
		If Len(aQPDts) > 0 .And. !Empty(aQPDts[1,2])
			dDtBaseFim := aQPDts[1,2]
		EndIf
		oStAbsence:SetDate(4,dDtBaseFim)

		//RESTAURA A QUERY COM OS PARÂMETROS INFORMADOS.
		cQryObj := oStAbsence:GetFixQuery()

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryObj),cQuery,.T.,.T.)
		oStAbsence:doTcSetField(cQuery)

		While (cQuery)->(!Eof())

			nDiasDir := 0
			nFaltas  := 0

			//Verifica se existem dias de abono
			aDataSRH  := fGetSRH( (cQuery)->RA_FILIAL, (cQuery)->RA_MAT, , , DTOS((cQuery)->R8_DATAINI), DTOS((cQuery)->R8_DATAFIM), cEmpTeam )
			For nX := 1 to Len(aDataSRH)
				cDtBsIni := aDataSRH[nX][4]
				cDtBsFim := aDataSRH[nX][5]
				nVacAbs  += aDataSRH[nX][6]
				nDiasDir := aDataSRH[nX][9]
				nFaltas  := aDataSRH[nX][11]
			Next nX

			aPeriod 	:= PeriodConcessive(,cDtBsFim)

			//Checa a condição das ferias
			cCondition	:= GetCondition(, , , , .T., (cQuery)->R8_DATAINI, (cQuery)->R8_DATAFIM)
			cDescStatus := StatusVacation((cQuery)->R8_DATAINI,(cQuery)->R8_DATAFIM)

			aAdd(aOcurances, {												;
				(cQuery)->R8_MAT,											;	//01
				(cQuery)->R8_FILIAL +"|"+ (cQuery)->R8_MAT +"|"+ cEmpTeam,	;	//02
				"vacation",													;	//03
				cDescStatus,												;	//04
				(cQuery)->R8_DATAINI,										;	//05
				(cQuery)->R8_DATAFIM,										;	//06
				nVacAbs,													;	//07
				.F.,														;	//08
				{},															;	//09
				getDescs((cQuery)->R8_TIPOAFA,.F.,(cQuery)->R8_FILIAL),		;	//10
				.F.,														;	//11
				(cQuery)->R8_DURACAO,										;	//12
				Nil,														;	//13
				Nil,														;	//14
				"",															;	//15
				Nil,														;	//16
				Nil,														;	//17
				Nil,														;	//18
				Nil,														;	//19
				Nil,														;	//20
				cDtBsIni,													;	//21
				cDtBsFim,													;	//22
				Nil,														;	//23
				Nil,														;	//24
				cFunName,													;	//25
				cFunDepto,													;	//26
				cFunFuncao,													;	//27
				{aPeriod[1], aPeriod[2]},									;	//28
				(cQuery)->R8_DURACAO + nVacAbs,								;	//29
				cCondition,													;	//30
				nDiasDir - nFaltas											;   //31
			})
			(cQuery)->( DbSkip() )
		EndDo
		(cQuery)->( DBCloseArea() )
	EndIf

Return(Nil)


/*/{Protheus.doc}GetVacationWKF
- Retorna a RH3 referentes a Férias.

@author:	Matheus Bizutti
@since:	12/04/2017
@param:	- aOcurances - Array passado por referencia para obter as ausencias;
		- cMatSRA - Matricula que será utilizada como filtro - No while dos funcionarios, As chamadas essa funcao passando a matricula que estao lendo;
		- cBranchVld - Filial utilizada ao logar ( GetCookie() )
		- cMatTeam - Matricula do usuario Logado ( Necessário para futura implementacao)
		- cFilTeam - Filial da matricula que está sendo pesquisada
		- cEmpTeam - Empresa da matricula que está sendo pesquisada
		- cStatus - Status da requisicao para filtro
		- aDataFunc - Dados do funcionario para inclusão em aOcurances
		- aQPDts - Filtro avançado de Datas.
		- nMonthAdv - Filtro avançado de risco de vencimento

/*/
Function GetVacationWKF(aOcurances, cMatSRA, cBranchVld, cMatTeam, cFilTeam, cEmpTeam, cStatus, aDataFunc, aQPDts, nMonthAdv)

Local aArea			:= GetArea()
Local aPerFerias	:= {}
Local nTamFilial	:= FWGETTAMFILIAL
Local cQuery 		:= GetNextAlias()
Local cQryObj		:= ""
Local dDataIni		:= cToD("//")
Local dDataFim		:= cToD("//")
Local dRiskDouble	:= cToD("//")
Local dDouble		:= cToD("//")
Local dDtIni		:= cTod("//")
Local dDtFim		:= cTod("//")
Local dDtMontAdv	:= cTod("//")
Local cDtBsIni  	:= ""
Local cDtBsFim  	:= ""
Local nX			:= 0
Local nVacDays		:= 0
Local nAbsDays      := 0
Local nDiasSRH		:= 0
Local nDFer			:= 0
Local nDAb			:= 0
Local nDiasDir		:= 0
Local nFaltas		:= 0
Local nSubDays		:= 60
Local lSolicAbono   := .F.
Local lSolic13      := .F.
Local lStAprov		:= .F.
Local aDadosSRH		:= {}
Local aStatus		:= {}
Local cCondition	:= ""
Local cFunName		:= "" 
Local cFunDepto		:= ""
Local cFunFuncao	:= ""
Local cFilRH4       := ""
Local cId			:= ""
Local cDescStatus   := ""

Default nMonthAdv   := 0
Default aOcurances	:= {}
Default cBranchVld  := FwCodFil()
Default cMatSRA		:= ""
Default cEmpTeam	:= cEmpAnt
Default cStatus		:= "'1','3','4','5'" //dispensa atendidas (status=2), pois sao carregadas pelo SRF 
Default aDataFunc	:= {}
Default aQPDts      := {}

cStatus := StrTran(cStatus,"'","" )  
aStatus := StrTokArr(cStatus, ",")

dDtMontAdv := Iif( !Empty(dDtRobot), dDtRobot, dDataBase )

If Len(aDataFunc) > 2
	cFunName	:= aDataFunc[1]
	cFunDepto	:= aDataFunc[2]
	cFunFuncao	:= aDataFunc[3]
EndIf

If oStVacWkfl == Nil .Or. cGetVacWKF <> cEmpTeam
	oStVacWkfl := FWPreparedStatement():New()
	cQryObj := "SELECT SRA.RA_FILIAL, SRA.RA_MAT, 
	cQryObj += " RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH3.RH3_MAT, RH3.RH3_DTSOLI, RH3.RH3_VISAO, RH3.RH3_FILINI, RH3.RH3_MATINI, RH3.RH3_EMPINI,
	cQryObj += " RH3.RH3_EMP, RH3.RH3_FILAPR, RH3.RH3_MATAPR, RH3.RH3_STATUS, RH3.RH3_TIPO, RH3.RH3_NVLINI, RH3.RH3_NVLAPR, RH3.R_E_C_N_O_"
	cQryObj += " FROM " + RetFullName('SRA', cEmpTeam) + " SRA "
	cQryObj += " INNER JOIN " + RetFullName('RH3', cEmpTeam) + " RH3 "
	cQryObj += " ON SRA.RA_FILIAL = RH3.RH3_FILIAL AND SRA.RA_MAT = RH3.RH3_MAT"
	cQryObj += " WHERE "
	cQryObj += " RH3.RH3_FILIAL = ?"
	cQryObj += " AND RH3.RH3_MAT = ?"
	cQryObj += " AND RH3.RH3_EMP = ? "
	cQryObj += " AND RH3.RH3_TIPO = 'B'"
	cQryObj += " AND RH3.RH3_STATUS IN (?)"
	cQryObj += " AND RH3.D_E_L_E_T_ = ' '"
	cQryObj += " AND SRA.D_E_L_E_T_ = ' '"

	cQryObj := ChangeQuery(cQryObj)
	oStVacWkfl:SetQuery(cQryObj)
	cGetVacWKF := cEmpTeam
EndIf

//DEFINIÇÃO DOS PARÂMETROS.
oStVacWkfl:SetString(1,cFilTeam)
oStVacWkfl:SetString(2,cMatTeam)
oStVacWkfl:SetString(3,cEmpTeam)
oStVacWkfl:SetIn(4,aStatus)

//RESTAURA A QUERY COM OS PARÂMETROS INFORMADOS.
cQryObj := oStVacWkfl:GetFixQuery()

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryObj),cQuery,.T.,.T.)

If Len(aQPDts) > 0
	dDtIni := aQPDts[1,1]
	dDtFim := aQPDts[1,2]
EndIf

While (cQuery)->(!Eof())

	dDataIni		:= cToD(" / / ")
	dDataFim		:= cToD(" / / ")
	cDtBsIni		:= ""
	cDtBsFim		:= ""
	nVacDays		:= 0
	nAbsDays    	:= 0
	nDiasDir		:= 0
	nFaltas			:= 0
	lSolicAbono		:= .F.
	lSolic13		:= .F.
	cFilRH4			:= ""
	aPerFerias		:= {}

	If RH4->( dbSeek( (cQuery)->RH3_FILIAL + (cQuery)->RH3_CODIGO ))

		While RH4->(!Eof()) .And. RH4->RH4_FILIAL = (cQuery)->RH3_FILIAL .And. RH4->RH4_CODIGO == (cQuery)->RH3_CODIGO

			If alltrim(RH4->RH4_CAMPO)     == "R8_DATAINI"
				dDataIni    := alltrim(RH4->RH4_VALNOV)
			ElseIf alltrim(RH4->RH4_CAMPO) == "R8_DATAFIM"
				dDataFim    := alltrim(RH4->RH4_VALNOV)
			ElseIf alltrim(RH4->RH4_CAMPO) == "R8_DURACAO"
				nVacDays    := Val(alltrim(RH4->RH4_VALNOV))
			ElseIf alltrim(RH4->RH4_CAMPO) == "TMP_ABONO"
				lSolicAbono := &(alltrim(RH4->RH4_VALNOV))
			ElseIf alltrim(RH4->RH4_CAMPO) == "TMP_DABONO"
				nAbsDays    := Val(alltrim(RH4->RH4_VALNOV))
			ElseIf alltrim(RH4->RH4_CAMPO) == "TMP_1P13SL"
				lSolic13    := &(alltrim(RH4->RH4_VALNOV))
			ElseIf alltrim(RH4->RH4_CAMPO) == "R8_FILIAL"
				cFilRH4      := SubStr( RH4->RH4_VALNOV, 1, nTamFilial )
			ElseIf alltrim(RH4->RH4_CAMPO) == "RF_DATABAS"
				cDtBsIni := alltrim(RH4->RH4_VALNOV)
			ElseIf alltrim(RH4->RH4_CAMPO) == "RF_DATAFIM"
				cDtBsFim := alltrim(RH4->RH4_VALNOV)
			EndIf

			RH4->(DbSkip())
		EndDo

	EndIf

	//Caso exista filtro da datas, busca conforme o filtro
	If !Empty(dDtIni) .And. !Empty(dDtFim)
		If !( cTod(dDataIni) >= dDtIni .And. cTod(dDataFim) <= dDtFim )
			(cQuery)->( DbSkip() )
			Loop
		EndIf
	EndIf

	//Obtem dados do periodo aquisitivo
	GetDtBasFer(cFilTeam, cMatTeam, @aPerFerias, (cQuery)->RH3_EMP, cDtBsIni)

	//Ferias que foram solicitadas pelo Portal GCH não possuem os dados do período aquisitivo.
	If Len(aPerFerias) > 0 

		If ( Empty(cDtBsIni) .Or. Empty(cDtBsFim) )
			cDtBsIni := DTOC(aPerFerias[1,1])
			cDtBsFim := DTOC(aPerFerias[1,2])
		EndIf

		nFaltas  := Iif( aPerFerias[1,3] > 0, aPerFerias[1,14], aPerFerias[1,15] )
		nDiasDir := Iif( aPerFerias[1,3] > 0, aPerFerias[1,3], 30 )
		nFaltas  += IIf( aPerFerias[1,3] > 0, 0, fMRhGetFal(cFilTeam, cMatTeam, cEmpTeam) )
		TabFaltas(@nFaltas)
		// Considera falta sempre sobre 30 dias.
		nFaltas := Iif( aPerFerias[1,3] > 0, nFaltas, ( nFaltas / aPerFerias[1,15] ) * 30 )
		
		aPeriod  := PeriodConcessive(, dToS(cTod(cDtBsFim)) )

		aDadosSRH := fGetSRH(cFilTeam, cMatTeam, CTOD(cDtBsIni), CTOD(cDtBsFim))
		If Len(aDadosSRH) > 0
			//Somente adiciona férias na SRH que não estão na programção da SRF.
			For nX := 1 to Len(aDadosSRH)
				If ( aDadosSRH[nX,1] != DTOS(aPerFerias[1,5]) ) .And.;
					( aDadosSRH[nX,1] != DTOS(aPerFerias[1,6]) ) .And.;
					( aDadosSRH[nX,1] != DTOS(aPerFerias[1,7]) )
					nDiasSRH += ( aDadosSRH[nX][2] + aDadosSRH[nX][6] )
				EndIf
			Next nX
		EndIf

		//Saldo de férias para computar o prazo para o gozo
		nDAb		:= ( aPerFerias[1,11] + aPerFerias[1,12] + aPerFerias[1,13] ) 
		nDFer		:= If(aPerFerias[1,3] > 0, Round(aPerFerias[1,3],0), Round(aPerFerias[1,4],0) ) - ;
					( nDiasSRH + ( aPerFerias[1,8] + aPerFerias[1,9] + aPerFerias[1,10] + ; // dias de férias programadas.
					nDAb ) ) //Dias de abono programados.

		dDouble 	:= aPeriod[2] - nDFer + 1 //Dobro => Fim do período concessivo menos o saldo de dias de ferias
		If nMonthAdv > 0
			If ( aPeriod[2] > DaySum(dDtMontAdv , nMonthAdv ) ) .Or. ;
			 	dDouble <= dDtMontAdv .Or. ;		// Não carrega férias vencidas em dobro.
				aPerFerias[1,3] > 0 .Or. ; 			// Não traz férias proporcionais
				!( (cQuery)->RH3_STATUS $ "1/4" )   // Não traz férias que já foram atendidas.
				(cQuery)->( DbSkip() )
				Loop
			EndIf
		EndIf
		dRiskDouble := aPeriod[2] - (nDFer + nSubDays) + 1 //Risco de dobro => Fim do período concessivo menos 60 dias e o saldo de dias de ferias
		cCondition	:= GetCondition(dDouble, dRiskDouble, aPerFerias[1,3], aPerFerias[1,4], NIL, NIL, NIL, dDtMontAdv)
		cDescStatus := getStatusWKF((cQuery)->RH3_STATUS)
	EndIf

	lStAprov := (cQuery)->RH3_STATUS $ "1" .And. ( (cQuery)->RH3_FILAPR + (cQuery)->RH3_MATAPR == cBranchVld + cMatSRA )
	cId		 := (cQuery)->RH3_FILIAL +"|"+ (cQuery)->RH3_MAT +"|"+ (cQuery)->RH3_EMP +"|"+ (cQuery)->RH3_CODIGO

	aAdd(aOcurances, ;
		{ ;
		(cQuery)->RH3_MAT,							;
		cId,										;
		"vacation",									;
		cDescStatus,								;
		Iif(!Empty(dDataIni),dDataIni,Nil),			;
		Iif(!Empty(dDataFim),dDataFim,Nil),			;
		nAbsDays,									;
		.F.,										;
		{(cQuery)->RH3_MATAPR},						;
		Nil,										;
		lStAprov, 									;
		nVacDays,                                   ;
		lSolicAbono,                                ;
		lSolic13,                                   ;
		(cQuery)->RH3_CODIGO,                       ;
		(cQuery)->R_E_C_N_O_,                       ;
		(cQuery)->RH3_STATUS,                       ;
		cFilRH4,                                    ;
		(cQuery)->RH3_NVLINI,                       ;
		(cQuery)->RH3_NVLAPR,                       ;
		dToS(cToD(cDtBsIni)),						;
		dToS(cToD(cDtBsFim)),						;
		(cQuery)->RH3_FILINI,						;
		(cQuery)->RH3_MATINI,						;
		cFunName,									;
		cFunDepto,									;
		cFunFuncao,									;
		{aPeriod[1], aPeriod[2]},					;
		nVacDays + nAbsDays,						;
		cCondition,									;
		nDiasDir - nFaltas,							;
		(cQuery)->RH3_EMPINI })
	(cQuery)->( DbSkip() )
EndDo

(cQuery)->( DBCloseArea() )

RestArea(aArea)

Return(Nil)


/*/{Protheus.doc}getBonus
- Retorna dias de Abono.
@author: 	Matheus Bizutti
@since:		12/04/2017

/*/
Function getBonus(cMat,dDtBase,dDtAte)

	Local cQuery 	:= GetNextAlias()
	Local aArea		:= GetArea() // current area
	Local aAreaSRA	:= SRA->(GetArea())
	Local nQtdAbono	:= 0

	Default cMat 		:= ""
	Default dDtBase	:= CtoD(" / / ")
	Default dDtAte	:= CtoD(" / / ")

	BEGINSQL ALIAS cQuery

	SELECT *
	   	   FROM %table:SRH% SRH
	WHERE SRH.RH_MAT = %Exp:cMat% AND
	      SRH.RH_ROTEIR = 'FER' AND
	      SRH.RH_DABONPE > 0 AND
	   	  SRH.%NotDel%

	ENDSQL

	While (cQuery)->(!Eof())

		nQtdAbono += (cQuery)->RH_DABONPE

		(cQuery)->( DbSkip() )
	EndDo

	(cQuery)->( DBCloseArea() )

	RestArea(aAreaSRA)
	RestArea(aArea)

Return(nQtdAbono)


/*/{Protheus.doc}filterService
- Alimenta o Json de Retorno baseado no filtro utilizado ( TEAMS OR ROLES ) por query param.
@author: 	Matheus Bizutti
@since:		12/04/2017

/*/
Function filterService(id,name,aData,aCoordTeam,cType,cBranchVld,cMatSRA)

	Local nX			:= 0
	Local nY			:= 0
	Local cFilRole		:= ""
	Local cFilTeam		:= ""
	Local oService		:= Nil
	Local aExist		:= {}

	Default id			:= ""
	Default name		:= ""
	Default cType		:= ""
	Default cBranchVld	:= ""
	Default cMatSRA		:= ""
	Default aData		:= {}
	Default aCoordTeam	:= {}

	If Len(aCoordTeam) > 0 .And. !ValType( aCoordTeam[1] ) == "L"

		// - Ordena por departamento.
		ASORT(aCoordTeam[1]:ListOfEmployee,,, { |x, y| x:Department > y:Department } )
		For nX := 1 To Len(aCoordTeam)

			For nY := 1 To Len(aCoordTeam[nX]:ListOfEmployee)

				oService	:= JsonObject():New()

				If cType $ "teams##organizationalsubdivision"

					cFilTeam := xFilial("SQB", aCoordTeam[nX]:ListOfEmployee[nY]:EmployeeFilial)

					If  !Empty(aCoordTeam[nX]:ListOfEmployee[nY]:Department) .And. !( aCoordTeam[nX]:ListOfEmployee[nY]:EmployeeFilial + aCoordTeam[nX]:ListOfEmployee[nY]:Registration == cBranchVld + cMatSRA ) //Tratativa para não carregar o departamento que o funcionário está alocado, porém não é lider.
						If ( aScan( aExist, { |x| x[1] == cFilTeam + Alltrim(aCoordTeam[nX]:ListOfEmployee[nY]:Department) } )) == 0
							oService["id"]   := cFilTeam + Alltrim(aCoordTeam[nX]:ListOfEmployee[nY]:Department)
							oService["name"] := EncodeUTF8(Alltrim(aCoordTeam[nX]:ListOfEmployee[nY]:DescrDepartment))

							Aadd(aExist, {cFilTeam + Alltrim(aCoordTeam[nX]:ListOfEmployee[nY]:Department)} )
							Aadd(aData,oService)
						EndIf
					EndIf

				ElseIf cType == "roles"

					cFilRole := xFilial("SRJ", aCoordTeam[nX]:ListOfEmployee[nY]:EmployeeFilial)

					If ( aScan( aExist, { |x| x[1] == cFilRole + Alltrim(aCoordTeam[nX]:ListOfEmployee[nY]:FunctionId) } )) == 0
						oService["id"]   := cFilRole + Alltrim(aCoordTeam[nX]:ListOfEmployee[nY]:FunctionId)
						oService["name"] := EncodeUTF8(Alltrim(aCoordTeam[nX]:ListOfEmployee[nY]:FunctionDesc))
						
						Aadd(aExist, {cFilRole + Alltrim(aCoordTeam[nX]:ListOfEmployee[nY]:FunctionId)} )
						Aadd(aData,oService)
					EndIf
				EndIf

			Next nY

		Next nX

	EndIf

Return(Nil)

/*/{Protheus.doc}validDate
- Valida as datas de exibicao das ocorrencias.
@author: 	Matheus Bizutti
@since:		12/04/2017

/*/
Static Function validDate(qryStringInit , dtAfastInit ,qryStringEnd, dtAfastEnd )

	Local lRet			:= .T.
	Local cDtInit		:= ""
	Local cDtFinish 	:= ""

	Default qryStringInit 	:= ""
	Default dtAfastInit	  	:= dDataBase
	Default qryStringEnd  	:= ""
	Default dtAfastEnd 	  	:= dDataBase

	If !Empty(qryStringInit) .And. !Empty(qryStringEnd)

		cDtInit 	:= Ctod(Substr(qryStringInit,9,2) + "/" + Substr(qryStringInit,6,2) + "/" + Substr(qryStringInit,1,4))
		cDtFinish	:= Ctod(Substr(qryStringEnd,9,2)  + "/" + Substr(qryStringEnd,6,2)  + "/" + Substr(qryStringEnd,1,4))

		// - A SRF e a SR8 não tem o mesmo padrão para os CAMPOS DATA
		// - Por isso transformamos tudo em DATE para tratamento.
		If ValType(dtAfastInit) == "C" .Or. ValType(dtAfastEnd) == "C"
			dtAfastInit := CTOD(Alltrim(dtAfastInit))
			dtAfastEnd  := CTOD(Alltrim(dtAfastEnd))
		EndIf

		If !(dtAfastInit >= cDtInit .And. dtAfastEnd <= cDtFinish)
			lRet := .F.
		EndIf

	EndIf

Return(lRet)

/*/{Protheus.doc}getDescs
- Retorna a descricao dos arquivos: SRJ e RCM.
@author: 	Matheus Bizutti
@since:		12/04/2017

/*/
Static Function getDescs(cCod,lIsRoleDescription,cBranchVld)

	Local cDesc		:= ""

	Default cCod	:= ""
	Default lIsRoleDescription := .F.
	Default cBranchVld := FwCodFil()

	cDesc := Iif( lIsRoleDescription, FDesc("SQ3", cCod, "Q3_DESCSUM",,cBranchVld ) , Alltrim(FDesc("RCM", cCod, "RCM_DESCRI",,cBranchVld ) ) )

Return( Alltrim(cDesc) )

/*/{Protheus.doc}getStatusWKF
- De/Para dos Status enviados pelo Front-End ao Rest;
@author: 	Matheus Bizutti
@since:		12/04/2017

/*/
Function getStatusWKF(cStatus)

	Local cDesc 	:= ""
	Default cStatus := ""

/*
- DE/PARA
- STATUS PROTHEUS -> STATUS FRONTEND

"empty": vazio utilizado por período aquisitivo
"approving": em aprovacao (primeiro nivel gestor/coordenador, solicitada, etc)
"approved": em aprovacao DP/RH, aprovado pelo gestor
"rejected": rejeitado
"closed": aprovada pelo RH/DP, marcada, pagas, finalizadas

*/

	DO CASE
	CASE cStatus == "1" .or. cStatus == "4" // Solicitada (em processo de aprovacao) ou Aguardando Efetivacao do RH
		cDesc := "approving"
	CASE cStatus == "2" // Atendida pelo RH
		cDesc := "closed"
	CASE cStatus == "3" // Reprovada
		cDesc := "rejected"
	OTHERWISE
		cDesc := "empty"
	ENDCASE

Return(cDesc)

/*/{Protheus.doc}SetJson
- Funcao IMPORTANTISSIMA* responsavel por efetuar a criacao do JSON baseada nas ocorrencias (Array aOcurances).
@author: 	Matheus Bizutti
@since:		12/04/2017

/*/
Function SetJson(oAbsences,aAbsences,aOcurances,nX,aConflict)

	Local nPos			:= 0
	Local nSaldo		:= 0
	Local lConcessive	:= .F.
	Local aDateGMT		:= {}

	Default aAbsences	:= {}
	Default oAbsences	:= JsonObject():New()
	Default aOcurances	:= {}
	Default nX			:= 0

	oAbsences  			:= JsonObject():New()

	If !Empty(aOcurances)

		lConcessive	:= UPPER(aOcurances[nX][3]) == "VACATIONLIMIT" .Or. UPPER(aOcurances[nX][30]) == "VACATIONSTOEXPIRE"

		// - Adiciona as ausencias
		// - definidas pelos seus tipos (enum) do FrontEnd
		oAbsences["id"] 				:= aOcurances[nX][2]
		oAbsences["type"] 				:= aOcurances[nX][3]
		oAbsences["status"]				:= aOcurances[nX][4]
		oAbsences["balance"]			:= aOcurances[nX][29]

		If aOcurances[nX][3] == "vacation" .And. aOcurances[nX][4] == "approving"
			oAbsences["statusLabel"] := Alltrim( EncodeUTF8(STR0040) ) //"Em processo de aprovação"
		else
			oAbsences["statusLabel"] := Nil
		EndIf

		// - A SRF e a SR8 não tem o mesmo padrão para os CAMPOS DATAINI
		// - Por isso transformamos tudo em DATE para tratamento em FORMATO GTM.
		If !(Valtype(aOcurances[nX][5]) == "U" .And. ValType(aOcurances[nX][6]) == "U")

			aDateGMT := {}
			If ValType(aOcurances[nX][5]) == "C" .Or. ValType(aOcurances[nX][6]) == "C"

				If "/" $ aOcurances[nX][5] .And. "/" $ aOcurances[nX][6]
					aOcurances[nX][5] := Substr(aOcurances[nX][5],7,4) + Substr(aOcurances[nX][5],4,2) + Substr(aOcurances[nX][5],1,2)
					aOcurances[nX][6] := Substr(aOcurances[nX][6],7,4) + Substr(aOcurances[nX][6],4,2) + Substr(aOcurances[nX][6],1,2)
				EndIf

				aOcurances[nX][5] := STOD(aOcurances[nX][5])
				aOcurances[nX][6] := STOD(aOcurances[nX][6])

			EndIf

			aDateGMT := LocalToUTC( DTOS(aOcurances[nX][5]), "12:00:00" )
			oAbsences["initDate"] 			:= Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + aDateGMT[2] + "Z"

			aDateGMT := {}
			aDateGMT := LocalToUTC( DTOS(aOcurances[nX][6]), "12:00:00" )
			oAbsences["endDate"]			:= Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + aDateGMT[2] + "Z"
		EndIf

		oAbsences["vacationBonus"] 			:= aOcurances[nX][7]
		oAbsences["approved"] 				:= aOcurances[nX][8]
		oAbsences["approvers"]				:= aOcurances[nX][9]
		oAbsences["justify"]				:= Iif(aOcurances[nX][10] != Nil, EncodeUTF8(aOcurances[nX][10]), aOcurances[nX][10])
		oAbsences["statusAbbr"]				:= Nil
		oAbsences["canApprove"]				:= aOcurances[nX][11]
		If aOcurances[nX][12] != Nil
			oAbsences["absenceDays"]		:= aOcurances[nX][12]
		EndIf

		oAbsences["hasConflict"] := .F.
		// Verifica ID ( X[1] ) e Data do Conflito ( X[2] )
		// É necessário pois a mesma pessoa pode ter mais de um registro no array aConflict
		If (nPos := aScan( aConflict, ;
						 { |x| x[1] == aOcurances[nX,2] .And.;
						       x[2] == aOcurances[nX,5] } ) ) > 0
			oAbsences["hasConflict"] 	:= .T.
		EndIf

		oAbsences["condition"]				:= aOcurances[nX][30]

		aDateGMT := LocalToUTC( aOcurances[nX][21], "12:00:00" )
		oAbsences["initPeriod"] := Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + aDateGMT[2] + "Z"

		aDateGMT := LocalToUTC( aOcurances[nX][22], "12:00:00" )
		oAbsences["endPeriod"] 	:= Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + aDateGMT[2] + "Z"

		//Exibe a data limite apenas quando tiver solicitação, programacao ou calculo
		If !lConcessive
			nSaldo	 := ( aOcurances[nX][31] - aOcurances[nX][29] )
			nSaldo   := Int(nSaldo)
			aDateGMT := LocalToUTC( DTOS((aOcurances[nX][28][2]) - nSaldo + 1), "12:00:00" )
			oAbsences["takeVacationUntil"] 		:= Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + aDateGMT[2] + "Z"
		EndIf

		//Período concessivo exibe apenas quando não existe solicitacao
		If lConcessive
			aDateGMT := LocalToUTC( DTOS(aOcurances[nX][28][1]), "12:00:00" )
			oAbsences["initConcessionPeriod"] 	:= Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + aDateGMT[2] + "Z"
		
			aDateGMT := LocalToUTC( DTOS(aOcurances[nX][28][2]), "12:00:00" )		
			oAbsences["endConcessionPeriod"] 	:= Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + aDateGMT[2] + "Z"
		EndIf

		//Tratamento não é mais necessário, pois férias rejeitadas já não são mais apresentadas na home do gestor (Meu RH).
		//Apresenta justificativa em caso de rejeição
		//If aOcurances[nX][4]== "rejected" .And. !Empty(aOcurances[nX][15])
		//	oAbsences["justify"] := AllTrim( getRGKJustify(SubStr(aOcurances[nX][2], 1, nSizeFil), aOcurances[nX][15], , .T.))
		//EndIf

		aAdd(aAbsences, oAbsences)
	Else
		// - Lista Vazia
		aAbsences := {}
	EndIf

Return(Nil)


/*/{Protheus.doc} fGetSupNotify
Verifica se o funcionario esta substituindo o seu gestor e retorna uma matriz com seus dados
@author:	Marcelo Silveira
@since:		02/05/2019
@param:		cBranchVld - Filial do funcionario para localizacao de seu gestor;
			cMatSRA - Matricula do funcionario para localizacao de seu gestor;
@return:	aSubstitute - Array com as dados do gestor e departamentos para buscar as notificaoes
/*/
Function fGetSupNotify(cBranchVld, cMatSRA)

	Local cQuery        := ""
	Local cBranch       := ""
	Local aSubstitute	:= {}
	Local lContinua		:= AliasInDic("RJ2")
	Local dCurrentDate  := DtoS( Date() )

	DEFAULT cBranchVld	:= ""
	DEFAULT cMatSRA     := ""

	If lContinua

		cBranch := xFilial("RJ2", cBranchVld)
		cQuery  := GetNextAlias()

		BEGINSQL ALIAS cQuery

		SELECT RJ2.RJ2_FILIAL, RJ2.RJ2_MAT, RJ2.RJ2_MATSUB, RJ2.RJ2_FILSUB, RJ2.RJ2_DEPTO, RJ2.RJ2_DATADE, RJ2.RJ2_DATATE
		FROM %Table:RJ2% RJ2
		WHERE RJ2.RJ2_FILSUB = %Exp:cBranch%
		  AND RJ2.RJ2_MATSUB = %Exp:cMatSRA%
		  AND RJ2.%NotDel%
		ORDER BY RJ2_MATSUB, RJ2_DATADE

		ENDSQL

		//Retornar um array com dados do gestor que esta sendo substituido com seguinte estrutura
		//aSubstitute[1,1] = FILIAL1
		//aSubstitute[1,2] = MATRICULA1
		//aSubstitute[1,3] = 'DEPARTAMENTO1','DEPARTAMENTO2','DEPARTAMENTO3' (Formatado para uso em query)
		While (cQuery)->(!Eof())

			If  ;
					( (dCurrentDate <= (cQuery)->RJ2_DATADE .And. dCurrentDate >= (cQuery)->RJ2_DATATE ) .Or. ;
					(dCurrentDate >= (cQuery)->RJ2_DATADE .And. dCurrentDate <= (cQuery)->RJ2_DATATE ) .Or. ;
					(dCurrentDate <= (cQuery)->RJ2_DATATE .And. dCurrentDate >= (cQuery)->RJ2_DATATE ) .Or. ;
					(dCurrentDate >= (cQuery)->RJ2_DATATE .And. dCurrentDate <= (cQuery)->RJ2_DATATE ) )

				If (nPos := aScan(aSubstitute, {|x| x[1]+x[2] == (cQuery)->RJ2_FILIAL + (cQuery)->RJ2_MAT}) ) == 0
					aAdd( aSubstitute, { ;
							(cQuery)->RJ2_FILIAL, ;
							(cQuery)->RJ2_MAT, ;
							"'" + (cQuery)->RJ2_DEPTO + "',",;
							(cQuery)->RJ2_FILSUB,;
							(cQuery)->RJ2_MATSUB } )
				Else
					aSubstitute[nPos,3] += "'" + (cQuery)->RJ2_DEPTO + "',"
				EndIf
			EndIf

			(cQuery)->( DbSkip())
		EndDo

		(cQuery)->( DBCloseArea() )

	EndIf

Return( aSubstitute )

/*/{Protheus.doc} fEmpBirth
Retorna os funcionários que fazem aniversário no mês vigente.
@author:	Fernando Quinteiro
@since:		16/07/2019
@param:		cBranchVld - Filial;
			cMatSRA - Matricula;
@return:	aListEmpl - Array com funcionários do time que fazem aniversários
/*/
Function fEmpBirth( cBranchVld, cMatSRA, lMorePage, cPage, cPageSize )

	Local cVision
	Local aEmpresas
	Local oEmployee		:= JsonObject():New()
	Local aListEmpl		:= {}
	Local aCoordTeam    := {}
	Local aFuncTeam     := {}
	Local aData			:= {}
	Local aVision		:= {}
	Local aQryParam		:= {}
	Local cMonthAdm		:= StrZero(Month(dDataBase),2)
	Local cOrgCFG		:= SuperGetMv("MV_ORGCFG", NIL, "0")
	Local cRoutine		:= "W_PWSA100A.APW"
	Local cDay			:= ""
	Local cMonth		:= ""
	Local cEmpSup		:= ""
	Local cFilSup		:= ""
	Local cMatSup		:= ""
	Local cId 			:= ""
	Local dDtNasc		:= cTod("//")
	Local nX 			:= 1
	Local lSitFun		:= .F.
	Local lContinua		:= .F.
	Local lGestor		:= .F.
	Local lNomeSoc      := SuperGetMv("MV_NOMESOC", NIL, .F.)

	DEFAULT cPage		:= "1"
	DEFAULT cPageSize	:= "6"
	DEFAULT	lMorePage	:= .F.

	cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)

	If !(cOrgCFG == "0")
		aVision := GetVisionAI8(cRoutine, cBranchVld)
		cVision := aVision[1][1]

		aEmpresas := {}
		fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T.)
	EndIf

	//Verifica sua estrutura para localizar os subordinados
	aAdd(aQryParam, { "PAGE", cPage} )
	aAdd(aQryParam, { "PAGESIZE", cPageSize } )
	aAdd(aQryParam, { "MONTHADM", cMonthAdm})
	aFuncTeam := APIGetStructure("", cOrgCFG, cVision, cBranchVld, cMatSRA, , , , , cBranchVld, cMatSRA, , , , , .T., aEmpresas, aQryParam, @lMorePage)
	lContinua := Len(aFuncTeam) > 0 .And. !ValType( aFuncTeam[1] ) == "L"  //Verifica se carregou dados da hierarquia.
	lGestor	  := ( lContinua .And. Len( aFuncTeam[1]:ListOfEmployee ) > 1 )

	If lContinua

		cEmpSup := aFuncTeam[1]:ListOfEmployee[1]:SupEmpresa
		cFilSup := aFuncTeam[1]:ListOfEmployee[1]:SupFilial
		cMatSup := aFuncTeam[1]:ListOfEmployee[1]:SupRegistration

		If lGestor
			For nX := 1 To Len( aFuncTeam[1]:ListOfEmployee )
				cID := aFuncTeam[1]:ListOfEmployee[nX]:EmployeeFilial +"|"+ aFuncTeam[1]:ListOfEmployee[nX]:Registration +"|"+ aFuncTeam[1]:ListOfEmployee[nX]:EmployeeEmp
				If !(cID == cBranchVld + "|" + cMatSRA + "|" + cEmpAnt )
					dDtNasc := cToD( aFuncTeam[1]:ListOfEmployee[nX]:BirthdayDate )
					cMonth	:= Strzero( Month(dDtNasc),2 )
					lSitFun	:= !(aFuncTeam[1]:ListOfEmployee[nX]:Situacao $ "D|T")
					cDay	:= Strzero( Day(dDtNasc),2 )
					//Não adiciona funcionarios demitidos ou transferidos
					If lSitFun
						aAdd( aListEmpl, ;
							{ ;
							cID, ;
							cValToChar( Year(dDtNasc) ) +"-"+  cMonth +"-"+ cDay + "T" + "12:00:00" + "Z", ;
							If(lNomeSoc .And. !Empty(aFuncTeam[1]:ListOfEmployee[nX]:SocialName), aFuncTeam[1]:ListOfEmployee[nX]:SocialName, aFuncTeam[1]:ListOfEmployee[nX]:Name), ;
							aFuncTeam[1]:ListOfEmployee[nX]:DescrDepartment ;
							})
					EndIf
				EndIf
			Next nX
		EndIf
	EndIf

	//Verifica a estrutura do gestor para localizar os pares da matricula logada
	If !Empty(cFilSup) .And. !Empty(cMatSup) .And. ( Len(aListEmpl) == 0 .Or. Val(cPageSize) <> 6  )

		aEmpresas := {}
		fGetTeamManager(cFilSup, cMatSup, @aEmpresas, cRoutine, cOrgCFG, .T., cEmpSup)

		aCoordTeam	:= APIGetStructure("", cOrgCFG, cVision, cFilSup, cMatSup, , , , , cFilSup, cMatSup, , , , cEmpSup, .T., aEmpresas, aQryParam, @lMorePage)
		lContinua 	:= Len(aCoordTeam) > 0 .And. !ValType( aCoordTeam[1] ) == "L" //Verifica se carregou dados da hierarquia.

		If lContinua
			For nX := 1 To Len( aCoordTeam[1]:ListOfEmployee )
				//Nao considera propria e nem a matricula do gestor
				If  !( aCoordTeam[1]:ListOfEmployee[nX]:EmployeeFilial + ;
				 	  aCoordTeam[1]:ListOfEmployee[nX]:Registration + ;
					  aCoordTeam[1]:ListOfEmployee[nX]:EmployeeEmp == cFilSup + cMatSup + cEmpSup ) .And. ;
					 !( aCoordTeam[1]:ListOfEmployee[nX]:EmployeeFilial + ;
				 	  aCoordTeam[1]:ListOfEmployee[nX]:Registration + ;
					  aCoordTeam[1]:ListOfEmployee[nX]:EmployeeEmp == cBranchVld + cMatSRA + cEmpAnt )

					cID 	:= aCoordTeam[1]:ListOfEmployee[nX]:EmployeeFilial +"|"+ aCoordTeam[1]:ListOfEmployee[nX]:Registration +"|"+ aCoordTeam[1]:ListOfEmployee[nX]:EmployeeEmp
					dDtNasc := cToD( aCoordTeam[1]:ListOfEmployee[nX]:BirthdayDate )
					cMonth	:= Strzero( Month(dDtNasc),2 )
					cDay	:= Strzero( Day(dDtNasc),2 )
					lSitFun	:= !(aCoordTeam[1]:ListOfEmployee[nX]:Situacao $ "D|T")

					//Não adiciona funcionarios demitidos ou transferidos
					If lSitFun
						aAdd( aListEmpl, ;
							{ ;
							cID, ;
							cValToChar( Year(dDtNasc) ) +"-"+  cMonth +"-"+ cDay + "T" + "12:00:00" + "Z", ;
							aCoordTeam[1]:ListOfEmployee[nX]:Name, ;
							aCoordTeam[1]:ListOfEmployee[nX]:DescrDepartment ;
							})
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	If Len( aListEmpl ) > 0

		//Ordena os funcionarios pela data de aniversario e nome
		aSort( aListEmpl,,,{|x,y| x[2]+x[3] < y[2]+y[3] } )

		//Adiciona as matriculas compreendidas na pagina e tamanho solicitados
		For nX := 1 To Len( aListEmpl )
			oEmployee					:= JsonObject():New()
			oEmployee["employeeId"] 	:= aListEmpl[nX,1]
			oEmployee["birthDate"] 		:= EncodeUTF8( aListEmpl[nX,2] )
			oEmployee["employeeName"]	:= EncodeUTF8( aListEmpl[nX,3] )
			oEmployee["department"]		:= EncodeUTF8( aListEmpl[nX,4] )
			aAdd( aData, oEmployee )
		Next nX
	EndIf
Return( aData )

/*/{Protheus.doc} fSupGetPosition
Retorna a descricao da função conforme a Filial e Matricula passados por parametro
@author:	Marcelo Silveira
@since:		02/12/2019
@param:		cBranchVld - Filial;
			cMatSRA - Matricula;
			cEmpMat - Empresa;
@return:	cDescFunc - String com a descricao da função
/*/
Function fSupGetPosition( cBranch, cMat, cEmpMat )

	Local cJoin      := ""
	Local cQuery     := ""
	Local cDescFunc := ""
	Local __cSRAtab  := ""
	Local __cSRJtab  := ""

	DEFAULT cBranch := ""
	DEFAULT cMat	:= ""
	DEFAULT cEmpMat := ""

	If !Empty(cBranch) .And. !Empty(cMat)

		If !Empty(cEmpMat)
			__cSRAtab := "%" + RetFullName("SRA", cEmpMat) + "%"
			__cSRJtab := "%" + RetFullName("SRJ", cEmpMat) + "%"
		Else
			__cSRAtab := "%" + RetSqlName("SRA") + "%"
			__cSRJtab := "%" + RetSqlName("SRJ") + "%"
		EndIf

		cJoin := "% SRA.RA_CODFUNC = SRJ.RJ_FUNCAO AND " + fMHRTableJoin("SRA", "SRJ") + "%"

		cQuery  := GetNextAlias()

		BEGINSQL ALIAS cQuery
		
		SELECT RA_FILIAL, RA_MAT, RA_CODFUNC, RJ_FUNCAO, RJ_DESC
		FROM %exp:__cSRAtab% SRA
			INNER JOIN %exp:__cSRJtab% SRJ
			ON %exp:cJoin%
		WHERE SRA.RA_FILIAL=%exp:cBranch% AND SRA.RA_MAT=%exp:cMat%
		
		ENDSQL

		While (cQuery)->(!Eof())
			cDescFunc := AllTrim( (cQuery)->RJ_DESC )
			Exit
		EndDo
		(cQuery)->( DbCloseArea() )

	EndIf

Return( cDescFunc )


/*/{Protheus.doc} fGetRH4Cpos
Retorna um array com os campos de uma requisicao (tabela RH4) conforme a filial e codigo
@author:	Marcelo Silveira
@since:		08/05/2019
@param:		cFilial  - Filial da requisicao;
			cCodigo	 - Codigo da requisicao;
@return: Array com os dados da requisiao de acordo com os parâmetros.
/*/
Function fGetRH4Cpos( cFilReq, cCodReq )

	Local cAliasRH4 := ""
	Local aData     := {}

	DEFAULT cFilReq := ""
	DEFAULT cCodReq := ""

	If !Empty(cFilReq) .And. !Empty(cCodReq)

		cAliasRH4 := GetNextAlias()

		BeginSql alias cAliasRH4
		SELECT RH4.RH4_CODIGO, RH4.RH4_CAMPO, RH4.RH4_VALNOV
		FROM  %table:RH4% RH4 
		WHERE 
			RH4.RH4_FILIAL  = %exp:cFilReq%	AND
			RH4.RH4_CODIGO  = %exp:cCodReq%	AND
			RH4.%notDel% 
		EndSql

		While !(cAliasRH4)->(Eof())

			aAdd( aData, { ;
				Alltrim( (cAliasRH4)->RH4_CAMPO ), ;
				Alltrim( (cAliasRH4)->RH4_VALNOV ) ;
				})

			(cAliasRH4)->(DBSkip())
		Enddo

		If select(cAliasRH4) > 0
			(cAliasRH4)->( DBCloseArea() )
		EndIf

	EndIf

Return( aData )

/*/{Protheus.doc} fGetdelaysAbsences
	Retorna um array com os eventos de atrasos e faltas do time
	@author	Marcelo Silveira
	@since	29/10/2020
	@param	Filial = Filial do funcionario que esta consultando (gestor)
			Matricula = Matricula do funcionario que esta consultando (gestor)
			lTotalize = Logico para definir se ira gerar só total do time
			aCoordTeam = Array com a estrutura da equipe do gestor
			aQryParam = Query parametros da API que esta fazendo a requisicao
			lNextPage = Logico, Se .T. indica que existem mais registros
	@return aEventos, array com os eventos de faltas e ausencias
/*/
Function fGetdelaysAbsences( cBranchVld, cMatSRA, lTotalize, aCoordTeam, aQryParam, lNextPage )

	Local cEmpJob		:= cEmpAnt
	Local cMatAtu		:= ""
	Local cFilAtu		:= ""
	Local cEmpAtu		:= ""
	Local cPage			:= ""
	Local cPageSize		:= ""
	Local cOcurrency	:= ""
	Local cClassEv		:= "01,02,03,04,05"

	Local cDtIni		:= ""
	Local cDtFim		:= ""

	Local aEventos		:= {}
	Local aRet			:= {}
	Local aRetData 		:= {}
	LocaL nRegCount		:= 0
	Local nRegIniCount  := 0 
	Local nRegFimCount  := 0
	LocaL nX        	:= 0
	Local nY			:= 0

	Local lPageControl	:= .F.

	//Obtem os valores das queryparams para aplicar os filtros
	For nX := 1 To Len( aQryParam )
		Do Case
			Case UPPER(aQryParam[nX,1]) == "PAGE"
				cPage		:= aQryParam[nX,2] 
			Case UPPER(aQryParam[nX,1]) == "PAGESIZE"
				cPageSize	:= aQryParam[nX,2]
			Case UPPER(aQryParam[nX,1]) == "OCURRENCY"
				cOcurrency	:= aQryParam[nX,2]
			Case UPPER(aQryParam[nX,1]) == "STARTDATE"
				cDtIni		:= aQryParam[nX,2]
			Case UPPER(aQryParam[nX,1]) == "ENDDATE"
				cDtFim		:= aQryParam[nX,2]
		End Case
	Next

	//Realiza o controle de paginacao
	If !Empty(cPage) .And. !Empty(cPageSize)
		If cPage == "1" .Or. cPage == ""
			nRegIniCount := 1 
			nRegFimCount := If( Empty( Val(cPageSize) ), 20, Val(cPageSize) )
		Else
			nRegIniCount := ( Val(cPageSize) * ( Val(cPage) - 1 ) ) + 1
			nRegFimCount := ( nRegIniCount + Val(cPageSize) ) - 1
		EndIf
		lPageControl := .T.
	EndIf	

	//Filtra conforme o tipo da ocorrencia
	If !Empty(cOcurrency)
		If UPPER(cOcurrency) == "DELAY"
			cClassEv := "03,04,05"
		ElseIf UPPER(cOcurrency) == "ABSENCE"
			cClassEv := "02"
		Else
			cClassEv := "01"
		EndIf
	EndIf

	aClass := StrTokArr(cClassEv,",")

	//Filtra por data e trata remocao de filtros da tela para nao gerar erro
	If !Empty(cDtIni)
		cDtIni := StrTran( SubStr(cDtIni, 1, 10), "-", "" )
		cDtFim := If( Empty(cDtFim), cDtIni, cDtFim )
	EndIf	

	If !Empty(cDtFim)
		cDtFim := StrTran( SubStr(cDtFim, 1, 10), "-", "" )
		cDtIni := If( Empty(cDtIni), cDtFim, cDtIni )
	EndIf

	For nX := 1 to Len(aCoordTeam[1]:ListOfEmployee)
		cEmpAtu := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeEmp
		cFilAtu := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeFilial
		cMatAtu := aCoordTeam[1]:ListOfEmployee[nX]:Registration

		If !( cEmpAtu+cFilAtu+cMatAtu == cEmpAnt+cBranchVld+cMatSRA )

			aRet := GetDataForJob("21", { cEmpAtu, cFilAtu, cMatAtu, cDtIni, cDtFim, aClass, lTotalize, cEmpJob }, cEmpAtu, cEmpJob)
			cEmpJob := cEmpAtu

			//Preenche o array de retorno
			If !Empty(aRet)
				For nY := 1 To Len(aRet)
					aAdd(aEventos, aRet[nY])
				Next nY
			EndIf
		EndIf
	Next nX
	
	//Fecha as tabelas do ponto após a utilização
	Pn090Close()

	If lTotalize
		aRetData := aEventos
	Else
		//Ordena por data e nome
		ASort( aEventos,,, { |x, y| x[5]+x[4] < y[5]+y[4] })

		//Retorna os registros conforme a paginacao
		For nX := 1 To Len(aEventos)

			nRegCount ++		
			
			If !lPageControl .Or. (nRegCount >= nRegIniCount .And. nRegCount <= nRegFimCount)
				aAdd( aRetData,	aEventos[nX] )
			Else
				If nRegCount >= nRegFimCount
					lNextPage := .T.
					Exit
				EndIf
			EndIf
		Next nX
		
	EndIf

Return(aRetData)


/*/{Protheus.doc} fTeamEmp
Retorna a estrutura do time de outro grupo de empresas
@author:	Marcelo Silveira
@since:		24/05/2021
@param:		cNewEmp - Empresa do outro grupo;
			cNewFil - Filial do outro grupo;
			aParams - Parametros que serao passados para APIGetStructure;
@return:	aTeam - Array com a estrutura do time
/*/
Function fTeamEmp(cBranchVld, cEmpFunc, cMatSRA, aParams, lJob, cUID)
	Local nX		 := NIL
	Local nY		 := NIL
	Local aCoordTeam := {}
	Local aAllData 	 := {}
	Local aEmails    := {}
	Local aPhones    := {}
	Local aDateGMT   := {}
	Local aQryParam	 := {}
	Local aData		 := {}
	Local oPhone     := Nil
	Local oEmail     := Nil
	Local oContacts  := Nil
	Local oData		 := NIL
	Local oEmployee  := Nil
	Local oItem		 := NIL
	Local dDtUltSal  := CToD("//")
	Local initPeriod := ctod("//")
	Local endPeriod  := ctod("//")
	Local dConvData	 := ctod("//")
	Local cEmpStruct := ""
	Local cFilStruct := ""
	Local cMatStruct := ""
	Local lContinua  := .T.
	Local lNomeSoc   := .F.
	Local lAttPoints := .F.
	Local lHasNext	 := .F.
	Local nPos		 := 0
	Local nPage		 := 1
	Local nPageSize  := 20
	Local nInicio
	Local nFim

	If lJob
		RPCSetType( 3 )
		RPCSetEnv( cEmpFunc, cBranchVld )
   	EndIf

	aQryParam   := aParams[18]
	aCoordTeam := APIGetStructure( aParams[1], ;
							  aParams[2], ;
							  aParams[3], ;
							  aParams[4], ;
							  aParams[5], ;
							  aParams[6], ;
							  aParams[7], ;
							  aParams[8], ;
							  aParams[9], ;
							  aParams[10], ;
							  aParams[11], ;
							  aParams[12], ;
							  aParams[13], ;
							  aParams[14], ;
							  aParams[15], ;
							  aParams[16], ;
							  aParams[17], ;
							  aParams[18], ;
							  @lHasNext )

	lContinua := Len(aCoordTeam) > 0 .And. !ValType( aCoordTeam[1] ) == "L" //Verifica se carregou dados da hierarquia.

	If lContinua
		// Tratativas queryParams.
		If Len(aQryParam) > 0
			If ( nPos := aScan( aQryParam, { |x| Upper( x[1] ) == "PAGE" } ) ) > 0
				nPage:= Val( aQryParam[nPos,2] )
			EndIf
			If ( nPos := aScan( aQryParam, { |x| Upper( x[1] ) == "PAGESIZE" } ) ) > 0
				nPageSize:= Val( aQryParam[nPos,2] )
			EndIf
			If ( nPos := aScan( aQryParam, { |x| Upper( x[1] ) == "ATTENTIONPOINTS" } ) ) > 0
				lAttPoints := If(aQryParam[nPos,2] == "true", .T., .F.) .And. aParams[2] == "0"
			EndIf
			If lAttPoints .And. ( nPos := aScan( aQryParam, { |x| Upper( x[1] ) == "INITPERIOD" } ) ) > 0
				initPeriod := StoD(Format8601(.T., aQryParam[nPos,2], Nil, .T.))
			EndIf
			If lAttPoints .And. ( nPos := aScan( aQryParam, { |x| Upper( x[1] ) == "ENDPERIOD" } ) ) > 0
				endPeriod := StoD(Format8601(.T., aQryParam[nPos,2], Nil, .T.))
			EndIf
		Endif

		lNomeSoc := SuperGetMv("MV_NOMESOC", NIL, .F.)
		For nX := 1 To Len(aCoordTeam)
		
			For nY := 1 To Len(aCoordTeam[nX]:ListOfEmployee)
				cEmpStruct := aCoordTeam[1]:ListOfEmployee[nY]:EmployeeEmp
				cFilStruct := aCoordTeam[1]:ListOfEmployee[nY]:EmployeeFilial
				cMatStruct := aCoordTeam[1]:ListOfEmployee[nY]:Registration

				oEmployee := aCoordTeam[nX]:ListOfEmployee[nY]

				If lContinua .And. !(cEmpStruct+cFilStruct+cMatStruct == cEmpFunc+cBranchVld+cMatSRA)//(Nao considera a propria matricula)

					//Tratamento do queryParam attention Points.
					If lAttPoints
						If(!fHvAttPnts(cFilStruct, cMatStruct, initPeriod, endPeriod))
							Loop
						EndIf
					EndIf
					
					oData                      := JsonObject():New()
					oData["id"]                := oEmployee:EmployeeFilial +"|"+ oEmployee:Registration +"|"+ oEmployee:EmployeeEmp

					oData["name"]              := AllTrim(EncodeUTF8(If(lNomeSoc .And. !Empty(oEmployee:SocialName), oEmployee:SocialName, oEmployee:Name)))
					oData["roleDescription"]   := AllTrim(EncodeUTF8(oEmployee:FunctionDesc))
					oData["department"]        := AllTrim(EncodeUTF8(oEmployee:DescrDepartment))
					oData["branchName"]		   := oEmployee:EmployeeFilial
					oData["registry"]		   := oEmployee:Registration
					oData["isCoordinator"]	   := oEmployee:PossuiEquipe
					oData["isInternal"]        := oEmployee:CatFunc == "E" .Or. oEmployee:CatFunc == "G"

					dConvData                  := CToD(oEmployee:AdmissionDate)
					aDateGMT                   := Iif(!Empty(dConvData), LocalToUTC( DTOS(dConvData), "12:00:00" ),{})
					oData["admissionDate"]     := Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")

					dConvData                  := CToD(oEmployee:BirthdayDate)
					aDateGMT                   := Iif(!Empty(dConvData), LocalToUTC( DTOS(dConvData), "12:00:00" ),{})
					oData["birthDate"]         := Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")

					If Empty(oEmployee:Situacao)
						oData["employeeStatus"] := "N"
					Else
						oData["employeeStatus"] := AllTrim(oEmployee:Situacao)
					EndIf

					//Busca dados de contato
					aPhones := {}
					aEmails := {}

					DbSelectArea("SRA")
					SRA->( dbSetOrder(1) )
					If SRA->( dbSeek(oEmployee:EmployeeFilial + oEmployee:Registration) )
						//telefones
						If !Empty(SRA->RA_TELEFON)
							oPhone                   := JsonObject():New()
							oPhone["id"]             := Iif( !Empty(SRA->RA_DDDFONE) .And. !Empty(SRA->RA_TELEFON), "home", "" )
							oPhone["region"]         := Nil
							oPhone["ddd"]            := Val(Alltrim( SRA->RA_DDDFONE ))
							oPhone["number"]         := Alltrim( SRA->RA_TELEFON )
							oPhone["default"]        := .T.
							oPhone["type"]           := "home"
							Aadd(aPhones, oPhone )
						EndIf

						If !Empty(SRA->RA_NUMCELU)
							oPhone                   := JsonObject():New()
							oPhone["id"]             := Iif( !Empty(SRA->RA_DDDCELU) .And. !Empty(SRA->RA_NUMCELU), "mobile", "" )
							oPhone["region"]         := Nil
							oPhone["ddd"]            := Val(Alltrim( SRA->RA_DDDCELU ))
							oPhone["number"]         := Alltrim( SRA->RA_NUMCELU )
							oPhone["default"]        := .F.
							oPhone["type"]           := "mobile"
							Aadd(aPhones, oPhone )
						EndIf

						//emails
						If !Empty(SRA->RA_EMAIL)
							oEmail                   := JsonObject():New()
							oEmail["id"]             := Iif( !Empty(SRA->RA_EMAIL), "work", "" )
							oEmail["email"]          := Alltrim( EncodeUTF8( SRA->RA_EMAIL ) )
							oEmail["default"]        := .T.
							oEmail["type"]           := EncodeUTF8("work")
							Aadd(aEmails, oEmail)
						EndIf

						IF !Empty(SRA->RA_EMAIL2)
							oEmail                   := JsonObject():New()
							oEmail["id"]             := Iif( !Empty(SRA->RA_EMAIL2), "home", "" )
							oEmail["email"]          := Alltrim( EncodeUTF8( SRA->RA_EMAIL2 ) )
							oEmail["default"]        := .F.
							oEmail["type"]           := EncodeUTF8("home")
							Aadd(aEmails, oEmail)
						EndIf
					EndIf

					oContacts		               := JsonObject():New()
					oContacts["phones"]            := aPhones
					oContacts["emails"]            := aEmails
					oData["contacts"]              := oContacts


					//busca última atualziação salarial
					dDtUltSal := fGetDtSal( oEmployee:EmployeeEmp, oEmployee:EmployeeFilial, oEmployee:Registration )

					aDateGMT                   := Iif(!Empty(dDtUltSal), LocalToUTC( DTOS(dDtUltSal), "12:00:00" ),{})
					oData["salaryDate"]        := Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")
					oData["salary"]            := oEmployee:Salary

					Aadd(aAllData, oData)
				EndIf
			Next nY
		Next nX
	EndIf

	If Len(aQryParam) == 0 .Or. lAttPoints
		nInicio := ( ( nPage - 1) * nPageSize ) + 1
		nFim    := Min( nInicio + nPageSize - 1, Len(aAllData))

		If Len(aAllData) >= nInicio

			ASort( aAllData,,, { |x, y| x["name"] < y["name"] })

			For nX := nInicio to nFim
				Aadd(aData, aAllData[nX])
			Next
		EndIf
		If(lAttPoints)
			lHasNext := Len(aAllData) > nFim
		EndIf
	Else
		ASort( aAllData,,, { |x, y| x["name"] < y["name"] })
		aData := aClone(aAllData)
	EndIf

	oItem := JsonObject():New()
	oItem["hasNext"] := lHasNext
	oItem["items"]   := aData

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

	FreeObj(oData)
	FreeObj(oContacts)
	FreeObj(oEmail)
	FreeObj(oPhone)

Return( oItem )

/*/{Protheus.doc} fRetPos
Avalia 1 elemento do array comparando aos demais para checar se existe intersecção entre datas
A comparação também pode ser entre os elementos do array e uma data fixa
@author:	Marcelo Silveira
@since:		17/06/2021
@param:		aCheck - Array com os dados dos funcionarios
		    nPosAtu - Elemento base do array que será comparado com os demais
			nPosIni - Numero da posicao que indica a data inicial
			nPosFim - Numero da posicao que indica a data final
			lDtFixa - Indica que a comparacao será com uma data especifica 
			dDtIni - Data especifica inicial para comparação com o(s) elemento(s) do array
			dDtFim - Data especifica final para comparação com o(s) elemento(s) do array
@return:	nRet - Posicao do elemento onde ocorreu a intersecção
/*/
Static Function fRetPos(aCheck, nPosAtu, nPosIni, nPosFim, lDtFixa, dDtIni, dDtFim)

Local nZ 		:= 0
Local nRet		:= 0

Default nPosIni	:= 5
Default nPosIni	:= 6
Default lDtFixa	:= .F.

For nZ := 1 To Len(aCheck)

	If UPPER(aCheck[nZ, 3]) == "VACATIONLIMIT" .Or. UPPER(aCheck[nZ, 4]) == "CLOSED"
		Loop
	EndIf

	If ValType(aCheck[nPosAtu,nPosIni]) == "C"
		dIniRef := CTOD( aCheck[nPosAtu,nPosIni] )
		dFimRef := CTOD( aCheck[nPosAtu,nPosFim] )
	Else
		dIniRef := aCheck[nPosAtu,nPosIni]
		dFimRef := aCheck[nPosAtu,nPosFim]
	EndIf

	If lDtFixa
		dIniComp := CTOD(Substr(dDtIni,9,2) + "/" + Substr(dDtIni,6,2) + "/" + Substr(dDtIni,1,4))
		dFimComp := CTOD(Substr(dDtFim,9,2) + "/" + Substr(dDtFim,6,2) + "/" + Substr(dDtFim,1,4))
	Else
		If ValType(aCheck[nZ,nPosIni]) == "C"
			dIniComp := CTOD( aCheck[nZ,nPosIni] )
			dFimComp := CTOD( aCheck[nZ,nPosFim] )
		Else
			dIniComp := aCheck[nZ,nPosIni]
			dFimComp := aCheck[nZ,nPosFim]	
		EndIf
	EndIf

	If !nZ == nPosAtu .Or. lDtFixa
		If ( ;
			((dIniRef >= dIniComp .And. dIniRef <= dFimComp) .Or. ;
			 (dFimRef >= dIniComp .And. dFimRef <= dFimComp)) .Or. ;
			((dIniComp >= dIniRef .And. dIniComp <= dFimRef) .Or. ;
			 (dFimComp >= dIniRef .And. dFimComp <= dFimRef)) ;
			) 
			nRet := nZ
			Exit
		EndIf
	EndIf
Next nZ

Return( nRet )

/*/{Protheus.doc}GetVacLimit
- Retorna o periodo concessivo do funcionario.
@author:	Matheus Bizutti, Marcelo Silveira (nova versao)
@since:	12/04/2017
@param:	
	- aOcurances = Array passado por referencia para obter as ausencias;
	- cMatTeam = Matricula que sera utilizada como filtro
	- cFilTeam = Filial que sera utilizada como filtro
	- cEmpTeam = Empresa que sera utilizada como filtro
	- aDataFunc = Dados do funcionario para inclusão em aOcurances
	- aQPDts   = Array com os filtros de data.	
/*/
Function GetVacLimit(aOcurances, cMatTeam, cFilTeam, cEmpTeam, aDataFunc, aQPDts, nMonthAdv)

Local cQuery 		:= GetNextAlias()
Local aPeriod		:= {}
Local aDataSRH		:= {}
Local cFunName		:= "" 
Local cFunDepto		:= ""
Local cFunFuncao	:= ""
Local cCondition	:= ""
Local cQryObj       := ""
Local nX			:= 0
Local nDFer			:= 0
Local nVacAbs       := 0
Local nPosFer		:= 0
Local nDiasSRH		:= 0
Local nFerSRH		:= 0
Local nDiasDir		:= 0
Local nFaltas		:= 0
Local nSubDays		:= 60
Local dDate   		:= Date()
Local dIniVacDate   := CToD(" / / ")
Local dEndVacDate   := CToD(" / / ")
Local dDtIni		:= CToD(" / / ")
Local dDtFim		:= CToD(" / / ")
Local lAchou		:= Len(aQPDts) == 0

Default nMonthAdv	:= 0
Default aOcurances 	:= {}
Default aDataFunc   := {}
Default aQPDts		:= {}
Default cMatTeam	:= ""
Default cFilTeam	:= FwCodFil()
Default cEmpTeam	:= cEmpAnt


If Len(aDataFunc) > 2
	cFunName	:= aDataFunc[1]
	cFunDepto	:= aDataFunc[2]
	cFunFuncao	:= aDataFunc[3]
EndIf

dDate := If( Empty(dDtRobot), dDate, dDtRobot )

If !Empty(cMatTeam)
	If oStVacLim == Nil .Or. cGetVacLim <> cEmpTeam
		oStVacLim := FWPreparedStatement():New()
		cQryObj := " SELECT RA_FILIAL, RA_MAT, RA_SITFOLH, RF_FILIAL, RF_MAT, RF_DATABAS, RF_DATAFIM, RF_DFERVAT, RF_DFERAAT,"
		cQryObj += " RF_DATAINI, RF_DFEPRO1, RF_DABPRO1, RF_DATINI2, RF_DFEPRO2, RF_DABPRO2, RF_DATINI3, RF_DFEPRO3, RF_DABPRO3,"
		cQryObj += " RF_DFALVAT, RF_DFALAAT"
		cQryObj += " FROM " + RetFullName('SRA', cEmpTeam) + " SRA "
		cQryObj += " INNER JOIN " + RetFullName('SRF', cEmpTeam) + " SRF "
		cQryObj += " ON SRA.RA_FILIAL = SRF.RF_FILIAL AND SRA.RA_MAT = SRF.RF_MAT"
		cQryObj += " WHERE SRA.RA_SITFOLH NOT IN ('D','T')"
		cQryObj += " AND SRA.RA_FILIAL = ?"
		cQryObj += " AND SRA.RA_MAT = ?"
		cQryObj += " AND SRF.RF_STATUS = '1'"
		cQryObj += " AND SRA.D_E_L_E_T_ = ' '"
		cQryObj += " AND SRF.D_E_L_E_T_ = ' '"

		cQryObj := ChangeQuery(cQryObj)
		cGetVacLim := cEmpTeam
		oStVacLim:SetQuery(cQryObj)
	EndIf

	//DEFINIÇÃO DOS PARÂMETROS.
	oStVacLim:SetString(1,cFilTeam)
	oStVacLim:SetString(2,cMatTeam)
	
	cQryObj := oStVacLim:GetFixQuery()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryObj),cQuery,.T.,.T.)
	oStVacLim:doTcSetField(cQuery)

	If Len(aQPDts) > 0
		dDtIni := aQPDts[1,1]
		dDtFim := aQPDts[1,2]
	EndIf

	While (cQuery)->(!Eof())

		aPeriod 	:= PeriodConcessive((cQuery)->RF_DATABAS,(cQuery)->RF_DATAFIM)

		//Reinicia conteudo das variáveis utilizados no While
		nVacAbs     := 0
		nFerSRH		:= 0
		nFaltas		:= 0
		nDiasDir	:= 0
		nDiasSRH	:= 0
		dIniVacDate := CToD(" / / ")
		dEndVacDate := CToD(" / / ")

		//Verifica se existe calculo para a programacao de ferias que esta sendo avaliada
		//Utiliza a database das férias pois podem haver até 3 programações para o mesmo período.
		aDataSRH  := fGetSRH( (cQuery)->RF_FILIAL, (cQuery)->RF_MAT, STOD((cQuery)->RF_DATABAS), STOD((cQuery)->RF_DATAFIM) )

		If Len(aDataSRH) > 0
			For nX := 1 to Len(aDataSRH)
				nDiasSRH += ( aDataSRH[nX][2] + aDataSRH[nX][6] )
			Next nX
		EndIf

		nDFer 	 := If( (cQuery)->RF_DFERVAT > 0, (cQuery)->RF_DFERVAT, (cQuery)->RF_DFERAAT) - nDiasSRH
		dDouble  := aPeriod[2] - nDFer + 1
		nDiasDir := IIf( (cQuery)->RF_DFERVAT > 0 , (cQuery)->RF_DFERVAT, 30)
		nFaltas  := IIf( (cQuery)->RF_DFERVAT > 0, (cQuery)->RF_DFALVAT, (cQuery)->RF_DFALAAT )
		nFaltas  += Iif( (cQuery)->RF_DFERVAT > 0, 0, fMRhGetFal(cFilTeam, cMatTeam, cEmpTeam) )
		TabFaltas(@nFaltas)
		// Mantém as faltas sobre 30 dias.
		nFaltas := IIf( (cQuery)->RF_DFERVAT > 0, nFaltas, ( nFaltas / (cQuery)->RF_DFERAAT ) * 30 )

		If nMonthAdv > 0 
			If ( aPeriod[2] > DaySum(dDate , nMonthAdv ) ) .Or. ;
				dDouble <= dDate .Or.     ;     	 // Férias que já estão em dobro são desprezadas.
				(cQuery)->RF_DFERAAT > 0 .Or. ; 	 // Férias proporcionais são desprezadas.
				Len(aDataSRH) > 0 .Or. ; 			 // Férias já calculadas para o período aquisitivo são desprezadas.
				!Empty((cQuery)->RF_DATAINI) .Or. ;  // Férias programadas para o período aquisitivo são desprezadas.
				!Empty((cQuery)->RF_DATINI2) .Or. ;  // Férias programadas para o período aquisitivo são desprezadas.
				!Empty((cQuery)->RF_DATINI3)         // Férias programadas para o período aquisitivo são desprezadas.
				(cQuery)->( DbSkip() )
				Loop
			EndIf
		EndIf

		If !empty((cQuery)->RF_DATAINI)
			dIniVacDate := cToD( Substr((cQuery)->RF_DATAINI,7,2) + "/" + Substr((cQuery)->RF_DATAINI,5,2) + "/" + Substr((cQuery)->RF_DATAINI,1,4) )
			dEndVacDate := (dIniVacDate + (cQuery)->RF_DFEPRO1) - 1
			If !Empty(dDtIni) .And. !Empty(dDtFim)
				lAchou := ( dIniVacDate >= dDtIni .And. dEndVacDate <= dDtFim  )
			EndIf
			If lAchou .And. dIniVacDate >= dDate
				nVacAbs     := (cQuery)->RF_DABPRO1
				nFerSRH		:= (cQuery)->RF_DFEPRO1
				// Somente considera a programação se ela não tiver cálculo de férias
				If ( nPosFer := Ascan( aDataSRH, {|x| ( x[1] == (cQuery)->RF_DATAINI ) } ) ) == 0 
					aAdd( aOcurances, ;
					{ ;
					(cQuery)->RF_MAT,;
					(cQuery)->RF_FILIAL +"|"+ (cQuery)->RF_MAT +"|"+ cEmpTeam ,;
					"vacation",;
					"approved",;
					dIniVacDate,;
					dEndVacDate,;
					nVacAbs,;
					.F.,;
					{},;
					Nil,;
					.F.,;
					Nil,;
					Nil,;
					Nil,;
					"",;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					(cQuery)->RF_DATABAS,;
					(cQuery)->RF_DATAFIM,;
					Nil,;
					Nil,;  
					cFunName,;
					cFunDepto,;
					cFunFuncao,;
					{aPeriod[1], aPeriod[2]},;
					nFerSRH + nVacAbs,;
					"scheduledVacation",;
					nDiasDir-nFaltas;
					})
				EndIf
			EndIf
		EndIf

		//Verifica se possui férias programas na 2 programação, pois podem haver até 3 programações para o mesmo período aquisitivo
		If !empty((cQuery)->RF_DATINI2)
			dIniVacDate := cToD( Substr((cQuery)->RF_DATINI2,7,2) + "/" + Substr((cQuery)->RF_DATINI2,5,2) + "/" + Substr((cQuery)->RF_DATINI2,1,4) )
			dEndVacDate := (dIniVacDate + (cQuery)->RF_DFEPRO2) - 1
			If !Empty(dDtIni) .And. !Empty(dDtFim)
				lAchou := ( dIniVacDate >= dDtIni .And. dEndVacDate <= dDtFim  )
			EndIf
			If lAchou .And. dIniVacDate >= dDate
				nVacAbs     := (cQuery)->RF_DABPRO2
				nFerSRH		:= (cQuery)->RF_DFEPRO2
				// Somente considera a programação se ela não tiver cálculo de férias
				If ( nPosFer := Ascan( aDataSRH, {|x| ( x[1] == (cQuery)->RF_DATINI2 ) } ) ) == 0 
					aAdd( aOcurances, ;
					{ ;
					(cQuery)->RF_MAT,;
					(cQuery)->RF_FILIAL +"|"+ (cQuery)->RF_MAT +"|"+ cEmpTeam, ;
					"vacation",;
					"approved",;
					dIniVacDate,;
					dEndVacDate,;
					nVacAbs,;
					.F.,;
					{},;
					Nil,;
					.F.,;
					Nil,;
					Nil,;
					Nil,;
					"",;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					(cQuery)->RF_DATABAS,;
					(cQuery)->RF_DATAFIM,;
					Nil,;
					Nil,;
					cFunName,;
					cFunDepto,;
					cFunFuncao,;
					{aPeriod[1], aPeriod[2]},;
					nFerSRH + nVacAbs,;
					"scheduledVacation",;
					nDiasDir-nFaltas;
					})
				EndIf
			EndIf
		EndIf

		//Verifica se possui férias programas na 3 programação, pois podem haver até 3 programações para o mesmo período aquisitivo
		If !empty((cQuery)->RF_DATINI3)
			dIniVacDate := cToD( Substr((cQuery)->RF_DATINI3,7,2) + "/" + Substr((cQuery)->RF_DATINI3,5,2) + "/" + Substr((cQuery)->RF_DATINI3,1,4) )
			dEndVacDate := (dIniVacDate + (cQuery)->RF_DFEPRO3) - 1
			If !Empty(dDtIni) .And. !Empty(dDtFim)
				lAchou := ( dIniVacDate >= dDtIni .And. dEndVacDate <= dDtFim  )
			EndIf
			If lAchou .And. dIniVacDate >= dDate
				nVacAbs     := (cQuery)->RF_DABPRO3
				nFerSRH		:= (cQuery)->RF_DFEPRO3
				// Somente considera a programação se ela não tiver cálculo de férias
				If ( nPosFer := Ascan( aDataSRH, {|x| ( x[1] == (cQuery)->RF_DATINI3 ) } ) ) == 0 
					aAdd( aOcurances, ;
					{ ;
					(cQuery)->RF_MAT,;
					(cQuery)->RF_FILIAL +"|"+ (cQuery)->RF_MAT +"|"+ cEmpTeam, ;
					"vacation",;
					"approved",;
					dIniVacDate,;
					dEndVacDate,;
					nVacAbs,;
					.F.,;
					{},;
					Nil,;
					.F.,;
					Nil,;
					Nil,;
					Nil,;
					"",;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					Nil,;
					(cQuery)->RF_DATABAS,;
					(cQuery)->RF_DATAFIM,;
					Nil,;
					Nil,;
					cFunName,;
					cFunDepto,;
					cFunFuncao,;
					{aPeriod[1], aPeriod[2]},;
					nFerSRH + nVacAbs,;
					"scheduledVacation",;
					nDiasDir-nFaltas;
					})
				EndIf
			EndIf
		EndIf
		If lAchou .And. aScan( aOcurances, { |x| x[2] == cFilTeam +"|"+ cMatTeam +"|"+ cEmpTeam } ) == 0

			dRiskDouble := aPeriod[2] - (nDFer + nSubDays) + 1
			cCondition	:= GetCondition(dDouble, dRiskDouble, (cQuery)->RF_DFERVAT, (cQuery)->RF_DFERAAT, , , ,dDate)

			aAdd(aOcurances, ;
				{ ;
				(cQuery)->RF_MAT,;
				(cQuery)->RF_FILIAL +"|"+ (cQuery)->RF_MAT +"|"+ cEmpTeam,;
				"vacationLimit",;
				"empty",;
				aPeriod[1],;
				aPeriod[2],;
				nVacAbs,;
				.F.,;
				{},;
				Nil,;
				.F.,;
				Nil,;
				Nil,;
				Nil,;
				"",;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				Nil,;
				(cQuery)->RF_DATABAS,;
				(cQuery)->RF_DATAFIM,;
				Nil,;
				Nil,;
				cFunName,;
				cFunDepto,;
				cFunFuncao,;
				{aPeriod[1], aPeriod[2]},;
				nDFer,;
				cCondition,;
				nDiasDir-nFaltas;
				})
			EndIf
		(cQuery)->( DbSkip() )
	EndDo
EndIf

(cQuery)->( DBCloseArea() )

Return(Nil)

/*/{Protheus.doc} GetCondition
Retorna a etapa da solicitação conforme os dados recebidos para avaliação
@author: Marcelo Silveira
@since:	13/08/2021
@param:	dDouble - Data para avaliar se é ferias em dobro
        dRiskDouble - Data para avaliar se é risco de ferias em dobro
        nFerVen - Dias de férias vencidas
        nFerProp - Dias de férias proporcionais
		lAbsense - Indica que está avaliando dados de afastamentos (tabela SR8)
		dDtIniAbs - Data inicio das férias (lAbsense = true)
		dDtIniAbs - Data final das férias (lAbsense = true)
		dDate - Data para comparação
@return: cCondition - Condição/etapa conforme a avaliação dos dados
/*/
Function GetCondition(dDouble, dRiskDouble, nFerVen, nFerProp, lAbsense, dDtIniAbs, dDtFimAbs, dDate)

Local cCondition := ""

DEFAULT lAbsense := .F.
DEFAULT dDate 	 := dDataBase

	DO CASE
		CASE !lAbsense .And. dDouble <= dDate
			cCondition := "doubleExpiredVacation"
		CASE !lAbsense .And. dRiskDouble <= dDate
			cCondition := "doubleRisk"
		CASE !lAbsense .And. nFerVen > 0 
			cCondition := "expiredVacation"
		CASE !lAbsense .And. nFerProp > 0
			cCondition := "vacationsToExpire"
		CASE lAbsense .And. dDtFimAbs <= dDate
			cCondition := "vacationsTaken"
		CASE lAbsense .And. dDtIniAbs > dDate
			cCondition := "calculated"
		CASE lAbsense .And. dDtIniAbs <= dDate
			cCondition := "onVacation"
		OTHERWISE
			cCondition := "vacationsToExpire"
	END CASE

Return( cCondition )

Static Function fGetDtSal( cCodEmp, cCodFil, cCodMat )

	Local dDtUltSal := ctod("//")
	Local cQuery	:= GetNextAlias()
	Local cTable	:= "%"+RetFullName("SR3",cCodEmp)+"%"

	BeginSQL Alias cQuery
		
		COLUMN R3_DATA AS DATE

		SELECT SR3.R3_FILIAL, SR3.R3_MAT, SR3.R3_DATA, SR3.R3_VALOR
			FROM %Exp:cTable% SR3
		WHERE
			SR3.R3_FILIAL = %Exp:cCodFil% AND
			SR3.R3_MAT = %Exp:cCodMat% AND
			SR3.R3_PD = '000' AND // Verba de salario base.
			SR3.D_E_L_E_T_ = ' '
			ORDER BY 3 DESC
	ENDSQL

	If !(cQuery)->(Eof())
		If (cQuery)->R3_DATA > dDtUltSal
			dDtUltSal := (cQuery)->R3_DATA
		EndIf
	EndIf

	(cQuery)->(dbclosearea())

Return dDtUltSal
