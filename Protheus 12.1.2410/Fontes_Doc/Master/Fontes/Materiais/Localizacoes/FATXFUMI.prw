#include 'protheus.ch'
#include 'FATXFUMI.ch'
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} FATXMIDsIt
Función para tratamineto de descuentos por ítem de Pedidos de Venta (Mercado Internacional)
@type
@author luis.enriquez
@since 04/03/2020
@version 1.0
@param nPrUnit, numeric, Precio Unitario del ítem
@param nPrcVen, numeric, Precio de Venta del ítem
@param nQtdVen, numeric, Cantidad del ítem
@param nTotal, numeric, Valor total del ítem
@param nPerc, numeric, Porcentaje de descuento del ítem
@param nDesc, numeric, Importe de descuento del ítem
@param nDescOri, numeric, Importe de descuento original del ítem
@param nTipo, numeric, Tipo de descuento del ítem (1-Porcentaje, 2-Valor descuento)
@param nQtdAnt, numeric, Cantidad anterior del ítem
@param nMoeda, numeric, Moneda del ítem
@return nPreco, numeric, Precio del ítem con descuento
@example
LXMexAcc(@aRotina)
@see (links_or_references)
/*/
Function FATXMIDsIt(nPrUnit,nPrcVen,nQtdVen,nTotal,nPerc,nDesc,nDescOri,nTipo,nQtdAnt,nMoeda)
	Local nPreco 		:= 0
	Local nValTot		:= 0
	
	Default nMoeda		:= Nil
	Default nTipo		:= 1
	Default nQtdAnt		:= nQtdVen

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo o Preco de Lista quando nao houver tabela de preco    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nPrUnit == 0
		nPrUnit += a410Arred((nTotal + nDescOri) / nQtdAnt,"D2_PRCVEN")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o novo preco de Venda                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTipo == 1
		nPreco := A410Arred(nPrUnit * (1-(nPerc/100)),"D2_PRCVEN")
		If nPerc > 0 .and. cPaisLoc $ "ARG|MEX"
			nTotal := nPreco * nQtdVen
		ELSE
			nTotal := A410Arred((nPrUnit * nQtdVen) * (1-(nPerc/100)),"D2_TOTAL")
		EndIf
	Else
		If nDesc > 0 .And. (IsInCallStack('CN120GrvPed') .Or. IsInCallStack('CN121GerDoc'))
			nPreco := (nTotal - nDesc) / nQtdVen
		Else
			nPreco := A410Arred(nPrUnit-(nDesc/nQtdVen),"D2_PRCVEN",nMoeda)
			If  cPAisLoc == "ARG" .And.  (nDesc > 0 .and.  nPreco > 0 .and.  nQtdVen > 0)
				nTotal := nPreco * nQtdVen
			ELSE
				nTotal := A410Arred((nPrUnit * nQtdVen) - nDesc,"D2_TOTAL")
			Endif
		EndIf
	EndIf

	nValTot:= A410Arred(nPrUnit * nQtdVen,"D2_TOTAL",nMoeda)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo dos descontos                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nPrUnit == 0
		nDesc := 0
		nPerc := 0
	Else
		nDesc := A410Arred(nValTot-nTotal,"D2_DESCON")
		If nTipo <> 1
			nPerc := A410Arred((1-(nPreco/nPrUnit))*100,"C6_DESCONT")
		EndIf
	EndIf
Return(nPreco)

/*/{Protheus.doc} FxMIVldItS
Valida que el item seleccionado pertenezca a un documento transmitido en la
rutina MATA465N para NCC - Colombia/Bolivia.
@author Marco Augusto Gonzalez Rivera
@since 25/04/2019
@version 1.0
@param cNumDoc, caracter, (Folio del documento)
@param cSerie,	caracter, (Serie del documento)
@return lRet, Verdadero si el documento se entra transmitido.
/*/
Function FxMIVldItS(cNumDoc, cSerie)
	Local lRet		:= .T.
	Local lM465PE  := .T.
	Local cFunName	:= FunName()
	Local aArea		:= {}
	Local lFactElec	:= !Empty(GetMV("MV_PROVFE", .F., "")) //Facturacion Electronica Activa
	Local cTpDoc := ""
	Local cVldD  := ""
	Local lValFE := .T.
	Local lCFDUso  := IIf(Alltrim(GetMv("MV_CFDUSO", .T., "1"))<>"0", .T.,.F.)

	Default cNumDoc	:= ""
	Default cSerie	:= ""

	If ExistBlock("M465DORIFE")
		lM465PE := ExecBlock("M465DORIFE",.F.,.F.,{xFilial("SF2"),cNumDoc,cSerie,M->F1_FORNECE,M->F1_LOJA})
	EndIf

	If lM465PE
		IF cPaisLoc=="COL"
			cTpDoc := AllTrim(ObtColSAT("S017",Alltrim(M->F1_TIPOPE),1,4,85,3))
			cVldD  := AllTrim(ObtColSAT("S017",Alltrim(M->F1_TIPOPE),1,4,88,1))
			lValFE := IIf((cTpDoc == "NCC" .And. cVldD $ "1|2") .Or. !(cTpDoc $ "NF|NDC|NCC") .Or. !(cVldD $ "0|1|2"),.T.,.F.)
			If cFunName $ "MATA465N" .And. lFactElec .And. lValFE
				aArea := GetArea()
				dbSelectArea("SF2")
				SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				//Regla de negocio
				If SF2->(MsSeek(xFilial("SF2") + cNumDoc + cSerie))
					If (Empty(SF2->F2_FLFTEX) .Or. SF2->F2_FLFTEX == "0") .Or. Empty(SF2->F2_UUID)
						MsgAlert(StrTran(STR0001, '###', AllTrim(SF2->F2_SERIE) + " " +  AllTrim(SF2->F2_DOC))) //"El documento seleccionado (###), no ha sido transmitido. Realice la transmisión e intente nuevamente."
						lRet := .F.
					EndIf
					If lRet .And. cVldD == "2" .And. Len(Alltrim(SF2->F2_UUID)) <> 40
						MsgAlert(StrTran(STR0002, '###', AllTrim(SF2->F2_SERIE) + " " +  AllTrim(SF2->F2_DOC))) //"El UUID del documento seleccionado (###), no pertenece a un documento emitido con el modelo de validación posterior."
						lRet := .F.
					EndIf
				EndIf
				RestArea(aArea)
			EndIf
			EndIf
		EndIf
Return lRet

/*/{Protheus.doc} LxActCpos
Función para habilitar los campos en el Pedido de Venta.
@type
@author veronica.flores
@since 15/04/2021
@version 1.0
@param aPedCpo, array , Array con los campos que se habilitaran.
@see (links_or_references)
/*/
Function LxActCpos(aPedCpo)

	Local aArea		:= GetArea()

	DbSelectArea("SC5")
	If SC5->(ColumnPos( "C5_CODMUN" ))  > 0
		AAdd(aPedCpo[1],"C5_CODMUN")
	EndIf
	If SC5->(ColumnPos( "C5_TPACTIV" )) > 0
		AAdd(aPedCpo[1],"C5_TPACTIV")
	EndIf
	IF SC5->(ColumnPos( "C5_TRMPAC" ))  > 0
		AAdd(aPedCpo[1],"C5_TRMPAC")
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} FatxVUni
Función que actualiza el valor del descuento apartir del valor unitario modificado
@type
@author veronica.flores
@since 31/05/2021
@version 1.0
@param
@see (links_or_references)
/*/
Function FatxVUni()
	Local nValCant	:= 0
	Local nValUni	:= 0
	Local cDescsai	:= SuperGetMV("MV_DESCSAI",.F.)
	Local nPosTotal := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_TOTAL"})
	Local nPosDesc  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_VALDESC"})
	Local nPosCant  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_QUANT"})
	Local nPosPDes  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_DESC"})
	Local cFunName	:= AllTrim(FunName())

	If cFunName $ "MATA465N" .And. acols[n][nPosDesc] > 0 .And. acols[n][nPosTotal] > 0 .And. cDescsai == "1"
		nValCant := aCols[n][nPosCant]
		nValUni	 := acols[n][nPosTotal] / nValCant
		If nValUni <> M->D1_VUNIT
			ACOLS[n][nPosTotal] := M->D1_VUNIT * nValCant
			ACOLS[n][nPosPDes]  := 0
			ACOLS[n][nPosDesc]  := 0
			MaFisAlt("IT_DESCONTO",ACOLS[n][nPosDesc],n)
			MaFisAlt("IT_PRCUNI",M->D1_VUNIT,n)
			MaFisAlt("IT_VALMERC", aCols[n][nPosTotal], n)
		EndIF

	EndIf
Return .T.

/*/{Protheus.doc} FxDesc
Función que calcula y actualiza el valor del descuento apartir del porcentaje modificado
@type
@author veronica.flores
@since 31/05/2021
@version 1.0
@param
@return  aCols[n][nPosDesc] - Valor del Descuento
@see (links_or_references)
/*/
Function FxDesc()
	Local nDescAc	:= 0
	Local cDescsai	:= SuperGetMV("MV_DESCSAI")
	Local nPosTotal := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_TOTAL"})
	Local nPosDesc  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_VALDESC"})
	Local nTotal 	:= 0
	Local cFunName	:= AllTrim(FunName())

	nTotal	:= acols[n][nPosTotal]
	nDescAc	:= acols[n][nPosDesc]

	If cFunName $ "MATA465N" .And. nDescAc > 0 .And. nTotal > 0 .And. cDescsai == "1"
		If nDescAc <> M->D1_DESC
			aCols[n][nPosDesc] := NoRound((nDescAc + nTotal)* (M->D1_DESC/100),TamSx3("D1_VALDESC")[2])
		EndIF
	Else
		aCols[n][nPosDesc] := NoRound(nTotal*M->D1_DESC/100,TamSx3("D1_VALDESC")[2])
	EndIf
