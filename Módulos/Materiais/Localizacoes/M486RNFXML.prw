#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M486RNFXML  ³ Autor ³ Dora Vega             ³ Data ³ 10.07.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de XML para guia de remision para trasmision      ³±±
±±³          ³ electronica de Peru,de acuerdo a esquema estandar UBL 2.1    ³±±
±±³          ³ para ser enviado a TSS para su envio a la SUNAT. (PER)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486RNFXML(cFil, cSerie, cNumDoc, cCliente, cLoja)           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil .- Sucursal que emitio el documento.                    ³±±
±±³          ³ cSerie .- Numero o Serie del Documento.                      ³±±
±±³          ³ cNumDoc .- Numero de documento.                              ³±±
±±³          ³ cCliente .- Codigo del cliente.                              ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA486                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz  ³31/08/17³DMINA-38   ³Se modifica funcion fGenXMLRNF para  ³±±
±±³              ³        ³           ³negenerar de manera correcta el nodo ³±±
±±³              ³        ³           ³con se pondra la firma digital.      ³±±
±±³M.Camargo     ³11/10/19³DMINA-7508 ³Apertuna PE M486EGR                  ³±±  
±±³José González ³19/02/20³DMINA-8156 ³Tratamiento para camposen tabla SM0  ³±± 
±±³Luis Enríquez ³25/03/11³DMINA-11774³Se agrega nodo cac:Contact para co-  ³±±
±±³              ³        ³           ³locar elemento cbc:ElectronicMail con³±±
±±³              ³        ³           ³el valor del campo E1_EMAIL. (PER)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function M486RNFXML(cFil, cSerie, cNumDoc, cCliente, cLoja)
	Local cXML      := ""
	Local aEncab    := {}	
	Local aArea     := getArea()
	Local nTamDoc   := TamSX3("F2_DOC")[1]
	Local aDetalle  := {}
	Local aTransla  := {}
	Local cMotTras  := ""
	Local cRUCTrans := ""
	Local cDirTrans := ""
	Local cCPTras   := ""
	Local cNomTrans := ""
	Local cNoIdCond := ""
	Local cNomCondu := ""
	Local cApeCondu := ""
	Local cTpIdCond := ""
	Local nPeso     := 0
	Local cModTras  := ""
	Local cFecEmi   := ""
	Local aUUIDRel  := {}
	Local nI        := 0	
	Local cFilSA1   := xfilial("SA1")
	Local cFilSA2   := xfilial("SA2")
	Local cFilSA4   := xfilial("SA4")
	Local cFilDA3   := xfilial("DA3")
	Local cFilDA4   := xfilial("DA4")
	Local cNoLicen  := ""
	Local cMatVehi  := ""
	Local lCliente  :=  .T.
	Local lCpoCep   := SA2->(ColumnPos("A2_CEPE")) > 0
	Local lCpoEnde  := SA2->(ColumnPos("A2_ENDENT")) > 0
	Local lCpoVehM1 := DA3->(ColumnPos("DA3_TIPID")) > 0
	Local nHdl       := 0
	Local lVehM1L   := .F.
	
	Private cCRLF   := (chr(13)+chr(10))
	Private aDocRel := {}
    Private cCPEnt  := ""
    Private cDirEnt := ""
    Private cPaisEnt:= ""
    
    
	dbSelectArea("SF2") 
	SF2->(dbSetORder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
	If SF2->(dbSeek(cFil + cNumDoc + cSerie + cCliente + cLoja))
		cFolio := SF2->F2_SERIE2 + "-" + STRZERO(VAL(SF2->F2_DOC),8) //Serie-Correlativo
		cFecEmi := StrZero(Year(SF2->F2_EMISSAO),4) + "-" + StrZero(MONTH(SF2->F2_EMISSAO),2) + "-" + StrZero(DAY(SF2->F2_EMISSAO),2) //Fecha de emisión
		nPeso    := SF2->F2_PBRUTO //Peso Bruto Total
		cMotTras := SF2->F2_MODTRAD //Motivo de traslado
		cFecIniTra :=  StrZero(Year(SF2->F2_FECDSE),4) + "-" + StrZero(MONTH(SF2->F2_FECDSE),2) + "-" + StrZero(DAY(SF2->F2_FECDSE),2) //Fecha de inicio del traslado
	
		aEncab  := {cFolio, cFecEmi, nPeso, SF2->F2_HORA}
		lCliente := Alltrim(SF2->F2_ESPECIE) == "RFN"
		
		If lCliente
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
			If SA1->(dbSeek(cFilSA1 + SF2->F2_CLIENT + SF2->F2_LOJENT))
				cCPEnt := SA1->A1_CEPE
				cDirEnt := Alltrim(SA1->A1_ENDENT)
				dbSelectArea("SYA")
				SYA->(dbSetOrder(1)) //YA_FILIAL + YA_CODGI
				If SYA->(dbSeek(xFilial("SYA") + SA1->A1_PAIS))
					cPaisEnt := SYA->YA_CODERP
				EndIf			
			EndIf
		Elseif lCpoEnde .And. lCpoCep
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
			If SA2->(MSSeek(cFilSA2 + SF2->F2_CLIENT + SF2->F2_LOJENT))
				cCPEnt := SA2->A2_CEPE
				cDirEnt := Alltrim(SA2->A2_ENDENT)
				dbSelectArea("SYA")
				SYA->(dbSetOrder(1)) //YA_FILIAL + YA_CODGI
				If SYA->(MsSeek(xFilial("SYA") + SA2->A2_PAIS))
					cPaisEnt := SYA->YA_CODERP
				EndIf			
			EndIf
		Endif
		
		//Transportadora
		dbSelectArea("SA4") 
		SA4->(dbSetOrder(1)) //A4_FILIAL + A4_COD
		If SA4->(dbSeek(cFilSA4 + SF2->F2_TRANSP))
			cRUCTrans := Trim(SA4->A4_CGC)
			cDirTrans := Trim(SA4->A4_END)
			cCPTras   := SA4->A4_CEP
			cNomTrans := SA4->A4_NOME
			cModTras  := SA4->A4_TIPOTRA			
		EndIf
			
		//Vehículo
		dbSelectArea("DA3") 
		DA3->(dbSetOrder(1)) //DA3_FILIAL + DA3_COD
		If DA3->(dbSeek(cFilDA3 + SF2->F2_VEICULO))
			cMatVehi := Alltrim(DA3->DA3_PLACA)
			//Conductor
			dbSelectArea("DA4") 
			DA4->(dbSetOrder(1)) //DA4_FILIAL + DA4_COD
			If DA4->(dbSeek(cFilDA4 + DA3->DA3_MOTORI))
				cNoIdCond  := Alltrim(DA4->DA4_RG)
				cNomCondu  := Alltrim(DA4->DA4_PRNOME) + " " + Alltrim(DA4->DA4_SENOME)
				cApeCondu  := Alltrim(DA4->DA4_APATER) + " " + Alltrim(DA4->DA4_AMATER)
				cTpIdCond  := Alltrim(DA4->DA4_TIPOID)
				cNoLicen   := Alltrim(DA4_NUMCNH)
			EndIf
			If lCpoVehM1
				lVehM1L := (DA3->DA3_TIPID == "1")
			Endif
		EndIf						

		aTransla := {cRUCTrans, cNomTrans, cModTras, cMotTras, cCPTras, cNoIdCond, cFecIniTra, cNomCondu, cApeCondu, cTpIdCond, cNoLicen, cMatVehi,lVehM1L}
		
		//Datos de traslado  
		 M486XMLTRA(cFil, cNumDoc, cSerie, cCliente, cLoja, @aDetalle)
		 
		 //Documentos relacionados
		 aUUIDRel := StrTokArr(SF2->F2_UUIDREL, cCRLF) 
		 
		 For nI := 1 To Len(aUUIDRel)
		 	aAdd(aDocRel, StrTokArr(aUUIDRel[nI], "/"))
		 Next nI

		//Genera XML
		cXML := fGenXMLRNF(cCliente,cLoja,aEncab, aDetalle, aTransla)
	EndIf	
	
	If isBlind() .And. Alltrim(FunName()) == "M486_AUTO"
		nHdl := fCreate("\baseline\soap.txt")
		fWrite(nHdl,cXML)	
		FClose(nHdl)
	Endif
	RestArea(aArea)	
Return cXML

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGenXMLRNF ³ Autor ³ Dora Vega             ³ Data ³ 10.07.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura XML para guia de remision de acuerdo al    ³±±
±±³          ³ al estandar UBL 2.1 (PERU)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGenXMLRNF(cCliente,cLoja,aEncab,aDetalle, aTransla)         ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCliente .- Codigo del cliente.                              ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±³          ³ aEncab .- Arreglo con datos para encabezado de XML.          ³±±
±±³          ³ aDetalle .-  Arreglo con datos de detalle de guia de remision³±±
±±³          ³ aTransla .- Arreglo con datos del Traslado.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXML .- String con estructura de XML para guia de remision.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486RNFXML                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGenXMLRNF(cCliente,cLoja,aEncab,aDetalle, aTransla)
	Local cXML  := ""
	Local nX      := 0
	Local lPEGRE  := ExistBlock("M486RNF")
	Local cXMLCon := ""
	Local cClient := ""
	Local cCLoja  := ""
	Local lCliente := Alltrim(SF2->F2_ESPECIE) == "RFN"
	Local cXMLPE  := ""

	Private lRSM := ALLTRIM(SuperGetMV("MV_PROVFE",,"")) == "RSM"
	
	cXML := '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' + cCRLF
	cXML += '<DespatchAdvice' + cCRLF 
	cXML += '	xmlns:ds="http://www.w3.org/2000/09/xmldsig#" ' + cCRLF 
	cXML += '	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' + cCRLF 
	cXML += '	xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2"' + cCRLF 
	cXML += '	xmlns:sac="urn:sunat:names:specification:ubl:peru:schema:xsd:SunatAggregateComponents-1"' + cCRLF 
	cXML += '	xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"' + cCRLF
	cXML += '	xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"' + cCRLF 
	cXML += '	xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' + cCRLF
	cXML += '	xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"' + cCRLF
	cXML += '	xmlns:ccts="urn:un:unece:uncefact:documentation:2"' + cCRLF
	cXML += '	xmlns="urn:oasis:names:specification:ubl:schema:xsd:DespatchAdvice-2">' + cCRLF
  
	//Adicionales
	cXML += '	<ext:UBLExtensions>' + cCRLF
	If lRSM
		// Puntos de Entrada que son habiles solamente cuando se usa RSM
		If ExistBlock("M486EGR") 
			cXML += ExecBlock("M486EGR",.F.,.F.,{SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_ESPECIE,cCliente,cLoja})
		EndIf
	EndIf
	cXML += '		<ext:UBLExtension>' + cCRLF
	cXML += '			<ext:ExtensionContent></ext:ExtensionContent>' + cCRLF  
	cXML += '		</ext:UBLExtension>' + cCRLF
	cXML += '	</ext:UBLExtensions>' + cCRLF	
    
    //Identificacion del Documento
    cXML += '	<cbc:UBLVersionID>2.1</cbc:UBLVersionID>' + cCRLF
	cXML += '	<cbc:CustomizationID>2.0</cbc:CustomizationID>' + cCRLF
	cXML += '	<cbc:ID>' + aEncab[1] + '</cbc:ID>' + cCRLF  
	cXML += '	<cbc:IssueDate>' + aEncab[2] + '</cbc:IssueDate>' + cCRLF
	cXML += '	<cbc:IssueTime>' + aEncab[4] + '</cbc:IssueTime>' + cCRLF 
	cXML += '	<cbc:DespatchAdviceTypeCode>09</cbc:DespatchAdviceTypeCode>' + cCRLF 

	//Note
	If lPEGRE
		cXML += ExecBlock("M486RNF",.F.,.F.,{"N"})
	EndIf

    //Documentos relacionados
    If Len(aDocRel) > 0
    	For nX := 1 To Len(aDocRel)
    		cXML += '	<cac:AdditionalDocumentReference>' + cCRLF
    		cXML += '		<cbc:ID>' + IIF(Len(aDocRel[nX]) > 1, aDocRel[nX][2],"") + '</cbc:ID>' + cCRLF
    		cXML += '		<cbc:DocumentTypeCode>' + aDocRel[nX][1] + '</cbc:DocumentTypeCode>' + cCRLF
			If lPEGRE
				cXML += ExecBlock("M486RNF",.F.,.F.,{"R",aDocRel[nX][1]})
			EndIf
      		cXML += '	</cac:AdditionalDocumentReference>' + cCRLF
    	Next nX
    EndIf
	
	//Firma Electronica
	cXML += M486XmlFE()
	
	aDatosSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_ENDENT", "M0_CEPENT", "M0_CGC", "M0_NOME"} ) 
	
	//Emisor
	cXML += '	<cac:DespatchSupplierParty>' + cCRLF
	cXML += '		<cac:Party>' + cCRLF
	cXML += '			<cac:PartyIdentification>' + cCRLF
	cXML += '				<cbc:ID schemeID="6" schemeName="Documento de Identidad" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo06">' + RTRIM(aDatosSM0[3][2]) + '</cbc:ID>' + cCRLF
	cXML += '			</cac:PartyIdentification>' + cCRLF
	cXML += '			<cac:PartyLegalEntity>' + cCRLF
	cXML += '				<cbc:RegistrationName><![CDATA[' + RTRIM(aDatosSM0[4][2]) + ']]></cbc:RegistrationName>' + cCRLF 
	cXML += '			</cac:PartyLegalEntity>' + cCRLF
	cXML += '		</cac:Party>' + cCRLF
	cXML += '	</cac:DespatchSupplierParty>' + cCRLF 
	
	//Receptor
	cClient := IIf(Alltrim(aTransla[4]) $ "03",SF2->F2_CLIENTE,SF2->F2_CLIENT)
	cCLoja	:= IIf(Alltrim(aTransla[4]) $ "03",SF2->F2_LOJA,SF2->F2_LOJENT)
	cXML += M486RECRNF(cClient,cCLoja,lCliente)

	//Comprador/Proveedor
	If lPEGRE
		cXML += ExecBlock("M486RNF",.F.,.F.,{"CP"})
	EndIf
	
	//Datos de envío
	cXML += '	<cac:Shipment>' + cCRLF
	cXML += '		<cbc:ID>01</cbc:ID>' + cCRLF 
	cXML += '		<cbc:HandlingCode listAgencyName="PE:SUNAT" listName="Motivo de traslado" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo20">'+ Alltrim(aTransla[4]) +'</cbc:HandlingCode>' + cCRLF 

	If lPEGRE
		cXMLPE := ExecBlock("M486RNF",.F.,.F.,{"S"})
	EndIf

	If !Empty(cXMLPE)
		cXML += cXMLPE
	EndiF

	If Alltrim(aTransla[4]) $ "08|09"
		cXML += '		<cbc:Information><![CDATA[' + Alltrim(ObtColSAT("S020",Alltrim(aTransla[4]),1,2,3,50)) + ']]></cbc:Information>' + cCRLF 
	EndIf
	cXML += '		<cbc:GrossWeightMeasure unitCode="KGM">'+ IIf(aEncab[3] > 0,Alltrim(Transform(aEncab[3],"999999.99")),"0.00") +'</cbc:GrossWeightMeasure>' + cCRLF
	
	//Número de Bultos o Pallets - Número de contenedor - Número de precinto
	If lPEGRE
		cXML += ExecBlock("M486RNF",.F.,.F.,{"P"})
	Else
		If Alltrim(aTransla[4]) == "08" //Motivos Importación
			cXML += '		<cbc:TotalTransportHandlingUnitQuantity>1</cbc:TotalTransportHandlingUnitQuantity>' + cCRLF
		EndIf 
	EndIf

	//Vehiculos de tipo M1 o L
	If aTransla[13]
		cXML += '		<cbc:SpecialInstructions>SUNAT_Envio_IndicadorTrasladoVehiculoM1L</cbc:SpecialInstructions>'+ cCRLF
	Endif

	cXML += '		<cac:ShipmentStage>' + cCRLF
	cXML += '			<cbc:TransportModeCode listAgencyName="PE:SUNAT" listName="Modalidad de traslado" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo18">'+ Alltrim(aTransla[3]) +'</cbc:TransportModeCode>' + cCRLF 
	cXML += '			<cac:TransitPeriod>' + cCRLF
	cXML += '				<cbc:StartDate>' + Alltrim(aTransla[7]) + '</cbc:StartDate>' + cCRLF 
	cXML += '			</cac:TransitPeriod>' + cCRLF
	IF !aTransla[13]
		If Alltrim(aTransla[3]) == "01" //Transporte público
			cXML += '			<cac:CarrierParty>' + cCRLF  		
			cXML += '			<cac:PartyIdentification>' + cCRLF
			cXML += '				<cbc:ID schemeID="6" schemeName="Documento de Identidad" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo06">' + Alltrim(aTransla[1]) + '</cbc:ID>' + cCRLF
			cXML += '			</cac:PartyIdentification>' + cCRLF
			cXML += '			<cac:PartyLegalEntity>' + cCRLF
			cXML += '				<cbc:RegistrationName><![CDATA[' + Alltrim(aTransla[2]) + ']]></cbc:RegistrationName>' + cCRLF
			If lPEGRE
				//MTC
				cXML += ExecBlock("M486RNF",.F.,.F.,{"PU"})
			EndIf
			cXML += '			</cac:PartyLegalEntity>' + cCRLF		
			cXML += '			</cac:CarrierParty> ' + cCRLF
		ElseIf Alltrim(aTransla[3]) == "02" //Transporte privado
			//Conductor
			cXML += '			<cac:DriverPerson>' + cCRLF
			cXML += '				<cbc:ID schemeID="' + aTransla[10] + '" schemeName="Documento de Identidad" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo06">' + Alltrim(aTransla[6]) + '</cbc:ID>' + cCRLF 
			cXML += '				<cbc:FirstName>' + aTransla[8] + '</cbc:FirstName>' + cCRLF 
			cXML += '				<cbc:FamilyName>' + aTransla[9] + '</cbc:FamilyName>' + cCRLF
			cXML += '				<cbc:JobTitle>Principal</cbc:JobTitle>' + cCRLF  
			cXML += '				<cac:IdentityDocumentReference>' + cCRLF
			cXML += '					<cbc:ID>' + aTransla[11] + '</cbc:ID>' + cCRLF
			cXML += '				</cac:IdentityDocumentReference>' + cCRLF	
			cXML += '			</cac:DriverPerson>' + cCRLF	
		EndIf
	Endif		
	cXML += '		</cac:ShipmentStage>' + cCRLF
	
	//Direccion punto de llegada 	
	cXML += '		<cac:Delivery>' + cCRLF
	cXML += '			<cac:DeliveryAddress>' + cCRLF 
	cXML += '			<cbc:ID schemeName="Ubigeos" schemeAgencyName="PE:INEI">' + Alltrim(cCPEnt) + '</cbc:ID>' + cCRLF
	If lPEGRE
		//DeliveryAddress
		cXML += ExecBlock("M486RNF",.F.,.F.,{"DA"})
	EndIf
	cXML += '			<cac:AddressLine>' + cCRLF
	cXML += '					<cbc:Line>' + Alltrim(cDirEnt) + '</cbc:Line>' + cCRLF
	cXML += '			</cac:AddressLine>' + cCRLF
	cXML += '			</cac:DeliveryAddress>' + cCRLF 
	//Direccion del punto de partida
	cXML += '			<cac:Despatch>' + cCRLF
	cXML += '				<cac:DespatchAddress>' + cCRLF
	If lPEGRE
		//DespatchAddress
		cXMLPE := ExecBlock("M486RNF",.F.,.F.,{"DP"})
	Endif
	If !Empty(cXMLPE)
		cXML += cXMLPE
	Else
		cXML += '					<cbc:ID schemeName="Ubigeos" schemeAgencyName="PE:INEI">' + Alltrim(aDatosSM0[2][2]) + '</cbc:ID>' + cCRLF
		cXML += '					<cac:AddressLine>' + cCRLF
		cXML += '						<cbc:Line>' + Alltrim(aDatosSM0[1][2]) + '</cbc:Line>' + cCRLF
		cXML += '					</cac:AddressLine>' + cCRLF
	EndIf
	cXML += '				</cac:DespatchAddress>' + cCRLF
	cXML += '			</cac:Despatch>' + cCRLF  
	cXML += '		</cac:Delivery>' + cCRLF

	If lPEGRE
		//Contenedor/Precinto
		cXMLCon += ExecBlock("M486RNF",.F.,.F.,{"CO"})
	EndIf

	If Alltrim(aTransla[3]) == "02" .Or. aTransla[13] .Or. !Empty(cXMLCon) //Transporte privado o existe PE para contenedor/precinto
		cXML += '		<cac:TransportHandlingUnit>' + cCRLF
		If Alltrim(aTransla[3]) == "02" .Or. aTransla[13]
			cXML += '			<cac:TransportEquipment>' + cCRLF
			cXML += '				<cbc:ID>' + Alltrim(aTransla[12]) + '</cbc:ID>' + cCRLF
			cXML += '			</cac:TransportEquipment>' + cCRLF
		EndIf
		//Contenedor/Precinto
		If !Empty(cXMLCon)
			cXML += cXMLCon
		EndIf
		cXML += '		</cac:TransportHandlingUnit>' + cCRLF
	EndIf
	cXML += '	</cac:Shipment>' + cCRLF
	
    For nX :=1 To Len(aDetalle)
	    cXML += '	<cac:DespatchLine>' + cCRLF
		cXML += '		<cbc:ID>' + aDetalle[nX][1] + '</cbc:ID>' + cCRLF
		cXML += '		<cbc:DeliveredQuantity unitCode="'+ Alltrim(aDetalle[nX][3]) +'">' + Alltrim(Transform(aDetalle[nX][2],"9999999.99"))  + '</cbc:DeliveredQuantity>' + cCRLF
		cXML += '		<cac:OrderLineReference>' + cCRLF
		cXML += '			<cbc:LineID>' + aDetalle[nX][1] + '</cbc:LineID>' + cCRLF
		cXML += '		</cac:OrderLineReference>' + cCRLF
		cXML += '		<cac:Item>' + cCRLF
		cXML += '			<cbc:Description><![CDATA[' + Alltrim(aDetalle[nX][4] )+ ']]></cbc:Description>' + cCRLF
		cXML += '			<cac:SellersItemIdentification>' + cCRLF
		cXML += '				<cbc:ID>' + Alltrim(aDetalle[nX][5]) + '</cbc:ID>' + cCRLF
		cXML += '			</cac:SellersItemIdentification>' + cCRLF
		cXML += '		</cac:Item>' + cCRLF
	    cXML += '	</cac:DespatchLine>' + cCRLF
    Next nX

	cXML += '</DespatchAdvice>' + cCRLF

Return cXML

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486RECRNF ³ Autor ³ Dora Vega             ³ Data ³ 10.07.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de Receptor para XML de acuerdo al estandar³±±
±±³          ³ UBL 2.1 (PERU)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486RECRNF(cCliente,cLoja)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCliente .- Codigo del cliente.                              ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXMLRec .- Nodo de receptor para XML de estandar UBL 2.1     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ fGenXMLRNF                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M486RECRNF(cCliente,cLoja,lCliente)
	Local cXMLRec   := ""
	Local cCRLF	    := (chr(13)+chr(10))
	Local cFilSA1   := xFilial("SA1")
	Local cFilSA2   := xFilial("SA2")
	Local aArea     := getArea()
	Local cTipDocId := ""
	Local cNoId     := ""
	Local cEmail    := ""
	Local cNombre   := ""
	Default cCliente:= ""
	Default cLoja   := ""
	Default lCliente:= .T.
		
	//Receptor
	If lCliente
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
		If SA1->(dbSeek(cFilSA1 + cCliente + cLoja)) 
			cTipDocId := Alltrim(SA1->A1_TIPDOC)
			If cTipDocId $ "6"
				cNoId := RTRIM(SA1->A1_CGC)
			Else
				cNoId := RTRIM(SA1->A1_PFISICA)
			EndIf	
			cNombre:= SA1->A1_NOME
			cEmail := SA1->A1_EMAIL
		EndIf
	else
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1)) //A2_FILIAL + A2_COD + A2_LOJA
		If SA2->(MSSeek(cFilSA2 + cCliente + cLoja)) 
			cTipDocId := Alltrim(SA2->A2_TIPDOC)
			If cTipDocId $ "6"
				cNoId := RTRIM(SA2->A2_CGC)
			Else
				cNoId := RTRIM(SA2->A2_PFISICA)
			EndIf	
			cNombre:= SA2->A2_NOME
			cEmail := SA2->A2_EMAIL
		EndIf
	ENDIF

	cXMLRec += '	<cac:DeliveryCustomerParty>' + cCRLF
	cXMLRec += '		<cac:Party>' + cCRLF
	cXMLRec += '			<cac:PartyIdentification>' + cCRLF
	cXMLRec += '				<cbc:ID schemeID="'+ cTipDocId +'" schemeName="Documento de Identidad" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo06">' + RTRIM(cNoId) + '</cbc:ID>' + cCRLF
	cXMLRec += '			</cac:PartyIdentification>' + cCRLF
	cXMLRec += '			<cac:PartyLegalEntity>' + cCRLF
	cXMLRec += '				<cbc:RegistrationName><![CDATA[' + RTRIM(cNombre) + ']]></cbc:RegistrationName>' + cCRLF 
	cXMLRec += '			</cac:PartyLegalEntity>' + cCRLF
	If lRSM .And. !Empty(cEmail)
		cXMLRec += '			<cac:Contact>' + cCRLF
		cXMLRec += '				<cbc:ElectronicMail><![CDATA[' + RTRIM(cEmail) + ']]></cbc:ElectronicMail>' + cCRLF 
		cXMLRec += '			</cac:Contact>' + cCRLF
	EndIf
	cXMLRec += '		</cac:Party>' + cCRLF
	cXMLRec += '	</cac:DeliveryCustomerParty>' + cCRLF

	RestArea(aArea)
