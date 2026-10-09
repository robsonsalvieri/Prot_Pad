#INCLUDE "Totvs.CH"
#INCLUDE "FISA846.CH"
#INCLUDE "FwLibVersion.ch"



/*/{Protheus.doc} FISA846
	Generación de TXT A122R-Emisiónccomprobante de retención.
	Imprime el cuadro de dialogo para configurar los parámetros utilizados en la generación del archivo.
	@type 		Function
	@author 	Alfredo Medrano
	@version	12.1.2410 / Superior
	@since		24/10/2025 
	@example    FISA846()
	@see (links_or_references)
/*/

Function FISA846()
Local aArea		    := getArea()
Local oFld		    := Nil
Local oDialog       := Nil

	DEFINE MSDIALOG oDialog TITLE STR0001 FROM 0,0 TO 250,450 OF oDialog PIXEL //"A122R-Emisión de Comprobante de Retención"

	@ 020,006 FOLDER oFld OF oDialog PROMPT STR0002 PIXEL SIZE 165,075 	//"Exportacion de TXT"

	@ 005,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] // "Esta rutina permite a los Agentes de Retención de "
	@ 015,005 SAY STR0004 SIZE 150,008 PIXEL OF oFld:aDialogs[1] // "Impuestos sobre los IIB, generar un archivo TXT "
	@ 025,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] // "de los comprobantes de retención."
	@ 045,005 SAY STR0006 SIZE 150,008 PIXEL OF oFld:aDialogs[1] // "A122R-Emisión comprobante de retención"
	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,178 BUTTON STR0007 SIZE 036,016 PIXEL ACTION RunProc() 	    //"&Exportar"
	@ 075,178 BUTTON STR0008 SIZE 036,016 PIXEL ACTION oDialog:End() 	//"&Salir"
	ACTIVATE MSDIALOG oDialog CENTER

	Restarea(aArea)
Return

/*/{Protheus.doc} RunProc
	Obtiene los parametros y procesa la información para la generción del archivo.
	@type  Static Function
	@author alfredo.medrano
	@since 24/10/2025
	@version 1
	@return Nil
	@example RunProc()
	@see (links_or_references)
/*/
Static Function RunProc()
Local aSucsCalc     := {}

	If Pergunte("FISA846",.T.)
		If ValidParam()
			If MV_PAR05 == 1 //selecciona sucursal Si
				aSucsCalc := SeleclFils() //Selección de sucursales
            ElseIf MV_PAR05 == 2 //selecciona sucursal No
                aadd(aSucsCalc,{.T.,cFilAnt})  // Toma la sucursal en curso
            EndIf

			If Len(aSucsCalc) > 0
				Processa( {|| ProcIIB(aSucsCalc)}, STR0011,STR0012, .T. ) // Atención // Generando información...
				MSGINFO(STR0014) //Proceso finalizado.
			EndIf
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} ProcIIB
	Procesa la información para generar el archivo TXT A122R-Emisiónccomprobante de retención.
	@type  Static Function
	@author alfredo.medrano
	@since 30/10/2025
	@version 1
	@version 12.1.2410
	@param aSucsCalc	- array con las sucursales
	@return Nil
	@example GetRetIIB(@Array, string)
	@see (links_or_references)
