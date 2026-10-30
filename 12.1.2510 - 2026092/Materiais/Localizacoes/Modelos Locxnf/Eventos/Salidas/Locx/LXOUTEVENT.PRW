#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "LXOUTEVENT.CH"


#Define ScCliFor    2
#Define SlFormProp  3
#Define ScTipoDoc  10

/*/{Protheus.doc} LXOUTEVENT
Clase responsable por el evento de detonación de grabado y validaciones de la locxnf.

@type 		Class
@author 	raul.medina
@version	12.1.2510 / Superior
@since		08/2026
/*/
Class LXOUTEVENT From FwModelEvent

    DATA oTipoDoc as object
    DATA aRecnoSE1 as array

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method InTTS()
    Method ModelPosVld()
    Method GridLinePosVld()
    Method DeActivate()
    Method GridPosVld()
    Method FieldPosVld()
    Method FillaDup()
    Method GetPergSX1()

EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2510 / Superior
@since		08/2026
/*/
Method New() Class LXOUTEVENT 


Return Nil

/*/{Protheus.doc} Activate
Metodo activate

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		lCopy    ,caracter	,Informa si el model debe copiar los datos del registro posicionado.
@author 	raul.medina
@version	12.1.2510 / Superior
@since		08/2026
/*/
Method Activate(oModel, lCopy) Class LXOUTEVENT

    self:oTipodoc := TipoDoc():New()
    self:aRecnoSE1 := {}

    If Type("cTipo") == "C"
        cTipo := oModel:GetModel("SF2_MASTER"):GetValue("F2_TIPO")
    EndIf

Return

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina
@version	12.1.2510 / Superior
@since		08/2026
/*/
Method VldActivate(oModel, cModelId) Class LXOUTEVENT
Local lRet          := .T.
Local nOperation    := oModel:GetOperation()

    If nOperation == MODEL_OPERATION_UPDATE
        oModel:SetErrorMessage("SF2_MASTER", 'F2_DOC', "SF2_MASTER", 'F2_DOC', 'OPERATION', STR0001, '', '') //Operación no permitida
        lRet := .F.
    EndIf

Return lRet

