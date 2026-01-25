#INCLUDE "PROTHEUS.CH" 
#INCLUDE "STFStTaxCalc.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} STFStTaxCalc
Calcula os impostos cadastrados para a tabela de ECF
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet Status de execução da rotina
@obs
@sample
/*/
//------------------------------------------------------------------- 

Function STFStTaxCalc()   
	Local aArea := GetArea()
	Local cMsg := ""
	Local lRet := .F.
	
	MsgRun(STR0001,STR0002,{||lRet := STFStTaxCl(@cMsg)})         //"Calculando os impostos para o cliente tipo padrão"#"Aguarde!"
	
	If lRet
		MsgInfo(cMsg) 
	Else 
		MsgAlert(cMsg)
	EndIf
	
	
	RestArea(aArea)


Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} STFStTaxCalc
Calcula os impostos cadastrados para a tabela de ECF
@param	 cMsg  Mensagem
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet Status de execução da rotina
@obs
@sample
/*/
//------------------------------------------------------------------- 
Static Function STFStTaxCl(cMsg)
	Local aArea := GetArea()   			//WorkArea Anterior
	Local aAreaSF4 := SF4->(GetArea())	//WorkArea SF4
	Local aAreaSB1 := SB1->(GetArea())	//WorkArea SB1
	Local aAreaSA1 := SA1->(GetArea())	//WorkArea SA1
	Local aAreaSB0 := SB0->(GetArea())	//WorkArea SB0 
	Local aAreaMFD := {}				//WorkArea MFD
	Local cCliPad  := PadR( SuperGetMV("MV_CLIPAD"), TamSX3("A1_COD")[1])     	//Cliente Padrão
	Local cLojaPad := PadR( SuperGetMV("MV_LOJAPAD"), TamSx3("A1_LOJA")[1])		//Loja Padrao
	Local cItemTES := "" 														//Tes do Produto
	Local cTpSolCf	:= SuperGetMv("MV_TPSOLCF")                					//Parametro para validacao do tipo de cliente para o calculo do solidario
    Local cFilSB1  := SB1->(xFilial())											//Filial SB1
    Local cFilSA1  := SA1->(xFilial())											//Filial SA1
    Local cFilSB0 := SB0->(xFilial())
    Local cFilSF4 := SF4->(xFilial())
    Local cFilMFD := ""
    Local lMVDescISS := SuperGetMv("MV_DESCISS",,.F.)
    Local nMVAliqISS := SuperGetMv("MV_ALIQISS") 
    Local cTipoImp 	 := ""
    Local nAliq		:= 0 
    Local nMFDAl1 := 0
    Local nMFDAl2 := 0  
    Local lRet := .F. //Retorno da Rotina
    Local lFunc := FindFunction("STBTaxTES")       
    Local nALIQISS		:= 0 
    Local nPICMRET 		:= 0
    Local cTS				:= ""
    
    Default cMsg := ""
    
    cMsg := STR0003 //"Registros Gerados com sucesso" 

	If nModulo == 12 .AND. AliasInDic("MFD")  .AND. lFunc
		aAreaMFD := MFD->(GetArea())  
		cFilMFD := MFD->(xFilial())
		cTabela := "SB1" 
		
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA  
		SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD 
		SB0->(DbSetOrder(1)) //B0_FILIAL+B0_COD  
		SF4->(DbSetOrder(1))//F4_FILIAL+F4_CODIGO  
		MFD->(DbSetOrder(1)) //MFD_FILIAL + MFD_IMPOST + STR(MFD_ALIQ,5,2)                                                                                                                                                                                                                                                                                                                                                                                                              	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciona o SA1   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	If SA1->(DbSeek( cFilSA1 + cCliPad + cLojaPad ) )                                                                                                                                         
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona o SB1   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SB1->(DbSeek( cFilSB1 ) )  
			
			nMFDAl1 := MFD->(TamSX3("MFD_ALIQ"))[1]
			nMFDAl2 := MFD->(TamSX3("MFD_ALIQ"))[2]
			
			Do While SB1->(!Eof() .AND. B1_FILIAL == cFilSB1)    
			
				nALIQISS		:= RetFldProd(SB1->B1_COD,"B1_ALIQISS") 
    			nPICMRET 		:= RetFldProd(SB1->B1_COD,"B1_PICMRET")
    			cTS				:= RetFldProd(SB1->B1_COD,"B1_TS")
    			
				cItemTES := STBTaxTES(	2	,	"01"		,	cCliPad		,	cLojaPad 							,;
											"C"	,	SB1->B1_COD	,	Nil				,   Iif(Empty(cTS), SB1->B1_TS, cTS)				)                                                                                                                                                   
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona o SB0   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SB0->(DbSeek(cFilSB0 +SB1->B1_COD)) //B0_FILIAL+B0_COD                                                                                                                                                
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Posiciona o SF4   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF4->(DbSeek( cFilSF4+cItemTES ) )   
				
					 cTipoImp 	 := "1"
					 nAliq		:= 0
					 
					nPICMRET  := Iif(Empty(nPICMRET ), SB1->B1_PICMRET, nPICMRET )
					
					If SF4->F4_ISS == "S" //.AND. ( ( ( SA1->A1_RECISS == "1" .AND. lMVDescISS ) .OR. ( SA1->A1_RECISS <> "1" ) ) )
						nALIQISS := Iif(Empty(nALIQISS), SB1->B1_ALIQISS, nALIQISS)
						If nALIQISS > 0 
							cTipoImp := "2"
							nAliq := nALIQISS
						Else
							cTipoImp := "2"
							nAliq := nMVAliqISS
						EndIf
					ElseIf nPICMRET > 0 .AND. SA1->A1_TIPO $ cTpSolCf .AND. SF4->F4_BSICMST <> 100 // Substituicao tributaria (Icms Solidario)
						nAliq := 0														
					ElseIf SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100 // Com redução de Icms na Base de Cálculo do Imposto
						nAliq := SB0->B0_ALIQRED	
					ElseIf SF4->F4_LFICM == "I"								// Isento
						nAliq := 0
					ElseIf SF4->F4_LFICM == "N" .OR. SF4->F4_LFICM == "O"	// N„o sujeito a ICMS
						nAliq := 0
					Else													// Com ICMS
						nAliq := AliqIcms(	"N"	,"S",SA1->A1_TIPO,"I", NIL, .T.)
					EndIf
				
				EndIf
				
			    If nAliq > 0 .AND. !MFD->(DbSeek(cFilMFD + cTipoImp + Str(nAliq, nMFDAl1, nMFDAl2)  ) )  
			    	RecLock("MFD", .T.)     
			    	MFD->MFD_FILIAL := cFilMFD
			    	MFD->MFD_IMPOST := cTipoImp
			    	MFD->MFD_ALIQ := nAliq
			    	MFD->(MsUnLock())
			    EndIf
			    
			    
			    SB1->(DbSkip())
			 End
			 lRet := .T.
		Else 
		 	cMsg := STR0004 //"Cliente Padrão não localizado"
		 EndIf
		    
	
		RestArea(aAreaMFD)
	Else
		If !AliasInDic("MFD") 
			cMsg := STR0005	 //"Para a execução da apuração das alíquotas do ECF, é necessário que a tabela MFD esteja cadastrada"  				
		Else
			If !lFunc
				cMsg := STR0006 //"Função não compilada no repositório: STBTaxTES"
			Else
			
				cMsg := STR0007 //"Esta rotina deve ser executada somente no SigaLoja"      
			EndIf
		EndIf
	EndIf
	
 
	RestArea(aAreaSB0)
	RestArea(aAreaSA1)
	RestArea(aAreaSB1)
	RestArea(aAreaSF4)
	RestArea(aArea) 
	
Return lRet