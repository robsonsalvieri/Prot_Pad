#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887RETPAR
Clase responsable por el evento de reglas de negocio de 
localización de retenciones de Paraguay

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		10/2021
/*/
Class F887RETPAR From FwModelEvent 

	Method New() CONSTRUCTOR

	Method Destroy()
	
	Method InTTS()
	
	Method UPDSFE()

	Method GridLinePosVld()

	Method ModelPosVld()

	Method GridLinePreVld()

	Method SeekCert()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		10/2021 
/*/
Method New() Class F887RETPAR
	
Return Nil	


/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		10/2021 
/*/
Method Destroy() Class F887RETPAR

Return Nil


/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		10/2021 
/*/
Method InTTS(oModel, cModelId) Class F887RETPAR
Local nOperation	:= oModel:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT
		self:UPDSFE(oModel)
	EndIf
	

Return Nil

/*/{Protheus.doc} UPDSFE
Metodo responsable por ejecutar reglas de negocio de Retenciones 
para la localización de Paraguay

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.

@author 	raul.medina
@version	12.1.27 / Superior
@since		10/2021 
/*/
Method UPDSFE(oModel) Class F887RETPAR
Local nOperation	:= 0
Local nX			:= 0
Local nY			:= 0
Local oModelFJT
Local oModelSEL
Local oModelSFE
Local cRecibo		:= ""
Local cSerie		:= ""
Local cCliente		:= ""
Local cLoja			:= ""
Local cNumeroSEL	:= ""
Local cPrefixSEL	:= ""
Local cTipo			:= ""
Local lCfo 			:= SFE->(ColumnPos("FE_CFO")) > 0
Local lCfoSEL 		:= SEL->(ColumnPos("EL_CFO")) > 0 .And. lCfo
local lRecmvc 		:= SuperGetMv("MV_RECMVC",.F.,.F.)


Default oModel		:= FWModelActive() 

	nOperation := oModel:GetOperation()
	oModelFJT := oModel:GetModel('FJT_MASTER')
	oModelSEL := oModel:GetModel('SEL_DETAIL')
	oModelSFE := oModel:GetModel('SFEGRID')

	cRecibo := oModelFJT:GetValue("FJT_RECIBO")
	cSerie := oModelFJT:GetValue("FJT_SERIE")
	cCliente := oModelFJT:GetValue("FJT_CLIENT")
	cLoja := oModelFJT:GetValue("FJT_LOJA")

	//Se verifican las forma de pago registradas, si existen retenciones RI o RR, se verifica si existen certificados de retención y son grabados. 
	//Sólo se consideran los certificados con valor en el campo FE_RETENC, si FE_RETENC es 0 no será grabada la línea.
	For nX := 1 To oModelSEL:Length()
		If AllTrim(oModelSEL:GetValue("EL_TIPODOC",nX)) $ "RI|RR"
			If lRecmvc
				cTipo := SubStr(oModelSEL:GetValue("EL_TIPODOC",nX), 2, 1)
				cNumeroSEL := oModelSEL:GetValue("EL_NUMERO",nX)
				cPrefixSEL := oModelSEL:GetValue("EL_PREFIXO",nX)
				For nY := 1 To oModelSFE:Length()
					If !oModelSFE:IsDeleted(nY) .and. cTipo ==  oModelSFE:GetValue("FE_TIPO", nY) .and. cNumeroSEL == oModelSFE:GetValue("ELNUMERO", nY) .and. cPrefixSEL == oModelSFE:GetValue("ELPREFIX", nY) .and. oModelSFE:GetValue("FE_RETENC", nY) > 0
						RecLock("SFE",.T.)
							FE_TIPO		:= cTipo
							FE_FILIAL   := xFilial('SFE')   
							FE_EMISSAO  := oModelSEL:GetValue("EL_EMISSAO", nX)
							FE_CLIENTE  := cCliente
							FE_LOJCLI 	:= cLoja
							FE_RECIBO   := cRecibo
							FE_NFISCAL	:= oModelSFE:GetValue("FE_NFISCAL", nY)
							FE_SERIE    := oModelSFE:GetValue("FE_SERIE", nY)
							FE_RETENC 	:= oModelSFE:GetValue("FE_RETENC", nY)
							FE_VALBASE 	:= oModelSFE:GetValue("FE_VALBASE", nY)
							FE_ALIQ		:= oModelSFE:GetValue("FE_ALIQ", nY)
							If lCfo
								FE_CFO		:= oModelSFE:GetValue("FE_CFO", nY)
							EndIf
							FE_NROCERT	:= oModelSFE:GetValue("FE_NROCERT", nY)
						MsUnlock()
					EndIf
				Next
			Else
				If oModelSEL:GetValue("EL_VALIMP1",nX) > 0
					RecLock("SFE",.T.)
						FE_TIPO		:= Iif(oModelSEL:GetValue("EL_TIPODOC",nX)=="RI","I","R")
						FE_FILIAL   := xFilial('SE1')   
						FE_EMISSAO  := oModelSEL:GetValue("EL_EMISSAO",nX)
						FE_CLIENTE  := oModelSEL:GetValue("EL_CLIENTE",nX)
						FE_LOJCLI 	:= oModelSEL:GetValue("EL_LOJA",nX)
						FE_RECIBO   := oModelSEL:GetValue("EL_RECIBO",nX)
						FE_NFISCAL	:= oModelSEL:GetValue("EL_DOCTO",nX)
						FE_SERIE    := oModelSEL:GetValue("EL_SDOCTO",nX)
						FE_RETENC 	:= oModelSEL:GetValue("EL_VALOR",nX)
						FE_VALBASE 	:= oModelSEL:GetValue("EL_VALIMP1",nX)
						FE_ALIQ		:= oModelSEL:GetValue("EL_ALQIMP1",nX)
						If lCfoSEL
							FE_CFO	:= oModelSEL:GetValue("EL_CFO",nX)
						EndIf
						FE_NROCERT	:= oModelSEL:GetValue("EL_NUMERO",nX)
					MsUnlock()
				EndIf
			EndIf
		EndIf
	Next nX