/*/{Protheus.doc} InTTS
Metodo responsable del grabado por medio de la rutina locxnf.

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina
@version	12.1.2510 / Superior
@since		08/2026
/*/
Method InTTS(oModel, cModelId) Class LXOUTEVENT
Local nOpc		    := oModel:GetOperation()
Local nX            := 0
Local nBaseDup      := 0
Local nMoeFin       := 0
Local nPosSEv       := 0
Local aCabNotaOri   := {{}, {}, {}}
Local aOldData      := {}
Local aCitensOri    := {}
Local aCpItensOri   := {}
Local cTipoDoc      := ""
Local aRatCC        := {}
Local aFin          := {}
Local aOldDtSEV     := {}
Local aPerg         := {}
Local lRet          := .T.
Local oView         := FwViewActive()
Private l103Class   := .F.
Private dDEmissao   :=  ddatabase
Private aHeader     := {}
Private nNFTipo     := 0
Private nMoedaNF    := 1
Private nTaxa       := 1
Private lDeleta     := .F.
Private cEspecie    := ""
Private cTipo       := ""
Private aRecSE2     := {}
Private aCols       := {}
Private lUsaCor		:= .F.
Private lGerarCFD   := .F.
Private lAnulaSF3   := .F. //Determina si anula o excluye el registro de Libro Fiscal(MaFisAtuSF3)
Private	lDocSp      := .F.
Private lAutoFact   := .F.
Private lInclui     := .F. 
Private aCfgNf      := {}
Private aDupl		:= {}
Private aHeadSEV    := {}
Private aColsSEV    := {}
Private aOPBenef    := {}
Private aRecnoSE1   := {}
Private aAmarrAFN   := {}
Private aRatAFN     := {}
Private cFunname    := Funname()
Private cCondicao   := ""
Private cNatureza   := ""
Private cNFiscal    := ""
Private cA100For    := ""
Private cLoja       := ""
Private cSerie      := ""
Private lLocxAuto   := .F.
Private aPE         := Nil

    //Asignación de valores a las variables privadas.
    cNFiscal := oModel:GetModel("SF2_MASTER"):GetValue("F2_DOC")
    cA100For := oModel:GetModel("SF2_MASTER"):GetValue("F2_CLIENTE")
    cLoja := oModel:GetModel("SF2_MASTER"):GetValue("F2_LOJA")
    cSerie := oModel:GetModel("SF2_MASTER"):GetValue("F2_SERIE")
    cEspecie := oModel:GetModel("SF2_MASTER"):GetValue("F2_ESPECIE")
    cTipoDoc := oModel:GetModel("SF2_MASTER"):GetValue("F2_TIPODOC")
    nNFTipo := Val(cTipoDoc)
    cTipo   := oModel:GetModel("SF2_MASTER"):GetValue("F2_TIPO")
    cCondicao := oModel:GetModel("SF2_MASTER"):GetValue("F2_COND")
    lLocxAuto := IIf(oModel:GetModel("SF2_MASTER"):HasField("AUTO"), oModel:GetModel("SF2_MASTER"):GetValue("AUTO"), .F.)
    If oModel:GetModel("SF2_MASTER"):HasField("F2_NATFIN") .and. !Empty(oModel:GetModel("SF2_MASTER"):GetValue("F2_NATFIN"))
        cNatureza   := oModel:GetModel("SF2_MASTER"):GetValue("F2_NATFIN")
    Else
        cNatureza := oModel:GetModel("SF2_MASTER"):GetValue("F2_NATUREZ")
    EndIf
    nMoedaNF := oModel:GetModel("SF2_MASTER"):GetValue("F2_MOEDA")
    nTaxa := oModel:GetModel("SF2_MASTER"):GetValue("F2_TXMOEDA")
    nBaseDup := IIf(oModel:GetModel("SF2_MASTER"):HasField("BASEDUP"),  oModel:GetModel("SF2_MASTER"):GetValue("BASEDUP"), 0)
    nMoeFin := IIf(oModel:GetModel("SF2_MASTER"):HasField("F2_MOEFIN") .and. !Empty(oModel:GetModel("SF2_MASTER"):GetValue("F2_MOEFIN")),  oModel:GetModel("SF2_MASTER"):GetValue("F2_MOEFIN"), oModel:GetModel("SF2_MASTER"):GetValue("F2_MOEDA"))
    self:oTipoDoc:SetTipoDoc(cTipoDoc)

    aCfgNf  := GetF2CfgNF()
    If (Type("aCfgNf[17]") == "A") 
        aPE := aClone(aCfgNF[17])
    EndIf    
    
    //Encabezado de la factura.
    For nX := 1 To Len(oModel:GetModel("SF2_MASTER"):aDataModel[1])
        aAdd(aCabNotaOri[1], oModel:GetModel("SF2_MASTER"):aDataModel[1][nX][1])
        aAdd(aCabNotaOri[2], oModel:GetModel("SF2_MASTER"):aDataModel[1][nX][2])
    Next

    //Items de la factura
    aOldData := oModel:GetModel("SD2_DETAIL"):GetOldData()
    aHeader := aOldData[1]
    aCitensOri  := aOldData[2]

    For nX := 1 To Len(aOldData[1])
        aAdd(aCpItensOri,aOldData[1][nX][2])
    Next

    aPerg := self:GetPergSX1()
    aCfgNf[16] := aClone(aPerg)
    aRecnoSE1 := aClone(self:aRecnoSE1)
    
    MaFisIni(cA100For, cLoja, "", cTipo, Nil, , , .F., "SB1", , cTipoDoc, cEspecie)
    If nOpc == MODEL_OPERATION_INSERT
        lInclui := .T.
        MaFisRestore()

        //Datos financieros.
        aDupl := self:FillaDup(oModel:GetModel("DUP_DETAIL"))
        aFin := {nMoeFin, cNatureza}

        //Prorrateo.

        //Datos de la multinaturaleza.
        If self:oTipoDoc:ValidMultiNatureSE1() .or. self:oTipoDoc:ValidMultiNatureSE2() .and. nBaseDup > 0 .and. oModel:GetModel("SEV_DETAIL"):IsUpdated()
            aOldDtSEV := oModel:GetModel("SEV_DETAIL"):GetOldData()
            Aeval({"EV_NATUREZ", "EV_VALOR", "EV_PERC", "EV_RATEICC"}, { |x| nPosSEV := oModel:GetModel("SEV_DETAIL"):GetStruct():GetFieldPos(x), Iif(nPosSEV>0,Aadd(aHeadSEV, aOldDtSEV[1][nPosSEV]),) })
            aColsSEV := self:FillaSEV(oModel:GetModel("SEV_DETAIL"), aHeadSEV)
        EndIf

        If MaFisFound()
            n := oModel:GetModel("SD2_DETAIL"):Length()
        Endif
        aCols   := aClone(aCitensOri)

        GravaNfGeral(aCabNotaOri, aCitensOri, aCpItensOri, nNFTipo, aPerg, aRatCC, .T., aFin, {}, aDupl, , ,.T.)

        FwFreeArray(aRatCC)
        FwFreeArray(aFin)
        FwFreeArray(aDupl)
        FwFreeArray(aOldDtSEV)
        FwFreeArray(aHeadSEV)
        FwFreeArray(aColsSEV)
    ElseIf nOpc == MODEL_OPERATION_DELETE .or. nOpc == 6
        lDeleta := .T.
        If nOpc == 6
            lAnulaSF3 := .T.
        EndIf
        aCols   := aClone(aCitensOri)
        MaColsToFis(aHeader, aCols  ,       , "MT100"   , .F., .T., .F., , .F.)
        lRet := LocxDelNF("SF2",SF2->(Recno()),aPerg[3],aPerg[4],aPerg[2],.T.,.T.,.F.,.F.,cFunname)
        If !lRet .and. ValType(oView) == "O"
            oView:setDeleteMessage(STR0002, STR0003) //"Fallo en el borrado", "El registro no fue borrado."
        EndIf
    EndIf

    If MaFisFound()
        MaFisEnd()
    EndIf
    FwFreeArray(aPE)
    FwFreeArray(aCols )
    FwFreeArray(aCitensOri)
    FwFreeArray(aHeader)
    FwFreeArray(aPerg)
    FwFreeArray(aRecnoSE1)
    FwFreeArray(aCfgNf)
    FwFreeArray(aCabNotaOri)
    FwFreeArray(aOldData)
    FwFreeArray(aCpItensOri)
    FwFreeArray(aRecSE2)
    FwFreeArray(aOPBenef)
    FwFreeArray(aAmarrAFN)
    FwFreeArray(aRatAFN)

