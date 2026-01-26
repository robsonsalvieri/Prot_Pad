#Include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 03/07/00

User Function IMPFERGF()        // incluido pelo assistente de conversao do AP5 IDE em 03/07/00

Local nCntCd		:= 0
Local nConta		:= 0
Local nDiaFeQueb 	:= 0
Local nDtIngres   := 0
Local nDtRegres   := 0
Local cDtRegres   := ""
Local aTempServ   := {}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMPFERGRF³ Autor ³ R.H. - Paulo          ³ Data ³ 16.02.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Recibo de Ferias                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ IMPFERGR                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDMAKE                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³------³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura No Arquivo de Ferias o Periodo a Ser Listado         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dDtBusFer := fDtBusFer() // Busca RH_DTRECIB ou RH_DTITENS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Funcionario tem  dias de Licensa remunerada, entao deve-se³
//³ imprimir somente o period de gozo das ferias (conf.vlr calcu-³
//³ lado.)                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SRH->( RH_DIALRE1 + RH_DIALREM) > 0
	nDiaFeQueb := SRH->(RH_DFERIAS - Int(RH_DFERIAS) )
	DaAuxF 	  := SRH->RH_DATAFIM -( SRH->( RH_DIALRE1 + RH_DIALREM ) ) + If(nDiaFeQueb>0 , 1, 0 )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recibo De Ferias                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPdv   := {}
