#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA088.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FISA088    ³ Autor ³ Mayra.Camargo             ³ Data ³ 21/04/14   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generación de Informacion para DIOT                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA088()                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³               ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³  Data  ³     BOPS    ³            Motivo da Alteracao            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³25/09/17³TSSERMI01-142³Se migran todos los cambios pendientes de  ³±±
±±³            ³        ³             ³version 12.1.07 .                          ³±±
±±³LuisEnriquez³12/12/17³DMINA-378    ³Defecto DMINA-1338 Se modifica la funcion  ³±±
±±³            ³        ³             ³FS88ImpOP para llenar en arreglo aDocums el³±±
±±³            ³        ³             ³tipo y fecha de datos de tabla SEK. (MEX)  ³±±
±±³Alf. Medrano³17/05/18³DMINA-2612   ³En Fun TodoOk agrega Valid para Filial Null³±±
±±³            ³        ³             ³En F088GERA se inicializan Variab(array) de³±±
±±³            ³        ³             ³Pagos por cada Filial procesada. se Utiliza³±±
±±³            ³        ³             ³Xfilial para asignar filiales a CDX y CE8. ³±±
±±³Alf. Medrano³05/06/18³DMINA-3199   ³En Fun FS088NCP() se obtiene la moneda del ³±±
±±³            ³        ³             ³campo E5_MOEDA para obtener tasa del día y ³±±
±±³            ³        ³             ³realizar conversion en los valores de los  ³±±
±±³            ³        ³             ³impuestos de NCP. También asigna condicion ³±±
±±³            ³        ³             ³en query E5_SITUACA<> ‘C’ para no incluir  ³±±
±±³            ³        ³             ³NCP canceladas.                            ³±±
±±³M.Camargo   ³09/01/19³DMINA-5316   ³En Fun FS088Impop() se coloca conidión para³±±
±±³            ³        ³             ³comprobar si el documento ya fue debitado. ³±±
±±³            ³        ³             ³Si no ha sido debitado, no se considera    ³±±
±±³            ³        ³             ³para generar registros del DIOT.           ³±±
±±³            ³        ³             ³Se modifica FS088FACIMP para buscar en SA2 ³±±
±±³            ³        ³             ³RFC del proveedor a partir de los datos en ³±±
±±³            ³        ³             ³la tabla RSE.                              ³±±
±±³Luis Eníquez³14/03/19³DMINA-6191   ³Se modifican funs. FS088SE2 y FS088GERA pa-³±±
±±³            ³        ³             ³ra llenado de campo CE8_CASE8 para acumula-³±±
±±³            ³        ³             ³de IVA fronterizo del 8%. (MEX)            ³±±
±±³Alf. Medrano³21/05/19³DMINA-6602   ³En Fun FS088SM0 se obtiene el número de suc³±±
±±³            ³        ³             ³-ursales que seran permitidas para su selec³±±
±±³            ³        ³             ³ción. MEX                                  ³±±
±±³Alf. Medrano³30/05/19³DMINA-6602   ³En Fun FS088SM0 se asigna a 60 el num de   ³±±
±±³            ³        ³             ³caracteres permitidos en la pregunta       ³±±
±±³            ³        ³             ³MV_PAR02. Se realiza tratamiento para la   ³±±
±±³            ³        ³             ³filial origen en el proceso de diot. en fun³±±
±±³            ³        ³             ³FS088DECUCC se utiliza el campo E5_FILORIG ³±±
±±³            ³        ³             ³en la condición del query. en fun FS88IMPOP³±±
±±³            ³        ³             ³Se utiliza la filial de la tabla SE5 para  ³±±
±±³            ³        ³             ³para filtrar la tabla SEK. MEX	          ³±±
±±³            ³        ³             ³Se asigna el num de fil permitidas para se-³±±
±±³            ³        ³             ³-lección en fun f_Opcoes                   ³±±
±±³  Marco A.  ³02/09/19³ DMINA-7263  ³Se realiza modificacion en la funcion      ³±±
±±³            ³        ³             ³FS088SE2() para cambiar el campo filial en ³±±
±±³            ³        ³             ³el DBSeek() a la tabla SE2 por el valor    ³±±
±±³            ³        ³             ³E2_FILORIG y se asigna variable cFilSD1 con³±±
±±³            ³        ³             ³el valor F1_FILIAL.                        ³±±
±±³  Marco A.  ³04/10/19³  DMINA-7514 ³Se modifica la funcion SelMovCE8, para acu-³±±
±±³            ³        ³             ³mular los valores de las bases en base al  ³±±
±±³            ³        ³             ³Tipo Tercero en el proveedor.              ³±±
±±³  Marco A.  ³24/10/19³  DMINA-7649 ³Se realizan multiples correcciones para es-³±±
±±³            ³        ³             ³tabilizar el DIOT en ambientes con finan-  ³±±
±±³            ³        ³             ³ciero compartido.                          ³±±
±±³  Marco A.  ³29/11/19³  DMINA-7791 ³Se implementa la generacion de informacion ³±±
±±³            ³        ³             ³para el DIOT a partir de la tabla SE2 y no ³±±
±±³            ³        ³             ³de SF1/SD1.                                ³±±
±±³  Marco A.  ³28/05/20³  DMINA-9118 ³Se implementa la generacion de informacion ³±±
±±³            ³        ³             ³para el DIOT en ambientes con financiero   ³±±
±±³            ³        ³             ³exclusivo que realicen pagos entre sucursa-³±±
±±³            ³        ³             ³les.                                       ³±±
±±³  Marco A.  ³06/09/20³  DMINA-9987 ³Se modifica la funcion FS088NCP() para que ³±±
±±³            ³        ³             ³sea tomada la tasa del campo E5_TXMOEDA en ³±±
±±³            ³        ³             ³el proceso de compensacion de NF vs NCP y  ³±±
±±³            ³        ³             ³que en este se modifique la tasa.          ³±±
±±³ José Glez  ³10/09/20³  DMINA-9995 ³Se modifica la función FS88ImpOP() para que³±±
±±³            ³        ³             ³el tipo de Documento PA también sume el    ³±±
±±³            ³        ³             ³total del Pago del campo SEK->EK_VLMOED1   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA088()
	
	Local aGetArea 	:= GetArea()
	Local aSays   	:= { }
	Local aButtons	:= { }
	Local nOpca   	:= 0
	Local cPerg   	:= "FISA088"
	Local cCadastro	:= STR0001 // "Generación de la Declaración Informativa de Operaciones con Terceros"
	Local cDIOTver  := "1" //Versión del DIOT
	
	Private cMes    := ''
	Private cAnio   := ''
	Private cMesAno := ''
	Private cSucur  := ''
	Private dFecIni := CToD("  /  /  ")
	Private dFecFin := CToD("  /  /  ")
	Private lAutomato := isblind()
	If cPaisLoc == "MEX"
		cDIOTver := SuperGetMV("MV_DIOTVER", .F., "1")
	EndIf
	aAdd(aSays, STR0002) // "Esta rutina genera la información necesaria para la presentación de  DIOT."
	aAdd(aSays, STR0003) // "Después de este proceso, se podrá ejecutar la Generación del Archivo y los Informes"
	aAdd(aSays, STR0004) // "necesarios."

	aAdd(aButtons, {5, .T., {|| Pergunte(cPerg, .T. ) } } )
	aAdd(aButtons, {1, .T., {|o| nOpca := 1, IIf(TodoOK(cPerg),FechaBatch(), nOpca := 0)}})
	aAdd(aButtons, {2, .T., {|o| FechaBatch() }} )

	If !lAutomato
		FormBatch( cCadastro, aSays, aButtons )

		If nOpca == 1 //Ejecuta el proceso
			Processa({|| FS088GERA(cDIOTver) },OemToAnsi(STR0005)) //"Procesando..."
		EndIf
	Else
		If TodoOK(cPerg)
			FS088GERA(cDIOTver)
		Endif
	EndIf

	RestArea(aGetArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TodoOK    ºAutor  ³M.Camargo           º Data ³  21/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacion de los datos antes de Ejecutar el proceso        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TodoOK(cPerg)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros         ³
	//³ MV_PAR01 // Mes y Año del periodo a procesar ³
	//³ MV_PAR02 // Sucursales a procesar            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte(cPerg,.F.)
	
	cMesAno := MV_PAR01
	cSucur  := MV_PAR02
	cMes    := StrZero(Val(Left(cMesAno,2)),2)
	cAnio   := Right(cMesAno,4)
	cLisSuc := AllTrim(cSucur)

	If Val(cMes) < 1 .Or. Val(cMes) > 12
		MsgInfo(STR0006) // "El mes debe ser de 1 a 12!"
		Return .F.
	EndIf

	If Val(cAnio) < 1900
		MsgInfo(STR0007) // "El año debe ser mayor a 1900!"
		Return .F.
	EndIf

	If !Empty(cLisSuc)
	    cSucur := FS088Traduce(cLisSuc)
	Else
		MsgInfo(STR0035) // "Seleccione al menos una sucursal "
		Return .F.
	EndIf

	dFecIni := Ctod("01/"+ cMes+ "/" +Substr(cAnio,3,2)+"/")
	dFecFin := Ctod(StrZero(f_UltDia(dFecIni), 02) + "/" + cMes + "/" + SubStr(cAnio, 3, 2))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FS088GERA ºAutor  ³Gpe Santacruz       º Data ³  21/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Proceso                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FISA088                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS088GERA(cDIOTver)

	Local cFilTmp	:= cFilAnt
	Local nX      	:= 0
	Local nK      	:= 0
	Local lInf    	:= .F.
	Local aArrFil 	:= Separa(StrTran(cSucur, "'", ""), ",")
	Local lBase8	:= (CE8->(ColumnPos("CE8_BASE8")) > 0)
	Local lMesCal	:= (CE8->(ColumnPos("CE8_MESCAL")) > 0)
	Local cMesSigte	:= ""
	Local lSepara	:= .F.
	Local lCpoBasA  := CE8->(ColumnPos("CE8_BASDVA")) > 0
	Local lCpoBasB  := CE8->(ColumnPos("CE8_BASDVB")) > 0
	Local lCpoBasC  := CE8->(ColumnPos("CE8_BASDVC")) > 0
	Local lCpoIACA  := CE8->(ColumnPos("CE8_IVAACA")) > 0
	Local lCpoIACB  := CE8->(ColumnPos("CE8_IVAACB")) > 0
	Local lCpoIACC  := CE8->(ColumnPos("CE8_IVAACC")) > 0
	Local lCpoIACD  := CE8->(ColumnPos("CE8_IVAACD")) > 0
	Local lCpoIACE  := CE8->(ColumnPos("CE8_IVAACE")) > 0
	Local lCpoIACF  := CE8->(ColumnPos("CE8_IVAACF")) > 0
	Local lCpoIACG  := CE8->(ColumnPos("CE8_IVAACG")) > 0
	Local lCpoIACH  := CE8->(ColumnPos("CE8_IVAACH")) > 0
	Local lCpoIACI  := CE8->(ColumnPos("CE8_IVAACI")) > 0
	Local lCpoIACJ  := CE8->(ColumnPos("CE8_IVAACJ")) > 0
	Local lCpoINAA  := CE8->(ColumnPos("CE8_IVANAA")) > 0 
	Local lCpoINAB  := CE8->(ColumnPos("CE8_IVANAB")) > 0
	Local lCpoINAD  := CE8->(ColumnPos("CE8_IVANAD")) > 0
	Local lCpoINAE  := CE8->(ColumnPos("CE8_IVANAE")) > 0
	Local lCpoINAF  := CE8->(ColumnPos("CE8_IVANAF")) > 0
	Local lCpoINAH  := CE8->(ColumnPos("CE8_IVANAH")) > 0
	Local lCpoINAI  := CE8->(ColumnPos("CE8_IVANAI")) > 0
	Local lCpoINAJ  := CE8->(ColumnPos("CE8_IVANAJ")) > 0
	Local lCpoINAL  := CE8->(ColumnPos("CE8_IVANAL")) > 0
	Local lCpoINAM  := CE8->(ColumnPos("CE8_IVANAM")) > 0
	Local lCpoINAN  := CE8->(ColumnPos("CE8_IVANAN")) > 0
	Local lCpoINAP  := CE8->(ColumnPos("CE8_IVANAP")) > 0
	Local lCpoINAQ  := CE8->(ColumnPos("CE8_IVANAQ")) > 0
	Local lCpoINAR  := CE8->(ColumnPos("CE8_IVANAR")) > 0
	Local lCpoINAT  := CE8->(ColumnPos("CE8_IVANAT")) > 0
	Local nPosRet 	:= 23 //posicion IVA Retenido
	
	Private _CLISIVAS 	:= AllTrim(GetMV("MV_LISIVAS")) //Numeros de Libros Fiscales de Impuestos IVA
	Private _CIMPRET  	:= AllTrim(GetMV("MV_IVARET")) //Numeros de Libros Fiscales de Impuestos Retenidos
	Private cIEPS     	:= SubStr(GetNewPar("MV_IEPS", ""), 1, 3) //Codigo de Impuesto del IEPS
	Private _cCpoIEPS	:= ''
	Private _cCpoIVC  	:= ''
	Private aPagos   	:= {}
	Private aPgosDIOT	:= {}
	Private aPgoDet   	:= {}
	Private aNCP      	:= {}
	Private aError    	:= {}
	Private lEsImport 	:= EsImporta()
	Private aDocsOP		:= {}
	Private lCompSEK	:= FWModeAccess("SEK", 1) == "C" .Or. FWModeAccess("SEK", 2) == "C" .Or. FWModeAccess("SEK", 3) == "C"
	Private lDIOTRet	:= (cPaisLoc == "MEX" .And. GetNewPar("MV_DIOTRET", .F.)) //Informar IVA y Retención en el mismo mes (.T. / .F.)

	Default cDIOTver	:= "1"
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aPgoDet                              ³
	//³                                     ³
	//³1 - Factura                          ³
	//³2 - Serie                            ³
	//³3 - Nunero de parcialidad            ³
	//³4 - Proveedor                        ³
	//³5 - Tienda                           ³
	//³6 - Fecha emision                    ³
	//³7 - Num de OP o docto con que sepago ³
	//³8 - Tipo de documento con que se pago³
	//³9 - Fecha de pago                    ³
	//³10 - Importe de pago                 ³
	//³11 - Tipo de pago                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	
	DbSelectArea("CDX")
	DbSelectArea("CE8")

	DbSelectArea("SFB")
	DbSetOrder(1) //FB_FILIAL + FB_CODIGO

	SFB->(DBSeek(xFilial("SFB") + "IVC"))
	_cCpoIVC := AllTrim(SFB->FB_CPOLVRO)

	SFB->(DBSeek(xFilial("SFB") + cIEPS))
	_cCpoIEPS := AllTrim(SFB->FB_CPOLVRO)

	If Val(cMes) < 12
		cMesSigte := StrZero(Val(cMes)+1,2) + cAnio
	Else
		cMesSigte := "01" + StrZero(Val(cAnio)+1,4)
	EndIf

	ProcRegua(3+len(aArrFil))

	For nK := 1 To Len(aArrFil)
	 	aPagos		:= {}
		aPgosDIOT	:= {}
	 	aPgoDet   	:= {}
	 	aNCP 	  	:= {}
	 	cFilAnt		:= aArrFil[nK]
		
		If nK == 1
			IncProc(STR0008 + aArrFil[nK]) // "Limpia movimientos del periodo de la filial : "
			FS088LIMPIA()
		EndIf
		
		IncProc(STR0009 + aArrFil[nK]) // "Generando Deducciones: "
		FS088DEDUCC()
		
		IncProc(STR0010 + aArrFil[nK]) // "Calculando proporciones de Deducciones de la filial: "
		If cDIOTver == "2"
			FS088SE2V2()
		Else
			FS088SE2()		
		EndIf

		If lEsImport //Si hay modulo de impotacion analiza las facturas de impuestos
			FS88FACIMP(cDIOTver)
			FS88EXTRA(cDIOTver) //Pedimentos de extraccion por pedimento
		EndIf

		IncProc(STR0011 + aArrFil[nK]) // "Calculando impuestos de Notas de Credito de la filial: "
		
		If cDIOTver == "2"
			nPosRet := 54
			FS088NCPV2()
		Else
			FS088NCP()
		EndIf

		IncProc(STR0012 + aArrFil[nK]) // "Grabando en tablas de la filial: "
		If cDIOTver <> "2"
			FS088RECPAIS() //Obtiene clave del pais
		EndIf

		DbSelectArea("CE8")
		For nX := 1 To Len(aPgosDIOT)
			lSepara := (!lDIOTRet .And. aPgosDIOT[nX,nPosRet] > 0 .And. lMesCal) // Separa Retención de pago e impuesto IVA
			RecLock("CE8", .T.)
				CE8->CE8_FILIAL	:= xFilial("CE8")
				CE8->CE8_MESANO	:= cMes+cAnio
				CE8->CE8_NUMDOC	:= aPgosDIOT[nX,2]
				CE8->CE8_SERIE	:= aPgosDIOT[nX,3]
				CE8->CE8_PARCEL	:= aPgosDIOT[nX,4]
				CE8->CE8_PROV	:= aPgosDIOT[nX,5]
				CE8->CE8_TIENDA	:= aPgosDIOT[nX,6]
				CE8->CE8_FECREG	:= dDataBase
				CE8->CE8_FECDOC	:= aPgosDIOT[nX,13]
				If lMesCal
					CE8->CE8_MESCAL	:= cMes+cAnio
				EndIf
				If cDIOTver == "2"
					CE8->CE8_TIPTER	:= aPgosDIOT[nX,8]
					CE8->CE8_TIPOPE	:= aPgosDIOT[nX,9]
					CE8->CE8_RFC	:= aPgosDIOT[nX,10]
					CE8->CE8_IDFISC	:= aPgosDIOT[nX,11]
					CE8->CE8_PAIS	:= aPgosDIOT[nX,12]
					
					If !lSepara
						//VALOR DE LOS ACTOS O ACTIVIDADES
						CE8->CE8_BA1011 := aPgosDIOT[nX,14]
						CE8->CE8_BASE8  := aPgosDIOT[nX,15]
						CE8->CE8_BASE10 := aPgosDIOT[nX,16]
						CE8->CE8_BI1011 := aPgosDIOT[nX,17]
						CE8->CE8_BA1516 := aPgosDIOT[nX,18]
						CE8->CE8_BI1516 := aPgosDIOT[nX,19]
						CE8->CE8_BASE15 := aPgosDIOT[nX,20]
						
						If lCpoBasA
							CE8->CE8_BASDVA := aPgosDIOT[nX,21]
						EndIf
						If lCpoBasB
							CE8->CE8_BASDVB := aPgosDIOT[nX,22]
						EndIf
						If lCpoBasC
							CE8_BASDVC := aPgosDIOT[nX,23]
						EndIf
						//IVA ACREDITABLE
						If lCpoIACA
							CE8->CE8_IVAACA := aPgosDIOT[nX,24]
						EndIf
						If lCpoIACB
							CE8->CE8_IVAACB := aPgosDIOT[nX,25]
						EndIf
						If lCpoIACC
							CE8->CE8_IVAACC := aPgosDIOT[nX,26]
						EndIf
						If lCpoIACD
							CE8->CE8_IVAACD := aPgosDIOT[nX,27]
						EndIf 
						If lCpoIACE
							CE8->CE8_IVAACE := aPgosDIOT[nX,28]
						EndIf
						If lCpoIACF
							CE8->CE8_IVAACF := aPgosDIOT[nX,29]
						EndIf
						If lCpoIACG
							CE8->CE8_IVAACG := aPgosDIOT[nX,30]
						EndIf
						If lCpoIACH
							CE8->CE8_IVAACH := aPgosDIOT[nX,31]
						EndIf
						If lCpoIACI
							CE8->CE8_IVAACI := aPgosDIOT[nX,32]
						EndIf
						If lCpoIACJ
							CE8->CE8_IVAACJ := aPgosDIOT[nX,33]
						EndIf
						//IVA NO ACREDITABLE
						If lCpoINAA
							CE8->CE8_IVANAA := aPgosDIOT[nX,34]
						EndIf
						If lCpoINAB
							CE8->CE8_IVANAB := aPgosDIOT[nX,35]
						EndIf
						If lCpoINAD
							CE8->CE8_IVANAD := aPgosDIOT[nX,37]
						EndIf
						If lCpoINAE
							CE8->CE8_IVANAE:= aPgosDIOT[nX,38]
						EndIf
						If lCpoINAF
							CE8->CE8_IVANAF := aPgosDIOT[nX,39]
						EndIf
						If lCpoINAH
							CE8->CE8_IVANAH := aPgosDIOT[nX,41]
						EndIf
						If lCpoINAI
							CE8->CE8_IVANAI := aPgosDIOT[nX,42]
						EndIf
						If lCpoINAJ
							CE8->CE8_IVANAJ := aPgosDIOT[nX,43]
						EndIf
						If lCpoINAL
							CE8->CE8_IVANAL := aPgosDIOT[nX,45]
						EndIf
						If lCpoINAM
							CE8->CE8_IVANAM := aPgosDIOT[nX,46]
						EndIf	
						If lCpoINAN
							CE8->CE8_IVANAN := aPgosDIOT[nX,47]
						EndIf	
						If lCpoINAP
							CE8->CE8_IVANAP := aPgosDIOT[nX,49]
						EndIf	
						If lCpoINAQ
							CE8->CE8_IVANAQ := aPgosDIOT[nX,50]
						EndIf		
						If lCpoINAR
							CE8->CE8_IVANAR := aPgosDIOT[nX,51]
						EndIf	
						If lCpoINAT
							CE8->CE8_IVANAT := aPgosDIOT[nX,53]
						EndIf																					
						//Exento
						CE8->CE8_BASIEX	:= aPgosDIOT[nX,55]
						CE8->CE8_BASEEX	:= aPgosDIOT[nX,56]
						//IVA 0%
						CE8->CE8_BASE0 	:= aPgosDIOT[nX,57]
						//Base No Objeto IVA - Proveedor Nacional
						CE8->CE8_VALTOT := aPgosDIOT[nX,58]
						//Base No Objeto IVA - Proveedor Extranjero
						CE8->CE8_IVADEV := aPgosDIOT[nX,59]
					EndIf
					//Retenciones
					CE8->CE8_IVARET	:= aPgosDIOT[nX,54]
					If Len(aPgosDIOT[nX]) >= 61
						CE8->CE8_TIPO	:= aPgosDIOT[nX,61]
					EndIf
				Else
					CE8->CE8_RFC	:= aPgosDIOT[nX,24]
					CE8->CE8_IDFISC	:= aPgosDIOT[nX,25]
					CE8->CE8_TIPTER	:= aPgosDIOT[nX,26]
					CE8->CE8_TIPOPE	:= aPgosDIOT[nX,27]
					CE8->CE8_PAIS	:= aPgosDIOT[nX,28]
					CE8->CE8_VALTOT	:= IIf(!lSepara, aPgosDIOT[nX,8], 0)
					CE8->CE8_BI1516	:= IIf(!lSepara, aPgosDIOT[nX,22], 0)
					CE8->CE8_BASE15	:= IIf(!lSepara, aPgosDIOT[nX,18], 0)
					CE8->CE8_BA1011	:= IIf(!lSepara, aPgosDIOT[nX,17], 0)
					CE8->CE8_BASE10	:= IIf(!lSepara, aPgosDIOT[nX,16], 0)
					CE8->CE8_BA1516	:= IIf(!lSepara, aPgosDIOT[nX,19], 0)
					CE8->CE8_BI1011	:= IIf(!lSepara, aPgosDIOT[nX,21], 0)
					CE8->CE8_BASIEX	:= IIf(!lSepara, aPgosDIOT[nX,20], 0)
					CE8->CE8_BASE0 	:= IIf(!lSepara, aPgosDIOT[nX,15], 0)
					CE8->CE8_BASEEX	:= IIf(!lSepara, aPgosDIOT[nX,14], 0)
					CE8->CE8_IVARET	:= aPgosDIOT[nX,23]
					CE8->CE8_TIPO	:= aPgosDIOT[nX,29]
					CE8->CE8_IVAPAG	:= IIf(!lSepara, aPgosDIOT[nX,30], 0)
					CE8->CE8_IVPAGI	:= IIf(!lSepara, aPgosDIOT[nX,31], 0)
					If lBase8
						CE8->CE8_BASE8	:= IIf(!lSepara, aPgosDIOT[NX,32], 0)
					EndIf
				EndIf

			CE8->(MsUnLock())

			If lSepara
				RecLock("CE8", .T.)
				CE8->CE8_FILIAL	:= xFilial("CE8")
				CE8->CE8_MESANO	:= cMesSigte
				CE8->CE8_NUMDOC	:= aPgosDIOT[nX,2]
				CE8->CE8_SERIE	:= aPgosDIOT[nX,3]
				CE8->CE8_PARCEL	:= aPgosDIOT[nX,4]
				CE8->CE8_PROV	:= aPgosDIOT[nX,5]
				CE8->CE8_TIENDA	:= aPgosDIOT[nX,6]
				CE8->CE8_FECDOC	:= aPgosDIOT[nX,13]
				CE8->CE8_FECREG	:= dDataBase
				CE8->CE8_MESCAL	:= cMes+cAnio
				CE8->CE8_IVARET	:= 0

				If cDIOTver == "2"
					CE8->CE8_TIPTER	:= aPgosDIOT[nX,8]
					CE8->CE8_TIPOPE	:= aPgosDIOT[nX,9]
					CE8->CE8_RFC	:= aPgosDIOT[nX,10]
					CE8->CE8_IDFISC	:= aPgosDIOT[nX,11]
					CE8->CE8_PAIS	:= aPgosDIOT[nX,12]
					CE8->CE8_FECDOC	:= aPgosDIOT[nX,13]
					//VALOR DE LOS ACTOS O ACTIVIDADES
					CE8->CE8_BA1011 := aPgosDIOT[nX,14]
					CE8->CE8_BASE8  := aPgosDIOT[nX,15]
					CE8->CE8_BASE10 := aPgosDIOT[nX,16]
					CE8->CE8_BI1011 := aPgosDIOT[nX,17]
					CE8->CE8_BA1516 := aPgosDIOT[nX,18]
					CE8->CE8_BI1516 := aPgosDIOT[nX,19]
					CE8->CE8_BASE15 := aPgosDIOT[nX,20]
					If lCpoBasA
						CE8->CE8_BASDVA := aPgosDIOT[nX,21]
					EndIf
					If lCpoBasB
						CE8->CE8_BASDVB := aPgosDIOT[nX,22]
					EndIf
					If lCpoBasC
						CE8_BASDVC := aPgosDIOT[nX,23]
					EndIf
					//IVA ACREDITABLE
					If lCpoIACA
						CE8->CE8_IVAACA := aPgosDIOT[nX,24]
					EndIf
					If lCpoIACB
						CE8->CE8_IVAACB := aPgosDIOT[nX,25]
					EndIf
					If lCpoIACC
						CE8->CE8_IVAACC := aPgosDIOT[nX,26]
					EndIf
					If lCpoIACD
						CE8->CE8_IVAACD := aPgosDIOT[nX,27]
					EndIf 
					If lCpoIACE
						CE8->CE8_IVAACE := aPgosDIOT[nX,28]
					EndIf
					If lCpoIACF
						CE8->CE8_IVAACF := aPgosDIOT[nX,29]
					EndIf
					If lCpoIACG
						CE8->CE8_IVAACG := aPgosDIOT[nX,30]
					EndIf
					If lCpoIACH
						CE8->CE8_IVAACH := aPgosDIOT[nX,31]
					EndIf
					If lCpoIACI
						CE8->CE8_IVAACI := aPgosDIOT[nX,32]
					EndIf
					If lCpoIACJ
						CE8->CE8_IVAACJ := aPgosDIOT[nX,33]
					EndIf
					//IVA NO ACREDITABLE
					If lCpoINAA
						CE8->CE8_IVANAA := aPgosDIOT[nX,34]
					EndIf
					If lCpoINAB
						CE8->CE8_IVANAB := aPgosDIOT[nX,35]
					EndIf
					If lCpoINAD
						CE8->CE8_IVANAD := aPgosDIOT[nX,37]
					EndIf
					If lCpoINAE
						CE8->CE8_IVANAE:= aPgosDIOT[nX,38]
					EndIf
					If lCpoINAF
						CE8->CE8_IVANAF := aPgosDIOT[nX,39]
					EndIf
					If lCpoINAH
						CE8->CE8_IVANAH := aPgosDIOT[nX,41]
					EndIf
					If lCpoINAI
						CE8->CE8_IVANAI := aPgosDIOT[nX,42]
					EndIf
					If lCpoINAJ
						CE8->CE8_IVANAJ := aPgosDIOT[nX,43]
					EndIf
					If lCpoINAL
						CE8->CE8_IVANAL := aPgosDIOT[nX,45]
					EndIf
					If lCpoINAM
						CE8->CE8_IVANAM := aPgosDIOT[nX,46]
					EndIf	
					If lCpoINAN
						CE8->CE8_IVANAN := aPgosDIOT[nX,47]
					EndIf	
					If lCpoINAP
						CE8->CE8_IVANAP := aPgosDIOT[nX,49]
					EndIf	
					If lCpoINAQ
						CE8->CE8_IVANAQ := aPgosDIOT[nX,50]
					EndIf		
					If lCpoINAR
						CE8->CE8_IVANAR := aPgosDIOT[nX,51]
					EndIf	
					If lCpoINAT
						CE8->CE8_IVANAT := aPgosDIOT[nX,53]
					EndIf																						
					//Exento
					CE8->CE8_BASIEX	:= aPgosDIOT[nX,55]
					CE8->CE8_BASEEX	:= aPgosDIOT[nX,56]
					//IVA 0%
					CE8->CE8_BASE0 	:= IIf(!lSepara, aPgosDIOT[nX,57], 0)
					//Base No Objeto IVA - Proveedor Nacional
					CE8->CE8_VALTOT := IIf(!lSepara, aPgosDIOT[nX,58], 0)
					//Base No Objeto IVA - Proveedor Extranjero
					CE8->CE8_IVADEV := IIf(!lSepara, aPgosDIOT[nX,59], 0)

				Else

					CE8->CE8_RFC	:= aPgosDIOT[nX,24]
					CE8->CE8_IDFISC	:= aPgosDIOT[nX,25]
					CE8->CE8_TIPTER	:= aPgosDIOT[nX,26]
					CE8->CE8_TIPOPE	:= aPgosDIOT[nX,27]
					CE8->CE8_PAIS	:= aPgosDIOT[nX,28]
					CE8->CE8_VALTOT	:= aPgosDIOT[nX,8]
					CE8->CE8_BI1516	:= aPgosDIOT[nX,22]
					CE8->CE8_BASE15	:= aPgosDIOT[nX,18]
					CE8->CE8_BA1011	:= aPgosDIOT[nX,17]
					CE8->CE8_BASE10	:= aPgosDIOT[nX,16]
					CE8->CE8_BA1516	:= aPgosDIOT[nX,19]
					CE8->CE8_BI1011	:= aPgosDIOT[nX,21]
					CE8->CE8_BASIEX	:= aPgosDIOT[nX,20]
					CE8->CE8_BASE0 	:= aPgosDIOT[nX,15]
					CE8->CE8_BASEEX	:= aPgosDIOT[nX,14]
					CE8->CE8_IVARET	:= 0
					CE8->CE8_TIPO	:= aPgosDIOT[nX,29]
					CE8->CE8_IVAPAG	:= aPgosDIOT[nX,30]
					CE8->CE8_IVPAGI	:= aPgosDIOT[nX,31]
					If lBase8
						CE8->CE8_BASE8	:= aPgosDIOT[NX,32]
					EndIf
				EndIf

				CE8->(MsUnLock())
			EndIf

			lInf := .T.
		Next nX

		DbSelectArea("CDX")
		For nX := 1 To Len(aPgoDet)
			RecLock("CDX",.T.)
				cdx->CDX_FILIAL	:= xFilial("CDX")
				cdx->CDX_MESANO	:= cMes + cAnio
				cdx->CDX_NUMDOC	:= aPgoDet[NX,1]
				cdx->CDX_SERIE 	:= aPgoDet[NX,2]
				cdx->CDX_PARCEL	:= aPgoDet[NX,3]
				cdx->CDX_PROV  	:= aPgoDet[NX,4]
				cdx->CDX_TIENDA	:= aPgoDet[NX,5]
				cdx->CDX_FECEMI	:= aPgoDet[NX,6]
				cdx->CDX_DOCPGO	:= aPgoDet[NX,7]
				cdx->CDX_TIPPGO	:= aPgoDet[NX,8]
				cdx->CDX_FECDOC	:= aPgoDet[NX,9]
				cdx->CDX_IMPPGO	:= aPgoDet[NX,10]
				cdx->CDX_TIPO 	:= aPgoDet[NX,11]
			cdx->(MsUnLock())
		Next nX

		For nX := 1 To Len(aNCP)
			cRFC	:= ''
			cID		:= ''
			cPai	:= ''
			cTipT	:= ''
			cTipO	:= ''

			If SA2->(DBSeek(xFilial("SA2") + aNCP[nX,3] + aNCP[nX,4]))
				cRFC	:= SA2->A2_CGC
				cID		:= SA2->A2_IDFISCA
				cTipT	:= SA2->A2_TIPOTER
				cTipO	:= SA2->A2_TPOPER
				cPai	:= SA2->A2_PAIS
			EndIf

			If VldRegistro(aNCP[nX,3] + " " + aNCP[nX,4], cRfc, cID, cTipT, cTipO, cPai)
				DbSelectArea("CE8")
				RecLock("CE8", .T.)
					CE8->CE8_FILIAL := xFilial("CE8")
					CE8->CE8_MESANO := cMes+cAnio
					CE8->CE8_NUMDOC	:= aNCP[nX,1]
					CE8->CE8_SERIE	:= aNCP[nX,2]
					CE8->CE8_PROV	:= aNCP[nX,3]
					CE8->CE8_TIENDA	:= aNCP[nX,4]
					CE8->CE8_FECDOC	:= aNCP[nX,5]
					CE8->CE8_RFC 	:= cRFC //OBLIGATORIO SI TIPOTER = 04
					CE8->CE8_IDFISC	:= cID
					CE8->CE8_TIPTER	:= cTipT
					CE8->CE8_TIPOPE	:= cTipO
					CE8->CE8_PAIS	:= cPai //Obligatorio cuando el tipo de tercero sea igual a: 05
					CE8->CE8_IVADEV	:= aNCP[nX,6]
					CE8->CE8_FECREG	:= dDataBase
					CE8->CE8_TIPO 	:= "NCP"
					If lMesCal
						CE8->CE8_MESCAL	:= cMes+cAnio
					EndIf
				CE8->(MSUnLock())
			EndIf
		Next nX
	Next nK
	
	cFilAnt := cFilTmp

	If !lAutomato
		If Len(aError) > 0
			If MsgYesNo(STR0013) //"Se generó la información (tabla CE8 y CDX),  pero, hubo errores para procesar algunos registros. ¿Quiere verificar el LOG?"
				ImprimeLog()
			EndIf
		ElseIf !lInf
			MsgInfo(STR0034) //"No se encontraron registros para generar información."
		Else
			MsgInfo(STR0014) //"El proceso ha finalizado correctamente."
		EndIf
	Else
		If Len(aError) > 0
			ConOut(STR0013) //"Se generó la información (tabla CE8 y CDX),  pero, hubo errores para procesar algunos registros. ¿Quiere verificar el LOG?"
		ElseIf !lInf
			ConOut(STR0034) //"No se encontraron registros para generar información."
		Else
			ConOut(STR0014) //"El proceso ha finalizado correctamente."
		EndIf
	Endif
	FwFreeArray(aPgosDIOT)
	FwFreeArray(aNCP)
	FwFreeArray(aError)
	FwFreeArray(aPgoDet)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FS088GERA ºAutor  ³Gpe Santacruz       º Data ³  21/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida informacion del proveedor para las NCP.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FS088GERA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldRegistro(CPrvTda, cRfc, cID, cTipT, CTipO, CPai)
	
	Local lRet	:= .T.

	If Empty(cRFC) .and. cTipT == '04'
		aAdd(aError, {STR0015 + CPrvTda + STR0016}) // "Prov.:"  " El RFC del proveedor esta vacío!"
		lRet := .F.
	EndIf
	
	If Empty(cPai) .and. cTipT == '05'
		aAdd(aError, {STR0015 + CPrvTda + STR0017}) // "Prov.:"  " El Pais del proveedor esta vacío!"
		lRet := .F.
	EndIf
	
	If Empty(cTipT)
		aAdd(aError, {STR0015 + CPrvTda + STR0018}) // " El Tipo proveedore (terceros) esta vacío!"
		lRet := .F.
	EndIf
	
	If Empty(cTipO)
		aAdd(aError, {STR0015 + CPrvTda + STR0019}) // " El Tipo operación esta vacío!"
		lRet := .F.
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS088LIMPIA  ³Autor ³ Gpe Santacruz        ³Data³21/04/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Limpia los movimientos del periodo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FS088GERA                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS088LIMPIA()
	
	Local lRet		:= .T.
	Local cQueryDel	:= ''
	Local lMesCal	:= (CE8->(ColumnPos("CE8_MESCAL")) > 0)

	DBSelectArea("CDX")

	cQueryDel := "DELETE FROM " + RetSqlName("CDX")
	cQueryDel += " WHERE CDX_FILIAL IN (" + cSucur + ") "
	cQueryDel += " AND CDX_MESANO =  '" + cMes + cAnio + "' "

	If (TcSqlExec( cQueryDel ) ) <> 0
		MsgAlert(TcSqlError())
		lRet := .F.
	EndIf

	DBSelectArea("CE8")

	cQueryDel := "DELETE FROM " + RetSqlName("CE8")
	cQueryDel += " WHERE CE8_FILIAL IN (" + cSucur + ") "
	If !lMesCal
		cQueryDel += " AND CE8_MESANO =  '" + cMes + cAnio + "' "
	Else
		cQueryDel += " AND ((CE8_MESANO = '" + cMes + cAnio + "' AND CE8_MESCAL = ' ') "
		cQueryDel += " OR CE8_MESCAL = '" + cMes + cAnio + "')"
	EndIf

	If (TcSqlExec( cQueryDel ) ) <> 0
		MsgAlert(TcSqlError())
		lRet := .F.
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS088SE2  	³Autor ³ Gpe Santacruz        ³Data³21/04/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ obtiene la parte proporcional pagada respecto al titulo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ fs088GERA                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS088SE2()

	Local nX			:= 0
	Local nPorcion		:= 0
	Local nTaxa			:= 0
	Local nY			:= 0
	Local nBase			:= 0
	Local cImp			:= ''
	Local cFilSA2		:= xFilial("SA2")
	Local cFilRSC		:= ''
	Local aArea			:= GetArea()
	Local nTamTip		:= TamSX3("E2_TIPO")[1]
	Local nTamPar		:= TamSX3("E2_PARCELA")[1]
	Local lImportacion	:= .F.
	Local cFilRSE		:= ''
	Local cFilSD1		:= ''
	Local lMovEnSE2		:= .F.
	Local nNumRecSE2	:= 0
	
	Local nBasExe		:= 0
	Local nSumBase		:= 0
	Local nSumImp		:= 0
	Local nJ			:= 0

	DBSelectArea("SA2")
	SA2->(DBSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA

	If lEsImport
		cFilRSE := xFilial("RSE")
		cFilSD1 := xFilial("SD1")
		cFilRSC := xFilial("RSC")
		DBSelectArea("RSE")
		RSE->(DBSetOrder(3)) //RSE_FILIAL + RSE_FACT + RSE_SERIE + RSE_PROV + RSE_TDA
		DBSelectArea("RSC") 
		RSC->(DBSetOrder(1)) //RSC_FILIAL + RSC_NUMPED
	EndIf

	ProcRegua(Len(aPagos)) // Número de registros a procesar
	DBSelectArea("SD1")
	SD1->(DBSetOrder(1)) //D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM 

	SE2->(DBSetOrder(6)) //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
	DBSelectArea("SF1")
	SF1->(DBSetOrder(1)) //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO

	For nX := 1 To Len(aPagos)
		lImportacion := .F.
		If lEsImport
			//Verifica que no sea un pago a una facturas de importacion, Solo si existe el modulo de importaciones Mexico
			If RSE->(DBSeek(cFilRSE+aPagos[nX,1]+aPagos[nX,2]+aPagos[nX,4]+aPagos[nX,5]))
				If RSE->RSE_TIPO $ "1/3" //Si es mercancia o gastos extranjeros
					lImportacion := .T.
				EndIf
			Else //Verifica que no sea factura de impuestos
				If SD1->(DBSeek(cFilSD1+aPagos[nX,1]+aPagos[nX,2]+aPagos[nX,4]+aPagos[nX,5]))
					If !Empty(SD1->D1_PEDIM)
						If RSC->(DBSeek(cFilRSC+SD1->D1_PEDIM))
							If aPagos[nX,1]+aPagos[nX,2] == RSC->RSC_FACIMP+RSC->RSC_SERIMP
								lImportacion := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If !lImportacion
			//Tratamiento para buscar en SE2 con Financiero compartido
			If lCompSEK
				lMovEnSE2 := SE2->(DBSeek(xFilial("SE2") + aPagos[nX,4] + aPagos[nX,5] + aPagos[nX,2] + aPagos[nX,1] + PADR(aPagos[nX,3], nTamPar, " ") + PADR(aPagos[nX,8], nTamTip, " ")))
			Else //Si no es financiero compartido
				nNumRecSE2 := fGetRecSE2(aPagos[nX])
				If nNumRecSE2 > 0
					lMovEnSE2 := .T.
					SE2->(DBGoTo(nNumRecSE2))
				EndIf
			EndIf
			
			If lMovEnSE2
				
				nTaxa := 1
				If SE2->E2_MOEDA <> 1
					nTaxa := SE2->E2_TXMOEDA
				EndIf
				
				nPorcion	:= aPagos[nx,6] / (SE2->E2_VALOR * nTaxa)
				
				cRFC	:= ''
				cID		:= ''
				cTipT	:= ''
				cTipO	:= ''
				cPai	:= ''
				
				If SA2->(DBSeek(cFilSA2 + aPagos[nX,4] + aPagos[nX,5]))
					cRFC	:= SA2->A2_CGC
					cID		:= SA2->A2_IDFISCA
					cTipT	:= SA2->A2_TIPOTER
					cTipO	:= SA2->A2_TPOPER
					cPai	:= SA2->A2_PAIS
				EndIf
				
				nY := 1
				Do While nY <= 10 
										
					nBase	:= 0
					nValImp	:= 0
					nImpImp	:= 0
					
					cImp	:= AllTrim(Str(nY))
					
					If (SE2->(FieldPos("E2_BASIMP" + cImp)) > 0)
						If _cCpoIVC  == cImp .OR. _cCpoIEPS  == cImp   //IVA INCLUIDO O IEPS
							nBase	:= (&("SE2->E2_BASIMP" + cImp) * nTaxa * nPorcion) * (-1)
						Else
							nBase	:= &("SE2->E2_BASIMP" + cImp) * nTaxa * nPorcion
						EndIf
						nValImp	:= &("SE2->E2_VALIMP" + cImp) * nTaxa * nPorcion
						nImpImp	:= &("SE2->E2_ALQIMP" + cImp)
						
						If nBase > 0
							cImp := StrZero(nImpImp, 2)
							nPos := aScan(aPgosDIOT, {|X| X[1]+X[2]+X[3]+X[4]+X[5]+X[6] == ;
							 							""+aPagos[nx,1]+aPagos[nx,2]+aPagos[nx,3]+aPagos[nx,4]+aPagos[nx,5]})
							
							If nPos == 0
								aAdd(aPgosDIOT, {"", aPagos[nx,1], aPagos[nx,2], aPagos[nx,3], aPagos[nx,4], aPagos[nx,5], aPagos[nx,7], nBase,;
								 						aPagos[nx,8], aPagos[nx,9], aPagos[nx,10], aPagos[nx,11], SE2->E2_EMISSAO,;
								 						0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cRFC, cID, cTipT, cTipO, cPai, SE2->E2_TIPO, 0, 0, 0})
								
								nPosD := Len(aPgosDIOT)
							Else
								nPosD := nPos
							EndIf
							
							If AllTrim(Str(nY)) $ _CIMPRET
								aPgosDIOT[nPosD,23] += nValImp
							Else
								If AllTrim(Str(nY)) $ _CLISIVAS
									nImpImp := Round(nImpImp,1)
									Do Case
										Case nImpImp == 0 //IVA 0%
											aPgosDIOT[nPosD, 15] += nBase
										Case nImpImp == 8 .AND. YEAR(aPagos[nX,9]) >= 2019 //IVA FRONTERIZO 8% A PARTIR DEL 2019
											aPgosDIOT[nPosD, 32] += nBase
										Case nImpImp == 10 .AND. YEAR(aPagos[nX,9]) < 2010 .AND. cTipT $ '04|15' 	//IVA 10 ANTES DEL 2010
											aPgosDIOT[nPosD, 16] += nBase
										Case (nImpImp == 11 .OR. nImpImp == 10) .AND. YEAR(aPagos[nX,9]) >= 2010 .AND. cTipT $ '04|15'//IVA 11
											aPgosDIOT[nPosD, 17] += nBase
										Case nImpImp == 15 .AND. YEAR(aPagos[nX,9]) < 2010 .AND. cTipT $ '04|15' //IVA 15 ANTES DE 2010
											aPgosDIOT[nPosD, 18] += nBase
										Case (nImpImp == 16 .OR. nImpImp == 15) .AND. YEAR(aPagos[nX,9])>=2010.AND. cTipT $ '04|15' //IVA 16
											aPgosDIOT[nPosD, 19] += nBase
										Case (nImpImp == 10 .OR. nImpImp == 11) .AND. cTipT == '05'  //10 U 11 Y ES IMPORTACION
											aPgosDIOT[nPosD, 21] += nBase
										Case(nImpImp == 15 .OR. nImpImp == 16) .AND. cTipT=='05'   //15 O 16 Y ES IMPORTACION
											aPgosDIOT[nPosD, 22] += nBase
									EndCase
									
									If cTipT == '05'
										aPgosDIOT[nPosD, 31] += nValImp
									Else
										aPgosDIOT[nPosD, 30] += nValImp
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					nY++
					cImp := ""
				EndDo
				
				//Se saca del ciclo para que no se registre n veces.
				aAdd(aPgoDet, {aPagos[nx,1], aPagos[nx,2], aPagos[nx,3], aPagos[nx,4], aPagos[nx,5], SE2->E2_EMISSAO,;
				 				IIf(!Empty(aPagos[nx,7]), aPagos[nx,7], aPagos[nx,10]), IIf(!Empty(aPagos[nx,7]), "OP",;
				 				aPagos[nx,10]), aPagos[nx,9], aPagos[nx,6], , cID, cTipT, cTipO, cPai, SE2->E2_TIPO})

				//Examina IVA Exento
				nSumBase	:= 0
				nSumImp		:= 0
				nBasExe		:= 0

				For nJ := 1 To 10
					cImp := AllTrim(Str(nJ))
					If (SE2->(FieldPos("E2_BASIMP"+cImp)) > 0)
						nSumBase	+= &("SE2->E2_BASIMP" + cImp)
						nSumImp		+= &("SE2->E2_VALIMP" + cImp)
					EndIf
				Next

				nBasExe := SE2->E2_VALOR - (nSumBase + nSumImp)
				
				If nBasExe > 0
					nBasExe :=  nBasExe * nTaxa * nPorcion
					nPos := aScan(aPgosDIOT, {|X| X[1]+X[2]+X[3]+X[4]+X[5]+X[6] == ""+aPagos[nx,1]+aPagos[nx,2]+aPagos[nx,3]+aPagos[nx,4]+aPagos[nx,5] })
					If nPos == 0
						aAdd(aPgosDIOT, {"", aPagos[nx,1], aPagos[nx,2], aPagos[nx,3], aPagos[nx,4], aPagos[nx,5], aPagos[nx,7], nBase,;
						 						aPagos[nx,8], aPagos[nx,9], aPagos[nx,10], aPagos[nx,11], SE2->E2_EMISSAO,;
						 						0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cRFC, cID, cTipT, cTipO, cPai, SE2->E2_TIPO, 0, 0, 0})
						nPosD := Len(aPgosDIOT)
					Else
						nPosD := nPos
					EndIf
					
					If cTipT == '04'  //IVA Exento Nacional
						aPgosDIOT[nPosD,14] += nBasExe
					Else //IVA Exento Extranjero
						aPgosDIOT[nPosD,20] += nBasExe
					EndIf
				EndIf
			Else
				aAdd(aError, {STR0031 + aPagos[nX,4] + " - " + aPagos[nX,5] + STR0032 + aPagos[nX,2] + " " + aPagos[nX,1] + PADR(aPagos[nX,3], nTamPar, " ")}) // "NO ENCONTRO EN CXP EL PROVEDOR :" " Y FACTURA :"
			EndIf
		EndIf
		IncProc()
	Next nX

	RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS088Traduce      ³ Gpe Santacruz         ³ Data ³21/04/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Convierte las variables de las preguntas que son de tipo   ³±±
±±³          ³ rango, a expresiones para usarse en querys.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS088Traduce (cExp1 )                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 = Parametro de la pregunta                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA088                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FS088Traduce(cVari)
	
	Local aMats	:= {}
	Local nX	:= 0

	If ";" $ cVari
		aMats := Separa(Alltrim(cVari), ";")
		cVari := ''
		For nX := 1 To Len(aMats)
			If !Empty(aMats[nX])
				cVari += "'" + aMats[nX] + "',"
			EndIf
		Next
		cVari := SubStr(cVari,1,Len(cVari)-1)
	Else
		If "-" $ cVari
			aMats := Separa(Alltrim(cVari), "-")
			cVari := "'" + aMats[1] + "' AND '" + aMats[2]+"'"
		EndIf
	EndIf

Return 	cVari

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS088RECPAIS      ³ Gpe Santacruz         ³ Data ³21/04/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Actualiza los paises con las siglas y nacional. SAT        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS088RECPAIS                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA088                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS088RECPAIS()
	
	DbSelectArea("SYA")
	SYA->(DBSetOrder(1)) //YA_FILIAL + YA_CODGI
	SYA->(DBGoTop())

	If SYA->(FieldPos("YA_SGLMEX")) > 0 .And. SYA->(FieldPos("YA_NASCIO")) > 0
		If SYA->(DbSeek(xFilial("SYA")+"013")) .And. Empty(SYA->YA_SGLMEX)
			Do While !SYA->(Eof())
				cCod := SYA->YA_CODGI
				RecLock("SYA",.F.)
					Do Case
						Case cCod == "013" //"Afganistán"
							SYA->YA_SGLMEX 	:= "AD"
							SYA->YA_NASCIO	:= "Afganistán"
						Case cCod == "023" //"Alemania"
							SYA->YA_SGLMEX 	:= "DD"
							SYA->YA_NASCIO	:= "Alemania"
						Case cCod == "017" //"República de Albania"
							SYA->YA_SGLMEX 	:= "AL"
							SYA->YA_NASCIO	:= "República de Albania"
						Case cCod == "037" //"Principado de Andorra"
							SYA->YA_SGLMEX 	:= "AD"
							SYA->YA_NASCIO	:= "Principado de Andorra"
						Case cCod == "040" //República de Angola
							SYA->YA_SGLMEX 	:= "AO"
							SYA->YA_NASCIO	:= "República de Angola"
						Case cCod == "041" //Isla Anguilla
							SYA->YA_SGLMEX 	:= "AI"
							SYA->YA_NASCIO	:= "Isla Anguilla"
						Case cCod == "043" //Antigua y Bermuda
							SYA->YA_SGLMEX 	:= "AG"
							SYA->YA_NASCIO	:= "Antigua y Bermuda"
						Case cCod == "047" //Antillas Neerlandesas
							SYA->YA_SGLMEX 	:= "AN"
							SYA->YA_NASCIO	:= "Antillas Neerlandesas"
						Case cCod == "053" //Arabia Saudita
							SYA->YA_SGLMEX 	:= "SA"
							SYA->YA_NASCIO	:= "Arabia Saudita"
						Case cCod == "059" //Argelia
							SYA->YA_SGLMEX 	:= "DZ"
							SYA->YA_NASCIO	:= "Argelia"
						Case cCod == "063" //Argentina
							SYA->YA_SGLMEX 	:= "AR"
							SYA->YA_NASCIO	:= "Argentina"
						Case cCod == "065" //Aruba
							SYA->YA_SGLMEX 	:= "AW"
							SYA->YA_NASCIO	:= "Aruba"
						Case cCod == "069" //Australia
							SYA->YA_SGLMEX 	:= "AU"
							SYA->YA_NASCIO	:= "Australia"
						Case cCod == "072" //Austria
							SYA->YA_SGLMEX 	:= "AT"
							SYA->YA_NASCIO	:= "Austria"
						Case cCod == "077" //Commonwealth de las Bahamas
							SYA->YA_SGLMEX 	:= "BS"
							SYA->YA_NASCIO	:= "Commonwealth de las Bahamas"
						Case cCod == "080" //Estado de Bahrein
							SYA->YA_SGLMEX 	:= "BH"
							SYA->YA_NASCIO	:= "Estado de Bahrein"
						Case cCod == "081" //Bangladesh
							SYA->YA_SGLMEX 	:= "BD"
							SYA->YA_NASCIO	:= "Bangladesh"
						Case cCod == "083" //Barbados
							SYA->YA_SGLMEX 	:= "BB"
							SYA->YA_NASCIO	:= "Barbados"
						Case cCod == "087" //Bélgica
							SYA->YA_SGLMEX 	:= "BE"
							SYA->YA_NASCIO	:= "Bélgica"
						Case cCod == "088" //Belice
							SYA->YA_SGLMEX 	:= "BL"
							SYA->YA_NASCIO	:= "Belice"
						Case cCod == "229" //Benin
							SYA->YA_SGLMEX 	:= "BJ"
							SYA->YA_NASCIO	:= "Benin"
						Case cCod == "090" //Bermudas
							SYA->YA_SGLMEX 	:= "BM"
							SYA->YA_NASCIO	:= "Bermudas"
						Case cCod == "097" //Bolivia
							SYA->YA_SGLMEX 	:= "BO"
							SYA->YA_NASCIO	:= "Bolivia"
						Case cCod == "101" //Botswana
							SYA->YA_SGLMEX 	:= "BW"
							SYA->YA_NASCIO	:= "Botswana"
						Case cCod == "105" //Brasil
							SYA->YA_SGLMEX 	:= "BR"
							SYA->YA_NASCIO	:= "Brasil"
						Case cCod == "108" //Brunei Darussalam
							SYA->YA_SGLMEX 	:= "BN"
							SYA->YA_NASCIO	:= "Brunei Darussalam"
						Case cCod == "108" //Brunei Darussalam
							SYA->YA_SGLMEX 	:= "BN"
							SYA->YA_NASCIO	:= "Brunei Darussalam"
						Case cCod == "111" //Bulgaria
							SYA->YA_SGLMEX 	:= "BG"
							SYA->YA_NASCIO	:= "Bulgaria"
						Case cCod == "031" .Or. cCod == "310" //Burkina Faso
							SYA->YA_SGLMEX 	:= "BF"
							SYA->YA_NASCIO	:= "Burkina Faso"
						Case cCod == "115" //Burundi
							SYA->YA_SGLMEX 	:= "BI"
							SYA->YA_NASCIO	:= "Burundi"
						Case cCod == "119" //Buthan
							SYA->YA_SGLMEX 	:= "BT"
							SYA->YA_NASCIO	:= "Buthan"
						Case cCod == "127" //República de Cabo Verde
							SYA->YA_SGLMEX 	:= "CV"
							SYA->YA_NASCIO	:= "República de Cabo Verde"
						Case cCod == "145" //Camerún
							SYA->YA_SGLMEX 	:= "CM"
							SYA->YA_NASCIO	:= "Camerún"
						Case cCod == "149" //Canadá
							SYA->YA_SGLMEX 	:= "CA"
							SYA->YA_NASCIO	:= "Canadá"
						Case cCod == "151" //Islas Canarias
							SYA->YA_SGLMEX 	:= "CD"
							SYA->YA_NASCIO	:= "Islas Canarias"
						Case cCod == "137" //Islas Caimán
							SYA->YA_SGLMEX 	:= "KY"
							SYA->YA_NASCIO	:= "Islas Caimán"
						Case cCod == "788" //Chad
							SYA->YA_SGLMEX 	:= "TD"
							SYA->YA_NASCIO	:= "Chad"
						Case cCod == "158" //Chile
							SYA->YA_SGLMEX 	:= "CL"
							SYA->YA_NASCIO	:= "Chile"
						Case cCod == "160" //China
							SYA->YA_SGLMEX 	:= "CN"
							SYA->YA_NASCIO	:= "China"
						Case cCod == "163" //República de Chipre
							SYA->YA_SGLMEX 	:= "CY"
							SYA->YA_NASCIO	:= "República de Chipre"
						Case cCod == "163" //República de Chipre
							SYA->YA_SGLMEX 	:= "CY"
							SYA->YA_NASCIO	:= "República de Chipre"
						Case cCod == "511" //Isla de Christmas
							SYA->YA_SGLMEX 	:= "CE"
							SYA->YA_NASCIO	:= "Isla de Christmas"
						Case cCod == "165" //Isla de Cocos o Kelling
							SYA->YA_SGLMEX 	:= "CC"
							SYA->YA_NASCIO	:= "Isla de Cocos o Kelling"
						Case cCod == "169" //Colombia
							SYA->YA_SGLMEX 	:= "CO"
							SYA->YA_NASCIO	:= "Colombia"
						Case cCod == "173" //Comoros
							SYA->YA_SGLMEX 	:= "KM"
							SYA->YA_NASCIO	:= "Comoros"
						Case cCod == "888" .Or. cCod == "177" //Congo
							SYA->YA_SGLMEX 	:= "CG"
							SYA->YA_NASCIO	:= "Congo"
						Case cCod == "183" //Islas Cook
							SYA->YA_SGLMEX 	:= "CK"
							SYA->YA_NASCIO	:= "Islas Cook"
						Case cCod == "187" //República Democrática de Corea
							SYA->YA_SGLMEX 	:= "KP
							SYA->YA_NASCIO	:= "República Democrática de Corea"
						Case cCod == "190" //República de Corea
							SYA->YA_SGLMEX 	:= "KR"
							SYA->YA_NASCIO	:= "República de Corea"
						Case cCod == "193" //Costa de Marfil
							SYA->YA_SGLMEX 	:= "CI"
							SYA->YA_NASCIO	:= "Costa de Marfil"
						Case cCod == "196" //República de Costa Rica
							SYA->YA_SGLMEX 	:= "CR"
							SYA->YA_NASCIO	:= "República de Costa Rica"
						Case cCod == "199" //Cuba
							SYA->YA_SGLMEX 	:= "CU"
							SYA->YA_NASCIO	:= "Cuba"
						Case cCod == "232" //Dinamarca
							SYA->YA_SGLMEX 	:= "DK"
							SYA->YA_NASCIO	:= "Dinamarca"
						Case cCod == "783" //República de Djibouti
							SYA->YA_SGLMEX 	:= "DJ"
							SYA->YA_NASCIO	:= "República de Djibouti"
						Case cCod == "235" //Commonwealth de Dominica
							SYA->YA_SGLMEX 	:= "DN"
							SYA->YA_NASCIO	:= "Commonwealth de Dominica"
						Case cCod == "240" //Egipto
							SYA->YA_SGLMEX 	:= "EG"
							SYA->YA_NASCIO	:= "Egipto"
						Case cCod == "687" //El Salvador
							SYA->YA_SGLMEX 	:= "SV"
							SYA->YA_NASCIO	:= "El Salvador"
						Case cCod == "244" //Emiratos Arabes Unidos
							SYA->YA_SGLMEX 	:= "AE"
							SYA->YA_NASCIO	:= "Emiratos Arabes Unidos"
						Case cCod == "239" //Ecuador
							SYA->YA_SGLMEX 	:= "EC"
							SYA->YA_NASCIO	:= "Ecuador"
						Case cCod == "247" .Or. cCod == "791" .Or. cCod == "790" //República Checa y República Eslovaca
							SYA->YA_SGLMEX 	:= "CS"
							SYA->YA_NASCIO	:= "República Checa y República Eslovaca"
						Case cCod == "245" //España
							SYA->YA_SGLMEX 	:= "ES"
							SYA->YA_NASCIO	:= "España"
						Case cCod == "249" //Estados Unidos de América
							SYA->YA_SGLMEX 	:= "US"
							SYA->YA_NASCIO	:= "Estados Unidos de América"
						Case cCod == "253" //Etiopía
							SYA->YA_SGLMEX 	:= "ET"
							SYA->YA_NASCIO	:= "Etiopía"
						Case cCod == "255" //Islas Malvinas
							SYA->YA_SGLMEX 	:= "FK"
							SYA->YA_NASCIO	:= "Islas Malvinas"
						Case cCod == "870" //Fiji
							SYA->YA_SGLMEX 	:= "FJ"
							SYA->YA_NASCIO	:= "Fiji"
						Case cCod == "267" //Filipinas
							SYA->YA_SGLMEX 	:= "PH"
							SYA->YA_NASCIO	:= "Filipinas"
						Case cCod == "271" //Finlandia
							SYA->YA_SGLMEX 	:= "FI"
							SYA->YA_NASCIO	:= "Finlandia"
						Case cCod == "271" //Finlandia
							SYA->YA_SGLMEX 	:= "FI"
							SYA->YA_NASCIO	:= "Finlandia"
						Case cCod == "161" //Taiwán
							SYA->YA_SGLMEX 	:= "TW"
							SYA->YA_NASCIO	:= "Taiwán"
						Case cCod == "275" //Francia
							SYA->YA_SGLMEX 	:= "FR"
							SYA->YA_NASCIO	:= "Francia"
						Case cCod == "281" //Gabón
							SYA->YA_SGLMEX 	:= "GA"
							SYA->YA_NASCIO	:= "Gabón"
						Case cCod == "285" //Gambia
							SYA->YA_SGLMEX 	:= "GM"
							SYA->YA_NASCIO	:= "Gambia"
						Case cCod == "289" //Ghana
							SYA->YA_SGLMEX 	:= "GH"
							SYA->YA_NASCIO	:= "Ghana"
						Case cCod == "293" //Gibraltar
							SYA->YA_SGLMEX 	:= "GI"
							SYA->YA_NASCIO	:= "Gibraltar"
						Case cCod == "297" //Granada
							SYA->YA_SGLMEX 	:= "GD"
							SYA->YA_NASCIO	:= "Granada"
						Case cCod == "297" //Granada
							SYA->YA_SGLMEX 	:= "GD"
							SYA->YA_NASCIO	:= "Granada"
						Case cCod == "301" //Grecia
							SYA->YA_SGLMEX 	:= "GR"
							SYA->YA_NASCIO	:= "Grecia"
						Case cCod == "305" //Groenlandia
							SYA->YA_SGLMEX 	:= "GJ"
							SYA->YA_NASCIO	:= "Groenlandia"
						Case cCod == "309" //Guadalupe
							SYA->YA_SGLMEX 	:= "GP"
							SYA->YA_NASCIO	:= "Guadalupe"
						Case cCod == "313" //Guam
							SYA->YA_SGLMEX 	:= "GU"
							SYA->YA_NASCIO	:= "Guam"
						Case cCod == "317" //Guatemala
							SYA->YA_SGLMEX 	:= "GT"
							SYA->YA_NASCIO	:= "Guatemala"
						Case cCod == "337" //República de Guyana
							SYA->YA_SGLMEX 	:= "GY"
							SYA->YA_NASCIO	:= "República de Guyana"
						Case cCod == "325" //Guyana Francesa
							SYA->YA_SGLMEX 	:= "GF"
							SYA->YA_NASCIO	:= "Guyana Francesa"
						Case cCod == "329" //Guinea
							SYA->YA_SGLMEX 	:= "GN"
							SYA->YA_NASCIO	:= "Guinea"
						Case cCod == "334" //Guinea Bissau
							SYA->YA_SGLMEX 	:= "GW"
							SYA->YA_NASCIO	:= "Guinea Bissau"
						Case cCod == "331" //Guinea Ecuatorial
							SYA->YA_SGLMEX 	:= "GQ"
							SYA->YA_NASCIO	:= "Guinea Ecuatorial"
						Case cCod == "341" //Haití
							SYA->YA_SGLMEX 	:= "HT"
							SYA->YA_NASCIO	:= "Haití"
						Case cCod == "345" //República de Honduras
							SYA->YA_SGLMEX 	:= "HN"
							SYA->YA_NASCIO	:= "República de Honduras"
						Case cCod == "351" //Hong Kong
							SYA->YA_SGLMEX 	:= "HK"
							SYA->YA_NASCIO	:= "Hong Kong"
						Case cCod == "355" //Hungría
							SYA->YA_SGLMEX 	:= "HU"
							SYA->YA_NASCIO	:= "Hungría"
						Case cCod == "357" .Or. cCod == "358" //Yemen Democrática
							SYA->YA_SGLMEX 	:= "YD"
							SYA->YA_NASCIO	:= "Yemen Democrática"
						Case cCod == "357" //Madeira
							SYA->YA_SGLMEX 	:= "MD"
							SYA->YA_NASCIO	:= "Madeira"
						Case cCod == "361" //India
							SYA->YA_SGLMEX 	:= "IN"
							SYA->YA_NASCIO	:= "India"
						Case cCod == "365" //Indonesia
							SYA->YA_SGLMEX 	:= "ID"
							SYA->YA_NASCIO	:= "Indonesia"
						Case cCod == "372" //Irán
							SYA->YA_SGLMEX 	:= "IR"
							SYA->YA_NASCIO	:= "Irán"
						Case cCod == "369" //Iraq
							SYA->YA_SGLMEX 	:= "IQ"
							SYA->YA_NASCIO	:= "Iraq"
						Case cCod == "375" //Irlanda
							SYA->YA_SGLMEX 	:= "IE"
							SYA->YA_NASCIO	:= "Irlanda"
						Case cCod == "379" //Islandia
							SYA->YA_SGLMEX 	:= "IS"
							SYA->YA_NASCIO	:= "Islandia"
						Case cCod == "383" //Israel
							SYA->YA_SGLMEX 	:= "IL"
							SYA->YA_NASCIO	:= "Israel"
						Case cCod == "386" //Italia
							SYA->YA_SGLMEX 	:= "IT"
							SYA->YA_NASCIO	:= "Italia"
						Case cCod == "388" .Or. cCod == "449" //Países de la Ex - Yugoslavia
							SYA->YA_SGLMEX 	:= "YU"
							SYA->YA_NASCIO	:= "Países de la Ex - Yugoslavia"
						Case cCod == "391" //Jamaica
							SYA->YA_SGLMEX 	:= "JM"
							SYA->YA_NASCIO	:= "Jamaica"
						Case cCod == "399" //Japón
							SYA->YA_SGLMEX 	:= "JP"
							SYA->YA_NASCIO	:= "Japón"
						Case cCod == "150" //Islas de Jersey (Islas del Canal)
							SYA->YA_SGLMEX 	:= "GZ"
							SYA->YA_NASCIO	:= "Islas de Jersey (Islas del Canal)"
						Case cCod == "403" //Reino Hachemita de Jordania
							SYA->YA_SGLMEX 	:= "JO"
							SYA->YA_NASCIO	:= "Reino Hachemita de Jordania"
						Case cCod == "411" //Kiribati
							SYA->YA_SGLMEX 	:= "KI"
							SYA->YA_NASCIO	:= "Kiribati"
						Case cCod == "420" //República Democrática de Laos
							SYA->YA_SGLMEX 	:= "LA"
							SYA->YA_NASCIO	:= "República Democrática de Laos"
						Case cCod == "426" //Lesotho
							SYA->YA_SGLMEX 	:= "LS"
							SYA->YA_NASCIO	:= "Lesotho"
						Case cCod == "431" //Líbano
							SYA->YA_SGLMEX 	:= "LB"
							SYA->YA_NASCIO	:= "Líbano"
						Case cCod == "434" //República de Liberia
							SYA->YA_SGLMEX 	:= "LR"
							SYA->YA_NASCIO	:= "República de Liberia"
						Case cCod == "438" //Libia
							SYA->YA_SGLMEX 	:= "LY"
							SYA->YA_NASCIO	:= "Libia"
						Case cCod == "440" //Principado de Liechtenstein
							SYA->YA_SGLMEX 	:= "LI"
							SYA->YA_NASCIO	:= "Principado de Liechtenstein"
						Case cCod == "445" //Gran Ducado de Luxemburgo
							SYA->YA_SGLMEX 	:= "LU"
							SYA->YA_NASCIO	:= "Gran Ducado de Luxemburgo"
						Case cCod == "447" //Macao
							SYA->YA_SGLMEX 	:= "MO"
							SYA->YA_NASCIO	:= "Macao"
						Case cCod == "450" //Madagascar
							SYA->YA_SGLMEX 	:= "MG"
							SYA->YA_NASCIO	:= "Madagascar"
						Case cCod == "455" //Malasia
							SYA->YA_SGLMEX 	:= "MY"
							SYA->YA_NASCIO	:= "Malasia"
						Case cCod == "458" //Malawi
							SYA->YA_SGLMEX 	:= "MW"
							SYA->YA_NASCIO	:= "Malawi"
						Case cCod == "461" //República de Maldivas
							SYA->YA_SGLMEX 	:= "MV"
							SYA->YA_NASCIO	:= "República de Maldivas"
						Case cCod == "464" //Malí
							SYA->YA_SGLMEX 	:= "ML"
							SYA->YA_NASCIO	:= "Malí"
						Case cCod == "467" //Malta
							SYA->YA_SGLMEX 	:= "MT"
							SYA->YA_NASCIO	:= "Malta"
						Case cCod == "472" //Islas Marianas del Noreste
							SYA->YA_SGLMEX 	:= "MP"
							SYA->YA_NASCIO	:= "Islas Marianas del Noreste"
						Case cCod == "474" //Marruecos
							SYA->YA_SGLMEX 	:= "MA"
							SYA->YA_NASCIO	:= "Marruecos"
						Case cCod == "476" //República de las Islas Marshall
							SYA->YA_SGLMEX 	:= "MH"
							SYA->YA_NASCIO	:= "República de las Islas Marshall"
						Case cCod == "477" //Martinica
							SYA->YA_SGLMEX 	:= "MQ"
							SYA->YA_NASCIO	:= "Martinica"
						Case cCod == "485" //República de Mauricio
							SYA->YA_SGLMEX 	:= "MU"
							SYA->YA_NASCIO	:= "República de Mauricio"
						Case cCod == "488" //Mauritania
							SYA->YA_SGLMEX 	:= "MR"
							SYA->YA_NASCIO	:= "Mauritania"
						Case cCod == "499" //Micronesia
							SYA->YA_SGLMEX 	:= "FM"
							SYA->YA_NASCIO	:= "Micronesia"
						Case cCod == "505" //Mozambique
							SYA->YA_SGLMEX 	:= "MZ"
							SYA->YA_NASCIO	:= "Mozambique"
						Case cCod == "497" //Mongolia
							SYA->YA_SGLMEX 	:= "MN"
							SYA->YA_NASCIO	:= "Mongolia"
						Case cCod == "501" //Monserrat
							SYA->YA_SGLMEX 	:= "MS"
							SYA->YA_NASCIO	:= "Monserrat"
						Case cCod == "507" //República de Namibia
							SYA->YA_SGLMEX 	:= "NA"
							SYA->YA_NASCIO	:= "República de Namibia"
						Case cCod == "508" //República de Nauru
							SYA->YA_SGLMEX 	:= "NR"
							SYA->YA_NASCIO	:= "República de Nauru"
						Case cCod == "517" //Nepal
							SYA->YA_SGLMEX 	:= "NP"
							SYA->YA_NASCIO	:= "Nepal"
						Case cCod == "521" //Nicaragua
							SYA->YA_SGLMEX 	:= "NI"
							SYA->YA_NASCIO	:= "Nicaragua"
						Case cCod == "525" //Níger
							SYA->YA_SGLMEX 	:= "NE"
							SYA->YA_NASCIO	:= "Níger"
						Case cCod == "528" //Nigeria
							SYA->YA_SGLMEX 	:= "NG"
							SYA->YA_NASCIO	:= "Nigeria"
						Case cCod == "531" //Niue
							SYA->YA_SGLMEX 	:= "NU"
							SYA->YA_NASCIO	:= "Niue"
						Case cCod == "535" //Isla de Norfolk
							SYA->YA_SGLMEX 	:= "NF"
							SYA->YA_NASCIO	:= "Isla de Norfolk"
						Case cCod == "538" //Noruega
							SYA->YA_SGLMEX 	:= "NO"
							SYA->YA_NASCIO	:= "Noruega"
						Case cCod == "542" //Nueva Caledonia
							SYA->YA_SGLMEX 	:= "NC"
							SYA->YA_NASCIO	:= "Nueva Caledonia"
						Case cCod == "548" //Nueva Zelandia
							SYA->YA_SGLMEX 	:= "NZ"
							SYA->YA_NASCIO	:= "Nueva Zelandia"
						Case cCod == "556" //Sultanía de Omán
							SYA->YA_SGLMEX 	:= "OM"
							SYA->YA_NASCIO	:= "Sultanía de Omán"
						Case cCod == "566" //Islas Pacífico
							SYA->YA_SGLMEX 	:= "IP"
							SYA->YA_NASCIO	:= "Islas Pacífico"
						Case cCod == "573" //Holanda
							SYA->YA_SGLMEX 	:= "NL"
							SYA->YA_NASCIO	:= "Holanda"
						Case cCod == "575" //Palau
							SYA->YA_SGLMEX 	:= "PW"
							SYA->YA_NASCIO	:= "Palau"
						Case cCod == "580" .Or. cCod == "895" //República de Panamá
							SYA->YA_SGLMEX 	:= "PA"
							SYA->YA_NASCIO	:= "República de Panamá"
						Case cCod == "583" .Or. cCod == "545" //Papúa Nueva Guinea
							SYA->YA_SGLMEX 	:= "PG"
							SYA->YA_NASCIO	:= "Papúa Nueva Guinea"
						Case cCod == "576"  //Pakistán
							SYA->YA_SGLMEX 	:= "PK"
							SYA->YA_NASCIO	:= "Pakistán"
						Case cCod == "586"  //Paraguay
							SYA->YA_SGLMEX 	:= "PY"
							SYA->YA_NASCIO	:= "Paraguay"
						Case cCod == "589"  //Perú
							SYA->YA_SGLMEX 	:= "PE"
							SYA->YA_NASCIO	:= "Perú"
						Case cCod == "593"  //Pitcairn
							SYA->YA_SGLMEX 	:= "PN"
							SYA->YA_NASCIO	:= "Pitcairn"
						Case cCod == "599"  //Polinesia Francesa
							SYA->YA_SGLMEX 	:= "PF"
							SYA->YA_NASCIO	:= "Polinesia Francesa"
						Case cCod == "603"  //Polonia
							SYA->YA_SGLMEX 	:= "PL"
							SYA->YA_NASCIO	:= "Polonia"
						Case cCod == "611"  //Estado Libre Asociado de Puerto Rico
							SYA->YA_SGLMEX 	:= "PR"
							SYA->YA_NASCIO	:= "Estado Libre Asociado de Puerto Rico"
						Case cCod == "607"  //Portugal
							SYA->YA_SGLMEX 	:= "PT"
							SYA->YA_NASCIO	:= "Portugal"
						Case cCod == "495"  //Principado de Mónaco
							SYA->YA_SGLMEX 	:= "MC"
							SYA->YA_NASCIO	:= "Principado de Mónaco"
						Case cCod == "623"  //Kenia
							SYA->YA_SGLMEX 	:= "KE"
							SYA->YA_NASCIO	:= "Kenia"
						Case cCod == "628"  //  REINO UNIDO
						    SYA->YA_SGLMEX := "GB"
							SYA->YA_NASCIO := " Gran Bretaña (Reino Unido)"
						Case cCod == "640"  // REPUBLICA CENTRO-AFRICANA
						    SYA->YA_SGLMEX := "CF"
							SYA->YA_NASCIO := "República Centro Africana"
						Case cCod == "647"  // REPUBLICA DOMINICANA
						    SYA->YA_SGLMEX := "DM"
							SYA->YA_NASCIO := "República Dominicana"
						Case cCod == "660"  // Reunión
						    SYA->YA_SGLMEX := "RE"
							SYA->YA_NASCIO := "Reunión"
						Case cCod == "670"  //  ROMENIA
						    SYA->YA_SGLMEX := "RO"
							SYA->YA_NASCIO := "Rumania"
						Case cCod == "675"  // RUANDA
						    SYA->YA_SGLMEX := "RW"
							SYA->YA_NASCIO := " Rhuanda"
						Case cCod == "685"  //  SAARA OCIDENTAL
						    SYA->YA_SGLMEX := "EH"
							SYA->YA_NASCIO := " Sahara del Oeste"
						Case cCod == "678"  // SAINT KITTS E NEVIS
						    SYA->YA_SGLMEX := "KN"
							SYA->YA_NASCIO := "San Kitts"
						Case cCod == "677" // SALOMAO, ILHAS
						    SYA->YA_SGLMEX := "SB"
							SYA->YA_NASCIO := "Islas Salomón"
						Case cCod == "690"  //  Estado Independiente de Samoa Occidental
						    SYA->YA_SGLMEX := "EO"
							SYA->YA_NASCIO := "Estado Independiente de Samoa Occidental"
						Case cCod == "691"  //  SAMOA AMERICANA
						    SYA->YA_SGLMEX := "AS"
							SYA->YA_NASCIO := "Samoa Americana"
						Case cCod == "697"  //  Serenísima República de San Marino
						    SYA->YA_SGLMEX := "SM"
							SYA->YA_NASCIO := "Serenísima República de San Marino"
						Case cCod == "710"  // SANTA HELENA
						    SYA->YA_SGLMEX := "SH"
							SYA->YA_NASCIO := "Santa Elena"
						Case cCod == "715"  //  SANTA LUCIA
						    SYA->YA_SGLMEX := "LC"
							SYA->YA_NASCIO := "Santa Lucía"
						Case cCod == "700"  // SAO PEDRO E MIQUELON
						    SYA->YA_SGLMEX := "PM"
							SYA->YA_NASCIO := "Isla de San Pedro y Miguelón"
						Case cCod == "720"  // SAO TOME E PRINCIPE, ILHA
						    SYA->YA_SGLMEX := "ST"
							SYA->YA_NASCIO := "Sao Tome and Príncipe"
						Case cCod == "705"  // SAO VICENTE E GRANADINAS
						    SYA->YA_SGLMEX := "VC"
							SYA->YA_NASCIO := " San Vicente y Las Granadinas"
						Case cCod == "728"  // SENEGAL
						    SYA->YA_SGLMEX := "SN"
							SYA->YA_NASCIO := "Senegal"
						Case cCod == "735"  //  SERRA LEOA
						    SYA->YA_SGLMEX := "SL"
							SYA->YA_NASCIO := "Sierra Leona"
						Case cCod == "731"  // SEYCHELLES
						    SYA->YA_SGLMEX := "SC"
							SYA->YA_NASCIO := "Seychelles Islas"
						Case cCod == "744"  //  SIRIA, REPUBLICA ARABE DA
						    SYA->YA_SGLMEX := "SY"
							SYA->YA_NASCIO := "Siria"
						Case cCod == "748"  // SOMALIA
						    SYA->YA_SGLMEX := "SO"
							SYA->YA_NASCIO := "Somalia"
						Case cCod == "750" // SRI LANKA
						    SYA->YA_SGLMEX := "LK"
							SYA->YA_NASCIO := "República Socialista Democrática de Sri Lanka"
						Case cCod == "754"   // SUAZILANDIA
						    SYA->YA_SGLMEX := "SZ"
							SYA->YA_NASCIO := "Reino de Swazilandia"
						Case cCod == "759" // SUDAO
						    SYA->YA_SGLMEX := "SD"
							SYA->YA_NASCIO := "Sudán"
						Case cCod == "764"  // SUECIA
						    SYA->YA_SGLMEX := "SE"
							SYA->YA_NASCIO := "Suecia"
						Case cCod == "767"  //  SUICA
						    SYA->YA_SGLMEX := "CH"
							SYA->YA_NASCIO := "Suiza"
						Case cCod == "770"  // SURINAME
						    SYA->YA_SGLMEX := "SR"
							SYA->YA_NASCIO := "Surinam"
						Case cCod == "776"  // TAILANDIA
						    SYA->YA_SGLMEX := "TH"
							SYA->YA_NASCIO := "Thailandia"
						Case cCod == "780"  // TANZANIA, REP.UNIDA DA
						    SYA->YA_SGLMEX := "TZ"
							SYA->YA_NASCIO := "Tanzania"
						Case cCod == "782"  // TERRITORIO BRIT.OC.INDICO
						    SYA->YA_SGLMEX := "IO"
							SYA->YA_NASCIO := "Territorio Británico en el Océano Indico"
						Case cCod == "795" // TIMOR LESTE
						    SYA->YA_SGLMEX := "TP"
							SYA->YA_NASCIO := "Timor Este"
						Case cCod == "800" // TOGO
						    SYA->YA_SGLMEX := "TG"
							SYA->YA_NASCIO := "Togo"
						Case cCod == "810"   // TONGA
						    SYA->YA_SGLMEX := "TO"
							SYA->YA_NASCIO := "Reino de Tonga"
						Case cCod == "805"   //Tokelau
						    SYA->YA_SGLMEX := "TK"
							SYA->YA_NASCIO := "Tokelau"
						Case cCod == "815"  // TRINIDAD E TOBAGO
						    SYA->YA_SGLMEX := "TT"
							SYA->YA_NASCIO := "República de Trinidad y Tobago"
						Case cCod == "823"   // TURCAS E CAICOS,ILHAS
						    SYA->YA_SGLMEX := "TC"
							SYA->YA_NASCIO := "Islas Turcas y Caicos"
						Case cCod == "827"   // TURQUIA
						    SYA->YA_SGLMEX := "TU"
							SYA->YA_NASCIO := "Turquía"
						Case cCod == "828" // TUVALU
						    SYA->YA_SGLMEX := "TV"
							SYA->YA_NASCIO := "Tuvalu"
						Case cCod == "831"  // UCRANIA
						    SYA->YA_SGLMEX := "UA"
							SYA->YA_NASCIO := "Ucrania"
						Case cCod == "833"  // UGANDA
						    SYA->YA_SGLMEX := "UG"
							SYA->YA_NASCIO := "Uganda"
						Case cCod == "840" .Or. cCod == "676" // URSS / RUSSIA
						    SYA->YA_SGLMEX := "SU"
							SYA->YA_NASCIO := "Países de la Ex -U.R.S.S., excepto Ucrania y Bielorusia"
						Case cCod == "845"  // URUGUAI
						    SYA->YA_SGLMEX := "UY"
							SYA->YA_NASCIO := "República Oriental del Uruguay"
						Case cCod == "551"  // República de Vanuatu
						    SYA->YA_SGLMEX := "VU"
							SYA->YA_NASCIO := "República de Vanuatu"
						Case cCod == "848"  // El Vaticano
						    SYA->YA_SGLMEX := "VA"
							SYA->YA_NASCIO := "El Vaticano"
						Case cCod == "850"  // VENEZUELA
						    SYA->YA_SGLMEX := "VE"
							SYA->YA_NASCIO := "Venezuela"
						Case cCod == "858"  // VIETNA
						    SYA->YA_SGLMEX := "VN"
							SYA->YA_NASCIO := "Vietnam"
						Case cCod == "863" // VIRGENS,ILHAS (BRITANICAS)
						    SYA->YA_SGLMEX := "VG"
							SYA->YA_NASCIO := "Islas Vírgenes Británicas"
						Case cCod == "866"  // VIRGENS,ILHAS (E.U.A.)
						    SYA->YA_SGLMEX := "VI"
							SYA->YA_NASCIO := "Islas Vírgenes de Estados Unidos de América"
						Case cCod == "875"  // WALLIS E FUTUNA, ILHAS
						    SYA->YA_SGLMEX := "WF"
							SYA->YA_NASCIO := "Islas Wallis y Funtuna"
						Case cCod == "890" // ZAMBIA
						    SYA->YA_SGLMEX := "ZM"
							SYA->YA_NASCIO := "Zambia"
						Case cCod == "665" // ZIMBABUE
							SYA->YA_SGLMEX := "ZW"
							SYA->YA_NASCIO := "Zimbawe"
						Case cCod == "756" // Sudáfrica
							SYA->YA_SGLMEX := "ZA"
							SYA->YA_NASCIO := "Sudáfrica"
						Case cCod == "259" // Islas Faroe
							SYA->YA_SGLMEX := "FO"
							SYA->YA_NASCIO := "Islas Faroe"
						Case cCod == "423" // Labuán
							SYA->YA_SGLMEX := "LN"
							SYA->YA_NASCIO := "Labuán"
						Case cCod == "359" // Isla del Hombre
							SYA->YA_SGLMEX := "IH"
							SYA->YA_NASCIO := "Isla del Hombre"
						Case cCod == "741" // Singapur
							SYA->YA_SGLMEX := "SG"
							SYA->YA_NASCIO := "Singapur"
						Case cCod == "154" // Estado de Quatar
							SYA->YA_SGLMEX := "QA"
							SYA->YA_NASCIO := "Estado de Quatar"
					EndCase
				MsUnLock()
				SYA->(DbSkip())
			EndDo
		EndIf
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImprimeLog  ³ Autor ³GSANTACRUZ          ³ Data ³21/04/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ejecuta rutina para Visualizar/Imprimir log del proceso.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA088                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImprimeLog()
	
	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Local cTamanho	:= "M"
	Local cTitulo	:= STR0020 // "LOG  de DIOT"
	Local nX		:= 1
	Local aNewLog	:= {}
	Local nTamLog	:= 0
	Local aLogTitle	:= {}
	Local aLog		:= {}

	For nX := 1 To Len(aError)
		aAdd(aLog, aError[nX, 1])
	Next

	aNewLog := aClone(aLog)
	nTamLog := Len( aLog)
	aLog    := {}

	If !Empty( aNewLog )
		aAdd(aLog, aClone(aNewLog))
	EndIf

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
	MsAguarde({ ||fMakeLog(aLog, aLogTitle, , .T., FunName(), cTitulo, cTamanho, "P", aReturn, .F.)}, STR0021) // "Generando Log de errores..."

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FS088NCP  ºAutor  ³Gpe Santacruz       º Data ³  21/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculando impuestos de Notas de Credito                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FS088GERA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS088NCP()
	
	Local cQuery   := ""
	Local cQryAux  := ""
	Local cAlias	:= ""
	Local cFilSE5	:= xFilial("SE5")
	Local aArea		:= GetArea()
	Local nY		:= 0
	Local nPos		:= 0
	Local nPosD		:= 0
	Local nValTit	:= 0
	Local nPorcion	:= 0
	Local cFilSE2	:= xFilial("SE2")
	Local nImpues	:= 0
	Local nTaxa		:= 0
	Local nTasaMod	:= 0
	Local cFilUsr   := ""

	SA6->(DbSetORder(1)) //A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
	SE2->(DbSetOrder(6)) //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO

	cQuery := "SELECT E5_TIPODOC, E5_VALOR, E5_MOEDA, E5_DATA, E5_VLMOED2, E5_NUMERO, E5_TIPO," 
	cQuery += " E5_PREFIXO, E5_PARCELA, E5_LOJA, E5_CLIFOR, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_FILORIG, E5_TXMOEDA" 
	cQuery += " FROM " + RetSqlName("SE5")
	cQuery += " WHERE"
	cQuery += " D_E_L_E_T_= ''"
	cQuery += " AND E5_FILIAL = '" + cFilSE5 + "'"
	cQuery += " AND ("
	
	cQryAux := " ( E5_DATA BETWEEN '" + Dtos(dFecIni) + "' AND  '" + Dtos(dFecFin) + "'"
	cQryAux += " AND E5_TIPO = 'NCP') AND E5_SITUACA <> 'C' ) "

	If ExistBlock("FS088FINCP")
		cFilUsr	:=	ExecBlock("FS088FINCP",.F.,.F.,{cQryAux})
		If !Empty(cFilUsr)
			cQryAux := cFilUsr
		EndIf
	Endif

	cQuery += cQryAux

	cAlias := GetNextAlias()
	cQuery  := ChangeQuery(cQuery)
	DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .T.)
	TCSetField(cAlias, "E5_DATA", "D", 8, 0)

	Count To nMax
	ProcRegua(nMax)
	
	DBSelectArea(cAlias)
	(cAlias)->(DBGoTop())

	While !((cAlias)->(Eof()))	
		If (cAlias)->E5_FILORIG == cFilAnt
			If (cAlias)->E5_MOEDA <> "01"
				nMoedaBco := Val((cAlias)->E5_MOEDA)
			Else
				nMoedaBco := 1
			EndIf
			nValTit := xMoeda((cAlias)->E5_VALOR, nMoedaBco, 1, (cAlias)->E5_DATA, MsDecimais(1), (cAlias)->E5_TXMOEDA, 1)
			
			nTasaMod := (cAlias)->E5_TXMOEDA
			
			If SE2->(DBSeek(cFilSE2 + (cAlias)->E5_CLIFOR + (cAlias)->E5_LOJA +(cAlias)->E5_PREFIXO+(cAlias)->E5_NUMERO))
			
				If SE2->E2_MOEDA <> 1
					nTaxa := nTasaMod
				Else
					nTaxa := 1
				EndIf
	
				nPorcion := nValTit/(SE2->E2_VALOR*nTaxa)
				For nY := 1 To 10
					nImpues := 0
					cImp    := AllTrim(Str(nY))
					IF (SE2->(FieldPos("E2_VALIMP"+cImp)) > 0)
						If _cCpoIVC == cImp .OR. _cCpoIEPS == cImp //Tratamiento para IVA Incluido e IEPS
							nImpues := (&("SE2->E2_VALIMP"+cImp)*nTaxa*nPorcion) * (-1)
						Else
							nImpues := &("SE2->E2_VALIMP"+cImp)*nTaxa*nPorcion
						EndIf
					EndIf
	
					If nImpues > 0
						nPos := Ascan (aNCP,{|X| X[1]+X[2]+X[3]+X[4] == (cAlias)->E5_NUMERO + (cAlias)->E5_PREFIXO+(cAlias)->E5_CLIFOR + (cAlias)->E5_LOJA   })
						If nPos == 0
							aAdd(aNCP, {(cAlias)->E5_NUMERO, (cAlias)->E5_PREFIXO, (cAlias)->E5_CLIFOR, (cAlias)->E5_LOJA, SE2->E2_EMISSAO, 0, 0})
							nPosD := Len(aNCP)
						Else
							nPosD := nPos
						EndIf
	
						Do Case
							Case !cImp $  _CIMPRET // Solo que no sea impuesto retenido
								If (cAlias)->E5_TIPODOC == "ES"
									aNCP[nPosD,6] -= nImpues
								Else
									aNCP[nPosD,6] += nImpues
								EndIf
							Case cImp == _CIMPRET
								aNCP[nPosD,6] += nImpues
						EndCase
					EndIf
				Next nY
			EndIf
		EndIf
		IncProc()
		(cAlias)->(DBSkip())
	EndDo
	(cAlias)->(DBCloseArea())

	RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS088SM0     ³Autor ³ Gpe Santacruz        ³Data³21/04/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta de Sucursales en la pregunta                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Preguntas FISA087, FISA088, FISR088                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS088SM0()
	
	Local nTamFil	:= TamSx3("A1_FILIAL")[1]//len(cFilAnt)
	Local cTitulo	:= STR0022 // "Filiales"
	Local MvPar		:= ""
	Local MvParDef	:= ""
	Local cc		:= ''
	Local cc1		:= ''
	Local nJ		:= 0
	Local nGrupo	:= 0
	Local nCarac	:= 99
	Local nNumPer	:= 0
	Local nTamFin	:= 0
	Local nNumFil	:= 0
	
	Private aFils	:= {}

	MvPar := &(Alltrim(ReadVar())) // Carrega Nome da Variavel do Get em Questao
	MvRet := AllTrim(ReadVar())    // Iguala Nome da Variavel ao Nome variavel de Retorno

	DBSelectArea("SM0")
	SM0->(DBGoTop())
	While !SM0->(Eof() )
		If !Empty(SM0->M0_CODFIL) .And. aScan(aFils, {|x| SubStr(AllTrim(x),1,nTamFil) == AllTrim(SM0->M0_CODFIL)}) == 0
			aAdd(aFils, Substr(SM0->M0_CODFIL, 1, nTamfil) + " - " + AllTrim(SM0->M0_NOMECOM))
			MvParDef += Substr(SM0->M0_CODFIL,1,nTamfil) //SM0->M0_CODFIL
		EndIf
		SM0->(DBSkip())
	Enddo
	
	nTamFin := nTamfil + 1 	// Se suma 1 que reprecenta el de caracter ';'
	nNumFil := Len(aFils)	// Número sucursales
	nCarac := 60 // Dígitos soportados por el campo 
	nNumPer := Int(  nCarac / nTamFin)// Número de sucursales permitidas.
	If f_Opcoes(@MvPar, cTitulo, aFils, MvParDef,,,.f., nTamfil, nNumPer)
		cc := StrTran(mvpar,"*","")
		For nGrupo := 1 To Len(cc)
			cc1 += SubStr(cc, nGrupo, nTamfil) + ";" 
	   		nGrupo := nGrupo + ntamfil -1
	   		nJ++
		Next nGrupo
		If nJ > nNumPer
			MsgInfo(STR0036 + AllTrim(str(nNumPer)) + " " + STR0037) //"Solo se puede seleccionar un máximo de " // "Sucursales"
		Else
			&(MvRet) := AllTrim(cc1)	
		EndIf
	EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EsImporta³ Autor ³ Laura Medina          ³ Data ³ 21/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion que valida si esta instalado el modulo de importa- ³±±
±±³          ³ ciones y si la tabla RSC-Pedimentos de registro existe.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EsImporta()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA088                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EsImporta()
	
	lImporta := .F.

	ChkFile("RSC")
	If FindFunction("MATA447") .And. Select("RSC") <> 0 //Verificar si existe la funcion de Importacion en el RPO y la tabla RSC
		lImporta := .T.
	EndIf

Return lImporta

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS88FACIMP ³ Autor ³ gSantacruz            ³ Data ³21/04/14³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Extrae el DIOT de las facturas de impuestos generadas por  ³±±
±±³          ³ los pedimentos de imoprtacion.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS88FACIMP()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±@param  cDIOTver, caracter, Versión del DIOT 1-Anterior, 2-DIOT 2025     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA088                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS88FACIMP(cDIOTver)
	
	Local aArea			:= GetArea()
	Local cTESmovI		:= SuperGetMV("MV_MXTESIM",,"") //Codigo de TES de factura de impuestos de importacion
	Local cAliFacs		:= CriaTrab(Nil,.F.)
	Local cFilRSC		:= xFilial("RSC")
	Local cFilRSE		:= xFilial("RSE")
	Local cFilRSH		:= xFilial("RSH")
	Local cFilRSF		:= xFilial("RSF")
	Local cFilDB9		:= xFilial("DB9")
	Local cFilSA2		:= xFilial("SA2")
	Local cFilSD1		:= xFilial("SD1")
	Local cFilRSI		:= xFilial("RSI")
	Local cFilSE2		:= xFilial("SE2")
	Local cQryFacImp	:= ''
	Local cTmpFac		:= ''
	Local cQry			:= ''
	Local nImpImp		:= 0
	Local nBase			:= 0
	Local nPosD			:= 0
	Local nPos			:= 0
	Local nMax			:= 0
	Local nX			:= 0
	Local aImpD1		:= {}
	Local cFact			:= ''
	Local cSer			:= ''
	Local cPrv			:= ''
	Local cTda			:= ''
	Local dFecP			:= CToD("  /  /  ")
	Local nTamFac		:= GetSX3Cache("RSE_FACT","X3_TAMANHO")
	Local nTaxa			:= 0
	Local nPorcion		:= 0
	Local cRFC			:= ""
	Local cID			:= ""
	Local cTipT			:= ""
	Local cTipO			:= ""
	Local cPai			:= ""
	Local cProdT		:= "1"
	Local cTipoIVA		:= "1"

	Default cDIOTver 	:= "1"	
	
	/* Array retornado
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aPgoDet                              ³
	//³1 - Factura                          ³
	//³2 - Serie                            ³
	//³3 - Nunero de parcialidad            ³
	//³4 - Proveedor                        ³
	//³5 - Tienda                           ³
	//³6 - Fecha emision                    ³
	//³7 - Num de OP o docto con que sepago ³
	//³8 - Tipo de documento con que se pago³
	//³9 - Fecha de pago                    ³
	//³10 - Importe de pago                 ³
	//³11 - Tipo de pago                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/

	CursorWait()
		DBSelectArea("RSC")
		DBSelectArea("RSE")
		DBSelectArea("RSF")
		DBSelectArea("RSH")
		RSH->(DBSetOrder(1)) //RSH_FILIAL + RSH_NUMPED + RSH_FACT + RSH_SERIE + RSH_PROV + RSH_TDA + RSH_ITEM + RSH_SECC + RSH_IMPUES

		DBSelectArea("DB9")
		DBSelectArea("SF4")
		DBSelectArea("SFC")
		DBSelectArea("SFB")
		DBSelectArea("RSI")
		RSH->(DBSetOrder(1)) //RSH_FILIAL + RSH_NUMPED + RSH_FACT + RSH_SERIE + RSH_PROV + RSH_TDA + RSH_ITEM + RSH_SECC + RSH_IMPUES

		DBSelectArea("RSG")
		RSG->(DBSetOrder(1)) //RSG_FILIAL + RSG_NUMPED + RSG_FACT + RSG_SERIE + RSG_PROV + RSG_TDA + RSG_ITEM + RSG_SECC
		
		DBSelectArea("SA2")
		SA2->(DBSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
		
		If !SF4->(DBSeek(xFilial("SF4")+cTESmovI))
		    aAdd(aError, {STR0023 + cTESmovI + STR0024 }) // "No existe la TES " "' Necesaria para generara el DIOT de facturas de impuestos de IMPORTACION"
		    Return
		EndIf
		If !SFC->(DBSeek(xFilial("SFC")+SF4->F4_CODIGO))
		    aAdd(aError, {STR0025 + SF4->F4_CODIGO + STR0026 +cTESmovI + STR0027}) // "No existe la IMPUESTO " "' asociado a la TES " " Necesario para generara el DIOT de facturas de impuestos de IMPORTACION"
			Return
		EndIf
		If !SFB->(DBSeek(xFilial("SFB")+SFC->FC_IMPOSTO))
		    aAdd(aError, {STR0025 + SFC->FC_IMPOSTO + STR0026 +cTESmovI + STR0027})// "No existe la IMPUESTO " "' asociado a la TES " " Necesario para generara el DIOT de facturas de impuestos de IMPORTACION"
			Return
		EndIf

		//Qry para extraer las pedimentos que continen facturas de impuestos de importacion PAGADAS
		cQryFacImp := "(SELECT DISTINCT(RSC_NUMPED) FROM " + RetSqlName("RSC") + " RSC, " + RetSqlName("SE2") + " SE2, " + RetSqlName("DB9") + " DB9"
		cQryFacImp += " WHERE RSC_FACIMP = E2_NUM AND RSC_SERIMP = E2_PREFIXO AND RSC_AGENTE = DB9_COD AND DB9_PROV = E2_FORNECE AND DB9_TDA = E2_LOJA"
		cQryFacImp += " AND RSC_FILIAL = '" + cFilRSC + "' AND E2_FILIAL = '" + cFilSE2 + "' AND DB9_FILIAL = '" + cFilDB9 + "'"
		cQryFacImp += " AND E2_BAIXA BETWEEN '" + Dtos(dFecIni) + "' AND  '" + Dtos(dFecFin) + "' AND E2_TIPO = 'NF ' AND E2_SALDO = 0"
		cQryFacImp += " AND RSC_STATUS = '2'" 
		cQryFacImp += " AND RSC.D_E_L_E_T_ = '' AND DB9.D_E_L_E_T_ = '' AND SE2.D_E_L_E_T_ = '') "

		cQry := " SELECT RSE_NUMPED, RSE_PROV, RSE_TDA, RSE_FACT, RSE_SERIE, RSF_ITEM, RSF_PRODUC, RSE_TIPO, RSC_TC, DB9_PROV, DB9_TDA,"
		cQry += " RSC_FACIMP, RSC_SERIMP, RSC_FCHPGO, A2_CGC, A2_IDFISCA, A2_TIPOTER, A2_TPOPER, A2_PAIS, RSE_VALMER"
		cQry += " FROM " + RetSqlName("RSE") + " RSE, " + RetSqlName("RSF") + " RSF, " + RetSqlName("RSC") + " RSC, "
		cQry += RetSqlName("DB9") + " DB9, " + RetSqlName("SA2") + " SA2 WHERE"
		cQry += " RSE_NUMPED = RSF_NUMPED AND RSE_ITEM = RSF_ITEDOC"
		cQry += " AND RSE_TIPO IN('1','3') AND RSC_NUMPED=RSE_NUMPED"
		cQry += " AND RSC.D_E_L_E_T_ = '' AND RSE.D_E_L_E_T_ = '' AND RSF.D_E_L_E_T_ = '' AND DB9.D_E_L_E_T_ = '' AND SA2.D_E_L_E_T_ = ''"
		cQry += " AND RSC_AGENTE = DB9_COD AND DB9_PROV = A2_COD AND DB9_TDA = A2_LOJA"
		cQry += " AND RSE_NUMPED IN " + cQryFacImp
		cQry += " AND RSC_FILIAL = '" + cFilRSC + "' AND RSE_FILIAL = '" + cFilRSE + "' AND RSF_FILIAL = '" + cFilRSF + "' AND DB9_FILIAL = '" + cFilDB9 + "' AND A2_FILIAL = '" + cFilSA2 + "' "
		cQry += " ORDER BY RSE_NUMPED,RSC_FACIMP,RSC_SERIMP,DB9_PROV,DB9_TDA,RSE_FACT,RSE_SERIE,RSE_PROV,RSE_TDA,RSF_ITEM,RSF_PRODUC"
		cQry := ChangeQuery(cQry)

		DBUseArea(.T., "TOPCONN", TcGenQry( , , cQry), cAliFacs, .T., .T.)
		TCSetField(cAliFacs, "RSC_FCHPGO", "D", 8, 0)
	CursorArrow()

	Count To nMax
	
	ProcRegua(nMax)
	
	DBSelectArea(cAliFacs)
	(cAliFacs)->(DbGotop())

	Do While !(cAliFacs)->(EoF())
		If !SD1->(DBSeek(cFilSD1 + (cAliFacs)->RSC_FACIMP + (cAliFacs)->RSC_SERIMP + (cAliFacs)->DB9_PROV + (cAliFacs)->DB9_TDA))
			// "No encontro factura de impuestos " " del pedimento " " y no se proceso!"
			aAdd(aError, {STR0028 + (cAliFacs)->RSC_FACIMP + " " + (cAliFacs)->RSC_SERIMP + STR0029 + (cAliFacs)->RSE_NUMPED + STR0030})
			cTmpFac := (cAliFacs)->RSE_NUMPED + (cAliFacs)->RSC_FACIMP + (cAliFacs)->RSC_SERIMP + (cAliFacs)->DB9_PROV
			Do While !(cAliFacs)->(EoF()) .AND. cTmpFac == (cAliFacs)->RSE_NUMPED + (cAliFacs)->RSC_FACIMP + (cAliFacs)->RSC_SERIMP + (cAliFacs)->DB9_PROV
				(cAliFacs)->(DBSkip())
			EndDo
			Loop
		EndIf
		    
	    nImpImp := 0
    	aImpD1  := DefImposto(SD1->D1_TES)
   		For nX := 1 To Len(aImpD1)
			nImpImp := &("SD1->D1_"+ aImpD1[nX][8])
		Next nX

		cTmpFac	:= (cAliFacs)->RSE_NUMPED+(cAliFacs)->RSC_FACIMP+(cAliFacs)->RSC_SERIMP+(cAliFacs)->DB9_PROV+(cAliFacs)->DB9_TDA+(cAliFacs)->RSE_FACT+(cAliFacs)->RSE_SERIE+(cAliFacs)->RSE_PROV+(cAliFacs)->RSE_TDA
		nBase  	:= 0
		
		cRFC   	:= ""
		cID    	:= ""
		cTipT  	:= ""
		cTipO  	:= ""
		cPai   	:= ""
		
		If SA2->(MSSeek(cFilSA2 + (cAliFacs)->RSE_PROV + (cAliFacs)->RSE_TDA))
			cRFC   	:= SA2->A2_CGC
			cID    	:= SA2->A2_IDFISCA
			cTipT  	:= SA2->A2_TIPOTER
			cTipO  	:= SA2->A2_TPOPER
			cPai   	:= SA2->A2_PAIS
		EndIf
		
		cFact  	:= (cAliFacs)->RSE_FACT
		cSer   	:= (cAliFacs)->RSE_SERIE
		cPrv   	:= (cAliFacs)->RSE_PROV
		cTda   	:= (cAliFacs)->RSE_TDA
		dFecP 	:= (cAliFacs)->RSC_FCHPGO
		cFacImp	:= (cAliFacs)->RSC_FACIMP
		cSerImp	:= (cAliFacs)->RSC_SERIMP
		cProvImp:= (cAliFacs)->DB9_PROV
		cTdaImp	:= (cAliFacs)->DB9_TDA
		nBase  	:= (cAliFacs)->RSE_VALMER*(cAliFacs)->RSC_TC //VALOR FACTURA

		Do While !(cAliFacs)->(EoF()) .AND. cTmpFac ==(cAliFacs)->RSE_NUMPED+(cAliFacs)->RSC_FACIMP+(cAliFacs)->RSC_SERIMP+(cAliFacs)->DB9_PROV+(cAliFacs)->DB9_TDA+(cAliFacs)->RSE_FACT+(cAliFacs)->RSE_SERIE+(cAliFacs)->RSE_PROV+(cAliFacs)->RSE_TDA
			If RSI->(DBSeek(cFilRSI+(cAliFacs)->RSE_NUMPED+(cAliFacs)->RSE_FACT+(cAliFacs)->RSE_SERIE+(cAliFacs)->RSE_PROV+(cAliFacs)->RSE_TDA+(cAliFacs)->RSF_ITEM))
				Do While !RSI->(EoF()) .AND. RSI->RSI_FILIAL+ RSI->RSI_NUMPED+RSI->RSI_FACT+ RSI->RSI_SERIE+ RSI->RSI_PROV+ RSI->RSI_TDA+ RSI->RSI_ITEM==CFILRSI+(cAliFacs)->RSE_NUMPED+(cAliFacs)->RSE_FACT+(cAliFacs)->RSE_SERIE+(cAliFacs)->RSE_PROV+(cAliFacs)->RSE_TDA+(cAliFacs)->RSF_ITEM
					nBase += RSI->RSI_INCREM //VALOR MAS INCREMENTBALES, NO COSIDERA VALOR DE GASTOS INTERNACIONALES POR QUE SE REFLEJAN POR FACTURA
					RSI->(DBSkip())
				EndDo
			EndIf
			If RSH->(DBSeek(cFilRSH+(cAliFacs)->RSE_NUMPED+(cAliFacs)->RSE_FACT+(cAliFacs)->RSE_SERIE+(cAliFacs)->RSE_PROV+(cAliFacs)->RSE_TDA+(cAliFacs)->RSF_ITEM))
				Do While !RSH->(EoF()) .AND. RSH->RSH_FILIAL+ RSH->RSH_NUMPED+RSH->RSH_FACT+ RSH->RSH_SERIE+ RSH->RSH_PROV+ RSH->RSH_TDA+ RSH->RSH_ITEM==CFILRSH+(cAliFacs)->RSE_NUMPED+(cAliFacs)->RSE_FACT+(cAliFacs)->RSE_SERIE+(cAliFacs)->RSE_PROV+(cAliFacs)->RSE_TDA+(cAliFacs)->RSF_ITEM
					nBase += RSH->RSH_IMPPAG // impuestos que aplican por item
					RSH->(DBSkip())
				EndDo
			EndIf
			(cAliFacs)->(DBSkip())
		EndDo

		cFactOri := cFact
		If "FLETE" $ Upper(cFact)  //Verifica factura que contiene un flete incluido
		   nPos := At("FLETE", cFact)
		   cFact:= PADR(SubStr(cFact, 1, nPos - 1), nTamFac, ' ')
		EndIf
		nPos := Ascan(aPgosDIOT, {|X| X[1]+X[2]+X[3]+X[4]+X[5]+X[6] == ""+cFact+cSer+cPrv+cTda })

		If nPos == 0
			If cDIOTver == "2"
				aAdd(aPgosDIOT, {"", cFact, cSer, '', cPrv, cTda, "", cTipT, cTipO, cRFC, cID, cPai, dFecP, ;
						0,0,0,0,0,0,0,0,0,0, ;
						0,0,0,0,0,0,0,0,0,0, ;
						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, ;
						0,0,0,0,0,0,0 ;
						})
			Else
				aAdd(aPgosDIOT, {"",cFact,cSer,'',cPrv,cTda,nBase,nBase,'','','','',dFecP,0,0,0,0,0,0,0,0,0,0,cRFC,cID,cTipT,cTipO,cPai,"NF",0,0,0})
			EndIf
			nPosD := Len(aPgosDIOT)
		Else
			nPosD := nPos
		EndIf

		If cDIOTver == "2"
			Do Case
			Case (nImpImp == 15 .OR. nImpImp == 16) .And. cProdT = '1'
				aPgosDIOT[nPosD, 20] += nBase
				If cTipoIVA == "1" //1-Acreditable No Proporcional
					aPgosDIOT[nPosD, 30] += (nImpImp / 100) * nBase
				EndIf
			EndCase
		Else
			Do Case
				Case nBase == 0 .AND. nImpImp == 0 //IVA EXENTO
					aPgosDIOT[nPosD,20] += nBase
				Case nImpImp == 10 	//IVA 10 ANTES DEL 2010
					aPgosDIOT[nPosD,21] += nBase
				Case nImpImp == 11 //IVA 11
					aPgosDIOT[nPosD,21] += nBase
				Case nImpImp == 15 //IVA 15 ANTES DE 2010
					aPgosDIOT[nPosD,22] += nBase
				Case nImpImp == 16  //IVA 16
					aPgosDIOT[nPosD,22] += nBase
			EndCase
			aPgosDIOT[nPosD,31] += (nImpImp / 100) * nBase
		EndIf
		

		//Busca el pago y saca la parte en porporcion al pago efectuado
		nX := aScan(aPagos, {|x| x[1] == cFacImp .and.  x[2] == cSerImp .and.   x[4] == cProvImp.and.  x[5] == cTdaImp})
		If nX > 0
			SE2->(DBSetOrder(6)) //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
			If SE2->(DBSeek(cFilSE2 + cProvImp + cTdaImp + cSerImp + cFacImp ))
				nTaxa := 1
				If SE2->E2_MOEDA <> 1
					nTaxa := SE2->E2_TXMOEDA
				EndIf
				nPorcion := aPagos[nX,6] / (SE2->E2_VALOR * nTaxa)
				aAdd(aPgoDet, {cFactOri, cSer, '', cPrv, cTda, SD1->D1_EMISSAO, IIf(!Empty(aPagos[nX,7]), aPagos[nX,7], aPagos[nX,10]), IIf (!Empty(aPagos[nX,7]), "OP", aPagos[nX,10]), aPagos[nX,9], nbase * NPORCION, ''})
			EndIf
		EndIf
	EndDo
	(cAliFacs)->(DBCloseArea())

	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS88EXTRA ³ Autor ³ gSantacruz           | Data ³ 21/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Extrae el DIOT de las facturas de empuestos generadas por  ³±±
±±³          ³ los pedimentos de imoprtacion y que sos extraccion por     ³±±
±±³          ³ pedimento.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS88EXTRA(cDIOTver)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±@param  cDIOTver, caracter, Versión del DIOT 1-Anterior, 2-DIOT 2025     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA088                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS88EXTRA(cDIOTver)
	
	Local aArea			:= GetArea()
	Local cTESmovI		:= SuperGetMV("MV_MXTESIM",,"") //Codigo de TES de factura de impuestos de importacion
	Local cAliFacs		:= CriaTrab(Nil,.F.)
	Local cFilRSC		:= xFilial("RSC")
	Local cFilRSH		:= xFilial("RSH")
	Local cFilDB9		:= xFilial("DB9")
	Local cFilSA2		:= xFilial("SA2")
	Local cFilSD1		:= xFilial("SD1")
	Local cFilSE2		:= xFilial("SE2")
	Local cFilRSI		:= xFilial("RSI")
	Local cQryFacImp	:= ''
	Local cTmpFac		:= ''
	Local cQry			:= ''
	Local nImpImp		:= 0
	Local nBase			:= 0
	Local nPosD			:= 0
	Local nPos			:= 0
	Local nMax			:= 0
	Local nX			:= 0
	Local aImpD1		:= {}
	Local cFact			:= ''
	Local cSer			:= ''
	Local cPrv			:= ''
	Local cTda			:= ''
	Local dFecP			:= CToD("  /  /  ")
	Local cPedExt		:= SuperGetMV("MV_MXEXTRA", .F., "G1") //Pedimentos de Extraccion de almacen fiscal
	Local nTaxa			:= 0
	Local nPorcion		:= 0
	Local cTmp			:= ''
	Local cProdT		:= "1"
	Local cTipoIVA		:= "1"

	Default cDIOTver 	:= "1"	

	If !Empty(cPedExt)
		cPedExt	:= AllTrim(cPedExt)
		cTmp	:= cPedExt
		nX		:= 1
		cNewExp	:= ''
		Do While nX <= Len(cPedExt)
			cNewExp	:= cNewExp + "'" + SubStr(cTmp,1,2) + "',"
			cTmp	:= SubStr(cTmp, 4, Len(cTmp))
			nX		:= nX + 3
		EndDo
		cPedExt	:= SubStr(cNewExp, 1, Len(cNewExp) - 1)
	EndIf

	CursorWait()
		DBSelectArea("RSC")
		DBSelectArea("RSE")
		DBSelectArea("RSF")
		DBSelectArea("RSH")
		RSH->(DBSetOrder(1)) //RSH_FILIAL + RSH_NUMPED + RSH_FACT + RSH_SERIE + RSH_PROV + RSH_TDA + RSH_ITEM + RSH_SECC + RSH_IMPUES

		DBSelectArea("DB9")
		DBSelectArea("SF4")
		DBSelectArea("SFC")
		DBSelectArea("SFB")
		DBSelectArea("RSI")
		RSH->(DBSetOrder(1)) //RSH_FILIAL + RSH_NUMPED + RSH_FACT + RSH_SERIE + RSH_PROV + RSH_TDA + RSH_ITEM + RSH_SECC + RSH_IMPUES

		DBSelectArea("SE2")
		SE2->(DBSetOrder(6)) //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO

		If !SF4->(DBSeek(xFilial("SF4")+cTESmovI))
			aAdd(aError, {STR0023 + cTESmovI + STR0024}) // "No existe la TES " "' Necesaria para generar el DIOT de facturas de impuestos de IMPORTACION"
			Return
		EndIf
		If !SFC->(DBSeek(xFilial("SFC")+SF4->F4_CODIGO))
			aAdd(aError, {STR0025 + SF4->F4_CODIGO + STR0026 + cTESmovI + STR0027}) // "No existe el IMPUESTO " "' asociado a la TES " " Necesario para generar el DIOT de facturas de impuestos de IMPORTACION"
			Return
		EndIf
		If !SFB->(DBSeek(xFilial("SFB")+SFC->FC_IMPOSTO))
			aAdd(aError, {STR0025 + SFC->FC_IMPOSTO + STR0026 + cTESmovI+ STR0027}) // "No existe el IMPUESTO " "' asociado a la TES " " Necesario para generar el DIOT de facturas de impuestos de IMPORTACION"
			Return
		EndIf
		If Empty(cPedExt)
			aAdd(aError, {STR0038}) // "El parámetro MV_MXEXTRA se encuentra vacío. Infórmelo e intente nuevamente."
			Return
		EndIf

		//Qry para extraer las pedimentos que continen facturas de impuestos de importacion PAGADAS
		cQryFacImp := "(SELECT DISTINCT(RSC_NUMPED) FROM " + RetSqlName("RSC") + " RSC, " + RetSqlName("SE2") + " SE2, " + RetSqlName("DB9") + " DB9"
		cQryFacImp += " WHERE RSC_FACIMP = E2_NUM AND RSC_SERIMP = E2_PREFIXO AND RSC_AGENTE = DB9_COD AND DB9_PROV = E2_FORNECE AND  DB9_TDA = E2_LOJA "
		cQryFacImp += " AND RSC_FILIAL = '" + cFilRSC + "' AND E2_FILIAL = '" + cFilSE2 + "' AND DB9_FILIAL = '" + cFilDB9 + "' "
		cQryFacImp += " AND E2_BAIXA BETWEEN '" + Dtos(dFecIni) + "' AND '" + Dtos(dFecFin) + "' AND E2_TIPO = 'NF ' AND E2_SALDO = 0"
		cQryFacImp += " AND RSC_STATUS = '2' AND RSC_CVEPED IN(" + cPedExt + ") "
		cQryFacImp += " AND RSC.D_E_L_E_T_ = '' AND DB9.D_E_L_E_T_ = '' AND SE2.D_E_L_E_T_ = '' ) "

		cQry := " SELECT RSI_NUMPED, RSI_PROV, RSI_TDA, RSI_FACT, RSI_SERIE, RSI_ITEM, RSI_PROD, RSI_CIF, RSC_TC, DB9_PROV, DB9_TDA,"
		cQry += " RSC_FACIMP, RSC_SERIMP, RSC_FCHPGO, A2_CGC, A2_IDFISCA, A2_TIPOTER, A2_TPOPER, A2_PAIS"
		cQry += " FROM " + RetSqlName("RSI")+" RSI, " + RetSqlName("RSC") + " RSC, "
		cQry += RetSqlName("DB9") + " DB9, " + RetSqlName("SA2") + " SA2  WHERE"
		cQry += " RSI_NUMPED = RSC_NUMPED"
		cQry += " AND RSI.D_E_L_E_T_ = '' AND RSC.D_E_L_E_T_ = '' AND DB9.D_E_L_E_T_ = '' AND SA2.D_E_L_E_T_ = ''"
		cQry += " AND RSC_AGENTE = DB9_COD AND DB9_PROV = A2_COD AND DB9_TDA = A2_LOJA"
		cQry += " AND RSI_NUMPED IN " + cQryFacImp
		cQry += " AND RSC_FILIAL = '" + cFilRSC + "' AND RSI_FILIAL = '" + cFilRSI + "' AND  DB9_FILIAL = '" + cFilDB9 + "' AND A2_FILIAL = '" + cFilSA2 + "'"
		cQry += " ORDER BY RSI_NUMPED, RSC_FACIMP, RSC_SERIMP, DB9_PROV, DB9_TDA, RSI_FACT, RSI_SERIE, RSI_PROV, RSI_TDA"
		cQry := ChangeQuery(cQry)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliFacs,.T.,.T.)
		TCSetField(cAliFacs,"RSC_FCHPGO","D",8,0)
	CursorArrow()

	Count To nMax
	ProcRegua(nMax)
	
	DBSelectArea(cAliFacs)
	(cAliFacs)->(DbGoTop())

	Do While !(cAliFacs)->(EoF())
		If !SD1->(DBSeek(cFilSD1+(cAliFacs)->RSC_FACIMP+(cAliFacs)->RSC_SERIMP+(cAliFacs)->DB9_PROV+(cAliFacs)->DB9_TDA))
			// "No encontro factura de impuestos " " del pedimento " " y no se proceso!"
			aAdd(aError, {STR0028 + (cAliFacs)->RSC_FACIMP +" "+ (cAliFacs)->RSC_SERIMP+ STR0029 +(cAliFacs)->RSI_NUMPED+ STR0030})
			cTmpFac := (cAliFacs)->RSI_NUMPED+(cAliFacs)->RSC_FACIMP+(cAliFacs)->RSC_SERIMP+(cAliFacs)->DB9_PROV
			Do While !(cAliFacs)->(EoF()) .AND. cTmpFac == (cAliFacs)->RSI_NUMPED+(cAliFacs)->RSC_FACIMP+(cAliFacs)->RSC_SERIMP+(cAliFacs)->DB9_PROV
				(cAliFacs)->(dbSkip())
			EndDo
			Loop
		EndIf
		nImpImp := 0

		aImpD1 := DefImposto(SD1->D1_TES)
		For nX := 1 To Len(aImpD1)
			nImpImp := &("SD1->D1_"+ aImpD1[nX][8])
		Next

		cTmpFac  := (cAliFacs)->RSI_NUMPED+(cAliFacs)->RSC_FACIMP+(cAliFacs)->RSC_SERIMP+(cAliFacs)->DB9_PROV+(cAliFacs)->DB9_TDA+(cAliFacs)->RSI_FACT+(cAliFacs)->RSI_SERIE+(cAliFacs)->RSI_PROV+(cAliFacs)->RSI_TDA
		nBase    := 0
		cRFC     := (cAliFacs)->A2_CGC
		cID      := (cAliFacs)->A2_IDFISCA
		cTipT    := (cAliFacs)->A2_TIPOTER
		cTipO    := (cAliFacs)->A2_TPOPER
		cPai     := (cAliFacs)->A2_PAIS
		cFact    := (cAliFacs)->RSI_FACT
		cSer     := (cAliFacs)->RSI_SERIE
		cPrv     := (cAliFacs)->RSI_PROV
		cTda     := (cAliFacs)->RSI_TDA
		dFecP    := (cAliFacs)->RSC_FCHPGO
		cFacImp  := (cAliFacs)->RSC_FACIMP
		cSerImp  := (cAliFacs)->RSC_SERIMP
		cProvImp := (cAliFacs)->DB9_PROV
		cTdaImp  := (cAliFacs)->DB9_TDA

		Do While !(cAliFacs)->(EoF()) .AND. cTmpFac ==(cAliFacs)->RSI_NUMPED+(cAliFacs)->RSC_FACIMP+(cAliFacs)->RSC_SERIMP+(cAliFacs)->DB9_PROV+(cAliFacs)->DB9_TDA+(cAliFacs)->RSI_FACT+(cAliFacs)->RSI_SERIE+(cAliFacs)->RSI_PROV+(cAliFacs)->RSI_TDA
			nBase += (cAliFacs)->RSI_CIF
			IF RSH->(DBSeek(cFilRSH+(cAliFacs)->RSI_NUMPED+(cAliFacs)->RSI_FACT+(cAliFacs)->RSI_SERIE+(cAliFacs)->RSI_PROV+(cAliFacs)->RSI_TDA+(cAliFacs)->RSI_ITEM))
				Do While !RSH->(EoF()) .AND. RSH->RSH_FILIAL+ RSH->RSH_NUMPED+RSH->RSH_FACT+ RSH->RSH_SERIE+ RSH->RSH_PROV+ RSH->RSH_TDA+ RSH->RSH_ITEM == ;
												cFilRSH+(cAliFacs)->RSI_NUMPED+(cAliFacs)->RSI_FACT+(cAliFacs)->RSI_SERIE+(cAliFacs)->RSI_PROV+(cAliFacs)->RSI_TDA+(cAliFacs)->RSI_ITEM
					
					nBase += RSH->RSH_IMPPAG // Impuestos que aplican por item
					RSH->(DBSkip())
				EndDo
			EndIf
			(cAliFacs)->(DBSkip())
		EndDo

		nPos := Ascan(aPgosDIOT,{|X| X[1]+X[2]+X[3]+X[4]+X[5]+X[6] == ""+cFact+cSer+cPrv+cTda })
		If nPos == 0

			If cDIOTver == "2"
				aAdd(aPgosDIOT, {"", cFact, cSer, '', cPrv, cTda, "", cTipT, cTipO, cRFC, cID, cPai, dFecP, ;
						0,0,0,0,0,0,0,0,0,0, ;
						0,0,0,0,0,0,0,0,0,0, ;
						0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, ;
						0,0,0,0,0,0,0 ;
						})
			Else
				aAdd(aPgosDIOT, {"", cFact, cSer, '', cPrv, cTda, nBase, nBase, '', '', '', '', dFecP, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,;
			 					cRFC, cID, cTipT, cTipO, cPai, "NF", 0, 0, 0})
			EndIf
		
			nPosD := Len(aPgosDIOT)
		Else
			nPosD := nPos
		EndIf

		If cDIOTver == "2"

			Do Case
			Case (nImpImp == 15 .OR. nImpImp == 16) .And. cProdT = '1'
				aPgosDIOT[nPosD, 20] += nBase
				If cTipoIVA == "1" //1-Acreditable No Proporcional
					aPgosDIOT[nPosD, 30] += (nImpImp / 100) * nBase
				EndIf
			EndCase

		Else

			Do Case
				Case nBase == 0 .AND. nImpImp == 0 //IVA EXENTO
					aPgosDIOT[nPosD,20] += nBase
				Case nImpImp == 10 //IVA 10 ANTES DEL 2010
					aPgosDIOT[nPosD,21] += nBase
				Case nImpImp == 11 //IVA 11
					aPgosDIOT[nPosD,21] += nBase
				Case nImpImp == 15 //IVA 15 ANTES DE 2010
					aPgosDIOT[nPosD,22] += nBase
				Case nImpImp == 16  //IVA 16
					aPgosDIOT[nPosD,22] += nBase
			EndCase
		
			aPgosDIOT[nPosD,31] += nBase *(nImpImp / 100)
		EndIf

		//Busca el pago y saca la parte en porporcion al pago efectuado
		//VERIFICAR QUE GRABE BIEN LOS PAGOS EN CDX
		nX := aScan(aPagos, {|x| x[1] == cFacImp .and.  x[2] == cSerImp .and.   x[4] == cProvImp.and.  x[5] == cTdaImp})
		If nX > 0
			SE2->(DBSetOrder(6)) //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
			If SE2->(DBSeek(CFILSE2 +  cProvImp+ cTdaImp+cSerImp+cFacImp ))
				nTaxa := 1
				If SE2->E2_MOEDA <> 1
					nTaxa := SE2->E2_TXMOEDA
				EndIf
				nPorcion := aPagos[nX,6]/(SE2->E2_VALOR*nTaxa)
				aAdd(aPgoDet, {cFact, cSer, '', cPrv, cTda, SD1->D1_EMISSAO, IIf(!Empty(aPagos[nX,7]), aPagos[nX,7], aPagos[nX,10]),;
				 				IIf(!Empty(aPagos[nX,7]), "OP", aPagos[nX,10]), aPagos[nX,9], nBase * nPorcion, ''})
			EndIf
		EndIf
	EndDo
	(cAliFacs)->(DBCloseArea())

	RestArea(aArea)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS088DEDUCC  ³Autor ³ Gpe Santacruz        ³Data³25/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera deducciones                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FS088GERA                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS088DEDUCC()
	
	Local cQuery	:= ''
	Local cQryAux	:= ''
	Local cAlias	:= ''
	Local lGraba	:= .T.
	Local nLenDoc	:= GetSX3Cache("E2_NUM","X3_TAMANHO")
	Local cDocumen	:= ''
	Local cOrdPago	:= ""
	Local cNumOrPg	:= ""
	Local aArea		:= GetArea()
	Local cFilUsr	:= ""
	Local oExecA    := Nil

	cQuery := "SELECT E5_DATA, E5_TIPO, E5_TIPODOC, E5_VALOR,E5_MOEDA, E5_VLMOED2, E5_ORDREC, E5_MOTBX, "
	cQuery += "E5_DTDISPO, E5_NUMERO, E5_PREFIXO, E5_PARCELA, E5_FORNECE, E5_CLIENTE, E5_LOJA, E5_DOCUMEN, "
	cQuery += "E5_CLIFOR, E5_TXMOEDA, E5_MOEDA, E5_RECPAG, E5_NUMLIQ, E5_FILIAL, E5_FILORIG, R_E_C_N_O_ "
	cQuery += "FROM ? SE5 "
	cQuery += "WHERE"
	cQuery += " D_E_L_E_T_= ?"
	cQuery += " AND E5_FILORIG = ? AND  E5_SITUACA <> 'C' "
	cQuery += " AND E5_DATA BETWEEN ? AND  ? "
	cQryAux += " AND (E5_MOTBX = 'CMP' OR E5_MOTBX = 'NOR') "
	cQryAux += " AND  ((E5_TIPODOC IN ('VL','BA','CP') AND E5_RECPAG='P') OR (E5_TIPODOC='ES' and E5_RECPAG='R'))"
	cQryAux += " ORDER BY E5_ORDREC"

	/*	Ponto de entrada para alteracao do filtro */
	If ExistBlock("IETUFILP")
		cFilUsr	:=	ExecBlock("IETUFILP",.F.,.F.,{cQryAux})
		If !Empty(cFilUsr)
			cQryAux := cFilUsr
		EndIf
	EndIf
	cQuery += " ? "

	cQuery := ChangeQuery(cQuery)
	oExecA := FwExecStatement():New(cQuery)

	oExecA:SetUnsafe(1,RetSqlName("SE5"))
	oExecA:SetString(2,' ') 
	oExecA:SetString(3,cFilAnt)
	oExecA:setDate(4,dFecIni)
	oExecA:setDate(5,dFecFin)
	oExecA:SetUnsafe(6,cQryAux)

	cAlias := oExecA:OpenAlias()
	TCSetField(cAlias, "E5_DATA", "D", 8, 0)
	
	Count To nMax
	
	DbSelectArea("SE2")
	SE2->(dbSetOrder(1)) //E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA

	ProcRegua(nMax) // Numero de registros a procesar
	(cAlias)->(DBGoTop())

	Do While !(cAlias)->(EoF())
		lGraba   := .F.
		cDocumen := SubStr((cAlias)->E5_DOCUMEN ,1 , 3 + nLenDoc + 1 + 3)
		cOrdPago := ""
		
		SE2->(DBGoTop())
		IF AllTrim((cAlias)->E5_MOTBX) == "CMP"
			If AllTrim((cAlias)->E5_TIPODOC) == "ES"  //SI ES CANCELACION
				If AllTrim((cAlias)->E5_TIPO) == "NF"  //SI ES FACTURA
					If SE2->(DbSeek(xFilial("SE2")+(cAlias)->E5_PREFIXO+(cAlias)->E5_NUMERO+(cAlias)->E5_PARCELA+(cAlias)->E5_TIPO+(cAlias)->E5_CLIFOR+(cAlias)->E5_LOJA,.F.))
						If Empty((cAlias)->E5_MOEDA) .Or. (!(cAlias)->E5_VALOR==(cAlias)->E5_VLMOED2 .And. !(cAlias)->E5_VLMOED2==0)
							nValTit := xMoeda((cAlias)->E5_VLMOED2,SE2->E2_MOEDA,1,(cAlias)->E5_DATA,MsDecimais(1),SE2->E2_TXMOEDA)
						EndIf
					EndIf
				Else
					If(DbSeek(xFilial("SE2")+cDocumen,.f.))
						If Empty((cAlias)->E5_MOEDA) .Or. (!(cAlias)->E5_VALOR==(cAlias)->E5_VLMOED2 .And. !(cAlias)->E5_VLMOED2==0)
							nValTit := xMoeda((cAlias)->E5_VLMOED2,SE2->E2_MOEDA,1,(cAlias)->E5_DATA,MsDecimais(1),SE2->E2_TXMOEDA)
						EndIf
					EndIf
				EndIf
				nValTit := nValTit*(-1)
				lGraba := .t.
			Else
				If AllTrim((cAlias)->E5_TIPO) == "NF"
					SE2->(DbSeek(xFilial("SE2") + (cAlias)->E5_PREFIXO + (cAlias)->E5_NUMERO + (cAlias)->E5_PARCELA + (cAlias)->E5_TIPO + (cAlias)->E5_CLIFOR + (cAlias)->E5_LOJA , .f.))
					If !(cAlias)->E5_VALOR == (cAlias)->E5_VLMOED2 .And. !(cAlias)->E5_VLMOED2 == 0
						nTaxaSEK := Round( (cAlias)->E5_VALOR / (cAlias)->E5_VLMOED2 , MsDecimais(1) )
						nValTit := xMoeda((cAlias)->E5_VLMOED2,SE2->E2_MOEDA,1,(cAlias)->E5_DATA,MsDecimais(1),nTaxaSEK)
					Else
						nValTit := xMoeda((cAlias)->E5_VLMOED2,SE2->E2_MOEDA,1,(cAlias)->E5_DATA,MsDecimais(1),SE2->E2_TXMOEDA)
					EndIf
				Else
					If(SE2->(DbSeek(xFilial("SE2")+cDocumen,.f.)))
						nValTit := xMoeda((cAlias)->E5_VLMOED2,SE2->E2_MOEDA,1,(cAlias)->E5_DATA,MsDecimais(1),SE2->E2_TXMOEDA)
					EndIf
				EndIf
				lGraba:=.t.
			EndIf
			If lGraba
				aAdd(aPagos, {(cAlias)->E5_NUMERO,(cAlias)->E5_PREFIXO,(cAlias)->E5_PARCELA,(cAlias)->E5_FORNECE,(cAlias)->E5_LOJA,nValTit,"",(cAlias)->E5_TIPO,(cAlias)->E5_DATA,substr((cAlias)->E5_DOCUMEN,11,9),SUBSTR((cAlias)->E5_DOCUMEN,11,3)})
			EndIf
		Else
			If AllTrim((cAlias)->E5_TIPO) == "CH"
				If SE2->(DbSeek(xFilial("SE2")+(cAlias)->E5_PREFIXO+(cAlias)->E5_NUMERO+(cAlias)->E5_PARCELA+(cAlias)->E5_TIPO+(cAlias)->E5_CLIFOR+(cAlias)->E5_LOJA))
					cOrdPago := SE2->E2_ORDPAGO
					FS88ImpOP(cOrdPago, cAlias)
				Else
					aAdd(aError, {STR0033+(cAlias)->E5_PREFIXO+(cAlias)->E5_NUMERO})// "Error: No encontro el cheque "
				EndIf
			Else
				If AllTrim((cAlias)->E5_TIPO) <> "PA"
					If cNumOrPg != (cAlias)->E5_ORDREC
						cOrdPago := AllTrim((cAlias)->E5_ORDREC)
						FS88ImpOP(cOrdPago, cAlias, (cAlias)->E5_NUMLIQ)
					EndIf
					cNumOrPg := (cAlias)->E5_ORDREC
				EndIf
			EndIf
		EndIf
		IncProc()
		(cAlias)->(DBSkip())
	EndDo
	(cAlias)->(DBCloseArea())

	If oExecA <> Nil
		oExecA:Destroy()
		oExecA := Nil
	EndIf
	RestArea(aArea)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS88ImpOP 	³Autor ³ Gpe Santacruz        ³Data³22/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Extrae los titulos de la Orden de Pago                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 = Numero de Orden de Pago                            ³±±
±±³          ³ cExp2 = Area de trabajo de deducciones                     ³±±
±±³          ³ cExp3 = Numero de Liquidacion                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FS088GERA                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS88ImpOP(cOrdPago, cAlias, cNumLiq)
	
	Local cFilSEK	:= (cAlias)->E5_FILIAL
	Local nTtlTits	:= 0
	Local nTtlPgo	:= 0
	Local aDocums	:= {}
	Local nX		:= 0
	Local aArea		:= GetArea()
	Local lLoop		:= .t.
	Local lExistDoc	:= .F.
	
	Default cNumLiq	:= ""

	SEK->(DBSetOrder(1)) //EK_FILIAL + EK_ORDPAGO + EK_TIPODOC + EK_PREFIXO + EK_NUM + EK_PARCELA + EK_TIPO + EK_SEQ 
	SEK->(DBGoTop())
	SEK->(DbSeek(cFilSEK + cOrdPago))
	
	//CH 	= Cheque
	//EF 	= Efectivo
	//TF	= Transferencia
	//NCP 	= Nota Crédito Proveedor
	//NDI	= Nota Débito Interna
	//PA	= Pago Anticipado
	//NF	= Factura
	//NDC	= Nota Débito Cliente
	//NDP	= Nota Débito Proveedor
	
	While !(SEK->(Eof())) .And. SEK->EK_FILIAL == cFilSEK .And. SEK->EK_ORDPAGO == cOrdPago
		
		If lCompSEK
			If Len(aDocsOP) > 0
				AEval(aDocsOP, {|x,y| IIf(aDocsOP[y,1]+aDocsOP[y,2]+aDocsOP[y,3]+aDocsOP[y,4]+aDocsOP[y,5]+aDocsOP[y,6] == SEK->(EK_PREFIXO+EK_NUM+EK_FORNECE+EK_LOJA+EK_TIPO+EK_PARCELA), lExistDoc := .T., .F.)})
			EndIf
		EndIf
		
		If IIf(lCompSEK, !lExistDoc, .T.)
			If AllTrim(SEK->EK_TIPO) $ "CH|EF|TF|NCP|NDI|PA|CA"
				If AllTrim(SEK->EK_TIPO) $ "NCP|NDI|PA"
					nTtlPgo += SEK->EK_VLMOED1
				Else
					If AllTrim(SEK->EK_TIPO) == "CH"
						SE2->(DBSetOrder(1)) //E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA 
						SE2->(DBSeek(xFilial("SE2") + SEK->EK_PREFIXO + SEK->EK_NUM + SEK->EK_PARCELA + SEK->EK_TIPO + SEK->EK_FORNECE + SEK->EK_LOJA))
						//verifica si el cheque est debitado
						If !(dFecIni <= SE2->E2_BAIXA .And. dFecFin >= SE2->E2_BAIXA)
							SEK->(DBSkip())
							lLoop := .T.
							Loop
						EndIf
						nTtlPgo += SEK->EK_VLMOED1
					Else
						nTtlPgo += SEK->EK_VLMOED1
					EndIf
				EndIf
			Else
				If AllTrim(SEK->EK_TIPO) $ "NF|NDC|NDP"
					//verifica si el cheque est debitado
					// Realizar con el E5_NUMLIQ busqueda en SE2 por el numliq
					If !(Revdeb(cOrdPago,cNumLiq))
						SEK->(DBSkip())
						lLoop := .T.
						Loop
					EndIf
					nTtlTits += SEK->EK_VLMOED1
					aAdd(aDocums, {SEK->EK_NUM, SEK->EK_PREFIXO, SEK->EK_PARCELA, SEK->EK_FORNECE, SEK->EK_LOJA, SEK->EK_VLMOED1, 0, SEK->EK_TIPO, SEK->EK_EMISSAO})
					If lCompSEK
						aAdd(aDocsOP, {SEK->EK_PREFIXO, SEK->EK_NUM, SEK->EK_FORNECE, SEK->EK_LOJA, SEK->EK_TIPO, SEK->EK_PARCELA})
					EndIf
				EndIf
			EndIf
		EndIf
		SEK->(DBSkip())
	EndDo

	//Extrae la parte proporcional del pago en la ordena cada titulo
	For nX := 1 To Len(aDocums)
		aDocums[nX,7] := (aDocums[nX,6] / nTtlTits) * nTtlPgo
	Next nX

	For nX := 1 To Len(aDocums)
		aAdd(aPagos, {aDocums[nx,1], aDocums[nx,2], aDocums[nx,3], aDocums[nx,4], aDocums[nx,5], aDocums[nx,7], cOrdPago, aDocums[nx,8], aDocums[nx,9], (cAlias)->E5_DOCUMEN, ""})
	Next nX

	RestArea(aArea)
	
Return

/*/{Protheus.doc} RevDeb
Revisa si el documento tiene un npumero de liquidación, entonces busca si el número de liquidación fue debitado dentro del periodo.
@type function
@author mayra.camargo
@since 10/01/2019
@version 1.0
@param cOrPago, string, Orden de Pago
@param cNumLiq, string, Número de Liquidación.
@example
(examples)
@see (links_or_references)
/*/
Static Function RevDeb(cOrdPago, cNumLiq)
	
	Local lRet		:= .T.
	Local cFilSE2	:= xFilial("SE2")
	
	Default cOrdPago	:= ""
	Default cNumLiq		:= ""
	
	SE2->(DBGoTop())
	SE2->(DBSetOrder(8)) //E2_FILIAL + E2_NUMORD
	If SE2->(DBSeek(xFilial("SE2") + cOrdPago))
		While !SE2->(EoF()) .And. SE2->E2_FILIAL == cFilSE2 .And. SE2->E2_ORDPAGO == cOrdPago
			If SE2->E2_NUMLIQ == cNumLiq
				If !(dFecIni <= SE2->E2_BAIXA .And. dFecFin >= SE2->E2_BAIXA)
					Return .F.
				EndIf
			EndIf
			SE2->(DBSkip())
		EndDo
	EndIf
	
Return lRet

/*/{Protheus.doc} RevDeb
Funcion utilizada para obtener el Recno del documento en SE2.
@type function
@author Marco Augusto Gonzalez Rivera
@since 27/05/2019
@version 1.0
@param aDocsPag, array, Arreglo con datos de documentos pagados
@example fGetRecSE2(aDocsPag)
@see (links_or_references)
/*/
Static Function fGetRecSE2(aDocsPag)
	Local nRecno	:= 0
	Local cTempSE2	:= GetNextAlias()
	Local oExec     := Nil
	Local cQuery    := ""
	
	/*
	* aDocsPag[1] = Numero del Documento
	* aDocsPag[2] = Serie del Documento
	* aDocsPag[3] = Parcialidad
	* aDocsPag[4] = Codigo del Proveedor
	* aDocsPag[5] = Tienda del Proveedor 
	* aDocsPag[7] = Orden de Pago
	* aDocsPag[8] = Tipo de Documento
	*/

	cQuery := "SELECT SE2.R_E_C_N_O_ TRBRECNO "
	cQuery += "FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += "WHERE SE2.E2_NUM = ? AND "
	cQuery += "SE2.E2_PREFIXO = ? AND "
	cQuery += "SE2.E2_PARCELA = ? AND "
	cQuery += "SE2.E2_FORNECE = ? AND "
	cQuery += "SE2.E2_LOJA = ? AND "
	cQuery += "SE2.E2_TIPO = ? AND "
	cQuery += "SE2.E2_ORDPAGO <> ? AND "
	cQuery += "SE2.E2_BAIXA <> ? AND "
	cQuery += "SE2.D_E_L_E_T_ = ? "

	cQuery := ChangeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)

	oExec:SetString(1,aDocsPag[1])
	oExec:SetString(2,aDocsPag[2])
	oExec:SetString(3,aDocsPag[3])
	oExec:SetString(4,aDocsPag[4])
	oExec:SetString(5,aDocsPag[5])
	oExec:SetString(6,aDocsPag[8])
	oExec:SetString(7,' ')
	oExec:SetString(8,' ')
	oExec:SetString(9,' ')

	cTempSE2 := oExec:OpenAlias()

	nRecno	:= oExec:ExecScalar("TRBRECNO")

	(cTempSE2)->(DbCloseArea())
 
	oExec:Destroy()
	oExec := Nil 

