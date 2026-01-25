#include 'protheus.ch'

Function TAFGRSABCE(aWizard, aFilial, cDatIni, cDatFim, cCabecalho)

Local oError	as object
Local cTxtSys  	as char
Local nHandle   as numeric
Local cREG 		as char
Local lFound    as logical
Local cStrTxt   as char
Local cIniAnt   as char
Local cFimAnt   as char
Local dIni      as date
Local dFim      as date

Local aApurST   := {}
Local nCreImp   := 0
Local nCredEnt  := 0
Local nCredTran := 0
Local nCredPres := 0
Local nCredComp := 0
Local nCredOutr := 0
Local nDebImp   := 0
Local nDebResp  := 0
Local nDebComp  := 0
Local nDebSaid  := 0
Local nDebTran  := 0
Local nDebOutr  := 0
Local nSldCrAnt  := 0
Local nCreNaoCom := 0
Local nSldCredTr := 0
Local nSldLim    := 0
Local nPgtoMesRef := 0
Local nPgtoVenc   := 0
Local nVlFolha    := 0
Local nVlFatur    := 0
Local nNumEmpr    := 0
Local nEntVlCtb   := 0
Local nSaiVlCtb   := 0
Local nIniPrpTrib := 0
Local nIniPrpIsen := 0
Local nIniEmTerc  := 0
Local nIniDeTerc  := 0
Local nFimPrpTrib := 0
Local nFimPrpIsen := 0
Local nFimEmTerc  := 0
Local nFimDeTerc  := 0
Local nFundoAmp   := 0
Local nTotRec     := 0
Local nLinha      := 0
Local nTotDebSt   := 0
Local nTotCreSt   := 0
Local nRecSt      := 0

