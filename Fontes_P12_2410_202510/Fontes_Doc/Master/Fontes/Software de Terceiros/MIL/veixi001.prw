#Include "PROTHEUS.CH"
#Include "VEIXI001.CH"

Static lMultMoeda := FGX_MULTMOEDA() // Trabalha com MultMoeda ?

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXI001 º Autor ³ Andre Luis / Rubens º Data ³  30/03/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Fases do Atendimento Modelo 2 - Novo                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXI001( cNumAte , nOpc , lXI001Auto, nOpcCancAuto, aMotCancAuto, cFaseInter, cParSerieNF, nTroco )
Local cMsg        := ""
Local nCntFor     := 0
Local cFaseAte    := ""
Local nRet        := 0
Local lInterrompe := .f. // Interromper o processo
Local lImprimir   := .f.
Local lRet        := .f.
Local cSerie      := ""
Local nRecVVA     := 0
Local aVVAs       := {}
Local nPosVVA     := 0
Local cObsAnt     := ""
Local lOkTit      := .f.
Local cQuery      := ""
Local nRecVQ0     := 0
Local cNamVQ0     := RetSQLName("VQ0")
Local lVVA_CODPED := ( VVA->(ColumnPos("VVA_CODPED")) > 0 ) // Codigo do Pedido Fabrica
Local lVV0_GERFIN := ( VV0->(ColumnPos("VV0_GERFIN")) > 0 ) // Campo que controla se gerou FINANCEIRO (Titulos)
Local lVV9_APRPUS := ( VV9->(ColumnPos("VV9_APRPUS")) > 0 )
Local lVX001DFA   := ExistBlock("VX001DFA")
Local lInterExecAuto := .f. // Controla se deve parar Avanco de Fase quando chamado de ExecAuto
Local oVeiculos   := DMS_Veiculo():New()
Local cMVMIL0156  := IIf(cPaisLoc=="BRA",GetNewPar("MV_MIL0156","1"),"0")
Local cMVMIL0162  := GetNewPar("MV_MIL0162","0") // Levanta Bonus automaticamente na Venda de Veic./Máq. do Atendimento ? ( 0=Não / 1=Lev.apagando existentes / 2=Lev.NAO apagando existentes )
Local lVVA_SEGMOD := ( VVA->(ColumnPos("VVA_SEGMOD")) > 0 )
Local lErro       := .F.
Local nTpFatura   := 0
Local cTpFatR     := "1" // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura com Remito
Local lVldVei     := .t. // Executa validações do Veiculo
Local aCliTotais  := {}
Local nCliTotais  := 0
Local nPosVV1 := 0, nVV1FCount := VV1->( fCount() )
Local aParamBox   := {}
Local aRet        := {}
Local lTelaTES    := .t.

Default cFaseInter  := "" // Quando chamado com ExecAuto, define a fase que irá parar a execucao
Default cParSerieNF := ""
Default nTroco      := 0

Private lCPagPad  := ( GetNewPar("MV_MIL0016","0") == "1" ) //Utiliza no Atendimento de Veículos, Condição de Pagamento da mesma forma que no Faturamento Padrão do ERP? (0=Não / 1= Sim) - Chamado CI 001985
Private lIntLoja  := Iif(cPaisLoc == "BRA", Substr(GetNewPar("MV_LOJAVEI","NNN"),3,1) == "S", .F.)
Private cTitAten  := IIf( cPaisLoc == "ARG" , "0" , IIf(lIntLoja,"2",left(GetNewPar("MV_TITATEN","0"),1)))
Private aTelaInf  := {}

private cLocxNFPV := ""
private lLocxAuto := .F.
private cIdPVArg  := ""
private cPV410    := ""
private cIdPV     := ""


If lCPagPad // Condição de Pagto Padrão (igual ao Faturamento)
	//
 	lIntLoja := .f.
	cTitAten := "0" // geração de Títulio na Finalização do Atendimento
	//
EndIf
//

DbSelectArea("VV9")
DbSetOrder(1)
If !DbSeek(xFilial("VV9")+cNumAte)
	FMX_HELP("VXI001ERR001_VV9", STR0001+" "+cNumAte) // Atendimento nao encontrado: / Atencao
	Return .f.
EndIf
DbSelectArea("VV0")
DbSetOrder(1)
If !DbSeek(xFilial("VV0")+cNumAte)
	FMX_HELP("VXI001ERR001_VV0", STR0001+" "+cNumAte) // Atendimento nao encontrado: / Atencao
	Return .f.
EndIf
DbSelectArea("VVA")
DbSetOrder(1)
If !DbSeek(xFilial("VVA")+cNumAte)
	FMX_HELP("VXI001ERR001_VVA", STR0001+" "+cNumAte) // Atendimento nao encontrado: / Atencao
	Return .f.
EndIf
nRecVVA := VVA->(Recno())
While !VVA->(Eof()) .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == cNumAte
	aAdd(aVVAs,{ VVA->VVA_CHAINT , VVA->VVA_CHASSI , VVA->(RecNo()) , VVA->VVA_CODTES , VVA->VVA_ITETRA })
	VVA->(dbSkip())
EndDo
VVA->(dbGoTo(nRecVVA))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cancelamento do Atendimento                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5 // Cancelar
	VXI001CANCEL(cNumAte,nOpc,aVVAs, lXI001Auto, nOpcCancAuto, aMotCancAuto)
	Return .t.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ ARGENTINA                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "ARG" // Argentina
	lVldVei := Empty(VV0->VV0_NUMNFI+VV0->VV0_REMITO) // Validar Veiculos se ainda não gerou Fatura ou Remito
	cTpFatR := VV0->VV0_TPFATR // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura com Remito
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes do(s) Veiculo(s)                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVldVei .and. !VXI001VLVEI(aVVAs)
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando integrado com o Venda Direta validar VENDEDOR      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lIntLoja
	If VV0->(ColumnPos("VV0_VENVDI")) > 0 .and. Empty(VV0->VV0_VENVDI)
		FMX_HELP("VXI001ERR002", STR0029) // Necessario informar o vendedor a ser utilizado na Venda Direta. Este campo sera considerado na integracao do Atendimento com a rotina de Venda Direta. / Atencao
		Return .f.
	EndIf
EndIf

// Verificação de Valor a Devolver ao Cliente (Troco)
If cMVMIL0156 == "0" .And. nTroco > 0
	FMX_HELP("VXI001ERR020", STR0043, STR0044) // Não é possível avançar pois há valor a devolver ao cliente (troco). / Corrija o valor ou altere a configuração do parâmetro MV_MIL0156.
	Return .f.
ElseIf cMVMIL0156 == "2" .And. nTroco > 0
	If !MsgYesNo(STR0045 + GetMV("MV_SIMB1") + " " + Alltrim(Str(nTroco, 10, 2)); // Há valor para devolução ao cliente (troco):  
		+ CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0047, STR0003) // Deseja continuar com o Avanço de Fase? / Atenção
		Return .f.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Validacao das Fases do Atendimento              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFaseAte := VXI001GETFASE() // "AX1PXOXLXFX" // X=Chamada do Ponto de Entrada entre as Fases

cFaseAtu := VV9->VV9_STATUS
If cFaseAtu == "R" // Reprovado
	cFaseAtu := "1" // Validar novamente Limite Credito / Minimo Comercial e passar para Pendente Aprovacao
ElseIf cFaseAtu == "F" .and. cPaisLoc == "BRA" // Finalizado
	FMX_HELP("VXI001ERR003",STR0002+" "+cNumAte) // O atendimento ja esta faturado. / Atencao
	return .f.
EndIf
nPos := At(VV9->VV9_STATUS,cFaseAte)
if nPos < 1
	nPos := 1
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o atendimento nao estiver com STATUS A (Aberto), avanca uma fase automaticamente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFaseAtu <> "A" .and. cFaseAtu <> "F"
	nPos ++
EndIf

// TOTAIS por Cliente/Loja //
aCliTotais := VXI010031_Totais_por_Cliente( VV9->VV9_NUMATE , .f. , .f. , )

