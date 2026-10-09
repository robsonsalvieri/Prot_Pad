#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} Loca021CQZ
Cria itens no pedido de vendas com os valores de pro rata referentes a A.S. posicionada
@type function
@version 25.10
@author Alexandre Circenis
@since 20/05/2026
@param nItens, numeric, NUmero do ultimo item incluido no array que vai gerar o pedido
@param cAS, character, Codigo da A.S. processada no faturamento
@param aItensPV, array, Array com os itens do Pedido
@param aFPZ, array, Array com o complemento do Rental dos itens do pedido
@param aRegFQZ, array, Array com os Registros da FQZ usados para faturamento
@param aProjetos, array, Array com os projetos processados
@param nTotPed, numeric, Valor total do pedido
@return variant, Retorna .T. para questões de compatibilidade
/*/
Function Loca021CQZ( nItens, cAS, aItensPV, aFPZ, aRegFQZ , aProjetos, nTotPed) 
Local cQuery := ""
Local aBindParam := {}
Local aItemTemp  := {}
Local aAreas   := {}
Local nX
Local lLoca21A1 := ExistBlock("LOCA21A1")
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.T.) //Integração com Módulo de Locações SIGALOC
Local _LOCA021D := EXISTBLOCK("LOCA021D")
Local _LCVAL    := SuperGetMv("MV_LOCX051",.F.,.T.)
Local nValUnit
Local _CTES     := SuperGetMv("MV_LOCX080" ,.T.,"" )

	Aadd(aAreas, FPA->(GetArea()))	
	Aadd(aAreas, FP1->(GetArea()))
	Aadd(aAreas, FP0->(GetArea()))
	Aadd(aAreas, GetArea())

	aBindParam := {}
	cQuery += " SELECT FPA_PROJET, FPA_OBRA, FPA_AS, FQZ_PROJET, FP1_OBRA, FQZ.R_E_C_N_O_ REG, FPA.R_E_C_N_O_ FPARECNO, FP1.R_E_C_N_O_ FP1RECNO, FP0.R_E_C_N_O_ FP0RECNO  "
	cQuery += " FROM "+RETSQLNAME("FQZ")+ " FQZ "
	cQuery += " INNER JOIN "+RETSQLNAME("FPA")+" FPA ON FPA_FILIAL='"+XFILIAL("FPA")+"' AND FPA.D_E_L_E_T_ = ' ' AND FPA_AS = FQZ.FQZ_AS AND FPA_AS <> '' "
	cQuery += " AND FPA_TIPOSE <> 'S' "
	cQuery += " AND FPA_AS = FQZ.FQZ_AS "
	cQuery += " INNER JOIN "+RETSQLNAME("FP0")+" FP0  ON FP0_FILIAL='"+XFILIAL("FP0")+"' AND FP0.D_E_L_E_T_ = ' ' AND FP0_PROJET = FPA_PROJET "
	cQuery += " INNER JOIN "+RETSQLNAME("FP1")+" FP1 ON FP1_FILIAL='"+XFILIAL("FP1")+"' AND FP1_PROJET = FP0_PROJET and FP1_OBRA = FPA_OBRA
	cQuery += " WHERE  FQZ.FQZ_FILIAL  = '"+XFILIAL("FQZ")+"' "
	cQuery += "   AND  FQZ.FQZ_AS = ? "
	aadd(aBindParam, cAS)
	cQuery += "   AND  FQZ.FQZ_PV   = ' ' "
	cQuery += "   AND  FQZ.FQZ_MSBLQL  = '2' "
	cQuery += "   AND  FQZ.FQZ_RETIRA <= FPA.FPA_DTFIM"
	cQuery += "   AND  FQZ.D_E_L_E_T_ = ' ' "
	cQuery += "   AND FQZ.FQZ_RETIRA BETWEEN ? AND ? "
	aadd(aBindParam,DTOS(CPAR21))
	aadd(aBindParam,DTOS(CPAR22))
	cQuery := CHANGEQUERY(cQuery) // estava comentado - DSERLOCA 5180
	MPSysOpenQuery(cQuery,"TRBFQZ",,,aBindParam)

	If lLoca21A1
		lBloqPe := EXECBLOCK("LOCA21A1" , .T. , .T. , {"P", {} }  )
		If lBloqPe
			Return .F.
		EndIf			
	EndIf

	WHILE !TRBFQZ->(EOF())
		FQZ->(DBGOTO(TRBFQZ->REG))
		FPA->( DBGOTO(TRBFQZ->FPARECNO) )
		FP1->( DBGOTO(TRBFQZ->FP1RECNO) )
		FP0->( DBGOTO(TRBFQZ->FP0RECNO) )
		//if len(aUltfat) > 0  // se for selecionada  locacao e pro-rata
		//	nPosUltDt := aScan(aUltfat, {|aItem| aItem[1] == TRBFQZ->FPARECNO})
		//	nUltData := aUltFat[nPosUltDt,2]
		//else // se for selecionada apenas pro-rata
			nUltData := FPA->FPA_ULTFAT
		//endif
		// DSERLOCA-9864 - Alessandro Gois, 12/01/2026
//		if FQZ->FQZ_RETIRA > FPA->FPA_DTFIM //FQZ->FQZ_RETIRA < nUltData .or. FQZ->FQZ_RETIRA > FPA->FPA_DTFIM // Frank em 16/01/26
//			aadd(aProjetos,{FPA->FPA_PROJET})
//			TRBFQZ->(dbSkip())
//		else
		
			nQtdItens	:= 0 //SIGALOC94-665 - Jose Eulalio - Gerar mais de um PV quando tiver mais de 300 linhas sendo processada
			aAgluNf   := {} // Itens Aglutinados
			aAgluRat  := {} // Reteio de Aglutinação

			lAglutinar := FP0->(FieldPos("FP0_AGLUNF")) > 0 .And. FP0->FP0_AGLUNF == "1"
			//realiza quebra dos itens
			//WHILE TMP->( !EOF() ) .AND. _CPROJET == TMP->FPA_PROJET
			//nova forma de quebra a partir de SIGALOC94-282 / MULTILPLUS FATURAMENTO NO CONTRATO
			//SIGALOC94-665 - Jose Eulalio - Gerar mais de um PV quando tiver mais de 300 linhas sendo processada
			//QUEBRA PEDIDO POR PROJETO / OBRA / CLIENTE / QTD ITENS (299)
			// Ao aglutinar não há limite de itens
			// Frank em 22/01/2026 - ISSUE DSERLOCA-10384

			WHILE TRBFQZ->( !EOF() ) 
				FQZ->( DBGOTO(TRBFQZ->REG))
				FPA->( DBGOTO(TRBFQZ->FPARECNO) )
				FP1->( DBGOTO(TRBFQZ->FP1RECNO) )
				FP0->( DBGOTO(TRBFQZ->FP0RECNO) )
				
				If empty(FPA->FPA_TESFAT)
					cTESAux :=  _CTES
				Else
					cTESAux :=  FPA->FPA_TESFAT
				EndIf
				dbSelectArea("SF4")
				dbSetOrder(1)
				dbSeek(xFilial("SF4")+cTESAux)
				// So Gera pedido para valores Positivos e se a TES permitir gerar valores zerados
				if FQZ->FQZ_VLRPRO > 0 .or. (FQZ->FQZ_VLRPRO=0 .and. SF4->F4_VLRZERO == "1")
					FPA->(DBSETORDER(3))
					FPA->(DBSEEK(XFILIAL("FPA")+FQZ->FQZ_AS))
					FP0->(DBSETORDER(1))
					FP0->(DBSEEK(XFILIAL("FP0")+TRBFQZ->FQZ_PROJET))
					FQZ->(dbGoto(TRBFQZ->REG))
					SB1->(DBSETORDER(1))
					SB1->(DBSEEK(XFILIAL("SB1")+FQZ->FQZ_COD))
					//NITENS := STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
					// Frank em 27/12/2022 chamado 612
					aItemTemp := {}
					nItens := soma1(nItens) //   STRZERO( LEN(_AITENSPV)+1 ,TAMSX3("C6_ITEM")[1])
					// FQZ->FQZ_VLRPRO deve ser feito em tempo de execução
					dDtInip := ctod("")
					nPerPro := 0
					aFPZPer := FPZ->(GetArea())
					FPZ->(dbSetOrder(2))
					FPZ->(dbSeek(xFilial("FPZ")+FQZ->FQZ_AS))
					While !FPZ->(Eof()) .and. FPZ->(FPZ_FILIAL+FPZ_AS) == xFilial("FPZ")+FQZ->FQZ_AS
						If FQZ->FQZ_RETIRA >= ctod(substr(FPZ->FPZ_PERLOC,1,10)) .and. FQZ->FQZ_RETIRA <= ctod(substr(FPZ->FPZ_PERLOC,14,10))
							dDtIniP := ctod(substr(FPZ->FPZ_PERLOC,1,10))
							Exit
						EndIf
						FPZ->(dbSkip())
					EndDo
					FPZ->(RestArea(aFPZPer))
					If !empty(dDtInip)
						nPerPro := (FQZ->FQZ_RETIRA-dDtInip) + 1
					Else
						// Se não houver um FOZ_PERLOC que contenha a FQZ_RETIRA
						// Temos que encontrar a dDtInip sendo a maior FPZ_PERLOC (data final) que seja <= FQZ_RETIRA
						aFPZPer := FPZ->(GetArea())
						FPZ->(dbSetOrder(2))
						FPZ->(dbSeek(xFilial("FPZ")+FQZ->FQZ_AS))
						dDtInip := ctod("")
						While !FPZ->(Eof()) .and. FPZ->(FPZ_FILIAL+FPZ_AS) == xFilial("FPZ")+FQZ->FQZ_AS
							If ctod(substr(FPZ->FPZ_PERLOC,14,10)) <= FQZ->FQZ_RETIRA
								If ctod(substr(FPZ->FPZ_PERLOC,14,10)) > dDtInip
									dDtInip := ctod(substr(FPZ->FPZ_PERLOC,14,10))
								EndIf
							EndIf
							FPZ->(dbSkip())
						EndDo
						FPZ->(RestArea(aFPZPer))
						If !empty(dDtInip)
							dDtInip ++
							nPerPro := (FQZ->FQZ_RETIRA-dDtInip) + 1
						EndIf		
						If empty(dDtInip)
							nPerPro := (FQZ->FQZ_RETIRA-FPA->FPA_DTINI) + 1
						EndIf					
					EndIf
					FP1->(dbSetOrder(1))
					FP1->(dbSeek(xFilial("FP1")+FPA->(FPA_PROJET+FPA_OBRA)))
					// DSERLOCA-10892 - Usa FQZ_VLRPRO pre-calculado pelo DSERLOCA-10880 (LOCA021 Sit.A progressivo)
					// Fallback para recalculo em tempo de execucao quando FQZ_VLRPRO nao estiver disponivel
					If FQZ->FQZ_VLRPRO > 0
						nCalc := FQZ->FQZ_VLRPRO
					Else
						If FP1->FP1_TPMES == "1" // Mês corrido
							nCalc := ROUND((FQZ->FQZ_VLRTOT * nPerPro) / If(FPA->FPA_LOCDIA==0,1,FPA->FPA_LOCDIA),GETSX3CACHE("C6_VALOR","X3_DECIMAL"))
						Else // Fechado ou Fixo
							nCalc := ROUND((FQZ->FQZ_VLRTOT * nPerPro) / 30, GETSX3CACHE("C6_VALOR","X3_DECIMAL"))
						EndIF
					EndIF
					AADD(aRegFQZ,{TRBFQZ->REG, nItens})
					nValunit := ROUND(nCalc / FQZ->FQZ_QTD , GETSX3CACHE("C6_PRCVEN","X3_DECIMAL")) 
					nCalc    := ROUND(nValunit * FQZ->FQZ_QTD, GETSX3CACHE("C6_VALOR","X3_DECIMAL"))
					// DSERLOCA-10892, fim
					AADD(aItemTemp , {"C6_FILIAL"  , XFILIAL("SC6")  , NIL})
					AADD(aItemTemp , {"C6_ITEM"    , nItens          , NIL})
					AADD(aItemTemp , {"C6_PRODUTO" , FQZ->FQZ_COD , NIL})
					AADD(aItemTemp , {"C6_DESCRI"  , SB1->B1_DESC , NIL})
					AADD(aItemTemp , {"C6_QTDVEN"  , FQZ->FQZ_QTD  , NIL})
					AADD(aItemTemp , {"C6_PRCVEN"  , nValunit         , NIL})    
					AADD(aItemTemp , {"C6_PRUNIT"  , nValunit        , NIL})
					AADD(aItemTemp , {"C6_VALOR"   , nCalc        , NIL})    
					nTotPed += nCalc 
					AADD(aItemTemp , {"C6_TES"     , cTESAux        , NIL})
					AADD(aItemTemp , {"C6_QTDLIB"  , FQZ->FQZ_QTD  , NIL})
					AADD(aItemTemp , {"C6_CC"      , FPA->FPA_CUSTO  , NIL})
					IF lAglutinar // Vai Haver aglutinação
						//determina o produto pelo tipo de serviço
						If FPA->FPA_TIPOSE == "L"
							cPrdAgluNf := IIF(!Empty(FP0->FP0_PRODL), FP0->FP0_PRODL , cMvLOCX063)
						EndIf
						//caso não tenha nada no array adiciona novo item aglutinado
						If Len(aAgluNf) == 0 .or. aScan(aAgluNf,{|x| x[1]==cPrdAgluNf}) =0
								Aadd(aAgluNf,{ cPrdAgluNf , FQZ->FQZ_VLRPRO , NITENS })
							nItemAglu := Len(aAgluNf)
							nPosPrdAgl := nItemAglu
							//09/09/2022 - Jose Eulalio - SIGALOC94-411 - Ajuste para preenchimento da tabela de rateio de centro de custo.
							aItemAGG := {}
							Aadd(aItemAGG, {"AGG_ITEM"		, StrZero(1,2)	,	NIL })
							Aadd(aItemAGG, {"AGG_PERC"		, NVALLOC			,	NIL }) //será atualizado mais a frente com a proporção
							Aadd(aItemAGG, {"AGG_CC"		, FPA->FPA_CUSTO	,	NIL })
							if _LCVAL
								Aadd(aItemAGG, {"AGG_CLVL"		, FPA->FPA_AS		,	NIL })
							else
								Aadd(aItemAGG, {"AGG_CLVL"		, ""		,	NIL })
							endif
							//campos vazios devem ser enviados
							Aadd(aItemAGG, {"AGG_CONTA"		, ""				,	NIL })
							Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				,	NIL })
							Aadd(aAgluRat, { StrZero(nItemAglu,2,0) , {aClone(aItemAGG)} })
						EndIf
					EndIf
					//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
					//Itens da Tabela de Pedido de Venda x Locação
					If lMvLocBac
						_cPerloc := IF(!empty(FQZ->FQZ_ULTFAT), DTOC(FQZ->FQZ_ULTFAT + 1), DTOC(FQZ->FQZ_DTINI)) + " A " + DTOC(FQZ->FQZ_RETIRA)
						IF _LOCA021D //EXISTBLOCK("LOCA021D")
							_cPerloc := EXECBLOCK("LOCA021D" , .F. , .F., {_CPERLOC} )
						ENDIF

						aBensId := LOCA229XNFR(  FPA->FPA_AS, FQZ->FQZ_DOC, FQZ->FQZ_SERIE) // Buscar ids devolvidos pela nota
						if Len(aBensID) > 0 // Tem ID para o produto gerar Uma FPZ para cada ID
							LOCA021APZ(aFPZ, aBensID, ROUND(nCalc / FQZ->FQZ_QTD,SC6->(GETSX3CACHE("C6_PRUNIT","X3_DECIMAL"))) , nCalc , ;
								IF(!Empty(FQZ->FQZ_ULTFAT), FQZ->FQZ_ULTFAT + 1, FQZ->FQZ_DTINI), FQZ->FQZ_RETIRA, nItens,;
								cTESAux , _LCVAL ,"N", _cPerloc, FQZ->(Recno()),,"PRO-RATA")
						else
							LOCA021APZ(aFPZ, {{FPA->FPA_GRUA,  FPA->FPA_PRODUT, FQZ->FQZ_QTD }}, ROUND(nCalc  / FQZ->FQZ_QTD,SC6->(GETSX3CACHE("C6_PRUNIT","X3_DECIMAL"))) , nCalc , ;
								IF(!Empty(FQZ->FQZ_ULTFAT), FQZ->FQZ_ULTFAT + 1, FQZ->FQZ_DTINI), FQZ->FQZ_RETIRA, nItens,;
								cTESAux , _LCVAL ,"N", _cPerloc, FQZ->(Recno()),,"PRO-RATA")
						endif 
						_NREG++
						NVALTOT += nCalc 
						AADD( aItensPv , ACLONE(aItemTemp) )
					EndIf
				EndIf
				TRBFQZ->(DBSKIP())
			ENDDO // fINALIZOU a prorata do item
		//endif
	enddo	
	TRBFQZ->( DBCLOSEAREA() )

	For nX := 1 To Len(Aareas)
		RestArea(aAreas[nX])
	next

Return .T.
