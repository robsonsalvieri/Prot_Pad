#INCLUDE "GFEA111.ch"
#INCLUDE "PROTHEUS.CH"     

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA111

Exportar Pré-Faturas

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA111()
	Local        cCdTrp := 0
	Local   aCdTrp      := {}
	Local   nCnt      
	Private cCond       := ""       
	Private cCGCSMO     := "" 
	Private cCxEdiRemet := "" 
	Private cCxEdiDest  := ""
	Private nSeq        := 1    
	Private nVlPrefTot  := 0
	Private nQtdPref    := 0
	Private cArqTxt     := ""
	Private lMsgErro    := .F. 
	/*/
	MV_PAR01: Filial de ? 
	MV_PAR02: Filial ate ?
	MV_PAR03: Nr. Pre-Fatura de ?
	MV_PAR04: Nr. Pre-Fatura ate ?
	MV_PAR05: Manter Data Corrente ?
	MV_PAR06: Data de Criacao de ?
	MV_PAR07: Data de Criacao ate ?
	MV_PAR08: Data Vencimento de ?
	MV_PAR09: Data Vencimento ate
	*/ 
	/*Não utilizado
	MV_PAR10: Data Limite de
	MV_PAR11: Data Limite ate ?*/ 
	/*
	MV_PAR10: Dt Cancelamento de ?
	MV_PAR11: Dt Cancelamento ate ?
	MV_PAR12: Transportador de ?
	MV_PAR13: Transportador ate ?
	MV_PAR14: Criadas ?
	MV_PAR15: Enviadas ?
	MV_PAR16: Aprovadas ?
	MV_PAR17: Canceladas ?
	MV_PAR18: Reenviar PreFaturas ?
	MV_PAR19: Saida ?
	MV_PAR20: Destino ?
	/*/
	
	If !Pergunte("GFEA111",.T.) /*Abre o grupo de perguntas para o usuario e se for cancelado o grupo fecha e não executa ação nenhuma*/
	   Return Nil
	Endif               
	
	If MV_PAR14 == 1 /*Criadas: 1-Sim 2-Não*/
		cCond += "1"
	Endif      
	If MV_PAR15 == 1 /*Enviadas: 1-Sim 2-Não*/
		cCond += "2"
	Endif
	If MV_PAR16 == 1 /*Aprovadas: 1-Sim 2-Não*/
		cCond += "3"
	Endif
	If MV_PAR17 == 1 /*Canceladas: 1-Sim 2-Não*/
		cCond += "4"
	Endif      
	
	dbSelectArea("GWJ")
	GWJ->( dbSetOrder(1) )
	GWJ->( dbSetFilter({|| If(Empty(MV_PAR01), .T., GWJ->GWJ_FILIAL >= MV_PAR01) .And. If(Empty(MV_PAR02), .T., GWJ->GWJ_FILIAL <= MV_PAR02) .And. ;
						   If(Empty(MV_PAR03), .T., GWJ->GWJ_NRPF >= MV_PAR03  ) .And. If(Empty(MV_PAR04), .T., GWJ->GWJ_NRPF <= MV_PAR04  ) .And. ;
						   If(Empty(MV_PAR12), .T., GWJ->GWJ_CDTRP >= MV_PAR12 ) .And. If(Empty(MV_PAR13), .T., GWJ->GWJ_CDTRP <= MV_PAR13 ) .And. ;
						   GWJ->GWJ_SIT $ cCond },"") )
	GWJ->( dbGoTop() )
	While !GWJ->( Eof() )
		If MV_PAR05 == 1 /*/MV_PAR05: Manter Data Corrente 1:Sim - 2:Não/*/
			If !(GWJ->GWJ_DTIMPL == DDATABASE)
	    		GWJ->(dbSkip())
	    		Loop
	  		Endif    							
		Else
			If !(IIf(Empty(MV_PAR06), .T., GWJ->GWJ_DTIMPL >= MV_PAR06) .And. IIf(Empty(MV_PAR07), .T., GWJ->GWJ_DTIMPL <= MV_PAR07))/*MV_PAR06: Data de Criacao de - -  MV_PAR07: Data de Criacao ate */
		    	GWJ->(dbSkip())
		    	Loop
			Endif    	
			If !(IIf(Empty(MV_PAR08), .T., GWJ->GWJ_DTVCTO >= MV_PAR08) .And. IIf(Empty(MV_PAR09), .T., GWJ->GWJ_DTVCTO <= MV_PAR09)) /*MV_PAR08:Data Vencimento de - - MV_PAR09: Data Vencimento ate*/
				GWJ->(dbSkip())
				Loop
			Endif  
			If MV_PAR17 == 1 .And. GWJ->GWJ_SIT == "4"  /*MV_PAR17: Se opção de canceladas estiver como SIM  e situacao da pre-fatura for CANCELADA */  
				If !(IIf(Empty(MV_PAR10),.T.,GWJ->GWJ_DTCANC >= MV_PAR10) .And. IIf(Empty(MV_PAR11),.T.,GWJ->GWJ_DTCANC <= MV_PAR11)) /*MV_PAR012:Dt Cancelamento de  - - MV_PAR013: Dt Cancelamento ate*/
			    	GWJ->(dbSkip())
			    	Loop
			    Endif           
			Endif  
			If MV_PAR18 == 2 /*MV_PAR18: Reenviar PreFaturas - 1:Sim; 2:Não */           
				If !Empty(GWJ->GWJ_DTENV)	    	 
			    	GWJ->(dbSkip())
			    	Loop             
		    	Endif
			Endif			
		EndIf
	   
		If ASCAN(aCdTrp,GWJ->GWJ_CDTRP) == 0 
			AADD(aCdTrp,GWJ->GWJ_CDTRP)		
		Endif
		 
		dbSkip()
	EndDo
	
	If Len(aCdTrp) > 0
		For nCnt := 1 To Len(aCdTrp) Step 1
			cCdTrp := aCdTrp[nCnt]
			If MV_PAR19 == 2 .Or. (MV_PAR19 == 1 .And. nCnt == 1) /*Saida: 1-Arquivo 2-Diretório*/
				GFEAUNB(cCdTrp)	/*CABEÇALHO DE INTERCÂMBIO*/
			Endif
			GFEAGERTXT(cCdTrp)	
		Next
		
		If MV_PAR19 == 1 /*Saida: 1-Arquivo 2-Diretório*/
			GFEATOT()
			aResp := GeraTxt(cCdTrp)
		Endif
			
		GWJ->( dbClearFilter() )
		If lMsgErro
			MsgInfo("Erro na exportação do(s) arquivo(s)", STR0007) //"Exportação finalizada. Erro na exportação do(s) arquivo(s)" ### "Exportação"
		Else
			MsgInfo(STR0006+CRLF+MV_PAR20, STR0007) //"Exportação finalizada. Arquivo(s) salvo(s) em: " ### "Exportação"
		Endif
		
	Else
		GWJ->( dbClearFilter() )
		MsgInfo("Não há dados para serem exportados", STR0007) //"Não há dados para serem exportados" ### "Exportação"		
	EndIf
