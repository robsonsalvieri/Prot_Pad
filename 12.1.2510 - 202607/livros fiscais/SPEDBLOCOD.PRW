#INCLUDE "SPEDFISCAL.CH" 
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "SPEDXDEF.CH"

STATIC nTamFT_IT	:= TAMSX3("FT_ITEM")[1]
STATIC aSPDSX3		:=	SpedLoadX3()
STATIC aSPDFil		:=  fGetSpdFil()

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
Function RegD700(cAlias, cAliasSFT, nRelac, aCmpAntSFT, aRegD700, lAchouSFX, lGravaD700, lAchouCDD, cSituaDoc,aInfCompl, cALiasCDD, aRegC100, cRelacDoc, lNaoGrvcCla, cEntSai, cAliasSF4, cEspecie, nItem, aTotaliza, nD7xxVTerc, nD7xxVlDed)
	
    Local nPosD700  := 0
	Local nValDoc 	:= 0
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

	Default aTotaliza  := {}
	Default nD7xxVTerc := 0
	Default nD7xxVlDed := 0

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
			If SA1->A1_EST == "EX"
				cMunDes := "9999999"
			EndIf
		Endif
	EndIf
	
  	If lNfAtiva

		If lAchouSFX
						
			If SFX->FX_TIPOREC  == "5"
				cTipFat:= "2" //Co-faturamento
			ElseIf SFX->FX_TIPOREC  == "7"
				cTipFat:= "1" //Faturamento centralizado
			Else 
				cTipFat:= "0" //Faturamento Normal
			EndIf

		EndIf

		If Len(aInfCompl) > 0
			cCodInf:= aInfCompl[1]
		EndIf

		//Prioriza o novo campo da SFX que possui o conteudo exatamente do spedfiscal campo 23 FIN_DOCe [0 - NFCom Normal; 3 - NFCom de Substituição; 4 - NFCom de Ajuste]
		If aSPDSX3[FP_FX_FINNFC] .and. lAchouSFX
			cFinDoc := SFX->FX_FINNFC
		Endif

		If lAchouCDD
			cSerRef	 := (cAliasCDD)->CDD_SERREF
			cNumRef	 := (cAliasCDD)->CDD_DOCREF
			cMAnoRef := (cAliasCDD)->CDD_MEANRF
			cModRef  := aModnot((cAliasCDD)->CDD_MODREF)
			If !Empty((cAliasCDD)->CDD_DOCREF) .And. !Empty((cAliasCDD)->CDD_SERREF)
				cChvRef := (cAliasCDD)->CDD_CHVNFE
				if empty( cFinDoc ) //campo novo nao informado
					cFinDoc := "4" //4=NFCom ajuste de débito
					if (cAliasSF4)->F4_AJUSTE <> "S"
						cFinDoc := "3" //3=NFCom de Substituição
					EndiF
				endif
			endif
		Endif

		If cVersao >= "019" //Versao do layout
			nValDoc := (aTotaliza[2] + aRegC100[1][15] + aTotaliza[7] + nD7xxVTerc) - nD7xxVlDed // (VL_SERV + VL_SERV_NT + VL_TERC ) - DED
		Else
			nValDoc	:= aRegC100[1][12]
		EndIf

		aAdd(aRegD700, {})
		nPosD700	:=	Len (aRegD700)

		aAdd (aRegD700[nPosD700], "D700")			 											//01 - REG  
		aAdd (aRegD700[nPosD700], cIndOper)							    						//02 - IND_OPER
		aAdd (aRegD700[nPosD700], cIndEmit)	   												    //03 - IND_EMIT	

		If cIndOper == "0"
			aAdd (aRegD700[nPosD700], aRegC100[1][4])											//04 - COD_PART
		ElseIf cIndOper == "1"
			aAdd (aRegD700[nPosD700], "")														//04 - COD_PART
		EndIf

		aAdd (aRegD700[nPosD700], cEspecie)					   									//05 - COD_MOD		
		aAdd (aRegD700[nPosD700], cSituaDoc)	   												//06 - COD_SIT		
		aAdd (aRegD700[nPosD700], aCmpAntSFT[2])   		                     					//07 - SER    
		aAdd (aRegD700[nPosD700], aCmpAntSFT[1])						       					//08 - NUM_DOC 
		aAdd (aRegD700[nPosD700], aCmpAntSFT[6])	   			 								//09 - DT_DOC	

		If cIndOper == "0"
			aAdd (aRegD700[nPosD700], aCmpAntSFT[5])			   								//10 - DT_E_S	

			If !lNaoGrvcCla 
				aAdd (aRegD700[nPosD700], nValDoc)												//11 - VL_DOC
				aAdd (aRegD700[nPosD700], aRegC100[1][14])										//12 - VL_DESC
				aAdd (aRegD700[nPosD700], aTotaliza[2])											//13 - VL_SERV
				aAdd (aRegD700[nPosD700], aRegC100[1][15] + aTotaliza[7])						//14 - VL_SERV_NT	
				aAdd (aRegD700[nPosD700], nD7xxVTerc)				       						//15 - VL_TERC
				aAdd (aRegD700[nPosD700], aRegC100[1][20])										//16 - VL_DA
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
			aAdd (aRegD700[nPosD700], nValDoc)													//11 - VL_DOC
			aAdd (aRegD700[nPosD700], aRegC100[1][14])											//12 - VL_DESC
			aAdd (aRegD700[nPosD700], aTotaliza[2])											    //13 - VL_SERV
			aAdd (aRegD700[nPosD700], aRegC100[1][15] + aTotaliza[7])							//14 - VL_SERV_NT	
			aAdd (aRegD700[nPosD700], nD7xxVTerc)				       					 	    //15 - VL_TERC
			aAdd (aRegD700[nPosD700], aRegC100[1][20])											//16 - VL_DA
		EndIf 
		
		If (cIndOper=="0" .And. aRegC100[1][22] > 0) .Or. cIndOper=="1" 
			aAdd (aRegD700[nPosD700], aRegC100[1][21])											//17 - VL_BC_ICMS
			aAdd (aRegD700[nPosD700], aRegC100[1][22])											//18 - VL_ICMS
		Else
			aAdd (aRegD700[nPosD700], "0")														//17 - VL_BC_ICMS
			aAdd (aRegD700[nPosD700], "0")														//18 - VL_ICMS
		EndIf
		
		aAdd (aRegD700[nPosD700], cCodInf)														//19 - COD_INF
		aAdd (aRegD700[nPosD700], aRegC100[1][26])												//20 - VL_PIS
		aAdd (aRegD700[nPosD700], aRegC100[1][27])												//21 - VL_COFINS
		aAdd (aRegD700[nPosD700], aCmpAntSFT[25])												//22 - CHV_DOCe
		aAdd (aRegD700[nPosD700], cFinDoc)						        					    //23 - FIN_DOCe

		aAdd (aRegD700[nPosD700], cTipFat)													    //24 - TIP_FAT

		If cFinDoc == "3"
			aAdd (aRegD700[nPosD700], cModRef )													//25 - COD_MOD_DOC_REF
		Else
			aAdd (aRegD700[nPosD700], "")														//25 - COD_MOD_DOC_REF
		EndIf

		If cModRef $"62"
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
		
		aAdd (aRegD700[nPosD700], cMunDes)													    //31 - COD_MUN_DEST
		aAdd (aRegD700[nPosD700], nD7xxVlDed)													//32 - DED
	EndIf

	GrvRegTrS(cAlias,RetRD(nRelac),aRegD700,nItem)

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
Function RegD730(cAlias, nRelac, aRegC170, cAliasSFT,aCmpAntSFT, aRegD730,nRedBSICM, aWizard, aRegD731, cVersao, cEntSai, cEspecie, oRegD730, oRegD731, cAliasSF4, oMsg9095, aReg0460)

	Local nPosD730		:= 0
	Local nPosD731		:= 0
	Local cFilD730		:= ""
	Local cFilD731		:= ""
	Local aMsgD730		:= {}
	Local cCodObs		:= ""
	Local cTxtObs		:= ""

	Default cAliasSF4	:= ""
	Default oMsg9095	:= Nil
	Default aReg0460	:= {}

	If oRegD730 == Nil 
		oRegD730:= JsonObject():New()
	EndIf

	cFilD730:= aRegC170[1][10]+aRegC170[1][11]+cValToChar(aRegC170[1][14])+RetRD(nRelac)

	SPesqjSon(oRegD730, cFilD730, @nPosD730)

	If nPosD730 == 0
		aAdd(aRegD730, {})
		nPosD730	:= Len (aRegD730)
		aAdd (aRegD730[nPosD730], "D730"			)					//01 - REG
		aAdd (aRegD730[nPosD730], aRegC170[1][10]	)					//02 - CST_ICMS
		aAdd (aRegD730[nPosD730], aRegC170[1][11]	)					//03 - CFOP
		aAdd (aRegD730[nPosD730], aRegC170[1][14]	)					//04 - ALIQ_ICMS
		aAdd (aRegD730[nPosD730], (cAliasSFT)->FT_VALCONT)		        //05 - VL_OPR
		aAdd (aRegD730[nPosD730], aRegC170[1][13]	)					//06 - VL_BC_ICMS
		aAdd (aRegD730[nPosD730], aRegC170[1][15]	)					//07 - VL_ICMS
		aAdd (aRegD730[nPosD730], nRedBSICM			)					//08 - VL_RED_BC
		aAdd (aRegD730[nPosD730], "")	 		  						//09 - COD_OBS
		If HMGet(oMsg9095, (cAliasSFT)->FT_IDTRIB, aMsgD730)
			If aMsgD730[1][5] == '1'				
				cCodObs := aMsgD730[1][2]
				cTxtObs := aMsgD730[1][4]
				aRegD730[nPosD730][9] := cCodObs
			EndIf
		ElseIf !Empty((cAliasSF4)->F4_CODOBSE)
			cCodObs := (cAliasSF4)->F4_CODOBSE
			If SPEDSeek("CCE",,aSPDFil[PFIL_CCE]+cCodObs)
				cCodObs := CCE->CCE_COD
				cTxtObs := CCE->CCE_DESCR
				aRegD730[nPosD730][9] := cCodObs
			EndIf
		EndIf			
		If !Empty(cCodObs) .And. !Empty(cTxtObs)
			Reg0460(@aReg0460, {cCodObs, cTxtObs})
		EndIf		
		oRegD730[cFilD730] := nPosD730
	Else
		aRegD730[nPosD730][5] += (cAliasSFT)->FT_VALCONT				//05 - VL_OPR
		If (cEntSai=="1" .And. aRegC170[1][15] > 0 ) .Or. cEntSai  == "2"
			aRegD730[nPosD730][6]+= aRegC170[1][13]						//06 - VL_BC_ICMS
			aRegD730[nPosD730][7]+= aRegC170[1][15]						//07 - VL_ICMS
		EndIf 		
		aRegD730[nPosD730][8]+= nRedBSICM								//08 - VL_RED_BC  	
	EndIf				

	//REGISTRO D731: INFORMAÇÕES DO FUNDO DE COMBATE À POBREZA – FCP – (CÓDIGO 62)		
	If aWizard[1][23] =="1-Sim" .and. cVersao >= "014" .and. cEspecie $ "62"

		If ((cAliasSFT)->FT_VALFECP) > 0

			If oRegD731 == Nil
				oRegD731:= JsonObject():New()
			EndIf 

			cFilD731:= cValtochar(nPosD731) + RetRD(nRelac)
			SPesqjSon(oRegD731, cFilD731, @nPosD731)
			
			If nPosD731 == 0
				aAdd(aRegD731, {})
				nPosD731	:=	Len(aRegD731)
				aAdd (aRegD731[nPosD731], "D731")						//01 - REG
				aAdd (aRegD731[nPosD731], (cAliasSFT)->FT_VALFECP)		//02 - VL_FCP_OP
				oRegD731[cFilD731] := nPosD731 
			Else
				aRegD731[nPosD731][2] +=  (cAliasSFT)->FT_VALFECP		//02 - VL_FCP_OP
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

		cFilD735	:= RetRD(cRelacDoc)
		SPesqjSon(oRegD735, cFilD735, @nPosD735)

		//³Geracao do REGISTRO D735
		If nPosD735 == 0
			aAdd(aRegD735, {})
			nPosD735 :=	Len(aRegD735)
			aAdd( aRegD735[nPosD735], "D735"			)					//01 - REG
			aAdd( aRegD735[nPosD735], aLanCDA[nX][07]	)					//02 - COD_OBS
			aAdd( aRegD735[nPosD735], aLanCDA[nX][17]	)					//03 - TXT_COMPL	
			oRegD735[cFilD735] := nPosD735
		
			//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL
			Reg0460(@aReg0460,{aLanCDA[nX][7],aLanCDA[nX][20]})

		EndIf

		If !aLanCDA[nX,24] // Legado (Código de lançamento vindo da TES)
			
			cFilD737:= RetRD(cRelacDoc) + aLanCDA[nX,1]
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
			Endif	
		Endif
		
		//³Geracao do REGISTRO D737
		If nPos == 0
			aAdd(aRegD737, {})
			nPos := Len (aRegD737)
			aAdd (aRegD737[nPos], "D737"				)					//01 - REG
			aAdd (aRegD737[nPos], aLanCDA[nX,1]			)					//02 - COD_AJ
			aAdd (aRegD737[nPos], aLanCDA[nX][2]		)					//03 - DESCR_COMPL_AJ
			aAdd (aRegD737[nPos], cCodItem				)					//04 - COD_ITEM
			aAdd (aRegD737[nPos], aLanCDA[nX][3]		)					//05 - VL_BC_ICMS
			aAdd (aRegD737[nPos], aLanCDA[nX][4]		)					//06 - ALIQ_ICMS
			aAdd (aRegD737[nPos], aLanCDA[nX][5]		)					//07 - VL_ICMS
			aAdd (aRegD737[nPos], aLanCDA[nX][6]		)					//08 - VL_OUTROS

			oRegD737[cFilD737] := nPos
		Else
			aRegD737[nPos][5]	+= aLanCDA[nX][3]							//05 - VL_BC_ICMS
			aRegD737[nPos][7]	+= aLanCDA[nX][5]							//06 - VL_ICMS
			aRegD737[nPos][8]	+= aLanCDA[nX][6]							//08 - VL_OUTROS

		EndIf

		//³Tratamento para que os itens utilizados seja gerados no 0200³
		If !Empty( cCodItem ) .And.  aScan ( aReg0200, { |aX| aX[2] == cCodItem }) == 0
			SPEDSeek("SB1",,aSPDFil[PFIL_SB1]+cCodItem)
			SFRG0200( cAlias, @aReg0200, @aReg0190, dDataDe, dDataAte, ,cCodItem , @aReg0220,,,,,,,,,,,,,,,,,,,aWizard  )
		EndIf	

	Next nX

	If Len(aD735aux) > 0 
		//³Geracao do REGISTRO D735 ³
		For nX := 1 To Len(aD735aux)  
			cFilD735:= aD735aux[nX][1]
			SPesqjSon(oRegD735, cFilD735, @nPosD735)

			If nPosD735 ==0
				aAdd(aRegD735, {})
				nPosD735 :=	Len (aRegD735)
				aAdd (aRegD735[nPosD735], "D735"			)					//01 - REG
				aAdd (aRegD735[nPosD735], aD735aux[nX][1]	)					//02 - COD_OBS
				aAdd (aRegD735[nPosD735], aD735aux[nX][3]	)					//03 - TXT_COMPL	

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
Function RegD750(cAlias, aRegC100, cAliasSFT, aPartDoc,aCmpAntSFT,aRegD750,lAchouSFX, aWizard, cEspecie, nRedBSICM, oRegD750, aTotaliza, nD7xxVTerc, nD7xxVlDed)
	Local	nPos		:=	0
	Local	cCodCons	:=	""
	Local	nValDoc		:= 0
	Local 	cFilD750	:= ""

	Default aTotaliza   := {}
	Default nD7xxVTerc  := 0
	Default nD7xxVlDed  := 0

	If oRegD750 == Nil
		oRegD750:= JsonObject():New()
	EndIf
	
	If lAchouSFX
		If aSPDSX3[FP_FX_INDPAG] 
			cCodCons := SFX->FX_INDPAG
		EndIf
	EndIf

	//³REGISTRO D750 - ESCRITURAÇÃO CONSOLIDADA DA NOTA FISCAL FATURA ELETRÔNICA DE SERVIÇOS DE COMUNICAÇÃO - NFCom (CÓDIGO 62)
	If Empty(aCmpAntSFT[7])	//NOTA FISCAL CANCELADA.
		nValDoc := (aRegC100[1][12] + aRegC100[1][15] + nD7xxVTerc + aRegC100[1][20]) - nD7xxVlDed
		cFilD750 := cEspecie + aCmpAntSFT[2] + DtoS(aCmpAntSFT[6]) + cCodCons

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
			aAdd (aRegD750[nPos], aRegC100[1][21]) 								//08 - VL_SERV
			aAdd (aRegD750[nPos], aRegC100[1][15]+aTotaliza[7])					//09 - VL_SERV_NT
			aAdd (aRegD750[nPos], nD7xxVTerc)  									//10 - VL_TERC
			aAdd (aRegD750[nPos], aRegC100[1][14])								//11 - VL_DESC
			aAdd (aRegD750[nPos], aRegC100[1][20])								//12 - VL_DA
			aAdd (aRegD750[nPos], aRegC100[1][21])								//13 - VL_BC_ICMS
			aAdd (aRegD750[nPos], aRegC100[1][22])								//14 - VL_ICMS
			aAdd (aRegD750[nPos], aRegC100[1][26])								//15 - VL_PIS
			aAdd (aRegD750[nPos], aRegC100[1][27])								//16 - VL_COFINS
			aAdd (aRegD750[nPos], nD7xxVlDed)									//17 - DED
			aAdd (aRegD750[nPos], RetRD(GetRelacPr())+strzero(nPos,nTamFT_IT)) 
			oRegD750[cFilD750] := nPos
		Else
			aRegD750[nPos][5] 	:=  Alltrim(STR(Val(aRegD750[nPos][5])+1))		//05 - QTD_CONS
			aRegD750[nPos][7]	+=	nValDoc										//07 - VL_DOC
			aRegD750[nPos][8]	+= 	aRegC100[1][21]								//08 - VL_SERV
			aRegD750[nPos][9]	+=	aRegC100[1][15] + aTotaliza[7]				//09 - VL_SERV_NT
			aRegD750[nPos][10]	+=	nD7xxVTerc									//10 - VL_TERC
			aRegD750[nPos][11]	+=	aRegC100[1][14] 							//11 - VL_DESC
			aRegD750[nPos][12]	+=	aRegC100[1][20]								//12 - VL_DA
			aRegD750[nPos][13]	+=	aRegC100[1][21]								//13 - VL_BC_ICMS
			aRegD750[nPos][14]	+=	aRegC100[1][22]								//14 - VL_ICMS
			aRegD750[nPos][15]	+=	aRegC100[1][26] 							//15 - VL_PIS
			aRegD750[nPos][16]	+=	aRegC100[1][27]								//16 - VL_COFINS
			aRegD750[nPos][17]	+=	nD7xxVlDed									//17 - DED
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
Function D760D761(cAliasSFT, aCmpAntSFT, aRegD760, aRegD761, aRegC170, aReg0460, oRegD760, oRegD761, nRedBSICM, lAchouSFX, aWizard, cEspecie, aRegD750, oRegD750, cAliasSF4, oMsg9095)
    Local cFilD760    := ""
    Local cFilD761    := ""
    Local cFilD750    := ""
    Local nPos761     := 0
    Local nPos2       := 0
    Local nPos        := 1
    Local cCodCons    := ""
    Local aMsgD760    := {}
	Local cCodObs     := ""
	Local cTxtObs     := ""
    
    Local cCstItem   := aRegC170[1][10] 
    Local cCfopItem  := aRegC170[1][11] 
    Local cAliqItem  := cValToChar(aRegC170[1][14]) 

	Default cAliasSF4	:= ""
	Default oMsg9095	:= Nil
	Default aReg0460	:= {}


	If oRegD750 == Nil
        oRegD750 := JsonObject():New()
    EndIf

    If aSPDSX3[FP_FX_INDPAG] .And. lAchouSFX 
        cCodCons := SFX->FX_INDPAG
    EndIf

    cFilD750 := cEspecie + aCmpAntSFT[2] + DtoS(aCmpAntSFT[6]) + cCodCons
    SPesqjSon(oRegD750, cFilD750, @nPos)

    If Empty(aCmpAntSFT[7])

		If oRegD760 == Nil
			oRegD760 := JsonObject():New()
		EndIf

        cFilD760 := cFilD750 + cCstItem + cCfopItem + cAliqItem
        SPesqjSon(oRegD760, cFilD760, @nPos2)

        If nPos2 == 0
            aAdd(aRegD760, {})
            nPos2 := Len(aRegD760)

            aAdd (aRegD760[nPos2], nPos)                                     // [1] Link com D750
            aAdd (aRegD760[nPos2], "D760")                                   // [2] 01 - REG
            aAdd (aRegD760[nPos2], cCstItem)                                 // [3] 02 - CST_ICMS
            aAdd (aRegD760[nPos2], cCfopItem)                                // [4] 03 - CFOP
            aAdd (aRegD760[nPos2], aRegC170[1][14])                          // [5] 04 - ALIQ_ICMS
            aAdd (aRegD760[nPos2], (cAliasSFT)->FT_VALCONT)                  // [6] 05 - VL_OPR 
            aAdd (aRegD760[nPos2], (cAliasSFT)->FT_BASEICM)                  // [7] 06 - VL_BC_ICMS 
            aAdd (aRegD760[nPos2], (cAliasSFT)->FT_VALICM)                   // [8] 07 - VL_ICMS 
            aAdd (aRegD760[nPos2], nRedBSICM)                                // [9] 08 - VL_RED_BC		
			aAdd (aRegD760[nPos2], "")                                       //09 - COD_OBS
			If HMGet(oMsg9095, (cAliasSFT)->FT_IDTRIB, aMsgD760)
				If aMsgD760[1][5] == '1'
					aRegD760[nPos2][10] := aMsgD760[1][2]
					cCodObs := aMsgD760[1][2]
					cTxtObs := aMsgD760[1][4]
				EndIf
			ElseIf !Empty((cAliasSF4)->F4_CODOBSE)
				cCodObs := (cAliasSF4)->F4_CODOBSE
				If SPEDSeek("CCE",,aSPDFil[PFIL_CCE]+cCodObs)
					cCodObs := CCE->CCE_COD
					cTxtObs := CCE->CCE_DESCR
					aRegD760[nPos2][10] := cCodObs
				EndIf
			EndIf

			If !Empty(cCodObs) .And. !Empty(cTxtObs)
				Reg0460(@aReg0460,{cCodObs,cTxtObs})
			EndIf
            
            aAdd (aRegD760[nPos2], RetRD(GetRelacPr())+strzero(nPos2,nTamFT_IT)) 
            oRegD760[cFilD760] := nPos2
        Else                            
            aRegD760[nPos2][06] += (cAliasSFT)->FT_VALCONT          //05 - VL_OPR
            aRegD760[nPos2][07] += (cAliasSFT)->FT_BASEICM          //06 - VL_BC_ICMS 
            aRegD760[nPos2][08] += (cAliasSFT)->FT_VALICM           //07 - VL_ICMS
            aRegD760[nPos2][09] += nRedBSICM                        //08 - VL_RED_BC
		Endif
        If cVersao >= "014" .and. cEspecie $ "62"

            If oRegD761 == Nil
                oRegD761:= JsonObject():New()
            EndIf
        
            cFilD761:= cValToChar(nPos2)
            SPesqjSon(oRegD761, cFilD761, @nPos761)

            If aWizard[1][23]== "1-Sim" .And. ((cAliasSFT)->FT_VALFECP) > 0
                IF nPos761  == 0    
                    aAdd(aRegD761, {})
                    nPos761 :=  Len(aRegD761)
                    aAdd (aRegD761[nPos761], nPos2)                                             // Relacionamento com D760 Pai
                    aAdd (aRegD761[nPos761], "D761")                                            //01 - REG
                    aAdd (aRegD761[nPos761], (cAliasSFT)->FT_VALFECP)                           //02 - VL_FCP_OP
                    aAdd (aRegD761[nPos761], RetRD(GetRelacPr())+strzero(nPos2,nTamFT_IT))      //03 - Posição de Hierarquia
                    oRegD761[cFilD761] := nPos761
                Else
                    aRegD761[nPos761][3]    +=  (cAliasSFT)->FT_VALFECP                        //02 - VL_FCP_OP
                Endif
            ElseIF nPos761  == 0    
                    aAdd(aRegD761, {})
                    nPos761 :=  Len(aRegD761)
                    aAdd (aRegD761[nPos761], nPos2)                                             //Relação com Registro D760 Pai
                    aAdd (aRegD761[nPos761], "D761")                                            //01 - REG
                    aAdd (aRegD761[nPos761], "0")                                               //02 - VL_FCP_OP
                    aAdd (aRegD761[nPos761], RetRD(GetRelacPr())+strzero(nPos2,nTamFT_IT))      //03 - Posição de Hierarquia
                    oRegD761[cFilD761] := nPos761
            EndIf
        Endif

    EndIf

