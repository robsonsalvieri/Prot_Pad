#INCLUDE "FATXPYME.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWLIBVERSION.CH'


//-------------------------------------------------------------------
/*/{Protheus.doc} FATXPYME
Función para validar series MyPyme de las facturas
de venda informado.
@param lConfirma, bolean, indica si se genera el documento
@param aNfArx, array, datos de los documentos como tipo monenda etc
@param  aFacs, array, datos de las series  usadas para generar los documentos
@param nSel, numerico, indica si se toma la moneda del pedido(1) o la moneda seleccionada (2)
@param nMonSel, numerico, moneda seleccionada
@param oJNFS, json, Moneda del pedido/remito
@param cPontoVend, character, punto de de venta
@return _lRet, bolean, indica si continua o no con la generación del documento
@author 
@since 09/04/2024
@version 1.0
@type funtion
/*/
//-------------------------------------------------------------------
Function FATXPYME(lConfirma,aNfArx,aFacs,nSel,nMonSel, oJNFS, cPontoVend)
Local _lRet		:= .F.  
Local cMsgCdto	:= ""
Local lRetCdto	:= .T.
Local aCol		:= {STR0001,STR0002,STR0003,STR0004} // "Nro de Linea","Serie","Factura","Error"
Local _cArea	:= GetArea()
Local aDatos	:= {}
Local nX 		:= 0
Local nMon		:= 1
Local aTasas:={}
Local cAgente:="" 
Local cProvent := ""
DEFAULT lConfirma:= .F.
DEFAULT aNfArx:={}
DEFAULT aFacs:={}
DEFAULT nSel:=1
DEFAULT nMonSel:=1
Default oJNFS := Nil
Default cPontoVend := ""

	If !isincallstack("a468nGera") .AND. lConfirma
	SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
	cAgente:=SUBSTR(SuperGetMV("MV_AGENTE",.T.,""),9,1)  
	For nX := 1 To Len(aFacs)
		IF SA1->(MsSeek(xFilial("SA1")+aFacs[nX][3]+aFacs[nX][4]))
			_lRet:=.T. // para el sig documento debe volver a empezar en true por si hubo un falso
							// Se verifica que la Serie ingresada corresponda a la Cond Iva del Cliente
			IF oJNFS:HasProperty(aNfArx[nX][1])
           		cProvent :=oJNFS[aNfArx[nX][1]]['PROVENT']
       		Endif				
			If !Empty(cAgente) .And. (cAgente$"I|X|F|M|E")
				If cAgente == "I"
					If SA1->A1_TIPO == "I" 
						If SA1->A1_EST <> "TF" .And. cProvent == "TF"
							If !(SUBSTR(aFacs[nX][1],1,1)$"E|X")   
								_lRet:=.F.   
							EndIf	
						Else
							If !(SUBSTR(aFacs[nX][1],1,1)$"A|B|M|X")   
								_lRet:=.F.   
							EndIf	
						EndIf	
					ElseIf SA1->A1_TIPO == "X"
						IF (SA1->A1_EST <> "TF" .Or. SA1->A1_EST == "TF") .And. cProvent <> "TF"
							If !(SUBSTR(aFacs[nX][1],1,1)$"B|X")
								_lRet:=.F.   
							EndIf
						ElseIf SA1->A1_EST == "TF"  .And. cProvent == "TF"	
							If !(SUBSTR(aFacs[nX][1],1,1)$"E|X")   
								_lRet:=.F.   
							EndIf
						Else
							If !(SUBSTR(aFacs[nX][1],1,1)$"X")   
								_lRet:=.F.   
							EndIf
						EndIf 	
					ElseIf SA1->A1_TIPO $ "F|S"
						If !(SUBSTR(aFacs[nX][1],1,1)$"B|X")   
							_lRet:=.F.   
						EndIf
					ElseIf SA1->A1_TIPO == "M"
						If !(SUBSTR(aFacs[nX][1],1,1)$"A|M|X")   
							_lRet:=.F.   
						EndIf
					ElseIf SA1->A1_TIPO == "E"
						If !(SUBSTR(aFacs[nX][1],1,1)$"E")    
							_lRet:=.F.   
						EndIf				  
					EndIf	
				ElseIf cAgente $ "F"
					If !(SUBSTR(aFacs[nX][1],1,1)$"C")
						_lRet:=.F.   
					EndIf
				ElseIf cAgente $ "M"
					If SA1->A1_TIPO == "E"
						If !(SUBSTR(aFacs[nX][1],1,1)$"E|X")
							_lRet:=.F.   
						EndIf
					ElseIf SA1->A1_TIPO <> "E"
						If !(SUBSTR(aFacs[nX][1],1,1)$"C|X")
							_lRet:=.F.   
						EndIf
					EndIf
				ElseIf cAgente=='E'
					If SA1->A1_TIPO == "E"
						If !(SUBSTR(aFacs[nX][1],1,1)$"E|X")
							_lRet:=.F.   
						EndIf
					ElseIf SA1->A1_TIPO <> "E"
						If !(SUBSTR(aFacs[nX][1],1,1)$"C|X")
							_lRet:=.F.   
						EndIf
					EndIf	
				EndIf
			Else	
				If SA1->A1_TIPO $ "I|M"
					if !(SUBSTR(aFacs[nX][1],1,1)$"A|E")   
					_lRet:=.F.   
					ENDIF
				ElseIf SA1->A1_TIPO $ "E" 
					if !(SUBSTR(aFacs[nX][1],1,1)$"E")
						_lRet:=.F.   
					ENDIF
				Else 
					if !(SUBSTR(aFacs[nX][1],1,1)$"B|C|X")
						_lRet:=.F.   
					ENDIF
				ENDIF
			EndIf
			If _lRet
				IF SUBSTR(aFacs[nX][1],1,1)$"A|B|C"
					IF nSel==2 //aParams[22]==2  // Se Factura con la moneda especificada
						nMon=nMonSel //aParams[23]
					ELSE   // Se factura con la moneda del pedido - Se extrae de la cadena 	QUEBRA
						If oJNFS:HasProperty(aNfArx[nx][1])
							nMon := oJNFS[aNfArx[nX][1]]['MONEDA']  // Se extrae la moneda de la cadena que usa para agrupar los remitos o Pedidos  A PARTIR DE VERSION 33
						EndIf
					ENDIF
					aTasas:=fTasas()
												//cEsp, cSer,         cPDV,                   nMonDoc, nTxDoc, nValor, cMsg, tamaño)
					lRetCdto := ARVLDCDT( aFacs[nX][1], cPontoVend, nMon,aTasas[nMon][2], aFacs[nX][14], @cMsgCdto,SA1->A1_TAMEMP, "01")
						
					If !lRetCdto
						cMsgCdto := Replace(cMsgCdto, CHR(13)+CHR(10), " ")
						aAdd(aDatos, {cValToChar(nX), aFacs[nX][1], aFacs[nX][2], cMsgCdto})
					EndIf
				ENDIF
			EndIf
			If !_lRet
				aAdd(aDatos, {cValToChar(nX), aFacs[nX][1], aFacs[nX][2], STR0006}) // Digite una Serie, de acuerdo al Tipo de Cliente."
			EndIf
		EndIf
		
	Next nX
	ENDIF
	RestArea(_cArea)
	/* Se muestra un Dialogo con los errores de Serie encontrados y las sugerencias */	
	If !Empty(aDatos)
		GENX0001(STR0008,aCol, aDatos, 0.75, 0.75) // "Errores encontrados"
		_lRet := .F. 
	EndIf
Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ARDCCDTO
Función para validar el tamaño del cliente y si el documenro supera el Monto minimo para MiPymes = 146.885
@param nVlrTotal, number, indica si se genera el documento
@param cTam, string, tamaño cliente (1.-MiPyME,2.-MiPyME Adherida,3.-Empresa  Grande,4.-Empresa grande adherida)
@return lRet, bolean, indica si cumple con los citerios de tamaño y valor del monto minimo
@author 
@since 09/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ARDCCDTO(nVlrTotal,cTam)

