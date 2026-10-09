#INCLUDE "QMTR300.Ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "Report.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QMTR300   ºAutor  ³Leandro Sabino      º Data ³  12/07/06	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relacao de instrumentos        							  º±±
±±º          ³ (Versao Relatorio Personalizavel)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                            
Function QMTR300()

	Local oReport := ReportDef()                    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                  ³
	//³ mv_par01   : Instrumento Inicial                      ³
	//³ mv_par02   : Instrumento Final                        ³
	//³ mv_par03   : Periodo Inicial                          ³
	//³ mv_par04   : Periodo Final                            ³
	//³ mv_par05   : Departamento Inicial                     ³
	//³ mv_par06   : Departamento Final                       ³
	//³ mv_par07   : Orgao Calibrador Todos/Interno/Externo   ³
	//³ mv_par08   : Orgao Calibrador interno de              ³
	//³ mv_par09   : Orgao Calibrador interno ate             ³
	//³ mv_par10   : Orgao Calibrador externo de              ³
	//³ mv_par11   : Orgao Calibrador externo ate             ³
	//³ mv_par12   : Usu rio de                               ³
	//³ mv_par13   : Usu rio ate                              ³
	//³ mv_par14   : Status de                                ³
	//³ mv_par15   : Status ate                               ³
	//³ mv_par16   : Quebra Depto / Pagina                    ³
	//³ mv_par17   : Imprime Legenda do Status                ³
	//³ mv_par18   : Imprime Nao Habilitado                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
	Pergunte("QMR300",.F.) 
	oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 12/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTR240                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

	Local aOrdem	:= {}
	Local cDesc1   := OemToAnsi( STR0001 ) // "Este programa ira emitir a listagem de"
	Local cDesc2   := OemToAnsi( STR0002 ) // "instrumentos"
	Local ctitulo  := OemToAnsi( STR0005 ) // "Listagem de Instrumento"
	Local oSection1 
	Local oSection2 

	//Definicao de Indices
	Aadd( aOrdem, OemToAnsi(STR0012) ) // "Departamento"
	Aadd( aOrdem, OemToAnsi(STR0013) ) // "Instrumento"
	Aadd( aOrdem, OemToAnsi(STR0011) ) // "Departamento/Instrumento"

	DEFINE REPORT oReport NAME "QMTR300" TITLE cTitulo PARAMETER "QMR300" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)
	oReport:SetLandscape(.T.)

	oSection1 := TRSection():New(oReport,OemToAnsi(STR0011),{"QM2"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) //Departamento/Instrumento
	DEFINE CELL NAME "cDEPTO"   OF oSection1 ALIAS "QM2" TITLE OemToAnsi(STR0014) SIZE 50 

	DEFINE SECTION oSection2 OF oSection1 TABLES "QM2" TITLE TitSx3("QM2_INSTR")[1]
	DEFINE CELL NAME "cINSTR"  OF oSection2 ALIAS "QM2" TITLE TitSx3("QM2_INSTR")[1]  SIZE 20  //Instrumento
	DEFINE CELL NAME "cFABR"   OF oSection2 ALIAS "QM2" TITLE TitSx3("QM2_FABR")[1]   SIZE 20 //Fabrincante
	DEFINE CELL NAME "cFREQAF" OF oSection2 ALIAS "QM2" TITLE TitSx3("QM2_FREQAF")[1] SIZE 04 //Frequencia em dias
	DEFINE CELL NAME "cOrgao"  OF oSection2 ALIAS "QM2" TITLE OemToAnsi(STR0022)      SIZE 20  LINE BREAK //Orgao Calibrador
	DEFINE CELL NAME "ccampo"  OF oSection2 ALIAS "QM2" TITLE OemToAnsi(STR0026) 	  SIZE 20 //Procedimento
	DEFINE CELL NAME "cDTULTC" OF oSection2 ALIAS "QM2" TITLE OemToAnsi(STR0019)+" "+OemToAnsi(STR0020) SIZE 08 //Dt. Ult. Calib.
	DEFINE CELL NAME "cVALDAF" OF oSection2 ALIAS "QM2" TITLE OemToAnsi(STR0019)+" "+OemToAnsi(STR0021) SIZE 08 //Dt. Prox. Calib.
	DEFINE CELL NAME "cSG"     OF oSection2 ALIAS "QM2" TITLE OemToAnsi(STR0027)      SIZE 03 //"SG"
	DEFINE CELL NAME "cCUSTO"  OF oSection2 ALIAS "QM2" TITLE OemToAnsi(STR0028)      SIZE (TamSx3("QM2_CUSTO")[1]) //CUSTO
	DEFINE CELL NAME "cLOCAL"  OF oSection2 ALIAS "QM2" TITLE TitSx3("QM2_LOCAL")[1]  SIZE (TamSx3("QM2_LOCAL")[1]) //Localizacao
	DEFINE CELL NAME "cLEIT"   OF oSection2 ALIAS "QM2" TITLE TitSx3("QM2_LEIT")[1]   SIZE (TamSx3("QM2_LEIT") [1])  //Leitura
	DEFINE CELL NAME "cTIPO"   OF oSection2 ALIAS "QM2" TITLE TitSx3("QM1_TIPO")[1]   SIZE 20    //Familia
	DEFINE CELL NAME "cDESQM1" OF oSection2 ALIAS "QM2" TITLE TitSx3("QM1_DESCR")[1]  SIZE 38 //Descricao
	DEFINE CELL NAME "cSTATUS" OF oSection2 ALIAS "QM2" TITLE TitSx3("QM2_STATUS")[1] SIZE (TamSx3("QM2_STATUS")[1])//STATUS
	DEFINE CELL NAME "cREVINS" OF oSection2 ALIAS "QM2" TITLE OemToAnsi(STR0029)      SIZE 02 //Revisao

Return oReport


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrintReport   ³ Autor ³ Leandro Sabino   ³ Data ³ 12/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprimir os campos do relatorio                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrintReport(ExpO1)  	     	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QMTR240                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                  
Static Function PrintReport(oReport) 

	Local aArea      := GetArea()
	Local aInstru     := {}
	Local cAliasQry   := GetNextAlias()
	Local cChave      := ""   // Auxiliar para quebra de subtotal
	Local cDepto      := ""   
	Local cExpQM2     := "%%"
	Local CINSTR      := ""
	Local cOrgao      := ""
	Local nCntParc    := 0    // Contador para subtotal
	Local nCntTot     := 0    // Contador para total
	Local nLin        := 0
	Local nOrdem      := oReport:Section(1):GetOrder() 
	Local nTm         := 1
	Local oSection1   := oReport:Section(1)
	Local oSection2   := oReport:Section(1):Section(1)
	Local TRB_CUSTO   := "" 
	Local TRB_DEPTO   := ""     
	Local TRB_DESPTO  := "" 
	Local TRB_DESQM1  := "" 
	Local TRB_FABR    := "" 
	Local TRB_FREQAF  := ""     
	Local TRB_INSTR   := "" 
	Local TRB_LEIT    := "" 
	Local TRB_QM2CTS  := "" 
	Local TRB_RESP    := "" 
	Local TRB_REVINS  := ""     
	Local TRB_SGUARD  := "" 
	Local TRB_STATUS  := ""     
	Local TRB_TDESCR  := "" 
	Local TRB_TIPO    := "" 
	Local TRB_VALDAF  := ""

	dbSelectArea( "QM2" )
	dbSetOrder(1)

	MakeSqlExpr(oReport:uParam)
		
	cChave := "%QM2_FILIAL,QM2_INSTR,QM2_REVINV%"	
		
	If !Empty(oReport:Section(1):GetSQLExp("QM2"))
		cExpQM2 := "% AND " + oReport:Section(1):GetSQLExp("QM2") + "%"
	EndIf

	BeginSQL alias cAliasQry //"TRB"

		SELECT *
		FROM %table:QM2% QM2, %table:QM1% QM1 					
		WHERE 
			QM2.QM2_FILIAL = %xFilial:QM2% AND 
			QM2.QM2_INSTR  BetWeen %Exp:mv_par01%       AND %Exp:mv_par02% AND  
			QM2.QM2_VALDAF BetWeen %Exp:DtoS(mv_par03)% AND %Exp:DtoS(mv_par04)% AND  
			QM2.QM2_DEPTO  BetWeen %Exp:mv_par05%       AND %Exp:mv_par06% AND  
			QM2.QM2_RESP   BetWeen %Exp:mv_par12%       AND %Exp:mv_par13% AND  
			QM2.QM2_TIPO  = QM1.QM1_TIPO AND 
			QM2.%notDel% AND
			QM1.%notDel%
			%Exp:cExpQM2%
		ORDER BY %Exp:cChave%      

	EndSql

	While (cAliasQry)->(!Eof())

		If (cAliasQry)->QM2_FILIAL+(cAliasQry)->QM2_INSTR <> cInstr
				Aadd(aInstru,{(cAliasQry)->QM2_FILIAL,(cAliasQry)->QM2_INSTR,(cAliasQry)->QM2_REVINS,;
					(cAliasQry)->QM2_VALDAF,(cAliasQry)->QM2_FREQAF,(cAliasQry)->QM2_DEPTO,(cAliasQry)->QM2_RESP,;
					(cAliasQry)->QM2_TIPO,(cAliasQry)->QM2_FABR,(cAliasQry)->QM2_STATUS,;
					(cAliasQry)->QM2_LOCAL,(cAliasQry)->QM2_SGUARD,(cAliasQry)->QM2_CUSTO,(cAliasQry)->QM2_LEIT,(cAliasQry)->QM1_PROCAL,;
					(cAliasQry)->QM1_DESCR,(cAliasQry)->QM2_REVINV})
		Endif	
		cInstr := (cAliasQry)->QM2_FILIAL+(cAliasQry)->QM2_INSTR
		dbSkip()
	Enddo    

	If nOrdem == 1 		//Ordena por Depto
		aSort(aInstru,,,{|x,y| x[6] < y[6]})
	ElseIf nOrdem == 2 //Instrumento
		aSort(aInstru,,,{|x,y| x[1]+x[2]< y[1]+y[2]})
	ElseIf nOrdem == 3 //Instrumento/Depto
		aSort(aInstru,,,{|x,y| x[6]+x[1]+x[2] < y[6]+y[1]+y[2]})
	Endif

	If Len(aInstru) > 0
		cChave := aInstru[1][6]
	Endif

	dbSelectArea("QM2")
	QM2->(dbSetOrder(1))	

	While nTm <= Len(aInstru) 

		TRB_INSTR	:= aInstru[nTm][2]
		TRB_REVINS	:= aInstru[nTm][3]
		TRB_VALDAF	:= aInstru[nTm][4]
		TRB_FREQAF	:= aInstru[nTm][5]
		TRB_DEPTO	:= aInstru[nTm][6]
		TRB_RESP	:= aInstru[nTm][7]
		TRB_TIPO	:= aInstru[nTm][8]                                             	
		TRB_FABR	:= aInstru[nTm][9]
		TRB_STATUS	:= aInstru[nTm][10]
		TRB_LOCAL	:= aInstru[nTm][11]
		TRB_SGUARD	:= aInstru[nTm][12]
		TRB_QM2CTS  := aInstru[nTm][13]
		TRB_LEIT 	:= aInstru[nTm][14] 
		TRB_REVINV	:= aInstru[nTm][17] 

		QM2->(Dbseek(xfilial("QM2")+TRB_INSTR+TRB_REVINV))  // posiciona QM2 para relatorio personalizado.

		TRB_TDESCR	:= aInstru[nTm][15]
		TRB_DESQM1 	:= aInstru[nTm][16]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico O.C. interno e externo                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par07 == 1
			If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,TRB_INSTR,TRB_REVINS)
				nTm++
				dbSkip()
				Loop
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico O.C. interno                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par07 == 2
			If ! Calibrador(1,mv_par08,mv_par09,,,TRB_INSTR,TRB_REVINS)
				nTm++
				dbSkip()
				Loop
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico O.C. externo                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par07 == 3
			If ! Calibrador(2,,,mv_par10,mv_par11,TRB_INSTR,TRB_REVINS)
				nTm++
				dbSkip()
				Loop
			EndIf
		EndIf

		
		If mv_par18 == 1 //Imprime Não Habilitados...
			If TRB_STATUS < mv_par14 .or. TRB_STATUS > mv_par15
				nTm++
				dbSkip()
				Loop	
			Endif
		Else
			If !QMTXSTAT(TRB_STATUS)
				nTm++
				dbSkip()
				Loop
			Endif
		Endif	
		
		If TRB_TIPO < mv_par19 .or. TRB_TIPO > mv_par20
			nTm++
			dbSkip()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura o departamento no QAD - Centro de Custo.             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("QAD")
		dbSetOrder(1)
		If dbSeek( xFilial("QAD") + TRB_DEPTO )
			TRB_CUSTO := QAD->QAD_CUSTO
			TRB_DESPTO := Alltrim(QAD->QAD_DESC)
		Else
			TRB_CUSTO := ""
			TRB_DESPTO := ""
		Endif    

		dbSelectArea( "QM1" )

		oSection1:Init()
		
		QAD->(dbSeek( xFilial("QAD") + cChave ))
	
		If TRB_DEPTO <> cDepto
			If nCntParc <> 0
				oReport:SkipLine(1) 
				oReport:PrintText(OemToAnsi(STR0007)+Str(nCntParc,5),oReport:Row(),025) //"Subtotal.....................:"
				oReport:SkipLine(1)	
			Endif
			oSection1:Finish()
			oSection2:Finish()
			oSection1:Init()
			If mv_par16 == 1 
				oSection1:SetPageBreak(.T.) 
			Endif
			oSection1:Cell("cDEPTO"):SetValue(TRB_DEPTO+" - "+TRB_DESPTO)		
			oSection1:PrintLine()
			oSection2:Init()
			nCntParc := 0    // Contador para subtotal
		Endif

		If !Empty(TRB_SGUARD)
			oSection2:Cell("cSG"):SetValue(SubStr(TRB_SGUARD,1,3))		
		Else
			oSection2:Cell("cSG"):SetValue("")			
		Endif	

		cOrgao	:= ""
		nLin 	:= 0
		
		dbSelectArea("QMK")
		dbSetOrder(1)
		If dbSeek(xFilial()+TRB_TIPO)
			dbSelectArea("QMR")
			dbSetOrder(1)
			If dbSeek(xFilial()+TRB_INSTR+TRB_REVINS)
				While !Eof() .And. xFilial()+TRB_INSTR+TRB_REVINS == QMR->(QMR_FILIAL+QMR_INSTR+QMR_REVINS)
					dbSelectArea("QM9")
					dbSetOrder(1)
					If dbSeek(xFilial()+QMR->QMR_ESCALA)
						If QM9->QM9_ORGAFE == "I"
							cOrgao += IIf(nLin == 0,STR0015,"/ "+STR0015)	//Interno
						Else
							cOrgao += IIf(nLin == 0,STR0016,"/ "+STR0016)	//Externo
						Endif
					Endif
					nLin++
					dbSelectArea("QMR")
					dbSkip()
				Enddo
				oSection2:Cell("cOrgao"):SetValue(cOrgao)
			Endif
		Endif	   	
		
		//Nao considera revisao do instrumento, ou seja, uma vez calibrado o codigo do instrumento
		//essa coluna sera impressa
		dbSelectArea("QM6")
		dbSetOrder(4)
		If dbSeek(xFilial()+TRB_INSTR)
			oSection2:Cell("cDTULTC"):SetValue(DtoC(QM6->QM6_DATA))
		Else              
			oSection2:Cell("cDTULTC"):SetValue(STR0017)//"S/Calibra"
		Endif     
		
		oSection2:Cell("cINSTR"):SetValue(TRB_INSTR)
		oSection2:Cell("cFABR"):SetValue(TRB_FABR)
		oSection2:Cell("cFREQAF"):SetValue(TRB_FREQAF)
		oSection2:Cell("ccampo"):SetValue(TRB_TDESCR) 
		oSection2:Cell("cVALDAF"):SetValue(STOD(TRB_VALDAF))		
		oSection2:Cell("cCUSTO"):SetValue(TRB_QM2CTS)		
		oSection2:Cell("cLOCAL"):SetValue(TRB_LOCAL)
		oSection2:Cell("cLEIT"):SetValue(TRB_LEIT)
		oSection2:Cell("cTIPO"):SetValue(TRB_TIPO)
		oSection2:Cell("cDESQM1"):SetValue(TRB_DESQM1)
		oSection2:Cell("cSTATUS"):SetValue(TRB_STATUS)
		oSection2:Cell("cREVINS"):SetValue(Alltrim(TRB_REVINS))

		nCntParc++
		nCntTot++
		nTm++
		cDepto := TRB_DEPTO
		
		oSection2:PrintLine() 
		dbSkip()	
	EndDo

	If Len(aInstru) > 0 .And. nCntTot > 0
	
		oReport:SkipLine(1) 
		oReport:PrintText(OemToAnsi(STR0007)+Str(nCntParc,5),oReport:Row(),025)// "Subtotal.....................:"
		oReport:SkipLine(2)	
		oReport:PrintText(OemToAnsi(STR0008)+Str(nCntTot,5),oReport:Row(),025) //"Total........................:"
		oReport:SkipLine(1)	

		If mv_par17 == 1	
			oReport:SkipLine(1) 
			oReport:FatLine()
			oReport:PrintText(OemToAnsi(STR0024),oReport:Row(),055) // Legenda Status
			oReport:SkipLine(1)	
			oReport:FatLine()

			dbSelectArea("QMP")
			dbSetOrder(1)
			dbGoTop()
			While QMP->(!Eof())
				oReport:SkipLine(1) 
				oReport:PrintText(UPPER(QMP->QMP_STATUS)+" - "+Alltrim(QMP->QMP_DESCR),oReport:Row(),025) // Legenda Status
				dbSkip()
			Enddo
		Endif
	Endif

	oSection1:Finish()
	(cAliasQry)->(DbCloseArea())
	RestArea(aArea)

Return NIL
