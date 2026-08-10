#INCLUDE "TOTVS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenMoTotGu
    Classe para calculo de totalizadores
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class CenMoTotGu

    Data nVLTINF as Float 
    Data nVLTPRO as Float 
    Data nVLTPGP as Float 
    Data nVLTDIA as Float 
    Data nVLTTAX as Float 
    Data nVLTMAT as Float 
    Data nVLTOPM as Float 
    Data nVLTMED as Float 
    Data nVLTGLO as Float 
    Data nVLTGUI as Float
    Data nVLTFOR as Float 
    Data nVLTTBP as Float 
    Data nVLTCOP as Float 

    Method New(oExecutor) Constructor
    Method calGuiMon(oAux,cTipEve,lSoma) //Calcula Totalizadores Guia Monitoramento
    Method calForDir(oAux,lSoma) //Calcula Totalizadores Fornecimento Direto
    Method carGuiMon(oAuxCol) //Carrega Totalizadores Guia Monitoramento
    Method carForDir(oAuxCol) //Carrega Totalizadores Fornecimento Direto
    Method destroy()
    Method setValue(cProp,nValue)
    Method getValue(cProp)

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New 
    Metodo construtor da classe CenMoTotGu
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New(oExecutor) Class CenMoTotGu
   
    self:nVLTINF := 0 
    self:nVLTPRO := 0 
    self:nVLTPGP := 0 
    self:nVLTDIA := 0 
    self:nVLTTAX := 0 
    self:nVLTMAT := 0 
    self:nVLTOPM := 0 
    self:nVLTMED := 0 
    self:nVLTGLO := 0 
    self:nVLTGUI := 0
    self:nVLTFOR := 0 
    self:nVLTTBP := 0 
    self:nVLTCOP := 0 
        
Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} calGuiMon
    Calcula os totalizadores da guia

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method calGuiMon(oAux,cTipEve,lSoma) Class CenMoTotGu
    
    Local nVLTINF := 0
    Local nVLTPRO := 0
    Local nVLTPGP := 0 
    Local nVLTDIA := 0    
    Local nVLTTAX := 0 
    Local nVLTMAT := 0
    Local nVLTOPM := 0
    Local nVLTMED := 0
    Local nVLTGLO := 0 
    Local nVLTGUI := 0
    Local nVLTFOR := 0
    Local nVLTTBP := 0
    Local nVLTCOP := 0
    Default lSoma := .T.
    
    nVLTINF :=  oAux:getValue("valueEntered")
    nVLTPRO :=  oAux:getValue("valueEntered") - oAux:getValue("disallVl")
    nVLTGLO :=  oAux:getValue("disallVl")
    nVLTGUI :=  oAux:getValue("procedureValuePaid")
    nVLTFOR :=  oAux:getValue("valuePaidSupplier")
    nVLTCOP :=  oAux:getValue("coPaymentValue")
    
    if cTipEve == "0" //Procedimentos        
        nVLTPGP := oAux:getValue("procedureValuePaid")
    elseIf cTipEve == "4" //Diarias
        nVLTDIA += oAux:getValue("procedureValuePaid")
    elseIf cTipEve == "3" //Taxas
        nVLTTAX += oAux:getValue("procedureValuePaid")
    elseIf cTipEve == "1" //Materiais
        nVLTMAT += oAux:getValue("procedureValuePaid")
    elseIf cTipEve == "5" //Opme
        nVLTOPM += oAux:getValue("procedureValuePaid")    
    elseIf cTipEve == "2" //Medicamento
        nVLTMED += oAux:getValue("procedureValuePaid")
    endIf

    if oAux:getValue("tableCode") $ "00,90,98"
        nVLTTBP += oAux:getValue("procedureValuePaid")
    endIf

    self:nVLTINF += nVLTINF
    self:nVLTPRO += nVLTPRO
    if lSoma
        self:nVLTPGP += nVLTPGP
        self:nVLTDIA += nVLTDIA
        self:nVLTTAX += nVLTTAX
        self:nVLTMAT += nVLTMAT
        self:nVLTOPM += nVLTOPM
        self:nVLTMED += nVLTMED
        self:nVLTGLO += nVLTGLO
        self:nVLTGUI += nVLTGUI
        self:nVLTFOR += nVLTFOR
        self:nVLTTBP += nVLTTBP
        self:nVLTCOP += nVLTCOP
    endIf
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} calForDir
    Calcula os totalizadores do fornecimento direto

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method calForDir(oAux,lSoma) Class CenMoTotGu
    
    Local nVLTGUI := 0
    Local nVLTCOP := 0
    Local nVLTTBP := 0
    Default lSoma := .T.
    
    nVLTGUI :=  oAux:getValue("procedureValuePaid") //* oAux:getValue("enteredQuantity")
    nVLTCOP :=  oAux:getValue("coPaymentValue") //* oAux:getValue("enteredQuantity")

    if oAux:getValue("tableCode") $ "00,90,98"
        nVLTTBP += oAux:getValue("procedureValuePaid") //* oAux:getValue("enteredQuantity")
    endIf
 
    if lSoma
        self:nVLTGUI += nVLTGUI
        self:nVLTCOP += nVLTCOP
        self:nVLTTBP += nVLTTBP
    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} carGuiMon
    Carrega os dados totalizadores de uma collect BKR

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method carGuiMon(oAuxCol) Class CenMoTotGu

    self:nVLTINF := oAuxCol:getValue("totalValueEntered")
    self:nVLTPRO := oAuxCol:getValue("valueProcessed")
    self:nVLTPGP := oAuxCol:getValue("procedureTotalValuePai")
    self:nVLTDIA := oAuxCol:getValue("dailyRatesTotalValue")
    self:nVLTTAX := oAuxCol:getValue("feesTotalValue")
    self:nVLTMAT := oAuxCol:getValue("materialsTotalValue")
    self:nVLTOPM := oAuxCol:getValue("totalOpmeValue")
    self:nVLTMED := oAuxCol:getValue("medicationTotalValue")
    self:nVLTGLO := oAuxCol:getValue("formDisallowanceValue")
    self:nVLTGUI := oAuxCol:getValue("valuePaidForm")
    self:nVLTFOR := oAuxCol:getValue("valuePaidSuppliers")
    self:nVLTTBP := oAuxCol:getValue("ownTableTotalValue")
    self:nVLTCOP := oAuxCol:getValue("coPaymentTotalValue")

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} carGuiMon
    Carrega os dados totalizadores de uma collect BKR

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method carForDir(oAuxCol) Class CenMoTotGu

    self:nVLTGUI := oAuxCol:getValue("valuePaidForm")
    self:nVLTCOP := oAuxCol:getValue("coPaymentTotalValue")
    self:nVLTTBP := oAuxCol:getValue("ownTableTotalValue")

Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} destroy
    Destroi o objeto

    @type  Class
    @author renan.almeida
    @since 2011010
