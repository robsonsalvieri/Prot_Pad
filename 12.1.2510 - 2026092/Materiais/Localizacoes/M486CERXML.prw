#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M486CERXML  ³ Autor ³ Dora Vega             ³ Data ³ 03.07.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Generacion de XML para certificado de retencion de Peru,     ³±±
±±³          ³ de acuerdo a esquema estandar UBL 2.0 para ser enviado a TSS ³±±
±±³          ³ para su envio a la SUNAT. (PER)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486CERXML(cFil,cNumCer,cNumDoc,cSerie,cProv,cLoja)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil .- Sucursal que emitio el documento.                    ³±±
±±³          ³ cNumCer .- Numero de Certificado.                            ³±±
±±³          ³ cNumDoc .- Numero de documento.                              ³±±
±±³          ³ cSerie .- Numero o Serie del Documento.                      ³±±
±±³          ³ cProv .- Codigo del Proveedor .                              ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA486                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz  ³31/08/17³DMINA-38   ³Se modifica funcion fGenXMLCER para  ³±±
±±³              ³        ³           ³negenerar de manera correcta el nodo ³±±
±±³              ³        ³           ³con se pondra la firma digital. 		³±±
±±³Andres S.  	 ³06/02/20³DMINA-7985 ³Se modifica funcion M486CERXML para  ³±±
±±³              ³        ³           ³que genere un solo XML por numero de ³±±
±±³              ³        ³           ³certificado (PER) 					³±±
±±³Eduardo PrzS. ³17/09/20³DMINA-9675 ³Se modifica funcion M486CERXML para  ³±±
±±³              ³        ³           ³que el nodo cbc:PaidDate contenga la ³±±
±±³              ³        ³           ³fecha del pago (PER) 				³±±
±±³Eduardo PrzS. ³18/10/20³DMINA-10417³Corrección schemeID por tipo de doc. ³±±
±±³              ³        ³           ³(catálogo 01 de la SUNAT) (PER) 	    ³±±
±±³Marco A. Glez.³22/11/20³DMINA-10567³Correccion en impresion de nodos y   ³±±
±±³              ³        ³           ³atributos que contienen moneda de    ³±±
±±³              ³        ³           ³documento origen. (PER)              ³±±
±±³Luis Enríquez ³15/01/21³DMINA-10885³Correccion número de pago documentos ³±±
±±³              ³        ³           ³referencias c/más de una cuota (PER) ³±±
±±³Alf Medrano   ³26/02/21³DMINA-11186³Correccion decimales en tasa cambio  ³±±
±±³              ³        ³           ³en fun M486RETFAC (PER)              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function M486CERXML(cFil,cNumCer, cNumDoc, cSerie, cProv, cLoja, cSerCrt) 
	Local cXML    := ""
	Local aEncab  := {}	
	Local aDocRef :={}
	Local aArea   := getArea()
	Local nTotalPa:= 0
	Local cAliq   := ""
	Local nValimp := 0
	Local cFilSFE := xFilial("SFE")
    Local lPros   := .T.
    Local cMoneda := ""
	Local nNoPago := 0
	Local aDocRet := {}
	Local nPos    := 0
    
    Private cTRB   := getNextAlias()
	Private cFecha := ""

	Default cSerCrt := ""
	
	BeginSql alias cTRB
		SELECT FE_FILIAL, FE_NROCERT, FE_SERIE2, FE_NFISCAL, FE_SERIE, FE_FORNECE, FE_LOJA, FE_ESPECIE, FE_EMISSAO, FE_ALIQ, FE_VALBASE, FE_VALIMP,FE_ORDPAGO, FE_PARCELA
		FROM  %table:SFE% SFE
		WHERE FE_FILIAL=%xFilial:SFE%
			AND FE_NROCERT = %exp:cNumCer%
			AND FE_SERIE2  = %exp:cSerCrt%
			AND SFE.%notDel%
		ORDER BY FE_FILIAL, FE_NROCERT, FE_SERIE2, FE_NFISCAL, FE_SERIE, FE_FORNECE, FE_LOJA, FE_ESPECIE
	EndSql
	
	TCSetField(cTRB,"FE_EMISSAO","D")

	dbSelectArea(cTRB)
	
	While (cTRB)->(!EOF()) 
		//Valida existencia del mismo documento para las retenciones a transmitir (durante proceso de transmisión)
		nPos := Ascan(aDocRet,{|x| x[1] == (cTRB)->FE_FILIAL .And. x[2] == (cTRB)->FE_NFISCAL .And. x[3] == (cTRB)->FE_SERIE .And. x[4] == (cTRB)->FE_FORNECE .And. x[5] == (cTRB)->FE_LOJA})
		If nPos > 0
			aDocRet[nPos][6] += 1
			nNoPago := aDocRet[nPos][6]
		Else
			aAdd(aDocRet, {(cTRB)->FE_FILIAL, (cTRB)->FE_NFISCAL, (cTRB)->FE_SERIE, (cTRB)->FE_FORNECE, (cTRB)->FE_LOJA, 1}) 
			nNoPago := 1
		EndIf
		//Valida si exiten retenciones anteriores transmitidas
		nNoPago += M486CERPAG(cFilSFE,cNumDoc, cSerie, cProv, cLoja) 
		cFolio := RTRIM((cTRB)->FE_SERIE2)  + "-" + STRZERO(VAL((cTRB)->FE_NROCERT),8)
		cFecha := Alltrim(Str(YEAR((cTRB)->FE_EMISSAO))) + "-" + Padl(Alltrim(Str(MONTH((cTRB)->FE_EMISSAO))),2,'0') + "-" +;
		Padl(Alltrim(Str(DAY((cTRB)->FE_EMISSAO))),2,'0')
		cAliq := (cTRB)->FE_ALIQ
		cMoneda := Alltrim(M486VALSX5("XQ1")) 
		nValimp := 0
		nTotalPa := 0
		
		nTotalPa := (cTRB)->FE_VALBASE - (cTRB)->FE_VALIMP			
		nValimp := (cTRB)->FE_VALIMP
		
		If lPros
			aEncab := {cFolio,cFecha,cAliq,nValimp,nTotalPa,cMoneda}
			lPros := .F.					
		Else
			aEncab[4] += nValimp
			aEncab[5] += nTotalPa 
		EndIf	

		//Comprobante Relacionado  
		M486RETFAC((cTRB)->FE_NFISCAL,(cTRB)->FE_SERIE, (cTRB)->FE_FORNECE, (cTRB)->FE_LOJA,(cTRB)->FE_ORDPAGO,@aDocRef,nNoPago, (cTRB)->FE_PARCELA, (cTRB)->FE_ESPECIE)			
			
		(cTRB)->(dbSkip())
	Enddo
	
	// Ajuste montos Documentos Relacionados
	M486DocRef(@aDocRef)
	
	//Genera XML
	cXML := fGenXMLCER(cProv,cLoja,aEncab,aDocRef)
	FwFreeArray(aEncab)
	FwFreeArray(aDocRef)
	(cTRB)->(dbcloseArea())
	RestArea(aArea)	
