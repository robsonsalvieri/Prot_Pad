#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER1360.CH"

/*/{Protheus.doc} GPER1360
	Listado de Nómina Salarial (LNS) de Paraguay (PAR).

	La presente rutina realiza la generación de un archivo .txt correspondientes al
	Listado de Nómina Salarial.
	
	@type  Function
	@author marco.rivera
	@since 17/12/2024
	@version 1.0
	@return lRet, Logical, Retorna .T. si se generó correctamente el archivo.
	@example
	GPER1360()
	@see https://tdn.totvs.com/pages/releaseview.action?pageId=898455504
	/*/
Function GPER1360()

	Local lRet := .F.

	//Valida la configuración necesaria para la generación del LNS
	If fVldConfig()
		//Se inicia la generación del archivo
		lRet := fGenArcLNS()
	EndIf

Return lRet

/*/{Protheus.doc} fVldConfig
	Función utilizada para validar la configuración necesaria
	para el correcto funcionamiento del LNS.

	@type  Static Function
	@author marco.rivera
	@since 17/12/2024
	@version 1.0
	@return lRet, Logical, Retorna .T. si se encuentra configurado los necesario para el LNS.
	@example
	fVldConfig()
/*/
Static Function fVldConfig()

	Local lRet			:= .T.
	Local cGrupoPerg	:= "GPER1360"
	Local aArea			:= GetArea()

	// Valida que exista el grupo de preguntas y campos
	If !(FWSX1Util():ExistPergunte(cGrupoPerg)) .Or. SRA->(FieldPos("RA_TIPINF")) == 0 .Or. SRA->(FieldPos("RA_OPTLEI")) == 0;
		.Or. SRA->(FieldPos("RA_REGIAO")) == 0 .Or. SRA->(FieldPos("RA_PROVINC")) == 0 .Or. SRA->(FieldPos("RA_CODMUN")) == 0
		MsgInfo(STR0003 + STR0004 + CRLF + CRLF + "https://tdn.totvs.com/x/0FeNNQ", STR0002) // "El Diccionario de Datos no se encuentra actualizado, " # "ingrese al siguiente enlace para mayor información:" # "TOTVS"
		lRet := .F.
	EndIf

	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} fGenArcLNS
	Función utilizada para la generación del LNS.
	
	@type  Static Function
	@author marco.rivera
	@since 17/12/2024
	@version 1.0
	@return lRet, Logical, Retorna .T. si se genera correctamente el archivo.
	@example
		fGenArcLNS()
/*/
Static Function fGenArcLNS()

	Local lRet			:= .F.
	Local cGrupoPerg	:= "GPER1360"
	Local cTabTmpArc	:= ""
	Local nHandleArc	:= 0
	Local oStatement	:= Nil

	/*
	* Grupo de Preguntas - GPER1360
	*
	* MV_PAR01 - ¿Proceso?
	* MV_PAR02 - ¿Procedimiento?
	* MV_PAR03 - ¿Año de Presentación?
	* MV_PAR04 - ¿Ruta para la Generación?
	*/
	If Pergunte(cGrupoPerg, .T.)
		cTabTmpArc := fGenTabTmp(@oStatement)

		If (cTabTmpArc)->(Eof())
			MsgInfo(STR0005, STR0002) // "No se encontró información con los parámetros informados." # "TOTVS"
		Else
			// Se realiza la generación del Archivo y de la ruta (si es necesario)
			If fGenRutArc(@nHandleArc)
				lRet := fGenInfArc(nHandleArc, cTabTmpArc) // Se escribe el contenido del archivo
			EndIf
		EndIf

		//Se cierra la tabla temporal
		(cTabTmpArc)->(DBCloseArea())

		If oStatement <> Nil
			Freeobj(oStatement)
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} fGenRutArc
	Función utilizada para generar el Archivo y Directorio para el LNS.
	
	@type  Static Function
	@author marco.rivera
	@since 17/12/2024
	@version 1.0
	@param nHandleArc, número, Número de manejo de archivo.
	@return lRet, lógico, Retorna .T. si se genera correctamente el archivo.
	@example
		fGenRutArc()
