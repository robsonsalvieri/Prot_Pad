#INCLUDE "Totvs.CH"
#INCLUDE "FISA841.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ±±
±±Program   | FISA841  | Autor |Luis Gerardo Mata   ±± Data31.08.2023    ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±Descripcion  ±± Percepciones | Retenciones de Misiones                 ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±Retorno   ±±  Ninguno                                                  ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±Parametrosï±± Ninguno                                                  ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±Fecha   ±± Programador   ±±Manutencao Efetuada                         ±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±        ±±               ±±                                            ±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ±±
/*/
Function FISA841()
	Local aArea		:= getArea()
	Local oFld		:= Nil
	Local oDialog := Nil
	Local lAutomato := IsBlind()

	If !lAutomato
		DEFINE MSDIALOG oDialog TITLE STR0001 FROM 0,0 TO 250,450 OF oDialog PIXEL //"Percepciones y Retenciones Misiones"

		@ 020,006 FOLDER oFld OF oDialog PROMPT STR0002 PIXEL SIZE 165,075 	//"Exportacion de TXT"

		@ 005,005 SAY STR0003 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta rutina realiza la exportacion de un TXT con las "
		@ 015,005 SAY STR0004 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"percepciones y retenciones de impuestos "
		@ 025,005 SAY STR0005 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"para la provincia de Misiones."
		//+-------------------
		//| Boton de MSDialog
		//+-------------------
		@ 055,178 BUTTON STR0006 SIZE 036,016 PIXEL ACTION RunProc() 	//"&Exportar"
		@ 075,178 BUTTON STR0007 SIZE 036,016 PIXEL ACTION oDialog:End() 		//"&Salir"
		ACTIVATE MSDIALOG oDialog CENTER
	Else 
		RunProc()
	EndIf 
	Restarea(aArea)
Return

/*/{Protheus.doc} RunProc()
	Función estatica para la construccion del aplicativo
	@type Static Function
	@author luis.mata
	@since 11/09/2023
	@version version 1
	@return  valor lógica que retorna .T. si el proceso fue exitoso. 
	@example
		RunProc()
/*/
Static Function RunProc()
	Local aDatos		:= {}
	Local aDatosA := {}
	Local aDatosR		:= {}
	Local aDatosRe := {}
	Local aSucsCalc := {}
	Local cSucursal := ""
	Local nSucus:= 0
	Local nI := 0
	Local lAutomato := IsBlind()

	If lAutomato
		lProc := .T.
	Else
		lProc := Pergunte("FISA841",.T.)
	EndIf
	If lProc
		If ValidParam()
			If MV_PAR04 == 1 // Selecciona Sucursales
				aSucsCalc := MatFilLCal(!lAutomato,,,,)
				If MV_PAR05 == 1 //Agrupa sucursales
					aDatosA := {}
					aDatosRe := {}
					For nI := 1 To Len(aSucsCalc)
						If (aSucsCalc[nI,1])
							aDatos := {}
							aDatosR := {}
							Processa( {|| GenArqPer(@aDatos,aSucsCalc[nI][2])}, STR0011,STR0009, .T. ) //"Atención" "Procesando registros"
							Aadd(aDatosA, aDatos)
							Processa( {|| GenArqRet(@aDatosR,aSucsCalc[nI][2])}, STR0011,STR0009, .T. ) //"Atención" "Procesando registros"
							Aadd(aDatosRe, aDatosR)
						EndIf
					Next
					Processa( {|| genFile(.T.,aDatosA,AllTrim(MV_PAR03)+"\"+STR0021+cSucursal+".txt")} , STR0011,STR0010, .T. ) //"Atención" "Seleccionando registros..."
					Processa( {|| genFile(.T.,aDatosRe,AllTrim(MV_PAR03)+"\"+STR0020+cSucursal+".txt")} , STR0011,STR0010, .T. ) //"Atención" "Seleccionando registros..."
				ElseIf MV_PAR05 == 2 //No agrupa sucursales
					For nSucus := 1 To Len(aSucsCalc)
						If (aSucsCalc[nSucus,1])
							cSucursal := aSucsCalc[nSucus,2]
							aDatos := {}
							aDatosR := {}
							Processa( {|| GenArqPer(@aDatos,cSucursal)}, STR0011,STR0009, .T. ) //"Atención" "Procesando registros"
							Processa( {|| genFile(.F.,aDatos,AllTrim(MV_PAR03)+"\"+STR0021+cSucursal+".txt")}	, STR0011,STR0010, .T. ) //"Atención" "Seleccionando registros..."
							Processa( {|| GenArqRet(@aDatosR,cSucursal)}, STR0011,STR0009, .T. ) //"Atención" "Procesando registros"
							Processa( {|| genFile(.F.,aDatosR,AllTrim(MV_PAR03)+"\"+STR0020+cSucursal+".txt")}	, STR0011,STR0010, .T. ) //"Atención" "Seleccionando registros..."
						EndIf
					Next
				EndIf
			Else //Toma la sucursal en curso
				aDatos := {}
				aDatosR := {}
					Processa( {|| GenArqPer(@aDatos,cFilAnt)}, STR0011,STR0009, .T. ) //"Atención" "Procesando registros"
					Processa( {|| genFile(.F.,aDatos,AllTrim(MV_PAR03)+"\"+STR0021+cFilAnt+".txt")}	, STR0011,STR0010, .T. ) //"Atención" Seleccionando registros...
					Processa( {|| GenArqRet(@aDatosR,cFilAnt)}, STR0011,STR0009, .T. ) //"Atención" "Procesando registros"
					Processa( {|| genFile(.F.,aDatosR,AllTrim(MV_PAR03)+"\"+STR0020+cFilAnt+".txt")}, STR0011,STR0010, .T. ) //"Atención" Seleccionando registros...
			EndIf
			MSGINFO(STR0012) // "Procedimiento finalizado."
		EndIf
	EndIf
Return .T.


/*/{Protheus.doc} ValidParam()
	Función estatica para validar Los parametros de iniciales
	@type Static Function
	@author luis.mata
	@since 11/09/2023
	@version version 1
	@return  lRet, variable lógica que retorna .T. si el proceso fue exitoso. 
	@example
		ValidParam()
