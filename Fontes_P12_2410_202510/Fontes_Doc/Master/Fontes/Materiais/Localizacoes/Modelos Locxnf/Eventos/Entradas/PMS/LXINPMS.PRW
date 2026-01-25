#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} LXINPMS
Clase responsable por el evento de reglas de negocio de la integración de WMS.

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Class LXINPMS From FwModelEvent

    //Propiedades que pueden ser alteradas desde los eventos con localización
    DATA oTipoDoc as object

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method ModelPosVld()
    Method GridPosVld()
    Method GridLinePosVld()
    Method QuantAFN()
    Method ValidQuant()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Method New() Class LXINPMS 


Return Nil

/*/{Protheus.doc} Activate
Metodo activate

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		lCopy    ,caracter	,Informa si el model debe copiar los datos del registro posicionado.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Method Activate(oModel, lCopy) Class LXINPMS

    self:oTipodoc := TipoDoc():New()

Return

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Method VldActivate(oModel, cModelId) Class LXINPMS
Local lRet := .T.

Return lRet

/*/{Protheus.doc} ModelPosVld
Método responsable por ejecutar las validaçioes de las reglas de negocio
genéricas del cadastro antes de la grabación del formulario.
Si retorna falso, no permite grabar.

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Method ModelPosVld(oModel, cModelId) Class LXINPMS
Local lRet      := .T. 

Return lRet

/*/{Protheus.doc} GridPosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validación de grid.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		06/2023
/*/
Method GridPosVld(oSubModel, cModelID) Class LXINPMS
Local lRet      := .T.
Local lPMS      := IntePms()
Local cTipoDoc  := ""
Local nD1Line   := 0
Local nX        := 0
Local nTotAFN   := 0
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")

    If cModelID == "SD1_DETAIL" .and. lPMS
        cTipoDoc    := oModelSF1:GetValue("F1_TIPODOC")
        self:oTipoDoc:SetTipoDoc(cTipoDoc)

        //Validación de todos los items antes de la grabación.
        If self:oTipoDoc:ValidPMS() 
            nD1Line := oSubModel:GetLine()
            For nX := 1 To oSubModel:Length()
                oSubModel:GoLine(nX)
                If !oSubModel:IsDeleted()
                    nTotAFN := self:QuantAFN(oSubModel:GetValue("D1_ITEM"))
                    lRet := self:ValidQuant(oSubModel:GetValue("D1_PEDIDO"), oSubModel:GetValue("D1_ITEMPC"), nTotAFN, oSubModel:GetValue("D1_QUANT"))
                EndIf
            Next
            oSubModel:GoLine(nD1Line)
        EndIf

    EndIf

Return lRet

/*/{Protheus.doc} GridLinePosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validación de línea.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,Número de línea validada
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		06/2023
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXINPMS
Local lRet      := .T.
Local lPMS      := IntePms()
Local nTotAFN	:= 0
Local cTipoDoc  := ""
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")

    If cModelID == "SD1_DETAIL" .and. lPMS
        cTipoDoc    := oModelSF1:GetValue("F1_TIPODOC")
        self:oTipoDoc:SetTipoDoc(cTipoDoc)
        If self:oTipoDoc:ValidPMS() 
            nTotAFN := self:QuantAFN(oSubModel:GetValue("D1_ITEM", nLine))
            lRet := self:ValidQuant(oSubModel:GetValue("D1_PEDIDO", nLine), oSubModel:GetValue("D1_ITEMPC", nLine), nTotAFN, oSubModel:GetValue("D1_QUANT", nLine))
        EndIf
    EndIf
    
Return lRet

/*/{Protheus.doc} QuantAFN
Metodo responsabe por regresar la cantidad relacionada con el item.
@type 		Method
@param 		cItem	,caracter	, item del cual se buscara la cantidad.
@Return     nTotAFN     ,numerico    ,Cantidad relacionada al item.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		06/2023
/*/
Method QuantAFN(cItem) Class LXINPMS
Local nTotAFN	:= 0
Local nX        := 0
Local nAFline   := 0
Local oModel    := FwModelActivate()
Local oModelAFN := oModel:GetModel("AFN_DETAIL")

Default cItem   := ""

    nAFline := oModelAFN:GetLine()
    For nX := 1 To oModelAFN:Length()
        oModelAFN:GoLine(nX)
        If !oModelAFN:IsDeleted()
            If oModelAFN:GetValue("AFN_ITEM") == cItem //Suma las cantidades del prorrateo estre tareas/proyecto
                nTotAFN += oModelAFN:GetValue("AFN_QUANT")
            EndIf
        EndIf
    Next
    oModelAFN:GoLine(nAFline)

Return nTotAFN

/*/{Protheus.doc} ValidQuant
Metodo responsabe por realizar la validación de que la cantidad en la factura sea mayor o igual que la asiganada en PMS
@type 		Method
@param 		cPedido	, caracter	, numero del pedido.
@param 		cItemPC	, caracter	, item del pedido.
@param 		nTotAFN	, numerico	, cantidad asiganada al proyecto de PMS.
@param 		nQuant	, numerico	, cantidad del documento
@Return     lRet    , logico    , Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		06/2023
/*/
Method ValidQuant(cPedido, cItemPC, nTotAFN, nQuant) Class LXINPMS
Local lRet := .T.

Default cPedido := ""
Default cItemPC := ""
Default nTotAFN := 0
Default nQuant  := 0

    If !PMSNFSA(cPedido, cItemPC)[1]
        //LA cantidad del documento no puede ser mejor que la asiganada al proyecto PMS.
        If nTotAFN > nQuant
            Help("   ",1,"PMSQTNF")
            lRet := .F.
        Endif
    Endif
        
Return lRet
