#Include "Ap5Mail.ch"
#Include "TopConn.ch"                                                                                                 
#Include "TbiConn.ch"
#Include "totvs.ch"
#Include "locm003.ch"

/*/{Protheus.doc} LOCM003.PRW
ITUP Business - TOTVS RENTAL
@type Function
@author Frank Zwarg Fuga
@since 03/12/2020
@version P12
@history 03/12/2020, Frank Zwarg Fuga, Fonte produtizado.
Antes era o ponto de entrada: SF2460I.PRW
Ao final da grava็ใo da nota fiscal de saํa
/*/ 

Function LOCM003()
Local _aArea    := GetArea()
Local aAreaST9  := ST9->(GetArea())
Local aAreaZAG  := FPA->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local aZAG		:= {}
Local cChaveSC6 := SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE
//Local cTesLF 	:= AllTrim( SuperGetMV("MV_LOCX083",.F.,"") )		// TES usada para faturamento de remessa  SuperGetMV("MV_LOCX083",.F.,"")
//Local cTesA		:= SuperGetMv("MV_LOCX220",.F.,"521")
Local _cRegSC6  := SC6->(Recno())
Local _cRegSC5  := SC5->(Recno())
Local cStatST9	:= "" 
Local cPvAs		:= ""
Local _lLogFat  := .T.
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra็ใo com M๓dulo de Loca็๕es SIGALOC
Local nW        := 0
Local _nX
Local lLOCX243  := SuperGetMv("MV_LOCX243",.F.,.F.)
Local lRemessa  := .F. // DSERLOCA-1955 - Frank em 19/02/2024

	For _nX := 1 to 20
		If Upper(Alltrim(ProcName(_nX))) $ "LOCA021#LOCA048#LOCA010#LOCA04804LOCA229I"
			_lLogFat := .F.
			Exit
		EndIf
	Next