/*/
Static Function ValidParam()
	Local lRet:=  .T.
	Local cErr := ""
	If Alltrim(Str(YEAR(MV_PAR01)))+Alltrim(Str(MONTH(MV_PAR01))) != Alltrim(Str(YEAR(MV_PAR02)))+Alltrim(Str(MONTH(MV_PAR02)))
		cErr += STR0013 + " " //"El rango de fechas debe pertenecer al mismo periodo."
		lRet := .F.
	EndIf
	If lRet == .F.
		Help(,,1,cErr)
	EndIf
Return lRet


/*/{Protheus.doc} GenArqPer(aDatos, cSucursal))
	Función estatica para que realiza el proceso para obtener los registrso de percepciones Misiones
	@type Static Function
	@author luis.mata
	@since 11/09/2023
	@version version 1
	@param aDatos, Arreglo, Array en donde seran almacenados los datos antes de generar el txt.
	@param cSucursal, caracter, Sucursal a considerar en la generación de txt   
	@return 
	@example
		GenArqPer(@aDatos,cFilAnt)
/*/
Static Function GenArqPer(aDatos, cSucursal)
	Local cCpo := ""
	Default aDatos := {}
	Default cSucursal := ""

	cCpo	:=  GetCpoLib(cSucursal) //Obtiene el cpo del impuesto IBC
	If cCpo != ""
		PerSF3(1,@aDatos,cCpo,cSucursal) //1.-Percepciones Clientes
		PerSF3(2,@aDatos,cCpo,cSucursal) //1.-Percepciones Proveedores
	EndIf

Return

/*/{Protheus.doc} GenArqRet(aDatosR, cSucursal))
	Función estatica para que realiza el proceso para obtener los registrso de retenciones Misiones.
	@type Static Function
	@author luis.mata
	@since 11/09/2023
	@version version 1
	@param aDatosR, Arreglo, Array en donde seran almacenados los datos antes de generar el txt.
	@param cSucursal, caracter, Sucursal a considerar en la generación de txt   
	@return 
	@example
		GenArqRet(@aDatosR,cFilAnt)
/*/
Static Function GenArqRet(aDatosR, cSucursal)
	Default aDatosR := {}
	Default cSucursal := ""

	RetSFE(1,@aDatosR,cSucursal) //Retenciones Proveedor Efectuadas

Return

//+----------------------------------------------------------------------+
//|Obtiene el campo del cual se obtendra el importe de las percepciones	 |
//+----------------------------------------------------------------------+
/*/{Protheus.doc} GetCpoLib(aDatosR, cSucursal))
	Función estatica para que realiza la obtención del campo Libro del cual se obtendra el importe de las percepciones	
	@type Static Function
	@author luis.mata
	@since 11/09/2023
	@version version 1
	@param cSucursal, caracter, Sucursal a considerar en la generación de txt   
	@return cCpo, caracter, Numero del campo libro que le corresonde tabla SFB
	@example
		GenArqRet(@aDatosR,cFilAnt)
