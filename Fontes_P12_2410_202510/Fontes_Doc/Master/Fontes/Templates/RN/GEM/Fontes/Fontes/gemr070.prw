
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMR070   ºAutor  ³Reynaldo Miyashita  º Data ³  02/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de Titulo a receber por empreendimento           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "GEMR070.CH"

#define _CABECALHO_FONTE_TAMANHO_ 2
#define _CORPO_FONTE_TAMANHO_     1


Static aIndex := { ;
                   {"E1_BAIXA"       ,"dtos(E1_BAIXA)+A1_COD+A1_LOJA+LIQ_COD"   ,x3Titulo2( "E1_BAIXA" )} ;
                  ,{"E1_VENCREA"     ,"dtos(E1_VENCREA)+A1_COD+A1_LOJA+LIQ_COD"  ,x3Titulo2( "E1_VENCREA" )} ;
                  ,{"LIQ_COD"        ,"LIQ_COD+NUMPARC"                         ,x3Titulo2( "LIQ_COD" )} ;
                  ,{"A1_COD+A1_LOJA" ,"A1_COD+A1_LOJA+LIQ_COD+NUMPARC"          ,AllTrim(x3Titulo2( "A1_COD" )) + " - " + Alltrim(x3Titulo2( "A1_LOJA" ))} ;
                  ,{"A1_NOME"        ,"A1_NOME+A1_COD+A1_LOJA+LIQ_COD+NUMPARC"  ,x3Titulo2( "A1_NOME" )} ;
                 }


Template Function GEMR070()
Local lDic      := .F.
Local lComp     := .T.
Local lFiltro   := .F.
Local wnrel     := "GMR070"
Local cDesc1    := OemToAnsi(STR0001)  //"Este relatorio ira imprimir a relacao dos titulos a "
Local cDesc2    := OemToAnsi(STR0002) //"receber/recebidos conforme os parametros solicitados"
Local cDesc3    := OemToAnsi("")
Local nCnt      := 0
Local cAlias    := ""
Local cTable    := ""
Local cIndex    := ""
Local cKey      := ""
Local aCampos   := {}
Local aStru     := {}
Local lContinua := .T.

Private NomeProg := "GMR070"
Private Cabec1   := ""
Private Cabec2   := ""
Private Titulo   := STR0003 //"Titulos a receber/recebidos por empreendimento"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso ultrapasse, utiliza o tamanho grande de Lay-Out                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lAuto1  := .F.
Private Tamanho := "G" // P/M/G
Private Limite  := 220 // 80/132/220
Private aOrdem  := {}  // Ordem do Relatorio
Private cPerg   := "GMR070"  // Pergunta do Relatorio
Private aReturn := { STR0004, 1,STR0005, 1, 2, 1, "",1 } //"Zebrado"  ##  "Administracao"
						//[1] Reservado para Formulario
						//[2] Reservado para N§ de Vias
						//[3] Destinatario
						//[4] Formato => 1-Comprimido 2-Normal
						//[5] Midia   => 1-Disco 2-Impressora
						//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
						//[7] Expressao do Filtro
						//[8] Ordem a ser selecionada
						//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault
Private nLi     := 100

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o Arquivo de perguntas                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrinter                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cAlias,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro,.F.)