Return cXML

/*/{Protheus.doc} M486DocRef
	Función encargada de ajustar los montos de la factura de entrada
	para los nodos cbc:PaidAmount, sac:SUNATRetentionAmount y sac:SUNATTotalPaid
	@type  Function
	@author eduardo.manriquez
	@since 20/10/2025
	@version 1.0
	@param aDocRef, Array, Array que contiene la información de los documentos referenciados en el comprobante de retención
			[1]-Folio del documento
			[2]-Moneda del documento 
			[3]-Fecha de emisión
			[4]-Valor de bruto del documento (F1_VALBRUT o F2_VALBRUT)
			[5]-Valor de la cuenta por pagar (E2_VALOR) 
			[6]-Valor de la retención (FE_VALIMP)
			[7]-Valor de cuenta por pagar menor las retenciones (E2_VALOR - FE_VALIMP)
			[8]-Tasa Moneda
			[9]-Tipo Documento, 01 - Factura | 07 - Nota de Crédito | 08 - Nota de Débito
			[10]-Número de pago de retenciones
			[11]-Total Pago (FE_VALBASE - FE_VALIMP)
			[12]-Fecha de la operación
	@return 
	@example
	M486DocRef(aDocRef)
	/*/
Function M486DocRef(aDocRef)
	Local nX := 1
	Local nPaidAmount:= 0
	Local nRetentionAmount := 0
	Local nPosNf := 0
	Local nSNetTotalPaid := 0

	Default aDocRef := {}

	For nX := 1 to len(aDocRef)
		If aDocRef[nX][9] == "07"
			nPaidAmount -= aDocRef[nX][5]
			nRetentionAmount -= aDocRef[nX][6]
			nSNetTotalPaid -= aDocRef[nX][11]
		Endif
	Next nX

	nPosNf := Ascan(aDocRef,{|x| x[9] == "01"})

	If nPosNf > 0
	  aDocRef[nPosNf][5] += nPaidAmount
	  aDocRef[nPosNf][6] += nRetentionAmount
	  aDocRef[nPosNf][11] += nSNetTotalPaid
	Endif


Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGenXMLCER ³ Autor ³ Dora Vega             ³ Data ³ 03.07.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura XML para certificado de retencion de       ³±±
±±³          ³ acuerdo al estandar UBL 2.0 (PERU)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGenXMLCER(cProv,cLoja,aEncab,aDocRef)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProv .- Codigo del Proveedor .                              ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±³          ³ aEncab .- Datos de encabezado del documento.                 ³±±
±±³          ³ aDocRef .- Datos de identificacion del Documento.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXML.-String de estructrura de XML certificado de retenciones³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486CERXML                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGenXMLCER(cProv,cLoja,aEncab,aDocRef)
	Local cXML			:= ""
	Local nI			:= 0
	Local cCRLF			:= (chr(13)+chr(10))
	Local cCodMonPEN	:= AllTrim(M486VALSX5("XQ"+"1")) //Obtiene codigo de moneda 1 en SX5

	cXML := '<?xml version="1.0" encoding="iso-8859-1" standalone="no"?>' + cCRLF
	cXML += '<Retention' + cCRLF 
	cXML += '	xmlns="urn:sunat:names:specification:ubl:peru:schema:xsd:Retention-1"' + cCRLF 
	cXML += '	xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"' + cCRLF 
	cXML += '	xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"' + cCRLF 
	cXML += '	xmlns:ccts="urn:un:unece:uncefact:documentation:2"' + cCRLF 
	cXML += '	xmlns:ds="http://www.w3.org/2000/09/xmldsig#" ' + cCRLF
	cXML += '	xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"' + cCRLF 
	cXML += '	xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2"' + cCRLF
	cXML += '	xmlns:sac="urn:sunat:names:specification:ubl:peru:schema:xsd:SunatAggregateComponents-1" ' + cCRLF
	cXML += '	xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"' + cCRLF
	cXML += '	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + cCRLF

	//Adicionales
	cXML += '	<ext:UBLExtensions>' + cCRLF
    cXML += '		<ext:UBLExtension>' + cCRLF
	cXML += '			<ext:ExtensionContent></ext:ExtensionContent>' + cCRLF  
    cXML += '		</ext:UBLExtension>' + cCRLF
    cXML += '	</ext:UBLExtensions>' + cCRLF	
    
    //Identificacion del Documento
    cXML += '	<cbc:UBLVersionID>2.0</cbc:UBLVersionID>' + cCRLF
	cXML += '	<cbc:CustomizationID>1.0</cbc:CustomizationID>' + cCRLF

	//Firma Electronica
	cXML += M486XmlFE() 
	
	cXML += '	<cbc:ID>' + aEncab[1] + '</cbc:ID>' + cCRLF  
	cXML += '	<cbc:IssueDate>' + aEncab[2] + '</cbc:IssueDate>' + cCRLF 
	
	//Emisor
	cXML += M486EMICER() 
	
	//Receptor
	cXML += M486RECCER(cProv,cLoja) 
	
	cXML += '	<sac:SUNATRetentionSystemCode>01</sac:SUNATRetentionSystemCode>' + cCRLF
	cXML += '	<sac:SUNATRetentionPercent>' + alltrim(TRANSFORM(aEncab[3],"999999.99")) + '</sac:SUNATRetentionPercent>' + cCRLF
	cXML += '	<cbc:Note/>' + cCRLF
	cXML += '	<cbc:TotalInvoiceAmount currencyID="'+ aEncab[6] +'">' + alltrim(TRANSFORM(aEncab[4],"999999.99")) + '</cbc:TotalInvoiceAmount>' + cCRLF
	cXML += '	<sac:SUNATTotalPaid currencyID="'+ aEncab[6] +'">' + alltrim(TRANSFORM(aEncab[5],"999999.99")) + '</sac:SUNATTotalPaid>' + cCRLF
		
	For nI := 1 to len(aDocRef)

		cXML += '	<sac:SUNATRetentionDocumentReference>' + cCRLF
		cXML += '		<cbc:ID schemeID="' + aDocRef[nI,9] + '">' + aDocRef[nI,1] + '</cbc:ID>' + cCRLF
		cXML += '		<cbc:IssueDate>' + aDocRef[nI,3] + '</cbc:IssueDate>' + cCRLF
		cXML += '		<cbc:TotalInvoiceAmount currencyID="'+ aDocRef[nI,2] +'">' + AllTrim(TRANSFORM(aDocRef[nI,4],"999999.99")) + '</cbc:TotalInvoiceAmount>' + cCRLF
		If !(aDocRef[nI,9] == "07")
			cXML += '		<cac:Payment>' + cCRLF
			cXML += '			<cbc:ID>' + Alltrim(Str(aDocRef[nI,10])) + '</cbc:ID>' + cCRLF
			cXML += '			<cbc:PaidAmount currencyID="'+ aDocRef[nI,2] +'">' + AllTrim(TRANSFORM(aDocRef[nI,5],"999999.99")) + '</cbc:PaidAmount>' + cCRLF
			cXML += '			<cbc:PaidDate>' + aEncab[2] + '</cbc:PaidDate>' + cCRLF
			cXML += '		</cac:Payment>' + cCRLF
			cXML += '		<sac:SUNATRetentionInformation>' + cCRLF
			cXML += '			<sac:SUNATRetentionAmount currencyID="'+ cCodMonPEN +'">' + alltrim(TRANSFORM(aDocRef[nI,6],"999999.99")) + '</sac:SUNATRetentionAmount>' + cCRLF //Default moneda PEN
			cXML += '			<sac:SUNATRetentionDate>' + aEncab[2] + '</sac:SUNATRetentionDate>' + cCRLF
			cXML += '			<sac:SUNATNetTotalPaid currencyID="'+ cCodMonPEN +'">' + alltrim(TRANSFORM(aDocRef[nI,11],"999999.99")) + '</sac:SUNATNetTotalPaid>' + cCRLF //Default moneda PEN
			cXML += '			<cac:ExchangeRate>' + cCRLF
			cXML += ' 				<cbc:SourceCurrencyCode>' + aDocRef[nI,2] + '</cbc:SourceCurrencyCode>' + cCRLF//Codigo moneda documento origen
			cXML += ' 				<cbc:TargetCurrencyCode>' + cCodMonPEN + '</cbc:TargetCurrencyCode>' + cCRLF //Default moneda PEN
			cXML += ' 				<cbc:CalculationRate>' + aDocRef[nI,8] + '</cbc:CalculationRate>' + cCRLF
			cXML += ' 				<cbc:Date>' + aDocRef[nI,12] + '</cbc:Date>' + cCRLF
			cXML += '			</cac:ExchangeRate>' + cCRLF
			cXML += '		</sac:SUNATRetentionInformation>' + cCRLF
		Endif
		cXML += '	</sac:SUNATRetentionDocumentReference>' + cCRLF
	
	Next nI
	
	cXML += '</Retention>' + cCRLF