For nCntFor := nPos to Len(cFaseAte)
	
	
	lInterrompe := .f.
	lImprimir   := .f.
	
	
	cFaseAtu := Subs(cFaseAte,nCntFor,1) // "AX1PXOXLXFX" // X=Chamada do Ponto de Entrada entre as Fases
	

	If cFaseAtu $ "A1POLF"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacoes do(s) Veiculo(s)                                                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If cPaisLoc == "ARG" // Argentina
			lVldVei := Empty(VV0->VV0_NUMNFI+VV0->VV0_REMITO) // Validar Veiculos se ainda não gerou Fatura ou Remito
		EndIf
		If lVldVei .and. !VXI001VLVEI(aVVAs)
			Return .f.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificar se o Cliente esta Bloqueado em TODAS as FASES (A1POLF) do Atendimento                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nCliTotais := 1 to len(aCliTotais)
			If !VXI001VLCLI( aCliTotais[nCliTotais,1] , aCliTotais[nCliTotais,2] )
				Return .f.
			EndIf
		Next

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Chama Ponto de Entrada ( Customizacao antes de cada fase do Atendimento )                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("VX001AFA")
			lInterrompe := ExecBlock("VX001AFA",.f.,.f.,{VV9->VV9_NUMATE,VV9->VV9_STATUS})
			If lInterrompe
				Return .f.
			EndIf
		EndIf
	
	EndIf
	
	
	
	Do Case
		
		
		
		Case cFaseAtu == "A" // ATENDIMENTO ABERTO
			If VXI001VLCEV(VV0->VV0_CODVEN)
				Begin Transaction
				VEIVM130TAR(VV9->VV9_NUMATE,"1","1",VV9->VV9_FILIAL, lXI001Auto) // Tarefas:  1-Gravacao / 1-Atendimento
				If lVV9_APRPUS .and. !Empty(VV9->VV9_APRPUS)
					VX0130021_RelacionaVQ0( VV9->VV9_NUMATE ) // Relaciona VVA com VQ0 se já fez Aprovacao Previa
				EndIf
				End Transaction
			Else
				Return .f.
			EndIf
			If cPaisLoc == "ARG" // Argentina
			 	If Empty(VV0->VV0_TPFATR) // Ainda não gerou Fatura e Remito
					If ! lXI001Auto
						nTpFatura := Aviso(STR0055,STR0056,{STR0060,STR0058,STR0059},2) // Atendimento de Veículos/Máquinas / Deseja gerar? / Fatura Entrega Futura / Remito / Cancela
						If nTpFatura == 0 .or. nTpFatura == 3 // Cancelou
							Return .f.
						EndIf
						cTpFatR := strzero(nTpFatura,1) // Tipo: 1=Fatura (default) / 2=Remito
						//
						If ExistBlock("VXX02TEA") // Ponto de Entrada para manipular o TES Argentina
							aRet := ExecBlock("VXX02TEA", .f., .f., { cTpFatR , VV0->VV0_FILIAL , VV0->VV0_NUMTRA })
							M->VV0_CODTES := aRet[1]
							lTelaTES      := aRet[2]
							aRet := {}
						EndIf
						If lTelaTES
							If cTpFatR == "1" // Fatura
								AADD(aParamBox,{1,STR0066,M->VV0_CODTES,"@!","VX0020101_Valida_TES_ARG('1',MV_PAR01,.t.)","SF4",".T.",50,.T.}) // TES Fatura
							Else // Remito
								AADD(aParamBox,{1,STR0063,M->VV0_CODTES,"@!","VX0020101_Valida_TES_ARG('2',MV_PAR01,.t.)","SF4",".T.",50,.T.}) // TES Remito
							EndIf
							If ParamBox(aParamBox,STR0038,@aRet,,,,,,,,.f.) // Atendimento
								M->VV0_CODTES := aRet[1] // TES
							Else
								Return .f.
							EndIf
						Else
							If !VX0020101_Valida_TES_ARG(cTpFatR,M->VV0_CODTES,.t.)
								Return .f.
							EndIf
						EndIf
						For nPosVVA := 1 to len(aVVAs)
							aVVAs[nPosVVA,4] := M->VVA_CODTES := M->VV0_CODTES // TES
							DbSelectArea("VVA")
							DbGoTo(aVVAs[nPosVVA,3])
							RecLock("VVA",.f.)
								VVA->VVA_CODTES := M->VVA_CODTES
							MsUnLock()
							VX002ACOLS("VVA_CODTES",nPosVVA)
						Next
					EndIf
				EndIf
				VX0020091_GravaCampoVV0(VV9->VV9_NUMATE,{{"VV0_TPFATR",cTpFatR}})
			EndIf



		Case cFaseAtu == "1" // Checar Limite de Credito do Cliente
			If "V" $ GetMv("MV_CHKCRE") // Veiculos
				For nCliTotais := 1 to len(aCliTotais)
					If !FGX_AVALCRED( aCliTotais[nCliTotais,1] , aCliTotais[nCliTotais,2] , aCliTotais[nCliTotais,3] , .t. )
						Help("  ",1,"LIMITECRED")
						Return .f.
					EndIf
				Next
			EndIf
			
			
			
		Case cFaseAtu == "P" // ATENDIMENTO PENDENTE APROVACAO
			If VX002DTTIT(VV9->VV9_NUMATE) // PENDENTE APROVACAO - Sempre validar as Datas dos Titulos
				Begin Transaction
				VEIVM130TAR(VV9->VV9_NUMATE,"4","1",VV9->VV9_FILIAL, lXI001Auto) // Tarefas: 4-Pendente Aprovacao / 1-Atendimento
				// Reserva do Veiculo na Fase 2-Pendente Aprovacao
				For nPosVVA := 1 to len(aVVAs)
					If !Empty(aVVAs[nPosVVA,1]) // Possui VVA_CHAINT
						VEIXX004(nOpc,VV9->VV9_NUMATE,aVVAs[nPosVVA,1],"2") 
					EndIf
				Next
				//
				VXI010021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , cFaseAtu ) // Altera automaticamente a Fase do Interesse
				VXI001ATU(VV9->VV9_NUMATE,cFaseAtu) // Atualiza Status
				End Transaction
				//
				VXI010011_EMAIL(1,"",aVVAs) // Gerar EMAIL no 1-Pendente Aprovação
				//
			Else
				Return .f.
			EndIf
			
			
			
		Case cFaseAtu == "O" // ATENDIMENTO PRE-APROVADO
			If VX002DTTIT(VV9->VV9_NUMATE) // PRE-APROVADO - Sempre validar as Datas dos Titulos
				nRet := VEIXX013(VV9->VV9_NUMATE,1,lXI001Auto) // Pre-Aprovacao
				If nRet > 0
					Begin Transaction
					If nRet == 1 // Pre-Aprovou
						VEIVM130TAR(VV9->VV9_NUMATE,"5","1",VV9->VV9_FILIAL, lXI001Auto) // Tarefas: 5-Pre-Aprovado / 1-Atendimento
						// Reserva do Veiculo na Fase 3-Pre-Aprovado
						For nPosVVA := 1 to len(aVVAs)
							If !Empty(aVVAs[nPosVVA,1]) // Possui VVA_CHAINT
								VEIXX004(nOpc,VV9->VV9_NUMATE,aVVAs[nPosVVA,1],"3") 
							EndIf
						Next
						// 
						If cTitAten == "1" // Geracao de Titulos na 1=Pre-Aprovacao
							If !VEIXI002(VV9->VV9_NUMATE,.f.,.f.,.t.,"",.f.,cFaseAtu, lXI001Auto) // Geracao de Pedido (.F.) , NF (.F.) e Titulos (.T.)
								lInterrompe := .t.
							EndIf
							If !lInterrompe .and. !lXI001Auto
								VX002ATTELA(VV9->VV9_NUMATE)
							EndIf
						EndIf
						If !lInterrompe
							VXI010021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , cFaseAtu ) // Altera automaticamente a Fase do Interesse
							VXI001ATU(VV9->VV9_NUMATE,cFaseAtu) // Atualiza Status
						EndIf
					Else // Reprovou a Pre-Aprovacao
						VXI010021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , "R" ) // Altera automaticamente a Fase do Interesse
						VXI001ATU(VV9->VV9_NUMATE,"R") // Atualiza Status
						lInterrompe := .t.
					EndIf
					End Transaction

				Else // Cancelou a Pre-Aprovacao
					If lXI001Auto
						FMX_HELP("VXI001ERR015", STR0048) // "Atendimento pendente de Pré-Aprovação."
					EndIf
					Return .f.
				EndIf
			Else // Datas dos Titulos com Divergencias
				Return .f.
			EndIf
			
			

		Case cFaseAtu == "L" // ATENDIMENTO APROVADO
			If cTitAten == "1" .or. VX002DTTIT(VV9->VV9_NUMATE) // Se ja Gerou Titulos na 1=Pre-Aprovacao (ja foi validado)  ou  Valida as Datas dos Titulos para gera-los posteriormente
				If !VEIVM130TAR(VV9->VV9_NUMATE,"0A","1",VV9->VV9_FILIAL, lXI001Auto) // 0A-Verifica/Valida na Aprovacao / 1-Atendimento
					Return .f.
				EndIf

				// Janela de Aprovacao //
				nRet :=  VEIXX013(VV9->VV9_NUMATE,2,lXI001Auto) 
				If nRet > 0
					Begin Transaction

					// Aprovou //
					If nRet == 1
						VEIVM130TAR(VV9->VV9_NUMATE,"6","1",VV9->VV9_FILIAL, lXI001Auto) // Tarefas: 6-Aprovado / 1-Atendimento
						// Reserva do Veiculo na Fase 4-Aprovado
						For nPosVVA := 1 to len(aVVAs)
							If !Empty(aVVAs[nPosVVA,1]) // Possui VVA_CHAINT
								VEIXX004(nOpc,VV9->VV9_NUMATE,aVVAs[nPosVVA,1],"4") 
							EndIf
						Next
						// 
						If VX002ORC(VV9->VV9_NUMATE) // Gerar Orcamento na Acao de Vendas
							If cTitAten == "2" .or. ( lIntLoja .and. Empty(VV0->VV0_PESQLJ) ) // Geracao de Titulos na 2=Aprovacao ou Integrado com o Loja
								If !VEIXI002(VV9->VV9_NUMATE,.f.,.f.,.t.,"",.f.,cFaseAtu, lXI001Auto) // Geracao de Pedido (.F.) , NF (.F.) e Titulos (.T.)
									lInterrompe := .t.
								EndIf
								If !lInterrompe .and. !lXI001Auto
									VX002ATTELA(VV9->VV9_NUMATE)
								EndIf
							EndIf
						Else // Cancelou a Aprovacao
							lInterrompe := .t.
						EndIf
						If !lInterrompe
							VXI010021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , cFaseAtu ) // Altera automaticamente a Fase do Interesse
							VXI001ATU(VV9->VV9_NUMATE,cFaseAtu) // Atualiza Status
						EndIf
					Else // Reprovou a Aprovacao
						VXI010021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , "R" ) // Altera automaticamente a Fase do Interesse
						VXI001ATU(VV9->VV9_NUMATE,"R") // Atualiza Status
						lInterrompe := .t.
					EndIf

					End Transaction

				// Cancelou a Aprovacao // 
				Else 
					If lXI001Auto
						FMX_HELP("VXI001ERR016", STR0049) // "Atendimento pendente de Aprovação."
					EndIf
					Return .f.
				EndIf
			Else // Datas dos Titulos com Divergencias
				Return .f.
			EndIf
			
			
			
		Case cFaseAtu == "F" // ATENDIMENTO FINALIZADO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integrado com o Loja - Verifica venda finalizada  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIntLoja .and. !Empty(VV0->VV0_PESQLJ)
				SL1->(DbSetOrder(1))
				If SL1->(DbSeek( xFilial("SL1") + VV0->VV0_PESQLJ ))
					If Empty(SL1->L1_DOCPED+SL1->L1_SERPED)
						FMX_HELP("VXI001ERR011",STR0024) // Para faturar este Atendimento, favor Finalizar o Orcamento de Venda Direta! / Atencao
						Return .t. // Retornar .t. para Fechar a Tela do Atendimento automaticamente
					EndIf
				EndIf
			EndIf

			For nPosVVA := 1 to len(aVVAs)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe VVA_CHAINT                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(aVVAs[nPosVVA,1]) // Nao Possui VVA_CHAINT
					FMX_HELP("VXI001ERR004", STR0006) // Impossivel faturar Atendimento sem chassi! / Atencao
					Return .f.
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verificar se o Veiculo esta Consignado ou Remessa ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cMsg := ""
				VV1->(DbSetOrder(1))
				VV1->(DbSeek(xFilial("VV1")+aVVAs[nPosVVA,1]))
				If VV1->VV1_SITVEI == "3" // Remessa
					cMsg := STR0007 // Veiculo em Remessa!
				ElseIf VV1->VV1_SITVEI == "4" // Consignado
					cMsg := STR0008 // Veiculo Consignado!
				EndIf
				If !Empty(cMsg)
					FMX_HELP("VXI001ERR014",STR0004 + CRLF + cMsg) // Impossivel continuar
					Return .f.
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Validacao do Veiculo                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lVldVei .and. !VEIXX012(2,,aVVAs[nPosVVA,1],aVVAs[nPosVVA,4],VV9->VV9_NUMATE) // Validar Veiculo
					Return .f.
				EndIf

				If oVeiculos:DtUltimaMovimentacao(aVVAs[nPosVVA,2]) > dDataBase // Valida referente a DataBase
					FMX_HELP("VXI001ERR020",STR0046 + CRLF + CRLF + aVVAs[nPosVVA,2] ) // Chassi com movimentacao posterior a data atual.
					Return .f.
				EndIf

				VV1->(DbSetOrder(1)) // Garantir que nesse ponto o Veiculo esteja posicionado corretamente
				VV1->(DbSeek(xFilial("VV1")+aVVAs[nPosVVA,1]))

				for nPosVV1 := 1 to nVV1FCount
					if X3Obrigat( VV1->(fieldName(nPosVV1)) ) .and. empty( VV1->(fieldGet(nPosVV1)) )
						FMX_HELP("VXI001ERR023",Alltrim(RetTitle("VV1_CHAINT")) + "-"+Alltrim(RetTitle("VV1_CHASSI")) + ": " +;
									AllTrim(VV1->VV1_CHAINT) +"-"+AllTrim(VV1->VV1_CHASSI) + CRLF + CRLF +;
									STR0067 + CRLF + CRLF + VV1->(fieldName(nPosVV1)) ) // Campo obrigatório não preenchido
						return .F.
					endif
				next

			Next

			If cTitAten == "0" // É para gerar Titulos na Finalizacao do Atendimento
				If !VX002DTTIT(VV9->VV9_NUMATE) // Valida as Datas dos Titulos
					Return .f.
				EndIf
			EndIf
			If ! FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_EMINFI","==","1")
				If lXI001Auto
					FMX_HELP("VXI001ERR017", STR0050, STR0051) // "Usuário não tem permissão para emitir nota fiscal de veículo.","Verifique a permissão no cadastro de equipe técnica.")
				Endif
				Return .f.
			EndIf
			If ! lXI001Auto 
				cMsgPerg := STR0010 // Deseja Faturar o Veiculo?
				If cPaisLoc == "ARG" // Argentina
					If !Empty(VV0->VV0_NUMNFI) .and. Empty(VV0->VV0_REMITO) // Gerou apenas Fatura, falta Remito
						cTpFatR := "2" // 2=Remito
					ElseIf Empty(VV0->VV0_NUMNFI) .and. !Empty(VV0->VV0_REMITO) // Gerou apenas Remito, falta Fatura
						cTpFatR := "3" // 3=Fatura pelo Remito
					EndIf
					If cTpFatR == "2" // 2=Remito
						cMsgPerg := STR0065 // Deseja gerar o Remito de Entrega?
					EndIf
				EndIf
				If ! MsgYesNo(cMsgPerg,STR0003) // Atencao
					Return .f.
				EndIf
			EndIf
			If ExistBlock("VEIXIANF")
				If !ExecBlock("VEIXIANF",.f.,.f.,{aVVAs, cNumAte})
					Return .f.
				EndIf
			EndIf
			If cTpFatR $ "1/3" // 1=Fatura / 3=Fatura com Remito
				If !VEIVM130TAR(VV9->VV9_NUMATE,"0F","1",VV9->VV9_FILIAL, lXI001Auto) // 0F-Verifica/Valida na Finalizacao / 1-Atendimento
					Return .f.
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Declarar variavel 'cNumero' qdo existir o PE 'M460NUM'. Variavel necessaria no 'MATA461' ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("M460NUM",.F.,.F.)
				cNumero := ""
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se for Faturar, exibir janela para escolher SERIE ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lXI001Auto .and. ! Empty(cParSerieNF)
				cSerie := cParSerieNF
			Else
				lRet := .t.
				if cPaisLoc == "BRA"
					lRet := SX5NumNota(@cSerie, GetNewPar("MV_TPNRNFS","1"))
				elseIf cPaisLoc == "ARG"
					cLocxNFPV := ""
					If FindFunction("OA5300051_Retorna_Ponto_de_Venda")
						If cTpFatR == "2" // Remito
							cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_REM_ATENDVEI") // Remito
						Else // Faturas
							cLocxNFPV := OA5300051_Retorna_Ponto_de_Venda("PV_FAT_ATENDVEI") // Fatura
						EndIf
					EndIf
					If Empty(cLocxNFPV)
						If Pergunte("PVXARG",.T.) .and. !Empty(MV_PAR01)
							cLocxNFPV := MV_PAR01
						Else
							lRet := .f.
						EndIf
					EndIf
					If !Empty(cLocxNFPV)
						cPV410    := cLocxNFPV // Variavel Private utilizada no a468nFatura
						lLocxAuto  := .F.
						cIdPVArg := cIdPV := POSICIONE("CFH",1, xFilial("CFH")+cLocxNFPV,"CFH_IDPV")
						lRet := F083ExtSFP(cLocxNFPV, .T.)
					Endif
				endif
				If !lRet
					Return .f.
				EndIf
			EndIf

			aTelaInf := {}
			Begin Transaction

			If cPaisLoc == "ARG"
				VX0020091_GravaCampoVV0(VV9->VV9_NUMATE,{{"VV0_TPFATR",cTpFatR}})
			EndIf

			If cTpFatR $ "1/3" // 1=Fatura / 3=Fatura com Remito

				//////////////////////////////////////////////////////////
				// Gravar MEMO do Historico de Alteracao do Atendimento //
				//////////////////////////////////////////////////////////
				DbSelectArea("VV0")
				cObsAnt := MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1]) // neste caso eh necessario o MSMM, pois o E_MSMM nao estava retornado o MEMO
				If !Empty(cObsAnt)
					cObsAnt += Chr(13)+Chr(10)
				EndIf
				cObsAnt += Repl("_",TamSx3("VV0_OBSERV")[1])+Chr(13)+Chr(10)+"***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)
				cObsAnt += STR0028 // Atendimento FINALIZADO!
				MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsAnt,1,,,"VV0","VV0_OBSMEM")
				//////////////////////////////////////////////////////////

				VX002CEV("F",VV9->VV9_NUMATE) // Geracao do CEV ( Pos-Venda )
				VEIVM130TAR(VV9->VV9_NUMATE,"2","1",VV9->VV9_FILIAL, lXI001Auto) // Tarefas: 2-Finalizacao / 1-Atendimento

				For nPosVVA := 1 to len(aVVAs)

					VEIXX016(nOpc,"3",VV9->VV9_NUMATE,aVVAs[nPosVVA,1]) // Prioridade de Venda -> Reserva Temporaria (3=Finalizacao do Atendimento)
					VX002VC3("F",VV9->VV9_NUMATE,aVVAs[nPosVVA,2]) // Inserir VC3 - Frota do Cliente

				Next

			EndIf

			// NF Geracao 
			// Se existir o campo de controle de geracao do Financeiro, sera chamado separado apos Finalizar a Transacao da NF e
			// Não é condição Padrão (ou seja, é condição Tipo A)
			If lVV0_GERFIN .and. !lCPagPad
			
				If !VEIXI002(VV9->VV9_NUMATE,.t.,.t.,.f.,cSerie,.f.,cFaseAtu, lXI001Auto, , cTpFatR) // Geracao de Pedido (.T.) , NF (.T.) e Titulos (.F.)
					DisarmTransaction()
					lErro := .T.
					break
				EndIf
				VV0->(DbSetOrder(1))
				If VV0->(MsSeek(xFilial("VV0")+VV9->VV9_NUMATE)) .and. cTpFatR $ "1/3" // 1=Fatura / 3=Fatura com Remito
					Reclock("VV0",.f.)
					VV0->VV0_GERFIN := "0" // Gerou Financeiro (Titulos)? ( 1=Sim / 0=Nao, deu problema na geracao )
					MsUnLock()
				EndIf

			Else // Se nao existr o campo de controle de geracao do Financeiro, sera chamado junto com a Transacao da NF (como era anteriormente)
			
				If !VEIXI002(VV9->VV9_NUMATE,.t.,.t.,.t.,cSerie,.f.,cFaseAtu, lXI001Auto, , cTpFatR) // Geracao de Pedido (.T.) , NF (.T.) e Titulos (.T.)
					DisarmTransaction()
					lErro := .T.
					break
				EndIf
				If lVV0_GERFIN // Se existir o campo de controle de geracao do Financeiro, sera chamado separado apos Finalizar a Transacao da NF e
					VV0->(DbSetOrder(1))
					If VV0->(MsSeek(xFilial("VV0")+VV9->VV9_NUMATE))
						Reclock("VV0",.f.)
						VV0->VV0_GERFIN := "1" // Gerou Financeiro (Titulos)? ( 1=Sim / 0=Nao, deu problema na geracao )
						MsUnLock()
					EndIf
				EndIf
			
			EndIf

			lImprimir := .t.

			If cTpFatR $ "1/3" // 1=Fatura / 3=Fatura com Remito
				VXI010021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , cFaseAtu ) // Altera automaticamente a Fase do Interesse
				VXI001ATU(VV9->VV9_NUMATE,cFaseAtu) // Atualiza Status
			EndIf

			End Transaction

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX6")
			MsRUnLock()

			if lErro
				return .F.
			endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Levantar os Bonus automaticamente para todos os Veiculos do Atendimento  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cMVMIL0162 $ "1/2" .and. lVVA_CODPED .and. cTpFatR $ "1/3" // Levanta Bonus automaticamente com o Codigo do Pedido Fabrica ( 1=Lev.apagando existentes / 2=Lev.NAO apagando existentes ) e 1=Fatura ou 3=Fatura com Remito
				For nPosVVA := 1 to len(aVVAs)
					DbSelectArea("VVA")
					DbGoTo(aVVAs[nPosVVA,3])
					cQuery := "SELECT VQ0.R_E_C_N_O_ "
					cQuery += " FROM " + cNamVQ0 +" VQ0 "
					cQuery += " WHERE VQ0.VQ0_FILATE = '" + VVA->VVA_FILIAL+ "' "
					cQuery += 	" AND VQ0.VQ0_NUMATE = '" + VVA->VVA_NUMTRA+ "' "
					cQuery += 	" AND VQ0.VQ0_CHAINT = '" + VVA->VVA_CHAINT+ "' "
					cQuery += 	" AND VQ0.D_E_L_E_T_=' '"
					nRecVQ0 := FM_SQL(cQuery)
					If nRecVQ0 > 0 // Necessário existir o PEDIDO do Veiculo
						//
						DbSelectArea("VQ0")
						DbGoTo(nRecVQ0)
						VA1630015_LevantaBonus( cMVMIL0162 ) // Levanta Bonus do Pedido
						//
						VV0->(DbSetOrder(1))
						VV0->(DbSeek(VVA->VVA_FILIAL+VVA->VVA_NUMTRA))
						VV2->(DbSetOrder(1))
						VV2->(DbSeek(xFilial("VV2")+VVA->VVA_CODMAR+VVA->VVA_MODVEI+IIf(lVVA_SEGMOD,VVA->VVA_SEGMOD,"")))
						VEIXX014(VVA->VVA_NUMTRA,VVA->VVA_CODMAR,VV2->VV2_GRUMOD,VVA->VVA_MODVEI,4,  .f.,  VV0->VV0_TIPFAT,VVA->(RecNo()), /* lSoSelect */, Iif(lMultMoeda, M->VV0_MOEDA, nil))
						//
					EndIf
				Next
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Ultima Movimentacao e Proprietario Atual do Veiculo             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nPosVVA := 1 to len(aVVAs)
				FGX_AMOVVEI(xFilial("VV1"),aVVAs[nPosVVA,2],"VEIXA018 - VEIXI001()")
			Next

			// 
			If Len(aTelaInf) > 0
				FMX_TELAINF( "1" , { { Alltrim(aTelaInf[1]) , Alltrim(aTelaInf[2]) , aTelaInf[3] } } )
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada apos a geracao da NF           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("VM011DNF")
				ExecBlock("VM011DNF",.f.,.f.)
			EndIf

			// Somente criar outra Transacao para os Titulos se existir o campo de controle de geracao do Financeiro
			If cTpFatR $ "1/3" .and. lVV0_GERFIN .and. !lCPagPad // 1=Fatura / 3=Fatura com Remito

				Begin Transaction

				lOkTit := .t.
				If !VEIXI002(VV9->VV9_NUMATE,.f.,.f.,.t.,cSerie,.f.,cFaseAtu, lXI001Auto, , cTpFatR) // Geracao de Pedido (.F.) , NF (.F.) e Titulos (.T.)
					DisarmTransaction()
					lOkTit := .f.
				EndIf
				If cTpFatR $ "1/3" // 1=Fatura / 3=Fatura com Remito
					DbSelectArea("VV0")
					RecLock("VV0",.f.)
						VV0->VV0_GERFIN := IIf(lOkTit,"1","0") // Gerou Financeiro (Titulos)? ( 1=Sim / 0=Nao, deu problema na geracao )
					MsUnLock()
				EndIf
				If !lOkTit
					MsgAlert(STR0025,STR0003) // O Atendimento foi Finalizado gerando NF, porem existe(m) inconsistencia(s) na Geração dos Titulos. Favor corrigir a(s) pendencia(s) e solicitar novamente a Geração dos Titulos. / Atencao
				Else
					// Exclui os LOGS gerados no momento do faturamento 
					cQuery := "DELETE FROM "+ RetSqlName("VQL")
					cQuery += " WHERE VQL_FILIAL = '"+xFilial("VQL")+"' "
					cQuery += "   AND VQL_AGROUP = 'VEIXI002' "
					cQuery += "   AND VQL_FILORI = '" + VV0->VV0_FILIAL + "' "
					cQuery += "   AND VQL_TIPO = 'VV0-" + VV0->VV0_NUMTRA + "'"
					cQuery += "   AND D_E_L_E_T_ = ' '"
					TcSqlExec(cQuery)
				EndIf

				End Transaction

			EndIf

			If cTpFatR $ "1/3" // 1=Fatura / 3=Fatura com Remito

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada apos a geracao de Titulos      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("VXI02TIT")
					ExecBlock("VXI02TIT",.f.,.f.)
				EndIf

				//
				VXI010011_EMAIL(5,"",aVVAs) // Gerar EMAIL no 5-Atendimento Finalizado
				//

			EndIf
		OtherWise
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chama Ponto de Entrada ( Customizacao X apos cada fase do Atendimento )  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lVX001DFA
				lInterrompe := ExecBlock("VX001DFA",.f.,.f.,{VV9->VV9_NUMATE,VV9->VV9_STATUS})
			EndIf
			
			If lInterExecAuto
				// Na existencia do PE VX001DFA, retorna a execucao do ponto de entrada, 
				// do contrario, retorna TRUE pois a execucao foi interrompida atraves do parametro cFaseInter
				// e nao por causa de um problema de execucao 
				Return IIf( lVX001DFA , lInterrompe , .t.)
			EndIf


	EndCase

	If cFaseAtu == cFaseInter
		lInterExecAuto := .t.
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sair do Laco das Fases do Atendimento      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lInterrompe
		Return .f.
	EndIf
	
	If lImprimir // IMPRIMIR
		If substr(GetMv("MV_LOJAVEI",,"NNN"),3,1) <> "S" .or. cPaisLoc <> "BRA"
			If !VV0->VV0_OPEMOV $ "234" // Venda/Remessa/Transferencia/Devolucao
				If ExistBlock("NFSAIVEI")
					ExecBlock("NFSAIVEI",.f.,.f.,{SF2->F2_DOC,SF2->F2_SERIE})
					dbSelectArea("SA6")
					dbSetOrder(1)
					If dbSeek(xFilial("SA6")+VV0->VV0_CODBCO)
						If ExistBlock("BLQCOB")
							ExecBlock("BLQCOB",.f.,.f.,{SF2->F2_DOC,,,,SF2->F2_PREFIXO,"1",substr(SA6->A6_MENSAGE,1,49),substr(SA6->A6_MENSAGE,50,49),substr(SA6->A6_MENSAGE,100,50),VV0->VV0_CODBCO})
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		lImprimir := .f.
	EndIf
	
	
