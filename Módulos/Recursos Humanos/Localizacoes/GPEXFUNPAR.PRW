#INCLUDE "PROTHEUS.CH"
#INCLUDE "SCOPECNT.CH"
#INCLUDE "GPEXFUNPAR.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |GPEXFUNPARºAutor  ³Laura Medina        º Data ³ 15/01/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Contiene funciones auxiliares en la localización de GPE     º±±
±±º          ³para PARAGUAY.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³Merge                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DiasFerParºAutor  ³Laura Medina        º Data ³ 15/01/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Función para obtener los días derecho para Paraguay.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ DiasFerPar(cFilSRA,cMat,cPdSRF,dDateIni                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cFilSRA     = Filial del empleado                          º±±
±±º          ³ cMat        = Matrícula                         	  	    º±±
±±º          ³ cPdSrf      = Concepto de días Derecho                     º±±
±±º          ³ dDateIni    = Fecha de Admisión del empleado               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gpea010Grv()                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DiasFerPar(cProces, dFcRecon, dAdmissa, cGpoVac)  
Local aArea	    := GetArea()
Local cCalend   := ""
Local nDiasVac  := 0
Local nAntigTot := ""
Local nAux01    := 0
Default cProces := ""
Default dFcRecon:= CTOD("//")
Default dAdmissa:= CTOD("//")
Default cGpoVac := ""

DbSelectArea( "RCJ" )
DbSetOrder( RetOrdem( "RCJ", "RCJ_FILIAL+RC_CODIGO" ) )
If  MsSeek( xFilial("RCJ") + cProces, .F. )
	If !Eof()
		cCalend := RCJ->RCJ_CALEND 
	EndIf
Endif

If  !Empty(dFcRecon) 
	dAntig := dFcRecon
Else 
	dAntig := dAdmissa                             
EndIf

If  cCalend == "1"
	nDiasAntig := Dias360(dAntig, dDatabase)
	nAntigTot  := nDiasAntig / 360 
Else
	nDiasAntig := dDatabase - dAntig + 1 
	nAntigTot  := nDiasAntig / 365
Endif  

nAux01 := FPOSTAB("S013", cGpoVac, "=", 4, nAntigTot, "<=",7)
If  nAux01 > 0 
	nDiasVac := FTABELA("S013",nAux01,8)
Endif


RestArea( aArea )

Return nDiasVac 


/*/{Protheus.doc} Dias360
Devuelve el salario y actualiza los campos necesarios. 
@author Laura Medina
@since 10/01/2020
@version 12.1.25  	
@return 	nSalario	Numerico	Salario (RA_SALARIO).  
/*/
Function fSal_PAR()
Local aArea		:= GetArea()
Local dAntig    := CTOD("//")
Local nFacCon   := 0 
Local cCalend   := ""
Local nAntigTot := 0
Local cCodFunc  := "" 
Local cCatFunc  := ""
Local cProces   := ""
Local nSalario  := 0
Local cPer      := ""
Local cNumPag   := ""
Local nAux01    := 0
Local nSalMes   := 0
Local nSalDia   := 0
Local lPer      := .T.
Local dFcRecon  := CTOD("//")
Local dFcAdmis  := CTOD("//")
Local nPorcen   := 0
Local dFcTemRCH := CTOD("//")
Local dFcIniRCH := CTOD("//")
Local dFcAniver := CTOD("//") 
Local dFcNasc   := CTOD("//")
Local nSalTemp  := 0

nSalario  := If( IsMemVar( "RA_SALARIO" ), GetMemVar( "RA_SALARIO" ) , SRA->RA_SALARIO)
cCodFunc  := If( IsMemVar( "RA_CODFUNC" ), GetMemVar( "RA_CODFUNC" ), SRA->RA_CODFUNC)
cCatFunc  := If( IsMemVar( "RA_CATFUNC" ), GetMemVar( "RA_CATFUNC" ), SRA->RA_CATFUNC)
cProces   := If( IsMemVar( "RA_PROCES" ),  GetMemVar( "RA_PROCES" ), SRA->RA_PROCES )
dFcRecon  := If( IsMemVar( "RA_DTREC" ),   GetMemVar( "RA_DTREC" ), SRA->RA_DTREC)
dFcAdmis  := If( IsMemVar( "RA_ADMISSA" ), GetMemVar( "RA_ADMISSA" ), SRA->RA_ADMISSA )
dFcNasc   := If( IsMemVar( "RA_NASC" ) ,   GetMemVar( "RA_NASC" ), SRA->RA_NASC ) 

If  Empty(dFcRecon)
	dAntig  := dFcAdmis
Else
	dAntig  := dFcRecon
Endif 

DbSelectArea( "RCJ" )
DbSetOrder( RetOrdem( "RCJ", "RCJ_FILIAL+RC_CODIGO" ) )
If  MsSeek( xFilial("RCJ") + cProces, .F. )
	If !Eof()
		cCalend := RCJ->RCJ_CALEND 
	EndIf
Endif

If  cCalend == "1"
	nDiasAntig := Dias360(dAntig, dDatabase)
	nAntigTot  := nDiasAntig / 360 
Else
	nDiasAntig := dDatabase - dAntig + 1 
	nAntigTot  := nDiasAntig / 365
Endif  

//Obtener Periodo y Numero de Pago 
cRetPer := Gp010RetCont("RCH_PER", NIL, cProces, @lPer )
If lPer
	cPer  := cRetPer
EndIf
cRetPer := Gp010RetCont("RCH_NUMPAG", NIL, cProces, @lPer )
If lPer
	cNumPag  := cRetPer
Endif
dFcTemRCH := Gp010RetCont("RCH_DTFIM", NIL, cProces, @lPer )
If lPer
	dFcIniRCH:= dFcTemRCH
Endif


//Determinar el % del salario mínimo con el que se compara

//1) Si Ley del primer empleo, Jornalero, Mensualista >= 100%
IF cCatFunc $ "1|D|M" 
   nPorcen  := 1
ENDIF

//2) Si Ley Empleo Juvenil (menor de edad, aprendiz)– Práctica Laboral >= 60%
dFcAniver :=  CTOD(STRZERO(DAY(dFcNasc),2) +"/" + STRZERO(MONTH(dFcNasc),2)+ "/" + ALLTRIM(STR(YEAR(dFcNasc)+18))) 
If  dFcIniRCH < dFcAniver .OR. cCatFunc $ "E|3"   //Menor de edad o E=Aprendiz o 3=Ley Empleo Juvenil – Práctica Laboral
	nPorcen := 0.60
Endif

//3) Si Ley de Empleo Juvenil – Capacitación Laboral y  Si Ley de Empleo Juvenil – Aprendizaje >= 70%
If  cCatFunc $ "2|5"
	nPorcen := 0.70
Endif

//4) Si Ley de Empleo Juvenil – Beca de Trabajo >= 25%
If  cCatFunc == "4" 
	nPorcen := 0.25
Endif

//5) Si Ley Empleo Juvenil - Primer Empleo Juvenil >= 65%
If  cCatFunc == "6" 
	nPorcen := 0.65
Endif

//6) Si Honorarios o Destajista >=0 %
If  cCatFunc $ "A|T"
	nPorcen := 0.00
Endif

DbSelectArea( "SRJ" )
DbSetOrder( RetOrdem( "SRJ", "SRJ_FILIAL+SRJ_FUNCAO" ) )
If  MsSeek( xFilial("SRJ") + cCodFunc )

	//Tomar de la tabla de Categorías (SRJ)
	If  SRJ->RJ_SALANT == "2" .AND. SRJ->RJ_SALTAR == "2" 
		nSalTemp := (SRJ->RJ_SALARIO * nPorcen)
		If  nSalario < 	nSalTemp				
			M->RA_SALARIO := nSalTemp
		Endif
		
    //Tomar de la tabla de Salario x Antiguedad (S003) 
    ElseIf  SRJ->RJ_SALANT == "1"   
    	nAux01 := FPOSTAB("S003", cCodFunc, "=", 4, nAntigTot, "<=",7)
    	If nAux01 > 0 
    		nSalTemp := FTABELA("S003",nAux01,8) * nPorcen
    		If  nSalario < nSalTemp	
    			M->RA_SALARIO := nSalTemp
    		Endif
    	Else
    		M->RA_SALARIO := 0
    	Endif
	      
    //Tomar de la tabla de Salario x Tareas (S070)
    ElseIf  SRJ->RJ_SALTAR == "1"    
    	IF  nSalario <> 0
		       M->RA_SALARIO := 0
		Endif
		M->RA_CATFUNC := "T"
	Endif 	
	M->RA_SALMES  := M->RA_SALARIO
	M->RA_SALDIA  := Iif(M->RA_SALARIO>0,Iif(SRJ->RJ_FACCON>0,M->RA_SALARIO / SRJ->RJ_FACCON,0) ,0)				
Endif

If !Inclui 
    M->RA_FECAUM  := CTOD("//")
    M->RA_TIPOALT := "004"
    M->RA_PERAUM  := cPer
    M->RA_PAGAUM  := cNumPag
    M->RA_DATAALT := Ddatabase 
Endif

nSalario := M->RA_SALARIO 

RestArea( aArea )
Return( nSalario )


/*/{Protheus.doc} Dias360
Devuelve la cantidad de días entre dos fechas basándose en un año de 360 días (12 meses de 30 días)
@author Laura Medina
@since 13/01/2020
@version 12.1.25
@param 		dFchIni		Date		Fecha de Antiguedad (inicial).
@param 		dFchFin		Date		Fecha actual (final).   	
@return 	nDias360	Numerico	Numero de días entre las 2 fechas, en un año de 360 días.  
/*/
Function Dias360(dFchIni, dFchFin)  //01/10/2007, 13/01/2020 
Local nDias360  := 0
Local nAnoFcIni := 0
Local nAnoFcFin := 0 
Local nAnoTotal := 0
Local nMesFcIni := 0
Local nMesFcFin := 0
Local nMesTotal := 0
Local nDayFcIni := 0 
Local nDayFcFin := 0 
Local nDayTotal := 0


Default dFchIni := CTOD("//")  
Default dFchFin := CTOD("//")   


//Año 
nAnoFcIni := YEAR(dFchIni)
nAnoFcFin := YEAR(dFchFin)

//Mes
nMesFcIni := MONTH(dFchIni)
nMesFcFin := MONTH(dFchFin)

//Día 
nDayFcIni := DAY(dFchIni)
nDayFcFin := DAY(dFchFin)

nDayFcIni := If(nDayFcIni>30, 30, Iif(nMesFcIni == 2 .And. (nDayFcIni == 28 .OR. nDayFcIni == 29), 30, nDayFcIni))
nDayFcFin := If(nDayFcFin>30, 30, Iif(nMesFcFin == 2 .And. (nDayFcFin == 28 .OR. nDayFcFin == 29), 30, nDayFcFin))

nDayTotal := nDayFcFin - nDayFcIni  //13 - 01 = 12

If  nDayTotal < 0  //Días en negativo 
	nDayFcFin += 30
	nDayTotal := nDayFcFin - nDayFcIni 
	nMesFcFin -= 1 
Endif

nMesTotal := nMesFcFin - nMesFcIni  //01 - 10 = -09

If  nMesTotal < 0  //Días en negativo 
	nMesFcFin += 12
	nMesTotal := nMesFcFin - nMesFcIni 
	nAnoFcFin -= 1 
Endif

nAnoTotal := nAnoFcFin - nAnoFcIni  //2020 - 2007 = 13

nDias360 := nDayTotal + ( nMesTotal * 30) + (nAnoTotal * 360) 


Return nDias360

/*/{Protheus.doc} GpexAusent
Genera archivo PRX para la tabla RCM a partir de a rutina de Conceptos
Genera el archivo GPRCMPAR a partir de la  Tabla de Tipos de Ausentimos (RCM).

La funcionalidad se movió al fuente GPEXFUMI

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@param cPath, caracter, directorio donde se generara el archivo
@param aListaArch, arreglo, lista de archivos que se han generado
@example
GpexAusent(cPath, aListaArch)
/*/
Function GpexAusent(cPath, aListaArch)

	Local cFuncion		:= "GPEXGERRCM"
	
	Default cPath		:= ""
	Default aListaArch	:= {}

	IIf(FindFunction(cFuncion), GpexGerRCM(cPath, aListaArch), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return(NIL)

/*/{Protheus.doc} fCargRCM
Carga los Registros de la Tabla de Tipos de Ausentimos RCM a partir de conceptos

La funcionalidad se movió al fuente GPEXFUMI

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@example
fCargRCM()
/*/
Function fCargRCM()

	Local cFuncion	:= "GPEXCRGRCM"

	IIf(FindFunction(cFuncion), GpexCrgRCM(), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return(NIL)

/*/{Protheus.doc} GerGpexRGX

Genera archivo PRX para la tabla RG5, RG6 y RG9 a partir de a rutina de Conceptos por proceso.
Genera el archivo GPRGX + cPaisLoc y GPRG9 + cPaisLoc a partir de la  Tabla de estandar de 
periodos y Criterios de Acumulación (RG5,RG6 y RG9).

Se mueve funcionalidad a GPEXFUMI debido que aplica para todo MI.

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@archivo utilizado	RCM
/*/
Function GerGpexRGX(cPath, aListaArch)

	Local cFuncion	:= "GPEXRGXMI"

	IIf(FindFunction(cFuncion), GpexRGXMI(cPath, aListaArch), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return (Nil)

/*/{Protheus.doc} fCargRGX
Carga los Registros de las Tablas de Estandar de Periodos RG5 y RG6 a partir de conceptos por procesos

Se mueve funcionalidad a GPEXFUMI debido que aplica para todo MI.

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@archivo utilizado	GPRGX + cPaisLoc + .PRX 
/*/
Function fCargRGX()

	Local cFuncion	:= "GPEXCRGRGX"

	IIf(FindFunction(cFuncion), GpexCrgRGX(), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return (Nil)

/*/{Protheus.doc} Carga RG9
Carga los Registros de la Tabla de Criterios de Acumulación RG9 a partir de conceptos por procesos.

Se mueve funcionalidad a GPEXFUMI debido que aplica para todo MI.

@author Erika Espinosa
@since 17/01/2020
@version 2.0
@archivo utilizado  GPRG9 + cPaisLoc + .PRX  
/*/
Function fCargRG9()

	Local cFuncion	:= "GPEXCRGRG9"

	IIf(FindFunction(cFuncion), GpexCrgRG9(), Help("", 1, "OBJECTRPO", , STR0015 + cFuncion + "().", 1, 0)) //"Rutina desactualizada, solicite paquete con actualizaciones: "

Return (Nil)

/*/{Protheus.doc} Inicializa estandar SRG
Inicializador estandar del campo RG_DFERVENT
@author Erika Espinosa
@since 10/03/2020
@version 12.1.25
@archivo utilizado 
/*/
Function fDferven()

Local aAreaSRF	:= SRF->(GetArea()) 
Local nAniosant := 0

DbSelectArea("SRF")
DbSetOrder(1)

If SRF->(MsSeek(xFilial("SRG") +  M->RG_MAT))

	While !SRF->(Eof()) .and. xFilial("SRG") +  M->RG_MAT == SRF->RF_FILIAL + SRF->RF_MAT

		If (RF_STATUS == "1")
			nAniosant := nAniosant + (RF_DFERVAT-RF_DFERANT)
		EndIf
	SRF->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSRF)
Return(nAniosant)

/*/{Protheus.doc} Inicializa estandar SRG
Inicializador estandar del campo RG_DFERPRO
@author Erika Espinosa
@since 10/03/2020
@version 12.1.25
@archivo utilizado 
/*/
Function fDferpro()

Local aAreaSRF	:= SRF->(GetArea()) 
Local nAniospro := 0

DbSelectArea("SRF")
DbSetOrder(1)

If SRF->(MsSeek(xFilial("SRG") +  M->RG_MAT))

	While !SRF->(Eof()) .and. xFilial("SRG") +  M->RG_MAT == SRF->RF_FILIAL + SRF->RF_MAT

		If (RF_STATUS == "1")
			nAniospro := nAniospro + RF_DFERAAT
		EndIf
	SRF->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSRF)
Return(nAniospro)


/*/{Protheus.doc} Inicializa estandar SRG
Inicializador estandar del campo RG_salmes
@author Erika Espinosa
@since 10/03/2020
@version 12.1.25
@archivo utilizado 
/*/
Function fSalmespar()

Local aAreaSRA	:= SRA->(GetArea()) 
Local nSalmes := 0

DbSelectArea("SRA")
DbSetOrder(1)

If SRA->(MsSeek(xFilial("SRG") +  M->RG_MAT))

	If (SRA->RA_CATFUNC $ "A|C|E|I|M|P")
		nSalmes := SRA->RA_SALARIO
	EndIf
	If (SRA->RA_CATFUNC $ "D|S")
		nSalmes := (SRA->RA_SALARIO * SRA->RA_HRSDIA) / SRA->RA_HRSMES
	EndIf
	If (SRA->RA_CATFUNC $ "G|H")
		nSalmes := SRA->RA_SALARIO * SRA->RA_HRSDIA
	EndIf
		
EndIf

RestArea(aAreaSRA)
Return(nSalmes)

/*/{Protheus.doc} nomeFunction
	(long_description)
	@type  Function
	@author oscar.lopez
	@since 02/01/2025
	@version version
	@param cOpc, caracter, Informa si se procesarán 1-Departamento, 2-Distrito o 3-Localidad
	@param lValid, booleano, Informa .T. si se validará el contenido de campo, .F. si se mostrará ventana de selección de codigo de Dep/Dis/Loc.
	@return lRet, booleano, Retorna .T. si se seleccionó un dato valido, o si se informó un dato valido.
	@example
		fS98LNSPar("2", .T.)
	/*/
Function fS98LNSPar(cOpc, lValid)
	Local aArea			:= GetArea()
	Local oDlgSXB		:= Nil
	Local oListBox		:= Nil
	Local oCmbOrdem		:= Nil
	Local lRet			:= .T.
	Local aDepDisLoc	:= {} 
	Local aOrdem		:= {STR0016, STR0017} // "Código" # "Descripción"
	Local nOrdem		:= 1
	Local cPesq			:= Space(50)
	Local cQuery		:= ""
	Local bOk			:= ""   
	Local cTitulo		:= ""
	Local bPesq			:= {||fS98Pesq(@oCmbOrdem,@aDepDisLoc,@oListBox,cPesq)}

	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjSize		:= {}
	Local aObjCoords	:= {}

	Local aAdv1Size		:= {}
	Local aInfo1AdvSize	:= {}
	Local aObj1Size		:= {}
	Local aObj1Coords	:= {}

	Local aAdv2Size		:= {}
	Local aInfo2AdvSize	:= {}
	Local aObj2Size		:= {}
	Local aObj2Coords	:= {}

	Local cDbMs         := AllTrim(UPPER(TcGetDb()))
	Local cExpSub		:= "SUBSTR"
	Local cFilRCC		:= FWxFilial("RCC")
	Local cTabRCC		:= RetSqlName("RCC")
	Local cContIni		:= ""
	Local cCodTab		:= ""
	Local cTamTemp		:= ""
	Local cCodRet		:= ""
	Local cValOrig		:= ""
	Local nNumParQry	:= 1
	Local oStatement	:= Nil

	Default cOpc		:= "1"
	Default lValid		:= .F.

	If cDbMs == "MSSQL" // Si el manejador de BD es SQL Server
		cExpSub := "SUBSTRING"
	EndIf
	
	If cOpc == "1" // Filtra Departamento
	 	cContIni	:= "1"
		cCodTab		:= "S095"
		cTitulo		:= STR0019 // "LNS - DEPARTAMENTO (S095)"
		cValOrig	:= M->RA_REGIAO
	ElseIf cOpc == "2" // Filtra Distrito, a partir de Departamento
		cContIni	:= "7"
		cCodTab		:= "S096"
		cTitulo		:= STR0020 // "LNS - DISTRITO (S096)"
		cValOrig	:= M->RA_PROVINC
	ElseIf cOpc == "3" // Filtra Localidad, a partir de Departamento y Distrito
		cContIni	:= "13"
		cCodTab		:= "S097"
		cTitulo		:= STR0021 // "LNS - LOCALIDAD (S097)"
		cValOrig	:= M->RA_CODMUN
	EndIf

	If !lValid .Or. (lValid .And. !Empty(cValOrig))
		cQuery := "	SELECT " + cExpSub + "(RCC.RCC_CONTEU,1,6) CODIGO, " + cExpSub + "(RCC.RCC_CONTEU,7,50) DESCRI"
		cQuery += " FROM ? RCC"
		cQuery += " WHERE RCC.RCC_CODIGO = '" + cCodTab + "'"
		cQuery += " AND " + cExpSub + "(RCC.RCC_CONTEU,1,6) IN ("
		cQuery += "      SELECT " + cExpSub + "(RC1.RCC_CONTEU," + cContIni + ",6)"
		cQuery += "      FROM ? RC1"
		cQuery += "      WHERE RC1.RCC_CODIGO = 'S098'"
		If cOpc $ "2|3" .Or. (lValid .And. cOpc == "1")
			cQuery += "      AND " + cExpSub + "(RC1.RCC_CONTEU,1,6) = ? "
			If cOpc == "3"  .Or. (lValid .And. cOpc == "2")
				cQuery += "      AND " + cExpSub + "(RC1.RCC_CONTEU,7,6) = ? "
				If lValid .And. cOpc == "3"
					cQuery += "      AND " + cExpSub + "(RC1.RCC_CONTEU,13,6) = ? "
				EndIf
			EndIf
		EndIf
		cQuery += "      AND RC1.RCC_FILIAL = ?"
		cQuery += "      AND RC1.D_E_L_E_T_ = ? )"
		cQuery += " AND RCC.RCC_FILIAL = ?"
		cQuery += " AND RCC.D_E_L_E_T_ = ?"
		cQuery += " ORDER BY RCC.RCC_SEQUEN"

		oStatement := FwExecStatement():New(cQuery)

		oStatement:SetUnsafe(nNumParQry++, cTabRCC)
		oStatement:SetUnsafe(nNumParQry++, cTabRCC)
		If lValid
			oStatement:SetString(nNumParQry++, M->RA_REGIAO)
			If cOpc $ "2|3"
				oStatement:SetString(nNumParQry++, M->RA_PROVINC)
				If cOpc $ "3"
					oStatement:SetString(nNumParQry++, M->RA_CODMUN)
				EndIf
			EndIf
		ElseIf cOpc $ "2|3"
			oStatement:SetString(nNumParQry++, M->RA_REGIAO)
			If cOpc == "3"
				oStatement:SetString(nNumParQry++, M->RA_PROVINC)
			EndIf
		EndIf
		oStatement:SetString(nNumParQry++, cFilRCC)
		oStatement:SetString(nNumParQry++, " ")
		oStatement:SetString(nNumParQry++, cFilRCC)
		oStatement:SetString(nNumParQry++, " ")

		cTamTemp := oStatement:OpenAlias()

		(cTamTemp)->(DbGoTop()) 
		While (cTamTemp)->(!Eof())
			Aadd(aDepDisLoc,{ (cTamTemp)->CODIGO, (cTamTemp)->DESCRI})
			(cTamTemp)->(dbSkip())
		EndDo

		If oStatement <> Nil
			Freeobj(oStatement)
		EndIf

		If Len(aDepDisLoc) <= 0
			cMsg := STR0021 + CRLF // "No existe relacion para el valor informado en la tabla Detalle DEPT/DIST/LOC (S098)"
			cMsg += STR0018 + " x " + STR0019 +" x "+ STR0020 +"." // "LNS - DEPARTAMENTO (S095)" # "LNS - DISTRITO (S096)" # "LNS - LOCALIDAD (S097)"
			MsgAlert(cMsg)
			lRet := .F.
		ElseIf !lValid
			cCodRet		:= cValOrig
			aAdvSize	:= MsAdvSize(.T.,.T.,380)
			aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
			aAdd( aObjCoords , { 000 , 030 , .T. , .F.  } )  		//1- Encabezado
			aAdd( aObjCoords , { 000 , 000 , .T. , .T. , .T.  } )	//2- ListBox
			aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

			//Division de encabezado
			aAdv1Size		:= aClone(aObjSize[1])
			aInfo1AdvSize	:= { aAdv1Size[2] , aAdv1Size[1] , aAdv1Size[4] , aAdv1Size[3] , 1 , 1 }
			aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			// Linea 1
			aAdd( aObj1Coords , { 000 , 000 , .T. , .T. } )			// Linea 2
			aObj1Size		:= MsObjSize( aInfo1AdvSize , aObj1Coords)//,,.T. )   

			// División en columnas
			aAdv2Size		:= aClone(aObj1Size[1])
			aInfo2AdvSize	:= { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 1 , 1 }
			aAdd( aObj2Coords , { 260, 000 , .F. , .T. } )			//1-Coluna1
			aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )			//3-Coluna2
			aObj2Size		:= MsObjSize( aInfo2AdvSize , aObj2Coords,,.T. )

			bOk := {||	cCodRet := aDepDisLoc[oListBox:nAt][1], oDlgSXB:End(),lRet := .T.  }
			//Pantalla de consulta de detalle tablas S095, S096 o S097
			oDlgSXB := TDialog():New(aAdvSize[7],0,aAdvSize[6],aAdvSize[5],cTitulo,,,,,,,,oMainWnd,.T.) 

			@ aObj1Size[1,1], aObj1Size[1,2] MSCOMBOBOX oCmbOrdem VAR nOrdem ITEMS aOrdem SIZE 250,010 OF oDlgSXB ON CHANGE fS98Ordem(oCmbOrdem,@aDepDisLoc,@oListBox) PIXEL
			@ aObj2Size[2,1], aObj2Size[2,2] BUTTON STR0022 SIZE 041, 011 OF oDlgSXB PIXEL Action Eval(bPesq) //"Buscar"
			@ aObj1Size[2,1], aObj1Size[2,2] MSGET cPesq SIZE 250, 010 OF oDlgSXB PIXEL Valid (Eval(bPesq))

			oListBox := TWBrowse():New(aObjSize[2,1], aObjSize[2,2] ,aObjSize[2,3], aObjSize[2,4],,{UPPER(STR0016),UPPER(STR0017)},,oDlgSXB,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Código" # "Descripción"
			oListBox:bLDblClick := bOk
			fS98Ordem(oCmbOrdem,@aDepDisLoc,@oListBox)
			oDlgSXB:bInit := {|| EnchoiceBar(oDlgSXB, bOK, {||oDlgSXB:End()},,)}
			oDlgSXB:lCentered := .T.
			oDlgSXB:Activate(,,,.T.)

			VAR_IXB := cCodRet

			FreeObj(oDlgSXB)
			FreeObj(oListBox)
			FreeObj(oCmbOrdem)
		EndIf
	EndIf

	If !lValid .And. !(cCodRet == cValOrig)
		If cOpc $ ("1|2") .And. !Empty(M->RA_CODMUN) // Limpia contenido Localidad
			M->RA_CODMUN := Space(GetSx3Cache("RA_CODMUN", "X3_TAMANHO"))
			If cOpc == "1" .And. !Empty(M->RA_PROVINC) // Limpia contenido Departamento
				M->RA_PROVINC := Space(GetSx3Cache("RA_PROVINC", "X3_TAMANHO"))
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} fS98Pesq
	Funcion para busqueda por código de Departamento, Distrito o Localidad.
	@type Static Function
	@author oscar.lopez
	@since 02/01/2025
	@version 1.0
	@param oCmbOrdem, objeto, Objeto MSCOMBOBOX de TDialog.
	@param aDepDisLoc, arreglo, Lista de Departamentos, Distritos o Localidades para TDialog.
	@param oListBox, objeto, Objeto TWBrowse para TDialog.
	@param cPesq, caracter, Valor a buscar en objeto TDialog.
	@return True
	@example
		fS98Pesq(oCmbOrdem,aDepDisLoc,oListBox,cPesq)
	/*/
Static Function fS98Pesq(oCmbOrdem,aDepDisLoc,oListBox,cPesq)

	Local nPos		:= 0 
	Local nSize		:= 0
	Local nOrdem	:= 0

	Default oCmbOrdem	:= Nil
	Default aDepDisLoc	:= {}
	Default oListBox	:= Nil
	Default cPesq		:= ""

	nOrdem	:= oCmbOrdem:nAt
	cPesq := AllTrim(Upper(cPesq))
	nSize := Len(cPesq)

	If nOrdem == 1 //Por codigo
		nPos := aScan(aDepDisLoc,{|x| Left(AllTrim(Upper(x[1])),nSize) == cPesq })
	ElseIf nOrdem == 2 //Por Descricao
		nPos := aScan(aDepDisLoc,{|x| Left(AllTrim(Upper(x[2])),nSize) == cPesq })
	EndIf

	If nPos > 0
		oListBox:nAt := nPos
		oListBox:Refresh()
	EndIf

Return .T.

/*/{Protheus.doc} fS98Ordem
	Orden de registros para consulta de fS98LNSPar().
	@type Static Function
	@author oscar.lopez
	@since 02/01/2025
	@version version
	@param oCmbOrdem, objeto, Objeto MSCOMBOBOX de TDialog.
	@param aDepDisLoc, arreglo, Lista de Departamentos, Distritos o Localidades para TDialog.
	@param oListBox, objeto, Objeto TWBrowse para TDialog.
	@return True
	@example
		fS98Ordem(oCmbOrdem,aDepDisLoc,oListBox)
	/*/
Static Function fS98Ordem(oCmbOrdem,aDepDisLoc,oListBox)

	Local nOrdem := 0 

	Default oCmbOrdem	:= Nil
	Default aDepDisLoc	:= {}
	Default oListBox	:= Nil

	nOrdem := oCmbOrdem:nAt

	If nOrdem == 1 //Ordena pelo codigo
		ASort(aDepDisLoc,,,{|x,y| x[1] < y[1] })
	ElseIf nOrdem == 2 //Ordena por Descrição
		ASort(aDepDisLoc,,,{|x,y| x[2] < y[2] })
	EndIf

	oListBox:SetArray(aDepDisLoc)
	oListBox:bLine := {||{	aDepDisLoc[oListBox:nAt][1],;
							aDepDisLoc[oListBox:nAt][2]}}
	oListBox:GoTop()
	oListBox:Refresh()

Return .T.