Return cXML

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486RETFAC ³ Autor ³ Dora Vega             ³ Data ³ 06.07.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene los datos del Comprobante Relacionado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486RETFAC(cNumDoc, cSerie, aDocRef)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNumDoc .- Numero de documento.                              ³±±
±±³          ³ cSerie .- Numero o Serie del Documento.                      ³±±
±±³          ³ aDocRef .- Datos de identificacion del Documento.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486CERXML                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M486RETFAC(cNumDoc, cSerie, cFornece, cLoja, cOrdPago, aDocRef, nNoPago, cParcela, cEspecie)
	Local cMoneda := ""
	Local cTasMon := ""
	Local cFolio := ""
	Local cFecha := ""
	Local cFechOp:= ""
	Local nValBr := 0 
	Local nTamMon := IIf(AllTrim(cEspecie) == "NCP",TamSX3("F2_TXMOEDA")[1],TamSX3("F1_TXMOEDA")[1])
	Local nTamDes := IIf(AllTrim(cEspecie) == "NCP",TamSX3("F2_TXMOEDA")[2],TamSX3("F1_TXMOEDA")[2])
	Local nValCob := 0
	Local nValIRE := 0
	Local TotPag  := 0
	Local nResTot := 0
	Local cTipDoc := ""
	Local cFilSE  := xFilial("SE2")
	
	nTamDes := IIf(nTamDes > 6, 6, nTamDes) // de 4 a 6 decimales maximo
	
    If Alltrim((cTRB)->FE_ESPECIE) $ "NF|NDP"
		dbSelectArea("SF1")
		SF1->(dbSetOrder(1)) //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO 
		If SF1->(MsSeek(xfilial("SF1") + cNumDoc + cSerie + cFornece + cLoja)) 
			cMoneda := AllTrim(M486VALSX5("XQ"+AllTrim(Str(SF1->F1_MOEDA))))
			cFolio := RTRIM(SF1->F1_SERIE2)  + "-" + STRZERO(VAL(SF1->F1_DOC),8)
			cFecha := Substr(dTos(SF1->F1_EMISSAO),0,4) + "-" + Substr(dTos(SF1->F1_EMISSAO),5,2) + "-" +;
			Substr(dTos(SF1->F1_EMISSAO),7,2)
			nValBr := SF1->F1_VALBRUT
			nValCob := M486CERCP(cFilSE,cSerie,cNumDoc,cParcela,cEspecie,cFornece,cLoja)
			nValIRE := (cTRB)->FE_VALIMP
			TotPag  := (cTRB)->FE_VALBASE - nValIRE
			nResTot := nValCob - nValIRE
			if SF1->F1_MOEDA <> 1
				DbSelectArea("SEK")
				SEK->(dbSetOrder(1)) //EK_FILIAL + EK_ORDPAGO + EK_TIPODOC + EK_PREFIXO + EK_NUM
				If SEK->(MsSeek(xfilial("SEK") +cOrdPago+"TB"+cSerie+cNumDoc))
					cFechOp := Substr(dTos(SEK->EK_EMISSAO),0,4) + "-" + Substr(dTos(SEK->EK_EMISSAO),5,2) + "-" +;
					Substr(dTos(SEK->EK_EMISSAO),7,2)
					cTasMon := LTRIM(STR(&("SEK->EK_TXMOE0"+AllTRIM(STR(SF1->F1_MOEDA))),nTamMon,nTamDes ))
				EndIf
			Else
				cFechOp := Substr(dTos(SF1->F1_EMISSAO),0,4) + "-" + Substr(dTos(SF1->F1_EMISSAO),5,2) + "-" +;
				Substr(dTos(SF1->F1_EMISSAO),7,2)
				cTasMon := LTRIM(STR(SF1->F1_TXMOEDA,nTamMon,nTamDes))
			Endif
			cTipDoc := IIf(Alltrim((cTRB)->FE_ESPECIE) == "NF","01","08")
			aAdd(aDocRef ,{cFolio,cMoneda,cFecha,nValBr,nValCob,nValIRE,nResTot,cTasMon,cTipDoc,nNoPago,TotPag,cFechOp})
		EndIf
	ElseIf Alltrim((cTRB)->FE_ESPECIE) == "NCP"
		dbSelectArea("SF2")
		SF2->(dbSetOrder(1)) //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
		If SF2->(MsSeek(xfilial("SF2") + cNumDoc + cSerie + cFornece + cLoja)) 
			cMoneda := AllTrim(M486VALSX5("XQ"+AllTrim(Str(SF2->F2_MOEDA))))
			cFolio := RTRIM(SF2->F2_SERIE2)  + "-" + STRZERO(VAL(SF2->F2_DOC),8)
			cFecha := Substr(dTos(SF2->F2_EMISSAO),0,4) + "-" + Substr(dTos(SF2->F2_EMISSAO),5,2) + "-" +;
			Substr(dTos(SF2->F2_EMISSAO),7,2)	
			nValBr := SF2->F2_VALBRUT
			nValCob := M486CERCP(cFilSE,cSerie,cNumDoc,cParcela,cEspecie,cFornece,cLoja)
			nValIRE := Abs((cTRB)->FE_VALIMP)
			TotPag  := Abs((cTRB)->FE_VALBASE) - nValIRE
			nResTot := nValCob - nValIRE
			if SF2->F2_MOEDA <> 1
				DbSelectArea("SEK")
				SEK->(dbSetOrder(1))//EK_FILIAL+EK_ORDPAGO+EK_TIPODOC+EK_PREFIXO+EK_NUM
				If SEK->(MsSeek(xfilial("SEK") +cOrdPago+"TB"+cSerie+cNumDoc)) 
					cFechOp := Substr(dTos(SEK->EK_EMISSAO),0,4) + "-" + Substr(dTos(SEK->EK_EMISSAO),5,2) + "-" +;
					Substr(dTos(SEK->EK_EMISSAO),7,2)
					cTasMon := LTRIM(STR(&("SEK->EK_TXMOE0"+AllTRIM(STR(SF2->F2_MOEDA))),nTamMon,nTamDes ))
				EndIf
			Else
				cFechOp := Substr(dTos(SF2->F2_EMISSAO),0,4) + "-" + Substr(dTos(SF2->F2_EMISSAO),5,2) + "-" +;
				Substr(dTos(SF2->F2_EMISSAO),7,2)
				cTasMon := LTRIM(STR(SF2->F2_TXMOEDA,nTamMon,nTamDes ))
			Endif
			cTipDoc := "07"
			aAdd(aDocRef ,{cFolio,cMoneda,cFecha,nValBr,nValCob,nValIRE,nResTot,cTasMon,cTipDoc,nNoPago,TotPag,cFechOp})
		EndIf
	EndIf
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486EMICER ³ Autor ³ Dora Vega             ³ Data ³ 03.07.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de Emisor para XML de acuerdo al estandar  ³±±
±±³          ³ UBL 2.0 (PERU)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486EMICER()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ No aplica.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXMLEmi .- Nodo de emisor para XML de estandar UBL 2.0       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486CERXML                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M486EMICER()
	Local cXMLEmi := ""
	Local cCRLF	 := (chr(13)+chr(10))
	cXMLEmi += '	<cac:AgentParty>' + cCRLF
	cXMLEmi += '		<cac:PartyIdentification>' + cCRLF 
	cXMLEmi += '			<cbc:ID schemeID="6">' + RTRIM(SM0->M0_CGC) + '</cbc:ID>' + cCRLF 
	cXMLEmi += '		</cac:PartyIdentification>' + cCRLF 
	cXMLEmi += '		<cac:PartyName>' + cCRLF
	cXMLEmi += '			<cbc:Name><![CDATA[' + RTRIM(SM0->M0_NOMECOM) + ']]></cbc:Name>' + cCRLF 
	cXMLEmi += '		</cac:PartyName>' + cCRLF
	cXMLEmi += '		<cac:PostalAddress>' + cCRLF
	cXMLEmi += '			<cbc:ID>' + RTRIM(SM0->M0_CEPENT) + '</cbc:ID>' + cCRLF
	cXMLEmi += '           	<cbc:StreetName><![CDATA[' + RTRIM(SM0->M0_ENDENT) + ']]></cbc:StreetName>' + cCRLF
	cXMLEmi += '           	<cbc:CitySubdivisionName><![CDATA[' + RTRIM(SM0->M0_CIDENT) + ']]></cbc:CitySubdivisionName>' + cCRLF
	cXMLEmi += '           	<cbc:CityName><![CDATA[' + RTRIM(SM0->M0_CIDENT) + ']]></cbc:CityName>' + cCRLF
	cXMLEmi += '           	<cbc:CountrySubentity><![CDATA[' + RTRIM(SM0->M0_CIDENT) + ']]></cbc:CountrySubentity>' + cCRLF
	cXMLEmi += '			<cbc:District><![CDATA[' + RTRIM(SM0->M0_BAIRENT) + ']]></cbc:District>' + cCRLF
	cXMLEmi += '			<cac:Country>' + cCRLF
	cXMLEmi += '				<cbc:IdentificationCode>PE</cbc:IdentificationCode>' + cCRLF 
	cXMLEmi += '			</cac:Country>' + cCRLF
	cXMLEmi += '		</cac:PostalAddress>' + cCRLF
	cXMLEmi += '		<cac:PartyLegalEntity>' + cCRLF
	cXMLEmi += '			<cbc:RegistrationName><![CDATA[' + RTRIM(SM0->M0_NOME) + ']]></cbc:RegistrationName>' + cCRLF
	cXMLEmi += ' 		</cac:PartyLegalEntity>' + cCRLF
	cXMLEmi += '	</cac:AgentParty>' + cCRLF
