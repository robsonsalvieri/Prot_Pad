#include "PROTHEUS.CH"
#include 'FWMVCDEF.CH'
#include "FWBROWSE.CH"
#include "tlpp-object.th"
#include 'FINA999.CH' 

/*/{Protheus.doc} FINV999ARG
	Clase responsable por el evento de reglas de negocio de localización padrón
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Class FINV999ARG From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()
	
	Method ModelPosVld()
	
	Method GridLinePosVld()
	
EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method New() Class FINV999ARG
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method VldActivate(oModel) Class FINV999ARG
Local lRet			:= .T.
	
	self:GetEvent("FINV999"):lArgentina := .T.

Return lRet

/*/{Protheus.doc} ModelPosVld
	Método responsable por ejecutar las validaçioes de las reglas de negocio
	genéricas del cadastro antes de la grabación del formulario.
	Si retorna falso, no permite grabar.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
	@param 		
		oModel	 ,objeto	,Modelo de dados.
		cModelID ,caracter	,Identificador do sub-modelo.
	@return
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Method ModelPosVld(oModel,cModelID) Class FINV999ARG
Local lRet 			:= .T. As Logical
Local nOperation	:= oModel:GetOperation() As Numeric
Local nX			:= 0 As Numeric
Local aModosPgo  	:= Fin025Tipo()
Local nMoeda 		:= 1
Local oModelEOP		:= oModel:GetModel("EOP_DETAIL") As Object
Local oModelDOP		:= oModel:GetModel("DOP_DETAIL") As Object
Local oModelSE2		:= oModel:GetModel("SE2_DETAIL") As Object
Local oModelPAG		:= oModel:GetModel("PAG_DETAIL") As Object

	If nOperation == MODEL_OPERATION_INSERT

		If lRet
			nMoeda := oModelEOP:GetValue("NMOEDA")
			For nX := 1 To oModelDOP:Length()
				If lRet .And. Empty(oModelDOP:GetValue("FORNECE",nX)) .Or. Empty(oModelDOP:GetValue("LOJA",nX)) 
					Help(,,STR0040,,STR0056,1, 0 ) //"Aviso" - "Existen pagos sin proveedor. Seleccione el proveedor con F4."
					lRet := .F.
					Exit
				EndIf
				
				If lRet .And. !F999SldOP(oModelDOP:GetValue("NSALDOPGOP",nX), oModelDOP:GetValue("DOCTERPA",nX), nMoeda, oModelEOP:GetValue("PA"))
					lRet := .F.
					Exit
				EndIf

				If lRet .And. !F999VldDes(oModelDOP:GetValue("NVALDESC",nX),oModelDOP:GetValue("NPORDESC",nX))
					lRet := .F.
					Exit
				EndIf
			Next 
		EndIf

		If lRet
			For nX := 1 To oModelSE2:Length()
				If lRet .And. !F999VldDoc(oModelSE2:GetValue("RECNO",nX), oModelEOP:GetValue("PREORD"))
					lRet := .F.
					Exit
				EndIf
			Next 
		EndIf

		If lRet
			For nX := 1 To oModelPAG:Length()
				If Alltrim(oModelPAG:GetValue("EK_TIPO",nX)) == "CH" .And. Empty(oModelPAG:GetValue("EK_TALAO",nX))
					Help(,,STR0040,,STR0045,1, 0 ) //"Aviso" - "Hay formas de pago con cheques propios que no tienen el número del talonario correspondiente."
					lRet := .F.
					Exit
				EndIf

				If lRet .And. Alltrim(oModelPAG:GetValue("EK_TIPO",nX)) <> "CH" .And. !Empty(oModelPAG:GetValue("EK_VALOR",nX)) .And. Empty(oModelPAG:GetValue("EK_NUM",nX))
					Help(,,STR0040,,STR0046,1, 0 ) //"Aviso" - "Hay formas de pago con documento propio que no tienen el número de documento informado."
					lRet := .F.
					Exit
				EndIf

				If lRet .And. !Empty(oModelPAG:GetValue("EK_VALOR",nX)) .And. Empty(oModelPAG:GetValue("EK_VENCTO",nX)) 
					Help(,,STR0040,,STR0047,1, 0 ) //"Aviso" - "Hay formas de pago con documento propio que no tienen fecha de vencimiento informada."
					lRet := .F.
					Exit
				EndIf

				If lRet .And. !F999VldVct(oModelPAG:GetValue("EK_TIPO",nX),oModelPAG:GetValue("EK_EMISSAO",nX),oModelPAG:GetValue("EK_VENCTO",nX), aModosPgo)
					Help(,,STR0040,,STR0048,1, 0 ) //"Aviso" - "Fecha de vencimento calculada/informada inválida. Verifique otra forma de cálculo o informe una fecha válida."
					lRet := .F.
					Exit
				EndIf
			Next
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GridLinePosVld
	Metodo responsabe por ejecutar reglas de negocio genericas para validación de línea.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
	@param 		
		oModel	 - objeto	- Modelo de dados.
		cModelID - caracter	- Identificador do sub-modelo.
		nLine	 - numerico	- Número de línea validada
	@return
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class FINV999ARG
Local lRet := .T. As Logical
Local nOperation := oSubModel:GetOperation() As Numeric
Local cFJSTipBco := ""
Local cSA6TipBco := ""

	If nOperation == MODEL_OPERATION_INSERT
		If cModelID == "PAG_DETAIL"
			If lRet .And. !Empty(oSubModel:GetValue("EK_BANCO")) .And. Empty(oSubModel:GetValue("EK_TIPO"))
				Help(,,STR0040,,STR0049,1, 0 ) //"Aviso" - "Informe el tipo de documento."
				lRet := .F.
			EndIf

			If lRet .And. !Empty(oSubModel:GetValue("EK_TIPO")) .And. !Empty(oSubModel:GetValue("EK_BANCO")) .And. !Empty(oSubModel:GetValue("EK_AGENCIA")) .And. !Empty(oSubModel:GetValue("EK_CONTA"))
				cFJSTipBco := GetAdvFVal("FJS","FJS_TIPBCO"	,XFilial("FJS")+oSubModel:GetValue("EK_TIPO"),1,"")
				cSA6TipBco := GetAdvFVal("SA6","A6_TIPBCO"	,XFilial("SA6")+oSubModel:GetValue("EK_BANCO")+oSubModel:GetValue("EK_AGENCIA")+oSubModel:GetValue("EK_CONTA"),1,"")
				If !Empty(cFJSTipBco) .And. (cFJSTipBco <> cSA6TipBco)
					Help(,,STR0040,,STR0050,1, 0 ) //"Aviso" - "Hay un tipo de banco que no es válido para el modo de pago en la línea."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} F999VldVct
	Función que valida las fechas emisión y vencimiento de las formas de pago 
	Con respecto a la configuración en la tabla FJS
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		18/08/2025
	@param 		
		cTipo     - caracter - Tipo de forma de pago 
		dEmissao  - fecha    - Fecha emisión
		dVencto   - fecha    - Fecha vencimiento
		aModosPgo - array    - Configuración de las formas de pago
	@return
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Function F999VldVct(cTipo, dEmissao, dVencto, aModosPgo)
Local lRet 		:= .T.
Local nDias     := 0
Local nPos		:= 0
Local cTpInt    := ""
Local cTpVal    := ""