Local lRet := .T.
DEFAULT nVlrTotal:=0
DEFAULT cTam:=""

If !(cTam $ "2|3|4")
	lRet := .F.
ElseIf nVlrTotal == 0 .and. cTam $ "2|3|4" 
	lRet := .T.
Else
	lRet := nVlrTotal >= fGetVal()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ARSERCDT
Función que Devuelve la series y la RG1415 .
@param cSer, string, serie a usar para generar el documento
@param cPDV, string, punto de venta
@param lEsCdto, bolean, indica si la RG1415 es menor o mayor a 200 (empresa MiPyme)
@param aDatRet, array, Arreglo pasado por referencia para obtener serie y RG1415 ejemplo: {'A','201'}
@param cTipDocu, character, Tipo documento (01-NF, 02-NDC, 04-NCC)
@author 
@since 09/04/2024
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function ARSERCDT(cSer, cPDV, lEsCdto, aDatRet, cTipDocu)

Local cQuery   := ""
Local aArea    := GetArea()
Local cAlias   := ""
Local oStmt    := Nil
Local cCodEsp  := "1" //NF
Local nOrd     := 1

DEFAULT cSer    := ""
DEFAULT cPDV    := ""
DEFAULT lEsCdto := .F.
DEFAULT aDatRet := {}
DEFAULT cTipDocu := "01"

    cQuery := "SELECT FP_SERIE, FP_RG1415 "
	cQuery += "FROM "  + RetSqlName("SFP") + " "
	cQuery += "WHERE FP_FILIAL  = ? "
	cQuery += "AND FP_FILUSO  = ? "
	cQuery += "AND SUBSTRING(FP_SERIE,1,1) = ? "
	cQuery += "AND FP_ESPECIE = ? "
	cQuery += "AND FP_PV      = ? "
	cQuery += "AND FP_ATIVO   = ? "
	If lEsCdto
		cQuery += "AND FP_RG1415  > ? "
	Else
		cQuery += "AND (FP_RG1415 <= ? OR FP_RG1415 = ?) "
	EndIf
	cQuery += " AND D_E_L_E_T_ = ? "

	If cTipDocu == "02"
		cCodEsp := "5" //NDC
	ElseIf cTipDocu == "04"
		cCodEsp := "4" //NCC
	EndIf

	cQuery := ChangeQuery(cQuery)
	oStmt  := FWExecStatement():New(cQuery)

	oStmt:SetString(nOrd++, xFilial("SFP"))   // FP_FILIAL
	oStmt:SetString(nOrd++, cFilAnt)          // FP_FILUSO
	oStmt:SetString(nOrd++, Left(cSer, 1))    // SUBSTRING(FP_SERIE,1,1)
	oStmt:SetString(nOrd++, cCodEsp)          // FP_ESPECIE
	oStmt:SetString(nOrd++, cPDV)             // FP_PV
	oStmt:SetString(nOrd++, "1")              // FP_ATIVO

	If lEsCdto
		oStmt:SetString(nOrd++, "200")        // FP_RG1415 > '200'
	Else
		oStmt:SetString(nOrd++, "200")        // FP_RG1415 <= '200'
		oStmt:SetString(nOrd++, " ")           // FP_RG1415 = ''
	EndIf

	oStmt:SetString(nOrd++, " ")              // D_E_L_E_T_

	cAlias := oStmt:OpenAlias()

	dbSelectArea(cAlias)

	While (cAlias)->(!EOF())
		AADD(aDatRet, {(cAlias)->FP_SERIE, (cAlias)->FP_RG1415})
		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(dbCloseArea())

	oStmt:Destroy()
	oStmt := Nil

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ARVLDCDT
Función para validar los datos de la serie
@param cSer, string, serie usada
@param cPDV, string, punto de venta
@param nMonDoc, moneda del documento
@param nTxDoc, tasa de la moneda del documento
@param nValor, valor del documento
@param cMsg, string, usado para obtener mensajes de errores
@param cTam, string, tamaño del cliente (1.-MiPyME,2.-MiPyME Adherida,3.-Empresa  Grande,4.-Empresa grande adherida)
@param cTipDocu, character, Tipo documento
@return lRet, bolean, indica si continua o no con la generación del documento 
@author 
@since 09/04/2024
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
Static Function ARVLDCDT(cSer, cPDV, nMonDoc, nTxDoc, nValor, cMsg, cTam, cTipDocu)

