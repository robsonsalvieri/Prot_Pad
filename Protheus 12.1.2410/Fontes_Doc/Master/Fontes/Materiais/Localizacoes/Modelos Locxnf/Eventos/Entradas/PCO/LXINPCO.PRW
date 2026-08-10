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
Method CarregaLancto(nTipo) Class LXINPCO
Local aPcoLanc := {NIL/*processo_pco*/, NIL /*Inclusao*/, NIL/*nome do programa*/, NIL/*Exclusao*/}

Default nTipo := 0

    Do Case
		Case nTipo == 4
			//mata465
			aPcoLanc[1] := "000309"
		    aPcoLanc[3] := "MATA465N"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"01", "03"}
		Case nTipo == 5
			//mata465
			aPcoLanc[1] := "000309"
		    aPcoLanc[3] := "MATA465N"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"01", "03"}
		Case nTipo == 8
			//mata466
			aPcoLanc[1] := "000311"
		    aPcoLanc[3] := "MATA466N"
			aPcoLanc[2] := {"01", "02"}
			aPcoLanc[4] := {"01", "02"}
		Case nTipo == 9 .Or. nTipo == 23
			//mata466
			aPcoLanc[1] := "000310"
		    aPcoLanc[3] := "MATA466N"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"01", "03"}
		Case nTipo == 10 .Or. nTipo == 20 //Adiantamento - Peru
			//mata101
			aPcoLanc[1] := "000306"
		    aPcoLanc[3] := "MATA101N"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"02", "04"}
		//Beneficiamento
		Case nTipo == 12
			//Mata101
			aPcoLanc[1] := "000306"
		    aPcoLanc[3] := "MATA101N"
			aPcoLanc[2] := {"05", "07"}
			aPcoLanc[4] := {"06", "08"}
		Case nTipo == 51
			//Mata462D Proprio
			aPcoLanc[1] := "000302"
		    aPcoLanc[3] := "MATA462DN"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"02", "04"}
		Case nTipo == 53
			//Mata462 Doc nao proprio
			aPcoLanc[1] := "000302"
		    aPcoLanc[3] := "MATA462DN"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"02", "04"}
		 //Remitos (Compras)
		Case nTipo == 60
			//Mata102
			aPcoLanc[1] := "000307"
		    aPcoLanc[3] := "MATA102N"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"02", "04"}
		Case nTipo == 62
			//Mata102
			aPcoLanc[1] := "000307"
		    aPcoLanc[3] := "MATA102N"
			aPcoLanc[2] := {"05", "07"}
			aPcoLanc[4] := {"06", "08"}
		Case nTipo == 63
			//Retorno SIMBOLICO
			aPcoLanc[1] := "000303"
		    aPcoLanc[3] := "MATA462R"
			aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"02", "04"}
		Case nTipo == 64
			aPcoLanc[1] := "000304"
		    aPcoLanc[3] := "MATA462TN"
	   		aPcoLanc[2] := {"01", "03"}
			aPcoLanc[4] := {"02", "04"}
	EndCase

Return aPcoLanc
