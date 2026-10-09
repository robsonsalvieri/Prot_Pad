
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMR050   ºAutor  ³Reynaldo Miyashita  º Data ³  02/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de ranking de inadimplentes por empreendimento   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "PROTHEUS.CH"

#define _CABECALHO_FONTE_TAMANHO_ 2
#define _CORPO_FONTE_TAMANHO_     1

Template Function GEMR050()
Local aArea	 := GetArea()
Local aDados := {}
Local lOk	 := .F.
Local lEnd

Private nLin    := 280

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

AjustaSX1()

oPrint := PcoPrtIni("Ranking de Clientes Inadimplentes",.F.,2,,@lOk,"GMR050")

If lOk
	Processa({||GMR050Proc( @aDados)},"Processando...")
	RptStatus( {|lEnd| GMR050Imp(@lEnd,oPrint,aDados)})
	PcoPrtEnd(oPrint)
EndIf

RestArea(aArea)
Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GMR050Proc³ Autor ³ Reynaldo Miyashita    ³ Data ³ 25.09.06 ³±±
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
/*/
Static Function GMR050Proc( aDados )
Local aArea     := GetArea()
Local aLIUDados := {}
Local aSA1Dados := {}
Local aSE1Dados := {}
Local nPosUni   := 0
Local nPosEmpr  := 0
Local nPosStru  := 0
Local nPos      := 0
Local nCntRegua := 0
Local nVlrCM    := 0
Local cTaxa     := ""
Local nMes      := 0
Local dUltBaixa := stod("") 
Local lUltCM    := GetNewPar("MV_GEMULTC",.F.) // verifica se utiliza a ultima correcao monetaria.

Default aDados := {}

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
						If LIT->LIT_STATUS == "1"

							// Cadastro de cliente
							dbSelectArea("SA1")
							dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
							If dbSeek(xFilial("SA1")+LIT->LIT_CLIENT+LIT->LIT_LOJA)
								    
								aSE1Dados := { 0 ; // Valor em atraso
								              ,0 } // qtd de parcelas em atraso
					              
								// Detalhes dos titulos a receber
								dbSelectArea("LIX")
								dbSetOrder(4) // LIX_FILIAL+LIX_NCONTR+LIX_CODCND+LIX_ITCND
								dbSeek(xFilial("LIX")+LIT->(LIT_NCONTR+LIT_COND))
								While LIX->(!Eof()) .AND. ;
							 	      xFilial("LIX")+LIT->(LIT_NCONTR+LIT_COND) == LIX->(LIX_FILIAL+LIX_NCONTR+LIX_CODCND)

									IncProc() 
									nCntRegua++
									If nCntRegua == 100
										ProcRegua(100)
										nCntRegua := 0
									EndIf

									dHabite := iIf( !Empty(LIQ->LIQ_HABITE) ,LIQ->LIQ_HABITE ,LIQ->LIQ_PREVHB )

									// Condicao de venda
									dbSelectArea("LJO")
									dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
									If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND )
										If left(dtos(dDatabase),6) > left(dtos(dHabite),6)
											cTaxa := LJO->LJO_INDPOS
											nMes  := LJO->LJO_NMES2
										Else               
											cTaxa := LJO->LJO_IND
											nMes  := LJO->LJO_NMES1
	
										EndIf
										
										// Titulos a receber
										dbSelectArea("SE1")
										dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
										If dbSeek(xFilial("SE1")+LIX->LIX_PREFIXO+LIX->LIX_NUM+LIX->LIX_PARCEL+LIX->LIX_TIPO)
	                                        
											If SE1->E1_SALDO <> 0 .and. (dDataBase > SE1->E1_VENCREA )
	
												If Empty(SE1->E1_BAIXA)
		                                                    
													if ! lUltCM
														If left(dTos(SE1->E1_VENCREA),6) < left(dTos(dDatabase),6)
															// Busca a CM da prestacao da dataBase
															aVlrCM := GEMCmTit( LIX->(Recno()) ,GMPrevMonth(dDatabase,1) )
														Else
															// Busca a CM da prestacao da dataBase
															aVlrCM := GEMCmTit( LIX->(Recno()) ,dDatabase )
														EndIf
													else // parametro para pegar sempre a ultima correcao ligado
														// Busca a CM da prestacao da dataBase
														aVlrCM := GEMCmTit( LIX->(Recno()) ,dDatabase )
													endif
														
													If !Empty(aVlrCM[1])
														cTaxa := aVlrCM[1]
													EndIf
													
													//
													// valor do titulo corrigido
													//
													nVlrParcela := LIX->LIX_ORIAMO+aVlrCM[2]
													nVlrParcela += iIf( LIX->LIX_JURFCT ,0 ,LIX->LIX_ORIJUR+aVlrCM[3] ) // juros fcto
													dUltBaixa := SE1->E1_VENCREA
	                                            Else
													// Valor recebido pelo Titulo na data da baixa
				   									nVlrCM := GEMCMSLd( LIX->(Recno()) ,SE1->E1_SALDO ,SE1->E1_BAIXA ,dDatabase ,LIT->LIT_EMISSA ,,dHabite )
			                                    	nVlrParcela := SE1->E1_SALDO+nVlrCM
													dUltBaixa := SE1->E1_BAIXA
												EndIf
												dVencto := SE1->E1_VENCREA

												//
												// Parcela Atrasada
												//
												nPorcJurMor := LIT->LIT_JURMOR
												nPorcMulta  := LIT->LIT_MULTA
											
												//
												// calcula a Pro-Rata Dia de Atraso, Juros mora e Multa do titulo
												//
												aRet := t_GEMAtraCalc( nVlrParcela ,dVencto ,cTaxa ,nMes ,LJO->LJO_DIACOR ,nPorcJurMor ,nPorcMulta ,dDatabase ,LIT->LIT_JURTIP ,dUltBaixa )
												
						     					aSE1Dados[1] += nVlrParcela
						     					aSE1Dados[1] += aRet[1]
						     					aSE1Dados[1] += aRet[2]
						     					aSE1Dados[1] += aRet[3]
						     					aSE1Dados[2]++       
											EndIf
										EndIf
									EndIf
									// detalhes do titulo a receber
									dbSelectArea("LIX")
									dbSkip()
								EndDo
						        
								If aSE1Dados[1] >0
									// Empreendimento
									If (nPosEmpr := aScan( aDados ,{|x| x[1] == LK3->LK3_CODEMP } )) <= 0
										aAdd( aDados ,{ LK3->LK3_CODEMP ; 
										               ,LK3->LK3_DESCRI ;
										               ,{} } )
										nPosEmpr := len(aDados)

									EndIf
									
									// Unidades
									aAdd( aDados[nPosEmpr ,3] ,{ SA1->A1_COD     ;
									                            ,SA1->A1_LOJA    ;
									                            ,SA1->A1_NOME    ;
									                            ,LIU->LIU_CODEMP ;
									                            ,aSE1Dados[1] ;
									                            ,aSE1Dados[2] ;
									                           } )
								EndIf
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
	
	For nPosEmpr := 1 To Len(aDados)
	
		aSort( aDados[nPosEmpr ,3] ,,,{|x,y| x[5]>y[5] })
		For nPosUni := 1 To Len(aDados[nPosEmpr ,3])
			aDados[nPosEmpr ,03 ,nPosUni ,5 ] := Transform( aDados[nPosEmpr ,03 ,nPosUni ,5 ] ,x3Picture("E1_SALDO")   ) 
			aDados[nPosEmpr ,03 ,nPosUni ,6 ] := Transform( aDados[nPosEmpr ,03 ,nPosUni ,6 ] ,x3Picture("LJO_NUMPAR") ) 
		Next nPosUni
	Next nPosEmpr			
RestArea(aArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GMR050IMP ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 25.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime as informacoes para o relatorio                    ³±±
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
Static Function GMR050Imp(lEnd,oPrint,aDados)
Local nLin      := 0
Local nCntStru  := 0
Local nCount    := 0
Local aTamCols  := {}
Local aColsIni  := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime os dados.             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Len(aDados) > 0)
		aTamCols := Array(2)
		aTamCols[1]	:= { 600,1000 }
		aTamCols[2]	:= { 150,75,600,200,500 }
		
		aAdd( aColsINI ,TamToCols(aTamCols[1]) )
		aAdd( aColsINI ,TamToCols(aTamCols[2]) )
		
		nLin := 0
		
	    //
	    // Imprime o cabecalho do relatorio
	    // 
		nLin:=280
		PcoPrtCab(oPrint)

		For nCntStru := 1 To Len(aDados)
		
			PcoPrtCol(aColsINI[1],.T.,len(aColsINI[1]))
			// Cabecalho 
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,"Codigo"     ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,"Descrição"  ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))
			nLin+=25
				
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aDados[nCntStru ,01] ,oPrint,2,_CORPO_FONTE_TAMANHO_ )
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aDados[nCntStru ,02] ,oPrint,2,_CORPO_FONTE_TAMANHO_ )
			
			nLin+=100
		
			// Definicao das colunas do Cabecalho do relatorio 
			PcoPrtCol(aColsINI[2],.T.,len(aColsINI[2]))
	
			// Cabecalho sobre cliente, loja e nome do cliente
			PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,"Cliente"        ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))
			PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,"Loja"           ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))
			PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,"Nome"           ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))
			PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),30,"Unidade"        ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))
			PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),30,"Inadimplencia"  ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))
			PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),30,"Qtd. Atrasados" ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))
			nLin+=25
			
			For nCount := 1 To Len(aDados[nCntStru ,03])
				PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aDados[nCntStru ,03 ,nCount ,01],oPrint,2,_CORPO_FONTE_TAMANHO_ )      //"Cliente"
				PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aDados[nCntStru ,03 ,nCount ,02],oPrint,2,_CORPO_FONTE_TAMANHO_ )      //"Loja"
				PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,aDados[nCntStru ,03 ,nCount ,03],oPrint,2,_CORPO_FONTE_TAMANHO_ )      //"Nome"
				PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),50,aDados[nCntStru ,03 ,nCount ,04],oPrint,2,_CORPO_FONTE_TAMANHO_ )      //"Unidade"
				PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),50,aDados[nCntStru ,03 ,nCount ,05],oPrint,2,_CORPO_FONTE_TAMANHO_,,,.T.) //"Inadimplencia"
				PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),50,aDados[nCntStru ,03 ,nCount ,06],oPrint,2,_CORPO_FONTE_TAMANHO_ )      //"Atraso"
				nLin+=50
				If PcoPrtLim(nLin)
					nLin:=280
					PcoPrtCab(oPrint)
				EndIf
				
			Next nCount
			
			nLin+=50

		Next nCount
		
	EndIf
	
Return( .T. )
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TamToCols ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 02.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Define o inicio de impressao de cada coluna                 ³±±
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
Static Function TamToCols( aTamCols ,nLeft, nRight )

Local aRetorno := {}
Local nCount   := 0
Local nCol     := 0

Default nLeft  := 10
Default nRight := 10

	aAdd( aRetorno ,nLeft )
	nCol := nLeft

	For nCount := 1 to len( aTamCols )
	
		nCol += aTamCols[nCount]
		aAdd( aRetorno ,nCol )
	
	Next nCount
	aAdd( aRetorno ,nCol )

Return( aRetorno )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AjustaSX1 ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 02.10.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza a tabela SX1 do relatorio                          ³±±
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
Static Function AjustaSX1()

Local cAlias	:= Alias()
Local aCposSX1	:= {}
Local aRegs		:= {}
Local nX 		:= 0
Local nJ		:= 0
Local cPerg		:= PadR ( "GMR050", Len( SX1->X1_GRUPO ) )

aCposSX1 := {"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
             "X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEF02","X1_DEFSPA1",;
             "X1_DEFENG1","X1_VAR02","X1_DEFSPA2","X1_DEFENG2",;
             "X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_F3","X1_PYME","X1_CNT01"}

aAdd(aRegs,{"01","Empreendimento de? " ,"","","mv_ch1","C",TamSX3("LK3_CODEMP")[1]   ,00,0,"G","","MV_PAR01","","","","","","","","","","","","LK3","",""})
aAdd(aRegs,{"02","Empreendimento ate?" ,"","","mv_ch2","C",TamSX3("LK3_CODEMP")[1]   ,00,0,"G","","MV_PAR02","","","","","","","","","","","","LK3","",""})

dbSelectArea("SX1")
dbSetOrder(1) // X1_GRUPO+X1_ORDEM
For nX := 1 to Len(aRegs)
	If !(dbSeek(cPerg+aRegs[nX][1]))
		RecLock("SX1",.T.)
		Replace X1_GRUPO with cPerg
		For nJ := 1 to Len(aCposSX1)
			If FieldPos(Alltrim(aCposSX1[nJ])) > 0
				FieldPut(FieldPos(Alltrim(aCposSX1[nJ])),aRegs[nX][nJ])
			EndIf
		Next nJ
		MsUnlock()
	EndIf		
Next

dbSelectArea(cAlias)
Return