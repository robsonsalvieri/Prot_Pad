#Include "Totvs.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} LOCM005
ITUP Business - TOTVS RENTAL
Ponto de Entrada na Exclusão do Pedido de Vendas - GPO: Ajusta status na FPG e ZAG.
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
Local _aAreaFPG := FPG->(GetArea())
Local _aAreaFPY := FPY->(GetArea())
Local _aAreaFPZ := FPZ->(GetArea())

Local _lRet     := .t.
Local _cQuery   := ""
Local dProxFat  := StoD("")
Local dUltFat   := StoD("")
Local dIni      := Ctod("")
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local cXTIPFAT
Local cXEXTRA
Local cXPERLOC
Local cXAS
Local lLOCX243  := SuperGetMv("MV_LOCX243",.f.,.f.)
Local aTempFPZ  := {}
Local aTempFPY  := {}
Local dGeraem
Local aPeriodo  := {}
Local lPrimFat  := .F.
Local lAtuFQZ   := .F. // DSERLOCA-11242

	// Se o registro não foi excluído (usuário cancelou), não executar
	If !(SC5->(Deleted()))
		RestArea( _aAreaOld )
		Return _lRet
	EndIf

	dbSelectArea("FPG")
	dbSelectArea("FPA")
	dbSelectArea("FP1")
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))	// C6_FILIAL + C6_NUM + C6_PRODUTO

	// Frank 05/11/20 - limpar os registros da tabela FQZ

	If Select("TRBSC6") > 0
		TRBSC6->( DbCloseArea() )
	EndIf

	_cQuery := " SELECT SC6.R_E_C_N_O_ SC6RECNO"
	_cQuery += " FROM " + RetSqlName("SC6") + " SC6 "
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
			LOCA062(xFilial("SC5"),SC5->C5_NUM,SC6->C6_ITEM,,,FPZ->FPZ_AS,,.t.)
		EndIf

		cXTIPFAT := FPY->FPY_TIPFAT
		cXEXTRA  := FPZ->FPZ_EXTRA
		cXPERLOC := FPZ->FPZ_PERLOC
		cXAS     := FPZ->FPZ_AS


		If cXTIPFAT == "P"

			If cXEXTRA == "S" .or. SC6->C6_VALDESC > 0

				_cQuery := " SELECT FPG.R_E_C_N_O_ FPGRECNO"
				_cQuery += " FROM " + RetSqlName("FPG") + " FPG"
				_cQuery += " WHERE FPG.FPG_FILIAL = ? "
				_cQuery += " AND FPG.FPG_PVNUM  = ? "
				_cQuery += " AND FPG.FPG_PVITEM = ? "
				_cQuery += " AND FPG.D_E_L_E_T_ = '' "
				_cQuery := changequery(_cQuery)
				aBindParam := {xFilial("FPG"), SC6->C6_NUM, SC6->C6_ITEM}
				MPSysOpenQuery(_cQuery,"TRBFPG",,,aBindParam)

				While TRBFPG->(!Eof())
					FPG->(dbGoTo(TRBFPG->FPGRECNO))

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
			
			endif