/*/
Static Function fGenRutArc(nHandleArc)

	Local lRet			:= .T.
	Local cDirArchiv	:= AllTrim(MV_PAR04)
	Local cNomeArchi	:= fGenNomArc(MV_PAR03)
	Local cMsgErr		:= STR0006 // "Ha ocurrido un error en la generación del archivo. Revise los permisos del directorio e intente nuevamente."

	Default nHandleArc	:= 0

	lRet := !Empty(cNomeArchi)

	// Valida si existe directorio, si no existe intenta crearlo
	If lRet .And. !ExistDir(cDirArchiv)
		If MakeDir(cDirArchiv, , .F.) <> 0
			cMsgErr := STR0007 + STR0008 // "El directorio informado, no pudo ser creado. " # "Revise los permisos de la carpeta o seleccione otra, e intente nuevamente."
			lRet := .F.
		EndIf
	EndIf

	If lRet
		nHandleArc := fCreate(cDirArchiv + cNomeArchi, 0, NIL, .F.)
		// Indica si el archivo fue creado
		lRet := (nHandleArc >= 0)
	EndIf

	If !lRet
		MsgInfo(cMsgErr, STR0002) // "TOTVS"
	EndIf

Return lRet

/*/{Protheus.doc} fGenNomArc
	Función utilizada para generar el nombre del LNS.
	
	@type  Static Function
	@author marco.rivera
	@since 17/12/2024
	@version 1.0
	@param cAnioParam, Char, Contiene el Año de presentación de la pregunta.
	@return cRetNomArc, Char, Retorna el nombre del archivo.
	@example
		cArch := fGenNomArc("2023")
/*/
Static Function fGenNomArc(cAnioParam)

	Local cRetNomArc	:= ""
	Local aDataSM0		:= {}
	Local aCamposSM0	:= {"M0_CGC"}

	Default cAnioParam	:= ""

	// Se obtiene información de la Sucursal
	aDataSM0 := FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aCamposSM0)

	If Len(aDataSM0) > 0 .And. !Empty(cAnioParam)
		cRetNomArc := AllTrim(StrTran(RTrim(aDataSM0[1][2]), "-", "")) + "_IRP_" + cAnioParam + ".txt" 
	EndIf

Return cRetNomArc

/*/{Protheus.doc} fGenTabTmp
	Función utilizada para obtener la información de periodos del LNS.
	
	@type  Static Function
	@author marco.rivera
	@since 17/12/2024
	@version 1.0
	@param oStatement, objeto, Objeto FwExecStatement para crear tabla temporal.
	@return cRetNomArc, Char, Retorna el nombre del archivo.
	@example
	fGenTabTmp()