Begin Sequence
	dIni := CTOD("01/"+ SubStr(aWizard[1,3],1,2) + "/" + cValToChar(aWizard[1,4]))
	dFim := LastDay(dIni)

	cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	nHandle   	:= MsFCreate( cTxtSys )
	cREG		:= "ABCE"
	lFound      := .T.

	cCabecalho := "****"										//FIXO
	cCabecalho += "08"											//Versão
	cCabecalho += Replicate("0",8) 						        //Data de Entrega
	cCabecalho += IIF(aWizard[1][5] == "0 - Não", "N", "S")     //Retificadora
	cCabecalho += SubStr(cDatIni,7,2)							//Dia Início
	cCabecalho += SubStr(cDatFim,7,2)							//Dia término
	cCabecalho += SubStr(cDatIni,5,2) + SubStr(cDatIni,1,4)		//Referencia - Mês/Ano
	cCabecalho += PADL(Alltrim(aFil[1,5]),10,"0") 				//Inscrição Estadual
	cCabecalho += "0001"
	cCabecalho += "ABCE"

	nCreImp   := CrDebImpor(cDatIni, cDatFim, "C")
	nCredEnt  := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoI_Creditos"   }) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoI_Creditos"   })][2], 0)
	nCredTran := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoII_Transf"    }) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoII_Transf"    })][2], 0)
	nCredPres := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoIII_Presum"   }) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoIII_Presum"   })][2], 0)
	nCredComp := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoIV_Compens"   }) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoIV_Compens"   })][2], 0)
	nCredOutr := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoXIV_OutrosCre"}) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoXIV_OutrosCre"})][2], 0)

	nDebImp  := CrDebImpor(cDatIni, cDatFim, "D")
	nDebResp := ajusDoc(cDatIni, cDatFim, "E", "00211", aFilial[7])
	nDebComp := ajusDoc(cDatIni, cDatFim, "E", "00212", aFilial[7])
	nDebSaid := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoV_Debitos"   }) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoV_Debitos"   })][2], 0)
	nDebTran := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVI_DebTransf"}) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVI_DebTransf"})][2], 0)
	nDebOutr := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoXV_OutrosDeb"}) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoXV_OutrosDeb"})][2], 0)

	aApurST := apurICMST(cDatIni, cDatFim)

	DbSelectArea("C2S")
	C2S->(DbSetOrder(1))
	If C2S->(DbSeek(xFilial("C2S") + '0' + cDatIni + cDatFim + " "))
		nSldCrAnt := C2S->C2S_CREANT + C2S->C2S_CRNANT
		nCreNaoCom := C2S->C2S_CRNTRA
		nTotRec   := C2S->C2S_TOTREC
		nSldCredTr := C2S->C2S_CRESEG

		If len(aApurST) > 0
			nSldCrAnt += aApurST[1,1] //Saldo credor anterior ST
		EndIf
	EndIf

	IF ((aWizard[1][12]) == "1 - Sim")
		cIniAnt := Dtos(TAFSubMes(dIni,1))
		cFimAnt := Dtos(TAFSubMes(dFim,1))

		DbSelectArea("C2S")
		C2S->(DbSetOrder(1))
		If C2S->(DbSeek(xFilial("C2S") + '0' + cIniAnt + cFimAnt + " "))
			nSldLim := C2S->C2S_TOTREC
		EndIf
	EndIf

	nPgtoMesRef := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVIII_PgtoMesRef"}) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVIII_PgtoMesRef"})][2], 0)
	nPgtoVenc   := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoIX_PgtoVenc"}) > 0,     aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoIX_PgtoVenc"})][2], 0)

	/*
    /*--- Início Cálculo da Ref. 22 ---
    nICMSST := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVII_TotDeb"}) > 0,     aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVII_TotDeb"})][2], 0)
	nICMSST -= IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVII_TotCred"}) > 0,     aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVII_TotCred"})][2], 0)
	nICMSST -= IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoIX_PgtoVenc_ST"}) > 0,     aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoIX_PgtoVenc_ST"})][2], 0)
	nICMSST -= IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVIII_PgtoMesRef_ST"}) > 0,     aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVIII_PgtoMesRef_ST"})][2], 0)

	IIF(nICMSST < 0, nICMSST := 0, nICMSST := nICMSST)
	//--- Fim Cálculo da Ref. 22 ---


	//--- Início Cálculo da Ref. 23 ---
    nICMS := (nDebResp + nDebComp + nDebImp + nDebSaid + nDebTran + nDebOutr)
	nICMS -= (nCreImp + nCredEnt + nCredTran + nCredPres + nCredComp + nCredOutr)
	nICMS -= IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVIII_PgtoMesRef_ICMS"}) > 0,     aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVIII_PgtoMesRef_ICMS"})][2], 0)
	nICMS -= IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoIX_PgtoVenc_ICMS"}) > 0,     aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoIX_PgtoVenc_ICMS"})][2], 0)
	nICMS -= nSldLim
	nICMS += nCreNaoCom

	IIF(nICMS < 0, nICMS := 0, nSldCredTr := nICMS)
	//--- Fim Cálculo da Ref. 23 ---
	*/

	/*--- Início Cálculo da Ref. 24 --- */
	nFundoAmp := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoX_FCP"}) > 0,     aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoX_FCP"})][2], 0)
	/*--- Fim Cálculo da Ref. 24 --- */

	DbSelectArea("CWY")
	CWY->(DbSetOrder(2))
	If CWY->(DbSeek(xFilial("CWY") + Strzero(Month(dIni),2,0) + Strzero(Year(dFim),4,0) ))
		nVlFolha := CWY->CWY_VLFOLH
		nVlFatur := CWY->CWY_VLFATM
		nNumEmpr := CWY->CWY_NUMEMP
	EndIf

	nEntVlCtb   := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoI_VlContabil"}) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoI_VlContabil"})][2], 0)
	nSaiVlCtb   := IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoV_VlContabil"}) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoV_VlContabil"})][2], 0)

	If(Month(dIni) == 1 .Or. aWizard[1][7] == "1 - Sim")
		nIniPrpTrib := infEstoque((dIni - 1), "'0', '1'", "'00', '10', '20'") //Estoque Inicial Prop.,Trib., no Estab. E/ou Poder de Terc.
		nIniPrpIsen := infEstoque((dIni - 1), "'0', '1'", "'30','40', '41'") 		  //Estoque Inicial Prop,Isento/Não Trib, Estab E/ou Poder Terc.

		nIniEmTerc := infEstoque((dIni - 1), "'1'")   //Estoque Inicial Pertencente ao Estab. Em Poder de Terc.
		nIniDeTerc := infEstoque((dIni - 1), "'2'")   //Estoque Inicial Pertencente a Terc. Em Poder do Estab.
	EndIf

	If(Month(dIni) == 12 .Or. aWizard[1][8] == "1 - Sim")
		nFimPrpTrib := infEstoque(dFim, "'0', '1'", "'00', '10', '20'") //Estoque Final Prop.,Trib., no Estab. E/ou Poder de Terc.
		nFimPrpIsen := infEstoque(dFim, "'0', '1'", "'30','40', '41'") 	     //Estoque Final Prop,Isento/Não Trib, Estab E/ou Poder Terc.

		nFimEmTerc := infEstoque(dFim, "'1'")    //Estoque Final Pertencente ao Estab. Em Poder de Terc.
		nFimDeTerc  := infEstoque(dFim, "'2'")   //Estoque Final Pertencente a Terc. Em Poder do Estab.
	EndIf

	cStrTxt := cCabecalho
	cStrTxt += StrTran(StrZero(nCredEnt, 16, 2),".","")          //Ref. 01
	cStrTxt += StrTran(StrZero(nCreImp, 16, 2),".","")           //Ref. 02
	cStrTxt += StrTran(StrZero(nCredTran, 16, 2),".","")         //Ref. 03
	cStrTxt += StrTran(StrZero(nCredPres, 16, 2),".","")         //Ref. 04
	cStrTxt += StrTran(StrZero(nCredComp, 16, 2),".","")         //Ref. 05
	cStrTxt += StrTran(StrZero(nCredOutr, 16, 2),".","")         //Ref. 06
	cStrTxt += StrTran(StrZero((nCreImp + nCredEnt + nCredTran + nCredPres + nCredComp + nCredOutr), 16, 2),".","") //Ref. 07
	cStrTxt += StrTran(StrZero(nDebSaid, 16, 2),".","")          //Ref. 08
	cStrTxt += StrTran(StrZero(nDebImp, 16, 2),".","")           //Ref. 09
	cStrTxt += StrTran(StrZero(nDebResp, 16, 2),".","")          //Ref. 10
	cStrTxt += StrTran(StrZero(nDebTran, 16, 2),".","")          //Ref. 11
	cStrTxt += StrTran(StrZero(nDebComp, 16, 2),".","")          //Ref. 12
	cStrTxt += StrTran(StrZero(nDebOutr, 16, 2),".","")          //Ref. 13
	cStrTxt += StrTran(StrZero((nDebResp + nDebComp + nDebImp + nDebSaid + nDebTran + nDebOutr), 16, 2),".","") //Ref. 14

	nLinha := aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVII"})

	If(nLinha > 0 )
		IIF(aTotAnexo[nLinha][2] > 0, cStrTxt += "S", cStrTxt += "N" ) //Ref. 15
	Else
		cStrTxt += "N"
	EndIf

	nLinha 	  := aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVII_TotDeb"})
	If(nLinha > 0)
		nTotDebSt := aTotAnexo[nLinha][2]
	EndIf

	nLinha 	  := aScan(aTotAnexo, {|x| AllTrim(x[1]) == "AnexoVII_TotCred"})
	If(nLinha > 0)
		nTotCreSt := aTotAnexo[nLinha][2]
	EndIf

	If(nTotDebSt > nTotCreSt)
		nRecSt := nTotDebSt - nTotCreSt
	EndIf

	cStrTxt += StrTran(StrZero(nSldCrAnt, 16, 2),".","") // Ref. 16
	cStrTxt += StrTran(StrZero(nSldLim, 16, 2),".","")   // Ref. 18
	cStrTxt += StrTran(StrZero(nPgtoMesRef, 16, 2),".","") //Ref. 20
	cStrTxt += StrTran(StrZero(nPgtoVenc, 16, 2),".","")   //Ref. 21
	cStrTxt += StrTran(StrZero((nRecSt), 16, 2),".","")   //ICMS Subst. Trib., Não compensável, a Recolher Ref. 22
	cStrTxt += StrTran(StrZero(nTotRec, 16, 2),".","")    //Ref. 23
	cStrTxt += StrTran(StrZero(nTotRec, 16, 2),".","")    //Ref. 25
	cStrTxt += StrTran(StrZero(nCreNaoCom, 16, 2),".","") //Ref. 26
	cStrTxt += StrTran(StrZero(aApurST[1][3], 16, 2),".","") //Saldo CR Subst. Trib. a transportar mês seguinte //Ref. 27
	cStrTxt += StrTran(StrZero(nSldCredTr, 16, 2),".","") //Ref. 28

	IIF ((aWizard[1][12] == "1 - Sim"),  cStrTxt += StrTran(StrZero(nTotRec, 16, 2),".",""),  cStrTxt += StrTran(StrZero(0, 16, 2),".","")) //Ref. 29

	cStrTxt += StrTran(StrZero(nVlFatur, 16, 2),".","")  //Ref. 31
	cStrTxt += StrZero(nNumEmpr, 6, 0)					 //Ref. 32
	cStrTxt += StrTran(StrZero(nVlFolha, 16, 2),".","")  //Ref. 33
	cStrTxt += Replicate("0",15) //Ref. 37
	cStrTxt += Replicate("0",15) //Ref. 38
	cStrTxt += Replicate("0",15) //Ref. 39
	cStrTxt += Replicate("0",15) //Ref. 40
	cStrTxt += Replicate("0",15) //Ref. 41
	cStrTxt += Replicate("0",15) //Ref. 42
	cStrTxt += StrTran(StrZero(nEntVlCtb, 16, 2),".","") //Ref. 43
	cStrTxt += StrTran(StrZero(nSaiVlCtb, 16, 2),".","") //Ref. 44

	cStrTxt += StrTran(StrZero(guiaAntec(dIni, dFim, "1", "'2', '3'"), 16, 2),".","")  //1 - ICMS +  2 - No Fato Gerador + 3 - Antecipada
	cStrTxt += StrTran(StrZero(guiaAntec(dIni, dFim, "2", "'2', '3'"), 16, 2),".","")  //2 - ICMSST +  2 - No Fato Gerador + 3 - Antecipada

	IIf(nSldCredTr > 0, cStrTxt += "S", cStrTxt += "N") //Transporta Saldo Devedor – ICMS Próprio – Próximo Mês

	cStrTxt += StrTran(StrZero(nIniPrpTrib, 17, 2),".","")   //Ref. 45
	cStrTxt += StrTran(StrZero(nIniPrpIsen, 17, 2),".","")   //Ref. 46
	cStrTxt += StrTran(StrZero(nIniEmTerc, 17, 2),".","")    //Ref. 47
	cStrTxt += StrTran(StrZero(nIniDeTerc, 17, 2),".","")    //Ref. 48

	cStrTxt += StrTran(StrZero(nFimPrpTrib, 17, 2),".","")   //Ref. 49
	cStrTxt += StrTran(StrZero(nFimPrpIsen, 17, 2),".","")   //Ref. 50
	cStrTxt += StrTran(StrZero(nFimEmTerc, 17, 2),".","")    //Ref. 51
	cStrTxt += StrTran(StrZero(nFimDeTerc, 17, 2),".","")    //Ref. 52

	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoI"}) > 0,   aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoI"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoIc"}) > 0,  aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoIc"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoII"}) > 0,  aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoII"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoIII"}) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoIII"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoIV"}) > 0,  aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoIV"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoV"}) > 0,   aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoV"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVa"}) > 0,  aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVa"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVb"}) > 0,  aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVb"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVc"}) > 0,  aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVc"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVI"}) > 0,  aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVI"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVII"}) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVII"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVIIa"}) > 0,aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVIIa"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVIIb"}) > 0,aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVIIb"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVIII"}) > 0,aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoVIII"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoIX"}) > 0,  aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoIX"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoX"}) > 0,   aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoX"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoXIV"}) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoXIV"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoXV"}) > 0,  aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoXV"})][2], 0), 3, 0)
	cStrTxt += StrZero(IIF(aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoXVI"}) > 0, aTotAnexo[aScan(aTotAnexo, {|x| AllTrim(x[1]) == "qtdAnexoXVI"})][2], 0), 3, 0)

	cStrTxt += "S" //Indicador de Sistema Próprio
	cStrTxt += "N" //Indicador de SINTEGRA
	cStrTxt += IIF(aWizard[1][7] == "1 - Sim", "S", "N") //Indicador de Início de Atividade
	cStrTxt += IIF(aWizard[1][8] == "1 - Sim", "S", "N") //Indicador de Fim de Atividade

	cStrTxt += StrTran(StrZero(nFundoAmp, 16, 2),".","")  // Normal Ref. 24
	cStrTxt += StrTran(StrZero(guiaAntec(dIni, dFim, "3", "'2'"), 16, 2),".","")     //3 - AMPARA +  2 - No Fato Gerador + 3 - Antecipada
	cStrTxt += StrTran(StrZero(guiaAntec(dIni, dFim, "4", "'2'"), 16, 2),".","")     //4 - AMPARA ST +  2 - No Fato Gerador + 3 - Antecipada

	cStrTxt += CRLF
	WrtStrTxt( nHandle, cStrTxt)

	GerTxtGRS( nHandle, cTxtSys, aFilial[1] + "_" + cReg)

Recover
	lFound := .F.

End Sequence

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CrDebImpor

Retorno os valores de Crédito e Débito referente a Exportação e Importação
respectivamente

@Param 	cPerIni ->	Data Inicial do período de processamento
		cPerFim ->	Data Final do período de processamento
		cTipOpe ->  E-Entrada; S-Saída

@Return nTot -> Valor total de crédito ou débito
@Author Rafael Völtz
@Since 12/08/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function CrDebImpor(cDtIni, cDtFim, cOper)
	Local cAliasQry  := GetNextAlias()
	Local cStrQuery  := ""
	Local nTot 		 := 0

  	cStrQuery := " SELECT SUM(C6Z_IMPCRD) AS TOTAL "
	cStrQuery +=   " FROM " + RetSqlName('C2S') + " C2S, "
	cStrQuery +=              RetSqlName('C6Z') + " C6Z, "
	cStrQuery +=              RetSqlName('C0Y') + " C0Y "
	cStrQuery += "  WHERE C2S.C2S_FILIAL = '" + xFilial('C2S') + "' "
	cStrQuery +=   "  AND C2S.C2S_DTINI  >=  '"+ cDtIni + "'
	cStrQuery +=   "  AND C2S.C2S_DTINI  <=  '"+ cDtFim + "'
	cStrQuery +=   "  AND C2S.C2S_TIPAPU =  '0'"
	cStrQuery +=   "  AND C2S.C2S_INDAPU =  ' '"
	cStrQuery +=   "  AND C6Z.C6Z_FILIAL =  C2S.C2S_FILIAL "
	cStrQuery +=   "  AND C6Z.C6Z_ID     =  C2S.C2S_ID "
	cStrQuery +=   "  AND C6Z.C6Z_CFOP       =  C0Y.C0Y_ID "
	cStrQuery +=   "  AND C0Y.C0Y_FILIAL =  '" + xFilial('C0Y') + "' "

	If(cOper == "C") //credito
		cStrQuery +=   "  AND C0Y.C0Y_CODIGO BETWEEN 3000 AND 3999 "
	Else
		cStrQuery +=   "  AND C0Y.C0Y_CODIGO BETWEEN 7000 AND 7999 "
	EndIf

	cStrQuery +=   "  AND C2S.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND C0Y.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND C6Z.D_E_L_E_T_ = ' '"

	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasQry,.T.,.T.)

	nTot := (cAliasQry)->TOTAL

Return nTot


//---------------------------------------------------------------------
/*/{Protheus.doc} ajusDoc

Retorno ajustes fiscais dos documentos

@Param 	cPerIni ->	Data Inicial do período de processamento
		cPerFim ->	Data Final do período de processamento
		cTipOpe ->  E-Entrada; S-Saída
		cSubItem -> Código do subitem
		cUFID    -> ID UF

@Return nValAjus -> Valor do ajuste
@Author Rafael Völtz
@Since 12/08/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ajusDoc(cPerIni, cPerFim, cTipOpe, cSubItem, cUFID)
  Local cStrQuery   := ""
  Local cAliasNF  := GetNextAlias()
  Local nValAjus := 0

  cStrQuery += " SELECT SUM(C2D.C2D_VLICM) VLR_AJUS"
  cStrQuery +=   " FROM " + RetSqlName('C20') + " C20, "
  cStrQuery +=              RetSqlName('C2D') + " C2D, "
  cStrQuery +=              RetSqlName('CHY') + " CHY  "
  cStrQuery += "  WHERE C20.C20_FILIAL                = '" + xFilial("C20") + "' "
  cStrQuery +=   "  AND C20.C20_DTDOC  BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'"
  cStrQuery +=   "  AND C20.C20_FILIAL = C2D.C2D_FILIAL "
  cStrQuery +=   "  AND C20.C20_CHVNF  = C2D.C2D_CHVNF "
  cStrQuery +=   "  AND C20.C20_INDOPE = '"+ cTipOpe + "'"
  cStrQuery +=   "  AND C20.C20_CODSIT NOT IN('000003','000005','000006') "  //CANCELADA, INUTILIZADA E DENEGADA
  cStrQuery +=   "  AND C2D.C2D_IDSUBI = CHY.CHY_ID "
  cStrQuery +=   "  AND CHY.CHY_FILIAL = ' '"
  cStrQuery +=   "  AND CHY.CHY_IDUF   = '" + cUFID + "'"
  cStrQuery +=   "  AND CHY.CHY_CODIGO = '" + cSubItem + "'"
  cStrQuery +=   "  AND C20.D_E_L_E_T_ = ' '"
  cStrQuery +=   "  AND C2D.D_E_L_E_T_ = ' '"
  cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"

  cStrQuery := ChangeQuery(cStrQuery)
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasNF,.T.,.T.)
  DbSelectArea(cAliasNF)
  dbGoTop()

  nValAjus := (cAliasNF)->VLR_AJUS

  DbCloseArea()

Return nValAjus

//---------------------------------------------------------------------
/*/{Protheus.doc} apurICMST

Retorno informações apuração de ICMS ST

@Param 	cPerIni ->	Data Inicial do período de processamento
		cPerFim ->	Data Final do período de processamento

@Return aApurST -> Valores da apuração de ICMS ST
@Author Rafael Völtz
@Since 12/08/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function apurICMST(cDtIni, cDtFim)
 Local cQryAls  := GetNextAlias()
 Local cSelect := ""
 Local cFrom   := ""
 Local cWhere  := ""
 Local aApurST := {}

	cSelect += " SUM(C3J.C3J_CREANT) C3J_CREANT, SUM(C3J.C3J_VLRREC) C3J_VLRREC, SUM(C3J_CRDTRA) C3J_CRDTRA "

	cFrom 	  := RetSqlName("C3J") + " C3J, "
	cFrom 	  += RetSqlName("C09") + " C09 "

	cWhere  += " C3J.C3J_FILIAL = '" + xFilial("C3J") + "' AND "
	cWhere  += " C3J.C3J_DTINI >= '" + cDtIni + "' AND "
	cWhere  += " C3J.C3J_DTFIN <= '" + cDtFim + "' AND "
	cWhere  += " C09.C09_FILIAL = '" + xFilial("C09") + "' AND "
	cWhere  += " C09.C09_ID = C3J.C3J_UF AND "
	cWhere  += " C09.C09_UF IN ('RS','EX') AND  "

	cSelect      := "%" + cSelect     + "%"
	cFrom        := "%" + cFrom       + "%"
	cWhere       := "%" + cWhere      + "%"

	BeginSql Alias cQryAls

		SELECT
		%Exp:cSelect%

		FROM
	    %Exp:cFrom%

		WHERE
		%Exp:cWhere%
		C3J.%NotDel% AND
		C09.%NotDel%

	EndSql

	//Alimenta o array aCabecApur com o campo/conteúdo de toda informação encontrada
	dbSelectArea(cQryAls)
	while (cQryAls)->( !eof() )
		aAdd(aApurST, {(cQryAls)->C3J_CREANT, (cQryAls)->C3J_VLRREC, (cQryAls)->C3J_CRDTRA})
		(cQryAls)->( dbSkip() )
	enddo
	(cQryAls)->( dbCloseArea() )

Return aApurST


//---------------------------------------------------------------------
/*/{Protheus.doc} guiaAntec

Retorno informações referente as Guias de Recolhimento de pagamento
antecipado ou no Fato Gerador

@Param 	cPerIni ->	Data Inicial do período de processamento
		cPerFim ->	Data Final do período de processamento

@Return aVlGuias -> Valor Guias pagas antecipadamente ou no fato gerador
@Author Rafael Völtz
@Since 12/08/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function guiaAntec(dIni, dFim, cTpImp, cTpRecol)
 Local cQryAls  := GetNextAlias()
 Local cSelect  := ""
 Local cWhere   := ""
 Local nTotal   := 0
 Local cPeriodo := StrZero(Month(dIni),2,0) + cValToChar(Year(dIni))

	cSelect  := "% SUM(C0R.C0R_VLDA) C0R_VLDAAD   %"

	cWhere  += "% C0R.C0R_FILIAL = '" + xFilial("C0R") + "' AND "
	cWhere  += "  C0R.C0R_PERIOD = '"+ cPeriodo +"' AND "
	cWhere  += "  C0R.C0R_UF     = '000024' AND "
	cWhere  += "  C0R.C0R_DTPGT BETWEEN '" + dtos(dIni) + "' AND '" + dtos(dFim) + "' AND "
	cWhere  += "  C0R.C0R_DTVCT BETWEEN '" + dtos(dIni) + "' AND '" + dtos(dFim) + "' AND "
	cWhere  += "  C0R.C0R_TPREC  IN ("+ cTpRecol +") AND "
	cWhere  += "  C0R.C0R_TPIMPO = '"+ cTpImp +"' AND %"

	BeginSql Alias cQryAls

		SELECT
		%Exp:cSelect%

		FROM
		%Table:C0R% C0R

		WHERE
		%Exp:cWhere%
		C0R.%NotDel%

	EndSql

	//Alimenta o array aCabecApur com o campo/conteúdo de toda informação encontrada
	dbSelectArea(cQryAls)
	nTotal := (cQryAls)->C0R_VLDAAD
	(cQryAls)->( dbCloseArea() )

Return nTotal

//---------------------------------------------------------------------
/*/{Protheus.doc} infEstoque

Retorno informações do Estoque no período

@Param 	cPerIni ->	Data Inicial do período de processamento
		cPerFim ->	Data Final do período de processamento

@Return aVlGuias -> Valor Guias pagas antecipadamente ou no fato gerador
@Author Rafael Völtz
@Since 12/08/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function infEstoque(dIvent, cIndProp, cCST)
  Local cSelect  := ""
  Local cWhere   := ""
  Local cFrom    := ""
  Local cQryAls  := GetNextAlias()
  Local nVlEstoq := 0

  cSelect := "% SUM(C5B.C5B_VITEM) C5B_VITEM %"

  cFrom	  := "%"
  cFrom   += RetSqlName('C5A') + " C5A,"
  cFrom   += RetSqlName('C5B') + " C5B,"
  cFrom   += RetSqlName('C5C') + " C5C "

  cWhere  := "% C5A.C5A_FILIAL = '" + xFilial("C5A") + "' AND "
  cWhere  +=  " C5A.C5A_DTINV  = '" + DTOS(dIvent) + "' AND "
  cWhere  +=  " C5A.C5A_FILIAL = C5B.C5B_FILIAL AND "
  cWhere  +=  " C5A.C5A_ID     = C5B.C5B_ID  AND "
  cWhere  +=  " C5B.C5B_FILIAL = C5C.C5C_FILIAL AND "
  cWhere  +=  " C5B.C5B_ID     = C5C.C5C_ID  AND "
  cWhere  +=  " C5B.C5B_CODITE = C5C.C5C_CODITE  AND "
  cWhere  +=  " C5B.C5B_INDPRO IN ("+ cIndProp +") AND"

  If !Empty(cCST)
  	cWhere  +=  " C14.C14_FILIAL = '" + xFilial("C14") + "' AND "
  	cWhere  +=  " C14.C14_ID = C5C.C5C_CSTICM  AND "
  	cWhere  +=  " C14.C14_CODIGO IN ("+ cCST +") AND "
  	cFrom   += "," + RetSqlName('C14') + " C14"
  EndIf

  cFrom	 += "%"
  cWhere += "%"

  BeginSql Alias cQryAls

	SELECT
	%Exp:cSelect%

	FROM
	%Exp:cFrom%

	WHERE
	%Exp:cWhere%
	C5A.%NotDel% AND
	C5B.%NotDel% AND
	C5C.%NotDel%

  EndSql

  DbSelectArea(cQryAls)

  nVlEstoq := (cQryAls)->C5B_VITEM

  (cQryAls)->(DbCloseArea())

Return nVlEstoq

