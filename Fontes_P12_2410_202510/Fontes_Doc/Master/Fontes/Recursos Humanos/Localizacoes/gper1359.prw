#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "GPER1359.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} GPER1359
    Rutina utilizada para la generación del Formulario 1359 (F. 1359),
    el cual es utilizado para presentar Impuesto a las Ganancias - 4ta. 
    Categoría Relación de Dependencia en sus diferentes tipos de archivo.

    @type  Function
    @author marco.rivera
    @since 02/12/2024
    @version 1.0
    @return lRet, Logical, Retorna .T. si el proceso finalizó correctamente.
    @example
    GPER1359()
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=893426187
    /*/
Function GPER1359()

    Local aRubrosRCC    := {}
    Local lRet          := .F.

    //Valida la configuración necesaria para la generación del F1359
    If fVldConfig(aRubrosRCC)
        lRet := fDefGenArc(aRubrosRCC) //Genera el F1359
    EndIf

Return lRet

/*/{Protheus.doc} fVldConfig
    Función utilizada para validar la configuración necesaria
    para el correcto funcionamiento del formulario.

    @type  Function
    @author marco.rivera
    @since 03/12/2024
    @version 1.0
    @param aRubrosRCC, Array, Arreglo con 3 posiciones con información de los rubros.
    @return lRet, Logical, Retorna si la validación está correcta.
    @example
    fVldConfig()
    /*/
Function fVldConfig(aRubrosRCC)

    Local lRet          := .T.
	Local cCpoSRV		:= "RV_COD13"
    Local cGrupoPerg    := "GPERFIAG"
    Local cConcepRB     := AllTrim(SuperGetMv("MV_IAGCRBF", .F., "911")) //Código del Concepto de Remuneración Bruta
    Local nValConRB     := SuperGetMv("MV_IAGVRBF", .F., 0) //Valor del Concepto de Remuneración Bruta

    Default aRubrosRCC  := {}

    If !(FWSX1Util():ExistPergunte(cGrupoPerg)) .Or. ; //Valida que exista el grupo de preguntas
        Len(FWSX3Util():GetFieldStruct("RV_COD13")) == 0 .Or. ; //Valida que exista el campo en Conceptos
        FWSX3Util():GetFieldStruct("RV_COD13")[3] <> 4 .Or. ; //Valida que tenga la configuración correca
        !(FWSX6Util():ExistsParam("MV_IAGIMPF")) .Or. ; //Valida que exista el parámetro del Impuesto del Formulario IAG
        !(FWSX6Util():ExistsParam("MV_IAGCONF")) .Or. ; //Valida que exista el parámetro del Concepto del Formulario IAG
        !(FWSX6Util():ExistsParam("MV_IAGFORF")) .Or. ; //Valida que exista el parámetro del Número del Formulario IAG
        !(FWSX6Util():ExistsParam("MV_IAGVERF")) .Or. ; //Valida que exista el parámetro de la Versión del Formulario IAG
        !(FWSX6Util():ExistsParam("MV_IAGCRBF")) .Or. ; //Valida que exista el parámetro del Concepto de Remuneración del Formulario IAG
        !(FWSX6Util():ExistsParam("MV_IAGVRBF")) //Valida que exista el parámetro con el Valor del Concepto de Remuneración del Formulario IAG

        lRet := .F.
        MsgInfo(STR0001 + STR0002 + CRLF + CRLF + "https://tdn.totvs.com/x/C5pANQ", STR0003) //"El Diccionario de Datos no se encuentra actualizado, " + "ingrese al siguiente enlace para mayor información:" + "TOTVS"
    EndIf

    If lRet .And. Len(fCrgTabRub(aRubrosRCC)) == 0
        lRet := .F.
        MsgInfo(STR0004 + STR0002 + CRLF + CRLF + "https://tdn.totvs.com/x/C5pANQ", STR0003) //"La Tabla Alfanumérica S051 no existe o no contiene información, "  + "ingrese al siguiente enlace para mayor información:" + "TOTVS"
    EndIf

    If lRet .And. (Empty(cConcepRB) .Or. nValConRB == 0)
        lRet := .F.
         MsgInfo(STR0005 + STR0002 + CRLF + CRLF + "https://tdn.totvs.com/x/C5pANQ", STR0003) //"El Código o Valor del Concepto de Remuneración Bruta no se encuentran configurados, " + "ingrese al siguiente enlace para mayor información:" + "TOTVS"
    EndIf

	If lRet .And. fConCod13()
		lRet := .F.
		MsgInfo(STR0220 + AllTrim(FWX3Titulo(cCpoSRV)) + " (" + cCpoSRV + ")" + STR0221, STR0003) //"No existen conceptos con el campo " # " informado" # "TOTVS"
	EndIf

Return lRet

/*/{Protheus.doc} fCrgTabRub
    Función utilizada para obtener los rubros para el F1359 de
    la tabla S051 - IAG - Códigos de Rubros.

    @type  Static Function
    @author marco.rivera
    @since 03/12/2024
    @version 1.0
    @param aRubrosRCC, Array, Arreglo para almacenamiento de rubros.
    @return aRubrosRCC, Array, Arreglo con 3 posiciones con información de los rubros.
    @example
    fCrgTabRub()
/*/
Static Function fCrgTabRub(aRubrosRCC)

    Local cFilialRCC    := xFilial("RCC")
    Local cCodTabRCC    := "S051"
    Local cAreaRCC      := RCC->(GetArea())

    Default aRubrosRCC  := {}

    DbSelectArea("RCC")
    RCC->(DBSetOrder(1)) //"RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"

    //Se buscan los registros en la tabla S051 - IAG - Códigos de Rubros
    If RCC->(MsSeek(cFilialRCC + cCodTabRCC))
        While !(Eof()) .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == cFilialRCC + cCodTabRCC
            aAdd(aRubrosRCC, ;
                    {SubStr(RCC->RCC_CONTEU, 1, 4), ; //Se obtiene Código de Rubro -> XXXX
                    Val(SubStr(RCC->RCC_CONTEU, 2, 1)), ; //Se obtiene el número de registro -> CXCC
                    Val(SubStr(RCC->RCC_CONTEU, 3, 2))}) //Se obtiene el número del campo -> CCXX
            RCC->(DBSkip())
        EndDo
    EndIf

    RestArea(cAreaRCC)
    
Return aRubrosRCC

/*/{Protheus.doc} fDefGenArc
    Define las distintas formas de impresión del Formulario 1359.

    @type  Static Function
    @author marco.rivera
    @since 03/12/2024
    @version 1.0
    @param aRubrosRCC, Array, Arreglo con 3 posiciones con información de los rubros.
    @return lRet, Logical, Retorna si se generó el F1359 correctamente.
    @example
    fDefGenArc(aRubrosRCC)
/*/
Static Function fDefGenArc(aRubrosRCC)

    Local lRet          := .F.
    Local cGrupoPerg    := "GPERFIAG"

    Default aRubrosRCC  := {}

    //Valida si confirma la información de los parámetros
    If (Pergunte(cGrupoPerg, .T.))
        If !isBlind()
            Processa({|| lRet := fGenInfArc(aRubrosRCC), STR0018}) //"Procesando..."
        EndIf
    EndIf

    If lRet
        MsgInfo(STR0019, STR0003) //"El proceso ha finalizado exitosamente." + "TOTVS"
    EndIf
    
Return lRet

/*/{Protheus.doc} fGenInfArc
    
    Función utilizada para generar la información y archivo que contendrá
    los registros del F1359.
    
    @type  Static Function
    @author marco.rivera
    @since 03/12/2024
    @version 1.0
    @param aRubrosRCC, Array, Arreglo con 3 posiciones con información de los rubros.
    @return lRet, Logical, Retorna si se generó la información para el F1359.
    @example
    fGenInfArc(aRubrosRCC)
/*/
Static Function fGenInfArc(aRubrosRCC)

    Local lRet          := .F.
    Local cGrupoPerg    := "GPERFIAG"
    Local cProceso      := ""
    Local cProcedimi    := ""
    Local cPerParam     := ""
    Local cNumPago      := ""
    Local cMatricula    := ""
    Local cCentrCIni    := ""
    Local cCentrCFin    := ""
    Local nTipoPrese    := 0
    Local aPerAbiert    := ""
    Local aPerCerrad    := ""
    Local nPosPerAbi    := 0
    Local nPosPerCer    := 0
    Local cAliasAux     := ""
    Local cPrefTab      := ""
    Local cPeriodRCH    := ""
    Local cTabTemp      := ""
    Local nTipoArcGen   := 0
    Local cNomeFile     := ""
    Local cRutaGener    := ""
    Local nArchivo      := 0
    Local nCountRegs    := 0
    Local nNumRegTmp    := 0
    Local nContRegla    := 0    
    Local cCUILEmp      := ""
    Local nValConRB     := SuperGetMv("MV_IAGVRBF", .F., 0) //Valor del Concepto de Remuneración Bruta
    Local cConcepRB     := AllTrim(SuperGetMv("MV_IAGCRBF", .F., "911")) //Código del Concepto de Remuneración Bruta
    Local oStatement	:= Nil
    Local cNomeEmp      := ""
    Local aDetEmpPDF    := {}
    Local lContinua     := .T.
	Local aDataExcel	:= {}
	Local oObjExcel		:= Nil
	Local nIter			:= 0

    //Variables para Esctrucuturas de Registros
	Local aEstrReg01	:= {} //Estructura del Registro 01 - Cabecera
	Local aEstrReg02	:= {} //Estructura del Registro 02 - Datos del Trabajador
    Local aEstrReg03    := {} //Estructura del Registro 03 - Remuneraciones Gravadas
    Local aEstrReg04    := {} //Estructura del Registro 04 - Remuneraciones Exentas o No Alcanzadas
    Local aEstrReg05    := {} //Estructura del Registro 05 - Deducciones Generales
    Local aEstrReg06    := {} //Estructura del Registro 06 - Deducciones Art. 30
    Local aEstrReg07    := {} //Estructura del Registro 07 - Pagos a Cuenta
    Local aEstrReg08    := {} //Estructura del Registro 08 - Cálculo del Impuesto

    Default aRubrosRCC  := {}

    /*
    * Grupo de Preguntas - GPERFIAG
    *
    * MV_PAR01 - ¿Proceso?
    * MV_PAR02 - ¿Procedimiento?
    * MV_PAR03 - ¿Periodo?
    * MV_PAR04 - ¿Número de Pago?
    * MV_PAR05 - ¿Matrícula?
    * MV_PAR06 - ¿De Centro de Costo?
    * MV_PAR07 - ¿A Centro de Costo?
    * MV_PAR08 - ¿Tipo de Presentación? -> 1 - Anual / 2 - Final / 3 - Informativa / 4 - Anual Distracto
    * MV_PAR09 - ¿Secuencia?
    * MV_PAR10 - ¿Periodo Fiscal?
    * MV_PAR11 - ¿Lugar de Emisión?
    * MV_PAR12 - ¿Fecha de Emisión?
    * MV_PAR13 - ¿Responsable?
    * MV_PAR14 - ¿Ruta para la Generación?
    * MV_PAR15 - ¿Tipo de Archivo? -> 1 - Archivo TXT / 2 - Planilla / 3 - PDF
    */

    //Se convierten a expresión SQL las preguntas
    MakeSqlExpr(cGrupoPerg)

    cProceso    := MV_PAR01
    cProcedimi  := MV_PAR02
    cPerParam   := MV_PAR03
    cNumPago    := MV_PAR04
    cMatricula  := MV_PAR05
    cCentrCIni  := MV_PAR06
    cCentrcFin  := MV_PAR07
    nTipoPrese  := MV_PAR08
    cSequencia  := MV_PAR09
    cRutaGener  := AllTrim(MV_PAR14)
    nTipoArcGen := MV_PAR15

	If nTipoArcGen == 2
		oObjExcel := FWMsExcelEx():New()
		oObjExcel:SetCelBgColor("#eca053") //Se setea color (naranja) de fondo para la celda correspondiente al Número de Registro
	EndIf

    If !(F1359VldPe(cPerParam, nTipoPrese))
        Return .F.
    EndIf

    //Se obtiene información de periodos abiertos o cerrados
    RetPerAbertFech(cProceso,;      // Proceso seleccionado en la pregunta
				    cProcedimi,;    // Procedimiento seleccionado en la pregunta
				    cPerParam,;      // Desde - Periodo seleccionado en la pregunta
				    cNumPago,;      // Desde - Número de Pago seleccionado en la pregunta
				    NIL,;           // Hasta - Periodo: Se informa Nil, debido a que solo se busca información de un periodo
				    NIL,;           // Hasta - Número de Pago: Se informa Nil, debido a que solo se busca información de un periodo
				    @aPerAbiert,;   // Retorna un arreglo con los Periodos abiertos
				    @aPerCerrad )   // Retorna un arreglo con los Periodos cerrados
    
    //Se valida la existencia de periodos abiertos o cerrados
    If Len(aPerAbiert) == 0 .And. Len(aPerCerrad) == 0
	    MsgInfo(STR0008, STR0003) //"No se encontraron periodos abiertos o cerrados con los parámetros informados. Verifíquelos e intente nuevamente." + "TOTVS"
        Return lRet
    Else
        nPosPerAbi := aScan(aPerAbiert, {|x| x[1] == cPerParam .And. x[2] == cNumPago})
        nPosPerCer := aScan(aPerCerrad, {|x| x[1] == cPerParam .And. x[2] == cNumPago})

        If nPosPerAbi > 0
            cAliasAux   := "SRC"
            cPrefTab    := "RC_"
            cPeriodRCH  := AllTrim(Str(Year(aPerAbiert[1,5]))) + cNumPago
        ElseIf nPosPerCer > 0 
            cAliasAux   := "SRD"
            cPrefTab    := "RD_"
            cPeriodRCH  := AllTrim(Str(Year(aPerCerrad[1,5]))) + cNumPago
        EndIf

        cTabTemp := fTabTmpMov(@oStatement, cPrefTab, cAliasAux, cCentrCIni, cCentrcFin, cMatricula, cProceso, cProcedimi, cPerParam, cNumPago, nTipoPrese)

	EndIf

    //Se valida que existan registros a procesar
    If (cTabTemp)->(Eof())
        MsgInfo(STR0009, STR0003) //"No se encontró información para generar el F. 1359 con los parámetros informados. Verifíquelos e intente nuevamente."  + "TOTVS"
        Return lRet
    Else
        
        While (cTabTemp)->(!Eof())
            nNumRegTmp++
            (cTabTemp)->(DBSkip())
        EndDo
        (cTabTemp)->(DBGoTop()) //Se posiciona el puntero al inicio de la tabla temporal

        If nTipoArcGen == 1 .Or. nTipoArcGen == 2

            //Se define el nombre del archivo a generar
            cNomeFile := fGenNomArc(cPeriodRCH, cSequencia)

            //Se valida que se haya obtenido un nombre para el archivo
            If nTipoArcGen == 1 .And. !(Empty(cNomeFile))
                lContinua := fGenTxtDir(@nArchivo, cRutaGener, cNomeFile) //Se valida que se haya generado el archivo
            EndIf

        EndIf

        If nTipoArcGen == 1 .And. !isBlind() //Si no es ejecución por rutina automatizada
            //Se define regla de avance
            ProcRegua(nNumRegTmp)
        EndIf
        
        While (cTabTemp)->(!Eof()) .And. lContinua

            If nTipoArcGen == 1 .And. !isBlind() //Si no es ejecución por rutina automatizada
                nContRegla++
                //Se muestra regla de progreso
                IncProc(STR0010 + cValToChar(nContRegla) + STR0011 + cValToChar(nNumRegTmp) + STR0012) //"Procesando " + " de " + " registros..."
            EndIf

            If fGetMovSRV("", cAliasAux, cPrefTab, (cTabTemp)->RA_FILIAL, (cTabTemp)->RA_MAT, 2, cConcepRB, cProceso, cProcedimi, cPerParam, cNumPago) >= nValConRB

                cCUILEmp := PadL((cTabTemp)->RA_CIC, 11, " ")
                cNomeEmp := AllTrim((cTabTemp)->RA_PRISOBR) + " " + AllTrim((cTabTemp)->RA_SECSOBR) + " " + AllTrim((cTabTemp)->RA_PRINOME) + " " + AllTrim((cTabTemp)->RA_SECNOME)

				aEstrReg02	:= {}		 //Registro 02 - Datos del Trabajador
                aEstrReg03  := Array(13) //Registro 03 - Remuneraciones Gravadas
                aEstrReg04  := Array(22) //Registro 04 - Remuneraciones Exentas o No Alcanzadas
                aEstrReg05  := Array(33) //Registro 05 - Deducciones Generales
                aEstrReg06  := Array(17) //Registro 06 - Deducciones Art. 30
                aEstrReg07  := Array(13) //Registro 07 - Pagos a Cuenta
                aEstrReg08  := Array(9) //Registro 08 - Cálculo del Impuesto

                nCountRegs++

                //Se realiza la impresión del //Registro 01 - Cabecera
                If nCountRegs == 1
                    fGenReg01(cPeriodRCH, nTipoArcGen, nTipoPrese, cPerParam, cSequencia, nArchivo, aEstrReg01)
					If nTipoArcGen == 2 .And. Len(aEstrReg01) > 0 //Generación de archivo Planilla
						oObjExcel := fDefImpExc(oObjExcel, aEstrReg01, "01", nCountRegs)
					EndIf
                EndIf

                //Se realiza generación del Registro 02 - Datos del Trabajador
                fGenReg02(CtoD((cTabTemp)->RA_ADMISSA), cCUILEmp, cPeriodRCH, nTipoArcGen, nArchivo, aEstrReg02)

                //Se realiza generación del Registro 03 - Remuneraciones Gravadas (13 campos)
                fObtEstReg(aEstrReg03, 3, cCUILEmp, aRubrosRCC, cAliasAux, cPrefTab, (cTabTemp)->RA_FILIAL, (cTabTemp)->RA_MAT, cProceso, cProcedimi, cPerParam, cNumPago)
                
                //Se realiza generación del Registro 04 - Remuneraciones Exentas o No Alcanzadas (20 campos)
                fObtEstReg(aEstrReg04, 4, cCUILEmp, aRubrosRCC, cAliasAux, cPrefTab, (cTabTemp)->RA_FILIAL, (cTabTemp)->RA_MAT, cProceso, cProcedimi, cPerParam, cNumPago)
                
                //Se realiza generación del Registro 05 - Deducciones Generales (33 campos)
                fObtEstReg(aEstrReg05, 5, cCUILEmp, aRubrosRCC, cAliasAux, cPrefTab, (cTabTemp)->RA_FILIAL, (cTabTemp)->RA_MAT, cProceso, cProcedimi, cPerParam, cNumPago)
                
                //Se realiza generación del Registro 06 - Deducciones Art. 30 (17 campos)
                fObtEstReg(aEstrReg06, 6, cCUILEmp, aRubrosRCC, cAliasAux, cPrefTab, (cTabTemp)->RA_FILIAL, (cTabTemp)->RA_MAT, cProceso, cProcedimi, cPerParam, cNumPago)
                
                //Se realiza generación del Registro 07 - Pagos a Cuenta (13 campos)
                fObtEstReg(aEstrReg07, 7, cCUILEmp, aRubrosRCC, cAliasAux, cPrefTab, (cTabTemp)->RA_FILIAL, (cTabTemp)->RA_MAT, cProceso, cProcedimi, cPerParam, cNumPago)
                
                //Se realiza generación del Registro 08 - Cálculo del Impuesto
                fObtEstReg(aEstrReg08, 8, cCUILEmp, aRubrosRCC, cAliasAux, cPrefTab, (cTabTemp)->RA_FILIAL, (cTabTemp)->RA_MAT, cProceso, cProcedimi, cPerParam, cNumPago)
                
                If nTipoArcGen == 1 //Generación del Archivo TXT
                    
                    //Escribe en el archivo la información de cada registro para el empleado
                    fGenRegXX(aEstrReg03, aEstrReg04, aEstrReg05, aEstrReg06, aEstrReg07, aEstrReg08, nTipoArcGen, nArchivo)

				ElseIf nTipoArcGen == 2 //Generación de archio Planilla

					aDataExcel := {}

					//Información del Empleado
					AAdd(aDataExcel, (cTabTemp)->RA_MAT)
					AAdd(aDataExcel, cNomeEmp)

					//Registro 02
					For nIter := 1 To Len(aEstrReg02)
						AAdd(aDataExcel, aEstrReg02[nIter])
					Next nIter

					fGenRegXX(aEstrReg03, aEstrReg04, aEstrReg05, aEstrReg06, aEstrReg07, aEstrReg08, nTipoArcGen, nArchivo, aDataExcel)

					If Len(aDataExcel) > 0
						oObjExcel := fDefImpExc(oObjExcel, aDataExcel, "XX", nCountRegs)
					EndIf

                ElseIf nTipoArcGen == 3 //Generación del información para Archivo PDF
                    
                    //Información de Encabezado y Detalle por Empleado
                    aAdd(aDetEmpPDF, { { {cCUILEmp, cNomeEmp, (cTabTemp)->RA_MAT, (cTabTemp)->RA_FILIAL}}, ; //Información del Empleado
                                        aEstrReg03, ; //Remuneraciones Gravadas
                                        aEstrReg04, ; //Remuneraciones Exentas
                                        aEstrReg05, ; //Deducciones Generales
                                        aEstrReg06, ; //Deducciones Personales
                                        aEstrReg07, ; //Pagos a Cuenta
                                        aEstrReg08}) //Cálculo del Impuesto

                EndIf
            
            EndIf

            (cTabTemp)->(DBSkip())
        EndDo

        //Se valida generación del Archivo TXT
        If nTipoArcGen == 1
            If !(FClose(nArchivo))
                MsgInfo(STR0013, STR0003) // "El archivo no se ha generado. Revise los permisos del directorio informado e intente nuevamente." + "TOTVS"
            Else
                lRet := .T.
            EndIf
        EndIf

        //Se cierra la tabla temporal
        (cTabTemp)->(DBCloseArea())
        
        If oStatement <> Nil
			Freeobj(oStatement)
		EndIf

		//Genera impresión del Archivo Planilla
		If nTipoArcGen == 2
			lRet := fGenExcel(oObjExcel, cRutaGener, cNomeFile)
			fViewExcel(cRutaGener, cNomeFile)
		EndIf

        //Genera impresión del Archivo PDF
        If nTipoArcGen == 3 .And. Len(aDetEmpPDF) > 0
            lRet := fGenArcPDF(aDetEmpPDF)
        EndIf

    EndIf

