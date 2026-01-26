#Include "Protheus.Ch"
              
Template Function PCLGeraOrc()  
 
Local nX 		  := 0  
Local nValtotICM  := 0
Local aDadosTMP   := aClone(aDadosBMB)  
Local cConcatOrc  := ""   
Local nTotal 	  := 0
Local nBico 	  := 0
Local nItem 	  := 0
	    
				                                                           
		FOR nX := 1 to len(aDadosTMP)    
          		
  			IF (aDadosTMP[nX, 1] == .T.) 
          		
      			cConcatOrc += aDadosTMP[nX, 2] + ", " 
      			nTotal += round(val(aDadosTMP[nX, 5]), 2) 
      			nBico  := val(aDadosTMP[nX, 2])     
      	
      		EndIF
      		
      	Next nX	 
      	
      	IF cConcatOrc == ""
      		MsgStop("Nenhum abastecimento selecionado!")
      		Return
      	EndIF	                                                                  
      	
      	
				cConcatOrc := Substr(cConcatOrc, 1, len(cConcatOrc)-2)	
				IF MSGYESNO("Confirma geração de orçamento para o(s) bico(s): " + cConcatOrc)

					cFil := FWGETCODFILIAL
					
					cProd     := Space(1)         //Variavel que pega o Codigo do Temporario no Cadastro de Produtos
					cCodP     := ""
					cBomb     := ""
					cTes      := ""
					cIcm      := 0
					cLocal    := ""
				

						DbSelectArea("SL1")
						DbSetOrder(1)
						RecLock("SL1",.T.)
						cReg1 := RECNO()
						replace SL1->L1_FILIAL  with  cFil
						cNew  := GetSXENum("SL1","L1_NUM")
						SL1->L1_NUM := cNew
						ConfirmSX8()
						cNew  := SL1->L1_NUM
							
						replace SL1->L1_VEND    with "000001"
						replace SL1->L1_CLIENTE with "000001"
						replace SL1->L1_EMISSAO with DDATABASE
						replace SL1->L1_VLRTOT  with nTotal
						replace SL1->L1_VLRLIQ  with nTotal
						replace SL1->L1_VALBRUT with nTotal
						replace SL1->L1_VALMERC with nTotal
						replace SL1->L1_TIPOCLI with "R"
						replace SL1->L1_DTLIM   with DDATABASE                                 		
						replace SL1->L1_ENTRADA with nTotal
						replace SL1->L1_PARCELA with 01
						replace SL1->L1_CONDPG  with "001"
						replace SL1->L1_FORMPG  with "R$"
						replace SL1->L1_LOJA    with "01"
						replace SL1->L1_CONFVEN with "SSSSSSSNSSSS"
						replace SL1->L1_IMPRIME with "2N"
						replace SL1->L1_COND    with 000
						replace SL1->L1_OPERACA with "O"
						replace SL1->L1_CONDPG  with "001"
						replace SL1->L1_BICO    with StrZero(nBico,2,0)
					
						MsUnlock()
					
					
						FOR nX := 1 to len(aDadosTMP)    
		          		
		          			IF (aDadosTMP[nX, 1] == .T.)
							    nItem++
								DbSelectArea("SL2")
								DbOrderNickName("SL2PCL3")
								RecLock("SL2",.T.)
								cReg := RECNO()                                  

								SL2->L2_NUM := cNew
								replace SL2->L2_ITEM    with StrZero(nItem,2,0)
								replace SL2->L2_QUANT   with val(aDadosTMP[nX, 4])
								//replace SL2->L2_VRUNIT  with Val(Stuff(LEG->LEG_PREPLI,2,0,"."))
								//replace SL2->L2_VLRITEM with Val(Stuff(LEG->LEG_TOTAPA,5,0,"."))
								replace SL2->L2_VRUNIT  with Val(aDadosTMP[nX, 3])
								replace SL2->L2_VLRITEM with Val(strtran(aDadosTMP[nX, 5], ",", "."))
								cLocal  := Posicione("LEI",1,xFilial("LEI")+StrZero(val(aDadosTMP[nX, 2]),2,0),"LEI_TANQUE")
								replace SL2->L2_LOCAL   with cLocal
								replace SL2->L2_UM      with "L"
								replace SL2->L2_BASEICM with SL2->L2_VLRITEM
								replace SL2->L2_TABELA  with "1"
								replace SL2->L2_EMISSAO with DDATABASE
								replace SL2->L2_PRCTAB  with val(aDadosTMP[nX, 3])
								replace SL2->L2_GRADE   with "N"
								replace SL2->L2_FILIAL  with cFil
								replace SL2->L2_VEND    with "000001"
								replace SL2->L2_BICO    with StrZero(val(aDadosTMP[nX, 2]),2,0)
								MsUnlock()  
						
					
								DbSelectArea("LEF")
								DbSetOrder(2)
								If DbSeek(xFilial("LEF") + StrZero(val(aDadosTMP[nX, 2]),2,0))
									cCodP   := LEF->LEF_CODPRO
									cProd   := LEF->LEF_DESCRI
									cBomb   := LEF->LEF_BICO
									RecLock("LEF",.F.)
									LEF->LEF_ENCER  := LEF->LEF_ENCER + SL2->L2_QUANT
									LEF->LEF_CORVAL := LEF->LEF_CORVAL + SL2->L2_VLRITEM
									MsUnlock()
						   		Endif
					
								DbSelectArea("SB1")
								DbSetOrder(1)
								If DbSeek(xFilial("SB1") + cCodP)
									cTes    := SB1->B1_TS
									cIcm    := SB1->B1_PICM
								Endif
					
								DbSelectArea("SL2")
								DbOrderNickName("SL2PCL3")
								DbGoTo(cReg)
								RecLock("SL2",.F.)
								replace SL2->L2_PRODUTO with cCodP
								replace SL2->L2_DESCRI  with cProd
								replace SL2->L2_TES     with cTes
								replace SL2->L2_VALICM  with SL2->L2_VLRITEM * cIcm / 100
								replace SL2->L2_BICO    with cBomb
								MsUnlock()   
							
						   		nValtotICM := nValtotICM + (SL2->L2_VLRITEM * cIcm / 100)
					
					
								DbSelectArea("SF4")
								DbSetOrder(1)
							                     
								If DbSeek(xFilial("SF4") + SL2->L2_TES)
									DbSelectArea("SL2")
									DbOrderNickName("SL2PCL3")
									DbGoTo(cReg)
									RecLock("SL2",.F.)
									replace SL2->L2_CF with SF4->F4_CF
									MsUnlock()
								Endif  
					
							EndIF
		                
		
				   		Next nX
					
			
						DbSelectArea("SL1")
						DbSetOrder(1)
						DbGoTo(cReg1)                                       
						RecLock("SL1",.F.)                                              
						replace SL1->L1_VALICM  with nValtotICM
						MsUnlock() 
			
				   
					DbSelectArea("SX3")
					SX3->(DbSetOrder(2))
					
					IF DBSeek("LEG_NUMORC")				
				
		     			DbSelectArea("LEG")
						LEG->(DbSetOrder(1))
		     		
			     			FOR nX := 1 to len(aDadosTMP)    
          		
	   				  			IF (aDadosTMP[nX, 1] == .T.) 
          		
       				    			If DbSeek(xFilial("LEG") + StrZero(val(aDadosTMP[nX, 7]),10,0))
										RecLock("LEG",.F.)
										LEG->LEG_NUMORC  := cNew
										MsUnlock()
							   		Endif         
      		                                                           
					      		EndIF
      		
					      	Next nX		                                                     

					EndIF
		     		                                                                           
					MSGINFO("Orçamento gerado com sucesso! Número: " + cNew)
			 Else  
			 		     
	                Alert("Geração de Orçamento Cancelada!")                            
	                
             EndIF
Return	