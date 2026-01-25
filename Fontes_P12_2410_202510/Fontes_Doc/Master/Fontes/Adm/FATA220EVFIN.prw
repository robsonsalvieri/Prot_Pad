#include 'totvs.ch'
#include 'FWMVCDef.ch'
#Include 'FATA220EVFIN.CH'

#Define BMP_ON  "LBOK"
#Define BMP_OFF "LBNO"

Static __oGDAI3 := Nil
Static __oGDAI4	:= Nil

/*/{Protheus.doc} FATA220EVFIN
Evento de Integração com o Módulo Financeiro na rotina FATA220 (Usuários de Portal)

@author Alison Kaique
@since Apr|2021
/*/
Class FATA220EVFIN From FWModelEvent
	Method New()
	//Bloco com regras de negócio na pós validação do modelo de dados.
	Method ModelPosVld()
	Method GridLinePreVld()
EndClass

/*/{Protheus.doc} New
Método Construtor da Classe

@author Alison Kaique
@since Apr|2021
/*/
Method New() Class FATA220EVFIN
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld
Evento de campos da grid. Utilizado para após inserir o código do cliente, perguntar se preenche
a grid com outras lojas do cliente se houver, e outros clientes do mesmo grupo se houver.

@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Method GridLinePreVld(oSubModel As Object, cModelID As Character, nLine As Numeric, cAction As Character, cId As Character, xValue, xCurrentValue)   Class FATA220EVFIN

	Local lRet      	As Logical
	Local lViewRefresh 	As Logical
	Local aArea			As Array
	Local aAreaSA1		As Array
	Local aRecCod		As Array
	Local cFilSA1		As Character
	Local cCodCli		As Character
	Local cLojCli		As Character
	Local nX			As Numeric
	Local nLineAux		As Numeric
	Local nLineTot		As Numeric
	Local aSaveLines  	As Array
	Local oView			As Object

	aArea 		:= GetArea()
	aAreaSA1 	:= SA1->(GetArea())
	lRet 		:= .T.	

	If cModelID == 'AI4DETAIL' .AND. cId == 'AI4_CODCLI' .AND. cAction == 'SETVALUE'
		If !(IsBlind()) .AND. !Empty(SuperGetMV('MV_MINGTOK', .F., '')) .AND. IsRightMingle() .AND. FunName() == 'FATA220'
			If FirsCod(oSubModel,nLine,xValue)
				
				cFilSA1	:= xFilial("SA1")
				cCodCli := xValue
				cLojCli := oSubModel:GetValue("AI4_LOJCLI")

				DbSelectArea("SA1")
				SA1->(DbSetOrder(1))	//A1_FILIAL+A1_COD+A1_LOJA
				If Empty(cLojCli) .And. SA1->A1_FILIAL == xFilial("SA1") .And. SA1->A1_COD == cCodCli
					cLojCli := SA1->A1_LOJA	//	Caso posicionou pelo F3
				EndIf				

				If SA1->(MsSeek(cFilSA1 + cCodCli + AllTrim(cLojCli)))

					lViewRefresh := .F.
					
					If Empty(cLojCli)
						cLojCli := SA1->A1_LOJA
					EndIf					

					aRecCod := GetCliCod(cCodCli,cLojCli)

					If Len(aRecCod) > 0
						If MsgYesNo(STR0021) // 'Deseja carregar as outras lojas desse cliente?'

							aSaveLines  := FWSaveRows()

							oSubModel:LoadValue('AI4_CODCLI',cCodCli,nLine)
							oSubModel:LoadValue('AI4_LOJCLI',cLojCli,nLine)

							For nX := 1 To Len(aRecCod)
								SA1->(DbGoTo(aRecCod[nX]))
								nLineTot := oSubModel:Length()
								nLineAux := oSubModel:AddLine()
								If nLineAux == nLineTot + 1
									oSubModel:LoadValue('AI4_CODCLI',SA1->A1_COD)
									oSubModel:SetValue('AI4_LOJCLI',SA1->A1_LOJA)
								EndIf
							Next nX							

							FWRestRows( aSaveLines )

							lViewRefresh := .T.

						EndIf
					EndIf

					SA1->(MsSeek(cFilSA1 + cCodCli + AllTrim(cLojCli)))

					If !Empty(SA1->A1_GRPVEN)

						aRecCod := GetCliGrup(cCodCli,cLojCli,SA1->A1_GRPVEN)

						If Len(aRecCod) > 0
							If MsgYesNo(STR0022) // 'Deseja carregar clientes do mesmo grupo de vendas?'

								aSaveLines  := FWSaveRows()

								oSubModel:LoadValue('AI4_CODCLI',cCodCli,nLine)
								oSubModel:LoadValue('AI4_LOJCLI',cLojCli,nLine)

								For nX := 1 To Len(aRecCod)								
									SA1->(DbGoTo(aRecCod[nX]))
									If !oSubModel:SeekLine({{"AI4_CODCLI",SA1->A1_COD},{"AI4_LOJCLI",SA1->A1_LOJA}},.F.,.F.)
										nLineTot := oSubModel:Length()
										nLineAux := oSubModel:AddLine()
										If nLineAux == nLineTot + 1
											oSubModel:LoadValue('AI4_CODCLI',SA1->A1_COD)
											oSubModel:SetValue('AI4_LOJCLI',SA1->A1_LOJA)
										EndIf
									EndIf
								Next nX							

								FWRestRows( aSaveLines )

								lViewRefresh := .T.

							EndIf
						EndIf
					EndIf

					If lViewRefresh
						oView := FwViewActive()
						If oView <> Nil
							oView:Refresh()
						EndIf					
					EndIf

				EndIf					
			EndIf
		EndIf
	EndIf
		
	RestArea(aAreaSA1)
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} ModelPosVld
Método responsável por executar regras de negócio do Financeiro
na pós validação do modelo de dados.

@type 		Método

@param 		oModel, objeto	, Modelo de dados de Clientes.
@param 		cID   , caracter, Identificador do sub-modelo.

