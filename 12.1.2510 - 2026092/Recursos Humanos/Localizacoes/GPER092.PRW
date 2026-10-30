#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER092.CH"

/*/{Protheus.doc} GPER092
    
    Función utilizada para la generación del archivo DANE - Encuesta Mensual Comercial,
    en formato Excel.

    @type  Function
    @author marco.rivera
    @since 24/11/2022
    @version 1.0
    @example
    GPER092()
    /*/
Function GPER092()

    Local cGrpPerg  := "GPR092"

    If Pergunte(cGrpPerg, .T.)
        MSAguarde({ || GPR92GenI(cGrpPerg)}, STR0001) //"Imprimiendo informe DANE..."
    EndIf
    
Return Nil

/*/{Protheus.doc} GPR92GenI
    
    Función utilizada para realizar la generación de los informes Sintético y Analítico.
    
    @type  Static Function
    @author marco.rivera
    @since 24/11/2022
    @version 1.0
    @param cGrpPerg, Caracter, Código del grupo de preguntas.
    @return lGenArcOk, Lógico, Retorna .F. si ocurrió un error en la generación del archivo.
    @example
    GPR92GenI(cGrpPerg)
/*/
Static Function GPR92GenI(cGrpPerg)
    
    Local cMatriz   := ""
    Local cSucursal := ""
    Local cPeriodo  := ""
    Local cProceso  := ""
    Local cProcedim := ""
    Local cRutaArch := ""
    Local cNomArch  := ""
    Local nTipoArch := 1
    Local cMsgError := ""
    Local lGenArcOk := .F.

    Default cGrpPerg := "GPR092"

    /* 
    *  ---------------------------------
    *     Grupo de preguntas GPR092
    *  ---------------------------------
    * ¿Matriz sucursal?     -> MV_PAR01
    * ¿Sucursal?            -> MV_PAR02
    * ¿Periodo de Pago?     -> MV_PAR03
    * ¿Proceso?             -> MV_PAR04
    * ¿Procedimiento?       -> MV_PAR05
    * ¿Ruta del Archivo?    -> MV_PAR06
    * ¿Nombre del Archivo?  -> MV_PAR07
    * ¿Tipo de Informe?     -> MV_PAR08
    *  ---------------------------------
    */

    Pergunte(cGrpPerg, .F.)

    cMatriz     := MV_PAR01
    cPeriodo    := MV_PAR03
    cRutaArch   := AllTrim(MV_PAR06)
    cNomArch    := AllTrim(MV_PAR07)
    nTipoArch   := MV_PAR08 // 1 = Sintético y 2 - Analítico

    MakeSqlExpr(cGrpPerg)

    cSucursal   := MV_PAR02
    cProceso    := MV_PAR04
    cProcedim   := MV_PAR05

    If Empty(cMatriz) .Or. Empty(cSucursal) .Or. Empty(cPeriodo) .Or. Empty(cProceso) .Or. Empty(cProcedim) .Or. Empty(cRutaArch) .Or. Empty(cNomArch)
        Help("", 1, "HELP", , STR0002, 1, 0) //"Informe un valor a las preguntas e intente nuevamente."
        Return .F.
    EndIf

    lGenArcOk := GPR92ImprI(cRutaArch, cNomArch, cMatriz, cSucursal, cProceso, cProcedim, cPeriodo, nTipoArch, @cMsgError)

    If !lGenArcOk
        Help("", 1, "ERROR", , STR0003  + CRLF + cMsgError, 1, 0) //"Ocurrió el siguiente error al generar el archivo:"
    Else
        MsgInfo(STR0004) //"El archivo se ha creado exitosamente en el directorio informado."
    EndIf

Return lGenArcOk

/*/{Protheus.doc} GPR92ImpI
    
    Función utilizada para realizar impresión del informe.
    
    @type  Static Function
    @author user
    @since 27/11/2022
    @version version
    @param cRutaArch, Caracter, Ruta del archivo.
    @param cNomArch, Caracter, Nombre del archivo a generar.
    @param cMatriz, Caracter, Código de la sucursal que será la matriz.
    @param cSucursal, Caracter, Códigos de Sucursales a filtrar.
    @param cProceso, Caracter, Códigos de Procesos a filtrar.
    @param cProcedim, Caracter, Códigos de Procedimientos a filtrar.
    @param cPeriodo, Caracter, Código del Periodo a filtrar.
    @param nTipoArch, Numérico, Tipo de generación del informe 1 - Sistético y 2 - Analítico.
    @param cMsgError, Caracter, Mensaje del error al generar el archivo.
    @return lRet, Lógico, Retorna .F. si ocurrió un error en la generación del archivo.
    @example
    GPR92ImprI(cRutaArch, cNomArch, cMatriz, cSucursal, cProceso, cProcedim, cPeriodo, nTipoArch, cMsgError)
/*/
Static Function GPR92ImprI(cRutaArch, cNomArch, cMatriz, cSucursal, cProceso, cProcedim, cPeriodo, nTipoArch, cMsgError)

    Local lRet          := .F.
    Local aFormXML      := {}
    Local aTotales      := {0, 0, 0, 8}

    Default cRutaArch   := ""
    Default cNomArch    := ""
    Default cMatriz     := ""
    Default cSucursal   := ""
    Default cProceso    := ""
    Default cProcedim   := ""
    Default cPeriodo    := ""
    Default nTipoArch   := ""
    Default cMsgError   := ""

    //Función que define el inicio del XML
    GPR92Ini(aFormXML)

    //Función que imprime el encabezado
    GPR92Enc(aFormXML, cMatriz, cPeriodo)
    
    //Función utilizada para imprimir el título de las columnas
    GPR92Cols(aFormXML)

    //Imprime sección de Indefinidos
    GPR92Indef(aFormXML, cSucursal, cProceso, cProcedim, cPeriodo, nTipoArch, aTotales)

    //Imprime sección de Fijos
    GPR92Fijos(aFormXML, cSucursal, cProceso, cProcedim, cPeriodo, nTipoArch, aTotales)

    //Imprime sección Empleado externos
    GPR92Exter(aFormXML)

    //Imprime sección de Aprendices
    GPR92Apren(aFormXML, cSucursal, cProceso, cProcedim, cPeriodo, nTipoArch, aTotales)

    //Imprime sección Totales
    GPR92Total(aFormXML, aTotales)

    //Función que define el final del XML
    GPR92Fin(aFormXML)

    //Función utilizada para la generación del archivo
    lRet := GPR92Build(aFormXML, cRutaArch, cNomArch, @cMsgError, aTotales)
    