/*/
Static function ProcIIB(aSucsCalc)
Local aDatos        := {}
Local aDatosA       := {}
Local cFileNameTxt 	:= ""
Local cSucursal     := ""
Local nSuc	        := 0
Local cCGC          := ""
Local nI            := 0
Local nPoSCuit      := 0
Local cRuta         := ""
Local cFilArq		:= ""
Local nMultSuc		:= 1
Local cExten        := ""
Local cDummyDrive   := ""
Local cDummyDir     := ""

Default aSucsCalc 	:= {}

	cRuta           := RTRIM(MV_PAR03)
    nMultSuc		:= MV_PAR05
	SplitPath(RTRIM(Upper(MV_PAR04)), @cDummyDrive, @cDummyDir, @cFileNameTxt, @cExten)

	cFileNameTxt += IIF(Lower(cExten) == ".txt", cExten, ".txt")

	If MV_PAR05 == 1 .and. MV_PAR06 == 1  //Agrupa sucursales
		aDatosA := {}
		For nSuc := 1 To Len(aSucsCalc)
			If (aSucsCalc[nSuc,1])
				aDatos := {}
				cCGC := RIGHT(AllTrim(aSucsCalc[nSuc,4]),11)
				cSucursal := aSucsCalc[nSuc,2]
				nPoSCuit := aScan(aDatosA,{|x| Substr(x[1][2],1,11) $ cCGC })  //Busca cuit para agrupar
				If nPoSCuit == 0								
					Aadd(aDatos,{ cSucursal, Alltrim(cCGC),"NOT","","","" })  // primer registro de array aDatos con info de la sucursal
				EndIf
				GetRetIIB(@aDatos,cSucursal)
				If Len(aDatos) > 1
					If nPoSCuit == 0
						Aadd(aDatosA, aDatos)
					Else
						AEval( aDatos,  { | x | AAdd( aDatosA[nPoSCuit], x ) } )
					EndIf
				EndIF
			EndIf
		Next
		For nI := 1 To Len(aDatosA)
			 aSort(aDatosA[nI],,,{|x,y| x[1]< y[1]}) // ordena por número de certificado de forma ascendente
			 genFileIIB(aDatosA[nI], cRuta + Substr(aDatosA[nI][1][2],1,11)  + "_" + cFileNameTxt)
		Next
	Else
		For nSuc := 1 To Len(aSucsCalc)
			If (aSucsCalc[nSuc,1])
				aDatos := {}
				cSucursal := aSucsCalc[nSuc,2]
				Aadd(aDatos,{ cSucursal, "","NOT","","","" })  // primer registro de array aDatos con info de la sucursal
				GetRetIIB(@aDatos,cSucursal)
				If nMultSuc == 1
					cFilArq := cSucursal + "_"
				Else	
					cFilArq := ""
				EndIf
				If Len(aDatos) > 1
					genFileIIB(aDatos,cRuta + cFilArq + cFileNameTxt)
				EndIf
			EndIf
		Next
	EndIf
Return .T.


/*/{Protheus.doc} ValidParam
	Valida los parámetros generados por el grupo de preguntas FISA846.
	Todos los parámetros con obligatorios.
	@type  Static Function
	@author alfredo.medrano
	@since 24/10/2025
	@version 1
	@return Nil
	@example ValidParam()
	@see (links_or_references)
/*/
Static Function ValidParam()
	Local lRet:=  .T.
	Local cErr := ""

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03) .Or. Empty(MV_PAR04) .Or. Empty(MV_PAR05) .Or. Empty(MV_PAR06) .Or. Empty(MV_PAR07)
		cErr += STR0009 + " " //"Complete todos los parámetros solicitados"
		lRet := .F.
	EndIf
	If Alltrim(Str(YEAR(MV_PAR01)))+Alltrim(Str(MONTH(MV_PAR01))) != Alltrim(Str(YEAR(MV_PAR02)))+Alltrim(Str(MONTH(MV_PAR02)))
		cErr += STR0010 + " " //"El rango de fechas debe pertenecer al mismo periodo."
		lRet := .F.
	EndIf
	If !Empty(MV_PAR03)
		 If !ExistDir(MV_PAR03)
		 	lRet := .F.
			cErr += STR0023 + " " //"El directorio no existe o está informado de forma incorrecta."
		 EndIf
	EndIf
	If lRet == .F.
		MSgAlert(cErr)
	EndIf

Return lRet

/*/{Protheus.doc} GetRetIIB
	Obtiene las reneciones de ingresos brutos IIB.
	@type  Static Function
	@author alfredo.medrano
	@since 27/10/2025
	@version 1
	@version 12.1.2410
	@param aData		- array con las retenciones (valor por referencia) 
	@param cSucursal	- Sucursal a procesar.
	@return Nil
	@example GetRetIIB(@Array, string)
	@see (links_or_references)
