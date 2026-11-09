#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER403ARG.CH"

/*/{Protheus.doc} GPER403ARG
	Función utilizada para generar un archivo Excel con el control de ganancias de los empleados.

	@type  Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@return lRet, Boolean, Indica si la operación fue exitosa
	@example
		GPER403ARG()
	/*/
Function GPER403ARG()

	Local aParams		:= {}
	Local cPerg			:= "GPER403ARG"
	Local lRet			:= .T.

	If fObtParams(cPerg, aParams)
		Processa({|| lRet := fGerInfGan(aParams), STR0001}) //"Procesando..."
	EndIf

Return lRet

/*/{Protheus.doc} fObtParams
	Función que asigna los parámetros ingresados a un arreglo.
	@type  Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param cPerg, caracter, Nombre del grupo de preguntas
	@param aParams, arreglo, Arreglo donde se almacenarán los parámetros.
	@return lRet, Boolean, Indica si la operación fue exitosa
	@example
		lRet := fObtParams(cPerg, aParams)
	/*/
Static Function fObtParams(cPerg, aParams)

	Local nIteracion	:= 0
	Local nMesAcu		:= 0
	Local lRet			:= .T.
	Local aPergs		:= {}
	Local aSituac		:= {}
	Local oFwSX1Util	:= Nil

	Default cPerg	:= ""
	Default aParams	:= {}

	If !FWSX1Util():ExistPergunte(cPerg) .Or. Empty(FWSX2Util():GetFile("RT3"))
		MsgInfo(STR0012, STR0009) // "No se cuenta con las actualizaciones de diccionario requeridas para la generación del informe." # "Atención"
		lRet := .F.
	EndIf

	lRet := (lRet .And. Pergunte(cPerg, .T.))

	If lRet
		oFwSX1Util := FwSX1Util():New()
		oFwSX1Util:AddGroup(cPerg)
		oFwSX1Util:SearchGroup()
		aPergs := oFwSX1Util:GetGroup(cPerg)[2]

		For nIteracion := 1 To Len(aPergs)
			AAdd(aParams, &("MV_PAR" + StrZero(nIteracion,2)))
		Next nIteracion

		// Mes Acumulados
		nMesAcu := Val(aParams[4])
		If nMesAcu < 1 .Or. nMesAcu > 12
			aParams[4] := "1"
		EndIf
		// Situacion empleado
		For nIteracion := 1 To Len(aParams[7])
			aAdd(aSituac, Subs(aParams[7],nIteracion,1))
		Next nIteracion
		aParams[7] := AClone(aSituac)
		// Ruta archivo
		aParams[8] := AllTrim(aParams[8])
	EndIf

	FWFreeObj(oFwSX1Util)

Return lRet

/*/{Protheus.doc} fGerInfGan
	Función para realizar la generación del informe de control de ganancias.
	@type  Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param aParams, arreglo, Arreglo con información de parámetros.
	@return lRet, Boolean, Indica si la operación fue exitosa
	@example
		fGerInfGan(aParams)
/*/
Static Function fGerInfGan(aParams)

	Local lRet			:=  .F.
	Local cNomArcPla	:= "Control_ganancias.xml"
	Local cNameWorkS	:= ""
	Local cNameTable	:= ""
	Local cMsgArc		:= ""
	Local cMesAcu		:= ""
	Local aDataDet		:= {}
	Local aDataRes		:= {}
	Local cRutaArc		:= ""
	Local oObjExcel		:=  Nil

	Default aParams		:= {}

	cMesAcu		:= aParams[4]
	cRutaArc	:= aParams[8]

	If File(cRutaArc + cNomArcPla)
		cMsgArc := STR0002 + cNomArcPla + STR0003 // "El archivo " # " no pudo ser borrado."
		If !(FErase(cRutaArc + cNomArcPla) == -1)
			cMsgArc := STR0002 + cNomArcPla + STR0004 // "El archivo " # " fue borrado exitosamente."
		EndIf
		ConOut(cMsgArc)
	EndIf

	// Obtiene información de detalle a partir de SRC / SRD
	If fCreTabCon(aDataDet, aDataRes, aParams)

		// Consulta y actualiza información de resumen a partir de RT3
		fObtInfAcum(aDataRes,aParams)

		ProcRegua(3)
		oObjExcel := FWMsExcelEx():New()
		oObjExcel:SetCelBgColor("#eca053") //Se setea color (naranja) de fondo para la celda correspondiente al Número de Registro

		cNameWorkS := "Resumen_Conceptos"
		cNameTable	:= "Table_" + cNameWorkS
		//Definicion de la Tabla de Trabajo
		fDefWSTab(@oObjExcel, cNameWorkS, cNameTable)
		//Definición de encabezados Hoja Detalle
		fDefEncReg(@oObjExcel, 1, cNameWorkS, cNameTable, cMesAcu)
		IncProc(STR0005) // "Generando Resumen..."
		//Impresión de los registros Hoja Detalle
		fDefImpReg(@oObjExcel, aDataRes, cNameWorkS, cNameTable, cMesAcu)

		cNameWorkS := "Detalle_Conceptos"
		cNameTable	:= "Table_" + cNameWorkS
		//Definicion de la Tabla de Trabajo
		fDefWSTab(@oObjExcel, cNameWorkS, cNameTable)
		//Definición de encabezados Hoja Detalle
		fDefEncReg(@oObjExcel, 2, cNameWorkS, cNameTable, cMesAcu)
		IncProc(STR0006) // "Generando Detalle..."
		//Impresión de los registros Hoja Detalle
		fDefImpReg(@oObjExcel, aDataDet, cNameWorkS, cNameTable, cMesAcu)

		IncProc(STR0007) // "Generando archivo..."
		//Generación del archivo Excel
		fGenExcel(@oObjExcel, cRutaArc, cNomArcPla)
		
		lRet := .T.

	EndIf

	If !lRet
		MsgInfo(STR0008, STR0009) // "No se encontraron Movimientos o Historial de movimientos en el periodo informado." - "Atención"
	EndIf

	FWFreeArray(aDataDet)
	FWFreeArray(aDataRes)