Return lRet

/*/{Protheus.doc} fGenNomArc
    
    Función utilizada para generar el nombre del F1359.

    @type  Static Function
    @author marco.rivera
    @since 04/12/2024
    @version 1.0
    @param cPeriodRCH, Char, Contiene el periodo a procesar.
    @param cSequencia, Char, Contiene la secuencia informada en las preguntas.
    @return cNomeFile, Char, Contiene el nombre del archivo.
    @example
    fGenNomArc(cPeriodRCH, cSequencia)
/*/
Static Function fGenNomArc(cPeriodRCH, cSequencia)

    Local aDataSM0      := {}
    Local aCamposSM0	:= {"M0_CGC"}
    Local cNumForm      := PadR(SuperGetMv("MV_IAGFORF", .F., "1359"), 4)

    Default cPeriodRCH  := ""
    Default cSequencia  := ""

    //Se obtiene información de la Sucursal
    aDataSM0 := FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aCamposSM0)

    //Se genera el nombre con la estructura F+ 1359 + . + Periodo + 0000 + . + Secuencia
    cNomeFile := "F" + cNumForm + "." + AllTrim(StrTran(RTrim(aDataSM0[1][2]), "-", "")) + "." + SubStr(cPeriodRCH, 1, 4) + "0000" + "." + StrZero(Val(cSequencia), 4)
    
Return cNomeFile

/*/{Protheus.doc} fGenTxtDir
    Función utilizada para la generación del archivo en el directorio informado.
    
    @type  Static Function
    @author marco.rivera
    @since 04/12/2024
    @version 1.0
    @param nArchivo, Numeric, Número (Handle) del archivo generado.
    @param cRutaGener, Char, Contiene la ruta para la generación del archivo.
    @param cNomeFile, Char, Contiene el nombre del archivo.
    @return lRet, Logical, Returna .T. si se generó correctamente el archivo.
    fGenTxtDir(@nArchivo, cRutaGener, cNomeFile)
/*/
Static Function fGenTxtDir(nArchivo, cRutaGener, cNomeFile)

    Local lRet          := .F.
    Local cArcConExt    := ""

    Default nArchivo    := 0
    Default cRutaGener  := ""
    Default cNomeFile   := ""

    cArcConExt := cNomeFile + ".txt"

    //Se valida la existencia del directorio
    If !(ExistDir(cRutaGener))
        If MakeDir(cRutaGener, , .F.) <> 0
            MsgInfo(STR0014 + STR0015, STR0003) //"El directorio informado, no pudo ser creado. " + "Revise los permisos de la carpeta o seleccione otra, e intente nuevamente." + "TOTVS"
            Return lRet
        EndIf
    EndIf

    nArchivo := fCreate(cRutaGener + cArcConExt)

    If nArchivo >= 0
        lRet := .T.
    EndIf

Return lRet

/*/{Protheus.doc} fGenReg01
    Función utilizada para generar la información del Registro 01 y
    para imprimir el Registro 01 en el Archivo TXT.
    
    @type  Static Function
    @author marco.rivera
    @since 05/12/2024
    @version 1.0
    @param cPeriodRCH, Char, Contiene el periodo a procesar.
    @param nTipoArcGen, Numeric, Contiene el Tipo de Archivo a generar.
    @param nTipoPrese, Numeric, Contiene el Tipo de Presentación.
    @param cPerParam, Char, Contiene el periodo informado en las preguntas.
    @param cSequencia, Char, Contiene la secuencia informada en las preguntas.
    @param nArchivo, Numeric, Número (Handle) del archivo generado.
    @example
    fGenReg01(cPeriodRCH, nTipoArcGen, nTipoPrese, cPerParam, cSequencia, nArchivo)
/*/
Static Function fGenReg01(cPeriodRCH, nTipoArcGen, nTipoPrese, cPerParam, cSequencia, nArchivo, aInfoReg01)

	Local aFilActual    := FWArrFilAtu()
	Local cLineaImp     := ""
	Local nIteracion    := 0

	Default cPeriodRCH  := ""
	Default nTipoArcGen := 0
	Default nTipoPrese  := 0
	Default cPerParam   := ""
	Default cSequencia  := ""
	Default nArchivo    := 0
	Default aInfoReg01	:= {}

    aAdd(aInfoReg01, "01") //1 - Tipo de Registro
    aAdd(aInfoReg01, PadR(StrTran(aFilActual[18], "-", ""), 11, " ")) //2 - CUIT Agente de Retención
    aAdd(aInfoReg01, IIf(nTipoPrese == 1 .Or. nTipoPrese == 4, SubStr(cPeriodRCH, 1, 4) + "00", cPerParam)) //3 - Periodo Informado
    aAdd(aInfoReg01, StrZero(Val(cSequencia), 2)) //4 - Secuencia
    aAdd(aInfoReg01, PadR(SuperGetMv("MV_IAGIMPF", .F., "0103"), 4)) //5 - Código de Impuesto
    aAdd(aInfoReg01, PadR(SuperGetMv("MV_IAGCONF", .F., "593"), 3)) //6 - Código de Concepto
    aAdd(aInfoReg01, PadR(SuperGetMv("MV_IAGFORF", .F., "1359"), 4)) //7 - Número de Formulario
    aAdd(aInfoReg01, AllTrim(Str(nTipoPrese))) //8 - Tipo de Presentación
    aAdd(aInfoReg01, PadR(SuperGetMv("MV_IAGVERF", .F., "00100"), 5)) //9 - Versión del Sistema

    //Se realiza la impresión del Registro 02 en el Archivo TXT
    If nTipoArcGen == 1
        For nIteracion := 1 To Len(aInfoReg01)
            cLineaImp += aInfoReg01[nIteracion]
        Next nIteracion
        
        If !Empty(cLineaImp)
            FWrite(nArchivo, cLineaImp) //Se escribe el Registro 01 - Cabecera
        EndIf
    EndIf

Return

/*/{Protheus.doc} fGenReg02
    Función utilizada para generar la información del Registro 02 y
    para imprimir el Registro 02 en el Archivo TXT.
    
    @type  Static Function
    @author marco.rivera
    @since 05/12/2024
    @version 1.0
    @param dDataAdmis, Date, Contiene la fecha de adminisión del empleado.
    @param cCUILEmp, Char, Contiene el CUIL del Empleado.
    @param cPeriodRCH, Char, Contiene el periodo a procesar.
    @param nTipoArcGen, Numeric, Contiene el Tipo de Archivo a generar.
    @param nArchivo, Numeric, Número (Handle) del archivo generado.
    @example
    fGenReg02(dDataAdmis, cCUILEmp, cPeriodRCH, nTipoArcGen, nArchivo)
/*/
Static Function fGenReg02(dDataAdmis, cCUILEmp, cPeriodRCH, nTipoArcGen, nArchivo, aInfoReg02)

    Local cLineaImp     := ""
    Local nIteracion    := 0
    Local cAnoIngres    := ""
    Local cPeriDesde    := ""
    Local cPeriHasta    := ""
    Local cNumMeses     := "12"
    Local cBeneficio    := "1"
    Local cEmpRemPoz    := "0"
    Local cEmpRetAct    := "0"
    Local cEmpMedCau    := "0"
    Local cEmpPodJud    := "0"
    Local cAnioPer      := ""

	Default dDataAdmis	:= CToD("//")
	Default cCUILEmp	:= ""
	Default cPeriodRCH	:= ""
	Default nTipoArcGen	:= 0
	Default nArchivo	:= 0
	Default aInfoReg02	:= {}

    cAnioPer    := SubStr(cPeriodRCH, 1, 4)
    cAnoIngres  := AllTrim(Str(Year(dDataAdmis)))

    cPeriDesde	:= IIf(cAnoIngres < cAnioPer, cAnioPer + "0101", cAnioPer + StrZero(Month(dDataAdmis), 2) + "01")
	cPeriHasta	:= SubStr(cPeriodRCH,1,4)+"1231"

    aAdd(aInfoReg02, "02") //1 - Tipo de Registro
    aAdd(aInfoReg02, cCUILEmp) //2 - CUIL
    aAdd(aInfoReg02, cPeriDesde) //3 - Periodo Trabajado Desde
    aAdd(aInfoReg02, cPeriHasta) //4 - Periodo Trabajado Hasta
    aAdd(aInfoReg02, cNumMeses) //5 - Meses
    aAdd(aInfoReg02, cBeneficio) //6 - Beneficio
    aAdd(aInfoReg02, cEmpRemPoz) //7 - ¿El trabajador percibe sus remuneraciones en concepto de "Personal de Pozo" bajo el CCT 396/2004 correspondiente al personal etroleros? (Ley 26.176 - Art. 1°)
    aAdd(aInfoReg02, cEmpRetAct) //8 - ¿El trabajador percibe sus retribuciones por medio de la Asociación Argentina de Actores en calidad de actor? (RG 2442/08)
    aAdd(aInfoReg02, cEmpMedCau) //9 - ¿El trabajador se encuentra alcanzado por una medida cautelar que afecte el régimen de retención del Impuesto?
    aAdd(aInfoReg02, cEmpPodJud) //10 - ¿El trabajador corresponde al poder judicial, no encontrándose alcanzado por el Segundo Párrafo del inc. A) del Art. 82 de la Ley del Impuesto?
    
    //Se realiza la impresión del Registro 02 en el Archivo TXT
    If nTipoArcGen == 1
        For nIteracion := 1 To Len(aInfoReg02)
            cLineaImp += aInfoReg02[nIteracion]
        Next nIteracion
        
        If !Empty(cLineaImp)
            cLineaImp := CRLF + cLineaImp
            FWrite(nArchivo, cLineaImp) //Se escribe el Registro 01 - Cabecera
        EndIf
    EndIf
    
