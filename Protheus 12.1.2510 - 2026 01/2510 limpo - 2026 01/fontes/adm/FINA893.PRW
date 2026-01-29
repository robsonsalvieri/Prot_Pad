#Include "TOTVS.ch"
#Include "FwSchedule.ch"
#Include "FINA893.ch"

Static __lCtaBanc As Logical
Static __lCFGPIX  As Logical
Static __lBcoProp As Logical
Static __lReadOnl As Logical

/*/{Protheus.doc} FINA893()
	Cria Wizard de Configuração para acesso ao Pagamentos Digitais.

	@author Edson Melo
	@since  09/02/2021
	@version 12.1.027
/*/
Function FINA893()
	Local aSM0Data		As Array
	Local nPosCGC		As Numeric
	Local nTamAgenci	As Numeric
	Local nTamBanco		As Numeric
	Local nTamConta		As Numeric
	Local oConfig		As Object
	Local oDaialog      As Object
	Local oPanel        As Object
	Local nWizard       As Numeric
	Local oSay          As Object
	Local oBtnBB        As Object
	Local oBtnTPI       As Object
	Local cVersao       As Char
	Local cCaracter     As Char
	Local cLstCaract    As Char
	Local nPosicao      As Numeric
	Local nQtdCaract    As Numeric
	Local o1stPage      As Object
	Local o2ndPage      As Object
	Local o3rdPage      As Object
	Local o4thPage      As Object
	Local o5thPage      As Object
	
	Private cAgenPIX	As Character
	Private cBancoPIX	As Character
	Private cBusId		As Character
	private cChaveConf	As Character
	private cChaveBCO	As Character
	Private cCNPJFil	As Character
	Private cContaPIX	As Character
	Private cExtBusId	As Character
	Private cFilJob		As Character
	Private cPDPss		As Character
	Private cPDUrl		As Character
	Private cPDUser		As Character
	Private cPDTenant	As Character
	Private cPosId		As Character

	Private lVldConn	As Logical

	Private oConfigS	As Object
	Private oFont1		As Object
	Private oFont2		As Object
	Private oPayHub		As Object
	Private oStepWiz	As Object

	If !(AliasInDic("F70")) .Or. !(AliasInDic("F71"))
		Help(" ", 1, "F893NaoTab",, STR0001, 1, 0,,,,,, {STR0002})
		Return
	EndIf
	
	cMsgErro	:= ""

	cFilJob := cFilAnt

	cCNPJFil	:= ""
	cPDUrl		:= ""
	cPDUser		:= ""
	cPDPss		:= ""
	cPDTenant	:= ""
	cPosId		:= ""
	cExtBusId	:= ""
	cChaveConf	:= cEmpAnt										//StrTran(cEmpAnt, " ", "_")
	cChaveBCO	:= cEmpAnt + "|" + AllTrim(FwXFilial("SA6")) 	//StrTran(cEmpAnt, " ", "_") + "|" + StrTran(FwXFilial("SA6"), " ", "_")
	nPosCGC		:= 0
	lVldConn	:= .F.
	oFont1		:= TFont():New("Arial",, -18,, .F.)
	oFont2		:= TFont():New("Arial",, -15,, .F.)
	nTamBanco	:= TamSX3("A6_COD")[1]
	nTamAgenci	:= TamSX3("A6_AGENCIA")[1]
	nTamConta	:= TamSX3("A6_NUMCON")[1] 
	nWizard     := 0
	oSay        := Nil
	oBtnBB      := Nil
	oBtnTPI     := Nil	
	cVersao     := ""
	cCaracter   := ""
	cLstCaract  := ""
	nPosicao    := 0
	nQtdCaract  := 0
	
	Define Dialog oDaialog Title STR0103  PIXEL
		oDaialog:nWidth  := 665
		oDaialog:nHeight := 290
		
		oPanel := TPanel():New(10, 20,"", oDaialog, Nil, Nil, Nil, Nil, Nil, oDaialog:nWidth, oDaialog:nHeight)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT	
		
		oFont1 	:= TFont():New(Nil, Nil, -18, .T., .T., Nil, Nil, Nil, Nil, Nil)
		oFont2 	:= TFont():New(Nil, Nil, -15, .F., .F., Nil, Nil, NIl, Nil, Nil)
		
		oSay := TSay():New(10, 15, {||STR0103}, oPanel, Nil, oFont1, Nil, Nil, Nil, .T.,,)
		oSay := TSay():New(40, 15, {||STR0104}, oPanel, Nil, oFont2, Nil, Nil, Nil, .T.,, Nil)
		
		oBtnTPI := TButton():New(65, 015, STR0105, oPanel, {||nWizard := 1, oDaialog:End()}, 145, 30, Nil, oFont1, .F., .T., .F., Nil, .F., Nil, Nil, .F.)
		oBtnBB  := TButton():New(65, 170, STR0070, oPanel, {||nWizard := 2, oDaialog:End()}, 145, 30, Nil, oFont1, .F., .T., .F., Nil, .F., Nil, Nil, .F.)
	ACTIVATE DIALOG oDaialog CENTER
	
	If nWizard == 2
		If __lCtaBanc == Nil
			__lCtaBanc := FindFunction("CtaBancPix") .And. FindFunction("FINA893A")
		EndIf
		
		If __lCFGPIX == Nil
			__lCFGPIX := SA6->(FieldPos("A6_CFGPIX")) > 0
		EndIf
		
		If (!__lCFGPIX .Or. !__lCtaBanc)
			nWizard := 0
			Help(" ", 1, "ATUAMBIENTE", Nil, STR0106, 2, 0, Nil, Nil, Nil, Nil, Nil, {STR0107 + STR0070 + STR0108})
		Else
			cLstCaract := AllTrim(StrTran(GetSrvVersion(), ".", ""))
			nQtdCaract := Len(cLstCaract) 
			
			For nPosicao := 1 To nQtdCaract 
				If !(cCaracter := (SubStr(cLstCaract, nPosicao, 1))) $ "0|1|2|3|4|5|6|7|8|9"
					Exit
				EndIf
				
				cVersao += cCaracter
			Next nPosicao
			
			If Val(Left(cVersao,4)) < 2031
				nWizard := 0
				Help(" ", 1, "ATUAMBIENTE", Nil, STR0119, 2, 0, Nil, Nil, Nil, Nil, Nil, {STR0120})
			ElseIf Val(Left(cVersao,4)) == 2031
				If Val(Right(cVersao,(Len(cVersao)- 4))) < 3
					nWizard := 0
					Help(" ", 1, "ATUAMBIENTE", Nil, STR0119, 2, 0, Nil, Nil, Nil, Nil, Nil, {STR0120})
				EndIf
			EndIf
		EndIf
	EndIf
	
	If nWizard > 0 .And. nWizard <= 2
		Do Case
			Case nWizard == 2
				FINA893A("001")
			OtherWise
				aSM0Data := FwSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {"M0_CGC", "M0_NOME"})
				nPosCGC  := AScan(aSM0Data, {|x| x[1] == "M0_CGC"})

				If nPosCGC > 0
					cCNPJFil := aSM0Data[nPosCGC][2]
				EndIf

				If Empty(cCNPJFil)
					Help(" ", 1, "HELP",, STR0048, 1, 1,,,,,, {STR0049})
					Return
				EndIf

				// Carrega inicalizador padrão das variáveis do TOTVS PAGAMENTOS DIGITAIS
				oConfig := FwTFConfig()

				// Definição da URL
				If ValType(cPDUrl := oConfig["fin_url_PagamentosDigitais"]) == "U"
					cPDUrl := PadR("https://staging.raas.varejo.totvs.com.br/", 100)
				EndIf

				// Definição do Usuário
				If ValType(cPDUser := oConfig["fin_user_PagamentosDigitais_" + cChaveConf]) == "U"
					cPDUser := PadR("", 50)
				EndIf

				// Definição do Senha
				If ValType(cPDPss := oConfig["fin_password_PagamentosDigitais_" + cChaveConf]) == "U"
					cPDPss := PadR("", 50)
				EndIf

				// Definição do Tenant
				If ValType(cPDTenant := oConfig["fin_tenant_PagamentosDigitais_" + cChaveConf]) == "U"
					cPDTenant := PadR("", 64)
				EndIf

				// Definição do Caixa Virtual 
				If ValType(cPosId := oConfig["fin_idpos_PagamentosDigitais_" + cChaveConf]) == "U"
					cPosId := PadR("", 50)
				EndIf
				
				// Definição do Código Externo da Unidade de Negócio no PD
				If ValType(cExtBusId := oConfig["fin_extBusId_PagamentosDigitais_" + cChaveConf]) == "U"
					cExtBusId := PadR("", 50)
				EndIf

				// Definação do Código da Unidade de Negócio dentro do PD
				If ValType(cBusId := oConfig["fin_busId_PagamentosDigitais_" + cChaveConf]) == "U"
					cBusId := PadR("", 50)
				EndIf

				// Definição Banco TOTVS PIX
				If ValType(cBancoPIX := oConfig["fin_banco_PagamentosDigitais_" + cChaveBCO]) == "U"
					cBancoPIX := PadR("", nTamBanco)
				EndIf

				// Definição Agência TOTVS PIX
				If ValType(cAgenPIX := oConfig["fin_agencia_PagamentosDigitais_" + cChaveBCO]) == "U"
					cAgenPIX := PadR("", nTamAgenci)
				EndIf

				// Definição Conta TOTVS PIX
				If ValType(cContaPIX := oConfig["fin_conta_PagamentosDigitais_" + cChaveBCO]) == "U"
					cContaPIX := PadR("", nTamConta)
				EndIf

				oConfigS := JSONObject():New()

				cPDUrl		:= AllTrim(cPDUrl)
				cPDUser		:= PadR(cPDUser,	50)
				cPDPss		:= PadR(cPDPss,		50)
				cPDTenant	:= PadR(cPDTenant,	64)
				cPosId		:= PadR(cPosId,		50)
				cExtBusId	:= PadR(cExtBusId,	50)
				cBusId		:= PadR(cBusId,		50)				
				__lBcoProp  := !Empty(cBancoPIX)
				__lReadOnl  := !__lBcoProp
				
				If __lBcoProp
					SA6->(DbSeek(FwXFilial("SA6") + cBancoPIX + cAgenPIX + cContaPIX))
				Else
					cBancoPIX	:= PadR(cBancoPIX,	nTamBanco)
					cAgenPIX	:= PadR(cAgenPIX,	nTamAgenci)
					cContaPIX	:= PadR(cContaPIX,	nTamConta)
				EndIf
				
				// Montagem do Wizard
				oStepWiz := FwWizardControl():New(,{600,850}) //Instancia a classe FwWizardControl
				oStepWiz:ActiveUISteps()

				// Pagina 1
				o1stPage := oStepWiz:AddStep("1STSTEP",{|Panel| Step1(Panel)}) // Adiciona um Step
				o1stPage:SetStepDescription(OemToAnsi(STR0003))
				o1stPage:SetNextTitle(OemToAnsi(STR0005)) // Define o título do botão de avanço -- STR0005
				o1stPage:SetNextAction({||.T.}) // Define o bloco ao clicar no botão Próximo
				o1stPage:SetCancelAction({|| .T.}) // Define o bloco ao clicar no botão Cancelar

				// Pagina 2
				o2ndPage := oStepWiz:AddStep("2NDSTEP", {|Panel| Step2(Panel)})
				o2ndPage:SetStepDescription(OemToAnsi(STR0004))
				o2ndPage:SetNextTitle(OemToAnsi(STR0005)) // --
				o2ndPage:SetPrevTitle(OemToAnsi(STR0006)) // Define o título do botão para retorno --
				o2ndPage:SetNextAction({|| VldStep2()})
				o2ndPage:SetPrevAction({|| .T.}) // Define o bloco ao clicar no botão Voltar
				o2ndPage:SetCancelAction({|| .T.}) // Define o bloco ao clicar no botão Cancelar

				// Pagina 3
				o3rdPage := oStepWiz:AddStep("3RDSTEP", {|Panel| Step3(Panel)})
				o3rdPage:SetStepDescription(OemToAnsi(STR0007))
				o3rdPage:SetNextTitle(OemToAnsi(STR0005))
				o3rdPage:SetPrevTitle(OemToAnsi(STR0006))
				o3rdPage:SetNextAction({|| .T.})
				o3rdPage:SetPrevWhen({|| !lVldConn})
				o3rdPage:SetCancelAction({|| .T.})

				// Pagina 4
				o4thPage := oStepWiz:AddStep("4THSTEP", {|Panel| Step4(Panel)})
				o4thPage:SetStepDescription(OemToAnsi(STR0008))
				o4thPage:SetNextTitle(OemToAnsi(STR0005))
				o4thPage:SetPrevTitle(OemToAnsi(STR0006))
				o4thPage:SetNextAction({||IIf(__lBcoProp, VldStep4(), .T.)})
				o4thPage:SetPrevWhen({|| !lVldConn})
				o4thPage:SetCancelAction({|| .T.})

				// Pagina 5
				o5thPage := oStepWiz:AddStep("5THSTEP", {|Panel| Step5(Panel)})
				o5thPage:SetStepDescription(OemToAnsi(STR0010))
				o5thPage:SetNextTitle(OemToAnsi(STR0011))
				o5thPage:SetPrevTitle(OemToAnsi(STR0006))
				o5thPage:SetNextAction({|| .T.})
				o5thPage:SetPrevWhen({|| .F.})
				o5thPage:SetCancelWhen({|| .F.})

				oStepWiz:Activate()

				FreeObj(o1stPage)
				FreeObj(o2ndPage)
				FreeObj(o3rdPage)
				FreeObj(o4thPage)
				FreeObj(o5thPage)
				FreeObj(oPayHub)
				FreeObj(oConfig)
				FreeObj(oConfigS)
				FreeObj(oStepWiz)
				FwFreeArray(aSM0Data)
		EndCase
	EndIf
