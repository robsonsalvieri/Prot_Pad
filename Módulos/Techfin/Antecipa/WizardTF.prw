#include "protheus.ch"
#include "totvs.ch"
#include "WizardTF.ch"

#DEFINE DEFAULT_MOTBX      "MPR"
#DEFINE DEFAULT_DESC_MOTBX "MAIS PRAZO"

//DEFINES para a gestão de procedures
#DEFINE DEF_SPS_FROM_RPO 		"1"
#DEFINE DEF_SPS_UPDATED			"0"

Static __lMotInDb As Logical

/*/{Protheus.doc} WizardTF
Wizard para ativação da integração com a TechFin

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
/*/

Main Function WizardTF1()

	MsApp():New( "SIGAFIN" )
	oApp:cInternet  := Nil
	__cInterNet := NIL
	oApp:bMainInit  := { || ( oApp:lFlat := .F. , TechFinWiz() , Final( "Encerramento Normal" , "" ) ) } //"Encerramento Normal"
	oApp:CreateEnv()
	OpenSM0()

	PtSetTheme( "TEMAP10" )
	SetFunName( "WIZARDTF1" )
	oApp:lMessageBar := .T.

	oApp:Activate()	

Return Nil


/*/{Protheus.doc} TechFinWiz
Montagem do Step do FWCarolWizard para ativação da integração com a TechFin

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
/*/

Static Function TechFinWiz()

	Local oWizard       As Object
	Local cDescription  As Character
	Local cReqMsg       As Character
	Local cReqDes       As Character
	Local cReqCont      As Character
	local cReqLib       As Character
	Local bConstruction As CodeBlock
	Local bProcess      As CodeBlock
	Local bNextAction   As CodeBlock
	Local bReqVld       As CodeBlock
	local bReqlib       As CodeBlock
	Private cStep       As Character

	nStep := 1
	
	oWizard := FWCarolWizard():New()

	cDescription   := STR0001
	bConstruction  := { | oPanel | cStep := StepProd(oPanel,oWizard)}
	bProcess       := { | cGrpEmp, cMsg | IIf(cStep == "TOTVS Antecipa", FinTFWizPg(), IIf(cStep == "TOTVS Analytics", .T., IIf(cStep == "TOTVS Mais Prazo", ProcAnt( cGrpEmp, cStep), IIF(cStep == "TOTVS Mais Negócios", RSKA110(), .T.))))}
	bNextAction    := { || VldStep(cStep, oWizard)}
	cReqDes        := STR0002 //"Release do RPO"
	cReqCont       := GetRpoRelease()
	bReqVld        := { || GetRpoRelease() >= "12.1.033"}
	cReqMsg        := STR0003 //"Versão de RPO deve ser no mínimo 12.1.33"
	cReqLib        := FwtechfinVersion()
	bReqlib        := { || FwtechfinVersion() >= "2.4.0" }

	oWizard:SetWelcomeMessage( STR0004 + CRLF + CRLF + STR0055 ) // "Boas vindas." // "Este Wizard irá auxiliá-lo na configuração da integração entre o sistema Protheus e a TOTVS Carol."
	oWizard:AddRequirement( cReqDes, cReqCont, bReqVld, cReqMsg )
	oWizard:AddRequirement( STR0033, cReqLib, bReqlib, STR0034 ) //"Versão" ## "Atualize a Lib para versão 2.4.0 ou superior."
	oWizard:AddStep( cDescription, bConstruction, bNextAction)
	oWizard:AddProcess( bProcess )
	oWizard:UsePlatformAccess(.T.)
    IF cReqLib >= "2.4.0"
		oWizard:SetExclusiveCompany(.F.)
	EndIf
	oWizard:SetCountries({"ALL"})
	oWizard:Activate()

Return Nil

/*/{Protheus.doc} StepProd
Montagem tela para escolha do Produto a Ser configurado

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Character, Retorna o codigo do Produto
/*/

Static Function StepProd(oPanel,oWizard) as Character

	Local cRet as Character
	Local nI as Numeric

	nI := 0
	aMarkedGrp := {}

	aGrpEmp		:= oWizard:GetSelectedGroups()

	For nI:=1 to Len(aGrpEmp)
		If aGrpEmp[nI,1]
			Aadd(aMarkedGrp,aGrpEmp[nI,2])
		EndIF
	Next nI

	RpcSetType(3)
	RpcSetEnv(aMarkedGrp[1],,,,'FIN',,,.T.)

	IF cPaisLoc == "BRA"
		cRet := StepWiz()
		@ 072, 010 SAY STR0005 +Space(1)+ cRet SIZE 200,20 OF oPanel PIXEL
	Else
		cRet := "Gesplan"
		@ 072, 010 SAY STR0071 SIZE 300,20 OF oPanel PIXEL //Somente o produto Gesplan está disponível para ser configurado neste ambiente devido à localização da instalação.
	EndIf
	
	@ 138, 010 SAY STR0006 SIZE 200,20 OF oPanel PIXEL

Return cRet

/*/{Protheus.doc} ProcAnt() 
Rotina de Processamento da gravaçao dos parâmetros

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@param      cGrpEmp, character, código do grupo da Empresa
@param      cStep, character, produto a ser configurado
@return     Logical, Sucesso ou insucesso da operação
/*/