/*  Parโmetro MV_LOCX243 foi descontinuado // Rossana - DSERLOCA 6832 - 28/05/25 
	dbSelectArea("SC6")
	SC6->(dbSetOrder(4))
	If SC6->(dbSeek(xFilial("SC6") + SF2->F2_DOC + SF2->F2_SERIE))
		While SC6->(!eof()) .and.;
			xFilial("SC6") + SF2->F2_DOC + SF2->F2_SERIE == SC6->C6_FILIAL + SC6->C6_NOTA + SC6->C6_SERIE
			If lLOCX243 .and. _lLogFat
				LOCA04804(SC6->C6_FILIAL,SC6->C6_NUM,SC6->C6_ITEM)
			EndIf
			SC6->(dbSkip())
		EndDo
	EndIf
*/
	// Frank Zwarg Fuga - 18/12/2020
	// Gravacao de dados adicionais sobre a nota fiscal de saida
	GRVNFIT2()

	SC5->(dbgoto(_cRegSC5))
	SC6->(dbgoto(_cRegSC6))

	// --> Alimenta a ZAG com o numero da nota de remessa
	DBCOMMIT()
	if BuscaZAG() 
		TZP5->(dbGoTop())
		While TZP5->( !Eof() )
			// DSERLOCA-1955 - Frank em 19/02/2024
			If lMvLocBac
				If TZP5->FPY_TIPFAT == "R"
					lRemessa := .T.
				Else
					lRemessa := .F.
				EndIF
			Else
				If TZP5->C5_XTIPFAT == "R"
					lRemessa := .T.
				Else
					lRemessa := .F.
				EndIF
			EndIF
			If lRemessa //(AllTrim(TZP5->C6_TES) $ AllTrim(cTesLF)) .Or. (AllTrim(TZP5->C6_TES) $ AllTrim(cTesA))
				aAdd(aZAG, {TZP5->ZAGRECNO,TZP5->D2_FILIAL,TZP5->D2_DOC,STOD(TZP5->D2_EMISSAO),TZP5->D2_SERIE, TZP5->D2_ITEM,TZP5->D2_PEDIDO, TZP5->D2_ITEM} )
			EndIf
		TZP5->(dbSkip()) 
		EndDo
	Else
		SC6->( dbSetOrder(4))
		If	SC6->(dbSeek( cChaveSC6 ))
			While AllTrim(SC6->(C6_FILIAL + C6_NOTA + C6_SERIE)) == AllTrim(cChaveSC6)
				cPvAs	:= ""
				If lMvLocBac
					FPZ->(dbSetOrder(3))
					FPZ->(DbSeek(SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM))
					If FPZ->FPZ_FILIAL + FPZ->FPZ_PEDVEN + FPZ->FPZ_ITEM == SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM
						cPvAs	:= FPZ->FPZ_AS 
						FPY->(dbSetOrder(1))
						If FPY->(dbSeek(xFilial("FPY")+SC6->C6_NUM))
							If FPY->FPY_STATUS == "1 " .and. FPY->FPY_TIPFAT == "R"
								lRemessa := .T.
							Else
								lRemessa := .F.
							EndIF
						EndIF
					EndIf
				Else
					cPvAs	:= SC6->C6_XAS
					If SC5->C5_XTIPFAT == "R"
						lRemessa := .T.
					Else
						lRemessa := .F.
					EndIF
				EndIf
				If lRemessa .And. !Empty(cPvAs) .And. BuscaAS(cPvAs) //((AllTrim(SC6->C6_TES) $ AllTrim(cTesLF)) .Or. (AllTrim(SC6->C6_TES) $ AllTrim(cTesA))) .And. BuscaAS(cPvAs) // Busca AS para casos da filial do centro de trabalho que podem ser diferentes da filial no qual o contrato estแ alocado
					FPA->( dbSetOrder(3) )
					If FPA->( dbSeek( ZAGAS->FPA_FILIAL + cPvAs) )
						aAdd(aZAG, {FPA->( Recno() ),SC6->C6_FILIAL,SC6->C6_NOTA,SC6->C6_DATFAT,SC6->C6_SERIE,SC6->C6_ITEM,SC6->C6_NUM} )	
					EndIf 
				EndIf 
				SC6->(dbSkip()) 
			EndDo 
		EndIf 
	EndIf 

	If Len(aZAG) > 0
		For nW := 1 To len(aZAG)
			FPA->(DbGoTo( aZAG[nW][1] ))
			If RecLock("FPA", .F.)
				FPA->FPA_FILREM	:= aZAG[nW][2]
				FPA->FPA_NFREM	:= aZAG[nW][3]
				FPA->FPA_DNFREM := aZAG[nW][4]
				FPA->FPA_SERREM	:= aZAG[nW][5]
				FPA->FPA_ITEREM	:= aZAG[nW][6]
				FPA->FPA_PEDIDO := aZAG[nW][7]
				FPA->(MsUnLock())
			EndIf
			
			If ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
				If !Empty(ST9->T9_STATUS)
					If !lMvLocBac
						If TQY->(dbSeek(xFilial("TQY")+ST9->T9_STATUS))
							TQY->(dbGoTop())
							While TQY->(!Eof()) .And. ! TQY->TQY_STTCTR == "20" // Status de gerar contrato
								TQY->(dbSkip())
							EndDo
							If TQY->TQY_STTCTR == "20"
								cStatST9 := ST9->T9_STATUS
								If RecLock("ST9",.F.)
									ST9->T9_STATUS := TQY->TQY_STATUS 
									ST9->(MsUnLock())
								EndIf
								LOCXITU21(cStatST9,TQY->TQY_STATUS,FPA->FPA_PROJET,FPA->FPA_NFREM,FPA->FPA_SERREM)
							Else
								MsgAlert(STR0001+CRLF+STR0002,STR0003) // "STATUS BEM: Nใo foi encontrado o 'Status de NF Remessa' 20 no cadastro de 'Status do Bem'!"###"Favor realizar o cadastro do mesmo para prosseguir."###"LOCM003.PRW"
							EndIf
						EndIf
					else
						FQD->(dbSetOrder(2)) 
						If FQD->(dbSeek(xFilial("FQD")+ST9->T9_STATUS))
							FQD->(dbGoTop())
							While FQD->(!Eof()) .And. ! FQD->FQD_STAREN == "20" // Status de gerar contrato
								FQD->(dbSkip())
							EndDo
							If FQD->FQD_STAREN == "20"
								cStatST9 := ST9->T9_STATUS
								If RecLock("ST9",.F.)
									ST9->T9_STATUS := FQD->FQD_STATQY
									ST9->(MsUnLock())
								EndIf
								LOCXITU21(cStatST9,FQD->FQD_STATQY,FPA->FPA_PROJET,FPA->FPA_NFREM,FPA->FPA_SERREM)
							Else
								MsgAlert(STR0001+CRLF+STR0002,STR0003) // "STATUS BEM: Nใo foi encontrado o 'Status de NF Remessa' 20 no cadastro de 'Status do Bem'!"###"Favor realizar o cadastro do mesmo para prosseguir."###"LOCM003.PRW"
							EndIf
						EndIf
					EndIf
				EndIF
			EndIF
		Next nW
	EndIf

	If Select("TZP5") > 0
		TZP5->( DbCloseArea() )
	EndIf                                            

	RestArea( _aArea )
	RestArea( aAreaST9 )
	RestArea( aAreaZAG )
	RestArea( aAreaSC6 )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ BuscaZAG  บ Autor ณ IT UP Business     บ Data ณ 20/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDescricao ณ Localiza as linhas da ZAG de acordo com a nota faturada.   ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function BuscaZAG()