Next
//
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VXI001ATU º Autor ³ Andre Luis / Rubens º Data ³  30/03/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava a Fase Atual do Atendimento Modelo 2 - Novo          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXI001ATU(cNumAte,cFaseAtu)
DBSelectArea("VV9")
DBSetOrder(1)
If DBSeek(xFilial("VV9")+cNumAte)
	Reclock("VV9",.f.)
		VV9->VV9_STATUS := cFaseAtu
	MsUnLock()
	M->VV9_STATUS := cFaseAtu
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VXI001GETFASEº Autor ³ Andre Luis / Rubens º Data ³30/03/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Fases do Atendimento Modelo 2 - Novo                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXI001GETFASE()
Local cFases := "AX1PXOXLXFX"// X=Chamada do Ponto de Entrada entre as Fases
Return cFases

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VXI001CANCEL º Autor ³ Andre Luis / Rubens º Data ³30/03/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cancelamento do Atendimento Modelo 2 - Novo                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXI001CANCEL(cNumAte,nOpc,aVVAs, lXI001Auto, nOpcCancAuto, aMotCancAuto)
Local xRet          := ""
Local cMsg          := ""
Local lCancTit      := .f.
Local cOrcto        := ""
Local nOpcao        := 0
Local ni            := 0
Local cQueryAux     := ""
Local cQuery        := ""
Local cSQLAlias     := "SQLAlias"
Local cFaseAtu      := ""
Local cFasePrx      := "C" // Cancelar o Atendimento
Local cNumTit       := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1)
Local cNumNFI       := ""
Local cSerNFI       := ""
Local nTamPref      := TamSx3("E1_PREFIXO")[1]
Local cPreNFI       := Space(nTamPref)
Local cNumPed       := ""
Local aRegSD2       := {}
Local aRegSE1       := {}
Local aRegSE2       := {}
Local aParcelas     := {}
Local cPrefOri      := GetNewPar("MV_PREFVEI","VEI")
Local lCancVAI      := .t. // Permissao do VAI para cancelamento
Local nPosVVA       := 0
Local cCancVAI      := "222222" // Permissao: ( 0=Nao faz nada / 1=Volta / 2=Cancela/Volta / 3=Cancela)
Local cObsAnt       := ""
Local cObsMot       := ""
Local lTitLoja      := .f.	// Controla se o numero do titulo é do Loja 
Local cPreTit       := ""
Local lVQ1          := TCCanOpen(RetSQLName("VQ1"))
Local lVVA_CODPED   := ( VVA->(ColumnPos("VVA_CODPED")) > 0 ) // Codigo do Pedido Fabrica
Local lVQ0_ITETRA   := ( VQ0->(ColumnPos("VQ0_ITETRA")) > 0 ) // Item Atendimento
Local lVVA_VRKNUM   := ( VVA->(ColumnPos("VVA_VRKNUM")) <> 0 ) // Numero do pedido de venda da Montadora
Local nCliTotais    := 0
Local aCliTotais    := {}
Local aMata410Cab   := {}
Local aMata410Itens := {}
Local aMotCancel    := {}
Local lLimpaParc    := .f.
Local nRecSL1       := 0
Local cL1_NUM       := ""

Local lNFeCancel  := SuperGetMV('MV_CANCNFE',.F.,.F.) .AND. SF2->(ColumnPos("F2_STATUS")) > 0
Local lErro       := .F.
Local cOptVAICanc := ""
Local aCancPed    := {}
Local nCntFor     := 0

