#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "LXINEVENT.CH"

#Define ScCliFor    2
#Define SlFormProp  3
#Define ScTipoDoc  10

/*/{Protheus.doc} LXINEVENT
Clase responsable por el evento de detonación de grabado y validaciones de la locxnf.

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		06/2023
/*/
Class LXINEVENT From FwModelEvent

    DATA oTipoDoc as object
    DATA aRecnoSE1 as array

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method InTTS()
    Method FillaDup()
    Method ModelPosVld()
    Method GridLinePosVld()
    Method FillaSEV()
    Method GetPergSX1()
    Method FillaOP()
    Method DeActivate()
    Method GridPosVld()
    Method FieldPosVld()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		08/2023
/*/
Method New() Class LXINEVENT 


Return Nil

/*/{Protheus.doc} Activate
Metodo activate

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		lCopy    ,caracter	,Informa si el model debe copiar los datos del registro posicionado.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		08/2023
/*/
Method Activate(oModel, lCopy) Class LXINEVENT

    self:oTipodoc := TipoDoc():New()
    self:aRecnoSE1 := {}

    If Type("cTipo") == "C"
        cTipo := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPO")
    EndIf

Return

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		08/2023
/*/
Method VldActivate(oModel, cModelId) Class LXINEVENT
Local lRet          := .T.
Local nOperation    := oModel:GetOperation()

    If nOperation == MODEL_OPERATION_UPDATE
        oModel:SetErrorMessage("SF1_MASTER", 'F1_DOC', "SF1_MASTER", 'F1_DOC', 'OPERATION', STR0003, '', '') //Operación no permitida
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
@version	12.1.2210 / Superior
@since		08/2023
/*/
Method InTTS(oModel, cModelId) Class LXINEVENT
Local nOpc		    := oModel:GetOperation()
Local oModelSEU
Local nX            := 0
Local nBaseDup      := 0
Local nMoeFin       := 0
Local nPosSEv       := 0
Local aCabNotaOri   := {{}, {}, {}}
Local aOldData      := {}
Local aCitensOri    := {}
Local aCpItensOri   := {}
Local cTipoDoc      := ""
Local aCposSDE      := {}
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
Private lIntegracao	:= IF(GetMV("MV_EASY")=="S",.T.,.F.)    //Integracao SIGAEIC
Private lEICFinanc	:= IF(GetMV("MV_EASYFIN")=="S",.T.,.F.) //Integracao SIGAEIC - Financeiro
Private lFacImport	:= .F.
Private aRecSE2     := {}
Private aCols       := {}
Private lUsaCor		:= .F.
Private lGerarCFD   := .F.
Private lAnulaSF3   := .F. //Determina si anula o excluye el registro de Libro Fiscal(MaFisAtuSF3)
Private	lDocSp      := .F.
Private lActFjRm    := .F.
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
Private cCxBenef
Private nCxValor
Private cCxCaixa
Private cCxAdian
Private cCxHistor
Private cCxRendic
Private lLocxAuto   := .F.

    //Asignación de valores a las variables privadas.
    cNFiscal := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
    cA100For := oModel:GetModel("SF1_MASTER"):GetValue("F1_FORNECE")
    cLoja := oModel:GetModel("SF1_MASTER"):GetValue("F1_LOJA")
    cSerie := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    cEspecie := oModel:GetModel("SF1_MASTER"):GetValue("F1_ESPECIE")
    cTipoDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPODOC")
    nNFTipo := Val(cTipoDoc)
    cTipo   := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPO")
    cCondicao := oModel:GetModel("SF1_MASTER"):GetValue("F1_COND")
    lLocxAuto := IIf(oModel:GetModel("SF1_MASTER"):HasField("AUTO"), oModel:GetModel("SF1_MASTER"):GetValue("AUTO"), .F.)
    If oModel:GetModel("SF1_MASTER"):HasField("F1_NATFIN") .and. !Empty(oModel:GetModel("SF1_MASTER"):GetValue("F1_NATFIN"))
        cNatureza   := oModel:GetModel("SF1_MASTER"):GetValue("F1_NATFIN")
    Else
        cNatureza := oModel:GetModel("SF1_MASTER"):GetValue("F1_NATUREZ")
    EndIf
    nMoedaNF := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
    nTaxa := oModel:GetModel("SF1_MASTER"):GetValue("F1_TXMOEDA")
    nBaseDup := IIf(oModel:GetModel("SF1_MASTER"):HasField("BASEDUP"),  oModel:GetModel("SF1_MASTER"):GetValue("BASEDUP"), 0)
    nMoeFin := IIf(oModel:GetModel("SF1_MASTER"):HasField("F1_MOEFIN") .and. !Empty(oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEFIN")),  oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEFIN"), oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA"))
    lDocSp := IIf(oModel:GetModel("SF1_MASTER"):HasField("DOCSOP"),  oModel:GetModel("SF1_MASTER"):GetValue("DOCSOP"), .F.)
    lAutoFact := IIf(oModel:GetModel("SF1_MASTER"):HasField("F1_AUTOFAC"), oModel:GetModel("SF1_MASTER"):GetValue("F1_AUTOFAC") == "1", .F.)
    self:oTipoDoc:SetTipoDoc(cTipoDoc)

    aCfgNf  := GetF1CfgNF()
    
    //Encabezado de la factura.
    For nX := 1 To Len(oModel:GetModel("SF1_MASTER"):aDataModel[1])
        aAdd(aCabNotaOri[1], oModel:GetModel("SF1_MASTER"):aDataModel[1][nX][1])
        aAdd(aCabNotaOri[2], oModel:GetModel("SF1_MASTER"):aDataModel[1][nX][2])
    Next

    //Items de la factura
    aOldData := oModel:GetModel("SD1_DETAIL"):GetOldData()
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
        aCposSDE := GetCposSDE(oModel:GetModel("SDE_DETAIL"))
        aRatCC := GetModSDE(oModel:GetModel("SDE_DETAIL"), aCposSDE)

        //Datos de la multinaturaleza.
        If self:oTipoDoc:ValidMultiNatureSE1() .or. self:oTipoDoc:ValidMultiNatureSE2() .and. nBaseDup > 0 .and. oModel:GetModel("SEV_DETAIL"):IsUpdated()
            aOldDtSEV := oModel:GetModel("SEV_DETAIL"):GetOldData()
            Aeval({"EV_NATUREZ", "EV_VALOR", "EV_PERC", "EV_RATEICC"}, { |x| nPosSEV := oModel:GetModel("SEV_DETAIL"):GetStruct():GetFieldPos(x), Iif(nPosSEV>0,Aadd(aHeadSEV, aOldDtSEV[1][nPosSEV]),) })
            aColsSEV := self:FillaSEV(oModel:GetModel("SEV_DETAIL"), aHeadSEV)
        EndIf

        If self:oTipoDoc:ValidCajaChica()
            oModelSEU := oModel:GetModel("SEU_DETAIL")
            cCxBenef := oModelSEU:GetValue("EU_BENEF")
            nCxValor := oModelSEU:GetValue("EU_VALOR")
            cCxCaixa := oModelSEU:GetValue("EU_CAIXA")
            cCxAdian := oModelSEU:GetValue("EU_NROADIA")
            cCxHistor := oModelSEU:GetValue("EU_HISTOR")

            cCxRendic := Iif(oModelSEU:HasField("EU_NRREND"), oModelSEU:GetValue("EU_NRREND"),"")
        EndIf

        If self:oTipoDoc:DevBenefOP()
            aOPBenef := self:FillaOP(oModel:GetModel("SD1_DETAIL"))
        EndIf

        If MaFisFound()
            n := oModel:GetModel("SD1_DETAIL"):Length()
        Endif

        GravaNfGeral(aCabNotaOri, aCitensOri, aCpItensOri, nNFTipo, aPerg, aRatCC, .T., aFin, {}, aDupl, , ,.T.)
    ElseIf nOpc == MODEL_OPERATION_DELETE .or. nOpc == 6
        lDeleta := .T.
        If nOpc == 6
            lAnulaSF3 := .T.
        EndIf
        aCols   := aClone(aCitensOri)
        MaColsToFis(aHeader, aCols  ,       , "MT100"   , .F., .T., .F., , .F.)
        lRet := LocxDelNF("SF1",SF1->(Recno()),aPerg[3],aPerg[4],aPerg[2],.T.,.T.,.F.,.F.,cFunname)
        If !lRet .and. ValType(oView) == "O"
            oView:setDeleteMessage(STR0001, STR0002) //"Fallo en el borrado", "El registro no fue borrado."
        EndIf
    EndIf

    If MaFisFound()
        MaFisEnd()
    EndIf

Return

/*/{Protheus.doc} FillaDup
Metodo responsable del grabado por medio de la rutina locxnf.