Return

/*/{Protheus.doc} fGenRegXX
    Función utilizada para generar la información de los Registros 03 al
    08 e imprimirlos.
    
    @type  Static Function
    @author marco.rivera
    @since 05/12/2024
    @version 1.0
    @param aEstrReg03, Array, Estructura del Registro 03.
    @param aEstrReg04, Array, Estructura del Registro 04.
    @param aEstrReg05, Array, Estructura del Registro 05.
    @param aEstrReg06, Array, Estructura del Registro 06.
    @param aEstrReg07, Array, Estructura del Registro 07.
    @param aEstrReg08, Array, Estructura del Registro 08.
    @param nTipoArcGen, Numeric, Contiene el Tipo de Archivo a generar.
    @param nArchivo, Numeric, Número (Handle) del archivo generado.
    @example
    fGenRegXX(aEstrReg03, aEstrReg04, aEstrReg05, aEstrReg06, aEstrReg07, aEstrReg08, nTipoArcGen, nArchivo)
/*/
Static Function fGenRegXX(aEstrReg03, aEstrReg04, aEstrReg05, aEstrReg06, aEstrReg07, aEstrReg08, nTipoArcGen, nArchivo, aDataExcel)

    Local cLineaImp     := ""
    Local nIteracion    := 0

    //Variables Registro 03
    Local nTotReg313    := 0
    Local cRuSumR313    := "" //Rubros de Registro 03 para Total Remuneración Gravada

    //Variables Registro 04
    Local nTotReg419    := 0
    Local cRuSumR419    := "" //Rubros de Registro 04 para Total Remuneración No Gravada / No Alcanzada / Exenta
    
    //Variables Registro 05
    Local nTotReg533    := 0
    Local cRuSumR533    := "" //Rubros de Registro 05 para Total Deducciones Generales

    //Variables Registro 06
    Local nTotReg611    := 0
    Local cRuSumR611    := "" //Rubros de Registro 06 para Total de Cargas Familia
    Local nTotReg615    := 0
    Local cRuSumR615    := "" //Rubros de Registro 06 para Total Deducciones Art. 30

    //Variables Registro 07
    Local nTotReg713    := 0
    Local cRuSumR713    := "" //Rubros de Registro 07 para Total Pagos a Cuenta

    //Variables Registro 08
    Local nTotReg803    := 0
    Local nTotReg805    := 0
    Local nTotReg806    := 0
    Local nTotReg807    := 0
    Local nTotReg808    := 0
    Local nTotReg809    := 0

	Local xCont			:= Nil
	Local nTotRemGNG	:= 0
	Local nTotDed30		:= 0

    Default aEstrReg03  := {}
    Default aEstrReg04  := {}
    Default aEstrReg05  := {}
    Default aEstrReg06  := {}
    Default aEstrReg07  := {}
    Default aEstrReg08  := {}
    Default nTipoArcGen := 0
    Default nArchivo    := 0
	Default aDataExcel	:= {}

    cRuSumR313  := "N303|N304|N305|N306|N307|N308|N309|N310|N311|N312"
    
    cRuSumR419  := "N403|N404|N405|N406|N407|N408|N409|N410|N411|N412|"
    cRuSumR419  += "N413|N414|N415|N416|N417|N418|N421|N422"
    
    cRuSumR533  := "N503|N504|N505|N506|N507|N508|N509|N510|N511|N512|"
    cRuSumR533  += "N513|N514|N515|N516|N517|N518|N519|N520|N521|N522|"
    cRuSumR533  += "N523|N524|N525|N526|N527|N528|N529|N530|N531|N532"

    cRuSumR713  := "N703|N704|N705|N706|N707|N708|N709|N710|N711|N712"

	cRuSumR611	:= "N604|N607|N610"

	cRuSumR615	:= "N603|N612|N613|N614"

    //Se realiza generación del Registro 03 - Remuneraciones Gravadas (13 campos)
    If Len(aEstrReg03) > 0

        cLineaImp   := CRLF

        //Se obtiene el Total de Remuneración Gravada
        For nIteracion := 3 To Len(aEstrReg03)
            If aEstrReg03[nIteracion][2] $ cRuSumR313
                nTotReg313 += aEstrReg03[nIteracion][1]
            EndIf
        Next nIteracion

		aEstrReg03[13][1]	:= nTotReg313
		
		//Se define la impresión del Registro 03
		For nIteracion := 1 To Len(aEstrReg03)
			If nIteracion == 1 .Or.  nIteracion == 2 //1 - Tipo de Registro # 2 - CUIL
				xCont := aEstrReg03[nIteracion][1]
			Else
				xCont := fPictDatos(aEstrReg03[nIteracion][1], 1, nTipoArcGen)
			EndIf

			If nTipoArcGen == 1
				cLineaImp += xCont
			ElseIf nTipoArcGen == 2
				AAdd(aDataExcel, xCont)
			EndIf
		Next nIteracion

		If nTipoArcGen == 1
			If !Empty(cLineaImp)
				FWrite(nArchivo, cLineaImp) //Se escribe el Registro 03 - Remuneraciones Gravadas
			EndIf
		EndIf
    EndIf

    //Se realiza generación del Registro 04 - Remuneraciones Exentas o No Alcanzadas (20 campos)
    If Len(aEstrReg04) > 0

        cLineaImp   := CRLF

        //Se obtiene el Total Remuneración No Gravada / No Alcanzada / Exenta
        For nIteracion := 3 To Len(aEstrReg04)
            If aEstrReg04[nIteracion][2] $ cRuSumR419
                nTotReg419 += aEstrReg04[nIteracion][1]
            EndIf
        Next nIteracion

		nTotRemGNG := nTotReg313 + nTotReg419 //Total Remuneración No Gravada + Total de Remuneración Gravada
		aEstrReg04[19][1]	:= nTotReg419
		aEstrReg04[20][1]	:= nTotRemGNG

		//Se define la impresión del Registro 04
		For nIteracion := 1 To Len(aEstrReg04)
			If nIteracion == 1 .Or.  nIteracion == 2 //1 - Tipo de Registro # 2 - CUIL
				xCont := aEstrReg04[nIteracion][1]
			Else
				xCont := fPictDatos(aEstrReg04[nIteracion][1], 1, nTipoArcGen)
			EndIf

			If nTipoArcGen == 1
				cLineaImp += xCont
			ElseIf nTipoArcGen == 2
				AAdd(aDataExcel, xCont)
			EndIf
		Next nIteracion

		If nTipoArcGen == 1
			If !Empty(cLineaImp)
				FWrite(nArchivo, cLineaImp) //Se escribe el Registro 04 - Remuneraciones Exentas o No Alcanzadas
			EndIf
		EndIf
    EndIf

    //Se realiza generación del Registro 05 - Deducciones Generales (33 campos)
    If Len(aEstrReg05) > 0

        cLineaImp   := CRLF

        //Se obtiene el Total de Deducciones Generales
        For nIteracion := 3 To Len(aEstrReg05)
            If aEstrReg05[nIteracion][2] $ cRuSumR533
                nTotReg533 += aEstrReg05[nIteracion][1]
            EndIf
        Next nIteracion

		aEstrReg05[33][1] := nTotReg533	//Total de Deducciones Generales

		//Se define la impresión del Registro 05
		For nIteracion := 1 To Len(aEstrReg05)
			If nIteracion == 1 .Or.  nIteracion == 2 //1 - Tipo de Registro # 2 - CUIL
				xCont := aEstrReg05[nIteracion][1]
			Else
				xCont := fPictDatos(aEstrReg05[nIteracion][1], 1, nTipoArcGen)
			EndIf

			If nTipoArcGen == 1
				cLineaImp += xCont
			ElseIf nTipoArcGen == 2
				AAdd(aDataExcel, xCont)
			EndIf
		Next nIteracion

		If nTipoArcGen == 1
			If !Empty(cLineaImp)
				FWrite(nArchivo, cLineaImp) //Se escribe el Registro 05 - Deducciones Generales
			EndIf
		EndIf
    EndIf

    //Se realiza generación del Registro 06 - Deducciones Art. 30 (17 campos)
    If Len(aEstrReg06) > 0

        cLineaImp   := CRLF

        //Se obtiene el Total de Cargas Familiares y Total de Deducciones Art. 30
        For nIteracion := 3 To Len(aEstrReg06)
            If aEstrReg06[nIteracion][2] $ cRuSumR611
                nTotReg611 += aEstrReg06[nIteracion][1]
            EndIf
            If aEstrReg06[nIteracion][2] $ cRuSumR615
                nTotReg615 += aEstrReg06[nIteracion][1]
            EndIf
        Next nIteracion

		nTotDed30			:= nTotReg615 + nTotReg611	//Total Deducciones Art. 30
		aEstrReg06[11][1]	:= nTotReg611				//Total de Cargas de Familia
		aEstrReg06[15][1]	:= nTotDed30
		//Se define la impresión del Registro 06
		For nIteracion := 1 To Len(aEstrReg06)
			If nIteracion == 1 .Or.  nIteracion == 2 //1 - Tipo de Registro # 2 - CUIL
				xCont := aEstrReg06[nIteracion][1]
			ElseIf nIteracion == 5 .Or. nIteracion == 6 .Or. nIteracion == 8 .Or. nIteracion == 9 .Or. nIteracion == 16 .Or. nIteracion == 17
				xCont := fPictDatos(aEstrReg06[nIteracion][1], 2, nTipoArcGen) //Cantidad de Hijos
			Else
				xCont := fPictDatos(aEstrReg06[nIteracion][1], 1, nTipoArcGen)
			EndIf

			If nTipoArcGen == 1
				cLineaImp += xCont
			ElseIf nTipoArcGen == 2
				AAdd(aDataExcel, xCont)
			EndIf
		Next nIteracion

		If nTipoArcGen == 1
			If !Empty(cLineaImp)
				FWrite(nArchivo, cLineaImp) //Se escribe el Registro 06 - Deducciones Art. 30
			EndIf
		EndIf
    EndIf

    //Se realiza generación del Registro 07 - Pagos a Cuenta (13 campos)
    If Len(aEstrReg07) > 0

        cLineaImp   := CRLF

        //Se obtiene el Total Pagos a Cuenta
        For nIteracion := 3 To Len(aEstrReg07)
            If aEstrReg07[nIteracion][2] $ cRuSumR713
                nTotReg713 += aEstrReg07[nIteracion][1]
            EndIf
        Next nIteracion

		aEstrReg07[13][1] := nTotReg713

		//Se define la impresión del Registro 07
		For nIteracion := 1 To Len(aEstrReg07)
			If nIteracion == 1 .Or.  nIteracion == 2 //1 - Tipo de Registro # 2 - CUIL
				xCont := aEstrReg07[nIteracion][1]
			Else
				xCont := fPictDatos(aEstrReg07[nIteracion][1], 1, nTipoArcGen)
			EndIf

			If nTipoArcGen == 1
				cLineaImp += xCont
			ElseIf nTipoArcGen == 2
				AAdd(aDataExcel, xCont)
			EndIf
		Next nIteracion

		If nTipoArcGen == 1
			If !Empty(cLineaImp)
				FWrite(nArchivo, cLineaImp) //Se escribe el Registro 07 - Pagos a Cuenta
			EndIf
		EndIf
    EndIf
    
    //Se realiza generación del Registro 08 - Cálculo del Impuesto (10 campos)
    If Len(aEstrReg08) > 0

        cLineaImp   := CRLF

        //Se obtiene el Total Pagos a Cuenta
        For nIteracion := 3 To Len(aEstrReg08)
            If aEstrReg08[nIteracion][2] $ "N805"
                nTotReg805 := aEstrReg08[nIteracion][1] //Impuesto Determinado
            ElseIf aEstrReg08[nIteracion][2] $ "N806"
                nTotReg806 := aEstrReg08[nIteracion][1] //Impuesto Retenido
            ElseIf aEstrReg08[nIteracion][2] $ "N808"
                nTotReg808 := aEstrReg08[nIteracion][1] //Impuesto Auto-retenido RG 5683
            EndIf
        Next nIteracion

        nTotReg803  := nTotReg313 - nTotReg533 - nTotReg615 - nTotReg611 //Total Remuneración Gravada - Total Deducciones Generales - Total Deducciones Art. 30
        nTotReg807  := nTotReg805 - nTotReg806 //Impuesto Determinado - Impuesto Retenido
        nTotReg809  := nTotReg807 - nTotReg808 - nTotReg713 //Subtotal saldo determinado antes de Pagos a Cuenta - Impuesto Autoretenido RG 5683 - TOTAL PAGOS A CUENTA (Apartado "G" Anexo II)
        
		aEstrReg08[3][1]	:= nTotReg803					//Remuneración Sujeta a Impuesto
		aEstrReg08[4][1]	:= fObtAlic(aEstrReg08[4][1])	//Alícuota – Art. 94 - LIG
        aEstrReg08[7][1]	:= nTotReg807					//Subtotal saldo determinado antes de Auto-retención / Pagos a Cuenta
        aEstrReg08[8][1]	:= nTotReg808					//Impuesto Auto-retenido RG 5683
        aEstrReg08[9][1]	:= nTotReg809					//Saldo Determinado

		//Se define la impresión del Registro 08
		For nIteracion := 1 To Len(aEstrReg08)
			If nIteracion == 1 .Or.  nIteracion == 2 .Or. nIteracion == 4 //1 - Tipo de Registro # 2 - CUIL # 4 - Alícuota – Art. 94 - LIG
				xCont := aEstrReg08[nIteracion][1]
			Else
				xCont := fPictDatos(aEstrReg08[nIteracion][1], 1, nTipoArcGen)
			EndIf

			If nTipoArcGen == 1
				cLineaImp += xCont
			ElseIf nTipoArcGen == 2
				AAdd(aDataExcel, xCont)
			EndIf
		Next nIteracion

		If nTipoArcGen == 1
			If !Empty(cLineaImp)
				FWrite(nArchivo, cLineaImp) //Se escribe el Registro 08 - Cálculo del Impuesto
			EndIf
		EndIf
    EndIf

Return