Local lRet := .F.
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra็ใo com M๓dulo de Loca็๕es SIGALOC
Local _cQry
Local aBindParam

	_cQry := " SELECT "
	_cQry += " F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_HORA, "
	_cQry += " D2_PEDIDO, D2_FILIAL, D2_DOC, D2_EMISSAO, D2_SERIE, D2_ITEM, D2_PEDIDO, "
	_cQry += " FPA_GRUA, FPA_TPBASE, FPA_PREDIA, ZAG.R_E_C_N_O_ ZAGRECNO, C6_TES, "
	_cQry += " C6_ITEM "
	If lMvLocBac
		_cQry += " ,FPZ_AS C6_XAS, FPY_TIPFAT "
	Else
		_cQry += " , C6_XAS, C5_XTIPFAT "
	EndIf
	_cQry += " FROM " + RetSqlName("SD2") + " SD2 "
	_cQry += " INNER JOIN " + RetSqlName("SF2") + " SF2 "
	_cQry += " ON  SD2.D2_FILIAL	= SF2.F2_FILIAL "
	_cQry += " AND SD2.D2_DOC		= SF2.F2_DOC "
	_cQry += " AND SD2.D2_SERIE		= SF2.F2_SERIE "
	_cQry += " AND SD2.D2_CLIENTE	= SF2.F2_CLIENTE "
	_cQry += " AND SD2.D2_LOJA		= SF2.F2_LOJA "
	_cQry += " AND SD2.D_E_L_E_T_ = '' "
	_cQry += " INNER JOIN " + RetSqlName("SC5") + " SC5 "
	_cQry += " ON  SC5.C5_FILIAL	= SD2.D2_FILIAL "
	_cQry += " AND SC5.C5_NUM		= SD2.D2_PEDIDO "
	_cQry += " AND SC5.D_E_L_E_T_ = '' "
	_cQry += " INNER JOIN " + RetSqlName("SC6") + " SC6 "
	_cQry += " ON  SC6.C6_FILIAL	= SD2.D2_FILIAL "
	_cQry += " AND SC6.C6_NUM		= SD2.D2_PEDIDO "
	_cQry += " AND SC6.C6_ITEM		= SD2.D2_ITEMPV "
	_cQry += " AND SC6.D_E_L_E_T_ = '' "
	If lMvLocBac
		_cQry += " INNER JOIN " + RetSqlName("FPZ") + " FPZ "
		_cQry += " ON  FPZ.FPZ_FILIAL = SC6.C6_FILIAL "
		_cQry += " AND FPZ_AS <> '' "
		_cQry += " AND FPZ.D_E_L_E_T_ = '' "
		_cQry += " AND FPZ_ITEM = SC6.C6_ITEM AND FPZ_PEDVEN = SC6.C6_NUM "
	EndIf
	_cQry += " INNER JOIN " + RetSqlName("FPA") + " ZAG "
	_cQry += " ON ZAG.FPA_FILIAL = SC6.C6_FILIAL "
	If lMvLocBac
		_cQry += " AND ZAG.FPA_AS = FPZ_AS "
	Else
		_cQry += " AND ZAG.FPA_AS = SC6.C6_XAS "
	EndIf
	_cQry += " AND ZAG.FPA_AS <> '' "
	_cQry += " AND ZAG.D_E_L_E_T_ = '' "

	_cQry += "INNER JOIN " + RetSqlName("FPY") + " FPY ON "
	_cQry += "FPY.FPY_FILIAL = SC5.C5_FILIAL AND FPY.D_E_L_E_T_ = ' ' AND FPY_STATUS <> '2' AND FPY_PEDVEN = SC5.C5_NUM "

	_cQry += " WHERE SF2.D_E_L_E_T_ = '' "
	_cQry += " AND F2_FILIAL	= ? "
	_cQry += " AND F2_DOC		= ? "
	_cQry += " AND F2_SERIE		= ? "
	_cQry += " AND D2_CLIENTE	= ? "
	_cQry += " AND D2_LOJA		= ? "

	_cQry := changequery(_cQry) 
	If Select("TZP5") > 0
		TZP5->( DbCloseArea() )
	EndIf   
	aBindParam := {SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA}
	MPSysOpenQuery(_cQry,"TZP5",,,aBindParam)
	TZP5->(dbGoTop())
	iiF (TZP5->(EOF()), lRet, lRet:= .T. )
Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ BuscaAS   บ Autor ณ IT UP Business     บ Data ณ 20/10/2016 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑณDescricao ณ Localiza as linhas da ZAG por AS caso a query nใo encontre ณฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function BuscaAS(cAS)
Local lRet := .F.
Local cQry
Local aBindParam

