#include "PROTHEUS.CH"
#include 'FWMVCDEF.CH'
#include "FWBROWSE.CH"
#include "tlpp-object.th"
#include 'FINA999.CH' 

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
	
	Method GridLinePosVld()

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
Local oModelDOP		:= oModel:GetModel("DOP_DETAIL") As Object

	If nOperation == MODEL_OPERATION_INSERT
		cPaisProv := GetAdvFVal("SA2","A2_PAIS"	,XFilial("SA2")+oModelDOP:GetValue("FORNECE")+oModelDOP:GetValue("LOJA"),1,"")
		If Empty(oModelDOP:GetValue("DCONCEP")) .And. cPaisProv <> "493"
			Help("",1,"EK_DCONCEP")
			lRet := .F.
		Endif
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
Method GridLinePosVld(oSubModel, cModelID, nLine) Class FINV999MEX
Local lRet := .T. As Logical
Local nOperation := oSubModel:GetOperation() As Numeric

	If nOperation == MODEL_OPERATION_INSERT
		If cModelID == "PAG_DETAIL"
			
		EndIf
	EndIf

Return lRet
