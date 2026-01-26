#INCLUDE "SPEDFISCAL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SPEDXDEF.CH"

/*/{Protheus.doc} RegD700
	D700  Nota Fiscal Fatura Eletrônica de Serviços de Comunicação – NFCom (Código 62)	
	@type  Function
	@author Talita Teixeira
	@since 18/06/2025
	@version 12.1.24
	@param aRegD700, array, array com as informacoes da nota fical de telecomunicação 
	@param lAchouSFX, lógico, Flag de posicionamento da tabela SFX  
	@param aRegC100, array, Array base para geracao do registro D700 
	@param aCmpAntSFT, array, Campos salvos da tabela SFT antes do skip 
	@param cSituaDoc, caracter, Situacao do documento fiscal
/*/

STATIC nTamFT_IT	:= TAMSX3("FT_ITEM")[1]
STATIC aSPDSX3		:=	SpedLoadX3()
STATIC aSPDFil		:=  fGetSpdFil()

Function RegD700(cAlias, cAliasSFT, nRelac, aCmpAntSFT, aRegD700, lAchouSFX, lGravaD700, lAchouCDD, cSituaDoc,aInfCompl, cALiasCDD, aRegC100, cRelacDoc, lNaoGrvcCla, cSituaDoc, cEntSai, cAliasSF4, cEspecie )
	
    Local nPosD700  := 0
	Local nVlTerc   := 0
    Local cCodInf   := ""
    Local cFinDoc   := "0"
    Local lNfAtiva	:= !cSituaDoc$"02#04#05" //Cancelada /denegada e inutilizada
    Local cModRef   := ""
	Local cSerRef	:= ""
	Local cNumRef	:= ""
	Local cMAnoRef	:= ""
	Local cIndOper	:= ""
	Local cIndEmit  := ""
	Local cTipFat	:= ""
	Local cChvRef	:= ""
	Local cMunDes   := ""

	If cEntSai == "1"
		cIndOper := "0"

		If aCmpAntSFT[8] == "S" 
			cIndEmit := "0"
		Else
			cIndEmit := "1"
		EndIf
	Else
		cIndOper := "1"
		cIndEmit := "0"

		If SPEDSeek("SA1",1,xFilial("SA1")+aCmpAntSFT[3]+aCmpAntSFT[4])
			cMunDes := UfCodIBGE(SA1->A1_EST) + SA1->A1_COD_MUN
		Endif
	EndIf

	
  IF lNfAtiva

    If lAchouSFX
		nVlTerc  := SFX->FX_VALTERC
		
		If SFX->FX_TIPOREC  == "0"  
			cTipFat:= "0" //Faturamento Normal;
		ElseIf SFX->FX_TIPOREC  == "5"
			cTipFat:= "2" //Co-faturamento
		ElseIf SFX->FX_TIPOREC  == "7"
			cTipFat:= "1" //Faturamento centralizado
		EndIf

	EndIf

    If Len(aInfCompl) > 0
        cCodInf:= aInfCompl[1]
    EndIf

	If lAchouCDD
		cSerRef		:= (cAliasCDD)->CDD_SERREF
		cNumRef		:= (cAliasCDD)->CDD_DOCREF
		cMAnoRef	:= (cAliasCDD)->CDD_MEANRF
		cModRef     := aModnot((cAliasCDD)->CDD_MODREF)

		If 	!Empty((cAliasCDD)->CDD_DOCREF) .And. !Empty((cAliasCDD)->CDD_SERREF) .And. (cAliasSF4)->F4_AJUSTE == "S"
			cFinDoc := "4"
			cChvRef := (cAliasCDD)-> CDD_CHVNFE
		ElseIf !Empty((cAliasCDD)->CDD_DOCREF) .And. !Empty((cAliasCDD)->CDD_SERREF) .And. (cAliasSF4)->F4_AJUSTE <> "S"
			cFinDoc := "3"
			cChvRef := (cAliasCDD)-> CDD_CHVNFE
		EndIf

	Endif

			aAdd(aRegD700, {})
			nPosD700	:=	Len (aRegD700)

			aAdd (aRegD700[nPosD700], "D700")			 										//01 - REG  
			aAdd (aRegD700[nPosD700], cIndOper)							    					//02 - IND_OPER
			aAdd (aRegD700[nPosD700], cIndEmit)	   												//03 - IND_EMIT	

		If cIndOper == "0"
			aAdd (aRegD700[nPosD700], aRegC100[1][4])											//04 - COD_PART
		ElseIf cIndOper == "1"
			aAdd (aRegD700[nPosD700], "")														//04 - COD_PART
		EndIf

			aAdd (aRegD700[nPosD700], cEspecie)					   								//05 - COD_MOD		
			aAdd (aRegD700[nPosD700], cSituaDoc)	   											//06 - COD_SIT		
			aAdd (aRegD700[nPosD700], aCmpAntSFT[2])   		                     				//07 - SER    
			aAdd (aRegD700[nPosD700], aCmpAntSFT[1])						       				//08 - NUM_DOC 
			aAdd (aRegD700[nPosD700], aCmpAntSFT[6])	   			 							//09 - DT_DOC	

		If cIndOper == "0"
			aAdd (aRegD700[nPosD700], aCmpAntSFT[5])			   								//10 - DT_E_S	

			If !lNaoGrvcCla 
				aAdd (aRegD700[nPosD700], aRegC100[1][12])											//11 - VL_DOC
				aAdd (aRegD700[nPosD700], aRegC100[1][14])											//12 - VL_DESC
				aAdd (aRegD700[nPosD700], aRegC100[1][12])											//13 - VL_SERV
				aAdd (aRegD700[nPosD700], aRegC100[1][15])											//14 - VL_SERV_NT	
				aAdd (aRegD700[nPosD700], nVlTerc)				       						 		//15 - VL_TERC
				aAdd (aRegD700[nPosD700], aRegC100[1][20])											//16 - VL_DA
			Else
				aAdd (aRegD700[nPosD700], "0")													//11 - VL_DOC
				aAdd (aRegD700[nPosD700], "0")													//12 - VL_DESC
				aAdd (aRegD700[nPosD700], "0")													//13 - VL_SERV
				aAdd (aRegD700[nPosD700], "0")													//14 - VL_SERV_NT	
				aAdd (aRegD700[nPosD700], "0")				       						 		//15 - VL_TERC
				aAdd (aRegD700[nPosD700], "0")													//16 - VL_DA
			EndIf
		Else
			aAdd (aRegD700[nPosD700], "")			   											//10 - DT_E_S	
			aAdd (aRegD700[nPosD700], aRegC100[1][12])											//11 - VL_DOC
			aAdd (aRegD700[nPosD700], aRegC100[1][14])											//12 - VL_DESC
			aAdd (aRegD700[nPosD700], aRegC100[1][12])											//13 - VL_SERV
			aAdd (aRegD700[nPosD700], aRegC100[1][15])											//14 - VL_SERV_NT	
			aAdd (aRegD700[nPosD700], nVlTerc)				       					 			//15 - VL_TERC
			aAdd (aRegD700[nPosD700], aRegC100[1][20])											//16 - VL_DA
		EndIf 
		
		If (cIndOper=="0" .And. aCmpAntSFT[15] > 0) .Or. cIndOper=="1" 
			aAdd (aRegD700[nPosD700], aRegC100[1][21])											//17 - VL_BC_ICMS
			aAdd (aRegD700[nPosD700], aRegC100[1][22])											//18 - VL_ICMS
		Else
			aAdd (aRegD700[nPosD700], "0")														//17 - VL_BC_ICMS
			aAdd (aRegD700[nPosD700], "0")														//18 - VL_ICMS
		EndIf
		
			aAdd (aRegD700[nPosD700], cCodInf)													//19 - COD_INF
			aAdd (aRegD700[nPosD700], aRegC100[1][26])											//20 - VL_PIS
			aAdd (aRegD700[nPosD700], aRegC100[1][27])											//21 - VL_COFINS
			aAdd (aRegD700[nPosD700], aCmpAntSFT[25])											//22 - CHV_DOCe
			aAdd (aRegD700[nPosD700], cFinDoc)						        					//23 - FIN_DOCe

			aAdd (aRegD700[nPosD700], cTipFat)													//24 - TIP_FAT

		If !Empty(aCmpAntSFT[38]) .And. cFinDoc == "3"
			aAdd (aRegD700[nPosD700], cModRef )													//25 - COD_MOD_DOC_REF
		Else
			aAdd (aRegD700[nPosD700], "")														//25 - COD_MOD_DOC_REF
		EndIf

		If cModRef $"62" .And. cFinDoc == "3"
			aAdd (aRegD700[nPosD700], cChvRef)   												//26 - CHV_DOCe_REF
		Else
			aAdd (aRegD700[nPosD700], "")   													//26 - CHV_DOCe_REF
		EndIf
		
		If cModRef $"21#22"
			aAdd (aRegD700[nPosD700], (cAliasSFT)->F3_MDCAT79)									//27 - HASH_DOC_REF
			aAdd (aRegD700[nPosD700], cSerRef)													//28 - SER_DOC_REF
			aAdd (aRegD700[nPosD700], cNumRef)													//29 - NUM_DOC_REF
			aAdd (aRegD700[nPosD700], cMAnoRef)													//30 - MES_DOC_REF
		ElseIf !Empty(aRegC100[1][5])
			aAdd (aRegD700[nPosD700], "")														//27 - HASH_DOC_REF
			aAdd (aRegD700[nPosD700], "")														//28 - SER_DOC_REF
			aAdd (aRegD700[nPosD700], "")														//29 - NUM_DOC_REF
			aAdd (aRegD700[nPosD700], "")														//30 - MES_DOC_REF
		EndIf
		
			aAdd (aRegD700[nPosD700], cMunDes)													//31 - COD_MUN_DEST
			aAdd (aRegD700[nPosD700], "")														//32 - DED
			aAdd (aRegD700[nPosD700], RetRD(GetRelacPr())+strzero(nPosD700,nTamFT_IT))
	Endif