Return lRet

/*/{Protheus.doc} GPR92Ini
    
    Función utilizada para la definición inicial del XML.

    @type  Static Function
    @author marco.rivera
    @since 26/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @example
    GPR92Ini(aFormXML)
/*/
Static Function GPR92Ini(aFormXML)

    Default aFormXML    := {}

    aAdd(aFormXML, '<?xml version="1.0"?>')
    aAdd(aFormXML, '<?mso-application progid="Excel.Sheet"?>')
    aAdd(aFormXML, '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"')
    aAdd(aFormXML, ' xmlns:o="urn:schemas-microsoft-com:office:office"')
    aAdd(aFormXML, ' xmlns:x="urn:schemas-microsoft-com:office:excel"')
    aAdd(aFormXML, ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"')
    aAdd(aFormXML, ' xmlns:html="http://www.w3.org/TR/REC-html40">')
    aAdd(aFormXML, ' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">')
    aAdd(aFormXML, '  <Author>TOTVS</Author>')
    aAdd(aFormXML, '  <LastAuthor>TOTVS</LastAuthor>')
    aAdd(aFormXML, '  <Created>2011-11-11T00:00:00Z</Created>')
    aAdd(aFormXML, '  <Version>16.00</Version>')
    aAdd(aFormXML, ' </DocumentProperties>')
    aAdd(aFormXML, ' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">')
    aAdd(aFormXML, '  <AllowPNG/>')
    aAdd(aFormXML, ' </OfficeDocumentSettings>')
    aAdd(aFormXML, ' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">')
    aAdd(aFormXML, '  <WindowHeight>12300</WindowHeight>')
    aAdd(aFormXML, '  <WindowWidth>28800</WindowWidth>')
    aAdd(aFormXML, '  <WindowTopX>0</WindowTopX>')
    aAdd(aFormXML, '  <WindowTopY>0</WindowTopY>')
    aAdd(aFormXML, '  <ProtectStructure>False</ProtectStructure>')
    aAdd(aFormXML, '  <ProtectWindows>False</ProtectWindows>')
    aAdd(aFormXML, ' </ExcelWorkbook>')
    aAdd(aFormXML, ' <Styles>')
    aAdd(aFormXML, '  <Style ss:ID="Default" ss:Name="Normal">')
    aAdd(aFormXML, '   <Alignment ss:Vertical="Bottom"/>')
    aAdd(aFormXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, '  <Style ss:ID="m2444420294784">')
    aAdd(aFormXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>')
    aAdd(aFormXML, '   <Borders>')
    aAdd(aFormXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '   </Borders>')
    aAdd(aFormXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000" ss:Bold="1"/>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, '  <Style ss:ID="m2444420294804">')
    aAdd(aFormXML, '   <Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>')
    aAdd(aFormXML, '   <Borders>')
    aAdd(aFormXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '   </Borders>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, '  <Style ss:ID="s62">')
    aAdd(aFormXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>')
    aAdd(aFormXML, '   <Borders>')
    aAdd(aFormXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '   </Borders>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, '  <Style ss:ID="s79">')
    aAdd(aFormXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>')
    aAdd(aFormXML, '   <Borders>')
    aAdd(aFormXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '   </Borders>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, '  <Style ss:ID="s80">')
    aAdd(aFormXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>')
    aAdd(aFormXML, '   <Borders>')
    aAdd(aFormXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '   </Borders>')
    aAdd(aFormXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, '  <Style ss:ID="s81">')
    aAdd(aFormXML, '   <Borders>')
    aAdd(aFormXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '   </Borders>')
    aAdd(aFormXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, '  <Style ss:ID="s82">')
    aAdd(aFormXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>')
    aAdd(aFormXML, '   <Borders>')
    aAdd(aFormXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '   </Borders>')
    aAdd(aFormXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000" ss:Bold="1"/>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, '  <Style ss:ID="s83">')
    aAdd(aFormXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>')
    aAdd(aFormXML, '   <Borders>')
    aAdd(aFormXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '   </Borders>')
    aAdd(aFormXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000" ss:Bold="1"/>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, '  <Style ss:ID="s84">')
    aAdd(aFormXML, '   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>')
    aAdd(aFormXML, '   <Borders>')
    aAdd(aFormXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '   </Borders>')
    aAdd(aFormXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000" ss:Bold="1"/>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, '  <Style ss:ID="s85">')
    aAdd(aFormXML, '   <Borders>')
    aAdd(aFormXML, '    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>')
    aAdd(aFormXML, '   </Borders>')
    aAdd(aFormXML, '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000" ss:Bold="1"/>')
    aAdd(aFormXML, '  </Style>')
    aAdd(aFormXML, ' </Styles>')
    
    //Define el nombre de la Hoja
    aAdd(aFormXML, ' <Worksheet ss:Name="' + STR0005 + '">') //"DANE"

    //Se agrega identificador para agregar posteriormente el número de filas con texto
    aAdd(aFormXML, 'NumeroFilas')

    aAdd(aFormXML, '   x:FullRows="1" ss:DefaultColumnWidth="60" ss:DefaultRowHeight="15">')
    
Return

/*/{Protheus.doc} GPR92Enc
    
    Función utilizada para imprimir el encabezado del informe.
    
    @type  Static Function
    @author marco.rivera
    @since 24/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @param aFormXML, Arreglo, Código de la sucursal matriz.
    @param cPeriodo, Caracter, Código del Periodo a filtrar.
    @example
    GPR92Enc(aFormXML, cMatriz, cPeriodo)
/*/
Static Function GPR92Enc(aFormXML, cMatriz, cPeriodo)

    //Variables utilizadas para obtener información de SM0
	Local aDatosSM0		:= {} //Utilizada para almacenar información de SM0
	Local aCamposSM0	:= {"M0_NOME", "M0_FILIAL", "M0_CGC"}
	Local cNomEmpr      := "" //Utilizada para almacenar M0_NOME
    Local cSucEmpr      := "" //Utilizada para almacenar M0_FILIAL
    Local cNITEmpr      := "" //Utilizada para almacenar M0_CGC
    Local cSaltoXML     := '&#10;'
    Local cFechaPer     := ""

    Default aFormXML    := {}
    Default cMatriz     := ""
    Default cPeriodo    := ""

    aDatosSM0   := FWSM0Util():GetSM0Data(cEmpAnt, cMatriz, aCamposSM0)

    cNomEmpr    := RTrim(aDatosSM0[1][2]) //Obtiene M0_NOME -> Nombre
    cSucEmpr    := RTrim(aDatosSM0[2][2]) //Obtiene M0_FILIAL -> Sucursal
    cNITEmpr    := RTrim(aDatosSM0[3][2]) //Obtiene M0_CGC -> NIT
    
    cFechaPer  := MesExtenso(SubStr(cPeriodo, 5, 2))  + STR0006 + SubStr(cPeriodo, 1, 4) //" de "

    aAdd(aFormXML, '   <Column ss:Width="18.75"/>')
    aAdd(aFormXML, '   <Column ss:Width="315.75"/>')
    aAdd(aFormXML, '   <Column ss:AutoFitWidth="0" ss:Width="140.25"/>')
    aAdd(aFormXML, '   <Column ss:AutoFitWidth="0" ss:Width="161.25"/>')
    aAdd(aFormXML, '   <Column ss:AutoFitWidth="0" ss:Width="82.5"/>')
    aAdd(aFormXML, '   <Row ss:AutoFitHeight="0">')
    aAdd(aFormXML, '    <Cell ss:MergeAcross="4" ss:StyleID="m2444420294784"><Data ss:Type="String">' + STR0007 + '</Data></Cell>') //"ENCUESTA MENSUAL DE COMERCIO - EMC"
    aAdd(aFormXML, '   </Row>')
    aAdd(aFormXML, '   <Row ss:AutoFitHeight="0" ss:Height="60">')
    aAdd(aFormXML, '    <Cell ss:MergeAcross="4" ss:StyleID="m2444420294804"><Data ss:Type="String">'+ GPR92CarEs(STR0008) + cNomEmpr + cSaltoXML + STR0009 +  cSucEmpr + cSaltoXML + STR0010 + cNITEmpr + cSaltoXML + STR0011 + cFechaPer + '</Data></Cell>') //"Razón Social: " - "Sucursal: " - "NIT: " - "Periodo: "
    aAdd(aFormXML, '   </Row>')
    
Return

/*/{Protheus.doc} GPR92Cols
    
    Función utilizada para la impresión de las columnas del encabezado.

    @type  Static Function
    @author marco.rivera
    @since 26/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @example
    GPR92Cols(aFormXML)
/*/
Static Function GPR92Cols(aFormXML)

    Default aFormXML    := {}
    
    aAdd(aFormXML, '   <Row ss:AutoFitHeight="0" ss:Height="75">')
    aAdd(aFormXML, '    <Cell ss:StyleID="s82"><Data ss:Type="String">' + STR0012 + '</Data></Cell>') //"No."
    aAdd(aFormXML, '    <Cell ss:StyleID="s82"><Data ss:Type="String">' + STR0013 + '</Data></Cell>') //"Concepto"
    aAdd(aFormXML, '    <Cell ss:StyleID="s83"><Data ss:Type="String">' + STR0014 + '</Data></Cell>') //"Promedio personal ocupado durante el mes. Incluye el ocupado en las unidades auxiliares con actividades relacionadas al comercio"
    aAdd(aFormXML, '    <Cell ss:StyleID="s83"><Data ss:Type="String">' + STR0015 + '</Data></Cell>') //"Sueldos y salarios causados en el mes"
    aAdd(aFormXML, '    <Cell ss:StyleID="s82"><Data ss:Type="String">' + STR0016 + '</Data></Cell>') //"Vacaciones"
    aAdd(aFormXML, '   </Row>')

Return

/*/{Protheus.doc} GPR92Indef
    
    Función utilizada para la impresión de la sección de indefinidos.
    
    @type  Static Function
    @author marco.rivera
    @since 25/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @param cSucursal, Caracter, Códigos de Sucursales a filtrar.
    @param cProceso, Caracter, Códigos de Procesos a filtrar.
    @param cProcedim, Caracter, Códigos de Procedimientos a filtrar.
    @param cPeriodo, Caracter, Código del Periodo a filtrar.
    @param nTipoArch, Numérico, Tipo de impresión del informe 1 - Sintético y 2 - Analítico.
    @param aTotales, Arreglo, Arreglo con los totales del informe.
    @example
    GPR92Indef(aFormXML, cSucursal, cProceso, cProcedim, cPeriodo, cCodIndefi)
/*/
Static Function GPR92Indef(aFormXML, cSucursal, cProceso, cProcedim, cPeriodo, nTipoArch, aTotales)

    Local cAliasTmp     := ""

    //Variables de Totales
    Local nValTotPro    := 0
    Local nValTotSld    := 0
    Local nValTotVac    := 0

    //Variables de total por Emppleado
    Local aFilasAdic    := {}

    Default aFormXML    := {}
    Default cSucursal   := ""
    Default cProceso    := ""
    Default cProcedim   := ""
    Default cPeriodo    := ""
    Default nTipoArch   := 1

    /*
    aTotales[1] = Valor total de promedios
    aToteles[2] = Valor total de sueldos
    aTotales[3] = Valor total de vacaciones
    atotales[4] = Valor total de filas adicioneles
    */
    Default aTotales    := {0, 0, 0, 8} //El 8 es el valor inicial de las filas con información

    //Se obtiene tabla temporal para procesar información
    cAliasTmp := GetNextAlias()
    cAliasTmp := GPR92TabT(cAliasTmp, cSucursal, cProceso, cProcedim, cPeriodo, "I")

    //Se obtiene información para le impresión
    GPR92ObtI(cAliasTmp, @nValTotPro, @nValTotSld, @nValTotVac, aTotales, aFilasAdic, nTipoArch)

    //Imprime inicio de la fila
    aAdd(aFormXML, '   <Row ss:AutoFitHeight="0">')

    //Imprime primera celda de fila (No)
    aAdd(aFormXML, '    <Cell ss:StyleID="s84"><Data ss:Type="Number">' + '1' + '</Data></Cell>')

    //Imprime segunda celda de la fila (Descripción)
    aAdd(aFormXML, '    <Cell ss:StyleID="s85"><Data ss:Type="String">' + GPR92CarEs(STR0017) + '</Data></Cell>') //"Personal permanente o de planta contratado a término indefinido"

    //Imprime tercera celda de la fila (Promedio)
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(nValTotPro)) + '</Data></Cell>')

    //Imprime cuarta celda de la fila (Sueldos)
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(nValTotSld)) + '</Data></Cell>')
    
    //Imprime quinta celda de la fila (Vacaciones)
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(nValTotVac)) + '</Data></Cell>')

    //Imprime final de la fila
    aAdd(aFormXML, '   </Row>')

    If nTipoArch == 2
        //Función utilizada para la impresión del detalle en el informe análitico por sección
        GPR92ImpA(aFormXML, aFilasAdic)
    EndIf
    
Return

/*/{Protheus.doc} GPR92Fijos
    
    Función utilizada para la impresión de la sección de fijos.
    
    @type  Static Function
    @author marco.rivera
    @since 25/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @param cSucursal, Caracter, Códigos de Sucursales a filtrar.
    @param cProceso, Caracter, Códigos de Procesos a filtrar.
    @param cProcedim, Caracter, Códigos de Procedimientos a filtrar.
    @param cPeriodo, Caracter, Código del Periodo a filtrar.
    @param nTipoArch, Numérico, Tipo de impresión del informe 1 - Sintético y 2 - Analítico.
    @param aTotales, Arreglo, Arreglo con los totales del informe.
    @example
    GPR92Fijos(aFormXML, cSucursal, cProceso, cProcedim, cPeriodo)
/*/
Static Function GPR92Fijos(aFormXML, cSucursal, cProceso, cProcedim, cPeriodo, nTipoArch, aTotales)
    
    Local cAliasTmp     := ""

    //Variables de Totales
    Local nValTotPro    := 0
    Local nValTotSld    := 0
    Local nValTotVac    := 0

    //Variables de total por Emppleado
    Local aFilasAdic    := {}

    Default aFormXML    := {}
    Default cSucursal   := ""
    Default cProceso    := ""
    Default cProcedim   := ""
    Default cPeriodo    := ""
    Default nTipoArch   := 1

    /*
    aTotales[1] = Valor total de promedios
    aToteles[2] = Valor total de sueldos
    aTotales[3] = Valor total de vacaciones
    atotales[4] = Valor total de filas adicioneles
    */
    Default aTotales    := {0, 0, 0, 8} //El 8 es el valor inicial de las filas con información

    //Se obtiene tabla temporal para procesar información
    cAliasTmp := GetNextAlias()
    cAliasTmp := GPR92TabT(cAliasTmp, cSucursal, cProceso, cProcedim, cPeriodo, "F")

    //Se obtiene información para le impresión
    GPR92ObtI(cAliasTmp, @nValTotPro, @nValTotSld, @nValTotVac, aTotales, aFilasAdic, nTipoArch)

    //Imprime inicio de la fila
    aAdd(aFormXML, '   <Row ss:AutoFitHeight="0">')

    //Imprime primera celda de fila (No)
    aAdd(aFormXML, '    <Cell ss:StyleID="s84"><Data ss:Type="Number">'+ '2' + '</Data></Cell>')

    //Imprime segunda celda de la fila (Descripción)
    aAdd(aFormXML, '    <Cell ss:StyleID="s85"><Data ss:Type="String">'+ GPR92CarEs(STR0018) + '</Data></Cell>') //"Personal temporal contratado directamente por la empresa a término fijo"

    //Imprime tercera celda de la fila (Promedio)
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(nValTotPro)) + '</Data></Cell>')

    //Imprime cuarta celda de la fila (Sueldos)
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(nValTotSld)) + '</Data></Cell>')

    //Imprime quinta celda de la fila (Vacaciones)
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(nValTotVac)) + '</Data></Cell>')

    //Imprime final de la fila
    aAdd(aFormXML, '   </Row>')

    If nTipoArch == 2
        //Función utilizada para la impresión del detalle en el informe análitico por sección
        GPR92ImpA(aFormXML, aFilasAdic)
    EndIf

Return

/*/{Protheus.doc} GPR92Exter
    
    Función utilizada para la impresión de la sección de externos.
    
    @type  Static Function
    @author marco.rivera
    @since 25/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @example
    GPR92Exter(aFormXML)
/*/
Static Function GPR92Exter(aFormXML)

    Default aFormXML    := {}
    
    aAdd(aFormXML, '   <Row ss:AutoFitHeight="0">')
    aAdd(aFormXML, '    <Cell ss:StyleID="s84"><Data ss:Type="Number">'+ '3' + '</Data></Cell>')
    aAdd(aFormXML, '    <Cell ss:StyleID="s85"><Data ss:Type="String">' + GPR92CarEs(STR0019) + '</Data></Cell>') //"Personal temporal contratado a través de empresas"
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + '0' + '</Data></Cell>')
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + '0' + '</Data></Cell>')
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + '0' + '</Data></Cell>')
    aAdd(aFormXML, '   </Row>')

