#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} M100RETR
    Cálculo de autorretención especial a título de renta.
    @type Function
    @author luis.samaniego
    @since 04/06/2025
    @version 12.1.2410
    @param cCalculo, Character, Valor a cálcular (A=Alícuota, B=Base, V=Valor).
	@param nItem, Numeric, Número de ítem.
    @param aInfo, Array, Información de impuestos (Código impuesto, Campo libro fiscal).
    @return nRet, Numeric, Base Imponible, Alícuota o Valor de impuesto.
    /*/
Function M100RETR(cCalculo,nItem,aInfo)

Local aConfTES   := {} //[1]=FC_LIQUIDO; [2]=FC_CALCULO
Local aItemInfo  := {}
Local cCpoLivro  := ""
Local cImpuesto  := ""
Local cMvDescSai := SuperGetMv( 'MV_DESCSAI' , .F., , '1' )
Local cTES       := ""
Local lXfis      := .F.
Local nAliq      := 0
Local nBase      := 0
Local nDecs      := 0
Local nMoeda     := 1
Local nRet       := 0

Static jImpxTES  := JsonObject():New()
Static lRatVICol := FindFunction("RatVICol")

Default cCalculo := ""
Default nItem    := 0
Default aInfo    := {}

    lXfis := (MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

	If lXfis

		cTES := MaFisRet(nItem,"IT_TES")
		If Len(aInfo) >= 2
			cImpuesto := aInfo[01] //Código de impuesto
			cCpoLivro := aInfo[02] //Campo libro
		EndIf

		nMoeda := MaFisRet(, "NF_MOEDA") //Moneda del documento
		nDecs := MsDecimais(nMoeda) //Decimales usados para moneda seleccionada

		If !jImpxTES:hasProperty(cImpuesto)
			jImpxTES[cImpuesto] := JsonObject():New()
			jImpxTES[cImpuesto]['FB_ALIQ'] := M100Aliq(cImpuesto) //Obtiene alícuota de tabla SFB
		EndIf

		If !jImpxTES:hasProperty(cTES+cImpuesto)
			aConfTES := VldImpxTES(cTES, cImpuesto) //Obtiene información del impuesto configurado en la TES.
			jImpxTES[cTES+cImpuesto] := JsonObject():New()
			jImpxTES[cTES+cImpuesto]['FC_LIQUIDO'] := aConfTES[1] //FC_LIQUIDO
			jImpxTES[cTES+cImpuesto]['FC_CALCULO'] := aConfTES[2] //FC_CALCULO
		EndIf

		Do Case
			Case cCalculo == "B"

				nAliq := jImpxTES[cImpuesto]['FB_ALIQ']

				If cMvDescSai == '1' .And. MaFisRet(, "NF_CLIFOR") == 'C'
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
					nRet := nBase
				EndIf

			Case cCalculo == "A"

				nRet := jImpxTES[cImpuesto]['FB_ALIQ']

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
						nRet := RatVICol(aInfo, nItem, nAliq, nBase, nMoeda, 100)
					Else
						nRet := nBase * (nAliq / 100)
					EndIf
				EndIf

		EndCase
	EndIf

	FwFreeArray(aConfTES)
	FwFreeArray(aItemInfo)

Return( nRet )

/*/{Protheus.doc} M100Aliq
Consulta la tabla SFB para obtener la alícuota.
@type function
@version 12.1.2410
@author luis.samaniego
@since 5/15/2025
@param  cImpuesto, Character, Código de impuesto.
@return nAliqSFB, Numeric, Alícuota informada en tabla SFB.
/*/
Static Function M100Aliq(cImpuesto)
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
