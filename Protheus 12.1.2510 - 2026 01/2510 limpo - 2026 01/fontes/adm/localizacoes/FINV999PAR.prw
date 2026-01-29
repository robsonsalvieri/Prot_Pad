#include "PROTHEUS.CH"
#include 'FWMVCDEF.CH'
#include "FWBROWSE.CH"
#include "tlpp-object.th"
#include 'FINA999.CH' 

/*/{Protheus.doc} FINV999PAR
	Clase responsable por el evento de reglas de negocio de localización Paraguay
	@type 		Class
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		15/10/2025
/*/
Class FINV999PAR From FwModelEvent 

	Method New() CONSTRUCTOR
	
	Method ModelPosVld()
	
EndClass

/*/{Protheus.doc} New
	Metodo responsable de la contrucción de la clase.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		15/10/2025
/*/
Method New() Class FINV999PAR
	
Return Nil

/*/{Protheus.doc} ModelPosVld
	Método responsable por ejecutar las validaçioes de las reglas de negocio
	genéricas del cadastro antes de la grabación del formulario.
	Si retorna falso, no permite grabar.
	@type 		Method
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		15/10/2025
	@param 		
		oModel	 ,objeto	,Modelo de dados.
		cModelID ,caracter	,Identificador do sub-modelo.
	@return
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Method ModelPosVld(oModel,cModelID) Class FINV999PAR
Local lRet 			:= .T. As Logical
Local nOperation	:= oModel:GetOperation() As Numeric
Local nX			:= 0 As Numeric
Local oModelDOP		:= oModel:GetModel("DOP_DETAIL") As Object

	If nOperation == MODEL_OPERATION_INSERT

		If lRet
			For nX := 1 To oModelDOP:Length()				
				If lRet .And. (oModelDOP:GetValue("IVA",nX) > 0 .Or. oModelDOP:GetValue("IR",nX) > 0) .And. !F999VldCer()
					lRet := .F.
					Exit
				EndIf
			Next 
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} F999VldCer
	Función que valida la configuración del número de certificado en la tabla SFP
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		02/09/2025
	@param 		
	@return
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Function F999VldCer()
Local lRet  	:= .T.
Local aArea 	:= {}
Local aGetSx5   := {}
Local nTamCert  := GetSx3Cache("FE_NROCERT","X3_TAMANHO")
Local cCombo 	:= ""
Local nPos		:= 0
Local cNumCert  := ""
Local nNumCert  := 0
Local cFilSFP   := ""

	aGetSx5  := FwGetSX5("99", "IVA")
	cNumCert := IIF(Len(aGetSx5) == 0,  PadL("1", nTamCert, "0"), StrZero(Val(aGetSx5[1][4])+1, nTamCert))
	cCombo   := Alltrim(GetSx3Cache("FP_ESPECIE","X3_CBOX"))
	nPos 	 := At("RET",cCombo)
	cCombo 	 := Substr(cCombo,nPos-2,1)

	aArea := SFP->(GetArea())
	DbSelectArea("SFP")
	SFP->(DbSetOrder(6)) //FP_FILIAL+FP_FILUSO+FP_ESPECIE+FP_SERIE+FP_NUMINI
	cFilSFP := xFilial("SFP")
	If SFP->(MsSeek(cFilSFP+cFilAnt+cCombo))
		lRet := .F.
		nNumCert := Val(cNumCert)
		While !SFP->(EOF()) .And. SFP->FP_FILIAL+SFP->FP_FILUSO+SFP->FP_ESPECIE == cFilSFP+cFilAnt+cCombo
			If nNumCert >= Val(SFP->FP_NUMINI) .And. nNumCert <= Val(SFP->FP_NUMFIM) .And. dDataBase <= SFP->FP_DTAVAL
				lRet := .T.
				Exit
			EndIf
			SFP->(DbSkip())
		Enddo

		If !lRet
			Help(,, STR0040,, STR0062 + AllTrim(cNumCert) + STR0063, 1, 0) //"Aviso" - "El comprobante de retención " # " no tiene un número de timbrado autorizado o la fecha de validez está vencida."
		EndIf
	Else
		Help(,, STR0040,, STR0064, 1, 0) //"Aviso" - "No existe un archivo de control de timbrados."
		lRet := .F.
	EndIf
	RestArea(aArea)

Return lRet
