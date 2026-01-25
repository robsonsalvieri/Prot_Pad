#include "PROTHEUS.CH"
#include 'FWMVCDEF.CH'
#include "FWBROWSE.CH"
#include "tlpp-object.th"
#include 'FINA999.CH' 

/*/{Protheus.doc} FINV999
	Clase responsable por el evento de reglas de negocio de localización padrón
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Class FINV999 From FwModelEvent 
    
    DATA lArgentina As Logical

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
Method New() Class FINV999
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method VldActivate(oModel) Class FINV999
Local lRet			:= .T.

	self:lArgentina := .F.

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
Method ModelPosVld(oModel,cModelID) Class FINV999
Local lRet 			:= .T. As Logical
Local nOperation	:= oModel:GetOperation() As Numeric
Local nX			:= 0 As Numeric
Local oModelEOP		:= oModel:GetModel("EOP_DETAIL") As Object
Local oModelDOP		:= oModel:GetModel("DOP_DETAIL") As Object
Local oModelPAG		:= oModel:GetModel("PAG_DETAIL") As Object

	If nOperation == MODEL_OPERATION_INSERT

		If lRet .And. oModelEOP:GetValue("NNUMORDENS") < 0
			Help("",1,"SEMORDPAG")
			lRet := .F.
		EndIf

		If lRet
			For nX := 1 To oModelDOP:Length()
				If lRet .And. oModelDOP:GetValue("NVLRPAGAR",nX) < 0
					Help(,,STR0040,,STR0055,1, 0 ) //"Aviso" - "El valor a pagar de la orden de pago no puede ser negativo."
					lRet := .F.
					Exit
				EndIf
				
				//Verifica la naturaleza informada en las ordenes de pago
				If lRet .And. !F999VldNat(oModelDOP:GetValue("CNATUREZA",nX))
					lRet := .F.
					Exit
				EndIf
			Next 
		EndIf

		If lRet
			For nX := 1 To oModelPAG:Length()
				//Verifica que la forma de pago o este vacía cuando el valor a sido informado
				If lRet .And. !Empty(oModelPAG:GetValue("EK_VALOR",nX)) .And. Empty(oModelPAG:GetValue("EK_TIPO",nX))
					Help(,,STR0040,,STR0041,1, 0 ) //"Aviso" - "Hay Ítems que no tienen la forma de pago definida"
					lRet := .F.
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
Method GridLinePosVld(oSubModel, cModelID, nLine) Class FINV999
Local lRet := .T. As Logical
Local nOperation := oSubModel:GetOperation() As Numeric

	If nOperation == MODEL_OPERATION_INSERT
		If cModelID == "PAG_DETAIL"
			If !self:lArgentina .And. IsInCallStack("A085ALNOK")
				If lRet .And. (Empty(oSubModel:GetValue("EK_BANCO")) .Or. Empty(oSubModel:GetValue("EK_AGENCIA")) .Or. Empty(oSubModel:GetValue("EK_CONTA"))) ;
					.And. oSubModel:GetValue("EK_TIPODOC") <> "3"
					Help(,,STR0040,,STR0054,1, 0 ) // "Aviso" - "El banco es obligatorio para débitos mediatos e inmediatos."
					lRet	:=	.F.
				EndIf

				If lRet .And. Alltrim(oSubModel:GetValue("EK_TIPODOC")) == "2" .And. oSubModel:GetValue("EK_VENCTO") <> dDataBase
					Help(" ",1,"BLOQDTVENC")
					lRet	:=	.F.
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} F999VldNat
	Función que valida la naturaleza de la orden de pago
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		08/08/2025
	@param 		
		cNatureza - caracter - Código de la naturaleza de la orden de pago
	@return
		lRet - lógico - indica si la naturaleza es correcta
/*/
Function F999VldNat(cNatureza)

Local lRet 		:= .T.
Local cNatAux 	:= ""
Local aArea		:= {}

Default cNatureza := ""

		If lRet
			//Verifica si existe la naturaleza en la tabla SED
			cNatAux := Padr(cNatureza,GetSx3Cache("ED_CODIGO","X3_TAMANHO"))
			aArea := SED->(GetArea())
			DbSelectArea("SED")
			SED->(DbSetOrder(1)) //ED_FILIAL+ED_CODIGO
			If !SED->(MsSeek(xFilial("SED")+cNatAux))
				Help(,,STR0040,,STR0043,1, 0 ) //"Aviso" - "La modalidad seleccionada no existe."
				lRet := .F.
			EndIf
			RestArea(aArea)
		EndIf

		If lRet .And. !FinVldNat( .F., cNatAux)
			lRet := .F.
		EndIf

Return lRet

/*/{Protheus.doc} F999VldDes
	Función que valida el descuento de la orden de pago
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		08/08/2025
	@param 		
		nDesc    - numérico - Descuento de la orden de pago
		nPorDesc - caracter - Porcentaje de descuento de la orden de pago
	@return
		lRet - lógico - indica si los descuentos son correctos
/*/
Function F999VldDes(nDesc, nPorDesc)

Local lRet 		:= .T.

Default nDesc 	 := 0
Default nPorDesc := 0

		If nDesc < 0 .Or. nPorDesc < 0
			Help(,,STR0040,,STR0042,1, 0 ) //"Aviso" - "Introduzca un valor de descuento mayor o igual que cero."
			lRet := .F.
		EndIf

Return lRet
