#Include "PROTHEUS.CH" 
#Include "GPER1357.CH"
#Include "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออหออออออออออหอออออออหออออออออออออออออออออออออออออออออหอออออออหอออออออออออออปฑฑ
ฑฑบPrograma  บ GPER1357 บ Autor บ Laura Medina                   บ Fecha บ  19/03/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออสออออออออออออออออออออออออออออออออสอออออออสอออออออออออออนฑฑ
ฑฑบDesc.     บArchivo 1357: 1-Informe 1357 y 2-Archivo .txt - Argentina                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       บ SIGAGPE                                                                 บฑฑ
ฑฑฬออออออออออสอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                 ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  บฑฑ
ฑฑฬออออออออออออออออหออออออออออออหออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ  Programador   บ    Data    บ   Issue    บ  Motivo da Alteracao                    บฑฑ
ฑฑฬออออออออออออออออลออออออออออออลออออออออออออลอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบalejandro.parralesบ29/09/2023บDNOMI-1548  บ Actualizacion a versi๓n 8.0             บฑฑ
ฑฑศออออออออออออออออสออออออออออออสออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPER1357()
	
	Local oFld			:= Nil
	Local aCombo		:= {}

	Private cCombo		:= ""
	Private oDlg		:= Nil
	Private oCombo		:= Nil
	Private cProceso	:= ""
	Private cProced		:= ""
	Private cPeriodo	:= ""
	Private cNroPago	:= ""
	Private cCodMat		:= ""
	Private cIniCC		:= ""
	Private cFinCC		:= ""
	Private cPerFis		:= ""
	Private cLugar		:= ""
	Private dFechEmi	:= ""
	Private cRespons	:= ""
	Private nTipoPre	:= 0
	Private cSecuenc	:= ""
	Private cRutaArc	:= ""
	Private cPictVal	:= "@E 999999999999.99"
	Private cPictV17	:= "@E 99999999999999.99"
	Private cPicSRD		:= PesqPict("SRD","RD_VALOR")
	Private nArchTXT	:= 0
	Private lGenTXT		:= .F.
	Private lGenPlan	:= .F.
	Private nGenPDF		:= 0
	Private aRubros		:= {}
	Private cConceRB	:= GetMv("MV_1357CRB",,"")
	Private nValorRB	:= GetMv("MV_1357VRB",,0)

	aAdd( aCombo, STR0003 ) //"1. Formulario 1357"
 	aAdd( aCombo, STR0004 ) //"2. Archivo 1357"
	aAdd( aCombo, STR0164 ) //"3. Planilla 1357"

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0,0 TO 125,450 OF oDlg PIXEL //"F - 1357"

	@ 006,006 TO 045,170 LABEL STR0002 OF oDlg PIXEL //"Indique la opci๓n a generar:"
	@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 100,8 PIXEL OF oFld
	
	@ 009,180 BUTTON STR0005 SIZE 036,016 PIXEL ACTION FDefArcGen(Subs(cCombo,1,1)) //"Aceptar"
	@ 029,180 BUTTON STR0006 SIZE 036,016 PIXEL ACTION oDlg:End() //"Salir"

	ACTIVATE MSDIALOG oDlg CENTER

Return

/*/{Protheus.doc} FDefArcGen
	Funci๓n que define el tipo de archivo a generar: 1 - Formulario / 2 - Archivo / 3 - Planilla.

	@type  Static Function
	@author marco.rivera
	@since 26/08/2024
	@version 1.0
	@param cOpcion, Caracter, Contiene la opci๓n seleccionada por el usuario.
	@return lRet, L๓gica, Retorna si la funci๓n es Valida (.T.) o Invalida (.F.).
	@example
	FDefArcGen(cOpcion)
/*/
Static Function FDefArcGen(cOpcion)

	Local lRet 		:= .T.

	Default cOpcion	:= "1"

	//Carga registros de la tabla alfanum้rica S044 - F1357 - LIQUIDACIำN IAG 4TA CAT
	aRubros := CargaTabla("S044")
	
	If Len(aRubros) == 0 //Si no hay registros en la tabla S044
		lRet := .F.
		Aviso(OemToAnsi(STR0007), OemToAnsi(STR0091), {STR0009} ) //"Atenci๓n" - "No se encontr๓ informaci๓n en la tabla alfanum้rica S044." - "OK"
	Else
		If cOpcion == "1" //Se selecciona generaci๓n del Formulario
			Form1357(cOpcion)
		ElseIf cOpcion $ "2/3" //Se selecciona generaci๓n del Archivo o Planilla
			//NOTA: Remover la validaci๓n al finalizar el desarrollo completo de la planilla.
			If cOpcion == "3"
				MsgInfo(STR0137, STR0138) //"La opci๓n seleccionada, se encuentra en fase de desarrollo." - "NOTA"
			EndIf
			Arch1357(cOpcion)
		EndIf
	Endif
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณForm1357    บAutor  ณLaura Media       บFecha ณ  19/03/2020  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n que genera el formulario 1357.                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Form1357(cOpcion)

Local cPerg		:= "GPER1357"
Local lRet		:= .T.

Default cOpcion	:= "1"

Pergunte(cPerg, .F.)

If !Pergunte(cPerg,.T.)
	Return .F. 
Endif

MakeSqlExpr(cPerg)

cProceso:= MV_PAR01
cProced := MV_PAR02
cPeriodo:= MV_PAR03
cNroPago:= MV_PAR04
cCodMat := MV_PAR05
cIniCC  := MV_PAR06
cFinCC  := MV_PAR07
cPerFis := MV_PAR08
cLugar  := MV_PAR09
dFechEmi:= MV_PAR10
cRespons:= MV_PAR11

nGenPDF	:= 0

Processa({ || ProcFyA(cOpcion) })

If nGenPDF >= 1 
	Aviso( OemToAnsi(STR0007), Iif(nGenPDF==1,  OemToAnsi(STR0017), OemToAnsi(STR0110)), {STR0009} ) //"Archivo generado con ้xito!." o "Archivos generados con ้xito!." 
ElseIf nGenPDF == 0
	Aviso(OemToAnsi(STR0007), OemToAnsi(Replace(STR0018, STR0116, STR0117)), {STR0009} ) //"No se encontr๓ informaci๓n para generar el archivo 1357." - "archivo" - "formulario"
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfPrinReport บAutor  ณAdrian Perez     บFecha   ณ  18/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Imprime Reporte       									   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function fPrinReport(aData, cPerRCH)
Local nX		:= 0
Local cPatchPDF := ""
Local nResImpr 	:= 1  //Resultado de impresi๓n
Private	nH303 	:= nH304:= nH305:= nH306:= nH307:= nH308:= nD309:= nH340:= nH341:= nH342:= nH310:= nH328:= nH311:= nH312:= nD309:= 0       
Private	nH338	:= nH343:= nH344:= nH345:= nH347:= nH346:= nH329:= nH330:= nH331:= nH332:= nH314:= nH315:= nH316:= nH317:= nH318:= 0
Private nD319	:= nD320:= nH348:= nH349:= nH350:= nH348:= nH333:= nH322:= nD323:= nD324:= nH339:= nH351:= nH352:= nH353:= nH355:= 0
Private	nH354	:= nH334:= nH335:= nH336:= nH337:= nH325:= nH326:= nH327:= nH356:= nH357:= nH358:= nH359:= nH360:= nH361:= nH362:= 0
Private nH363	:= nH364:= nH365:= nH366:= nH367:= 0
Private nD403	:= nD404:= nD405:= nD406:= nD407:= nD408:= nD409:= nD410:= nD411:= nD412:= nD413:= nD414:= nD415:= nD416:= nD417:= 0
Private nD418	:= nD419:= nD420:= nD421:= nD422:= nD423:= nD424:= nD425:= nD426:= nD427:= nD432:= nD433:= nD434:= nD435:= nD436:= 0
Private nD437	:= 0
Private nD503	:= nD509:= nD506:= nD507:= nD515:= nD508:= nD516:= nD504:= nD505:= nD517:= nD518:= nD510:= nD514:= nD519:= nD520:=0
Private nD521	:= nD522:= 0
Private nG603	:= nG604:= nG605:= nG606:= nD607:= nG608:= 0
Private nG714	:= 0

Default aData 	:= {}
Default cPerRCH := ""
			
	For nX=1 to len(aData)
		If  nResImpr == 1
			GenPDFxEm(aData[nX], nX, @cPatchPDF, @nResImpr, cPerRCH)
		Else 
			nGenPDF	:= -1
			Exit
		Endif
	Next			
	If  nResImpr == 2 .And. nGenPDF == 1
		nGenPDF	:= -1
	Endif
								
Return


Static Function GenPDFxEm(aData,nX,cPatchPDF,nResImpr,cPerRCH)
Local oPrinter
Local cFileGen 	:= space(100) 

Default aData 		:= {}
Default nX			:= 0
Default cPatchPDF	:= ""
Default nResImpr 	:= 0
Default cPerRCH		:= ""

cFileGen :=  aData[1,1,4] + aData[1,1,3] + "_" + Substr(cPerRCH,1,4)

	oPrinter:= FWMSPrinter():New(cFileGen,6,.F.,GetClientDir(),Iif(nX == 1, .F., .T.))  //inicializa el objeto
	oPrinter:setDevice( IMP_PDF )   	//selecciona el medio de impresi๓n
	oPrinter:SetMargin(40,10,40,10) 	//margenes del documento
	oPrinter:SetPortrait()           	//orientaci๓n de pแgina modo retrato =  Horizontal

	If  nX == 1		
		nResImpr:= oPrinter:nModalResult 	//obtiene nModalResult=1 confimada --- nModalResult=2 cancelada
		cPatchPDF := oPrinter:CPATHPDF
	Else
		oPrinter:cPathPDF := cPatchPDF
	Endif
	
	If  nResImpr == 1
		fReport(@oPrinter,aData,nX)		
		oPrinter:SetViewPDF(.F.)
		oPrinter:Print()	
		If  File(GetClientDir() + cFileGen +".rel")	
			FERASE(GetClientDir() + cFileGen + ".rel")	
		Endif		
	Endif

