#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "LXINFIN.CH"

/*/{Protheus.doc} LXINFIN
Clase responsable por el evento de reglas de negocio de 
localización padrón

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		03/2023
/*/
Class LXINFIN From FwModelEvent

    //Propiedades que pueden ser alteradas desde los eventos con localización
    DATA oTipoDoc as object
    DATA lDuplicatas as logical
    DATA lAjustDup as logical
    DATA lCharDup as logical
    DATA cCharDup as character

    Method New() CONSTRUCTOR
    Method Activate()
    Method VldActivate()
    Method ModelPosVld()
    Method GridPosVld()
    Method GridLinePosVld()
    Method UpdNumberDetail()
    Method FieldPreVld()
    Method CajaChicaVld()
    Method GridLinePreVld()
    Method DelAnticipo()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		03/2023
/*/
Method New() Class LXINFIN 


Return Nil

/*/{Protheus.doc} Activate
Metodo activate

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		lCopy    ,caracter	,Informa si el model debe copiar los datos del registro posicionado.
@author 	raul.medina
@version	12.1.2210 / Superior
@since		03/2023
/*/
Method Activate(oModel, lCopy) Class LXINFIN

    self:oTipodoc := TipoDoc():New()
    self:lDuplicatas := .T.
    self:lAjustDup := !(cPaisLoc == "EUA")
    self:lCharDup := cPaisLoc == "RUS"
    self:cCharDup :=  CHR(124)

Return

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@param 		oModel	 ,objeto	,Modelo de dados.
@param 		cModelID ,caracter	,Identificador do sub-modelo.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method VldActivate(oModel, cModelId) Class LXINFIN
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
@since		03/2023
/*/
Method ModelPosVld(oModel, cModelId) Class LXINFIN
Local lRet      := .T. 
Local lExist    := .F.
Local oModelSF1 := oModel:GetModel("SF1_MASTER")
Local oModelDUP := oModel:GetModel("DUP_DETAIL")
Local oModelSEV := oModel:GetModel("SEV_DETAIL")
Local nBaseDup  := 0
Local nMonedaNF := 0
Local nTaxa     := 0
Local nValBrut  := 0
Local nI        := 0
Local nTotDup   := 0
Local nValMulNat:= 0
Local nMoeFin   := 0
Local cCondicao := ""
Local cTipoDoc  := ""
Local cNatureza := ""
Local cSerie    := ""
Local cNFiscal  := ""
Local cCliFor   := ""
Local cLoja     := ""
Local cEspecie  := ""
Local cNumAnt   := ""
Local cEspAux   := ""
Local nUpdNum   := SuperGetMV("MV_ALTNUM",,1)
Local aDupli    := {}
Local nOpc		:= oModel:GetOperation()