@author 	alison.kaique
@version	12.1.33 / Superior
@since		23/04/2021
/*/
Method ModelPosVld(oModel, cID) Class FATA220EVFIN

	Local oModelAI6  As Object
	Local nOperation As Numeric
	Local lRet       As Logical
	Local cLogin     As Character
	Local cSenha     As Character
	Local cFuncao    As Character
	Local cCodWS     As Character
	Local cUrlMingle As Character
	Local cAliMingle As Character
	Local oServMail  As Object
	Local oMessage   As Object	
	Local lMailOk	 As Logical
	Local nRetMail	 As Numeric
	Local lContinue  As Logical
	Local nLinha	 As Numeric

	nOperation := 0
	lRet       := .T.
	lMailOk	   := .T.
	cLogin     := ''
	cSenha     := ''
	cFuncao    := ''
	cCodWS     := ''
	cUrlMingle := 'PROD'
	cAliMingle := ''
	nRetMail   := 0
	lContinue  := .T.

	nOperation 	:= oModel:GetOperation()

	// verifica o Id do submodelo
	If (AllTrim(cID) == "FATA220") // usuário de Portal
		// verifica a operação
		If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE .OR.;
				nOperation == MODEL_OPERATION_DELETE)
		/*/
			Integração Portal do Cliente Mingle
		/*/
			//Verifica se existe cliente incluido como usuario do Portal
			If (FindFunction('PORTAL.CLIENTE.UTIL.INTMINGLEPCM'))
				// código do WebService
				cCodWS := PadR(SuperGetMV('MV_WEBSVPC', .F., 'PORTALCLIENTEMINGLE'), TamSX3('AI7_WEBSRV')[01])
				// verifica se foi vinculado o WebService do Portal do Cliente para o usuário
				oModelAI6 := oModel:GetModel('AI6DETAIL')

				If (oModelAI6:SeekLine({{"AI6_WEBSRV", cCodWS}}))
					If (oModelAI6:SeekLine({{"AI6_WEBSRV", "PORTALMINGLEDEV"}}))
						cUrlMingle := "DEV"
					Endif

					For nLinha := 1 To oModelAI6:Length()
						If !(Alltrim(oModelAI6:aCols[nLinha][2]) $ 'PORTALCLIENTEMINGLE|PORTALMINGLEDEV') .And. !(oModelAI6:aCols[nLinha][4])
							lRet 		:= .F.
							lContinue 	:= .F.
							HELP(" ", 1, STR0001,, STR0044, 2, 0,,,,,,{ STR0045 }) // # "Portal - Clientes" # "O direito "Portal do Cliente Mingle" deve ser exclusivo, não aceitando mais direitos vinculados ao usuário." # "Apague as linhas dos outros direitos."
						EndIf
					Next nLinha

					cLogin  := AllTrim(oModel:GetValue('AI3MASTER', 'AI3_LOGIN'))
					cSenha  := AllTrim(oModel:GetValue('AI3MASTER', 'AI3_PSW'))

					If nOperation == MODEL_OPERATION_UPDATE
						If !(AllTrim(cLogin) == AllTrim(AI3->AI3_LOGIN))
							lRet 		:= .F.
							lContinue 	:= .F.
							HELP(" ",1, STR0001 ,, STR0046 + ' ' + AllTrim(FwX3Titulo('AI3_LOGIN')) + ' ' + STR0047 ,2,0)// "Portal - Clientes" # "Não é permitido alterar o campo" # "para cadastros vinculados ao Portal do Cliente."
						EndIf
					EndIf

					If lContinue .AND. cSenha <> Replicate('*', TamSX3('AI3_PSW')[01])
						If ValidModel(oModel)							
							cFuncao := 'PORTAL.CLIENTE.UTIL.INTMINGLEPCM("' + cLogin + '", "' + cSenha + '", ' + cValToChar(nOperation) + ', "' + cUrlMingle + '")'
							// efetua o processamento no Mingle
							lRet := &(cFuncao)
						Else
							lRet := .F.
							HELP(" ",1, STR0001 ,, STR0002 ,2,0,,,,,,{ STR0003 }) // # "Portal - Clientes" # "Inclusão de Cliente" # "Necessario Incluir Cliente para conclusão do Cadastro"
						Endif

						If lRet 
							If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE) .AND. (FwIsInCallStack("FATA220") .OR. FwIsInCallStack("FT220CadCli"))
								cAliMingle := AllTrim(SuperGetMV('MV_FMINGAL', .F., ''))
								If !Empty(cAliMingle)								
									If !Empty(AllTrim(oModel:GetValue('AI3MASTER', 'AI3_EMAIL')))

										// Comunicação com servedor de email
										oServMail := &("gfin.job.bills.email.BillsEMail():new()")									

										// Envio mensagem						
										If oServMail:lConnected
											oMessage := TMailMessage():New()
											oMessage:Clear()      
											oMessage:cFrom			:= oServMail:cFrom
											oMessage:cTo			:= AllTrim(oModel:GetValue('AI3MASTER', 'AI3_EMAIL'))
											oMessage:cBcc			:= ''
											oMessage:cSubject		:= STR0006 	// 'Acesso Portal do Cliente'
											oMessage:cBody			:= BodyMail(oModel,cAliMingle)
											nRetMail := oMessage:Send( oServMail:oServcMail )
											FT220ErFin(nRetMail,oServMail)
											oMessage:Clear()
											oServMail:Destroy()
										ElseIf !IsBlind()
											FwAlertHelp(STR0004 + CRLF + oServMail:getError()) // 'O e-mail automático com os dados de acesso do usuário não será enviado!'
										EndIf
									ElseIf !IsBlind() .AND. !FwIsInCallStack("FT220CadCli")
										FwAlertHelp(STR0004,STR0005) // 'O e-mail automático com os dados de acesso do usuário não será enviado!' # 'Para que o e-mail automático seja enviado o campo E-mail (AI3_EMAIL) deve ser informado.'
									EndIf
								EndIf
							EndIf							
							oModel:LoadValue('AI3MASTER', 'AI3_PSW', Replicate('*', TamSX3('AI3_PSW')[01]))
						EndIf
					EndIf
				EndIf
			Endif
		EndIf
	EndIf

	If oServMail <> Nil
		FreeObj(oServMail)
	EndIf
	If oMessage <> Nil
		FreeObj(oMessage)	
	EndIf

Return lRet

/*/{Protheus.doc} ValidModel
Função responsável por validar se foi cadastrado cliente para o Portal
@type 		Função
@param 		oModel, objeto	, Modelo de dados de Clientes.
@author 	francisco.Oliveira
@version	12.1.33 / Superior
@since		19/09/2021
/*/

Static Function ValidModel(oModel As Object) As Logical

	Local nX			    As Numeric
	Local nLenAI4		  As Numeric
	Local lRet			  As Logical
	Local oAI4DETAIL	As Object

	nX		:= 0
	lRet	:= .F.
	oAI4DETAIL  := oModel:GetModel("AI4DETAIL")

	nLenAI4 := oAI4DETAIL:Length()

	If nLenAI4 > 0
		For nX := 1 To nLenAI4
			oAI4DETAIL:Goline(nX)
			If !oAI4DETAIL:IsDeleted()
				cCodCli	:= oAI4DETAIL:GetValue("AI4_CODCLI")
				cLojCli	:= oAI4DETAIL:GetValue("AI4_LOJCLI")
				If Empty(cCodCli) .Or. Empty(cLojCli)
					lRet := .F.
				Else
					lRet := .T.
					Exit
				Endif
			Endif
		Next nX
	Endif

Return lRet


/*/{Protheus.doc} BodyMail
Monta o corpo do e-mail
@type 		Função
@param 		oModel, 		Objeto - Modelo de dados FATA220
			cAliMingle,		Character - Parametro alias do Mingle 
@author 	rafael.rondon
@version	12.1.33 / Superior
@since		21/11/2022
@return 	cBody, 			html do corpo do e-mail
/*/
Static Function BodyMail(oModel As Object,cAliMingle As Character) As Character

	Local cBody 		As Character
	Local oAI4Model 	As Object
	Local nI			As Numeric

	cBody := "<p>" + AllTrim(oModel:GetValue('AI3MASTER', 'AI3_NOME')) + ", " + OemToANSI(STR0013) + AllTrim(FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt , {'M0_NOMECOM'})[1][2]) + ".</p>" // "chegaram os seus dados de acesso ao Portal do Cliente da "

	cBody += '<p>' + OemToANSI(STR0011) + '<a href="https://portalfinanceiroprotheus.totvs-solucoes.com.br/login/' + cAliMingle + '">' + OemToANSI(STR0012) + '</a>.</p>' // 'Para acessar o mesmo, ' # 'clique aqui'
 
	cBody += "<p>" + OemToANSI(STR0010) + AllTrim(oModel:GetValue('AI3MASTER', 'AI3_LOGIN')) + "</p>" // 'Usuário: '

	cBody += "<p>" + OemToANSI(STR0009) + AllTrim(oModel:GetValue('AI3MASTER', 'AI3_PSW')) + "</p>" //'Senha: '

	oAI4Model := oModel:GetModel('AI4DETAIL')	

	If oAI4Model:Length() > 0

		cBody += "<p>" + OemToANSI(STR0014) + "</p>" // "Você possui acesso aos seguintes clientes:"

		cBody += '<table align="left" border="1" cellpadding="1" cellspacing="1" style="width:500px">'
		cBody += "	<tbody>"
		cBody += "		<tr>"
		cBody += "			<td>Cliente</td>"
		cBody += "			<td>Loja</td>"
		cBody += "			<td>Nome</td>"
		cBody += "			<td>CNPJ</td>"		
		cBody += "		</tr>"

		For nI := 1 To oAI4Model:Length()
			oAI4Model:Goline(nI)
			If !oAI4Model:IsDeleted()
				cBody += "		<tr>"
				cBody += "			<td>" + oAI4Model:GetValue('AI4_CODCLI') + "</td>"
				cBody += "			<td>" + oAI4Model:GetValue('AI4_LOJCLI') + "</td>"
				cBody += "			<td>" + OemToANSI( AllTrim( Posicione('SA1',1, xFilial('SA1') + oAI4Model:GetValue('AI4_CODCLI') + oAI4Model:GetValue('AI4_LOJCLI') , 'A1_NOME ') ) ) + "</td>"
				cBody += "			<td>" + OemToANSI(PicCgc( Posicione('SA1',1, xFilial('SA1') + oAI4Model:GetValue('AI4_CODCLI') + oAI4Model:GetValue('AI4_LOJCLI') , 'A1_CGC ') )) + "</td>"
				cBody += "		</tr>"
			EndIf
		Next nI			

		cBody += "	</tbody>"
		cBody += "</table>"

		For nI := 1 To oAI4Model:Length() + 1
			cBody += '<p>&nbsp;</p>'
		Next nI
		
	EndIf

	cBody += "<p>" + OemToANSI(STR0008) + "</p>"

Return cBody

/*/{Protheus.doc} PicCgc
Coloca picture CNPJ ou CPF e mascara CPF por causa da LGPD
@type 		Função
@param 		cCgc, 		Campo A1+_CGC sem formatação
@author 	rafael.rondon
@version	12.1.33 / Superior
@since		21/11/2022
@return 	cCgc, 		Campo A1_CGC formatado pelo tamanho, CPF ou CNPJ
/*/
Static Function PicCgc(cCgc As Character) As Character

	If !Empty(cCgc)

		If Len(AllTrim(cCgc)) <= 11
			cCgc := '***.***.' + SubStr(cCgc,7,3) + '-' + SubStr(cCgc,10,2)
		Else
			cCgc := AllTrim(Transform(cCgc, '@R! NN.NNN.NNN/NNNN-99'))
		EndIf

	EndIf

Return cCgc

/*/{Protheus.doc} FT220ErFin
Trata erro
@type 		Função
@param 		nRetMail, 		Retorno envio de email
			oServMail,		Classe email bills.mail