Default cTipo 	  := ""
Default dEmissao  := Ctod("//")
Default dVencto	  := Ctod("//")
Default aModosPgo := {}

nPos   := Ascan(aModosPgo,{|x| x[1] == cTipo})

	If nPos > 0
		cTpInt := Alltrim(aModosPgo[nPos][2])
		cTpVal := Alltrim(aModosPgo[nPos][8])

		Do Case
			Case cTpInt $ MVCHEQUE .And. cTpVal == "2"
				nDias :=  dVencto - dEmissao
				If !((nDias >= 1) .And. (nDias <= 360))
					lRet := .F.
				EndIf
			Case cTpInt $ MVCHEQUE .And. cTpVal == "1" .And. dVencto <> dEmissao
				lRet := .F.
			Case !(cTpInt $ MVCHEQUE) .And. cTpVal == "2" .And. dVencto <= dEmissao
				lRet := .F.
			Case !(cTpInt $ MVCHEQUE) .And. cTpVal == "1" .And. dVencto <> dEmissao
				lRet := .F.
			Case Empty(cTpVal) .And. dVencto < dEmissao
				lRet := .F.
		EndCase
	EndIf

Return lRet

/*/{Protheus.doc} F999VldDoc
	Función que valida si el documento fue dado de baja completamente en otra orden de pago
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		21/08/2025
	@param 		
		nRecno  - caracter - Recno del título financiero en la tabla SE2
		lPreOrd - lógico   - Indica si la orden de pago es una orden previa
	@return
		lRet - lógico - indica si puede o no utilizar el título financiero
/*/
Function F999VldDoc(nRecno, lPreOrd)
Local lRet  := .T.
Local aArea := {}
Local lVldPreOk := .F.

Default nRecno  := 0
Default lPreOrd := .F.

	lVldPreOk := IIF(lPreOrd, .F., !Empty(SE2->E2_PREOK))

	aArea := SE2->(GetArea())
	DbSelectArea("SE2") 
	SE2->(DbGoto(nRecno))
	If !SE2->(EOF())
		If lVldPreOk .Or. (!Empty(SE2->E2_ORDPAGO) .And. SE2->E2_SALDO == 0)
			Help(,,STR0040,,STR0044,1, 0 ) //"Aviso" - "Documento utilizado en otra orden de pago."
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} F999SldOP
	Función que valida el saldo de la orden de pago
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		02/09/2025
	@param 		
		nSaldo - caracter - Saldo de la orden de pago
		lGenPa - lógico   - Indica si se genera PA por documento de tercero
		nMoeda - numérico - Moneda de la orden de pago
	@return
		lRet - lógico - indica si el saldo de la orden de pago es válido
/*/
Function F999SldOP(nSaldo, lGenPa, nMoeda, lPA)
Local lRet  := .T.

Default nSaldo := 0
Default lGenPa := .F.
Default nMoeda := 1
Default lPA    := .F.

	nSaldo := Round(nSaldo, MsDecimais(nMoeda))

	If nSaldo != 0 .And. (!(nSaldo < 0 .And. lGenPA) .Or. lPA)
		Help(,,STR0040,,; // "Aviso"
		STR0051 + SuperGetMv("MV_SIMB"+Alltrim(Str(nMoeda))) + ; // "Faltan "
		Alltrim(Transform(nSaldo,PesqPict("SE2","E2_VALOR"))) + ;
		STR0052 + ;   // " o su equivalente en otra moneda, para pagar los títulos seleccionados."
		STR0053,1, 0) // " Si desea pagar este valor, modifique en la pestaña Títulos el valor por pagar."

		lRet := .F.
	EndIf

Return lRet