Return lRet

/*/{Protheus.doc} fCreTabCon
	Función utilizada para obtener los movimientos de empleados.
	
	@type Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param aDataDet, Array, Array donde se almacenarán los datos del Excel
	@return lRet, Boolean, Indica si la operación fue exitosa
	@example
		fCreTabCon(aDataDet)
	/*/
Static Function fCreTabCon(aDataDet, aDataRes, aParams)

	Local aArea		:= GetArea()
	Local oTmpSR	:= Nil
	Local cQrySr	:= ""
	Local cWhereSR	:= ""
	Local cAliasSR	:= ""
	Local cFilSRC	:= ""
	Local cFilSRD	:= ""
	Local cFilSRA	:= ""
	Local cFilSRV	:= ""
	Local cFilRCH	:= ""
	Local cNomSRC	:= RetSqlName("SRC")
	Local cNomSRD	:= RetSqlName("SRD")
	Local cNomRCH	:= RetSqlName("RCH")
	Local cNomSRV	:= RetSqlName("SRV")
	Local cNomSRA	:= RetSqlName("SRA")
	Local cCodAbo	:= Space(GetSx3Cache("RV_CODABO", "X3_TAMANHO"))
	Local cUltDia	:= ""
	Local cMatricula:= ""
	Local cEmpleado	:= ""
	Local cConAcum	:= ""
	Local cConcepto	:= ""
	Local cDescCon	:= ""
	Local dFchDesde	:= CToD(" /  /    ")
	Local dFchHasta	:= CToD(" /  /    ")
	Local nParQry	:= 1
	Local nPosArrDet:= 0
	Local nPosArrRes:= 0
	Local nMesGan	:= 0
	Local nMesAcu	:= 0
	Local nTotal	:= 0
	Local lRet		:= .T.
	Local lExisRes	:= .F.
	Local lExisDet	:= .F.

	// Parámetros
	Local cSucursal	:= ""
	Local cProceso	:= ""
	Local cAnioAcu	:= ""
	Local cMesAcu	:= ""
	Local cMatIni	:= ""
	Local cMatFin	:= ""
	Local aSituac	:= {}

	Default aDataDet	:= {}
	Default aDataRes	:= {}
	Default aParams		:= {}

	cSucursal	:= aParams[1]
	cProceso	:= aParams[2]
	cAnioAcu	:= aParams[3]
	cMesAcu		:= aParams[4]
	cMatIni		:= aParams[5]
	cMatFin		:= aParams[6]
	aSituac		:= aParams[7]

	nMesAcu := Val(cMesAcu)

	cFilSRC	:= FWxFilial("SRC", cSucursal)
	cFilSRD	:= FWxFilial("SRD", cSucursal)
	cFilSRA	:= FWxFilial("SRA", cSucursal)
	cFilSRV	:= FWxFilial("SRV", cSucursal)
	cFilRCH	:= FWxFilial("RCH", cSucursal)

	dFchDesde	:= CToD("01/01/" + cAnioAcu)
	dFchHasta	:= CToD("01/" + cMesAcu + "/" + cAnioAcu)
	cUltDia		:= Str(Day(LastDay(dFchHasta)), 2)
	dFchHasta	:= CToD(cUltDia +"/" + cMesAcu + "/" + cAnioAcu)

	cWhereSR := " AND RCH.RCH_FCHGAN BETWEEN ? AND ? "
	cWhereSR += " AND NOT SRV.RV_CODABO = ? "
	cWhereSR += " AND SRV.RV_FILIAL = ? "
	cWhereSR += " AND RCH.RCH_FILIAL = ? "
	cWhereSR += " AND SRA.RA_FILIAL = ? "
	cWhereSR += " AND SRA.RA_MAT BETWEEN ? AND ? "
	cWhereSR += " AND SRA.RA_SITFOLH IN ( ? ) "
	cWhereSR += " AND SRV.D_E_L_E_T_ = ? "
	cWhereSR += " AND RCH.D_E_L_E_T_ = ? "
	cWhereSR += " AND SRA.D_E_L_E_T_ = ? "

	cQrySR := " SELECT SRA.RA_MAT, SRA.RA_NOMECMP, SRV.RV_CODABO, SRV.RV_COD, SRV.RV_DESCDET, RCH.RCH_FCHGAN, 'RC' ORIGEN, SRC.RC_ROTEIR, SRC.RC_PERIODO, SRC.RC_SEMANA, SUM(SRC.RC_VALOR) VALOR "
	cQrySR += " FROM ? SRC "
	cQrySR += " INNER JOIN ? SRV "
	cQrySR += " ON SRC.RC_PD = SRV.RV_COD "
	cQrySR += " INNER JOIN ? RCH "
	cQrySR += " ON SRC.RC_ROTEIR = RCH.RCH_ROTEIR "
	cQrySR += " AND SRC.RC_PROCES = RCH.RCH_PROCES "
	cQrySR += " AND SRC.RC_PERIODO = RCH.RCH_PER "
	cQrySR += " AND SRC.RC_SEMANA = RCH.RCH_NUMPAG "
	cQrySR += " INNER JOIN ? SRA "
	cQrySR += " ON SRC.RC_MAT = SRA.RA_MAT "
	cQrySR += " AND SRC.RC_PROCES = SRA.RA_PROCES "
	cQrySR += " WHERE SRC.RC_PROCES = ? "
	cQrySR += " AND SRC.RC_FILIAL = ? "
	cQrySR += " AND SRC.D_E_L_E_T_ = ? "
	cQrySR += cWhereSR
	cQrySR += " GROUP BY SRA.RA_MAT, SRA.RA_NOMECMP, SRV.RV_CODABO, SRV.RV_COD, SRV.RV_DESCDET, RCH.RCH_FCHGAN, SRC.RC_ROTEIR, SRC.RC_PERIODO, SRC.RC_SEMANA "
	cQrySR += " UNION ALL "
	cQrySR += " SELECT SRA.RA_MAT, SRA.RA_NOMECMP, SRV.RV_CODABO, SRV.RV_COD, SRV.RV_DESCDET, RCH.RCH_FCHGAN, 'RD' ORIGEN, SRD.RD_ROTEIR, SRD.RD_PERIODO, SRD.RD_SEMANA, SUM(SRD.RD_VALOR) VALOR"
	cQrySR += " FROM ? SRD "
	cQrySR += " INNER JOIN ? SRV "
	cQrySR += " ON SRD.RD_PD = SRV.RV_COD "
	cQrySR += " INNER JOIN ? RCH "
	cQrySR += " ON SRD.RD_ROTEIR = RCH.RCH_ROTEIR "
	cQrySR += " AND SRD.RD_PROCES = RCH.RCH_PROCES "
	cQrySR += " AND SRD.RD_PERIODO = RCH.RCH_PER "
	cQrySR += " AND SRD.RD_SEMANA = RCH.RCH_NUMPAG "
	cQrySR += " INNER JOIN ? SRA "
	cQrySR += " ON SRD.RD_MAT = SRA.RA_MAT "
	cQrySR += " AND SRD.RD_PROCES = SRA.RA_PROCES "
	cQrySR += " WHERE SRD.RD_PROCES = ? "
	cQrySR += " AND SRD.RD_FILIAL = ? "
	cQrySR += " AND SRD.D_E_L_E_T_ = ? "
	cQrySR += cWhereSR
	cQrySR += " GROUP BY SRA.RA_MAT, SRA.RA_NOMECMP, SRV.RV_CODABO, SRV.RV_COD, SRV.RV_DESCDET, RCH.RCH_FCHGAN, SRD.RD_ROTEIR, SRD.RD_PERIODO, SRD.RD_SEMANA "
	// Ordena por Matricula(SRA.RA_MAT), Concepto Acumulación (SRV.RV_CODABO), Concepto (SRV.RV_COD)
	cQrySR += " ORDER BY 1, 3, 4 "

	oTmpSR := FwExecStatement():New(cQrySR)

	// Define la consulta de los parámetros SRC y alisas tablas
	oTmpSR:SetUnsafe(nParQry++, cNomSRC)
	oTmpSR:SetUnsafe(nParQry++, cNomSRV)
	oTmpSR:SetUnsafe(nParQry++, cNomRCH)
	oTmpSR:SetUnsafe(nParQry++, cNomSRA)
	oTmpSR:SetString(nParQry++, cProceso)
	oTmpSR:SetString(nParQry++, cFilSRC)
	oTmpSR:SetString(nParQry++, " ") // SRC.D_E_L_E_T_
	
	// cWhereSR
	oTmpSR:SetDate(nParQry++, dFchDesde)
	oTmpSR:SetDate(nParQry++, dFchHasta)
	oTmpSR:SetString(nParQry++, cCodAbo)
	oTmpSR:SetString(nParQry++, cFilSRV)
	oTmpSR:SetString(nParQry++, cFilRCH)
	oTmpSR:SetString(nParQry++, cFilSRA)
	oTmpSR:SetString(nParQry++, cMatIni)
	oTmpSR:SetString(nParQry++, cMatFin)
	oTmpSr:SetIn(nParQry++, aSituac)
	oTmpSR:SetString(nParQry++, " ") // SRV.D_E_L_E_T_
	oTmpSR:SetString(nParQry++, " ") // RCH.D_E_L_E_T_
	oTmpSR:SetString(nParQry++, " ") // SRA.D_E_L_E_T_

	// Define la consulta de los parámetros SRD y alisas tablas
	oTmpSR:SetUnsafe(nParQry++, cNomSRD)
	oTmpSR:SetUnsafe(nParQry++, cNomSRV)
	oTmpSR:SetUnsafe(nParQry++, cNomRCH)
	oTmpSR:SetUnsafe(nParQry++, cNomSRA)
	oTmpSR:SetString(nParQry++, cProceso)
	oTmpSR:SetString(nParQry++, cFilSRD)
	oTmpSR:SetString(nParQry++, " ") // SRC.D_E_L_E_T_
	
	// cWhereSR
	oTmpSR:SetDate(nParQry++, dFchDesde)
	oTmpSR:SetDate(nParQry++, dFchHasta)
	oTmpSR:SetString(nParQry++, cCodAbo)
	oTmpSR:SetString(nParQry++, cFilSRV)
	oTmpSR:SetString(nParQry++, cFilRCH)
	oTmpSR:SetString(nParQry++, cFilSRA)
	oTmpSR:SetString(nParQry++, cMatIni)
	oTmpSR:SetString(nParQry++, cMatFin)
	oTmpSr:SetIn(nParQry++, aSituac)
	oTmpSR:SetString(nParQry++, " ") // SRV.D_E_L_E_T_
	oTmpSR:SetString(nParQry++, " ") // RCH.D_E_L_E_T_
	oTmpSR:SetString(nParQry++, " ") // SRA.D_E_L_E_T_

	cAliasSR := oTmpSR:OpenAlias()
	DbSelectArea(cAliasSR)

	Count To nTotal
	lRet := (nTotal > 0)

	ProcRegua(nTotal)

	(cAliasSR)->(DbGoTop())

	While (cAliasSR)->(!EoF())

		IncProc(STR0010) // "Obteniendo información Detalle..."
		lExisRes := (cMatricula == (cAliasSR)->RA_MAT .And. cConAcum == (cAliasSR)->RV_CODABO)
		lExisDet := (lExisRes .And. cConcepto == (cAliasSR)->RV_COD)

		If !lExisDet
			cMatricula	:= (cAliasSR)->RA_MAT
			cEmpleado	:= AllTrim((cAliasSR)->RA_NOMECMP)
			cConAcum	:= (cAliasSR)->RV_CODABO
			cConcepto	:= (cAliasSR)->RV_COD
			cDescCon	:= AllTrim((cAliasSR)->RV_DESCDET)

			nPosArrDet := fCreaLinea(2, aDataDet, cProceso, cMatricula, cEmpleado, cConAcum, cConcepto, cDescCon, nMesAcu)
		EndIf

		If !lExisRes
			nPosArrRes := fCreaLinea(1, aDataRes, cProceso, cMatricula, cEmpleado, cConAcum, , , nMesAcu)
		EndIf
		
		nMesGan := Month(SToD((cAliasSR)->RCH_FCHGAN))
		If (cAliasSR)->ORIGEN == "RD"
			// Acumulado Aplicado
			aDataDet[nPosArrDet][7 + nMesGan] += (cAliasSR)->VALOR
		ElseIf nMesGan == nMesAcu
			aDataDet[nPosArrDet][Len(aDataDet[nPosArrDet])] += (cAliasSR)->VALOR
			aDataRes[nPosArrRes][Len(aDataRes[nPosArrRes])] += (cAliasSR)->VALOR
		EndIf

		(cAliasSR)->(dbSkip())

	EndDo

	(cAliasSR)->(dbCloseArea())

	FWFreeObj(oTmpSR)
	FWRestArea(aArea)