@author 	rafael.rondon
@version	12.1.33 / Superior
@since		21/11/2022
@return 	
/*/
Function FT220ErFin(nRetMail As Numeric,oServMail As Object)

	If nRetMail <> 0
		If !IsBlind()
			FwAlertHelp(STR0007 + CRLF + oServMail:oServcMail:GetErrorString(nRetMail)) // "Não foi possível enviar o e-mail: "
		EndIf
	EndIf

Return


/*/{Protheus.doc} FT220CadCli
Função para cadastro de usuário após a inclusão de cliente
@type 		Função
@param 		cCodSA1, 		A1_COD
			cLojaSA1,		A1_LOJA
			cGrupSA1,		A1_GRPVEN
@author 	rafael.rondon
@version	12.1.33 / Superior
@since		21/11/2022
@return 	
/*/
Function FT220CadCli( cCodSA1 As Character , cLojaSA1 As Character , cGrupSA1 As Character) 

	Local oStepWiz	As Object
	Local o1stPage	As Object
	Local o2stPage	As Object
	Local aCoords	As Array

	aCoords := FWGetDialogSize()

	oStepWiz := FWWizardControl():New(/*oDlg*/,{aCoords[3] * 0.9, aCoords[4] * 0.9})
	oStepWiz:ActiveUISteps()


	o1stPage := oStepWiz:AddStep("1STSTEP",{|Panel| PnlUsu(Panel,cCodSA1,cLojaSA1)})
	o1stPage:SetStepDescription(OemToAnsi('Usuários'))
	o1stPage:SetNextTitle(OemToAnsi('Avançar'))      
	o1stPage:SetNextAction({|| ValPnlUsu() })
	o1stPage:SetCancelAction({|| .T.})

	o2stPage := oStepWiz:AddStep("2STSTEP",{|Panel| PnlCli(Panel,cCodSA1,cLojaSA1,cGrupSA1)})
	o2stPage:SetStepDescription(OemToAnsi('Clientes'))
	o2stPage:SetNextTitle(OemToAnsi('Finalizar'))
	o2stPage:SetNextAction({|| ValPnlCli() })
	o2stPage:SetCancelAction({|| .T.})

	oStepWiz:Activate()

	If __oGDAI3 <> Nil
		FreeObj(__oGDAI3)
		__oGDAI3 := Nil
	EndIf
	If __oGDAI4 <> Nil
		FreeObj(__oGDAI4)
		__oGDAI4 := Nil
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValPnlCli
Função para construção página do wizard step 2 informações gerais do wizard
@param 	oPanel
		__oGDAI4
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function ValPnlCli()

	Local lRet 			As Logical
	Local aRequired		As Array
	Local nI			As Numeric
	Local nJ			As Numeric
	Local nPosMark		As Numeric
	Local cLog			As Character
	Local lHasMarked	As Logical

	lRet		:= .T.
	nPosMark	:= aScan( __oGDAI4:aHeader, { |x| AllTrim( x[2] ) == "MARK" } )
	cLog		:= "" 
	lHasMarked := .F.		// Define se existe itens marcados

	aRequired := {}
	For nI := 1 To Len(__oGDAI4:aHeader)
		If __oGDAI4:aHeader[nI][17] // Obrigatorio
			aAdd(aRequired,nI)	//	Posicao do campo obrigatorio no acols
		EndIf
	Next nI

	For nI := 1 To Len(__oGDAI4:aCols)
		If !__oGDAI4:aCols[nI][ Len(__oGDAI4:aHeader) + 1 ]	// Não Deletado
			If __oGDAI4:aCols[nI][nPosMark] == BMP_ON		// Marcado

				lHasMarked := .T.

				For nJ := 1 To Len(aRequired)
					If Empty(__oGDAI4:aCols[nI][ aRequired[nJ] ])
						cLog := STR0015 + CRLF	// "Existem linhas marcadas com campos obrigatórios em branco:"
						cLog += STR0016 + cValToChar(nI) + CRLF + STR0017 + __oGDAI4:aHeader[aRequired[nJ]][1] // "Linha: " # "Campo: "
						FwAlertHelp(cLog,'') 
						lRet := .F.
						Exit
					EndIf
				Next nJ

				If !lRet								
					Exit
				EndIf

			EndIf
		EndIf
	Next nI	

	If lRet .AND. !lHasMarked
		lRet := .F.
		FwAlertHelp(STR0018) // 'Nenhum cliente foi selecionado'	
	EndIf

	If lRet
		Processa( { || lRet := ProcAdd220() }, STR0019, STR0020 ) //	'Processando..' # 'Aguarde.'
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PnlCli
Função para construção página do wizard step 2 informações gerais do wizard
@param 	oPanel
		__oGDAI4
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function PnlCli(oPanel As Object, cCodSA1 As Character,cLojaSA1 As Character,cGrupSA1 As Character)

	Local aHeader	As Array
	Local aAlter	As Array	
	Local nI		As Numeric
	Local aCols		As Array
	Local oCheck    As Object	
	Local lCheck    As Logical
	Local oFont     As Object	
	Local oFont2N	As Object	
	Local oSay     	As Object		
	
	aHeader	:= GetCliHeader()

	aAlter := {}
	For nI := 1 To Len(aHeader)
		If aHeader[nI][14] <> 'V' // Não editar campo visual
			aAdd(aAlter,aHeader[nI][2])
		EndIf
	Next nI

	aCols := {}
	aAdd( aCols, { 	BMP_ON		, ; 	
					cCodSA1		, ;
					cLojaSA1	, ;
					Posicione('SA1',1,xFilial('SA1') + cCodSA1 +cLojaSA1, 'A1_NOME' )	, ;
					.F.			} )
	// adicionar clientes pelo código e grupo					
	AddCliGrid(cCodSA1, cLojaSA1, cGrupSA1, @aCols)

	oFont 	:= TFont():New(,,-14,.T.,,,,,,)
	oFont2N	:= TFont():New(,,-18,.T.,.T.,,,,,)

	oSay := TSay():New(05,0,{|| STR0039},oPanel,,oFont2N,,,,.T.,CLR_BLUE,,oPanel:nClientWidth/2)  // 'Selecione um ou mais clientes a serem vinculados aos usuários.'
	oSay:SetTextAlign( 2, 2 )

	lCheck := .T.
	oCheck := TCheckBox():New(50,05,STR0040,{||lCheck},oPanel,100,210,,{|| lCheck:=!lCheck , CheckMark(@__oGDAI4,lCheck) },oFont,,,,,.T.,,,) // 'Marcar/Desmarcar todos'

	__oGDAI4 	:= MsNewGetDados():New(60,0,oPanel:nClientHeight/2,oPanel:nClientWidth/2,GD_INSERT+GD_UPDATE+GD_DELETE,"AllwaysTrue","AllwaysTrue","",aAlter,,999,/*fieldok*/,/*superdel*/,"AllwaysFalse"/*delok*/,oPanel,aHeader,aCols)
	__oGDAI4:oBrowse:blDblClick:={|| DobClick(@__oGDAI4)  }

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} AddCliGrid
Função de interface para preecnher clientes no acols
@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function AddCliGrid(cCodSA1 As Character, cLojaSA1 As Character, cGrupSA1 As Character, aCols As Array)

	Local aRecCod		As Array
	Local aRecGrup		As Array
	Local aArea			As Array
	Local aAreaSA1		As Array	
	Local nI			As Numeric

	aArea := GetArea()
	aAreaSA1 := SA1->(GetArea())
	DbSelectArea('SA1')

	aRecCod := GetCliCod(cCodSA1,cLojaSA1)

	If Len(aRecCod) > 0
		If MsgYesNo(STR0021) // 'Deseja carregar as outras lojas desse cliente?'
			For nI := 1 To Len(aRecCod)
				SA1->(DbGoTo(aRecCod[nI]))
				aAdd( aCols, { 	BMP_ON			, ; 	
								SA1->A1_COD		, ;
								SA1->A1_LOJA	, ;
								SA1->A1_NOME 	, ;
								.F.				} )
			Next nI
		EndIf
	EndIf

	If !Empty(cGrupSA1)
		aRecGrup := GetCliGrup(cCodSA1,cLojaSA1, cGrupSA1)
		If Len(aRecGrup) > 0
			If MsgYesNo(STR0022) // 'Deseja carregar clientes do mesmo grupo de vendas?'
				For nI := 1 To Len(aRecGrup)
				
					SA1->(DbGoTo(aRecGrup[nI]))
					If !HasCliaCols(SA1->A1_COD,SA1->A1_LOJA,aCols)
						aAdd( aCols, { 	BMP_ON			, ; 	
										SA1->A1_COD		, ;
										SA1->A1_LOJA	, ;
										SA1->A1_NOME 	, ;
										.F.				} )
					EndIf
				Next nI		
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSA1)
	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} HasCliaCols