Return 

/*/{Protheus.doc} RegD730
Registro analítico Nota Fiscal Fatura Eletrônica de Serviços de Comunicação – NFCom (Código 62)  	
	Atribui em um array o conteudo a ser gravado no TRB atraves da funcao GrvRegTrS com as informacoes contidas no array aRegC170(Itens) aglutinados CFOP, CST e ALIQ. 
	@type  Function
	@author Talita Teixeira
	@since 18/06/2025
	@version 12.1.24
	@param aRegC170, array, Informacoes dos Itens do documento fiscal  
	@param cAliasSFT, caracter, Alias da tabela SFT posicionada no momento  
	@param aRegC100, array, Array base para geracao do registro D700 
	@param aCmpAntSFT, array, Campos salvos da tabela SFT antes do skip 
	@param cSituaDoc, caracter, Situacao do documento fiscal
/*/

Function RegD730(cAlias, aRegC170, cAliasSFT,aCmpAntSFT, aRegD730,nRedBSICM, aWizard, aRegD731, cVersao, cEntSai, cEspecie, oRegD730, oRegD731)

Local nPosD730		:= 0
Local nPosD731		:= 0
Local cFilD730		:= ""
Local cFilD731		:= ""

	If oRegD730 == Nil 
		oRegD730:= JsonObject():New()
	EndIf
		
	cFilD730:= aRegC170[1][10]+aRegC170[1][11]+cValToChar(aRegC170[1][14])+aCmpAntSFT[1]

	SPesqjSon(oRegD730, cFilD730, @nPosD730)

		If nPosD730 == 0
			aAdd(aRegD730, {})
			nPosD730	:= Len (aRegD730)
			aAdd (aRegD730[nPosD730], nPosD730)	 								//01 - Relação com Registro D730 Pai
			aAdd (aRegD730[nPosD730], "D730")	 	   							//02 - REG
			aAdd (aRegD730[nPosD730], aRegC170[1][10])							//03 - CST_ICMS
			aAdd (aRegD730[nPosD730], aCmpAntSFT[9])							//04 - CFOP
			aAdd (aRegD730[nPosD730], aCmpAntSFT[14])							//05 - ALIQ_ICMS
			aAdd (aRegD730[nPosD730], (cAliasSFT)->FT_VALCONT)					//06 - VL_OPR
			aAdd (aRegD730[nPosD730], aCmpAntSFT[13] )							//07 - VL_BC_ICMS
			aAdd (aRegD730[nPosD730], aCmpAntSFT[15])	 						//08 - VL_ICMS
			aAdd (aRegD730[nPosD730], nRedBSICM)	 							//09 - VL_RED_BC
			aAdd (aRegD730[nPosD730], "")	 		  							//10 - COD_OBS
			aAdd (aRegD730[nPosD730], RetRD(GetRelacPr())+strzero(nPosD730,nTamFT_IT))//11 - CHAVE DE RELACIONAMENTO
			oRegD730[cFilD730] := nPosD730
		Else
			aRegD730[nPosD730][6]+=	(cAliasSFT)->FT_VALCONT						//06 - VL_OPR
			If (cEntSai=="1" .And. aCmpAntSFT[15] > 0 ) .Or. cEntSai  == "2"
				aRegD730[nPosD730][7]+= aCmpAntSFT[13]							//07 - VL_BC_ICMS
				aRegD730[nPosD730][8]+= aCmpAntSFT[15]							//08 - VL_ICMS
			EndIf 		
			aRegD730[nPosD730][9]+= nRedBSICM	 								//09 - VL_RED_BC  	
		EndIf				
	

		//REGISTRO D731: INFORMAÇÕES DO FUNDO DE COMBATE À POBREZA – FCP – (CÓDIGO 62)		
		If aWizard[1][23]=="1-Sim" .and. cVersao >= "014" .and. cEspecie $ "62"
			
			If oRegD731 == Nil
				oRegD731:= JsonObject():New()
			EndIf 

			If ((cAliasSFT)->FT_VALFECP) > 0
				cFilD731:= cValtochar(nPosD731) + aCmpAntSFT[1]
				SPesqjSon(oRegD731, cFilD731, @nPosD731)
				IF nPosD731 == 0	
					aAdd(aRegD731, {})
					nPosD731	:=	Len(aRegD731)
					aAdd (aRegD731[nPosD731], nPosD730)	 					//Relação com Registro D730 Pai
					aAdd (aRegD731[nPosD731], "D731")						//01 - REG
					aAdd (aRegD731[nPosD731], (cAliasSFT)->FT_VALFECP)		//02 - VL_FCP_OP
					aAdd (aRegD731[nPosD731], RetRD(GetRelacPr())+strzero(nPosD730,nTamFT_IT))		//5 - Posição de Hierarquia  		

					oRegD731[cFilD731] := nPosD731 
				Else
					aRegD731[nPosD731][3]	+=	(cAliasSFT)->FT_VALFECP		//02 - VL_FCP_OP
				Endif
			Endif
					
		EndIf

		

