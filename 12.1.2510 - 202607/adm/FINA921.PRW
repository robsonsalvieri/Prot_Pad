#Include 'Protheus.ch'
#Include "FwSchedule.ch"
#Include "FINA921.ch"

Static __lAPixTpd As Logical
Static __lSchedul As Logical
Static __lAutomat As Logical
/*/{Protheus.doc} FINA921()
Cria Wizard de Configuração para acesso ao Pagamentos Digitais.

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
/*/
Function FINA921(lAutomato As Logical, oAcesso As JSon, cCodigoJob As Character, nTipoCadas As Numeric)	
	Local cEmpFVR  As Character
	Local cUniFVR  As Character
	Local cFilFVR  As Character
	Local cEmpFV3  As Character
	Local cUniFV3  As Character
	Local cFilFV3  As Character
	Local nPosCGC  As Numeric
	Local nEmp     As Numeric	
	Local aSM0Data As Array	
	Local aEmp     As Array
	Local aArea    As Array
	
	Private cCnpjFil As Character
	Private cFilJob  As Char
	Private oFont1   As Object
	Private oFont2   As Object
	
	//Parâmetros de entrada
	Default lAutomato  := .F.
	Default oAcesso    := Nil
	Default cCodigoJob := ""
	Default nTipoCadas := 3
	
	//Inicializa variáveis	
	cEmpFVR    := FWMODEACCESS("FVR", 1)
	cUniFVR    := FWMODEACCESS("FVR", 2)
	cFilFVR    := FWMODEACCESS("FVR", 3)
	cEmpFV3    := FWMODEACCESS("FV3",1)
	cUniFV3    := FWMODEACCESS("FV3",2)
	cFilFV3    := FWMODEACCESS("FV3",3)
	nPosCGC    := 0
	nEmp       := 0	
	aSM0Data   := {}
	aEmp       := {}
	aArea      := Nil
	cCnpjFil   := ""
	cFilJob    := ""	
	oFont1     := TFont():New("Arial",,-18,,.F.)
	oFont2     := TFont():New("Arial",,-15,,.F.)	
	__lSchedul := .F.
	__lAutomat := lAutomato
	
	If cPaisLoc != "BRA"
		Help(" ",1,"F921BRA",, "Rotina indisponível." , 1 , 1,,,,,,{ "Rotina disponível apenas para ambiente BRASIL." })
		Return
	EndIf
	
	//Verifica o compartilhamento das tabelas FVR e FV3 são iguais e compartilhado..
	If ((cEmpFVR == "E") .Or. (cUniFVR == "E") .Or. (cFilFVR == "E")) .Or. ((cEmpFV3 == "E") .Or. (cUniFV3 == "E") .Or. (cFilFV3 == "E"))
		MsgStop( STR0048, STR0049 )
		Return(.F.)
	EndIf
	
	If !MayIUseCode("FINA921")
		MsgStop(STR0050, STR0051)
		Return(.F.)
	EndIf
	
	If !AliasIndic('FIF') .or. !AliasIndic('FVR') .or. !AliasIndic('FV3')
		Help(" ", 1, "F921NaoTab",, STR0052, 1, 0,,,,,,{ STR0053 })
		Return
	EndIf
	
	aEmp := FwLoadSm0()
	
	For nEmp := 1 to Len(aEmp)
		If  aEmp[nEmp][1] == cEmpAnt
			cFilJob := aEmp[nEmp][2]
			exit
		EndIf
	Next
	
	//VALIDAÇÃO DA FILIAL
	aSM0Data := FwSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {"M0_CGC", "M0_NOME"})
	
	If (nPosCGC  := AScan(aSM0Data, {|x| x[1] == "M0_CGC"})) > 0
		cCnpjFil := aSM0Data[nPosCGC,2]
	Else
		Help(" ",1,"HELP",, STR0061 , 1 , 1,,,,,,{ STR0054 })
		Return
	EndIf
	
	aArea := GetArea()
	
	FINA921Wiz(oAcesso, @cCodigoJob, nTipoCadas)
	
	RestArea(aArea)
	
	FwFreeArray(aEmp)
	FwFreeArray(aSM0Data)
	FwFreeArray(aArea)
Return

