#INCLUDE "protheus.ch"
#INCLUDE "gemr040.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GEMR040   ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 25.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Resumo de venda                                             ³±±
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
#INCLUDE "protheus.ch"

#define _CABECALHO_FONTE_TAMANHO_ 2
#define _CORPO_FONTE_TAMANHO_     1

Template Function GEMR040()
Local aArea		:= GetArea()
Local aDados    := {}
Local lOk		:= .F.
Local lEnd

Private nLin    := 280

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

AjustaSX1()

oPrint := PcoPrtIni(STR0001,.F.,2,,@lOk,"GMR040")  //"Resumo de Venda"

If lOk
	Processa({||GMR040Proc(@aDados)},STR0002)
	RptStatus( {|lEnd| GMR040Imp(@lEnd,oPrint,aDados)})
	PcoPrtEnd(oPrint)
EndIf

RestArea(aArea)
Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GMR040Proc³ Autor ³ Reynaldo Miyashita    ³ Data ³ 25.09.06 ³±±
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
Static Function GMR040Proc( aDados )
Local aArea     := GetArea()
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local aAreaLJN  := LJN->(GetArea())

Local lContinua := .F.
Local aSC5Dados := {}
Local aSC6Dados := {}
Local aSA1Dados := {}
Local aLJNDados := {}
Local aLEADados := {}
Local nCntRegua := 0
Local cCondPag  := ""
Local d1Venc    := stod("")
Local nC6_VALOR := 0

DEFAULT aDados := {}

ProcRegua(100)