Return

/*/{Protheus.doc} D735D737
REGISTRO D735 - OBSERVAÇÕES DO LANÇAMENTO FISCAL (CÓDIGO 62)
REGISTRO D737 - OUTRAS OBRIGAÇÕES TRIBUTÁRIAS, AJUSTES E INFORMAÇÕES DE VALORES PROVENIENTES DE DOCUMENTO FISCAL   
	@type  Function
	@author Talita Teixeira
	@since 18/06/2025
	@version 12.1.24
	@param cAlias, caracter, Alias do TRB que recebera as informacoes  
	@param aRegD735, array, Array com as informações do registro D735
	@param aRegD737, array, Array com as informações do registro D737
	@param aLanCDA, array, Array com os lancamentos da tabela CDA 
	@param aCmpAntSFT, array, Campos salvos da tabela SFT antes do skip 
	@param cEspecie, caracter, Especie do documento fiscal    
/*/

Function D735D737(cAlias, aRegD735, aRegD737, aLanCDA, cRelacDoc, aReg0460, aRegD700, oRegD735, oRegD737, cEspecie, cMVEstado, aReg0200, aReg0190, aReg0220, aWizard, aD735aux)
	Local	nPos		:=	0
	Local	nPosD735	:=	0
	Local	nX			:=	0
	Local 	nPosD700	:=  0
	Local 	cFilD735	:=  ""
	Local	cCodItem	:=	""
	Local 	dDataDe     :=	SToD(aWizard[1][1])
	Local 	dDataAte    :=	SToD(aWizard[1][2])
	Local 	cFilD737	:= ""

	If oRegD735 == Nil 
		oRegD735:= JsonObject():New()
	EndIf 

	If oRegD737 == Nil 
		oRegD737:= JsonObject():New()
	EndIf 

		//³Processando lancamentos do documento fiscal relacionados no CDA³
	For nX := 1 to len(aLanCDA)

		cCodItem	:=	aLanCDA[nX,13]

		cFilD735:= aLanCDA[nX][07] + aLanCDA[nX][10]
		SPesqjSon(oRegD735, cFilD735, @nPosD735)

		//³Geracao do REGISTRO D735
		If nPosD735 ==0
			aAdd(aRegD735, {})
			nPosD700:=	Len (aRegD700)
			nPosD735	:=	Len (aRegD735)
			aAdd (aRegD735[nPosD735], nPosD700)												//01 - RELACIONAMENTO 	
			aAdd (aRegD735[nPosD735], "D735")		 	   									//02 - REG
			aAdd (aRegD735[nPosD735], aLanCDA[nX][07])										//03 - COD_OBS
			aAdd (aRegD735[nPosD735], aLanCDA[nX][17])		   								//04 - TXT_COMPL	
			aAdd (aRegD735[nPosD735], RetRD(GetRelacPr())+strzero(nPosD735,nTamFT_IT)) 		//05 - - Posição de Hierarquia
			oRegD735[cFilD735] := nPosD735

			//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL
			Reg0460(@aReg0460,{aLanCDA[nX][7],aLanCDA[nX][20]})

		EndIf

		If !aLanCDA[nX,24] // Legado (Código de lançamento vindo da TES)
			
			cFilD737:= cValtochar(nPosD735) + cCodItem + aLanCDA[nX,1]
			SPesqjSon(oRegD737, cFilD737, @nPos)
		
		Else
			//Estrutura do configurador
			If aLanCDA[nX,23] == "01"
				cFilD737:= cValtochar(nPosD735) + aLanCDA[nX,1] 
				SPesqjSon(oRegD737, cFilD737, @nPos)
			ElseIf aLanCDA[nX,23] == "02"
				cFilD737:= cValtochar(nPosD735) + aLanCDA[nX,1] + aLanCDA[nX][2]
				SPesqjSon(oRegD737, cFilD737, @nPos)
			Elseif aLanCDA[nX,23] == "03"
				cFilD737:= cValtochar(nPosD735) + cCodItem + aLanCDA[nX,1]
				SPesqjSon(oRegD737, cFilD737, @nPos)
			Else
				cFilD737:= cValtochar(nPosD735) + cCodItem + aLanCDA[nX,1]
				SPesqjSon(oRegD737, cFilD737, @nPos)
			Endif	
		Endif

		
		//³Geracao do REGISTRO D737
			If nPos == 0
				aAdd(aRegD737, {})
				nPos	:=	Len (aRegD737)
				aAdd (aRegD737[nPos], nPosD735)																			//01 - RELACIONAMENTO COM D735 (PAI)
				aAdd (aRegD737[nPos], "D737")	   																		//02 - REG
				aAdd (aRegD737[nPos], aLanCDA[nX,1])				       												//03 - COD_AJ
				aAdd (aRegD737[nPos], aLanCDA[nX][2])					   												//04 - DESCR_COMPL_AJ
				aAdd (aRegD737[nPos], cCodItem)																			//05 - COD_ITEM
				aAdd (aRegD737[nPos], aLanCDA[nX][3])																	//06 - VL_BC_ICMS
			 	aAdd (aRegD737[nPos], aLanCDA[nX][4])	 																//07 - ALIQ_ICMS
				aAdd (aRegD737[nPos], aLanCDA[nX][5])																	//08 - VL_ICMS
				aAdd (aRegD737[nPos], aLanCDA[nX][6])																	//09 - VL_OUTROS
		
				aAdd (aRegD737[nPos], RetRD(GetRelacPr())+strzero(nPosD735,nTamFT_IT))									//10 - - Posição de Hierarquia

				oRegD737[cFilD737] := nPos
			Else
				aRegD737[nPos][6]	+= aLanCDA[nX][3]																	//06 - VL_BC_ICMS
				aRegD737[nPos][8]	+= aLanCDA[nX][5]																	//08 - VL_ICMS
				aRegD737[nPos][9]	+= aLanCDA[nX][6]																	//09 - VL_OUTROS
	
			EndIf

		//³Tratamento para que os itens utilizados seja gerados no 0200³
		If !Empty( cCodItem ) .And.  aScan ( aReg0200, { |aX| aX[2] == cCodItem }) == 0
			SPEDSeek("SB1",,aSPDFil[PFIL_SB1]+cCodItem)
			SFRG0200( cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, ,cCodItem , @aReg0220,,,,,,,,,,,,,,,,,,,aWizard  )
		EndIf	

	Next nX

	If Len(aD735aux) > 0 
	//³Geracao do REGISTRO C195 ³
	For nX := 1 To Len(aD735aux)  
		cFilD735:= aD735aux[nX][1]
		SPesqjSon(oRegD735, cFilD735, @nPosD735)

		If nPosD735 ==0
			aAdd(aRegD735, {})
			nPosD700:=	Len (aRegD700)
			nPosD735	:=	Len (aRegD735)
			aAdd (aRegD735[nPosD735], nPosD700)												//01 - RELACIONAMENTO 	
			aAdd (aRegD735[nPosD735], "D735")		 	   									//02 - REG
			aAdd (aRegD735[nPosD735], aD735aux[nX][1])										//03 - COD_OBS
			aAdd (aRegD735[nPosD735], aD735aux[nX][3])		   								//04 - TXT_COMPL	
			aAdd (aRegD735[nPosD735], RetRD(GetRelacPr())+strzero(nPosD735,nTamFT_IT)) 		//05 - - Posição de Hierarquia
			
			oRegD735[cFilD735] := nPosD735

			//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL      ³
			Reg0460(@aReg0460,{aD735aux[nX][1],aD735aux[nX][4]})
		Endif			
	Next nX

	EndIf