Return cXMLEmi 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486RECCER ³ Autor ³ Dora Vega             ³ Data ³ 03.07.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Genera estructura de Receptor para XML de acuerdo al estandar³±±
±±³          ³ UBL 2.0 (PERU)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486RECCER(cProv,cLoja)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProv.- Clave del Proveedor                                  ³±±
±±³          ³ cLoja.- Clave de tienda del proveedor                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cXMLRec .- Nodo de receptor para XML de estandar UBL 2.0     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486CERXML                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M486RECCER(cProv,cLoja)
	Local cXMLRec := ""
	Local cCRLF	   := (chr(13)+chr(10))
	Local aArea   := getArea()
	Local cPais   := ""
		
	//Receptor (Proveedores)
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
	If SA2->(dbSeek(xFilial("SA2") + cProv + cLoja)) 			
		dbSelectArea("SYA")
		SYA->(dbSetOrder(1)) //YA_FILIAL+YA_CODGI
		If SYA->(dbSeek(xFilial("SYA") + SA2->A2_PAIS))
			cPais := SYA->YA_CODERP
		EndIf
		cXMLRec += '	<cac:ReceiverParty>' + cCRLF
		cXMLRec += '		<cac:PartyIdentification>' + cCRLF
		cXMLRec += '			<cbc:ID schemeID="6">' + RTRIM(SA2->A2_CGC) + '</cbc:ID>' + cCRLF
		cXMLRec += '		</cac:PartyIdentification>' + cCRLF
		cXMLRec += '		<cac:PartyName>' + cCRLF
		cXMLRec += '			<cbc:Name><![CDATA[' + RTRIM(SA2->A2_NOME) + ']]></cbc:Name>' + cCRLF 
		cXMLRec += '		</cac:PartyName>' + cCRLF
		cXMLRec += '		<cac:PostalAddress>' + cCRLF
		cXMLRec += '			<cbc:ID>' + RTRIM(SA2->A2_CEP) + '</cbc:ID>' + cCRLF
		cXMLRec += '			<cbc:StreetName><![CDATA[' + RTRIM(SA2->A2_END) + ']]></cbc:StreetName>' + cCRLF
		cXMLRec += '           	<cbc:CitySubdivisionName><![CDATA[' + RTRIM(SM0->M0_CIDENT) + ']]></cbc:CitySubdivisionName>' + cCRLF
		cXMLRec += '			<cbc:CityName><![CDATA[' + RTRIM(SA2->A2_MUN) + ']]></cbc:CityName>' + cCRLF
		cXMLRec += '           	<cbc:CountrySubentity><![CDATA[' + RTRIM(SM0->M0_CIDENT) + ']]></cbc:CountrySubentity>' + cCRLF
		cXMLRec += '			<cbc:District><![CDATA[' + RTRIM(SA2->A2_BAIRRO) + ']]></cbc:District>' + cCRLF
		cXMLRec += '			<cac:Country>' + cCRLF
		cXMLRec += '				<cbc:IdentificationCode>' + TRIM(cPais) + '</cbc:IdentificationCode>' + cCRLF
		cXMLRec += '			</cac:Country>' + cCRLF
		cXMLRec += '		</cac:PostalAddress>' + cCRLF
		cXMLRec += '		<cac:PartyLegalEntity>' + cCRLF
		cXMLRec += '			<cbc:RegistrationName><![CDATA[' + RTRIM(SA2->A2_NOME) + ']]></cbc:RegistrationName>' + cCRLF
		cXMLRec += '		</cac:PartyLegalEntity>' + cCRLF
		cXMLRec += '	</cac:ReceiverParty>' + cCRLF	
	EndIf
	RestArea(aArea)
