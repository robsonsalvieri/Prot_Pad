#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} LXINPCO
Clase responsable por el evento de reglas de negocio de la integración de WMS.

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Class LXINPCO From FwModelEvent

    //Propiedades que pueden ser alteradas desde los eventos con localización
    DATA oTipoDoc as object
    DATA aItemPCO as array
    DATA aLancPCO as array

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method ModelPosVld()
    Method GridPosVld()
    Method GridLinePosVld()
    Method setPCOLanc()
    Method CarregaLancto()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Method New() Class LXINPCO 


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
Method Activate(oModel, lCopy) Class LXINPCO

    self:oTipodoc := TipoDoc():New()
    self:aItemPCO := {}
    self:aLancPCO := {}

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
Method VldActivate(oModel, cModelId) Class LXINPCO
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
Method ModelPosVld(oModel, cModelId) Class LXINPCO
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
Method GridPosVld(oSubModel, cModelID) Class LXINPCO
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
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXINPCO
Local lRet      := .T.
Local lPCO      := SuperGetMV("MV_PCOINTE", .F., "2") == "1"
Local cTipoDoc  := ""
Local nPosIt    := 0
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")

    If cModelID == "SD1_DETAIL"
        If lPCO
            cTipoDoc := oModelSF1:GetValue("F1_TIPODOC")
            self:setPCOLanc(cTipoDoc)
            If Len(self:aItemPCO) > 0
                nPosIt := aScan(self:aItemPCO, {|x| x[1] == oSubModel:GetValue("D1_ITEM", nLine)})
            EndIf
            If nPosIt == 0 .Or. !(self:aItemPCO[nPosIt][2])
                lRet := PcoVldLan(self:aLancPCO[1], self:aLancPCO[2][1], self:aLancPCO[3], , ,.T.) //Valida bloqueo
                If lRet
                    aAdd(self:aItemPCO, {oSubModel:GetValue("D1_ITEM", nLine), lRet})
                EndIf
            EndIf
        EndIf
    EndIf
    
Return lRet

/*/{Protheus.doc} setPCOLanc
Metodo responsabe por llenar el arreglo aLancPCO con la información de PCO.
@type 		Method
@param 		cTipo	,caracter, numero del documento.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		06/2023
/*/
Method setPCOLanc(cTipo) Class LXINPCO

Default cTipo := ""

    If !Empty(cTipo) .and. Empty(self:aLancPCO)
		self:aLancPCO := {" ", {" "," "}, " ", {" "," "}}
		If FindFunction("PcoCarregaLancto")
    		self:aLancPCO := aClone(PcoCarregaLancto(Val(cTipo)))
		EndIf
    EndIf

Return