FreeObj(oPrinter)
oPrinter := Nil

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfReport   บAutor  ณAdrian Perez     บFecha     ณ  18/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Estructura del reporte 									   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function fReport(oPrinter,aData,nVez)
	
	Local aAux		:= {}
	Local nR		:= 50
	Local nB		:= 0	
	Local cStartPath:= GetSrvProfString("Startpath","")
	Local aDatos	:= {}
	Local aAuxDat	:= {}
	Local nSalto	:= 0
	Local lBoxDoble	:= .T.
	
	Private nAncho	:= 13
	Private nRR		:= 10
	Private oFontP
	Private oFontT
	
	Default nVez	:= 0
	Default aData	:= {}
   						 
			oFontT 		:= TFont():New('Arial',,-12,.T.,.T.) //Fuente del Titulo
			oFontP 		:= TFont():New('Arial',,-10,.T.)     //Fuente del Pแrrafo
		
			oPrinter:StartPage() 
			
			//LOGO
			oPrinter:Box( nR-35,10,100, 100)
			oPrinter:SayBitmap((nR-35)+10,15,cStartPath+"lgrl"+FwCodEmp("SM0")+".bmp",80,40)
			//FIN LOGO
			nR+=5
			//"CERTIFICADO DE LIQUIDACIำN DE IMPUESTO A LAS GANANCIAS."
			oPrinter:Say(nR,110,STR0019 , oFontP) 	
			nR+=15
			//"4TA.CATEGORIA. RELACIำN DE DEPENDENCIA."
			oPrinter:Say(nR,110,STR0020 , oFontP)	
			nR+=45
			//"Fecha:"
			oPrinter:Say(nR,10,STR0021 , oFontP)
			oPrinter:Say(nR,110,DTOC(dFechEmi) , oFontP)
			
			nR+=15
			aAux:=aData[1,1]
			
			//"Beneficiario:"
			oPrinter:Say(nR,10,STR0022  , oFontP)
			oPrinter:Say(nR,70,aAux[1] , oFontP)
			oPrinter:Say(nR,150,aAux[2] , oFontP)
			oPrinter:Say(nR,400,aAux[3] , oFontP)
			
			nR+=15
			//"Agente de Retenci๓n:"
			oPrinter:Say(nR,10,STR0023 , oFontP)
			oPrinter:Say(nR,120,SM0->M0_CGC , oFontP)
			oPrinter:Say(nR,250,SM0->M0_NOME , oFontP)
			
			nR+=15
			//"Periodo Fiscal:"
			oPrinter:Say(nR,10,STR0024 , oFontP)
			oPrinter:Say(nR,100,cPerFis , oFontP)
			
			nR+=50
			nB:=nR-20
			//Encabezado1: "REMUNERACIONES"
			aadd(aAuxDat,{STR0025})
			
			nSalto:=fReportHead(@nR,@nB,@oPrinter,	aAuxDat,.F.)
			
			//Encabezado2: "Abonadas por el agente de retenci๓n"
			aAuxDat:={}
			nR+=nSalto
			aadd(aAuxDat,{STR0028})
			fReportHead(@nR,@nB,@oPrinter,	aAuxDat,.F.)
			
			aAux:={}
			//REMUNERACIONES
			//1=Empleados, 2=Remuneraciones[1=Valor,2=C๓digo], 3=Deducciones, 4=Deduccion23 y 5=CalcImpto
			aAux:=aData[2]
			aDatos:={}
			If	nVez == 1
				nH303	:= aScan(aAux, {|x| x[2] == "H303"})
				nH304	:= aScan(aAux, {|x| x[2] == "H304"})
				nH305	:= aScan(aAux, {|x| x[2] == "H305"})
				nH306	:= aScan(aAux, {|x| x[2] == "H306"})
				nH307	:= aScan(aAux, {|x| x[2] == "H307"})
				nH308	:= aScan(aAux, {|x| x[2] == "H308"})
				nD309	:= aScan(aAux, {|x| x[2] == "D309"})
				nH340	:= aScan(aAux, {|x| x[2] == "H340"})
				nH341	:= aScan(aAux, {|x| x[2] == "H341"})
				nH342	:= aScan(aAux, {|x| x[2] == "H342"})
				nH310	:= aScan(aAux, {|x| x[2] == "H310"})
				nH328	:= aScan(aAux, {|x| x[2] == "H328"})
				nH311	:= aScan(aAux, {|x| x[2] == "H311"})
				nH312	:= aScan(aAux, {|x| x[2] == "H312"})
				nD309	:= aScan(aAux, {|x| x[2] == "D309"})
				nH338	:= aScan(aAux, {|x| x[2] == "H338"})
				nH343	:= aScan(aAux, {|x| x[2] == "H343"}) 
				nH344	:= aScan(aAux, {|x| x[2] == "H344"})
				nH345	:= aScan(aAux, {|x| x[2] == "H345"})
				nH347	:= aScan(aAux, {|x| x[2] == "H347"})
				nH346	:= aScan(aAux, {|x| x[2] == "H346"})
				nH329	:= aScan(aAux, {|x| x[2] == "H329"})
				nH330	:= aScan(aAux, {|x| x[2] == "H330"})
				nH331	:= aScan(aAux, {|x| x[2] == "H331"})
				nH332	:= aScan(aAux, {|x| x[2] == "H332"})										
				nH314	:= aScan(aAux, {|x| x[2] == "H314"})
				nH315	:= aScan(aAux, {|x| x[2] == "H315"})
				nH316	:= aScan(aAux, {|x| x[2] == "H316"})
				nH317	:= aScan(aAux, {|x| x[2] == "H317"})
				nH318	:= aScan(aAux, {|x| x[2] == "H318"})
				nD319	:= aScan(aAux, {|x| x[2] == "D319"})
				nD320	:= aScan(aAux, {|x| x[2] == "D320"})	
				nH348	:= aScan(aAux, {|x| x[2] == "H348"})
				nH349	:= aScan(aAux, {|x| x[2] == "H349"})
				nH350	:= aScan(aAux, {|x| x[2] == "H350"})
				nH348	:= aScan(aAux, {|x| x[2] == "H348"})
				nH333	:= aScan(aAux, {|x| x[2] == "H333"})
				nH322	:= aScan(aAux, {|x| x[2] == "H322"})		
				nD323	:= aScan(aAux, {|x| x[2] == "D323"})
				nD324	:= aScan(aAux, {|x| x[2] == "D324"})
				nH339	:= aScan(aAux, {|x| x[2] == "H339"})		
				nH351	:= aScan(aAux, {|x| x[2] == "H351"})
				nH352	:= aScan(aAux, {|x| x[2] == "H352"})
				nH353	:= aScan(aAux, {|x| x[2] == "H353"})
				nH355	:= aScan(aAux, {|x| x[2] == "H355"})
				nH354	:= aScan(aAux, {|x| x[2] == "H354"})
				nH334	:= aScan(aAux, {|x| x[2] == "H334"})
				nH335	:= aScan(aAux, {|x| x[2] == "H335"})
				nH336	:= aScan(aAux, {|x| x[2] == "H336"})
				nH337	:= aScan(aAux, {|x| x[2] == "H337"})						
				nH325	:= aScan(aAux, {|x| x[2] == "H325"})
				nH326	:= aScan(aAux, {|x| x[2] == "H326"})
				nH327	:= aScan(aAux, {|x| x[2] == "H327"})
				//Actualizaci๓n v8.0
				nH356	:= aScan(aAux, {|x| x[2] == "H356"})
				nH357	:= aScan(aAux, {|x| x[2] == "H357"})
				nH358	:= aScan(aAux, {|x| x[2] == "H358"})
				nH359	:= aScan(aAux, {|x| x[2] == "H359"})
				nH360	:= aScan(aAux, {|x| x[2] == "H360"})
				nH361	:= aScan(aAux, {|x| x[2] == "H361"})
				nH362	:= aScan(aAux, {|x| x[2] == "H362"})
				nH363	:= aScan(aAux, {|x| x[2] == "H363"})
				nH364	:= aScan(aAux, {|x| x[2] == "H364"})
				nH365	:= aScan(aAux, {|x| x[2] == "H365"})
				nH366	:= aScan(aAux, {|x| x[2] == "H366"})
				nH367	:= aScan(aAux, {|x| x[2] == "H367"})
			Endif
			
			aadd(aDatos,{STR0029	,Iif(nH303 > 0,aAux[nH303,1],0)}) //"Remuneraci๓n bruta gravada"	
			aadd(aDatos,{STR0030	,Iif(nH304 > 0,aAux[nH304,1],0)}) //"Retribuciones no habituales gravadas"			
			aadd(aDatos,{STR0031	,Iif(nH305 > 0,aAux[nH305,1],0)}) //"SAC primera cuota gravado"
			aadd(aDatos,{STR0032	,Iif(nH306 > 0,aAux[nH306,1],0)}) //"SAC segunda cuota gravado"			
			aadd(aDatos,{STR0033	,Iif(nH307 > 0,aAux[nH307,1],0)}) //"Horas extras remuneraci๓n gravada"
			aadd(aDatos,{STR0034	,0}) //"Movilidad y viแticos remuneraci๓n gravada"
			aadd(aDatos,{STR0035	,Iif(nD309 > 0,aAux[nD309,1],0)}) //"Material didแctico personal docente remuneraci๓n gravada"
			aadd(aDatos,{STR0026	,Iif(nH340 > 0,aAux[nH340,1],0)}) //"Bonos de productividad gravados"
			aadd(aDatos,{STR0027	,Iif(nH341 > 0,aAux[nH341,1],0)}) //"Fallos de caja gravados "
			aadd(aDatos,{STR0092	,Iif(nH342 > 0,aAux[nH342,1],0)}) //"Conceptos de similar naturaleza gravados"
			aadd(aDatos,{STR0036	,Iif(nH310 > 0,aAux[nH310,1],0)}) //"Remuneraci๓n exenta o no alcanzada"
			aadd(aDatos,{STR0094	,Iif(nH328 > 0,aAux[nH328,1],0)}) //"Retribuciones no habituales exentas o no alcanzadas"
			aadd(aDatos,{STR0037	,Iif(nH311 > 0,aAux[nH311,1],0)}) //"Horas extras remuneraci๓n exenta"
			aadd(aDatos,{STR0038	,0}) //"Movilidad y viแticos remuneraci๓n exenta o no alcanzada"
			aadd(aDatos,{STR0039	,Iif(nD309 > 0,aAux[nD309,1],0)}) //"Material didแctico personal docente remuneraci๓n exenta o no alcanzada"	
			aadd(aDatos,{STR0095	,Iif(nH338 > 0,aAux[nH338,1],0)}) //"Remuneraci๓n exenta Ley 27549"
			aadd(aDatos,{STR0096	,Iif(nH343 > 0,aAux[nH343,1],0)}) //"Bonos de productividad exentos"
			aadd(aDatos,{STR0097	,Iif(nH344 > 0,aAux[nH344,1],0)}) //"Fallos de caja exentos"
			aadd(aDatos,{STR0098	,Iif(nH345 > 0,aAux[nH345,1],0)}) //"Conceptos de similar naturaleza exentos"
			aadd(aDatos,{STR0099	,Iif(nH347 > 0,aAux[nH347,1],0)}) //"Suplementos particulares artํculo 57 de la Ley 19.101 exentos"
			aadd(aDatos,{STR0100	,Iif(nH346 > 0,aAux[nH346,1],0)}) //"Compensaci๓n gastos teletrabajo exentos"
			aadd(aDatos,{STR0101	,Iif(nH329 > 0,aAux[nH329,1],0)}) //"SAC primera cuota – Exento o No alcanzado"
			aadd(aDatos,{STR0102	,Iif(nH330 > 0,aAux[nH330,1],0)}) //"SAC segunda cuota – Exento o No alcanzado"
			aadd(aDatos,{STR0103	,Iif(nH331 > 0,aAux[nH331,1],0)}) //"Ajustes perํodos anteriores - Remuneraci๓n gravada"
			aadd(aDatos,{STR0104	,Iif(nH332 > 0,aAux[nH332,1],0)}) //"Ajuste perํodos anteriores - Remuneraci๓n exenta / no alcanzada"
						
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			//Encabezado3: "Otros empleos"
			aAuxDat:={}
			aadd(aAuxDat,{STR0040})
			fReportHead(@nR,@nB,@oPrinter,aAuxDat,.F.)
			aAuxDat:={}
			
			aDatos:={}			
			aadd(aDatos,{STR0029	,Iif(nH314 > 0,aAux[nH314,1],0)}) //"Remuneraci๓n bruta gravada"			
			aadd(aDatos,{STR0030	,Iif(nH315 > 0,aAux[nH315,1],0)}) //"Retribuciones no habituales gravadas"
			aadd(aDatos,{STR0031	,Iif(nH316 > 0,aAux[nH316,1],0)}) //"SAC primera cuota gravado"
			aadd(aDatos,{STR0032	,Iif(nH317 > 0,aAux[nH317,1],0)}) //"SAC segunda cuota gravado"
			aadd(aDatos,{STR0033	,Iif(nH318 > 0,aAux[nH318,1],0)}) //"Horas extras remuneraci๓n gravada"
			aadd(aDatos,{STR0034	,0}) //"Movilidad y viแticos remuneraci๓n gravada"
			aadd(aDatos,{STR0035	,Iif(nD320 > 0,aAux[nD320,1],0)}) //"Material didแctico personal docente remuneraci๓n gravada"	
			aadd(aDatos,{STR0026	,Iif(nH348 > 0,aAux[nH348,1],0)}) //"Bonos de productividad gravados"
			aadd(aDatos,{STR0027	,Iif(nH349 > 0,aAux[nH349,1],0)}) //"Fallos de caja gravados "
			aadd(aDatos,{STR0092	,Iif(nH350 > 0,aAux[nH350,1],0)}) //"Conceptos de similar naturaleza gravados"
			aadd(aDatos,{STR0036	,Iif(nH348 > 0,aAux[nH348,1],0)}) //"Remuneraci๓n exenta o no alcanzada"
			aadd(aDatos,{STR0094	,Iif(nH333 > 0,aAux[nH333,1],0)}) //"Retribuciones no habituales exentas o no alcanzadas"
			aadd(aDatos,{STR0037	,Iif(nH322 > 0,aAux[nH322,1],0)}) //"Horas extras remuneraci๓n exenta"	
						
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			aDatos:={}	
			aadd(aDatos,{STR0038	,0}) //"Movilidad y viแticos remuneraci๓n exenta o no alcanzada"
			aadd(aDatos,{STR0039	,Iif(nD324 > 0,aAux[nD324,1],0)}) //"Material didแctico personal docente remuneraci๓n exenta o no alcanzada"
			aadd(aDatos,{STR0095	,Iif(nH339 > 0,aAux[nH339,1],0)}) //"Remuneraci๓n exenta Ley 27549"		
			aadd(aDatos,{STR0096	,Iif(nH351 > 0,aAux[nH351,1],0)}) //"Bonos de productividad exentos"
			aadd(aDatos,{STR0097	,Iif(nH352 > 0,aAux[nH352,1],0)}) //"Fallos de caja exentos"
			aadd(aDatos,{STR0098	,Iif(nH353 > 0,aAux[nH353,1],0)}) //"Conceptos de similar naturaleza exentos"
			aadd(aDatos,{STR0099	,Iif(nH355 > 0,aAux[nH355,1],0)}) //"Suplementos particulares artํculo 57 de la Ley 19.101 exentos"
			aadd(aDatos,{STR0100	,Iif(nH354 > 0,aAux[nH354,1],0)}) //"Compensaci๓n gastos teletrabajo exentos"
			aadd(aDatos,{STR0101	,Iif(nH334 > 0,aAux[nH334,1],0)}) //"SAC primera cuota – Exento o No alcanzado"
			aadd(aDatos,{STR0102	,Iif(nH335 > 0,aAux[nH335,1],0)}) //"SAC segunda cuota – Exento o No alcanzado"
			aadd(aDatos,{STR0103	,Iif(nH336 > 0,aAux[nH336,1],0)}) //"Ajustes perํodos anteriores - Remuneraci๓n gravada"
			aadd(aDatos,{STR0104	,Iif(nH337 > 0,aAux[nH337,1],0)}) //"Ajuste perํodos anteriores - Remuneraci๓n exenta / no alcanzada"				
			//Actualizaci๓n v8.0
			aadd(aDatos,{STR0118	,Iif(nH356 > 0,aAux[nH356,1],0),"U"}) //"Cantidad Bonos de productividad"
			aadd(aDatos,{STR0119	,Iif(nH357 > 0,aAux[nH357,1],0),"U"}) //"Cantidad de Fallos de caja"
			aadd(aDatos,{STR0120	,Iif(nH358 > 0,aAux[nH358,1],0),"U"}) //"Cantidad de Conceptos de similar naturaleza"
			aadd(aDatos,{STR0121	,Iif(nH359 > 0,aAux[nH359,1],0),"U"}) //"Cantidad otros empleos bonos de productividad"
			aadd(aDatos,{STR0122	,Iif(nH360 > 0,aAux[nH360,1],0),"U"}) //"Cantidad de otros empleos fallos de caja"
			aadd(aDatos,{STR0123	,Iif(nH361 > 0,aAux[nH361,1],0),"U"}) //"Cantidad de otros empleos conceptos de similar naturaleza"
			aadd(aDatos,{STR0124	,Iif(nH362 > 0,aAux[nH362,1],0)}) //"Movilidad remuneraci๓n gravada"
			aadd(aDatos,{STR0125	,Iif(nH363 > 0,aAux[nH363,1],0)}) //"Viแticos remuneraci๓n gravada"
			aadd(aDatos,{STR0126	,Iif(nH364 > 0,aAux[nH364,1],0)}) //"Compensaci๓n anแlogos remuneraci๓n gravada"
			aadd(aDatos,{STR0127	,Iif(nH365 > 0,aAux[nH365,1],0)}) //"Remuneraci๓n otros empleos - movilidad remuneraci๓n gravada"
			aadd(aDatos,{STR0128	,Iif(nH366 > 0,aAux[nH366,1],0)}) //"Remuneraci๓n otros empleos - viแticos remuneraci๓n gravada"
			aadd(aDatos,{STR0129	,Iif(nH367 > 0,aAux[nH367,1],0)}) //"Remuneraci๓n otros empleos - compensaci๓n anแlogos remuneraci๓n gravada"

			nR:=fChangePage(nR,@oPrinter)
			nB:=nR-20
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			aDatos:={}
			//totales			
			aadd(aDatos,{STR0087	,Iif(nH325 > 0,aAux[nH325,1],0)}) //"TOTAL REMUNERACIำN GRAVADA"
			aadd(aDatos,{STR0088	,Iif(nH326 > 0,aAux[nH326,1],0)}) //"TOTAL REMUNERACIำN EXENTA O NO ALCANZADA"
			aadd(aDatos,{STR0089	,Iif(nH327 > 0,aAux[nH327,1],0)}) // "TOTAL REMUNERACIONES"
			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			//"DEDUCCIONES GENERALES"	
			nR+=5					
			oPrinter:Box(nR,010,nB,579)
			oPrinter:Say(nR-15,012,STR0090 , oFontT)
			
			nR+=nAncho-5
			nB+=nAncho
			
			aDatos:={}
			
			aAux:={}
			aAux:=aData[3]
			
			If	nVez == 1
				nD403	:= aScan(aAux, {|x| x[2] == "D403"})
				nD404	:= aScan(aAux, {|x| x[2] == "D404"})			
				nD405	:= aScan(aAux, {|x| x[2] == "D405"}) 
				nD406	:= aScan(aAux, {|x| x[2] == "D406"})
				nD407	:= aScan(aAux, {|x| x[2] == "D407"})
				nD408	:= aScan(aAux, {|x| x[2] == "D408"}) 
				nD409	:= aScan(aAux, {|x| x[2] == "D409"})
				nD410	:= aScan(aAux, {|x| x[2] == "D410"}) 
				nD411	:= aScan(aAux, {|x| x[2] == "D411"})
				nD412	:= aScan(aAux, {|x| x[2] == "D412"})
				nD413	:= aScan(aAux, {|x| x[2] == "D413"})
				nD414	:= aScan(aAux, {|x| x[2] == "D414"})
				nD415	:= aScan(aAux, {|x| x[2] == "D415"})
				nD416	:= aScan(aAux, {|x| x[2] == "D416"})
				nD417	:= aScan(aAux, {|x| x[2] == "D417"})
				nD418	:= aScan(aAux, {|x| x[2] == "D418"})
				nD419	:= aScan(aAux, {|x| x[2] == "D419"})
				nD420	:= aScan(aAux, {|x| x[2] == "D420"})
				nD421	:= aScan(aAux, {|x| x[2] == "D421"})
				nD422	:= aScan(aAux, {|x| x[2] == "D422"})
				nD423	:= aScan(aAux, {|x| x[2] == "D423"})
				nD424	:= aScan(aAux, {|x| x[2] == "D424"})
				nD425	:= aScan(aAux, {|x| x[2] == "D425"})
				nD426	:= aScan(aAux, {|x| x[2] == "D426"})
				nD427	:= aScan(aAux, {|x| x[2] == "D427"})

				//Agregado para Versi๓n 6.0
				nD432	:= aScan(aAux, {|x| x[2] == "D432"}) //"Servicios educativos y las herramientas destinadas a esos efectos"
				
				//Actualizaci๓n v8.0
				nD433	:= aScan(aAux, {|x| x[2] == "D433"})
				nD434	:= aScan(aAux, {|x| x[2] == "D434"})
				nD435	:= aScan(aAux, {|x| x[2] == "D435"})
				nD436	:= aScan(aAux, {|x| x[2] == "D436"})

				//Actualizaci๓n v9.0
				nD437	:= aScan(aAux, {|x| x[2] == "D437"})

			Endif
			
			aadd(aDatos,{STR0041	,Iif(nD403 > 0,aAux[nD403,1],0)}) //"Aportes a fondos de jubilaciones, retiros, pensiones o subsidios que se destinen a cajas nacionales, provinciales o municipales"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
		
			aDatos:={}
			aadd(aDatos,{STR0041	,0}) //"Aportes a fondos de jubilaciones, retiros, pensiones o subsidios que se destinen a cajas nacionales, provinciales o municipales"
			aadd(aDatos,{STR0042	,Iif(nD404 > 0,aAux[nD404,1],0)}) //"por otros empleos" 			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP,lBoxDoble)
		
			aDatos:={}
			aadd(aDatos,{STR0043	,Iif(nD405 > 0,aAux[nD405,1],0)}) //"Aportes a obras sociales"
			aadd(aDatos,{STR0044	,Iif(nD406 > 0,aAux[nD406,1],0)}) //"Aportes a obras sociales por otros empleos "
			aadd(aDatos,{STR0045	,Iif(nD407 > 0,aAux[nD407,1],0)}) //"Cuota sindical "
			aadd(aDatos,{STR0046	,Iif(nD408 > 0,aAux[nD408,1],0)}) //"Cuota sindical por otros empleos"
			aadd(aDatos,{STR0047	,Iif(nD409 > 0,aAux[nD409,1],0)}) //"Cuotas m้dico asistenciales"
			aadd(aDatos,{STR0048	,Iif(nD410 > 0,aAux[nD410,1],0)}) //"Primas de seguro para el caso de muerte"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
		
			aDatos:={}
			aadd(aDatos,{STR0049	,0}) //"Primas de seguro por riesgo de muerte y de ahorro de seguros mixtos, excepto para los casos de seguros de retiro privados"
			aadd(aDatos,{STR0093	,Iif(nD411 > 0,aAux[nD411,1],0)}) //"administrados por entidades sujetas al control de la Superintendencia de Seguros de la Naci๓n."
			filas(@nR,@nB,@oPrinter,aDatos,oFontP,lBoxDoble)
		
			aDatos:={}
			aadd(aDatos,{STR0050	,0}) //"Aportes a planes de seguro de retiro privados administrados por entidades sujetas al control de la Superintendencia de Seguros de"
			aadd(aDatos,{STR0105	,Iif(nD412 > 0,aAux[nD412,1],0)}) //"la Naci๓n"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP,lBoxDoble)
		
			aDatos:={}
			aadd(aDatos,{STR0051	,Iif(nD413 > 0,aAux[nD413,1],0)}) //"Cuotapartes de fondos comunes de inversi๓n constituidos con fines de retiro"
			aadd(aDatos,{STR0052	,Iif(nD414 > 0,aAux[nD414,1],0)}) //"Gastos de sepelio"
			aadd(aDatos,{STR0053	,Iif(nD415 > 0,aAux[nD415,1],0)}) //"Gastos de amortizaci๓n e intereses de rodado de corredores y viajantes de comercio"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			aDatos:={}
			aadd(aDatos,{STR0054	,0}) //"Donaciones a fiscos nacionales, provinciales y municipales y a instituciones comprendidas los incisos e) y f) del artํculo 26 de la"
			aadd(aDatos,{STR0106	,Iif(nD416 > 0,aAux[nD416,1],0)}) //"Ley de Impuesto a las Ganancias"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP,lBoxDoble)
		
			aDatos:={}
			aadd(aDatos,{STR0055	,Iif(nD417 > 0,aAux[nD417,1],0)}) //"Descuentos obligatorios establecidos por ley nacional, provincial o municipal"
			aadd(aDatos,{STR0056	,Iif(nD418 > 0,aAux[nD418,1],0)}) //"Honorarios por servicios de asistencia sanitaria, m้dica y param้dica"
			aadd(aDatos,{STR0057	,Iif(nD419 > 0,aAux[nD419,1],0)}) //"Intereses de cr้ditos hipotecarios"
			aadd(aDatos,{STR0058	,Iif(nD420 > 0,aAux[nD420,1],0)}) //"Aportes al capital social o al fondo de riesgo de socios protectores de sociedades de garantํa recํproca"
			aadd(aDatos,{STR0059	,Iif(nD421 > 0,aAux[nD421,1],0)}) //"Aportes a Cajas Complementarias de Previsi๓n, Fondos Compensadores de Previsi๓n o similares"
			aadd(aDatos,{STR0060	,Iif(nD422 > 0,aAux[nD422,1],0)}) //"Alquiler de inmuebles destinados a casa habitaci๓n"
			aadd(aDatos,{STR0061	,Iif(nD423 > 0,aAux[nD423,1],0)}) //"Remuneraciones y Aportes a Empleados del Servicio Dom้stico"
			aadd(aDatos,{STR0062	,0}) //"Gastos de movilidad, viแticos y otras compensaciones anแlogas abonados por el empleador"
			aadd(aDatos,{STR0063	,Iif(nD425 > 0,aAux[nD425,1],0)}) //"Gastos por adquisici๓n de indumentaria y/o equipamiento de trabajo"
			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)			
			nR:=fChangePage(nR,@oPrinter)
			nB:=nR-20
			aDatos:={}
			
			aadd(aDatos, {STR0064, Iif(nD426 > 0, aAux[nD426, 1], 0)}) //"Otras deducciones"

			//Agregado para Versi๓n 6.0
			aadd(aDatos, {STR0111, IIf(nD432 > 0, aAux[nD432, 1], 0)}) //"Servicios educativos y las herramientas destinadas a esos efectos"
			
			//Actualizaci๓n v8.0
			aAdd(aDatos, {STR0130, IIf(nD433 > 0, aAux[nD433, 1], 0)}) //"Gtos mov. Abonados por el empleador"
			aAdd(aDatos, {STR0131, IIf(nD434 > 0, aAux[nD434, 1], 0)}) //"Gtos. Viแticos abonados por el empleador"
			aAdd(aDatos, {STR0132, IIf(nD435 > 0, aAux[nD435, 1], 0)}) //"Compensaci๓n anแloga"
			aAdd(aDatos, {STR0133, IIf(nD436 > 0, aAux[nD436, 1], 0),"U"}) //"Cantidad Compensaci๓n anแloga"

			//Actualizaci๓n v9.0
			aAdd(aDatos, {STR0134, IIf(nD437 > 0, aAux[nD437,1], 0)}) //"Alquileres de Inmuebles Destinados a su Casa Habitaci๓n - Art. 85 Inc. K (10%)"

			aAdd(aDatos, {STR0065, Iif(nD427 > 0, aAux[nD427, 1], 0)}) //"TOTAL DEDUCCIONES GENERALES"
			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			nR+=5
			oPrinter:Box(nR,010,nB,579)
			oPrinter:Say(nR-15,012,STR0066, oFontT) //"DEDUCCIONES PERSONALES"
			
			nR+=nAncho-5
			nB+=nAncho
								
			aDatos:={}
			aAux:={}
			aAux:=aData[4]
			
			If	nVez == 1
				nD503	:= aScan(aAux, {|x| x[2] == "D503"})
				nD509	:= aScan(aAux, {|x| x[2] == "D509"})
				nD506	:= aScan(aAux, {|x| x[2] == "D506"})
				nD507	:= aScan(aAux, {|x| x[2] == "D507"})
				nD515	:= aScan(aAux, {|x| x[2] == "D515"})
				nD508	:= aScan(aAux, {|x| x[2] == "D508"})
				nD516	:= aScan(aAux, {|x| x[2] == "D516"})
				nD504	:= aScan(aAux, {|x| x[2] == "D504"})
				nD505	:= aScan(aAux, {|x| x[2] == "D505"})					
				nD517	:= aScan(aAux, {|x| x[2] == "D517"})
				nD518	:= aScan(aAux, {|x| x[2] == "D518"})
				nD510	:= aScan(aAux, {|x| x[2] == "D510"})
				nD514	:= aScan(aAux, {|x| x[2] == "D514"})
				
				//Agregado para Versi๓n 6.0
				nD519	:= aScan(aAux, {|x| x[2] == "D519"})
				nD520	:= aScan(aAux, {|x| x[2] == "D520"})
				nD521	:= aScan(aAux, {|x| x[2] == "D521"})
				nD522	:= aScan(aAux, {|x| x[2] == "D522"})
			Endif
			
			aadd(aDatos,{STR0067	,Iif(nD503 > 0,aAux[nD503,1],0)}) //"Ganancia No Imponible"
			aadd(aDatos,{STR0070	,Iif(nD509 > 0,aAux[nD509,1],0)}) //"Cargas de Familia"
			aadd(aDatos,{STR0071	,Iif(nD506 > 0,aAux[nD506,1],0)}) //"C๓nyuge/ Uni๓n Convivencial"
			aadd(aDatos,{STR0072	,Iif(nD507 > 0,aAux[nD507,1],0), "U"}) //"Cantidad de hijos/as e hijastros/as"
			aadd(aDatos,{STR0107	,Iif(nD515 > 0,aAux[nD515,1],0), "U"}) //"Cantidad de hijos/as e hijastros/as incapacitados para el trabajo"
			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
						
			nR:=fChangePage(nR,@oPrinter)
			nB:=nR-20
			
			aDatos:={}
			aadd(aDatos,{STR0073	,Iif(nD508 > 0 .And. nD516 > 0, (aAux[nD508,1] + aAux[nD516,1]) , 0)}) //"Deducci๓n total hijos/as e hijastros/as"
			aadd(aDatos,{STR0068	,Iif(nD504 > 0,aAux[nD504,1],0)}) //"Deducci๓n Especial "
			aadd(aDatos,{STR0069	,Iif(nD505 > 0,aAux[nD505,1],0)}) //"Deducci๓n Especํfica"				
			aadd(aDatos,{STR0108	,Iif(nD517 > 0,aAux[nD517,1],0)}) //"Deducci๓n Especial Incrementada Primera parte del pen๚ltimo pแrrafo del inciso c) del artํculo 30 de la ley del gravamen"
			aadd(aDatos,{STR0109	,Iif(nD518 > 0,aAux[nD518,1],0)}) //"Deducci๓n Especial Incrementada Segunda parte del pen๚ltimo pแrrafo del inciso c) del artํculo 30 de la ley del gravamen"		
			
			//Agregado para Versi๓n 6.0
			aadd(aDatos, {STR0112, IIf(nD519 > 0, aAux[nD519, 1], 0), "U"}) //"Cantidad de Hijos/Hijastros al 100%"
			aadd(aDatos, {STR0113, IIf(nD520 > 0, aAux[nD520, 1], 0), "U"}) //"Cantidad de Hijos/Hijastros Incapacitados al 100%"
			aadd(aDatos, {STR0114, IIf(nD521 > 0, aAux[nD521, 1], 0), "U"}) //"Cantidad de Hijos entre 18 y 24 a๑os - Educaci๓n al 50%"
			aadd(aDatos, {STR0115, IIf(nD522 > 0, aAux[nD522, 1], 0), "U"}) //"Cantidad de Hijos entre 18 y 24 a๑os - Educaci๓n al 100%"
			
			aadd(aDatos,{STR0074	,Iif(nD510 > 0,aAux[nD510,1],0)}) //"TOTAL DEDUCCIONES PERSONALES"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			oPrinter:Box(nR,010,nB,579)
			oPrinter:Say(nR-nRR,012,STR0076, oFontT) //"DETERMINACIำN DEL IMPUESTO"
			
			nR+=nAncho
			nB+=nAncho
			
			aDatos:={}
			aadd(aDatos,{STR0075	,Iif(nD514 > 0,aAux[nD514,1],0)}) //"REMUNERACIำN SUJETA A IMPUESTO"
			
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)
			
			aDatos:={}
			aAux:={}
			aAux:=aData[5]
			
			If nVez == 1
				nG603	:= aScan(aAux, {|x| x[2] == "G603"})
				nG604	:= aScan(aAux, {|x| x[2] == "G604"})
				nG605	:= aScan(aAux, {|x| x[2] == "G605"})
				nG606	:= aScan(aAux, {|x| x[2] == "G606"})
				nD607	:= aScan(aAux, {|x| x[2] == "D607"})
				nG608	:= aScan(aAux, {|x| x[2] == "G608"})
			Endif
			
			aadd(aDatos,{STR0077	,Iif(nG603 > 0,aAux[nG603,1],0)}) //"Alํcuota aplicable artํculo 94 de la ley de impuesto a las ganancias %"
			aadd(aDatos,{STR0078	,Iif(nG604 > 0,aAux[nG604,1],0)}) //"Alํcuota aplicable sin incluir horas extras %"
			aadd(aDatos,{STR0079	,Iif(nG605 > 0,aAux[nG605,1],0)}) //"IMPUESTO DETERMINADO"
			aadd(aDatos,{STR0080	,Iif(nG606 > 0,aAux[nG606,1],0)}) //"Impuesto Retenido"
			aadd(aDatos,{STR0081	,Iif(nD607 > 0,aAux[nD607,1],0)}) //"Pagos a cuenta"
			aadd(aDatos,{STR0082	,Iif(nG608 > 0,aAux[nG608,1],0)}) //"SALDO A PAGAR"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)

			//Se define secci๓n de Informaci๓n Adicional.
			aDatos	:= {}
			aAux	:= {}
			aAux	:= aData[6]

			//Actualizaci๓n v9.5
			If nVez == 1
				nG714	:= aScan(aAux, {|x| x[2] == "G714"})
			Endif

			oPrinter:Box(nR,010,nB,579)
			oPrinter:Say(nR-nRR,012, STR0135, oFontT) //"INFORMACION ADICIONAL"
			
			nR+=nAncho
			nB+=nAncho

			aadd(aDatos,{STR0136, IIf(nG714 > 0, aAux[nG714, 1], 0)}) //"Diferencia por Aplicaci๓n Dto 473/2023"
			filas(@nR,@nB,@oPrinter,aDatos,oFontP)

			nR+=nAncho
			nB+=nAncho
			
			oPrinter:Say(nR-nRR,012,STR0083, oFontT) //"Se extiende el presente certificado para constancia del interesado"
			
			nR+=nAncho+20
			nB+=nAncho+20
			
			oPrinter:Say(nR+12,012,STR0084 , oFontT) //"Lugar y Fecha:"
			oPrinter:Say(nR+12,112,DTOC(dFechEmi) , oFontT)
			
			oPrinter:Say(nR+25,012,STR0085 , oFontT) //"Firma del Responsable:"
			
			oPrinter:Say(nR+38,012,STR0086 , oFontT) //"Identificaci๓n del Responsable: "
			oPrinter:Say(nR+38,252,cRespons , oFontT)
			
			oPrinter:EndPage() //fin pag
								
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfilas  บAutor  ณAdrian Perez     บFecha ณ  18/03/2020 	   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Dibuja las filas y celdas asi como la informacion		   บฑฑ
 			  en informe 1357. 											   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static function filas(nR,nB,oPrinter,aDatos,oFont,lBoxDoble)
