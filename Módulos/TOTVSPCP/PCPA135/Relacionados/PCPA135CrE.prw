#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA135.CH"

//Estáticas para guardar os parâmetros do Wizard
Static soProgrBar := Nil
Static snNivel    := 1
Static snStatus   := 3
Static snComps    := 2
Static sdDataDe   := SToD("        ")
Static sdDataAte  := SToD("        ")
Static snJaExist  := 1
Static snPreEstr  := 2
Static slAltPai   := .F.
Static scNovoPai  := CriaVar("G1_COD")

//Estáticas de controle
Static saRegInclu := {}  //{GG_COD, GG_COMP, GG_TRT}
Static saRegExclu := {}  //{GG_COD, GG_COMP, GG_TRT}
Static saListaCmp := {}  //{GG_LISTA, GG_COMP, GG_TRT, CARGOPAI, INDICADOR, LINHA}

//Estáticas para guardar os parâmetros
Static sMvAPRESTR := SuperGetMV("MV_APRESTR",.F.,.F.)
Static sMvPCPRLEP := SuperGetMV("MV_PCPRLEP",.F., 2)
Static sMvREVAUT  := SuperGetMV("MV_REVAUT",.F., .F.)
Static SMVARQPROD := If(GetMv('MV_ARQPROD')=="SBZ","SBZ","SB1")

//Estáticas de integração
Static sIntgPPI   := PCPIntgPPI()

/*/{Protheus.doc} PCPA135CrE
Cria estrutura a partir da pré-estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return lCriou, logical, indica se foi criada a estrutura
/*/
Function PCPA135CrE(aAutoCab)

	Local lCriou    := .F.
	Local lOk       := .T.
	Local oNewModel := FWLoadModel("PCPA135")
	Local oNewView  := FWLoadView("PCPA135")
	Local oViewExec := Nil
	Local cMsgErro := ""

	Default aAutoCab := Nil

	If aAutoCab <> Nil

		// Verificar se existe se foi passado o parametro AUTNIVCRIAEST - Considera Niveis
		nPos := aScan(aAutoCab, {|x| x[1] == "AUTNIVCRIAEST"})
		If nPos > 0 .And. !Empty(aAutoCab[nPos][2])
			// Verifica se os dados são validos
			If "|" + cValToChar(aAutoCab[nPos][2]) + "|" $"|1|2|"
				snNivel := aAutoCab[nPos][2]
			Else
				cMsgErro := STR0293 								// "Valor informado no parâmetro "
				cMsgErro += aAutoCab[nPos][1] + " "
				cMsgErro += STR0294 								// "inválido"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295})  // "Informe um valor válido."
				lOk := .F.
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Parâmetro "
				cMsgErro += "AUTNIVCRIAEST" + " "
				cMsgErro += STR0302 	// "não infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o parâmetro "
			EndIf
			lOk := .F.
		EndIf

		nPos := aScan(aAutoCab, {|x| x[1] == "AUTCONSIDSTT"})
		If lOk .and. (nPos > 0 .And. !Empty(aAutoCab[nPos][2]))
			If "|" + cValToChar(aAutoCab[nPos][2]) + "|" $"|1|2|3|"
				//Se o utiliza a alçada de aprovação, só considera pré-estruturas aprovadas
				If sMvAPRESTR
					If aAutoCab[nPos][2] == 1
						snStatus := aAutoCab[nPos][2]
					Else
						cMsgErro := STR0299 		// "Devido ao parâmetro MV_APRESTR, apenas pré-estruturas aprovadas podem gerar estrutura"
						Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0300})  // "Aprove a pré-estrutura antes de gerar a estrutra"
						lOk := .F.
					EndIf
				Else
					snStatus := aAutoCab[nPos][2]
				EndIf
			Else
				cMsgErro := STR0293 								// "Valor informado no parâmetro "
				cMsgErro += aAutoCab[nPos][1] + " "
				cMsgErro += STR0294 								// "inválido"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295})  // "Informe um valor válido."
				lOk := .F.
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Parâmetro "
				cMsgErro += "AUTCONSIDSTT" + " "
				cMsgErro += STR0302 	// "não infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o parâmetro "
			EndIf
			lOk := .F.
		EndIf

		nPos := aScan(aAutoCab, {|x| x[1] == "AUTCONSIDCOMP"})
		If lOk .and. (nPos > 0 .And. !Empty(aAutoCab[nPos][2]))
			If "|" + cValToChar(aAutoCab[nPos][2]) + "|" $"|1|2|3|"
				snComps := aAutoCab[nPos][2]
				// Caso selecionado a opção "Validos no periodo", atribui as datas.
				If snComps == 3
					nPos := aScan(aAutoCab, {|x| x[1] == "AUTDTDE"})
					If nPos > 0 .And. !Empty(aAutoCab[nPos][2])
						sdDataDe := aAutoCab[nPos][2]
					Else
						cMsgErro := STR0301 	// "Parâmetro "
						cMsgErro += "AUTDTDE" + " "
						cMsgErro += STR0302 	// "não infromado"
						Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTDE"})  // "Informe o parâmetro "
						lOk := .F.
					EndIf
					nPos := aScan(aAutoCab, {|x| x[1] == "AUTDTATE"})
					If lOk .and. (nPos > 0 .And. !Empty(aAutoCab[nPos][2]))
						sdDataAte := aAutoCab[nPos][2]
					Else
						If lOk
							cMsgErro := STR0301 	// "Parâmetro "
							cMsgErro += "AUTDTATE" + " "
							cMsgErro += STR0302 	// "não infromado"
							Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o parâmetro "
						EndIf
						lOk := .F.
					EndIf
				EndIf
			Else
				cMsgErro := STR0293 								// "Valor informado no parâmetro "
				cMsgErro += aAutoCab[nPos][1] + " "
				cMsgErro += STR0294 								// "inválido"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295})  // "Informe um valor válido."
				lOk := .F.
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Parâmetro "
				cMsgErro += "AUTCONSIDCOMP" + " "
				cMsgErro += STR0302 	// "não infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o parâmetro "
			EndIf
			lOk := .F.
		EndIf

		If lOk
			lOk := ValidaPag2()
		EndIf

		nPos := aScan(aAutoCab, {|x| x[1] == "AUTESTEX"})
		If lOk .and. (nPos > 0 .And. !Empty(aAutoCab[nPos][2]))
			If "|" + cValToChar(aAutoCab[nPos][2]) + "|" $"|1|2|"
				snNivel := aAutoCab[nPos][2]
			Else
				cMsgErro := STR0293 								// "Valor informado no parâmetro "
				cMsgErro += aAutoCab[nPos][1] + " "
				cMsgErro += STR0294 								// "inválido"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295})  // "Informe um valor válido."
				lOk := .F.
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Parâmetro "
				cMsgErro += "AUTESTEX" + " "
				cMsgErro += STR0302 	// "não infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o parâmetro "
			EndIf
			lOk := .F.
		EndIf

		nPos := aScan(aAutoCab, {|x| x[1] == "AUTPREESTGRAV"})
		If lOk .and. (nPos > 0 .And. !Empty(aAutoCab[nPos][2]))
			If "|" + cValToChar(aAutoCab[nPos][2]) + "|" $"|1|2|"
				snNivel := aAutoCab[nPos][2]
			Else
				cMsgErro := STR0293 								// "Valor informado no parâmetro "
				cMsgErro += aAutoCab[nPos][1] + " "
				cMsgErro += STR0294 								// "inválido"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295})  // "Informe um valor válido."
				lOk := .F.
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Parâmetro "
				cMsgErro += "AUTPREESTGRAV" + " "
				cMsgErro += STR0302 	// "não infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o parâmetro "
			EndIf
			lOk := .F.
		EndIf

		nPos := aScan(aAutoCab, {|x| x[1] == "AUTALTPAI"})
		If lOk .and. (nPos > 0 .And. (aAutoCab[nPos][2] == .T. .Or. aAutoCab[nPos][2] == .F.))
			If aAutoCab[nPos][2]
				slAltPai := .T.
				nPos := aScan(aAutoCab, {|x| x[1] == "AUTNVPAI"})
				If nPos > 0 .And. !Empty(aAutoCab[nPos][2])
					scNovoPai := aAutoCab[nPos][2]
				Else
					If lOk
						cMsgErro := STR0301 	// "Parâmetro "
						cMsgErro += "AUTNVPAI" + " "
						cMsgErro += STR0302 	// "não infromado"
						Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o parâmetro "
					EndIf
				EndIf
			EndIf
		Else
			If lOk
				cMsgErro := STR0301 	// "Parâmetro "
				cMsgErro += "AUTALTPAI" + " "
				cMsgErro += STR0302 	// "não infromado"
				Help(' ',1,"HELP" ,, cMsgErro,2,0,,,,,, {STR0295 + "AUTDTATE"})  // "Informe o parâmetro "
			EndIf
			lOk := .F.
		EndIf

		If lOk
			lCriou := ValidaPag3(oNewModel, .T.)
		EndIf

	Else
		oViewExec := FWViewExec():New()

		//Desabilita a edição dos campos
		oNewView:SetOnlyView("V_FLD_MASTER")
		oNewView:SetOnlyView("V_FLD_SELECT")
		oNewView:SetOnlyView("V_GRID_DETAIL")
		oNewView:setUpdateMessage(" ", STR0181) //"Estrutura criada com sucesso."

		oViewExec:setTitle(STR0169) //"Criar Estrutura"
		oViewExec:setOK({|oNewModel| lCriou := WizCriacao(oNewModel)})
		oViewExec:setCancel({|oNewModel| CanCriacao(oNewModel)})
		oViewExec:setSource("PCPA135")
		oViewExec:setView(oNewView)
		oViewExec:setModel(oNewModel)
		oViewExec:setOperation(MODEL_OPERATION_UPDATE)
		oViewExec:setModal(.F.)
		oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0038},; //"Confirmar"
							{.T.,STR0037},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})   //"Cancelar"
		oViewExec:openView(.T.)
	EndIf

