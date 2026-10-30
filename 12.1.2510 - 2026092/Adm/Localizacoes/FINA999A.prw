#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'fwbrowse.ch'
#include 'tlpp-object.th'
#include 'fina999.ch'

Static aEOP 	:= {}
Static aMOE 	:= {}
Static aSOP 	:= {}
Static aTIT 	:= {}
Static aPAG 	:= {}
Static aTER 	:= {}
Static aFJR 	:= {}
Static aRIVA 	:= {}
Static aRIB 	:= {}
Static aRSUS 	:= {}
Static aRSLI 	:= {}
Static aRISI 	:= {}
Static aRGAN 	:= {}
Static aHdrFJR	:= {}
Static aHdrTIT	:= {}
Static aHdrPAG	:= {}
Static aHdrTER	:= {}
Static aHdrRIVA := {}
Static aHdrRIB  := {}
Static aHdrRSUS := {}
Static aHdrRSLI := {}
Static aHdrRISI := {}
Static aHdrRGAN := {}

/*/{Protheus.doc} VlLinF999
	Valida línea de formas de pago documentos propios
	@author ARodriguez
	@since 07/07/2025
	@version 12.1.2310
	@param 
		lF850 - lógico - indica si la información viene de la rutina FINA850 o FINA085A
	@return 
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Function VlLinF999(lF850, lPA)
	Local oModel		:= Nil
	Local lRet			:= .F.
	Local lFree			:= .F.

	Default lF850 	:= .F.
	Default lPA 	:= .F.

	If lF850
		GetHdrCols(lF850, {}, aPagos, lPA)
		oModel := LdF999F850()
		lRet   := VLineaF999(oModel, "PAG_DETAIL")
	Else
		GetHdrCols(lF850, {}, aPagos)
		oModel := LdF999F085()
		lRet   := VLineaF999(oModel, "PAG_DETAIL")
		lFree  := .T.
	EndIf
	
	oModel:DeActivate()
	FreeHdrCol(lFree)
	
Return lRet

/*/{Protheus.doc} VlTudoF999
	Valida modelo = TudoOk
	@author ARodriguez
	@since 07/07/2025
	@version 12.1.2310 y superiores
	@param 
		lF850 - lógico  - indica si la información viene de la rutina FINA850 o FINA085A
		aSE2  - arreglo - variable que contiene información sobre títulos financieros, documentos propios, documentos de terceros y retenciones
	@return 
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Function VlTudoF999(lF850, aSE2, lPA)
	Local oModel		:= Nil
	Local lRet			:= .F.
	Local lFree			:= .F.

	Default lF850 	:= .F.
	Default aSE2    := {}
	Default lPA     := .F.

	If lF850
		GetHdrCols(lF850, aSE2, aPagos, lPA)
		oModel := LdF999F850()
		lRet   := ValidaF999(oModel)
	Else
		GetHdrCols(lF850, aSE2, aPagos)
		oModel := LdF999F085()
		lRet   := ValidaF999(oModel)
		lFree  := .T.
	EndIf

	oModel:DeActivate()
	FreeHdrCol(lFree)

Return lRet

/*/{Protheus.doc} F999Grava
	Carga el modelo FINA999 y realiza la operación de grabado de las rutinas FINA850 y FINA085A
	@author carlos.espinoza
	@since 12/11/2025
	@version 12.1.2310 y superiores
	@param 
		lF850     - lógico    - indica si la información viene de la rutina FINA850 o FINA085A
		aSE2      - arreglo   - variable que contiene información sobre títulos financieros, documentos propios, documentos de terceros y retenciones
		lPA       - lógico    - Indica si es pago anticipado
		oJCotiz   - objeto    - Objeto que contiene la cotización del título
		nOps      - numérico  - Orden de pago actual a grabar del ciclo aPagos
		nMoedaRet - numérico  - Moneda para grabado de retención
		nTxPromed - numérico  - Tasa promedio de todos los títulos financieros de una OP
		aTxProm   - arreglo   - Arreglo de tasas configuradas en la tabla SM2
		cSolFun   - caracter  - Solicitación de fondo
	@return 
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Function F999Grava(lF850, aSE2, lPA, oJCotiz, nOps, nMoedaRet, nTxPromed, aTxProm, cSolFun)
	Local oModel		:= Nil
	Local lRet			:= .F.
	Local lFree 		:= .F.

	Default lF850 		:= .F.
	Default aSE2    	:= {}
	Default lPA     	:= .F.
	Default oJCotiz 	:= JsonObject():New()
	Default nOps 		:= 0
	Default nMoedaRet 	:= 1
	Default nTxPromed 	:= 1
	Default aTxProm 	:= {}
	Default cSolFun 	:= ""

	lFree := Len(aSE2) == nOps

	If lF850
		GetHdrCols(lF850, aSE2, aPagos, lPA, oJCotiz, nOps, nMoedaRet, nTxPromed, aTxProm, cSolFun)
		oModel := LdF999F850()
		lRet   := ValidaF999(oModel)
	EndIf

	If lRet
		oModel:CommitData()
	EndIf

	oModel:DeActivate()
	FreeHdrCol(lFree)

Return lRet

/*/{Protheus.doc} GetHdrCols
	Carga las variables que vienen de la FINA850 y FINA085A a las transforma en variables aHeader y aCols que facilitan el llenado de los modelos
	@type  Static Function
	@author carlos.espinoza
	@since 13/08/2025
	@version 12.1.2310 y superior
	@param 
		lF850     - lógico    - indica si la información viene de la rutina FINA850 o FINA085A
		aSE2      - arreglo   - variable que contiene información sobre títulos financieros, documentos propios, documentos de terceros y retenciones
		aPagos    - arreglo   - variable que contiene información de los pagos a generar de cada orden de pago
		lPA       - lógico    - Indica si es pago anticipado
		oJCotiz   - objeto    - Objeto que contiene la cotización del título
		nOps      - numérico  - Orden de pago actual a grabar del ciclo aPagos	
		nTxPromed - numérico  - Tasa promedio de todos los títulos financieros de una OP
		aTxProm   - arreglo   - Arreglo de tasas configuradas en la tabla SM2	
		cSolFun   - caracter  - Solicitación de fondo
	@return 
