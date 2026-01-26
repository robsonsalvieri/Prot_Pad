#INCLUDE "QMTR340.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QMTR340  ³ Autor ³ Denis Martins         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao dos graficos MSA 3 Edicao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QMTR340(lBrow,nChart)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Chamada da mBrowse                                 ³±±
±±³          ³ ExpN1 = Imprime Tipo de Grafico                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAQMT                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Denis Martins³        ³      ³ Inclusao dos dados na moldura          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function QMTR340(lBrow,nChart,cInstrt,cRevvt,cDQM2cr,lBiCaudal,cPngGrafic,aTesteHipo)
Local oPrint	   := Nil

Default aTesteHipo := {}
Default cDQM2cr    := QM2->QM2_DESCR
Default cInstrt    := QM2->QM2_INSTR
Default cRevvt     := QM2->QM2_REVINS
Default lBiCaudal  := .F.
Default lBrow      := .F.
Default nChart     := 1

Private cArqDeBi    := ""
Private cArqDeCt    := ""
Private cArqDeL1    := ""
Private cArqDeL2    := ""
Private cArqDeLn    := ""
Private cArqDeLr    := ""
Private cArqDeLt    := ""
Private cArqDeTe    := ""
Private cDir        := GetMv("MV_QDIRGRA")
Private lExistChart := FindFunction("QIEMGRAFIC") .AND. GetBuild() >= "7.00.170117A" //controle se executa o grafico modelo novo ou por DLL

// Verifica se o diretorio do grafico e um  diretorio Local
If !QA_VerQDir(cDir) 
	Return
EndIf

oPrint	:= TMSPrinter():New(STR0002) //"MSA 3Ed."

If nChart == 3
	oPrint:SetLandScape()
Else
	oPrint:SetPortrait()
Endif	

MsgRun(OemToAnsi(STR0001),"",{|| CursorWait(), Q340MtRel(oPrint,nChart,cInstrt,cRevvt,cDQM2cr,lBiCaudal,cPngGrafic) ,CursorArrow()}) //"Gerando Impressao, Aguarde..."

oPrint:EndPage() 		// Finaliza a pagina

oPrint:Preview()  		// Visualiza antes de imprimir

//Deleta os arquivos temporarios .BMP

If File(cDir+cArqDeTe)
	FErase (cDir+cArqDeTe) 			
Endif

If File(cDir+cArqDeTe)
	FErase (cDir+cArqDeTe) 			
Endif

If File(cDir+cArqDeL1)
	FErase (cDir+cArqDeL1) 			
Endif

If File(cDir+cArqDeLn)
	FErase (cDir+cArqDeLn) 			
Endif

If File(cDir+cArqDeL2)
	FErase (cDir+cArqDeL2) 			
Endif

If File(cDir+cArqDeCt)
	FErase (cDir+cArqDeCt) 			
Endif

If File(cDir+cArqDeLr)
	FErase (cDir+cArqDeLr) 			
