#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'tlpp-object.th'
#include 'fina999.ch'

/*/{Protheus.doc} F999PA
	Clase responsable por el evento de reglas de negocio de localización padrón
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Class F999PA From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method AfterTTS()
	
EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method New() Class F999PA
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method VldActivate(oModel) Class F999PA
Local lRet	:= .T.

Return lRet

/*/{Protheus.doc} AfterTTS
Metodo responsable por ejecutar reglas de negocio de retenciones 
después de la transacción del modelo de datos.
@type 		Method
@param 		oModel	 - objeto	 - Modelo de dados de Clientes.
@param 		cModelId - caracter	 - Identificador do sub-modelo.
@author 	carlos.espinoza
@version	12.1.2310 / Superior
@since		23/04/2026 
/*/
Method AfterTTS(oModel, cModelId) Class F999PA
Local nOperation	:= oModel:GetOperation()
Local oModelEOP 	:= oModel:GetModel('EOP_MASTER')
Local oModelFJR 	:= oModel:GetModel('FJR_MASTER')
Local oModelSOP 	:= oModel:GetModel('SOP_DETAIL')
Local oModelMOE 	:= oModel:GetModel('MOE_DETAIL')
Local nX			:= 0
Local cJCotiz		:= oModelEOP:GetValue("COTIZ")
Local oJCotiz 		:= JsonObject():New()
Local lUsaFlag      := SuperGetMV("MV_CTBFLAG", .T., .F.)
Local cDocCred		:= ""
Local lRetPA		:= SuperGetMv("MV_RETPA", .F., "N") == "S"
Local nColig		:= SuperGetMv("MV_RMCOLIG", .F., 0)
Local cSimbol	    := SuperGetMV("MV_SIMB1", .F., "")
Local lActTit       := ExistBlock("A085ATIT")
Local lMsgUnica		:= IsIntegTop()
Local lFlagCTB      := Type("aFlgCTB") == "A"
Local lSelPgo		:= IsInCallStack("SELPAGO")  //Valida si el PA es generado por Generar PA
Local oJTxProm		:= JsonObject():New()
Local nTxPromed 	:= oModelFJR:GetValue("NTXPROM")  	
Local aTxProm   	:= {}
Local aAreaSEK 		:= {}
Local aAreaSE2 		:= {}

	If nOperation == MODEL_OPERATION_INSERT .And. !oModelEOP:GetValue("HASERROR")
		Pergunte("FIN850P", .F., /*cTitle*/, .F., /*oDlg*/, .T.)
		If lRetPA .And. MV_PAR11 $ MVPAGANT
			cDocCred :=	MVPAGANT
		ElseIf !(Empty(MV_PAR11) .Or. !(MV_PAR11 $ MV_CPNEG+"|"+MVPAGANT))
			cDocCred :=	MV_PAR11
		EndIf
		oJCotiz:FromJson(cJCotiz)
		oJTxProm:FromJson(oModelFJR:GetValue("ATXPROM"))
		aTxProm := oJTxProm['txprom']
		F999CmpMoe(oModelSOP, oModelMOE)
		For nX := 1	To oModelSOP:Length()
			oModelSOP:GoLine(nX)
			If oModelSOP:GetValue("SALDO") < 0  //Genera pago anticipado
				oModelFJR:SeekLine({{"FJR_ORDPAG", oModelSOP:GetValue("ORDPAGO")}}, .F., .T.)
				aAreaSEK := SEK->(GetArea())
				DbSelectArea("SEK")
				RecLock("SEK",.T.)
				SEK->EK_FILIAL	:= xFilial("SEK")
				SEK->EK_TIPODOC	:= "PA"
				SEK->EK_NUM    	:= oModelFJR:GetValue("FJR_ORDPAG")
				SEK->EK_PARCELA	:= ALLTrim(STR(nX))
				SEK->EK_TIPO   	:= cDocCred 
				SEK->EK_FORNECE	:= oModelFJR:GetValue("FJR_FORNEC")
				SEK->EK_LOJA   	:= oModelFJR:GetValue("FJR_LOJA")
				SEK->EK_EMISSAO	:= dDataBase
				SEK->EK_VENCTO 	:= dDataBase
				SEK->EK_VALOR  	:= Abs(oModelSOP:GetValue("SALDO"))
				SEK->EK_SALDO  	:= Abs(oModelSOP:GetValue("SALDO"))
				SEK->EK_VLMOED1	:= Round(xMoeda(Abs(oModelSOP:GetValue("SALDO")),oModelFJR:GetValue("NMOERET"),1,,5,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(1))
				SEK->EK_MOEDA  	:= Alltrim(Str(oModelFJR:GetValue("NMOERET")))
				SEK->EK_ORDPAGO	:= oModelFJR:GetValue("FJR_ORDPAG")
				SEK->EK_DTDIGIT	:= dDataBase
				SEK->EK_FORNEPG	:= oModelFJR:GetValue("FJR_FORNEC")
				SEK->EK_LOJAPG 	:= oModelFJR:GetValue("FJR_LOJA")
				SEK->EK_NUMOPER := oModelFJR:GetValue("NUMOP")
				SEK->EK_TOTANT  := oModelFJR:GetValue("TOTANT")
				SEK->EK_TES     := oModelFJR:GetValue("TES")
				SEK->EK_PROV    := oModelFJR:GetValue("PROVIN")
				SEK->EK_PGCBU	:= oModelFJR:GetValue("CBU")
				SEK->EK_NATUREZ := oModelFJR:GetValue("FJR_NATURE")
				SEK->EK_SOLFUN  := oModelFJR:GetValue("SOLFUN")
				F999GrvTx(oJCotiz['MonedaCotiz'], nTxPromed, aTxProm, oJCotiz, oModelMOE,, .T.)
				SEK->(MsUnlock())
				RestArea(aAreaSEK)

				If oModelEOP:GetValue("CPGTOELT") <> "1"
					aAreaSE2 := SE2->(GetArea())
					DbSelectArea("SE2")
					RecLock("SE2",.T.)
					SE2->E2_FILIAL	:= xFilial("SE2")
					SE2->E2_NUMLIQ 	:= oModelFJR:GetValue("CLIQUID")
					SE2->E2_NUM    	:= oModelFJR:GetValue("FJR_ORDPAG")
					SE2->E2_PARCELA	:= AllTrim(STR(nX))
					SE2->E2_TIPO   	:= cDocCred
					SE2->E2_NATUREZ := oModelFJR:GetValue("FJR_NATURE")
					SE2->E2_FORNECE	:= oModelFJR:GetValue("FJR_FORNEC")
					SE2->E2_LOJA   	:= oModelFJR:GetValue("FJR_LOJA")
					SE2->E2_NOMFOR 	:= oModelFJR:GetValue("NOMBRE")
					SE2->E2_EMISSAO	:= dDataBase
					SE2->E2_EMIS1  	:= dDataBase
					SE2->E2_VENCTO 	:= dDataBase
					SE2->E2_VENCORI	:= dDataBase
					SE2->E2_VENCREA	:= DataValida(dDataBase,.T.)
					SE2->E2_VALOR 	:= Abs(oModelSOP:GetValue("SALDO"))
					SE2->E2_SALDO  	:= Abs(oModelSOP:GetValue("SALDO"))
					SE2->E2_VLCRUZ 	:= Round(xMoeda(Abs(oModelSOP:GetValue("SALDO")),oModelFJR:GetValue("NMOERET"),1,,5,oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET"))),MsDecimais(1))
					SE2->E2_MOEDA  	:= oModelFJR:GetValue("NMOERET")
					SE2->E2_TXMOEDA := oModelMOE:GetValue("TASA",oModelFJR:GetValue("NMOERET")) //Graba la tasa de la moneda
					SE2->E2_STATLIB	:= "03" //Fue liberado nX solicitación de fondos.
					SE2->E2_CODAPRO	:= FJA->FJA_CODAPR
					SE2->E2_DATALIB	:= FJA->FJA_DTOPER
					SE2->E2_SITUACA	:= "0"
					SE2->E2_ORDPAGO	:= oModelFJR:GetValue("FJR_ORDPAG")
					SE2->E2_ORIGEM 	:= "FINA850"
					SE2->E2_FILORIG := cFilAnt
					If lSelPgo
						SE2->E2_CODAPRO := Alltrim(oModelEOP:GetValue("CAPROV"))
					EndIf

					If !lUsaFlag
						SE2->E2_LA := "S"
					EndIf

					//Integración Protheus X TOP - Argentina y Mexico
					If !lMsgUnica .And. nColig > 0 .And. IntePMS() .And.  MsgYesNo(OemToAnsi(STR0071)+" "+"("+cDocCred+")"+" "+AllTrim(SE2->E2_NUM)+" " +OemToAnsi(STR0072)+" "+;
						cSimbol+" "+ AllTrim(Transform(SE2->E2_VLCRUZ,GetSx3Cache("E2_VLCRUZ","X3_PICTURE")))+ " " + OemToAnsi(STR0073))//"Desea vincular el título" "de valor" "a un proyecto?"
						PMSFi999()
					EndIf

					SE2->(MsUnlock())
					RestArea(aAreaSE2)

					If lUsaFlag .And. lFlagCTB // Almaneca en aFlgCTB para actualizar el modulo Contable
						aAdd(aFlgCTB, {"E2_LA", "S", "SE2", SE2->(RecNo()), 0, 0, 0})
					EndIf

					If lActTit
						ExecBLock("A085ATIT",.F.,.F.)
					Endif
				EndIf
			EndIf
		Next
	EndIf

Return Nil

/*/{Protheus.doc} PMSFi999
	En caso de que la integración con Totvs Obras y Proyectos este relacionada, llama a la pantalla de prorrateo de proyecto
	@type  Function
	@author carlos.espinoza
	@since 08/05/2026
	@version 12.1.2310 y superior
	@param 
	@return 
/*/
Static Function PMSFi999()
Local aArea
Local bPMSDlgF99 := {|| PmsDlgFI(3,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA)} //Ingteración PMS
	
	aArea := GetArea()

	M->E2_NUM 		:= SE2->E2_NUM
	M->E2_PREFIXO   := SE2->E2_PREFIXO
	M->E2_FORNECE   := SE2->E2_FORNECE
	M->E2_LOJA		:= SE2->E2_LOJA
	M->E2_ORIGEM	:= SE2->E2_ORIGEM
	M->E2_VALOR		:= SE2->E2_VALOR
	M->E2_MOEDA		:= SE2->E2_MOEDA
	M->E2_TXMOEDA	:= SE2->E2_TXMOEDA

	Eval(bPMSDlgF99)
	PmsWriteFI(1,"SE2")
	RestArea(aArea)

Return

/*/{Protheus.doc} F999CmpMoe
	Función recursiva para aplicar los valores recibidos en moneda diferente a los títulos en estos mismos títulos.
	@type  Function
	@author carlos.espinoza
	@since 08/05/2026
	@version 12.1.2310 y superior
	@param 
		oModelSOP - objeto - Modelo de Saldos de Ordenes de Pago
		oModelMOE - objeto - Modelo de Monedas
	@return 
/*/
Static Function F999CmpMoe(oModelSOP, oModelMOE)
Local nX 		:= 0
Local nI 		:= 0
Local nA 		:= 0
Local nP 		:= 0
Local nPago	    := 0
Local nJ 		:= 0
Local aTitPags 	:= {}
Local aOps    	:= {}

Default oModelSOP := Nil
Default oModelMOE := Nil

For nX := 1 To oModelSOP:Length()
	oModelSOP:GoLine(nX)
	If AScan(aOps,{|x| x == oModelSOP:GetValue("ORDPAGO")}) == 0
		AAdd(aOps, oModelSOP:GetValue("ORDPAGO"))
	EndIf
Next 

For nX := 1 To Len(aOps)
	For nI := 1 To oModelSOP:Length()
		oModelSOP:GoLine(nI)
		If oModelSOP:GetValue("ORDPAGO") == aOps[nX]
			AAdd(aTitPags, oModelSOP:GetValue("SALDO"))
		EndIf
	Next 

	For nA := 1 To Len(aTitPags)
		If aTitPags[nA]	> 0
			For nP := 1 To Len(aTitPags)
				If aTitPags[nA]	> 0
					If aTitPags[nP]	< 0
						nPago := Round(xMoeda(aTitPags[nP],nP,nA,,MsDecimais(nA)+1,oModelMOE:GetValue("TASA", nP),oModelMOE:GetValue("TASA", nA)),MsDecimais(nA))
						//El valor nPago es siempre negativo
						If Abs(nPago) > aTitPags[nA]
							aTitPags[nP] +=	Round(xMoeda(aTitPags[nA],nA,nP,,MsDecimais(nP)+1,oModelMOE:GetValue("TASA", nA),oModelMOE:GetValue("TASA", nP)),MsDecimais(nP))
							aTitPags[nA] :=	0
						ElseIf Abs(nPago) < aTitPags[nA]
							aTitPags[nA] +=	nPago
							aTitPags[nP] :=	0
						Else
							aTitPags[nA] :=	0
							aTitPags[nP] :=	0
						Endif
					Endif
				Else
					Exit
				Endif
			Next
		Endif
	Next

	For nI := 1 To oModelSOP:Length()
		oModelSOP:GoLine(nI)
		If oModelSOP:GetValue("ORDPAGO") == aOps[nX]
			nJ++
			If nJ <= Len(aTitPags)
				oModelSOP:LoadValue("SALDO", aTitPags[nJ])
			EndIf
		EndIf
	Next 

	nJ := 0
	aTitPags := {}
Next 

Return()