/*/{Protheus.doc} fGetMovSRV
    Función utilizada para obterner movimientos de SRV para los conceptos
    mediante los campos RV_COD13 (nOpcion = 1) o RV_COD (nOpcion = 2).
    
    @type  Static Function
    @author marco.rivera
    @since 06/12/2024
    @version 1.0
    @param cCodFIAG, Char, Código del Rubro informado en el campo RV_COD13.
    @param cAliasAux, Char, Código de la tabla SRC o SRD.
    @param cPrefTab, Char, Prefijo de la tabla SRD (RD_) o SRC (RD_).
    @param cFilialMov, Char, Filial utilizada para la busqueda en SRC o SRD.
    @param cMatMov, Char, Matrícula del empleado.
    @param nOpcion, Numeric, Opción para la búsqueda de información 1 - RV_COD13 y 2 - RV_COD.
    @param cCodConcep, Char, Código del concepto a buscar.
    @param cProceso, Char, Proceso a utilizar en la búsqueda.
    @param cProcedimi, Char, Procedimiento a utilizar en la búsqueda.
    @param cPerParam, Char, Periodo a utilizar en la búsqueda.
    @param cNumPago, Char, Número de pago a utilizar en la búsqueda.
    fGetMovSRV(cCodFIAG, cAliasAux, cPrefTab, cFilialMov, cMatMov, nOpcion, cCodConcep, cProceso, cProcedimi, cPerParam, cNumPago)
/*/
Static Function fGetMovSRV(cCodFIAG, cAliasAux, cPrefTab, cFilialMov, cMatMov, nOpcion, cCodConcep, cProceso, cProcedimi, cPerParam, cNumPago)
    
    Local cQuery        := ""
    Local cTabTmpSRV    := ""
    Local nRenumera     := 0
    Local cFilialSRV    := xFilial("SRV")
    Local oObjTmpQry	:= Nil
    Local nNumParQry    := 1

    Default nOpcion     := 1
    Default cCodConcep  := ""

    cQuery := "SELECT SUM(" + cPrefTab + "VALOR) " + cPrefTab + "VALOR "
    cQuery += "FROM "
    cQuery +=  " ? " + cAliasAux + ", ? SRV " 
    cQuery += "WHERE " + cAliasAux + "." + cPrefTab + "MAT = ? AND "
    cQuery += cAliasAux + "." + cPrefTab + "FILIAL	= ? AND "
    cQuery += cAliasAux + "." + cPrefTab + "PROCES	= ? AND "
    cQuery += cAliasAux + "." + cPrefTab + "ROTEIR	= ? AND "
    cQuery += cAliasAux + "." + cPrefTab + "PERIODO	= ? AND "
    cQuery += cAliasAux + "." + cPrefTab + "SEMANA	= ? AND "
    cQuery += cAliasAux + "." + cPrefTab + "PD = SRV.RV_COD AND "

    If nOpcion ==1
        cQuery += "SRV.RV_COD13 = ? AND "
    Elseif nOpcion == 2
        cQuery += "SRV.RV_COD = ? AND "
    Endif

    cQuery += cAliasAux + ".D_E_L_E_T_= ? AND "
    cQuery += "SRV.D_E_L_E_T_= ? AND "
    cQuery += "SRV.RV_FILIAL = ? "

    oObjTmpQry := FwExecStatement():New(cQuery)

    oObjTmpQry:SetUnsafe(nNumParQry++, RetSqlName(cAliasAux))
    oObjTmpQry:SetUnsafe(nNumParQry++, RetSqlName("SRV"))
    oObjTmpQry:SetString(nNumParQry++, cMatMov)
    oObjTmpQry:SetString(nNumParQry++, cFilialMov)
    oObjTmpQry:SetString(nNumParQry++, cProceso)
    oObjTmpQry:SetString(nNumParQry++, cProcedimi)
    oObjTmpQry:SetString(nNumParQry++, cPerParam)
    oObjTmpQry:SetString(nNumParQry++, cNumPago)

    If nOpcion ==1
        oObjTmpQry:SetString(nNumParQry++, cCodFIAG)
    Elseif nOpcion == 2
        oObjTmpQry:SetString(nNumParQry++, cCodConcep)
    Endif
    oObjTmpQry:SetString(nNumParQry++, " ")
    oObjTmpQry:SetString(nNumParQry++, " ")
    oObjTmpQry:SetString(nNumParQry++, cFilialSRV)

    cTabTmpSRV := oObjTmpQry:OpenAlias()

    If (cTabTmpSRV)-> (!Eof())
        nRenumera := Abs((cTabTmpSRV)->&((cPrefTab) + "VALOR"))
    EndIf

    (cTabTmpSRV)->(DBCloseArea())

    If oObjTmpQry <> Nil
        Freeobj(oObjTmpQry)
    EndIf

Return nRenumera

/*/{Protheus.doc} fPictDatos
    Función utilizada para convertir los valores en el formato solicitado por
    el F1359.

    @type  Static Function
    @author marco.rivera
    @since 09/12/2024
    @version 1.0
    @param nValor, Numeric, Valor a convertir.
    @param nOpcion, Numeric, Opción que define el formato que se aplicará.
	@param nTipoArcGen, Numeric, Contiene el Tipo de Archivo a generar.
	@return xRetDato, Char/Numeric, Cantidad con formato Texto o Número.
    @example
    fPictDatos(nValor, nOpcion, nTipoArcGen)
/*/
Static Function fPictDatos(nValor, nOpcion, nTipoArcGen)

    Local xRetDato      := Nil
    Local cPictVal15    := "@E 999999999999.99"
    Local nValToConv    := 0

    Default nValor      := 0
    Default nOpcion     := 0
	Default nTipoArcGen	:= 0

    If nValor > 0
        nValToConv := nValor
    EndIf

	If nTipoArcGen == 1
		If nOpcion == 1
			xRetDato := PadL(STRTRAN(AllTrim(STRTRAN(Transform(nValToConv, cPictVal15), ",", "")), ".", ""), 15, "0")
		ElseIf nOpcion == 2
			xRetDato := StrZero(nValToConv, 2)
		EndIf
	ElseIf nTipoArcGen == 2
		xRetDato := nValToConv
	EndIf

Return xRetDato

/*/{Protheus.doc} fObtAlic
    Función utilizada para obtener el valor de la alicuota de acuerdo al
    Art. 94 LIG.

    @type  Static Function
    @author marco.rivera
    @since 10/12/2024
    @version 1.0
    @param nValAlic, Numeric, Valor de la alicuota.
    @return cRetAlic, Char, Texto equivalente de la alicuota en base a Art. 94 LIG
    @example
    fObtAlic(nValAlic)
/*/
Static Function fObtAlic(nValAlic)

    Local cRetAlic      := "00"
    Local aAlicuotas    := {}
    Local nIteracion    := 0

    Default nValAlic    := 0

    aAdd(aAlicuotas, {0, "00"})
    aAdd(aAlicuotas, {5, "01"})
    aAdd(aAlicuotas, {9, "02"})
    aAdd(aAlicuotas, {12, "03"})
    aAdd(aAlicuotas, {15, "04"})
    aAdd(aAlicuotas, {19, "05"})
    aAdd(aAlicuotas, {23, "06"})
    aAdd(aAlicuotas, {27, "07"})
    aAdd(aAlicuotas, {31, "08"})
    aAdd(aAlicuotas, {35, "09"})

    For nIteracion := 1 To Len(aAlicuotas)
        If nValAlic == aAlicuotas[nIteracion, 1]
            cRetAlic := aAlicuotas[nIteracion, 2]
        EndIf
    Next nIteracion
    
Return cRetAlic

/*/{Protheus.doc} fTabTmpMov
    Función utilizada para extraer los registros de los empleados a procesar en el F1359.

    @type  Static Function
    @author marco.rivera
    @since 11/12/2024
    @version 1.0
    @param oStatement, Object, Objeto de la clase FwExecStatement para tratamiento de consultas.
    @param cPrefTab, Char, Prefijo de la tabla SRD (RD_) o SRC (RD_).
    @param cAliasAux, Char, Código de la tabla SRC o SRD.
    @param cCentrCIni, Char, Centro de Costo inicial a utilizar en la búsqueda.
    @param cCentrCFin, Char, Centro de Costo final a utilizar en la búsqueda.
    @param cMatricula, Char, Matrículas a utilizar en la búsqueda.
    @param cProceso, Char, Proceso a utilizar en la búsqueda.
    @param cProcedimi, Char, Procedimiento a utilizar en la búsqueda.
    @param cPerParam, Char, Periodo a utilizar en la búsqueda.
    @param cNumPago, Char, Número de pago a utilizar en la búsqueda.
	@param nTipoPrese, Numeric, Contiene el Tipo de Presentación.
    @return cRetTabTmp, Char, Retorna el nombre de la tabla temporal.
    @example
    fTabTmpMov(oStatement, cPrefTab, cAliasAux, cCentrCIni, cCentrCFin, cMatricula, cProceso, cProcedimi, cPerParam, cNumPago)
/*/
Static Function fTabTmpMov(oStatement, cPrefTab, cAliasAux, cCentrCIni, cCentrCFin, cMatricula, cProceso, cProcedimi, cPerParam, cNumPago, nTipoPrese)

    Local cFilialSRA    := xFilial("SRA")
    Local cRetTabTmp    := ""
    Local nNumParQry    := 1
	Local lFiltraSit	:= .F.

    Default oStatement  := Nil
    Default cPrefTab    := ""
    Default cAliasAux   := ""
    Default cCentrCIni  := ""
    Default cCentrcFin  := ""
    Default cMatricula  := ""
    Default cProceso    := ""
    Default cProcedimi  := ""
    Default cPerParam   := ""
    Default cNumPago    := ""
	Default nTipoPrese	:= 0

	lFiltraSit := !(nTipoPrese == 2)

    cQuery := " SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_ACTTRAN, RA_ADMISSA, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_ZONDES, SUM(" + cPrefTab + "VALOR) RC_VALOR "
    cQuery += " FROM "
    cQuery += " ? SRA, "
    cQuery += " ? " + cAliasAux + " "
    cQuery += " WHERE SRA.D_E_L_E_T_= ? "
    cQuery += " AND " + cAliasAux + ".D_E_L_E_T_= ? "
    cQuery += " AND SRA.RA_FILIAL = ? "
    cQuery += " AND " + cAliasAux + "." + cPrefTab + "FILIAL = ? "
    cQuery += " AND SRA.RA_CC BETWEEN ? AND ? "
    
    If !Empty(cMatricula)
        cQuery  +=	" AND ? "
    Endif
    
    cQuery += " AND " + cAliasAux + "." + cPrefTab + "MAT = RA_MAT "
    cQuery += " AND " + cAliasAux + "." + cPrefTab + "FILIAL = RA_FILIAL "
    cQuery += " AND " + cAliasAux + "." + cPrefTab + "PROCES = ? "
    cQuery += " AND " + cAliasAux + "." + cPrefTab + "ROTEIR = ? "
    cQuery += " AND " + cAliasAux + "." + cPrefTab + "PERIODO = ? "
    cQuery += " AND " + cAliasAux + "." + cPrefTab + "SEMANA = ? "
	If lFiltraSit
		cQuery += " AND RA_SITFOLH <> ? "
	EndIf
    cQuery += "GROUP BY RA_FILIAL, RA_MAT, RA_CIC, RA_ACTTRAN, RA_ADMISSA, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_ZONDES "
    cQuery += "ORDER BY RA_FILIAL, RA_MAT"

    oStatement := FwExecStatement():New(cQuery)

    oStatement:SetUnsafe(nNumParQry++, RetSqlName("SRA"))
    oStatement:SetUnsafe(nNumParQry++, RetSqlName(cAliasAux))
    oStatement:SetString(nNumParQry++, " ")
    oStatement:SetString(nNumParQry++, " ")
    oStatement:SetString(nNumParQry++, cFilialSRA)
    oStatement:SetString(nNumParQry++, cFilialSRA)
    oStatement:SetString(nNumParQry++, cCentrCIni)
    oStatement:SetString(nNumParQry++, cCentrCFin)
    If !Empty(cMatricula)
        oStatement:SetUnsafe(nNumParQry++, cMatricula)
    Endif
    oStatement:SetString(nNumParQry++, cProceso)
    oStatement:SetString(nNumParQry++, cProcedimi)
    oStatement:SetString(nNumParQry++, cPerParam)
    oStatement:SetString(nNumParQry++, cNumPago)
	If lFiltraSit
		oStatement:SetString(nNumParQry++, "D")
	EndIf

    cRetTabTmp := oStatement:OpenAlias()
    
Return cRetTabTmp

/*/{Protheus.doc} fObtEstReg
    Función utilizada para retornar la Estructura de los registros 03 al 08.
    
    @type  Static Function
    @author marco.rivera
    @since 11/12/2024
    @version 1.0
    @param aEstrRegXX, Array, Estructura del Registro XX (03 al 08) a procesar.
    @param nNumReg, Numeric, Número del Registro (3 al 8) a procesar.
    @param cCUILEmp, Char, CUIL del Empleado.
    @param aRubrosRCC, Array, Arreglo con 3 posiciones con información de los rubros.
    @param cAliasAux, Char, Código de la tabla SRC o SRD.
    @param cPrefTab, Char, Prefijo de la tabla SRD (RD_) o SRC (RD_).
    @param cFilTabTmp, Char, Filial a utilizar en la búsqueda.
    @param cMatTabTmp, Char, Matrícula a utilizar en la búsqueda.
    @param cProceso, Char, Proceso a utilizar en la búsqueda.
    @param cProcedimi, Char, Procedimiento a utilizar en la búsqueda.
    @param cPerParam, Char, Periodo a utilizar en la búsqueda.
    @param cNumPago, Char, Número de pago a utilizar en la búsqueda.
    @example
    fObtEstReg(aEstrRegXX, nNumReg, cCUILEmp, aRubrosRCC, cAliasAux, cPrefTab, cFilTabTmp, cMatTabTmp, cProceso, cProcedimi, cPerParam, cNumPago)
/*/
Static Function fObtEstReg(aEstrRegXX, nNumReg, cCUILEmp, aRubrosRCC, cAliasAux, cPrefTab, cFilTabTmp, cMatTabTmp, cProceso, cProcedimi, cPerParam, cNumPago)

    Local nIteracion    := 0
    Local nPosRubro     := ""

    Default aEstrRegXX  := {}
    Default nNumReg     := 0
    Default cCUILEmp    := ""
    Default aRubrosRCC  := {}
    Default cAliasAux   := ""
    Default cPrefTab    := ""
    Default cFilTabTmp  := ""
    Default cMatTabTmp  := ""
    Default cProceso    := ""
    Default cProcedimi  := ""
    Default cPerParam   := ""
    Default cNumPago    := ""

    aEstrRegXX[1] := {StrZero(nNumReg, 2),""}
    aEstrRegXX[2] := {cCUILEmp, ""}
    
    For nIteracion := 3 To Len(aEstrRegXX)
        
        //Se determina si existe la posición del concepto en los rubros
        nPosRubro := aScan(aRubrosRCC, {|x| x[2] == nNumReg .And. x[3] == nIteracion})
        
        //Se existe la posición, se buscan sus movimientos en SRV
        If nPosRubro > 0
            aEstrRegXX[nIteracion] := {fGetMovSRV(aRubrosRCC[nPosRubro, 1], cAliasAux, cPrefTab, cFilTabTmp, cMatTabTmp, 1, , cProceso, cProcedimi, cPerParam, cNumPago), aRubrosRCC[nPosRubro, 1]}
        Else
            aEstrRegXX[nIteracion] := {0, ""}
        EndIf
        
    Next nIteracion
    
Return Nil

/*/{Protheus.doc} F1359VldPe
	Función utilizada para validar el periodo informado en la pregunta ¿Periodo?.

	@type  Function
	@author marco.rivera
	@since 11/12/2024
	@version 1.0
    @param cPeriodo, Char, Contiene el periodo informado en las preguntas.
	@param nTipoPrese, Numeric, Contiene el Tipo de Presentación.
	@return lRet, Logical, Retorna .T. si el periodo es correcto.
	@example
	F1359VldPe(cPeriodo, nTipoPrese)
	/*/
Function F1359VldPe(cPeriodo, nTipoPrese)
	Local lRet          := .T. 
	
    Default cPeriodo    := ""
	Default nTipoPrese  := 0

	If (nTipoPrese == 1 .Or. nTipoPrese == 4) .And. Substr(cPeriodo,1,4) < "2024" 
		lRet := .F.
		MsgInfo(STR0017 + "2024" + ").", STR0003) //"Informe un período válido (a partir del " + "TOTVS"
	ElseIf (nTipoPrese == 2 .OR. nTipoPrese == 3) .And. cPeriodo < "202401" 
		lRet := .F.
		MsgInfo(STR0017 + "202401" + ").", STR0003) //"Informe un período válido (a partir del " + "TOTVS"
	EndIf