aPdd   := {}
cRet1  := ""
cRet2  := ""
nLi    := 1
nLiAnt := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona Arq. SRR Para Guardar na Matriz as Verbas De Ferias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SRR")
If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "F" )
	While ! Eof() .And. SRA->RA_FIlIAL + SRA->RA_MAT + "F" == SRR->RR_FILIAL + SRR->RR_MAT + SRR->RR_TIPO3
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Verba For Abono Ou 13o Esta $ Na Variavel Nao Lista ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SRR->RR_PD #cPdAb .And. SRR->RR_PD # cPd13Ab .And. SRR->RR_PD # cPd13o .And. SRR->RR_PD # aCodFol[102,1] .And.;
			Ascan(aCodBenef, { |x| x[1] == SRR->RR_PD }) == 0
			If SRR->RR_DATA == dDtBusFer
				If PosSrv( SRR->RR_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
					Aadd(aPdv , { SRR->RR_PD , SRR->RR_VALOR })
				ElseIf PosSrv( SRR->RR_PD , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "2"
					Aadd(aPdd , { SRR->RR_PD , SRR->RR_VALOR })
				Endif
			Endif
		Endif
		dbSkip()
	Enddo
	
	PER_AQ_I := STRZERO(DAY(SRH->RH_DATABASE),2)+"/"+STRZERO(MONTH(SRH->RH_DATABAS),2)+"/"+STRZERO(YEAR(SRH->RH_DATABAS),4)	//" De "###" De "
	PER_AQ_F := STRZERO(DAY(SRH->RH_DBASEATE),2)+"/"+STRZERO(MONTH(SRH->RH_DBASEAT),2)+"/"+STRZERO(YEAR(SRH->RH_DBASEAT),4)	//" De "###" De "
	PER_GO_I := STRZERO(DAY(DAAUXI),2)+"/"+STRZERO(MONTH(DAAUXI),2)+"/"+STRZERO(YEAR(DAAUXI),4)		//" De "###" De "
	PER_GO_F := STRZERO(DAY(DAAUXF),2)+"/"+STRZERO(MONTH(DAAUXF),2)+"/"+STRZERO(YEAR(DAAUXF),4)		//" De "###" De "
	
	//		aMat[1]  := SRA->RA_MAT
	nAnos := 0 // fCalAntig(aMat)
	
	aTempServ := DateDiffYMD(SRA->RA_ADMISSA, dDataDia )
	
	oPrint:Say(nLi+20,110 , Transform(aTempServ[1],"99")	,oArial10N) // qtde anos
	oPrint:Say(nLi+20,150 , OemToAnsi("AÑO")								,oArial10N)
	
	nLi:=nLi+120
	oPrint:Box(nLi-50 ,100,nLi+90,2450)
	oPrint:Line(nLi-50,400,nLi+90,400)
	oPrint:Line(nLi-50,2150,nLi+90,2150)
	//////////////////////////////////////
	oPrint:Box(nLi-50 ,2150,nLi+20,2450)
	//////////////////////////////////////
	oPrint:Say(nLi,120  , OemToAnsi("NOMINA")					,oArial16N)
	oPrint:Say(nLi,1000 , OemToAnsi("RECIBO DE VACACIONES")		,oArial16N)
	oPrint:Say(nLi-30,2155 , OemToAnsi("FECHA")					,oArial9N)
	oPrint:Say(nLi-30,2285 , STRZERO(DAY(dDataDia),2)+"/"+STRZERO(MONTH(dDataDia),2)+"/"+STRZERO(YEAR(dDataDia),4)	,oArial9N)	// data emissão
	
	//////////////////////////////////////
	nLi:=nLi+140
	oPrint:Box(nLi-50 ,100,nLi+50,2450)
	oPrint:Line(nLi-50,1250,nLi+50,1250)
	//////////////////////////////////////
	oPrint:Say(nLi,110 , OemToAnsi("APELLIDOS Y NOMBRES") + " " +  Alltrim(SRA->RA_PRINOME)+" "+Alltrim(SRA->RA_SECNOME),oArial11N)
	oPrint:Say(nLi,1300 , OemToAnsi("CARGO") + " " + SRA->RA_CARGO + " - "+FDESC("SQ3",SRA->RA_CARGO,"Q3_DESCSUM"),oArial11N)
	//////////////////////////////////////
	nLi:=nLi+100
	oPrint:Box(nLi-50 ,100,nLi+50,2450)
	oPrint:Line(nLi-50,620,nLi+50,620)
	oPrint:Line(nLi-50,1835,nLi+50,1835)
	oPrint:Line(nLi-50,1250,nLi+50,1250)
	//////////////////////////////////////
	nLi:=nLi+100
	oPrint:Box(nLi-50 ,100,nLi+65,2450)
	oPrint:Line(nLi-50,620,nLi+65,620)
	oPrint:Line(nLi-50,1250,nLi+65,1250)
	oPrint:Line(nLi-50,1535,nLi+65,1535)
	oPrint:Line(nLi-50,1835,nLi+65,1835)
	oPrint:Line(nLi-50,2035,nLi+65,2035)
	oPrint:Line(nLi-50,2245,nLi+65,2245)
	//////////////////////////////////////
	oPrint:Say(nLi-100,110 , OemToAnsi("FECHA DE INGRESO")		,oArial11N)
	oPrint:Say(nLi-100,690 , OemToAnsi("TIEMPO DE SERVICIOS") 	,oArial11N)
	oPrint:Say(nLi-100,1320, OemToAnsi("PERIODO VACACIONAL") 	,oArial11N)
	oPrint:Say(nLi-100,1900, OemToAnsi("PERIODO A DISFRUTAR")	,oArial11N)
	nLi:=nLi+80
	
	oPrint:Say(nLi-120,1330, OemToAnsi("DESDE")					,oArial9N) //"DESDE"
	oPrint:Say(nLi-120,1610, OemToAnsi("HASTA")					,oArial9N) //"HASTA"
	oPrint:Say(nLi-120,1870, OemToAnsi("DESDE")					,oArial9N) //"DESDE"
	oPrint:Say(nLi-120,2070, OemToAnsi("HASTA")					,oArial9N) //"HASTA"
	oPrint:Say(nLi-120,2260, OemToAnsi("REGRESO")				,oArial9N) //"REGRESO"
	
	nDtIngres := STRZERO(DAY(SRA->RA_ADMISSA),2)+"/"+STRZERO(MONTH(SRA->RA_ADMISSA),2)+"/"+STRZERO(YEAR(SRA->RA_ADMISSA),4)
	
	oPrint:Say(nLi-70,260 , nDtIngres												,oArial9N) //data de ingresso
	
	If	aTempServ[1] = 1
		oPrint:Say(nLi-70,670 , Transform(aTempServ[1],"99") + " " + OemToAnsi("AÑO") ,oArial9N) //tiempo de servicos ANO
	Else
		oPrint:Say(nLi-70,670 , Transform(aTempServ[1],"99") + " " + OemToAnsi("AÑOS") ,oArial9N) //tiempo de servicos ANOS
	EndIf
	If	aTempServ[2] = 1
		oPrint:Say(nLi-70,830 , Transform(aTempServ[2],"99") + " " + OemToAnsi("MES") ,oArial9N) //tiempo de servicos MES
	Else
		oPrint:Say(nLi-70,830 , Transform(aTempServ[2],"99") + " " + OemToAnsi("MESES") ,oArial9N) //tiempo de servicos MESES
	EndIf
	If	aTempServ[3] = 1
		oPrint:Say(nLi-70,1020 , Transform(aTempServ[3],"99") + " " + OemToAnsi("DIA") ,oArial9N) //tiempo de servicos DIA
	Else
		oPrint:Say(nLi-70,1020 , Transform(aTempServ[3],"99") + " " + OemToAnsi("DIAS") ,oArial9N) //tiempo de servicos DIAS
	EndIf
	
	oPrint:Say(nLi-70,1310, PER_AQ_I													,oArial9N) //tiempo de servicos	 DESDE
	oPrint:Say(nLi-70,1600, PER_AQ_F													,oArial9N) //tiempo de servicos	 HASTA
	oPrint:Say(nLi-70,1850, PER_GO_I													,oArial9N) //PERIODO A DISFRUTAR	 DESDE
	oPrint:Say(nLi-70,2050, PER_GO_F													,oArial9N) //PERIODO A DISFRUTAR  HASTA
	
	nDtRegres := SRH->RH_DATAFIM + 1
	cDtRegres := STRZERO(DAY(nDtRegres),2)+"/"+STRZERO(MONTH(nDtRegres),2)+"/"+STRZERO(YEAR(nDtRegres),4)		//data de regreso"
	oPrint:Say(nLi-70,2260, cDtRegres	   						  				,oArial9N) //REGRESO
	
	//////////////////////////////////////
	nLi:=nLi+30
	oPrint:Box(nLi-45 ,100,nLi+60,2450)
	oPrint:Line(nLi-45,1250,nLi+60,1250)
	//////////////////////////////////////
	nLi:=nLi+60
	
	oPrint:Say(nLi-70,530 , OemToAnsi("SUELDO") 			,oArial11N)
	oPrint:Say(nLi-70,1760, OemToAnsi("CONCEPTO") 			,oArial11N)
	
	nLi:=nLi+30
	//////////////////////////////////////
	oPrint:Box(nLi-27 ,100,nLi+350,2450)
	oPrint:Line(nLi-27,1250,nLi+350,1250)
	//////////////////////////////////////
	
	oPrint:Say(nLi,160 , OemToAnsi("MENSUAL................................Bs.") ,oArial11N)
	oPrint:Say(nLi,860 , AliDir(SRH->RH_SALMES,"@E 999,999,999.99")		,oArial11N)	//Valor Mensual
	
	oPrint:Say(nLi,1320, OemToAnsi("VACACIONES (ART.219 L.O.T.):")				,oArial11N)
	oPrint:Say(nLi,2020 ,AliDir(SRH->RH_DFERIAS,"99.9")			 			,oArial11N)	//Qtde dias VACACIONES
	nLi:=nLi+80
	
	oPrint:Say(nLi,1320, OemToAnsi("BONO VACACIONAL  (ART.223 L.O.T.):")		,oArial11N)
	oPrint:Say(nLi,2020, AliDir(SRH->RH_DBONIFI,"99.9")						,oArial11N)	//Qtde dias BONO VACACIONAL
	nLi:=nLi+80
	
	oPrint:Say(nLi,1320, OemToAnsi("FALTAS:") 									,oArial11N)
	oPrint:Say(nLi,2020, AliDir(SRH->RH_DFALTAS,"99.9")						,oArial11N)	//Qtde dias FALTAS
	nLi:=nLi+80
	
	oPrint:Say(nLi,160 , OemToAnsi("MENSUAL DIARIO.....................Bs.") 	,oArial11N)
	oPrint:Say(nLi,860 , AliDir(SRH->RH_SALDIA,"@E 9,999,999.99")  		,oArial11N)	//Valor Mensual Diario
	nLi:=nLi+160
	//////////////////////////////////////
	oPrint:Box(nLi-50 ,100,nLi+60,2450)
	//		oPrint:Line(nLi-50,1250,nLi+70,1250)
	//////////////////////////////////////
	oPrint:Say(nLi,480 , OemToAnsi("ASIGNACIONES")								,oArial11N)
	oPrint:Say(nLi,1730, OemToAnsi("DEDUCCIONES")								,oArial11N)
	nLi:=nLi+115
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao das Verbas                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLiAnt  := nLi
	
	nMaximo := MAX(Len(aPDV),Len(aPdd))
	
	//////////////////////////////////////
	oPrint:Box(nLi-50 ,100,nLi+70+(nMaximo * 80),2450)
	oPrint:Line(nLi-50,1250,nLi+70+(nMaximo * 80),1250)
	//////////////////////////////////////
	
	For nConta :=1 TO nMaximo
		If nConta <= Len(aPdv)
			cDesc:=Left(DescPd(aPdv[nConta,1],SRA->RA_FILIAL),15)
			DET:= aPdv[nConta,1]+" "+cDesc+"   "+AliDir(aPdv[nConta,2],'@E 999,999,999.99')
			oPrint:Say(nLi,160 ,  aPdv[nConta,1]  															,oArial11N)
			oPrint:Say(nLi,260 ,  Left(DescPd(aPdv[nConta,1],SRA->RA_FILIAL),15)					,oArial11N)
			oPrint:Say(nLi,860 ,  AliDir(aPdv[nConta,2],'@E 999,999,999.99')						,oArial11N)
		EndIf
		If nConta <= Len(aPdd)
			cDesc:=Left(DescPd(aPdd[nConta,1],SRA->RA_FILIAL),15)
			DET:= aPdd[nConta,1]+" "+cDesc+"   "+AliDir(aPdd[nConta,2],'@E 999,999,999.99')
			oPrint:Say(nLi,1320 ,  aPdd[nConta,1]															,oArial11N)
			oPrint:Say(nLi,1420 ,  Left(DescPd(aPdd[nConta,1],SRA->RA_FILIAL),15)				,oArial11N)
			oPrint:Say(nLi,2020 ,  AliDir(aPdd[nConta,2],'@E 999,999,999.99') 					,oArial11N)
		EndIf
		nLi:=nLi+80
	Next
	
	nTvp := 0.00
	nTvd := 0.00
	AeVal(aPdv,{ |X| nTVP:= nTVP + X[2]})    // Acumula Valores
	AeVal(aPdd,{ |X| nTVD:= nTVD + X[2]})
	
	
	nLi:=nLi+100
	//////////////////////////////////////
	oPrint:Box(nLi-30 ,100,nLi+70,2450)
	oPrint:Line(nLi-30,1250,nLi+70,1250)
	//////////////////////////////////////
	oPrint:Say(nLi,160 ,  OemToAnsi("TOTAL ASIGNACIONES:................Bs.") 	,oArial11N)
	oPrint:Say(nLi,860 ,  AliDir(nTvp,"@E 999,999,999.99")						,oArial11N)	//Valor Total ASIGNACIONES
	
	oPrint:Say(nLi,1320,  OemToAnsi("TOTAL DEDUCCIONES:.................Bs.")	,oArial11N)
	oPrint:Say(nLi,2020,  AliDir(nTvd,"@E 999,999,999.99")			  			,oArial11N)	//Valor Total DEDUCCIONES
	
	nLi:=nLi+120
	//////////////////////////////////////
	oPrint:Box(nLi-50 ,100,nLi+70,2450)
	oPrint:Line(nLi-50,1250,nLi+70,1250)
	//////////////////////////////////////
	oPrint:Say(nLi,1320,  OemToAnsi("NETO A PAGAR:.............................Bs.") ,oArial11N)
	oPrint:Say(nLi,2020,  AliDir(nTvp-nTvd,"@E 999,999,999.99")	  				,oArial11N)	//Valor NETO A PAGAR
	
	nLi:=nLi+100
	
	cExt   := EXTENSO(nTvp-nTvd,.F.,1)
	
	SepExt(cExt,42,77,@cRet1,@cRet2)
	
	nLi:=nLi+30
	//////////////////////////////////////
	oPrint:Box(nLi-60 ,100,nLi+720,2450)
	//////////////////////////////////////
	oPrint:Say(nLi,360 , OemToAnsi("Declaro haber recibido la cantidad de bolivares(Bs):") + AliDir(nTvp-nTvd	,"@E 999,999,999.99")+" ("+cRet1,oArial11N)
	
	If Len(cRet2) = 0
		oPrint:Say(nLi,360 , ".****)"								,oArial11N)
	Endif
	
	If Len(cRet2) > 0
		nLi:=nLi+80
		oPrint:Say(nLi,360 , cRet2+".****)"						,oArial11N)
	Endif
	
	nLi:=nLi+80
	oPrint:Say(nLi,360 , OemToAnsi("por la cancelacion del concepto de vacaciones correspondiente al periodo antes mencionado, el cual acepto a mi"),oArial11N)
	nLi:=nLi+80
	oPrint:Say(nLi,360 , OemToAnsi("entera satisfaccion.") ,oArial11N)
	nLi:=nLi+200
	
	oPrint:Say(nLi,860, OemToAnsi("FIRMA DEL TRABAJADOR:")	,oArial11N)
	oPrint:Box(nLi+35,1470,nLi+36,2400)
	nLi:=nLi+160
	
	oPrint:Say(nLi,1295, OemToAnsi("C.I.:")						,oArial11N)
	oPrint:Say(nLi,1470, TransForm(SRA->RA_RG, "@R 999.999.999"),oArial11N) //nro C.I.
	nLi:=nLi+160
	//////////////////////////////////////
	oPrint:Box(nLi-40 ,100,nLi+60,2450)
	oPrint:Line(nLi-40,850,nLi+60,850)
	oPrint:Line(nLi-40,1650,nLi+60,1650)
	//////////////////////////////////////
	
	oPrint:Say(nLi,160, OemToAnsi("ELABORADO POR")					,oArial11N)
	oPrint:Say(nLi,880, OemToAnsi("REVISADO POR")					,oArial11N)
	oPrint:Say(nLi,1680, OemToAnsi("APROBADO POR")					,oArial11N)
	
	nLi:=nLi+80
	
	//////////////////////////////////////
	oPrint:Box(nLi-20 ,100,nLi+100,2450)
	oPrint:Line(nLi-20,850,nLi+100,850)
	oPrint:Line(nLi-20,1650,nLi+100,1650)
	//////////////////////////////////////
	oPrint:Say(nLi+20,160, 	cPrepar								,oArial11N) //ELABORADO POR
	oPrint:Say(nLi+20,880, 	cRevis								,oArial11N) //REVISADO POR
	oPrint:Say(nLi+20,1680, cAprov								,oArial11N) //APROBADO POR
Endif
nLi := 1

Return



Static Function AliDir(nVlr,cPicture)
Local cRet:="",cCont:=""
Local nCont:=0

If Len(Alltrim(Str(Int(nVlr))))==9
	cRet:=PADL(" ",1," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==8
	cRet:=PADL(" ",3," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==7
	cRet:=PADL(" ",5," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==6
	cRet:=PADL(" ",8," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==5
	cRet:=PADL(" ",10," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==4
	cRet:=PADL(" ",12," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==3
	cRet:=PADL(" ",15," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==2
	cRet:=PADL(" ",17," ")+alltrim(Transform(nVlr,cPicture))
ElseIf Len(Alltrim(Str(Int(nVlr))))==1
	cRet:=PADL(" ",19," ")+alltrim(Transform(nVlr,cPicture))
Endif
If At("*",cRet)>0
	cCont:=Alltrim(cRet)
	cRet:=""
	For nCont:=1 To Len(cCont)
		If Substr(cCont,nCont,1)=="*"
			cRet+="0"
		Else
			cRet+=Substr(cCont,nCont,1)
		Endif
	Next
Endif
Return cRet