@type 		Method
@param 		oSubModel   ,objeto	,Modelo de dados.
@Return     aDupl       ,array  ,Retorno la información de los títulos para el grabado.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		09/2023
/*/
Method FillaDup(oSubModel) Class LXINEVENT
Local nX        := 0
Local aDupl     := {}

    If oSubModel:IsUpdated()
        For nX := 1 To oSubModel:Length()
            aAdd(aDupl, oSubModel:GetValue("DUP", nX))
        Next
    EndIf

Return aDupl

/*/{Protheus.doc} GridLinePosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validación de línea.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		nLine		,numerico	,Número de línea validada
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		10/2023
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXINEVENT
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
        If cModelID == "SD1_DETAIL"
            cEspecie := oModel:GetModel("SF1_MASTER"):GetValue("F1_ESPECIE")
            cCondicao := oModel:GetModel("SF1_MASTER"):GetValue("F1_COND")
            nMoedaNF := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
            aOldData := oSubModel:GetOldData()
            AEval( aOldData[1], { |x| AAdd( aCposIOri, x[2] ) } )
            aCitensOri  := aOldData[2]

            aCfgNf  := GetF1CfgNF()
            aRecnoSE1 := aClone(self:aRecnoSE1)

            lRet := NfLinOk("SD1",aCposIOri,aCfgNf[ScCliFor],aCitensOri,aCfgNf[ScTipoDoc],nLine,aCfgNf[SlFormProp])

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
@version	12.2.2210 / Superior
@since		04/2024
/*/
Method GridPosVld(oSubModel, cModelID) Class LXINEVENT
Local lRet      := .T. 

    If cModelID == "SD1_DETAIL"
        CalcImpIN() //Ejecuta el calculo de valores del documento, si hay fue realizado el calculo no hace nada.
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
Method ModelPosVld(oModel, cModelId) Class LXINEVENT
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
        AEval( oModel:GetModel("SF1_MASTER"):aDataModel[1], { |x,y| AAdd( aCposTela[1], x[1] ), AAdd( aCposTela[2], x[2] ), AAdd( aGetsTela, {x[1],x[2]} ) } )
        cNFiscal := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
        cSerie := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
        cEspecie := oModel:GetModel("SF1_MASTER"):GetValue("F1_ESPECIE")
        cTipoDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPODOC")
        nNFTipo := Val(cTipoDoc)
        cCondicao := oModel:GetModel("SF1_MASTER"):GetValue("F1_COND")
        If oModel:GetModel("SF1_MASTER"):HasField("F1_NATFIN") .and. !Empty(oModel:GetModel("SF1_MASTER"):GetValue("F1_NATFIN"))
            cNatureza   := oModel:GetModel("SF1_MASTER"):GetValue("F1_NATFIN")
        Else
            cNatureza := oModel:GetModel("SF1_MASTER"):GetValue("F1_NATUREZ")
        EndIf
        nMoedaNF := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
        nMoedaCor := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
        nTaxa := oModel:GetModel("SF1_MASTER"):GetValue("F1_TXMOEDA")
        lDocSp := IIf(oModel:GetModel("SF1_MASTER"):HasField("DOCSOP"),  oModel:GetModel("SF1_MASTER"):GetValue("DOCSOP"), .F.)
        
        aCfgNf  := GetF1CfgNF()
        
        aAux 			:= CposAutoNf("SF1",aCfgNf[ScCliFor],aCfgNf[SlFormProp],aCposTela[1],{aCposTela[2]},aCfgNf[ScTipoDoc])
        aCposTela[1] 	:= aClone(aAux[1])
        aCposTela[2] 	:= aClone(aAux[2][1])

        aOldData := oModel:GetModel("SD1_DETAIL"):GetOldData()
        AEval( aOldData[1], { |x| AAdd( aCposIOri, x[2] ) } )
        aHeader := aOldData[1]
        aCitensOri  := aOldData[2]
        aCols := aClone(aCitensOri)

        aDupl := self:FillaDup(oModel:GetModel("DUP_DETAIL"))
        aRecnoSE1 := aClone(self:aRecnoSE1)

        MaFisRestore()
        If Empty(MaFisRet(,"NF_NATUREZA"))
            MaFisAlt("NF_NATUREZA", cNatureza)
        EndIf
        If MaFisFound()
            n := oModel:GetModel("SD1_DETAIL"):Length()
        Endif
        lRet := NfTudOk("SF1","SD1",aCfgNf[ScCliFor],aCposTela,aCposIOri,aCitensOri,Len(aCitensOri),aCfgNf[ScTipoDoc],aCfgNf[SlFormProp],aGetsTela,.F.)

        If MaFisFound()
            MaFisSave()
            MaFisEnd()
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} FillaSEV
Metodo responsable del grabado por medio de la rutina locxnf.

@type 		Method
@param 		oSubModel   ,objeto	,Modelo de dados.
@param      aHeader , array, encabezado de la tabla SEV.
@Return     aSEV       ,array  ,Retorno de la información del prorrateo de la multi naturaleza para el grabado.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		10/2023
/*/
Method FillaSEV(oSubModel, aHeader) Class LXINEVENT
Local aSEV      := {}
Local nX        := 0
Local nLen      := 0
Local nLenHead  := 0