If !(nLastKey == 27)

	aAdd( aCampos ,{"LK3_CODEMP" ,"LK3_CODEMP" })
	aAdd( aCampos ,{"LK3_DESCRI" ,"LK3_DESCRI" })
	aAdd( aCampos ,{"A1_COD"     ,"A1_COD"     })
	aAdd( aCampos ,{"A1_LOJA"    ,"A1_LOJA"    })
	aAdd( aCampos ,{"A1_NOME"    ,"A1_NOME"    })
	aAdd( aCampos ,{"LIQ_COD"    ,"LIQ_COD"    })
	aAdd( aCampos ,{"E1_BAIXA"   ,"E1_BAIXA"   })
	aAdd( aCampos ,{"E1_VENCREA" ,"E1_VENCREA" })
	aAdd( aCampos ,{"NUMPARC"    ,"E1_ITPARC"  })
	aAdd( aCampos ,{"TIPPARC"    ,"LJO_TPDESC" })
	aAdd( aCampos ,{"TAXA"       ,"LJO_IND"    })
	aAdd( aCampos ,{"VLRPRINC"   ,"E1_SALDO"   })
	aAdd( aCampos ,{"VLRUNID"    ,"E1_SALDO"   })
	aAdd( aCampos ,{"VLRJRFCT"   ,"E1_SALDO"   })
	aAdd( aCampos ,{"VLRPENAL"   ,"E1_SALDO"   })
	aAdd( aCampos ,{"VLRDESC"    ,"E1_SALDO"   })
	aAdd( aCampos ,{"VLRPARC"    ,"E1_SALDO"   })
	aAdd( aCampos ,{"VLRCORR"    ,"E1_SALDO"   })
	aAdd( aCampos ,{"SITUAC"     ,{"C",20,0}   })
	
	cTable  := CriaTrab(NIL ,.F.)
	cIndex  := cTable
	
	For nCnt := 1 to Len(aCampos)
		If ValType(aCampos[nCnt][2]) == "C"
			dbSelectArea("SX3")
			dbSetOrder(2) // X3_FILIAL+X3_CAMPO
			If MsSeek(aCampos[nCnt][2])
				aAdd(aStru,{aCampos[nCnt][1] ,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
			EndIf
		ElseIf ValType(aCampos[nCnt][2]) == "A"
			aAdd(aStru,{aCampos[nCnt][1] ,aCampos[nCnt][2][1],aCampos[nCnt][2][2],aCampos[nCnt][2][3]})
		EndIf
	Next nCnt

	cKey := SeekIndex( MV_PAR10)
	
	cKey := "LK3_CODEMP+" + cKey

	dbCreate(cTable,aStru)
	dbUseArea(.T.,,cTable,cTable,.F.,.F.)
	IndRegua(cTable, cIndex, cKey ,,)
	(cTable)->(dbSetIndex(cIndex + OrdBagExt()))
	(cTable)->(dbSetOrder(1))
	
	Processa({||GMR070Proc( cTable )},STR0006) //"Processando..."
	RptStatus({|lEnd| GMR070Imp(@lEnd ,@wnRel ,cTable ,aReturn )})
	
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GMR070Proc³ Autor ³ Reynaldo Miyashita    ³ Data ³ 25.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa as informacoes para o relatorio                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 25.09.06 ³Reynaldo Miyash³ Criação                                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GMR070Proc( cTable )
Local aArea       := GetArea()
Local aAreaLIU
Local nCntRegua   := 0
Local aVlrCM      := {}
Local nVlrPrinc   := 0
Local nVlrJrFcto  := 0
Local nVlrParcela := 0
Local cTipParc    := ""
Local cTaxa       := ""
Local nMes        := 0
Local aRet        := {}
Local nVlrAtual     := 0
Local nVlrProRata   := 0
Local nVlrJurosMora := 0
Local nVlrMulta     := 0
Local nVlrDescont   := 0
Local dHabite       := stod("")
Local nCnt        := 0
Local nCnt2       := 0
Local cSituacao   := ""
Local cFilLIU     := xFilial("LIU")
Local nTotUnid    := 0  
Local lUltCM      := GetNewPar("MV_GEMULTC",.F.) // verifica se pega a ultima correcao monetaria  
Local aBaixas := {}
	
	ProcRegua(100)

	// empreendimento
	dbSelectArea("LK3")
	dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
	dbSeek( xFilial("LK3")+MV_PAR01,.T. )
	While LK3->(!Eof()) .AND. ;
	      LK3->LK3_FILIAL+LK3->LK3_CODEMP <= xFilial("LK3")+MV_PAR02

		 // Cadastro das Unidades do Empreendimentos
		dbSelectArea("LIQ")
		dbSetOrder(4) // LIQ_FILIAL+LIQ_CODEMP+LIQ_STRPAI
		dbSeek(xFilial("LIQ")+LK3->LK3_CODEMP)
		While LIQ->(!Eof()) ;
		      .and. LK3->LK3_FILIAL+LK3->LK3_CODEMP == xFilial("LIQ")+LIQ->LIQ_CODEMP
			// se tiver contrato assinado
			If LIQ->LIQ_STATUS == 'CA'
				// Itens do Contrato
				dbSelectArea("LIU")
				dbSetOrder(2) // LIU_FILIAL+LIU_CODEMP
				dbSeek(xFilial("LIU")+LIQ->LIQ_COD)
				While LIU->(!Eof()) .AND. LIU->LIU_FILIAL+LIU->LIU_CODEMP==xFilial("LIU")+LIQ->LIQ_COD
					// cabecalho do Contrato
					dbSelectArea("LIT")
					dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
					If dbSeek(xFilial("LIT")+LIU->LIU_NCONTR)
						// se o contrato estiver ativo
						If LIT->LIT_STATUS == "1" ;
						   .AND. LIT->LIT_CLIENT >= MV_PAR03 .AND. LIT->LIT_CLIENT <= MV_PAR05 ;
						   .AND. LIT->LIT_LOJA >= MV_PAR04 .AND. LIT->LIT_LOJA <= MV_PAR06
						   
							// guarda a soma de todas as unidades do contrato
						   aAreaLIU := LIU->(GetArea())
						   LIU->(DbSetOrder(1)) //LIU_FILIAL+LIU_DOC+LIU_SERIE+LIU_CLIENT+LIU_LOJA+LIU_COD+LIU_ITEM
						   LIU->(DbSeek(cFilLIU+LIT->LIT_DOC+LIT->LIT_SERIE))
						   
						   nTotUnid := 0
						   While !LIU->(EOF()) .And. LIU->(LIU_FILIAL+LIU_DOC+LIU_SERIE)==cFilLIU+LIT->LIT_DOC+LIT->LIT_SERIE
								If !Empty(LIU->LIU_CODEMP)
									nTotUnid += LIU->LIU_TOTAL
								EndIf
								LIU->(DbSkip())
						   EndDo
						   RestArea(aAreaLIU)
						   nRateio := LIU->LIU_TOTAL / nTotUnid

							// Cadastro de cliente
							dbSelectArea("SA1")
							dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
							If dbSeek(xFilial("SA1")+LIT->LIT_CLIENT+LIT->LIT_LOJA)
							
								// Detalhes dos titulos a receber
								dbSelectArea("LIX")
								dbSetOrder(4) // LIX_FILIAL+LIX_NCONTR+LIX_CODCND+LIX_ITCND
								dbSeek(xFilial("LIX")+LIT->LIT_NCONTR)
								While LIX->(!Eof()) .AND. ;
							 	      xFilial("LIX")+LIT->LIT_NCONTR == LIX->(LIX_FILIAL+LIX_NCONTR)

									IncProc(STR0007) //"Selecionando...."
									nCntRegua++
									If nCntRegua == 100
										ProcRegua(100)
										nCntRegua := 0
									EndIf

									// Titulos a receber
									dbSelectArea("SE1")
									dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
									If dbSeek(xFilial("SE1")+LIX->LIX_PREFIXO+LIX->LIX_NUM+LIX->LIX_PARCEL+LIX->LIX_TIPO)
									
										aVlrCM      := {}
										nVlrPrinc   := 0
										nVlrJrFcto  := 0
										nVlrParcela := 0
										cTipParc    := ""
										cTaxa       := ""
										nMes        := 0
										aRet        := {}
										nVlrProRata   := 0
										nVlrJurosMora := 0
										nVlrMulta     := 0
										nVlrDescont   := 0
										
										// Titulos a receber
										If MV_PAR07 == 1 
										
											If SE1->E1_SALDO <> 0 .AND. (SE1->E1_VENCREA >= MV_PAR08 .AND. SE1->E1_VENCREA <= MV_PAR09)
												dHabite := iIf( !Empty(LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
	                                            
												aBaixas := {}				
												// Condicao de venda
												dbSelectArea("LJO")
												dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
												If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND )
	                                                
	                                                if ! lUltCM
														If left(dTos(SE1->E1_VENCREA),6) < left(dTos(dDatabase),6)
															// Busca a CM da prestacao da dataBase
															aVlrCM := GEMCmTit( LIX->(Recno()) ,GMPrevMonth(dDatabase,1) )
														Else
															// Busca a CM da prestacao da dataBase
															aVlrCM := GEMCmTit( LIX->(Recno()) ,dDatabase )
														Endif
												     else // sempre utiliza a ultima correcao do mes 
												        aVlrCM := GEMCmTit( LIX->(Recno()) ,dDatabase )
												     endif
														
													cTaxa := aVlrCM[1] // nome da taxa
													
													cTipParc := LJO->LJO_TPDESC // Tipo de Parcela
											
													If left(dtos(dDatabase),6) > left(dtos(dHabite),6)
														cTaxa := iIf( Empty(cTaxa) ,LJO->LJO_INDPOS ,cTaxa )
														nMes  := LJO->LJO_NMES2
													Else               
														cTaxa := iIf( Empty(cTaxa) ,LJO->LJO_IND ,cTaxa )
														nMes  := LJO->LJO_NMES1
													EndIf
													
													If Empty(SE1->E1_BAIXA)
													
														nVlrPrinc  := LIX->LIX_ORIAMO+aVlrCM[2] // Valor Principal do titulo Original + CM
														nVlrJrFcto := LIX->LIX_ORIJUR+aVlrCM[3] // Valor JUROS do titulo Original + CM
													
														nVlrParcela := nVlrPrinc + nVlrJrFcto
														
														cSituacao := STR0008  // EM ABERTO
														
														nPercJuros := LIT->LIT_JURMOR 
														nPercMulta := LIT->LIT_MULTA
														
													// Parcela com baixa parcial
													Else

														nVlrParcela := GEMCMSLd( LIX->(Recno()) ,SE1->E1_SALDO ,SE1->E1_BAIXA ,dDatabase ,LIT->LIT_EMISSA ,,dHabite )
														nVlrParcela := SE1->E1_SALDO+nVlrParcela

														nVlrPrinc  := nVlrParcela*(LIX->LIX_ORIAMO/(LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) // Valor Principal do titulo Original + CM
														nVlrJrFcto := nVlrParcela*(LIX->LIX_ORIJUR/(LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) // Valor JUROS do titulo Original + CM

														cSituacao := STR0009    // PARCIAL

														nPercJuros := LIT->LIT_JURMOR 
														nPercMulta := 0   
														
														If nVlrParcela <> SE1->E1_VALOR
															aBaixas := DadFinTit( SE1->E1_PREFIXO, SE1->E1_NUM ,SE1->E1_PARCELA ,SE1->E1_TIPO ,SE1->E1_CLIENTE ,SE1->E1_LOJA  )     														
														EndIf
														
													EndIf
														
													// calcula a Pro-Rata Dia de Atraso, Juros mora e Multa do titulo
													//
													aRet := t_GEMAtraCalc( nVlrPrinc ,SE1->E1_VENCREA ,cTaxa ,nMes ,LJO->LJO_DIACOR ,nPercJuros ,nPercMulta ,dDatabase ,LIT->LIT_JURTIP ,SE1->E1_BAIXA )

													nVlrProRata   := aRet[1] // Pro-Rata dia (CM diaria) por atraso na baixa do titulo 
													nVlrJurosMora := aRet[2] // Juros Mora dia por atraso na baixa do titulo
													nVlrMulta     := aRet[3] // Multa por atraso na baixa do titulo
													
													nVlrDescont   := SE1->E1_DECRESC //desconto

													RecLock(cTable ,.T.)
													(cTable)->LK3_CODEMP := LK3->LK3_CODEMP
													(cTable)->LK3_DESCRI := LK3->LK3_DESCRI
													(cTable)->A1_COD     := SE1->E1_CLIENTE
													(cTable)->A1_LOJA    := SE1->E1_LOJA
													(cTable)->A1_NOME    := SA1->A1_NOME
													(cTable)->LIQ_COD    := LIQ->LIQ_COD
													(cTable)->E1_BAIXA   := SE1->E1_BAIXA
													(cTable)->E1_VENCREA := SE1->E1_VENCREA
													(cTable)->NUMPARC    := LIX->LIX_ITNUM + "/" + STRZERO(LJO->LJO_NUMPAR,TamSX3("LJO_NUMPAR")[1]) + "-" + LJO->LJO_ITEM
													(cTable)->TIPPARC    := cTipParc
													(cTable)->TAXA       := cTaxa
													(cTable)->VLRPRINC   := nVlrPrinc
													(cTable)->VLRUNID    := nVlrPrinc * nRateio
													(cTable)->VLRJRFCT   := nVlrJrFcto * nRateio
													(cTable)->VLRPENAL   := (nVlrProRata+nVlrJurosMora+nVlrMulta) * nRateio
													(cTable)->VLRDESC    := nVlrDescont * nRateio
													IF Len(aBaixas)>0
														For nCnt:= 1 to Len(aBaixas)
															(cTable)->VLRPARC    := (aBaixas[nCnt][02]+aBaixas[nCnt][03]+aBaixas[nCnt][04] ;
														  		                    + aBaixas[nCnt][05]+aBaixas[nCnt][06]-aBaixas[nCnt][07]) * nRateio
													    Next nCnt													
													else
														(cTable)->VLRPARC := 0													
													EndIF    
													 
													(cTable)->VLRCORR    := (nVlrParcela+(nVlrProRata+nVlrJurosMora+nVlrMulta)-nVlrDescont) * nRateio
													(cTable)->SITUAC     := cSituacao
													MsUnLock()

												EndIf
											EndIf

										// Titulos recebidos 
										ElseIf MV_PAR07 == 2

											If (SE1->E1_BAIXA >= MV_PAR08 .AND. SE1->E1_BAIXA <= MV_PAR09)

												dHabite := iIf( !Empty(LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )
	
												// Condicao de venda
												dbSelectArea("LJO")
												dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
												If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND )
	
													If left(dtos(SE1->E1_BAIXA),6) > left(dtos(dHabite),6)
														cTaxa := LJO->LJO_INDPOS
													Else               
														cTaxa := LJO->LJO_IND
													EndIf
													
													aBaixas := DadFinTit( SE1->E1_PREFIXO, SE1->E1_NUM ,SE1->E1_PARCELA ,SE1->E1_TIPO ,SE1->E1_CLIENTE ,SE1->E1_LOJA  )
                                                    
													For nCnt := 1 To Len(aBaixas)
														nVlrPrinc  := aBaixas[nCnt][02]*(LIX->LIX_ORIAMO/(LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) // Valor Principal do titulo Original
														nVlrJrFcto := aBaixas[nCnt][02]*(LIX->LIX_ORIJUR/(LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) // Valor JUROS do titulo Original
														nVlrPrinc  += aBaixas[nCnt][03]*(LIX->LIX_ORIAMO/(LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) // CM valor Principal do titulo Original
														nVlrJrFcto += aBaixas[nCnt][03]*(LIX->LIX_ORIJUR/(LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) // CM Valor JUROS do titulo Original 
													
														nVlrAtual := 0
														nVlrAtual += GEMCMSLd( LIX->(Recno()) ,aBaixas[nCnt][2]+aBaixas[nCnt][3] ,aBaixas[nCnt][1] ,dDatabase ,LIT->LIT_EMISSA ,.T. ,dHabite)
														
														For nCnt2 := 4 To 7
															nVlrAtual += GEMCMSLd( LIX->(Recno()) ,aBaixas[nCnt][nCnt2] ,aBaixas[nCnt][1] ,dDatabase ,LIT->LIT_EMISSA ,.T. ,dHabite)
														Next nCnt2
														
														If nVlrPrinc < 0
															nVlrPrinc := 0
														EndIf 
														If nVlrJrFcto < 0 
															nVlrJrFcto := 0
														EndIf 
														
														cSituacao := STR0009  //parcial

														If nCnt == Len(aBaixas) .AND. SE1->E1_SALDO == 0
															cSituacao := STR0010   // liquidado
														EndIf
														
														RecLock(cTable ,.T.)
														(cTable)->LK3_CODEMP := LK3->LK3_CODEMP
														(cTable)->LK3_DESCRI := LK3->LK3_DESCRI
														(cTable)->A1_COD     := SA1->A1_COD
														(cTable)->A1_LOJA    := SA1->A1_LOJA
														(cTable)->A1_NOME    := SA1->A1_NOME
														(cTable)->LIQ_COD    := LIQ->LIQ_COD
														(cTable)->E1_BAIXA   := aBaixas[nCnt][01]
														(cTable)->E1_VENCREA := SE1->E1_VENCREA
														(cTable)->NUMPARC    := LIX->LIX_ITNUM + "/" + STRZERO(LJO->LJO_NUMPAR,TamSX3("LJO_NUMPAR")[1]) + "-" + LJO->LJO_ITEM
														(cTable)->TIPPARC    := LJO->LJO_TPDESC
														(cTable)->TAXA       := cTaxa
														(cTable)->VLRPRINC   := nVlrPrinc
														(cTable)->VLRUNID    := nVlrPrinc * nRateio
														(cTable)->VLRJRFCT   := nVlrJrFcto * nRateio
														(cTable)->VLRPENAL   := (aBaixas[nCnt][04]+aBaixas[nCnt][05]+aBaixas[nCnt][06]) * nRateio
														(cTable)->VLRDESC    := aBaixas[nCnt][07] * nRateio
														(cTable)->VLRPARC    := (aBaixas[nCnt][02]+aBaixas[nCnt][03]+aBaixas[nCnt][04] ;
														                      + aBaixas[nCnt][05]+aBaixas[nCnt][06]-aBaixas[nCnt][07]) * nRateio
														(cTable)->VLRCORR    := ((cTable)->VLRPARC+nVlrAtual) * nRateio
														(cTable)->SITUAC     := cSituacao
														MsUnLock()
														                 
													Next nCnt
												EndIf
											EndIf
										EndIf
									EndIf
									// detalhes do titulo a receber
									dbSelectArea("LIX")
									dbSkip()
								EndDo
							EndIf
						EndIf
				    EndIf
				    
					// itens do contrato
					dbSelectArea("LIU")
					dbSkip()
				EndDo
				
			EndIf
			
			// Unidade
			dbSelectArea("LIQ")
			dbSkip()
		EndDo
		
		// Empreendimento
		dbSelectArea("LK3")
		dbSkip()
	EndDo

RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ GMR070Imp   ³ Autor ³ Reynaldo Miyashita  ³ Data ³01.01.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a impressao                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GMR070Imp(cPar1, nPar1, aPar1, nPar2)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cPar1 = Nome do programa chamador                            ³±±
±±³          ³nPar1 = Linha para impressao                                 ³±±
±±³          ³aPar1 = Matriz com a estrutura do orcamento                  ³±±
±±³          ³ { { { CODIGO DA EDT/TAREFA, DESCRICAO, RECNO, TABELA } }    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GMR070Imp(lEnd ,wnRel ,cTable ,aReturn )
Local nCntRegua := 0
Local aColsPos  := {}
Local aTotGrupo := {0,0,0,0,0,0}
Local aTotEmpr  := {0,0,0,0,0,0}
Local aTotGeral := {0,0,0,0,0,0}
Local cSubTit1  := ""
Local cSubTit2  := ""
Local uKey      := NIL
Local nWidth    := 0
Local lImpGrp   := .F.
Local lImpEmpr  := .F.

Local cSubTit := ""
Local cCabec2 := ""
Local nTipo := If(aReturn[4]==1,15,18)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os dados.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( (cTable)->(lastrec())>0 )
	
		SetDefault(aReturn,"")
	
		SetRegua(RecCount())
		
		If MV_PAR07 == 1 
			Titulo := STR0011    //"Titulos a receber por empreendimento"
		Else
			Titulo := STR0012    //"Titulos a recebidos por empreendimento"
		EndIf

		cSubTit := Padr(STR0013 + dtoc(MV_PAR08)+ STR0014 +dtoc(MV_PAR09) ,Limite/2)     //"Periodo: " ## ate 
		cSubTit += STR0015 + SeekTitle( MV_PAR10 )     // ordenado por:
		
		aColPos := { 000 ,010 ,041 ,054 ,063 ;
		            ,072 ,083 ,094 ,101 ,116 ;
		            ,131 ,146 ,161 ,176 ,191 ;
		            ,206 }
	            
		(cTable)->(dbGoTop())
		cCodEmpr := ""
		uKey     := NIL
		cCampo   := (cTable)->(&(SeekOrder(MV_PAR10)))
		uKey     := NIL
		
		While (cTable)->(!Eof())		
		
			IncRegua(STR0016) //"Imprimindo..."
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do cabecalho do relatorio. . .                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLi > 60 
				nLi := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLi++
				@ nLi,000 PSAY cSubTit
				nLi++
				@ nLi,000 PSAY __PrtThinLine()
				nLi++
			EndIf

		    //
		    // Imprime o cabecalho do Empreendimento
		    //
			If cCodEmpr != (cTable)->LK3_CODEMP
				nLi++
				@ nLi,000 PSAY STR0017 + (cTable)->LK3_CODEMP  //"Empreendimento: "
				@ nLi,050 PSAY STR0018     + (cTable)->LK3_DESCRI  // Descricao :
				nLi++
				@ nLi,000 PSAY __PrtThinLine()
				nLi++
					
				cCodEmpr   := (cTable)->LK3_CODEMP
				cDescrEmpr := (cTable)->LK3_DESCRI
				uKey     := NIL
				lImpEmpr := .F.
		  	EndIf

			If uKey != cCampo
				nLi++
				@ nLi,aColPos[01] PSAY STR0019 //cliente
				@ nLi,aColPos[02] PSAY STR0020     //nome
				@ nLi,aColPos[03] PSAY STR0021  // unidade
				@ nLi,aColPos[04] PSAY STR0022   // vencto
				@ nLi,aColPos[05] PSAY STR0023    // baixa
				@ nLi,aColPos[06] PSAY STR0024   //parcela   
				@ nLi,aColPos[07] PSAY STR0025     // tipo parc.
				@ nLi,aColPos[08] PSAY STR0026      // indice
				@ nLi,aColPos[09] PSAY PadL(STR0027 ,14)    // principal
				@ nLi,aColPos[10] PSAY PadL(STR0028 ,14)    // vlr unid
				@ nLi,aColPos[11] PSAY PadL(STR0029 ,14)   // juros fcto
				@ nLi,aColPos[12] PSAY PadL(STR0030 ,14)    // penalidade
				@ nLi,aColPos[13] PSAY PadL(STR0031 ,14)      // desconto
				@ nLi,aColPos[14] PSAY PadL(STR0032 ,14)    // valor pago
				@ nLi,aColPos[15] PSAY PadL(STR0033 ,14)  // vlr corrigido
				@ nLi,aColPos[16] PSAY STR0034     // situação
				nLi++
				@ nLi,000 PSAY __PrtThinLine()
				nLi++
				
				uKey := cCampo
				lImpGrp  := .F.
				
			EndIf

			@ nLi,aColPos[01] PSAY (cTable)->A1_COD+"-"+(cTable)->A1_LOJA
			@ nLi,aColPos[02] PSAY PadR(Alltrim((cTable)->A1_NOME),30)
			@ nLi,aColPos[03] PSAY (cTable)->LIQ_COD
			@ nLi,aColPos[04] PSAY Transform((cTable)->E1_VENCREA ,x3Picture("E1_VENCREA"))
			@ nLi,aColPos[05] PSAY Transform((cTable)->E1_BAIXA   ,x3Picture("E1_BAIXA"))
			@ nLi,aColPos[06] PSAY (cTable)->NUMPARC
			@ nLi,aColPos[07] PSAY (cTable)->TIPPARC
			@ nLi,aColPos[08] PSAY (cTable)->TAXA
			@ nLi,aColPos[09] PSAY Transform((cTable)->VLRPRINC ,"@E 999,999,999.99")
			@ nLi,aColPos[10] PSAY Transform((cTable)->VLRUNID  ,"@E 999,999,999.99")
			@ nLi,aColPos[11] PSAY Transform((cTable)->VLRJRFCT ,"@E 999,999,999.99")
			@ nLi,aColPos[12] PSAY Transform((cTable)->VLRPENAL ,"@E 999,999,999.99")
			@ nLi,aColPos[13] PSAY Transform((cTable)->VLRDESC  ,"@E 999,999,999.99")
			@ nLi,aColPos[14] PSAY Transform((cTable)->VLRPARC  ,"@E 999,999,999.99")
			@ nLi,aColPos[15] PSAY Transform((cTable)->VLRCORR  ,"@E 999,999,999.99")
			@ nLi,aColPos[16] PSAY (cTable)->SITUAC
			nLi++

			// Totaliza os valores por Grupo
			aTotGrupo[1] += (cTable)->VLRUNID
			aTotGrupo[2] += (cTable)->VLRJRFCT
			aTotGrupo[3] += (cTable)->VLRPENAL
			aTotGrupo[4] += (cTable)->VLRDESC
			aTotGrupo[5] += (cTable)->VLRPARC
			aTotGrupo[6] += (cTable)->VLRCORR

			(cTable)->(dbSkip())
			cCampo   := (cTable)->(&(SeekOrder(MV_PAR10)))

			If uKey != cCampo                         
				SubTotGrp( uKey, aColPos ,aTotGrupo ,aTotEmpr )
				lImpGrp  := .T.
			EndIf
			

			If cCodEmpr != (cTable)->LK3_CODEMP
			
				If !lImpGrp
					SubTotGrp( uKey, aColPos ,aTotGrupo ,aTotEmpr )
				EndIf
				SubTotEmpr( uKey ,aColPos ,aTotEmpr ,aTotGeral )
				lImpEmpr := .T.
	
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If LastKey() == 27
				@nLi,00 PSAY STR0035    //"*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
	
		EndDo
		
		If !lImpEmpr 
			SubTotEmpr( uKey ,aColPos ,aTotEmpr ,aTotGeral )
		EndIf
				
		@ nLi,000 PSAY __PrtThinLine()
		nLi++
		@ nLi,aColPos[01] PSAY STR0036    // total geral
	
		@ nLi,aColPos[10] PSAY Transform(aTotGeral[01] ,"@E 999,999,999.99")
		@ nLi,aColPos[11] PSAY Transform(aTotGeral[02] ,"@E 999,999,999.99")
		@ nLi,aColPos[12] PSAY Transform(aTotGeral[03] ,"@E 999,999,999.99")
		@ nLi,aColPos[13] PSAY Transform(aTotGeral[04] ,"@E 999,999,999.99")
		@ nLi,aColPos[14] PSAY Transform(aTotGeral[05] ,"@E 999,999,999.99")
		@ nLi,aColPos[15] PSAY Transform(aTotGeral[06] ,"@E 999,999,999.99")
		nLi++
		nLi++
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a execucao do relatorio...                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		SET DEVICE TO SCREEN
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se impressao em disco, chama o gerenciador de impressao...          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If aReturn[5]==1
			dbCommitAll()
			SET PRINTER TO
			OurSpool(wnrel)
		Endif
		
		MS_FLUSH()
		
	EndIf
	
Return( .T. )

/*
Imprime o subtotal por grupo
*/
Static Function SubTotGrp( uKey, aColPos ,aTotGrupo ,aTotEmpr )
Local cKey := ""
			
	If ValType(uKey) == "D"
		cKey := dtoc(uKey)
	ElseIf ValType(uKey) == "N"
		cKey := Transform( uKey ,x3Picture("E1_SALDO") )
	Else
		cKey := uKey
	EndIf

	nLi++
	@ nLi,000 PSAY __PrtThinLine()
	nLi++
	@ nLi,aColPos[01] PSAY STR0037 + SeekTitle( MV_PAR10 ) + ": " + cKey    // total por

	@ nLi,aColPos[10] PSAY Transform(aTotGrupo[01] ,"@E 999,999,999.99")
	@ nLi,aColPos[11] PSAY Transform(aTotGrupo[02] ,"@E 999,999,999.99")
	@ nLi,aColPos[12] PSAY Transform(aTotGrupo[03] ,"@E 999,999,999.99")
	@ nLi,aColPos[13] PSAY Transform(aTotGrupo[04] ,"@E 999,999,999.99")
	@ nLi,aColPos[14] PSAY Transform(aTotGrupo[05] ,"@E 999,999,999.99")
	@ nLi,aColPos[15] PSAY Transform(aTotGrupo[06] ,"@E 999,999,999.99")
	nLi++
	nLi++
		
	aTotEmpr[1] += aTotGrupo[1]
	aTotEmpr[2] += aTotGrupo[2]
	aTotEmpr[3] += aTotGrupo[3]
	aTotEmpr[4] += aTotGrupo[4]
	aTotEmpr[5] += aTotGrupo[5]
	aTotEmpr[6] += aTotGrupo[6]
	
	aTotGrupo[1] := 0.00
	aTotGrupo[2] := 0.00
	aTotGrupo[3] := 0.00
	aTotGrupo[4] := 0.00
	aTotGrupo[5] := 0.00
	aTotGrupo[6] := 0.00
Return( .T. )

/*
Imprime o subtotal por emprendimento
*/
Static Function SubTotEmpr( uKey ,aColPos ,aTotEmpr ,aTotGeral )

	@ nLi,000 PSAY __PrtThinLine()
	nLi++
	@ nLi,aColPos[01] PSAY STR0038 + cCodEmpr + " - "+ cDescrEmpr    // total empreendimento

	@ nLi,aColPos[10] PSAY Transform(aTotEmpr[01] ,"@E 999,999,999.99")
	@ nLi,aColPos[11] PSAY Transform(aTotEmpr[02] ,"@E 999,999,999.99")
	@ nLi,aColPos[12] PSAY Transform(aTotEmpr[03] ,"@E 999,999,999.99")
	@ nLi,aColPos[13] PSAY Transform(aTotEmpr[04] ,"@E 999,999,999.99")
	@ nLi,aColPos[14] PSAY Transform(aTotEmpr[05] ,"@E 999,999,999.99")
	@ nLi,aColPos[15] PSAY Transform(aTotEmpr[06] ,"@E 999,999,999.99")
	nLi++
	nLi++

	aTotGeral[1] += aTotEmpr[1] 
	aTotGeral[2] += aTotEmpr[2] 
	aTotGeral[3] += aTotEmpr[3] 
	aTotGeral[4] += aTotEmpr[4] 
	aTotGeral[5] += aTotEmpr[5] 
	aTotGeral[6] += aTotEmpr[6] 

	aTotEmpr[1] := 0.00
	aTotEmpr[2] := 0.00
	aTotEmpr[3] := 0.00
	aTotEmpr[4] := 0.00
	aTotEmpr[5] := 0.00
	aTotEmpr[6] := 0.00
Return( .T. )

Static Function SeekOrder( nOrder )
Local cOrder := ""

	If nOrder <= Len(aIndex)
		cOrder := aIndex[nOrder][1]
	EndIf

Return( cOrder )

Static Function SeekIndex( nOrder )
Local cIndex := ""

	If nOrder <= Len(aIndex)
		cIndex := aIndex[nOrder][2]
	EndIf

Return( cIndex )

Static Function SeekTitle( nOrder )
Local cName := ""

	If nOrder <= Len(aIndex)
		cName := aIndex[nOrder][3]
	EndIf

Return( cName )

Static Function x3Titulo2( cCampo )
Local cTitulo  := ""
Local aArea    := GetArea()
Local aAreaSX3 := SX3->(GetArea())

	dbSelectArea("SX3")
	dbSetOrder(2) // X3_FILIAL+X3_CAMPO
	If dbSeek(cCampo)
		cTitulo := x3Titulo()
	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)

Return( cTitulo )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DadFinTit ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 02.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 25.09.06 ³Reynaldo Miyash³ Criação                                    ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DadFinTit( cPrefixo, cNumero ,cParcela ,cTipo ,cCliente ,cLoja )

Local aTipoDoc   := {}
Local nCntSE5    := 0
Local lEstornada := .F.
Local lBaixaAbat := .F.
Local nRecAtu    := 0
Local cSequencia := ""
Local cTipoEst   := "ES"
Local aBaixas    := {}
//
// se numliq for preenchido e emissao for maior que a database, naum considera
//
If !(!Empty(SE1->E1_NUMLIQ) .AND. SE1->E1_EMISSAO > dDatabase)
	aTipoDoc := {"BA" ,"VL"}
	
	For nCntSE5 := 1 to Len(aTipoDoc)
		//
		// Busca no SE5, as baixas do titulo a receber tanto baixa com/sem mov. bancario
		//
		dbSelectArea("SE5")
		dbSetOrder(2) // E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
		dbSeek(xFilial("SE5")+aTipoDoc[nCntSE5]+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
		While SE5->(!Eof()) .AND. ;
		      SE5->E5_FILIAL+SE5->E5_TIPODOC  +SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO ;
		      == SE1->E1_FILIAL+aTipoDoc[nCntSE5]+SE1->E1_PREFIXO+SE1->E1_NUM   +SE1->E1_PARCELA+SE1->E1_TIPO
	
			If SE5->E5_CLIFOR+SE5->E5_LOJA == SE1->E1_CLIENTE+SE1->E1_LOJA
				lEstornada := .F.
				lBaixaAbat := .F.
				nRecAtu    := SE5->(recno())
				cSequencia := SE5->E5_SEQ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica se existe uma baixa cancelada para esta baixa efetuada       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SE5->(MsSeek(xFilial("SE5")+"ES"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
				cTipoEst := "ES"
	
				While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .and. ;
				            SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO ;
				         == cTipoEst       +SE1->E1_PREFIXO+SE1->E1_NUM   +SE1->E1_PARCELA+SE1->E1_TIPO
	
					If SE5->E5_CLIFOR != SE1->E1_CLIENTE .OR. SE5->E5_LOJA != SE1->E1_LOJA
						SE5->(dbSkip())
						Loop
					EndIF
		
					IF SE5->E5_SEQ != cSequencia
						SE5->(dbSkip())
						Loop
					EndIF
		
					If SE5->E5_MOTBX == "FAT"
						dbSkip()
						Loop
					Endif
	
					//ÚBaixa NormalÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Sera estornado se for exatamente a mesma sequencia, carteira          ³
					//³contraria e nao for um adiantamento ou credito. (Titulo Normal)       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SE5->E5_SEQ == cSequencia .And. SE5->E5_RECPAG == "P" .and. !SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG
						lEstornada := .T.
						Exit
					EndIf
		
					//ÚÄBaixa de AdiantamentoÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Sera estornado se for exatamente a mesma sequencia, carteira          ³
					//³contraria e for um adiantamento ou credito. (Titulo de Credito        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SE5->E5_SEQ == cSequencia .And. SE5->E5_RECPAG == "R" .and. SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG
						lEstornada := .T.
						Exit
					EndIf
					SE5->( dbSkip() )
				EndDo
				SE5->(dbSetOrder(2)) // E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
				SE5->(dbGoTo(nRecAtu))
				If lEstornada
					lEstornada := .F.
					lBaixaAbat := .F.
					SE5->(dbSkip())
					Loop
				EndIf
	
				If (SE5->E5_TIPODOC == "VL") .OR. (SE5->E5_TIPODOC == "BA") 
	
		    		aAdd( aBaixas ,{ SE5->E5_DATA ;
		    		                ,SE5->E5_VALOR-SE5->E5_VLMULTA-SE5->E5_VLJUROS ;
		    		                ,SE5->E5_CM1 ;
		    		                ,SE5->E5_PRORATA ;
		    		                ,SE5->E5_VLJUROS-iIf(SE5->E5_CM1>0,SE5->E5_CM1,0) -iIf(SE5->E5_PRORATA>0,SE5->E5_PRORATA,0) ;
		    		                ,SE5->E5_VLMULTA ;
		    		                ,SE5->E5_VLDESCO-iIf(SE5->E5_CM1<0,SE5->E5_CM1*-1,0) -iIf(SE5->E5_PRORATA<0,SE5->E5_PRORATA*-1,0) ;
		    		                })
/*		    		                
					aAdd( aBaixas ,{ E5_DATA ;
					                ,SE5->E5_VALOR-SE5->E5_VLMULTA-SE5->E5_VLJUROS ;
					                ,SE5->E5_CM1 ;
					                ,SE5->E5_PRORATA ;
								    ,SE5->E5_VLMULTA ;
								    ,SE5->E5_VLJUROS-SE5->E5_CM1-SE5->E5_PRORATA ;
					                ,SE5->E5_VLDESCO })
*/		    		                
	
				EndIf
	
		    EndIf
	    
	    	dbSelectArea("SE5")
	    	dbSkip()
	    EndDo
	
	Next nCntSE5
EndIf

Return( aBaixas )
