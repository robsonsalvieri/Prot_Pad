#include "Protheus.ch"
#include "topconn.ch"

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  FATSMEX   ºAutor  ³Luis Eduardo Enríquez Mata                        º Data ³  18/10/2022   º±±
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
/*/{Protheus.doc} FATSMEX
Genera el XML para Documentos de tipo Salida (NF/NDC)
@type function
@author luis.enríquez
@since 31/10/2022
@version 1.0
@param cFilSF2, caracter, Filial de tabla SF2
@param cSerie, caracter, Serie del Documento
@param cDocumento, caracter, Número de Folio del Documento
@param cCliente, caracter, Código de Cliente del Documento
@param cLoja, caracter, Código de Tienda del Documento
@return Nil
@example
FATSMEX(cFilSF2, cSerie, cDocumento, cCliente, cLoja)
@see (Usado en FATSMEX.PRW)
/*/
Function FATSMEX(cFilSF2, cSerie, cDocumento, cCliente, cLoja)
	Local aAreaSF2:= SF2->(GetArea())
	Local cXML    := ""
	Local cFecEmi := ""
	Local cFechaD := ""
	Local cNomXML := ""
	Local lDocTras:= .F.
	Local lFacGlo := .F.
	Local lCartaP := .F.
	Local lComExt := .F.
	Local lLeyFis := .F.
	Local lGenExp := .F.
	Local lDatoT  := .F.
	Local cFormaP := ""
	Local cCtrl   := (chr(13)+chr(10))
	Local cCadOri := ""
	Local cSepara := "|"
	Local aSM0    := {}
	Local cMoeSAT := ""
	Local cSello  := ""
	Local cCert   := IIf(FindFunction("FATXMICERT"),FATXMICERT(),"")  //Leer Certidicado 
	Local nImpInc := 0
	Local nTotBon := 0
	Local cDesCondP  := ""
	Local cMetPagO   := ""
	Local nDesCPorte := 0
	Local nImpCPorte := 0
	Local aDatosRec  := {}
	Local cCFDICPG   := SuperGetMV("MV_CFDICPG", .F., "")
	Local lCompComE  := SuperGetMV("MV_CFDIEXP",.F.,.F.)
	Local lCadCon    := SuperGetMV("MV_COCONSO", .F., "") == "S"
	Local cCliRegF   := ""
	Local cAI0MPago  := ""
	Local cFilAI0    := xFilial("AI0")
	Local nDecTot    := 2
	Local cVerCFDI   := "4.0"
	Local cFPago     := ""
	Local cValSubT   := ""
	Local cMoneda    := ""
	Local cTpoCam    := ""
	Local cExporta   := "01"
	Local cDescto    := ""
	Local cTpoComp   := ""
	Local cValTot    := ""
	Local cImpLoc    := ""
	Local cComExt    := ""
	Local cLeyFis    := ""
	Local cCartaP    := ""
	Local aDatosCE   := {}
	Local aDatosCli  := {}
	Local cLgExp     := ""
	Local cFilSA1    := xFilial("SA1")
	Local aDetComE   := {}
	Local aImpResta  := {}
	Local lCpoConUNi := SF2->(FieldPos("F2_CONUNI")) > 0
	Local cPFisica   := ""
	Local aEmiCE     := {}
	Local aF3I       := {}
	Local lFuncF3I   := FindFunction("FATXVALF3I")
	Local lPEXMLDoc    := ExistBlock("PEXMLDOC")
	Local lPEXMLCCE    := ExistBlock("PEXMLCCE")
	Local cSubTPE    := ""
	Local cTotPE     := ""
	Local cMonPE     := ""
	Local cTpCPE     := ""
	Local cDescPE    := ""
	Local cTotImpPE  := ""
	Local cFecEPE    := ""
	Local cMetPE     := ""
	Local cForPE     := ""
	Local cLgExPE     := ""
	Local lPEEmRe    := ExistBlock("PEEMIREC")
	Local aRecp      := {}
	Local lPEXMLAdi  := ExistBlock("PEXMLADIC")
	Local cPEConc    := ""
	Local cExpoPE	 := ""
	Local lUlTVerCP  := SuperGetMV("MV_ACTCOCP", .F., .T.)
	Local lPECadOri	 := ExistBlock("PECADORI")
	Local lCfdVlTras := SF2->(ColumnPos("F2_CFDVLTR")) > 0
	Local cCfdVlTras := "1"
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

	Default cFilSF2    := xFilial("SF2") 
	Default cSerie     := ""
	Default cDocumento := ""
	Default cCliente   := ""
	Default cLoja      := ""

	aSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CGC", "M0_NOMECOM", "M0_DSCCNA", "M0_CEPENT", "M0_ENDCOB", "M0_CODZOSE", "M0_CODMUN"} )

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF2->(MsSeek(cFilSF2 + cDocumento + cSerie + cCliente + cLoja))

		//Nombre del XML
		cNomXML := &(GetNewPar("MV_CFDNAF2","Lower(AllTrim(SF2->F2_ESPECIE)) + '_' + Lower(AllTrim(SF2->F2_SERIE)) + '_'  + Lower(AllTrim(SF2->F2_DOC)) + '.xml'"))

		//Monedas
		DbSelectArea("CTO")
		CTO->(DbSetOrder(1)) //CTO_FILIAL+CTO_MOEDA
		If CTO->(MsSeek(xFilial("CTO") + Strzero(SF2->F2_MOEDA,2)))
			cMoeSAT := AllTrim(CTO->CTO_MOESAT)
		EndIf		

		//Condición de Pago
		DbSelectArea("SE4")
		SE4->(DbSetOrder(1)) //E4_FILIAL+E4_CODIGO
		If SE4->(MsSeek(xFilial("SE4") + SF2->F2_COND))
			cDesCondP := AllTrim(SE4->E4_DESCRI)
			cMetPagO  := AllTrim(SE4->E4_MPAGSAT)
		EndIf

		//Documento de Traslado
		lDocTras := AllTrim(SF2->F2_TIPODOC) == "21"

		//Documento de Venta Global
		lFacGlo := SF2->F2_GLOBAL == '1'

		//Documento con Complemento de Carta Porte
		lCartaP := SF2->(ColumnPos("F2_TPCOMPL")) > 0 .And. AllTrim(SF2->F2_TPCOMPL) == "S"

		lComExt := lCompComE .And. !Empty(SF2->F2_TIPOPE)

		lDatoT := lDocTras .And. ((!(Alltrim(SF2->F2_TIPOPE) $ "3|4")) .Or. lCartaP)
	
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		If SA1->(MsSeek(cFilSA1 + cCliente + cLoja)) 
			aAdd(aDatosCli,IIf(lDatoT,AllTrim(aSM0[1][2]),Alltrim(SA1->A1_CGC))) 
			aAdd(aDatosCli,IIf(lDatoT,AllTrim(aSM0[2][2]),Alltrim(SA1->A1_NOME)))
			aAdd(aDatosCli,IIf(lDatoT .Or. Alltrim(SA1->A1_CGC) $ "XEXX010101000|XAXX010101000",AllTrim(aSM0[4][2]),Alltrim(SA1->A1_CEP)))
			aAdd(aDatosCli,SA1->A1_END)
			aAdd(aDatosCli,SA1->A1_NR_END)
			aAdd(aDatosCli,SA1->A1_NROINT)
			aAdd(aDatosCli,SA1->A1_BAIRRO)
			aAdd(aDatosCli,SA1->A1_MUN)
			aAdd(aDatosCli,SA1->A1_EST)
			aAdd(aDatosCli,SA1->A1_PAIS)
			aAdd(aDatosCli,SA1->A1_CEP)
			aAdd(aDatosCli,Alltrim(SF2->F2_IDTRIB))
			cPFisica := SA1->A1_PFISICA
		EndIf

		//Complementos del Cliente
		If FindFunction("FATXCOMPCL")
			FATXCOMPCL(cFilAI0,SF2->F2_CLIENTE,SF2->F2_LOJA,@cCliRegF,@cAI0MPago)
		EndIf

		If lPEXMLDoc
			cSubTPE := ExecBlock("PEXMLDOC",.F.,.F.,{"ST",.T.}) //Subtotal por Punto de Entrada
			cTotPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"T",.T.})  //Total por Punto de Entrada
			cDescPE := ExecBlock("PEXMLDOC",.F.,.F.,{"D",.T.})  //Descuento Total por Punto de Entrada
			cFecEPE := ExecBlock("PEXMLDOC",.F.,.F.,{"FE",.T.}) //Fecha de Emisión por Punto de Entrada
			cMetPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"MP",.T.}) //Metodo Pago
			cForPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"FP",.T.}) //Forma Pago
			cMonPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"MO",.T.}) //Moneda
			cTpCPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"TC",.T.}) //Tipo Cambio
			cLgExPe := ExecBlock("PEXMLDOC",.F.,.F.,{"LE",.T.}) //Lugar Expedición
			cExpoPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"E",.T.})  //Exportación
			cSeriePE  := ExecBlock("PEXMLDOC",.F.,.F.,{"SER",.T.})  //Serie
			cFolioPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"FOL",.T.})  //Folio
			If !lDocTras
				cCondPagPE  := ExecBlock("PEXMLDOC",.F.,.F.,{"CDP",.T.})  //Condiciones De Pago
			EndIf
		EndIf

		//Documento con Complemento de Comercio Exterior
		If !Empty(cExpoPE)
			cExporta := cExpoPE
		Else
			If !Empty(SF2->F2_TIPOPE)
				cExporta := IIf(Alltrim(SF2->F2_TIPOPE)== "4","03",IIf(SF2->F2_CVEPED != "A1" .Or. Alltrim(SF2->F2_TIPOPE) == "3", "04", "02"))
			EndIf
		EndIf
		lGenExp  := IIf(cExporta == "03" .Or.(cExporta == "04" .And.( Empty(SF2->F2_CERORI) .Or. Empty(SF2->F2_INCOTER) .Or. Empty(SF2->F2_SUBDIV) .Or. Empty(SF2->F2_TCUSD) .Or. Empty(SF2->F2_TOTUSD))) ,.F.,.T.)
		lComExt  := lComExt  .And. lGenExp

		cSerieDoc := SF2->F2_SERIE
		cFolioDoc := SF2->F2_DOC
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
			aAdd(aDatosCE,SF2->F2_TRASLA) 
			aAdd(aDatosCE,SF2->F2_TIPOPE)
			aAdd(aDatosCE,SF2->F2_CVEPED) 
			aAdd(aDatosCE,SF2->F2_CERORI) 
			aAdd(aDatosCE,SF2->F2_NUMCER) 
			aAdd(aDatosCE,SF2->F2_EXPCONF) 
			aAdd(aDatosCE,SF2->F2_INCOTER) 
			aAdd(aDatosCE,SF2->F2_OBSCE)
			aAdd(aDatosCE,SF2->F2_TCUSD)
			aAdd(aDatosCE,SF2->F2_TOTUSD)
		EndIf

		//Total de Bonificaciones
		nTotBon := fSumBC(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA)

		nDecTot := IIf(lDocTras,0,2)

		//Fecha
		If !Empty(cFecEPE)
			cFechaD := cFecEPE
		Else
			If FindFunction("zh_FechaHoraUTC") .And. !Empty(cCFDICPG)
				cFechaD := zh_FechaHoraUTC(AllTrim(cCFDICPG),AllTrim(aSM0[4][2]),SF2->F2_EMISSAO,SF2->F2_HORA)
			Else
				cFecEmi := DtoS(SF2->F2_EMISSAO)
				cFechaD := Left(cFecEmi,4) + "-" + SubStr(cFecEmi,5,2)+ "-" + Right(cFecEmi,2)
				cFechaD += "T" + SF2->F2_HORA
			EndIf
		EndIf

		//Impuestos del Documento
		fImptosD(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,lDocTras,"SD2",lFacGlo,@nImpInc,lCartaP,@nDesCPorte, @nImpCPorte, @aDetComE, @aImpResta)

		
		//Forma de Pago
		cFormaP := IIf(SF2->(ColumnPos("F2_TPDOC")) > 0,AllTrim(SF2->F2_TPDOC),cAI0MPago)

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
		If !lDocTras
			If !EMPTY( cForPE )
				cFPago := cForPE
			Else
				cFPago := IIf(lFacGlo,FormPagGlo(SF2->F2_DOC,SF2->F2_SERIE),IIf(Empty(cFormaP) .Or. cMetPagO == "PPD","99",cFormaP))
			Endif
			cCadOri += cFPago + cSepara
		EndIf
		//NoCertificado
		cCadOri += AllTrim(SF2->F2_CERTFOL) + cSepara
		//CondicionesDePago
		If !lDocTras
			cCadOri += CFDCarEsp(cDesCondP) + cSepara
		EndIf
		//Subtotal
		If !Empty(cSubTPE)
			cValSubT := cSubTPE
		Else
			cValSubT := AllTrim(IIf(lDocTras,Str(0),Str((SF2->(F2_VALMERC+F2_FRETE+F2_SEGURO+F2_DESPESA) + nTotBon + SF2->F2_DESCONT) - nImpInc - nDesCPorte,14,nDecTot)))
		EndIf

		cCadOri += cValSubT + cSepara

		//Descuento
		If !lDocTras .And. SF2->F2_DESCONT > 0
			If !Empty(cDescPE)
				cDescto := cDescPE
			Else
				cDescto := AllTrim(Str(SF2->F2_DESCONT,14,2))
			EndIf
			cCadOri +=  cDescto + cSepara
		EndIf
		
		//Moneda
		If !EMPTY( cMonPE )
			cMoneda := cMonPE
		else
			cMoneda := IIf(lDocTras,"XXX",cMoeSAT)
		Endif
		cCadOri += cMoneda + cSepara

		//TipoCambio
		If !EMPTY( cTpCPE )
			cTpoCam := cTpCPE
		Else
			If !lDocTras
				cTpoCam := IIf(cMoeSAT <> "MXN", AllTrim(Str(SF2->F2_TXMOEDA,14,2)), "1")
			EndIf
		Endif
		cCadOri += Iif(!EMPTY( cTpoCam ) ,cTpoCam+ cSepara,"")
		//Total
		If !Empty(cTotPE)
			cValTot := cTotPE
		Else
			cValTot := AllTrim(IIf(lDocTras,Str(0),Str(IIf(GetSx3Cache("F2_VALBRUT","X3_DECIMAL") <= 2,SF2->F2_VALBRUT,Round(SF2->F2_VALBRUT,2)) + nTotBon - nDesCPorte - nImpCPorte - IIf(Len(aImpResta) > 0,aImpResta[1],0),14,nDecTot)))			
		EndIf
		
		cCadOri += cValTot + cSepara

		//TipoDeComprobante
		cTpoComp := IIf(AllTrim(SF2->F2_ESPECIE) == "NF",IIf(lDocTras, "T", "I" ), "E")
		cCadOri += cTpoComp + cSepara

		//Exportacion
		cCadOri += cExporta + cSepara

		//MetodoPago
		If !EMPTY( cMetPE )
			cMetPagO := cMetPE
		Endif
		If !lDocTras
			cCadOri += cMetPagO + cSepara
		EndIf

		//LugarExpedicion
		If !EMPTY( cLgExPE )
			cLgExp := cLgExPE
		Else
			cLgExp := CFDCarEsp(AllTrim(aSM0[4][2]))
		Endif
		cCadOri += cLgExp  + cSepara

		//CFDI RELACIONADOS
		If FindFunction("fGetFolRel")
			If !Empty(SF2->F2_RELSAT) .Or. (!Empty(SF2->F2_SERMAN) .Or. !Empty(SF2->F2_DOCMAN))
				If !(lCartaP .And. lDocTras)
					cCadOri += fGetFolRel("S",.T.)
				EndIf
			EndIf
		EndIf
		
		//DATOS DEL EMISOR
		If FindFunction("FATXMIEMIS")
			cCadOri += FATXMIEMIS(aSM0, .T., cSepara)
		EndIf

		If AllTrim(SF2->F2_ESPECIE) <> "NDI"
			//DATOS DEL RECEPTOR
			If FindFunction("FATXMIRECE")
				If lPEEmRe
					aRecp := ExecBlock("PEEMIREC",.F.,.F.,{"R"})
				EndIf
				aAdd(aDatosRec,AllTrim(SF2->F2_USOCFDI)) //Uso CFDI
				aAdd(aDatosRec,IIf(lDatoT,AllTrim(aSM0[3][2]),cCliRegF))   //Régimen Fiscal
				aAdd(aDatosRec,Alltrim(AI0->AI0_IDFIS)) //NumRegIdTrib
				If cExporta $ "04" .And. Empty(SF2->F2_RESIDE)
					aAdd(aDatosRec,AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_CCESAT"))) //ResidenciaFiscal
				Else
					aAdd(aDatosRec,AllTrim(Posicione("SYA",1,xFilial("SYA")+SF2->F2_RESIDE,"YA_CCESAT"))) //ResidenciaFiscal
				EndIf
				cCadOri += FATXMIRECE(aSM0,SF2->F2_CLIENTE,SF2->F2_LOJA,.T.,cSepara, lDocTras, lComExt, lCartaP, lFacGlo, aDatosRec, aDatosCli, lDatoT, aRecp,cExporta)
			EndIf

			//Puntos de entrada para conceptos y Total de Impuestos
			If lPEXMLDoc
				cPEConc   :=  ExecBlock("PEXMLDOC",.F.,.F.,{"CO",.T.}) // Conceptos
				cTotImpPE := ExecBlock("PEXMLDOC",.F.,.F.,{"TI",.T.}) //Total de Impuestos por Punto de Entrada
			EndIf
			
			//Si F2_CFDVLTR == "2", muestra el valor del precio unitario en CFDI en facturas de traslado
			If lDocTras .And. lCfdVlTras
				cCfdVlTras := SF2->F2_CFDVLTR
			EndIf

			//Conceptos
			If !Empty(cPEConc)
				cCadOri += cPEConc
			Else
				cCadOri += fXMLFUN("CO",.T.,lDocTras,lCartaP,cCfdVlTras)
			EndIf
			
			//Total Impuestos
			If !Empty(cTotImpPE)
				cCadOri += cTotImpPE
			Else
				cCadOri += fXMLFUN("TI",.T.,lDocTras)
			EndIf

			//Impuestos Locales
			cImpLoc := fXMLFUN("IL",.T.,lDocTras)

			If !Empty(cImpLoc)
				cCadOri += cImpLoc
				lImpLoc := .T.
			EndIf

			//Carta Porte
			If FindFunction("LxFunaCaPo")
				cCartaP := LxFunaCaPo(SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,.T.,lDocTras,lCartaP)
				If !Empty(cCartaP)
					cCadOri += cCartaP
				EndIf
			EndIf
			
			//Comercio Exterior
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

			//Documento con Complemento de Leyendas Fiscales (IMMEX)
			lLeyFis := FindFunction("FATXLEYFIS") .And. lComExt .And. lCpoConUNi .And. (lImpLoc .or. !Empty(cComExt)) .And. !Empty(SF2->F2_CONUNI) .And. Alltrim(SF2->F2_ESPECIE) == "NF" .And. SA1->A1_CONTRBE == "1"

			//Leyendas Fiscales
			If lLeyFis
				cCadOri += FATXLEYFIS(.T., cPFisica, cSepara, SF2->F2_CONUNI)
			EndIf

			If lPEXmlComp //Agregar cadena original de complemento
				cCadOri += ExecBlock("PEXMLCOMPL", .F., .F., {"S", .T., SF2->F2_ESPECIE})
			EndIf

			cCadOri += cSepara
		EndIf

		//Encriptación de la Cadena Original
		If FindFunction("FATXMISECA")
			If lCadCon
				ConOut("Cadena Original " + Alltrim(SF2->F2_SERIE) + "-" + Alltrim(SF2->F2_DOC) + ": " + cCadOri)
			EndIf
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
		//Leyendas Fiscales
		If lLeyFis
			cSchemaXML += ' xmlns:leyendasFisc="http://www.sat.gob.mx/leyendasFiscales"'
		EndIf
		cSchemaXML += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'
		//CartaPorte
		If lCartaP
			If lUlTVerCP
				cSchemaXML += ' xmlns:cartaporte31="http://www.sat.gob.mx/CartaPorte31"'
			Else
				cSchemaXML += ' xmlns:cartaporte30="http://www.sat.gob.mx/CartaPorte30"' 
			EndIf
		EndIf
		cSchemaXML += ' xsi:schemaLocation='
		cSchemaXML += '"'
		cSchemaXML += 'http://www.sat.gob.mx/cfd/4 http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd'
		//Impuestos Locales
		If lImpLoc
			cSchemaXML += ' http://www.sat.gob.mx/implocal http://www.sat.gob.mx/sitio_internet/cfd/implocal/implocal.xsd'
		EndIf		
		//Leyendas Fiscales
		If lLeyFis
			cSchemaXML += ' http://www.sat.gob.mx/leyendasFiscales http://www.sat.gob.mx/sitio_internet/cfd/leyendasFiscales/leyendasFisc.xsd'
		EndIf
		//Comercio Exterior
		If lComExt
			cSchemaXML += ' http://www.sat.gob.mx/ComercioExterior20 http://www.sat.gob.mx/sitio_internet/cfd/ComercioExterior20/ComercioExterior20.xsd'
		EndIf
		//CartaPorte
		If lCartaP
			If lUlTVerCP
				cSchemaXML += ' http://www.sat.gob.mx/CartaPorte31 http://www.sat.gob.mx/sitio_internet/cfd/CartaPorte/CartaPorte31.xsd'
			Else
				cSchemaXML += ' http://www.sat.gob.mx/CartaPorte30 http://www.sat.gob.mx/sitio_internet/cfd/CartaPorte/CartaPorte30.xsd'
			EndIf
		EndIf
		cSchemaXML += '"'
		//Comercio Exterior
		If lComExt
			cSchemaXML += ' xmlns:cce20="http://www.sat.gob.mx/ComercioExterior20"'
		EndIf

		If lPEXmlSche //Modificar schemalocation
			cSchemaXML := ExecBlock("PEXMLSCHEM", .F., .F., {"S", cSchemaXML, SF2->F2_ESPECIE, {lImpLoc, lLeyFis, lCartaP, lComExt}})
		EndIf

		cXML += cSchemaXML

		cXML += ' Version="' + cVerCFDI + '"'
		cXML += ' Serie="' + AllTrim(cSerieDoc) + '"'
		cXML += ' Folio="' + AllTrim(cFolioDoc) + '"'
		cXML += ' Fecha="' + AllTrim(cFechaD) + '"'
		cXML += ' Sello="' + cSello + '"'
		If !lDocTras
			cXML += ' FormaPago="' + cFPago + '"'
		EndIf
		cXML += ' NoCertificado="' + AllTrim(SF2->F2_CERTFOL) + '"'
		cXML += ' Certificado="' + cCert + '"'
		If !lDocTras
			cXML += ' CondicionesDePago="' +  CFDCarEsp(cDesCondP) + '"'
		EndIf

		cXML += ' SubTotal="' + cValSubT + '"'

		If !lDocTras .And. SF2->F2_DESCONT > 0
			cXML += ' Descuento="' + cDescto + '"'
		EndIf
		cXML += ' Moneda="' + cMoneda + '"'
		If !EMPTY( cTpCPE )
			cXML += ' TipoCambio="' + cTpoCam + '"'
		Else
			If !lDocTras
				cXML += ' TipoCambio="' + cTpoCam + '"'
			EndIf
		Endif

		cXML += ' Total="' + cValTot +  '"'
		
		cXML += ' TipoDeComprobante="' + cTpoComp + '"'
		cXML += ' Exportacion="' + cExporta + '"'

		If !lDocTras
			cXML += ' MetodoPago="' +  cMetPagO + '"' 
		EndIf
		cXML += ' LugarExpedicion="' + cLgExp + '"'
		cXML += '>' + cCtrl

		//CFDI RELACIONADOS
		If FindFunction("fGetFolRel")
			If !Empty(SF2->F2_RELSAT) .Or. (!Empty(SF2->F2_SERMAN) .Or. !Empty(SF2->F2_DOCMAN))
				If !(lCartaP .And. lDocTras)
					cXML += fGetFolRel("S",.F.) + cCtrl
				EndIf
			EndIf
		EndIf

		//DATOS DEL EMISOR
		If FindFunction("FATXMIEMIS")
			cXML += FATXMIEMIS(aSM0, .F., cSepara)
		EndIf

		If AllTrim(SF2->F2_ESPECIE) <> "NDI"
			//DATOS DEL RECEPTOR
			If FindFunction("FATXMIRECE")
				cXML += FATXMIRECE(aSM0,SF2->F2_CLIENTE,SF2->F2_LOJA,.F.,cSepara, lDocTras, lComExt, lCartaP, lFacGlo, aDatosRec, aDatosCli, lDatoT, aRecp,cExporta)
			EndIf
		EndIf

		
		//Puntos de entrada para Conceptos y Total de Impuestos
		If lPEXMLDoc
			cPEConc   := ExecBlock("PEXMLDOC",.F.,.F.,{"CO",.F.}) //Conceptos
			cTotImpPE := ExecBlock("PEXMLDOC",.F.,.F.,{"TI",.F.}) //Total de Impuestos por Punto de Entrada
		EndIf

		//Si F2_CFDVLTR == "2", muestra el valor del precio unitario en CFDI en facturas de traslado
		If lDocTras .And. lCfdVlTras
			cCfdVlTras := SF2->F2_CFDVLTR
		EndIf

		//Conceptos
		If !Empty(cPEConc)
			cXML += cPEConc
		Else
			cXML += fXMLFUN("CO",.F.,lDocTras,lCartaP,cCfdVlTras)
		EndIf

		//Total de Impuestos
		If !Empty(cTotImpPE)
			cXML += cTotImpPE
		Else
			cXML += cCtrl + fXMLFUN("TI",.F.,lDocTras)
		EndIf

		//COMPLEMENTOS

		//Impuestos Locales
		cImpLoc := fXMLFUN("IL",.F.,lDocTras)

		//Carta Porte
		If FindFunction("LxFunaCaPo")
			cCartaP := LxFunaCaPo(SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,.F.,lDocTras,lCartaP)
		EndIf

		//Comercio Exterior
		If FindFunction("FATXCOMEXT") .And. lComExt
			cComExt := FATXCOMEXT(.F., aDatosCE, "", aEmiCE, aDatosCli, aDatosRec, aDetComE)
		EndIf

		//Leyendas Fiscales
		If lLeyFis
			cLeyFis := FATXLEYFIS(.F., cPFisica, "", SF2->F2_CONUNI)
		EndIf

		If lPEXmlComp //Agregar nodo de complemento al XML
			cXmlCompl := ExecBlock("PEXMLCOMPL", .F., .F., {"S", .F., SF2->F2_ESPECIE})
		EndIf

		If !Empty(cImpLoc) .Or. !Empty(cComExt) .Or. !Empty(cLeyFis) .Or. !Empty(cCartaP) .Or. !Empty(cXmlCompl)
			cXML += '	<cfdi:Complemento>' + cCtrl
			cXML += IIf(!Empty(cImpLoc),cImpLoc,"")
			cXML += IIf(!Empty(cCartaP),cCartaP,"")
			cXML += IIf(!Empty(cComExt),cComExt,"")
			cXML += IIf(!Empty(cLeyFis),cLeyFis,"")
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

	RestArea(aAreaSF2)
Return Nil