Verificar se o cliente + loja a ser inserida já não existe no acols
@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function HasCliaCols(cCodCli As Character,cLojCli As Character,aCols As Array) As Logical

	Local lRet 		As Logical
	Local nI 		As Numeric

	lRet := .F.

	For nI := 1 To Len(aCols)
		If aCols[nI][2] == cCodCli .AND. aCols[nI][3] == cLojCli
			lRet := .T.
			Exit
		EndIf
	Next nI

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GetCliCod
Busca outras lojas do mesmo codigo de cliente
@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function GetCliCod(cCodSA1 As Character ,cLojaSA1 As Character ) As Array

	Local cQuery 	As Character
	Local aClientes	As Array
	Local cAlias	As Character

	cAlias := GetNextAlias()
	aClientes := {}

	cQuery := " SELECT "
	cQuery += "    R_E_C_N_O_ "	
	cQuery += " FROM " + RetSqlName("SA1")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += " AND A1_COD = '" + cCodSA1 + "'"
	cQuery += " AND A1_LOJA <> '" + cLojaSA1 + "'"
	cQuery += " ORDER BY A1_LOJA "

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAlias)
 
	While (cAlias)->(!EOF())
		AAdd(aClientes,(cAlias)->R_E_C_N_O_)
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return aClientes

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUsers
Busca usuários com acesso a outras lojas do mesmo código de cliente
@param cCodSA1
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function GetUsers(cCodSA1 As Character ) As Array

	Local cQuery 	As Character
	Local aUsers	As Array
	Local aAux		As Array
	Local cAlias	As Character

	cAlias 	:= GetNextAlias()
	aUsers 	:= {}	

	cQuery := " SELECT DISTINCT AI3_CODUSU ,AI3_LOGIN , AI3_PSW , AI3_NOME, AI3_EMAIL FROM " + RetSqlName("AI3") + " AI3 "
	cQuery += " INNER JOIN " + RetSqlName("AI4") + " AI4 "
	cQuery += " ON AI4.AI4_FILIAL = AI3.AI3_FILIAL "
	cQuery += " AND AI4.AI4_CODUSU = AI3.AI3_CODUSU "
	cQuery += " AND AI4.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE AI3.AI3_FILIAL = '" + xFilial("AI3") + "' "
	cQuery += " AND AI4.AI4_CODCLI = '" + cCodSA1 + "' "

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAlias)
 
	While (cAlias)->(!EOF())
		aAux	:= {}
		AAdd(aAux,(cAlias)->AI3_CODUSU)
		AAdd(aAux,(cAlias)->AI3_LOGIN)
		AAdd(aAux,(cAlias)->AI3_PSW)
		AAdd(aAux,(cAlias)->AI3_NOME)
		AAdd(aAux,(cAlias)->AI3_EMAIL)
		AAdd(aUsers,aAux)
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return aUsers


//-------------------------------------------------------------------
/*/{Protheus.doc} GetCliGrup
Busca outros Clientes pelo mesmo grupo
@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function GetCliGrup(cCodSA1 As Character ,cLojaSA1 As Character , cGrupSA1 As Character) As Array

	Local cQuery 	As Character
	Local aClientes	As Array
	Local cAlias	As Character

	cAlias := GetNextAlias()
	aClientes := {}

	cQuery := " SELECT "
	cQuery += "    R_E_C_N_O_ "	
	cQuery += " FROM " + RetSqlName("SA1")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " AND A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += " AND A1_GRPVEN = '" + cGrupSA1 + "'"
	cQuery += " AND NOT (A1_COD = '" + cCodSA1 + "' AND A1_LOJA = '" + cLojaSA1 + "')"
	cQuery += " ORDER BY A1_COD , A1_LOJA "

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, cAlias)
 
	While (cAlias)->(!EOF())
		AAdd(aClientes,(cAlias)->R_E_C_N_O_)
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())

Return aClientes

//-------------------------------------------------------------------
/*/{Protheus.doc} F220EVFCli
Valida cliente loja digitados na getdados
@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Function F220EVFCli()

	Local lRet 			As Logical
	Local nPosCod		As Character
	Local nPosLoj		As Character
	Local nPosNom		As Character
	Local cCodCli		As Character
	Local cLojCli		As Character

	lRet := .T.
	nPosCod := aScan( __oGDAI4:aHeader, { |x| AllTrim( x[2] ) == "CODCLI" } )
	nPosLoj := aScan( __oGDAI4:aHeader, { |x| AllTrim( x[2] ) == "LOJCLI" } )
	nPosNom := aScan( __oGDAI4:aHeader, { |x| AllTrim( x[2] ) == "NOMCLI" } )	

	If ReadVar() == 'M->CODCLI'
		cCodCli := M->CODCLI
	Else
		cCodCli := __oGDAI4:aCols[n][nPosCod]
	EndIf

	If ReadVar() == 'M->LOJCLI'
		cLojCli := M->LOJCLI
	Else
		cLojCli := __oGDAI4:aCols[n][nPosLoj]
	EndIf	

	If !Empty(cCodCli) .AND. !Empty(cLojCli)
		DbSelectArea('SA1')
		SA1->(DbSetOrder(1))
		If !SA1->(DbSeek( xFilial("SA1") + cCodCli + cLojCli ))
			lRet := .F.
			Help(,,, "F220EVFCli", STR0023, 1, 0)	//	'Cliente e Loja não encontrados!'
		ElseIf HasCliaCols(cCodCli,cLojCli,__oGDAI4:aCols)
			lRet := .F.
			Help(,,, "F220EVFCli", STR0024 , 1, 0)	//	'Cliente e Loja já foram adicionados!'
		Else
			lRet := .T.
			__oGDAI4:aCols[n][nPosNom] := SA1->A1_NOME
		EndIf	
	EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PnlUsu