Local nX		:=1
Local nCentro 	:=0
Local cVlrImp	:= ""

Default nR		:= 0
Default nB  	:= 0
Default aDatos	:= {}
Default lBoxDoble := .F. //Serแn 2 registros en aDatos

 	For nX := 1 To Len(aDatos) 
 		If  lBoxDoble 
 			If  nX == 1
 				nR+=13
 				//nB+=13
 				oPrinter:Box(nR,010,nB,579) 
 			Endif
 			oPrinter:Say(nR-(nRR+13),012,aDatos[nX][1] , oFont)
 		Else
			oPrinter:Box(nR,010,nB,579)
			oPrinter:Say(nR-nRR,012,aDatos[nX][1] , oFont)			
		Endif

		cVlrImp := PADL(Alltrim(Transform(Iif(!Empty(aDatos[nX][2]),aDatos[nX][2],0.00),cPicSRD)),14," ")

		nCentro:=5*(len(cVlrImp))
		
		If  lBoxDoble
			If  nX == 1
				oPrinter:Box(nR,480,nB,579)
			Else
				oPrinter:Say(nR-25,500,cVlrImp, oFont)
				oPrinter:Say(nR-25,483,"$", oFont)
				nR-=13
			Endif
		Else
			oPrinter:Box(nR,480,nB,579)
			oPrinter:Say(nR-nRR,500,cVlrImp, oFont)
			If Len(aDatos[nX]) > 2
				oPrinter:Say(nR-nRR,483,"", oFont)
			Else
				oPrinter:Say(nR-nRR,483,"$", oFont)
			EndIf	
		Endif
				
		nCentro:=0
		nR+=nAncho
		nB+=nAncho
	Next
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfReportHead   บAutor  ณAdrian Perez     บFecha ณ  18/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Insertar un encabezado de 3 celdas en Informe Archivo 1357. บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static function fReportHead(nR,nB,oPrinter,aDatos,lSalto)
Local nSalto:=0