// Somente pedido de venda
If MV_PAR11 == 1

	// Pedido de venda
	dbSelectArea("SC5")
	dbSetOrder(1) // C5_FILIAL+C5_NUM
	dbSeek(xFilial("SC5")+MV_PAR01 ,.T.)
	While SC5->(!Eof()) .and. SC5->C5_FILIAL+SC5->C5_NUM <= xFilial("SC5")+MV_PAR02

        // Se o cliente faz parte do filtro
		If SC5->C5_CLIENTE >= MV_PAR07 .AND. SC5->C5_CLIENTE <= MV_PAR09 ;
		   .AND. SC5->C5_LOJACLI >= MV_PAR08 .AND. SC5->C5_LOJACLI <= MV_PAR10 
	    
			lContinua := .F.
		    aSC5Dados := { SC5->C5_NUM ;
		                  ,Transform( SC5->C5_EMISSAO ,x3Picture("C5_EMISSAO") ) ;
		                 }
			cCondPag := SC5->C5_CONDPAG
			d1Venc   := SC5->C5_EMISSAO

			// Itens do Pedido de venda
			dbSelectArea("SC6")
			dbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			dbSeek(xFilial("SC6")+SC5->C5_NUM)
			While SC6->(!Eof()) .and. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM
			
				If !Empty(SC6->C6_CODEMPR) .AND. (SC6->C6_CODEMPR >= MV_PAR05 .AND. SC6->C6_CODEMPR <= MV_PAR06)
				
					// Cadastro das Unidades do Empreendimentos
					dbSelectArea("LIQ")
					dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
					If dbSeek(xFilial("LIQ")+SC6->C6_CODEMPR)
						// Cadastro do Empreendimentos
						dbSelectArea("LK3")
						dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
						If dbSeek(xFilial("LK3")+LIQ->LIQ_CODEMP)
					        aSC6Dados := {}
					        
							aAdd( aSC6Dados ,LK3->LK3_CODEMP )
							aAdd( aSC6Dados ,LK3->LK3_DESCRI )
							aAdd( aSC6Dados ,SC6->C6_CODEMPR )
							aAdd( aSC6Dados ,LIQ->LIQ_DESC   )
							
							// Cabecalho do Contrato
							dbSelectArea("LIT")
							dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
							If dbSeek(xFilial("LIT")+SC6->C6_NOTA+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA )
								If LIT->LIT_NCONTR >= MV_PAR03 .and. LIT->LIT_NCONTR <= MV_PAR04
	
									nC6_VALOR := LIT->LIT_VALBRU
				    			  	aAdd( aSC5Dados ,Transform( LIT->LIT_NCONTR ,x3Picture("LIT_NCONTR") ) )
				                  	aAdd( aSC5Dados ,Transform( LIT->LIT_EMISSA ,x3Picture("LIT_EMISSA") ) )
									aAdd( aSC5Dados ,Transform( LIT->LIT_VALBRU ,x3Picture("LIT_VALBRU") ) )
									
									Do Case
										Case LIT->LIT_STATUS == "1" 
											aAdd( aSC5Dados ,STR0003 ) //"Em Aberto"
										Case LIT->LIT_STATUS == "2"
											aAdd( aSC5Dados ,STR0004 )   //"Encerrado"
										Case LIT->LIT_STATUS == "3"
											aAdd( aSC5Dados ,STR0005 )   //"Cancelado"
										Case LIT->LIT_STATUS == "4"
											aAdd( aSC5Dados ,STR0006 )  //"Cessao de Direito"
										Case LIT->LIT_STATUS == "5"
											aAdd( aSC5Dados ,STR0007 )         //"Distrato"
										Otherwise
											aAdd( aSC5Dados ,STR0008 )    //"Desconhecido"
									EndCase
		                    		lContinua := .T.
	                            EndIF
							Else
								nC6_VALOR := SC6->C6_VALOR
			    			  	aAdd( aSC5Dados ,"" )
			                  	aAdd( aSC5Dados ,"" )
								aAdd( aSC5Dados ,Transform( SC6->C6_VALOR ,x3Picture("C6_VALOR") ) )
			                  	aAdd( aSC5Dados ,STR0009 )  //"Näo foi gerado contrato"
		                    	lContinua := .T.
							EndIf
						EndIf
		    		EndIf
				EndIf       
				dbSelectArea("SC6")
		        dbSkip()
			EndDo

			IncProc() 
			nCntRegua++
			If nCntRegua == 100
				ProcRegua(100)
				nCntRegua := 0
			EndIf

			If lContinua 		
				aSA1Dados := {}
				// Cadastro de cliente
				dbSelectArea("SA1")
				dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
				If dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
				    aAdd( aSA1Dados ,SA1->A1_COD  ) 
				    aAdd( aSA1Dados ,SA1->A1_LOJA )
				    aAdd( aSA1Dados ,SA1->A1_NOME ) 
				    aAdd( aSA1Dados ,SA1->A1_END ) 
				    aAdd( aSA1Dados ,SA1->A1_BAIRRO ) 
				    aAdd( aSA1Dados ,SA1->A1_EST ) 
			    EndIf
			
				aLEADados := {}
				// Solidarios do contrato
				dbSelectArea("LEA")
				dbSetOrder(1) // LEA_FILIAL+LEA_NUM+LEA_CODSOL+LEA_LJSOLI
				dbSeek(xFilial("LEA")+SC5->C5_NUM)
				While LEA->(!Eof()) .AND. LEA->LEA_FILIAL+LEA->LEA_NUM==xFilial("LEA")+SC5->C5_NUM
					dbSelectArea("SA1")
					dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
					If dbSeek(xFilial("SA1")+LEA->LEA_CODSOL+LEA->LEA_LJSOLI)
						aAdd( aLEADados ,{} )
					    aAdd( aLEADados[Len(aLEADados)] ,SA1->A1_COD  ) 
					    aAdd( aLEADados[Len(aLEADados)] ,SA1->A1_LOJA )
					    aAdd( aLEADados[Len(aLEADados)] ,SA1->A1_NOME ) 
					    aAdd( aLEADados[Len(aLEADados)] ,Transform( SA1->A1_CGC ,PicPesFJ(SA1->A1_PESSOA) ) )
					    aAdd( aLEADados[Len(aLEADados)] ,QA_CBox("LEA_GRAU",LEA->LEA_GRAU))
				    EndIf
				    dbSelectArea("LEA")
				    dbSkip()

			    EndDo
			    
				If Len(aLEADados) == 0
					aAdd( aLEADados ,{"","","","",""} )
				EndIf
				
				aLJNDados := {}
				  
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Condicao de venda do Pedido de Venda
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				// Condicao de venda personalizada
				//
				If cCondPag == GetMV("MV_GMCPAG")
					// Condicao de venda do Pedido de Venda
					dbSelectArea("LJN")
					dbSetOrder(1) // LJN_FILIAL+LJN_NUM+LJN_ITEM
					dbSeek(xFilial("LJN")+SC5->C5_NUM)
					While LJN->(!Eof()) .and. LJN->LJN_FILIAL+LJN->LJN_NUM == xFilial("LJN")+SC5->C5_NUM
						aAdd( aLJNDados ,{} )
						aAdd( aLJNDados[Len(aLJNDados)] ,LJN->LJN_ITEM   )
						aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJN->LJN_NUMPAR ,x3Picture("LJN_NUMPAR") )+Space(01) )
						aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJN->LJN_VALOR/LJN->LJN_NUMPAR ,x3Picture("LJN_VALOR") ) )
						aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJN->LJN_VALOR ,x3Picture("LJN_VALOR") ) )
						aAdd( aLJNDados[Len(aLJNDados)] ,LJN->LJN_TIPPAR )
						aAdd( aLJNDados[Len(aLJNDados)] ,LJN->LJN_TPDESC )
						aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJN->LJN_1VENC ,x3Picture("LJN_1VENC") ) )
						aAdd( aLJNDados[Len(aLJNDados)] ,QA_CBox("LJN_TPSIST",LJN->LJN_TPSIST) )
						aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJN->LJN_TAXANO ,x3Picture("LJN_TAXANO") ) )
						aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJN->LJN_COEF ,x3Picture("LJN_COEF") ) )
						aAdd( aLJNDados[Len(aLJNDados)] ,LJN->LJN_IND    )
						aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJN->LJN_NMES1 ,x3Picture("LJN_NMES1") ) )
						aAdd( aLJNDados[Len(aLJNDados)] ,LJN->LJN_INDPOS )
						aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJN->LJN_NMES2 ,x3Picture("LJN_NMES2") ) )
						
						dbSelectArea("LJN")
					    dbSkip()
					EndDo
				Else
					// Condicao de Pagamento
					dbSelectArea("SE4")
					dbSetOrder(1) // E4_FILIAL+E4_CODIGO
					If dbSeek(xFilial("SE4")+cCondPag)
						// condicao de venda - cabecalho
						dbSelectArea("LIR")
						dbSetOrder(1) // LIR_FILIAL+LIR_CODCND
						If dbSeek(xFilial("LIR")+SE4->E4_CODCND)
							dbSelectArea("LIS")
							dbSetOrder(1) // LIS_FILIAL+LIS_CODCND+LIS_ITEM
							If dbSeek(xFilial("LIS")+LIR->LIR_CODCND)
								While LIS->(!Eof()) .and. LIS->LIS_FILIAL+LIS->LIS_CODCND == xFilial("LIS")+LIR->LIR_CODCND
									aAdd( aLJNDados ,{} )
									aAdd( aLJNDados[Len(aLJNDados)] ,LIS->LIS_ITEM   )
									aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LIS->LIS_NUMPAR ,x3Picture("LIS_NUMPAR") ) )
									aAdd( aLJNDados[Len(aLJNDados)] ,Transform( (nC6_VALOR*(LIS->LIS_PERCLT/100))/LIS->LIS_NUMPAR ,x3Picture("LJN_VALOR") ) )
									aAdd( aLJNDados[Len(aLJNDados)] ,Transform( (nC6_VALOR*(LIS->LIS_PERCLT/100)) ,x3Picture("LJN_VALOR") ) )
									aAdd( aLJNDados[Len(aLJNDados)] ,LIS->LIS_TIPPAR )
									aAdd( aLJNDados[Len(aLJNDados)] ,LIS->LIS_TPDESC )
									aAdd( aLJNDados[Len(aLJNDados)] ,Transform( d1Venc ,x3Picture("LJN_1VENC") ) )
									aAdd( aLJNDados[Len(aLJNDados)] ,QA_CBox("LIS_TPSIST",LIS->LIS_TPSIST) )
									aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LIS->LIS_TAXANO ,x3Picture("LIS_TAXANO") ) )
									aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LIS->LIS_COEF ,x3Picture("LIS_COEF") ) )
									aAdd( aLJNDados[Len(aLJNDados)] ,LIS->LIS_IND    )
									aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LIS->LIS_NMES1 ,x3Picture("LIS_NMES1") ) )
									aAdd( aLJNDados[Len(aLJNDados)] ,LIS->LIS_INDPOS )
									aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LIS->LIS_NMES2 ,x3Picture("LIS_NMES2") ) )
									
									dbSelectArea("LIS")
								    dbSkip()
								EndDo
							EndIf
				        EndIf
					EndIf
				EndIf
						
		    	aAdd( aDados,{ aSA1Dados ,aLEADados ,aSC5Dados ,aSC6Dados ,aLJNDados } )
			EndIf
	    EndIf   
	    
		dbSelectArea("SC5")
		dbSkip()
	EndDo