Return

/*/{Protheus.doc} GPR92Apren
    
    Función utilizada para la impresión de la sección de externos.
    
    @type  Static Function
    @author marco.rivera
    @since 25/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @param cSucursal, Caracter, Códigos de Sucursales a filtrar.
    @param cProceso, Caracter, Códigos de Procesos a filtrar.
    @param cProcedim, Caracter, Códigos de Procedimientos a filtrar.
    @param cPeriodo, Caracter, Código del Periodo a filtrar.
    @param nTipoArch, Numérico, Tipo de impresión del informe 1 - Sintético y 2 - Analítico.
    @param aTotales, Arreglo, Arreglo con los totales del informe.
    @example
    GPR92Apren(aFormXML, cSucursal, cProceso, cProcedim, cPeriodo)
/*/
Static Function GPR92Apren(aFormXML, cSucursal, cProceso, cProcedim, cPeriodo, nTipoArch, aTotales)

    Local cAliasTmp     := ""

    //Variables de Totales
    Local nValTotPro    := 0
    Local nValTotSld    := 0
    Local nValTotVac    := 0

    //Variables de total por Emppleado
    Local aFilasAdic    := {}

    Default aFormXML    := {}
    Default cSucursal   := ""
    Default cProceso    := ""
    Default cProcedim   := ""
    Default cPeriodo    := ""
    Default nTipoArch   := 1

    /*
    aTotales[1] = Valor total de promedios
    aToteles[2] = Valor total de sueldos
    aTotales[3] = Valor total de vacaciones
    atotales[4] = Valor total de filas adicioneles
    */
    Default aTotales    := {0, 0, 0, 8} //El 8 es el valor inicial de las filas con información

    //Se obtiene tabla temporal para procesar información
    cAliasTmp := GetNextAlias()
    cAliasTmp := GPR92TabT(cAliasTmp, cSucursal, cProceso, cProcedim, cPeriodo, "A")

    //Se obtiene información para le impresión
    GPR92ObtI(cAliasTmp, @nValTotPro, @nValTotSld, @nValTotVac, aTotales, aFilasAdic, nTipoArch)

    //Imprime inicio de la fila
    aAdd(aFormXML, '   <Row ss:AutoFitHeight="0">')

    //Imprime primera celda de fila (No)
    aAdd(aFormXML, '    <Cell ss:StyleID="s84"><Data ss:Type="Number">' + '4' + '</Data></Cell>')

    //Imprime segunda celda de la fila (Descripción)
    aAdd(aFormXML, '    <Cell ss:StyleID="s85"><Data ss:Type="String">' + GPR92CarEs(STR0020) + '</Data></Cell>') //"Aprendices o pasantes (en etapa práctica)"

    //Imprime tercera celda de la fila (Promedio)
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(nValTotPro)) + '</Data></Cell>')
    
    //Imprime cuarta celda de la fila (Sueldos)
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(nValTotSld)) + '</Data></Cell>')

    //Imprime quinta celda de la fila (Vacaciones)
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(nValTotVac)) + '</Data></Cell>')

    //Imprime final de la fila
    aAdd(aFormXML, '   </Row>')

    If nTipoArch == 2
        //Función utilizada para la impresión del detalle en el informe análitico por sección
        GPR92ImpA(aFormXML, aFilasAdic)
    EndIf
    