Default nR	:= 0
Default nB  := 0
Default aDatos	:= {}
Default lSalto	:= .T.

	if lSalto
		nSalto:=50
	EndIf
	oPrinter:Box(nR+nSalto,010,nB,579)
	oPrinter:Say((nR-nRR),012,aDatos[1][1] , oFontT)
	
	nR+=nAncho
	nB+=nAncho+nSalto
	
return nSalto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfChangePage   บAutor  ณAdrian Perez     บFecha ณ  18/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n que cambia de pagina para Informe Archivo 1357.     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/
Static Function fChangePage(nRow,oPrinter)

Default nRow := 0

	If (nRow) >= 740
		nRow := 80
		oPrinter:EndPage()
		oPrinter:StartPage()
	EndIf
		
Return nRow

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArch1357   บAutor  ณLaura Medina        บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n que genera el Archivo 1357.                         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Arch1357(cOpcion)

Local cPerg		:= "GPER1357A"
Local lRet		:= .T.

Default cOpcion	:= "2"

Pergunte(cPerg, .F.)

If !Pergunte(cPerg, .T.)
	Return .F. 
Endif 

MakeSqlExpr(cPerg)

cProceso:= MV_PAR01
cProced := MV_PAR02
cPeriodo:= MV_PAR03
cNroPago:= MV_PAR04
cCodMat := MV_PAR05
cIniCC  := MV_PAR06
cFinCC  := MV_PAR07
nTipoPre:= MV_PAR08
cSecuenc:= MV_PAR09
cRutaArc:= AllTrim(MV_PAR10)

lGenTXT		:= .F.
lGenPlan	:= .F.

If Vl1537(cPeriodo, nTipoPre)
	
	Processa({ || ProcFyA(cOpcion) })

	If cOpcion == "2" //Generaci๓n de Archivo
		If lGenTXT
			Aviso(OemToAnsi(STR0007), OemToAnsi(STR0017), {STR0009} ) //"Atenci๓n" - "Archivo generado con ้xito!." - "OK"
		Else
			Aviso(OemToAnsi(STR0007), OemToAnsi(STR0018), {STR0009} ) //"Atenci๓n" - "No se encontr๓ informaci๓n para generar el archivo 1357." - "OK 
		Endif
		FClose(nArchTXT)
	ElseIf cOpcion == "3" //Generaci๓n de Planilla
		If lGenPlan
			Aviso(OemToAnsi(STR0007), OemToAnsi(STR0139), {STR0009} ) //"Atenci๓n" - "กPlanilla generada con ้xito!." - "OK"
		Else
			Aviso(OemToAnsi(STR0007), OemToAnsi(STR0140), {STR0009} ) //"Atenci๓n" - "No se encontr๓ informaci๓n para generar la planilla 1357." - "OK
		Endif
	EndIf
	
Else
	lRet := .F.	
Endif
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtDatos   บAutor  ณLaura Medina        บFecha ณ  23/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funci๓n para obtener los datos de la SRC o SRD.             บฑฑ
ฑฑบ          ณ 1. Formulario 1357 y  2.Archivo  1357                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcFyA(cOpcion)

Local nPos			:= 0 
Local cAliasAux		:= ""
Local cPrefixo		:= ""
Local cQuery		:= ""
Local cTmp			:= GetNextAlias()
Local lProcesa		:= .T.
Local aRemunera		:= Array(27)
Local aDeduccio		:= Array(27)
Local aDeducc23		:= Array(11)
Local aCalcImpt		:= Array(8)
Local aDesRegTri	:= Array(14)
Local nLoop			:= 0
Local nRegs			:= 0
Local nPos2			:= 0
Local nCounReg1		:= 0
Local lVerifRB		:= !Empty(cConceRB) .And. nValorRB > 0
Local cNomTipArc	:= ""
Local cNomeEmp		:= ""
Local cNomArcPla	:= ""
Local oObjExcel		:= Nil

Local aDataExcel	:= {}
Local aEmpleados	:= {}
Local aData			:= {}
Local cPerRCH		:= ""

Private aPerAbe		:= {} //Periodo Abierto
Private aPerFec		:= {} //Periodo Cerrado

Default cOpcion		:= "1"

RetPerAbertFech(cProceso,; // Processo selecionado na Pergunte.
				cProced,; // Roteiro selecionado na Pergunte.
				cPeriodo,; // Periodo selecionado na Pergunte.
				cNroPago,; // Numero de Pagamento selecionado na Pergunte.
				NIL		,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
				NIL		,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
				@aPerAbe,; // Retorna array com os Periodos e NrPagtos Abertos
				@aPerFec ) // Retorna array com os Periodos e NrPagtos Fechados