//
// Somente Contratos
//
Else

	// Contratos
	dbSelectArea("LIT")
	dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
	dbSeek(xFilial("LIT")+MV_PAR03 ,.T.)
	While LIT->(!Eof()) .and. LIT->LIT_FILIAL+LIT->LIT_NCONTR <= xFilial("LIT")+MV_PAR04
	
		lContinua := .F.
        // Se o cliente faz parte do filtro
		If LIT->LIT_CLIENT >= MV_PAR07 .AND. LIT->LIT_CLIENT <= MV_PAR09 ;
		   .AND. LIT->LIT_LOJA >= MV_PAR08 .AND. LIT->LIT_LOJA <= MV_PAR10 
	    
			lContinua := .F.
		    aSC5Dados := { "" /*numero do pedido*/	;
		                  ,"" /*data do pedido*/	;
		    			  ,LIT->LIT_NCONTR ;
		                  ,Transform( LIT->LIT_EMISSA ,x3Picture("LIT_EMISSA") ) ;
						  ,Transform( LIT->LIT_VALBRU ,x3Picture("LIT_VALBRU") ) ;
		                 }
		
			Do Case
				Case LIT->LIT_STATUS == "1" 
					aAdd( aSC5Dados ,STR0003 ) //"Em Aberto"
				Case LIT->LIT_STATUS == "2"
					aAdd( aSC5Dados ,STR0004 ) // encerrado
				Case LIT->LIT_STATUS == "3"
					aAdd( aSC5Dados ,STR0005 ) // cancelado
				Case LIT->LIT_STATUS == "4"
					aAdd( aSC5Dados ,STR0006 )    // cessao de direito
				Case LIT->LIT_STATUS == "5"
					aAdd( aSC5Dados ,STR0007 )  // distrato
				Otherwise
					aAdd( aSC5Dados ,STR0008 )   // desconhecido
			EndCase

			// Itens do Contrato
			dbSelectArea("LIU")
			dbSetOrder(3) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
			dbSeek(xFilial("LIU")+LIT->LIT_NCONTR)
			While LIU->(!Eof()) .and. LIU->LIU_FILIAL+LIU_NCONTR ;
			                       == xFilial("LIU")+LIT->LIT_NCONTR
			
				If !Empty(LIU->LIU_CODEMP) .AND. (LIU->LIU_CODEMP >= MV_PAR05 .AND. LIU->LIU_CODEMP <= MV_PAR06)
				
					If LIU->LIU_PEDIDO >= MV_PAR01 .and. LIU->LIU_PEDIDO <= MV_PAR02
						// Cadastro das Unidades do Empreendimentos
						dbSelectArea("LIQ")
						dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
						If dbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)
							// Cadastro do Empreendimentos
							dbSelectArea("LK3")
							dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
							If dbSeek(xFilial("LK3")+LIQ->LIQ_CODEMP)

						        aSC6Dados := {}
								aAdd( aSC6Dados ,LK3->LK3_CODEMP )
								aAdd( aSC6Dados ,LK3->LK3_DESCRI )
								aAdd( aSC6Dados ,LIU->LIU_CODEMP )
								aAdd( aSC6Dados ,LIQ->LIQ_DESC   )
								
								// cabecalho do pedido de venda
								dbSelectArea("SC5")
								dbSetOrder(1) // C5_FILIAL+C5_NUM
								If dbSeek(xFilial("SC5")+LIU->LIU_PEDIDO)
							    	aSC5Dados[1] := SC5->C5_NUM     /*numero do pedido*/	
							    	aSC5Dados[2] := Transform( SC5->C5_EMISSAO ,x3Picture("C5_EMISSAO") ) /*data do pedido*/
		                    		lContinua := .T.
	                            EndIf
				
							EndIf
			    		EndIf
			    	EndIf
				EndIf       
				dbSelectArea("LIU")
		        dbSkip()
			EndDo
	
			IncProc() 
			nCntRegua++
			If nCntRegua == 100
				ProcRegua(100)
				nCntRegua := 0
			EndIf

			If lContinua
				aSA1Dados := {}
				// Cadastro de cliente
				dbSelectArea("SA1")
				dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
				If dbSeek(xFilial("SA1")+LIT->LIT_CLIENT+LIT->LIT_LOJA)
				    aAdd( aSA1Dados ,SA1->A1_COD  ) 
				    aAdd( aSA1Dados ,SA1->A1_LOJA )
				    aAdd( aSA1Dados ,SA1->A1_NOME ) 
				    aAdd( aSA1Dados ,SA1->A1_END ) 
				    aAdd( aSA1Dados ,SA1->A1_BAIRRO ) 
				    aAdd( aSA1Dados ,SA1->A1_EST ) 
			    EndIf
			
				aLEADados := {}
				// Solidarios do contrato
				dbSelectArea("LEA")
				dbSetOrder(2) // LEA_FILIAL+LEA_NCONTR+LEA_CODSOL+LEA_LJSOLI
				dbSeek(xFilial("LEA")+LIT->LIT_NCONTR)
				While LEA->(!Eof()) .AND. LEA->LEA_FILIAL+LEA->LEA_NCONTR==xFilial("LIT")+LIT->LIT_NCONTR
					dbSelectArea("SA1")
					dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
					If dbSeek(xFilial("SA1")+LEA->LEA_CODSOL+LEA->LEA_LJSOLI)
						aAdd( aLEADados ,{} )
					    aAdd( aLEADados[Len(aLEADados)] ,SA1->A1_COD  ) 
					    aAdd( aLEADados[Len(aLEADados)] ,SA1->A1_LOJA )
					    aAdd( aLEADados[Len(aLEADados)] ,SA1->A1_NOME ) 
					    aAdd( aLEADados[Len(aLEADados)] ,Transform( SA1->A1_CGC ,PicPesFJ(SA1->A1_PESSOA) ) )
					    aAdd( aLEADados[Len(aLEADados)] ,QA_CBox("LEA_GRAU",LEA->LEA_GRAU))
				    EndIf
				    dbSelectArea("LEA")
				    dbSkip()

			    EndDo

				If Len(aLEADados) == 0
					aAdd( aLEADados ,{"","","","",""} )
				EndIf

				aLJNDados := {}
				// Condicao de venda do CONTRATO
				dbSelectArea("LJO")
				dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
				dbSeek(xFilial("LJO")+LIT->LIT_NCONTR)
				While LJO->(!Eof()) .and. LJO->LJO_FILIAL+LJO->LJO_NCONTR == xFilial("LJO")+LIT->LIT_NCONTR
					aAdd( aLJNDados ,{} )
					aAdd( aLJNDados[Len(aLJNDados)] ,LJO->LJO_ITEM   )
					aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJO->LJO_NUMPAR ,x3Picture("LJO_NUMPAR") ) )
					aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJO->LJO_VALOR/LJO->LJO_NUMPAR ,x3Picture("LJO_VALOR") ) )
					aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJO->LJO_VALOR ,x3Picture("LJO_VALOR") ) )
					aAdd( aLJNDados[Len(aLJNDados)] ,LJO->LJO_TIPPAR )
					aAdd( aLJNDados[Len(aLJNDados)] ,LJO->LJO_TPDESC )
					aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJO->LJO_1VENC ,x3Picture("LJO_1VENC") ) )
					aAdd( aLJNDados[Len(aLJNDados)] ,QA_CBox("LJO_TPSIST",LJO->LJO_TPSIST) )
					aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJO->LJO_TAXANO ,x3Picture("LJO_TAXANO") ) )
					aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJO->LJO_COEF ,x3Picture("LJO_COEF") ) )
					aAdd( aLJNDados[Len(aLJNDados)] ,LJO->LJO_IND    )
					aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJO->LJO_NMES1 ,x3Picture("LJO_NMES1") ) )
					aAdd( aLJNDados[Len(aLJNDados)] ,LJO->LJO_INDPOS )
					aAdd( aLJNDados[Len(aLJNDados)] ,Transform( LJO->LJO_NMES2 ,x3Picture("LJO_NMES2") ) )
					
					dbSelectArea("LJO")
				    dbSkip()
				EndDo
		
		    	aAdd( aDados,{ aSA1Dados ,aLEADados ,aSC5Dados ,aSC6Dados ,aLJNDados } )
			EndIf
	    EndIf   
	    
		dbSelectArea("LIT")
		dbSkip()
	EndDo