Endif
If File(cDir+cArqDeBi)
	FErase (cDir+cArqDeBi) 			
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Q340MtRel³ Autor ³ Denis Martins         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³MSA 3 EDICAO                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q340MtRel(ExpO1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Flag para impressao do grafico                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTR340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Q340MtRel(oPrint, nChart, cInstrt, cRevvt, cDQM2cr,lBiCaudal,cPngGrafic)
Local i 	:= 1
Local lin 	:= 0

Private oFont08  := TFont():New("Arial", 08, 08, , .F., , , , .T., .F.)
Private oFont08b := TFont():New("Arial", 08, 08, , .T., , , , .T., .F.)
Private oFont10  := TFont():New("Arial", 10, 10, , .F., , , , .T., .F.)
Private oFont12  := TFont():New("Arial", 12, 12, , .F., , , , .T., .F.)
Private oFont12b := TFont():New("Arial", 12, 12, , .T., , , , .T., .F.)
Private oFont16  := TFont():New("Arial", 16, 16, , .F., , , , .T., .F.)
Private oFont17b := TFont():New("Arial", 17, 17, , .T., , , , .T., .F.)

oPrint:StartPage() 		// Inicia uma nova pagina

Q340CALHO(oPrint,i,nChart, cInstrt, cRevvt, cDQM2cr) 			// Funcao que monta o cabecalho

lin := Q340Dtail(oPrint,i,nChart,cInstrt, cRevvt, cDQM2cr,lBiCaudal,cPngGrafic)	// Funcao que monta os detalhes

lin := 150

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Q340CALHO ³ Autor ³ Denis Martins         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho do relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q340CALHO(ExpO1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QPPR170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Q340CALHO(oPrint,i,nChart,cInstrt,cRevvt,cDQM2cr)
Local cTiMsa:= ""

If nChart == 1
	cTiMsa := OemToAnsi(STR0006) //"TENDENCIA"
ElseIf nChart == 2
	cTiMsa := OemToAnsi(STR0007) //"LINEARIDADE"
ElseIf nChart == 3
	cTiMsa := OemToAnsi(STR0008) //"ESTABILIDADE"
Endif

If nChart <> 3
	oPrint:Say(075,900,OemToAnsi(STR0003)+cTiMsa,oFont16 ) //"GRAFICO"
	
	//Box Cabecalho
	oPrint:Box( 150, 80, 290, 2350 )
	oPrint:Line( 150, 640, 289, 640 )   	// vertical - revisao.. 	 
	oPrint:Line( 150, 930, 289, 930 )   	// vertical - descricao..	
	// Descricao do Cabecalho
	// 1a Linha
	oPrint:Say(160,0090,OemToAnsi(STR0004),oFont12b ) //"Instrumento"
	oPrint:Say(212,0090,Alltrim(cInstrt),oFont12 )
	
	oPrint:Say(160,650,OemToAnsi(STR0005),oFont12b ) //"Revisao"
	oPrint:Say(212,650,Alltrim(cRevvt),oFont12 )

	oPrint:Say(160,940,OemToAnsi(STR0016),oFont12b ) //"Descricao"
	oPrint:Say(212,940,Alltrim(cDQM2cr),oFont12 )

Else
	oPrint:Say(075,1010,OemToAnsi(STR0003)+cTiMsa+"/"+OemToAnsi(STR0006),oFont16 ) //"GRAFICO" "/TENDENCIA"
	oPrint:Box( 150, 80, 290, 3065 )
	oPrint:Line( 150, 720, 289, 720 )   	// vertical    
	oPrint:Line( 150, 1020, 289, 1020 )   	// vertical    	
	oPrint:Say(160,0090,OemToAnsi(STR0004),oFont12b ) //"Instrumento"
	oPrint:Say(212,0090,Alltrim(cInstrt),oFont12 )
	
	oPrint:Say(160,730,OemToAnsi(STR0005),oFont12b ) //"Revisao"
	oPrint:Say(212,730,Alltrim(cRevvt),oFont12 )			

	oPrint:Say(160,1030,OemToAnsi(STR0016),oFont12b ) //"Descricao"
	oPrint:Say(212,1030,Alltrim(cDQM2cr),oFont12 )

Endif

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Q340Dtail³ Autor ³ Denis Martins         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Detalhes do relatorio de MSA                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Q340Dtail(ExpO1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±³          ³ ExpN2 = Flag para impressao do grafico                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTR340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Q340Dtail(oPrint,i,nChart,cInstrt,cRevvt,cDQM2cr,lBiCaudal,cPngGrafic)
Local lin		 := 580
Local cArqOrTe   := ""
Local cArqOrL1   := ""
Local cArqOrLn   := ""
Local cArqOrL2   := ""
Local cArqOrLt   := ""
Local cArqOrLr   := ""
Local oQLGrafico := GraficosQualidadeX():New()

Default lBiCaudal := .F.

If nChart == 1
	If lExistChart //controle se executa o grafico modelo novo ou por DLL
		cImgGraf := oQLGrafico:retorna_Local_Imagens_Graficos()+cPngGrafic
		oPrint:SayBitmap(600, 30, cImgGraf, 2320, 1150)
		If len(aTesteHipo) > 0
			oPrint:Say(1995,1040,OemToAnsi(STR0009),oFont16 ) //"RESULTADOS"
			lin := 2200
			
			//Box da análise numérica
			oPrint:Box( lin,	   760, 2290, 1700 )
			oPrint:Say( lin+10,	   930, OemToAnsi(STR0023),     oFont17b ) // "Análise de Tendência"

			oPrint:Box(  lin+90,   760, 2370, 1700 ) 
			oPrint:Say(  lin+110,  880, OemToAnsi(STR0024),     oFont12b ) // "Tendência ="
			oPrint:Line( lin+90,  1200, 2370, 1200 )                       // Linha central
			oPrint:Say(  lin+110, 1220, aTesteHipo[1],          oFont12 )

			oPrint:Box(  lin+170,  760, 2450, 					1700 ) 	    
			oPrint:Say(  lin+190,  910, OemToAnsi(STR0025),	    oFont12b ) 	// "Sigma R ="
			oPrint:Line( lin+170, 1200, 2450, 					1200 )   	// Linha Central
			oPrint:Say(  lin+190, 1220, aTesteHipo[2],			oFont12 ) 	

			oPrint:Box(  lin+250,  760, 2530, 					1700 ) 		
			oPrint:Say(  lin+270,  910, OemToAnsi(STR0026),	    oFont12b ) 	// "Sigma B ="
			oPrint:Line( lin+250, 1200, 2530, 					1200 )  	// Linha central
			oPrint:Say(  lin+270, 1220, aTesteHipo[3],			oFont12 ) 	

			oPrint:Box(  lin+330,  760, 2610, 					1700 )		// Caixa de análise
			oPrint:Line( lin+330, 1200, 2610, 					1200 ) 		// Linha Central
			oPrint:Say(  lin+345,  840, OemToAnsi(STR0027), 	oFont12b )  // "Limite inferior"
			oPrint:Say(  lin+345, 1220, OemToAnsi(STR0028), 	oFont12b )  // "Limite Superior"

			oPrint:Box(  lin+410,  760, 2690, 					1700 )	
			oPrint:Line( lin+410, 1200, 2690, 					1200 ) 		// Linha Central
			oPrint:Say(  lin+430,  880, aTesteHipo[4], 			oFont12 )   // Limite Inferior
			oPrint:Say(  lin+430, 1220, aTesteHipo[5], 			oFont12 )   // Limite Superior

			oPrint:Box(  lin+490,  760, 2770, 					1700 )	
			oPrint:Say(  lin+510,  850, aTesteHipo[6], 			oFont08b,,CLR_HRED ) // Limite Superior

		EndIf
		lin := 2700
	Else
		If Right(cDir,1) <> "\"
			cDir += "\"
		Endif
		If File(cDir+"TENDE.BMP")            
			cArqOrTe := "TENDE.BMP"
			cArqDeTe := CriaTrab(, .F.) + ".BMP"
			fRename(cDir+cArqOrTe,cDir+cArqDeTe)
			oPrint:SayBitmap(350,30,cDir+cArqDeTe,2320,1150) //cDir+"TENDE.BMP"
		Endif
		oPrint:Say(1542,1099,OemToAnsi(STR0009),oFont16 ) //"RESULTADOS"
		
		lin := 1635
		If !lBiCaudal
			If File(cDir+"LEG1.BMP")
				cArqOrL1 := "LEG1.BMP"
				cArqDeL1 := CriaTrab(, .F.) + ".BMP"
				fRename(cDir+cArqOrL1,cDir+cArqDeL1)
				oPrint:SayBitmap(lin,854,cDir+cArqDeL1,870,1528)
			Endif  
		Else	
			If File(cDir+"LEGD.BMP")
				cArqOrL1 := "LEGD.BMP"
				cArqDeBi := CriaTrab(, .F.) + ".BMP"
				fRename(cDir+cArqOrL1,cDir+cArqDeBi)
				oPrint:SayBitmap(lin,854,cDir+cArqDeBi,870,1528)
			Endif	
		Endif	
	EndIf
Elseif nChart == 2

	If lExistChart //controle se executa o grafico modelo novo ou por DLL
		cImgGraf := oQLGrafico:retorna_Local_Imagens_Graficos()+cPngGrafic
		//Imprime o grafico no relatorio
			 //SayBitmap( < nLinha>, < nCol>, < cBitmap>, [ nWidth], [ nHeight] )
		oPrint:SayBitmap(600, 30, cImgGraf, 2320, 1150)
	Else
		If Right(cDir,1) <> "\"
			cDir += "\"
		Endif
		If File(cDir+"LINEA.BMP")
			cArqOrLn := "LINEA.BMP"
			cArqDeLn := CriaTrab(, .F.) + ".BMP"
			fRename(cDir+cArqOrLn,cDir+cArqDeLn)
			oPrint:SayBitmap(600,30,cDir+cArqDeLn,2320,1150)
		Endif
	Endif

	If len(aTesteHipo) > 0

		oPrint:Say(1995,800,OemToAnsi(STR0014),oFont16 ) //"ANALISE NUMERICA - RESULTADOS"
		lin := 2200
		
		//Box da análise numérica
		oPrint:Box( lin, 330, 2290, 1950 )
		oPrint:Say( lin,870,OemToAnsi(STR0017),oFont17b ) // 'Teste de Hipóteses'

		oPrint:Box(  lin+90,  330,  2370, 1950 ) // Caixa de Hipóteses
		oPrint:Line( lin+90,  1140, 2370, 1140 ) // Linha central
		oPrint:Say(  lin+100, 360, OemToAnsi(STR0018) + " a = 0"     ,oFont10 ) // 'Hp: '
		oPrint:Say(  lin+100, 1170,OemToAnsi(STR0018)+" b = 0" 	     ,oFont10 ) // 'Hp: '
		oPrint:Say(  lin+100, 1500,OemToAnsi(STR0022)+ aTesteHipo[7] ,oFont10 ) // 'VE = '

		oPrint:Box(  lin+170,  330, 2450, 					1950 ) 	    // Caixa de Tendências
		oPrint:Say(  lin+180,  360, OemToAnsi(STR0019),		oFont12 ) 	// 'T =' (a)
		oPrint:Line( lin+170,  530, 2450, 					530 ) 
		oPrint:Say(  lin+180,  540, aTesteHipo[1],			oFont12 )	// a
		oPrint:Line( lin+170, 1140, 2450, 					1140 )   	// Linha Central
		oPrint:Say(  lin+180, 1170, OemToAnsi(STR0019),		oFont12 ) 	// 'T =' (b)
		oPrint:Line( lin+170, 1350, 2450, 					1350 ) 
		oPrint:Say(  lin+180, 1360, aTesteHipo[2],			oFont12 ) 	// b

		oPrint:Box(  lin+250,  330, 2530, 					1950 ) 		// Caixa de T Crítico
		oPrint:Say(  lin+268,  360, OemToAnsi(STR0020),		oFont12 ) 	// 'T Crítico ' (a)
		oPrint:Line( lin+250,  530, 2530, 					530 ) 
		oPrint:Say(  lin+260,  540, aTesteHipo[3],			oFont12 ) 	// a
		oPrint:Line( lin+250, 1140, 2530, 					1140 )  	// Linha central
		oPrint:Say(  lin+268, 1170, OemToAnsi(STR0020),		oFont12 ) 	// 'T Crítico ' (b)
		oPrint:Line( lin+250, 1350, 2530,					1350 )
		oPrint:Say(  lin+260, 1360, aTesteHipo[4],			oFont12 ) 	// b

		oPrint:Box(  lin+330,  330, 2610, 					1950 )		// Caixa de análise
		oPrint:Say(  lin+345, 1050, OemToAnsi(STR0021), 	oFont17b )  // 'Análise'

		oPrint:Box(  lin+410,  330, 2800, 					1950 )		// Caixa de Mensagens
		oPrint:Line( lin+410, 1140, 2800, 					1140 ) 		// Linha Central
		oPrint:Say(  lin+420,  360, aTesteHipo[5], oFont08b,,CLR_HRED ) // Mensagem a 
		oPrint:Say(  lin+420, 1170, aTesteHipo[6], oFont08b,,CLR_HRED ) // Mensagem b

		lin := 2700

	elseIf File(cDir+"LEG2.BMP")
		cArqOrL2 := "LEG2.BMP"
		cArqDeL2 := CriaTrab(, .F.) + ".BMP"
		fRename(cDir+cArqOrL2,cDir+cArqDeL2)
		oPrint:SayBitmap(lin,405,cDir+cArqDeL2,1535,870)
	EndIf
	
Elseif nChart == 3
	If Right(cDir,1) <> "\"
		cDir += "\"
	Endif
	If File(cDir+"CARTA.BMP")
		cArqOrLt := "CARTA.BMP"
		cArqDeLt := CriaTrab(, .F.) + ".BMP"
		fRename(cDir+cArqOrLt,cDir+cArqDeLt)
		oPrint:SayBitmap(297,30,cDir+cArqDeLt,3050,1000)
	Endif

	If File(cDir+"CARTA2.BMP")
		cArqOrLr := "CARTA2.BMP"
		cArqDeLr := CriaTrab(, .F.) + ".BMP"
		fRename(cDir+cArqOrLr,cDir+cArqDeLr)
		oPrint:SayBitmap(1352,30,cDir+"CARTA2.BMP",3050,1000)
	Endif

	oPrint:EndPage() 		// Finaliza a pagina
	oPrint:StartPage() 		// Inicia uma nova pagina		

	oPrint:Say(075,1010,OemToAnsi(STR0003)+OemToAnsi(STR0008)+"/"+OemToAnsi(STR0006),oFont16 ) //"GRAFICO"

	oPrint:Box( 150, 30, 290, 3065 )
	oPrint:Line( 150, 720, 289, 720 )   	// vertical    
	oPrint:Line( 150, 1020, 289, 1020 )   	// vertical    	
	oPrint:Say(160,0040,OemToAnsi(STR0004),oFont08 ) //"Instrumento"
	oPrint:Say(202,0040,Alltrim(cInstrt),oFont08 )
	
	oPrint:Say(160,730,OemToAnsi(STR0005),oFont08 ) //"Revisao"
	oPrint:Say(202,730,Alltrim(cRevvt),oFont08 )			

	oPrint:Say(160,1030,OemToAnsi(STR0016),oFont08 ) //"Descricao"
	oPrint:Say(202,1030,Alltrim(cDQM2cr),oFont08 )

	lin := 320
	oPrint:Say( lin,1320,Alltrim(OemToAnsi(STR0015)),oFont16 )	//"L E G E N D A"	

	If File(cDir+"LEG1.BMP")
		cArqOrL1 := "LEG1.BMP"
		cArqDeL1 := CriaTrab(, .F.) + ".BMP"
		fRename(cDir+cArqOrL1,cDir+cArqDeL1)
		oPrint:SayBitmap(lin+200,1090,cDir+cArqDeL1,870,1528)
	Endif
Endif

Return lin
