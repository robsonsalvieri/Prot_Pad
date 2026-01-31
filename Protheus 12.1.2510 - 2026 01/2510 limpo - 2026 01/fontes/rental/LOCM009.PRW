#INCLUDE "PROTHEUS.CH"
#Include "TopConn.ch"

/*/{Protheus.doc} LOCM009
Função para processar deleção de item da nota de entrada no Rental
@type function
@version 1
@author Circenis
@since 03/016/2024
@return variant, return_description
/*/
FUNCTION LOCM009()

	Local cQuery 	:= ""
	Local lDel 	:= .f.
	Local lMVLOCBAC := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
	Local lEstCla
	Local aBindParam  := {}
	Local lLocX022  := SuperGetMV("MV_LOCX022",,.F.)
	Local lLocx278  := Getmv("MV_LOCX278",,.F.)

	Private cAuxDoc	:= " "
	Private cAuxSer	:= " "
	Private _nOpc  := 5  // compatibilização para o funcionamento do locxitu21

	// DSERLOCA-6564 - Frank em 04/07/2025
    // Tratamento da geração do título provisório pelo campo FP0_PROV
    If FP0->(FieldPos("FP0_PROV")) > 0
        If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
            lLocx278 := .T.
        Else
            lLocx278 := .F.
        EndIf
    EndIf

	if AtIsRotina("A103GRAVA") .or. AtIsRotina("LOCXDELNF") // Na gravação da nota de entrada Classificada

		If AtIsRotina("A140ESTCLA")
			lEstCla := .T.					// Estorno de Classificacao
		EndIf

		if !Empty(SD1->D1_NFORI) .and. lMVLOCBAC .and. !lEstCla  // Tem Nota de Origem verificar se é uma devolução de locação e não está com a integreção ligada

			aBindParam  := {}
			cQuery := "SELECT  DISTINCT ZAG.R_E_C_N_O_ FPARECNO , FQZ.R_E_C_N_O_ FQZRECNO"
			cQuery += "  FROM " + RetSqlName("SD2") + " SD2"
			cQuery += "        INNER JOIN " + RetSqlName("FPZ") + " FPZ"
			cQuery += "                     ON  FPZ_FILIAL  = D2_FILIAL"
			cQuery += "                     AND FPZ_PEDVEN  = D2_PEDIDO"
			cQuery += "                     AND FPZ_ITEM    = D2_ITEMPV"
			cQuery += "                     AND FPZ.D_E_L_E_T_ = ' '"
			cQuery += "        INNER JOIN " + RetSqlName("FPY") + " FPY"
			cQuery += "                     ON  FPY_FILIAL  = FPZ_FILIAL"
			cQuery += "                     AND FPY_PEDVEN  = FPZ_PEDVEN"
			cQuery += "                     AND FPY_TIPFAT = 'R'"
			cQuery += "                     AND FPY.D_E_L_E_T_ = ' '"
			cQuery += "        INNER JOIN " + RetSqlName("FPA") + " ZAG"
			cQuery += "                     ON  FPA_FILIAL = D2_FILIAL"
			cQuery += "                     AND FPA_NFREM  = D2_DOC"
			cQuery += "                     AND FPA_SERREM = D2_SERIE"
			cQuery += "                     AND FPA_DNFREM = D2_EMISSAO"
			cQuery += "                     AND FPA_AS     = FPZ_AS"
			cQuery += "                     AND ZAG.D_E_L_E_T_ = ' '"
			cQuery += "        INNER JOIN " + RetSqlName("FP0") + " ZA0"
			cQuery += "                     ON  FP0_FILIAL = FPA_FILIAL"
			cQuery += "                     AND FP0_PROJET = FPA_PROJET"
			cQuery += "                     AND ZA0.D_E_L_E_T_ = ' '"
			cQuery += " INNER JOIN " + RetSqlName("FQZ") + " FQZ"
			cQuery += "   ON FQZ_FILIAL   = D2_FILIAL "
			cQuery += "   AND FQZ_DOC     = ?"
			Aadd(aBindParam, SD1->D1_DOC)
			cQuery += "   AND FQZ_SERIE   = ?"
			Aadd(aBindParam, SD1->D1_SERIE)
			cQuery += "   AND FQZ_FORNE   = ?"
			Aadd(aBindParam, SD1->D1_FORNECE)
			cQuery += "   AND FQZ_LOJA    = ?"
			Aadd(aBindParam, SD1->D1_LOJA)
			cQuery += "   AND FQZ_ITEM    = ?"
			Aadd(aBindParam, SD1->D1_ITEM)
			cQuery += "   AND FQZ_MSBLQL  = '2'" // Não bloqueado
			cQuery += "   AND SD2.D_E_L_E_T_ = ' '"
			cQuery += " WHERE D2_FILIAL  = ?"
			Aadd(aBindParam, SD1->D1_FILIAL)
			cQuery += "   AND D2_DOC     = ?"
			Aadd(aBindParam,SD1->D1_NFORI)
			cQuery += "   AND D2_SERIE   = ?"
			Aadd(aBindParam, SD1->D1_SERIORI)
			cQuery += "   AND D2_ITEM    = ?"
			Aadd(aBindParam, SD1->D1_ITEMORI)
			cQuery += "   AND SD2.D_E_L_E_T_ = ' '"

			//If Select("TRBFPA") > 0
			//	TRBFPA->(dbCloseArea())
			//EndIf
			cQuery := ChangeQuery(cQuery)
			MPSysOpenQuery(cQuery,"TRBFPA",,,aBindParam)
			//TcQuery cQuery New Alias "TRBFPA"

			If TRBFPA->(!Eof())

				dbSelectArea("FPA")
				dbSelectArea("SD1")
				dbSelectArea("TQY")
				dbSelectArea("ST9")
				dbSelectArea("FPN")


				While TRBFPA->(!Eof())

					FPA->(dbGoTo(TRBFPA->FPARECNO))

					// Frank em 22/07/22 - controle para ver se usar o conceito de Romaneio
					_lTemZUC := .F.
					aBindParam  := {}
					cQuery := " SELECT FQ3_QTD, FQ3_ITEM "
					cQuery += " FROM " + RetSqlName("FQ3") + " SZ1"
					cQuery += " WHERE "
					cQuery += "       SZ1.FQ3_FILIAL = '"+xFilial("FQ3")+"' and "
					cQuery += "       SZ1.FQ3_AS = ? and "
					Aadd(aBindParam, FPA->FPA_AS)
					cQuery += "       SZ1.FQ3_VIAGEM = ? and "
					Aadd(aBindParam, FPA->FPA_VIAGEM)
					cQuery += "       SZ1.FQ3_NUM = ? and "
					Aadd(aBindParam, SF1->F1_IT_ROMA)
					cQuery += "       SZ1.D_E_L_E_T_ = ' ' "
					cQuery += " ORDER BY FQ3_ITEM "
					
					cQuery := ChangeQuery(cQuery)
					MPSysOpenQuery(cQuery,"TRBSZ1",,,aBindParam)

					If !TRBSZ1->(Eof())
						_lTemZUC := .T.
					EndIf
					TRBSZ1->(dbCloseArea())

					// Verificar a quantidade que foi enviado x a quantidade retornada.
					// Só armazenar a nota se for a ultima entrada, ou seja, se as quantidades forem iguais.
					// Frank 19/10/20
					FP0->(dbSetOrder(1))
					FP0->(dbSeek(xfilial("FP0")+FPA->FPA_PROJET))

					FQ7->(dbSetOrder(1))
					FQ7->(dbSeek(xFilial("FQ7")+FPA->FPA_PROJET))
					While !FQ7->(Eof()) .and. FQ7->FQ7_FILIAL == xFilial("FQ7") .and. FQ7->FQ7_PROJET == FPA->FPA_PROJET
						If FQ7->FQ7_NFRET == SD1->D1_DOC .and. FQ7->FQ7_SERRET == SD1->D1_SERIE .and. FQ7->FQ7_FORNE == SD1->D1_FORNECE .and. FQ7->FQ7_LOJF == SD1->D1_LOJA
							FQ7->(RecLock("FQ7",.F.))
							FQ7->FQ7_NFRET := ""
							FQ7->FQ7_SERRET := ""
							FQ7->FQ7_FORNE := ""
							FQ7->FQ7_LOJF := ""
							FQ7->(MsUnlock())

						EndIf
						FQ7->(dbSkip())
					EndDo

					If FPA->(RecLock("FPA",.F.))
						cAuxDoc		:= FPA->FPA_NFRET
						cAuxSer		:= FPA->FPA_SERRET
						FPA->FPA_NFRET  := ""
						FPA->FPA_SERRET := ""
						FPA->FPA_DNFRET := StoD("")
						FPA->FPA_ITERET := ""
						FPA->FPA_DTSCRT := StoD("") // Jose Eulalio - 29/09/2022 - SIGALOC94-522/Chamado 29981 - ALIGN - Não gera faturamento automático, quando teve nota de retorno

						//If FP0->FP0_TIPOSE == "L" .and. !_lTemZUC
						If FP0->FP0_TIPOSE == "L" // Jose Eulalio - 29/09/2022 - o Saldo deverá sempre retornar no caso de retorno parcial
							// para efeito da cobranca somar a quantidade
							_nRet := 0
							_aAreaFQZ := FQZ->(GetArea())
							FQZ->(dbGoTo(TRBFPA->FQZRECNO))

							// o campo FPA_CONFIG identifica as notas que não devem ser computadas no estorno
							If alltrim(FQZ->FQZ_DOC+FQZ->FQZ_SERIE) <> alltrim(FPA->FPA_CONFIG)
								If FQZ->FQZ_DOC == SD1->D1_DOC .and. FQZ->FQZ_SERIE == SD1->D1_SERIE .and. alltrim(FQZ->FQZ_AS) == alltrim(FPA->FPA_AS) .and. empty(FQZ->FQZ_DTCANC)
									_nRet += FQZ->FQZ_QTD
								EndIF
							EndIF

							FQZ->(RestArea(_aAreaFQZ))
							FPA->FPA_QUANT := FPA->FPA_QUANT + _nRet
							IF FPA->(FIELDPOS("FPA_QTDRET")) > 0
								FPA->FPA_QTDRET := FPA->FPA_QTDRET - _nRet 
							EndIf
							FPA->FPA_VLBRUT := FPA->FPA_PRCUNI * FPA->FPA_QUANT
							FPA->FPA_VRHOR := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT -(FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC)))
						EndIF

						If FP0->FP0_TIPOSE == "L" 
							
							if _lTemZUC

								aBindParam  := {}
								cQuery := " SELECT SZ1.R_E_C_N_O_ AS REG "
								cQuery += " FROM " + RetSqlName("FQ3") + " SZ1"
								cQuery += " WHERE "
								cQuery += "       SZ1.FQ3_FILIAL = '"+xFilial("FQ3")+"' and "
								cQuery += "       SZ1.FQ3_AS = ? and "
								Aadd(aBindParam ,FPA->FPA_AS)
								cQuery += "       SZ1.FQ3_VIAGEM = ? and "
								Aadd(aBindParam ,FPA->FPA_VIAGEM)
								cQuery += "       SZ1.FQ3_NUM = ? and "
								Aadd(aBindParam ,SF1->F1_IT_ROMA)
								cQuery += "       SZ1.D_E_L_E_T_ = ' ' "
								cQuery += " ORDER BY FQ3_ITEM "

								cQuery := ChangeQuery(cQuery)
								MPSysOpenQuery(cQuery,"TRBFQ3",,,aBindParam)

								lDel := .F.
								_nReg := 0
								While !TRBFQ3->(Eof())
									FQ3->(dbGoto(TRBFQ3->REG))
									FQ3->(Reclock("FQ3",.F.))
									FQ3->FQ3_NFRET := ""
									FQ3->FQ3_SERRET := ""
									FQ3->FQ3_FORNE := ""
									FQ3->FQ3_LOJF := ""
									FQ3->(MsUnlock())
									If !lDel
										_nReg := TRBFQ3->REG
									EndIF
									TRBFQ3->(dbSkip())
									lDel := .T.
								Enddo

								If lDel
									FQ3->(dbGoto(_nReg))
									FQ2->(dbSetOrder(1))
									If FQ2->(dbSeek(xFilial("FQ2")+FQ3->FQ3_NUM))
										FQ2->(RecLock("FQ2",.F.))
										FQ2->FQ2_NFSER := ""
										FQ2->(MsUnlock())
									EndIF
								EndIF

								TRBFQ3->(dbCloseArea())

							elseif FwAliasInDic("FQX") // Nova tabela de dicionario

								aBindParam  := {}
								cQuery := " SELECT FQX.R_E_C_N_O_ AS REG "
								cQuery += " FROM " + RetSqlName("FQX") + " FQX"
								cQuery += " WHERE "
								cQuery += "       FQX.FQX_FILIAL = '"+xFilial("FQX")+"' and "
								cQuery += "       FQX.FQX_AS = ? and "
								Aadd(aBindParam ,FPA->FPA_AS)
								cQuery += "       FQX.FQX_NUM = ? and "
								Aadd(aBindParam ,SF1->F1_IT_ROMA)
								cQuery += "       FQX.D_E_L_E_T_ = ' ' "
								cQuery += " ORDER BY FQX_ITEM "

								cQuery := ChangeQuery(cQuery)
								MPSysOpenQuery(cQuery,"TRBFQX",,,aBindParam)

								lDel := .F.
								_nReg := 0
								While !TRBFQX->(Eof())
									FQX->(dbGoto(TRBFQX->REG))
									FQX->(Reclock("FQX",.F.))
									FQX->FQX_STATUS := IF( FQX->FQX_STATUS = '5', '2', '3')
									FQX->FQX_NFRET  := ""
									FQX->FQX_SERRET := ""
									FQX->FQX_ITEMNF := ""
									FQX->FQX_FORNEC := ""
									FQX->FQX_LOJA   := ""
									FQX->FQX_FORMUL := ""
									FQX->(MsUnlock())
									If !lDel
										_nReg := TRBFQX->REG
									EndIF

									// Gravar a nota de Devolução dos I.D. do grupo tipo 3
									if !Empty(GetSx3Cache("FH2_DTDEV","X3_TITULO"))
										FH2->(dbSetOrder(1)) // Verificar se existem bens quantificaveis
										IF FH2->(dbSeek(xFilial("FH2")+FPA->FPA_AS))

											cQuery := " SELECT   FQD_STATQY"
											cQuery += " FROM " + RetSqlName("FQD") + " FQD "
											cQuery += " WHERE    FQD.FQD_STAREN < '50' "
											cQuery += "   AND    FQD.D_E_L_E_T_ = ' ' "
											cQuery += " ORDER BY FQD_STAREN DESC "
											cQuery := changequery(cQuery)
											MPSysOpenQuery(cQuery,"TRBFQD")
											TRBFQD->(dbGotop())

											while !(FH2->(Eof())) .and. FH2->FH2_AS = FPA->FPA_AS .and. FH2->FH2_FILIAL = xFilial("FH2")
										
												if FQX->FQX_NUM = FH2->FH2_ROMRET
													RecLock("FH2", .F.)
													FH2->FH2_NFRET  := ""
													FH2->FH2_SERRET := ""
													FH2->FH2_INFRET := ""
													FH2->FH2_FORNEC  := ""
													FH2->FH2_LOJART  := ""
													FH2->FH2_FORMUL  := ""
													FH2->FH2_DTDEV   := Ctod("//")
													MsUnlock()
									
													ST9->(dbSeek(xFilial("ST9")+FH2->FH2_CODBEM))
													cStatST9 := ST9->T9_STATUS
													If RecLock("ST9",.F.)
														ST9->T9_STATUS := TRBFQD->FQD_STATQY
														ST9->(MsUnLock())
													EndIf
													LOCXITU21(cStatST9,TRBFQD->FQD_STATQY, FH2->FH2_CONTRA, SD1->D1_DOC, SD1->D1_SERIE)	
												endif	
												FH2->(dbSkip())
											
											enddo									
										endif	
									endif

									TRBFQX->(dbSkip())
									lDel := .T.
								Enddo

								If lDel
									FQX->(dbGoto(_nReg))
									FQW->(dbSetOrder(1))
									If FQW->(dbSeek(xFilial("FQW")+FQX->FQX_NUM))
										FQW->(RecLock("FQW",.F.))
										FQW->FQW_STATUS := FQX->FQX_STATUS
										FQW->FQW_NFRET  := ""
										FQW->FQW_SERRET := ""
										FQW->FQW_FORMUL := ""
										FQW->FQW_TIPONF := ""
										FQW->(MsUnlock())
									EndIF
								EndIF

								TRBFQX->(dbCloseArea())
							endif

						EndIf

						

						// Cancelamento do log das notas de entrada x orçamento.
						// Frank Z Fuga em 08/09/2020
						If lLocX022 //SuperGetMV("MV_LOCX022",,.F.)
							ITLOGFQZ(SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_ITEM, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_EMISSAO, SD1->D1_COD, SD1->D1_QUANT, FPA->FPA_AS, _nOpc, FPA->FPA_PROJET, FPA->FPA_OBRA, .F.)
						EndIf

						// Tratamento dos titulos provisorios - voltar com os PR
						If lLocx278 //getmv("MV_LOCX278",,.F.)
							FP0->(dbSetOrder(1))
							FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
							_nRegX := FPA->(Recno())
							loca01318() // criacao do titulo provisorio
							FPA->(dbGoto(_nRegX))
						EndIF

						FPA->(MsUnLock())

					EndIf
					aBindParam := {}
					cQuery := " SELECT ZLF.R_E_C_N_O_ ZLFRECNO, FPN_AS, FPN_DTINIC, FPN_DTFIM"
					cQuery += " FROM " + RetSqlName("FPN") + " ZLF"
					cQuery += " WHERE  FPN_FILIAL = ?"
					Aadd(aBindParam, FPA->FPA_FILIAL )
					cQuery += "   AND  FPN_AS     = ?"
					Aadd(aBindParam, FPA->FPA_AS )
					cQuery += "   AND  FPN_PROJET = ?"
					Aadd(aBindParam, FPA->FPA_PROJET )
					cQuery += "   AND  FPN_VIAGEM = ?"
					Aadd(aBindParam, FPA->FPA_VIAGEM )
					cQuery += "   AND  FPN_DTFIM  = ?"
					Aadd(aBindParam, DtoS(SF1->F1_EMISSAO) )
					cQuery += "   AND  FPN_NUMPV  = ' '"
					cQuery += "   AND  FPN_SITUAC IN ('1','2')"
					cQuery += "   AND  ZLF.D_E_L_E_T_ = ' '"
					cQuery += " ORDER BY ZLFRECNO"

					cQuery := ChangeQuery(cQuery)
					MPSysOpenQuery(cQuery,"TRBFPN",,,aBindParam)

					If TRBFPN->(!Eof())
						FPN->(dbGoTo(TRBFPN->ZLFRECNO))

						If FPN->(RecLock("FPN",.F.))
							FPN->FPN_DTMEDP := (FPN->FPN_DTINIC)+(FPA->FPA_LOCDIA)-1
							FPN->FPN_DTFIM := (FPN->FPN_DTINIC)+(FPA->FPA_LOCDIA)-1

							FPN->(MsUnlock())
						EndIf
					EndIf
					TRBFPN->(dbCloseArea())

					TRBFPA->(dbSkip())
				EndDo

			EndIf
		EndIf
	endif
