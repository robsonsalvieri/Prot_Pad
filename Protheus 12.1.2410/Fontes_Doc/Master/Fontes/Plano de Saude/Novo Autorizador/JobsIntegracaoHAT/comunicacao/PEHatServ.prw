#INCLUDE "TOTVS.CH"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatServ
    Servico que realiza o envio dos cadastros do PLS para o HAT
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatServ From PLSService
	   
    Method New() 
    Method runProc(oObj)
    
EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatServ

    _Super:New()
    self:cLogFile := "plshatservice.log"
    self:cAlias   := "BNV"
    self:oFila    := CenFilaBd():New(PlsCltBNV():New())
    self:oProc    := PEHatFact():New()
    
Return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} runProc
    Processa um pedido
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method runProc(oColBNV) Class PEHatServ

    self:oProc:setup(oColBNV)
    self:oProc:procBNV(oColBNV)
    
Return