//Variáveis Remito Argentina
Local cPedRem     := "" // Remito Argentina
Local cMsgVoltar  := "" // Mensagem para voltar status do atendimento

Default lXI001Auto := .f.
Default nOpcCancAuto := 0
Default aMotCancAuto := {}

If lXI001Auto
	nOpcao := nOpcCancAuto
	aMotCancel := aMotCancAuto
EndIf

If VAI->(ColumnPos("VAI_CANVEI")) > 0

	//  Informe se o usuário tem permissão para Cancelar/Voltar o Atendimento. As opções para preenchimento são:
	//  0 = Usuário sem permissão
	//  1 = Voltar Atendimento
	//  2 = Cancelar/Voltar Atendimento
	//  3 = Cancelar Atendimento
	//  
	//  APOLRF - Cada posição é correspondente a um status do Atendimento:
	//  A = Aberto (1a.posição)
	//  P = Pendente aprovação (2a.posição)
	//  O = Pré-aprovado (3a. posição)
	//  L = Aprovado (4a.posição)
	//  R = Reprovado (5a.posição)
	//  F = Finalizado (6a.posição)
	cCancVAI := FGX_USERVL(xFilial("VAI"),__cUserID,"VAI_CANVEI","?")
EndIf

If lIntLoja .and. !Empty(VV0->VV0_PESQLJ)
	SL1->(DbSetOrder(1))
	If SL1->(DbSeek( xFilial("SL1") + VV0->VV0_PESQLJ ))
		cL1_NUM  := SL1->L1_NUM
		cNumTit  := SL1->L1_DOCPED // Numero dos Titulos ja gerados pelo Loja
		cPreTit  := SL1->L1_SERPED // Serie dos Titulos Gerados pelo Loja 
		cQuery := "SELECT R_E_C_N_O_ "
		cQuery += "  FROM "+RetSQLName("SL1")
		cQuery += " WHERE L1_FILIAL='"+xFilial("SL1")+"'"
		cQuery += "   AND L1_ORCRES='"+SL1->L1_NUM+"'"
		cQuery += "   AND D_E_L_E_T_=' '"
		nRecSL1 := FM_SQL(cQuery)
		If nRecSL1 > 0
			SL1->(DbGoto( nRecSL1 )) // Posicionar no Orcamento da Liberacao para Faturar
			cL1_NUM  := SL1->L1_NUM
		EndIf
		lTitLoja := .t. 
	EndIf
EndIf

// TOTAIS por Cliente/Loja //
aCliTotais := VXI010031_Totais_por_Cliente( VV9->VV9_NUMATE , .f. , .f. , )

For nCliTotais := 1 to len(aCliTotais)

	cNumPed := aCliTotais[nCliTotais,5]
	cNumNFI := aCliTotais[nCliTotais,6]
	cSerNFI := aCliTotais[nCliTotais,7]
	cPreNFI := Space(nTamPref)

	// Se tiver finalizado procura o prefixo do titulo para exclusao 
	If VV9->VV9_STATUS == "F" .and. !Empty(cNumNFI+cSerNFI)// ATENDIMENTO FINALIZADO
		SF2->(dbSetOrder(1))
		If SF2->(DbSeek(xFilial("SF2") + cNumNFI + cSerNFI ))
			cPreNFI := SF2->F2_PREFIXO
			aCliTotais[nCliTotais,12] := cPreNFI
		Else
			FMX_HELP("VXI001ERR021",STR0052)
		EndIf
	EndIf
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar se ja existe Titulos Baixados ou Parcialmente Baixados ou fora de carteira ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/////////
	// SE1 //
	/////////
	cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"'"
	If lTitLoja // Titulo gerado pelo Loja 
		cQuery += " AND ( ( SE1.E1_NUM='"+cNumTit+"' AND SE1.E1_PREFIXO = '" + cPreTit + "' ) "
	Else
		cQuery += " AND ( SE1.E1_NUM='"+cNumTit+"' "
	EndIf
	If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
		cQuery += "OR ( SE1.E1_NUM='"+cNumNFI+"' AND SE1.E1_PREFIXO = '" + cPreNFI + "' )"
	EndIf
	cQuery += " ) AND SE1.E1_PREFORI='"+cPrefOri+"' AND ( SE1.E1_BAIXA <> ' ' OR SE1.E1_SALDO <> SE1.E1_VALOR )"
	cQuery += " AND SE1.E1_FILORIG='"+xFilial("VV9")+"' AND SE1.D_E_L_E_T_=' '"
	If FM_SQL(cQuery) > 0
		FMX_HELP("VXI001ERR005",STR0011) // Ha titulo(s) de Contas a Receber ja baixado(s) referente(s) a este Atendimento! / Atencao
		Return .f.
	EndIf
	//Titulos fora de carteira
	cQuery := "SELECT SE1.R_E_C_N_O_ AS RECSE1 FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"'"
	If lTitLoja // Titulo gerado pelo Loja 
		cQuery += " AND ( ( SE1.E1_NUM='"+cNumTit+"' AND SE1.E1_PREFIXO = '" + cPreTit + "' ) "
	Else
		cQuery += " AND ( SE1.E1_NUM='"+cNumTit+"' "
	EndIf
	If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
		cQuery += "OR ( SE1.E1_NUM='"+cNumNFI+"' AND SE1.E1_PREFIXO = '" + cPreNFI + "' )"
	EndIf
	cQuery += " ) AND SE1.E1_PREFORI='"+cPrefOri+"' AND SE1.E1_SITUACA <> '0'"
	cQuery += " AND SE1.E1_FILORIG='"+xFilial("VV9")+"' AND SE1.D_E_L_E_T_=' '"
	If FM_SQL(cQuery) > 0
		FMX_HELP("VXI001ERR022",STR0053)
		Return .f.
	EndIf
	/////////
	// SE2 //
	/////////
	cQuery := "SELECT SE2.R_E_C_N_O_ AS RECSE2 FROM "+RetSQLName("SE2")+" SE2 WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"' "
	If lTitLoja // Titulo gerado pelo Loja 
		cQuery += " AND ( ( SE2.E2_NUM='"+cNumTit+"' AND SE2.E2_PREFIXO = '" + cPreTit + "' ) "
	Else
		cQuery += " AND ( SE2.E2_NUM='"+cNumTit+"' "
	EndIf
	If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
		cQuery += "OR ( SE2.E2_NUM='"+cNumNFI+"' AND SE2.E2_PREFIXO = '" + cPreNFI + "' )"
	EndIf
	cQuery += " ) AND SE2.E2_TIPO IN ('TC ','RBT','NCF') AND " // ( TAC, Rebate ou NCF )
	If FGX_SA1SA2(aCliTotais[nCliTotais,1],aCliTotais[nCliTotais,2],.f.) // Cliente como Fornecedor
		cQuery += "SE2.E2_FORNECE='"+SA2->A2_COD+"' AND SE2.E2_LOJA='"+SA2->A2_LOJA+"' AND "
	EndIf
	cQuery += "( SE2.E2_BAIXA <> ' ' OR SE2.E2_SALDO <> SE2.E2_VALOR )"
	cQuery += " AND SE2.E2_FILORIG='"+xFilial("VV9")+"' AND SE2.D_E_L_E_T_=' '"
	If FM_SQL(cQuery) > 0
		FMX_HELP("VXI001ERR006",STR0012) // Ha titulo(s) de Contas a Pagar ja baixado(s) referente(s) a este Atendimento! / Atencao
		Return .f.
	EndIf

	If VV0->VV0_CFFINA == "2" .and. nCliTotais == 1 // Finame 2=Financeira/Banco e Executar apenas no Cliente principal
		cQuery := "SELECT SE2.R_E_C_N_O_ AS RECSE2 FROM "+RetSQLName("SE2")+" SE2 WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"' "
		If lTitLoja // Titulo gerado pelo Loja 
			cQuery += " AND ( ( SE2.E2_NUM='"+cNumTit+"' AND SE2.E2_PREFIXO = '" + cPreTit + "' ) "
		Else
			cQuery += " AND ( SE2.E2_NUM='"+cNumTit+"' "
		EndIf
		If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
			cQuery += "OR ( SE2.E2_NUM='"+cNumNFI+"' AND SE2.E2_PREFIXO = '" + cPreNFI + "' )"
		EndIf
		cQuery += " ) AND SE2.E2_TIPO IN ('FF ','FR ') AND " // ( Finame Flat, Finame Risco )
		If FGX_SA1SA2(VV0->VV0_CLFINA,VV0->VV0_LJFINA,.f.) // Cliente como Fornecedor
			cQuery += "SE2.E2_FORNECE='"+SA2->A2_COD+"' AND SE2.E2_LOJA='"+SA2->A2_LOJA+"' AND "
		EndIf
		cQuery += "( SE2.E2_BAIXA <> ' ' OR SE2.E2_SALDO <> SE2.E2_VALOR )"
		cQuery += " AND SE2.E2_FILORIG='"+xFilial("VV9")+"' AND SE2.D_E_L_E_T_=' '"
		If FM_SQL(cQuery) > 0
			FMX_HELP("VXI001ERR007",STR0012) // Ha titulo(s) de Contas a Pagar ja baixado(s) referente(s) a este Atendimento! / Atencao
			Return .f.
		EndIf
	EndIf

Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar se existem Orcamentos em Aberto                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT VS1.VS1_NUMORC FROM "+RetSQLName("VS1")+" VS1 WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_STATUS NOT IN ('0','C') AND VS1.VS1_NUMATE='"+VV9->VV9_NUMATE+"' AND VS1.D_E_L_E_T_=' '"
cOrcto := ""
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !(cSQLAlias)->(Eof())
	cOrcto += "'"+(cSQLAlias)->( VS1_NUMORC )+"' , "
	(cSQLAlias)->(DbSkip())
Enddo
(cSQLAlias)->(DbCloseArea())
If !Empty(cOrcto)
	FMX_HELP("VXI001ERR008",STR0013+CHR(13)+CHR(10)+CHR(13)+CHR(10)+left(cOrcto,len(cOrcto)-3)) // Existe(m) Orcamento(s) em Aberto para este Atendimento! / Atencao
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar STATUS do Atendimento e Permissao do Usuario no VAI    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg     := STR0020 // Usuario sem permissao para Cancelar/Voltar Atendimento!
cFaseAtu := VV9->VV9_STATUS
Do Case
Case cFaseAtu == "A" // Aberto
	If substr(cCancVAI,1,1) $ "2/3" // VAI - Permite Cancelar/Voltar ou Permite somente Cancelar
		nOpcao   := 2   // Cancelar
		cFasePrx := "C" // Cancelar o Atendimento
	Else
		lCancVAI := .f. // Usuario sem permissao
		If substr(cCancVAI,1,1) == "1" // VAI - Permite Voltar
			cMsg := STR0023 // Impossivel Voltar o Atendimento, pois o mesmo se encontra Aberto!
		EndIf
	EndIf
Case cFaseAtu $ "POLR" // Pendente Aprovacao / Pre-Aprovado / Aprovado / Reprovado

	Do Case
	Case cFaseAtu=="P" ; cOptVAICanc := substr(cCancVAI,2,1)
	Case cFaseAtu=="O" ; cOptVAICanc := substr(cCancVAI,3,1)
	Case cFaseAtu=="L" ; cOptVAICanc := substr(cCancVAI,4,1)
	Case cFaseAtu=="R" ; cOptVAICanc := substr(cCancVAI,5,1)
	End Case

	Do Case
	// VAI - Permite somente Cancelar
	Case cOptVAICanc == "3"
		nOpcao   := 2   // Cancelar
		cFasePrx := "C" // Cancelar o Atendimento

	// VAI - Permite Cancelar/Voltar
	Case cOptVAICanc == "2"
		If ! lXI001Auto
			cMsgVoltar := STR0015 // Voltar Atendimento para Aberto
			If cPaisLoc == "ARG" .and. !Empty(VV0->VV0_REMITO) // Remito Argentina
				cMsgVoltar := STR0016 // Voltar Atendimento para Aprovado
			EndIf
			nOpcao := Aviso(STR0014,"- "+cMsgVoltar+CHR(13)+CHR(10)+"- "+STR0017, { STR0018 , STR0019 } ) // Cancelamento do Atendimento / Cancelar Total o Atendimento / Voltar / Cancelar
		EndIf
		If nOpcao == 1 // Voltar para Aberto
			cFasePrx := "A" // Voltar o Atendimento para Aberto
			If cPaisLoc == "ARG" .and. !Empty(VV0->VV0_REMITO) // Remito Argentina
				cFasePrx := "L" // Voltar o Atendimento para Aprovado
			EndIf
		ElseIf nOpcao == 2 // Cancelar
			cFasePrx := "C" // Cancelar o Atendimento
		EndIf

	// VAI - Permite Voltar
	Case cOptVAICanc == "1"
		nOpcao   := 1   // Voltar para Aberto
		cFasePrx := "A" // Voltar o Atendimento para Aberto
		If cPaisLoc == "ARG" .and. !Empty(VV0->VV0_REMITO) // Remito Argentina
			cFasePrx := "L" // Voltar o Atendimento para Aprovado
		EndIf
	OtherWise
		lCancVAI := .f. // Usuario sem permissao
	EndCase