Função para construção página do wizard step 1 informações gerais do wizard
@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function PnlUsu(oPanel As Object, cCodSA1 As Character,cLojaSA1 As Character)

	Local aHeader		As Array
	Local aAlter		As Array	
	Local aCols			As Array	
	Local aUsers		As Array	
	Local nI			As Numeric
	Local nPosCodUsu	As Character
	Local cOnlyFields	As Character
	Local oFont      	As Object	
	Local oFont2N      	As Object	
	Local oSay      	As Object	
	Local oCheck      	As Object	
	Local lCheck      	As Logical		

	cOnlyFields := "AI3_CODUSU ,AI3_LOGIN , AI3_PSW , AI3_NOME, AI3_EMAIL"

	aHeader	:= GetDadHeader( 'AI3' , .T. , cOnlyFields )

	/*
		Retirar GetSxeNum e obrigatorio do AI3_CODUSU para não influenciar no GetDados
		Executar o GetSxeNum somente quando chamar o FATA220 para inclusão no final do processo
	*/
	nPosCodUsu := aScan( aHeader, { |x| AllTrim( x[2] ) == "AI3_CODUSU" } )
	aHeader[nPosCodUsu][06] := 'F220EVFUsu()'	// Valid
	aHeader[nPosCodUsu][09] := 'AI3'	// F3
	aHeader[nPosCodUsu][12] := '' 		// X3_RELACAO
	aHeader[nPosCodUsu][13] := '.T.'	// 13 - When
	aHeader[nPosCodUsu][14] := '' 		//14 - Visual
	aHeader[nPosCodUsu][17] := .F. 		// Obrigatorio	

	aAlter := {}
	For nI := 1 To Len(aHeader)
		If aHeader[nI][14] <> 'V' // Não editar campo visual
			aAdd(aAlter,aHeader[nI][2])
		EndIf
	Next nI

	aCols := {}
	aUsers := GetUsers(cCodSA1)
	If Len(aUsers) > 0
		If MsgYesNo(STR0025) // 'Deseja carregar usuários que possuem outras lojas desse cliente?'
			For nI := 1 To Len(aUsers)
				aAdd( aCols, { 	BMP_ON				, ; 	
								aUsers[nI][1]		, ;
								aUsers[nI][2]		, ;
								aUsers[nI][3]		, ;
								aUsers[nI][4]		, ;
								aUsers[nI][5]		, ;
								.F.					} )
			Next							
		EndIf
	EndIf

	oFont2N     := TFont():New(,,-18,.T.,.T.,,,,,)
	oFont      := TFont():New(,,-14,.T.,,,,,,)

	oSay := TSay():New(05,0,{||STR0041 },oPanel,,oFont2N,,,,.T.,CLR_BLUE,,oPanel:nClientWidth/2) // 'Selecione o(s) usuário(s) que deseja vincular ao(s) cliente(s).'
	oSay:SetTextAlign( 2, 2 )

	TSay():New(25,15,{|| STR0042},oPanel,,oFont,,,,.T.,,,)        // 'Para selecionar um usuário existente, preencha o campo código.'
	TSay():New(35,15,{|| STR0043},oPanel,,oFont,,,,.T.,,)	// 'Para incluir um novo usuário, o código deve estar em branco e os outros campos devem ser preenchidos.'

	lCheck := .F.
	oCheck := TCheckBox():New(50,05,STR0040,{||lCheck},oPanel,100,210,,{|| lCheck:=!lCheck , CheckMark(@__oGDAI3,lCheck) },oFont,,,,,.T.,,,) // 'Marcar/Desmarcar todos'

	__oGDAI3 	:= MsNewGetDados():New(60,0, oPanel:nClientHeight/2,oPanel:nClientWidth/2,GD_INSERT+GD_UPDATE+GD_DELETE,"AllwaysTrue","AllwaysTrue","",aAlter,,999,/*fieldok*/,/*superdel*/,"AllwaysFalse"/*delok*/,oPanel,aHeader,aCols)
	__oGDAI3:oBrowse:blDblClick:={|| DobClick(@__oGDAI3)  }

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckMark
Marcar ou desmarcar todos
@param 
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function CheckMark(oMsNewGD As Object ,lCheck As Logical)

	Local nPosMark		As Numeric
	Local nI			As Numeric

	nPosMark	:= aScan( oMsNewGD:aHeader, { |x| AllTrim( x[2] ) == "MARK" } )	

	For nI := 1 To Len(oMsNewGD:aCols)
		If !oMsNewGD:aCols[nI][ Len(oMsNewGD:aHeader) + 1 ]	// Não Deletado
			If lCheck
				oMsNewGD:aCols[nI][nPosMark] := BMP_ON		// Marcado
			Else
				oMsNewGD:aCols[nI][nPosMark] := BMP_OFF		// Desmarcado
			EndIf
		EndIf
	Next nI	
	oMsNewGD:Refresh()
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} F220EVFUsu
Valida Get do usuário
@param 
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Function F220EVFUsu() As Logical

	Local lRet			As Logical 
	Local cCodUsu		As Character
	Local nI			As Numeric
	Local nPos			As Numeric

	lRet := .T.

	If ReadVar() == "M->AI3_CODUSU"
		cCodUsu := M->AI3_CODUSU
		If !Empty(cCodUsu)
			DbSelectArea('AI3')
			AI3->(DbSetOrder(1))
			If AI3->(DbSeek(xFilial('AI3') + cCodUsu ))
				lRet := .T.
				// Preencher os campos existentes da getdados
				For nI := 1 To AI3->(FCount())
					nPos := aScan( __oGDAI3:aHeader, { |x| AllTrim( x[2] ) == FieldName(nI) } )			
					If nPos > 0
						__oGDAI3:aCols[n][nPos] := FieldGet(nI)
					EndIf
				Next nI
			Else
				lRet := .F.
				FwAlertHelp(STR0026, + ; // 'Código de usuário não encontrado!'
				STR0027 + CRLF + ; //'Para relacionar um usuário existente ao(s) cliente(s) preencha o código de usuário.'
				STR0028) // 'Para incluir usuário deixe o código em branco e preencha os outros campos. O código será preenchido automaticamente no final do processamento.'
			EndIf		
		EndIf			
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ValPnlUsu
Valid do botao avançar do step1
@param 
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function ValPnlUsu() As Logical

	Local lRet 			As Logical
	Local aRequired		As Array
	Local nI			As Numeric
	Local nJ			As Numeric
	Local nPosMark		As Numeric
	Local nPosMail		As Numeric
	Local cLog			As Character
	Local lHasMarked	As Logical
	Local cMingal		As Character
	Local cMingAvi		As Character

	lRet		:= .T.
	nPosMark	:= aScan( __oGDAI3:aHeader, { |x| AllTrim( x[2] ) == "MARK" } )	
	cLog		:= "" 
	lHasMarked 	:= .F.		// Define se existe itens marcados
	cMingal		:= AllTrim(SuperGetMV('MV_FMINGAL', .F., ''))
	cMingAvi	:= ""
	nPosMail	:= aScan( __oGDAI3:aHeader, { |x| AllTrim( x[2] ) == 'AI3_EMAIL' } )	

	aRequired := {}
	For nI := 1 To Len(__oGDAI3:aHeader)
		If __oGDAI3:aHeader[nI][17] // Obrigatorio
			aAdd(aRequired,nI)	//	Posicao do campo obrigatorio no acols
		EndIf
	Next nI

	For nI := 1 To Len(__oGDAI3:aCols)
		If !__oGDAI3:aCols[nI][ Len(__oGDAI3:aHeader) + 1 ]	// Não Deletado
			If __oGDAI3:aCols[nI][nPosMark] == BMP_ON		// Marcado

				lHasMarked := .T.

				For nJ := 1 To Len(aRequired)
					If Empty(__oGDAI3:aCols[nI][ aRequired[nJ] ])
						cLog := STR0029 + CRLF	// "Existem linhas marcadas com campos obrigatórios em branco"
						cLog += STR0016 + cValToChar(nI) + CRLF + STR0017 + __oGDAI3:aHeader[aRequired[nJ]][1]	// "Linha: " # "Campo: "
						FwAlertHelp(cLog,'') 
						lRet := .F.
						Exit
					EndIf
				Next nJ

				If !lRet								
					Exit
				EndIf

				// Caso configurado para mandar e-mail de acesso e não informou e-mail de algum usuario selecionado
				If !Empty(cMingal) .AND. nPosMail > 0 .AND. Empty(__oGDAI3:aCols[nI][nPosMail])
					cMingAvi := STR0030	//	'Existem usuários sem o campo e-mail preenchido. Não será enviado e-mail automático com os dados de acesso para os usuários sem o campo e-mail preenchido.'
				EndIf

			EndIf
		EndIf
	Next nI	

	If lRet .AND. !lHasMarked
		lRet := .F.
		FwAlertHelp(STR0031,'') // 'Nenhum usuário foi selecionado'
	EndIf

	If lRet .AND. !Empty(cMingAvi)
		FwAlertHelp(cMingAvi,STR0032) // 'Caso queira enviar e-mail automático com os dados de acesso para os usuários, clique em voltar e preencha o campo e-mail.'
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DobClick
Função dois cliques
@param __oGDAI3, 		Objeto Get Dados
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function DobClick(oMsNewGD As Object )

	If oMsNewGD:oBrowse:nColPos == 1 
		F220BMP(@oMsNewGD,1)
	Else
		oMsNewGD:EditCell()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F220BMP
