#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
| Descripcion: Clase para manejar las impresiones PDF.                |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARPrinter

	DATA lPDF
	DATA oPrn
	DATA lImprimir As Logical
	
	DATA cPathPdf
	DATA cPathRel
	DATA cNombre
	DATA cDirPDF
	DATA aFontes
	DATA aString
	DATA lVerCoor
	
	DATA nTamFila
	DATA nTamCol
	
	DATA nAjuFil	
	DATA nAjuCol
	
	DATA nHorizontal
	DATA nVertical

	METHOD New() CONSTRUCTOR
	METHOD setDesplazamiento()
	METHOD setPrinter()
	METHOD setPDF()
	METHOD imprimePDF()
	METHOD mueve()
	METHOD borra()
	METHOD visualiza()
	METHOD guardaCoordenadas()
	METHOD Fila()
	METHOD Columna()
	
	METHOD StartPage()
	METHOD EndPage()	
	METHOD Say()
	METHOD SayAlign()
	METHOD SayBitmap()
	METHOD Box()
	METHOD Line()
	METHOD CodBar()
	METHOD QrCode()
	
ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(lPDF, nPorcAju, nTamFila, nTamCol, lVerCoor) CLASS ARPrinter 

	Local nX	:= 0			
	Local nPorc	:= IIf(nPorcAju<>Nil, nPorcAju/100, 1) * IIf(lPDF, 1, 1)
	
	::lPDF		:= lPDF
	::oPrn		:= Nil
	::cPathPdf	:= IIf(isBlind(), "\system\", GetTempPath())
	::cPathRel	:= "\spool\"
	::aFontes	:= {}
	::aString	:= {}
	::nAjuFil	:= IIf(lPDF, 0.90, 1)
	::nAjuCol	:= IIf(lPDF, 0.98, 1)
	::nTamFila	:= IIf(nTamFila <> Nil, nTamFila, 50) * ::nAjuFil
	::nTamCol	:= IIf(nTamCol <> Nil, nTamCol, 50) * ::nAjuCol
	::lVerCoor	:= IIf(lVerCoor <> Nil, lVerCoor, .F.)
	::lImprimir := .T.
	
	::setPrinter()
	::setDesplazamiento(0,0)
	
	// Del 01 a 15 Arial Normal
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Arial",, nX*nPorc,, .F.,,,, .T., .F. ))
	Next nX

	// Del 16 a 30 Arial Bold
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Arial",, nX*nPorc,, .T.,,,, .T., .F. ))
	Next nX

	// Del 31 a 45 Courier New Normal
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Courier New",, nX*nPorc,, .F.,,,, .T., .F. ))
	Next nX

	// Del 46 a 60 Courier New Bold
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Courier New",, nX*nPorc,, .T.,,,, .T., .F. ))
	Next nX
	
	// Del 61 a 75 Segoe UI Normal
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Segoe UI",, nX*nPorc,, .F.,,,, .T., .F. ))
	Next nX	

	// Del 76 a 90 Segoe UI Bold
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "Segoe UI",, nX*nPorc,, .T.,,,, .T., .F. ))
	Next nX	

	// Del 61 a 75 DejaVu Sans Mono Normal
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "DejaVu Sans Mono",, nX*nPorc,, .F.,,,, .T., .F. ))
	Next nX	

	// Del 76 a 90 DejaVu Sans Mono Bold
	For nX := 6 To 20	
		aAdd(::aFontes, TFont():New( "DejaVu Sans Mono",, nX*nPorc,, .T.,,,, .T., .F. ))
	Next nX		
	
RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setPrinter() CLASS ARPrinter 
	
	If !::lPDF .And. ::oPrn == Nil
		::oPrn:=FwMSPrinter():New("Spool",2)

		If ::oPrn:nModalResult == 2 //Si se cancela la impresión
			::lImprimir := .F.
		Else
			If ::oPrn:nDevice == 6 // PDF
				::oPrn:SetResolution(72)
				::nAjuFil	:= 0.90
				::nAjuCol	:= 0.98
				::nTamFila	:= ::nTamFila * ::nAjuFil
				::nTamCol	:= ::nTamCol * ::nAjuCol
			EndIf

		::oPrn:SetPortrait()
		::oPrn:SetPaperSize(DMPAPER_A4)
		::oPrn:SetMargin(10,10,10,10)
		EndIf
	EndIf
	