Return .T.       

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEAGERTXT

Função que começa a gravar a variavel para criação do txt 

@param -> cCdTrp = recebe o transportador para o documento

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEAGERTXT(cCdTrp) 
	Local aArea      := GetArea()   
	Local cFilFat    := ""
	Local cNmFilFat  := ""    
	Local cIeEmb     := ""     
	Local aResp      := {}
	Local nFlag      := 0
	
	GFEAUNH() //Cabeçalho da Pré-fatura
	
	GWJ->( dbSetOrder(1) )
	GWJ->( dbSetFilter({|| If(Empty(MV_PAR01), .T., GWJ->GWJ_FILIAL >= MV_PAR01) .And. If(Empty(MV_PAR02), .T., GWJ->GWJ_FILIAL <= MV_PAR02) .And. ;
						   If(Empty(MV_PAR03), .T., GWJ->GWJ_NRPF >= MV_PAR03  ) .And. If(Empty(MV_PAR04), .T., GWJ->GWJ_NRPF <= MV_PAR04  ) .And. ;
						   If(Empty(MV_PAR12), .T., GWJ->GWJ_CDTRP >= MV_PAR12 ) .And. If(Empty(MV_PAR13), .T., GWJ->GWJ_CDTRP <= MV_PAR13 ) .And. ;
						   GWJ->GWJ_SIT $ cCond },"") )
	GWJ->( dbGoTop() )
	While !GWJ->( Eof() )
		If MV_PAR05 == 1 /*/MV_PAR05: Manter Data Corrente 1:Sim - 2:Não/*/
			If !(GWJ->GWJ_DTIMPL == DDATABASE)
	    		GWJ->(dbSkip())
	    		Loop
	  		Endif    							
		Else
			If !(IIf(Empty(MV_PAR06), .T., GWJ->GWJ_DTIMPL >= MV_PAR06) .And. IIf(Empty(MV_PAR07), .T., GWJ->GWJ_DTIMPL <= MV_PAR07))/*MV_PAR06: Data de Criacao de - -  MV_PAR07: Data de Criacao ate */
		    	GWJ->(dbSkip())
		    	Loop
			Endif    	
			If !(IIf(Empty(MV_PAR08), .T., GWJ->GWJ_DTVCTO >= MV_PAR08) .And. IIf(Empty(MV_PAR09), .T., GWJ->GWJ_DTVCTO <= MV_PAR09)) /*MV_PAR08:Data Vencimento de - - MV_PAR09: Data Vencimento ate*/
				GWJ->(dbSkip())
				Loop
			Endif  
			If MV_PAR17 == 1 .And. GWJ->GWJ_SIT == "4"  /*MV_PAR17: Se opção de canceladas estiver como SIM  e situacao da pre-fatura for CANCELADA */  
				If !(IIf(Empty(MV_PAR10),.T.,GWJ->GWJ_DTCANC >= MV_PAR10) .And. IIf(Empty(MV_PAR11),.T.,GWJ->GWJ_DTCANC <= MV_PAR11)) /*MV_PAR012:Dt Cancelamento de  - - MV_PAR013: Dt Cancelamento ate*/
			    	GWJ->(dbSkip())
			    	Loop
			    Endif           
			Endif    
			If MV_PAR18 == 2 /*MV_PAR18: Reenviar PreFaturas*/           
				If !Empty(GWJ->GWJ_DTENV)	    	 
			    	GWJ->(dbSkip())
			    	Loop             
		    	Endif
			Endif			
		EndIf
	    
		cFilFat := GetAdvFVal( 'SM0', 'M0_CGC' , cEmpAnt + GWJ->GWJ_FILIAL , 1, '' )
		cFilFat := StrTran ( cFilFat,"-","")
	    
		cNmFilFat := GetAdvFVal( 'SM0', 'M0_FILIAL' , cEmpAnt + GWJ->GWJ_FILIAL , 1, '' )  
	    
		dbSelectArea("GU3")
 			dbSetOrder(11)
		If dbSeek(xFilial("GU3")+cCgcSMO)
			cIeEmb := GU3->GU3_IE
		Endif  	    
		    
		If GWJ->GWJ_CDTRP == cCdTrp
			If nFlag == 0
		    	cArqTxt += PadR("391",3)
		    	cArqTxt += PadR(cFilFat,15)  
		    	cArqTxt += PadR(StrTran(cIeEmb, ".", ""),15) 
		    	cArqTxt += PadR(cNmFilFat,40)
		   		cArqTxt += PadR("",127)    
		   		cArqTxt += CRLF
		   		nFlag := 1
		   	Endif		 
			GFEADPF() 	 
		Else
			GWJ->( dbSkip() )
			loop
		Endif
			
   		RecLock("GWJ",.F.)
   		GWJ->GWJ_DTENV  := DDATABASE
   		GWJ->GWJ_HRENV  := TIME()
  		GWJ->GWJ_USUENV := cUserName
   		MsUnLock("GWJ")
		
		dbSelectArea("GWJ")
		GWJ->( dbSkip() )
	EndDo     
	
	If MV_PAR19 == 2 /*Saida: 1-Arquivo 2-Diretório*/
		GFEATOT()
		aResp := GeraTxt(cCdTrp)
		RestArea(aArea)
	Endif
