#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "LXINFIS.CH"

/*/{Protheus.doc} LXINFIS
Clase responsable por el evento de reglas de negocio de 
localización padrón

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Class LXINFIS From FwModelEvent

    //Propiedades que pueden ser alteradas desde los eventos con localización
    DATA oTipoDoc as object

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method ModelPosVld()
    Method GridPosVld()
    Method GridLinePreVld()
    Method GridLinePosVld()
    Method UpdNumberDetail()
    Method FieldPreVld()
    Method UpdItems()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Method New() Class LXINFIS 

Return Nil

/*/{Protheus.doc} Activate
Metodo activate

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		lCopy    ,caracter	,Informa si el model debe copiar los datos del registro posicionado.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Method Activate(oModel, lCopy) Class LXINFIS

    self:oTipodoc := TipoDoc():New()

    If oModel:GetOperation() == 6
        oModel:lModify := .T.
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
@since		04/2023
/*/
Method VldActivate(oModel, cModelId) Class LXINFIS
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
@since		04/2023
/*/
Method ModelPosVld(oModel, cModelId) Class LXINFIS
Local lRet      := .T. 
Local lExist    := .F.
Local oModelSF1 := oModel:GetModel("SF1_MASTER")
Local cSerie    := ""
Local cNFiscal  := ""
Local cCliFor   := ""
Local cLoja     := ""
Local cEspecie  := ""
Local cTipoDoc  := ""
Local cNumAnt   := ""
Local nUpdNum   := SuperGetMV("MV_ALTNUM",,1)
Local aArea     := {}
Local nOpc		:= oModel:GetOperation()

