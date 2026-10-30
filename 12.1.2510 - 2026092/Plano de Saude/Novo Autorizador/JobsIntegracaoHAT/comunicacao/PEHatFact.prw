#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"
#INCLUDE "PLSMGER.CH"

#Define ALIAS_DESCONTINUADOS "BAU|BC0|BA1|BFE|BTS|BT8|BT7|BRV|BG8|BFG|BFD|BFC|BF3|BEA|BCA|BC4|BC1|BB8|BB2|BAX"

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
    Method encerraPed(cPedido)

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

    //Pode haver pedidos ainda não processados na BNV para aliás que estamos descontinuando, então essa é uma proteção para não dar errorlog
    if !(cAlias $ ALIAS_DESCONTINUADOS)
        Do Case
            Case cStatus == "3"
                self:oPedido := SyncHndPLS():New()
            OtherWise            
                self:oPedido := &("PEHat"+cAlias+"():New()")
        EndCase

        self:oPedido:setDadBNV(cPedido,cAlias,cChaveBNV,nIDINT,cToken)
        self:oPedido:setDadBNN(cCodTrans)
    endif 

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
    Local cAlias  := oColBNV:getValue("alias")
    Local cPedido := oColBNV:getValue("code")

    //Pode haver pedidos ainda não processados na BNV para aliás que estamos descontinuando, então essa é uma proteção para não dar errorlog
    if cAlias $ ALIAS_DESCONTINUADOS
        self:encerraPed(cPedido)
    else
        if oColBNV:getValue("status") == "3"
            self:oPedido:procGetTok()
        else
            self:oPedido:procPedido() 
        endIf
    endif

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

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} encerraPed
    Encerra na BNV pedidos de alias que foram descontinuados, forcando
    status 5 (Proc.Sucesso) para que o schedule pare de reprocessa-los.

    @type  Class
    @author Nicole Luna
    @since 20260703
/*/
//------------------------------------------------------------------------------------------
Method encerraPed(cPedido) Class PEHatFact
    Local aCampos := {}

    Default cPedido := ""

    if !empty(cPedido)
        BNV->(DbSetOrder(1)) //BNV_FILIAL+BNV_CODIGO
        if BNV->(MsSeek(xFilial("BNV")+cPedido))
            aadd( aCampos,{ "BNV_STATUS", "5" })
            PLS274GRV( K_Alterar, aCampos )
        endIf
    endIf

Return
//-------------------------------------------------------------------