Return lRet

/*/{Protheus.doc} fGenArcPDF
    
    Función utilizada para iniciar la generación del Archivo PDF para el F1359.
    
    @type  Static Function
    @author marco.rivera
    @since 29/01/2025
    @version 1.0
    @param aDetEmpPDF, Array, Arreglo con datos del empleado y sus rubros
    @return lRet, Logical, Retorna .T. si se imprimió correctamente el PDF
    @example
    fGenArcPDF(aDetEmpPDF)
/*/
Static Function fGenArcPDF(aDetEmpPDF)
    Local lRet          := .T.
    Local nIteracion    := 0
    Local nNumRegTmp    := 0

    Default aDetEmpPDF  := {}

    nNumRegTmp := Len(aDetEmpPDF)
    
    If !isBlind() //Si no es ejecución por rutina automatizada
        //Se define regla de avance
        ProcRegua(nNumRegTmp)
    EndIf

    For nIteracion := 1 To nNumRegTmp

        If !isBlind() //Si no es ejecución por rutina automatizada
            //Se muestra regla de progreso
            IncProc(STR0010 + cValToChar(nIteracion) + STR0011 + cValToChar(nNumRegTmp) + STR0012) //"Procesando " + " de " + " registros..."
        EndIf
        
        //Se inicia impresión del PDF
        fDefImpPDF(aDetEmpPDF[nIteracion])

    Next nIteracion
    
Return lRet

/*/{Protheus.doc} nomeStaticFunction
    Función utilizada para realizar la definición de la impresión del PDF.
    
    @type  Static Function
    @author marco.rivera
    @since 29/01/2025
    @version 1.0
    @param aDataEmp, Array, Arreglo con datos del empleado y sus rubros
    @return lRet, Logical, Retorna .T. si se imprimió correctamente el PDF
    @example
    fDefImpPDF(aDataEmp)
/*/
Static Function fDefImpPDF(aDataEmp)

    Local lRet          := .T.
    Local cArcGenNom    := Space(100)
    Local oPrinter      := Nil
    Local cRutArcPDF    := AllTrim(MV_PAR14)

    Default aDataEmp    := {}

    cArcGenNom := StrTran(AllTrim(aDataEmp[1, 1, 4]), " ", "_") + "_" + aDataEmp[1, 1, 3] + "_" + SubStr(AllTrim(MV_PAR10), 1, 4) //Sucursal + Matrícula + Periodo

    oPrinter := FWMSPrinter():New(cArcGenNom, IMP_PDF, .F., cRutArcPDF, .T., , , , .T., , , , , , )  //Inicializa el objeto
	oPrinter:SetMargin(40, 10, 40, 10) //Setea márgenes del documento
	oPrinter:SetPortrait() //Define orientación de la página modo retrato =  Horizontal
    oPrinter:SetPaperSize(DMPAPER_A4) //Setea tamaño de la hoja: 9 - A4 (210mm x 297mm  620 x 876)
    oPrinter:cPathPDF := cRutArcPDF //Setea ruta de generación de PDF

    //Se inicia definición de impresión
    fDetImpPDF(@oPrinter, aDataEmp)

    oPrinter:SetViewPDF(.F.) //Se setea visualización del PDF
    oPrinter:Print() //Realiza impresión del PDF

    //Limpia objeto utilizado
    FreeObj(oPrinter)
    oPrinter := Nil
    
Return lRet