Return Nil

/*/{Protheus.doc} Step1
Função para construção da primeira página do wizard

@author		Edson Melo
@since		09/02/2021
@version	12.1.027
@param		oPanel
/*/
Static Function Step1(oPanel As Object)

	TSay():New(010, 025,{|| OemToAnsi(STR0012)}, oPanel,, oFont1,,,, .T.)
	TSay():New(025, 030,{|| OemToAnsi(STR0013)}, oPanel,, oFont2,,,, .T.)
	TSay():New(065, 030,{|| OemToAnsi(STR0014)}, oPanel,, oFont2,,,, .T.)
	TSay():New(085, 030,{|| OemToAnsi(STR0015)}, oPanel,, oFont2,,,, .T.)
	TSay():New(105, 030,{|| OemToAnsi(STR0016)}, oPanel,, oFont2,,,, .T.)
	TSay():New(125, 030,{|| OemToAnsi(STR0017)}, oPanel,, oFont2,,,, .T.)

Return Nil

/*/{Protheus.doc} Step2
Função para construção da segunda página do wizard. Validação de usuário e senha.

@author		Edson Melo
@since		09/02/2021
@version	12.1.027
@param		oPanel
/*/
Static Function Step2(oPanel As Object)

	TSay():New(010, 025, {|| OemToAnsi(STR0018)}, oPanel,, oFont1,,,, .T.)
	TSay():New(025, 030, {|| OemToAnsi(STR0019)}, oPanel,, oFont2,,,, .T.)

	//Dados de acesso 
	TSay():New(041, 030, {|| OemToAnsi(STR0020)}, oPanel,, oFont2,,,, .T.)	
	TGet():New(056, 030, {|u| If(PCount() > 0, cPDTenant := u, cPDTenant)},oPanel,296,009,"",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.f.,, cPDTenant)

	TSay():New(072, 030, {|| OemToAnsi(STR0021)}, oPanel,, oFont2,,,, .T.)
	TGet():New(087, 030, {|u| If(PCount() > 0, cPDUser := u, cPDUser)},oPanel,296,009,"",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.f.,, cPDUser)

	TSay():New(103, 030, {|| OemToAnsi(STR0022)}, oPanel,, oFont2,,,, .T.)
	TGet():New(118, 030, {|u| If(PCount() > 0, cPDPss := u, cPDPss)},oPanel,296,009,"",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.T.,, cPDPss)

	TSay():New(134, 030, {|| OemToAnsi(STR0056)}, oPanel,, oFont2,,,, .T.)
	TGet():New(149, 030, {|u| If(PCount() > 0, cExtBusId := u, cExtBusId)},oPanel,296,009,"",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.f.,, cExtBusId)

	TSay():New(165, 030, {|| OemToAnsi(STR0057)}, oPanel,, oFont2,,,, .T.)	
	TGet():New(180, 030, {|u| If(PCount() > 0, cPosId := u, cPosId)},oPanel,296,009,"",,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.f.,, cPosId)