Return

/*/{Protheus.doc} GridLinePosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validación de línea.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,Número de línea validada
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2510 / Superior
@since		08/2026
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXOUTEVENT
Local lRet      := .T.
Local aOldData  := {}
Local aCposIOri := {}
Local aCitensOri:= {}
Local oModel    := FwModelActivate()
Local nOpc		:= oModel:GetOperation()

Private nMoedaNF    := 1
Private l103Class   := .F.
Private aCfgNf      := {}
Private aRecnoSE1   := {}
Private cEspecie    := ""
Private cCondicao   := ""
    
    If nOpc == MODEL_OPERATION_INSERT
        If cModelID == "SD2_DETAIL"
            cEspecie := oModel:GetModel("SF2_MASTER"):GetValue("F2_ESPECIE")
            cCondicao := oModel:GetModel("SF2_MASTER"):GetValue("F2_COND")
            nMoedaNF := oModel:GetModel("SF2_MASTER"):GetValue("F2_MOEDA")
            aOldData := aClone(oSubModel:GetOldData())
            AEval( aOldData[1], { |x| AAdd( aCposIOri, x[2] ) } )
            aCitensOri  := aClone(aOldData[2])

            aCfgNf  := GetF2CfgNF()
            aRecnoSE1 := aClone(self:aRecnoSE1)

            lRet := NfLinOk("SD2",aCposIOri,aCfgNf[ScCliFor],aCitensOri,aCfgNf[ScTipoDoc],nLine,aCfgNf[SlFormProp])

            FwFreeArray(aOldData)
            FwFreeArray(aCposIOri)
            FwFreeArray(aCitensOri)
            FwFreeArray(aCfgNf)
            FwFreeArray(aRecnoSE1)
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} GridPosVld
Metodo responsabe por ejecutar reglas de negocio genericas del grid.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2510 / Superior
@since		08/2026
/*/
Method GridPosVld(oSubModel, cModelID) Class LXOUTEVENT
Local lRet      := .T. 

    If cModelID == "SD2_DETAIL"
        CalcImpOUT() //Ejecuta el calculo de valores del documento, si hay fue realizado el calculo no hace nada.
    EndIf

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
@since		10/2023
/*/
Method ModelPosVld(oModel, cModelId) Class LXOUTEVENT
Local lRet      := .T. 
Local aOldData  := {}
Local aCposIOri := {}
Local aCitensOri:= {}
Local aCposTela := {{}, {}, {}}
Local aGetsTela := {}
Local cTipoDoc  := ""
Local aAux      := {}
Local nOpc		:= oModel:GetOperation()

Private aCfgNf      := {}
Private aDupl       := {}
Private aHeader     := {}
Private ARECNOSE1   := {}
Private aCols       := {}
Private nNFTipo     := 0
Private nMoedaNF    := 1
Private nMoedaCor   := 1
Private nTaxa       := 1
Private cNFiscal    := ""
Private cSerie      := ""
Private cEspecie    := ""
Private cNatureza   := ""
Private cCondicao   := ""
Private lLocxAuto   := .F.
Private l103Class   := .F.
Private lUsaCor     := .F.
Private lGerarCFD   := .F.
Private	lDocSp      := .F.
Private bRefresh    := {||}
    
    If nOpc == MODEL_OPERATION_INSERT
        AEval( oModel:GetModel("SF2_MASTER"):aDataModel[1], { |x,y| AAdd( aCposTela[1], x[1] ), AAdd( aCposTela[2], x[2] ), AAdd( aGetsTela, {x[1],x[2]} ) } )
        cNFiscal := oModel:GetModel("SF2_MASTER"):GetValue("F2_DOC")
        cSerie := oModel:GetModel("SF2_MASTER"):GetValue("F2_SERIE")
        cEspecie := oModel:GetModel("SF2_MASTER"):GetValue("F2_ESPECIE")
        cTipoDoc := oModel:GetModel("SF2_MASTER"):GetValue("F2_TIPODOC")
        nNFTipo := Val(cTipoDoc)
        cCondicao := oModel:GetModel("SF2_MASTER"):GetValue("F2_COND")
        If oModel:GetModel("SF2_MASTER"):HasField("F2_NATFIN") .and. !Empty(oModel:GetModel("SF2_MASTER"):GetValue("F2_NATFIN"))
            cNatureza   := oModel:GetModel("SF2_MASTER"):GetValue("F2_NATFIN")
        Else
            cNatureza := oModel:GetModel("SF2_MASTER"):GetValue("F2_NATUREZ")
        EndIf
        nMoedaNF := oModel:GetModel("SF2_MASTER"):GetValue("F2_MOEDA")
        nMoedaCor := oModel:GetModel("SF2_MASTER"):GetValue("F2_MOEDA")
        nTaxa := oModel:GetModel("SF2_MASTER"):GetValue("F2_TXMOEDA")
        
        aCfgNf  := GetF2CfgNF()
        
        aAux 			:= CposAutoNf("SF2",aCfgNf[ScCliFor],aCfgNf[SlFormProp],aCposTela[1],{aCposTela[2]},aCfgNf[ScTipoDoc])
        aCposTela[1] 	:= aClone(aAux[1])
        aCposTela[2] 	:= aClone(aAux[2][1])

        aOldData := aClone(oModel:GetModel("SD2_DETAIL"):GetOldData())
        AEval( aOldData[1], { |x| AAdd( aCposIOri, x[2] ) } )
        aHeader := aClone(aOldData[1])
        aCitensOri  := aClone(aOldData[2])
        aCols := aClone(aCitensOri)

        aDupl := self:FillaDup(oModel:GetModel("DUP_DETAIL"))
        aRecnoSE1 := aClone(self:aRecnoSE1)

        MaFisRestore()
        If Empty(MaFisRet(,"NF_NATUREZA"))
            MaFisAlt("NF_NATUREZA", cNatureza)
        EndIf
        If MaFisFound()
            n := oModel:GetModel("SD2_DETAIL"):Length()
        Endif
        lRet := NfTudOk("SF2","SD2",aCfgNf[ScCliFor],aCposTela,aCposIOri,aCitensOri,Len(aCitensOri),aCfgNf[ScTipoDoc],aCfgNf[SlFormProp],aGetsTela,.F.)

        If MaFisFound()
            MaFisSave()
            MaFisEnd()
        EndIf

        FwFreeArray(aOldData)
        FwFreeArray(aCposIOri)
        FwFreeArray(aCitensOri)
        FwFreeArray(aCposTela)
        FwFreeArray(aGetsTela)
        FwFreeArray(cTipoDoc)
        FwFreeArray(aAux)
        FwFreeArray(aCfgNf)
        FwFreeArray(aDupl)
        FwFreeArray(aHeader)
        FwFreeArray(ARECNOSE1)
        FwFreeArray(aCols)

    EndIf

Return lRet

/*/{Protheus.doc} FieldPosVld
Metodo responsabe por ejecutar reglas de negocio del campo.

