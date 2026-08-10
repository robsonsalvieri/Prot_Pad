#Include "Totvs.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} LOCM005
ITUP Business - TOTVS RENTAL
Ponto de Entrada na Exclusão do Pedido de Vendas - GPO: Ajusta status na ZC1 e ZAG.
@type Function
@author Frank Zwarg Fuga
@since 03/12/2020
@version P12
@history 03/12/2020, Frank Zwarg Fuga, Fonte produtizado.
Antigo ponto de entrada MA410DEL
/*/

Function LOCM005()
Local _aAreaOld := GetArea()
Local _aAreaSC5 := SC5->(GetArea())
Local _aAreaSC6 := SC6->(GetArea())
Local _aAreaZAG := FPA->(GetArea())
Local _aAreaZA1 := FP1->(GetArea())
Local _aAreaZC1 := FPG->(GetArea())
Local _lRet     := .t.
Local _cQuery   := ""
Local _dProxFat := StoD("")
Local _dUltFat  := StoD("")
Local _nDiasTrb := 0
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local cXTIPFAT
Local cXEXTRA
Local cXPERLOC
Local cXAS
Local lLOCX243  := SuperGetMv("MV_LOCX243",.f.,.f.)
Local aTempFPZ  := {}
Local aTempFPY  := {}
Local dGeraem

	dbSelectArea("FPG")
	dbSelectArea("FPA")
	dbSelectArea("FP1")
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))	// C6_FILIAL + C6_NUM + C6_PRODUTO

	// Frank 05/11/20 - limpar os registros da tabela FQZ
	/*
	xFilial("FQZ")
	SC5->C5_NUM
	*/

	If Select("TRBFQZ") > 0
		TRBFQZ->( DbCloseArea() )
	EndIf

	_cQuery := " SELECT FQZ.R_E_C_N_O_ FQZRECNO" //+ CRLF
	_cQuery += " FROM " + RetSqlName("FQZ") + " FQZ (NOLOCK)" //+ CRLF
	_cQuery += " WHERE  FQZ_FILIAL  = ? " //+ CRLF
	_cQuery += " AND FQZ_PV = ? "
	_cQuery += " AND FQZ.D_E_L_E_T_ = '' " // ajustado 16/02/24 - Frank
	_cQuery := changequery(_cQuery)

	aBindParam := {xFilial("FQZ"), SC5->C5_NUM}
	MPSysOpenQuery(_cQuery,"TRBFQZ",,,aBindParam)

	While TRBFQZ->(!Eof())
		FQZ->(dbGoto(TRBFQZ->FQZRECNO))
		FQZ->(RecLock("FQZ",.F.))
		FQZ->FQZ_PV := ""
		FQZ->(MsUnlock())
		TRBFQZ->(dbSkip())
	EndDo
	TRBFQZ->( DbCloseArea() )

	/*
	xFilial("SC6")
	SC5->C5_NUM
	*/

	If Select("TRBSC6") > 0
		TRBSC6->( DbCloseArea() )
	EndIf

	_cQuery := " SELECT SC6.R_E_C_N_O_ SC6RECNO"
	_cQuery += " FROM " + RetSqlName("SC6") + " SC6 (NOLOCK)"
	_cQuery += " WHERE SC6.C6_FILIAL = ? "
	_cQuery += " AND SC6.C6_NUM = ? "
	//_cQuery += " AND SC6.D_E_L_E_T_ = '' "  // ajustado 16/02/24 - Frank
	// removido o delet pois o registro já foi excluido neste momento. Frank - 14/03/24
	_cQuery := changequery(_cQuery)

	aBindParam := {xFilial("SC6"), SC5->C5_NUM}
	MPSysOpenQuery(_cQuery,"TRBSC6",,,aBindParam)

	While TRBSC6->(!Eof())
		SC6->(dbGoTo(TRBSC6->SC6RECNO))

		If lMvLocBac
			FPY->(dbSetOrder(1))
			FPY->(dbSeek(xFilial("FPY")+SC5->C5_NUM))
			FPZ->(dbSetOrder(1))
			FPZ->(dbSeek(xFilial("FPZ")+SC5->C5_NUM+FPY->FPY_PROJET+SC6->C6_ITEM))
			aTempFPZ := FPZ->(GetArea())
			aTempFPY := FPY->(GetArea())
		EndIF

		If lLOCX243
			If !lMvLocBac
				LOCA062(xFilial("SC5"),SC5->C5_NUM,SC6->C6_ITEM,,,SC6->C6_XAS,,.t.)
			Else
				LOCA062(xFilial("SC5"),SC5->C5_NUM,SC6->C6_ITEM,,,FPZ->FPZ_AS,,.t.)
			EndIF
		EndIf

		If !lMvLocBac
			cXTIPFAT := SC5->C5_XTIPFAT
			cXEXTRA  := SC6->C6_XEXTRA
			cXPERLOC := SC6->C6_XPERLOC
			cXAS     := SC6->C6_XAS
		Else
			cXTIPFAT := FPY->FPY_TIPFAT
			cXEXTRA  := FPZ->FPZ_EXTRA
			cXPERLOC := FPZ->FPZ_PERLOC
			cXAS     := FPZ->FPZ_AS
		EndIf

		If cXTIPFAT == "P"
			If cXEXTRA == "S" .or. SC6->C6_VALDESC > 0
				/*
				xFilial("FPG")
				SC6->C6_NUM
				SC6->C6_ITEM
				*/

				If Select("TRBFPG") > 0
					TRBFPG->(dbCloseArea())
				EndIf

				_cQuery := " SELECT ZC1.R_E_C_N_O_ ZC1RECNO"
				_cQuery += " FROM " + RetSqlName("FPG") + " ZC1"
				_cQuery += " WHERE ZC1.FPG_FILIAL = ? "
				_cQuery += " AND ZC1.FPG_PVNUM  = ? "
				_cQuery += " AND ZC1.FPG_PVITEM = ? "
				_cQuery += " AND ZC1.D_E_L_E_T_ = '' "
				_cQuery := changequery(_cQuery)
				aBindParam := {xFilial("FPG"), SC6->C6_NUM, SC6->C6_ITEM}
				MPSysOpenQuery(_cQuery,"TRBFPG",,,aBindParam)

				While TRBFPG->(!Eof())
					FPG->(dbGoTo(TRBFPG->ZC1RECNO))

					If empty(FPG->FPG_SEQ)
						_cSeq := GetSx8Num("FPG","FPG_SEQ")
						ConfirmSx8()
						If FPG->(RecLock("FPG",.F.))
							FPG->FPG_SEQ := _cSeq
							FPG->(MsUnlock())
						EndIF
					EndIf

					If RecLock("FPG",.f.)
						FPG->FPG_PVNUM  := ""
						FPG->FPG_PVITEM := ""
						FPG->FPG_STATUS := "1"	// Pendente
						FPG->(MsUnlock())
					EndIf

					TRBFPG->(dbSkip())
				EndDo

				TRBFPG->(dbCloseArea())
			Else
				If !Empty(cXAS)
					FPA->(dbSetOrder(3)) // FPA_FILIAL + FPA_AS + FPA_VIAGEM
					If FPA->(dbSeek( xFilial("FPA") + cXAS ))
						_dUltFat  := FPA->FPA_ULTFAT
						_dProxFat := FPA->FPA_DTFIM

						FP1->(dbSetOrder(1))				// FP1_FILIAL + FP1_PROJET + FP1_OBRA
						If FP1->(dbSeek( xFilial("FP1") + FPA->FPA_PROJET + FPA->FPA_OBRA ))
							If FP1->FP1_TPMES == "0"		// Mes Fechado
								_nDiasTrb := 30
								_dProxFat := MonthSub(_dProxFat,1)

								If FPA->FPA_DTINI > MonthSub(FPA->FPA_ULTFAT,1)
									_dUltFat := StoD("") 
								Else 
									_dUltFat := MonthSub(FPA->FPA_ULTFAT,1)
								EndIf
							Else
								If FP1->FP1_TPMES == "1"		// Dias Corridos
								_nDiasTrb := FPA->FPA_LOCDIA
								_dProxFat := _dProxFat - _nDiasTrb

								If FPA->FPA_DTINI > FPA->FPA_ULTFAT - _nDiasTrb
									_dUltFat := StoD("")
								Else
									_dUltFat := FPA->FPA_ULTFAT - _nDiasTrb
								EndIf

								If FPA->FPA_DTINI > _dUltFat
									_dUltFat := StoD("")
									EndIf
								Else  // Mes Fixo
									_dProxFat := FPZ->FPZ_DTFIM
									_dUltFat  := FPZ->FPZ_PRVFAT
								EndIf
							EndIf
						EndIf
					EndIf

					If RecLock("FPA",.f.)
						FPA->FPA_DTFIM  := _dProxFat
						FPA->FPA_ULTFAT := _dUltFat
						FPA->(MsUnlock())
					EndIf

					If FPA->(FIELDPOS("FPA_GERAEM")) > 0 .and. lMvLocBac
						If !empty(FPA->FPA_GERAEM)
							// Pesquisar na FPZ o pedido mais próximo antes do que esta sendo excluído
							// se não tiver zerar o campo FPA_GERAEM
							FP1->(dbSetOrder(1))
							FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA))
							dGeraem := FPA->FPA_GERAEM
							If FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2" // fechado, ou fixo
								dGeraem := MONTHSUB(FPA->FPA_GERAEM,1)
							else // dias corridos
								dGeraem := FPA->FPA_GERAEM - FPA->FPA_LOCDIA
							EndIF
							FPA->(Reclock("FPA",.F.))
							FPA->FPA_GERAEM := dGeraem
							FPA->(MsUnlock())
							FPZ->(RestArea(aTempFPZ))
							FPY->(RestArea(aTempFPY))
						EndIF
					EndIf

				EndIf
			EndIf
		elseif cXTIPFAT == "R" // é uma remessa
			if ChkFile("FQV") // Tenta abrir o arquivo
				// Verificar se veio da Gestão de Expedição
				_cQuery := " SELECT FQV.R_E_C_N_O_ FQVRECNO"
				_cQuery += " FROM " + RetSqlName("FQV") + " FQV"
				_cQuery += " WHERE FQV.FQV_FILIAL = '"+xFilial("FQV")+"' "
				_cQuery += " AND FQV.FQV_PEDIDO  = ? "
				_cQuery += " AND FQV.FQV_ITEMPV = ? "
				_cQuery += " AND FQV.D_E_L_E_T_ = ' ' "
				_cQuery := changequery(_cQuery)
				aBindParam := { SC6->C6_NUM, SC6->C6_ITEM}
				MPSysOpenQuery(_cQuery,"TRBFQV",,,aBindParam)

				if TRBFQV->(!Eof()) // Achou pedido e item no romaneio
					FQV->(dbGoto(TRBFQV->FQVRECNO))
					RecLock("FQV")
					FQV->FQV_PEDIDO := ''
					FQV->FQV_ITEMPV := ''
					FQV->FQV_STATUS := '6' // Separado
					msUnlock()

					FQU->(dbSetOrder(1))
					FQU->(dbSeek(xFilial("FQU")+FQV->FQV_NUM))
					RecLock("FQU", .F.)
					FQU->FQU_STATUS := "3" // Separado
					msUnlock()

					dbSelectArea("FQ5")
					dbSetOrder(9) // Por A.S.
					if FQ5->(dbSeek(xFilial("FQ5")+FQV->FQV_AS))
						RecLock("FQ5", .F.)
						FQ5->FQ5_STDEMA := "2"
						msUnlock()
					endif	
				endif
			endif

		endif

		TRBSC6->(dbSkip())
	EndDo

	//Atualiza a tabela de PV x Locação
	If lMvLocBac
		FPY->(DbSetOrder(1)) //
		If FPY->(DbSeek(xFilial("FPY") + SC5->C5_NUM))
			If RecLock("FPY",.f.)
				FPY->FPY_STATUS  := "2" // //1=Pedido Ativo;2=Pedido Cancelado
				FPY->(MsUnlock())
			EndIf
		EndIf
	EndIF

	If cXTIPFAT == "M" // Medição Estornar a medição

		// Procurar a nova medição
		if AliasInDic("FQK")
			dbSelectArea("FQK")
			dbSetOrder(5)
			if dbSeek(xFilial("FQK")+cFilant+SC5->C5_NUM) // Achei a nedição

				FQK->(RecLock("FQK",.F.))          
				FQK->FQK_FILPV  := ""
				FQK->FQK_NUMPV  := ""
				FQK->FQK_SITUAC :=  "1"
				FQK->(MsUnlock())

				FQL->(dbSetOrder(5))
				FQL->(dbSeek(xFilial("FQL")+FQK->(FQK_COD+FQK_MEDSEQ)))
				FQ5->(dbSetOrder(9))
				While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_COD+FQL_ORDEM) == xFilial("FQL")+FQK->(FQK_COD+FQK_MEDSEQ)
					FQ5->(dbSeek(xFilial("FQ5")+FQL->FQL_AS))
					FQ5->(RecLock("FQ5",.F.))
					FQ5->FQ5_ZLFTIP := ""
					FQ5->FQ5_NUMPV  := ""
					FQ5->(MsUnlock())
					FQL->(dbSkip())
				EndDo
			endif
		endif

	EndIf

	FPG->(RestArea( _aAreaZC1 ))
	FP1->(RestArea( _aAreaZA1 ))
	FPA->(RestArea( _aAreaZAG ))
	SC6->(RestArea( _aAreaSC6 ))
	SC5->(RestArea( _aAreaSC5 ))
	RestArea( _aAreaOld )

Return _lRet