Return                                  

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEAUNB

Cabeçalho de intercâmbio - este registro identifica o arquivo gerado.
@author Lidiomar Fernando dos S. Machado
@since 26/11/12
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEAUNB(cCdTrp)
	
	Local cAnoDtBase := ""
	Local cDtBase := DTOC(DDATABASE)

	IF Length(cDtBase) == 8
		cAnoDtBase := Substr(DTOC(DDATABASE),7)
	ELSEIF Length(cDtBase) == 10
		cAnoDtBase := Substr(DTOC(DDATABASE),9)
	ENDIF
	
	If MV_PAR19 == 2
		cArqTxt := ""	
	Endif

	cCgcSMO := GetAdvFVal( 'SM0', 'M0_CGC' , cEmpAnt + cFilAnt, 1, '' )  
	cCgcSMO := StrTran ( cCgcSMO,"-","")
	     
	dbSelectArea("GU3")
	dbSetOrder(11)
	If dbSeek(xFilial("GU3")+cCgcSMO)
		cCxEdiRemet := GU3->GU3_CXEDI
	Endif
	  
	dbSelectArea("GU3")
	dbSetOrder(1)
	If dbSeek(xFilial("GU3")+cCdTrp)
		cCxEdiDest := GU3->GU3_CXEDI
	Endif

	cArqTxt += PadR("000",3)
	cArqTxt += PadR(Alltrim(cCxEdiRemet),35) 
	cArqTxt += PadR(Alltrim(cCxEdiDest),35) 
    cArqTxt += PadR(GFEADTDM()+cAnoDtBase,6)
	cArqTxt += PadR(GFEAHRMN(),4)
	cArqTxt += PadR("PRE"+GFEADTDM()+GFEAHRMN(),12)
	cArqTxt += PadR("",105)     
	cArqTxt += CRLF  	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEAUNH

Cabeçalho da Pré-fatura

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEAUNH()
	cArqTxt += "390"
	cArqTxt += "PREFA"
	cArqTxt += GFEADTDM()                         
	cArqTxt += GFEAHRMN()                       
	cArqTxt += Alltrim(STR(nSeq))   
    cArqTxt += PadR("",183)
	cArqTxt += CRLF 
Return        

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEADPF

Dados da Pré-fatura

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------                  
Static Function GFEADPF() 
	Local cSit     
	Local nVlCalc := 0 
	Local nQtdDoc := 0
	If GWJ->GWJ_SIT == "4"
		cSit := "E"
	Else
		cSit := "I"
	Endif     
	
	dbSelectArea("GWF")
	dbSetOrder(3)
	dbSeek(GWJ->GWJ_FILIAL+GWJ->GWJ_NRPF)
	While !Eof() .And. GWF->GWF_FILIAL == GWJ->GWJ_FILIAL .And. GWF->GWF_NRPREF == GWJ->GWJ_NRPF
		dbSelectArea("GWH")
		dbSetOrder(1)
		dbSeek(xFilial("GWH")+GWF->GWF_NRCALC)
		While !Eof() .And. xFilial("GWH") == GWF->GWF_FILIAL .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
			dbSelectArea("GW1")
			dbSetOrder(1)
			dbSeek(xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC)
			While !Eof() .And. xFilial("GW1") == GWH->GWH_FILIAL .And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC .And. GW1->GW1_EMISDC == GWH->GWH_EMISDC .And. GW1->GW1_SERDC == GWH->GWH_SERDC .And. GW1->GW1_NRDC == GWH->GWH_NRDC	
				nQtdDoc += 1			
				dbSelectArea("GW1")
				dbSkip()
			EndDo		
			dbSelectArea("GWH")
			dbSkip()
		EndDo
		nVlCalc += VLTOTFRET()
		dbSelectArea("GWF")
		dbSkip()
	EndDo
	cArqTxt    += PadR("392",3) //identificador de registro
	cArqTxt    += PadR(GWJ->GWJ_NRPF,20)//identificação da pré-fatura
	cArqTxt    += PadR(Substring(DTOC(GWJ->GWJ_DTIMPL),1,2)+Substring(DTOC(GWJ->GWJ_DTIMPL),4,2)+Substring(DTOC(GWJ->GWJ_DTIMPL),7,10),8)//data de emissão da pré-fatura
	cArqTxt    += PadR(Substring(DTOC(GWJ->GWJ_DTVCTO),1,2)+Substring(DTOC(GWJ->GWJ_DTVCTO),4,2)+Substring(DTOC(GWJ->GWJ_DTVCTO),7,10),8)//data para pagamento da pré-fatura
	cArqTxt    += PadL(Alltrim(STR(nQtdDoc)),4)//qtde de documentos na pré-fatura
	cArqTxt    += PadL(Alltrim(STR(nVlCalc * (10 ^ 2))),15)//valor total da pré-fatura
	cArqTxt    += PadR(cSit,1)  //ação do documento
	cArqTxt    += PadR("",141)//filler 	
	cArqTxt    += CRLF  
	nVlPrefTot += nVlCalc * (10 ^ 2)
	nQtdPref   += 1
	GFEADLP()
Return           

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEADLP

Documentos Liberados para Pagamento

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------      
Static Function GFEADLP() 
	Local cCgcRem   
	Local cNatur
	Local cValRateio := ""
	
	GWF->(dbSetOrder(3))
	GWF->(dbSeek(GWJ->GWJ_FILIAL+GWJ->GWJ_NRPF))
	While GWF->(!Eof()) .And. GWF->GWF_FILIAL == GWJ->GWJ_FILIAL .And. GWF->GWF_NRPREF == GWJ->GWJ_NRPF

		GWH->(dbSetOrder(1))
		GWH->(dbSeek(xFilial("GWH")+GWF->GWF_NRCALC))
		While GWH->(!Eof()) .And. xFilial("GWF") == GWF->GWF_FILIAL .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC

			GW1->(dbSetOrder(1))
			GW1->(dbSeek(xFilial("GW1")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC))
			While GW1->(!Eof()) .And. xFilial("GW1") == GW1->GW1_FILIAL .And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC .And. GW1->GW1_EMISDC == GWH->GWH_EMISDC .And. GW1->GW1_SERDC == GWH->GWH_SERDC .And. GW1->GW1_NRDC == GWH->GWH_NRDC		

				GU3->(dbSetOrder(1))
				If GU3->(dbSeek(xFilial("GU3")+GW1->GW1_CDREM))
					cCgcRem	:= GU3->GU3_IDFED	
				Endif
				 
				cNatur := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDDEST,"GU3_NATUR")
				
				If cNatur == "J"
					cNatur := "1"
				Else
					cNatur := "2"
				Endif
	     			GW4->(dbSetOrder(2)) 
					GW4->(dbSeek(GW1->(GW1_FILIAL+GW1_EMISDC+GW1_SERDC+GW1_NRDC+GW1_CDTPDC)))		
					
					GW3->(dbSetOrder(1))
					GW3->(dbSeek(GW4->(GW4_FILIAL+GW4_CDESP+GW4_EMISDF+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS))))
	
			 		cArqTxt += PadR("393",3)
			    	cArqTxt += PadR(cCgcRem,15)
					cArqTxt += PadR(TRANSFORM(GW1->GW1_SERDC, "!!!"),5)
					cArqTxt += PadL(GW1->GW1_NRDC,20)
					cArqTxt += PadL(Substring(DTOC(GW1->GW1_DTEMIS),1,2)+Substring(DTOC(GW1->GW1_DTEMIS),4,2)+Substring(DTOC(GW1->GW1_DTEMIS),7,10),8)	
		   			cArqTxt += PadL(GW3->GW3_SERDF,5)
		   			cArqTxt += PadL(GW3->GW3_NRDF,12)
		   			cArqTxt += PadL(Substring(DTOC( GW3->GW3_DTEMIS),1,2)+Substring(DTOC( GW3->GW3_DTEMIS),4,2)+Substring(DTOC( GW3->GW3_DTEMIS),7,10),8)
					cArqTxt += PadL(Posicione("GU3", 1, xFilial("GU3") + GW3->GW3_CDREM, "GU3->GU3_IDFED"),15)
					cArqTxt += PadL(Posicione("GU3", 1, xFilial("GU3") + GW3->GW3_CDDEST, "GU3->GU3_IDFED"),15)	   	
					cArqTxt += PadR(cNatur,1)
					
					cValRateio := CVALTOCHAR(TRANSFORM(GFERATFRTDC(GWF->GWF_NRCALC, GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC), "@E 999999.99")  )
					cArqTxt += PadL(StrTran(cValRateio, ",", ""),15) //Valor do rateio 
		   			
		   			cArqTxt += PadL("0",15)
		   			cArqTxt += PadL("0",1)
					cArqTxt += PadL("0",15)
					cArqTxt += PadR("",47)
					cArqTxt += CRLF
					GFEAVFC(GWF->GWF_NRCALC) // 394 - Valor do frete calculado pelo embarcador
					GFEANFC() // 396 - Notas fiscais do conhecimento liberado para pagamento

				GW1->(dbSkip())
			EndDo
			GWH->(dbSkip())
		EndDo
		GWF->(dbSkip())
	EndDo    