If Empty(aPerAbe) .And. Empty(aPerFec)
	Aviso( OemToAnsi(STR0007), OemToAnsi(STR0012), {STR0009} ) //"No fue encontrado ningun periodo. Verifique los parแmetros!"
	Return 
Endif

If (nPos:=aScan(aPerAbe, {|x| x[1] == cPeriodo .And. x[2] == cNroPago})) > 0 
	cAliasAux   := "SRC"
	cPrefixo    := "RC_"	
	cPerRCH		:= Alltrim(Str(Year(aPerAbe[1,5]))) + cNroPago
Elseif (nPos:=aScan(aPerFec, {|x| x[1] == cPeriodo .And. x[2] == cNroPago})) > 0 
	cAliasAux   := "SRD"
	cPrefixo    := "RD_"	
	cPerRCH		:= Alltrim(Str(Year(aPerFec[1,5]))) + cNroPago
Endif 

cQuery 	:= 	"SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_ACTTRAN, RA_ADMISSA, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_ZONDES, SUM("+cPrefixo+"VALOR) RC_VALOR "
cQuery	+=	"FROM "
cQuery	+=	RetSqlName("SRA") + " SRA,  "	
cQuery  +=	RetSqlName(cAliasAux) +" "+ cAliasAux + " " 
cQuery  += 	"WHERE SRA.D_E_L_E_T_= ' ' AND "
cQuery +=		cAliasAux+".D_E_L_E_T_= ' ' AND "
cQuery  += 		"SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND "
cQuery  += 		cAliasAux+"."+cPrefixo+"FILIAL	= '" +   xFilial("SRA") + "'  AND "
cQuery  +=		"SRA.RA_CC BETWEEN '"+ cIniCC +"' AND '"+ cFinCC +"' AND " 
If  !Empty(cCodMat)
	cQuery  +=	cCodMat +" AND "
Endif
cQuery += 		cAliasAux+"."+cPrefixo+"MAT    = RA_MAT  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"FILIAL = RA_FILIAL  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PROCES	= '" +  cProceso+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"ROTEIR	= '" +  cProced+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PERIODO	= '" +  cPeriodo+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"SEMANA	= '" +  cNroPago+ "'  AND "
//PDF4: Solo activos ?
cQuery +=		"RA_SITFOLH <> 'D' " 
cQuery +=	"GROUP BY RA_FILIAL, RA_MAT, RA_CIC, RA_ACTTRAN, RA_ADMISSA, RA_PRINOME, RA_SECNOME, RA_PRISOBR, RA_SECSOBR, RA_ZONDES "
cQuery +=	"ORDER BY RA_FILIAL, RA_MAT"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)
TcSetField(cTmp, "RA_ADMISSA", "D", 08, 0)

Count to nRegs

ProcRegua(nRegs)
(cTmp)->(dbGoTop())

If cOpcion $ "2/3" .And. nRegs > 0 //Archivo 1357
	If cOpcion == "2" .And. !GenArch(cPerRCH)  //Crea el archivo.
		lProcesa := .F.
	ElseIf cOpcion == "3"
		oObjExcel	:= FWMsExcelEx():New()
		oObjExcel:SetCelBgColor("#eca053") //Se setea color (naranja) de fondo para la celda correspondiente al N๚mero de Registro
	Endif
Endif

If cOpcion == "1"
	cNomTipArc := STR0014 //"formulario 1357... "
ElseIf cOpcion == "2"
	cNomTipArc := STR0015 //"archivo 1357... "
Else
	cNomTipArc := STR0141 //"planilla 1357... "
EndIf