/*/
Static Function GetHdrCols(lF850, aSE2, aPagos, lPA, oJCotiz, nOps, nMoedaRet, nTxPromed, aTxProm, cSolFun)
Local nX			 := 0
Local nI 			 := 0
Local nY 			 := 0
Local nD 			 := 0
Local nP 			 := 0
Local nLen			 := 0
Local lGrava    	 := IsInCallStack("F850Grava") .Or. IsInCallStack("Fa085Grava")
Local lFormVld 		 := IsInCallStack("F850VldOPs")
Local lPa085a   	 := IsInCallStack("A085APgAdi")
Local cOrdPgo   	 := ""
Local lCCR      	 := .F.
Local oJTxProm		 := JsonObject():New()
Local aMonedasOp	 := Array(MoedFin())
Local cCotiz		 := ""
Local cTxProm		 := ""
Local cApro			 := ""

Default lF850	 	 := .F.
Default aSE2	 	 := {}
Default aPagos  	 := {}
Default lPA  	 	 := .F.
Default oJCotiz  	 := JsonObject():New()
Default nOps 	 	 := 0
Default nMoedaRet 	 := 1
Default nTxPromed 	 := 1
Default aTxProm 	 := {}
Default cSolFun 	 := ""

	GetHeaders()

	If lF850

		oJTxProm['txprom'] := aTxProm

		If !lAutomato .And. lGrava .And. !lPA
			lCCR := lProcCCR
		EndIf

		If IsInCallStack("F850PgAdi")
			cApro := cAprov	
		EndIf

		//Encabezado de orden de pago
		If !lPA .And. !IsInCallStack("F850LNOK")
			aEOP := {{nNumOrdens, nValOrdens, cMoeda, cOpcElt, nMoedaCor, lPA, 0, "", lShowPOrd, lCCR}}
		Else
			aEOP := {{nNumOrdens, 0, "", cOpcElt, nMoedaCor, lPA, 0, "", lShowPOrd, lCCR, cApro}}
		EndIf
		
		If lGrava
			For nI := 1 To Len(aTxMoedas)
				AADD(aMOE,{Alltrim(STR(nI)),aTxMoedas[nI][1],aTxMoedas[nI][2],aTxMoedas[nI][3]})
			Next

			For nI := 1 To Len(aMonedasOp)
				AADD(aSOP, {cOrdPago, nI, 0})
			Next

			cCotiz := oJCotiz:ToJson()
			If Len(cCotiz) <= 255
				aEOP[1][8] := cCotiz //COTIZ
			EndIf
		EndIf

		//Si nOps es cero, se validan todos los registros de aPagos, si tiene valor se toma encuenta únicamente esa posición/orden de pago
		nP   := IIF(nOps > 0, nOps, 1)
		nLen := IIF(nOps > 0, nOps, Len(aPagos))

		//Detalle de las ordenes de pago
		For nX := nP To nLen
			aAdd(aFJR, Array(38))
			nD := Len(aFJR)
			aFJR[nD,  1] := aPagos[nX, 1]  //H_OK
			aFJR[nD,  2] := aPagos[nX, 2]  //H_FORNECE
			aFJR[nD,  3] := aPagos[nX, 3]  //H_LOJA
			aFJR[nD,  4] := aPagos[nX, 4]  //H_NOME
			aFJR[nD,  5] := aPagos[nX, 5]  //H_NF
			aFJR[nD,  6] := aPagos[nX, 6]  //H_NCC_PA
			aFJR[nD,  7] := aPagos[nX, 7]  //H_TOTAL
			aFJR[nD,  8] := aPagos[nX, 16] //H_PORDESC
			aFJR[nD,  9] := aPagos[nX, 18] //H_DESCVL
			aFJR[nD, 10] := aPagos[nX, 15] //H_TOTALVL
			aFJR[nD, 11] := IIF(!Empty(aPagos[nX, 21]), aPagos[nX, 21], aPagos[1, 21]) //H_NATUREZA

			If Empty(aFJR[nD, 11]) .And. lPA
				aFJR[nD, 11] := cNatureza
			EndIf

			aFJR[nD, 12] := 0 //NSALDOPGOP
			aFJR[nD, 13] := 0 //NTOTDOCTERC
			aFJR[nD, 14] := 0 //NTOTDOCPROP

			If lGrava
				cOrdPgo := cOrdPago
				aFJR[nD, 15] := cOrdPgo		    //FJR_ORDPAG
				aFJR[nD, 16] := xFilial("FJR")  //FJR_FILIAL
				aFJR[nD, 17] := dDataBase 	    //FJR_EMISSA
				aFJR[nD, 18] := cLiquid 	  	//CLIQUID
				aFJR[nD, 19] := cIDProc			//CIDPROC
				aFJR[nD, 20] := cNumOp 	   	    //NUMOP
				aFJR[nD, 21] := IIF(lPa, cCF, cTes) //TES
				aFJR[nD, 22] := cProv 	   		//PROVIN
				aFJR[nD, 23] := nTotAnt 	   	//TOTANT
				aFJR[nD, 24] := aPagos[nX, 20]  //H_VALORIG 
				If oJCotiz['lCpoCotiz']
					aFJR[nD, 25] := IIF(!lPA,oJCotiz['TipoCotiz'],0) //FJR_TIPCOT
				EndIf
				aFJR[nD, 38] := cSolFun    		//SOLFUN
			EndIf

			aFJR[nD, 26] := IIF(Len(aPagos[nX]) > 23, aPagos[nX, 24],"") //H_TERC
			aFJR[nD, 27] := aPagos[nX, 8]  		//H_RETGAN
			aFJR[nD, 28] := aPagos[nX, 9]  		//H_RETIVA
			aFJR[nD, 29] := aPagos[nX, 10] 		//H_RETIB
			aFJR[nD, 30] := aPagos[nX, 11] 		//H_RETSUSS
			aFJR[nD, 31] := aPagos[nX, 12] 		//H_RETSLI
			aFJR[nD, 32] := aPagos[nX, 13] 		//H_RETISI
			aFJR[nD, 33] := aPagos[nX, 14] 		//H_CBU
			aFJR[nD, 34] := .F.			   		//DOCTERPA
			aFJR[nD, 35] := nMoedaRet	   		//NMOERET
			aFJR[nD, 36] := nTxPromed	    	//NTXPROM
			
			cTxProm := oJTxProm:ToJson()
			If Len(cTxProm) <= 255
				aFJR[nD, 37] := cTxProm 		//ATXPROM
			EndIf

			If lFormVld .Or. lGrava
				//Cols Documentos de terceros
				For nI := 1 To Len(aSE2[nX][3][3])
					AADD(aTER, ACLONE(aSE2[nX][3][3][nI]))
					nY := Len(aTER)
					AADD(aTER[nY], cOrdPgo)
					If AllTrim(aSE2[nX][3][3][nI][1]) == "CH"
						aFJR[nD][34] := .T. //lGenPA
					EndIf
					aFJR[nD][13] += aSE2[nX][3][3][nI][7] //Total documentos de terceros		
				Next

				//Cols Títulos Financieros
				For nI := 1 To Len(aSE2[nX][1])
					aAdd(aTIT, Array(21))
					nY := Len(aTIT)
					aTIT[nY,  1]  := aSE2[nX, 1, nI, 1]  //E2_FORNECE
					aTIT[nY,  2]  := aSE2[nX, 1, nI, 2]  //E2_LOJA
					aTIT[nY,  3]  := aSE2[nX, 1, nI, 3]  //E2_VALOR
					aTIT[nY,  4]  := aSE2[nX, 1, nI, 4]  //E2_MOEDA
					aTIT[nY,  5]  := aSE2[nX, 1, nI, 5]  //E2_SALDO
					aTIT[nY,  6]  := aSE2[nX, 1, nI, 6]  //SALDO1
					aTIT[nY,  7]  := aSE2[nX, 1, nI, 7]  //E2_EMISSAO
					aTIT[nY,  8]  := aSE2[nX, 1, nI, 8]  //E2_VENCTO
					aTIT[nY,  9]  := aSE2[nX, 1, nI, 9]  //E2_PREFIXO
					aTIT[nY,  10] := aSE2[nX, 1, nI, 10] //E2_NUM
					aTIT[nY,  11] := aSE2[nX, 1, nI, 11] //E2_PARCELA
					aTIT[nY,  12] := aSE2[nX, 1, nI, 12] //E2_TIPO
					aTIT[nY,  13] := aSE2[nX, 1, nI, 13] //RECNO
					aTIT[nY,  14] := cOrdPgo    		 //E2_ORDPAGO
					aTIT[nY,  15] := aSE2[nX, 1, nI, 21] //E2_PAGAR
					aTIT[nY,  16] := aSE2[nX, 1, nI, 18] //E2_DESCONT
					aTIT[nY,  17] := aSE2[nX, 1, nI, 17] //E2_JUROS
					aTIT[nY,  18] := aSE2[nX, 1, nI, 22] //E2_MULTA
					aTIT[nY,  19] := aSE2[nX, 1, nI, 19] //E2_NATUREZ
					aTIT[nY,  20] := aSE2[nX, 1, nI, 16] //E2_NOMFOR
					aTIT[nY,  21] := aSE2[nX, 1, nI, 33] //E2_TXMOEDA

					//Se obtienen las retenciones del título financiero 
					GetRetTit(aSE2[nX][1][nI], cOrdPgo)
				Next

				//Retención de Ganancias
				For nI := 1 To Len(aSE2[nX][2])
					AAdd(aRGAN,ACLONE(aSE2[nX][2][nI]))
					nY := Len(aRGAN)
					AAdd(aRGAN[nY], "G")
					AAdd(aRGAN[nY], cOrdPgo)
				Next 

				//Cols Documentos propios
				For nI := 1 To Len(aSE2[nX][3][2])
					AADD(aPAG, Nil)
					nY := Len(aPAG)	
					aPAG[nY] := ACLONE(aSE2[nX][3][2][nI])
					If Len(aPAG[nY]) >= 17
						aPAG[nY][17] := cOrdPgo 	 //EK_ORDPAGO
						AADD(aPAG[nY], aPAG[nY][16]) //RECSEF
					ElseIf Len(aPAG[nY]) == 16
						AADD(aPAG[nY], cOrdPgo) //EK_ORDPAGO
						AADD(aPAG[nY], 0) 		//RECSEF
					EndIf
					
					aFJR[nD][14] += aSE2[nX][3][2][nI][15] //Total Documentos propios
				Next

				If lPA
					aFJR[nD][12] := nSaldoPgOP
				Else
					aFJR[nD][12] := aFJR[nD][10] - aFJR[nD][14] - aFJR[nD][13] //Saldo de la orden de pago
				EndIf
			EndIf
		Next nX

		If !(lFormVld .Or. lGrava)
			aPAG := oGetDad1:aCols
		EndIf
	Else
		//Encabezado de orden de pago
		aEOP := IIF(!lPa085a,{{nNumOrdens, nValOrdens, cMoeda, "", nMoedaCor, lPa085a, nPagar, ""}},{{0, 0, "", "", nMoedaCor, lPa085a, nPagar, ""}})

		//Si nOps es cero, se validan todos los registros de aPagos, si tiene valor se toma encuenta únicamente esa posición/orden de pago
		nP   := IIF(nOps > 0, nOps, 1)
		nLen := IIF(nOps > 0, nOps, Len(aPagos))

		//Detalle de las ordenes de pago
		For nX := nP To nLen
			aAdd(aFJR, Array(26))
			nI := Len(aFJR)
			aFJR[nI,  1] := aPagos[nX, 1] //H_OK
			aFJR[nI,  2] := aPagos[nX, 2] //H_FORNECE
			aFJR[nI,  3] := aPagos[nX, 3] //H_LOJA
			aFJR[nI,  4] := aPagos[nX, 4] //H_NOME
			aFJR[nI,  5] := aPagos[nX, 5] //H_NF
			aFJR[nI,  6] := aPagos[nX, 6] //H_NCC_PA
			aFJR[nI,  7] := aPagos[nX, 7] //H_TOTAL
			aFJR[nI,  8] := 0 //Pendiente
			aFJR[nI,  9] := 0 //Pendiente
			aFJR[nI, 10] := aPagos[nX, 15] //H_TOTALVL
			aFJR[nI, 11] := cNatureza //Modalidad

			aFJR[nI, 12] := 0 //Pendiente
			aFJR[nI, 13] := 0 //Pendiente 
			aFJR[nI, 14] := 0 //Pendiente 

			If cPaisLoc == "MEX"
				aFJR[nI, 25] := cDesc //DCONCEP
			EndIf

			If cPaisLoc == "PAR"
				aFJR[nI, 25] := aPagos[nX, 9]  //H_RETIVA
				aFJR[nI, 26] := aPagos[nX, 11] //H_RETIR
			EndIf
		Next nX

		If lPa085a .And. Len(aFJR) == 0
			aAdd(aFJR, Array(26))
			nI := Len(aFJR)
			aFJR[nI,  2] := cFornece  //H_FORNECE
			aFJR[nI,  3] := cLoja 	  //H_LOJA
			aFJR[nI,  7] := nValor    //H_TOTAL
			aFJR[nI, 11] := cNatureza //Modalidad
		EndIf
		
		//Formas de pago
		If nPagar < 4
			aPAG := {{cNatureza, IIF(nPagar < 3,cDebMed, cDebInm), dDataVenc, cBanco, cAgencia, cConta, IIF(lPa085a, "",cDesc)}}
			aHdrPAG := {'EK_NATUREZ','EK_TIPO','EK_VENCTO','EK_BANCO','EK_AGENCIA','EK_CONTA','EK_DCONCEP'}
		Else
			aPAG := aCols
			For nX := 1 To Len(aHeader)
				AADD(aHdrPAG,aHeader[nX][2])
			Next
		EndIf
	EndIf
	
Return Nil

/*/{Protheus.doc} LdF999F850
	Carga información de la FINA850 al model
	@type  Function
	@author arodriguez
	@since 02/07/2025
	@version 12.1.2310 y superior
	@param 
	@return 
		oModel - objeto - Modelo cargado de la FINA999