Return lRet

/*/{Protheus.doc} fCreaLinea
	Añade un nuevo renglon al arreglo de Resumen / Detalle.

	@type  Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param nHoja, Numeric, Número de la Hoja (1- Resumen, 2- Detalle).
	@param aInfo, Array, Arreglo donde se almacenarán los datos del Excel
	@param cProceso, Character, Código del proceso.
	@param cMatricula, Character, Matrícula del empleado.
	@param cEmpleado, Character, Nombre del empleado.
	@param cConAcum, Character, Código del concepto de acumulación.
	@param cConcepto, Character, Código del concepto.
	@param cDescCon, Character, Descripción del concepto.
	@param nMesAcu, Numeric, Mes hasta donde se consultan los acumulados.
	@return nPosArr, Numeric, Tamaño del arreglo después de agregar el nuevo renglón.
	@example
		nNumLin := fCreaLinea(nHoja, aInfo, cProceso, cMatricula, cEmpleado, cConAcum, cConcepto, cDescCon, nMesAcu)
/*/
Static Function fCreaLinea(nHoja, aInfo, cProceso, cMatricula, cEmpleado, cConAcum, cConcepto, cDescCon, nMesAcu)

	Local nPosArr	:= 0
	Local nPosDet	:= 1
	Local nIteracion:= 0
	Local nTamArr	:= 6

	Default nHoja		:= 1
	Default aInfo		:= {}
	Default cProceso	:= ""
	Default cMatricula	:= ""
	Default cEmpleado	:= ""
	Default cConAcum	:= ""
	Default cConcepto	:= ""
	Default cDescCon	:= ""
	Default nMesAcu		:= 1

	If nHoja = 2
		nTamArr := 7
	EndIf

	AAdd(aInfo, Array(nTamArr + nMesAcu + 2))
	nPosArr := Len(aInfo)

	aInfo[nPosArr][nPosDet++] := cProceso
	aInfo[nPosArr][nPosDet++] := cMatricula
	aInfo[nPosArr][nPosDet++] := cEmpleado
	aInfo[nPosArr][nPosDet++] := cConAcum
	If nHoja = 2
		aInfo[nPosArr][nPosDet++] := cConcepto
	EndIf
	aInfo[nPosArr][nPosDet++] := cDescCon
	aInfo[nPosArr][nPosDet++] := "Aplicado"

	// Se inicializan valores mensuales
	For nIteracion := 1 To nMesAcu
		aInfo[nPosArr][nPosDet++] := 0
	Next nIteracion

	aInfo[nPosArr][nPosDet++] := "Calculado"
	aInfo[nPosArr][nPosDet++] := 0