RETURN ::oPrn

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setPDF(cNombre, cDirPDF) CLASS ARPrinter

	If ::lPDF
		If cNombre != Nil			
			::cNombre := cNombre
			::cDirPDF := cDirPDF + IIf(Right(Alltrim(cDirPDF),1) <> "\", "\", "")
			
			::oPrn:=FwMSPrinter():New(cNombre,6,.T.,::cPathRel,.T.,,,,.T.)
			::oPrn:SetResolution(72)	// GDC - 78
			::oPrn:SetPortrait()
			::oPrn:SetPaperSize(DMPAPER_A4)
			::oPrn:SetMargin(10,10,10,10)

			::oPrn:CPATHPDF	:= ::cPathPdf
			::oPrn:LVIEWPDF	:= .F. 
			::oPrn:CPRINTER	:= "PDF"
			::oPrn:NDEVICE	:= 6                                                            
			::oPrn:CPATHPRINT	:= ::cPathPdf
		EndIf
	EndIf
	
RETURN ::oPrn

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDesplazamiento(nHorizontal, nVertical) CLASS ARPrinter 

	If nHorizontal <> Nil
		::nHorizontal := nHorizontal
	EndIf
	
	If nVertical <> Nil
		::nVertical := nVertical
	EndIf
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD imprimePDF() CLASS ARPrinter 
		
	If ::lPDF .And. ::oPrn <> Nil
		::oPrn:Print()
		::mueve()
		::borra()
		Ms_Flush()
		
	EndIf
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD mueve() CLASS ARPrinter

	Local aArchOld 	:= {}
	Local cNomTmp		:= ""
	Local nI 		:= 0

	Local lCopio	:= .F.

	aArchOld := Directory( ::cPathPdf + ::cNombre + "*.PDF" )

	For nI := 1 to Len( aArchOld )
		cNomTmp := AllTrim(aArchOld[nI][1])
		lCopio := __CopyFile(::cPathPdf + cNomTmp, ::cDirPDF + cNomTmp)
	Next nI 

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD borra() CLASS ARPrinter

	Local cTmp		:= ::cPathPdf
	Local aArchOld	:= Directory( cTmp + "*.PDF" )
	Local nI		:= 1

	For nI := 1 to Len( aArchOld )
		FErase( cTmp + aArchOld[nI][1])
	Next nI

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD visualiza() CLASS ARPrinter

	If !::lPDF
		::oPrn:Preview()
		Ms_Flush()
			
	EndIf

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD StartPage() CLASS ARPrinter

	::oPrn:StartPage()

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD EndPage() CLASS ARPrinter

	::oPrn:EndPage()

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD Say(nFila, nCol, cTexto, nFont) CLASS ARPrinter

	::oPrn:Say(::Fila(nFila), ::Columna(nCol), cTexto, ::aFontes[nFont], 100)

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD SayAlign(nFila, nCol, cTexto, nFont, nWidth, nAlign) CLASS ARPrinter
	
	::oPrn:SayAlign(::Fila(nFila), ::Columna(nCol), cTexto, ::aFontes[nFont], nWidth, 200, Nil, nAlign)

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD SayBitmap(nFila, nCol, cBMP, nWidth, nHeight) CLASS ARPrinter

	::oPrn:SayBitmap(::Fila(nFila), ::Columna(nCol), cBMP, nWidth, nHeight)

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD Box(nTop, nLeft, nBottom, nRight) CLASS ARPrinter

	::oPrn:Box(::Fila(nTop), ::Columna(nLeft), ::Fila(nBottom), ::Columna(nRight))
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD Line(nTop, nLeft, nBottom, nRight) CLASS ARPrinter

	::oPrn:Line(::Fila(nTop), ::Columna(nLeft), ::Fila(nBottom), ::Columna(nRight))
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD Fila(nFila) CLASS ARPrinter
RETURN ( nFila * ::nTamFila ) + ::nVertical

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD Columna(nCol) CLASS ARPrinter
RETURN ( nCol * ::nTamCol ) + ::nHorizontal

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD CodBar(cCod, nFil, nCol) CLASS ARPrinter

::oPrn:FWMsBar("INT25", nFil*::nAjuFil, nCol*::nAjuCol, cCod, ::oPrn, .F., Nil, Nil, 0.017, 0.8, .F., Nil, Nil,.F.)

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPrinter  | Autor: Andres Demarziani | Fecha: 25/04/22  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD QRCode(nFil, nCol, cCod, nTam) CLASS ARPrinter

	If ::lPDF
		nTam *= 0.9
	EndIf

	::oPrn:QrCode(::Fila(nFil), ::Columna(nCol), cCod, nTam)

RETURN Nil