Local lRet		:= .T.
Local lEsCdto   :=.F.
Local aDatDoc	:={}
Local nValBrut  :=0

Default cSer		:="" 
Default cPDV		:="" 
Default nMonDoc		:=0 
Default nTxDoc 		:=0 
Default nValor 		:=0 
Default cMsg		:="" 
DEFAULT cTam        :=""
DEFAULT cTipDocu := "01"


	If nMonDoc = 1 
		nValBrut := nValor 
	else 
		nValBrut := xMoeda(nValor,nMonDoc,1,dDataBase,MsDecimais(nMonDoc),Nil,nTxDoc)
	EndIf
	
	// Verifico si es factura de cdto	
	lEsCdto := ARDCCDTO(nValBrut,cTam)
	
	// Guardo la serie y el tp RG1415 segun el comprobante
	ARSERCDT(cSer, cPDV, lEsCdto, @aDatDoc, cTipDocu)
	
	// Verifico si la serie es la correcta
	lRet := fVerOk(lEsCdto, cSer, aDatDoc, @cMsg)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fGetVal
Función que Devuelve el Monto minimo para MiPymes = 146,885
@return nVal, valor, Monto minimo para MiPymes
@author 
@since 09/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fGetVal()

Local nVal := SuperGetMV("MV_VLRFCE",.F.,146885) // Monto minimo para MiPymes ARS 146.885