Return lCriou

/*/{Protheus.doc} CanCriacao
Função acionada ao Cancelar a operação
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return .T., logical, permite o cancelamento
/*/
Static Function CanCriacao(oModel)

	oModel:lModify := .F.

Return .T.

/*/{Protheus.doc} WizCriacao
Abre o Wizard para a criação da estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return lCriou, logical, indica se o processamento foi confirmado e criou a estrutura
/*/
Static Function WizCriacao(oModel)

	Local oStepWiz := FWWizardControl():New(,{520, 670})
	Local oNewPag  := Nil
	Local lCriou   := .F.

	//Adiciona os passos no Wizard
	oStepWiz:ActiveUISteps()

	//Página 1
	oNewPag := oStepWiz:AddStep("1", {|oPanel| MontaPag1(oPanel)})
	oNewPag:SetStepDescription(STR0182) //"Início"

	//Página 2
	oNewPag := oStepWiz:AddStep("2", {|oPanel| MontaPag2(oPanel)})
	oNewPag:SetStepDescription(STR0183) //"Leitura"
	oNewPag:SetNextAction({|| ValidaPag2()})

	//Página 3
	oNewPag := oStepWiz:AddStep("3", {|oPanel| MontaPag3(oPanel)})
	oNewPag:SetStepDescription(STR0184) //"Gravação"
	oNewPag:SetNextAction({|| lCriou := ValidaPag3(oModel)})

	oStepWiz:Activate()
	oStepWiz:Destroy()

	aSize(saListaCmp,0)

Return lCriou