Troca imagem marcação
@param oMsNewGD,
		nPosAtivo
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function F220BMP(oMsNewGD As Object,nPosAtivo As Numeric)

	If !oMsNewGD:aCols[oMsNewGD:nAt][Len(oMsNewGD:aHeader)+1]
		If oMsNewGD:aCols[oMsNewGD:nAt][nPosAtivo] == BMP_ON
			oMsNewGD:aCols[oMsNewGD:nAt][nPosAtivo]:= BMP_OFF
		Else
			oMsNewGD:aCols[oMsNewGD:nAt][nPosAtivo]:= BMP_ON
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadHeader
Retirna strutura AI3 para getdados
@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function GetDadHeader( cAlias As Character, lAddMark As Logical, cOnlyFields As Character) As Array

	Local aRet 	As Array
	Local aAux 	As Array
	Local nI	As Numeric

	Default lAddMark := .F.	// Define se adiciona coluna de marcação.
	Default cOnlyFields := ""

	aRet := {}
	aAux := FWFormStruct(2, cAlias ,,.T.)

	For nI := 1 To Len(aAux:aFields)

		If nI == 1 .AND. lAddMark 
			aAdd( aRet, { 	'' 	, ; 	// 01 - Titulo
							'MARK'	, ;		// 02 - Campo
							'@BMP'	, ;		// 03 - Picture
							4		, ;		// 04 - Tamanho
							0		, ;		// 05 - Decimal
							.F.  	, ;		// 06 - Valid
							'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     '  	, ;		// 07 - Usado
							'C'   	, ;		// 08 - Tipo
							''		, ;		// 09 - F3
							''		, ;   	// 10 - Contexto
							''		, ; 	// 11 - ComboBox
							'"LBNO"', ;		// 12 - Relacao		
							.F.		, ; 	// 13 - When
							''		, ; 	// 14 - Visual
							''		, ; 	// 15 - Valid User
							''		, ;		// 16 - Picture Var
							.F.		} )		// 17 - Obrigat
		EndIf

		If X3Uso(GetSX3Cache(aAux:aFields[nI][1], 'X3_USADO')) .AND. cNivel >= GetSX3Cache(aAux:aFields[nI][1], 'X3_NIVEL') .AND. aAux:aFields[nI][1] $ cOnlyFields
			aAdd( aRet, { 	AllTrim(GetSX3Cache(aAux:aFields[nI][1], 'X3_TITULO') ), ; 	// 01 - Titulo
							GetSX3Cache(aAux:aFields[nI][1], 'X3_CAMPO')	, ;		// 02 - Campo
							GetSX3Cache(aAux:aFields[nI][1], 'X3_PICTURE')	, ;		// 03 - Picture
							GetSX3Cache(aAux:aFields[nI][1], 'X3_TAMANHO')	, ;		// 04 - Tamanho
							GetSX3Cache(aAux:aFields[nI][1], 'X3_DECIMAL')	, ;		// 05 - Decimal
							GetSX3Cache(aAux:aFields[nI][1], 'X3_VALID')  	, ;		// 06 - Valid
							GetSX3Cache(aAux:aFields[nI][1], 'X3_USADO')  	, ;		// 07 - Usado
							GetSX3Cache(aAux:aFields[nI][1], 'X3_TIPO')   	, ;		// 08 - Tipo
							GetSX3Cache(aAux:aFields[nI][1], 'X3_F3')		, ;		// 09 - F3
							GetSX3Cache(aAux:aFields[nI][1], 'X3_CONTEXT')	, ;   	// 10 - Contexto
							GetSX3Cache(aAux:aFields[nI][1], 'X3_CBOX')		, ; 	// 11 - ComboBox
							GetSX3Cache(aAux:aFields[nI][1], 'X3_RELACAO')	, ; 	// 12 - Relacao
							GetSX3Cache(aAux:aFields[nI][1], 'X3_WHEN')		, ; 	// 13 - When
							GetSX3Cache(aAux:aFields[nI][1], 'X3_VISUAL')	, ; 	// 14 - Visual
							GetSX3Cache(aAux:aFields[nI][1], 'X3_VLDUSER')	, ; 	// 15 - Valid User
							GetSX3Cache(aAux:aFields[nI][1], 'X3_PICTVAR')	, ;		// 16 - Picture Var
							X3Obrigat(aAux:aFields[nI][1])		 			} )		// 17 - Obrigat

		EndIf

	Next nI
	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IncAI3