Return

/*/{Protheus.doc} SPDD197CDA
	(Buscar dados do código de lançamento na TES de saida.
	Retorna um Json que contem os códigos de lançamento que terão tratamento diferenciado para composição dos Registros D190,D195,D197
	reduzindo as chamadas da função SPLancCDA para lançamentos que não necessitam gerar os registros E131 e E531, a partir do SIGATMS)
	@type  Function
	@author Delleon Fernandes
	@since 27/02/2026
	@version 12.1.2510
	@param cCodLctos, caracter, Códigos de lançamentos separados por vírgula.
	@return oJCodL9597, objeto, Objeto JSON com os dados dos códigos de lançamento.
/*/
Function SPDD197CDA(cCodLctos)
	Local oJCodL9597 := Nil
	Local oQry187CDA := Nil
	Local aCodLctos := StrToArray(Alltrim(cCodLctos), ",")
	Local cQuery := ""
	Local cAlias197 := ""
	Local cDesAjuste := ""
	Local oCacheMSMM := JsonObject():New()


	cQuery := "SELECT CC7.CC7_CODLAN, SF4.F4_CODIGO, CC7.CC7_IFCOMP, CCE.CCE_DESCR, CC7.CC7_DESCR, CC6.CC6_DESCR2, CC6.CC6_DESCR "
	cQuery += " FROM " + RetSqlName("SF4") + " SF4 "
	cQuery += " INNER JOIN " + RetSqlName("CC7") + " CC7 ON (CC7.CC7_FILIAL=? AND CC7.CC7_TES=SF4.F4_CODIGO AND CC7.CC7_CODLAN IN ( ? ) AND CC7.D_E_L_E_T_=?) " // 1-2-3
	cQuery += " LEFT JOIN " + RetSqlName("CCE") + " CCE ON (CCE.CCE_FILIAL=? AND CCE.CCE_COD=CC7.CC7_IFCOMP AND CCE.D_E_L_E_T_=?) " // 4-5
	cQuery += " LEFT JOIN " + RetSqlName("CC6") + " CC6 ON (CC6.CC6_FILIAL= ? AND CC6.CC6_CODLAN=CC7.CC7_CODLAN AND CC6.D_E_L_E_T_= ? ) " // 6-7
	cQuery += " WHERE SF4.F4_FILIAL =? " // 8
	cQuery += " AND SF4.F4_CODIGO > ? " // 9
	cQuery += " AND SF4.D_E_L_E_T_ =? " // 10
		
	cQuery := ChangeQuery(cQuery)

	oQry187CDA := FwExecStatement():New(cQuery)

	oQry187CDA:setString(1, aSPDFil[PFIL_CC7])
	oQry187CDA:setIn(    2, aCodLctos)
	oQry187CDA:setString(3, " ")
	oQry187CDA:setString(4, aSPDFil[PFIL_CCE])
	oQry187CDA:setString(5, " ")
	oQry187CDA:setString(6, aSPDFil[PFIL_CC6])
	oQry187CDA:setString(7, " ")
	oQry187CDA:setString(8, aSPDFil[PFIL_SF4])
	oQry187CDA:setString(9, "499")
	oQry187CDA:setString(10, " ")

	cAlias197 := oQry187CDA:OpenAlias()

	While (cAlias197)->(!Eof())

		If oJCodL9597 == Nil
			oJCodL9597 := JsonObject():New()
		EndIf

		If !Empty((cAlias197)->CC6_DESCR2) .Or. !Empty((cAlias197)->CC6_DESCR)
			cDesAjuste := SpdDesAjSY(@oCacheMSMM, (cAlias197)->CC6_DESCR2, (cAlias197)->CC6_DESCR)
		Else
			cDesAjuste := (cAlias197)->CC7_DESCR
		EndIf

		oJCodL9597[(cAlias197)->CC7_CODLAN + (cAlias197)->F4_CODIGO] := {(cAlias197)->CC7_CODLAN,;
																		(cAlias197)->F4_CODIGO,;
																		(cAlias197)->CC7_IFCOMP,;
																		Alltrim((cAlias197)->CCE_DESCR),;
																		cDesAjuste}
	(cAlias197)->(DbSkip())
	EndDo
		
	(cAlias197)->(DbCloseArea())	
	oQry187CDA:Destroy()
	oQry187CDA := Nil

    FreeObj(oCacheMSMM)
    oCacheMSMM := Nil

