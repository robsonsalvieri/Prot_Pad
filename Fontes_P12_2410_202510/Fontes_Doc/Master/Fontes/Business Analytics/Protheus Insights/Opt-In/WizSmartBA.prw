#include "protheus.ch"
#include "InsightDefs.ch"
#INCLUDE "FWLIBVERSION.CH"
#include "wizsmartba.ch"

Static __lChkTerm As Logical

//-------------------------------------------------------------------------------------
/*/
{Protheus.doc} WizSmartBA
Classe responsavel pelo wizard de confoguração Wizard para ativação da integração
entre Protheus X Carol
@author DANILO SANTOS
@since 01/06/2023
/*/
//-------------------------------------------------------------------------------------
Main Function WizSmartBA()
	Private lIsBlind := IsBLind()
 
	MsApp():New("SIGAFIN")
	oApp:cInternet := Nil
	oApp:lIsBlind  := lIsBlind
	__cInterNet    := NIL
	oApp:bMainInit := { || ( oApp:lFlat := .F., WizBAtech(), Final(STR0001 , "" ) ) } // "Encerramento Normal"
	oApp:CreateEnv()
	OpenSM0()

	PtSetTheme("TEMAP10")
	SetFunName("UPDDISTR")
	oApp:lMessageBar := .T.

	grvMetrBA()

	oApp:Activate()
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WizBAtech
Construção da Tela de Wizard
@return Nil
@author TOTVS
@since 10/11/2022
/*/
//-------------------------------------------------------------------------------------
Static Function WizBAtech()
	Local oWizard       As Object
	Local cDescription  As Character
	Local cTermServ     As Character
	Local bProcess      As CodeBlock
	Local aParam        As Array
	Local cMsgWiz       As Character
	Local bConstoptIn   As CodeBlock
	Local bNextOptIn    As CodeBlock
	Local cTermsVers    As Character
	Local lOptInOk      As Logical

	//Valida ambiente Produção ou Engenharia Protheus Insights
	If !totvs.protheus.backoffice.ba.insights.util.pinsCheckEnv()

		Help(Nil, Nil, "WIZARD", "Protheus Insights",	STR0030, 1	;					// "Identificamos que você está usando o Protheus Insights em ambiente de homologação e isto afeta a qualidade e atualização de novas recomendações."
			,Nil ,Nil, Nil, Nil, Nil, Nil, {STR0031 + CRLF + CRLF +	;					// "Sugerimos que leia a documentação e siga o passo a passo descrito para ter acesso a insights mais assertivos."
			I18N( STR0032, {"https://tdn.totvs.com/display/PROT/Protheus+Insights"} )})	// "Para informações acesse: #1"

		grvMetrDemo( "WIZARD", "", "INSIGHT_WIZARD_OPEN", "HPI" )		// homologação protheus insight	

		Return
		
	EndIf

	oWizard := FWCarolWizard():New()

	__lChkTerm := .F.
	lOptInOk := .F.
	cDescription := STR0002  // "Validando informações de dicionarios" STR0002
	cTermServ    := STR0007
	bConstoptIn := { | oPanel | lOptInOk := BuildOptIn(oPanel, @cTermsVers) }
	bNextOptIn  := { || Iif(lOptInOk, SendOptIn(@cTermsVers), .F.) }
	bProcess    := { | cGrpEmp, cMsg | ProcAnt( cGrpEmp, @cMsg, aParam, oWizard ) }
	cMsgWiz  := STR0005 + CRLF + CRLF + CRLF + STR0006     // "Wizard de configuração para validação de conexão entre Protheus e Carol."  + CRLF + CRLF + CRLF + "A configuração só pode ser realizado por usuários Administradores."
	oWizard:SetWelcomeMessage(cMsgWiz)
	oWizard:AddRequirement( STR0003, GetRpoRelease(), { || GetRpoRelease() >= "12.1.033" }, STR0004 )	// "Release do RPO"###"Versão de RPO deve ser no mínimo 12.1.33"
	oWizard:AddRequirement( STR0023, FwLibVersion(), { || FwLibVersion() >= INSIGHT_LIB }, I18N( STR0024, { INSIGHT_LIB } ) )	//"Versão da LIB"###"Versão da LIB deve ser maior ou igual a #1 "
	If FindFunction( "FWTECHFINVERSION" )
		oWizard:AddRequirement( STR0025, FwtechfinVersion(), { || FwtechfinVersion() >= INSIGHT_SMARTLINK }, I18N( STR0026, { INSIGHT_SMARTLINK } ) )	//"Pacote Smartlink"###"Versão do pacote Smartlink deve ser maior ou igual a #1"
	EndIF
    //oWizard:AddRequirement( STR0027, STR0028 , { || totvs.protheus.backoffice.ba.insights.util.validDictionary(.T.) == .T.  }, I18N( STR0029, { INSIGHT_VERSION } ) )	//"Dicionário de Dados: #"Atualizado" #"Notamos que o dicionário de dados do Protheus Insights não está atualizado. Por favor, baixe o pacote da Expedição Contínua e execute o UPDDISTR. A estrutura necessária está disponível no pacote de: [ #1 ]."         

	//oWizard:SetErpCredentialsMode(.T.) //Método para ativar o provisionamento automático
	//oWizard:SetAppProvision("painelbackoffice") //Método para definir o app a ser provisionado
	oWizard:SetCountries({"ALL"})
	oWizard:AddStep(cTermServ, bConstoptIn, bNextOptIn, { || .T. }, { || .T. })    // "Aceite de Termos de Serviços"
	oWizard:AddProcess(bProcess)
	oWizard:SetTrialMode(.F.) //Default .F.
	oWizard:SetExclusiveCompany(.F.) //Default .T.

	oWizard:Activate()


Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcAnt
Processamento de regra de negócio
@type function
@author TOTVS
@param cGrpEmp, character, grupo de empresa logado
@param cMsg, character, mensagem de erro de retorno
@param aParam, array, parâmetros para da etapa de configuração
@param oWizard, object, Objeto do Wizard do Protheus Insights
@param aADVPRCompanies, array, vetor com as empresas quando chamada via ADVPR
@return logical, sucesso ou falha
/*/
//-------------------------------------------------------------------------------------
Static Function ProcAnt( cGrpEmp, cMsg, aParam, oWizard, aADVPRCompanies )
	Local aCompanies := {}
	Local lI20Exist := .F.

	Default aADVPRCompanies := {}

	lI20Exist := AliasInDic( "I20" )

		cMsg := STR0009    // "Sucesso na conexão"

		// Cria o agendamento da FWTOTVSLINKJOB e outras funções necessárias no agendamento.
		aCompanies	:= Iif( !Empty( aADVPRCompanies ), aADVPRCompanies, oWizard:GetSelectedGroups() )
		AddLinkJob( aCompanies )

		// Força a gravação de configuração dos insights inscritos
		If FindFunction( "pinsSaveConfig" ) .And. lI20Exist
			pinsSaveConfig()            
		EndIf

		// Grava as informações de execução do Wizard.
		totvs.protheus.backoffice.ba.insights.util.saveInstallInfo()	

	FWFreeArray( aCompanies )
Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AddLinkJob
Cria o agendamento da FWTOTVSLINKJOB