Static Function ProcAnt( cGrpEmp as Character, cStep as Character) as Logical

	Local aMotBx      As Array
	Local aDescMotbx  As Array
	Local lRet        As Logical
	Local lExistBxMpr As Logical
	Local nI          As Numeric
	Local oDlg        As Object
	Local oCbx        As Object
	Local oGrp        As Object

	Local cMvPrefixo  As Character
	Local cMvTipo     As Character
	Local cMvMotBx    As Character
	Local cMvNaturez  As Character
	Local cMvFornece  As Character
	Local cMvLoja     As Character
	Local cMvValAce   As Character

	Private cPref     As Character
	Private cTipo     As Character
	Private cNat      As Character
	Private cForn     As Character
	Private cLoja     As Character
	Private cMotBx    As Character
	Private cCodVa    As Character
	Private cDescVa   As Character
	Private lExistSED   As Logical
	Private lExistSA2   As Logical
	Private lExistFKC   As Logical

	LimMotRead()
	aMotBx      := ReadMotBx()
	aDescMotbx  := {}
	nI          := 1
	lExistBxMpr := .T.
	lRet        := .T.

	SUPERGETMV() // Para Limpar o cache do Supergetmv

	//Retorna o Array aDescMotBx contendo apenas a descricao do motivo das Baixas
	For nI := 1 to Len( aMotBx )
		If SubStr(aMotBx[nI],34,01) == "P"
			aAdd(aDescMotbx,SubStr(aMotBx[nI],01,3))
		EndIf
	Next nI

	If aScan(aDescMotbx, {|x| x == DEFAULT_MOTBX}) == 0 //MPR
		lExistBxMpr := .F.
		aAdd(aDescMotbx, DEFAULT_MOTBX) //MPR
	EndIf

	cMvPrefixo := SuperGetMV("MV_PRETECF", .F., "")
	cMvTipo    := SuperGetMV("MV_TPTECF" , .F., "")
	cMvNaturez := SuperGetMV("MV_NTTECF" , .F., "")
	cMvFornece := SuperGetMV("MV_FNTECF" , .F., "")
	cMvLoja    := SuperGetMV("MV_LFTECF" , .F., "")
	cMvMotBx   := SuperGetMV("MV_MBXTECF", .F., "")
	cMvValAce  := SuperGetMV("MV_VATECF" , .F., "")

	cPref      := If(Empty(cMvPrefixo), Space(TamSX3("E2_PREFIXO")[1]), PadR(AllTrim(cMvPrefixo), TamSX3("E2_PREFIXO")[1]))
	cTipo      := If(Empty(cMvTipo)   , Space(TamSX3("E2_TIPO"   )[1]), PadR(AllTrim(cMvTipo)   , TamSX3("E2_TIPO"   )[1]))
	cNat       := If(Empty(cMvNaturez), Space(TamSX3("ED_CODIGO" )[1]), PadR(AllTrim(cMvNaturez), TamSX3("ED_CODIGO" )[1]))
	cForn      := If(Empty(cMvFornece), Space(TamSX3("A2_COD"    )[1]), PadR(AllTrim(cMvFornece), TamSX3("A2_COD"    )[1]))
	cLoja      := If(Empty(cMvLoja)   , Space(TamSX3("A2_LOJA"   )[1]), PadR(AllTrim(cMvLoja)   , TamSX3("A2_LOJA"   )[1]))
	cCodVa     := If(Empty(cMvValAce) , Space(TamSX3("FKC_CODIGO")[1]), PadR(AllTrim(cMvValAce) , TamSX3("FKC_CODIGO")[1]))
	cMotBx     := If(Empty(cMvMotBx)  , DEFAULT_MOTBX                 , PadR(AllTrim(cMvMotBx)  , 3))

	lExistSED  := If(Empty(cMvNaturez), .F., CheckParam("SED", {cMvNaturez}))
	lExistSA2  := If(Empty(cMvFornece) .And. Empty(cMvLoja), .F., CheckParam("SA2", {cMvFornece, cMvLoja}))
	lExistFKC  := If(Empty(cMvValAce), .F., CheckParam("FKC", {cMvValAce}))
	
	If ValidParam()

		DEFINE MSDIALOG oDlg TITLE STR0007 STYLE DS_MODALFRAME FROM 180,180 TO 470,700 PIXEL
		oDlg:lEscClose := .F.

		@ 000,005 GROUP oGrp TO 117,255 LABEL STR0008 PIXEL

		@ 012, 010 SAY STR0009 SIZE 200,20 OF oDlg PIXEL //"Prefixo"
		@ 010, 053 MSGET cPref SIZE 59, 09 OF oDlg PIXEL WHEN .T. PICTURE "@!" VALID !VAZIO()

		@ 027, 010 SAY STR0010 SIZE 200,20 OF oDlg PIXEL //"Tipo"
		@ 027, 053 MSGET cTipo SIZE 59, 09 OF oDlg  PIXEL F3 "05" WHEN .T. PICTURE "@!" VALID !VAZIO()

		@ 044, 010 SAY STR0011 SIZE 200,20 OF oDlg PIXEL //"Natureza"
		@ 044, 053 MSGET cNat SIZE 59, 09 OF oDlg PIXEL WHEN .T. VALID Vazio() .Or. ExistCpo("SED",cNat) PICTURE "@!"
		@ 044, 115 BUTTON oBtnClient PROMPT STR0044 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN .T. ACTION ( SetAction( "SED", .T. ) )    //"Pesquisar"
		@ 044, 150 BUTTON oBtnClient PROMPT STR0045 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN !lExistSED ACTION ( SetAction( "SED", .F. ) )    //"Incluir"

		@ 061, 010 SAY STR0012 SIZE 200,20 OF oDlg PIXEL //"Fornec./Loja"
		@ 061, 053 MSGET cForn SIZE 40, 09 OF oDlg PIXEL WHEN .T. VALID Vazio() .Or. ExistCpo("SA2",cForn) PICTURE "@!"
		@ 061, 095 MSGET cloja SIZE 15, 09 OF oDlg PIXEL WHEN !Empty(cForn) VALID Vazio() .Or. ExistCpo("SA2",cForn+cLoja) PICTURE "@!"
		@ 061, 115 BUTTON oBtnClient PROMPT STR0044 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN .T. ACTION ( SetAction( "SA2", .T. ) )    //"Pesquisar"
		@ 061, 150 BUTTON oBtnClient PROMPT STR0045 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN !lExistSA2 ACTION ( SetAction( "SA2", .F. ) )    //"Incluir"

		@ 078, 010 SAY STR0050 SIZE 200,20 OF oDlg PIXEL //"Valor Acessório"
		@ 078, 053 MSGET cCodVa SIZE 59, 09  OF oDlg PIXEL WHEN .T. VALID Vazio() .Or. ExistCpo("FKC",cCodVa) PICTURE "@!"
		@ 078, 115 BUTTON oBtnClient PROMPT STR0044 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN .T. ACTION ( SetAction( "FKC", .T. ) )    //"Pesquisar"
		@ 078, 150 BUTTON oBtnClient PROMPT STR0045 SIZE 30, 11 OF oDlg PIXEL ;
			WHEN !lExistFKC ACTION ( SetAction( "FKC", .F. ) )    //"Incluir"

		@ 095, 010 SAY STR0014 SIZE 200,20 OF oDlg PIXEL //"Motivo Baixa"
		@ 095, 053 MSCOMBOBOX oCbx VAR cMotBx ITEMS aDescMotbx SIZE 59,35 OF oDlg PIXEL

		@ 120, 110 BUTTON STR0017 SIZE 030, 025 PIXEL OF oDlg ACTION ( If(GravaPar(lExistBxMpr), oDlg:End(),.F.))

		ACTIVATE DIALOG oDlg CENTERED

	Endif

	lRet := ValidParam()

Return lRet

/*/{Protheus.doc} Gravapar
Rotina de Validação e gravação dos parâmetros

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Logical, Sucesso ou insucesso da operação
/*/

