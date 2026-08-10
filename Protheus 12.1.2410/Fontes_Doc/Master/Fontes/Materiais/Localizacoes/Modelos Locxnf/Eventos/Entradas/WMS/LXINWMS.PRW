#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"
//#INCLUDE "LXINWMS.CH"

/*/{Protheus.doc} LXINWMS
Clase responsable por el evento de reglas de negocio de la integración de WMS.

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Class LXINWMS From FwModelEvent

    //Propiedades que pueden ser alteradas desde los eventos con localización
    DATA oTipoDoc as object

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method ModelPosVld()
    Method GridPosVld()
    Method GridLinePosVld()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Method New() Class LXINWMS 


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
Method Activate(oModel, lCopy) Class LXINWMS

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
Method VldActivate(oModel, cModelId) Class LXINWMS
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
Method ModelPosVld(oModel, cModelId) Class LXINWMS
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
Method GridPosVld(oSubModel, cModelID) Class LXINWMS
Local lRet      := .T.

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
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXINWMS
Local lRet      := .T.
Local cTipoDoc  := ""
Local aArea     := {}
Local aOldData  := {}
Local aColsM    := {}
Local aHeaderM  := {}
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")

    If cModelID == "SD1_DETAIL"
        cTipoDoc    := oModelSF1:GetValue("F1_TIPODOC")
        self:oTipoDoc:SetTipoDoc(cTipoDoc)

        If self:oTipoDoc:ValidWMS() .and. FindFunction("WmsValLiMI") .and. IntWMS()
            aArea := GetArea()
            SF4->(MsSeek(xFilial("SF4")+oSubModel:GetValue("D1_TES", nLine)))

            If SF4->F4_ESTOQUE == "S"
                //Se obtienen los datos de la línea en el formato anterior.
                aOldData := oSubModel:GetOldData()
                aHeaderM := aOldData[1]
                aColsM   := aOldData[2]
                lRet := WmsValLiMI(aColsM, nLine, aHeaderM) //Validaciones realizadas en las funciones pertenecientes a wms.
            EndIf

            RestArea(aArea)
        EndIf

    EndIf
    
Return lRet