Return

/*/{Protheus.doc} D750 
D750 - ESCRITURAÇÃO CONSOLIDADA DA NOTA FISCAL FATURA ELETRÔNICA DE SERVIÇOS DE COMUNICAÇÃO NFCom (CÓDIGO 62)  		
D760 - REGISTRO ANALÍTICO DA ESCRITURAÇÃO CONSOLIDADA DA NOTA FISCAL FATURA ELETRÔNICA DE SERVIÇOS DE COMUNICAÇÃO - NFCom (CÓDIGO 62)   
Atribui em um array o conteudo a ser gravado no TRB atraves da funcao GrvRegTrS com as informacoe contidas no array aRegD700/aRegD730/aPartDoc/aCmpAntSFT para os modelos 62 que serao gravados no final da funcao  
	@author Talita Teixeira
	@since 18/06/2025
	@version 12.1.24
	@param aPartDoc, array, Array com informacoes sobre o participante do documento fiscal, este array eh montado pela funcao principal. 
	@param aCmpAntSFT, array, Informacoes sobre o cabecalho dos documentos.
	@param aRegD700, array, Array contendo as informacoes processadas pela funcao a ser retornado para gravacao pela funcao principal.
	@param aRegD730, array, Informacoes ja gravadas no registro D730 para utilizacao.   
	@param lAchouSFX -> Flag de posicionamento da tabela SFX 
/*/