/*/{Protheus.doc} fDetImpPDF
    Función utilizada para definir el detalle de impresión del Archivo PDF.
    
    @type  Static Function
    @author marco.rivera
    @since 29/01/2025
    @version 1.0
    @param oPrinter, Object, Objeto de impresión
    @param aDataEmp, Array, Arreglo con datos del empleado y sus rubros
    @return lRet, Logical, Retorna .T. si se definió correctamente la impresión
    @example
    fDetImpPDF(oPrinter, aDataEmp)
/*/
Static Function fDetImpPDF(oPrinter, aDataEmp)

    Local lRet          := .T.
    Local oFontTit      := Nil
    Local oFontPar      := Nil
    Local aAuxInfImp    := {}
    Local aAuxDatEmp    := {}
    Local aDataSM0      := {}
    Local aCamposSM0    := {"M0_CGC", "M0_NOME"}
	Local nPosVerti     := 50
    Local nPorVerTxt    := 5
	Local nPosBoxRod    := 0
    Local nAncho        := 13
    Local cStartPath    := GetSrvProfString("Startpath","")
    Local cPictIdent    := PesqPict("SRA", "RA_CIC")

    //Variables de Remuneraciones Gravadas
    Local nValRub303    := 0
    Local nValRub304    := 0
    Local nValRub305    := 0
    Local nValRub306    := 0
    Local nValRub307    := 0
    Local nValRub308    := 0
    Local nValRub309    := 0
    Local nValRub310    := 0
    Local nValRub311    := 0
    Local nValRub312    := 0
    Local nValRemBNH    := 0
    Local nValSAC       := 0
    Local nValOERBNH    := 0
    Local nValOESAC     := 0
    Local nTotRemGra    := 0

    //Variables de Remuneraciones Exentas o No Alcanzadas
    Local nValRub403    := 0
    Local nValRub404    := 0
    Local nValRub405    := 0
    Local nValRub406    := 0
    Local nValRub407    := 0
    Local nValRub408    := 0
    Local nValRub409    := 0
    Local nValRub410    := 0
    Local nValRub411    := 0
    Local nValRub412    := 0
    Local nValRub413    := 0
    Local nValRub414    := 0
    Local nValRub415    := 0
    Local nValRub416    := 0
    Local nValRub417    := 0
    Local nValRub418    := 0
    Local nTotRemNGr    := 0
    Local nTotRemune    := 0

    //Variables de Deducciones Generales
    Local nValRub503    := 0
    Local nValRub504    := 0
    Local nValRub505    := 0
    Local nValRub506    := 0
    Local nValRub507    := 0
    Local nValRub508    := 0
    Local nValRub509    := 0
    Local nValRub510    := 0
    Local nValRub511    := 0
    Local nValRub512    := 0
    Local nValRub513    := 0
    Local nValRub514    := 0
    Local nValRub515    := 0
    Local nValRub516    := 0
    Local nValRub517    := 0
    Local nValRub518    := 0
    Local nValRub519    := 0
    Local nValRub520    := 0
    Local nValRub521    := 0
    Local nValRub522    := 0
    Local nValRub523    := 0
    Local nValRub524    := 0
    Local nValRub525    := 0
    Local nValRub526    := 0
    Local nValRub527    := 0
    Local nValRub528    := 0
    Local nValRub529    := 0
    Local nValRub530    := 0
    Local nValRub531    := 0
    Local nValRub532    := 0
    Local nTotDedGen    := 0

    //Variables de Deducciones Personales
    Local nValRub603    := 0
    Local nValRub604    := 0
    Local nValRub605    := 0
    Local nValRub606    := 0
    Local nValRub607    := 0
    Local nValRub608    := 0
    Local nValRub609    := 0
    Local nValRub610    := 0
    Local nValRub612    := 0
    Local nValRub613    := 0
    Local nValRub614    := 0
    Local nValRub616    := 0
    Local nValRub617    := 0
    Local nTotCarFam    := 0
    Local nTotDedPer    := 0

    //Variables de Pagos a Cuenta
    Local nValRub703    := 0
    Local nValRub704    := 0
    Local nValRub705    := 0
    Local nValRub706    := 0
    Local nValRub707    := 0
    Local nValRub708    := 0
    Local nValRub709    := 0
    Local nValRub710    := 0
    Local nValRub711    := 0
    Local nValRub712    := 0
    Local nTotPagACt    := 0

    //Variables de Determinación de Impuesto
    Local nValRub803    := 0
    Local nValRub804    := 0
    Local nValRub805    := 0
    Local nValRub806    := 0
    Local nValRub808    := 0
    Local nValRemSAI    := 0
    Local nSubTotPAC    := 0
    Local nSalAPagar    := 0

    Default oPrinter    := Nil
    Default aDataEmp    := {}

    //Se obtiene información de la Sucursal
    aDataSM0 := FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aCamposSM0)

    oFontTit := TFont():New('Arial', , -12, .T., .T.) //Fuente del Titulo
	oFontPar := TFont():New('Arial', , -10, .T.)     //Fuente del Párrafo

    oPrinter:StartPage()

    //Impresión del Logo
    oPrinter:SayBitmap((nPosVerti - 20) + 10, 15, cStartPath + "lgrl" + FWGrpCompany() + ".bmp", 80, 40)
    nPosVerti += 5
    
    oPrinter:Say(nPosVerti, 110, STR0020, oFontPar) //"LIQUIDACIÓN DE IMPUESTOS A LAS GANANCIAS - 4TA. CATEGORÍA RELACIÓN DE DEPENDENCIA"
    nPosVerti += 70
    
    //Impresión de Fecha
    oPrinter:Say(nPosVerti, 10, STR0021 + DToC(MV_PAR12), oFontPar) //"Fecha: "
    nPosVerti += 15

    //Impresión de Beneficiario
    aAuxInfImp := aDataEmp[1, 1]

    //(CUIL + Nombre + Matrícula)
    oPrinter:Say(nPosVerti, 10, STR0022 + Transform(aAuxInfImp[1], cPictIdent) + ", " + AllTrim(aAuxInfImp[2]) + ", " + AllTrim(aAuxInfImp[3]), oFontPar) //"Beneficiario: "
    nPosVerti += 15

    //Impresión de Agente de Retención
    //(CUIT + Denominación Legal)
    oPrinter:Say(nPosVerti, 10, STR0023 + Transform(aDataSM0[1][2], cPictIdent) + ", " + AllTrim(aDataSM0[2][2]), oFontPar) //"Agente de Retención: "
    nPosVerti += 15

    //Impresión del Periodo Fiscal
    oPrinter:Say(nPosVerti, 10, STR0024 + SubStr(AllTrim(MV_PAR10), 1, 4), oFontPar) //"Periodo Fiscal: "
    nPosVerti += 30

    //Se comienza impresión del detalle
    nPosBoxRod := nPosVerti - 15

    //Impresión del box REMUNERACIONES GRAVADAS
    fImpBoxTxt(@nPosVerti, @nPosBoxRod, @oPrinter, STR0025, oFontTit, nAncho, nPorVerTxt) //"REMUNERACIONES GRAVADAS"
    
    //Impresión del box Abonadas por el agente de retención
    fImpBoxTxt(@nPosVerti, @nPosBoxRod, @oPrinter, STR0026, oFontTit, nAncho, nPorVerTxt) //"Abonadas por el Agente de Retención"

    //Arreglo auxiliar que contiene el detalle de Remuneraciones Gravadas
    aAuxDatEmp := aDataEmp[2]

    //Impresión de Rubros para Abonadas por agente de retención
    nValRub303 := fObtValRub(aAuxDatEmp, "N303")
    nValRub304 := fObtValRub(aAuxDatEmp, "N304")
    nValRub305 := fObtValRub(aAuxDatEmp, "N305")
    nValRub306 := fObtValRub(aAuxDatEmp, "N306")
    nValRub307 := fObtValRub(aAuxDatEmp, "N307")
    nValRub308 := fObtValRub(aAuxDatEmp, "N308")
    nValRub309 := fObtValRub(aAuxDatEmp, "N309")
    nValRub310 := fObtValRub(aAuxDatEmp, "N310")
    nValRub311 := fObtValRub(aAuxDatEmp, "N311")
    nValRub312 := fObtValRub(aAuxDatEmp, "N312")

    nValRemBNH  := nValRub303 + nValRub304
    nValSAC     := nValRub305 + nValRub306
    nValOERBNH  := nValRub307 + nValRub308
    nValOESAC   := nValRub309 + nValRub310

    //Total de Remuneraciones Gravadas
    nTotRemGra := nValRemBNH + nValSAC + nValOERBNH + nValOESAC + nValRub311 + nValRub312

    //Arreglo con Rubros para REMUNERACIONES GRAVADAS (Abonadas por el Agenta de Retención)
    aAuxInfImp := {}
    aAdd(aAuxInfImp, {STR0027, nValRemBNH}) //'Remuneración bruta y no habituales'
    aAdd(aAuxInfImp, {STR0028, nValSAC}) //'SAC'
    aAdd(aAuxInfImp, {STR0029, nValRub311}) //'Ajuste de Períodos Anteriores sobre Remuneraciones Gravadas'

    //Impresión de Rubros
    fImpRubros(@nPosVerti, @nPosBoxRod, @oPrinter, aAuxInfImp, oFontPar, nPorVerTxt, nAncho)

    //Impresión del box Otros Empleos
    fImpBoxTxt(@nPosVerti, @nPosBoxRod, @oPrinter, STR0030, oFontTit, nAncho, nPorVerTxt) //"Otros Empleos"

    //Arreglo con Rubros para REMUNERACIONES GRAVADAS (Otros Empleos)
    aAuxInfImp := {}
    aAdd(aAuxInfImp, {STR0031, nValOERBNH}) //'Otros Empleos - Remuneración Bruta y no habituales'
    aAdd(aAuxInfImp, {STR0032, nValOESAC}) //'Otros Empleos - SAC'
    aAdd(aAuxInfImp, {STR0033, nValRub312}) //'Otros Empleos - Ajustes de Períodos Anteriores sobre Remuneraciones Gravadas'
    aAdd(aAuxInfImp, {STR0034, nTotRemGra}) //'TOTAL REMUNERACIÓN GRAVADA'

    //Impresión de Rubros
    fImpRubros(@nPosVerti, @nPosBoxRod, @oPrinter, aAuxInfImp, oFontPar, nPorVerTxt, nAncho)

    //Impresión del box REMUNERACIONES EXENTAS o NO ALCANZADAS
    fImpBoxTxt(@nPosVerti, @nPosBoxRod, @oPrinter, STR0035, oFontTit, nAncho, nPorVerTxt) //"REMUNERACIONES EXENTAS o NO ALCANZADAS"

    //Impresión del box Abonadas por el agente de retención
    fImpBoxTxt(@nPosVerti, @nPosBoxRod, @oPrinter, STR0036, oFontTit, nAncho, nPorVerTxt) //"Abonadas por el agente de retención"

    //Arreglo auxiliar que contiene el detalle de Remuneraciones Exentas o No Alcanzadas
    aAuxDatEmp := aDataEmp[3]
    
    //Posiciones de Rubros para Abonadas por el agente de retención
    nValRub403 := fObtValRub(aAuxDatEmp, "N403")
    nValRub404 := fObtValRub(aAuxDatEmp, "N404")
    nValRub405 := fObtValRub(aAuxDatEmp, "N405")
    nValRub406 := fObtValRub(aAuxDatEmp, "N406")
    nValRub407 := fObtValRub(aAuxDatEmp, "N407")
    nValRub408 := fObtValRub(aAuxDatEmp, "N408")
    nValRub409 := fObtValRub(aAuxDatEmp, "N409")
    nValRub410 := fObtValRub(aAuxDatEmp, "N410")
    nValRub411 := fObtValRub(aAuxDatEmp, "N411")
    nValRub412 := fObtValRub(aAuxDatEmp, "N412")
    nValRub413 := fObtValRub(aAuxDatEmp, "N413")
    nValRub414 := fObtValRub(aAuxDatEmp, "N414")
    nValRub415 := fObtValRub(aAuxDatEmp, "N415")
    nValRub416 := fObtValRub(aAuxDatEmp, "N416")
    nValRub417 := fObtValRub(aAuxDatEmp, "N417")
    nValRub418 := fObtValRub(aAuxDatEmp, "N418")

    //Total de Remuneraciones No Gravadas
    nTotRemNGr := nValRub403 + nValRub404 + nValRub405 + nValRub406 + nValRub407 + nValRub408 + nValRub409 + nValRub410
    nTotRemNGr += nValRub411 + nValRub412 + nValRub413 + nValRub414 + nValRub415 + nValRub416 + nValRub417 + nValRub418
    
    //Total de Remuneraciones
    nTotRemune := nTotRemGra + nTotRemNGr

    //Arreglo con Rubros de la sección REMUNERACIONES EXENTAS o NO ALCANZADAS (Abonadas por el agente de Retención)
    aAuxInfImp := {}
    aAdd(aAuxInfImp, {STR0037, nValRub403}) //'Asignaciones Familiares'
    aAdd(aAuxInfImp, {STR0038, nValRub404}) //'Intereses por préstamos al empleador'
    aAdd(aAuxInfImp, {STR0039, nValRub405}) //'Indemnizaciones establecidas en los inc. c), d) y e) del Apartado "A" - Anexo II de la RG 4003/2017'
    aAdd(aAuxInfImp, {STR0040, nValRub406})//'Remuneraciones bajo el Art. 1° de la Ley N° 19.640 "Territorio Nacional de la Tierra del Fuedo A.I.A.S."'
    aAdd(aAuxInfImp, {STR0041, nValRub407}) //'Remuneraciones bajo el CCT 396/2204 "Petroleros -> Personal de Pozo" - Art. 1° Ley N° 26.176'
    aAdd(aAuxInfImp, {STR0042, nValRub408}) //'Cursos y Seminarios establecidos en el inc. o) del Apartado "A" - Anexo II de la RG 4003/2017'
    aAdd(aAuxInfImp, {STR0043, nValRub409}) //'Indumentaria y equipamiento provistos por el empleador'
    aAdd(aAuxInfImp, {STR0044, nValRub410}) //'Ajustes de Períodos Anteriores sobre Remuneraciones Exentas no Alcanzadas'

    //Impresión de Rubros
    fImpRubros(@nPosVerti, @nPosBoxRod, @oPrinter, aAuxInfImp, oFontPar, nPorVerTxt, nAncho)

    //Impresión del box de Otros Empleos
    fImpBoxTxt(@nPosVerti, @nPosBoxRod, @oPrinter, STR0030, oFontTit, nAncho, nPorVerTxt) //"Otros Empleos"

    //Arreglo con Rubros para REMUNERACIONES EXENTAS o NO ALCANZADAS (Otros Empleados)
    aAuxInfImp := {}
    aAdd(aAuxInfImp, {STR0045, nValRub411}) //'Otros Empleos -> Asignaciones Familiares'
    aAdd(aAuxInfImp, {STR0046, nValRub412}) //'Otros Empleos -> Intereses por préstamos al empleador'
    aAdd(aAuxInfImp, {STR0047, nValRub413}) //'Otros Empleos -> Indemnizaciones establecidas en los inc. c), d) y e) del Apartado "A" - Anexo II de la RG 4003/2017'
    aAdd(aAuxInfImp, {STR0048, nValRub414}) //'Otros Empleos -> Remuneraciones bajo el Art. 1° de la Ley N° 19.640 "Territorio Nacional de la Tierra del Fuedo A.I.A.S."'
    aAdd(aAuxInfImp, {STR0049, nValRub415}) //'Otros Empleos -> Remuneraciones bajo el CCT 396/2204 "Petroleros -> Personal de Pozo" - Art. 1° Ley N° 26.176'
    aAdd(aAuxInfImp, {STR0050, nValRub416}) //'Otros Empleos -> Cursos y Seminarios establecidos en el inc. o) del Apartado "A" - Anexo II de la RG 4003/2017'
    aAdd(aAuxInfImp, {STR0051, nValRub417}) //'Otros Empleos -> Indumentaria y equipamiento provistos por el empleador'
    aAdd(aAuxInfImp, {STR0052, nValRub418}) //'Otros Empleos -> Ajustes de Períodos Anteriores sobre Remuneraciones Exentas no Alcanzadas'
    aAdd(aAuxInfImp, {STR0053, nTotRemNGr}) //'TOTAL REMUNERACIÓN NO GRAVADA / NO ALCANZADA / EXENTA'
    aAdd(aAuxInfImp, {STR0054, nTotRemune}) //'TOTAL REMUNERACIONES'

    //Impresión de Rubros
    fImpRubros(@nPosVerti, @nPosBoxRod, @oPrinter, aAuxInfImp, oFontPar, nPorVerTxt, nAncho)

    //Impresión del box DEDUCCIONES GENERALES 1/2
    fImpBoxTxt(@nPosVerti, @nPosBoxRod, @oPrinter, STR0055, oFontTit, nAncho, nPorVerTxt) //"DEDUCCIONES GENERALES 1/2"

    //Arreglo auxiliar que contiene el detalle de Deducciones Generales
    aAuxDatEmp := aDataEmp[4]

    //Posiciones de Rubros para Abonadas por el agente de retención
    nValRub503 := fObtValRub(aAuxDatEmp, "N503")
    nValRub504 := fObtValRub(aAuxDatEmp, "N504")
    nValRub505 := fObtValRub(aAuxDatEmp, "N505")
    nValRub506 := fObtValRub(aAuxDatEmp, "N506")
    nValRub507 := fObtValRub(aAuxDatEmp, "N507")
    nValRub508 := fObtValRub(aAuxDatEmp, "N508")
    nValRub509 := fObtValRub(aAuxDatEmp, "N509")
    nValRub510 := fObtValRub(aAuxDatEmp, "N510")
    nValRub511 := fObtValRub(aAuxDatEmp, "N511")
    nValRub512 := fObtValRub(aAuxDatEmp, "N512")
    nValRub513 := fObtValRub(aAuxDatEmp, "N513")
    nValRub514 := fObtValRub(aAuxDatEmp, "N514")
    nValRub515 := fObtValRub(aAuxDatEmp, "N515")
    nValRub516 := fObtValRub(aAuxDatEmp, "N516")
    nValRub517 := fObtValRub(aAuxDatEmp, "N517")
    nValRub518 := fObtValRub(aAuxDatEmp, "N518")
    nValRub519 := fObtValRub(aAuxDatEmp, "N519")
    nValRub520 := fObtValRub(aAuxDatEmp, "N520")
    nValRub521 := fObtValRub(aAuxDatEmp, "N521")
    nValRub522 := fObtValRub(aAuxDatEmp, "N522")
    nValRub523 := fObtValRub(aAuxDatEmp, "N523")
    nValRub524 := fObtValRub(aAuxDatEmp, "N524")
    nValRub525 := fObtValRub(aAuxDatEmp, "N525")
    nValRub526 := fObtValRub(aAuxDatEmp, "N526")
    nValRub527 := fObtValRub(aAuxDatEmp, "N527")
    nValRub528 := fObtValRub(aAuxDatEmp, "N528")
    nValRub529 := fObtValRub(aAuxDatEmp, "N529")
    nValRub530 := fObtValRub(aAuxDatEmp, "N530")
    nValRub531 := fObtValRub(aAuxDatEmp, "N531")
    nValRub532 := fObtValRub(aAuxDatEmp, "N532")

    //Total de Deducciones Generales
    nTotDedGen := nValRub503 + nValRub504 + nValRub505 + nValRub506 + nValRub507 + nValRub508 + nValRub509
    nTotDedGen += nValRub510 + nValRub511 + nValRub512 + nValRub513 + nValRub514 + nValRub515 + nValRub516
    nTotDedGen += nValRub517 + nValRub518 + nValRub519 + nValRub520 + nValRub521 + nValRub522 + nValRub523
    nTotDedGen += nValRub524 + nValRub525 + nValRub526 + nValRub527 + nValRub528 + nValRub529 + nValRub530
    nTotDedGen += nValRub531 + nValRub532

    //Arreglo de Rubros para Deducciones Generales    
    aAuxInfImp := {}
    aAdd(aAuxInfImp, {STR0056, nValRub503}) //'Aportes para fondos de Jubilaciones, retiros, pensiones o subsidios - ANSES'
    aAdd(aAuxInfImp, {STR0057, nValRub504}) //'Otros Empleos - Aportes para fondos de Jubilaciones, retiros, pensiones o subsidios - ANSES'
    aAdd(aAuxInfImp, {STR0058, nValRub505}) //'Aportes para fondos de Jubilaciones, retiros, pensiones o subsidios - Cajas Previsionales Provinciales, Municipales o para Prof.'
    aAdd(aAuxInfImp, {STR0059, nValRub506}) //'Otros Empleos - Aportes para fondos de Jubilaciones, retiros, pensiones o subsidios - Cajas Prev. Prov., Mpales. o para Prof.'
    aAdd(aAuxInfImp, {STR0060, nValRub507}) //'Aportes a Obras Sociales'
    aAdd(aAuxInfImp, {STR0061, nValRub508}) //'Otros Empleos - Aportes a Obras Sociales'
    aAdd(aAuxInfImp, {STR0062, nValRub509}) //'Cuotas Sindicales'
    aAdd(aAuxInfImp, {STR0063, nValRub510}) //'Otros Empleos - Cuotas Sindicales'
    aAdd(aAuxInfImp, {STR0064, nValRub511}) //'Cuotas Médico Asistenciales'
    aAdd(aAuxInfImp, {STR0065, nValRub512}) //'Primas de Seguro para el caso de Muerte'
    aAdd(aAuxInfImp, {STR0066, nValRub513}) //'Seguro de Muerte/Mixtos Sujetos al control de la SSN'
    aAdd(aAuxInfImp, {STR0067, nValRub514}) //'Adquisición de Cuotapartes de FCI con fines de Retiro'
    aAdd(aAuxInfImp, {STR0068, nValRub515}) //'Gastos de Sepelio'
    aAdd(aAuxInfImp, {STR0069, nValRub516}) //'Amortización Impositiva e Intereses por adquisición de Rodados para Corredores y Viajantes de Comercio'
    aAdd(aAuxInfImp, {STR0070, nValRub517}) //'Donaciones a Fiscos Nac./Prov./Mun./Inst. Art. 26 Inc e) y f) LIG'
    
    //Impresión de Rubros
    fImpRubros(@nPosVerti, @nPosBoxRod, @oPrinter, aAuxInfImp, oFontPar, nPorVerTxt, nAncho)

    //Se realiza saldo de página
    oPrinter:EndPage()
	oPrinter:StartPage()
    
    nPosVerti := 80
    nPosBoxRod := nPosVerti - 15

    //Impresión del box DEDUCCIONES GENERALES 2/2
    fImpBoxTxt(@nPosVerti, @nPosBoxRod, @oPrinter, STR0071, oFontTit, nAncho, nPorVerTxt) //"DEDUCCIONES GENERALES 2/2"

    //Arreglo de Rubros para Deducciones Generales en la siguiente página
    aAuxInfImp := {}
    aAdd(aAuxInfImp, {STR0072, nValRub518}) //'Alquileres de Inmuebles destinados a Casa-Habitación para Inquilinos No Propietarios - Art. 85 inc. h) - 40%'
    aAdd(aAuxInfImp, {STR0073, nValRub519}) //'Descuentos Obligatorios por Ley Nacional, Provincial o Municipal'
    aAdd(aAuxInfImp, {STR0074, nValRub520}) //'Honorarios por Servicios de Asistencia Sanitaria, Médica y Paramédica'
    aAdd(aAuxInfImp, {STR0075, nValRub521}) //'Intereses Créditos Hipotecarios'
    aAdd(aAuxInfImp, {STR0076, nValRub522}) //'Aportes al Cap.Soc./Fondo Riesgo de Socios Protectores de SGR'
    aAdd(aAuxInfImp, {STR0077, nValRub523}) //'Empleados del Servicio Doméstico'
    aAdd(aAuxInfImp, {STR0078, nValRub524}) //'Cajas Complementarias de Previsión'
    aAdd(aAuxInfImp, {STR0079, nValRub525}) //'Fondos Compensadores de Previsión'
    aAdd(aAuxInfImp, {STR0080, nValRub526}) //'Otros Aportes para fondos de Jubilaciones, retiros, pensiones o subsidios - incluido ANSES Autónomos'
    aAdd(aAuxInfImp, {STR0081, nValRub527}) //'Seguros de Retiro Privados -Sujetos al Control de la SSN'
    aAdd(aAuxInfImp, {STR0082, nValRub528}) //'Indumentaria/ y Equipamiento -Uso exclusivo y carácter obligatorio - Adquiridos por empleado'
    aAdd(aAuxInfImp, {STR0083, nValRub529}) //'Servicios y Herramientas con Fines Educativos para Cargas de Familia'
    aAdd(aAuxInfImp, {STR0084, nValRub530}) //'Alquileres de Inmuebles destinados a Casa-Habitación para Inquilinos y Propietarios - Art. 85 inc. k) - 10%'
    aAdd(aAuxInfImp, {STR0085, nValRub531}) //'Antártida Argentina - Adicional remunerativo para personal civil y militar'
    aAdd(aAuxInfImp, {STR0086, nValRub532}) //'Actores - Retribución pagada a los representantes - RG 2442/08'
    aAdd(aAuxInfImp, {STR0087, nTotDedGen}) //'TOTAL DEDUCCIONES GENERALES'

    //Impresión de Rubros
    fImpRubros(@nPosVerti, @nPosBoxRod, @oPrinter, aAuxInfImp, oFontPar, nPorVerTxt, nAncho)

    //Impresión del box de Deducciones Personales
    fImpBoxTxt(@nPosVerti, @nPosBoxRod, @oPrinter, STR0088, oFontTit, nAncho, nPorVerTxt) //"DEDUCCIONES PERSONALES"

    //Arreglo auxiliar que contiene el detalle de Deducciones Art. 30
    aAuxDatEmp := aDataEmp[5]

    //Posiciones de Rubros para Deducciones Personales
    nValRub603 := fObtValRub(aAuxDatEmp, "N603")
    nValRub604 := fObtValRub(aAuxDatEmp, "N604")
    nValRub605 := fObtValRub(aAuxDatEmp, "N605")
    nValRub606 := fObtValRub(aAuxDatEmp, "N606")
    nValRub607 := fObtValRub(aAuxDatEmp, "N607")
    nValRub608 := fObtValRub(aAuxDatEmp, "N608")
    nValRub609 := fObtValRub(aAuxDatEmp, "N609")
    nValRub610 := fObtValRub(aAuxDatEmp, "N610")
    nValRub611 := fObtValRub(aAuxDatEmp, "N611")
    nValRub612 := fObtValRub(aAuxDatEmp, "N612")
    nValRub613 := fObtValRub(aAuxDatEmp, "N613")
    nValRub614 := fObtValRub(aAuxDatEmp, "N614")
    nValRub615 := fObtValRub(aAuxDatEmp, "N615")
    nValRub616 := fObtValRub(aAuxDatEmp, "N616")
    nValRub617 := fObtValRub(aAuxDatEmp, "N617")

    nTotCarFam := nValRub604 + nValRub607 + nValRub610
    nTotDedPer := nValRub603 + nValRub612 + nValRub613 + nValRub614

    //Arreglo de Rubros para Deducciones Personales
    aAuxInfImp := {}
    aAdd(aAuxInfImp, {STR0089, nValRub603}) //'Ganancia No Imponible'
    aAdd(aAuxInfImp, {STR0090, nTotCarFam}) //'Cargas de familia'
    aAdd(aAuxInfImp, {STR0091, nValRub612}) //'Deducción Especial'
    aAdd(aAuxInfImp, {STR0092, nValRub613}) //'Deducción especial 2do párrafo artículo 30 de la ley del gravamen (12° parte)'
    aAdd(aAuxInfImp, {STR0093, nValRub614}) //'Deducción Específica'
    aAdd(aAuxInfImp, {STR0094, nTotDedPer}) //'TOTAL DEDUCCIONES PERSONALES'

    //Impresión de Rubros
    fImpRubros(@nPosVerti, @nPosBoxRod, @oPrinter, aAuxInfImp, oFontPar, nPorVerTxt, nAncho)

    //Impresión del box de Determinación del Impuesto
    fImpBoxTxt(@nPosVerti, @nPosBoxRod, @oPrinter, STR0095, oFontTit, nAncho, nPorVerTxt) //"DETERMINACIÓN DEL IMPUESTO"

    //Arreglo auxiliar que contiene el detalle de Pagos a Cuenta
    aAuxDatEmp := aDataEmp[6]

    //Posiciones de Rubros para Pagos a Cuenta
    nValRub703 := fObtValRub(aAuxDatEmp, "N703")
    nValRub704 := fObtValRub(aAuxDatEmp, "N704")
    nValRub705 := fObtValRub(aAuxDatEmp, "N705")
    nValRub706 := fObtValRub(aAuxDatEmp, "N706")
    nValRub707 := fObtValRub(aAuxDatEmp, "N707")
    nValRub708 := fObtValRub(aAuxDatEmp, "N708")
    nValRub709 := fObtValRub(aAuxDatEmp, "N709")
    nValRub710 := fObtValRub(aAuxDatEmp, "N710")
    nValRub711 := fObtValRub(aAuxDatEmp, "N711")
    nValRub712 := fObtValRub(aAuxDatEmp, "N712")

    //Total de Pagos a Cuenta
    nTotPagACt := nValRub703 + nValRub704 + nValRub705 + nValRub706 + nValRub707 + nValRub708 + nValRub709
    nTotPagACt += nValRub710 + nValRub711 + nValRub712

    //Arreglo auxiliar que contiene el detalle de Cálculo del Impuesto
    aAuxDatEmp := aDataEmp[7]

    //Posiciones de Rubros para Determinación del Impuesto
    nValRub803 := fObtValRub(aAuxDatEmp, "N803")
    nValRub804 := fObtValRub(aAuxDatEmp, "N804")
    nValRub805 := fObtValRub(aAuxDatEmp, "N805")
    nValRub806 := fObtValRub(aAuxDatEmp, "N806")
    nValRub808 := fObtValRub(aAuxDatEmp, "N808")

    //Total de Remuneración Sujeta a Impuesto
    nValRemSAI := nTotRemGra - nTotDedGen - nTotDedPer - nTotCarFam

    //Subtotal de Salto Determinado antes de Pagos a Cuenta
    nSubTotPAC := nValRub805 - nValRub806

    //Saldo a Pagar
    nSalAPagar := nSubTotPAC - nValRub808 - nTotPagACt

    //Arreglo de Rubros para Determinación del Impuesto
    aAuxInfImp := {}
    aAdd(aAuxInfImp, {STR0096, nValRemSAI}) //REMUNERACIÓN SUJETA A IMPUESTO'
    aAdd(aAuxInfImp, {STR0097, nValRub804, "%", .F.}) //'Alícuota aplicable artículo 94 de la Ley de Impuesto a las Ganancias'
    aAdd(aAuxInfImp, {STR0098, nValRub805}) //'IMPUESTO DETERMINADO'
    aAdd(aAuxInfImp, {STR0099, nValRub806}) //'Impuesto retenido'
    aAdd(aAuxInfImp, {STR0102, nTotPagACt}) //'Pagos a cuenta'
    aAdd(aAuxInfImp, {STR0222, nSubTotPAC}) //"Subtotal saldo determinado antes de Auto-retención / Pagos a Cuenta"
    aAdd(aAuxInfImp, {STR0223, nValRub808}) //"Impuesto Auto-retenido RG 5683"
    aAdd(aAuxInfImp, {STR0103, nSalAPagar, "$", .T.}) //'SALDO A PAGAR'

    //Impresión de Rubros
    fImpRubros(@nPosVerti, @nPosBoxRod, @oPrinter, aAuxInfImp, oFontPar, nPorVerTxt, nAncho)

    //Impresión de Rodapié
    nPosVerti += 5
    oPrinter:Say(nPosVerti, 10, STR0104, oFontPar) //"Se extiende el presente documento para constancia del interesado."
    nPosVerti += 40

    oPrinter:Say(nPosVerti, 10, STR0105 + AllTrim(MV_PAR11) + ", " + AllTrim(DToC(MV_PAR12)), oFontPar) //"Lugar y Fecha: "
    nPosVerti += 15
    oPrinter:Say(nPosVerti, 10, STR0106 + AllTrim(MV_PAR13), oFontPar) //"Identificación del Responsable: "
    nPosVerti += 15
    oPrinter:Say(nPosVerti, 10, STR0107, oFontPar) //"Firma del Responsable: "
    nPosVerti += 15

    //Limpia de objetos utilizados
    FreeObj(oFontPar)
    oFontPar := Nil

    FreeObj(oFontTit)
    oFontTit := Nil
    
