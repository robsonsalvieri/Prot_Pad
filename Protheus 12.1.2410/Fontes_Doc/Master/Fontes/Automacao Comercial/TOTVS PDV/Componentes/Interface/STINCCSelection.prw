#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE 'FWBROWSE.CH'
#INCLUDE "POSCSS.CH"   
#INCLUDE "STINCCSELECTION.CH"
#INCLUDE "STPOS.CH"

#DEFINE NCCSELECTED 	1	// Campo logico que indica se a NCC foi selecionada
#DEFINE SE1NUM			3	// Posicao do campo E1_NUM do Array aNCCsCli
#DEFINE SE1RECNO 		5	// Posicao do Recno do registro dentro do Array aNCCsCli
#DEFINE SE1SALDO		6	// Posicao do campo E1_SALDO do Array aNCCsCli
#DEFINE SE1PREFIXO		9	// Posicao do campo E1_PREFIXO do Array aNCCsCli
#DEFINE SE1PARCELA		10	// Posicao do campo E1_PARCELA do Array aNCCsCli
#DEFINE SE1TIPO 		11	// Posicao do campo E1_TIPO do Array aNCCsCli

Static nNccSelOld		:= 0						// Valor das NCC's Selecionadas no orçamento
Static aNccsSelCliOld	:= {}						// Backup do Array aNCCsCli
Static aNCCsCli			:= {}						// Array com todas as NCCs do cliente
Static oLblSelTotal		:= Nil						// Objeto do label que informa o valor total das NCCs selecionadas.		
Static oLblTotalVend	:= Nil						// Label que informa o restante para pagamento																
Static cTextSelection	:= STR0010					// "Item Selecionado - "
Static lZeraPayImport	:= .F.						// Indica se considera as formas de pagamentos importados 
//-------------------------------------------------------------------
/*{Protheus.doc} STINCCSelection
Responsavel por montar a interface de selecao de NCCs

@author Vendas CRM
@since 26/04/2013
@version 11.80
@return oMainPanel - Objeto contendo o painel de selecao de NCCs

*/
//-------------------------------------------------------------------

Function STINCCSelection()
Local oPanelMVC  		:= STIGetPanel()				// Objeto do Panel onde a interface de selecao de clientes sera criada
Local oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta

/*
	Declaracao dos Objetos
*/
Local oLblCab			:= Nil							// Objeto do label "Seleção de Notas de Crédito ao Cliente"
Local oLblList			:= NIl							// Objeto do label "Digite aqui para filtrar"
Local oListPanel		:= Nil 							// Objeto do panel onde será criado o Browse com as NCCs do cliente.
Local oListNCCs			:= Nil							// Objeto do tipo TListBox, que exibe as NCCs do cliente.
Local oLblCliTotal		:= Nil							// Objeto do label que informa o valor total das NCCs do cliente.
Local oTotal  			:= STFGetTot() 					// Recebe o Objeto totalizador	

/*
	Variaveis de posicionamento de objetos
*/
Local nPosVerPanListBox	:= oMainPanel:nHeight/2 * 0.0666// Posicao vertical do objeto TPanel oListPanel
Local nPosVerTListBox	:= oMainPanel:nHeight/2 * 0.05	// Posicao vertical do Say oLblList
Local nListPosHor		:= oMainPanel:nWidth/2 * 0.05	// Posicao Horizontal do objeto TListBox oListNCCs


/*/
	Botão "Selecionar Cliente"
/*/
Local oButton			:= Nil							// Botao "Selecionar Cliente"
Local aListNCCs			:= {}							// Itens do objeto oListNCCs
Local nX				:= 0							// Contador do FOR
Local oListFont 		:= TFont():New("Courier New") 	// Fonte utilizada no listbox

Local nSaldoNCCs		:= 0							// Total das NCCs do cliente
Local nTotalSel			:= 0							// Total das NCCs selecionadas
Local oTotFont			:= TFont():New( "Arial"	,Nil,-13,Nil,.T. )	// Objeto da fonte dos totalizadores

