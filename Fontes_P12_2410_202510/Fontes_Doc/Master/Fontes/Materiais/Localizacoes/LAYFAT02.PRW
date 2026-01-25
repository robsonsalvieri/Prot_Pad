#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include 'FWLIBVERSION.CH'
#Include "ARPRINTER.CH"
#Include "LAYFAT02.CH"

#Define MAXLIN 20

/*/{Protheus.doc} LAYFAT02
	Programa para la impresión de formato para remitos de venta.
	@type  Function
	@author luis.samaniego
	@since 24/11/2022
	@param lAutomato - Logical - Indica si es rutina automática
	@return Nil
	/*/
Function LAYFAT02(lAutomato)
Local cPerg		:= "LAYFAT02"
Local aArea		:= GetArea()
Local ojParam	:= JsonObject():New()
Local aPreg		:= {}

Default lAutomato	:= .F.

	aPreg := {"Tipo_Documento", "De_Documento", "A_Documento", "De_Serie", "A_Serie", "De_Fecha", "A_Fecha",;
				"De_Cliente", "De_Tienda", "A_Cliente", "A_Tienda", "Copias", "GeneraPDF", "RutaPDF"}

	ojParam := LayJson(aPreg)
	
	Pergunte(cPerg, .T.)

	ojParam['Tipo_Documento']  := mv_par01
	ojParam['De_Documento'] := mv_par02
	ojParam['A_Documento'] := mv_par03
	ojParam['De_Serie'] := mv_par04
	ojParam['A_Serie'] := mv_par05
	ojParam['De_Fecha'] := mv_par06
	ojParam['A_Fecha'] := mv_par07
	ojParam['De_Cliente'] := mv_par08
	ojParam['De_Tienda'] := mv_par09
	ojParam['A_Cliente'] := mv_par10
	ojParam['A_Tienda'] := mv_par11
	ojParam['GeneraPDF'] := Iif(mv_par12 == 2, 'S', 'N')
	ojParam['RutaPDF'] := Alltrim(mv_par13)
	ojParam['Copias']  := 1

	If ojParam['GeneraPDF'] == "S" .And. !ExistDir(ojParam['RutaPDF'])
		If lAutomato
			MakeDir(ojParam['RutaPDF'], , .F.)
		Else
			If MsgYesNo(STR0002) //"El directorio que informo no existe. ¿Desea crearlo?"
				If MakeDir(ojParam['RutaPDF'],,.F.) <> 0
					MsgStop(STR0003) //"El directorio no se pudo crear. Se procedera a generar la impresion en pantalla."
					ojParam['GeneraPDF'] := "N"
				EndIf
			EndIf
		EndIf
	EndIf

	If !lAutomato
		Processa({|lFin| SelectComp(ojParam) }, STR0001, , .T.) //Verificando datos y generando archivos ...
	Else
		SelectComp(ojParam)
	EndIf

	FreeObj(ojParam)
	ojParam := Nil

	RestArea(aArea)

Return Nil

/*/{Protheus.doc} SelectComp
	Función para la selección de comprobantes e impresión de formatos.
	@type  Function
	@author luis.samaniego
	@since 24/11/2022
	@param ojParam - Json - Objeto con los parámetros de la rutina.
	@return Nil
	/*/
Static Function SelectComp(ojParam)
Local cClave	:= ""
Local cItem		:= ""
Local cNomArc	:= ""
Local nLin		:= 1
Local nPag		:= 1
Local oJProds   := JsonObject():New()

Local oPrn		 := Nil
Local aRecPedSC5 := {}
Local cTrb       := GetNextAlias()

