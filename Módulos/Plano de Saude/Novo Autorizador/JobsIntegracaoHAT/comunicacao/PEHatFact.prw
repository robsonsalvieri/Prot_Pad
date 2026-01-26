#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatFact
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatFact
    
    Data oPedido

	Method New()
    Method setup(oColBNV)
    Method setAuto(lAuto,cJsAutPost,cJsAutGet)
    Method procBNV()
    Method getJson()

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatFact
      
    self:oPedido := nil
  
Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method setup(oColBNV) Class PEHatFact

    Local cPedido   := oColBNV:getValue("code")
    Local cAlias    := oColBNV:getValue("alias")
    Local cChaveBNV := oColBNV:getValue("key")
    Local nIDINT    := oColBNV:getValue("integrationID")
    Local cCodTrans := oColBNV:getValue("transactionCode")
    Local cStatus   := oColBNV:getValue("status")
    Local cToken    := oColBNV:getValue("token")

    Do Case
        Case cStatus == "3"
            self:oPedido := SyncHndPLS():New()

        Case cCodTrans $ _beneficiaries_inc+"/"+_beneficiaries_alt
            self:oPedido := PEHatBenef():New()

        Case cCodTrans $ _healthProviders_inc+"/"+_healthProviders_alt
            self:oPedido := PEHatPrest():New()

        OtherWise
            self:oPedido := &("PEHat"+cAlias+"():New()")
    EndCase

    self:oPedido:setDadBNV(cPedido,cAlias,cChaveBNV,nIDINT,cToken)
    self:oPedido:setDadBNN(cCodTrans)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setAuto
    Metodo para setar dados de automacao
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method setAuto(lAuto,cJsAutPost,cJsAutGet) Class PEHatFact

    if ValType(self:oPedido) <> nil
        self:oPedido:lAuto      := lAuto
        self:oPedido:cJsAutPost := cJsAutPost
        self:oPedido:cJsAutGet  := cJsAutGet
    endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procBNV
    Processa o pedido

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method procBNV(oColBNV) Class PEHatFact
    
    if oColBNV:getValue("status") == "3"
        self:oPedido:procGetTok()
    else
        self:oPedido:procPedido() 
    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getJson
    Retorna o Json do Pedido

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method getJson() Class PEHatFact
Return self:oPedido:cJson