/*/
Function LdF999F850()
	Local oModel := Nil

	oModel := FwLoadModel("FINA999")

    oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	//Llenado del encabezado virtual de la orden de pago 
	SetModel(@oModel, "EOP_MASTER" ,, aEOP, .T.)

	//Llenado del encabezado de la orden de pago
	SetModel(@oModel, "FJR_MASTER" , aHdrFJR, aFJR, .T.)

	//Llenado del modelo de monedas
	SetModel(@oModel, "MOE_DETAIL" ,, aMOE, .T.)

	//Llenado del modelo de saldos por orden de pago
	SetModel(@oModel, "SOP_DETAIL" ,, aSOP, .T.)

    //Llenado de títulos financieros
	SetModel(@oModel, "SE2_DETAIL", aHdrTIT, aTIT, .T.)

	//Llenado de títulos financieros
	SetModel(@oModel, "TTB_DETAIL", {}, {}, .T.)

    //Llenado de documentos propios
	SetModel(@oModel, "PAG_DETAIL", aHdrPAG, aPAG, .T.)

	//Llenado de documentos terceros
	SetModel(@oModel, "3RO_DETAIL", aHdrTER, aTER, .T.)

	//Llenado de retención de IVA
	SetModel(@oModel, "SFE_DETAIL", aHdrRIVA, aRIVA, .T.)
	
	//Llenado de retención de IB
	SetModel(@oModel, "SFE_DETAIL", aHdrRIB, aRIB, .F., .T.)

	//Llenado de retención de SUSS
	SetModel(@oModel, "SFE_DETAIL", aHdrRSUS, aRSUS, .F., .T.)

	//Llenado de retención de SLI
	SetModel(@oModel, "SFE_DETAIL", aHdrRSLI, aRSLI, .F., .T.)

	//Llenado de retención de ISI
	SetModel(@oModel, "SFE_DETAIL", aHdrRISI, aRISI, .F., .T.)

	//Llenado de retención de Ganancias
	SetModel(@oModel, "SFE_DETAIL", aHdrRGAN, aRGAN, .F., .T.)

Return oModel

/*/{Protheus.doc} LdF999F085
	Carga información de la FINA085A al model
	@type  Function
	@author arodriguez
	@since 02/07/2025
	@version 12.1.2310 y superior
	@param 
	@return 
		oModel - objeto - Modelo cargado de la FINA999
	/*/
Function LdF999F085()
	Local oModel		:= Nil

	oModel := FwLoadModel("FINA999")

    oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	//Llenado del encabezado del documento.
	SetModel(@oModel, "EOP_MASTER" ,, aEOP,.T.)

	//Llenado del encabezado de la orden de pago
	SetModel(@oModel, "FJR_MASTER" ,aHdrFJR, aFJR,.T.)

    //Llenado de documentos propios
	SetModel(@oModel, "PAG_DETAIL", aHdrPAG, aPAG)

Return oModel

/*/{Protheus.doc} SetModel
	Función que carga en el Modelo principal un SubModelo utilizando las variables aHeader y aCols que fueron construidas previamente
	@type  Function
	@author carlos.espinoza
	@since 13/08/2025
	@version 12.1.2310 y superior
	@param 
		oModel   - objeto  	- Modelo de datos FINA999
		cModel   - caracter	- Submodelo a cargar
		aHead  	 - arreglo 	- aHeader relacionado al Submodelo a cargar
		aCols  	 - arreglo 	- aCols relacionado al Submodelo a cargar
		lClear   - lógico	- Indica si debe inicializar el SubModelo
		lAddLine - lógico	- Indica si debe agregar una nueva línea al modelo
	@return 