/*/
Static function GetRetIIB(aData, cSucursal)

Local aArea		:= getArea()
Local cAliasRet := GetNextAlias()
Local nPosReg	:= 0
Local nRegs		:= 0
Local cCuit		:= ""
Local cNoCert	:= ""
Local cQuery    := ""
Local cFilSFE   := ""
Local cFilSA2   :=""
Local dFechaIn  := DTOS(MV_PAR01)
Local dFechaFn  := DTOS(MV_PAR02)
Local cPuntoV   := MV_PAR07 
Local nTamDate	:= FWSX3Util():GetFieldStruct("FE_EMISSAO")[3]
Local oExecImp  := Nil
Local lTabComp  := VldModAcc() //Valida la comparticion de la tabla SFE.

Default aData := {}
Default cSucursal := ""

	If !Empty(cSucursal)
		cFilSA2 := xFilial('SA2', cSucursal)
		cQuery := " SELECT SA2.A2_CGC, SFE.FE_ORDPAGO, SFE.FE_NROCERT, SFE.FE_NRETORI, SFE.FE_EMISSAO, 
		cQuery += " SUM(SFE.FE_VALBASE) AS BASE, SFE.FE_ALIQ "
		cQuery += " FROM " + RetSqlName("SFE") + " SFE" 
		cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 "
		cQuery += "   ON SA2.A2_COD = SFE.FE_FORNECE AND SA2.A2_LOJA  = SFE.FE_LOJA "
		cQuery += "   AND SA2.A2_FILIAL = ? "	
		cQuery += "   AND SA2.D_E_L_E_T_ = ? "
		cQuery += " WHERE SFE.FE_EST = ? "
		cQuery += "   AND SFE.FE_TIPO = ? "
		cQuery += "   AND SFE.FE_FORNECE <> ? "
		cQuery += "   AND SFE.FE_EMISSAO >= ? "
		cQuery += "   AND SFE.FE_EMISSAO <= ? "
		cQuery += "   AND (SFE.FE_DTESTOR < ? " 
		cQuery += "   OR  SFE.FE_DTESTOR > ? "
		cQuery += "   OR  SFE.FE_DTESTOR = ? "
		cQuery += "   OR  SFE.FE_NRETORI <> ? ) "       
		cQuery += "   AND (SFE.FE_DTRETOR < ? " 
		cQuery += "   OR  SFE.FE_DTRETOR > ? "
		cQuery += "   OR  SFE.FE_DTRETOR = ? "
		cQuery += "   OR  SFE.FE_NRETORI = ? )"
		If lTabComp //Valida la comparticion de la tabla SFE.
			cQuery += " AND SFE.FE_MSFIL = ? " 
			cFilSFE := cSucursal
		Else
			cQuery += " AND SFE.FE_FILIAL = ?"
			cFilSFE := xFilial("SFE",cSucursal)  
		EndIf
		cQuery += "   AND SFE.D_E_L_E_T_ = ? "
		cQuery += "GROUP BY SA2.A2_CGC, SFE.FE_ORDPAGO, SFE.FE_NROCERT, SFE.FE_EMISSAO, SFE.FE_ALIQ, SFE.FE_NRETORI "

		cQuery := ChangeQuery(cQuery)
		oExecImp := FwExecStatement():New( cQuery )

		oExecImp:SetString( 01, cFilSA2 )      //A2_FILIAL =
		oExecImp:SetString( 02, ' ' )             //SA2.D_E_L_E_T_ =
		oExecImp:SetString( 03, "BA" )            //SFE.FE_EST = 
		oExecImp:SetString( 04, 'B' )             //SFE.FE_TIPO =
		oExecImp:SetString( 05, ' ' )             //SFE.FE_FORNECE <>
		oExecImp:SetString( 06, dFechaIn )        //SFE.FE_EMISSAO >
		oExecImp:SetString( 07, dFechaFn )        //SFE.FE_EMISSAO <
		oExecImp:SetString( 08, dFechaIn )        //SFE.FE_DTESTOR <
		oExecImp:SetString( 09, dFechaFn)         //SFE.FE_DTESTOR >
		oExecImp:SetString( 10, ' ' )             //SFE.FE_DTESTOR =
		oExecImp:SetString( 11, ' ' )             //SFE.FE_NRETORI <>
		oExecImp:SetString( 12, dFechaIn )        //SFE.FE_DTRETOR <
		oExecImp:SetString( 13, dFechaFn)         //SFE.FE_DTRETOR >
		oExecImp:SetString( 14, ' ' )             //SFE.FE_DTRETOR =
		oExecImp:SetString( 15, ' ' )             //SFE.FE_NRETORI =
		oExecImp:SetString( 16, cFilSFE )         //SFE.FE_MSFIL / SFE.FE_FILIAL 
		oExecImp:SetString( 17, ' ' )             //SFE.D_E_L_E_T_ 
		
		cQuery := oExecImp:getFixQuery()
		cAliasRet := oExecImp:OpenAlias()

		TCSetField(cAliasRet, "FE_EMISSAO", "D", nTamDate, 0)
		Count To nRegs
		ProcRegua(nRegs)

		dbSelectArea(cAliasRet)
		(cAliasRet)->(DbGoTop())
		While (cAliasRet )->(!Eof())
			nRegs++
			IncProc(STR0013 + cSucursal + " " + Alltrim(str(nRegs))) // "Procesando registros "
			
			If AllTrim((cAliasRet)->FE_NROCERT) == 'NORET' .OR. (cAliasRet)->BASE <= 0
				(cAliasRet)->(dbSkip())
				Loop
			EndIf

			cCuit 	:= STRZERO(Val((cAliasRet)->A2_CGC),11,0)
			cNoCert := STRZERO(Val((cAliasRet)->FE_NROCERT),20,0)
			nPosReg := aScan(aData,{|x| x[1] == cNoCert .and. x[2] == cCuit})

			If nPosReg == 0
				AADD(aData,;
					{cNoCert,;							//Certificado
					cCuit,; 							//Cuit del proveedor 
					PADL(Alltrim(cPuntoV), 5 , '0'),; 	//punto de venta // Sucursal
					DTOC((cAliasRet)->FE_EMISSAO),;		//Fecha operación
					PADL(Alltrim(TRANSFORM((cAliasRet)->FE_ALIQ,  "@! 99.99")), 5, '0'),;			//Alicuota
					PADL(Alltrim(TRANSFORM((cAliasRet)->BASE,  "@! 9999999999999.99")), 16, '0')})	//Base Imponible
			EndIf

			(cAliasRet)->(dbskip())
		EndDo
		(cAliasRet)-> (dbCloseArea())
	Endif
		
	RestArea(aArea)

Return

/*/{Protheus.doc} genFileIIB
	Crea el archivo de texto con las retenciones IIB
	@type  Static Function
	@author alfredo.medrano
	@since 28/10/2025
	@version 1
	@version 12.1.2410
	@param aArq			- array con las retenciones IIB
	@param cFileName	- Ruta y nombre del archivo.
	@return .T.
	@example GetRetIIB(@Array, string)
	@see (links_or_references)