/*/
Static Function fGenTabTmp(oStatement)

	Local cRetTabTmp	:= ""
	Local cQuery		:= ""
	Local cAnio			:= ""
	Local cTabCon		:= "S094"
	Local cExpSub		:= "SUBSTR"
	Local cDbMs			:= AllTrim(UPPER(TcGetDb()))
	Local nNumParQry	:= 1
	Local aMonBru		:= {}
	Local aDesJub		:= {}
	Local aDesSeg		:= {}
	Local aOtrDes		:= {}
	Local aMonAgu		:= {}

	Default oStatement := Nil

	If cDbMs == "MSSQL" // Si el manejador de BD es SQL Server
		cExpSub := "SUBSTRING"
	EndIf
	cAnio	:= AllTrim(Str(Val(MV_PAR03)-1))
	aMonBru := fBuscaCon(cTabCon, "MONBRU", 4, 6)
	aDesJub := fBuscaCon(cTabCon, "DESJUB", 4, 6)
	aDesSeg := fBuscaCon(cTabCon, "DESSEG", 4, 6)
	aOtrDes := fBuscaCon(cTabCon, "OTRDES", 4, 6)
	aMonAgu := fBuscaCon(cTabCon, "MONAGU", 4, 6)

	// Mostrar solo empleados con historial de movimientos (SRD)
	cQuery := " SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_ENDEREC, RA_COMPLEM, RA_TELEFON, RA_TELEMOV, RA_TPCIC"
	cQuery += " , RA_CIC, RA_TIPINF, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_EMAIL, RA_ESTADO, RA_CEP, RA_OPTLEI"
	cQuery += " , RA_REGIAO, RA_PROVINC, RA_CODMUN"
	cQuery += " , SUM(CASE WHEN RD_PD IN (?) THEN RD_VALOR ELSE 0 END) MONBRU"
	cQuery += " , SUM(CASE WHEN RD_PD IN (?) THEN RD_VALOR ELSE 0 END) DESJUB"
	cQuery += " , SUM(CASE WHEN RD_PD IN (?) THEN RD_VALOR ELSE 0 END) DESSEG"
	cQuery += " , SUM(CASE WHEN RD_PD IN (?) THEN RD_VALOR ELSE 0 END) OTRDES"
	cQuery += " , SUM(CASE WHEN RD_PD IN (?) THEN RD_VALOR ELSE 0 END) MONAGU"
	cQuery += " FROM ? SRD"
	cQuery += " RIGHT JOIN ? SRA"
	cQuery += " ON RD_MAT = RA_MAT"
	cQuery += " WHERE RD_FILIAL = ?"
	cQuery += " AND RA_FILIAL = ?"
	cQuery += " AND RD_PROCES = ?"
	cQuery += " AND RD_ROTEIR = ?"
	cQuery += " AND " + cExpSub + "(RD_DATPGT, 1, 4) = ?"
	cQuery += " AND SRA.D_E_L_E_T_ = ?"
	cQuery += " AND SRD.D_E_L_E_T_ = ?"
	cQuery += " GROUP BY RA_FILIAL, RA_MAT, RA_NOME, RA_ENDEREC, RA_COMPLEM, RA_TELEFON, RA_TELEMOV, RA_TPCIC"
	cQuery += " , RA_CIC, RA_TIPINF, RA_PRISOBR, RA_SECSOBR, RA_PRINOME, RA_SECNOME, RA_EMAIL, RA_ESTADO, RA_CEP, RA_OPTLEI"
	cQuery += " , RA_REGIAO, RA_PROVINC, RA_CODMUN"

	oStatement := FwExecStatement():New(cQuery)

	oStatement:SetIn(nNumParQry++, aMonBru)
	oStatement:SetIn(nNumParQry++, aDesJub)
	oStatement:SetIn(nNumParQry++, aDesSeg)
	oStatement:SetIn(nNumParQry++, aOtrDes)
	oStatement:SetIn(nNumParQry++, aMonAgu)
	oStatement:SetUnsafe(nNumParQry++, RetSqlName("SRD"))
	oStatement:SetUnsafe(nNumParQry++, RetSqlName("SRA"))
	oStatement:SetString(nNumParQry++, FWxFilial("SRD"))
	oStatement:SetString(nNumParQry++, FWxFilial("SRA"))
	oStatement:SetString(nNumParQry++, MV_PAR01)
	oStatement:SetString(nNumParQry++, MV_PAR02)
	oStatement:SetString(nNumParQry++, cAnio)
	oStatement:SetString(nNumParQry++, " ")
	oStatement:SetString(nNumParQry++, " ")

	cRetTabTmp := oStatement:OpenAlias()
	
Return cRetTabTmp

/*/{Protheus.doc} fGenInfArc
	Función utilizada para escribir las líneas del archivo.
	
	@type  Static Function
	@author marco.rivera
	@since 17/12/2024
	@version 1.0
	@param nHandleArc, caracter, Contiene el Año de presentación de la pregunta.
	@param cTabTmpArc, caracter, Nombre de tabla temporal con detalle de empleados.
	@return lRet, lógico, Retorna .T. si es generado un archivo de manera exitosa, de lo contrario retorna .F.
	@example
		fGenInfArc(nHandleArc, cTabTmpArc)
/*/
Static Function fGenInfArc(nHandleArc, cTabTmpArc)

	Local lRet		:= .F.
	Local nNumReg	:= 0
	Local nMontoTot	:= 0
	Local aLinArc01	:= {}
	Local aLinArc02	:= {}
	Local cMsgProc	:= STR0006 // "Ha ocurrido un error en la generación del archivo. Revise los permisos del directorio e intente nuevamente."
	
	Default cTabTmpArc := ""

	(cTabTmpArc)->(DBGoTop()) // Se posiciona el puntero al inicio de la tabla temporal

	While (cTabTmpArc)->(!Eof())
		nNumReg++
		fGenLin02(aLinArc02, cTabTmpArc, @nMontoTot)
		(cTabTmpArc)->(DBSkip())
	EndDo

	If nNumReg > 0
		fGenLin01(aLinArc01, nNumReg, nMontoTot)
		fIncInfo(nHandleArc, aLinArc01)
		fIncInfo(nHandleArc, aLinArc02)
	EndIf

	If FClose(nHandleArc)
		lRet := .T.
		cMsgProc := STR0009 // "El archivo ha sido generado de forma exitosa."
	EndIf

	 MsgInfo(cMsgProc, STR0002) // "TOTVS"

Return lRet

/*/{Protheus.doc} fGenLin01
	Obtiene información para generar linea 1 de archivo.
	
	@type  Static Function
	@author marco.rivera
	@since 17/12/2024
	@version 1.0
	@param aLinArc01, arreglo, arreglo con información de registro 1 para archivo
	@param nNumReg , número, Número total de empleados procesados
	@param nMontoTot, número, Total acumulado de Monto Bruto (sin descuentos) de los empleados procesados
	@return Nil
	@example
		fGenLin01(aLinArc01, nNumReg, nMontoTot)