Return nPosArr

/*/{Protheus.doc} fObtInfAcum
	Función para obtener información de acumulados desde RT3, y ajustar arreglo aDataRes
	para mostrar el valor acumulado esperado en el periodo informado en los parámetros.
	@type Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param aDataRes, arreglo, Arreglo donde se almacenarán los datos de resumen de acumulados
	@param aParams, arreglo, Arreglo con información de parámetros.
	@return Nil
	@example
		fObtInfAcum(aDataRes, aParams)
	/*/
Static Function fObtInfAcum(aDataRes, aParams)

	Local aArea		:= GetArea()
	Local cFilRT3	:= ""
	Local cFilSRA	:= ""
	Local cFilSRV	:= ""
	Local cQryRT3	:= ""
	Local cAliasRT3	:= ""
	Local cMatricula:= ""
	Local cConcepto	:= ""
	Local nTotal	:= 0
	Local nMesAcu	:= 0
	Local nParQry	:= 1
	Local nPosArr	:= 0
	Local nIteracion:= 0
	Local nValAcuMes:= 0
	Local oTmpRT3	:= Nil

	// Parámetros
	Local cSucursal	:= ""
	Local cProceso	:= ""
	Local cAnioAcu	:= ""
	Local cMatIni	:= ""
	Local cMatFin	:= ""
	Local aSituac	:= {}

	Default aDataRes	:= {}
	Default aParams		:= {}

	cSucursal	:= aParams[1]
	cProceso	:= aParams[2]
	cAnioAcu	:= aParams[3]
	nMesAcu		:= Val(aParams[4])
	cMatIni		:= aParams[5]
	cMatFin		:= aParams[6]
	aSituac		:= aParams[7]

	DBSelectArea("SRV")
	DBSetOrder(1) //RV_FILIAL+RV_COD

	cFilRT3 := FWxFilial("RT3", cSucursal)
	cFilSRA := FWxFilial("SRA", cSucursal)
	cFilSRV	:= FWxFilial("SRV", cSucursal)

	cQryrt3 := " SELECT *  "
	cQryrt3 += " FROM ? RT3 "
	cQryrt3 += " INNER JOIN ? SRA "
	cQryrt3 += " ON RT3.RT3_MAT = SRA.RA_MAT "
	cQryrt3 += " WHERE RT3.RT3_FILIAL = ? "
	cQryrt3 += " AND RT3.RT3_PROCES = ? "
	cQryrt3 += " AND RT3.RT3_ANOINI = ? "
	cQryrt3 += " AND RT3.RT3_ANOFIM = ? "
	cQryrt3 += " AND SRA.RA_FILIAL = ? "
	cQryrt3 += " AND SRA.RA_MAT BETWEEN ? AND ? "
	cQryrt3 += " AND SRA.RA_SITFOLH IN ( ? ) "
	cQryrt3 += " AND RT3.D_E_L_E_T_ = ? "
	cQryrt3 += " AND SRA.D_E_L_E_T_ = ? "
	cQryrt3 += " ORDER BY RT3_PROCES, RT3_MAT, RT3_PD "

	oTmpRT3 := FwExecStatement():New(cQryrt3)

	// Define la consulta de los parámetros SRC y alisas tablas
	oTmpRT3:SetUnsafe(nParQry++, RetSqlName("RT3"))
	oTmpRT3:SetUnsafe(nParQry++, RetSqlName("SRA"))
	oTmpRT3:SetString(nParQry++, cFilRT3)
	oTmpRT3:SetString(nParQry++, cProceso)
	oTmpRT3:SetString(nParQry++, cAnioAcu)
	oTmpRT3:SetString(nParQry++, cAnioAcu)
	oTmpRT3:SetString(nParQry++, cFilSRA)
	oTmpRT3:SetString(nParQry++, cMatIni)
	oTmpRT3:SetString(nParQry++, cMatFin)
	oTmpRt3:SetIn(nParQry++, aSituac)
	oTmpRT3:SetString(nParQry++, " ") // RT3.D_E_L_E_T_
	oTmpRT3:SetString(nParQry++, " ") // SRA.D_E_L_E_T_

	cAliasRT3 := oTmpRT3:OpenAlias()
	DbSelectArea(cAliasRT3)

	Count To nTotal

	ProcRegua(nTotal)

	(cAliasRT3)->(DbGoTop())

	While (cAliasRT3)->(!EoF())

		IncProc(STR0011) // "Obteniendo información Resumen..."

		If !(cMatricula == (cAliasRT3)->RT3_MAT .And. cConcepto == (cAliasRT3)->RT3_PD)
			cMatricula	:= (cAliasRT3)->RT3_MAT
			cConcepto	:= (cAliasRT3)->RT3_PD
			// Buscar si ya existe un registro con la misma información de proceso, matrícula y concepto
			nPosArr := AScan(aDataRes, {|x| x[2] == (cAliasRT3)->RT3_MAT .And. x[4] == (cAliasRT3)->RT3_PD})
			SRV->(MsSeek(cFilSRV + (cAliasRT3)->RT3_PD))
		EndIf

		If nPosArr > 0
			// Actualizar descripción del concepto
			aDataRes[nPosArr][5] := AllTrim(SRV->RV_DESCDET)
			// Informar el valor acumulado en cada mes dentro del periodo indicado
			For nIteracion := 1 To nMesAcu
				aDataRes[nPosArr][6 + nIteracion] += (cAliasRT3)->&("RT3_ACUM"+StrZero(nIteracion,2))
				If nIteracion == nMesAcu
					nValAcuMes := (cAliasRT3)->&("RT3_ACUM"+StrZero(nIteracion,2))
					// Si no existen acumulados en el mes, se toma el valor acumulado del mes anterior
					If nValAcuMes == 0 .And. nMesAcu > 1
						nValAcuMes := (cAliasRT3)->&("RT3_ACUM"+StrZero(nIteracion-1,2))
					EndIf
					aDataRes[nPosArr][Len(aDataRes[nPosArr])] += nValAcuMes
				EndIf
			Next nIteracion
		EndIf

		(cAliasRT3)->(dbSkip())

	EndDo

	(cAliasRT3)->(dbCloseArea())

	FWFreeObj(oTmpRT3)
	FWRestArea(aArea)

