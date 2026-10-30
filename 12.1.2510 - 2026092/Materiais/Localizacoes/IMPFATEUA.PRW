#INCLUDE "PROTHEUS.CH"
#INCLUDE "IMPFATEUA.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³ IMPFATEUA³ Autor ³ Alfredo Medrano     ³ Data ³  27/10/2017   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impresión Facturas  - EUA                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ IMPFATEUA()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Facturación                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alf. Medrano ³27/10/17³DMINA-537  ³Se agrega funcionalidad para impresión³±±
±±³              ³        ³           ³de Factura EUA                        ³±±
±±³ Luis Enriquez³03/11/17³DMINA-537  ³Def. DMINA-913 Se realiza acomodo de  ³±±
±±³              ³        ³           ³columnas de reporte p/ PDF y se hace -³±±
±±³              ³        ³           ³bifurcacion en uso de fun. EXTENSO de ³±±
±±³              ³        ³           ³acuerdo a idioma (EUA).               ³±±
±±³ Alf. Medrano ³27/10/17³DMINA-537  ³En func PrntEncab se quita código que ³±±
±±³              ³        ³           ³no se utiliza como variable cSuc y la ³±±
±±³              ³        ³           ³instancia de la tabla SE4. Se valida  ³±±
±±³              ³        ³           ³los Dbseek de SC5, SC6 y SB1          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function IMPFATEUA()

	Local cPerg  := "FATEUA"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variables utilizadas para parametros                         ³
	//³ mv_par01             // De Factura?                          ³
	//³ mv_par02             // A Factura?                           ³
	//³ mv_par03             // Serie?                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If pergunte(cPerg,.T.)	
		RptStatus({|| RptNota(mv_par01, mv_par02, mv_par03)})   //Llamada a Funcion RptNota
	Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RptNota   ³ Autor ³ Alfredo Medrano       ³ Data ³27/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Imprime Factura                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RptNota(ExpC1,ExpC2,ExpC3)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³ cFatIni   := Fecha Inicio                                  ³±±