While (cTmp)-> (!Eof()) .And. lProcesa
	IncProc(STR0013 + cNomTipArc) //"Generando "
	
	If Iif(lVerifRB, ObtMov("", cAliasAux, cPrefixo, (cTmp)->RA_FILIAL, (cTmp)->RA_MAT, 2, cConceRB) >= nValorRB, .T.)

		aRemunera	:= Array(67) //Registro 03
		aDeduccio	:= Array(37) //Registro 04
		aDeducc23	:= Array(22) //Registro 05
		aCalcImpt	:= Array(19) //Registro 06
		aDesRegTri	:= Array(14) //Registro 07
		
		nCounReg1 ++
		
		//REMUNERACIONES (Registro 03)
		aRemunera[1]:= {"03",""}
		aRemunera[2]:= {PADL((cTmp)->RA_CIC, 11, " "),""}
		For nloop := 3 to 67
			If (nPos2:= aScan(aRubros, {|x| x[2] == 3 .And. x[3] == nloop}) )> 0
				aRemunera[nloop]:= {ObtMov(aRubros[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1),aRubros[nPos2,1]}
			Else
				aRemunera[nloop]:= {0,""}
			Endif
		Next
		
		//DEDUCCIONES (Generales) (Registro 04)
		aDeduccio[1]:= {"04",""}
		aDeduccio[2]:= {PADL((cTmp)->RA_CIC, 11, " "),""}
		For nloop := 3 to 37
			If (nPos2:= aScan(aRubros, {|x| x[2] == 4 .And. x[3] == nloop}) )> 0
				aDeduccio[nloop]:= {ObtMov(aRubros[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1),aRubros[nPos2,1]}
			Else
				aDeduccio[nloop]:= {0,""}
			Endif
		Next
		
		//DEDUCCIONES ART. 23 (Personales) (Registro 04)
		aDeducc23[1]:= {"05",""}
		aDeducc23[2]:= {PADL((cTmp)->RA_CIC, 11, " "),""}
		For nloop := 3 to 22
			If (nPos2:= aScan(aRubros, {|x| x[2] == 5 .And. x[3] == nloop}) )> 0
				aDeducc23[nloop]:= {ObtMov(aRubros[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1),aRubros[nPos2,1]}
			Else
				aDeducc23[nloop]:= {0,""}
			Endif
		Next
		
		//CALCULO DE IMPUESTO (Registro 06)
		aCalcImpt[1]:= {"06",""}
		aCalcImpt[2]:= {PADL((cTmp)->RA_CIC, 11, " "),""}
		For nloop := 3 to 19
			If (nPos2 := aScan(aRubros, {|x| x[2] == 6 .And. x[3] == nloop}) ) > 0
				aCalcImpt[nloop]:= {ObtMov(aRubros[nPos2,1], cAliasAux, cPrefixo,(cTmp)->RA_FILIAL,(cTmp)->RA_MAT,1),aRubros[nPos2,1]}
			Else
				aCalcImpt[nloop]:= {0,""}
			Endif
		Next

		//Informaci๓n Desagregada por R้gimen Tributario (Registro 07)
		aDesRegTri[1] := {"07",""}
		aDesRegTri[2] := {PADL((cTmp)->RA_CIC, 11, " "),""}
		For nloop := 3 to 14
			If (nPos2 := aScan(aRubros, {|x| x[2] == 7 .And. x[3] == nloop}) ) > 0
				aDesRegTri[nloop] := {ObtMov(aRubros[nPos2, 1], cAliasAux, cPrefixo, (cTmp)->RA_FILIAL, (cTmp)->RA_MAT, 1), aRubros[nPos2, 1]}
			Else
				aDesRegTri[nloop] := {0, ""}
			Endif
		Next nloop
		
		If cOpcion == "1" //Generaci๓n de PDF

			cNomeEmp := AllTrim((cTmp)->RA_PRISOBR) + " " + AllTrim((cTmp)->RA_SECSOBR) + " " + AllTrim((cTmp)->RA_PRINOME) + " " + AllTrim((cTmp)->RA_SECNOME)
			aAdd(aEmpleados, {(cTmp)->RA_CIC, cNomeEmp, (cTmp)->RA_MAT, (cTmp)->RA_FILIAL})
			aAdd(aData, {aEmpleados, aRemunera, aDeduccio, aDeducc23, aCalcImpt, aDesRegTri})
			aEmpleados := {}
			nGenPDF++

		ElseIf cOpcion == "2" //Generaci๓n de Archivo
			
			If nCounReg1 == 1 //Solo se imprime una vez el registro 01
				GrabaReg01(cPerRCH, cOpcion) //Impresi๓n de Registro 01 (Longitud de 38)
			Endif

			//Solo en caso de tener registros positivo se va a grabar el registro 02...07
			GrabaReg02((cTmp)->RA_ADMISSA, (cTmp)->RA_ACTTRAN, (cTmp)->RA_CIC, (cTmp)->RA_ZONDES, cPerRCH) //Impresi๓n de Registro 02 (Longitud de 38)
			GrabaRegXX(aRemunera, 3, cOpcion) //Impresi๓n de Registro 03 (Longitud de 856)
			GrabaRegXX(aDeduccio, 4, cOpcion) //Impresi๓n de Registro 04 (Longitud de 513)
			GrabaRegXX(aDeducc23, 5, cOpcion) //Impresi๓n de Registro 05 (Longitud de 193)
			GrabaRegXX(aCalcImpt, 6, cOpcion) //Impresi๓n de Registro 06 (Longitud de 226)
			GrabaReg07(aDesRegTri) //Impresi๓n de Registro 07 (Longitud de 109)

			lGenTXT := .T.

		ElseIf cOpcion == "3" //Generaci๓n de Planilla
			
			If nCounReg1 == 1 //Solo se imprime una vez el registro 01
				
				aDataExcel := {}
				
				GrabaReg01(cPerRCH, cOpcion, aDataExcel) //Impresi๓n de Registro 01 (Longitud de 38)
				
				If Len(aDataExcel) > 0					
					oObjExcel	:= fDefImpExc(oObjExcel, aDataExcel, "01", nCounReg1)
				EndIf

			Endif

			aDataExcel := {}
			cNomeEmp := AllTrim((cTmp)->RA_PRISOBR) + " " + AllTrim((cTmp)->RA_SECSOBR) + " " + AllTrim((cTmp)->RA_PRINOME) + " " + AllTrim((cTmp)->RA_SECNOME)			
			GrabaReg02((cTmp)->RA_ADMISSA, (cTmp)->RA_ACTTRAN, (cTmp)->RA_CIC, (cTmp)->RA_ZONDES, cPerRCH, cOpcion, (cTmp)->RA_MAT, cNomeEmp, aDataExcel) //Impresi๓n de Registro 02 (Longitud de 38)
			GrabaRegXX(aRemunera, 3, cOpcion, aDataExcel) //Impresi๓n de Registro 03 (67 campos)
			GrabaRegXX(aDeduccio, 4, cOpcion, aDataExcel) //Impresi๓n de Registro 04 (37 campos)
			GrabaRegXX(aDeducc23, 5, cOpcion, aDataExcel) //Impresi๓n de Registro 05 (22 campos)
			GrabaRegXX(aCalcImpt, 6, cOpcion, aDataExcel) //Impresi๓n de Registro 06 (19 campos)

			If Len(aDataExcel) > 0					
				oObjExcel	:= fDefImpExc(oObjExcel, aDataExcel, "XX", nCounReg1)
			EndIf

			lGenPlan := .T.

		Endif
	Endif	
	(cTmp)->(DbSkip())	
EndDo
(cTmp)->(dbCloseArea())

If cOpcion == "3" .And. lGenPlan
	fGenExcel(oObjExcel, @cNomArcPla, cPerRCH)
	fViewExcel(cNomArcPla)
EndIf

If cOpcion == "1" .And. nGenPDF >= 1
	fPrinReport(aData, cPerRCH)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGenArch   บAutor  ณLaura Medina         บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Generar archivo y registro 01                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GenArch(cPerRCH)
Local lRet   	:= .T.
Local cNomArch	:= "F1357."+Alltrim(STRTRAN(SM0->M0_CGC,"-",""))+"."+substr(cPerRCH,1,4)+"0000."+StrZero(Val(cSecuenc),4)+".txt"  //PDF1
Local cDrive	:= ""
Local cDir      := ""
Local cExt      := ""
Local cNewFile	:= ""

Default cPerRCH := ""

IIf (!(Substr(cNomArch,Len(cNomArch) - 2, 3) $ "txt|TXT"), cNomArch += ".TXT", "")

cNewFile := cRutaArc + cNomArch

SplitPath(cNewFile,@cDrive,@cDir,@cNomArch,@cExt)
cDir 	 := cDrive + cDir

Makedir(cDir,,.F.) //Crea el directorio en caso de no existir

cNewFile := cDir + cNomArch + cExt   
nArchTXT := FCreate (cNewFile,0)

If nArchTXT == -1
	Aviso( OemToAnsi(STR0007), OemToAnsi(STR0008 + cNomArch), {STR0009} ) //"Atencion" - "No se pudo crear el archivo " - "OK"
	lRet   := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrabaReg01 บAutor  ณLaura Medina        บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณArchivo 1357 | Registro 01 |                                 บฑฑ
ฑฑบ          ณEl registro cabecera debe ser el primer registro del archivo,บฑฑ
ฑฑบ          ณcon una longitud de 38 (treinta y ocho) caracteres.          บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrabaReg01(cPerRCH, cOpcion, aDataExcel)

	Local aFilAtu		:= FWArrFilAtu()

	//Variables del Registro 01
	Local cTipRegArc	:= "01" //1 - Tipo de Registro
	Local cCUITAgent	:= PadR(StrTran(aFilAtu[18],"-",""), 11, " ") //2 - CUIT Agente Retenci๓n
	Local cPeriodo		:= IIf(nTipoPre == 1 .Or. nTipoPre == 4, SubStr(cPerRCH, 1, 4) + "00", cPeriodo) //3 - Periodo Informado
	Local cSecuencia	:= StrZero(Val(cSecuenc), 2) //4 - Secuencia
	Local cCodImpues	:= PadR(SuperGetMv("MV_1357IMP", .F., ""), 4) //5 - C๓digo del Impuesto
	Local cCodConcep	:= PadR(SuperGetMv("MV_1357CON", .F., ""), 3) //6 - C๓digo del Concepto
	Local cNumFormul	:= PadR(SuperGetMv("MV_1357FOR", .F., ""), 4) //7 - N๚mero de Formulario
	Local cTipoPrese	:= AllTrim(Str(nTipoPre)) //8 - Tipo de Presentaci๓n
	Local cCodVersio	:= PadR(SuperGetMv("MV_1357SIS", .F., ""),5) //9 - Versi๓n del Sistema

	//Variables Archivo
	Local cLinea		:= ""

	Default cPerRCH 	:= ""
	Default cOpcion		:= "2"
	Default aDataExcel	:= {}

	If cOpcion == "2" //Generaci๓n de Registro 01 para Archivo
		
		//Longitud 38 caracteres
		cLinea := cTipRegArc
		cLinea += cCUITAgent
		cLinea += cPeriodo
		cLinea += cSecuencia
		cLinea += cCodImpues
		cLinea += cCodConcep
		cLinea += cNumFormul
		cLinea += cTipoPrese
		cLinea += cCodVersio

		FWrite(nArchTXT, cLinea)

		cLinea := ""

	ElseIf cOpcion == "3" //Generaci๓n de Registro 01 para Planilla

		aAdd(aDataExcel, cTipRegArc) //1 - Tipo de Registro
		aAdd(aDataExcel, cCUITAgent) //2 - CUIT Agente Retenci๓n
		aAdd(aDataExcel, cPeriodo) //3 - Periodo Informado
		aAdd(aDataExcel, cSecuencia) //4 - Secuencia
		aAdd(aDataExcel, cCodImpues) //5 - C๓digo del Impuesto
		aAdd(aDataExcel, cCodConcep) //6 - C๓digo del Concepto
		aAdd(aDataExcel, cNumFormul) //7 - N๚mero de Formulario
		aAdd(aDataExcel, cTipoPrese) //8 - Tipo de Presentaci๓n
		aAdd(aDataExcel, cCodVersio) //9 - Versi๓n del Sistema
		
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrabaReg02 บAutor  ณLaura Medina        บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Archivo 1357 | Registro 02 |                                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrabaReg02(dAdmissa, nActTran, cCIC, cZonDes, cPerRCH, cOpcion, cMatricula, cNomeEmp, aDataExcel)

	Local cAnoIng   := AllTrim(Str(Year(dAdmissa)))  //A๑o de la fecha de Admisi๓n 

	//Variables del Registro 02
	Local cTipRegArc	:= "02" //1 - Tipo de Registro
	Local cCUILEmple	:= PADR(cCIC, 11, " ") //2 - CUIL Empleado
	Local cPeriDesde	:= "" //3 - Periodo trabajado desde
	Local cPeriHasta	:= "" //4 - Periodo trabajado hasta
	Local cNumMeses		:= "12" //5 - Meses
	Local cBeneficio	:= "" //6 - Beneficio
	Local cDesActivi	:= "" //7 - ฟDesarrolla actividad de transporte larga distancia?
	Local cLey27424		:= "0" //8 - ฟEl trabajador posee el beneficio promocional de la Ley Nro. 27.424? 
	Local cLey27549		:= "0" //9 - ฟEl trabajador posee el beneficio de la Ley 27.549?
	Local cLey27555		:= "0" //10 - ฟEl trabajador labora bajo el r้gimen de teletrabajo - Ley 27.555?
	Local cLey19101		:= "0" //11 - ฟEl trabajador es personal militar en actividad - Ley 19.101?
	Local cEmpActTer	:= "0" //12 - ฟEl trabajador desarrolla la actividad de transporte TERRESTRE de larga distancia bajo el convenio 40/1989?

	//Variables de Archivo
	Local cLinea		:= ""

	Default dAdmissa	:= CToD("//")
	Default nActTran	:= "0"
	Default cCIC		:= ""
	Default cZonDes 	:= ""
	Default cPerRCH 	:= ""
	Default cOpcion 	:= "2"
	Default cMatricula	:= ""
	Default cNomeEmp	:= ""
	Default aDataExcel	:= {}

	cPeriDesde	:= IIf(cAnoIng < Substr(cPerRCH,1,4),Substr(cPerRCH,1,4)+"0101",Substr(cPerRCH,1,4)+STRZERO(MONTH(dAdmissa),2)+"01")
	cPeriHasta	:= SubStr(cPerRCH,1,4)+"1231"
	cZonDes		:= AllTrim(cZonDes)
	cBeneficio	:= IIf(Empty(cZonDes),"1",IIf(len(cZonDes)==1,cZonDes,substr(cZonDes,2,1)))  //Beneficio (RA_ZONDES)
	cDesActivi	:= IIf(nActTran != "1", "0", nActTran)

	If cOpcion == "2" //Generaci๓n de Registro 02 para Archivo
		
		//Longitud 38 caracteres
		cLinea := CRLF 
		cLinea += cTipRegArc
		cLinea += cCUILEmple
		cLinea += cPeriDesde
		cLinea += cPeriHasta
		cLinea += cNumMeses
		cLinea += cBeneficio
		cLinea += cDesActivi
		cLinea += cLey27424
		cLinea += cLey27549
		cLinea += cLey27555
		cLinea += cLey19101

		//Agregado para Versi๓n 6.0
		cLinea += cEmpActTer //ฟEl trabajador desarrolla la actividad de transporte TERRESTRE de larga distancia bajo el convenio 40/1989? - 1 = Sํ / 0 = No

		FWrite(nArchTXT, cLinea)

		cLinea := ""

	ElseIf cOpcion == "3" //Generaci๓n de Registro 02 para Planilla

		aAdd(aDataExcel, cMatricula) //Matrํcula (Campo informativo)
		aAdd(aDataExcel, cNomeEmp) //Nombre (Campo informativo)
		aAdd(aDataExcel, cTipRegArc)  //1 - Tipo de Registro
		aAdd(aDataExcel, cCUILEmple)  //2 - CUIL Empleado
		aAdd(aDataExcel, cPeriDesde)  //3 - Periodo trabajado desde
		aAdd(aDataExcel, cPeriHasta)  //4 - Periodo trabajado hasta
		aAdd(aDataExcel, cNumMeses)  //5 - Meses
		aAdd(aDataExcel, cBeneficio)  //6 - Beneficio
		aAdd(aDataExcel, cDesActivi)  //7 - ฟDesarrolla actividad de transporte larga distancia?
		aAdd(aDataExcel, cLey27424)  //8 - ฟEl trabajador posee el beneficio promocional de la Ley Nro. 27.424? 
		aAdd(aDataExcel, cLey27549)  //9 - ฟEl trabajador posee el beneficio de la Ley 27.549?
		aAdd(aDataExcel, cLey27555)  //10 - ฟEl trabajador labora bajo el r้gimen de teletrabajo - Ley 27.555?
		aAdd(aDataExcel, cLey19101)  //11 - ฟEl trabajador es personal militar en actividad - Ley 19.101?
		aAdd(aDataExcel, cEmpActTer)  //12 - ฟEl trabajador desarrolla la actividad de transporte TERRESTRE de larga distancia bajo el convenio 40/1989?

	EndIf

Return

/*/{Protheus.doc} GrabaRegXX
	Genera los valores de los Registros 03, 04, 05 y 06.
	
	@type  Static Function
	@author Laura Medina
	@since 07/10/2024
	@version 2.0
	@param aRegistroX, Array, Arreglo con los movimientos (RC/RD_VALOR).
	@param nReg, Numeric, N๚mero de Registro.
	@param cOpcion, Caracter, Contiene la opci๓n seleccionada por el usuario.
	@param aDataExcel, Array, Arreglo con los datos que se imprimirแn en la planilla.
	@example
	GrabaRegXX(aRegistroX, nReg, cOpcion, aDataExcel)
/*/
Static Function GrabaRegXX(aRegistroX, nReg, cOpcion, aDataExcel)

Local nLoop			:= 0 
Local nInicio		:= 3
Local cLinea		:= ""

Default aRegistroX	:= {}
Default nReg		:= 0
Default cOpcion		:= "2"
Default aDataExcel	:= {}

If cOpcion == "2" //Generaci๓n de Registro XX para Archivo
	cLinea := CRLF
	cLinea += aRegistroX[1,1]
	cLinea += aRegistroX[2,1]
ElseIf cOpcion == "3" //Generaci๓n de Registro XX para Planilla
	aAdd(aDataExcel, aRegistroX[1,1])
	aAdd(aDataExcel, aRegistroX[2,1])
EndIf

If nReg == 6
	nInicio := 5

	If cOpcion == "2" //Generaci๓n de Registro XX para Archivo
		cLinea += Tabla_Aliq(aRegistroX[3,1])
		cLinea += Tabla_Aliq(aRegistroX[4,1])
	ElseIf cOpcion == "3" //Generaci๓n de Registro XX para Planilla
		aAdd(aDataExcel, aRegistroX[3,1])
		aAdd(aDataExcel, aRegistroX[4,1])
	EndIf
	
Endif

For nLoop := nInicio To Len(aRegistroX)
	If (nReg == 5 .And. (nLoop == 7 .Or. nLoop == 15 .Or. nLoop == 19 .Or. nLoop == 20 .Or. nLoop == 21 .Or. nLoop == 22)) .OR.;
		(nReg == 3 .and. (nLoop >= 56 .and. nLoop <= 61)) .or. (nReg == 4 .and. nLoop == 36)
		If cOpcion == "2" //Generaci๓n de Registro XX para Archivo
			cLinea +=  StrZero(aRegistroX[nLoop,1],2)
		ElseIf cOpcion == "3" //Generaci๓n de Registro XX para Planilla
			aAdd(aDataExcel, aRegistroX[nLoop,1])
		EndIf
	Else
		If nLoop <> 27
			If (nReg == 3 .and. (nLoop == 8 .Or. nLoop == 12 .Or. nLoop == 19 .Or. nLoop == 23)) .or. ;
				(nReg == 6 .and. nLoop == 12) .Or. (nReg == 5 .and. (nLoop == 11 .or. nLoop == 12 .or. nLoop == 13)) .OR.;
				(nReg == 4 .and. nLoop == 24)

				If cOpcion == "2" //Generaci๓n de Registro XX para Archivo
					cLinea += "0"
				ElseIf cOpcion == "3" //Generaci๓n de Registro XX para Planilla
					aAdd(aDataExcel, "0")
				EndIf
			Else
				If cOpcion == "2" //Generaci๓n de Registro XX para Archivo
					cLinea += PadL(STRTRAN(AllTrim(STRTRAN(Transform(aRegistroX[nLoop,1], cPictVal),",","")),".",""), 15, "0")
				ElseIf cOpcion == "3" //Generaci๓n de Registro XX para Planilla
					aAdd(aDataExcel, AllTrim(Transform(aRegistroX[nLoop,1], cPictVal)))
				EndIf
			EndIf
		Else
			If cOpcion == "2" //Generaci๓n de Registro XX para Archivo
				cLinea += PadL(STRTRAN(AllTrim(STRTRAN(Transform(aRegistroX[nLoop,1], cPictV17),",","")),".",""), 17, "0")
			ElseIf cOpcion == "3" //Generaci๓n de Registro XX para Planilla
				aAdd(aDataExcel, AllTrim(Transform(aRegistroX[nLoop,1], cPictV17)))
			EndIf
		Endif
	Endif
Next nLoop

If cOpcion == "2" //Generaci๓n de Registro XX para Archivo
	FWrite(nArchTXT, cLinea)
	cLinea := ""
EndIf

Return

/*/{Protheus.doc} GrabaReg07
	Funci๓n utilizada para la impresi๓n del Registro Nฐ 7 correspondiente a
	Informaci๓n Desagregada por R้gimen Tributario.

	@type  Static Function
	@author marco.rivera
	@since 18/07/2024
	@version 1.0
	@param aRegistroX, Array, Arreglo con los movimientos (RC/RD_VALOR)
	@example
	GrabaReg07(aRegistroX)
	/*/
Static Function GrabaReg07(aRegistroX)

	Local nIteracion	:= 0
	Local cLinea		:= ""

	Default aRegistroX	:= {}

	cLinea := CRLF 
	cLinea += aRegistroX[1,1] //Campo 1 - Tipo Registro
	cLinea += aRegistroX[2,1] //Campo 2 - CUIL

	For nIteracion := 3 To Len(aRegistroX)
		//Procesa solo campos de Alicuota
		If nIteracion == 4 .Or. nIteracion == 5 .Or. nIteracion == 8 .Or. nIteracion == 9 .Or. nIteracion == 11 .Or. nIteracion == 12
			cLinea += Tabla_Aliq(aRegistroX[nIteracion, 1])
		Else //Procesa campos N๚mericos con Longitud 15
			cLinea += PadL(StrTran(AllTrim(StrTran(Transform(aRegistroX[nIteracion, 1], cPictVal), ",", "")), ".", ""), 15, "0")
		EndIf
	Next nIteracion

	FWrite(nArchTXT, cLinea)
	cLinea := ""

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVl1537     บAutor  ณLaura Medina        บFecha ณ  19/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validaci๓n del periodo, debe ser mayor o igual a 2018       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Vl1537(cPerVld, nTipPr)
Local lRet := .T. 
Default nTipPr := 0

If  (nTipPr == 1 .Or. nTipPr == 4) .And. Substr(cPerVld,1,4)< "2020" 
	lRet := .F.
	Aviso( OemToAnsi(STR0007), OemToAnsi(STR0010), {STR0009} ) //"Atencion" - "Informe un periodo valido (a partir del 2020)."  
Elseif (nTipPr == 2 .OR. nTipPr == 3) .And. cPerVld < "202101" 
	lRet := .F. //PDF1,2,3
	Aviso( OemToAnsi(STR0007), OemToAnsi(STR0016), {STR0009} ) //"Informe un periodo valido (a partir del 202101)." 
Endif

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณObtMov     บAutor  ณLaura Medina        บFecha ณ  24/03/2020 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener movimientos para el concepto.                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ObtMov(cCod1357, cAliasAux, cPrefixo, cFilMov, cMatMov, nOpc, cConcep)

Local cQuery	:= ""
Local cTmp		:= GetNextAlias()
Local nRenumera := 0

Default nOpc	:= 1
Default cConcep := ""

cQuery := 	"SELECT SUM("+cPrefixo+"VALOR) "+cPrefixo+"VALOR "
cQuery +=	"FROM "
cQuery +=	RetSqlName(cAliasAux) +" "+ cAliasAux + ", "  +RetSqlName("SRV")+ " SRV " 
cQuery += 	"WHERE "+ cAliasAux+"."+cPrefixo+"MAT = '" +cMatMov + "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"FILIAL	= '" +  cFilMov+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PROCES	= '" +  cProceso+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"ROTEIR	= '" +  cProced+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PERIODO	= '" +  cPeriodo+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"SEMANA	= '" +  cNroPago+ "'  AND "
cQuery += 		cAliasAux+"."+cPrefixo+"PD = SRV.RV_COD AND "

//RV_COD1357 G603, G604,...D619
If nOpc ==1
	cQuery += 		"SRV.RV_COD1357 = '" + cCod1357 + "'  AND "
Elseif nOpc == 2
	cQuery += 		"SRV.RV_COD = '" + cConcep + "'  AND "
Endif

cQuery +=		cAliasAux+".D_E_L_E_T_= ' ' AND "
cQuery +=		"SRV.D_E_L_E_T_= ' ' AND "
cQuery +=		"SRV.RV_FILIAL = '" + xFilial("SRV")+ "' ""
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmp,.T.,.T.)

If (cTmp)-> (!Eof())
	nRenumera := abs((cTmp)->&((cPrefixo)+"VALOR"))
Endif
(cTmp)->(dbCloseArea())	

Return nRenumera

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Tabla_Aliq บAutor  ณLaura Medina       บFecha ณ  15/04/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener el valor que corresponde.                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tabla_Aliq(cAliq)
Local cValor  := ""
Default cAliq := "0"

cAliq := Alltrim(str(cAliq))

Do Case
	Case cAliq == "0"
		 cValor := "0"
	Case cAliq == "5"
		 cValor := "1"
	Case cAliq == "9"
		 cValor := "2"
	Case cAliq == "12"
		 cValor := "3"
	Case cAliq == "15"
		 cValor := "4"
	Case cAliq == "19"
		 cValor := "5"
	Case cAliq == "23"
		 cValor := "6"
	Case cAliq == "27"
		 cValor := "7"	
	Case cAliq == "31"
		 cValor := "8"
	Case cAliq == "35"
		 cValor := "9"		 
	OtherWise
		 cValor := "0"
	EndCase

Return cValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcargaTabla บAutor  ณLaura Medina        บFecha ณ  17/04/2021 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener los rubros de la tabla alfanum้rica S044.           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAGPE: Archivo 1357                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cargaTabla(cTabla)

Local aTablaS044 := {}

Default cTabla 	 := ""

DbSelectArea("RCC")    
RCC->(dbSetOrder(1)) //"RCC_FILIAL+RCC_CODIGO+RCC_FIL+RCC_CHAVE+RCC_SEQUEN"

If RCC->(MsSeek(xFilial("RCC") + cTabla ))
	While !Eof() .And. RCC->RCC_FILIAL + RCC->RCC_CODIGO == xFilial("RCC") + cTabla
		aAdd(aTablaS044, {Substr(RCC->RCC_CONTEU, 1, 4), Val(Substr(RCC->RCC_CONTEU, 2, 1)), Val(Substr(RCC->RCC_CONTEU, 3, 2))})
		RCC->(DBSkip())	
	EndDo
Endif

Return aTablaS044

/*/{Protheus.doc} fDefImpExc
	Funci๓n para definir la impresi๓n del Encabezado y Detalle de los
	Registros.
	
	@type  Static Function
	@author marco.rivera
	@since 02/09/2024
	@version 1.0
	@param oObjExcel, Object, Objeto de la clase FWMsExcelEx.
	@param aDataExcel, Array, Arreglo que contiene datos del Registro.
	@param cIdentReg, Character, Identificador de Registro a procesar.
	@param nRegistros, Numeric, N๚mero de registro que se estแ procesando.
	@return oObjExcel, Object, Objeto que contiene la definici๓n de la planilla.
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
	* Definici๓n de Hoja y Tabla para imprimir informaci๓n de Registro 01
	* -------------------------------------------------------------------- 
	*/
	If cIdentReg == '01' .And. nRegistros == 1

		//Definici๓n de Hoja de Trabajo (Worksheet) y Tabla
		oObjExcel := fDefWSTab(oObjExcel, cIdentReg, cNameWorkS, cNameTable)
	
		//Definici๓n de encabezado de Registro 01 - Datos del Empleador (9 campos)
		oObjExcel := fDefEncReg(oObjExcel, cIdentReg, cNameWorkS, cNameTable)
	EndIf

	/*
	* --------------------------------------------------------------------
	* Definici๓n de Hoja y Tabla para imprimir informaci๓n de Registro 02 en adelante
	* --------------------------------------------------------------------
	*/
	If cIdentReg == "XX" .And. nRegistros == 1

		//Definici๓n de Hoja de Trabajo (Worksheet) y Tabla
		oObjExcel := fDefWSTab(oObjExcel, cIdentReg, cNameWorkS, cNameTable)
	
		//Definici๓n de encabezado de Registro 01 - Datos del Empleador (9 campos)
		oObjExcel := fDefEncReg(oObjExcel, cIdentReg, cNameWorkS, cNameTable)
	EndIf
	
	//Impresi๓n del detalle de los Registros
	oObjExcel := fDefImpReg(oObjExcel, cIdentReg, aDataExcel, cNameWorkS, cNameTable)
	
Return oObjExcel

/*/{Protheus.doc} fDefWSTab
	Funci๓n utilizada para definir el nombre de la Hoja de Trabajo y Tabla.

	@type  Static Function
	@author marco.rivera
	@since 02/09/2024
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definici๓n de la planilla.
	@param cIdentReg, Character, Identificador de Registro a procesar.
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, N๚mero de la Tabla.
	@return oObjExcel, Object, Objeto que contiene la definici๓n de la planilla.
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
	Funci๓n utilizada para definir el encabezado de los registros.

	@type  Static Function
	@author marco.rivera
	@since 02/09/2024
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definici๓n de la planilla.
	@param cIdentReg, Character, Identificador de Registro a procesar.
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, N๚mero de la Tabla.
	@return oObjExcel, Object, Objeto que contiene la definici๓n de la planilla.
	@example
	fDefEncReg(oObjExcel, cIdentReg, cNameWorkS, cNameTable)
/*/
Static Function fDefEncReg(oObjExcel, cIdentReg, cNameWorkS, cNameTable)

	Local aTitulos		:= {}

	Default oObjExcel	:= Nil
	Default cIdentReg	:= ""
	Default cNameWorkS	:= ""
	Default cNameTable	:= ""

	If cIdentReg == "01" //Definici๓n de Encabezados para el Registro 01

		//Campos pertenecientes al Registro 01 - Cabecera (9 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0142,;	//Campo 1 = "Registro"
						STR0143,;	//Campo 2 = "CUIT Ag. Ret."
						STR0144,;	//Campo 3 = "Periodo"
						STR0145,;	//Campo 4 = "Secuencia"
						STR0146,;	//Campo 5 = "C๓d. Impuesto"
						STR0147,;	//Campo 6 = "C๓d. Concepto"
						STR0148,;	//Campo 7 = "N๚m. Formulario"
						STR0149,;	//Campo 8 = "Tipo Present."
						STR0150;	//Campo 9 = "Versi๓n"
						})

		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

	Else //Definici๓n de encabezado de Registro 02 al 07
		
		oObjExcel:AddColumn(cNameWorkS, cNameTable, STR0151, 1, 1, .F.) //"Matrํcula" (Este campo es informativo)
		oObjExcel:AddColumn(cNameWorkS, cNameTable, STR0152, 1, 1, .F.) //"Nombre" (Este campo es informativo)

		//Campos pertenecientes al Registro 02 - Datos del Trabajador (12 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0142,;	//Campo 1 = "Registro"
						STR0153,;	//Campo 2 = "CUIL"
						STR0154,;	//Campo 3 = "Per. Desde"
						STR0155,;	//Campo 4 = "Per. Hasta"
						STR0156,;	//Campo 5 = "Meses"
						STR0157,;	//Campo 6 = "Beneficio"
						STR0158,;	//Campo 7 = "ฟDes. Act. Transp.?"
						STR0159,;	//Campo 8 = "ฟTrab. Ley 27.424?"
						STR0160,;	//Campo 9 = "ฟTrab. Ley 27.549?"
						STR0161,;	//Campo 10 = "ฟTrab. Ley 27.555?"
						STR0162,;	//Campo 11 = "ฟTrab. Ley 19.101?"
						STR0163;	//Campo 12 = "ฟTrab. Conv. 40/1989?"
						})
		
		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

		//Campos pertenecientes al Registro 03 - Remuneraciones (67 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0142,;	//Campo 1 = "Registro"
						STR0153,;	//Campo 2 = "CUIL"
						STR0165,;	//Campo 3 = "Rem. Bruta"
						STR0166,;	//Campo 4 = "Ret. No Habit."
						STR0167,;	//Campo 5 = "SAC 1ra Cuota"
						STR0168,;	//Campo 6 = "SAC 2da Cuota"
						STR0169,;	//Campo 7 = "Hrs. Ext. Rem. Gra."
						STR0170,;	//Campo 8 = "Mov. Via. Rem. Gra."
						STR0171,;	//Campo 9 = "Mat. Did. Rem. Gra."
						STR0172,;	//Campo 10 = "Rem. No Alc. o Exc."
						STR0173,;	//Campo 11 = "Hrs. Ext. Rem. Exe."
						STR0174,;	//Campo 12 = "Mov. Via. Rem. Exe."
						STR0175,;	//Campo 13 = "Mat. Did. Rem. Exe."
						STR0165,;	//Campo 14 = "Rem. Bruta"
						STR0166,;	//Campo 15 = "Ret. No Habit."
						STR0167,;	//Campo 16 = "SAC 1ra Cuota"
						STR0168,;	//Campo 17 = "SAC 2da Cuota"
						STR0169,;	//Campo 18 = "Hrs. Ext. Rem. Gra."
						STR0170,;	//Campo 19 = "Mov. Via. Rem. Gra."
						STR0171,;	//Campo 20 = "Mat. Did. Rem. Gra."
						STR0172,;	//Campo 21 = "Rem. No Alc. o Exc."
						STR0173,;	//Campo 22 = "Hrs. Ext. Rem. Exe."
						STR0174,;	//Campo 23 = "Mov. Via. Rem. Exe."
						STR0175,;	//Campo 24 = "Mat. Did. Rem. Exe."
						STR0176,;	//Campo 25 = "Tot. Rem. Gra."
						STR0177,;	//Campo 26 = "Tot. Rem. No Alc."
						STR0178,;	//Campo 27 = "Tot. Rem."
						STR0179,;	//Campo 28 = "Ret. No Hab. o Exe."
						STR0180,;	//Campo 29 = "SAC 1ra Cuota Exe."
						STR0181,;	//Campo 30 = "SAC 2da Cuota Exe."
						STR0182,;	//Campo 31 = "Aju. Per. Ant. Rem. Gra."
						STR0183,;	//Campo 32 = "Aju. Per. Ant. Rem. Exe."
						STR0184,;	//Campo 33 = "Otr. Emp. Ret. No Hab. Exe."
						STR0185,;	//Campo 34 = "Otr. Emp. SAC 1ra Cuo. Exe."
						STR0186,;	//Campo 35 = "Otr. Emp. SAC 2da Cuo. Exe."
						STR0187,;	//Campo 36 = "Otr. Emp. Aju. Per. Rem. Gra."
						STR0188,;	//Campo 37 = "Otr. Emp. Aju. Per. Rem. Exe."
						STR0189,;	//Campo 38 = "Rem. Exenta Ley 27549"
						STR0190,;	//Campo 39 = "Otr. Emp. Rem. Exe. Ley 27549"
						STR0191,;	//Campo 40 = "Bonos Prod. Gra."
						STR0192,;	//Campo 41 = "Fallos de Caja Gra."
						STR0193,;	//Campo 42 = "Conc. Sim. Nat. Gra."
						STR0194,;	//Campo 43 = "Bonos Prod. Exentos"
						STR0195,;	//Campo 44 = "Fallos Caja Exe."
						STR0196,;	//Campo 45 = "Conc. Sim. Nat. Exe."
						STR0197,;	//Campo 46 = "Comp. Gas. Tel. Exe."
						STR0198,;	//Campo 47 = "Pers. Mil. Ley 19.101"
						STR0199,;	//Campo 48 = "Otr. Emp. Bon. Pro. Gra."
						STR0200,;	//Campo 49 = "Otr. Emp. Fal. Caj. Gra."
						STR0201,;	//Campo 50 = "Otr. Emp. Conc. Sim. Nat. Gra."
						STR0202,;	//Campo 51 = "Otr. Emp. Bon. Pro. Exe."
						STR0203,;	//Campo 52 = "Otr. Emp. Fal. Caj. Exe."
						STR0204,;	//Campo 53 = "Otr. Emp. Conc. Sim. Nat. Exe."
						STR0205,;	//Campo 54 = "Otr. Emp. Comp. Gas. Tel. Exe."
						STR0206,;	//Campo 55 = "Otr. Emp. Pers. Mil. Ley 19.101"
						STR0207,;	//Campo 56 = "Can. Bon. Pro."
						STR0208,;	//Campo 57 = "Can. Fal. Caj."
						STR0209,;	//Campo 58 = "Can. Con. Sim. Nat."
						STR0210,;	//Campo 59 = "Can. Otr. Emp. Bon. Pro."
						STR0211,;	//Campo 60 = "Can. Otr. Emp. Fal. Caj."
						STR0212,;	//Campo 61 = "Can. Otr. Emp. Con. Sim. Nat."
						STR0213,;	//Campo 62 = "Mov. Rem. Gra."
						STR0214,;	//Campo 63 = "Viแ. Rem. Gra."
						STR0215,;	//Campo 64 = "Com. Anแ. Rem. Gra."
						STR0216,;	//Campo 65 = "Rem. Otr. Emp. Mov. Rem. Gra."
						STR0217,;	//Campo 66 = "Rem. Otr. Emp. Viแ. Rem. Gra."
						STR0218;	//Campo 67 = "Rem. Otr. Emp. Com. Anแ. Rem. Gra."
						})
		
		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

		//Campos pertenecientes al Registro 04 - Deducciones (37 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0142,;	//Campo 1 = "Registro"
						STR0153,;	//Campo 2 = "CUIL"
						STR0219,;	//Campo 3 = "Apo. Fon. Jub."
						STR0220,;	//Campo 4 = "Apo. Fon. Jub. Otr. Emp."
						STR0221,;	//Campo 5 = "Apo. Obr. Soc."
						STR0222,;	//Campo 6 = "Apo. Obr. Soc. Otr. Emp."
						STR0223,;	//Campo 7 = "Cuota Sindical"
						STR0224,;	//Campo 8 = "Cuota Sindical Otr. Emp."
						STR0225,;	//Campo 9 = "Cutona M้dico Asi."
						STR0226,;	//Campo 10 = "Pri. Seg. Caso Mue."
						STR0227,;	//Campo 11 = "Pri. Rie. Mue."
						STR0228,;	//Campo 12 = "Apo. Pla. Seg. Ret."
						STR0229,;	//Campo 13 = "Cuo. Par. Fon. Com."
						STR0230,;	//Campo 14 = "Gastos Sepelio"
						STR0231,;	//Campo 15 = "Gas. Amo. Int. Rod."
						STR0232,;	//Campo 16 = "Don. Fis. Nac. Art. 20"
						STR0233,;	//Campo 17 = "Des. Obl. Est. Ley Nac."
						STR0234,;	//Campo 18 = "Hon. Serv. Asi. San."
						STR0235,;	//Campo 19 = "Int. Cr้. Hip."
						STR0236,;	//Campo 20 = "Apo. Cap. Soc. Fon. Rie."
						STR0237,;	//Campo 21 = "Apo. Caj. Com. Pre."
						STR0238,;	//Campo 22 = "Alq. Inm. Dest. Casa Hab."
						STR0239,;	//Campo 23 = "Emp. Ser. Dom."
						STR0240,;	//Campo 24 = "Gas. Mov. y Com. Anแ. Emp."
						STR0241,;	//Campo 25 = "Gas. Adq. Ind. Equ. Tra."
						STR0242,;	//Campo 26 = "Otras Deducciones"
						STR0243,;	//Campo 27 = "Total Ded. Generales"
						STR0244,;	//Campo 28 = "Otr. Ded. Apo. Jub. ANSeS"
						STR0245,;	//Campo 29 = "Otr. Ded. Caj. Prov."
						STR0246,;	//Campo 30 = "Otr. Ded. Act. Ret. RG 2442/08"
						STR0247,;	//Campo 31 = "Otr. Ded. Fon. Com. Prev."
						STR0248,;	//Campo 32 = "Ser. Edu. y Her."
						STR0249,;	//Campo 33 = "Gto. Mov. Abo. Emp."
						STR0250,;	//Campo 34 = "Gto. Viแ. Abo. Emp."
						STR0251,;	//Campo 35 = "Comp. Anแloga"
						STR0252,;	//Campo 36 = "Can. Comp. Anแloga"
						STR0253;	//Campo 37 = "Alq. Inm. Dest. Casa Hab."
						})
		
		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

		//Campos pertenecientes al Registro 05 - Deducciones Art. 23 (22 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0142,;	//Campo 1 = "Registro"
						STR0153,;	//Campo 2 = "CUIL"
						STR0254,;	//Campo 3 = "Ganancia No Imponible"
						STR0255,;	//Campo 4 = "Deducci๓n Especial"
						STR0256,;	//Campo 5 = "Deducci๓n Especํfica"
						STR0257,;	//Campo 6 = "C๓nyuge"
						STR0258,;	//Campo 7 = "Cant. Hijos/Hijastros"
						STR0259,;	//Campo 8 = "Hijos/Hijastros"
						STR0260,;	//Campo 9 = "Tot. Cargas Fam."
						STR0261,;	//Campo 10 = "Tot. Ded. Art. 23"
						STR0262,;	//Campo 11 = "Rem. Suj. Imp. Art. 46"
						STR0263,;	//Campo 12 = "Ded. Inc. A Art. 46 Ley 27541"
						STR0264,;	//Campo 13 = "Ded. Inc. C Art. 46 Ley 27541"
						STR0265,;	//Campo 14 = "Rem. Suj. Imp."
						STR0266,;	//Campo 15 = "Cant. Hij. Inc. Trab."
						STR0267,;	//Campo 16 = "Hij. Inc. Trab ($)"
						STR0268,;	//Campo 17 = "Ded. Esp. Inc. Pri."
						STR0269,;	//Campo 18 = "Ded. Esp. Inc. Seg."
						STR0270,;	//Campo 19 = "Cant. Hij. 100%"
						STR0271,;	//Campo 20 = "Cant. Hij. Inc. 100%"
						STR0272,;	//Campo 21 = "Cant. Hij. 18 y 24 Edu. 50%"
						STR0273;	//Campo 22 = "Cant. Hij. 18 y 24 Edu. 100%"
						})
		
		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

		//Campos pertenecientes al Registro 06 - Cแlculo del Impuesto (19 campos)
		aTitulos := {}
		aAdd(aTitulos, {;
						STR0142,;	//Campo 1 = "Registro"
						STR0153,;	//Campo 2 = "CUIL"
						STR0274,;	//Campo 3 = "Alํ. Art. 90 Ley Gan."
						STR0275,;	//Campo 4 = "Alํ. Apl. sin Inc. Hrs. Ext."
						STR0276,;	//Campo 5 = "Imp. Determinado"
						STR0277,;	//Campo 6 = "Imp. Retenido"
						STR0278,;	//Campo 7 = "Pagos a Cuenta"
						STR0279,;	//Campo 8 = "Saldo"
						STR0280,;	//Campo 9 = "Pgo. Cta. Imp. Cr้. D้b."
						STR0281,;	//Campo 10 = "Pgo. Cta. Per. Ret. Adu."
						STR0282,;	//Campo 11 = "Pgo. Cta. Rel Gen. 3819/2015"
						STR0283,;	//Campo 12 = "Pgo. Cta. Bono Ley 27.424"
						STR0284,;	//Campo 13 = "Pgo. Cta. Ley 27541 Inc. A"
						STR0285,;	//Campo 14 = "Pgo. Cta. Ley 27541 Inc. B"
						STR0286,;	//Campo 15 = "Pgo. Cta. Ley 27541 Inc. C"
						STR0287,;	//Campo 16 = "Pgo. Cta. Ley 27541 Inc. D"
						STR0288,;	//Campo 17 = "Pgo. Cta. Ley 27541 Inc. E"
						STR0289,;	//Campo 18 = "Pgo. Cta. Imp. Mov. Prop."
						STR0290;	//Campo 19 = "Pgo. Cta. Can. Efe."
						})
		
		fAddTitulo(cNameWorkS, cNameTable, aTitulos[1], @oObjExcel)

	EndIf
	