/*/
//------------------------------------------------------------------------------------------
Method destroy() Class CenMoTotGu
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setVLTGLO
    Adiciona um valor para uma propriedade do objeto

    @type  Class
    @author renan.almeida
    @since 2011010
/*/
//------------------------------------------------------------------------------------------
Method setValue(cProp,nValue) Class CenMoTotGu

    Local lRet := .F.

    Do Case 
        Case cProp == "nVLTINF"
            self:nVLTINF := nValue
            lRet := .T.

        Case cProp == "nVLTPRO" 
            self:nVLTPRO := nValue
            lRet := .T.

        Case cProp == "nVLTPGP" 
            self:nVLTPGP := nValue
            lRet := .T.

        Case cProp == "nVLTDIA" 
            self:nVLTDIA := nValue
            lRet := .T.

        Case cProp == "nVLTTAX"
            self:nVLTTAX := nValue
            lRet := .T.

        Case cProp == "nVLTMAT"
            self:nVLTMAT := nValue
            lRet := .T.

        Case cProp == "nVLTOPM"
            self:nVLTOPM := nValue
            lRet := .T.

        Case cProp == "nVLTMED"
            self:nVLTMED := nValue
            lRet := .T.

        Case cProp == "nVLTGLO"
            self:nVLTGLO := nValue
            lRet := .T.

        Case cProp == "nVLTGUI"
            self:nVLTGUI := nValue
            lRet := .T.

        Case cProp == "nVLTFOR"
            self:nVLTFOR := nValue
            lRet := .T.

        Case cProp == "nVLTTBP"
            self:nVLTTBP := nValue
            lRet := .T.

        Case cProp == "nVLTCOP"
            self:nVLTCOP := nValue
            lRet := .T.

    EndCase

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getValue
    Retorna o valor de uma propriedade do objeto

    @type  Class
    @author renan.almeida
    @since 2011010
/*/
//------------------------------------------------------------------------------------------
Method getValue(cProp) Class CenMoTotGu

    Local nRet := 0

    Do Case 
        Case cProp == "nVLTINF"
            nRet := self:nVLTINF

        Case cProp == "nVLTPRO" 
            nRet := self:nVLTPRO

        Case cProp == "nVLTPGP" 
            nRet := self:nVLTPGP
        
        Case cProp == "nVLTDIA" 
            nRet := self:nVLTDIA
        
        Case cProp == "nVLTTAX"
            nRet := self:nVLTTAX
        
        Case cProp == "nVLTMAT"
            nRet := self:nVLTMAT
        
        Case cProp == "nVLTOPM"
            nRet := self:nVLTOPM 
        
        Case cProp == "nVLTMED"
            nRet := self:nVLTMED
       
        Case cProp == "nVLTGLO"
            nRet := self:nVLTGLO
        
        Case cProp == "nVLTGUI"
            nRet := self:nVLTGUI
        
        Case cProp == "nVLTFOR"
            nRet := self:nVLTFOR
        
        Case cProp == "nVLTTBP"
            nRet := self:nVLTTBP
       
        Case cProp == "nVLTCOP"
            nRet := self:nVLTCOP

    EndCase

Return nRet