/*/
Static Function SetModel(oModel, cModel, aHead, aCols, lClear, lAddLine)
Local nX 			:= 0
Local nI 			:= 0
Local cField 		:= ""
Local oMdl          := oModel:GetModel(cModel)
Local oStruct 		:= oMdl:GetStruct()
Local aMdlFields	:= {}
Local lPicFormat    := Upper(GetSrvProfString("PictFormat", "DEFAULT")) == "DEFAULT"

Default oModel		:= Nil
Default cModel		:= ""
Default aHead		:= {}
Default aCols		:= {}
Default lClear		:= .F.
Default lAddLine	:= .F.

	If lClear
		oMdl:ClearData(.T.,.T.)
	EndIf

	//Si la variable aHead viene vacía se toma el aHeader del la estructura del modelo
	If Len(aHead) == 0
		aMdlFields := oStruct:GetFields()
		For nX := 1 To Len(aMdlFields)
			AADD(aHead,aMdlFields[nX][3])
		Next nX
	EndIf
	
	
	For nX := 1 To Len(aCols)
		If nX > 1 .Or. (lAddLine .And. !oMdl:IsEmpty())
            oMdl:AddLine()
        EndIf

		For nI := 1 To Len(aHead)
			cField := AllTrim(aHead[nI])
			If oMdl:HasField(cField) .And. Len(aCols[nX]) >= nI .And. !Empty(aCols[nX][nI])
				
				//Si la información a cargar es un número con puntos y decimales se transforma en un valor que la operación VAL soporte 
				If oStruct:GetProperty(cField,MODEL_FIELD_TIPO) == "N" .And. ValType(aCols[nX][nI]) == "C" .And. "," $ aCols[nX][nI] .And. "." $ aCols[nX][nI]
					If lPicFormat
						aCols[nX][nI] := StrTran(aCols[nX][nI], ".", "")
						aCols[nX][nI] := StrTran(aCols[nX][nI], ",", ".")
					Else
						aCols[nX][nI] := StrTran(aCols[nX][nI], ",", "")
					EndIf
				EndIf

				xValue := TypeData(oStruct, cField, aCols[nX][nI])
				oMdl:LoadValue(cField, xValue)
			EndIf
		Next nI
    Next nX

Return Nil

/*/{Protheus.doc} VLineaF999
	Realizar las validaciones de un ítem del Submodelo
	@author 	ARodriguez
	@since 		07/07/2025
	@version	12.1.2310 / Superior
	@param 
		oModel    - objeto  	- Modelo de datos FINA999
		cSubModel - caracter	- Submodelo a validar
	@return 
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Function VLineaF999(oModel, cSubModel)
Local aError	    := {}
Local lRet			:= .T.