Return nVal

//-------------------------------------------------------------------
/*/{Protheus.doc} fVerOk
Función para verificar los errores que informados en aDatDoc

@param  lEsCdto,boolena, indica si es mipyme 
@param  cSer,string, serie
@param  aDatDoc,array, datos de errores
@param  cMsg, string, mensaje a devolver junto con el error
@return lRet, bolean, indica si existe errores
@author 
@since 09/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function fVerOk(lEsCdto, cSer, aDatDoc, cMsg)

Local lRet		:= .T.
Local nReg:=0
Local nPos:=0

DEFAULT lEsCdto :=.F.
DEFAULT cSer	:="" 
DEFAULT aDatDoc :={}
DEFAULT cMsg    :=""

nReg:=len(aDatDoc)

IF nReg>0
 nPos:= Ascan(aDatDoc,{ |x| x[1] == cSer})
EndIf

If lEsCdto
	If nReg==0 
		lRet	:= .F.
		cMsg	:= STR0009
	ElseIf  nPos==0 
		lRet	:= .F.
		cMsg	:= STR0010+; // "El documento que se deberá cargar es de tipo MyPyME "
				STR0011 +cValToChar(fGetVal())+STR0012+; // "(Supera los $ "   //
				STR0013+ getSer(aDatDoc) // "Para ello puede usar la(s) serie(s): "
	EndIf
Else

	If nPos==0 //cSer
		lRet 	:= .F.
		cMsg	:= STR0014+; // "El documento que se deberá cargar no es de tipo MyPyME "
				STR0015 + getSer(aDatDoc) // "Para ello puede usar la(s) serie(s): "
				
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} getSer
Función para concatenar en un strin las series que se obtiene  en el arreglo aDat

@param  aDat,array, datos de las series donde puede venir por arreglo la sig estructura {{"A","200"},"AN",""}
@return cMsg, cadena concatenada, donde se guardan las series del arreglo aDat
@author 
@since 09/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function getSer(aDat)

Local nX:=0
Local cMsg:=""

Default aDat:={}

	For nX := 1 To Len(aDat)
		cMsg+=" '"+aDat[nX][1]+"',"
	Next nX

	IF cMsg<>""
		cMsg:=SUBSTR(cMsg,1,len(cMsg)-1)     
	EndIf

return cMsg
/****/