Return nRecno

/*/{Protheus.doc} FS088SE2V2
	Calculo de Impuestos de IVA/Retención de Facturas de Entrada para el DIOT 2025
	@type  Static Function
	@author Alfredo Medrano
	@since 01/03/2025
	@version 1
	@example
		FS088SE2V2()
	@see (links_or_references)
/*/
Function FS088SE2V2()
	Local nX			:= 0
	Local nPorcion		:= 0
	Local nTaxa			:= 0
	Local nY			:= 0
	Local nBase			:= 0
	Local cImp			:= ''
	Local cFilSA2		:= xFilial("SA2")
	Local cFilSD1       := xFilial("SD1")
	Local cFilSFC       := xFilial("SFC")
	Local cFilSFB       := xFilial("SFB")
	Local cFilSE2       := xFilial("SE2")
	Local cFilSB1       := xFilial("SB1")
	Local cFilRSC		:= ''
	Local aArea			:= GetArea()
	Local nTamTip		:= GetSX3Cache("E2_TIPO","X3_TAMANHO")
	Local nTamPar		:= GetSX3Cache("E2_PARCELA","X3_TAMANHO") 
	Local lImportacion	:= .F.
	Local cFilRSE		:= ''
	Local lMovEnSE2		:= .F.
	Local nNumRecSE2	:= 0
	
	Local nBasExe		:= 0
	Local nSumBase		:= 0
	Local nSumImp		:= 0
	Local cQryImp       := ""
	Local cQryD         := ""
	Local oExecImp      := Nil
	Local oExecDoc      := Nil
    Local cAliasI       := ""
	Local aImpFact      := {}
	Local cTabSD1       := RetSqlName("SD1")
	Local cTabSFB       := RetSqlName("SFB")
	Local cTabSFC       := RetSqlName("SFC")
	Local cTabSB1       := RetSqlName("SB1")
	Local lCpoTan       := SB1->(ColumnPos("B1_PRODTAN")) > 0
	Local lCpoObjI      := SB1->(ColumnPos("B1_OBJIVA")) > 0
	Local lCpoReg       := SA2->(ColumnPos("A2_REGION")) > 0
	Local lCpoTpIv      := SFB->(ColumnPos("FB_TIPOIVA")) > 0
	Local cRegPro       := ""
	Local cProdT        := ""
	Local cProdOI       := ""
	Local cTipoIVA      := ""
	Local cCposSel      := ""
	Local cCposAcu      := ""
	Local cCposGru      := ""
	Local nOrd          := 1
	Local nPosD         := 0

	DBSelectArea("SA2")
	SA2->(DBSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA

	If lEsImport
		cFilRSE := xFilial("RSE")
		cFilSD1 := xFilial("SD1")
		cFilRSC := xFilial("RSC")
		DBSelectArea("RSE")
		RSE->(DBSetOrder(3)) //RSE_FILIAL + RSE_FACT + RSE_SERIE + RSE_PROV + RSE_TDA
		DBSelectArea("RSC") 
		RSC->(DBSetOrder(1)) //RSC_FILIAL + RSC_NUMPED
	EndIf

	ProcRegua(Len(aPagos)) // Número de registros a procesar
	DBSelectArea("SD1")
	SD1->(DBSetOrder(1)) //D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM 

	SE2->(DBSetOrder(6)) //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
	DBSelectArea("SF1")
	SF1->(DBSetOrder(1)) //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO

	For nX := 1 To Len(aPagos)
		lImportacion := .F.
		aImpFact := {}
		If lEsImport
			//Verifica que no sea un pago a una facturas de importacion, Solo si existe el modulo de importaciones Mexico
			If RSE->(DBSeek(cFilRSE+aPagos[nX,1]+aPagos[nX,2]+aPagos[nX,4]+aPagos[nX,5]))
				If RSE->RSE_TIPO $ "1/3" //Si es mercancia o gastos extranjeros
					lImportacion := .T.
				EndIf
			Else //Verifica que no sea factura de impuestos
				If SD1->(DBSeek(cFilSD1+aPagos[nX,1]+aPagos[nX,2]+aPagos[nX,4]+aPagos[nX,5]))
					If !Empty(SD1->D1_PEDIM)
						If RSC->(DBSeek(cFilRSC+SD1->D1_PEDIM))
							If aPagos[nX,1]+aPagos[nX,2] == RSC->RSC_FACIMP+RSC->RSC_SERIMP
								lImportacion := .T.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If !lImportacion
			//Tratamiento para buscar en SE2 con Financiero compartido
			If lCompSEK
				lMovEnSE2 := SE2->(MsSeek(cFilSE2 + aPagos[nX,4] + aPagos[nX,5] + aPagos[nX,2] + aPagos[nX,1] + PADR(aPagos[nX,3], nTamPar, " ") + PADR(aPagos[nX,8], nTamTip, " ")))
			Else //Si no es financiero compartido
				nNumRecSE2 := fGetRecSE2(aPagos[nX])
				If nNumRecSE2 > 0
					lMovEnSE2 := .T.
					SE2->(DBGoTo(nNumRecSE2))
				EndIf
			EndIf
			If lMovEnSE2
				nTaxa := 1
				If SE2->E2_MOEDA <> 1
					nTaxa := SE2->E2_TXMOEDA
				EndIf
				
				nPorcion	:= aPagos[nx,6] / (SE2->E2_VALOR * nTaxa)
				
				cRFC	 := ""
				cID		 := ""
				cTipT	 := ""
				cTipO	 := ""
				cPai	 := ""
				cRegPro  := ""
				nSumBase := 0
				nSumImp	 := 0
				nBasExe	 := 0
				
				If SA2->(MsSeek(cFilSA2 + aPagos[nX,4] + aPagos[nX,5]))
					cRFC	:= SA2->A2_CGC
					cID		:= SA2->A2_IDFISCA
					cTipT	:= SA2->A2_TIPOTER
					cTipO	:= SA2->A2_TPOPER
					cPai	:= SA2->A2_PAIS
					If cTipT $ "04|15"
						If lCpoReg .And. !Empty(SA2->A2_REGION)
							cRegPro := SA2->A2_REGION
						EndIf
					EndIf
				EndIf
				
				//Impuestos del Documento
				cQryImp := "SELECT SFB.FB_CPOLVRO "
				cQryImp += "FROM ? SD1 "
				cQryImp += "INNER JOIN ? SFC ON SFC.FC_TES = SD1.D1_TES  "
				cQryImp += "INNER JOIN ? SFB ON SFB.FB_CODIGO = SFC.FC_IMPOSTO "
				cQryImp += "WHERE SD1.D1_DOC = ? "
				cQryImp += "AND SD1.D1_SERIE = ? "
				cQryImp += "AND SD1.D1_FORNECE = ? "
				cQryImp += "AND SD1.D1_LOJA = ? "
				cQryImp += "AND SD1.D1_TES = SFC.FC_TES "
				cQryImp += "AND SFC.FC_IMPOSTO = SFB.FB_CODIGO "
				cQryImp += "AND SD1.D1_FILIAL = ? "
				cQryImp += "AND SFC.FC_FILIAL = ? "
				cQryImp += "AND SFB.FB_FILIAL = ? "
				cQryImp += "AND SD1.D_E_L_E_T_  = ? "
				cQryImp += "AND SFC.D_E_L_E_T_  = ? "
				cQryImp += "AND SFB.D_E_L_E_T_  = ? "
				cQryImp += "GROUP BY SFB.FB_CPOLVRO "
				cQryImp += "ORDER BY SFB.FB_CPOLVRO "
			
				cQryImp := ChangeQuery(cQryImp)
				oExecImp := FwExecStatement():New(cQryImp)

				oExecImp:SetUnsafe(1,cTabSD1)
				oExecImp:SetUnsafe(2,cTabSFC)
				oExecImp:SetUnsafe(3,cTabSFB)
				oExecImp:SetString(4,aPagos[nx,1])  //Documento
				oExecImp:SetString(5,aPagos[nx,2])  //Serie
				oExecImp:SetString(6,aPagos[nx,4])  //Proveedor
				oExecImp:SetString(7,aPagos[nx,5])  //Tienda
				oExecImp:SetString(8,cFilSD1)       //Filial SFC
				oExecImp:SetString(9,cFilSFC)       //Filial SFC
				oExecImp:SetString(10,cFilSFB)       //Filial SFB
				oExecImp:SetString(11,' ')           //SD1.D_E_L_E_T_
				oExecImp:SetString(12,' ')           //SFC.D_E_L_E_T_
				oExecImp:SetString(13,' ')          //SFB.D_E_L_E_T_

 				cAliasI := oExecImp:OpenAlias()

				dbSelectArea(cAliasI)
				(cAliasI)->(DbGoTop())
				While (cAliasI )->(!Eof())
					aAdd(aImpFact,{(cAliasI)->FB_CPOLVRO})
					(cAliasI)->(dbskip())
				EndDo

				(cAliasI)->(DBCloseArea())

				If Len(aImpFact) > 0
					For nY:=1 To Len(aImpFact)
						nOrd := 1
						cImp := Alltrim(aImpFact[ny][1])
						cCposSel := "SD1.D1_ALQIMP" + cImp +" AS ALIQ" + IIf(lCpoTpIv,", SFB.FB_TIPOIVA","") + IIf(lCpoObjI ,", SB1.B1_OBJIVA","") + IIf(lCpoTan ,",SB1.B1_PRODTAN","")
						cCposAcu := ", SUM(SD1.D1_BASIMP" + cImp +") AS BASE, SUM(SD1.D1_VALIMP" + cImp + ") AS VALIMP " 
						cCposGru := "SD1.D1_ALQIMP" + cImp + IIf(lCpoTpIv,", SFB.FB_TIPOIVA","") + IIf(lCpoObjI ,", SB1.B1_OBJIVA","") + IIf(lCpoTan ,",SB1.B1_PRODTAN","")
						cQryD := "SELECT SD1.D1_FILIAL, SD1.D1_SERIE, SD1.D1_DOC, SD1.D1_FORNECE, SD1.D1_LOJA, ? ? "
						cQryD += "FROM ? SD1 "
						cQryD += "INNER JOIN ? SFC ON SFC.FC_TES = SD1.D1_TES  "
						cQryD += "INNER JOIN ? SFB ON SFB.FB_CODIGO = SFC.FC_IMPOSTO "
						If lCpoTan .Or. lCpoObjI
							cQryD += "INNER JOIN ? SB1 ON SB1.B1_COD = SD1.D1_COD "
						EndIf
						cQryD += "WHERE SD1.D1_DOC = ? "
						cQryD += "AND SD1.D1_SERIE = ? "
						cQryD += "AND SD1.D1_FORNECE = ? "
						cQryD += "AND SD1.D1_LOJA = ? "
						cQryD += "AND SFB.FB_CPOLVRO = ? "
						cQryD += "AND SD1.D1_FILIAL = ? "
						cQryD += "AND SFC.FC_FILIAL = ? "
						cQryD += "AND SFB.FB_FILIAL = ? "
						If lCpoTan .Or. lCpoObjI
							cQryD += "AND SB1.B1_FILIAL = ? "
							cQryD += "AND SB1.D_E_L_E_T_  = ? "
						EndIf
						cQryD += "AND SD1.D_E_L_E_T_  = ? "
						cQryD += "AND SFB.D_E_L_E_T_  = ? "
						cQryD += "AND SFC.D_E_L_E_T_  = ? "
						cQryD += "GROUP BY SD1.D1_FILIAL, SD1.D1_SERIE, SD1.D1_DOC, SD1.D1_FORNECE, SD1.D1_LOJA, ? "
						cQryD := ChangeQuery(cQryD)

						oExecDoc := FwExecStatement():New(cQryD)

						oExecDoc:SetUnsafe(nOrd++,cCposSel)    
						oExecDoc:SetUnsafe(nOrd++,cCposAcu) 
						oExecDoc:SetUnsafe(nOrd++,cTabSD1)
						oExecDoc:SetUnsafe(nOrd++,cTabSFC)
						oExecDoc:SetUnsafe(nOrd++,cTabSFB)
						If lCpoTan .Or. lCpoObjI
							oExecDoc:SetUnsafe(nOrd++,cTabSB1)
						EndIf
						oExecDoc:SetString(nOrd++,aPagos[nx,1]) //Documento
						oExecDoc:SetString(nOrd++,aPagos[nx,2]) //Serie
						oExecDoc:SetString(nOrd++,aPagos[nx,4]) //Cliente
						oExecDoc:SetString(nOrd++,aPagos[nx,5]) //Tienda
						oExecDoc:SetString(nOrd++,cImp)         //Número Campo de Libro
						oExecDoc:SetString(nOrd++,cFilSD1)      //Filial SFC
						oExecDoc:SetString(nOrd++,cFilSFC)      //Filial SFC
						oExecDoc:SetString(nOrd++,cFilSFB)      //Filial SFB
						If lCpoTan .Or. lCpoObjI
							oExecDoc:SetString(nOrd++,cFilSB1)      //Filial SB1
							oExecDoc:SetString(nOrd++,' ')          //SB1.D_E_L_E_T_
						EndIf
						oExecDoc:SetString(nOrd++,' ')          //SD1.D_E_L_E_T_
						oExecDoc:SetString(nOrd++,' ')          //SFC.D_E_L_E_T_
						oExecDoc:SetString(nOrd++,' ')          //SFB.D_E_L_E_T_
						oExecDoc:SetUnsafe(nOrd++,cCposGru)

						cAliasD := oExecDoc:OpenAlias()

						dbSelectArea(cAliasD)
						(cAliasD)->(DbGoTop())
						While (cAliasD )->(!Eof())
							If (cAliasD)->BASE > 0
								nSumBase	+= (cAliasD)->BASE
								nSumImp		+= (cAliasD)->VALIMP
							EndIf
							If _cCpoIVC  == cImp .OR. _cCpoIEPS  == cImp   //IVA INCLUIDO O IEPS
								nBase	:= ((cAliasD)->BASE * nTaxa * nPorcion) * (-1)
							Else
								nBase	:= (cAliasD)->BASE * nTaxa * nPorcion
							EndIf
							nValImp	:= (cAliasD)->VALIMP * nTaxa * nPorcion
							nImpImp	:= (cAliasD)->ALIQ //Alícuota

							//Tipo de Iva
							If lCpoTpIv .And. !Empty((cAliasD)->FB_TIPOIVA)
								cTipoIVA := (cAliasD)->FB_TIPOIVA
							Else
								cTipoIVA := "1" //1-Acreditable No Proporcional
							EndIf

							//Objeto de Impuesto
							If lCpoObjI .And. !Empty((cAliasD)->B1_OBJIVA)
								cProdOI := (cAliasD)->B1_OBJIVA
							Else
								cProdOI := "1" //1-Si
							EndIf

							If cTipT == "05"
								//Producto Tangible
								If lCpoTan .And. !Empty((cAliasD)->B1_PRODTAN)
									cProdT := (cAliasD)->B1_PRODTAN
								Else
									cProdT := "1" //1-Si
								EndIf
							EndIf

							If nBase > 0
								nPos := aScan(aPgosDIOT, {|X| X[1]+X[2]+X[3]+X[4]+X[5]+X[6] == ""+aPagos[nx,1]+aPagos[nx,2]+aPagos[nx,3]+aPagos[nx,4]+aPagos[nx,5]})
								
								If nPos == 0
									aAdd(aPgosDIOT, {"", aPagos[nx,1], aPagos[nx,2], aPagos[nx,3], aPagos[nx,4], aPagos[nx,5], aPagos[nx,7], cTipT, cTipO, cRFC, cID, cPai, SE2->E2_EMISSAO, ;
													0,0,0,0,0,0,0,0,0,0, ;
													0,0,0,0,0,0,0,0,0,0, ;
													0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, ;
													0,0,0,0,0,0,0,SE2->E2_TIPO ;
													  })
									
									nPosD := Len(aPgosDIOT)
								Else
									nPosD := nPos
								EndIf
								
								If cImp $ _CIMPRET
									aPgosDIOT[nPosD,54] += nValImp
								Else 
									If cImp $ _CLISIVAS //Clasificación del IVA
										nImpImp := Round(nImpImp,1)		
										If cTipT $ "04|15" .And. cProdOI == "2" //Proveedor Nacional - No Objeto de IVA
											aPgosDIOT[nPosD, 58] += nBase
										ElseIf cTipT $ "05" .And. cProdOI == "2" //Proveedor Extranjero - No Objeto de IVA
											aPgosDIOT[nPosD, 59] += nBase
										EndIf
										If cTipT $ "04|15" .And. Empty(cRegPro)
											If nImpImp == 8
												cRegPro := "1" //Frontera Norte
											Else	
												cRegPro := "3" //Interior del País
											EndIf	
										EndIf					
										FS88CLASIF(@aPgosDIOT, nPosD, cRegPro, nBase, nImpImp, nValImp, cTipT, cTipoIVA, cProdT, cProdOI, 1)
									EndIf
								EndIf 
							EndIf //Fin nBase
							(cAliasD)->(dbskip())
						EndDo
					Next nY
					
					(cAliasD)->(DBCloseArea())
				Else
					nPos := aScan(aPgosDIOT, {|X| X[1]+X[2]+X[3]+X[4]+X[5]+X[6] == ""+aPagos[nx,1]+aPagos[nx,2]+aPagos[nx,3]+aPagos[nx,4]+aPagos[nx,5]})
					
					If nPos == 0
						aAdd(aPgosDIOT, {"", aPagos[nx,1], aPagos[nx,2], aPagos[nx,3], aPagos[nx,4], aPagos[nx,5], aPagos[nx,7], cTipT, cTipO, cRFC, cID, cPai, SE2->E2_EMISSAO, ;
											0,0,0,0,0,0,0,0,0,0, ;
											0,0,0,0,0,0,0,0,0,0, ;
											0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, ;
											0,0,0,0,0,0,0, SE2->E2_TIPO ;
											})
						nPosD := Len(aPgosDIOT)
					Else
						nPosD := nPos
					EndIf
				EndIf
				//Base Exento
				nBasExe := (SE2->E2_VALOR - (nSumBase + nSumImp))
				If nBasExe > 0 .And. nPosD > 0
					nBasExe :=  nBasExe * nTaxa * nPorcion
					If cTipT == '05'  //IVA Exento Extranjero
						aPgosDIOT[nPosD,55] += nBasExe
					Else //IVA Exento Nacional
						aPgosDIOT[nPosD,56] += nBasExe
					EndIf
				EndIf
				
				If oExecDoc <> Nil
					oExecDoc:Destroy()
					oExecDoc := Nil
				EndIf
				If oExecImp <> Nil
					oExecImp:Destroy()
					oExecImp := Nil
				EndIf
			Else
				aAdd(aError, {STR0031 + aPagos[nX,4] + " - " + aPagos[nX,5] + STR0032 + aPagos[nX,2] + " " + aPagos[nX,1] + PADR(aPagos[nX,3], nTamPar, " ")}) // "NO ENCONTRO EN CXP EL PROVEDOR :" " Y FACTURA :"
			EndIf
		EndIf
		IncProc()
	Next nX

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} FS088NCPV2
	Calculo de Impuestos de IVA/Retención de Notas de Crédito de Proveedor para el DIOT 2025
	@type  Static Function
	@author Alfredo Medrano
	@since 01/03/2025
	@version 1
	@example
		FS088NCPV2()
	@see (links_or_references)