Default oModel		:= Nil
Default cSubModel	:= ""

    If !oModel:GetModel(cSubModel):VldLineData() //Validacion de linea
        aError := oModel:GetErrorMessage()
        Help(" ", 1, aError[5], , aError[6], 2, 0,,,,,, {aError[7]})
        lRet := .F.
    EndIf

Return lRet


/*/{Protheus.doc} ValidaF999
	Realizar las validaciones de los datos del modelo de Orden de Pago FINA999
	@author 	ARodriguez
	@since 		07/07/2025
	@version	12.1.2310 y Superior
	Parametros
		oModel - object - Modelo de datos FINA999
	@Return 
		lRet - logico - retorno de las validaciones
/*/
Function ValidaF999(oModel)
Local lRet      := .T.  as logical
Local aError    := {}   as array

Default oModel  := NIL

    If !oModel:VldData()
        aError := oModel:GetErrorMessage()
        Help(" ", 1, aError[5], , aError[6], 2, 0,,,,,, {aError[7]})
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} ModelF999
	Función que verifica si el parámetro MV_OPESTR está activado o desactivado
	@author 	ARodriguez
	@since 		07/07/2025
	@version	12.1.2310 / Superior
	@param 
	@return 
		lRet - lógico - indica si el parámetro MV_OPESTR está activado o desactivado