//-------------------------------------------------------------------
/*/{Protheus.doc} GENX0001
Función para mostrar pantalla de errores

@param  cTitulo, string, titulo
@param  aColumns, array,arreglo de columnas  {"Nro de Linea","Serie","Factura","Error"}
@param  aDatos,   array, arreglo de datos de error
@param  nPorcAncho,numeric, ancho ventana
@param  nPorcAlto, numeric, altura ventana

@author 
@since 09/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GENX0001(cTitulo, aColumns, aDatos, nPorcAncho, nPorcAlto)

Local oTwbr 	:= Nil
Local oDlg	:= Nil
Local aSize 	:= MsAdvSize()
Local nOpcA	:= 0

Private oOK	:= LoadBitmap( GetResources(), "WFCHK" )
Private oNO 	:= LoadBitmap( GetResources(), "WFUNCHK" )

DEFAULT cTitulo	 :="" 
DEFAULT aColumns :={}
DEFAULT aDatos	 :={} 
DEFAULT nPorcAncho:=1 
DEFAULT nPorcAlto :=1 



If Len(aDatos) > 0 
	
		aSize[5] := aSize[5] * nPorcAncho	// Anchura
		aSize[6]	:= aSize[6] * nPorcAlto	// Altura
	
		IF !isBlind()
			DEFINE MSDIALOG oDlg FROM aSize[7],000 TO aSize[6],aSize[5] TITLE cTitulo PIXEL

			oTwbr:= TwBrowse():New(0,0,0,0,,aColumns,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oTwbr:Align := CONTROL_ALIGN_ALLCLIENT
			oTwbr:SetArray(aDatos)
			oTwbr:bLine := &(getBLine(aDatos[oTwbr:nAt]))

			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ || nOpcA:=1,oDlg:End() },{|| nOpcA:=0,oDlg:End()},,) CENTERED
		EndiF
	
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} getBLine
Función para obtener datos de arreglo y construir linea 

@param  cTitulo, array
@return cRet, string, datos del error y datos de la linea para mostrar información
@author 
@since 09/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function getBLine(aArray)

Local cRet 		:= "" 
Local nX	

DEFAULT aArray:={}

For nX := 1 To Len(aArray)
	If Len(cRet) > 0
		cRet += " , "
	EndIf

	Do Case
		Case nX == 1 .And. ValType(aArray[nX]) == "L"
			cRet += "IIF(aDatos[oTwbr:nAt,"+Alltrim(Str(nX))+"],oOk,oNo)"
		Case ValType(aArray[nX]) == "N"
			cRet += "Transform(aDatos[oTwbr:nAt,"+AllTrim(Str(nX))+"],'@E 99,999,999,999.99')"
		Otherwise
			cRet += "aDatos[oTwbr:nAt,"+AllTrim(Str(nX))+"]"
	EndCase
Next

Return "{|| {" + cRet + " } }" 

//-------------------------------------------------------------------
/*/{Protheus.doc} fTasas
Función para obtener las tasas de las monedas
@return aTxMoedas, array, contiene las tasas de las monedas
@author 
@since 14/05/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fTasas()

Local nC := MoedFin()
Local nA := 0
Local cMoedaTx	:= ""
Local aTxMoedas := 	{}

Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
For nA	:=	2	To nC
	cMoedaTx	:=	Str(nA,IIf(nA <= 9,1,2))
	If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
		Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),RecMoeda(dDataBase,nA),PesqPict("SM2","M2_MOEDA"+cMoedaTx) })
	Else
		Aadd(aTxMoedas,{1,nA,PesqPict("SM2","M2_MOEDA1")})
	Endif
Next

Return aTxMoedas