Return cXMLRec

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486CERPAG ³ Autor ³ Luis Enríquez Mata    ³ Data ³ 15.01.21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida si anteriormente se realizó transmisión electrónica-  ³±±
±±³          ³ en algún Cert. de Retención alguna cuota para el documento de³±±
±±³          ³ referencia.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486CERPAG()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilSFE .- Sucursal que emitio el cert. de Retención.        ³±±
±±³          ³ cNumDoc .- Numero de documento.                              ³±±
±±³          ³ cSerie .- Numero o Serie del Documento.                      ³±±
±±³          ³ cFornece .- Codigo del Proveedor .                           ³±±
±±³          ³ cLoja .- Codigo de la tienda del cliente.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nNumPago .- Número de registros para documento transmitidos  ³±±
±±³          ³             previamente en otros certificados de retención   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486CERXML                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M486CERPAG(cFilSFE, cNumDoc,cSerie,cFornece,cLoja)
	Local nNumPago := 0
		dbSelectArea("SFE")
		SFE->(dbSetOrder(4)) //FE_FILIAL + FE_FORNECE + FE_LOJA + FE_NFISCAL + FE_SERIE + FE_TIPO + FE_CONCEPT  
		If SFE->(MsSeek(cFilSFE + cFornece + cLoja + cNumDoc + cSerie)) 
			While SFE->(!Eof()) .And. SFE->(FE_FILIAL + FE_FORNECE + FE_LOJA + FE_NFISCAL + FE_SERIE) == cFilSFE + cFornece + cLoja + cNumDoc + cSerie
				If !Empty(SFE->FE_FECAUT) .And. !Empty(SFE->FE_STATUS)
					nNumPago += 1
				EndIf
				SFE->(dbSkip())
			EndDo
		EndIf