/*/
Function ModelF999()
	Local lRet	:= .F.

	lRet := SuperGetMv("MV_OPESTR", .F., .T.)

Return lRet

/*/{Protheus.doc} FreeHdrCol
	Función que libera el espacio de las variables utilizadas para cargar el modelo
	@author 	carlos.espinoza
	@since 		21/08/2025
	@version	12.1.2310 y superior
	@param 
	@return 
/*/
Function FreeHdrCol(lFree)

Default lFree := .F.
	
	aFJR 		:= {}
	aEOP 		:= {}
	aMOE		:= {}
	aSOP		:= {}
	aTIT 		:= {}
	aPAG 		:= {}
	aTER 		:= {}
	aRIVA 		:= {}
	aRIB 		:= {}
	aRSUS 		:= {}
	aRSLI 		:= {}
	aRISI 		:= {}
	aRGAN 		:= {}
	aHdrFJR		:= {}
	aHdrTIT		:= {}

	If lFree
		aHdrPAG		:= {}
		aHdrTER		:= {}
	EndIf

	aHdrRIVA	:= {}
	aHdrRIB		:= {}
	aHdrRSUS	:= {}
	aHdrRSLI	:= {}
	aHdrRISI	:= {}
	aHdrRGAN	:= {}

Return Nil

/*/{Protheus.doc} GetRetTit
	Función que obtiene las retenciones del título financiero
	@author 	carlos.espinoza
	@since 		21/08/2025
	@version	12.1.2310 y superior
	@param 		
		aTitulo	- array - Título financiero
	@return