@param aCompanies, array, vetor com as empresas apresentadas no Wizard.

@author  Marcia Junko
@since   07//08/2024
/*/
//-------------------------------------------------------------------------------------
Static Function AddLinkJob( aCompanies )
	Local aJobs := {}
	Local cExecComp := ""
    Local cRecurrence := ""
    Local cTaskName := ""	
	Local lI20Exist := .F.

	lI20Exist := AliasInDic( "I20" )
	If FindFunction( "totvs.protheus.backoffice.ba.insights.scheduler.evaluateJobs" )
		If !Empty( aCompanies )
			aEval( aCompanies, {|x| cExecComp += Iif( x[1], x[2] + ";", "" ) } )

			If FindFunction( "totvs.protheus.backoffice.ba.insights.InsightSchedProcess" ) .And. lI20Exist
				cTaskName   := "totvs.protheus.backoffice.ba.insights.InsightSchedProcess"
				cRecurrence := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(0002);Interval(12:00);Discard;"
				aAdd( aJobs, { cTaskName, cRecurrence, "00:00", cExecComp } )
			EndIf
			totvs.protheus.backoffice.ba.insights.scheduler.evaluateJobs( aJobs )
		EndIf
	EndIf

	FWFreeArray( aJobs )
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BuildOptIn
Construcao janela de termo OptIn Carol
@type function
@author TOTVS
@param oPanel, object, painel do wizard
@param cTermsVers, Character, ponteiro para a variavel a ser preenchida com a versão dos termos
@return logical, sucesso ou falha na aquisicao dos termos de aceite
/*/
//-------------------------------------------------------------------------------------
Static Function BuildOptIn(oPanel as Object, cTermsVers as Character)

	Local aHeader as Array
	Local cIdioma as Character
	Local cTerms as Character
	Local cTermsPath as Character
	Local cTermsRet as Character
	Local cTermsURL as Character
	Local lJSonDes as Logical
	Local lRet as Logical
	Local oFont as Object
	Local oRest as Object
	Local oTermsAPI as Object
	Local oCheck1 as Object

	cTermsVers := "0"
	cIdioma := FwRetIdiom()
	cTermsURL := "https://painel-backoffice.totvs.app"
	cTermsPath := "/provisioning/api/Contract/getContract"
	lRet := .F.

	aHeader := {}
	aAdd(aHeader, "User-Agent: Protheus " + GetBuild())
	oRest := FWRest():New(cTermsURL)
	oRest:SetPath(cTermsPath)

	If oRest:Get(aHeader)
		cTermsRet := oRest:GetResult()
		lJSonDes := FWJSonDeserialize(cTermsRet,@oTermsAPI)

		If(!lJSonDes)
			cTerms := oTermsAPI:errormessage  // "Erro ao verificar resposta JSON:"
			Help(Nil, Nil, "WIZSMARTBA", "REST_ERROR", STR0012, 1;      // "Erro ao verificar resposta JSON:"
			,,,,,,,{STR0015})
			lRet := .F.
		Else
			cTerms := DecodeUTF8(&("oTermsAPI:terms_" + SubStr(cIdioma,1,2)))
			cTermsVers := oTermsAPI:id
			lRet := .T.
		EndIf
	Else
		cTerms := oRest:GetLastError()
		Help(Nil, Nil, "WIZSMARTBA", "REST_ERROR", STR0013, 1;      // "Erro ao adquirir termos"
		,,,,,,,{STR0015})
		lRet := .F.
	Endif

	oFont := TFont():New('Times New Roman',, -14, .T.)
	oCheck1 := TCheckBox():New(oPanel:nClientHeight/2.2,(oPanel:nClientWidth/4) - 172,STR0016,{|u|if(PCount()>0,__lChkTerm:= u,__lChkTerm)},oPanel,150,210,,{||.T.},,,,,,.T.,,,) //"Eu concordo com os termos e condições acima."
	@ 015,035 GET oGet1 VAR cTerms OF oPanel MEMO PIXEL FONT oFont SIZE 350,165 WHEN .F.

	FreeObj(oTermsAPI)
	FreeObj(oRest)

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SendOptIn
Envio de OptIn para o endpoint
@type function
@author TOTVS
@param cTermsVers, Character, versão dos termos a ser enviada
@return logical, sucesso ou falha no envio do post do aceite de termos
/*/
//-------------------------------------------------------------------------------------
Static Function SendOptIn(cTermsVers as Character)

	Local aHeadOut     as Array
	Local lRet         as Logical
	Local cAcceptURL   as Character
	Local cTermsPath   as Character
	Local cCNPJ        as Character
	Local oRest        as Object
	Local oTermsAccept as Object

	If !__lChkTerm
		Help(Nil, Nil, "WIZSMARTBA", "ACCEPTTERM", STR0017, 1;     // "Termo de Serviços não aceito."
		,,,,,,,{STR0018})                                              // "Para continuar é necessário aceitar o Termo de Serviços"
		Return .F.
	EndIf

	lRet := .F.
	aHeadOut := {}
	cAcceptURL := "https://painel-backoffice.totvs.app"
	cTermsPath := "/provisioning/api/Contract/acceptContract"

	oRest := FWRest():New(cAcceptURL)
	oRest:SetPath(cTermsPath)

    /*
        Alterar cUserId para pegar variavel __cUserID
        e alterar cUsername para adquirir cUsername das variaveis private
        quando ambiente for setado
        PswAdmin()
    */

	//Busca todos CNPJs da empresa
	cCNPJ := BuscaCNPJ()

	oTermsAccept              := JsonObject():New()
	oTermsAccept["cnpj"]      := SM0->M0_CGC
	oTermsAccept["cUserId"]   := MPUSR_USR->USR_ID // __cUserID
	oTermsAccept["cUserName"] := Trim(MPUSR_USR->USR_NOME) // cUsername
	oTermsAccept["UserEmail"] := TRIM(UsrRetMail(MPUSR_USR->USR_ID))
	oTermsAccept["idTerm"]    := cTermsVers
	oTermsAccept["cnpjAll"]   := cCNPJ

	aAdd(aHeadOut, "Content-Type: application/json")
	aAdd(aHeadOut, "x-access-token: D9A58469-7B5E-477B-83A8-B7FD463CB241")
	aAdd(aHeadOut, "User-Agent: Protheus " + GetBuild())

	oRest:SetPostParams(EncodeUTF8(FwJsonSerialize(oTermsAccept)))
	lRet := oRest:Post(aHeadOut)

	If (!lRet)
		Help(Nil, Nil, "WIZSMARTBA", "REST_ERROR", STR0014, 1,,,,,,, { STR0015 } )	// "Erro ao enviar aceite de termos de serviço."###"Por favor tente novamente em alguns instantes ou contate o suporte caso o erro persista."
	Endif

	FWFreeArray( aHeadOut ) 
	FreeObj( oTermsAccept )
	FreeObj( oRest )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BuscaCNPJ
Busca todos CNPJs da empresa e retorna em uma string no formato de json
@type function
@version  
@author raphael.santana
@since 10/06/2024
@return caracter, CNPJs disponíveis no cadastro de empresas
/*/
//-------------------------------------------------------------------------------------
Static Function BuscaCNPJ()
	Local cRet  as Character
	Local cCNPJ as Character
	Local aFil  as Array
	Local nI    as Numeric

	aFil    := FWLoadSM0( .F., .F. )
	cCNPJ   := ""

	For nI:=1 To len( aFil )
		If Empty( aFil[nI][17] ) .OR. len( Alltrim( aFil[nI][18] ) ) <> 14 .OR. Empty( aFil[nI][22] )
			loop
		endif

		If At( aFil[nI][18], cCNPJ ) == 0 
			cCNPJ += '"' + aFil[nI][18] +'",'
		EndIf
	next nI

	cRet := '{"cnpj":[' + SubStr( cCNPJ, 1, Len( cCNPJ ) - 1 ) + ']}'

	FWFreeArray( aFil )
Return cRet 