Return cXMLRec

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486XMLTRA ³ Autor ³ Dora Vega             ³ Data ³ 13/07/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtiene los datos del Traslado para la guia de remision.(PERU)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486XMLTRA(cDoc, cSerie, cCliente, cLoja, aDetalle)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cDoc .- Numero de documento.                                 ³±±
±±³          ³ cSerie .- Numero o Serie del Documento.                      ³±±
±±³          ³ cCliente .- Codigo del cliente.                              ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±³          ³ aDetalle .-  Arreglo con datos de detalle de guia de remision³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486RNFXML                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function M486XMLTRA(cFilDoc,cDoc,cSerie,cCliente,cLoja,aDetalle)
	Local aArea     := getArea()
	Local cAliasXML := getNextAlias()	
	Local cUniMed   := ""
	Local nQtdItem  := 0
	Local cDesPro   := ""
	Local cCodProd  := ""
	Local cCampos   := ""
	Local cTablas   := ""	
	Local cCond     := ""
	Local lPEDet    := ExistBlock("M486DETRNF")
	Local aM486DET  := {}
	Local cOrden    := ""

	Default cFilDoc  := ""
	Default cDoc     := ""
	Default cSerie   := ""
	Default cCliente := ""
	Default cLoja    := ""
	Default aDetalle := {}
	
	cCampos  += "% SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_LOJA, SD2.D2_CLIENTE, SD2.D2_ESPECIE, SD2.D2_COD, SD2.D2_QUANT, SD2.D2_PESO, "
	cCampos  += " SB1.B1_DESC, SB1.B1_UM, SD2.D2_PEDIDO, SD2.D2_ITEM %"
	cTablas  := "% " + RetSqlName("SD2") + " SD2, "  + RetSqlName("SB1") + " SB1 %"
	cCond    := "% SD2.D2_DOC = '" + cDoc + "' AND SD2.D2_SERIE = '" + cSerie + "'"
	cCond    += " AND SD2.D2_CLIENTE = '" + cCliente + "' AND SD2.D2_LOJA = '" + cLoja + "'"
	cCond    += " AND SD2.D2_COD = SB1.B1_COD "
	cCond	 += " AND SD2.D2_FILIAL = '" + cFilDoc + "'"
	cCond	 += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cCond	 += " AND SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	cCond	 += " AND SB1.D_E_L_E_T_  = ' ' "
	cCond	 += " AND SD2.D_E_L_E_T_  = ' ' %"
	cOrden   := "% SD2.D2_ITEM %"
		
	BeginSql alias cAliasXML
		SELECT %exp:cCampos%
		FROM  %exp:cTablas%
		WHERE %exp:cCond%
		ORDER BY %exp:cOrden%
	EndSql	
	
	dbSelectArea(cAliasXML)

	(cAliasXML)->(DbGoTop())

	While (cAliasXML )->(!Eof())
		If lPEDet
			aM486DET := ExecBlock("M486DETRNF",.F.,.F.,{(cAliasXML)->D2_FILIAL,(cAliasXML)->D2_DOC,(cAliasXML)->D2_SERIE,(cAliasXML)->D2_ESPECIE,(cAliasXML)->D2_CLIENTE,(cAliasXML)->D2_LOJA,(cAliasXML)->D2_ITEM,(cAliasXML)->D2_COD})
		EndIf

		nQtdItem := IIf(Len(aM486DET) >= 1 .And. !(aM486DET[1]==Nil),aM486DET[1],(cAliasXML)->D2_QUANT)          // Cantidad
		cUniMed	 := IIf(Len(aM486DET) >= 2 .And. !(aM486DET[2]==Nil),aM486DET[2],M486UNIMED((cAliasXML)->B1_UM)) // Unidad de Medida
		cDesPro	 := IIf(Len(aM486DET) >= 3 .And. !(aM486DET[3]==Nil),aM486DET[3],(cAliasXML)->B1_DESC)           // Descripción del Producto
		cCodProd := IIf(Len(aM486DET) >= 4 .And. !(aM486DET[4]==Nil),aM486DET[4],(cAliasXML)->D2_COD)            // Código del Producto

		aAdd(aDetalle,{(cAliasXML)->D2_ITEM, nQtdItem, cUniMed, cDesPro, cCodProd})
		(cAliasXML)->(dbskip())
	EndDo	
	(cAliasXML)->(dbCloseArea())
	RestArea(aArea)
Return Nil