RETURN

// Rotina para criar o log das notas de entradas x movimentos da ZAG
// Frank Zwarg Fuga - 08/09/2020
Static Function ITLOGFQZ(cDoc, cSerie, cItem, cForne, cLoja, dEmiss, cProd, nQtd, cAs, nVar, cProjet, cObra, lMarcacao)
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local cQuery := ""
Local cQryPesq  := ""

    // Rotina valida somente para o tipo de serviço Locação.
    If FP0->FP0_TIPOSE == "L"
        FQZ->(dbSetOrder(1))
        If nVar == 5
            // Quando for realizado a exclusão da nota de entrada, verificar se o registro do log existe
            // Se existir deixar como cancelado, se não existir criar e deixar como cancelado
            If FQZ->(dbSeek(xFilial("FQZ")+cDoc+cSerie+cForne+cLoja+cItem))
                FQZ->(RecLock("FQZ",.F.))
                FQZ->FQZ_MSBLQL := "1"
                FQZ->FQZ_DTCANC	:= dDataBase
                FQZ->(dbDelete())
                FQZ->(MsUnlock())

            EndIf

    		If ! Empty(FPA->FPA_GRUA) .And. ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
	    		If !lMvLocBac /*/ Só será chamado com MVLOCBAC .T.
		    	/*	If Select("TRBTQY") > 0
			    		TRBTQY->(dbCloseArea())
		    		EndIf
			    	cQuery := " SELECT   TQY_STATUS"
    				cQuery += " FROM " + RetSqlName("TQY") + " TQY "
	    			cQuery += " WHERE    TQY.TQY_STTCTR < '50' "
		    		cQuery += "   AND    TQY.D_E_L_E_T_ = ' ' "
			    	cQuery += " ORDER BY TQY_STTCTR DESC "
    				cQuery := changequery(cQuery)
	    			TcQuery cQuery New Alias "TRBTQY"
		    		TRBTQY->(dbGotop()) // antes era na query top 1, agora pegamos o primeiro registro

			    	If ! TRBTQY->(Eof())
				    	LOCXITU21(ST9->T9_STATUS,TRBTQY->TQY_STATUS,FPA->FPA_PROJET,FPA->FPA_NFREM,FPA->FPA_SERREM,.T.)
					    If RecLock("ST9",.F.)
	    					ST9->T9_STATUS := TRBTQY->TQY_STATUS
		    				ST9->(MsUnLock())
			    		EndIf
				    EndIf

				    TRBTQY->(dbCloseArea()) */
    			else
