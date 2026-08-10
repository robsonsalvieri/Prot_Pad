#include "Protheus.ch"
#include "topconn.ch"

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FATEMEX   ºAutor  ³Verónica Flores Falcón                            º Data ³  15/05/2023   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ XML de Documentos Electrónicos de Entrada                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT - Facturación                                                                     º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                       ACTUALLIZACIONES SUFRIDAS DESDE LA CONStrUCCIÓN INICIAL                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador           ³ Data       ³ BOPS        ³ Motivo de Alteración                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                      ³ 99/99/9999 ³ DMINA-XXXXX ³                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} FATEMEX
Genera el XML para Documentos de tipo Entrada (NCC)
@type function
@author veronica.flores
@since 15/05/2023
@version 1.0
@param cFilSF1, caracter, Filial de tabla SF1
@param cSerie, caracter, Serie del Documento
@param cDocumento, caracter, Número de Folio del Documento
@param cCliente, caracter, Código de Cliente del Documento
@param cLoja, caracter, Código de Tienda del Documento
@return Nil
@example
	FATEMEX(cFilSF1, cSerie, cDocumento, cCliente, cLoja)
@see (Usado en FATSMEX.PRW)
/*/
Function FATEMEX(cFilSF1, cSerie, cDocumento, cCliente, cLoja)
	Local aAreaSF1:= SF1->(GetArea())
	Local cXML    := ""
	Local cFecEmi := ""
	Local cFechaD := ""
	Local cNomXML := ""
	Local lComExt := .F.
	Local cFormaP := ""
	Local cCtrl   := (chr(13)+chr(10))
	Local cCadOri := ""
	Local cSepara := "|"
	Local aSM0    := {}
	Local cMoeSAT := ""
	Local cSello  := ""
	Local cCert   := IIf(FindFunction("FATXMICERT"),FATXMICERT(),"")  //Leer Certificado 
	Local nImpInc := 0
	Local cDesCondP  := ""
	Local cMetPagO   := ""
	Local cLgExp     := ""
	Local aDatosRec  := {}
	Local aDatosCli	 := {}
	Local cCFDICPG   := SuperGetMV("MV_CFDICPG", .F., "")
	Local cCliRegF   := ""
	Local cAI0MPago  := ""
	Local cFilAI0    := xFilial("AI0")
	Local cFilSA1    := xFilial("SA1")
	Local nDecTot    := 2
	Local cVerCFDI   := "4.0"
	Local cFPago     := ""
	Local cValSubT   := ""
	Local cTpoCam    := ""
	Local cExporta   := ""
	Local cDescto    := ""
	Local cTpoComp   := ""
	Local cValTot    := ""
	Local lPEXMLDoc  := ExistBlock("PEXMLDOC")
	Local lPEXMLCCE  := ExistBlock("PEXMLCCE")
	Local lPEEmRe    := ExistBlock("PEEMIREC")
	Local aRecp      := {}
	Local cSubTPE    := ""
	Local cTotPE     := ""
	Local cDescPE    := ""
	Local cTotImpPE  := ""
	Local cFecEPE    := ""
	Local cMetPE     := ""
	Local cForPE     := ""
	Local cMonPE     := ""
	Local cTpCPE     := ""
	Local cLgExPE    := ""
	Local lPEXMLAdi  := ExistBlock("PEXMLADIC")
	Local cPEConc    := ""
	Local cImpLoc    := ""
	Local aEmiCE     := {}
	Local aF3I       := {}
	Local aDatosCE   := {}
	Local lFuncF3I   := FindFunction("FATXVALF3I")
	Local aDetComE   := {}
	Local cComExt    := ""
	Local cExpoPE	 := ""
	Local lPECadOri	 := ExistBlock("PECADORI")
	Local lGenExp	 := .T.
	Local cCPEnt 	 := ""
	Local cSchemaXML := ""
	Local cXmlCompl  := ""
	Local lImpLoc    := .F. //Impuestos locales
	Local lPEXmlComp := ExistBlock("PEXMLCOMPL") //Punto de entrada para agregar complementos
	Local lPEXmlSche := ExistBlock("PEXMLSCHEM") //Punto de entrada para modificar el SchemaLocation
	Local cSeriePE := ""
	Local cFolioPE := ""
	Local cCondPagPE := ""
	Local cSerieDoc := ""
	Local cFolioDoc := ""

	Default cFilSF1    := xFilial("SF1") 
	Default cSerie     := ""
	Default cDocumento := ""
	Default cCliente   := ""
	Default cLoja      := ""

	aSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CGC", "M0_NOMECOM", "M0_DSCCNA", "M0_CEPENT", "M0_ENDCOB", "M0_CODZOSE", "M0_CODMUN"} )

	DbSelectArea("SF1")
	SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL+F1_TIPO
	If SF1->(MsSeek(cFilSF1 + cDocumento + cSerie + cCliente + cLoja))

		//Nombre del XML
		cNomXML := &(GetNewPar("MV_CFDNAF1","Lower(AllTrim(SF1->F1_ESPECIE)) + '_' + Lower(AllTrim(SF1->F1_SERIE)) + '_'  + Lower(AllTrim(SF1->F1_DOC)) + '.xml'"))

		//NCC con Complemento de Comercio Exterior
		lComExt := IIf(SuperGetMV("MV_CFDIEXP",.F.,.F.)  .And. !Empty(SF1->F1_TIPOPE), .T., .F.)
		
		//Monedas
		DbSelectArea("CTO")
		CTO->(DbSetOrder(1)) //CTO_FILIAL+CTO_MOEDA
		If CTO->(MsSeek(xFilial("CTO") + Strzero(SF1->F1_MOEDA,2)))
			cMoeSAT := AllTrim(CTO->CTO_MOESAT)
		EndIf		

		//Condición de Pago
		DbSelectArea("SE4")
		SE4->(DbSetOrder(1)) //E4_FILIAL+E4_CODIGO
		If SE4->(MsSeek(xFilial("SE4") + SF1->F1_COND))
			cDesCondP := AllTrim(SE4->E4_DESCRI)
			cMetPagO  := AllTrim(SE4->E4_MPAGSAT)
		EndIf

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		If SA1->(MsSeek(cFilSA1 + cCliente + cLoja)) 
			aAdd(aDatosCli,AllTrim(SA1->A1_CGC)) 
			aAdd(aDatosCli,AllTrim(SA1->A1_NOME))
			aAdd(aDatosCli,IIf(Alltrim(SA1->A1_CGC) $ "XEXX010101000|XAXX010101000",AllTrim(aSM0[4][2]),Alltrim(SA1->A1_CEP)))
			aAdd(aDatosCli,SA1->A1_END)
			aAdd(aDatosCli,SA1->A1_NR_END)
			aAdd(aDatosCli,SA1->A1_NROINT)
			aAdd(aDatosCli,SA1->A1_BAIRRO)
			aAdd(aDatosCli,SA1->A1_MUN)
			aAdd(aDatosCli,SA1->A1_EST)
			aAdd(aDatosCli,SA1->A1_PAIS)
			aAdd(aDatosCli,SA1->A1_CEP)
			aAdd(aDatosCli,Alltrim(SF1->F1_IDTRIB))
		EndIf

		//Complementos del Cliente
		If FindFunction("FATXCOMPCL")
			FATXCOMPCL(cFilAI0,SF1->F1_FORNECE,SF1->F1_LOJA,@cCliRegF,@cAI0MPago)
		EndIf
	
		If lPEXMLDoc
			cSubTPE := ExecBlock("PEXMLDOC",.F.,.F.,{"ST",.T.}) //Subtotal por Punto de Entrada
			cTotPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"T",.T.})  //Total por Punto de Entrada
			cDescPE := ExecBlock("PEXMLDOC",.F.,.F.,{"D",.T.})  //Descuento Total por Punto de Entrada
			cFecEPE := ExecBlock("PEXMLDOC",.F.,.F.,{"FE",.T.}) //Fecha de Emisión por Punto de Entrada
			cMetPE := ExecBlock("PEXMLDOC",.F.,.F.,{"MP",.T.}) //Metodo Pago
			cForPE := ExecBlock("PEXMLDOC",.F.,.F.,{"FP",.T.}) //Forma Pago
			cMonPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"MO",.T.}) //Moneda
			cTpCPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"TC",.T.}) //Tipo Cambio
			cLgExPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"LE",.T.}) //Lugar Expedición
			cExpoPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"E",.T.})  //Exportación
			cSeriePE  := ExecBlock("PEXMLDOC",.F.,.F.,{"SER",.T.})  //Serie
			cFolioPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"FOL",.T.})  //Folio
			cCondPagPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"CDP",.T.})  //Condiciones De Pago
		EndIf

		cSerieDoc := SF1->F1_SERIE
		cFolioDoc := SF1->F1_DOC
		/* Asigna el valor del punto de entrada PEXMLDOC */
		If lPEXMLDoc
			If !Empty(cSeriePE)
				cSerieDoc := cSeriePE
			EndIf
			If !Empty(cFolioPE)
				cFolioDoc := cFolioPE
			EndIf
			If !Empty(cCondPagPE)
				cDesCondP := cCondPagPE
			EndIf
		EndIf

		If lComExt
			aAdd(aDatosCE,SF1->F1_TRASLA) 
			aAdd(aDatosCE,SF1->F1_TIPOPE)
			aAdd(aDatosCE,SF1->F1_CVEPED) 
			aAdd(aDatosCE,SF1->F1_CERORI) 
			aAdd(aDatosCE,SF1->F1_NUMCER) 
			aAdd(aDatosCE,SF1->F1_EXPCONF) 
			aAdd(aDatosCE,SF1->F1_INCOTER) 
			aAdd(aDatosCE,SF1->F1_OBSCE)
			aAdd(aDatosCE,SF1->F1_TCUSD)
			aAdd(aDatosCE,SF1->F1_TOTUSD)
		EndIf
		
		//Fecha
		If !Empty(cFecEPE)
			cFechaD := cFecEPE
		ElseIf FindFunction("zh_FechaHoraUTC") .And. !Empty(cCFDICPG)
			cFechaD := zh_FechaHoraUTC(AllTrim(cCFDICPG),AllTrim(aSM0[4][2]),SF1->F1_EMISSAO,SF1->F1_HORA)
		Else
			cFecEmi := DtoS(SF1->F1_EMISSAO)
			cFechaD := Left(cFecEmi,4) + "-" + SubStr(cFecEmi,5,2)+ "-" + Right(cFecEmi,2)
			cFechaD += "T" + SF1->F1_HORA
		EndIf

		//Impuestos del Documento
		fImptosD(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,.F.,"SD1",.F.,@nImpInc, , , ,@aDetComE)


		//Forma de Pago
		cFormaP := IIf(SF1->(ColumnPos("F1_TPDOC")) > 0,AllTrim(SF1->F1_TPDOC),cAI0MPago)
		
		//Geración de Cadena Original
		cCadOri := cSepara + cSepara
		//Version
		cCadOri += cVerCFDI + cSepara
		//Serie
		cCadOri += AllTrim(cSerieDoc) + cSepara
		//Folio
		cCadOri += AllTrim(cFolioDoc) + cSepara
		//Fecha
		cCadOri += AllTrim(cFechaD) + cSepara
		//FormaPago
		If !EMPTY( cForPE )
			cFPago := cForPE
		Else
			cFPago := IIf(Empty(cFormaP) .Or. cMetPagO == "PPD","99",cFormaP)
		Endif
		cCadOri += cFPago + cSepara
		//NoCertificado
		cCadOri += AllTrim(SF1->F1_CERTFOL) + cSepara
		//CondicionesDePago
		cCadOri += CFDCarEsp(cDesCondP) + cSepara

		//Subtotal
		If !Empty(cSubTPE)
			cValSubT := cSubTPE
		Else
			cValSubT := AllTrim(Str((SF1->(F1_VALMERC+F1_FRETE+F1_SEGURO+F1_DESPESA) + SF1->F1_DESCONT) - nImpInc,14,nDecTot))
		EndIf
		cCadOri += cValSubT + cSepara
		//Descuento
		If SF1->F1_DESCONT > 0
			If !Empty(cDescPE)
				cDescto := cDescPE
			Else
				cDescto := AllTrim(Str(SF1->F1_DESCONT,14,2))
			EndIf
			cCadOri +=  cDescto + cSepara
		EndIf
		
		//Moneda
		If !EMPTY( cMonPE )
			cMoeSAT := cMonPE
		Endif
		cCadOri += cMoeSAT + cSepara
		
		//TipoCambio
		If !EMPTY( cTpCPE )
			cTpoCam := cTpCPE
		else
			cTpoCam := IIf(cMoeSAT <> "MXN", AllTrim(Str(SF1->F1_TXMOEDA,14,2)), "1")
		Endif
		cCadOri += cTpoCam + cSepara

		//Total
		If !Empty(cTotPE)
			cValTot := cTotPE
		Else
			cValTot := AllTrim(Str(IIf(GetSx3Cache("F1_VALBRUT","X3_DECIMAL") <= 2,SF1->F1_VALBRUT,Round(SF1->F1_VALBRUT,2)),14,nDecTot))
		EndIf
		cCadOri += cValTot + cSepara
		//TipoDeComprobante
		cTpoComp := IIf(AllTrim(SF1->F1_ESPECIE) == "NF","I", "E")
		cCadOri += cTpoComp + cSepara
		//Exportacion
		If !Empty(cExpoPE)
			cExporta := cExpoPE
		Else
			cExporta := IIf(lComExt .And. AllTrim(SF1->F1_ESPECIE) == "NCC","02", "01")
			If !Empty(SF1->F1_TIPOPE) .And. (Alltrim(SF1->F1_CVEPED) != "A1" .Or. Alltrim(SF1->F1_TIPOPE) == "3")
				cExporta := "04"
			EndIf
		EndIf

		If cExporta == "04" .And.( Empty(SF1->F1_CERORI) .Or. Empty(SF1->F1_INCOTER) .Or. Empty(SF1->F1_SUBDIV) .Or. Empty(SF1->F1_TCUSD) .Or. Empty(SF1->F1_TOTUSD))
			lGenExp := .F.
		EndIf
		lComExt  := lComExt  .And. lGenExp
		cCadOri += cExporta + cSepara
				
		//MetodoPago
		If !EMPTY( cMetPE )
			cMetPagO := cMetPE
		Endif
		cCadOri += cMetPagO + cSepara

		//LugarExpedicion
		If !EMPTY( cLgExPE )
			cLgExp := cLgExPE
		Else
			cLgExp := CFDCarEsp(AllTrim(aSM0[4][2]))
		Endif
		cCadOri += cLgExp  + cSepara

		//CFDI RELACIONADOS
		If FindFunction("fGetFolRel")
			If !Empty(SF1->F1_RELSAT) .Or. (!Empty(SF1->F1_SERMAN) .Or. !Empty(SF1->F1_DOCMAN))
					cCadOri += fGetFolRel("E",.T.)
			EndIf
		EndIf
		
		//DATOS DEL EMISOR
		If FindFunction("FATXMIEMIS")
			cCadOri += FATXMIEMIS(aSM0, .T., cSepara)
		EndIf

		//DATOS DEL RECEPTOR
		If FindFunction("FATXMIRECE")
			If lPEEmRe
				aRecp := ExecBlock("PEEMIREC",.F.,.F.,{"R"})
			EndIf
			aAdd(aDatosRec,AllTrim(SF1->F1_USOCFDI)) //Uso CFDI
			aAdd(aDatosRec,cCliRegF) //Régimen Fiscal
			aAdd(aDatosRec,Alltrim(AI0->AI0_IDFIS)) //NumRegIdTrib
			If cExporta $ "04" .And. Empty(SF1->F1_RESIDE)
				aAdd(aDatosRec,AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_CCESAT"))) //ResidenciaFiscal
			Else
				aAdd(aDatosRec,AllTrim(Posicione("SYA",1,xFilial("SYA")+SF1->F1_RESIDE,"YA_CCESAT"))) //ResidenciaFiscal
			EndIf
			cCadOri += FATXMIRECE(aSM0,SF1->F1_FORNECE,SF1->F1_LOJA,.T.,cSepara,.F., lComExt,.F.,.F., aDatosRec,aDatosCli,,aRecp,cExporta)
		EndIf

		//Ejecución Punto de Entrada Conceptos y Total de Impuestos
		If lPEXMLDoc
			cPEConc   := ExecBlock("PEXMLDOC",.F.,.F.,{"CO",.T.}) // Conceptos
			cTotImpPE := ExecBlock("PEXMLDOC",.F.,.F.,{"TI",.T.}) //Total de Impuestos por Punto de Entrada
		EndIf
		
		//Conceptos
		If !Empty(cPEConc)
			cCadOri += cPEConc
		Else
			cCadOri += fXMLFUN("CO",.T.)
		ENDIF
		
		//Total de Impuestos
		If !Empty(cTotImpPE)
			cCadOri += cTotImpPE
		Else
			cCadOri += fXMLFUN("TI",.T.)
		EndIf

		//Impuestos Locales
		cImpLoc := fXMLFUN("IL",.T.)
		If !Empty(cImpLoc)
			cCadOri += cImpLoc
			lImpLoc := .T.
		EndIf

		If FindFunction("FATXCOMEXT") .And. lComExt
			cCPEnt := AllTrim(aSM0[4][2])
			aAdd(aEmiCE,CFDCarEsp(AllTrim(aSM0[5][2]))) //M0_ENDCOB
			aAdd(aEmiCE,IIf(!Empty(cCPEnt),CFDCarEsp(AllTrim(ObtColSAT("S015",AllTrim(aSM0[6][2])+cCPEnt,1,9,1,4))),"")) //M0_CEPENT //M0_CODZOSE
			aAdd(aEmiCE,IIf(!Empty(aSM0[7][2]),AllTrim(aSM0[7][2]),"")) //M0_CODMUN
			If lFuncF3I 					
				aF3I := FATXVALF3I("S004","Codigo",cCPEnt)
			EndIf
			aAdd(aEmiCE,IIf(Len(aF3I) > 2,CFDCarEsp(aF3I[2]),"")) //M0_CEPENT
			aAdd(aEmiCE,"MEX") 
			aAdd(aEmiCE,cCPEnt) //M0_CEPENT
			If Len(aF3I) >= 4 .And. !Empty(aF3I[4])
				aAdd(aEmiCE,CFDCarEsp(AllTrim((aF3I[4])))) //Localidad
			Else
				aAdd(aEmiCE,"") //Localidad		
			EndIf
			//Punto de entrada para personalizar nodos de CCE
			If lPEXMLCCE
				aEmiCE := ExecBlock("PEXMLCCE",.F.,.F.,{"EM",aEmiCE})
				aDatosCli := ExecBlock("PEXMLCCE",.F.,.F.,{"RE",aDatosCli})
				aDetComE := ExecBlock("PEXMLCCE",.F.,.F.,{"MER",aDetComE})
			Endif
			cComExt := FATXCOMEXT(.T., aDatosCE, cSepara, aEmiCE, aDatosCli, aDatosRec, aDetComE)
		EndIf

		If !Empty(cComExt)
			cCadOri += cComExt
		EndIf

		If lPEXmlComp //Agregar cadena original de complemento
			cCadOri += ExecBlock("PEXMLCOMPL", .F., .F., {"E", .T., SF1->F1_ESPECIE})
		EndIf

		cCadOri += cSepara

		//Encriptación de la Cadena Original
		If FindFunction("FATXMISECA")
			cSello := FATXMISECA(cCadOri)
		EndIf
		//PE Cadena Original
		If lPECadOri
			ExecBlock("PECADORI",.F.,.F.,{cCadOri})
		EndIf

		//Geración de XML
		cXML := '<?xml version="1.0" encoding="UTF-8"?>' + cCtrl
		cXML += '<cfdi:Comprobante'
		
		cSchemaXML := ' xmlns:cfdi="http://www.sat.gob.mx/cfd/4"'
		//Impuestos Locales
		If lImpLoc
			cSchemaXML += ' xmlns:implocal="http://www.sat.gob.mx/implocal"'
		EndIf
		cSchemaXML += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
		cSchemaXML += ' xsi:schemaLocation='
		cSchemaXML += '"'
		cSchemaXML += 'http://www.sat.gob.mx/cfd/4 http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd' 
		//Impuestos Locales
		If lImpLoc
			cSchemaXML += ' http://www.sat.gob.mx/implocal http://www.sat.gob.mx/sitio_internet/cfd/implocal/implocal.xsd'
		ENDIF
		//Comercio Exterior
		If lComExt
			cSchemaXML += ' http://www.sat.gob.mx/ComercioExterior20 http://www.sat.gob.mx/sitio_internet/cfd/ComercioExterior20/ComercioExterior20.xsd'			
		EndIf
		cSchemaXML += '"'
		//Comercio Exterior
		If lComExt
			cSchemaXML += ' xmlns:cce20="http://www.sat.gob.mx/ComercioExterior20"'
		EndIf

		If lPEXmlSche //Modificar schemalocation
			cSchemaXML := ExecBlock("PEXMLSCHEM", .F., .F., {"E", cSchemaXML, SF1->F1_ESPECIE, {lImpLoc, .F., .F., lComExt}})
		EndIf

		cXML += cSchemaXML

		cXML += ' Version="' + cVerCFDI + '"'
		cXML += ' Serie="' + AllTrim(cSerieDoc) + '"'
		cXML += ' Folio="' + AllTrim(cFolioDoc) + '"'
		cXML += ' Fecha="' + AllTrim(cFechaD) + '"'
		cXML += ' Sello="' + cSello + '"'
		cXML += ' FormaPago="' + cFPago + '"'
		cXML += ' NoCertificado="' + AllTrim(SF1->F1_CERTFOL) + '"'
		cXML += ' Certificado="' + cCert + '"'
		cXML += ' CondicionesDePago="' +  CFDCarEsp(cDesCondP) + '"'
		cXML += ' SubTotal="' + cValSubT + '"'
		If SF1->F1_DESCONT > 0
			cXML += ' Descuento="' + cDescto + '"'
		EndIf
		cXML += ' Moneda="' + cMoeSAT + '"'
		cXML += ' TipoCambio="' + cTpoCam + '"'
		cXML += ' Total="' + cValTot +  '"'
		cXML += ' TipoDeComprobante="' + cTpoComp + '"'
		cXML += ' Exportacion="' + cExporta + '"'
		cXML += ' MetodoPago="' +  cMetPagO + '"' 
		cXML += ' LugarExpedicion="' + cLgExp+ '"'
		cXML += '>' + cCtrl

		//CFDI RELACIONADOS
		If FindFunction("fGetFolRel")
			If !Empty(SF1->F1_RELSAT) .Or. (!Empty(SF1->F1_SERMAN) .Or. !Empty(SF1->F1_DOCMAN))
				cXML += fGetFolRel("E",.F.) + cCtrl
			EndIf
		EndIf

		//DATOS DEL EMISOR
		If FindFunction("FATXMIEMIS")
			cXML += FATXMIEMIS(aSM0, .F., cSepara)
		EndIf

		//DATOS DEL RECEPTOR
		If FindFunction("FATXMIRECE")
			cXML += FATXMIRECE(aSM0,SF1->F1_FORNECE,SF1->F1_LOJA,.F.,cSepara,.F.,lComExt,.F.,.F., aDatosRec,aDatosCli,,aRecp,cExporta)
		EndIf

		//Ejecución Punto de Entrada para Conceptos y Total de Impuestos
		If lPEXMLDoc
			cPEConc   := ExecBlock("PEXMLDOC",.F.,.F.,{"CO",.F.}) // Conceptos
			cTotImpPE := ExecBlock("PEXMLDOC",.F.,.F.,{"TI",.F.}) //Total de Impuestos por Punto de Entrada
		EndIf

		//Conceptos
		If !Empty(cPEConc)
			cXML += cPEConc
		Else
			cXML += fXMLFUN("CO",.F.,,)
		ENDIF
		
		//Total de Impuestos
		If !Empty(cTotImpPE)
			cXML += cTotImpPE
		Else
			cXML += cCtrl + fXMLFUN("TI",.F.,)
		EndIf
		
		//Impuestos Locales
		cImpLoc := fXMLFUN("IL",.F.)

		//Comercio Exterior
		If FindFunction("FATXCOMEXT") .And. lComExt
			cComExt := FATXCOMEXT(.F., aDatosCE, "", aEmiCE, aDatosCli, aDatosRec, aDetComE)
		EndIf

		If lPEXmlComp //Agregar nodo de complemento al XML
			cXmlCompl := ExecBlock("PEXMLCOMPL", .F., .F., {"E", .F., SF1->F1_ESPECIE})
		EndIf

		If !Empty(cImpLoc) .Or. !Empty(cComExt) .Or. !Empty(cXmlCompl)
			cXML += '	<cfdi:Complemento>' + cCtrl
			cXML += IIf(!Empty(cImpLoc),cImpLoc,"")
			cXML += IIf(!Empty(cComExt),cComExt,"")
			If !Empty(cXmlCompl)
				cXML += cXmlCompl
			EndIf
			cXML += '	</cfdi:Complemento>' + cCtrl
		EndIf
		If lPEXMLAdi
			cXML += (chr(13)+chr(10)) + ExecBlock("PEXMLADIC",.F.,.F.) //Información Adicional por Punto de Entrada
		EndIf
		cXML += '</cfdi:Comprobante>'
	EndIf

	//Creación del XML
	If FindFunction("FATXMICREA") .And. !Empty(cXML)
		FATXMICREA(cXML, cNomXML)
	EndIf

	RestArea(aAreaSF1)
Return Nil