Local cText 			:= ""							//Texto selecionado
Local nValRest			:= 0							//REstante
Local oSelVlr			:= Nil							//Objeto checkbox de seleção automatica de valores da NCC
Local LSELVLR			:= .F.							//Seleciona automaticamente valores de NCC
Local lPeTPOpNCC		:= ExistBlock("STTPOPNCC")		//Ponto de Entrada para permitir ou não alterar NCCs definidos pelo Orçamento na Importação pelo Totvs PDV
Local cTpOpNcc			:= ""

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Monta a interface de seleção de NCCs" )  //Gera LOG

aNCCsCli		:= STDGetNCCs("1")		
aNccsSelCliOld 	:= Aclone(aNCCsCli)

//Limpa a variavel de saldo selecionados
STDSetNCCs("2") 	

If SuperGetMv("MV_LJNCCOR", Nil, .F.)
	//Carrega a NCC que foi definida no orçamento
	STDSetNCCs("1",aNccsSelCliOld)
	aNCCsCli := STDGetNCCs("1")
EndIf

For nX := 1 To Len(aNCCsCli)
	cText := STR0001+aNCCsCli[nX,SE1PREFIXO]+STR0002+aNCCsCli[nX,SE1NUM]+STR0003+aNCCsCli[nX,SE1PARCELA]+STR0004+AllTrim(Str(aNCCsCli[nX,SE1SALDO]))+STR0016+aNCCsCli[nX,SE1TIPO]
	If aNCCsCli[nX,NCCSELECTED]
		cText := cTextSelection + cText
		STDSetNCCs("2",aNCCsCli[nX,SE1SALDO])
	EndIf
	aAdd(aListNCCs,cText)

	nSaldoNCCs += aNCCsCli[nX,SE1SALDO]
Next nX

//Retorna o Total Selecionado
nTotalSel  := STDGetNCCs("2")
nNccSelOld := nTotalSel

//Calcula o Restante a receber
nValRest := oTotal:GetValue("L1_VLRTOT") - nTotalSel

//Tratamento só para não aparecer valor negativo no valor restante para pagamento.
If nValRest < 0
	nValRest := 0
EndIf
	
/*/
	Cabecalho da tela - "Seleção de Notas de Crédito ao Cliente"
/*/
oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0005},oMainPanel,,,,,,.T.,,,,) //"Seleção de Notas de Crédito ao Cliente"
oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 	 

/* Instancia do Painel do ListBox de selecao de NCCs */
oListPanel := TPanel():New(nPosVerPanListBox,000,"",oMainPanel,,,,,,oMainPanel:nWidth/2.15,oMainPanel:nHeight/5)

/* Instancia do Label do ListBox de selecao de NCCs */
oLblList:= TSay():New(000,nListPosHor,{||STR0006},oListPanel,,oTotFont,,,,.T.,,,,)                                                        								                                 //"Selecione os titulos desejados e clique em 'Avançar'"
oLblList:SetCSS( POSCSS (GetClassName(oLblList), CSS_LABEL_FOCAL )) 

/* Instancia do ListBox das NCCs do cliente */
oListNCCs := TListBox():Create(oListPanel, nPosVerTListBox, nListPosHor, Nil, aListNCCs, oListPanel:nWidth/2.2, oListPanel:nHeight/2.5,,,,,.T.,,{||STISelectNCC(oListNCCs)},oListFont)
oListNCCs:SetCSS( POSCSS (GetClassName(oListNCCs), CSS_LISTBOX )) 

/* Instancia do Label que informa o valor total das NCCs que o cliente possui */
oLblCliTotal := TSay():New(oMainPanel:nHeight/4.5,nListPosHor,{||STR0007 +AllTrim(Str(nSaldoNCCs))},oMainPanel,,oTotFont,,,,.T.,,,,)  //"Saldo Total: "
oLblCliTotal:SetCSS( POSCSS (GetClassName(oLblCliTotal), CSS_LABEL_FOCAL )) 

/* Instancia do Label que informa o valor total das NCCs selecionadas */
oLblSelTotal := TSay():New(oMainPanel:nHeight/4.5,nListPosHor*7.5,{||STR0008+AllTrim(Str(nTotalSel))},oMainPanel,,oTotFont,,,,.T.,,,,)  //"Total Selecionado: "
oLblSelTotal:SetCSS( POSCSS (GetClassName(oLblSelTotal), CSS_LABEL_FOCAL )) 