Return lRet

/*/{Protheus.doc} fImpBoxTxt
    Función utilizada para imprimir box y texto para cada sección principal y subsección
    en el Archivo PDF.
    
    @type  Static Function
    @author marco.rivera
    @since 31/01/2025
    @version 1.0
    @param nPosVerti, Numeric, Coordenada vertical en pixeles del texto
    @param nPosBoxRod, Numeric, Indica la posición del objeto en relacion al rodapié
    @param oPrinter, Object, Objeto de impresión
    @param cTexto, Character, Texto a imprimir
    @param oFontTit, Object, Fuente a aplicar en la impresión del texto
    @param nAncho, Numeric, Valor fijo para setear los saltos de impresión
    @param nPorVerTxt, Numeric, Valor fijo para impresión de texto respecto al box
    @example
    fImpBoxTxt(nPosVerti, nPosBoxRod, oPrinter, cTexto, oFontTit, nAncho, nPorVerTxt)
/*/
Static Function fImpBoxTxt(nPosVerti, nPosBoxRod, oPrinter, cTexto, oFontTit, nAncho, nPorVerTxt)

    Default nPosVerti   := 0
    Default nPosBoxRod  := 0
    Default oPrinter    := Nil
    Default cTexto      := ""
    Default oFontTit    := Nil
    Default nAncho      := 0
    Default nPorVerTxt  := 0

	oPrinter:Box(nPosVerti, 10, nPosBoxRod, 565)
	oPrinter:Say((nPosVerti - nPorVerTxt), 12, cTexto, oFontTit)
	
	nPosVerti += nAncho
	nPosBoxRod += nAncho
    
Return

/*/{Protheus.doc} fImpRubros
    Función utilizada para realizar la impresión de cada uno de los rubros
    en el Archivo PDF.

    @type  Static Function
    @author marco.rivera
    @since 31/01/2025
    @version 1.0
    @param nPosVerti, Numeric, Coordenada vertical en pixeles del texto
    @param nPosBoxRod, Numeric, Indica la posición del objeto en relacion al rodapié
    @param oPrinter, Object, Objeto de impresión
    @param aAuxInfImp, Array, Arreglo con datos de los rubros a imprimir
    @param oFont, Object, Fuente a aplicar en la impresión del texto
    @param nPorVerTxt, Numeric, Valor fijo para impresión de texto respecto al box
    @param nAncho, Numeric, Valor fijo para setear los saltos de impresión
    @example
    fImpRubros(nPosVerti, nPosBoxRod, oPrinter, aAuxInfImp, oFont, nPorVerTxt, nAncho)
/*/
Static Function fImpRubros(nPosVerti, nPosBoxRod, oPrinter, aAuxInfImp, oFont, nPorVerTxt, nAncho)

    Local nIteracion    := 0
    Local cVlrImp       := ""
    Local cPictSRD      := PesqPict("SRD", "RD_VALOR")
    Local nValRubro     := 0
    Local cSimbolo      := ""
    Local lImpValNeg    := .F.

    Default nPosVerti   := 0
    Default nPosBoxRod  := 0
    Default oPrinter    := Nil
    Default aAuxInfImp  := {}
    Default oFont       := Nil
    Default nPorVerTxt  := 0
    Default nAncho      := 0

 	For nIteracion := 1 To Len(aAuxInfImp)

        cSimbolo := "$"
        lImpValNeg := .F.
 		
        //Impresión de la descripción del rubro
        oPrinter:Box(nPosVerti, 10, nPosBoxRod, 565)
        oPrinter:Say(nPosVerti - nPorVerTxt, 012, aAuxInfImp[nIteracion][1], oFont)

        nValRubro := aAuxInfImp[nIteracion][2]

        If Len(aAuxInfImp[nIteracion]) > 2
            cSimbolo := aAuxInfImp[nIteracion][3]
            lImpValNeg := aAuxInfImp[nIteracion][4]
        EndIf

        If nValRubro < 0 .And. !lImpValNeg
            nValRubro := 0.00
        EndIf

        //Se formatea el valor a imprimir
		cVlrImp := PadL(AllTrim(Transform(nValRubro, cPictSRD)), 14, " ")
		
        //Impresión del valor del rubro
        oPrinter:Box(nPosVerti, 480, nPosBoxRod, 565)
        oPrinter:Say(nPosVerti - nPorVerTxt, 500, cVlrImp, oFont)
        
        //Impresión del símbolo del rubro
        oPrinter:Say(nPosVerti - nPorVerTxt, 483, cSimbolo, oFont)

		nPosVerti += nAncho
		nPosBoxRod += nAncho

	Next nIteracion
    
Return

/*/{Protheus.doc} fObtValRub
    Función utilizada para obtener el valor de los rubros a partir del arreglo.

    @type  Static Function
    @author marco.rivera
    @since 06/02/2025
    @version 1.0
    @param aAuxDatEmp, Array, Arreglo con información de rubros.
    @param cCodRubro, Character, Código del rubro.
    @return nValRetRub, Numeric, Valor del Rubro.
    @example
    fObtValRub(aAuxDatEmp, cCodRubro)
/*/
Static Function fObtValRub(aAuxDatEmp, cCodRubro)

    Local nValRetRub    := 0
    Local nPosicion     := 0

    Default aAuxDatEmp	:= {}
	Default cCodRubro   := ""

	nPosicion := aScan(aAuxDatEmp, {|x| x[2] == cCodRubro})
	If nPosicion > 0
		nValRetRub := aAuxDatEmp[nPosicion, 1]
	EndIf
    
Return nValRetRub

/*/{Protheus.doc} fConCod13
	Valida que existan conceptos configurados con el campo RV_COD13.
	@type  Static Function
	@author oscar.lopez
	@since 26/03/2025
	@version 1.0
	@return lRet, logico, .T. si no existen conceptos con RV_COD13 configurado, de lo contrario .F.
	@example
	lRet := fConCod13()
/*/
Static Function fConCod13()
 
	Local aArea			:= GetArea()
	Local cQuery        := ""
	Local cTabTmpSRV    := ""
	Local cFilialSRV    := xFilial("SRV")
	Local oObjTmpQry	:= Nil
	Local nNumParQry    := 1
	Local nTotReg		:= 0
	Local lRet			:= .F.

	cQuery := " SELECT RV_COD13 "
	cQuery += " FROM ? SRV "
	cQuery += " WHERE "
	cQuery += " RV_FILIAL = ? "
	cQuery += " AND RV_COD13 <> ? "
	cQuery += " AND D_E_L_E_T_= ? "

	oObjTmpQry := FwExecStatement():New(cQuery)

	oObjTmpQry:SetUnsafe(nNumParQry++, RetSqlName("SRV"))
	oObjTmpQry:SetString(nNumParQry++, cFilialSRV)
	oObjTmpQry:SetString(nNumParQry++, " ")
	oObjTmpQry:SetString(nNumParQry++, " ")

	cTabTmpSRV := oObjTmpQry:OpenAlias()
	DbSelectArea(cTabTmpSRV)
	(cTabTmpSRV)->(DbGoTop())

	Count To nTotReg

	lRet := (nTotReg == 0)

	(cTabTmpSRV)->(DBCloseArea())

	If oObjTmpQry <> Nil
		Freeobj(oObjTmpQry)
	EndIf
	FWRestArea(aArea)
Return lRet

/*/{Protheus.doc} fDefImpExc
	Función para definir la impresión del Encabezado y Detalle de los
	Registros.

	@type  Static Function
	@author oscar.lopez
	@since 24/03/2025
	@version 1.0
	@param oObjExcel, Object, Objeto de la clase FWMsExcelEx.
	@param aDataExcel, Array, Arreglo que contiene datos del Registro.
	@param cIdentReg, Character, Identificador de Registro a procesar.
	@param nRegistros, Numeric, Número de registro que se está procesando.
	@return oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@example
	fDefImpExc(oObjExcel, aDataExcel, cIdentReg, nRegistros)
/*/
Static Function fDefImpExc(oObjExcel, aDataExcel, cIdentReg, nRegistros)

	Local cNameWorkS	:= "Reg_"
	Local cNameTable	:= "Table_"

	Default oObjExcel	:= Nil
	Default aDataExcel	:= {}
	Default cIdentReg	:= ""
	Default nRegistros	:= 0

	cNameWorkS	+= cIdentReg
	cNameTable	+= cIdentReg

	/*
	* --------------------------------------------------------------------
	* Definición de Hoja y Tabla para imprimir información de Registro 01
	* -------------------------------------------------------------------- 
	*/
	If cIdentReg == '01' .And. nRegistros == 1

		//Definición de Hoja de Trabajo (Worksheet) y Tabla
		oObjExcel := fDefWSTab(oObjExcel, cIdentReg, cNameWorkS, cNameTable)

		//Definición de encabezado de Registro 01 - Datos del Empleador (9 campos)
		oObjExcel := fDefEncReg(oObjExcel, cIdentReg, cNameWorkS, cNameTable)
	EndIf

	/*
	* --------------------------------------------------------------------
	* Definición de Hoja y Tabla para imprimir información de Registro 02 en adelante
	* --------------------------------------------------------------------
	*/
	If cIdentReg == "XX" .And. nRegistros == 1

		//Definición de Hoja de Trabajo (Worksheet) y Tabla
		oObjExcel := fDefWSTab(oObjExcel, cIdentReg, cNameWorkS, cNameTable)

		//Definición de encabezado de Registro 01 - Datos del Empleador (9 campos)
		oObjExcel := fDefEncReg(oObjExcel, cIdentReg, cNameWorkS, cNameTable)
	EndIf

	//Impresión del detalle de los Registros
	oObjExcel := fDefImpReg(oObjExcel, cIdentReg, aDataExcel, cNameWorkS, cNameTable)

Return oObjExcel

/*/{Protheus.doc} fDefWSTab
	Función utilizada para definir el nombre de la Hoja de Trabajo y Tabla.

	@type  Static Function
	@author oscar.lopez
	@since 24/03/2025
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@param cIdentReg, Character, Identificador de Registro a procesar.
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, Número de la Tabla.
	@return oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@example
	fDefWSTab(oObjExcel, cIdentReg, cNameWorkS, cNameTable)
/*/
Static Function fDefWSTab(oObjExcel, cIdentReg, cNameWorkS, cNameTable)

	Default oObjExcel	:= Nil
	Default cIdentReg	:= ""
	Default cNameWorkS	:= ""
	Default cNameTable	:= ""

	oObjExcel:AddworkSheet(cNameWorkS)
	oObjExcel:AddTable(cNameWorkS, cNameTable, .F.)

Return oObjExcel