Return Nil

/*/{Protheus.doc} fDefWSTab
	Función utilizada para definir el nombre de la Hoja de Trabajo y Tabla.

	@type  Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, Número de la Tabla.
	@example
		fDefWSTab(oObjExcel, cNameWorkS, cNameTable)
/*/
Static Function fDefWSTab(oObjExcel, cNameWorkS, cNameTable)

	Default oObjExcel	:= Nil
	Default cNameWorkS	:= ""
	Default cNameTable	:= ""

	oObjExcel:AddworkSheet(cNameWorkS)
	oObjExcel:AddTable(cNameWorkS, cNameTable, .F.)

Return Nil

/*/{Protheus.doc} fDefEncReg
	Función utilizada para definir el encabezado de los registros.

	@type  Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@param nHoja, Numeric, Número de la Hoja (1- Resumen, 2- Detalle).
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, Número de la Tabla.
	@param cMesAcu, Character, Mes hasta donde se consultan los acumulados.
	@return Nil
	@example
		fDefEncReg(oObjExcel, nHoja, cNameWorkS, cNameTable, cMesAcu)
/*/
Static Function fDefEncReg(oObjExcel, nHoja, cNameWorkS, cNameTable, cMesAcu)

	Local aTitulos		:= {}
	Local nIteracion	:= 0
	Local nMes			:= 0

	Default oObjExcel	:= Nil
	Default nHoja		:= 1
	Default cNameWorkS	:= ""
	Default cNameTable	:= ""
	Default cMesAcu		:= "1"
	
	nMes := Val(cMesAcu)

	aAdd(aTitulos, {})
	aAdd(aTitulos[1], STR0013)		// "Proceso"
	aAdd(aTitulos[1], STR0014)		// "Matrícula"
	aAdd(aTitulos[1], STR0015)		// "Empleado"
	aAdd(aTitulos[1], STR0016)		// "Concepto Acumulado"
	If nHoja == 2
		aAdd(aTitulos[1], STR0017)	// "Concepto Calculado"
	EndIf
	aAdd(aTitulos[1], STR0018)		// "Descripción Concepto"
	aAdd(aTitulos[1], STR0019)		// "Tipo"
	For nIteracion := 1 To nMes
		aAdd(aTitulos[1], STR0020 + StrZero(nIteracion,2)) // "Valor Acum. Mes "
	Next nIteracion
	aAdd(aTitulos[1], STR0019)		// "Tipo"
	aAdd(aTitulos[1], STR0020 + StrZero(nMes,2)) // "Valor Acum. Mes "
	fAddTitulo(@oObjExcel, cNameWorkS, cNameTable, aTitulos[1], nHoja)

	FWFreeArray(aTitulos)