Default ojParam  := Nil

	fArmaDatos(ojParam, @cTrb)

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSelectArea("SF2")
	dbSetOrder(1)
	dbSelectArea(cTrb)
	(cTrb)->(dbGoTop())

	If (cTrb)->(!Eof())

		oPrn := ARPrinter():New(ojParam['GeneraPDF'] == "S")
		
		If !oPrn:lImprimir //Se anula la impresión
			oPrn:oPrn:oPrint:Cancel()
			FreeObj(oPrn)
			Return
		EndIf

		ProcRegua((cTrb)->(RecCount()))
		
		While !Eof()		
			cClave 	:= (cTrb)->(F2_SERIE+F2_DOC+A1_COD+A1_LOJA+F2_ESPECIE)
			cItem	:= (cTrb)->D2_ITEM
			cNomArc	:= Alltrim((cTrb)->(F2_SERIE))+"_"+Alltrim((cTrb)->(F2_DOC))+"_"+AllTrim((cTrb)->(A1_COD))+"_"+AllTrim((cTrb)->(A1_LOJA))+"_"+AllTrim((cTrb)->(F2_ESPECIE))
			
			// Solo funciona si el objeto se creo como "PDF"
			oPrn:setPDF(cNomArc, ojParam['RutaPDF'])
			
			nLin	:= 1
			nPag	:= 1
			aRecPedSC5 := {}

			PrintHead(ojParam['Copias'], nPag, ojParam, @oPrn, cTrb)
					
			While !Eof() .And. cClave == (cTrb)->(F2_SERIE+F2_DOC+A1_COD+A1_LOJA+F2_ESPECIE)
				IncProc()
				
				fCargaRec(cTrb, @aRecPedSC5)
				PrintItem(ojParam['Copias'], @nLin, @nPag, ojParam, @oPrn, cTrb, @oJProds)
				nLin++
				(cTrb)->(dbSkip())
			EndDo
			
			PrintFoot(ojParam['Copias'], @nPag, @oPrn, aRecPedSC5)
			
			// Solo funciona si el objeto se creo como "PDF"
			oPrn:imprimePDF()
			
		EndDo

		// Solo funciona si el objeto no se creo como "PDF"
		oPrn:visualiza()

	Else
		MsgStop(STR0005) //"No hay datos por exhibir"
	EndIf

	If Select(cTRB) > 0
		(cTrb)->(dbCloseArea())
	EndIf

Return Nil


/*/{Protheus.doc} PrintHead
	Función para la impresión del encabezado del documento.
	@type  Function
	@author luis.samaniego
	@since 24/11/2022
	@param 
			nNroCop - Númerico - Número de copia.
			nPag - Númerico - Número de página.
			ojParam - json - Objeto con los parámetros de la rutina.
			oPrn - Objeto para impresión.
			cTrb - Tabla temporal de trabajo.
	@return Nil
	/*/
Static Function PrintHead(nNroCop, nPag, ojParam, oPrn, cTrb)
Local aCopias  := {STR0006} //"ORIGINAL"
Local aEncab   := {STR0011} //"REMITO"
Local aPosIt   := {2.5, 10.84, 28, 34}
Local aRecuad  := {2,15,20,58,65}
Local cFATLOG  := GetNewPar("MV_FATLOG","logo\logo.bmp")
Local cCodComp := '91'
Local cTipoDoc := AllTrim((cTrb)->TIPODOC)

