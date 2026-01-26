#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBRV
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBRV From PEHatGener

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
Method New() Class PEHatBRV

    Default cPedido := ''
    
    _Super:New()
    self:nInd       := 1
    self:cNodePrinc := 'items'
    self:aNodeKey   := {'healthProductCode','healthProductVersion'}

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} montaCabec

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method montaCabec(oObj) Class PEHatBRV

	oObj['healthInsurerId']    := self:cCodOpe
	oObj['ansRegistry']        := self:cSusep 
    oObj['coverageGroupLevel'] := 'produto'
    
Return