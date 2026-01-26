#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBB2
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBB2 From PEHatGener

	Method New()
    Method montaCabec(oObj)

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatBB2

    Default cPedido := ''
    
    _Super:New()
    self:cNodePrinc := 'items'
    self:aNodeKey   := {'healthProductCode','healthProductVersion','procedureTableCode','procedureCode'}

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} montaCabec

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method montaCabec(oObj) Class PEHatBB2

	oObj['healthInsurerId']        := self:cCodOpe
	oObj['ansRegistry']            := self:cSusep 
    oObj['coverageProcedureLevel'] := 'produto'
    
Return