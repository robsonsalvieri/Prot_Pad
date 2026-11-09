#INCLUDE "mnta990.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "PROTHEUS.CH"

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} MNTR996
Imprimir Programacao.
@type function

@author Denis Hyroshi de Souza
@since 17/04/2003

@param  c990TRB3, array, O.S. já programadas.
@param  c990TRBE, array, Insumos de especialidades.
@param  aList2  , array, Carga disponivel das especialidades.

/*/
//-----------------------------------------------------------------------------------------
Function MNTR996( c990TRB3, c990TRBE, aList2 )

	Local nX
	Local aArea    := GetArea()
	Local nTot01   := 0
	Local nTot02   := 0
	Local nTot03   := 0
	Local nTotDisp := 0
	Local nTotProg := 0
	Local nTotTecn := 0
	Local cManut

	Private oPrint
	Private oFont12,oFont13,oFont20
	Private lin

	// Permite a impressão de relatório personalizado
	If ExistBlock("MNTA9908")
		Return ExecBlock("MNTA9908",.F.,.F.,{c990TRB3})
	EndIf

	oFont08	:= TFont():New("Arial",07,07,,.F.,,,,.F.,.F.)
	oFont12	:= TFont():New("Arial",09,09,,.T.,,,,.F.,.F.)
	oFont13	:= TFont():New("Arial",08,08,,.F.,,,,.F.,.F.)
	oFont20	:= TFont():New("Arial",12,12,,.T.,,,,.F.,.F.)

	oPrint	:= TMSPrinter():New(OemToAnsi(STR0145)) //"Relatório da Programação de O.S."
	If !oPrint:Setup() //Apresenta Janela de Configuração da impressora
		Return .F.
	EndIf
	oPrint:SetLandscape()

	lin := 9999
	nPag1 := 0
	lNaoImpr := .T.
	dbSelectArea(c990TRB3)
	dbSetOrder(nTipoInd)
	dbGoTop()
	ProcRegua((c990TRB3)->(RecCount()))
	While !EoF()
		IncProc()

		dbSelectArea("STJ")
		dbSetOrder(1)
		dbSeek( xFilial("STJ") + (c990TRB3)->ORDEM + (c990TRB3)->PLANO )

		dbSelectArea("ST4")
		dbSetOrder(1)
		dbSeek( xFilial("ST4") + STJ->TJ_SERVICO )

		dbSelectArea("STF")
		dbSetOrder(1) //TF_FILIAL+TF_CODBEM+TF_SERVICO+TF_SEQRELA
		dbSeek( xFilial("STF") + STJ->TJ_CODBEM + STJ->TJ_SERVICO + STJ->TJ_SEQRELA)
		cManut := STF->TF_NOMEMAN //Retorna o Nome da Manutenção na STF.

		lTemEspec := .F.

		dbSelectArea(c990TRBE)
		dbSetOrder(02)
		dbGoTop()
		dbSeek( (c990TRB3)->ORDEM + (c990TRB3)->PLANO )
		While !EoF() .And. (c990TRB3)->ORDEM + (c990TRB3)->PLANO == (c990TRBE)->ORDEM + (c990TRBE)->PLANO

			Somalin1(60,.T.)
			lTemEspec := .T.

			cHoraHomem := MtoH( HtoM((c990TRBE)->TEMPRO) / (c990TRBE)->QTDTEC )
			oPrint:Say(lin,0110,(c990TRB3)->EQUIPE,oFont13)
			oPrint:Say(lin,0260,(c990TRB3)->CODBEM,oFont13)
			oPrint:Say(lin,0520,(c990TRB3)->ORDEM,oFont13)
			oPrint:Say(lin,0660,Substr(Alltrim(ST4->T4_NOME),1,25),oFont13)
			oPrint:say(lin,1050,Substr(Alltrim(cManut),1,25),oFont13)
			oPrint:Say(lin,1600,Substr(Alltrim((c990TRBE)->DESCRI),1,30),oFont13)
			oPrint:Say(lin,2240,TransForm((c990TRBE)->QTDTEC,"9999"),oFont13,,,,1)
			oPrint:Say(lin,2280,cHoraHomem,oFont13)
			oPrint:Say(lin,2450,(c990TRBE)->TEMPRO,oFont13)
			//oPrint:Say(lin,2650,(c990TRBE)->OBS,oFont13)

			dbSelectArea(c990TRBE)
			dbSkip()
		End

		If !lTemEspec
			Somalin1(60,.T.)
			oPrint:Say(lin,0110,(c990TRB3)->EQUIPE,oFont13)
			oPrint:Say(lin,0260,(c990TRB3)->CODBEM,oFont13)
			oPrint:Say(lin,0520,(c990TRB3)->ORDEM,oFont13)
			oPrint:Say(lin,0660,Substr(Alltrim(ST4->T4_NOME),1,25),oFont13)
			oPrint:say(lin,1050,Substr(Alltrim(cManut),1,25),oFont13)
		EndIf

		dbSelectArea(c990TRB3)
		dbSkip()
	End

	dbSelectArea(c990TRB3)
	dbGoTop()

	If !lNaoImpr
		If lin + 310 + (Len(aList2) * 60) > 2350
			lin := 9999
		EndIf
		For nX := 1 to Len(aList2)
			If nX == 1
				Somalin1(150,.F.)
				oPrint:Say(lin,130,STR0146,oFont20) //"Resumo da Programação - Homem Hora Disponível x Programado"
				Somalin1(080,.F.)
				oPrint:Line(lin-10,100,lin-10,2300)
				oPrint:Line(lin+60,100,lin+60,2300)
				oPrint:Say(lin,0130,STR0074,oFont12) //"Especialidade"
				oPrint:Say(lin,0730,STR0147,oFont12) //"Qtde."
				oPrint:Say(lin,0850,STR0148,oFont12) //"HH Disponível"
				oPrint:Say(lin,1150,STR0149,oFont12) //"HH Programado"
				oPrint:Say(lin,1450,STR0150,oFont12) //"Diferença"
				oPrint:Say(lin,1700,STR0151,oFont12) //"Backlog (HH)"
				oPrint:Say(lin,1970,STR0152,oFont12) //"Backlog (Dias)"
				Somalin1(20,.F.)
			EndIf
			Somalin1(60,.F.)
			oPrint:Say(lin,0130,aList2[nX][02],oFont13)
			oPrint:Say(lin,0820,Alltrim(Str(aList2[nX][03]+aList2[nX][04]-aList2[nX][06],6)),oFont13,,,,1)
			oPrint:Say(lin,0850,aList2[nX][09],oFont13)
			oPrint:Say(lin,1150,aList2[nX][08],oFont13)
			nDiff := HtoM(aList2[nX][09])-HtoM(aList2[nX][08])
			If nDiff < 0
				nDiff := nDiff * -1
				oPrint:Say(lin,1440,"-"+MtoH( nDiff ),oFont13)
			Else
				oPrint:Say(lin,1450,MtoH( nDiff ),oFont13)
			EndIf

			nHrTRBE := 0
			dbSelectArea(c990TRBE)
			dbSetOrder(3)
			dbSeek(aList2[nX][02])
			While !EoF() .And. Alltrim(aList2[nX][02]) == Alltrim((c990TRBE)->DESCRI)
				nHrTRBE += HtoM((c990TRBE)->TEMREA)
				dbSkip()
			End
			nPart01  := nHrTRBE / 60
			nPart02  := HtoM(aList2[nX][09]) / 60
			nBackLog := nPart01 / ( nPart02 * 0.7 )
			oPrint:Say(lin,1700,MtoH(nHrTRBE),oFont13)
			oPrint:Say(lin,2220,Transform( nBackLog ,"@E 999,999.99"),oFont13,,,,1)

			nTot01   += nPart01
			nTot02   += nPart02
			nTot03   += nHrTRBE
			nTotDisp += HtoM(aList2[nX][09])
			nTotProg += HtoM(aList2[nX][08])
			nTotTecn += aList2[nX][03]+aList2[nX][04]-aList2[nX][06]

			If nX == Len(aList2)
				Somalin1(60,.F.)
				oPrint:Line(lin-10,100,lin-10,2300)
				oPrint:Say(lin,0130,STR0153,oFont13) //"Total"
				oPrint:Say(lin,0820,Alltrim(Str(nTotTecn,6)),oFont13,,,,1)
				oPrint:Say(lin,0850,MtoH(nTotDisp),oFont13)
				oPrint:Say(lin,1150,MtoH(nTotProg),oFont13)
				nDiff := nTotDisp-nTotProg
				nBackLog := nTot01 / ( nTot02 * 0.7 )
				If nDiff < 0
					nDiff := nDiff * -1
					oPrint:Say(lin,1440,"-"+MtoH( nDiff ),oFont13)
				Else
					oPrint:Say(lin,1450,MtoH( nDiff ),oFont13)
				EndIf
				oPrint:Say(lin,1700,MtoH(nTot03),oFont13)
				oPrint:Say(lin,2220,Transform( nBackLog ,"@E 999,999.99"),oFont13,,,,1)
			EndIf
		Next nX

		If lin > 2100
			lin := 9999
			Somalin1(60,.F.)
			lin := 500
		Else
			lin := 2200
		EndIf
		oPrint:Line(lin,100,lin,1000)
		oPrint:Say(lin+20,400,STR0154,oFont13) //"Aprovação Execução"
		oPrint:Line(lin,2000,lin,2900)
		oPrint:Say(lin+20,2300,STR0155,oFont13) //"Aprovação Planejamento"

		oPrint:EndPage()
	EndIf

	oPrint:Preview()
	RestArea(aArea)

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} Somalin1
Somalinha

@sample
Somalin1(nLinha,lCabec)

@author Denis Hyroshi de Souza
@since 17/04/2003
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function Somalin1(nLinha,lCabec)
	Local cSMCOD := IIf(FindFunction("FWGrpCompany"),FWGrpCompany(),SM0->M0_CODIGO)
	Local cSMFIL := IIf(FindFunction("FWCodFil"),FWCodFil(),SM0->M0_CODFIL)

	lin += nLinha
	If lin > 2300
		If !lNaoImpr
			oPrint:EndPage()
		EndIf
		nPag1++
		oPrint:StartPage()

		cFileLogo := cPathSiga+"lgrl"+cSMCOD+cSMFIL+".bmp"
		If File(cFileLogo)
			oPrint:sayBitMap(150,150,cFileLogo,370,120)
		Else
			cFileLogo := cPathSiga+"lgrl"+cSMCOD+".bmp"
			If File(cFileLogo)
				oPrint:sayBitMap(150,150,cFileLogo,370,120)
			EndIf
		EndIf

		lin := 200
		cDescTit := ""
		If !Empty(cTT1_DESCRI)
			cDescTit := Alltrim(cTT1_DESCRI)
		Else
			cDescTit := STR0098 //"PROGRAMAÇÃO"
		EndIf
		If nOSPrInd == 2
			cDescTit += STR0156 + DtoC(_dDiaAtu) //" - PERÍODO: "
		Else
			cDescTit += STR0156 + DtoC(dTT1_DTPROG) + " - " + DtoC(dTT1_DTFIM) //" - PERÍODO: "
		EndIf
		oPrint:Say(lin,800,cDescTit,oFont20)
		oPrint:Say(lin,2700,STR0157+cTT1_CODIGO,oFont20) //"NÚMERO: "

		lin := 320
		If lCabec
			oPrint:Line(lin-10,100,lin-10,3100)
			oPrint:Line(lin+60,100,lin+60,3100)
			oPrint:Say(lin,0110,STR0013,oFont12) //"Equipe"
			oPrint:Say(lin,0260,STR0158,oFont12) //"Equipamento"
			oPrint:Say(lin,0520,STR0010,oFont12) //"Ordem"
			oPrint:Say(lin,0660,STR0159,oFont12) //"Serviço"
			oPrint:Say(lin,1050,STR0316,oFont12) //"Nome da Manutenção"
			oPrint:Say(lin,1600,STR0074,oFont12) //"Especialidade"
			oPrint:Say(lin,2140,STR0147,oFont12) //"Qtde."
			oPrint:Say(lin,2280,STR0160,oFont12) //"Tempo"
			oPrint:Say(lin,2450,STR0161,oFont12) //"HH"
			//oPrint:Say(lin,2650,STR0144,oFont12) //"Executante"
			lin := 400
		EndIf

		lNaoImpr := .F.
	EndIf
Return .T.