Return aCols[n][nPosDesc]

/*/{Protheus.doc} FatPorDesc
Función que calcula y actualiza el porcentaje del descuento
@type
@author veronica.flores
@since 31/05/2021
@version 1.0
@param
@return  aCols[n][nPosPDes] - Porcentaje del Descuento
@see (links_or_references)
/*/
Function FatPorDesc()
	Local cDescsai	:= SuperGetMV("MV_DESCSAI",.F.)
	Local nPosTotal := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_TOTAL"})
	Local nPosDesc  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_VALDESC"})
	Local nPosPDes  := AScan(AHEADER,{|x|Alltrim(x[2])=="D1_DESC"})
	Local cFunName	:= AllTrim(FunName())
	Local nTotal 	:= 0
	Local nRet		:= 0
	Local nDescAux	:= 0

	If cFunName $ "MATA465N" .And. acols[n][nPosDesc] > 0  .And. cDescsai == "1"
		aCols[n][nPosPDes]  := Round((aCols[n][nPosDesc]*100)/(aCols[n][nPosTotal] + aCols[n][nPosDesc]),TamSx3("D1_DESC")[2])
	Else
		If (cFunName $ "COMA221|COMA222|COMA223|COMA224") .and. aCols[n][nPosPDes] > 0
			nTotal	:= acols[n][nPosTotal]
			nDescAux:= NoRound(nTotal*aCols[n][nPosPDes]/100,TamSx3("D1_VALDESC")[2])
			If aCols[n][nPosDesc] == nDescAux
				nRet := aCols[n][nPosPDes]
			EndIf
		EndIf
		aCols[n][nPosPDes]  := nRet
	EndIf
Return aCols[n][nPosPDes]

/*/{Protheus.doc} FxValStock
Función para validar stock al generar docto desde MATA410.

@type function
@author oscar.lopez
@since 28/06/2021
@version 1.0
@param cAlias, char, Alias de la tabla con la información del pedido de venta.
@param nReg, numeric, Numero de registro en la tabla cAlias del pedido de venta.
@return  lRet, logic, Regresa Falso si existen documentos que siperen saldo de stock.
/*/
Function FxValStock(cAlias,nReg)
	Local lRet		:= .T.
	Local aAreaSC5	:= {}
	Local aAreaSC6	:= {}
	Local aAreaSC9	:= {}
	Local aAreaSB2	:= {}
	Local aAreaSF4	:= {}
	Local cFilSC6	:= xFilial("SC6")
	Local cFilSC9	:= xFilial("SC9")
	Local cFilSB2	:= xFilial("SB2")
	Local cFilSF4	:= xFilial("SF4")
	Local lEstNeg	:= (SuperGetMV("MV_ESTNEG") == "S")
	Local cPedido	:= ""
	Local cProd		:= ""
	Local nCantidad	:= 0
	Local aLog		:= {} //ítems que dejarán stock negativo.
	Local aLogTitle	:= {}
	Local aReturn	:= {"", 1, "", 2, 2, 1, "",1 }
	Local cFunName	:= FunName()
	Local nLenProd	:= GetSX3Cache("C9_PRODUTO", "X3_TAMANHO") + 2
	Local nLenPed	:= GetSX3Cache("C9_PEDIDO", "X3_TAMANHO") + 4

	Default cAlias	:= ""
	Default nReg	:= 0

	If !lEstNeg .And. cPaisLoc $ "MEX" .And. IsInCallStack("MATA410") .And. !Empty(cAlias) .And. nReg > 0
		aAreaSC5 := SC5->(GetArea())
		aAreaSC6 := SC6->(GetArea())
		aAreaSC9 := SC9->(GetArea())
		aAreaSB2 := SB2->(GetArea())
		aAreaSF4 := SF4->(GetArea())

		SC5->(DbGoTo(nReg))
		cPedido := SC5->C5_NUM

		SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		SF4->(DbSetOrder(1)) //F4_FILIAL+F4_CODIGO

		DbSelectArea("SC9")
		SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED

		If SC9->(MsSeek(cFilSC9+cPedido))

			while !SC9->(EoF()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == (cFilSC9+cPedido)
				If Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED) //Solo procesa productos sin bloqueos.
					cProd := SC9->C9_PRODUTO
					cLocal := SC9->C9_LOCAL
					nCantidad := SC9->C9_QTDLIB
					If  SC6->(msSeek(cFilSC6+cPedido+SC9->C9_ITEM+cProd)) .And. ;
						SF4->(msSeek(cFilSF4+SC6->C6_TES)) .And. SF4->F4_ESTOQUE == "S" .And. ;
						SB2->(MsSeek(cFilSB2 + cProd + cLocal)) .And. ( SaldoSB2(,.F.,,,,,,,.F.) <  nCantidad )
						AAdd(aLog, {PadR(SC9->C9_PEDIDO, nLenPed) + PadR(SC9->C9_ITEM, 5) + PadR(cProd, nLenProd) + cLocal})
					EndIf
				EndIf
				SC9->(DbSkip())
			EndDo

		EndIf

		SC5->(RestArea(aAreaSC5))
		SC6->(RestArea(aAreaSC6))
		SC9->(RestArea(aAreaSC9))
		SB2->(RestArea(aAreaSB2))
		SF4->(RestArea(aAreaSF4))

		If Len(aLog) > 0
			lRet := .F.
			If isBlind()
				Conout(STR0004) //"Se identificaron productos que sobrepasan el límite de stock, no se permite dejar el saldo en stock Negativo. (MV_ESTNEG) \n ¿Desea visualizar el log?"
			ElseIf MsgYesNo(STR0004 + CRLF + STR0011, "MV_ESTNEG") //"Se identificaron productos que sobrepasan el límite de stock, no se permite dejar el saldo en stock Negativo. (MV_ESTNEG) \n ¿Desea visualizar el log?"
				AAdd(aLogTitle, Padr(STR0005, nLenPed) + STR0006 + PadR(STR0007, nLenProd) + STR0008) //"Pedido " ## "Ítem " ## "Producto " ## "Local"
				MsAguarde( { ||fMakeLog( aLog , aLogTitle , "", .T. , cFunName , STR0009 , , "P" , aReturn, .F. )}, STR0010) //"Impresión de Log" ## "Generando Log de proceso..."
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} fDesDocMI