Return Nil

/*/{Protheus.doc} GridLinePosVld
Metodo responsable de hacer una post-validacion al modelo

@type 		Method

@param 		oModel	,objeto	, modelo de datos
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.2210 / Superior
@since		11/2024 
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class F887RETPAR
Local lRet 			:= .T.
Local lEdit			:= .F.
Local oModel        := FWModelActive() 
Local nOperation	:= oModel:GetOperation()
Local aCampos		:= {}
Local nX			:= 0

	If (cModelID == 'SFEGRID') .AND. (nOperation == MODEL_OPERATION_INSERT)
		aCampos := {"FE_VALBASE", "FE_ALIQ", "FE_RETENC", "FE_CFO", "FE_NROCERT"} //Campos que deben de ser llanados en la pantalla de retenciones.
		
		//Valida si existe un campo informado de retenciones.
		For nX := 1 to Len(aCampos)
			If !Empty(oSubModel:GetValue(aCampos[nX], nLine))
				lEdit := .T.
				Exit
			EndIf
		Next

		If lEdit //Si existe algún campo informado se valida que todos estén informados.
			For nX := 1 to Len(aCampos)
				If Empty(oSubModel:GetValue(aCampos[nX], nLine))
					lRet := .F.
					Help( " ", 1, "LINECER",, STR0211 + AllTrim(FwX3Titulo(aCampos[nX])),1,0) //"No se informó el campo: "
					Exit
				EndIf
			Next
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} ModelPosVld
Método responsable por ejecutar las validaçioes de las reglas de negocio
genéricas del cadastro antes de la grabación del formulario.
Si retorna falso, no permite grabar.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelID ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.2210 / Superior
@since		11/2024 
/*/
Method ModelPosVld(oModel,cModelID) Class F887RETPAR
Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()
Local oModelSEL
Local nLine			:= 0
Local nSelLine		:= 0
Local cTipoDoc		:= ""	

	If nOperation == MODEL_OPERATION_INSERT
		//Validación de certificados de retención.
		oModelSEL := oModel:GetModel("SEL_DETAIL")
		nSelLine := oModelSEL:GetLine()
		For nLine := 1 To oModelSEL:Length()
			If lRet .and. !oModelSEL:IsDeleted()
				cTipoDoc := AllTrim(oModelSEL:GetValue("EL_TIPODOC",nLine))
				//Si se encuentra un registro de renteción se verifica si existen certificados y que los valores sean correctos.
				If cTipoDoc == "RI" .Or. cTipoDoc == "RR" 
					lRet := F887ValCer(oModel, Substr(cTipoDoc,2,1), oModelSEL:GetValue("EL_NUMERO", nLine), oModelSEL:GetValue("EL_PREFIXO", nLine), oModelSEL:GetValue("EL_VALOR", nLine))
				EndIf
			EndIf
		Next
		oModelSEL:GoLine(nSelLine)
	EndIF