Return nNumPago

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486CERCP ³ Autor ³ Luis Enríquez Mata    ³  Data ³ 22.01.21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Obtiene el valor del documento/parcilidad de tablas de cuenta³±±
±±³          ³ por pagar/cobrar (SE1/SE2)                                   ³±±
±±³          ³ referencia.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M486CERXML()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFilSE .- Sucursal de Ctas por Pagar/Cobrar.                 ³±±
±±³          ³ cPrefixo .- Serie del Documento.                             ³±±
±±³          ³ cNum .- Número del Documento.                                ³±±
±±³          ³ cParcela .- Parcela de del documento.                        ³±±
±±³          ³ cTipo .- Especie del cliente.                                ³±±
±±³          ³ cFornece .- Código del Proveedor del documento.              ³±±
±±³          ³ cLoja .- Código de la Tienda del documento.                  ³±±
±±³          ³ cOpc .- Opción de cuentas por pagar/cobrar.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nValor .- Valor de la cuentas por pagar/cobrar.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M486CERXML                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M486CERCP(cFilSE,cPrefixo,cNum,cParcela,cTipo,cFornece,cLoja)
	Local nValor := 0
	Local cTRBSE := getNextAlias()

	BeginSql alias cTRBSE
		SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR
		FROM  %table:SE2% SE2
		WHERE E2_FILIAL = %exp:cFilSE%
			AND E2_PREFIXO = %exp:cPrefixo%
			AND E2_NUM  = %exp:cNum%
			AND E2_PARCELA  = %exp:cParcela%
			AND E2_TIPO = %exp:cTipo%
			AND E2_FORNECE  = %exp:cFornece%
			AND E2_LOJA  = %exp:cLoja%
			AND SE2.%notDel%
		ORDER BY E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
	EndSql

	TCSetField(cTRB,"E2_VALOR","N")

	dbSelectArea(cTRBSE)
	
	While (cTRBSE)->(!EOF()) 
		nValor := (cTRBSE)->E2_VALOR
		(cTRBSE)->(dbSkip())
	Enddo
	
	(cTRBSE)->(dbcloseArea())
Return nValor