/*/
Static Function fGenLin01(aLinArc01, nNumReg, nMontoTot)

	Local aDataSM0		:= {}
	Local aCamposSM0	:= {"M0_CGC"}

	Default aLinArc01	:= {}
	Default nNumReg		:= 0
	Default nMontoTot	:= 0

	//Se obtiene información de la Sucursal
	aDataSM0 := FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aCamposSM0)
	
	aAdd(aLinArc01, {"1",;															// 1 - Tipo linea - Cabecera
					AllTrim(StrTran(aDataSM0[1][2], "-", "")),;						// 2 - RUC Declarante
					MV_PAR03,;														// 3 - Periodo
					AllTrim(Str(nNumReg)),;											// 4 - Cantidad Empleados
					AllTrim(StrTran(StrTran(Str(nMontoTot), ".", ""), ",", ""))})	// 5 - Suma Monto Total

Return Nil

/*/{Protheus.doc} fGenLin02
	Añade detalle para linea 2 por empleado
	
	@type  Static Function
	@author marco.rivera
	@since 17/12/2024
	@version 1.0
	@param aLinArc02, arreglo, Arreglo con información de empleados para archivo
	@param cTabTmpArc, caracter, Nombre de tabla temporal con detalle de empleados
	@param nMontoTot, número, Variable para suma total (sin descuentos) de todos los empleados procesados
	@return return_var, return_type, return_description
	@example
		GenLin02(aLinArc02, cTabTmpArc, @nMontoTot)