Return Nil

/*/{Protheus.doc} VldStep2
Valida se cliente poderá continuar com o processo.

@author 	Edson Melo
@since  	09/02/2021
@version 	12.1.027
/*/
Static Function VldStep2() As Logical

	Local lRet	As Logical

	lRet	:= .T.

	If Empty(cPDTenant)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0024), {STR0027}, 3)
		lRet := .F.
	ElseIf Empty(cPDUser)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0025), {STR0027}, 3)
		lRet := .F.
	ElseIf lRet .And. Empty(cPDPss)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0026), {STR0027}, 3)
		lRet := .F.
	ElseIf Empty(cPosId)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0050), {STR0027}, 3)
		lRet := .F.
	ElseIf Empty(cExtBusId)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0051), {STR0027}, 3)
		lRet := .F.
	EndIf

	If lRet
		oPayHub := PayHubPix():New(cExtBusId, cPosId, cPDTenant, cPDUser, cPDPss, "totvs_pagamento_digital_protheus_ro",, "BRL")
		If AllTrim(Upper(cPDTenant)) <> "TOTVS_INTERNO"
			If !(lRet := oPayHub:CheckIntegrity())
				Aviso(OemToAnsi(STR0023), OemToAnsi(oPayHub:cLastError), {STR0027}, 3)
			ElseIf !(lRet := oPayHub:ValidConn())
				Aviso(OemToAnsi(STR0023), OemToAnsi(STR0028 + oPayHub:cLastError), {STR0027}, 3)
			ElseIf !(lRet := oPayHub:ValidExternalBusinessUnitId(@cBusId))
				Aviso(OemToAnsi(STR0023), OemToAnsi(oPayHub:cLastError), {STR0027}, 3)
			ElseIf !(lRet := oPayHub:ValidPosId(cBusId))
				Aviso(OemToAnsi(STR0023), OemToAnsi(oPayHub:cLastError), {STR0027}, 3)
			EndIf
		EndIf
		lVldConn := lRet
	EndIf