Return oJCodL9597


/*/{Protheus.doc} SPDD190MV
    Realiza a geração do registro D190 quando o parametro MV_SPDD197 estiver 
	preenchido com códigos de lançamento especificos. Esta função é usada 
	quando não para pela função SPLancCDA.

    @type  Function
    @author Jose Ricardo Bernardo
    @since 23/11/2025
    @version 12.1.2510
	@param aRegC170   , Array   , Informações sobre os itens da Nota processado no while da função principal
	@param cAliasSFT  , Caracter, Alias da tabela SFT posicionada
	@param aRegD190   , Array   , Array com as informações acumuladas do Registro D190 que são atualizadas no processamento de cada item
	@param nRedBSICM  , Numérico, Valor de Redução de Base do ICMS
	@param aLanTransp , Array   , Array com os Codigos de Ajuste originados do PE SPEDD197	
	@param aReg0460   , Array   , Array com os Codigos de observacoes do código de lançamento.
/*/
Function SPDD190MV(aRegC170, cAliasSFT, aRegD190, nRedBSICM, aLanTransp, aReg0460 )
                
	Local nPos     := 0

	If (nPos := aScan(aRegD190,{|aX| aX[2]==aRegC170[1][10] .And. aX[3]==aRegC170[1][11] .And. aX[4]==aRegC170[1][14]}))==0

		aAdd(aRegD190, {})
		nPos := Len(aRegD190)
		aAdd (aRegD190[nPos], "D190")						//01 - REG
		aAdd (aRegD190[nPos], aRegC170[1][10])				//02 - CST
		aAdd (aRegD190[nPos], aRegC170[1][11])				//03 - CFOP
		aAdd (aRegD190[nPos], aRegC170[1][14])				//04 - ALIQ_ICMS
		aAdd (aRegD190[nPos], 0)							//05 - VL_OPR
		aAdd (aRegD190[nPos], 0)							//06 - VL_BC_ICMS
		aAdd (aRegD190[nPos], 0)							//07 - VL_ICMS
		aAdd (aRegD190[nPos], 0)							//08 - VL_RED_BC
		aAdd (aRegD190[nPos], "")							//09 - COD_OBS

		// Se houver lancamento fiscal nao amarrado ao D197, devo prioriza-lo
		If Len(aLanTransp)>=5
			aRegD190[nPos,9] := aLanTransp[3]

			// REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL
			IF !( empty( aLanTransp[3] ) .and. empty( aLanTransp[5]) )
				Reg0460(@aReg0460, { aLanTransp[3], aLanTransp[5]})
			ENDIF

		EndIf

	EndIf

	//-- Realiza somatório de valores
	aRegD190[nPos][5]	+=	(cAliasSFT)->FT_VALCONT	 		//05 - VL_OPR
	aRegD190[nPos][6]	+=	aRegC170[1][13]					//06 - VL_BC_ICMS
	aRegD190[nPos][7]	+=	aRegC170[1][15]					//07 - VL_ICMS
	aRegD190[nPos][8]	+=	nRedBSICM						//08 - VL_RED_BC

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SPDD195197