Private cTipoNF   := ""

    cTipoDoc    := oModelSF1:GetValue("F1_TIPODOC")
    self:oTipoDoc:SetTipoDoc(cTipoDoc)
    nBaseDup    := IIf(oModelSF1:HasField("BASEDUP"),  oModelSF1:GetValue("BASEDUP"), 0)
    cCondicao   := oModelSF1:GetValue("F1_COND")
    If oModelSF1:HasField("F1_NATFIN") .and. !Empty(oModelSF1:GetValue("F1_NATFIN"))
        cNatureza   := oModelSF1:GetValue("F1_NATFIN")
    Else
        If self:oTipoDoc:ValidNatAnt(cPaisLoc)
            cNatureza   := oModelSF1:GetValue("F1_NATUREZ")
        EndIf
    EndIf
    nMonedaNF   := oModelSF1:GetValue("F1_MOEDA")
    nMoeFin     := IIf(oModelSF1:HasField("F1_MOEFIN") .and. !Empty(oModelSF1:GetValue("F1_MOEFIN")),  oModelSF1:GetValue("F1_MOEFIN"), nMonedaNF)
    nTaxa       := oModelSF1:GetValue("F1_TXMOEDA")
    nValBrut    := oModelSF1:GetValue("F1_VALBRUT")
    cSerie      := oModelSF1:GetValue("F1_SERIE")
    cNFiscal    := oModelSF1:GetValue("F1_DOC")
    cCliFor     := oModelSF1:GetValue("F1_FORNECE")
    cLoja       := oModelSF1:GetValue("F1_LOJA")
    cEspecie    := oModelSF1:GetValue("F1_ESPECIE")
    cEspAux     := PADR(cEspecie,GETSX3CACHE("E2_TIPO", "X3_TAMANHO"))
    cTipoNF     := oModelSF1:GetValue("F1_TIPO")


    If nOpc == MODEL_OPERATION_INSERT
        If self:oTipoDoc:ValidConditionPayment() .and. nBaseDup > 0 .and. Empty(cCondicao)
            oModel:SetErrorMessage("SF1_MASTER", 'F1_COND', 'SF1_MASTER', 'F1_COND', 'Condition', STR0001 + GetSx3Cache('F1_COND',"X3_TITULO"), '', '') //Complete el campo del encabezado:
            lRet := .F.
        EndIf
        
        If lRet 
            If !(Type("aCfgNf") == "A")
                aCfgNf  := GetF1CfgNF()
            EndIf

            //Verificación de existencia del numero de documento usado.
            For nI := 1 To oModelDUP:Length()
                If DesTrans(Extrae(oModelDUP:GetValue("DUP", nI),5,Iif(self:lCharDup,self:cCharDup,))) > 0
                    aAdd(aDupli, oModelDUP:GetValue("DUP",nI))
                EndIf    
            Next
            lExist := !aDupNaoExiste("SF1", cSerie, cNFiscal, cCliFor, cLoja, cEspAux, aDupli, .F.)
            If lExist
                If self:oTipoDoc:UpdateNumberDoc() //Documentos de formulario propio.
                    While lExist
                        cNFiscal    := Soma1(cNFiscal)
                        lExist      := !aDupNaoExiste("SF1", cSerie, cNFiscal, cCliFor, cLoja, cEspAux, aDupli, .F.)
                    EndDo
                    If nUpdNum == 1 //Realiza la actualización de la numeración.
                        cNumAnt := oModelSF1:GetValue("F1_DOC")
                        self:UpdNumberDetail(cNFiscal)
                        MsgInfo(STR0009 + cNumAnt + STR0010 + cNFiscal, STR0011) //El número del documento fue modificado de: #  a:  # Número
                    ElseIf nUpdNum == 2 //Pregunta si debe realizar la actualización de la numeración.
                        lRet:= MsgYesNo(STR0012 + oModelSF1:GetValue("F1_DOC") +  STR0013 + cNFiscal  ) //El documento Nº:  #  existe, confirma modificación de la numeración a:
                        If lRet
                            self:UpdNumberDetail(cNFiscal)
                        EndIf
                    Else //No realiza la actualización de la numeración.
                        oModel:SetErrorMessage("SF1_MASTER", 'F1_DOC', "SF1_MASTER", 'F1_DOC', 'NumDocument', STR0014 +"("+cNFiscal+"/"+cSerie+")" , '', '') //¡Verifique la numeración de la Factura! Esta Factura ya existe.
                        lRet := .F.
                    EndIf
                Else //Documento de no formulario propio.
                    oModel:SetErrorMessage("SF1_MASTER", 'F1_DOC', "SF1_MASTER", 'F1_DOC', 'NumDocument', STR0012 + "("+cNFiscal+" / "+cSerie+")" + STR0015, '', '') //El documento Nº:  # ya existe
                    lRet := .F.
                EndIf
            EndIf
        EndIf

        If lRet .and. self:oTipoDoc:ValidNature() .and. nBaseDup > 0 .and. Empty(cNatureza)
            oModel:SetErrorMessage("SF1_MASTER", 'F1_NATUREZ', 'SF1_MASTER', 'F1_NATUREZ', 'Nature', STR0002, '', '') //¡Informe el código de la modalidad!
            lRet := .F.
        EndIf

        If lRet .and. self:lDuplicatas .and. self:oTipoDoc:ValidFinancialTitle(cPaisLoc) .and. oModelDUP:Length() > 0
            For nI := 1 To oModelDUP:Length()
                nTotDup += DesTrans(Extrae(oModelDUP:GetValue("DUP", nI),5,Iif(self:lCharDup,self:cCharDup,)))
            Next nI
            //Ajuste para permitir el valor financiero con impuestos provisionales del MATA462N y MATA462AN
            If self:lAjustDup .and. nTotDup > 0
                If Abs(xMoeda(nBaseDup,nMonedaNF,nMoeFin,dDataBase,,nTaxa) - nTotDup) > SuperGetMV("MV_LIMPAG")
                    oModel:SetErrorMessage("SF1_MASTER", 'F1_COND', 'SF1_MASTER', 'F1_COND', 'TitlesFin', STR0003, '', '') //Inconsistencias en los valores financieros
                    lRet	:= .F.
                EndIf
            EndIf
        EndIf
        
        //Validación de monto no negativo
        If lRet .and. xMoeda(nValBrut,nMonedaNF,nMoeFin,dDataBase,,nTaxa) < 0
            Help("  ",1,'TOTAL')
            lRet := .F.
        EndIf

        //Validación para considerar el valor total de las multinaturalezas
        If lRet .and. (self:oTipoDoc:ValidMultiNatureSE1() .or. self:oTipoDoc:ValidMultiNatureSE2()) .and. nBaseDup > 0 
            For nI := 1 To oModelSEV:Length()
                nValMulNat += oModelSEV:GetValue("EV_VALOR", nI)
            Next
            nTotDup := 0
            For nI := 1 To oModelDUP:Length()
                nTotDup += DesTrans(Extrae(oModelDUP:GetValue("DUP", nI),5,Iif(self:lCharDup,self:cCharDup,)))
            Next nI
            If nValMulNat <> 0 .and. nValMulNat <> nTotDup
                lRet := .F.
                oModel:SetErrorMessage("SEV_DETAIL", 'EV_VALOR', "SEV_DETAIL", 'EV_VALOR', 'MultiNature', STR0008, '', '') //Valor de modalidades incorrecto.
            EndIf
        EndIf

        //Validaciones de caja chica
        If lRet .and. self:oTipoDoc:ValidCajaChica()
            lRet := self:CajaChicaVld(oModel:GetModel("SEU_DETAIL"))
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} GridPosVld
Metodo responsabe por ejecutar reglas de negocio genericas para validación de grid.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@param 		cModelID	,caracter	,Identificador do sub-modelo.
@Return     lRet        ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		04/2023
/*/
Method GridPosVld(oSubModel, cModelID) Class LXINFIN
Local lRet      := .T.
Local nX        := 0
Local nPorcent  := 0
Local oModel    := FwModelActivate()

    //Verificación del 100% de prorrateo en las multi naturalezas
    If cModelID == "SEV_DETAIL"
        For nX := 1 To oSubModel:Length()
            nPorcent += oSubModel:GetValue("EV_PERC", nX)
        Next
        If nPorcent <> 100 .And. nPorcent<> 0
            lRet := .F.
            oModel:SetErrorMessage(cModelID, 'EV_PERC', cModelID, 'EV_PERC', 'MultiPerc', STR0006 + STR0007 + TransForm(nPorcent,"@E 99.99%"), '', '') //La suma de los porcentajes informados de totalizar 100%. # Porcentaje alcanzado ==>
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
@since		03/2023
/*/
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXINFIN
Local lRet      := .T.
Local cTes      := ""
Local nQuant    := 0
Local nUnValue  := 0
Local nTotal    := 0
Local nTotAux   := 0
Local nMonedaNF := 1
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")

    If cModelID == "SD1_DETAIL"
        cTes        := oSubModel:GetValue("D1_TES", nLine)
        nQuant      := oSubModel:GetValue("D1_QUANT", nLine)
        nUnValue    := oSubModel:GetValue("D1_VUNIT", nLine)
        nTotal      := oSubModel:GetValue("D1_TOTAL", nLine)
        nMonedaNF   := oModelSF1:GetValue("F1_MOEDA")

        If lRet .and. nUnValue < 0
            lRet := .F.
            oModel:SetErrorMessage(cModelID, 'D1_VUNIT', cModelID, 'D1_VUNIT', 'UnitVal', STR0004, '', '') //Valor unitario no puede ser negativo.
        EndIf

        If lRet .and. self:oTipoDoc:ValidDecimals(cPaisLoc)
            If MaTesSel(cTes).And. nQuant == 0
                If nUnValue<>nTotal
                    oModel:SetErrorMessage(cModelID, 'D1_TOTAL', cModelID, 'D1_TOTAL', 'QuantZero', STR0005, '', '') //Inconsistencia en los valores del documento.
                    lRet := .F.
                EndIf
            Else
                nTotAux := Iif(self:oTipoDoc:ValidArred(cPaisLoc), A410Arred((nUnValue*nQuant),"D1_TOTAL",nMonedaNF),(nUnValue*nQuant))
                If Abs(nTotal - nTotAux) > (1/(10**(Iif(MsDecimais(nMonedaNF)==0,1,MsDecimais(nMonedaNF))-1)))/   IIF (MsDecimais(nMonedaNF)==0 ,1,  2) 
                    lRet := .F.
                    oModel:SetErrorMessage(cModelID, 'D1_TOTAL', cModelID, 'D1_TOTAL', 'D1_TOTAL', STR0005, '', '') //Inconsistencia en los valores del documento.
                EndIf
            EndIf
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} UpdNumberDetail
Metodo responsabe por realizar la actualización en caso de cambio de numeración por duplicidad,
actualiza datos en SF1 y SD1.
@type 		Method
@param 		cNumDoc	,caracter	, numero a ser actualizado en el modelo, encabezado y detalle
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		04/2023
/*/
Method UpdNumberDetail(cNumDoc) Class LXINFIN
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
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class LXINFIN
Local lRet      := .T.
Local oView     := FwViewActive()
Local oModel

    If cModelID == "SF1_MASTER"
        If cAction == "SETVALUE"
            Do Case
                Case cId == "F1_COND"
                    If oSubModel:HasField("F1_MOEFIN")
                        oSubModel:LoadValue("F1_MOEFIN", oSubModel:GetValue("F1_MOEDA"))
                    EndIf
                    F1PaymntCn(xValue)
                Case cId == "F1_MOEDA"
                    If ValType(oView) == "O" .and. !(oSubModel:GetValue("F1_MOEDA") == xValue)
                        If FwIsInCallStack("MAKEVALID")
                            oModel := FwModelActive()
                            If oModel:GetModel("SD1_DETAIL"):Length() > 1 .Or. !Empty(oModel:GetModel("SD1_DETAIL"):GetValue("D1_COD",1))
                                If MsgYesNo(OemToAnsi(STR0019),OemToAnsi(STR0020))
                                    If !Empty(oSubModel:GetValue("F1_COND"))
                                        oSubModel:LoadValue("F1_COND", "")
                                        oSubModel:LoadValue("F1_DSCCOND", "")
                                        F1PaymntCn("")
                                    EndIf
                                    CleanModIn(oView)
                                Else
                                    lRet := .F.
                                EndIf
                            EndIf
                        Else
                            lRet := .F.
                        EndIf
                    EndIf
            EndCase
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} GridLinePreVld
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
@since		11/2023
/*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class LXINFIN
Local lRet      := .T.
Local aArea     := GetArea()

    If cModelID == "SD1_DETAIL"
        If cAction == "SETVALUE"
            If cId == "D1_COD"
                DbSelectArea("SB1")
                SB1->(DbSetOrder(1))
                If SB1->(MsSeek(xFilial("SB1") + xValue))
                    oSubModel:LoadValue("D1_CONTA", SB1->B1_CONTA)
                    oSubModel:LoadValue("D1_ITEMCTA", SB1->B1_ITEMCC)
                    oSubModel:LoadValue("D1_CLVL", SB1->B1_CLVL)
                    oSubModel:LoadValue("D1_CC", SB1->B1_CC)
                EndIf
            ElseIf cId == "D1_TES"
                If oSubModel:HasField("D1_VALADI") .and. oSubModel:GetValue("D1_VALADI", nLine) > 0
                    If 1 == Aviso(STR0021,STR0022,{STR0023,STR0024}) //"¡Atencion!"#"Después de vincular los anticipos, si la TES se modifica, es necesario remover los anticipos. ¿Desea remover los anticipos y modificar la TES?"#SIM#NAO
                        oSubModel:LoadValue("D1_VALADI", 0)
                        self:DelAnticipo(nLine)
                    Else
                        lRet := .F.
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    RestArea(aArea)

Return lRet

/*/{Protheus.doc} CajaChicaVld
Metodo responsabe por ejecutar las validaciones de caja chica.
@type 		Method
@param 		oSubModel	,objeto		,Modelo de dados.
@Return     lRet     ,logico    ,Retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		10/2023
/*/
Method CajaChicaVld(oSubModel) Class LXINFIN
Local lRet      := .T.
Local aArea     := getArea()
Local cMsg      := ""

    If !Empty(oSubModel:GetValue("EU_CAIXA")) .or. oSubModel:GetValue("EU_VALOR") > 0 .or. !Empty(oSubModel:GetValue("EU_BENEF"))
        If Empty(oSubModel:GetValue("EU_CAIXA"))
            cMsg := AllTrim(FWX3Titulo("EU_CAIXA")) + " (EU_CAIXA)"
            lRet := .F.
        EndIf
        If Empty(oSubModel:GetValue("EU_BENEF"))
            cMsg += Iif(Empty(cMsg), "", ", ") +  AllTrim(FWX3Titulo("EU_BENEF")) + " (EU_BENEF)"
            lRet := .F.
        EndIf
        If oSubModel:GetValue("EU_VALOR") <= 0
            cMsg += Iif(Empty(cMsg), "", ", ") +  AllTrim(FWX3Titulo("EU_VALOR")) + " (EU_VALOR)"
            lRet := .F.
        EndIf
        If lRet
            If !Empty(oSubModel:GetValue("EU_NROADIA"))
                dbSelectArea("SEU")
                SEU->(dbSetOrder(6)) //EU_FILIAL+EU_CAIXA+EU_TIPO+EU_NROADIA+EU_NUM
                If SEU->(MsSeek(xFilial("SEU") + oSubModel:GetValue("EU_CAIXA") + "01" + oSubModel:GetValue("EU_NROADIA")))
                    If !(oSubModel:GetValue("EU_VALOR") <= SEU->EU_SLDADIA)
                        Help(" ", 1, "FA560SALDO")
					    lRet	:=	.F.
                    EndIf
                Else
				    Help(" ", 1, "FA560NE") // Adiantamento informado nao encontrado
				    lRet	:=	.F.
                EndIf
            Else
                SET->(dbSetOrder(1)) //ET_FILIAL+ET_CODIGO
                If !(SET->(MsSeek(xFilial("SET") + oSubModel:GetValue("EU_CAIXA"))) .and. SET->ET_SALDO >= oSubModel:GetValue("EU_VALOR"))
                    Help(" ",1,"FA560SALDO")
			        lRet	:=	.F.
                EndIf
            EndIf
        Else
            Help(" ", 1, STR0016, , STR0017 + cMsg, 2, 0)//"CAJA CHICA" "Es necesario informar los siguientes campos: "
        EndIf
    EndIf
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} DelAnticipo
Metodo responsabe por realizar la limpieza de los anticipos.
@type 		Method
@param 		nItem   ,   numerico    , item que está siendo procesado.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		06/2024
/*/
Method DelAnticipo(nItem) Class LXINFIN
Local oModel    := FwModelActivate()
Local nX        := 0
Local nEvent    := 0
Local aRecnoSE1 := {}
Local aNewSE1   := {}

Default nItem := 0
    
    //Se obtiene el arreglo con la información de los anticipos.
    nEvent := aScan(oModel:oEventHandler:aEvents, {|x| x:cIdEvent == "LXINEVENT"})
    If nEvent > 0
        aRecnoSE1 := aClone(oModel:oEventHandler:aEvents[nEvent]:aRecnoSE1)
    EndIf

    //Se crea un arreglo sin la información del item del que fue eliminado el anticipo.
    For nX := 1 To Len(aRecnoSE1)
		If Len(aRecnoSE1[nX]) > 3 .AND. aRecnoSE1[nX][4] != nItem
			AAdd(aNewSE1, aRecnoSE1[nX])
		EndIf
	Next nX

    //Se asigna nuevamente el arreglo con la información de los anticipos.
    If nEvent > 0
        oModel:oEventHandler:aEvents[nEvent]:aRecnoSE1 := aClone(aNewSE1)
    EndIf

Return
