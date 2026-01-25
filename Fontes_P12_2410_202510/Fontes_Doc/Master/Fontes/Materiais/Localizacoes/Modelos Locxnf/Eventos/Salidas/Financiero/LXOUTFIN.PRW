#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "LXOUTFIN.CH"

/*/{Protheus.doc} LXOUTFIN
Clase responsable por el evento de reglas de negocio de 
localización padrón

@type 		Class
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Class LXOUTFIN From FwModelEvent

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
    Method LocXAvCred()

EndClass


/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.2210 / Superior
@since		04/2023
/*/
Method New() Class LXOUTFIN 


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
Method Activate(oModel, lCopy) Class LXOUTFIN

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
@version	12.1.2210 / Superior
@since		04/2021 
/*/
Method VldActivate(oModel, cModelId) Class LXOUTFIN
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
Method ModelPosVld(oModel, cModelId) Class LXOUTFIN
Local lRet      := .T. 
Local oModelSF2 := oModel:GetModel("SF2_MASTER")
Local oModelDUP := oModel:GetModel("DUP_DETAIL")
Local oModelSEV := oModel:GetModel("SEV_DETAIL")
Local nBaseDup  := 0
Local nMonedaNF := 0
Local nTaxa     := 0
Local nValBrut  := 0
Local nI        := 0
Local nTotDup   := 0
Local nVend     := 0
Local nValMulNat:= 0
Local nMoeFin   := 0
Local cCondicao := ""
Local cTipoDoc  := ""
Local cNatureza := ""
Local cVendedor := ""
Local cCpoVend  := ""
Local cSerie    := ""
Local cNFiscal  := ""
Local cCliFor   := ""
Local cLoja     := ""
Local cEspecie  := ""
Local cNumAnt   := ""
Local cEspAux   := ""
Local nUpdNum   := SuperGetMV("MV_ALTNUM",,1)
Local aArea     := {}
Local aDupli    := {}
Local nOpc		:= oModel:GetOperation()

    cTipoDoc    := oModelSF2:GetValue("F2_TIPODOC")
    nBaseDup    := IIf(oModelSF2:HasField("BASEDUP"),  oModelSF2:GetValue("BASEDUP"), 0)
    cCondicao   := oModelSF2:GetValue("F2_COND")
    cNatureza   := oModelSF2:GetValue("F2_NATUREZ")
    nMonedaNF   := oModelSF2:GetValue("F2_MOEDA")
    nMoeFin     := IIf(oModelSF2:HasField("F2_MOEFIN") .and. !Empty(oModelSF2:GetValue("F2_MOEFIN")),  oModelSF2:GetValue("F2_MOEFIN"), nMonedaNF)
    nTaxa       := oModelSF2:GetValue("F2_TXMOEDA")
    nValBrut    := oModelSF2:GetValue("F2_VALBRUT")
    cSerie      := oModelSF2:GetValue("F2_SERIE")
    cNFiscal    := oModelSF2:GetValue("F2_DOC")
    cCliFor     := oModelSF2:GetValue("F2_CLIENTE")
    cLoja       := oModelSF2:GetValue("F2_LOJA")
    cEspecie    := oModelSF2:GetValue("F2_ESPECIE")
    cEspAux     := PADR(cEspecie,GETSX3CACHE("E1_TIPO", "X3_TAMANHO"))
    self:oTipoDoc:SetTipoDoc(cTipoDoc)

    If nOpc == MODEL_OPERATION_INSERT
        If self:oTipoDoc:ValidConditionPayment() .and. nBaseDup > 0 .and. Empty(cCondicao)
            oModel:SetErrorMessage("SF2_MASTER", 'F2_COND', 'SF2_MASTER', 'F2_COND', 'Condition', STR0001 + GetSx3Cache('F2_COND',"X3_TITULO"), '', '') //Complete el campo del encabezado:
            lRet := .F.
        EndIf

        If lRet .and. self:oTipoDoc:ValidCredit()
            lRet := self:LocXAvCred(nBaseDup, nMoedaNF, cCliFor, cLoja)
        EndIf

        If lRet
            //Verificación de existencia del numero de documento usado.
            For nI := 1 To oModelDUP:Length()
                If DesTrans(Extrae(oModelDUP:GetValue("DUP", nI),5,Iif(self:lCharDup,self:cCharDup,))) > 0
                    aAdd(aDupli, oModelDUP:GetValue("DUP",nI))
                EndIf    
            Next
            lExist := !aDupNaoExiste("SF2", cSerie, cNFiscal, cCliFor, cLoja, cEspAux, aDupli, .F.)
            If lExist
                If self:oTipoDoc:UpdateNumberDoc() //Documentos de formulario propio.
                    While lExist
                        cNFiscal    := Soma1(cNFiscal)
                        lExist      := !aDupNaoExiste("SF2", cSerie, cNFiscal, cCliFor, cLoja, cEspAux, aDupli, .F.)
                    EndDo
                    If nUpdNum == 1 //Realiza la actualización de la numeración.
                        cNumAnt := oModelSF2:GetValue("F2_DOC")
                        self:UpdNumberDetail(cNFiscal)
                        MsgInfo(STR0010 + cNumAnt + STR0011 + cNFiscal, STR0012) //El número del documento fue modificado de: #  a:  # Número
                    ElseIf nUpdNum == 2 //Pregunta si debe realizar la actualización de la numeración.
                        lRet:= MsgYesNo(STR0013 + oModelSF2:GetValue("F2_DOC") +  STR0014 + cNFiscal  ) //El documento Nº:  #  existe, confirma modificación de la numeración a: 
                        If lRet
                            self:UpdNumberDetail(cNFiscal)
                        EndIf
                    Else //No realiza la actualización de la numeración.
                        oModel:SetErrorMessage("SF2_MASTER", 'F2_DOC', "SF2_MASTER", 'F2_DOC', 'NumDocument', STR0015 +"("+cNFiscal+"/"+cSerie+")" , '', '') //¡Verifique la numeración de la Factura! Esta Factura ya existe.
                        lRet := .F.
                    EndIf
                Else //Documento de no formulario propio.
                    oModel:SetErrorMessage("SF2_MASTER", 'F2_DOC', "SF2_MASTER", 'F2_DOC', 'NumDocument', STR0013 + "("+cNFiscal+" / "+cSerie+")" + STR0015, '', '') //El documento Nº:  # ya existe
                    lRet := .F.
                EndIf
            EndIf
        EndIf
        
        //Verificación de existencia de vendedores.
        If lRet
            aArea := GetArea()
            SA3->(dbSetOrder(1))
            nVend := Fa440CntVen()
            For nI := 1 to nVend
                cCpoVend  := "F2_VEND"+AllTrim(Str(nI))
                cVendedor := oModelSF2:GetValue(cCpoVend)
                If !Empty(cVendedor)
                    If !SA3->(MsSeek(xFilial("SA3")+cVendedor))
                        oModel:SetErrorMessage("SF2_MASTER", cCpoVend, 'SF2_MASTER', cCpoVend, cCpoVend, STR0004 + "(" + cVendedor + ")", '', '') //¡Código de vendedor inválido!
                        lRet := .F.
                        exit
                    EndIf
                EndIf
            Next nI
            RestArea(aArea)
        EndIf

        If lRet .and. self:lDuplicatas .and. self:oTipoDoc:ValidFinancialTitle(cPaisLoc) .and. oModelDUP:Length() > 0
            For nI := 1 To oModelDUP:Length()
                nTotDup += DesTrans(Extrae(oModelDUP:GetValue("DUP", nI),5,Iif(self:lCharDup,self:cCharDup,)))
            Next nI
            //Ajuste para permitir el valor financiero con impuestos provisionales del MATA462N y MATA462AN
            If self:lAjustDup .and. nTotDup > 0
                If Abs(xMoeda(nBaseDup,nMonedaNF,nMoeFin,dDataBase,,nTaxa) - nTotDup) > SuperGetMV("MV_LIMPAG")
                    oModel:SetErrorMessage("SF2_MASTER", 'F2_COND', 'SF2_MASTER', 'F2_COND', 'TitlesFin', STR0003, '', '') //Inconsistencias en los valores financieros.
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
                oModel:SetErrorMessage("SEV_DETAIL", 'EV_VALOR', "SEV_DETAIL", 'EV_VALOR', 'MultiNature', STR0009, '', '') //Valor de modalidades incorrecto.
            EndIf
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
Method GridPosVld(oSubModel, cModelID) Class LXOUTFIN
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
            oModel:SetErrorMessage(cModelID, 'EV_PERC', cModelID, 'EV_PERC', 'MultiPerc', STR0007 + STR0008 + TransForm(nPorcent,"@E 99.99%"), '', '') //La suma de los porcentajes informados de totalizar 100%. # Porcentaje alcanzado ==>
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
Method GridLinePosVld(oSubModel, cModelID, nLine) Class LXOUTFIN
Local lRet      := .T.
Local cTes      := ""
Local nQuant    := 0
Local nUnValue  := 0
Local nTotal    := 0
Local nTotAux   := 0
Local nMonedaNF := 1
Local nDesc:=0
Local oModel    := FwModelActivate()
Local oModelSF2 := oModel:GetModel("SF2_MASTER")
Local cDescSai   := SuperGetMV("MV_DESCSAI",,"1")
Local lValDes  :=.F.

    If cModelID == "SD2_DETAIL"

        cTes        := oSubModel:GetValue("D2_TES", nLine)
        nQuant      := oSubModel:GetValue("D2_QUANT", nLine)
        nUnValue    := oSubModel:GetValue("D2_PRCVEN", nLine)
        nTotal      := oSubModel:GetValue("D2_TOTAL", nLine)
        nDesc      := oSubModel:GetValue("D2_DESCON", nLine)
        nMonedaNF   := oModelSF2:GetValue("F2_MOEDA")

        IF cDescSai=="2"
            lValDes:=.T.
        EndIf

        If lRet .and. nUnValue < 0 .OR. (lValDes .AND. (nDesc>nTotal))
            lRet := .F.
            oModel:SetErrorMessage(cModelID, 'D2_PRCVEN', cModelID, 'D2_PRCVEN', 'UnitVal', STR0005, '', '') //Valor unitario no puede ser negativo.
        EndIf

        If lRet .and. self:oTipoDoc:ValidDecimals(cPaisLoc)
            If MaTesSel(cTes).And. nQuant == 0
                nTotAux := Iif(self:oTipoDoc:ValidArred(cPaisLoc), A410Arred((nUnValue),"D2_TOTAL",nMonedaNF),(nUnValue))
                If !self:oTipoDoc:NoValidTotalZero() .and. Abs(nTotal - nTotAux) > (1/(10**(Iif(MsDecimais(nMonedaNF)==0,1,MsDecimais(nMonedaNF))-1))) / IIF (MsDecimais(nMonedaNF)==0 ,1,  2)
                    oModel:SetErrorMessage(cModelID, 'D2_TOTAL', cModelID, 'D2_TOTAL', 'QuantZero', STR0006, '', '') //Inconsistencia en los valores del documento.
                    lRet := .F.
                EndIf
            Else
                nTotAux := Iif(self:oTipoDoc:ValidArred(cPaisLoc), A410Arred((nUnValue*nQuant),"D2_TOTAL",nMonedaNF),(nUnValue*nQuant))
                If Abs(nTotal - nTotAux) > (1/(10**(Iif(MsDecimais(nMonedaNF)==0,1,MsDecimais(nMonedaNF))-1)))/   IIF (MsDecimais(nMonedaNF)==0 ,1,  2) 
                    lRet := .F.
                    oModel:SetErrorMessage(cModelID, 'D2_TOTAL', cModelID, 'D2_TOTAL', 'D2_TOTAL', STR0006, '', '') //Inconsistencia en los valores del documento.
                EndIf
            EndIf
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} UpdNumberDetail
Metodo responsabe por realizar la actualización en caso de cambio de numeración por duplicidad,
actualiza datos en SF2 y SD2.
@type 		Method
@param 		cNumDoc	,caracter	, numero a ser actualizado en el modelo, encabezado y detalle.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method UpdNumberDetail(cNumDoc) Class LXOUTFIN
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

/*/{Protheus.doc} LocXAvCred
Metodo responsabe por verificar la información de credito
@type 		Method
@param 		nValDup		,numerico	    , valor del titulo
@param 		nMoedaNF     , numerico		, monedas para las validaciones.
@param 		cCliente    , caracter		, codico del cliente.
@param 		cLoja       , caracter		, tienda del cliente.
@Return     lCredito      ,logico       , indica retorno de las validaciones.
@author 	raul.medina	
@version	12.2.2210 / Superior
@since		05/2023
/*/
Method LocXAvCred(nValDup, nMoedaNF, cCliente, cLoja) Class LXOUTFIN
LOCAL lCredito  := .F.
Local lMTValAvC := ExistBlock("MTVALAVC")
Local nValAv	:= 0
Local cMsg      := ""
LOCAL cBlCred   := ""
LOCAL aEmpenho  := {}

Default cCliente := ""
Default cLoja    := ""
Default nValDup  := 0
Default nMoedaNF := 1

    //³ Efetuar a avaliacao do Cr‚dito  ³
    nValAv := Iif(lMTValAvC, ExecBLock("MTValAvC",.F.,.F.,{'LOCXNF',nVlrTotal,Nil}), nValDup)

    lCredito := MaAvalCred(cCliente, cLoja, nValAv, nMoedaNF, .T., @cBlCred, @aEmpenho)

    If !lCredito
        If !Empty(cBlCred)
            If cBlCred == "01"
                cMsg := STR0017 //"01-Sin Limite de Cr‚dito"
            ElseIf cBlCred == "04"
                cMsg := STR0018 //"04-Limite de Cr‚dito Vencido"
            Else
                cMsg := STR0019 //"99-Otros"
            EndIf
            If IsInCallStack("FA096Anula") .And. cBlCred == "04" .or. cBlCred == "01"
                lCredito := .T.
            Else
                Help(" ",1,"A467LC",,cMsg,4,5)
            EndIf
        EndIf
    EndIf
    
Return lCredito 