/*/
Static Function genFileIIB(aArq,cFileName)
	Local cLinea		:= ""
	Local nI			:= 0
	Local nJ			:= 0
	Local nNumArq		:= 0
	Local nLimit		:= 4096
	Local oFileWrite	:= Nil
	Default aArq		:= {}
	Default cFileName	:= ""

	nNumArq := Len(aArq)
	If nNumArq > 0
		oFileWrite := FWFileWriter():New(cFileName, .T., nLimit)
		oFileWrite:SetCaseSensitive(.T.)
        If oFileWrite:Exists()
			oFileWrite:Close()
			oFileWrite:Erase()
		EndIf
		oFileWrite:Create()
		If !(oFileWrite:Error():Cod == Nil)
	        FWAlertInfo(cValToChar(oFileWrite:Error():Message))
		Else
			ProcRegua(nNumArq)
			For nI := 1 To nNumArq 
				IncProc(STR0021 + aArq[nI,1] ) // "Creando archivo "
				IF aArq[nI,3] != "NOT" //posicion contiene info de sucursal se excluye
					For nJ := 1 to Len(aArq[nI]) 
						cLinea	+= aArq[nI,nJ]
					Next nJ
					oFileWrite:Write(cLinea + CRLF)
					cLinea:= ""
				EndIf
			Next nI
			oFileWrite:Close()
			If FISA846Zip(cFileName)
				oFileWrite:Erase()
			EndIf
		EndIf
		FreeObj(oFileWrite)
		oFileWrite := Nil
	EndIf

Return .T.

/*/{Protheus.doc} SeleclFils
	Crea una pantalla con las filiales.
	@type  Static Function
	@author alfredo.medrano
	@since 30/10/2025
	@version 1
	@version 12.1.2410
	@example SeleclFils()
	@see (links_or_references)