@description Realiza a geração dos registro D195 e D197 quando informação 
             originada do parametro MV_SPDD197 visando otimizar performance 
			 nos cenários envolvendo Codigo de Lancamento constante, 
			 evitando multiplas chamadas na tabela CDA via SPLancCDA
			 
@author Jose Ricardo Bernardo
@since 20/11/2025
@version 12.1.2510
/*/
Function SPDD195197(cAlias, nRelac, aD195D197, aReg0460, aCmpAntSFT, aD197Aux)
	Local	nPos		:=	0
	Local	nPosD195	:=	0

	Local	aRegD195	:=	{}
	Local	aRegD197	:=	{}

	Local	cCodAjuste  := aD197Aux[1]
	Local	cDesAjuste  := aD197Aux[5]

	//³Processando lancamentos originados do Ponto de Entrada para gravação do registro D195 / D197 ³

	//³Geracao do REGISTRO D195
	aAdd(aRegD195, {})
	nPosD195 := Len(aRegD195)
	aAdd (aRegD195[nPosD195], "D195"      ) //01 - REG
	aAdd (aRegD195[nPosD195], aD197Aux[3] ) //02 - COD_OBS
	aAdd (aRegD195[nPosD195], ''		  ) //03 - TXT_COMPL	

	aAdd (aRegD195[nPosD195], RetRD(GetRelacPr())+strzero(nPosD195,nTamFT_IT)) //04 - - Posição de Hierarquia
			
	//³REGISTRO 0460 - TABELA DE OBSERVACOES DO LANCAMENTO FISCAL
	Reg0460(@aReg0460, {  aD197Aux[3] , aD197Aux[5] })

	// Regras especificas
	If cCodAjuste $ "SP90090104/SP90090278" // Portaria CAT Nº 66 DE 25/07/2018 de São Paulo é nescessario que CFOP seja adicionado no campo de descrição do registro C197 
		cDesAjuste := aCmpAntSFT[09]
		If aD195D197[1][2] == 0
			aD195D197[1][2] := ''
		EndIf
		If aD195D197[1][3] == 0
			aD195D197[1][3] := ''
		EndIf		
	EndIf

	//³Geracao do REGISTRO D197
	aAdd(aRegD197, {})
	nPos :=	Len (aRegD197)
	aAdd (aRegD197[nPos], nPosD195)									//01 - RELACIONAMENTO COM D195 (PAI)
	aAdd (aRegD197[nPos], "D197")	   								//02 - REG
	aAdd (aRegD197[nPos], cCodAjuste				)				//03 - COD_AJ
	aAdd (aRegD197[nPos], cDesAjuste				)				//04 - DESCR_COMPL_AJ
	aAdd (aRegD197[nPos], ''						)				//05 - COD_ITEM
	aAdd (aRegD197[nPos], aD195D197[1][2]			)				//06 - VL_BC_ICMS
	aAdd (aRegD197[nPos], aD195D197[1][3]			)			 	//07 - ALIQ_ICMS
	aAdd (aRegD197[nPos], aD195D197[1][4]			)				//08 - VL_ICMS
	aAdd (aRegD197[nPos], 0							)				//09 - VL_OUTROS

	aAdd (aRegD197[nPos], RetRD(GetRelacPr())+strzero(nPosD195,nTamFT_IT)) //10 - - Posição de Hierarquia

	GrRegDep(cAlias, aRegD195, aRegD197,,,,,,.T.,.T.)

Return