//	cQry := " SELECT FPA_FILIAL, *		 " 
	cQry := " SELECT *		 " 
	cQry += " FROM "+RetSQLName("FPA")+" " 
	cQry += " WHERE  D_E_L_E_T_ =''		 " 
	cQry +=   " AND  FPA_AS = ?	 " 
	cQry +=   " AND  FPA_AS <> ''        " 
	cQry := changequery(cQry) 
	If Select("ZAGAS") > 0
		ZAGAS->(dbCloseArea()) 
	EndIf   
	aBindParam := {cAS}
	MPSysOpenQuery(cQry,"ZAGAS",,,aBindParam)
	ZAGAS->(dbGoTop())
	Iif (ZAGAS->(Eof()) , lRet , lRet := .T. ) 
Return lRet


// Gravacao dos dados adicionais da nota fiscal de saida
// Frank Z Fuga - 23/12/2020
Static Function GRVNFIT2()

Local lMvLocBac		:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra็ใo com M๓dulo de Loca็๕es SIGALOC
Local _cDestin 		:= SuperGetMv("MV_LOCX059",.F.,"")
Local cPvProjet		:= ""
Local cPvAs			:= ""
Local cFpyRoma  	:= ""
Local _aArea        := GetArea()
Local aAreaSD2      := SD2->(GetArea())
Local _cNotax
Local _cSeriex

	SD2->(dbSetOrder(3))
	SD2->(dbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO))

	If lMvLocBac
		FPY->(dbSetOrder(1))
		FPY->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO))
		cPvProjet	:= FPY->FPY_PROJET
	Else
		cPvProjet	:= SC5->C5_XPROJET
	EndIf

  	IF !Empty( FPY->FPY_NFDEVO)  // Veio da antiga Remessa 
		// FQ2 serแ posicionada pelo romaneio grado na FPY
		FQ2->(dbSetOrder(1))
		if FQ2->(dbSeek(xFilial("FQ2") + FPY->FPY_NFDEVO))
			// Inclusใo da verfica็ใo se vem de rotina Localizada MATA462AN

				If SF2->(FieldPos("F2_IT_ROMA")) > 0
					If RecLock("SF2",.F.)
						SF2->F2_IT_ROMA := FQ2->FQ2_NUM	// Recebe Numero do romaneio.
						SF2->(MsUnLock())
					EndIf
				EndIf

				FQ2->(RecLock("FQ2",.F.))
				FQ2->FQ2_NFSER := alltrim(SF2->F2_DOC) +"\"+ SF2->F2_SERIE
				FQ2->(MsUnlock())

				_cNotax  := SF2->F2_DOC
				_cSeriex := SF2->F2_SERIE
				SC6->(dbSetOrder(4))
				SC6->(dbSeek(xFilial("SC6")+_cNotax+_cSeriex))
				While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->(C6_NOTA+C6_SERIE) == _cNotax+_cSeriex
					SD2->(dbSetOrder(8))
					SD2->(dbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))

					If lMvLocBac
						FPY->(dbSetOrder(1))
						FPY->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO))
						FPZ->(dbSetOrder(1))
						FPZ->(dbSeek(xFilial("SC5") + FPY->FPY_PEDVEN + FPY->FPY_PROJET + SC6->C6_ITEM))
						cFpyRoma:= FPY->FPY_NFDEVO   //FPY->FPY_IT_ROM Frank em 26/07/23
						cPvAs	:= FPZ->FPZ_AS
					EndIf
					If !empty(cPvAs)
						FQ3->(dbSetOrder(3))
						If FQ3->(dbSeek(xFilial("FQ3")+cPvAs))
							If empty(FQ3->FQ3_NFREM) .and. FQ3->FQ3_NUM = cFpyRoma
								FQ3->(RecLock("FQ3",.F.))
								FQ3->FQ3_NFREM	:= _cNotax
								FQ3->FQ3_SERREM	:= _cSeriex
								FQ3->(MsUnlock())
							EndIf
						EndIf
					EndIf
					SC6->(dbSkip())
				EndDo
			
		endif	
	elseif FPY->(FieldPos("FPY_ROMAN")) >0 .and. !Empty( FPY->FPY_ROMAN) // Veio da Nova Gestใo de Demanda
		FQU->(dbSetOrder(1))
  		IF FQU->(dbSeek(xFilial("FQU") + FPY->FPY_ROMAN))
    		// Inclusใo da verfica็ใo se vem de rotina Localizada MATA462AN

				_cNotax  := SF2->F2_DOC
				_cSeriex := SF2->F2_SERIE
				SC6->(dbSetOrder(4))
				SC6->(dbSeek(xFilial("SC6")+_cNotax+_cSeriex))
				While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->(C6_NOTA+C6_SERIE) == _cNotax+_cSeriex
					SD2->(dbSetOrder(8))
					SD2->(dbSeek(xFilial("SD2")+SC6->C6_NUM+SC6->C6_ITEM))

					FPY->(dbSetOrder(1))
					FPY->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO))
					FPZ->(dbSetOrder(1))
					FPZ->(dbSeek(xFilial("SC5") + FPY->FPY_PEDVEN + FPY->FPY_PROJET + SC6->C6_ITEM))
					cFpyRoma:= FPY->FPY_NFDEVO   //FPY->FPY_IT_ROM Frank em 26/07/23
					cPvAs	:= FPZ->FPZ_AS

					If !empty(cPvAs)
						FQV->(dbSetOrder(2))
						FQV->(dbSeek(xFilial("FQV")+cPvAs))
						FQV->(RecLock("FQV",.F.))
						FQV->FQV_NFREM	:= _cNotax
						FQV->FQV_SERREM	:= _cSeriex
						FQV->FQV_ITEMNF := SD2->D2_ITEM
						FQV->(MsUnlock())
					EndIf
					SC6->(dbSkip())
				EndDo
			
		endif
	endif

	If !SuperGetMV("MV_GERNFS",,.F.)
		If ! Empty( _cDestin )
			LOCXITU23( "", "", _cNotax, _cSeriex)
		EndIf
	EndIf
	RestArea(aAreaSD2)
	RestArea(_aArea)
Return .t.