/*/
Static Function SeleclFils()
Local aArea	:= GetArea()
Local aFilsCalc	:= {}
Local oChkQual	:= Nil
Local oQual 	:= Nil
Local oDlg	    := Nil
Local oOk		:= LoadBitmap(GetResources(),"LBOK")
Local oNo   	:= LoadBitmap(GetResources(),"LBNO")
Local cVarQ 	:= ""
Local lQual 	:= .F.
Local aSM0      := FWLoadSM0(.T.,,.T.)
Local aFilSelec	:= {}
Local nOpca		:= 0


//-- Carrega filiais da empresa corrente
	aEval(aSM0,{|x| If(x[SM0_GRPEMP] == cEmpAnt .And. x[SM0_EMPRESA] == FWCompany() .And. x[SM0_USEROK] .And. x[SM0_EMPOK],;
		 aAdd(aFilsCalc,{.F.,x[SM0_CODFIL],x[SM0_NOMRED],x[SM0_CGC]}), NIL )})

//-- Monta tela para selecao de filiais
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0015) STYLE DS_MODALFRAME From 145,0 To 445,628 OF oMainWnd PIXEL //Seleccion de Sucursal
	oDlg:lEscClose := .F.
	@ 05,15 TO 125,300 LABEL OemToAnsi(STR0016) OF oDlg  PIXEL //"Marque las Sucursales que serán consideradas en el procesamiento"
	@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT OemToAnsi(STR0017) SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(aFilsCalc, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.)) // "Invierte selección"
	@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0018),OemToAnsi(STR0019),OemToAnsi(STR0020) SIZE 273,090 ON DBLCLICK (aFilsCalc:=InvtSelec(oQual:nAt,aFilsCalc),oQual:Refresh()) NoScroll OF oDlg PIXEL //Sucursal // Descripción // CUIT
	bLine := {|| {If(aFilsCalc[oQual:nAt,1],oOk,oNo),aFilsCalc[oQual:nAt,2],aFilsCalc[oQual:nAt,3],Transform(aFilsCalc[oQual:nAt,4],"@R 99-99999999-9")}}
	oQual:SetArray(aFilsCalc)
	oQual:bLine := bLine
	DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION (nOpca := 1, IIF(ValFilCal(aFilsCalc), oDlg:End(),nOpca := 0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION (nOpca := 0, oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1
		aEval(aFilsCalc, {|e| If(e[1], aadd(aFilSelec,{e[1], e[2], e[3], e[4]} ),)}) // asigna al array aFilSelec solo las sucursales seleccionadas
	EndIf
	aFilsCalc := aClone(aFilSelec)
	aFilsCalc := aSort(aFilsCalc,,,{|x,y| x[4]>y[4]}) // ordena por CUIT de agente que declara
	RestArea(aArea)
Return aFilsCalc

/*/{Protheus.doc} ValFilCal
	Valida la selección de las sucursales.
	@type  Static Function
	@author alfredo.medrano
	@since 30/10/2025
	@version 1
	@version 12.1.2410
	@param aFilsCalc	- array con las filiales
	@example ValFilCal(@Array)
	@see (links_or_references)
/*/
Static function ValFilCal(aFilsCalc)
Local lRet 	:= .T.
Local nCSel	:= 0
Default aFilsCalc := {}	

	If Len(aFilsCalc) > 0
		aEval(aFilsCalc, {|e| If(e[1], nCSel++,)})
		If nCSel == 0 // Filiales seleccionadas
			MSGINFO(STR0022) // "No se seleccionarón sucursales." 
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} InvtSelec
	Cambia el estado del checkbox al seleccionar la filial.
	@type  Static Function
	@author alfredo.medrano
	@since 30/10/2025
	@version 1
	@version 12.1.2410
	@param nIt			- posición de la filial selecionada
	@param aArray		- array con las filiales
	@example InvtSelec(int, Array)
	@see (links_or_references)
/*/
Static Function InvtSelec(nIt,aArray)
Default nIt 	:= 0
Default aArray	:= {}
	If nIt > 0 .and. Len(aArray) > 0
		aArray[nIt,1] := !aArray[nIt,1]
	EndIf
Return aArray

/*/{Protheus.doc} VldModAcc
	Valida si esxiste comparticion de tablas (SFE y SA2)
	@type  Static Function
	@author alfredo.medrano
	@since 30/10/2025
	@version 1
	@version 12.1.2410
	@example VldModAcc()
	@see (links_or_references)
/*/
Static Function VldModAcc()
	Local lRet := .F.
	If FwModeAccess("SFE",1) + FwModeAccess("SFE",2) + FwModeAccess("SFE",3) == "CCC" .AND.;
		FwModeAccess("SA2",1) + FwModeAccess("SA2",2) + FwModeAccess("SA2",3) == "CCC"
		If SFE->(ColumnPos("FE_MSFIL")) > 0
			lRet := .T.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} FISA846Zip
	Comprime el archivo indicado en la ruta donde se encuentra
	@type  Static Function
	@author oswaldo.diego
	@since 17/04/2026
	@version 1
	@version 12.1.2510
	@param cFile - String, Nombre del archivo a comprimir, incluyendo ruta
	@return nRet == 0 - Boolean, Si nRet es 0 (compresión exitosa) se retornará .T., .F. en caso contrario
	@example FISA846Zip(cFile)
/*/
Static Function FISA846Zip(cFile)
	Local nRet     := 0
	Local cZipName := ""
	Local aArch    := {}

	Default cFile := ""

	If !Empty(cFile)
		aArch := {cFile}
		cZipName := Left(cFile, RAT(".", cFile) - 1) + ".zip"
		nRet := FZip(cZipName, aArch, Left(cFile, RAT("\", cFile)),,.F.)
		If nRet != 0
			MSgAlert(STR0024) //Ocurrió un error durante la compresión del archivo.
		EndIf
	EndIF

Return nRet == 0