Return Nil

/*/{Protheus.doc} fAddTitulo
	Función utilizada para agregar al objeto las columnas al objetivo
	por registro y su respectivo título.

	@type  Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, Número de la Tabla.
	@param aTitulos, Array, Arreglo con los títulos por registro.
	@param nHoja, Numeric, Número de la Hoja (1- Resumen, 2- Detalle).
	@return Nil
	@example
		fAddTitulo(cNameWorkS, cNameTable, aTitulos, oObjExcel)
/*/
Static Function fAddTitulo(oObjExcel, cNameWorkS, cNameTable, aTitulos, nHoja)

	Local nIteracion	:= 0
	Local nTipo			:= 1
	Local nAlinea		:= 1
	Local cPicture		:= ""
	Local nPosMes		:= 7
	Local nTamTit		:= 0
	Local cPicValor		:= GetSx3Cache("RT3_MES01", "X3_PICTURE")

	Default oObjExcel	:= Nil
	Default cNameWorkS	:= ""
	Default cNameTable	:= ""
	Default aTitulos	:= {}
	Default nHoja		:= 1

	If nHoja == 2
		nPosMes := 8
	EndIf

	nTamTit := Len(aTitulos)

	For nIteracion := 1 To nTamTit
		nTipo	:= 1 // Tipo Texto
		nAlinea	:= 1 // Alineación Izquierda
		cPicture:= ""

		If (nIteracion >= nPosMes .And. nIteracion <= (nTamTit-2)) .Or. nIteracion == nTamTit
			nTipo	:= 2 // Tipo número
			nAlinea	:= 3 // Alineación Derecha
			cPicture:= cPicValor
		EndIf
		oObjExcel:AddColumn(cNameWorkS, cNameTable, aTitulos[nIteracion], nAlinea, nTipo, .F., cPicture)
	Next nIteracion