/*/
Static Function fGenLin02(aLinArc02, cTabTmpArc, nMontoTot)

	Local cTipDoc	:= ""
	Local cNumDoc	:= ""
	Local cDigVer	:= ""
	Local cTpPago	:= ""
	Local cDirec	:= ""
	Local cTeleFij	:= ""
	Local cTeleMov	:= ""
	Local cMonBru	:= "0"
	Local cDesJub	:= "0"
	Local cDesSeg	:= "0"
	Local cOtrDes	:= "0"
	Local cMonAgu	:= "0"

	Default aLinArc02	:= {}
	Default cTabTmpArc	:= ""
	Default nMontoTot	:= 0

	cDirec		:= RTrim((AllTrim((cTabTmpArc)->RA_ENDEREC) + " " + AllTrim((cTabTmpArc)->RA_COMPLEM)))
	cTeleFij	:= AllTrim((cTabTmpArc)->RA_TELEFON)
	cTeleMov	:= AllTrim((cTabTmpArc)->RA_TELEMOV)

	cTipDoc := AllTrim((cTabTmpArc)->RA_TPCIC)
	cNumDoc := AllTrim((cTabTmpArc)->RA_CIC)
	If cTipDoc == "RUC" .And. !Empty(cNumDoc)
		cDigVer := Right(cNumDoc, 1)
		cNumDoc := Left(cNumDoc, Len(cNumDoc)-1)
	EndIf

	cTpPago := AllTrim((cTabTmpArc)->RA_TIPINF)
	If !(cTpPago == "9")
		cMonBru := StrTran( StrTran( LTrim( Str( Round( (cTabTmpArc)->MONBRU, 0))), ".", ""), ",", "")
		cDesJub := StrTran( StrTran( LTrim( Str( Round( (cTabTmpArc)->DESJUB, 0))), ".", ""), ",", "")
		cDesSeg := StrTran( StrTran( LTrim( Str( Round( (cTabTmpArc)->DESSEG, 0))), ".", ""), ",", "")
		cOtrDes := StrTran( StrTran( LTrim( Str( Round( (cTabTmpArc)->OTRDES, 0))), ".", ""), ",", "")
		cMonAgu := StrTran( StrTran( LTrim( Str( Round( (cTabTmpArc)->MONAGU, 0))), ".", ""), ",", "")
	EndIf

	//Suma monto total (monto bruto de todos los empleados) para registro 1
	nMontoTot += Round( (cTabTmpArc)->MONBRU, 0)

	aAdd(aLinArc02, {"2",;								// Detalle
					cNumDoc,;							// No. Documento
					cDigVer,;							// Digito Verificador (RUC)
					AllTrim((cTabTmpArc)->RA_PRISOBR),;	// Primer apellido
					AllTrim((cTabTmpArc)->RA_SECSOBR),;	// Segundo apellido
					AllTrim((cTabTmpArc)->RA_PRINOME),;	// Primer nombre
					AllTrim((cTabTmpArc)->RA_SECNOME),;	// Segundo nombre
					cTpPago,;							// Tipo de Pago
					cMonBru,;							// Monto bruto (sin descuentos)
					cDesJub,;							// Descuento por Jubilación
					cDesSeg,;							// Descuentos por Seguro Social
					cOtrDes,;							// Otros descuentos
					cMonAgu,;							// Monto aguinaldo
					AllTrim((cTabTmpArc)->RA_EMAIL),;	// Correo electrónico
					AllTrim((cTabTmpArc)->RA_REGIAO),;	// Departamento
					AllTrim((cTabTmpArc)->RA_PROVINC),;	// Distrito
					AllTrim((cTabTmpArc)->RA_CODMUN),;	// Localidad/Barrio
					cDirec,;							// Direccion completa
					Left(cTeleFij, 3),;					// Prefijo linea fija
					Right(cTeleFij, 6),;				// Telefono linea fija
					Left(cTeleMov, 4),;					// Prefijo celular
					Right(cTeleMov, 6),;				// Telefono celular
					(cTabTmpArc)->RA_OPTLEI })			// Tipo de empleado

Return

/*/{Protheus.doc} fIncInfo
	Función para añadir registro(s) a archivo txt

	@type  Static Function
	@author oscar.lopez
	@since 26/12/2024
	@version 1.0
	@param nHandleArc, numero, param_descr
	@param aLinArc0X, arreglo, Arreglo con información por linea a añadir a archivo
	@return Nil
	@example
		fIncInfo(nHandleArc, aLinArc01)
	/*/
Static Function fIncInfo(nHandleArc, aLinArc0X)

	Local nItera1	:= 0
	Local nItera2	:= 0
	Local nTamReg	:= 0
	Local cSep		:= ";"
	Local cRegImp	:= ""
	Local lSalLin	:= .T.

	Default nHandleArc:= 0
	Default aLinArc0X := {{""}}

	nTamReg := Len(aLinArc0X[1])
	lSalLin := !(aLinArc0X[1][1] ==  "1")

	For nItera1 := 1 To Len(aLinArc0X)
		cRegImp := ""
		For nItera2 := 1 To nTamReg
			cRegImp += aLinArc0X[nItera1][nItera2] + cSep
		Next nItera2
		If lSalLin
			cRegImp := CRLF + cRegImp
		EndIf
		FWrite(nHandleArc, cRegImp) // Se añade registro a archivo
	Next nItera1

Return Nil

/*/{Protheus.doc} fBuscaCon
	Busca información en tabla alfanumerica y retorna contenido de columna indicada

	@type  Static Function
	@author oscar.lopez
	@since 30/12/2024
	@version 1.0
	@param cTabCon, caracter, Indica tabla enla cual se buscará información.
	@param cValBus, caracter, Indica el codigo que contiene los tipos de conceptos a acumular.
	@param nColBus, número, Indica el numero de columna donde se buscara el código informado.
	@param nColRes, número, Indica el numero de columna que contiene la lista de conceptos conforme al codigo indicado.
	@return aRet, arreglo, Retorna la lista de conceptos en un arreglo.
	@example
		aArreglo := fBuscaCon("S094", "MONBRU", 4, 5)
	/*/
Static Function fBuscaCon(cTabCon, cValBus, nColBus, nColRes)

	Local nPosTab	:= 0
	Local cConcep	:= ""
	Local aRet		:= {}

	Default cTabCon := ""
	Default cValBus := ""
	Default nColBus := 0
	Default nColRes := 0

	nPosTab := fPosTab(cTabCon, cValBus, "=", nColBus)
	If nPosTab > 0
		cConcep := AllTrim(fTabela(cTabCon, nPosTab, nColRes))
	EndIf
	If !Empty(cConcep)
		aRet := StrTokArr(cConcep, "|")
	EndIf

Return aRet