//	    			If Select("TRBFQD") > 0
//		    			TRBFQD->(dbCloseArea())
//			    	EndIf
                    cQryPesq := " SELECT   FPA_PROJET"
	    			cQryPesq += " FROM " + RetSqlName("FPA") + " FPA "
		    		cQryPesq += " WHERE  FPA.D_E_L_E_T_ = ' ' "
                    cQryPesq += "   AND  FPA.FPA_PROJET <> ? "
                    cQryPesq += "   AND  FPA.FPA_PRODUT = ? "
                    cQryPesq += "   AND  FPA.FPA_GRUA = ? "
                    cQryPesq += "   AND  FPA.FPA_NFRET = ' ' "
                    cQryPesq := changequery(cQryPesq)
                    aBindParam := {FPA->FPA_PROJET,FPA->FPA_PRODUT, FPA->FPA_GRUA}
	                MPSysOpenQuery(cQryPesq,"TRBPSQ",,,aBindParam)
					TRBPSQ->(dbGotop()) 
		    		If TRBPSQ->(Eof()) // verifica se bem não está em outro contrato // Rossana - DSERLOCA 3570 - 15/07/24
    
					    cQuery := " SELECT   FQD_STATQY"
		    			cQuery += " FROM " + RetSqlName("FQD") + " FQD "
			    		cQuery += " WHERE    FQD.FQD_STAREN < '50' "
    					cQuery += "   AND    FQD.D_E_L_E_T_ = ' ' "
		    			cQuery += " ORDER BY FQD_STAREN DESC "
			    		cQuery := changequery(cQuery)
        	            MPSysOpenQuery(cQuery,"TRBFQD")
    					TRBFQD->(dbGotop()) // antes era na query top 1, agora pegamos o primeiro registro

			    		If ! TRBFQD->(Eof())
				    		LOCXITU21(ST9->T9_STATUS,TRBFQD->FQD_STATQY,FPA->FPA_PROJET,FPA->FPA_NFREM,FPA->FPA_SERREM,.T.)
		    	    		If RecLock("ST9",.F.)
		    					ST9->T9_STATUS := TRBFQD->FQD_STATQY
				    			ST9->(MsUnLock())
					    	EndIf
					    EndIf

	    				TRBFQD->(dbCloseArea())
					Else
						If FQ4->(dbSeek( xFilial("FQ4") + FPA->FPA_GRUA ))
							While !FQ4->(Eof()) .and. FQ4->FQ4_FILIAL+FQ4->FQ4_CODBEM==xFilial("FQ4") + FPA->FPA_GRUA
								If FQ4->FQ4_STATUS == "L3" .and. FQ4->FQ4_PROJET==FPA->FPA_PROJET
									If FQ4->FQ4_DOCUME == cAuxDoc .and. FQ4->FQ4_SERIE == cAuxSer
										IF RECLOCK("FQ4",.F.)
											FQ4->FQ4_DOCUME := ""
                                   			FQ4->FQ4_SERIE  := ""
                                  			FQ4->(MsUnLock())
										EndIf
                               	 	EndIf
                            	EndIf
                            	FQ4->(DbSkip())
                            End
                        EndIf
					EndIf
    			    TRBPSQ->(dbCloseArea())
		    	Endif
		    EndIf
        EndIf
    EndIf
	
Return .T.