Return

/*/{Protheus.doc} GPR92Total
    
    Función utilizada para la impresión de la sección de Totales.
    
    @type  Static Function
    @author marco.rivera
    @since 25/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @param aTotales, Arreglo, Arreglo con los totales del informe.
    @example
    GPR92Total(aFormXML)
/*/
Static Function GPR92Total(aFormXML, aTotales)

    Default aFormXML    := {}
    
    /*
    aTotales[1] = Valor total de promedios
    aToteles[2] = Valor total de sueldos
    aTotales[3] = Valor total de vacaciones
    atotales[4] = Valor total de filas adicioneles
    */
    Default aTotales    := {0, 0, 0, 8} //El 8 es el valor inicial de las filas con información

    aAdd(aFormXML, '   <Row ss:AutoFitHeight="0">')
    aAdd(aFormXML, '    <Cell ss:StyleID="s84"><Data ss:Type="Number">' + '5' + '</Data></Cell>')
    aAdd(aFormXML, '    <Cell ss:StyleID="s85"><Data ss:Type="String">' + STR0021 + '</Data></Cell>') //"TOTAL"
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(aTotales[1])) + '</Data></Cell>')
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(aTotales[2])) + '</Data></Cell>')
    aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(aTotales[3])) + '</Data></Cell>')
    aAdd(aFormXML, '   </Row>')
    
