#INCLUDE "gema070.ch"
#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GMA070   ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 06.04.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de correcao monetaria.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMA070()
Local oDlg
Local oArialBold
Local nOpcx := 1
Local oRadio

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

Pergunte("GMA070",.F.) 

DEFINE MSDIALOG oDlg FROM  0,0 TO 240,370 TITLE OemToAnsi(STR0001) PIXEL // "Correcao Monetaria"
DEFINE FONT oArialBold NAME "Arial" SIZE 0, -14 BOLD

@ 15, 15 SAY STR0002 FONT oArialBold SIZE 250, 10 OF oDlg PIXEL  // "Este programa irá realizar a correção monetária do "
@ 25, 15 SAY STR0003 FONT oArialBold SIZE 250, 10 OF oDlg PIXEL  // "grupo de contratos selecionados e a partir do "

// Cria o Objeto
oRadio := TRadMenu():New (45,15,{STR0001,STR0053,STR0054},;
							,oDlg,,,,,,,,100,15,,,.T.,.T.)
// Seta Eventos
oRadio:bSetGet := {|u|Iif (PCount()==0,nOpcx,nOpcx:=u)}
oRadio:bWhen   := {|| .T. }

DEFINE SBUTTON oBtnParam FROM 100, 65 TYPE 5 ACTION pergunte("GMA070",.T.) ENABLE OF oDlg
oBtnParam:nWidth := 80

DEFINE SBUTTON FROM 100, 105 TYPE 1 ACTION ExecFunc( nOpcx,StrZero( MV_PAR01,2),StrZero( MV_PAR02,4),MV_PAR03,MV_PAR04) ENABLE OF oDlg

DEFINE SBUTTON FROM 100, 135 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Processa ³ Autor ³ Daniel Tadashi Batori ³ Data ³ 01/10/2007        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa a Correcao Monetaria ou Fechamento ou Estorno do Fechamento³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpcx     : [1]Correcao Monetaria                                   ³±±
±±³          ³             [2]Fechamento                                           ³±±
±±³          ³             [3]Estorno do Fechamento                                ³±±
±±³          ³ cMes      : mes(caracter com 2 digitos)                             ³±±
±±³          ³ cAno      : Ano(caracter com 4 digitos)                             ³±±
±±³          ³ cContrDe  : numero de contrato de                                   ³±±
±±³          ³ cContrAte :numero de contrato ate                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExecFunc( nOpcx,cMes,cAno,cContrDe,cContrAte )
Private oProcess

Do Case 
	Case nOpcx==1
		oProcess := MsNewProcess():New({|lEnd| GMProcCM(cMes,cAno,cContrDe,cContrAte) },STR0005)     // "Processando a Correcao Monetaria"
	Case nOpcx==2
		oProcess := MsNewProcess():New({|lEnd| T_GMFechaMes(cMes,cAno,cContrDe,cContrAte) },STR0004) // "Processando o Fechamento da CM"
	Case nOpcx==3
		oProcess := MsNewProcess():New({|lEnd| T_EstorFech(cMes,cAno,cContrDe,cContrAte) },STR0052)  // "Processando o Estorno do Fechamento"
EndCase

oProcess:Activate()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GMProcCM ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 06.04.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de correcao monetaria. (modelo2)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GMProcCM( cMes,cAno,cContrDe,cContrAte )
Local oDlg 
Local oSBtnOk
Local oFont
Local oMemo
Local aArea        := GetArea()
Local aContrProc   := {}
Local aNaoProc     := {}
Local aMsgError    := {}
Local aCondVend    := {}
Local aFields      := {}
Local aHeader      := {}
Local lContinua    := .F.
Local lContratos   := .T. 
Local lSuccess     := .F.
Local lNovoLIW     := 0
Local lNovoLJX     := 0
Local nQtdParcelas := 0
Local nTotQtdParc  := 0
Local nDecTaxa     := 0
Local nDecIndCM    := 0
Local nVlrAmort    := 0
Local nVlrJuros    := 0
Local nVlrSldDev   := 0
Local nCMAmort     := 0
Local nCMJuros     := 0
Local nCMSldDev    := 0
Local nAcumCMAmort := 0
Local nAcumCMJuros := 0
Local nAcumCMSaldo := 0
Local nNewCMAmort  := 0
Local nNewCMJuros  := 0
Local nNewCMSldDev := 0

