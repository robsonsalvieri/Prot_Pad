#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc} LXOUTPCO
Clase responsable por el evento de reglas de negocio de la integración de WMS.

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Class LXOUTPCO From FwModelEvent

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
Method New() Class LXOUTPCO 


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
Method Activate(oModel, lCopy) Class LXOUTPCO

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
Method VldActivate(oModel, cModelId) Class LXOUTPCO
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
Method ModelPosVld(oModel, cModelId) Class LXOUTPCO
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
Method GridPosVld(oSubModel, cModelID) Class LXOUTPCO
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
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXOUTPCO
Local lRet      := .T.
Local lPCO      := SuperGetMV("MV_PCOINTE", .F., "2") == "1"
Local cTipoDoc  := ""
Local nPosIt    := 0
Local oModel    := FwModelActivate()
Local oModelSF2 := oModel:GetModel("SF2_MASTER")

    If cModelID == "SD2_DETAIL"
        If lPCO
            cTipoDoc := oModelSF2:GetValue("F2_TIPODOC")
            self:setPCOLanc(cTipoDoc)
            If Len(self:aItemPCO) > 0
                nPosIt := aScan(self:aItemPCO, {|x| x[1] == oSubModel:GetValue("D2_ITEM", nLine)})
            EndIf
            If nPosIt == 0 .Or. !(self:aItemPCO[nPosIt][2])
                lRet := PcoVldLan(self:aLancPCO[1], self:aLancPCO[2][1], self:aLancPCO[3], , ,.T.) //Valida bloqueo
                If lRet
                    aAdd(self:aItemPCO, {oSubModel:GetValue("D2_ITEM", nLine), lRet})
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
Method setPCOLanc(cTipo) Class LXOUTPCO

Default cTipo := ""

    If !Empty(cTipo) .and. Empty(self:aLancPCO)
       self:aLancPCO := aClone(self:CarregaLancto(Val(cTipo)))
    EndIf

Return

/*/{Protheus.doc} CarregaLancto
Metodo responsabe por ejecutar reglas de negocio genericas para validación de línea.
@type 		Method
@param 		nTipo		,numerico	, numero del documento
@Return     aPcoLanc     ,array    ,Retorno con las informaciones para PCO de acuerdo al documento
//Retorna array com 04 posicoes
//onde 1a. pos. = processo_pco (lancto padrao do pco)
//QUANDO ROTINA FOR INCLUSAO
//     2a. pos. = array com na pos. 1 - item processo (detalhe-item)
//                                     pos. 2 - item processo  (cabeca-total)
//     3a. pos. = nome do programa que gerou o lancto no pco
//QUANDO ROTINA FOR EXCLUSAO
//     4a. pos. = array com na pos. 1 - item processo (EXCLUSAO detalhe-item)
//                                     pos. 2 - item processo  (EXCLUSAO cabeca-total)
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		06/2023
/*/
Method CarregaLancto(nTipo) Class LXOUTPCO
Local aPcoLanc := {NIL/*processo_pco*/, NIL /*Inclusao*/, NIL/*nome do programa*/, NIL/*Exclusao*/}

Default nTipo := 0

    Do Case
		//Nota de Venta - Especificos EQUADOR - - Adiantamento - Traslado - Mexico
		Case nTipo == 1 .Or. nTipo == 17 .Or. nTipo == 19 .Or. nTipo == 21
			//mata467
		    aPcoLanc[1] := "000300"
		    aPcoLanc[3] := "MATA467N"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"01", "03"}
		Case nTipo == 2
			//mata465
			aPcoLanc[1] := "000308"
		    aPcoLanc[3] := "MATA465N"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"01", "03"}
		Case nTipo == 3
			//mata465
			aPcoLanc[1] := "000308"
		    aPcoLanc[3] := "MATA465N"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"01", "03"}
		Case nTipo == 6
			//mata466
			aPcoLanc[1] := "000310"
		    aPcoLanc[3] := "MATA466N"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"01", "03"}
		Case nTipo == 7 .or. nTipo == 22
			//mata466
			aPcoLanc[1] := "000311"
		    aPcoLanc[3] := "MATA466N"
			aPcoLanc[2] := {"03", "04"}
			aPcoLanc[4] := {"03", "04"}
		//Beneficiamento
		Case nTipo == 11
			//Mata467
		    aPcoLanc[1] := "000300"
		    aPcoLanc[3] := "MATA467N"
			aPcoLanc[2] := {"05", "07"}
			aPcoLanc[4] := {"05", "07"}
	     //Remitos (facturacion)
		Case nTipo == 50
			//Mata462
		    aPcoLanc[1] := "000301"
		    aPcoLanc[3] := "MATA462N"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"02", "04"}
		Case nTipo == 52
			//Mata462
		    aPcoLanc[1] := "000301"
		    aPcoLanc[3] := "MATA462N"
			aPcoLanc[2] := {"05", "07"}
			aPcoLanc[4] := {"06", "08"}
		Case nTipo == 54 // Remito de transf. Saida
			//Mata462
			aPcoLanc[1] := "000304"
		    aPcoLanc[3] := "MATA462TN"
			aPcoLanc[2] := {"05", "07"}
			aPcoLanc[4] := {"06", "08"}
		Case nTipo == 61
			//Mata102
			aPcoLanc[1] := "000305"
		    aPcoLanc[3] := "MATA102DN"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"02", "04"}
	EndCase

Return aPcoLanc
