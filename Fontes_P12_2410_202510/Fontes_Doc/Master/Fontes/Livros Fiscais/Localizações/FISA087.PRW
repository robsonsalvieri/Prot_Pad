#INCLUDE "PROTHEUS.CH"
#INCLUDE "FwLibVersion.ch"
#INCLUDE "FISA087.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FISA087  ³ Autor ³Mayra Camargo          ³ Data ³ 21/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generación del archivo de Declaraciones Informativas de    ³±±
±±³          ³ operacioes con Terceros correspondients al 2014.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA087()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³17/05/18³DMINA-2612³En Fun SELMOVCE8 por cada sucursal se ³±±
±±³            ³        ³          ³crea un query asignando UNION ALL para³±±
±±³            ³        ³          ³el uso de Xfilial en tablas con dif.  ³±±
±±³            ³        ³          ³permisos SA2 vs CE8 (Exclusivas vs Com³±±
±±³            ³        ³          ³-partidas) En Fun TodoOk se agrega    ³±±
±±³            ³        ³          ³Valid para Filial Null                ³±±
±±³Alf. Medrano³21/05/18³DMINA-3163³En fun SelMovCE8 se asigna Order by al³±±
±±³            ³        ³          ³Final de query para Union ALL         ³±±
±±³Alf. Medrano³30/01/19³DMINA-5571³En fun vldCaract() no se considera la ³±±
±±³            ³        ³          ³la letra “Ñ” para la validación de la ³±±
±±³            ³        ³          ³razón social de los proveedores.      ³±±
±±³LuisEnríquez³14/03/19³DMINA-6191³Se modifican funs. SelMovCE8 y GenArch³±±
±±³            ³        ³          ³para colocar en la posicion 13 el acu-³±±
±±³            ³        ³          ³mulado del campo CE8_BASE8 y se agrega³±±
±±³            ³        ³          ³el valor vacío en la posicion 15 (MEX)³±±
±±³  Marco A.  ³30/08/19³DMINA-7263³Se modifican la funcion SelMovCE8,    ³±±
±±³            ³        ³          ³para acumular los valores de las bases³±±
±±³            ³        ³          ³por RFC de Proveedores. (MEX)         ³±±
±±³  Marco A.  ³11/09/19³DMINA-7474³Se modifican la funcion SelMovCE8,    ³±±
±±³            ³        ³          ³para acumular los valores de las bases³±±
±±³            ³        ³          ³por RFC de Proveedores Extranjeros.   ³±±
±±³            ³        ³          ³Tambien se permite el caracter & en el³±±
±±³            ³        ³          ³Nombre (A2_NOME).                     ³±±
±±³  Marco A.  ³04/10/19³DMINA-7514³Se modifica la funcion SelMovCE8, para³±±
±±³            ³        ³          ³acumular los valores de las bases en  ³±±
±±³            ³        ³          ³base al Tipo Tercero en el proveedor. ³±±
±±³  Marco A.  ³24/10/19³DMINA-7649³Se realizan multiples correcciones    ³±±
±±³            ³        ³          ³para estabilizar el DIOT en ambientes ³±±
±±³            ³        ³          ³con financiero compartido.            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FISA087()

	Local aGetArea	:= GetArea()
	Local aSays		:= {}
	Local aButtons	:= {}
	Local nOpca		:= 0
	Local cPerg		:= "FISA087"
	Local cCadastro	:= STR0001 	//"Generación del archivo de DIOT"

	Private cMes		:= ""
	Private cAnio		:= ""
	Private cMesAno		:= ""
	Private cSucur		:= ""
	Private cArchivo	:= ""
	Private cRuta		:= ""
	Private dFecIni		:= CToD("  /  /  ")
	Private dFecFin		:= CToD("  /  /  ")
	Private aTmpMov		:= {}
	Private aErrores	:= {}
	Private nTotREg		:= 0
	Private cEnviar		:= ""

	aAdd(aSays,OemToAnsi(STR0002) ) // "Esta rutina genera el archivo de Declaraciones Informativas de Operaciones con "
	aAdd(aSays,OemToAnsi(STR0003) ) // "Terceros correspondientes al 2008, con la versión del DIOT completa 2008. "

	aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } }  )
	aAdd(aButtons, { 1,.T.,{|o| nOpca := 1,IF(TodoOK(cPerg),FechaBatch(),nOpca:=0) }} )
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

	FormBatch( cCadastro, aSays, aButtons )

	If nOpca == 1
		Processa({|| FS087GERA() },OemToAnsi(STR0004)) //"Procesando..."
	Endif

	RestArea(aGetArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS087GERA³ Autor ³ Mayra Camargo         ³ Data ³ 21/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para generar el proceso para obtencion de registros³±±
±±³          ³ y generacion del archivo.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS087GERA()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FS087GERA()

	Local lRet := .T.  //(F=No se genero el archivo)

	nTotREg := 0

	IncProc(STR0005) // "Obteniendo informacion..."
	aTmpMov := SelMovCE8()

	If !Empty(aTmpMov)
		IncProc(STR0006) // "Generando archivo..."
		lRet := GenArch()
	Else
	    MsgInfo(STR0007) // "No encontro registros para generar el archivo!"
	    lRet := .F.
	EndIf

	If lRet
		If Len(aErrores) > 0
			If MsgYesNo(STR0008) // "Errores encotrados, ¿Quiere verificar el LOG?"
				ImprimeLog()
			EndIf
		Else
			Aviso(STR0009, STR0010 + AllTrim(MV_PAR04) + AllTrim(MV_PAR03) + ".txt", {STR0011})    // "Atención" "Proceso concluido con éxito, se genero el archivo en la siguiente ruta: " "OK"
			If MsgYesNo(STR0012) // "¿Quiere verificar el LOG del Proceso?"
				ImprimeLog()
			EndIf
		EndIf
	Else
		MsgInfo(STR0013)     // "No se genero el archivo, proceso concluido!"
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³SelMovCE8 ³ Autor ³ Mayra Camargo         ³ Data ³ 21/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion para seleccionar los movimientos de la tabla CE8,  ³±±
±±³          ³ acuerdo a los parámetros de entrada.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SelMovCE8()                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SelMovCE8()

	Local cAliasTmp		:= CriaTrab(Nil,.F.)
	Local cCE8Name		:= InitSqlName("CE8")
	Local cSA2Name		:= InitSqlName("SA2")
	Local cQuery		:= ""
	Local aMovimien		:= {}
	Local aFils			:= {}
	Local nTamFil		:= 0
	Local nCont			:= 0
	Local aEncabeMov	:= {}
	Local aTotalMovs	:= {}
	Local lProvNac		:= .F.
	Local lProvExt		:= .F.
	Local cDiotVer		:= "1"
	Local nLugJurF		:= SA2->(FieldPos("A2_LUGJURF"))
	Local nBase8		:= CE8->(FieldPos("CE8_BASE8"))
	Local cQry			:= ""
	Local lVerLib		:= (FwLibVersion() >= "20211116")
	Local oQry			:= Nil
	Local cFilSA2		:= xFilial("SA2")
	Local cFilSYA       := xFilial("SYA")
	Local aFiltros      := {}
	Local nX            := 0
	Local nResiduo		:= 0

	If cPaisLoc == "MEX"
		cDiotVer := SuperGetMV("MV_DIOTVER", .F., "1")
	EndIf

	cSucur := Alltrim(cSucur)
	aFils := StrToKArr(cSucur, ';')
	nTamFil := len(aFils)

	If cDiotVer == "1"
		cQry := "CE8_TIPTER, CE8_TIPOPE, CE8_RFC, CE8_IDFISC, A2_NOME, CE8_PAIS,  CE8_PROV, CE8_TIENDA, "
		cQry += "SUM(CE8_BA1516) CE8_BA1516, SUM(CE8_BASE15) CE8_BASE15, SUM(CE8_BA1011) CE8_BA1011, SUM(CE8_BASE10) CE8_BASE10,"
		cQry += "SUM(CE8_BI1516) CE8_BI1516, SUM(CE8_BI1011) CE8_BI1011, SUM(CE8_BASIEX) CE8_BASIEX, SUM(CE8_BASE0) CE8_BASE0,"
		cQry += "SUM(CE8_BASEEX) CE8_BASEEX, SUM(CE8_IVARET) CE8_IVARET, SUM(CE8_IVADEV) CE8_IVADEV, " + IIf( nBase8 > 0, "SUM(CE8_BASE8) CE8_BASE8 ", "")
	Else
		// Datos del tercero declarado
		cQry := "CE8_TIPTER, CE8_TIPOPE, CE8_RFC, CE8_IDFISC, A2_NOME, CE8_PAIS,  CE8_PROV, CE8_TIENDA, "
		// Valor de los actos o actividades
		cQry += "SUM(CE8_BA1011) CE8_BA1011, SUM(CE8_BASE8) CE8_BASE8, SUM(CE8_BASE10) CE8_BASE10, SUM(CE8_BI1011) CE8_BI1011, SUM(CE8_BA1516) CE8_BA1516, SUM(CE8_BI1516) CE8_BI1516, "
		cQry += "SUM(CE8_BASE15) CE8_BASE15, SUM(CE8_BASDVA) CE8_BASDVA, SUM(CE8_BASDVB) CE8_BASDVB, SUM(CE8_BASDVC) CE8_BASDVC, "
		// IVA acreditable
		cQry += "SUM(CE8_IVAACA) CE8_IVAACA, SUM(CE8_IVAACB) CE8_IVAACB, SUM(CE8_IVAACC) CE8_IVAACC, SUM(CE8_IVAACD) CE8_IVAACD, SUM(CE8_IVAACE) CE8_IVAACE, SUM(CE8_IVAACF) CE8_IVAACF, "
		cQry += "SUM(CE8_IVAACG) CE8_IVAACG, SUM(CE8_IVAACH) CE8_IVAACH, SUM(CE8_IVAACI) CE8_IVAACI, SUM(CE8_IVAACJ) CE8_IVAACJ, "
		// IVA no acreditable
		cQry += "SUM(CE8_IVANAA) CE8_IVANAA, SUM(CE8_IVANAB) CE8_IVANAB, SUM(CE8_IVANAC) CE8_IVANAC, SUM(CE8_IVANAD) CE8_IVANAD, SUM(CE8_IVANAE) CE8_IVANAE, SUM(CE8_IVANAF) CE8_IVANAF, "
		cQry += "0 CE8_IVANAG, SUM(CE8_IVANAH) CE8_IVANAH, SUM(CE8_IVANAI) CE8_IVANAI, SUM(CE8_IVANAJ) CE8_IVANAJ, 0 CE8_IVANAK, SUM(CE8_IVANAL) CE8_IVANAL, "
		cQry += "SUM(CE8_IVANAM) CE8_IVANAM, SUM(CE8_IVANAN) CE8_IVANAN, 0 CE8_IVANAO, SUM(CE8_IVANAP) CE8_IVANAP, SUM(CE8_IVANAQ) CE8_IVANAQ, SUM(CE8_IVANAR) CE8_IVANAR, "
		cQry += "0 CE8_IVANAS, SUM(CE8_IVANAT) CE8_IVANAT, "
		// Datos adicionales
		cQry += "SUM(CE8_IVARET) CE8_IVARET, SUM(CE8_BASIEX) CE8_BASIEX, SUM(CE8_BASEEX) CE8_BASEEX, SUM(CE8_BASE0) CE8_BASE0, SUM(CE8_VALTOT) CE8_VALTOT, SUM(CE8_IVADEV) CE8_IVADEV "
	EndIf

	For nCont := 1 to nTamFil
		If nCont > 1
			cQuery += " UNION ALL "
		Else
			cQuery := " "
		EndIf

		aAdd(aFiltros,{cQry})
		aAdd(aFiltros,{cCE8Name})
		aAdd(aFiltros,{cSA2Name})
		aAdd(aFiltros,{cMesAno})
		aAdd(aFiltros,{aFils[nCont]})
		aAdd(aFiltros,{xFilial("SA2" , STRTRAN( aFils[nCont], "'", ""))})

		cQuery += "SELECT ?"
		cQuery += " FROM ? CE8, ? SA2"
		cQuery += " WHERE "
		cQuery += " CE8_MESANO = ?"
		cQuery += " AND CE8_FILIAL = ? AND A2_FILIAL = ?"
		cQuery += " AND CE8_PROV = A2_COD"
		cQuery += " AND CE8_TIENDA = A2_LOJA"
		cQuery += " AND CE8.D_E_L_E_T_= ' '"
		cQuery += " AND SA2.D_E_L_E_T_= ' '"
		cQuery += " GROUP BY CE8_TIPTER, CE8_RFC, CE8_TIPOPE, CE8_IDFISC, A2_NOME, CE8_PAIS, CE8_PROV, CE8_TIENDA"

		If nCont == nTamFil
			cQuery += " ORDER BY CE8_TIPTER, CE8_RFC, CE8_TIPOPE, CE8_IDFISC, A2_NOME, CE8_PAIS, CE8_PROV, CE8_TIENDA"
		EndIf
	Next nCont

	cQuery := ChangeQuery(cQuery)
	oQry := IIf(lVerLib, FwExecStatement():New( cQuery ), FWPreparedStatement():New( cQuery ))
	For nX := 1 To Len(aFiltros)
		nResiduo := (nX % 6)
		If (nResiduo > 0 .And. nResiduo < 4)
			oQry:SetUnsafe(nX,aFiltros[nX][1])
		Else
			oQry:SetString(nX,aFiltros[nX][1])
		EndIf
	Next nX
	
	cAliasTmp := IIf(lVerLib, oQry:OpenAlias(), MpSysOpenQuery(oQry:GetFixQuery()))

	dbSelectArea(cAliasTmp)
	Count to nTotREg
	(cAliasTmp)->(DBGoTop())

	ProcRegua(nTotREg)

	aTotalMovs := Array( IIf(cDiotVer == "1", 12, 46) )

	While (cAliasTmp)->(!EOF())

		IncProc()

		aSize(aEncabeMov, 0)
		aFill(aTotalMovs, 0)
		lProvNac	:= .F.
		lProvExt	:= .F.

		If AllTrim((cAliasTmp)->CE8_TIPTER) == "04" .And. AllTrim((cAliasTmp)->CE8_PAIS) == "493" //Si el Proveedor es Nacional
			lProvNac := .T.
		ElseIf AllTrim((cAliasTmp)->CE8_TIPTER) == "05" .And. AllTrim((cAliasTmp)->CE8_PAIS) <> "493" //Si el Proveedor es Extranjero
			lProvExt := .T.
		EndIf

		aAdd(aEncabeMov, {(cAliasTmp)->CE8_TIPTER,;
						(cAliasTmp)->CE8_TIPOPE,;
						IIf(lProvNac .Or. lProvExt, AllTrim((cAliasTmp)->CE8_RFC), ""),;
						IIf(lProvExt, AllTrim((cAliasTmp)->CE8_IDFISC), ""),;
						IIf(lProvExt, AllTrim((cAliasTmp)->A2_NOME), ""),;
						IIf(lProvExt, AllTrim(Posicione("SYA", 1, cFilSYA + (cAliasTmp)->CE8_PAIS, "YA_CCESAT")), ""),;
						IIF(lProvExt, AllTrim(Posicione("SYA", 1, cFilSYA + (cAliasTmp)->CE8_PAIS, "YA_NASCIO")), ""),;
						AllTrim((cAliasTmp)->CE8_PROV),;
						AllTrim((cAliasTmp)->CE8_TIENDA),;
						""})
		
		If cDiotVer > "1" .And. nLugJurF > 0 .And. (cAliasTmp)->CE8_TIPTER == "05" .And. ((cAliasTmp)->CE8_PAIS == "ZZZ" .Or. aEncabeMov[1][6] == "ZZZ")
			If SA2->(msSeek(cFilSA2 + (cAliasTmp)->CE8_PROV + (cAliasTmp)->CE8_TIENDA))
				aEncabeMov[1][10] := SA2->A2_LUGJURF	// Campo Memo
			EndIf
		EndIf

		While (cAliasTmp)->(!EoF()) .And. IIf(lProvNac, AllTrim((cAliasTmp)->CE8_RFC) == AllTrim(aEncabeMov[1,3]), ; //Valida con RFC
											IIf(lProvExt, AllTrim((cAliasTmp)->CE8_IDFISC) == AllTrim(aEncabeMov[1,4]), ; //Valida con Identificador Fiscal
												AllTrim((cAliasTmp)->CE8_TIPTER) == AllTrim(aEncabeMov[1,1]))) //Valida Tipo Tercero igual a 15
			If cDiotVer == "1"
				aTotalMovs[1] += (cAliasTmp)->CE8_BA1516
				aTotalMovs[2] += (cAliasTmp)->CE8_BASE15
				aTotalMovs[3] += (cAliasTmp)->CE8_BA1011
				aTotalMovs[4] += (cAliasTmp)->CE8_BASE10
				aTotalMovs[5] += (cAliasTmp)->CE8_BI1516
				aTotalMovs[6] += (cAliasTmp)->CE8_BI1011
				aTotalMovs[7] += (cAliasTmp)->CE8_BASIEX
				aTotalMovs[8] += (cAliasTmp)->CE8_BASE0
				aTotalMovs[9] += (cAliasTmp)->CE8_BASEEX
				aTotalMovs[10] += (cAliasTmp)->CE8_IVARET
				aTotalMovs[11] += (cAliasTmp)->CE8_IVADEV
				aTotalMovs[12] += IIf(nBase8 > 0, (cAliasTmp)->CE8_BASE8, 0)
			Else
				aTotalMovs[01] += (cAliasTmp)->CE8_BA1011
				aTotalMovs[02] += (cAliasTmp)->CE8_BASE8
				aTotalMovs[03] += (cAliasTmp)->CE8_BASE10
				aTotalMovs[04] += (cAliasTmp)->CE8_BI1011
				aTotalMovs[05] += (cAliasTmp)->CE8_BA1516
				aTotalMovs[06] += (cAliasTmp)->CE8_BI1516
				aTotalMovs[07] += (cAliasTmp)->CE8_BASE15
				aTotalMovs[08] += (cAliasTmp)->CE8_BASDVA
				aTotalMovs[09] += (cAliasTmp)->CE8_BASDVB
				aTotalMovs[10] += (cAliasTmp)->CE8_BASDVC
				//Frontera Norte - IVA ACREDITABLE NO PROPORCIONAL
				aTotalMovs[11] += RecalcIVA((cAliasTmp)->CE8_BA1011-(cAliasTmp)->CE8_BASE8,(cAliasTmp)->CE8_IVAACA) 
				//Frontera Norte - IVA ACREDITABLE PROPORCIONAL
				aTotalMovs[12] += RecalcIVA((cAliasTmp)->CE8_BA1011-(cAliasTmp)->CE8_BASE8,(cAliasTmp)->CE8_IVAACB)
				//Frontera Sur - IVA ACREDITABLE NO PROPORCIONAL
				aTotalMovs[13] += RecalcIVA((cAliasTmp)->CE8_BASE10-(cAliasTmp)->CE8_BI1011,(cAliasTmp)->CE8_IVAACC)
				//Frontera Sur - IVA ACREDITABLE PROPORCIONAL
				aTotalMovs[14] += RecalcIVA((cAliasTmp)->CE8_BASE10-(cAliasTmp)->CE8_BI1011,(cAliasTmp)->CE8_IVAACD)
				//Interior del País - IVA ACREDITABLE NO PROPORCIONAL
				aTotalMovs[15] += RecalcIVA((cAliasTmp)->CE8_BA1516-(cAliasTmp)->CE8_BI1516,(cAliasTmp)->CE8_IVAACE)
				//Interior del País - IVA ACREDITABLE PROPORCIONAL
				aTotalMovs[16] += RecalcIVA((cAliasTmp)->CE8_BA1516-(cAliasTmp)->CE8_BI1516,(cAliasTmp)->CE8_IVAACF)
				//Extranjero - IVA ACREDITABLE NO PROPORCIONAL - TANGIBLE
				aTotalMovs[17] += RecalcIVA((cAliasTmp)->CE8_BASE15-(cAliasTmp)->CE8_BASDVA,(cAliasTmp)->CE8_IVAACG)
				//Extranjero - IVA ACREDITABLE PROPORCIONAL - TANGIBLE
				aTotalMovs[18] += RecalcIVA((cAliasTmp)->CE8_BASE15-(cAliasTmp)->CE8_BASDVA,(cAliasTmp)->CE8_IVAACH) 
				//Extranjero - IVA ACREDITABLE NO PROPORCIONAL - INTANGIBLE
				aTotalMovs[19] += RecalcIVA((cAliasTmp)->CE8_BASDVB-(cAliasTmp)->CE8_BASDVC,(cAliasTmp)->CE8_IVAACI)  
				//Extranjero - IVA ACREDITABLE PROPORCIONAL - INTANGIBLE
				aTotalMovs[20] += RecalcIVA((cAliasTmp)->CE8_BASDVB-(cAliasTmp)->CE8_BASDVC,(cAliasTmp)->CE8_IVAACJ)
				//Frontera Norte - IVA NO ACREDITABLE PROPORCIONAL
				aTotalMovs[21] += RecalcIVA((cAliasTmp)->CE8_BA1011-(cAliasTmp)->CE8_BASE8,(cAliasTmp)->CE8_IVANAA)
				//Frontera Norte - IVA NO ACREDITABLE NO PROPORCIONAL
				aTotalMovs[22] += RecalcIVA((cAliasTmp)->CE8_BA1011-(cAliasTmp)->CE8_BASE8,(cAliasTmp)->CE8_IVANAB)
				//Frontera Norte - Exento
				aTotalMovs[23] += RecalcIVA((cAliasTmp)->CE8_BA1011-(cAliasTmp)->CE8_BASE8,(cAliasTmp)->CE8_IVANAC)
				//Frontera Norte - IVA NO ACREDITABLE NO PROPORCIONAL - No Objeto IVA
				aTotalMovs[24] += RecalcIVA((cAliasTmp)->CE8_BA1011-(cAliasTmp)->CE8_BASE8,(cAliasTmp)->CE8_IVANAD)
				//Frontera Sur - IVA NO ACREDITABLE PROPORCIONAL
				aTotalMovs[25] += RecalcIVA((cAliasTmp)->CE8_BASE10-(cAliasTmp)->CE8_BI1011,(cAliasTmp)->CE8_IVANAE)
				//Frontera Sur - IVA NO ACREDITABLE NO PROPORCIONAL
				aTotalMovs[26] += RecalcIVA((cAliasTmp)->CE8_BASE10-(cAliasTmp)->CE8_BI1011,(cAliasTmp)->CE8_IVANAF)
				//Frontera Sur - Exento
				aTotalMovs[27] += RecalcIVA((cAliasTmp)->CE8_BASE10-(cAliasTmp)->CE8_BI1011,(cAliasTmp)->CE8_IVANAG)
				//Frontera Sur - IVA NO ACREDITABLE NO PROPORCIONAL - No Objeto IVA
				aTotalMovs[28] += RecalcIVA((cAliasTmp)->CE8_BASE10-(cAliasTmp)->CE8_BI1011,(cAliasTmp)->CE8_IVANAH)
				//Interior de País - IVA NO ACREDITABLE PROPORCIONAL
				aTotalMovs[29] += RecalcIVA((cAliasTmp)->CE8_BA1516-(cAliasTmp)->CE8_BI1516,(cAliasTmp)->CE8_IVANAI)
				//Interior de País - IVA NO ACREDITABLE NO PROPORCIONAL
				aTotalMovs[30] += RecalcIVA((cAliasTmp)->CE8_BA1516-(cAliasTmp)->CE8_BI1516,(cAliasTmp)->CE8_IVANAJ)
				//Interior de País - Exento
				aTotalMovs[31] += RecalcIVA((cAliasTmp)->CE8_BA1516-(cAliasTmp)->CE8_BI1516,(cAliasTmp)->CE8_IVANAK)
				//Interior de País - IVA NO ACREDITABLE NO PROPORCIONAL - No Objeto IVA
				aTotalMovs[32] += RecalcIVA((cAliasTmp)->CE8_BA1516-(cAliasTmp)->CE8_BI1516,(cAliasTmp)->CE8_IVANAL)
				//Extranjero - IVA NO ACREDITABLE PROPORCIONAL - TANGIBLE
				aTotalMovs[33] += RecalcIVA((cAliasTmp)->CE8_BASE15-(cAliasTmp)->CE8_BASDVA,(cAliasTmp)->CE8_IVANAM)
				//Extranjero - IVA NO ACREDITABLE NO PROPORCIONAL - TANGIBLE
				aTotalMovs[34] += RecalcIVA((cAliasTmp)->CE8_BASE15-(cAliasTmp)->CE8_BASDVA,(cAliasTmp)->CE8_IVANAN)
				//Extranjero - Exento - TANGIBLE
				aTotalMovs[35] += RecalcIVA((cAliasTmp)->CE8_BASE15-(cAliasTmp)->CE8_BASDVA,(cAliasTmp)->CE8_IVANAO)
				//Extranjero - IVA NO ACREDITABLE NO PROPORCIONAL - No Objeto IVA - TANGIBLE
				aTotalMovs[36] += RecalcIVA((cAliasTmp)->CE8_BASE15-(cAliasTmp)->CE8_BASDVA,(cAliasTmp)->CE8_IVANAP)
				//Extranjero - IVA NO ACREDITABLE PROPORCIONAL - INTANGIBLE
				aTotalMovs[37] += RecalcIVA((cAliasTmp)->CE8_BASDVB-(cAliasTmp)->CE8_BASDVC,(cAliasTmp)->CE8_IVANAQ)
				//Extranjero - IVA NO ACREDITABLE NO PROPORCIONAL - INTANGIBLE
				aTotalMovs[38] += RecalcIVA((cAliasTmp)->CE8_BASDVB-(cAliasTmp)->CE8_BASDVC,(cAliasTmp)->CE8_IVANAR)
				//Extranjero - Exento - INTANGIBLE
				aTotalMovs[39] += RecalcIVA((cAliasTmp)->CE8_BASDVB-(cAliasTmp)->CE8_BASDVC,(cAliasTmp)->CE8_IVANAS)
				//Extranjero - IVA NO ACREDITABLE NO PROPORCIONAL - No Objeto IVA - TANGIBLE
				aTotalMovs[40] += RecalcIVA((cAliasTmp)->CE8_BASDVB-(cAliasTmp)->CE8_BASDVC,(cAliasTmp)->CE8_IVANAT)

				aTotalMovs[41] += (cAliasTmp)->CE8_IVARET
				aTotalMovs[42] += (cAliasTmp)->CE8_BASIEX
				aTotalMovs[43] += (cAliasTmp)->CE8_BASEEX
				aTotalMovs[44] += (cAliasTmp)->CE8_BASE0
				aTotalMovs[45] += (cAliasTmp)->CE8_VALTOT
				aTotalMovs[46] += (cAliasTmp)->CE8_IVADEV
			EndIf

			(cAliasTmp)->(DBSkip())
	 	EndDo

	 	//Estructura del array de movimientos (Hasta 2024)
		//+-------------------------+
		//| 1.- Tipo de tercero		|
		//| 2.- tipo Operacion		|
		//| 3.- RFC					|
		//| 4.- ID FISCAL PROV EXTR	|
		//| 5.- Nombre				|
		//| 6.- Pais				|
		//| 7.- nacionalidad   		|
		//| 8.- Base 15/16 nac		|
		//| 9.- Base 15				|
		//|10.- base 10/11 nac		|
		//|11.- Base 10 			|
		//|12.- Base Imp 15/16		|
		//|13.- Base Imp 10/11		|
		//|14.- Base imp Exenta		|
		//|15.- Base 0				|
		//|16.- Base Exenta         |
		//|17.- Iva retención		|
		//|18.- Iva devuelto		|
		//|19.- Documento		    |
		//|20.- Serie				|
		//|21.- Proveedor			|
		//|22.- Tienda				|
		//|23.- Base 8			    |
		//+-------------------------+

		If cDiotVer == "1"
			aAdd(aMovimien, {aEncabeMov[1,1],;
							aEncabeMov[1,2],;
							aEncabeMov[1,3],;
							aEncabeMov[1,4],;
							aEncabeMov[1,5],;
							aEncabeMov[1,6],;
							aEncabeMov[1,7],;
							aTotalMovs[1],;
							aTotalMovs[2],;
							aTotalMovs[3],;
							aTotalMovs[4],;
							aTotalMovs[5],;
							aTotalMovs[6],;
							aTotalMovs[7],;
							aTotalMovs[8],;
							aTotalMovs[9],;
							aTotalMovs[10],;
							aTotalMovs[11],;
							'',;
							'',;
							aEncabeMov[1,8],;
							aEncabeMov[1,9],;
							aTotalMovs[12]})
		Else
			aAdd(aMovimien, {aEncabeMov[1,1],;
							aEncabeMov[1,2],;
							aEncabeMov[1,3],;
							aEncabeMov[1,4],;
							aEncabeMov[1,5],;
							aEncabeMov[1,6],;
							aEncabeMov[1,7],;
							aEncabeMov[1,10],;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							0,;
							"",;
							"",;
							aEncabeMov[1,8],;
							aEncabeMov[1,9],;
							aClone(aTotalMovs)})
		EndIf

	EndDo

	(cAliasTmp)->( dbCloseArea())

	If oQry <> Nil
		oQry:Destroy()	
		oQry := Nil
	EndIf

Return aMovimien

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GenArch  ³ Autor ³ Mayra Camargo         ³ Data ³ 25/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcion que va a generar los registros para el archivo de  ³±±
±±³          ³ texto plano.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GenArch()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GenArch()

	Local nLoop		:= 0
	Local cArcDIOT	:= ""
	Local lRet		:= .T.
	Local oFileWrite
	Local nLimit 	:= 4096
	Local cDiotVer	:= "1"

	If cPaisLoc == "MEX"
		cDiotVer := SuperGetMV("MV_DIOTVER", .F., "1")
	EndIf

	cRuta := AllTrim(cRuta)
	cRuta := IIf(SubStr(cRuta, Len(cRuta), 1) == "\", cRuta, cRuta + "\")
	cArcDIOT := cRuta + AllTrim(cArchivo) + ".txt"   //Nombre_archivo.txt

	oFileWrite := FWFileWriter():New(cArcDIOT, .T., nLimit)

	// Valida a criação do Arquivo
	If oFileWrite:Exists()
	  	If MsgYesNo(OemToAnsi(STR0014 + Alltrim(cArcDIOT) + STR0015))   //"El archivo "+XXX+" ya existe, ¿Desea eliminarlo?"
			oFileWrite:Close()
			oFileWrite:Erase()
		Else
			lRet := .F.
		EndIf
	Endif

	If lRet
		oFileWrite:Create()
		If !(oFileWrite:Error():Cod == Nil)
	        FWAlertInfo(cValToChar(oFileWrite:Error():Message))
			lRet := .F.
		EndIf
	EndIf

	If lRet
		ProcRegua(Len(aTmpMov))

		For nLoop := 1 To Len(aTmpMov)

			IncProc()

			If Empty(aTmpMov[nLoop][2])
				aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0030})  // "      CE8_TIPOPE - Tipo de operación vacio"
				Loop
			EndIf

			If Empty(aTmpMov[nLoop][3]) .and. aTmpMov[nLoop][1]=='04'
				aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0031})// "      A2_CGC - R.F.C. Vacio"
				Loop
			EndIf

		    If !Empty(aTmpMov[nLoop][4])
				If !vldCaract(aTmpMov[nLoop][4], 1)
					aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0032})//  "      CE8_IDFISC - Contiene caracteres no permitidos"
					Loop
				EndIf
			EndIf

			If !Empty(aTmpMov[nLoop][5])
				If !vldCaract(aTmpMov[nLoop][5], 2)
					aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0033})//"      A2_NOME - Contiene caracteres no permitidos"
					Loop
				EndIf
			Else
				IF !Empty(aTmpMov[nLoop][5]) .and.	aTmpMov[nLoop][1] == '05'
					aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0034 })// "      A2_NOME - Nombre extranjero obligatorio para tipo tercero 05"
					Loop
				EndIf
			EndIf

			If !Empty(aTmpMov[nLoop][7])
				If !vldCaract(aTmpMov[nLoop][7], 3)
					aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0035})// "      A2_NASCIO - Contiene caracteres no permitidos"
					Loop
				EndIf
			EndIf

			IF Empty(aTmpMov[nLoop][6]) .and. aTmpMov[nLoop][1]=='05'
				aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0036})// "      CE8_PAIS - Pais obliagtorio para tipo tercero 05"
				Loop
			EndIf

			If cDiotVer == "1"
				IF Empty(aTmpMov[nLoop][7]) .and. !Empty(aTmpMov[nLoop][5]) .and. aTmpMov[nLoop][1]=='05'
					aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0039}) // "      YA_NASCIO - Nacionalidad obliagtoria Si hay nombre extranjero"
					Loop
				EndIf
			Else // 2025 en adelante
				If aTmpMov[nLoop][1] == "05" .And. aTmpMov[nLoop][6] == "ZZZ"
					If Empty(aTmpMov[nLoop][8])
						aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0041 })	// "      A2_LUGJURF - Lugar de jurisdicción fiscal obligatorio para tipo tercero 05"
						Loop
					ElseIf !vldCaract(aTmpMov[nLoop][8], 2)
						aAdd(aErrores,{aTmpMov[nLoop][19]+" "+aTmpMov[nLoop][20]+" "+aTmpMov[nLoop][21]+"-"+aTmpMov[nLoop][22]+ STR0042})	// "      A2_LUGJURF - Contiene caracteres no permitidos"
						Loop
					EndIf
				Else
					aTmpMov[nLoop][8] := ""
				EndIf
			EndIf

			// Datos del tercero declarado
			cLinea := AllTrim(aTmpMov[nLoop][1]) + "|" // 01 CE8_TIPTER
			cLinea += AllTrim(aTmpMov[nLoop][2]) + "|" // 02 CE8_TIPOPE
			cLinea += AllTrim(aTmpMov[nLoop][3]) + "|" // 03 CE8_RFC
			cLinea += AllTrim(aTmpMov[nLoop][4]) + "|" // 04 CE8_IDFISC
			cLinea += AllTrim(aTmpMov[nLoop][5]) + "|" // 05 A2_NOME
			cLinea += AllTrim(aTmpMov[nLoop][6]) + "|" // 06 CE8_PAIS

			If cDiotVer == "1"
				cLinea += AllTrim(aTmpMov[nLoop][7]) + "|" // 07 YA_NASCIO
			Else // 2025 en adelante
				cLinea += AllTrim(aTmpMov[nLoop][8]) + "|" // 07 A2_LUGJURF
			EndIf

			If cDiotVer == "1"
				cLinea += IIf(aTmpMov[nLoop][8] > 0, AllTrim(Str(Round(aTmpMov[nLoop][8],0))), '') + "|"	// 08 CE8_BA1516
				cLinea += IIf(aTmpMov[nLoop][9] > 0, AllTrim(Str(Round(aTmpMov[nLoop][9],0))), '') + "|"	// 09 CE8_BASE15
				cLinea += ""+"|" 																			// 10 No-Aplica
				cLinea += IIf(aTmpMov[nLoop][10] > 0, AllTrim(Str(Round(aTmpMov[nLoop][10],0))), '') + "|"	// 11 CE8_BA1110
				cLinea += IIf(aTmpMov[nLoop][11] > 0, AllTrim(Str(Round(aTmpMov[nLoop][11],0))), '') + "|"	// 12 CE8_BASE10
				cLinea += IIf(aTmpMov[nLoop][23] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23],0))), '') + "|"	// 13 CE8_BASE8
				cLinea += ""+"|" 																			// 14 No-Aplica
				cLinea += ""+"|" 																			// 15 No-Aplica (Opcional)
				cLinea += IIf(aTmpMov[nLoop][12] > 0, AllTrim(Str(Round(aTmpMov[nLoop][12],0))), '') + "|"	// 16 CE8_BI1516
				cLinea += ""+"|" 																			// 17 No-Aplica
				cLinea += IIf(aTmpMov[nLoop][13] > 0, AllTrim(Str(Round(aTmpMov[nLoop][13],0))), '') + "|"	// 18 CE8_BI1011
				cLinea += ""+"|" 																			// 19 No-Aplica
				cLinea += IIf(aTmpMov[nLoop][14] > 0, AllTrim(Str(Round(aTmpMov[nLoop][14],0))), '') + "|"	// 20 CE8_BASIEX
				cLinea += IIf(aTmpMov[nLoop][15] > 0, AllTrim(Str(Round(aTmpMov[nLoop][15],0))), '') + "|"	// 21 CE8_BASE0
				cLinea += IIf(aTmpMov[nLoop][16] > 0, AllTrim(Str(Round(aTmpMov[nLoop][16],0))), '') + "|"	// 22 CE8_BASEEX
				cLinea += IIf(aTmpMov[nLoop][17] > 0, AllTrim(Str(Round(aTmpMov[nLoop][17],0))), '') + "|"	// 23 CE8_IVARET
				cLinea += IIf(aTmpMov[nLoop][18] > 0, AllTrim(Str(Round(aTmpMov[nLoop][18],0))), '') + "|"	// 24 CE8_IVADEV
			Else // 2025 en adelante
				// Valor de los actos o actividades
				cLinea += IIf(aTmpMov[nLoop][23][01] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][01],0))), '') + "|"	// 08 CE8_BA1011 Pagos RFN
				cLinea += IIf(aTmpMov[nLoop][23][02] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][02],0))), '') + "|"	// 09 CE8_BASE8  Dev/Desc RFN
				cLinea += IIf(aTmpMov[nLoop][23][03] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][03],0))), '') + "|"	// 10 CE8_BASE10 Pagos RFS
				cLinea += IIf(aTmpMov[nLoop][23][04] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][04],0))), '') + "|"	// 11 CE8_BI1011 Dev/Desc RFS
				cLinea += IIf(aTmpMov[nLoop][23][05] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][05],0))), '') + "|"	// 12 CE8_BA1516 Pagos Interior
				cLinea += IIf(aTmpMov[nLoop][23][06] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][06],0))), '') + "|"	// 13 CE8_BI1516 Dev/Desc Interior
				cLinea += IIf(aTmpMov[nLoop][23][07] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][07],0))), '') + "|"	// 14 CE8_BASE15 Pagos Tangibles
				cLinea += IIf(aTmpMov[nLoop][23][08] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][08],0))), '') + "|"	// 15 CE8_BASDVA Dev/Desc Tangibles
				cLinea += IIf(aTmpMov[nLoop][23][09] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][09],0))), '') + "|"	// 16 CE8_BASDVB Pagos Intangibles
				cLinea += IIf(aTmpMov[nLoop][23][10] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][10],0))), '') + "|"	// 17 CE8_BASDVC Dev/Desc Intangibles

				// IVA acreditable
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][11] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][11],0))), '') + "|"	// 18 CE8_IVAACA IVA,Acred,No Prop,RFN
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][12] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][12],0))), '') + "|"	// 19 CE8_IVAACB IVA,Acred,Prop,RFN
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][13] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][13],0))), '') + "|"	// 20 CE8_IVAACC IVA,Acred,No Prop,RFS
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][14] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][14],0))), '') + "|"	// 21 CE8_IVAACD IVA,Acred,Prop,RFS
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][15] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][15],0))), '') + "|"	// 22 CE8_IVAACE IVA,Acred,No Prop,Interior
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][16] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][16],0))), '') + "|"	// 23 CE8_IVAACF IVA,Acred,Prop,Interior
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][17] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][17],0))), '') + "|"	// 24 CE8_IVAACG IVA,Acred,No Prop,Tangible
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][18] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][18],0))), '') + "|"	// 25 CE8_IVAACH IVA,Acred,Prop,Tangible
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][19] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][19],0))), '') + "|"	// 26 CE8_IVAACI IVA,Acred,No Prop,Intangible
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][20] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][20],0))), '') + "|"	// 27 CE8_IVAACJ IVA,Acred,Prop,Intangible

				// IVA no acreditable
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][21] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][21],0))), '') + "|"	// 28 CCE8_IVANAA IVA,No Acred,Prop,RFN
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][22] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][22],0))), '') + "|"	// 29 CCE8_IVANAB IVA,No Acred,No Prop,RFN ?????
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][23] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][23],0))), '') + "|"	// 30 CCE8_IVANAC IVA,No Acred,No Prop, Exento,RFN
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][24] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][24],0))), '') + "|"	// 31 CCE8_IVANAD IVA,No Acred,No Prop, No Objeto IVA,RFN
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][25] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][25],0))), '') + "|"	// 32 CCE8_IVANAE IVA,No Acred,Prop,RFS
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][26] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][26],0))), '') + "|"	// 33 CCE8_IVANAF IVA,No Acred,No Prop,RFS
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][27] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][27],0))), '') + "|"	// 34 CCE8_IVANAG IVA,No Acred,No Prop, Exento,RFS
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][28] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][28],0))), '') + "|"	// 35 CCE8_IVANAH IVA,No Acred,No Prop, No Objeto IVA,RFS
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][29] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][29],0))), '') + "|"	// 36 CCE8_IVANAI IVA,No Acred,Prop,Interior
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][30] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][30],0))), '') + "|"	// 37 CCE8_IVANAJ IVA,No Acred,No Prop,Interior
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][31] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][31],0))), '') + "|"	// 38 CCE8_IVANAK IVA,No Acred,No Prop, Exento,Interior
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][32] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][32],0))), '') + "|"	// 39 CCE8_IVANAL IVA,No Acred,No Prop, No Objeto IVA,Interior
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][33] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][33],0))), '') + "|"	// 40 CCE8_IVANAM IVA,No Acred,Prop,Tangibles
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][34] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][34],0))), '') + "|"	// 41 CCE8_IVANAN IVA,No Acred,No Prop,Tangibles
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][35] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][35],0))), '') + "|"	// 42 CCE8_IVANAO IVA,No Acred,No Prop, Exento,Tangibles
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][36] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][36],0))), '') + "|"	// 43 CCE8_IVANAP IVA,No Acred,No Prop, No Objeto IVA,Tangibles
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][37] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][37],0))), '') + "|"	// 44 CCE8_IVANAQ IVA,No Acred,Prop,Intangibles
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][38] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][38],0))), '') + "|"	// 45 CCE8_IVANAR IVA,No Acred,No Prop,Intangibles
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][39] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][39],0))), '') + "|"	// 46 CCE8_IVANAS IVA,No Acred,No Prop, Exento,Intangibles
				cLinea += IIf(cEnviar == "1" .And. aTmpMov[nLoop][23][40] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][40],0))), '') + "|"	// 47 CCE8_IVANAT IVA,No Acred,No Prop, No Objeto IVA,Intangibles

				// Datos adicionales
				cLinea += IIf(aTmpMov[nLoop][23][41] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][41],0))), '') + "|"	// 48 CE8_IVARET IVA Retenido
				cLinea += IIf(aTmpMov[nLoop][23][42] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][42],0))), '') + "|"	// 49 CE8_BASIEX Importación Exentos
				cLinea += IIf(aTmpMov[nLoop][23][43] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][43],0))), '') + "|"	// 50 CE8_BASEEX Nacional Exentos
				cLinea += IIf(aTmpMov[nLoop][23][44] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][44],0))), '') + "|"	// 51 CE8_BASE0  Tasa 0
				cLinea += IIf(aTmpMov[nLoop][23][45] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][45],0))), '') + "|"	// 52 CE8_VALTOT No Objeto de IVA, Nacional
				cLinea += IIf(aTmpMov[nLoop][23][46] > 0, AllTrim(Str(Round(aTmpMov[nLoop][23][46],0))), '') + "|"	// 53 CE8_IVADEV No Objeto de IVA, Extranjero
				cLinea += "01"	// 54
			Endif

			oFileWrite:Write(cLinea + CRLF)
	    Next nLoop
	EndIf

	oFileWrite:Close()
	FreeObj(oFileWrite)
	oFileWrite := Nil

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TodoOK    ºAutor  ³M.Camargo           º Data ³  21/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacion de los datos antes de Ejecutar el proceso        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³FISA087                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TodoOK(cPerg)

	Local nLoop := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros         ³
	//³ MV_PAR01 // Mes y Año del periodo a procesar ³
	//³ MV_PAR02 // Sucursales a procesar            ³
	//³ MV_PAR03 // Nombre del archivo               ³
	//³ MV_PAR04 // Ubicación del archivo            ³
	//³ MV_PAR05 // Datos a enviar                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte(cPerg, .F.)

	cMesAno := MV_PAR01
	cSucur  := Alltrim(MV_PAR02)
	cArchivo:= Alltrim(MV_PAR03)
	cRuta   := MV_PAR04
	cEnviar := cValToChar( IIf(FindFunction("fLeePreg"), fLeePreg(cPerg,5,1), MV_PAR05) )	// Dependencia manual de la rutina PERXTMP

	cMes	:= StrZero(Val(Left(CMESANO,2)),2)
	cAnio	:= Right(CMESANO,4)
	cLisSuc	:= AllTrim(cSucur)

	If Val(cMes) < 1 .Or. Val(cMes) > 12
		MsgInfo(STR0016) // "El mes debe ser de 1 a 12!"
		Return .F.
	EndIf

	If Empty(cMesAno)
		MsgInfo(STR0017) // "Debe indicar el Mes y Año!"
		Return .F.
	EndIf

	If Val(cAnio) < 1900
		MsgInfo(STR0018) // "El año debe ser mayor a 1900!"
		Return .F.
	EndIf

	If Empty(cArchivo)
		MsgInfo(STR0019) // "Debe indicar nombre del archivo!"
		Return .F.
	EndIf

	For nLoop := 1 To Len(cArchivo)
		If SubStr(cArchivo,nLoop,1) $"@/%/'/!/./$/&/¿/?/¡/Ñ/,/ /"
			MsgInfo(STR0020) // "El nombre del archivo contiene caracteres que no son validos!"
			Return .F.
		EndIf
	Next nLoop

	If Empty(cRuta)
		MsgInfo(STR0020) // "La Ruta esta vacia, verifique!"
		Return .F.
	EndIf

	If !ExistDir(cRuta)
		MsgInfo(STR0022) // "Atención" "La Ruta seleccionada no existe" "OK"
		Return .F.
	EndIf

	If Empty(cLisSuc)
	    MsgInfo(STR0038) // "Seleccione al menos una sucursal"
	    Return .F.
	EndIf

	dFecIni := CToD("01/"+ cmes+ "/" +Substr(cAnio,3,2)+"/")
	dFecFin := CToD(StrZero(f_UltDia(dFecIni),02)+ "/"+cMes+"/"+substr(cAnio,3,2))

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VldRuta   ºAutor  ³M.Camargo           º Data ³  21/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacion del path seleccionado para el grabado del archivoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generacion Archivo DIOT                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldRuta()

	Local lRet := .T.

	cPath := MV_PAR03

	If !ExistDir(cPath)
		Aviso(STR0009, STR0022, {STR0011}) // "Atención" "La Ruta seleccionada no existe" "OK"
		lRet := .F.
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³vldCaract ºAutor  ³M.Camargo           º Data ³  21/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacion y tratamiento de caracteres especiales.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generacion Archivo DIOT                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function vldCaract(cPalabra,nOpc)

	Local nLoop   := 0
	Local lRet    := .T.
	Local cCaract := IIf(nOpc == 1, "@/%/'/!/./$/&/¿/?/¡/Ñ", IIf(nOpc == 2, "@%'!$¿?¡", "'/&/Ñ"))

	For nLoop := 1 To Len(cPalabra)
		If SubStr(cPalabra, nLoop, 1) $ cCaract
			lRet := .F.
			Exit
		Endif
	Next nLoop

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImprimeLog  ³ Autor ³GSANTACRUZ          ³ Data ³ 21/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ejecuta rutina para Visualizar/Imprimir log del proceso.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISA087                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImprimeLog()

	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Local cTamanho	:= "M"
	Local cTitulo	:= STR0028 // "LOG  de DIOT"
	Local nX		:= 1
	Local aNewLog	:= {}
	Local nTamLog	:= 0
	Local aLogTitle	:= {}
	Local aLog		:= {}

	aAdd(aLog, STR0023 + AllTrim(Str(Len(aTmpMov)))) 					//"Registros procesados: "
	aAdd(aLog, STR0024 + AllTrim(Str(Len(aTmpMov) - Len(aErrores)))) 	//"Registros cargados: "
	aAdd(aLog, STR0025 + AllTrim(Str(Len(aErrores))))   				//"Registros con error: "
	aAdd(aLog, "")
	aAdd(aLog, "")
	aAdd(aLog, STR0026) // "Detalle de los registros con error:"
	aAdd(aLog, "")
	aAdd(aLog, STR0040) // "Prov/Tienda  Observación "

	For nX := 1 To Len(aErrores)
	    aAdd(aLog,aErrores[nX,1])
	Next nX

	aNewLog	:= aClone(aLog)
	nTamLog	:= Len(aLog)

	aLog := {}

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
	MsAguarde( { ||fMakeLog( aLog ,aLogTitle , , .T. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )},STR0029) // "Generando Log de errores..."

Return

/*/{Protheus.doc} RecalcIVA
	Recalcular IVA sobre base redondeada
	@type  Static Function
	@author ARodiguez
	@since 11/04/2025
	@version 12.1.2310
	@param nBase, numérica, Base del Impuesto
	@param nIVA, numérica, Valor de IVA
	@return Nil
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RecalcIVA(nBase, nIVA)
	Local nTasa	  := 0
	Local nRetIVA := 0

	Default nBase := 0
	Default nIVA := 0

	nRetIVA := nIVA

	If nBase <> 0
		If nIVA <> 0 .And. (nIVA - Int(nIVA)) >= .50
			nTasa   := Round(nIVA / nBase * 100, 0)
			nRetIVA := Round(nBase,0) * nTasa / 100
		EndIf
	EndIf

Return nRetIVA