±±³          ³ cFatFin   := Fecha Fin                                     ³±±
±±³          ³ cSer      := Serie de Factura                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ IMPFATEUA()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RptNota(cFatIni,cFatFin,cSer)
	Local cLin		:=""
	Local cQuery 	:= ""
	Local cChavec	:= ""
	local nTotalR := 0
	local nConta	:= 0
	Local nValfat := 0
	Local nValNeto:= 0
	Local nFrete 	:= 0
	Local nSeguro	:= 0
	Local nDescon := 0
	Local nDespes := 0
	Local nPag 	:= 0
	Local nNumReg := 0
	Local aImpts 	:= {}
	Local aTotImp	:= {}
	Local nPos 	:= 0
	Local nNum 	:= 0
	Local cCmpSD2 := ""
	Local cProd	:= ""
	Local nTotItm := SuperGetMv( "MV_NUMITEN", .F., "1" ) // número de items permitidos en la Factura

	Private oPrint
	Private oFont08c	:= TFont():New("Courier New",		NIL,  8, NIL, .T., NIL, NIL, NIL, .T., .F.)
	Private cAliasBus	:= criatrab( nil, .f. )
	Private nRen		:=0
	Private nRtam   	:= 50
	Private cBMfranja	:= "franja_factura.BMP"
	Private cBMPLogo 	:= "lgrl_ancho.BMP"

	oPrint := TMSPrinter():New()	   	

	fRHLoadImg(@cBMPLogo)
	fRHLoadImg(@cBMfranja)

	// se obtinen los campos VALIMP 
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(MsSeek("SD2"))
	While ( SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "SD2" )
		If "D2_VALIMP" $ AllTrim(SX3->X3_CAMPO)
			cCmpSD2:= cCmpSD2 + "," + AllTrim(SX3->X3_CAMPO)
		EndIf		
		dbSkip()
	EndDo

	cQuery:= " SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_COND, F2_EMISSAO, F2_VALBRUT, F2_FRETE, F2_SEGURO, "
	cQuery+= " 	F2_DESCONT, F2_DESPESA, F2_VALFAT, F2_VALIMP1, F2_VALIMP3, F2_MOEDA, D2_ITEM, D2_PEDIDO, D2_DOC, "
	cQuery+= " 	D2_SERIE, D2_COD, D2_QUANT, D2_PRCVEN, D2_TOTAL " + cCmpSD2 + ", D2_TES, D2_CLIENTE, D2_LOJA, "
	cQuery+= " 	A1_END, A1_NOME, A1_BAIRRO, A1_EST, A1_MUN, A1_COD_MUN, A1_CGC, A1_COD "
	cQuery+= " FROM " + RetSqlName("SF2") + " SF2 INNER JOIN " + RetSqlName("SD2") + "  SD2 "
	cQuery+= " 	ON D2_DOC = F2_DOC and D2_SERIE = F2_SERIE and D2_CLIENTE = F2_CLIENTE and D2_LOJA = F2_LOJA "
	cQuery+= " 	INNER JOIN " + RetSqlName("SA1") + "  SA1 ON SA1.A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
	cQuery+= " WHERE F2_SERIE = '"+ cSer +"' AND  F2_DOC BETWEEN '" + cFatIni + "' AND  '" + cFatFin + "' AND "
	cQuery+= " 	SF2.D_E_L_E_T_='' AND SD2.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' AND "
	cQuery+= "		SF2.F2_FILIAL = '" + XFILIAL('SF2') + "' AND SA1.A1_FILIAL = '" + XFILIAL('SA1') + "' AND "
	cQuery+= "		SD2.D2_FILIAL = '" + XFILIAL('SD2') + "' "
	cQuery+= " ORDER BY F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO "
	cQuery := ChangeQuery(cQuery)   	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBus,.T.,.T.)
	TcSetField(cAliasBus,"F2_EMISSAO","D",8	,0)
	Count to nTotalR
	(cAliasBus)->(dbgotop())//primer registro de tabla

	SetRegua(Val(cFatFin)-Val(cFatIni)+1)		//Calcula el número de registros a procesar

	While ( cAliasBus )->(!eof())
		nFrete	:= 0
		nSeguro:= 0
		nDescon:= 0
		nDespes:= 0
		nNumReg:= 20 // número de items por página
		nPag := nNumReg
		aImpts := {}
		aTotImp := {}
		oPrint:StartPage() 

		If (cAliasBus)->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) != cChavec
			PrntEncab()// imprime encabezado
		EndIf

		cChavec := ( cAliasBus )->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) 
		If ( cAliasBus )->F2_VALFAT==0 					//Se agregó en 16/11/05 para Facturas Mostrador - Global, llamado AAICO4
			nValFt:= ( cAliasBus )->F2_VALBRUT
		Else
			nValFt:= ( cAliasBus )->F2_VALFAT
		EndIf

		nValNeto := nValFt
		
		cLin := Extenso(nValNeto,.F.,1,,"3",.T.,.F.)
		
		nFrete  := ( cAliasBus )->F2_FRETE
		nSeguro := ( cAliasBus )->F2_SEGURO
		nDescon := ( cAliasBus )->F2_DESCONT
		nDespes := ( cAliasBus )->F2_DESPESA
		
		//===================================
		//Imprime el Detalle de las Facturas
		nConta := 0
		While ( cAliasBus )->(!eof()) .and. ( cAliasBus )->(D2_DOC + D2_SERIE+ D2_CLIENTE + D2_LOJA) == cChavec .and. nConta<= nTotItm 
			oPrint:Say( nRen ,  0110,   AllTrim(( cAliasBus )->D2_COD)	, oFont08c)
			If SB1->(dbseek(xFILIAL("SB1")+( cAliasBus )->D2_COD))
				 cProd := AllTrim(SB1->B1_DESC)
			Else
				cProd := STR0029 //"Producto inexistente "
			EndIf
			oPrint:Say( nRen ,  0350,   cProd	, oFont08c)
			oPrint:Say( nRen ,  1100,   Transform(( cAliasBus )->D2_QUANT,"999,999,999.99")	, oFont08c)
			oPrint:Say( nRen ,  1400,   Transform(( cAliasBus )->D2_PRCVEN,"999,999,999.99")	, oFont08c)
			oPrint:Say( nRen ,  1700,   Transform(( cAliasBus )->D2_TOTAL,"999,999,999.99")	, oFont08c)
			aImpts := TesImpInf(( cAliasBus )->D2_TES)

			For nNum := 1 to Len(aImpts) 			
				If (nPos := Ascan(aTotImp,{|x| AllTrim(x[2]) == Alltrim(aImpts[nNum][6]) })) > 0
					aTotImp[nPos][3] += (cAliasBus)->&(aImpts[nNum][2])
				Else
					aAdd(aTotImp, {aImpts[nNum][1],aImpts[nNum][6], (cAliasBus)->&(aImpts[nNum][2])})
				EndIf
			Next

			nValfat := nValfat+(IIf(( cAliasBus )->D2_TES $ "503/523",0,( cAliasBus )->D2_TOTAL))
			nConta++
			( cAliasBus )->(dbSkip())
			nRen := nRen + nRtam

			If nConta >= nNumReg 
				oPrint:EndPage()
				oPrint:StartPage() 
				PrntEncab()
				nNumReg := nNumReg + nPag
			EndIf

		EndDo
		
		nRen := 2213
		oPrint:Say( nRen ,  100,  REPLICATE("-",130)	, oFont08c)
		nRen := nRen + nRtam

		oPrint:Say( nRen ,   500,  STR0016 , oFont08c) //"Transfer Reference:"
		oPrint:Say( nRen ,  1150,  STR0017 , oFont08c) //"Subtotal"
		oPrint:Say( nRen ,  1580,  STR0024 , oFont08c) //"US$"
		oPrint:Say( nRen ,  1700,  Transform(nValfat,"999,999,999.99")	, oFont08c)
		nRen := nRen + nRtam
		If nDespes > 0	
			oPrint:Say( nRen ,  1150,  STR0018 , oFont08c) //"Gasto"
			oPrint:Say( nRen ,  1580,  STR0024 , oFont08c) //"US$"
			oPrint:Say( nRen ,  1700,  Transform(nDespes,"999,999,999.99")	, oFont08c)
			nRen := nRen + nRtam
		EndIf	
		If nFrete > 0	
		    oPrint:Say( nRen ,  1150,  STR0019 , oFont08c) //"Flete"
			oPrint:Say( nRen ,  1580,  STR0024 , oFont08c) //"US$"
			oPrint:Say( nRen ,  1700,  Transform(nFrete,"999,999,999.99")	, oFont08c)
			nRen := nRen + nRtam
		EndIf	
		If nSeguro > 0			
		    oPrint:Say( nRen ,  1150,  STR0020 , oFont08c) //"Seguro"
			oPrint:Say( nRen ,  1580,  STR0024 , oFont08c) //"US$"
			oPrint:Say( nRen ,  1700,  Transform(nSeguro,"999,999,999.99")	, oFont08c)
			nRen := nRen + nRtam
		EndIf	
		If nDescon > 0	
		    oPrint:Say( nRen ,  1150,  STR0021 , oFont08c) //"Descuento"
			oPrint:Say( nRen ,  1580,  STR0024 , oFont08c) //"US$"
			oPrint:Say( nRen ,  1700,  Transform(nDescon,"999,999,999.99")	, oFont08c)			
			nRen := nRen + nRtam	
		EndIf

		For nNum := 1 to Len(aTotImp)
			If aTotImp[nNum][3] > 0
				oPrint:Say( nRen ,  1150,  STR0022 + Space(1) + Alltrim(aTotImp[nNum][1]) , oFont08c) //"Sales Tax"
				oPrint:Say( nRen ,  1580,  STR0024 , oFont08c) //"US$"
				oPrint:Say( nRen ,  1700,  Transform(aTotImp[nNum][3],"999,999,999.99")	, oFont08c)	
				nRen := nRen + nRtam
			EndIf
		Next

		oPrint:Say( nRen ,  1150,  STR0023 , oFont08c) //"Grand Total"
		oPrint:Say( nRen ,  1580,  STR0024 , oFont08c) //"US$"
		oPrint:Say( nRen ,  1700,  Transform(nValNeto,"999,999,999.99")	, oFont08c)	
		nRen := nRen + nRtam
		nRen := nRen + nRtam	

		oPrint:Say( nRen ,  300,   cLin	, oFont08c)

		nValfat    := 0
		nValNeto 	:= 0	  
		oPrint:EndPage()
		incregua()
	EndDo

	If 	nTotalR > 0 
		oPrint:Preview()   // previsualiza el archivo PDF
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PrntEncab ³ Autor ³ Alfredo Medrano       ³ Data ³27/10/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Imprime encabezado de informe Factura                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrntEncab()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ N/A                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RptNota()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrntEncab()

	Local cSOrder := ""
	Local cPClient := ""

	oPrint:SayBitmap(0,100, cBMPLogo, 400, 400, , .T.)		
	oPrint:SayBitmap(1,1750, cBMfranja, 565,3300, , .T.) 

	If Trim(( cAliasBus )->D2_PEDIDO) <> ""
		DBSelectArea("SC5")
		SC5->(DBSetOrder(1))
		If SC5->(DBSeek(xFilial("SC5")+( cAliasBus )->D2_PEDIDO))
			cSOrder := SC5->C5_NUM
			DBSelectArea("SC6")
			SC6->(DBSetOrder(1))
			If SC6->(DBSeek(xFilial("SC6")+( cAliasBus )->D2_PEDIDO,.T.))
				cPClient := SC6->C6_PEDCLI
			EndIf
		EndIf
	Else
		DBSelectArea("SC5")
		SC5->(DBSetOrder(5))
		If SC5->(DBSeek(xFilial("SC5")+( cAliasBus )->F2_DOC+( cAliasBus )->F2_SERIE))
			cSOrder := SC5->C5_NUM
		EndIf
	EndIf
	
	//---------		Datos del CLIENTE		-----------------

	
	nRen:=312

	oPrint:Say( nRen ,  1400, STR0001  + ( cAliasBus )->F2_DOC, oFont08c)   //Número de Documento (Factura)
	nRen := nRen + nRtam

	oPrint:Say(nRen ,  1400, STR0002 + SUBSTR(( cAliasBus )->A1_END,1,50), oFont08c)   //Dirección Cliente
	nRen := nRen + nRtam
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  1400, STR0003 + dtoc(( cAliasBus )->F2_EMISSAO), oFont08c) // Fecha
	nRen := nRen + nRtam
	nRen := nRen + nRtam
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100, STR0004 , oFont08c) //"Bill to:"  
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100, SUBSTR(( cAliasBus )->A1_NOME,1,59), oFont08c) //Nombre del cliente
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100, allTrim(( cAliasBus )->A1_END), oFont08c) //Dirección del cliente
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100, AllTrim(( cAliasBus )->A1_BAIRRO)	, oFont08c) //Colonia del cliente
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100, AllTrim(( cAliasBus )->A1_MUN) + ", " +  AllTrim(( cAliasBus )->A1_EST) +  "," + STR0006 , oFont08c) //Ciudad, estado  //Pais ("USA")
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100,  STR0007  + AllTrim(( cAliasBus )->A1_COD_MUN)	, oFont08c) //"City Code "
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100,  ( cAliasBus )->A1_CGC, oFont08c)
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100,   STR0008  + ( cAliasBus )->A1_COD , oFont08c) // "Customer ID : " 
	oPrint:Say( nRen ,  500,   STR0009  + cSOrder , oFont08c) // "Selling Order : "
	oPrint:Say( nRen ,  900,   STR0010  , oFont08c) //"   Credit Terms: "
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100,   STR0011  + ( cAliasBus )->A1_COD , oFont08c) //"Deliver Ref.: "
	oPrint:Say( nRen ,  500,   STR0012  + cPClient , oFont08c) //"P.O. : "
	oPrint:Say( nRen ,  900,   STR0013 , oFont08c) //"BL : "
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100,  REPLICATE("-",130), oFont08c)
	nRen := nRen + nRtam

	oPrint:Say( nRen ,   100, STR0014 , oFont08c) //"PRODUCT ID"
	oPrint:Say( nRen ,   350, STR0025 , oFont08c) //"DESCRIPTION"
	oPrint:Say( nRen ,  1220, STR0026 , oFont08c) //"QUANTITY"
	oPrint:Say( nRen ,  1520, STR0027 , oFont08c) //"PRICE"
	oPrint:Say( nRen ,  1800, STR0028 , oFont08c) //"TOTAL"
	nRen := nRen + nRtam

	oPrint:Say( nRen ,  100,  REPLICATE("-",130), oFont08c)
	nRen := nRen + nRtam

Return