Return lRet

/*/{Protheus.doc} Step3
Função para construção da terceira página do wizard. usuário informa o endereço de conexão com o pix.

@author 	Edson Melo
@since 	 	09/02/2021
@version 	12.1.027
@param 		oPanel
/*/
Static Function Step3(oPanel As Object)

	TSay():New(010, 025, {|| OemToAnsi(STR0029)},					oPanel,, oFont1,,,, .T.)
	TSay():New(025, 030, {|| OemToAnsi(STR0030)},					oPanel,, oFont2,,,, .T.)
	TSay():New(040, 030, {|| OemToAnsi(STR0031 + oPayHub:cURL)},	oPanel,, oFont2,,,, .T.)

Return Nil

/*/{Protheus.doc} Step4
Função para construção da quarta página do wizard. usuário informa o banco padrão para o PIX.

@author		Edson Melo
@since		09/02/2021
@version	12.1.027
@param		oPanel
/*/
Static Function Step4(oPanel As Object)
	Local oGetBco	As Object
	Local oGetAgen	As Object
	Local oGetConta	As Object
	
	TSay():New(010, 025, {|| OemToAnsi(STR0008)}, oPanel,, oFont1,,,, .T.)
	TSay():New(028, 025, {|| OemToAnsi(STR0032)}, oPanel,, oFont2,,,, .T.)
	TSay():New(041, 025, {|| OemToAnsi(STR0033)}, oPanel,, oFont2,,,, .T.)	
	
	//Banco
	oFont2:nHeight := 11
	oGetBco   := TGet():New(077, 025, {|u| If(PCount() > 0, cBancoPIX := u, cBancoPIX)}, oPanel, 296, 009, "@!", {|u| ValidBanco(1)},, Nil, Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, __lReadOnl, .F., Nil, cBancoPIX, Nil, Nil, Nil, Nil, Nil, Nil, STR0034, 1, oFont2)
	oGetBco:bF3 := {||.F.}
	
	If !__lReadOnl
		oGetBco:bF3 := {||ConPadSA6(@oGetBco, @oGetAgen, @oGetConta)}
	EndIf
	
	//Agência
	oGetAgen  := TGet():New(110, 025, {|u| If(PCount() > 0, cAgenPIX := u, cAgenPIX)}, oPanel, 296, 009, "@!", {|u| ValidBanco(2)},, Nil, Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, __lReadOnl, .F., Nil, cAgenPIX, Nil, Nil, Nil, Nil, Nil, Nil, STR0035, 1, oFont2)
	
	//Conta
	oGetConta := TGet():New(143, 025, {|u| If(PCount() > 0, cContaPIX := u, cContaPIX)}, oPanel, 296, 009, "@!", {|u| ValidBanco(3)},, Nil, Nil, .F., Nil, .T., Nil, .F., Nil, .F., .F., Nil, __lReadOnl, .F., Nil, cContaPIX, Nil, Nil, Nil, Nil, Nil, Nil, STR0037, 1, oFont2)
	
	//Utilizar banco próprio
	oFont2:nHeight := -15
	TCheckBox():New(050, 025, STR0140, bSetGet(__lBcoProp), oPanel, 100, 018, Nil, {||BancoProp(@oGetBco, @oGetAgen, @oGetConta)}, oFont2, Nil, Nil, Nil, Nil, .T., Nil, Nil, Nil)	
