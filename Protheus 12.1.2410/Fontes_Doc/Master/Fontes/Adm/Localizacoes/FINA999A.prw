#include "PROTHEUS.CH"
#include 'FWMVCDEF.CH'
#include "FWBROWSE.CH"
#include "tlpp-object.th"
#include 'FINA999A.CH' 

Static aEOP 	:= {}
Static aDOP 	:= {}
Static aTIT 	:= {}
Static aPAG 	:= {}
Static aTER 	:= {}
Static aRIVA 	:= {}
Static aHdrTIT	:= {}
Static aHdrPAG	:= {}
Static aHdrTER	:= {}
Static aHdrRIVA := {}

/*/{Protheus.doc} VlLinF999
	Valida línea de formas de pago documentos propios
	@type  Static Function
	@author ARodriguez
	@since 07/07/2025
	@version 12.1.2410
	@param 
		lF850 - lógico - indica si la información viene de la rutina FINA850 o FINA085A
	@return 
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Function VlLinF999(lF850)
	Local oModel		:= Nil
	Local lRet			:= .F.

	Default lF850 	:= .F.

	If lF850
		GetHdrCols(lF850, {}, aPagos)
		oModel := LdF999F850()
		lRet := VLineaF999(oModel, "PAG_DETAIL")
	Else
		GetHdrCols(lF850, {}, aPagos)
		oModel := LdF999F085()
		lRet := VLineaF999(oModel, "PAG_DETAIL")
	EndIf
	
	oModel:DeActivate()
	FreeHdrCol()
	
Return lRet

/*/{Protheus.doc} VlTudoF999
	Valida modelo = TudoOk
	@type  Static Function
	@author ARodriguez
	@since 07/07/2025
	@version 12.1.2410 y superiores
	@param 
		lF850 - lógico  - indica si la información viene de la rutina FINA850 o FINA085A
		aSE2  - arreglo - variable que contiene información sobre títulos financieros, documentos propios, documentos de terceros y retenciones
	@return 
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Function VlTudoF999(lF850, aSE2)
	Local oModel		:= Nil
	Local lRet			:= .F.

	Default lF850 	:= .F.
	Default aSE2    := {}

	If lF850
		GetHdrCols(lF850, aSE2, aPagos)
		oModel := LdF999F850()
		lRet := ValidaF999(oModel)
	Else
		GetHdrCols(lF850, aSE2, aPagos)
		oModel := LdF999F085()
		lRet := ValidaF999(oModel)
	EndIf

	oModel:DeActivate()
	FreeHdrCol()

Return lRet

/*/{Protheus.doc} GetHdrCols
	Carga las variables que vienen de la FINA850 y FINA085A a las transforma en variables aHeader y aCols que facilitan el llenado de los modelos
	@type  Function
	@author carlos.espinoza
	@since 13/08/2025
	@version 12.1.2310 y superior
	@param 
		lF850   - lógico  - indica si la información viene de la rutina FINA850 o FINA085A
		aSE2    - arreglo - variable que contiene información sobre títulos financieros, documentos propios, documentos de terceros y retenciones
		aPagos  - arreglo - variable que contiene información de los pagos a generar de cada orden de pago
	@return 
/*/
Static Function GetHdrCols(lF850, aSE2, aPagos)
Local nX		 := 0
Local nI 		 := 0
Local nY 		 := 0
Local lFormVld 	 := IsInCallStack("F850VldOPs")