@author Luis Arturo Samaniego
@since 20/08/2021
@param cTipoDoc, String, Valor de campo D1/D2_ESPECIE
@return cDesDoc, String, Tipo de documento
/*/
Function fDesDocMI(cTipoDoc)
Local cDesDoc    := ""
Default cTipoDoc := ""

	cDesDoc    := Alltrim(cTipoDoc)

	If cDesDoc == "NF"
		cDesDoc := "FAC"
	EndIf

Return cDesDoc
/*/{Protheus.doc} FATXMICERT
Función que lee el certificado informado en el parámetro MV_CFDI_CP, contenido 
en la ruta informada en el parámetro MV_CFDDIRS.
@type function
@author luis.enríquez
@since 18/10/2022
@version 1.0
@return cCertD, character, Cadena con el certificado digital
@example
FATXMICERT()
@see (Usado en FATSMEX.PRW)
/*/
Function FATXMICERT()
	Local cCertD	:= ""
	Local nHandle   := 0
	Local cLinea    := ""
	Local cFile := &(SuperGetMv("MV_CFDDIRS",,""))+SuperGetMv("MV_CFDI_CP",,"")

	nHandle := FT_FUse(cFile)
	// Se hay error al abrir el archivo
	If  nHandle = -1
		return cCertD
	Endif
	// Se posiciona en la primera línea
	FT_FGoTop()

	While !FT_FEOF()
		cLinea := FT_FReadLn() // lee cada línea del archivo
		If Alltrim(cLinea) <> "-----BEGIN CERTIFICATE-----" .And. Alltrim(cLinea) <> "-----END CERTIFICATE-----"
			cCertD += Alltrim(cLinea)
		EndIf
		FT_FSKIP() // Salta a siguiente línea
	End

	// Fecha o Arquivo
	FT_FUSE()

Return cCertD

/*/{Protheus.doc} FATXMISECA
Realiza el sellado de la Cadena Original con algoritmo SHA256 utilizando el archivo configurado en el parámetro MV_CFDI_CP, 
y que se encuentra contenido en la ruta informada en el parámetro MV_CFDDIRS.
@type function
@author luis.enríquez
@since 25/10/2022
@version 1.0
@param cCadOri, character, Cadena Original del Documento
@return cCertcSelloD, character, Cadena Original sellada del Documento
@example
FATXMISECA(cCadOri)
@see (Usado en FATSMEX.PRW)
/*/
Function FATXMISECA(cCadOri)
	Local cSello := ""

	Default cCadOri := ""

	If !Empty(cCadOri)
		cSello := EVPDigest(cCadOri, 5)
		cSello := PrivSignRSA(&(SuperGetMv("MV_CFDDIRS", , "")) + SuperGetMv("MV_CFDARQS", , ""), cSello, 6, "assinatura") //SHA256
		cSello := ENCODE64(cSello)
	EndIf
Return cSello

/*/{Protheus.doc} FATXMIEMIS
Genera la Cadena original y Nodo de cfdi:Emisor
@type function
@author luis.enríquez
@since 25/10/2022
@version 1.0
@param aSM0, arreglo, Datos de la Empresa del ambiente
@param lCadOrig, lógico, .T. = genera Cadena Original y .F. = genera XML
@param cSepara, caracter, Separador para la Cadena Original
@return cEmisor, caracter, Datos para el nodo de cfdi:Emisor
@example
FATXMIEMIS(aSM0, lCadOrig, cSepara)
@see (Usado en FATSMEX.PRW)
/*/
Function FATXMIEMIS(aSM0, lCadOrig, cSepara)
	Local cEmisor := ""
	Local cCtrl   := (chr(13)+chr(10))
	Local nSpace4 := Space(4)
	Local lPEEmRe := ExistBlock("PEEMIREC")
	Local aEmisor := {}
	Local nPosRFC := 0
	Local nPosNom := 0
	Local nPosReg := 0
	
	Default aSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CGC", "M0_NOMECOM", "M0_DSCCNA", "M0_CEPENT"} )
	Default lCadOrig := .F.
	Default cSepara := "|"

	aEmisor := IIF(lPEEmRe,ExecBlock("PEEMIREC",.F.,.F.,{"E"}),{})
	If lPEEmRe 
		nPosRFC := aScan(aEmisor, { | x,y | AllTrim( x[1] ) == 'RFC' })
		nPosNom := aScan(aEmisor, { | x,y | AllTrim( x[1] ) == 'Nombre' })
		nPosReg := aScan(aEmisor, { | x,y | AllTrim( x[1] ) == 'RegimenFiscal' })
	EndIf
	cRFC 	:= IIf(lPEEmRe .And. nPosRFC > 0 .and. !Empty(aEmisor[nPosRFC][2]),AllTrim(aEmisor[nPosRFC][2]),AllTrim(aSM0[1][2]))
	cNombre	:= IIf(lPEEmRe .And. nPosNom > 0 .and. !Empty(aEmisor[nPosNom][2]),AllTrim(aEmisor[nPosNom][2]),AllTrim(aSM0[2][2]))
	cRegFis	:= IIf(lPEEmRe .And. nPosReg > 0 .and. !Empty(aEmisor[nPosReg][2]),AllTrim(aEmisor[nPosReg][2]),Alltrim(aSM0[3][2]))
	
	If lCadOrig //Cadena Origina
		//Rfc
		cEmisor += CFDCarEsp(cRFC,.F.) + cSepara
		//Nombre
		cEmisor += CFDCarEsp(cNombre,.F.) + cSepara
		//RegimenFiscal
		cEmisor += CFDCarEsp(cRegFis) + cSepara
	Else //XML
		cEmisor += nSpace4 + '<cfdi:Emisor'
		cEmisor += ' Rfc="' + CFDCarEsp(cRFC)+ '"' 
		cEmisor += ' Nombre="' + CFDCarEsp(cNombre,.T.) + '"'
		cEmisor += ' RegimenFiscal="' + CFDCarEsp(cRegFis) + '"'
		cEmisor += '/>' + cCtrl
	EndIf
Return cEmisor

/*/{Protheus.doc} FATXMIRECE
Genera la Cadena origina y Nodo de cfdi:Receptor
@type function
@author luis.enríquez
@since 25/10/2022
@version 1.0
@param aSM0, arreglo, Datos de la Empresa del ambiente
@param lCadOrig, lógico, .T. = genera Cadena Original y .F. = genera XML
@param cSepara, caracter, Separador para la Cadena Original
@param lDocTras, lógico, .T. = Si el Documento es de tipo Traslado, en caso contrario enviar .F.
@param lComExt, lógico, .T. = Si el Documento es lleva complemento de Comercio Exterior, en caso contrario enviar .F.
@param lCartaP, lógico, .T. = Si el Documento es lleva complemento de Carta Porte, en caso contrario enviar .F.
@param lFacGlo, lógico, .T. = Si el Documento es de tipo Factura Global, en caso contrario enviar .F.
@param aDatosRec, arreglo, Datos adiconales para el nodo cfdi:Receptor
@return cRecep, caracter, Datos para el nodo de cfdi:Receptor
@example
FATXMIRECE(aSM0, lCadOrig, cSepara, lDocTras, lComExt, lCartaP, lFacGlo, aDatosRec)
@see (Usado en FATSMEX.PRW)
/*/
Function FATXMIRECE(aSM0, cCliente, cLoja, lCadOrig, cSepara, lDocTras, lComExt, lCartaP, lFacGlo, aDatosRec, aDatosCli, lDatoT, aRecp,cExporta)
	Local cRecep  := ""
	Local cRFCRec := ""
	Local cNomRec := ""
	Local cCPRec  := ""
	Local cRegFRec:= ""
	Local cCtrl   := (chr(13)+chr(10))
	Local aAreaSA1:= SA1->(GetArea())
	Local nSpace4 := Space(4)
	Local lUsoCFDI:= Len(aDatosRec[1]) >= 1
	Local lPEEmRe := ExistBlock("PEEMIREC")
	Local cUsoCFD := ""
	Local nPosRFC := 0
	Local nPosNom := 0
	Local nPosReg := 0
	Local nPosDF  := 0
	Local nPosUso := 0
	Local nPosRF  := 0
	Local nPosNumId:=0
	Local cResFis  := ""
	Local cNumRegid := ""

	Default aSM0 := FWSM0Util():GetSM0Data( cEmpAnt, cFilAnt , { "M0_CGC", "M0_NOMECOM", "M0_DSCCNA", "M0_CEPENT"} )
	Default cCliente := ""
	Default cLoja    := ""
	Default lCadOrig := .F.
	Default cSepara  := "|"
	Default lDocTras := .F.
	Default lComExt  := .F.
	Default lCartaP  := .F.
	Default lFacGlo  := .F.
	Default aDatosRec := {}
	Default aDatosCli := {}
	Default lDatoT   := .F.
	Default aRecp    := {}
	Default cExporta := "1"

	If lPEEmRe 
		nPosRFC := aScan(aRecp, { | x,y | AllTrim( x[1] ) == 'RFC' })
		nPosNom := aScan(aRecp, { | x,y | AllTrim( x[1] ) == 'Nombre' })
		nPosReg := aScan(aRecp, { | x,y | AllTrim( x[1] ) == 'RegimenFiscal' })
		nPosDF  := aScan(aRecp, { | x,y | AllTrim( x[1] ) == 'DomicilioFiscal' })
		nPosUso := aScan(aRecp, { | x,y | AllTrim( x[1] ) == 'UsoCFDI' })
		nPosRF  := aScan(aRecp, { | x,y | AllTrim( x[1] ) == 'ResidenciaFiscal' })
		nPosNumId := aScan(aRecp, { | x,y | AllTrim( x[1] ) == 'NumRegIdTrib' })
	EndIf
	
	//Receptor
	If Len(aDatosCli) > 0
		cRFCRec := IIF(nPosRFC > 0,AllTrim(aRecp[nPosRFC][2]),AllTrim(aDatosCli[1]))
		cNomRec := FxDelExp(IIF(nPosNom > 0,AllTrim(aRecp[nPosNom][2]),AllTrim(aDatosCli[2])))
		cCPRec  := IIF(nPosDF > 0,AllTrim(aRecp[nPosDF][2]),AllTrim(aDatosCli[3]))
	EndIf

	cRegFRec := IIf((lComExt .Or. lCartaP) .And. lDocTras,AllTrim(aSM0[3][2]),aDatosRec[2])
	cRegFRec := IIF(nPosReg > 0,AllTrim(aRecp[nPosReg][2]),cRegFRec) 
	cUsoCFD  := IIF(nPosUso > 0,AllTrim(aRecp[nPosUso][2]),aDatosRec[1]) //Uso CFDI

	If lCadOrig //Cadena Original
		//Rfc
		cRecep += IIf(lFacGlo, "XAXX010101000", CFDCarEsp(cRFCRec, .F.)) + cSepara
		If !lFacGlo
			//Nombre
			cRecep += CFDCarEsp(cNomRec,.F.) + cSepara
			//DomicilioFiscalReceptor
			cRecep += CFDCarEsp(cCPRec,.F.) + cSepara
			If (lComExt .and. !lDatoT) .Or. (cExporta $ "04" .And. AllTrim(aDatosCli[1]) $ "XEXX010101000")
				If nPosNumId > 0
					cNumRegid:=IIf(!Empty(AllTrim(aRecp[nPosNumId][2])),CFDCarEsp(AllTrim(aRecp[nPosNumId][2])),"")
				Else
					cNumRegid := IIf(!Empty(aDatosRec[3]),CFDCarEsp(aDatosRec[3]),"")
				Endif

				if nPosRF > 0
					cResFis := IIf(!Empty(AllTrim(aRecp[nPosRF][2])),CFDCarEsp(AllTrim(aRecp[nPosRF][2])),"")
				else
					cResFis := IIf(!Empty(aDatosRec[4]),aDatosRec[4],"")
				ENDIF  
				cRecep += IIf(!Empty(cResFis), cResFis + cSepara,"")
				cRecep += IIf(!Empty(cNumRegid), cNumRegid + cSepara,"")	
			EndIf
			//RegimenFiscalReceptor
			cRecep += CFDCarEsp(cRegFRec,.F.) + cSepara
		EndIf
		//UsoCFDI
		If lUsoCFDI
			cRecep += cUsoCFD + cSepara
		EndIf

	Else //XML
		cRecep += nSpace4 + '<cfdi:Receptor'
		cRecep += ' Rfc="' + CFDCarEsp(IIf(lFacGlo, "XAXX010101000", cRFCRec)) + '"'
		If !lFacGlo
			cRecep += ' Nombre="' + CFDCarEsp(cNomRec,.T.) + '"'
			cRecep += ' DomicilioFiscalReceptor="' + cCPRec + '"'
			cRecep += ' RegimenFiscalReceptor="' + cRegFRec + '"'
		EndIf
		If lUsoCFDI
			cRecep += ' UsoCFDI="' + cUsoCFD + '"'
		EndIf
		If (lComExt .and. !lDatoT) .Or. (cExporta $ "04" .And. AllTrim(aDatosCli[1]) $ "XEXX010101000") 
			If nPosNumId > 0
				cNumRegid:=IIf(!Empty(AllTrim(aRecp[nPosNumId][2])),CFDCarEsp(AllTrim(aRecp[nPosNumId][2])),"")
			Else
				cNumRegid := IIf(!Empty(aDatosRec[3]),CFDCarEsp(aDatosRec[3]),"")
			Endif

			if nPosRF > 0
				cResFis := IIf(!Empty(AllTrim(aRecp[nPosRF][2])),CFDCarEsp(AllTrim(aRecp[nPosRF][2])),"")
			else
				cResFis := IIf(!Empty(aDatosRec[4]),aDatosRec[4],"")
			ENDIF

			cRecep += IIf(!Empty(cNumRegid),' NumRegIdTrib="' + cNumRegid + '"',"")
			cRecep += IIf(!Empty(cResFis),' ResidenciaFiscal="' + cResFis + '"',"")
		EndIf
		cRecep += '/>' + cCtrl	
	EndIf
	RestArea(aAreaSA1)
Return cRecep

/*/{Protheus.doc} FATXMICREA
Función que crea XML en la ruta definida en el parámetro MV_CFDDOCS
@type function
@author luis.enríquez
@since 25/10/2022
@version 1.0
@param cXML, character, Contenido del archivo a escribir
@param cFile, character, Nombre del archivo a escribir
@return Nil
@example
FATXMICREA()
@see (Usado en FATSMEX.PRW)
/*/
Function FATXMICREA(cXML, cFile)
	Local cPath	    := SuperGetMV("MV_CFDDOCS", .F., "")
	Local cPathFile := ""
	Local nHdl      := 0
	Local cRutAdic	:= ""

	Default cXML := ""
	Default cFile := ""

	cPathFile :=  &(cPath) + cRutAdic + cFile

	Ferase(cPathFile)

	nHdl :=	fCreate(cPathFile,,,.F.)
	If (nHdl >= 0)
		fWrite(nHdl,cXML)
		fClose(nHdl)
	Else
		ConOut(StrTran(STR0012, '###', AllTrim(cPathFile)) + ":" + Str(Ferror())) //"Error en la creación del archivo ### "
	EndIf
Return Nil

/*/{Protheus.doc} FATXCOMPCL
Obtiene datos de Complementos del Cliente (AI0)
@type function
@author luis.enríquez
@since 31/10/2022
@version 1.0
@param cFilAI0, character, Filial para la tabla AI0
@param cCliente, character, Código del Cliente
@param cLoja, character, Tienda del Cliente
@param cCliRegF, character, Regimén Fisacal del Cliente
@param cAI0MPago, character, Metódo de Pago del Cliente
@return Nil
@example
FATXMICOMP(cFilAI0,cCliente,cLoja,cCliRegF,cAI0MPago)
@see (Usado en FATSMEX.PRW)
/*/
Function FATXCOMPCL(cFilAI0, cCliente, cLoja, cCliRegF, cAI0MPago)
	Default cFilAI0   := xFilial("AI0")
	Default cCliente  := "" 
	Default cLoja     := ""
	Default cCliRegF  := ""
	Default cAI0MPago := ""

	DbSelectArea("AI0")
	AI0->(DbSetOrder(1)) //AI0_FILIAL+AI0_CODCLI+AI0_LOJA 
	If AI0->(MsSeek(cFilAI0 + cCliente + cLoja))
		cCliRegF := Alltrim(AI0->AI0_REGFIS)
		cAI0MPago := Alltrim(AI0->AI0_MPAGO)
	EndIf
Return Nil

/*/{Protheus.doc} FATXVALF3I
Realiza búsqueda de datos en tabla F3I - Mantenimiento de Tablas.
@type function
@author luis.enríquez
@since 18/11/2022
@version 1.0
@param cTabla, character, Código de Tabla donde se realizará la búsqueda
@param cCampo, character, Nombre del campo por el cual se realizará la busqueda
@param cBusca, character, Dato por el cual ser realizará la búsqueda.
@return Nil
@example
FATXMICOMP(cFilAI0,cCliente,cLoja,cCliRegF,cAI0MPago)
@see (Usado en FATSMEX.PRW)
/*/
Function FATXVALF3I(cTabla, cCampo, cBusca)
	Local aTabF3H	:= {}
	Local aTabF3I	:= {}
	Local cFilF3H	:= xFilial("F3H")
	Local cFilF3I   := xFilial("F3I")
	Local nPosTab	:= 0
	Local nI        := 0
	Local nT        := 0
	Local cCond     := ""
	Local cAliasF3I := GetNextAlias()
	Local cF3IConteu:= ""
	Local cDatoF3I  := ""
	Local nPos1		:= 1
	Local nPos2		:= 0
	Local lGetDB	:= AllTrim(Upper(TCGetDB())) == "ORACLE"
	Local cCondFil  := ""

	Default cTabla  := ""
	Default cCampo	:= ""
	Default cBusca  := ""

	If !Empty(cTabla) .And. !Empty(cCampo) .And. !Empty(cBusca)
		aAdd( aTabF3H, { cTabla , {} } )
		nPosTab := Len(aTabF3H)

		If F3H->( dbSeek( cFilF3H + cTabla, .T.) )
			While F3H->( !Eof() .And. F3H_FILIAL + F3H_CODIGO == cFilF3H + cTabla )
				F3H->( aAdd( aTabF3H[nPosTab,2], { Upper(Trim(F3H_CAMPOS)), F3H_TIPO, F3H_TAMAN, F3H_DECIMA } ) )
				F3H->( dbSkip() )
			End While
		EndIf

		cCampo := Upper(cCampo)

		For nI := 1 to Len(aTabF3H[nPosTab,2])
			If aTabF3H[nPosTab,2,nI,1] == cCampo
				nPos2 := aTabF3H[nPosTab,2,nI,3]
				Exit
			Else
				nPos1 += aTabF3H[nPosTab,2,nI,3]
			EndIf
		Next nI

		cCond := "% F3I.F3I_FILIAL = '" + cFilF3I + "' AND F3I.F3I_CODIGO = '" + cTabla + "'"

		cCondFil := IIf(lGetDB,"TRIM(TO_CHAR(SUBSTR(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + ")))","SUBSTRING(F3I_CONTEU," + Alltrim(Str(nPos1)) + "," + Alltrim(Str(nPos2)) + ")")
		cCond += " AND " + cCondFil + "= '" + Alltrim(cBusca) + "'"
		cCond += "%"

		BeginSql Alias cAliasF3I                             
			SELECT F3I_FILIAL, F3I_CODIGO, F3I_SEQUEN, F3I_CONTEU		
			FROM %table:F3I% F3I		
			WHERE %exp:cCond% AND F3I.%notDel%	
			ORDER BY F3I_FILIAL, F3I_CODIGO, F3I_SEQUEN
		EndSql

		While (cAliasF3I)->(!Eof())
			cF3IConteu := (cAliasF3I)->F3I_CONTEU
			(cAliasF3I)->(dbSkip())
		EndDo

		nPosIni := 1
		nColAte := 1

		If !Empty(cF3IConteu)
			For nT:= 1 To Len(aTabF3H[nPosTab,2]) 			
				//Tamaño del Campo                                          	                
				nTamCpo := aTabF3H[nPosTab,2,nT,3]
				//--Guarda el contenido del campo en variable 				
				If aTabF3H[nPosTab,2,nT,2] == "C" //Caracter
					cDatoF3I := Subs(cF3IConteu,nPosIni,nTamCpo)
				ElseIf aTabF3H[nPosTab,2,nT,2] == "N" //Número
					//cDatoF3I := Val(Subs(cF3IConteu,nPosIni,nTamCpo))
				ElseIf aTabF3H[nPosTab,2,nT,2] == "D" //Fecha
					//cConteudo := Subs(cContTmp,nPosIni,nTamCpo)
					//cConteudo := If("/" $ cConteudo , CtoD(cConteudo) , StoD(cConteudo))
				EndIf             

				Aadd(aTabF3I,cDatoF3I)
				//--Posición del Próximo Campo
				nPosIni += nTamCpo
			Next nT
		EndIf
	EndIf
Return aTabF3I

/*/{Protheus.doc} FATXMENPRO
	Función para agregar nuevas acciones para pantalla de Proveedores (Mercado Internacional)
	@type  Function
	@author Luis.Enríquez
	@since 15/12/2022
	@version version
	@param oView, Vista MVC para rutina MATA020
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function FATXMENPRO(oView)
	Local cProveFE := SuperGetMV("MV_PROVFE",,"")
	Local lCpoReg  := IIf(TCCanOpen(RetSqlname("AIT")),AIT->(ColumnPos("AIT_REG")) > 0,.F.)

	Default oView := Nil
	
	If cPaisLoc =="COL" .And. oView != Nil .And. lCpoReg .And. !Empty(cProveFE)
		oView:AddUserButton(STR0013,'BUDGET',{ || FISA827( "SA2", SA2->(RecNo()), 4, 1, "P") },,,{MODEL_OPERATION_UPDATE}) //"Resp. Obligaciones DIAN"
		oView:AddUserButton(STR0014,'BUDGET',{ || FISA827( "SA2", SA2->(RecNo()), 4, 2, "P") },,,{MODEL_OPERATION_UPDATE}) //"Tributos DIAN"	
	EndIf