Default aHeader := {}

    nLenHead := Len(aHeader)

    For nX := 1 To oSubModel:Length()
        If !oSubModel:IsDeleted(nX)
            aAdd(aSEV, Array(nLenHead + 1))
            nLen += 1
            Aeval(aHeadSEV, {|x,y| aSEV[nLen][y] := oSubModel:GetValue(x[2], nX)})
            aSEV[nLen][nLenHead + 1] := .F.
        EndIf
    Next

Return aSEV

/*/{Protheus.doc} GetPergSX1
Metodo responsable obtener los valores de la configuración de contabilidad.

@type 		Method
@Return     aPergs       ,array  ,Información del grupo de preguntas de contabilidad.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		10/2023
/*/
Method GetPergSX1() Class LXINEVENT 
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

Return aPergs

/*/{Protheus.doc} FillaOP
Metodo responsable del grabado por medio de la rutina locxnf.

@type 		Method
@param 		oSubModel   ,objeto	,Modelo de dados de SD1.
@Return     aRet       ,array  ,Retorno de la información del prorrateo de la multi naturaleza para el grabado.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		12/2023
/*/
Method FillaOP(oSubModel) Class LXINEVENT
Local aRet      := {}
Local nX        := 0

    For nX := 1 To oSubModel:Length()
        If !oSubModel:IsDeleted(nX) .and. !Empty(oSubModel:GetValue("D1_OP", nX))
            aAdd(aRet, {oSubModel:GetValue("D1_OP", nX), oSubModel:GetValue("D1_QUANT", nX), oSubModel:GetValue("D1_COD", nX), oSubModel:GetValue("D1_ITEM", nX)})
        EndIf
    Next