Return

/*/{Protheus.doc} GPR92ImpA
    
    Función utilizada para le impresión del detalle por sección en el informe analítico.

    @type  Static Function
    @author marco.rivera
    @since 29/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @param aFilasAdic, Arreglo, Arreglo con las líneas adicionales a imprimir.
    @example
    GPR92ImpA(aFormXML, aFilasAdic)
/*/
Static Function GPR92ImpA(aFormXML, aFilasAdic)

    Local nIteracion    := 0
    Local cCodConcep    := ""
    Local cClasifCon    := "" //0 - No aplica, 1 - Sueldos y 2 - Vacaciones
    
    Default aFormXML    := {}
    Default aFilasAdic  := {}

    For nIteracion := 1 To Len(aFilasAdic)

        cCodConcep  := aFilasAdic[nIteracion][1]
        cClasifCon  := aFilasAdic[nIteracion][3]

        //Imprime inicio de la fila
        aAdd(aFormXML, '   <Row ss:AutoFitHeight="0">')

        //Imprime primera celda de fila (No)
        aAdd(aFormXML, '    <Cell ss:StyleID="s80"><Data ss:Type="String">' + ' ' + '</Data></Cell>')

        //Imprime segunda celda de la fila (Descripción)
        aAdd(aFormXML, '    <Cell ss:StyleID="s81"><Data ss:Type="String">' + cCodConcep + " - " + GPR92CarEs(aFilasAdic[nIteracion][4]) + '</Data></Cell>')

        //Imprime tercera celda de la fila (Promedio)
        aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">' + ' ' + '</Data></Cell>')

        If cClasifCon == "2"
            //Imprime cuarta celda de la fila (Sueldos)
            aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">' + ' '+ '</Data></Cell>')
            //Imprime quinta celda de la fila (Vacaciones)
            aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(aFilasAdic[nIteracion][2])) + '</Data></Cell>')
        Else
            //Imprime cuarta celda de la fila (Sueldos)
            aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="Number">' + AllTrim(Str(aFilasAdic[nIteracion][2])) + '</Data></Cell>')
            //Imprime quinta celda de la fila (Vacaciones)
            aAdd(aFormXML, '    <Cell ss:StyleID="s62"><Data ss:Type="String">' + ' ' + '</Data></Cell>')
        EndIf

        //Imprime final de la fila
        aAdd(aFormXML, '   </Row>')
    Next nIteracion