Incluir Usuário Portal
@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function IncAI3(aAI3 As Array , aAI4 As Array) As Array

	Local oMdl220	As Object
	Local oMdlAI4	As Object
	Local oMdlAI6	As Object	
	Local cLog		As Character
	Local cProcesso	As Character
	Local cCodWS	As Character
	Local aRet		As Array
	Local nI		As Numeric
	Local nJ		As Numeric

	cCodWS 	:= PadR(SuperGetMV('MV_WEBSVPC', .F., 'PORTALCLIENTEMINGLE'), TamSX3('AI7_WEBSRV')[01])
	aRet 	:= {}

	oMdl220     := FWLoadModel('FATA220')
	oMdl220:SetOperation(MODEL_OPERATION_INSERT)
	oMdl220:Activate()

	For nI := 1 To Len(aAI3)
		If !Empty(aAI3[nI][2])
			oMdl220:SetValue("AI3MASTER",aAI3[nI][1],aAI3[nI][2])
		EndIf
	Next nI

	oMdlAI4 := oMdl220:GetModel('AI4DETAIL')
	For nI := 1 To Len(aAI4)
		If !oMdlAI4:IsEmpty()
			oMdlAI4:AddLine()
		EndIf		
		For nJ := 1 To Len(aAI4[nI])
			If !Empty(aAI4[nI][nJ][2])
				oMdlAI4:SetValue(aAI4[nI][nJ][1],aAI4[nI][nJ][2])
			EndIf
		Next nJ	
	Next nI		

	oMdlAI6 := oMdl220:GetModel('AI6DETAIL')	
	oMdlAI6:SetValue('AI6_WEBSRV',cCodWS)	

	cProcesso := STR0033 + ' - AI3_LOGIN: ' + AllTrim(oMdl220:GetValue("AI3MASTER","AI3_LOGIN"))  + ' , AI3_NOME: ' + AllTrim(oMdl220:GetValue("AI3MASTER","AI3_NOME")) // 'INCLUSÃO'

	If oMdl220:VldData()
		oMdl220:CommitData()
		ConfirmSX8()
		aAdd( aRet , .T.)
		aAdd( aRet , STR0034)	//	'Sucesso'
		aAdd( aRet , cProcesso)		
	Else
		cLog := cValToChar(oMdl220:GetErrorMessage()[4]) + ' - '
		cLog += cValToChar(oMdl220:GetErrorMessage()[5]) + ' - '
		cLog += cValToChar(oMdl220:GetErrorMessage()[6])
		aAdd( aRet , .F.)		
		aAdd( aRet , cLog)
		aAdd( aRet , cProcesso)
	Endif
	oMdl220:DeActivate()
	oMdl220:Destroy()
	oMdl220:= Nil
	
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GetDadHeader
Retirna strutura AI3 para getdados
@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function GetCliHeader()

	Local aRet 	As Array

	aRet := {}

	aAdd( aRet, { 	'' 	, ; 	// 01 - Titulo
					'MARK'	, ;		// 02 - Campo
					'@BMP'	, ;		// 03 - Picture
					4		, ;		// 04 - Tamanho
					0		, ;		// 05 - Decimal
					.F.  	, ;		// 06 - Valid
					'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     '  	, ;		// 07 - Usado
					'C'   	, ;		// 08 - Tipo
					''		, ;		// 09 - F3
					''		, ;   	// 10 - Contexto
					''		, ; 	// 11 - ComboBox
					'"LBNO"', ;		// 12 - Relacao		
					.F.		, ; 	// 13 - When
					''		, ; 	// 14 - Visual
					''		, ; 	// 15 - Valid User
					''		, ;		// 16 - Picture Var
					.F.		} )		// 17 - Obrigat


	aAdd( aRet, { 	AllTrim(GetSX3Cache('AI4_CODCLI', 'X3_TITULO') ), ; 	// 01 - Titulo
					'CODCLI'								, ;		// 02 - Campo
					GetSX3Cache('AI4_CODCLI', 'X3_PICTURE')	, ;		// 03 - Picture
					GetSX3Cache('AI4_CODCLI', 'X3_TAMANHO')	, ;		// 04 - Tamanho
					GetSX3Cache('AI4_CODCLI', 'X3_DECIMAL')	, ;		// 05 - Decimal
					'F220EVFCli()'						  	, ;		// 06 - Valid
					GetSX3Cache('AI4_CODCLI', 'X3_USADO')  	, ;		// 07 - Usado
					GetSX3Cache('AI4_CODCLI', 'X3_TIPO')   	, ;		// 08 - Tipo
					GetSX3Cache('AI4_CODCLI', 'X3_F3')		, ;		// 09 - F3
					GetSX3Cache('AI4_CODCLI', 'X3_CONTEXT')	, ;   	// 10 - Contexto
					GetSX3Cache('AI4_CODCLI', 'X3_CBOX')	, ; 	// 11 - ComboBox
					GetSX3Cache('AI4_CODCLI', 'X3_RELACAO')	, ; 	// 12 - Relacao
					GetSX3Cache('AI4_CODCLI', 'X3_WHEN')	, ; 	// 13 - When
					GetSX3Cache('AI4_CODCLI', 'X3_VISUAL')	, ; 	// 14 - Visual
					GetSX3Cache('AI4_CODCLI', 'X3_VLDUSER')	, ; 	// 15 - Valid User
					GetSX3Cache('AI4_CODCLI', 'X3_PICTVAR')	, ;		// 16 - Picture Var
					X3Obrigat('AI4_CODCLI')		 			} )		// 17 - Obrigat


	aAdd( aRet, { 	AllTrim(GetSX3Cache('AI4_LOJCLI', 'X3_TITULO') ), ; 	// 01 - Titulo
					'LOJCLI'								, ;		// 02 - Campo
					GetSX3Cache('AI4_LOJCLI', 'X3_PICTURE')	, ;		// 03 - Picture
					GetSX3Cache('AI4_LOJCLI', 'X3_TAMANHO')	, ;		// 04 - Tamanho
					GetSX3Cache('AI4_LOJCLI', 'X3_DECIMAL')	, ;		// 05 - Decimal
					'F220EVFCli()'						  	, ;		// 06 - Valid
					GetSX3Cache('AI4_LOJCLI', 'X3_USADO')  	, ;		// 07 - Usado
					GetSX3Cache('AI4_LOJCLI', 'X3_TIPO')   	, ;		// 08 - Tipo
					GetSX3Cache('AI4_LOJCLI', 'X3_F3')		, ;		// 09 - F3
					GetSX3Cache('AI4_LOJCLI', 'X3_CONTEXT')	, ;   	// 10 - Contexto
					GetSX3Cache('AI4_LOJCLI', 'X3_CBOX')	, ; 	// 11 - ComboBox
					GetSX3Cache('AI4_LOJCLI', 'X3_RELACAO')	, ; 	// 12 - Relacao
					GetSX3Cache('AI4_LOJCLI', 'X3_WHEN')	, ; 	// 13 - When
					GetSX3Cache('AI4_LOJCLI', 'X3_VISUAL')	, ; 	// 14 - Visual
					GetSX3Cache('AI4_LOJCLI', 'X3_VLDUSER')	, ; 	// 15 - Valid User
					GetSX3Cache('AI4_LOJCLI', 'X3_PICTVAR')	, ;		// 16 - Picture Var
					X3Obrigat('AI4_LOJCLI')		 			} )		// 17 - Obrigat

	aAdd( aRet, { 	AllTrim(GetSX3Cache('AI4_NOMCLI', 'X3_TITULO') ), ; 	// 01 - Titulo
					'NOMCLI'								, ;		// 02 - Campo
					GetSX3Cache('AI4_NOMCLI', 'X3_PICTURE')	, ;		// 03 - Picture
					GetSX3Cache('AI4_NOMCLI', 'X3_TAMANHO')	, ;		// 04 - Tamanho
					GetSX3Cache('AI4_NOMCLI', 'X3_DECIMAL')	, ;		// 05 - Decimal
					'F220EVFCli()'						  	, ;		// 06 - Valid
					GetSX3Cache('AI4_NOMCLI', 'X3_USADO')  	, ;		// 07 - Usado
					GetSX3Cache('AI4_NOMCLI', 'X3_TIPO')   	, ;		// 08 - Tipo
					GetSX3Cache('AI4_NOMCLI', 'X3_F3')		, ;		// 09 - F3
					GetSX3Cache('AI4_NOMCLI', 'X3_CONTEXT')	, ;   	// 10 - Contexto
					GetSX3Cache('AI4_NOMCLI', 'X3_CBOX')	, ; 	// 11 - ComboBox
					GetSX3Cache('AI4_NOMCLI', 'X3_RELACAO')	, ; 	// 12 - Relacao
					GetSX3Cache('AI4_NOMCLI', 'X3_WHEN')	, ; 	// 13 - When
					GetSX3Cache('AI4_NOMCLI', 'X3_VISUAL')	, ; 	// 14 - Visual
					GetSX3Cache('AI4_NOMCLI', 'X3_VLDUSER')	, ; 	// 15 - Valid User
					GetSX3Cache('AI4_NOMCLI', 'X3_PICTVAR')	, ;		// 16 - Picture Var
					X3Obrigat('AI4_NOMCLI')		 			} )		// 17 - Obrigat

	
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcAdd220
Processa dados da interface para modelo de dados FATA220

@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function ProcAdd220() As Logical

	Local aAllAI3	As Array
	Local aAI4		As Array
	Local lRet		As Logical
	Local nI		As Numeric
	Local lIsError	As Logical

	
	lIsError := .F.
	aAI4 	:= GetAI4()
	aAllAI3 := GetAI3()
	
	For nI := 1 To Len(aAllAI3)
		aRet := ProcAI3(aAllAI3[nI] , aAI4)
		If !aRet[1]
			FwAlertHelp(STR0035 + CRLF + aRet[3] + CRLF + aRet[2])	// 'Ocorreu erro ao incluir/alterar usuário:'
			lIsError	:= .T.
		EndIf
	Next nI

	If !lIsError
		MsgAlert(STR0036)	// 'Todos os usuários foram processados com sucesso!'
	Else
		FwAlertHelp(STR0037)	// 'Alguns usuários não foram incluídos/alterados corretamente.'
	EndIf
	lRet := .T.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcAI3
Processa dados da interface para modelo de dados FATA220

@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function ProcAI3(aAI3 As Array, aAI4 As Array) As Array

	Local aRet		As Array
	Local aArea 	As Array
	Local nPosCod 	As Numeric

	aArea := GetArea()

	nPosCod := Ascan(aAI3,{|x| Alltrim(x[1]) == "AI3_CODUSU"})

	DbSelectArea('AI3')
	AI3->(DbSetOrder(1))
	If AI3->(Dbseek(xFilial('AI3') + aAI3[nPosCod][2] ))
		aRet := AltAI3(aAI3 , aAI4 )
	Else
		aRet := IncAI3(aAI3 , aAI4 )
	EndIf	

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAI4
Processa dados da interface para modelo de dados FATA220

