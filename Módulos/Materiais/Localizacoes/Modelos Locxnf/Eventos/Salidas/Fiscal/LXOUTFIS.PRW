#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "LXOUTFIS.CH"

/*/{Protheus.doc} LXOUTFIS
Clase responsable por el evento de reglas de negocio de 
localización padrón

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Class LXOUTFIS From FwModelEvent

    //Propiedades que pueden ser alteradas desde los eventos con localización
    DATA oTipoDoc as object

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method ModelPosVld()
    Method GridPosVld()
    Method GridLinePosVld()
    Method UpdNumberDetail()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Method New() Class LXOUTFIS 


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
Method Activate(oModel, lCopy) Class LXOUTFIS

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
@since		04/2021 
/*/
Method VldActivate(oModel, cModelId) Class LXOUTFIS
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
Method ModelPosVld(oModel, cModelId) Class LXOUTFIS
Local lRet      := .T. 
Local lExist    := .F.
Local oModelSF2 := oModel:GetModel("SF2_MASTER")
Local cSerie    := ""
Local cNFiscal  := ""
Local cCliFor   := ""
Local cLoja     := ""
Local cEspecie  := ""
Local cTipoDoc  := ""
Local cNumAnt   := ""
Local nUpdNum   := SuperGetMV("MV_ALTNUM",,1)
Local aArea     := {}

    cSerie      := oModelSF2:GetValue("F2_SERIE")
    cNFiscal    := oModelSF2:GetValue("F2_DOC")
    cCliFor     := oModelSF2:GetValue("F2_CLIENTE")
    cLoja       := oModelSF2:GetValue("F2_LOJA")
    cEspecie    := oModelSF2:GetValue("F2_ESPECIE")
    cTipoDoc    := oModelSF2:GetValue("F2_TIPODOC")
    self:oTipoDoc:SetTipoDoc(cTipoDoc)

    If self:oTipoDoc:ValidNumTRF() //Documentos de transferencia.
        lRet := !aNumTRFNaoExiste("SF2", cSerie, cNFiscal, cCliFor, cLoja, cEspecie, {{"F2_TIPODOC", "F2_EMISSAO"}, {cTipoDoc, oModelSF2:GetValue("F2_EMISSAO")}, {}})
    EndIf

    //Verificación de existencia del numero de documento usado.
    If lRet
        lExist := !aNumNaoExiste("SF2", cSerie, cNFiscal, cCliFor, cLoja, cEspecie)
        If lExist
            If self:oTipoDoc:UpdateNumberDoc() //Documentos de formulario propio.
                While lExist
                    cNFiscal    := Soma1(cNFiscal)
                    lExist      := !aNumNaoExiste("SF2", cSerie, cNFiscal, cCliFor, cLoja, cEspecie)
                EndDo
                If nUpdNum == 1 //Realiza la actualización de la numeración.
                    cNumAnt := oModelSF2:GetValue("F2_DOC")
                    self:UpdNumberDetail(cNFiscal)
                    MsgInfo(STR0007 + cNumAnt + STR0008 + cNFiscal, STR0014) //El número del documento fue modificado de: #  a:  # Número
                ElseIf nUpdNum == 2 //Pregunta si debe realizar la actualización de la numeración.
                    lRet:= MsgYesNo(STR0009 + oModelSF2:GetValue("F2_DOC") +  STR0010 + cNFiscal  ) //El documento Nº:  #  existe, confirma modificación de la numeración a: 
                    If lRet
                        self:UpdNumberDetail(cNFiscal)
                    EndIf
                Else //No realiza la actualización de la numeración.
                    oModel:SetErrorMessage("SF2_MASTER", 'F2_DOC', "SF2_MASTER", 'F2_DOC', 'NumDocument', STR0011 +"("+cNFiscal+"/"+cSerie+")" , '', '') //¡Verifique la numeración de la Factura! Esta Factura ya existe.
                    lRet := .F.
                EndIf
            Else //Documento de no formulario propio.
                oModel:SetErrorMessage("SF2_MASTER", 'F2_DOC', "SF2_MASTER", 'F2_DOC', 'NumDocument', STR0009 + "("+cNFiscal+" / "+cSerie+")" + STR0012, '', '') //El documento Nº:  # ya existe
                lRet := .F.
            EndIf
        EndIf
    EndIf

    //Valida que exista el cliente utilizado.
    If lRet .and. self:oTipoDoc:ValidCustomerExist() //Documentos de formulario propio de clientes.
        aArea := GetArea()
        SA1->(DBSetOrder(1))
        If !SA1->(MSSeek(xFilial("SA1")+cCliFor+cLoja))
            oModel:SetErrorMessage("SF2_MASTER", 'F2_CLIENTE', "SF2_MASTER", 'F2_CLIENTE', 'Customer', STR0013+"("+cCliFor+"/"+cLoja+")", '', '') //Cliente no registrado 
            lRet := .F.
        EndIf
        RestArea(aArea)
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
Method GridPosVld(oSubModel, cModelID) Class LXOUTFIS
Local lRet      := .T.
Local oModel    := FwModelActivate()
Local oModelSF2 := oModel:GetModel("SF2_MASTER")
Local nX        := ""
Local cNFiscal  := ""
Local cSerie    := ""

    If cModelID == "SD2_DETAIL"
        //Valida que la numeración de los items corresponda a la numeración del encabezado.
        cNFiscal    := oModelSF2:GetValue("F2_DOC")
        cSerie      := oModelSF2:GetValue("F2_SERIE")

        If self:oTipoDoc:ValidItemNumberDoc(cPaisLoc)
            For nX := 1 to oSubModel:Length()
                If !oSubModel:IsDeleted()
                    If lRet .and. (oSubModel:GetValue("D2_DOC", nX) <> cNFiscal .or. oSubModel:GetValue("D2_SERIE", nX) <> cSerie)
                        oModel:SetErrorMessage(cModelID, 'D2_DOC', cModelID, 'D2_DOC', 'NumDocument', STR0006 +"("+cNFiscal+"-"+cSerie+"/"+oSubModel:GetValue("D2_DOC", nX)+"-"+oSubModel:GetValue("D2_SERIE", nX)+")" , '', '') //Inconsistencias en la numeración de la Factura con relación a sus ítems
                        lRet := .F.
                    EndIf
                EndIf
            Next
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
@since		04/2023
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXOUTFIS
Local lRet      := .T.
Local cRemito   := ""
Local cItRemito := ""
Local cTipo     := ""
Local cTipoDoc  := ""
Local cTes      := ""
Local cPedido   := ""
Local cItemPV   := ""
Local aArea     := {}
Local oModel    := FwModelActivate()
Local oModelSF2 := oModel:GetModel("SF2_MASTER")


    If cModelID == "SD2_DETAIL"

        cRemito     := oSubModel:GetValue("D2_REMITO", nLine)
        cItRemito   := oSubModel:GetValue("D2_ITEMREM", nLine)
        cNFOri      := oSubModel:GetValue("D2_NFORI", nLine)
        cTes        := oSubModel:GetValue("D2_TES", nLine)
        cPedido     := oSubModel:GetValue("D2_PEDIDO", nLine)
        cItemPV     := oSubModel:GetValue("D2_ITEMPV", nLine)
        cTipo       := oModelSF2:GetValue("F2_TIPO")
        cTipoDoc    := oModelSF2:GetValue("F2_TIPODOC")
        self:oTipoDoc:SetTipoDoc(cTipoDoc)

        //Verifica la integridad de información referente a un remito.
        If (!Empty(cRemito) .and. Empty(cItRemito)) .or. (!Empty(cItRemito) .and. Empty(cRemito))
            oModel:SetErrorMessage("SD2_DETAIL", 'D2_REMITO', 'D2_REMITO', 'D2_REMITO', 'ITREMITO', STR0001, '', '') //Complete correctamente los campos de Remito e Ítem de Remito.
            lRet := .F.
        EndIf

        //Valida NF requerida
        If lRet .and. self:oTipoDoc:ValidNFRequired(AllTrim(cTipo)) .and. Empty(cNFOri)
            oModel:SetErrorMessage("SD2_DETAIL", 'D2_NFORI', 'D2_NFORI', 'D2_NFORI', 'ITNFORI', STR0002, '', '') //Complete los datos de la Factura original
            lRet := .F.
        EndIf

        //Verificación de que para documentos de salidas se use una TES mayor a 500.
        If lRet .and. Val(cTes) <= 500
            oModel:SetErrorMessage("SD2_DETAIL", 'D2_TES', 'D2_TES', 'D2_TES', 'ITTES', STR0003 + "("+cTes+")", '', '') //¡TES no válido para este documento!
            lRet := .F.
        EndIf

        //Validación de que exista la TES.
        If lRet 
            aArea := GetArea()
            DbSelectArea("SF4")
            DbSetOrder(1)
            If !SF4->(MsSeek(xFilial("SF4")+cTes))
                oModel:SetErrorMessage("SD2_DETAIL", 'D2_TES', 'D2_TES', 'D2_TES', 'ITTES', STR0004 + "("+cTes+")", '', '') //TES no válido
                lRet := .F.
            EndIf
            RestArea(aArea)
        EndIf

        //Verifica la integridad de información referente a un pedido de venta.
        If lRet .and. (!Empty(cPedido) .and. Empty(cItemPV)) .or. (!Empty(cItemPV) .and. Empty(cPedido))
            oModel:SetErrorMessage("SD2_DETAIL", 'D2_PEDIDO', 'D2_PEDIDO', 'D2_PEDIDO', 'ITPEDIDO', STR0005, '', '') //Verifique la cumplimentación del Pedido de venta y su respectivo ítem
            lRet := .F.
        Endif

    EndIf

Return lRet

/*/{Protheus.doc} UpdNumberDetail
Metodo responsabe por realizar la actualización en caso de cambio de numeración por duplicidad,
actualiza datos en SF2 y SD2.
@type 		Method
@param 		cNumDoc	,caracter	, numero a ser actualizado en el modelo, encabezado y detalle.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		04/2023
/*/
Method UpdNumberDetail(cNumDoc) Class LXOUTFIS
Local nX        := 0
Local nD2line   := 0
Local oModel    := FwModelActivate()
Local oModelSD2 := oModel:GetModel("SD2_DETAIL")

Default cNumDoc := ""

    oModel:GetModel("SF2_MASTER"):LoadValue("F2_DOC", cNumDoc)
    nD2line := oModelSD2:GetLine()
    For nX := 1 To oModelSD2:Length()
        oModelSD2:GoLine(nX)
        If !oModelSD2:IsDeleted()
            oModelSD2:LoadValue("D2_DOC", cNumDoc)
        EndIf
    Next
    oModelSD2:GoLine(nD2line)

Return