Return aRet

/*/{Protheus.doc} DeActivate
Metodo responsable por realizar los desbloqueos al salir del model sin hacer un commit

@type 		Method
@param 		oModel   ,objeto	,objeto del model que está siendo procesado.
@Return     Nil     
@author 	raul.medina
@version	12.1.2210 / Superior
@since		03/2024
/*/
METHOD DeActivate(oModel) CLASS LXINEVENT

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
        MsUnLockAll()
	EndIf

Return Nil

/*/{Protheus.doc} FieldPosVld
Metodo responsabe por ejecutar reglas de negocio del campo.

@type 		Method

@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.2210 / Superior
@since		01/2025
/*/
Method FieldPosVld(oSubModel, cModelID) Class LXINEVENT
Local lRet      := .T.
Local cSerie    := ""
Local cTipoDoc  := ""
Local oModel    := FwModelActivate()

IF cModelID == 'SF1_MASTER'

    cSerie      := oSubModel:GetValue("F1_SERIE")
    cTipoDoc    := oSubModel:GetValue("F1_TIPODOC")
    self:oTipoDoc:SetTipoDoc(cTipoDoc)

	//Valida serie requerida para documentos de formulario propio.
    If lRet .and. Empty(cSerie) .and. self:oTipoDoc:ValidSerie()
        oModel:SetErrorMessage("SF1_MASTER", 'F1_SERIE', 'SF1_MASTER', 'F1_SERIE', 'SERIE', STR0004, '', '') //¡La serie es requerida para este documento!
        lRet := .F.
    EndIf
EndIf

Return lRet
