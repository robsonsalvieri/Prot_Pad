#include "fisa817.ch"
#include "protheus.ch"
#include "fileio.ch"
#include "shell.ch"
#include "xmlxfun.ch"
#include "vkey.ch"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

// Elementos de aRegs 
#Define dfRecNo			1	// Recno()
#Define dfEstatus		2	// Status actual (F1/F2_FLFTEX)
#Define dfCancelable	3	// Es cancelable (F1/F2_ESCANC)
#Define dfXML			4	// Nombre xml
#Define dfResultado		5	// Resultado de WS
#Define dfMensaje		6	// Mensaje de WS
#Define dfActualiza		7	// Actualizar status: .T. / .F.
#Define dfDocumento		8	// Doc + Serie
#Define dfCliente		9	// Cliente + Loja
#Define dfConfProc		10	// Confirma proceso mediante WS
#Define dfMotivo        11  // Motivo de cancelación del documento
#Define dfUUIDDoc       12  // UUID que Sustituye
#Define dfCanFper       13  // Cancelable fuera de Periodo
#Define dfMsgCan        14  // Mensaje de Cancelación
#Define dfFraPer		15  // Doc fuera de Periodo
#Define dfLongitud		15	// Subarreglo en aRegs


// #########################################################################################
// Projeto: Factura Electrónica México
// Modulo : SIGATFAT
// Fonte  : FISA817
// -----------+-------------------+------------+--------------------------------------------
// Data       | Autor             | Issue      | Descricao
// -----------+-------------------+------------+--------------------------------------------
// 23/10/2018 | Alberto Rodriguez |DMINA-4570  | Servicios de Cancelación de CFDI.
// -----------+-------------------+------------+--------------------------------------------
// 07/12/2018 | Alf Medrano       |DMINA-4858  | se quita line en blanco para relacionar la rutina al issue
// 07/12/2018 | M.Camargo         |DMINA-4980  | se agrega comentario para relacionar la rutina al issue
// 07/12/2018 | M.Camargo         |DMINA-4923  | se agrega comentario para relacionar la rutina al issue
// 09/01/2019 | Alberto Rodriguez |DMINA-4923  | Masteredi: Respuesta JSON con atributos diferentes al SAT, sin EstatusUUID.
// 09/04/2019 | Luis Enríquez Mata|DMINA-6337  | Modificación para que al cancelar CFDI se realice anulado en lugar de borrado de los documentos.
// 09/04/2019 | Luis Enríquez Mata|DMINA-6337  | Defecto: DMINA-6566 Se modifica agregado de descripción del código 201 y 202 cuando en respuesta del PAC es vacía..
// 09/04/2019 | Alfredo Medrano   |DMINA-6646  | Se agrega fun ObtOrigen que obtiene la rutina origen del documento(E1_ORIGEM)
// 28/05/2019 | Alberto Rodriguez |DMINA-6699  | Ejecución directa de las rutinas de la LOCXNF (MATA467N, MATA465N); sin MsExecAuto()
// 25/07/2019 | Alf Medrano       |DMINA-7162  | En fun RespWS para el proceso “cancelación con aceptación” se válida para que no se elimine el docto y se quede en estatus de "proceso de cancelación"".
//----------------------------------------------------------------------------------------------------------
// 07/10/2019 | M.Camargo         |DMINA-7452  | ajustes nuevo proceso Cancelación para PAC Solución Factible
// 05/03/2020 | Alberto Rodriguez |DMINA-8306  | Aplica ChangeQuery() a expresión para filtrar browse. Depuración F817BRWSFX() por buenas prácticas
//            | Marco Augusto Glez|            | Tambien se elimina funcion LeeSX3, porque se reemplaza con el uso de FWSX3Util
// 12/03/2020 | Marco Augusto Glez|DMINA-8183  | Se modifica la funcion ChecaResp() para concatenar el contenido del atributo "EsCancelable" en el mensaje
//            |                   |            | mensaje mostrado al usuario.
// 12/06/2021 | Luis Enríquez Mata|DMINA-12334 | Se modifica función F817VMark() para validar si las NCC tienen compensaciones.