//--------------------------------------------------------------------------
/*{Protheus.doc} FINA921Wiz()
Montagem do wizard para comunicação com API

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
*/
//--------------------------------------------------------------------------
Function FINA921Wiz(oAcesso As JSon, cCodigoJob As Character, nTipoCadas As Numeric)
	Local oStepWiz 	  As Object
	Local o1stPage 	  As Object
	Local o2ndPage 	  As Object
	Local o3thPage 	  As Object	
	
	Private oRecHub	  As Object
	Private cPDUrlRAC As Character
	Private cPDUser   As Character
	Private cPDPss    As Character
	Private cPDTenant As Character
	Private cExtBusId As Character
	Private lVldConn  As Logical
	
	Default __lAutomat := .F.	
	Default oAcesso    := Nil
	Default nTipoCadas := 3 
	
	//Inicializa variáveis
	__lAPixTpd := IIf(FindFunction("F918AtuTPD"), F918AtuTPD(), .F.)
	
	If __lAPixTpd	
		//Carrega inicalizador padrão das variáveis do TOTVS PAGAMENTOS DIGITAIS
		oRecHub   := FINReceiveHubTPD():New()
		cPDUrlRAC := oRecHub:cUrlRAC
		cPDUser   := PADR(oRecHub:cUserName, 50)
		cPDPss    := PADR(oRecHub:cPassword, 50)
		cPDTenant := PADR(oRecHub:cTenant, 64)
		cExtBusId := PADR(oRecHub:cCodeComp, 50)
		
		If __lAutomat 			
			cPDUrlRAC := oRecHub:cUrlRAC
			cPDUser   := oAcesso["nomedousuario"]
			cPDPss    := oAcesso["senhadousuario"]
			cPDTenant := oAcesso["dominioemp"]
			cExtBusId := oAcesso["unidadeneg"]
		Else
			// Montagem do Wizard
			oStepWiz := FWWizardControl():New(, { 600, 850 }) //Instancia a classe FWWizardControl
			oStepWiz:ActiveUISteps()

			// Pagina 1 (Informações gerais sobre a rotina)
			o1stPage := oStepWiz:AddStep("1STSTEP", { |Panel| Step1(Panel) }) 	// Adiciona um Step (pagina)
			o1stPage:SetStepDescription(OemToAnsi(STR0003)) 			   		// "Informações"
			o1stPage:SetNextTitle(OemToAnsi(STR0005)) 					   		// "Avançar"
			o1stPage:SetNextAction({||.T. }) 							   		// Define o bloco ao clicar no botão "Avançar"
			o1stPage:SetCancelAction({|| .T. }) 							    // Define o bloco ao clicar no botão "Cancelar"

			// Pagina 2 (Credenciais Tenant)
			o2ndPage := oStepWiz:AddStep("2NDSTEP", { |Panel| Step2(Panel) }) 	// Adiciona um Step (pagina)
			o2ndPage:SetStepDescription(STR0004) 								// "Credenciais Tenant"
			o2ndPage:SetNextTitle(STR0005) 						            	// "Avançar"
			o2ndPage:SetPrevTitle(STR0006) 						            	// "Retornar"
			o2ndPage:SetNextAction({|| VldStep2() }) 							// Valida os dados do usuário
			o2ndPage:SetPrevAction({|| .T. }) 									// Define o bloco ao clicar no botão "Retornar"
			o2ndPage:SetCancelAction({|| .T. }) 								// Define o bloco ao clicar no botão "Cancelar"

			// Pagina 3 (Encerramento Processo)
			o3thPage := oStepWiz:AddStep("3THSTEP", { |Panel| Step3(Panel) })  	// Adiciona um Step (pagina)
			o3thPage:SetStepDescription(OemToAnsi(STR0010))                		// Titulo do step: "Encerramento Processo"
			o3thPage:SetNextTitle(OemToAnsi(STR0011))                       	// "Concluir"
			o3thPage:SetPrevTitle(OemToAnsi(STR0006))                       	// "Retornar"
			o3thPage:SetNextAction({||.T. })                                	// Define o bloco ao clicar no botão "Concluir"
			o3thPage:SetPrevAction({|| .F. })                               	// Define o bloco ao clicar no botão "Retornar"
			o3thPage:SetCancelAction({|| .F. })                              	// Define o bloco ao clicar no botão "Cancelar"
		
			oStepWiz:Activate()
			FreeObj(oStepWiz)
		EndIf
	Else
		Help(" ", 1, "Dicionário",, STR0055, 1, 0,,,,,,{ STR0056 })
	EndIf

Return Nil