Return Nil

/*/{Protheus.doc} FATXDELEMI
	Función de acciones al hacer commit en la rutina de Proveedores - MATA020 (Mercado Internacional)
	@type  Function
	@author Luis.Enríquez
	@since 15/12/2022
	@version version
	@param oModel, Modelo MVC para rutina MATA020
	@param nOperation, Operación a realizar durante el commit
	@return Nil
	@example
	(examples)
	@see (links_or_references)
	/*/
Function FATXDELEMI(oModel, nOperation)
	Local aArea   := GetArea()
	Local cFilAIT := xFilial("AIT")
	Local cProv   := ""
	Local cLoja   := ""
	Local lCpoReg := IIf(TCCanOpen(RetSqlname("AIT")),AIT->(ColumnPos("AIT_REG")) > 0,.F.)
	Local cProveFE := SuperGetMV("MV_PROVFE",,"")

	Default oModel     := Nil
	Default nOperation := 0

	If cPaisLoc == "COL" .And. oModel <> Nil .And. lCpoReg .And. !Empty(cProveFE)
		cProv := oModel:GetValue("SA2MASTER","A2_COD")
		cLoja := oModel:GetValue("SA2MASTER","A2_LOJA")
		If nOperation == MODEL_OPERATION_DELETE
			dbSelectArea("AIT")
			AIT->(dbSetOrder(1)) //AIT_FILIAL+AIT_CODCLI+AIT_LOJA+AIT_TIPO
			If AIT->(MsSeek(cFilAIT + cProv + cLoja))
				If AIT->AIT_REG == "P"
					RecLock("AIT",.F.)
					AIT->(DbDelete())
					AIT->(MsUnlock())
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} FATXCOMEXT
	Genera la Cadena Original y nodo en el XML para informar los datos correspondientes al Complemento de Comercio Exterior.
	@type  Function
	@author Luis.Enríquez
	@since 13/03/2023
	@version version
	@param lCadena, lógico, Indica si se va a generar la Cadena Originao o los nodos del XML
	@param aDatosCE, Array,  Arreglo con los datos del Encabezado del Complemento de Comercio Exterior
	@param cSepara, String, Caracter del separador utilizado para la generación de la Cadena Original
	@param aEmiCE, Array, Arreglo con datos del Emisor
	@param aDatosCli, Array, Arreglo con datos del Cliente (Tabla SA1)
	@param aDatosRec, Array, Arreglo con datos Fiscales del Receptor (Tabla SF2/SM0)
	@param aDetComE, Array, Arreglo con datos para el Detalle de Mercancías del Complemento de Comercio exterior
	@return cDatoCC, String, Si lCadena es .T. retorna el valor de la Cadena Original, caso contrario retorna el nodo para generación del XML
	@example
	(examples
	@see (links_or_references)
	/*/
Function FATXCOMEXT(lCadena, aDatosCE, cSepara, aEmiCE, aDatosCli, aDatosRec, aDetComE)
	Local cDatoCC := ""
	Local cVerCE  := "2.0"
	Local cCtrl   := (chr(13)+chr(10))
	Local nI      := 0
	Local lCpoDes := SF2->(ColumnPos("F2_ACOPLA")) > 0
	Local ComCE   := "cce20"

	Default lCadena   := .F.
	Default aDatosCE  := {}
	Default cSepara   := "|"
	Default aEmiCE    := {}
	Default aDatosCli := {}
	Default aDatosRec := {}
	Default aDetComE  := {}

	If lCadena //Cadena Original
		cDatoCC += cVerCE + cSepara
		cDatoCC += IIf(!Empty(aDatosCE[1]), Alltrim(aDatosCE[1]) + cSepara, "") //F2_TRASLA
		cDatoCC += IIf(!Empty(aDatosCE[3]), Alltrim(aDatosCE[3]) + cSepara, "") //F2_CVEPED
		cDatoCC += IIf(!Empty(aDatosCE[4]), Alltrim(aDatosCE[4]) + cSepara, "") //F2_CERORI
		cDatoCC += IIf(!Empty(aDatosCE[5]), Alltrim(aDatosCE[5]) + cSepara, "") //F2_NUMCER
		cDatoCC += IIf(!Empty(aDatosCE[6]), Alltrim(aDatosCE[6]) + cSepara, "") //F2_EXPCONF
		cDatoCC += IIf(!Empty(aDatosCE[7]), Alltrim(aDatosCE[7]) + cSepara, "") //F2_INCOTER
		cDatoCC += IIf(!Empty(aDatosCE[8]), CFDCarEsp(AllTrim(aDatosCE[8]), .F.) + cSepara, "") //F2_OBSCE
		cDatoCC += IIf(!Empty(Str(aDatosCE[9])), Alltrim(Str(aDatosCE[9])) + cSepara, "") //F2_TCUSD
		cDatoCC += IIf(!Empty(Str(aDatosCE[10])), Alltrim(Str(aDatosCE[10],14,2)) + cSepara, "") //F2_TOTUSD

		//cce20:Emisor
		If Len(aEmiCE) > 0 
			cDatoCC += Alltrim(aEmiCE[1]) + cSepara //Calle
			cDatoCC += IIf(!Empty(aEmiCE[2]), AllTrim(aEmiCE[2]) + cSepara, "") //Colonia
			If Len(aEmiCE) >= 7 .And. !Empty(aEmiCE[7])
				cDatoCC += Alltrim(aEmiCE[7]) + cSepara //Localidad
			EndIf
			cDatoCC += IIf(!Empty(aEmiCE[3]), AllTrim(aEmiCE[3]) + cSepara, "") //Municipio
			cDatoCC += IIf(!Empty(aEmiCE[4]), AllTrim(aEmiCE[4]) + cSepara, "") //Estado
			cDatoCC += AllTrim(aEmiCE[5]) + cSepara //Pais
			cDatoCC += IIf(!Empty(aEmiCE[6]), AllTrim(aEmiCE[6]) + cSepara, "") //CodigoPostal
		EndIf

		//cce20:Receptor
		If Len(aDatosCli) > 0
			cDatoCC += IIf(aDatosCli[1] == "XEXX010101000", CFDCarEsp(AllTrim(Iif(Alltrim(cEspecie)== "NCC",SF1->F1_IDTRIB,SF2->F2_IDTRIB))) + cSepara, "") //F2_IDTRIB
			cDatoCC += CFDCarEsp(AllTrim(aDatosCli[4])) + cSepara //A1_END
			cDatoCC += IIf(!Empty(AllTrim(aDatosCli[5])), AllTrim(aDatosCli[5]) + cSepara, "") //A1_NR_END
			cDatoCC += IIf(!Empty(AllTrim(aDatosCli[6])), AllTrim(aDatosCli[6]) + cSepara, "") //A1_NROINT
			cDatoCC += IIf(!Empty(CFDCarEsp(AllTrim(aDatosCli[7]))), CFDCarEsp(CFDCarEsp(AllTrim(aDatosCli[7]))) + cSepara,"") //A1_BAIRRO
			cDatoCC += IIf(!Empty(CFDCarEsp(AllTrim(aDatosCli[8]))), CFDCarEsp(AllTrim(aDatosCli[8]),.F.) + cSepara,"") //A1_MUN
			cDatoCC += CFDCarEsp(Alltrim(Posicione("SX5",1,xFilial("SX5")+"12" + aDatosCli[9],"X5_DESCRI"))) + cSepara //A1_EST
			cDatoCC += AllTrim(Posicione("SYA",1,xFilial("SYA")+aDatosCli[10],"YA_CCESAT")) + cSepara //A1_PAIS
			cDatoCC += AllTrim(aDatosCli[11]) + cSepara //A1_CEP
		EndIf

		//cce20:Destinatario
		If lCpoDes
			cDatoCC += LxCEDest(SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_ACOPLA,.T.)
		EndIf

		//cce20:Mercancias
		If Len(aDetComE) > 0
			For nI := 1 To Len(aDetComE)
				cDatoCC += IIf(!Empty(aDetComE[nI][1] + aDetComE[nI][2]), Alltrim(aDetComE[nI][1] + aDetComE[nI][2]) + cSepara,"") //D2_ITEM //D2_COD
				cDatoCC += IIf(!Empty(aDetComE[nI][3]), Alltrim(aDetComE[nI][3]) + Alltrim(aDetComE[nI][4]) + cSepara, "") //D2_FRACCA //D2_NICO
				cDatoCC += IIf(!Empty(Str(aDetComE[nI][5])), Alltrim(Str(aDetComE[nI][5])) + cSepara, "") //D2_CANADU
				cDatoCC += IIf(!Empty(aDetComE[nI][8]), AllTrim(aDetComE[nI][8]) + cSepara, "") //D2_FRACCA
				cDatoCC += IIf(!Empty(Str(aDetComE[nI][6],14,2)), Alltrim(Str(aDetComE[nI][6],14,2)) + cSepara, "") //D2_VALADU
				cDatoCC += IIf(!Empty(Str(aDetComE[nI][7],14,2)), Alltrim(Str(aDetComE[nI][7],14,2)) + cSepara, "") //D2_USDADU
			Next nI
		EndIf
	Else //XML
		cDatoCC :=  '		<'+ComCE+':ComercioExterior' 
		cDatoCC +=  ' Version="' + cVerCE + '"'
		cDatoCC += IIf(!Empty(aDatosCE[1]), ' MotivoTraslado="' + Alltrim(aDatosCE[1]) + '"',"") //F2_TRASLA
		cDatoCC += IIf(!Empty(aDatosCE[3]), ' ClaveDePedimento="' + Alltrim(aDatosCE[3]) + '"',"") //F2_CVEPED
		cDatoCC += IIf(!Empty(aDatosCE[4]), ' CertificadoOrigen="' + Alltrim(aDatosCE[4]) +'"',"") //F2_CERORI
		cDatoCC += IIf(!Empty(aDatosCE[5]), ' NumCertificadoOrigen="' + Alltrim(aDatosCE[5]) + '"',"") //F2_NUMCER
		cDatoCC += IIf(!Empty(aDatosCE[6]), ' NumeroExportadorConfiable="' + Alltrim(aDatosCE[6]) + '"',"") //F2_EXPCONF
		cDatoCC += IIf(!Empty(aDatosCE[7]), ' Incoterm="' + Alltrim(aDatosCE[7]) + '"',"") //F2_INCOTER
		cDatoCC += IIf(!Empty(aDatosCE[8]), ' Observaciones="' + CFDCarEsp(AllTrim(aDatosCE[8]), .T.) + '"',"") //F2_OBSCE
		cDatoCC += IIf(!Empty(Str(aDatosCE[9])), ' TipoCambioUSD="' + Alltrim(Str(aDatosCE[9])) + '"',"") //F2_TCUSD
		cDatoCC += IIf(!Empty(Str(aDatosCE[10])), ' TotalUSD="' + Alltrim(Str(aDatosCE[10],14,2)) + '"',"") //F2_TOTUSD
		cDatoCC +=  '>' + cCtrl

		//Emisor
		If Len(aEmiCE) > 0			
			cDatoCC += '    		<'+ComCE+':Emisor>' + cCtrl
			cDatoCC += '        		<'+ComCE+':Domicilio'         
			cDatoCC += ' Calle="' + Alltrim(aEmiCE[1]) + '"' 
			cDatoCC += IIf(!Empty(aEmiCE[2]), ' Colonia="' + AllTrim(aEmiCE[2]) + '"', "")  
			If Len(aEmiCE) >= 7 .And. !Empty(aEmiCE[7])
				cDatoCC += ' Localidad="' + AllTrim(aEmiCE[7]) + '"'
			EndIf
			cDatoCC += IIf(!Empty(aEmiCE[3]), ' Municipio="' + AllTrim(aEmiCE[3]) + '"', "") 
			cDatoCC += IIf(!Empty(aEmiCE[4]), ' Estado="' + AllTrim(aEmiCE[4]) + '"',"")
			cDatoCC += ' Pais="' + AllTrim(aEmiCE[5]) + '"'
			cDatoCC += IIf(!Empty(aEmiCE[6]),' CodigoPostal="' + AllTrim(aEmiCE[6]) + '"',"") 
			cDatoCC += '/>' + ( chr(13)+chr(10) )
			cDatoCC += '    		</'+ComCE+':Emisor>' + cCtrl
		EndIf

		//Receptor
		If Len(aDatosCli) > 0
			cDatoCC += '    		<'+ComCE+':Receptor ' + IIf(aDatosCli[1]=="XEXX010101000", 'NumRegIdTrib="' + CFDCarEsp(AllTrim(aDatosCli[12])) + '"',"")     
			cDatoCC += '>' + cCtrl
			cDatoCC += '        		<'+ComCE+':Domicilio'        
			cDatoCC += ' Calle="' + CFDCarEsp(AllTrim(aDatosCli[4])) + '"' //A1_END
			cDatoCC += IIf(!Empty(AllTrim(aDatosCli[5])), ' NumeroExterior="' + AllTrim(aDatosCli[5]) + '"', "") //A1_NR_END
			cDatoCC += IIf(!Empty(AllTrim(aDatosCli[6])), ' NumeroInterior="' + AllTrim(aDatosCli[6]) + '"', "") //A1_NROINT
			cDatoCC += IIf(!Empty(CFDCarEsp(AllTrim(aDatosCli[7]))), ' Colonia="' + CFDCarEsp(AllTrim(aDatosCli[7])) + '"', "") //A1_BAIRRO
			cDatoCC += IIf(!Empty(AllTrim(aDatosCli[8])), ' Municipio="' + CFDCarEsp(AllTrim(aDatosCli[8]),.T.) + '"', "") //A1_MUN
			cDatoCC += ' Estado="' + CFDCarEsp(Alltrim(Posicione("SX5",1,xFilial("SX5") + "12" + aDatosCli[9],"X5_DESCRI"))) + '"' //A1_EST
			cDatoCC += ' Pais="' + AllTrim(Posicione("SYA",1,xFilial("SYA") + aDatosCli[10],"YA_CCESAT")) + '"' //A1_PAIS
			cDatoCC += ' CodigoPostal="' + AllTrim(aDatosCli[11]) + '"' //A1_CEP
			cDatoCC += '/>' + ( chr(13)+chr(10) )
			cDatoCC += '    		</'+ComCE+':Receptor>' + cCtrl
		EndIf

		//Destinatatios
		If lCpoDes
			cDatoCC += LxCEDest(SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_ACOPLA,.F.)
		EndIf

		//Mercancías
		If Len(aDetComE) > 0
			cDatoCC += '    		<'+ComCE+':Mercancias>' + cCtrl
			For nI := 1 To Len(aDetComE)
				cDatoCC += '      			<'+ComCE+':Mercancia'
				cDatoCC += IIf(!Empty(aDetComE[nI][1] + aDetComE[nI][2]),' NoIdentificacion="' + Alltrim(aDetComE[nI][1] + aDetComE[nI][2]) + '"',"") //D2_ITEM //D2_COD
				cDatoCC += IIf(!Empty(aDetComE[nI][3]), ' FraccionArancelaria="' + Alltrim(aDetComE[nI][3]) + Alltrim(aDetComE[nI][4]) + '"', "") //D2_FRACCA //D2_NICO
				cDatoCC += IIf(!Empty(Str(aDetComE[nI][5])), ' CantidadAduana="' + Alltrim(Str(aDetComE[nI][5])) + '"', "") //D2_CANADU
				cDatoCC += IIf(!Empty(aDetComE[nI][8]), ' UnidadAduana="' + AllTrim(aDetComE[nI][8]) + '"', "") ////D2_FRACCA
				cDatoCC += IIf(!Empty(Str(aDetComE[nI][6])), ' ValorUnitarioAduana="' + Alltrim(Str(aDetComE[nI][6],14,2)) + '"', "") //D2_VALADU
				cDatoCC += IIf(!Empty(Str(aDetComE[nI][7])),' ValorDolares="' + Alltrim(Str(aDetComE[nI][7],14,2)) + '"',"")  //D2_USDADU
				cDatoCC += ">" + cCtrl
				cDatoCC += '      			</'+ComCE+':Mercancia>' + cCtrl
			Next nI
			cDatoCC += '    		</'+ComCE+':Mercancias>' + cCtrl
		EndIf
		cDatoCC +=  '		</'+ComCE+':ComercioExterior>' + cCtrl
	EndIf
	
Return cDatoCC

/*/{Protheus.doc} FATXLEYFIS
	Genera la Cadena Original y nodo en el XML para informar los datos correspondientes al Complemento de Leyendas Fiscales.
	@type  Function
	@author Luis.Enríquez
	@since 16/03/2023
	@version version
	@param param_name, param_type, param_descr
	@param lCadena, lógico, Indica si se va a generar la Cadena Originao o los nodos del XML
	@param cPFisica, String, Valor de No. IMMEX, tomado del campo A1_PFISICA
	@param cSepara, String, Caracter del separador utilizado para la generación de la Cadena Original
	@param cRegIMMEX, String, Régimen del IMMEX (Campo F2_CONUNI)
	@return cDatosLF, String, Si lCadena es .T. retorna el valor de la Cadena Original, caso contrario retorna el nodo para generación del XML
	@example
	(examples
	@see (links_or_references)
	/*/
Function FATXLEYFIS(lCadena, cPFisica, cSepara, cRegIMMEX)
	Local cDatosLF := ""
	Local cCtrl    := (chr(13)+chr(10))
	Local cTxtLey  := "OPERACION DE CONFORMIDAD CON EL ART. 29 FRACCION I DE LIVA Y LO ESTIPULADO EN LAS RGCE 5.2.6. FRACCION ###, 5.2.7 Y 4.3.21"
	Local cVerLey  := "1.0"
	Local cFracc   := ""

	Default lCadena   := .F.
	Default cPFisica  := ""
	Default cSepara   := "|"
	Default cRegIMMEX := ""

	cFracc := IIf(cRegIMMEX == "1", "I", "II")
	
	cTxtLey := StrTran(cTxtLey,"###",cFracc)

	If lCadena
		cDatosLF += cVerLey + cSepara
		cDatosLF += 'IMMEX:' + AllTrim(cPFisica) + ' ' + cTxtLey + cSepara
	Else
		cDatosLF := '        <leyendasFisc:LeyendasFiscales version="' + cVerLey + '" >' + cCtrl
		cDatosLF += '            <leyendasFisc:Leyenda textoLeyenda="IMMEX:' + AllTrim(cPFisica) + ' ' + cTxtLey + '" />' + cCtrl
		cDatosLF += '        </leyendasFisc:LeyendasFiscales>' + cCtrl
	EndIf

Return cDatosLF


/*/{Protheus.doc} fOrdSepara
	Obtiene datos de orden de separación
	@type  Function
	@author Cristian Franco
	@since 14/06/2023
	@param aOrdSep, Array, Datos de orden de separación. (Valor por referencia)
	@return 
	/*/
Function fOrdSepara(aOrdSep)
Local aAreaSC9 := {}

Default aOrdSep := {}

	aAreaSC9 := SC9->(GetArea())
	SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO+C9_BLEST+C9_BLCRED
	If SC9->(DbSeek(xFilial("SC9")+SD2->(D2_PEDIDO+D2_ITEMPV+D2_SEQUEN)));
		.And. SC9->C9_REMITO+SC9->C9_SERIREM+SC9->C9_ORDSEP == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_ORDSEP
			aadd(aOrdSep,{SD2->D2_ORDSEP,SC9->C9_ITEM,SD2->D2_PEDIDO})
	EndIf
	SC9->(RestArea(aAreaSC9))
Return

/*/{Protheus.doc} FATXMI030
	Función para agregar acciones en modificación de clientes - Mercado Internacional.
	@type  Function
	@author Luis Enríquez
	@since 11/07/2023
	@param	aButtons - Array con opciones. La variable se pasa por referencia (@aButtons)
	@return Nil.
	/*/
Function FATXMI030(aButtons)
	Default aButtons := {}

	If cPaisLoc == "MEX" .And. ExisteAlias("AIT")
		Aadd(aButtons,{"", { || MATA489( "SA1", SA1->(RecNo()), 4, 1) } ,STR0015}) //"Destinatarios"
	EndIf

Return Nil

/*/{Protheus.doc} FATXMI980
	Función para agregar acciones en modificación de clientes - Mercado Internacional.
	@type  Function
	@author Luis Enríquez
	@since 11/07/2023
	@param	oView - Objeto de la Vista de CRMA90
	@return Nil.
	/*/
Function FATXMI980(oView)
	Local bDest := { || MATA489( "SA1", SA1->(RecNo()), 4, 1) }

	If ExisteAlias("AIT")
		oView:addUserButton(OemToAnsi(STR0015),"MAGIC_BMP", bDest, OemToAnsi(STR0015),, {MODEL_OPERATION_UPDATE} ) //"Destinatarios"
	EndIf
Return Nil

/*/{Protheus.doc} LxCEDest
	Función que genera el nodo cce20:Destinatario en el XML y Cadena Original en el Complemento de Comercio exterior
	@type  Function
	@author Luis Enríquez
	@since 11/07/2023
	@param	cCliente - Caracter - Código de Cliente
	@param	cLoja - Caracter - Código de Tienda
	@param	cDestino - Caracter - Valor del Campo Destinos (F2_ACOPLA)
	@param	lCadena - Lógico - .T. genera Cadena Original y .F. genera XML
	@return cRet - Cadena Original o XML para el nodo cce20:Destinatario
	/*/
Function LxCEDest(cCliente, cLoja, cDestino, lCadena)
	Local aArea     := GetArea()
	Local cFilAIT   := xFilial("AIT")
	Local cRet      := ""
	Local nX        := "0
	Local cWhere    := ""
	Local cCodDes   := ""
	Local cAliasQry := GetNextAlias()
	Local cSalto    := CHR(13)+CHR(10)
	Local cSepara   := "|"
	Local aDest     := {}
	Local ComCE   := "cce20"

	Default cCliente := ""
	Default cLoja    := ""
	Default cDestino := ""
	Default lCadena  := .F.

	If ExisteAlias("AIT")	

		aDest := StrTokArr(cDestino, "|")

		For nX := 1 to Len(aDest)
			cCodDes += "'" + aDest[nX] + "'"
			If nX < Len(aDest)
				cCodDes += ","
			Endif
		Next nX

		cWhere += "% AIT_CODRES IN (" + cCodDes + ") AND "
		cWhere += "AIT_FILIAL = '" + cFilAIT + "' AND "
		cWhere += "AIT_CODCLI  = '" + cCliente + "' AND "
		cWhere += "AIT_LOJA = '" + cLoja + "' %"

		BeginSql Alias cAliasQry
			SELECT AIT_FILIAL, AIT_CODCLI, AIT_LOJA, AIT_CODRES, AIT_CODTRI, AIT_TIPO, AIT_REG, AIT_NUMEXT, AIT_NUMINT, AIT_COLON, AIT_LOCALI, AIT_MUNICI, AIT_ESTADO, AIT_PAIS, AIT_CODPOS, AIT_REF
			FROM %Table:AIT% AIT
			WHERE AIT.%notDel% AND
				%Exp:cWhere%
			ORDER BY AIT_FILIAL, AIT_CODCLI, AIT_LOJA, AIT_CODRES
		EndSql

		dbSelectArea(cAliasQry)
		(cAliasQry)->(DbGoTop())
		While (cAliasQry )->(!Eof())
			If lCadena //Cadena Origina
				//Destinatario
				If !Empty((cAliasQry)->AIT_CODTRI)
					cRet += Alltrim((cAliasQry)->AIT_CODTRI) + cSepara //NumRegIdTrib
				EndIf
				cRet += Alltrim(CFDCarEsp((cAliasQry)->AIT_TIPO,.T.)) + cSepara //Nombre
				
				//Domicilio
				cRet += Alltrim(CFDCarEsp((cAliasQry)->AIT_REG,.T.)) + cSepara  //Calle  
				If !Empty((cAliasQry)->AIT_NUMEXT)   
					cRet += Alltrim((cAliasQry)->AIT_NUMEXT) + cSepara //NumeroExterior
				EndIf
				If !Empty((cAliasQry)->AIT_NUMINT)
					cRet += Alltrim((cAliasQry)->AIT_NUMINT) + cSepara //NumeroInterior
				EndIf
				If !Empty((cAliasQry)->AIT_COLON)
					cRet += Alltrim(CFDCarEsp((cAliasQry)->AIT_COLON,.T.)) + cSepara //Colonia
				EndIf
				If !Empty((cAliasQry)->AIT_LOCALI)
					cRet += Alltrim(CFDCarEsp((cAliasQry)->AIT_LOCALI,.T.)) + cSepara //Localidad
				EndIf
				If !Empty((cAliasQry)->AIT_REF)
					cRet += Alltrim(CFDCarEsp((cAliasQry)->AIT_REF,.T.)) + cSepara //Referencia
				EndIf
				If !Empty((cAliasQry)->AIT_MUNICI)
					cRet += Alltrim(CFDCarEsp((cAliasQry)->AIT_MUNICI,.T.)) + cSepara //Municipio
				EndIf
				cRet += Alltrim((cAliasQry)->AIT_ESTADO) + cSepara //Estado
				cRet += Alltrim((cAliasQry)->AIT_PAIS) + cSepara //País
				cRet += Alltrim((cAliasQry)->AIT_CODPOS) + cSepara //CodigoPostal
			Else //XML
				cRet += '			<'+ComCE+':Destinatario Nombre="' + Alltrim(CFDCarEsp((cAliasQry)->AIT_TIPO,.T.)) + IIf(!Empty((cAliasQry)->AIT_CODTRI),'" NumRegIdTrib="' + Alltrim((cAliasQry)->AIT_CODTRI),"") + '">' + cSalto
				cRet +=	'				<'+ComCE+':Domicilio Calle="' + Alltrim(CFDCarEsp((cAliasQry)->AIT_REG,.T.)) + ;
					'" CodigoPostal="' + Alltrim((cAliasQry)->AIT_CODPOS) + ;
					IIf(!Empty((cAliasQry)->AIT_COLON),'" Colonia="' + Alltrim(CFDCarEsp((cAliasQry)->AIT_COLON,.T.)),"") + ;
					'" Estado="' + Alltrim((cAliasQry)->AIT_ESTADO) + ;
					IIf(!Empty((cAliasQry)->AIT_LOCALI),'" Localidad="' + Alltrim(CFDCarEsp((cAliasQry)->AIT_LOCALI,.T.)),"") + ;
					IIf(!Empty((cAliasQry)->AIT_REF),'" Referencia="' + Alltrim(CFDCarEsp((cAliasQry)->AIT_REF,.T.)),"") + ;
					IIf(!Empty((cAliasQry)->AIT_MUNICI),'" Municipio="' + Alltrim(CFDCarEsp((cAliasQry)->AIT_MUNICI,.T.)),"") + ;
					IIf(!Empty((cAliasQry)->AIT_NUMEXT),'" NumeroExterior="' + Alltrim((cAliasQry)->AIT_NUMEXT),"") + ;
					IIf(!Empty((cAliasQry)->AIT_NUMINT),'" NumeroInterior="' + Alltrim((cAliasQry)->AIT_NUMINT),"") + ;
					'" Pais="' + Alltrim((cAliasQry)->AIT_PAIS) + '"/>' + cSalto
				cRet += '			</'+ComCE+':Destinatario>' + cSalto
			EndIf
			(cAliasQry)->(dbskip())
		EndDo
		(cAliasQry)->(DBCloseArea())
	EndIf

	RestArea(aArea)
Return cRet

/*/{Protheus.doc} FxDelExp
	Función que elimina más de un espacio, para colocar solo en en una cadena de caracteres
	@type  Function
	@author Luis Enríquez
	@since 28/09/2023
	@param	cTexto - Caracter - Texto que será procesado para sustitur más de un espcio por un espacio
	@return cTxtRet - Caracter - Texto con solo un espacio entre palabras
/*/
Function FxDelExp(cTexto)
	Local cTxtRet := ""
	Local aCadTxt := {}
	Local nX      := 0
	Local nTam    := 0

	Default cTexto := ""

	aCadTxt := StrTokArr(cTexto, " ")

	nTam := Len(aCadTxt)

	For nX := 1 To nTam
		cTxtRet += aCadTxt[nX] + IIf(nX==nTam,""," ")
	Next nX
Return cTxtRet

/*/{Protheus.doc} fFilDocFis
	Verificar el modo de compartición de las tablas SF1, SF2, SD1 y SD2.
	@type Function
	@author luis.samaniego
	@since 26/10/2023
/*/
Function fFilDocFis()
Local lModAccess := .T.
Local cCompSD1 := ""
Local cCompSD2 := ""
Local cCompSF1 := ""
Local cCompSF2 := ""
Local cVersion := GetRpoRelease()

	If !(cVersion == "12.1.2310")
		Return lModAccess
	EndIf

	cCompSD1 := FwModeAccess("SD1",1) + FwModeAccess("SD1",2) + FwModeAccess("SD1",3)
	cCompSD2 := FwModeAccess("SD2",1) + FwModeAccess("SD2",2) + FwModeAccess("SD2",3)
	cCompSF1 := FwModeAccess("SF1",1) + FwModeAccess("SF1",2) + FwModeAccess("SF1",3)
	cCompSF2 := FwModeAccess("SF2",1) + FwModeAccess("SF2",2) + FwModeAccess("SF2",3)

	If !(cCompSF1 == cCompSD1) .Or. !(cCompSF2 == cCompSD2)
		lModAccess := .F.
	EndIf

	If !lModAccess
		If fExistsInf()
			Help(" ", 1, "COMPARTILHAMENTO", , STR0018, 2, 0,,,,,, {STR0019})
		Else
			If fFixComprt()
				Help(" ", 1, "COMPARTILHAMENTO", , STR0020, 2, 0,,,,,, {STR0021})
			EndIf
		EndIf
	EndIf
	
Return lModAccess

/*/{Protheus.doc} fExistsInf
	Verifica si hay información en la tabla SD2.
	@type  Static Function
	@author luis.samaniego
	@since 26/10/2023
/*/
Static Function fExistsInf()
Local aArea      := GetArea()
Local cTrbTemp   := GetNextAlias()
Local lRet       := .F.
	
	BeginSql alias cTrbTemp
		SELECT COUNT(SD2.D2_FILIAL) nReg
		FROM  %Table:SD2% SD2
	EndSql

	If (cTrbTemp)->nReg > 0
		lRet := .T.
	EndIf
	(cTrbTemp)->(DbCloseArea())

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} fFixComprt
	Actualiza el modo de compartición de la tabla SD2 a la compartición estándar.
	@type  Static Function
	@author luis.samaniego
	@since 26/10/2023
	Return lRet - Logico - .T. si fue actualizado el modo de compartición.
/*/
Static Function fFixComprt()
Local aArea := GetArea()
Local lRet := .F.

	DbSelectArea("SX2")
	dbSetOrder(1)
	If SX2->(MsSeek("SD2"))
		SX2->(RecLock("SX2"))
			SX2->X2_MODOEMP := FwModeAccess("SF2", 1)
			SX2->X2_MODOUN := FwModeAccess("SF2", 2)
			SX2->X2_MODO := FwModeAccess("SF2", 3)
		SX2->(MsUnLock())
		lRet := .T.
	EndIf

	RestArea(aArea)
Return lRet


/*/{Protheus.doc} RatVImpMI
	Ajusta valores decimales cuando se presentan difencias entre el valor total de un impuesto vs la suma del impuesto por ítems - Mercado Internacional.
	@type  Function
	@author luis.samaniego
	@since 05/04/2025
	@version 12.1.2410
	@param 
		aInfo, Array, Información de impuesto. [1]-Impuesto; [2]-Campo libro.
		nItem, Numeric, Numero ítem del documento.
		nAliq, Numeric, Alícuota del impuesto.
		nBase, Numeric, Valor de la base imponible del ítem.
		nMoneda, Numeric, Moneda del documento.
		nDivAlq, Numeric, Valor para dividir la alícuota de cálculo.
	@return nAuxVlr, Numeric, Valor del impuesto con el ajuste de decimales.
	/*/
Function RatVImpMI(aInfo, nItem, nAliq, nBase, nMoneda, nDivAlq)
Local nAuxVlr   := 0
Local nBaseT    := 0
Local nDecimais := 0
Local nValDif   := 0
Local nValDif1  := 0
Local nValorT   := 0
Local nVlrRat   := 0

Default aInfo := {}
Default nItem := 0
Default nAliq := 0
Default nBase := 0
Default nMoneda := 1
Default nDivAlq := 100

	If nItem > 0 .And. Len(aInfo) > 0 .And. MaFisFound()
		nDecimais := MsDecimais(nMoneda) //Decimales para la moneda seleccionada.
		nBaseT    := MaRetBasT(aInfo[2], nItem, nAliq) //Base total de impuesto

		nVlrRat := Round(nBaseT * (nAliq / nDivAlq), nDecimais) //Valor total de impuesto
		nAuxVlr := Round(nBase * (nAliq / nDivAlq), nDecimais) //Valor impuesto de item.
		nValorT := fSumVImpMI(aInfo, nItem, nAliq) + nAuxVlr //Suma el impuesto ya cálculado + impuesto del item

		/*En caso de presentar diferencias por redondeo, se realiza el ajuste de los valores decimales*/
		If nValorT <> nVlrRat
			nValDif := (nVlrRat - nValorT)
			nValDif1 := nValDif
			If nValDif < 0
				nValDif1 := (nValDif * -1)
			EndIf
			nCent := 1/(10 ** nDecimais)
			If nValDif1 >= nCent
				If nValDif > 0
					nAuxVlr += nValDif1
				Else
					nAuxVlr -= nValDif1
				EndIf
			EndIf
		EndIf
	EndIf

Return nAuxVlr


/*/{Protheus.doc} fSumVImpMI
	Obtiene la suma del impuesto en los ítems del documento fiscal - Mercado Internacional.
	@type  Function
	@author luis.samaniego
	@since 05/04/2025
	@version 12.1.2410
	@param
		aInfo, Array, Información de impuesto. [1]-Impuesto; [2]-Campo libro.
		nItem, Numeric, Numero ítem del documento.
		nAliq, Numeric, Alícuota del impuesto.
	@return nAuxVlr, Numeric, Total impuesto.
	/*/
Static Function fSumVImpMI(aInfo, nItem, nAliq)
Local nAuxVlr := 0
Local nItemNF := 0
Local cNumImp := ""
Local cFunName := FunName()

Default aInfo := {}
Default nItem := 0
Default nAliq := 0

	If Type("aCols") == "U"
		aCols := {}
	EndIf

	If nItem > 0 .And. Len(aInfo) > 0
		cNumImp := aInfo[2] //Campo libro fiscal
		For nItemNF := 1 To Len(aCols)
			If MaFisFound("IT", nItemNF) .And. !MaFisRet(nItemNF, 'IT_DELETED') .And. ((cFunName $ "MATA410" .And.  nItemNF < nItem) .Or. (!(cFunName $ "MATA410") .And. nItemNF <> nItem))
				If MaFisRet(nItemNF,'IT_ALIQIV'+cNumImp) == nAliq
					nAuxVlr += MaFisRet(nItemNF,'IT_VALIV'+cNumImp)
				Endif
			EndIf
		Next
	EndIf

Return nAuxVlr