Return Nil

/*/{Protheus.doc} ConPadSA6
Validação dos campos banco, agência e conta.

@author		Rafael Riego
@since		16/08/2021
@param		oGetBco, object, get referente ao código do banco
@param		oGetAgen, object, get referente a agência
@param		oGetConta, object, get referente ao número da conta
/*/
Static Function ConPadSA6(oGetBco As Object, oGetAgen As Object, oGetConta As Object)
	If ConPad1(,,, "SA6",,, .F.)
		cBancoPIX	:= SA6->A6_COD
		cAgenPIX	:= SA6->A6_AGENCIA
		cContaPIX	:= SA6->A6_NUMCON
		oGetBco:Refresh()
		oGetAgen:Refresh()
		oGetConta:Refresh()
	EndIf
Return Nil

/*/{Protheus.doc} ValidBanco
Validação dos campos banco, agência e conta.

@author 	Rafael Riego
@since  	16/08/2021
@param		nTipo, numeric, qual dado deve ser validado, sendo 1=Banco;2=Agência;3=Conta
@return 	logical, verdadeiro caso os dados informados sejam válidos
/*/
Static Function ValidBanco(nTipo As Numeric) As Logical
	Local lValido	As Logical

	Default nTipo	:= 0

	lValido := .T.

	If nTipo == 1 //Banco
		If Empty(cBancoPIX) 
			cAgenPIX	:= Space(TamSX3("A6_AGENCIA")[1])
			cContaPIX	:= Space(TamSX3("A6_NUMCON")[1])
		ElseIf !(ExistCpo("SA6", cBancoPIX))
			lValido := .F.
		EndIf
	ElseIf nTipo == 2 //Agencia
		If Empty(cAgenPIX)
			cContaPIX := Space(TamSX3("A6_NUMCON")[1])
		ElseIf !(ExistCpo("SA6", cBancoPIX + cAgenPIX))
			lValido := .F.
		EndIf
	ElseIf nTipo == 3 //Conta
		If !(Empty(cContaPIX)) .And. !(ExistCpo("SA6", cBancoPIX + cAgenPIX + cContaPIX))
			lValido := .F.
		EndIf
	EndIf

	//Validação completa da chave SA6
	If lValido .And. !(Empty(cBancoPIX)) .And. !(Empty(cAgenPIX)) .And. !(Empty(cContaPIX))
		If !(ExistCpo("SA6", cBancoPIX + cAgenPIX + cContaPIX))
			lValido := .F.
		EndIf
	EndIf

