#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} LXOUTWMS
Clase responsable por el evento de reglas de negocio de la integración de WMS.

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		07/2023
/*/
Class LXOUTWMS From FwModelEvent

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
@since		07/2023
/*/
Method New() Class LXOUTWMS 


Return Nil

/*/{Protheus.doc} Activate
Metodo activate

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		lCopy    ,caracter	,Informa si el model debe copiar los datos del registro posicionado.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		07/2023
/*/
Method Activate(oModel, lCopy) Class LXOUTWMS

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
@since		07/2023
/*/
Method VldActivate(oModel, cModelId) Class LXOUTWMS
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
@since		07/2023
/*/
Method ModelPosVld(oModel, cModelId) Class LXOUTWMS
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
@since		07/2023
/*/
Method GridPosVld(oSubModel, cModelID) Class LXOUTWMS
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
@since		07/2023
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXOUTWMS
Local lRet          := .T.
Local cTipoDoc      := ""
Local aArea         := {}
Local aOldData      := {}
Local aColsM        := {}
Local aHeaderM      := {}
Local nPosServ      := 0
Local nPosLotCtl    := 0
Local nPosLocalz    := 0
Local cEspecie      := ""
Local oModel        := FwModelActivate()
Local oModelSF2     := oModel:GetModel("SF2_MASTER")

    If cModelID == "SD2_DETAIL"
        cTipoDoc    := oModelSF2:GetValue("F2_TIPODOC")
        self:oTipoDoc:SetTipoDoc(cTipoDoc)

        If self:oTipoDoc:ValidWMS() .and. FindFunction("WmsVldReMI")
            aArea := GetArea()
            SF4->(MsSeek(xFilial("SF4")+oSubModel:GetValue("D2_TES", nLine)))

            If SF4->F4_ESTOQUE == "S"
                //Se obtienen los datos de la línea en el formato anterior.
                aOldData := oSubModel:GetOldData()
                aHeaderM := aOldData[1]
                aColsM   := aOldData[2]

                //Posiciones de los campos en el aheader.
                nPosServ      := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_SERVIC"  })
                nPosLotCtl    := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_LOTECTL" })
                nPosLocalz    := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_LOCALIZ" })
                cEspecie      := AllTrim(oModelSF2:GetValue("F2_ESPECIE"))

                lRet := WmsVldReMI("SD2"  , cTipoDoc, nLine, aColsM , @aColsM,cEspecie, aHeaderM)
                oSubModel:GetOldData()[2] := aColsM

                oSubModel:aDataModel[nLine][1][2][nPosServ] := .T. //Se indica que el campo D2_SERVIC fue editado, para poder realizar la actualización en la locxnf en caso de ser necesario.
                oSubModel:aDataModel[nLine][1][2][nPosLocalz] := .T. //Se indica que el campo D2_LOCALIZ fue editado, para poder realizar la actualización en la locxnf en caso de ser necesario.
                oSubModel:aDataModel[nLine][1][2][nPosLotCtl] := .T. //Se indica que el campo D2_LOTECTL fue editado, para poder realizar la actualización en la locxnf en caso de ser necesario.
            EndIf

            RestArea(aArea)
        EndIf

    EndIf
    
Return lRet
