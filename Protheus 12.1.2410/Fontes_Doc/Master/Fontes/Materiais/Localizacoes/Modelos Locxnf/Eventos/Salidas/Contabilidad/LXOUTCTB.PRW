#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} LXOUTCTB
Clase responsable por el evento de reglas de negocio de 
localización padrón

@type 		Class
@author 	laura.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Class LXOUTCTB From FwModelEvent

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
@author 	laura.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Method New() Class LXOUTCTB 

Return Nil


/*/{Protheus.doc} New
Metodo activate

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		lCopy    ,caracter	,Informa si el model debe copiar los datos del registro posicionado.
@author 	laura.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Method Activate(oModel, lCopy) Class LXOUTCTB

    self:oTipodoc := TipoDoc():New()

Return

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	laura.medina
@version	12.1.2210 / Superior
@since		05/2021 
/*/
Method VldActivate(oModel, cModelId) Class LXOUTCTB
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
@author 	laura.medina
@version	12.1.2210 / Superior
@since		05/2023
/*/
Method ModelPosVld(oModel, cModelId) Class LXOUTCTB
Local lRet      := .T.  
Local dDataRef   
Local dDataBloq	:= GetNewPar("MV_ATFBLQM",CTOD("")) //Data de Bloqueio da Movimentação - MV_ATFBLQM
Local oModelSF2 := oModel:GetModel("SF2_MASTER")
Local aArea     := {}

aArea := GetArea()
 
    //Verifica se existe bloqueio contábil
    dDataRef    := oModelSF2:GetValue("F2_EMISSAO") //M->F2_EMISSAO
    
    If  !(Empty(dDataRef)) .And. (lRet := CtbValiDt(Nil,dDataRef,/*.T.*/ ,Nil ,Nil ,{"COM001"}/*,"Data de apuração bloqueada pelo calendário contábil."*/))
        If!Empty(dDataBloq) .AND. (dDataRef <= dDataBloq)
            Help(" ",1,"ATFCTBBLQ") //P: Processo bloqueado pelo Calendário Contábil ou parâmetro de bloqueio nesta data ou período. S: Caso possível altere a data de referência do processo, verifique o parâmetro ou contate o responsável pelo Módulo Contábil.)
            lRet := .F.
        End
    EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} GridPosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validación de grid.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	laura.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method GridPosVld(oSubModel, cModelID) Class LXOUTCTB
Local lRet      := .T.

Return lRet

/*/{Protheus.doc} GridLinePosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validación de línea.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,Número de línea validada
@Return     lRet        ,logico    ,Retorno de las validaciones.
@author 	laura.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXOUTCTB
Local lRet      := .T.
Local aArea     := {}

aArea := GetArea()

    If cModelID == "SD2_DETAIL"
    	If  !CtbAmarra(oSubModel:GetValue("D2_CONTA", nLine),oSubModel:GetValue("D2_CCUSTO", nLine),oSubModel:GetValue("D2_ITEMCC", nLine),oSubModel:GetValue("D2_CLVL", nLine))         
			lRet := .F.
		EndIf    

    EndIf

RestArea(aArea)

Return lRet