Case cFaseAtu == "F" // Finalizado

	cOptVAICanc := substr(cCancVAI,6,1)

	Do Case
	// VAI - Permite somente Cancelar
	Case cOptVAICanc == "3"
		nOpcao   := 2   // Cancelar
		cFasePrx := "C" // Cancelar o Atendimento

	// VAI - Permite Cancelar/Voltar
	Case cOptVAICanc == "2"

		If lIntLoja .and. !Empty(cL1_NUM)
			If ! lXI001Auto
				nOpcao := Aviso(STR0014,"- "+STR0015+CHR(13)+CHR(10)+"- "+STR0017, { STR0018 , STR0019 } ) // Cancelamento do Atendimento / Voltar Atendimento para Aberto / Cancelar Total o Atendimento / Voltar / Cancelar
			EndIf
			If nOpcao == 1 // Voltar para Aberto
				cFasePrx := "A" // Voltar o Atendimento para Aberto
			ElseIf nOpcao == 2 // Cancelar
				cFasePrx := "C" // Cancelar o Atendimento
			EndIf
		Else
			If ! lXI001Auto
				nOpcao := Aviso(STR0014,"- "+STR0016+CHR(13)+CHR(10)+"- "+STR0017, { STR0018 , STR0019 } ) // Cancelamento do Atendimento / Voltar Atendimento para Aprovado / Cancelar Total o Atendimento / Voltar / Cancelar
			EndIf
			If nOpcao == 1 // Voltar para Aprovado
				cFasePrx := "L" // Voltar o Atendimento para Aprovado
			ElseIf nOpcao == 2 // Cancelar
				cFasePrx := "C" // Cancelar o Atendimento
			EndIf
		EndIf

	// VAI - Permite Voltar
	Case cOptVAICanc == "1"
		nOpcao   := 1   // Voltar para Aprovado
		If lIntLoja .and. !Empty(cL1_NUM)
			cFasePrx := "A" // Voltar o Atendimento para Aberto
		Else
			cFasePrx := "L" // Voltar o Atendimento para Aprovado
		EndIf

	// Usuario sem permissao
	OtherWise
		lCancVAI := .f. 
	EndCase
EndCase

If !lCancVAI
	FMX_HELP("VXI001ERR009", cMsg) // Atencao
	Return .f.
EndIf
If ( cFasePrx == "C" .or. cFasePrx == "A" ) 
	If lVQ1 // Comissoes de Bonus
		cQuery := "SELECT VQ0.R_E_C_N_O_ FROM "+RetSQLName("VQ0")+" VQ0 "
		cQuery += "INNER JOIN "+RetSQLName("VQ1")+" VQ1 ON ( VQ1.VQ1_FILIAL=VQ0.VQ0_FILIAL AND VQ1.VQ1_CODIGO=VQ0.VQ0_CODIGO AND VQ1.VQ1_STATUS='3' AND VQ1.D_E_L_E_T_=' ' ) "
		cQuery += "WHERE VQ0.VQ0_FILATE='"+VV9->VV9_FILIAL+"' AND VQ0.VQ0_NUMATE='"+VV9->VV9_NUMATE+"' AND VQ0.D_E_L_E_T_=' '"
		If FM_SQL(cQuery) > 0
	    	If !MsgNoYes(STR0031,STR0003) // Existe(m) NF(s) gerada(s) referente(s) a comissão(ões) de Bonus. Deseja continuar com o Cancelamento do Atendimento?
	    		Return .f.
			EndIf
		EndIf	
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Perguntar se deseja realmente CANCELAR Atendimento               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFasePrx == "C"
	If ! lXI001Auto
		nOpcao := 0
		If MsgYesNo(STR0021,STR0003) // Deseja realmente CANCELAR o Atendimento? / Atencao
			nOpcao := 1
		EndIf
	Else
		nOpcao := 1
	EndIf
EndIf

cPedRem := If(cPaisLoc == "ARG", VV0->VV0_PEDREM, "") // Remito Argentina