/*/{Protheus.doc} FISA817
Servicios de Cancelación de CFDI.

@author    Alberto Rodriguez
@version   11.8
@since     23/10/2018
/*/
//------------------------------------------------------------------------------------------
Function FISA817()
	Local aArea			:= GetArea()

	Private cCadastro	:= OemToAnsi(STR0001)	//"Cancelación de CFDI"
	Private cPerg		:= "FISA817"
	Private nTipo		:= 0
	Private dFechaI	:= CtoD("")
	Private dFechaF	:= CtoD("")
	Private cSerieI	:= ""
	Private cSerieF	:= ""
	Private cDocI		:= ""
	Private cDocF		:= ""
	Private cClienteI	:= ""
	Private cClienteF	:= ""
	Private cLojaI		:= ""
	Private cLojaF		:= ""

	// Parametros de timbrado
	Private cRutaSrv := ""
	Private cRutaSmr := ""
	Private cCfdUser := ""
	Private cCfdPass := ""
	Private cCFDiPAC := ""
	Private cCFDiAmb := ""
	Private cCFDiCer := ""
	Private cCFDiKey := ""
	Private cCFDiCve := ""
	Private cCFDiNF  := ""
	Private cCFDiNC  := ""
	Private nCFDiCmd := 0
	Private cCFDiSF1 := ""
	Private cCFDiSF2 := ""
	Private lProxySr := .F.
	Private cProxyIP := ""
	Private nProxyPt := 0
	Private lProxyAW := .F.
	Private cProxyUr := ""
	Private cProxyPw := ""
	Private cProxyDm := ""
	Private cLogWS   := ""
	Private cRutina  := ""
	Private cProxy   := "[PROXY]"
	Private cTipo    := ""
	Private cEspecie := ""
	Private cSerNCA	 := ""

	// Validar proceso de F.E.
	If !ChecaCFD()
		Return Nil
	EndIf

	If Pergunte(cPerg,.T.)
		nTipo		:= MV_PAR01
		dFechaI		:= MV_PAR02
		dFechaF		:= MV_PAR03
		cSerieI		:= MV_PAR04
		cSerieF		:= MV_PAR05
		cDocI		:= MV_PAR06
		cDocF		:= MV_PAR07
		cClienteI	:= MV_PAR08
		cClienteF	:= MV_PAR09
		cLojaI		:= MV_PAR10
		cLojaF		:= MV_PAR11

		If nTipo == 1
			cCadastro += STR0060 //" - Factura"
			cEspecie := "NF"
		ElseIf nTipo == 2
			cCadastro += STR0061 //" - Nota de Débito"
			cEspecie := "NDC"
		Else
			cCadastro += STR0062 //" - Nota de Crédito"
			cEspecie := "NCC"
		EndIf

		// Pantalla de Browse
		F817BRWSFX()
	EndIf

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} ChecaCFD
//Valida parámetros de factura electrónica.
@author ARodriguez
@since 23/10/2018
@version 1.0
${parametersSection}
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Static Function ChecaCFD()
	Local aGerarCFD		:= {}
	Local lRet			:= .T.
	Local cMsgCFD		:= ""
	Local nX			:= 0
	Local nVersion		:= 0


	// Checa parametros
	aGerarCFD := CFDVerific()

	If aGerarCFD[1] == "0"
		MsgAlert(STR0003, STR0002)	// "No está en uso la Factura Electrónica" # "CFDI"
		lRet := .F.

	ElseIf !Empty(aGerarCFD[2])
		For nX := 1 To Len(aGerarCFD[2])
			cMsgCFD += aGerarCFD[2][nX][2] + CRLF
		Next nX

		MsgAlert(cMsgCFD, STR0002)	// <mensajes generados en CFDVerific()> # "CFDI"
		lRet := .F.

	Else
		cRutaSrv := &(SuperGetmv( "MV_CFDDOCS" , .F. , "\cfd\facturas\" ))	// Ruta donde se encuentran las facturas.xml (servidor)

		If GetRemoteType() == 5 //Tratamiento HTML
			cRutaSmr := &(SuperGetmv( "MV_CFDSMAR" , .F. , "\system\\" ))
		Else
			cRutaSmr := &(SuperGetmv( "MV_CFDSMAR" , .F. , "GetClientDir()" ))	// Ruta A donde se copiaran los archivos que vienen del servidor . . .  + "\TimbradoATEB\bin\Debug\"
		Endif

		nVersion := Val(GetVersao(.F.))

		If nVersion < 12
			cCfdUser := SuperGetmv( "MV_CFDUSER" , .F. , "" )				// Usuario del servicio web
			cCfdPass := SuperGetmv( "MV_CFDPASS" , .F. , "" )				// Password del servicio web
			cCFDiPAC := SuperGetmv( "MV_CFDIPAC" , .F. , "" )				// Rutina a ejecutar (PAC)
			cCFDiAmb := SuperGetmv( "MV_CFDIAMB" , .F. , "T" )				// Ambiente (Teste o Produccion)
			cCFDiCer := SuperGetmv( "MV_CFDICER" , .F. , "" )				// Archivo de llave pública (.cer)
			cCFDiKey := SuperGetmv( "MV_CFDIKEY" , .F. , "" )				// Archivo de llave privada (.key)
			cCFDiCve := SuperGetmv( "MV_CFDICVE" , .F. , "" )				// Clave de certificado de llave privada
		Else
			cCfdUser := SuperGetmv( "MV_CFDI_US" , .F. , "" )				// Usuario del servicio web (Ant: MV_CFDUSER)
			cCfdPass := SuperGetmv( "MV_CFDI_CO" , .F. , "" )				// Password del servicio web (Ant: MV_CFDPASS)
			cCFDiPAC := SuperGetmv( "MV_CFDI_PA" , .F. , "" )				// Rutina a ejecutar (PAC) (Ant: MV_CFDIPAC)
			cCFDiAmb := SuperGetmv( "MV_CFDI_AM" , .F. , "T" )				// Ambiente (Teste o Produccion) (Ant: MV_CFDIAMB)
			cCFDiCer := SuperGetmv( "MV_CFDI_CE" , .F. , "" )				// Archivo de llave pública (.cer) (Ant: MV_CFDICER)
			cCFDiKey := SuperGetmv( "MV_CFDI_PR" , .F. , "" )				// Archivo de llave privada (.key) (Ant: MV_CFDIKEY)
			cCFDiCve := SuperGetmv( "MV_CFDI_CL" , .F. , "" )				// Clave del certificado de llave privada
		EndIf

		nCFDiCmd := SuperGetmv( "MV_CFDICMD" , .F. , 0 )					// Mostrar ventana de comando del Shell: 0=no, 1=si
		cCFDiSF1 := SuperGetmv( "MV_CFDNAF1" , .F. , "" )					// Nombre para archivo xml de SF1
		cCFDiSF2 := SuperGetmv( "MV_CFDNAF2" , .F. , "" )					// Nombre para archivo xml de SF2
		lProxySr := SuperGetmv( "MV_PROXYSR" , .F. , .F. )					// Emplear Proxy Server?
		cProxyIP := Trim(SuperGetmv( "MV_PROXYIP" , .F. , "" ))				// IP del Proxy Server
		nProxyPt := SuperGetmv( "MV_PROXYPT" , .F. , 0 )					// Puerto del Proxy Server
		lProxyAW := SuperGetmv( "MV_PROXYAW" , .F. , .F. )					// Autenticación en Proxy Server con credenciales de Windows?
		cProxyUr := Trim(SuperGetmv( "MV_PROXYUR" , .F. , "" ))				// Usuario para autenticar Proxy Server
		cProxyPw := Trim(SuperGetmv( "MV_PROXYPW" , .F. , "" ))				// Clave para autenticar Proxy Server
		cProxyDm := Trim(SuperGetmv( "MV_PROXYDM" , .F. , "" ))				// Dominio para autenticar Proxy Server
		cLogWS   := SuperGetmv( "MV_CFDILOG" , .F. , "LOG" )				// Tipo de log en consumo del servicio web: LOG (default), LOGDET (detallado), NOLOG (ninguno)
		cSerNCA	 := SuperGetmv( "MV_SERNCA" , .F. , "" ) 					// Serie de Nota de Cancelación para Docs. Fuera de Periodo
		cRutina := "Timbrado" + Trim(cCFDiPAC) + ".exe "

		If Empty(cRutaSmr) .Or. !( cRutaSmr == Strtran( cRutaSmr , " " ) )
			cMsgCFD += "MV_CFDSMAR"
		EndIf
		If Empty(cCfdUser)
			cMsgCFD += IIf(nVersion < 12, "MV_CFDUSER", "MV_CFDI_US") + CRLF
		EndIf
		If Empty(cCfdPass)
			cMsgCFD += IIf(nVersion < 12, "MV_CFDPASS", "MV_CFDI_CO") + CRLF
		EndIf
		If Empty(cCFDiPAC)
			cMsgCFD += IIf(nVersion < 12, "MV_CFDIPAC", "MV_CFDI_PA") + CRLF
		EndIf
		If Empty(cCFDiAmb)
			cMsgCFD += IIf(nVersion < 12, "MV_CFDIAMB", "MV_CFDI_AM") + CRLF
		EndIf
		If Empty(cCFDiCer) .And. Empty(cCFDiKey)
			cMsgCFD += IIf(nVersion < 12, "MV_CFDICER", "MV_CFDI_CE") + CRLF
		EndIf
		If Empty(cCFDiKey)
			cMsgCFD += IIf(nVersion < 12, "MV_CFDIKEY", "MV_CFDI_PR") + CRLF
		EndIf
		If Empty(cCFDiCve)
			cMsgCFD += IIf(nVersion < 12, "MV_CFDICVE", "MV_CFDI_CL") + CRLF
		EndIf

		If !Empty(cMsgCFD)
			cMsgCFD := STR0023 + CRLF + cMsgCFD		//"Revise la configuración de los siguientes parámetros:"
		EndIf

		If !Empty(cCFDiPAC) .And. !File( cRutaSmr + Trim(cRutina) )
			cMsgCFD += IIf( !Empty(cMsgCFD), CRLF, "") + Strtran( STR0024 , "#EXEPAC#", cRutina)	//"El ejecutable de timbrado #EXEPAC# no existe en la ruta indicada en el parámetro MV_CFDSMAR."
		EndIf

		If !Empty(cCFDiCer) .And. !File( cRutaSmr + Trim(cCFDiCer) )
			cMsgCFD += IIf( !Empty(cMsgCFD), CRLF, "") + Strtran( STR0025 , "#CERT#", cCFDiCer)	//"El certificado #CERT# no existe en la ruta indicada en el parámetro MV_CFDSMAR."
		EndIf

		If !Empty(cCFDiKey) .And. !File( cRutaSmr + Trim(cCFDiKey) )
			cMsgCFD += IIf( !Empty(cMsgCFD), CRLF, "") + Strtran( STR0025 , "#CERT#", cCFDiKey)	//"El certificado #CERT# no existe en la ruta indicada en el parámetro MV_CFDSMAR."
		EndIf

		If !Empty(cMsgCFD)
			//MsgAlert(cMsgCFD, STR0002)	//  # "CFDI"
			MsgAlert(cMsgCFD + CRLF + cRutaSmr + CRLF + "Version " + Str(nVersion) , STR0002)		//"CFDI"
			lRet := .F.

		Else
			If nCFDiCmd < 0 .Or. nCFDiCmd > 10
				nCFDiCmd := 0
			Endif

			// Parámetros para el Proxy Server
			cProxy += "[" + If( lProxySr , "1" , "0" ) + "]"
			cProxy += "[" + cProxyIP + "]"
			cProxy += "[" + lTrim( Str( nProxyPt ) ) + "]"
			cProxy += "[" + If( lProxyAW , "1" , "0" ) + "]"
			cProxy += "[" + If( lProxyAW , "" , cProxyUr ) + "]"
			cProxy += "[" + If( lProxyAW , "" , cProxyPw ) + "]"
			cProxy += "[" + If( lProxyAW , "" , cProxyDm ) + "]"

		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} F817BRWSFX
//Browse con documentos del proceso de cancelación de CFDI.
@author ARodriguez
@since 23/10/2018
@version 1.0
${parametersSection}
@return Nil
@example
(examples)
@see (links_or_references)
nTipo == 1 => cEspecie == "NF " // Factura Venta
nTipo == 2 => cEspecie == "NDC" // Nota Débito al Cliente
nTipo == 3 => cEspecie == "NCC" // Nota de Crédito al cliente
/*/
Static Function F817BRWSFX()
	Local aCores		:= F817Cores(nTipo)
	Local cAliasSF		:= ""
	Local aFields		:= {}
	Local aCampos		:= {}
	Local cCampo		:= ""
	Local cStatus		:= ""
	Local cQuery		:= ""
	Local nX			:= 0

	Private cMarca		:= ""
	Private aRotina		:= MenuDef()
	Private aRegs		:= {}

	//Se obtienen campos no virtuales
	Private aCabsSF1	:= FWSX3Util():GetAllFields("SF1", .F.)
	Private aCabsSF2	:= FWSX3Util():GetAllFields("SF2", .F.)
	Private aItensSD1	:= FWSX3Util():GetAllFields("SD1", .F.)
	Private aItensSD2	:= FWSX3Util():GetAllFields("SD2", .F.)

	// Genera cadena SQL / Filter segun la tabla de documentos
	If nTipo == 1 .Or. nTipo == 2
		cAliasSF := "SF2"
		aFields := {"F2_DOC","F2_SERIE","F2_CLIENTE","F2_LOJA","F2_EMISSAO","F2_UUID","F2_FECCANC","F2_HORACAN"}
		aCampos := CamposBrw( aFields, cAliasSF)
		cCampo := "F2_MARK"
		cQuery := "F2_ESPECIE = " + IIf(nTipo == 1, "'NF'", "'NDC'") + ;
					" AND F2_EMISSAO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "'" + ;
					" AND F2_SERIE >= '" + MV_PAR04 + "' AND F2_SERIE <= '" + MV_PAR05 + "'" + ;
					" AND F2_DOC >= '" + MV_PAR06 + "' AND F2_DOC <= '" + MV_PAR07 + "'" + ;
					" AND F2_CLIENTE >= '" + MV_PAR08 + "' AND F2_CLIENTE <= '" + MV_PAR09 + "'" + ;
					" AND F2_LOJA >= '" + MV_PAR10 + "' AND F2_LOJA <= '" + MV_PAR11 + "'" + ;
					" AND F2_UUID <> '' AND F2_FILIAL ='" + xFilial("SF2") + "'"

	ElseIf nTipo == 3 // Nota de Crédito al cliente
		cAliasSF := "SF1"
		aFields := {"F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_EMISSAO","F1_UUID","F1_FECCANC","F1_HORACAN"}
		aCampos := CamposBrw( aFields, cAliasSF)
		cCampo := "F1_MARK"
		cQuery := "F1_ESPECIE = 'NCC'" + ;
					" AND F1_EMISSAO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "'" + ;
					" AND F1_SERIE >= '" + MV_PAR04 + "' AND F1_SERIE <= '" + MV_PAR05 + "'" + ;
					" AND F1_DOC >= '" + MV_PAR06 + "' AND F1_DOC <= '" + MV_PAR07 + "'" + ;
					" AND F1_FORNECE >= '" + MV_PAR08 + "' AND F1_FORNECE <= '" + MV_PAR09 + "'" + ;
					" AND F1_LOJA >= '" + MV_PAR10 + "' AND F1_LOJA <= '" + MV_PAR11 + "'" + ;
					" AND F1_UUID <> '' AND F1_FILIAL ='" + xFilial("SF1") + "'"

	EndIf

	// Aplica ChangeQuery; en Oracle no funciona F?_UUID <> '', debe ser F?_UUID <> ' '
	cQuery := "SELECT * FROM " + RetSqlName(cAliasSF) + " WHERE " + cQuery
	cQuery := ChangeQuery(cQuery)
	cQuery := Alltrim(Substr(cQuery, At(" WHERE ",cQuery)+7))

	cMarca := GetMark(,cAliasSF,cCampo)
	aCores := F817Cores(IIf(cAliasSF == "SF2", 1, 2))

	// Pantalla de Browse con los documentos filtrados
	MarkBrow(cAliasSF,cCampo,cStatus,aCampos,,cMarca,"F817VMARK(1)",,,,"F817VMARK(2)",,cQuery,,aCores)

	// Desmarcar registros
	For nX := 1 to Len(aRegs)
		If nTipo == 1 .Or. nTipo == 2
			SF2->(dbGoto(aRegs[nX,dfRecNo]))
			RecLock("SF2", .F.)
			SF2->F2_MARK	:= "  "
			SF2->(MsUnlock())
		Else
			SF1->(dbGoto(aRegs[nX,dfRecNo]))
			RecLock("SF1", .F.)
			SF1->F1_MARK	:= "  "
			SF1->(MsUnlock())
		EndIf
	Next nX

	DbSelectArea(cAliasSF)
	RetIndex(cAliasSF)

Return Nil

/*/{Protheus.doc} MenuDef
//Genera botones de opciones del proceso.
@author ARodriguez
@since 23/10/2018
@version 1.0
${parametersSection}
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd(aRotina, {STR0005 ,"F817Consul"		,0,2,0,.F.}) //Act. Status
	aAdd(aRotina, {STR0004 ,"F817Cancel"		,0,2,0,.F.}) //Cancelar
	aAdd(aRotina, {STR0006 ,"F817Visual"		,0,2,0,.F.}) //Visualizar
	aAdd(aRotina, {STR0007 ,"F817Leyend"		,0,2,0,.F.}) //Leyenda
	aAdd(aRotina, {STR0008 ,"PesqBrw"			,0,1,0,.F.}) //Buscar
	aAdd(aRotina, {STR0066 ,"F817CanMot"		,0,2,0,.F.}) //Solic. Canc. Pendientes

Return aRotina
/*/{Protheus.doc} F817CanMot
	Función que detona la solicitud de cancelación para los documentos pendientes.
	para la cancelación.
	@type function
	@author eduardo.manriquez
	@since 24/02/2022
	@version 1.0
	@return
	/*/
Function F817CanMot()
	Local cPercCan := "F817CAN"
	Local cDoc     := ""
	Local cSerie   := ""
	Local cFilSF3  := xFilial("SF3")
	Local aMotCancel := {}
	Local cDocTimb := ""
	Local UUIDDoc  := ""
	Local cOpeDoc  := ""
	Local lDocExis := .F.
	Local cCtrl    := (chr(13)+chr(10))
	Local cEstado  := ""
	Local cStaAct  := ""
	Local cMsg	   := ""
	Local cDirLoc  := SuperGetmv( "MV_CFDCARF" , .F. ,"")
	Local aArchivos:= {}

	If Pergunte(cPercCan,.T.)
		cSerie   := MV_PAR01
		cDoc     := MV_PAR02
		If !Empty(cSerie) .And. !Empty(cDoc)
			dbSelectArea("SF3")
			SF3->(dbSetOrder(6)) //F3_FILIAL+F3_NFISCAL+F3_SERIE
			If SF3->(MsSeek(cFilSF3 + cDoc + cSerie))
				If SF3->F3_STATUS $ "S|A|R|E" //Documento anulado pero no Canelado ante el SAT
					cOpeDoc := F817DOCTIM(cSerie, cDoc, @cDocTimb, @UUIDDoc)
					lDocExis := .T.
					cStaAct := ALLTRIM(SF3->F3_STATUS)
					If cOpeDoc == "R"
						MsgAlert( STR0072 +  Alltrim(cSerie) + "-" + Alltrim(cDoc) + STR0073 + Alltrim(cDocTimb) + STR0074,STR0015) //"No es posible solicitar la cancelación ante el SAT del documento " //", ya que se encuentra relacionado al dococumento " //" para el cual no se ha timbrado el CFDI, proceda a borrarlo desde la rutinda donde se registró." //"ATENCION"
					Else
						aAdd( aRegs , Array(dfLongitud))

						aRegs[Len(aRegs),dfCancelable] := .T.
						aRegs[Len(aRegs),dfDocumento] := AllTrim(SF3->F3_NFISCAL) + SF3->F3_SERIE
						aRegs[Len(aRegs),dfCliente] := AllTrim(SF3->F3_CLIEFOR)
						aRegs[Len(aRegs),dfConfProc] := .T.
						aRegs[Len(aRegs),dfXML]  := fNombreXml(SF3->F3_CODNFE) //Nombre XML
						aRegs[Len(aRegs),12] := ""
						aRegs[Len(aRegs),dfCanFper] := .F. // Cancelable fuera de periodo
						aRegs[len(aRegs),dfMsgCan] := "" //Mensaje Cancelación fuera de Periodo
						aRegs[len(aRegs),dfFraPer] := .F. // doc fuera de periodo
						If cStaAct != "E"
							If cOpeDoc <> "T" 
								If nTipo == 1 .Or. nTipo == 2
									aRegs[Len(aRegs),dfConfProc] := F817MCanc("SF2","F2",@aMotCancel,"")
								Else
									aRegs[Len(aRegs),dfConfProc] := F817MCanc("SF1","F1",@aMotCancel,"")
								EndIf
								aRegs[Len(aRegs),dfMotivo] := aMotCancel[1]
							Else
								aRegs[Len(aRegs),dfConfProc] := MSGYESNO(STR0075 + Alltrim(cSerie) + "-" + Alltrim(cDoc) + cCtrl + STR0076 + Alltrim(cDocTimb) + cCtrl + STR0077, STR0001  ) //"Se solicitará la Cancelación ante el SAT del Documento: " //"El Documento que lo sustituye ya tiene timbrado el CFDI: " //"¿Desea continuar?"
								aRegs[Len(aRegs),dfMotivo] := SF3->F3_MOTIVO
								aRegs[Len(aRegs),12] := UUIDDoc
							EndIf
						EndIf	
						If aRegs[Len(aRegs),dfConfProc] //Si se confirma la cancelación
							Processa( {|| ProcesoWS(IIF(cStaAct=="E","E","S"),.T.) },STR0045, ,) //"Procesando solicitud... Espere"
							If Len(aRegs[Len(aRegs)]) >= 16
								cEstado := F817ActSta(cStaAct,aRegs[Len(aRegs)][16],@cMsg)
								aRegs[Len(aRegs)][6] := IIF(!Empty(cMsg),cMsg,aRegs[Len(aRegs)][6])								
								Aadd(aArchivos,aRegs[Len(aRegs),dfXML])
							EndIf
							If F817ResCan(fNombreXml(SF3->F3_CODNFE))
								//Soliciud de Cancelación ante el SAT exitosa
								If SF3->(RecLock( "SF3" , .F.))
									SF3->F3_STATUS := IIF(cEstado $ "A|R|E",cEstado,"")
									SF3->(MSUnlock())
								EndIf
								If !Empty(cDirLoc) .And. Len(aArchivos)>0 
									F817CopAcu(aArchivos,cDirLoc,.T.)
								EndIf
							EndIf
						EndIf
						ImprimeLog("S") // Impresión del log
					EndIf
				EndIf
			Else
				MsgAlert(STR0031+": "+cSerie+cDoc+" "+STR0070, STR0054)// El documento: ### no fue encontrado
			EndIf
			If !lDocExis
				MsgAlert(StrTran(STR0078,"###",Alltrim(cSerie) + "-" + Alltrim(cDoc)),STR0015) //"ATENCION" "El documento ### no se encuentra pendiente de solicitud de Cancelación ante el SAT."
			EndIf
		else
			MsgAlert(STR0069, STR0054)//Informe la serie y documento para continuar
		EndIf
	EndIf
	aRegs := {}
Return Nil
/*/{Protheus.doc} F800ResCan
//Obtiene atributos de la respuesta de WS de solicutud de cancelación.
@author luis.enriquez
@since 19/02/2022
@version 1.0
@return lCancel, array, .T. si la cancelación fue exitosa y .F. si no fue exitosa.
@param cNameCFDI, characters, Nombre del XML para lectura del archivo .out
@type function
/*/
Function F817ResCan(cNameCFDI)
	Local oXML     := Nil
	Local cError   := ""
	Local cDetalle := ""
	Local cCodigo  := ""
	Local lCancel  := .F.
	Local cFechaXML:= ""
	Local cNomXML  := ""
	Local cRutaAnu	:= &(SuperGetmv( "MV_CFDANUL" , .F. ,cRutaSrv))
	
	cNomXML := cRutaAnu + cNameCFDI + ".sol"
	oXml := XmlParserFile(cNomXML, "", @cError, @cDetalle )

	If XmlChildEx(oXml, "_CLSCANCELA") <> Nil
		// XML generado por el ejecutable de timbrado
		cCodigo := oXml:_CLSCANCELA:_CODESTATUS:Text

		If cCodigo == "0"
			If XmlChildEx(oXml:_CLSCANCELA, "_FOLIOS") <> Nil
				// Nodo de estado del UUID
				If ValType(oXml:_CLSCANCELA:_FOLIOS) == "A"
					cCodigo := oXml:_CLSCANCELA:_FOLIOS[1]:_FOLIO:_ESTATUSUUID:Text
				Else
					If XmlChildEx(oXml:_CLSCANCELA:_FOLIOS:_FOLIO,"_ESTATUSUUID") <> Nil
						cCodigo := oXml:_CLSCANCELA:_FOLIOS:_FOLIO:_ESTATUSUUID:Text
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If cCodigo == "201" .Or. cCodigo == "202"
		lCancel := .T.
	EndIf

	If !lCancel .And. UPPER(cCFDiPAC) == "SOLUCIONFACTIBLE"
		aResp := RespWS("E", cNameCFDI, @cFechaXML, .T.)
		If aResp[1] $ "3|4|5" //Cancelado sin aceptación - Cancelado con aceptación - Plazo vencido
			lCancel := .T.
		EndIf
	EndIf
Return lCancel

/*/{Protheus.doc} F817Cores
//Semáforos con color según el status.
@author ARodriguez
@since 23/10/2018
@version 1.0
${parametersSection}
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Static Function F817Cores(nType)
	Local aCores := {}
	Default nType := 1

	If nType == 1
		aCores := {	{"(F2_FLFTEX==' ' .Or. F2_FLFTEX=='0') .And. F2_ESCANC==' '", 'BR_VERDE' },;	//Vigente
					{"(F2_FLFTEX==' ' .Or. F2_FLFTEX=='0') .And. F2_ESCANC=='1'", 'BR_LARANJA' },;	//Vigente - Cancelable sin aceptación
					{"(F2_FLFTEX==' ' .Or. F2_FLFTEX=='0') .And. F2_ESCANC=='2'", 'BR_PINK' },;		//Vigente - Cancelable con aceptación
					{"F2_FLFTEX=='1'", 'BR_AZUL'},;													//En proceso
					{"F2_FLFTEX=='2'", 'BR_PRETO'},;												//Rechazado
					{"F2_FLFTEX=='3' .Or. F2_FLFTEX=='4' .Or. F2_FLFTEX=='5'", 'BR_AMARELO'},;		//Cancelada -> debería ser BR_VERMELHO pero no procede
					{"F2_FLFTEX=='6'", 'BR_AMARELO'},;												//Documentos relacionados
					{"F2_FLFTEX=='7'",'BR_AZUL_CLARO'},;											//Cancelada fuera de periodo
					{"F2_FLFTEX=='8'",'BR_VERDE_ESCURO'},;											//Cancelada fuera de periodo - Pendiente de acuse
					{"F2_FLFTEX=='9'",'BR_VIOLETA'}}														//Cancelada ante el SAT, pendiente de cancelación en el sistema.
	Else
		aCores := {	{"(F1_FLFTEX==' ' .Or. F1_FLFTEX=='0') .And. F1_ESCANC==' '", 'BR_VERDE' },;	//Vigente
					{"(F1_FLFTEX==' ' .Or. F1_FLFTEX=='0') .And. F1_ESCANC=='1'", 'BR_LARANJA' },;	//Vigente - Cancelable sin aceptación
					{"(F1_FLFTEX==' ' .Or. F1_FLFTEX=='0') .And. F1_ESCANC=='2'", 'BR_PINK' },;		//Vigente - Cancelable con aceptación
					{"F1_FLFTEX=='1'", 'BR_AZUL'},;													//En proceso
					{"F1_FLFTEX=='2'", 'BR_PRETO'},;												//Rechazado
					{"F1_FLFTEX=='3' .Or. F1_FLFTEX=='4' .Or. F1_FLFTEX=='5'", 'BR_AMARELO'},;		//Cancelada -> debería ser BR_VERMELHO pero no procede
					{"F1_FLFTEX=='6'", 'BR_AMARELO'}}												//Documentos relacionados
	EndIf

Return aCores

/*/{Protheus.doc} F817Leyend
//Leyenda: Pantalla con descripción de status.
@author ARodriguez
@since 23/10/2018
@version 1.0
${parametersSection}
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Function F817Leyend()
	BrwLegenda(cCadastro,OemToAnsi(STR0014), {;				//"Cancelación de CFDI" # "Leyenda"
            {"BR_VERDE", OemToAnsi(STR0009)},;				//"Vigente"
            {"BR_LARANJA", OemToAnsi(STR0041)},;			//"Vigente - Cancelable sin aceptación"
            {"BR_PINK", OemToAnsi(STR0042)},;				//"Vigente - Cancelable con aceptación"
            {"BR_AZUL", OemToAnsi(STR0011)},;				//"En proceso de cancelación"
            {"BR_PRETO", OemToAnsi(STR0012)},;				//"Solicitud de cancelación rechazada"
            {"BR_AMARELO", OemToAnsi(STR0013)},;			//"Contiene documentos relacionados"
            {"BR_AZUL_CLARO",OemToAnsi(STR0119)},;			//"Cancelada fuera de periodo"
			{"BR_VERDE_ESCURO",OemToAnsi(STR0119) + " - " + OemToAnsi(STR0120)},;     //"Cancelada fuera de periodo - Pendiente de acuse"
			{"BR_VIOLETA",OemToAnsi(STR0131)};//"Cancelado ante el SAT, pendiente cancelación en sistema"
            })

            // No procede este status porque Protheus no marca cancelación sino que borrar documentos
            //{"BR_VERMELHO", OemToAnsi(STR0010)}			//"Cancelada"

Return Nil

/*/{Protheus.doc} CamposBrw
//Genera array de campos para el Browse.
@author arodriguez
@since 29/10/2018
@version 1.0
@return aColumns, arreglo de campos para MarkBrowse
@param aFields, array, Vector de campos para mostrar en MarkBrowse
@type function
/*/
Static Function CamposBrw( aFields, cAlias )
	Local aArea	:= GetArea()
	Local aColumns := {}
	Local nX := 0
	Default aFields := {}
    Default cAlias := ""

	For	nX:=1 To Len(aFields)
		If (cAlias)->(ColumnPos(aFields[nx]))
			AAdd( aColumns, {aFields[nX],;
			                 ,; 
							TRIM(fwx3Titulo(aFields[nx])),;
							GetSx3Cache(aFields[nx], "X3_PICTURE")} ) // Capital()
		EndIf
	Next nX

	RestArea(aArea)

Return aColumns

/*/{Protheus.doc} F817VMark
//Valida si se puede marcar el registro.
@author ARodriguez
@since 23/10/2018
@version 1.0
${parametersSection}
@return lOK, Lógico, Marcó/desmarcó?
@example
(examples)
@see (links_or_references)
/*/
Function F817VMark( nOpc )
Local lOK      := .T.
Local lValida  := .T.
Local cRutOrig := ""
Local cFilSE4  := xFilial("SE4")
Local lActCanFp	:=  SuperGetmv( "MV_CANFRPE" , .F. , .F. )	//indica si el proceso de cancelación fuera de periodo esta activado 
Private lCanFper:= .F.

If nOpc == 1
	// Marcar todos; no procede
	Return .F.
EndIf

// Valida stataus para seleccion de documento
If nTipo == 1 .Or. nTipo == 2
	
	If lActCanFp .and. nTipo == 1 
		// Si el año de emisión es menor al año de cancelación ó si el mes de emisión es menor al mes de cancelación se considera Fuera de periodo
		lCanFper:= IIf( Year(SF2->F2_EMISSAO) < Year(dDatabase) .OR. Month(SF2->F2_EMISSAO) < Month(dDatabase), .T.,.F. )
	EndIf
	If !SF2->(Empty(F2_FLFTEX) .Or. F2_FLFTEX $ "0|1|2|6|8|9")
		lOK := .F.
	EndIf
	If lOK 
		cRutOrig := ObtOrigen(SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_PREFIXO, SF2->F2_DOC )
		dbSelectArea("SE4")
		SE4->(dbGotop()) 
		SE4->(dbSetOrder(1)) //E4_FILIAL+E4_CODIGO
		SE4->(MsSeek(cFilSE4 + SF2->F2_COND))
		lValida := ( IIf(nTipo == 1 .and. (!lCanFper), FS817VlCnt(SF2->F2_EMISSAO,SF2->F2_DTLANC), .T.) .And.  MaCanDelF2("SF2", SF2->(RecNo()), , , , cRutOrig ) )
	EndIf
Else
	If !SF1->(Empty(F1_FLFTEX) .Or. F1_FLFTEX $ "0|1|2|6")
		lOK := .F.
	EndIf
	If lOK
		cTipo := 'D'
		lValida := LxMaCanDelF1(SF1->(Recno()),,,,,,.F.,"MATA465N")
	EndIf
EndIf

If !lValida
	lOK := .F.
EndIf

If lOK
	// Marca/Desmarca
	If nTipo == 1 .Or. nTipo == 2
		// NF/NDC
		RecLock("SF2",.F.)
		SF2->F2_MARK := IIf(SF2->F2_MARK==cMarca,"  ",cMarca)
		SF2->(MsUnLock())

		If SF2->F2_MARK == cMarca
			//Agrega a array de Recno y Status
			aAdd( aRegs , Array(dfLongitud))
			aRegs[Len(aRegs),dfRecNo] := SF2->(Recno())
			aRegs[Len(aRegs),dfEstatus] := SF2->F2_FLFTEX
			aRegs[Len(aRegs),dfCancelable] := SF2->F2_ESCANC
			aRegs[Len(aRegs),dfDocumento] := SF2->F2_DOC + SF2->F2_SERIE
			aRegs[Len(aRegs),dfCliente] := SF2->F2_CLIENTE +"/"+ SF2->F2_LOJA
			aRegs[Len(aRegs),dfConfProc] := .T.
			aRegs[Len(aRegs),dfUUIDDoc] := ""
			aRegs[Len(aRegs),dfMotivo] := ""
			aRegs[Len(aRegs),dfCanFper] := lCanFper // Cancelable fuera de periodo
			aRegs[len(aRegs),dfMsgCan] := "" //Mensaje Cancelación fuera de Periodo
			aRegs[len(aRegs),dfFraPer] := .F. // doc fuera de periodo
		Else
			If ( nReg := aScan( aRegs , {|x| x[1]==SF2->(Recno())} ) ) > 0
				//Elimina de array de Recno y Status
				aDel( aRegs , nReg )
				aSize( aRegs , Len(aRegs)-1 )
			EndIf
		EndIf

	Else
		// NCC
		RecLock("SF1",.F.)
		SF1->F1_MARK := IIf(SF1->F1_MARK==cMarca,"  ",cMarca)
		SF1->(MsUnLock())

		If SF1->F1_MARK == cMarca
			//Agrega a array de Recno y Status
			aAdd( aRegs , Array(dfLongitud))
			aRegs[Len(aRegs),dfRecNo] := SF1->(Recno())
			aRegs[Len(aRegs),dfEstatus] := SF1->F1_FLFTEX
			aRegs[Len(aRegs),dfCancelable] := SF1->F1_ESCANC
			aRegs[Len(aRegs),dfDocumento] := SF1->F1_DOC + SF1->F1_SERIE
			aRegs[Len(aRegs),dfCliente] := SF1->F1_FORNECE +"/"+ SF1->F1_LOJA
			aRegs[Len(aRegs),dfConfProc] := .T.
			aRegs[Len(aRegs),dfMotivo] := ""
			aRegs[Len(aRegs),dfCanFper] := .F. // Cancelable fuera de periodo
			aRegs[len(aRegs),dfMsgCan] := "" //Mensaje Cancelación fuera de Periodo
			aRegs[len(aRegs),dfFraPer] := .F. // doc fuera de periodo
		Else
			If ( nReg := aScan( aRegs , {|x| x[1]==SF1->(Recno())} ) ) > 0
				//Elimina de array de Recno y Status
				aDel( aRegs , nReg )
				aSize( aRegs , Len(aRegs)-1 )
			EndIf
		EndIf

	EndIf

Else
	If !lValida
		MsgAlert( OemToAnsi(STR0048), OemToAnsi(STR0015))	// "El documento no puede ser seleccionado para anulación." # "ATENCION"
	Else
		MsgAlert( OemToAnsi(STR0016), OemToAnsi(STR0015))	// "Documento ya cancelado." # "ATENCION"
	EndIf
EndIf

Return lOK

/*/{Protheus.doc} F817Visual
//Visualiza documento, utiliza rutinas de LOCXNF.
@author ARodriguez
@since 23/10/2018
@version 1.0
${parametersSection}
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Function F817Visual()
	Private aCfgNF := {}

	If nTipo == 1 .Or. nTipo == 2
	 	aCfgNF := MontaCfgNf( nTipo, {}, .T.)
	 Else
	 	aCfgNF := MontaCfgNf( 4, {}, .T.)
	EndIf

 	LocxDlgNF(aCfgNF,2)

	//bFiltraBrw := {|| FilBrowse(cAliasSF,@aIndexSF,@cFiltro) }
	//bFiltraBrw := {|x| If(x==Nil,FilBrowse(cAliasSF,@aIndexSF,@cFiltro),If(x==1,cFiltro,cQuery)) }

	//If !lTopConn
	//	Eval(bFiltraBrw)
	//EndIf
Return Nil

/*/{Protheus.doc} F817Consul
//Consulta status del proceso de cancelación.
@author ARodriguez
@since 23/10/2018
@version 1.0
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Function F817Consul()
	Local nRegs		:= 0

	If Len(aRegs) > 0
		// Checa status de los registros seleccionados
		aEval(aRegs , {|x,y| IIf(Empty(aRegs[y,dfEstatus]) .Or. aRegs[y,dfEstatus]$"0|1|6|", ++nRegs,) } )

		If Len(aRegs) <> nRegs
			MsgAlert( OemToAnsi(STR0018), OemToAnsi(STR0015))	// "Para consultar estado de proceso seleccione solo documentos En Proceso." # "ATENCION"

		ElseIf MsgYesNo(STR0022,cCadastro)						// "¿Continuar con la consulta de estado de proceso?" # "Cancelación de CFDI"
			// Ejecutar rutina de consulta de estado de proceso
			EjecutaWS("E")

		EndIf

	Else
		MsgAlert( OemToAnsi(STR0020), OemToAnsi(STR0015))		// "Debe seleccionar al menos un documento para consulta de estado de proceso." # "ATENCION"

	EndIf

Return Nil

/*/{Protheus.doc} F817Cancel
//Solicitud de cancelación.
@author ARodriguez
@since 23/10/2018
@version 1.0
@return Nil
@example
(examples)
@see (links_or_references)
/*/
Function F817Cancel()
Local nRegs := 0

If Len(aRegs) > 0
	// Checa status de los registros seleccionados
	aEval(aRegs , {|x,y| IIf(aRegs[y,dfEstatus]$"0|2|8|9" .And. !Empty(aRegs[y,dfCancelable]) .And. aRegs[y,dfCancelable]$"1|2", ++nRegs,) } )

	If UPPER(cCFDiPAC) <> "SOLUCIONFACTIBLE" .and. Len(aRegs) <> nRegs
		MsgAlert( OemToAnsi(STR0017), OemToAnsi(STR0015))	// "Para solicitud de cancelación los documentos deben ser cancelables, realice antes la consulta de estado." # "ATENCION"
	ElseIf MsgYesNo(STR0021,cCadastro)						// "¿Continuar con solicitud de cancelación?" # "Cancelación de CFDI"
		// Ejecutar rutina de solicitud de cancelación
		EjecutaWS("S")
	EndIf

Else
	MsgAlert( OemToAnsi(STR0019), OemToAnsi(STR0015))		// "Debe seleccionar al menos un documento para solicitud de cancelación." # "ATENCION"

EndIf

Return Nil

/*/{Protheus.doc} EjecutaWS
Realiza llamado de función que genera .INI y .Bat para consumo de WS de
solicitud cancelación o consulta status; e imprime el log.

@author arodriguez
@since 27/10/2018
@version 1.0
@Param cOpcion, string, E=Consulta estado, S=Solicitud cancelación
@return Nil

@type function
/*/
Static Function EjecutaWS(cOpcion)

	Processa( {|| ProcesoWS(cOpcion) },STR0045,,)// "Procesando solicitud... Espere"

	// Imprime log del proceso
	ImprimeLog(cOpcion)

	// Reset del array
	aSize(aRegs, 0)

Return Nil

/*/{Protheus.doc} ProcesoWS
Genera .INI y .Bat para consumo de WS de solicitud cancelación o consulta status.

@type function
@author arodriguez
@since 27/10/2018
@version 1.0
@Param cOpcion, string,  E=Consulta estado, S=Solicitud cancelación
@Param lCanAut, boolean,  Indica su es proceso de Cancelación automática (valor .T. es SI y .F. es NO)
@return Nil
/*/
Function ProcesoWS(cOpcion, lCanAut)
	Local cRutaCFDI		:= cRutaSmr + "Recibos\"
	Local cRutaExeWeb   := GetSrvProfString('RootPath', '') + cRutaSmr 
	Local cIniFile		:= "timbradocfdi.ini"
	Local cBatch		:= "CancelaCFDI.bat"
	Local cNameCFDI		:= ""
	Local cParametros	:= ""
	Local cResultado	:= ""
	Local cMensaje		:= ""
	Local nHandle		:= 0
	Local nOpc			:= 0
	Local nX			:= 0
	Local lHTML         := GetRemoteType()==5
	Local lTimbWeb      := .T.
	Local aMotCancel	:= {}
	Local lCanc40		:= .F.
	Local cCFDIni		:= ""
	Local nDocCan		:= 0
	Local cEstatus		:= ""
	Local cRutaAnu		:= &(SuperGetmv( "MV_CFDANUL" , .F. ,cRutaSrv))
	Local lActCanFp 	:=  SuperGetmv( "MV_CANFRPE" , .F. , .F. )	//indica si el proceso de cancelación fuera de periodo esta activado 
	Local lDocSus		:= .F.
	Default lCanAut     := .F.

	// Si existe ya el archivo con la lista de documentos a enviar, se borra.
	If File( cRutaSmr + cIniFile )
		FErase(cRutaSmr + cIniFile)
	Endif
	
	// Se crea archivo para lista de documentos a enviar al WS
	nHandle	:= FCreate( cRutaSmr + cIniFile )

	If nHandle == -1
		MsgAlert( OemToAnsi(STR0026) + cRutaSmr, OemToAnsi(STR0015))		// "No es posible crear archivo temporal en la ruta " # "ATENCION"
		Return .F.
	EndIf

	//Validación si existen los campos requeridos para Cancelación CFDI version 4.0
	If nTipo == 1 .Or. nTipo == 2 //Factura o Nota de Débito
		lCanc40 := (cOpcion == "S" .And. SF2->(ColumnPos("F2_TIPNOTA")) > 0 .And. SF2->(ColumnPos("F2_CODDOC")) > 0)
	Else //Nota de Crédito
		lCanc40 := (cOpcion == "S" .And. SF1->(ColumnPos("F1_TIPNOTA")) > 0 .And. SF1->(ColumnPos("F1_CODDOC")) > 0)
	EndIf

	FWrite( nHandle, "[RECIBOS]" + CRLF )

	// Asegura existencia de carpeta local de xml
	MakeDir( cRutaCFDI )
	ProcRegua(Len(aRegs))
	For nX := 1 to Len(aRegs)
		// Nombre del xml
		If nTipo == 1 .Or. nTipo == 2
			// NF  - Nota fiscal clientes
			// NDC - Nota de debito clientes
			lDocSus:= .F.
			If !lCanAut
				SF2->(dbGoto(aRegs[nX,dfRecNo]))
				cNameCFDI := &(cCFDiSF2)
				If lCanc40
					IF lActCanFp .and. (lxMxDcMt01(nX) .OR. SF2->F2_FLFTEX == "9") // Mot = 01, Docto Fuera Per = .T. y estus 2 rechazada, 6 no cancelable y 8 pendiente acuse. 9 Cancelado en SAt pendiente cancelar en sistema
						If lxMxDocPen(nX, SF2->F2_DOC, SF2->F2_SERIE,SF2->F2_FLFTEX) // verifica si existe documento sustituto y obtiene el uuid 
							lDocSus := .T.
						Else
							Loop
						EndIf
					Else
						aRegs[nX, dfConfProc] := F817MCanc("SF2", "F2", @aMotCancel,cNameCFDI)
						If lActCanFp .and. aRegs[nX, dfConfProc] .AND. nTipo == 1 
							If !lxMxDcFrPr(nX) //Cancelación fuera de Periodo
								Loop
							EndIf
						EndIf
					EndIf
				EndIf
				
			EndIf
		Else
			// NCC - Nota de credito clientes
			If !lCanAut
				SF1->(dbGoto(aRegs[nX,dfRecNo]))
				cNameCFDI := &(cCFDiSF1)
				If lCanc40
					aRegs[nX, dfConfProc] := F817MCanc("SF1", "F1", @aMotCancel,cNameCFDI)
				EndIf
			EndIf
		EndIf
		If lCanAut
			cNameCFDI := aRegs[nX, dfXML]
		EndIf

		If !aRegs[nX, dfConfProc]
			Loop
		EndIf

		aRegs[nX, dfXML] := cNameCFDI
		
		If !lCanAut .And. Iif(!Empty(aMotCancel), Alltrim(aMotCancel[1]) == "01",.F.)
			aRegs[nX,dfMotivo] := Alltrim(aMotCancel[1])
			aRegs[nX,dfActualiza ] := .T.
			IF aRegs[nX,dfCanFper] == .T.
				aRegs[nX,dfMensaje]    := STR0132 //"Pendiente de generación de documento sustituto, no se realizó solicitud de cancelación ante el SAT"
			Else
				aRegs[nX,dfMensaje]    := STR0065 //Documento anulado en el sistema pero no se realizó solicitud de cancelación ante el SAT
			EndIf
			IncProc(STR0071+" "+aRegs[nX,dfDocumento]) //"Anulando el documento en el sistema"
			Loop
		else
			IncProc(IIf(cOpcion=="E", STR0043,STR0044)+" "+Iif(!Empty(aRegs[nX,dfDocumento]),aRegs[nX,dfDocumento],"")) //  "Consulta de estado de CFDI" - "Solicitud de cancelación de CFDI"
			
			//Proceso pruebas / pilotos//
			// If cOpcion=="E" .and. nTipo == 1 .and. Year(SF2->F2_EMISSAO) < Year(dDatabase) .OR. Month(SF2->F2_EMISSAO) < Month(dDatabase)
			// 	if (aRegs[nX,dfEstatus] == " " .OR. aRegs[nX,dfEstatus] == "0" )  .and. aRegs[nX,dfCancelable] == " "
			// 		aRegs[nX,dfActualiza ] := .T.
			// 		aRegs[nX,dfMensaje]    := "PLT -> Proceso realizado con éxito"
			// 		Loop
			// 	Endif
			// EndIf
			
		Endif

		//Validar si el archivo xml existe
		If !File(cRutaSrv + cNameCFDI)
			aRegs[nX,5] := STR0027	//"No existe el archivo del CFDI "
			Loop
		Endif

		If File( cRutaCFDI + cNameCFDI )
			FErase( cRutaCFDI + cNameCFDI )
		Endif

		If File( cRutaCFDI + cNameCFDI + ".out" )
			FErase( cRutaCFDI + cNameCFDI + ".out" )
		Endif

		if lHTML
			COPY FILE (cRutaSrv+cNameCFDI) TO (cRutaCFDI+cNameCFDI)
		Else
			// Copiar archivos .xml del servidor a la ruta del smartclient o la establecida (StartPath...\CFD\RECIBOS\xxx...xxx.XML a x:\totvs\protheusroot\bin\smartclient)
			CpyS2T( cRutaSrv + cNameCFDI , cRutaCFDI )
		Endif

			// Agrega a la lista
		If lCanAut .or. (!empty(aRegs[nX,dfUUIDDoc]) .and. lDocSus)
			cCFDIni := cNameCFDI + IIf(lCanc40, " " + Alltrim(aRegs[nX,11])+ " " +Alltrim(aRegs[nX,12]) , "")
		Else
			cCFDIni := cNameCFDI + IIf(lCanc40, " " + Alltrim(aMotCancel[1]), "")
		EndIf
		FWrite( nHandle, cCFDIni + CRLF )
		nDocCan++		
	Next nX

	fClose( nHandle )

	If nDocCan > 0 //Valida si existe al menos un documento a cancelar
		// parametros: Usuario, Password, Factura.xml, Ambiente,
		cParametros += cCFDUser + " " + cCFDPass + " " + cIniFile + " " +cCFDiAmb +  " "
		//             Archivo.cer, Archivo.key, ClaveAutenticacion, nil, Solicitud/Estado proceso
		cParametros += cCFDiCer + " " + cCFDiKey + " " + cCFDiCve + " . " + cOpcion + " "
		//			   Proxy, log
		cParametros += cProxy + " " + cLogWS

		If nCFDiCmd == 3 .Or. nCFDiCmd == 10
			nHandle	:= FCreate( cRutaSmr + cBatch )

			If nHandle <> -1
				FWrite( nHandle, cRutaSmr + cRutina + Trim(cParametros) + CRLF )
				FWrite( nHandle, "Pause" + CRLF )
				fClose( nHandle )
				nOpc := WAITRUN( cRutaSmr + cBatch, nCFDiCmd )

			Else
				// Ejecuta cliente de servicio web
				nOpc := WAITRUN( cRutaSmr + cRutina + Trim(cParametros), nCFDiCmd )
			Endif

		Else
			If lHTML
				lTimbWeb := WaitRunSrv( cRutaExeWeb + cRutina + Trim(cParametros), .T., cRutaExeWeb )
				If !lTimbWeb
					nOpc := 1
				EndIf
			Else
				// Ejecuta cliente de servicio web
				nOpc := WAITRUN( cRutaSmr + cRutina + Trim(cParametros), nCFDiCmd )
			Endif
		Endif
		If  UPPER(cCFDiPAC) == "SOLUCIONFACTIBLE"
			cOpcion := "E"
		EndIf
		// Procesa respuestas
		For nX := 1 to Len( aRegs )
			//pruebas / pilotos//
			// If aRegs[nX,dfMensaje]<> nil 
			// 	If "PLT" $ aRegs[nX,dfMensaje]
			// 		Loop
			// 	EndIf
			// EndIf 
			If !aRegs[nX, dfConfProc]
				aRegs[nX, dfActualiza] := .F.
				Loop
			EndIf
			cNameCFDI := aRegs[nX, dfXML]
			cNameResp := cNameCFDI + IIf(cOpcion=="S",".sol",".con")
			cResultado := ""
			cMensaje := ""

			If nOpc == 0 .And. File( cRutaCFDI + cNameCFDI + ".out" )
				//Copiar respuesta del WS al servidor
				__CopyFile( cRutaCFDI + cNameCFDI + ".out" , cRutaAnu + cNameResp )
				__CopyFile( cRutaCFDI + cNameCFDI  , cRutaAnu + cNameCFDI) //copia el XML anulado a carpeta anuladas

				// Revisa contenido de respuesta
				aRegs[nX, dfActualiza] := ChecaResp(cRutaAnu + cNameResp, cRutaCFDI + cNameCFDI + ".out", @cResultado, @cMensaje, cOpcion, @cEstatus)
				IIf( Empty(cMensaje) , cMensaje := STR0029 , )		//"No se pudo procesar la solicitud/consulta de estado"
				aAdd( aRegs[nX] ,IIf(!Empty(cEstatus) , UPPER(cEstatus) ,"" ))

			Else
				aRegs[nX, dfActualiza] := Iif(!lCanAut .And. aRegs[nx,dfMotivo] == "01",.T.,.F.)
				cMensaje := Iif(!lCanAut .And. aRegs[nx,dfMotivo] == "01",STR0065,STR0028)	//"Documento anulado en el sistema pero no se realizó solicitud de cancelación ante el SAT"-"No se encuentra archivo de respuesta del WS"
			Endif

			aRegs[nX, dfResultado] := cResultado
			aRegs[nX, dfMensaje] := cMensaje

			// Eliminar temporales
			Ferase( cRutaCFDI + cNameCFDI )
			Ferase( cRutaCFDI + cNameCFDI + ".out" )
		Next nX

	EndIf
	// Actualiza status documentos y efecta cancelaciones
	If !lCanAut
		ActualizaDoc(cOpcion)
	EndIf

Return Nil

/*/{Protheus.doc} ChecaResp
//Checa la respuesta del WS segúun la solucitud.
@author arodriguez
@since 30/10/2018
@version 1.0
@return lógico, (.T.)Correcto o (.F.)Con error
@param cFile, characters, archivo xml de respuesta
@param cResultado, characters, retorna el resultado del ws
@param cOpcion, characters,  (E)-Consulta estado, (S)-Solicitud cancelación
@type function
/*/
Static Function ChecaResp( cFileSrv, cFileRmt , cResultado , cMensaje , cOpcion, cEstatus )
Local oXml		:= Nil
Local cXML		:= ""
Local cCodigo	:= ""
Local cError	:= ""
Local cDetalle	:= ""
Local nHandle 	:= 0
Local aInfoFile	:= {}
Local nSize		:= 0
Local nRegs		:= 0
Local nFor		:= 0
Local cBuffer	:= ""
Local cLine		:= ""
Local lRet      := .F.

Default cEstatus:= ""
oXml := XmlParserFile(cFileSrv, "", @cError, @cDetalle )

If Valtype(oXml) == "O"				//Es un objeto
	SAVE oXml XMLSTRING cXML

	If cOpcion == "E"
		// Consulta de estado - valida xml de respuesta
		If XmlChildEx(oXml:_CLSESTADO, "_CODIGOESTATUS") <> Nil
			cCodigo := oXml:_CLSESTADO:_CODIGOESTATUS:Text
			cDetalle := oXml:_CLSESTADO:_ESTADO:Text
		EndIf

		If Substr(cCodigo,1,2) == "S "
			// Solicitud recibida correctamente
			lRet := .T.
			If Len(cCodigo) <= 2 .And. XmlChildEx(oXml:_CLSESTADO, "_ESCANCELABLE") <> Nil
				cCodigo += "- " + oXml:_CLSESTADO:_ESCANCELABLE:Text
			EndIf
			cMensaje := cCodigo
			cEstatus := IIf(XmlChildEx(oXml:_CLSESTADO, "_ESTADO") <> Nil,oXml:_CLSESTADO:_ESTADO:Text,"")
		Else
			// Error en recepción
			cMensaje := cCodigo + IIf( Substr(cCodigo,1,2)=="N ", "", " " + cDetalle )
		EndIf

	Else
		// Solicitud de cancelación - valida xml de respuesta
		If XmlChildEx(oXml, "_CLSCANCELA") <> Nil
			cCodigo := oXml:_CLSCANCELA:_CODESTATUS:Text
			If XmlChildEx(oXml:_CLSCANCELA, "_MENSAJE") <> Nil
				cDetalle := oXml:_CLSCANCELA:_MENSAJE:Text
			ElseIf XmlChildEx(oXml:_CLSCANCELA, "_FOLIOS") <> Nil
				// Nodo de estado del UUID
				If ValType(oXml:_CLSCANCELA:_FOLIOS) == "A"
					cDetalle := oXml:_CLSCANCELA:_FOLIOS[1]:_FOLIO:_MENSAJE:Text
				Else
					cDetalle := oXml:_CLSCANCELA:_FOLIOS:_FOLIO:_MENSAJE:Text
				EndIf
			EndIf
		EndIf

		If cCodigo == "0" .Or. "201" $ cCodigo .Or. "202" $ cCodigo
			// Solicitud recibida correctamente
			lRet := .T.
			If Empty(cDetalle)
				cDetalle := IIf(cCodigo == "201", STR0046, IIf(cCodigo == "202", STR0047, "")) //"El folio se ha cancelado con éxito, documento anulado." //"El CFDI ya había sido cancelado previamente, y será anulado el documento."
			EndIf
			cMensaje := cCodigo + Trim(" " + cDetalle)
		Else
			// Error en recepción
			cMensaje := cCodigo + " " + AllTrim(cDetalle)
		EndIf

	EndIf

	If !lRet .And. Empty(cCodigo)
		// El archivo no contiene formato esperado ==> Error
		If AT( "<ERROR" , Upper(cXML) ) > 0
			If 	ValType(oXml:_ERROR) == "O"
				cError := oXml:_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_ERROR:_DESCRIPCIONERROR:TEXT
			EndIf

		ElseIf AT( "<CODERROR" , Upper(cXML) ) > 0
			If 	ValType(oXml:_CODERROR) == "O"
				cError := oXml:_CODERROR:_CODIGO:TEXT
				cDetalle := ""
			EndIf

		ElseIf AT( "CFDI:ERROR" , Upper(cXML) ) > 0
			If 	ValType(oXml:_CFDI_ERROR) == "O"
				cError := oXml:_CFDI_ERROR:_CODIGO:TEXT
				cDetalle := oXml:_CFDI_ERROR:_CFDI_DESCRIPCIONERROR:TEXT
			EndIf

	    EndIf

		cMensaje := Trim(cError) + " " + cDetalle
		IIf(Empty(cMensaje), cMensaje := STR0029, )		//"No se pudo procesar la consulta de estado/solicitud de cancelación."
	EndIf

	cResultado := cXML

Else
	// El archivo no tiene formato de XML
	Begin Sequence
	   	nHandle := fOpen(cFileRmt)

		If nHandle <= 0
			cResultado := STR0028  //"No se encuentra archivo de respuesta del WS"
			Break
		EndIf

		aInfoFile := Directory(cFileRmt)
		nSize := aInfoFile[ 1 , 2 ]
		nRegs := Int(nSize/2048)

		For nFor := 1 to nRegs
			fRead( nHandle , @cBuffer , 2048 )
			cLine += cBuffer
		Next

		If nSize > nRegs * 2048
			fRead( nHandle , @cBuffer , (nSize - nRegs * 2048) )
			cLine += cBuffer
		EndIf

		fClose(nHandle)
	End Sequence

	If Substr(cLine,1,1) == "("
		cLine := Substr(cLine,2)
		cLine := Strtran( cLine , ")" , " " , 1 , 1 )
	EndIf

	cBuffer := Upper(cLine)

	If cOpcion == "E"
		// Consulta de estado - Busca nodo/atributo previsto
		If "CLSESTADO" $ cBuffer .And. "CODIGOESTATUS" $ cBuffer
			nFor := At("CODIGOESTATUS", cBuffer) + 14
			cCodigo := Substr(cBuffer, nFor, At("</CODIGOESTATUS", cBuffer) - nFor)
		EndIf

		If Substr(cCodigo,1,2) == "S "
			// Solicitud recibida correctamente
			lRet := .T.
		EndIf

		cMensaje := cCodigo

	Else
		// Solicitud de cancelación - Busca nodo/atributo previsto
		If "CLSCANCELA" $ cBuffer .And. "CODESTATUS" $ cBuffer
			nFor := At("CODESTATUS", cBuffer) + 11
			cCodigo := Substr(cBuffer, nFor, At("</CODESTATUS", cBuffer) - nFor)
		EndIf

		If cCodigo == "0" .Or. "201" $ cCodigo .Or. "202" $ cCodigo
			// Solicitud recibida correctamente, Vigente (Es espera) o ya está cancelado
			lRet := .T.
		EndIf

		cMensaje := cCodigo

	EndIf

	If !lRet .And. Empty(cCodigo)
		// El archivo no contiene formato esperado ==> Error
		nFor := At("<ERROR" , cBuffer)
		If nFor == 0
			nFor := At("<CODERROR", cBuffer)
		EndIf
		If nFor == 0
			nFor := At("CFDI:ERROR" , cBuffer)
			IIf(nFor > 1, --nFor, )
		EndIf
		If nFor > 0
			cError := Substr(cBuffer, nFor)
			nFor := At(">" , cError)
			If nFor > 0
				cError := Substr(cError, 1, nFor)
			EndIf
			cMensaje := cError
		EndIf

		IIf(Empty(cMensaje), cMensaje := STR0029, ) //"No se pudo procesar la consulta de estado/solicitud de cancelación."
	EndIf

	cResultado := Alltrim(cLine)

Endif

Return 	lRet

/*/{Protheus.doc} ActualizaDoc
	Realiza la actualización de estatus para los documentos,
	cuando se realiza la Consulta de Estado y Solicitud de
	Cancelación.

	@type  Static Function
	@author arodriguez
	@since 30/10/2018
	@version 1.0
	@param cOpcion, Carácter, E=Consulta estado, S=Solicitud cancelación
	@example
	ActualizaDoc(cOpcion)
/*/
Static Function ActualizaDoc(cOpcion)
	Local dFecha		:= Date()
	Local cHora			:= GetRmtTime()
	Local cFechaXML		:= ""
	Local aCabs			:= {}
	Local aItens		:= {}
	Local aAreas		:= {SF1->(GetArea("SF1")), SF2->(GetArea("SF2")), SD1->(GetArea("SD1")),  SD2->(GetArea("SD2")), GetArea()}
	Local cFilSD1		:= xFilial("SD1")
	Local cFilSD2		:= xFilial("SD2")
	Local nX			:= 0
	Local nY			:= 0
	Local aResp         := {}
	Local cRutaloc 		:= SuperGetmv( "MV_CFDCARF" , .F. ,"")
	Local aArchivos		:= {}
	Local lNoCanSis		:= .F.
	//Variables para uso de Telemetria
	Local cIdMetrica	:= "faturamento-protheus_cantidad-de-documentos-cancelados-por-empresa_total" //Identificador de Métrica
	Local cSubRutina	:= ""
	Local cTxtSubrut	:= "CFDI_Cancelado_" //Texto complementario para la Subrutina
	Local cTxtAuto		:= IIf(isBlind(), "_auto", "") //Se identifica si es ejecución de automatizados

	For nX := 1 to Len(aRegs)
		Begin Sequence

			If !aRegs[nX, dfActualiza]
				Break
			EndIf
			lNoCanSis := .F.
			cFechaXML := ""
			If aRegs[nX,dfMotivo] == "01"
				If aRegs[nX,dfCanFper] //cancelable fuera de periodo
					aResp := {}
					Aadd(aResp, "99")
					Aadd(aResp, "")
				Else
					Aadd(aResp, "201")
					Aadd(aResp, "")
				EndIf
			// ElseIf "PLT" $ aRegs[nX,dfMensaje] /// pruebas / pilotos//
			// 		Aadd(aResp, "0")
			// 		Aadd(aResp, "1")
			Else   
				aResp := RespWS(cOpcion, aRegs[nX,dfXML], @cFechaXML, aRegs[nX,dfCancelable])
			Endif

			If Empty(aResp[1])
				aRegs[nX, dfActualiza] := .F.
				Break
			EndIf

			If nTipo == 1 .Or. nTipo == 2
				// NF  - Nota fiscal clientes
				// NDC - Nota de debito clientes
				SF2->(dbGoto(aRegs[nX,dfRecNo]))

				If aResp[1] == "201" .Or. aResp[1] == "202"
					// Cancelado / Previamente cancelado
					If SF2->F2_FLFTEX $ "3|4|5"
						aResp[1] := SF2->F2_FLFTEX
					Else
						aResp[1] := IIf(SF2->F2_ESCANC=="1", "3", IIf(SF2->F2_ESCANC=="2", "4", "5"))
					Endif

					aResp[2] := SF2->F2_ESCANC
				EndIf

				If SF2->F2_FLFTEX == aResp[1] .And. SF2->F2_ESCANC == aResp[2]
					aRegs[nX, dfMensaje] += " " + STR0040	//"Sin cambio de estado."
					aRegs[nX, dfActualiza] := .F.
					Break
				EndIf

				If aResp[1] $ "3|4|5" .and. !aRegs[nX,dfCanFper]
					// Procesa cancelación del documento NF/NDC
					aSize(aCabs, 0)
					aSize(aItens, 0)
					For nY := 1 to Len(aCabsSF2)
						aAdd(aCabs, {aCabsSF2[nY], &("SF2->"+aCabsSF2[nY]), Nil})
					Next nY

					SD2->(dbSetOrder(3))
					SD2->(dbSeek(cFilSD2+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					Do While !SD2->(Eof()) .And. cFilSD2+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
						aAdd(aItens, {})
						For nY := 1 to Len(aItensSD2)
							aAdd(aItens[Len(aItens)], {aItensSD2[nY],&("SD2->"+aItensSD2[nY]), Nil})
						Next nY
						SD2->(dbSkip())
					 Enddo

					// Baja por rutina automática
					BeginTran()
					lMSErroAuto := .F.
					MaFisEnd()

					If nTipo == 1
						MATA467N(aCabs,aItens,6) // MSExecAuto({|x,y,z| MATA467N(x,y,z)},aCabs,aItens,6)
					Else
						MATA465N(aCabs,aItens,6) // MSExecAuto({|x,y,z| MATA465N(x,y,z)},aCabs,aItens,6)
					Endif

					If lMSErroAuto
						DisarmTransaction()	 //MostraErro()
						aRegs[nX,dfMensaje] += " " + STR0030	//"El CFDI se canceló pero ocurrió error al procesar baja en Protheus."
					Else
						EndTran()
						If LibMetric()	//Valida la fecha de la LIB para utilizacion en Telemetria
							cSubRutina := cTxtSubrut + IIf(nTipo == 1, "NF", "NDC") + cTxtAuto
							FwCustomMetrics():setSumMetric(cSubRutina, cIdMetrica, 1, /*dDateSend*/, /*nLapTime*/, "FISA817")
						EndIf
					EndIf

					MsUnlockAll()
				EndIf
				If aRegs[nX,dfCanFper] .and. aRegs[nX,dfMotivo] == "01" //Cancelable fuera de periodo // Motivo Cancelación 01- Comprobante emitido con errores con relación 
					//actualiza campos SF3 (Libros Fiscales)
					LxActSF3(SF2->F2_TIPNOTA,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CODDOC,SF2->F2_UUID,SF2->F2_FLFTEX,SF2->F2_ESCANC)
					aResp[1] :=  "8"
					aResp[2] := SF2->F2_ESCANC
				Endif

				// Actualiza campos relacionados con el proceso de cancelación
				If SF2->F2_TIPNOTA == "01" .AND. aRegs[nX,dfCanFper] 
					lxMxActEst(aResp[1]) //actualiza SF3
				Endif
				
				If aRegs[nX,dfCanFper] .and.  aResp[1] $ "3|4|5" //Docto fuera de periodo Cancelado ante el SAT
					If !lxMxValDFP(nX, IIF(cOpcion == "E", .T.,.F.)) 
						// Si hay errores en la generación de la NCC y Recibo se debe actualizar el estatus = 9
						// para poder generar nuevamente los documentos NCA y Recibo desde el botón Cancelar.
						lNoCanSis := .T.
					Endif
				EndIf
				
				RecLock("SF2", .F.)
				SF2->F2_FLFTEX	:= aResp[1]
				SF2->F2_ESCANC	:= aResp[2]

				If aResp[1] $ "3|4|5"
					// Documento cancelado - Fecha actual o del Acuse
					IIf(aRegs[nX,dfMotivo] != "01",Aadd(aArchivos,aRegs[nX,dfXML]),"")
					If aRegs[nX,dfCanFper] 
						If lNoCanSis
							SF2->F2_FLFTEX := "9" /// Cancelado ante el SAT, pendiente de cancelación en el sistema. 
						Else
							SF2->F2_FLFTEX := "7" // cancelable fuera de periodo 
						EndIf
					EndIf
					If Empty(cFechaXML)
						SF2->F2_FECCANC	:= dFecha
						SF2->F2_HORACAN	:= cHora
					Else
						SF2->F2_FECCANC	:= StoD( Strtran( Substr(cFechaXML,1,10), "-") )
						SF2->F2_HORACAN	:= Substr(cFechaXML,12,8)
					EndIf
					SF2->F2_FECANTF := SF2->F2_FECCANC
				Else
					// Solo actualizó estado
					SF2->F2_FECCANC	:= dFecha
					SF2->F2_HORACAN	:= cHora
				EndIf

				SF2->F2_MARK	:= "  "
				SF2->(MsUnlock())

			Else
				// NCC - Nota de credito clientes
				SF1->(dbGoto(aRegs[nX,dfRecNo]))

				If aResp[1] == "201" .Or. aResp[1] ==  "202"
					// Cancelado / Previamente cancelado
					If SF1->F1_FLFTEX $ "3|4|5"
						aResp[1] := SF1->F1_FLFTEX
					Else
						aResp[1] := IIf(SF1->F1_ESCANC=="1", "3", IIf(SF1->F1_ESCANC=="2", "4", "5"))
					Endif

					aResp[2] := SF1->F1_ESCANC
				EndIf

				If SF1->F1_FLFTEX == aResp[1] .And. SF1->F1_ESCANC == aResp[2]
					aRegs[nX, dfMensaje] += " " + STR0040	//"Sin cambio de estado."
					aRegs[nX, dfActualiza] := .F.
					Break
				EndIf

				If aResp[1] $ "3|4|5"
					// Procesa cancelación del documento NCC
					aSize(aCabs, 0)
					aSize(aItens, 0)
					For nY := 1 to Len(aCabsSF1)
						aAdd(aCabs, {aCabsSF1[nY], &("SF1->"+aCabsSF1[nY]), Nil})
					Next nY

					SD1->(dbSetOrder(3))
					SD1->(dbSeek(cFilSD1+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
					Do While !SD1->(Eof()) .And. cFilSD1+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA==SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
						aAdd(aItens, {})
						For nY := 1 to Len(aItensSD1)
							aAdd(aItens[Len(aItens)], {aItensSD1[nY],&("SD1->"+aItensSD1[nY]), Nil})
						Next nY
						SD1->(dbSkip())
					 Enddo

					// Baja por rutina automática
					BeginTran()
					lMSErroAuto := .F.
					MaFisEnd()
					MATA465N(aCabs,aItens,6) // MSExecAuto({|x,y,z| MATA465N(x,y,z)},aCabs,aItens,6)

					If lMSErroAuto
						DisarmTransaction()	//MostraErro()
						aRegs[nX,dfMensaje] += " " + STR0030	//"El CFDI se canceló pero ocurrió error al procesar baja en Protheus."
					Else
						EndTran()
						If LibMetric()	//Valida la fecha de la LIB para utilizacion en Telemetria
							cSubRutina := cTxtSubrut + "NCC" + cTxtAuto
							FwCustomMetrics():setSumMetric(cSubRutina, cIdMetrica, 1, /*dDateSend*/, /*nLapTime*/, "FISA817")
						EndIf
					EndIf

					MsUnlockAll()
				EndIf

				// Actualiza campos relacionados con el proceso de cancelación
				RecLock("SF1", .F.)
				SF1->F1_FLFTEX	:= aResp[1]
				SF1->F1_ESCANC	:= aResp[2]

				If aResp[1] $ "3|4|5"
					// Documento cancelado - Fecha actual o del Acuse
					IIf(aRegs[nX,dfMotivo] != "01",Aadd(aArchivos,aRegs[nX,dfXML]),"")
					If Empty(cFechaXML)
						SF1->F1_FECCANC	:= dFecha
						SF1->F1_HORACAN	:= cHora
					Else
						SF1->F1_FECCANC	:= StoD( Strtran( Substr(cFechaXML,1,10), "-") )
						SF1->F1_HORACAN	:= Substr(cFechaXML,12,8)
					EndIf
					SF1->F1_FECANTF := SF1->F1_FECCANC
				Else
					// Solo actualizó estado
					SF1->F1_FECCANC	:= dFecha
					SF1->F1_HORACAN	:= cHora
				EndIf

				SF1->F1_MARK	:= "  "
				SF1->(MsUnlock())

			EndIf


		End Sequence

		If !aRegs[nX, dfActualiza]
			// Desmarca
			If nTipo == 1 .Or. nTipo == 2
				SF2->(dbGoto(aRegs[nX,dfRecNo]))
				RecLock("SF2", .F.)
				SF2->F2_MARK	:= "  "
				SF2->(MsUnlock())
			Else
				SF1->(dbGoto(aRegs[nX,dfRecNo]))
				RecLock("SF1", .F.)
				SF1->F1_MARK	:= "  "
				SF1->(MsUnlock())
			EndIf
		EndIf

	Next nX

	If !Empty(cRutaloc) .And. Len(aArchivos)>0
		F817CopAcu(aArchivos,cRutaloc,.T.)
	EndIF
	// Restaura areas... "el último será el primero"
	aEval( aAreas, {|x,y| RestArea(aAreas[y])})

Return Nil

/*/{Protheus.doc} RespWS
//Obtiene atributos de la respuesta de WS de consulta estado / solicutud de cancelación.
@author arodriguez
@since 30/10/2018
@version 1.0
@return aResp, array con Estado, EsCancelable, EstadoCancelacion
@param cOpcion, characters, (E)-Consulta estado, (S)-Solicitud cancelación
@param aResp, array, Respuesta del WS (xml)
@type function
/*/
Function RespWS(cOpcion, cNameCFDI, cFechaXML, cEsCancel)
Local oXML		:= nil
Local cError	:= ""
Local cDetalle	:= ""
Local cCodigo	:= ""
Local cEstado	:= ""
local cStatus	:= ""
Local cCancel	:= ""
Local aResp		:= {"", ""}
Local cRutaAnu	:= &(SuperGetmv( "MV_CFDANUL" , .F. ,cRutaSrv))

//oXML := XmlParser(cResp, "_", "", "")
cNameCFDI := cRutaAnu + cNameCFDI + IIf(cOpcion=="S",".sol",".con")
oXml := XmlParserFile(cNameCFDI, "", @cError, @cDetalle )

If cOpcion == "E"
	// Consulta de estado
	If XmlChildEx(oXml:_CLSESTADO, "_CODIGOESTATUS") <> Nil
		// XML generado por el ejecutable de timbrado
		cCodigo := oXml:_CLSESTADO:_CODIGOESTATUS:Text
		cEstado := oXML:_CLSESTADO:_ESTADO:Text
		cStatus := oXML:_CLSESTADO:_ESTATUSCANCELACION:Text
		cCancel := oXML:_CLSESTADO:_ESCANCELABLE:Text
	Endif

	// Estado y EstatusCancelacion
	If Substr(cCodigo,1,2) == "S "
		//"S - Comprobante obtenido satisfactoriamente."
		If !("CANCELADO" $ Upper(cEstado))
			If "RECHAZADA" $ Upper(cStatus) .Or. "RECHAZADA" $ Upper(cEstado)
				//"Solicitud rechazada"
				aResp[1] := "2"
			ElseIf "PROCESO" $ Upper(cStatus) .Or. "PROCESO" $ Upper(cEstado)
				//"En proceso"
				aResp[1] := "1"
			ElseIf "NO CANCELABLE" $ Upper(cEstado)
				//"No cancelable" ==> Documentos relacionados
				aResp[1] := "6"
				aResp[2] := "3"	
			Else
				//"Vigente"
				aResp[1] := "0"
			EndIf

		Else
			//"Cancelado"
			If "CANCELADO SIN" $ Upper(cStatus)
				//"Cancelado sin aceptación"
				aResp[1] := "3"
			ElseIf "CANCELADO CON" $ Upper(cStatus)
				//"Cancelado con aceptación"
				aResp[1] := "4"
			ElseIf "PLAZO" $ Upper(cStatus)
				//"Plazo vencido"
				aResp[1] := "5"
			EndIf

		EndIf
	Endif

	// EsCancelable
	If "CANCELABLE SIN " $ Upper(cCancel)
		//"Cancelable sin aceptación"
		aResp[2] := "1"
	ElseIf "CANCELABLE CON " $ Upper(cCancel)
		//"Cancelable con aceptación"
		aResp[2] := "2"
	ElseIf "NO CANCELABLE" $ Upper(cCancel)
		//"No cancelable" ==> Documentos relacionados
		aResp[1] := "6"
		aResp[2] := "3"
	Endif

Else
	If XmlChildEx(oXml, "_CLSCANCELA") <> Nil
		// XML generado por el ejecutable de timbrado
		cCodigo := oXml:_CLSCANCELA:_CODESTATUS:Text

		If cCodigo == "0"
			//"En proceso"
			aResp[1] := "1"

			If XmlChildEx(oXml:_CLSCANCELA, "_FOLIOS") <> Nil
				// Nodo de estado del UUID
				If ValType(oXml:_CLSCANCELA:_FOLIOS) == "A"
					cCodigo := oXml:_CLSCANCELA:_FOLIOS[1]:_FOLIO:_ESTATUSUUID:Text
				Else
					If XmlChildEx(oXml:_CLSCANCELA:_FOLIOS:_FOLIO,"_ESTATUSUUID") <> Nil .And. cEsCancel != "2"
						cCodigo := oXml:_CLSCANCELA:_FOLIOS:_FOLIO:_ESTATUSUUID:Text
					Else
						If cEsCancel != "2" // Diferente a Cancelable con Aceptación
							cCodigo := "201"
						EndIf
					EndIf
				EndIf
			EndIf

			If XmlChildEx(oXml:_CLSCANCELA, "_ACUSE") <> Nil
				// Fecha de cancelación (Acuse)
				If XmlChildEx(oXml:_CLSCANCELA:_ACUSE, "_CANCELACFDRESPONSE") <> Nil
					cFechaXML := oXml:_CLSCANCELA:_ACUSE:_CANCELACFDRESPONSE:_CANCELACFDRESULT:_FECHA:Text
				Else
					cFechaXML := ""
				EndIf
			EndIf
		EndIf
	EndIf

	If cCodigo == "201" .Or. cCodigo == "202"
		// Cancelado ==> La rutina de actualización coloca estado correcto
		aResp[1] := cCodigo
	EndIf

EndIf

Return aResp

/*/{Protheus.doc} ImprimeLog
//Imprime Log del proceso.
@author arodriguez
@since 30/10/2018
@version 1.0
@return Nil

@type function
/*/
Static Function ImprimeLog(cOpcion)
	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Local cTamanho	:= "M"
	Local cTitulo	:= STR0001	//"Cancelación de CFDI"
	Local aLogTitle	:= Array(2)
	Local aLog		:= {}
	Local nLenDoc	:= Len(SF2->(F2_DOC+F2_SERIE)) + 4
	Local nLenCte	:= Len(SF2->(F2_CLIENTE+F2_LOJA)) + 5
	Local nX		:= 1
	Local nTotProc	:= 0

	aLogTitle[1] := PadR(STR0031,nLenDoc)+PadR(STR0032,nLenCte)+STR0033	//"Documento" # "Cliente" # "Mensaje"
	aLogTitle[2] := IIf(cOpcion=="E", STR0037, STR0038)	//"Resumen del proceso de consulta de estado de CFDI" # "Resumen del proceso de solicitud de cancelación de CFDI"
	aAdd( aLog, {})

	For nX := 1 to Len(aRegs)
		If !aRegs[nX, dfConfProc]
			Loop
		EndIf
	    aAdd(aLog[1],	aRegs[nX,dfDocumento] + Space(4) + ; // Documento + Serie
	    				aRegs[nX,dfCliente] + Space(4) + ; // Cliente + Loja
	    				IIf(!Empty(aRegs[nX,dfMensaje]), aRegs[nX,dfMensaje], STR0034) + ;
						IIf(!Empty(aRegs[nX,dfMsgCan]), CRLF + space(Len(aRegs[nX,dfDocumento]));
							 + Space(4) + space(Len(aRegs[nX,dfCliente])) + Space(4) + aRegs[nX,dfMsgCan], "")) // Detalle # "Procesado."
		nTotProc++
	Next nX

	If nTotProc == 0
		aAdd(aLog[1], STR0063) //"No se realizó solicitud de cancelación de CFDI para ningún documento."
	EndIf

	aAdd( aLog, {})
	aAdd( aLog[2], "")
	aAdd( aLog[2], STR0039 + Str(nTotProc,5))	//"Total de documentos procesados: "

	/*
		1 -	aLogFile 	//Array que contem os Detalhes de Ocorrencia de Log
		2 -	aLogTitle	//Array que contem os Titulos de Acordo com as Ocorrencias
		3 -	cPerg		//Pergunte a Ser Listado
		4 -	lShowLog	//Se Havera "Display" de Tela
		5 -	cLogName	//Nome Alternativo do Log
		6 -	cTitulo		//Titulo Alternativo do Log
		7 -	cTamanho	//Tamanho Vertical do Relatorio de Log ("P","M","G")
		8 -	cLandPort	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
		9 -	aRet		//Array com a Mesma Estrutura do aReturn
		10-	lAddOldLog	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
	*/
	MsAguarde( { ||fMakeLog( aLog , aLogTitle , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn , .F. )}, STR0035) //"Generando Log de proceso..."
Return Nil

/*/{Protheus.doc} ImprimeLog
//Obtiene la rutina origen del documento(E1_ORIGEM)
@author alf Medrano
@since 30/04/2019
@version 1.0
@return nombre de rutina origen
@type function
/*/
Static function ObtOrigen(cCliente,cLoja,cPrefixo,cNumDoc )
	Local aArea		:= GetArea()
	Local cRutOrg	:= ""

	DbSelectArea("SE1")
	SE1->(DbSetOrder(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(dbSeek(xFilial("SE1")+cCliente+cLoja+cPrefixo+cNumDoc ))
		 cRutOrg := SE1->E1_ORIGEM
	EndIf
	SE1->(dbCloseArea())
	RestArea(aArea)

Return cRutOrg

/*/{Protheus.doc} LibMetric
Funcion utilizada para validar la fecha de la LIB para ser utilizada en Telemetria.

@type       Function
@author     Marco Augusto González Rivera
@since      20/11/2021
@version    1.0
@return     lMetric, lógico, Retorna .T. si la LIB puede ser utilizada para Telemetria.
/*/
Static Function LibMetric()
	Local lMetric := .F.

	lMetric := (FWLibVersion() >= "20210517") .And. FindClass('FWCustomMetrics')

Return lMetric

/*/{Protheus.doc} F817MCanc
//Ventana para selección de Motivo de cancelación
@type function
@author oscar.lopez
@since 13/01/2021
@version 1.0
@param cTab, string, Area a utilizar
@param cAlTab, string, Alias de area a utilizar
@return aRet, array, Arreglo con motivo de cancelacion y folio que sustituye
/*/
Function F817MCanc(cTab, cAlTab, aMotCancel,cArchivo)

	Local aArea		:= GetArea()
	Local aItems	:= {}
	Local cCpoVal	:= "X3_CBOX"
	Local cConVal	:= ""
	Local cIdiom	:= FwRetIdiom()
	Local lRet		:= .F.
	Local lF817CanMot := IsInCallStack("F817CanMot")
	Local oDlg		:= Nil
	Local oSay		:= Nil
	Local oGet		:= Nil
	Local cUUID		:= Iif(lF817CanMot,AllTrim(SF3->F3_CNATREC),&(cTab+"->"+cAlTab+"_UUID"))
	Local cMotCanc	:= Iif(lF817CanMot,aRegs[Len(aRegs),11],&(cTab+"->"+cAlTab+"_TIPNOTA"))
	Local cSerDoc	:= Iif(lF817CanMot,SF3->F3_SERIE,&(cTab+"->"+cAlTab+"_SERIE"))
	Local cNumDoc	:= Iif(lF817CanMot,AllTrim(SF3->F3_NFISCAL),&(cTab+"->"+cAlTab+"_DOC"))
	Local cDocto	:= Alltrim(cSerDoc) + "/" + AllTrim(cNumDoc)
	Default cArchivo := ""

	If cIdiom $ 'en|ru'
		cCpoVal += "ENG"
	ElseIf cIdiom == 'es'
		cCpoVal += "SPA"
	EndIf

	cConVal	:= GetSX3Cache(cAlTab+"_TIPNOTA", cCpoVal)
	aItems	:= STRTOKARR(cConVal, ";")

	DEFINE DIALOG oDlg TITLE STR0049 FROM 180,180 TO 332,600 PIXEL //"Motivo Baja"

		@ 010,010 SAY oSay PROMPT STR0059 RIGHT SIZE 065,011 OF oDlg PIXEL //"Serie/No. Doc."
		@ 010,080 SAY oSay PROMPT cDocto SIZE 120,011 OF oDlg PIXEL

		@ 025,010 SAY oSay PROMPT STR0050 RIGHT SIZE 065,011 OF oDlg PIXEL //"Folio:"
		@ 025,080 SAY oSay PROMPT AllTrim(cUUID) SIZE 120,011 OF oDlg PIXEL

		@ 041,010 SAY oSay PROMPT STR0051 RIGHT SIZE 065,011 OF oDlg PIXEL //"Motivo cancelación:"
		oCombo1 := TComboBox():New(040,080,{|u| If(PCount()>0,cMotCanc:=u,cMotCanc)},aItems,120,011,oDlg,,;
								{||},,,,.T.,,,,,,,,,'cMotCanc')

		@ 058,135 BUTTON STR0053 SIZE 030, 011 PIXEL OF oDlg ACTION (lRet := F817MCanVa(cMotCanc, cTab), IIf(lRet,oDlg:End(),)) //"Confirmar"
		@ 058,170 BUTTON STR0058 SIZE 030, 011 PIXEL OF oDlg ACTION (lRet := .F., oDlg:End()) //"Salir"

	ACTIVATE DIALOG oDlg CENTERED

	If lRet .and. !lF817CanMot
		RecLock(cTab, .F.)
		(cTab)->&(cAlTab+"_TIPNOTA")	:= cMotCanc
		(cTab)->&(cAlTab+"_CODDOC")		:= cArchivo
		(cTab)->(MsUnlock())
	EndIf

	aMotCancel := {cMotCanc}
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} F817MCanVa
//Validacion al informar el motivo de cancelacion
@type function
@author oscar.lopez
@since 13/01/2022
@version 1.0
@param cMotCan, string, Codigo de motivo de cancelacion
@param cUUIDSust, string, Folio sustitución
@param cTab, string, Area a utilizar
@return lRet, boolean, Verdadero o falso a partir de las validaciones realizadas
/*/
Function F817MCanVa(cMotCan, cTab)
	Local lRet	:= .T.
	Local aArea	:= GetArea()
	Local nOrdem:= IIf(cTab == "SF1", 7, 15)
	Local lF817CanMot := IsIncallStack("F817CanMot")
	Default cMotCan		:= ""

	If Empty(cMotCan)
		MsgAlert(STR0055, STR0054) //"Por favor seleccione el motivo de cancelación." ## "Alerta"
		lRet := .F.
	ElseIf cMotCan == "01"
		if !lF817CanMot
			If !MsgYesNo(STR0064, STR0054) //"Al seleccionar el Motivo de cancelación 01 - Compr. Emitido c/errores c/relac.,
				lRet := .F.               //usted está obligado a realizar una nueva factura que sustituya a la seleccionada actualmente.
			Endif                          //Al transmitir la nueva factura, la cancelación de la factura actual será informada al SAT.Después de ejecutado el proceso actual, la factura que ahora usted tiene seleccionada quedara solo anulada dentro del sistema y no se visualizará más. ¿Continuar?" ## "Alerta"
		else
			If !F817DocSus(SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA)
				MsgAlert(STR0067,STR0054) // El Documento fue previamente anulado en el sistema con el motivo 01, por favor elija otro motivo de cancelación para realizar la solicitud de cancelación ante el sat.
				lRet := .F.
			Else
				lRet := .T.
			Endif
		Endif
	Elseif lF817CanMot .And. F817DocSus(SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA)
		MsgAlert(STR0068,STR0054) // El Documento ya fue relacionado con un nuevo documento, por favor elije el Motivo de cancelación 01 - Compr. Emitido c/errores c/relac. para cancelar ante el SAT
		lRet:= .F.
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} F817DocSus
	Función que valida si el documento ya fue informado como documento a sustituir
	para la cancelación.
	@type function
	@author eduardo.manriquez
	@since 24/02/2022
	@version 1.0
	@param cDoc, caracter, Número de documento
	@param cSer, caracter, Serie del documento
	@param cCliente, caracter, Cliente del documento
	@param cLoja, caracter, Tienda del cliente
	@return lRet, boolean, Verdadero si el documento ya fue usado, falso si aun no ha sifo usado
	/*/
 Function F817DocSus(cDoc,cSer,cCliente,cLoja)
	Local cAliasTmp := GetNextAlias()
	Local cCampos   := ""
	Local cTabla    := ""
	Local cCond     := ""
	Local nReg      := 0
	Local lRet      := .F.
	Local cEspDoc   := ""

	If nTipo == 1 .Or. nTipo == 2
		cEspDoc := IIf(nTipo == 1,"NF","NDC")
		cCampos	:= "% SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_UUID as UUID%"
		cTabla  :=  "%" + RetSqlName("SF2") +" SF2 %"
		cCond	:= "% SF2.F2_FILIAL = '" + xFilial("SF2") + "'"
		cCond	+= " AND SF2.F2_DOCMAN ='"+AllTrim(cDoc)+"'"
		cCond	+= " AND SF2.F2_SERMAN ='"+cSer+"'"
		cCond	+= " AND SF2.F2_ESPECIE ='"+cEspDoc+"'"
		cCond	+= " AND SF2.F2_CLIENTE ='"+cCliente+"'"
		cCond	+= " AND SF2.F2_LOJA ='"+cLoja+"'"
		cCond	+= " AND SF2.F2_UUID <>''"
		cCond	+= " AND SF2.F2_FECTIMB <>''"
		cCond	+= " AND SF2.D_E_L_E_T_  = ' ' %"
	else
		cEspDoc := "NCC"
		cCampos	:= "% SF1.F1_FILIAL,SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_UUID as UUID%"
		cTabla  :=  "%" + RetSqlName("SF1") +" SF1 %"
		cCond	:= "% SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
		cCond	+= " AND SF1.F1_DOCMAN ='"+cDoc+"'"
		cCond	+= " AND SF1.F1_SERMAN ='"+cSer+"'"
		cCond	+= " AND SF1.F1_ESPECIE ='"+cEspDoc+"'"
		cCond	+= " AND SF1.F1_FORNECE ='"+cCliente+"'"
		cCond	+= " AND SF1.F1_LOJA ='"+cLoja+"'"
		cCond	+= " AND SF1.F1_UUID <>''"
		cCond	+= " AND SF1.F1_FECTIMB <>''"
		cCond	+= " AND SF1.D_E_L_E_T_  = ' ' %"
	Endif

	BeginSql alias cAliasTmp
		SELECT %exp:cCampos%
		FROM  %exp:cTabla%
		WHERE %exp:cCond%
	EndSql

	Count to nReg

	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbGotop())
	If nReg > 0
		lRet := .T.
		aRegs[Len(aRegs), 12] := (cAliasTmp)->UUID
	EndIF

	(cAliasTmp)->( dbCloseArea())

Return lRet

/*/{Protheus.doc} F817DOCTIM
Valida si el documento a sustituir se encuentra relacionado a un documento timbrado
@type function
@author luis.enriquez
@since 12/03/2022
@version 1.0
@param cSerSus, caracter, Serie el Recibo cancelado.
@param cDocSus, caracter, Folio de Recibo cancelado.
@param cDocTimb, caracter, Serie el Recibo que Sustituye.
@param UUIDDoc, caracter, Folio de Recibo que Sustituye.
@return cAccion, caracter, //T- Si el doc. a sustiruir está relacionado a un documento Timbrado
R- Si el doc. a sustiruir está relacionado a un documento sin Timbrar y vacío que no se encuentra relacionado a un documento.
/*/
Function F817DOCTIM(cSerSus, cDocSus, cDocTimb, UUIDDoc)
	Local cAliasSF := getNextAlias()
	Local nCount   := 0
	Local cAccion  := "" //T-Documentos Relacionado-Timbrado "R"-Documentos Relacionado-No Timbrado

	Default cSerSus  := ""
	Default cDocSus  := ""
	Default cDocTimb := ""
	Default UUIDDoc  := ""

	If nTipo == 1 .Or. nTipo == 2
		BeginSql alias cAliasSF
			SELECT F2_SERIE SERIE, F2_DOC DOC, F2_UUID UUID, F2_FECTIMB FECTIMB
			FROM %table:SF2% SF2
			WHERE SF2.F2_FILIAL = %xFilial:SF2%
			AND F2_SERMAN = %exp:cSerSus%
			AND F2_DOCMAN = %exp:cDocSus%
			AND SF2.%notDel%
		EndSql
	Else
		BeginSql alias cAliasSF
			SELECT F1_SERIE SERIE, F1_DOC DOC, F1_UUID UUID, F1_FECTIMB FECTIMB
			FROM %table:SF1% SF1
			WHERE SF1.F1_FILIAL = %xFilial:SF1%
			AND F1_SERMAN = %exp:cSerSus%
			AND F1_DOCMAN = %exp:cDocSus%
			AND SF1.%notDel%
		EndSql
	EndIf

	count to nCount

	If nCount > 0
		dbSelectArea(cAliasSF)
		(cAliasSF)->(dbGoTop())

		While (cAliasSF)->(!Eof())
			If !Empty(UUID) .And. !Empty(FECTIMB)
				UUIDDoc := Alltrim((cAliasSF)->UUID)
				cAccion := "T"
			Else
				cAccion := "R"
			EndIf
			cDocTimb := Alltrim((cAliasSF)->SERIE) + "-" + Alltrim((cAliasSF)->DOC)

			(cAliasSF)->(dBSkip())
		EndDo
	EndIf

	If Select(cAliasSF) > 0
		(cAliasSF)->(dbCloseArea())
	EndIf
Return cAccion

/*/{Protheus.doc} FS817VlCnt
	Valida Calendario Contable (Abierto, Cancelado o Cerrado)
	@type  Static Function
	@author Alfredo Medrano
	@since 10/08/2022
	@version version
	@param dDataRef, fecha, Fecha de emision de factura.
	@param dDtLanc, Fecha, Fecha de contabilización del documento.
	@return lRet, lógico
	@example FS817VlCnt(22/12/2022, 22/12/2022)
/*/
Function FS817VlCnt(dDataRef, dDtLanc)
	Local aArea		:= GetArea()
	Local cTmpPer	:= CriaTrab(Nil,.F.)
	Local lRet		:= .T.
	Local cHelp		:= ""
	Local cDataRef	:= Dtos(dDataRef)

	If !Empty(dDtLanc)
		BeginSql alias cTmpPer
			SELECT CTG_CALEND, CTG_STATUS, CTG_DTINI, CTG_DTFIM
			FROM %table:CTG%
			WHERE %exp:cDataRef% BETWEEN CTG_DTINI AND CTG_DTFIM
				AND CTG_FILIAL = %xFilial:CTG%
				AND %notDel%
		EndSql

		dbSelectArea(cTmpPer)
		(cTmpPer)->(dbGotop())

		If (cTmpPer)->(!EOF())
			If (cTmpPer)->CTG_STATUS $ '4|2'
				cHelp := "Calendario Contable Bloqueado." + chr(10) //"Calendario Contable Bloqueado."
				cHelp += "Calendario: " + (cTmpPer)->CTG_CALEND + chr(10) //"Calendario: "
				cHelp += "Periodo: " + DToC(SToD((cTmpPer)->CTG_DTINI)) +" - "+ DToC(SToD((cTmpPer)->CTG_DTFIM)) //"Periodo: "
				Help(" ",1,"CTBBLOQ",,cHelp,1,0)
				lRet := .F.
			EndIf
		EndIf

		(cTmpPer)->( dbCloseArea())

		If lRet //Si Calendario Contable no esta Cerrado o Bloqueado, valida bloqueo de proceso FAT004
			cHelp	:= "Calendario Contable - Proceso FAT004 Bloqueado." //"Calendario Contable - Proceso FAT004 Bloqueado."
			lRet	:= CtbValiDt(Nil,dDataRef,/*.T.*/  ,Nil ,Nil ,{"FAT004"}, cHelp)
		EndIf
	EndIf
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} F817ActSta
//Actualiza el estatus despues de realizar la consulta al SAT del documento
@author Verónica Flores
@since 31/01/2023
@version 1.0
@param cStaAct caracter Estatus actual del documento
@param cStatus caracter Nuevo estatus del documento
@param cMsg caracter Mensaje que devuelve segun el estatus
@return cNStatus caracter Estatus nuevo del documento
@type function
/*/
Function F817ActSta(cStaAct,cStatus,cMsg)

Local cNStatus  := ""
Default cStatus := ""
Default cStaAct	:= ""
Default cMsg	:= ""

	Do Case
		Case "PROCESO" $ cStatus
			cNStatus := "E"
			cMsg	 := STR0083 //"Documento con solicitud de cancelación en Proceso."
		Case "RECHAZADA" $ cStatus
			cNStatus := "R"
			cMsg	 := STR0084 //"Documento con solicitud de cancelación Rechazada."
		Case "CANCELADO" $ cStatus
			cNStatus := "C"
			cMsg	 := STR0085 //"Documento Cancelado ante el SAT."
		Case "NO CANCELABLE" $ cStatus
			cNStatus := "E"
			cMsg	 := STR0087 //"Documento No Cancelable"	
		Case cStaAct $ "R|A"	
			cNStatus := "E"
			cMsg	 := STR0086 //"Documento enviado para solicitud de cancelación."
		Otherwise	
			cNStatus := ""	
	End	

Return cNStatus

/*/{Protheus.doc} F817CopAcu
//Copia archivos .sol,.xml y .pdf de los documentos cancelados.
@author Verónica Flores
@since 20/10/2023
@version 1.0
@param aArchivos array Nombre de los documentos cancelados
@param cDirLoc caracter Ruta donde se copiarán los archivos localmente
@param lMsg logico Si muestra o no el mensaje al usuario
@return lRet logico Si se copiaron los documentos
@type function
/*/

Function F817CopAcu(aArchivos,cDirLoc,lMsg)
Local nX      	:= 0
Local cMsj    	:= ""
Local cRutaAnu	:= &(SuperGetmv( "MV_CFDANUL" , .F. ,""))
Local lRet  	:= .F.
Default lMsg	:= .F.
Default cDirLoc:= ""
Default aArchivos:= {}

	MakeDir(cDirLoc)
	For nX := 1 to Len(aArchivos)
		If File(cRutaAnu + aArchivos[nX] + ".sol")			
			CpyS2T( cRutaAnu + aArchivos[nX] + ".sol" , cDirLoc )			
			If File(cRutaAnu + aArchivos[nX])
				CpyS2T( cRutaAnu + aArchivos[nX], cDirLoc )
			Endif
			If File(cRutaSrv + Replace(aArchivos[nX],"xml","pdf"))
				CpyS2T( cRutaSrv + Replace(aArchivos[nX],"xml","pdf") , cDirLoc )
			Endif
			cMsj += Replace(aArchivos[nX],".xml","") + (chr(13)+chr(10))
		Endif
	Next nX

	If !Empty(cMsj) 
	   	If lMsg
			MsgAlert( STR0124 + cMsj + STR0125 + cDirLoc , STR0002 ) //"Los acuses de cancelación de los docs: " // "se guardaron en la ruta "
		EndIf
		lRet := .T.
	EndIf
Return lRet


/*/{Protheus.doc} lxMxDcFrPr
  	Se informa al usuario del proceso de cancelación fuera de periodo 
	cancelación(Generación de NCA y de Recibo) 
	@type  Static Function
	@author alfredo.medrano
	@since 30/08/2023
	@version version
	@@param nX,		número,		Posición del Docto. que se esta procesando.
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lxMxDcFrPr(nX)

	Local lRet 		:= .T.
	Local cTxtRet 	:= ""
	Default nX 		:= 0

	cTxtRet := StrTran( STR0088,"###",Alltrim(SF2->F2_DOC + SF2->F2_SERIE) ) //"El Documento ### se encuentra fuera de periodo para su cancelación (aaa)."
	cTxtRet := StrTran( cTxtRet,"##",Alltrim(DtoC(SF2->F2_EMISSAO)) )  + CRLF + CRLF
	cTxtRet += STR0089 + CRLF + CRLF //"Para este documento será utilizado el proceso de cancelación fuera de Periodo. "
	cTxtRet += STR0090 //"El proceso de cancelación fuera de periodo genera una Nota de Crédito de tipo NCA(Nota de Cancelación), " 
	cTxtRet += STR0091 + CRLF + CRLF//"posteriormente, se genera un Recibo de Cobro para compensar el documento a cancelar y la NCA"
	cTxtRet += STR0093//"¿Desea continuar con la cancelación de éste Documento?" 

	If aRegs[nX,dfCanFper] // fuera de periodo, valor asignado en la funcion F817VMark()
		
		If !MsgYesNo( cTxtRet,STR0115) //Aviso
			aRegs[nX,dfMensaje] := STR0094 //"No procesado."
			lRet := .F.
		Endif
		
	EndIf

Return lRet

/*/{Protheus.doc} lxMxValDFP
    Generación de NCA y de Recibo cobro para las facturas fuera de periodo.  
	Función utilizada en lxMxDocPen(), ActualizaDoc() y en la urutina FISA800
	dentro de la función lxMxActSts()
	@type  Static Function
	@author alfredo.medrano
	@since 30/08/2023
	@version version
	@@param nX,		número,		Posición del Docto. que se esta procesando.
	@return lOpc, 	Lógico, 	Indica si será mostrado el aviso de generación de doctos de cancelación (NCA y Recibo) 
	@example
	(examples)
	@see (links_or_references)
/*/
Function lxMxValDFP(nX,lOpc)
Local lRet 		:= .T.
Local cTxtRet 	:= ""
Default nX 		:= 0
Default lOpc 	:= .T.

	If lOpc
		If SF2->F2_FLFTEX == "9" //Cancelado en el SAT pendiente cancelación en sistema
			cTxtRet := STR0133 + Alltrim(SF2->F2_DOC + SF2->F2_SERIE) + STR0134 + CRLF + CRLF //"Documento "//" cancelado ante el SAT, pendiente de cancelación en sistema."
		EndIf
		cTxtRet += STR0135 // "Serán generados los documentos de cancelación (Nota de Crédito de Cancelación y Recibo de Compensación) "
		cTxtRet += STR0136 + Alltrim(SF2->F2_DOC + SF2->F2_SERIE) + STR0137 + CRLF //"para cancelar la Factura " //" en el sistema." 
		Aviso( STR0099, cTxtRet,{"Ok"}) //"Cancelación Fuera de Periodo"
	Endif

	If !LxMxGnrNCA(nX)  // Generacion de NCA (NCC tipo 24) y Recibo
		If SF2->F2_FLFTEX != "9"
			aRegs[nX,dfMsgCan] := Alltrim(STR0133) + STR0134 //"Documento cancelado ante el SAT, pendiente de cancelación en sistema."
		EndIf
		lRet := .F.
	Endif

Return lRet


/*/{Protheus.doc} LxMxGnrNCA
	Generación de Nota de cancelación(NCA) y de Recibo
	@type  Static Function
	@author alfredo.medrano
	@since 28/08/2023
	@version version
	@@param nX,		número,		Posición del Docto. que se esta procesando.
	@return lRet, 	Lógico, 	Transacción 
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function LxMxGnrNCA(nX)
	Local aArea		:= GetArea()
	Local aCabs		:= {}
	Local aItensTot	:= {}
	Local cNmSx5	:= "" 
	Local lRet		:= .T.
	Local lTES		:= .T.
	Local cEspec	:= Padr("NCC", TamSx3("F1_ESPECIE")[1], " ")
	Local cFilSF1	:= XFilial("SF1")
	
	If Type('cSerNCA') == "U"
		Private cSerNCA	 := SuperGetmv( "MV_SERNCA" , .F. , "" ) 
	EndIf	

	If Empty(cSerNCA) 
		aRegs[nX,dfMensaje] := STR0126 //"El parámetro MV_SERNCA no esta configurado. Asigne una serie para identificar las Notas de Cancelación."
		Return .F.
	Endif

	cSerNCA	:= Padr(Alltrim(cSerNCA), TamSx3("F1_SERIE")[1], " ")
	aSize(aCabs, 0)
	
		If lxMxGerNum(@cNmSx5,cEspec,cSerNCA,cFilSF1) 
			
			lxMxLdNCC(@aCabs, @aItensTot, cNmSx5, cEspec, cSerNCA,nX,@lTES)
			If !lTES
				Return .F.	
			Endif
			// Baja por rutina automática
			BEGIN TRANSACTION
				lMSErroAuto := .F.
				MaFisEnd()
				MATA465N(aCabs,aItensTot,3,,,4) 
				
				If lMSErroAuto
					DisarmTransaction()	 
					MostraErro()
					lRet := .F.
					aRegs[nX,dfMensaje] := STR0096 + cNmSx5+cSerNCA //"Error al generar la Nota de Crédito de tipo Cancelación "
				Else
					DbSelectArea('SF1')
					SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
					If (SF1->(MSSeek(cFilSF1+cNmSx5+cSerNCA+SF2->F2_CLIENTE+SF2->F2_LOJA)))
						If SF1->F1_VALBRUT <> SF2->F2_VALBRUT
							aRegs[nX,dfMensaje] := STR0097 + Alltrim(Transform(SF1->F1_VALBRUT,PesqPict("SF1","F1_VALBRUT")))  + STR0098 + Alltrim(Transform(SF2->F2_VALBRUT,PesqPict("SF2","F2_VALBRUT"))) //"El valor de la Nota de Cancelación "//" es diferente al saldo del Documento " 
							DisarmTransaction()	 
							lRet := .F.
						Else
							If !lxMxNmDcRc(nX, SF2->F2_DOC+SF2->F2_SERIE, cNmSx5+cSerNCA,  SF2->F2_VALBRUT, SF1->F1_VALBRUT) // genera Recibo
								DisarmTransaction()	 
								lRet := .F.
							Endif
						EndIf
					EndIf
				EndIf
			END TRANSACTION
		Else
			aRegs[nX,dfMensaje] := STR0099 +  StrTran( STR0100,"###",alltrim(cSerNCA) )  //"Cancelación fuera de periodo. " + "No existe la serie ### en el Control de formulario (SFP) " 
			lRet := .F.		
		EndIf

	RestArea(aArea)
Return lRet


 /*/{Protheus.doc} LxMxGnrRcb
	Generacion del Recibo por medio de la rutina automatica FINA887
	@type  Function
	@author alfredo.medrano
	@since 03/08/2023
	@version version
	@param nX,		número,		Posición del Docto. que se esta procesando.
	@param cSerie,	carácter,	Serie del Recibo
	@param cRecibo, carácter,	Número del Recibo
	@return lRet, 	lógico, 	Recibo Generado
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function LxMxGnrRcb(nX,cSerie,cRecibo)
	Local aArea		:= GetArea()
	Local oMdlTab
    Local cMsj 		:= ""
    Local cCliente 	:= SF2->F2_CLIENTE 
	Local cLoja 	:= SF2->F2_LOJA     
	Local nMoedDc 	:= SF2->F2_MOEDA
	Local lRet 		:= .T.
	Local cF2Espc 	:= Padr(SF2->F2_ESPECIE, TamSx3("E1_TIPO")[1], " ")
	Local cF1Espc 	:= Padr(SF1->F1_ESPECIE, TamSx3("E1_TIPO")[1], " ")
	Local cNumRec	:= ""
	Local cNumDcF1  := ""
	Local cFilSE1 	:=xFilial("SE1")
	Local cRutinaE	:= FunName()

	Default nX 			:= 0
	Default cRecibo 	:= ""
    Default cSerie  	:= ""

	cNumRec:= cRecibo
	If !Empty(cSerie)
		cNumRec := cSerie + " - " + cRecibo
	EndIf
	cNumDcF1 := SF1->F1_DOC+SF1->F1_SERIE
	SetFunName("FINA887")
 
    // Se define el modelo FINA887  
    oMdlTab  := FwLoadModel("FINA887")
   
    // Se define la operación INSERT en el modelo
    oMdlTab:SetOperation(MODEL_OPERATION_INSERT)
  
    // Se activa el modelo
    oMdlTab:Activate()
   
    //Encabezado de recibo - FJT
    oMdlTab:SetValue('FJT_MASTER', "FJT_FILIAL" , xFilial("FJT"))
    oMdlTab:SetValue('FJT_MASTER', "FJT_DTDIGI" ,   dDataBase )
    oMdlTab:SetValue('FJT_MASTER', "FJT_RECIBO" ,  cRecibo )
    oMdlTab:SetValue('FJT_MASTER', "FJT_SERIE" , cSerie)
    oMdlTab:SetValue('FJT_MASTER', "FJT_EMISSA" , dDataBase)
    oMdlTab:SetValue('FJT_MASTER', "FJT_CLIENT" ,  cCliente )
    oMdlTab:SetValue('FJT_MASTER', "FJT_LOJA"   , cLoja)
    oMdlTab:SetValue('FJT_MASTER', "FJT_COBRAD" , "")
    oMdlTab:SetValue('FJT_MASTER', "FJT_RECPRV" ,"")
    oMdlTab:SetValue('FJT_MASTER', "GERANCC"    , "")   
    oMdlTab:SetValue('FJT_MASTER', "DOCUMEN"    ,  "RA")
     
    // Se activa el grupo de preguntas FIN988 para usar los valores de la tabla de preguntas SX1.
    Pergunte("FIN998",.F.)
 
    oMdlTab:SetValue('FJT_MASTER', "ASIENTO"    , MV_PAR01) // ¿Muestra  Asientos ?         
    oMdlTab:SetValue('FJT_MASTER', "AGRUPA"     , MV_PAR02) // ¿Agrupa Asientos ?           
    oMdlTab:SetValue('FJT_MASTER', "ONLINE"     , MV_PAR03) //¿Asientos Online ?           
 
    //Monedas
    oMdlTab:SetValue('MOE_DETAIL',"MOEDA"       , nMoedDc)
    oMdlTab:SetValue('MOE_DETAIL',"TASA"        , SF1->F1_TXMOEDA)
    oMdlTab:SetValue('MOE_DETAIL',"RECIBIDO"    , 0) // Monto total que suman las formas de pago.
    oMdlTab:SetValue('MOE_DETAIL',"SALDO"       , 0 ) // Saldo que queda por cobrar entre los títulos x cobrar y las formas de pago.
    oMdlTab:GetModel('MOE_DETAIL' ):AddLine()
    oMdlTab:SetValue('MOE_DETAIL',"MOEDA"       , "2")
    oMdlTab:SetValue('MOE_DETAIL',"TASA"        , 0)
    oMdlTab:SetValue('MOE_DETAIL',"RECIBIDO"    , 0)
    oMdlTab:SetValue('MOE_DETAIL',"SALDO"       , 0 )

	DbSelectArea("SE1")
	SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(MSSEEK(cFilSE1+cCliente+cLoja+SF2->F2_PREFIXO+SF2->F2_DOC))
		nlin := 0
		While !SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)== cFilSE1+cCliente+cLoja+SF2->F2_PREFIXO+SF2->F2_DOC
			//Detalle de los titulos x cobrar - Tabla SE1
			If nlin > 0
				//Para agregar una nueva linea al grid de titulos x cobrar
				oMdlTab:GetModel('SE1_DETAIL' ):AddLine()
			Endif
			oMdlTab:SetValue('SE1_DETAIL',"E1_FILIAL"       , xFilial("SE1"))
			oMdlTab:SetValue('SE1_DETAIL',"E1_PREFIXO"      , SF2->F2_PREFIXO)
			oMdlTab:SetValue('SE1_DETAIL',"E1_NUM"          , SF2->F2_DOC)
			oMdlTab:SetValue('SE1_DETAIL',"E1_PARCELA"      , SE1->E1_PARCELA)
			oMdlTab:SetValue('SE1_DETAIL',"E1_TIPO"         , cF2Espc)
			oMdlTab:SetValue('SE1_DETAIL',"E1_CLIENTE"      , cCliente)
			oMdlTab:SetValue('SE1_DETAIL',"E1_LOJA"         , cLoja)
			oMdlTab:SetValue('SE1_DETAIL',"E1_DESCONT"      , 0)
			oMdlTab:SetValue('SE1_DETAIL',"E1_MULTA"        , 0)
			oMdlTab:SetValue('SE1_DETAIL',"E1_JUROS"        , 0)
			oMdlTab:SetValue('SE1_DETAIL',"E1_SALDO"        , SE1->E1_SALDO)
			oMdlTab:SetValue('SE1_DETAIL',"BAIXAR" 			, SE1->E1_SALDO)
			oMdlTab:SetValue('SE1_DETAIL',"RECNO" 			, SE1->(RECNO()))
			oMdlTab:SetValue('SE1_DETAIL',"E1_MOTIVO"       , "NOR")
			nlin++	
			SE1->(DbSkip())		
		End
	EndIf

	SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(MSSEEK(cFilSE1+cCliente+cLoja+SF1->F1_PREFIXO+SF1->F1_DOC))
		While !SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)== cFilSE1+cCliente+cLoja+SF1->F1_PREFIXO+SF1->F1_DOC
			//Detalle de los titulos x cobrar - Tabla SE1
			//Para agregar una nueva linea al grid de titulos x cobrar
			oMdlTab:GetModel('SE1_DETAIL' ):AddLine()
			
			oMdlTab:SetValue('SE1_DETAIL',"E1_FILIAL"       , xFilial("SE1"))
			oMdlTab:SetValue('SE1_DETAIL',"E1_PREFIXO"      , SF1->F1_PREFIXO  )
			oMdlTab:SetValue('SE1_DETAIL',"E1_NUM"          , SF1->F1_DOC)
			oMdlTab:SetValue('SE1_DETAIL',"E1_PARCELA"      , SE1->E1_PARCELA)
			oMdlTab:SetValue('SE1_DETAIL',"E1_TIPO"         , cF1Espc)
			oMdlTab:SetValue('SE1_DETAIL',"E1_CLIENTE"      , cCliente)
			oMdlTab:SetValue('SE1_DETAIL',"E1_LOJA"         , cLoja)
			oMdlTab:SetValue('SE1_DETAIL',"E1_DESCONT"      , 0)
			oMdlTab:SetValue('SE1_DETAIL',"E1_MULTA"        , 0)
			oMdlTab:SetValue('SE1_DETAIL',"E1_JUROS"        , 0)
			oMdlTab:SetValue('SE1_DETAIL',"E1_SALDO"        , SE1->E1_SALDO)
			oMdlTab:SetValue('SE1_DETAIL',"BAIXAR" 			, SE1->E1_SALDO)
			oMdlTab:SetValue('SE1_DETAIL',"RECNO" 			, SE1->(RECNO()))
			oMdlTab:SetValue('SE1_DETAIL',"E1_MOTIVO"		, "NOR")
			SE1->(DbSkip())		
		End
	EndIf

	SE1->(dbCloseArea())

    oMdlTab:SetValue('FAC_DETAIL','FACTOR',"2") // Factoraje financiero, 1 - Indica que es una operación de factoraje | 2 - No es operación de factoraje
 
    oMdlTab:SetValue('GEN_DETAIL',"HOURSAVERECEIPT"     , Time() ) // Hora de guardado del recibo.
 
    //Se ejecuta el commit
    If oMdlTab:VldData() // Se detonan las validaciones del modelo
        // Si pasa las validaciones, se ejecutara el CommitData del modelo para guardar los datos.
        oMdlTab:CommitData()
    Endif
 
    // En caso de usar número consecutivos en el recibo
    If !Empty(GetSx3Cache("EL_RECIBO","X3_RELACAO"))
        If Alltrim(cRecibo) <> Alltrim(InitPad(GetSX3Cache("EL_RECIBO","X3_RELACAO")))
            RollBackSX8()
        EndIf
    EndIf
     
    // Se obtienen los errores del modelo
    aError := oMdlTab:GetErrorMessage()
    If alltrim(aError[6]) <> ""
        cMsj := aError[6]
		lRet := .F.
    Endif
	If lRet
		aRegs[nX,dfMsgCan]  := StrTran( STR0101,"###",alltrim(cNumDcF1) ) + cNumRec // "Se generó la Nota de Cancelación(NCA) ###  y el Recibo "
	Else
		aRegs[nX,dfMensaje] := STR0102 + cNumRec + " " + cMsj // "Error al generar el Recibo de Cancelación "
	Endif
     
    oMdlTab:DeActivate()
	RestArea(aArea)
	SetFunName(cRutinaE)
 
Return lRet

/*/{Protheus.doc} lxMxGerNum
	Genera el número de Nota de Crédito de Tipo NCA (Cancelación)
	@type  Static Function
	@author alfredo.medrano
	@since 18/08/2023
	@version  1.0
	@param cNmSx5,	carácter, 	Valor por referencia, contiene el número de NCA
	@param cEspec, 	carácter, 	Especie del del Docto. NCA
	@param cSerieNF,carácter,   Serie del Docto. NCA
	@param cFilSF1,	carácter,   Filial de la tabla SF1
	@return lRet,	Lógico, 	Validación de la serie NCA
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lxMxGerNum(cNmSx5,cEspec,cSerieNF,cFilSF1)
Local aAreaA	:= GetArea()
Local cImpX5 	:= ""
Local lRet		:= .T.
Local cNumCert 	:= "" 
Local cImpX5Tam	:= "" 
    
	cNumCert := PadL( "1", TamSX3( "FP_NUMINI" )[1], "0" )
	dbSelectArea("SFP")
	SFP->(dbSetOrder(3)) // FP_FILIAL+FP_FILUSO+FP_SERIE+FP_CAI+FP_NUMINI+FP_NUMFIM+FP_ESPECIE+FP_PV 
	If SFP->(dbSeek(xFilial("SFP")+cFilAnt+cSerieNF)) 	
		DbSelectArea("SX5")
		If dbSeek(xFilial("SX5")+"01"+cSerieNF)
			cImpX5 := alltrim(X5Descri())
			cImpX5Tam := PadL( cImpX5, TamSX3( "FP_NUMINI" )[1], "0" ) // se asignan el tamaño del campo de número de inicial
			If RecLock("SX5",.F.) 
				cImpX5Ex := Soma1(cImpX5Tam)
				Replace X5_DESCRI	WITH cImpX5Ex
				Replace X5_DESCSPA	WITH cImpX5Ex
				Replace X5_DESCENG	WITH cImpX5Ex
				SX5->(MsUnLock())
			EndIf
		 Else
		 		cImpX5Tam := cNumCert
				RecLock("SX5", .T.)
				SX5->X5_TABELA 	:= '01'
				SX5->X5_FILIAL 	:= xFilial("SX5")
				SX5->X5_CHAVE  	:= Alltrim(cSerieNF)
				SX5->X5_DESCRI 	:= cNumCert
				SX5->X5_DESCSPA := cNumCert
				SX5->X5_DESCENG := cNumCert
				MsUnLock()
   		EndIf
	Else
		lRet := .F.
	Endif   
	cNmSx5 :=cImpX5Tam     
	RestArea(aAreaA)
Return lRet

/*/{Protheus.doc} lxMxNmDcRc
	Ventana de selección de serie y número de Recibo de canelación 
	@type  Static Function
	@author alfredo.medrano
	@since 18/08/2023
	@version  1.0
	@param nX,		número,		Posición del Docto que se esta procesando.
	@param cDocNF,	carácter, 	Número de Factura mas Serie
	@param cDocNCA,	carácter, 	Número de Nota de Credito(NCA) mas Serie
	@param nSaldo,	número,   	Valor de la Factura
	@param nPago,	número,     Valor de la Nota de Credito(NCA)
	@return lRet,	Lógico, 	Validación de la generación del Recibo
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lxMxNmDcRc(nX, cDocNF, cDocNCA,nSaldo,nPago)
	
	Local lValSer   := .T.
	Local lRet 		:= .T.
	Local cSerie	:= Padr("", TamSx3("FJT_SERIE")[1], " ")
	Local cRecibo   := Padr("", TamSx3("FJT_RECIBO")[1], " ")
	Local oDlg		:= Nil
	Local oSay		:= Nil
	Local oSerie	:= Nil
	Local oRecibo	:= Nil
	Local oGroup	:= Nil
	Local oGroup1 	:= Nil
	Private nSaveSX8	:= GetSX8Len()


    lValSer := SuperGetMv('MV_SERREC') // Usa serie en los recibos 

	DEFINE MSDIALOG oDlg TITLE STR0103 FROM 180,180 TO 388,570 PIXEL //"Cancelación de Factura / Generación de Recibo

 	oGroup:= TGroup():New(023,012,55,190,STR0104,oDlg,,,.T.) //"Valores de la Baja"
	oGroup1:= TGroup():New(060,012,85,190,STR0105,oDlg,,,.T.) //"Recibo"

		@ 005,014 SAY oSay PROMPT STR0106   OF oGroup PIXEL // "Será generado un Recibo de Cobro para compensar el saldo del " 
		@ 013,014 SAY oSay PROMPT STR0107   OF oGroup PIXEL //"Documento con la Nota de Crédito de Cancelación (NCA)."
		@ 033,014 SAY oSay PROMPT STR0108	OF oGroup PIXEL //"Factura :" 
		@ 033,045 SAY oSay PROMPT  cDocNF  	OF oGroup PIXEL 
		@ 033,125 SAY oSay PROMPT STR0109  	OF oGroup PIXEL //"Saldo  :"
		@ 033,150 SAY oSay PROMPT Alltrim(Transform(nSaldo,PesqPict("SF2","F2_VALBRUT")))  OF oGroup PIXEL  
		@ 043,014 SAY oSay PROMPT STR0110   OF oGroup PIXEL //"Nota NCA"
		@ 043,045 SAY oSay PROMPT cDocNCA   OF oGroup PIXEL 
		@ 043,125 SAY oSay PROMPT STR0111  	OF oGroup PIXEL //"Pagar  :"
		@ 043,150 SAY oSay PROMPT Alltrim(Transform(nPago,PesqPict("SF1","F1_VALBRUT")))  OF oGroup PIXEL 

		@ 072,014 SAY oSay PROMPT STR0112   OF oGroup1 PIXEL //"Serie:"
		If lValSer
			@ 067,035 MSGET oSerie VAR cSerie F3 CpoRetF3('FJT_SERIE') SIZE 30, 10 OF oGroup1 PIXEL  HASBUTTON WHEN .t. VALID lxMxSerRec(cSerie,@cRecibo )
		Else
			@ 067,035 MSGET oSerie VAR cSerie SIZE 30, 10 OF oGroup1 PIXEL  HASBUTTON WHEN .F.
		EndIf
		@ 072,075 SAY oSay PROMPT STR0113 OF oGroup1 PIXEL //"Recibo:"
		@ 068,100 MSGET oRecibo VAR cRecibo	SIZE 40, 10 OF oGroup1 PIXEL  HASBUTTON WHEN .t. VALID lxMxNumRec(cSerie,cRecibo)

		DEFINE SBUTTON FROM 88, 129 TYPE 1 ENABLE OF oDlg ACTION (lRet := .T., oDlg:End()) //"ok"
		DEFINE SBUTTON FROM 88, 164 TYPE 2 ENABLE OF oDlg ACTION (lRet := .F., oDlg:End()) //"Cancelar"

	ACTIVATE MSDIALOG oDlg CENTERED

	If lRet
		lRet := LxMxGnrRcb(nX, cSerie, cRecibo)
	Else 
		aRegs[nX,dfMensaje] := STR0094//"No procesado."
	EndIf

Return lRet

/*/{Protheus.doc} lxMxSerRec
	Valida la serie y obtienen el número de recibo.
	@type  Static Function
	@author alfredo.medrano
	@since 19/08/2023
	@version version
	@param cSerie,	carácter, Serie del Recibo
	@param cRecibo, carácter, Número del Recibo
	@return lRet, 	Lógico,   Validación de número de Recibo
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lxMxSerRec(cSerie,cRecibo )
	Local aAreaA:= GetArea()
	Local lRet	:= .T.

	If Empty(cSerie)
		Help( ,, STR0115 ,,STR0114 ,1, 0 )//"Aviso" //"Indique la Serie "
		lRet	:= .F.
	Else
		DbSelectArea("SX5") 
		SX5->(DbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
		If SX5->(MSSeek(xFilial("SX5")+"RN"+cSerie ))
			cRecibo := StrZero( Val( X5Descri() ),TamSX3("EL_RECIBO")[1] )
		Endif
	Endif
	RestArea(aAreaA)
Return lRet

/*/{Protheus.doc} lxMxNumRec
	Valida la serie y el número de recibo. 
	@type  Static Function
	@author alfredo.medrano
	@since 19/08/2023
	@version version
	@param cSerie,	carácter, Serie del Recibo
	@param cRecibo, carácter, Número del Recibo
	@return lValid, Lógico,   Validación de número de Recibo
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lxMxNumRec(cSerie,cRecibo)
	Local aAreaA := GetArea()
	Local lValid := .T.

	If Empty(cRecibo)
			Help( ,, STR0115,, STR0116 ,1, 0 )//"Aviso" //"Indique el número de Recibo "
			lValid:= .F.
	Else
		DbSelectArea("FJT")
		FJT->(DbSetorder(1)) //FJT_FILIAL+FJT_SERIE+FJT_RECIBO+FJT_VERSAO
		If FJT->(MSSeek(xFilial("FJT")+cSerie+cRecibo))
			Help( ,, "FJTNUMEXIS" ,"FJTNUMEXIS",STR0117,1, 0 ) // "El Número del Recibo ya Existe "
			lValid := .F.
		EndIf
	EndIf
	RestArea(aAreaA)
Return lValid

/*/{Protheus.doc} lxMxLdNCC
	Carga el encabezado y los ítems de la nota de cancelación 
	@type  Static Function
	@author alfredo.medrano
	@since 23/08/2023
	@version version
	@param aCabs,     array,	valor por referencia, contiene los campos del encabezado de la Docto. NCA
	@param aItensTot, array,	valor por referencia, contiene los campos del detale de la Docto. NCA
	@param cNmSx5, 	  carácter, contiene el número de documento del Docto. NCA
	@param cEspec, 	  carácter, especie del del Docto. NCA
	@param cSerNCA,   carácter, Serie del Docto. NCA
	@param nX,   	  número, 	posición del Docto que se esta procesando.
	@param lRet,   	  Lógico, 	valor por referencia, validación de TES.
	@return .T.,	  Lógico, , .T.
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lxMxLdNCC(aCabs,aItensTot,cNmSx5,cEspec,cSerNCA,nX,lRet)
	Local aAreaA	:= GetArea()
	Local cFilSD2	:= xFilial("SD2")
	Local cFilSF4	:= xFilial("SF4")
	Local cTESNCC	:= ""
	Local dFecha	:= Date()
	Local aItens	:= {}
	Local cTESCF	:= ""
	Local nJ		:= 0
	Local aItemsEx  := {}
	Local lPESD1NCA := ExistBlock("F817NCASD1") // PE para agregar campos detalle de la NCA (SD1) 
	If Type('aItensSD1') == "U" 
		private aItensSD1	:= FWSX3Util():GetAllFields("SD1", .F.)
	Endif

		AADD(aCabs,{"F1_FORNECE"	,SF2->F2_CLIENTE	,NIL })
		AADD(aCabs,{"F1_LOJA"   	,SF2->F2_LOJA		,NIL })
		AADD(aCabs,{"F1_SERIE"  	,cSerNCA			,NIL })
		AADD(aCabs,{"F1_DOC"		,cNmSx5				,NIL })
		AADD(aCabs,{"F1_TPDOC"		,SF2->F2_TPDOC		,NIL })
		AADD(aCabs,{"F1_NATUREZ"	,SF2->F2_NATUREZ	,NIL })
		AADD(aCabs,{"F1_ESPECIE"	,cEspec				,NIL })
		AADD(aCabs,{"F1_EMISSAO"	,dFecha				,NIL })
		AADD(aCabs,{"F1_MOEDA"		,SF2->F2_MOEDA		,NIL })
		AADD(aCabs,{"F1_TXMOEDA"	,SF2->F2_TXMOEDA	,NIL })
		AADD(aCabs,{"F1_TIPODOC"	,"24"				,NIL }) 
		AADD(aCabs,{"F1_COND"		,SF2->F2_COND		,NIL })
		AADD(aCabs,{"F1_USOCFDI"	,SF2->F2_USOCFDI	,NIL })
		AADD(aCabs,{"F1_UUIDREL"	,SF2->F2_UUID		,NIL })
		AADD(aCabs,{"F1_DESPESA"    ,SF2->F2_DESPESA	,NIL }) 
		AADD(aCabs,{"F1_FRETE"    	,SF2->F2_FRETE		,NIL }) 
		AADD(aCabs,{"F1_SEGURO"    	,SF2->F2_SEGURO		,NIL }) 
		
		// Procesa generacion del documento NCA(NCC tipo 24)
		aSize(aItens, 0)
		
		SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO
		SD2->(dbSetOrder(3))  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		SD2->(MSSeek(cFilSD2+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		Do While !SD2->(Eof()) .And. cFilSD2+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
			
			aItens   := {}
			aItemsEx := {}
			If SF4->(DbSeek(cFilSF4+SD2->D2_TES)) //Obtiene TES de Entrada
				IF !EMPTY(SF4->F4_TESDV) 
					cTESNCC	:= SF4->F4_TESDV 
					cTESCF := Posicione("SF4", 1, cFilSF4+cTESNCC, "F4_CF") 
				Else
					aRegs[nX,dfMensaje] := StrTran( STR0118,"###",Alltrim(SD2->D2_TES) ) //"La TES ### utilizada por el ítem (##) no tiene configurada una TES de devolución."
					aRegs[nX,dfMensaje] := StrTran( aRegs[nX,dfMensaje],"##",Alltrim(SD2->D2_ITEM )) 
					lRet := .F.
					EXIT
				EndIf
			EndIf
		
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_UM"		} ) >  0  ,   AADD(aItens,{"D1_UM"		,	SD2->D2_UM		, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_SEGUM" 	} ) >  0  ,   AADD(aItens,{"D1_SEGUM"	, 	SD2->D2_SEGUM	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_COD" 		} ) >  0  ,   AADD(aItens,{"D1_COD"		, 	SD2->D2_COD 	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_LOCAL" 	} ) >  0  ,   AADD(aItens,{"D1_LOCAL"	,	SD2->D2_LOCAL 	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_NFORI" 	} )	>  0  ,   AADD(aItens,{"D1_NFORI"	,	SD2->D2_DOC 	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_SERIORI"	} )	>  0  ,   AADD(aItens,{"D1_SERIORI"	,	SD2->D2_SERIE 	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_ITEMORI"	} )	>  0  ,   AADD(aItens,{"D1_ITEMORI"	,	SD2->D2_ITEM 	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_ITEM" 		} )	>  0  ,   AADD(aItens,{"D1_ITEM" 	, 	SD2->D2_ITEM	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_VUNIT" 	} )	>  0  ,   AADD(aItens,{"D1_VUNIT" 	, 	SD2->D2_PRCVEN	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_TES" 		} )	>  0  ,   AADD(aItens,{"D1_TES" 	, 	cTesNCC			, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_CF" 		} )	>  0  ,   AADD(aItens,{"D1_CF" 		, 	cTESCF			, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_CONTA" 	} )	>  0  ,   AADD(aItens,{"D1_CONTA" 	, 	SD2->D2_CONTA	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_CC" 		} )	>  0  ,   AADD(aItens,{"D1_CC" 		, 	SD2->D2_CCUSTO	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_ITEMCTA"	} ) >  0  ,   AADD(aItens,{"D1_ITEMCTA"	, 	SD2->D2_ITEMCC	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_CLVL" 		} )	>  0  ,   AADD(aItens,{"D1_CLVL"  	, 	SD2->D2_CLVL	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_LOTECTL"	} ) >  0  ,   AADD(aItens,{"D1_LOTECTL"	, 	SD2->D2_LOTECTL	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_NUMLOTE"	} ) >  0  ,   AADD(aItens,{"D1_NUMLOTE"	, 	SD2->D2_NUMLOTE	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_DTVALID"	} ) >  0  ,   AADD(aItens,{"D1_DTVALID"	, 	SD2->D2_DTVALID	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_QTSEGUM"	} ) >  0  ,   AADD(aItens,{"D1_QTSEGUM"	, 	SD2->D2_QTSEGUM	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_FORNECE"	} ) >  0  ,   AADD(aItens,{"D1_FORNECE"	, 	SD2->D2_CLIENTE	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_LOJA" 		} )	>  0  ,   AADD(aItens,{"D1_LOJA"	, 	SD2->D2_LOJA	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_UNIADU" 	} )	>  0  ,   AADD(aItens,{"D1_UNIADU" 	, 	SD2->D2_UNIADU	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_USDADU" 	} )	>  0  ,   AADD(aItens,{"D1_USDADU" 	, 	SD2->D2_USDADU	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_VALADU" 	} )	>  0  ,   AADD(aItens,{"D1_VALADU" 	, 	SD2->D2_VALADU	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_CANADU" 	} )	>  0  ,   AADD(aItens,{"D1_CANADU" 	, 	SD2->D2_CANADU	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_FRACCA" 	} )	>  0  ,   AADD(aItens,{"D1_FRACCA" 	, 	SD2->D2_FRACCA	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_NICO" 		} )	>  0  ,   AADD(aItens,{"D1_NICO"	, 	SD2->D2_NICO	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_QUANT" 	} )	>  0  ,   AADD(aItens,{"D1_QUANT" 	, 	SD2->D2_QUANT	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_TOTAL" 	} )	>  0  ,   AADD(aItens,{"D1_TOTAL" 	, 	SD2->D2_TOTAL	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_SEGURO" 	} )	>  0  ,   AADD(aItens,{"D1_SEGURO" 	, 	SD2->D2_SEGURO	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_VALFRE"	} ) >  0  ,   AADD(aItens,{"D1_VALFRE"	, 	SD2->D2_VALFRE	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_DESPESA" 	} )	>  0  ,   AADD(aItens,{"D1_DESPESA" , 	SD2->D2_DESPESA	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_NUMSERI" 	} )	>  0  ,   AADD(aItens,{"D1_NUMSERI" , 	SD2->D2_NUMSERI	, NIL})	,	)
			If (Ascan(aItensSD1	, {|x| Alltrim(x) == "D1_LOCALIZ" 	} )	>  0  ,   AADD(aItens,{"D1_LOCALIZ" , 	SD2->D2_LOCALIZ	, NIL})	,	)

			//Permite agregar mas campos de la Tabla SD1 vs SD2
			If lPESD1NCA
				aItemsEx := ExecBlock("F817NCASD1",.F.,.F.)
				For nJ := 1 To Len(aItemsEx)
					aAdd(aItens, aItemsEx[nJ])
				Next
			EndIf

			AADD(aItensTot, aItens)
			
			SD2->(dbSkip())

		Enddo
	RestArea(aAreaA)
Return .T.

/*/{Protheus.doc} lxMxExRcbo
	Verifica si existe recibo relacionado a la Factura.
	@type  Static Function
	@author alfredo.medrano
	@since 26/09/2023
	@version version
	@param cSerieD,	carácter, Serie de la Factura
	@param cDocD, 	carácter, Número de la Factura
	@param cClienD,	carácter, Cliente de la Factura
	@param cLojaD, 	carácter, Tienda de la Factura
	@return lRet, Lógico, Existe recibo relacionado a la Factura
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lxMxExRcbo(cSerieD, cDocD, cClienD, cLojaD)
	Local aAreaA	:= GetArea()
	Local cAliasSF1 := GetNextAlias()
	Local lRet:= .F.
	Local cSerNCA := SuperGetmv( "MV_SERNCA" , .F. , "" ) // Serie de Nota de Cancelación para Docs. Fuera de Periodo	
	

	If !Empty(cSerieD) .and. !Empty(cDocD) .and. !Empty(cClienD) .and. !Empty(cLojaD) .and. !Empty(cSerNCA)
		cSerNCA := Padr(Alltrim(cSerNCA), TamSx3("F1_SERIE")[1], " ")
		//Si el documento seleccionado esta fuera de periodo, revisa si éste ya genero nota de cancelación (NCA) y recibo.
		BeginSQL Alias cAliasSF1
			%noparser%
			SELECT 
				F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA
			FROM
				%table:SF1% SF1
			WHERE
				F1_FILIAL 	=  %xFilial:SF1% 	AND
				F1_SERORIG  =  %Exp:cSerieD%   	AND
				F1_NFORIG  	=  %Exp:cDocD% 	 	AND
				F1_FORNECE  =  %Exp:cClienD% 	AND
				F1_LOJA     =  %Exp:cLojaD% 	AND
				F1_SERIE    =  %Exp:cSerNCA% 	AND
				SF1.%notDel%
		EndSQL
		
		If (!(cAliasSF1)->(EOF()))
			dbSelectArea("SEL")
			SEL->(dbSetOrder(2)) //EL_FILIAL+EL_PREFIXO+EL_NUMERO+EL_PARCELA+EL_TIPO+EL_CLIORIG+EL_LOJORIG
			If SEL->(MsSeek(xFilial("SEL") + (cAliasSF1)->F1_SERIE + (cAliasSF1)->F1_DOC ))
				lRet := .T.
			EndIf
		EndIf
		(cAliasSF1)->(DbCloseArea())
	Endif
	RestArea(aAreaA)

Return lRet
                                                                                         

/*/{Protheus.doc} lxMxDocPen
	Valida si el documento a sustituir se encuentra relacionado a un documento timbrado
	y obtiene su UUID
	@type  Static Function
	@author alfredo.medrano
	@since 103/10/2023
	@version version
	@param nX,		número,		Posición del Docto que se esta procesando.
	@param cDoc, 	carácter, 	Número del documento cancelado.
	@param cSerie,	carácter, 	Serie del documento cancelado.
	@param cEstatus carácter, 	Estatus del documento.
	@return lRet, 	Lógico, 	Existe recibo relacionado a la Factura
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lxMxDocPen(nX, cDoc, cSerie, cEstatus)

	Local lRet 	   := .T.
	Local cDocTimb := ""
	Local UUIDDoc  := ""
	Local cOpeDoc  := ""
	
	Default nX 		:= 0
	Default cDoc 	:= ""
	Default cSerie 	:= ""
	Default cEstatus:= ""

	If cEstatus == "9" // Cancelado ante el SAT, pendiente de cancelación en el sistema. 
		If lxMxValDFP(nX, .T.) // Genera los doctos de cancelación (NCA y Recibo)
			RecLock("SF2", .F.)
			SF2->F2_FLFTEX := "7"  // Cancelado en sistema 
			SF2->(MSUnlock()) 
		Endif
		aRegs[nX, dfActualiza] := .F. // El docto ya esta cancelado ante el SAT, no requiere re-transmisión
		lRet := .F. 
	Else 
		cOpeDoc := F817DOCTIM(cSerie, cDoc, @cDocTimb, @UUIDDoc)
		If cOpeDoc == "T"
			aRegs[nX,dfUUIDDoc] := UUIDDoc
		ElseIf cOpeDoc == "R"
			aRegs[nX,dfMensaje] := STR0121  + cDocTimb + STR0122 //"El documento que sustituye \\ no contiene timbre fiscal(CFDI)." 
			lRet := .F.
		ElseIf cOpeDoc == ""
			aRegs[nX,dfMensaje] := STR0123//"Pendiente de generación de documento sustituto."
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} lxMxActEst
	Actualza los estatus de la tabla SF3 dependiendo el código de 
	respuesta de la cancelación o consulta.
	@type  Static Function
	@author alfredo.medrano
	@since 103/10/2023
	@version version
	@param cEstResp, carácter, Código de respuesta de la cancelación / consulta
	@example
	(examples)
	@see (links_or_references)
/*/
Static function lxMxActEst(cEstResp)
	Local aAreaA   	:= GetArea()
	Local cFilSF3  	:= xFilial("SF3")
	Local cEstdS	:= ""
	Default cEstResp:= ""
	
	dbSelectArea("SF3")
	SF3->(dbSetOrder(6)) //F3_FILIAL+F3_NFISCAL+F3_SERIE
	If SF3->(MsSeek(cFilSF3 + SF2->F2_DOC + SF2->F2_SERIE))
		cEstdS := SF3->F3_STATUS
		If cEstResp $ "3|4|5"  //"3 - Cancelado sin aceptación" //4 - Cancelado con aceptación" //5 - "Plazo vencido"
			cEstdS := ""
		ElseIf cEstResp $ "1|6"  //"1 - En proceso"//" 6 -No cancelable" ==> Documentos relacionados
			cEstdS := "E"
		ElseIf cEstResp =="2" //"2 - Solicitud rechazada"
			cEstdS := "R"
		EndIf
		If SF3->(RecLock( "SF3" , .F.))
			SF3->F3_STATUS := cEstdS
			SF3->(MSUnlock())
		EndIf
	EndIf
	RestArea(aAreaA)
return


/*/{Protheus.doc} lxMxDcMt01
	Valida si el documento contiene Motivo 01, fue cancelado fuera de periodo y contiene el estus 2 rechazada, 
	6 no cancelable y 8 pendiente. 
    Detecta si el documento con estatus 8 (que genero doctos NCA y Recibo con motivo 01) actualizó la tabla SF3
    Caso en el cual no se actualiza la tabla SF3 --> problemas con el pac, desconexión de la red, etc.
	@type  Static Function
	@author user
	@since 14/10/2023
	@version version
	@param nX,	número,		Posición del Docto que se esta procesando.
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function lxMxDcMt01(nX)
	Local aAreaA  := GetArea()
	Local cFilSF3 := xFilial("SF3")
	Local lRet	  := .F.	
	
	If nTipo == 1 .and. aRegs[nX, dfCanFper] .and. SF2->F2_TIPNOTA == "01" .and. SF2->F2_FLFTEX $ "2|6|8" //  rechazada, no cancelable,pendiente acuse
		lRet := .T.
		If SF2->F2_FLFTEX == "8"
			dbSelectArea("SF3")
			SF3->(dbSetOrder(6)) //F3_FILIAL+F3_NFISCAL+F3_SERIE
			If SF3->(dbSeek(cFilSF3+ SF2->F2_DOC+SF2->F2_SERIE))
				If Empty(SF3->F3_MOTIVO) .and. Empty(SF3->F3_STATUS) 
					lRet := .F.
				Endif
			EndIf
		EndIf
	Endif
	RestArea(aAreaA)

Return lRet

/*/{Protheus.doc} LxMxNFSUS
Abre una pantalla de selección con los documentos cancelados que podrán ser sustituidos
con la nueva Factura, si la consulta es utilizada por la rutina FISA817 excluye los 
documentos cancelados fuera de periodo.
Se ejecuta a partir de la consulta específica DOCSUS utilizada en el campo F2_SERMAN,
también utilizada en el grupo de preguntas F817CAN (MV_PAR01) y la rutina MATA468N
dentro de la funnción A468ChgRel()
@type  Function
@author alfredo.medrano
@since 20/08/2024
@version 1
@param N/A
@return  VAR_IXB[1], VAR_IXB[2]
@example
(examples)
@see (links_or_references)
/*/
Function LxMxNFSUS()

	Local aArea 	:= GetArea()
	Local cAliasQry := GetNextAlias()
	Local cEspS		:= Padr(cEspecie, FWSX3Util():GetFieldStruct("F2_ESPECIE")[3], " ")
	Local cTpMov	:= Padr('V', FWSX3Util():GetFieldStruct("F3_TIPOMOV")[3], " ")
	Local cEstS		:= Padr('S', FWSX3Util():GetFieldStruct("F3_STATUS")[3], " ")
	Local cEstA		:= Padr('A', FWSX3Util():GetFieldStruct("F3_STATUS")[3], " ")
	Local cSerNCA 	:= SuperGetmv( "MV_SERNCA" , .F. , "" ) // Serie de Nota de Cancelación para Docs. Fuera de Periodo	
	Local aCordW	:= {125,0,450,635}
	Local aCGD		:= {44,5,90,315}
	Local nX 		:= 0
	Local nJ 		:= 0
	Local nUsado 	:= 0
	Local nPosCols 	:= 0
	Local aCombo 	:= {}
	Local aMyCombo 	:= {}
	Local cCombo 	:= ""
	Local cBusca 	:= space(FWSX3Util():GetFieldStruct("F2_DOC")[3])
	Local cLine		:= ""
	Local aHeadS	:= {}
	Local aHeader	:= {}
	Local aCols		:= {}
	Local bLine 	:= Nil
	Local lOk 		:= .F.
	Local nTotREg 	:= 0
	Local cTitDoc 	:= ""
	Local cTitSer 	:= ""
	Local cTitFech 	:= ""
	Local cStrFil 	:= ""
	Local lFisa817 	:= IsInCallStack("FISA817")
	Local cQuery 	:= ""
	Local cSubQr 	:= ""

	Local oCombo 	:= Nil
	Local oBusca 	:= Nil
	Local oBtn1 	:= Nil
	Local oDlg 		:= Nil
	Local oListBox 	:= Nil
	


	cSerNCA := Padr(Alltrim(cSerNCA), FWSX3Util():GetFieldStruct("F1_SERIE")[3], " ")
	cStrFil	 := "'" +cEstS + "','" + cEstA + "'"

	cQuery := "SELECT  F3_SERIE,F3_NFISCAL,F3_CLIEFOR,F3_LOJA, F3_CNATREC "
	cQuery += "FROM " + RetSqlName("SF3") + " SF3 "
	cQuery += "WHERE SF3.F3_FILIAL='" + xFilial("SF3") + "' AND "
	cQuery += "SF3.F3_TIPOMOV = '" + cTpMov + "'  AND "
	cQuery += "SF3.F3_STATUS IN (" + cStrFil + ") AND "
	cQuery += "SF3.F3_ESPECIE = '" + cEspS + "'   AND "
	cQuery += "SF3.D_E_L_E_T_ = ''"

	If lFisa817 // excluye los documentos cancelados fuera de periodo identificados por la nota de cancelacion NCA.
		iF nTipo == 1 
			cSubQr := "SELECT F1_NFORIG FROM " + RetSqlName("SF1") + " SF1 "
			cSubQr += " WHERE SF1.F1_FILIAL ='" + xFilial("SF1") + "' AND F1_FORNECE = SF3.F3_CLIEFOR AND " 
			cSubQr += " F1_LOJA = SF3.F3_LOJA AND  F1_SERORIG = SF3.F3_SERIE AND "
			cSubQr += " F1_NFORIG = SF3.F3_NFISCAL AND F1_SERIE = '" + cSerNCA + "' AND SF1.D_E_L_E_T_ ='' "
			cQuery += " AND SF3.F3_NFISCAL NOT IN ( " + cSubQr + ")"
		EndIf
	EndIf
	
	cQuery  := ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasQry, .T., .T.)

	Count to nTotREg
		
	If nTotREg > 0
		cTitDoc	:= Alltrim(GetSx3Cache("F3_NFISCAL","X3_TITULO"))
		cTitSer := Alltrim(GetSx3Cache("F3_SERIE","X3_TITULO"))
		cTitFech:= Alltrim(GetSx3Cache("F3_CNATREC","X3_TITULO"))
		//Arreglo con los campos que conforman el browse
		aadd(aHeader,{'F3_SERIE','F3_NFISCAL','F3_CLIEFOR','F3_LOJA','F3_CNATREC'})
		//Arreglo con los campos que serán mostrados en el combo de busqueda
		aadd(aCombo,cTitDoc)
		aadd(aCombo,cTitSer)
		aadd(aCombo,cTitFech)
		//Arreglo con los campos que serán utilizados para las búsquedas
		aadd(aMyCombo, {cTitDoc,'F3_NFISCAL'} )
		aadd(aMyCombo, {cTitSer,'F3_SERIE'} )
		aadd(aMyCombo, {cTitFech,'F3_CNATREC'} )
		//aHeadS  -  Arreglo que contiene el título de los campos y seran mostrados en el encabezado
		For nX :=1 to  len(aHeader[1])
			If X3Usado(aHeader[1][nX])
				nUsado++
				AAdd(aHeadS, GetSx3Cache(aHeader[1][nX],"X3_TITULO")) //Título
			Endif
		Next

		(cAliasQry)->(dbGoTop())
		While (cAliasQry)->(!Eof())
			nPosCols++
			AAdd(aCols, Array(nUsado))
			For nJ := 1 To Len(aHeader[1])
				aCols[nPosCols][nJ] :=  (cAliasQry)->&(aHeader[1][nj])
			Next nJ
			(cAliasQry)->(dbSkip())
		EndDo
		
		cLine := "{"
		For nX:=1 To nUsado
			cLine += "aCols[oListBox:nAt][" + AllTrim(Str(nX)) + "]"
			If nX < nUsado
				cLine += ","
			EndIf
		Next
		cLine += "}"
		bLine := &( "{|| " + cLine + "}" )

		DEFINE MSDIALOG oDlg TITLE STR0127 FROM aCordW[1],aCordW[2] TO aCordW[3],aCordW[4] PIXEL OF oMainWnd //"Documento Sustituye" 

			@ 029,005 SAY STR0128 SIZE 35,07 OF oDlg PIXEL // 'Buscar por:'
			@ 025,045 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 080,013 OF oDlg PIXEL 
			oCombo:bChange := {||lxMxFomSu(@cBusca,aMyCombo,cCombo) }
			@ 025,130 MSGET oBusca VAR cBusca PICTURE "@!"  SIZE 120,10 OF oDlg PIXEL
			@ 045,500 BTNBMP oBtn1 RESOURCE "btpesq" SIZE 025,025 OF oDlg PIXEL ACTION (lxMxBsSus(cBusca, cCombo, aMyCombo,aHeader, aCols, oListBox ) )
			
			oListBox := TWBrowse():New(aCGD[1],aCGD[2],aCGD[4],aCGD[3],,aHeadS,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oListBox:SetArray(aCols)
			oListBox:bLDblClick := { || }
			oListBox:bLine      := bLine

			DEFINE SBUTTON FROM aCGD[3]+55,aCGD[4]-60 TYPE 1 ENABLE OF oDlg ACTION (lOk:=lxMxActSu(aHeader,aCols, oListBox:nAt ),oDlg:End())
			DEFINE SBUTTON FROM aCGD[3]+55,aCGD[4]-30 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())
			ACTIVATE MSDIALOG oDlg CENTERED
	Else
		HELP("   ",1,"LXMEXSUS",,STR0129,1) // "No hay registros relacionados a la informacion seleccionada"
	EndIf
	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return lOk

/*/{Protheus.doc} lxMxFomSu
Inicializa el tamaño (número de carácter permitidos) del campo de búsqueda
dependiendo la opción de búsqueda seleccionada.
@type  Function
@author alfredo.medrano
@since 21/08/2024
@version 1
@param cBusca,    carácter, información a buscar
@param aMyCombo,  array   , Arreglo con los campos que serán utilizados para las búsquedas
@param cCombo ,   carácter, opción seleccionada en el combo de busqueda
@return lRet, lógico
@example
(examples)
@see (links_or_references)
/*/
Static function lxMxFomSu(cBusca,aMyCombo,cCombo)
	Local nCmbLin	:= 0
	Local lRet 		:=.F.
	Default cBusca	:= ""
	Default aMyCombo:= {}
	Default cCombo	:= ""

	nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )

	If nCmbLin > 0
		cBusca:=space(FWSX3Util():GetFieldStruct(aMyCombo[nCmbLin,02])[3])
		lRet:=.T.
	EndIf

Return lRet

/*/{Protheus.doc} lxMxBsSus
Realiza la búsqueda a partir de la opción seleccionada en el combo y en el texto asignado.
@type  Function
@author alfredo.medrano
@since 21/08/2024
@version 1
@param cBusca,	carácter, Información a buscar
@param cCombo,	carácter, Opción seleccionada en el combo de busqueda
@param aMyCombo,array,	  Arreglo con los campos que serán utilizados para las búsquedas
@param aHeader,	array,	  Campos utilizados por la lista de selección
@param aCols,	array,	  Columnas con información de los campos utilizados por la lista de selección
@param oListBox,objeto,	  Objeto de la lista de selección
@return lRet, lógico
@example
(examples)
@see (links_or_references)
/*/
Static Function lxMxBsSus(cBusca, cCombo, aMyCombo,aHeader, aCols, oListBox )
Local nPosLin 	:= 0
Local nPosCpo 	:= 0
Local nLenCmb 	:= 0
Local nCmbLin 	:= 0
Local lRet	  	:=.F.
Default cBusca	:= ""
Default cCombo	:= ""
Default aMyCombo:= {}
Default aHeader	:= {}
Default aCols	:= {}
Default oListBox:= Nil

	nLenCmb := Len(Alltrim(cBusca))
	nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )

	If nCmbLin > 0
		nPosCpo := AScan(aHeader[1], { |x| AllTrim(x) == aMyCombo[nCmbLin,02] })
		If nPosCpo > 0
			nPosLin := aScan( aCols, { |x| SubStr(Alltrim(UPPER(x[nPosCpo])),1,nLenCmb) == Alltrim(cBusca)} )
		EndIf
	EndIf
	If nPosLin >= 1
		oListBox:nAt := nPosLin
		lRet:= .T.
	Else
		MSGINFO( STR0130, STR0115 ) //STR0130// "No se encontró información relacionada a los criterios de búsqueda." // "Aviso"
	EndIf
	oListBox:Refresh()

Return lRet

/*/{Protheus.doc} lxMxActSu
Asigna la serie (F3_SERIE) y el número de documento(F3_NFISCAL) del documento seleccionado
a la variable publica VAR_IXB.
@type  Function
@author alfredo.medrano
@since 21/08/2024
@version 1
@param aHeader, array, campos utilizados por la lista de selección
@param aCols ,  array, columnas con información de los campos utilizados por la lista de selección
@param nNatS ,  número, posición de la línea seleccionada en la lista.
@return lRet, lógico
@example
(examples)
@see (links_or_references)
/*/
static Function lxMxActSu(aHeader,aColsD, nNatS )
	Local nPosDoc	:= 0
	Local nPosSer	:= 0
	Local lRet 		:=.F.
	Default aHeader := {}
	Default aColsD  := {}
	Default nNatS	:= 0

	nPosDoc	:= AScan(aHeader[1], { |x| AllTrim(x) == 'F3_NFISCAL' })
	nPosSer	:= AScan(aHeader[1], { |x| AllTrim(x) == 'F3_SERIE' })
	If nPosDoc > 0 .and. nPosSer > 0
		VAR_IXB := { aColsD[nNatS,nPosSer], aColsD[nNatS,nPosDoc] }
		lRet:= .T.
	EndIf

Return lRet