/*/
Function GetRetTit(aTitulo, cOrdPgo)

Local nX 		:= 0
Local nI 		:= 0
Local nY 		:= 0
Local nZ		:= 0
Local aRetISI 	:= {}

Default aTitulo := {}
Default cOrdPgo := ""

	//Retención de IVA
	For nX := 1 To Len(aTitulo[14])
		AAdd(aRIVA,ACLONE(aTitulo[14][nX]))
		nY := Len(aRIVA)
		AAdd(aRIVA[nY], aTitulo[1])
		AAdd(aRIVA[nY], aTitulo[2])
		AAdd(aRIVA[nY], "I")
		AAdd(aRIVA[nY], aTitulo[11])
		AAdd(aRIVA[nY], cOrdPgo)
	Next 
	
	//Retención de IB
	For nX := 1 To Len(aTitulo[15])
		AAdd(aRIB,ACLONE(aTitulo[15][nX]))
		nY := Len(aRIB)
		AAdd(aRIB[nY], "B")
		AAdd(aRIB[nY], cOrdPgo)
	Next 

	//Retención de SUS
	For nX := 1 To Len(aTitulo[24])
		AAdd(aRSUS,ACLONE(aTitulo[24][nX]))
		nY := Len(aRSUS)
		AAdd(aRSUS[nY], "S")
		AAdd(aRSUS[nY], cOrdPgo)
	Next 

	//Retención de SLI
	For nX := 1 To Len(aTitulo[25])
		AAdd(aRSLI,ACLONE(aTitulo[25][nX]))
		nY := Len(aRSLI)
		AAdd(aRSLI[nY], "L")
		AAdd(aRSLI[nY], cOrdPgo)
	Next 

	//Retención de ISI
	For nX := 1 To Len(aTitulo[28])
		AAdd(aRetISI,ACLONE(aTitulo[28][nX]))
		nZ := Len(aRetISI)
		For nI := 1 To Len(aRetISI[nZ][8])
			aAdd(aRISI, Array(12))
			nY := Len(aRISI)
			aRISI[nY][1]  := aRetISI[nZ][1]
			aRISI[nY][2]  := aRetISI[nZ][2]
			aRISI[nY][3]  := aRetISI[nZ][3]
			aRISI[nY][4]  := aRetISI[nZ][8][nI][3]
			aRISI[nY][5]  := aRetISI[nZ][8][nI][3]
			aRISI[nY][6]  := aRetISI[nZ][8][nI][1]
			aRISI[nY][7]  := aRetISI[nZ][9]
			aRISI[nY][8]  := aRetISI[nZ][10]
			aRISI[nY][9]  := aRetISI[nZ][8][nI][4]
			aRISI[nY][10] := aRetISI[nZ][8][nI][2]
			aRISI[nY][11] := "M"
			aRISI[nY][12] := cOrdPgo
		Next 
	Next 

Return Nil

/*/{Protheus.doc} GetHeaders
	Función que inicializa los headers para cada modelo
	@author 	carlos.espinoza
	@since 		09/12/2025
	@version	12.1.2310 y superior
	@param 		
	@return