EndIf

LJN->(RestArea(aAreaLJN))
SC6->(RestArea(aAreaSC6))
SC5->(RestArea(aAreaSC5))
RestArea(aArea)

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GMR040Imp ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 25.09.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressão do relatorio                                      ³±±
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
Static Function GMR040Imp(lEnd,oPrint,aDados)
Local nLin      := 0
Local nCount    := 0
Local nCount2   := 0
Local aTamCols  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os dados.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Len(aDados) > 0)
	
	aTamCols := Array(6)	
	aTamCols[1] := {10,0220,0300,0330} // dados do cliente
	aTamCols[2] := {10,1200,2000,2485} // dados residenciais do cliente
	aTamCols[3] := {10,0220,0300,1295,1695,1995} // dados dos solidarios
	aTamCols[4] := {10,0300,0515,0805,0995,1295,1515,2380} // dados do pedido/Contrato
	aTamCols[5] := {10,0300          ,0995,1295,1515,2380} // dados do empreendimento
	aTamCols[6] := {10,0100,288,477,656,855,1104,1254,1504,1684,1864,2004,2104,2234,2344 }  // dados da condicao de venda

	For nCount := 1 To Len(aDados)                       
	
		nLin := 0
	    //
	    // Imprime o cabecalho do relatorio
	    // 
		nLin:=280
		PcoPrtCab(oPrint)                      
		
		// Definicao das colunas do Cabecalho do relatorio sobre cliente, loja e nome do cliente
		PcoPrtCol(aTamCols[1],.T.,len(aTamCols[1]))
	
		// Cabecalho sobre cliente, loja e nome do cliente
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0011,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //"Cliente"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,STR0012   ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //"Loja"
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,STR0013   ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //"Nome"
		nLin+=25
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aDados[nCount ,1 ,1],oPrint,4,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aDados[nCount ,1 ,2],oPrint,4,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,aDados[nCount ,1 ,3],oPrint,4,_CORPO_FONTE_TAMANHO_)
		nLin+=50

		// Definicao das colunas do Cabecalho do relatorio sobre cliente, loja e nome do cliente
		PcoPrtCol(aTamCols[2],.T.,len(aTamCols[2]))

		// Cabecalho sobre cliente, loja e nome do cliente
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0014,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //"Cliente"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,STR0015  ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //"Loja"
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,STR0016  ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //"Nome"
		nLin+=25
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aDados[nCount ,1 ,4],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aDados[nCount ,1 ,5],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,aDados[nCount ,1 ,6],oPrint,2,_CORPO_FONTE_TAMANHO_)
		nLin+=75
	
		// Definicao das colunas do Cabecalho do relatorio sobre os solidarios
		PcoPrtCol(aTamCols[3],.T.,len(aTamCols[3]))

		// Cabecalho sobre os solidarios                    
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0017 ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //"Solidario"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,STR0018      ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //"Loja"
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,STR0013      ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //"Nome"
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),30,STR0019  ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //CPF/CNPJ
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),30,STR0020   ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))  //"Relacao"
		nLin+=25

		For nCount2 := 1 To len(aDados[nCount ,02])

			PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,aDados[nCount ,02 ,nCount2 ,01],oPrint,2,_CORPO_FONTE_TAMANHO_) 
			PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),50,aDados[nCount ,02 ,nCount2 ,02],oPrint,2,_CORPO_FONTE_TAMANHO_) 
			PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),50,aDados[nCount ,02 ,nCount2 ,03],oPrint,2,_CORPO_FONTE_TAMANHO_) 
			PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),50,aDados[nCount ,02 ,nCount2 ,04],oPrint,2,_CORPO_FONTE_TAMANHO_) 
			PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),50,aDados[nCount ,02 ,nCount2 ,05],oPrint,2,_CORPO_FONTE_TAMANHO_) 
			nLin+=50
		Next nCount2
		nLin+=25
	
		// Definicao das colunas do Cabecalho sobre pedido de venda Data do contrato e valor original e atual do contrato
		PcoPrtCol(aTamCols[4],.T.,len(aTamCols[4]))
		
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0021  ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230)) //"Numero do Pedido"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,STR0022       ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230)) //"Data Pedido" 
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,STR0023,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230)) //"Numero do Contrato"
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),30,STR0024     ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230)) //"Data Contrato" 
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),30,""                  ,oPrint,0,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230)) //
		PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),30,STR0025    ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230)) //"Valor Contrato"
		PcoPrtCell(PcoPrtPos(7),nLin,PcoPrtTam(7),30,STR0026            ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230)) //"Status"  
		nLin+=25
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aDados[nCount ,3 ,1],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aDados[nCount ,3 ,2],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,aDados[nCount ,3 ,3],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),50,aDados[nCount ,3 ,4],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),50,""                  ,oPrint,0,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(6),nLin,PcoPrtTam(6),50,aDados[nCount ,3 ,5],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(7),nLin,PcoPrtTam(7),50,aDados[nCount ,3 ,6],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		nLin+=75
                   
		// Definicao das colunas do Cabecalho sobre pedido de venda Data do contrato e valor original e atual do contrato
		PcoPrtCol(aTamCols[5],.T.,len(aTamCols[5]))
		
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),30,STR0027,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Empreendimento"
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),30,""              ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),30,""              ,oPrint,0,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230)) 
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),30,STR0028       ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))// unidade
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),30,""              ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))
		nLin+=25
		PcoPrtCell(PcoPrtPos(1),nLin,PcoPrtTam(1),50,aDados[nCount ,4 ,1],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(2),nLin,PcoPrtTam(2),50,aDados[nCount ,4 ,2],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(3),nLin,PcoPrtTam(3),50,""                  ,oPrint,0,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(4),nLin,PcoPrtTam(4),50,aDados[nCount ,4 ,3],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		PcoPrtCell(PcoPrtPos(5),nLin,PcoPrtTam(5),50,aDados[nCount ,4 ,4],oPrint,2,_CORPO_FONTE_TAMANHO_) 
		nLin+=75
                   
		// Definicao das colunas do Cabecalho dos titulos a receber
		PcoPrtCol(aTamCols[6],.T.,len(aTamCols[6]))
		// Cabecalho dos titulos a receber
		PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),30,STR0029          ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Item"
		PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),30,STR0030 ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Qtd. Parcelas"
		PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),30,STR0031 ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Valor Parcela"
		PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),30,STR0032   ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Valor Total"
		PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),30,STR0033  ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Tipo Parcela" 
		PcoPrtCell(PcoPrtPos( 6),nLin,PcoPrtTam( 6),30,STR0034     ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Descricao"
		PcoPrtCell(PcoPrtPos( 7),nLin,PcoPrtTam( 7),30,STR0035     ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"1o. Venc."
		PcoPrtCell(PcoPrtPos( 8),nLin,PcoPrtTam( 8),30,STR0036  ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Tipo Sistema"
		PcoPrtCell(PcoPrtPos( 9),nLin,PcoPrtTam( 9),30,STR0037    ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Taxa Anual" 
		PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),30,STR0038   ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Coeficiente"
		PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),30,STR0039       ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Ind.Pre" 
		PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),30,STR0040         ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))// "Meses"
		PcoPrtCell(PcoPrtPos(13),nLin,PcoPrtTam(13),30,STR0041       ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))// "Ind.Pos"   
		PcoPrtCell(PcoPrtPos(14),nLin,PcoPrtTam(14),30,STR0040         ,oPrint,2,_CABECALHO_FONTE_TAMANHO_,t_GEMRGB(230,230,230))//"Meses"
		nLin+=25

		For nCount2 := 1 To len(aDados[nCount ,05])

			PcoPrtCell(PcoPrtPos( 1),nLin,PcoPrtTam( 1),50,aDados[nCount ,05 ,nCount2 ,01],oPrint,2,_CORPO_FONTE_TAMANHO_) 
			PcoPrtCell(PcoPrtPos( 2),nLin,PcoPrtTam( 2),50,aDados[nCount ,05 ,nCount2 ,02],oPrint,2,_CORPO_FONTE_TAMANHO_,,,.T.) 
			PcoPrtCell(PcoPrtPos( 3),nLin,PcoPrtTam( 3),50,aDados[nCount ,05 ,nCount2 ,03],oPrint,2,_CORPO_FONTE_TAMANHO_,,,.T.) 
			PcoPrtCell(PcoPrtPos( 4),nLin,PcoPrtTam( 4),50,aDados[nCount ,05 ,nCount2 ,04],oPrint,2,_CORPO_FONTE_TAMANHO_,,,.T.) 
			PcoPrtCell(PcoPrtPos( 5),nLin,PcoPrtTam( 5),50,aDados[nCount ,05 ,nCount2 ,05],oPrint,2,_CORPO_FONTE_TAMANHO_) 
			PcoPrtCell(PcoPrtPos( 6),nLin,PcoPrtTam( 6),50,aDados[nCount ,05 ,nCount2 ,06],oPrint,2,_CORPO_FONTE_TAMANHO_) 
			PcoPrtCell(PcoPrtPos( 7),nLin,PcoPrtTam( 7),50,aDados[nCount ,05 ,nCount2 ,07],oPrint,2,_CORPO_FONTE_TAMANHO_) 
			PcoPrtCell(PcoPrtPos( 8),nLin,PcoPrtTam( 8),50,aDados[nCount ,05 ,nCount2 ,08],oPrint,2,_CORPO_FONTE_TAMANHO_)			 
			PcoPrtCell(PcoPrtPos( 9),nLin,PcoPrtTam( 9),50,aDados[nCount ,05 ,nCount2 ,09],oPrint,2,_CORPO_FONTE_TAMANHO_,,,.T.) 
			PcoPrtCell(PcoPrtPos(10),nLin,PcoPrtTam(10),50,aDados[nCount ,05 ,nCount2 ,10],oPrint,2,_CORPO_FONTE_TAMANHO_,,,.T.)			
			PcoPrtCell(PcoPrtPos(11),nLin,PcoPrtTam(11),50,aDados[nCount ,05 ,nCount2 ,11],oPrint,2,_CORPO_FONTE_TAMANHO_)
			PcoPrtCell(PcoPrtPos(12),nLin,PcoPrtTam(12),50,aDados[nCount ,05 ,nCount2 ,12],oPrint,2,_CORPO_FONTE_TAMANHO_,,,.T.)
			PcoPrtCell(PcoPrtPos(13),nLin,PcoPrtTam(13),50,aDados[nCount ,05 ,nCount2 ,13],oPrint,2,_CORPO_FONTE_TAMANHO_)
			PcoPrtCell(PcoPrtPos(14),nLin,PcoPrtTam(14),50,aDados[nCount ,05 ,nCount2 ,14],oPrint,2,_CORPO_FONTE_TAMANHO_,,,.T.)
			nLin+=50                                                        

		Next nCount2		
	    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEnd
	    	Exit
		EndIf  
		
    Next nCount
    