If nOpcao > 0

	If cFasePrx == "C" // Cancelar
		If ExistBlock("VLDEXC011")
			If !ExecBlock("VLDEXC011",.f.,.f.)
				Return .f.
			EndIf
		EndIf
		
		If lXI001Auto .and. Len(aMotCancAuto) > 0
			aMotCancel := aClone(aMotCancAuto)
		Else
			//³ Motivo do Cancelamento do Atendimento                         ³
			aMotCancel := OFA210MOT("000001","1",VV9->VV9_FILIAL,VV9->VV9_NUMATE,.t.) // Filtro da consulta do motivo de Cancelamentos ( 000001 = Atendimento de Veiculos )
			If len(aMotCancel) <= 0
				Return .f.
			EndIf
		EndIf
	EndIf

	If lNFeCancel .and. cFaseAtu == "F"
	
	  For nCliTotais := 1 to len(aCliTotais)
		
		cNumNFI := aCliTotais[nCliTotais,6]
		cSerNFI := aCliTotais[nCliTotais,7]

		cNFCliente := aCliTotais[nCliTotais,1]
		cNFLoja    := aCliTotais[nCliTotais,2]
		If VV0->VV0_CATVEN == "7" .and. ! Empty(VV0->VV0_CLIALI+VV0->VV0_LOJALI)
			cNFCliente := VV0->VV0_CLIALI
			cNFLoja    := VV0->VV0_LOJALI
		EndIf

		// Transmite o Cancelamento para o SEFAZ automaticamente	
		If !Empty(cNumNFI+cSerNFI) .and. !FGX_STATF2("D",cSerNFI,cNumNFI,cNFCliente,cNFLoja,"S") // verifica se NF foi Deletada

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cancelar NF                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF2")
			DbSetOrder(1)
			If DbSeek(xFilial("SF2") + cNumNFI + cSerNFI )
				If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2) // Verifica se o estorno do documento de saida pode ser feito
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estorna o documento de saida                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PERGUNTE("MTA521",.f.)
					If lIntLoja .and. !Empty(cL1_NUM)
						////////////////////////////////////////////////
						// Mudar para Modulo 5 - Faturamento          //
						////////////////////////////////////////////////
						nModulo := 5 
					EndIf
					If !SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
						Return .f.
					Endif
					If lIntLoja .and. !Empty(cL1_NUM)
						////////////////////////////////////////////////
						// Voltar Modulo 11 - Veiculos                //
						////////////////////////////////////////////////
						nModulo := 11
					EndIf
				Else
					// NF nao pode ser excluida //
					Return .f.
				EndIf
			EndIf
			
			If !FGX_STATF2("V",cSerNFI,cNumNFI,cNFCliente,cNFLoja,"S") /// Verifica STATUS da NF no SEFAZ
				Return .f.
			EndIf

		EndIf
	
	  Next

	EndIf
	//

	If cFaseAtu == "F" .and. !lNFeCancel .and. cPaisLoc == "ARG" // ATENDIMENTO FINALIZADO
		For nCliTotais := 1 to len(aCliTotais)
			cNumNFI := aCliTotais[nCliTotais,6]
			cSerNFI := aCliTotais[nCliTotais,7]
			If !Empty(cNumNFI+cSerNFI)
				SF2->(dbSetOrder(1))
				If SF2->(DbSeek(xFilial("SF2") + cNumNFI + cSerNFI ))
					If !VX0010058_CancNFArg(SF2->F2_DOC, SF2->F2_SERIE, "1") // 1=Nota Normal / 2=Nota do Remito
						lMsErroAuto:= .T.
						MostraErro()
						lErro := .T.
						Exit
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	// Exclui nota fiscal do remito
	If !lErro
		If cPaisLoc == "ARG" .and. !Empty(VV0->VV0_REMITO) // Remito Argentina
			If !VX0010058_CancNFArg(VV0->VV0_REMITO, VV0->VV0_SERREM, "2") // 1=Nota Normal / 2=Nota do Remito
				lMsErroAuto:= .T.
				MostraErro()
				lErro := .T.
			Endif
			If !lErro
				// Limpa os campos do remito
				DbSelectArea("VV0")
				RecLock("VV0",.f.)
				VV0->VV0_REMITO := ""
				VV0->VV0_SERREM := ""
				VV0->VV0_TPFATR := ""
				MsUnlock()
			EndIf
		EndIf
	EndIf

	
	If !lErro

		Begin Transaction

		If ExistBlock("VXI01ACA")
			If !ExecBlock("VXI01ACA",.f.,.f.,{VV9->VV9_NUMATE,cFasePrx})
				DisarmTransaction()
				lErro := .T.
				break
			EndIf
		EndIf

		If cFasePrx == "A" .or. cFasePrx == "C" // Voltar o Atendimento para Aberto ou Cancelar o Atendimento
			DbSelectArea("VV0")
			RecLock("VV0",.f.)
			VV0->VV0_NUMTIT := ""
			MsUnlock()
		EndIf

		For nPosVVA := 1 to len(aVVAs)

			If cFasePrx == "C"
				VX006GRV(nOpc,VV9->VV9_NUMATE,ctod(""),ctod(""),ctod(""),"",aVVAs[nPosVVA,3],0,"","","") // Limpar campos de Entrega e Memo (Observacao)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Limpar Data de Liberado para Faturemento e Entrega do VVA ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("VVA")
			DbGoTo(aVVAs[nPosVVA,3])
			RecLock("VVA",.f.)
				VVA->VVA_DTLIBF := ctod("")
				VVA->VVA_DTLIBE := ctod("")

			If cFasePrx == "C" .and. lVVA_VRKNUM
				VVA->VVA_VRKNUM := " "
				VVA->VVA_VRKITE := " "
			EndIf

			MsUnLock()

			// if cFasePrx == "C" .and. ! empty( VVA->VVA_RESERV )		// cancelamento da venda e tem Reserva
			// 	VEIXX004(0,VVA->VVA_NUMTRA,VVA->VVA_CHAINT,"0")
			// endif
			If cFasePrx == "A" .or. cFasePrx == "C" // Voltar o Atendimento para Aberto ou Cancelar o Atendimento

				If lVVA_CODPED .and. cFasePrx == "C"  // Codigo do Pedido Fabrica
					If !Empty(VVA->VVA_CODPED)
						DbSelectArea("VQ0")
						DbSetOrder(1)
						If DbSeek(xFilial("VQ0")+VVA->VVA_CODPED) // Limpar campos: Filial e Nro Atendimento
							RecLock("VQ0",.f.)
								VQ0->VQ0_FILATE := ""
								VQ0->VQ0_NUMATE := ""						
								If lVQ0_ITETRA
									VQ0->VQ0_ITETRA := ""
								EndIf
							MsUnLock()
							RecLock("VVA",.f.)							
								VVA->VVA_CODPED := ""							
							MsUnLock()					
						EndIf
						DbSelectArea("VVA")					
					EndIf
				EndIf

				If !Empty(aVVAs[nPosVVA,1])

					VEIXX004(nOpc,VV9->VV9_NUMATE,aVVAs[nPosVVA,1],"0") // Reserva ( Cancela Reserva do Veiculo )

					If cFasePrx == "C" // Cancelar o Atendimento

						VEIXX016(nOpc,"2",VV9->VV9_NUMATE,aVVAs[nPosVVA,1]) // Prioridade de Venda -> Reserva Temporaria (2=Cancelamento do Atendimento)

					EndIf

				EndIf

			EndIf

		Next

		If cFasePrx == "A" .or. cFasePrx == "C" // Voltar o Atendimento para Aberto ou Cancelar o Atendimento

			If !Empty(VV9->VV9_NUMATE) // SEGURANCA - verifica se existe o nro do atendimento para nao C-cancelar todos Orcamentos sem Atendimento
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cancelar Orcamentos 0=Digitados       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := "SELECT VS1.R_E_C_N_O_ AS VS1RECNO FROM "+RetSQLName("VS1")+" VS1 WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+"' AND VS1.VS1_STATUS='0' AND VS1.VS1_NUMATE='"+VV9->VV9_NUMATE+"' AND VS1.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
				While !(cSQLAlias)->(Eof())
					DbSelectArea("VS1")
					DbGoTo((cSQLAlias)->( VS1RECNO ))
					RecLock("VS1",.f.)
						VS1->VS1_STATUS := "C"
					MsUnLock()
					If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
						OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0014 ) // Grava Data/Hora na Mudança de Status do Orçamento / Cancelamento do Atendimento
					EndIf
					If FindFunction("FM_GerLog")
						//grava log das alteracoes das fases do orcamento
						FM_GerLog("F",VS1->VS1_NUMORC)
					EndIf
					(cSQLAlias)->(DbSkip())
				EndDo
				(cSQLAlias)->(DbCloseArea())
			EndIf

			If cFasePrx == "C" // Cancelar o Atendimento

				VX008ATUAL("0T",VV9->VV9_NUMATE,VV9->VV9_FILIAL) // Avaliacoes de Veiculos Usados ( 0-Cancela Total o VAZ )

				VEIVM130TAR(VV9->VV9_NUMATE,"9","1",VV9->VV9_FILIAL, lXI001Auto) // Tarefas: 9-Cancela Atendimento / 1-Atendimento

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Levantar o Motivo do Cancelamento do Atendimento              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cObsMot := STR0022+" "+aMotCancel[2] // Atendimento CANCELADO! Motivo:
				For ni := 1 to len(aMotCancel[4])
					If !Empty(aMotCancel[4,ni,1])
						cObsMot += CHR(13)+CHR(10)+" - "+Alltrim(aMotCancel[4,ni,1])+": "+Transform(aMotCancel[4,ni,2],aMotCancel[4,ni,6])
					EndIf
				Next

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravar VV9                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("VV9")
				RecLock("VV9",.f.)
					VV9->VV9_MOTIVO := aMotCancel[1]
					VV9->VV9_DATCAN := dDataBase
				MsUnLock()
				cObsAnt := E_MSMM(VV9->VV9_OBSMEM,TamSx3("VV9_OBSERV")[1])
				If !Empty(cObsAnt)
					cObsAnt += Chr(13)+Chr(10)
				EndIf
				cObsAnt += Replicate("-",TamSx3("VV9_OBSERV")[1])+CHR(13)+CHR(10)
				cObsAnt += cObsMot
				MSMM(VV9->VV9_OBSMEM,TamSx3("VV9_OBSERV")[1],,cObsAnt,1,,,"VV9","VV9_OBSMEM") // Observacao

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravar VV0                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("VV0")
				RecLock("VV0",.f.)
					VV0->VV0_SITNFI := "0" // Cancelada
					VV0->VV0_DATAPR := cTod("")
					VV0->VV0_USRAPR := ""
					VV0->VV0_STATUS := "C" // Cancelado
				MsUnlock()
				cObsAnt := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])
				If !Empty(cObsAnt)
					cObsAnt += Chr(13)+Chr(10)
				EndIf
				cObsAnt += Repl("_",TamSx3("VV0_OBSERV")[1])+Chr(13)+Chr(10)+"***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)
				cObsAnt += cObsMot
				MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsAnt,1,,,"VV0","VV0_OBSMEM")

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravar CEV no Cancelamento do Atendimento                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aMotCancel[3] // Motivo do Cancelamento GERA CEV ?
					VX002CEV("CT",VV9->VV9_NUMATE) // Geracao do CEV ( CT - Cancelamento Total do Atendimento )
				EndIf

				// ####################################################### //
				// Limpa relacionamento com o Peiddo de Venda de Montadora //
				// ####################################################### //
				VXI001VRJLIMPAR(VV9->VV9_NUMATE, aVVAs)
				//
				VA1100423_DesvinculaAtendimento(VV9->VV9_FILIAL, VV9->VV9_NUMATE, VVA->VVA_ITETRA)
				//
			EndIf

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VV9->(dbGoTo(VV9->(Recno())))

		VEIVM130DEL(VV9->VV9_NUMATE,cFasePrx,VV9->VV9_FILIAL) // "Deleta" Tarefas que deverao ser executadas novamente.

		If cFasePrx == "A" .or. cFasePrx == "L" // Voltar Atendimento para Aberto ou para Aprovado

			//////////////////////////////////////////////////////////
			// Gravar MEMO do Historico de Alteracao do Atendimento //
			//////////////////////////////////////////////////////////
			DbSelectArea("VV0")
			cObsAnt := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])
			If !Empty(cObsAnt)
				cObsAnt += Chr(13)+Chr(10)
			EndIf
			cObsAnt += Repl("_",TamSx3("VV0_OBSERV")[1])+Chr(13)+Chr(10)+"***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)
			If cFasePrx == "A" // Atendimento Aberto
				cObsAnt += STR0026 // Voltou o Atendimento para ABERTO!
			ElseIf cFasePrx == "L" // Atendimento Aprovado
				cObsAnt += STR0027 // Voltou o Atendimento para APROVADO!
			EndIf
			MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsAnt,1,,,"VV0","VV0_OBSMEM")
			//////////////////////////////////////////////////////////

			VX002CEV("CP",VV9->VV9_NUMATE) // Geracao do CEV ( CP - Cancelamento Parcial do Atendimento )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar VV0                                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("VV0")
			RecLock("VV0",.f.)
				VV0->VV0_NUMNFI := ""
				VV0->VV0_SERNFI := ""
				VV0->VV0_NUMPED := ""
				VV0->VV0_NNFFDI := ""
				VV0->VV0_SNFFDI := ""
				If cPaisLoc == "ARG" // Remito Argentina
					VV0->VV0_PEDREM := ""
					If cFasePrx == "A" // Voltar o Atendimento para Aberto
						VV0->VV0_TPFATR := ""
					EndIf
				EndIf
				If cFasePrx == "A" // Voltar o Atendimento para Aberto
					VV0->VV0_DATAPR := cTod("")
					VV0->VV0_USRAPR := ""
					VV0->VV0_STATUS := "I" // Inicializado
					VV0->VV0_NUMTIT := ""
				Else
					VV0->VV0_STATUS := "L" // Liberado
					If cTitAten == "0" // Gera Titulo na Finalizacao
						VV0->VV0_NUMTIT := ""
					EndIf
				EndIf
			MsUnlock()

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VV9->(dbGoTo(VV9->(Recno())))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VV0->(dbGoTo(VV0->(Recno())))

		If cFaseAtu == "F" .or. (cPaisLoc == "ARG" .and. !Empty(cPedRem)) // ATENDIMENTO FINALIZADO ou Remito Argentina

			If !Empty(aCliTotais[1,6]+aCliTotais[1,7]) .or. (cPaisLoc == "ARG" .and. !Empty(cPedRem)) // Tem Nota Fiscal ou Remito Argentina

				cNumNFI := aCliTotais[1,6] // NF
				cSerNFI := aCliTotais[1,7] // Serie

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cancelar COMISSAO do Vendedor/Superior referente a NF ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lNFeCancel .and. cPaisLoc == "BRA"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Cancelar NF                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SF2")
					DbSetOrder(1)
					If DbSeek(xFilial("SF2") + cNumNFI + cSerNFI )
						If MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2) // Verifica se o estorno do documento de saida pode ser feito
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Estorna o documento de saida                                   ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							PERGUNTE("MTA521",.f.)
							If lIntLoja .and. !Empty(cL1_NUM)
								////////////////////////////////////////////////
								// Mudar para Modulo 5 - Faturamento          //
								////////////////////////////////////////////////
								nModulo := 5 
							EndIf
							SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
							If lIntLoja .and. !Empty(cL1_NUM)
								////////////////////////////////////////////////
								// Voltar Modulo 11 - Veiculos                //
								////////////////////////////////////////////////
								nModulo := 11
							EndIf
						Else
							// NF nao pode ser excluida //
							DisarmTransaction()
							lErro := .T.
							break
						EndIf
					EndIf
				EndIf

				aCancPed := {}
				If !Empty(cNumPed) // Pedido da Fatura
					aAdd(aCancPed,cNumPed)
				EndIf
				If cPaisLoc == "ARG" // Argentina - trazer todos os registros de Pedidos
					If !Empty(cPedRem) // Pedido do Remito
						aAdd(aCancPed,cPedRem)
					EndIf
	  				For nCliTotais := 1 to len(aCliTotais)
						If !Empty(aCliTotais[nCliTotais,5]) // Pedidos das Faturas dos Co-titulares
							aAdd(aCancPed,aCliTotais[nCliTotais,5])
						EndIf
					Next
				EndIf

				SC5->(dbGoTop())
				SC6->(dbGoTop())
				SC9->(dbGoTop())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cancelar PEDIDO                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lMsErroAuto := .f.
				For nCntFor := 1 to len(aCancPed)
					If !lMsErroAuto
						cNumPed := aCancPed[nCntFor]
						DbSelectArea("SC5")
						DbSetOrder(1)
						If DbSeek(xFilial("SC5")+cNumPed)
							aMata410Cab   := {{"C5_NUM"      , cNumPed,Nil}}   //Numero do pedido SC5
							aMata410Itens := {{"C6_NUM"      , cNumPed,Nil}}   //Numero do Pedido SC6
							//Exclui Pedido
							SC9->(dbSetOrder(1))
							SC9->(dbSeek(xFilial("SC9")+cNumPed))
							While !SC9->(Eof()) .And. xFilial("SC9") == SC9->C9_FILIAL .and. cNumPed == SC9->C9_PEDIDO
								SC9->(a460Estorna())
								SC9->(dbSkip())
							EndDo
							MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5)
						EndIf
					EndIf
				Next

				If lMsErroAuto

					MostraErro()
					DisarmTransaction()
					lErro := .T.
					break
				Else

					For nPosVVA := 1 to len(aVVAs)

						If !Empty(aVVAs[nPosVVA,1]) // Possui VVA_CHAINT

							FM_LOCVZL(1,aVVAs[nPosVVA,1]) // Credita VZL_QTDATU

						EndIf

					Next

					// Exclui os LOGS gerados no momento do faturamento 
					cQuery := "DELETE FROM "+ RetSqlName("VQL")
					cQuery += " WHERE VQL_FILIAL = '"+xFilial("VQL")+"' "
					cQuery += "   AND VQL_AGROUP = 'VEIXI002' "
					cQuery += "   AND VQL_FILORI = '" + VV0->VV0_FILIAL + "' "
					cQuery += "   AND VQL_TIPO = 'VV0-" + VV0->VV0_NUMTRA + "'"
					cQuery += "   AND D_E_L_E_T_ = ' '"
					TcSqlExec(cQuery)
					//

				EndIf

			EndIf

		EndIf

		If cFasePrx == "A" .or. cFasePrx == "C" // Voltar o Atendimento para Aberto ou Cancelar o Atendimento

			If lIntLoja .and. !Empty(cL1_NUM)

				// So exclui orcamento do loja quando o atendimento nao estiver faturado 
				// senao o orcamento deve ser excluido pela rotina que exclui a NF (MaDelNFS)
				If cFaseAtu != "F"
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Qdo Integrado com o LOJA, cancelar Pedido de Venda SL1/L2/L4 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					////////////////////////////////////////////////
					// Mudar para Modulo 5 - Faturamento          //
					////////////////////////////////////////////////
					nModulo := 5 
		            //
					xRet := LJ140Exc( "SL1" , Nil , Nil , Nil , .t. , xFilial("SL1") , cL1_NUM )
		            //
					////////////////////////////////////////////////
					// Voltar Modulo 11 - Veiculos                //
					////////////////////////////////////////////////
					nModulo := 11

					If ValType(xRet) <> "N" .or. xRet <> 1 // Erro na Funcao LJ140Exc
						FMX_HELP("VXI001ERR012",STR0030) // Erro na exclusao do orcamento no Loja / Atencao
						DisarmTransaction()
						lErro := .T.
						break
					EndIf
				EndIf

				DbSelectArea("VV0")
				RecLock("VV0",.f.)
					VV0->VV0_PESQLJ := "" // Pedido de Venda do Loja
				MsUnlock()

				If nRecSL1 > 0
					//
					SL1->(DbGoto( nRecSL1 )) // Posicionar no Orcamento da Liberacao para Faturar e excluir os registros
					//
					DbSelectArea("SL2")
					DbSetOrder(1) // NUM
					DBSeek(xFilial("SL2")+SL1->L1_NUM)
					Do While !Eof() .and. xFilial("SL2") == SL2->L2_FILIAL .and. SL2->L2_NUM == SL1->L1_NUM
						RecLock("SL2",.f.,.t.)
						DbDelete()
						MsUnlock()
						DbSelectArea("SL2")
						DbSkip()
					EndDo
					//
					DbSelectArea("SL4")
					DbSetOrder(1) // NUM
					DBSeek(xFilial("SL4")+SL1->L1_NUM)
					Do While !Eof() .and. xFilial("SL4") == SL4->L4_FILIAL .and. SL4->L4_NUM == SL1->L1_NUM
						RecLock("SL4",.f.,.t.)
						DbDelete()
						MsUnlock()
						DbSelectArea("SL4")
						DbSkip()
					EndDo
					//
					DbSelectArea("SL1")
					RecLock("SL1",.f.,.t.)
					DbDelete()
					MsUnlock()
					//
				EndIf

			EndIf

		EndIf

		If cFasePrx == "A" .or. cFasePrx == "C" .or. ( cFasePrx == "L" .and. cTitAten == "0" ) // Voltar o Atendimento para Aberto ou Cancelar o Atendimento ou ( Voltar Atendimento para Aprovado e Gera Titulo na Finalizacao )

			For nCliTotais := 1 to len(aCliTotais)

				cNumNFI := aCliTotais[nCliTotais,6]
				cSerNFI := aCliTotais[nCliTotais,7]
				cPreNFI := Space(nTamPref)

				If !Empty(cNumNFI+cSerNFI)
					SF2->(dbSetOrder(1))
					If SF2->(DbSeek(xFilial("SF2") + cNumNFI + cSerNFI ))
						cPreNFI := SF2->F2_PREFIXO
					else
						cPreNFI := aCliTotais[nCliTotais,12]
					EndIf
				EndIf
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cancelar TITULOS -> CONTAS A RECEBER ( SE1 )                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aParcelas := {}
				cQuery := "SELECT SE1.E1_PREFIXO , SE1.E1_NUM , SE1.E1_PARCELA , SE1.E1_TIPO "
				cQuery +=  " FROM " + RetSQLName("SE1") + " SE1 "
				cQuery += " WHERE SE1.E1_FILIAL='" + xFilial("SE1") + "'"
				If lTitLoja // Titulo gerado pelo Loja 
					cQuery += " AND ( ( SE1.E1_NUM='"+cNumTit+"' AND SE1.E1_PREFIXO = '" + cPreTit + "' ) "
				Else
					cQuery += " AND ( SE1.E1_NUM='"+cNumTit+"' "
				EndIf
				If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
					cQuery += "OR ( SE1.E1_NUM='"+cNumNFI+"' AND SE1.E1_PREFIXO = '" + cPreNFI + "' )"
				EndIf
				cQuery += " ) AND SE1.E1_PREFORI='"+cPrefOri+"'"
				cQuery += " AND SE1.E1_FILORIG='"+xFilial("VV9")+"' AND SE1.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
				While !(cSQLAlias)->(Eof())
					If (cSQLAlias)->(E1_TIPO) $ MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT // Nao leva para a exclusao os Titulo de Abatimento de Impostos
						(cSQLAlias)->(DbSkip())
						Loop
					EndIf
					aAdd(aParcelas,{{"E1_PREFIXO" , (cSQLAlias)->( E1_PREFIXO ) ,nil},;
									{"E1_NUM"     , (cSQLAlias)->( E1_NUM )     ,nil},;
									{"E1_PARCELA" , (cSQLAlias)->( E1_PARCELA ) ,nil},;
									{"E1_TIPO"    , (cSQLAlias)->( E1_TIPO )    ,nil},;
									{"E1_ORIGEM"  , "MATA460"                    ,nil}})
					(cSQLAlias)->(DbSkip())
				Enddo
				(cSQLAlias)->(DbCloseArea())
				DbSelectArea("SE1")
				Pergunte("FIN040",.F.)
				For ni := 1 to len(aParcelas)
					lCancTit := .t.
					lMsErroAuto := .f.
					MSExecAuto({|x,y| FINA040(x,y)},aParcelas[ni],5)
					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
						lErro := .T.
						break
					EndIf
				Next

				If nCliTotais == len(aCliTotais) // Somente no ultimo Cliente - limpar o VS9
					//////////////////////////////////////////////////////
					// Se CANCELAR titulo do SE1, limpar PARCELA no VS9 //
					//////////////////////////////////////////////////////
					cQuery := "SELECT VS9.R_E_C_N_O_  AS VS9RECNO , VS9.VS9_TIPPAG FROM "+RetSQLName("VS9")+" VS9 WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND ( VS9.VS9_NUMIDE='"+VV9->VV9_NUMATE+"' OR VS9.VS9_NUMIDE='CFD"+VV9->VV9_NUMATE+"' ) AND VS9.VS9_TIPOPE='V' AND VS9.VS9_PARCEL<>' ' AND VS9.D_E_L_E_T_=' '"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
					While !(cSQLAlias)->(Eof())
						DbSelectArea("VS9")
						DbGoTo((cSQLAlias)->( VS9RECNO ))
						lLimpaParc :=.f.
						If Alltrim((cSQLAlias)->(VS9_TIPPAG)) == "NF"
							lLimpaParc :=.t.
						Else
							If lCancTit .or. lCPagPad
								lLimpaParc :=.t.
							Endif
						EndIf
						If lLimpaParc
							RecLock("VS9",.f.)
							VS9->VS9_PARCEL := " "
							MsUnLock()
						Endif
						(cSQLAlias)->(DbSkip())
					Enddo
					(cSQLAlias)->(DbCloseArea())
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Cancelar TITULOS -> CONTAS A PAGAR ( SE2 )                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aParcelas := {}
				cQuery := "SELECT SE2.E2_PREFIXO , SE2.E2_NUM , SE2.E2_PARCELA , SE2.E2_TIPO FROM " + RetSQLName("SE2") + " SE2 WHERE E2_FILIAL='" + xFilial("SE2") + "' "
				If lTitLoja // Titulo gerado pelo Loja 
					cQuery += " AND ( ( SE2.E2_NUM='"+cNumTit+"' AND SE2.E2_PREFIXO = '" + cPreTit + "' ) "
				Else
					cQuery += " AND ( SE2.E2_NUM='"+cNumTit+"' "
				EndIf
				If !Empty(cNumNFI) // Titulos gerados com o Nro da Nota Fiscal
					cQuery += "OR ( SE2.E2_NUM='"+cNumNFI+"' AND SE2.E2_PREFIXO = '" + cPreNFI + "' )"
				EndIf
				cQuery += " ) AND ( ( SE2.E2_FORNECE='______' AND SE2.E2_LOJA='__' ) "
				If FGX_SA1SA2(aCliTotais[nCliTotais,1],aCliTotais[nCliTotais,2],.f.) // Cliente como Fornecedor
					cQuery += " OR ( SE2.E2_FORNECE='"+SA2->A2_COD+"' AND SE2.E2_LOJA='"+SA2->A2_LOJA+"' ) "
				EndIf
				If VV0->VV0_CFFINA == "2" // Finame 2=Financeira/Banco
					If FGX_SA1SA2(VV0->VV0_CLFINA,VV0->VV0_LJFINA,.f.) // Cliente como Fornecedor
						cQuery += " OR ( SE2.E2_FORNECE='"+SA2->A2_COD+"' AND SE2.E2_LOJA='"+SA2->A2_LOJA+"' ) "
					EndIf
				EndIf
				// Levantar todos os Clientes/Lojas de 1=Financiamento como Fornecedor
				cQueryAux := "SELECT VSA.VSA_CODCLI , VSA.VSA_LOJA FROM "+RetSQLName("VSA")+" VSA "
				cQueryAux += "JOIN "+RetSQLName("VS9")+" VS9 ON ( VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+PadR(VV9->VV9_NUMATE,TamSX3("VS9_NUMIDE")[1]," ")+"' AND VS9.VS9_TIPOPE='V' AND VS9.VS9_TIPPAG=VSA.VSA_TIPPAG AND VS9.D_E_L_E_T_=' ' ) "
				cQueryAux += "WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='1' AND VSA.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryAux ), cSQLAlias , .F. , .T. )
				While !(cSQLAlias)->( Eof() )
					If FGX_SA1SA2((cSQLAlias)->( VSA_CODCLI ),(cSQLAlias)->( VSA_LOJA ),.f.)
						cQuery += " OR ( SE2.E2_FORNECE='"+SA2->A2_COD+"' AND SE2.E2_LOJA='"+SA2->A2_LOJA+"' ) "
					EndIf
					(cSQLAlias)->(DbSkip())
				EndDo
				(cSQLAlias)->(DbCloseArea())
				cQuery += " ) AND SE2.E2_FILORIG='"+xFilial("VV9")+"' AND SE2.D_E_L_E_T_=' '"
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
				While !(cSQLAlias)->(Eof())
					aAdd(aParcelas,{{"E2_PREFIXO" , (cSQLAlias)->( E2_PREFIXO ) ,nil},;
									{"E2_NUM"     , (cSQLAlias)->( E2_NUM )     ,nil},;
									{"E2_PARCELA" , (cSQLAlias)->( E2_PARCELA ) ,nil},;
									{"E2_TIPO"    , (cSQLAlias)->( E2_TIPO )    ,nil}})
					(cSQLAlias)->(DbSkip())
				Enddo
				(cSQLAlias)->(DbCloseArea())
				DbSelectArea("SE2")
				Pergunte("FIN050",.F.)
				For ni := 1 to len(aParcelas)
					lMsErroAuto := .f.
					MSExecAuto({|x,y,z| FINA050(x,y,z)},aParcelas[ni],,5)
					If lMsErroAuto
						MostraErro()
						DisarmTransaction()
						lErro := .T.
						break
					EndIf
				Next

				If len(aCliTotais) > 1 // Tem VARIOS clientes
					aCliTotais[nCliTotais,5] := "" // Pedido
					aCliTotais[nCliTotais,6] := "" // NF
					aCliTotais[nCliTotais,7] := "" // Serie
					VA3500051_Gravacao_Totais_por_Clientes( aCliTotais , nCliTotais ) // Limpa na gravação da tabela de Percentuais por Cliente
				EndIf

			Next

		EndIf

		VXI010021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , cFasePrx ) // Altera automaticamente a Fase do Interesse
		VXI001ATU(VV9->VV9_NUMATE,cFasePrx) // Atualiza Status

		If VV9->(FieldPos("VV9_ENVCFT")) > 0
			VA380004D_AtualizaFlag({VV9->(RecNo())}, "0")
		Endif

		For nPosVVA := 1 to len(aVVAs)

			If !Empty(aVVAs[nPosVVA,2])

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza Ultima Movimentacao e Proprietario Atual do Veiculo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FGX_AMOVVEI(xFilial("VV1"),aVVAs[nPosVVA,2],"VEIXA018 - VXI001CANCEL")

				DbSelectArea("VV1")
				DbSetOrder(1)
				If DbSeek(xFilial("VV1")+aVVAs[nPosVVA,1])
					If VV0->VV0_TIPFAT <> "1" .or. (VV1->VV1_DATVEN == VV1->VV1_DTUVEN) // Novo ou Dt.1a.Venda eh igual a Dt.Ult.Venda
						DbSelectArea("VO5")
						DbSetOrder(1)
						If DbSeek(xFilial("VO5")+VV1->VV1_CHAINT)
							RecLock("VO5",.f.)
							VO5->VO5_DATVEN := ctod("")
							MsUnlock()
						EndIf
					EndIf
					MsUnlock()
				EndIf

			EndIf
			
		Next

		If ExistBlock("VXI01DCA")
			If !ExecBlock("VXI01DCA",.f.,.f.,{VV9->VV9_NUMATE,cFasePrx})
				DisarmTransaction()
				lErro := .T.
				break
			EndIf
		EndIf
	
	End Transaction

	EndIf

	If cFasePrx == "C" // Proxima Fase "C" - Cancelar
		//
		VXI010011_EMAIL(6,cObsMot,aVVAs) // Gerar EMAIL no 6-Atendimento Cancelado
		//
	EndIf

