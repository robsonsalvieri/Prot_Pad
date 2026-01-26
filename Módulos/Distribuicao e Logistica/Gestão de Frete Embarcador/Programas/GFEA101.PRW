#INCLUDE "GFEA101.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


Function GFEA101()
	Local lNotBlind := !IsBlind()
	Private cTxtLog := ""

	If lNotBlind
		Processa({||GFEA101PRC(lNotBlind) },"Geração de contratos Batch... Aguarde")
		ShowErrLog(cTxtLog)
	Else
		GFEA101PRC(lNotBlind)
	EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA101PRC

Geração de contratos Batch

@author Jorge Matos Valcanaia
@since 02/03/10
@version 1.0
/*/
//------------------------------------------------------------------- 
Function GFEA101PRC(lNotBlind)
Local nNrCont     := "********"
Local cCdProp       
Local nNrCalc
Local nTotalCal := 0
Local nTotalReg := 0
Local nAtualReg := 1
Local aCdDoc    := {}
Local aDSDTRE   := {"1=Data Corrente","2=Data Criação","3=Informada Usuário","4=Financeiro"}
Local aDSDTAP   := {"1=Data Corrente","2=Data Criação","3=Informada Usuário"}
Local s_BASINS  := SuperGetMv("MV_BASINS", .F., 0)
Local s_PCINAU  := SuperGetMv("MV_PCINAU", .F., 0)
Local s_VLMXRE  := SuperGetMv("MV_VLMXRE", .F., 0)
Local s_BASIRF  := SuperGetMv("MV_BASIRF", .F., 0)
Local s_DEDSES  := SuperGetMv('MV_DEDSES', .F., "1")
Local s_DEDINS  := SuperGetMV('MV_DEDINS', .F., "1")
Local s_MINIRF  := SuperGetMv('MV_MINIRF', .F., 0)
Local s_PCSEST  := SuperGetMv('MV_PCSEST', .F., 0)
Local s_PCSENA  := SuperGetMv('MV_PCSENA', .F., 0)
Local s_DSDTAP  := SuperGetMV('MV_DSDTAP', .F., "1")
Local s_DSDTRE  := SuperGetMV('MV_DSDTRE', .F., "1")
Local s_INTGFE  := SuperGetMv("MV_INTGFE", .F., .F.)
Local s_INTGFE2 := SuperGetMv("MV_INTGFE2", .F., "2")
Local s_DTULFE  := SuperGetMv("MV_DTULFE", .F., "20000101")

Private nBaseInss	:= 0
Private nInssOutEmp := 0 // Inss Outras Empresas 
Private nInssPer    := 0 // Inss Período         
Private nBaseReIr   := 0 // Recolher Base Ir     
Private nFretCont   := 0 // Frete contratado     
Private nAdicionais := 0 // Adicionais           
Private nDescontos  := 0 // Descontos
Private nSestSenat  := 0 // SEST/SENAT
Private nSestAux	:= 0 // SEST
Private nSenaAux	:= 0 // SENAT
Private nIss        := 0 // ISS
Private nInssAuto   := 0 // INSS Autonomo
Private nIrrf       := 0 // IRRF
Private nVlLiqui    := 0 // Valor Liquido 
Private oButton
Private cRecno      
Private nImpostos   
Private nInssAuto2  := 0         
Private nInssOtEmp 
Private nVlTotFret
Private nFretContImp := 0 	
Private nVlInem 	 := 0						
Private nGFEEDIL 	 := SuperGetMV('MV_GFEEDIL',,'1')
Private GFELog100

Default lNotBlind := .T.

	If !Pergunte("GFEA101",.T.) /*Abre o grupo de perguntas para o usuario e se for cancelado o grupo fecha e não executa ação nenhuma*/
	Return Nil
	Endif  

	If Empty(MV_PAR05) .Or. MV_PAR05 < DDATABASE
		Help( ,, 'HELP',,STR0001, 1, 0) //"Data de vencimento não foi informada ou deve ser maior que a Data de hoje"
		Return .F.
	Endif
	
	cAlias := GetNextAlias()

	cQuery := " SELECT GWF.*, GU3.GU3_ENTOBR FROM "+RetSQLName("GWF")+" GWF "
	cQuery += " INNER JOIN "+RetSQLName("GU3")+" GU3 ON GU3.GU3_FILIAL = '"+xFilial("GU3")+"' AND GU3.GU3_CDEMIT = GWF.GWF_TRANSP "		
	cQuery += " WHERE "
	cQuery += " 	GWF.GWF_TRANSP >= '"+MV_PAR01+"'       AND GWF.GWF_TRANSP <= '"+MV_PAR02+"'       AND "
	cQuery += " 	GWF.GWF_DTCRIA >= '"+DToS(MV_PAR03)+"'       AND GWF.GWF_DTCRIA <= '"+DToS(MV_PAR04)+"'       AND "	
	cQuery += "   GU3.GU3_AUTON = '1' AND"
	cQuery += "   GWF.D_E_L_E_T_ = ' '  AND"	
	cQuery += " 	GWF.GWF_NRCONT = ' '"
	cQuery += " ORDER BY GWF.GWF_FILIAL, GWF.GWF_TRANSP "
		
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

	dbSelectArea((cAlias))
	(cAlias)->( dbGoTop() )
	While !(cAlias)->( Eof() )
		nTotalReg++
		(cAlias)->( dbSkip() )
	EndDo
	
	ProcRegua(nTotalReg)

	(cAlias)->( dbGoTop() )		
	While !(cAlias)->( Eof() ).And. xFilial("GWF") == (cAlias)->GWF_FILIAL    
		dbSelectArea("GWN") /*Posiciona na tabela de Romaneio*/
		dbSetOrder(1)
		If dbSeek(xFilial("GWN")+(cAlias)->GWF_NRROM) /*Posiciona no romaneio do cálculo do frete*/
			If GWN->GWN_SIT != "3" .And. GWN->GWN_SIT != "4" /* Verifica se o romaneio está como liberado ou encerrado para permitir a vinculação ao contrato com autonomo */
				//Erro		
				cromaneio := (cAlias)->GWF_NRROM
				cTxtLog += "Documento não Gerado" + CRLF	
				cTxtLog += "Romaneio " + cromaneio + ", com situação diferente de liberado ou encerrado." + CRLF	
				cTxtLog += "--------------------------------------------------------------------------------------------------------------------" + CRLF																
				dbSelectArea(cAlias)
				dbSkip()
				Loop
			EndIf	
		EndIf
		If lNotBlind
			IncProc("Documento "+ cValToChar(nAtualReg)+ " de " + cValToChar(nTotalReg))
			nAtualReg++
		EndIf

		
		If (cAlias)->GU3_ENTOBR == "1" 
			dbSelectArea("GWH") /*Posiciona na tabela de vinculo entre Documento de Carga/Cálculo de frete*/
			dbSetOrder(1)
			dbSeek(xFilial("GWH")+(cAlias)->GWF_NRCALC) //Posiciona no primeiro cálculo cadastrado na tabela de vinculo
						
			While !Eof() .And. xFilial("GWF") == (cAlias)->GWF_FILIAL .And. GWH->GWH_NRCALC == (cAlias)->GWF_NRCALC //Continua dentro do While enquanto a filial e o cálculo for o mesmo
				dbSelectArea("GW1") //Posiciona no Documento de Carga
				dbSetOrder(1)
				dbSeek(xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC) //Posiciona no primeiro Documento de Carga a partir de um Registro da tabela de vinculo
											
				While !Eof() .And. xFilial("GW1") == GW1->GW1_FILIAL .And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC .And. GW1->GW1_EMISDC == GWH->GWH_EMISDC .And. GW1->GW1_SERDC == GWH->GWH_SERDC .And. GW1->GW1_NRDC == GWH->GWH_NRDC //Continua no While enquanto a filial,código do tipo do documento, emissor do documento e a série seja a mesma do registro passado no dbSeek
	           		
	           		dbSelectArea("GWU") //Posiciona na tabela de trecho
					dbSetOrder(1)
					dbSeek(xFilial("GWU")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC) //Posiciona no primeiro Trecho que estaja cadastrado para o documento de carga
					While !Eof() .And. xFilial("GWU") == GWU->GWU_FILIAL .And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC;
		           	.And. GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. GWU->GWU_SERDC == GW1->GW1_SERDC .And. GWU->GWU_NRDC == GW1->GW1_NRDC /*Percorre o While enquanto a Filial,Código do tipo de Documento, Emissor do documento, serie do documento e o número do documento seja o mesmo do que o informado no trecho do documento de carga*/
						If GWU->GWU_CDTRP == (cAlias)->GWF_TRANSP //Verifica se o código do transportador do trecho e o mesmo do código do proprietario em tela*/
		   					If !Empty(GWU->GWU_DTENT) //Verifica se a data esta diferente de branco					
							    dbSelectArea("GV5") //Posiciona na tabela de tipo de documento de carga
								dbSetOrder(1)
								If dbSeek(xFilial("GV5")+GW1->GW1_CDTPDC) /*Posiciona no tipo do documento de carga do documento que esta posicionado*/ 
									If MV_PAR08 == 1 /*Verifica se o parametro do MV_PAR03 está como sim que então verifica se o sentido do documento é entrada*/
										If GV5->GV5_SENTID == "1" /*Verifica se o sentido é entrada*/ 					  
										    dbSelectArea("GW2")
										    dbSetOrder(2)
											If dbSeek(xFilial("GW2")+(cAlias)->GWF_TRANSP+nNrCont)										
											/*vincula um calculo ao contrato ja criado*/
												nBaseReIr  := 0 // Grava BASE IR do periodo
												nInssPer    := 0 // Grava o INSS do periodo
												nAdicionais := 0 // Grava o Valor dos Adicionais
												nDescontos  := 0 // Grava o Valor dos Descontos
												nSestSenat  := 0 // Grava o Valor do Sest/Senat
												nIss        := 0 // Grava o Valor do ISS
												nInssAuto   := 0 // Grava o Valor do INSS do Autonomo
												nIrrf       := 0 // Grava o Valor do IRRF
												nVlLiqui    := 0 // Grava o Valor liquido do contrato
												nImpostos 	:= 0
												nFretContImp	:= 0
												dbSelectArea("GWF") /*Posiciona na Tabela de cálculo*/
												dbSetOrder(1)
												iF dbSeek(xFilial("GWF")+(cAlias)->GWF_NRCALC)
												  	RecLock("GWF",.F.)	 
													GWF->GWF_NRCONT := nNrCont 
													MsUnLock("GWF")  
												EndIf
												If ASCAN(aCdDoc,(cAlias)->GWF_NRCALC) == 0 
													AADD(aCdDoc,(cAlias)->GWF_NRCALC)	
													nFretCont := GW2->GW2_VLFRET + TOTFRTIMP((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC)
													cRecno    := GW2->(Recno())
												Endif
																								
											Else
												/*Cria um novo contrato*/ 

												nBaseReIr  := 0 // Grava BASE IR do periodo
												nInssPer    := 0 // Grava o INSS do periodo
												nAdicionais := 0 // Grava o Valor dos Adicionais
												nDescontos  := 0 // Grava o Valor dos Descontos
												nSestSenat  := 0 // Grava o Valor do Sest/Senat
												nIss        := 0 // Grava o Valor do ISS
												nInssAuto   := 0 // Grava o Valor do INSS do Autonomo
												nIrrf       := 0 // Grava o Valor do IRRF
												nVlLiqui    := 0 // Grava o Valor liquido do contrato
												nImpostos 	:= 0
												nFretContImp	:= 0 	
												nVlInem := 0
																								
												If ASCAN(aCdDoc,(cAlias)->GWF_NRCALC) == 0 
													AADD(aCdDoc,(cAlias)->GWF_NRCALC)															
													nFretCont := 0
													nFretCont := TOTFRTIMP((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC)
												Endif			 	
												
												
												nNrCont := GETSXENUM("GW2","GW2_NRCONT")  
												cCdProp := (cAlias)->GWF_TRANSP      
												nNrCalc := (cAlias)->(Recno())
												
												dbSelectArea("GWF") /*Posiciona na Tabela de cálculo*/
												dbSetOrder(1)
												iF dbSeek(xFilial("GWF")+(cAlias)->GWF_NRCALC)
												  	RecLock("GWF",.F.)	 
													GWF->GWF_NRCONT := nNrCont
													MsUnLock("GWF")  
												EndIf	
																								
												RecLock("GW2",.T.) 																			
												GW2->GW2_FILIAL := xFilial("GW2")
												GW2->GW2_NRCONT := nNrCont
												GW2->GW2_SITCON := "2"
												GW2->GW2_USUCRI := cUserName
												GW2->GW2_CDPROP := cCdProp
												GW2->GW2_SITREC := "1"
												GW2->GW2_SITFIN := "1"
												GW2->GW2_SITRH  := "1"
												GW2->GW2_DTVENC := MV_PAR05
												GW2->GW2_TEST1  := MV_PAR06
												GW2->GW2_TEST2  := MV_PAR07
												GW2->GW2_DTCRIA := DDATABASE 
												
												cRecno          := GW2->(Recno())																											
												MsUnLock("GW2")								
																																						
												ConfirmSx8()																																																 	 													 	
											 	cTxtLog += STR0002 + nNrcont + CRLF //"Contrato     - "
										   		cTxtLog += STR0003 + posicione("GU3",1,xFilial("GU3")+cCdProp,"GU3_NMEMIT") + CRLF //"Proprietario - "
										   		cTxtLog += "--------------------------------------------------------------------------------------------------------------------" + CRLF													
										 	Endif			 								 
										Endif
									ElseIf MV_PAR08 == 2
										IF GV5->GV5_SENTID <> "1"
									   		dbSelectArea("GW2")
										    dbSetOrder(2)
											If dbSeek(xFilial("GW2")+(cAlias)->GWF_TRANSP+nNrCont)										
												/*vincula um calculo ao contrato ja criado*/
												nBaseReIr  := 0 // Grava BASE IR do periodo
												nInssPer    := 0 // Grava o INSS do periodo
												nAdicionais := 0 // Grava o Valor dos Adicionais
												nDescontos  := 0 // Grava o Valor dos Descontos
												nSestSenat  := 0 // Grava o Valor do Sest/Senat
												nIss        := 0 // Grava o Valor do ISS
												nInssAuto   := 0 // Grava o Valor do INSS do Autonomo
												nIrrf       := 0 // Grava o Valor do IRRF
												nVlLiqui    := 0 // Grava o Valor liquido do contrato
												nImpostos 	:= 0
												nFretContImp	:= 0 
												nVlInem := 0			
  
														
												dbSelectArea("GWF") /*Posiciona na Tabela de cálculo*/
												dbSetOrder(1)
												iF dbSeek(xFilial("GWF")+(cAlias)->GWF_NRCALC)
												  	RecLock("GWF",.F.)	 
													GWF->GWF_NRCONT := nNrCont
													MsUnLock("GWF")  
												EndIf
												If ASCAN(aCdDoc,(cAlias)->GWF_NRCALC) == 0 
													AADD(aCdDoc,(cAlias)->GWF_NRCALC)																							 
													nFretCont := GW2->GW2_VLFRET + TOTFRTIMP((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC)
													cRecno    := GW2->(Recno())
												Endif
												
									 			 														
											Else												   
												/*Cria um novo contrato*/
												
												nBaseReIr  := 0 // Grava BASE IR do periodo
												nInssPer    := 0 // Grava o INSS do periodo
												nAdicionais := 0 // Grava o Valor dos Adicionais
												nDescontos  := 0 // Grava o Valor dos Descontos
												nSestSenat  := 0 // Grava o Valor do Sest/Senat
												nIss        := 0 // Grava o Valor do ISS
												nInssAuto   := 0 // Grava o Valor do INSS do Autonomo
												nIrrf       := 0 // Grava o Valor do IRRF
												nVlLiqui    := 0 // Grava o Valor liquido do contrato
												nImpostos 	:= 0
												nFretContImp	:= 0 
												nVlInem := 0		
																								
												If ASCAN(aCdDoc,(cAlias)->GWF_NRCALC) == 0 
													AADD(aCdDoc,(cAlias)->GWF_NRCALC)	
													nFretCont := 0
													nFretCont := TOTFRTIMP((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC)
												Endif			 	
	
												nNrCont := GETSXENUM("GW2","GW2_NRCONT")  
												cCdProp := (cAlias)->GWF_TRANSP      
												nNrCalc := (cAlias)->(Recno())
												dbSelectArea("GWF") /*Posiciona na Tabela de cálculo*/
												dbSetOrder(1)
												iF dbSeek(xFilial("GWF")+(cAlias)->GWF_NRCALC)
												  	RecLock("GWF",.F.)	 
													GWF->GWF_NRCONT := nNrCont
													MsUnLock("GWF")  
												EndIf

												RecLock("GW2",.T.) 																			
												GW2->GW2_FILIAL := xFilial("GW2")
												GW2->GW2_NRCONT := nNrCont
												GW2->GW2_SITCON := "2"
												GW2->GW2_USUCRI := cUserName
												GW2->GW2_CDPROP := cCdProp
												GW2->GW2_SITREC := "1"
												GW2->GW2_SITFIN := "1"
												GW2->GW2_SITRH  := "1"
												GW2->GW2_DTVENC := MV_PAR05
												GW2->GW2_TEST1  := MV_PAR06
												GW2->GW2_TEST2  := MV_PAR07
												GW2->GW2_DTCRIA := DDATABASE 
												
												cRecno          := GW2->(Recno())																											
												MsUnLock("GW2")								
												
	
												ConfirmSx8()												 								 	
 											 	cTxtLog += STR0002 + nNrcont + CRLF //"Contrato     - "
										   		cTxtLog += STR0003 + posicione("GU3",1,xFilial("GU3")+cCdProp,"GU3_NMEMIT") + CRLF //"Proprietario - "
										   		cTxtLog += "--------------------------------------------------------------------------------------------------------------------" + CRLF	
										   	Endif
										Endif
									Endif								
						      	Endif
								If MV_PAR08 == 2 .and. GV5->GV5_SENTID == "1"	
									//Erro		
									cTxtLog += "Documento não Gerado" + CRLF	
									cTxtLog += "Doc Carga " + GW1->GW1_NRDC + ", é um doc. de entrada."	 + CRLF	
									cTxtLog += "--------------------------------------------------------------------------------------------------------------------" + CRLF													
								elseIf	MV_PAR08 == 1 .and. GV5->GV5_SENTID <> "1"	
									cTxtLog += "Documento não Gerado" + CRLF	
									cTxtLog += "Doc Carga " + GW1->GW1_NRDC + ", não é um doc. de entrada." + CRLF
									cTxtLog += "--------------------------------------------------------------------------------------------------------------------" + CRLF													
								Endif											
							Endif
							//Erro
							cTxtLog += "Documento não Gerado" + CRLF	
							cTxtLog += "Doc Carga " + GW1->GW1_NRDC + ", sem data de entrada." + CRLF
							cTxtLog += "--------------------------------------------------------------------------------------------------------------------" + CRLF													
						Endif
						dbSelectArea("GWU")							
						dbSkip()
					EndDo												
					dbSelectArea("GW1")                	
					dbSkip()
				EndDo
			
				dbSelectArea("GWH")
				dbSkip()
			EndDo
		
			dbSelectArea("GW2")
			dbSetOrder(2)
			If dbSeek(xFilial("GW2")+(cAlias)->GWF_TRANSP+nNrCont)
				
				GFELog100   := GFELog():New("Contrato_Autonomo_"+GW2->GW2_FILIAL+'_'+GW2->GW2_NRCONT, "Cálculo Impostos Autônomo", nGFEEDIL)
				GFEA101AL(" ***********************","")
				GFEA101AL("        PARAMETROS      ","")
				GFEA101AL(" ***********************","")
				GFEA101AL("% Base INSS-MV_BASINS: ",cValToChar(s_BASINS))
				GFEA101AL("% INSS Autônomo-MV_PCINAU: ", cValToChar(s_PCINAU))
				GFEA101AL("Valor Máximo de INSS-MV_VLMXRE: ",cValToChar(s_VLMXRE))
				GFEA101AL("% Base IRRF-MV_BASIRF: ", cValToChar(s_BASIRF))
				GFEA101AL("SEST Base IRRF-MV_DEDSES: ", IIF(s_DEDSES$"1S","1=Descontar","2=Manter"))
				GFEA101AL("INSS Base IRRF-MV_DEDINS: ", IIF(s_DEDINS$"1S","1=Descontar","2=Manter"))
				GFEA101AL("Valor Mínimo IRRF-MV_MINIRF: ", cValToChar(s_MINIRF))
				GFEA101AL("% SEST-MV_PCSEST: ", cValToChar(s_PCSEST))
				GFEA101AL("% SENAT-MV_PCSENA: ", cValToChar(s_PCSENA))
				GFEA101AL("Data Integração Financeiro-MV_DSDTAP: ", IIF(Empty(s_DSDTAP),"Nao definido",aDSDTAP[val(s_DSDTAP)]))
				GFEA101AL("Data Integração Recebimento-MV_DSDTRE: ", IIF(Empty(s_DSDTRE),"Nao definido",aDSDTRE[val(s_DSDTRE)]))
				GFEA101AL("Integracao com o TOTVS GFE-MV_INTGFE: ", IIF(s_INTGFE==.T.,"Sim","Não"))
				GFEA101AL("Integracao Direta com TOTVS GFE-MV_INTGFE2: ", IIF(s_INTGFE2=="1","Sim","Não"))
				GFEA101AL("Data do Último Fechamento-MV_DTULFE: ", cValToChar(s_DTULFE))
				GFEA101AL("","")
				
				nBaseInss := (nFretCont + nInssAuto) * (s_BASINS/100)	
				
				GFEA100GC()
											
				nFretContImp := nFretContImp + ((VLTOTFRET((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC) - TOTFRTIMP((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC))) // Somatório do valor do frete apenas considerando os componentes que NÃO fazem parte da base de imposto.
				nVlTotFret := nFretCont + nFretContImp
				nVlLiqui  := (nVlTotFret + nAdicionais) - (nDescontos + nSestSenat + nIss + nInssAuto + nIrrf)
												
				GFEA101AL("","")
				GFEA101AL(" *********************** ", "")
				GFEA101AL("   VALORES CALCULADOS    ", "")
				GFEA101AL(" *********************** ", "")
				GFEA101AL("Valor Total de Frete (+): ",PadL(AllTrim(Transform(nVlTotFret,  "@E 999,999,999.99")), 14) + " (+)")
				GFEA101AL("  Valores Adicionais (+): ",PadL(AllTrim(Transform(nAdicionais, "@E 999,999,999.99")), 14) + " (+)")
				GFEA101AL("     Valor Descontos (-): ",PadL(AllTrim(Transform(nDescontos,  "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("    Valor SEST/SENAT (-): ",PadL(AllTrim(Transform(nSestSenat,  "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("           Valor ISS (-): ",PadL(AllTrim(Transform(nIss,        "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("  Valor ISS Autonomo (-): ",PadL(AllTrim(Transform(nInssAuto,   "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("          Valor IRRF (-): ",PadL(AllTrim(Transform(nIrrf,       "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("       Valor Líquido (=): ",PadL(AllTrim(Transform(nVlLiqui,    "@E 999,999,999.99")), 14) + " (=)")
				GFELog100:EndLog()

				If nVlLiqui < 0
					nVlLiqui := 0
				Endif
			
											
				dbSelectArea("GW2")
				dbGoTo(cRecno)
															
				RecLock("GW2",.F.)
				GW2->GW2_VLBAIR := nBaseReIr		// Grava BASE IR do periodo
				GW2->GW2_INSSPE := nInssPer      // Grava o INSS do periodo
				GW2->GW2_VLFRET := nVlTotFret     // Grava o Valor do Frete
				GW2->GW2_VLADIC := nAdicionais   // Grava o Valor dos Adicionais
				GW2->GW2_VLDESC := nDescontos    // Grava o Valor dos Descontos
				GW2->GW2_VLSEST := nSestSenat    // Grava o Valor do Sest/Senat
				GW2->GW2_VLISS  := nIss          // Grava o Valor do ISS
				GW2->GW2_VLINSS := nInssAuto     // Grava o Valor do INSS do Autonomo
				GW2->GW2_VLIRRF := nIrrf         // Grava o Valor do IRRF
				GW2->GW2_VLLIQ  := nVlLiqui      // Grava o Valor liquido do contrato
				GW2->GW2_VLIMP  := nImpostos     // Grava a Soma dos impostos
				GW2->GW2_VLINEM := nVlInem					
				GW2->GW2_VLBAIN := nBaseInss     // Base INSS	
				MsUnLock("GW2")
			Endif
	           				
		Else
			dbSelectArea("GWH") /*Posiciona na tabela de vinculo entre Documento de Carga/Cálculo de frete*/
			dbSetOrder(1)
			dbSeek(xFilial("GWH")+(cAlias)->GWF_NRCALC) /*Posiciona no primeiro cálculo cadastrado na tabela de vinculo*/	
					
			While !Eof() .And. xFilial("GWF") == (cAlias)->GWF_FILIAL .And. GWH->GWH_NRCALC == (cAlias)->GWF_NRCALC /*Continua dentro do While enquanto a filial e o cálculo for o mesmo*/
				dbSelectArea("GW1") //Posiciona no Documento de Carga
				dbSetOrder(1)
				dbSeek(xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC) //Posiciona no primeiro Documento de Carga a partir de um Registro da tabela de vinculo
				While !Eof() .And. xFilial("GW1") == GW1->GW1_FILIAL .And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC .And. GW1->GW1_EMISDC == GWH->GWH_EMISDC .And. GW1->GW1_SERDC == GWH->GWH_SERDC .And. GW1->GW1_NRDC == GWH->GWH_NRDC //Continua no While enquanto a filial,código do tipo do documento, emissor do documento e a série seja a mesma do registro passado no dbSeek

				    dbSelectArea("GV5") /*Posiciona na tabela de tipo de documento de carga*/
   					dbSetOrder(1)
   					If dbSeek(xFilial("GV5")+GW1->GW1_CDTPDC) /*Posiciona no tipo do documento de carga do documento que esta posicionado*/ 
						If MV_PAR08 == 1 /*Verifica se o parametro do MV_PAR03 está como sim que então verifica se o sentido do documento é entrada*/
							If GV5->GV5_SENTID == "1" /*Verifica se o sentido é entrada*/ 					  
							    dbSelectArea("GW2")
							    dbSetOrder(2)
								If dbSeek(xFilial("GW2")+(cAlias)->GWF_TRANSP+nNrCont)										
									/*vincula um calculo ao contrato ja criado*/  	
									nBaseReIr  := 0 // Grava BASE IR do periodo
									nInssPer    := 0 // Grava o INSS do periodo
									nAdicionais := 0 // Grava o Valor dos Adicionais
									nDescontos  := 0 // Grava o Valor dos Descontos
									nSestSenat  := 0 // Grava o Valor do Sest/Senat
									nIss        := 0 // Grava o Valor do ISS
									nInssAuto   := 0 // Grava o Valor do INSS do Autonomo
									nIrrf       := 0 // Grava o Valor do IRRF
									nVlLiqui    := 0 // Grava o Valor liquido do contrato
									nImpostos 	:= 0
									nFretContImp	:= 0
									dbSelectArea("GWF") /*Posiciona na Tabela de cálculo*/
									dbSetOrder(1)
									iF dbSeek(xFilial("GWF")+(cAlias)->GWF_NRCALC)
									  	RecLock("GWF",.F.)	 
										GWF->GWF_NRCONT := nNrCont
										MsUnLock("GWF")  
									EndIf
									
	
									If ASCAN(aCdDoc,(cAlias)->GWF_NRCALC) == 0 
										AADD(aCdDoc,(cAlias)->GWF_NRCALC)															
										nFretCont := GW2->GW2_VLFRET + TOTFRTIMP((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC) 
										cRecno    := GW2->(Recno())
									Endif
																		 			 														
								Else
									/*Cria um novo contrato*/
									nBaseReIr  := 0 // Grava BASE IR do periodo
									nInssPer    := 0 // Grava o INSS do periodo
									nAdicionais := 0 // Grava o Valor dos Adicionais
									nDescontos  := 0 // Grava o Valor dos Descontos
									nSestSenat  := 0 // Grava o Valor do Sest/Senat
									nIss        := 0 // Grava o Valor do ISS
									nInssAuto   := 0 // Grava o Valor do INSS do Autonomo
									nIrrf       := 0 // Grava o Valor do IRRF
									nVlLiqui    := 0 // Grava o Valor liquido do contrato
									nImpostos 	:= 0
									nFretContImp	:= 0 										 
									nVlInem := 0
									
									If ASCAN(aCdDoc,(cAlias)->GWF_NRCALC) == 0 
										AADD(aCdDoc,(cAlias)->GWF_NRCALC)	
										nFretCont := 0										
										nFretCont := TOTFRTIMP((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC)
									Endif			 	
									
									nNrCont := GETSXENUM("GW2","GW2_NRCONT")  
									cCdProp := (cAlias)->GWF_TRANSP      
									nNrCalc := (cAlias)->(Recno())
													
									dbSelectArea("GWF") /*Posiciona na Tabela de cálculo*/
									dbSetOrder(1)
									iF dbSeek(xFilial("GWF")+(cAlias)->GWF_NRCALC)
										RecLock("GWF",.F.)	 
										GWF->GWF_NRCONT := nNrCont
										MsUnLock("GWF")  
									EndIf											
									
									RecLock("GW2",.T.) 																			
									GW2->GW2_FILIAL := xFilial("GW2")
									GW2->GW2_NRCONT := nNrCont
									GW2->GW2_SITCON := "2"
									GW2->GW2_USUCRI := cUserName
									GW2->GW2_CDPROP := cCdProp
									GW2->GW2_SITREC := "1"
									GW2->GW2_SITFIN := "1"
									GW2->GW2_SITRH  := "1"
									GW2->GW2_DTVENC := MV_PAR05
									GW2->GW2_TEST1  := MV_PAR06
									GW2->GW2_TEST2  := MV_PAR07
									GW2->GW2_DTCRIA := DDATABASE 
									
									cRecno          := GW2->(Recno())																											
									MsUnLock("GW2")								
	
									ConfirmSx8()		
																									 	 													 	
									cTxtLog += STR0002 + nNrcont + CRLF //"Contrato     - "
							   		cTxtLog += STR0003 + posicione("GU3",1,xFilial("GU3")+cCdProp,"GU3_NMEMIT") + CRLF //"Proprietario - "
							   		cTxtLog += "--------------------------------------------------------------------------------------------------------------------" + CRLF													
							 	Endif			 								 
							Endif
						ElseIf MV_PAR08 == 2
							IF GV5->GV5_SENTID <> "1"
								dbSelectArea("GW2")
							    dbSetOrder(2)
								If dbSeek(xFilial("GW2")+(cAlias)->GWF_TRANSP+nNrCont)										
									/*vincula um calculo ao contrato ja criado*/
									nBaseReIr  := 0 // Grava BASE IR do periodo
									nInssPer    := 0 // Grava o INSS do periodo
									nAdicionais := 0 // Grava o Valor dos Adicionais
									nDescontos  := 0 // Grava o Valor dos Descontos
									nSestSenat  := 0 // Grava o Valor do Sest/Senat
									nIss        := 0 // Grava o Valor do ISS
									nInssAuto   := 0 // Grava o Valor do INSS do Autonomo
									nIrrf       := 0 // Grava o Valor do IRRF
									nVlLiqui    := 0 // Grava o Valor liquido do contrato
									nImpostos 	:= 0
									nFretContImp	:= 0 
									nVlInem := 0
									
									dbSelectArea("GWF") /*Posiciona na Tabela de cálculo*/
									dbSetOrder(1)
									iF dbSeek(xFilial("GWF")+(cAlias)->GWF_NRCALC)
										RecLock("GWF",.F.)	 
										GWF->GWF_NRCONT := nNrCont
										MsUnLock("GWF")  
									EndIf
									If ASCAN(aCdDoc,(cAlias)->GWF_NRCALC) == 0 
										AADD(aCdDoc,(cAlias)->GWF_NRCALC)															
										nFretCont := GW2->GW2_VLFRET + TOTFRTIMP((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC)
										cRecno    := GW2->(Recno())	
										nTotalCal := nTotalCal -1
									Endif		
			 			 														
								Else
							    	/*Cria um novo contrato*/

									nBaseReIr  := 0 // Grava BASE IR do periodo
									nInssPer    := 0 // Grava o INSS do periodo
									nAdicionais := 0 // Grava o Valor dos Adicionais
									nDescontos  := 0 // Grava o Valor dos Descontos
									nSestSenat  := 0 // Grava o Valor do Sest/Senat
									nIss        := 0 // Grava o Valor do ISS
									nInssAuto   := 0 // Grava o Valor do INSS do Autonomo
									nIrrf       := 0 // Grava o Valor do IRRF
									nVlLiqui    := 0 // Grava o Valor liquido do contrato
									nImpostos 	:= 0
									nFretContImp	:= 0 	
									nVlInem := 0							    	
							    	
							    	If ASCAN(aCdDoc,(cAlias)->GWF_NRCALC) == 0 
										AADD(aCdDoc,(cAlias)->GWF_NRCALC)										    	
										nFretCont := 0
										nFretCont := TOTFRTIMP((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC)
										nTotalCal := nTotalCal -1
									Endif					 	
									
									nNrCont := GETSXENUM("GW2","GW2_NRCONT")  
									cCdProp := (cAlias)->GWF_TRANSP      
									nNrCalc := (cAlias)->(Recno())


									dbSelectArea("GWF") /*Posiciona na Tabela de cálculo*/
									dbSetOrder(1)
									iF dbSeek(xFilial("GWF")+(cAlias)->GWF_NRCALC)
									  	RecLock("GWF",.F.)	 
										GWF->GWF_NRCONT := nNrCont
										MsUnLock("GWF")  
									EndIf
									
									cSitRec := IntSITREC("1",GV5->GV5_FRCTB,GW1->GW1_USO)
									
									RecLock("GW2",.T.) 																			
									GW2->GW2_FILIAL := xFilial("GW2")
									GW2->GW2_NRCONT := nNrCont
									GW2->GW2_SITCON := "2"
									GW2->GW2_USUCRI := cUserName
									GW2->GW2_CDPROP := cCdProp
									GW2->GW2_SITREC := cSitRec
									GW2->GW2_SITFIN := "1"
									GW2->GW2_SITRH  := "1"
									GW2->GW2_DTVENC := MV_PAR05
									GW2->GW2_TEST1  := MV_PAR06
									GW2->GW2_TEST2  := MV_PAR07
									GW2->GW2_DTCRIA := DDATABASE 
									
									cRecno          := GW2->(Recno())																											
									MsUnLock("GW2")								

									ConfirmSx8()
													 													 	 													 									 	
									cTxtLog += STR0002 + nNrcont + CRLF //"Contrato     - "
							   		cTxtLog += STR0003 + posicione("GU3",1,xFilial("GU3")+cCdProp,"GU3_NMEMIT") + CRLF //"Proprietario - "
							   		cTxtLog += "--------------------------------------------------------------------------------------------------------------------" + CRLF													
                               	Endif
							Endif								
				      	Endif
						If MV_PAR08 == 2 .and. GV5->GV5_SENTID == "1"	
							//Erro		
							cTxtLog += "Documento não Gerado" + CRLF	
							cTxtLog += "Doc Carga " + GW1->GW1_NRDC + ", é um doc. de entrada." + CRLF	
							cTxtLog += "--------------------------------------------------------------------------------------------------------------------" + CRLF														
						elseIf	MV_PAR08 == 1 .and. GV5->GV5_SENTID <> "1"	
							cTxtLog += "Documento não Gerado" + CRLF	
							cTxtLog += "Doc Carga " + GW1->GW1_NRDC + ", não é um doc. de entrada." + CRLF
							cTxtLog += "--------------------------------------------------------------------------------------------------------------------" + CRLF													
						Endif					      	
					Endif									
					dbSelectArea("GW1")                	
					dbSkip()
				EndDo
               	dbSelectArea("GWH")
               	dbSkip()
			EndDo	
			dbSelectArea("GW2")
			dbSetOrder(2)
			If dbSeek(xFilial("GW2")+(cAlias)->GWF_TRANSP+nNrCont)
			
				GFELog100   := GFELog():New("Contrato_Autonomo_"+GW2->GW2_FILIAL+'_'+GW2->GW2_NRCONT, "Cálculo Impostos Autônomo", nGFEEDIL)
				GFEA101AL(" ***********************","")
				GFEA101AL("        PARAMETROS      ","")
				GFEA101AL(" ***********************","")
				GFEA101AL("% Base INSS-MV_BASINS: ",cValToChar(s_BASINS))
				GFEA101AL("% INSS Autônomo-MV_PCINAU: ", cValToChar(s_PCINAU))
				GFEA101AL("Valor Máximo de INSS-MV_VLMXRE: ",cValToChar(s_VLMXRE))
				GFEA101AL("% Base IRRF-MV_BASIRF: ", cValToChar(s_BASIRF))
				GFEA101AL("SEST Base IRRF-MV_DEDSES: ", IIF(s_DEDSES$"1S","1=Descontar","2=Manter"))
				GFEA101AL("INSS Base IRRF-MV_DEDINS: ", IIF(s_DEDINS$"1S","1=Descontar","2=Manter"))
				GFEA101AL("Valor Mínimo IRRF-MV_MINIRF: ", cValToChar(s_MINIRF))
				GFEA101AL("% SEST-MV_PCSEST: ", cValToChar(s_PCSEST))
				GFEA101AL("% SENAT-MV_PCSENA: ", cValToChar(s_PCSENA))
				GFEA101AL("Data Integração Financeiro-MV_DSDTAP: ", IIF(Empty(s_DSDTAP),"Nao definido",aDSDTAP[val(s_DSDTAP)]))
				GFEA101AL("Data Integração Recebimento-MV_DSDTRE: ", IIF(Empty(s_DSDTRE),"Nao definido",aDSDTRE[val(s_DSDTRE)]))
				GFEA101AL("Integracao com o TOTVS GFE-MV_INTGFE: ", IIF(s_INTGFE==.T.,"Sim","Não"))
				GFEA101AL("Integracao Direta com TOTVS GFE-MV_INTGFE2: ", IIF(s_INTGFE2=="1","Sim","Não"))
				GFEA101AL("Data do Último Fechamento-MV_DTULFE: ", cValToChar(s_DTULFE))
				GFEA101AL("","")
				
				nBaseInss := (nFretCont + nInssAuto) * (s_BASINS/100)	
				
				GFEA100GC()
												
				nFretContImp := nFretContImp + ((VLTOTFRET((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC) - TOTFRTIMP((cAlias)->GWF_FILIAL,(cAlias)->GWF_NRCALC))) // Somatório do valor do frete apenas considerando os componentes que NÃO fazem parte da base de imposto.
				nVlTotFret := nFretCont + nFretContImp
				nVlLiqui  := (nVlTotFret + nAdicionais) - (nDescontos + nSestSenat + nIss + nInssAuto + nIrrf)
												
				GFEA101AL("","")
				GFEA101AL(" *********************** ", "")
				GFEA101AL("   VALORES CALCULADOS    ", "")
				GFEA101AL(" *********************** ", "")
				GFEA101AL("Valor Total de Frete (+): ",PadL(AllTrim(Transform(nVlTotFret,  "@E 999,999,999.99")), 14) + " (+)")
				GFEA101AL("  Valores Adicionais (+): ",PadL(AllTrim(Transform(nAdicionais, "@E 999,999,999.99")), 14) + " (+)")
				GFEA101AL("     Valor Descontos (-): ",PadL(AllTrim(Transform(nDescontos,  "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("    Valor SEST/SENAT (-): ",PadL(AllTrim(Transform(nSestSenat,  "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("    		Valor SEST  ():  ",PadL(AllTrim(Transform(nSestAux,    "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("    		Valor SENAT ():  ",PadL(AllTrim(Transform(nSenaAux,    "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("           Valor ISS (-): ",PadL(AllTrim(Transform(nIss,        "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("  Valor ISS Autonomo (-): ",PadL(AllTrim(Transform(nInssAuto,   "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("          Valor IRRF (-): ",PadL(AllTrim(Transform(nIrrf,       "@E 999,999,999.99")), 14) + " (-)")
				GFEA101AL("       Valor Líquido (=): ",PadL(AllTrim(Transform(nVlLiqui,    "@E 999,999,999.99")), 14) + " (=)")

				GFELog100:EndLog()

				If nVlLiqui < 0
					nVlLiqui := 0
				Endif
				
																				  	
				dbSelectArea("GW2")
				dbGoTo(cRecno)
														
				RecLock("GW2",.F.)
				GW2->GW2_VLBAIN := nBaseInss     // Base INSS	
				GW2->GW2_VLBAIR := nBaseReIr	 // Grava BASE IR do periodo
				GW2->GW2_INSSPE := nInssPer      // Grava o INSS do periodo
				GW2->GW2_VLFRET := nVlTotFret    // Grava o Valor do Frete
				GW2->GW2_VLADIC := nAdicionais   // Grava o Valor dos Adicionais
				GW2->GW2_VLDESC := nDescontos    // Grava o Valor dos Descontos
				GW2->GW2_VLSEST := nSestSenat    // Grava o Valor do Sest/Senat
				GW2->GW2_VLISS  := nIss          // Grava o Valor do ISS
				GW2->GW2_VLINSS := nInssAuto     // Grava o Valor do INSS do Autonomo
				GW2->GW2_VLIRRF := nIrrf         // Grava o Valor do IRRF
				GW2->GW2_VLLIQ  := nVlLiqui      // Grava o Valor liquido do contrato
				GW2->GW2_VLIMP  := nImpostos     // Grava a Soma dos impostos
				GW2->GW2_VLINEM := nVlInem
				MsUnLock("GW2")
			Endif
		EndIf

		dbSelectArea(cAlias)
		dbSkip()  
	EndDo
	(cAlias)->( dbCloseArea() )

	If Empty(cTxtLog)
		cTxtLog += STR0004 //"Não foi possivel gerar nenhum contrato"
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowErrLog

Apresentacao do log de processo/erro em tela.

@param  cTxtLog        texto log para apresentacao

@author Jorge Matos Valcanaia
@since 02/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ShowErrLog(cTxtLog)
	Local cPrograma := Substr(ProcName(1),3,Len(ProcName(1)))
	Local cMask := STR0005 //"Arquivos Texto (*.TXT) |*.txt|"
	Local oFont, oDlg
	Local cArq   := cPrograma + "_" + SM0->M0_CODIGO + SM0->M0_CODFIL + "_" + Dtos(Date()) + "_" + StrTran(Time(),":","") + ".LOG"
	
	Private lError := .F.	
	Private aLog := Array(1)

	If !Empty(cArq) .And. !Empty(cTxtLog)
		cTxtLog += + " - " + AllTrim(cArq)
		aLog[1] := {cTxtLog}
		DEFINE FONT oFont NAME "Courier New" SIZE 5,0
		DEFINE MSDIALOG oDlg TITLE If(lError,STR0009,STR0006)+STR0007 From 3,0 to 340,417 COLOR CLR_BLACK,CLR_WHITE PIXEL //"Log de Processo"###" - Contratos Gerados" //"Inconsistência"
			@ 5,5 GET oMemo  VAR cTxtLog MEMO SIZE 200,145 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont := oFont
				oMemo:lReadOnly := .T.
				
			DEFINE SBUTTON FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
			DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,OemToAnsi(STR0008)),If(cFile="",.t.,MemoWrite(cFile,cTxtLog)),oDlg:End()) ENABLE OF oDlg PIXEL //"Salvar Como..."
			DEFINE SBUTTON  FROM 153,115 TYPE 6 ACTION LOGPRINT(aLog,cPrograma) ENABLE OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	
	FERASE(cArq)
	
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} LOGPRINT

Impressao do log.

@param  aLog        array contendo o conteudo para impressao
@param  cPrograma   programa que chama a impressao.

@author Jorge Matos Valcanaia
@since 02/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LOGPRINT(aLog,cPrograma)
	Local aTitle   := {If(lError,STR0009,STR0006)+STR0007} //"Log de Processo"###" - Contratos Gerados" //"Inconsistência"
	CursorWait()
	fMakeLog( aLog,aTitle,,.T.,cPrograma,aTitle[1],"G","P",,.F.)
	CursorArrow()
Return Nil

Static Function GFEA101AL(cMsg, cVal )
	if nGFEEDIL <> "1"
		GFELog100:Add(PADL(cMsg,50)+cVal)
	EndIf
Return