Static Function GravaPar(lExistBxMpr As Logical) As Logical

	Local lRet     as Logical
	Local cPeriod  as Character
	Local cAgend   as Character
	Local cMsgErro as Character

	cPeriod  := ""
	cAgend   := ""
	cMsgErro := ""
	lRet     := !Empty(cPref) .And. !Empty(cTipo) .And. !Empty(cNat) .And. !Empty(cForn) .And. !Empty(cLoja) .And. !Empty(cCodVa) .And. !Empty(cMotBx)

	If lRet
		If !lExistBxMpr .And. !IncMotBx()
			Help(Nil, Nil, "MOTBX", "", STR0051, 1,;
				,,,,,,{STR0052}) //"Não foi possível incluir o motivo de baixa MPR automaticamente." ## "Será necessário realizar o cadastro manualmente."
		EndIf

		If Len(alltrim(cPref)) > TamSX3("E2_PREFIXO")[1]
			Help(Nil, Nil, "NONAT", "", STR0018 + FWCompany() , 1,;
				,,,,,,{STR0019})
		else
			PUTMV("MV_PRETECF" , PADR(alltrim(cPref), TamSX3("E2_PREFIXO")[1]))   //Prefixo
		Endif

		dbSelectArea('SX5')
		dbSetOrder(1)
		If dbSeek(xFilial('SX5')+"05"+ PADR(alltrim(cTipo), TamSX3("E2_TIPO")[1]))
			PUTMV("MV_TPTECF"  , PADR(alltrim(cTipo), TamSX3("E2_TIPO")[1]))   //Tipo
		Else
			Help(Nil, Nil, "TIPTIT", "", STR0020 + FWCompany() , 1,;
				,,,,,,{STR0021})
		EndIf

		Dbselectarea("SED")
		dbSetOrder(1)
		Dbgotop()
		If dbseek(FwxFilial("SED")+ PADR(alltrim(cNat), TamSX3("ED_CODIGO")[1]))
			PUTMV("MV_NTTECF"  , PADR(alltrim(cNat), TamSX3("ED_CODIGO")[1]))   //Natureza
		else
			Help(Nil, Nil, "NONAT", "", STR0022 + FWCompany() , 1,;
				,,,,,,{STR0023})
		Endif

		DbSelectArea("SA2")
		DbSetorder(1)
		DbGotop()
		If dbseek(FwxFilial("SA2")+ PADR(alltrim(cForn), TamSX3("A2_COD")[1])+PADR(alltrim(cLoja), TamSX3("A2_LOJA")[1]))
			PUTMV("MV_FNTECF"  , PADR(alltrim(cForn), TamSX3("A2_COD")[1]))   //Fornecedor
			PUTMV("MV_LFTECF"  , PADR(alltrim(cLoja), TamSX3("A2_LOJA")[1]))   //Loja
		else
			Help(Nil, Nil, "NOFOR", "", STR0024 + FWCompany() , 1,;
				,,,,,,{STR0025})
		Endif

		PUTMV("MV_MBXTECF" , PADR(alltrim(cMotBx), TamSX3("FK1_MOTBX")[1]))   //Motivo de Baixa

		DbSelectArea("FKC")
		DbSetorder(1)
		DbGotop()

		PUTMV("MV_VATECF"  , PADR(alltrim(cCodVa), TamSX3("FKC_CODIGO")[1]))   //Codigo Valores AcessÃƒÂ³rios

		If !(ExisteJob())
			//Executa a cada 10 minutos
			cPeriod := "D(Each(.T.);Day(1);EveryDay(.F.););Execs(0144);Interval(00:10);"
			//(cFunction, cUserID, cParam, cPeriod, cTime, cEnv, cEmpFil, cStatus, dDate, nModule, aParamDef)
			cAgend := FwInsSchedule("FINA137F", "000000",, cPeriod, "00:00", Upper(GetEnvServer()), cEmpAnt + "/" + cFilAnt + ";","0", Date(), 6, {cEmpAnt, cFilAnt, "TESTE"})
			If Empty(cAgend)
				cMsgErro :=  STR0026
				FwLogMsg("INFO",, "SCHEDULER", FunName(), "", "01", cMsgErro, 0, 0, {})
			EndIf
		EndIf	
	EndIf

Return lRet

/*/{Protheus.doc} ValidParam
Rotina de Validação dos Parametros TOTVS Mais Prazo

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Logical, Sucesso ou insucesso da operação
/*/

Static Function ValidParam() As Logical

	Local lExiste   As Logical

	lExiste := .T.

	If !(GetMV("MV_PRETECF", .T.)) .Or. !(GetMV("MV_TPTECF", .T.)) .Or. !(GetMV("MV_NTTECF", .T.)) .Or.;
			!(GetMV("MV_FNTECF", .T.)) .Or. !(GetMV("MV_LFTECF", .T.)) .Or. !(GetMV("MV_MBXTECF", .T.)) .Or. !(GetMV("MV_VATECF", .T.))
		lExiste := .F.
		Help(Nil, Nil, "NOPARAM", "", STR0027 + FWCompany() , 1,; //"Um ou mais parÃƒÂ¢metros Financeiros do TOTVS Antecipa nÃƒÂ£o foram encontrados."
		,,,,,,{STR0028}) // "Execute o UPDDISTR de acordo com a ÃƒÂºltima expediÃƒÂ§ÃƒÂ£o contÃƒÂ­nua para criaÃƒÂ§ÃƒÂ£o dos parÃƒÂ¢metros Financeiros do TOTVS Antecipa."
	EndIf

Return lExiste

/*/{Protheus.doc} Stepwiz()
Rotina de Escolha do Produto

@author     Victor Furukawa
@version    1.0
@type       Function
@since      28/01/2021
@return     Character, Codigo do produto a ser configurado
/*/

Static Function Stepwiz() As Character
	Local aOptions As Array
	Local cRet     As Character
	Local nRadio   As Numeric
	Local oButton  As Object
	Local oDlg     As Object
	Local oRadio   As Object

	aOptions := {"Gesplan","TOTVS Antecipa", "TOTVS Analytics", "TOTVS Mais Negócios","TOTVS Mais Prazo"}
	nRadio   := 1

	DEFINE MSDIALOG oDlg FROM 0,0 TO 160,245 STYLE DS_MODALFRAME PIXEL TITLE STR0029
	oDlg:lEscClose := .F.
	oRadio := tRadMenu():New(9,12,aOptions, {|u|if(PCount()>0,nRadio:=u,nRadio)},oDlg,,,,,,,,100,20,,,,.T.)
	@ 60,25 BUTTON oButton PROMPT STR0030 OF oDlg PIXEL ACTION oDlg:End() //"Confirmar"
	ACTIVATE MSDIALOG oDlg CENTERED

	cRet := aOptions[nRadio]

	FwFreeArray(aOptions)
	FwFreeObj(oButton)
	FwFreeObj(oDlg)
	FwFreeObj(oRadio)
Return cRet 


/*/{Protheus.doc} ExisteJob
Verifica se o JOB existe no grupo de empresa atual.

@type       Function
@author     Victor Furukawa
@since      05/11/2020
@version    P12.1.27
@param      cAgendamen, character, código do agendamento
@return     logical, verdadeiro caso encontre o job para empresa desejada
@obs        rotina possui referência direta as tabelas de framework XX1 e XX2 pois não existe função que atenda a este requisito. A issue DFRM1-16827 foi aberta para este propósito
/*/
Static Function ExisteJob() As Logical

	Local aSchd       As Array
	Local lCriado     As Logical
	Local oDASched    As Object
	Local nX          As Numeric

	lCriado := .F.

	oDASched := FWDASchedule():New() //chama o objeto do schedule
	aSchd:=oDASched:readSchedules() //como voce não sabe quem é, tem que ler todos

	For nX := 1 to Len(aSchd)

		If Alltrim(aSchd[nX]:GetFunction())== 'FINA137F' .And. aSchd[nX]:GetEmpFil() == AllTrim(cEmpAnt) + "/" + AllTrim(cFilAnt) + ";"
			lCriado := .T.
		Endif

	Next

Return lCriado