@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function GetAI4() As Array 

	Local aAI4		As Array
	Local aAux		As Array
	Local nI		As Numeric
	Local nPosCod	As Numeric
	Local nPosLoj	As Numeric

	aAI4		:= {}
	nPosMark	:= aScan( __oGDAI4:aHeader, { |x| AllTrim( x[2] ) == "MARK" } )
	nPosCod 	:= aScan( __oGDAI4:aHeader, { |x| AllTrim( x[2] ) == "CODCLI" } )
	nPosLoj		:= aScan( __oGDAI4:aHeader, { |x| AllTrim( x[2] ) == "LOJCLI" } )

	For nI := 1 To Len(__oGDAI4:aCols)
		If !__oGDAI4:aCols[nI][ Len(__oGDAI4:aHeader) + 1 ]	// Não Deletado
			If __oGDAI4:aCols[nI][nPosMark] == BMP_ON		// Marcado
				aAux := {}
				aAdd(aAux,{"AI4_CODCLI"		,__oGDAI4:aCols[nI][nPosCod]				,Nil})
				aAdd(aAux,{"AI4_LOJCLI"		,__oGDAI4:aCols[nI][nPosLoj]				,Nil})
				aAdd(aAI4,aAux)
			EndIf			
		EndIf
	Next nI	

Return aAI4


//-------------------------------------------------------------------
/*/{Protheus.doc} GetAI3
Processa dados da interface para modelo de dados FATA220

@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function GetAI3() As Array 

	Local aAI3		As Array
	Local aAux		As Array
	Local nI		As Numeric
	Local nJ		As Numeric
	Local nPos		As Numeric

	aAI3		:= {}
	nPosMark	:= aScan( __oGDAI3:aHeader, { |x| AllTrim( x[2] ) == "MARK" } )
	aFields		:= FWSX3Util():GetAllFields( 'AI3' , .F. ) 

	For nI := 1 To Len(__oGDAI3:aCols)
		If !__oGDAI3:aCols[nI][ Len(__oGDAI3:aHeader) + 1 ]	// Não Deletado
			If __oGDAI3:aCols[nI][nPosMark] == BMP_ON		// Marcado
				aAux := {}
				For nJ := 1 To Len(aFields)
					nPos 	:= aScan( __oGDAI3:aHeader, { |x| AllTrim( x[2] ) == aFields[nJ] } )
					If nPos > 0
						aAdd(aAux,{	aFields[nJ]		,__oGDAI3:aCols[nI][nPos]				,Nil})
					EndIf					
				Next nJ
				aAdd(aAI3,aAux)
			EndIf
		EndIf
	Next nI	

Return aAI3



//-------------------------------------------------------------------
/*/{Protheus.doc} AltAI3
Alterar Usuário Portal
@param oPanel
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function AltAI3(aAI3 As Array , aAI4 As Array) As Array

	Local oMdl220	As Object
	Local oMdlAI4	As Object
	Local oMdlAI6	As Object	
	Local cLog		As Character
	Local cProcesso	As Character
	Local cCodWS	As Character
	Local aRet		As Array
	Local nI		As Numeric
	Local nJ		As Numeric

	cCodWS 	:= PadR(SuperGetMV('MV_WEBSVPC', .F., 'PORTALCLIENTEMINGLE'), TamSX3('AI7_WEBSRV')[01])
	aRet 	:= {}

	oMdl220     := FWLoadModel('FATA220')
	oMdl220:SetOperation(MODEL_OPERATION_UPDATE)
	oMdl220:Activate()

	For nI := 1 To Len(aAI3)
		If oMdl220:GetValue("AI3MASTER",aAI3[nI][1]) <> aAI3[nI][2]
			oMdl220:SetValue("AI3MASTER",aAI3[nI][1],aAI3[nI][2])
		EndIf
	Next nI

	oMdlAI4 := oMdl220:GetModel('AI4DETAIL')
	For nI := 1 To Len(aAI4)
		If !oMdlAI4:SeekLine( { {"AI4_CODCLI", aAI4[nI][1][2] },{"AI4_LOJCLI", aAI4[nI][2][2] } } )
			If !oMdlAI4:IsEmpty()
				oMdlAI4:AddLine()
			EndIf		
			For nJ := 1 To Len(aAI4[nI])
				If !Empty(aAI4[nI][nJ][2])
					oMdlAI4:SetValue(aAI4[nI][nJ][1],aAI4[nI][nJ][2])
				EndIf
			Next nJ	
		EndIf			
	Next nI		

	oMdlAI6 := oMdl220:GetModel('AI6DETAIL')	
	If !(oMdlAI6:SeekLine({{"AI6_WEBSRV", cCodWS}}))
		If !oMdlAI6:IsEmpty()
			oMdlAI4:AddLine()
		EndIf
		oMdlAI6:SetValue('AI6_WEBSRV',cCodWS)	
	EndIf

	cProcesso := STR0038 + ' - ' + 'AI3_CODUSU: ' + oMdl220:GetValue("AI3MASTER","AI3_CODUSU") + ', AI3_LOGIN: ' + AllTrim(oMdl220:GetValue("AI3MASTER","AI3_LOGIN"))  + ', AI3_NOME: ' + AllTrim(oMdl220:GetValue("AI3MASTER","AI3_NOME"))	// 'ALTERAÇÃO'

	If oMdl220:VldData()
		oMdl220:CommitData()
		ConfirmSX8()
		aAdd( aRet , .T.)
		aAdd( aRet , STR0034) // 'Sucesso'
		aAdd( aRet , cProcesso)		
	Else
		cLog := cValToChar(oMdl220:GetErrorMessage()[4]) + ' - '
		cLog += cValToChar(oMdl220:GetErrorMessage()[5]) + ' - '
		cLog += cValToChar(oMdl220:GetErrorMessage()[6])
		aAdd( aRet , .F.)		
		aAdd( aRet , cLog)
		aAdd( aRet , cProcesso)
	Endif
	oMdl220:DeActivate()
	oMdl220:Destroy()
	oMdl220:= Nil
	
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FirsCod
Vefifica se é o primeiro Código desse cliente informado na grid
@param oSubModel		, Object	, Submodelo AI4
@param nLine			, Numeric	, Linha atual da grid
@param cValue			, Charater	, AI4_CODCLI
@author rafael.rondon
@since 30/11/2022
/*/
//-------------------------------------------------------------------
Static Function FirsCod(oSubModel As Object ,nLine As Numeric ,cValue As Character) As Logical

	Local nX			As Numeric
	Local lFirst		As Logical
	Local aSaveLines  	As Array

	nX := 1
	lFirst := .T.

	aSaveLines  := FWSaveRows()

	For nX := 1 To oSubModel:Length()
		If nX <> nLine
			oSubModel:Goline(nX)
			If !oSubModel:IsDeleted()
				If oSubModel:GetValue("AI4_CODCLI") == cValue
					lFirst := .F.
					Exit
				EndIf
			Endif
		EndIf
	Next nX

	FWRestRows( aSaveLines )

Return lFirst


//-------------------------------------------------------------------
/*/{Protheus.doc} IsRightMingle
verifica se foi vinculado o WebService do Portal do Cliente para o usuário
@author rafael.rondon
@since 19/12/2022
/*/
//-------------------------------------------------------------------
Static Function IsRightMingle() As Logical

	Local lRet 		As Logical
	Local oModel 	As Object
	Local oModelAI6	As Object
	Local cCodWS	As Character

	lRet := .F.	

	cCodWS := PadR(SuperGetMV('MV_WEBSVPC', .F., 'PORTALCLIENTEMINGLE'), TamSX3('AI7_WEBSRV')[01])
	If !Empty(cCodWS)
		oModel := FWModelActive()
		oModelAI6 := oModel:GetModel('AI6DETAIL')
		If (oModelAI6:SeekLine({{"AI6_WEBSRV", cCodWS}}))
			lRet := .T.
		EndIf
	EndIf	

Return lRet
