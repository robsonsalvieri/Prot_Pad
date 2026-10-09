#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'tlpp-object.th'
#include 'fina999.ch'

/*/{Protheus.doc} FINV999MEX
	Clase responsable por el evento de reglas de negocio de localización padrón
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Class FINV999MEX From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method ModelPosVld()

EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		29/07/2025
/*/
Method New() Class FINV999MEX
	
Return Nil

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
Method ModelPosVld(oModel,cModelID) Class FINV999MEX
Local lRet 			:= .T. As Logical
Local nOperation	:= oModel:GetOperation() As Numeric
Local oModelEOP		:= oModel:GetModel("EOP_MASTER") As Object
Local oModelFJR		:= oModel:GetModel("FJR_MASTER") As Object
Local cPaisProv     := "" As Character

	If nOperation == MODEL_OPERATION_INSERT
		cPaisProv := GetAdvFVal("SA2","A2_PAIS"	,XFilial("SA2")+oModelFJR:GetValue("FJR_FORNEC")+oModelFJR:GetValue("FJR_LOJA"),1,"")
		If !oModelEOP:GetValue("PA") .And. Empty(oModelFJR:GetValue("DCONCEP", 1)) .And. cPaisProv <> "493"
			Help("",1,"EK_DCONCEP")
			lRet := .F.
		Endif
	EndIf

Return lRet