Default lF850	 := .F.
Default aSE2	 := {}
Default aPagos   := {}

	If lF850

		//Encabezado de orden de pago
		aEOP := {{nNumOrdens, nValOrdens, cMoeda, cPgtoElt, nMoedaCor, .F., lShowPOrd}}

		//Detalle de las ordenes de pago
		For nX := 1 To Len(aPagos)
			aAdd(aDOP, Array(23))
			nI := Len(aDOP)
			aDOP[nI,  1] := aPagos[nX, 1] //MARK
			aDOP[nI,  2] := aPagos[nX, 2] //H_FORNECE
			aDOP[nI,  3] := aPagos[nX, 3] //H_LOJA
			aDOP[nI,  4] := aPagos[nX, 4] //H_NOME
			aDOP[nI,  5] := aPagos[nX, 5] //H_NF
			aDOP[nI,  6] := aPagos[nX, 6] //H_NCC_PA
			aDOP[nI,  7] := aPagos[nX, 7] //H_TOTAL
			aDOP[nI,  8] := aPagos[nX, 16] //H_PORDESC
			aDOP[nI,  9] := aPagos[nX, 18] //H_DESCVL
			aDOP[nI, 10] := aPagos[nX, 15] //H_TOTALVL
			aDOP[nI, 11] := aPagos[nX, 21] //H_NATUREZA

			aDOP[nI, 12] := 0 //NSALDOPGOP
			aDOP[nI, 13] := 0 //NTOTDOCTERC (Total de documentos de terceros)
			aDOP[nI, 14] := 0 //NTOTDOCPROP (Total de documentos propios)

			aDOP[nI, 15] := aPagos[nX, 24] //H_TERC
			aDOP[nI, 16] := aPagos[nX, 8] //H_RETGAN
			aDOP[nI, 17] := aPagos[nX, 9] //H_RETIVA
			aDOP[nI, 18] := aPagos[nX, 10] //H_RETIB
			aDOP[nI, 19] := aPagos[nX, 11] //H_RETSUSS
			aDOP[nI, 20] := aPagos[nX, 12] //H_RETSLI
			aDOP[nI, 21] := aPagos[nX, 13] //H_RETISI
			aDOP[nI, 22] := aPagos[nX, 14] //H_CBU
			aDOP[nI, 23] := .F.			   //lGenPA
		Next nX

		//Header Documentos de terceros
		For nX := 1 To Len(oGetDad2:aHeader)
			AADD(aHdrTER,oGetDad2:aHeader[nX][2])
		Next

		//Header Títulos Financieros
		aHdrTIT := {'E2_FORNECE','E2_LOJA','E2_VALOR'  ,'E2_MOEDA' ,;
					'E2_SALDO'  ,'SALDO1' ,'E2_EMISSAO','E2_VENCTO',;
					'E2_PREFIXO','E2_NUM' ,'E2_PARCELA','E2_TIPO'  ,'RECNO'}
		
		//Header Documentos propios
		For nX := 1 To Len(oGetDad1:aHeader)
			AADD(aHdrPAG,oGetDad1:aHeader[nX][2])
		Next

		//Header Retención de IVA
		aHdrRIVA := {'FE_NFISCAL', 'FE_SERIE', 'FE_VALBASE', 'FE_VALIMP', ;
		'FE_PORCRET', 'FE_RETENC', '', '', 'FE_CFORI', 'FE_ALIQ', 'FE_CFO',;
		'', 'FE_FORNECE', 'FE_LOJA', 'FE_TIPO', 'FE_PARCELA'}

		If lFormVld
			For nX := 1 To Len(aSE2)
				//Cols Documentos de terceros
				For nI := 1 To Len(aSE2[nX][3][3])
					AADD(aTER, aSE2[nX][3][3][nI])
					If AllTrim(aSE2[nX][3][3][nI][1]) == "CH"
						aDOP[nX][23] := .T.
					EndIf
					aDOP[nX][13] += aSE2[nX][3][3][nI][7] //Total documentos de terceros		
				Next

				//Cols Títulos Financieros
				For nI := 1 To Len(aSE2[nX][1])
					aAdd(aTIT, Array(13))
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

					//Se obtienen las retenciones del título financiero 
					GetRetTit(aSE2[nX][1][nI])
				Next

				//Cols Documentos propios
				For nI := 1 To Len(aSE2[nX][3][2])
					AADD(aPAG, aSE2[nX][3][2][nI])
					aDOP[nX][14] += aSE2[nX][3][2][nI][15] //Total Documentos propios			
				Next
				aDOP[nX][12] := aDOP[nX][10] - aDOP[nX][14] - aDOP[nX][13] //Saldo de la orden de pago
			Next
		EndIf

		If !lFormVld
			aPAG := oGetDad1:aCols
		EndIf
	Else
		//Encabezado de orden de pago
		aEOP := {{nNumOrdens, nValOrdens, cMoeda, "", nMoedaCor, .F.}}

		//Detalle de las ordenes de pago
		For nX := 1 To Len(aPagos)
			aAdd(aDOP, Array(15))
			nI := Len(aDOP)
			aDOP[nI,  1] := aPagos[nX, 1] //H_OK
			aDOP[nI,  2] := aPagos[nX, 2] //H_FORNECE
			aDOP[nI,  3] := aPagos[nX, 3] //H_LOJA
			aDOP[nI,  4] := aPagos[nX, 4] //H_NOME
			aDOP[nI,  5] := aPagos[nX, 5] //H_NF
			aDOP[nI,  6] := aPagos[nX, 6] //H_NCC_PA
			aDOP[nI,  7] := aPagos[nX, 7] //H_TOTAL
			aDOP[nI,  8] := 0 //Pendiente
			aDOP[nI,  9] := 0 //Pendiente
			aDOP[nI, 10] := 0 //Pendiente
			aDOP[nI, 11] := cNatureza //Pendiente

			aDOP[nI, 12] := 0 //Pendiente
			aDOP[nI, 13] := 0 //Pendiente 
			aDOP[nI, 14] := 0 //Pendiente 
			aDOP[nI, 15] := cDesc //Pendiente 

		Next nX
		
		//Formas de pago
		If !IsInCallStack("a085aLnok")
			aPAG := {{cNatureza, nPagar, cDebMed, dDataVenc, lBaixaChq, cBanco, cAgencia, cConta, cDesc}}
			aHdrPAG := {'EK_NATUREZ', 'NPAGAR', 'EK_TIPO','EK_VENCTO','LBAIXACHQ','EK_BANCO','EK_AGENCIA','EK_CONTA','EK_DCONCEP'}
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

	//Llenado del encabezado de la orden de pago
	SetModel(@oModel, "EOP_DETAIL" ,, aEOP,.T.)

	//Llenado de órdenes de pago a generar
	SetModel(@oModel, "DOP_DETAIL" ,, aDOP,.T.)

    //Llenado de títulos financieros
	SetModel(@oModel, "SE2_DETAIL", aHdrTIT, aTIT,.T.)

    //Llenado de documentos propios
	SetModel(@oModel, "PAG_DETAIL", aHdrPAG, aPAG,.T.)

	//Llenado de documentos terceros
	SetModel(@oModel, "3RO_DETAIL", aHdrTER, aTER,.T.)

	//Llenado de retención de IVA
	SetModel(@oModel, "SFE_DETAIL", aHdrRIVA, aRIVA,.T.)

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
	SetModel(@oModel, "EOP_DETAIL" ,, aEOP,.T.)

	//Llenado de órdenes de pago a generar
	SetModel(@oModel, "DOP_DETAIL" ,, aDOP,.T.)

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
		oModel  - objeto  	- Modelo de datos FINA999
		cModel  - caracter	- Submodelo a cargar
		aHead  	- arreglo 	- aHeader relacionado al Submodelo a cargar
		aCols  	- arreglo 	- aCols relacionado al Submodelo a cargar
		lClear  - lógico	- Indica si debe inicializar el SubModelo
	@return 