/*/{Protheus.doc} VldStep
Retorna um aviso para que o usuario esteja ciente para verificar o compartilhamento das tabelas SA2 e SED.

@type       Function
@author     Victor Furukawa
@since      05/11/2020
@version    P12.1.27
@return     Character, Retorna o codigo do valor acessório
/*/
Static Function VldStep(cOpc As Character, oWizard As Object) As Logical

	Local cPeriodo	 As Character
	Local cTime		 As Character
	Local cTaskID	 As Character
	Local lRet       As Logical
	Local lCheck     AS Logical
	Local lPrjover   As Logical
	Local lFIntGes   As Logical
	Local lContinua  As Logical
	Local lExistPrj  As Logical
	Local lExistFIn  As Logical
	Local lExistJob  As Logical
	Local oDlg    	 As Object
	Local oChkBox 	 As Object
	Local cUser   	 As Character
	Local cSenha  	 As Character
	Local aGrpEmp 	 As Array
	Local aSM0		 As Array
	Local cMarkedGrp As Character
	Local nI		 As Numeric
	Local nX		 As Numeric

	cPeriodo	:= 'A'
    cTime 		:= '00:00'
	cTaskID 	:= FwSchdByFunction("FINXGES")
	cMarkedGrp	:= ""
	lRet      	:= .T.
	lCheck    	:= .F.
	lPrjover  	:= SuperGetMv("MV_PRJOVER",.F.,.F.)
	lFIntGes  	:= SuperGetMv("MV_FINTGES",.F.,.F.)
    lok       	:= .F.
	cUSer     	:= Space(30)
	cSenha    	:= Space(30)	
	lContinua 	:= .T.
	lExistPrj 	:= .F.
	lExistFIn 	:= .F.
	lExistJob 	:= FindFunction("FINXGES")
	aSM0		:= FWLoadSM0()
	aGrpEmp		:= {}
	nI			:= 0
	nX			:= 0

    If Alltrim(cOpc) == "Gesplan" 
		
		If GetApoInfo("finxnat.prx")[4] >=CtoD('07/11/2022') .And. GetApoInfo("finxfin.prx")[4]>=CtoD('07/11/2022')

			aGrpEmp		:= oWizard:GetSelectedGroups()

			lExistPrj := CheckParam("SX6",{"MV_PRJOVER"})
			lExistFIn := CheckParam("SX6",{"MV_FINTGES"})

			If lExistPrj .AND. lExistFIn 
				If !lPrjover .Or. !lFIntGes
					MessageBox(STR0057,STR0056, 0) // "Necessário que os parâmetros MV_PRJOVER e MV_FINTGES estejam ativos (.T.)"
					lContinua := .F.
				EndIF
			Else
				If !lExistPrj
					MessageBox(STR0059,STR0056, 0) //"Necessário criar o parâmetro MV_PRJOVER do tipo lógico e seu conteúdo estar ativo (.T.)"
					lContinua := .F.
				EndIf

				If !lExistFIn
					MessageBox(STR0060,STR0056, 0) //"Necessário criar o parâmetro MV_FINTGES do tipo lógico e seu conteúdo estar ativo (.T.)"
					lContinua := .F.
				EndIf
			EndIf

			If lExistJob
				//ordena o array de filial por grupo e código de filial
				aSM0 := aSort(aSM0,,,{|X,Y| X[1]+X[2] < Y[1]+Y[2]})
				For nI := 1 to Len(aGrpEmp)
					If aGrpEmp[nI,1]
						cFindEmp := aGrpEmp[nI,2] 

						//posiciona no primeiro registro do grupo logado
						nX := aScan(aSM0,{|X| X[1] == cFindEmp})
						cMarkedGrp += aSM0[nX,1] + "/" + aSM0[nX,2] + ";"

						lContinua := VldProced(cFindEmp)

						If !lContinua
							Exit	
						EndIf
					EndIf
				Next nI
			EndIf

			If lContinua

				DEFINE MSDIALOG oDlg FROM 0,0 TO 220,350 STYLE DS_MODALFRAME PIXEL TITLE STR0061+" "+Alltrim(cOpc) //Produto selecionado: 
				oDlg:lEscClose := .F.

				@ 07,10 SAY STR0062 SIZE 200,20 OF oDlg PIXEL  //UPDDISTR será executado em modo exclusivo para criação 
				@ 17,10 SAY STR0063 SIZE 200,20 OF oDlg PIXEL //dos campos da integração. Necessário logar novamente.					
				
				@ 33,10 CHECKBOX oChkBox VAR lok PROMPT STR0064 SIZE 60,15 OF oDlg PIXEL //Estou Ciente!
				@ 52,10 say STR0065 SIZE 200,20 OF oDlg PIXEL //Usuário
				@ 60,10 MSGET cUSer SIZE 56, 09 OF oDlg PIXEL WHEN .T. 
				@ 52,81 say STR0066 SIZE 200,20 OF oDlg PIXEL //Senha 
				@ 60,81 GET oSenha VAR cSenha PASSWORD  SIZE 56, 09 OF oDlg PIXEL WHEN .T.			

				@ 85,10 BUTTON oButton PROMPT STR0067 OF oDlg PIXEL ACTION (lok := .F. , lRet:=.F. , oDlg:End()) //Voltar
				@ 85,80 BUTTON oButton PROMPT STR0068 OF oDlg PIXEL ACTION Iif(lok .and. VldStepUsr(Alltrim(cUSer),Alltrim(cSenha)) , oDlg:End(), Nil ) //Avançar

				ACTIVATE MSDIALOG oDlg CENTERED

				If lok 
					If (lRet := MyOpenSm0Ex())
						LoadMsgUpd({||lRet:=WzGerGes(aGrpEmp,Alltrim(cSenha))},STR0040,STR0039+ CRLF + STR0069) //Processando","Compatibilizando ambiente.... Este processo pode demorar. Aguarde!
					EndIf

					If lRet .And. lExistJob .And. Empty(cTaskID)
						FwInsSchedule("FINXGES", "000000",, cPeriodo, cTime, Upper(GetEnvServer()), cMarkedGrp,"0", Date(), 6, NIL) 
					EndIf
				EndIf
			Else
				lRet:=.F.
			EndIf
		Else
			//"A data dos fontes FINXFIN.PRW e FINXNAT.PRW deve ser superior ou igual a 07/11/2022. Atualize a lib para poder prosseguir.", "Integração Gesplan"
			MessageBox(STR0054, STR0053 , 0) 
			lRet:=.F.
		EndIF
	Else
		DEFINE MSDIALOG oDlg FROM 0,0 TO 170,550 STYLE DS_MODALFRAME PIXEL TITLE STR0061+" "+Alltrim(cOpc) //Produto selecionado:
		oDlg:lEscClose := .F.

		@ 15,17 SAY STR0072 SIZE 255,15 OF oDlg PIXEL //"Por favor, verifique o compartilhamento dos cadastros, especialmente os de Natureza e Fornecedor."
		@ 25,17 SAY STR0073 SIZE 255,15 OF oDlg PIXEL //"A partir deste momento, os dados serão compartilhados com a TOTVS TECHFIN."

		@ 43,17 CHECKBOX oChkBox VAR lCheck PROMPT STR0074 SIZE 60,15 OF oDlg PIXEL //"Estou ciente!"

		@ 60,100 BUTTON oButton PROMPT STR0030 OF oDlg PIXEL ACTION Iif(lCheck, oDlg:End(), "") //"Confirmar"
		ACTIVATE MSDIALOG oDlg CENTERED
    EndIf

Return lRet