oSelVlr := TCheckBox():New(oMainPanel:nHeight/4, nListPosHor,STR0015,{|| lSelVlr },oMainPanel,100,,,{|| (lSelVlr := STI7SelNcc(oListNCCs, lSelVlr),oSelVlr:Refresh())}) //"Seleção automática de valores"

/* Instancia do Label que informa o restante a ser pago na venda */
oLblTotalVend := TSay():New(oMainPanel:nHeight/3.5, nListPosHor, {||STR0011 + AllTrim(Str(nValRest,12,2)) +STR0012}, oMainPanel,,oTotFont,,,,.T.,,,,10)
oLblTotalVend:SetCSS( POSCSS (GetClassName(oLblTotalVend), CSS_LABEL_FOCAL )) 

/* Instancia do botao "Avançar" */
oButton	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0013,oMainPanel,{ || STISNCCPayment()}, ; //"Avançar"
							LARGBTN,ALTURABTN,,,,.T.)

oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL ))

If SuperGetMV("MV_LJASNNC",.F.,"1") == "2" //Seleciona automaticamente os valores caso esteja 2
	lSelVlr := STI7SelNcc(oListNCCs, lSelVlr)	
EndIf

If lPeTPOpNCC .AND. STBIsImpOrc()
	cTpOpNcc := ExecBlock("STTPOPNCC",.F.,.F.)
	oListNCCs:lReadOnly:= (cTpOpNcc=="1") 
	oSelVlr:lReadOnly:= (cTpOpNcc=="1")
Endif
								
Return oMainPanel

//-------------------------------------------------------------------
/*{Protheus.doc} STISelectNCC
Responsavel por realizar a marcacao do item selecionado

@aparam oListNCCs - Objeto do tipo TListBox responsavel por apresentar as NCCs do cliente.
@author Vendas CRM
@since 26/04/2013
@version 11.80
*/
//-------------------------------------------------------------------

Static Function STISelectNCC(oListNCCs)
Local nLine 		:= oListNCCs:nAt
Local cTextNCC 		:= oListNCCs:GetSelText()
Local oTotal  		:= STFGetTot() 									// Recebe o Objeto totalizador
Local nTotalVend	:= oTotal:GetValue("L1_VLRTOT") 				// Valor total da venda
Local nTotalNCCs	:= STDGetNCCs("2")								// Valor total das NCCs
Local nValRest		:= 0											// Valor restante para pagamento
Local lImport		:= !Empty(STDGPBasket("SL1" , "L1_NUMORIG")) 	// Variavel de controle que identifica se é importação de orçamento

DEFAULT oListNCCs := Nil

If !lImport .OR. (lImport .AND. STFProfile(41)[1]) 
	If ValType(oListNCCs) == "O"

		If Len(cTextNCC) > Len(cTextSelection) .AND. SubStr(cTextNCC,1,Len(cTextSelection)) == cTextSelection // Caso o item esteja selecionado, desmarca o item.
			STDSetNCCs("2",-aNCCsCli[nLine,SE1SALDO]) 						//O saldo da NCC posicionada é deduzido do total selecionado
			oListNCCs:Modify(SubStr(cTextNCC,Len(cTextSelection)+1),nLine) 	// O texto de selecao é removido
			aNCCsCli[nLine,NCCSELECTED] := .F.								// A NCC é desmarcada como selecionada
			LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "NCC removida", cTextSelection+oListNCCs:GetSelText() ) //Grava Log =====================================================================
		Else // Caso contrario, marca o item
			/* Verifico se o total de NCCs selecionadas nao extrapolou o valor total da venda */
			If nTotalVend > nTotalNCCs 
				STDSetNCCs("2",aNCCsCli[nLine,SE1SALDO]) 						// Atualiza o saldo total de NCCs selecionadas
				oListNCCs:Modify(cTextSelection+oListNCCs:GetSelText(),nLine)	// Modifica o texto para informar que a NCC foi selecionada
				aNCCsCli[nLine,NCCSELECTED] := .T.								// A NCC é marcada como selecionada
				LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "NCC selecionada", cTextSelection+oListNCCs:GetSelText() ) //Grava Log =====================================================================
			Else
				STFMessage(ProcName(),"STOP",STR0014) //"Valor total já atingido."
				STFShowMessage(ProcName())	
				STFCleanMessage(ProcName())
			EndIf
		EndIf
		
		nTotalNCCs := STDGetNCCs("2")
		If (nTotalVend-nTotalNCCs) > 0
			nValRest := nTotalVend-nTotalNCCs
		Else
			nValRest := 0
		EndIf
		
		oLblSelTotal:SetText(STR0008+AllTrim(Str(STDGetNCCs("2")))) //"Total Selecionado: "
		oLblTotalVend:SetText(STR0011 + AllTrim(Str(nValRest,12,2)) + STR0012)

		LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "NCC - Total selecionado", STR0008+AllTrim(Str(STDGetNCCs("2"))) ) //Grava Log =====================================================================
		LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "NCC - Total restante", STR0011 + AllTrim(Str(nValRest,12,2)) + STR0012 ) //Grava Log =====================================================================

	EndIf