/*/
Static Function GetCpoLib(cSucursal)
	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTmp		:= "tempIBC"
	Local cCpo		:= ""
	Default cSucursal := ""

	cQuery	:= 	"SELECT "
	cQuery	+=	"FB_CPOLVRO "
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName("SFB") + " SFB "
	cQuery	+=	"WHERE "
	cQuery 	+=  "FB_ESTADO ='MI' AND "
	cQuery	+=	"FB_FILIAL = '"+ xFilial("SFB",cSucursal)+"' AND "
	cQuery	+=	"FB_CLASSIF = '1' AND "
	cQuery	+=	"FB_CLASSE = 'P' AND "
	cQuery	+=	"D_E_L_E_T_= ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	(cTmp)-> (dbgotop())
	While (cTmp)-> (!Eof())
		cCpo := (cTmp)->FB_CPOLVRO
		(cTmp)->(dbskip())
	EndDo
	(cTmp)->(dbCloseArea())
	RestArea(aArea)
Return cCpo


/*/{Protheus.doc} genFile(lAgrup, aArq,cFileName)
	Función estatica para que Genera el archivo de texto. 
	@type Static Function
	@author luis.mata
	@since 11/09/2023
	@version version 1
	@param lAgrupa, logico, variable que indica si los archivos seran agrupados por sucursal. 
	@param aArq, areglo, Array con los datos a registrar en el archivo de Texto.
	@param cFileName, caracter, Nombre del archivo que sera asignado al generar el txt.	 
	@return  variable lógica que retorna .T. si el proceso fue exitoso. 
	@example
		GenArqRet(.T.,aDatosRe,AllTrim(MV_PAR03)+"\"+STR0020+cSucursal+".txt")
/*/
Static Function genFile(lAgrup, aArq,cFileName)
	Local cLinea	:= ""
	Local nI		:= 0
	Local nJ		:= 0
	Local nK		:= 0
	Local nArqLog	:= 0
	
	Default lAgrup := .T.
	Default aArq := {}
	Default cFileName := ""

	if Len(aArq) > 0
		If File(cFileName)
			FErase(cFileName)
		EndIf
		nArqLog	:= MSfCreate(cFileName, 0)
		ProcRegua(Len(aArq))
		For nI:=1 To Len(aArq)
			IncProc(STR0009  + str(nI)) //"Procesando registros"
			If lAgrup
				For nJ:= 1 to Len(aArq[nI])
					For nK:= 1 to Len(aArq[nI,nJ])
						cLinea	+= aArq[nI,nJ,nK]
					Next nK
					FWrite(nArqLog,cLinea+Chr(13)+Chr(10))
					cLinea:= ""
				Next nJ
			Else
				For nJ:= 1 to Len(aArq[nI])
					cLinea	+= aArq[nI,nJ]
				Next nJ
				FWrite(nArqLog,cLinea+Chr(13)+Chr(10))
				cLinea:= ""
			EndIf
		Next nI
		FClose(nArqLog)
	EndIf

Return .T.

//+---------------------------------------------------------------------+
//|Muestra la pantalla de seleccion de sucursales						|
//+---------------------------------------------------------------------+

Static Function MatFilLCal(lMostratela,aListaFil,lChkUser,nOpca,nValida,lContEmp)
	Local aFilsCalc	:= {}
	Local oChkQual,lQual,oQual,cVarQ
	Local oOk       := LoadBitmap(GetResources(),"LBOK")
	Local oNo       := LoadBitmap(GetResources(),"LBNO")
	Local lIsBlind  := IsBlind()
	Local oDlg	:= Nil

	Local aAreaSM0	:= SM0->(GetArea())
	Local aSM0      := FWLoadSM0(.T.,,.T.)

	Default nValida	:= 0 //0=Legado Seleção Livre
	Default lMostraTela	:= .F.
	Default aListaFil	:= {{.T., cFilAnt}}
	Default lchkUser	:= .T.
	Default lContEmp 	:= .F.
	Default nOpca		:= 1

	lChkUser := !GetAPOInfo("FWFILIAL.PRW")[4] < CTOD("10/01/2013")

	aEval(aSM0,{|x| If(x[SM0_GRPEMP] == cEmpAnt .And.;
		Iif (!lContEmp ,x[SM0_EMPRESA] == FWCompany(),.T.) .And.;
		(!lChkUser .Or. x[SM0_USEROK].Or. lIsBlind) .And.;
		(x[SM0_EMPOK] .Or. lIsBlind),;
		aAdd(aFilsCalc,{.F.,x[SM0_CODFIL],x[SM0_NOMRED],x[SM0_CGC],Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSC"), ;
		Posicione("SM0",1,x[SM0_GRPEMP]+x[SM0_CODFIL],"M0_INSCM")}),;
		NIL)})

	If lMostraTela
		DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0014) STYLE DS_MODALFRAME From 145,0 To 445,628 OF oMainWnd PIXEL //"Seleccion de Sucursales"
		oDlg:lEscClose := .F.
		@ 05,15 TO 125,300 LABEL OemToAnsi(STR0015) OF oDlg  PIXEL //"Marque las Sucursales que se consideran en el procesamiento"
		@ 15,20 CHECKBOX oChkQual VAR lQual PROMPT OemToAnsi(STR0016) SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(aFilsCalc, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.)) //"Invertir seleccion"
		@ 30,20 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0017),OemToAnsi(STR0018),OemToAnsi(STR0019) SIZE 273,090 ON DBLCLICK (aFilsCalc:=MtFClTroca(oQual:nAt,aFilsCalc),oQual:Refresh()) NoScroll OF oDlg PIXEL //"Sucursal""Descripcion""CUIT"
		bLine := {|| {If(aFilsCalc[oQual:nAt,1],oOk,oNo),aFilsCalc[oQual:nAt,2],aFilsCalc[oQual:nAt,3],Transform(aFilsCalc[oQual:nAt,4],"@!R NN.NNN.NNN/NNNN-99")}}
		oQual:SetArray(aFilsCalc)
		oQual:bLine := bLine
		DEFINE SBUTTON FROM 134,240 TYPE 1 ACTION If(MtFCalOk(@aFilsCalc,.T.,.T.,nValida),oDlg:End(),) ENABLE OF oDlg
		DEFINE SBUTTON FROM 134,270 TYPE 2 ACTION If(MtFCalOk(@aFilsCalc,.F.,.T.,nValida),oDlg:End(),) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	RestArea(aAreaSM0)
Return aFilsCalc

//+---------------------------------------------------------------------+
//|Funcion auxiliar para la seleccion de sucursales						|
//+---------------------------------------------------------------------+

Static Function MtFClTroca(nIt,aArray)
	Default nIt := 0
	Default aArray := {}

	aArray[nIt,1] := !aArray[nIt,1]
	
Return aArray


/*/{Protheus.doc} PerSF3(nTipo,aData,cCpo,cSucursal)
	Función estatica que Obtiene informacion de SF3 para archivo de percepciones	
	@type Static Function
	@author luis.mata
	@since 11/09/2023
	@version version 1
	@param nTipo, numerico, Tipo de archivo a generar 
	@param aDatos, Array, Array en donde seran almacenados los datos antes de generar el txt.  
	@param cSucursal, caracter, Sucursal a considerar en la generación de txt   
	@return cCpo, caracter, Numero del campo libro que le corresonde tabla SFB
	@return  aDatos, Array, arreglo con las percepciones obtenidas de la consulta 
	@example
		PerSF3(1,@aDatos,cCpo,cSucursal) 
/*/
Static function PerSF3(nTipo,aData,cCpo,cSucursal)

	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTempPer	:= GetNextAlias()
	Local nRegs		:= 0
	Local cCuit 	:= ""
	Local cNome 	:= ""
	Local cEspecieV	:= ""
	Local cFcNccOr  := ""
	Local cDocOri   := ""
	Local cCompOri  := ""
	Local cTipComp  := ""
	Local cNumComp 	:= ""
	Local cMontBas 	:= ""
	Local cAlicApl 	:= ""
	Local cFechaPago 	:= ""
	Local cCuitOri 	:= ""


	Default nTipo := 1
	Default aData := {}
	Default cCpo := ""
	Default cSucursal := ""

	If nTipo == 1
		cEspecieV	:= "'NF','NDC','NCC' "
	ElseIf nTipo == 2
		cEspecieC  := "'NDI','NCI' "
	EndIf
	// Query para seccion datos
	cQuery 	:= 	"SELECT "
	cQuery	+=		"F3_SERIE, "
	cQuery	+=		"F3_CLIEFOR, "
	cQuery	+=		"F3_LOJA, "
	cQuery	+=		"F3_EMISSAO, "
	cQuery	+=		"F3_NFISCAL, "
	cQuery	+=		"F3_ESPECIE, "
	cQuery	+=		"F3_LIQPROD, "
	cQuery	+=		"F3_RG1415, "
	cQuery	+=		"SUM(F3_BASIMP" + cCpo + ") AS F3_BASIMP" + cCpo + ", "
	cQuery	+=		"F3_ALQIMP" + cCpo + ", "
	cQuery	+=		"SUM(F3_VALIMP" + cCpo + ") AS F3_VALIMP" + cCpo + ", "
	If nTipo == 1
		cQuery	+=	"A1_CGC, A1_NOME, A1_TIPO, A1_MUN, A1_END, A1_CEP 	"
	ElseIf nTipo == 2
		cQuery 	+=	"A2_CGC, A2_NOME "
	EndIf
	cQuery 	+=	"FROM "
	cQuery	+=		RetSqlName("SF3")+ " SF3,"

	If nTipo == 1
		cQuery	+=		RetSqlName("SA1")+ " SA1 "
	ElseIf nTipo == 2
		cQuery	+=		RetSqlName("SA2")+ " SA2 "
	End IF

	cQuery	+=	"WHERE "
	cQuery	+=	"F3_FILIAL='" + xFilial("SF3",cSucursal)+ "' AND "
	cQuery  +=  "F3_VALIMP"+ cCpo +" <> 0 AND "
	If nTipo == 1
		cQuery	+=	"A1_FILIAL='" + xFilial("SA1",cSucursal)+ "' AND "
	Else
		cQuery	+=	"A2_FILIAL='" + xFilial("SA2",cSucursal)+ "' AND "
	End If

	cQuery	+=		"F3_EMISSAO >='" + DTOS(MV_PAR01)+ "' AND "
	cQuery	+=		"F3_EMISSAO <='" + DTOS(MV_PAR02)+ "' AND "
	If nTipo == 1	// Percepciones Clientes
		cQuery	+=	"F3_TIPOMOV='V' AND "
		cQuery 	+=	"F3_ESPECIE IN ("+cEspecieV+") AND "
		cQuery	+=	"A1_COD =F3_CLIEFOR  AND "
		cQuery	+=	"A1_LOJA=F3_LOJA  AND "
		cQuery	+=	"SA1.D_E_L_E_T_=' ' AND "
	ElseIf nTipo == 2 // Percepciones Proveedores
		cQuery 	+= 	"F3_TIPOMOV='C' AND "
		cQuery 	+=	"F3_ESPECIE IN ("+cEspecieC+") AND "
		cQuery	+=	"A2_COD =F3_CLIEFOR  AND "
		cQuery	+=	"A2_LOJA=F3_LOJA  AND "
		cQuery	+=	"SA2.D_E_L_E_T_=' ' AND "

	EndIf
	cQuery	+=		"SF3.D_E_L_E_T_=' ' "
	cQuery	+=	"GROUP BY F3_NFISCAL,F3_ESPECIE,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_EMISSAO,F3_LIQPROD,F3_RG1415,F3_ALQIMP" + cCpo + ","
	If nTipo == 1
		cQuery	+=	"A1_CGC,A1_NOME,A1_TIPO,A1_MUN,A1_END,A1_CEP "
	Else
		cQuery	+=	"A2_CGC,A2_NOME "
	EndIf
	cQuery	+=		"ORDER BY F3_EMISSAO "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempPer,.T.,.T.)
	TcSetField( cTempPer, 'F3_EMISSAO', 'D', TamSX3('F3_EMISSAO')[1], 0 )

	Count to nRegs
	ProcRegua(nRegs)
	nRegs	:= 0
	(cTempPer)-> (dbgotop())
	While (cTempPer)-> (!Eof())
		nRegs++
		IncProc(STR0009 + str(nRegs)) //"Seleccionando registros..."
		// Modifica los datos del cliente (nTipo:1) 

		cFcNccOr  := ""
		cDocOri   := ""
		cCuitOri := ""
		cCompOri  := ""		
		If Alltrim((cTempPer)->F3_ESPECIE) == "NCC"
			SD1->(dbSelectArea("SD1"))
			SD1->(dbSetOrder(1))
			IF SD1->(dbSeek(xFilial("SD1",cSucursal)+(cTempPer)->F3_NFISCAL+(cTempPer)->F3_SERIE+(cTempPer)->F3_CLIEFOR+(cTempPer)->F3_LOJA, .T.))
			   SF2->(dbSelectArea("SF2"))
			   SF2->(dbSetOrder(1))
			   If SF2->(MsSeek(xFilial("SF2",cSucursal)+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA))
					cFcNccOr  := Substr(DTOS(SF2->F2_EMISSAO),7,2)+"-"+Substr(DTOS(SF2->F2_EMISSAO),5,2)+"-"+Substr(DTOS(SF2->F2_EMISSAO),1,4)
					cDocOri   := SF2->F2_DOC
					cCuitOri := Alltrim(Substr((cTempPer)->A1_CGC,0,11)) 
					cCompOri  := ""
					If !Empty(SF2->F2_RG1415) .And. !Empty(SF2->F2_SERIE) .And. Alltrim(SF2->F2_ESPECIE) == "NF"
						cCompOri := F841TYPDC( Alltrim(SF2->F2_RG1415), Alltrim(Substr(SF2->F2_SERIE,0,1)),Alltrim(SF2->F2_ESPECIE) )				
					EndIf
			  	EndIf
			EndIf 
		EndIf 
		If Alltrim((cTempPer)->F3_ESPECIE) == "NCI"
			SD1->(dbSelectArea("SD1"))
			SD1->(dbSetOrder(1))
			IF SD1->(dbSeek(xFilial("SD1",cSucursal)+(cTempPer)->F3_NFISCAL+(cTempPer)->F3_SERIE+(cTempPer)->F3_CLIEFOR+(cTempPer)->F3_LOJA, .T.))
			   SF1->(dbSelectArea("SF1"))
			   SF1->(dbSetOrder(1))
			   If SF1->(MsSeek(xFilial("SF1",cSucursal)+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA))
					cFcNccOr  := Substr(DTOS(SF1->F1_EMISSAO),7,2)+"-"+Substr(DTOS(SF1->F1_EMISSAO),5,2)+"-"+Substr(DTOS(SF1->F1_EMISSAO),1,4)
					cDocOri   := SF1->F1_DOC
					cCuitOri := Alltrim(Substr((cTempPer)->A2_CGC,0,11)) 
					cCompOri  := ""
					If !Empty(SF1->F1_RG1415) .And. !Empty(SF1->F1_SERIE) .And. Alltrim(SF1->F1_ESPECIE) == "NF"
						cCompOri := F841TYPDC( Alltrim(SF1->F1_RG1415), Alltrim(Substr(SF1->F1_SERIE,0,1)), Alltrim(SF1->F1_ESPECIE))			
					EndIf
			  	EndIf
			EndIf 
		EndIf 
		cTipComp := ""
		If Alltrim((cTempPer)->F3_ESPECIE) $ "NF|NCC|NCI|NDC|NDI"
			cTipComp := F841TYPDC( Alltrim((cTempPer)->F3_RG1415), Alltrim(Substr((cTempPer)->F3_SERIE,0,1)),Alltrim((cTempPer)->F3_ESPECIE) )	
		Endif

		cFechaPago := Substr(DTOS((cTempPer)->F3_EMISSAO),7,2)+"-"+Substr(DTOS((cTempPer)->F3_EMISSAO),5,2)+"-"+Substr(DTOS((cTempPer)->F3_EMISSAO),1,4) +"," 
		cTipComp := cTipComp +  ","
		cNumComp := (cTempPer)->F3_NFISCAL+","
		If nTipo == 1
			cCuit := Alltrim(Substr((cTempPer)->A1_CGC,0,11))+","
			cNome := Alltrim(Substr((cTempPer)->A1_NOME,0,60))+","
		ElseIf nTipo == 2
			cCuit := Alltrim(Substr((cTempPer)->A2_CGC,0,11))+","
			cNome := Alltrim(Substr((cTempPer)->A2_NOME,0,60))+","
		EndIf
		cMontBas := Strtran(Alltrim(TRANSFORM((cTempPer)->&("F3_BASIMP"+cCpo),"@E 9999999999.99")),",",".")+","
		cAlicApl := Strtran(Alltrim(TRANSFORM((cTempPer)->&("F3_ALQIMP"+cCpo),"@E 99.99")),",",".")+","
		cDocOri  := IIF( Alltrim(cDocOri) ==",", ",", cDocOri +"," ) 
		cCompOri := IIF( Alltrim(cCompOri) ==",", ",", cCompOri +"," ) 
		cFcNccOr := IIF( Alltrim(cFcNccOr) ==",", ",", cFcNccOr +"," ) 
		cCuitOri := IIF( Alltrim(cCuitOri) =="", "", cCuitOri ) 


		AADD(aData,{cFechaPago,cTipComp,cNumComp,cNome,cCuit,cMontBas,cAlicApl,;
			cCompOri,cDocOri,cFcNccOr,cCuitOri})
		(cTempPer)-> (dbSkip())
	EndDo
	(cTempPer)-> (dbCloseArea())
	RestArea(aArea)
Return

/*/{Protheus.doc} RetSFE(nTipo,aData,cSucursal)
	Función estatica que Obtiene informacion de SFE para archivo de retenciones 		
	@type Static Function
	@author luis.mata
	@since 11/09/2023
	@version version 1
	@param nTipo, numerico, Tipo de archivo a generar 
	@param aData, Array, Array en donde seran almacenados los datos antes de generar el txt.  
	@param cSucursal, caracter, Sucursal a considerar en la generación de txt   
	@example
		RetSFE(1,@aDatosR,cSucursal)
/*/

Static Function RetSFE(nTipo,aData,cSucursal)

	Local aArea		:= getArea()
	Local cQuery	:= ""
	Local cTmp		:= GetNextAlias()
	Local nRegs		:= 0
	Local cCuit 	:= ""
	Local cFechaPago 	:= ""
	Local cTipo 	:= ""
	Local cCep 	:= ""
	Local cNome 	:= ""
	Local cValBase 	:= ""
	Local cAlicApl 	:= ""
	Local cTipoOri 	:= ""
	Local cCompOr 	:= ""
	Local cDatOri 	:= ""
	Local cCuiOri 	:= ""

	Default nTipo := 1
	Default aData := {}
	Default cSucursal := ""

	// Query para seleccion datos
	cQuery 	:= 		"SELECT "
	cQuery	+=		"FE_NROCERT, "
	cQuery	+=		"FE_FORNECE, "
	cQuery	+=		"FE_LOJA, "
	cQuery	+=		"FE_EMISSAO, "
	cQuery	+=		"SUM(FE_VALBASE) FE_VALBASE, "
	cQuery	+=		"FE_ALIQ, "
	cQuery	+=		"FE_FILIAL,"
	cQuery	+=		"FE_ORDPAGO,"
	cQuery	+=		"FE_SERIE,"
	cQuery	+=		"FE_PARCELA,"
	cQuery	+=		"FE_DTESTOR,"
	cQuery	+=		"FE_NRETORI,"
	cQuery	+=		"FE_DTRETOR,"
	cQuery	+=		"A2_CGC,"
	cQuery	+=		"A2_NOME,"
	cQuery	+=		"A2_TIPO,"
	cQuery	+=		"A2_NROIB "
	cQuery 	+=		"FROM "
	cQuery	+=		RetSqlName("SFE")+ " SFE,"
	cQuery	+=		RetSqlName("SA2")+ " SA2 "
	cQuery	+=		"WHERE "
	cQuery	+=		"FE_FILIAL='" 		+ xFilial("SFE",cSucursal)+ "' AND "
	cQuery	+=		"A2_FILIAL='" 		+ xFilial("SA2",cSucursal)+ "' AND "
	cQuery	+=		"FE_EMISSAO >='" 	+ DTOS(MV_PAR01)+ "' AND "
	cQuery	+=		"FE_EMISSAO <='" 	+ DTOS(MV_PAR02)+ "' AND "
	cQuery	+=		"FE_EST = 'MI' AND "
	cQuery	+=		"FE_TIPO = 'B' AND "
	cQuery	+=		"A2_COD =FE_FORNECE  AND "
	cQuery	+=		"A2_LOJA=FE_LOJA  AND "
	cQuery	+=		"SA2.D_E_L_E_T_=' ' AND "
	cQuery	+=		"SFE.D_E_L_E_T_=' ' "
	cQuery	+= 		" AND (FE_DTESTOR <'" + DTOS(MV_PAR01)+ "' OR "
	cQuery	+=		" FE_DTESTOR >'" + DTOS(MV_PAR02)+ "' OR "
	cQuery	+=		" FE_DTESTOR = ' ' OR "
	cQuery	+=		" FE_NRETORI <> ' ' "        //Significa que es Ret. Anulada
	cQuery	+=		") AND "
	cQuery	+=		"( "
	cQuery	+=		"FE_DTRETOR <'" + DTOS(MV_PAR01)+ "' OR "
	cQuery	+=		"FE_DTRETOR >'" + DTOS(MV_PAR02)+ "' OR "
	cQuery	+=		"FE_DTRETOR = ' ' OR "
	cQuery	+=		"FE_NRETORI = ' ' "
	cQuery	+=		") "
	cQuery  +=		"GROUP BY FE_NROCERT,FE_FORNECE,FE_LOJA,FE_EMISSAO,FE_ALIQ,FE_FILIAL,"
	cQuery  +=		"FE_ORDPAGO,FE_SERIE,FE_PARCELA,FE_DTESTOR,FE_NRETORI,FE_DTRETOR,A2_CGC,A2_NOME,"
	cQuery  +=		"A2_TIPO,A2_NROIB"
	cQuery  +=		"ORDER BY FE_EMISSAO"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
	TcSetField( cTmp, 'FE_EMISSAO', 'D', TamSX3('FE_EMISSAO')[1], 0 )
	Count to nRegs
	ProcRegua(nRegs)
	nRegs	:= 0


	(cTmp)-> (dbgotop())
	While (cTmp)-> (!Eof())
		nRegs++
		IncProc(STR0009 + str(nRegs))//"Seleccionando registros..."


			cFechaPago :=Substr(DTOS((cTmp)->FE_EMISSAO),7,2)+"-"+Substr(DTOS((cTmp)->FE_EMISSAO),5,2)+"-"+Substr(DTOS((cTmp)->FE_EMISSAO),1,4) +","
			Iif(  !EMPTY((cTmp)->FE_DTESTOR) .And. !EMPTY((cTmp)->FE_DTRETOR) , cTipo:="CAR",cTipo:="CR")
			cTipo  := cTipo+","
			cCep := Alltrim(Substr((cTmp)->FE_NROCERT,0,60))+","
			cCuit := Alltrim(Substr((cTmp)->A2_CGC,0,11))+","
			cNome := Alltrim(Substr((cTmp)->A2_NOME,0,60))+","
			cValBase := Alltrim(Replace(TRANSFORM((cTmp)->FE_VALBASE,"@E 9999999999.99"),",","."))+","
			cAlicApl := Alltrim(Replace(TRANSFORM((cTmp)->FE_ALIQ,"@E 99.99"),",","."))+","
			If (cTmp)->FE_VALBASE < 0
				cValBase := (cTmp)->FE_VALBASE * -1
				cValBase := Strtran(Alltrim(TRANSFORM(cValBase,"@E 9999999999.99")),",",".")+","
			EndIf
			cTipoOri := ""
			cCompOr  :=	""
			cDatOri  := ""
			cCuiOri  := ""
			If !EMPTY((cTmp)->FE_DTESTOR) .And. !EMPTY((cTmp)->FE_DTRETOR)
				cTipoOri := "CR"
				cCompOr  :=	Alltrim(Substr((cTmp)->FE_NRETORI,0,12))
				cDatOri  := Substr((cTmp)->FE_DTRETOR,7,2)+"-"+Substr((cTmp)->FE_DTRETOR,5,2)+"-"+Substr((cTmp)->FE_DTRETOR,1,4) 
				cCuiOri  := Alltrim(Substr((cTmp)->A2_CGC,0,11))
			EndIf 
			cTipoOri := IIF( Alltrim(cTipoOri) ==",", ",", cTipoOri +"," ) 
			cCompOr  :=	IIF( Alltrim(cCompOr) ==",", ",", cCompOr +"," ) 
			cDatOri  := IIF( Alltrim(cDatOri) ==",", ",", cDatOri +"," ) 
			cCuiOri  := IIF( Alltrim(cCuiOri) =="", "", cCuiOri +"" ) 


			AADD(aData,{cFechaPago,cTipo,cCep,cNome,cCuit,;
				cValBase,cAlicApl,cTipoOri,cCompOr,cDatOri,cCuiOri })

		(cTmp)-> (dbSkip())
	EndDo
	(cTmp)-> (dbCloseArea())
	RestArea(aArea)
Return

/*/{Protheus.doc} F841TYPDC(cRg1415,cSerie)
	Función estatica que devuelve el tipo de documento	
	@type Static Function
	@author luis.mata
	@since 14/09/2023
	@version version 1
	@param cRg1415, String, RG que le corresponde al documento
	@param cSerie, String, cadena que almacena la serie del documento  
	@param cEspecie, String, cadena que almacena la especie del documento  
	@example
		F841TYPDC( Alltrim(SF1->F1_RG1415), Alltrim(Substr(SF1->F1_SERIE,0,1)), Alltrim(SF1->F1_ESPECIE))
/*/
Static function F841TYPDC(cRg1415,cSerie,cEspecie)
Local cTipComp  := ""
Default cRg1415 := ""
Default cSerie  := ""
Default cEspecie := "" 

	If cEspecie = "NF" 
		Do Case
			Case cRg1415<"200" .And. cSerie =="A"
				cTipComp := "FA_A"
			Case cRg1415<"200" .And. cSerie =="B"
				cTipComp := "FA_B"
			Case cRg1415<"200" .And. cSerie =="C"
				cTipComp := "FA_C"
			Case cRg1415>"200" .And. cSerie =="A"
				cTipComp := "FCE_A"
			Case cRg1415>"200" .And. cSerie =="B"
				cTipComp := "FCE_B"
			Case cRg1415>"200" .And. cSerie =="C"
				cTipComp := "FCE_C"
		EndCase 
	Elseif cEspecie $ "NCC|NCI" 
		Do Case
			Case cRg1415<"200" .And. cSerie =="A"
				cTipComp := "NC_A"
			Case cRg1415<"200" .And. cSerie =="B"
				cTipComp := "NC_B"
			Case cRg1415<"200" .And. cSerie =="C"
				cTipComp := "NC_C"
			Case cRg1415>"200" .And. cSerie =="A"
				cTipComp := "NCE_A"
			Case cRg1415>"200" .And. cSerie =="B"
				cTipComp := "NCE_B"
			Case cRg1415>"200" .And. cSerie =="C"
				cTipComp := "NCE_C"
		EndCase 
	ElseIf cEspecie $ "NDI|NDC" 
		Do Case
			Case cRg1415<"200" .And. cSerie =="A"
				cTipComp := "ND_A"
			Case cRg1415<"200" .And. cSerie =="B"
				cTipComp := "ND_B"
			Case cRg1415<"200" .And. cSerie =="C"
				cTipComp := "ND_C"
			Case cRg1415>"200" .And. cSerie =="A"
				cTipComp := "NDE_A"
			Case cRg1415>"200" .And. cSerie =="B"
				cTipComp := "NDE_B"
			Case cRg1415>"200" .And. cSerie =="C"
				cTipComp := "NDE_C"
		EndCase 
	EndIf 

Return cTipComp