Function RegD750(cAlias, aRegC100, cAliasSFT, aPartDoc,aCmpAntSFT,aRegD750,lAchouSFX, aWizard, cEspecie, nRedBSICM, oRegD750)
	Local	nPos		:=	0
	Local	cCodCons	:=	""
	Local	nValTer		:= 0
	Local 	nValDes		:= 0
	Local	nValDoc		:= 0
	Local 	cFilD750	:= ""

	If oRegD750 == Nil
		oRegD750:= JsonObject():New()
	EndIf
	

	If lAchouSFX
		If aSPDSX3[FP_FX_INDPAG] 
			cCodCons := SFX->FX_INDPAG
		EndIf
		nValTer	 := SFX->FX_VALTERC
	EndIf

	//³REGISTRO D750 - ESCRITURAÇÃO CONSOLIDADA DA NOTA FISCAL FATURA ELETRÔNICA DE SERVIÇOS DE COMUNICAÇÃO - NFCom (CÓDIGO 62)
	If Empty(aCmpAntSFT[7])	//NOTA FISCAL CANCELADA.
		nValDes:= (cAliasSFT)->FT_DESPESA -  ((cAliasSFT)->FT_SEGURO + (cAliasSFT)->FT_FRETE) 
		nValDoc:= (aRegC100[1][12]+aRegC100[1][15]+nValTer+aRegC100[1][20]) - aRegC100[1][14]
		cFilD750:= cEspecie + aCmpAntSFT[2] + dToc(aCmpAntSFT[6]) + cCodCons

		SPesqjSon(oRegD750, cFilD750, @nPos)

		If nPos == 0
			aAdd(aRegD750, {})
			nPos	:=	Len (aRegD750)
			aAdd (aRegD750[nPos], "D750")	 	 	  							//01 - REG
			aAdd (aRegD750[nPos], cEspecie) 	   								//02 - COD_MOD
			aAdd (aRegD750[nPos], aCmpAntSFT[2])	   							//03 - SER
			aAdd (aRegD750[nPos], aCmpAntSFT[6]) 	   							//04 - DT_DOC
			aAdd (aRegD750[nPos], "1")     										//05 - QTD_CONS
			aAdd (aRegD750[nPos], cCodCons)				 	   					//06 - IND_PREPAGO
			aAdd (aRegD750[nPos], nValDoc)										//07 - VL_DOC
			aAdd (aRegD750[nPos], aRegC100[1][12])								//08 - VL_SERV
			aAdd (aRegD750[nPos], aRegC100[1][15])								//09 - VL_SERV_NT
			aAdd (aRegD750[nPos], nValTer)	  									//10 - VL_TERC
			aAdd (aRegD750[nPos], aRegC100[1][14])								//11 - VL_DESC
			aAdd (aRegD750[nPos], aRegC100[1][20])								//12 - VL_DA
			aAdd (aRegD750[nPos], aRegC100[1][21])								//13 - VL_BC_ICMS
			aAdd (aRegD750[nPos], aRegC100[1][22])								//14 - VL_ICMS
			aAdd (aRegD750[nPos], aRegC100[1][26])								//15 - VL_PIS
			aAdd (aRegD750[nPos], aRegC100[1][27])								//16 - VL_COFINS
			aAdd (aRegD750[nPos], "0"			)								//17 - DED
			aAdd (aRegD750[nPos], RetRD(GetRelacPr())+strzero(nPos,nTamFT_IT)) 
			oRegD750[cFilD750] := nPos

		Else

			aRegD750[nPos][5] 	:=  Alltrim(STR(Val(aRegD750[nPos][5])+1))		//05 - QTD_CONS
			aRegD750[nPos][7]	+=	nValDoc										//07 - VL_DOC
			aRegD750[nPos][8]	+= 	aRegC100[1][12]								//08 - VL_SERV
			aRegD750[nPos][9]	+=	aRegC100[1][15] 							//09 - VL_SERV_NT
			aRegD750[nPos][10]	+=	nValTer										//10 - VL_TERC
			aRegD750[nPos][11]	+=	aRegC100[1][14] 							//11 - VL_DESC
			aRegD750[nPos][12]	+=	aRegC100[1][20]								//12 - VL_DA
			aRegD750[nPos][13]	+=	aRegC100[1][21]								//13 - VL_BC_ICMS
			aRegD750[nPos][14]	+=	aRegC100[1][22]								//14 - VL_ICMS
			aRegD750[nPos][15]	+=	aRegC100[1][26] 							//15 - VL_PIS
			aRegD750[nPos][16]	+=	aRegC100[1][27]								//16 - VL_COFINS
		
			
			
		EndIf
	EndIf