//-------------------------------------------------------------------
/*/{Protheus.doc} FVASERPYME
Función para revisar la serie del documento de acuerdo al MV_AGENTE y el tipo de cliente o proveedor.
@param cCodCl, caracter, codigo del cliente
@param cLoja, caracter, tienda del cliente informada en el documento
@param cSer, caracter, serie del documento a validar
@param cPv, caracter, punto de venta informada en el documento
@param nMon, numerico, moneda informada en el documento/seleccionada
@param cEstDoc, caracter, provincia del documento
@param nValTot, numerico, valor total del documento
@param cNudo, caracter, numero del documento
@param cLetSeri, caracter, Letra inicial de la serie seleccionada
@param cAliasCF, caracter, Tabla de cliente/proveedor (SA1/SA2)
@return _lRet, calógico, Define si se debe continuar con el proceso o si hubo algun error previo
@author brenda.ramirez
@since 14/07/2026
@version 1.0
/*/
Function FVASERPYME(cCodCl,cLoja,cSer,cPv,nMon,cEstDoc,nValTot,cNudo,cLetSeri,cAliasCF)
Local lCl 		:= .F.
Local _lRet		:= .T. 
Local cAgente	:= SUBSTR(SuperGetMV("MV_AGENTE",.T.,""),9,1) 
Local cTipCl	:= ""
Local cEstCl	:= ""
Local cTamEm	:= ""
Local aArea1	:= GetArea()
Default cCodCl	:= ""
Default cLoja	:= ""
Default cSer	:= ""
Default cPv		:= ""
Default nMon	:= 1
Default cEstDoc	:= ""
Default nValTot	:= 0
Default cNudo	:= ""
Default cLetSeri:= ""
Default cAliasCF:= ""

	IF !empty(cCodCl)

		If UPPER(cAliasCF) == "SA1"
			SA1->(DbSetOrder(1))
			lCl:= SA1->(MsSeek(xFilial("SA1")+cCodCl+cLoja)) //Verifica que exista el cliente y obtiene su información
			If lCl
				cTipCl := SA1->A1_TIPO
				cEstCl := SA1->A1_EST
				cTamEm := SA1->A1_TAMEMP
			EndIf
		EndIf
		RestArea(aArea1)
		IF lCl .And. !empty(cTamEm) // valida el cliente de acuerdo al indice: A1_FILIAL+A1_COD+A1_LOJA
			// Se verifica que la Serie ingresada corresponda a la Cond Iva del Cliente				
			If !Empty(cAgente) .And. (cAgente$"I|X|F|M|E")
				If cAgente == "I"
					If cTipCl == "I" 
						If cEstCl <> "TF" .And. cEstDoc == "TF"
							If !(cLetSeri$"E|X")   
								_lRet:=.F.   
							EndIf	
						Else
							If !(cLetSeri$"A|B|M|X")   
								_lRet:=.F.   
							EndIf	
						EndIf	
					ElseIf cTipCl == "X"
						IF (cEstCl <> "TF" .Or. cEstCl == "TF") .And. cEstDoc <> "TF"
							If !(cLetSeri$"B|X")
								_lRet:=.F.   
							EndIf
						ElseIf cEstCl == "TF"  .And. cEstDoc == "TF"	
							If !(cLetSeri$"E|X")   
								_lRet:=.F.   
							EndIf
						Else
							If !(cLetSeri$"X")   
								_lRet:=.F.   
							EndIf
						EndIf 	
					ElseIf cTipCl $ "F|S"
						If !(cLetSeri$"B|X")   
							_lRet:=.F.   
						EndIf
					ElseIf cTipCl == "M"
						If !(cLetSeri$"A|M|X")   
							_lRet:=.F.   
						EndIf
					ElseIf cTipCl == "E"
						If !(cLetSeri$"E")    
							_lRet:=.F.   
						EndIf				  
					EndIf	
				ElseIf cAgente $ "F"
					If !(cLetSeri$"C")
						_lRet:=.F.   
					EndIf
				ElseIf cAgente $ "M"
					If cTipCl == "E"
						If !(cLetSeri$"E|X")
							_lRet:=.F.   
						EndIf
					ElseIf cTipCl <> "E"
						If !(cLetSeri$"C|X")
							_lRet:=.F.   
						EndIf
					EndIf
				ElseIf cAgente=='E'
					If cTipCl == "E"
						If !(cLetSeri$"E|X")
							_lRet:=.F.   
						EndIf
					ElseIf cTipCl <> "E"
						If !(cLetSeri$"C|X")
							_lRet:=.F.   
						EndIf
					EndIf	
				EndIf
			Else	
				If cTipCl $ "I|M"
					if !(cLetSeri$"A|E")   
					_lRet:=.F.   
					ENDIF
				ElseIf cTipCl $ "E" 
					if !(cLetSeri$"E")
						_lRet:=.F.   
					ENDIF
				Else 
					if !(cLetSeri$"B|C|X")
						_lRet:=.F.   
					ENDIF
				ENDIF
			EndIf
			If !_lRet
				//Help: ERSERTC  Problema: La serie informada no corresponde con el tipo de cliente   Solucion: Digite una Serie, de acuerdo al Tipo de Cliente.
				Help(" ",1,"ERSERTC",,STR0016, 2, 0, , , , , , {STR0006}) 
			EndIf
		EndIf
		
	EndIf
	FWFreeArray(aArea1)