Else
	STFMessage(ProcName(),"STOP",STR0017) //"Usuario sem permissão para alterar a negociação do orçamento."
	STFShowMessage(ProcName())	
EndIf
Return


//-------------------------------------------------------------------
/* {Protheus.doc} STISNCCPayment
Funcao que seta um array estatico das NCCs com as informacoes que serao passadas para o componente de pagamento.
Tambem chama a tela de pagamento.

@author  	Vendas & CRM
@version 	P12
@since   	01/03/2013
@return  	
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STISNCCPayment()
Local oModelPayment := ModelPayme() 							 // Modelo de dados do Pagamento
Local oMdlParc 		:= oModelPayment:GetModel("PARCELAS")
Local oMdlaPaym 	:= oModelPayment:GetModel("APAYMENTS") 
Local oTotal  		:= STFGetTot() 								 // Recebe o Objeto totalizador
Local nTotalVend	:= oTotal:GetValue("L1_VLRTOT") 			 // Valor total da venda
Local nTotalNCCs	:= STDGetNCCs("2")							 // Valor total das NCCs
Local nMVLJCPNCC	:= SuperGetMv("MV_LJCPNCC ",,1)				 // Tratamento para compensacao de NCC 1 - INCLUSAO DE NOVO TITULO|2 - ALTERACAO DO SALDO|3 - BAIXA TOTAL DA NCC|4 - SALDO DA NCC COM TROCO 
Local lImport		:= !Empty(STDGPBasket("SL1" , "L1_NUMORIG")) // Variavel de controle que identifica se é importação de orçamento

oMdlaPaym:DeActivate()
oMdlaPaym:Activate()

oMdlParc:DeActivate()
oMdlParc:Activate()

STDSetNCCs("1",aNCCsCli)

LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "O parametro MV_LJCPNCC esta configurado como ", nMVLJCPNCC )
If nMVLJCPNCC == 4 //Somente quando esta config. 4 que os parametros de troco são necessário saber
	LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "O parametro MV_LJTROCO esta configurado como ", SuperGetMv("MV_LJTROCO",,.F.) )
	LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "O parametro MV_LJTRDIN esta configurado como ", SuperGetMv("MV_LJTRDIN",,0) )
EndIf

If nTotalNCCs == 0
	//nTotalNCCs zerado indica que nenhuma NCC foi selecionada ou caso tenha foi desmarcada.
	LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Nenhuma NCC foi selecionada",nTotalNCCs)
	
	If lImport .AND. nNccSelOld <> nTotalNCCs //Caso seja importação e as NCC"s foram alteradas
		
		LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Existe uma diferença entre as NCC's do orçamento e as NCC's da venda")
		
		STFMessage("STISNCCPay","YESNO",STR0018)//"Caso altere a negociação incluindo ou removendo uma NCC sera necessario refazer as formas de pagamento, deseja continuar"
		
		LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Caso altere a negociação incluindo ou removendo uma NCC sera necessario refazer as formas de pagamento, deseja continuar")
		
		If STFShowMessage("STISNCCPay")
			LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Sim, desejo seguir com a alteração.")
			
			//Indico que devera limpar as fomar de pagamento com a variavel lZeraPayImport = True
			lZeraPayImport := .T.
			
			//Carrego os paineis para os demais pagamentos
			STIExchangePanel({|| STIPayment() })
		Else
			LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Não, desejo desfazer a alteração.")
			LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Restaurando NCC's do orçamento.")
			If nNccSelOld > nTotalVend .And. nMVLJCPNCC <> 4  // Caso o valor total das NCCs selecionadas seja maior que o valor total da venda, sera setado o valor total da venda.
				//Desfaço as alterações feitas caso ele negue
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"O valor da NCC salva no orçamento é maior que o VALOR TOTAL da venda ")
				
				//Indico que não devera limpar as fomar de pagamento com a variavel lZeraPayImport = False
				lZeraPayImport := .F.
				
				//Carrego os paineis para os demais pagamentos
				STIExchangePanel({|| STIPayment() })
				
				//Adiciono o pagamento da NCC no Grid de pagamentos
				If nNccSelOld > 0
					LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"NCC restaurada no valor de: " + cValToChar(nTotalVend))
					STIAddPay("CR", Nil, 1, Nil, Nil, nTotalVend)
				EndIf

				//Restauro o valor das NCC's e o Array aNCCsCli com as NCC's selecionadas
				STDSetNCCs("2", nTotalVend)
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Valor de pagamento com NCC's restaurado: " + cValToChar(nTotalVend))
				
				aNCCsCli := aNccsSelCliOld 
				STDSetNCCs("1",aNCCsCli)
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Array aNCCsCli resturado",aNCCsCli)
			Else
				//Desfaço as alterações feitas caso ele negue
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"NCC's do orçamento é menor ou igual ao TOTAL DA VENDA")

				//Indico que não devera limpar as fomar de pagamento com a variavel lZeraPayImport = False
				lZeraPayImport := .F.

				//Carrego os paineis para os demais pagamentos
				STIExchangePanel({|| STIPayment() })
				
				//Adiciono o pagamento da NCC no Grid de pagamentos
				If nNccSelOld > 0
					LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"NCC restaurada no valor de: " + cValToChar(nNccSelOld))
					STIAddPay("CR", Nil, 1, Nil, Nil, nNccSelOld)
				EndIf

				//Restauro o valor das NCC's e o Array aNCCsCli com as NCC's selecionadas
				STDSetNCCs("2",nNccSelOld)
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Valor de pagamento com NCC's restaurado: " + cValToChar(nNccSelOld))

				aNCCsCli := aNccsSelCliOld
				STDSetNCCs("1",aNCCsCli)
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Array aNCCsCli resturado",aNCCsCli)
			EndIf
		EndIf
	Else //Caso seja auto serviço e não selecionou NCC
		LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"NCC utilizada em venda Auto Serviço")
		STIExchangePanel({|| STIPayment() })
	EndIf
ElseIf nTotalNCCs > nTotalVend .And. nMVLJCPNCC <> 4  // Caso o valor total das NCCs selecionadas seja maior que o valor total da venda, sera setado o valor total da venda.
	LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Uma ou mais NCC's foram selecionadas, e o valor do credito é maior que o TOTAL DA VENDA",nTotalNCCs)
	
	If lImport .AND. nNccSelOld <> nTotalNCCs //Caso seja importação e as NCC"s foram alteradas
		
		LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Existe uma diferença entre as NCC's do orçamento VS a NCC's da venda")
		
		STFMessage("STISNCCPay","YESNO",STR0018) //"Caso altere a negociação incluindo ou removendo uma NCC sera necessario refazer as formas de pagamento, deseja continuar"
		
		LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Caso altere a negociação incluindo ou removendo uma NCC sera necessario refazer as formas de pagamento, deseja continuar")
		
		If STFShowMessage("STISNCCPay")	
			LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Sim, desejo seguir com a alteração.")
			
			//Indico que devera limpar as fomar de pagamento com a variavel lZeraPayImport = True
			lZeraPayImport := .T.

			//Carrego os paineis para os demais pagamentos
			STIExchangePanel({|| STIPayment() })

			//Adiciono o pagamento da NCC no Grid de pagamentos
			LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Valor do pagamento com NCC's alteradas de: " + cValToChar(nNccSelOld) + " Para: " + cValToChar(nTotalVend))
			STIAddPay("CR", Nil, 1, Nil, Nil, nTotalVend)

		Else //Desfaço as alterações feitas caso ele negue
			LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Não, desejo desfazer a alteração.")
			LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Restaurando NCC's do orçamento.")

			//Verifico se o valor da Ncc salvo no orçamento é maior que o total da venda
			If nNccSelOld > nTotalVend
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"O valor da NCC salva no orçamento é maior que o VALOR TOTAL da venda ")
				
				//Indico que não devera limpar as fomar de pagamento com a variavel lZeraPayImport = False
				lZeraPayImport := .F.

				//Carrego os paineis para os demais pagamentos
				STIExchangePanel({|| STIPayment() })

				//Adiciono o pagamento da NCC no Grid de pagamentos
				If nNccSelOld > 0
					LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"NCC restaurada no valor de: " + nTotalVend)
					STIAddPay("CR", Nil, 1, Nil, Nil, nTotalVend)
				EndIf

				//Restauro o valor das NCC's e o Array aNCCsCli com as NCC's selecionadas
				STDSetNCCs("2",nTotalVend)
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"O valor de pagamento com NCC's restaurado: " + nTotalVend)

				aNCCsCli := aNccsSelCliOld
				STDSetNCCs("1",aNCCsCli)
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Array aNCCsCli resturado",aNCCsCli)
			Else
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"O valor da NCC salva no orçamento é menor que o VALOR TOTAL da venda")
				
				//Indico que não devera limpar as fomar de pagamento com a variavel lZeraPayImport = False
				lZeraPayImport := .F.
				
				//Carrego os paineis para os demais pagamentos
				STIExchangePanel({|| STIPayment() })
				
				//Adiciono o pagamento da NCC no Grid de pagamentos
				If nNccSelOld > 0
					LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"NCC restaurada no valor de: " + cValToChar(nNccSelOld))
					STIAddPay("CR", Nil, 1, Nil, Nil, nNccSelOld)
				EndIf

				//Restauro o valor das NCC's e o Array aNCCsCli com as NCC's selecionadas
				STDSetNCCs("2",nNccSelOld)
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"O valor de pagamento com NCC's restaurado: " + cValToChar(nTotalVend))

				aNCCsCli := aNccsSelCliOld
				STDSetNCCs("1",aNCCsCli)
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Array aNCCsCli resturado",aNCCsCli)
			EndIf
		EndIf
	ElseIf !lImport .OR. (lImport .AND. nNccSelOld == nTotalNCCs )  //NCC utilizada em venda Auto Serviço ou não teve alteração nas NCC's.
		LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"NCC utilizada em venda Auto Serviço ou não teve alteração nas NCC's.")
		
		//Carrego os paineis para os demais pagamentos
		STIExchangePanel({|| STIPayment() })

		//Adiciono o pagamento da NCC no Grid de pagamentos
		STIAddPay("CR", Nil, 1, Nil, Nil, nTotalVend)
	EndIf 
Else
	LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"NCC's do orçamento é menor ou igual ao TOTAL DA VENDA")

	If lImport .AND. nNccSelOld <> nTotalNCCs //Caso seja importação e as NCC"s foram alteradas

		LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Existe uma diferença entre as NCC's do orçamento VS a NCC's da venda")
		
		STFMessage("STISNCCPay","YESNO",STR0018) //"Caso altere a negociação incluindo ou removendo uma NCC sera necessario refazer as formas de pagamento, deseja continuar"
		
		LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Caso altere a negociação incluindo ou removendo uma NCC sera necessario refazer as formas de pagamento, deseja continuar")

		If STFShowMessage("STISNCCPay")
			LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Sim, desejo seguir com a alteração.")	
			
			//Indico que devera limpar as fomar de pagamento com a variavel lZeraPayImport = True
			lZeraPayImport := .T.
			
			//Carrego os paineis para os demais pagamentos
			STIExchangePanel({|| STIPayment() })
			
			//Adiciono o pagamento da NCC no Grid de pagamentos
			STIAddPay("CR", Nil, 1, Nil, Nil, nTotalNCCs)	

		Else //Desfaço as alterações feitas caso ele negue
			
			//Indico que não devera limpar as fomar de pagamento com a variavel lZeraPayImport = False
			lZeraPayImport := .F.
			
			//Carrego os paineis para os demais pagamentos
			STIExchangePanel({|| STIPayment() })
			
			//Adiciono o pagamento da NCC no Grid de pagamentos
			If nNccSelOld > 0
				LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"NCC restaurada no valor de: " + cValToChar(nNccSelOld))
				STIAddPay("CR", Nil, 1, Nil, Nil, nNccSelOld)
			EndIf
			
			//Restauro o valor das NCC's e o Array aNCCsCli com as NCC's selecionadas
			STDSetNCCs("2",nNccSelOld)
			LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"O valor de pagamento com NCC's restaurado: " + cValToChar(nNccSelOld))
			
			aNCCsCli := aNccsSelCliOld
			STDSetNCCs("1",aNCCsCli)
			LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"Array aNCCsCli resturado",aNCCsCli)

		EndIf
	ElseIf !lImport .OR. (lImport .AND. nNccSelOld == nTotalNCCs) //NCC utilizada em venda Auto Serviço ou não teve alteração nas NCC's.
		LjGrvLog("L1_NUM: " + STDGPBasket("SL1","L1_NUM"),"NCC utilizada em venda Auto Serviço ou não teve alteração nas NCC's.")
		
		//Carrego os paineis para os demais pagamentos
		STIExchangePanel({|| STIPayment() })

		//Adiciono o pagamento da NCC no Grid de pagamentos
		STIAddPay("CR", Nil, 1, Nil, Nil, nTotalNCCs)
	EndIf 
EndIf

Return Nil

//-------------------------------------------------------------------
/* {Protheus.doc} STINCCClearStatic
Responsavel por zerar todas as variaveis static

@author  	Vendas & CRM
@version 	P12
@since   	02/05/2013
@return  	
*/
//-------------------------------------------------------------------
Function STINCCClearStatic()
	
