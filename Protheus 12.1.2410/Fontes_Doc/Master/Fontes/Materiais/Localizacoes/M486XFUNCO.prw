#include 'protheus.ch'
#include 'parmtype.ch'
#include "FILEIO.CH"
#include "rwmake.ch"
#INCLUDE "M486XFUNCO.CH"

Static nTamCod  := Nil
Static nTamItem := Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M486XFUNCO ³ Autor ³Luis Eduardo Enríquez Mata³ Data ³ 24/07/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funciones genérias para transmisión de documentos electrónicos  ³±±
±±³ (COL)    ³ a la DIAN por medio del proveedor tecnológico TheFactory HKA.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA486                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data        ³ BOPS     ³ Motivo da Alteracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³LuisEnriquez³03/12/2019  ³DMINA-7923³Se activa nodo de TasaCambio, para do- ³±±
±±³            ³            ³          ³cumentos nacionales con moneda diferente±±
±±³            ³            ³          ³de COP. (COL)                           ±±
±±³LuisEnriquez³04/02/2020  ³DMINA-8044³Se activa funcionalidad para referencia³±±
±±³            ³            ³          ³adicional, ordenes de compra y retencio-±±
±±³            ³            ³          ³nes. (COL)                              ±±
±±³LuisEnriquez³12/03/2020  ³DMINA-8101³Se activa funcionalidad para tipo ope- ³±±
±±³            ³            ³          ³ración FE versión 1.8 DIAN (COL).       ±±
±±³LuisEnriquez³22/04/2020  ³DMINA-8877³Se activa clase InformacionAdicional   ³±±
±±³            ³            ³          ³para envio de autorretenciones (COL).   ±±
±±³LuisEnriquez³28/04/2020  ³DMINA-8799³Se activa el PE M486OWSCOL, para agre- ³±±
±±³            ³            ³          ³gar atributos opcionales (COL).         ±±
±±³LuisEnriquez³02/06/2020  ³DMINA-9364³Se activa en el PE M486OWSCOL,poder al-³±±
±±³            ³            ³          ³terar el elemento ctotalMonto (COL).    ±±
±±³LuisEnriquez³18/10/2020  ³DMINA-    ³Se agrega funcionalidad de campos ext. ³±±
±±³            ³            ³10236     ³para modificar por PE M486OWSCOL(COL).  ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*/{Protheus.doc} M486XMLHKA
Función para llenado de oWSfactura solicitado por TheFactory HKA, con datos obtenidos del XML.
@type function
@author luis.enriquez
@since 24/07/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486XMLHKA(cPrejixo, aFact, nPos, aError, lMailAut, lNoEnv, cFilSA, cFilAI0,cEmailEmp)
	Local aArea		 := getArea()
	Local cPathDocs  := GetNewPar("MV_CFDDOCS","")
	Local cNameXML   := ""
	Local aOpcDoc    := {}
	Local cTipoPer   := ""
	Local cCodImp    := ""
    Local cAviso     := ""
	Local cError     := ""
	Local oWS        := Nil
	Local oWSImpDet  := Nil
	Local oWSDescDet := Nil
	Local oWSDest    := Nil
	Local nX         := 1
	Local aRespObl   := {}
	Local cFacHexa   := ""
	Local cDetTri    := ""
	Local aTributos  := {}
	Local aImpGral   := {}
	Local aImpGralR  := {}
	Local cUrl       := SuperGetMV("MV_WSRTSS",,"")
	Local cNote      := ""
	Local cTpOper    := ""
	Local cVldD      := ""
	Local nY         := 0
	Local lM486CExt	 := ExistBlock("M486CEXT")
	Local aCamposExt := {}
	Local cMoedaFin	 := Alltrim( Posicione("CTO",1,xFilial("CTO")+"01","CTO_MOESAT") )
	Local nVlrRet    :=  0
	Local aDocSop 	 := {}
	Local cCliProv	 := ""
	Local cLojProv	 := ""
	Local cEmailRec  := ""
	Local lTipoPago  := SE4->(ColumnPos("E4_MPAGSAT")) > 0
	Local cTipoPago  := ""
	Local cMedioPag  := ""
	Local cFInicio	 := ""
	Local aFecha	 := {}
	Local cAlias	 := ""
	Local aFVence	 := {}
	Local oWSMedPago := Nil
	Local cCiuCli    := ""
	Local cCodDepCli := ""
	Local cDeptoCli  := ""
	Local cDirCli    := ""
	Local cMunCli    := ""
	Local cPaisCli   := ""
	Local cZPosCli   := ""
	Local cEmailCli  := ""
	Local cNomCli    := ""
	Local cRUCCli    := ""
	Local cDVCli     := ""
	Local cTpDocCli  := ""
	Local cTpoCli    := ""
	Local cTelCli    := ""
	Local cSegNom    := ""
	Local cApeCli    := ""
	Local lCpoReg    := AIT->(ColumnPos("AIT_REG")) > 0
	Local lPEAdj     := ExistBlock("M486PEADJU")
	Local lFuncF3I  := FindFunction("FATXVALF3I")
	Local aF3I		 := {}
	Local aImpuestos := {}
	Local nI         := 0
	Local cDoc       := ""
	Local cSerie     := ""
	Local cCliente   := ""
	Local cLoja      := ""
	Local cEsp       := ""
	Local cSepTasa   := "#"
	Local nIVA       := 0
	Local nINC       := 0
	Local nTotBol    := 0
	Local nOtroImp   := 0
	Local nRetIVA    := 0
	Local nRetFte    := 0
	Local nRetICA    := 0
	Local nValMerc   := 0 
	Local nValBrut   := 0
	Local nDescto    := 0
	Local cFEXP3     := ""
	Local cTxMoeda   := ""
	Local lConvExp   := .F.
	Local lConvDSAj  := .F.
	Local aDesc		 := {}
	Local oWSDescGrl := Nil
	Local lCpoAsum   := AI0->(ColumnPos("AI0_TS")) > 0
	Local lCpoMues   := .F.
	Local cTablaM	 := ""

	Private cInfoAd  := ""
	Private lPEWS    := ExistBlock("M486OWSCOL")
	Private lDocSp 	 := .F.
	Private lNotAjus := .F.

	Default cPrejixo  := "" 
	Default aFact     := {} 
	Default nPos      := 0
	Default aError    := {} 
	Default lMailAut  := .F.
	Default lNoEnv    := .F.
	Default cFilSA    := xFilial("SA1")
	Default cFilAI0   := xFilial("AI0")
	Default cEmailEmp := SuperGetMV("MV_EMAILRE",,"")
	
	
	cFacHexa:= M486XHEX(ALLTRIM( substr( aFact[nPos,2] , 4 , Len(aFact[nPos,2]) - 3 ) ),10)
	IF AllTrim(cEspecie) $ "NF" .And. SD2->(ColumnPos("D2_NICO")) > 0
		lCpoMues := .T.
		cTablaM := "SD2"
	ElseIf AllTrim(cEspecie) $ "NCC" .And. SD1->(ColumnPos("D1_NICO")) > 0
		lCpoMues := .T.
		cTablaM := "SD1"
	EndIf
	If cPaisLoc == "COL"
		lConvDSAj := SuperGetMV("MV_CONVEXP",.F.,.F.)
	Endif

	If cPrejixo $ "f|n" //Factura de Venta // Nota Ajuste
		aOpcDoc := {"_FE_INVOICE","_FE_INVOICELINE","_CBC_INVOICEDQUANTITY","_FE_ITEM","_FE_PRICE","_FE_LEGALMONETARYTOTAL"}
	ElseIf cPrejixo == "c" //Nota de Credito
		aOpcDoc := {"_FE_CREDITNOTE","_CAC_CREDITNOTELINE","_CBC_CREDITEDQUANTITY","_CAC_ITEM","_CAC_PRICE","_FE_LEGALMONETARYTOTAL"}		
	ElseIf cPrejixo == "d" //Nota de Debito
		aOpcDoc := {"_FE_DEBITNOTE","_CAC_DEBITNOTELINE","_CBC_DEBITEDQUANTITY","_CAC_ITEM","_CAC_PRICE","_FE_LEGALMONETARYTOTAL"}		
	EndIf
	
	cCliProv := aFact[nPos,3]
	cLojProv := aFact[nPos,4]
	
	If cPaisLoc == "COL"  
		If nTDTras == 6 
			dbSelectAre("SF1")
			dbSetOrder(1) //F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO)
			IF SF1->(dbSeek(xFilial("SF1")+aFact[nPos,2]+aFact[nPos,1]+aFact[nPos,3]+aFact[nPos,4]+PadR("NF",TamSX3("F1_ESPECIE")[1])))
				If SF1->(FieldPos("F1_SOPORT")) > 0
					lDocSp := IIf(SF1->F1_SOPORT == "S", .T.,.F.)
					cTpOper := Alltrim(SF1->F1_TIPOPE)
				EndIf
			EndIf
		ElseIf nTDTras == 8  .Or. nTDTras == 9 // Nota Ajuste 8 =NDP - 9=NCP
			lNotAjus := .T.
		EndIf
	EndIf
	cNameXML := &(cPathDocs) + Lower('face') + '_' + cPrejixo + PADR( Alltrim(SM0->M0_CGC) , 10 , "0" ) + cFacHexa + '.xml'
	
	oXML := XmlParserFile( cNameXML, "_", @cAviso,@cError ) //Lee XML
	
	If oXML <> Nil	
		oWS := WSNFECol():NEW()
		oWS:_URL := cUrl
		oWS:ctokenEmpresa  := SuperGetMV("MV_TKN_EMP",,"") // Token empresa
		oWS:ctokenPassword := SuperGetMV("MV_TKN_PAS",,"") // Token password

		oWS:oWSfactura:ccantidadDecimales := "2"
		oWS:cadjuntos  := IIf(lPEAdj,ExecBlock("M486PEADJU",.F.,.F.,{aFact[nPos,1],aFact[nPos,2],aFact[nPos,3],aFact[nPos,4],cPrejixo}),"0")

		cMoeDoc  :=	&("oXml:" + aOpcDoc[1] + ":_CBC_DOCUMENTCURRENCYCODE:TEXT")
		IF lCpoMues .And. lCpoAsum .And. Alltrim(AI0->AI0_TS) == "N" .And. AllTrim(cEspecie) $ "NF|NCC"
			M486DESGRA(xFilial(cTablaM), aFact[nPos,1],aFact[nPos,2],aFact[nPos,3],aFact[nPos,4],@aDesc,cTablaM)
			
			If Len(aDesc) > 0
				oWS:oWSfactura:OWSCARGOSDESCUENTOS := Service_ArrayOfCargosDescuentos():New()
				oWSDescGrl := Service_CargosDescuentos():New()
				oWSDescGrl:ccodigo := "00"
				IF XmlChildEx(&("oXml:" + aOpcDoc[1] + ":_CAC_ALLOWANCECHARGE"), "_CBC_ALLOWANCECHARGEREASON") <> Nil  
					oWSDescGrl:cdescripcion := &("oXml:" + aOpcDoc[1] + ":_CAC_ALLOWANCECHARGE:_CBC_ALLOWANCECHARGEREASON:TEXT")
				ELSE
					oWSDescGrl:cdescripcion := STR0011 //"Descuento por IVA Asumido"
				EndiF
				oWSDescGrl:cindicador := "0"
				oWSDescGrl:cmonto :=  Alltrim(Str(aDesc[1],,2))						
				oWSDescGrl:cmontoBase := AllTrim(Str(aDesc[2],,2))
				oWSDescGrl:csecuencia := "1"
				oWSDescGrl:cporcentaje :=AllTrim(Str(aDesc[3],,2))
				aAdd(oWS:oWSfactura:OWSCARGOSDESCUENTOS:OWSCARGOSDESCUENTOS, oWSDescGrl)
			EndIf
					
		EndIf
		//Cliente
		oWSCli := Service_Cliente():New()
		If (lDocSp .Or. lNotAjus) .And. lCpoReg //Documento Soporte - Notas de Ajuste (Crédito/Débito)
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
			If SA2->(MsSeek(cFilSA + cCliProv + cLojProv ))
				cCiuCli    := Alltrim(POSICIONE("CC2",3,xFilial("CC2") + SA2->A2_COD_MUN,"CC2_MUN"))
				cCodDepCli := Alltrim(SA2->A2_EST)
				cDeptoCli  := Alltrim(M486VALSX5('12' + SA2->A2_EST))
				cDirCli    := Alltrim(SA2->A2_END)
				cMunCli    := Alltrim(SA2->A2_COD_MUN)
				cPaisCli   := Posicione("SYA",1,xFilial("SYA")+SA2->A2_PAIS,"YA_CCEDIAN")
				cZPosCli   := Alltrim(SA2->A2_CEP)
				cEmailCli  := AllTrim(SA2->A2_EMAIL)
				cNomCli    := Alltrim(SA2->A2_NOME)
				cRUCCli    := IIf(AllTrim(SA2->A2_TIPDOC) == "31",Left(Alltrim(SA2->A2_CGC),Len(Alltrim(SA2->A2_CGC))-1),AllTrim(SA2->A2_PFISICA))
				cDVCli     := Right( Alltrim(SA2->A2_CGC), 1 )
				cTpDocCli  := AllTrim(SA2->A2_TIPDOC)
				cTpoCli    := AllTrim(SA2->A2_PESSOA)
				cTelCli    := AllTrim(SA2->A2_TEL)
				cTipoPer   := IIf( AllTrim(SA2->A2_PESSOA) == "F" , "2" , "1" )
				If cTipoPer == "2"
					cSegNom := Alltrim(SA2->A2_NOMEPES)
					cApeCli := Alltrim(SA2->A2_NOMEPAT)
				EndIf
			EndIf
			If !Empty(cEmailEmp)
				cEmailRec := cEmailEmp
			EndIf
		Else
			//Actividad económica
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA

			dbSelectArea("AI0")
			AI0->(dbSetOrder(1)) //AI0_FILIAL+AI0_CODCLI+AI0_LOJA
			
			If SA1->(MsSeek(cFilSA + cCliProv + cLojProv ))
				If !Empty(SA1->A1_ATIVIDA)
					oWSCli:cactividadEconomicaCIIU := Alltrim(SA1->A1_ATIVIDA)
				EndIf
				If AI0->(ColumnPos("AI0_RECE")) > 0 //Email especial para Recepción (Definido ante la DIAN)
					//Complementos del Cliente
					If AI0->(dbSeek(cFilAI0 + cCliProv + cLojProv ))
						If !Empty(AI0->AI0_RECE)
							cEmailRec := Alltrim(AI0->AI0_RECE)
						EndIf
					EndIf
				EndIf
				If Empty(cEmailRec)	
					If !Empty(SA1->A1_EMAIL)
						cEmailRec := Alltrim(SA1->A1_EMAIL)
					EndIf
				EndIf
			EndIf	
		EndIf		

		If lMailAut .And. !Empty(cEmailRec)
			oWSCli:cnotificar := "SI"

			//Destinatarios
			oWSCli:oWSdestinatario := Service_ArrayOfDestinatario():New()
			oWSDest := Service_Destinatario():New()

			oWSDest:ccanalDeEntrega := "0"

			//Email
			oWSDest:oWSemail := Service_ArrayOfstring():New()
			aAdd(oWSDest:oWSemail:cstring, cEmailRec)

			aAdd(oWSCli:oWSdestinatario:oWSDestinatario, oWSDest)
			lNoEnv := .F.
		Else
			oWSCli:cnotificar := "NO"
			If lMailAut .And. Empty(cEmailRec) //Documentos sin envío de email por falta de correo
				lNoEnv := .T.
			EndIf
		EndIf
		
		//Detalles tributarios
		cDetTri := M486RESOBL(cCliProv, cLojProv, "T", lDocSp, lNotAjus, lCpoReg)
		aTributos := StrTokArr(cDetTri, ";")
		oWSCli:oWSdetallesTributarios := Service_ArrayOfTributos():New()
		For nX := 1 To Len(aTributos)
			oWSDetTri := Service_Tributos():New()
			oWSDetTri:ccodigoImpuesto := aTributos[nX]
		    aAdd(oWSCli:oWSdetallesTributarios:oWSTributos, oWSDetTri)
		Next nX
		
		//Dirección cliente
		oWSCli:oWSdireccionCliente := Service_Direccion():New()
		If (lDocSp .Or. lNotAjus) .And. lCpoReg
			oWSCli:oWSdireccionCliente:cciudad := cCiuCli
			oWSCli:oWSdireccionCliente:ccodigoDepartamento := cCodDepCli
			oWSCli:oWSdireccionCliente:cdireccion := cDirCli
			oWSCli:oWSdireccionCliente:clenguaje := "es"
			oWSCli:oWSdireccionCliente:cpais := cPaisCli
			
			If !(cCodDepCli == "EX") //Diferente de extranjero
				oWSCli:oWSdireccionCliente:cdepartamento := cDeptoCli
				oWSCli:oWSdireccionCliente:cmunicipio := cMunCli
				oWSCli:oWSdireccionCliente:czonaPostal := cZPosCli
			EndIf
			
			//Dirección fiscal
			oWSCli:oWSdireccionFiscal := Service_Direccion():New()
			oWSCli:oWSdireccionFiscal:cciudad := cCiuCli
			oWSCli:oWSdireccionFiscal:ccodigoDepartamento := cCodDepCli			
			oWSCli:oWSdireccionFiscal:cdireccion := cDirCli
			oWSCli:oWSdireccionFiscal:clenguaje := "es"			
			oWSCli:oWSdireccionFiscal:cpais := cPaisCli
			
			If !(cCodDepCli == "EX") //Diferente de extranjero
				oWSCli:oWSdireccionFiscal:cdepartamento := cDeptoCli
				oWSCli:oWSdireccionFiscal:cmunicipio := cMunCli
				oWSCli:oWSdireccionFiscal:czonaPostal := cZPosCli
			EndIf

			If !Empty(cEmailCli)
				oWSCli:cemail := cEmailCli
			EndIf
			//Información legal del cliente
			oWSCli:oWSinformacionLegalCliente := Service_InformacionLegal():New()
			oWSCli:oWSinformacionLegalCliente:cnombreRegistroRUT := cNomCli
			oWSCli:oWSinformacionLegalCliente:cnumeroIdentificacion := cRUCCli
			oWSCli:oWSinformacionLegalCliente:cnumeroIdentificacionDV := cDVCli //Digito verificador
			oWSCli:oWSinformacionLegalCliente:ctipoIdentificacion := cTpDocCli

			If cTipoPer == "2" //Persona Natural
				oWSCli:cnombreRazonSocial := cNomCli
				If !Empty(cSegNom)
					oWSCli:csegundoNombre := cSegNom
				EndIf
				If !Empty(cApeCli)
					oWSCli:capellido := cApeCli
				EndiF
			Else //Persona Jurídica
				oWSCli:cnombreRazonSocial := cNomCli
			EndIf	
			
			If !Empty(cTelCli)
				oWSCli:ctelefono := cTelCli
			EndIf

			oWSCli:cnumeroDocumento := cRUCCli
			oWSCli:cnumeroIdentificacionDV := cDVCli //Digito verificador
		
			//Responsabilidades RUT Cliente
			oWSCli:oWSresponsabilidadesRut := Service_ArrayOfObligaciones():New()
			If (cTipoPer == "1" .Or. (lDocSp .And. cTipoPer == "2")) //Persona Jurídica/Fisica
				cRespCli := M486RESOBL(cCliProv, cLojProv, "R", lDocSp, lNotAjus, lCpoReg)
				aRespObl := StrTokArr(cRespCli, ";")
				If Len(aRespObl) > 0
					For nX := 1 To Len(aRespObl)
						oWSRespRUT := Service_Obligaciones():New()
						oWSRespRUT:cobligaciones := Alltrim(aRespObl[nX])
						aAdd(oWSCli:oWSresponsabilidadesRut:oWSObligaciones, oWSRespRUT)
					Next nX
				EndIf
			EndIf

			oWSCli:ctipoIdentificacion = cTpDocCli
			oWSCli:ctipoPersona = cTipoPer
		Else
			cCodDepCli := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CBC_COUNTRYSUBENTITYCODE:TEXT")
			oWSCli:oWSdireccionCliente:cdireccion := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CAC_ADDRESSLINE:_CBC_LINE:TEXT")
			oWSCli:oWSdireccionCliente:cpais := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CAC_COUNTRY:_CBC_IDENTIFICATIONCODE:TEXT")

			If !(cCodDepCli == "EX") //Diferente de extranjero
				oWSCli:oWSdireccionCliente:cdepartamento := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CBC_COUNTRYSUBENTITY:TEXT")
				oWSCli:oWSdireccionCliente:cmunicipio := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CBC_ID:TEXT")			
				oWSCli:oWSdireccionCliente:czonaPostal := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CBC_POSTALZONE:TEXT")
				oWSCli:oWSdireccionCliente:cciudad := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CBC_CITYNAME:TEXT") //Ciudad/Municipio
				oWSCli:oWSdireccionCliente:ccodigoDepartamento := cCodDepCli
				oWSCli:oWSdireccionCliente:clenguaje := "es"
			EndIf

			//Dirección fiscal
			oWSCli:oWSdireccionFiscal := Service_Direccion():New()
			oWSCli:oWSdireccionFiscal:cdireccion := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CAC_ADDRESSLINE:_CBC_LINE:TEXT")
			oWSCli:oWSdireccionFiscal:cpais := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CAC_COUNTRY:_CBC_IDENTIFICATIONCODE:TEXT")
			
			If !(cCodDepCli == "EX") //Diferente de extranjero
				oWSCli:oWSdireccionFiscal:cdepartamento := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CBC_COUNTRYSUBENTITY:TEXT")
				oWSCli:oWSdireccionFiscal:cmunicipio := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CBC_ID:TEXT")			
				oWSCli:oWSdireccionFiscal:czonaPostal := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CBC_POSTALZONE:TEXT")
				oWSCli:oWSdireccionFiscal:cciudad := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CAC_REGISTRATIONADDRESS:_CBC_CITYNAME:TEXT") //Ciudad/Municipio
				oWSCli:oWSdireccionFiscal:ccodigoDepartamento := cCodDepCli
				oWSCli:oWSdireccionFiscal:clenguaje := "es"
			EndIf
			
			If XmlChildEx(&("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY"), "_CAC_CONTACT") <> Nil          
				If XmlChildEx(&("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_CONTACT"), "_CBC_ELECTRONICMAIL") <> Nil
					oWSCli:cemail := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_CONTACT:_CBC_ELECTRONICMAIL:TEXT")
				EndIf
			EndIf

			//Información legal del cliente
			oWSCli:oWSinformacionLegalCliente := Service_InformacionLegal():New()
			oWSCli:oWSinformacionLegalCliente:cnombreRegistroRUT := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CBC_REGISTRATIONNAME:TEXT")
			oWSCli:oWSinformacionLegalCliente:cnumeroIdentificacion := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_COMPANYID:TEXT")
			oWSCli:oWSinformacionLegalCliente:cnumeroIdentificacionDV := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_COMPANYID:_SCHEMEID:TEXT") //Digito verificador
			oWSCli:oWSinformacionLegalCliente:ctipoIdentificacion := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_COMPANYID:_SCHEMENAME:TEXT")

			cTipoPer := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_CBC_ADDITIONALACCOUNTID:TEXT")
			If cTipoPer == "2" //Persona Natural
				oWSCli:cnombreRazonSocial := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CBC_REGISTRATIONNAME:TEXT")
				oWSCli:csegundoNombre     := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PERSON:_CBC_MIDDLENAME:TEXT")
				oWSCli:capellido          := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PERSON:_CBC_FAMILYNAME:TEXT")
			Else //Persona Jurídica
				oWSCli:cnombreRazonSocial := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYLEGALENTITY:_CBC_REGISTRATIONNAME:TEXT")
			EndIf	
			
			If XmlChildEx(&("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_CONTACT"), "_CBC_TELEPHONE") <> Nil
				oWSCli:ctelefono := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_CONTACT:_CBC_TELEPHONE:TEXT")
			EndIf

			oWSCli:cnumeroDocumento := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CBC_COMPANYID:TEXT")
			oWSCli:cnumeroIdentificacionDV := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CBC_COMPANYID:_SCHEMEID:TEXT") //Digito verificador
			
			cTpOper := &("oXml:" + aOpcDoc[1] + ":_CBC_CUSTOMIZATIONID:TEXT")
		
			//Responsabilidades RUT Cliente
			oWSCli:oWSresponsabilidadesRut := Service_ArrayOfObligaciones():New()
			If cTipoPer == "1" //Persona Jurídica	
				aRespObl := StrTokArr(&("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CBC_TAXLEVELCODE:TEXT"), ";")
				If Len(aRespObl) > 0
					For nX := 1 To Len(aRespObl)
						oWSRespRUT := Service_Obligaciones():New()
						oWSRespRUT:cobligaciones := Alltrim(aRespObl[nX])
						oWSRespRUT:cregimen := &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_FE_PARTYTAXSCHEME:_CBC_TAXLEVELCODE:_LISTNAME:TEXT")
						aAdd(oWSCli:oWSresponsabilidadesRut:oWSObligaciones, oWSRespRUT)
					Next nX
				EndIf
			EndIf

			oWSCli:ctipoIdentificacion = &("oXml:" + aOpcDoc[1] + ":_FE_ACCOUNTINGCUSTOMERPARTY:_FE_PARTY:_CAC_PARTYIDENTIFICATION:_CBC_COMPANYID:_SCHEMENAME:TEXT")
			oWSCli:ctipoPersona = cTipoPer
		EndIf
		
		oWS:oWSfactura:oWSCliente = oWSCli
		
		oWS:oWSfactura:cconsecutivoDocumento = &("oXml:" + aOpcDoc[1] + ":_CBC_ID:TEXT")
		
		//Detalle de la Factura
		oWSDetDoc := Service_ArrayOfFacturaDetalle():New()
		If Valtype(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2])) == "A" //Varios ítems
			For nX := 1 To Len(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2]))	
				M486DETDOC(@oWS, aOpcDoc, "oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2] + "[" + Str(nX) + "]",aFact,nPos,cTpOper,lCpoMues)		
			Next nX		
			oWS:oWSfactura:oWSdetalleDeFactura := oWSDetDoc	
			oWS:oWSfactura:ctotalProductos = Alltrim(Str(Len(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2]))))
		Else //Un ítem
			M486DETDOC(@oWS, aOpcDoc, "oXml:" + aOpcDoc[1] + ":" + aOpcDoc[2],aFact,nPos,cTpOper,lCpoMues)
			oWS:oWSfactura:ctotalProductos = "1"
		EndIf
		
		//Documentos Referenciados
		cVldD  := AllTrim(ObtColSAT("S017",cTpOper,1,4,88,1))
		If (!(cVldD $ "0|1|2") .Or. cVldD $ "1|2") .OR. lNotAjus
			oWSDocRef := Service_ArrayOfDocumentoReferenciado():NEW()
			If cPrejixo $ "c|d|n"
				cNote := &("oXml:" + aOpcDoc[1] + ":_CBC_NOTE:TEXT")
				If ValType(&("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE")) == "A"
					For nX := 1 To Len(&("oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE"))
						M486REFDOC(@oWSDocRef, aOpcDoc, "oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE[" + Str(nX) + "]",cNote,lNotAjus)
					Next nX
				Else
					M486REFDOC(@oWSDocRef, aOpcDoc, "oXml:" + aOpcDoc[1] + ":_CAC_BILLINGREFERENCE",cNote,lNotAjus)
				EndIf
			ElseIf cPrejixo == "f"
				If XmlChildEx(&("oXml:" + aOpcDoc[1]), "_CAC_ADDITIONALDOCUMENTREFERENCE") <> Nil
					If Valtype(&("oXml:" + aOpcDoc[1] + ":_CAC_ADDITIONALDOCUMENTREFERENCE")) == "A" 
						For nX := 1 To Len(&("oXml:" + aOpcDoc[1] + ":_CAC_ADDITIONALDOCUMENTREFERENCE"))
							M486REFADI(@oWSDocRef, aOpcDoc, "oXml:" + aOpcDoc[1] + ":_CAC_ADDITIONALDOCUMENTREFERENCE[" + Alltrim(Str(nX)) + "]")
						Next nX
					Else				
						M486REFADI(@oWSDocRef, aOpcDoc, "oXml:" + aOpcDoc[1] + ":_CAC_ADDITIONALDOCUMENTREFERENCE")
					EndIf
				EndIf
			EndIf						
			oWS:oWSfactura:oWSDocumentosReferenciados := oWSDocRef	
		EndIf
	
		
		oWS:oWSfactura:cfechaEmision := &("oXml:" + aOpcDoc[1] + ":_CBC_ISSUEDATE:TEXT") + " " + &("oXml:" + aOpcDoc[1] + ":_CBC_ISSUETIME:TEXT")
					
		//Medios de pago (Factura)
		oWS:oWSfactura:oWSmediosDePago := Service_ArrayOfMediosDePago():New()
		If lTipoPago
			cAlias := IIF(AllTrim(cEspecie) $ "NF|NDC|NCP" .AND. !lDocSp,"SF2","SF1")
			dbSelectArea(cAlias)
			(cAlias)->(dbSetOrder(1)) //SF2->F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO##SF1->F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO   
			If cAlias == "SF2"
				SF2->(dbSeek(xFilial("SF2")+aFact[nPos,2]+aFact[nPos,1]+aFact[nPos,3]+aFact[nPos,4]))
				cMedioPag := IIF(SF2->(ColumnPos("F2_TPDOC"))>0 ,SF2->F2_TPDOC,"1")
				cFInicio := IIF(SF2->(ColumnPos("F2_PTOEMIS"))>0 ,Alltrim("01-" + SF2->F2_PTOEMIS),"")
				nValMerc  := SF2->F2_VALMERC
				nValBrut  := SF2->F2_VALBRUT
				nDescto   := SF2->F2_DESCONT
			Else
				SF1->(dbSeek(xFilial("SF1")+aFact[nPos,2]+aFact[nPos,1]+aFact[nPos,3]+aFact[nPos,4]))
				cMedioPag := IIF(SF1->(ColumnPos("F1_TPDOC"))>0 ,SF1->F1_TPDOC,"1")
				cFInicio  := IIF(SF1->(ColumnPos("F1_PTOEMIS"))>0 ,Alltrim("01-" + SF1->F1_PTOEMIS),"")
				nValMerc  := SF1->F1_VALMERC
				nValBrut  := SF1->F1_VALBRUT
				nDescto   := SF1->F1_DESCONT
			EndIf
			cTipoPago := IIF(FindFunction("M486TPPAG"),M486TPPAG(xFilial("SE4"),(cAlias)->&(REPLACE(cAlias,"S","")+"_COND")),"")

			//Periodo de Facturación
			If &("oXml:" + aOpcDoc[1] + ":_CBC_CUSTOMIZATIONID:TEXT") $ "22|32" .And. Len(cFInicio) == 10
				aFecha := StrTokArr(cFInicio,"-")
				oWS:oWSfactura:cfechaInicioPeriodoFacturacion   := aFecha[3] + "-" + aFecha[2] + "-" + aFecha[1] + " 00:00:00"
				oWS:oWSfactura:cfechaFinPeriodoFacturacion      := aFecha[3] + "-" + aFecha[2] + "-" + cValToChar(Last_Day(cFInicio)) + " 00:00:00"
			EndIf	
		
			If cTipoPago == "2" //Crédito
				M486COLVEN(cAlias,aFact[nPos,3],aFact[nPos,4],aFact[nPos,1],aFact[nPos,2],AllTrim((cAlias)->&(Replace(cAlias,"S","")+"_ESPECIE")),@aFVence)
				For nX := 1 To Len(aFVence)
					M486MedPago(AllTrim(cMedioPag),cTipoPago,aFVence[nx][1],@oWSMedPago)
					aAdd(oWS:oWSfactura:oWSmediosDePago:oWSMediosDePago, oWSMedPago)
				Next nX	
			Else
				M486MedPago(AllTrim(cMedioPag),cTipoPago,"",@oWSMedPago)
				aAdd(oWS:oWSfactura:oWSmediosDePago:oWSMediosDePago, oWSMedPago)
			EndIf
		Else
			M486MedPago("1","1","",@oWSMedPago)
			aAdd(oWS:oWSfactura:oWSmediosDePago:oWSMediosDePago, oWSMedPago)
		EndIf

		//Orden de Compra		
		oWS:oWSfactura:oWSordenDeCompra := Service_ArrayOfOrdenDeCompra():New()
		
		If XmlChildEx(&("oXml:" + aOpcDoc[1]), "_CAC_ORDERREFERENCE") <> Nil
			oWSOC := Service_ArrayOfOrdenDeCompra():New()			
			If Valtype(&("oXml:" + aOpcDoc[1] + ":_CAC_ORDERREFERENCE")) == "A" 				
				For nX := 1 To Len(&("oXml:" + aOpcDoc[1] + ":_CAC_ORDERREFERENCE"))
					M486ORDCOM(@oWSOC, ":_CAC_ORDERREFERENCE[" + Alltrim(Str(nX)) + "]")
				Next nX				
			Else
				M486ORDCOM(@oWSOC, ":_CAC_ORDERREFERENCE")	
			EndIf
			oWS:oWSfactura:oWSordenDeCompra:oWSOrdenDeCompra := oWSOC:oWSOrdenDeCompra
		EndIf	
	
		//Tasa de cambio
		If XmlChildEx(&("oXml:" + aOpcDoc[1]), "_CAC_PAYMENTEXCHANGERATE") <> Nil
			oWS:oWSfactura:oWStasaDeCambio := Service_TasaDeCambio():New()
			oWS:oWSfactura:oWStasaDeCambio:cbaseMonedaDestino := &("oXml:" + aOpcDoc[1] + ":_CAC_PAYMENTEXCHANGERATE:_CBC_TARGETCURRENCYBASERATE:TEXT")
			oWS:oWSfactura:oWStasaDeCambio:cbaseMonedaOrigen  := &("oXml:" + aOpcDoc[1] + ":_CAC_PAYMENTEXCHANGERATE:_CBC_SOURCECURRENCYBASERATE:TEXT")
			oWS:oWSfactura:oWStasaDeCambio:cfechaDeTasaDeCambio := &("oXml:" + aOpcDoc[1] + ":_CAC_PAYMENTEXCHANGERATE:_CBC_DATE:TEXT")
			oWS:oWSfactura:oWStasaDeCambio:cmonedaDestino := &("oXml:" + aOpcDoc[1] + ":_CAC_PAYMENTEXCHANGERATE:_CBC_TARGETCURRENCYCODE:TEXT")
			oWS:oWSfactura:oWStasaDeCambio:cmonedaOrigen := &("oXml:" + aOpcDoc[1] + ":_CAC_PAYMENTEXCHANGERATE:_CBC_SOURCECURRENCYCODE:TEXT")
			oWS:oWSfactura:oWStasaDeCambio:ctasaDeCambio := &("oXml:" + aOpcDoc[1] + ":_CAC_PAYMENTEXCHANGERATE:_CBC_CALCULATIONRATE:TEXT")
		EndIf
		If Len(aDesc) > 0
			oWS:oWSfactura:ctotalMonto := Alltrim(Str(Val(&("oXml:" + aOpcDoc[1] + ":_FE_LEGALMONETARYTOTAL:_CBC_PAYABLEAMOUNT:TEXT")) -aDesc[1],,2))
			oWS:oWSfactura:ctotalDescuentos := Alltrim(Str(aDesc[1],,2))
		Else
			oWS:oWSfactura:ctotalMonto := &("oXml:" + aOpcDoc[1] + ":_FE_LEGALMONETARYTOTAL:_CBC_PAYABLEAMOUNT:TEXT")
		EndIf
	 	If lDocSp
			oWS:oWSfactura:ctipoDocumento := "05" //Doct Soporte
		ElseIf lNotAjus
			oWS:oWSfactura:ctipoDocumento := "95" //Nota Ajuste 
		Else
			oWS:oWSfactura:ctipoDocumento := PadL(&("oXml:" + aOpcDoc[1] + ":_CBC_INVOICETYPECODE:TEXT"),2,"0")
		EndIf

		If cMoeDoc <> "COP"
			If lDocSp .Or. lNotAjus
				lConvExp := lConvDSAj
			Elseif AllTrim(cEspecie) $ "NF|NDC|NCC"
				lConvExp := .T.
			endif
		Endif

		oWS:oWSfactura:cmoneda := IIf(lConvExp,"COP",cMoeDoc)
		
		aSize(aCamposExt, 0)
		
		If lM486CExt
			// PE de campos extensibles
			M486CExt(aFact[nPos], aCamposExt)
		EndIf

		//Campos Extensibles para retenciones en Notas de Crédito
		If ((Alltrim(cEspecie) $ "NCC|NDC") .And. !lDocSp) .Or. lNotAjus
			//Impuestos generales (Factura-Retenciones)	
			If XmlChildEx(&("oXml:" + aOpcDoc[1]), "_FE_WITHHOLDINGTAXTOTAL") <> Nil
				If ValType(&("oXml:" + aOpcDoc[1] + ":_FE_WITHHOLDINGTAXTOTAL")) == "A" //Varios impuestos
					For nX := 1 To Len(&("oXml:" + aOpcDoc[1] + ":_FE_WITHHOLDINGTAXTOTAL"))
						nVlrRet += Val(&("oXml:" + aOpcDoc[1] + ":_FE_WITHHOLDINGTAXTOTAL[" + Str(nX) + "]:_CBC_TAXAMOUNT:TEXT"))
					Next nX
				Else //Un solo impuesto
					nVlrRet := Val(&("oXml:" + aOpcDoc[1] + ":_FE_WITHHOLDINGTAXTOTAL:_CBC_TAXAMOUNT:TEXT"))
				EndIf 
			EndIf		
			If nVlrRet > 0
				aAdd( aCamposExt , {"TOTAL Retenciones", "", "5170002", "1", Alltrim(TRANSFORM(nVlrRet,"999,999,999,999,999.99")), "0"} )
			EndIf
		EndIf

		//Campos extras
		If lFuncF3I
			aF3I := FATXVALF3I("S019","NOMBRE","5170007") //Campo de Fabricante de Software
			If !Empty(aF3I)
				aF3I[4]:=IIf(Empty(aF3I[4]),1,aF3I[4]) 
				aF3I[6]:=IIf(Empty(aF3I[6]),1,aF3I[6]) 
				AADD( aCamposExt, aF3I )
			EndIf
		EndIf
		If oWS:oWSfactura:ctipoDocumento $ "08|05" .and. !lDocSp .and. !lNotAjus
			// NF, NDC, NCC de exportación
			If aScan(aCamposExt, {|x|x[3]=="81"} ) == 0
				cMoedaOri := cMoeDoc

				If oWS:oWSfactura:ctipoDocumento $ "02|08"
					SF2->(dbSeek(xFilial("SF2")+aFact[nPos,2]+aFact[nPos,1]))
					cTxMoeda := Alltrim(Str(SF2->F2_TXMOEDA))
				Else
					SF1->(dbSeek(xFilial("SF1")+aFact[nPos,2]+aFact[nPos,1]))
					cTxMoeda := Alltrim(Str(SF1->F1_TXMOEDA))
				EndIf

				aAdd( aCamposExt , {"Tasa de Cambio"   , "", "81", "1", "1"      , "1"} )
				aAdd( aCamposExt , {"Moneda Origen"    , "", "83", "1", cMoedaOri, "1"} )
				aAdd( aCamposExt , {"Moneda Final"     , "", "84", "1", cMoedaFin, "1"} )
				aAdd( aCamposExt , {"Valor del Calculo", "", "85", "1", cTxMoeda , "1"} )
			EndIf
		EndIf
		cDoc := Iif(Alltrim(cEspecie) $ "NF/NDC/NCP",SF2->F2_DOC,SF1->F1_DOC)
		cSerie := Iif(Alltrim(cEspecie) $ "NF/NDC/NCP",SF2->F2_SERIE,SF1->F1_SERIE)
		cCliente := Iif(Alltrim(cEspecie) $ "NF/NDC/NCP",SF2->F2_CLIENTE,SF1->F1_FORNECE)
		cLoja := Iif(Alltrim(cEspecie) $ "NF/NDC/NCP",SF2->F2_LOJA,SF1->F1_LOJA)
	
		aImpuestos := M486GETTAX(cDoc, cSerie,cCliente, cLoja,cEspecie)
		For nI := 1 to len(aImpuestos)
			if Alltrim(aImpuestos[nI][1]) == "ZZ" .and. aImpuestos[nI][5] > 0 .and. aImpuestos[nI][6] > 0
				aF3I := FATXVALF3I("S020","IMPUESTO",aImpuestos[nI][2])
				If !Empty(aF3I)
					aF3I[1] := Alltrim(aF3I[1])
					aF3I[2] := Alltrim(aF3I[2])
					aF3I[3] := Alltrim(aF3I[3])
					aF3I[4]:=IIf(Empty(aF3I[4]),1,aF3I[4]) 
					aF3I[5] := Alltrim(aF3I[5])
					aF3I[6]:=IIf(Empty(aF3I[6]),1,aF3I[6]) 
					aF3I[7] := Alltrim(aF3I[7])
					AADD( aCamposExt, aF3I )
				EndIf
			Endif
		Next nI
		If AllTrim(cEspecie) $ "NF|NDC|NCC" .And. !lDocSp .And. !lNotAjus .And. lConvExp .And. cMoeDoc <> "COP"//Documento de Exportación
			cTxMoeda := IIf(Alltrim(cEspecie) == "NCC",SF1->F1_TXMOEDA,SF2->F2_TXMOEDA)
			M486GETIMP(cDoc, cSerie, cCliente, cLoja, @nIVA, @nINC, @nTotBol, @nOtroImp, @nRetIVA, @nRetFte, @nRetICA)
			cFEXP3 := Alltrim(Str(cTxMoeda)) + cSepTasa + ; //1.Valor tasa de cambio
			Alltrim(cMoeDoc) + cSepTasa + ;          //2.Nombre de moneda
			Alltrim(Str(nValMerc,20,2)) + cSepTasa + ; //3. Sub Total
			"0.00" + cSepTasa + ;                      //4.Descuento a nivel de detalle
			"0.00" + cSepTasa + ;                      //5.Recargo a nivel de detalle
			Alltrim(Str(nValMerc,20,2)) + cSepTasa + ; //6.Campo para informar el total bruto
			Alltrim(Str(nIVA,20,2)) + cSepTasa + ;     //7.Campo para informar el total IVA
			Alltrim(Str(nINC,20,2)) + cSepTasa + ;     //8.Campo para informar el total INC
			Alltrim(Str(nTotBol,20,2)) + cSepTasa + ;  //9.Total de impuesto a la bolsa
			Alltrim(Str(nOtroImp,20,2)) + cSepTasa + ; //10.total de otros impuesto diferentes a los anteriores reportados
			"0.00" +  cSepTasa + ;                     //11.monto total de los impuestos
			Alltrim(Str(nValBrut,20,2)) + cSepTasa + ; //12.Valor total a pagar
			Alltrim(Str(nDescto,20,2)) + cSepTasa + ;  //13.Descuento global
			"0.00" + cSepTasa + ;                      //14.Recargo global
			Alltrim(Str(nValBrut,20,2)) + cSepTasa + ; //15.Valor a pagar
			Alltrim(Str(nRetFte,20,2)) + cSepTasa + ;  //16.ReteFuente
			Alltrim(Str(nRetIVA,20,2)) + cSepTasa + ;  //17.ReteIva
			"0.00" + cSepTasa + ;                      //18.ReteIca
			"0.00"                                     //19.Total anticipos
			//Extra para NF de Exportación
			aAdd( aCamposExt , {"", "", "FEXP1", "1", "1", "1"} )
			aAdd( aCamposExt , {"", "", "FEXP2", "1", "Responsable: #Lugar de Salida: #Medio de transporte: #Tipo de Doc.de transporte: #N° de Doc. de transporte: #Transportadora o Tramitadora: #País de Origen de la M/cia: #Destino: #Términos de pago: #Seguro: #Observaciones:", "1"} )
			aAdd( aCamposExt , {"TotalesCop", "", "FEXP3", "1", cFEXP3, "1"} )
		EndIf

		If Len(aCamposExt) > 0
			oWS:oWSfactura:oWSextras := Service_ArrayOfExtras():NEW()
			For nY := 1 to Len(aCamposExt)
				oWSCamposExt := Service_Extras():NEW()
				oWSCamposExt:ccontrolInterno1 := aCamposExt[nY,1]
				oWSCamposExt:ccontrolInterno2 := aCamposExt[nY,2]
				oWSCamposExt:cnombre := aCamposExt[nY,3]
				oWSCamposExt:cpdf := aCamposExt[nY,4]
				oWSCamposExt:cvalor := aCamposExt[nY,5]
				oWSCamposExt:cxml := aCamposExt[nY,6]
				aAdd(oWS:oWSfactura:oWSextras:oWSextras , oWSCamposExt)
			Next nY
		EndIf				
	 
		If lPEWS
			ExecBlock("M486OWSCOL",.F.,.F.,{aFact[nPos,1],aFact[nPos,2],aFact[nPos,3],aFact[nPos,4],&("oXml:" + aOpcDoc[1]),1,@oWS:oWSfactura})
		EndIf
		
		oWS:oWSfactura:oWSimpuestosGenerales := Service_ArrayOfFacturaImpuestos():NEW()
		//Impuestos generales (Factura)	
		If XmlChildEx(&("oXml:" + aOpcDoc[1]), "_FE_TAXTOTAL") <> Nil
			If ValType(&("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL")) == "A" //Varios impuestos
				For nX := 1 To Len(&("oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL"))
					M486TAXTOT(@oWS, "oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL[" + Str(nX) + "]", @aImpGral)
				Next nX
			Else //Un solo impuesto
				M486TAXTOT(@oWS,"oXml:" + aOpcDoc[1] + ":_FE_TAXTOTAL", @aImpGral)
			EndIf 
		EndIf
		
		If (!(Alltrim(cEspecie) $ "NCC|NDC") .And. !lNotAjus) .Or. lDocSp
			//Impuestos generales (Factura-Retenciones)	
			If XmlChildEx(&("oXml:" + aOpcDoc[1]), "_FE_WITHHOLDINGTAXTOTAL") <> Nil
				If ValType(&("oXml:" + aOpcDoc[1] + ":_FE_WITHHOLDINGTAXTOTAL")) == "A" //Varios impuestos
					For nX := 1 To Len(&("oXml:" + aOpcDoc[1] + ":_FE_WITHHOLDINGTAXTOTAL"))
						M486TAXTOT(@oWS, "oXml:" + aOpcDoc[1] + ":_FE_WITHHOLDINGTAXTOTAL[" + Str(nX) + "]", @aImpGralR, @cInfoAd)
					Next nX
				Else //Un solo impuesto
					M486TAXTOT(@oWS,"oXml:" + aOpcDoc[1] + ":_FE_WITHHOLDINGTAXTOTAL", @aImpGralR, @cInfoAd)
				EndIf 
			EndIf
		EndIf
		
		//Autoretenciones
		If !Empty(cInfoAd)
			oWS:oWSfactura:oWSinformacionAdicional := Service_ArrayOfstring():New()
			aAdd(oWS:oWSfactura:oWSinformacionAdicional:cstring, cInfoAd)
		EndIf
		
		//Impuestos totales (Factura)
		oWS:oWSfactura:oWSimpuestosTotales := Service_ArrayOfImpuestosTotales():New()
		For nX := 1 To Len(aImpGral)
			oWSImpTot := Service_ImpuestosTotales():New()
			oWSImpTot:ccodigoTOTALImp := aImpGral[nX][1]
			oWSImpTot:cmontoTotal := Alltrim(Str(aImpGral[nX][2]))
			aAdd(oWS:oWSfactura:oWSimpuestosTotales:oWSImpuestosTotales, oWSImpTot)
		EndFor
		
		//Impuestos totales (Factura-Retenciones)
		For nX := 1 To Len(aImpGralR)
			oWSImpTot := Service_ImpuestosTotales():New()
			oWSImpTot:ccodigoTOTALImp := aImpGralR[nX][1]
			oWSImpTot:cmontoTotal := Alltrim(Str(aImpGralR[nX][2]))
			aAdd(oWS:oWSfactura:oWSimpuestosTotales:oWSImpuestosTotales, oWSImpTot)
		EndFor
				
		oWS:oWSfactura:crangoNumeracion := Alltrim(&("oXml:" + aOpcDoc[1] + ":_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION[1]:_EXT_EXTENSIONCONTENT:_STS_DIANEXTENSIONS:_STS_INVOICECONTROL:_STS_AUTHORIZEDINVOICES:_STS_PREFIX:TEXT")) + "-" + ;
			                              Alltrim(Str(Val(&("oXml:" + aOpcDoc[1] + ":_EXT_UBLEXTENSIONS:_EXT_UBLEXTENSION[1]:_EXT_EXTENSIONCONTENT:_STS_DIANEXTENSIONS:_STS_INVOICECONTROL:_STS_AUTHORIZEDINVOICES:_STS_FROM:TEXT"))))
		oWS:oWSfactura:ctipoOperacion := &("oXml:" + aOpcDoc[1] + ":_CBC_CUSTOMIZATIONID:TEXT")
		If XmlChildEx(&("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[6]), "_CBC_TAXEXCLUSIVEAMOUNT") <> Nil
			oWS:oWSfactura:ctotalBaseImponible := &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[6] + ":_CBC_TAXEXCLUSIVEAMOUNT:TEXT")
		Else
			oWS:oWSfactura:ctotalBaseImponible = "0.00"
		EndIf			 
		oWS:oWSfactura:ctotalBrutoConImpuesto = &("oXml:" + aOpcDoc[1] + ":" + aOpcDoc[6] + ":_CBC_PAYABLEAMOUNT:TEXT")		
		oWS:oWSfactura:ctotalSinImpuestos := &("oXml:" + aOpcDoc[1] + ":_FE_LEGALMONETARYTOTAL:_CBC_LINEEXTENSIONAMOUNT:TEXT")
	Else
		aAdd(aError, {aFact[nPos,1],aFact[nPos,2],aFact[nPos,3],aFact[nPos,4],"XML mal generado, revise el script correspondiente (FATECOL.INI, FATSCOL.INI, FATSECOL.INI)."}) //"XML mal generado, revise el script correspondiente (FATECOL.INI, FATSCOL.INI, FATSECOL.INI)."
	EndIf
	
	RestArea(aArea)	
Return oWS

/*/{Protheus.doc} M486DETDOC
Función para llenado de oWSdetalleDeFactura solicitado por TheFactory HKA, con datos obtenidos del XML.
@type function
@author luis.enriquez
@since 24/07/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486DETDOC(oWS, aOpcDoc, cObjXML,aFact,nPosDoc,cTpOper,lCpoMues)
	Local aImpGralD := {}
	Local nX   := 0
	Local nPos := 0
	Local cCodMand := ""
	Local aF3I      := {}
	Local cItem := ""
	Local cProd := ""
	Local lMuestra	:= .F. 
	Local nPrec	:= 0
	Local cPref := ""
	Local nDetOrd := 3
	Local cAlias  := ""
	Local aArea   := GetArea()
	Default aOpcDoc := {}
	Default cObjXML := ""
	Default aFact   := {}
	Default nPosDoc := 0
	Default cTpOper := ""
	Default lCpoMues := .F.

	If AllTrim(cEspecie) $ "NF|NCC" .And. lCpoMues
	
		If AllTrim(cEspecie) $ "NF"
			cAlias  := "SD2"
			nDetOrd := 3  //D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
		Else
			cAlias := "SD1"
			nDetOrd := 1 //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		EndIf	
		cPref := Replace(cAlias,"S","")
		If nTamCod == Nil
  			nTamCod := FWSX3Util():GetFieldStruct( cPref+"_COD" )[3]
		EndIf
		cProd := PadR(&(cObjXML + ":" + aOpcDoc[4] + ":_CAC_SELLERSITEMIDENTIFICATION:_CBC_ID:TEXT"),nTamCod)
		If nTamItem == Nil
  			nTamItem := FWSX3Util():GetFieldStruct( cPref+"_ITEM" )[3]
		EndIf
		cItem := PadL(&(cObjXML + ":_CBC_ID:TEXT"),nTamItem,"0")
		dbSelectArea(cAlias)
		(cAlias)->(dbSetOrder(nDetOrd))
		If (cAlias)->(Msseek(xFilial(cAlias) + aFact[nPosDoc,2] + aFact[nPosDoc,1]+ aFact[nPosDoc,3] + aFact[nPosDoc,4]+cProd+cItem))
			If Alltrim((cAlias)->&(cPref+"_NICO")) == "S"
				lMuestra:=.T.
			EndIf
		EndIF
	EndIf
	oWSDet := Service_FacturaDetalle():New()	
	oWSDet:ccantidadPorEmpaque := &(cObjXML + ":" + aOpcDoc[4] + ":_CBC_PACKSIZENUMERIC:TEXT")
	oWSDet:ccantidadReal := Alltrim(&(cObjXML + ":" + aOpcDoc[5] + ":_CBC_BASEQUANTITY:TEXT"))
	oWSDet:ccantidadRealUnidadMedida := &(cObjXML + ":" + aOpcDoc[3] + ":_UNITCODE:TEXT")
	oWSDet:ccantidadUnidades := &(cObjXML + ":" + aOpcDoc[3] + ":TEXT")
	If XmlChildEx(&(cObjXML + ":" + aOpcDoc[4]),"_CBC_IDMANDATORY") <> NIL
		cCodMand := &(cObjXML + ":" + aOpcDoc[4] + ":_CBC_IDMANDATORY:TEXT")
	Endif
	If cTpOper == "11" 
		oWSDet:cidEsquema := "1"
		If !Empty(cCodMand)
			aF3I := FATXVALF3I("S022","CODIGO",cCodMand)
			If !Empty(aF3I)
				If !Empty(aF3I[2]) // NIT
					oWSDet:cmandatorioNumeroIdentificacion := AllTrim(aF3I[3])
				Endif
				If !Empty(aF3I[3]) // DIGITO VERIFICADOR
					oWSDet:cmandatorioNumeroIdentificacionDV := Alltrim(aF3I[4])			
				Endif
				If !Empty(aF3I[4]) // Tipo Identificación
					oWSDet:cmandatorioTipoIdentificacion := Alltrim(aF3I[5])			
				Endif 
			EndIf
		Else
			oWSDet:cidEsquema := "0"
		Endif		
	EndIf
	//Descuentos
	If XmlChildEx(&(cObjXML), "_CAC_ALLOWANCECHARGE") <> Nil
		oWSDet:oWScargosDescuentos := Service_ArrayOfCargosDescuentos():New()
		oWSDescDet := Service_CargosDescuentos():New()
		oWSDescDet:cindicador := "0"
		oWSDescDet:cdescripcion := &(cObjXML + ":_CAC_ALLOWANCECHARGE:_CBC_ALLOWANCECHARGEREASON:TEXT")
		oWSDescDet:cmonto := &(cObjXML + ":_CAC_ALLOWANCECHARGE:_CBC_AMOUNT:TEXT")								
		oWSDescDet:cmontoBase := Alltrim(Str(Val(&(cObjXML + ":_CAC_ALLOWANCECHARGE:_CBC_AMOUNT:TEXT")) + ;
		                                     Val(&(cObjXML + ":_CBC_LINEEXTENSIONAMOUNT:TEXT")),16,2))
		oWSDescDet:csecuencia := "1"
		oWSDescDet:cporcentaje := &(cObjXML + ":_CAC_ALLOWANCECHARGE:_CBC_MULTIPLIERFACTORNUMERIC:TEXT")
		aAdd(oWSDet:oWScargosDescuentos:oWSCargosDescuentos, oWSDescDet)
	EndIf
	oWSDet:ccodigoProducto := &(cObjXML + ":" + aOpcDoc[4] + ":_CAC_SELLERSITEMIDENTIFICATION:_CBC_ID:TEXT")
	oWSDet:ccodigoTipoPrecio := "01" //NUEVO CODIGO TIPOPRECIO
	oWSDet:cdescripcion := &(cObjXML + ":" + aOpcDoc[4] + ":_CBC_DESCRIPTION:TEXT")
	IF lDocSp .Or. lNotAjus
		oWSDet:cdescripcion2 := &("oXml:" + aOpcDoc[1] + ":_CBC_ISSUEDATE:TEXT") // fecha de Compra
		oWSDet:cdescripcion3 := "1" // 1 = Por operacion, 2 = Acumulado 
		oWSDet:cdescripcionTecnica := &(cObjXML + ":" + aOpcDoc[4] + ":_CBC_DESCRIPTION:TEXT")
	EndIF
	oWSDet:cestandarCodigo := "999"
	
	oWSDet:cestandarCodigoProducto := &(cObjXML + ":" + aOpcDoc[4] + ":_CAC_SELLERSITEMIDENTIFICATION:_CBC_ID:TEXT")
	
	oWSDet:cmuestraGratis := IIf(lMuestra,"1","0") //SI ES MUESTRA GRATIS
	oWSDet:cprecioReferencia := Alltrim(&(cObjXML + ":" + aOpcDoc[5] + ":_CBC_PRICEAMOUNT:TEXT")) // PRECIO DEL VALOR DEL ARTICULO
	If XmlChildEx(&(cObjXML), "_CAC_PRICINGREFERENCE") <> Nil .And. !lMuestra
		oWSDet:cprecioTotal	:= Alltrim(&(cObjXML + ":_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[2]:_CBC_PRICEAMOUNT:TEXT"))
		oWSDet:cprecioTotalSinImpuestos	:= Alltrim(&(cObjXML + ":_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[1]:_CBC_PRICEAMOUNT:TEXT"))
	ElseIf lMuestra
		nPrec	:= Val(&(cObjXML + ":_CAC_PRICINGREFERENCE:_CAC_ALTERNATIVECONDITIONPRICE[1]:_CBC_PRICEAMOUNT:TEXT"))
		oWSDet:cprecioTotal	:= "0.00"
		oWSDet:cprecioTotalSinImpuestos	:= "0.00"
	EndIf			
	oWSDet:cprecioVentaUnitario := Alltrim(&(cObjXML + ":" + aOpcDoc[5] + ":_CBC_PRICEAMOUNT:TEXT"))
	oWSDet:csecuencia := &(cObjXML + ":_CBC_ID:TEXT")
	oWSDet:cunidadMedida := &(cObjXML + ":" + aOpcDoc[3] + ":_UNITCODE:TEXT")
	
	oWSDet:oWSimpuestosDetalles := Service_ArrayOfFacturaImpuestos():NEW()
	
	If lPEWS
		ExecBlock("M486OWSCOL",.F.,.F.,{aFact[nPosDoc,1],aFact[nPosDoc,2],aFact[nPosDoc,3],aFact[nPosDoc,4],&(cObjXML),2,@oWSDet})
	EndIf		
	//Impuestos detalle
	If XmlChildEx(&(cObjXML), "_CAC_TAXTOTAL") <> Nil
		oWS:oWSfactura:oWSimpuestosGenerales := Service_ArrayOfFacturaImpuestos():NEW()
		If ValType(&(cObjXML + ":_CAC_TAXTOTAL")) == "A" //Varios impuestos
			For nX := 1 To Len(&(cObjXML + ":_CAC_TAXTOTAL"))
				M486TXTDET(@oWSDet, cObjXML + ":_CAC_TAXTOTAL[" + Str(nX) + "]", @aImpGralD)
			Next nX
		Else //Un solo impuesto
			M486TXTDET(@oWSDet, cObjXML + ":_CAC_TAXTOTAL", @aImpGralD)
		EndIf 
	EndIf	
	
	//Impuestos totales (detalle)
	oWSDet:oWSimpuestosTotales := Service_ArrayOfImpuestosTotales():New()
	For nPos := 1 To Len(aImpGralD)
		oWSImpTot := Service_ImpuestosTotales():New()
		oWSImpTot:ccodigoTOTALImp := aImpGralD[nPos][1]
		oWSImpTot:cmontoTotal := Alltrim(Str(aImpGralD[nPos][2]))
		aAdd(oWSDet:oWSimpuestosTotales:oWSImpuestosTotales, oWSImpTot)
	EndFor	
	
	aAdd(oWSDetDoc:oWSFacturaDetalle, oWSDet)
	
	oWS:oWSfactura:oWSdetalleDeFactura := oWSDetDoc

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} M486TAXTOT
Función para leer el tag taxTotal
@type function
@author luis.enriquez
@since 01/08/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486TAXTOT(oWS, cObjXML, aImpGral, cInfoAd)
	Local nX := 0
	If ValType(&(cObjXML + ":_CAC_TAXSUBTOTAL")) == "A" //Varios impuestos
		For nX := 1 To Len(&(cObjXML + ":_CAC_TAXSUBTOTAL"))
			M486TAXSUB(oWS, cObjXML + ":_CAC_TAXSUBTOTAL["  + Str(nX) +  "]", @aImpGral, @cInfoAd)
		Next nX
	Else
		M486TAXSUB(oWS, cObjXML + ":_CAC_TAXSUBTOTAL", @aImpGral, @cInfoAd)
	EndIf
Return Nil

/*/{Protheus.doc} M486TAXSUB
Función para leer el tag taxTotal
@type function
@author luis.enriquez
@since 01/08/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486TAXSUB(oWS, cObjXML, aImpGral, cInfoAd)
	Local cCodImp := ""
	Local cValImp := ""
	
	cCodImp := Alltrim( &(cObjXML + ":_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT") )
	cValImp := &(cObjXML + ":_CBC_TAXAMOUNT:TEXT")
	If !EsAutoReten(cCodImp)
		nPos := AScan(aImpGral,{|x| Alltrim(x[1]) == Alltrim(cCodImp)})
		If nPos == 0
			aAdd(aImpGral,{cCodImp, Val(cValImp)})
		Else	
			aImpGral[nPos][2] += Val(cValImp)
		EndIf
		oWSImpDet := Service_FACTURAIMPUESTOS():New()
		oWSImpDet:ccodigoTOTALImp := Substr( cCodImp, 1, 2)
		If Len(cCodImp) > 2
			oWSImpDet:ccontrolInterno := Substr( cCodImp, 3)
		EndIf
		oWSImpDet:cbaseImponibleTOTALImp := &(cObjXML + ":_CBC_TAXABLEAMOUNT:TEXT")
		oWSImpDet:cporcentajeTOTALImp := &(cObjXML + ":_CBC_PERCENT:TEXT")
		oWSImpDet:cvalorTOTALImp := &(cObjXML + ":_CBC_TAXAMOUNT:TEXT")
		
		aAdd(oWS:oWSfactura:oWSimpuestosGenerales:oWSFacturaImpuestos,oWSImpDet)				
	Else
		cInfoAd += IIf(Empty(cInfoAd), "", "<br>") + "Cod: " + cCodImp + ;
				"<br>Descripción: " + ObtColSAT("S005",PadR(cCodImp,3),1,3,4,80) + ;
				"<br>Base Impuesto: " + &(cObjXML + ":_CBC_TAXABLEAMOUNT:TEXT") + ;
				"<br>Porcentaje: " + &(cObjXML + ":_CBC_PERCENT:TEXT") + ;
				"<br>Valor Impuesto: " + &(cObjXML + ":_CBC_TAXAMOUNT:TEXT")
	EndIf
Return Nil

/*/{Protheus.doc} M486TXTDET
Función para leer el tag taxTotal
@type function
@author luis.enriquez
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486TXTDET(oWSDet, cObjXML, aImpGralD)
	Local nX := 0
	If XmlChildEx(&(cObjXML),"_CAC_TAXSUBTOTAL") <> NIL
		If ValType(&(cObjXML + ":_CAC_TAXSUBTOTAL")) == "A" //Varios impuestos
			For nX := 1 To Len(&(cObjXML + ":_CAC_TAXSUBTOTAL"))
				M486TXSUBD(oWSDet, cObjXML + ":_CAC_TAXSUBTOTAL["  + Str(nX) +  "]", @aImpGralD)
			Next nX
		Else
			M486TXSUBD(oWSDet, cObjXML + ":_CAC_TAXSUBTOTAL", @aImpGralD)
		EndIf
	Endif
Return Nil

/*/{Protheus.doc} M486TAXSUB
Función para leer el tag taxTotal
@type function
@author luis.enriquez
@since 01/08/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function M486TXSUBD(oWSDet, cObjXML, aImpGralD)
	Local cCodImp := ""
	Local cValImp := ""
	
	cCodImp := Alltrim( &(cObjXML + ":_CAC_TAXCATEGORY:_CAC_TAXSCHEME:_CBC_ID:TEXT") )
	cValImp := &(cObjXML + ":_CBC_TAXAMOUNT:TEXT")
	If !EsAutoReten(cCodImp)
		nPos := AScan(aImpGralD,{|x| Alltrim(x[1]) == Alltrim(cCodImp)})
		If nPos == 0
			aAdd(aImpGralD,{cCodImp, Val(cValImp)})
		Else	
			aImpGralD[nPos][2] += Val(cValImp)
		EndIf
		oWSImpDet := Service_FACTURAIMPUESTOS():New()
		oWSImpDet:ccodigoTOTALImp := Substr( cCodImp, 1, 2)
		If Len(cCodImp) > 2
			oWSImpDet:ccontrolInterno := Substr( cCodImp, 3)
		EndIf
		oWSImpDet:cbaseImponibleTOTALImp := &(cObjXML + ":_CBC_TAXABLEAMOUNT:TEXT")
		oWSImpDet:cporcentajeTOTALImp := &(cObjXML + ":_CBC_PERCENT:TEXT")
		oWSImpDet:cvalorTOTALImp := &(cObjXML + ":_CBC_TAXAMOUNT:TEXT")
		
		aAdd(oWSDet:oWSimpuestosDetalles:oWSFacturaImpuestos, oWSImpDet)				
	Else
		cInfoAd += IIf(Empty(cInfoAd), "", "<br>") + "Cod: " + cCodImp + ;
				"<br>Descripción: " + ObtColSAT("S005",PadR(cCodImp,3),1,3,4,80) + ;
				"<br>Base Impuesto: " + &(cObjXML + ":_CBC_TAXABLEAMOUNT:TEXT") + ;
				"<br>Porcentaje: " + &(cObjXML + ":_CBC_PERCENT:TEXT") + ;
				"<br>Valor Impuesto: " + &(cObjXML + ":_CBC_TAXAMOUNT:TEXT")
	EndIf
Return Nil

/*/{Protheus.doc} M486REFDOC
Función para llenado de oWSdocumentosReferenciados solicitado por TheFactory HKA, con datos obtenidos del XML.
@type function
@author luis.enriquez
@since 24/07/2019
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function M486REFDOC(oWSDocRef, aOpcDoc, cRefXML, cNote, lNotAjus)
	Local cRefrns 	:= ""
	Default lNotAjus:= .F.
	If lNotAjus
		cRefrns := cRefXML + ":_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ISSUETYPE:TEXT"
	Else
		cRefrns := "oXml:" + aOpcDoc[1] + ":_CAC_DISCREPANCYRESPONSE:_CBC_RESPONSECODE:TEXT"
	EndIf 
	//Motivos (DiscrepancyResponse)
	oWSRefM := Service_DocumentoReferenciado():New()
	oWSRefM:ccodigoEstatusDocumento :=  &(cRefrns) 					
	oWSRefM:ccodigoInterno:= "4"
	oWSRefM:ccufeDocReferenciado:= &(cRefXML + ":_CAC_INVOICEDOCUMENTREFERENCE:_CBC_UUID:TEXT")
	
	If lNotAjus // Concepto de Nota de Ajuste Tabla 1D -SX5
		cNote := M486VALSX5('1D'+ &(cRefXML + ":_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ISSUETYPE:TEXT"))
		oWSRefM:ctipoDocumento:= "05" // Indica que es un Documento Soporte 
		oWSRefM:ctipoDocumentoCodigo := "05" // Indica que es un Documento Soporte 
	Endif

	oWSRefM:oWSdescripcion := Service_ArrayOfstring():New()
	aAdd(oWSRefM:oWSdescripcion:cstring, cNote)

	oWSRefM:cnumeroDocumento := &(cRefXML + ":_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ID:TEXT")
	aAdd(oWSDocRef:oWSDocumentoReferenciado, oWSRefM)

	//Documento afectado (BillingReference)
	oWSRef := Service_DocumentoReferenciado():New()					
	oWSRef:ccodigoInterno:= "5"
	oWSRef:ccufeDocReferenciado:= &(cRefXML + ":_CAC_INVOICEDOCUMENTREFERENCE:_CBC_UUID:TEXT")
	oWSRef:cfecha := &(cRefXML + ":_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ISSUEDATE:TEXT")
	oWSRef:cnumeroDocumento := &(cRefXML + ":_CAC_INVOICEDOCUMENTREFERENCE:_CBC_ID:TEXT")
	oWSRef:ctipoDocumentoCodigo := "01" 
	oWSRef:ctipoCUFE := IIf(lNotAjus,"CUDS","CUFE") + "-SHA384"
	If lNotAjus // Concepto de Nota de Ajuste Tabla 1D -SX5
		oWSRef:ctipoDocumento:= "05" // Indica que es un Documento Soporte 
		oWSRef:ctipoDocumentoCodigo := "05" // Indica que es un Documento Soporte
	EndIf
	aAdd(oWSDocRef:oWSDocumentoReferenciado, oWSRef)
Return Nil

/*/{Protheus.doc} M486REFADI
Función para llenado de oWSdocumentosReferenciados solicitado por TheFactory HKA, con referencias adicionales para Facturas.
@type function
@author luis.enriquez
@since 31/01/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function M486REFADI(oWSDocRef, aOpcDoc, cRefXML)
	oWSRef := Service_DocumentoReferenciado():New()
	oWSRef:ccodigoInterno := "1"
	IIf(XmlChildEx(&(cRefXML), "_CBC_ISSUEDATE") <> Nil, oWSRef:cfecha := &(cRefXML + ":_CBC_ISSUEDATE:TEXT"),"")
	IIf(XmlChildEx(&(cRefXML), "_CBC_ID") <> Nil, oWSRef:cnumeroDocumento := &(cRefXML + ":_CBC_ID:TEXT"),"")
	IIf(XmlChildEx(&(cRefXML), "_CBC_DOCUMENTTYPECODE") <> Nil, oWSRef:ctipoDocumentoCodigo := &(cRefXML + ":_CBC_DOCUMENTTYPECODE:TEXT"),"")	
	aAdd(oWSDocRef:oWSDocumentoReferenciado, oWSRef)
Return Nil

/*/{Protheus.doc} M486ORDCOM
Función para llenado de oWSOrdenDeCompra solicitado por TheFactory HKA, con referencias adicionales para Facturas.
@type function
@author luis.enriquez
@since 31/01/2020
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function M486ORDCOM(oWSOC, cNodoXML)
	oWSOrdC := Service_OrdenDeCompra():New()
	IIf(XmlChildEx(&("oXml:" + aOpcDoc[1] + cNodoXML), "_CBC_CUSTOMERREFERENCE") <> Nil,oWSOrdC:ccodigoCliente := &("oXml:" + aOpcDoc[1] + cNodoXML + ":_CBC_CUSTOMERREFERENCE:TEXT"),"")
	IIf(XmlChildEx(&("oXml:" + aOpcDoc[1] + cNodoXML), "_CBC_ISSUEDATE") <> Nil,oWSOrdC:cfecha := &("oXml:" + aOpcDoc[1] + cNodoXML + ":_CBC_ISSUEDATE:TEXT"),"")
	IIf(XmlChildEx(&("oXml:" + aOpcDoc[1] + cNodoXML), "_CBC_ID") <> Nil,oWSOrdC:cnumeroOrden := &("oXml:" + aOpcDoc[1] + cNodoXML + ":_CBC_ID:TEXT"),"")
	IIf(XmlChildEx(&("oXml:" + aOpcDoc[1] + cNodoXML), "_CBC_SALESORDER") <> Nil,oWSOrdC:cnumeroPedido := &("oXml:" + aOpcDoc[1] + cNodoXML + ":_CBC_SALESORDER:TEXT"),"")
	IIf(XmlChildEx(&("oXml:" + aOpcDoc[1] + cNodoXML), "_CBC_ORDERTYPECODE") <> Nil,oWSOrdC:ctipoOrden := &("oXml:" + aOpcDoc[1] + cNodoXML + ":_CBC_ORDERTYPECODE:TEXT"),"")				
	IIf(XmlChildEx(&("oXml:" + aOpcDoc[1] + cNodoXML), "_CBC_UUID") <> Nil,oWSOrdC:cuuid := &("oXml:" + aOpcDoc[1] + cNodoXML + ":_CBC_UUID:TEXT"),"")
	If XmlChildEx(&("oXml:" + aOpcDoc[1] + cNodoXML), "_CBC_UUID") <> Nil
		IIf(XmlChildEx(&("oXml:" + aOpcDoc[1] + cNodoXML + ":_CBC_UUID"), "_SCHEMENAME") <> Nil,oWSOrdC:ctipoCUFE := &("oXml:" + aOpcDoc[1] + cNodoXML + ":_CBC_UUID:_SCHEMENAME:TEXT"),"")
	EndIf
	aAdd(oWSOC:oWSordenDeCompra, oWSOrdC)
Return Nil

/*/{Protheus.doc} M486RESOBL
Obtiene las responsabilidades tributarias y tributos del cliente.
@type function
@author luis.enriquez
@since 08/08/2019
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Function M486RESOBL(cCliente, cLoja, cTipo, lDocSp, lNotAjus, lCpoReg)
	Local cResp   := ""
	Local cFilAIT := xFilial("AIT")
	Local cAliasImp := getNextAlias()
	Local cCampos  := ""
	Local cTabla   := ""
		
	Default cCliente := ""
	Default cLoja    := ""
	Default cTipo    := "R"
	Default lDocSp   := .F.
	Default lNotAjus := .F.
	Default lCpoReg  := AIT->(ColumnPos("AIT_REG")) > 0
	
	cCampos	:= "% AIT_FILIAL, AIT_CODCLI, AIT_LOJA, AIT_CODRES, AIT_CODTRI, AIT_TIPO " + IIf(lCpoReg,",AIT_REG","") + " %"
	cTabla	:= "% " + RetSqlName("AIT") + " AIT %"
	cCond	:= "% AIT_CODCLI = '" + cCliente + "' "
	cCond	+= " AND AIT_LOJA = '" + cLoja + "' "
	cCond	+= " AND AIT_TIPO = '" + cTipo + "' "
	If lCpoReg
		cCond	+= "AND " + IIf(lDocSp .Or. lNotAjus,"AIT_REG = 'P' "," AIT_REG <> 'P'")
	EndIf
	cCond	+= " AND AIT_FILIAL = '" + cFilAIT + "'"
	cCond	+= " AND AIT.D_E_L_E_T_  = ' ' %"

	BeginSql alias cAliasImp
		SELECT %exp:cCampos%
		FROM  %exp:cTabla%
		WHERE %exp:cCond%
	EndSql

	dbSelectArea(cAliasImp)
	(cAliasImp)->(DbGoTop())
	While (cAliasImp )->(!Eof())
			If cTipo == "R" .And. Alltrim((cAliasImp)->AIT_CODRES) == "NAO"
				cResp += "R-99-PN"
			Else
				If cTipo == "R" .And. !Empty((cAliasImp)->AIT_CODRES)
					cResp += (cAliasImp)->AIT_CODRES + ";"
				ElseIf cTipo == "T" .And. !Empty((cAliasImp)->AIT_CODTRI)
					cResp += (cAliasImp)->AIT_CODTRI + ";"
				EndIF
			EndIf
		(cAliasImp)->(dbskip())
	EndDo
	(cAliasImp)->(DBCloseArea())
Return cResp

/*/{Protheus.doc} M486EDODOC
  Obtiene estado de los documentos electrónicos (COLOMBIA)
  @type
  @author luis.enriquez
  @since 07/10/2019
  @version 1.0
  @param aDocs, array, Documentos a Consultar
  @param cIdEnt, character, Entidad de TSS
  @param cURL, character, url de conecxion
  @return aRet, Array con la informaicón que será mostrada en el monitor
  @example
  (examples)
  @see (links_or_references)
  /*/
Function M486EDODOC(aDocs, cUrl, cTKNEmp, cTKNPas, cEspecie)
	Local oWSEdoDoc := Nil
	Local cDoc := ""
	Local nI := 0
	Local cAmb := GetNewPar("MV_CFDIAMB","2") //Ambiente 1=Producción 2=Pruebas
	Local aResp := {}
	Local nEstado := 0
	Local cCUFE := ""
	Local cMsjRep := ""
	Local cMsjErr := ""
	Local nCodigo := 0
	Local aRegVal := {}
	Local nY := 0
	Local cRespXML := ""
	Local cFactHex := ""
	Local cPref := IIf(Alltrim(cEspecie) == "NF" , "f" , IIF(Alltrim(cEspecie) == "NCC" , "c" , IIF(Alltrim(cEspecie) == "NDC", "d" , "f" ) ) )
	Local cMsg	:= ""

	CURSORWAIT()

	If SuperGetMV("MV_PROVFE",,"") == "DFACTURA"		

		For nI:= 1 to len(aDocs)				
			cDoc := Alltrim(aDocs[nI,6]) + Alltrim(Str(Val(aDocs[nI,3]))) //Serie2 + Documento
			cCUFE := ""
			oWSEdoDoc := WSNFECol():NEW()
			oWSEdoDoc:_URL := cUrl
			oWSEdoDoc:ctokenEmpresa  := SuperGetMV("MV_TKN_EMP",,"") // Token empresa
			oWSEdoDoc:ctokenPassword := SuperGetMV("MV_TKN_PAS",,"") // Token password
			oWSEdoDoc:cdocumento := cDoc
			
			cFactHex := M486XHEX(ALLTRIM( substr( aDocs[nI,3] , 4 , Len(aDocs[nI,3]) - 3 ) ),10)
		    cDocXML  := Lower('face') + '_' + cPref + PADR( Alltrim(SM0->M0_CGC) , 10 , "0" ) + cFactHex
			
			If !(Alltrim(aDocs[nI,7]) == "6") //Solo consume WS para documentos que no están autorizados
				If oWSEdoDoc:EstadoDocumento()
					If oWSEdoDoc:oWSEstadoDocumentoResult:lesValidoDian .And. (!Empty(oWSEdoDoc:oWSEstadoDocumentoResult:ctrackID) .Or. !Empty(oWSEdoDoc:oWSEstadoDocumentoResult:ccufe) ) //Autorizado
						If oWSEdoDoc:oWSEstadoDocumentoResult:ncodigo == 200
							nEstado := 6 //Autorizado DIAN
							cCUFE   :=	Alltrim(oWSEdoDoc:oWSEstadoDocumentoResult:ccufe)
							cMsg	:= Alltrim(oWSEdoDoc:oWSEstadoDocumentoResult:cdescripcionEstatusDocumento)
							If oWSEdoDoc:DescargaXML()
								cRespXML := Decode64(oWSEdoDoc:oWSDescargaXMLResult:cdocumento)
								If !Empty(cRespXML)						
									fWriteXml(cRespXML, cDocXML + ".xml",.T.)
								EndIf								
							EndIf
						EndIf
					ElseIf oWSEdoDoc:oWSEstadoDocumentoResult:lesValidoDian .And. Empty(oWSEdoDoc:oWSEstadoDocumentoResult:ctrackID) //En proceso
						nEstado := 5 //Error en comunicación The Factory - DIAN
						cCUFE := ""
						cMsjRep := STR0010 //"Ocurrio un error de actualización del estatus en la plataforma del Proveedor Tecnológico."
					Else //Rechazado
						If !(oWSEdoDoc:oWSEstadoDocumentoResult:ncodigo == 201) 
							nEstado := 5 
							nCodigo := oWSEdoDoc:oWSEstadoDocumentoResult:ncodigo
							cMsjRep := oWSEdoDoc:oWSEstadoDocumentoResult:cmensaje
							For nY := 1 to Len(oWSEdoDoc:oWSEstadoDocumentoResult:oWSreglasValidacionDIAN:cstring)
								aAdd(aRegVal, {oWSEdoDoc:oWSEstadoDocumentoResult:oWSreglasValidacionDIAN:cstring[nY]})
							Next nY	
							M486XMLOUT(nCodigo, cMsjRep, aRegVal, aDocs[nI,2], aDocs[nI,3], aDocs[nI,6], cPref)						
						EndIf
					EndIf
					
					If nEstado <> 5
						cMsjRep := cMsg
					EndIf
				Else
					cMsjRep := GetWSCError()							
				EndIf
			Else
				nEstado := Val(aDocs[nI,7])
				cMsjRep := STR0001 //"Procesado Correctamente"
				cCUFE := IIf(Alltrim(aDocs[nI,7]) == "6", Alltrim(aDocs[nI,8]) ,"")
			EndIf
			
			aAdd(aResp, {nEstado,;
			Alltrim(aDocs[nI,2]) + "-" + aDocs[nI,3],;
			IIf(Alltrim(cAmb) == "1", STR0002, STR0003),; //"Producción" //"Pruebas"
			cMsjRep,;
			cCUFE,;
			aDocs[nI,2],; //Serie
			aDocs[nI,3]}) //Documento
			oWSEdoDoc := Nil			
		Next nI
	EndIf					
	
	CURSORARROW()
Return aResp

/*/{Protheus.doc} M486XMLOUT
  Genera .out con observaciones de rechazo (COLOMBIA)
  @type
  @author luis.enriquez
  @since 08/10/2019
  @version 1.0
  @param nCodigo, Numeric, código del error
  @param cMsjErr, Character, Descripción del mensaje de error
  @param aRegVal, Array, Arreglo de reglas DIAN
  @return cDoc, Character, Descripción del mensaje de error
  @return cEspecie, Array con la informaicón que será mostrada en el monitor  
  @example
  (examples)
  @see (links_or_references)
  /*/
Function M486XMLOUT(nCodigo, cMsjErr, aRegVal, cSerie, cDoc, cSerie2, cPref)
	Local cPath	    := getMV("MV_CFDDOCS") 
	Local cPathFile := ""
	Local nHdl
  	Local nI := 0
  	Local cNomDoc := ""
  	Local cCRLF	 := (chr(13)+chr(10))
  	Local lReg := Len(aRegVal) > 0
  	
  	cDocHex := M486XHEX(ALLTRIM( substr( cDoc , 4 , Len(cDoc) - 3 ) ),10)

	cNomDoc := Lower('face') + '_' + cPref + PADR( Alltrim(SM0->M0_CGC) , 10 , "0" ) + cDocHex + ".xml.out"
	
	cPathFile := &(cPath) + cNomDoc
	
	cTexto := "<Response>" + cCRLF
	cTexto += "	<Serie>" + Alltrim(cSerie) + "</Serie>" + cCRLF
	cTexto += "	<Documento>" + Alltrim(cDoc) + "</Documento>" + cCRLF
	cTexto += "	<Serie2>" + Alltrim(cSerie2) + "</Serie2>" + cCRLF
	cTexto += "	<HasError>True</HasError>" + cCRLF
	cTexto += "	<Status>" + Alltrim(Str(nCodigo)) + "</Status>" + cCRLF	
	cTexto += "	<Error>" + Alltrim(cMsjErr) + "</Error>" + cCRLF
		
	If lReg
		cTexto += "	<Message>" + cCRLF
	EndIf
	
	For nI := 1 To Len(aRegVal)
		cTexto += "		<Description>" + aRegVal[nI] + "</Description>" + cCRLF
	Next nI
	
	If lReg
		cTexto += "	</Message>" + cCRLF
	EndIf
		
	cTexto += "</Response>"
	
	cTexto := EncodeUTF8(cTexto)
	
	Ferase(cPathFile)
	nHdl	:=	fCreate(cPathFile)
	fWrite(nHdl,cTexto)
	fClose(nHdl)
Return

/*/{Protheus.doc} M486DRCOL
  Genera nodos AdditionalDocumentReference y OrderReference (COLOMBIA)
  @type
  @author luis.enriquez
  @since 04/02/2020
  @version 1.0
  @param cUUIDRel, Character, referencias adicionales
  @param nOpc, Numeric, 1-Documentos relacionados 2-Ordenes de Compra
  @return cXML, Character, No para xml de refencias adicionales y ordenes de compras 
  @example
  (examples)
  @see (links_or_references)
  /*/
Function M486DRCOL(cUUIDRel, nOpc)
	Local aUUIDRel  := {}
	Local aDocRel   := {}
	Local cXML      := ""
	Local cCRLF     := (chr(13)+chr(10))
	Local nI := 0
	
	Default nOpc := 1
	
	If !Empty(cUUIDRel)
		//Documentos relacionados
		aUUIDRel := StrTokArr(cUUIDRel, cCRLF) 
		 
		For nI := 1 To Len(aUUIDRel)
			aAdd(aDocRel, StrTokArr(aUUIDRel[nI], "/"))
		Next nI	
		
		If nOpc == 1 //Referencias adicionales
			For nI := 1 To Len(aDocRel)
				If !(Alltrim(aDocRel[nI][1]) == "ORDC")
					cXML += "	<cac:AdditionalDocumentReference>" + cCRLF
					If Len(aDocRel[nI]) >= 1
						cXML += "		<cbc:ID>" + Alltrim(aDocRel[nI][2]) + "</cbc:ID>" + cCRLF
					EndIf
					If Len(aDocRel[nI]) >= 2
						cXML += "		<cbc:DocumentTypeCode>" + Alltrim(aDocRel[nI][1]) + "</cbc:DocumentTypeCode>" + cCRLF
					EndIf
					If Len(aDocRel[nI]) >= 3
						cXML += "		<cbc:IssueDate>" + Alltrim(aDocRel[nI][3]) + "</cbc:IssueDate>" + cCRLF
					EndIf
				 	cXML += "	</cac:AdditionalDocumentReference>" + cCRLF
			 	EndIf
		 	Next nI
	 	ElseIf nOpc == 2 //Ordenes de Compra
			For nI := 1 To Len(aDocRel)
				If (Alltrim(aDocRel[nI][1]) == "ORDC")
					cXML += "	<cac:OrderReference>" + cCRLF
					If Len(aDocRel[nI]) >= 2
						cXML += "		<cbc:ID>" + Alltrim(aDocRel[nI][2]) + "</cbc:ID>" + cCRLF
					EndIf
					If Len(aDocRel[nI]) >= 3
						cXML += "		<cbc:IssueDate>" + Alltrim(aDocRel[nI][3]) + " 00:00:00</cbc:IssueDate>" + cCRLF
					EndIf
					If Len(aDocRel[nI]) >= 4
						cXML += "		<cbc:OrderTypeCode>" + Alltrim(aDocRel[nI][4]) + "</cbc:OrderTypeCode>" + cCRLF
					EndIf				
				 	cXML += "	</cac:OrderReference>" + cCRLF
			 	EndIf
		 	Next nI		
	 	EndIf
 	EndIf
Return cXML

/*/{Protheus.doc} M486ColVen
	Obtiene la fecha de vencimiento de las cuotas del documento
	@type  Function
	@author Verónica Flores
	@since 25/11/2022
	@version version
	@param cAlias, caracter, Alias de la tabla que se va utilizar para la busqueda
	@param cCliente, caracter, Cliente del documento
	@param cLoja, caracter, Tienda del documento
	@param cSerie, caracter, Serie del documento
	@param cDoc, caracter, Numero del documento
	@param cEspecie, caracter, Especie del documento
	@param aFVence, array, Fechas de Vencimiento del documento.
	@return NIL, NIL, NIL
	@see (links_or_references)
/*/

Function M486COLVEN(cAlias,cCliente,cLoja,cSerie,cDoc,cEspecie,aFVence)

	Local cFecPar   := ""
	Local cFilOri   := ""
	Local cTabla	:= ""
	Local cFilSE    := ""

	Default cAlias	:= ""
	Default cCliente:= ""
	Default cLoja	:= ""
	Default cSerie	:= ""
	Default cDoc	:= ""
	Default cEspecie:= ""
	Default aFVence	:= {}

	cFilOri := xFilial(cAlias)
	cTabla  := IIF(AllTrim(cEspecie) $ "NF|NDC|NCC" .AND. !lDocSp,"SE1","SE2") 
	dbSelectArea(cTabla)
	(cTabla)->(dbGoTop())	
	IIf(cTabla=="SE1",dbSetOrder(2),dbSetOrder(6)) 
	cFilSE := xFilial(cAlias)
	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO ## 
	//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO  
	IF (cTabla)->(dbSeek(cFilSE+cCliente+cLoja+cSerie+cDoc))
		While (cTabla)->(!Eof()) .And. ;
		 	(cTabla)->&(Replace(cTabla,"S","")+"_FILIAL") + ;
			(cTabla)->&(Replace(cTabla,"S","")+ IIf(cTabla=="SE1","_CLIENTE","_FORNECE") ) + ;
			(cTabla)->&(Replace(cTabla,"S","")+"_LOJA") + ;
			(cTabla)->&(Replace(cTabla,"S","")+"_PREFIXO") + ;
			(cTabla)->&(Replace(cTabla,"S","")+"_NUM")  == cFilSE+cCliente+cLoja+cSerie+cDoc
			cFecPar:=(cTabla)->&(Replace(cTabla,"S","")+"_VENCTO")
			aAdd(aFVence, {Alltrim(Str(YEAR(cFecPar))) + "-" + Padl(Alltrim(Str(MONTH(cFecPar))),2,"0") + "-" + Padl(Alltrim(Str(DAY(cFecPar))),2,"0")})
			(cTabla)->(DbSkip())
		EndDo
	EndIf
Return

/*/{Protheus.doc} M486MedPago
	Asigna los medios de pago en el objeto oWSMedPago
	@type  Function
	@author Verónica Flores
	@since 25/11/2022
	@version version
	@param cMedioPago, caracter, Medio de pago del documento
	@param cMetPago, caracter, Metodo de pago del documento
	@param cFVence, caracter, Fecha de vencimiento del documento
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function M486MedPago(cMedioPago,cMetPago,cFVence,oWSMedPago)

	Default cMedioPago := ""
	Default cMetPago   := ""
	Default cFVence	   := ""
	Default oWSMedPago := Nil

	oWSMedPago := Service_MediosDePago():New()
	oWSMedPago:cmedioPago := AllTrim(cMedioPago)
	oWSMedPago:cmetodoDePago := cMetPago
	IIf(!Empty(cFVence),oWSMedPago:cfechaDeVencimiento := cFVence,.F.)

Return Nil

/*/{Protheus.doc} nomeFunction
	Busca los impuestos del documento a transmitir.
	@type  Function
	@author eduardo.manriquez
	@since 26/10/2023
	@version 1.0
	@param cDoc, caracter, Número de Documento
	@param cSerie, caracter, Serie Documento
	@param cCliente, caracter, Código de cliente
	@param cLoja, caracter, Tienda
	@param cEsp, caracter, Especie de documento

	@return aImp, array, Arreglo con los impuesto del documento: 
		1. Código Impuesto DIAN
		2. Código Impuesto
		3. Clase Impuesto
		4. Libro Fiscal
		5. Base Impuesto.
		6. Valor Impuesto.
	@example
	M486GETTAX(cDoc, cSerie,cCliente, cLoja,cEsp)
	@see (links_or_references)
	/*/
Function M486GETTAX(cDoc, cSerie,cCliente, cLoja,cEsp)
	Local aArea  	:= GetArea()
	Local aImp   	:= {}
	Local cTmp   	:= getNextAlias()
	Local nX        :=1
	Local cAliasSF	:= IIf(Alltrim(cEsp) $ 'NF|NDC',"SF2","SF1")
	Local cBasImpSF	:= IIf(Alltrim(cEsp) $ 'NF|NDC',"F2_BASIMP","F1_BASIMP")
	Local cValImpSF	:= IIf(Alltrim(cEsp) $ 'NF|NDC',"F2_VALIMP","F1_VALIMP")

	cEsp := ALLTRIM(cEsp)

	If cEsp $ "NF/NDC/NCP"
		BeginSql alias cTmp
			SELECT DISTINCT FB_CODIGO,FB_IMPSAT,FB_CLASSE,FB_CPOLVRO,FC_TES
			FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON FB_CODIGO=FC_IMPOSTO
			WHERE FB_FILIAL = %exp:xfilial("SFB")%
			AND FC_FILIAL = %exp:xfilial("SFC")%
			AND SFC.%notDel%
			AND SFB.%notDel%
			AND SFC.FC_TES IN (
				SELECT SD2.D2_TES FROM %table:SD2% SD2
				WHERE SD2.D2_FILIAL = %exp:xfilial("SD2")%
					AND SD2.D2_DOC =  %exp:cDoc%
					AND SD2.D2_SERIE =  %exp:cSerie%
					AND SD2.D2_CLIENTE = %exp:cCliente%
					AND SD2.D2_LOJA = %exp:cLoja%
					AND SD2.%notDel%
				GROUP BY SD2.D2_TES
			)
		EndSql
	ElseIf cEsp $ "NCC|NDP"
		BeginSql alias cTmp
			SELECT DISTINCT FB_CODIGO,FB_IMPSAT, FB_CLASSE,FB_CPOLVRO,FC_TES
			FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON FB_CODIGO=FC_IMPOSTO
			WHERE FB_FILIAL = %exp:xfilial("SFB")%
			AND FC_FILIAL = %exp:xfilial("SFC")%
			AND SFC.%notDel%
			AND SFB.%notDel%
			AND SFC.FC_TES IN (
				SELECT SD1.D1_TES FROM %table:SD1% SD1
				WHERE SD1.D1_FILIAL = %exp:xfilial("SD1")%
					AND SD1.D1_DOC =  %exp:cDoc%
					AND SD1.D1_SERIE =  %exp:cSerie%
					AND SD1.D1_FORNECE = %exp:cCliente%
					AND SD1.D1_LOJA = %exp:cLoja%
					AND SD1.%notDel%
				GROUP BY SD1.D1_TES
			)
		EndSql
	EndIf

	dbSelectArea(cTmp)
	(cTmp)->(DbGoTop())
	While (!(cTmp)->(EOF()))
		/*
		Estructura de aImp
		1. Código Impuesto DIAN
		2. Código Impuesto
		3. Clase Impuesto
		4. Libro Fiscal
		5. Base Impuesto.
		6. Valor Impuesto.
		*/
		AADD( aImp , { (cTmp)->FB_IMPSAT,(cTmp)->FB_CODIGO,(cTmp)->FB_CLASSE,FB_CPOLVRO,0.00,0.00,IIf(cEsp $ "NF|NCC",(cTmp)->FC_TES,"")})
		(cTmp)->(dbskip())
	EndDo
	For nX := 1 To Len(aImp)
		If aImp[nX,3] == "I"
			aImp[nX,5]:= (cAliasSF)->&(cBasImpSF + aImp[nX,4])
			aImp[nX,6] := (cAliasSF)->&(cValImpSF + aImp[nX,4])
		Endif
	NEXT nX

	RestArea(aArea)
Return aImp

/*/{Protheus.doc} M486GETIMP
	Asigna los medios de pago en el objeto oWSMedPago
	@type  Function
	@author Luis Enríquez
	@since 23/01/2024
	@version version
	@param cDoc, caracter, Número de Documento
	@param cSerie, caracter, Serie del Documento
	@param cCliente, caracter, Código del Cliente
	@param cLoja, caracter, Código de la Tienda
	@param nIVA, numeric, Total IVA
	@param nINC, numeric, Total INC
	@param nTotBol, numeric, Total Impuesto a la Bolsa
	@param nOtroImp, numeric, Total de Otros Impuestos
	@param nRetIVA, numeric, Total Retención de IVA
	@param nRetFte, numeric, Total Retención de Fuente
	@param nRetICA, numeric, Total Retención de ICA
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Function M486GETIMP(cDoc, cSerie, cCliente, cLoja, nIVA, nINC, nTotBol, nOtroImp, nRetIVA, nRetFte, nRetICA)
	Local aArea  	:= GetArea()
	Local aImp   	:= {}
	Local cTmp   	:= getNextAlias()
	Local nX		:= 0
	Local nPos		:= 0
	Local nBaseImp	:= 0
	Local nValImp	:= 0
	Local cAliasSF 	:= IIf(AllTrim(cEspecie)=="NCC", "SF1","SF2")
	Local cTabDet 	:= IIf(AllTrim(cEspecie)=="NCC", "SD1","SD2")
	Local nDetOrd	:= IIf(AllTrim(cEspecie)=="NCC",1,3)
	Local cPref		:= IIf(AllTrim(cEspecie)=="NCC", "D1_","D2_") 
	Local cCpoCP    := IIf(AllTrim(cEspecie)=="NCC", "FORNECE","CLIENTE") 
	Local aImpAux	:= {}
	Local cItem     := ""

	Default cDoc     := ""
	Default cSerie   := ""
	Default cCliente := ""
	Default cLoja    := ""
	Default nIVA     := 0
	Default nINC     := 0
	Default nTotBol  := 0
	Default nOtroImp := 0
	Default nRetIVA  := 0
	Default nRetFte  := 0
	Default nRetICA  := 0

	If AllTrim(cEspecie) $ "NF/NDC"
		BeginSql alias cTmp
			SELECT FB_CODIGO,FB_ALIQ,FB_IMPSAT,FB_CPOLVRO,FB_CLASSE,FC_TES,FC_INCDUPL
			FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON FB_CODIGO=FC_IMPOSTO
			WHERE FB_FILIAL = %exp:xfilial("SFB")%
			AND FC_FILIAL = %exp:xfilial("SFC")%
			AND SFC.%notDel%
			AND SFB.%notDel%
			AND SFC.FC_TES IN (
				SELECT SD2.D2_TES FROM %table:SD2% SD2
				WHERE SD2.D2_FILIAL = %exp:xfilial("SD2")%
					AND SD2.D2_DOC =  %exp:cDoc%
					AND SD2.D2_SERIE =  %exp:cSerie%
					AND SD2.D2_CLIENTE = %exp:cCliente%
					AND SD2.D2_LOJA = %exp:cLoja%
					AND SD2.%notDel%
				GROUP BY SD2.D2_TES
			)
		EndSql
	ElseIf AllTrim(cEspecie) $ "NCC"
		BeginSql alias cTmp
			SELECT FB_CODIGO,FB_ALIQ,FB_IMPSAT,FB_CPOLVRO,FB_CLASSE,FC_TES,FC_INCDUPL
			FROM %table:SFB% SFB INNER JOIN %table:SFC% SFC ON FB_CODIGO=FC_IMPOSTO
			WHERE FB_FILIAL = %exp:xfilial("SFB")%
			AND FC_FILIAL = %exp:xfilial("SFC")%
			AND SFC.%notDel%
			AND SFB.%notDel%
			AND SFC.FC_TES IN (
				SELECT SD1.D1_TES FROM %table:SD1% SD1
				WHERE SD1.D1_FILIAL = %exp:xfilial("SD1")%
					AND SD1.D1_DOC =  %exp:cDoc%
					AND SD1.D1_SERIE =  %exp:cSerie%
					AND SD1.D1_FORNECE = %exp:cCliente%
					AND SD1.D1_LOJA = %exp:cLoja%
					AND SD1.%notDel%
				GROUP BY SD1.D1_TES
			)
		EndSql
	EndIf

	dbSelectArea(cTmp)
	(cTmp)->(DbGoTop())
	While (!(cTmp)->(EOF()))
		/*
		Estructura de aImp
		1. Libro Fiscal
		2. Código Impuesto DIAN
		3. Clase de Impuest
		4. Alícuota
		5. Código Impuesto
		6. TES
		7. Base Impuesto
		8. Total Impuesto
		9. 1+, 2-, 3 (Indiferente [Auto-Retención 0A-ZZZ | Impuesto incluido en precio])
		*/
		AADD( aImp , { (cTmp)->FB_CPOLVRO, (cTmp)->FB_IMPSAT, (cTmp)->FB_CLASSE, (cTmp)->FB_ALIQ, (cTmp)->FB_CODIGO, (cTmp)->FC_TES, 0.00, 0.00, FC_INCDUPL })
		(cTmp)->(dbskip())
	EndDo

	(cTmp)->(dbCloseArea())

	dbSelectArea(cTabDet)
	//Para SF1: F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	//Para SF2: F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	&(cAliasSF)->(dbSetOrder(1)) 
	If &(cAliasSF)->(MSSeek(xFilial(cAliasSF)+ cDoc + cSerie + cCliente + cLoja))
		dbSelectArea(cTabDet)
		//Para SD1: D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		//Para SD2: D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		&(cTabDet)->(dbSetOrder(nDetOrd))

		If &(cTabDet)->(MsSeek(xFilial(cTabDet)+cDoc + cSerie + cCliente + cLoja),.t.)
			While (!&(cTabDet)->(EOF())).and. (cTabDet)->&(cPref+"FILIAL")+&(cPref+"DOC")+&(cPref+"SERIE")+&(cPref+cCpoCP)+&(cPref+"LOJA") == xFilial(cTabDet) + cDOC + cSerie + cCliente + cLoja
				For nX := 1 To Len(aImp)
					nBaseImp:= (cTabDet)->&(cPref+"BASIMP" + aImp[nX,1])
					nValImp :=  (cTabDet)->&(cPref+"VALIMP" + aImp[nX,1])
					cItem   :=  (cTabDet)->&(cPref+"ITEM")
					If  ((cTabDet)->&(cPref+"TES") == aImp[nX,6]) .and. (nBaseImp > 0 .or. nValImp > 0)
						aImp[nX,7] := nBaseImp
						aImp[nX,8] := nValImp

						aImp[nX,4] := (cTabDet)->&(cPref+"ALQIMP" + aImp[nX,1])

						//Acumulado de impuestos
						If aImp[nX,3] $ "I|R"
							If Len(aImpAux) > 0
								nPos := Ascan(aImpAux,{|x| x[1] == aImp[nX,2]} )
								If nPos == 0
									aAdd(aImpAux,{Alltrim(aImp[nX,2]), aImp[nX,8], aImp[nX,3]})
								Else
									aImpAux[nPos,2] += nValImp
								EndIf
							Else
								aAdd(aImpAux,{Alltrim(aImp[nX,2]), aImp[nX,8], aImp[nX,3]})
							EndIf
						EndIf
					EndIf
				Next nX
				(cTabDet)->(dbskip())
			EndDo
		EndIf
	EndIf

	//Impuestos
	ASort(aImpAux,,,{|x,y| x[2] < y[2]})
	If Len(aImpAux) > 0
		For nX := 1 To Len(aImpAux)
			If aImpAux[nX,3] == "I" // Impuesto
				If aImpAux[nX,1] == "01" //IVA
					nIVA += aImpAux[nX,2]
				ElseIf aImpAux[nX,1] == "04" //INC
					nINC += aImpAux[nX,2]
				ElseIf aImpAux[nX,1] == "22" //Bolsas
					nTotBol += aImpAux[nX,2]
				Else
					nOtroImp += aImpAux[nX,2]
				EndIf
			ElseIf aImpAux[nX,3] == "R" //Retención
				If aImpAux[nX,1] == "05" //Retención sobre el IVA
					nRetIVA += aImpAux[nX,2]
				ElseIf aImpAux[nX,1] == "06" //Retención sobre la Fuente
					nRetFte += aImpAux[nX,2]
				ElseIf aImpAux[nX,1] == "07" //Retención sobre el ICA
					nRetICA += aImpAux[nX,2]
				EndIf
			EndIf
		Next nX
	EndIf
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} M486DESGRA
	Obtiene los descuentos de IVA que asumira el emisor para items muestra
	@type  Function
	@author veronica.flores
	@since 08/11/2024
	@version 1.0
	@param cFilDoc, caracter, Sucursal de Documento
	@param cSerie, caracter, Serie Documento
	@param cDoc, caracter, Número de Documento
	@param cCliente, caracter, Código de cliente
	@param cLoja, caracter, Tienda
	@param aDesc, array, Descuentos de items de muestra
	@param cAlias, caracter, Alias de la tabla que se va utilizar para la busqueda
	@example
	M486DESGRA(cFilDoc, cSerie, cDoc, cCliente, cLoja,aDesc)
	/*/
Function M486DESGRA(cFilDoc, cSerie, cDoc, cCliente, cLoja,aDesc,cAlias)
	Local aArea		:= GetArea()
	LOCAL nTotal 	:= 0
	LOCAL aImp 		:= {}
	LOCAL cChave	:= ""
	Local nValImp 	:= 0
	local nPorDesc 	:= 0
	Local nVImpMues := 0
	local nBaseImp 	:= 0
	lOCAL nX		:= 0
	Local lRet 		:= .F.
	Local nDetOrd 	:= 1
	Local cCpo 		:= ""
	Local cPref		:= ""
	
	Default cFilDoc := ""
	Default cSerie  := ""
	Default cDoc    := ""
	Default cCliente:= ""
	Default cLoja   := ""
	Default aDesc 	:= {}
	Default cAlias	:= ""

	If cAlias == "SD2"
		nDetOrd := 3
		cPref	:= "D2_"
		cCpo 	:= "D2_CLIENTE"
	Else
		nDetOrd := 1
		cPref	:= "D1_"
		cCpo 	:= "D1_FORNECE"
	EndIf

	cChave := cFilDoc + cDoc + cSerie + cCliente + cLoja

	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(nDetOrd)) //D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
		IF ((cAlias)->(Msseek( cChave )) )
				aImp := M486GETTAX(cDoc, cSerie,cCliente, cLoja,cEspecie)
				While (cAlias)->(!Eof()) .And. cChave == (cAlias)->&(cPref+"FILIAL")+&(cPref+"DOC")+&(cPref+"SERIE")+&(cCpo)+&(cPref+"LOJA")
					For nX := 1 To Len(aImp)
						If Alltrim( aImp[nX,1] ) == "01" .And. ((cAlias)->&(cPref+"TES") == aImp[nX,7])
							If AllTrim((cAlias)->&(cPref+"NICO")) == "S"
								nVImpMues +=  (cAlias)->&(cPref+"VALIMP" + aImp[nX,4])
								lRet := .T.
							Else
								nBaseImp := (cAlias)->&(cPref+"BASIMP" + aImp[nX,4])
								nValImp  :=  (cAlias)->&(cPref+"VALIMP" + aImp[nX,4])
								nTotal	 += (nBaseImp + nValImp)
							EndIf	
						EndIf
					Next nX	
					(cAlias)->(dbskip())	
				Enddo
			If lRet
				If nTotal == 0
					nTotal := nVImpMues
					nPorDesc := 99.99
				Else
					nTotal += nVImpMues
					nPorDesc := (nVImpMues/nTotal)*100
				EndIf
				aDesc:= {nVImpMues,nTotal,nPorDesc}
			EndIf		
		EndIf
	RestArea(aArea)
Return Nil