Return Nil

/*/{Protheus.doc} fDefImpReg
	Función utilizada para definir la impresión del detalle de los
	registros.

	@type  Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@param aData, Array, Arreglo que contiene datos del Registro.
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, Número de la Tabla.
	@param cMesAcu, Character, Mes hasta donde se consultan los acumulados.
	@return Nil
	@example
		fDefImpReg(oObjExcel, aDataDet, cNameWorkS, cNameTable)
/*/
Static Function fDefImpReg(oObjExcel, aData, cNameWorkS, cNameTable, cMesAcu)

	Local aRowOrange	:= {} //Arreglo con número de columnas a resaltar
	Local nIteracion	:= 0
	Local nTamData		:= 0

	Default oObjExcel	:= Nil
	Default aData		:= {}
	Default cNameWorkS	:= ""
	Default cNameTable	:= ""

	nTamData	:= Len(aData[1]) -1
	aRowOrange	:= {nTamData, nTamData - Val(cMesAcu) - 1} //Resalta las filas de 'Tipo'

	For nIteracion := 1 To Len(aData)
		//Se realiza la impresión del renglón
		oObjExcel:AddRow(cNameWorkS, cNameTable, aData[nIteracion], aRowOrange)
	Next nIteracion

Return Nil

/*/{Protheus.doc} fGenExcel
	Función utilizada para generar el archivo Excel en el directorio informado.

	@type  Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@param cRutaArc, Character, cRutaGener, Char, Contiene la ruta para la generación del archivo.
	@param cNomArcPla, Character, Nombre de la planilla a generar.
	@example
		fGenExcel(oObjExcel, cRutaArc, cNomArcPla)
/*/
Static Function fGenExcel(oObjExcel, cRutaArc, cNomArcPla)

	Local lRet := .T.

	Default oObjExcel	:= Nil
	Default cRutaArc	:= ""
	Default cNomArcPla	:= ""

	oObjExcel:Activate()

	oObjExcel:GetXMLFile(cRutaArc + cNomArcPla)

	oObjExcel:DeActivate()

	FreeObj(oObjExcel)

	fViewExcel(cRutaArc, cNomArcPla)

Return lRet

/*/{Protheus.doc} fViewExcel
	Función utilizada para generar el archivo Excel en el directorio informado.

	@type  Static Function
	@author oscar.lopez
	@since 20/01/2026
	@version 1.0
	@param cRutaArc, Character, cRutaGener, Char, Contiene la ruta para la generación del archivo.
	@param cNomArcPla, Character, Nombre de la planilla a generar.
	@example
		fViewExcel(cRutaArc, cNomArcPla)
/*/
Static Function fViewExcel(cRutaArc, cNomArcPla)

	Local oExcelApp		:= Nil

	Default cRutaArc	:= ""
	Default cNomArcPla	:= ""

	//Se configura visualización de la Planilla tras generación
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cRutaArc + cNomArcPla)
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()

	FreeObj(oExcelApp)

Return Nil