Default nNroCop := 0
Default nPag    := 0
Default ojParam := Nil
Default oPrn    := Nil
Default cTrb    := ""

	oPrn:StartPage()

	//--------------
	// 1er recuadro
	//--------------
	oPrn:Box(aRecuad[1], 2, aRecuad[2], 47)

	//------
	// Logo
	//------
	If File(cFATLOG)
		oPrn:SayBitmap(3.1, 5, cFATLOG, 200, 200 )
	Else
		oPrn:Say(4, 4, STR0012, ARIAL_15B) //"Configure el parametro MV_FATLOG con la ruta "
		oPrn:Say(5, 4, STR0013, ARIAL_15B) //"de archivo válido formato BMP dentro de la"
		oPrn:Say(6, 4, STR0014, ARIAL_15B) //"Estructura del servidor 550 x 250 px."
	EndIf

	//----------------
	// Recuadro Serie
	//----------------
	oPrn:Box(03.2, 24, 06, 26)

	oPrn:Say(03, 38, aCopias[nNroCop], ARIAL_18B)
			
	oPrn:Say(05, 24.6, (cTrb)->F2_SERIE, ARIAL_20B)
	oPrn:Say(07, 24, STR0015, ARIAL_12)	//"Código"
	oPrn:Say(08, 24.25, STR0016 + cCodComp, ARIAL_12) //"Nº "

	oPrn:Say(06, 30, aEncab[ojParam['Tipo_Documento']], ARIAL_18B)	        
	oPrn:Say(07, 30, STR0016 + Left((cTrb)->F2_DOC,4)+"-"+Right((cTrb)->F2_DOC,8), ARIAL_18B) //"Nº "

	oPrn:Say(09, 05, MemoLine(SM0->M0_NOMECOM,40,1), ARIAL_15)
	oPrn:Say(10, 05, MemoLine(SM0->M0_NOMECOM,40,2), ARIAL_15)
	oPrn:Say(11, 05, IIf(Empty(SM0->M0_ENDENT), STR0017, AllTrim(SM0->M0_ENDENT)+" - "+AllTrim(SM0->M0_CIDENT)), ARIAL_15) //"Direccion de prueba"
	oPrn:Say(12, 05, STR0018 + GetNewPar("MV_FATCEP",SM0->M0_CEPENT)+", "+SM0->M0_BAIRENT, ARIAL_15) //"C.P: "
	oPrn:Say(13, 05, STR0019 + GetNewPar("MV_FATTEL",SM0->M0_TEL), ARIAL_15) //"Tel: "
	oPrn:Say(14, 05, GetNewPar("MV_FATTIP", STR0020), ARIAL_15) //"Crear parametro MV_FATTIP con contenido 'IVA Responsable Inscripto'"

	oPrn:Say(09, 31, STR0021 + DToC((cTrb)->F2_EMISSAO), ARIAL_15) //"Fecha: "
	oPrn:Say(10, 31, STR0022 + SM0->M0_CGC, ARIAL_15) //"C.U.I.T.: "
	oPrn:Say(11, 31, STR0023 + SM0->M0_INSC, ARIAL_15) //"Ingresos Brutos: "
	oPrn:Say(12, 31, GetNewPar("MV_FATINI", STR0024), ARIAL_15) //"Inicio de actividades: 99/9999"
	oPrn:Say(13, 31, STR0025 + cValToChar(nPag), ARIAL_15) //"Página: "

	//--------------
	// 2do recuadro
	//--------------
	cTipoDoc := Substr(cTipoDoc, At("|", cTipoDoc)+1, Len(cTipoDoc))

	oPrn:Box(aRecuad[2], 2, aRecuad[3], 47)

	oPrn:Say(16, 05, LAYXTXT((cTrb)->A1_NOME) + ' (' + LAYXTXT((cTrb)->A1_COD) + ') ', ARIAL_15)//oAria
	oPrn:Say(16, 33, cTipoDoc + ": "+ (cTrb)->A1_CGC , ARIAL_15)
				
	oPrn:Say(17, 05, LAYXTXT((cTrb)->A1_END) + " - " + LAYXTXT((cTrb)->A1_MUN), ARIAL_15)
				
	oPrn:Say(18, 05, "A " + LAYXTXT((cTrb)->DESTIPO), ARIAL_15)

	oPrn:Say(21, aPosIt[1], LAYFALIN(STR0026, "I",16)				, COURIER_11B)	//"CODIGO"
	oPrn:Say(21, aPosIt[2], LAYFALIN(STR0027,"I", 80)		, COURIER_11B)	//"DESCRIPCION"
	oPrn:Say(21, aPosIt[3], LAYFALIN(STR0028,"D",12)				, COURIER_11B)	//"CANT."
	oPrn:Say(21, aPosIt[4], LAYFALIN(STR0029,"I",5)				, COURIER_11B)	//"UNID."

	oPrn:Line(22, 02, 22, 47)

Return Nil
	
/*/{Protheus.doc} PrintItem
	Función para la impresión de lineas.
	@type  Function
	@author luis.samaniego
	@since 24/11/2022
	@param 
			nNroCop - Númerico - Número de copia.
			nLin - Númerico - Número de línea.
			nPag - Númerico - Número de página.
			ojParam - Objeto con los párametros de la rutina.
			oPrn - Objeto para impresión.
			aRecPedSC5 - Array con recno del pedido de venta relacionado.
			cTrb - Tabla temporal de trabajo.
			oJProds - Json con información del código/descripción del producto.
	@return Nil
	/*/
Static Function PrintItem(nNroCop, nLin, nPag, ojParam, oPrn, cTrb, oJProds)
Local nFila := 0
Local aPosIt := {2.5, 10.84, 28, 34}
Local cCodProd  := ""
Local cDescProd := ""