/*/
Static Function GetHeaders()
Local nx := 0

	//Header Encabezado Orden de Pago FJR
	aHdrFJR := {'MARK','FJR_FORNEC','FJR_LOJA','NOMBRE','FACTURAS',;
					'DESCUENTO','TOTAL','NPORDESC','NVALDESC','NVLRPAGAR',;
					'FJR_NATURE','NSALDOPGOP','NTOTDOCTERC','NTOTDOCPROP',;
					'FJR_ORDPAG','FJR_FILIAL','FJR_EMISSA','CLIQUID','CIDPROC',;
					'NUMOP','TES', 'PROVIN', 'TOTANT', 'VALORIG'}
	
	If cPaisLoc == "ARG"
		AADD(aHdrFJR,'FJR_TIPCOT')
		AADD(aHdrFJR,'ACEPTA3')
		AADD(aHdrFJR,'GANANCIAS')
		AADD(aHdrFJR,'IVA')
		AADD(aHdrFJR,'IIBB')
		AADD(aHdrFJR,'SUSS')
		AADD(aHdrFJR,'SLI')
		AADD(aHdrFJR,'MUNICIPAL')
		AADD(aHdrFJR,'CBU')
		AADD(aHdrFJR,'DOCTERPA')
		AADD(aHdrFJR,'NMOERET')
		AADD(aHdrFJR,'NTXPROM')
		AADD(aHdrFJR,'ATXPROM')
		AADD(aHdrFJR,'SOLFUN')
	EndIf

	If cPaisLoc == "MEX"
		AADD(aHdrFJR,'DCONCEP')
	EndIf

	If cPaisLoc == "PAR"
		AADD(aHdrFJR,'IVA')
		AADD(aHdrFJR,'IR')
	EndIf

	//Header Títulos Financieros
	aHdrTIT := {'E2_FORNECE','E2_LOJA','E2_VALOR'  ,'E2_MOEDA' ,;
				'E2_SALDO'  ,'SALDO1' ,'E2_EMISSAO','E2_VENCTO',;
				'E2_PREFIXO','E2_NUM' ,'E2_PARCELA','E2_TIPO'  ,;
				'RECNO'	,'E2_ORDPAGO' ,'E2_PAGAR' ,'E2_DESCONT',;
				'E2_JUROS', 'E2_MULTA','E2_NATUREZ','E2_NOMFOR','E2_TXMOEDA'}

	If cPaisLoc == "ARG"
		//Header Documentos de terceros
		If Len(aHdrTER) == 0
			For nX := 1 To Len(oGetDad2:aHeader)
				AADD(aHdrTER,oGetDad2:aHeader[nX][2])
			Next
			AADD(aHdrTER,"RECSE1")
			AADD(aHdrTER,"RECSEF")
			AADD(aHdrTER,"")
			AADD(aHdrTER,"E1_ORDPAGO")
		EndIf

		//Header Documentos propios
		If Len(aHdrPAG) == 0
			For nX := 1 To Len(oGetDad1:aHeader)
				AADD(aHdrPAG,oGetDad1:aHeader[nX][2])
			Next
			AADD(aHdrPAG,"")
			AADD(aHdrPAG,"EK_ORDPAGO")
			AADD(aHdrPAG,"RECSEF")
		EndIf

		//Header Retención de IVA
		aHdrRIVA := {'FE_NFISCAL', 'FE_SERIE', 'FE_VALBASE', 'FE_VALIMP',;
		'FE_PORCRET', 'FE_RETENC', '', '', 'FE_CFORI', 'FE_ALIQ', 'FE_CFO',;
		'RETTOT', 'FE_FORNECE', 'FE_LOJA', 'FE_TIPO', 'FE_PARCELA', 'FE_ORDPAGO'}
		
		//Header Retención de IB
		aHdrRIB := {'FE_NFISCAL', 'FE_SERIE', 'FE_VALBASE', 'FE_ALIQ',;
		'', 'FE_RETENC', '', '', 'FE_EST', '', 'FE_CFO',;
		'', '', 'FE_CONCEPT', 'FE_DEDUC', 'FE_PORCRET', 'ESRETADC','CFORA',;
		'ALIQRET', 'ALIQADC', '', '', '', '','',;
		'', '', 'SALDO', 'FE_TPCALR', '', '','',;
		'', '', 'FE_TIPO','FE_ORDPAGO'}

		//Header Retención de SUSS
		aHdrRSUS := {'FE_NFISCAL', 'FE_SERIE', 'FE_VALBASE', 'FE_VALIMP',;
		'FE_PORCRET', 'FE_RETENC', 'FE_ALIQ', 'FE_CONCEPT', '', 'TPOBRA', '',;
		'', '', '', '', 'FE_TIPO', 'FE_ORDPAGO'}

		//Header Retención de SLI
		aHdrRSLI := {'FE_NFISCAL', 'FE_SERIE', 'FE_VALBASE', 'FE_VALIMP',;
		'FE_PORCRET', 'FE_RETENC', 'FE_TIPO', 'FE_ORDPAGO'}

		//Header Retención de ISI
		aHdrRISI := {'FE_NFISCAL', 'FE_SERIE', 'FE_VALBASE', 'FE_VALIMP',;
		'FE_RETENC', 'FE_ALIQ', 'FE_EST', 'FE_RET_MUN', 'CFORA', 'IMPUESTO',; 
		'FE_TIPO', 'FE_ORDPAGO'}	

		//Header Retención de Ganancias
		aHdrRGAN := {'', 'FE_VALBASE', 'FE_ALIQ', 'FE_VALIMP',;
		'FE_RETENC', 'FE_DEDUC', 'FE_CONCEPT', 'FE_PORCRET', 'FE_CONCEP2', 'FE_FORCOND',; 
		'FE_LOJCOND', 'RGANNC', 'FE_TIPO', 'FE_ORDPAGO'}

	EndIf

Return Nil