/*/{Protheus.doc} SetAction
Função executada ao clicar no botão Pesquisar ou Incluir.
Esta função é responsável por chamar o MBrowse ou AxInclui.

@type  StaticFunction
@author  Claudio Yoshio Muramatsu
@since   01/11/2022
@param cTabOri, character, tabela que será utilizada
@param lPesquisa, logical, informa se a ação é de pesquisa
/*/
Static Function SetAction(cTabOri As Character, lPesquisa As Logical)
	Local aArea      As Array
	Local cFilBrowse As Character

	Private aRotina   As Array
	Private cCadastro As Character
	Private cTabAlias As Character

	Default lAutomato := .F.
	
	aArea      := GetArea()
	cFilBrowse := ""

	cCadastro := ""
	aRotina   := MenuDef()
	cTabAlias := cTabOri

	If cTabAlias == "SED"
		cCadastro  := STR0046 //"Configuração da Natureza"
		cFilBrowse := "ED_FILIAL == '" + xFilial("SED") + "'"
	ElseIf cTabAlias == "SA2"
	 	cCadastro := STR0047 //"Configuração do Fornecedor"
		cFilBrowse := "A2_FILIAL == '" + xFilial("SA2") + "'"
	ElseIf cTabAlias == "FKC"
	 	cCadastro := STR0048 //"Configuração do Valor Acessório"
		cFilBrowse := "FKC_FILIAL == '" + xFilial("FKC") + "'"
	EndIf

	If lPesquisa
		mBrowse(6,1,22,75,cTabAlias,,,,,,,,,,,,,,,,,,cFilBrowse)
	Else
		WizTFInclu()
	EndIf

	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aRotina )
Return

/*/{Protheus.doc} SetFldEnch
Função responsável em atribuir um conteúdo padrão aos campos da enchoice.

@type  StaticFunction
@author  Claudio Yoshio Muramatsu
@since   01/11/2022
/*/
Static Function SetFldEnch()
	Local aContent As Array
	Local nItem    As Numeric

	aContent := {}
	nItem    := 0

	If cTabAlias == "SED"
		aContent := { ;
						{ 'ED_CODIGO' , 'MAISPRAZO' }, ;
						{ 'ED_DESCRIC', 'MAIS PRAZO' }, ;
						{ 'ED_COND'   , 'D' } }
	ElseIf cTabAlias == "SA2"
		// Nunca traduzir estes dados, pois são os dados de cadastro da Supplier
		aContent := { ;
						{ 'A2_COD'    , 'SUPPLI' }, ;
						{ 'A2_LOJA'   , '01' }, ;
						{ 'A2_NOME'   , 'CARTAO DE COMPRA SUPPLIERCARD FUNDO DE INVESTIMENTO EM DIREITOS CREDITORIOS' }, ;
						{ 'A2_NREDUZ' , 'SUPPLIER' }, ;
						{ 'A2_CGC'    , '08692888000182' }, ;
						{ 'A2_END'    , 'AV DAS AMERICAS, 500' }, ;
						{ 'A2_COMPLEM', 'BL13 GRUPO 205 - COD. DOWNTOWN' }, ;
						{ 'A2_MUN'    , 'RIO DE JANEIRO' }, ;
						{ 'A2_BAIRRO' , 'BARRA DA TIJUCA' }, ;
						{ 'A2_EST'    , 'RJ' }, ;
						{ 'A2_CEP'    , '22640100' }, ;
						{ 'A2_TIPO'   , 'J' }, ;
						{ 'A2_INSCR'  , 'ISENTO' } }
	ElseIf cTabAlias == "FKC"
		aContent := { ;
						{ 'FKC_CODIGO' , 'MP0001' }, ;
						{ 'FKC_DESC'   , 'VA MAIS PRAZO' }, ;
						{ 'FKC_ACAO'   , '1' }, ;
						{ 'FKC_TPVAL'  , '2' }, ;
						{ 'FKC_APLIC'  , '3' }, ;
						{ 'FKC_PERIOD' , '1' }, ;
						{ 'FKC_ATIVO'  , '1' }, ;
						{ 'FKC_RECPAG' , '1' }, ;
						{ 'FKC_VARCTB' , 'MPR001' } }	
	EndIf

	For nItem := 1 to Len(aContent)
		M->&(aContent[nItem][1]) := aContent[nItem][2]
	Next

	FWFreeArray(aContent)
Return Nil

/*/{Protheus.doc} MenuDef
Menu funcional da rotina de cadastros (Natureza, Fornecedor, Valores Acessórios)

@type  StaticFunction
@author Daniel Moda
@since 19/07/2022
@return Array, Opções do Menu
/*/
Static Function MenuDef() As Array
	Local aRotina As Array

	aRotina := {{"Selecionar" ,"WizTFSelec" ,0, 6, 0, Nil},; //"Selecionar"
				{"Visualizar" ,"AxVisual"   ,0, 2, 0, Nil}}  //"Visualizar"
Return aRotina

/*/{Protheus.doc} WizTFSelec
Botão chamado quando é selecionado um cadastro no Mbrowse
@type  Function
@author Claudio Yoshio Muramatsu
@since 01/11/2022
/*/
Function WizTFSelec()
	SetParamVar()	
	CloseBrowse()
Return Nil

/*/{Protheus.doc} WizTFInclu
Botão chamado na inclusão de um cadastro no Mbrowse

@type  Function
@author Claudio Yoshio Muramatsu
@since 01/11/2022
/*/
Function WizTFInclu()
	Local aParam  As Array

	aParam := Array(4)
	aParam[1] := {|| SetFldEnch()}
	aParam[2] := {|| .T. }
	aParam[3] := {|| .T. }
	aParam[4] := {|| .T. }
	
	If AxInclui( cTabAlias, , , , , , "WizTFTudOk()", , , , aParam ) == 1
		SetParamVar()
		If cTabAlias == "SED"
			lExistSED := .T.
		ElseIf cTabAlias == "SA2"
			lExistSA2 := .T.
		ElseIf cTabAlias == "FKC"
			lExistFKC := .T.
		EndIf
	EndIf

	FwFreeArray(aParam)
Return

/*/{Protheus.doc} SetParamVar
Atribui valor nas variáveis da tela com o conteúdo do registro selecionado

@type  Function
@author Claudio Yoshio Muramatsu
@since 01/11/2022
/*/
Static Function SetParamVar()
	If cTabAlias == "SED"
		cNat := SED->ED_CODIGO
	ElseIf cTabAlias == "SA2"
		cForn := SA2->A2_COD
		cLoja := SA2->A2_LOJA
	ElseIf cTabAlias == "FKC"
		cCodVa := FKC->FKC_CODIGO
	EndIf
Return

/*/{Protheus.doc} WizTFTudOk
Função para validação na confirmação da inclusão dos cadastros

@type  Function
@author Claudio Yoshio Muramatsu
@since 01/11/2022
@return Logical, indica se o registro em questão existe no banco de dados.
/*/
Function WizTFTudOk() As Logical
	Local lRet As Logical
	
	lRet := .T.

	If (cTabAlias == "SED" .And. CheckParam(cTabAlias,{M->ED_CODIGO})) .Or. ;
	   (cTabAlias == "SA2" .And. CheckParam(cTabAlias,{M->A2_COD,M->A2_LOJA})) .Or. ;
	   (cTabAlias == "FKC" .And. CheckParam(cTabAlias,{M->FKC_CODIGO}))
		
		lRet := .F.
		Help(" ", 1, "CADEXISTE",, STR0049, 1, 0) //"Já existe um cadastro com a chave informada."
	EndIf
Return lRet

