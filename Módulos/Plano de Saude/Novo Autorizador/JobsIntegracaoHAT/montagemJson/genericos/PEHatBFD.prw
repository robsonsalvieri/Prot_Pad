#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBFD
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBFD From PEHatGener

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
Method New() Class PEHatBFD

    Default cPedido := ''
    
    _Super:New()
    self:cNodePrinc := 'items'
    self:aNodeKey   := {'companyId','subscriberId','procedureCode','procedureTableCode'}

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} montaCabec

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method montaCabec(oObj) Class PEHatBFD

    oObj['healthInsurerId']        := self:cCodOpe
	oObj['ansRegistry']            := self:cSusep 
    oObj['coverageProcedureLevel'] := 'familia'

Return