/*/
Static Function SetModel(oModel, cModel, aHead, aCols, lClear)
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
		If nX > 1
            oMdl:AddLine()
        EndIf

		For nI := 1 To Len(aHead)
			cField := AllTrim(aHead[nI])
			If oMdl:HasField(cField) .and. !Empty(aCols[nX][nI])
				
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
	@version	12.1.2410 / Superior
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
	@version	12.1.2410 / Superior
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
Function FreeHdrCol()
	
	aEOP 		:= {}
	aDOP 		:= {}
	aTIT 		:= {}
	aPAG 		:= {}
	aTER 		:= {}
	aRIVA 		:= {}
	aHdrTIT		:= {}
	aHdrPAG		:= {}
	aHdrTER		:= {}
	aHdrRIVA	:= {}

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
Function GetRetTit(aTitulo)

Local nX := 0
Local nY := 0

Default aTitulo := {}

	//Retención de IVA
	For nX := 1 To Len(aTitulo[14])
		AAdd(aRIVA,aTitulo[14][nX])
		nY := Len(aRIVA)
		AAdd(aRIVA[nY], aTitulo[1])
		AAdd(aRIVA[nY], aTitulo[2])
		AAdd(aRIVA[nY], "I")
		AAdd(aRIVA[nY], aTitulo[11])
	Next 

Return Nil