Return lValido

/*/{Protheus.doc} VldStep4
Valida o banco / Agencia e Conta.

@author 	Edson Melo
@since  	09/02/2021
@version 	12.1.027
@return		logical
/*/
Static Function VldStep4() As Logical
	Local lRet		As Logical
	Local cChavePix As Character
	Local cTpChvPix As Character
	Local cQuery	As Character

	lRet		:= .T.
	cChavePix	:= ""
	cTpChvPix	:= ""
	cQuery		:= ""

	If Empty(cBancoPIX) .Or. Empty(cAgenPIX) .Or. Empty(cContaPIX)
		Aviso(OemToAnsi(STR0023), OemToAnsi(STR0038), {STR0027}, 3)
		lRet := .F.
	Else
		cBancoPIX := AvKey(cBancoPIX, 	"A6_COD")
		cAgenPIX  := AvKey(cAgenPIX,	"A6_AGENCIA")
		cContaPIX := AvKey(cContaPIX, 	"A6_NUMCON")

		SA6->(DbSetOrder(1)) //A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON
		If !SA6->(DbSeek(FwXFilial("SA6") + cBancoPIX + cAgenPIX + cContaPIX))
			Aviso(OemToAnsi(STR0023), OemToAnsi(STR0039), {STR0027}, 3)
			lRet := .F.
		Else
			cTempF70	:= GetNextAlias()
			cQuery		:= " SELECT  F70_TPCHV, F70_CHVPIX "
			cQuery		+= " FROM " + RetSQLName("F70")+ " "
			cQuery		+= " WHERE F70_COD = '"		+ cBancoPIX			+ "' "
			cQuery		+= " AND F70_AGENCI = '"	+ cAgenPIX			+ "' "
			cQuery		+= " AND F70_NUMCON = '"	+ cContaPIX			+ "' "
			cQuery		+= " AND F70_ACTIVE = '1' "
			cQuery		+= " AND D_E_L_E_T_ = ' ' "
			cQuery		:= ChangeQuery(cQuery)
			MPSysOpenQuery(cQuery,cTempF70)

			If (cTempF70)->(!EoF())
				cTpChvPix := (cTempF70)->F70_TPCHV
				cChavePix := (cTempF70)->F70_CHVPIX
			EndIf

			(cTempF70)->(DbCloseArea())

			If Empty(cChavePix) .And. Empty(cTpChvPix)
				Aviso(OemToAnsi(STR0023), OemToAnsi(STR0040), {STR0027}, 3)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		//Efetua gravação dos dados de conexão PIX API 
		oConfigS["fin_url_PagamentosDigitais"]						:= AllTrim(cPDUrl)
		oConfigS["fin_user_PagamentosDigitais_" 	+ cChaveConf]	:= AllTrim(cPDUser)
		oConfigS["fin_password_PagamentosDigitais_" + cChaveConf]	:= AllTrim(cPDPss)
		oConfigS["fin_tenant_PagamentosDigitais_" 	+ cChaveConf]	:= AllTrim(cPDTenant)
		oConfigS["fin_idpos_PagamentosDigitais_" 	+ cChaveConf]	:= AllTrim(cPosId)
		oConfigS["fin_busId_PagamentosDigitais_" 	+ cChaveConf]	:= AllTrim(cBusId)
		oConfigS["fin_extBusId_PagamentosDigitais_" + cChaveConf]	:= AllTrim(cExtBusId)
		oConfigS["fin_banco_PagamentosDigitais_" 	+ cChaveBCO]	:= cBancoPIX
		oConfigS["fin_agencia_PagamentosDigitais_" 	+ cChaveBCO]	:= cAgenPIX
		oConfigS["fin_conta_PagamentosDigitais_" 	+ cChaveBCO]	:= cContaPIX
		FwTFSetConfig(oConfigS)
	EndIf
