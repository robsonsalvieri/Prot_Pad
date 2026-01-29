#include "PROTHEUS.CH"
#include 'FWMVCDEF.CH'
#include "FWBROWSE.CH"
#include "tlpp-object.th"
#include 'FINA999.CH' 

/*/{Protheus.doc} F999BCO
	Clase responsable por el evento de reglas de negocio de bancos
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Class F999BCO From FwModelEvent 

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
Method New() Class F999BCO
	
Return Nil

/*/{Protheus.doc} VldActivate
	Metodo responsable de las validaciones al activar el modelo
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method VldActivate(oModel) Class F999BCO
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
Method ModelPosVld(oModel,cModelID) Class F999BCO
Local lRet 			:= .T. As Logical
Local nOperation	:= oModel:GetOperation() As Numeric
Local nX			:= 0 As Numeric
Local oModelPAG		:= oModel:GetModel("PAG_DETAIL") As Object
Local oModelEOP		:= oModel:GetModel("EOP_DETAIL") As Object

	If nOperation == MODEL_OPERATION_INSERT

		If lRet
			For nX := 1 To oModelPAG:Length()
				//Verifica si el banco es valido cuando el valor a sido informado
				If (!Empty(oModelPAG:GetValue("EK_VALOR",nX)) .Or. ;
					(oModelEOP:GetValue("PA",nX) .And. oModelEOP:GetValue("NPAGAR",nX) > 0 .And. oModelEOP:GetValue("NPAGAR",nX) < 4));
					.And. !F999VldBco(oModelPAG:GetValue("EK_BANCO",nX),oModelPAG:GetValue("EK_AGENCIA",nX),oModelPAG:GetValue("EK_CONTA",nX))
					lRet := .F.
					Exit
				EndIf
			Next
		EndIf	

	EndIf

Return lRet

/*/{Protheus.doc} F999VldBco
	Función que valida el banco de la forma de pago
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		08/08/2025
	@param 		
		cBco   - caracter - Banco
		cAge   - caracter - Agencia
		cConta - caracter - Cuenta
	@return
		lRet - lógico - indica si el banco es correcto
/*/
Function F999VldBco(cBco, cAge, cConta)

Local lRet 		:= .T.
Local aArea		:= {}

Default cBco 	:= ""
Default cAge 	:= ""
Default cConta 	:= ""

		If lRet .And. Empty(cBco) .Or. Empty(cAge) .Or. Empty(cConta)
			Help("",1,"BCOBRANCO")
			lRet := .F.
		EndIf

		//Verifica si existe el banco en la tabla SA6
		If lRet
			aArea := SA6->(GetArea())
			DbSelectArea("SA6") 
			SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
			If !SA6->(MsSeek(xFilial("SA6")+cBco+cAge+cConta))
				Help("",1,"BCONAOCAD")
				lRet := .F.
			EndIf
			RestArea(aArea)
		EndIf

Return lRet