EndIf

Return( .T. )

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
Local cPerg		:= PadR ( "GMR040", Len( SX1->X1_GRUPO ) )

aCposSX1 := {"X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
             "X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEF02","X1_DEFSPA1",;
             "X1_DEFENG1","X1_VAR02","X1_DEFSPA2","X1_DEFENG2",;
             "X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_F3","X1_PYME","X1_CNT01"}

aAdd(aRegs,{"01","Pedido de? "         ,"","","mv_ch1","C",TamSX3("C5_num")[1]    ,00,0,"G","","MV_PAR01","","","","","","","","","","","","SC5","",""})
aAdd(aRegs,{"02","Pedido ate?"         ,"","","mv_ch2","C",TamSX3("C5_num")[1]    ,00,0,"G","","MV_PAR02","","","","","","","","","","","","SC5","",""})
aAdd(aRegs,{"03","Contrato de? "       ,"","","mv_ch3","C",TamSX3("LIT_NCONTR")[1],00,0,"G","","MV_PAR03","","","","","","","","","","","","LIT","",""})
aAdd(aRegs,{"04","Contrato ate?"       ,"","","mv_ch4","C",TamSX3("LIT_NCONTR")[1],00,0,"G","","MV_PAR04","","","","","","","","","","","","LIT","",""})
aAdd(aRegs,{"05","Empreendimento de? " ,"","","mv_ch5","C",TamSX3("LIQ_COD")[1]   ,00,0,"G","","MV_PAR05","","","","","","","","","","","","LIQ","",""})
aAdd(aRegs,{"06","Empreendimento ate?" ,"","","mv_ch6","C",TamSX3("LIQ_COD")[1]   ,00,0,"G","","MV_PAR06","","","","","","","","","","","","LIQ","",""})
aAdd(aRegs,{"07","Cliente de? "        ,"","","mv_ch7","C",TamSX3("A1_COD")[1]    ,00,0,"G","","MV_PAR07","","","","","","","","","","","","SA1","",""})
aAdd(aRegs,{"08","Loja de?"            ,"","","mv_ch8","C",TamSX3("A1_LOJA")[1]   ,00,0,"G","","MV_PAR08","","","","","","","","","","","",""   ,"",""})
aAdd(aRegs,{"09","Cliente ate? "       ,"","","mv_ch9","C",TamSX3("A1_COD")[1]    ,00,0,"G","","MV_PAR09","","","","","","","","","","","","SA1","",""})
aAdd(aRegs,{"10","Loja ate?"           ,"","","mv_chA","C",TamSX3("A1_LOJA")[1]   ,00,0,"G","","MV_PAR10","","","","","","","","","","","",""   ,"",""})
aAdd(aRegs,{"11","Considerar ?"        ,"","","mv_chB","N",01                     ,00,0,"C","","MV_PAR10","Pedido de Venda","Contrato","","","","","","","","","","","",""})

dbSelectArea("SX1")
dbSetOrder(1) // X1_GRUPO_+X1_ORDEM
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