EndIf

Return ! lErro

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VXI001VLVEIº Autor ³ Andre Luis Almeida º Data ³  25/06/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacoes do(s) Veiculo(s)                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXI001VLVEI(aVVAs)
	Local lRet     := .t.
	Local nPosVVA  := 0
	For nPosVVA := 1 to len(aVVAs)
		If !Empty(aVVAs[nPosVVA,1]) // Possui VVA_CHAINT
			lRet := VXI00101_ValidaVeiculo(aVVAs[nPosVVA,1])
			If !lRet
				Exit
			EndIf
		EndIf
	Next
Return lRet

/*/{Protheus.doc} VXI00101_ValidaVeiculo
	Validacao do Veiculo individualmente
	
	@author Rubens
	@since 06/12/2019
/*/
Function VXI00101_ValidaVeiculo(cChaInt)

	Local lRet     := .t.
	Local aQUltMov := {}
	Local nj       := 0
	Local cMsg     := ""

	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1") + cChaInt ))

	If VV1->VV1_SITVEI == "1" // Veiculo Vendido
		lRet := .f. // Desconsiderar Veiculo ja Vendido
	ElseIf VV1->VV1_SITVEI == "3" // Remessa
		aQUltMov := FGX_VEIMOVS( VV1->VV1_CHASSI , , )
		For nj := 1 to len(aQUltMov)
			If aQUltMov[nj,1] == "E" // Entrada
				Exit
			ElseIf aQUltMov[nj,1] == "S" // Saida por Remessa
				If len(aQUltMov) >= ( nj+1 )
					If aQUltMov[nj+1,1] == "S" .and. aQUltMov[nj+1,5] == "0" // Saida por Venda
						lRet := .f. // Desconsiderar Veiculo ja Vendido e esta em Remessa
						Exit
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	If !lRet
		FMX_HELP("VXI001ERR010",STR0004+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0005+" "+ VV1->VV1_CHASSI ) // Impossivel continuar! / Veiculo ja Vendido. / Atencao
	EndIf

	If lRet
		lRet := VX016VALID( VV9->VV9_NUMATE , cChaInt , .f. ) // Prioridade de Venda - RESERVA TEMPORARIA
	EndIf

	If lRet
		lRet := VXX120011_ValidaReservado( VV9->VV9_NUMATE , , @cMsg ) // Valida se esta RERVADO - Reserva com Regras
		If !lRet
			FMX_HELP("VXI001ERR018",cMsg)
		EndIf
	EndIf

	If lRet
		lRet := VXX120021_ValidaStatusAtendimentos( VV9->VV9_NUMATE , VV1->VV1_CHASSI , VV1->VV1_CHAINT , @cMsg ) // Valida Status dos demais Atendimentos do mesmo Veiculo
		If !lRet
			FMX_HELP("VXI001ERR019",cMsg)
		EndIf
	EndIf

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VXI001VLCLIº Autor ³ Andre Luis Almeida º Data ³  26/11/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida se o Cliente esta Bloqueado                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXI001VLCLI(cCliCodigo, cCliLoja)
	Local lRet := .t.
	
	Default cCliCodigo := VV9->VV9_CODCLI
	Default cCliLoja   := VV9->VV9_LOJA

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + cCliCodigo + cCliLoja))
	If SA1->A1_MSBLQL == "1"
		Help("",1,"REGBLOQ",,"SA1" + chr(13) + chr(10) + AllTrim(RetTitle("A1_COD")) + ": " + SA1->A1_COD + "-" + SA1->A1_LOJA + " - " + SA1->A1_NOME,3,0)
		lRet := .f.
	EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VXI001VLCEVº Autor ³ Andre Luis Almeida º Data ³  13/08/14  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validar se o Vendedor fez as abordagens no CEV             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Avancar o Atendimento somente se o vendedor ja fez a qtde minima de   º±±