Return lRet

/*/{Protheus.doc} FieldPreVld
Metodo responsabe por ejecutar pre validaciones del campo.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param      nLine       ,numerico   ,Número de línea procesada.
@param 		cAction 	,caracter	,Identificador de la acción realizada (CANSETVALUE/SETVALUE).
@param 		cId     	,caracter	,Identificador del campo ejecutado.
@param 		xValue  	,       	,Valor recibido del campo.
@param      xCurrentValue,          , 
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		11/2024
/*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class F887RETPAR
Local lRet      := .T.
Local lDel		:= .F.
Local lAltNum	:= .F.
Local lCert		:= .F.
Local aSeek		:= {}
Local nX		:= 0
Local cTipoDoc	:= ""
Local oModel    := FwModelActivate()
Local oModelSEL
Local oModelSE1

    If cModelID == "SEL_DETAIL"
        lDel := cAction == "DELETE"
		lAltNum := cAction == "SETVALUE" .and. cId == "EL_NUMERO" .and. !Empty(xCurrentValue) .and. xValue <> xCurrentValue
		//Si se realizan un borrado de una reteción o se modifica la númeración y existen certificados se indicara al usuario que serán eliminados los certificados,
		//si el usuario no acepta el borrado de los certificados tampco será eliminada la retención.
		If lDel .Or. lAltNum
			If AllTrim(oSubModel:GetValue("EL_TIPODOC", nLine)) $ "RI|RR"
				oModelSE1 := oModel:GetModel("SE1_DETAIL")
				For nX := 1 To oModelSE1:Length()
					If lRet .and. !lCert .and. (oModelSE1:GetValue("CHECK", nX) .or. oModelSE1:GetValue("BAIXAR", nX) > 0)
						aSeek := {}
						aAdd(aSeek, {"FE_NFISCAL"	, oModelSE1:GetValue("E1_NUM",nX)})
						aAdd(aSeek, {"FE_SERIE"		, oModelSE1:GetValue("E1_PREFIXO",nX)})	
						aAdd(aSeek, {"FE_PARCELA"	, oModelSE1:GetValue("E1_PARCELA",nX)})
						aAdd(aSeek, {"TIPODOC"		, oModelSE1:GetValue("E1_TIPO",nX)})
						aAdd(aSeek, {"ELNUMERO"		, oSubModel:GetValue("EL_NUMERO",nLine)})
						aAdd(aSeek, {"ELPREFIX"		, oSubModel:GetValue("EL_PREFIXO",nLine)})	
						aAdd(aSeek, {"FE_TIPO"		, SubStr(oSubModel:GetValue("EL_TIPODOC",nLine), 2, 1)})
						lRet := self:SeekCert(oModel, aSeek, @lCert)
					EndIf
				Next
				//Si el usuario modificó el número de una retención serán eliminados los certificados.
				If lAltNum .and. lRet
					F887ELDlCr(oModel, .F., .F., .T.)
				EndIf
			EndIf
        EndIf
	ElseIf cModelID == "SE1_DETAIL"
		If cAction == "SETVALUE"
			If cId == "CHECK" .and. xCurrentValue .and. !xValue
				oModelSEL := oModel:GetModel("SEL_DETAIL")
				//Al desmarcar un título es verificado si existen retenciones y si estás tienen certificados asociados al título.
				//Si existen certificado se inidica al usuario que serán eliminados, si el usuario no acepta, no será desmarcado el título.
				For nX := 1 To oModelSEL:Length()
					If lRet .and. !lCert .and. !oModelSEL:IsDeleted(nX)
						cTipoDoc := AllTrim(oModelSEL:GetValue("EL_TIPODOC",nX))
						If cTipoDoc == "RI" .Or. cTipoDoc == "RR"
							aSeek := {}
							aAdd(aSeek, {"FE_NFISCAL"	, oSubModel:GetValue("E1_NUM",nLine)})
							aAdd(aSeek, {"FE_SERIE"		, oSubModel:GetValue("E1_PREFIXO",nLine)})	
							aAdd(aSeek, {"FE_PARCELA"	, oSubModel:GetValue("E1_PARCELA",nLine)})
							aAdd(aSeek, {"TIPODOC"		, oSubModel:GetValue("E1_TIPO",nLine)})
							aAdd(aSeek, {"ELNUMERO"		, oModelSEL:GetValue("EL_NUMERO",nX)})
							aAdd(aSeek, {"ELPREFIX"		, oModelSEL:GetValue("EL_PREFIXO",nX)})	
							aAdd(aSeek, {"FE_TIPO"		, SubStr(cTipoDoc, 2, 1)})
							lRet := self:SeekCert(oModel, aSeek, @lCert)
						EndIf
					EndIf
				Next
			EndIf
		EndIf
	ElseIf cModelID == "SFEGRID"
		If cAction == "SETVALUE"
			oModelSEL := oModel:GetModel("SEL_DETAIL")
			If !(oModelSEL:GetValue("EL_NUMERO") == oSubModel:GetValue("ELNUMERO",nLine) .and. oModelSEL:GetValue("EL_PREFIXO") == oSubModel:GetValue("ELPREFIX",nLine) .and.;
				SubStr(oModelSEL:GetValue("EL_TIPODOC"), 2, 1) == oSubModel:GetValue("FE_TIPO",nLine))
				Help('FINA887',/*nLinha*/,STR0205,/*cNome*/,STR0212,1,0)//"STR0205-Certificados de Retención" - "STR0212-No es posible modificar este registro, pues no pertenece a la retención seleccionada."
				lRet := .F.
			EndIf
		EndIf
    EndIf