aNCCsCli		:= {}	
oLblSelTotal	:= Nil	
oLblTotalVend	:= Nil	

STDSetNCCs("1")
STDSetNCCs("2")

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STI7SelNcc
Responsavel por marcar/desmarcar a seleção automatica dos valores de NCC
a serem utilizados na venda.

@aparam	 oListNCCs - Objeto do tipo TListBox responsavel por apresentar as NCCs do cliente.
@author	 Vendas CRM
@since	 03/12/2015
@version 11.80
*/
//-------------------------------------------------------------------
Static Function STI7SelNcc(oListNCCs, lSelVlr)
Local lImport		:= !Empty(STDGPBasket("SL1" , "L1_NUMORIG")) // Variavel de controle que identifica se é importação de orçamento

lSelVlr := !lSelVlr

If !lImport .OR. (lImport .AND. STFProfile(41)[1]) 
	STISelAutNCC(oListNCCs, lSelVlr)
Else
	lSelVlr := .F.
	STFMessage(ProcName(),"STOP",STR0017)//"Usuario sem permissão para alterar a negociação do orçamento."
	STFShowMessage(ProcName())	
EndIf 

Return lSelVlr

//-------------------------------------------------------------------
/*{Protheus.doc} STI7SelNcc
Responsavel por marcar/desmarcar a seleção automatica dos valores de NCC
a serem utilizados na venda.

@aparam	 oListNCCs - Objeto do tipo TListBox responsavel por apresentar as NCCs do cliente.
@author	 Vendas CRM
@since	 03/12/2015
@version 11.80
@obs	 Esta selecção segue a ordem crescente das posições do array da NCC.
*/
//-------------------------------------------------------------------
Static Function STISelAutNCC(oListNCCs, lSelVlr)
Local lContinua		:= .T.							// Controle do While
Local nLenNCC		:= 0							// Quantidade maxima de linhas de NCC
Local nLine 		:= 1							// Linha atual do objeto de NCC
Local nDiferenca	:= 0							// Diferença de valores entre total venda e NCC selecionadas
Local nValRest		:= 0							// Valor restante para pagamento
Local oTotal  		:= STFGetTot() 					// Recebe o Objeto totalizador
Local nTotalVend	:= oTotal:GetValue("L1_VLRTOT") // Valor total da venda
Local nTotalNCCs	:= STDGetNCCs("2")				// Valor total das NCCs