Local nMesDiff     := 0
Local nCntTit      := 0
Local cTaxa        := ""
Local cUltFech     := GetMV("MV_GMULTFE")
Local cTexto       := ""
Local cMsgError    := ""
Local dIndCM       := stod("")
Local dRefIndCM    := stod("")
Local nY           := 0
Local nCount       := 0
Local aCustomCM   := {}
Local nPos_ITEM   := 0 // Item da condicao venda 
Local nPos_NUMPAR := 0 // Qtd de parcelas 
Local nPos_TIPPAR := 0 // Codigo do Tipo de Parcela
Local nPos_TAXANO := 0 // Taxa anual
Local nPos_IND    := 0 // Codigo da taxa pre-chaves
Local nPos_NMES1  := 0 // n Mes referente ao indice
Local nPos_INDPOS := 0 // Codigo da taxa pos-chaves
Local nPos_NMES2  := 0 // n Mes referente ao indice
Local nPos_DIACOR := 0 // DIA DO VENCIMENTO
Local aRetCoef   := {}
Local nAmorBase  := 0
Local nJuroBase  := 0
Local nNewVlrTit := 0
Local cAux       := ""
Local cCM_Ant    := ""
Local cFilLIT    := xFilial("LIT")
Local cFilLIW    := xFilial("LIW")
Local cFilSE1    := xFilial("SE1")
Local cFilLJX    := xFilial("LJX")

	// se naum encontrou o parametro
	If ValType(cUltFech)=="L"
	   //	Help("",1,"GMA070001")
	Else
		lContinua := .T.
	
		If Empty(cUltFech)
			cUltFech := left(dtos(GMPrevMonth(dDatabase ,1)),6)
			PutMV("MV_GMULTFE" ,cUltFech )
		EndIf
		
		If cAno == replicate("0",4) .OR. cMes == replicate("0",2)
			// mes/ano nao foi informado
			Help("",1,"GMA070002")
			lContinua := .F.
		EndIf
		
		// O Mes/ano informado para o recalculo tem q ser superior ao mes/ano do 
		// fechamento
		If LIT->(FieldPos("LIT_FECHAM"))=0 .And. ;
			(cAno+cMes <= cUltFech) .And. lContinua 
			// mes/ano é inferior ao mes/ano fechado
			HELP( "   ",1,"GMA070ERRO001",,STR0006 + cMes + "/" + cAno + STR0007 + CRLF ; //### //"O Mês/Ano: "###" informado é igual "
			      + STR0008+right(cUltFech,2)+"/"+Left(cUltFech,4) + ".",1,0) // "ou inferior ao último fechamento: "
			lContinua := .F.
		EndIf
		
		If lContinua

			oProcess:SetRegua1(LIT->(recCount()))
			oProcess:SetRegua2(0)
		
			// Contrato de venda - Cabecalho
			dbSelectArea("LIT")
			dbSetOrder(2) // LIT_FILIAL + LIT_NCONTR
			dbSeek(cFilLIT+cContrDe,.T.)
			While LIT->(!eof()) .And. (LIT->(LIT_FILIAL+LIT_NCONTR) <= cFilLIT+cContrAte)
				// atualiza as reguas
				oProcess:IncRegua1(STR0015 + LIT->LIT_NCONTR ) // "Contrato: "
				oProcess:IncRegua2("")
				nTotQtdParc := 0
				cCM_Ant := cUltFech
				
				If LIT->(FieldPos("LIT_FECHAM"))>0 .And. LIT->(FieldPos("LIT_DTCM"))>0

					If !(Empty(LIT->LIT_FECHAM)) .And. LIT->LIT_FECHAM >= cAno+cMes
						//data de fechamento do contrato superior ou igual a data de fechamento
						aAdd( aNaoProc , {LIT->LIT_NCONTR , STR0032+Substr(LIT->LIT_FECHAM,5,2)+"/"+Substr(LIT->LIT_FECHAM,1,4) }) //" não processado - contrato fechado até a data de (mm/aaaa)"
						LIT->(DbSkip())
						Loop
					EndIf

					//verifica se existe e se eh valida a correcao monetaria do mes anterior
					cCM_Ant := Left ( DtoS( GMPrevMonth( StoD(cAno+cMes+"01") , 1 ) ) , 6 )
					If !Empty(LIT->LIT_DTCM) .And. LIT->LIT_DTCM < cCM_Ant
						aAdd( aNaoProc , {LIT->LIT_NCONTR , STR0033 }) //" não processado - a correção monetaria do contrato não foi realizada no mes anterior"
						LIT->(DbSkip())
						Loop
					EndIf

				EndIf
				
				//
				// se mes/ano do contrato for inferior ao mes/ano de CM deve corrigr
				//
				If StrZero(YEAR(LIT->LIT_EMISSAO),4)+StrZero(Month(LIT->LIT_EMISSAO),2) < cAno+cMes
                    
					/****************************************************************************/ 
					// Busca pelo Item de venda 
					/****************************************************************************/ 
					dbSelectArea("LIU")
					dbSetOrder(3) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
					If dbSeek(xFilial("LIU")+LIT->LIT_NCONTR)
						/****************************************************************************/ 
						// Busca pelo empreendimento 
						/****************************************************************************/ 
						dbSelectArea("LIQ")
						dbSetOrder(1) //  LIQ_FILIAL+LIQ_COD
						If dbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)
						
							/****************************************************************************/ 
							// Contrato em aberto
							/****************************************************************************/ 
							If LIT->LIT_STATUS == "1"
								
								lContratos := .T.
								lContinua  := .T.
								aMsgError  := {}
		
								If Empty(LIQ->LIQ_HABITE)
									If Empty(LIQ->LIQ_PREVHB) .OR. Left(Dtos(LIQ->LIQ_PREVHB),6) <= cAno+cMes
										//"A data de Pre-Habite do contrato: "### " deve ser atualizada ou informar a data do Habite-se."
										aAdd(aMsgError , STR0034 + LIT->LIT_NCONTR + STR0035)
										lContinua := .F.
									EndIf
								EndIf
								
								If lContinua
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Faz a montagem do aColsLJO                                ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									dbSelectArea("LJO")
									dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
									If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR)
										While !Eof() .And. LJO->LJO_FILIAL+LJO->LJO_NCONTR==xFilial("LJO")+LIT->LIT_NCONTR
											
											// zera o contador de titulos processados
											nCntTit := 0
											cTaxa   := ""
											// Quantidade total de titulos
											nQtdParcelas := LJO->LJO_NUMPAR
											
											// Se foi entregue as chaves e a CM for superior a data de entrega
											If ! Empty(LIQ->LIQ_HABITE) .AND. cAno+cMes > left(dtos(LIQ->LIQ_HABITE),6)
												cTaxa    := LJO->LJO_INDPOS
												nMes     := LJO->LJO_NMES2
												nDiaCorr := LJO->LJO_DIACOR
											Else
												cTaxa    := LJO->LJO_IND
												nMes     := LJO->LJO_NMES1
												nDiaCorr := LJO->LJO_DIACOR
											EndIf
											
											dRefIndCM := stod("")
											dIndCM    := stod("")
											nDecIndCM := 0
											lContinua := .T.
											
											// se houver indice de correcao monetaria
											If ! Empty(cTaxa)
												// se foi informado o dia para a correcao monetaria
												If nDiaCorr > 0 
												
													dRefIndCM := stod(cAno+cMes+STRZERO(nDiaCorr ,TAMSX3("LIS_DIACOR")[1]))
													aRetCoef  := T_GEMCoefCM( cTaxa ,nMes ,dRefIndCM )
									
													nDecIndCM := aRetCoef[1]/aRetCoef[2]
													dIndCM := aRetCoef[4]
													If !(lContinua := Empty(aRetCoef[3]))
														aAdd(aMsgError ,aRetCoef[3] )
													EndIf
													
												Else 
													// "Dia da correção monetaria nao foi informado para o item '"###"' da condicao de venda."
													aAdd(aMsgError ,STR0036 + LJO->LJO_ITEM + STR0037)
													lContinua := .F.
												EndIf
											EndIf
											
											// naum encontrou dados par ao calculo da correcao monetaria
											If lContinua
												//
												// Tipo de parcela
												//
												dbSelectArea("LFD")
												dbSetOrder(1) // LFD_FILIAL+LFD_COD
												If dbSeek(xFilial("LFD")+LJO->LJO_TIPPAR)
													
													// Calcula o valor da taxa anual para a taxa equivalente conforme 
													// intervalo informado convertendo em decimal
													nDecTaxa := t_GMCoefSistema( LJO->LJO_TAXANO ,LFD->LFD_INTERV )/100
													
													// Atualiza a regua de parcelas
													oProcess:SetRegua2(nQtdParcelas)
													
													//
													// calcula as prestacoes
													//
													dbSelectArea("LIX")
													dbSetOrder(4) // LIX_FILIAL + LIX_NCONTR + LIX_CODCND + LIX_ITCND
													dbSeek(xFilial("LIX")+LIT->(LIT_NCONTR+LIT_COND)+LJO->LJO_ITEM)
													While LIX->(!eof()) .AND. ;
												 	      xFilial("LIX")+LIT->(LIT_NCONTR+LIT_COND)+LJO->LJO_ITEM == LIX->(LIX_FILIAL+LIX_NCONTR+LIX_CODCND+LIX_ITCND)
												 	      
												 		oProcess:IncRegua2(STR0016 + LIX->LIX_PREFIXO +" "+LIX->LIX_NUM+"-"+LIX->LIX_PARCEL ) // "Título : "
														nAcumCMAmort := 0
														nAcumCMJuros := 0
														nCMAmort     := 0
														nCMJuros     := 0
									 					
														//
														// titulos a receber
														//
														dbSelectArea("SE1")
														dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
														If dbSeek(cFilSE1+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))
															// Se o mes/ano de emissao do titulo for menor que o mes/ano de CM, calcula a CM 
															If left(dtos(SE1->E1_EMISSAO),6) < left(dtos(dRefIndCM),6)
																// Ultima correcao monetaria aplicada
																dbSelectArea("LIW")
																dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
																lSuccess := dbSeek(cFilLIW+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+cCM_Ant )
																
																If lSuccess
																	nAcumCMAmort := LIW->LIW_ACUAMO
																	nCMAmort     := LIW->LIW_VLRAMO
																	nAcumCMJuros := LIW->LIW_ACUJUR
																	nCMJuros     := LIW->LIW_VLRJUR
																EndIf
																	
																// Valor do título atual
																nVlrTitulo := LIX->LIX_ORIAMO+LIX->LIX_ORIJUR+nAcumCMAmort+nAcumCMJuros+nCMAmort+nCMJuros
																nAmorBase  := round( nVlrTitulo*(LIX->LIX_ORIAMO / (LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) ,2 )
																nJuroBase  := round( nVlrTitulo*(LIX->LIX_ORIJUR / (LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) ,2 )
																
																// Correcao monetaria do titulo, Amortizacao, Juros e Saldo devedor
																nNewVlrTit  := round( (nVlrTitulo*nDecIndCM) ,2)
																If nNewVlrTit < 0
																	nNewVlrTit := nNewVlrTit * -1
																EndIf
																
																// valor do amortizado corrigido com o indice
																nNewCMAmort := round( nAmorBase * nDecIndCM ,2)
										
																If ExistBlock("GmCalcCM")
					
																	// nVlrTitulo - Valor do titulo atual(base amortizado + base juros)
																	// nAmorBase - Valor da amortizacao do titulo atual
						
																	aCustomCM := ExecBlock("GMCalcCM",.F.,.F.,{nVlrTitulo,nAmorBase,nDecIndCM})
																	// ---> Com o valor do titulo e a base de amortizado, conseguira encontrar a base de juros
																	// ---> O indice e passado para que poss    
																
																	// aCustomCM[1] - Valor do titulo corrigido com novo indice
																	// aCustomCM[2] - Valor do amortizado do titulo corrigido
																
																	nNewVlrTit  := aCustomCM[1]
																	nNewCMAmort := aCustomCM[2]
																
																EndIf                               
					
																nCMTitulo   := nNewVlrTit-nVlrTitulo // Valor da CM do Titulo 
																nNewCMAmort := nNewCMAmort-nAmorBase // Valor da CM do amortizado
																nNewCMJuros := nCMTitulo-nNewCMAmort // Valor da CM do juros
																												
																
																// contador de prestacao recalculadas
																nCntTit++
																nTotQtdParc++
																
																//
																// Detalhe de Titulos a Receber (Correcao monetaria)
																//
																dbSelectArea("LIW")
																dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
																lNovoLIW := ! dbSeek(cFilLIW+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+cAno+cMes )
																
																// atualiza a data de processamento e o valor da correcao monetaria do titulo a receber
																RecLock("LIW",lNovoLIW)
																
																	If lNovoLIW
																		LIW->LIW_FILIAL  := xFilial("LIW")
																		LIW->LIW_PREFIXO := SE1->E1_PREFIXO
																		LIW->LIW_NUM     := SE1->E1_NUM 
																		LIW->LIW_PARCELA := SE1->E1_PARCELA 
																		LIW->LIW_TIPO    := SE1->E1_TIPO
																	
																	EndIf
																	LIW->LIW_DTPRC  := dDatabase  // data do calculo da correcao monetaria
																	LIW->LIW_DTRef  := cAno+cMes  // Ano/Mes de referencia
																	LIW->LIW_DTIND  := dIndCM     // data de referencia do indice de correcao
																	LIW->LIW_TPCORR := "1"        // Correcao monetaria
																	LIW->LIW_TAXA   := cTaxa      // Codigo da taxa de correcao monetaria utilizado
																	LIW->LIW_INDICE := aRetCoef[1]
																	LIW->LIW_BASAMO := nVlrTitulo*(LIX->LIX_ORIAMO / (LIX->LIX_ORIAMO+LIX->LIX_ORIJUR))
																	LIW->LIW_BASJUR := nVlrTitulo*(LIX->LIX_ORIJUR / (LIX->LIX_ORIAMO+LIX->LIX_ORIJUR))
																	LIW->LIW_VLRAMO := nNewCMAmort
																	LIW->LIW_VLRJUR := nNewCMJuros
																	LIW->LIW_ACUAMO := nCMAmort+nAcumCMAmort
																	LIW->LIW_ACUJUR := nCMJuros+nAcumCMJuros
																MSUnlock()
																
															EndIf
															                                     
														EndIf
														
														dbSelectArea("LIX")
												 		dbSkip()
												 	EndDo
												Else
													//Tipo de parcela ### na condicao de venda ##########" nao foi encontrado."
													aAdd(aMsgError ,STR0038+" '" + LJO->LJO_TIPPAR + "' "+STR0039+" '"+ LIS->LIS_CODCND + "/" + LJO->LJO_ITEM + STR0040)
												EndIf
											
											EndIf
											
											dbSelectArea("LJO")
											dbSkip()
										EndDo
									Else
										aAdd(aMsgError ,STR0041) //"Itens da condicao de pagamento do contrato nao foram encontrados."
									EndIf
								EndIf										
								// Totaliza as parcelas do contrato e os erros gerados
								aAdd( aContrProc, {LIT->LIT_NCONTR ,nTotQtdParc ,aMsgError })
								
							/****************************************************************************/ 
							// Cancelado (Distrato)
							/****************************************************************************/ 
							ElseIf LIT->LIT_STATUS == "5"
							
								dbSelectArea("LJD")
								dbSetOrder(1) // LJD_FILIAL+LJD_NCONTR+LJD_REVISA
								If dbSeek(xFilial("LJD")+LIT->LIT_NCONTR)
									lContratos := .T.
									aMsgError  := {}
			                        
									If ! Empty(LJD->LJD_COND)
										
										aCondVend := {}
										
										If LJD->LJD_COND == GetMV("MV_GMCPAG")
											//
											// Define os campos para pesquisa
											//
											aFields := { "LJS_ITEM" ,"LJS_NUMPAR" ,"LJS_TIPPAR" ;
											            ,"LJS_IND"  ,"LJS_NMES"   ,"LJS_DIACOR" }
											aHeader   := {}
											dbSelectArea("SX3")
											SX3->(dbSetOrder(2)) // X3_FILIAL + X3_CAMPO
											aEval(aFields ,{|cCampo| iIf( SX3->(dbSeek(cCampo)) ;
											                                ,aAdd( aHeader,{ TRIM(x3titulo()) ,SX3->x3_campo   ,SX3->x3_picture ;
											                                                ,SX3->x3_tamanho  ,SX3->x3_decimal ,SX3->x3_valid   ;
											                                                ,SX3->x3_usado    ,SX3->x3_tipo    ,SX3->x3_arquivo ;
											                                                ,SX3->x3_context } ) ,.F. ) ;
											               } )
											               
											nPos_ITEM   := aScan(aHeader ,{|x|Alltrim(x[2])== "LJS_ITEM"  }) // Item da condicao venda 
											nPos_NUMPAR := aScan(aHeader ,{|x|Alltrim(x[2])== "LJS_NUMPAR"}) // Qtd de parcelas 
											nPos_TIPPAR := aScan(aHeader ,{|x|Alltrim(x[2])== "LJS_TIPPAR"}) // Codigo do Tipo de Parcela
											nPos_IND    := aScan(aHeader ,{|x|Alltrim(x[2])== "LJS_IND"   }) // Codigo da taxa pre-chaves
											nPos_NMES1  := aScan(aHeader ,{|x|Alltrim(x[2])== "LJS_NMES"  }) // n Mes referente ao indice
											nPos_DIACOR := aScan(aHeader ,{|x|Alltrim(x[2])== "LJS_DIACOR"}) // DIA DO VENCIMENTO
											
											
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Faz a montagem do aColsLJO                                ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											dbSelectArea("LJS")
											dbSetOrder(1) // LJS_FILIAL+LJS_NCONTR+LJS_REVISA+LJS_ITEM
											dbSeek(xFilial("LJS")+LJD->LJD_NCONTR)
											While !Eof() .And. LJS->LJS_FILIAL+LJS->LJS_NCONTR==xFilial("LJS")+LJD->LJD_NCONTR
												aAdd( aCondVend ,Array(len(aHeader)) )
												For nY := 1 to len(aHeader)
													If ( aHeader[ny][10] != "V")
														aCondVend[Len(aCondVend)][ny] := FieldGet(FieldPos(aHeader[ny][2]))
													Else
														aCondVend[Len(aCondVend)][ny] := CriaVar(aHeader[ny][2])
													EndIf
												Next nY
												dbSelectArea("LJS")
												dbSkip()
											EndDo
											
											If len(aCondVend) == 0
												aAdd( aMsgError ,STR0041) //"Itens da condicao de pagamento do contrato nao foram encontrados."
											EndIf
										EndIf
										
										For nY := 1 to len(aCondVend)
											lContinua := .F.
											// zera o contador de titulos processados
											nCntTit := 0
											// Quantidade total de titulos
											nQtdParcelas := aCondVend[nY][nPos_NUMPAR]
											
											// se houver indice de correcao monetaria								
											If ! Empty(aCondVend[nY][nPos_IND]) 
												//
												// Cadastro de indices
												//
												dbSelectArea("AAD")
												AAD->(dbSetOrder(1)) // AAD_FILIAL+AAD_CODIND
												If AAD->(dbSeek(xFilial("AAD")+aCondVend[nY][nPos_IND]))
												    // se foi informado o dia para a correcao monetaria
													If aCondVend[nY][nPos_DIACOR] > 0 
														// monta a data do indice para correcao monetaria
														dRefIndCM := stod(cAno+cMes+STRZERO(aCondVend[nY][nPos_DIACOR] ,TAMSX3("LIS_DIACOR")[1]))
														aRetCoef  := T_GEMCoefCM( aCondVend[nY][nPos_IND] ,aCondVend[nY][nPos_NMES1] ,dRefIndCM )
														
														nDecIndCM := aRetCoef[1]/aRetCoef[2]
														dIndCM := aRetCoef[4]
														If !(lContinua := Empty(aRetCoef[3]))
															aAdd(aMsgError ,aRetCoef[3] )
														EndIf

													Else 
														aAdd(aMsgError ,STR0042) //"Dia da correção monetaria para condicao de venda nao foi informado."
														lContinua := .F.
													EndIf
												Else
													//"Indice '"###"' para correcao monetaria nao foi encontrado."
													aAdd(aMsgError ,STR0043 + aCondVend[nY][nPos_IND] + STR0044)
													lContinua := .F.
												EndIf
											Else 
												dIndCM    := stod("")
												nDecIndCM := 0
												lContinua := .T.
											EndIf
											
											// naum encontrou dados para o calculo da correcao monetaria
											If lContinua
												//
												// Tipo de parcela
												//
												dbSelectArea("LFD")
												dbSetOrder(1) // LFD_FILIAL+LFD_COD
												If dbSeek(xFilial("LFD")+aCondVend[nY][nPos_TIPPAR])
													
													// Atualiza a regua de parcelas
													oProcess:SetRegua2(nQtdParcelas)
													
													//
													// Detalhes dos titulos a pagar do distrato
													//
													dbSelectArea("LJV") 
													LJV->(dbSetOrder(2)) // LJV_FILIAL+LJV_PREFIX+LJV_NUM+LJV_PARCEL+LJV_TIPO
													LJV->(dbSeek(xFilial("LJV")+LIT->LIT_PREFIX+LIT->LIT_DUPL+LJD->LJD_COND+aCondVend[nY][nPos_ITEM]))
													
													// calcula as prestacoes
													While LJV->(!eof()) .AND. ;
												 	      xFilial("LJV")+LIT->LIT_PREFIX+LIT->LIT_DUPL+LJD->LJD_COND+aCondVend[nY][nPos_ITEM] == LJV->LJV_FILIAL+LJV->LJV_PREFIXO+LJV->LJV_NUM+LJV->LJV_CODCND+LJV->LJV_ITCND
												 	
												 		oProcess:IncRegua2(STR0016 + LJV->LJV_PREFIXO +" "+LJV->LJV_NUM+"-"+LJV->LJV_PARCEL ) // "Título : "
												 		
														//
														// titulos a pagar
														//
														dbSelectArea("SE2")
														SE2->(dbSetOrder(1)) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
														If SE2->(dbSeek(xFilial("SE2")+LJV->LJV_PREFIXO+LJV->LJV_NUM+LJV->LJV_PARCEL+LJV->LJV_TIPO))
											 	        	// Se existe saldo e o mes/ano de emissao do titulo for menor que o mes/ano de CM, calcula a CM
															If SE2->E2_SALDO > 0 .AND. left(dtos(SE2->E2_EMISSAO),6) < left(dtos(dIndCM),6)
																// Valor da amortizacao e juros da prestacao
																nVlrAmort  := LJV->LJV_AMORT
																nVlrJuros  := LJV->LJV_VALJUR
																
																// Ultima correcao monetaria aplicada
																dbSelectArea("LJX")
																LJX->(dbSetOrder(1)) // LJX_FILIAL+LJX_PREFIX+LJX_NUM+LJX_PARCEL+LJX_TIPO+LJX_DTREF
																If dbSeek(cFilLJX+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)+cCM_Ant )
																	nAcumCMAmort := LJX->LJX_ACUAMO
																	nAcumCMJuros := LJX->LJX_ACUJUR
																	nCMAmort := LJX->LJX_VLRAMO
																	nCMJuros := LJX->LJX_VLRJUR
																Else
																	nAcumCMAmort := 0
																	nAcumCMJuros := 0
																	nCMAmort := 0
																	nCMJuros := 0
																EndIf
																
																// Valor do título atual
																nVlrTitulo := nVlrAmort+nVlrJuros+nAcumCMAmort+nAcumCMJuros+nCMAmort+nCMJuros
																nAmorBase  := round( nVlrTitulo*(LIX->LIX_ORIAMO / (LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) ,2 )
																nJuroBase  := round( nVlrTitulo*(LIX->LIX_ORIJUR / (LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) ,2 )
																
																// Correcao monetaria do titulo, Amortizacao, Juros
																nNewVlrTit  := round( (nVlrTitulo*nDecIndCM) ,2)
																If nNewVlrTit < 0
																	nNewVlrTit := nNewVlrTit * -1
																EndIf
																nCMTitulo   := nNewVlrTit-nVlrTitulo
																
																nNewCMAmort := round( nAmorBase * nDecIndCM ,2) -nAmorBase
																nNewCMJuros := nCMTitulo-nNewCMAmort
																
																// contador de prestacao recalculadas
																nCntTit++
																nTotQtdParc++
																
																RecLock("SE2",.F.)
																	If SE2->E2_SALDO == SE2->E2_VALOR
																		SE2->E2_VALOR  := nVlrTitulo+nCMTitulo
																	EndIf
																	SE2->E2_SALDO  := nVlrTitulo+nCMTitulo
																	SE2->E2_VLCRUZ := nVlrTitulo+nCMTitulo
																SE2->(MSUnlock())
																
																//
																// Detalhe de Titulos a Pagar (Correcao monetaria)
																//
																dbSelectArea("LJX")
																LJX->(dbSetOrder(1)) // LJX_FILIAL+LJX_PREFIX+LJX_NUM+LJX_PARCEL+LJX_TIPO+LJX_DTIND
																lNovoLJX := ! dbSeek(cFilLJX+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)+cAno+cMes )
																  
																//
																// atualiza a data de processamento e o valor da correcao monetaria do titulo a receber
																//
																RecLock("LJX",lNovoLJX)
																
																	If lNovoLJX
																		LJX->LJX_FILIAL  := SE2->E2_FILIAL
																		LJX->LJX_PREFIXO := SE2->E2_PREFIXO
																		LJX->LJX_NUM     := SE2->E2_NUM
																		LJX->LJX_PARCELA := SE2->E2_PARCELA
																		LJX->LJX_TIPO    := SE2->E2_TIPO
																	EndIf
																	LJX->LJX_DTRef  := cAno+cMes        // Ano/Mes de referencia
																	LJX->LJX_DTPRC  := dDatabase
																	LJX->LJX_TAXA   := aCondVend[nY][nPos_IND] // Codigo da taxa de correcao monetaria utilizado
																	LJX->LJX_DTIND  := dIndCM           // data de referencia do indice de correcao
																	LJX->LJX_VLRAMO := nNewCMAmort
																	LJX->LJX_VLRJUR := nNewCMJuros
																	LJX->LJX_ACUAMO := nCMAmort+nAcumCMAmort
																	LJX->LJX_ACUJUR := nCMJuros+nAcumCMJuros
																LJX->(MSUnlock())
																
																//
																// Detalhes dos titulos
																//
																RecLock("LJV",.F.)
																	LJV->LJV_AMORT  := nVlrAmort
																	LJV->LJV_VALJUR := nVlrJuros
																	LJV->LJV_CMAMO  := nNewCMAmort
																	LJV->LJV_CMJUR  := nNewCMJuros
																LJV->(MSUnlock())
															EndIf
															
														EndIf
														
												 		LJV->(dbSkip())
												 		
												 	EndDo
												Else
													//Tipo de parcela###"' na condicao de pagamento '"###" nao foi encontrado."
													aAdd(aMsgError ,STR0038 + " '" + aCondVend[nY][nPos_TIPPAR] + STR0045 + LIS->LIS_CODCND + "/" + aCondVend[nY][nPos_ITEM] + STR0040)
												EndIf
											EndIf
										Next nY
									EndIf

								Else
									//"Distrato do contrato '"###"' nao foi encontrado."
									aAdd(aMsgError ,STR0046 + LIT->LIT_NCONTR + STR0040)
							    EndIf

								aAdd( aContrProc, {LIT->LIT_NCONTR ,nTotQtdParc ,aMsgError })
							
							EndIf
							
						Else
							//"O empreendimento do Contrato '"###"' nao foi encontrado."
							aAdd(aMsgError ,STR0047 + LIT->LIT_NCONTR + STR0040)
							aAdd( aContrProc, {LIT->LIT_NCONTR ,nTotQtdParc ,aMsgError })
						EndIf
					
					Else
						//"Não existe empreendimento referente ao Contrato '"
						aAdd(aMsgError , STR0048 + LIT->LIT_NCONTR + "'.")
						aAdd( aContrProc, {LIT->LIT_NCONTR ,nTotQtdParc ,aMsgError })
					EndIf

				Else
					cAux := SubStr(DtoS(LIT->LIT_EMISSAO),7,2)+"/"+SubStr(DtoS(LIT->LIT_EMISSAO),5,2)+"/"+SubStr(DtoS(LIT->LIT_EMISSAO),1,4)
					//" não processado - data de emissao ("###") posterior a correção monetaria"
					aAdd( aNaoProc , {LIT->LIT_NCONTR , STR0049+cAux+STR0050 })
				EndIf

				If LIT->(FieldPos("LIT_DTCM")) > 0 .And. lContinua
					RecLock("LIT",.F.)
					LIT->LIT_DTCM := cAno+cMes
					LIT->(MsUnlock())
				EndIf

				dbSelectArea("LIT")
				dbSkip()
			EndDo
			
			// se naum processou nenhum contrato
			If !lContratos
				Help("",1,"GMA070002")
			Else
			
				cTexto := STR0023 + CRLF // "Log da Correção Monetária "
				cTexto := cTexto + replicate("-",40) + CRLF + CRLF
				cTexto := cTexto + STR0024 + CRLF // "Parametros Utilizados: "
				cTexto := cTexto + STR0025 + cMes+"/"+cAno + CRLF // "Mês/Ano: "
				cTexto := cTexto + STR0026 + cContrDe + STR0027 + cContrAte + "'" + CRLF + CRLF //### //"Filtro de Contratos: '"###"' a '"
				
				For nCount := 1 To Len(aContrProc)
					cTexto := cTexto + STR0015 + aContrProc[nCount][1] + STR0028 + Transform( aContrProc[nCount][2] ,"@E 999,999") + STR0029 + CRLF //###### //"Contrato: "###" foram processadas "###" parcelas."
					aEval( aContrProc[nCount][3] ,{|cError| cTexto := cTexto + space(10) + cError +CRLF })
				Next nCount
				For nCount := 1 To Len(aNaoProc)
					cTexto := cTexto + STR0015 + aNaoProc[nCount][1] + aNaoProc[nCount][2] + CRLF //###### //"Contrato: "###" foram processadas "###" parcelas."
				Next nCount

				cTexto := cTexto + CRLF
				cTexto := cTexto + STR0030 + Transform( Len(aContrProc) ,"@E 999,999,999,999,999") + CRLF // "Total de Contratos processados: "
				cTexto := cTexto + STR0051 + Transform( Len(aNaoProc) ,"@E 999,999,999,999,999") //"Total de Contratos não processados: "
				
				__cFileLog := Criatrab(,.f.)+".LOG"
				lSuccess := MemoWrite(__cFileLog ,cTexto)
				DEFINE FONT oFont NAME "Arial" SIZE 6,14
				DEFINE MSDIALOG oDlg TITLE STR0031 From 3,0 to 340,417 PIXEL // "Correção Monetaria dos Títulos Concluído"
				@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL 
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont:=oFont
				
				DEFINE SBUTTON oSBtnOk FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //ok
				oSBtnOk:SetFocus()
				ACTIVATE MSDIALOG oDlg CENTER
				
				fErase(__cFileLog)
			
			EndIf

		EndIf
	EndIf			
	RestArea( aArea )
	
Return( .T. )