/*/{Protheus.doc} Step1
Função para construção da primeira página do wizard

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
@param 		oPanel
/*/
Static Function Step1(oPanel as Object) 

	TSay():New(015,085,{|| OemToAnsi(STR0012) },oPanel,,oFont1,,,,.T.,CLR_BLUE,)
	TSay():New(030,110,{|| OemToAnsi(STR0013) },oPanel,,oFont1,,,,.T.,CLR_BLUE,)
	TSay():New(055,030,{|| OemToAnsi(STR0014) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TSay():New(080,050,{|| OemToAnsi(STR0015) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TSay():New(095,050,{|| OemToAnsi(STR0016) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TSay():New(110,050,{|| OemToAnsi(STR0017) },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TSay():New(135,030,{|| OemToAnsi(STR0018) },oPanel,,oFont2,,,,.T.,CLR_BLUE,) 

	TSay():New(170,080,{|| OemToAnsi(STR0057) },oPanel,,oFont1,,,,.T.,CLR_RED,) 
	TSay():New(185,120,{|| OemToAnsi(STR0058) },oPanel,,oFont1,,,,.T.,CLR_RED,) 

Return

/*/{Protheus.doc} Step2
Função para construção da segunda página do wizard:
Informa os dados de tenant, usuário e senha.

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
@param 		oPanel
/*/
Static Function Step2(oPanel As Object) As Logical
	Local lRet 		As Logical

	lRet := .T.	

	TSay():New(025,25,{|| STR0019 },oPanel,,oFont1,,,,.T.,CLR_BLUE,)
	TSay():New(045,30,{|| STR0020 },oPanel,,oFont2,,,,.T.,CLR_BLUE,)

	// Dados de acesso:

	// Tenant
	TSay():New(060,30,{|| STR0021 },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TGet():New(070,30,{ |u| If(PCount() > 0, cPDTenant := u, cPDTenant) } ,oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPDTenant)

	// Usuario
	TSay():New(090,30,{|| STR0022 },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TGet():New(100,30,{ |u| If(PCount() > 0, cPDUser := u, cPDUser) } ,oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPDUser)

	// Senha
	TSay():New(120,30,{|| STR0023 },oPanel,,oFont2,,,,.T.,CLR_BLUE,)
	TGet():New(130,30,{ |u| If(PCount() > 0, cPDPss := u, cPDPss) } ,oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.T.,,cPDPss)

	// Código Externo da Unidade de Negócio
	TSay():New(150,30, {|| STR0059 },oPanel,,oFont2,,,,.T.,CLR_BLUE)
	TGet():New(160,30, { |u| If(PCount() > 0, cExtBusId := u, cExtBusId) },oPanel,296,009,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cExtBusId)

Return lRet

/*/{Protheus.doc} VldStep2
Valida se é possivel fazer a comunucação/autenticação com a TPD com base nos dados informados

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
/*/
Static Function VldStep2() As Logical
	Local lRet As Logical

	lRet := .T.

	If Empty(cPDTenant)
		If !__lAutomat
			Aviso(STR0024, STR0025, {STR0028}, 3)
		EndIf
		
		lRet := .F.
	EndIf

	If lRet .And. Empty(cPDUser)
		If !__lAutomat
			Aviso(STR0024, STR0026, {STR0028}, 3)
		EndIf
		
		lRet := .F.
	EndIf

	If lRet .And. Empty(cPDPss)
		If !__lAutomat
			Aviso(STR0024, STR0027, {STR0028}, 3)
		EndIf
		
		lRet := .F.
	EndIf

	If lRet .And. Empty(cExtBusId)
		If !__lAutomat
			Aviso(STR0024, STR0060, {STR0028}, 3)
		EndIf
		
		lRet := .F.
	EndIf
	
	If lRet
		// Faz a gravação dos dados de acesso
		oRecHub:cCodeComp  := ALLTRIM(cExtBusId)
		oRecHub:cTenant    := ALLTRIM(cPDTenant)
		oRecHub:cUserName  := ALLTRIM(cPDUser)
		oRecHub:cPassword  := ALLTRIM(cPDPss)
		oRecHub:SaveParam()
		
		If !__lAutomat .And. !(lRet := IIf(Upper(Alltrim(cPDTenant)) == "TOTVS_INTERNO", .T., oRecHub:ValidConn()))
			MessageBox(STR0040 + Chr(13) + Chr(13) + STR0043 + Alltrim(oRecHub:cURLRAC) + Chr(13) + STR0044 + AllTrim(cPDTenant), STR0029,16 )
		EndIf

		lVldConn := lRet
	EndIf
Return lRet

/*/{Protheus.doc} Step4
Encerramento do processo

@author 	TOTVS SA
@since  	16/07/2021
@version 	12.1.33
@param 		oPanel
/*/
Static Function Step3(oPanel As Object)

	Local lRet     As Logical

	lRet := .T.

	TSay():New(025,25,{|| STR0032 },oPanel,,oFont1,,,,.T.,CLR_BLUE,)

Return lRet