Default nNroCop    := 0
Default nLin       := 0
Default nPag       := 0
Default ojParam    := Nil
Default oPrn       := Nil
Default cTrb       := ""
Default oJProds    := Nil

	If nLin > MAXLIN
		nLin := 1
		nPag++
		oPrn:EndPage()
		PrintHead(nNroCop, nPag, ojParam, @oPrn, cTrb)
	EndIf

	cCodProd := Alltrim((cTrb)->D2_COD)
	If !oJProds:HasProperty(cCodProd)
		cDescProd := POSICIONE("SB1",1, xFilial("SB1")+(cTrb)->D2_COD,"B1_DESC")
		If !Empty(cDescProd)
			oJProds[cCodProd] := cDescProd
		EndIf
	EndIf

	nFila := nLin+22

	oPrn:Say(nFila, aPosIt[1], LAYFALIN((cTrb)->D2_COD,"I",16), COURIER_11)	// CODIGO
	oPrn:Say(nFila, aPosIt[2], LAYFALIN(oJProds[cCodProd], "I", 80), COURIER_11)	// DESCRPCION
	oPrn:Say(nFila, aPosIt[3], LAYFALIN((cTrb)->D2_QUANT,"D",12), COURIER_11)	// CANTIDAD
	oPrn:Say(nFila, aPosIt[4], LAYFALIN((cTrb)->D2_UM,"I",5), COURIER_11)	// UNIDAD DE MEDIDA

Return Nil
	
/*/{Protheus.doc} PrintFoot
	Función para la impresión del pie de pagina.
	@type  Function
	@author luis.samaniego
	@since 24/11/2022
	@param 
			nNroCop - Númerico - Número de copia.
			nPag - Númerico - Número de página.
			oPrn - Númerico - Objeto para la impresión.
			aRecPedSC5 - Array con recno del pedido de venta relacionado.
	@return Nil
	/*/
Static Function PrintFoot(nNroCop, nPag, oPrn, aRecPedSC5)
Local cOCCli   := ""
Local cPVAsoc  := ""
Local nTotPed  := Len(aRecPedSC5)
Local nIniObs  := 44
Local aObsPed  := {}
Local nX       := 0
Local aRecuad  := {2,15,20,58,65}

Default nNroCop    := 0
Default nPag       := 0
Default oPrn       := Nil
Default aRecPedSC5 := {}
	//--------------
	// 4to recuadro
	//--------------
	// Footer
	//--------------
	oPrn:Line(aRecuad[4], 02, aRecuad[4], 47 )

	For nX := 1 To nTotPed
		SC5->(dbGoTo(aRecPedSC5[nX]))
		If SC5->(ColumnPos("C5_XOCCLI")) > 0
			cOCCli += IIf(Empty(cOCCli),"","/")+Alltrim(SC5->C5_XOCCLI)
		EndIf

		cPVAsoc += IIf(Empty(cPVAsoc),"","/")+Alltrim(SC5->C5_NUM)

		If !Empty(SC5->C5_MENNOTA)
			aAdd(aObsPed, AlLTrim(SC5->C5_MENNOTA))
		EndIf
	Next nX

	For nX := 1 To Len(aObsPed)
		oPrn:Say(nIniObs, 04, STR0030 + cValToChar(nX)+": "+aObsPed[nX], COURIER_12) //"Obs. "
		nIniObs++
	Next nX

	If !Empty(cPVAsoc)
		oPrn:Say(59, 05, STR0031 + cPVAsoc, COURIER_12) //"Pedidos de Venta asociados: "
	EndIf

	If !Empty(cOCCli)
		oPrn:Say(60, 05, STR0032 +cOCCli, COURIER_12) //"Ordenes de Compra asociadas: "
	EndIf

	oPrn:EndPage()

Return Nil

/*/{Protheus.doc} fArmaDatos
	Función para obtener la información de los remitos.
	@type  Function
	@author luis.samaniego
	@since 24/11/2022
	@param 
			ojParam - Objeto json con los parámetros de la rutina.
			cTrb - Tabla temporal de trabajo.
	@return Nil
	/*/
Static Function fArmaDatos(ojParam, cTrb)
Local aCampos    := {}
Local nX		 := 1
Local cEspecie   := "RFN"
Local cDeDocum   := ojParam['De_Documento']
Local cADocum    := ojParam['A_Documento']
Local cDeSerie   := ojParam['De_Serie']
Local cASerie    := ojParam['A_Serie']
Local dDeFecha   := DTOS(ojParam['De_Fecha'])
Local dAFecha    := DTOS(ojParam['A_Fecha'])
Local cDeCliente := ojParam['De_Cliente']
Local cACliente  := ojParam['A_Cliente']
Local cDeTienda  := ojParam['De_Tienda']
Local cATienda   := ojParam['A_Tienda']