//			Else
			If cXEXTRA != "S"
				If !Empty(cXAS)

					// Se não veio da FQZ continua se não limpa FQZ e salta
					if LOCM005a(cXAS, SC5->C5_NUM) 

						// Retornar as Datas na FPA

						FPA->(dbSetOrder(3)) // FPA_FILIAL + FPA_AS + FPA_VIAGEM
						If FPA->(dbSeek( xFilial("FPA") + cXAS ))

							FP1->(dbSetOrder(1))
							FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA))

							aPeriodo := Locm005B(cXAS, SC5->C5_NUM)

							// ISSUE: DSERLOCA-XXXX - 23/02/2026 - Correcao estorno 1o faturamento FPA
							// Identifica 1o faturamento: FPZ_DTINI igual ao inicio do contrato (FPA_DTINI)
							// indica que nao houve faturamento anterior para este AS
							lPrimFat := ( Len(aPeriodo) >= 2 ) .and. ( aPeriodo[1] == FPA->FPA_DTINI )

							If lPrimFat
								// 1o faturamento: FPZ_DTFIM ja e a data correta do periodo original
								// nao recalcular via MONTHSUM ou LOCDIA pois pode ser periodo parcial
								dUltFat  := StoD("")
								dProxFat := aPeriodo[2]
							Else
								// 2o faturamento em diante: logica existente de calculo por tipo de mes
								dIni    := aPeriodo[1] - 1
								dUltFat := aPeriodo[1] - 1

								IF FP1->FP1_TPMES == "0"				// MES FECHADO

									DPROXFAT := MONTHSUM(dIni,1)

									// somente se o dia for 30 e proximo mes 31
									// se for 29 de janeiro validar o maior dia de fevereiro
									// frank em 20/07/22 - ajuste do ultimo dia do mes fechado
									If day(dProxFat) == 30 .or. (month(dIni) == 1 .and. day(dIni) == 28)  .or. (month(dIni) == 2 .and. (day(dIni) == 28.or.day(dIni) == 29))
										nMes := month(dproxfat)
										while nMes == month(dproxfat)
											dProxFat ++
										EndDo
										dproxfat := dproxfat - 1
									EndIf

								ELSEIF FP1->FP1_TPMES == "1"				// MES ABERTO
									dProxFat := dIni + FPA->FPA_LOCDIA

								ELSE // mes fixo

									dProxFat := MONTHSUM(dIni,1)

									// somente se o dia for 30 e proximo mes 31
									// se for 29 de janeiro validar o maior dia de fevereiro
									// frank em 20/07/22 - ajuste do ultimo dia do mes fechado
									If day(dProxFat) == 30 .or. (month(dIni) == 1 .and. day(dini) == 28)  .or. (month(dini) == 2 .and. (day(dini) == 28.or.day(dIni) == 29))
										nMes := month(dProxFat)
										while nMes == month(dProxFat)
											dProxFat ++
										EndDo
										dProxFat := dProxFat - 1
									EndIf

								ENDIF
							EndIf

							If RecLock("FPA",.f.)
								FPA->FPA_DTFIM  := dProxFat
								FPA->FPA_ULTFAT := dUltFat

								// No 1o faturamento com mes fixo ou fechado, FPA_LOCDIA precisa ser
								// recalculado pois o periodo original pode ter sido parcial
								// FPA_DTFIM ja foi gravado acima com aPeriodo[2] (FPZ_DTFIM)
								// formula: (FPA_DTFIM - FPA_DTINI) + 1 = dias reais do 1o periodo
								If lPrimFat .and. ( FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2" )
									FPA->FPA_LOCDIA := ( FPA->FPA_DTFIM - FPA->FPA_DTINI ) + 1
								EndIf

								If FPA->(FIELDPOS("FPA_GERAEM")) > 0 .and. lMvLocBac
									If !empty(FPA->FPA_GERAEM)

										dGeraem := FPA->FPA_GERAEM
										If FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2" // fechado, ou fixo
											dGeraem := MONTHSUB(FPA->FPA_GERAEM,1)
										else // dias corridos
											dGeraem := FPA->FPA_GERAEM - FPA->FPA_LOCDIA
										EndIF
										FPA->FPA_GERAEM := dGeraem
									endif
								endif
								// ISSUE: DSERLOCA-11242 - 11/03/2026 - Atualiza FQZ apos restauracao das datas na FPA
								lAtuFQZ := .T.
								FPZ->(RestArea(aTempFPZ))
								FPY->(RestArea(aTempFPY))
							EndIF
							FPA->(MsUnlock())
							// DSERLOCA-11242
							If lAtuFQZ
								LOCM005c(cXAS, dUltFat, FP1->FP1_TPMES, FPA->FPA_LOCDIA, FPA->FPA_TPBASE)
								lAtuFQZ := .F.
							EndIf
								
						EndIf
					endif
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
					
					FH2->(dbSetOrder(1)) // Verificar se existem bens quantificaveis
					IF FH2->(dbSeek(xFilial("FH2")+FQV->FQV_AS))
						while !(FH2->(Eof())) .and. FH2->FH2_AS = FQV->FQV_AS .and. FH2->FH2_FILIAL = xFilial("FH2")
							RecLock("FH2", .F.)
							FH2->FH2_PEDIDO := " "
							FH2->FH2_ITEMPV := " "
							MsUnlock()
							FH2->(dbSkip())
						enddo
					endif
					
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
						// Buscar a Demanda para indicar o Faturamento gerado
                        FQT->(dbSetOrder(1))
                        FQT->(dbSeek(xFilial("FQT")+ FQ5->FQ5_DEMAND))
                        RecLock("FQT")
                        FQT->FQT_FATURA -= FQV->FQV_QTD
						FQT->FQT_PENDEN += FQV->FQV_QTD 
                        msUnlock()

					endif	
				endif
			endif

		endif

		TRBSC6->(dbSkip())
	EndDo

	//Atualiza a tabela de PV x Locação
/*
	If lMvLocBac
		FPY->(DbSetOrder(1)) //
		If FPY->(DbSeek(xFilial("FPY") + SC5->C5_NUM))
			If RecLock("FPY",.f.)
				FPY->FPY_STATUS  := "2" // //1=Pedido Ativo;2=Pedido Cancelado
				FPY->(MsUnlock())
			EndIf
		EndIf
	EndIF
*/
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

	//DSERLOCA-10440\DSERLOCA-9813 Alessandro Gois, 26/01/2026

	FPY->(dbSetOrder(1))
	if FPY->(dbSeek(SC5->C5_FILIAL+SC5->C5_NUM))
		FPZ->(dbSetOrder(1))
		if FPZ->(dbSeek(SC5->C5_FILIAL+SC5->C5_NUM+FPY->FPY_PROJET))
			While !FPZ->(Eof()) .and. FPZ->FPZ_FILIAL == SC5->C5_FILIAL .and. FPZ->FPZ_PEDVEN == SC5->C5_NUM .and. FPZ->FPZ_PROJET == FPY->FPY_PROJET
				FPZ->(RecLock("FPZ",.F.))
				FPZ->(dbDelete())
				FPZ->(MsUnlock())
				FPZ->(dbSkip())
			EndDo

			FPY->(RecLock("FPY",.F.))
			FPY->(dbDelete())
			FPY->(MsUnlock())
		endif
	endif
	//DSERLOCA-10440\DSERLOCA-9813 fim, Alessandro Gois, 26/01/2026


	FPG->(RestArea( _aAreaFPG )) 
	FP1->(RestArea( _aAreaZA1 ))
	FPA->(RestArea( _aAreaZAG ))
	SC6->(RestArea( _aAreaSC6 ))
	SC5->(RestArea( _aAreaSC5 ))
	FPY->(RestArea( _aAreaFPY ))
	FPZ->(RestArea( _aAreaFPZ ))

	RestArea( _aAreaOld )

Return _lRet



/*/{Protheus.doc} LOCM005a
ITUP Business - TOTVS RENTAL
Pesquisar a cXAS e procurar na fqz. se o pedido que esta na fqz é o mesmo 
que está posicionado no programa (c5_num). Se tiver nao pode fazer esse trecho
@type Function
@author Alessandro Gois
@since 12/12/2025
@version P12
@history 12/12/2025, Alessandro Gois, Fonte produtizado.
/*/
Function LOCM005a(cXAS, cPedido)
Local lRet := .t.
Local cQuery 
Local aBindParam
Local lLOCA005z := EXISTBLOCK("LOCM005z")
Local lFORCA := .F. 

	IF lLOCA005z
		lFORCA := EXECBLOCK("LOCM005z",.f.,.f.,{})
	ENDIF
	cXAS := alltrim(cXAS)
	if empty(cXAS) .or. lforca
		cXAS := ' '
	endif

	LOCACLOSE("TRBFQZ")

	cQuery := " SELECT FQZ.R_E_C_N_O_ FQZRECNO" 
	cQuery += " FROM " + RetSqlName("FQZ") + " FQZ " 
	cQuery += " WHERE  FQZ_FILIAL  = '" + XFILIAL("FQZ") + "' " 
	cQuery += " AND FQZ_AS = ? "
	cQuery += " AND FQZ_PV = ?"
	cQuery += " AND FQZ.D_E_L_E_T_ = ' ' " 
	cQuery := changequery(cQuery)

	aBindParam := {cXAS, cPedido}
	MPSysOpenQuery(cQuery,"TRBFQZ",,,aBindParam)
	TRBFQZ->(dbGoTop())

	if !TRBFQZ->(Eof())

		//DSERLOCA-9898 Alessandro Gois, 20/01/2026
		FQZ->(dbGoTo(TRBFQZ->FQZRECNO))
		reclock("FQZ",.f.)
			FQZ->FQZ_PV := "" 
		FQZ->(MSUNLOCK())
		//DSERLOCA-9898 fim Alessandro Gois, 20/01/2026
	
		lRet := .f.
	endif

	TRBFQZ->( DbCloseArea() )


return lRet

/*/{Protheus.doc} Locm005b
Retorno as datad de Inicio e Fim da FPY do penultimo pedido de feturamento na FPY
@type function
@version 25.10
@author Alexandre Circenis
@since 11/02/2026
@param cAS, character, Codigo da A.S>
@param cPedido, character, pNumero do pedido a ser ignorado
@return variant, Array com data de Inicio e Data Fim
/*/
Function Locm005b(cAS, cPedido)
Local aRet := {}
Local cQuery := ""
Local aArea := GetArea()
Local aParam := {}

cQuery += "SELECT FPZ_DTINI, FPZ_DTFIM"
cQuery += " FROM "+RetSqlName("FPZ")+ " FPZ"
cQuery += " INNER JOIN  "+RetSqlName("FPY")+ " FPY"
cQuery += "  ON FPY_FILIAL = '"+xFilial("FPY")+"'"
cQuery += "  AND FPY_PEDVEN = FPZ_PEDVEN"
cQuery += "  AND FPY_TIPFAT = 'P'" // Só faturamento automatico
cQuery += "  AND FPY_STATUS = '1'" // Ativo
cQuery += "  AND FPY.D_E_L_E_T_ = ' '"
cQuery += " WHERE FPZ_FILIAL = '"+xFilial("FPZ")+"'"
cQuery += " AND FPZ_AS = ?"
Aadd(aParam, cAS)
cQuery += " AND FPZ_PEDVEN = ?"
Aadd(aParam, cPedido )
cQuery += " AND FPZ_EXTRA = 'N'" // Não pode ser Custo Extra
cQuery += " AND FPZ.D_E_L_E_T_ = ' '"
cQuery += " AND NOT EXISTS ( SELECT FQZ_AS 
cQuery += "   FROM "+RetSqlName("FQZ")+ " FQZ"
cQuery += "   WHERE FQZ_FILIAL = '"+xFilial("FQZ")+"'"
cQuery += "   AND FQZ_PV = FPZ_PEDVEN"
cQuery += "   AND FQZ_AS = FPZ_AS"
cQuery += "   AND FQZ_MSBLQL = '2' "
cQuery += "   AND FQZ.D_E_L_E_T_ = ' ' )"
cQuery += " ORDER BY FPZ_DTINI DESC"

cQuery := Changequery(cQuery)
MPSysOpenQuery(cQuery,"TRBFPZ",,,aParam)
TRBFPZ->(dbGoTop())

if !TRBFPZ->(EOF())
	aRet := {Stod(TRBFPZ->FPZ_DTINI), Stod(TRBFPZ->FPZ_DTFIM)}
endif

RestArea(aArea)

Return aRet

/*/{Protheus.doc} LOCM005c
ITUP Business - TOTVS RENTAL
Atualiza FQZ_ULTFAT, FQZ_PERPRO e FQZ_VLRPRO apos restauracao de datas na FPA
por estorno de exclusao do PV. Aplica a mesma logica de calculo do ITLOGFQZ (LOCM008).
@type Function
@author Lui Pazini
@since 11/03/2026
@param cAS, character, Codigo da A.S.
@param dUltFat, date, Nova data FPA_ULTFAT (restaurada)
@param cTpMes, character, Tipo de mes do contrato (FP1_TPMES)
@param nLocDia, numeric, Dias de locacao (FPA_LOCDIA)
@param cTpBase, character, Tipo de base de calculo (FPA_TPBASE)
@history 11/03/2026, Frank Zwarg Fuga, DSERLOCA-11242 - Fonte produtizado.
/*/
Function LOCM005c(cAS, dUltFat, cTpMes, nLocDia, cTpBase)
Local cQuery  := ""
Local aParam  := {}
Local nNDias  := 30

	LOCACLOSE("TRBFQZC")

	cAS    := alltrim(cAS) // pre-trim antes do bind param - DSERLOCA-11242

	cQuery := " SELECT FQZ.R_E_C_N_O_ FQZRECNO"
	cQuery += " FROM " + RetSqlName("FQZ") + " FQZ"
	cQuery += " WHERE FQZ_FILIAL = '" + xFilial("FQZ") + "'"
	cQuery += " AND FQZ_AS = ?"
	cQuery += " AND FQZ_PV = ' '"
	cQuery += " AND FQZ_MSBLQL = '2'"
	cQuery += " AND FQZ.D_E_L_E_T_ = ' '"
	cQuery := changequery(cQuery)

	aParam := {cAS}
	MPSysOpenQuery(cQuery, "TRBFQZC", ,, aParam)
	TRBFQZC->(dbGoTop())

	If !TRBFQZC->(Eof())
		FQZ->(dbGoTo(TRBFQZC->FQZRECNO))

		If FQZ->(RecLock("FQZ", .F.))
			FQZ->FQZ_ULTFAT := dUltFat

			// Recalculo de FQZ_PERPRO (mesma logica de LOCM008/ITLOGFQZ)
			If !empty(FQZ->FQZ_ULTFAT)
				FQZ->FQZ_PERPRO := (FQZ->FQZ_RETIRA - FQZ->FQZ_ULTFAT)
			Else
				FQZ->FQZ_PERPRO := (FQZ->FQZ_RETIRA - FQZ->FQZ_DTINI) + 1
			EndIf

			// Recalculo de FQZ_VLRPRO (mesma logica de LOCM008/ITLOGFQZ)
			If cTpMes <> "0" .and. cTpMes <> "2" // mes aberto / corrido
				FQZ->FQZ_VLRPRO := (FQZ->FQZ_VLRTOT * FQZ->FQZ_PERPRO) / If(nLocDia == 0, 1, nLocDia)
			Else // mes fechado ou fixo
				nNDias := 30
				Do Case
					Case cTpBase == "M"
						nNDias := 30
					Case cTpBase == "Q"
						nNDias := 15
					Case cTpBase == "S"
						nNDias := 7
					Otherwise
						nNDias := If(nLocDia > 0, nLocDia, 30)
				EndCase
				FQZ->FQZ_VLRPRO := (FQZ->FQZ_VLRTOT * FQZ->FQZ_PERPRO) / nNDias
			EndIf

			FQZ->(MsUnlock())
		EndIf

		TRBFQZC->(dbSkip())
	EndIf

	TRBFQZC->(dbCloseArea())

Return .T.