/*/{Protheus.doc} CheckParam
Função que verifica se o registro existe no banco de dados.

@type StaticFunction
@author  Claudio Yoshio Muramatsu
@since   01/11/2022
@param cTabOri, character, tabela que será utilizada
@param aInfo, array, armezena os dados da entidade a ser pesquisada
@return Logical, indica se o registro em questão existe no banco de dados.
/*/
Static Function CheckParam(cTabOri As Character, aInfo As Array)
	Local aArea      As Array
	Local cQuery     As Character
	Local cTempAlias As Character
	Local lExist     As Logical

	aArea      := GetArea()
	cQuery     := ""
	cTempAlias := ""
	lExist     := .F.

	If cTabOri == "SED"
		cQuery := "SELECT ED_CODIGO FROM " + RetSqlName("SED") + ;
			" WHERE ED_FILIAL = '" + xFilial("SED") + "' " + ;
			" AND ED_CODIGO = '" + aInfo[ 1 ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	ElseIf cTabOri == "SA2"
		cQuery := "SELECT A2_COD FROM " + RetSqlName("SA2") + ;
			" WHERE A2_FILIAL = '" + xFilial("SA2") + "' " + ;
			" AND A2_COD = '" + aInfo[ 1 ] + "' " + ;
			" AND A2_LOJA = '" + aInfo[ 2 ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	ElseIf cTabOri == "FKC"
		cQuery := "SELECT FKC_CODIGO FROM " + RetSqlName("FKC") + ;
			" WHERE FKC_FILIAL = '" + xFilial("FKC") + "' " + ;
			" AND FKC_CODIGO = '" + aInfo [ 1 ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	ElseIf cTabOri == "SX6"
		cQuery := "SELECT X6_CONTEUD FROM " + RetSqlName("SX6") + ;
			" WHERE X6_VAR = '" + aInfo [ 1 ] + "' " + ;
			" AND D_E_L_E_T_ = ' '"
	EndIf

	IF !Empty(cQuery)
		cQuery := ChangeQuery(cQuery)

		cTempAlias := MPSysOpenQuery(cQuery)
		If (cTempAlias)->(!Eof())
			lExist := .T.
		EndIf
		(cTempAlias)->(DbCloseArea())
	EndIf

	RestArea(aArea)
	FWFreeArray(aArea)
Return lExist

/*/{Protheus.doc} IncMotBx
Inclui o motivo de baixa que será utilizado no Mais Prazo

@type StaticFunction
@author Claudio Yoshio Muramatsu
@since  01/11/2022
@return Logical, Verdadeiro se for incluído
/*/
Static Function IncMotBx() As Logical
	Local aArea      As Array
	Local aCampos    As Array
	Local aMotBaixas As Array
	Local cFile	     As Character
	Local lRet       As Logical

	aArea      := GetArea()
	aCampos    := {}
	aMotBaixas := {}
	cFile	   := "SIGAADV.MOT"
	lRet       := .T.

	// Executa a função de leitura das baixas para forçar a criação do arquivo, caso não exista.
	aMotBaixas := ReadMotBx() 

	If __lMotInDb == Nil
		__lMotInDb := AliasInDic("F7G")
	Endif

	If !__lMotInDb
		aCampos:={	{"SIGLA"	, "C", 03, 0 },;
			{"DESCR"	, "C", 10, 0 },;
			{"CARTEIRA"	, "C", 01, 0 },;
			{"MOVBANC"	, "C", 01, 0 },;
			{"COMIS"	, "C", 01, 0 },;
			{"CHEQUE"	, "C", 01, 0 },;
			{"ESPECIE"	, "C", 01, 0 }	}

		_oFINA4901 := FWTemporaryTable():New( "cArqTmp" )
		_oFINA4901:SetFields( aCampos )
		_oFINA4901:Create()

		cAlias := "cArqTmp"
		dbSelectArea( cAlias )

		APPEND FROM &cFile SDF
		DbGoTop()

		While CARQTMP->( !Eof() )
			If CARQTMP->SIGLA == 'MPR'
				lRet := .F.
				Exit
			EndIf

			CARQTMP->( dbSkip() )
		End

		If ( lRet )

			lRet := .F.

			BEGIN TRANSACTION
			RecLock( cAlias , .T. )
				CARQTMP->Sigla    := DEFAULT_MOTBX //MPR
				CARQTMP->Descr    := DEFAULT_DESC_MOTBX //MAIS PRAZO
				CARQTMP->Carteira := "P"
				CARQTMP->MovBanC  := "N"
				CARQTMP->Comis    := "N"
				CARQTMP->Cheque   := "N"
				CARQTMP->Especie  := "N"
			MsUnLock()

			dbSelectArea( "cArqTmp" )
			FERASE( cFile )
			Copy to &cFile SDF

			lRet := .T.
			END TRANSACTION
		Endif

		RestArea( aArea )
	Else
		lRet := .T.
	Endif

	FWFreeArray( aCampos )
	FWFreeArray( aArea )
	FWFreeArray( aMotBaixas )

	if !__lMotInDb
		FwFreeObj( _oFINA4901 )
	Endif
Return lRet

/*{Protheus.doc} WzGerGes
Executa UPDDISTR para criação de MSUID na SEV e SEZ

@type StaticFunction
@author TOTVS
@since 21/09/2022
@version 1.0
*/
Static Function WzGerGes(aGrpEmp As Array, cSenha As Character) As Logical

Local oX31 		As Object
Local nI     	As Numeric
Local nJ     	As Numeric
Local lContinua As Logical
Local cMsg		As Character
Local cVlr 		As Character
Local cGrpEmp  	As Character
Local cPath	 	As Character
Local cCodPrj	As Character
Local cArquivo 	As Character
Local nHandle 	As Numeric
Local nTamanho	As Numeric
Local aCols 	As Array
Local aMarkedGrp As Array
Local nFildSEV  As Numeric 
Local nFildSEZ  As Numeric 

nI     		:= 0
nJ     		:= 0 
lContinua 	:= .F.
cMsg		:= STR0035//"Classe necessária não encontrada. Atualize a versão da LIB."
cVlr 		:= ''
cGrpEmp  	:= ''
cCodPrj		:= ''
cPath	 	:= GetSystemLoadDir()
cArquivo 	:= cPath+"upddistr_param.json"
nHandle		:= 0
nTamanho 	:= If(AllTrim(Upper(TCGetDB())) == "ORACLE", 32, 36) 
aCols 		:= {{"EZ_MSUID","SEZ"},{"EV_MSUID","SEV"}}
aMarkedGrp	:= {}

dbSelectArea('SEV')
nFildSEV := FieldPos('EV_MSUID')
dbSelectArea('SEZ')
nFildSEZ := FieldPos('EZ_MSUID')

If nFildSEV > 0 .and. nFildSEZ > 0
	lContinua := .T.
Else
For nI:=1 to Len(aGrpEmp)
	If aGrpEmp[nI,1]
		Aadd(aMarkedGrp,aGrpEmp[nI,2])
	EndIF
Next nI

RpcSetType(3)
RpcSetEnv(aMarkedGrp[1],,,,'FIN',,,.T.)

aEval( aMarkedGrp, {|x| Iif( !(x $ cGrpEmp) ,(cGrpEmp += x +'","'), Nil)}) 

cVlr += '{'
cVlr += '    "password":"'+alltrim(cSenha)+'",'
cVlr += '    "simulacao":false,'
cVlr += '    "localizacao":"'+ cPaisLoc +'",'
cVlr += '    "sixexclusive":true,'
cVlr += '    "empresas":["'+Substr(cGrpEmp,1,Len(cGrpEmp)-3)+'"],' //empresas":["T1","T2"],
cVlr += '    "logprocess":true,'
cVlr += '    "logatualizacao":true,'
cVlr += '    "logwarning":true,'
cVlr += '    "loginclusao":true,'
cVlr += '    "logcritical":true,'
cVlr += '    "updstop":false,'
cVlr += '    "oktoall":true,'
cVlr += '    "deletebkp":false,'
cVlr += '    "keeplog":true'
cVlr += '    }'

If File(cArquivo)
	FErase(cArquivo)
EndIf	
If (nHandle := MSFCreate(cArquivo,0)) == -1
	MessageBox(STR0042, STR0041 ,0)//"Falha no processamento" "Falha na criação do dicionário diferencial"
    Return .F.
EndIf
    
FWrite(nHandle,cVlr+CRLF)
FClose(nHandle)

If FindClass("MPX31Field") 

	oX31 := MPX31Field():New("Inclusao de Campos MSUID") //"Inclusao de Campos MSUID"

	If MethIsMemberOf( oX31, 'CreateUUID')

		If File(cPath+'sdf'+cPaisLoc+'.txt') 
			FErase(cPath+'sdf'+cPaisLoc+'.txt')
		EndIf
		For nI := 1 to Len(aCols)
		    If !ExistDir("\cfglog")
                MakeDir("\cfglog")
            EndIf

            oX31:SetAlias(aCols[nI,2])
            oX31:CreateUUID()
            oX31:SetSize(nTamanho)
            oX31:SetOverWrite(.T.)
            If oX31:VldData()
                oX31:CommitData()
                lContinua := .T. 
            EndIf
		Next
		
		If lContinua	
			cCodPrj:=oX31:oPrjResult:cCodProj
			lRetDif:=FWGnFlByTp(cCodPrj,cPath) 

			If lRetDif
                DBCloseAll()
                StartJob("UPDDISTR",GetEnvServer(),.T.)
                For nJ := 1 to len(aMarkedGrp)
                   StartJob("WizGrvGes",GetEnvServer(),.T., aMarkedGrp[nJ] ) 
                Next    
			EndIf		
		EndIf

		FreeObj(oX31)
		oX31 := Nil	
	EndIf
EndIf

FErase(cArquivo)
EndIf
Return lContinua

/*{Protheus.doc} WizGrvGes
Grava o UUID nos campos do rateio

@type StaticFunction
@param cGrpEmp, characters, código da empresa
@return lRet, Logical , Logical validando a carga dos campos UUID nas tabelas SEV e SEZ
@author Fabio Zanchim
@since 06/08/2021
@version 1.0
*/
Function WizGrvGes(cGrpEmp As Character)

Local cSQL 		 As Character
Local cAuxTmp    As Character
Local lFormatUID As Logical
Local oQrySEVS1  As Object
Local oQrySEVS2  As Object
Local oQrySEZS1  As Object
Local oQrySEZS2  As Object

RpcSetType(3)
RpcSetEnv(cGrpEmp,,,,'FIN',,{'SEV','SEZ'},.T.)

cSQL 		:= ""
cAuxTmp     := ""
lFormatUID 	:= If(AllTrim(Upper(TCGetDB())) == "ORACLE", .F., .T.) 

//--------------------------------------
// Rateio Natureza
dbSelectArea('SEV')
If FieldPos('EV_MSUID') > 0

	If oQrySEVS1 == Nil
		cSQL := "SELECT SEV.R_E_C_N_O_ REC FROM ? "
		cSQL += " INNER JOIN ? SEV"
		cSQL += "  ON EV_FILIAL=E1_FILIAL AND EV_PREFIXO=E1_PREFIXO AND "
		cSQL += "     EV_NUM=E1_NUM AND EV_PARCELA=E1_PARCELA AND " 
		cSQL += "     EV_TIPO=E1_TIPO AND EV_CLIFOR=E1_CLIENTE AND "
		cSQL += "     EV_LOJA=E1_LOJA AND EV_RECPAG='R' "
		cSQL += " WHERE E1_EMIS1 >= ? "
		cSQL += "    OR E1_SALDO <> ? "
		cSQL += "    OR E1_BAIXA >= ? "
		cSQL := ChangeQuery(cSQL)
        oQrySEVS1 := FWPreparedStatement():New(cSQL)
	EndIf	

	oQrySEVS1:SetNumeric(1, RetSqlName("SE1"))
	oQrySEVS1:SetNumeric(2, RetSqlName("SEV"))
	oQrySEVS1:SetString(3, Str(Year(Date())-2,4)+"0101")
	oQrySEVS1:SetNumeric(4, 0 )
	oQrySEVS1:SetString(5, Str(Year(Date())-2,4)+"0101") 

	cSQL := oQrySEVS1:GetFixQuery()
	cAuxTmp := MpSysOpenQuery(cSQL)
	WizGrvReg(cAuxTmp,'SEV','EV_MSUID',lFormatUID)
	(cAuxTmp)->(DbCloseArea())

	If oQrySEVS2 == Nil
		cSQL := "SELECT SEV.R_E_C_N_O_ REC FROM ?"
		cSQL += " INNER JOIN ? SEV" 
		cSQL += "  ON EV_FILIAL=E2_FILIAL AND EV_PREFIXO=E2_PREFIXO AND "
		cSQL += "     EV_NUM=E2_NUM AND EV_PARCELA=E2_PARCELA AND "
		cSQL += "     EV_TIPO=E2_TIPO AND EV_CLIFOR=E2_FORNECE AND "
		cSQL += "     EV_LOJA=E2_LOJA AND EV_RECPAG='P' "
		cSQL += " WHERE E2_EMIS1 >= ? "
		cSQL += "    OR E2_SALDO <> ? "
		cSQL += "    OR E2_BAIXA >= ? " 
		cSQL := ChangeQuery(cSQL)
        oQrySEVS2 := FWPreparedStatement():New(cSQL)
	EndIf

	oQrySEVS2:SetNumeric(1, RetSqlName("SE2"))
	oQrySEVS2:SetNumeric(2, RetSqlName("SEV"))
	oQrySEVS2:SetString(3, Str(Year(Date())-2,4)+"0101")
	oQrySEVS2:SetNumeric(4, 0 )
	oQrySEVS2:SetString(5, Str(Year(Date())-2,4)+"0101") 

	cSQL := oQrySEVS2:GetFixQuery()
	cAuxTmp := MpSysOpenQuery(cSQL)
	WizGrvReg(cAuxTmp,'SEV','EV_MSUID',lFormatUID)
	(cAuxTmp)->(DbCloseArea())
	
EndIf
//--------------------------------------
// Rateio C.Custo
dbSelectArea('SEZ')
If FieldPos('EZ_MSUID') > 0

	If oQrySEZS1 == Nil
		cSQL := "SELECT SEZ.R_E_C_N_O_ REC FROM ? "    
		cSQL += " INNER JOIN ? SEZ"
		cSQL += "  ON EZ_FILIAL=E1_FILIAL AND EZ_PREFIXO=E1_PREFIXO AND "
		cSQL += "     EZ_NUM=E1_NUM AND EZ_PARCELA=E1_PARCELA AND "
		cSQL += "     EZ_TIPO=E1_TIPO AND EZ_CLIFOR=E1_CLIENTE AND "
		cSQL += "     EZ_LOJA=E1_LOJA AND EZ_RECPAG='R' "
		cSQL += " WHERE E1_EMIS1 >= ? "
		cSQL += "    OR E1_SALDO <> ? "
		cSQL += "    OR E1_BAIXA >= ? " 
		cSQL := ChangeQuery(cSQL)
        oQrySEZS1 := FWPreparedStatement():New(cSQL)
	EndIf

	oQrySEZS1:SetNumeric(1, RetSqlName("SE1"))
	oQrySEZS1:SetNumeric(2, RetSqlName("SEZ"))
	oQrySEZS1:SetString(3, Str(Year(Date())-2,4)+"0101")
	oQrySEZS1:SetNumeric(4, 0 )
	oQrySEZS1:SetString(5, Str(Year(Date())-2,4)+"0101") 

	cSQL := oQrySEZS1:GetFixQuery()
	cAuxTmp := MpSysOpenQuery(cSQL)
	WizGrvReg(cAuxTmp,'SEZ','EZ_MSUID',lFormatUID)
	(cAuxTmp)->(DbCloseArea())

	If oQrySEZS2 == Nil
		cSQL := "SELECT SEZ.R_E_C_N_O_ REC FROM ? "    
		cSQL += " INNER JOIN ? SEZ"
		cSQL += "  ON EZ_FILIAL=E2_FILIAL AND EZ_PREFIXO=E2_PREFIXO AND "
		cSQL += "     EZ_NUM=E2_NUM AND EZ_PARCELA=E2_PARCELA AND "
		cSQL += "     EZ_TIPO=E2_TIPO AND EZ_CLIFOR=E2_FORNECE AND "
		cSQL += "     EZ_LOJA=E2_LOJA AND EZ_RECPAG='P' "
		cSQL += " WHERE E2_EMIS1 >= ? "
		cSQL += "    OR E2_SALDO <> ? "
		cSQL += "    OR E2_BAIXA >= ? " 
		cSQL := ChangeQuery(cSQL)
        oQrySEZS2 := FWPreparedStatement():New(cSQL)
	EndIf

	oQrySEZS2:SetNumeric(1, RetSqlName("SE2"))
	oQrySEZS2:SetNumeric(2, RetSqlName("SEZ"))
	oQrySEZS2:SetString(3, Str(Year(Date())-2,4)+"0101")
	oQrySEZS2:SetNumeric(4, 0 )
	oQrySEZS2:SetString(5, Str(Year(Date())-2,4)+"0101") 

	cSQL := oQrySEZS2:GetFixQuery()
	cAuxTmp := MpSysOpenQuery(cSQL)
	WizGrvReg(cAuxTmp,'SEZ','EZ_MSUID',lFormatUID)
	(cAuxTmp)->(DbCloseArea())

EndIF

//--------------------------------------
// Habilita controle da integração.
PUTMV('MV_FINTGES', .T.)

FreeObj(oQrySEVS1)
FreeObj(oQrySEVS2)
FreeObj(oQrySEZS1)
FreeObj(oQrySEZS2)

Return

/*{Protheus.doc} WizGrvReg
Grava campo MSUID
@param cAliasQry, 	Alias temporarios para executar RecLock
@param cTabela, 	Nome da tabela para efetuar o RecLock
@param cCpoUUID, 	Character, Nome do campo UUID a ser gravado
@param lFormatUID, 	Logical, Parametro para ser passado na função FWUUIDV4
@type StaticFunction
@author Fabio Zanchim
@since 21/09/2022
@version 1.0
*/
Static Function WizGrvReg(cAliasQry As Character,cTabela As Character,cCpoUUID As Character,lFormatUID As Logical)

	(cAliasQry)->(dbGoTop())
	DbSelectArea((ctabela))
	While !(cAliasQry)->(Eof())
		(ctabela)->(dbGoTo((cAliasQry)->REC))
		If Empty(&(ctabela+"->"+cCpoUUID))
			RecLock(ctabela,.F.)
			&(ctabela+"->"+cCpoUUID) := FWUUIDV4(lFormatUID)
			(ctabela)->(MsUnlock())
		EndIF
		(cAliasQry)->(dbSkip())
	EndDo

Return

/*{Protheus.doc} VldStepUsr
Valida a senha do admin para prosseguir

@type StaticFunction
@author Fabio Zanchim
@since 21/09/2022
@param cUser, character, Usuário do login
@param cPass, character, senha do usuário
@version 1.0
*/
Static Function VldStepUsr(cUser As Character,cPass As Character) As Logical
	
	Local lRet As logical
	lRet := .F.	

	If FWIsAdmin(cUser) //Verifica se usuario é Admin
		PswOrder(2)
		If PswSeek(cUser)
			lRet := PswName(cPass)// Valida senha do usuario
		EndIf
	EndIF

	If !lRet
		MessageBox(STR0070, STR0056 , 0) //Senha inválida. Atenção
	EndIf

Return lRet 

/*{Protheus.doc} MyOpenSM0Ex
Abre arquivo de empresas em modo exclusivo

@type StaticFunction
@author Fabio Zanchim
@since 21/09/2022
@version 1.0
*/
Static Function MyOpenSM0Ex() As Logical

Local lOpen As Logical
Local nLoop As Numeric

lOpen := .F. 
nLoop := 0 

For nLoop := 1 To 5
	OpenSM0Excl() 
	If !Empty( Select( "SM0" ) ) 
		lOpen := .T. 
		dbSetOrder(1)
		Exit	
	EndIf
Next nLoop                                

Return( lOpen )

/*{Protheus.doc} LoadMsgUpd
Tela de carregamento do processamento do UPDDISTR

@type StaticFunction
@author Bruno Rosa
@since 15/04/2024
@param bAction, Codeblock, Ação a executar
@param cTitle, Character, Título da tela
@param cMsg, Character, Mensagem a ser apresentada
@version 1.0
*/
Static Function LoadMsgUpd(bAction As Block, cTitle As Character, cMsg As Character)

    Local oDlg As Object

    DEFINE MSDIALOG oDlg FROM 12,35 TO 19.5, 75 TITLE OemToAnsi(cTitle) STYLE DS_MODALFRAME STATUS

	@ 10, 20  SAY __oText VAR OemToAnsi(cMsg) SIZE 130, 20 PIXEL OF oDlg FONT oDlg:oFont
    oDlg:bStart = { || Eval( bAction ), oDlg:End() }

    ACTIVATE DIALOG oDlg CENTERED

Return

/*/{Protheus.doc} VldProced
Função responsável por validar a instalação da procedure.

@type  Static Function
@author victor.azevedo@totvs.com.br
@since 02/04/2025
@version P12
@return .T. caso esteja tudo ok;
		.F. caso haja divergencias.
/*/
Static Function VldProced(cCompany As Character) As Logical

	Local lRet			as Logical
	Local oProcesso   	as Object
	Local oProcessRPO 	as Object
	Local cAssProc    	as Character

	Default cCompany := cEmpAnt

	lRet        := .T.
	oProcesso   := EngSPSStatus("33", cCompany)
	oProcessRPO := EngSPSGetProcess(DEF_SPS_FROM_RPO, oProcesso["process"],  cCompany /*empresa*/)
	cAssProc    := EngSPS33Signature("33")

	If !(oProcessRPO["signature"] == cAssProc)
		cMsg := "Procedure nao localizada no repositorio ou assinatura da procedure nao esta atualizada. Favor realizar atualizacao do sistema. "
		MessageBox(cMsg, STR0075 , 0)
		lRet := .F.
	EndIf

Return lRet