Return

/*/{Protheus.doc} GPR92Fin
    
    Función utilizada para la definición final del XML.

    @type  Static Function
    @author marco.rivera
    @since 26/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @example
    GPR92Fin(aFormXML)
/*/
Static Function GPR92Fin(aFormXML)

    Default aFormXML    := {}

    aAdd(aFormXML, '  </Table>')
    aAdd(aFormXML, '  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
    aAdd(aFormXML, '   <PageSetup>')
    aAdd(aFormXML, '    <Header x:Margin="0.31496062000000002"/>')
    aAdd(aFormXML, '    <Footer x:Margin="0.31496062000000002"/>')
    aAdd(aFormXML, '    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"')
    aAdd(aFormXML, '     x:Right="0.511811024" x:Top="0.78740157499999996"/>')
    aAdd(aFormXML, '   </PageSetup>')
    aAdd(aFormXML, '   <Unsynced/>')
    aAdd(aFormXML, '   <Selected/>')
    aAdd(aFormXML, '   <Panes>')
    aAdd(aFormXML, '    <Pane>')
    aAdd(aFormXML, '     <Number>3</Number>')
    aAdd(aFormXML, '     <ActiveRow>14</ActiveRow>')
    aAdd(aFormXML, '     <ActiveCol>2</ActiveCol>')
    aAdd(aFormXML, '    </Pane>')
    aAdd(aFormXML, '   </Panes>')
    aAdd(aFormXML, '   <ProtectObjects>False</ProtectObjects>')
    aAdd(aFormXML, '   <ProtectScenarios>False</ProtectScenarios>')
    aAdd(aFormXML, '  </WorksheetOptions>')
    aAdd(aFormXML, ' </Worksheet>')
    aAdd(aFormXML, '</Workbook>')
    
Return

/*/{Protheus.doc} GPR92TabT
    
    Función utilizada para crear tabla temporal para el procesamiento de la información.

    @type  Static Function
    @author marco.rivera
    @since 24/11/2022
    @version 1.0
    @param cAliasTmp, Caracter, Tabla temporal con datos del periodo.
    @param cSucursal, Caracter, Códigos de Sucursales a filtrar.
    @param cProceso, Caracter, Códigos de Procesos a filtrar.
    @param cProcedim, Caracter, Códigos de Procedimientos a filtrar.
    @param cPeriodo, Caracter, Código del Periodo a filtrar.
    @param cIdSeccion, Caracter, Identificador de la sección a procesar.
    @return cAliasTmp, Caracter, Tabla temporal con datos del periodo.
    @example
    GPR92TabT(cAliasTmp, cSucursal, cProceso, cProcedim, cPeriodo, cIdSeccion)
/*/
Static Function GPR92TabT(cAliasTmp, cSucursal, cProceso, cProcedim, cPeriodo, cIdSeccion)

    Local cPeriodIni    := ""
    Local cPeriodFin    := ""
    Local cClasifCon    := "'1', '2'" //0 - No aplica, 1 - Sueldos y 2 - Vacaciones
    Local cCodConDia    := "900" //Concepto de Días pagados
    Local cExpInEmpl    := ""

    Default cAliasTmp   := GetNextAlias()
    Default cSucursal   := ""
    Default cProceso    := ""
    Default cProcedim   := ""
    Default cPeriodo    := ""
    Default cIdSeccion  := ""

    //Se define fecha inicial y final del mes en base al periodo informado
    cPeriodIni    := cPeriodo + "01"
    cPeriodFin    := cPeriodo + StrZero(Day(LastDay(SToD(cPeriodo + "01"))), 2)

    //Se definen expresiones para el query
    cSucursal   := "%" + cSucursal + "%"
    cProceso    := "%" + cProceso + "%"
    cProcedim   := "%" + cProcedim + "%"
    cClasifCon  := "%(" + cClasifCon + ")%"

    //Se crea expresión para determinar el tipo de empleado
    If cIdSeccion == "I"
        cExpInEmpl := "%SRA.RA_TPCONTR IN ('1')%" //Expresión para obtener empleados Indefinidos
    ElseIf cIdSeccion == "F"
        cExpInEmpl := "%SRA.RA_TPCONTR IN ('2') AND SRA.RA_TIPOEST NOT IN ('1', '2', '3')%" //Expresión para obtener empleados Fijos
    Else
        cExpInEmpl := "%SRA.RA_TPCONTR IN ('2') AND SRA.RA_TIPOEST IN ('2', '3')%" //Expresión para obtener empleados Aprendices
    EndIf
    
    BeginSql Alias cAliasTmp
        SELECT 
            RD_MAT, RD_PD, RD_HORAS, RD_VALOR, RV_SALGRA, RV_DESCDET
        FROM
             %table:SRD% SRD
        INNER JOIN
	        %table:SRV% SRV
        ON
	        SRD.RD_PD = SRV.RV_COD
        WHERE
            %exp:cSucursal% AND
            %exp:cProceso% AND
            %exp:cProcedim% AND
            SRD.RD_PERIODO = %exp:cPeriodo% AND
            (SRD.RD_PD = %exp:cCodConDia% OR SRD.RD_PD IN ( 
                            SELECT
                                RV_COD
                            FROM
                                %table:SRV% SRV
                            WHERE
                                SRV.RV_SALGRA IN %exp:cClasifCon% AND 
                                SRV.%notDel%)) AND
            SRD.RD_MAT IN (
                SELECT 
                    RA_MAT
                FROM
                    %table:SRA% SRA
                WHERE
                    %exp:cExpInEmpl% AND
                    (( SRA.RA_SITFOLH = %exp:"D"% AND ( SRA.RA_DEMISSA >= %exp:cPeriodIni% AND SRA.RA_DEMISSA <= %exp:cPeriodFin%)) OR 
                    (SRA.RA_SITFOLH <> %exp:"D"% AND SRA.RA_ADMISSA <= %exp:cPeriodFin%)) AND 
                    SRA.%notDel%) AND
            SRD.%notDel%
        ORDER BY
            SRD.RD_MAT, SRD.RD_PD
    EndSql
    
Return cAliasTmp

/*/{Protheus.doc} GPR92ObtI
    
    Functión utilizada para obtener la información a imprimir a partir de la tabla temporal.

    @type  Static Function
    @author marco.rivera
    @since 29/11/2022
    @version 1.0
    @param cAliasTmp, Caracter, Tabla temporal con datos del periodo.
    @param nValTotPro, Numérico, Total del promedio por sección.
    @param nValTotSld, Numérico, Total de sueldos por sección.
    @param nValTotVac, Numérico, Total de vacaciones por sección.
    @param aTotales, Arreglo, Arreglo con los totales del informe.
    @param aFilasAdic, Arreglo, Arreglo con las filas adicionales para el sintético.
    @param nTipoArch, Numérico, Tipo de impresión del informe 1 - Sintético y 2 - Analítico.
    @example
    GPR92ObtI(cAliasTmp, nValTotPro, nValTotSld, nValTotVac, aTotales, aFilasAdic, nTipoArch)
/*/
Static Function GPR92ObtI(cAliasTmp, nValTotPro, nValTotSld, nValTotVac, aTotales, aFilasAdic, nTipoArch)

    Local cCodConDia    := "900" //Concepto de Días pagados
    Local nDiaLabMes    := 30

    //Variables de total por Emppleado
    Local nValSldEmp    := 0
    Local nValDiaEmp    := 0
    Local nPosConcep    := 0
    Local cMatricula    := ""

    Default cAliasTmp   := GetNextAlias()
    Default nValTotPro  := 0
    Default nValTotSld  := 0
    Default nValTotVac  := 0
    /*
    aTotales[1] = Valor total de promedios
    aToteles[2] = Valor total de sueldos
    aTotales[3] = Valor total de vacaciones
    atotales[4] = Valor total de filas adicioneles
    */
    Default aTotales    := {0, 0, 0, 8} //El 8 es el valor inicial de las filas con información
    Default aFilasAdic  := {}
    Default nTipoArch   := 1
    
    DBSelectArea(cAliasTmp)
    (cAliasTmp)->(DBGoTop())
    While (cAliasTmp)->(!EoF())
        If (cAliasTmp)->RD_MAT <> cMatricula
            nValTotPro += nValDiaEmp / nDiaLabMes
            nValSldEmp := 0
            nValDiaEmp := 0
            cMatricula := (cAliasTmp)->RD_MAT
        EndIf
              
        If (cAliasTmp)->RV_SALGRA == "2" //Vacaciones
            nValTotVac += (cAliasTmp)->RD_VALOR
        Elseif (cAliasTmp)->RD_PD == cCodConDia //Días trabajados
            nValDiaEmp += (cAliasTmp)->RD_HORAS
        Else //Sueldos
            nValTotSld += (cAliasTmp)->RD_VALOR
            nValSldEmp += (cAliasTmp)->RD_VALOR
        EndIf

        //Se obtiene la filas adicionales de impresión para el informe analítico
        If nTipoArch == 2 //Si es archivo analítico
            If !((cAliasTmp)->RD_PD $ cCodConDia)
                nPosConcep := aScan(aFilasAdic, { |x| x[1] == (cAliasTmp)->RD_PD } )
                If nPosConcep == 0
                    aAdd(aFilasAdic, {(cAliasTmp)->RD_PD, NoRound((cAliasTmp)->RD_VALOR, 2), (cAliasTmp)->RV_SALGRA, AllTrim((cAliasTmp)->RV_DESCDET)})
                Else
                    aFilasAdic[nPosConcep][2] += NoRound((cAliasTmp)->RD_VALOR, 2)
                EndIf
            EndIf
        EndIf

        (cAliasTmp)->(DBSkip())
    EndDo
    (cAliasTmp)->(DBCloseArea())

    nValTotPro += nValDiaEmp / nDiaLabMes

    nValTotPro := NoRound(nValTotPro, 2)
    nValTotSld := NoRound(nValTotSld, 2)
    nValTotVac := NoRound(nValTotVac, 2)

    //Almacena el valores de los totales
    aTotales[1] += nValTotPro //Total de Promedios
    aTotales[2] += nValTotSld //Total de Sueldos
    aTotales[3] += nValTotVac //Total de Vacaciones
    aTotales[4] += Len(aFilasAdic) //Total de filas adicionales agregadas

Return

/*/{Protheus.doc} GPR92CarEs
    
    Función utilizada para sustituir los acentos a código utilizado en HTML/XML.

    @type  Static Function
    @author marco.rivera
    @since 26/11/2022
    @version version
    @param cTexto, Character, Texto con caracteres a convertir.
    @return cRetStr, Character, Texto con caracteres convertidos.
    @example
    GPR92CarEs(cTexto)
/*/
Static Function GPR92CarEs(cTexto)

    Local cRetStr       := ""
    Local aCarEsp       := {}
    Local nIteracion    := 0

    Default cTexto  := ""

    If !Empty(cTexto)

        cRetStr := cTexto

        aAdd(aCarEsp, {"á", "&aacute;"})
        aAdd(aCarEsp, {'é', "&eacute;"})
        aAdd(aCarEsp, {"í", "&iacute;"})
        aAdd(aCarEsp, {"ó", "&oacute;"})
        aAdd(aCarEsp, {"ú", "&uacute;"})
        aAdd(aCarEsp, {"Á", "&Aacute;"})
        aAdd(aCarEsp, {'É', "&Eacute;"})
        aAdd(aCarEsp, {"Í", "&Iacute;"})
        aAdd(aCarEsp, {"Ó", "&Oacute;"})
        aAdd(aCarEsp, {"Ú", "&Uacute;"})
        aAdd(aCarEsp, {"ü", "&uuml;"})
        aAdd(aCarEsp, {"Ü", "&Uuml;"})

        For nIteracion := 1 To Len(aCarEsp)
            cRetStr := StrTran(cRetStr, aCarEsp[nIteracion, 1], aCarEsp[nIteracion, 2])
        Next nIteracion

    EndIf 
    
Return cRetStr

/*/{Protheus.doc} GPR92Build
    
    Función utilizada para generar el informe en el directorio y nombre informado.

    @type  Static Function
    @author marco.rivera
    @since 26/11/2022
    @version 1.0
    @param aFormXML, Arreglo, Arreglo que tiene la defición del XML.
    @param cRutaArch, Caracter, Cadena que tiene la ruta en la que se generará el archivo.
    @param cNomArch, Caracter, Cadena que tiene el nombre que tendrá el archivo.
    @param cMsgError, Caracter, Cadena enviada por referencia para contener el error al crear el archivo.
    @param aTotales, Arreglo, Arreglo con los totales del informe.
    @return lRet, Lógico, Retorna .F. si ocurrió un error en la creación del archivo.
    @example
    GPR92Build(aFormXML, cRutaArch, cNomArch, cMsgError)
/*/
Static Function GPR92Build(aFormXML, cRutaArch, cNomArch, cMsgError, aTotales)
    
    Local nRetArch      := 0
    Local nIteracion    := 0
    Local lRet          := .T.
    Local cExtension    := ".xls"

    Default aFormXML    := {}
    Default cRutaArch   := ""
    Default cNomArch    := ""
    Default cMsgError   := ""
    /*
    aTotales[1] = Valor total de promedios
    aToteles[2] = Valor total de sueldos
    aTotales[3] = Valor total de vacaciones
    atotales[4] = Valor total de filas adicioneles
    */
    Default aTotales    := {0, 0, 0, 8} //El 8 es el valor inicial de las filas con información

    //Se valida que exista el archivo y si existe se borra
    If File(cRutaArch + cNomArch + cExtension)
        FErase(cRutaArch + cNomArch + cExtension)
        
        //Se valida si ocurre un error durante el borrado
        If FError() <> 0
            //Se obtiene el error al borrar el archivo
		    cMsgError := AllTrim(Str(FError()))  + " - " + STR0022 //"Revise los permisos del directorio informado o cierre el archivo si está siendo utilizado e intente nuevamente." 
		    lRet := .F.
        EndIf
	EndIf

    //Si no ocurrió un error durante el borrado o del archivo se procede a crearlo
    If lRet
        //Se realiza la creación del archivo
        nRetArch := MSFCreate(cRutaArch + cNomArch + cExtension, 0)

        //Si se encuentra un error en la creación del archivo
        If FError() <> 0 .And. nRetArch < 0
            //Se obtiene el error al crear el archivo
            cMsgError := AllTrim(Str(FError()))  + " - " + STR0023 //"Revise los permisos del directorio informado e intente nuevamente."
            lRet := .F.
        EndIf
    EndIf

    //Si no ocurrió un error durante el borrado o creación del archivo se procede a escribir las líneas
    If lRet
        //Se escribe en el archivo, cada línea contenida en el arreglo
        For nIteracion := 1 To Len(aFormXML)
            If aFormXML[nIteracion] == "NumeroFilas" //Idenficador utilizado para sustituir el contador de filas
                aFormXML[nITeracion] := '  <Table ss:ExpandedColumnCount="5" ss:ExpandedRowCount="' + AllTrim(Str(aTotales[4])) + '" x:FullColumns="1"'
            EndIf
            FWrite(nRetArch, aFormXML[nIteracion] + CRLF)
        Next nIteracion
        
        //Se finaliza la creación del archivo
        FClose(nRetArch)
    EndIf

Return lRet