±±º abordagens ou se o % de abordagens eh maior que o estabelecido no VAI º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXI001VLCEV(_cCodVen)
Local lRet      := .t.
Local cQuery    := ""
Local cSQLAlias := "SQLAlias"
Local nDIAAVA   := 0
Local nPERAVA   := 0
Local nQTDAVA   := 0
Local nTotAge   := 0
Local nTotAbo   := 0
If VAI->(ColumnPos("VAI_DIAAVA")) > 0
	cQuery := "SELECT VAI_DIAAVA , VAI_PERAVA , VAI_QTDAVA FROM "+RetSQLName("VAI")+" WHERE VAI_FILIAL='"+xFilial("VAI")+"' AND VAI_CODVEN='"+_cCodVen+"' AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
	If !(cSQLAlias)->(Eof())
		nDIAAVA := (cSQLAlias)->( VAI_DIAAVA ) // dias a retroagir no CEV para saber a qtde de agendas
		nPERAVA := (cSQLAlias)->( VAI_PERAVA ) // % minimo de abordagens CEV
		nQTDAVA := (cSQLAlias)->( VAI_QTDAVA ) // qtde minima de abordagens CEV
	EndIf
	(cSQLAlias)->(DbCloseArea())
	If ( nDIAAVA + nPERAVA + nQTDAVA ) > 0
		nTotAge := FM_SQL("SELECT COUNT(*) FROM "+RetSQLName("VC1")+" WHERE VC1_FILIAL='"+xFilial("VC1")+"' AND VC1_CODVEN='"+_cCodVen+"' AND VC1_DATAGE>='"+dtos(dDataBase-nDIAAVA)+"' AND D_E_L_E_T_=' '")
		nTotAbo := FM_SQL("SELECT COUNT(*) FROM "+RetSQLName("VC1")+" WHERE VC1_FILIAL='"+xFilial("VC1")+"' AND VC1_CODVEN='"+_cCodVen+"' AND VC1_DATAGE>='"+dtos(dDataBase-nDIAAVA)+"' AND VC1_DATVIS<>' ' AND D_E_L_E_T_=' '")
		// Avancar o Atendimento somente se o vendedor ja fez a qtde minima de abordagens ou se o % de abordagens eh maior que o estabelecido no VAI
		If ( nTotAbo >= nQTDAVA ) .or. ( Round( ( ( nTotAbo / nTotAge ) * 100 ) , 2 ) >= nPERAVA )
			lRet := .t.
		Else
			FMX_HELP("VXI001ERR013",STR0033) // Impossivel continuar! O vendedor informado nao atingiu o limite minimo de abordagens no CEV. / Atencao
			lRet := .f.
		EndIf
	EndIf
	DbSelectArea("VV9")
EndIf
Return lRet


/*/{Protheus.doc} VXI001VRJLIMPAR

Desvincula Pedido de venda da montadora do Atendimento Cancelado

@author Rubens
@since 15/03/2019
@version 1.0
@return boolean, Indica se o processamento foi terminado com sucesso
@param cNumAte, characters, Numero do Atendimento cancelado
@param aVVAs, array, Array com os itens do atendimento cancelado
@type function
/*/
Function VXI001VRJLIMPAR(cNumAte, aVVAs)

	Local cSQL
	Local nPosVVA

	If ! TableInDic("VRJ")
		Return .t.
	EndIf

	For nPosVVA := 1 to Len(aVVAs)

		cSQL := "SELECT R_E_C_N_O_ VRKRECNO " +;
			" FROM " + RetSQLName("VRK") + " VRK " + ;
			" WHERE VRK.VRK_FILIAL = '" + xFilial("VRK") + "'" + ;
			" AND VRK.VRK_NUMTRA = '" + cNumAte + "'" + ;
			" AND VRK.VRK_ITETRA = '" + aVVAs[nPosVVA, 5] + "'" + ;
			" AND VRK.VRK_CANCEL <> '1'" + ;
			" AND VRK.D_E_L_E_T_ = ' '"
		nRecVRK := FM_SQL(cSQL)
		If nRecVRK <> 0
			Conout("                 " + cNumAte + " - " + aVVAs[nPosVVA, 5] + " - " + AllToChar(nRecVRK) )
			VRK->(dbGoTo(nRecVRK))
			RecLock("VRK", .f. , .t. )
			VRK->VRK_NUMTRA := " "
			VRK->VRK_ITETRA := " "
			VRK->(MsUnLock())
		EndIf

	Next nPosVVA

Return .t.
/*/{Protheus.doc} VXI010011_EMAIL
	Gerar EMAIL no momento do 1-Pendente Aprovação / 5-Finaliza Atendimento / 6-Cancela Atendimento
	
	@author Andre Luis Almeida
	@since 18/10/2018
/*/
Static Function VXI010011_EMAIL(nTp,cTxtComp,aVVAs)
Local oEmailHlp  := DMS_EmailHelper():New()
Local cTitEmail  := ""
Local cEmails    := ""
Local cMensagem  := ""
Local nCntFor    := 0
Default nTp      := 5
Default cTxtComp := ""
Default aVVAs    := {}
If FindFunction("VA0100011_LevantaEmails")
	Do Case
		Case nTp == 1 // Pendente Aprovação 
			cTitEmail := STR0034+" ( "+STR0037+": "+VV0->VV0_FILIAL+" - "+STR0038+": "+VV0->VV0_NUMTRA+" )" // Atendimento PENDENTE APROVAÇÃO! / Filial: / Atendimento:
			cEmails   := VA0100011_LevantaEmails( "1" ) // E-mail's destinatarios ( 1 - Atendimento Pendente Aprovação )
		Case nTp == 5 // Atendimento Finalizado
			cTitEmail := STR0035+" ( "+STR0037+": "+VV0->VV0_FILIAL+" - "+STR0038+": "+VV0->VV0_NUMTRA // Atendimento FINALIZADO! / Filial: / Atendimento:
			If !Empty(VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
				cTitEmail += " - "+STR0039+": "+VV0->VV0_NUMNFI+"-"+VV0->VV0_SERNFI // NF
			EndIf
			cTitEmail += " )"
			cEmails   := VA0100011_LevantaEmails( "5" ) // E-mail's destinatarios ( 5 - Atendimento Finalizado )
		Case nTp == 6 // Atendimento Cancelado
			cTitEmail := STR0036+" ( "+STR0037+": "+VV0->VV0_FILIAL+" - "+STR0038+": "+VV0->VV0_NUMTRA // Atendimento PRE-APROVADO! / Filial: / Atendimento:
			If !Empty(VV0->VV0_NUMNFI+VV0->VV0_SERNFI)
				cTitEmail += " - "+STR0039+": "+VV0->VV0_NUMNFI+"-"+VV0->VV0_SERNFI // NF
			EndIf
			cTitEmail += " )"
			cEmails   := VA0100011_LevantaEmails( "6" ) // E-mail's destinatarios ( 6 - Atendimento Cancelado )
	EndCase
	If !Empty(cEmails) // Tem E-mail para Enviar
		cMensagem := "<font size=4 face='verdana,arial' Color=#0000cc><b>"+cTitEmail+"<br><br>"+Transform(dDataBase,"@D")+" "+left(time(),5)+" - "+UPPER(UsrRetName(__CUSERID))+"</b></font><br><br><br>"
		If !Empty(cTxtComp)
			cMensagem += "<font size=3 face='verdana,arial' Color=red>"+cTxtComp+"</font><br><br><br>"
		EndIf
		cMensagem += "<table width=100% border=1>"
		cMensagem += "<tr>"
		cMensagem += "<td width=40% align=center bgcolor=cyan><font size=2 face='verdana,arial' Color=black><b>"+STR0040+"</b></font></td>" // Chassi
		cMensagem += "<td width=40% align=center bgcolor=cyan><font size=2 face='verdana,arial' Color=black><b>"+STR0041+"</b></font></td>" // Marca
		cMensagem += "<td width=20% align=center bgcolor=cyan><font size=2 face='verdana,arial' Color=black><b>"+STR0042+"</b></font></td>" // Fab/Mod
		cMensagem += "</tr>"
		For nCntFor := 1 to len(aVVAs)
			VV1->(DbSetOrder(1))
			VV1->(DbSeek( xFilial("VV1") + aVVAs[nCntFor,1] ))
			VV2->(dbSetOrder(1))
			VV2->(dbSeek( xFilial("VV2") + VV1->VV1_CODMAR + VV1->VV1_MODVEI ))
			cMensagem += "<tr>"
			cMensagem += "<td><font size=2 face='verdana,arial' Color=#0000cc>"+VV1->VV1_CHASSI+"</font></td>"
			cMensagem += "<td><font size=2 face='verdana,arial' Color=#0000cc>"+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)+"</font></td>"
			cMensagem += "<td><font size=2 face='verdana,arial' Color=#0000cc>"+Transform(VV1->VV1_FABMOD,"@R 9999/9999")+"</font></td>"
			cMensagem += "</tr>"
		Next
		cMensagem += "</table>"
		oEmailHlp:Send({;
						{'assunto' , cTitEmail },;
						{'mensagem', cMensagem },;
						{'destino' , cEmails   } ;
					})
	EndIf
EndIf
Return

/*/{Protheus.doc} VXI010021_FaseAutomaticaInteresse()
	Altera automaticamente a Fase do Interesse relacionado ao Status do Atendimento
	
	@author Andre Luis Almeida
	@since 23/10/2018
/*/
Function VXI010021_FaseAutomaticaInteresse( cFilAte , cNumAte , cStaAte )
If FindFunction("VCM680011_FaseAutomaticaInteresse")
	VCM680011_FaseAutomaticaInteresse( cFilAte , cNumAte , cStaAte )
EndIf
Return

/*/{Protheus.doc} VXI010031_Totais_por_Cliente
	Retorna os Clientes do Atendimento com os devidos TOTAIS e percentuais
	ATENCAO: No BRASIL retorna apenas 1 cliente ( VV9_CODCLI + VV9_LOJA )
	
	@author Andre Luis Almeida
	@since 25/09/2024
/*/
Function VXI010031_Totais_por_Cliente( cNumAte , lRetVei , lRetPar , cTpFatR )
Local aCliTotais := {}
Local nCliTotais := 0
Local nTotCli    := 0
Local nSomaTotal := 0
Local n1Linha    := 0
Local cQuery     := ""
Local cSQLAlias  := "SQLAUX"
Default cNumAte  := VV9->VV9_NUMATE
Default lRetVei  := .f.
Default lRetPar  := .f.
Default cTpFatR  := "1" // Tipo: 1=Fatura (default) / 2=Remito / 3=Fatura com Remito
//
VV9->(DbSetOrder(1))
VV9->(MsSeek( xFilial("VV9") + cNumAte ))
VV0->(DbSetOrder(1))
VV0->(MsSeek( xFilial("VV0") + cNumAte ))
//
If cPaisLoc == "ARG" .and. cTpFatR <> "2" // Somente Argentina e diferente de 2=Remito
	If VV0->VV0_CATVEN <> "7" .or. Empty(VV0->VV0_CLIALI+VV0->VV0_LOJALI) // Não é Leasing ou esta SEM Cliente Alienado
		aCliTotais := VA3500041_Levanta_Cotitulares( cNumAte ) // Pode ter Cotitulares
	EndIf
EndIf
//
If len(aCliTotais) == 0 // Apenas 1 Cliente (PADRAO) 100%
	aCliTotais := VA3500041_Levanta_Cotitulares( "_______" , .t.)
EndIf
//
If lRetVei // Retorna os Veiculos com os Valores correspontendes a cada cliente - Atualizar aCliTotais[9]
	cQuery := "SELECT R_E_C_N_O_ AS RECVVA , VVA_VALMOV "
	cQuery += "  FROM " + RetSQLName("VVA")
	cQuery += " WHERE VVA_FILIAL='" + xFilial("VVA") + "'"
	cQuery += "   AND VVA_NUMTRA='"+cNumAte+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
	While !(cSQLAlias)->(Eof())
		n1Linha := 0
		nSomaTotal := 0
		For nCliTotais := 1 to len (aCliTotais)
			nTotCli := round( ( ( (cSQLAlias)->VVA_VALMOV / 100 ) * aCliTotais[nCliTotais,8] ) , 2 )
			nSomaTotal += nTotCli
			aAdd(aCliTotais[nCliTotais,9],{ (cSQLAlias)->RECVVA , nTotCli })
			If n1Linha == 0
				n1Linha := len(aCliTotais[nCliTotais,9]) // 1a.Linha do primeiro Cliente/Veiculo
			EndIf
		Next
		aCliTotais[1,9,n1Linha,2] += ( (cSQLAlias)->VVA_VALMOV - nSomaTotal ) // Se necessário - ajusta o Veiculo no primeiro Cliente/Veiculo
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VV0")
EndIf
//
If lRetPar // Retorna as Parcelas com os Valores correspontendes a cada cliente - Atualizar aCliTotais[10]
	cQuery := "SELECT R_E_C_N_O_ AS RECVS9 , VS9_VALPAG "
	cQuery += "  FROM "+RetSQLName("VS9")
	cQuery += " WHERE VS9_FILIAL='"+xFilial("VS9")+"'"
	cQuery += "   AND VS9_NUMIDE='"+cNumAte+"'"
	cQuery += "   AND VS9_TIPOPE='V'"
	cQuery += "   AND VS9_VALPAG > 0 "
	cQuery += "   AND D_E_L_E_T_=' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())
		n1Linha := 0
		nSomaTotal := 0
		For nCliTotais := 1 to len (aCliTotais)
			nTotCli := round( ( ( (cSQLAlias)->VS9_VALPAG / 100 ) * aCliTotais[nCliTotais,4] ) , 2 )
			nSomaTotal += nTotCli
			aAdd(aCliTotais[nCliTotais,10],{ (cSQLAlias)->RECVS9 , nTotCli })
			If n1Linha == 0
				n1Linha := len(aCliTotais[nCliTotais,10]) // 1a.Linha do primeiro Cliente/Veiculo
			EndIf
		Next
		aCliTotais[1,10,n1Linha,2] += ( (cSQLAlias)->VS9_VALPAG - nSomaTotal ) // Se necessário - ajusta o Veiculo no primeiro Cliente/Veiculo
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	DbSelectArea("VV0")
EndIf
//
Return aClone(aCliTotais)