Private cTipo   := ""

    cSerie      := oModelSF1:GetValue("F1_SERIE")
    cNFiscal    := oModelSF1:GetValue("F1_DOC")
    cCliFor     := oModelSF1:GetValue("F1_FORNECE")
    cLoja       := oModelSF1:GetValue("F1_LOJA")
    cEspecie    := oModelSF1:GetValue("F1_ESPECIE")
    cTipoDoc    := oModelSF1:GetValue("F1_TIPODOC")
    cTipo       := oModelSF1:GetValue("F1_TIPO")
    self:oTipoDoc:SetTipoDoc(cTipoDoc)

    If nOpc == MODEL_OPERATION_INSERT

        If !(Type("aCfgNf") == "A")
            aCfgNf  := GetF1CfgNF()
        EndIf

        If self:oTipoDoc:ValidNumTRF() //Documentos de transferencia.
            lRet := !aNumTRFNaoExiste("SF1", cSerie, cNFiscal, cCliFor, cLoja, cEspecie, {{"F1_TIPODOC", "F1_EMISSAO"}, {cTipoDoc, oModelSF1:GetValue("F1_EMISSAO")}, {}})
        EndIf

        //Verificación de existencia del numero de documento usado.
        If lRet
            lExist := !aNumNaoExiste("SF1", cSerie, cNFiscal, cCliFor, cLoja, cEspecie)
            If lExist
                If self:oTipoDoc:UpdateNumberDoc() //Documentos de formulario propio.
                    While lExist
                        cNFiscal    := Soma1(cNFiscal)
                        lExist      := !aNumNaoExiste("SF1", cSerie, cNFiscal, cCliFor, cLoja, cEspecie)
                    EndDo
                    If nUpdNum == 1 //Realiza la actualización de la numeración.
                        cNumAnt := oModelSF1:GetValue("F1_DOC")
                        self:UpdNumberDetail(cNFiscal)
                        MsgInfo(STR0007 + cNumAnt + STR0008 + cNFiscal, STR0014) //El número del documento fue modificado de: #  a:  # Número
                    ElseIf nUpdNum == 2 //Pregunta si debe realizar la actualización de la numeración.
                        lRet:= MsgYesNo(STR0009 + oModelSF1:GetValue("F1_DOC") +  STR0010 + cNFiscal  ) //El documento Nº:  #  existe, confirma modificación de la numeración a:
                        If lRet
                            self:UpdNumberDetail(cNFiscal)
                        EndIf
                    Else //No realiza la actualización de la numeración.
                        oModel:SetErrorMessage("SF1_MASTER", 'F1_DOC', "SF1_MASTER", 'F1_DOC', 'NumDocument', STR0011 +"("+cNFiscal+"/"+cSerie+")" , '', '') //¡Verifique la numeración de la Factura! Esta Factura ya existe.
                        lRet := .F.
                    EndIf
                Else //Documento de no formulario propio.
                    oModel:SetErrorMessage("SF1_MASTER", 'F1_DOC', "SF1_MASTER", 'F1_DOC', 'NumDocument', STR0009 + "("+cNFiscal+" / "+cSerie+")" + STR0012, '', '') //El documento Nº:  # ya existe
                    lRet := .F.
                EndIf
            EndIf
        EndIf

        //Valida que exista el cliente utilizado.
        If lRet .and. self:oTipoDoc:ValidCustomerExist() //Documentos de formulario propio de clientes.
            aArea := GetArea()
            SA1->(DBSetOrder(1))
            If !SA1->(MSSeek(xFilial("SA1")+cCliFor+cLoja))
                oModel:SetErrorMessage("SF1_MASTER", 'F1_DOC', "SF1_MASTER", 'F1_DOC', 'Customer', STR0013+"("+cCliFor+"/"+cLoja+")", '', '') //Cliente no registrado 
                lRet := .F.
            EndIf
            RestArea(aArea)
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} GridPosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validación de grid.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		04/2023
/*/
Method GridPosVld(oSubModel, cModelID) Class LXINFIS
Local lRet      := .T.
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")
Local nX        := ""
Local cNFiscal  := ""
Local cSerie    := ""

    If cModelID == "SD1_DETAIL"
        //Valida que la numeración de los items corresponda a la numeración del encabezado.
        cNFiscal    := oModelSF1:GetValue("F1_DOC")
        cSerie      := oModelSF1:GetValue("F1_SERIE")

        If self:oTipoDoc:ValidItemNumberDoc(cPaisLoc)
            For nX := 1 to oSubModel:Length()
                If !oSubModel:IsDeleted(nX) .and. oSubModel:IsUpdated(nX) 
                    If lRet .and. (oSubModel:GetValue("D1_DOC", nX) <> cNFiscal .or. oSubModel:GetValue("D1_SERIE", nX) <> cSerie)
                        oModel:SetErrorMessage(cModelID, 'D1_DOC', cModelID, 'D1_DOC', 'NumDocument', STR0006 +"("+cNFiscal+"-"+cSerie+"/"+oSubModel:GetValue("D1_DOC", nX)+"-"+oSubModel:GetValue("D1_SERIE", nX)+")" , '', '') //Inconsistencias en la numeración de la Factura con relación a sus ítems
                        lRet := .F.
                    EndIf
                EndIf
            Next
        EndIf
    EndIf

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
@since		08/2023
/*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class LXINFIS
Local lRet      := .T.
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")
Local aArea     := GetArea()

    If cModelID == "SD1_DETAIL"
        If cAction == "SETVALUE"
            If cId == "D1_COD"
                oSubModel:LoadValue("D1_DOC", oModelSF1:GetValue("F1_DOC"))
                oSubModel:LoadValue("D1_SERIE", oModelSF1:GetValue("F1_SERIE"))
                oSubModel:LoadValue("D1_FORNECE", oModelSF1:GetValue("F1_FORNECE"))
                oSubModel:LoadValue("D1_LOJA", oModelSF1:GetValue("F1_LOJA"))
                DbSelectArea("SB1")
                SB1->(DbSetOrder(1))
                If SB1->(MsSeek(xFilial("SB1") + xValue))
                    oSubModel:LoadValue("D1_UM", SB1->B1_UM)
                    oSubModel:LoadValue("D1_SEGUM", SB1->B1_SEGUM)
                    oSubModel:LoadValue("D1_LOCAL", SB1->B1_LOCPAD)
                    oSubModel:LoadValue("D1_TES", SB1->B1_TE)
                    oSubModel:LoadValue("D1_CF", Posicione("SF4", 1, xFilial("SF4") + SB1->B1_TE, "F4_CF"))
                EndIf
            ElseIf FindString(cId, {"D1_QUANT", "D1_VUNIT", "D1_TOTAL", "D1_TES", "D1_DESC", "D1_VALDESC", "D1_CF","D1_CODMUN","D1_TPACTIV"})
                If !(xCurrentValue == xValue)
                    oModelSF1:LoadValue("CALC", .T.)
                ElseIf cId == "D1_TOTAL" .and. xValue == 0 .and. xCurrentValue == 0
                    //Solventa la situación cuando se usa una TES que permite cantidad en 0.
                    oSubModel:ClearField(cId, nLine, .F.) 
                EndIf
            EndIf
        ElseIf cAction == "DELETE" .Or. cAction == "UNDELETE"
            If oSubModel:IsUpdated(nLine)
                oModelSF1:LoadValue("CALC", .T.)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)

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
@since		04/2023
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXINFIS
Local lRet      := .T.
Local cRemito   := ""
Local cItRemito := ""
Local cTipo     := ""
Local cTipoDoc  := ""
Local cTes      := ""
Local cPedido   := ""
Local cItemPC   := ""
Local aArea     := {}
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")


    If cModelID == "SD1_DETAIL"

        cRemito     := oSubModel:GetValue("D1_REMITO", nLine)
        cItRemito   := oSubModel:GetValue("D1_ITEMREM", nLine)
        cNFOri      := oSubModel:GetValue("D1_NFORI", nLine)
        cTes        := oSubModel:GetValue("D1_TES", nLine)
        cPedido     := oSubModel:GetValue("D1_PEDIDO", nLine)
        cItemPC     := oSubModel:GetValue("D1_ITEMPC", nLine)
        cTipo       := oModelSF1:GetValue("F1_TIPO")
        cTipoDoc    := oModelSF1:GetValue("F1_TIPODOC")
        self:oTipoDoc:SetTipoDoc(cTipoDoc)

        //Verifica la integridad de información referente a un remito.
        If (!Empty(cRemito) .and. Empty(cItRemito)) .or. (!Empty(cItRemito) .and. Empty(cRemito))
            oModel:SetErrorMessage("SD1_DETAIL", 'D1_REMITO', 'D1_REMITO', 'D1_REMITO', 'ITREMITO', STR0001, '', '') //Complete correctamente los campos de Remito e Ítem de Remito.
            lRet := .F.
        EndIf

        //Valida NF requerida
        If lRet .and. self:oTipoDoc:ValidNFRequired(AllTrim(cTipo)) .and. Empty(cNFOri)
            oModel:SetErrorMessage("SD1_DETAIL", 'D1_NFORI', 'D1_NFORI', 'D1_NFORI', 'ITNFORI', STR0002, '', '') //Complete los datos de la Factura original
            lRet := .F.
        EndIf

        //Verificación de que para documentos de entradas se use una TES menor a 500.
        If lRet .and. Val(cTes) > 500
            oModel:SetErrorMessage("SD1_DETAIL", 'D1_TES', 'D1_TES', 'D1_TES', 'ITTES', STR0003 +"("+cTes+")", '', '') //¡TES no válido para este documento!
            lRet := .F.
        EndIf

        //Validación de que exista la TES.
        If lRet 
            aArea := GetArea()
            DbSelectArea("SF4")
            DbSetOrder(1)
            If !SF4->(MsSeek(xFilial("SF4")+cTes))
                oModel:SetErrorMessage("SD1_DETAIL", 'D1_TES', 'D1_TES', 'D1_TES', 'ITTES', STR0004 +"("+cTes+")", '', '') //TES no válido
                lRet := .F.
            EndIf
            RestArea(aArea)
        EndIf

        //Verifica la integridad de información referente a un pedido de compra.
        If lRet .and. (!Empty(cPedido) .and. Empty(cItemPC)) .or. (!Empty(cItemPC) .and. Empty(cPedido))
            oModel:SetErrorMessage("SD1_DETAIL", 'D1_PEDIDO', 'D1_PEDIDO', 'D1_PEDIDO', 'ITPEDIDO', STR0005, '', '') //Verifique los datos referentes al Pedido de compra y su respectivo ítem
            lRet := .F.
        Endif

    EndIf

Return lRet

/*/{Protheus.doc} UpdNumberDetail
Metodo responsabe por realizar la actualización en caso de cambio de numeración por duplicidad,
actualiza datos en SF1 y SD1.
@type 		Method
@param 		cNumDoc	,caracter	, numero a ser actualizado en el modelo, encabezado y detalle
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		04/2023
/*/
Method UpdNumberDetail(cNumDoc) Class LXINFIS
Local nX        := 0
Local nD1line   := 0
Local oModel    := FwModelActivate()
Local oModelSD1 := oModel:GetModel("SD1_DETAIL")

Default cNumDoc := ""

    oModel:GetModel("SF1_MASTER"):LoadValue("F1_DOC", cNumDoc)
    nD1line := oModelSD1:GetLine()
    For nX := 1 To oModelSD1:Length()
        oModelSD1:GoLine(nX)
        If !oModelSD1:IsDeleted()
            oModelSD1:LoadValue("D1_DOC", cNumDoc)
        EndIf
    Next
    oModelSD1:GoLine(nD1line)

Return

/*/{Protheus.doc} FieldPreVld
Metodo responsabe por ejecutar pre validaciones del campo.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		cAction 	,caracter	,Identificador de la acción realizada (CANSETVALUE/SETVALUE).
@param 		cId     	,caracter	,Identificador del campo ejecutado.
@param 		xValue  	,       	,Valor recibido del campo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		08/2023
/*/
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class LXINFIS
Local lRet      := .T.

    If cModelID == "SF1_MASTER"
        If cAction == "SETVALUE"
            Do Case
                Case cId == "F1_DOC"
                    self:UpdItems("SD1_DETAIL", "D1_DOC", xValue)
                Case cId == "F1_SERIE"
                    self:UpdItems("SD1_DETAIL", "D1_SERIE", xValue)
                Case cId == "F1_FORNECE"
                    self:UpdItems("SD1_DETAIL", "D1_FORNECE", xValue)
                Case cId == "F1_LOJA"
                    self:UpdItems("SD1_DETAIL", "D1_LOJA", xValue)
                Case cId == "F1_PROVENT"
                    self:UpdItems("SD1_DETAIL", "D1_PROVENT", xValue)
            EndCase
            If (FindString(cId, {"F1_FORNECE", "F1_LOJA", "F1_DOC", "F1_SERIE", "F1_TPACTIV","F1_EMISSAO"}) .and. (!Empty(FwFldGet(cId)) .and. !(FwFldGet(cId) == xValue)) .and. oSubModel:GetValue("F1_VALMERC") > 0) .Or. (FindString(cId, {"F1_FRETE", "F1_DESPESA", "F1_SEGURO", "F1_DESCONT"}))
                oSubModel:LoadValue("CALC", .T.)
            EndIf
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} UpdItems
Metodo responsabe por actualizar campos del encabezado en todos los items (Documento/Serie).
@type 		Method
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@param 		cField     	,caracter	,Identificador del campo a actualizar.
@param 		xValue  	,       	,Valor recibido del campo.
@Return     
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		08/2023
/*/
Method UpdItems(cModelID, cField, xValue) Class LXINFIS
Local nX        := 0
Local nline     := 0
Local oModel    := FwModelActivate()
Local oSubModel := oModel:GetModel(cModelID)

Default cModelID    := ""
Default cField      := ""
Default xValue      := ""

    nline := oSubModel:GetLine()
    For nX := 1 To oSubModel:Length()
        oSubModel:GoLine(nX)
        If !oSubModel:IsDeleted()
            oSubModel:LoadValue(cField, xValue)
        EndIf
    Next
    oSubModel:GoLine(nline)

Return