Return lRet

/*/{Protheus.doc} SeekCert
Metodo utilizado para buscar certificados de acuerdo a las llaves de busqueda.
@author 	raul.medina
@since 		11/2024
@version	12.1.2210 / Superior
Parametros
    oModel - - modelo activo
	aSeek - array - Arreglo con la llave de busqueda.
	lCert - logico - Usado para verificar si se encotraron certificados con valor. (Usado por parámetro por referecia @lCert)
@Return 
/*/
Method SeekCert(oModel, aSeek, lCert) Class F887RETPAR
Local lRet      := .T.
Local nSFELine	:= 0
Local oModelSFE
Local oView


Default oModel	:= FwModelActivate()
Default aSeek	:= {}
Default lCert	:= .F.

	oModelSFE := oModel:GetModel("SFEGRID")

	nSFELine := oModelSFE:GetLine()
	//Se realiza la busqueda de certiticados con la llave recibida.
	If oModelSFE:SeekLine(aSeek, .F., .T.)
		//Si existen certificados configurados pregunta al usuario que para continuar deben ser eliminados.
		If oModelSFE:GetValue("FE_RETENC") > 0
			oView := FwViewActive()
			If ValType(oView) == "O"
				lRet := MsgYesNo(STR0213) //"Existen certificados de retenciones para este registro que serán eliminados. ¿Desea continuar?"
				If !lRet
					oModel:SetErrorMessage('', '' , '' , '' ,"DELCERT" , STR0214) //"Acción cancelada"
				EndIf
				lCert := .T.
			EndIf
		EndIf
	EndIf
	oModelSFE:GoLine(nSFELine)

Return lRet