Return lRet

/*/{Protheus.doc} Step5
Encerramento do processo.

@author 	Edson Melo
@since  	09/02/2021
@version 	12.1.027
@param 		oPanel
/*/
Static Function Step5(oPanel As Object)
	TSay():New(025, 025, {|| OemToAnsi(STR0047)}, oPanel,, oFont1,,,, .T.)
Return Nil

/*/{Protheus.doc} BancoProp
	Limpa os dados bancário quando não usar banco próprio
	
	@author Sivaldo Oliveira
	@since 28/11/2023
	
	@Param oGetBco,  Object, Objeto de TGet com o código do banco
	@Param oGetAgen, Object, Objeto de TGet com a agência bancária 
	@Param oGetBco, Object,  Objeto de TGet com a conta bancária
/*/
Static Function BancoProp(oGetBco As Object, oGetAgen As Object, oGetConta As Object)	
	//Parâmetros de entrada
	Default oGetBco   := Nil
	Default oGetAgen  := Nil  
	Default oGetConta := Nil
	
	If !__lBcoProp
		If (!Empty(cBancoPIX) .Or. !Empty(cAgenPIX) .Or. !Empty(cContaPIX))
			cBancoPIX := PadR(" ", TamSX3("A6_COD")[1])
			cAgenPIX  := PadR(" ", TamSX3("A6_AGENCIA")[1])
			cContaPIX := PadR(" ", TamSX3("A6_NUMCON")[1])
		EndIf
		
		If oGetBco != Nil
			oGetBco:bF3 := {||.F.}
			oGetBco:Refresh()
		EndIf
		
		If oGetAgen != Nil
			oGetAgen:Refresh()
		EndIf
		
		If oGetConta != Nil
			oGetConta:Refresh()
		EndIf
	ElseIf oGetBco != Nil		
		oGetBco:bF3 := {||ConPadSA6(@oGetBco, @oGetAgen, @oGetConta)}
	EndIf
	
	__lReadOnl := !__lBcoProp 
Return Nil