Return _lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FVAMONPYME
Función para validar el monto del documento de acuerdo al parámetro MV_VLRFCE
@param cCodCl, caracter, codigo del cliente
@param cLoja, caracter, tienda del cliente informada en el documento
@param cSer, caracter, serie del documento a validar
@param cPv, caracter, punto de venta informada en el documento
@param nMon, numerico, moneda informada en el documento/seleccionada
@param cEstDoc, caracter, provincia del documento
@param nValTot, numerico, valor total del documento
@param cNudo, caracter, numero del documento
@param cLetSeri, caracter, Letra inicial de la serie seleccionada
@param cAliasCF, caracter, Tabla de cliente/proveedor (SA1/SA2)
@param cTipDocu, character, Tipo documento
@return _lRet, calógico, Define si se debe continuar con el proceso o si hubo algun error previo
@author brenda.ramirez
@since 14/07/2026
@version 1.0
@type function
/*/
Function FVAMONPYME(cCodCl,cLoja,cSer,cPv,nMon,cEstDoc,nValTot,cNudo,cLetSeri,cAliasCF,cTipDocu)
Local lCl 		:= .F.
Local lRetCdto	:= .F.
Local _lRet		:= .T. 
Local aTasas	:= {} 
Local cTamEm	:= ""
Local cMsgCdto	:= ""
Local aArea2	:= GetArea()
Default cCodCl	:= ""
Default cLoja	:= ""
Default cSer	:= ""
Default cPv		:= ""
Default nMon	:= 1
Default cEstDoc	:= ""
Default nValTot	:= 0
Default cNudo	:= ""
Default cLetSeri:= ""
Default cAliasCF:= ""
Default cTipDocu := "01"

	IF !empty(cCodCl)
		//Verifica que exista el cliente de acuerdo al indice: A1_FILIAL+A1_COD+A1_LOJA y obtiene su información 
		If cAliasCF == "SA1"
			SA1->(DbSetOrder(1))
			lCl:= SA1->(MsSeek(xFilial("SA1")+cCodCl+cLoja)) 
			If lCl
				cTamEm := SA1->A1_TAMEMP
			EndIf
		EndIf
		RestArea(aArea2)
		//Valida que se haya obtenido información del cliente y que sea de tipo MyPyme
		IF lCl .And. !empty(cTamEm) 		
			If _lRet
				IF cLetSeri$"A|B|C"
					aTasas:=fTasas()
					lRetCdto := ARVLDCDT(cSer, cPv, nMon, aTasas[nMon][2], nValTot, @cMsgCdto, cTamEm, cTipDocu)
					If !lRetCdto 
						cMsgCdto := Replace(cMsgCdto, CHR(13)+CHR(10), " ")
						//El help puede tener dos posibles valores:
						//1 -> Help: ERSERMON  Problema: El documento por generar no es de tipo MyPyME Para ello puede usar la(s) serie(s):   Solucion: Informar una serie valida para el tipo de documento generado
						//2 -> Help: ERSERMON  Problema: El documento por generar es de tipo MyPyME Para ello puede usar la(s) serie(s):   Solucion: Informar una serie valida para el tipo de documento generado
						Help(" ",1,"ERSERMON",,cMsgCdto, 2, 0, , , , , , {STR0017}) 
						_lRet:= .F.
					EndIf
				ENDIF
			EndIf
		EndIf
	EndIf
	FWFreeArray(aTasas)
	FWFreeArray(aArea2)
Return _lRet