If ValType(oListNCCs) == "O"

	nLenNCC := Len(oListNCCs:aItems)

	While lContinua

		 //---------------Selecão de NCCs--------------------------
		 If lSelVlr 

		 	nDiferenca := nTotalVend - nTotalNCCs

		 	If nDiferenca <= 0 .Or. nLine > nLenNCC 
		 		lContinua := .F.
			Else
		 		oListNCCs:nAt := nLine
				If !aNCCsCli[nLine,NCCSELECTED] //Não esta selecionado?
		 			STDSetNCCs("2",aNCCsCli[nLine,SE1SALDO]) // Atualiza o saldo total de NCCs selecionadas
					oListNCCs:Modify(cTextSelection+oListNCCs:GetSelText(),nLine) // Modifica o texto para informar que a NCC foi selecionada
					aNCCsCli[nLine,NCCSELECTED] := .T. // A NCC é marcada como selecionada

					LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "NCC selecionada automaticamente", cTextSelection+oListNCCs:GetSelText() ) //Grava Log =====================================================================

		 			nTotalNCCs := STDGetNCCs("2") //atualiza valor total de NCC selecionada
		 		EndIf

		 	EndIf

		 	nLine++ //Atualiza linha do objeto

		 //-------------Retirada de seleção de NCCs----------------
		 Else

			If nTotalNCCs == 0 .Or. nLine > nLenNCC 
		 		lContinua := .F.
			Else
				 oListNCCs:nAt := nLine
				 If aNCCsCli[nLine,NCCSELECTED] //Esta selecionado?
					STDSetNCCs("2",-aNCCsCli[nLine,SE1SALDO]) //O saldo da NCC posicionada é deduzido do total selecionado
					oListNCCs:Modify(SubStr(oListNCCs:GetSelText(),Len(cTextSelection)+1),nLine) // O texto de selecao é removido
					aNCCsCli[nLine,NCCSELECTED] := .F. // A NCC é desmarcada como selecionada

					LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "NCC removida", cTextSelection+oListNCCs:GetSelText() )

					nTotalNCCs := STDGetNCCs("2") //atualiza valor total de NCC selecionada
				EndIf
			EndIf

		 	nLine++ //Atualiza linha do objeto

		 EndIf
	End

	//Atualizando valores da tela
	nTotalNCCs := STDGetNCCs("2")
	If (nTotalVend-nTotalNCCs) > 0
		nValRest := nTotalVend-nTotalNCCs
	Else
		nValRest := 0
	EndIf

	oLblSelTotal:SetText(STR0008+AllTrim(Str(STDGetNCCs("2")))) //"Total Selecionado: "
	oLblTotalVend:SetText(STR0011 + AllTrim(Str(nValRest,12,2)) + STR0012) //#Restam  ##para pagar

	LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "NCC - Total selecionado automaticamente", STR0008+AllTrim(Str(STDGetNCCs("2"))) )
	LjGrvLog( "L1_NUM: " + STDGPBasket("SL1","L1_NUM"), "NCC - Total restante", STR0011 + AllTrim(Str(nValRest,12,2)) + STR0012 ) 

EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} STIGetZrPg
Função de Get para a variavel statica lZeraPayImport, a variavel indica se deverá considerar os pagamentos de um orçamento

@aparam	
@author	 Lucas Novais (lnovias)
@since	 03/10/2018
@version 12.1.17
@obs	 
*/
//-------------------------------------------------------------------
Function STIGetZrPg()

Return lZeraPayImport

//-------------------------------------------------------------------
/*{Protheus.doc} STISetZrPg
Função de Set para a variavel statica lZeraPayImport, a variavel indica se deverá considerar os pagamentos de um orçamento

@aparam	
@author	 Lucas Novais (lnovias)
@since	 03/10/2018
@version 12.1.17
@obs	 
*/
//-------------------------------------------------------------------
Function STISetZrPg(lZeraPg)

DEFAULT lZeraPg := .F.

lZeraPayImport :=  lZeraPg

Return