Return oObjExcel

/*/{Protheus.doc} fDefImpReg
	Funci๓n utilizada para definir la impresi๓n del detalle de los
	registros.

	@type  Static Function
	@author marco.rivera
	@since 02/09/2024
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definici๓n de la planilla.
	@param cIdentReg, Character, Identificador de Registro a procesar.
	@param aDataExcel, Array, Arreglo que contiene datos del Registro.
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, N๚mero de la Tabla.
	@return oObjExcel, Object, Objeto que contiene la definici๓n de la planilla.
	@example
	fDefImpReg(oObjExcel, cIdentReg, aDataExcel, cNameWorkS, cNameTable)
/*/
Static Function fDefImpReg(oObjExcel, cIdentReg, aDataExcel, cNameWorkS, cNameTable)

	Local aRowOrange	:= {} //Arreglo con n๚mero de columnas a resaltar

	Default oObjExcel	:= Nil
	Default cIdentReg	:= ""
	Default aDataExcel	:= {}
	Default cNameWorkS	:= ""
	Default cNameTable	:= ""

	If cIdentReg == "01"
		aRowOrange	:= {1} //Se agrega el n๚mero de columna a resaltar en color naranja para Registro 01
	Else
		aRowOrange	:= {3, 15, 82, 119, 141, 160} //Se agrega el n๚mero de columna a resaltar en color naranja para Reg 02 en adelante
	EndIf
	
	//Se realiza la impresi๓n del rengl๓n
	oObjExcel:AddRow(cNameWorkS, cNameTable, aDataExcel, aRowOrange)
	
