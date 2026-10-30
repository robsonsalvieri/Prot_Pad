#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} M460RETR
    Cálculo de autorretención especial a título de renta.
    @type Function
    @author luis.samaniego
    @since 15/05/2025
    @version 12.1.2410
    @param cCalculo, Character, Valor a cálcular (A=Alícuota, B=Base, V=Valor).
	@param nItem, Numeric, Número de ítem.
    @param aInfo, Array, Información de impuestos (Código impuesto, Campo libro fiscal).
    @return xRet, Undefinited, Valor de impuesto.
    /*/
Function M460RETR(cCalculo,nItem,aInfo)

Local aConfTES   := {} //[1]=FC_LIQUIDO; [2]=FC_CALCULO
Local aItemInfo  := {}
Local cCpoLivro  := ""
Local cFunName   := FunName()
Local cImpuesto  := ""
Local cMvDescSai := SuperGetMv( 'MV_DESCSAI' , .F., , '1' )
Local cTES       := ""
Local nAliq      := 0
Local nBase      := 0
Local nDecs      := 0
Local nDesconto  := 0
Local nMoeda     := 1
Local xRet       := Nil

Static jImpxTES  := JsonObject():New()
Static lRatVICol := FindFunction("RatVICol")

Default cCalculo := ""
Default nItem    := 0
Default aInfo    := {}

	If Type("lPedidos") == "U"
		lPedidos := .F.
	EndIf

    lXfis := (MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

	If !lxFis
		xRet      := {}
		cTes      := SF4->F4_CODIGO
		aItemInfo := ParamIxb[1]
        xRet      := ParamIxb[2]

		If Len(xRet) >= 1
			cImpuesto := xRet[1]
		EndIf

		//Moneda del documento
		If lPedidos
			nMoeda := SC5->C5_MOEDA
		Else
			nMoeda := SF2->F2_MOEDA
		EndIf

	Else

		xRet := 0
		cTES := MaFisRet(nItem,"IT_TES")
		If Len(aInfo) >= 2
			cImpuesto := aInfo[01] //Código de impuesto
			cCpoLivro := aInfo[02] //Campo libro
		EndIf

		//Moneda del documento
		If cFunName $ "MATA410"
			If Type("M->C5_MOEDA") <> "U" 
				nMoeda := M->C5_MOEDA
			EndIf
		Else
			nMoeda := MaFisRet(, "NF_MOEDA")
		EndIf
		
	EndIf

	nDecs := MsDecimais(nMoeda)

	If !jImpxTES:hasProperty(cImpuesto)
		jImpxTES[cImpuesto] := JsonObject():New()
		jImpxTES[cImpuesto]['FB_ALIQ'] := M460Aliq(cImpuesto) //Obtiene alícuota de tabla SFB
	EndIf

	If !lXFis
	
		nAliq := jImpxTES[cImpuesto]['FB_ALIQ']
		
		//Resta el valor del descuento si calcula sobre valor neto
		If Len(xRet) >= 18 .And. ValType(xRet[18])=="N" .And. Subs(xRet[5],4,1) == "S"
			nDesconto := xRet[18]
		EndIf

		//Realiza el calculo de la autorretención
		If Len(aItemInfo) >= 5
			nBase := (aItemInfo[3] + aItemInfo[4] + aItemInfo[5] - nDesconto)
		EndIf
		If Len(xRet) >= 4
			xRet[2] := nAliq
			xRet[3] := nBase
			xRet[4] := nBase * (nAliq / 100)
		EndIf

	Else

		If !jImpxTES:hasProperty(cTES+cImpuesto)
			aConfTES := VldImpxTES(cTES, cImpuesto) //Obtiene información del impuesto configurado en la TES.
			jImpxTES[cTES+cImpuesto] := JsonObject():New()
			jImpxTES[cTES+cImpuesto]['FC_LIQUIDO'] := aConfTES[1] //FC_LIQUIDO
			jImpxTES[cTES+cImpuesto]['FC_CALCULO'] := aConfTES[2] //FC_CALCULO
		EndIf

		Do Case
			Case cCalculo == "B"

				nAliq := jImpxTES[cImpuesto]['FB_ALIQ']

				If cMvDescSai == '1' 
					nBase += MaFisRet(nItem,"IT_DESCONTO")
				Endif

				//Resta el valor del descuento si calcula sobre valor neto
				If jImpxTES[cTES+cImpuesto]['FC_LIQUIDO'] == "S"
					nBase -= MaFisRet(nItem, "IT_DESCONTO") //Valor descuento
				EndIf

				nBase += MaFisRet(nItem,"IT_VALMERC") //Valor mercadería
				nBase += MaFisRet(nItem,"IT_FRETE") //Valor flete
				nBase += MaFisRet(nItem,"IT_DESPESA") //Valor gastos
				nBase += MaFisRet(nItem,"IT_SEGURO") //Valor seguro
				
				If nAliq > 0
					xRet := nBase
				EndIf

			Case cCalculo == "A"

				xRet := jImpxTES[cImpuesto]['FB_ALIQ']

			Case cCalculo == "V"

				nAliq := MaFisRet(nItem, 'IT_ALIQIV'+cCpoLivro) //Alícuota
				If nAliq > 0
					If jImpxTES[cTES+cImpuesto]['FC_CALCULO'] == "T"
						nBase := MaRetBasT(cCpoLivro, nItem, nAliq) //Base total
					Else
						nBase := MaFisRet(nItem, 'IT_BASEIV'+cCpoLivro) //Base ítem
					EndIf

					//Realiza cálculo de autorretención
					If lRatVICol .And. jImpxTES[cTES+cImpuesto]['FC_CALCULO'] == "I"
						xRet := RatVICol(aInfo, nItem, nAliq, nBase, nMoeda, 100)
					Else
						xRet := nBase * (nAliq / 100)
					EndIf
				EndIf

		EndCase
	EndIf

	FwFreeArray(aConfTES)
	FwFreeArray(aItemInfo)

Return( xRet )

/*/{Protheus.doc} M460Aliq
Consulta la tabla SFB para obtener la alícuota.
@type function
@version 12.1.2410
@author luis.samaniego
@since 5/15/2025
@param  cImpuesto, Character, Código de impuesto.
@return nAliqSFB, Numeric, Alícuota informada en tabla SFB.
/*/
Static Function M460Aliq(cImpuesto)
Local nAliqSFB := 0
Local aAreaSFB := {}

Default cImpuesto := ""

	aAreaSFB := GetArea()
	dbSelectArea("SFB")
	dbSetOrder(1)
	If MsSeek(xFilial("SFB") + cImpuesto)
		nAliqSFB := SFB->FB_ALIQ //Aliquota
	EndIf
	RestArea(aAreaSFB)
	FwFreeArray(aAreaSFB)

Return nAliqSFB

/*/{Protheus.doc} VldImpxTES
	Obtiene información del impuesto configurado en la TES.
	@type  Function
	@author luis.samaniego
	@since 15/05/2025
	@version 12.1.2410
	@param cTES, Character, Código de la TES.
	@param cImpuesto, Character, Código de impuesto.
	@return aConfTES, Array, Configurado en la TES.
	/*/
Static Function VldImpxTES(cTES, cImpuesto)
Local aAreaSFC := {}
Local aConfTES := {"",""} //[1]=FC_LIQUIDO; [2]=FC_CALCULO

Default cTES := ""
Default cImpuesto := ""

	aAreaSFC := GetArea()
	dbSelectArea("SFC")
	SFC->(DbSetOrder(2))
	If (SFC->(MsSeek(xFilial("SFC") + cTES + cImpuesto)))
		aConfTES[1] := SFC->FC_LIQUIDO
		aConfTES[2] := SFC->FC_CALCULO
	Endif
	RestArea(aAreaSFC)
	FwFreeArray(aAreaSFC)

Return aClone(aConfTES)
