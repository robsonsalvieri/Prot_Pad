#include "PROTHEUS.CH"
#include 'FWMVCDEF.CH'
#include "FWBROWSE.CH"
#include "tlpp-object.th"
#include 'FINA999.CH' 

/*/{Protheus.doc} F999RETARG
	Clase responsable por el evento de reglas de negocio de retención de Argentina
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Class F999RETARG From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method VldActivate()
	
	Method ModelPosVld()
	
EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method New() Class F999RETARG
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method VldActivate(oModel) Class F999RETARG
Local lRet			:= .T.

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
Method ModelPosVld(oModel,cModelID) Class F999RETARG
Local lRet 			:= .T. As Logical
Local nOperation	:= oModel:GetOperation() As Numeric
Local nX			:= 0 As Numeric
Local oModelEOP		:= oModel:GetModel("EOP_DETAIL") As Object
Local oModelDOP		:= oModel:GetModel("DOP_DETAIL") As Object

	If nOperation == MODEL_OPERATION_INSERT

		If lRet
			For nX := 1 To oModelDOP:Length()
				If lRet .And. !VldRetIVA(oModelDOP:GetValue("IVA",nX),oModelEOP:GetValue("PA"))
					lRet := .F.
					Exit
				EndIf
			Next 
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} VldRetIVA
	Función que valida la retención de IVA
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		02/09/2025
	@param 		
		nTotalIVA  - numérico  - Total de Retención de IVA
		lPA  	   - lógico    - Moneda de la orden de pago
	@return
		lRet - lógico - indica si puede o no utilizar el título financiero
/*/
Function VldRetIVA(nTotalIVA, lPA)
Local lRet := .T.

Default nTotalIVA 	:= 0
Default lPA			:= .F.

	If !lPA .And. nTotalIVA < 0
		//No se permite retención de IVA negativo
		Help(" ",1,"A085RETIVA")
		lRet := .F.
	Endif

Return lRet