/*/{Protheus.doc} MontaPag1
Monta a primeira página do Wizard
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oPanel, object, painel a serem adicionados os componentes da página
@return Nil
/*/
Static Function MontaPag1(oPanel)

	//Configuração as fontes
	Local oFont13B := TFont():New("Arial", , -13, , .T.)
	Local oFont12  := TFont():New("Arial", , -12, , .F.)
	Local oFont12B := TFont():New("Arial", , -12, , .T.)

	//Textos da tela ("Bem-Vindo...")
	Local oSay1 := TSay():New(05, 10, {|| STR0185 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Criação de Estrutura"
	Local oSay2 := TSay():New(50, 10, {|| STR0186 }, oPanel, , oFont12B, , , , .T., , , 290, 20) //"Bem-Vindo..."
	Local oSay3 := TSay():New(70, 10, {|| STR0187 }, oPanel, , oFont12 , , , , .T., , , 320, 100, , , , , , , 3) //"Este assistente permite o preenchimento das informações para criação de estruturas com base nas pré-estruturas."

Return Nil

/*/{Protheus.doc} MontaPag2
Monta a segunda página do Wizard
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oPanel, object , painel a serem adicionados os componentes da página
@return Nil
/*/
Static Function MontaPag2(oPanel)

	//Configuração as fontes
	Local oFont13B := TFont():New("Arial", , -13, , .T.)
	Local oFont11  := TFont():New("Arial", , -11, , .F.)

	//Texto do cabeçalho
	Local oTitulo   := TSay():New(05, 10, {|| STR0188 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Parâmetros para leitura"
	Local oDecricao := TSay():New(15, 10, {|| STR0189 }, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Informe os parâmetros relacionados a leitura dos dados."

	//Grupo: Considera níveis
	Local oGroup1 := TGroup():New(45, 40, 90, 120, STR0190, oPanel, , , .T.) //"Considera níveis"
	Local oRadio1 := TRadMenu():New(55, 50, {STR0191, STR0192}, {|u| If(PCount() == 0, snNivel, snNivel := u)}, oGroup1, , , , , , , , 60, 40, , , , .T.) //"Todos","Primeiro Nível"

	//Grupo: Considera status
	Local oGroup2 := Nil
	Local oRadio2 := Nil

	//Grupo: Considera componentes
	Local oGroup3 := TGroup():New(45, 150, 150, 295, STR0193, oPanel, , , .T.) //"Considera componentes"
	Local oSay1   := TSay():New(097, 195, {|| STR0194 }, oGroup3, , oFont11, , , , .T., , , 30, 20) //"De:"
	Local oSay2   := TSay():New(112, 195, {|| STR0195 }, oGroup3, , oFont11, , , , .T., , , 30, 20) //"Até:"
	Local oTGet1  := TGet():New(095, 210, {|u| If(PCount() == 0, sdDataDe , sdDataDe  := u)}, oGroup3, 60, 10, "@D",, 0, ,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"sdDataDe" ,,,,.T.)
	Local oTGet2  := TGet():New(110, 210, {|u| If(PCount() == 0, sdDataAte, sdDataAte := u)}, oGroup3, 60, 10, "@D",, 0, ,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"sdDataAte",,,,.T.)
	Local oRadio3 := TRadMenu():New(55, 160, {STR0196, STR0197, STR0198}, ; //"Qualquer data" - "Data válida" - "Válidos no período"
	                                {|u| If(PCount() == 0, snComps, snComps := u)}, oGroup3, , ;
									{||  If(snComps == 3, EnableData(oTGet1, oTGet2, .T.), EnableData(oTGet1, oTGet2, .F.) )}, , , , , , 100, 60, , , , .T.)

	//Desabilita os campos de Data
	If snComps <> 3
		oTGet1:Disable()
		oTGet2:Disable()
	EndIf

	//Se o utiliza a alçada de aprovação, só considera pré-estruturas aprovadas
	If sMvAPRESTR
		snStatus := 1
	Else
		oGroup2 := TGroup():New(100, 40, 150, 120, STR0199, oPanel, , , .T.) //"Considera status"
		oRadio2 := TRadMenu():New(110, 50, {STR0200, STR0201, STR0202}, ; //"Aprovados" - "Rejeitados" - "Todos"
		                          {|u| If(PCount() == 0, snStatus, snStatus := u)}, oGroup2, , , , , , , , 60, 40, , , , .T.)
	EndIf

Return Nil

/*/{Protheus.doc} MontaPag3
Monta a terceira página do Wizard
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oPanel, object, painel a serem adicionados os componentes da página
@return Nil
/*/
Static Function MontaPag3(oPanel)

	//Configuração as fontes
	Local oFont13B := TFont():New("Arial", , -13, , .T.)
	Local oFont11  := TFont():New("Arial", , -11, , .F.)

	//Texto do cabeçalho
	Local oTitulo   := TSay():New(05, 10, {|| STR0203 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Parâmetros para gravação"
	Local oDecricao := TSay():New(15, 10, {|| STR0204 }, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Informe os parâmetros relacionados a gravação dos dados."

	//Grupo: Estruturas já existentes
	Local oGroup1 := TGroup():New(45, 40, 90, 145, STR0205, oPanel, , , .T.) //"Estruturas já existentes"
	Local oRadio1 := TRadMenu():New(55,  50, {STR0206, STR0207}, {|u| If(PCount() == 0, snJaExist, snJaExist := u)}, oGroup1, , , , , , , , 60, 40, , , , .T.) //"Sobrescreve" - "Mantêm"

	//Grupo: Pré-Estrutura gravada
	Local oGroup2 := TGroup():New(45, 190, 90, 295, STR0208, oPanel, , , .T.) //"Pré-Estrutura gravada"
	Local oRadio2 := TRadMenu():New(55, 200, {STR0209, STR0223}, {|u| If(PCount() == 0, snPreEstr, snPreEstr := u)}, oGroup2, , , , , , , , 60, 40, , , , .T.) //"Apaga" - "Mantém"

	//Altera codigo do pai?
	Local oCheck1 := TCheckBox():New(107, 40, STR0210, {|u| If(PCount() == 0, slAltPai, slAltPai := u)}, oPanel, 90, 40, , ; //"Altera código do produto pai "
	                                 {|| If(slAltPai, oTGet1:Enable(), ( scNovoPai := CriaVar("G1_COD"), oTGet1:Disable(), oTGet1:CtrlRefresh()) )  }, , , , , , .T., , , )
	Local oTGet1  := TGet():New(105, 130, {|u| If(PCount() == 0, scNovoPai, scNovoPai := u)}, oPanel, 100, 10, "@!", {|| ValidaPai()}, , , , , , .T., , , , , , , .F., .F., , "scNovoPai", , , , , .F.)

 	oTGet1:cF3 := "SB1"

	//Desabilita o campo Produto
	If !slAltPai
		oTGet1:Disable()
	EndIf

	//Define a barra de progresso
	soProgrBar := Nil
	soProgrBar := TMeter():New(140, 40, , 100, oPanel, 255, 12, , .T.)
	soProgrBar:lVisible := .F.

Return Nil

/*/{Protheus.doc} ValidaPai
Emite alerta caso o produto informado já possua estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return lOk, logic, indica se o produto informado pode ser utilizado
/*/
Static Function ValidaPai()

	Local lOk := .T.

	If !Empty(scNovoPai)
		SG1->(dbSetOrder(1))
		If SG1->(dbSeek(xFilial("SG1") + scNovoPai))
			Aviso(STR0211, STR0212,{"Ok"}) //"Atenção!" - "Já existe estrutura para esse produto."
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} EnableData
Habilita ou Desabilita os campos Data De e Data Até
@author Marcelo Neumann
@since 18/02/2019
@version P12
@param 01 oTGet1 , object, objeto do componente Data De
@param 02 oTGet2 , object, objeto do componente Data Até
@param 03 lEnable, logic , indica se deverá habilitar (.T.) ou desabiliar (.F.) os componentes
@return Nil
/*/
Static Function EnableData(oTGet1, oTGet2, lEnable)

	If lEnable
		oTGet1:Enable()
		oTGet2:Enable()
	Else
		sdDataDe  := SToD("        ")
		sdDataAte := SToD("        ")
		oTGet1:CtrlRefresh()
		oTGet2:CtrlRefresh()
		oTGet1:Disable()
		oTGet2:Disable()
	EndIf

Return Nil

/*/{Protheus.doc} ValidaPag2
Validação da segunda página do Wizard
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return lRet, logic, indica se a página está válida
/*/
Static Function ValidaPag2()

	Local lRet := .T.

	If snComps == 3
		If Empty(sdDataDe) .Or. Empty(sdDataAte)
			Help( ,  , "Help", , STR0213, 1, 0, , , , , , {""})  //"Período informado inválido."
			lRet := .F.
		EndIf

		If sdDataDe > sdDataAte
			Help( ,  , "Help", ,  STR0213, ; //"Período informado inválido."
			     1, 0, , , , , , {STR0214	} ) //"Data De deve ser menor que Data Até."
			lRet := .F.
		EndIf
	EndIf

	//Se a página estiver válida, esconde a barra de progresso (caso ela já tenha sido criada/exibida)
	If lRet
		If !Empty(soProgrBar)
			soProgrBar:lVisible := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} ValidaPag3
Validação da terceira página do Wizard e processamento
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oModel, object, modelo principal
@return lRet, logic, indica se o processamento foi finalizado com sucesso
/*/
Static Function ValidaPag3(oModel, lAuto)

	Local lRet := .T.

	If slAltPai
		If Empty(scNovoPai)
			Help( ,  , "Help", ,  STR0215, ; //"Código do Produto não informado."
				 1, 0, , , , , , {STR0216} ) //"Informe um código para o produto pai ou desmarque a opção de alteração de código."
			lRet := .F.
		Else
			lRet := ExistCpo("SB1", scNovoPai)
		EndIf
	EndIf

	//Se a página está válida, inicia a gravação da estrutura
	If lRet
		lRet := GravaG1New(oModel, lAuto)
		//lRet := GravaSG1(oModel, lAuto)
	EndIf
	If lRet
		If ExistBlock ("MTA202CRIA")
			ExecBlock ("MTA202CRIA",.F.,.F.,{oModel:GetModel("FLD_MASTER"):GetValue("GG_COD"),scNovoPai})
		Endif
	EndIf

Return lRet

/*/{Protheus.doc} GravaG1New
Realiza o processamento da gravação da estrutura
@author Michele Girardi
@since 16/10/2024
@version P12
@param 01 oModel, object, modelo principal
@param 02 lAuto, lógico, indica se é rotina automática
@return lRet, logic, indica se o processamento foi finalizado com sucesso
/*/
Static Function GravaG1New(oModel, lAuto)
	Local aAliasAnt  := {}
	Local aCodiSeek  := {}
	Local aNomePos   := {}
	Local aRegsSGG   := {}
	Local cAlias     := Alias()
	Local cAliasQry  := GetNextAlias()
	Local cCodiSeek  := ""
	Local cCpoDest   := If(SMVARQPROD=="SBZ","BZ_QB","B1_QB")
	Local cNomeArq   := ""
	Local cNomeCamp  := ""
	Local cProduto   := ""
	Local cProPai    := ""
	Local cQuery     := ""
	Local cRevAtual  := ""
	Local cRevFim    := CriaVar("G1_REVFIM")
	Local cRevFimAnt := ""
	Local cRevIni    := CriaVar("G1_REVINI")
	Local lAchouCod  := .F.
	Local lAchouG1   := .F.
	Local lGravouSG1 := .F.
	Local lGrvRev    := .T.
	Local lPCPREVATU := FindFunction( 'PCPREVATU' )
	Local lQBase     := .T.
	Local lRet       := .T.
	Local nInd       := 0
	Local nISGG      := 0
	Local nPosComp   := SGG->(FieldPos("GG_COMP"))
	Local nPosicao   := 0
	Local nPosTrt    := SGG->(FieldPos("GG_TRT "))
	Local nRecnoG1   := 0
	Local nTotal     := 0
	Local nx         := 0
	Local oEvent135  := NIL
	Local oEvent200  := NIL
	Local oTempTable := NIL

	Private	nEstru   := 0

	If lAuto
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		oModel:GetModel("FLD_MASTER"):SetValue("CEXECAUTO", "S")
	EndIf

	cProduto   := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")

	oEvent200 := PCPA200EVDEF():New()
	oEvent200:PerguntaPCPA200(.F.)

	oEvent135 := PCPA200EVDEF():New()
	oEvent135:PerguntaPCPA135C(.F., .F.)

	dbSelectArea("SG1")
	SG1->(dbSetOrder(1))

	//Cria arquivo de trabalho com a estrutura completa
	cNomeArq := Estrut2(cProduto,NIL,NIL,@oTempTable,NIL,.T.,.F.,,.F.)

	//Percorre arquivo para atualizar estrutura
	dbSelectArea('ESTRUT')
	ESTRUT->(dbGotop())
	nTotal := Lastrec()

	If !lAuto
		//Exibe a barra de progresso
		soProgrBar:SetTotal(nTotal)
		soProgrBar:Set(0)
		soProgrBar:lVisible := .T.
	EndIf

	Begin Transaction
		While !ESTRUT->(Eof())

			If !lAuto
				nInd++
				soProgrBar:Set(nInd)
			EndIf

			//Caso tenha marcado somente primeiro nivel
			If snNivel == 2 .And. Val(ESTRUT->NIVEL) > 1
				ESTRUT->(dbSkip())
				Loop
			EndIf

			SGG->(dbGoto(ESTRUT->REGISTRO))

			//Caso o parâmento MV_APRESTR esteja habilitado somente deverá ser gerada a estrutura
			//para aquelas que foram aprovadas pelo grupo de aprovação do controle de alçada
			If (sMvAPRESTR .And. SGG->GG_STATUS <> "2")
				ESTRUT->(dbSkip())
				Loop
			EndIf

			// Verifica o status a ser considerado
			If (snStatus == 1 .And. SGG->GG_STATUS <> "2") .Or. (snStatus == 2 .And. SGG->GG_STATUS <> "3")
				ESTRUT->(dbSkip())
				Loop
			EndIf

			// Valida data com database
			If snComps == 2 .And. ((dDataBase < SGG->GG_INI)  .Or. (dDataBase > SGG->GG_FIM))
				ESTRUT->(dbSkip())
				Loop
			EndIf

			// Valida data com data de parâmetros
			If snComps == 3 .And. ((SGG->GG_INI > sdDataAte)  .Or. (SGG->GG_FIM < sdDataDe))
				ESTRUT->(dbSkip())
				Loop
			EndIf

			dbSelectArea("SG1")

			// Verifica qual o nome a ser alterado
			If slAltPai .And. !Empty(scNovoPai) .And. Val(ESTRUT->NIVEL) == 1
				cCodiSeek := scNovoPai
			Else
				cCodiSeek := SGG->GG_COD
			EndIf

			lAchouCod := SG1->(dbSeek(xFilial("SG1")+cCodiSeek))

			//Processa gravacao se não achou o código ou se permite sobreposição
			If snJaExist == 1 .Or. (snJaExist == 2 .And. !lAchouCod)
				lGravouSG1:=.T.

				//Sobrepõe estrutura caso necessário
				If lAchouCod .And. !sMvREVAUT
					While !EOF() .And. xFilial("SG1")+cCodiSeek == SG1->G1_FILIAL+SG1->G1_COD
						Reclock("SG1",.F.)
							SG1->(dbDelete())
						MsUnlock()

						SG1->(dbSkip())
					End
				EndIf

				//Array com caracteristicas de campo
				//Criado para acelerar o processo evitando fieldpos e fieldname a todo momento
				If Len(aNomePos) == 0
					For nx := 1 to SGG->(FCount())
						cNomeCamp := "G1_"+Substr(SGG->(FieldName(nx)),4)
						nPosicao  := SG1->(FieldPos(cNomeCamp))
						// Grava todos os campos de SGG (mesmo nao existindo em SG1)
						// Array com
						// 1 Nome do campo no SG1
						// 2 Posicao do campo no SG1
						// 3 Posicao do campo no SGG
						Aadd(aNomePos,{cNomecamp,nPosicao,nx})
					Next nx
				EndIf

				//Carrega as informações do registro SGG
				nISGG++
				Aadd(aCodiSeek,cCodiSeek)
				Aadd(aRegsSGG,Array(SGG->(FCount())))
				For nx := 1 to SGG->(FCount())
					aRegsSGG[nISGG,nx] := SGG->(FieldGet(nx))
				Next

				//Grava status atualizado
				Reclock("SGG",.F.)
				If slAltPai .And. !Empty(scNovoPai) .And. Val(ESTRUT->NIVEL) == 1
					//Novo código do produto
					Replace GG_COD With scNovoPai
				EndIf
				Replace GG_STATUS With "4"

				If snPreEstr == 1
					SGG->(dbDelete())
				EndIf
				MsUnlock()

				//Grava quantidade base na SB1
				If Val(ESTRUT->NIVEL) == 1 .And. lQBase
					aAliasAnt := GetArea()
					dbSelectArea(SMVARQPROD)
					(SMVARQPROD)->(dbSetOrder(1))
					If (SMVARQPROD)->(dbSeek(xFilial(SMVARQPROD)+SGG->GG_COD))
						If Substr(cCpoDest,1,2) == "B1"
							SB1->(dbSeek(xFilial("SB1")+SGG->GG_COD))
						EndIf
						Reclock(If(cCpoDest=="BZ_QB","SBZ","SB1"),.F.)
						If SMVARQPROD == "SBZ"
							Replace &(cCpoDest) With SBZ->BZ_QBP
						Else
							Replace &(cCpoDest) With SB1->B1_QBP
						EndIf
						MsUnlock()
					Else
						SB1->(dbSeek(xFilial("SB1")+SGG->GG_COD))
						RecLock("SB1",.F.)
						Replace SB1->B1_QB With SB1->B1_QBP
						MsUnLock()
					EndIf
					lQBase:=.F.
					RestArea(aAliasAnt)
				EndIf
			EndIf

			dbSelectArea('ESTRUT')
			ESTRUT->(dbSkip())
		End

		If lGravouSG1

			If !lAuto
				//Exibe a barra de progresso
				soProgrBar:SetTotal(Len(aRegsSGG))
				soProgrBar:Set(0)
				soProgrBar:lVisible := .T.
				nInd := 0
			EndIf

			cRevFimAnt := ""

			//Le as informações dos registros da SGG contidas no array e grava as mesmas na SG1
			For nISGG := 1 to Len(aRegsSGG)

				cCodiSeek := aCodiSeek[nISGG]

				IF cProPai <> aCodiSeek[nISGG]
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(dbseek(xFilial("SB1")+cCodiSeek))
					cRevAtual := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
				EndIf

				If !lAuto
					nInd++
					soProgrBar:Set(nInd)
				EndIf

				// Posiciona o registro na revisão atual, a quantidade sendo a mesma, vai entender que não precisa criar uma nova revisão.
				// Se existir, grava o recno na variavel nRecnoG1 e já posiciona
				lAchouG1 := .F.
				nRecnoG1 := 0

				cQuery := "SELECT R_E_C_N_O_ RECG1"
				cQuery += "	FROM "+RetSqlName('SG1') + " SG1"
				cQuery += " WHERE SG1.G1_FILIAL   = '" + xFilial("SG1") + "'"
				cQuery += " AND SG1.G1_COD      = '" + cCodiSeek + "'"
				cQuery += " AND SG1.G1_COMP     = '" + aRegsSGG[nISGG,nPosComp]+ "'"
				cQuery += " AND SG1.G1_TRT      = '" + aRegsSGG[nISGG,nPosTrt ]+ "'"
				cQuery += " AND SG1.G1_REVINI  <= '" + cRevAtual + "'"
				cQuery += " AND SG1.G1_REVFIM  >= '" + cRevAtual + "'"
				cQuery += " AND SG1.D_E_L_E_T_ = ''"

				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

				If !(cAliasQry)->(Eof())
					nRecnoG1 := (cAliasQry)->RECG1
					SG1->(dbGoTo(nRecnoG1))
					lAchouG1 := .T.
				EndIf

				(cAliasQry)->(dbCloseArea())

				IF (sMvREVAUT .Or. oEvent200:mvlArquivoRevisao)
					cRevIni := ""
					If lAchouG1
						DbSelectArea("SGG")
						SGG->(DbSetOrder(1))
						If SGG->(dbSeek(xFilial("SGG")+cCodiSeek+aRegsSGG[nISGG,nPosComp]+aRegsSGG[nISGG,nPosTrt]))
							If (SG1->G1_REVFIM == cRevAtual) .and. (SG1->G1_QUANT == SGG->GG_QUANT)
								cRevIni := SG1->G1_REVINI
							EndIf
						EndIf
					EndIf

					IF cProPai <> aCodiSeek[nISGG]
						lGrvRev := P135GrvRev(lAuto)
						If lGrvRev
							cRevFim := A200Revis(aCodiSeek[nISGG],.F.)
						EndIf

						If !sMvREVAUT
							cRevFim := "ZZZ"
						EndIf
						cRevFimAnt := cRevFim
					Else
						cRevFim := cRevFimAnt
					EndIf

					If sMvREVAUT
						IF Empty(cRevIni)
							cRevIni  := cRevFim
						EndIf
					EndIf

					cProPai := aCodiSeek[nISGG]
				EndIf

				dbSelectArea("SG1")

				Begin Transaction
					// Se ainda não existe o componente na estrutura ou se ele estava fora de uso.
					If !lAchouG1 .Or. (cRevIni  == cRevFim)
						Reclock("SG1",.T.)
						For nx:=1 to Len(aNomePos)
							If aNomePos[nx,2] > 0  // Verifica se campo existe em SG1
								FieldPut(aNomePos[nx,2],aRegsSGG[nISGG,nx])
		    				EndIf
						Next nx

						// Grava informacoes especificas
						// Filial
						SG1->G1_FILIAL := xFilial("SG1")
						SG1->G1_COD	   := cCodiSeek		//Incluido para nao gerar erro se o codigo do pai for alterado
						Replace G1_REVINI With cRevIni
						Replace G1_REVFIM With cRevFim
					Else
						SG1->(dbGoTo(nRecnoG1))
						Reclock("SG1",.F.)
						Replace G1_REVFIM With cRevFim
						For nX := 1 To Len(aNomePos)
							If aNomePos[nx,2] > 0  //Verifica se campo existe em SG1
								If sMvREVAUT
									//Se for revisão automática, considera a próxima revisão no G1_REVINI e G1_REVFIM
									If aNomePos[nx,1] == "G1_REVINI"
										FieldPut(aNomePos[nx,2],cRevIni)
									ElseIf aNomePos[nx,1] == "G1_REVFIM"
										FieldPut(aNomePos[nx,2],cRevFim)
									ElseIf aNomePos[nx,1] == "G1_FILIAL"
										FieldPut(aNomePos[nx,2],xFilial("SG1"))
									Else
										FieldPut(aNomePos[nx,2],aRegsSGG[nISGG,nx])
									EndIf
								Else
									FieldPut(aNomePos[nx,2],aRegsSGG[nISGG,nx])
								EndIf
		    				EndIf
						Next nX
					EndIf
					MsUnlock()
				End Transaction
			Next

			IF snPreEstr == 1

				If !lAuto
					//Exibe a barra de progresso
					soProgrBar:SetTotal(Len(aRegsSGG))
					soProgrBar:Set(0)
					soProgrBar:lVisible := .T.
					nInd := 0
				EndIf

				//Le as informações dos registros da SGG contidas no array e exclui a SGG
				For nISGG := 1 to Len(aRegsSGG)

					If !lAuto
						nInd++
						soProgrBar:Set(nInd)
					EndIf

					cCodiSeek := aCodiSeek[nISGG]

					DbSelectArea("SGG")
					SGG->(DbSetOrder(1))
					If SGG->(dbSeek(xFilial("SGG")+cCodiSeek+aRegsSGG[nISGG,nPosComp]+aRegsSGG[nISGG,nPosTrt]))
						Reclock("SGG",.F.)
							SGG->(dbDelete())
						MsUnlock()
					EndIf
				Next nISGG
			EndIf

		EndIf
	End Transaction
	FimEstrut2(Nil,oTempTable)

	GravAltPre(oModel)

	dbSelectArea(cAlias)

Return lRet


/*/{Protheus.doc} GravaSG1
Realiza o processamento da gravação da estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oModel, object, modelo principal
@return lRet, logic, indica se o processamento foi finalizado com sucesso
/*/
Static Function GravaSG1(oModel, lAuto)

	Local aCab      := {}
	Local aItem     := {}
	Local cBkpPai   := scNovoPai
	Local cCargoPai := ""
	Local nQtdBase  := Nil
	Local nTotal    := Nil
	Local nOperAuto := 3
	Local lRet      := .F.
	Local oView     := FWViewActive()
	Local nAcao		:= 1 	// 1 = Cria a estrutura // 2 = Altera a pré-estrutura // 3 = Mantém no Wizard

	Private lMsErroAuto := .F.

	If lAuto
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		oModel:GetModel("FLD_MASTER"):SetValue("CEXECAUTO", "S")
		//Adiciona o produto PAI.
		cCargoPai := P135AddPai(oModel:GetModel("FLD_MASTER"):GetValue("GG_COD"))
		//Carrega os componentes
		P135TreeCh(.F.,cCargoPai)
		nQtdBase  := oModel:GetModel("FLD_MASTER"):GetValue("NQTBASE")
		nTotal    := oModel:GetModel("GRID_DETAIL"):Length() + 1
	Else
		nQtdBase  := oModel:GetModel("FLD_MASTER"):GetValue("NQTBASE")
		nTotal    := oModel:GetModel("GRID_DETAIL"):Length() + 1
	EndIf

	//Limpa as mensagens de HELP
	FwClearHLP()

	If !lAuto
		//Exibe a barra de progresso
		soProgrBar:SetTotal(nTotal)
		soProgrBar:Set(0)
		soProgrBar:lVisible := .T.
	EndIf

	//Inicializa as variáveis de controle
	IniciaArr()

	//Verifica se será utilizado um pai diferente
	If !slAltPai
		scNovoPai := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
	EndIf

	If !lAuto
		cCargoPai := oModel:GetModel("FLD_MASTER"):GetValue("CARGO")
		P135TrSeek(cCargoPai, , .T.)
	EndIf

	//Cabeçalho para o ExecAuto
	aCab := {{"G1_COD"   , scNovoPai, NIL},; //Código do produto PAI
	         {"G1_QUANT" , nQtdBase , NIL},; //Quantidade base do produto PAI
	         {"ATUREVSB1", "N"      , NIL},; //A variável ATUREVSB1 é utilizada para gerar nova revisão quando MV_REVAUT=.F.
	         {"NIVALT"   , "N"      , NIL}}  //A variável NIVALT é utilizada para recalcular ou não os níveis da estrutura.

	//Prepara as tabelas que serão usadas na função recursiva
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	dbSelectArea("SVG")
	SVG->(dbSetOrder(1))
	dbSelectArea("SG1")
	SG1->(dbSetOrder(1))
	If SG1->(dbSeek(xFilial("SG1") + scNovoPai))
		//Se já existe estrutura para o pai, altera para Modificação
		nOperAuto := 4
	EndIf

	//Carrega os componentes
	lRet := CargaItens(aItem, oModel, .F., cCargoPai, lAuto)

	If lRet
		If Empty(aItem)
			Help( ,  , "Help", ,  STR0217, ; //"Não existem registros para criar a estrutura."
			     1, 0, , , , , , {STR0218} ) //"Revise os parâmetros informados."
			lRet := .F.
		Else
			//Valida a Lista de Componente
			nAcao := ValidLista(oModel, lAuto)
			If nAcao == 1
				//Carrega os registros que deverão ser excluídos
				ExcluiSG1(aItem)

				//Processa a Criação/Alteração da estrutura
				MSExecAuto({|x,y,z,w| PCPA200(x,y,z,w)}, aCab, aItem, nOperAuto, "PCPA135CrE")

				If !lAuto
					//Seta valor máximo na barra de progresso
					soProgrBar:Set(nTotal)
				EndIf

				//Verifica se ocorreu algum erro, e exibe a mensagem
				If lMsErroAuto
					lRet := .F.
					MostraErro()
					DesfazAltP(oModel)
				Else
					//Se integra com o MES, exibe a mensagem de alerta caso tenha ocorrido algum erro
					If sIntgPPI
						P200ErrPPI()
					EndIf
					lRet := .T.
				EndIf
			ElseIf nAcao == 2
				oView:SetUpdateMessage(" ", STR0276) //"Pré-estrutura alterada com sucesso."
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//Retorna a variável com o pai informado pelo usuário
	scNovoPai := cBkpPai

Return lRet

/*/{Protheus.doc} IniciaArr
Inicializa as variáveis utilizadas no processamento
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return Nil
/*/
Static Function IniciaArr()

	If saRegInclu == NIL
		saRegInclu := {}
	Else
		aSize(saRegInclu,0)
	EndIf

	If saRegExclu == NIL
		saRegExclu := {}
	Else
		aSize(saRegExclu,0)
	EndIf

Return Nil

/*/{Protheus.doc} CargaItens
Seleciona os registros que serão utilizados na criação da estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 aItem     , array 	, array com os itens a serem enviados ao ExecAuto
@param 02 oModel    , object	, modelo principal
@param 03 lRecursiva, logic 	, indica se é uma chamada recursiva da função
@param 04 cCargoPai , characters, campo CARGO do pai
@return lRet, logic, indica se ouve erro durante a carga dos dados
/*/
Static Function CargaItens(aItem, oModel, lRecursiva, cCargoPai, lAuto)

	Local oMdlGrd    := oModel:GetModel("GRID_DETAIL")
	Local oMdlSelec	 := oModel:GetModel("FLD_SELECT")
	Local cCargoAtu  := oMdlSelec:GetValue("CARGO")
	Local cCodSeek   := ""
	Local lExiste    := .T.
	Local nInd       := 1
	Local lRet       := .T.

	Default lAuto := .F.

	//Se estiver na primeira chamada, pai pode não ser o que está carregado no modelo
	If lRecursiva
		cCodSeek := oMdlGrd:GetValue("GG_COD", 1)
	Else
		cCodSeek := scNovoPai
	EndIf

	//Verifica se o produto possui estrutura
	If SG1->(dbSeek(xFilial("SG1") + cCodSeek))

		//Sobrescreve
		If snJaExist == 1
			While !SG1->(Eof())                     .And. ;
				   SG1->G1_FILIAL == xFilial("SG1") .And. ;
				   SG1->G1_COD    == cCodSeek

				If ExistNaRev()
					//Se o componente não está na pré-estrutura, deve deletar o registro (sobrescrever estrutura)
					If aScan(saRegInclu, {|x| x[1] == SG1->G1_COD  .And. ;
											  x[2] == SG1->G1_COMP .And. ;
											  x[3] == SG1->G1_TRT}) == 0
						aAdd(saRegExclu, {SG1->G1_COD, SG1->G1_COMP, SG1->G1_TRT})
					EndIf
				EndIf

				SG1->(dbSkip())
			End

		//Mantêm
		Else
			//Se foi marcado para manter as estruturas existentes, retorna
			Return lRet
		EndIf
	EndIf

	//Percorre os componentes da pré-estrutura
	For nInd := 1 To oMdlGrd:Length()

		//Tratativa para não processar mais de uma vez o mesmo componente
		If aScan(saRegInclu, {|x| x[1] == oMdlGrd:GetValue("GG_COD" , nInd) .And. ;
		                          x[2] == oMdlGrd:GetValue("GG_COMP", nInd) .And. ;
		                          x[3] == oMdlGrd:GetValue("GG_TRT" , nInd)}) == 0

			oMdlGrd:GoLine(nInd)
			aAdd(saRegInclu, {oMdlGrd:GetValue("GG_COD" ),;
			                  oMdlGrd:GetValue("GG_COMP"),;
							  oMdlGrd:GetValue("GG_TRT" )})

			//Valida os parametros informados na tela
			If ValidParam(oMdlGrd)

				//Verifica se o componente existe
				lExiste := .F.
				If SG1->(dbSeek(xFilial("SG1") + cCodSeek + oMdlGrd:GetValue("GG_COMP") + oMdlGrd:GetValue("GG_TRT")))
					While !SG1->(Eof())                                  .And. ;
					       SG1->G1_FILIAL == xFilial("SG1")              .And. ;
					       SG1->G1_COD    == cCodSeek                    .And. ;
					       SG1->G1_COMP   == oMdlGrd:GetValue("GG_COMP") .And. ;
					       SG1->G1_TRT    == oMdlGrd:GetValue("GG_TRT")

						If ExistNaRev()
							//Sobrescreve
							If snJaExist == 1
								//Se o componente existe na estrutura na revisão atual, o mesmo será alterado ao invés de excluído
								nPos := aScan(saRegExclu, {|x| x[1] == cCodSeek                    .And. ;
								                               x[2] == oMdlGrd:GetValue("GG_COMP") .And. ;
															   x[3] == oMdlGrd:GetValue("GG_TRT")})
								aDel(saRegExclu, nPos)
								aSize(saRegExclu,Len(saRegExclu) - 1)
							EndIf

							lExiste := .T.
							Exit
						EndIf

						SG1->(dbSkip())
					End
				EndIF

				//Se o componente veio de uma lista de componentes, valida se continua consistente
				If !Empty(oMdlGrd:GetValue("GG_LISTA"))
					//Valida os campos do componente com a lista
					aAdd(saListaCmp, {oMdlGrd:GetValue("GG_LISTA"), ;
					                  oMdlGrd:GetValue("GG_COMP") , ;
									  oMdlGrd:GetValue("GG_TRT")  , ;
									  cCargoPai                   , ;
									  ValCpoList(oMdlGrd, nInd)   , ;
									  oMdlGrd:GetLine()} )
				EndIf

				//Carrega o array aItem com as informações do componente
				CargaComp(aItem, oMdlGrd, nInd, lRecursiva, lExiste)

				//Grava a alteração na Pré-Estrutura
				GravAltPre(oModel)

				//Todos os níveis
				If snNivel == 1
					//Muda o produto selecionado na tree e faz a chamada recursiva
					P135TrSeek(oMdlGrd:GetValue("CARGO"), , .T.)
					If !oMdlGrd:IsEmpty()
						lRet := CargaItens(aItem, oModel, .T., oMdlSelec:GetValue("CARGO"))
					EndIf
					P135TrSeek(cCargoAtu, , .T.)
				EndIf
			EndIf
		EndIf


		//Atualiza a barra de progresso quando estiver no produto PAI
		If !lRecursiva .and. !lAuto
			soProgrBar:Set(nInd)
		EndIf

	Next nInd

Return lRet

/*/{Protheus.doc} CargaComp
Carrega as informações do componente no array do ExecAuto
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 aItem     , array  , array dos itens (ExecAuto)
@param 02 oMdlGrd   , object , modelo da grid dos componentes
@param 03 nLine     , numeric, indica a linha do componente
@param 04 lRecursiva, logic  , indica se é uma chamada recursiva da função
@param 05 lAltera   , logic  , indica se é uma alteração (se componente existe)
@return Nil
/*/
Static Function CargaComp(aItem, oMdlGrd, nLine, lRecursiva, lAltera)

	Local aFields := oMdlGrd:oFormModelStruct:aFields
	Local aGets   := {}
	Local cUsaAlt := "1"
	Local nIndCps := 1

	//Percorre todos os campos do componente da pré-estrutura
	For nIndCps := 1 To Len(aFields)
		If !oMdlGrd:oFormModelStruct:GetProperty(aFields[nIndCps][3], MODEL_FIELD_VIRTUAL)
			If aFields[nIndCps][3] == "GG_COD" .And. !lRecursiva
				aAdd(aGets, { NomeNaSG1(aFields[nIndCps][3]), scNovoPai, NIL })
			ElseIf aFields[nIndCps][3] == "GG_FILIAL"
				aAdd(aGets, { NomeNaSG1(aFields[nIndCps][3]), xFilial("SG1"), NIL })
			Else
				aAdd(aGets, { NomeNaSG1(aFields[nIndCps][3]), oMdlGrd:GetValue(aFields[nIndCps][3], nLine), NIL })
			EndIf
		EndIf
	Next nIndCps

	If lAltera
		aAdd(aGets, {"LINPOS", "G1_COD+G1_COMP+G1_TRT", SG1->G1_COD, SG1->G1_COMP, SG1->G1_TRT})
	EndIf

	cUsaAlt := InitPad(GetSX3Cache("G1_USAALT","X3_RELACAO"))

	//Atribui conteúdo default para o campo G1_USAALT
	aAdd(aGets, { "G1_USAALT", cUsaAlt, NIL })

	aAdd(aItem, aGets)

Return Nil

/*/{Protheus.doc} ValidParam
Valida o componente com os filtros informados no Wizard
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oMdlGrd, object, modelo da grid dos componentes
@return lRet, logic, indica se o componente deve ser utilizado na criação da estrutura
/*/
Static Function ValidParam(oMdlGrd)

	If !Empty(oMdlGrd:GetValue("GG_LISTA"))
		Return .T.
	EndIf

	//Considera Status
	Do Case
		//Aprovados
		Case snStatus == 1
			If oMdlGrd:GetValue("CSTATUS") <> "2"
				Return .F.
			EndIf

		//Rejeitados
		Case snStatus == 2
			If oMdlGrd:GetValue("CSTATUS") <> "3"
				Return .F.
			EndIf
	EndCase

	//Considera Componentes
	Do Case
		//Data válida
		Case snComps == 2
			If dDataBase < oMdlGrd:GetValue("GG_INI") .Or. dDataBase > oMdlGrd:GetValue("GG_FIM")
				Return .F.
			EndIf

		//Válidos no período
		Case snComps == 3
			If oMdlGrd:GetValue("GG_INI") > sdDataAte
				Return .F.
			EndIf

			If oMdlGrd:GetValue("GG_FIM") < sdDataDe
				Return .F.
			EndIf
	EndCase

Return .T.

/*/{Protheus.doc} NomeNaSG1
Converte o nome do campo entre SGG e SG1
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 cCampo, characters, campo a ser convertido
@return cCampo, characters, campo convertido - StrTran(cCampo, "GG_", "G1_")
/*/
Static Function NomeNaSG1(cCampo)

Return StrTran(cCampo, "GG_", "G1_")

/*/{Protheus.doc} GravAltPre
Altera o componente no modelo da pré-estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oModel, object, modelo principal (pré-estrutura)
@return Nil
/*/
Static Function GravAltPre(oModel)

	Local oMdlGrid  := oModel:GetModel("GRID_DETAIL")
	Local oMdlGrava := oModel:GetModel("GRAVA_SGG")
	Local aFields   := oMdlGrid:oFormModelStruct:aFields
	Local cCampo    := ""
	Local lAchou    := .F.
	Local nIndCps   := 0

	If !oMdlGrava:IsEmpty()
		oMdlGrava:AddLine()
	EndIf

	//Inclui o componente no modelo de gravação do PCPA135
	For nIndCps := 1 to Len(aFields)
		cCampo := AllTrim(aFields[nIndCps][3])
		oMdlGrava:LoadValue(cCampo, oMdlGrid:GetValue(cCampo))
	Next nIndCps

	oMdlGrava:LoadValue("LINHA", oMdlGrid:GetLine())

	DbSelectArea("SGG")
	SGG->(DbSetOrder(1))
	If SGG->(dbSeek(xFilial("SGG")+oMdlGrava:GetValue("GG_COD")+oMdlGrava:GetValue("GG_COMP")+oMdlGrava:GetValue("GG_TRT")))
		oMdlGrava:LoadValue("CSTATUS", SGG->GG_STATUS)
		lAchou := .T.
	EndIf

	//Não encontrou -- Verifica se existe estrutura para o novo produto
	If !lAchou .And. slAltPai .And. !Empty(scNovoPai)
		If SGG->(dbSeek(xFilial("SGG")+scNovoPai+oMdlGrava:GetValue("GG_COMP")+oMdlGrava:GetValue("GG_TRT")))
			oMdlGrava:LoadValue("GG_COD", SGG->GG_COD)
			oMdlGrava:LoadValue("CSTATUS", SGG->GG_STATUS)
			lAchou := .T.
		EndIf
	EndIf

	If !lAchou .And. snPreEstr == 1
		oMdlGrava:LoadValue("DELETE", .T.)
	EndIf

Return Nil

/*/{Protheus.doc} DesfazAltP
Limpa o modelo de gravação do PCPA135 para não alterar nenhuma informação
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oModel, object, modelo principal (pré-estrutura)
@return Nil
/*/
Static Function DesfazAltP(oModel)

	Local oMdlGrava := oModel:GetModel("GRAVA_SGG")
	Local nInd      := 0

	FwModelActive(oModel)

	For nInd := 1 to oMdlGrava:Length()
		If oMdlGrava:IsDeleted(nInd)
			Loop
		EndIf

		oMdlGrava:GoLine(nInd)
		oMdlGrava:DeleteLine()
	Next nInd

Return Nil

/*/{Protheus.doc} ExcluiSG1
Carrega o array com os registros que deverão ser excluídos
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 aItem, array, array com os itens a serem enviados ao ExecAuto
@return Nil
/*/
Static Function ExcluiSG1(aItem)

	Local nInd  := 1

	//Sobrescreve
	If snJaExist == 1
		For nInd := 1 to Len(saRegExclu)
			If !Empty(saRegExclu[nInd][1])
				AddRegDel(aItem, nInd)
			EndIf
		Next nInd
	EndIf

Return Nil

/*/{Protheus.doc} AddRegDel
Adiciona no array aItem (ExecAuto) o componente que deve ser excluído
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 aItem, array  , array com os itens a serem enviados ao ExecAuto
@param 02 nInd , numeric, posição do array saRegExclu com o registro a ser excluído
@return Nil
/*/
Static Function AddRegDel(aItem, nInd)

	Local aGets := {}

	aAdd(aGets, {"G1_COD"   , saRegExclu[nInd][1]    , NIL})
	aAdd(aGets, {"G1_COMP"  , saRegExclu[nInd][2]    , NIL})
	aAdd(aGets, {"G1_TRT"   , saRegExclu[nInd][3]    , NIL})
	aAdd(aGets, {"LINPOS"   , "G1_COD+G1_COMP+G1_TRT", saRegExclu[nInd][1], saRegExclu[nInd][2], saRegExclu[nInd][3]})
	aAdd(aGets, {"AUTDELETA", "S"                    , NIL})
	aAdd(aItem, aGets)

Return Nil

/*/{Protheus.doc} ExistNaRev
Verifica se o componente existe na revisão atual da SB1
@author Marcelo Neumann
@since 14/02/2019
@version P12
@return lExiste, logic, indica que o componente existe na revisão atual
/*/
Static Function ExistNaRev()

	Local cRevAtu := CriaVar('B1_REVATU')
	Local lExiste := .F.

	If SB1->(dbSeek(xFilial("SB1")+SG1->G1_COD))
		cRevAtu := SB1->B1_REVATU
	EndIf

	If cRevAtu >= SG1->G1_REVINI .And. cRevAtu <= SG1->G1_REVFIM
		lExiste := .T.
	EndIf

Return lExiste

/*/{Protheus.doc} ValCpoList
Valida as informações do componente com as informações da lista
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oMdlGrd, object 	 , modelo da grid dos componentes
@param 02 nLine  , numeric	 , número da linha referente ao componente
@return cAcao	 , characters, indica se o componente foi alterado ou removido da lista
							   "NIL" - componente está ok
							   "UPD" - houve alteração em algum campo da lista
							   "DEL" - componente foi removido da lista
/*/
Static Function ValCpoList(oMdlGrd, nLine)

	Local aFields  := oMdlGrd:oFormModelStruct:aFields
	Local nIndCps  := 1
	Local cCampoVG := ""
	Local cAcao	   := "NIL"

	//Se o parâmetro de réplica está desativado, não valida a lista
	If sMvPCPRLEP <> 1
		Return "NIL"
	EndIf

	//Verifica se o componente existe na lista
	If SVG->(dbSeek(xFilial("SVG") + oMdlGrd:GetValue("GG_LISTA", nLine) + oMdlGrd:GetValue("GG_TRT", nLine) + oMdlGrd:GetValue("GG_COMP", nLine) ))
		//Percorre e compara todos os campos
		For nIndCps := 1 To Len(aFields)
			cCampoVG := ConvCampo(aFields[nIndCps][3])

			//Se for o campo Data Inicial ou Data Final, só valida se estiver preenchido na lista
			IF cCampoVG $ "|VG_INI|VG_FIM|"
				If Empty(SVG->(&(cCampoVG)))
					Loop
				EndIf
			EndIf

			//Compara o campo
			If SVG->(FieldPos(cCampoVG)) > 0
				If SVG->(&(cCampoVG)) <> oMdlGrd:GetValue(aFields[nIndCps][3], nLine)
					cAcao := "UPD"
					Exit
				EndIf
			EndIf
		Next nIndCps
	Else
		cAcao := "DEL"
	EndIf

Return cAcao

/*/{Protheus.doc} ConvCampo
Converte o campo da SGG para SVG
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param cCampo , characters, campo a ser convertido
@return cCampo, characters, campo convertido
/*/
Static Function ConvCampo(cCampo)

	cCampo := AllTrim(cCampo)

	Do Case
		Case cCampo == "GG_LISTA"
			cCampo := "VG_COD"

		Case cCampo == "GG_COD"
			cCampo := "NAO_USADO"

		Otherwise
			cCampo := Strtran(cCampo,"GG_","VG_")
	EndCase

Return cCampo

/*/{Protheus.doc} ValidLista
Valida as listas de componentes utilizadas na pré-estrutura
@author Marcelo Neumann
@since 14/02/2019
@version P12
@param 01 oModel, object, modelo principal
@return nAcao, numeric, 1 = Cria a estrutura
						2 = Altera a pré-estrutura
						3 = Mantém no Wizard
/*/
Static Function ValidLista(oModel, lAuto)

	Local nIndLista  := 1
	Local cLisAnteri := ""
	Local lOk        := .T.
	Local nInd		 := 1
	Local oModelAuxG := Nil
	Local lPergunta  := .F.
	Local lAlteraSta := .F.
	Local nAcao		 := 1
	Local cPaiAnteri := ""
	Local cCargoAtu  := oModel:GetModel("FLD_SELECT"):GetValue("CARGO")

	Default lAuto := .F.

	//Se o parâmetro de réplica está desativado, não valida a lista
	If sMvPCPRLEP <> 1
		Return 1
	EndIf

	//Ordena o array para poupar consultas no banco de dados
	aSort(saListaCmp, , , { | x,y | x[4] + x[1] + x[5] < y[4] + y[1] + y[5] } )

	SVG->(dbSetOrder(1))

	If aScan(saListaCmp, { |x| x[5] $ "UPD|DEL" }) > 0
		lPergunta := .T.
		//STR0046 - Informação
		//STR0219 - A lista de componentes utilizada na pré-estrutura possui alterações que não foram replicadas para esta pré-estrutura.
		//STR0273 - Deseja voltar a pré-estrutura para a situação em criação e corrigir conforme a lista de componentes?
		//STR0011 - Sim
		//STR0012 - Voltar
		If Aviso(STR0046, STR0219 + STR0273, {STR0011, STR0012}) == 1
			DesfazAltP(oModel)
		Else
			Return 3
		EndIf
	EndIf

	//Percorre o array carregado com as listas e componentes da pré-estrutura atual
 	For nIndLista := 1 To Len(saListaCmp)
	 	oModelAuxG := oModel:GetModel("GRID_DETAIL")

		//Tratamento para consultar somente uma vez as listas
		If Empty(cLisAnteri)
			cLisAnteri := saListaCmp[1][1]
			cPaiAnteri := saListaCmp[1][4]
			P135TrSeek(saListaCmp[1][4], , .T.)
		Else
			If cLisAnteri == saListaCmp[nIndLista][1] .And. cPaiAnteri == saListaCmp[nIndLista][4] .And. saListaCmp[nIndLista][5] <> "UPD"
				Loop
			Else
				cLisAnteri := saListaCmp[nIndLista][1]
				cPaiAnteri := saListaCmp[nIndLista][4]
				P135TrSeek(saListaCmp[nIndLista][4], , .T.)
			EndIf
		EndIf

		If saListaCmp[nIndLista][5] == "DEL"
			oModelAuxG:GoLine(saListaCmp[nIndLista][6])
			oModelAuxG:DeleteLine()
			lAlteraSta := .T.
		EndIf

		//Verifica se a lista existe
		If SVG->(dbSeek(xFilial("SVG") + saListaCmp[nIndLista][1]))
			While !SVG->(Eof()) .And. ;
				SVG->VG_FILIAL == xFilial("SVG") .And. ;
				SVG->VG_COD    == saListaCmp[nIndLista][1]

				If oModelAuxG:SeekLine({ {"GG_COMP", SVG->VG_COMP} , {"GG_TRT", SVG->VG_TRT} , {"GG_LISTA", SVG->VG_COD} } , .F., .T.)
					If saListaCmp[nIndLista][5] == "NIL"
						SVG->(dbSkip())
						Loop
					EndIf
				Else
					//STR0046 - Informação
					//STR0219 - A lista de componentes utilizada na pré-estrutura possui alterações que não foram replicadas para esta pré-estrutura.
					//STR0273 - Deseja voltar a pré-estrutura para a situação em criação e corrigir conforme a lista de componentes?
					//STR0011 - Sim
					//STR0012 - Voltar
					If !lPergunta
						lPergunta := .T.
						If Aviso(STR0046, STR0219 + STR0273, {STR0011, STR0012}) == 1
							DesfazAltP(oModel)
						Else
							lOk := .F.
							Exit
						EndIf
					EndIf

					If lOk
						oModelAuxG:AddLine()
					EndIf
				EndIf

				lAlteraSta := .T.

				//Valida a atribuição dos valores dos campos principais
				If !oModelAuxG:SetValue("GG_COMP",SVG->VG_COMP)
					lOk := .F.
					Exit
				EndIf

				If !oModelAuxG:SetValue("GG_TRT",SVG->VG_TRT)
					lOk := .F.
					Exit
				EndIf

				If !oModelAuxG:SetValue("GG_QUANT",SVG->VG_QUANT)
					lOk := .F.
					Exit
				EndIf

				If !Empty(SVG->VG_INI)
					oModelAuxG:SetValue("GG_INI",SVG->VG_INI)
				EndIf

				If !Empty(SVG->VG_FIM)
					oModelAuxG:SetValue("GG_FIM",SVG->VG_FIM)
				EndIf

				oModelAuxG:SetValue("GG_FIXVAR"  , SVG->VG_FIXVAR)
				oModelAuxG:SetValue("GG_GROPC"   , SVG->VG_GROPC)
				oModelAuxG:SetValue("GG_OPC"     , SVG->VG_OPC)
				oModelAuxG:SetValue("GG_POTENCI" , SVG->VG_POTENCI)
				oModelAuxG:SetValue("GG_TIPVEC"  , SVG->VG_TIPVEC)
				oModelAuxG:SetValue("GG_VECTOR"  , SVG->VG_VECTOR)
				oModelAuxG:SetValue("GG_LISTA"   , SVG->VG_COD)
				oModelAuxG:SetValue("GG_LOCCONS" , SVG->VG_LOCCONS)
				oModelAuxG:LoadValue("CSTATUS","1")

				SVG->(dbSkip())
			End
		Else
			lOk := .F.
			Help( ,  , "Help", ,  STR0221, 1, 0, , , , , ,     ; //"A lista de componentes utilizada na pré-estrutura não existe."
				{STR0220 + AllTrim(saListaCmp[nIndLista][1])} ) //"Revise os componentes da lista: "
			nAcao := 3
			Exit
		EndIf
		If lAlteraSta
			//Se houver divergências, percorre todos os itens da grid e alterar o status pra 1
			For nInd := 1 to oModelAuxG:Length()
				If oModelAuxG:GetValue("CSTATUS", nInd) <> "1"
					oModelAuxG:GoLine(nInd)
					oModelAuxG:LoadValue("CSTATUS","1")
				EndIf
			Next
			lAlteraSta := .F.
			nAcao := 2
		EndIf

		If !lOk
			nAcao := 3
			Exit
		EndIf

	Next nIndLista

	If !lAuto
		P135TrSeek(cCargoAtu, , .T.)
	Else
		P135TreeCh(.T., cCargoAtu)
	EndIf

Return nAcao

/*/{Protheus.doc} P135GrvRev
Avalia Gravação de Revisão na Estrutura

@author ana.paula
@since 10/06/2025
@version P12
@param 01 lAuto, lógico, indica se é rotina automática
@return lReturn, lógico, indica se grava Revisão na Estrutura
/*/
Static Function P135GrvRev(lAuto)

	Local cLinha1  := STR0308 + CHR(13) //"Cada alteração em uma estrutura pode gerar uma nova estrutura para"
	Local cLinha2  := STR0309 + CHR(13) //"o controle histórico de alterações em determinado produto."
	Local cLinha3  := STR0310 + CHR(13) //"A alteração deve gerar uma nova revisão para esta estrutura?"
	Local lReturn  := .T.

	If !sMvREVAUT
		lReturn := .F.

		If !lAuto
			lReturn := ApMsgYesNo(cLinha1+cLinha2+cLinha3,STR0311)	//"Gerar Revisão da Estrutura?"
		EndIf
	EndIf

Return lReturn