/*/{Protheus.doc} fDefEncReg
	Función utilizada para definir el encabezado de los registros.

	@type  Static Function
	@author oscar.lopez
	@since 24/03/2025
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@param cIdentReg, Character, Identificador de Registro a procesar.
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, Número de la Tabla.
	@return oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@example
	fDefEncReg(oObjExcel, cIdentReg, cNameWorkS, cNameTable)
/*/
Static Function fDefEncReg(oObjExcel, cIdentReg, cNameWorkS, cNameTable)

	Local aTitulos		:= {}

	Default oObjExcel	:= Nil
	Default cIdentReg	:= ""
	Default cNameWorkS	:= ""
	Default cNameTable	:= ""

	If cIdentReg == "01" //Definición de Encabezados para el Registro 01

		//Campos pertenecientes al Registro 01 - Cabecera (9 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0108,;	//Campo 1 = "Registro"
						STR0109,;	//Campo 2 = "CUIT Ag. Ret."
						STR0110,;	//Campo 3 = "Periodo"
						STR0111,;	//Campo 4 = "Secuencia"
						STR0112,;	//Campo 5 = "Cód. Impuesto"
						STR0113,;	//Campo 6 = "Cód. Concepto"
						STR0114,;	//Campo 7 = "Núm. Formulario"
						STR0115,;	//Campo 8 = "Tipo Present."
						STR0116;	//Campo 9 = "Versión"
						})

		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

	Else //Definición de encabezado de Registro 02 al 08

		oObjExcel:AddColumn(cNameWorkS, cNameTable, STR0117, 1, 1, .F.) //"Matrícula" (Este campo es informativo)
		oObjExcel:AddColumn(cNameWorkS, cNameTable, STR0118, 1, 1, .F.) //"Nombre" (Este campo es informativo)

		//Campos pertenecientes al Registro 02 - Datos del Trabajador (8 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0108,;	//Campo 1 = "Registro"
						STR0119,;	//Campo 2 = "CUIL"
						STR0120,;	//Campo 3 = "Per. Desde"
						STR0121,;	//Campo 4 = "Per. Hasta"
						STR0122,;	//Campo 5 = "Meses"
						STR0123,;	//Campo 6 = "Beneficio"
						STR0124,;	//Campo 7 = "Rem. CCT 396/2004 Ley 26.176-Art. 1°"
						STR0125,;	//Campo 8 = "Retr. RG 2442/08"
                        STR0224,;	//Campo 9 = "¿Alcanzado por medida cautelar?"
                        STR0225;	//Campo 10 = "¿Corresponde al Poder Judicial?"
						})

		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

		//Campos pertenecientes al Registro 03 - Remuneraciones (13 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0108,;	//Campo 1 = "Registro"
						STR0119,;	//Campo 2 = "CUIL"
						STR0126,;	//Campo 3 = "Rem. Bruta"
						STR0127,;	//Campo 4 = "Ret. No Habit."
						STR0128,;	//Campo 5 = "SAC 1ra Cuota"
						STR0129,;	//Campo 6 = "SAC 2da Cuota"
						STR0130,;	//Campo 7 = "Otr. Emp. Rem. Brut."
						STR0131,;	//Campo 8 = "Otr. Emp. Ret. No Hab."
						STR0132,;	//Campo 9 = "Otr. Emp. SAC 1ra Cuota"
						STR0133,;	//Campo 10 = "Otr. Emp. SAC 2da Cuota"
						STR0134,;	//Campo 11 = "Aju. Per. Ant. Rem. Gra."
						STR0135,;	//Campo 12 = "Otr. Emp. Aju. Per. Rem. Gra."
						STR0136;	//Campo 13 = "Tot. Rem. Gra."
						})

		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

		//Campos pertenecientes al Registro 04 - Deducciones (20 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0108,;	//Campo 1 = "Registro"
						STR0119,;	//Campo 2 = "CUIL"
						STR0137,;	//Campo 3 = "Asign. Fam."
						STR0138,;	//Campo 4 = "Int. Por Prest. Emp."
						STR0139,;	//Campo 5 = "Ind. An. II RG 4003/2017"
						STR0140,;	//Campo 6 = "Rem. Art. 1 Ley 19.640"
						STR0141,;	//Campo 7 = "Rem. Art. 1 Ley 26.176"
						STR0142,;	//Campo 8 = "Cur. Sem. An. II RG 4003/2017"
						STR0143,;	//Campo 9 = "Ind. Equ. Prov. Por Empleador"
						STR0144,;	//Campo 10 = "Aju. Per. Ant. - Rem. Exenta / No alcanzada"
						STR0145,;	//Campo 11 = "Asig. Fam.Otr. Emp."
						STR0146,;	//Campo 12 = "Int. Por Prest. Empleador Otr. Emp."
						STR0147,;	//Campo 13 = "Ind. An. II RG 4003/2017 Otr. Emp."
						STR0148,;	//Campo 14 = "Rem. Art. 1 Ley 19.640 Otr. Emp."
						STR0149,;	//Campo 15 = "Rem CCT 396/2204 Art. 1 Ley 26.176 Otr. Emp."
						STR0150,;	//Campo 16 = "Cur. Sem. An. II RG 4003/2017 Otr. Emp."
						STR0151,;	//Campo 17 = "Ind. Equ. Prov. Por Empleador Otr. Emp."
						STR0152,;	//Campo 18 = "Aju. Per. Ant. - Rem. Ex. / No alcanzada Otr. Emp."
						STR0153,;	//Campo 19 = "Tot. Rem. No Gra. / No Alc. / Exe."
						STR0154,;	//Campo 20 = "Tot. Rem."
                        STR0226,;	//Campo 21 = "Rem. Poder Judicial No alcanzadas"
                        STR0227;	//Campo 22 = "Otr. Emp. Rem. Poder Judicial No alcanzadas"
						})

		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

		//Campos pertenecientes al Registro 05 - Deducciones Art. 23 (33 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0108,;	//Campo 1 = "Registro"
						STR0119,;	//Campo 2 = "CUIL"
						STR0155,;	//Campo 3 = "Apo. Fon. Jub."
						STR0156,;	//Campo 4 = "Apo. Fon. Jub.  Otr. Emp."
						STR0157,;	//Campo 5 = "Apo. Caj. Prev.  Mun. Prof."
						STR0158,;	//Campo 6 = "Apo. Caj. Prev.  Mun. Prof. Otr. Emp.
						STR0159,;	//Campo 7 = "Apo. Obr. Soc."
						STR0160,;	//Campo 8 = "Apo. Obr. Soc. Otr. Emp."
						STR0161,;	//Campo 9 = "Cuo. Sind."
						STR0162,;	//Campo 10 = "Cuo. Sind. Otr. Emp."
						STR0163,;	//Campo 11 = "Cuo. Med. Asist."
						STR0164,;	//Campo 12 = "Prim. Seg. Muerte"
						STR0165,;	//Campo 13 = "Seg. Muerte Mixto SSN"
						STR0166,;	//Campo 14 = "Adq. Cuot. FCI Ret."
						STR0167,;	//Campo 15 = "Gas. Sepelio"
						STR0168,;	//Campo 16 = "Amort. Impo. E Int."
						STR0169,;	//Campo 17 = "Don. Fis. Nac. Art. 26"
						STR0170,;	//Campo 18 = "Alq. Inm. Dest. Casa Hab. 40%"
						STR0171,;	//Campo 19 = "Des. Obl. Ley Nac. Prov. O Mun."
						STR0172,;	//Campo 20 = "Hon. Serv. Asi. San."
						STR0173,;	//Campo 21 = "Int. Cré. Hip."
						STR0174,;	//Campo 22 = "Apo. Cap. Soc. Fon. Rie."
						STR0175,;	//Campo 23 = "Emp. Ser. Dom."
						STR0176,;	//Campo 24 = "Caj. Comp. Prev."
						STR0177,;	//Campo 25 = "Fon. Comp. De Prev."
						STR0178,;	//Campo 26 = "Apo. Fon. Jub. Otr. Emp."
						STR0179,;	//Campo 27 = "Seg. De Ret. Priv."
						STR0180,;	//Campo 28 = "Ind. Equ.  Adq. Por Emp."
						STR0181,;	//Campo 29 = "Serv. Her. Fin. Edu."
						STR0182,;	//Campo 30 = "Alq. Inm. Dest. Casa Hab. 10%"
						STR0183,;	//Campo 31 = "Antártica Argentina"
						STR0184,;	//Campo 32 = "Actore RG 2442/08"
						STR0185;	//Campo 33 = "TOTAL DEDUCCIONES GENERALES"
						})
		
		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

		//Campos pertenecientes al Registro 06 - Cálculo del Impuesto (17 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0108,;	//Campo 1 = "Registro"
						STR0119,;	//Campo 2 = "CUIL"
						STR0186,;	//Campo 3 = "Gan. No Imponible"
						STR0187,;	//Campo 4 = "Conyugue / Unión Conv."
						STR0188,;	//Campo 5 = "Cant. H. Al 50%"
						STR0189,;	//Campo 6 = "Cant. H. Al 100%"
						STR0190,;	//Campo 7 = "Hijos / Hijastros"
						STR0191,;	//Campo 8 = "Cant. H. Incap. 50%"
						STR0192,;	//Campo 9 = "Cant. H. Incap. 100%"
						STR0193,;	//Campo 10 = "Hijos / Hijastros Incap."
						STR0194,;	//Campo 11 = "TOTAL DE CARGAS DE FAMILIA"
						STR0195,;	//Campo 12 = "Ded. Esp."
						STR0196,;	//Campo 13 = "Ded. Esp. Adic. 12va Pt."
						STR0197,;	//Campo 14 = "Ded. Específica"
						STR0198,;	//Campo 15 = "TOTAL DEDUCCIONES ART. 30"
						STR0199,;	//Campo 16 = "Cant. H. 18-24 al 50%"
						STR0200;	//Campo 17 = "Cant. H. 18-24 al 100%"
						})

		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

		//Campos pertenecientes al Registro 07 - Pagos a Cuenta (13 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0108,;	//Campo 1 = "Registro"
						STR0119,;	//Campo 2 = "CUIL"
						STR0201,;	//Campo 3 = "RG 2281/2007 Ret. Perc. Adu."
						STR0202,;	//Campo 4 = "RG 2111/2006 Imp. Cred. Deb. Cta. Ban."
						STR0203,;	//Campo 5 = "RG 2111/2006 Imp. Cred. Deb. Mov. Fon."
						STR0204,;	//Campo 6 = "RG 3819/2015 Can. Efec. Serv. Ext."
						STR0205,;	//Campo 7 = "RG 3819/2015 Can. Efec. Serv. Transp."
						STR0206,;	//Campo 8 = "RG 5617/2024 Ley 27.541 Art. 35 Comp. Div."
						STR0207,;	//Campo 9 = "RG 5617/2024 Ley 27.541 Art. 35 Adq. Bien."
						STR0208,;	//Campo 10 = "RG 5617/2024 Ley 27.541 Art. 35 Serv. No Res."
						STR0209,;	//Campo 11 = "RG 5617/2024 Ley 27.541 Art. 35 Serv. Age."
						STR0210,;	//Campo 12 = "RG 5617/2024 Ley 27.541 Art. 35 Serv. Trp."
						STR0211;	//Campo 13 = "TOTAL PAGOS A CUENTA"
						})

		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

		//Campos pertenecientes al Registro 08 - Cálculo del Impuesto (10 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0108,;	//Campo 1 = "Registro"
						STR0119,;	//Campo 2 = "CUIL"
						STR0212,;	//Campo 3 = "REMUNERACION SUJETA A IMPUESTO"
						STR0213,;	//Campo 4 = "Alq. Art. 49 LIG"
						STR0214,;	//Campo 5 = "Imp. Det."
						STR0215,;	//Campo 6 = "Imp. Ret."
						STR0228,;	//Campo 7 = "Sub. Sal. Det. antes de Auto-ret. / Pagos a Cta."
						STR0229,;	//Campo 8 = "Imp. Auto-retenido RG 5683"
						STR0219;	//Campo 9 = "SALDO DETERMINADO"
						})

		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

	EndIf

Return oObjExcel

/*/{Protheus.doc} fDefImpReg
	Función utilizada para definir la impresión del detalle de los
	registros.

	@type  Static Function
	@author oscar.lopez
	@since 24/03/2025
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@param cIdentReg, Character, Identificador de Registro a procesar.
	@param aDataExcel, Array, Arreglo que contiene datos del Registro.
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, Número de la Tabla.
	@return oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@example
	fDefImpReg(oObjExcel, cIdentReg, aDataExcel, cNameWorkS, cNameTable)
/*/
Static Function fDefImpReg(oObjExcel, cIdentReg, aDataExcel, cNameWorkS, cNameTable)

	Local aRowOrange	:= {} //Arreglo con número de columnas a resaltar

	Default oObjExcel	:= Nil
	Default cIdentReg	:= ""
	Default aDataExcel	:= {}
	Default cNameWorkS	:= ""
	Default cNameTable	:= ""

	If cIdentReg == "01"
		aRowOrange	:= {1} //Se agrega el número de columna a resaltar en color naranja para Registro 01
	Else
		aRowOrange	:= {3, 13, 26, 48, 81, 98, 111} //Se agrega el número de columna a resaltar en color naranja para Reg 02 en adelante
	EndIf

	//Se realiza la impresión del renglón
	oObjExcel:AddRow(cNameWorkS, cNameTable, aDataExcel, aRowOrange)

Return oObjExcel

/*/{Protheus.doc} fGenExcel
	Función utilizada para generar el archivo Excel en el directorio
	informado.

	@type  Static Function
	@author oscar.lopez
	@since 24/03/2025
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@param cRutaArc, Character, cRutaGener, Char, Contiene la ruta para la generación del archivo.
	@param cNomArcPla, Character, Nombre de la planilla a generar.
	@param cPerRCH, Character, Periodo procesado.
	@example
	fGenExcel(oObjExcel)
/*/
Static Function fGenExcel(oObjExcel, cRutaArc, cNomArcPla)
	Local lRet := .T.

	Default oObjExcel	:= Nil
	Default cRutaArc	:= ""
	Default cNomArcPla	:= ""

	oObjExcel:Activate()

	oObjExcel:GetXMLFile(cRutaArc + cNomArcPla + ".xml")

	FreeObj(oObjExcel)
	oObjExcel := Nil

Return lRet

/*/{Protheus.doc} fViewExcel
	Función utilizada para generar el archivo Excel en el directorio
	informado.

	@type  Static Function
	@author oscar.lopez
	@since 24/03/2025
	@version 1.0
	@param cRutaArc, Character, cRutaGener, Char, Contiene la ruta para la generación del archivo.
	@param cNomArcPla, Character, Nombre de la planilla a generar.
	@example
	fViewExcel()
/*/
Static Function fViewExcel(cRutaArc, cNomArcPla)

	Local oExcelApp		:= Nil

	Default cRutaArc	:= ""
	Default cNomArcPla	:= ""

	//Se configura visualización de la Planilla tras generación
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cRutaArc + cNomArcPla + ".xml")
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()

	FreeObj(oExcelApp)
	oExcelApp := Nil

Return Nil

/*/{Protheus.doc} fAddTitulo
	Función utilizada para agregar al objeto las columnas al objetivo
	por registro y su respectivo título.

	@type  Static Function
	@author oscar.lopez
	@since 24/03/2025
	@version 1.0
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, Número de la Tabla.
	@param aTitulos, Array, Arreglo con los títulos por registro.
	@return oObjExcel, Object, Objeto que contiene la definición de la planilla.
	@example
	fAddTitulo(cNameWorkS, cNameTable, aTitulos, oObjExcel)
/*/
Static Function fAddTitulo(cNameWorkS, cNameTable, aTitulos, oObjExcel)

	Local nIteracion	:= 0

	Default cNameWorkS	:= ""
	Default cNameTable	:= ""
	Default aTitulos	:= {}
	Default oObjExcel	:= Nil

	For nIteracion := 1 To Len(aTitulos)
		oObjExcel:AddColumn(cNameWorkS, cNameTable, cValToChar(nIteracion) + " - " + aTitulos[nIteracion], 1, 1, .F.)
	Next nIteracion

Return Nil