/*/
Function FS088NCPV2()
	Local cQuery   := ""
	Local cQryAux  := ""
	Local cAlias	:= ""
	Local cFilSE5	:= xFilial("SE5")
	Local aArea		:= GetArea()
	Local nY		:= 0
	Local nPos		:= 0
	Local nPosD		:= 0
	Local nValTit	:= 0
	Local nPorcion	:= 0
	Local cFilSE2	:= xFilial("SE2")
	Local cFilSA2	:= xFilial("SA2")
	Local cFilSD2	:= xFilial("SD2")
	Local cFilSFC	:= xFilial("SFC")
	Local cFilSFB	:= xFilial("SFB")
	Local cFilSB1   := xFilial("SB1")
	Local nValImp	:= 0
	Local nBase     := 0
	Local nTaxa		:= 0
	Local nTasaMod	:= 0
	Local cFilUsr   := ""
	Local cQryImp	:= ""
	Local cImp		:= ""
	Local cQryD		:= ""
	Local cTabSD2   := RetSqlName("SD2")
	Local cTabSFB   := RetSqlName("SFB")
	Local cTabSFC   := RetSqlName("SFC")
	Local cTabSB1   := RetSqlName("SB1")
	Local lCpoTan       := SB1->(ColumnPos("B1_PRODTAN")) > 0
	Local lCpoObjI      := SB1->(ColumnPos("B1_OBJIVA")) > 0
	Local lCpoReg       := SA2->(ColumnPos("A2_REGION")) > 0
	Local lCpoTpIv      := SFB->(ColumnPos("FB_TIPOIVA")) > 0
	Local cTipoIVA      := ""
	Local cProdOI       := ""
	Local cRegPro       := ""
	Local cProdT        := ""
	Local nImpImp		:= 0
	Local cRFC			:= ""
	Local cID			:= ""
	Local cTipT			:= ""
	Local cTipO			:= ""
	Local cPai			:= ""
	Local aImpFact		:= {}
	Local oExecImp      := Nil
	Local oExecDoc      := Nil
	Local oExeSE5       := Nil
	Local cCposSel      := ""
	Local cCposAcu      := ""
	Local cCposGru      := ""
	Local nOrd          := 1

	SA6->(DbSetORder(1)) //A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
	SE2->(DbSetOrder(6)) //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO

	cQuery := " SELECT E5_TIPODOC, E5_VALOR, E5_MOEDA, E5_DATA, E5_VLMOED2, E5_NUMERO, E5_TIPO," 
	cQuery += " E5_PREFIXO, E5_PARCELA, E5_LOJA, E5_CLIFOR, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_FILORIG, E5_TXMOEDA" 
	cQuery += " FROM ? "
	cQuery += " WHERE"
	cQuery += " D_E_L_E_T_= ?"
	cQuery += " AND E5_FILIAL = ?"
	cQuery += " AND ("
	
	cQryAux := " ( E5_DATA BETWEEN '" + Dtos(dFecIni) + "' AND  '" + Dtos(dFecFin) + "'"
	cQryAux += " AND E5_TIPO = 'NCP') AND E5_SITUACA <> 'C' ) "

	If ExistBlock("FS088FINCP")
		cFilUsr	:=	ExecBlock("FS088FINCP",.F.,.F.,{cQryAux})
		If !Empty(cFilUsr)
			cQryAux := cFilUsr
		EndIf
	Endif

	cQuery += " ? "

	cQuery  := ChangeQuery(cQuery)
	oExeSE5 := FwExecStatement():New(cQuery)
	oExeSE5:SetUnsafe(1,RetSqlName("SE5")) 
	oExeSE5:SetString(2,'') 
	oExeSE5:SetString(3,cFilSE5)   
	oExeSE5:SetUnsafe(4,cQryAux) 
	
	cAlias := oExeSE5:OpenAlias()
	TCSetField(cAlias, "E5_DATA", "D", 8, 0)

	Count To nMax
	ProcRegua(nMax)
	
	DBSelectArea(cAlias)
	(cAlias)->(DBGoTop())

	While !((cAlias)->(Eof()))	
		aImpFact := {}
		If (cAlias)->E5_FILORIG == cFilAnt

			If (cAlias)->E5_MOEDA <> "01"
				nMoedaBco := Val((cAlias)->E5_MOEDA)
			Else
				nMoedaBco := 1
			EndIf
			nValTit := xMoeda((cAlias)->E5_VALOR, nMoedaBco, 1, (cAlias)->E5_DATA, MsDecimais(1), (cAlias)->E5_TXMOEDA, 1)
			
			nTasaMod := (cAlias)->E5_TXMOEDA
			
			If SE2->(MsSeek(cFilSE2 + (cAlias)->E5_CLIFOR + (cAlias)->E5_LOJA +(cAlias)->E5_PREFIXO+(cAlias)->E5_NUMERO))
			
				If SE2->E2_MOEDA <> 1
					nTaxa := nTasaMod
				Else
					nTaxa := 1
				EndIf
	
				nPorcion := nValTit/(SE2->E2_VALOR*nTaxa)

				cRFC	:= ""
				cID		:= ""
				cTipT	:= ""
				cTipO	:= ""
				cPai	:= ""
				cRegPro := ""
				nSumBase := 0
				nSumImp	 := 0
				nBasExe	 := 0
				
				If SA2->(MsSeek(cFilSA2 + SE2->E2_FORNECE + SE2->E2_LOJA))
					cRFC	:= SA2->A2_CGC
					cID		:= SA2->A2_IDFISCA
					cTipT	:= SA2->A2_TIPOTER
					cTipO	:= SA2->A2_TPOPER
					cPai	:= SA2->A2_PAIS
					If cTipT $ "04|15"
						If lCpoReg .And. !Empty(SA2->A2_REGION)
							cRegPro := SA2->A2_REGION
						EndIf
					EndIf
				EndIf
				
				//Impuestos del Documento
				cQryImp := "SELECT SFB.FB_CPOLVRO "
				cQryImp += "FROM ? SD2 "
				cQryImp += "INNER JOIN ? SFC ON SFC.FC_TES = SD2.D2_TES  "
				cQryImp += "INNER JOIN ? SFB ON SFB.FB_CODIGO = SFC.FC_IMPOSTO "
				cQryImp += "WHERE SD2.D2_DOC = ? "
				cQryImp += "AND SD2.D2_SERIE = ? "
				cQryImp += "AND SD2.D2_CLIENTE = ? "
				cQryImp += "AND SD2.D2_LOJA = ? "
				cQryImp += "AND SD2.D2_FILIAL = ? "
				cQryImp += "AND SFC.FC_FILIAL = ? "
				cQryImp += "AND SFB.FB_FILIAL = ? "
				cQryImp += "AND SD2.D_E_L_E_T_  = ? "
				cQryImp += "AND SFC.D_E_L_E_T_  = ? "
				cQryImp += "AND SFB.D_E_L_E_T_  = ? "
				cQryImp += "GROUP BY SFB.FB_CPOLVRO "
				cQryImp += "ORDER BY SFB.FB_CPOLVRO "
			
				cQryImp := ChangeQuery(cQryImp)
				oExecImp := FwExecStatement():New(cQryImp)

				oExecImp:SetUnsafe(1,cTabSD2)
				oExecImp:SetUnsafe(2,cTabSFC)
				oExecImp:SetUnsafe(3,cTabSFB)
				oExecImp:SetString(4,SE2->E2_NUM)     //Documento
				oExecImp:SetString(5,SE2->E2_PREFIXO) //Serie
				oExecImp:SetString(6,SE2->E2_FORNECE) //Proveedor
				oExecImp:SetString(7,SE2->E2_LOJA)    //Tienda
				oExecImp:SetString(8,cFilSD2)         //Filial SD2
				oExecImp:SetString(9,cFilSFC)         //Filial SFC
				oExecImp:SetString(10,cFilSFB)         //Filial SFB
				oExecImp:SetString(11,' ')             //SD2.D_E_L_E_T_
				oExecImp:SetString(12,' ')             //SFC.D_E_L_E_T_
				oExecImp:SetString(13,' ')            //SFB.D_E_L_E_T_

 				cAliasI := oExecImp:OpenAlias()

				dbSelectArea(cAliasI)
				(cAliasI)->(DbGoTop())
				While (cAliasI )->(!Eof())
					aAdd(aImpFact,{(cAliasI)->FB_CPOLVRO})
					(cAliasI)->(dbskip())
				EndDo

				(cAliasI)->(DBCloseArea())

				If Len(aImpFact) > 0
					For nY:=1 To Len(aImpFact)
						nOrd := 1
						cImp := Alltrim(aImpFact[ny][1])
						cCposSel := "SD2.D2_ALQIMP" + cImp +" AS ALIQ" + IIf(lCpoTpIv,", SFB.FB_TIPOIVA","") + IIf(lCpoObjI ,", SB1.B1_OBJIVA","") + IIf(lCpoTan ,",SB1.B1_PRODTAN","")
						cCposAcu := ", SUM(SD2.D2_BASIMP" + cImp +") AS BASE, SUM(SD2.D2_VALIMP" + cImp + ") AS VALIMP "
						cCposGru := "SD2.D2_ALQIMP" + cImp + IIf(lCpoTpIv,", SFB.FB_TIPOIVA","") + IIf(lCpoObjI ,", SB1.B1_OBJIVA","") + IIf(lCpoTan ,",SB1.B1_PRODTAN","")
						cQryD := "SELECT SD2.D2_FILIAL, SD2.D2_SERIE, SD2.D2_DOC, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_EMISSAO, ? ?"
						cQryD += "FROM ? SD2 "
						cQryD += "INNER JOIN ? SFC ON SFC.FC_TES = SD2.D2_TES  "
						cQryD += "INNER JOIN ? SFB ON SFB.FB_CODIGO = SFC.FC_IMPOSTO "
						If lCpoTan .Or. lCpoObjI
							cQryD += "INNER JOIN ? SB1 ON SB1.B1_COD = SD2.D2_COD "
						EndIf
						cQryD += "WHERE SD2.D2_DOC = ? "
						cQryD += "AND SD2.D2_SERIE = ? "
						cQryD += "AND SD2.D2_CLIENTE = ? "
						cQryD += "AND SD2.D2_LOJA = ? "
						cQryD += "AND SFB.FB_CPOLVRO = ? "
						cQryD += "AND SD2.D2_FILIAL = ? "
						cQryD += "AND SFC.FC_FILIAL = ? "
						cQryD += "AND SFB.FB_FILIAL = ? "
						If lCpoTan .Or. lCpoObjI
							cQryD += "AND SB1.B1_FILIAL = ? "
							cQryD += "AND SB1.D_E_L_E_T_  = ? "
						EndIf
						cQryD += "AND SD2.D_E_L_E_T_  = ? "
						cQryD += "AND SFB.D_E_L_E_T_  = ? "
						cQryD += "AND SFC.D_E_L_E_T_  = ? "
						cQryD += "GROUP BY SD2.D2_FILIAL, SD2.D2_SERIE, SD2.D2_DOC, SD2.D2_CLIENTE, SD2.D2_LOJA,SD2.D2_EMISSAO, ?"
						cQryD := ChangeQuery(cQryD)

						oExecDoc := FwExecStatement():New(cQryD)

						oExecDoc:SetUnsafe(nOrd++,cCposSel)  
						oExecDoc:SetUnsafe(nOrd++,cCposAcu)   
						oExecDoc:SetUnsafe(nOrd++,cTabSD2)
						oExecDoc:SetUnsafe(nOrd++,cTabSFC)
						oExecDoc:SetUnsafe(nOrd++,cTabSFB)
						If lCpoTan .Or. lCpoObjI
							oExecDoc:SetUnsafe(nOrd++,cTabSB1)
						EndIf
						oExecDoc:SetString(nOrd++,SE2->E2_NUM)     //Documento
						oExecDoc:SetString(nOrd++,SE2->E2_PREFIXO) //Serie
						oExecDoc:SetString(nOrd++,SE2->E2_FORNECE) //Proveedor
						oExecDoc:SetString(nOrd++,SE2->E2_LOJA)    //Tienda
						oExecDoc:SetString(nOrd++,cImp)            //Número Campo de Libro
						oExecDoc:SetString(nOrd++,cFilSD2)         //Filial SD2
						oExecDoc:SetString(nOrd++,cFilSFC)         //Filial SFC
						oExecDoc:SetString(nOrd++,cFilSFB)        //Filial SFB
						If lCpoTan .Or. lCpoObjI
							oExecDoc:SetString(nOrd++,cFilSB1)      //Filial SB1
							oExecDoc:SetString(nOrd++,' ')          //SB1.D_E_L_E_T_
						EndIf
						oExecDoc:SetString(nOrd++,' ')            //SD2.D_E_L_E_T_
						oExecDoc:SetString(nOrd++,' ')            //SFB.D_E_L_E_T_
						oExecDoc:SetString(nOrd++,' ')            //SFC.D_E_L_E_T_
						oExecDoc:SetUnsafe(nOrd++,cCposGru)

						cAliasD := oExecDoc:OpenAlias()

						dbSelectArea(cAliasD)
						(cAliasD)->(DbGoTop())
						While (cAliasD )->(!Eof())

							nValImp := 0
							nBase   := 0

							If (cAliasD)->BASE > 0
								nSumBase	+= (cAliasD)->BASE
								nSumImp		+= (cAliasD)->VALIMP
							EndIf
						
							If _cCpoIVC == cImp .OR. _cCpoIEPS == cImp //Tratamiento para IVA Incluido e IEPS
								nValImp := ((cAliasD)->VALIMP * nTaxa * nPorcion) 
								nBase   := ((cAliasD)->BASE * nTaxa * nPorcion) * (-1)
							Else
								nValImp := (cAliasD)->VALIMP * nTaxa * nPorcion
								nBase   := (cAliasD)->BASE * nTaxa * nPorcion
							EndIf

							nImpImp	:= (cAliasD)->ALIQ //Alícuota

							//Tipo de Iva
							If lCpoTpIv .And. !Empty((cAliasD)->FB_TIPOIVA)
								cTipoIVA := (cAliasD)->FB_TIPOIVA
							Else
								cTipoIVA := "1" //1-Acreditable No Proporcional
							EndIf

							//Objeto de Impuesto
							If lCpoObjI .And. !Empty((cAliasD)->B1_OBJIVA)
								cProdOI := (cAliasD)->B1_OBJIVA
							Else
								cProdOI := "1" //1-Si
							EndIf

							//Producto Tangible
							If cTipT == "05" .And. lCpoTan .And. !Empty((cAliasD)->B1_PRODTAN)
								cProdT := (cAliasD)->B1_PRODTAN
							Else
								cProdT := "1" //1-Si
							EndIf

							If nBase > 0
								nPos := aScan(aPgosDIOT, {|X| X[1]+X[2]+X[3]+X[4]+X[5]+X[6] == ""+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_PARCELA+SE2->E2_FORNECE+SE2->E2_LOJA})
								If nPos == 0								
									aAdd(aPgosDIOT, {"", SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_PARCELA, SE2->E2_FORNECE , SE2->E2_LOJA, "", cTipT, cTipO, cRFC, cID, cPai, SE2->E2_EMISSAO, ;
														0,0,0,0,0,0,0,0,0,0, ;
														0,0,0,0,0,0,0,0,0,0, ;
														0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, ;
														0,0,0,0,0,0,0,SE2->E2_TIPO ;
														})

									nPosD := Len(aPgosDIOT)
								Else
									nPosD := nPos
								EndIf

								Do Case
									Case !cImp $  _CIMPRET // Solo que no sea impuesto retenido
										nImpImp := Round(nImpImp,1)	
										nValImp := nValImp * (-1)
										If cTipT $ "04|15" .And. Empty(cRegPro)
											If nImpImp == 8
												cRegPro := "1" //Frontera Norte
											Else	
												cRegPro := "3" //Interior del País
											EndIf
										EndIf
										FS88CLASIF(@aPgosDIOT, nPosD, cRegPro, nBase, nImpImp, nValImp, cTipT, cTipoIVA, cProdT, cProdOI, 2)
									Case cImp == _CIMPRET
										aPgosDIOT[nPosD,54] += nValImp
								EndCase
							EndIf
						
							(cAliasD)->(dbskip())
						EndDo
					Next nY

					(cAliasD)->(DBCloseArea())
				Else
					nPos := aScan(aPgosDIOT, {|X| X[1]+X[2]+X[3]+X[4]+X[5]+X[6] == ""+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_PARCELA+SE2->E2_FORNECE+SE2->E2_LOJA})
					
					If nPos == 0
						aAdd(aPgosDIOT, {"", SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_PARCELA, SE2->E2_FORNECE , SE2->E2_LOJA, "", cTipT, cTipO, cRFC, cID, cPai, SE2->E2_EMISSAO, ;
											0,0,0,0,0,0,0,0,0,0, ;
											0,0,0,0,0,0,0,0,0,0, ;
											0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, ;
											0,0,0,0,0,0,0, SE2->E2_TIPO ;
											})
						nPosD := Len(aPgosDIOT)
					Else
						nPosD := nPos
					EndIf
				EndIf
				//Base Exento
				nBasExe := (SE2->E2_VALOR - (nSumBase + nSumImp))
				If nBasExe > 0
					nBasExe :=  nBasExe * nTaxa * nPorcion
					If cTipT == '05'  //IVA Exento Extranjero
						aPgosDIOT[nPosD,55] += nBasExe
					Else //IVA Exento Nacional
						aPgosDIOT[nPosD,56] += nBasExe
					EndIf
				EndIf
				If oExecImp <> Nil
					oExecImp:Destroy()
					oExecImp := Nil
				EndIf
				If oExecDoc <> Nil
					oExecDoc:Destroy()
					oExecDoc := Nil
				EndIf
			EndIf
		EndIf
		IncProc()
		(cAlias)->(DBSkip())
	EndDo
	(cAlias)->(DBCloseArea())

	If oExeSE5 <> Nil
		oExeSE5:Destroy()
		oExeSE5 := Nil
	EndIf

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} FS88CLASIF
	LLenado de arreglo con clasificación de bases e IVAS
	@type  Function
	@author Alfredo Medrano
	@since 06/03/2025
	@version version
	@param aPgosDIOT, arreglo, Arreglo con bases e IVAS
	@param nPosD, numeric, Posición del registro en el arreglo
	@param cRegPro, caracter, Región de Proveedores Nacionales
	@param nBase, numeric, Base el Impuesto
	@param nImpImp, numeric, Alícuota del Impuesto
	@param nValImp, numeric, Valor del Impuesto
	@param cTipT, caracter, Tipo de Tercero del Proveedor
	@param cTipoIVA, caracter, Tipo de IVA
	@param cProdT, caracter, Producto Tangible
	@param cProdOI, caracter, Producto Objeto de Impuesto
	@param nOpc, numeric, 1-Facturas / 2-Nota de Crédito de Proveedor
	@return return_var, return_type, return_description
	@example
	FS88CLASIF(aPgosDIOT, nPosD, cRegPro, nBase, nImpImp, nValImp, cTipT, cTipoIVA, cProdT, cProdOI, nOpc)
	@see (links_or_references)
/*/
Function FS88CLASIF(aPgosDIOT, nPosD, cRegPro, nBase, nImpImp, nValImp, cTipT, cTipoIVA, cProdT, cProdOI, nOpc)
	Local nPosBseFN  := 14 
	Local nPosBseFS  := 16
	Local nPosBseIP  := 18
	Local nPosBseET  := 20
	Local nPosBseENT := 22

	Default aPgosDIOT := {}
	Default cRegPro   := "1" //1-Frontera Norte
	Default nBase     := 0
	Default nImpImp   := 0
	Default nValImp   := 0
	Default cTipT     := ""
	Default cTipoIVA  := "1" //1-Acreditable No Proporcional
	Default cProdT    := "1" //1-SI Tangible
	Default cProdOI   := "1" //1-SI Objeto de IVA
	Default nOpc      := 1

	If nOpc = 2
	 	nPosBseFN  := 15 
		nPosBseFS  := 17
		nPosBseIP  := 19
		nPosBseET  := 21
		nPosBseENT := 23
	EndIf
								
	Do Case
		Case nImpImp == 0 //IVA 0%
			aPgosDIOT[nPosD, 57] += nBase
		//Frontera Norte - Proveedor 04-Nacional/15-Global
		Case cRegPro == "1" .And. cTipT $ '04|15' 
			aPgosDIOT[nPosD, nPosBseFN] += nBase
			If cTipoIVA == "1" //1-Acreditable No Proporcional
				aPgosDIOT[nPosD, 24] += nValImp
			ElseIf cTipoIVA == "2" //2-No Acreditable No Proporcional 
				If cProdOI == "1" //1-SI Objeto de IVA
					aPgosDIOT[nPosD, 35] += nValImp
				ElseIf cProdOI == "2" //2-NO Objeto de IVA 
					aPgosDIOT[nPosD, 37] += nValImp
				EndIf
			ElseIf cTipoIVA == "3" //3-Acreditable Proporcional
				aPgosDIOT[nPosD, 25] += nValImp
			ElseIf cTipoIVA == "4" //4-No Acreditable Proporcional
				If cProdOI == "1" //1-SI Objeto de IVA
					aPgosDIOT[nPosD, 34] += nValImp
				EndIf
			EndIf
		//Frontera Sur
		Case cRegPro == "2" .And. cTipT $ '04|15'
			aPgosDIOT[nPosD, nPosBseFS] += nBase
			If cTipoIVA == "1" //1-Acreditable No Proporcional
				aPgosDIOT[nPosD, 26] += nValImp
			ElseIf cTipoIVA == "2" //2-No Acreditable No Proporcional
				If cProdOI == "1" //1-SI Objeto de IVA
					aPgosDIOT[nPosD, 39] += nValImp
				ElseIf cProdOI == "2" //2-NO Objeto de IVA 
					aPgosDIOT[nPosD, 41] += nValImp
				EndIf
			ElseIf cTipoIVA == "3" //3-Acreditable Proporcional
				aPgosDIOT[nPosD, 27] += nValImp
			ElseIf cTipoIVA == "4" //4-No Acreditable Proporcional
				aPgosDIOT[nPosD, 38] += nValImp
			EndIf
		//Interior del País
		Case cRegPro == "3" .And. cTipT$ '04|15'
			aPgosDIOT[nPosD, nPosBseIP] += nBase
			If cTipoIVA == "1" //1-Acreditable No Proporcional
				aPgosDIOT[nPosD, 28] += nValImp
			ElseIf cTipoIVA == "2" //2-No Acreditable No Proporcional
				If cProdOI == "1" //1-SI Objeto de IVA
					aPgosDIOT[nPosD, 43] += nValImp
				ElseIf cProdOI == "2" //2-NO Objeto de IVA 
					aPgosDIOT[nPosD, 45] += nValImp
				EndIf												
			ElseIf cTipoIVA == "3" //3-Acreditable Proporcional
				aPgosDIOT[nPosD, 29] += nValImp
			ElseIf cTipoIVA == "4" //4-No Acreditable Proporcional
				aPgosDIOT[nPosD, 42] += nValImp
			EndIf
		//05 Proveedor Extranjero - Producto Tangible
		Case cTipT=='05' .And. cProdT = '1'
			aPgosDIOT[nPosD, nPosBseET] += nBase
			If cTipoIVA == "1" //1-Acreditable No Proporcional
				aPgosDIOT[nPosD, 30] += nValImp
			ElseIf cTipoIVA == "2" //2-No Acreditable No Proporcional
				If cProdOI == "1" //1-SI Objeto de IVA
					aPgosDIOT[nPosD, 47] += nValImp
				ElseIf cProdOI == "2" //2-NO Objeto de IVA 
					aPgosDIOT[nPosD, 49] += nValImp
				EndIf												
			ElseIf cTipoIVA == "3" //3-Acreditable Proporcional
				aPgosDIOT[nPosD, 31] += nValImp
			ElseIf cTipoIVA == "4" //4-No Acreditable Proporcional
				aPgosDIOT[nPosD, 46] += nValImp
			EndIf
		//05 Proveedor Extranjero - Producto Intangible o servicio
		Case cTipT=='05' .And. cProdT = '2'
			aPgosDIOT[nPosD, nPosBseENT] += nBase
			If cTipoIVA == "1" //1-Acreditable No Proporcional
				aPgosDIOT[nPosD, 32] += nValImp
			ElseIf cTipoIVA == "2" //2-No Acreditable No Proporcional
				If cProdOI == "1" //1-SI Objeto de IVA
					aPgosDIOT[nPosD, 51] += nValImp
				ElseIf cProdOI == "2" //2-NO Objeto de IVA 
					aPgosDIOT[nPosD, 53] += nValImp
				EndIf
			ElseIf cTipoIVA == "3" //3-Acreditable Proporcional
				aPgosDIOT[nPosD, 33] += nValImp
			ElseIf cTipoIVA == "4" //4-No Acreditable Proporcional
				aPgosDIOT[nPosD,50] += nValImp
			EndIf
	EndCase
Return Nil

	