Default ojParam   := Nil
Default cTrb      := ""

	BeginSql alias cTrb

		SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_END, SA1.A1_MUN, SA1.A1_CGC,;
			SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, SF2.F2_ESPECIE,;
			SD2.D2_COD, SD2.D2_UM, SD2.D2_QUANT, SD2.D2_ITEM, SD2.D2_PEDIDO, SD2.D2_ITEMPV, SD2.D2_SERIREM, SD2.D2_REMITO, SD2.D2_ITEMREM,;
			TPDOC.X5_DESCSPA AS TIPODOC, TPCLI.X5_DESCSPA AS DESTIPO
		FROM %table:SF2% SF2
			INNER JOIN %table:SD2% SD2
					ON SF2.F2_FILIAL = SD2.D2_FILIAL
						AND SF2.F2_DOC = SD2.D2_DOC
						AND SF2.F2_SERIE = SD2.D2_SERIE
						AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
						AND SF2.F2_LOJA = SD2.D2_LOJA
						AND SF2.F2_ESPECIE = SD2.D2_ESPECIE
						AND SD2.%NotDel%
			INNER JOIN %table:SA1% SA1
					ON SF2.F2_CLIENTE = SA1.A1_COD
						AND SF2.F2_LOJA = SA1.A1_LOJA
						AND SA1.%NotDel%
			LEFT JOIN %table:SX5% TPCLI
					ON TPCLI.X5_TABELA = 'SF'
						AND TPCLI.X5_CHAVE = SA1.A1_TIPO
						AND TPCLI.%NotDel%
			LEFT JOIN %table:SX5% TPDOC
					ON TPDOC.X5_TABELA = 'OC'
						AND TPDOC.X5_CHAVE = SA1.A1_AFIP
						AND TPDOC.%NotDel%
		WHERE  SF2.F2_FILIAL = %Exp:(xFilial("SF2"))%
			AND SF2.F2_ESPECIE = %Exp:cEspecie%
			AND SF2.F2_DOC BETWEEN %Exp:cDeDocum% AND %Exp:cADocum%
			AND SF2.F2_SERIE BETWEEN %Exp:cDeSerie% AND %Exp:cASerie%
			AND SF2.F2_EMISSAO BETWEEN %Exp:dDeFecha% AND %Exp:dAFecha%
			AND SF2.F2_CLIENTE BETWEEN %Exp:cDeCliente% AND %Exp:cACliente%
			AND SF2.F2_LOJA BETWEEN %Exp:cDeTienda% AND %Exp:cATienda%
			AND SF2.%NotDel%
		ORDER BY SF2.F2_SERIE,SF2.F2_DOC,SA1.A1_COD,SA1.A1_LOJA,SF2.F2_ESPECIE,SD2.D2_ITEM

	EndSql

	aCampos := (cTrb)->(dbStruct())
	For nX := 1 To Len(aCampos)
		If !(aCampos[nX,1] $ "TIPODOC|DESTIPO")
			aCampos[nX,2] := GetSX3Cache(aCampos[nX,1],"X3_TIPO")
			aCampos[nX,3] := GetSX3Cache(aCampos[nX,1],"X3_TAMANHO")
			aCampos[nX,4] := GetSX3Cache(aCampos[nX,1],"X3_DECIMAL")
			TCSetField(cTrb, aCampos[nX,1], aCampos[nX,2], aCampos[nX,3], aCampos[nX,4])
		EndIf
	Next

Return Nil

/*/{Protheus.doc} fCargaRec
	Función para obtener el recno de los pedidos de venta vinculados al remito de venta.
	@type  Function
	@author luis.samaniego
	@since 24/11/2022
	@param cTrb - Tabla temporal de trabajo.
	@return aRecPedSC5 - Array con el número de recno del pedido de venta.
	/*/
Static Function fCargaRec(cTrb, aRecPedSC5)
Default aRecPedSC5 := {}

Default cTrb       := ""

	If !Empty((cTrb)->D2_PEDIDO)
		If SC5->(msSeek(xFilial("SC5")+(cTrb)->D2_PEDIDO))
			If aScan(aRecPedSC5, {|x| x == SC5->(Recno())}) == 0
				aAdd(aRecPedSC5, SC5->(Recno()))
			EndIf
		EndIf
	EndIf

Return