Return oObjExcel

/*/{Protheus.doc} fGenExcel
	Funci๓n utilizada para generar el archivo Excel en el directorio
	informado.

	@type  Static Function
	@author marco.rivera
	@since 02/09/2024
	@version 1.0
	@param oObjExcel, Object, Objeto que contiene la definici๓n de la planilla.
	@param cNomArcPla, Character, Nombre de la planilla a generar.
	@param cPerRCH, Character, Periodo procesado.
	@example
	fGenExcel(oObjExcel)
/*/
Static Function fGenExcel(oObjExcel, cNomArcPla, cPerRCH)

	Default oObjExcel	:= Nil
	Default cNomArcPla	:= ""

	cNomArcPla := "F1357." + AllTrim(StrTran(SM0->M0_CGC,"-","")) + "." + SubStr(cPerRCH,1,4) + "0000." + StrZero(Val(cSecuenc),4)

	oObjExcel:Activate()

	oObjExcel:GetXMLFile(cRutaArc + cNomArcPla + ".xml")

	FreeObj(oObjExcel)
	oObjExcel := Nil
	
Return

/*/{Protheus.doc} fViewExcel
	Funci๓n utilizada para generar el archivo Excel en el directorio
	informado.

	@type  Static Function
	@author marco.rivera
	@since 02/09/2024
	@version 1.0
	@param cNomArcPla, Character, Nombre de la planilla a generar.
	@example
	fViewExcel()
/*/
Static Function fViewExcel(cNomArcPla)

	Local oExcelApp		:= Nil
	
	Default cNomArcPla	:= ""

	//Se configura visualizaci๓n de la Planilla tras generaci๓n
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cRutaArc + cNomArcPla + ".xml")
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()

	FreeObj(oExcelApp)
	oExcelApp := Nil
	
Return

/*/{Protheus.doc} fAddTitulo
	Funci๓n utilizada para agregar al objeto las columnas al objetivo
	por registro y su respectivo tํtulo.

	@type  Static Function
	@author marco.rivera
	@since 09/10/2024
	@version 1.0
	@param cNameWorkS, Character, Nombre de la Hoja de Trabajo (Work Sheet).
	@param cNameTable, Character, N๚mero de la Tabla.
	@param aTitulos, Array, Arreglo con los tํtulos por registro.
	@return oObjExcel, Object, Objeto que contiene la definici๓n de la planilla.
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
	
Return