@type 		Method

@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.2510 / Superior
@since		08/2026
/*/
Method FieldPosVld(oSubModel, cModelID) Class LXOUTEVENT
Local lRet      := .T.

Return lRet

/*/{Protheus.doc} FillaDup
Metodo responsable del grabado por medio de la rutina locxnf.

@type 		Method
@param 		oSubModel   ,objeto	,Modelo de dados.
@Return     aDupl       ,array  ,Retorno la información de los títulos para el grabado.
@author 	raul.medina
@version	12.1.2610 / Superior
@since		08/2026
/*/
Method FillaDup(oSubModel) Class LXOUTEVENT
Local nX        := 0
Local aDupl     := {}

    If oSubModel:IsUpdated()
        For nX := 1 To oSubModel:Length()
            aAdd(aDupl, oSubModel:GetValue("DUP", nX))
        Next
    EndIf

Return aClone(aDupl)


/*/{Protheus.doc} GetPergSX1
Metodo responsable obtener los valores de la configuración de contabilidad.

@type 		Method
@Return     aPergs       ,array  ,Información del grupo de preguntas de contabilidad.
@author 	raul.medina
@version	12.1.2510 / Superior
@since		08/2026
/*/
Method GetPergSX1() Class LXOUTEVENT 
Local oObj      := FWSX1Util():New()
Local aPergunte := {}
Local aPergs    := {}
Local nX        := 0

    Pergunte("MTXRED",.F.)
    oObj:AddGroup("MTXRED")
    oObj:SearchGroup()
    aPergunte := oObj:GetGroup("MTXRED")
    For nX := 1 To Len(aPergunte[2])
        AAdd(aPergs, &(aPergunte[2][nX]:CX1_VAR01) == 1)
    Next
    AAdd(aPergs,.F.)

Return aClone(aPergs)

/*/{Protheus.doc} DeActivate
Metodo responsable por realizar los desbloqueos al salir del model sin hacer un commit

@type 		Method
@param 		oModel   ,objeto	,objeto del model que está siendo procesado.
@Return     Nil     
@author 	raul.medina
@version	12.1.2510 / Superior
@since		08/2026
/*/
METHOD DeActivate(oModel) CLASS LXOUTEVENT

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
        MsUnLockAll()
	EndIf

Return Nil
