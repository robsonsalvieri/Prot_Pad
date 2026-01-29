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

    DATA lPeru As Logical

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

	self:lPeru 		:= .F.

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
Local lPa085a		:= IsInCallStack("A085APgAdi")

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
				If lRet .And. !lPa085a .And. (self:lArgentina .Or. oModelDOP:GetValue("NVLRPAGAR",nX) <> 0) .And. !F999VldNat(oModelDOP:GetValue("CNATUREZA",nX))
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

		If lRet .And. oModelEOP:GetValue("PA")
			If oModelDOP:GetValue("TOTAL") < 0
				Help(" ",1,"VALNEG")
				lRet := .F.
			EndIf

			If lRet .And. !F999VlProv(oModelDOP:GetValue("FORNECE"), oModelDOP:GetValue("LOJA"))
				Help(" ",1,"NOFORNEC")
				lRet := .F.
			EndIf

			If lRet .And. oModelEOP:GetValue("NPAGAR") <> 3 .And. oModelEOP:GetValue("NPAGAR") > 0 .And. oModelPAG:GetValue("EK_BANCO") $ SuperGetMV("MV_CARTEIR")
				Help("",1,"a085ChqCar")
				lRet := .F.
			EndIf
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
Local lRet		 := .T. As Logical
Local nX   		 := 0 As Numeric
Local nOperation := oSubModel:GetOperation() As Numeric
Local aArea		 := {}
Local cChaveSE2  := ""

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

				If lRet
					For nX := 1 To oSubModel:Length()
						If nX <> nLine .And. oSubModel:GetValue("EK_TIPO", nX) + oSubModel:GetValue("EK_TIPODOC", nX) +;
						oSubModel:GetValue("EK_NUM", nX) + oSubModel:GetValue("EK_PARCELA", nX) == ;
						oSubModel:GetValue("EK_TIPO", nLine) + oSubModel:GetValue("EK_TIPODOC", nLine) +;
						oSubModel:GetValue("EK_NUM", nLine) + oSubModel:GetValue("EK_PARCELA", nLine)
							Help(" ",1,"FA050NUM")
							lRet	:=	.F.
							Exit
						Endif
					Next
				EndIf

				If lRet
					aArea := SE2->(GetArea())
					cChaveSE2 := xFilial("SE2")+Space(GetSx3Cache("E2_PREFIXO","X3_TAMANHO"))+oSubModel:GetValue("EK_NUM")+oSubModel:GetValue("EK_PARCELA")+oSubModel:GetValue("EK_TIPO")
					DbSelectArea("SE2")
					SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
					If SE2->(MsSeek(cChaveSE2))
						While lRet .And. !SE2->(EOF()) .And. cChaveSE2 == xFilial("SE2")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
							If SE2->E2_BCOCHQ == oSubModel:GetValue("EK_BANCO") .And. SE2->E2_AGECHQ == oSubModel:GetValue("EK_AGENCIA") .And. SE2->E2_CTACHQ == oSubModel:GetValue("EK_CONTA")
								Help(" ",1,"CHEQJAEXIST")
								lRet :=	.F.
							EndIf
							SE2->(DbSkip())
						EndDo
					Endif
					RestArea(aArea)
				EndIf

				If lRet .And. self:lPeru .And. !F999CkPG(oSubModel:GetValue("EK_BANCO"),Alltrim(oSubModel:GetValue("EK_TIPO")),Alltrim(oSubModel:GetValue("EK_TIPODOC")))
					lRet :=	.F.
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

/*/{Protheus.doc} F999CkPG
	Función que valida si el banco recibe asiento dependiendo del tipo de débito y la forma de pago
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		07/10/2025
	@param 		
		cBanco  - caracter - Código de Banco
		cDebInm - caracter - Tipo de forma de pago
		cPagar  - caracter - Tipo de débito
	@return
		lRet - lógico - indica si las validaciones fueron satisfactorias
/*/
Function F999CkPG(cBanco, cDebInm, cPagar)

Local lRet 		 := .T.
Local lF85ABCVLD := ExistBlock("F85ABCVLD")
Local cCxFin	 := Left(SuperGetMv("MV_CXFIN"),GetSx3Cache("A6_COD","X3_TAMANHO")) + "/" + SuperGetMv("MV_CARTEIR")

Default cBanco 	 := ""
Default cDebInm  := ""
Default cPagar	 := ""

	If !lF85ABCVLD
		If !Empty(cBanco) .And. cBanco $ cCxFin .Or. IsCaixaLoja(cBanco)
			If cPagar == "2" .And. cDebInm == "TF"
				Help(,,STR0040,,STR0058+cBanco+STR0059,1, 0) //"Aviso" - "El Banco # no recibe asientos del tipo TF."
				lRet := .F.
			Elseif cPagar == "1" .Or. cPagar == "2"
				Help(,,STR0040,,STR0058+cBanco+STR0060,1, 0) //"Aviso" - "El Banco # no recibe asientos del tipo CH."
				lRet := .F.
			Endif
		Endif
	Else
		lRet := ExecBlock("F85ABCVLD",.F.,.F.,{cDebInm,cBanco,Val(cPagar)})
	EndIf
	
Return lRet

/*/{Protheus.doc} F999VlProv
	Función que valida si el proveedor/tienda informado es válido
	@type 		Function
	@author 	carlos.espinoza
	@version	12.1.2310 / Superior
	@since		05/11/2025
	@param 		
		cProveedor - caracter - Código del proveedor
		cLoja      - caracter - Tienda del proveedor
	@return
		lRet - lógico - indica si el proveedor/tienda es correcto
/*/
Function F999VlProv(cProveedor, cLoja)

Local lRet 		:= .T.
Local aArea		:= {}

Default cProveedor := ""
Default cLoja	   := ""

	aArea := SA2->(GetArea())
	SA2->(DbsetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA
	If !SA2->(MsSeek(xFilial("SA2")+cProveedor+cLoja))
		lRet := .F.
	EndIf
	RestArea(aArea)

Return lRet