Return             

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEAVFC
Valor do frete calculado pelo embarcador
@author Lidiomar Fernando dos S. Machado
@since 29/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFEAVFC(cNrCalc)
	
	Local nFrtUnid  	:= 0
	Local nFrtValor 	:= 0
	Local nFrtTaxa  	:= 0
	Local nFrtPedag 	:= 0
	Local nBaseICMS 	:= 0
	Local nVlICMS   	:= 0
	Local nVlISS    	:= 0
	Local aAreaGWF  	:= GWF->( GetArea() )
	Local aAreaGV2  	:= GV2->( GetArea() )
	Local aAreaGW8  	:= GW8->( GetArea() )
	Local aAreaGWH  	:= GWH->( GetArea() )
	Local aAreaGWI  	:= GWI->( GetArea() )	
	//valores do rateio
	Local nPesoR    	:= 0
	Local nVolum    	:= 0
	Local nQtd      	:= 0
	Local nValor    	:= 0
	Local cCriRat   	:= IIf(Empty(SuperGetMv("MV_CRIRAT",,"1")), "1", SuperGetMv("MV_CRIRAT",,"1"))
	//valores totais para rateio
	Local nTotPesoR 	:= 0
	Local nTotVolum 	:= 0
	Local nTotQtd   	:= 0
	Local nTotValor 	:= 0
	//valores rateados
	Local nRatFUnid  	:= 0
	Local nRatFValor 	:= 0
	Local nRatFTaxa  	:= 0
	Local nRatFPedag 	:= 0
	Local nRatBICMS  	:= 0
	Local nRatVlICMS 	:= 0
	Local nRatVlISS  	:= 0
	Local cRatFUnid		:=  ""
	Local cRatFPedag	:=  ""
	Local cRatFTaxa		:=  ""
	Local cRatVlISS		:=	""
	Local cRatBICMS		:=	""
	Local cRatVlICMS	:=	""
	Local cRatFValor	:=	""
	Local cPesoR		:=	""
	
	GWF->( dbSetOrder(1) )
	If GWF->( dbSeek(GW1->GW1_FILIAL + cNrCalc) )
		
		nBaseICMS := GWF->GWF_BASICM
		
		nVlICMS := GWF->GWF_VLICMS
		nVlISS  := GWF->GWF_VLISS
		
		GWI->( dbSetOrder(1) )
		GWI->( dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC) )
		While !GWI->( Eof() ) .And. GWI->GWI_FILIAL == GWF->GWF_FILIAL .And. GWI->GWI_NRCALC == GWF->GWF_NRCALC
			
			GV2->( dbSetOrder(1) )
			If GV2->( dbSeek(xFilial("GV2") + GWI->GWI_CDCOMP) )
				
				If GV2->GV2_CATVAL == "1"
					nFrtUnid += GWI->GWI_VLFRET
				ElseIf GV2->GV2_CATVAL == "2"
					nFrtValor += GWI->GWI_VLFRET
				ElseIf GV2->GV2_CATVAL == "3"
					nFrtTaxa += GWI->GWI_VLFRET
				ElseIf GV2->GV2_CATVAL == "4"
					nFrtPedag += GWI->GWI_VLFRET
				EndIf
				
			EndIf
			
			GWI->( dbSkip() )
		EndDo
		
	EndIf
	
	GWH->( dbSetOrder(1) )
	GWH->( dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC) )
	While !GWH->( Eof() ) .And. GWH->GWH_FILIAL == GWF->GWF_FILIAL .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
		
		GW8->( dbSetOrder(1) )
		GW8->( dbSeek(GWH->GWH_FILIAL + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC) )		
		While !GW8->( Eof() ).And. ;
			GW8->GW8_FILIAL == GWH->GWH_FILIAL .And. ;
			GW8->GW8_CDTPDC == GWH->GWH_CDTPDC .And. ;
			GW8->GW8_EMISDC == GWH->GWH_EMISDC .And. ;
			GW8->GW8_SERDC == GWH->GWH_SERDC .And. ;
			GW8->GW8_NRDC == GWH->GWH_NRDC
						
			nTotPesoR += GW8->GW8_PESOR
			nTotVolum += GW8->GW8_VOLUME
			nTotQtd   += GW8->GW8_QTDE
			nTotValor += GW8->GW8_VALOR
			
			GW8->( dbSkip() ) 
		EndDo
		
		GWH->( dbSkip() )
	EndDo
	
	GW8->( dbSetOrder(1) )
	GW8->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )		
	While !GW8->( Eof() ).And. ;
		GW8->GW8_FILIAL == GW1->GW1_FILIAL .And. ;
		GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. ;
		GW8->GW8_EMISDC == GW1->GW1_EMISDC .And. ;
		GW8->GW8_SERDC == GW1->GW1_SERDC .And. ;
		GW8->GW8_NRDC == GW1->GW1_NRDC
		
		If GW8->GW8_PESOC > GW8->GW8_PESOR
			nPesoR += GW8->GW8_PESOC
		Else
			nPesoR += GW8->GW8_PESOR
		EndIf
		
		nVolum += GW8->GW8_VOLUME
		nQtd   += GW8->GW8_QTDE
		nValor += GW8->GW8_VALOR
		
		GW8->( dbSkip() ) 
	EndDo
	
	If cCriRat == "1" //peso
		nRatFUnid  := nFrtUnid * nPesoR / nTotPesoR
		nRatFValor := nFrtValor * nPesoR / nTotPesoR
		nRatFTaxa  := nFrtTaxa * nPesoR / nTotPesoR
		nRatFPedag := nFrtPedag * nPesoR / nTotPesoR
		nRatBICMS  := nBaseICMS * nPesoR / nTotPesoR
		nRatVlICMS := nVlICMS * nPesoR / nTotPesoR
		nRatVlISS  := nVlISS * nPesoR / nTotPesoR
	ElseIf cCriRat == "2" //valor
		nRatFUnid  := nFrtUnid * nValor / nTotValor
		nRatFValor := nFrtValor * nValor / nTotValor
		nRatFTaxa  := nFrtTaxa * nValor / nTotValor
		nRatFPedag := nFrtPedag * nValor / nTotValor
		nRatBICMS  := nBaseICMS * nValor / nTotValor
		nRatVlICMS := nVlICMS * nValor / nTotValor
		nRatVlISS  := nVlISS * nValor / nTotValor 
	ElseIf cCriRat == "3" //volume
		nRatFUnid  := nFrtUnid * nVolum / nTotVolum
		nRatFValor := nFrtValor * nVolum / nTotVolum
		nRatFTaxa  := nFrtTaxa * nVolum / nTotVolum
		nRatFPedag := nFrtPedag * nVolum / nTotVolum
		nRatBICMS  := nBaseICMS * nVolum / nTotVolum
		nRatVlICMS := nVlICMS * nVolum / nTotVolum
		nRatVlISS  := nVlISS * nVolum / nTotVolum
	ElseIf cCriRat == "4" //quantidade
		nRatFUnid  := nFrtUnid * nQtd / nTotQtd
		nRatFValor := nFrtValor * nQtd / nTotQtd
		nRatFTaxa  := nFrtTaxa * nQtd / nTotQtd
		nRatFPedag := nFrtPedag * nQtd / nTotQtd
		nRatBICMS  := nBaseICMS * nQtd / nTotQtd
		nRatVlICMS := nVlICMS * nQtd / nTotQtd
		nRatVlISS  := nVlISS * nQtd / nTotQtd
	EndIf
	
	cRatFUnid	:=  StrTran(CVALTOCHAR(nRatFUnid*100), ".", "")
	cRatFPedag	:=  StrTran(CVALTOCHAR(nRatFPedag*100), ".", "")
	cRatFTaxa	:=  StrTran(CVALTOCHAR(nRatFTaxa*100), ".", "")
	cRatVlISS	:=	StrTran(CVALTOCHAR(nRatVlISS*100), ".", "")
	cRatBICMS	:=	StrTran(CVALTOCHAR(nRatBICMS*100), ".", "")
	cRatVlICMS	:=	StrTran(CVALTOCHAR(nRatVlICMS*100), ".", "")
	cRatFValor	:=	StrTran(CVALTOCHAR(nRatFValor*100), ".", "")	
	cPesoR		:=	StrTran(CVALTOCHAR(nPesoR*100), ".", "")
	
	cArqTxt += PadL("394",3) 			     		  // Identificador do registro
	cArqTxt += PadL(cRatFUnid,15, "0")    // * Valor do frete por peso / volume;  posição: 001 valor rateado para o DC //04
	cArqTxt += PadL("000000000000000",15, "0")   		 // Valor SEC - CAT;                    posição: 019 
	cArqTxt += PadL("000000000000000",15, "0")   		 // VALOR ITR; 							 posição: 034 
	cArqTxt += PadL(cRatFPedag,15, "0")   		 // VALOR DO PEDÁGIO;                   posição: 049 
	cArqTxt += PadL(cRatFTaxa,15, "0")   		 // VALORES DIVERSOS/OUTROS;            posição: 064
	cArqTxt += PadL("000000000000000",15, "0")         // VALOR DE DESCONTO;                  posição: 079
	cArqTxt += PadL("000000000000000",15, "0")         // VALOR ADEME;                        posição: 094
	cArqTxt += PadL("00000",5, "0")              	   // % DE TAXA DO ISS;                    posição: 109
	cArqTxt += PadL(cRatVlISS,15, "0")   // VALOR DO ISS;                        posição: 114
	cArqTxt += PadL(cRatBICMS,15, "0")        // BASE DE CÁLCULO PARA APURAÇÃO ICMS;  posição: 129
	cArqTxt += PadL("000000000000000",5, "0")         // % DE TAXA DO ICMS;                   posição: 144
	cArqTxt += PadL(cRatVlICMS,15, "0")  // VALOR DO ICMS;                       posição: 149
	cArqTxt += PadL(cRatFValor,15, "0") 		   // VALOR DO FRETE AD VALOREM;           posição: 164
	cArqTxt += PadL("000000000000000",15, "0")        // VALOR DO DESPACHO;                   posição: 179
	cArqTxt += PadL(cPesoR,7, "0")    // PESO A SER TRANSPORTADO;             posição: 194 peso DC soma dos itens
	cArqTxt += CRLF
	
	RestArea(aAreaGWF)
	RestArea(aAreaGV2)
	RestArea(aAreaGW8)
	RestArea(aAreaGWH)
	RestArea(aAreaGWI)
	
Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEANFC
N F C  - notas fiscais do conhecimento liberado para pagamento
@author Lidiomar Fernando dos S. Machado
@since 29/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFEANFC()
	Local cEmisDf
	Local cCdesp
	Local cSerdf
	Local cNrdf
	Local nQtdDoc   := 1
	
	dbSelectArea("GW4")
	dbSetOrder(2)
	If dbSeek(xFilial("GW4")+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+GW1->GW1_CDTPDC)
		cEmisDf := GW4->GW4_EMISDF
		cCdesp  := GW4->GW4_CDESP
		cSerdf  := GW4->GW4_SERDF
		cNrdf   := GW4->GW4_NRDF
		dDtEmis := GW4->GW4_DTEMIS
		dbSelectArea("GW4")
		dbSetOrder(1)
		dbSeek(xFilial("GW4")+cEmisDf+cCdesp+cSerdf+cNrdf+DTOS(dDtEmis))
		While !GW4->(Eof()) .And. ;
			GW4->GW4_EMISDF  == cEmisDf .And.;
			GW4->GW4_CDESP   == cCdesp .And.; 
			GW4->GW4_SERDF   == cSerdf .And.;
			GW4->GW4_NRDF    == cNrdf .And.;
			GW4->GW4_DTEMIS  == dDtEmis

			If nQtdDoc == 1
				cArqTxt += PadR("396",3)					
			EndIf
			
			cArqTxt += PadR(TRANSFORM(GW4->GW4_SERDC, "!!!"),3)
			cArqTxt += PadR(GW4->GW4_NRDC,8)
			
			If nQtdDoc/15 == 1
				cArqTxt += Space(31)
				cArqTxt += CRLF
				nQtdDoc := 0
			EndIf				
			
			nQtdDoc++
			dbSkip()
		EndDo
		
		While nQtdDoc <= 15
			cArqTxt += Space(3)
			cArqTxt += Space(8)
			nQtdDoc++
		EndDo
		cArqTxt += Space(31)
		cArqTxt += CRLF
	EndIf		
Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEATOT

Totais das Pré-faturas

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------                            
Static Function GFEATOT() 
	cArqTxt += PadR("399",3)
	cArqTxt += PadL(Alltrim(STR(nVlPrefTot)),15)
	cArqTxt += PadL(Alltrim(STR(nQtdPref))  ,15)
	cArqTxt += PadR("",167)
	cArqTxt += CRLF 
Return 
                       
//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTxt

Gera o txt das Pré-faturas

@author Jorge Matos Valcanaia
@since 10/06/10
@version 1.0
/*/
//-------------------------------------------------------------------   
Static Function GeraTxt(cCdTrp)
	//+-----------------------------------------------------------------------------
	//| Cria o arquivo texto
	//+-----------------------------------------------------------------------------
	Private cDiretorio 
	Private nHdl 
	
	IF MV_PAR19 == 1 /*Saida: 1-Arquivo 2-Diretório*/                                                                    
		cDiretorio :=  Alltrim(MV_PAR20)
	Else
		cDiretorio :=  Alltrim(MV_PAR20)+"\"+"PREFA"+"_"+Alltrim(cCdTrp)+"_"+DTOS(DDATABASE)+".TXT"
	Endif
		
	
	nHdl := fCreate(cDiretorio) 
	
	If nHdl == -1
		lMsgErro := .T.
		MsgAlert(STR0001+cDiretorio+STR0002,STR0003) //"O arquivo de nome "###" não pode ser executado! Verifique os parâmetros."###"Atenção!"
		Return .F.
	Endif             
		
	If fWrite(nHdl,cArqTxt,Len(cArqTxt)) != Len(cArqTxt)
		If !MsgAlert(STR0004+STR0005,STR0003) //"Ocorreu um erro na gravação do arquivo."###"Continua?"###"Atenção!"
		Endif
	Endif 
		
	fClose(nHdl)              

	cCGCSMO      := ""
	cCxEdiRemet  := ""
	cCxEdiDest   := ""
  	nVlPrefTot   := 0
	nQtdPref     := 0       
Return {.T., cDiretorio}