Return nPos


/*/{Protheus.doc} D760D761
	(long_description)
	@type  Function
	@author user
	@since 01/07/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function D760D761(cAliasSFT, aCmpAntSFT, aRegD760, aRegD761, aRegC170, aReg0460, oRegD760, oRegD761, nRedBSICM, lAchouSFX, aWizard, cEspecie, aRegD750, oRegD750)
	Local 	cFilD760	:= ""
	Local 	cFilD761	:= ""
	Local 	cFilD750    := ""
	Local 	nPos761		:= 0
	Local	nPos2		:= 0
	Local 	nPos		:= 0
	Local   cCodCons	:= ""
	Local 	cChaveRel	:= ""
	Local 	nRelPai		:= 0

	If oRegD760 == Nil
		oRegD760:= JsonObject():New()
	EndIf

	If aSPDSX3[FP_FX_INDPAG]  .And.  lAchouSFX 
		cCodCons := SFX->FX_INDPAG
	EndIf

	If Len(aRegD750) > 0
		cFilD750:= cEspecie + aCmpAntSFT[2] + dToc(aCmpAntSFT[6]) + cCodCons
		SPesqjSon(oRegD750, cFilD750, @nPos)
		
		If nPos > 0
			cChaveRel:= aRegD750[nPos][18]
		EndIf
	

	EndIf

	If Empty(aCmpAntSFT[7])	//NOTA FISCAL CANCELADA.
		//³REGISTRO D760 - REGISTRO ANALÍTICO DA ESCRITURAÇÃO CONSOLIDADA DA NOTA FISCAL FATURA ELETRÔNICA DE SERVIÇOS DE COMUNICAÇÃO - NFCom (CÓDIGO 62)
		cFilD760:= aRegC170[1][10] + aCmpAntSFT[9] + cValToChar(aCmpAntSFT[11]) + cCodCons

			SPesqjSon(oRegD760, cFilD760, @nPos2)

			If nPos2 ==0
				
				aAdd(aRegD760, {})

				If nPos > 0
					nRelPai:= nPos
				Else
					nRelPai:= Len (aRegD760)
				EndIf

				nPos2	:=	Len (aRegD760)
				aAdd (aRegD760[nPos2], nRelPai)	 		            	//Relação com Registro
				aAdd (aRegD760[nPos2], "D760")	 	 	  				//01 - REG
				aAdd (aRegD760[nPos2], aRegC170[1][10])	  				//02 - CST_ICMS
				aAdd (aRegD760[nPos2], aCmpAntSFT[9])	  				//03 - CFOP
				aAdd (aRegD760[nPos2], aCmpAntSFT[11])					//04 - ALIQ_ICMS
				aAdd (aRegD760[nPos2], (cAliasSFT)->FT_VALCONT)	  		//05 - VL_OPR 
				aAdd (aRegD760[nPos2], (cAliasSFT)->FT_BASEICM)	 		//06 - VL_BC_ICMS 
				aAdd (aRegD760[nPos2], (cAliasSFT)->FT_VALICM)	 		//07 - VL_ICMS 
				aAdd (aRegD760[nPos2], nRedBSICM) 	  					//08 - VL_RED_BC
				If Len(aReg0460) > 0
					aAdd (aRegD760[nPos2], aReg0460[1][2]) 	  			//09 - COD_OBS
				Else 
					aAdd (aRegD760[nPos2], "") 							//09 - COD_OBS
				EndIf
				
				aAdd (aRegD760[nPos2], RetRD(GetRelacPr())+strzero(nPos2,nTamFT_IT)) 
				oRegD760[cFilD760] := nPos2

			Else				 			
				aRegD760[nPos2][06] += (cAliasSFT)->FT_VALCONT			//05 - VL_OPR
				aRegD760[nPos2][07]	+= (cAliasSFT)->FT_BASEICM	 	 	//06 - VL_BC_ICMS 
				aRegD760[nPos2][08] += (cAliasSFT)->FT_VALICM	 		//07 - VL_ICMS
				aRegD760[nPos2][09]	+= nRedBSICM	 	  				//08 - VL_RED_BC

			EndIf		
		
			//REGISTRO D761: INFORMAÇÕES DO FUNDO DE COMBATE À POBREZA – FCP – (CÓDIGO 62)		
		If cVersao >= "014" .and. cEspecie $ "62"

			If oRegD761 == Nil
				oRegD761:= JsonObject():New()
			EndIf

			cFilD761:= cValToChar(nPos2)

			SPesqjSon(oRegD761, cFilD761, @nPos761)

			If aWizard[1][23]=="1-Sim" .And. ((cAliasSFT)->FT_VALFECP) > 0
				IF nPos761  == 0	
					aAdd(aRegD761, {})
					nPos761	:=	Len(aRegD761)
					aAdd (aRegD761[nPos761], nRelPai)	 		            							//Relação com Registro D760 Pai
					aAdd (aRegD761[nPos761], "D761")													//01 - REG
					aAdd (aRegD761[nPos761], (cAliasSFT)->FT_VALFECP)									//02 - VL_FCP_OP
					aAdd (aRegD761[nPos761], RetRD(GetRelacPr())+strzero(nPos2,nTamFT_IT)) 				//03 - Posição de Hierarquia
					oRegD761[cFilD761] := nPos2
				Else
					aRegD761[nPos761][3]	+=	(cAliasSFT)->FT_VALFECP									//02 - VL_FCP_OP
				Endif
			ElseIF nPos761  == 0	
					aAdd(aRegD761, {})
					nPos761	:=	Len(aRegD761)
					aAdd (aRegD761[nPos761], nRelPai)	 		   		         						//Relação com Registro D760 Pai
					aAdd (aRegD761[nPos761], "D761")													//01 - REG
					aAdd (aRegD761[nPos761], "0")	 													//02 - VL_FCP_OP
					aAdd (aRegD761[nPos761], RetRD(GetRelacPr())+strzero(nPos2,nTamFT_IT)) 				//03 - Posição de Hierarquia
					oRegD761[cFilD761] := nPos2
				EndIf
			Endif

		EndIf
	
Return  
